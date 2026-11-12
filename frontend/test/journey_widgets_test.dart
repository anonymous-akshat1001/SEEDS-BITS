import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/main.dart' show routeObserver;
import 'package:frontend/screens/journeys/journey_player_screen.dart';
import 'package:frontend/screens/journeys/journey_step_composer.dart';
import 'package:frontend/screens/journeys/student_journeys_screen.dart';
import 'package:frontend/screens/journeys/teacher_journeys_screen.dart';
import 'package:frontend/services/journey_api.dart';
import 'package:frontend/services/journey_audio.dart';
import 'package:frontend/services/journey_models.dart';
import 'package:frontend/services/offline_journey_store.dart';
import 'package:frontend/services/tts_service.dart';
import 'package:frontend/widgets/journey_menu.dart';
import 'package:frontend/widgets/key_instruction_wrapper.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'journey_engine_test.dart' show foodJourney;

class FakeAudio implements JourneyAudio {
  final played = <String>[];
  final _done = StreamController<void>.broadcast();
  bool _playing = false;

  void finish() {
    _playing = false;
    _done.add(null);
  }

  @override
  Stream<void> get completed => _done.stream;
  @override
  bool get playing => _playing;
  @override
  Object? get item => played.isEmpty ? null : played.last;
  @override
  Future<void> playUrl(String url) async {
    played.add(url);
    _playing = true;
  }

  @override
  Future<void> playFile(String path, {String? mimeType}) => playUrl(path);
  @override
  Future<void> pause() async => _playing = false;
  @override
  Future<void> resume() async => _playing = true;
  @override
  Future<void> stop() async => _playing = false;
  @override
  Future<void> seekBy(Duration delta) async {}
  @override
  Future<void> setRate(double rate) async {}
  @override
  Future<void> dispose() async {}
}

class FakeJourneyApi extends JourneyApi {
  FakeJourneyApi({this.teacher = const [], this.student = const [], this.offline = false});
  final List<JourneyDraft> teacher;
  final List<StudentJourneySummary> student;
  final bool offline;

  @override
  Future<List<JourneyDraft>> teacherJourneys(int classId, int subjectId) async =>
      teacher;

  @override
  Future<List<StudentJourneySummary>> studentJourneys() async {
    if (offline) {
      throw const JourneyApiException('No connection', network: true);
    }
    return student;
  }

  @override
  Future<({List<String> accepted, List<String> rejected})> sync(
    List<Map<String, dynamic>> runs,
  ) async => (accepted: <String>[], rejected: <String>[]);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final spoken = <String>[];

