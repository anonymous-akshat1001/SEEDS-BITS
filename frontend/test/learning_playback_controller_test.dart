import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/services/learning_playback_controller.dart';
import 'package:frontend/services/learning_progress_store.dart';

class _MemoryStore extends LearningProgressStore {
  _MemoryStore() : super(root: Directory.systemTemp, userId: 7);
  final records = <int, LessonProgress>{};
  int writes = 0;
  int bookmarkWrites = 0;
  bool fail = false;
  Completer<void>? saveGate;
  final readGates = <int, Completer<void>>{};

  @override
  Future<LessonProgress?> lesson(int audioId) async {
    await readGates[audioId]?.future;
    if (fail) throw const LearningStorageException('Storage unavailable.');
    return records[audioId];
  }

  @override
  Future<LessonProgress> savePosition({
    required int audioId,
    required String title,
    required Duration position,
    required double speed,
    Duration? duration,
    bool completed = false,
  }) async {
    writes++;
    await saveGate?.future;
    if (fail) throw const LearningStorageException('Storage unavailable.');
    return records[audioId] =
        (records[audioId] ??
                LessonProgress(
                  audioId: audioId,
                  title: title,
                  position: position,
                  updatedAt: DateTime.utc(2026),
                ))
            .copyWith(
              position: position,
              speed: speed,
              duration: duration,
              completed: completed,
            );
  }

  @override
  Future<LessonProgress> addBookmark(
    int audioId,
    Duration position, {
    String? label,
  }) async {
    bookmarkWrites++;
    final old = records[audioId]!;
    return records[audioId] = old.copyWith(
      bookmarks: [
        ...old.bookmarks,
        LessonBookmark(
          id: old.nextBookmarkId,
          label: label ?? 'Bookmark ${old.nextBookmarkId}',
          position: position,
        ),
      ],
      nextBookmarkId: old.nextBookmarkId + 1,
    );
  }

  @override
  Future<LessonProgress> removeBookmark(int audioId, int bookmarkId) async {
    final old = records[audioId]!;
    return records[audioId] = old.copyWith(
      bookmarks: old.bookmarks
          .where((bookmark) => bookmark.id != bookmarkId)
          .toList(),
    );
  }

  @override
  Future<LessonProgress> setRepeat(
    int audioId,
    Duration? start,
    Duration? end,
  ) async {
    if (end != null && (start == null || end <= start)) {
      throw ArgumentError('End must follow start.');
    }
    return records[audioId] = records[audioId]!.copyWith(
      repeatStart: start,
      repeatEnd: end,
      resetRepeat: true,
    );
  }
}

