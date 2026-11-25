import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter/widgets.dart' show TextDirection;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/speech.dart';
import 'speech_engine.dart'
    if (dart.library.js_interop) 'speech_engine_web.dart';

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
  // Rates use flutter_tts's scale: on Android 0.5 is the engine's normal
  // speed (the plugin doubles the value), so the default 0.875 is 1.75 times
  // normal. The web engine applies the same scale (see speech_engine_web).
  static const defaultSpeechRate = 0.875;
  static const minSpeechRate = 0.25;
  static const maxSpeechRate = 2.0;
  static const speechRateStep = 0.125;
  static const _previousDefaultSpeechRate = 0.75;
  static const _speechRateVersionKey = 'tts_speech_rate_version';
  static const _speechRateVersion = 2;

  /// Speed relative to the engine's normal voice, e.g. 1.75.
  static double speedMultiple(double rate) => rate * 2;

  /// Spoken and visible form, e.g. "1.75 times normal speed".
  static String describeSpeed(double rate) =>
      Speech.t.ttsSpeedDescription(formatSpeedMultiple(rate));

  /// "1.75", "2", "0.5": no trailing zeros.
  static String formatSpeedMultiple(double rate) {
    final text = speedMultiple(rate).toStringAsFixed(2);
    return text.replaceFirst(RegExp(r'\.?0+$'), '');
  }

  static double clampSpeechRate(double rate) =>
      rate.clamp(minSpeechRate, maxSpeechRate).toDouble();

  static final FlutterTts _tts = createSpeechEngine();
  static final ValueNotifier<String?> issue = ValueNotifier(null);
  static final ValueNotifier<bool> speaking = ValueNotifier(false);
  static bool _isInitialized = false;
  static Future<void>? _initializing;
  static Future<String>? _checkingVoice;
  static String _englishLanguage = 'en-IN';

  /// The language chosen in Settings. [Speech.language] is the language
  /// actually spoken: English when the chosen voice is not available.
  static SpeechLanguage _selectedLanguage = SpeechLanguage.english;
  static SpeechLanguage get selectedLanguage => _selectedLanguage;
  static bool _enabled = true;
  static double _speechRate = defaultSpeechRate;
  // Temporary speeds for particular screens (only the quiz uses this). The
  // most recently set one wins; removing it restores the Settings speed.
  static final Map<Object, double> _rateOverrides = {};
  static String? _currentText;
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

  /// The speed chosen in Settings.
  static double get speechRate => _speechRate;

  /// The speed in use now: a screen's temporary speed, else Settings.
  static double get effectiveSpeechRate =>
      _rateOverrides.isEmpty ? _speechRate : _rateOverrides.values.last;

  /// What app speech is saying right now, if anything.
  static String? get currentText => _speakingNow ? _currentText : null;

  static bool _speakingNow = false;
  static bool _speakingUpdateScheduled = false;

  /// Updates [speaking]. Speech can stop while a frame is being built (a
  /// screen rebuilding stops the previous announcement); listeners that call
  /// setState would then fail, so the change is published after the frame.
  static void _setSpeaking(bool value) {
    _speakingNow = value;
    final SchedulerBinding binding;
    try {
      binding = SchedulerBinding.instance;
    } catch (_) {
      speaking.value = value;
      return;
    }
    if (binding.schedulerPhase != SchedulerPhase.persistentCallbacks) {
      speaking.value = value;
      return;
    }
    if (_speakingUpdateScheduled) return;
    _speakingUpdateScheduled = true;
    binding.addPostFrameCallback((_) {
      _speakingUpdateScheduled = false;
      speaking.value = _speakingNow;
    });
  }

  /// Sets ([rate]) or removes (null) a temporary speed owned by [owner].
  /// Settings and every other screen keep their own speed.
  static Future<void> setSpeechRateOverride(Object owner, double? rate) async {
    _rateOverrides.remove(owner);
    if (rate != null) _rateOverrides[owner] = clampSpeechRate(rate);
    await init();
    if (!_isInitialized) return;
    try {
      await _tts.setSpeechRate(effectiveSpeechRate).timeout(_engineTimeout);
    } catch (error) {
      _report(Speech.t.ttsSpeedChangeFailed, error);
    }
  }

  static Future<void> init() async {
    if (_isInitialized) return;
    await (_initializing ??= _initialize());
  }

  static Future<void> _initialize() async {
    try {
      await _applyLanguage();
      await _tts.awaitSpeakCompletion(true).timeout(_engineTimeout);
      await _applyVoiceSettings().timeout(_engineTimeout);
      _isInitialized = true;
      if (Speech.language == _selectedLanguage) issue.value = null;
    } catch (error) {
      _report(Speech.t.ttsUnavailable, error);
    } finally {
      _initializing = null;
    }
  }

  /// Selects the voice for [_selectedLanguage], falling back to English
  /// text and voice when that language has no voice on this device.
  static Future<void> _applyLanguage() async {
    if (_selectedLanguage != SpeechLanguage.english) {
      Object? failure;
      try {
        final selected = await _tts
            .setLanguage(_selectedLanguage.voiceLocale)
            .timeout(_engineTimeout);
        if (selected == 1) {
          Speech.language = _selectedLanguage;
          return;
        }
      } catch (error) {
        failure = error;
      }
      Speech.language = SpeechLanguage.english;
      _report(
        Speech.t.ttsLanguageFallback(languageName(_selectedLanguage)),
        failure ?? StateError('No ${_selectedLanguage.name} voice'),
      );
    }
    Speech.language = SpeechLanguage.english;
    final language = await _tts
        .setLanguage(_englishLanguage)
        .timeout(_engineTimeout);
    if (language != 1) {
      final fallback = await _tts.setLanguage('en-US').timeout(_engineTimeout);
      if (fallback != 1) throw StateError('No English TTS voice available');
    }
  }

  /// The name of [language], spoken in the current speech language.
  static String languageName(SpeechLanguage language) {
    final t = Speech.t;
    return switch (language) {
      SpeechLanguage.english => t.languageEnglish,
      SpeechLanguage.hindi => t.languageHindi,
      SpeechLanguage.kannada => t.languageKannada,
      SpeechLanguage.telugu => t.languageTelugu,
      SpeechLanguage.bengali => t.languageBengali,
    };
  }

  /// Saves and applies the speech language. Returns false when the device
  /// has no voice for it and SEEDS fell back to English.
  static Future<bool> setSpeechLanguage(SpeechLanguage language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, language.code);
    // Chosen before signing in: the next sign-in keeps it instead of the
    // account's older saved language.
    if (!prefs.containsKey('token')) {
      await prefs.setString(languageChosenSignedOutKey, language.code);
    }
    _selectedLanguage = language;
    await stop();
    if (_initializing != null) await _initializing;
    if (!_isInitialized) {
      await init();
    } else {
      try {
        await _applyLanguage();
        if (Speech.language == language) issue.value = null;
      } catch (error) {
        _report(Speech.t.ttsUnavailable, error);
      }
    }
    return Speech.language == language;
  }

  static const _languageKey = 'speech_language';
  static const languageChosenSignedOutKey = 'speech_language_signed_out';

  /// Follows Android TalkBack unless the user explicitly chose a speech mode
  /// in Settings, so app speech and the screen reader never talk together.
  static Future<void> syncWithPlatformScreenReader(bool active) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('speech_mode')) return;
    final mode = active ? SpeechMode.screenReader : SpeechMode.selfVoicing;
    if (mode == _mode) return;
    await configure(mode: mode);
    await speak(
      active ? Speech.t.ttsScreenReaderDetected : Speech.t.ttsScreenReaderOff,
      priority: SpeechPriority.critical,
    );
  }

  static Future<void> loadFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await _migrateSpeechRate(prefs);
    final language = SpeechLanguage.fromCode(prefs.getString(_languageKey));
    if (language != _selectedLanguage) {
      _selectedLanguage = language;
      if (_isInitialized) {
        try {
          await _applyLanguage();
        } catch (error) {
          _report(Speech.t.ttsUnavailable, error);
        }
      }
    }
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

  /// Settings used to save the old default (1.5 times) on every save, so a
  /// stored 0.75 almost always means "never changed". Move those phones to
  /// the new default once; any other saved speed is kept.
  static Future<void> _migrateSpeechRate(SharedPreferences prefs) async {
    if ((prefs.getInt(_speechRateVersionKey) ?? 1) >= _speechRateVersion) {
      return;
    }
    if (prefs.getDouble('tts_speech_rate') == _previousDefaultSpeechRate) {
      await prefs.remove('tts_speech_rate');
    }
    await prefs.setInt(_speechRateVersionKey, _speechRateVersion);
  }

  /// Checks that the device has a voice for the chosen speech language.
  static Future<String> checkVoice() async {
    try {
      return await (_checkingVoice ??= _checkVoice());
    } finally {
      _checkingVoice = null;
    }
  }

  static Future<String> _checkVoice() async {
    final language = _selectedLanguage;
    final english = language == SpeechLanguage.english;
    try {
      await init();
      await stop();
      final locales = english ? ['en-IN', 'en-US'] : [language.voiceLocale];
      for (final locale in locales) {
        final available = await _tts
            .isLanguageAvailable(locale)
            .timeout(_engineTimeout);
        if (available == false) continue;
        if (available != true) {
          throw StateError('Unexpected language availability response');
        }
        final selected = await _tts.setLanguage(locale).timeout(_engineTimeout);
        if (selected != 1) {
          throw StateError('Language selection not acknowledged');
        }
        if (english) _englishLanguage = locale;
        Speech.language = language;
        final installed = await _tts
            .isLanguageInstalled(locale)
            .timeout(_engineTimeout);
        if (installed is! bool) {
          throw StateError('Unexpected installed-language response');
        }
        issue.value = null;
        final name = languageName(language);
        return installed
            ? Speech.t.ttsVoiceInstalled(name)
            : '${Speech.t.ttsVoiceNotOffline(name)} '
                  '${Speech.t.ttsVoiceRecovery(name)}';
      }
      final message = await _voiceProblem(
        language,
        (t, name) => t.ttsVoiceMissing(name),
      );
      if (english) _isInitialized = false;
      _report(message, StateError('No ${language.name} voice'));
      return message;
    } catch (error) {
      final message = await _voiceProblem(
        language,
        (t, name) => t.ttsVoiceUnverified(name),
      );
      _report(message, error);
      return message;
    }
  }

  /// A voice problem with recovery steps. For a language other than English
  /// SEEDS returns to English speech, so the problem is said in English.
  static Future<String> _voiceProblem(
    SpeechLanguage language,
    String Function(AppLocalizations t, String name) problem,
  ) async {
    if (language != SpeechLanguage.english) {
      Speech.language = SpeechLanguage.english;
      try {
        await _tts.setLanguage(_englishLanguage).timeout(_engineTimeout);
      } catch (_) {
        // Reported by the caller; English speech is retried on next init.
      }
    }
    final t = Speech.t;
    final name = languageName(language);
    return '${problem(t, name)} ${t.ttsVoiceRecovery(name)}';
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
    if (speechRate != null) _speechRate = clampSpeechRate(speechRate);
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
      _report(Speech.t.ttsSettingsFailed, error);
    }
  }

  static Future<void> _applyVoiceSettings() async {
    await _tts.setSpeechRate(effectiveSpeechRate);
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
    if (!_enabled || text.trim().isEmpty) return;
    if (priority == SpeechPriority.incidental) {
      final key = group ?? text;
      if (_updates.containsKey(key) || _updates.length < 8) {
        _updates.update(key, (count) => count + 1, ifAbsent: () => 1);
      } else {
        _updates.update(
          _otherUpdatesKey,
          (count) => count + 1,
          ifAbsent: () => 1,
        );
      }
      _scheduleUpdates();
      return;
    }
    if (_mode == SpeechMode.screenReader) {
      // The screen reader owns the voice; hand it the message instead of
      // dropping it, otherwise status changes would be silent for its users.
      try {
        await SemanticsService.announce(text, TextDirection.ltr);
      } catch (error) {
        debugPrint('[TTS] Screen reader announcement failed: $error');
      }
      return;
    }
    final generation = ++_speechGeneration;
    _activePriority = priority;
    _currentText = text;
    _setSpeaking(true);
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
      if (generation == _speechGeneration) {
        _report(Speech.t.ttsCouldNotStart, error);
        await _finish(generation);
      }
    }
  }

  static Future<void> _utter(String text, int generation) async {
    try {
      final result = await _tts.speak(text);
      if (result == 0 && generation == _speechGeneration) {
        _report(Speech.t.ttsNotAvailable, result);
      } else if (generation == _speechGeneration) {
        _blocked = null;
        issue.value = null;
      }
    } on PlatformException catch (error) {
      if (generation != _speechGeneration) return;
      if (_isAwaitingUserGesture(error)) {
        // Browsers allow speech only after a click or key press on the page.
        // Not a failure: keep the sentence for the first interaction.
        _blocked = text;
        debugPrint('[TTS] Waiting for a click or key press before speaking.');
      } else {
        _report(Speech.t.ttsFailed, error);
      }
    } catch (error) {
      if (generation == _speechGeneration) {
        _report(Speech.t.ttsFailed, error);
      }
    } finally {
      await _finish(generation);
    }
  }

  static String? _blocked;

  static bool _isAwaitingUserGesture(PlatformException error) =>
      error.code == 'browser_speech' && error.message == 'not-allowed';

  /// The latest sentence the browser refused to speak because the page had
  /// no click or key press yet, once. The first interaction speaks it.
  static String? takeBlockedSpeech() {
    final text = _blocked;
    _blocked = null;
    return text;
  }

  static Future<void> _finish(int generation) async {
    if (generation != _speechGeneration) return;
    _activePriority = null;
    _currentText = null;
    _setSpeaking(false);
    await _resumePaused(generation);
    _scheduleUpdates();
  }

  static Future<void> _resumePaused(int generation) async {
    if (generation != _speechGeneration) return;
    final paused = Map.of(_paused);
    for (final entry in paused.entries) {
      if (generation != _speechGeneration) return;
      _paused.remove(entry.key);
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
        _report(Speech.t.ttsLessonResumeFailed, error);
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

  static const _otherUpdatesKey = '\u0000other';

  static String _updateGroupName(String key) =>
      key == _otherUpdatesKey ? Speech.t.ttsOtherUpdates : key;

  static Future<void> readPendingUpdates() async {
    final entries = _updates.entries.toList();
    _updates.clear();
    final limit = _verbosity == SpeechVerbosity.detailed ? entries.length : 3;
    final t = Speech.t;
    await speak(
      entries.isEmpty
          ? t.ttsNoPendingUpdates
          : [
              for (final entry in entries.take(limit))
                entry.value > 1
                    ? t.ttsUpdateGroupCount(
                        _updateGroupName(entry.key),
                        entry.value,
                      )
                    : t.ttsUpdateGroup(_updateGroupName(entry.key)),
              if (entries.length > limit)
                t.ttsOtherUpdateGroups(entries.length - limit),
            ].join(' '),
    );
  }

  static Future<void> stop() async {
    await stopForVoiceCommands();
  }

  static Future<bool> stopForVoiceCommands() async {
    final generation = ++_speechGeneration;
    _activePriority = null;
    _currentText = null;
    _setSpeaking(false);
    _updateTimer?.cancel();
    _updateTimer = null;
    _updates.clear();
    var stopped = true;
    try {
      await _tts.stop().timeout(_engineTimeout);
    } catch (error) {
      stopped = false;
      _report(Speech.t.ttsStopFailed, error);
    }
    await _resumePaused(generation);
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

  // Web Speech error codes are a fixed list and never contain spoken text,
  // so they are safe to log. Other platform messages may echo private text.
  static const _browserErrorCodes = {
    'canceled',
    'interrupted',
    'audio-busy',
    'audio-hardware',
    'network',
    'synthesis-unavailable',
    'synthesis-failed',
    'language-unavailable',
    'voice-unavailable',
    'text-too-long',
    'invalid-argument',
    'not-allowed',
  };

  static void _report(String message, Object error) {
    issue.value = message;
    final detail =
        error is PlatformException &&
            error.code == 'browser_speech' &&
            _browserErrorCodes.contains(error.message)
        ? 'browser: ${error.message}'
        : error.runtimeType;
    debugPrint('[TTS] $message ($detail)');
  }
}
