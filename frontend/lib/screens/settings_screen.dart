import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/tts_service.dart';
import '../announcers/settings_text.dart';
import '../l10n/speech.dart';
import '../utils/spoken_format.dart';
import '../services/feedback_cues.dart';
import '../services/message_center.dart';
import '../services/activity_telemetry.dart';
import '../utils/ui_utils.dart';
import '../utils/keypad_actions.dart';
import '../widgets/key_instruction_wrapper.dart';

// Settings Screen Widget
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  // Link widget to logic
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

// Define the Settings State Class
class _SettingsScreenState extends State<SettingsScreen> {
  // Default values of the settings/shortcuts
  bool _ttsEnabled = true;
  bool _voiceCommandsEnabled = false;
  bool _showKeyboardShortcuts = true;
  bool _highContrastMode = true;
  double _ttsVolume = 1.0;
  double _ttsSpeechRate = TtsService.defaultSpeechRate;
  double _textScale = 1.0;

  /// Explicit user choice; null means Automatic (follow TalkBack). Only an
  /// explicit choice is stored as 'speech_mode', so automatic switching in
  /// TtsService keeps working until the user picks a mode.
  SpeechMode? _speechModeChoice;
  bool _platformScreenReader = false;
  SpeechVerbosity _verbosity = SpeechVerbosity.standard;
  final _modeFocus = FocusNode(debugLabel: 'settings-speech-mode');
  final _verbosityFocus = FocusNode(debugLabel: 'settings-verbosity');
  final _stopFocus = FocusNode(debugLabel: 'settings-stop-speech');
  final _repeatFocus = FocusNode(debugLabel: 'settings-repeat-help');
  final _voiceCheckFocus = FocusNode(debugLabel: 'settings-english-voice');
  final _languageFocus = FocusNode(debugLabel: 'settings-language');
  SpeechLanguage _language = TtsService.selectedLanguage;
  bool _changingLanguage = false;
  bool _checkingVoice = false;
  String? _voiceStatus;
  final FocusNode _backFocus = FocusNode(debugLabel: 'settings-back');
  final FocusNode _resetFocus = FocusNode(debugLabel: 'settings-reset');
  final FocusNode _ttsFocus = FocusNode(debugLabel: 'settings-tts');
  final FocusNode _volumeFocus = FocusNode(debugLabel: 'settings-volume');
  final FocusNode _rateFocus = FocusNode(debugLabel: 'settings-rate');
  final FocusNode _testFocus = FocusNode(debugLabel: 'settings-test');
  final FocusNode _voiceFocus = FocusNode(debugLabel: 'settings-voice');
  final FocusNode _voiceHelpFocus = FocusNode(
    debugLabel: 'settings-voice-help',
  );
  final FocusNode _shortcutsFocus = FocusNode(debugLabel: 'settings-shortcuts');
  final FocusNode _contrastFocus = FocusNode(debugLabel: 'settings-contrast');
  final FocusNode _textScaleFocus = FocusNode(
    debugLabel: 'settings-text-scale',
  );
  final FocusNode _saveFocus = FocusNode(debugLabel: 'settings-save');
  final FocusNode _cuesFocus = FocusNode(debugLabel: 'settings-sound-cues');
  final FocusNode _vibrationFocus = FocusNode(debugLabel: 'settings-vibration');

  static String get _voiceHelpText => Speech.t.settingsVoiceHelp;

  SpeechMode get _speechMode =>
      _speechModeChoice ??
      (_platformScreenReader
          ? SpeechMode.screenReader
          : SpeechMode.selfVoicing);

  String get _speechModeDescription => switch (_speechModeChoice) {
    null => Speech.t.settingsModeAutomatic(
      _speechMode == SpeechMode.screenReader
          ? Speech.t.settingsModeUsingScreenReader
          : Speech.t.settingsModeUsingSelfVoicing,
    ),
    SpeechMode.screenReader => Speech.t.settingsModeScreenReader,
    SpeechMode.selfVoicing => Speech.t.settingsModeSelfVoicing,
  };

  // Called once when widget is created
  @override
  void initState() {
    super.initState();
    // Starts loading settings from storage
    _loadSettings();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _platformScreenReader =
        MediaQuery.maybeAccessibleNavigationOf(context) ?? false;
  }

