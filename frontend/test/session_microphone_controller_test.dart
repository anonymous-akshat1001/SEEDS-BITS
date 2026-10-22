import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/services/session_microphone_controller.dart';

void main() {
  late SessionMicrophoneController microphone;
  late List<bool> requests;
  late List<bool> capture;
  late Completer<ApiResult<Map<String, dynamic>>> acknowledgment;
  var available = true;
  var disposed = false;

  setUp(() {
    requests = [];
    capture = [];
    acknowledgment = Completer();
    available = true;
    disposed = false;
    microphone = SessionMicrophoneController(
      isAvailable: () => available,
      setCaptureEnabled: capture.add,
      sendMute: (muted) {
        requests.add(muted);
        return acknowledgment.future;
      },
    );
  });

  tearDown(() {
    if (!disposed) microphone.dispose();
  });

  test('fresh joins are muted and remote unmute never opens capture', () {
    expect(microphone.muted, isTrue);
    microphone.applyRemoteMute(false);
    microphone.applyRemoteMute(false);
    expect(microphone.muted, isTrue);
    expect(capture, isEmpty);
    expect(requests, isEmpty);
  });

  test('only acknowledged explicit self-unmute activates capture', () async {
    final pending = microphone.toggle();
    expect(microphone.pending, isTrue);
    expect(microphone.muted, isTrue);
    expect(capture, isEmpty);
    microphone.applyRemoteMute(false);
    expect(capture, isEmpty);
    acknowledgment.complete(const ApiResult.success({'ok': true}));
    expect((await pending).isSuccess, isTrue);
    expect(microphone.muted, isFalse);
    expect(microphone.pending, isFalse);
    expect(capture, [true]);
    expect(requests, [false]);
  });

  test(
    'lost acknowledgment stays muted even with an earlier unmute echo',
    () async {
      final pending = microphone.toggle();
      microphone.applyRemoteMute(false);
      acknowledgment.complete(
        const ApiResult.failure(
          ApiFailure(kind: ApiFailureKind.network, message: 'Not confirmed'),
        ),
      );
      expect((await pending).isSuccess, isFalse);
      microphone.applyRemoteMute(false);
      expect(microphone.muted, isTrue);
      expect(capture, isEmpty);
    },
  );

  test('duplicate pending actions do not send a second request', () async {
    final pending = microphone.toggle();
    expect((await microphone.toggle()).isSuccess, isFalse);
    expect(requests, [false]);
    acknowledgment.complete(const ApiResult.success({'ok': true}));
    await pending;
  });

  test(
    'unavailable capture cannot claim successful unmute or send an action',
    () async {
      available = false;
      final result = await microphone.toggle();
      expect(result.isSuccess, isFalse);
      expect(result.failure!.message, contains('permission'));
      expect(microphone.muted, isTrue);
      expect(requests, isEmpty);
      expect(capture, isEmpty);
    },
  );

  test(
    'capture becoming unavailable during acknowledgment cannot activate',
    () async {
      final pending = microphone.toggle();
      available = false;
      acknowledgment.complete(const ApiResult.success({'ok': true}));
      expect((await pending).isSuccess, isFalse);
      expect(microphone.muted, isTrue);
      expect(capture, isEmpty);
    },
  );

  test('teacher mute wins over an older pending self-unmute', () async {
    final pending = microphone.toggle();
    microphone.applyRemoteMute(true);
    microphone.applyRemoteMute(false);
    acknowledgment.complete(const ApiResult.success({'ok': true}));
    expect((await pending).isSuccess, isFalse);
    expect(microphone.muted, isTrue);
    expect(capture, [false]);
  });

  test(
    'muting disables capture immediately even when server confirmation fails',
    () async {
      acknowledgment.complete(const ApiResult.success({'ok': true}));
      await microphone.toggle();
      acknowledgment = Completer();
      final pending = microphone.toggle();
      expect(microphone.muted, isTrue);
      expect(capture, [true, false]);
      acknowledgment.complete(
        const ApiResult.failure(
          ApiFailure(kind: ApiFailureKind.network, message: 'Not confirmed'),
        ),
      );
      expect((await pending).isSuccess, isFalse);
      expect(microphone.muted, isTrue);
      expect(capture, [true, false]);
    },
  );

  test('a remote mute disables an active local track', () async {
    acknowledgment.complete(const ApiResult.success({'ok': true}));
    await microphone.toggle();
    microphone.applyRemoteMute(true);
    expect(microphone.muted, isTrue);
    expect(capture, [true, false]);
    microphone.applyRemoteMute(false);
    expect(capture, [true, false]);
  });

  test('an unmute snapshot after interruption preserves local state', () async {
    acknowledgment.complete(const ApiResult.success({'ok': true}));
    await microphone.toggle();
    microphone.applyRemoteMute(false);
    expect(microphone.muted, isFalse);
    expect(capture, [true]);
    expect(requests, [false]);
  });

  test(
    'disposal revokes capture and rejects a late unmute acknowledgment',
    () async {
      final pending = microphone.toggle();
      microphone.dispose();
      disposed = true;
      acknowledgment.complete(const ApiResult.success({'ok': true}));
      expect((await pending).isSuccess, isFalse);
      expect(capture, [false]);
    },
  );
}
