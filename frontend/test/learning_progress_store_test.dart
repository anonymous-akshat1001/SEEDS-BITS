import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/services/learning_progress_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

File _lessonFile(Directory root, int user, int audio) => File(
  '${root.path}${Platform.pathSeparator}seeds_learning'
  '${Platform.pathSeparator}$user${Platform.pathSeparator}lesson_$audio.json',
);

void main() {
  late Directory root;
  late LearningProgressStore store;
  var now = DateTime.utc(2026, 1, 1);

  setUp(() async {
    root = await Directory.systemTemp.createTemp('seeds-learning-test-');
    now = DateTime.utc(2026, 1, 1);
    store = LearningProgressStore(root: root, userId: 7, clock: () => now);
  });

  tearDown(() async => root.delete(recursive: true));

  Future<LessonProgress> save({
    int audio = 1,
    int seconds = 45,
    double speed = 1.25,
    bool completed = false,
  }) => store.savePosition(
    audioId: audio,
    title: 'English lesson',
    position: Duration(seconds: seconds),
    duration: const Duration(minutes: 3),
    speed: speed,
    completed: completed,
  );

  test('position, speed and title survive a fresh store instance', () async {
    await save();
    final reopened = LearningProgressStore(root: root, userId: 7);
    final lesson = (await reopened.lesson(1))!;
    expect(lesson.audioId, 1);
    expect(lesson.title, 'English lesson');
    expect(lesson.position, const Duration(seconds: 45));
    expect(lesson.duration, const Duration(minutes: 3));
    expect(lesson.speed, 1.25);
    expect(lesson.updatedAt, now);
    expect(lesson.completed, isFalse);
    final envelope = jsonDecode(await _lessonFile(root, 7, 1).readAsString());
    expect(envelope['version'], 1);
    expect(envelope['account_id'], 7);
    expect(envelope['lesson']['audio_id'], 1);
    expect(envelope.keys, isNot(contains('token')));
  });

  test(
    'accounts stay isolated and retain their own progress across logout',
    () async {
      SharedPreferences.setMockInitialValues({
        'user_id': 7,
        'token': 'test-token',
      });
      await save();
      final preferences = await SharedPreferences.getInstance();
      await preferences.clear();
      await preferences.setInt('user_id', 8);
      final other = LearningProgressStore(root: root, userId: 8);
      expect(await other.lesson(1), isNull);
      await other.savePosition(
        audioId: 1,
        title: 'Another lesson',
        position: const Duration(seconds: 12),
        speed: 1,
      );
      expect((await other.lesson(1))!.position, const Duration(seconds: 12));
      expect(
        (await LearningProgressStore(
          root: root,
          userId: 7,
        ).lesson(1))!.position,
        const Duration(seconds: 45),
      );
      expect(
        await _lessonFile(root, 7, 1).readAsString(),
        isNot(contains('test-token')),
      );
    },
  );

  test(
    'parallel instances merge bookmarks without losing position writes',
    () async {
      await save();
      final other = LearningProgressStore(root: root, userId: 7);
      await Future.wait([
        for (var i = 0; i < 20; i++)
          (i.isEven ? store : other).addBookmark(
            1,
            Duration(seconds: i),
            label: 'Point $i',
          ),
        save(seconds: 90, speed: 1.5),
      ]);
      final lesson = (await store.lesson(1))!;
      expect(lesson.position, const Duration(seconds: 90));
      expect(lesson.speed, 1.5);
      expect(lesson.bookmarks, hasLength(20));
      expect(
        lesson.bookmarks.map((bookmark) => bookmark.id),
        orderedEquals(List.generate(20, (i) => i + 1)),
      );
      expect(lesson.nextBookmarkId, 21);
    },
  );

  test('bookmark ids do not change or get reused after removal', () async {
    await save();
    await store.addBookmark(1, const Duration(seconds: 20));
    await store.addBookmark(1, const Duration(seconds: 30), label: 'Example');
    await store.removeBookmark(1, 1);
    final lesson = await store.addBookmark(1, const Duration(seconds: 40));
    expect(lesson.bookmarks.map((bookmark) => bookmark.id), [2, 3]);
    expect(lesson.bookmarks.map((bookmark) => bookmark.label), [
      'Example',
      'Bookmark 3',
    ]);
  });

  test(
    'completion resets resume position but retains bookmarks and speed',
    () async {
      await save();
      await store.addBookmark(1, const Duration(seconds: 25));
      final lesson = await save(seconds: 180, completed: true);
      expect(lesson.position, Duration.zero);
      expect(lesson.completed, isTrue);
      expect(lesson.bookmarks.single.position, const Duration(seconds: 25));
      expect(lesson.speed, 1.25);
    },
  );

  test(
    'repeat markers persist, validate their order and can be cleared',
    () async {
      await save();
      await store.setRepeat(1, const Duration(seconds: 10), null);
      await store.setRepeat(
        1,
        const Duration(seconds: 10),
        const Duration(seconds: 20),
      );
      final restored = (await LearningProgressStore(
        root: root,
        userId: 7,
      ).lesson(1))!;
      expect(restored.repeatStart, const Duration(seconds: 10));
      expect(restored.repeatEnd, const Duration(seconds: 20));
      expect(
        () => store.setRepeat(
          1,
          const Duration(seconds: 20),
          const Duration(seconds: 20),
        ),
        throwsArgumentError,
      );
      expect(
        () => store.setRepeat(1, null, const Duration(seconds: 20)),
        throwsArgumentError,
      );
      await expectLater(
        store.setRepeat(1, const Duration(seconds: 200), null),
        throwsArgumentError,
      );
      final cleared = await store.setRepeat(1, null, null);
      expect(cleared.repeatStart, isNull);
      expect(cleared.repeatEnd, isNull);
    },
  );

  test(
    'a changed lesson cannot restore a position beyond its duration',
    () async {
      await save(seconds: 150);
      final lesson = await store.savePosition(
        audioId: 1,
        title: 'English lesson',
        position: const Duration(seconds: 150),
        duration: const Duration(seconds: 100),
        speed: 1,
      );
      expect(lesson.position, const Duration(seconds: 100));
    },
  );

  test(
    'updates touch only their lesson file and most recent order is stable',
    () async {
      await save();
      final first = await _lessonFile(root, 7, 1).readAsString();
      now = now.add(const Duration(seconds: 10));
      await save(audio: 2, seconds: 20);
      expect(await _lessonFile(root, 7, 1).readAsString(), first);
      expect((await store.recent()).map((lesson) => lesson.audioId), [2, 1]);
    },
  );

  test(
    'corrupt data is reported and never overwritten with an empty default',
    () async {
      await save();
      await save(audio: 2);
      final file = _lessonFile(root, 7, 1);
      await file.writeAsString('{broken');
      await expectLater(
        store.lesson(1),
        throwsA(isA<LearningStorageException>()),
      );
      await expectLater(save(), throwsA(isA<LearningStorageException>()));
      expect(await file.readAsString(), '{broken');
      expect((await store.lesson(2))!.audioId, 2);
      await save(audio: 2, seconds: 60);
      expect((await store.lesson(2))!.position, const Duration(seconds: 60));
    },
  );

  test(
    'foreign-account data is not exposed even if copied into this account',
    () async {
      await save();
      final foreign = _lessonFile(root, 8, 1);
      await foreign.parent.create(recursive: true);
      await _lessonFile(root, 7, 1).copy(foreign.path);
      final other = LearningProgressStore(root: root, userId: 8);
      await expectLater(
        other.lesson(1),
        throwsA(isA<LearningStorageException>()),
      );
    },
  );

  test(
    'a fully written interrupted first save is recovered atomically',
    () async {
      await save();
      final file = _lessonFile(root, 7, 1);
      final temporary = await file.rename('${file.path}.tmp');
      expect(await file.exists(), isFalse);
      expect((await store.lesson(1))!.position, const Duration(seconds: 45));
      expect(await file.exists(), isTrue);
      expect(await temporary.exists(), isFalse);
    },
  );

  test('a partial interrupted save is not treated as valid progress', () async {
    final temporary = File('${_lessonFile(root, 7, 1).path}.tmp');
    await temporary.parent.create(recursive: true);
    await temporary.writeAsString('{partial');
    await expectLater(
      store.lesson(1),
      throwsA(isA<LearningStorageException>()),
    );
    expect(await temporary.readAsString(), '{partial');
    expect(await _lessonFile(root, 7, 1).exists(), isFalse);
  });

  test(
    'storage failure is explicit and the queue accepts a later retry',
    () async {
      final directory = _lessonFile(root, 7, 1).parent;
      await directory.parent.create(recursive: true);
      final blocker = await File(directory.path).writeAsString('blocked');
      await expectLater(save(), throwsA(isA<LearningStorageException>()));
      await expectLater(
        store.lesson(1),
        throwsA(isA<LearningStorageException>()),
      );
      await blocker.delete();
      await save();
      expect((await store.lesson(1))!.position, const Duration(seconds: 45));
    },
  );

  test(
    'invalid positions, speed, account and bookmark inputs are rejected',
    () async {
      expect(
        () => LearningProgressStore(root: root, userId: 0),
        throwsArgumentError,
      );
      expect(() => save(speed: double.nan), throwsArgumentError);
      expect(() => save(seconds: -1), throwsArgumentError);
      await save();
      expect(
        () => store.addBookmark(1, Duration.zero, label: ' '),
        throwsArgumentError,
      );
      await expectLater(
        store.addBookmark(1, const Duration(seconds: 200)),
        throwsArgumentError,
      );
      await expectLater(store.removeBookmark(1, 99), throwsArgumentError);
      await expectLater(
        store.addBookmark(99, Duration.zero),
        throwsA(isA<LearningStorageException>()),
      );
    },
  );

  test(
    'schema and field corruption cannot be normalized into success',
    () async {
      await save();
      final file = _lessonFile(root, 7, 1);
      final original = await file.readAsString();
      for (final field in [
        'version',
        'speed',
        'position_ms',
        'next_bookmark_id',
      ]) {
        final envelope = jsonDecode(original) as Map<String, dynamic>;
        if (field == 'version') {
          envelope[field] = 99;
        } else {
          (envelope['lesson'] as Map<String, dynamic>)[field] = 'invalid';
        }
        await file.writeAsString(jsonEncode(envelope));
        await expectLater(
          store.lesson(1),
          throwsA(isA<LearningStorageException>()),
        );
      }
    },
  );
}
