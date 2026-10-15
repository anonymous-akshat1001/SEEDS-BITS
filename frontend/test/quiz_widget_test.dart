import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/screens/quiz_screens.dart';
import 'package:frontend/utils/keypad_actions.dart';

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
  test('dashboard keypad mappings expose quizzes', () {
    expect(studentDashboardKeyLabels[5], 'Quizzes');
    expect(teacherDashboardKeyLabels[6], 'Quizzes');
    expect(quizAttemptKeyLabels[1], 'Select option 1');
    expect(quizAttemptKeyLabels[5], 'Submit selected answer');
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

      expect(find.byType(TextField), findsNWidgets(6));
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

    expect(find.text('No opening time'), findsOneWidget);
    expect(find.text('No closing time'), findsOneWidget);
    expect(find.text('Optional · choose date, then time'), findsOneWidget);
    expect(find.text('Optional · must be after opening time'), findsOneWidget);

    for (var index = 0; index < 5; index++) {
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
