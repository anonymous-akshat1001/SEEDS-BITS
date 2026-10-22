import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/services/tts_service.dart';
import 'package:frontend/widgets/key_instruction_wrapper.dart';
import 'package:frontend/main.dart' show routeObserver;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('flutter_tts'),
          (_) async => 1,
        );
  });

  testWidgets(
    'D-pad traverses, edit mode suppresses shortcuts, and Up exits editing',
    (tester) async {
      final first = FocusNode(debugLabel: 'first');
      final input = FocusNode(debugLabel: 'input');
      final controller = KeypadNavigationController();
      var shortcuts = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: KeypadInstructionWrapper(
            autoPlay: false,
            navigationController: controller,
            actions: {1: () => shortcuts++},
            focusTargets: [
              KeypadFocusTarget(node: first, label: 'First'),
              KeypadFocusTarget(node: input, label: 'Input', isTextField: true),
            ],
            child: Scaffold(
              body: Column(
                children: [
                  Focus(focusNode: first, child: const Text('First')),
                  TextField(focusNode: input),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      expect(first.hasFocus, isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      expect(input.hasFocus, isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(controller.isEditing, isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.digit1);
      expect(shortcuts, 0);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      expect(first.hasFocus, isTrue);
      expect(controller.isEditing, isFalse);
      await tester.sendKeyEvent(LogicalKeyboardKey.digit1);
      expect(shortcuts, 1);

      await tester.pumpWidget(const SizedBox.shrink());
      first.dispose();
      input.dispose();
    },
  );

  testWidgets('Star repeats and slider Left/Right does not trap D-pad', (
    tester,
  ) async {
    final before = FocusNode();
    final slider = FocusNode();
    var repeats = 0;
    var value = 1;
    var nativeAdjustments = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: KeypadInstructionWrapper(
          autoPlay: false,
          actions: const {},
          onStarKey: () => repeats++,
          focusTargets: [
            KeypadFocusTarget(node: before, label: 'Before'),
            KeypadFocusTarget(
              node: slider,
              label: 'Slider',
              onDecrease: () => value--,
              onIncrease: () => value++,
            ),
          ],
          child: Scaffold(
            body: Column(
              children: [
                Focus(focusNode: before, child: const Text('Before')),
                Slider(
                  focusNode: slider,
                  value: 0.5,
                  onChanged: (_) => nativeAdjustments++,
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.sendKeyEvent(LogicalKeyboardKey.numpadMultiply);
    expect(repeats, 1);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    expect(slider.hasFocus, isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    expect(value, 2);
    expect(nativeAdjustments, 0);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    expect(before.hasFocus, isTrue);
    expect(nativeAdjustments, 0);

    await tester.pumpWidget(const SizedBox.shrink());
    before.dispose();
    slider.dispose();
  });

  testWidgets('digits do not trigger shortcuts in a touch-focused text field', (
    tester,
  ) async {
    final input = FocusNode(debugLabel: 'touch-input');
    var shortcuts = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: KeypadInstructionWrapper(
          autoPlay: false,
          actions: {1: () => shortcuts++},
          focusTargets: [
            KeypadFocusTarget(
              node: input,
              label: 'Phone number',
              isTextField: true,
            ),
          ],
          child: Scaffold(body: TextField(focusNode: input)),
        ),
      ),
    );
    await tester.tap(find.byType(TextField));
    await tester.pump();
    expect(input.hasFocus, isTrue);

    await tester.sendKeyEvent(LogicalKeyboardKey.digit1);
    expect(shortcuts, 0);

    await tester.pumpWidget(const SizedBox.shrink());
    input.dispose();
  });

  testWidgets('star and hash stay available to a field while editing', (
    tester,
  ) async {
    final input = FocusNode(debugLabel: 'punctuation-input');
    final navigation = KeypadNavigationController();
    var repeats = 0;
    var exits = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: KeypadInstructionWrapper(
          autoPlay: false,
          actions: const {},
          navigationController: navigation,
          onStarKey: () => repeats++,
          onHashKey: () => exits++,
          focusTargets: [
            KeypadFocusTarget(node: input, label: 'Message', isTextField: true),
          ],
          child: Scaffold(body: TextField(focusNode: input)),
        ),
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    expect(navigation.isEditing, isTrue);
    await tester.sendKeyEvent(
      LogicalKeyboardKey.asterisk,
      physicalKey: PhysicalKeyboardKey.numpadMultiply,
    );
    await tester.sendKeyEvent(
      LogicalKeyboardKey.numberSign,
      physicalKey: PhysicalKeyboardKey.digit3,
    );
    expect(repeats, 0);
    expect(exits, 0);
    expect(input.hasFocus, isTrue);
    await tester.pumpWidget(const SizedBox.shrink());
    input.dispose();
  });

  testWidgets('OK activates a native button on a legacy wrapped screen', (
    tester,
  ) async {
    var activations = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: KeypadInstructionWrapper(
          autoPlay: false,
          actions: const {},
          child: Scaffold(
            body: ElevatedButton(
              onPressed: () => activations++,
              child: const Text('Activate'),
            ),
          ),
        ),
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(activations, 1);
  });

  testWidgets('a new TTS announcement stops the previous announcement', (
    tester,
  ) async {
    final methods = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('flutter_tts'),
      (call) async {
        methods.add(call.method);
        return 1;
      },
    );

    await TtsService.configure(enabled: true);
    methods.clear();
    await TtsService.speak('First screen');
    await TtsService.speak('Second screen');

    expect(methods, ['stop', 'speak', 'stop', 'speak']);
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('flutter_tts'),
      null,
    );
  });

  testWidgets(
    'D-pad falls back to native traversal on legacy wrapped screens',
    (tester) async {
      final first = FocusNode(debugLabel: 'legacy-first');
      final input = FocusNode(debugLabel: 'legacy-input');
      var shortcuts = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: KeypadInstructionWrapper(
            autoPlay: false,
            actions: {1: () => shortcuts++},
            child: Scaffold(
              body: Column(
                children: [
                  ElevatedButton(
                    focusNode: first,
                    onPressed: () {},
                    child: const Text('First'),
                  ),
                  TextField(focusNode: input),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      expect(first.hasFocus, isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      expect(input.hasFocus, isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.digit1);
      expect(shortcuts, 0);

      await tester.pumpWidget(const SizedBox.shrink());
      first.dispose();
      input.dispose();
    },
  );

  testWidgets('popping a route announces the screen that becomes current', (
    tester,
  ) async {
    final spoken = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('flutter_tts'),
      (call) async {
        if (call.method == 'speak') spoken.add(call.arguments.toString());
        return 1;
      },
    );
    await TtsService.configure(enabled: true);

    await tester.pumpWidget(
      MaterialApp(
        navigatorObservers: [routeObserver],
        home: const _AnnouncementPage(name: 'First screen', hasNext: true),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));
    expect(spoken.last, contains('First screen'));

    spoken.clear();
    await tester.tap(find.text('Next'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(spoken.last, contains('Second screen'));

    spoken.clear();
    await tester.tap(find.text('Back'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 550));
    expect(spoken.last, contains('First screen'));

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('flutter_tts'),
      null,
    );
  });

  testWidgets('hash goes back and restores the previously focused control', (
    tester,
  ) async {
    final opener = FocusNode(debugLabel: 'restore-opener');
    await tester.pumpWidget(
      MaterialApp(
        navigatorObservers: [routeObserver],
        home: Builder(
          builder: (context) => KeypadInstructionWrapper(
            autoPlay: false,
            actions: const {},
            focusTargets: [
              KeypadFocusTarget(
                node: opener,
                label: 'Open details',
                onActivate: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const KeypadInstructionWrapper(
                      autoPlay: false,
                      actions: {},
                      child: Scaffold(body: Text('Details')),
                    ),
                  ),
                ),
              ),
            ],
            child: Scaffold(
              body: TextButton(
                focusNode: opener,
                onPressed: () {},
                child: const Text('Open details'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.text('Details'), findsOneWidget);
    await tester.sendKeyEvent(
      LogicalKeyboardKey.numberSign,
      physicalKey: PhysicalKeyboardKey.digit3,
    );
    await tester.pumpAndSettle();
    expect(find.text('Details'), findsNothing);
    expect(opener.hasFocus, isTrue);
    await tester.pumpWidget(const SizedBox.shrink());
    opener.dispose();
  });
}

class _AnnouncementPage extends StatelessWidget {
  const _AnnouncementPage({required this.name, required this.hasNext});

  final String name;
  final bool hasNext;

  @override
  Widget build(BuildContext context) {
    return KeypadInstructionWrapper(
      screenName: name,
      actions: const {},
      child: Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: hasNext
                ? () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => const _AnnouncementPage(
                        name: 'Second screen',
                        hasNext: false,
                      ),
                    ),
                  )
                : () => Navigator.pop(context),
            child: Text(hasNext ? 'Next' : 'Back'),
          ),
        ),
      ),
    );
  }
}
