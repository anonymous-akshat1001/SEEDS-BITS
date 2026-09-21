import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/services/auth_session_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('logout cancel preserves state and confirmation clears login', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'token': 'secret',
      'user_id': 7,
      'role': 'student',
      'tts_enabled': true,
    });

    await tester.pumpWidget(
      MaterialApp(
        routes: {'/welcome': (_) => const Scaffold(body: Text('Welcome'))},
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () => AuthSessionService.logoutFrom(context),
              child: const Text('Logout'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    var prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('token'), 'secret');

    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Log out'));
    await tester.pumpAndSettle();
    prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('token'), isNull);
    expect(prefs.getInt('user_id'), isNull);
    expect(prefs.getBool('tts_enabled'), isTrue);
    expect(find.text('Welcome'), findsOneWidget);
  });
}
