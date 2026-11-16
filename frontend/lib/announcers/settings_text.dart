import '../l10n/speech.dart';
import '../services/tts_service.dart';
import '../utils/spoken_format.dart';

/// Spoken text for Settings.
abstract final class SettingsText {
  static AppLocalizations get _t => Speech.t;
  static String _onOff(bool value) => SpokenFormat.onOff(value);

  static String soundCues(bool enabled) => enabled
      ? _t.settingsSoundCuesOnSaved(_onOff(true))
      : _t.settingsSoundCues(_onOff(false));
  static String vibration(bool enabled) => enabled
      ? _t.settingsVibrationOnBuzz(_onOff(true))
      : _t.settingsVibration(_onOff(false));
  static String soundCuesLabel(bool enabled) =>
      _t.settingsSoundCuesLabel(_onOff(enabled));
  static String vibrationLabel(bool enabled) =>
      _t.settingsVibrationLabel(_onOff(enabled));
  static String get soundCuesHelp => _t.settingsSoundCuesHelp;
  static String get vibrationHelp => _t.settingsVibrationHelp;

  /// Star summary of the current values.
  static String state({
    required bool speech,
    required String speed,
    required int volume,
    required int textSize,
    required bool highContrast,
    required bool soundCues,
    required bool vibration,
  }) => _t.settingsState(
    _onOff(speech),
    speed,
    '$volume',
    '$textSize',
    _onOff(highContrast),
    _onOff(soundCues),
    _onOff(vibration),
    TtsService.languageName(TtsService.selectedLanguage),
  );

  static String volume(int percent) => _t.settingsVolume('$percent');
  static String textSize(int percent) => _t.settingsTextSize('$percent');
  static String get speechOff => _t.settingsSpeechOff;
  static String get speechOn => _t.settingsSpeechOn;
  static String speechMode(String description) =>
      _t.settingsSpeechMode(description);
  static String narration(SpeechVerbosity level) =>
      _t.settingsNarration(narrationName(level));

  static String narrationName(SpeechVerbosity level) => switch (level) {
    SpeechVerbosity.essential => _t.settingsNarrationEssential,
    SpeechVerbosity.standard => _t.settingsNarrationStandard,
    SpeechVerbosity.detailed => _t.settingsNarrationDetailed,
  };

  static String language(SpeechLanguage language) =>
      _t.settingsLanguage(TtsService.languageName(language));
  static String languageLabel(SpeechLanguage language) =>
      _t.settingsLanguageLabel(TtsService.languageName(language));
}
