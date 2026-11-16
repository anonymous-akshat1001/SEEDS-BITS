import 'package:flutter/widgets.dart';

import 'app_localizations.dart';

export 'app_localizations.dart' show AppLocalizations;

/// Languages SEEDS can speak in. [code] must match an `app_<code>.arb` file
/// and [voiceLocale] the text-to-speech voice used for it.
enum SpeechLanguage {
  english('en', 'en-IN', 'English'),
  hindi('hi', 'hi-IN', 'हिन्दी, Hindi'),
  kannada('kn', 'kn-IN', 'ಕನ್ನಡ, Kannada'),
  telugu('te', 'te-IN', 'తెలుగు, Telugu'),
  bengali('bn', 'bn-IN', 'বাংলা, Bengali');

  const SpeechLanguage(this.code, this.voiceLocale, this.displayName);

  final String code;
  final String voiceLocale;

  /// Spoken and shown in the language picker, in its own script first.
  final String displayName;

  static SpeechLanguage fromCode(String? code) => values.firstWhere(
    (language) => language.code == code,
    orElse: () => english,
  );
}

/// Spoken text for the current speech language: `Speech.t.someMessage`.
///
/// Every sentence that SEEDS speaks lives in `lib/l10n/app_<code>.arb`.
/// Messages missing from a translation fall back to English.
abstract final class Speech {
  /// The language spoken now. Set by TtsService once the matching voice is
  /// chosen; screens never set it directly.
  static SpeechLanguage language = SpeechLanguage.english;
  static final Map<SpeechLanguage, AppLocalizations> _cache = {};

  static AppLocalizations get t => _cache.putIfAbsent(
    language,
    () => lookupAppLocalizations(Locale(language.code)),
  );
}
