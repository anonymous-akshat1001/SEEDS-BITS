import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/main.dart' show routeObserver;
import 'package:frontend/services/tts_service.dart';
import 'package:frontend/widgets/key_instruction_wrapper.dart';
import 'package:frontend/widgets/keypad_paged_list.dart';
import 'package:frontend/widgets/keypad_text_step.dart';
import 'package:frontend/widgets/numbered_menu.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final spoken = <String>[];
  var speechStops = 0;

  setUp(() async {
    spoken.clear();
    speechStops = 0;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('flutter_tts'), (
          call,
        ) async {
          if (call.method == 'speak') spoken.add(call.arguments.toString());
          if (call.method == 'stop') speechStops++;
          return 1;
        });
    await TtsService.configure(
      enabled: true,
      mode: SpeechMode.selfVoicing,
      verbosity: SpeechVerbosity.standard,
    );
  });

  Widget app(Widget child) =>
      MaterialApp(navigatorObservers: [routeObserver], home: child);

  test('menus and list pages enforce the five-choice boundary', () {
    expect(
      () => NumberedMenu(
        title: 'Too many',
        choices: List.generate(
          6,
          (index) => NumberedChoice(label: '$index', onSelected: () {}),
        ),
      ),
      throwsArgumentError,
    );
    expect(
      () => KeypadListPage(items: List.generate(6, (index) => index)),
      throwsFormatException,
    );
    expect(
      () => KeypadListPage<int>(items: [], nextCursor: 'next'),
      throwsFormatException,
    );
  });

  testWidgets('menu digits, D-pad and touch use the same action', (
    tester,
  ) async {
    var selected = 0;
    await tester.pumpWidget(
      app(
        NumberedMenu(
          title: 'Lessons',
          autoPlay: false,
          choices: [
            NumberedChoice(label: 'Play', onSelected: () => selected++),
          ],
        ),
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.digit1);
    expect(selected, 1);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    expect(selected, 2);
    await tester.tap(find.text('1: Play'));
    expect(selected, 3);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('separate quick presses work without timing-dependent debounce', (
    tester,
  ) async {
    var selected = 0;
    await tester.pumpWidget(
      app(
        NumberedMenu(
          title: 'Menu',
          autoPlay: false,
          choices: [
            NumberedChoice(label: 'Select', onSelected: () => selected++),
          ],
        ),
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.digit1);
    await tester.sendKeyEvent(LogicalKeyboardKey.digit1);
    expect(selected, 2);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('a held menu key cannot confirm the destination', (tester) async {
    var confirmations = 0;
    await tester.pumpWidget(
      app(
        Builder(
          builder: (context) => NumberedMenu(
            title: 'Choose',
            autoPlay: false,
            choices: [
              NumberedChoice(
                label: 'Open review',
                onSelected: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => NumberedMenu(
                      title: 'Review',
                      autoPlay: false,
                      choices: [
                        NumberedChoice(
                          label: 'Confirm',
                          onSelected: () => confirmations++,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.sendKeyDownEvent(LogicalKeyboardKey.digit1);
    await tester.pumpAndSettle();
    await tester.sendKeyRepeatEvent(LogicalKeyboardKey.digit1);
    expect(confirmations, 0);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.digit1);
    await tester.sendKeyEvent(LogicalKeyboardKey.digit1);
    expect(confirmations, 1);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('hash stops narration instead of popping numbered screens', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(NumberedMenu(title: 'Stay here', autoPlay: false, choices: const [])),
    );
    final previous = speechStops;
    await tester.sendKeyEvent(
      LogicalKeyboardKey.numberSign,
      physicalKey: PhysicalKeyboardKey.digit3,
    );
    await tester.pump();
    expect(find.text('Stay here'), findsOneWidget);
    expect(speechStops, greaterThan(previous));
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('disabled choices keep their number and cannot execute', (
    tester,
  ) async {
    var selected = 0;
    await tester.pumpWidget(
      app(
        NumberedMenu(
          title: 'Choices',
          autoPlay: false,
          choices: [
            NumberedChoice(
              label: 'Unavailable',
              enabled: false,
              onSelected: () => selected++,
            ),
            NumberedChoice(
              label: 'Available',
              onSelected: () => selected += 10,
            ),
          ],
        ),
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.digit1);
    await tester.pump();
    expect(selected, 0);
    expect(spoken.join(), contains('not available'));
    await tester.sendKeyEvent(LogicalKeyboardKey.digit2);
    expect(selected, 10);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'text entry owns digits, star and hash; fallback enables Continue',
    (tester) async {
      final controller = TextEditingController(text: 'secret-password');
      final calls = <String>[];
      await tester.pumpWidget(
        app(
          KeypadTextStep(
            title: 'Password',
            label: 'Hidden password',
            controller: controller,
            obscureText: true,
            onContinue: (value) async => calls.add(value),
          ),
        ),
      );
      await tester.pump();
      expect(FocusManager.instance.primaryFocus?.debugLabel, 'step-input');
      for (final key in [
        LogicalKeyboardKey.digit0,
        LogicalKeyboardKey.digit1,
        LogicalKeyboardKey.asterisk,
        LogicalKeyboardKey.numberSign,
      ]) {
        await tester.sendKeyEvent(
          key,
          physicalKey: key == LogicalKeyboardKey.asterisk
              ? PhysicalKeyboardKey.numpadMultiply
              : key == LogicalKeyboardKey.numberSign
              ? PhysicalKeyboardKey.digit3
              : null,
        );
      }
      expect(calls, isEmpty);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.digit1);
      await tester.pump();
      expect(calls, ['secret-password']);
      expect(spoken.join(), isNot(contains('secret-password')));
      await tester.pumpWidget(const SizedBox.shrink());
      controller.dispose();
    },
  );

  testWidgets('native Done validates the field and retains invalid input', (
    tester,
  ) async {
    final controller = TextEditingController(text: 'short');
    var submitted = 0;
    await tester.pumpWidget(
      app(
        KeypadTextStep(
          title: 'Phone',
          label: 'Phone number',
          controller: controller,
          validate: (value) => value.length != 10 ? 'Enter ten digits.' : null,
          onContinue: (_) async => submitted++,
        ),
      ),
    );
    await tester.pump();
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(submitted, 0);
    expect(controller.text, 'short');
    expect(find.text('Enter ten digits.'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '9000000000');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(submitted, 1);
    await tester.pumpWidget(const SizedBox.shrink());
    controller.dispose();
  });

  testWidgets('a pending Continue is sent only once', (tester) async {
    final pending = Completer<void>();
    final controller = TextEditingController(text: 'value');
    var submitted = 0;
    await tester.pumpWidget(
      app(
        KeypadTextStep(
          title: 'Input',
          label: 'Name',
          controller: controller,
          onContinue: (_) {
            submitted++;
            return pending.future;
          },
        ),
      ),
    );
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyEvent(LogicalKeyboardKey.digit1);
    await tester.sendKeyEvent(LogicalKeyboardKey.digit1);
    expect(submitted, 1);
    pending.complete();
    await tester.pump();
    await tester.pumpWidget(const SizedBox.shrink());
    controller.dispose();
  });

  testWidgets('large lists request five items and search the complete source', (
    tester,
  ) async {
    final queries = <KeypadListQuery>[];
    final selected = <int>[];
    final source = List.generate(1000, (index) => index + 1);
    Future<KeypadListPage<int>> load(KeypadListQuery query) async {
      queries.add(query);
      final matches = source
          .where((item) => query.search.isEmpty || '$item' == query.search)
          .toList();
      final offset = int.parse(query.cursor ?? '0');
      final items = matches.skip(offset).take(5).toList();
      return KeypadListPage(
        items: items,
        nextCursor: offset + items.length < matches.length
            ? '${offset + items.length}'
            : null,
      );
    }

    await tester.pumpWidget(
      app(
        KeypadPagedList<int>(
          title: 'Lessons',
          scope: 'account-a',
          loadPage: load,
          labelOf: (value) => 'Lesson $value',
          onSelected: selected.add,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(ElevatedButton), findsNWidgets(5));
    expect(find.text('1: Lesson 1'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.digit9);
    await tester.pumpAndSettle();
    expect(find.text('1: Lesson 6'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.digit1);
    expect(selected, [6]);
    await tester.sendKeyEvent(LogicalKeyboardKey.digit7);
    await tester.pumpAndSettle();
    expect(find.text('1: Lesson 1'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.digit8);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '999');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(queries.last.search, '999');
    expect(queries.last.cursor, isNull);
    expect(find.text('1: Lesson 999'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('failed next page keeps the current choices and permits retry', (
    tester,
  ) async {
    var fail = true;
    await tester.pumpWidget(
      app(
        KeypadPagedList<int>(
          title: 'Lessons',
          scope: 'account-a',
          loadPage: (query) async {
            if (query.cursor == 'next') {
              if (fail) throw const KeypadListException('Connection failed.');
              return KeypadListPage(items: [6]);
            }
            return KeypadListPage(items: [1, 2, 3, 4, 5], nextCursor: 'next');
          },
          labelOf: (value) => 'Lesson $value',
          onSelected: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.digit9);
    await tester.pumpAndSettle();
    expect(find.text('Connection failed.'), findsOneWidget);
    expect(find.text('1: Lesson 1'), findsOneWidget);
    fail = false;
    await tester.sendKeyEvent(LogicalKeyboardKey.digit6);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.digit3);
    await tester.pumpAndSettle();
    expect(find.text('1: Lesson 6'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('an account change discards stale asynchronous page results', (
    tester,
  ) async {
    final old = Completer<KeypadListPage<int>>();
    Widget list(String scope) => app(
      KeypadPagedList<int>(
        title: 'Private lessons',
        scope: scope,
        loadPage: (_) => scope == 'a'
            ? old.future
            : Future.value(KeypadListPage(items: [2])),
        labelOf: (value) => 'Lesson $value',
        onSelected: (_) {},
      ),
    );
    await tester.pumpWidget(list('a'));
    await tester.pumpWidget(list('b'));
    await tester.pumpAndSettle();
    old.complete(KeypadListPage(items: [1]));
    await tester.pumpAndSettle();
    expect(find.text('1: Lesson 2'), findsOneWidget);
    expect(find.text('1: Lesson 1'), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('numbered menus reflow on the target display with large text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(240, 320);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      app(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.5)),
          child: NumberedMenu(
            title: 'Learning choices',
            autoPlay: false,
            choices: List.generate(
              5,
              (index) => NumberedChoice(
                label: 'A clear learning choice ${index + 1}',
                onSelected: () {},
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('legacy hash behavior is retained for unmigrated screens', (
    tester,
  ) async {
    var hashActions = 0;
    await tester.pumpWidget(
      app(
        KeypadInstructionWrapper(
          autoPlay: false,
          actions: const {},
          onHashKey: () => hashActions++,
          child: const Scaffold(body: Text('Legacy')),
        ),
      ),
    );
    await tester.sendKeyEvent(
      LogicalKeyboardKey.numberSign,
      physicalKey: PhysicalKeyboardKey.digit3,
    );
    expect(hashActions, 1);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
