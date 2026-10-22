import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/services/classroom_check_state.dart';
import 'package:frontend/services/tts_service.dart';
import 'package:frontend/widgets/classroom_check_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final response = {'user_id': 7, 'name': 'Student', 'choice': 'help'};
  Map<String, dynamic> json({List<Object> responses = const []}) => {
    'type': 'classroom_check',
    'check_id': 'current',
    'revision': 2,
    'open': true,
    'responses': responses,
  };
  test(
    'private state validates identity, choices, duplicate names and missing shape',
    () {
      final own = ClassroomCheckState.parse(
        json(responses: [response]),
        userId: 7,
        teacher: false,
      );
      expect(
        own.describe(false),
        contains('Your confirmed response: Need help.'),
      );
      expect(
        () => ClassroomCheckState.parse(
          json(responses: [response]),
          userId: 8,
          teacher: false,
        ),
        throwsFormatException,
      );
      expect(
        () => ClassroomCheckState.parse(
          json(responses: [response, response]),
          userId: 7,
          teacher: true,
        ),
        throwsFormatException,
      );
      expect(
        () => ClassroomCheckState.parse(
          json(
            responses: [
              {...response, 'choice': 'graded'},
            ],
          ),
          userId: 7,
          teacher: true,
        ),
        throwsFormatException,
      );
      expect(
        () => ClassroomCheckState.parse({'ok': true}, userId: 7, teacher: true),
        throwsFormatException,
      );
    },
  );
  test(
    'teacher summary counts latest responses without describing them as grades',
    () {
      final state = ClassroomCheckState.parse(
        json(
          responses: [
            response,
            {'user_id': 8, 'name': 'Other', 'choice': 'repeat'},
          ],
        ),
        userId: 9,
        teacher: true,
      );
      expect(state.describe(true), contains('2 students responded'));
      expect(state.describe(true), contains('Need help: 1'));
      expect(state.describe(true), contains('Please repeat: 1'));
      expect(state.describe(true), contains('not grades'));
    },
  );

  late ValueNotifier<ClassroomCheckState> state;
  final calls = <(String, String?, String?)>[];
  final spoken = <String>[];
  Completer<String?>? pending;
  setUp(() async {
    state = ValueNotifier(
      ClassroomCheckState.parse(json(), userId: 7, teacher: false),
    );
    calls.clear();
    spoken.clear();
    pending = null;
    SharedPreferences.setMockInitialValues({});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('flutter_tts'), (
          call,
        ) async {
          if (call.method == 'speak') {
            final argument = call.arguments;
            spoken.add(
              argument is String
                  ? argument
                  : (argument as Map)['text'] as String,
            );
          }
          return 1;
        });
    await TtsService.stop();
    await TtsService.configure(enabled: true, mode: SpeechMode.selfVoicing);
  });
  tearDown(() async {
    state.dispose();
    await TtsService.stop();
  });

  Future<void> open(WidgetTester tester, {bool teacher = false}) async {
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
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => showDialog<void>(
              context: context,
              builder: (_) => ClassroomCheckDialog(
                state: state,
                teacher: teacher,
                act: (type, id, choice) async {
                  calls.add((type, id, choice));
                  return pending == null ? null : await pending!.future;
                },
              ),
            ),
            child: const Text('Open check'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open check'));
    await tester.pumpAndSettle();
  }

  Future<void> activate(WidgetTester tester, String id) async {
    for (
      var i = 0;
      i < 30 && FocusManager.instance.primaryFocus?.debugLabel != 'check-$id';
      i++
    ) {
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
    }
    expect(FocusManager.instance.primaryFocus?.debugLabel, 'check-$id');
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
  }

  testWidgets(
    'student check response stays pending and failures remain readable at 240x320 with large text',
    (tester) async {
      pending = Completer();
      await open(tester);
      await activate(tester, 'help');
      expect(calls, [('check_response', 'current', 'help')]);
      expect(find.textContaining('Waiting for confirmation.'), findsOneWidget);
      expect(find.textContaining('No response confirmed yet.'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(calls.length, 1);
      pending!.complete('Not confirmed. Refresh before trying again.');
      await tester.pumpAndSettle();
      expect(
        find.text('Not confirmed. Refresh before trying again.'),
        findsOneWidget,
      );
      expect(spoken.any((text) => text.contains('Not confirmed.')), isTrue);
      await activate(tester, 'read');
      await activate(tester, 'stop');
      await activate(tester, 'back');
      await tester.pumpAndSettle();
      expect(find.text('Open check'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'only confirmed responses display and closed checks disable answers',
    (tester) async {
      await open(tester);
      state.value = ClassroomCheckState.parse(
        json(responses: [response]),
        userId: 7,
        teacher: false,
      );
      await tester.pump();
      expect(
        find.textContaining('Your confirmed response: Need help.'),
        findsOneWidget,
      );
      state.value = const ClassroomCheckState(
        id: 'current',
        revision: 3,
        open: false,
      );
      await tester.pump();
      final help = tester.widget<OutlinedButton>(
        find.widgetWithText(OutlinedButton, 'Need help'),
      );
      expect(help.onPressed, isNull);
      expect(calls, isEmpty);
    },
  );
  testWidgets(
    'new teacher check confirms clearing previous responses and cancellation sends nothing',
    (tester) async {
      await open(tester, teacher: true);
      await activate(tester, 'open');
      await tester.pumpAndSettle();
      expect(find.text('Open a new classroom check?'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.digit1);
      await tester.pumpAndSettle();
      expect(calls, isEmpty);
      await activate(tester, 'open');
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.digit2);
      await tester.pumpAndSettle();
      expect(calls, [('open_check', 'current', null)]);
      expect(tester.takeException(), isNull);
    },
  );
}
