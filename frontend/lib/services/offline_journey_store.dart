import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show MissingPluginException;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/speech.dart';
import 'journey_api.dart';
import 'journey_engine.dart';
import 'journey_models.dart';
import 'offline_lesson_store.dart';

class OfflineJourneyException implements Exception {
  const OfflineJourneyException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Recording storage used by journeys. The default adapter shares the
/// account's 50 MB lesson-download allowance, integrity and expiry rules.
abstract class JourneyMediaStore {
  Future<Set<int>> completeIds();
  Future<void> download(int audioId, OfflineDownload operation);
  Future<String> localPath(int audioId);
  Future<void> remove(int audioId);
}

class LessonStoreMedia implements JourneyMediaStore {
  LessonStoreMedia(this.store);
  final OfflineLessonStore store;

  @override
  Future<Set<int>> completeIds() async => {
    for (final lesson in await store.list())
      if (lesson.complete && !lesson.revoked) lesson.audioId,
  };

  @override
  Future<void> download(int audioId, OfflineDownload operation) =>
      store.download(audioId, operation);

  @override
  Future<String> localPath(int audioId) async {
    try {
      await store.renew(audioId);
    } on OfflineLessonException catch (error) {
      if (!error.mayUseExistingAccess) rethrow;
    }
    return store.localPath(audioId);
  }

  @override
  Future<void> remove(int audioId) => store.remove(audioId);
}

/// Browsers cannot save recordings for offline use; journeys stream them.
class StreamOnlyMedia implements JourneyMediaStore {
  const StreamOnlyMedia();

  static String get unavailable => Speech.t.journeyDownloadNeedsApp;

  @override
  Future<Set<int>> completeIds() async => <int>{};

  @override
  Future<void> download(int audioId, OfflineDownload operation) async =>
      throw OfflineJourneyException(unavailable);

  @override
  Future<String> localPath(int audioId) async =>
      throw OfflineJourneyException(unavailable);

  @override
  Future<void> remove(int audioId) async {}
}

/// Where the journey store keeps its small JSON files.
abstract class JourneyFiles {
  String get key;
  Future<String?> read(String name);
  Future<void> write(String name, String contents);
  Future<void> delete(String name);
  Future<List<String>> names();
}

class _DirectoryFiles implements JourneyFiles {
  _DirectoryFiles(this.directory);
  final Directory directory;

  File _file(String name) =>
      File('${directory.path}${Platform.pathSeparator}$name');

  @override
  String get key => directory.absolute.path;

  @override
  Future<String?> read(String name) async {
    final file = _file(name);
    return await file.exists() ? file.readAsString() : null;
  }

  @override
  Future<void> write(String name, String contents) async {
    await directory.create(recursive: true);
    final file = _file(name);
    final temp = File('${file.path}.tmp');
    await temp.writeAsString(contents, flush: true);
    await temp.rename(file.path);
  }

  @override
  Future<void> delete(String name) async {
    final file = _file(name);
    if (await file.exists()) await file.delete();
  }

  @override
  Future<List<String>> names() async {
    if (!await directory.exists()) return [];
    return [
      await for (final entry in directory.list(followLinks: false))
        if (entry is File) entry.uri.pathSegments.last,
    ];
  }
}

/// Browser storage: one preference entry per file, scoped to the account.
class _PreferenceFiles implements JourneyFiles {
  _PreferenceFiles(this.preferences, int userId)
    : prefix = 'seeds_journeys_${userId}_';
  final SharedPreferences preferences;
  final String prefix;

  @override
  String get key => prefix;

  @override
  Future<String?> read(String name) async =>
      preferences.getString('$prefix$name');

  @override
  Future<void> write(String name, String contents) =>
      preferences.setString('$prefix$name', contents);

  @override
  Future<void> delete(String name) => preferences.remove('$prefix$name');

  @override
  Future<List<String>> names() async => [
    for (final key in preferences.getKeys())
      if (key.startsWith(prefix)) key.substring(prefix.length),
  ];
}

class JourneySyncReport {
  const JourneySyncReport({
    this.sent = 0,
    this.rejected = 0,
    this.remaining = 0,
    this.offline = false,
  });
  final int sent;
  final int rejected;
  final int remaining;
  final bool offline;
}

/// Account-private journey files: downloaded snapshots, resume progress and
/// runs waiting to be sent to the school server.
class OfflineJourneyStore {
  OfflineJourneyStore({
    required Directory root,
    required this.userId,
    required this.media,
  }) : _files = _DirectoryFiles(
         Directory(
           '${root.path}${Platform.pathSeparator}seeds_learning'
           '${Platform.pathSeparator}$userId${Platform.pathSeparator}journeys',
         ),
       ) {
    if (userId <= 0) throw ArgumentError.value(userId, 'userId');
  }