void main() {
  late _MemoryStore store;
  late LearningPlaybackController controller;
  late List<Duration> seeks;
  late List<double> speeds;
  late List<String> issues;
  late int resumes;
  Completer<void>? seekGate;

  setUp(() {
    store = _MemoryStore();
    seeks = [];
    speeds = [];
    issues = [];
    resumes = 0;
    seekGate = null;
    controller = LearningPlaybackController(
      openStore: () async => store,
      seek: (position) async {
        seeks.add(position);
        await seekGate?.future;
      },
      setSpeed: (speed) async => speeds.add(speed),
      resume: () async => resumes++,
      isPlaying: () => true,
      onIssue: issues.add,
    );
  });

  tearDown(() => controller.dispose());

  Future<void> start(WidgetTester tester, {int id = 1}) async {
    expect(await controller.prepare(id, 'Lesson $id'), isTrue);
    controller.activate();
    await tester.pump();
  }

  testWidgets(
    'restores position and speed without automatically enabling saved repeat',
    (tester) async {
      await store.savePosition(
        audioId: 1,
        title: 'Lesson',
        position: const Duration(seconds: 25),
        speed: 1.5,
      );
      await store.setRepeat(
        1,
        const Duration(seconds: 5),
        const Duration(seconds: 15),
      );
      await start(tester);
      expect(controller.position, const Duration(seconds: 25));
      expect(controller.speed, 1.5);
      expect(controller.hasRepeatRegion, isTrue);
      expect(controller.repeatEnabled, isFalse);
      expect(seeks, isEmpty);
    },
  );

  testWidgets(
    'continuous positions checkpoint every five seconds, not endlessly debounce',
    (tester) async {
      await start(tester);
      final initial = store.writes;
      for (var second = 1; second <= 5; second++) {
        controller.updatePosition(Duration(seconds: second));
        await tester.pump(const Duration(seconds: 1));
      }
      expect(store.writes, initial + 1);
      expect(store.records[1]!.position, const Duration(seconds: 5));
      controller.updatePosition(const Duration(seconds: 6));
      await tester.pump(const Duration(seconds: 5));
      expect(store.writes, initial + 2);
    },
  );

  testWidgets('flush captures pause and dispose captures last position', (
    tester,
  ) async {
    await start(tester);
    controller.updatePosition(const Duration(seconds: 17));
    expect(await controller.flush(), isTrue);
    expect(store.records[1]!.position.inSeconds, 17);
    controller.updatePosition(const Duration(seconds: 19));
    controller.dispose();
    await tester.pump();
    expect(store.records[1]!.position.inSeconds, 19);
    // Replace the disposed instance so tearDown has exactly one live owner.
    controller = LearningPlaybackController(
      seek: (_) async {},
      setSpeed: (_) async {},
      resume: () async {},
      isPlaying: () => false,
      onIssue: issues.add,
      openStore: () async => store,
    );
  });

  testWidgets('completion survives later position events and disposal saves', (
    tester,
  ) async {
    await start(tester);
    controller.updatePosition(const Duration(seconds: 90));
    expect(await controller.handleCompletion(), isFalse);
    expect(store.records[1]!.completed, isTrue);
    controller.updatePosition(const Duration(seconds: 90));
    expect(await controller.flush(), isFalse);
    expect(store.records[1]!.completed, isTrue);
    expect(store.records[1]!.position, Duration.zero);
    expect(controller.ready, isFalse);
  });

  testWidgets(
    'storage failure reports once, stops automatic writes, and explicitly recovers',
    (tester) async {
      await start(tester);
      store.fail = true;
      controller.updatePosition(const Duration(seconds: 10));
      await tester.pump(const Duration(seconds: 5));
      final failedCount = store.writes;
      expect(issues, ['Storage unavailable.']);
      for (var i = 0; i < 4; i++) {
        controller.updatePosition(Duration(seconds: 11 + i));
        await tester.pump(const Duration(seconds: 5));
      }
      expect(store.writes, failedCount);
      store.fail = false;
      await controller.retrySaving();
      expect(controller.issue, isNull);
      expect(store.records[1]!.position.inSeconds, 14);
    },
  );

  testWidgets(
    'explicit read-only recovery does not overwrite unreadable progress',
    (tester) async {
      store.fail = true;
      await expectLater(
        controller.prepare(1, 'Lesson'),
        throwsA(isA<LearningStorageException>()),
      );
      expect(
        await controller.prepare(1, 'Lesson', withoutSavedProgress: true),
        isTrue,
      );
      controller.activate();
      controller.updatePosition(const Duration(seconds: 20));
      await tester.pump(const Duration(seconds: 10));
      expect(store.writes, 0);
      expect(controller.canSave, isFalse);
      await expectLater(
        controller.addBookmark(),
        throwsA(isA<LearningStorageException>()),
      );
      store.fail = false;
      await controller.retrySaving();
      expect(controller.canSave, isTrue);
      expect(store.records[1]!.position.inSeconds, 20);
    },
  );

  testWidgets('a stale preparation cannot replace the newer selection', (
    tester,
  ) async {
    final gate = store.readGates[1] = Completer<void>();
    final old = controller.prepare(1, 'Old');
    await tester.pump();
    expect(await controller.prepare(2, 'New'), isTrue);
    gate.complete();
    expect(await old, isFalse);
    expect(controller.lesson!.audioId, 2);
  });

  testWidgets('aborting invalidates a pending restore', (tester) async {
    final gate = store.readGates[1] = Completer<void>();
    final pending = controller.prepare(1, 'Old');
    await tester.pump();
    controller.abort();
    gate.complete();
    expect(await pending, isFalse);
    expect(controller.lesson, isNull);
    expect(controller.ready, isFalse);
  });

  testWidgets(
    'bookmark action waiting on a save cannot cross lesson selection',
    (tester) async {
      await start(tester);
      controller.updatePosition(const Duration(seconds: 12));
      final gate = store.saveGate = Completer<void>();
      final bookmark = controller.addBookmark(label: 'Old lesson point');
      await tester.pump();
      final next = controller.prepare(2, 'Next lesson');
      gate.complete();
      await bookmark;
      await next;
      expect(controller.lesson!.audioId, 2);
      expect(store.bookmarkWrites, 0);
      expect(store.records[1]!.bookmarks, isEmpty);
    },
  );

  testWidgets(
    'bookmarks preserve position and can be removed without deleting progress',
    (tester) async {
      await start(tester);
      controller.updatePosition(const Duration(seconds: 25));
      await controller.addBookmark(label: 'Definition');
      expect(controller.lesson!.bookmarks.single.label, 'Definition');
      expect(controller.lesson!.bookmarks.single.position.inSeconds, 25);
      await controller.removeBookmark(1);
      expect(controller.lesson!.bookmarks, isEmpty);
      expect(store.records[1]!.position.inSeconds, 25);
    },
  );

  Future<void> repeatRegion(WidgetTester tester) async {
    await start(tester);
    controller.updateDuration(const Duration(seconds: 30));
    controller.updatePosition(const Duration(seconds: 5));
    await controller.markRepeatStart();
    controller.updatePosition(const Duration(seconds: 30));
    await controller.markRepeatEnd();
    controller.toggleRepeat();
  }

  testWidgets(
    'A-B rejects reversed bounds and looping requires an explicit action',
    (tester) async {
      await start(tester);
      await expectLater(
        Future.sync(controller.toggleRepeat),
        throwsArgumentError,
      );
      controller.updatePosition(const Duration(seconds: 10));
      await controller.markRepeatStart();
      controller.updatePosition(const Duration(seconds: 5));
      await expectLater(controller.markRepeatEnd(), throwsArgumentError);
      expect(controller.repeatEnabled, isFalse);
    },
  );

  testWidgets(
    'endpoint position and completion share one loop seek and resume',
    (tester) async {
      await repeatRegion(tester);
      final gate = seekGate = Completer<void>();
      controller.updatePosition(const Duration(seconds: 30));
      final completion = controller.handleCompletion();
      await tester.pump();
      expect(seeks, [const Duration(seconds: 5)]);
      gate.complete();
      expect(await completion, isTrue);
      expect(resumes, 1);
      expect(store.records[1]!.completed, isFalse);
      expect(controller.position.inSeconds, 5);
      await controller.flush();
    },
  );

  testWidgets('stale completion cannot finalize the newly selected lesson', (
    tester,
  ) async {
    await repeatRegion(tester);
    final gate = seekGate = Completer<void>();
    final oldCompletion = controller.handleCompletion();
    await tester.pump();
    await controller.prepare(2, 'Next');
    controller.activate();
    await tester.pump();
    gate.complete();
    expect(await oldCompletion, isFalse);
    expect(controller.lesson!.audioId, 2);
    expect(controller.ready, isTrue);
    expect(store.records[2]!.completed, isFalse);
    expect(resumes, 0);
  });

  testWidgets(
    'seeking outside A-B disables looping and speed changes persist',
    (tester) async {
      await repeatRegion(tester);
      await controller.moveTo(const Duration(seconds: 2));
      expect(controller.repeatEnabled, isFalse);
      expect(seeks.last.inSeconds, 2);
      await controller.changeSpeed(1.75);
      expect(speeds, [1.75]);
      expect(store.records[1]!.speed, 1.75);
      await expectLater(
        controller.moveTo(const Duration(seconds: 31)),
        throwsArgumentError,
      );
      await expectLater(
        controller.changeSpeed(double.nan),
        throwsArgumentError,
      );
    },
  );

  testWidgets(
    'shortened duration disables an unusable repeat without deleting saved points',
    (tester) async {
      await repeatRegion(tester);
      controller.updateDuration(const Duration(seconds: 20));
      expect(controller.hasRepeatRegion, isFalse);
      expect(controller.repeatEnabled, isFalse);
      expect(controller.lesson!.repeatEnd!.inSeconds, 30);
    },
  );
}
