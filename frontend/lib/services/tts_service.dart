import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

// This is not a widget/screen/UI and just a background helper service
class TtsService {
  // Creates one single(static) TTS engine shared acroos the whole app
  static final FlutterTts _tts = FlutterTts();
  // Lazy initialization - tracks whether TTS has been initialized and prevents repeated setup
  static bool _isInitialized = false;
  // Gloabl on/off button
  static bool _enabled = true;
  static double _speechRate = 0.5;
  static double _volume = 1.0;
  static double _pitch = 1.0;

  /// Initialize TTS with default settings
  static Future<void> init() async {
    
    // If TTS is already set up → do nothing
    if (_isInitialized){
      return;
    }
    
    await _tts.setLanguage("en-IN");
    await _applyVoiceSettings();

    _isInitialized = true;
  }

  /// Load persisted TTS preferences once at app startup.
  static Future<void> loadFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _enabled = prefs.getBool('tts_enabled') ?? true;
    _volume = prefs.getDouble('tts_volume') ?? 1.0;
    _speechRate = prefs.getDouble('tts_speech_rate') ?? 0.5;
    await init();
    await _applyVoiceSettings();
  }

  static Future<void> configure({
    bool? enabled,
    double? speechRate,
    double? volume,
    double? pitch,
  }) async {
    if (enabled != null) _enabled = enabled;
    if (speechRate != null) _speechRate = speechRate.clamp(0.1, 1.0).toDouble();
    if (volume != null) _volume = volume.clamp(0.0, 1.0).toDouble();
    if (pitch != null) _pitch = pitch.clamp(0.5, 2.0).toDouble();

    await init();
    await _applyVoiceSettings();
  }

  static Future<void> _applyVoiceSettings() async {
    await _tts.setSpeechRate(_speechRate);
    await _tts.setVolume(_volume);
    await _tts.setPitch(_pitch);
  }

  /// Speak text if TTS is enabled
  static Future<void> speak(String text) async {

    // If TTS disabled → silent return
    if (!_enabled){
      return;
    }

    // Ensures TTS is initialized only when needed, first call initializes it
    await init();
    // converts text to speech, also async hence UI does not freeze
    await _tts.speak(text);
  }

  /// Stop current speech
  static Future<void> stop() async {
    await _tts.stop();
  }

  /// Enable or disable TTS
  static void setEnabled(bool enabled) {
    // Stores preference in memory, synced with settings screen
    _enabled = enabled;
  }

  /// Check if TTS is enabled(a getter)
  static bool get isEnabled => _enabled;

  /// Set speech rate (0.0 to 1.0)
  static Future<void> setSpeechRate(double rate) async {
    await configure(speechRate: rate);
  }

  /// Set volume (0.0 to 1.0)
  static Future<void> setVolume(double volume) async {
    await configure(volume: volume);
  }

  /// Set pitch (0.5 to 2.0)
  static Future<void> setPitch(double pitch) async {
    await configure(pitch: pitch);
  }

  /// Get available languages
  static Future<List<dynamic>> getLanguages() async {
    await init();
    return await _tts.getLanguages;
  }

  /// Set language
  static Future<void> setLanguage(String language) async {
    await _tts.setLanguage(language);
  }
}
