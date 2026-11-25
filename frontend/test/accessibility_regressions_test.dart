import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/main.dart' show routeObserver;
import 'package:frontend/screens/audio_library_screen.dart';
import 'package:frontend/screens/login_screen.dart';
import 'package:frontend/screens/quiz_screens.dart';
import 'package:frontend/screens/teacher_dashboard.dart';
import 'package:frontend/services/tts_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> focus(WidgetTester tester, String label) async {
  for (
    var i = 0;
    i < 60 && FocusManager.instance.primaryFocus?.debugLabel != label;
    i++
  ) {
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
  }
  expect(FocusManager.instance.primaryFocus?.debugLabel, label);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final spoken = <String>[];
  setUp(() async {
    spoken.clear();
    SharedPreferences.setMockInitialValues({
      'token': 'test-token',
      'user_id': 7,
      'role': 'teacher',
      'user_name': 'Teacher',
    });
    dotenv.testLoad(fileInput: 'API_BASE_URL=https://example.test');
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(const MethodChannel('flutter_tts'), (
      call,
    ) async {
      if (call.method == 'speak') {
        final arguments = call.arguments;
        spoken.add(
          arguments is Map ? arguments['text'] as String : arguments as String,
        );
      }
      return 1;
    });
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
    await TtsService.configure(enabled: true, mode: SpeechMode.selfVoicing);
  });
  tearDown(TtsService.stop);

  Future<void> open(WidgetTester tester, Widget screen) async {
    await tester.pumpWidget(
      MaterialApp(navigatorObservers: [routeObserver], home: screen),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'phone focus is spoken before any typing and delayed help does not overwrite it',
    (tester) async {
      await open(tester, const LoginScreen());
      await tester.pump(const Duration(seconds: 1));
      // The number field is focused at once, so typing can start at once.
      expect(FocusManager.instance.primaryFocus?.debugLabel, 'login-phone');
      expect(spoken.join(' '), contains('Phone number'));
      expect(
        tester.widget<TextField>(find.byType(TextField).first).controller!.text,
        isEmpty,
      );
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  Map<String, dynamic> teacherHome({
    bool canStart = true,
    int workspaces = 1,
  }) => {
    'role': 'teacher',
    'live_class': null,
    'today': [
      {
        'entry_id': 5,
        'occurrence_date': '2026-11-16',
        'class_id': 1,
        'class_name': 'Class 6',
        'subject_id': 2,
        'subject_name': 'English',
        'start_clock': '09:00',
        'end_clock': '09:40',
        'opens_at': '2026-11-16T03:20:00Z',
        'status': canStart ? 'open' : 'upcoming',
        'can_start': canStart,
      },
    ],
    'workspaces': [
      for (var i = 1; i <= workspaces; i++)
        {
          'assignment_id': i,
          'class_id': i,
          'class_name': 'Class $i',
          'subject_id': 2,
          'subject_name': 'English',
        },
    ],
  };

  testWidgets(
    'teacher home starts the timetabled class with one key, has no title, list or refresh, and 0 asks before logging out',
    (tester) async {
      final requests = <http.Request>[];
      await http.runWithClient(
        () async {
          await open(tester, const TeacherDashboard());
          expect(find.text('1: Start English, Class 6'), findsOneWidget);
          expect(find.byType(TextField), findsNothing);
          expect(find.textContaining('Refresh'), findsNothing);
          expect(spoken.join(' '), contains('English, Class 6 is ready'));

          await tester.sendKeyEvent(LogicalKeyboardKey.digit1);
          await tester.pumpAndSettle();
          final start = requests.where((r) => r.url.path == '/classes/start');
          expect(start, hasLength(1));
          expect(jsonDecode(start.single.body), {
            'entry_id': 5,
            'occurrence_date': '2026-11-16',
          });

          await tester.sendKeyEvent(LogicalKeyboardKey.digit0);
          await tester.pumpAndSettle();
          expect(find.text('Log out of SEEDS?'), findsOneWidget);
          await tester.sendKeyEvent(LogicalKeyboardKey.digit1);
          await tester.pumpAndSettle();
          expect(find.byType(TeacherDashboard), findsOneWidget);
          await tester.pumpWidget(const SizedBox.shrink());
        },
        () => MockClient((request) async {
          requests.add(request);
          if (request.url.path == '/classes/start') {
            return http.Response(
              jsonEncode({
                'created': true,
                'live_class': {
                  'session_id': 9,
                  'subject_name': 'English',
                  'class_name': 'Class 6',
                },
              }),
              200,
            );
          }
          return http.Response(jsonEncode(teacherHome()), 200);
        }),
      );
    },
  );

  testWidgets(
    'teacher home reads every key and what the administrator did, once',
    (tester) async {
      final seen = <Object?>[];
      await http.runWithClient(
        () async {
          await open(tester, const TeacherDashboard());
          final arrival = spoken.join(' ');
          expect(arrival, contains('English, Class 6 is ready'));
          expect(
            arrival,
            contains('Your administrator published quiz Plants.'),
          );
          expect(
            arrival,
            contains('Your administrator added lesson English, Class 7.'),
          );
          expect(arrival, contains('Press 1 for'));
          for (final key in ['2', '3', '4', '5', '0']) {
            expect(arrival, contains(', $key for'));
          }
          expect(seen, [
            {
              'notice_ids': [4, 5],
            },
          ]);
          await tester.pumpWidget(const SizedBox.shrink());
        },
        () => MockClient((request) async {
          if (request.url.path == '/me/notices/seen') {
            seen.add(jsonDecode(request.body));
            return http.Response('{"ok":true,"seen":1}', 200);
          }
          return http.Response(
            jsonEncode({
              ...teacherHome(),
              'admin_notices': seen.isEmpty
                  ? [
                      {
                        'notice_id': 4,
                        'kind': 'quiz',
                        'title': 'Plants',
                        'action': 'published',
                      },
                      {
                        'notice_id': 5,
                        'kind': 'lesson',
                        'title': 'English, Class 7',
                        'action': 'created',
                        'actor_role': 'admin',
                        'actor_name': 'Mrs Admin',
                      },
                    ]
                  : [],
            }),
            200,
          );
        }),
      );
    },
  );

  testWidgets(
    'a class that cannot start yet says when it can, without starting',
    (tester) async {
      final requests = <String>[];
      await http.runWithClient(
        () async {
          await open(tester, const TeacherDashboard());
          expect(
            find.text('1: Next: English, Class 6 at 09:00'),
            findsOneWidget,
          );
          await tester.sendKeyEvent(LogicalKeyboardKey.digit1);
          await tester.pumpAndSettle();
          expect(spoken.last, contains('You can start it from'));
          expect(requests, isNot(contains('/classes/start')));
          await tester.pumpWidget(const SizedBox.shrink());
        },
        () => MockClient((request) async {
          requests.add(request.url.path);
          return http.Response(jsonEncode(teacherHome(canStart: false)), 200);
        }),
      );
    },
  );

  testWidgets('changing class and subject is a numbered choice under More', (
    tester,
  ) async {
    await http.runWithClient(
      () async {
        await open(tester, const TeacherDashboard());
        await tester.sendKeyEvent(LogicalKeyboardKey.digit5);
        await tester.pumpAndSettle();
        expect(
          find.text('2: Change class and subject for lessons'),
          findsOneWidget,
        );
        await tester.sendKeyEvent(LogicalKeyboardKey.digit2);
        await tester.pumpAndSettle();
        expect(find.byType(DropdownButtonFormField<int>), findsNothing);
        expect(find.textContaining('1: English, Class 1'), findsOneWidget);
        await tester.sendKeyEvent(LogicalKeyboardKey.digit1);
        await tester.pumpAndSettle();
        expect(
          spoken.join(' '),
          contains('Lessons, quizzes and playlists are for English, Class 1'),
        );
        await tester.pumpWidget(const SizedBox.shrink());
      },
      () => MockClient(
        (request) async =>
            http.Response(jsonEncode(teacherHome(workspaces: 6)), 200),
      ),
    );
  });

  for (final hasClasses in [false, true]) {
    testWidgets(
      'library key 5 focuses active sessions without opening recordings; classes=$hasClasses',
      (tester) async {
        await http.runWithClient(
          () async {
            await open(tester, const OfflineAudioLibraryScreen());
            await tester.sendKeyEvent(LogicalKeyboardKey.digit5);
            await tester.pumpAndSettle();
            expect(find.byType(OfflineAudioLibraryScreen), findsOneWidget);
            expect(find.byType(ClassAudioScreen), findsNothing);
            if (hasClasses) {
              expect(
                FocusManager.instance.primaryFocus?.debugLabel,
                'recorded-library-session-11',
              );
              expect(spoken.last, contains('D-pad up and down'));
              await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
              await tester.pumpAndSettle();
              expect(
                FocusManager.instance.primaryFocus?.debugLabel,
                'recorded-library-session-12',
              );
            } else {
              expect(spoken.last, contains('no active classes'));
            }
            await tester.pumpWidget(const SizedBox.shrink());
            await TtsService.stop();
          },
          () => MockClient(
            (request) async => http.Response(
              jsonEncode([
                if (hasClasses) ...[
                  {'session_id': 11, 'title': 'First class', 'created_by': 7},
                  {'session_id': 12, 'title': 'Second class', 'created_by': 7},
                ],
              ]),
              200,
            ),
          ),
        );
      },
    );
  }

  testWidgets(
    'correct-answer cycling announces every option and real keypad editing preserves 0 and 1',
    (tester) async {
      await open(tester, const AccessibleQuestionEditorDialog());
      final question = find.widgetWithText(TextField, 'Question text');
      await tester.enterText(question, 'Question 0 1');
      await tester.sendKeyEvent(LogicalKeyboardKey.digit0);
      await tester.sendKeyEvent(LogicalKeyboardKey.digit1);
      expect(find.byType(AccessibleQuestionEditorDialog), findsOneWidget);
      expect(
        tester.widget<TextField>(question).controller!.text,
        'Question 0 1',
      );
      await focus(tester, 'bank-question-correct-answer');
      spoken.clear();
      for (var option = 1; option <= 4; option++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.pump();
        expect(
          spoken.last,
          contains('Option $option selected as correct answer'),
        );
      }
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      expect(spoken.last, contains('Option 3 selected as correct answer'));
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
