import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/ui_utils.dart';


// Settings Screen Widget
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  // Link widget to logic
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

// Define the Settings State Class
class _SettingsScreenState extends State<SettingsScreen> {
  // Creates an instance of the TTS engine
  final FlutterTts _tts = FlutterTts();
  
  // Default values of the settings/shortcuts
  bool _ttsEnabled = true;
  bool _voiceCommandsEnabled = false;
  bool _showKeyboardShortcuts = true;
  bool _highContrastMode = false;
  double _ttsVolume = 1.0;
  double _ttsSpeechRate = 0.5;
  double _audioSyncTolerance = 0.5;

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
    
    // set the initial values and store in local storage
    setState(() {
      _ttsEnabled = prefs.getBool('tts_enabled') ?? true;
      _voiceCommandsEnabled = prefs.getBool('voice_commands_enabled') ?? false;
      _showKeyboardShortcuts = prefs.getBool('show_keyboard_shortcuts') ?? true;
      _highContrastMode = prefs.getBool('high_contrast_mode') ?? false;
      _ttsVolume = prefs.getDouble('tts_volume') ?? 1.0;
      _ttsSpeechRate = prefs.getDouble('tts_speech_rate') ?? 0.5;
      _audioSyncTolerance = prefs.getDouble('audio_sync_tolerance') ?? 0.5;
    });

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
    await prefs.setDouble('audio_sync_tolerance', _audioSyncTolerance);

    // apply changes to TTS
    await _configureTTS();
    await _speakIfEnabled("Settings saved");
    
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
      await _tts.setVolume(_ttsVolume);
      await _tts.setSpeechRate(_ttsSpeechRate);
      await _tts.setPitch(1.0);
    } catch (e) {
      print('[TTS CONFIG] Error: $e');
    }
  }

  // Helper function to centralize TTS logic
  Future<void> _speakIfEnabled(String text) async {
    // Give audio feedback only if TTS is enabled
    if (_ttsEnabled) {
      try {
        await _tts.speak(text);
      } catch (e) {
        print('[TTS] Error: $e');
      }
    }
  }

  // Function to test the TTS setting applied
  Future<void> _testTTS() async {
    await _configureTTS();
    await _tts.speak("This is a test of the text to speech system. Volume is ${(_ttsVolume * 100).round()} percent. Speech rate is ${(_ttsSpeechRate * 2).toStringAsFixed(1)}.");
  }

  // Function to restore the original values
  Future<void> _resetToDefaults() async {
    // ask user to give confirmation for the decision by showing a dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text('Are you sure you want to reset all settings to defaults?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reset'),
          ),
        ],
      ),
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
        _audioSyncTolerance = 0.5;
      });

      await _saveSettings();
    }
  }