  // Function to load the settings from storage
  Future<void> _loadSettings() async {
    // open local storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('audio_sync_tolerance');
    if (!mounted) return;

    // set the initial values and store in local storage
    setState(() {
      _ttsEnabled = prefs.getBool('tts_enabled') ?? true;
      _voiceCommandsEnabled = prefs.getBool('voice_commands_enabled') ?? false;
      _showKeyboardShortcuts = prefs.getBool('show_keyboard_shortcuts') ?? true;
      _highContrastMode = prefs.getBool('high_contrast_mode') ?? true;
      _ttsVolume = prefs.getDouble('tts_volume') ?? 1.0;
      _ttsSpeechRate =
          prefs.getDouble('tts_speech_rate') ?? TtsService.defaultSpeechRate;
      _textScale = prefs.getDouble('text_scale') ?? 1.0;
      _speechModeChoice = switch (prefs.getString('speech_mode')) {
        'screenReader' => SpeechMode.screenReader,
        'selfVoicing' => SpeechMode.selfVoicing,
        _ => null,
      };
      _verbosity = switch (prefs.getString('speech_verbosity')) {
        'essential' => SpeechVerbosity.essential,
        'detailed' => SpeechVerbosity.detailed,
        _ => SpeechVerbosity.standard,
      };
      _language = SpeechLanguage.fromCode(prefs.getString('speech_language'));
    });

    UIUtils.setHighContrastMode(_highContrastMode);
    UIUtils.setTextScale(_textScale);
    // Applies volume & speech rate to TTS engine
    await _configureTTS();
    // Speaks confirmation only if TTS is enabled
    await _speakIfEnabled(Speech.t.settingsLoaded);
  }

  // Saves current values permanently
  Future<void> _saveSettings({String? message}) async {
    message ??= Speech.t.settingsSaved;
    final prefs = await SharedPreferences.getInstance();

    // saves each setting under a key
    await prefs.setBool('tts_enabled', _ttsEnabled);
    await prefs.setBool('voice_commands_enabled', _voiceCommandsEnabled);
    await prefs.setBool('show_keyboard_shortcuts', _showKeyboardShortcuts);
    await prefs.setBool('high_contrast_mode', _highContrastMode);
    await prefs.setDouble('tts_volume', _ttsVolume);
    await prefs.setDouble('tts_speech_rate', _ttsSpeechRate);
    await prefs.setDouble('text_scale', _textScale);
    // Writing 'speech_mode' turns off automatic TalkBack detection, so it is
    // stored only when the user explicitly chose a mode.
    final choice = _speechModeChoice;
    if (choice == null) {
      await prefs.remove('speech_mode');
    } else {
      await prefs.setString('speech_mode', choice.name);
    }
    await prefs.setString('speech_verbosity', _verbosity.name);

    UIUtils.setHighContrastMode(_highContrastMode);
    UIUtils.setTextScale(_textScale);
    // apply changes to TTS
    await _configureTTS();
    // One announcement only: TtsService also reaches TalkBack, so the
    // SnackBar below is hidden from screen readers.
    await _speakIfEnabled(message);
    ActivityTelemetry.record('settings_saved');
    if (!mounted) return;

    // Spoken above; the message bar keeps it readable.
    MessageCenter.show(message, kind: MessageKind.success, speak: false);
  }

  // Applies TTS settings to system engine
  Future<void> _configureTTS() async {
    // apply volume, speech rate and pitch
    try {
      await TtsService.configure(
        enabled: _ttsEnabled,
        volume: _ttsVolume,
        speechRate: _ttsSpeechRate,
        mode: _speechMode,
        verbosity: _verbosity,
      );
    } catch (e) {
      debugPrint('[TTS CONFIG] Error: $e');
    }
  }

  // Helper function to centralize TTS logic
  Future<void> _speakIfEnabled(String text) async {
    // Give audio feedback only if TTS is enabled
    if (_ttsEnabled) {
      try {
        await TtsService.speak(text);
      } catch (e) {
        debugPrint('[TTS] Error: $e');
      }
    }
  }

  // Function to test the TTS setting applied
  Future<void> _testTTS() async {
    await _configureTTS();
    await TtsService.speak(
      Speech.t.settingsTestSpeech(
        '${_percent(_ttsVolume)}',
        TtsService.describeSpeed(_ttsSpeechRate),
      ),
    );
  }

  Future<void> _checkVoice() async {
    if (_checkingVoice) return;
    setState(() => _checkingVoice = true);
    final message = await TtsService.checkVoice();
    if (!mounted) return;
    setState(() {
      _checkingVoice = false;
      _voiceStatus = message;
    });
    await TtsService.speak(message);
  }

  /// Moves to the next speech language. Its voice is checked at once; when
  /// the phone has no voice for it, SEEDS keeps speaking English and says so.
  Future<void> _cycleLanguage() async {
    if (_changingLanguage) return;
    final next = SpeechLanguage
        .values[(_language.index + 1) % SpeechLanguage.values.length];
    setState(() {
      _language = next;
      _changingLanguage = true;
    });
    final available = await TtsService.setSpeechLanguage(next);
    if (!mounted) return;
    setState(() => _changingLanguage = false);
    await _speakIfEnabled(
      available
          ? SettingsText.language(next)
          : TtsService.issue.value ?? SettingsText.language(next),
    );
  }

  static int _percent(double value) => (value * 100).round();

