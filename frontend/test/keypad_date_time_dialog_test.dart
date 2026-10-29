import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/widgets/keypad_date_time_dialog.dart';

void main() {
  testWidgets('numeric date fields validate and save through the keypad', (
    tester,
  ) async {
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('flutter_tts'),
      (_) async => 1,
    );
    DateTime? selected;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () async {
                selected = await showDialog<DateTime>(
                  context: context,
                  builder: (_) => KeypadDateTimeDialog(
                    initial: DateTime(2026, 10, 19, 13, 30),
                    firstDate: DateTime(2026, 10, 18),
                    lastDate: DateTime(2028, 10, 19),
                  ),
                );
              },
              child: const Text('Choose schedule'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Choose schedule'));
    await tester.pumpAndSettle();
    final fields = find.byType(TextField);
    expect(fields, findsNWidgets(5));
    Future<void> saveWithKeypad() async {
      for (var step = 0; step < 7; step++) {
        if (FocusManager.instance.primaryFocus?.debugLabel ==
            'date-time-save') {
          break;
        }
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pump();
      }
      expect(FocusManager.instance.primaryFocus?.debugLabel, 'date-time-save');
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
    }

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(FocusManager.instance.primaryFocus?.debugLabel, 'date-time-field-0');

    await tester.enterText(fields.at(0), '999999');
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.digit1);
    await tester.pump();
    expect(selected, isNull);
    expect(find.textContaining('Choose a valid date'), findsNothing);
    await saveWithKeypad();
    expect(find.textContaining('Choose a valid date'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.enterText(fields.at(0), '2026');
    await tester.enterText(fields.at(1), '11');
    await tester.enterText(fields.at(2), '31');
    await saveWithKeypad();
    expect(selected, isNull);
    expect(find.textContaining('Enter a valid date'), findsOneWidget);

    await tester.enterText(fields.at(2), '30');
    await saveWithKeypad();
    expect(selected, DateTime(2026, 11, 30, 13, 30));
  });
}
