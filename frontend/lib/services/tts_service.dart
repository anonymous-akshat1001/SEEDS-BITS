import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SpeechMode { selfVoicing, screenReader }

enum SpeechVerbosity { essential, standard, detailed }

enum SpeechPriority { incidental, navigation, requested, critical }

class _RecordedPlayback {
  const _RecordedPlayback({
    required this.isPlaying,
    required this.item,
    required this.pause,
    required this.resume,
    this.canResume,
    this.onResumeSkipped,
  });

  final bool Function() isPlaying;
  final Object? Function() item;
  final Future<void> Function() pause;
  final Future<void> Function() resume;
  final bool Function()? canResume;
  final VoidCallback? onResumeSkipped;
}

class TtsService {
  static const defaultSpeechRate = 0.75;
  static final FlutterTts _tts = FlutterTts();
  static final ValueNotifier<String?> issue = ValueNotifier(null);
  static final ValueNotifier<bool> speaking = ValueNotifier(false);
  static bool _isInitialized = false;
  static Future<void>? _initializing;
  static Future<String>? _checkingVoice;
  static String _englishLanguage = 'en-IN';
  static bool _enabled = true;
  static double _speechRate = defaultSpeechRate;
  static double _volume = 1.0;
  static double _pitch = 1.0;
  static SpeechMode _mode = SpeechMode.selfVoicing;
  static SpeechVerbosity _verbosity = SpeechVerbosity.standard;
  static SpeechPriority? _activePriority;
  static int _speechGeneration = 0;
  static final Map<Object, _RecordedPlayback> _recorded = {};
  static final Map<Object, (_RecordedPlayback, Object?)> _paused = {};
  static final Set<Object> _liveSessions = {};
  static final Map<String, int> _updates = {};
  static Timer? _updateTimer;
  static const _engineTimeout = Duration(seconds: 2);

  static bool get isEnabled => _enabled;
  static double get volume => _volume;
  static SpeechMode get mode => _mode;
  static SpeechVerbosity get verbosity => _verbosity;

  static Future<void> init() async {
    if (_isInitialized) return;
    await (_initializing ??= _initialize());
  }

  static Future<void> _initialize() async {
    try {
      final language = await _tts
          .setLanguage(_englishLanguage)
          .timeout(_engineTimeout);
      if (language != 1) {
        final fallback = await _tts
            .setLanguage('en-US')
            .timeout(_engineTimeout);
        if (fallback != 1) throw StateError('No English TTS voice available');
      }
      await _tts.awaitSpeakCompletion(true).timeout(_engineTimeout);
      await _applyVoiceSettings().timeout(_engineTimeout);
      _isInitialized = true;
      issue.value = null;
    } catch (error) {
      _report(
        'Speech is unavailable. Enable an English Android text-to-speech voice, '
        'then use Test TTS in Settings.',
        error,
      );
    } finally {
      _initializing = null;
    }
  }

