import '../services/tts_service.dart';
import '../utils/spoken_format.dart';

/// Shared base for spoken text. Every screen area keeps its sentences in one
/// `*_text.dart` file in this folder, so wording stays consistent, can offer
/// brief and detailed styles, and can be translated later.
abstract final class Announce {
  /// Brief wording when speech is set to Essential, detailed otherwise.
  static String pick({required String brief, required String detailed}) =>
      TtsService.verbosity == SpeechVerbosity.essential ? brief : detailed;
}

/// Phrases used by more than one area.
abstract final class CommonText {
  static const pleaseWait = 'Please wait. Still working.';
  static const signInFirst = 'Please sign in first.';
  static const accountChanged =
      'Your account changed on this phone. Sign in again.';
  static const noWorkspace =
      'No class and subject is chosen. Press 7 to choose a workspace.';
  static const noConnection =
      'No connection to the school server. Check your internet and try again.';
  static const notAvailable = 'This is not available right now.';
  static const nothingChanged = 'Nothing was changed.';
  static const noMessages = 'There are no messages on this screen.';
  static const endOfList = 'End of list. Back to the first item. ';
  static const topOfList = 'Top of list. Moved to the last item. ';

  static String opening(String what, {bool needsInternet = false}) =>
      Announce.pick(
        brief: 'Opening $what.',
        detailed:
            'Opening $what.${needsInternet ? ' Internet is required.' : ''}',
      );

  static String unavailable(String what, [String? reason]) =>
      '$what is not available.${reason == null ? '' : ' $reason'}';

  static String session(int id) => SpokenFormat.session(id);

  /// Star "where am I": screen, focused item, state, last message.
  static String whereAmI({
    required String screen,
    String? focused,
    String? state,
    String? message,
  }) => [
    '$screen.',
    if (focused != null && focused.isNotEmpty) 'Focused: $focused.',
    if (state != null && state.isNotEmpty) state,
    ?message,
  ].join(' ');
}
