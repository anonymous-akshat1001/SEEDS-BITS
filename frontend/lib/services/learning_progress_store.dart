import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/speech.dart';

class LearningStorageException implements Exception {
  const LearningStorageException(this.message);
  final String message;
  @override
  String toString() => message;
}

class LessonBookmark {
  const LessonBookmark({
    required this.id,
    required this.label,
    required this.position,
  });

  final int id;
  final String label;
  final Duration position;

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'position_ms': position.inMilliseconds,
  };

  factory LessonBookmark.fromJson(Map<String, dynamic> data) => LessonBookmark(
    id: _integer(data['id'], Speech.t.learningFieldBookmarkId, minimum: 1),
    label: _text(data['label'], Speech.t.learningFieldBookmarkLabel),
    position: Duration(
      milliseconds: _integer(data['position_ms'], Speech.t.learningFieldBookmarkPosition),
    ),
  );
}

class LessonProgress {
  LessonProgress({
    required this.audioId,
    required this.title,
    required this.position,
    required this.updatedAt,
    this.duration,
    this.speed = 1,
    this.completed = false,
    List<LessonBookmark> bookmarks = const [],
    this.repeatStart,
    this.repeatEnd,
    this.nextBookmarkId = 1,
  }) : bookmarks = List.unmodifiable(bookmarks);

  final int audioId;
  final String title;
  final Duration position;
  final Duration? duration;
  final double speed;
  final bool completed;
  final DateTime updatedAt;
  final List<LessonBookmark> bookmarks;
  final Duration? repeatStart;
  final Duration? repeatEnd;
  final int nextBookmarkId;

  LessonProgress copyWith({
    String? title,
    Duration? position,
    Duration? duration,
    double? speed,
    bool? completed,
    DateTime? updatedAt,
    List<LessonBookmark>? bookmarks,
    Duration? repeatStart,
    Duration? repeatEnd,
    bool resetRepeat = false,
    int? nextBookmarkId,
  }) => LessonProgress(
    audioId: audioId,
    title: title ?? this.title,
    position: position ?? this.position,
    duration: duration ?? this.duration,
    speed: speed ?? this.speed,
    completed: completed ?? this.completed,
    updatedAt: updatedAt ?? this.updatedAt,
    bookmarks: bookmarks ?? this.bookmarks,
    repeatStart: resetRepeat ? repeatStart : repeatStart ?? this.repeatStart,
    repeatEnd: resetRepeat ? repeatEnd : repeatEnd ?? this.repeatEnd,
    nextBookmarkId: nextBookmarkId ?? this.nextBookmarkId,
  );

  Map<String, dynamic> toJson() => {
    'audio_id': audioId,
    'title': title,
    'position_ms': position.inMilliseconds,
    'duration_ms': duration?.inMilliseconds,
    'speed': speed,
    'completed': completed,
    'updated_at': updatedAt.toUtc().toIso8601String(),
    'bookmarks': bookmarks.map((bookmark) => bookmark.toJson()).toList(),
    'repeat_start_ms': repeatStart?.inMilliseconds,
    'repeat_end_ms': repeatEnd?.inMilliseconds,
    'next_bookmark_id': nextBookmarkId,
  };

  factory LessonProgress.fromJson(Map<String, dynamic> data) {
    final speed = data['speed'];
    final completed = data['completed'];
    final date = DateTime.tryParse(_text(data['updated_at'], Speech.t.learningFieldUpdateTime));
    final rawBookmarks = data['bookmarks'];
    if (speed is! num ||
        !speed.isFinite ||
        speed < 0.25 ||
        speed > 3 ||
        completed is! bool ||
        date == null ||
        rawBookmarks is! List) {
      throw LearningStorageException(
        Speech.t.learningSavedLessonInvalid,
      );
    }
    Duration? optionalDuration(String key) => data[key] == null
        ? null
        : Duration(milliseconds: _integer(data[key], key));
    final bookmarks = rawBookmarks.map((raw) {
      if (raw is! Map<String, dynamic>) {
        throw LearningStorageException(
          Speech.t.learningSavedBookmarkUnreadable,
        );
      }
      return LessonBookmark.fromJson(raw);
    }).toList();
    final nextId = _integer(
      data['next_bookmark_id'],
      Speech.t.learningFieldNextBookmarkId,
      minimum: 1,
    );
    final ids = bookmarks.map((bookmark) => bookmark.id).toSet();
    if (ids.length != bookmarks.length || ids.any((id) => id >= nextId)) {
      throw LearningStorageException(
        Speech.t.learningSavedBookmarkIdsInvalid,
      );
    }
    final result = LessonProgress(
      audioId: _integer(data['audio_id'], Speech.t.learningFieldLessonId, minimum: 1),
      title: _text(data['title'], Speech.t.learningFieldLessonTitle),
      position: Duration(
        milliseconds: _integer(data['position_ms'], Speech.t.learningFieldPosition),
      ),
      duration: optionalDuration('duration_ms'),
      speed: speed.toDouble(),
      completed: completed,
      updatedAt: date.toUtc(),
      bookmarks: bookmarks,
      repeatStart: optionalDuration('repeat_start_ms'),
      repeatEnd: optionalDuration('repeat_end_ms'),
      nextBookmarkId: nextId,
    );
    if (result.repeatEnd != null &&
        (result.repeatStart == null ||
            result.repeatEnd! <= result.repeatStart!)) {
      throw LearningStorageException(
        Speech.t.learningSavedRepeatInvalid,
      );
    }
    return result;
  }
}

