import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/screens/quiz_screens.dart';
import 'package:frontend/services/tts_service.dart';
import 'package:frontend/widgets/key_instruction_wrapper.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

Map<String, dynamic> question(int id) => {
  'question_id': id,
  'quiz_question_id': id,
  'source_question_id': id,
  'question_text': 'Question $id',
  'position': id,
  'revision': 1,
  'options': [
    for (var i = 0; i < 4; i++)
      {
        'quiz_option_id': id * 10 + i,
        'option_text': 'Answer ${i + 1}',
        'is_correct': i == 1,
        'position': i,
      },
  ],
};

Map<String, dynamic> draft(List<Map<String, dynamic>> questions) => {
  'quiz_id': 3,
  'class_id': 1,
  'subject_id': 2,
  'title': 'New class quiz',
  'mode': 'graded',
  'status': 'draft',
  'question_count': questions.length,
  'questions': questions,
  'attempt_limit': 1,
  'feedback_policy': 'after_completion',
  'shuffle_questions': false,
  'shuffle_options': false,
};

Future<void> activate(WidgetTester tester, String label) async {
  for (
    var i = 0;
    i < 80 && FocusManager.instance.primaryFocus?.debugLabel != label;
    i++
  ) {
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
  }
  expect(FocusManager.instance.primaryFocus?.debugLabel, label);
  await tester.sendKeyEvent(LogicalKeyboardKey.enter);
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'token': 'test-token',
      'user_id': 7,
    });
    dotenv.testLoad(fileInput: 'API_BASE_URL=https://example.test');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('flutter_tts'),
          (_) async => 1,
        );
    await TtsService.configure(enabled: false);
  });
  tearDown(TtsService.stop);

  testWidgets('key 4 creates explicitly untimed ungraded practice', (
    tester,
  ) async {
    var saved = draft([]);
    Map<String, dynamic>? submitted;
    await http.runWithClient(
      () async {
        await tester.pumpWidget(
          const MaterialApp(
            home: TeacherQuizScreen(
              classId: 1,
              subjectId: 2,
              className: 'Class',
              subjectName: 'English',
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.sendKeyEvent(LogicalKeyboardKey.digit4);
        await tester.pumpAndSettle();
        expect(find.byType(AccessibleQuizEditorDialog), findsOneWidget);
        await tester.enterText(
          find.widgetWithText(TextField, 'Quiz title'),
          'Practice numbers',
        );
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.sendKeyEvent(LogicalKeyboardKey.digit8);
        await tester.pumpAndSettle();
        expect(submitted?['mode'], 'practice');
        expect(submitted?['time_limit_minutes'], isNull);
        expect(submitted?['attempt_limit'], 1);
        expect(submitted?['feedback_policy'], 'immediate');
        expect(find.text('Step 2: Add questions'), findsOneWidget);
        await tester.pumpWidget(const SizedBox.shrink());
      },
      () => MockClient((request) async {
        if (request.url.path == '/question-bank') {
          return http.Response('[]', 200);
        }
        if (request.method == 'POST') {
          submitted = jsonDecode(request.body) as Map<String, dynamic>;
          saved = {...saved, ...submitted!};
        }
        return http.Response(
          jsonEncode(
            request.url.path == '/teacher/quizzes' && request.method == 'GET'
                ? [saved]
                : saved,
          ),
          200,
        );
      }),
    );
  });

  for (final bankFails in [false, true]) {
    testWidgets(
      'step 2 refreshes saved bank questions before selection; bankFails=$bankFails',
      (tester) async {
        var reads = 0;
        var additions = 0;
        var saved = draft([]);
        await http.runWithClient(
          () async {
            await tester.pumpWidget(
              MaterialApp(
                home: GuidedQuizDraftScreen(
                  quizId: 3,
                  classId: 1,
                  subjectId: 2,
                  onPublish: (_) async {},
                ),
              ),
            );
            await tester.pumpAndSettle();
            await tester.sendKeyEvent(LogicalKeyboardKey.digit3);
            await tester.pumpAndSettle();
            expect(reads, 2);
            if (bankFails) {
              expect(
                find.textContaining('No question was added.'),
                findsOneWidget,
              );
              expect(additions, 0);
            } else {
              expect(find.textContaining('Question 9'), findsOneWidget);
              await tester.sendKeyEvent(LogicalKeyboardKey.digit1);
              await tester.pumpAndSettle();
              expect(additions, 1);
              expect(find.textContaining('1 questions saved.'), findsOneWidget);
              expect(
                find.textContaining('Saved question 1: Question 9.'),
                findsOneWidget,
              );
            }
            await tester.pumpWidget(const SizedBox.shrink());
          },
          () => MockClient((request) async {
            if (request.url.path == '/question-bank') {
              reads++;
              return reads == 1
                  ? http.Response('[]', 200)
                  : bankFails
                  ? http.Response('{"detail":"Unavailable"}', 503)
                  : http.Response(jsonEncode([question(9)]), 200);
            }
            if (request.method == 'POST') {
              additions++;
              saved = draft([question(9)]);
            }
            return http.Response(jsonEncode(saved), 200);
          }),
        );
      },
    );
  }

  for (final legacyResponse in [false, true]) {
    testWidgets(
      'bank-save failures are visible without manual refresh; legacyResponse=$legacyResponse',
      (tester) async {
        var bankReads = 0;
        var saved = false;
        await http.runWithClient(
          () async {
            await tester.pumpWidget(
              const MaterialApp(
                home: TeacherQuizScreen(
                  classId: 1,
                  subjectId: 2,
                  className: 'Class',
                  subjectName: 'English',
                ),
              ),
            );
            await tester.pumpAndSettle();
            await tester.sendKeyEvent(LogicalKeyboardKey.digit2);
            await tester.pumpAndSettle();
            await tester.enterText(
              find.widgetWithText(TextField, 'Question text'),
              'Question 11',
            );
            for (var i = 0; i < 4; i++) {
              await tester.enterText(
                find.widgetWithText(TextField, 'Option ${i + 1}'),
                'Answer ${i + 1}',
              );
            }
            await activate(tester, 'bank-question-correct-answer');
            await tester.sendKeyEvent(LogicalKeyboardKey.digit9);
            await tester.pumpAndSettle();
            expect(
              find.textContaining('Question save could not be confirmed.'),
              findsWidgets,
            );
            expect(saved, isTrue);
            if (legacyResponse) {
              expect(bankReads, 2);
              expect(
                find.textContaining(
                  'server returned a question without a revision',
                ),
                findsWidgets,
              );
              expect(find.text('Question 11'), findsOneWidget);
            } else {
              expect(bankReads, 1);
            }
            await tester.pumpWidget(const SizedBox.shrink());
          },
          () => MockClient((request) async {
            if (request.url.path == '/question-bank') {
              if (request.method == 'POST') {
                saved = true;
                final body = question(11)..remove('revision');
                return legacyResponse
                    ? http.Response(jsonEncode(body), 200)
                    : http.Response('{"detail":"Unavailable"}', 503);
              }
              bankReads++;
              return http.Response(
                jsonEncode(saved && legacyResponse ? [question(11)] : []),
                200,
              );
            }
            return http.Response('[]', 200);
          }),
        );
      },
    );
  }

  testWidgets(
    'teacher creates title, writes and reuses questions, reviews and separately confirms publish',
    (tester) async {
      var saved = draft([]);
      final mutations = <http.Request>[];
      await http.runWithClient(
        () async {
          await tester.pumpWidget(
            const MaterialApp(
              home: TeacherQuizScreen(
                classId: 1,
                subjectId: 2,
                className: 'Class',
                subjectName: 'English',
              ),
            ),
          );
          await tester.pumpAndSettle();
          await tester.sendKeyEvent(LogicalKeyboardKey.digit3);
          await tester.pumpAndSettle();
          expect(
            find.descendant(
              of: find.byType(AccessibleQuizEditorDialog),
              matching: find.byType(TextField),
            ),
            findsOneWidget,
          );
          await tester.enterText(
            find.widgetWithText(TextField, 'Quiz title'),
            'New class quiz',
          );
          await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
          await tester.pump();
          await tester.sendKeyEvent(LogicalKeyboardKey.digit8);
          await tester.pumpAndSettle();
          expect(find.text('Step 2: Add questions'), findsOneWidget);
          expect(mutations.length, 1);
          final create = jsonDecode(mutations.first.body) as Map;
          expect(create['attempt_limit'], 1);
          expect(create['time_limit_minutes'], isNull);
          expect(create['feedback_policy'], 'after_completion');
          await tester.sendKeyEvent(LogicalKeyboardKey.digit6);
          await tester.pumpAndSettle();
          expect(find.text('Step 3: Review and publish'), findsNothing);

          await tester.sendKeyEvent(LogicalKeyboardKey.digit2);
          await tester.pumpAndSettle();
          expect(find.byType(TextField), findsNWidgets(5));
          await tester.enterText(
            find.widgetWithText(TextField, 'Question text'),
            'Which option?',
          );
          for (var i = 0; i < 4; i++) {
            await tester.enterText(
              find.widgetWithText(TextField, 'Option ${i + 1}'),
              'Answer ${i + 1}',
            );
          }
          await activate(tester, 'bank-question-correct-answer');
          await tester.sendKeyEvent(LogicalKeyboardKey.digit9);
          await tester.pumpAndSettle();
          expect(mutations.last.url.path, '/teacher/quizzes/3/questions/new');
          expect(jsonDecode(mutations.last.body)['save_to_bank'], isTrue);
          expect(find.textContaining('1 questions saved.'), findsOneWidget);

          await tester.sendKeyEvent(LogicalKeyboardKey.digit3);
          await tester.pumpAndSettle();
          await activate(tester, 'action-dialog-option-0');
          expect(
            mutations.last.url.path,
            '/teacher/quizzes/3/questions/from-bank',
          );
          expect(find.textContaining('2 questions saved.'), findsOneWidget);
          await activate(tester, 'guided-quiz-review');
          expect(find.text('Step 3: Review and publish'), findsOneWidget);
          expect(find.textContaining('One attempt'), findsNothing);
          expect(find.textContaining('1 attempts. No timer.'), findsOneWidget);
          expect(
            mutations.where((r) => r.url.path.endsWith('/publish')),
            isEmpty,
          );
          await tester.sendKeyEvent(LogicalKeyboardKey.digit8);
          await tester.pumpAndSettle();
          expect(find.text('Publish quiz?'), findsOneWidget);
          await tester.sendKeyEvent(LogicalKeyboardKey.digit1);
          await tester.pumpAndSettle();
          expect(
            mutations.where((r) => r.url.path.endsWith('/publish')),
            isEmpty,
          );
          await activate(tester, 'guided-quiz-publish');
          await tester.sendKeyEvent(LogicalKeyboardKey.digit2);
          await tester.pumpAndSettle();
          expect(
            mutations.where((r) => r.url.path.endsWith('/publish')).length,
            1,
          );
          expect(find.text('Quiz published'), findsOneWidget);
          await tester.pumpWidget(const SizedBox.shrink());
        },
        () => MockClient((request) async {
          if (request.method != 'GET') mutations.add(request);
          if (request.url.path == '/question-bank') {
            return http.Response(jsonEncode([question(9)]), 200);
          }
          if (request.url.path == '/teacher/quizzes') {
            if (request.method == 'POST') {
              saved = {
                ...saved,
                ...jsonDecode(request.body) as Map<String, dynamic>,
              };
            }
            return http.Response(
              jsonEncode(request.method == 'GET' ? [saved] : saved),
              200,
            );
          }
          if (request.url.path.endsWith('/questions/new')) {
            saved = draft([question(100)]);
          }
          if (request.url.path.endsWith('/questions/from-bank')) {
            saved = draft([
              ...List<Map<String, dynamic>>.from(saved['questions']),
              question(9),
            ]);
          }
          if (request.url.path.endsWith('/publish')) {
            saved = {...saved, 'status': 'published'};
          }
          return http.Response(jsonEncode(saved), 200);
        }),
      );
    },
  );

  for (final malformed in [true, false]) {
    testWidgets(
      'unconfirmed question add blocks duplicates until authoritative refresh; malformed=$malformed',
      (tester) async {
        var saved = draft([]);
        var adds = 0;
        await http.runWithClient(
          () async {
            await tester.pumpWidget(
              MaterialApp(
                home: GuidedQuizDraftScreen(
                  quizId: 3,
                  classId: 1,
                  subjectId: 2,
                  onPublish: (_) async {},
                ),
              ),
            );
            await tester.pumpAndSettle();
            await tester.sendKeyEvent(LogicalKeyboardKey.digit3);
            await tester.pumpAndSettle();
            await activate(tester, 'action-dialog-option-0');
            expect(adds, 1);
            expect(
              find.textContaining(
                'Adding the question could not be confirmed.',
              ),
              findsOneWidget,
            );
            await tester.sendKeyEvent(LogicalKeyboardKey.digit3);
            await tester.sendKeyEvent(LogicalKeyboardKey.digit6);
            await tester.pumpAndSettle();
            expect(adds, 1);
            expect(find.text('Step 3: Review and publish'), findsNothing);
            await tester.sendKeyEvent(LogicalKeyboardKey.digit1);
            await tester.pumpAndSettle();
            expect(find.textContaining('1 questions saved.'), findsOneWidget);
            await activate(tester, 'guided-quiz-review');
            expect(find.text('Step 3: Review and publish'), findsOneWidget);
            await tester.pumpWidget(const SizedBox.shrink());
          },
          () => MockClient((request) async {
            if (request.url.path == '/question-bank') {
              return http.Response(jsonEncode([question(9)]), 200);
            }
            if (request.method == 'POST') {
              adds++;
              saved = draft([question(9)]);
              return http.Response(
                malformed ? '{"ok":true}' : '{"detail":"Unavailable"}',
                malformed ? 200 : 503,
              );
            }
            return http.Response(jsonEncode(saved), 200);
          }),
        );
      },
    );
  }

  testWidgets('pending add is single-flight and cannot leave the draft', (
    tester,
  ) async {
    final response = Completer<http.Response>();
    var adds = 0;
    await http.runWithClient(
      () async {
        await tester.pumpWidget(
          MaterialApp(
            home: GuidedQuizDraftScreen(
              quizId: 3,
              classId: 1,
              subjectId: 2,
              onPublish: (_) async {},
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.sendKeyEvent(LogicalKeyboardKey.digit3);
        await tester.pumpAndSettle();
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.digit3);
        await tester.sendKeyEvent(LogicalKeyboardKey.digit0);
        await tester.pump();
        expect(adds, 1);
        expect(find.byType(GuidedQuizDraftScreen), findsOneWidget);
        response.complete(http.Response(jsonEncode(draft([question(9)])), 200));
        await tester.pumpAndSettle();
        await tester.pumpWidget(const SizedBox.shrink());
      },
      () => MockClient((request) async {
        if (request.method == 'POST') {
          adds++;
          return response.future;
        }
        return http.Response(
          jsonEncode(
            request.url.path == '/question-bank' ? [question(9)] : draft([]),
          ),
          200,
        );
      }),
    );
  });

  for (final confirmed in [true, false]) {
    testWidgets(
      'review changes settings without publishing and guards unconfirmed saves: $confirmed',
      (tester) async {
        var saved = {
          ...draft([question(9)]),
          'feedback_policy': 'legacy_immediate',
          'attempt_limit': 3,
          'time_limit_minutes': 30,
          'opens_at': '2026-10-22T10:00:00Z',
          'closes_at': '2026-10-23T10:00:00Z',
          'shuffle_options': true,
        };
        Map<String, dynamic>? update;
        var publishes = 0;
        await http.runWithClient(
          () async {
            await tester.pumpWidget(
              MaterialApp(
                home: GuidedQuizDraftScreen(
                  quizId: 3,
                  classId: 1,
                  subjectId: 2,
                  onPublish: (_) async {
                    publishes++;
                  },
                ),
              ),
            );
            await tester.pumpAndSettle();
            await tester.sendKeyEvent(LogicalKeyboardKey.digit6);
            await tester.pumpAndSettle();
            await tester.sendKeyEvent(LogicalKeyboardKey.digit5);
            await tester.pumpAndSettle();
            await tester.enterText(
              find.widgetWithText(TextField, 'Quiz title'),
              'Reviewed title',
            );
            await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
            await tester.pump();
            await tester.sendKeyEvent(LogicalKeyboardKey.digit8);
            await tester.pumpAndSettle();
            expect(update!['feedback_policy'], 'legacy_immediate');
            expect(update!['attempt_limit'], 3);
            expect(update!['time_limit_minutes'], 30);
            expect(update!['shuffle_options'], isTrue);
            expect(
              DateTime.parse(update!['opens_at'] as String),
              DateTime.utc(2026, 10, 22, 10),
            );
            expect(publishes, 0);
            if (confirmed) {
              expect(
                find.textContaining('Reviewed title. 1 questions saved.'),
                findsOneWidget,
              );
            } else {
              expect(
                find.textContaining('Settings save could not be confirmed.'),
                findsOneWidget,
              );
              await tester.sendKeyEvent(LogicalKeyboardKey.digit8);
              await tester.pumpAndSettle();
              expect(publishes, 0);
              await tester.sendKeyEvent(LogicalKeyboardKey.digit1);
              await tester.pumpAndSettle();
              expect(
                find.textContaining('Reviewed title. 1 questions saved.'),
                findsOneWidget,
              );
            }
            await tester.pumpWidget(const SizedBox.shrink());
          },
          () => MockClient((request) async {
            if (request.url.path == '/question-bank') {
              return http.Response('[]', 200);
            }
            if (request.method == 'PUT') {
              update = jsonDecode(request.body) as Map<String, dynamic>;
              saved = {...saved, ...update!};
              if (!confirmed) return http.Response('{"ok":true}', 200);
            }
            return http.Response(jsonEncode(saved), 200);
          }),
        );
      },
    );
  }

  testWidgets(
    'removing a draft question requires selection and a separate confirmation',
    (tester) async {
      var saved = draft([question(9)]);
      var deletions = 0;
      await http.runWithClient(
        () async {
          await tester.pumpWidget(
            MaterialApp(
              home: GuidedQuizDraftScreen(
                quizId: 3,
                classId: 1,
                subjectId: 2,
                onPublish: (_) async {},
              ),
            ),
          );
          await tester.pumpAndSettle();
          await tester.sendKeyEvent(LogicalKeyboardKey.digit4);
          await tester.pumpAndSettle();
          await activate(tester, 'action-dialog-option-0');
          await tester.sendKeyEvent(LogicalKeyboardKey.digit1);
          await tester.pumpAndSettle();
          expect(deletions, 0);
          await activate(tester, 'guided-quiz-remove');
          await activate(tester, 'action-dialog-option-0');
          await tester.sendKeyEvent(LogicalKeyboardKey.digit2);
          await tester.pumpAndSettle();
          expect(deletions, 1);
          expect(find.textContaining('0 questions saved.'), findsOneWidget);
          await tester.pumpWidget(const SizedBox.shrink());
        },
        () => MockClient((request) async {
          if (request.url.path == '/question-bank') {
            return http.Response('[]', 200);
          }
          if (request.method == 'DELETE') {
            deletions++;
            saved = draft([]);
            return http.Response('', 204);
          }
          return http.Response(jsonEncode(saved), 200);
        }),
      );
    },
  );

  testWidgets(
    'account change while entering a question blocks the mutation and gives recovery guidance',
    (tester) async {
      var mutations = 0;
      await http.runWithClient(
        () async {
          await tester.pumpWidget(
            MaterialApp(
              home: GuidedQuizDraftScreen(
                quizId: 3,
                classId: 1,
                subjectId: 2,
                onPublish: (_) async {},
              ),
            ),
          );
          await tester.pumpAndSettle();
          await tester.sendKeyEvent(LogicalKeyboardKey.digit3);
          await tester.pumpAndSettle();
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', 'different-account');
          await activate(tester, 'action-dialog-option-0');
          expect(mutations, 0);
          expect(find.textContaining('Your account changed.'), findsOneWidget);
          await tester.pumpWidget(const SizedBox.shrink());
        },
        () => MockClient((request) async {
          if (request.method != 'GET') mutations++;
          return http.Response(
            jsonEncode(
              request.url.path == '/question-bank' ? [question(9)] : draft([]),
            ),
            200,
          );
        }),
      );
    },
  );

  testWidgets('malformed nested questions are not exposed as a usable draft', (
    tester,
  ) async {
    await http.runWithClient(
      () async {
        await tester.pumpWidget(
          MaterialApp(
            home: GuidedQuizDraftScreen(
              quizId: 3,
              classId: 1,
              subjectId: 2,
              onPublish: (_) async {},
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(
          find.textContaining('could not be loaded. Refresh'),
          findsOneWidget,
        );
        expect(find.textContaining('Write a question'), findsNothing);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      },
      () => MockClient(
        (request) async => http.Response(
          jsonEncode(
            request.url.path == '/question-bank'
                ? []
                : {
                    ...draft([]),
                    'questions': [null],
                    'question_count': 1,
                  },
          ),
          200,
        ),
      ),
    );
  });

  testWidgets(
    'resumed draft and review remain fully reachable at 240x320 and 3x text',
    (tester) async {
      tester.view.physicalSize = const Size(240, 320);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await http.runWithClient(
        () async {
          await tester.pumpWidget(
            MaterialApp(
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(3)),
                child: child!,
              ),
              home: GuidedQuizDraftScreen(
                quizId: 3,
                classId: 1,
                subjectId: 2,
                onPublish: (_) async {},
              ),
            ),
          );
          await tester.pumpAndSettle();
          for (final review in [false, true]) {
            if (review) {
              await tester.sendKeyEvent(LogicalKeyboardKey.digit6);
              await tester.pumpAndSettle();
            }
            final wrapper = tester.widget<KeypadInstructionWrapper>(
              find.byType(KeypadInstructionWrapper),
            );
            for (final target in wrapper.focusTargets.where(
              (target) => target.isEnabled?.call() != false,
            )) {
              for (var i = 0; i < 40 && !target.node.hasFocus; i++) {
                await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
                await tester.pumpAndSettle();
              }
              expect(target.node.hasFocus, isTrue, reason: target.label);
              expect(tester.takeException(), isNull);
            }
            expect(
              tester.allRenderObjects.whereType<RenderParagraph>().where(
                (p) => p.didExceedMaxLines,
              ),
              isEmpty,
            );
          }
          await tester.pumpWidget(const SizedBox.shrink());
        },
        () => MockClient(
          (r) async => http.Response(
            jsonEncode(
              r.url.path == '/question-bank'
                  ? [question(9)]
                  : draft([question(9)]),
            ),
            200,
          ),
        ),
      );
    },
  );
}
