import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/screens/settings_screen.dart';
import 'package:frontend/services/tts_service.dart';
import 'package:frontend/widgets/key_instruction_wrapper.dart';
import 'package:frontend/widgets/chat_panel.dart';
import 'package:frontend/services/sse_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _ChatEvents extends SseService {
  MsgHandler? handler;

  @override
  void registerChatHandler(MsgHandler h) => handler = h;

  @override
  void unregisterChatHandler(MsgHandler h) => handler = null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final spoken = <String>[];
  final calls = <String>[];
  final utterances = <Completer<int>>[];
  var holdSpeech = false;
  var failSpeech = false;
  String? failureMessage;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    spoken.clear();
    calls.clear();
    utterances.clear();
    holdSpeech = false;
    failSpeech = false;
    failureMessage = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('flutter_tts'), (
          call,
        ) async {
          calls.add(call.method);
          if (call.method == 'speak') {
            final arguments = call.arguments;
            final text = arguments is Map ? arguments['text'] : arguments;
            if (text is! String) {
              throw StateError('Unexpected speech arguments');
            }
            spoken.add(text);
            if (failSpeech) {
              throw PlatformException(
                code: 'voice_unavailable',
                message: failureMessage,
              );
            }
            if (holdSpeech) {
              final completion = Completer<int>();
              utterances.add(completion);
              return completion.future;
            }
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

  tearDown(() async {
    await TtsService.stop();
    for (final completion in utterances) {
      if (!completion.isCompleted) completion.complete(1);
    }
  });

  testWidgets(
    'native speech errors never log private spoken content or platform error details',
    (tester) async {
      final previous = debugPrint;
      final logs = <String>[];
      try {
        debugPrint = (message, {wrapWidth}) {
          if (message != null) logs.add(message);
        };
        failSpeech = true;
        failureMessage = '012345678901 private credential';
        await TtsService.speak('012345678901 private credential');
        await tester.pump();
        expect(logs.join(' '), contains('PlatformException'));
        expect(logs.join(' '), isNot(contains('012345678901')));
        expect(logs.join(' '), isNot(contains('private credential')));
      } finally {
        debugPrint = previous;
      }
    },
  );

  testWidgets('incidental event storms never interrupt requested explanation', (
    tester,
  ) async {
    holdSpeech = true;
    await TtsService.speak('An important explanation.');
    final stops = calls.where((method) => method == 'stop').length;
    for (var event = 0; event < 100; event++) {
      await TtsService.speak(
        'Student $event joined',
        priority: SpeechPriority.incidental,
        group: 'Participants joined',
      );
    }
    await tester.pump(const Duration(seconds: 3));
    expect(spoken, ['An important explanation.']);
    expect(calls.where((method) => method == 'stop').length, stops);
  });

  testWidgets('only the current speech completion resumes the recorded item', (
    tester,
  ) async {
    holdSpeech = true;
    final owner = Object();
    var pauses = 0;
    var resumes = 0;
    TtsService.registerRecordedPlayback(
      owner,
      isPlaying: () => true,
      item: () => 10,
      pause: () async {
        pauses++;
      },
      resume: () async {
        resumes++;
      },
    );
    addTearDown(() => TtsService.unregisterRecordedPlayback(owner));
    await TtsService.speak('Read the lesson description.');
    await TtsService.speak(
      'New focused control.',
      priority: SpeechPriority.navigation,
    );
    expect(pauses, 1);
    expect(resumes, 0);
    utterances.first.complete(1);
    await tester.pump();
    expect(resumes, 0);
    utterances.last.complete(1);
    await tester.pump();
    expect(resumes, 1);
  });

  for (final change in ['paused', 'changed', 'disposed', 'backgrounded']) {
    testWidgets('speech never resumes a recording that was $change', (
      tester,
    ) async {
      holdSpeech = true;
      final owner = Object();
      var playing = true;
      var currentRoute = true;
      var item = 10;
      var resumes = 0;
      var skipped = 0;
      TtsService.registerRecordedPlayback(
        owner,
        isPlaying: () => playing,
        canResume: () => currentRoute,
        onResumeSkipped: () => skipped++,
        item: () => item,
        pause: () async {},
        resume: () async {
          resumes++;
        },
      );
      addTearDown(() => TtsService.unregisterRecordedPlayback(owner));
      await TtsService.speak('Read this control.');
      switch (change) {
        case 'paused':
          playing = false;
        case 'changed':
          item = 11;
        case 'disposed':
          TtsService.unregisterRecordedPlayback(owner);
        case 'backgrounded':
          currentRoute = false;
      }
      utterances.single.complete(1);
      await tester.pump();
      expect(resumes, 0);
      expect(skipped, change == 'backgrounded' ? 1 : 0);
    });
  }

  testWidgets('Stop speech releases a paused lesson exactly once', (
    tester,
  ) async {
    holdSpeech = true;
    final owner = Object();
    var resumes = 0;
    TtsService.registerRecordedPlayback(
      owner,
      isPlaying: () => true,
      item: () => 10,
      pause: () async {},
      resume: () async {
        resumes++;
      },
    );
    addTearDown(() => TtsService.unregisterRecordedPlayback(owner));
    await TtsService.speak('Long explanation.');
    await TtsService.stop();
    expect(resumes, 1);
    utterances.single.complete(1);
    await tester.pump();
    expect(resumes, 1);
  });

  testWidgets('live class updates wait for an explicit read request', (
    tester,
  ) async {
    final owner = Object();
    TtsService.registerLiveSession(owner);
    addTearDown(() => TtsService.unregisterLiveSession(owner));
    for (var event = 0; event < 3; event++) {
      await TtsService.speak(
        'Someone joined.',
        priority: SpeechPriority.incidental,
        group: 'Participants joined',
      );
    }
    await tester.pump(const Duration(seconds: 5));
    expect(spoken, isEmpty);
    await TtsService.readPendingUpdates();
    await tester.pump();
    expect(spoken.single, contains('Participants joined, 3 updates'));
  });

  testWidgets(
    'screen-reader mode never speaks or enables narration through star',
    (tester) async {
      await TtsService.configure(
        enabled: false,
        volume: 0,
        mode: SpeechMode.screenReader,
      );
      await tester.pumpWidget(
        const MaterialApp(
          home: KeypadInstructionWrapper(
            autoPlay: false,
            actions: {},
            labels: {1: 'Example action'},
            child: Scaffold(body: Text('Screen-reader test')),
          ),
        ),
      );
      await tester.sendKeyEvent(
        LogicalKeyboardKey.asterisk,
        physicalKey: PhysicalKeyboardKey.numpadMultiply,
      );
      await tester.pump();
      await TtsService.speak('Must remain silent.');
      expect(spoken, isEmpty);
      expect(TtsService.isEnabled, isFalse);
      expect(TtsService.volume, 0);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'navigation star restores disabled zero-volume app speech and help',
    (tester) async {
      await TtsService.configure(enabled: false, volume: 0);
      await tester.pumpWidget(
        const MaterialApp(
          home: KeypadInstructionWrapper(
            autoPlay: false,
            screenName: 'Recovery test',
            actions: {},
            labels: {1: 'Example action'},
            child: Scaffold(body: Text('Recovery test')),
          ),
        ),
      );
      await tester.sendKeyEvent(
        LogicalKeyboardKey.asterisk,
        physicalKey: PhysicalKeyboardKey.numpadMultiply,
      );
      await tester.pumpAndSettle();
      expect(TtsService.isEnabled, isTrue);
      expect(TtsService.volume, greaterThan(0));
      expect(spoken.join(' '), contains('Example action'));
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('tts_enabled'), isTrue);
      expect(prefs.getDouble('tts_volume'), greaterThan(0));
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('native speech failure is visible and releases paused playback', (
    tester,
  ) async {
    failSpeech = true;
    final owner = Object();
    var resumes = 0;
    TtsService.registerRecordedPlayback(
      owner,
      isPlaying: () => true,
      item: () => 10,
      pause: () async {},
      resume: () async {
        resumes++;
      },
    );
    addTearDown(() => TtsService.unregisterRecordedPlayback(owner));
    await TtsService.speak('Cannot be spoken.');
    await tester.pump();
    expect(TtsService.issue.value, contains('Speech failed'));
    expect(resumes, 1);
  });

  testWidgets('legacy chat defers incoming text and reads it with native OK', (
    tester,
  ) async {
    final events = _ChatEvents();
    await tester.pumpWidget(
      MaterialApp(
        home: KeypadInstructionWrapper(
          autoPlay: false,
          actions: const {},
          child: Scaffold(
            body: ChatPanel(ws: events, sessionId: '1', participantId: '3'),
          ),
        ),
      ),
    );
    events.handler!({
      'type': 'chat',
      'text': 'Please open lesson two.',
      'sender_name': 'Teacher',
    });
    events.handler!({
      'type': 'chat',
      'text': 'My own echoed text.',
      'is_own': true,
    });
    await tester.pump(const Duration(seconds: 3));
    expect(spoken, isEmpty);
    expect(find.text('My own echoed text.'), findsNothing);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(FocusManager.instance.primaryFocus?.debugLabel, 'chat-read-latest');
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(spoken.last, 'Teacher: Please open lesson two.');
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Essential narration keeps full help available on request', (
    tester,
  ) async {
    await TtsService.configure(verbosity: SpeechVerbosity.essential);
    await tester.pumpWidget(
      const MaterialApp(
        home: KeypadInstructionWrapper(
          screenName: 'Essential test',
          actions: {},
          labels: {1: 'Example action'},
          child: Scaffold(body: Text('Essential test')),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));
    expect(spoken.join(' '), contains('Press star for all shortcuts'));
    expect(spoken.join(' '), isNot(contains('Example action')));
    await TtsService.speak(
      'An incidental update.',
      priority: SpeechPriority.incidental,
    );
    await tester.pump(const Duration(seconds: 3));
    expect(spoken.join(' '), isNot(contains('An incidental update')));
    await tester.sendKeyEvent(
      LogicalKeyboardKey.asterisk,
      physicalKey: PhysicalKeyboardKey.numpadMultiply,
    );
    await tester.pumpAndSettle();
    expect(spoken.join(' '), contains('Example action'));
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('a stalled native Stop is bounded at two seconds', (
    tester,
  ) async {
    final stopped = Completer<int>();
    final messenger = tester.binding.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
      const MethodChannel('flutter_tts'),
      (call) async => call.method == 'stop' ? stopped.future : 1,
    );
    try {
      var finished = false;
      final operation = TtsService.stop().then((_) => finished = true);
      await tester.pump(const Duration(milliseconds: 1999));
      expect(finished, isFalse);
      await tester.pump(const Duration(milliseconds: 1));
      expect(finished, isTrue);
      expect(TtsService.issue.value, contains('Speech could not be stopped'));
      await operation;
    } finally {
      stopped.complete(1);
      messenger.setMockMethodCallHandler(
        const MethodChannel('flutter_tts'),
        (_) async => 1,
      );
    }
  });

  testWidgets('Settings persists manual mode and verbosity with D-pad access', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));
    await tester.pumpAndSettle();
    for (var move = 0; move < 15; move++) {
      if (FocusManager.instance.primaryFocus?.debugLabel ==
          'settings-speech-mode') {
        break;
      }
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
    }
    expect(
      FocusManager.instance.primaryFocus?.debugLabel,
      'settings-speech-mode',
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(TtsService.mode, SpeechMode.screenReader);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('speech_mode'), 'screenReader');
    final speechCount = spoken.length;
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(
      FocusManager.instance.primaryFocus?.debugLabel,
      'settings-verbosity',
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(TtsService.verbosity, SpeechVerbosity.detailed);
    expect(prefs.getString('speech_verbosity'), 'detailed');
    expect(spoken.length, speechCount);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
