import 'package:flutter_tts/flutter_tts.dart';

// This is not a widget/screen/UI and just a background helper service
class TtsService {
  // Creates one single(static) TTS engine shared acroos the whole app
  static final FlutterTts _tts = FlutterTts();
  // Lazy initialization - tracks whether TTS has been initialized and prevents repeated setup
  static bool _isInitialized = false;
  // Gloabl on/off button
  static bool _enabled = true;

  /// Initialize TTS with default settings
  static Future<void> init() async {
    
    // If TTS is already set up → do nothing
    if (_isInitialized){
      return;
    }
    
    // Set the default values
    await _tts.setLanguage("en-IN");
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);

    _isInitialized = true;
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
    await _tts.setSpeechRate(rate);
  }

  /// Set volume (0.0 to 1.0)
  static Future<void> setVolume(double volume) async {
    await _tts.setVolume(volume);
  }

  /// Set pitch (0.5 to 2.0)
  static Future<void> setPitch(double pitch) async {
    await _tts.setPitch(pitch);
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