import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/l10n/speech.dart';
import 'package:frontend/services/auth_session_service.dart';
import 'package:frontend/services/tts_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('logout cancel preserves state and confirmation clears login', (
    tester,
  ) async {
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('flutter_tts'),
      (_) async => 1,
    );
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
    await tester.sendKeyEvent(LogicalKeyboardKey.digit1);
    await tester.pumpAndSettle();
    var prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('token'), 'secret');

    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.digit2);
    await tester.pumpAndSettle();
    prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('token'), isNull);
    expect(prefs.getInt('user_id'), isNull);
    expect(prefs.getBool('tts_enabled'), isTrue);
    expect(find.text('Welcome'), findsOneWidget);
  });

  testWidgets(
    'a language chosen before signing in is kept, even over the account\'s saved settings',
    (tester) async {
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('flutter_tts'),
        (_) async => 1,
      );
      // This account last signed in before choosing any language.
      SharedPreferences.setMockInitialValues({
        'account_profile_7': '{"tts_enabled":true}',
      });
      await TtsService.setSpeechLanguage(SpeechLanguage.hindi);
      await AuthSessionService.saveLoginState({
        'access_token': 'token',
        'user_id': 7,
        'role': 'student',
        'name': 'Asha',
      });
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('speech_language'), 'hi');
      expect(TtsService.selectedLanguage, SpeechLanguage.hindi);
      expect(Speech.language, SpeechLanguage.hindi);
      expect(prefs.containsKey(TtsService.languageChosenSignedOutKey), isFalse);
      await TtsService.setSpeechLanguage(SpeechLanguage.english);
    },
  );

  testWidgets(
    'the administrator\'s speech is used, a change in Settings is kept, and a new choice applies again',
    (tester) async {
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('flutter_tts'),
        (_) async => 1,
      );
      SharedPreferences.setMockInitialValues({});
      Future<void> signIn(Map<String, Object?> speech) =>
          AuthSessionService.saveLoginState({
            'access_token': 'token',
            'user_id': 9,
            'role': 'teacher',
            'speech': speech,
          });
      await signIn({'language': 'kn', 'rate': 0.75});
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('speech_language'), 'kn');
      expect(prefs.getDouble('tts_speech_rate'), 0.75);
      expect(TtsService.selectedLanguage, SpeechLanguage.kannada);

      // The person picks Hindi in Settings; the same choice from the
      // administrator does not undo it.
      await TtsService.setSpeechLanguage(SpeechLanguage.hindi);
      expect(
        await AuthSessionService.applyAdministratorSpeech({
          'language': 'kn',
          'rate': 0.75,
        }),
        isFalse,
      );
      expect(prefs.getString('speech_language'), 'hi');

      // A new choice from the administrator applies once more.
      expect(
        await AuthSessionService.applyAdministratorSpeech({
          'language': 'te',
          'rate': 0.75,
        }),
        isTrue,
      );
      expect(TtsService.selectedLanguage, SpeechLanguage.telugu);
      expect(prefs.getDouble('tts_speech_rate'), 0.75);
      await TtsService.setSpeechLanguage(SpeechLanguage.english);
    },
  );
}