int _integer(Object? value, String field, {int minimum = 0}) {
  if (value is! int || value < minimum) {
    throw LearningStorageException(
      Speech.t.learningSavedFieldUnreadable(field),
    );
  }
  return value;
}

String _text(Object? value, String field) {
  if (value is! String || value.trim().isEmpty) {
    throw LearningStorageException(
      Speech.t.learningSavedFieldUnreadable(field),
    );
  }
  return value;
}

class LearningProgressStore {
  LearningProgressStore({
    required Directory root,
    required this.userId,
    DateTime Function()? clock,
  }) : _directory = Directory(
         '${root.path}${Platform.pathSeparator}seeds_learning'
         '${Platform.pathSeparator}$userId',
       ),
       _clock = clock ?? DateTime.now {
    if (userId <= 0) throw ArgumentError.value(userId, 'userId');
  }

  final int userId;
  final Directory _directory;
  final DateTime Function() _clock;
  static final _queues = <String, Future<void>>{};
  File _file(int audioId) =>
      File('${_directory.path}${Platform.pathSeparator}lesson_$audioId.json');
  File _temporary(int audioId) => File('${_file(audioId).path}.tmp');

  static Future<LearningProgressStore> forCurrentUser() async {
    final preferences = await SharedPreferences.getInstance();
    final userId = preferences.getInt('user_id');
    if (userId == null || userId <= 0) {
      throw LearningStorageException(
        Speech.t.learningSignInFirst,
      );
    }
    final root = await getApplicationSupportDirectory();
    if (preferences.getInt('user_id') != userId) {
      throw LearningStorageException(
        Speech.t.learningAccountChanged,
      );
    }
    return LearningProgressStore(root: root, userId: userId);
  }

