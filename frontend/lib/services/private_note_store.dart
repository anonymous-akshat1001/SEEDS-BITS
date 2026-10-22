import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrivateNoteException implements Exception {
  const PrivateNoteException(this.message);
  final String message;
  @override
  String toString() => message;
}

class PrivateNote {
  const PrivateNote({
    required this.id,
    required this.title,
    required this.complete,
    required this.duration,
    this.audioId,
    this.position,
    this.issue,
  });
  final String id;
  final String title;
  final bool complete;
  final Duration duration;
  final int? audioId;
  final Duration? position;
  final String? issue;
}

class PrivateNoteStore {
  PrivateNoteStore({
    required Directory root,
    required this.userId,
    required this.checkAccount,
  }) : directory = Directory(
         '${root.path}${Platform.pathSeparator}seeds_learning${Platform.pathSeparator}$userId${Platform.pathSeparator}notes',
       ) {
    if (userId <= 0) throw ArgumentError.value(userId, 'userId');
  }
  static const quota = 10000000;
  final Directory directory;
  final int userId;
  final Future<void> Function() checkAccount;
  static final _queues = <String, Future<void>>{};

  static Future<PrivateNoteStore> forCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    if (userId == null || userId <= 0) {
      throw const PrivateNoteException('Sign in before opening private notes.');
    }
    Future<void> check() async {
      if (prefs.getInt('user_id') != userId) {
        throw const PrivateNoteException(
          'Your account changed. Open private notes again.',
        );
      }
    }

