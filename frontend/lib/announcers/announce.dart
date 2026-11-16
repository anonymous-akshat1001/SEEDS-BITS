import '../l10n/speech.dart';
import '../services/tts_service.dart';
import '../utils/spoken_format.dart';

/// Shared base for spoken text. Every screen area keeps its sentences in one
/// `*_text.dart` file in this folder, and the wording itself lives in
/// `lib/l10n/app_<language>.arb` so it can be translated.
abstract final class Announce {
  /// Brief wording when speech is set to Essential, detailed otherwise.
  static String pick({required String brief, required String detailed}) =>
      TtsService.verbosity == SpeechVerbosity.essential ? brief : detailed;
}

/// Phrases used by more than one area.
abstract final class CommonText {
  static AppLocalizations get _t => Speech.t;

  static String get pleaseWait => _t.commonPleaseWait;
  static String get signInFirst => _t.commonSignInFirst;
  static String get accountChanged => _t.commonAccountChanged;
  static String get noWorkspace => _t.commonNoWorkspace;
  static String get noConnection => _t.commonNoConnection;
  static String get notAvailable => _t.commonNotAvailable;
  static String get nothingChanged => _t.commonNothingChanged;
  static String get noMessages => _t.commonNoMessages;
  static String get endOfList => '${_t.commonEndOfList} ';
  static String get topOfList => '${_t.commonTopOfList} ';

  static String opening(String what, {bool needsInternet = false}) =>
      Announce.pick(
        brief: _t.commonOpening(what),
        detailed: needsInternet
            ? _t.commonOpeningNeedsInternet(what)
            : _t.commonOpening(what),
      );

  static String unavailable(String what, [String? reason]) => reason == null
      ? _t.commonUnavailable(what)
      : _t.commonUnavailableBecause(what, reason);

  static String session(int id) => SpokenFormat.session(id);

  /// Star "where am I": screen, focused item, state, last message.
  static String whereAmI({
    required String screen,
    String? focused,
    String? state,
    String? message,
  }) => [
    _t.commonWhereScreen(screen),
    if (focused != null && focused.isNotEmpty) _t.commonWhereFocused(focused),
    if (state != null && state.isNotEmpty) state,
    ?message,
  ].join(' ');
}
