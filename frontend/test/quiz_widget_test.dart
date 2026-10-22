import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/screens/quiz_screens.dart';
import 'package:frontend/utils/keypad_actions.dart';
import 'package:frontend/utils/ui_utils.dart';
import 'package:frontend/services/tts_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/widgets/quiz_extra_time_dialog.dart';
import 'package:frontend/screens/question_revisions_screen.dart';

Map<String, dynamic> attemptFixture() => {
  'attempt_id': 7,
  'quiz_id': 3,
  'attempt_number': 1,
  'status': 'in_progress',
  'started_at': '2026-10-13T08:00:00',
  'deadline_at': null,
  'completed_at': null,
  'correct_count': 0,
  'total_questions': 1,
  'percentage_score': 0.0,
  'answered_count': 0,
  'server_time': '2026-10-13T08:00:00',
  'question': {
    'quiz_question_id': 11,
    'question_text': 'Which option is second?',
    'position': 0,
    'options': [
      {'quiz_option_id': 21, 'option_text': 'First', 'position': 0},
      {'quiz_option_id': 22, 'option_text': 'Second', 'position': 1},
      {'quiz_option_id': 23, 'option_text': 'Third', 'position': 2},
      {'quiz_option_id': 24, 'option_text': 'Fourth', 'position': 3},
    ],
  },
};

