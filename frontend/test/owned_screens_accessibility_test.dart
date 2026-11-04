import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/main.dart' show WelcomeScreen, routeObserver;
import 'package:frontend/screens/login_screen.dart';
import 'package:frontend/screens/register_screen.dart';
import 'package:frontend/screens/settings_screen.dart';
import 'package:frontend/screens/student_dashboard.dart';
import 'package:frontend/services/tts_service.dart';
import 'package:frontend/utils/ui_utils.dart';
import 'package:frontend/widgets/key_instruction_wrapper.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Keypad and speech behaviour of the welcome, login, registration,
/// settings and student dashboard screens.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final spoken = <String>[];

  setUp(() async {
    spoken.clear();
    SharedPreferences.setMockInitialValues({
      'token': 'test-token',
      'user_id': 7,
      'role': 'student',
      'user_name': 'Asha',
    });
    dotenv.testLoad(fileInput: 'API_BASE_URL=https://example.test');
    UIUtils.setHighContrastMode(true);
    UIUtils.setTextScale(1.0);
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
    await TtsService.configure(enabled: true, mode: SpeechMode.selfVoicing);
  });
  tearDown(TtsService.stop);

  Future<void> open(WidgetTester tester, Widget screen) async {
    await tester.pumpWidget(
      MaterialApp(navigatorObservers: [routeObserver], home: screen),
    );
    await tester.pumpAndSettle();
  }

  List<String?> targetOrder(WidgetTester tester) => tester
      .widget<KeypadInstructionWrapper>(
        find.byType(KeypadInstructionWrapper).first,
      )
      .focusTargets
      .map((target) => target.node.debugLabel)
      .toList();

  testWidgets('welcome stops only on actions; descriptions are plain text', (
    tester,
  ) async {
    await open(tester, const WelcomeScreen());
    expect(targetOrder(tester), [
      'welcome-login',
      'welcome-register',
      'welcome-settings',
      'welcome-repeat-instructions',
    ]);
    final semantics = tester.ensureSemantics();
    expect(
      tester.getSemantics(find.text('SEEDS')),
      matchesSemantics(label: 'SEEDS', isHeader: true),
    );
    semantics.dispose();
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('login keypad order matches the visual order', (tester) async {
    await open(tester, const LoginScreen());
    final order = targetOrder(tester);
    expect(order, [
      'login-phone',
      'login-password',
      'login-password-visibility',
      'login-role',
      'login-submit',
      'login-register',
      'login-sim-suggestion',
      'login-recovery-help',
    ]);
    double top(String label) => tester
        .getTopLeft(
          find
              .byWidgetPredicate(
                (widget) =>
                    widget is Focus && widget.focusNode?.debugLabel == label,
              )
              .first,
        )
        .dy;
    for (var i = 1; i < order.length; i++) {
      expect(
        top(order[i]!) >= top(order[i - 1]!) - 24,
        isTrue,
        reason: '${order[i]} must not be above ${order[i - 1]}',
      );
    }
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('login account type is one semantic control with its value', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await open(tester, const LoginScreen());
    expect(find.bySemanticsLabel('Account type'), findsOneWidget);
    final node = tester.getSemantics(find.bySemanticsLabel('Account type'));
    expect(node.value, 'Student, selected. Press 1, 2 or 3 to change');
    semantics.dispose();
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('login error is spoken and focus moves to the field to fix', (
    tester,
  ) async {
    await open(tester, const LoginScreen());
    await tester.enterText(find.byType(TextField).first, '12');
    await tester.enterText(find.byType(TextField).at(1), 'secret-password');
    await tester.ensureVisible(find.text('4: Login as Student'));
    await tester.tap(find.text('4: Login as Student'));
    await tester.pumpAndSettle();
    expect(FocusManager.instance.primaryFocus?.debugLabel, 'login-phone');
    expect(spoken.last, contains('Enter a valid 10-digit phone number.'));
    expect(spoken.last, contains('phone number field'));
    expect(find.text('Enter a valid 10-digit phone number.'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('registration error focuses the first invalid field', (
    tester,
  ) async {
    await open(tester, const RegisterScreen());
    await tester.enterText(find.byType(TextField).at(1), '9876543210');
    // Digits typed while a field is focused stay in the field, so leave it
    // with the D-pad and activate Register with OK.
    for (
      var press = 0;
      press < 12 &&
          FocusManager.instance.primaryFocus?.debugLabel != 'register-submit';
      press++
    ) {
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
    }
    expect(FocusManager.instance.primaryFocus?.debugLabel, 'register-submit');
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(FocusManager.instance.primaryFocus?.debugLabel, 'register-name');
    expect(spoken.last, contains('Enter your name.'));
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('after registering, login says so and focuses the phone field', (
    tester,
  ) async {
    await open(tester, const LoginScreen(justRegistered: true));
    expect(FocusManager.instance.primaryFocus?.debugLabel, 'login-phone');
    expect(spoken.join(' '), contains('Registered. Now log in.'));
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'Settings speech mode cycles back to Automatic, which keeps TalkBack auto-detection',
    (tester) async {
      await open(tester, const SettingsScreen());
      expect(find.textContaining('Automatic: follows TalkBack'), findsWidgets);
      expect(find.textContaining('On by default'), findsOneWidget);
      final prefs = await SharedPreferences.getInstance();
      final mode = find.textContaining('Speech mode.');
      await tester.ensureVisible(mode);
      await tester.tap(mode);
      await tester.pumpAndSettle();
      expect(prefs.getString('speech_mode'), 'screenReader');
      await tester.tap(find.textContaining('Speech mode.'));
      await tester.pumpAndSettle();
      expect(prefs.getString('speech_mode'), 'selfVoicing');
      await tester.tap(find.textContaining('Speech mode.'));
      await tester.pumpAndSettle();
      expect(prefs.containsKey('speech_mode'), isFalse);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('Settings sections are announced and save speaks once', (
    tester,
  ) async {
    await open(tester, const SettingsScreen());
    final labels = tester
        .widget<KeypadInstructionWrapper>(
          find.byType(KeypadInstructionWrapper).first,
        )
        .focusTargets
        .map((target) => target.label)
        .toList();
    expect(labels.where((label) => label.contains(' section. ')), hasLength(3));
    expect(labels[2], startsWith('Speech section. App speech, on'));
    spoken.clear();
    await tester.sendKeyEvent(LogicalKeyboardKey.digit6);
    await tester.pumpAndSettle();
    expect(spoken.where((text) => text == 'Settings saved'), hasLength(1));
    final semantics = tester.ensureSemantics();
    expect(find.bySemanticsLabel('Settings saved'), findsNothing);
    semantics.dispose();
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'student dashboard: every session is a focus stop with a concise label, count is spoken, number search filters',
    (tester) async {
      final sessions = [
        {
          'session_id': 12,
          'title': 'Science',
          'subject_name': 'Science',
          'class_name': 'Class 6',
          'teacher_name': 'Mrs Rao',
          'subject_id': 1,
        },
        {
          'session_id': 34,
          'title': 'Maths revision',
          'subject_name': 'Maths',
          'class_name': 'Class 6',
          'teacher_name': 'Mr Das',
          'subject_id': 2,
        },
      ];
      await http.runWithClient(
        () async {
          await open(tester, const StudentDashboard());
          await tester.pump(const Duration(seconds: 2));
          final wrapper = tester.widget<KeypadInstructionWrapper>(
            find.byType(KeypadInstructionWrapper).first,
          );
          final sessionLabels = wrapper.focusTargets
              .where(
                (target) =>
                    target.node.debugLabel?.startsWith('student-session-') ==
                        true &&
                    target.node.debugLabel != 'student-session-number',
              )
              .map((target) => target.label)
              .toList();
          expect(sessionLabels, [
            'Science, Class 6, Teacher Mrs Rao, live now, session 12. Press OK to join',
            'Maths revision, Maths, Class 6, Teacher Mr Das, live now, session 34. Press OK to join',
          ]);
          expect(spoken.join(' '), contains('2 sessions available'));
          expect(wrapper.labels[0], 'Log out, asks to confirm');

          await tester.enterText(
            find.byWidgetPredicate(
              (widget) =>
                  widget is TextField &&
                  widget.focusNode?.debugLabel == 'student-session-number',
            ),
            '34',
          );
          await tester.pump(const Duration(seconds: 1));
          expect(find.text('Science'), findsNothing);
          expect(find.text('Maths revision'), findsOneWidget);
          expect(spoken.last, contains('Found: Maths revision'));

          await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
          await tester.pumpAndSettle();
          await tester.pumpWidget(const SizedBox.shrink());
        },
        () => MockClient(
          (request) async => http.Response(
            request.url.path.endsWith('/sessions/active')
                ? jsonEncode(sessions)
                : '{}',
            200,
          ),
        ),
      );
    },
  );

  testWidgets('student dashboard key 0 asks to confirm before logging out', (
    tester,
  ) async {
    await http.runWithClient(
      () async {
        await open(tester, const StudentDashboard());
        await tester.sendKeyEvent(LogicalKeyboardKey.digit0);
        await tester.pumpAndSettle();
        expect(find.text('Log out of SEEDS?'), findsOneWidget);
        await tester.sendKeyEvent(LogicalKeyboardKey.digit1);
        await tester.pumpAndSettle();
        expect(find.text('Log out of SEEDS?'), findsNothing);
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString('token'), 'test-token');
        await tester.pumpWidget(const SizedBox.shrink());
      },
      () => MockClient(
        (request) async => http.Response(
          request.url.path.endsWith('/sessions/active') ? '[]' : '{}',
          200,
        ),
      ),
    );
  });
}
