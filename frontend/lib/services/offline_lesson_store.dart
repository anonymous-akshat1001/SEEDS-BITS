import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/speech.dart';
import 'api_service.dart';
import 'activity_telemetry.dart';

class OfflineLessonException implements Exception {
  const OfflineLessonException(
    this.message, {
    this.mayUseExistingAccess = false,
  });
  final String message;
  final bool mayUseExistingAccess;
  @override
  String toString() => message;
}

class OfflineLesson {
  OfflineLesson({
    required this.audioId,
    required this.title,
    required this.bytes,
    required this.digest,
    required this.authorizedAt,
    required this.expiresAt,
    required this.mimeType,
    required this.accountId,
    required this.classId,
    required this.subjectId,
    this.complete = false,
    this.revoked = false,
  });
  final int audioId;
  final int accountId;
  final int classId;
  final int subjectId;
  final String title;
  final int bytes;
  final String digest;
  final String mimeType;
  final DateTime authorizedAt;
  final DateTime expiresAt;
  final bool complete;
  final bool revoked;

  factory OfflineLesson.parse(Map<String, dynamic> data, int accountId) {
    final id = data['audio_id'];
    final size = data['bytes'];
    final authorized = data['authorized_at'];
    final expiry = data['expires_at'];
    final digest = data['sha256'];
    if (data['version'] != 1 ||
        data['account_id'] != accountId ||
        id is! int ||
        id <= 0 ||
        size is! int ||
        size <= 0 ||
        size > OfflineLessonStore.quota ||
        authorized is! int ||
        authorized <= 0 ||
        expiry is! int ||
        expiry > 8640000000000 ||
        expiry <= authorized ||
        expiry - authorized > const Duration(days: 30).inSeconds ||
        digest is! String ||
        !RegExp(r'^[a-f0-9]{64}$').hasMatch(digest) ||
        data['title'] is! String ||
        (data['title'] as String).trim().isEmpty ||
        data['mime_type'] is! String ||
        data['class_id'] is! int ||
        data['subject_id'] is! int ||
        (data.containsKey('complete') && data['complete'] is! bool) ||
        (data.containsKey('revoked') && data['revoked'] is! bool)) {
      throw OfflineLessonException(Speech.t.downloadErrInvalidInfo);
    }
    return OfflineLesson(
      audioId: id,
      accountId: accountId,
      classId: data['class_id'] as int,
      subjectId: data['subject_id'] as int,
      title: data['title'] as String,
      bytes: size,
      digest: digest,
      mimeType: data['mime_type'] as String,
      authorizedAt: DateTime.fromMillisecondsSinceEpoch(
        authorized * 1000,
        isUtc: true,
      ),
      expiresAt: DateTime.fromMillisecondsSinceEpoch(
        expiry * 1000,
        isUtc: true,
      ),
      complete: data['complete'] == true,
      revoked: data['revoked'] == true,
    );
  }

  Map<String, dynamic> toJson({bool? complete, bool? revoked}) => {
    'version': 1,
    'account_id': accountId,
    'audio_id': audioId,
    'title': title,
    'class_id': classId,
    'subject_id': subjectId,
    'mime_type': mimeType,
    'bytes': bytes,
    'sha256': digest,
    'authorized_at': authorizedAt.millisecondsSinceEpoch ~/ 1000,
    'expires_at': expiresAt.millisecondsSinceEpoch ~/ 1000,
    'complete': complete ?? this.complete,
    'revoked': revoked ?? this.revoked,
  };
}

class OfflineDownload extends ChangeNotifier {
  bool _cancelled = false;
  int received = 0;
  int total = 0;
  bool get cancelled => _cancelled;
  void cancel() {
    _cancelled = true;
    _client?.close();
    notifyListeners();
  }

  http.Client? _client;
  void _progress(int value, int size) {
    received = value;
    total = size;
    notifyListeners();
  }
}