void main() {
  Future<void> activate(WidgetTester tester, String label) async {
    for (
      var i = 0;
      i < 80 && FocusManager.instance.primaryFocus?.debugLabel != label;
      i++
    ) {
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump(const Duration(milliseconds: 30));
    }
    expect(FocusManager.instance.primaryFocus?.debugLabel, label);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
  }

  testWidgets(
    'review D-pad traversal reaches question 25 beyond the viewport and withholds keys visibly when required',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: QuizReviewScreen(
            review: {
              'questions': [
                for (var i = 1; i <= 25; i++)
                  {
                    'question_text': 'Question $i',
                    'spoken_question_text': 'Spoken question $i',
                    'is_correct': true,
                    'selected_option_text': 'Second',
                    'correct_option_text': 'Second',
                  },
              ],
            },
          ),
        ),
      );
      await tester.pump();
      await activate(tester, 'quiz-review-question-24');
      expect(
        FocusManager.instance.primaryFocus?.debugLabel,
        'quiz-review-question-24',
      );
      await tester.pumpWidget(
        const MaterialApp(
          home: QuizReviewScreen(
            review: {
              'questions': [],
              'feedback_message': 'Scheduled feedback remains withheld.',
            },
          ),
        ),
      );
      await tester.pump();
      await activate(tester, 'quiz-review-message');
      expect(find.text('Scheduled feedback remains withheld.'), findsOneWidget);
      expect(find.textContaining('Incorrect'), findsNothing);
    },
  );

  testWidgets(
    'completed scores stay silent and out of live semantics until explicit Read result',
    (tester) async {
      final spoken = <String>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('flutter_tts'),
        (call) async {
          if (call.method == 'speak') {
            spoken.add(call.arguments.toString());
          }
          return 1;
        },
      );
      await TtsService.configure(enabled: true, mode: SpeechMode.selfVoicing);
      final semantics = tester.ensureSemantics();
      try {
        await tester.pumpWidget(
          MaterialApp(
            home: QuizAttemptScreen(
              quizTitle: 'Private result',
              initialAttempt: {
                ...attemptFixture(),
                'status': 'completed',
                'question': null,
                'correct_count': 1,
                'percentage_score': 100.0,
              },
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 500));
        expect(spoken.join(' '), isNot(contains('percent')));
        expect(
          find.bySemanticsLabel(
            'Attempt complete. Result private. Use Read result privately.',
          ),
          findsOneWidget,
        );
        await tester.sendKeyEvent(LogicalKeyboardKey.digit8);
        await tester.pumpAndSettle();
        expect(spoken.join(' '), contains('100.0 percent'));
        expect(find.bySemanticsLabel(RegExp('Score 1 of 1')), findsOneWidget);
      } finally {
        semantics.dispose();
      }
    },
  );

  testWidgets(
    'history introductions do not disclose grades; explicitly focused summary still reads them',
    (tester) async {
      final spoken = <String>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('flutter_tts'),
        (call) async {
          if (call.method == 'speak') {
            spoken.add(call.arguments.toString());
          }
          return 1;
        },
      );
      await tester.pumpWidget(
        const MaterialApp(
          home: QuizHistoryScreen(
            quizTitle: 'Private history',
            history: {'highest_score': 88.0, 'attempts': []},
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));
      expect(spoken.join(' '), isNot(contains('88')));
      await activate(tester, 'quiz-history-summary');
      expect(spoken.join(' '), contains('Highest score: 88.0'));
    },
  );

  testWidgets(
    'answer save acknowledgment does not narrate keys or explanations until explicit private feedback',
    (tester) async {
      final spoken = <String>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('flutter_tts'),
        (call) async {
          if (call.method == 'speak') {
            spoken.add(call.arguments.toString());
          }
          return 1;
        },
      );
      await http.runWithClient(
        () async {
          await tester.pumpWidget(
            MaterialApp(
              home: QuizAttemptScreen(
                quizTitle: 'Private feedback',
                initialAttempt: attemptFixture(),
              ),
            ),
          );
          await tester.pump();
          await tester.sendKeyEvent(LogicalKeyboardKey.digit2);
          await tester.sendKeyEvent(LogicalKeyboardKey.digit5);
          await tester.pumpAndSettle();
          expect(find.text('Correct'), findsOneWidget);
          expect(spoken.join(' '), contains('confirmed saved and locked'));
          expect(spoken.join(' '), isNot(contains('Correct answer')));
          expect(spoken.join(' '), isNot(contains('Private explanation')));
          await activate(tester, 'quiz-feedback');
          expect(spoken.join(' '), contains('Correct answer: Second'));
          expect(spoken.join(' '), contains('Private explanation'));
        },
        () => MockClient(
          (_) async => http.Response(
            jsonEncode({
              'is_correct': true,
              'correct_option_text': 'Second',
              'selected_option_text': 'Second',
              'explanation': 'Private explanation',
              'feedback_released': true,
              'next_question': null,
            }),
            200,
          ),
        ),
      );
    },
  );

  for (final scoreOnly in [false, true]) {
    testWidgets(
      'new graded quiz preserves graded limits with explicit feedback policy, scoreOnly=$scoreOnly',
      (tester) async {
        Map<String, dynamic>? saved;
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () async {
                    saved = await showDialog<Map<String, dynamic>>(
                      context: context,
                      builder: (_) => const AccessibleQuizEditorDialog(),
                    );
                  },
                  child: const Text('Create graded quiz'),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Create graded quiz'));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.widgetWithText(TextField, 'Quiz title'),
          'Graded quiz',
        );
        if (scoreOnly) {
          await activate(tester, 'quiz-optional-settings');
          await activate(tester, 'quiz-feedback-policy');
          await activate(tester, 'quiz-save');
          expect(saved, isNull);
          await activate(tester, 'quiz-feedback-policy');
        }
        await activate(tester, 'quiz-save');
        expect(saved!['mode'], 'graded');
        expect(saved!['attempt_limit'], 1);
        expect(
          saved!['feedback_policy'],
          scoreOnly ? 'score_only' : 'after_completion',
        );
        expect(saved!['feedback_release_at'], isNull);
      },
    );
  }

  setUp(() async {
    SharedPreferences.setMockInitialValues({'token': 'test-token'});
    dotenv.testLoad(fileInput: 'API_BASE_URL=https://example.test');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('flutter_tts'),
          (_) async => 1,
        );
    await TtsService.configure(enabled: true);
  });

  for (final available in [true, false]) {
    testWidgets(
      'early finalization checks the server rather than stale local unanswered counts, available=$available',
      (tester) async {
        var reads = 0;
        await http.runWithClient(
          () async {
            await tester.pumpWidget(
              MaterialApp(
                home: QuizAttemptScreen(
                  quizTitle: 'Authoritative count',
                  initialAttempt: {
                    ...attemptFixture(),
                    'total_questions': 3,
                    'answered_count': 0,
                  },
                ),
              ),
            );
            await tester.pump();
            await tester.sendKeyEvent(LogicalKeyboardKey.digit7);
            await tester.pumpAndSettle();
            expect(reads, 1);
            if (available) {
              expect(
                find.textContaining(
                  'server check confirms 1 unanswered questions.',
                ),
                findsOneWidget,
              );
              expect(
                find.textContaining('3 unanswered questions.'),
                findsNothing,
              );
              await activate(tester, 'dialog-cancel');
            } else {
              expect(
                find.textContaining('No early submission was sent.'),
                findsOneWidget,
              );
              expect(find.text('Finalize saved answers'), findsNothing);
            }
          },
          () => MockClient((request) async {
            expect(request.method, 'GET');
            reads++;
            return available
                ? http.Response(
                    jsonEncode({
                      ...attemptFixture(),
                      'total_questions': 3,
                      'answered_count': 2,
                    }),
                    200,
                  )
                : http.Response('{"detail":"Unavailable"}', 503);
          }),
        );
      },
    );
  }

  test('dashboard keypad mappings expose quizzes', () {
    expect(studentDashboardKeyLabels[5], 'Quizzes');
    expect(teacherDashboardKeyLabels[6], 'Quizzes');
    expect(quizAttemptKeyLabels[1], 'Select option 1');
    expect(quizAttemptKeyLabels[5], 'Submit selected answer');
    expect(adminDashboardKeyLabels[6], 'Create Class');
    expect(teacherQuizKeyLabels[2], 'Create bank question');
    expect(studentQuizKeyLabels[1], 'Refresh quizzes');
  });

  testWidgets(
    'teacher-reviewed spoken notation is used for question, options and screen-reader semantics',
    (tester) async {
      final spoken = <String>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('flutter_tts'),
        (call) async {
          if (call.method == 'speak') spoken.add(call.arguments.toString());
          return 1;
        },
      );
      final semantics = tester.ensureSemantics();
      try {
        final attempt = attemptFixture();
        final question = attempt['question'] as Map<String, dynamic>;
        question['question_text'] = r'\frac{x}{2}';
        question['spoken_question_text'] = 'X divided by two';
        question['options'][0]['option_text'] = r'\frac{1}{2}';
        question['options'][0]['spoken_option_text'] = 'One half';
        await tester.pumpWidget(
          MaterialApp(
            home: QuizAttemptScreen(
              quizTitle: 'Spoken notation',
              initialAttempt: attempt,
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 500));
        await activate(tester, 'quiz-repeat-options');
        expect(spoken.join(' '), contains('X divided by two'));
        expect(spoken.join(' '), contains('One half'));
        expect(spoken.join(' '), isNot(contains(r'\frac')));
        expect(
          tester.getSemantics(find.byType(RadioListTile<int>).first).label,
          contains('One half'),
        );
        expect(
          tester.getSemantics(find.byType(RadioListTile<int>).first).label,
          isNot(contains(r'\frac')),
        );
      } finally {
        semantics.dispose();
      }
    },
  );

  testWidgets(
    'editing described notation requires renewed teacher review and preserves topic/revision payload',
    (tester) async {
      tester.view.physicalSize = const Size(240, 320);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      Map<String, dynamic>? saved;
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.5)),
            child: child!,
          ),
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async {
                  saved = await showDialog<Map<String, dynamic>>(
                    context: context,
                    builder: (_) => AccessibleQuestionEditorDialog(
                      initialQuestion: {
                        'question_text': 'Question',
                        'revision': 2,
                        'explanation': 'Explanation',
                        'options': [
                          for (var i = 1; i <= 4; i++)
                            {'option_text': 'Option $i', 'is_correct': i == 2},
                        ],
                        'notation': 'described',
                        'topics': ['Algebra'],
                        'spoken_question_text': 'Spoken question',
                        'spoken_options': [
                          for (var i = 1; i <= 4; i++) 'Spoken option $i',
                        ],
                        'spoken_explanation': 'Spoken explanation',
                        'spoken_reviewed': true,
                      },
                    ),
                  );
                },
                child: const Text('Edit notation'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Edit notation'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextField, 'Teacher-written spoken question'),
        'Updated spoken question',
      );
      await tester.pump();
      expect(
        tester.widget<CheckboxListTile>(find.byType(CheckboxListTile)).value,
        isFalse,
      );
      await activate(tester, 'bank-question-save');
      expect(saved, isNull);
      expect(
        find.textContaining('Review and confirm every spoken alternative'),
        findsOneWidget,
      );
      await activate(tester, 'bank-question-reviewed');
      await activate(tester, 'bank-question-save');
      expect(saved!['spoken_reviewed'], isTrue);
      expect(saved!['topics'], ['Algebra']);
      expect(saved!['spoken_question_text'], 'Updated spoken question');
      expect(saved!['spoken_options'], hasLength(4));
    },
  );

  testWidgets(
    'read-only revision history paginates older and newer snapshots without mutation',
    (tester) async {
      final offsets = <int>[];
      Map<String, dynamic> row(int version) => {
        'revision': version,
        'recorded_at': '2026-10-21',
        'content': {
          'question_text': 'Question version $version',
          'spoken_question_text': 'Spoken version $version',
          'options': ['First', 'Second', 'Third', 'Fourth'],
          'correct_option_index': 1,
          'topics': ['Topic'],
        },
      };
      await http.runWithClient(
        () async {
          await tester.pumpWidget(
            const MaterialApp(home: QuestionRevisionsScreen(questionId: 4)),
          );

          await tester.pumpAndSettle();
          expect(
            find.textContaining('Question: Spoken version 21'),
            findsOneWidget,
          );
          for (var i = 0; i < 20; i++) {
            await activate(tester, 'question-revision-older');
          }
          expect(
            find.textContaining('Question: Spoken version 1'),
            findsOneWidget,
          );
          await activate(tester, 'question-revision-newer');
          expect(
            find.textContaining('Question: Spoken version 2'),
            findsOneWidget,
          );
          expect(offsets, [0, 20, 0]);
        },
        () => MockClient((request) async {
          expect(request.method, 'GET');
          final offset = int.parse(request.url.queryParameters['offset']!);
          offsets.add(offset);
          return http.Response(
            jsonEncode({
              'question_id': 4,
              'has_more': offset == 0,
              'revisions': offset == 0
                  ? [for (var v = 21; v >= 2; v--) row(v)]
                  : [row(1)],
            }),
            200,
          );
        }),
      );
    },
  );

  testWidgets(
    'private revision responses are discarded after an account change',
    (tester) async {
      final response = Completer<http.Response>();
      await http.runWithClient(() async {
        await tester.pumpWidget(
          const MaterialApp(home: QuestionRevisionsScreen(questionId: 4)),
        );
        await tester.pump();
        await tester.pump();
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', 'another-account');
        response.complete(
          http.Response(
            jsonEncode({'question_id': 4, 'has_more': false, 'revisions': []}),
            200,
          ),
        );
        await tester.pumpAndSettle();
        expect(
          find.text(
            'Your account changed. Private question history was cleared.',
          ),
          findsOneWidget,
        );
      }, () => MockClient((_) => response.future));
    },
  );

  for (final responseKind in ['confirmed', 'mismatched', 'forbidden']) {
    testWidgets(
      'extra time teacher control requires a matching acknowledgement at 240x320 and 1.5x: $responseKind',
      (tester) async {
        tester.view.physicalSize = const Size(240, 320);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        var futureMinutes = 0;
        var posts = 0;
        await http.runWithClient(
          () async {
            await tester.pumpWidget(
              MaterialApp(
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaler: const TextScaler.linear(1.5)),
                  child: child!,
                ),
                home: const QuizResultsScreen(
                  quizId: 3,
                  quizTitle: 'Timed quiz',
                ),
              ),
            );
            await tester.pumpAndSettle();
            await activate(tester, 'quiz-extra-student-9');
            await tester.enterText(find.byType(TextField), '20');
            await activate(tester, 'quiz-extra-save');
            expect(posts, 1);
            expect(
              find.text(
                'Future extra time: ${responseKind == 'confirmed' ? 20 : 0} minutes. Set',
              ),
              findsOneWidget,
            );
            if (responseKind == 'mismatched') {
              expect(
                find.textContaining('confirmation did not match'),
                findsOneWidget,
              );
            }
            expect(tester.takeException(), isNull);
          },
          () => MockClient((request) async {
            if (request.method == 'POST') {
              posts++;
              expect(jsonDecode(request.body), {
                'student_id': 9,
                'extra_minutes': 20,
              });
              if (responseKind == 'forbidden') {
                return http.Response('{"detail":"Not allowed"}', 403);
              }
              futureMinutes = responseKind == 'confirmed' ? 20 : 0;
              return http.Response(
                jsonEncode({
                  'ok': true,
                  'student_id': responseKind == 'confirmed' ? 9 : 10,
                  'extra_minutes': 20,
                }),
                200,
              );
            }
            if (request.url.path.endsWith('/summary')) {
              return http.Response(
                jsonEncode({
                  'mode': 'graded',
                  'time_limit_minutes': 10,
                  'eligible_students': 1,
                  'started': 0,
                  'completed': 0,
                  'not_attempted': 1,
                  'completion_percentage': 0,
                  'per_question': [],
                }),
                200,
              );
            }
            return http.Response(
              jsonEncode([
                {
                  'student_id': 9,
                  'student_name': 'Kai',
                  'started': false,
                  'completed': false,
                  'attempts': [],
                  'extra_time_minutes': futureMinutes,
                },
              ]),
              200,
            );
          }),
        );
      },
    );
  }

  for (final practice in [false, true]) {
    testWidgets(
      'withheld score or ungraded practice completion is announced without inventing an incorrect answer; practice=$practice',
      (tester) async {
        await http.runWithClient(
          () async {
            await tester.pumpWidget(
              MaterialApp(
                home: QuizAttemptScreen(
                  quizTitle: 'Policy-aware attempt',
                  initialAttempt: {
                    ...attemptFixture(),
                    'is_graded': !practice,
                    'score_released': practice,
                  },
                ),
              ),
            );
            await tester.pump();
            await tester.sendKeyEvent(LogicalKeyboardKey.digit2);
            await tester.sendKeyEvent(LogicalKeyboardKey.digit5);
            await tester.pumpAndSettle();
            expect(find.text('Answer saved and locked'), findsOneWidget);
            expect(find.text('Incorrect'), findsNothing);
            expect(find.textContaining('Correct answer: null'), findsNothing);
            await tester.sendKeyEvent(LogicalKeyboardKey.digit6);
            await tester.pumpAndSettle();
            expect(find.text('Attempt complete'), findsOneWidget);
            expect(
              find.textContaining(
                practice
                    ? 'Practice, not an academic grade'
                    : 'Score not released',
              ),
              findsOneWidget,
            );
            expect(find.textContaining('null percent'), findsNothing);
          },
          () => MockClient((request) async {
            if (request.url.path.endsWith('/answers')) {
              return http.Response(
                jsonEncode({
                  'feedback_released': false,
                  'feedback_message':
                      'Confirmed saved. Feedback is released later.',
                  'selected_option_text': 'Second',
                  'next_question': null,
                }),
                200,
              );
            }
            return http.Response(
              jsonEncode({
                ...attemptFixture(),
                'status': 'completed',
                'question': null,
                'correct_count': practice ? 1 : null,
                'percentage_score': null,
                'is_graded': !practice,
                'score_released': practice,
                'feedback_message': 'The scheduled release has not arrived.',
              }),
              200,
            );
          }),
        );
      },
    );
  }
  testWidgets(
    'early final submission warns about unanswered/unsaved answers and cancellation never sends completion',
    (tester) async {
      var completions = 0;
      await http.runWithClient(
        () async {
          await tester.pumpWidget(
            MaterialApp(
              home: QuizAttemptScreen(
                quizTitle: 'Early submission',
                initialAttempt: attemptFixture(),
              ),
            ),
          );
          await tester.pump();
          await tester.sendKeyEvent(LogicalKeyboardKey.digit2);
          await tester.sendKeyEvent(LogicalKeyboardKey.digit7);
          await tester.pumpAndSettle();
          expect(
            find.textContaining('1 unanswered questions.'),
            findsOneWidget,
          );
          await activate(tester, 'dialog-cancel');
          expect(completions, 0);
          await activate(tester, 'quiz-early-finish');
          await activate(tester, 'dialog-confirm');
          expect(completions, 1);
          expect(find.text('Attempt complete'), findsOneWidget);
        },
        () => MockClient((request) async {
          if (request.method == 'GET') {
            return http.Response(jsonEncode(attemptFixture()), 200);
          }
          expect(request.url.path.endsWith('/complete'), isTrue);
          completions++;
          return http.Response(
            jsonEncode({
              ...attemptFixture(),
              'status': 'completed',
              'question': null,
            }),
            200,
          );
        }),
      );
    },
  );
  testWidgets(
    'leaving an attempt confirms unsaved-selection loss and never submits',
    (tester) async {
      var requests = 0;
      await http.runWithClient(
        () async {
          await tester.pumpWidget(
            MaterialApp(
              home: Builder(
                builder: (context) => Scaffold(
                  body: TextButton(
                    onPressed: () => Navigator.push<void>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => QuizAttemptScreen(
                          quizTitle: 'Exit safely',
                          initialAttempt: attemptFixture(),
                        ),
                      ),
                    ),
                    child: const Text('Quiz list'),
                  ),
                ),
              ),
            ),
          );
          await tester.tap(find.text('Quiz list'));
          await tester.pumpAndSettle();
          await tester.sendKeyEvent(LogicalKeyboardKey.digit2);
          await activate(tester, 'quiz-exit-attempt');
          expect(
            find.textContaining('This does not submit your attempt.'),
            findsOneWidget,
          );
          await activate(tester, 'dialog-confirm');
          expect(find.text('Quiz list'), findsOneWidget);
          expect(requests, 0);
        },
        () => MockClient((_) async {
          requests++;
          return http.Response('{}', 500);
        }),
      );
    },
  );
  testWidgets(
    'separate practice editor emits untimed ungraded unlimited-retry mode without changing the graded default',
    (tester) async {
      Map<String, dynamic>? saved;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async {
                  saved = await showDialog<Map<String, dynamic>>(
                    context: context,
                    builder: (_) =>
                        const AccessibleQuizEditorDialog(practice: true),
                  );
                },
                child: const Text('Create practice'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Create practice'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextField, 'Quiz title'),
        'Practice words',
      );
      await activate(tester, 'quiz-save');
      expect(saved!['mode'], 'practice');
      expect(saved!['time_limit_minutes'], isNull);
      expect(saved!['feedback_policy'], 'immediate');
      expect(saved!['feedback_release_at'], isNull);
    },
  );
  testWidgets(
    'extra time input rejects negative minutes and saving zero is explicit for future attempts only',
    (tester) async {
      int? selected;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async {
                  selected = await showDialog<int>(
                    context: context,
                    builder: (_) => const QuizExtraTimeDialog(
                      studentName: 'Student',
                      initialMinutes: 15,
                    ),
                  );
                },
                child: const Text('Set extra time'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Set extra time'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '-1');
      await activate(tester, 'quiz-extra-save');
      expect(selected, isNull);
      expect(find.textContaining('Enter a whole number'), findsOneWidget);
      await tester.enterText(find.byType(TextField), '0');
      await activate(tester, 'quiz-extra-save');
      expect(selected, 0);
    },
  );

  testWidgets('small phone widths preserve combined text scaling', (
    tester,
  ) async {
    double? effectiveScale;
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(size: Size(320, 640)),
        child: MaterialApp(
          home: Builder(
            builder: (context) {
              effectiveScale =
                  UIUtils.combinedTextScaler(
                    MediaQuery.textScalerOf(context),
                    2.0,
                  ).scale(16) /
                  16;
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );

    expect(effectiveScale, 2.0);
  });

  testWidgets('attempt renders four options and requires explicit submit', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: QuizAttemptScreen(
          quizTitle: 'Accessible quiz',
          initialAttempt: attemptFixture(),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(RadioListTile<int>), findsNWidgets(4));
    expect(find.text('5: Submit answer'), findsOneWidget);
    expect(find.text('Correct'), findsNothing);

    await tester.tap(find.text('2. Second'));
    await tester.pump();

    final selected = tester.widget<RadioGroup<int>>(
      find.byType(RadioGroup<int>),
    );
    expect(selected.groupValue, 22);
    expect(find.text('Correct'), findsNothing);
  });

  testWidgets('numeric keypad selects option without grading it', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: QuizAttemptScreen(
          quizTitle: 'Keypad quiz',
          initialAttempt: attemptFixture(),
        ),
      ),
    );
    await tester.pump();

    await tester.sendKeyDownEvent(LogicalKeyboardKey.digit3);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.digit3);
    await tester.pump();

    final selected = tester.widget<RadioGroup<int>>(
      find.byType(RadioGroup<int>),
    );
    expect(selected.groupValue, 23);
    expect(find.text('Correct'), findsNothing);
  });

  testWidgets('Next before a saved answer never completes the attempt', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'token': 'test-token'});
    dotenv.testLoad(fileInput: 'API_BASE_URL=https://example.test');
    final requests = <http.Request>[];
    await http.runWithClient(
      () async {
        await tester.pumpWidget(
          MaterialApp(
            home: QuizAttemptScreen(
              quizTitle: 'Safe navigation',
              initialAttempt: attemptFixture(),
            ),
          ),
        );
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.digit6);
        await tester.pumpAndSettle();
        expect(requests, isEmpty);
        expect(find.text('Attempt complete'), findsNothing);
        expect(find.byType(RadioListTile<int>), findsNWidgets(4));
        await tester.pumpWidget(const SizedBox.shrink());
      },
      () => MockClient((request) async {
        requests.add(request);
        return http.Response(
          jsonEncode({
            ...attemptFixture(),
            'status': 'completed',
            'question': null,
          }),
          200,
        );
      }),
    );
  });

  testWidgets('question prompt is spoken and reachable before its options', (
    tester,
  ) async {
    final spoken = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('flutter_tts'),
      (call) async {
        if (call.method == 'speak') spoken.add(call.arguments.toString());
        return 1;
      },
    );
    await TtsService.configure(enabled: true);
    await tester.pumpWidget(
      MaterialApp(
        home: QuizAttemptScreen(
          quizTitle: 'Spoken question',
          initialAttempt: attemptFixture(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));
    expect(spoken.join(' '), contains('Which option is second?'));
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(
      FocusManager.instance.primaryFocus?.debugLabel,
      'quiz-question-prompt',
    );
    await tester.pumpWidget(const SizedBox.shrink());
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('flutter_tts'),
      null,
    );
  });

  testWidgets(
    'pending and saved answers cannot be submitted or changed again',
    (tester) async {
      final response = Completer<http.Response>();
      var submissions = 0;
      await http.runWithClient(
        () async {
          await tester.pumpWidget(
            MaterialApp(
              home: QuizAttemptScreen(
                quizTitle: 'Answer safety',
                initialAttempt: attemptFixture(),
              ),
            ),
          );
          await tester.pump();
          await tester.tap(find.text('2. Second'));
          await tester.pump();
          await tester.ensureVisible(find.text('5: Submit answer'));
          await tester.tap(find.text('5: Submit answer'));
          await tester.pump();
          await tester.sendKeyEvent(LogicalKeyboardKey.digit5);
          await tester.sendKeyEvent(LogicalKeyboardKey.digit1);
          await tester.pump();
          expect(submissions, 1);
          expect(
            tester
                .widget<RadioGroup<int>>(find.byType(RadioGroup<int>))
                .groupValue,
            22,
          );
          expect(
            tester
                .widget<RadioListTile<int>>(
                  find.byType(RadioListTile<int>).first,
                )
                .enabled,
            isFalse,
          );

          response.complete(
            http.Response(
              jsonEncode({
                'is_correct': true,
                'selected_option_text': 'Second',
                'correct_option_text': 'Second',
                'explanation': 'Second is option two.',
                'next_question': null,
              }),
              200,
            ),
          );
          await tester.pumpAndSettle();
          expect(find.textContaining('Second is option two.'), findsOneWidget);
          expect(
            FocusManager.instance.primaryFocus?.debugLabel,
            'quiz-feedback',
          );
          await tester.sendKeyEvent(LogicalKeyboardKey.digit3);
          await tester.pump();
          expect(find.byType(RadioGroup<int>), findsNothing);
          expect(find.text('5: Submit answer'), findsNothing);
          expect(find.text('6: View result'), findsOneWidget);
          expect(submissions, 1);
          await tester.pumpWidget(const SizedBox.shrink());
        },
        () => MockClient((_) {
          submissions++;
          return response.future;
        }),
      );
    },
  );

  testWidgets(
    'saved answer advances to the next spoken question, not a result',
    (tester) async {
      final initial = {...attemptFixture(), 'total_questions': 2};
      final nextQuestion = {
        ...(initial['question'] as Map<String, dynamic>),
        'quiz_question_id': 12,
        'question_text': 'What comes next?',
      };
      final requests = <String>[];
      await http.runWithClient(
        () async {
          await tester.pumpWidget(
            MaterialApp(
              home: QuizAttemptScreen(
                quizTitle: 'Two questions',
                initialAttempt: initial,
              ),
            ),
          );
          await tester.pump();
          await tester.sendKeyEvent(LogicalKeyboardKey.digit2);
          await tester.sendKeyEvent(LogicalKeyboardKey.digit5);
          await tester.pumpAndSettle();
          await tester.sendKeyEvent(LogicalKeyboardKey.digit6);
          await tester.pumpAndSettle();
          expect(find.text('Question 2 of 2'), findsOneWidget);
          expect(find.text('What comes next?'), findsOneWidget);
          expect(
            FocusManager.instance.primaryFocus?.debugLabel,
            'quiz-question-prompt',
          );
          expect(
            tester
                .widget<RadioGroup<int>>(find.byType(RadioGroup<int>))
                .groupValue,
            isNull,
          );
          expect(requests, ['/student/attempts/7/answers']);
          await tester.pumpWidget(const SizedBox.shrink());
        },
        () => MockClient((request) async {
          requests.add(request.url.path);
          return http.Response(
            jsonEncode({
              'is_correct': true,
              'selected_option_text': 'Second',
              'correct_option_text': 'Second',
              'explanation': 'Second is option two.',
              'next_question': nextQuestion,
            }),
            200,
          );
        }),
      );
    },
  );

  testWidgets(
    'completion failure keeps saved feedback and exposes keypad retry',
    (tester) async {
      var completions = 0;
      await http.runWithClient(
        () async {
          await tester.pumpWidget(
            MaterialApp(
              home: QuizAttemptScreen(
                quizTitle: 'Retry safely',
                initialAttempt: attemptFixture(),
              ),
            ),
          );
          await tester.pump();
          await tester.sendKeyEvent(LogicalKeyboardKey.digit2);
          await tester.sendKeyEvent(LogicalKeyboardKey.digit5);
          await tester.pumpAndSettle();
          await tester.sendKeyEvent(LogicalKeyboardKey.digit6);
          await tester.pumpAndSettle();
          expect(completions, 1);
          expect(find.text('Attempt complete'), findsNothing);
          expect(find.text('Retry completion'), findsOneWidget);
          expect(
            find.textContaining('Your saved answers are preserved.'),
            findsOneWidget,
          );
          expect(find.textContaining('Second is option two.'), findsOneWidget);

          await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
          await tester.pump();
          expect(
            FocusManager.instance.primaryFocus?.debugLabel,
            'quiz-next-question',
          );
          await tester.sendKeyEvent(LogicalKeyboardKey.enter);
          await tester.pumpAndSettle();
          expect(completions, 2);
          expect(find.text('Attempt complete'), findsOneWidget);
          expect(
            FocusManager.instance.primaryFocus?.debugLabel,
            'quiz-return-to-list',
          );
          await tester.pumpWidget(const SizedBox.shrink());
        },
        () => MockClient((request) async {
          if (request.url.path.endsWith('/answers')) {
            return http.Response(
              jsonEncode({
                'is_correct': true,
                'selected_option_text': 'Second',
                'correct_option_text': 'Second',
                'explanation': 'Second is option two.',
                'next_question': null,
              }),
              200,
            );
          }
          completions++;
          if (completions == 1) {
            return http.Response('{"detail":"Temporarily unavailable"}', 503);
          }
          return http.Response(
            jsonEncode({
              ...attemptFixture(),
              'status': 'completed',
              'question': null,
              'answered_count': 1,
              'correct_count': 1,
              'percentage_score': 100.0,
            }),
            200,
          );
        }),
      );
    },
  );

  testWidgets(
    'resumed attempt with every answer saved can confirm its result',
    (tester) async {
      var completions = 0;
      await http.runWithClient(
        () async {
          await tester.pumpWidget(
            MaterialApp(
              home: QuizAttemptScreen(
                quizTitle: 'Resume saved answers',
                initialAttempt: {
                  ...attemptFixture(),
                  'answered_count': 1,
                  'question': null,
                },
              ),
            ),
          );
          await tester.pump();
          expect(find.text('6: View result'), findsOneWidget);
          await tester.sendKeyEvent(LogicalKeyboardKey.digit6);
          await tester.pumpAndSettle();
          expect(completions, 1);
          expect(find.text('Attempt complete'), findsOneWidget);
          await tester.pumpWidget(const SizedBox.shrink());
        },
        () => MockClient((request) async {
          expect(request.url.path, '/student/attempts/7/complete');
          completions++;
          return http.Response(
            jsonEncode({
              ...attemptFixture(),
              'status': 'completed',
              'question': null,
              'answered_count': 1,
            }),
            200,
          );
        }),
      );
    },
  );

  for (final status in [503, 200]) {
    testWidgets(
      'unconfirmed answer ($status) keeps the selection and blocks Next',
      (tester) async {
        var requests = 0;
        await http.runWithClient(
          () async {
            await tester.pumpWidget(
              MaterialApp(
                home: QuizAttemptScreen(
                  quizTitle: 'Unconfirmed answer',
                  initialAttempt: attemptFixture(),
                ),
              ),
            );
            await tester.pump();
            await tester.sendKeyEvent(LogicalKeyboardKey.digit2);
            await tester.sendKeyEvent(LogicalKeyboardKey.digit5);
            await tester.pumpAndSettle();
            expect(requests, 1);
            expect(find.text('Correct'), findsNothing);
            expect(
              find.textContaining('Your selection is preserved'),
              findsOneWidget,
            );
            expect(
              tester
                  .widget<RadioGroup<int>>(find.byType(RadioGroup<int>))
                  .groupValue,
              22,
            );
            await tester.sendKeyEvent(LogicalKeyboardKey.digit6);
            await tester.pumpAndSettle();
            expect(requests, 1);
            expect(find.text('Attempt complete'), findsNothing);
            await tester.pumpWidget(const SizedBox.shrink());
          },
          () => MockClient((_) async {
            requests++;
            return http.Response('{"ok":true}', status);
          }),
        );
      },
    );
  }

  testWidgets('malformed completion never becomes a successful result', (
    tester,
  ) async {
    await http.runWithClient(() async {
      await tester.pumpWidget(
        MaterialApp(
          home: QuizAttemptScreen(
            quizTitle: 'Unreadable confirmation',
            initialAttempt: {
              ...attemptFixture(),
              'answered_count': 1,
              'question': null,
            },
          ),
        ),
      );
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.digit6);
      await tester.pumpAndSettle();
      expect(find.text('Attempt complete'), findsNothing);
      expect(find.text('Retry completion'), findsOneWidget);
      expect(
        find.textContaining('Completion was not confirmed'),
        findsOneWidget,
      );
      await tester.pumpWidget(const SizedBox.shrink());
    }, () => MockClient((_) async => http.Response('{"ok":true}', 200)));
  });

  testWidgets(
    'deadline still finalizes and disables answers during completion retry',
    (tester) async {
      var completions = 0;
      await http.runWithClient(
        () async {
          await tester.pumpWidget(
            MaterialApp(
              home: QuizAttemptScreen(
                quizTitle: 'Deadline recovery',
                initialAttempt: {
                  ...attemptFixture(),
                  'deadline_at': '2026-10-13T07:59:00',
                },
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(completions, 1);
          expect(find.text('Retry completion'), findsOneWidget);
          expect(find.byType(RadioListTile<int>), findsNothing);
          await tester.sendKeyEvent(LogicalKeyboardKey.digit2);
          await tester.sendKeyEvent(LogicalKeyboardKey.digit5);
          await tester.pump();
          expect(completions, 1);
          await tester.sendKeyEvent(LogicalKeyboardKey.digit6);
          await tester.pumpAndSettle();
          expect(completions, 2);
          expect(find.text('Attempt complete'), findsOneWidget);
          await tester.pumpWidget(const SizedBox.shrink());
        },
        () => MockClient((request) async {
          expect(request.url.path, '/student/attempts/7/complete');
          completions++;
          if (completions == 1) {
            return http.Response('{"detail":"Unavailable"}', 503);
          }
          return http.Response(
            jsonEncode({
              ...attemptFixture(),
              'status': 'timed_out',
              'question': null,
            }),
            200,
          );
        }),
      );
    },
  );

  testWidgets('history displays highest score and all attempts', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: QuizHistoryScreen(
          quizTitle: 'History quiz',
          history: {
            'highest_score': 80.0,
            'attempts': [
              {
                'attempt_id': 1,
                'attempt_number': 1,
                'status': 'completed',
                'correct_count': 3,
                'total_questions': 5,
                'percentage_score': 60.0,
              },
              {
                'attempt_id': 2,
                'attempt_number': 2,
                'status': 'completed',
                'correct_count': 4,
                'total_questions': 5,
                'percentage_score': 80.0,
              },
            ],
          },
        ),
      ),
    );

    expect(find.text('Highest score: 80.0'), findsOneWidget);
    expect(find.text('Attempt 1'), findsOneWidget);
    expect(find.text('Attempt 2'), findsOneWidget);
  });

  testWidgets(
    'bank question uses separate correct-answer selector and D-pad order',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: AccessibleQuestionEditorDialog()),
      );
      await tester.pump();

      expect(find.byType(TextField), findsNWidgets(5));
      expect(find.text('Which answer is correct?'), findsOneWidget);
      expect(find.text('Choose the correct option'), findsOneWidget);
      expect(find.text('Correct answer'), findsNothing);

      await tester.sendKeyDownEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(
        FocusManager.instance.primaryFocus?.debugLabel,
        'bank-question-text',
      );

      for (var index = 0; index < 5; index++) {
        await tester.sendKeyDownEvent(LogicalKeyboardKey.arrowDown);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.arrowDown);
        await tester.pump();
      }
      expect(
        FocusManager.instance.primaryFocus?.debugLabel,
        'bank-question-correct-answer',
      );
    },
  );

  testWidgets('quiz schedule controls are spoken and D-pad reachable', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: AccessibleQuizEditorDialog()),
    );
    await tester.pump();

    expect(find.text('No opening time'), findsNothing);
    await activate(tester, 'quiz-optional-settings');
    expect(find.text('No opening time'), findsOneWidget);
    expect(find.text('No closing time'), findsOneWidget);
    expect(
      find.text('Optional · enter year, month, day, hour and minute'),
      findsOneWidget,
    );
    expect(find.text('Optional · must be after opening time'), findsOneWidget);

    for (var index = 0; index < 4; index++) {
      await tester.sendKeyDownEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
    }
    expect(FocusManager.instance.primaryFocus?.debugLabel, 'quiz-opens-at');
  });

  testWidgets('question action dialog exposes D-pad navigable buttons', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AccessibleActionDialog(
          title: 'Question options',
          actions: [
            AccessibleAction(
              value: 'edit',
              label: 'Edit bank question',
              icon: Icons.edit,
            ),
            AccessibleAction(
              value: 'archive',
              label: 'Archive bank question',
              icon: Icons.archive_outlined,
            ),
          ],
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Edit bank question'), findsOneWidget);
    expect(find.text('Archive bank question'), findsOneWidget);
    expect(find.text('0: Cancel'), findsOneWidget);

    await tester.sendKeyDownEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(
      FocusManager.instance.primaryFocus?.debugLabel,
      'action-dialog-option-0',
    );
  });

  testWidgets('completed attempt supports keypad return to quizzes', (
    tester,
  ) async {
    final completed = {
      ...attemptFixture(),
      'status': 'completed',
      'completed_at': '2026-10-13T08:05:00',
      'correct_count': 1,
      'percentage_score': 100.0,
      'answered_count': 1,
      'question': null,
    };
    await tester.pumpWidget(
      MaterialApp(
        initialRoute: '/attempt',
        routes: {
          '/': (_) => const Scaffold(body: Text('Quiz list')),
          '/attempt': (_) => QuizAttemptScreen(
            quizTitle: 'Completed quiz',
            initialAttempt: completed,
          ),
        },
      ),
    );
    await tester.pump();

    expect(find.text('0: Return to quizzes'), findsOneWidget);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(
      FocusManager.instance.primaryFocus?.debugLabel,
      'quiz-return-to-list',
    );

    await tester.sendKeyDownEvent(LogicalKeyboardKey.digit6);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.digit6);
    await tester.pumpAndSettle();
    expect(find.text('Quiz list'), findsOneWidget);
  });
}