  /// Browser store: progress and unsent answers in browser storage;
  /// recordings stream instead of downloading.
  OfflineJourneyStore.browser({
    required SharedPreferences preferences,
    required this.userId,
    this.media = const StreamOnlyMedia(),
  }) : _files = _PreferenceFiles(preferences, userId) {
    if (userId <= 0) throw ArgumentError.value(userId, 'userId');
  }

  final JourneyFiles _files;
  final int userId;
  final JourneyMediaStore media;
  static final _queues = <String, Future<void>>{};

  static Future<OfflineJourneyStore> forCurrentUser() async {
    final preferences = await SharedPreferences.getInstance();
    final id = preferences.getInt('user_id');
    if (id == null || id <= 0) {
      throw OfflineJourneyException(Speech.t.journeySignInFirst);
    }
    if (kIsWeb) {
      return OfflineJourneyStore.browser(preferences: preferences, userId: id);
    }
    try {
      final root = await getApplicationSupportDirectory();
      final lessons = await OfflineLessonStore.forCurrentUser();
      return OfflineJourneyStore(
        root: root,
        userId: id,
        media: LessonStoreMedia(lessons),
      );
    } on MissingPlatformDirectoryException {
      throw OfflineJourneyException(Speech.t.journeyStorageUnavailableDevice);
    } on OfflineLessonException catch (error) {
      throw OfflineJourneyException(error.message);
    } on MissingPluginException {
      throw OfflineJourneyException(Speech.t.journeyStorageUnavailableDevice);
    }
  }

  String _snapshotFile(int id) => 'journey_$id.json';
  String _progressFile(int id) => 'progress_$id.json';
  static const _pendingFile = 'pending_runs.json';

  Future<T> _exclusive<T>(Future<T> Function() action) {
    final key = _files.key;
    final result = (_queues[key] ?? Future<void>.value()).then((_) async {
      try {
        return await action();
      } on FileSystemException {
        throw OfflineJourneyException(Speech.t.journeyStorageFull);
      }
    });
    final tail = result.then<void>((_) {}, onError: (_) {});
    _queues[key] = tail;
    unawaited(
      tail.whenComplete(() {
        if (identical(_queues[key], tail)) _queues.remove(key);
      }),
    );
    return result;
  }

  Future<void> _write(String name, Object value) =>
      _files.write(name, jsonEncode(value));

  Future<Object?> _read(String name) async {
    final text = await _files.read(name);
    if (text == null) return null;
    try {
      return jsonDecode(text);
    } on FormatException {
      return null;
    }
  }

  // ─── Downloaded snapshots ────────────────────────────────────────────────

  Future<JourneySnapshot?> savedSnapshot(int journeyId) => _exclusive(() async {
    final data = await _read(_snapshotFile(journeyId));
    if (data is! Map || data['account_id'] != userId) return null;
    try {
      final snapshot = JourneySnapshot.parse(data['snapshot']);
      return snapshot.journeyId == journeyId ? snapshot : null;
    } on FormatException {
      return null;
    }
  });

  Future<void> saveSnapshot(JourneySnapshot snapshot) => _exclusive(
    () => _write(_snapshotFile(snapshot.journeyId), {
      'version': 1,
      'account_id': userId,
      'snapshot': snapshot.toJson(),
    }),
  );

  Future<List<JourneySnapshot>> savedSnapshots() => _exclusive(() async {
    final result = <JourneySnapshot>[];
    for (final name in await _files.names()) {
      final match = RegExp(r'^journey_([1-9][0-9]*)\.json$').firstMatch(name);
      if (match == null) continue;
      final data = await _read(name);
      if (data is! Map || data['account_id'] != userId) continue;
      try {
        result.add(JourneySnapshot.parse(data['snapshot']));
      } on FormatException {
        debugPrint('[JOURNEY] Unreadable saved journey kept.');
      }
    }
    return result..sort((a, b) => a.title.compareTo(b.title));
  });

