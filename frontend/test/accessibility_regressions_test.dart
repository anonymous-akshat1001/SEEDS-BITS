import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/main.dart' show routeObserver;
import 'package:frontend/screens/admin_dashboard.dart';
import 'package:frontend/screens/audio_library_screen.dart';
import 'package:frontend/screens/lesson_sequences_screen.dart';
import 'package:frontend/screens/login_screen.dart';
import 'package:frontend/screens/quiz_screens.dart';
import 'package:frontend/screens/register_screen.dart';
import 'package:frontend/screens/teacher_dashboard.dart';
import 'package:frontend/services/tts_service.dart';
import 'package:frontend/widgets/key_instruction_wrapper.dart';
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
      spoken.clear();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump(const Duration(seconds: 1));
      expect(spoken.last, contains('Phone number field'));
      expect(
        tester.widget<TextField>(find.byType(TextField).first).controller!.text,
        isEmpty,
      );
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'stale admin filter responses cannot erase the current failure or steal focus',
    (tester) async {
      final student = Completer<http.Response>();
      final teacher = Completer<http.Response>();
      await http.runWithClient(
        () async {
          await open(tester, const AdminDashboard());
          await focus(tester, 'admin-account-type-filter');
          await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
          await tester.pump();
          await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
          await tester.pump();
          teacher.complete(http.Response('{"detail":"Unavailable"}', 503));
          await tester.pumpAndSettle();
          expect(
            find.textContaining('Administration data was not refreshed'),
            findsOneWidget,
          );
          expect(spoken.last, contains('Teachers only'));
          expect(
            FocusManager.instance.primaryFocus?.debugLabel,
            'admin-account-type-filter',
          );
          student.complete(http.Response('[]', 200));
          await tester.pumpAndSettle();
          expect(
            find.textContaining('Administration data was not refreshed'),
            findsOneWidget,
          );
          expect(find.text('No matching accounts.'), findsNothing);
          expect(
            FocusManager.instance.primaryFocus?.debugLabel,
            'admin-account-type-filter',
          );
          await tester.pumpWidget(const SizedBox.shrink());
        },
        () => MockClient((request) async {
          if (request.url.path == '/admin/users') {
            switch (request.url.queryParameters['role']) {
              case 'student':
                return student.future;
              case 'teacher':
                return teacher.future;
            }
          }
          return http.Response('[]', 200);
        }),
      );
    },
  );

  testWidgets('registration key 3 toggles the role and is visible and spoken', (
    tester,
  ) async {
    await open(tester, const RegisterScreen());
    await tester.sendKeyEvent(LogicalKeyboardKey.digit3);
    await tester.pumpAndSettle();
    expect(
      find.text('3: Register as Teacher. Change account type'),
      findsOneWidget,
    );
    expect(spoken.last.toLowerCase(), contains('teacher'));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 350)),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.digit3);
    await tester.pumpAndSettle();
    expect(
      find.text('3: Register as Student. Change account type'),
      findsOneWidget,
    );
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'admin filters stay mounted, retain keypad focus and announce the new button state',
    (tester) async {
      final pending = Completer<http.Response>();
      await http.runWithClient(
        () async {
          await open(tester, const AdminDashboard());
          await focus(tester, 'admin-account-type-filter');
          await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
          await tester.pump();
          expect(
            FocusManager.instance.primaryFocus?.debugLabel,
            'admin-account-type-filter',
          );
          expect(find.byType(TextField), findsOneWidget);
          pending.complete(http.Response('[]', 200));
          await tester.pumpAndSettle();
          expect(
            FocusManager.instance.primaryFocus?.debugLabel,
            'admin-account-type-filter',
          );
          expect(
            spoken.last,
            contains('Account type filter button. Students only.'),
          );
          await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
          await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
          await tester.pumpAndSettle();
          expect(
            FocusManager.instance.primaryFocus?.debugLabel,
            'admin-assignment-filter',
          );
          expect(spoken.last, contains('Assignment filter button. Enrolled.'));
          await tester.sendKeyEvent(LogicalKeyboardKey.digit7);
          await tester.pumpAndSettle();
          await tester.sendKeyEvent(LogicalKeyboardKey.digit2);
          await tester.pumpAndSettle();
          expect(find.text('Classes'), findsOneWidget);
          expect(find.text('Accounts'), findsNothing);
          expect(find.text('Subjects'), findsNothing);
          await tester.pumpWidget(const SizedBox.shrink());
        },
        () => MockClient((request) async {
          if (request.url.queryParameters['role'] == 'student' &&
              request.url.queryParameters['assignment_status'] == 'all') {
            return pending.future;
          }
          return http.Response('[]', 200);
        }),
      );
    },
  );

  testWidgets('workspace selection is numbered, paged, and has no dropdown', (
    tester,
  ) async {
    await http.runWithClient(
      () async {
        await open(tester, const TeacherDashboard());
        expect(find.byType(DropdownButtonFormField<int>), findsNothing);
        await tester.sendKeyEvent(LogicalKeyboardKey.digit7);
        await tester.pumpAndSettle();
        expect(find.textContaining('1: Class 1, English'), findsOneWidget);
        expect(find.textContaining('Class 6, English'), findsNothing);
        for (final instruction in [
          'Press 6 for list options',
          'Press 7 for the previous page',
          'Press 8 to search all items',
          'Press 9 for the next page',
          'Press 0 to go back',
          'D-pad up and down',
        ]) {
          expect(spoken.join(' '), contains(instruction));
        }
        await tester.sendKeyEvent(LogicalKeyboardKey.digit9);
        await tester.pumpAndSettle();
        await tester.sendKeyEvent(LogicalKeyboardKey.digit1);
        await tester.pumpAndSettle();
        expect(
          find.text('7: Class 6, English. Change workspace'),
          findsOneWidget,
        );
        expect(spoken.join(' '), contains('Class 6, English selected'));
        await tester.pumpWidget(const SizedBox.shrink());
      },
      () => MockClient(
        (request) async => http.Response(
          jsonEncode(
            request.url.path == '/me/access-context'
                ? {
                    'teacher_workspaces': [
                      for (var i = 1; i <= 6; i++)
                        {
                          'assignment_id': i,
                          'class_id': i,
                          'subject_id': 2,
                          'class_name': 'Class $i',
                          'subject_name': 'English',
                        },
                    ],
                  }
                : [],
          ),
          200,
        ),
      ),
    );
  });

  for (final section in [
    (LogicalKeyboardKey.digit2, 'classes', 'Create Class'),
    (LogicalKeyboardKey.digit3, 'subjects', 'Create Subject'),
  ]) {
    testWidgets(
      'administration ${section.$2} help names only that section controls',
      (tester) async {
        await http.runWithClient(() async {
          await open(tester, const AdminDashboard());
          await tester.sendKeyEvent(LogicalKeyboardKey.digit7);
          await tester.pumpAndSettle();
          await tester.sendKeyEvent(section.$1);
          await tester.pumpAndSettle();
          await tester.pump(const Duration(milliseconds: 600));
          expect(spoken.last, contains('${section.$2} section'));
          expect(spoken.last, contains(section.$3));
          expect(spoken.last, isNot(contains('Account Type Filter')));
          spoken.clear();
          await tester.sendKeyEvent(LogicalKeyboardKey.numpadMultiply);
          await tester.pumpAndSettle();
          expect(spoken.last, contains('${section.$2} section'));
          expect(spoken.last, contains(section.$3));
          await tester.pumpWidget(const SizedBox.shrink());
        }, () => MockClient((_) async => http.Response('[]', 200)));
      },
    );
  }

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
    'missing lesson routes show an actionable error and cannot submit a null workspace',
    (tester) async {
      var mutations = 0;
      await http.runWithClient(
        () async {
          await open(
            tester,
            const LessonSequencesScreen(classId: 1, subjectId: 2),
          );
          expect(
            find.textContaining('teacher-sequences backend routes'),
            findsOneWidget,
          );
          final wrapper = tester.widget<KeypadInstructionWrapper>(
            find.byType(KeypadInstructionWrapper),
          );
          final create = wrapper.focusTargets.singleWhere(
            (target) => target.node.debugLabel == 'sequence-create',
          );
          expect(create.enabled, isTrue);
          create.onActivate!();
          await tester.pumpAndSettle();
          expect(spoken.last, contains('Create lesson plan is unavailable'));
          expect(mutations, 0);
          await tester.pumpWidget(const SizedBox.shrink());
        },
        () => MockClient((request) async {
          if (request.method != 'GET') mutations++;
          return http.Response('{"detail":"Not Found"}', 404);
        }),
      );
    },
  );

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