  /// Slider changes from touch or TalkBack: TalkBack already reads the new
  /// slider value, so app speech only confirms it when self-voicing.
  bool get _speakSliderChanges => TtsService.mode == SpeechMode.selfVoicing;

  void _setVolume(double value, {bool announce = true}) {
    final next = value.clamp(0.0, 1.0).toDouble();
    setState(() => _ttsVolume = next);
    _configureTTS();
    if (announce) _speakIfEnabled(SettingsText.volume(_percent(next)));
  }

  void _setSpeechRate(double value, {bool announce = true}) {
    // Snap to the 0.25-times steps so D-pad and slider land on the same values.
    final steps = (value / TtsService.speechRateStep).round();
    final next = TtsService.clampSpeechRate(steps * TtsService.speechRateStep);
    final atLimit = next == _ttsSpeechRate && next != value;
    setState(() => _ttsSpeechRate = next);
    _configureTTS();
    if (announce) {
      _speakIfEnabled(
        atLimit
            ? (next >= TtsService.maxSpeechRate
                  ? Speech.t.settingsFastestSpeed(
                      TtsService.describeSpeed(next),
                    )
                  : Speech.t.settingsSlowestSpeed(
                      TtsService.describeSpeed(next),
                    ))
            : Speech.t.settingsSpeechSpeed(TtsService.describeSpeed(next)),
      );
    }
  }

  void _setTextScale(double value, {bool announce = true}) {
    final next = value.clamp(0.9, 1.5).toDouble();
    setState(() => _textScale = next);
    UIUtils.setTextScale(next);
    if (announce) _speakIfEnabled(SettingsText.textSize(_percent(next)));
  }

  // Function to restore the original values
  Future<void> _resetToDefaults() async {
    // ask user to give confirmation for the decision by showing a dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => const _ResetSettingsDialog(),
    );
    if (!mounted) return;
    // Return keypad focus to the control that opened the dialog.
    if (_resetFocus.context != null) _resetFocus.requestFocus();

