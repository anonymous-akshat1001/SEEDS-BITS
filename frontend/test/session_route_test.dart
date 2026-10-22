import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/main.dart';
import 'package:frontend/screens/session_screen.dart';
import 'package:frontend/services/tts_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    dotenv.testLoad(fileInput: 'API_BASE_URL=https://example.test');
    SharedPreferences.setMockInitialValues({});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('flutter_tts'),
          (_) async => 1,
        );
  });

  testWidgets(
    'legacy simplified route uses the real session with all context',
    (tester) async {
      await tester.pumpWidget(const MyApp(initialRoute: '/login'));
      await tester.pumpAndSettle();
      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      for (final name in ['/session', '/simple_session']) {
        final route = app.onGenerateRoute!(
          RouteSettings(
            name: name,
            arguments: {
              'sessionId': 42,
              'userId': 7,
              'userName': 'Teacher',
              'isTeacher': true,
              'sessionTitle': 'English lesson',
              'className': 'Class 1',
              'subjectName': 'English',
            },
          ),
        );
        expect(route, isA<MaterialPageRoute>());
        final page = route! as MaterialPageRoute;
        final session = page.builder(tester.element(find.byType(MaterialApp)));
        expect(session, isA<SessionScreen>());
        final screen = session as SessionScreen;
        expect(screen.sessionId, 42);
        expect(screen.userId, 7);
        expect(screen.userName, 'Teacher');
        expect(screen.isTeacher, isTrue);
        expect(screen.sessionTitle, 'English lesson');
        expect(screen.className, 'Class 1');
        expect(screen.subjectName, 'English');
      }
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await TtsService.stop();
    },
  );
}
