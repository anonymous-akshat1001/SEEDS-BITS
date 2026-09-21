import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/main.dart';
import 'package:frontend/screens/login_screen.dart';
import 'package:frontend/screens/register_screen.dart';
import 'package:frontend/screens/settings_screen.dart';
import 'package:frontend/utils/ui_utils.dart';
import 'package:frontend/widgets/keypad_confirmation_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    UIUtils.setHighContrastMode(false);
    UIUtils.setTextScale(1.0);
  });

  testWidgets('login validates locally and password visibility works', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
    await tester.pump(const Duration(milliseconds: 100));

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), '9876543210');
    await tester.enterText(fields.at(1), 'short');
    await tester.tap(find.text('1: Login'));
    await tester.pump();
    expect(
      find.text('Password must be at least 6 characters.'),
      findsOneWidget,
    );

    var passwordField = tester.widget<TextField>(fields.at(1));
    expect(passwordField.obscureText, isTrue);
    await tester.tap(find.byTooltip('Show password'));
    await tester.pump();
    passwordField = tester.widget<TextField>(fields.at(1));
    expect(passwordField.obscureText, isFalse);
  });

  testWidgets('registration validates locally and password visibility works', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: RegisterScreen()));
    await tester.pump();

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Student');
    await tester.enterText(fields.at(1), '9876543210');
    await tester.enterText(fields.at(2), 'short');
    await tester.tap(find.text('1: Register'));
    await tester.pump();
    expect(
      find.text('Password must be at least 6 characters.'),
      findsOneWidget,
    );

    var passwordField = tester.widget<TextField>(fields.at(2));
    expect(passwordField.obscureText, isTrue);
    await tester.tap(find.byTooltip('Show password'));
    await tester.pump();
    passwordField = tester.widget<TextField>(fields.at(2));
    expect(passwordField.obscureText, isFalse);
  });

  testWidgets('Settings hides sync tolerance and persists high contrast', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));
    await tester.pumpAndSettle();
    expect(find.text('Sync Tolerance'), findsNothing);
    expect(
      find.textContaining('Available only inside active sessions'),
      findsOneWidget,
    );

    await tester.scrollUntilVisible(
      find.text('High Contrast'),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text('High Contrast'));
    await tester.pump();
    await tester.scrollUntilVisible(
      find.text('Save Settings'),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text('Save Settings'));
    await tester.pump();
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('high_contrast_mode'), isTrue);
    expect(prefs.containsKey('audio_sync_tolerance'), isFalse);
  });

  testWidgets('Settings supports D-pad, Enter, sliders, and reset dialog', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));
    await tester.pumpAndSettle();

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    expect(FocusManager.instance.primaryFocus?.debugLabel, 'settings-back');
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    expect(FocusManager.instance.primaryFocus?.debugLabel, 'settings-reset');
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    expect(FocusManager.instance.primaryFocus?.debugLabel, 'settings-tts');

    expect(
      tester.widget<SwitchListTile>(find.byType(SwitchListTile).first).value,
      isTrue,
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(
      tester.widget<SwitchListTile>(find.byType(SwitchListTile).first).value,
      isFalse,
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    expect(FocusManager.instance.primaryFocus?.debugLabel, 'settings-volume');
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pump();
    expect(
      tester.widget<Slider>(find.byType(Slider).first).value,
      closeTo(0.9, 0.001),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    expect(FocusManager.instance.primaryFocus?.debugLabel, 'settings-rate');

    await tester.tap(find.byTooltip('Reset to Defaults'));
    await tester.pumpAndSettle();
    expect(find.text('Reset Settings'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    expect(
      FocusManager.instance.primaryFocus?.debugLabel,
      'settings-reset-cancel',
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    expect(
      FocusManager.instance.primaryFocus?.debugLabel,
      'settings-reset-confirm',
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.text('Reset Settings'), findsNothing);
    expect(
      tester.widget<SwitchListTile>(find.byType(SwitchListTile).first).value,
      isTrue,
    );
  });

  testWidgets('startup loading screen is branded and accessible', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(const MaterialApp(home: SeedsLoadingScreen()));
    expect(find.text('SEEDS'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label == 'SEEDS is loading' &&
            widget.properties.liveRegion == true,
      ),
      findsOneWidget,
    );
    semantics.dispose();
  });

  testWidgets('Welcome remains usable at 1.3x text scale', (tester) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(
          size: Size(360, 640),
          textScaler: TextScaler.linear(1.3),
        ),
        child: const MaterialApp(home: WelcomeScreen()),
      ),
    );
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Register'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Settings changes and persists app text size', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));
    await tester.pumpAndSettle();

    final textSizeSlider = find.byType(Slider).last;
    tester.widget<Slider>(textSizeSlider).onChanged!(1.4);
    await tester.pump();
    expect(UIUtils.textScaleListenable.value, 1.4);

    await tester.scrollUntilVisible(
      find.text('Save Settings'),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text('Save Settings'));
    await tester.pump();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getDouble('text_scale'), 1.4);
  });

  testWidgets('permission explanations support keypad choices', (tester) async {
    bool? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () async {
                result = await showDialog<bool>(
                  context: context,
                  builder: (_) => const KeypadConfirmationDialog(
                    title: 'Microphone access',
                    message: 'Used only during an active session.',
                    confirmLabel: 'Continue',
                  ),
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    expect(FocusManager.instance.primaryFocus?.debugLabel, 'dialog-cancel');
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    expect(FocusManager.instance.primaryFocus?.debugLabel, 'dialog-confirm');
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(result, isTrue);
  });
}