  static Future<void> loadFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await configure(
      enabled: prefs.getBool('tts_enabled') ?? true,
      volume: prefs.getDouble('tts_volume') ?? 1.0,
      speechRate: prefs.getDouble('tts_speech_rate') ?? defaultSpeechRate,
      mode: prefs.getString('speech_mode') == SpeechMode.screenReader.name
          ? SpeechMode.screenReader
          : SpeechMode.selfVoicing,
      verbosity: switch (prefs.getString('speech_verbosity')) {
        'essential' => SpeechVerbosity.essential,
        'detailed' => SpeechVerbosity.detailed,
        _ => SpeechVerbosity.standard,
      },
    );
  }

  static Future<String> checkEnglishVoice() async {
    try {
      return await (_checkingVoice ??= _checkEnglishVoice());
    } finally {
      _checkingVoice = null;
    }
  }

  static Future<String> _checkEnglishVoice() async {
    const recovery =
        'Open Android Settings, find Text-to-speech output, select an English '
        'voice and install its voice data. Return here and check again. '
        'You can use your Android screen reader instead of app speech.';
    try {
      await init();
      await stop();
      for (final locale in ['en-IN', 'en-US']) {
        final available = await _tts
            .isLanguageAvailable(locale)
            .timeout(_engineTimeout);
        if (available == false) continue;
        if (available != true) {
          throw StateError('Unexpected language availability response');
        }
        final selected = await _tts.setLanguage(locale).timeout(_engineTimeout);
        if (selected != 1) {
          throw StateError('English selection not acknowledged');
        }
        _englishLanguage = locale;
        final installed = await _tts
            .isLanguageInstalled(locale)
            .timeout(_engineTimeout);
        if (installed is! bool) {
          throw StateError('Unexpected installed-language response');
        }
        issue.value = null;
        return installed
            ? 'Android reports installed English voice data. Use Test TTS in '
                  'Settings, then test it again in airplane mode before relying on '
                  'offline speech. This check cannot prove that you can hear it.'
            : 'English is available, but installed offline voice data was not '
                  'confirmed. Speech may need internet. $recovery';
      }
      _isInitialized = false;
      _report(
        'No English voice was detected. $recovery',
        StateError('No English voice'),
      );
      return 'No English voice was detected. $recovery';
    } catch (error) {
      _report(
        'English voice availability could not be verified. $recovery',
        error,
      );
      return 'English voice availability could not be verified. $recovery';
    }
  }

  static Future<void> configure({
    bool? enabled,
    double? speechRate,
    double? volume,
    double? pitch,
    SpeechMode? mode,
    SpeechVerbosity? verbosity,
  }) async {
    if (enabled != null) _enabled = enabled;
    if (speechRate != null) _speechRate = speechRate.clamp(0.1, 1.0).toDouble();
    if (volume != null) _volume = volume.clamp(0.0, 1.0).toDouble();
    if (pitch != null) _pitch = pitch.clamp(0.5, 2.0).toDouble();
    if (mode != null) _mode = mode;
    if (verbosity != null) _verbosity = verbosity;
    if (!_enabled || _mode == SpeechMode.screenReader) await stop();
    await init();
    if (!_isInitialized) return;
    try {
      await _applyVoiceSettings().timeout(_engineTimeout);
      issue.value = null;
    } catch (error) {
      _report(
        'Speech settings could not be applied. Try Test TTS again.',
        error,
      );
    }
  }

  static Future<void> _applyVoiceSettings() async {
    await _tts.setSpeechRate(_speechRate);
    await _tts.setVolume(_volume);
    await _tts.setPitch(_pitch);
  }

  static void registerRecordedPlayback(
    Object owner, {
    required bool Function() isPlaying,
    required Object? Function() item,
    required Future<void> Function() pause,
    required Future<void> Function() resume,
    bool Function()? canResume,
    VoidCallback? onResumeSkipped,
  }) {
    _recorded[owner] = _RecordedPlayback(
      isPlaying: isPlaying,
      item: item,
      pause: pause,
      resume: resume,
      canResume: canResume,
      onResumeSkipped: onResumeSkipped,
    );
  }

  static void unregisterRecordedPlayback(Object owner) {
    _recorded.remove(owner);
    _paused.remove(owner);
  }

  static void registerLiveSession(Object owner) => _liveSessions.add(owner);
  static void unregisterLiveSession(Object owner) =>
      _liveSessions.remove(owner);

  static Future<void> speak(
    String text, {
    SpeechPriority priority = SpeechPriority.requested,
    String? group,
  }) async {
    if (!_enabled || _mode == SpeechMode.screenReader || text.trim().isEmpty) {
      return;
    }
    if (priority == SpeechPriority.incidental) {
      final key = group ?? text;
      if (_updates.containsKey(key) || _updates.length < 8) {
        _updates.update(key, (count) => count + 1, ifAbsent: () => 1);
      } else {
        _updates.update(
          'Other updates',
          (count) => count + 1,
          ifAbsent: () => 1,
        );
      }
      _scheduleUpdates();
      return;
    }
    final generation = ++_speechGeneration;
    _activePriority = priority;
    speaking.value = true;
    try {
      await init();
      if (generation != _speechGeneration) return;
      if (!_isInitialized) {
        await _finish(generation);
        return;
      }
      await _tts.stop().timeout(_engineTimeout);
      if (generation != _speechGeneration) return;
      for (final entry in _recorded.entries.toList()) {
        final playback = entry.value;
        final paused = _paused[entry.key];
        if (paused != null && paused.$2 != playback.item()) {
          _paused.remove(entry.key);
        }
        if (_paused.containsKey(entry.key) || !playback.isPlaying()) continue;
        _paused[entry.key] = (playback, playback.item());
        await playback.pause().timeout(_engineTimeout);
        if (generation != _speechGeneration) return;
      }
      if (!_enabled || _mode == SpeechMode.screenReader) return;
      // Completion belongs to this generation, including when a newer request
      // stops the native utterance. A stale completion must not resume audio.
      unawaited(_utter(text, generation));
    } catch (error) {
      _report('Speech could not start. Try Test TTS in Settings.', error);
      if (generation == _speechGeneration) await _finish(generation);
    }
  }

  static Future<void> _utter(String text, int generation) async {
    try {
      final result = await _tts.speak(text);
      if (result == 0 && generation == _speechGeneration) {
        _report('Speech was not available. Try Test TTS in Settings.', result);
      } else if (generation == _speechGeneration) {
        issue.value = null;
      }
    } catch (error) {
      _report('Speech failed. Try Test TTS in Settings.', error);
    } finally {
      await _finish(generation);
    }
  }

  static Future<void> _finish(int generation) async {
    if (generation != _speechGeneration) return;
    _activePriority = null;
    speaking.value = false;
    await _resumePaused();
    _scheduleUpdates();
  }

  static Future<void> _resumePaused() async {
    final paused = Map.of(_paused);
    _paused.clear();
    for (final entry in paused.entries) {
      final playback = entry.value.$1;
      if (!identical(_recorded[entry.key], playback) ||
          !playback.isPlaying() ||
          playback.item() != entry.value.$2) {
        continue;
      }
      if (!(playback.canResume?.call() ?? true)) {
        playback.onResumeSkipped?.call();
        continue;
      }
      try {
        await playback.resume().timeout(_engineTimeout);
      } catch (error) {
        _report(
          'The recorded lesson could not resume. Select Play to retry.',
          error,
        );
      }
    }
  }

  static void _scheduleUpdates() {
    if (_updates.isEmpty ||
        _updateTimer != null ||
        _activePriority != null ||
        _verbosity == SpeechVerbosity.essential ||
        _liveSessions.isNotEmpty ||
        _recorded.values.any((playback) => playback.isPlaying())) {
      return;
    }
    _updateTimer = Timer(const Duration(seconds: 2), () {
      _updateTimer = null;
      if (_activePriority == null &&
          _liveSessions.isEmpty &&
          !_recorded.values.any((playback) => playback.isPlaying())) {
        unawaited(readPendingUpdates());
      }
    });
  }

  static Future<void> readPendingUpdates() async {
    final entries = _updates.entries.toList();
    _updates.clear();
    final limit = _verbosity == SpeechVerbosity.detailed ? entries.length : 3;
    await speak(
      entries.isEmpty
          ? 'No pending updates.'
          : [
              for (final entry in entries.take(limit))
                '${entry.key}${entry.value > 1 ? ', ${entry.value} updates' : ''}.',
              if (entries.length > limit)
                '${entries.length - limit} other update groups.',
            ].join(' '),
    );
  }

  static Future<void> stop() async {
    await stopForVoiceCommands();
  }

  static Future<bool> stopForVoiceCommands() async {
    ++_speechGeneration;
    _activePriority = null;
    speaking.value = false;
    _updateTimer?.cancel();
    _updateTimer = null;
    _updates.clear();
    var stopped = true;
    try {
      await _tts.stop().timeout(_engineTimeout);
    } catch (error) {
      stopped = false;
      _report(
        'Speech could not be stopped. Check the Android TTS engine.',
        error,
      );
    }
    await _resumePaused();
    return stopped;
  }

  static Future<void> rescue() async {
    if (_mode == SpeechMode.screenReader) return;
    if (_enabled && _volume > 0) return;
    final prefs = await SharedPreferences.getInstance();
    await configure(enabled: true, volume: _volume > 0 ? _volume : 0.6);
    await prefs.setBool('tts_enabled', true);
    await prefs.setDouble('tts_volume', _volume);
  }

  static void setEnabled(bool enabled) {
    _enabled = enabled;
    if (!enabled) unawaited(stop());
  }

  static Future<void> setSpeechRate(double rate) => configure(speechRate: rate);
  static Future<void> setVolume(double volume) => configure(volume: volume);
  static Future<void> setPitch(double pitch) => configure(pitch: pitch);
  static Future<List<dynamic>> getLanguages() async {
    await init();
    return await _tts.getLanguages;
  }

  static Future<void> setLanguage(String language) =>
      _tts.setLanguage(language);

  static void _report(String message, Object error) {
    issue.value = message;
    debugPrint('[TTS] $message (${error.runtimeType})');
  }
}
