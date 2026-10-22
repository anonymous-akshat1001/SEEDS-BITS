import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_service.dart';

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
      throw const OfflineLessonException(
        'Download information is invalid or belongs to a different account. Existing files are kept.',
      );
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
        throw const OfflineLessonException(
          'Sign in before opening downloaded lessons.',
        );
      }
      final root = await getApplicationSupportDirectory();
      if (preferences.getInt('user_id') != id) {
        throw const OfflineLessonException(
          'Your account changed. Open Downloads again.',
        );
      }
      return OfflineLessonStore(
        root: root,
        userId: id,
        apiBase: Uri.parse(ApiService.baseUrl),
        credentials: () async {
          if (preferences.getInt('user_id') != id) {
            throw const OfflineLessonException(
              'Your account changed. Open Downloads again.',
            );
          }
          return preferences.getString('token');
        },
      );
    } on MissingPlatformDirectoryException {
      throw const OfflineLessonException(
        'Download storage is unavailable on this device.',
      );
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
        throw const OfflineLessonException(
          'Download storage is unavailable. Check free space and retry. Existing files have not been intentionally removed.',
        );
      } on FormatException {
        throw const OfflineLessonException(
          'Download records could not be read. Existing files are kept.',
        );
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
      throw const OfflineLessonException(
        'A download record could not be read. Existing files are kept.',
      );
    }
    final lesson = OfflineLesson.parse(data, userId);
    if (lesson.audioId != id) {
      throw const OfflineLessonException(
        'Download identity does not match its record.',
      );
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
      throw const OfflineLessonException(
        'Sign in online before renewing download access.',
      );
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
        throw const OfflineLessonException(
          'Your sign-in changed. Open Downloads again.',
        );
      }
      if (response.statusCode == 401 ||
          response.statusCode == 403 ||
          response.statusCode == 404) {
        final existing = await _read(id);
        if (existing != null) await _write(existing, revoked: true);
        throw const OfflineLessonException(
          'Recording access is no longer confirmed for this account. Reconnect and sign in to renew. The saved file is kept.',
        );
      }
      if (response.statusCode == 413) {
        throw const OfflineLessonException(
          'This recording is larger than the 50 MB download limit.',
        );
      }
      if (response.statusCode != 200) {
        throw const OfflineLessonException(
          'The server could not renew this recording. Try again later.',
        );
      }
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const OfflineLessonException(
          'The server returned invalid download information.',
        );
      }
      final manifest = OfflineLesson.parse(decoded, userId);
      if (manifest.audioId != id) {
        throw const OfflineLessonException(
          'The server returned a different recording.',
        );
      }
      return manifest;
    } on TimeoutException {
      throw const OfflineLessonException(
        'The connection timed out. Reconnect and retry.',
        mayUseExistingAccess: true,
      );
    } on http.ClientException {
      throw const OfflineLessonException(
        'Could not connect to renew this recording. Check your internet connection.',
        mayUseExistingAccess: true,
      );
    } on SocketException {
      throw const OfflineLessonException(
        'Could not connect to renew this recording. Check your internet connection.',
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
        throw const OfflineLessonException(
          'The offline time record could not be read. Connect and renew access.',
        );
      }
      previous = DateTime.parse(data['last_seen'] as String);
    }
    if (now.isBefore(
          lesson.authorizedAt.subtract(const Duration(minutes: 5)),
        ) ||
        (previous != null &&
            now.isBefore(previous.subtract(const Duration(minutes: 5))))) {
      throw const OfflineLessonException(
        'The phone clock moved backwards. Correct its date and reconnect to renew access.',
      );
    }
    if (!now.isBefore(lesson.expiresAt)) {
      throw const OfflineLessonException(
        'Offline access expired after 30 days. Connect to the internet and renew this lesson. Your progress and downloaded file are kept.',
      );
    }
    await _writeClock(
      previous != null && previous.isAfter(now) ? previous : now,
    );
  }

  Future<String> localPath(int id) => _exclusive(() async {
    final lesson = await _read(id);
    if (lesson == null || !lesson.complete) {
      throw const OfflineLessonException(
        'Download this lesson completely before offline playback.',
      );
    }
    if (lesson.revoked) {
      throw const OfflineLessonException(
        'Access renewal is required. Connect and renew before playing this download.',
      );
    }
    await _checkClock(lesson);
    final media = _file(id, 'media');
    if (!await _intact(media, lesson)) {
      throw const OfflineLessonException(
        'The downloaded recording is incomplete or damaged. Remove this download and download it again. Progress and bookmarks are separate.',
      );
    }
    await credentials();
    return media.path;
  });

  Future<void> renew(int id) => _exclusive(() async {
    final existing = await _read(id);
    if (existing == null) {
      throw const OfflineLessonException('Download this lesson first.');
    }
    final fresh = await _manifest(id);
    if (existing.digest != fresh.digest || existing.bytes != fresh.bytes) {
      await _write(existing, revoked: true);
      throw const OfflineLessonException(
        'This recording has changed. Remove its download and download the current recording. Progress and bookmarks are kept.',
      );
    }
    await _write(fresh, complete: existing.complete);
    await _writeClock(fresh.authorizedAt);
  });

  Future<void> download(
    int id,
    OfflineDownload operation,
  ) => _exclusive(() async {
    if (operation.cancelled) {
      throw const OfflineLessonException(
        'Download cancelled. Any partial file is kept for an explicit retry.',
      );
    }
    final manifest = await _manifest(id);
    final existing = await _read(id);
    if (existing != null &&
        (existing.digest != manifest.digest ||
            existing.bytes != manifest.bytes)) {
      throw const OfflineLessonException(
        'The recording changed. Remove its old download before downloading the current version. Progress is kept.',
      );
    }
    final media = _file(id, 'media');
    if (await _intact(media, manifest)) {
      await _write(manifest, complete: true);
      return;
    }
    if (await media.exists()) {
      throw const OfflineLessonException(
        'The saved recording is damaged. Remove its download before retrying.',
      );
    }
    final used = await _reserved();
    if (used + (existing == null ? manifest.bytes : 0) > quota) {
      throw const OfflineLessonException(
        'Your account has reached its 50 MB download limit. Choose which of your downloads to remove, then retry. Nothing was deleted.',
      );
    }
    await _write(manifest);
    final part = _file(id, 'part');
    var offset = await part.exists() ? await part.length() : 0;
    if (offset > manifest.bytes) {
      throw const OfflineLessonException(
        'The partial download is invalid. Remove it before retrying.',
      );
    }
    if (offset == manifest.bytes) {
      if (!await _intact(part, manifest)) {
        throw const OfflineLessonException(
          'Download integrity check failed. Remove this partial download before retrying.',
        );
      }
      await part.rename(media.path);
      await _write(manifest, complete: true);
      return;
    }
    final token = await credentials();
    if (token == null || token.isEmpty) {
      throw const OfflineLessonException('Sign in before downloading.');
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
        throw const OfflineLessonException(
          'Download cancelled. Partial data is kept for an explicit retry.',
        );
      }
      if (response.statusCode == 401 ||
          response.statusCode == 403 ||
          response.statusCode == 404) {
        await _write(manifest, revoked: true);
        throw const OfflineLessonException(
          'Download access was denied. Reconnect and renew access.',
        );
      }
      if (response.statusCode == 200) {
        offset = 0;
      } else if (response.statusCode == 206 && offset > 0) {
        if (response.headers['content-range'] !=
            'bytes $offset-${manifest.bytes - 1}/${manifest.bytes}') {
          throw const OfflineLessonException(
            'The server returned an unexpected partial recording. Retry without deleting existing data.',
          );
        }
      } else {
        throw const OfflineLessonException(
          'The recording could not be downloaded. Check your connection and retry.',
        );
      }
      if (response.contentLength != null &&
          response.contentLength != manifest.bytes - offset) {
        throw const OfflineLessonException(
          'The recording size changed. Retry downloading.',
        );
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
          throw const OfflineLessonException(
            'Download cancelled. Partial data is kept for an explicit retry.',
          );
        }
        if (await credentials() != token) {
          throw const OfflineLessonException(
            'Your account changed. The download was stopped.',
          );
        }
        offset += chunk.length;
        if (offset > manifest.bytes) {
          throw const OfflineLessonException(
            'The recording exceeded its declared size. Download stopped.',
          );
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
        throw const OfflineLessonException(
          'Download cancelled. Partial data is kept for an explicit retry.',
        );
      }
      if (!await _intact(part, manifest)) {
        throw const OfflineLessonException(
          'Download integrity check failed. Retry an incomplete download, or remove damaged partial data before retrying.',
        );
      }
      if (await credentials() != token) {
        throw const OfflineLessonException(
          'Your sign-in changed. Download stopped before installation.',
        );
      }
      await part.rename(media.path);
      await _write(manifest, complete: true);
      operation._progress(manifest.bytes, manifest.bytes);
    } on TimeoutException {
      throw const OfflineLessonException(
        'Download timed out. Partial data is kept; activate Download to retry.',
      );
    } on http.ClientException {
      throw OfflineLessonException(
        operation.cancelled
            ? 'Download cancelled. Partial data is kept for retry.'
            : 'Download interrupted. Partial data is kept; activate Download to retry.',
      );
    } on SocketException {
      throw const OfflineLessonException(
        'Download interrupted. Partial data is kept; activate Download to retry.',
      );
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
  });
}