    // set the default values
    if (confirm == true) {
      setState(() {
        _ttsEnabled = true;
        _voiceCommandsEnabled = false;
        _showKeyboardShortcuts = true;
        _highContrastMode = true;
        _ttsVolume = 1.0;
        _ttsSpeechRate = TtsService.defaultSpeechRate;
        _textScale = 1.0;
        _speechModeChoice = null;
        _verbosity = SpeechVerbosity.standard;
        _language = SpeechLanguage.english;
      });

      await TtsService.setSpeechLanguage(SpeechLanguage.english);
      await _saveSettings(message: Speech.t.settingsResetSaved);
      ActivityTelemetry.record('settings_reset');
    }
  }

  Future<void> _toggleTts() async {
    if (_ttsEnabled) {
      // Announce before disabling; once the engine is disabled it must remain
      // silent until the user explicitly enables it again.
      setState(() => _ttsEnabled = false);
      await TtsService.speak(SettingsText.speechOff);
      if (!mounted) return;
      await _saveBoolSetting('tts_enabled', false);
      await _configureTTS();
      return;
    }

    setState(() => _ttsEnabled = true);
    await _saveBoolSetting('tts_enabled', true);
    await _configureTTS();
    await TtsService.speak(SettingsText.speechOn);
  }

  /// Cycles Automatic -> Screen reader -> Self-voicing -> Automatic.
  Future<void> _cycleSpeechMode() async {
    setState(() {
      _speechModeChoice = switch (_speechModeChoice) {
        null => SpeechMode.screenReader,
        SpeechMode.screenReader => SpeechMode.selfVoicing,
        SpeechMode.selfVoicing => null,
      };
    });
    final prefs = await SharedPreferences.getInstance();
    final choice = _speechModeChoice;
    if (choice == null) {
      await prefs.remove('speech_mode');
    } else {
      await prefs.setString('speech_mode', choice.name);
    }
    await _configureTTS();
    if (!mounted) return;
    await TtsService.speak(SettingsText.speechMode(_speechModeDescription));
  }

  Future<void> _cycleVerbosity() async {
    setState(() {
      _verbosity = SpeechVerbosity
          .values[(_verbosity.index + 1) % SpeechVerbosity.values.length];
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('speech_verbosity', _verbosity.name);
    await _configureTTS();
    await TtsService.speak(SettingsText.narration(_verbosity));
  }

  void _repeatHelp() {
    TtsService.speak(
      buildTtsInstructions(
        settingsKeyLabels,
        screenName: Speech.t.settingsScreenName,
      ),
    );
  }

  Future<void> _toggleSoundCues() async {
    final enabled = !FeedbackCues.soundEnabled;
    await FeedbackCues.setSoundEnabled(enabled);
    if (!mounted) return;
    setState(() {});
    _speakIfEnabled(SettingsText.soundCues(enabled));
    if (enabled) unawaited(FeedbackCues.play(Cue.saved));
  }

  Future<void> _toggleVibration() async {
    final enabled = !FeedbackCues.vibrationEnabled;
    await FeedbackCues.setVibrationEnabled(enabled);
    if (!mounted) return;
    setState(() {});
    _speakIfEnabled(SettingsText.vibration(enabled));
    if (enabled) unawaited(FeedbackCues.play(Cue.ok));
  }

  void _toggleVoiceCommands() {
    setState(() => _voiceCommandsEnabled = !_voiceCommandsEnabled);
    _saveBoolSetting('voice_commands_enabled', _voiceCommandsEnabled);
    _speakIfEnabled(
      _voiceCommandsEnabled
          ? Speech.t.settingsVoiceCommandsEnabled
          : Speech.t.settingsVoiceCommandsDisabled,
    );
  }

  void _toggleHighContrast() {
    setState(() => _highContrastMode = !_highContrastMode);
    _saveBoolSetting('high_contrast_mode', _highContrastMode);
    UIUtils.setHighContrastMode(_highContrastMode);
    _speakIfEnabled(
      _highContrastMode
          ? Speech.t.settingsHighContrastOn
          : Speech.t.settingsHighContrastOff,
    );
  }

  void _toggleKeyboardShortcuts() {
    setState(() => _showKeyboardShortcuts = !_showKeyboardShortcuts);
    _saveBoolSetting('show_keyboard_shortcuts', _showKeyboardShortcuts);
    _speakIfEnabled(
      _showKeyboardShortcuts
          ? Speech.t.settingsShortcutsShown
          : Speech.t.settingsShortcutsHidden,
    );
  }

  Future<void> _saveBoolSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  // UI HELPERS (REUSABLE WIDGET BUILDERS)

  // Section with a screen-reader heading and a visible border.
  Widget _buildSettingSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: UIUtils.spacing(context, 10)),
      decoration: BoxDecoration(
        color: UIUtils.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: UIUtils.cardBorderColor, width: 1.5),
      ),
      child: Padding(
        padding: UIUtils.paddingAll(context, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: Text(
                title,
                style: TextStyle(
                  fontSize: UIUtils.fontSize(context, 18),
                  fontWeight: FontWeight.w700,
                  color: UIUtils.accentColor,
                ),
              ),
            ),
            Divider(color: UIUtils.cardBorderColor),
            ...children,
          ],
        ),
      ),
    );
  }

  TextStyle _titleStyle(BuildContext context) => TextStyle(
    fontSize: UIUtils.fontSize(context, 16),
    fontWeight: FontWeight.w600,
    color: UIUtils.textColor,
  );

  TextStyle _subtitleStyle(BuildContext context) => TextStyle(
    fontSize: UIUtils.fontSize(context, 14),
    color: UIUtils.subtextColor,
  );

  // Switch Tile : Reusable switch row
  Widget _buildSwitchTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required FocusNode focusNode,
  }) {
    return SwitchListTile(
      focusNode: focusNode,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      title: Text(title, style: _titleStyle(context)),
      subtitle: Text(subtitle, style: _subtitleStyle(context)),
      value: value,
      onChanged: onChanged,
      activeThumbColor: UIUtils.onAccentColor,
      activeTrackColor: UIUtils.accentColor,
      inactiveThumbColor: UIUtils.textColor,
      inactiveTrackColor: UIUtils.cardColor,
      trackOutlineColor: WidgetStatePropertyAll(UIUtils.cardBorderColor),
    );
  }

  // Adjustable value: a keypad focus stop changed with D-pad left/right
  // (registered in the focus targets), the screen reader's increase and
  // decrease actions, or the - and + buttons. Not a touch-only slider.
  Widget _buildSliderTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
    required String Function(double) valueText,
    required FocusNode focusNode,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: ExcludeSemantics(
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              spacing: 8,
              children: [
                Text(title, style: _titleStyle(context)),
                Text(
                  valueText(value),
                  style: TextStyle(
                    fontSize: UIUtils.fontSize(context, 16),
                    fontWeight: FontWeight.bold,
                    color: UIUtils.accentColor,
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(subtitle, style: _subtitleStyle(context)),
        ),
        Builder(
          builder: (context) {
            final step = (max - min) / divisions;
            double clamp(double next) => next.clamp(min, max).toDouble();
            return Semantics(
              label: title,
              value: valueText(value),
              increasedValue: valueText(clamp(value + step)),
              decreasedValue: valueText(clamp(value - step)),
              onIncrease: () => onChanged(clamp(value + step)),
              onDecrease: () => onChanged(clamp(value - step)),
              excludeSemantics: true,
              child: Focus(
                focusNode: focusNode,
                child: Builder(
                  builder: (context) {
                    final focused = Focus.of(context).hasFocus;
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: focused
                              ? UIUtils.focusRingColor
                              : UIUtils.cardBorderColor,
                          width: focused ? 3 : 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          ExcludeFocus(
                            child: IconButton(
                              tooltip: Speech.t.settingsDecrease(title),
                              onPressed: () => onChanged(clamp(value - step)),
                              icon: const Icon(Icons.remove),
                            ),
                          ),
                          Expanded(
                            child: LinearProgressIndicator(
                              value: ((value - min) / (max - min)).clamp(
                                0.0,
                                1.0,
                              ),
                              minHeight: 8,
                              color: UIUtils.accentColor,
                              backgroundColor: UIUtils.cardBorderColor,
                            ),
                          ),
                          ExcludeFocus(
                            child: IconButton(
                              tooltip: Speech.t.settingsIncrease(title),
                              onPressed: () => onChanged(clamp(value + step)),
                              icon: const Icon(Icons.add),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // saves memory since it is called when screen is destroyed
  @override
  void dispose() {
    _modeFocus.dispose();
    _verbosityFocus.dispose();
    _stopFocus.dispose();
    _repeatFocus.dispose();
    _voiceCheckFocus.dispose();
    _languageFocus.dispose();
    _backFocus.dispose();
    _resetFocus.dispose();
    _ttsFocus.dispose();
    _volumeFocus.dispose();
    _rateFocus.dispose();
    _testFocus.dispose();
    _voiceFocus.dispose();
    _voiceHelpFocus.dispose();
    _shortcutsFocus.dispose();
    _contrastFocus.dispose();
    _textScaleFocus.dispose();
    _saveFocus.dispose();
    _cuesFocus.dispose();
    _vibrationFocus.dispose();
    super.dispose();
  }

  Widget _buildActionButton(
    BuildContext context, {
    required FocusNode focusNode,
    required String text,
    required VoidCallback? onPressed,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: OutlinedButton(
        focusNode: focusNode,
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: UIUtils.textColor,
          side: BorderSide(color: UIUtils.cardBorderColor, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          alignment: Alignment.centerLeft,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              ExcludeSemantics(
                child: Icon(
                  icon,
                  size: UIUtils.iconSize(context, 20),
                  color: UIUtils.accentColor,
                ),
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: UIUtils.fontSize(context, 16),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusText(BuildContext context, String message) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Semantics(
      liveRegion: true,
      child: Text(
        message,
        style: TextStyle(
          fontSize: UIUtils.fontSize(context, 14),
          color: UIUtils.textColor,
        ),
      ),
    ),
  );

  String _onOff(bool value) => SpokenFormat.onOff(value);

  // Build UI Widgets
  @override
  Widget build(BuildContext context) {
    final bool tiny = UIUtils.isTiny(context);
    final t = Speech.t;

    return KeypadInstructionWrapper(
      screenName: t.settingsScreenName,
      navigationSections: t.settingsSections,
      stateSummary: () => SettingsText.state(
        speech: _ttsEnabled,
        speed: TtsService.describeSpeed(_ttsSpeechRate),
        volume: _percent(_ttsVolume),
        textSize: _percent(_textScale),
        highContrast: _highContrastMode,
        soundCues: FeedbackCues.soundEnabled,
        vibration: FeedbackCues.vibrationEnabled,
      ),
      onSpeechRescued: () => setState(() {
        _ttsEnabled = TtsService.isEnabled;
        _ttsVolume = TtsService.volume;
      }),
      labels: settingsKeyLabels,
      focusTargets: [
        KeypadFocusTarget(
          node: _backFocus,
          label: t.settingsBack,
          onActivate: () => Navigator.maybePop(context),
        ),
        KeypadFocusTarget(
          node: _resetFocus,
          label: t.settingsResetLabel,
          onActivate: _resetToDefaults,
        ),
        // ── Speech section ──
        KeypadFocusTarget(
          node: _ttsFocus,
          label: t.settingsSpeechSectionLabel(_onOff(_ttsEnabled)),
          onActivate: _toggleTts,
        ),
        KeypadFocusTarget(
          node: _languageFocus,
          label: SettingsText.languageLabel(_language),
          onActivate: () => unawaited(_cycleLanguage()),
          isEnabled: () => !_changingLanguage,
        ),
        KeypadFocusTarget(
          node: _volumeFocus,
          label: t.settingsVolumeLabel('${_percent(_ttsVolume)}'),
          onDecrease: () => _setVolume(_ttsVolume - 0.1),
          onIncrease: () => _setVolume(_ttsVolume + 0.1),
        ),
        KeypadFocusTarget(
          node: _rateFocus,
          label: t.settingsSpeedLabel(TtsService.describeSpeed(_ttsSpeechRate)),
          onDecrease: () =>
              _setSpeechRate(_ttsSpeechRate - TtsService.speechRateStep),
          onIncrease: () =>
              _setSpeechRate(_ttsSpeechRate + TtsService.speechRateStep),
        ),
        KeypadFocusTarget(
          node: _testFocus,
          label: t.settingsTestLabel,
          onActivate: _testTTS,
        ),
        KeypadFocusTarget(
          node: _modeFocus,
          label: t.settingsModeLabel(_speechModeDescription),
          onActivate: _cycleSpeechMode,
        ),
        KeypadFocusTarget(
          node: _verbosityFocus,
          label: t.settingsNarrationLabel(
            SettingsText.narrationName(_verbosity),
          ),
          onActivate: _cycleVerbosity,
        ),
        KeypadFocusTarget(
          node: _voiceCheckFocus,
          label: t.settingsCheckVoiceLabel(TtsService.languageName(_language)),
          onActivate: _checkVoice,
          isEnabled: () => !_checkingVoice,
        ),
        KeypadFocusTarget(
          node: _stopFocus,
          label: t.settingsStopLabel,
          onActivate: TtsService.stop,
        ),
        // ── Display section ──
        KeypadFocusTarget(
          node: _contrastFocus,
          label: t.settingsContrastLabel(_onOff(_highContrastMode)),
          onActivate: _toggleHighContrast,
        ),
        KeypadFocusTarget(
          node: _textScaleFocus,
          label: t.settingsTextSizeLabel('${_percent(_textScale)}'),
          onDecrease: () => _setTextScale(_textScale - 0.1),
          onIncrease: () => _setTextScale(_textScale + 0.1),
        ),
        // ── Keys and help section ──
        KeypadFocusTarget(
          node: _shortcutsFocus,
          label: t.settingsShortcutsLabel(_onOff(_showKeyboardShortcuts)),
          onActivate: _toggleKeyboardShortcuts,
        ),
        KeypadFocusTarget(
          node: _voiceFocus,
          label: t.settingsVoiceCommandsLabel(_onOff(_voiceCommandsEnabled)),
          onActivate: _toggleVoiceCommands,
        ),
        KeypadFocusTarget(
          node: _cuesFocus,
          label: SettingsText.soundCuesLabel(FeedbackCues.soundEnabled),
          onActivate: () => unawaited(_toggleSoundCues()),
        ),
        KeypadFocusTarget(
          node: _vibrationFocus,
          label: SettingsText.vibrationLabel(FeedbackCues.vibrationEnabled),
          onActivate: () => unawaited(_toggleVibration()),
        ),
        if (!tiny)
          KeypadFocusTarget(
            node: _voiceHelpFocus,
            label: t.settingsVoiceHelpLabel,
            onActivate: () => _speakIfEnabled(_voiceHelpText),
          ),
        KeypadFocusTarget(
          node: _repeatFocus,
          label: t.settingsRepeatHelpLabel,
          onActivate: _repeatHelp,
        ),
        KeypadFocusTarget(
          node: _saveFocus,
          label: t.settingsSaveLabel,
          onActivate: _saveSettings,
        ),
      ],
      actions: {
        0: () => Navigator.maybePop(context),
        1: _toggleTts,
        2: _toggleVoiceCommands,
        3: _toggleKeyboardShortcuts,
        4: _toggleHighContrast,
        5: _testTTS,
        6: _saveSettings,
        7: _checkVoice,
        8: () => unawaited(_toggleSoundCues()),
        9: () => unawaited(_toggleVibration()),
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            focusNode: _backFocus,
            tooltip: Speech.t.settingsBack,
            onPressed: () => Navigator.maybePop(context),
            icon: const Icon(Icons.arrow_back),
          ),
          title: UIUtils.useStackedLayout(context)
              ? null
              : Semantics(
                  header: true,
                  child: Text(
                    Speech.t.settingsScreenName,
                    style: TextStyle(
                      fontSize: UIUtils.fontSize(context, 18),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
          backgroundColor: UIUtils.cardColor,
          foregroundColor: UIUtils.textColor,
          elevation: 0,
          shape: Border(
            bottom: BorderSide(color: UIUtils.cardBorderColor, width: 1.5),
          ),
          toolbarHeight: tiny ? 44 : null,
          actions: [
            IconButton(
              focusNode: _resetFocus,
              icon: Icon(
                Icons.refresh_rounded,
                size: UIUtils.iconSize(context, 22),
                color: UIUtils.textColor,
              ),
              tooltip: Speech.t.settingsResetTooltip,
              onPressed: _resetToDefaults,
            ),
          ],
        ),

        backgroundColor: UIUtils.backgroundColor,

        body: SingleChildScrollView(
          padding: UIUtils.paddingAll(context, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (UIUtils.useStackedLayout(context))
                Semantics(
                  header: true,
                  child: Text(
                    Speech.t.settingsScreenName,
                    style: TextStyle(
                      fontSize: UIUtils.fontSize(context, 22),
                      fontWeight: FontWeight.bold,
                      color: UIUtils.textColor,
                    ),
                  ),
                ),
              ValueListenableBuilder<String?>(
                valueListenable: ActivityTelemetry.syncIssue,
                builder: (_, message, child) => message == null
                    ? const SizedBox.shrink()
                    : Semantics(liveRegion: true, child: Text(message)),
              ),
              _buildSettingSection(context, Speech.t.settingsSectionSpeech, [
                ValueListenableBuilder<String?>(
                  valueListenable: TtsService.issue,
                  builder: (_, message, child) => message == null
                      ? const SizedBox.shrink()
                      : _statusText(context, message),
                ),
                _buildSwitchTile(
                  context,
                  title: Speech.t.settingsAppSpeechTitle,
                  subtitle: Speech.t.settingsAppSpeechSubtitle,
                  value: _ttsEnabled,
                  onChanged: (_) => _toggleTts(),
                  focusNode: _ttsFocus,
                ),
                _buildActionButton(
                  context,
                  focusNode: _languageFocus,
                  onPressed: _changingLanguage
                      ? null
                      : () => unawaited(_cycleLanguage()),
                  icon: Icons.translate,
                  text: Speech.t.settingsLanguageButton(_language.displayName),
                ),
                _buildSliderTile(
                  context,
                  title: Speech.t.settingsVolumeTitle,
                  subtitle: Speech.t.settingsVolumeSubtitle,
                  value: _ttsVolume,
                  min: 0.0,
                  max: 1.0,
                  divisions: 10,
                  onChanged: (value) =>
                      _setVolume(value, announce: _speakSliderChanges),
                  valueText: (val) =>
                      Speech.t.settingsPercentValue('${_percent(val)}'),
                  focusNode: _volumeFocus,
                ),
                _buildSliderTile(
                  context,
                  title: Speech.t.settingsSpeedTitle,
                  subtitle: Speech.t.settingsSpeedSubtitle,
                  value: _ttsSpeechRate,
                  min: TtsService.minSpeechRate,
                  max: TtsService.maxSpeechRate,
                  divisions:
                      ((TtsService.maxSpeechRate - TtsService.minSpeechRate) /
                              TtsService.speechRateStep)
                          .round(),
                  onChanged: (value) =>
                      _setSpeechRate(value, announce: _speakSliderChanges),
                  valueText: (val) => Speech.t.settingsTimesNormal(
                    TtsService.formatSpeedMultiple(val),
                  ),
                  focusNode: _rateFocus,
                ),
                _buildActionButton(
                  context,
                  focusNode: _testFocus,
                  onPressed: _testTTS,
                  icon: Icons.volume_up,
                  text: Speech.t.settingsTestButton,
                ),
                _buildActionButton(
                  context,
                  focusNode: _modeFocus,
                  onPressed: _cycleSpeechMode,
                  icon: Icons.record_voice_over_outlined,
                  text: Speech.t.settingsSpeechMode(_speechModeDescription),
                ),
                _buildActionButton(
                  context,
                  focusNode: _verbosityFocus,
                  onPressed: _cycleVerbosity,
                  text: Speech.t.settingsNarrationButton(
                    SettingsText.narrationName(_verbosity),
                  ),
                ),
                _buildActionButton(
                  context,
                  focusNode: _voiceCheckFocus,
                  onPressed: _checkingVoice ? null : _checkVoice,
                  text: _checkingVoice
                      ? Speech.t.settingsCheckingVoice(_language.displayName)
                      : Speech.t.settingsCheckVoiceButton(
                          _language.displayName,
                        ),
                ),
                if (_voiceStatus != null) _statusText(context, _voiceStatus!),
                _buildActionButton(
                  context,
                  focusNode: _stopFocus,
                  onPressed: TtsService.stop,
                  text: Speech.t.settingsStopButton,
                ),
              ]),

              _buildSettingSection(context, Speech.t.settingsSectionDisplay, [
                _buildSwitchTile(
                  context,
                  title: Speech.t.settingsHighContrastTitle,
                  subtitle: Speech.t.settingsHighContrastSubtitle,
                  value: _highContrastMode,
                  onChanged: (_) => _toggleHighContrast(),
                  focusNode: _contrastFocus,
                ),
                _buildSliderTile(
                  context,
                  title: Speech.t.settingsTextSizeTitle,
                  subtitle: Speech.t.settingsTextSizeSubtitle,
                  value: _textScale,
                  min: 0.9,
                  max: 1.5,
                  divisions: 6,
                  onChanged: (value) =>
                      _setTextScale(value, announce: _speakSliderChanges),
                  valueText: (val) =>
                      Speech.t.settingsPercentValue('${_percent(val)}'),
                  focusNode: _textScaleFocus,
                ),
              ]),

              _buildSettingSection(context, Speech.t.settingsSectionKeys, [
                _buildSwitchTile(
                  context,
                  title: Speech.t.settingsShortcutsTitle,
                  subtitle: Speech.t.settingsShortcutsSubtitle,
                  value: _showKeyboardShortcuts,
                  onChanged: (_) => _toggleKeyboardShortcuts(),
                  focusNode: _shortcutsFocus,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 6,
                  ),
                  child: Text(
                    Speech.t.settingsGlobalKeysHint,
                    style: _subtitleStyle(context),
                  ),
                ),
                _buildSwitchTile(
                  context,
                  title: Speech.t.settingsVoiceCommandsTitle,
                  subtitle: Speech.t.settingsVoiceCommandsSubtitle,
                  value: _voiceCommandsEnabled,
                  onChanged: (_) => _toggleVoiceCommands(),
                  focusNode: _voiceFocus,
                ),
                _buildSwitchTile(
                  context,
                  title: Speech.t.settingsSoundCuesTitle,
                  subtitle: SettingsText.soundCuesHelp,
                  value: FeedbackCues.soundEnabled,
                  onChanged: (_) => unawaited(_toggleSoundCues()),
                  focusNode: _cuesFocus,
                ),
                _buildSwitchTile(
                  context,
                  title: Speech.t.settingsVibrationTitle,
                  subtitle: SettingsText.vibrationHelp,
                  value: FeedbackCues.vibrationEnabled,
                  onChanged: (_) => unawaited(_toggleVibration()),
                  focusNode: _vibrationFocus,
                ),
                if (!tiny)
                  _buildActionButton(
                    context,
                    focusNode: _voiceHelpFocus,
                    onPressed: () => _speakIfEnabled(_voiceHelpText),
                    text: Speech.t.settingsVoiceHelpButton,
                  ),
                _buildActionButton(
                  context,
                  focusNode: _repeatFocus,
                  onPressed: _repeatHelp,
                  text: Speech.t.settingsRepeatHelpLabel,
                ),
              ]),

              SizedBox(height: UIUtils.spacing(context, 12)),

              // Save Button
              ElevatedButton.icon(
                focusNode: _saveFocus,
                onPressed: _saveSettings,
                icon: Icon(
                  Icons.save_rounded,
                  size: UIUtils.iconSize(context, 22),
                ),
                label: Text(
                  Speech.t.keySaveSettings,
                  style: TextStyle(
                    fontSize: UIUtils.fontSize(context, 16),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: UIUtils.primaryColor,
                  foregroundColor: UIUtils.onPrimaryColor,
                  padding: UIUtils.paddingSymmetric(context, vertical: 14),
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: UIUtils.cardBorderColor,
                      width: 1.5,
                    ),
                  ),
                  elevation: 0,
                ),
              ),

              SizedBox(height: UIUtils.spacing(context, 10)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResetSettingsDialog extends StatefulWidget {
  const _ResetSettingsDialog();

  @override
  State<_ResetSettingsDialog> createState() => _ResetSettingsDialogState();
}

class _ResetSettingsDialogState extends State<_ResetSettingsDialog> {
  final FocusNode _cancelFocus = FocusNode(debugLabel: 'settings-reset-cancel');
  final FocusNode _confirmFocus = FocusNode(
    debugLabel: 'settings-reset-confirm',
  );

  @override
  void dispose() {
    _cancelFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    void close(bool confirmed) => Navigator.pop(context, confirmed);
    final t = Speech.t;
    final spokenMessage = t.settingsResetQuestion;
    final message = spokenMessage;

    return KeypadInstructionWrapper(
      screenName: t.settingsResetScreen(spokenMessage),
      labels: {1: t.settingsResetCancel, 2: t.settingsResetConfirm},
      actions: {1: () => close(false), 2: () => close(true)},
      // The safe choice is focused first.
      initialFocusNode: _cancelFocus,
      focusTargets: [
        KeypadFocusTarget(
          node: _cancelFocus,
          label: t.settingsResetCancelLabel,
          onActivate: () => close(false),
        ),
        KeypadFocusTarget(
          node: _confirmFocus,
          label: t.settingsResetConfirmLabel,
          onActivate: () => close(true),
        ),
      ],
      child: AlertDialog(
        scrollable: true,
        backgroundColor: UIUtils.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: UIUtils.cardBorderColor, width: 1.5),
        ),
        title: Semantics(
          header: true,
          child: Text(
            t.settingsResetTitle,
            style: TextStyle(
              color: UIUtils.textColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        content: Text(
          message,
          style: TextStyle(color: UIUtils.textColor, fontSize: 16),
        ),
        actions: [
          TextButton(
            focusNode: _cancelFocus,
            onPressed: () => close(false),
            child: Text(
              t.settingsResetCancelButton,
              style: TextStyle(color: UIUtils.accentColor, fontSize: 16),
            ),
          ),
          ElevatedButton(
            focusNode: _confirmFocus,
            onPressed: () => close(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: UIUtils.errorColor,
              foregroundColor: UIUtils.isHighContrast
                  ? Colors.black
                  : Colors.white,
            ),
            child: Text(
              t.settingsResetConfirmButton,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
