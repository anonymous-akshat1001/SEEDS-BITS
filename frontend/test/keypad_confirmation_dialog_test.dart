import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/widgets/keypad_confirmation_dialog.dart';

void main() {
  testWidgets('custom keypad keys confirm and cancel a dialog', (tester) async {
    bool? result;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              result = await showDialog<bool>(
                context: context,
                barrierDismissible: false,
                builder: (_) => const KeypadConfirmationDialog(
                  title: 'Leave session?',
                  message: 'Return to the dashboard?',
                  cancelLabel: 'Stay',
                  confirmLabel: 'Leave',
                  cancelKey: 0,
                  confirmKey: 1,
                ),
              );
            },
            child: const Text('Open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.digit1);
    await tester.pumpAndSettle();
    expect(result, isTrue);

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.digit0);
    await tester.pumpAndSettle();
    expect(result, isFalse);
  });
}
