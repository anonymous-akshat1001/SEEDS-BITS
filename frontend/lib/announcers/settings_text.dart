/// Spoken text for Settings.
abstract final class SettingsText {
  static String _onOff(bool value) => value ? 'on' : 'off';

  static String soundCues(bool enabled) =>
      'Sound cues ${_onOff(enabled)}.${enabled ? ' This is the saved sound.' : ''}';
  static String vibration(bool enabled) =>
      'Vibration ${_onOff(enabled)}.${enabled ? ' One short buzz means OK.' : ''}';
  static String soundCuesLabel(bool enabled) =>
      'Sound cues, ${_onOff(enabled)}. Short sounds for correct, wrong, saved, errors and your turn to speak';
  static String vibrationLabel(bool enabled) =>
      'Vibration, ${_onOff(enabled)}. One buzz for OK, two for an error, a long buzz for leaving';
  static const soundCuesHelp =
      'Short sounds for correct, wrong, saved, errors, end of list and your turn to speak. Saved immediately.';
  static const vibrationHelp =
      'One short buzz for OK, two for an error, one long buzz for leaving or ending. Saved immediately.';

  /// Star summary of the current values.
  static String state({
    required bool speech,
    required String speed,
    required int volume,
    required int textSize,
    required bool highContrast,
    required bool soundCues,
    required bool vibration,
  }) =>
      'App speech ${_onOff(speech)}, speed $speed, volume $volume percent. '
      'Text size $textSize percent. High contrast ${_onOff(highContrast)}. '
      'Sound cues ${_onOff(soundCues)}. Vibration ${_onOff(vibration)}.';

  static String volume(int percent) => 'Volume $percent percent';
  static String textSize(int percent) => 'Text size $percent percent';
  static const speechOff = 'App speech off';
  static const speechOn = 'App speech on';
  static String speechMode(String description) => 'Speech mode. $description';
  static String narration(String level) => 'Narration level $level.';
}