  /// True when the snapshot and every recording in it are saved on this phone.
  Future<bool> isDownloaded(JourneySnapshot snapshot) async {
    final saved = await savedSnapshot(snapshot.journeyId);
    if (saved == null || saved.revision != snapshot.revision) return false;
    final complete = await media.completeIds();
    return snapshot.audioIds.every(complete.contains);
  }

  /// Saves the journey and downloads its recordings one at a time.
  Future<void> download(
    JourneySnapshot snapshot, {
    OfflineDownload? operation,
    void Function(int done, int total)? onProgress,
  }) async {
    final ids = snapshot.audioIds.toSet().toList();
    final complete = await media.completeIds();
    var done = ids.where(complete.contains).length;
    onProgress?.call(done, ids.length);
    for (final id in ids) {
      if (complete.contains(id)) continue;
      final current = operation ?? OfflineDownload();
      if (current.cancelled) {
        throw OfflineJourneyException(Speech.t.journeyDownloadCancelled);
      }
      try {
        await media.download(id, current);
      } on OfflineLessonException catch (error) {
        throw OfflineJourneyException(
          '${error.message} ${Speech.t.journeyRecordingsSaved('$done', '${ids.length}')}',
        );
      }
      done++;
      onProgress?.call(done, ids.length);
    }
    await saveSnapshot(snapshot);
  }

  /// Removes the saved journey and recordings no other saved journey uses.
  Future<int> removeDownload(int journeyId) async {
    final all = await savedSnapshots();
    final target = all.where((s) => s.journeyId == journeyId).firstOrNull;
    if (target == null) return 0;
    final shared = {
      for (final other in all)
        if (other.journeyId != journeyId) ...other.audioIds,
    };
    var removed = 0;
    for (final id in target.audioIds.toSet()) {
      if (shared.contains(id)) continue;
      try {
        await media.remove(id);
        removed++;
      } on OfflineLessonException {
        debugPrint('[JOURNEY] A recording could not be removed; it is kept.');
      }
    }
    await _exclusive(() => _files.delete(_snapshotFile(journeyId)));
    return removed;
  }

  // ─── Progress and sync queue ─────────────────────────────────────────────

  Future<Object?> loadProgress(int journeyId) =>
      _exclusive(() => _read(_progressFile(journeyId)));

  /// Saves resume progress and queues the run for the server.
  Future<void> saveProgress(JourneyEngine engine, {bool offline = false}) =>
      _exclusive(() async {
        await _write(_progressFile(engine.snapshot.journeyId), engine.toJson());
        final pending = await _pending();
        if (engine.answers.isNotEmpty || engine.finished) {
          final previous = pending[engine.runId];
          final wasOffline =
              previous is Map && previous['played_offline'] == true;
          pending[engine.runId] = engine.toSyncJson(
            playedOffline: offline || wasOffline,
          );
          await _write(_pendingFile, pending);
        }
      });

  Future<void> clearProgress(int journeyId) =>
      _exclusive(() => _files.delete(_progressFile(journeyId)));

  Future<Map<String, dynamic>> _pending() async {
    final data = await _read(_pendingFile);
    if (data is! Map) return {};
    return {
      for (final entry in data.entries)
        if (entry.key is String && entry.value is Map)
          entry.key as String: entry.value,
    };
  }

  Future<int> pendingCount() => _exclusive(() async => (await _pending()).length);

  /// Sends queued runs. Accepted and permanently rejected runs leave the
  /// queue; everything is kept when the server cannot be reached.
  Future<JourneySyncReport> syncPending(JourneyApi api) async {
    final pending = await _exclusive(_pending);
    if (pending.isEmpty) return const JourneySyncReport();
    final runs = pending.values.cast<Map<String, dynamic>>().take(50).toList();
    final ({List<String> accepted, List<String> rejected}) result;
    try {
      result = await api.sync(runs);
    } on JourneyApiException catch (error) {
      return JourneySyncReport(
        remaining: pending.length,
        offline: error.network,
      );
    }
    return _exclusive(() async {
      final latest = await _pending();
      for (final id in [...result.accepted, ...result.rejected]) {
        final sent = runs.where((run) => run['run_id'] == id).firstOrNull;
        // Keep a run that gained new answers while the request was in flight.
        if (sent != null && jsonEncode(latest[id]) == jsonEncode(sent)) {
          latest.remove(id);
        }
      }
      await _write(_pendingFile, latest);
      return JourneySyncReport(
        sent: result.accepted.length,
        rejected: result.rejected.length,
        remaining: latest.length,
      );
    });
  }
}