    final root = await getApplicationSupportDirectory();
    await check();
    return PrivateNoteStore(root: root, userId: userId, checkAccount: check);
  }

  File _file(String id, String extension) {
    if (!RegExp(r'^[a-f0-9]{32}$').hasMatch(id)) {
      throw const PrivateNoteException('Invalid note identity.');
    }
    return File('${directory.path}${Platform.pathSeparator}$id.$extension');
  }

  Future<T> _exclusive<T>(Future<T> Function() action) {
    final key = directory.absolute.path;
    final result = (_queues[key] ?? Future<void>.value()).then((_) async {
      try {
        await checkAccount();
        return await action();
      } on FileSystemException catch (error) {
        debugPrint('[NOTES] Storage failed (${error.osError?.errorCode}).');
        throw const PrivateNoteException(
          'Private note storage is unavailable. Check free space and retry. Existing files are kept.',
        );
      }
    });
    final tail = result.then<void>(
      (_) {},
      onError: (Object error, StackTrace stack) {
        debugPrint('[NOTES] Operation failed (${error.runtimeType}).');
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

  Future<int> _used() async {
    if (!await directory.exists()) return 0;
    var bytes = 0;
    await for (final entry in directory.list(followLinks: false)) {
      if (entry is File && entry.path.endsWith('.m4a')) {
        bytes += await entry.length();
      }
    }
    return bytes;
  }

  Future<int> usedBytes() => _exclusive(_used);

  Future<void> _write(PrivateNote note) async {
    final temp = _file(note.id, 'json.tmp');
    await temp.writeAsString(
      jsonEncode({
        'version': 1,
        'account_id': userId,
        'id': note.id,
        'title': note.title,
        'complete': note.complete,
        'duration_ms': note.duration.inMilliseconds,
        'audio_id': note.audioId,
        'position_ms': note.position?.inMilliseconds,
      }),
      flush: true,
    );
    await temp.rename(_file(note.id, 'json').path);
  }

  Future<PrivateNote> _read(String id) async {
    try {
      final saved = _file(id, 'json');
      final source = await saved.exists() ? saved : _file(id, 'json.tmp');
      final data = jsonDecode(await source.readAsString());
      if (data is! Map<String, dynamic> ||
          data['version'] != 1 ||
          data['account_id'] != userId ||
          data['id'] != id ||
          data['title'] is! String ||
          (data['title'] as String).trim().isEmpty ||
          data['complete'] is! bool ||
          data['duration_ms'] is! int ||
          (data['duration_ms'] as int) < 0 ||
          (data['duration_ms'] as int) > 300000 ||
          (data['audio_id'] != null &&
              (data['audio_id'] is! int || (data['audio_id'] as int) <= 0)) ||
          (data['position_ms'] != null &&
              (data['position_ms'] is! int ||
                  (data['position_ms'] as int) < 0))) {
        throw const FormatException();
      }
      return PrivateNote(
        id: id,
        title: data['title'] as String,
        complete: data['complete'] as bool,
        duration: Duration(milliseconds: data['duration_ms'] as int),
        audioId: data['audio_id'] as int?,
        position: data['position_ms'] == null
            ? null
            : Duration(milliseconds: data['position_ms'] as int),
      );
    } on FormatException {
      debugPrint('[NOTES] Unreadable metadata for $id retained.');
      return PrivateNote(
        id: id,
        title: 'Unreadable note $id',
        complete: false,
        duration: Duration.zero,
        issue:
            'This note record cannot be read. Its files are kept; only explicit selected removal changes them.',
      );
    }
  }

  Future<List<PrivateNote>> list() => _exclusive(() async {
    if (!await directory.exists()) return [];
    final ids = <String>{};
    await for (final entry in directory.list(followLinks: false)) {
      final name = entry.uri.pathSegments.last;
      final match = RegExp(
        r'^([a-f0-9]{32})\.(json(?:\.tmp)?|m4a)$',
      ).firstMatch(name);
      if (entry is File && match != null) ids.add(match.group(1)!);
    }
    final notes = <PrivateNote>[];
    for (final id in ids) {
      if (!await _file(id, 'json').exists() &&
          !await _file(id, 'json.tmp').exists()) {
        notes.add(
          PrivateNote(
            id: id,
            title: 'Interrupted recording $id',
            complete: false,
            duration: Duration.zero,
            issue:
                'Recording metadata is missing. The file is retained for selected removal.',
          ),
        );
      } else {
        notes.add(await _read(id));
      }
    }
    return notes..sort((a, b) => a.title.compareTo(b.title));
  });

  Future<({PrivateNote note, String path, int allowance})> prepare({
    required String title,
    int? audioId,
    Duration? position,
  }) => _exclusive(() async {
    if (title.trim().isEmpty ||
        title.length > 160 ||
        (audioId != null && audioId <= 0) ||
        (position != null && position.isNegative)) {
      throw const PrivateNoteException(
        'Enter a note name of up to 160 characters and a valid lesson position.',
      );
    }
    final allowance = quota - await _used();
    if (allowance < 1024) {
      throw const PrivateNoteException(
        'Your private note allowance is full. Remove a chosen note before recording. No note was deleted.',
      );
    }
    await directory.create(recursive: true);
    final random = Random.secure();
    final id = List.generate(
      16,
      (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
    final note = PrivateNote(
      id: id,
      title: title.trim(),
      complete: false,
      duration: Duration.zero,
      audioId: audioId,
      position: position,
    );
    await _write(note);
    await checkAccount();
    return (note: note, path: _file(id, 'm4a').path, allowance: allowance);
  });

  Future<PrivateNote> finish(
    String id,
    Duration duration,
  ) => _exclusive(() async {
    final note = await _read(id);
    if (note.issue != null ||
        duration <= Duration.zero ||
        duration > const Duration(minutes: 5)) {
      throw const PrivateNoteException(
        'The note was interrupted or its duration is invalid. Its files are retained for selected removal.',
      );
    }
    final media = _file(id, 'm4a');
    if (!await media.exists() ||
        await media.length() == 0 ||
        await _used() > quota) {
      throw const PrivateNoteException(
        'This recording is empty or exceeds the private-note allowance. Its partial file is kept; review storage and remove the selected recording.',
      );
    }
    final saved = PrivateNote(
      id: id,
      title: note.title,
      complete: true,
      duration: duration,
      audioId: note.audioId,
      position: note.position,
    );
    await checkAccount();
    await _write(saved);
    return saved;
  });

  Future<String> localPath(String id) => _exclusive(() async {
    final note = await _read(id);
    final media = _file(id, 'm4a');
    if (!note.complete || !await media.exists() || await media.length() == 0) {
      throw const PrivateNoteException(
        'This note is incomplete or unavailable. It has not been deleted.',
      );
    }
    await checkAccount();
    return media.path;
  });

  Future<void> rename(String id, String title) => _exclusive(() async {
    if (title.trim().isEmpty || title.length > 160) {
      throw const PrivateNoteException(
        'Enter a note name of up to 160 characters.',
      );
    }
    final note = await _read(id);
    if (note.issue != null) throw PrivateNoteException(note.issue!);
    await _write(
      PrivateNote(
        id: id,
        title: title.trim(),
        complete: note.complete,
        duration: note.duration,
        audioId: note.audioId,
        position: note.position,
      ),
    );
  });

  Future<void> remove(String id) => _exclusive(() async {
    for (final extension in ['m4a', 'json', 'json.tmp']) {
      final file = _file(id, extension);
      if (await file.exists()) await file.delete();
    }
  });
}
