import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/screens/audio_library_screen.dart';
import 'package:frontend/screens/playlist_screens.dart';
import 'package:frontend/screens/downloads_screen.dart';
import 'package:frontend/screens/private_notes_screen.dart';
import 'package:frontend/services/offline_lesson_store.dart';
import 'package:frontend/services/learning_progress_store.dart';
import 'package:frontend/services/tts_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _PrivateTestDirectory extends PathProviderPlatform {
  _PrivateTestDirectory(this.path);
  final String path;
  @override
  Future<String?> getApplicationSupportPath() async => path;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory root;
  late LearningProgressStore store;
  late PathProviderPlatform previousProvider;
  final calls = <MethodCall>[];
  String? playerId;
  int positionMs = 0;
  Completer<void>? seekGate;
  var available = true;
  var offline = false;
  var failSecondDownload = false;
  var streamRequested = false;
  Completer<void>? mediaResponseGate;
  final media = utf8.encode('Test recording for local media validation');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  Future<void> emit(String name, [Object? value, String? target]) async {
    await messenger.handlePlatformMessage(
      'xyz.luan/audioplayers/events/${target ?? playerId}',
      const StandardMethodCodec().encodeSuccessEnvelope({
        'event': name,
        'value': value,
      }),
      (_) {},
    );
  }

  setUp(() async {
    root = await Directory.systemTemp.createTemp('seeds-learning-widget-');
    previousProvider = PathProviderPlatform.instance;
    PathProviderPlatform.instance = _PrivateTestDirectory(root.path);
    store = LearningProgressStore(root: root, userId: 7);
    calls.clear();
    playerId = null;
    positionMs = 0;
    seekGate = null;
    available = true;
    offline = false;
    failSecondDownload = false;
    streamRequested = false;
    mediaResponseGate = null;
    SharedPreferences.setMockInitialValues({
      'user_id': 7,
      'token': 'test-token',
      'role': 'student',
    });
    dotenv.testLoad(fileInput: 'API_BASE_URL=https://example.test');
    messenger.setMockMethodCallHandler(
      const MethodChannel('flutter_tts'),
      (_) async => 1,
    );
    await TtsService.configure(
      enabled: true,
      volume: 1,
      mode: SpeechMode.selfVoicing,
    );
    for (final channel in [
      'xyz.luan/audioplayers.global',
      'xyz.luan/audioplayers.global/events',
    ]) {
      messenger.setMockMethodCallHandler(
        MethodChannel(channel),
        (_) async => null,
      );
    }
    messenger.setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers'),
      (call) async {
        calls.add(call);
        final arguments = call.arguments as Map;
        if (call.method == 'create') {
          final id = arguments['playerId'] as String;
          messenger.setMockMethodCallHandler(
            MethodChannel('xyz.luan/audioplayers/events/$id'),
            (_) async => null,
          );
        } else if (call.method == 'setSourceUrl') {
          playerId = arguments['playerId'] as String;
          await emit('audio.onPrepared', true, playerId);
        } else if (call.method == 'seek') {
          positionMs = arguments['position'] as int;
          await seekGate?.future;
          await emit(
            'audio.onSeekComplete',
            null,
            arguments['playerId'] as String,
          );
        } else if (call.method == 'getDuration') {
          return 180000;
        } else if (call.method == 'getCurrentPosition') {
          return positionMs;
        }
        return null;
      },
    );
    await AudioPlayer.global.ensureInitialized();
  });

  tearDown(() async {
    await TtsService.stop();
    PathProviderPlatform.instance = previousProvider;
    await root.delete(recursive: true);
  });

  final audio = <String, dynamic>{
    'audio_id': 1,
    'title': 'English lesson',
    'class_id': 1,
    'subject_id': 1,
    'subject_name': 'English',
    'duration': 180.0,
  };
  http.Client client() => MockClient((request) async {
    if (offline) throw const SocketException('Offline');
    Object result;
    if (request.url.path == '/audio/list') {
      result = available ? [audio] : [];
    } else if (request.url.path == '/student/teacher-playlists/1') {
      result = {
        'title': 'Class playlist',
        'items': [
          {
            ...audio,
            'item_id': 1,
            'available': available,
            'stream_path': '/audio/1/stream',
          },
        ],
      };
    } else if (request.url.path.endsWith('play-log')) {
      result = {'ok': true};
    } else if (request.url.path.endsWith('offline-manifest')) {
      final issued = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
      result = {
        'version': 1,
        'account_id': 7,
        'audio_id': int.parse(request.url.pathSegments[1]),
        'title': 'English lesson',
        'class_id': 1,
        'subject_id': 1,
        'mime_type': 'audio/mpeg',
        'bytes': media.length,
        'sha256': sha256.convert(media).toString(),
        'authorized_at': issued,
        'expires_at': issued + 30 * 86400,
      };
    } else if (request.url.path.endsWith('/stream')) {
      streamRequested = true;
      await mediaResponseGate?.future;
      if (failSecondDownload && request.url.path == '/audio/2/stream') {
        return http.Response('Unavailable', 503);
      }
      return http.Response.bytes(media, 200);
    } else {
      result = [];
    }
    return http.Response(
      jsonEncode(result),
      200,
      headers: {'content-type': 'application/json'},
    );
  });

  Future<void> waitFor(WidgetTester tester, bool Function() ready) async {
    for (var tries = 0; tries < 300 && !ready(); tries++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump(const Duration(milliseconds: 20));
    }
    expect(
      ready(),
      isTrue,
      reason:
          'Timed out waiting for player or private storage. '
          'Native calls: ${calls.map((call) => call.method).toList()}. '
          'Visible text: ${tester.widgetList<Text>(find.byType(Text)).map((text) => text.data).take(15).toList()}',
    );
  }

  Future<void> keyActivate(WidgetTester tester, String label) async {
    for (var press = 0; press < 100; press++) {
      if (FocusManager.instance.primaryFocus?.debugLabel == label) break;
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump(const Duration(milliseconds: 30));
    }
    expect(FocusManager.instance.primaryFocus?.debugLabel, label);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
  }

  Future<void> close(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    var drained = false;
    final pending = store.recent().then((_) => drained = true);
    await waitFor(tester, () => drained);
    await pending;
    await TtsService.stop();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  }

  Future<void> seed(WidgetTester tester) async {
    await tester.runAsync(
      () => store.savePosition(
        audioId: 1,
        title: 'English lesson',
        position: const Duration(seconds: 25),
        duration: const Duration(minutes: 3),
        speed: 1.5,
      ),
    );
  }

  testWidgets(
    'class player restores actual native position and speed with all controls reachable at 240 by 320 and 3x text',
    (tester) async {
      tester.view.physicalSize = const Size(240, 320);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 3;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await seed(tester);
      await http.runWithClient(() async {
        await tester.pumpWidget(
          const MaterialApp(
            home: ClassAudioScreen(
              sessionId: 0,
              sessionTitle: 'Lessons',
              initialAudioId: 1,
            ),
          ),
        );
        await waitFor(
          tester,
          () => find.text('Add bookmark').evaluate().isNotEmpty,
        );
        await waitFor(tester, () => calls.any((call) => call.method == 'seek'));
        expect(
          calls
              .where((call) => call.method == 'seek')
              .last
              .arguments['position'],
          25000,
        );
        expect(
          calls
              .where((call) => call.method == 'setPlaybackRate')
              .last
              .arguments['playbackRate'],
          1.5,
        );
        final reached = <String>{};
        for (var i = 0; i < 60; i++) {
          await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
          await tester.pump(const Duration(milliseconds: 30));
          reached.add(FocusManager.instance.primaryFocus?.debugLabel ?? '');
        }
        expect(
          reached,
          containsAll([
            'class-audio-learning-status',
            'class-audio-bookmark-add',
            'class-audio-bookmarks',
            'class-audio-repeat-a',
            'class-audio-play',
            'class-audio-faster',
            'audio-item-1',
          ]),
        );
        await close(tester);
      }, client);
    },
  );

  testWidgets(
    'named bookmarks, confirmed removal, and progress work across class and playlist players',
    (tester) async {
      await seed(tester);
      await TtsService.configure(mode: SpeechMode.screenReader);
      await http.runWithClient(() async {
        await tester.pumpWidget(
          const MaterialApp(
            home: ClassAudioScreen(
              sessionId: 0,
              sessionTitle: 'Lessons',
              initialAudioId: 1,
            ),
          ),
        );
        await waitFor(
          tester,
          () => find.text('Add bookmark').evaluate().isNotEmpty,
        );
        await keyActivate(tester, 'class-audio-bookmark-add');
        await tester.pump(const Duration(milliseconds: 300));
        positionMs = 40000;
        await tester.pump(const Duration(milliseconds: 300));
        await tester.enterText(find.byType(TextField), 'Definition * #');
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await keyActivate(tester, 'bookmark-save');
        await waitFor(
          tester,
          () => find.text('Bookmarks (1)').evaluate().isNotEmpty,
        );
        final named = await tester.runAsync(() => store.lesson(1));
        expect(named!.position.inSeconds, 40);
        expect(named.bookmarks.single.position.inSeconds, 25);
        await keyActivate(tester, 'class-audio-bookmarks');
        await tester.pump(const Duration(milliseconds: 300));
        await keyActivate(tester, 'bookmark-jump-1');
        await waitFor(
          tester,
          () => find.text('Definition * # at 0:25').evaluate().isEmpty,
        );
        expect(
          calls
              .where((call) => call.method == 'seek')
              .last
              .arguments['position'],
          25000,
        );
        await keyActivate(tester, 'class-audio-bookmarks');
        await tester.pump(const Duration(milliseconds: 300));
        await keyActivate(tester, 'bookmark-remove-1');
        await tester.pump(const Duration(milliseconds: 300));
        await tester.tap(find.text('0: Keep bookmark'));
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.text('Definition * # at 0:25'), findsOneWidget);
        await keyActivate(tester, 'bookmark-remove-1');
        await tester.pump(const Duration(milliseconds: 300));
        await tester.tap(find.text('1: Remove bookmark'));
        await waitFor(
          tester,
          () => find.textContaining('No bookmarks yet').evaluate().isNotEmpty,
        );
        await keyActivate(tester, 'bookmark-close');
        await close(tester);

        final saved = await tester.runAsync(() => store.lesson(1));
        expect(saved!.position.inSeconds, 25);
        expect(saved.bookmarks, isEmpty);
        await tester.pumpWidget(
          MaterialApp(home: PlaylistDetailScreen.studentClass(playlistId: 1)),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('3 Play'));
        await waitFor(
          tester,
          () => find.text('Add bookmark').evaluate().isNotEmpty,
        );
        await waitFor(tester, () => find.text('3 Pause').evaluate().isNotEmpty);
        expect(
          calls
              .where((call) => call.method == 'seek')
              .last
              .arguments['position'],
          25000,
        );
        expect(
          calls
              .where((call) => call.method == 'setPlaybackRate')
              .last
              .arguments['playbackRate'],
          1.5,
        );
        await keyActivate(tester, 'playlist-learning-back-ten');
        await waitFor(
          tester,
          () =>
              calls
                  .where((call) => call.method == 'seek')
                  .last
                  .arguments['position'] ==
              15000,
        );
        expect(find.text('3 Pause'), findsOneWidget);
        await keyActivate(tester, 'playlist-learning-forward-ten');
        await waitFor(
          tester,
          () =>
              calls
                  .where((call) => call.method == 'seek')
                  .last
                  .arguments['position'] ==
              25000,
        );
        await emit('audio.onComplete');
        await waitFor(tester, () => find.text('3 Play').evaluate().isNotEmpty);
        await close(tester);
        final completed = await tester.runAsync(() => store.lesson(1));
        expect(completed!.completed, isTrue);
        expect(completed.position, Duration.zero);
      }, client);
    },
  );

  testWidgets(
    'continue learning revalidates access and retains unavailable progress',
    (tester) async {
      await seed(tester);
      available = false;
      await http.runWithClient(() async {
        await tester.pumpWidget(
          const MaterialApp(home: OfflineAudioLibraryScreen()),
        );
        await waitFor(
          tester,
          () => find.text('Continue Learning').evaluate().isNotEmpty,
        );
        await tester.tap(find.text('Continue Learning'));
        await waitFor(
          tester,
          () => find
              .textContaining('unfinished lessons are not currently available')
              .evaluate()
              .isNotEmpty,
        );
        expect(find.byType(ClassAudioScreen), findsNothing);
        expect(calls.where((call) => call.method == 'setSourceUrl'), isEmpty);
        await close(tester);
        final retained = await tester.runAsync(() => store.lesson(1));
        expect(retained!.position.inSeconds, 25);
      }, client);
    },
  );

  testWidgets(
    'continue learning opens the authorized lesson from only the signed-in account',
    (tester) async {
      await seed(tester);
      await tester.runAsync(
        () => LearningProgressStore(root: root, userId: 8).savePosition(
          audioId: 99,
          title: 'Another account lesson',
          position: const Duration(seconds: 80),
          speed: 1,
        ),
      );
      await http.runWithClient(() async {
        await tester.pumpWidget(
          const MaterialApp(home: OfflineAudioLibraryScreen()),
        );
        await waitFor(
          tester,
          () => find.text('Continue Learning').evaluate().isNotEmpty,
        );
        await tester.tap(find.text('Continue Learning'));
        await waitFor(
          tester,
          () => find.text('Add bookmark').evaluate().isNotEmpty,
        );
        expect(find.byType(ClassAudioScreen), findsOneWidget);
        final source =
            calls
                    .where((call) => call.method == 'setSourceUrl')
                    .last
                    .arguments['url']
                as String;
        expect(Uri.parse(source).path, '/audio/1/stream');
        expect(
          calls
              .where((call) => call.method == 'seek')
              .last
              .arguments['position'],
          25000,
        );
        await close(tester);
      }, client);
    },
  );

  testWidgets(
    'playlist A-B controls share a native endpoint loop without advancing or marking complete',
    (tester) async {
      await seed(tester);
      await TtsService.configure(mode: SpeechMode.screenReader);
      await http.runWithClient(() async {
        await tester.pumpWidget(
          MaterialApp(home: PlaylistDetailScreen.studentClass(playlistId: 1)),
        );
        await waitFor(tester, () => find.text('3 Play').evaluate().isNotEmpty);
        await tester.tap(find.text('3 Play'));
        await waitFor(tester, () => find.text('3 Pause').evaluate().isNotEmpty);
        positionMs = 5000;
        await tester.pump(const Duration(milliseconds: 300));
        await keyActivate(tester, 'playlist-repeat-a');
        await waitFor(
          tester,
          () => find.text('Set A 0:05').evaluate().isNotEmpty,
        );
        positionMs = 180000;
        await tester.pump(const Duration(milliseconds: 300));
        await keyActivate(tester, 'playlist-repeat-b');
        await waitFor(
          tester,
          () => find.text('Set B 3:00').evaluate().isNotEmpty,
        );
        final gate = seekGate = Completer<void>();
        await keyActivate(tester, 'playlist-repeat-toggle');
        await waitFor(
          tester,
          () => calls.where((call) => call.method == 'seek').length == 2,
        );
        final resumes = calls.where((call) => call.method == 'resume').length;
        await emit('audio.onComplete');
        await tester.pump();
        gate.complete();
        await waitFor(
          tester,
          () => calls.where((call) => call.method == 'resume').length > resumes,
        );
        expect(calls.where((call) => call.method == 'seek').length, 2);
        expect(
          calls
              .where((call) => call.method == 'seek')
              .last
              .arguments['position'],
          5000,
        );
        expect(calls.where((call) => call.method == 'setSourceUrl').length, 1);
        expect(
          calls
              .where((call) => call.method == 'setReleaseMode')
              .last
              .arguments['releaseMode'],
          ReleaseMode.stop.toString(),
        );
        expect(find.text('3 Pause'), findsOneWidget);
        await close(tester);
        final saved = await tester.runAsync(() => store.lesson(1));
        expect(saved!.completed, isFalse);
        expect(saved.repeatStart!.inSeconds, 5);
        expect(saved.repeatEnd!.inSeconds, 180);
      }, client);
    },
  );

  testWidgets(
    'playlist refresh stops an unavailable lesson without discarding its progress',
    (tester) async {
      await seed(tester);
      await http.runWithClient(() async {
        await tester.pumpWidget(
          MaterialApp(home: PlaylistDetailScreen.studentClass(playlistId: 1)),
        );
        await waitFor(tester, () => find.text('3 Play').evaluate().isNotEmpty);
        await tester.tap(find.text('3 Play'));
        await waitFor(tester, () => find.text('3 Pause').evaluate().isNotEmpty);
        available = false;
        await tester.sendKeyEvent(LogicalKeyboardKey.digit1);
        await waitFor(
          tester,
          () => find
              .textContaining('Playback stopped. Your saved progress')
              .evaluate()
              .isNotEmpty,
        );
        expect(find.text('3 Play'), findsOneWidget);
        final resumes = calls.where((call) => call.method == 'resume').length;
        await tester.tap(find.text('3 Play'));
        await tester.pump(const Duration(milliseconds: 300));
        expect(calls.where((call) => call.method == 'resume').length, resumes);
        await close(tester);
        final saved = await tester.runAsync(() => store.lesson(1));
        expect(saved!.position.inSeconds, 25);
        expect(saved.completed, isFalse);
      }, client);
    },
  );

  testWidgets(
    'download manager saves actual media then opens local playback without internet at 240 by 320',
    (tester) async {
      tester.view.physicalSize = const Size(240, 320);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await seed(tester);
      await http.runWithClient(() async {
        await tester.pumpWidget(
          MaterialApp(home: DownloadsScreen(candidates: [audio])),
        );
        await waitFor(
          tester,
          () => find
              .text(
                'No downloads yet. Find recordings online or open Downloads from a class or playlist.',
              )
              .evaluate()
              .isNotEmpty,
        );
        await keyActivate(tester, 'downloads-download-1');
        await waitFor(
          tester,
          () => find.text('Play downloaded lesson').evaluate().isNotEmpty,
        );
        final offlineStore = await tester.runAsync(
          OfflineLessonStore.forCurrentUser,
        );
        final lessons = await tester.runAsync(offlineStore!.list);
        expect(lessons!.single.complete, isTrue);
        offline = true;
        await keyActivate(tester, 'downloads-play-1');
        await waitFor(
          tester,
          () => calls.any((call) => call.method == 'setSourceUrl'),
        );
        final source =
            calls.where((call) => call.method == 'setSourceUrl').last.arguments
                as Map;
        expect(source['isLocal'], isTrue);
        expect(source['url'], endsWith('1.media'));
        expect(
          calls
              .where((call) => call.method == 'seek')
              .last
              .arguments['position'],
          25000,
        );
        expect(tester.takeException(), isNull);
        await close(tester);
      }, client);
    },
  );

  testWidgets(
    'saved downloads remain keypad reachable while the online library request is stalled',
    (tester) async {
      final onlineResponse = Completer<http.Response>();
      var requested = false;
      await http.runWithClient(
        () async {
          await tester.pumpWidget(
            const MaterialApp(home: OfflineAudioLibraryScreen()),
          );
          await waitFor(tester, () => requested);
          await keyActivate(tester, 'recorded-library-downloads');
          await waitFor(
            tester,
            () =>
                find.textContaining('No downloads yet.').evaluate().isNotEmpty,
          );
          expect(find.byType(DownloadsScreen), findsOneWidget);
          await close(tester);
          onlineResponse.complete(http.Response('[]', 200));
          await tester.pump();
        },
        () => MockClient((_) {
          requested = true;
          return onlineResponse.future;
        }),
      );
    },
  );

  testWidgets(
    'private notes remain keypad reachable while the online library request is stalled',
    (tester) async {
      final response = Completer<http.Response>();
      var requested = false;
      await http.runWithClient(
        () async {
          await tester.pumpWidget(
            const MaterialApp(home: OfflineAudioLibraryScreen()),
          );
          await waitFor(tester, () => requested);
          await keyActivate(tester, 'recorded-library-notes');
          await waitFor(
            tester,
            () => find.text('Record a private note').evaluate().isNotEmpty,
          );
          expect(find.byType(PrivateNotesScreen), findsOneWidget);
          expect(calls.where((call) => call.method == 'start'), isEmpty);
          await close(tester);
          response.complete(http.Response('[]', 200));
          await tester.pump();
        },
        () => MockClient((_) {
          requested = true;
          return response.future;
        }),
      );
    },
  );

  testWidgets(
    'study notes capture the lesson point on activation and pause the native lesson before opening',
    (tester) async {
      await seed(tester);
      await TtsService.configure(mode: SpeechMode.screenReader);
      await http.runWithClient(() async {
        await tester.pumpWidget(
          const MaterialApp(
            home: ClassAudioScreen(
              sessionId: 0,
              sessionTitle: 'Lessons',
              initialAudioId: 1,
            ),
          ),
        );
        await waitFor(tester, () => calls.any((call) => call.method == 'seek'));
        final before = calls.where((call) => call.method == 'pause').length;
        await keyActivate(tester, 'class-audio-private-notes');
        await waitFor(
          tester,
          () => find.byType(PrivateNotesScreen).evaluate().isNotEmpty,
        );
        expect(
          calls.where((call) => call.method == 'pause').length,
          greaterThan(before),
        );
        expect(
          find.textContaining('Captured lesson point: 25 seconds.'),
          findsOneWidget,
        );
        expect(calls.where((call) => call.method == 'start'), isEmpty);
        await close(tester);
      }, client);
    },
  );

  testWidgets(
    'unreadable download records have confirmed keypad recovery without deleting other media',
    (tester) async {
      await http.runWithClient(() async {
        final offlineStore = await tester.runAsync(() async {
          final saved = await OfflineLessonStore.forCurrentUser();
          await saved.download(1, OfflineDownload());
          await saved.download(2, OfflineDownload());
          await File(
            '${saved.directory.path}${Platform.pathSeparator}1.json',
          ).writeAsString('{broken');
          return saved;
        });
        await tester.pumpWidget(const MaterialApp(home: DownloadsScreen()));
        await waitFor(
          tester,
          () => find.text('Remove unreadable download 1').evaluate().isNotEmpty,
        );
        await keyActivate(tester, 'downloads-remove-1');
        await tester.pump(const Duration(milliseconds: 300));
        await tester.sendKeyEvent(LogicalKeyboardKey.digit1);
        await tester.pump(const Duration(milliseconds: 300));
        expect(
          await tester.runAsync(
            () async => (await offlineStore!.inspectRecords()).unreadableIds,
          ),
          [1],
        );
        await keyActivate(tester, 'downloads-remove-1');
        await tester.pump(const Duration(milliseconds: 300));
        await tester.sendKeyEvent(LogicalKeyboardKey.digit2);
        await waitFor(
          tester,
          () => find.text('Remove unreadable download 1').evaluate().isEmpty,
        );
        expect(
          await tester.runAsync(
            () async => (await offlineStore!.list()).single.audioId,
          ),
          2,
        );
        expect(
          await tester.runAsync(
            () async => File(await offlineStore!.localPath(2)).exists(),
          ),
          isTrue,
        );
        await close(tester);
      }, client);
    },
  );

  testWidgets(
    'download cancellation retains retryable state and never reports success',
    (tester) async {
      final gate = mediaResponseGate = Completer<void>();
      await http.runWithClient(() async {
        await tester.pumpWidget(
          MaterialApp(home: DownloadsScreen(candidates: [audio])),
        );
        await waitFor(
          tester,
          () => find.textContaining('No downloads yet.').evaluate().isNotEmpty,
        );
        await keyActivate(tester, 'downloads-download-1');
        await waitFor(tester, () => streamRequested);
        await keyActivate(tester, 'downloads-cancel');
        gate.complete();
        await waitFor(
          tester,
          () =>
              find.textContaining('Download cancelled.').evaluate().isNotEmpty,
        );
        expect(
          find.text('Download verified and saved for offline playback.'),
          findsNothing,
        );
        final offlineStore = await tester.runAsync(
          OfflineLessonStore.forCurrentUser,
        );
        final saved = await tester.runAsync(offlineStore!.list);
        expect(saved!.single.complete, isFalse);
        await close(tester);
      }, client);
    },
  );

  testWidgets(
    'confirmed playlist pack reports partial success without deleting verified recordings',
    (tester) async {
      failSecondDownload = true;
      await http.runWithClient(() async {
        await tester.pumpWidget(
          MaterialApp(
            home: DownloadsScreen(
              candidates: [
                audio,
                {...audio, 'audio_id': 2, 'title': 'Second recording'},
              ],
            ),
          ),
        );
        await waitFor(
          tester,
          () => find.textContaining('No downloads yet.').evaluate().isNotEmpty,
        );
        await keyActivate(tester, 'downloads-pack');
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.text('Download listed recordings?'), findsOneWidget);
        await tester.sendKeyEvent(LogicalKeyboardKey.digit2);
        await waitFor(
          tester,
          () => find
              .textContaining(
                '1 of 2 recordings verified. The recording could not be downloaded.',
              )
              .evaluate()
              .isNotEmpty,
        );
        final offlineStore = await tester.runAsync(
          OfflineLessonStore.forCurrentUser,
        );
        final saved = await tester.runAsync(offlineStore!.list);
        expect(saved!.where((lesson) => lesson.complete).single.audioId, 1);
        expect(saved.where((lesson) => !lesson.complete).single.audioId, 2);
        await close(tester);
      }, client);
    },
  );

  testWidgets(
    'removing a download requires confirmation and preserves progress and bookmarks',
    (tester) async {
      await seed(tester);
      await tester.runAsync(
        () => store.addBookmark(
          1,
          const Duration(seconds: 15),
          label: 'Retain me',
        ),
      );
      await http.runWithClient(() async {
        final offlineStore = await tester.runAsync(
          OfflineLessonStore.forCurrentUser,
        );
        await tester.runAsync(
          () => offlineStore!.download(1, OfflineDownload()),
        );
        await tester.pumpWidget(const MaterialApp(home: DownloadsScreen()));
        await waitFor(
          tester,
          () => find.text('Play downloaded lesson').evaluate().isNotEmpty,
        );
        await keyActivate(tester, 'downloads-remove-1');
        await tester.pump(const Duration(milliseconds: 300));
        await tester.sendKeyEvent(LogicalKeyboardKey.digit1);
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.text('Play downloaded lesson'), findsOneWidget);
        await keyActivate(tester, 'downloads-remove-1');
        await tester.pump(const Duration(milliseconds: 300));
        await tester.sendKeyEvent(LogicalKeyboardKey.digit2);
        await waitFor(
          tester,
          () => find.text('Play downloaded lesson').evaluate().isEmpty,
        );
        final retained = await tester.runAsync(() => store.lesson(1));
        expect(retained!.position.inSeconds, 25);
        expect(retained.bookmarks.single.label, 'Retain me');
        await close(tester);
      }, client);
    },
  );

  testWidgets(
    'corrupt progress requires explicit read-only playback and is never erased',
    (tester) async {
      await seed(tester);
      final file = File(
        '${root.path}${Platform.pathSeparator}seeds_learning'
        '${Platform.pathSeparator}7${Platform.pathSeparator}lesson_1.json',
      );
      await tester.runAsync(() => file.writeAsString('{broken'));
      await http.runWithClient(() async {
        await tester.pumpWidget(
          const MaterialApp(
            home: ClassAudioScreen(
              sessionId: 0,
              sessionTitle: 'Lessons',
              initialAudioId: 1,
            ),
          ),
        );
        await waitFor(
          tester,
          () => find.text('Saved progress unavailable').evaluate().isNotEmpty,
        );
        expect(calls.where((call) => call.method == 'setSourceUrl'), isEmpty);
        await tester.tap(find.text('1: Listen from beginning'));
        await waitFor(
          tester,
          () => calls.any((call) => call.method == 'resume'),
        );
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
        await TtsService.stop();
        await tester.pumpAndSettle();
        expect(await tester.runAsync(file.readAsString), '{broken');
        expect(tester.takeException(), isNull);
      }, client);
    },
  );
}
