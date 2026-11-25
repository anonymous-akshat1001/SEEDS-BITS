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
  external set voice(_Voice? value);
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

/// Browser error codes that a different voice may fix (a missing language,
/// an unavailable or online voice that failed). Speech is retried once.
const _retryWithFallbackVoice = {
  'language-unavailable',
  'voice-unavailable',
  'synthesis-unavailable',
  'synthesis-failed',
  'audio-busy',
  'network',
};

String _normalizedLang(String lang) => lang.toLowerCase().replaceAll('_', '-');

/// Each utterance owns its completion; canceled browser events cannot affect
/// a newer utterance or index into its text.
///
/// Errors are [PlatformException]s with code `browser_speech` and the
/// browser's error as message. `not-allowed` means the page has not had a
/// click or key press yet, which browsers require before speech.
class BrowserSpeechEngine extends FlutterTts {
  String _language = 'en-IN';
  // flutter_tts scale, where 0.5 is normal speed (as on Android).
  double _rate = 0.875;
  double _volume = 1;
  double _pitch = 1;
  _Utterance? _active;
  Completer<int>? _completion;

  @override
  Future<dynamic> awaitSpeakCompletion(bool awaitCompletion) async => 1;

  List<_Voice> get _voices {
    try {
      return _synthesis.getVoices().toDart;
    } catch (_) {
      return const [];
    }
  }

  /// A voice for [language], preferring one installed on the device: the
  /// exact locale (kn-IN) first, then any voice of the same language (kn).
  _Voice? _voiceFor(String language) {
    final wanted = _normalizedLang(language);
    final primary = wanted.split('-').first;
    _Voice? best(Iterable<_Voice> matches) =>
        matches.where((voice) => voice.localService).firstOrNull ??
        matches.firstOrNull;
    return best(
          _voices.where((voice) => _normalizedLang(voice.lang) == wanted),
        ) ??
        best(
          _voices.where(
            (voice) => _normalizedLang(voice.lang).split('-').first == primary,
          ),
        );
  }

  /// Any English voice, preferring one installed on the device, which keeps
  /// working when an online voice or the network fails.
  _Voice? get _fallbackVoice {
    final english = _voices.where(
      (voice) => _normalizedLang(voice.lang).startsWith('en'),
    );
    return english.where((voice) => voice.localService).firstOrNull ??
        english.firstOrNull;
  }

  @override
  Future<dynamic> speak(String text, {bool focus = false}) {
    _cancel();
    final completion = Completer<int>();
    _completion = completion;
    _start(text, completion, fallback: false);
    return completion.future;
  }

  void _start(
    String text,
    Completer<int> completion, {
    required bool fallback,
  }) {
    final utterance = _Utterance(text)
      // Web Speech treats 1 as normal speed; Android's plugin doubles the
      // flutter_tts value, so do the same here for identical speeds.
      ..rate = (_rate * 2).clamp(0.1, 10).toDouble()
      ..volume = _volume
      ..pitch = _pitch;
    final voice = fallback ? _fallbackVoice : _voiceFor(_language);
    if (voice != null) {
      utterance
        ..voice = voice
        ..lang = voice.lang;
    } else if (!fallback) {
      // No exact voice yet (voices load late); let the browser choose.
      utterance.lang = _language;
    }
    _active = utterance;
    void finish([String? error]) {
      if (_active != utterance || completion.isCompleted) return;
      _active = null;
      utterance.onend = null;
      utterance.onerror = null;
      if (error == null || error == 'canceled' || error == 'interrupted') {
        _completion = null;
        completion.complete(1);
      } else if (!fallback && _retryWithFallbackVoice.contains(error)) {
        _start(text, completion, fallback: true);
      } else {
        _completion = null;
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

  /// Returns 0 when the browser has no voice for [language] (Chrome on
  /// Windows has none for Kannada, Telugu or Bengali), so SEEDS falls back
  /// to English and says why instead of staying silent. Voices can load a
  /// moment after the page opens, so an empty list is waited for briefly.
  @override
  Future<dynamic> setLanguage(String language) async {
    _language = language;
    for (var attempt = 0; attempt < 10 && _voices.isEmpty; attempt++) {
      await Future<void>.delayed(const Duration(milliseconds: 150));
    }
    if (_voices.isEmpty) return 1;
    return _voiceFor(language) == null ? 0 : 1;
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
