import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/services/private_note_recorder.dart';
import 'package:frontend/services/private_note_store.dart';
import 'package:frontend/services/tts_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('seeds/private_notes');
  late Directory root;
  late PrivateNoteStore store;
  late PrivateNoteRecorder recorder;
  final calls = <String>[];
  var allowed = true;
  var current = true;
  var changed = false;
  String? id;
  var duration = 2000;
  Completer<bool>? startGate;
  setUp(() async {
    root = await Directory.systemTemp.createTemp('seeds-note-recorder-test-');
    calls.clear();
    allowed = current = true;
    changed = false;
    duration = 2000;
    startGate = null;
    id = null;
    PrivateNoteRecorder.liveSessions = 0;
    store = PrivateNoteStore(
      root: root,
      userId: 7,
      checkAccount: () async {
        if (changed) throw const PrivateNoteException('Account changed');
      },
    );
    SharedPreferences.setMockInitialValues({});
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
      const MethodChannel('flutter_tts'),
      (_) async => 1,
    );
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call.method);
      if (call.method == 'start') {
        final args = call.arguments as Map;
        id = args['id'] as String;
        expect(args['max_bytes'], lessThanOrEqualTo(10000000));
        await File(args['path'] as String).writeAsBytes(List.filled(100, 1));
        return startGate == null ? true : await startGate!.future;
      }
      if (call.method == 'stop') {
        return {
          'id': id,
          'duration_ms': duration,
          'reason': 'stopped',
          'error': null,
        };
      }
      throw StateError('Unexpected note method ${call.method}');
    });
    await TtsService.stop();
    await TtsService.configure(enabled: true, mode: SpeechMode.selfVoicing);
    recorder = PrivateNoteRecorder(
      channel: channel,
      permission: () async => allowed,
    );
  });
  tearDown(() async {
    await recorder.stop();
    recorder.dispose();
    await root.delete(recursive: true);
    PrivateNoteRecorder.liveSessions = 0;
    await TtsService.stop();
  });
  Future<void> start() => recorder.start(
    store: store,
    title: 'Private draft',
    canRecord: () => current,
    audioId: 9,
    position: const Duration(seconds: 25),
  );
  Future<void> waitFor(bool Function() done) async {
    for (var i = 0; i < 100 && !done(); i++) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    expect(done(), isTrue);
  }

  test(
    'no capture until explicit Start; Stop saves an account-private timestamped draft',
    () async {
      expect(calls, isEmpty);
      await start();
      expect(calls, ['start']);
      expect(recorder.recording, isTrue);
      await recorder.stop();
      expect(recorder.recording, isFalse);
      expect(recorder.active, isFalse);
      expect((await store.list()).single.complete, isTrue);
      expect((await store.list()).single.position, const Duration(seconds: 25));
    },
  );
  test(
    'permission denial, live sessions and a changed route never start native capture',
    () async {
      allowed = false;
      await start();
      expect(recorder.issue, contains('permission'));
      allowed = true;
      PrivateNoteRecorder.liveSessions = 1;
      await start();
      expect(recorder.issue, contains('live session'));
      PrivateNoteRecorder.liveSessions = 0;
      current = false;
      await start();
      expect(calls, isEmpty);
    },
  );
  test(
    'route change while native start is pending settles Start then stops rather than leaving capture active',
    () async {
      startGate = Completer<bool>();
      final operation = start();
      await waitFor(() => calls.contains('start'));
      current = false;
      startGate!.complete(true);
      await operation;
      expect(calls, ['start', 'stop']);
      expect(recorder.active, isFalse);
    },
  );
  test(
    'Stop while native Start is pending cannot resurrect stopped capture when the late acknowledgment arrives',
    () async {
      startGate = Completer<bool>();
      final operation = start();
      await waitFor(() => calls.contains('start'));
      await recorder.stop();
      startGate!.complete(true);
      await operation;
      expect(recorder.active, isFalse);
      expect(recorder.recording, isFalse);
      expect(calls, ['start', 'stop']);
    },
  );
  test(
    'disposing during pending native Start still stops capture and ignores its late acknowledgment',
    () async {
      startGate = Completer<bool>();
      final operation = start();
      await waitFor(() => calls.contains('start'));
      final original = recorder;
      original.dispose();
      await waitFor(() => calls.contains('stop'));
      startGate!.complete(true);
      await operation;
      await waitFor(() => !original.active);
      expect(original.active, isFalse);
      recorder = PrivateNoteRecorder(
        channel: channel,
        permission: () async => true,
      );
    },
  );
  test(
    'a second recorder cannot steal the active recorder callback or stop its capture',
    () async {
      await start();
      final originalId = id;
      final second = PrivateNoteRecorder(
        channel: channel,
        permission: () async => true,
      );
      try {
        await second.start(
          store: store,
          title: 'Second draft',
          canRecord: () => true,
        );
        expect(second.issue, contains('Another private recorder'));
        expect(calls, ['start']);
        expect(recorder.recording, isTrue);
        await recorder.stop();
        expect(
          (await store.list())
              .firstWhere((note) => note.id == originalId)
              .complete,
          isTrue,
        );
      } finally {
        second.dispose();
      }
    },
  );
  test(
    'app narration stops capture and cannot automatically restart it',
    () async {
      await start();
      TtsService.speaking.value = true;
      await waitFor(() => !recorder.active);
      TtsService.speaking.value = false;
      expect(calls, ['start', 'stop']);
      expect((await store.list()).single.complete, isTrue);
    },
  );
  test(
    'native duration/storage limit completion retains a reviewable note without restarting',
    () async {
      await start();
      duration = 300000;
      await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .handlePlatformMessage(
            'seeds/private_notes',
            const StandardMethodCodec().encodeMethodCall(
              MethodCall('stopped', {
                'id': id,
                'duration_ms': duration,
                'reason': 'limit',
                'error': null,
              }),
            ),
            (_) {},
          );
      expect(recorder.active, isFalse);
      expect(recorder.status, contains('limit reached'));
      expect((await store.list()).single.duration, const Duration(minutes: 5));
      expect(calls.where((method) => method == 'start').length, 1);
    },
  );
  test('empty or unreadable duration never produces a saved success', () async {
    await start();
    duration = 0;
    await recorder.stop();
    expect(recorder.issue, isNotNull);
    expect(recorder.status, contains('could not be finalized'));
    expect((await store.list()).single.complete, isFalse);
  });
  test(
    'account change stops recording and retains only an incomplete file in the original account',
    () async {
      await start();
      changed = true;
      await recorder.stop();
      expect(recorder.recording, isFalse);
      expect(recorder.issue, contains('Account changed'));
      changed = false;
      expect((await store.list()).single.complete, isFalse);
    },
  );
}
