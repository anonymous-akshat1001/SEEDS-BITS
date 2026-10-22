import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/screens/change_password_screen.dart';
import 'package:frontend/screens/login_screen.dart';
import 'package:frontend/services/auth_session_service.dart';
import 'package:frontend/services/tts_service.dart';
import 'package:frontend/widgets/admin_password_reset_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final spoken = <String>[];
  const credential = '012345678901';
  final replacement = <String, dynamic>{
    'ok': true,
    'access_token': 'replacement-session',
    'user_id': 7,
    'role': 'student',
    'name': 'Test learner',
    'must_change_password': false,
  };

  setUp(() async {
    dotenv.testLoad(fileInput: 'API_BASE_URL=https://example.test');
    SharedPreferences.setMockInitialValues({
      'token': 'restricted-session',
      'user_id': 7,
      'role': 'student',
      'must_change_password': true,
    });
    spoken.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('flutter_tts'), (
          call,
        ) async {
          if (call.method == 'speak') {
            final args = call.arguments;
            spoken.add(args is Map ? args['text'] as String : args as String);
          }
          return 1;
        });
    await TtsService.stop();
    await TtsService.configure(enabled: true, mode: SpeechMode.selfVoicing);
  });

  Future<void> activate(WidgetTester tester, String label) async {
    for (
      var i = 0;
      i < 60 && FocusManager.instance.primaryFocus?.debugLabel != label;
      i++
    ) {
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump(const Duration(milliseconds: 30));
    }
    expect(FocusManager.instance.primaryFocus?.debugLabel, label);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
  }

  Future<void> changeForm(
    WidgetTester tester, {
    String password = 'new-password',
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        routes: {
          '/student_dashboard': (_) =>
              const Scaffold(body: Text('Normal dashboard')),
          '/login': (_) => const Scaffold(body: Text('Sign in again')),
        },
        home: const ChangePasswordScreen(),
      ),
    );
    await tester.pump();
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), credential);
    await tester.enterText(fields.at(1), password);
    await tester.enterText(fields.at(2), password);
  }

  Future<void> adminForm(WidgetTester tester) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('role', 'admin');
    await prefs.setBool('must_change_password', false);
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => const AdminPasswordResetDialog(
                  accountId: 8,
                  authVersion: 3,
                  accountName: 'Selected learner',
                  phoneNumber: '9000000008',
                ),
              ),
              child: const Text('Recover selected account'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Recover selected account'));
    await tester.pumpAndSettle();
  }

  testWidgets(
    'temporary login routes only to required change and persists the restricted state',
    (tester) async {
      await http.runWithClient(
        () async {
          await tester.pumpWidget(
            MaterialApp(
              routes: {
                '/change_password': (_) =>
                    const Scaffold(body: Text('Required change')),
              },
              home: const LoginScreen(),
            ),
          );
          await tester.pump();
          await tester.enterText(find.byType(TextField).first, '9000000007');
          await tester.enterText(find.byType(TextField).at(1), credential);
          await tester.tap(find.text('4: Login as Student'));
          await tester.pumpAndSettle();
          final prefs = await SharedPreferences.getInstance();
          expect(prefs.getBool('must_change_password'), isTrue);
          expect(prefs.getString('token'), 'temporary-session');
          expect(find.text('Required change'), findsOneWidget);
          expect(spoken.join(' '), isNot(contains(credential)));
          expect(spoken.join(' '), isNot(contains('Test learner')));
        },
        () => MockClient(
          (request) async => http.Response(
            jsonEncode({
              ...replacement,
              'access_token': 'temporary-session',
              'must_change_password': true,
            }),
            200,
          ),
        ),
      );
    },
  );

  testWidgets(
    'keypad password change verifies the real acknowledgment and replaces the restricted session',
    (tester) async {
      final requests = <http.Request>[];
      await http.runWithClient(
        () async {
          await changeForm(tester, password: ' new-password ');
          expect(
            tester
                .widgetList<TextField>(find.byType(TextField))
                .every((field) => field.obscureText),
            isTrue,
          );
          await activate(tester, 'recovery-save');
          expect(requests, hasLength(1));
          expect(requests.single.url.path, '/auth/change-password');
          expect(
            requests.single.headers['Authorization'],
            'Bearer restricted-session',
          );
          expect(jsonDecode(requests.single.body), {
            'current_password': credential,
            'new_password': ' new-password ',
          });
          final prefs = await SharedPreferences.getInstance();
          expect(prefs.getBool('must_change_password'), isFalse);
          expect(prefs.getString('token'), 'replacement-session');
          expect(find.text('Normal dashboard'), findsOneWidget);
          expect(spoken.join(' '), isNot(contains(credential)));
          expect(spoken.join(' '), isNot(contains('new-password')));
        },
        () => MockClient((request) async {
          requests.add(request);
          return http.Response(jsonEncode(replacement), 200);
        }),
      );
    },
  );

  testWidgets(
    'malformed replacement never unlocks the dashboard or overwrites the restricted token',
    (tester) async {
      await http.runWithClient(
        () async {
          await changeForm(tester);
          await activate(tester, 'recovery-save');
          final prefs = await SharedPreferences.getInstance();
          expect(prefs.getString('token'), 'restricted-session');
          expect(prefs.getBool('must_change_password'), isTrue);
          expect(find.textContaining('could not be verified'), findsOneWidget);
          expect(find.text('Normal dashboard'), findsNothing);
        },
        () => MockClient(
          (_) async => http.Response(
            '{"ok":true,"user_id":7,"must_change_password":false}',
            200,
          ),
        ),
      );
    },
  );

  testWidgets(
    'a late successful change cannot replace another signed-in account',
    (tester) async {
      final response = Completer<http.Response>();
      await http.runWithClient(() async {
        await changeForm(tester);
        await activate(tester, 'recovery-save');
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', 'other-account-session');
        await prefs.setInt('user_id', 99);
        response.complete(http.Response(jsonEncode(replacement), 200));
        await tester.pumpAndSettle();
        expect(prefs.getString('token'), 'other-account-session');
        expect(prefs.getInt('user_id'), 99);
        expect(find.text('Normal dashboard'), findsNothing);
        expect(find.textContaining('account changed'), findsOneWidget);
      }, () => MockClient((_) => response.future));
    },
  );

  testWidgets(
    'Back never bypasses change; confirmed sign-out clears forced state and cached credentials',
    (tester) async {
      await changeForm(tester);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      await activate(tester, 'dialog-cancel');
      expect(find.byType(ChangePasswordScreen), findsOneWidget);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('token'), 'restricted-session');
      await activate(tester, 'recovery-sign-out');
      await activate(tester, 'dialog-confirm');
      expect(find.text('Sign in again'), findsOneWidget);
      expect(prefs.getString('token'), isNull);
      expect(prefs.getBool('must_change_password'), isNull);
    },
  );

  testWidgets(
    'admin recovery requires attestation and separate confirmation; credential is revealed only on explicit Read',
    (tester) async {
      final requests = <http.Request>[];
      await http.runWithClient(
        () async {
          await adminForm(tester);
          expect(
            tester
                .widget<ElevatedButton>(find.byType(ElevatedButton))
                .onPressed,
            isNull,
          );
          await activate(tester, 'admin-reset-attestation');
          await activate(tester, 'admin-reset-submit');
          expect(requests, isEmpty);
          await activate(tester, 'dialog-confirm');
          expect(requests, hasLength(1));
          expect(jsonDecode(requests.single.body), {
            'identity_verified': true,
            'expected_auth_version': 3,
          });
          expect(
            find.textContaining('Temporary credential: 0 1'),
            findsNothing,
          );
          expect(spoken.join(' '), isNot(contains('0 1 2 3 4 5 6 7 8 9 0 1')));
          await activate(tester, 'admin-reset-read');
          expect(
            find.textContaining('Temporary credential: 0 1'),
            findsOneWidget,
          );
          expect(spoken.join(' '), contains('0 1 2 3 4 5 6 7 8 9 0 1'));
          final prefs = await SharedPreferences.getInstance();
          expect(
            prefs.getKeys().any(
              (key) => prefs.get(key).toString().contains(credential),
            ),
            isFalse,
          );
          await activate(tester, 'admin-reset-close');
          await activate(tester, 'dialog-cancel');
          expect(find.byType(AdminPasswordResetDialog), findsOneWidget);
          await activate(tester, 'admin-reset-close');
          await activate(tester, 'dialog-confirm');
          expect(find.byType(AdminPasswordResetDialog), findsNothing);
        },
        () => MockClient((request) async {
          requests.add(request);
          return http.Response(
            jsonEncode({
              'ok': true,
              'temporary_credential': credential,
              'expires_at': DateTime.now()
                  .toUtc()
                  .add(const Duration(hours: 24))
                  .toIso8601String(),
              'auth_version': 4,
            }),
            200,
          );
        }),
      );
    },
  );

  testWidgets(
    'unconfirmed admin reset cannot be automatically retried from the same review',
    (tester) async {
      var requests = 0;
      await http.runWithClient(
        () async {
          await adminForm(tester);
          await activate(tester, 'admin-reset-attestation');
          await activate(tester, 'admin-reset-submit');
          await activate(tester, 'dialog-confirm');
          expect(requests, 1);
          expect(find.textContaining('Reset not confirmed.'), findsOneWidget);
          expect(
            find.text('Reset password and end online sessions'),
            findsNothing,
          );
          await activate(tester, 'admin-reset-close');
          expect(find.byType(AdminPasswordResetDialog), findsNothing);
          expect(requests, 1);
        },
        () => MockClient((_) async {
          requests++;
          return http.Response('{"detail":"conflict"}', 409);
        }),
      );
    },
  );

  testWidgets(
    'recovery form reflows at 240x320 with 1.5x text and keeps save/sign-out keypad reachable',
    (tester) async {
      tester.view.physicalSize = const Size(240, 320);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.5)),
            child: child!,
          ),
          home: const ChangePasswordScreen(),
        ),
      );
      await tester.pump();
      for (var i = 0; i < 5; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pump(const Duration(milliseconds: 30));
      }
      expect(
        FocusManager.instance.primaryFocus?.debugLabel,
        'recovery-sign-out',
      );
      expect(tester.takeException(), isNull);
    },
  );

  test(
    'session persistence rejects malformed credentials without clearing another account',
    () async {
      await expectLater(
        AuthSessionService.saveLoginState({...replacement, 'user_id': '7'}),
        throwsFormatException,
      );
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('token'), 'restricted-session');
    },
  );
}
