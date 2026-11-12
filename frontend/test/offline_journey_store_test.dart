import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/services/journey_api.dart';
import 'package:frontend/services/journey_engine.dart';
import 'package:frontend/services/journey_models.dart';
import 'package:frontend/services/offline_journey_store.dart';
import 'package:frontend/services/offline_lesson_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeMedia implements JourneyMediaStore {
  final complete = <int>{};
  final removed = <int>[];
  int? failOn;

  @override
  Future<Set<int>> completeIds() async => {...complete};
  @override
  Future<void> download(int audioId, OfflineDownload operation) async {
    if (audioId == failOn) {
      throw const OfflineLessonException('Your account has reached its 50 MB download limit.');
    }
    complete.add(audioId);
  }

  @override
  Future<String> localPath(int audioId) async => '/media/$audioId';
  @override
  Future<void> remove(int audioId) async {
    removed.add(audioId);
    complete.remove(audioId);
  }
}

class FakeApi extends JourneyApi {
  FakeApi();
  final sent = <List<Map<String, dynamic>>>[];
  bool offline = false;
  Set<String> reject = {};

  @override
  Future<({List<String> accepted, List<String> rejected})> sync(
    List<Map<String, dynamic>> runs,
  ) async {
    if (offline) {
      throw const JourneyApiException('No connection', network: true);
    }
    sent.add(runs);
    final ids = runs.map((run) => run['run_id'] as String).toList();
    return (
      accepted: ids.where((id) => !reject.contains(id)).toList(),
      rejected: ids.where(reject.contains).toList(),
    );
  }
}

JourneySnapshot journey(int id, List<int> audio) => JourneySnapshot.parse({
  'journey_id': id,
  'revision': 1,
  'title': 'Journey $id',
  'steps': [
    for (final audioId in audio)
      {'kind': 'audio', 'audio_id': audioId, 'title': 'Recording $audioId'},
    {
      'kind': 'question',
      'text': 'Q',
      'options': ['A', 'B'],
      'correct_index': 0,
    },
  ],
});

void main() {
  late Directory root;
  late FakeMedia media;
  late OfflineJourneyStore store;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('journeys');
    media = FakeMedia();
    store = OfflineJourneyStore(root: root, userId: 5, media: media);
  });

  tearDown(() => root.delete(recursive: true));

  test('answered progress is queued, synced once and kept when offline', () async {
    final api = FakeApi()..offline = true;
    final engine = JourneyEngine(journey(1, [10]))..next();
    await store.saveProgress(engine);
    expect(await store.pendingCount(), 0, reason: 'nothing answered yet');
    engine.answer(0);
    await store.saveProgress(engine, offline: true);
    expect(await store.pendingCount(), 1);

    final offline = await store.syncPending(api);
    expect(offline.offline, isTrue);
    expect(offline.remaining, 1);

    api.offline = false;
    final report = await store.syncPending(api);
    expect(report.sent, 1);
    expect(report.remaining, 0);
    expect(api.sent.single.single['played_offline'], isTrue);
    expect(await store.loadProgress(1), isNotNull);
    await store.clearProgress(1);
    expect(await store.loadProgress(1), isNull);
  });

  test('rejected runs leave the queue instead of retrying forever', () async {
    final engine = JourneyEngine(journey(1, [10]))..next();
    engine.answer(1);
    await store.saveProgress(engine);
    final api = FakeApi()..reject = {engine.runId};
    final report = await store.syncPending(api);
    expect((report.sent, report.rejected, report.remaining), (0, 1, 0));
  });

  test('download is complete only when every recording is saved', () async {
    media.failOn = 12;
    final snapshot = journey(2, [11, 12]);
    final progress = <String>[];
    await expectLater(
      store.download(snapshot, onProgress: (d, t) => progress.add('$d/$t')),
      throwsA(
        isA<OfflineJourneyException>().having(
          (e) => e.message,
          'message',
          contains('1 of 2 recordings are saved'),
        ),
      ),
    );
    expect(await store.isDownloaded(snapshot), isFalse);
    media.failOn = null;
    await store.download(snapshot);
    expect(await store.isDownloaded(snapshot), isTrue);
    expect(progress, ['0/2', '1/2']);
    expect((await store.savedSnapshots()).single.journeyId, 2);
  });

  test('removing a download keeps recordings another journey still uses', () async {
    await store.download(journey(3, [20, 21]));
    await store.download(journey(4, [21]));
    expect(await store.removeDownload(3), 1);
    expect(media.removed, [20]);
    expect(await store.savedSnapshot(3), isNull);
    expect(await store.savedSnapshot(4), isNotNull);
  });

  test('another account cannot read saved journeys', () async {
    await store.download(journey(5, [30]));
    final other = OfflineJourneyStore(root: root, userId: 6, media: media);
    expect(await other.savedSnapshot(5), isNull);
    expect(await other.savedSnapshots(), isEmpty);
  });

  test('browser store keeps progress and unsent answers, streams recordings', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final browser = OfflineJourneyStore.browser(preferences: preferences, userId: 5);
    final engine = JourneyEngine(journey(7, [70]))..next();
    engine.answer(0);
    await browser.saveProgress(engine);
    expect(await browser.loadProgress(7), isNotNull);
    expect(await browser.pendingCount(), 1);
    final report = await browser.syncPending(FakeApi());
    expect((report.sent, report.remaining), (1, 0));
    await browser.clearProgress(7);
    expect(await browser.loadProgress(7), isNull);
    // Recordings are never saved in a browser; the reason is spoken.
    expect(await browser.isDownloaded(journey(7, [70])), isFalse);
    await expectLater(
      browser.download(journey(7, [70])),
      throwsA(isA<OfflineJourneyException>().having(
        (e) => e.message, 'message', contains('Android app'),
      )),
    );
    final other = OfflineJourneyStore.browser(preferences: preferences, userId: 6);
    await browser.saveProgress(engine);
    expect(await other.loadProgress(7), isNull, reason: 'kept per account');
  });
}
