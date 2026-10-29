import 'dart:async';
import 'dart:js_interop';

import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

@JS('window.speechSynthesis')
external _Synthesis get _synthesis;

extension type _Synthesis._(JSObject _) implements JSObject {
  external void speak(_Utterance utterance);
  external void cancel();
  external JSArray<_Voice> getVoices();
}

@JS('SpeechSynthesisUtterance')
extension type _Utterance._(JSObject _) implements JSObject {
  external factory _Utterance(String text);
  external set lang(String value);
  external set rate(double value);
  external set volume(double value);
  external set pitch(double value);
  external set onend(JSFunction? value);
  external set onerror(JSFunction? value);
}

extension type _Voice._(JSObject _) implements JSObject {
  external String get lang;
  external bool get localService;
}

extension type _SpeechError._(JSObject _) implements JSObject {
  external String get error;
}

FlutterTts createSpeechEngine() => BrowserSpeechEngine();

/// Each utterance owns its completion; canceled browser events cannot affect
/// a newer utterance or index into its text.
class BrowserSpeechEngine extends FlutterTts {
  String _language = 'en-IN';
  double _rate = 0.75;
  double _volume = 1;
  double _pitch = 1;
  _Utterance? _active;
  Completer<int>? _completion;

  @override
  Future<dynamic> awaitSpeakCompletion(bool awaitCompletion) async => 1;

  @override
  Future<dynamic> speak(String text, {bool focus = false}) {
    _cancel();
    final utterance = _Utterance(text)
      ..lang = _language
      ..rate = _rate
      ..volume = _volume
      ..pitch = _pitch;
    final completion = Completer<int>();
    _active = utterance;
    _completion = completion;
    void finish([String? error]) {
      if (_active != utterance || completion.isCompleted) return;
      _active = null;
      _completion = null;
      utterance.onend = null;
      utterance.onerror = null;
      if (error == null || error == 'canceled' || error == 'interrupted') {
        completion.complete(1);
      } else {
        completion.completeError(
          PlatformException(code: 'browser_speech', message: error),
        );
      }
    }

    utterance.onend = ((JSAny event) => finish()).toJS;
    utterance.onerror = ((_SpeechError event) => finish(event.error)).toJS;
    try {
      _synthesis.speak(utterance);
    } catch (error, stack) {
      _active = null;
      _completion = null;
      utterance.onend = null;
      utterance.onerror = null;
      completion.completeError(error, stack);
    }
    return completion.future;
  }

  @override
  Future<dynamic> stop() async {
    _cancel();
    return 1;
  }

  void _cancel() {
    final utterance = _active;
    final completion = _completion;
    _active = null;
    _completion = null;
    if (utterance != null) {
      utterance.onend = null;
      utterance.onerror = null;
    }
    _synthesis.cancel();
    if (completion != null && !completion.isCompleted) completion.complete(1);
  }

  @override
  Future<dynamic> setLanguage(String language) async {
    _language = language;
    return 1;
  }

  @override
  Future<dynamic> setSpeechRate(double rate) async {
    _rate = rate;
    return 1;
  }

  @override
  Future<dynamic> setVolume(double volume) async {
    _volume = volume;
    return 1;
  }

  @override
  Future<dynamic> setPitch(double pitch) async {
    _pitch = pitch;
    return 1;
  }

  @override
  Future<dynamic> get getLanguages async =>
      _synthesis.getVoices().toDart.map((voice) => voice.lang).toSet().toList();

  @override
  Future<dynamic> isLanguageAvailable(String language) async =>
      _synthesis.getVoices().toDart.any(
        (voice) => voice.lang.toLowerCase().startsWith(language.toLowerCase()),
      );

  @override
  Future<dynamic> isLanguageInstalled(String language) async =>
      _synthesis.getVoices().toDart.any(
        (voice) =>
            voice.localService &&
            voice.lang.toLowerCase().startsWith(language.toLowerCase()),
      );
}
