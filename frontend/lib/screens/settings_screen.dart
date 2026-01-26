import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';


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
  Widget _buildSettingSection(String title, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const Divider(),
            ...children,          // spread operator : Inserts multiple widgets into column
          ],
        ),
      ),
    );
  }

  // Switch Tile : Reusable switch row
  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    // Automatically aligns text + switch
    return SwitchListTile(
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(subtitle),
      value: value,
      onChanged: (val) {
        onChanged(val);
        _speakIfEnabled("$title ${val ? 'enabled' : 'disabled'}");
      },
      activeColor: Colors.teal,
    );
  }

  // Reusable slider + label UI
  Widget _buildSliderTile({
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
          contentPadding: EdgeInsets.zero,
          title: Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          subtitle: Text(subtitle),
          trailing: Text(
            labelBuilder?.call(value) ?? value.toStringAsFixed(2),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
        ),

        // Interactive horizontal slider
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          label: labelBuilder?.call(value) ?? value.toStringAsFixed(2),      // Optional function to format display text
          onChanged: onChanged,
          activeColor: Colors.teal,
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Accessibility'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset to Defaults',
            onPressed: _resetToDefaults,
          ),
        ],
      ),
      
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Text-to-Speech Settings
            _buildSettingSection(
              'Text-to-Speech',
              [
                _buildSwitchTile(
                  title: 'Enable TTS',
                  subtitle: 'Read out messages and notifications',
                  value: _ttsEnabled,
                  onChanged: (val) => setState(() => _ttsEnabled = val),
                ),
                _buildSliderTile(
                  title: 'Volume',
                  subtitle: 'Adjust TTS volume level',
                  value: _ttsVolume,
                  min: 0.0,
                  max: 1.0,
                  divisions: 10,
                  onChanged: (val) => setState(() => _ttsVolume = val),
                  labelBuilder: (val) => '${(val * 100).round()}%',
                ),
                _buildSliderTile(
                  title: 'Speech Rate',
                  subtitle: 'Adjust how fast TTS speaks',
                  value: _ttsSpeechRate,
                  min: 0.1,
                  max: 1.0,
                  divisions: 9,
                  onChanged: (val) => setState(() => _ttsSpeechRate = val),
                  labelBuilder: (val) => '${(val * 2).toStringAsFixed(1)}x',
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: _testTTS,
                  icon: const Icon(Icons.volume_up),
                  label: const Text('Test TTS'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                ),
              ],
            ),

            // Voice Commands
            _buildSettingSection(
              'Voice Commands',
              [
                _buildSwitchTile(
                  title: 'Enable Voice Commands',
                  subtitle: 'Control app with voice (experimental)',
                  value: _voiceCommandsEnabled,
                  onChanged: (val) => setState(() => _voiceCommandsEnabled = val),
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Voice commands include: "mute", "unmute", "raise hand", "lower hand", "leave"',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ],
            ),

            // Keyboard Shortcuts
            _buildSettingSection(
              'Keyboard Shortcuts',
              [
                _buildSwitchTile(
                  title: 'Show Keyboard Shortcuts',
                  subtitle: 'Display keyboard hints in UI',
                  value: _showKeyboardShortcuts,
                  onChanged: (val) => setState(() => _showKeyboardShortcuts = val),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Keyboard Shortcuts:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text('• M - Toggle Mute'),
                      Text('• H - Raise/Lower Hand'),
                      Text('• L - Leave Session'),
                      Text('• T - Toggle TTS'),
                      Text('• Enter - Send Chat Message'),
                    ],
                  ),
                ),
              ],
            ),

            // Visual Settings
            _buildSettingSection(
              'Visual Settings',
              [
                _buildSwitchTile(
                  title: 'High Contrast Mode',
                  subtitle: 'Increase contrast for better visibility',
                  value: _highContrastMode,
                  onChanged: (val) => setState(() => _highContrastMode = val),
                ),
              ],
            ),

            // Audio Sync Settings
            _buildSettingSection(
              'Advanced Audio',
              [
                _buildSliderTile(
                  title: 'Playback Sync Tolerance',
                  subtitle: 'Audio synchronization precision',
                  value: _audioSyncTolerance,
                  min: 0.1,
                  max: 2.0,
                  divisions: 19,
                  onChanged: (val) => setState(() => _audioSyncTolerance = val),
                  labelBuilder: (val) => '${val.toStringAsFixed(1)}s',
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Lower values provide tighter sync but may cause stuttering on slow connections',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Save Button
            ElevatedButton.icon(
              onPressed: _saveSettings,
              icon: const Icon(Icons.save, size: 28),
              label: const Text(
                'Save Settings',
                style: TextStyle(fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(vertical: 16),
                minimumSize: const Size(double.infinity, 60),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}