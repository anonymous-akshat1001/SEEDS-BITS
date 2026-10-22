import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/services/tts_service.dart';
import 'package:frontend/widgets/classroom_console_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final spoken = <String>[];
  late ValueNotifier<int> revision;
  late List<Map<String, dynamic>> participants;
  final acknowledged = <int>[];
  Completer<String?>? response;

  setUp(() async {
    spoken.clear();
    acknowledged.clear();
    response = null;
    revision = ValueNotifier(0);
    participants = [
      {
        'id': 1,
        'name': 'Later',
        'raised_hand': true,
        'hand_queue_order': 20,
        'is_muted': true,
      },
      {
        'id': 2,
        'name': 'First',
        'raised_hand': true,
        'hand_queue_order': 10,
        'is_muted': true,
      },
    ];
    SharedPreferences.setMockInitialValues({});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('flutter_tts'), (
          call,
        ) async {
          if (call.method == 'speak') {
            final arguments = call.arguments;
            spoken.add(
              arguments is String
                  ? arguments
                  : (arguments as Map)['text'] as String,
            );
          }
          return 1;
        });
    await TtsService.stop();
    await TtsService.configure(enabled: true, mode: SpeechMode.selfVoicing);
  });

  tearDown(() async {
    revision.dispose();
    await TtsService.stop();
  });

  Future<void> open(WidgetTester tester, {double textScale = 1}) async {
    tester.view.physicalSize = const Size(240, 320);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => showDialog<void>(
              context: context,
              builder: (_) => ClassroomConsoleDialog(
                revision: revision,
                participants: () => participants,
                summary: () =>
                    'Snapshot summary. Speaker identification unavailable.',
                acknowledge: (id, order) async {
                  acknowledged.add(id);
                  expect(
                    order,
                    participants.firstWhere(
                      (p) => p['id'] == id,
                    )['hand_queue_order'],
                  );
                  return response == null ? null : await response!.future;
                },
              ),
            ),
            child: const Text('Open console'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open console'));
    await tester.pumpAndSettle();
  }

  Future<void> activate(WidgetTester tester, String name) async {
    for (var count = 0; count < 30; count++) {
      if (FocusManager.instance.primaryFocus?.debugLabel == 'console-$name') {
        break;
      }
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
    }
    expect(FocusManager.instance.primaryFocus?.debugLabel, 'console-$name');
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
  }

  testWidgets(
    'FIFO next/previous selection and summary are keypad accessible at 240x320 with large text',
    (tester) async {
      await open(tester, textScale: 1.5);
      expect(find.textContaining('First. Hand 1 of 2.'), findsOneWidget);
      expect(spoken.any((text) => text.contains('Snapshot summary.')), isFalse);
      await activate(tester, 'summary');
      await tester.pumpAndSettle();
      expect(spoken.any((text) => text.contains('Snapshot summary.')), isTrue);
      await activate(tester, 'next');
      await tester.pumpAndSettle();
      expect(find.textContaining('Later. Hand 2 of 2.'), findsOneWidget);
      await activate(tester, 'previous');
      await tester.pumpAndSettle();
      expect(find.textContaining('First. Hand 1 of 2.'), findsOneWidget);
      expect(acknowledged, isEmpty);
      await activate(tester, 'stop');
      await activate(tester, 'back');
      await tester.pumpAndSettle();
      expect(find.text('Open console'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'unknown-order hands are labelled and a reconnect retains the selected identity',
    (tester) async {
      participants.add({
        'id': 3,
        'name': 'Legacy',
        'raised_hand': true,
        'is_muted': true,
      });
      await open(tester);
      expect(find.textContaining('Legacy. Hand 1 of 3.'), findsOneWidget);
      expect(
        find.textContaining('Original raise order unknown'),
        findsOneWidget,
      );
      await activate(tester, 'next');
      await tester.pumpAndSettle();
      participants = participants.reversed.toList();
      revision.value++;
      await tester.pump();
      expect(find.textContaining('First. Hand 2 of 3.'), findsOneWidget);
      participants.removeWhere((p) => p['id'] == 2);
      revision.value++;
      await tester.pump();
      expect(
        find.textContaining('The selected hand is no longer in the queue.'),
        findsOneWidget,
      );
      await activate(tester, 'next');
      await tester.pumpAndSettle();
      expect(find.textContaining('Legacy. Hand 1 of 2.'), findsOneWidget);
      expect(acknowledged, isEmpty);
    },
  );

  testWidgets(
    'acknowledgment stays pending, blocks duplicates and preserves the queue on failure',
    (tester) async {
      response = Completer<String?>();
      await open(tester);
      await activate(tester, 'acknowledge');
      expect(acknowledged, [2]);
      expect(
        find.textContaining('Waiting for server acknowledgment.'),
        findsOneWidget,
      );
      expect(find.textContaining('First. Hand 1 of 2.'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(acknowledged, [2]);
      response!.complete(
        'The server did not confirm the selected hand. Read the queue before retrying.',
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('The server did not confirm'), findsOneWidget);
      expect(find.textContaining('First. Hand 1 of 2.'), findsOneWidget);
      expect(participants.every((p) => p['is_muted'] == true), isTrue);
      await activate(tester, 'read');
      await tester.pumpAndSettle();
      expect(
        spoken.any((text) => text.contains('The server did not confirm')),
        isTrue,
      );
    },
  );
}
