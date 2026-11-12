import 'dart:async';
import 'dart:io' show Platform;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Short, distinct non-speech feedback. Cues are faster than words, still
/// work after # stops speech, and can be heard in a noisy classroom.
enum Cue {
  /// A request succeeded (one short buzz).
  ok,

  /// Something was saved (soft chime, one short buzz).
  saved,

  /// A right answer (rising two tones, one short buzz).
  correct,

  /// A wrong answer (low falling buzz, two buzzes).
  wrong,

  /// Something failed (low double buzz, two buzzes).
  error,

  /// D-pad wrapped at the end or top of a list (tick, tiny buzz).
  endOfList,

  /// Work started that needs waiting (two soft ticks, no buzz).
  loading,

  /// The microphone is live: your turn to speak (rising sweep, three buzzes).
  unmuted,

  /// The microphone is off (falling sweep, one short buzz).
  muted,

  /// Leaving, ending or logging out (falling three notes, one long buzz).
  leave,
}

class FeedbackCues {
  const FeedbackCues._();

  static const soundPreference = 'sound_cues_enabled';
  static const vibrationPreference = 'vibration_enabled';
  static const _channel = MethodChannel('seeds/feedback');

  static bool _sound = true;
  static bool _vibration = true;
  static AudioPlayer? _player;

  /// Every cue requested, newest last; used by tests and diagnostics.
  @visibleForTesting
  static final played = <Cue>[];

  static bool get soundEnabled => _sound;
  static bool get vibrationEnabled => _vibration;

  static const _files = {
    Cue.ok: 'saved',
    Cue.saved: 'saved',
    Cue.correct: 'correct',
    Cue.wrong: 'wrong',
    Cue.error: 'error',
    Cue.endOfList: 'end_of_list',
    Cue.loading: 'loading',
    Cue.unmuted: 'unmuted',
    Cue.muted: 'muted',
    Cue.leave: 'leave',
  };

  /// Vibration patterns: alternating on/off milliseconds, starting "on".
  static const _patterns = <Cue, List<int>>{
    Cue.ok: [40],
    Cue.saved: [40],
    Cue.correct: [40],
    Cue.wrong: [60, 120, 60],
    Cue.error: [60, 120, 60],
    Cue.endOfList: [15],
    Cue.loading: [],
    Cue.unmuted: [40, 80, 40, 80, 40],
    Cue.muted: [40],
    Cue.leave: [450],
  };

  static bool get _platformAudio =>
      !kIsWeb &&
      !Platform.environment.containsKey('FLUTTER_TEST') &&
      (Platform.isAndroid || Platform.isIOS);

  static Future<void> loadFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _sound = prefs.getBool(soundPreference) ?? true;
    _vibration = prefs.getBool(vibrationPreference) ?? true;
  }

  static Future<void> setSoundEnabled(bool enabled) async {
    _sound = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(soundPreference, enabled);
  }

  static Future<void> setVibrationEnabled(bool enabled) async {
    _vibration = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(vibrationPreference, enabled);
  }

  /// Plays [cue]. Never throws: feedback must not break the action.
  static Future<void> play(Cue cue) async {
    played.add(cue);
    if (played.length > 50) played.removeAt(0);
    await Future.wait([_playSound(cue), _vibrate(cue)]);
  }

  static Future<void> _playSound(Cue cue) async {
    if (!_sound || !_platformAudio) return;
    try {
      final player = _player ??= AudioPlayer()
        ..setPlayerMode(PlayerMode.lowLatency);
      await player.stop();
      await player.play(AssetSource('cues/${_files[cue]}.wav'), volume: 0.8);
    } catch (error) {
      debugPrint('[CUES] Sound failed (${error.runtimeType})');
    }
  }

  static Future<void> _vibrate(Cue cue) async {
    final pattern = _patterns[cue]!;
    if (!_vibration || pattern.isEmpty || kIsWeb) return;
    try {
      await _channel.invokeMethod<void>('vibrate', {'pattern': pattern});
    } on MissingPluginException {
      await _fallbackVibrate(pattern);
    } on PlatformException {
      await _fallbackVibrate(pattern);
    }
  }

  static Future<void> _fallbackVibrate(List<int> pattern) async {
    // Only real phones buzz; widget tests and desktops have no motor.
    if (!_platformAudio) return;
    for (var i = 0; i < pattern.length; i += 2) {
      await (pattern[i] >= 300
          ? HapticFeedback.heavyImpact()
          : HapticFeedback.vibrate());
      if (i + 1 < pattern.length) {
        await Future<void>.delayed(Duration(milliseconds: pattern[i + 1]));
      }
    }
  }
}