  Future<T> _serialize<T>(Future<T> Function() operation) {
    final key = _directory.absolute.path;
    final result = (_queues[key] ?? Future<void>.value()).then(
      (_) => operation(),
    );
    // The caller receives the failure; this tail only keeps later retries usable.
    final tail = result.then<void>(
      (_) {},
      onError: (Object error, StackTrace stack) {
        debugPrint(
          '[LEARNING] Storage operation failed (${error.runtimeType})',
        );
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

  Future<LessonProgress?> _read(int audioId) async {
    if (audioId <= 0) throw ArgumentError.value(audioId, 'audioId');
    try {
      await _checkDirectory();
      final file = _file(audioId);
      final temporary = _temporary(audioId);
      final recovering = !await file.exists() && await temporary.exists();
      final source = recovering ? temporary : file;
      if (!await source.exists()) return null;
      final decoded = jsonDecode(await source.readAsString());
      if (decoded is! Map<String, dynamic> ||
          decoded['version'] != 1 ||
          decoded['account_id'] != userId ||
          decoded['lesson'] is! Map<String, dynamic>) {
        throw LearningStorageException(
          Speech.t.learningUnsupportedFormat,
        );
      }
      final lesson = LessonProgress.fromJson(
        decoded['lesson'] as Map<String, dynamic>,
      );
      if (lesson.audioId != audioId) {
        throw LearningStorageException(
          Speech.t.learningIdentityMismatch,
        );
      }
      if (recovering) await temporary.rename(file.path);
      return lesson;
    } on FormatException {
      throw LearningStorageException(
        Speech.t.learningDataUnreadable,
      );
    } on FileSystemException {
      throw LearningStorageException(
        Speech.t.learningStorageUnavailableFreeSpace,
      );
    }
  }

  Future<void> _checkDirectory() async {
    final type = await FileSystemEntity.type(
      _directory.path,
      followLinks: false,
    );
    if (type != FileSystemEntityType.notFound &&
        type != FileSystemEntityType.directory) {
      throw LearningStorageException(
        Speech.t.learningStorageUnavailable,
      );
    }
  }

  Future<void> _write(LessonProgress lesson) async {
    try {
      await _directory.create(recursive: true);
      final temporary = _temporary(lesson.audioId);
      await temporary.writeAsString(
        jsonEncode({
          'version': 1,
          'account_id': userId,
          'lesson': lesson.toJson(),
        }),
        flush: true,
      );
      await temporary.rename(_file(lesson.audioId).path);
    } on FileSystemException {
      throw LearningStorageException(
        Speech.t.learningSaveFailed,
      );
    }
  }

  Future<LessonProgress?> lesson(int audioId) =>
      _serialize(() => _read(audioId));

  Future<List<LessonProgress>> recent() => _serialize(() async {
    try {
      await _checkDirectory();
      if (!await _directory.exists()) return const [];
      final ids = <int>{};
      final pattern = RegExp(r'^lesson_([1-9][0-9]*)\.json(?:\.tmp)?$');
      await for (final entry in _directory.list()) {
        if (entry is! File) continue;
        final match = pattern.firstMatch(entry.uri.pathSegments.last);
        if (match != null) ids.add(int.parse(match.group(1)!));
      }
      final lessons = <LessonProgress>[];
      for (final id in ids) {
        final lesson = await _read(id);
        if (lesson != null) lessons.add(lesson);
      }
      lessons.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return List.unmodifiable(lessons);
    } on FileSystemException {
      throw LearningStorageException(
        Speech.t.learningProgressUnavailable,
      );
    }
  });

  Future<LessonProgress> savePosition({
    required int audioId,
    required String title,
    required Duration position,
    required double speed,
    Duration? duration,
    bool completed = false,
  }) {
    if (audioId <= 0 ||
        title.trim().isEmpty ||
        position.isNegative ||
        !speed.isFinite ||
        speed < 0.25 ||
        speed > 3 ||
        duration?.isNegative == true) {
      throw ArgumentError(Speech.t.learningInvalidProgress);
    }
    return _serialize(() async {
      final previous = await _read(audioId);
      final effectiveDuration = duration ?? previous?.duration;
      final effectivePosition = completed
          ? Duration.zero
          : effectiveDuration != null && position > effectiveDuration
          ? effectiveDuration
          : position;
      final lesson =
          previous?.copyWith(
            title: title,
            position: effectivePosition,
            duration: effectiveDuration,
            speed: speed,
            completed: completed,
            updatedAt: _clock().toUtc(),
          ) ??
          LessonProgress(
            audioId: audioId,
            title: title,
            position: effectivePosition,
            duration: effectiveDuration,
            speed: speed,
            completed: completed,
            updatedAt: _clock().toUtc(),
          );
      await _write(lesson);
      return lesson;
    });
  }

  Future<LessonProgress> _change(
    int audioId,
    LessonProgress Function(LessonProgress) transform,
  ) => _serialize(() async {
    final existing = await _read(audioId);
    if (existing == null) {
      throw LearningStorageException(
        Speech.t.learningStartLessonFirst,
      );
    }
    final updated = transform(existing).copyWith(updatedAt: _clock().toUtc());
    await _write(updated);
    return updated;
  });

  Future<LessonProgress> addBookmark(
    int audioId,
    Duration position, {
    String? label,
  }) {
    if (position.isNegative || label?.trim().isEmpty == true) {
      throw ArgumentError(Speech.t.learningBookmarkNeedsPositionLabel);
    }
    return _change(audioId, (lesson) {
      if (lesson.duration != null && position > lesson.duration!) {
        throw ArgumentError(Speech.t.learningBookmarkExceedsDuration);
      }
      return lesson.copyWith(
        bookmarks: [
          ...lesson.bookmarks,
          LessonBookmark(
            id: lesson.nextBookmarkId,
            label: label?.trim() ?? Speech.t.learningDefaultBookmarkLabel('${lesson.nextBookmarkId}'),
            position: position,
          ),
        ],
        nextBookmarkId: lesson.nextBookmarkId + 1,
      );
    });
  }

  Future<LessonProgress> removeBookmark(int audioId, int bookmarkId) =>
      _change(audioId, (lesson) {
        if (!lesson.bookmarks.any((bookmark) => bookmark.id == bookmarkId)) {
          throw ArgumentError.value(
            bookmarkId,
            'bookmarkId',
            Speech.t.learningBookmarkNotFound,
          );
        }
        return lesson.copyWith(
          bookmarks: lesson.bookmarks
              .where((bookmark) => bookmark.id != bookmarkId)
              .toList(),
        );
      });

  Future<LessonProgress> setRepeat(
    int audioId,
    Duration? start,
    Duration? end,
  ) {
    if (start?.isNegative == true ||
        end?.isNegative == true ||
        (end != null && (start == null || end <= start))) {
      throw ArgumentError(Speech.t.learningRepeatEndAfterStart);
    }
    return _change(audioId, (lesson) {
      if (lesson.duration != null &&
          ((start != null && start > lesson.duration!) ||
              (end != null && end > lesson.duration!))) {
        throw ArgumentError(Speech.t.learningRepeatExceedsDuration);
      }
      return lesson.copyWith(
        repeatStart: start,
        repeatEnd: end,
        resetRepeat: true,
      );
    });
  }
}
