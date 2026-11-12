import 'package:shared_preferences/shared_preferences.dart';

import '../announcers/quiz_text.dart';
import 'tts_service.dart';

/// A speech speed used only while a student answers or reviews a quiz, so
/// options can be heard faster (or slower) without changing the speed of
/// the rest of the app chosen in Settings.
///
/// The speed is remembered between quizzes. It starts at the Settings speed
/// until the student changes it.
class QuizSpeechSpeed {
  QuizSpeechSpeed(this._owner);

  static const preferenceKey = 'quiz_tts_speech_rate';

  final Object _owner;
  double _rate = TtsService.speechRate;
  bool _active = false;
  // What a speed change last re-read (for example the options), so pressing
  // 9 again while it is being re-read keeps re-reading it.
  String? _replayed;

  double get rate => _rate;

  /// "1.75 times normal speed".
  String get description => TtsService.describeSpeed(_rate);

  /// Applies the remembered quiz speed while the quiz screen is open.
  Future<void> start() async {
    _active = true;
    final prefs = await SharedPreferences.getInstance();
    if (!_active) return;
    _rate = TtsService.clampSpeechRate(
      prefs.getDouble(preferenceKey) ?? TtsService.speechRate,
    );
    await TtsService.setSpeechRateOverride(_owner, _rate);
  }

  /// Restores the Settings speed for the rest of the app.
  Future<void> stop() async {
    _active = false;
    await TtsService.setSpeechRateOverride(_owner, null);
  }

  /// Changes the quiz speed by [steps] of 0.25 times and speaks the result.
  /// If app speech was reading something (for example the options), it is
  /// read again from the start at the new speed.
  Future<void> change(int steps) async {
    if (TtsService.mode == SpeechMode.screenReader) {
      await TtsService.speak(QuizText.speedScreenReader);
      return;
    }
    final interrupted = TtsService.currentText;
    String? content = interrupted;
    final replayed = _replayed;
    if (content != null && replayed != null && content.endsWith(replayed)) {
      content = replayed;
    } else if (content != null && QuizText.isSpeedAnnouncement(content)) {
      content = null;
    }
    _replayed = content;
    final next = TtsService.clampSpeechRate(
      _rate + steps * TtsService.speechRateStep,
    );
    final String announcement;
    if (next == _rate) {
      announcement = QuizText.speedLimit(steps > 0, description);
    } else {
      _rate = next;
      await TtsService.setSpeechRateOverride(_owner, _rate);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(preferenceKey, _rate);
      announcement = QuizText.speedChanged(steps > 0, description);
    }
    await TtsService.speak(
      content == null ? announcement : '$announcement $content',
    );
  }

  /// Speaks the current quiz speed and how to change it.
  Future<void> read() => TtsService.speak(
    TtsService.mode == SpeechMode.screenReader
        ? QuizText.speedScreenReader
        : QuizText.speedRead(description),
  );
}
