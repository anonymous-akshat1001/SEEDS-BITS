import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/services/session_voice_controller.dart';

void main() {
  late SessionVoiceController voice;
  late List<void Function(String, bool)> results;
  late List<String> commands;
  late List<String> issues;
  late List<String> order;
  var available = true;
  var quiet = true;
  var current = true;
  Completer<bool>? initializeGate;
  Completer<void>? cancelGate;
  Completer<void>? listenGate;
  var initializes = 0;
  var listens = 0;
  var cancels = 0;

  setUp(() {
    results = [];
    commands = [];
    issues = [];
    order = [];
    available = quiet = current = true;
    initializeGate = null;
    cancelGate = null;
    listenGate = null;
    initializes = listens = cancels = 0;
    voice = SessionVoiceController(
      stopSpeech: () async {
        order.add('quiet');
        return quiet;
      },
      initialize: () async {
        initializes++;
        order.add('initialize');
        return initializeGate == null ? available : initializeGate!.future;
      },
      listen: (callback) async {
        listens++;
        results.add(callback);
        order.add('listen');
        await listenGate?.future;
      },
      cancel: () async {
        cancels++;
        await cancelGate?.future;
        order.add('cancel');
      },
      canAct: () => current,
      onCommand: (command) async {
        order.add('command');
        commands.add(command);
      },
      onIssue: issues.add,
    );
  });

  tearDown(() => voice.dispose());

  testWidgets(
    'construction never initializes, listens, or cancels another owner',
    (tester) async {
      expect(voice.busy, isFalse);
      expect(initializes, 0);
      expect(listens, 0);
      await voice.stop();
      expect(cancels, 0);
    },
  );

  testWidgets(
    'explicit start silences narration before initialization and one listen',
    (tester) async {
      await voice.start();
      expect(order, ['quiet', 'initialize', 'listen']);
      expect(voice.hasWindow, isTrue);
      expect(voice.status, contains('one command'));
      await voice.start();
      expect(listens, 1);
      await voice.stop();
    },
  );

  testWidgets(
    'confirmed cancellation precedes dispatch and duplicate results are discarded',
    (tester) async {
      await voice.start();
      results.single('unmute', false);
      expect(commands, isEmpty);
      results.single('unmute', true);
      results.single('unmute', true);
      await tester.pump();
      expect(order, ['quiet', 'initialize', 'listen', 'cancel', 'command']);
      expect(commands, ['unmute']);
      expect(voice.busy, isFalse);
      await tester.pump(const Duration(seconds: 20));
      expect(listens, 1);
    },
  );

  testWidgets(
    'the twelve-second bound ends capture without any automatic restart',
    (tester) async {
      await voice.start();
      await tester.pump(const Duration(seconds: 12));
      expect(voice.busy, isFalse);
      expect(cancels, 1);
      expect(issues.single, contains('No command heard'));
      await tester.pump(const Duration(seconds: 30));
      expect(listens, 1);
      results.single('unmute', true);
      expect(commands, isEmpty);
    },
  );

  testWidgets(
    'done permits a late final result but does not restart listening',
    (tester) async {
      await voice.start();
      voice.handleStatus('done');
      await tester.pump(const Duration(milliseconds: 200));
      expect(voice.status, contains('Finishing'));
      results.single('raise hand', true);
      await tester.pump();
      expect(commands, ['raise hand']);
      await tester.pump(const Duration(seconds: 20));
      expect(listens, 1);
    },
  );

  testWidgets('done without a final result ends cleanly with retry guidance', (
    tester,
  ) async {
    await voice.start();
    voice.handleStatus('notListening');
    await tester.pump(const Duration(milliseconds: 500));
    expect(voice.busy, isFalse);
    expect(issues.single, contains('Activate Listen'));
    expect(listens, 1);
  });

  testWidgets(
    'permission denial and failed TTS stop cannot start recognition',
    (tester) async {
      quiet = false;
      await voice.start();
      expect(initializes, 0);
      expect(listens, 0);
      expect(issues.single, contains('speech could not be stopped'));
      quiet = true;
      available = false;
      await voice.start();
      expect(listens, 0);
      expect(issues.last, contains('permission'));
      expect(voice.busy, isFalse);
    },
  );

  testWidgets('cancelling pending initialization prevents a late listen', (
    tester,
  ) async {
    final gate = initializeGate = Completer<bool>();
    final pending = voice.start();
    await tester.pump();
    await voice.stop();
    gate.complete(true);
    await pending;
    expect(listens, 0);
    expect(voice.busy, isFalse);
  });

  testWidgets('stale callbacks cannot act in a newer window or hidden route', (
    tester,
  ) async {
    await voice.start();
    final old = results.single;
    await voice.stop();
    await voice.start();
    old('unmute', true);
    expect(commands, isEmpty);
    current = false;
    results.last('unmute', true);
    await tester.pump();
    expect(commands, isEmpty);
    expect(voice.busy, isFalse);
  });

  testWidgets(
    'unconfirmed cancellation blocks new capture until explicit stop succeeds',
    (tester) async {
      await voice.start();
      final gate = cancelGate = Completer<void>();
      final stopping = voice.stop();
      await tester.pump(const Duration(seconds: 2));
      expect(await stopping, isFalse);
      expect(voice.status, contains('not confirmed'));
      await voice.start();
      expect(listens, 1);
      results.single('unmute', true);
      expect(commands, isEmpty);
      gate.complete();
      cancelGate = null;
      expect(await voice.stop(), isTrue);
      await voice.start();
      expect(listens, 2);
      await voice.stop();
    },
  );

  testWidgets(
    'stop waits for an in-flight native start before cancellation and permits no new window',
    (tester) async {
      final gate = listenGate = Completer<void>();
      final starting = voice.start();
      await tester.pump();
      expect(listens, 1);
      final stopping = voice.stop();
      await tester.pump();
      expect(cancels, 0);
      await voice.start();
      expect(listens, 1);
      gate.complete();
      await starting;
      expect(await stopping, isTrue);
      expect(cancels, 1);
      results.single('unmute', true);
      await tester.pump();
      expect(commands, isEmpty);
    },
  );

  testWidgets(
    'recognizer errors terminate rather than loop or execute old results',
    (tester) async {
      await voice.start();
      voice.handleError();
      await tester.pump();
      results.single('unmute', true);
      await tester.pump(const Duration(seconds: 20));
      expect(commands, isEmpty);
      expect(listens, 1);
      expect(issues.single, contains('could not finish'));
    },
  );
}
