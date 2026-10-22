import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/screens/lesson_sequences_screen.dart';
import 'package:frontend/services/tts_service.dart';
import 'package:frontend/widgets/key_instruction_wrapper.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Map<String, dynamic> plan;
  final requests = <http.Request>[];
  final executed = <LessonSequenceStep>[];
  var stale = false;
  var malformed = false;
  setUp(() async {
    plan = {
      'sequence_id': 1,
      'owner_teacher_id': 7,
      'class_id': 1,
      'subject_id': 2,
      'revision': 1,
      'title': 'Reusable English lesson',
      'steps': [
        {'kind': 'prompt', 'text': 'Introduce a word', 'audio_id': null},
        {'kind': 'check', 'text': 'Ask whether to repeat', 'audio_id': null},
      ],
    };
    stale = malformed = false;
    requests.clear();
    executed.clear();
    SharedPreferences.setMockInitialValues({
      'user_id': 7,
      'role': 'teacher',
      'token': 'test-token',
    });
    dotenv.testLoad(fileInput: 'API_BASE_URL=https://example.test');
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
      const MethodChannel('flutter_tts'),
      (_) async => 1,
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
        if (call.method == 'create') {
          final id = (call.arguments as Map)['playerId'];
          messenger.setMockMethodCallHandler(
            MethodChannel('xyz.luan/audioplayers/events/$id'),
            (_) async => null,
          );
        }
        return null;
      },
    );
    await AudioPlayer.global.ensureInitialized();
    await TtsService.configure(enabled: true, mode: SpeechMode.selfVoicing);
  });
  tearDown(() async => TtsService.stop());
  MockClient client() => MockClient((request) async {
    requests.add(request);
    Object body;
    if (request.method == 'GET') {
      body = {
        'class_id': 1,
        'subject_id': 2,
        'plans': [plan],
      };
    } else if (request.url.path.endsWith('/prepare')) {
      if (stale) {
        return http.Response(
          '{"detail":"This sequence changed. Refresh first."}',
          409,
        );
      }
      final position = int.parse(request.url.pathSegments[3]);
      body = malformed
          ? {'ok': true, 'sequence_id': 99}
          : {
              'ok': true,
              'sequence_id': 1,
              'revision': plan['revision'],
              'position': position,
              'step': (plan['steps'] as List)[position],
            };
    } else {
      final data = jsonDecode(request.body) as Map<String, dynamic>;
      plan = {
        ...plan,
        'title': data['title'],
        'steps': data['steps'],
        'revision': (plan['revision'] as int) + 1,
      };
      body = {'ok': true, 'plan': plan};
    }
    return http.Response(jsonEncode(body), 200);
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
    tester.view.physicalSize = const Size(240, 320);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(1.5)),
          child: child!,
        ),
        home: LessonSequencesScreen(
          sessionId: 5,
          execute: (step) async {
            executed.add(step);
          },
        ),
      ),
    );
    await settle(tester);
  }

  Future<void> activate(WidgetTester tester, String name) async {
    final target = tester
        .widgetList<KeypadInstructionWrapper>(
          find.byType(KeypadInstructionWrapper),
        )
        .expand((widget) => widget.focusTargets)
        .firstWhere((target) => target.node.debugLabel == name);
    expect(target.enabled, isTrue, reason: name);
    target.node.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await settle(tester);
  }

  Future<void> close(WidgetTester tester) async {
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await settle(tester);
  }

  test(
    'strict step parser rejects unknown kinds, empty prompts and nonrecording audio IDs',
    () {
      for (final data in [
        {'kind': 'quiz', 'text': 'Not approved'},
        {'kind': 'audio', 'text': 'No identity'},
        {'kind': 'check', 'text': '   '},
        {'kind': 'prompt', 'text': 'Wrong reference', 'audio_id': 1},
      ]) {
        expect(() => LessonSequenceStep.parse(data), throwsFormatException);
      }
    },
  );
  testWidgets(
    'plan and step selection never execute; cancel keeps state, confirmed Run validates the selected step and never advances',
    (tester) async {
      await http.runWithClient(() async {
        await open(tester);
        await activate(tester, 'sequence-plan-1');
        await activate(tester, 'sequence-next');
        expect(executed, isEmpty);
        expect(requests.where((request) => request.method == 'POST'), isEmpty);
        await activate(tester, 'sequence-run');
        await activate(tester, 'dialog-cancel');
        expect(executed, isEmpty);
        await activate(tester, 'sequence-run');
        await activate(tester, 'dialog-confirm');
        expect(executed.single.kind, LessonStepKind.check);
        expect(executed.single.text, 'Ask whether to repeat');
        expect(find.textContaining('Step 2 of 2:'), findsOneWidget);
        expect(
          requests
              .where((request) => request.url.path.endsWith('/prepare'))
              .single
              .url
              .queryParameters['session_id'],
          '5',
        );
        await close(tester);
      }, client);
    },
  );
  for (final badShape in [false, true]) {
    testWidgets(
      'stale or mismatched preparation cannot execute a classroom step; malformed=$badShape',
      (tester) async {
        stale = !badShape;
        malformed = badShape;
        await http.runWithClient(() async {
          await open(tester);
          await activate(tester, 'sequence-plan-1');
          await activate(tester, 'sequence-run');
          await activate(tester, 'dialog-confirm');
          expect(executed, isEmpty);
          expect(
            find.textContaining(
              badShape
                  ? 'prepared step did not match'
                  : 'Refresh and select the intended step',
            ),
            findsOneWidget,
          );
          await close(tester);
        }, client);
      },
    );
  }
  testWidgets(
    'teacher prompt addition and reordering are saved with revision, never run',
    (tester) async {
      await http.runWithClient(() async {
        await open(tester);
        await activate(tester, 'sequence-plan-1');
        await activate(tester, 'sequence-add-prompt');
        await tester.enterText(find.byType(TextField), 'Review the example');
        await activate(tester, 'sequence-entry-save');
        expect((plan['steps'] as List).length, 3);
        expect(plan['revision'], 2);
        expect(executed, isEmpty);
        await activate(tester, 'sequence-earlier');
        expect(
          ((plan['steps'] as List)[1] as Map)['text'],
          'Review the example',
        );
        expect(plan['revision'], 3);
        expect(executed, isEmpty);
        await close(tester);
      }, client);
    },
  );
}
