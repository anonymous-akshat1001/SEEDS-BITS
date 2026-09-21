import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/tts_service.dart';
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
  bool _highContrastMode = false;
  double _ttsVolume = 1.0;
  double _ttsSpeechRate = 0.5;
  double _textScale = 1.0;
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

  // Called once when widget is created
  @override
  void initState() {
    super.initState();
    // Starts loading settings from storage
    _loadSettings();
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
      _highContrastMode = prefs.getBool('high_contrast_mode') ?? false;
      _ttsVolume = prefs.getDouble('tts_volume') ?? 1.0;
      _ttsSpeechRate = prefs.getDouble('tts_speech_rate') ?? 0.5;
      _textScale = prefs.getDouble('text_scale') ?? 1.0;
    });

    UIUtils.setHighContrastMode(_highContrastMode);
    UIUtils.setTextScale(_textScale);
    // Applies volume & speech rate to TTS engine
    await _configureTTS();
    // Speaks confirmation only if TTS is enabled
    await _speakIfEnabled("Settings loaded");
  }

  // Saves current values permanently
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();

    // saves each setting under a key
    await prefs.setBool('tts_enabled', _ttsEnabled);
    await prefs.setBool('voice_commands_enabled', _voiceCommandsEnabled);
    await prefs.setBool('show_keyboard_shortcuts', _showKeyboardShortcuts);
    await prefs.setBool('high_contrast_mode', _highContrastMode);
    await prefs.setDouble('tts_volume', _ttsVolume);
    await prefs.setDouble('tts_speech_rate', _ttsSpeechRate);
    await prefs.setDouble('text_scale', _textScale);

    UIUtils.setHighContrastMode(_highContrastMode);
    UIUtils.setTextScale(_textScale);
    // apply changes to TTS
    await _configureTTS();
    await _speakIfEnabled("Settings saved");
    if (!mounted) return;

    // Visual confirmation at bottom of the screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings saved successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Applies TTS settings to system engine
  Future<void> _configureTTS() async {
    // apply volume, speech rate and pitch
    try {
      await TtsService.configure(
        enabled: _ttsEnabled,
        volume: _ttsVolume,
        speechRate: _ttsSpeechRate,
      );
    } catch (e) {
      print('[TTS CONFIG] Error: $e');
    }
  }

  // Helper function to centralize TTS logic
  Future<void> _speakIfEnabled(String text) async {
    // Give audio feedback only if TTS is enabled
    if (_ttsEnabled) {
      try {
        await TtsService.speak(text);
      } catch (e) {
        print('[TTS] Error: $e');
      }
    }
  }

  // Function to test the TTS setting applied
  Future<void> _testTTS() async {
    await _configureTTS();
    await TtsService.speak(
      "This is a test of the text to speech system. Volume is ${(_ttsVolume * 100).round()} percent. Speech rate is ${(_ttsSpeechRate * 2).toStringAsFixed(1)}.",
    );
  }

  void _setVolume(double value) {
    final next = value.clamp(0.0, 1.0).toDouble();
    setState(() => _ttsVolume = next);
    _configureTTS();
    _speakIfEnabled('Volume, ${(next * 100).round()} percent');
  }

  void _setSpeechRate(double value) {
    final next = value.clamp(0.1, 1.0).toDouble();
    setState(() => _ttsSpeechRate = next);
    _configureTTS();
    _speakIfEnabled('Speech rate, ${(next * 2).toStringAsFixed(1)}');
  }

  void _setTextScale(double value) {
    final next = value.clamp(0.9, 1.5).toDouble();
    setState(() => _textScale = next);
    UIUtils.setTextScale(next);
    _speakIfEnabled('Text size, ${(next * 100).round()} percent');
  }

  // Function to restore the original values
  Future<void> _resetToDefaults() async {
    // ask user to give confirmation for the decision by showing a dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => const _ResetSettingsDialog(),
    );

    // set the default values
    if (confirm == true) {
      setState(() {
        _ttsEnabled = true;
        _voiceCommandsEnabled = false;
        _showKeyboardShortcuts = true;
        _highContrastMode = false;
        _ttsVolume = 1.0;
        _ttsSpeechRate = 0.5;
        _textScale = 1.0;
      });

      await _saveSettings();
    }
  }

  Future<void> _toggleTts() async {
    if (_ttsEnabled) {
      // Announce before disabling; once the engine is disabled it must remain
      // silent until the user explicitly enables it again.
      setState(() => _ttsEnabled = false);
      await TtsService.speak('TTS disabled');
      if (!mounted) return;
      await _saveBoolSetting('tts_enabled', false);
      await _configureTTS();
      return;
    }

    setState(() => _ttsEnabled = true);
    await _saveBoolSetting('tts_enabled', true);
    await _configureTTS();
    await TtsService.speak('TTS enabled');
  }

  void _toggleVoiceCommands() {
    setState(() => _voiceCommandsEnabled = !_voiceCommandsEnabled);
    _saveBoolSetting('voice_commands_enabled', _voiceCommandsEnabled);
    _speakIfEnabled(
      _voiceCommandsEnabled
          ? "Voice commands enabled"
          : "Voice commands disabled",
    );
  }

  void _toggleHighContrast() {
    setState(() => _highContrastMode = !_highContrastMode);
    _saveBoolSetting('high_contrast_mode', _highContrastMode);
    UIUtils.setHighContrastMode(_highContrastMode);
    _speakIfEnabled(
      _highContrastMode ? "High contrast enabled" : "High contrast disabled",
    );
  }

  void _toggleKeyboardShortcuts() {
    setState(() => _showKeyboardShortcuts = !_showKeyboardShortcuts);
    _saveBoolSetting('show_keyboard_shortcuts', _showKeyboardShortcuts);
    _speakIfEnabled(
      _showKeyboardShortcuts
          ? "Keyboard shortcuts shown"
          : "Keyboard shortcuts hidden",
    );
  }

  Future<void> _saveBoolSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  // UI HELPERS (REUSABLE WIDGET BUILDERS)

  // Section Card
  Widget _buildSettingSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Card(
      margin: EdgeInsets.only(bottom: UIUtils.spacing(context, 10)),
      elevation: 2,
      child: Padding(
        padding: UIUtils.paddingAll(context, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: UIUtils.fontSize(context, 16),
                fontWeight: FontWeight.w700,
                color: UIUtils.primaryColor,
              ),
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

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
      dense: UIUtils.isTiny(context),
      title: Text(
        title,
        style: TextStyle(
          fontSize: UIUtils.fontSize(context, 14),
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: UIUtils.fontSize(context, 11)),
      ),
      value: value,
      onChanged: onChanged,
      activeThumbColor: UIUtils.accentColor,
    );
  }

  // Reusable slider + label UI
  Widget _buildSliderTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
    String Function(double)? labelBuilder,
    required FocusNode focusNode,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          dense: UIUtils.isTiny(context),
          contentPadding: EdgeInsets.zero,
          title: Text(
            title,
            style: TextStyle(
              fontSize: UIUtils.fontSize(context, 14),
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(fontSize: UIUtils.fontSize(context, 11)),
          ),
          trailing: Text(
            labelBuilder?.call(value) ?? value.toStringAsFixed(2),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: UIUtils.accentColor,
            ),
          ),
        ),

        Focus(
          focusNode: focusNode,
          child: AnimatedBuilder(
            animation: focusNode,
            builder: (context, child) => DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: focusNode.hasFocus
                    ? Border.all(color: UIUtils.accentColor, width: 3)
                    : null,
              ),
              child: child,
            ),
            child: ExcludeFocus(
              child: Slider(
                value: value,
                min: min,
                max: max,
                divisions: divisions,
                label: labelBuilder?.call(value) ?? value.toStringAsFixed(2),
                onChanged: onChanged,
                activeColor: UIUtils.accentColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // saves memory since it is called when screen is destroyed
  @override
  void dispose() {
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
    super.dispose();
  }

  // Build UI Widgets
  @override
  Widget build(BuildContext context) {
    final bool tiny = UIUtils.isTiny(context);

    return KeypadInstructionWrapper(
      screenName: 'Settings',
      labels: settingsKeyLabels,
      focusTargets: [
        KeypadFocusTarget(
          node: _backFocus,
          label: 'Back',
          onActivate: () => Navigator.maybePop(context),
        ),
        KeypadFocusTarget(
          node: _resetFocus,
          label: 'Reset settings to defaults',
          onActivate: _resetToDefaults,
        ),
        KeypadFocusTarget(
          node: _ttsFocus,
          label: 'Text to speech, currently ${_ttsEnabled ? 'on' : 'off'}',
          onActivate: _toggleTts,
        ),
        KeypadFocusTarget(
          node: _volumeFocus,
          label: 'Volume, ${(_ttsVolume * 100).round()} percent',
          onDecrease: () => _setVolume(_ttsVolume - 0.1),
          onIncrease: () => _setVolume(_ttsVolume + 0.1),
        ),
        KeypadFocusTarget(
          node: _rateFocus,
          label: 'Speech rate, ${(_ttsSpeechRate * 2).toStringAsFixed(1)}',
          onDecrease: () => _setSpeechRate(_ttsSpeechRate - 0.1),
          onIncrease: () => _setSpeechRate(_ttsSpeechRate + 0.1),
        ),
        KeypadFocusTarget(
          node: _testFocus,
          label: 'Test TTS',
          onActivate: _testTTS,
        ),
        KeypadFocusTarget(
          node: _voiceFocus,
          label: 'Voice commands for active sessions',
          onActivate: _toggleVoiceCommands,
        ),
        if (!tiny)
          KeypadFocusTarget(
            node: _voiceHelpFocus,
            label: 'Voice command help. Commands work only in active sessions.',
            onActivate: () => _speakIfEnabled(
              'In active sessions, say mute, unmute, raise hand, lower hand, leave, or repeat instructions.',
            ),
          ),
        KeypadFocusTarget(
          node: _shortcutsFocus,
          label: 'Show keypad shortcuts',
          onActivate: _toggleKeyboardShortcuts,
        ),
        KeypadFocusTarget(
          node: _contrastFocus,
          label: 'High contrast mode',
          onActivate: _toggleHighContrast,
        ),
        KeypadFocusTarget(
          node: _textScaleFocus,
          label: 'Text size, ${(_textScale * 100).round()} percent',
          onDecrease: () => _setTextScale(_textScale - 0.1),
          onIncrease: () => _setTextScale(_textScale + 0.1),
        ),
        KeypadFocusTarget(
          node: _saveFocus,
          label: 'Save settings',
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
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            focusNode: _backFocus,
            tooltip: 'Back',
            onPressed: () => Navigator.maybePop(context),
            icon: const Icon(Icons.arrow_back),
          ),
          title: Text(
            'Settings',
            style: TextStyle(
              fontSize: UIUtils.fontSize(context, 18),
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: UIUtils.cardColor,
          foregroundColor: UIUtils.textColor,
          elevation: 0,
          toolbarHeight: tiny ? 40 : null,
          actions: [
            IconButton(
              focusNode: _resetFocus,
              icon: Icon(
                Icons.refresh_rounded,
                size: UIUtils.iconSize(context, 22),
                color: UIUtils.subtextColor,
              ),
              tooltip: 'Reset to Defaults',
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
              // Text-to-Speech Settings
              _buildSettingSection(context, 'Text-to-Speech', [
                _buildSwitchTile(
                  context,
                  title: 'Enable TTS',
                  subtitle: 'Read out messages',
                  value: _ttsEnabled,
                  onChanged: (_) => _toggleTts(),
                  focusNode: _ttsFocus,
                ),
                _buildSliderTile(
                  context,
                  title: 'Volume',
                  subtitle: 'TTS volume level',
                  value: _ttsVolume,
                  min: 0.0,
                  max: 1.0,
                  divisions: 10,
                  onChanged: _setVolume,
                  labelBuilder: (val) => '${(val * 100).round()}%',
                  focusNode: _volumeFocus,
                ),
                _buildSliderTile(
                  context,
                  title: 'Speech Rate',
                  subtitle: 'How fast TTS speaks',
                  value: _ttsSpeechRate,
                  min: 0.1,
                  max: 1.0,
                  divisions: 9,
                  onChanged: _setSpeechRate,
                  labelBuilder: (val) => '${(val * 2).toStringAsFixed(1)}x',
                  focusNode: _rateFocus,
                ),
                SizedBox(height: UIUtils.spacing(context, 4)),
                ElevatedButton.icon(
                  focusNode: _testFocus,
                  onPressed: _testTTS,
                  icon: Icon(
                    Icons.volume_up,
                    size: UIUtils.iconSize(context, 18),
                  ),
                  label: Text(
                    'Test TTS',
                    style: TextStyle(fontSize: UIUtils.fontSize(context, 13)),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: UIUtils.accentColor,
                    foregroundColor: Colors.white,
                    padding: UIUtils.paddingSymmetric(
                      context,
                      horizontal: 12,
                      vertical: 8,
                    ),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ]),

              // Voice Commands
              _buildSettingSection(context, 'Voice Commands', [
                _buildSwitchTile(
                  context,
                  title: 'Voice Commands',
                  subtitle: 'Available only inside active sessions',
                  value: _voiceCommandsEnabled,
                  onChanged: (_) => _toggleVoiceCommands(),
                  focusNode: _voiceFocus,
                ),
                if (!tiny)
                  Semantics(
                    button: true,
                    label:
                        'Voice commands. Say mute, unmute, raise hand, lower hand, leave, or repeat instructions.',
                    child: InkWell(
                      focusNode: _voiceHelpFocus,
                      onTap: () => _speakIfEnabled(
                        'Voice commands are mute, unmute, raise hand, lower hand, leave, and repeat instructions.',
                      ),
                      borderRadius: BorderRadius.circular(6),
                      child: Padding(
                        padding: UIUtils.paddingAll(context, 6),
                        child: Text(
                          'Active-session commands: "mute", "unmute", "raise hand", "lower hand", "leave", "repeat"',
                          style: TextStyle(
                            fontSize: UIUtils.fontSize(context, 11),
                            color: UIUtils.subtextColor,
                          ),
                        ),
                      ),
                    ),
                  ),
              ]),

              // Keyboard Shortcuts
              _buildSettingSection(context, 'Keyboard Shortcuts', [
                _buildSwitchTile(
                  context,
                  title: 'Show Shortcuts',
                  subtitle: 'Display keyboard hints',
                  value: _showKeyboardShortcuts,
                  onChanged: (_) => _toggleKeyboardShortcuts(),
                  focusNode: _shortcutsFocus,
                ),
                if (!tiny) ...[
                  SizedBox(height: UIUtils.spacing(context, 6)),
                  Container(
                    padding: UIUtils.paddingAll(context, 8),
                    decoration: BoxDecoration(
                      color: UIUtils.backgroundColor,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: UIUtils.accentColor.withOpacity(0.35),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Keyboard Shortcuts:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: UIUtils.fontSize(context, 12),
                          ),
                        ),
                        SizedBox(height: UIUtils.spacing(context, 4)),
                        Text(
                          '• M - Mute  • H - Hand',
                          style: TextStyle(
                            fontSize: UIUtils.fontSize(context, 11),
                          ),
                        ),
                        Text(
                          '• L - Leave  • T - TTS',
                          style: TextStyle(
                            fontSize: UIUtils.fontSize(context, 11),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ]),

              // Visual Settings
              _buildSettingSection(context, 'Visual Settings', [
                _buildSwitchTile(
                  context,
                  title: 'High Contrast',
                  subtitle: 'Better visibility',
                  value: _highContrastMode,
                  onChanged: (_) => _toggleHighContrast(),
                  focusNode: _contrastFocus,
                ),
                _buildSliderTile(
                  context,
                  title: 'Text Size',
                  subtitle:
                      'App text size; system font scaling is also respected',
                  value: _textScale,
                  min: 0.9,
                  max: 1.5,
                  divisions: 6,
                  onChanged: _setTextScale,
                  labelBuilder: (val) => '${(val * 100).round()}%',
                  focusNode: _textScaleFocus,
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
                  'Save Settings',
                  style: TextStyle(
                    fontSize: UIUtils.fontSize(context, 15),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: UIUtils.primaryColor,
                  foregroundColor: Colors.white,
                  padding: UIUtils.paddingSymmetric(context, vertical: 14),
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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

    return KeypadInstructionWrapper(
      screenName: 'Reset settings confirmation',
      labels: const {1: 'Cancel', 2: 'Reset'},
      actions: {1: () => close(false), 2: () => close(true)},
      focusTargets: [
        KeypadFocusTarget(
          node: _cancelFocus,
          label: 'Cancel reset',
          onActivate: () => close(false),
        ),
        KeypadFocusTarget(
          node: _confirmFocus,
          label: 'Confirm reset settings',
          onActivate: () => close(true),
        ),
      ],
      child: AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text(
          'Are you sure you want to reset all settings to defaults?',
        ),
        actions: [
          TextButton(
            focusNode: _cancelFocus,
            onPressed: () => close(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            focusNode: _confirmFocus,
            onPressed: () => close(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
