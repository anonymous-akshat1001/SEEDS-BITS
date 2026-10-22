import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/main.dart' show routeObserver;
import 'package:frontend/screens/private_notes_screen.dart';
import 'package:frontend/services/private_note_store.dart';
import 'package:frontend/services/tts_service.dart';
import 'package:frontend/widgets/key_instruction_wrapper.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _NoteDirectory extends PathProviderPlatform {
  _NoteDirectory(this.path);
  final String path;
  @override
  Future<String?> getApplicationSupportPath() async => path;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory root;
  late PathProviderPlatform previousProvider;
  late PrivateNoteStore store;
  final calls = <MethodCall>[];
  final requests = <http.Request>[];
  String? captureId;
  var failedUpload = false;
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  setUp(() async {
    TestWidgetsFlutterBinding.instance.handleAppLifecycleStateChanged(
      AppLifecycleState.resumed,
    );
    root = await Directory.systemTemp.createTemp('seeds-private-note-widget-');
    previousProvider = PathProviderPlatform.instance;
    PathProviderPlatform.instance = _NoteDirectory(root.path);
    calls.clear();
    requests.clear();
    failedUpload = false;
    captureId = null;
    SharedPreferences.setMockInitialValues({
      'user_id': 7,
      'token': 'test-token',
      'role': 'student',
    });
    dotenv.testLoad(fileInput: 'API_BASE_URL=https://example.test');
    store = await PrivateNoteStore.forCurrentUser();
    messenger.setMockMethodCallHandler(
      const MethodChannel('flutter_tts'),
      (_) async => 1,
    );
    messenger.setMockMethodCallHandler(
      const MethodChannel('flutter.baseflow.com/permissions/methods'),
      (call) async {
        if (call.method == 'requestPermissions') {
          return {for (final value in call.arguments as List) value: 1};
        }
        return 1;
      },
    );
    messenger.setMockMethodCallHandler(
      const MethodChannel('seeds/private_notes'),
      (call) async {
        calls.add(call);
        if (call.method == 'start') {
          final args = call.arguments as Map;
          captureId = args['id'] as String;
          await File(args['path'] as String).writeAsBytes([1, 2, 3]);
          return true;
        }
        return {
          'id': captureId,
          'duration_ms': 3000,
          'reason': 'stopped',
          'error': null,
        };
      },
    );
    for (final name in [
      'xyz.luan/audioplayers.global',
      'xyz.luan/audioplayers.global/events',
    ]) {
      messenger.setMockMethodCallHandler(
        MethodChannel(name),
        (_) async => null,
      );
    }
    messenger.setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers'),
      (call) async {
        calls.add(call);
        final args = call.arguments as Map;
        if (call.method == 'create') {
          messenger.setMockMethodCallHandler(
            MethodChannel('xyz.luan/audioplayers/events/${args['playerId']}'),
            (_) async => null,
          );
        } else if (call.method == 'setSourceUrl') {
          await messenger.handlePlatformMessage(
            'xyz.luan/audioplayers/events/${args['playerId']}',
            const StandardMethodCodec().encodeSuccessEnvelope({
              'event': 'audio.onPrepared',
              'value': true,
            }),
            (_) {},
          );
        } else if (call.method == 'getDuration') {
          return 3000;
        } else if (call.method == 'getCurrentPosition') {
          return 0;
        }
        return null;
      },
    );
    await AudioPlayer.global.ensureInitialized();
    await TtsService.configure(enabled: true, mode: SpeechMode.selfVoicing);
  });
  tearDown(() async {
    await TtsService.stop();
    PathProviderPlatform.instance = previousProvider;
    await root.delete(recursive: true);
  });
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 12; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 10)),
      );
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  Future<void> open(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        navigatorObservers: [routeObserver],
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(1.5)),
          child: child!,
        ),
        home: const PrivateNotesScreen(
          audioId: 9,
          lessonTitle: 'Algebra',
          position: Duration(seconds: 25),
        ),
      ),
    );
    await settle(tester);
    for (
      var i = 0;
      i < 80 && find.byType(LinearProgressIndicator).evaluate().isNotEmpty;
      i++
    ) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 10)),
      );
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.byType(LinearProgressIndicator), findsNothing);
  }

  Future<void> idle(WidgetTester tester) async {
    for (
      var i = 0;
      i < 100 && find.byType(LinearProgressIndicator).evaluate().isNotEmpty;
      i++
    ) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(find.byType(LinearProgressIndicator), findsNothing);
  }

  Future<void> activate(WidgetTester tester, String name) async {
    final target = tester
        .widgetList<KeypadInstructionWrapper>(
          find.byType(KeypadInstructionWrapper),
        )
        .expand((wrapper) => wrapper.focusTargets)
        .firstWhere((target) => target.node.debugLabel == name);
    expect(target.enabled, isTrue, reason: name);
    target.node.requestFocus();
    await tester.pump();
    expect(target.node.hasFocus, isTrue, reason: name);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await settle(tester);
    if (find.byType(AlertDialog).evaluate().isEmpty) await idle(tester);
  }

  Future<PrivateNote> saved() async {
    final prepared = await store.prepare(
      title: 'Teacher draft',
      audioId: 9,
      position: const Duration(seconds: 25),
    );
    await File(prepared.path).writeAsBytes([1, 2, 3]);
    return store.finish(prepared.note.id, const Duration(seconds: 3));
  }

  Future<void> close(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await settle(tester);
  }

  void smallScreen(WidgetTester tester) {
    tester.view.physicalSize = const Size(240, 320);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  MockClient client() => MockClient((request) async {
    requests.add(request);
    if (request.url.path == '/me/access-context') {
      return http.Response(
        jsonEncode({
          'workspaces': [
            {
              'class_id': 1,
              'subject_id': 2,
              'class_name': 'Class A',
              'subject_name': 'English',
            },
          ],
        }),
        200,
      );
    }
    if (request.url.path == '/audio/upload') {
      return http.Response(
        failedUpload
            ? '{}'
            : jsonEncode({
                'audio': {
                  'audio_id': 55,
                  'class_id': 1,
                  'subject_id': 2,
                  'uploaded_by': 7,
                },
              }),
        200,
      );
    }
    return http.Response('{}', 404);
  });
  testWidgets(
    '240x320 keypad explicit recording preserves the opening timestamp and students never get Publish',
    (tester) async {
      smallScreen(tester);
      await open(tester);
      expect(calls.where((call) => call.method == 'start'), isEmpty);
      await activate(tester, 'notes-start');
      expect(find.text('Name private note'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'My algebra note');
      await activate(tester, 'note-name-save');
      expect(find.text('Record private note?'), findsOneWidget);
      await activate(tester, 'dialog-confirm');
      expect(
        calls.where((call) => call.method == 'start').length,
        1,
        reason: tester
            .widgetList<Text>(find.byType(Text))
            .map((widget) => widget.data)
            .join('\n'),
      );
      await activate(tester, 'notes-stop');
      final notes = await tester.runAsync(() => store.list());
      expect(notes!.single.complete, isTrue);
      expect(notes.single.position, const Duration(seconds: 25));
      expect(notes.single.title, 'My algebra note');
      expect(find.text('Publish reviewed note'), findsNothing);
      expect(tester.takeException(), isNull);
      await close(tester);
    },
  );
  testWidgets(
    'selected deletion cancel preserves media and confirmation removes only the selected note',
    (tester) async {
      smallScreen(tester);
      final first = (await tester.runAsync(saved))!;
      await tester.runAsync(saved);
      await open(tester);
      expect(
        find.text('Teacher draft'),
        findsNWidgets(2),
        reason: tester
            .widgetList<Text>(find.byType(Text))
            .map((widget) => widget.data)
            .join('\n'),
      );
      await activate(tester, 'notes-remove-${first.id}');
      await activate(tester, 'dialog-cancel');
      expect((await tester.runAsync(() => store.list()))!.length, 2);
      await activate(tester, 'notes-remove-${first.id}');
      await activate(tester, 'dialog-confirm');
      final remaining = await tester.runAsync(() => store.list());
      expect(remaining!.length, 1);
      expect(remaining.single.id, isNot(first.id));
      expect(tester.takeException(), isNull);
      await close(tester);
    },
  );
  for (final fail in [false, true]) {
    testWidgets(
      'teacher publication requires local review, workspace and explicit confirmation; malformed=$fail retains draft',
      (tester) async {
        smallScreen(tester);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('role', 'teacher');
        final note = (await tester.runAsync(saved))!;
        failedUpload = fail;
        await http.runWithClient(() async {
          await open(tester);
          final publish = tester.widget<OutlinedButton>(
            find.widgetWithText(OutlinedButton, 'Publish reviewed note'),
          );
          expect(publish.onPressed, isNull);
          await activate(tester, 'notes-play-${note.id}');
          expect(
            calls.any(
              (call) =>
                  call.method == 'setSourceUrl' &&
                  (call.arguments as Map)['isLocal'] == true,
            ),
            isTrue,
          );
          await activate(tester, 'notes-publish-${note.id}');
          expect(
            requests.where((request) => request.url.path == '/audio/upload'),
            isEmpty,
          );
          await activate(tester, 'note-workspace-0');
          expect(find.text('Publish reviewed note to class?'), findsOneWidget);
          expect(
            requests.where((request) => request.url.path == '/audio/upload'),
            isEmpty,
          );
          await activate(tester, 'dialog-confirm');
          expect(
            requests
                .where((request) => request.url.path == '/audio/upload')
                .length,
            1,
          );
          expect(
            (await tester.runAsync(() => store.list()))!.single.id,
            note.id,
          );
          expect(
            find.textContaining('Published as recording 55'),
            fail ? findsNothing : findsOneWidget,
          );
          if (fail) {
            expect(
              find.textContaining('Publication confirmation was unreadable'),
              findsOneWidget,
            );
          }
          expect(tester.takeException(), isNull);
          await close(tester);
        }, client);
      },
    );
  }
}