// UI HELPERS (REUSABLE WIDGET BUILDERS)

  // Section Card
  Widget _buildSettingSection(BuildContext context, String title, List<Widget> children) {
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
  Widget _buildSwitchTile(BuildContext context, {
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      dense: UIUtils.isTiny(context),
      title: Text(
        title,
        style: TextStyle(fontSize: UIUtils.fontSize(context, 14), fontWeight: FontWeight.w500),
      ),
      subtitle: Text(subtitle, style: TextStyle(fontSize: UIUtils.fontSize(context, 11))),
      value: value,
      onChanged: (val) {
        onChanged(val);
        _speakIfEnabled("$title ${val ? 'enabled' : 'disabled'}");
      },
      activeColor: UIUtils.accentColor,
    );
  }

  // Reusable slider + label UI
  Widget _buildSliderTile(BuildContext context, {
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
    String Function(double)? labelBuilder,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          dense: UIUtils.isTiny(context),
          contentPadding: EdgeInsets.zero,
          title: Text(
            title,
            style: TextStyle(fontSize: UIUtils.fontSize(context, 14), fontWeight: FontWeight.w500),
          ),
          subtitle: Text(subtitle, style: TextStyle(fontSize: UIUtils.fontSize(context, 11))),
          trailing: Text(
            labelBuilder?.call(value) ?? value.toStringAsFixed(2),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: UIUtils.accentColor,
            ),
          ),
        ),

        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          label: labelBuilder?.call(value) ?? value.toStringAsFixed(2),
          onChanged: onChanged,
          activeColor: UIUtils.accentColor,
        ),
      ],
    );
  }

  // saves memory since it is called when screen is destroyed
  @override
  void dispose() {
    // Stops any ongoing speech
    _tts.stop();
    super.dispose();
  }

  // Build UI Widgets
  @override
  Widget build(BuildContext context) {
    final bool tiny = UIUtils.isTiny(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: TextStyle(fontSize: UIUtils.fontSize(context, 18), fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        foregroundColor: UIUtils.textColor,
        elevation: 0,
        toolbarHeight: tiny ? 40 : null,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, size: UIUtils.iconSize(context, 22), color: UIUtils.subtextColor),
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
            _buildSettingSection(
              context,
              'Text-to-Speech',
              [
                _buildSwitchTile(context,
                  title: 'Enable TTS',
                  subtitle: 'Read out messages',
                  value: _ttsEnabled,
                  onChanged: (val) => setState(() => _ttsEnabled = val),
                ),
                _buildSliderTile(context,
                  title: 'Volume',
                  subtitle: 'TTS volume level',
                  value: _ttsVolume,
                  min: 0.0,
                  max: 1.0,
                  divisions: 10,
                  onChanged: (val) => setState(() => _ttsVolume = val),
                  labelBuilder: (val) => '${(val * 100).round()}%',
                ),
                _buildSliderTile(context,
                  title: 'Speech Rate',
                  subtitle: 'How fast TTS speaks',
                  value: _ttsSpeechRate,
                  min: 0.1,
                  max: 1.0,
                  divisions: 9,
                  onChanged: (val) => setState(() => _ttsSpeechRate = val),
                  labelBuilder: (val) => '${(val * 2).toStringAsFixed(1)}x',
                ),
                SizedBox(height: UIUtils.spacing(context, 4)),
                ElevatedButton.icon(
                  onPressed: _testTTS,
                  icon: Icon(Icons.volume_up, size: UIUtils.iconSize(context, 18)),
                  label: Text('Test TTS', style: TextStyle(fontSize: UIUtils.fontSize(context, 13))),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: UIUtils.accentColor,
                    foregroundColor: Colors.white,
                    padding: UIUtils.paddingSymmetric(context, horizontal: 12, vertical: 8),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),

            // Voice Commands
            _buildSettingSection(
              context,
              'Voice Commands',
              [
                _buildSwitchTile(context,
                  title: 'Voice Commands',
                  subtitle: 'Control app with voice',
                  value: _voiceCommandsEnabled,
                  onChanged: (val) => setState(() => _voiceCommandsEnabled = val),
                ),
                if (!tiny)
                  Padding(
                    padding: UIUtils.paddingAll(context, 6),
                    child: Text(
                      'Commands: "mute", "unmute", "raise hand", "leave"',
                      style: TextStyle(fontSize: UIUtils.fontSize(context, 11), color: Colors.grey),
                    ),
                  ),
              ],
            ),

            // Keyboard Shortcuts
            _buildSettingSection(
              context,
              'Keyboard Shortcuts',
              [
                _buildSwitchTile(context,
                  title: 'Show Shortcuts',
                  subtitle: 'Display keyboard hints',
                  value: _showKeyboardShortcuts,
                  onChanged: (val) => setState(() => _showKeyboardShortcuts = val),
                ),
                if (!tiny) ...[
                  SizedBox(height: UIUtils.spacing(context, 6)),
                  Container(
                    padding: UIUtils.paddingAll(context, 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Keyboard Shortcuts:',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: UIUtils.fontSize(context, 12))),
                        SizedBox(height: UIUtils.spacing(context, 4)),
                        Text('• M - Mute  • H - Hand', style: TextStyle(fontSize: UIUtils.fontSize(context, 11))),
                        Text('• L - Leave  • T - TTS', style: TextStyle(fontSize: UIUtils.fontSize(context, 11))),
                      ],
                    ),
                  ),
                ],
              ],
            ),

            // Visual Settings
            _buildSettingSection(
              context,
              'Visual Settings',
              [
                _buildSwitchTile(context,
                  title: 'High Contrast',
                  subtitle: 'Better visibility',
                  value: _highContrastMode,
                  onChanged: (val) => setState(() => _highContrastMode = val),
                ),
              ],
            ),

            // Audio Sync Settings
            _buildSettingSection(
              context,
              'Advanced Audio',
              [
                _buildSliderTile(context,
                  title: 'Sync Tolerance',
                  subtitle: 'Audio sync precision',
                  value: _audioSyncTolerance,
                  min: 0.1,
                  max: 2.0,
                  divisions: 19,
                  onChanged: (val) => setState(() => _audioSyncTolerance = val),
                  labelBuilder: (val) => '${val.toStringAsFixed(1)}s',
                ),
              ],
            ),

            SizedBox(height: UIUtils.spacing(context, 12)),

            // Save Button
            ElevatedButton.icon(
              onPressed: _saveSettings,
              icon: Icon(Icons.save_rounded, size: UIUtils.iconSize(context, 22)),
              label: Text(
                'Save Settings',
                style: TextStyle(fontSize: UIUtils.fontSize(context, 15), fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: UIUtils.primaryColor,
                foregroundColor: Colors.white,
                padding: UIUtils.paddingSymmetric(context, vertical: 14),
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),

            SizedBox(height: UIUtils.spacing(context, 10)),
          ],
        ),
      ),
    );
  }
}