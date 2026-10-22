import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/main.dart';
import 'package:frontend/screens/settings_screen.dart';
import 'package:frontend/services/tts_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final calls = <MethodCall>[];
  String scenario = 'installed';
  Completer<bool>? stalled;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    scenario = 'installed';
    stalled = null;
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('flutter_tts'), (
          call,
        ) async {
          calls.add(call);
          if (call.method == 'isLanguageAvailable') {
            if (scenario == 'stalled') {
              return (stalled ??= Completer<bool>()).future;
            }
            if (scenario == 'failure') {
              throw PlatformException(code: 'missing_engine');
            }
            if (scenario == 'missing') return false;
            if (scenario == 'fallback') return call.arguments == 'en-US';
            return true;
          }
          if (call.method == 'isLanguageInstalled') {
            return scenario != 'network';
          }
          return 1;
        });
    await TtsService.configure(enabled: true, mode: SpeechMode.selfVoicing);
  });

  tearDown(() async {
    stalled?.complete(false);
    await TtsService.stop();
  });

  for (final saved in <double?>[null, 0.4]) {
    testWidgets(
      'native rate uses 1.5x default without replacing saved rate $saved',
      (tester) async {
        SharedPreferences.setMockInitialValues({
          if (saved != null) 'tts_speech_rate': saved,
        });
        await TtsService.loadFromPreferences();
        expect(TtsService.defaultSpeechRate, 0.5 * 1.5);
        expect(
          calls.lastWhere((call) => call.method == 'setSpeechRate').arguments,
          saved ?? 0.75,
        );
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getDouble('tts_speech_rate'), saved);
      },
    );
  }

  testWidgets('Settings reset persists the faster default after confirmation', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'tts_speech_rate': 0.4});
    await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Reset to Defaults'));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.digit2);
    await tester.pumpAndSettle();
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getDouble('tts_speech_rate'), 0.75);
    expect(
      calls.lastWhere((call) => call.method == 'setSpeechRate').arguments,
      0.75,
    );
    await tester.pumpWidget(const SizedBox.shrink());
  });

  for (final mode in [
    'installed',
    'fallback',
    'network',
    'missing',
    'failure',
    'stalled',
  ]) {
    testWidgets('Settings 7 checks English directly and reports $mode honestly', (
      tester,
    ) async {
      scenario = mode;
      await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));
      await tester.pumpAndSettle();
      calls.clear();
      await tester.sendKeyEvent(LogicalKeyboardKey.digit7);
      await tester.pump();
      if (mode == 'stalled') await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      final message = switch (mode) {
        'installed' ||
        'fallback' => 'Android reports installed English voice data.',
        'network' =>
          'English is available, but installed offline voice data was not confirmed.',
        'missing' => 'No English voice was detected.',
        _ => 'English voice availability could not be verified.',
      };
      expect(find.textContaining(message), findsOneWidget);
      expect(find.textContaining('keypad practice'), findsNothing);
      if (mode == 'fallback') {
        expect(
          calls.where((call) => call.method == 'setLanguage').last.arguments,
          'en-US',
        );
      }
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }

  testWidgets('late English check never updates a disposed Settings route', (
    tester,
  ) async {
    scenario = 'stalled';
    await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.digit7);
    await tester.pump();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 3));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'voice check remains visible but app speech is silent in screen-reader mode',
    (tester) async {
      SharedPreferences.setMockInitialValues({'speech_mode': 'screenReader'});
      await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));
      await tester.pumpAndSettle();
      calls.clear();
      await tester.sendKeyEvent(LogicalKeyboardKey.digit7);
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Android reports installed English voice data.'),
        findsOneWidget,
      );
      expect(calls.where((call) => call.method == 'speak'), isEmpty);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('normal startup contains no keypad-practice route', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp(initialRoute: '/login'));
    await tester.pumpAndSettle();
    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.initialRoute, '/login');
    expect(app.routes!.keys, isNot(contains('/keypad_practice')));
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
