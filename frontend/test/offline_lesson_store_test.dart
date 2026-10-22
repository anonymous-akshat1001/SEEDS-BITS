import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/services/offline_lesson_store.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  late Directory root;
  late OfflineLessonStore store;
  final content = utf8.encode('Small educational audio recording');
  late DateTime now;
  late DateTime issued;
  var manifestStatus = 200;
  var reportedSize = 0;
  var wrongHash = false;
  var changedAccount = false;
  var offline = false;
  var streamCalls = 0;
  String? range;
  Future<http.StreamedResponse> Function(http.BaseRequest)? mediaHandler;

  Map<String, dynamic> manifest(int id, {int account = 7}) => {
    'version': 1,
    'account_id': account,
    'audio_id': id,
    'title': 'Lesson $id',
    'class_id': 1,
    'subject_id': 1,
    'mime_type': 'audio/mpeg',
    'bytes': reportedSize > 0 ? reportedSize : content.length,
    'sha256': wrongHash ? '0' * 64 : sha256.convert(content).toString(),
    'authorized_at': issued.millisecondsSinceEpoch ~/ 1000,
    'expires_at':
        issued.add(const Duration(days: 30)).millisecondsSinceEpoch ~/ 1000,
  };

  http.Client client() => MockClient.streaming((request, _) async {
    if (offline) throw const SocketException('No connection');
    expect(request.headers['Authorization'], 'Bearer test-token');
    if (request.url.path.endsWith('offline-manifest')) {
      final id = int.parse(request.url.pathSegments[1]);
      return http.StreamedResponse(
        Stream.value(utf8.encode(jsonEncode(manifest(id)))),
        manifestStatus,
      );
    }
    streamCalls++;
    range = request.headers['Range'];
    if (mediaHandler != null) return mediaHandler!(request);
    final offset = range == null
        ? 0
        : int.parse(range!.substring(6).replaceAll('-', ''));
    return http.StreamedResponse(
      Stream.value(content.sublist(offset)),
      offset == 0 ? 200 : 206,
      contentLength: content.length - offset,
      headers: offset == 0
          ? {}
          : {
              'content-range':
                  'bytes $offset-${content.length - 1}/${content.length}',
            },
    );
  });

  OfflineLessonStore open({int user = 7}) => OfflineLessonStore(
    root: root,
    userId: user,
    apiBase: Uri.parse('https://example.test'),
    clock: () => now,
    clientFactory: client,
    credentials: () async {
      if (changedAccount) throw const OfflineLessonException('Account changed');
      return 'test-token';
    },
  );

  File file(int id, String suffix) =>
      File('${store.directory.path}${Platform.pathSeparator}$id.$suffix');

  setUp(() async {
    root = await Directory.systemTemp.createTemp('seeds-offline-test-');
    now = issued = DateTime.utc(2026, 10, 1);
    manifestStatus = 200;
    reportedSize = 0;
    wrongHash = changedAccount = offline = false;
    streamCalls = 0;
    range = null;
    mediaHandler = null;
    store = open();
  });
  tearDown(() async => root.delete(recursive: true));

  test(
    'unreadable inventory permits selected removal without hiding corruption or valid lessons',
    () async {
      await store.download(1, OfflineDownload());
      await store.download(2, OfflineDownload());
      await file(1, 'json').writeAsString('{broken');
      final inventory = await open().inspectRecords();
      expect(inventory.unreadableIds, [1]);
      expect(inventory.lessons.single.audioId, 2);
      expect(await file(1, 'media').exists(), isTrue);
      await expectLater(
        store.reservedBytes(),
        throwsA(isA<OfflineLessonException>()),
      );
      await store.remove(1);
      expect((await store.inspectRecords()).unreadableIds, isEmpty);
      expect(await store.reservedBytes(), content.length);
      expect(await store.localPath(2), endsWith('2.media'));
    },
  );

  test(
    'download survives reopening, verifies SHA-256, and has no persisted token or URL',
    () async {
      final operation = OfflineDownload();
      await store.download(1, operation);
      expect(operation.received, content.length);
      expect(operation.total, content.length);
      expect((await store.list()).single.complete, isTrue);
      final path = await open().localPath(1);
      expect(await File(path).readAsBytes(), content);
      expect(
        await file(1, 'json').readAsString(),
        isNot(contains('test-token')),
      );
      expect(await file(1, 'json').readAsString(), isNot(contains('https:')));
      expect(await store.reservedBytes(), content.length);
      operation.dispose();
    },
  );

  test(
    'local playback makes no network request and expires at exactly thirty days',
    () async {
      await store.download(1, OfflineDownload());
      offline = true;
      now = issued
          .add(const Duration(days: 30))
          .subtract(const Duration(milliseconds: 1));
      expect(await store.localPath(1), endsWith('1.media'));
      now = issued.add(const Duration(days: 30));
      await expectLater(
        store.localPath(1),
        throwsA(
          isA<OfflineLessonException>().having(
            (e) => e.message,
            'message',
            contains('expired'),
          ),
        ),
      );
      expect(await file(1, 'media').exists(), isTrue);
    },
  );

  test(
    'renewal preserves bytes and progress; an online denial prevents future offline playback',
    () async {
      await store.download(1, OfflineDownload());
      now = issued = issued.add(const Duration(days: 29));
      await store.renew(1);
      now = now.add(const Duration(days: 5));
      expect(await store.localPath(1), endsWith('1.media'));
      manifestStatus = 403;
      await expectLater(store.renew(1), throwsA(isA<OfflineLessonException>()));
      offline = true;
      await expectLater(
        store.localPath(1),
        throwsA(
          isA<OfflineLessonException>().having(
            (e) => e.message,
            'message',
            contains('renewal'),
          ),
        ),
      );
      expect(await file(1, 'media').exists(), isTrue);
    },
  );

  test(
    'per-account quota reserves partial sizes without silently evicting anything',
    () async {
      reportedSize = OfflineLessonStore.quota - 1;
      mediaHandler = (_) async => http.StreamedResponse(
        Stream.value(content),
        200,
        contentLength: reportedSize,
      );
      await expectLater(
        store.download(1, OfflineDownload()),
        throwsA(isA<OfflineLessonException>()),
      );
      reportedSize = 2;
      await expectLater(
        store.download(2, OfflineDownload()),
        throwsA(
          isA<OfflineLessonException>().having(
            (e) => e.message,
            'message',
            contains('50 MB'),
          ),
        ),
      );
      expect((await store.list()).single.audioId, 1);
      expect(await store.reservedBytes(), OfflineLessonStore.quota - 1);
      expect(await open(user: 8).reservedBytes(), 0);
      expect(await file(1, 'part').exists(), isTrue);
      expect(streamCalls, 1);
    },
  );

  test(
    'partial interruption resumes with a validated Range response',
    () async {
      mediaHandler = (_) async => http.StreamedResponse(
        Stream.value(content.sublist(0, 8)),
        200,
        contentLength: content.length,
      );
      await expectLater(
        store.download(1, OfflineDownload()),
        throwsA(isA<OfflineLessonException>()),
      );
      expect(await file(1, 'part').length(), 8);
      mediaHandler = null;
      await store.download(1, OfflineDownload());
      expect(range, 'bytes=8-');
      expect(await file(1, 'media').readAsBytes(), content);
      expect(await file(1, 'part').exists(), isFalse);
    },
  );

  test(
    'server ignoring Range restarts safely rather than appending duplicate bytes',
    () async {
      mediaHandler = (_) async => http.StreamedResponse(
        Stream.value(content.sublist(0, 8)),
        200,
        contentLength: content.length,
      );
      await expectLater(
        store.download(1, OfflineDownload()),
        throwsA(isA<OfflineLessonException>()),
      );
      mediaHandler = (_) async => http.StreamedResponse(
        Stream.value(content),
        200,
        contentLength: content.length,
      );
      await store.download(1, OfflineDownload());
      expect(await file(1, 'media').readAsBytes(), content);
    },
  );

  test('incorrect Range does not overwrite retained partial bytes', () async {
    mediaHandler = (_) async => http.StreamedResponse(
      Stream.value(content.sublist(0, 8)),
      200,
      contentLength: content.length,
    );
    await expectLater(
      store.download(1, OfflineDownload()),
      throwsA(isA<OfflineLessonException>()),
    );
    mediaHandler = (_) async => http.StreamedResponse(
      Stream.value(content),
      206,
      headers: {'content-range': 'bytes 0-5/6'},
    );
    await expectLater(
      store.download(1, OfflineDownload()),
      throwsA(isA<OfflineLessonException>()),
    );
    expect(await file(1, 'part').readAsBytes(), content.sublist(0, 8));
  });

  test(
    'checksum mismatch and post-download corruption cannot be played',
    () async {
      wrongHash = true;
      await expectLater(
        store.download(1, OfflineDownload()),
        throwsA(isA<OfflineLessonException>()),
      );
      expect(await file(1, 'media').exists(), isFalse);
      await store.remove(1);
      wrongHash = false;
      await store.download(1, OfflineDownload());
      await file(1, 'media').writeAsBytes(List.filled(content.length, 0));
      await expectLater(
        store.localPath(1),
        throwsA(
          isA<OfflineLessonException>().having(
            (e) => e.message,
            'message',
            contains('damaged'),
          ),
        ),
      );
    },
  );

  test(
    'explicit cancellation retains partial data for retry and never reports complete',
    () async {
      final operation = OfflineDownload();
      final chunks = StreamController<List<int>>();
      mediaHandler = (_) async => http.StreamedResponse(
        chunks.stream,
        200,
        contentLength: content.length,
      );
      final pending = store.download(1, operation);
      final failure = expectLater(
        pending,
        throwsA(isA<OfflineLessonException>()),
      );
      while (streamCalls == 0) {
        await Future<void>.delayed(const Duration(milliseconds: 5));
      }
      chunks.add(content.sublist(0, 8));
      await Future<void>.delayed(const Duration(milliseconds: 30));
      operation.cancel();
      await chunks.close();
      await failure;
      expect((await store.list()).single.complete, isFalse);
      expect(await file(1, 'part').length(), 8);
      mediaHandler = null;
      await store.download(1, OfflineDownload());
      expect(await store.localPath(1), endsWith('1.media'));
      operation.dispose();
    },
  );

  test(
    'account switches stop an in-flight transfer without exposing it to the next account',
    () async {
      final chunks = StreamController<List<int>>();
      mediaHandler = (_) async => http.StreamedResponse(
        chunks.stream,
        200,
        contentLength: content.length,
      );
      final pending = store.download(1, OfflineDownload());
      final failure = expectLater(
        pending,
        throwsA(isA<OfflineLessonException>()),
      );
      while (streamCalls == 0) {
        await Future<void>.delayed(const Duration(milliseconds: 5));
      }
      changedAccount = true;
      chunks.add(content);
      unawaited(chunks.close());
      await failure;
      expect(await file(1, 'media').exists(), isFalse);
      changedAccount = false;
      expect(await open(user: 8).list(), isEmpty);
    },
  );

  test(
    'changed content requires explicit replacement, never overwrites an existing lesson',
    () async {
      await store.download(1, OfflineDownload());
      wrongHash = true;
      await expectLater(store.renew(1), throwsA(isA<OfflineLessonException>()));
      await expectLater(
        store.download(1, OfflineDownload()),
        throwsA(isA<OfflineLessonException>()),
      );
      expect(await file(1, 'media').readAsBytes(), content);
      await expectLater(
        store.localPath(1),
        throwsA(isA<OfflineLessonException>()),
      );
    },
  );

  test('a backwards clock cannot extend an existing entitlement', () async {
    await store.download(1, OfflineDownload());
    now = issued.add(const Duration(days: 20));
    await store.localPath(1);
    now = issued.add(const Duration(days: 10));
    await expectLater(
      store.localPath(1),
      throwsA(
        isA<OfflineLessonException>().having(
          (e) => e.message,
          'message',
          contains('clock'),
        ),
      ),
    );
  });

  test(
    'the exact 50 MB reservation is accepted while one additional byte is rejected',
    () async {
      reportedSize = OfflineLessonStore.quota;
      mediaHandler = (_) async => http.StreamedResponse(
        Stream.value(content),
        200,
        contentLength: reportedSize,
      );
      await expectLater(
        store.download(1, OfflineDownload()),
        throwsA(isA<OfflineLessonException>()),
      );
      expect(streamCalls, 1);
      expect(await store.reservedBytes(), OfflineLessonStore.quota);
      reportedSize = 1;
      await expectLater(
        store.download(2, OfflineDownload()),
        throwsA(
          isA<OfflineLessonException>().having(
            (e) => e.message,
            'message',
            contains('50 MB'),
          ),
        ),
      );
      expect(streamCalls, 1);
    },
  );

  test(
    'corrupt and foreign-account metadata is retained and explicitly rejected',
    () async {
      await store.download(1, OfflineDownload());
      await file(1, 'json').writeAsString('{broken');
      await expectLater(store.list(), throwsA(isA<OfflineLessonException>()));
      expect(await file(1, 'json').readAsString(), '{broken');
      expect(await file(1, 'media').readAsBytes(), content);
      await file(1, 'json').writeAsString(jsonEncode(manifest(1, account: 8)));
      await expectLater(
        store.localPath(1),
        throwsA(isA<OfflineLessonException>()),
      );
      expect(await file(1, 'media').exists(), isTrue);
    },
  );

  test(
    'successful online renewal repairs a corrupt time checkpoint without deleting media',
    () async {
      await store.download(1, OfflineDownload());
      final clockFile = File(
        '${store.directory.path}${Platform.pathSeparator}clock.json',
      );
      await clockFile.writeAsString('{broken');
      await expectLater(
        store.localPath(1),
        throwsA(isA<OfflineLessonException>()),
      );
      await store.renew(1);
      expect(await store.localPath(1), endsWith('1.media'));
    },
  );

  test(
    'selected removal leaves progress and all other downloads intact',
    () async {
      await store.download(1, OfflineDownload());
      await store.download(2, OfflineDownload());
      final progress = File(
        '${store.directory.parent.path}${Platform.pathSeparator}lesson_1.json',
      );
      await progress.writeAsString('separate progress');
      await store.remove(1);
      expect((await store.list()).single.audioId, 2);
      expect(await progress.readAsString(), 'separate progress');
      expect(await store.localPath(2), endsWith('2.media'));
    },
  );
}
