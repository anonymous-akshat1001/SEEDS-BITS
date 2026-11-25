import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/services/class_alerts.dart';
import 'package:frontend/main.dart' show routeObserver;
import 'package:frontend/services/feedback_cues.dart';
import 'package:frontend/services/message_center.dart';
import 'package:frontend/services/tts_service.dart';
import 'package:frontend/services/undo_service.dart';
import 'package:frontend/utils/spoken_format.dart';
import 'package:frontend/widgets/journey_menu.dart';
import 'package:frontend/widgets/key_instruction_wrapper.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final spoken = <String>[];
  final vibrations = <List<Object?>>[];

  setUp(() async {
    spoken.clear();
    vibrations.clear();
    FeedbackCues.played.clear();
    MessageCenter.clear();
    UndoService.reset();
    SharedPreferences.setMockInitialValues({});
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(const MethodChannel('flutter_tts'), (
      call,
    ) async {
      if (call.method == 'speak') spoken.add(call.arguments.toString());
      return 1;
    });
    messenger.setMockMethodCallHandler(const MethodChannel('seeds/feedback'), (
      call,
    ) async {
      vibrations.add((call.arguments as Map)['pattern'] as List<Object?>);
      return null;
    });
    await TtsService.configure(
      enabled: true,
      mode: SpeechMode.selfVoicing,
      verbosity: SpeechVerbosity.standard,
    );
  });

  group('SpokenFormat', () {
    test('reads phone numbers and identifiers digit by digit', () {
      expect(
        SpokenFormat.phone('+91 98765 43210'),
        'plus 9 1 9 8 7, 6 5 4 3 2, 1 0',
      );
      expect(SpokenFormat.session(42), 'session four two');
    });

    test('reads times of day and dates naturally', () {
      final now = DateTime(2026, 11, 11, 9);
      expect(
        SpokenFormat.timeOfDay(DateTime(2026, 1, 1, 10, 30)),
        '10:30 in the morning',
      );
      expect(SpokenFormat.timeOfDay(DateTime(2026, 1, 1, 12)), '12 noon');
      expect(
        SpokenFormat.timeOfDay(DateTime(2026, 1, 1, 15, 5)),
        '3:05 in the afternoon',
      );
      expect(
        SpokenFormat.dateTime(DateTime(2026, 11, 12, 18), now: now),
        "tomorrow at 6 o'clock in the evening",
      );
      expect(
        SpokenFormat.dateTime(DateTime(2026, 11, 16, 8), now: now),
        "Monday 16 November at 8 o'clock in the morning",
      );
    });

    test('reads durations in words', () {
      expect(
        SpokenFormat.duration(const Duration(seconds: 130)),
        '2 minutes 10 seconds',
      );
      expect(
        SpokenFormat.duration(const Duration(minutes: 65, seconds: 9)),
        '1 hour 5 minutes',
      );
      expect(SpokenFormat.duration(const Duration(seconds: 1)), '1 second');
      expect(
        SpokenFormat.position(
          const Duration(seconds: 65),
          const Duration(minutes: 4),
        ),
        '1 minute 5 seconds of 4 minutes',
      );
    });
  });

  group('Cues and messages', () {
    test(
      'errors play the error cue with two buzzes and stay readable',
      () async {
        MessageCenter.error('Upload failed.');
        await Future<void>.delayed(Duration.zero);
        expect(FeedbackCues.played, [Cue.error]);
        expect(vibrations.single, [60, 120, 60]);
        expect(MessageCenter.spoken(), 'Last problem: Upload failed.');
      },
    );

    test('leaving uses one long buzz; cues can be turned off', () async {
      await FeedbackCues.play(Cue.leave);
      expect(vibrations.single, [450]);
      await FeedbackCues.setVibrationEnabled(false);
      await FeedbackCues.play(Cue.ok);
      expect(vibrations, hasLength(1));
      await FeedbackCues.setVibrationEnabled(true);
    });
  });

  group('Keypad wrapper', () {
    Widget screen({VoidCallback? onOne}) => MaterialApp(
      navigatorObservers: [routeObserver],
      home: _Probe(onOne: onOne),
    );

    testWidgets(
      'star reads screen, focused item, state, last message, then keys',
      (tester) async {
        await tester.pumpWidget(screen());
        await tester.pumpAndSettle();
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pumpAndSettle();
        MessageCenter.show('Saved draft.', speak: false);
        await tester.sendKeyEvent(LogicalKeyboardKey.numpadMultiply);
        await tester.pumpAndSettle();
        final help = spoken.last;
        final order = [
          'Probe screen.',
          'Focused: First',
          'Muted. Hand raised.',
          'Last message: Saved draft.',
          'Press 1 for Do one',
          'Use the direction keys',
        ].map(help.indexOf).toList();
        expect(order.every((index) => index >= 0), isTrue, reason: help);
        expect(order, [...order]..sort());
        // No text field on this screen, so no editing instructions.
        expect(help, isNot(contains('editing')));
      },
    );

    testWidgets(
      'opening reads every key; coming back reads the main ones and points to star',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            navigatorObservers: [routeObserver],
            home: Builder(
              builder: (context) => KeypadInstructionWrapper(
                interactionPolicy: KeypadInteractionPolicy.numbered,
                screenName: 'Home',
                brief: 'English is live.',
                labels: const {1: 'Open details', 2: 'Do two', 5: 'Do five'},
                actions: {
                  1: () => Navigator.of(context).push<void>(
                    MaterialPageRoute(
                      builder: (_) => const Scaffold(body: Text('Details')),
                    ),
                  ),
                  2: () {},
                  5: () {},
                },
                child: const Scaffold(body: Text('Home')),
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pumpAndSettle();
        final opening = spoken.join(' ');
        expect(
          opening,
          contains(
            'Home. English is live. Press 1 for Open details, 2 for Do two, '
            '5 for Do five. Press star for help.',
          ),
        );
        // The first screen has nowhere to go back to, so 0 is not offered.
        expect(opening, isNot(contains('0 for Back')));
        expect(opening, isNot(contains('hash')));
        expect(opening, isNot(contains('editing')));
        await tester.sendKeyEvent(LogicalKeyboardKey.digit1);
        await tester.pumpAndSettle();
        spoken.clear();
        tester.state<NavigatorState>(find.byType(Navigator)).pop();
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pumpAndSettle();
        expect(
          spoken.last,
          endsWith(
            'Home. English is live. Press 1 for Open details, 2 for Do two. '
            'Press star for all keys.',
          ),
        );
      },
    );

    testWidgets(
      'a menu that is still loading says so, and reads its choices only once loaded',
      (tester) async {
        var busy = true;
        late StateSetter update;
        await tester.pumpWidget(
          MaterialApp(
            navigatorObservers: [routeObserver],
            home: StatefulBuilder(
              builder: (context, setState) {
                update = setState;
                return JourneyMenu(
                  title: 'Journeys',
                  busy: busy,
                  status: busy ? '0 new.' : '2 new.',
                  choices: [JourneyChoice('Leaves', () {})],
                );
              },
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 600));
        expect(spoken.join(' '), contains('Journeys. Working, please wait.'));
        expect(spoken.join(' '), isNot(contains('0 new')));
        update(() => busy = false);
        await tester.pump(const Duration(milliseconds: 600));
        expect(spoken.last, contains('2 new.'));
        expect(spoken.last, contains('Press 1 for Leaves'));
        expect(spoken.join(' '), isNot(contains('0 new')));
      },
    );

    testWidgets(
      '8 repeats the last message; wrapping plays the end-of-list cue',
      (tester) async {
        await tester.pumpWidget(screen());
        await tester.pumpAndSettle();
        MessageCenter.show('Class started.', speak: false);
        await tester.sendKeyEvent(LogicalKeyboardKey.digit8);
        await tester.pumpAndSettle();
        expect(spoken.last, 'Last message: Class started.');
        for (var i = 0; i < 3; i++) {
          await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
          await tester.pumpAndSettle();
        }
        expect(FeedbackCues.played, contains(Cue.endOfList));
        expect(spoken.last, startsWith('End of list.'));
      },
    );

    testWidgets(
      '1 undoes a pending removal before the screen action, then commits otherwise',
      (tester) async {
        var screenOne = 0;
        var undone = 0;
        var committed = 0;
        await tester.pumpWidget(screen(onOne: () => screenOne++));
        await tester.pumpAndSettle();
        await UndoService.offer(
          done: 'Removed step 2.',
          undo: () => undone++,
          commit: () => committed++,
        );
        expect(
          MessageCenter.last.value!.text,
          contains('Press 1 within 10 seconds to undo'),
        );
        await tester.sendKeyEvent(LogicalKeyboardKey.digit1);
        await tester.pumpAndSettle();
        expect((undone, screenOne, committed), (1, 0, 0));
        await tester.sendKeyEvent(LogicalKeyboardKey.digit1);
        await tester.pumpAndSettle();
        expect(screenOne, 1);

        await UndoService.offer(
          done: 'Removed.',
          undo: () => undone++,
          commit: () => committed++,
        );
        await tester.pump(const Duration(seconds: 11));
        expect((undone, committed), (1, 1));
      },
    );
  });

  test('a late class alert rings only for what is left of its minute', () {
    final ringUntil = DateTime.utc(2026, 11, 16, 3, 31);
    final alert = ClassAlert.parse({
      'type': 'class_alert',
      'session_id': '42',
      'alert_id': 'a1',
      'ring_until': '${ringUntil.millisecondsSinceEpoch}',
    })!;
    expect(alert.sessionId, 42);
    expect(
      alert.remaining(ringUntil.subtract(const Duration(seconds: 15))),
      const Duration(seconds: 15),
    );
    expect(
      alert.remaining(ringUntil.add(const Duration(minutes: 5))),
      Duration.zero,
    );
    expect(ClassAlert.parse({'type': 'quiz_published'}), isNull);
  });

  for (final key in [LogicalKeyboardKey.digit1, LogicalKeyboardKey.digit0]) {
    testWidgets(
      'the ringing class alert joins with 1 and stops with 0: ${key.keyLabel}',
      (tester) async {
        bool? result;
        await tester.pumpWidget(
          MaterialApp(
            navigatorObservers: [routeObserver],
            home: Builder(
              builder: (context) => TextButton(
                onPressed: () async => result = await showDialog<bool>(
                  context: context,
                  builder: (_) => const ClassAlertDialog(
                    subject: 'English',
                    remaining: Duration(seconds: 60),
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        );
        await tester.tap(find.text('open'));
        await tester.pump(const Duration(seconds: 1));
        expect(spoken.join(' '), contains('English class has started'));
        await tester.sendKeyEvent(key);
        await tester.pumpAndSettle();
        expect(result, key == LogicalKeyboardKey.digit1);
      },
    );
  }

  testWidgets('the class alert closes by itself when the ringing ends', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => showDialog<bool>(
              context: context,
              builder: (_) =>
                  const ClassAlertDialog(remaining: Duration(seconds: 5)),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(ClassAlertDialog), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    expect(find.byType(ClassAlertDialog), findsNothing);
  });
}

class _Probe extends StatefulWidget {
  const _Probe({this.onOne});
  final VoidCallback? onOne;
  @override
  State<_Probe> createState() => _ProbeState();
}

class _ProbeState extends State<_Probe> {
  final _first = FocusNode(debugLabel: 'probe-first');
  final _second = FocusNode(debugLabel: 'probe-second');

  @override
  void dispose() {
    _first.dispose();
    _second.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => KeypadInstructionWrapper(
    interactionPolicy: KeypadInteractionPolicy.numbered,
    screenName: 'Probe screen',
    autoPlay: false,
    labels: const {1: 'Do one'},
    actions: {1: () => widget.onOne?.call()},
    stateSummary: () => 'Muted. Hand raised.',
    focusTargets: [
      KeypadFocusTarget(node: _first, label: 'First', onActivate: () {}),
      KeypadFocusTarget(node: _second, label: 'Second', onActivate: () {}),
    ],
    child: Scaffold(
      body: Column(
        children: [
          TextButton(
            focusNode: _first,
            onPressed: () {},
            child: const Text('First'),
          ),
          TextButton(
            focusNode: _second,
            onPressed: () {},
            child: const Text('Second'),
          ),
        ],
      ),
    ),
  );
}