class OfflineLessonStore {
  OfflineLessonStore({
    required Directory root,
    required this.userId,
    required this.apiBase,
    required this.credentials,
    http.Client Function()? clientFactory,
    DateTime Function()? clock,
  }) : directory = Directory(
         '${root.path}${Platform.pathSeparator}seeds_learning'
         '${Platform.pathSeparator}$userId${Platform.pathSeparator}downloads',
       ),
       _clientFactory = clientFactory ?? (() => http.Client()),
       _clock = clock ?? DateTime.now {
    if (userId <= 0) throw ArgumentError.value(userId, 'userId');
  }
  static const quota = 50000000;
  final Directory directory;
  final int userId;
  final Uri apiBase;
  final Future<String?> Function() credentials;
  final http.Client Function() _clientFactory;
  final DateTime Function() _clock;
  static final _queues = <String, Future<void>>{};

  static Future<OfflineLessonStore> forCurrentUser() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final id = preferences.getInt('user_id');
      if (id == null || id <= 0) {
        throw OfflineLessonException(Speech.t.downloadErrSignInToOpen);
      }
      final root = await getApplicationSupportDirectory();
      if (preferences.getInt('user_id') != id) {
        throw OfflineLessonException(Speech.t.downloadErrAccountChanged);
      }
      return OfflineLessonStore(
        root: root,
        userId: id,
        apiBase: Uri.parse(ApiService.baseUrl),
        credentials: () async {
          if (preferences.getInt('user_id') != id) {
            throw OfflineLessonException(Speech.t.downloadErrAccountChanged);
          }
          return preferences.getString('token');
        },
      );
    } on MissingPlatformDirectoryException {
      throw OfflineLessonException(Speech.t.downloadErrNoStorage);
    }
  }

  File _file(int id, String suffix) {
    if (id <= 0) throw ArgumentError.value(id, 'audioId');
    return File('${directory.path}${Platform.pathSeparator}$id.$suffix');
  }

  Future<T> _exclusive<T>(Future<T> Function() action) {
    final key = directory.absolute.path;
    final result = (_queues[key] ?? Future<void>.value()).then((_) async {
      try {
        await credentials();
        return await action();
      } on FileSystemException {
        throw OfflineLessonException(Speech.t.downloadErrStorageUnavailable);
      } on FormatException {
        throw OfflineLessonException(Speech.t.downloadErrRecordsUnreadable);
      }
    });
    final tail = result.then<void>(
      (_) {},
      onError: (Object error, StackTrace stack) {
        debugPrint('[OFFLINE] Operation failed (${error.runtimeType})');
      },
    );
    _queues[key] = tail;
    unawaited(
      tail.whenComplete(() {
        if (identical(_queues[key], tail)) _queues.remove(key);
      }),
    );
    return result;
  }

  Future<OfflineLesson?> _read(int id) async {
    final file = _file(id, 'json');
    final temp = _file(id, 'json.tmp');
    final source = await file.exists() ? file : temp;
    if (!await source.exists()) return null;
    final data = jsonDecode(await source.readAsString());
    if (data is! Map<String, dynamic>) {
      throw OfflineLessonException(Speech.t.downloadErrRecordUnreadable);
    }
    final lesson = OfflineLesson.parse(data, userId);
    if (lesson.audioId != id) {
      throw OfflineLessonException(Speech.t.downloadErrIdentityMismatch);
    }
    if (source.path == temp.path) await temp.rename(file.path);
    return lesson;
  }

  Future<void> _write(
    OfflineLesson lesson, {
    bool? complete,
    bool? revoked,
  }) async {
    await directory.create(recursive: true);
    final temp = _file(lesson.audioId, 'json.tmp');
    await temp.writeAsString(
      jsonEncode(lesson.toJson(complete: complete, revoked: revoked)),
      flush: true,
    );
    await temp.rename(_file(lesson.audioId, 'json').path);
  }

  Future<List<OfflineLesson>> _list({List<int>? unreadableIds}) async {
    if (!await directory.exists()) return [];
    final ids = <int>{};
    await for (final entry in directory.list(followLinks: false)) {
      if (entry is! File) continue;
      final match = RegExp(
        r'^([1-9][0-9]*)\.json(?:\.tmp)?$',
      ).firstMatch(entry.uri.pathSegments.last);
      if (match != null) ids.add(int.parse(match.group(1)!));
    }
    final records = <OfflineLesson>[];
    for (final id in ids) {
      try {
        final lesson = await _read(id);
        if (lesson != null) records.add(lesson);
      } on OfflineLessonException {
        if (unreadableIds == null) rethrow;
        debugPrint('[OFFLINE] Unreadable download record $id retained.');
        unreadableIds.add(id);
      } on FormatException {
        if (unreadableIds == null) rethrow;
        debugPrint('[OFFLINE] Malformed download record $id retained.');
        unreadableIds.add(id);
      }
    }
    return records..sort((a, b) => a.title.compareTo(b.title));
  }

  Future<List<OfflineLesson>> list() => _exclusive(() => _list());

  Future<({List<OfflineLesson> lessons, List<int> unreadableIds})>
  inspectRecords() => _exclusive(() async {
    final unreadableIds = <int>[];
    final lessons = await _list(unreadableIds: unreadableIds);
    return (lessons: lessons, unreadableIds: unreadableIds..sort());
  });

  Future<int> _reserved() async {
    var total = 0;
    final lessons = await _list();
    for (final lesson in lessons) {
      // Reserve the complete size even for a partial file, preventing overbook.
      total += lesson.bytes;
    }
    if (await directory.exists()) {
      final known = lessons.map((lesson) => lesson.audioId).toSet();
      await for (final entry in directory.list(followLinks: false)) {
        if (entry is! File) continue;
        final match = RegExp(
          r'^([1-9][0-9]*)\.(media|part)$',
        ).firstMatch(entry.uri.pathSegments.last);
        if (match != null && !known.contains(int.parse(match.group(1)!))) {
          total += await entry.length();
        }
      }
    }
    return total;
  }

  Future<int> reservedBytes() => _exclusive(_reserved);

  Future<OfflineLesson> _manifest(int id) async {
    final token = await credentials();
    if (token == null || token.isEmpty) {
      throw OfflineLessonException(Speech.t.downloadErrSignInToRenew);
    }
    final client = _clientFactory();
    try {
      final response = await client
          .get(
            apiBase.resolve('/audio/$id/offline-manifest'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 10));
      if (await credentials() != token) {
        throw OfflineLessonException(Speech.t.downloadErrSignInChanged);
      }
      if (response.statusCode == 401 ||
          response.statusCode == 403 ||
          response.statusCode == 404) {
        final existing = await _read(id);
        if (existing != null) await _write(existing, revoked: true);
        throw OfflineLessonException(Speech.t.downloadErrAccessNotConfirmed);
      }
      if (response.statusCode == 413) {
        throw OfflineLessonException(Speech.t.downloadErrTooLarge);
      }
      if (response.statusCode != 200) {
        throw OfflineLessonException(Speech.t.downloadErrRenewServer);
      }
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw OfflineLessonException(Speech.t.downloadErrInvalidServerInfo);
      }
      final manifest = OfflineLesson.parse(decoded, userId);
      if (manifest.audioId != id) {
        throw OfflineLessonException(Speech.t.downloadErrDifferentRecording);
      }
      return manifest;
    } on TimeoutException {
      throw OfflineLessonException(
        Speech.t.downloadErrTimedOut,
        mayUseExistingAccess: true,
      );
    } on http.ClientException {
      throw OfflineLessonException(
        Speech.t.downloadErrRenewConnect,
        mayUseExistingAccess: true,
      );
    } on SocketException {
      throw OfflineLessonException(
        Speech.t.downloadErrRenewConnect,
        mayUseExistingAccess: true,
      );
    } finally {
      client.close();
    }
  }

  Future<bool> _intact(File file, OfflineLesson lesson) async =>
      await file.exists() &&
      await file.length() == lesson.bytes &&
      (await sha256.bind(file.openRead()).first).toString() == lesson.digest;

  Future<void> _writeClock(DateTime value) async {
    final temp = File(
      '${directory.path}${Platform.pathSeparator}clock.json.tmp',
    );
    await temp.writeAsString(
      jsonEncode({
        'account_id': userId,
        'last_seen': value.toUtc().toIso8601String(),
      }),
      flush: true,
    );
    await temp.rename('${directory.path}${Platform.pathSeparator}clock.json');
  }

  Future<void> _checkClock(OfflineLesson lesson) async {
    final now = _clock().toUtc();
    final clockFile = File(
      '${directory.path}${Platform.pathSeparator}clock.json',
    );
    DateTime? previous;
    if (await clockFile.exists()) {
      final data = jsonDecode(await clockFile.readAsString());
      if (data is! Map<String, dynamic> ||
          data['account_id'] != userId ||
          data['last_seen'] is! String ||
          DateTime.tryParse(data['last_seen'] as String) == null) {
        throw OfflineLessonException(Speech.t.downloadErrClockUnreadable);
      }
      previous = DateTime.parse(data['last_seen'] as String);
    }
    if (now.isBefore(
          lesson.authorizedAt.subtract(const Duration(minutes: 5)),
        ) ||
        (previous != null &&
            now.isBefore(previous.subtract(const Duration(minutes: 5))))) {
      throw OfflineLessonException(Speech.t.downloadErrClockBackwards);
    }
    if (!now.isBefore(lesson.expiresAt)) {
      throw OfflineLessonException(Speech.t.downloadErrExpired);
    }
    await _writeClock(
      previous != null && previous.isAfter(now) ? previous : now,
    );
  }

  Future<String> localPath(int id) => _exclusive(() async {
    final lesson = await _read(id);
    if (lesson == null || !lesson.complete) {
      throw OfflineLessonException(Speech.t.downloadErrIncompleteForPlayback);
    }
    if (lesson.revoked) {
      throw OfflineLessonException(Speech.t.downloadErrRenewalRequired);
    }
    await _checkClock(lesson);
    final media = _file(id, 'media');
    if (!await _intact(media, lesson)) {
      throw OfflineLessonException(Speech.t.downloadErrDamaged);
    }
    await credentials();
    return media.path;
  });

  Future<void> renew(int id) => _exclusive(() async {
    final existing = await _read(id);
    if (existing == null) {
      throw OfflineLessonException(Speech.t.downloadErrDownloadFirst);
    }
    final fresh = await _manifest(id);
    if (existing.digest != fresh.digest || existing.bytes != fresh.bytes) {
      await _write(existing, revoked: true);
      throw OfflineLessonException(Speech.t.downloadErrRecordingChangedRenew);
    }
    await _write(fresh, complete: existing.complete);
    await _writeClock(fresh.authorizedAt);
    ActivityTelemetry.record('download_renewed', audioId: id);
  });

  Future<void> download(
    int id,
    OfflineDownload operation,
  ) => _exclusive(() async {
    if (operation.cancelled) {
      throw OfflineLessonException(Speech.t.downloadErrCancelledAnyPartial);
    }
    final manifest = await _manifest(id);
    ActivityTelemetry.record('download_requested', audioId: id);
    final existing = await _read(id);
    if (existing != null &&
        (existing.digest != manifest.digest ||
            existing.bytes != manifest.bytes)) {
      throw OfflineLessonException(Speech.t.downloadErrRecordingChanged);
    }
    final media = _file(id, 'media');
    if (await _intact(media, manifest)) {
      await _write(manifest, complete: true);
      return;
    }
    if (await media.exists()) {
      throw OfflineLessonException(Speech.t.downloadErrSavedDamaged);
    }
    final used = await _reserved();
    if (used + (existing == null ? manifest.bytes : 0) > quota) {
      throw OfflineLessonException(Speech.t.downloadErrQuota);
    }
    await _write(manifest);
    final part = _file(id, 'part');
    var offset = await part.exists() ? await part.length() : 0;
    if (offset > manifest.bytes) {
      throw OfflineLessonException(Speech.t.downloadErrPartialInvalid);
    }
    if (offset == manifest.bytes) {
      if (!await _intact(part, manifest)) {
        throw OfflineLessonException(Speech.t.downloadErrIntegrityPartial);
      }
      await part.rename(media.path);
      await _write(manifest, complete: true);
      return;
    }
    final token = await credentials();
    if (token == null || token.isEmpty) {
      throw OfflineLessonException(Speech.t.downloadErrSignInToDownload);
    }
    final client = _clientFactory();
    operation._client = client;
    IOSink? sink;
    try {
      final request = http.Request('GET', apiBase.resolve('/audio/$id/stream'));
      request.followRedirects = false;
      request.headers['Authorization'] = 'Bearer $token';
      if (offset > 0) request.headers['Range'] = 'bytes=$offset-';
      final response = await client
          .send(request)
          .timeout(const Duration(seconds: 10));
      if (operation.cancelled) {
        throw OfflineLessonException(Speech.t.downloadErrCancelledExplicit);
      }
      if (response.statusCode == 401 ||
          response.statusCode == 403 ||
          response.statusCode == 404) {
        await _write(manifest, revoked: true);
        throw OfflineLessonException(Speech.t.downloadErrAccessDenied);
      }
      if (response.statusCode == 200) {
        offset = 0;
      } else if (response.statusCode == 206 && offset > 0) {
        if (response.headers['content-range'] !=
            'bytes $offset-${manifest.bytes - 1}/${manifest.bytes}') {
          throw OfflineLessonException(Speech.t.downloadErrUnexpectedPartial);
        }
      } else {
        throw OfflineLessonException(Speech.t.downloadErrCouldNotDownload);
      }
      if (response.contentLength != null &&
          response.contentLength != manifest.bytes - offset) {
        throw OfflineLessonException(Speech.t.downloadErrSizeChanged);
      }
      sink = part.openWrite(
        mode: offset > 0 ? FileMode.append : FileMode.write,
      );
      operation._progress(offset, manifest.bytes);
      var lastNotification = DateTime.now();
      await for (final chunk in response.stream.timeout(
        const Duration(seconds: 20),
      )) {
        if (operation.cancelled) {
          throw OfflineLessonException(Speech.t.downloadErrCancelledExplicit);
        }
        if (await credentials() != token) {
          throw OfflineLessonException(
            Speech.t.downloadErrAccountChangedStopped,
          );
        }
        offset += chunk.length;
        if (offset > manifest.bytes) {
          throw OfflineLessonException(Speech.t.downloadErrExceededSize);
        }
        sink.add(chunk);
        await sink.flush();
        if (DateTime.now().difference(lastNotification).inMilliseconds >= 250) {
          operation._progress(offset, manifest.bytes);
          lastNotification = DateTime.now();
        }
      }
      await sink.flush();
      await sink.close();
      sink = null;
      if (operation.cancelled) {
        throw OfflineLessonException(Speech.t.downloadErrCancelledExplicit);
      }
      if (!await _intact(part, manifest)) {
        throw OfflineLessonException(Speech.t.downloadErrIntegrity);
      }
      if (await credentials() != token) {
        throw OfflineLessonException(Speech.t.downloadErrSignInChangedStopped);
      }
      await part.rename(media.path);
      await _write(manifest, complete: true);
      operation._progress(manifest.bytes, manifest.bytes);
      ActivityTelemetry.record('download_completed', audioId: id);
    } on TimeoutException {
      ActivityTelemetry.record(
        'download_failed',
        audioId: id,
        details: {'reason_code': 'network'},
      );
      throw OfflineLessonException(Speech.t.downloadErrTimedOutPartial);
    } on http.ClientException {
      ActivityTelemetry.record(
        operation.cancelled ? 'download_cancelled' : 'download_failed',
        audioId: id,
        details: {'reason_code': operation.cancelled ? 'cancelled' : 'network'},
      );
      throw OfflineLessonException(
        operation.cancelled
            ? Speech.t.downloadErrCancelledRetry
            : Speech.t.downloadErrInterrupted,
      );
    } on SocketException {
      ActivityTelemetry.record(
        'download_failed',
        audioId: id,
        details: {'reason_code': 'network'},
      );
      throw OfflineLessonException(Speech.t.downloadErrInterrupted);
    } finally {
      if (sink != null) {
        await sink.flush();
        await sink.close();
      }
      operation._client = null;
      client.close();
    }
  });

  Future<void> remove(int id) => _exclusive(() async {
    // The caller must confirm this selected recording before invoking removal.
    for (final suffix in ['media', 'part', 'json.tmp', 'json']) {
      final file = _file(id, suffix);
      if (await file.exists()) await file.delete();
    }
    ActivityTelemetry.record('download_removed', audioId: id);
  });
}
