import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/services/notification_services.dart';
import 'package:frontend/services/tts_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final spoken = <String>[];

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'token': 'synthetic-first-session',
      'user_id': 1,
      'fcm_token': 'synthetic-device-token',
    });
    dotenv.testLoad(fileInput: 'API_BASE_URL=https://example.test');
    spoken.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('flutter_tts'), (
          call,
        ) async {
          if (call.method == 'speak') spoken.add(call.arguments.toString());
          return 1;
        });
    await TtsService.configure(enabled: true, mode: SpeechMode.selfVoicing);
  });

  tearDown(() async => TtsService.stop());

  test(
    'signed-in push registration sends only the current account and device token',
    () async {
      var requests = 0;
      await http.runWithClient(
        () async {
          await NotificationService().registerSavedToken();
        },
        () => MockClient((request) async {
          requests++;
          expect(request.url.path, '/users/fcm-token');
          expect(
            request.headers['authorization'],
            'Bearer synthetic-first-session',
          );
          expect(jsonDecode(request.body), {
            'token': 'synthetic-device-token',
            'device_type': 'mobile',
          });
          return http.Response('{"ok":true}', 200);
        }),
      );
      expect(requests, 1);
    },
  );

  for (final restricted in [false, true]) {
    test(
      'push registration is deferred without a normal account: restricted=$restricted',
      () async {
        final prefs = await SharedPreferences.getInstance();
        if (restricted) {
          await prefs.setBool('must_change_password', true);
        } else {
          await prefs.remove('token');
        }
        var requests = 0;
        await http.runWithClient(
          () async {
            await NotificationService().registerSavedToken();
          },
          () => MockClient((_) async {
            requests++;
            return http.Response('{"ok":true}', 200);
          }),
        );
        expect(requests, 0);
      },
    );
  }

  test(
    'next account registration cannot reuse the previous account authorization',
    () async {
      final headers = <String?>[];
      await http.runWithClient(
        () async {
          await NotificationService().registerSavedToken();
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', 'synthetic-second-session');
          await prefs.setInt('user_id', 2);
          await NotificationService().registerSavedToken();
        },
        () => MockClient((request) async {
          headers.add(request.headers['authorization']);
          return http.Response('{"ok":true}', 200);
        }),
      );
      expect(headers, [
        'Bearer synthetic-first-session',
        'Bearer synthetic-second-session',
      ]);
    },
  );

  testWidgets(
    'malformed success does not acknowledge notification registration and gives recovery guidance',
    (tester) async {
      await http.runWithClient(
        () async {
          await NotificationService().registerSavedToken();
          await tester.pump(const Duration(seconds: 3));
          expect(
            spoken.join(' '),
            contains('Notifications could not be registered'),
          );
        },
        () =>
            MockClient((_) async => http.Response('{"unexpected":true}', 200)),
      );
    },
  );
}