  setUp(() async {
    spoken.clear();
    SharedPreferences.setMockInitialValues({'user_id': 5});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('flutter_tts'), (
          call,
        ) async {
          if (call.method == 'speak') spoken.add(call.arguments.toString());
          return 1;
        });
    await TtsService.configure(
      enabled: true,
      mode: SpeechMode.selfVoicing,
      verbosity: SpeechVerbosity.standard,
    );
  });

  Widget app(Widget child) =>
      MaterialApp(navigatorObservers: [routeObserver], home: child);

  Future<void> press(WidgetTester tester, LogicalKeyboardKey key) async {
    await tester.sendKeyEvent(key);
    await tester.pumpAndSettle();
  }

  group('JourneyMenu', () {
    testWidgets(
      'back in a step builder returns to the previous prompt with entries kept',
      (tester) async {
        JourneyStep? result;
        var finished = false;
        await tester.pumpWidget(
          app(
            Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () async {
                    result = await JourneyStepComposer.poll(context);
                    finished = true;
                  },
                  child: const Text('Add poll'),
                ),
              ),
            ),
          ),
        );
        Future<void> type(String text) async {
          await tester.enterText(find.byType(TextField), text);
          await tester.tap(find.text('1: Continue'));
          await tester.pumpAndSettle();
        }

        Future<void> back() async {
          await tester.tap(find.text('0: Back'));
          await tester.pumpAndSettle();
        }

        String field() =>
            tester.widget<TextField>(find.byType(TextField)).controller!.text;

        await tester.tap(find.text('Add poll'));
        await tester.pumpAndSettle();
        await type('Did you eat rice?');
        await type('Yes');
        expect(find.text('Option 2'), findsWidgets);
        await back();
        expect(find.text('Option 1'), findsWidgets);
        expect(field(), 'Yes');
        await back();
        expect(find.text('Poll question'), findsWidgets);
        expect(field(), 'Did you eat rice?');
        expect(finished, isFalse, reason: 'Back stays inside the step.');

        await type('Did you eat rice?');
        await type('Yes');
        await type('No');
        // "Add option 3?": 2 is no more options; then 1 saves the step.
        await press(tester, LogicalKeyboardKey.digit2);
        expect(find.text('Check before saving'), findsWidgets);
        await press(tester, LogicalKeyboardKey.digit1);
        expect(finished, isTrue);
        expect(result?.text, 'Did you eat rice?');
        expect(result?.options, ['Yes', 'No']);
      },
    );

    test('never offers more than five numbered choices', () {
      expect(
        () => JourneyMenu(
          title: 'Too many',
          choices: List.generate(6, (i) => JourneyChoice('$i', () {})),
        ),
        throwsArgumentError,
      );
    });

    testWidgets('digits, D-pad and touch share one action; unavailable choices explain why', (
      tester,
    ) async {
      var opened = 0;
      await tester.pumpWidget(
        app(
          JourneyMenu(
            title: 'Journey',
            autoPlay: false,
            details: 'Three steps.',
            choices: [
              JourneyChoice('Open', () => opened++),
              JourneyChoice(
                'Publish',
                () => opened += 100,
                enabled: false,
                unavailableReason: 'Add a step first.',
              ),
            ],
          ),
        ),
      );
      await press(tester, LogicalKeyboardKey.digit1);
      expect(opened, 1);
      await press(tester, LogicalKeyboardKey.arrowDown);
      await press(tester, LogicalKeyboardKey.enter);
      expect(opened, 2);
      await tester.tap(find.text('1: Open'));
      expect(opened, 3);
      await press(tester, LogicalKeyboardKey.digit2);
      expect(opened, 3);
      expect(spoken.last, contains('Add a step first.'));
      await press(tester, LogicalKeyboardKey.digit8);
      expect(spoken.last, contains('Three steps.'));
      final wrapper = tester.widget<KeypadInstructionWrapper>(
        find.byType(KeypadInstructionWrapper),
      );
      expect(wrapper.interactionPolicy, KeypadInteractionPolicy.numbered);
      expect(
        wrapper.focusTargets.map((target) => target.label),
        ['1. Open', '2. Publish, unavailable', '8. Read details again', '0. Back'],
      );
    });
  });

  group('JourneyPlayerScreen', () {
    testWidgets(
      'plays content, asks the question, replays after a wrong answer and summarises',
      (tester) async {
        final audio = FakeAudio();
        await tester.pumpWidget(
          app(
            JourneyPlayerScreen(
              snapshot: foodJourney(),
              audio: audio,
              streamUrl: (id) async => 'stream/$id',
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(spoken.last, contains('Let us hear about food.'));
        expect(find.text('2: Next step'), findsOneWidget);

        await press(tester, LogicalKeyboardKey.digit2);
        expect(audio.played, ['stream/3']);
        expect(find.text('5: Play or pause'), findsOneWidget);

        audio.finish();
        await tester.pumpAndSettle();
        expect(spoken.last, contains('Which grain?'));
        expect(spoken.last, contains('Option 1: Rice.'));
        expect(find.text('5: Submit answer'), findsOneWidget);

        await press(tester, LogicalKeyboardKey.digit5);
        expect(spoken.last, contains('Choose an answer first'));
        await press(tester, LogicalKeyboardKey.digit2);
        expect(spoken.last, contains('Option 2, Stone, selected'));
        expect(find.text('2: Stone, selected'), findsOneWidget);
        await press(tester, LogicalKeyboardKey.digit5);
        expect(spoken.last, contains('Not quite. Let us listen'));
        expect(audio.played, ['stream/3', 'stream/3']);
        expect(find.textContaining('Listening again'), findsOneWidget);

        audio.finish();
        await tester.pumpAndSettle();
        expect(spoken.last, contains('Try again. 1 try left.'));
        await press(tester, LogicalKeyboardKey.digit1);
        await press(tester, LogicalKeyboardKey.digit5);
        expect(spoken.last, contains('Correct! Rice.'));
        expect(spoken.last, contains('Poll. There is no wrong answer.'));

        await press(tester, LogicalKeyboardKey.digit1);
        await press(tester, LogicalKeyboardKey.digit5);
        expect(spoken.last, contains('Thank you. Your answer is saved.'));
        await press(tester, LogicalKeyboardKey.digit3);
        await press(tester, LogicalKeyboardKey.digit5);
        expect(spoken.last, contains('You finished Food around us'));
        expect(spoken.last, contains('1 of 2 questions correctly on the first try'));
        expect(find.text('1: Play again'), findsOneWidget);
      },
    );

    testWidgets('leaving mid-journey asks for confirmation and 1 cancels', (
      tester,
    ) async {
      await tester.pumpWidget(
        app(
          JourneyPlayerScreen(
            snapshot: foodJourney(),
            audio: FakeAudio(),
            streamUrl: (id) async => 'stream/$id',
          ),
        ),
      );
      await tester.pumpAndSettle();
      await press(tester, LogicalKeyboardKey.digit0);
      expect(find.text('Leave this journey?'), findsOneWidget);
      await press(tester, LogicalKeyboardKey.digit1);
      expect(find.text('Leave this journey?'), findsNothing);
      expect(find.byType(JourneyPlayerScreen), findsOneWidget);
    });

    testWidgets('fits a 240 by 320 keypad phone at 1.5 times text', (tester) async {
      tester.view.physicalSize = const Size(240, 320);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final audio = FakeAudio();
      await tester.pumpWidget(
        MaterialApp(
          navigatorObservers: [routeObserver],
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(240, 320),
              textScaler: TextScaler.linear(1.5),
            ),
            child: JourneyPlayerScreen(
              snapshot: foodJourney(),
              audio: audio,
              streamUrl: (id) async => 'stream/$id',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await press(tester, LogicalKeyboardKey.digit2);
      audio.finish();
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  group('Journey home screens', () {
    testWidgets('student home works offline and points to downloads', (
      tester,
    ) async {
      final store = OfflineJourneyStore(
        root: Directory.systemTemp.createTempSync('student-journeys'),
        userId: 5,
        media: _NoMedia(),
      );
      await tester.runAsync(() async {
        await tester.pumpWidget(
          app(
            StudentJourneysScreen(
              api: FakeJourneyApi(offline: true),
              openStore: () async => store,
            ),
          ),
        );
        await Future<void>.delayed(const Duration(milliseconds: 200));
      });
      await tester.pumpAndSettle();
      expect(find.textContaining('No internet. Downloaded journeys still work'), findsOneWidget);
      await press(tester, LogicalKeyboardKey.digit2);
      expect(spoken.last, contains('This needs internet'));
      await press(tester, LogicalKeyboardKey.digit5);
      expect(spoken.last, contains('Nothing is downloaded'));
    });

    testWidgets('teacher home counts journeys by status', (tester) async {
      final draft = JourneyDraft.parse({
        'journey_id': 1,
        'class_id': 1,
        'subject_id': 2,
        'title': 'Food around us',
        'status': 'draft',
        'revision': 1,
        'steps': [],
      });
      await tester.pumpWidget(
        app(
          TeacherJourneysScreen(
            classId: 1,
            subjectId: 2,
            workspaceName: 'Class 3, Environment',
            api: FakeJourneyApi(teacher: [draft]),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('2: Drafts, 1'), findsOneWidget);
      expect(find.text('3: Published, 0 (unavailable)'), findsOneWidget);
      await press(tester, LogicalKeyboardKey.digit3);
      expect(spoken.last, contains('Nothing is published yet.'));
      await press(tester, LogicalKeyboardKey.digit2);
      expect(find.textContaining('Food around us. Draft, not yet published'), findsWidgets);
    });
  });
}

class _NoMedia implements JourneyMediaStore {
  @override
  Future<Set<int>> completeIds() async => {};
  @override
  Future<void> download(int audioId, dynamic operation) async {}
  @override
  Future<String> localPath(int audioId) async => '';
  @override
  Future<void> remove(int audioId) async {}
}
