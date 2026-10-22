import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/main.dart';
import 'package:frontend/screens/change_password_screen.dart';
import 'package:frontend/screens/login_screen.dart';
import 'package:frontend/screens/register_screen.dart';
import 'package:frontend/screens/settings_screen.dart';
import 'package:frontend/screens/student_dashboard.dart';
import 'package:frontend/screens/teacher_dashboard.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:frontend/screens/quiz_screens.dart';
import 'package:frontend/services/tts_service.dart';
import 'package:frontend/utils/ui_utils.dart';
import 'package:frontend/widgets/key_instruction_wrapper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _NonlinearSystemScaler extends TextScaler {
  const _NonlinearSystemScaler();

  @override
  double scale(double fontSize) => fontSize * (fontSize < 20 ? 2 : 1.5);

  @override
  double get textScaleFactor => 2;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'user_id': 7,
      'token': 'synthetic-layout-token',
      'user_name': 'Test account',
    });
    dotenv.testLoad(fileInput: 'API_BASE_URL=https://example.test');
    UIUtils.setTextScale(1);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('flutter_tts'),
          (_) async => 1,
        );
    await TtsService.configure(enabled: false);
  });

  tearDown(() async {
    UIUtils.setTextScale(1);
    await TtsService.stop();
  });

  test(
    'app magnification preserves nonlinear system scaling for each font size',
    () {
      final scaler = UIUtils.combinedTextScaler(
        const _NonlinearSystemScaler(),
        1.5,
      );
      expect(scaler.scale(16), 48);
      expect(scaler.scale(24), 54);
      expect(scaler.scale(40), 90);
    },
  );

  testWidgets(
    'real app uses 2x system and 1.5x app scaling on a 240-pixel phone without shrinking type',
    (tester) async {
      tester.view.physicalSize = const Size(240, 320);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      UIUtils.setTextScale(1.5);
      await tester.pumpWidget(const MyApp(initialRoute: '/login'));
      await tester.pumpAndSettle();
      final context = tester.element(find.byType(LoginScreen));
      expect(MediaQuery.textScalerOf(context).scale(16), 48);
      expect(UIUtils.fontSize(context, 16), 16);
      final clipped = tester.allRenderObjects
          .whereType<RenderParagraph>()
          .where((paragraph) => paragraph.didExceedMaxLines)
          .map((paragraph) => paragraph.text.toPlainText())
          .toList();
      expect(
        clipped,
        isEmpty,
        reason: 'Important text must reflow, not be truncated.',
      );
      expect(tester.takeException(), isNull);
    },
  );

  final routes = <String, Widget Function()>{
    'Welcome': () => const WelcomeScreen(),
    'Login': () => const LoginScreen(),
    'Register': () => const RegisterScreen(),
    'Settings': () => const SettingsScreen(),
    'Password change': () => const ChangePasswordScreen(),
    'Student dashboard': () => const StudentDashboard(),
    'Teacher dashboard': () => const TeacherDashboard(),
    'Quiz attempt': () => QuizAttemptScreen(
      quizTitle: 'Accessible large-text assessment',
      initialAttempt: {
        'attempt_id': 7,
        'quiz_id': 3,
        'status': 'in_progress',
        'total_questions': 1,
        'answered_count': 0,
        'question': {
          'quiz_question_id': 11,
          'question_text': 'Which option is second?',
          'position': 0,
          'options': [
            {
              'quiz_option_id': 21,
              'option_text': 'First option',
              'position': 0,
            },
            {
              'quiz_option_id': 22,
              'option_text': 'Second option',
              'position': 1,
            },
            {
              'quiz_option_id': 23,
              'option_text': 'Third option',
              'position': 2,
            },
            {
              'quiz_option_id': 24,
              'option_text': 'Fourth option',
              'position': 3,
            },
          ],
        },
      },
    ),
    'Quiz history': () => const QuizHistoryScreen(
      quizTitle: 'Accessible large-text assessment',
      history: {'highest_score': 88.0, 'attempts': []},
    ),
    'Quiz title editor': () => const AccessibleQuizEditorDialog(),
    'Question editor': () => const AccessibleQuestionEditorDialog(),
    'Optional quiz settings': () => const AccessibleQuizEditorDialog(
      initialQuiz: {
        'title': 'Review saved quiz settings',
        'attempt_limit': 2,
        'feedback_policy': 'after_completion',
        'time_limit_minutes': 20,
      },
    ),
    'Optional question metadata': () => const AccessibleQuestionEditorDialog(
      initialQuestion: {
        'question_text': 'An existing question',
        'explanation': 'An optional explanation',
        'options': [],
        'topics': ['English'],
      },
    ),
  };

  for (final entry in routes.entries) {
    testWidgets(
      '${entry.key} reflows and every enabled D-pad control is reachable at 240x320 and combined 3x text',
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
                  data: MediaQuery.of(context).copyWith(
                    textScaler: UIUtils.combinedTextScaler(
                      TextScaler.linear(2),
                      1.5,
                    ),
                  ),
                  child: child!,
                ),
                home: entry.value(),
              ),
            );
            await tester.pumpAndSettle();
            final wrapper = tester.widget<KeypadInstructionWrapper>(
              find.byType(KeypadInstructionWrapper).first,
            );
            final targets = wrapper.focusTargets
                .where((target) => target.enabled)
                .toList();
            expect(targets, isNotEmpty);
            for (final target in targets) {
              for (var steps = 0; steps <= targets.length; steps++) {
                if (target.node.hasFocus) break;
                await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
                await tester.pumpAndSettle();
              }
              expect(
                target.node.hasFocus,
                isTrue,
                reason: '${entry.key}: ${target.node.debugLabel}',
              );
            }
            final clipped = tester.allRenderObjects
                .whereType<RenderParagraph>()
                .where((paragraph) => paragraph.didExceedMaxLines)
                .map((paragraph) => paragraph.text.toPlainText())
                .toList();
            expect(
              clipped,
              isEmpty,
              reason: 'Important text must reflow, not be truncated.',
            );
            expect(tester.takeException(), isNull);
          },
          () => MockClient(
            (request) async => http.Response(
              request.url.path == '/me/access-context' ? '{}' : '[]',
              200,
            ),
          ),
        );
      },
    );
  }
}
