@TestOn('browser')
library;

import 'dart:js_interop';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/services/speech_engine_web.dart';
import 'package:frontend/services/tts_service.dart';

@JS('window')
external JSObject get _window;
@JS('window.speechSynthesis')
external JSObject get _originalSynthesis;
@JS('Object.defineProperty')
external JSObject _defineProperty(JSObject object, String name, JSObject value);

extension type _Probe(JSObject _) implements JSObject {
  external JSFunction? get onend;
  external JSFunction? get onerror;
  external JSFunction? get onboundary;
  external String get text;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final sent = <_Probe>[];
  late JSObject original;
  var cancellations = 0;
  void install(JSObject value) => _defineProperty(
    _window,
    'speechSynthesis',
    {'value': value, 'configurable': true}.jsify() as JSObject,
  );
  setUp(() {
    original = _originalSynthesis;
    sent.clear();
    cancellations = 0;
    install(
      {
            'speak': ((JSObject utterance) => sent.add(_Probe(utterance))).toJS,
            'cancel': (() => cancellations++).toJS,
            'getVoices': (() => <JSObject>[].toJS).toJS,
          }.jsify()
          as JSObject,
    );
  });
  tearDown(() => install(original));

  test('interrupted speech owns a separate utterance and completion', () async {
    final engine = BrowserSpeechEngine();
    final first = engine.speak('A much longer initial announcement');
    final outgoing = sent.single;
    final lateEnd = outgoing.onend!;
    final lateError = outgoing.onerror!;
    var nextCompleted = false;
    final next = engine.speak('Hi').then((result) {
      nextCompleted = true;
      return result;
    });
    final incoming = sent.last;
    expect(await first, 1);
    expect(incoming.text, 'Hi');
    expect(outgoing.text, 'A much longer initial announcement');
    expect(outgoing.onboundary, isNull);
    expect(outgoing.onend, isNull);
    expect(outgoing.onerror, isNull);
    lateEnd.callAsFunction(outgoing, JSObject());
    lateError.callAsFunction(
      outgoing,
      {'error': 'interrupted', 'charIndex': 27}.jsify(),
    );
    await Future<void>.delayed(Duration.zero);
    expect(nextCompleted, isFalse);
    incoming.onend!.callAsFunction(incoming, JSObject());
    expect(await next, 1);
    expect(cancellations, 2);
  });

  test(
    'stop settles cancellation and the next announcement still completes',
    () async {
      final engine = BrowserSpeechEngine();
      final first = engine.speak('Interrupted');
      await engine.stop();
      expect(await first, 1);
      final next = engine.speak('Destination screen');
      sent.last.onend!.callAsFunction(sent.last, JSObject());
      expect(await next, 1);
    },
  );

  test(
    'genuine browser errors are explicit and do not poison later speech',
    () async {
      final engine = BrowserSpeechEngine();
      final first = engine.speak('Test');
      final failed = expectLater(first, throwsA(isA<PlatformException>()));
      sent.last.onerror!.callAsFunction(
        sent.last,
        {'error': 'synthesis-unavailable'}.jsify(),
      );
      await failed;
      final next = engine.speak('Retry');
      sent.last.onend!.callAsFunction(sent.last, JSObject());
      expect(await next, 1);
    },
  );

  test(
    'service interruption keeps destination speech active until its own completion',
    () async {
      await TtsService.configure(enabled: true, mode: SpeechMode.selfVoicing);
      await TtsService.speak('Long outgoing screen announcement');
      final outgoing = sent.single;
      final staleEnd = outgoing.onend!;
      await TtsService.speak('Next control');
      expect(sent.last.text, 'Next control');
      staleEnd.callAsFunction(outgoing, JSObject());
      await Future<void>.delayed(Duration.zero);
      expect(TtsService.speaking.value, isTrue);
      sent.last.onend!.callAsFunction(sent.last, JSObject());
      await Future<void>.delayed(Duration.zero);
      expect(TtsService.speaking.value, isFalse);
      expect(TtsService.issue.value, isNull);
      await TtsService.stop();
    },
  );
}
