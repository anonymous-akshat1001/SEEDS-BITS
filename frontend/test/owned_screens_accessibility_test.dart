import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/announcers/dashboard_text.dart';
import 'package:frontend/main.dart' show WelcomeScreen, routeObserver;
import 'package:frontend/screens/login_screen.dart';
import 'package:frontend/screens/settings_screen.dart';
import 'package:frontend/screens/student_dashboard.dart';
import 'package:frontend/services/tts_service.dart';
import 'package:frontend/utils/ui_utils.dart';
import 'package:frontend/widgets/key_instruction_wrapper.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Keypad and speech behaviour of the welcome, sign-in, settings and
/// student home screens.
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

  testWidgets('welcome names Settings on opening and on coming back', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        navigatorObservers: [routeObserver],
        home: const WelcomeScreen(),
        routes: {'/login': (_) => const Scaffold(body: Text('Sign in'))},
      ),
    );
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 600));
    expect(
      spoken.join(' '),
      contains('Press 1 for Login, 2 for Settings. Press star for help.'),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.digit1);
    await tester.pumpAndSettle();
    spoken.clear();
    tester.state<NavigatorState>(find.byType(Navigator)).pop();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();
    expect(spoken.join(' '), contains('Press 1 for Login, 2 for Settings.'));
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('welcome stops only on actions; descriptions are plain text', (
    tester,
  ) async {
    await open(tester, const WelcomeScreen());
    expect(targetOrder(tester), [
      'welcome-login',
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
      'login-submit',
      'login-sim-suggestion',
      'login-admin',
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

  testWidgets('a shared phone asks for the profile number, then signs in', (
    tester,
  ) async {
    final bodies = <Map<String, dynamic>>[];
    await http.runWithClient(
      () async {
        await open(tester, const LoginScreen());
        // The 10th digit signs in, and the profile number's last digit
        // continues: neither OK nor 1 is needed.
        await tester.enterText(find.byType(TextField).first, '988800000');
        await tester.pumpAndSettle();
        expect(bodies, isEmpty);
        await tester.enterText(find.byType(TextField).first, '9888000000');
        await tester.pumpAndSettle();
        expect(
          FocusManager.instance.primaryFocus?.debugLabel,
          'login-profile-code',
        );
        expect(spoken.join(' '), contains('This phone is shared'));
        await tester.enterText(find.byType(TextField).at(1), '1');
        await tester.pumpAndSettle();
        expect(bodies, hasLength(1));
        await tester.enterText(find.byType(TextField).at(1), '12');
        await tester.pumpAndSettle();
        expect(bodies.last, {
          'phone_number': '9888000000',
          'profile_code': '12',
        });
        expect(bodies.first.containsKey('profile_code'), isFalse);
        await tester.pumpWidget(const SizedBox.shrink());
      },
      () => MockClient((request) async {
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        bodies.add(body);
        return http.Response(
          body.containsKey('profile_code')
              ? '{"detail":"That profile number is not recognised on this phone."}'
              : '{"profile_required":true,"code_length":2}',
          body.containsKey('profile_code') ? 401 : 200,
        );
      }),
    );
  });

  testWidgets(
    'sign-in starts in the number field and says it signs in by itself, before the keys',
    (tester) async {
      await open(tester, const LoginScreen());
      await tester.pump(const Duration(milliseconds: 600));
      final opening = spoken.join(' ');
      final task = opening.indexOf('Signing in starts by itself');
      final field = opening.indexOf('You are in Phone number.');
      final keys = opening.indexOf('Press 1 for Sign in');
      expect(task, greaterThanOrEqualTo(0), reason: opening);
      expect(field, greaterThan(task), reason: opening);
      expect(keys, greaterThan(field), reason: opening);
      expect(opening, contains(', 3 for'));
      expect(opening, isNot(contains('While editing')));
      expect(FocusManager.instance.primaryFocus?.debugLabel, 'login-phone');
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('login error is spoken and focus moves to the number field', (
    tester,
  ) async {
    await open(tester, const LoginScreen());
    await tester.enterText(find.byType(TextField).first, '12');
    await tester.tap(find.text('1: Sign in'));
    await tester.pumpAndSettle();
    expect(FocusManager.instance.primaryFocus?.debugLabel, 'login-phone');
    expect(spoken.last, contains('Type your phone number first.'));
    expect(find.text('Type your phone number first.'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('an unknown number says to ask the administrator', (
    tester,
  ) async {
    await http.runWithClient(
      () async {
        await open(tester, const LoginScreen());
        await tester.enterText(find.byType(TextField).first, '9111111111');
        await tester.pumpAndSettle();
        expect(spoken.join(' '), contains('Ask your school administrator'));
        await tester.pumpWidget(const SizedBox.shrink());
      },
      () => MockClient(
        (_) async => http.Response('{"detail":"not registered"}', 401),
      ),
    );
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

  Map<String, dynamic> studentHome({bool live = false}) => {
    'role': 'student',
    'class_name': 'Class 6',
    'live_class': live
        ? {
            'session_id': 12,
            'subject_name': 'English',
            'class_name': 'Class 6',
            'teacher_name': 'Mrs Rao',
          }
        : null,
    'next_class': live
        ? null
        : {
            'entry_id': 3,
            'occurrence_date': '2026-11-16',
            'subject_name': 'English',
            'start_clock': '10:00',
          },
  };

  testWidgets(
    'student home: one sentence on arrival, join is key 1, nothing to type, search or refresh',
    (tester) async {
      await http.runWithClient(
        () async {
          await open(tester, const StudentDashboard());
          await tester.pump(const Duration(seconds: 2));
          expect(find.text('1: Join English class'), findsOneWidget);
          expect(find.byType(TextField), findsNothing);
          expect(find.textContaining('Refresh'), findsNothing);
          expect(
            spoken.join(' '),
            contains('English class is live. Press 1 to join.'),
          );
          expect(find.text('0: ${DashboardText.logout}'), findsOneWidget);
          await tester.pumpWidget(const SizedBox.shrink());
        },
        () => MockClient(
          (request) async =>
              http.Response(jsonEncode(studentHome(live: true)), 200),
        ),
      );
    },
  );

  testWidgets(
    'before class, key 1 consents to joining automatically and pressing it again cancels',
    (tester) async {
      await http.runWithClient(
        () async {
          await open(tester, const StudentDashboard());
          await tester.pump(const Duration(seconds: 2));
          expect(
            find.text('1: Join English automatically when it starts at 10:00'),
            findsOneWidget,
          );
          await tester.sendKeyEvent(LogicalKeyboardKey.digit1);
          await tester.pumpAndSettle();
          expect(spoken.last, contains('I will open English'));
          expect(find.text('1: Stop joining automatically'), findsOneWidget);
          await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 350)),
          );
          await tester.sendKeyEvent(LogicalKeyboardKey.digit1);
          await tester.pumpAndSettle();
          expect(spoken.last, contains('Automatic joining cancelled'));
          await tester.pumpWidget(const SizedBox.shrink());
        },
        () => MockClient(
          (request) async => http.Response(jsonEncode(studentHome()), 200),
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
