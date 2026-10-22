import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/services/sse_service.dart';
import 'package:frontend/services/tts_service.dart';
import 'package:frontend/widgets/chat_panel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Sender extends SseService {
  final acknowledgment = Completer<ApiResult<Map<String, dynamic>>>();
  final sent = <Map<String, dynamic>>[];

  @override
  Future<ApiResult<Map<String, dynamic>>> send(Map<String, dynamic> message) {
    sent.add(message);
    return acknowledgment.future;
  }
}

Future<void> _withChat(
  WidgetTester tester,
  _Sender sender,
  Future<void> Function() check,
) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 260,
          height: 400,
          child: ChatPanel(ws: sender, sessionId: '42', participantId: '11'),
        ),
      ),
    ),
  );
  try {
    await check();
  } finally {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final spoken = <String>[];

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    spoken.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('flutter_tts'), (
          call,
        ) async {
          if (call.method == 'speak') {
            final arguments = call.arguments;
            final text = arguments is Map ? arguments['text'] : arguments;
            if (text is! String) {
              throw StateError('Unexpected speech arguments');
            }
            spoken.add(text);
          }
          return 1;
        });
    await TtsService.stop();
    await TtsService.configure(
      enabled: true,
      volume: 1,
      mode: SpeechMode.selfVoicing,
      verbosity: SpeechVerbosity.standard,
    );
  });

  tearDown(() async => TtsService.stop());

  testWidgets('pending sends cannot repeat and failure keeps the draft', (
    tester,
  ) async {
    final sender = _Sender();
    await _withChat(tester, sender, () async {
      await tester.enterText(find.byType(TextField), 'My question');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump();
      expect(find.text('My question\nSending'), findsOneWidget);
      final button = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.send),
      );
      expect(button.onPressed, isNull);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(sender.sent, [
        {'type': 'chat', 'text': 'My question'},
      ]);

      sender.acknowledgment.complete(
        const ApiResult.failure(
          ApiFailure(
            kind: ApiFailureKind.network,
            message: 'Message not confirmed. Check before trying again.',
          ),
        ),
      );
      await tester.pump();
      expect(find.text('My question\nNot confirmed'), findsOneWidget);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'My question',
      );
      expect(spoken, isNot(contains('Message sent.')));
      expect(
        spoken,
        contains('Message not confirmed. Check before trying again.'),
      );
    });
  });

  testWidgets('only accepted acknowledgment clears the unchanged draft', (
    tester,
  ) async {
    final sender = _Sender();
    await _withChat(tester, sender, () async {
      await tester.enterText(find.byType(TextField), 'My question');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(spoken, isNot(contains('Message sent.')));
      sender.acknowledgment.complete(const ApiResult.success({'ok': true}));
      await tester.pump();
      expect(find.text('My question\nSent'), findsOneWidget);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        isEmpty,
      );
      expect(spoken.where((text) => text == 'Message sent.'), hasLength(1));
    });
  });

  testWidgets('an older acknowledgment cannot erase a newly edited draft', (
    tester,
  ) async {
    final sender = _Sender();
    await _withChat(tester, sender, () async {
      await tester.enterText(find.byType(TextField), 'First question');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump();
      await tester.enterText(find.byType(TextField), 'Second question');
      sender.acknowledgment.complete(const ApiResult.success({'ok': true}));
      await tester.pump();
      expect(find.text('First question\nSent'), findsOneWidget);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'Second question',
      );
      expect(sender.sent, hasLength(1));
    });
  });

  testWidgets(
    'leaving chat ignores late acknowledgment without success speech',
    (tester) async {
      final sender = _Sender();
      await _withChat(tester, sender, () async {
        await tester.enterText(find.byType(TextField), 'My question');
        await tester.tap(find.byIcon(Icons.send));
        await tester.pump();
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
        sender.acknowledgment.complete(const ApiResult.success({'ok': true}));
        await tester.pump();
        expect(tester.takeException(), isNull);
        expect(spoken, isNot(contains('Message sent.')));
      });
    },
  );
}
