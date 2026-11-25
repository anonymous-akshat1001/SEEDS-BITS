import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../announcers/dashboard_text.dart';
import '../l10n/speech.dart';
import '../services/auth_session_service.dart';
import '../services/class_alerts.dart';
import '../services/class_entry.dart';
import '../services/learning_autopilot.dart';
import '../services/message_center.dart';
import '../services/tts_service.dart';
import '../widgets/journey_menu.dart';
import 'audio_library_screen.dart';
import 'home_more_menu.dart';
import 'home_updates.dart';
import 'journeys/student_journeys_screen.dart';
import 'playlist_screens.dart';
import 'quiz_screens.dart';

/// Student home: one action for what matters now (join the live class),
/// then learning. Nothing to refresh, search or type: the class appears by
/// itself when the teacher starts it.
class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard>
    with WidgetsBindingObserver, HomeUpdates {
  /// The class the student asked to enter when it starts (S17): only that
  /// occurrence, and only while this screen stays open.
  String? _autoJoinFor;
  bool _spokeArrival = false;

  Map<String, dynamic>? get _live => home?['live_class'] is Map
      ? Map<String, dynamic>.from(home!['live_class'] as Map)
      : null;

  Map<String, dynamic>? get _next => home?['next_class'] is Map
      ? Map<String, dynamic>.from(home!['next_class'] as Map)
      : null;

  String? _occurrenceKey(Map<String, dynamic>? next) =>
      next == null ? null : '${next['entry_id']}:${next['occurrence_date']}';

  @override
  void initState() {
    super.initState();
    startHomeUpdates();
    unawaited(LearningAutopilot.syncQuietly());
    unawaited(LearningAutopilot.prepareOffline());
  }

  @override
  void dispose() {
    stopHomeUpdates();
    super.dispose();
  }

  @override
  void homeChanged(Map<String, dynamic>? previous, {required bool first}) {
    if (first) {
      unawaited(_arrive());
      return;
    }
    // Something the teacher or administrator changed while Home is open.
    if (onScreen && _spokeArrival) {
      final notices = takeNotices();
      if (notices != null && notices.isNotEmpty) {
        unawaited(TtsService.speak(notices));
      }
    }
    final live = _live;
    final previousLive = previous?['live_class'];
    final previousId = previousLive is Map ? previousLive['session_id'] : null;
    if (live == null || live['session_id'] == previousId) return;
    if (_autoJoinFor != null && onScreen) {
      _autoJoinFor = null;
      unawaited(
        ClassEntry.open(
          live['session_id'] as int,
          liveClass: live,
          arrival: Speech.t.homeAutoJoined(_subject(live)),
        ),
      );
      return;
    }
    if (onScreen) announceClassStarted(_subject(live));
  }

  /// First arrival: return to an interrupted class (S18); otherwise say in
  /// one sentence what to do now.
  Future<void> _arrive() async {
    final live = _live;
    final interrupted = await ClassEntry.interrupted();
    if (!mounted) return;
    if (live != null && interrupted == live['session_id']) {
      await ClassEntry.open(
        interrupted!,
        liveClass: live,
        arrival: Speech.t.homeReturningToClass,
      );
      return;
    }
    if (interrupted != null) await ClassEntry.forget();
    if (_spokeArrival || !onScreen) return;
    _spokeArrival = true;
    final carried = MessageCenter.takeArrivalMessage();
    unawaited(
      TtsService.speak(
        [
          ?carried,
          Speech.t.homeTitle,
          _brief(),
          ?takeNotices(),
          JourneyMenu.spokenKeys(_choices, DashboardText.logout),
        ].join(' '),
      ),
    );
  }

  String _subject(Map<String, dynamic> item) =>
      '${item['subject_name'] ?? Speech.t.sessionDefaultTitle}';

  String _now() {
    final t = Speech.t;
    final live = _live;
    final next = _next;
    if (live != null) return t.homeBriefLive(_subject(live));
    if (next != null) {
      return t.homeBriefNext(_subject(next), '${next['start_clock']}');
    }
    return t.homeBriefNoClass;
  }

  String _brief() => [?homeIssue, _now()].join(' ');

  void _primary() {
    final live = _live;
    if (live != null) {
      unawaited(ClassEntry.open(live['session_id'] as int, liveClass: live));
      return;
    }
    final next = _next;
    if (next == null) {
      unawaited(TtsService.speak(Speech.t.homeNoClassReason));
      return;
    }
    final key = _occurrenceKey(next);
    setState(() => _autoJoinFor = _autoJoinFor == key ? null : key);
    unawaited(
      TtsService.speak(
        _autoJoinFor == null
            ? Speech.t.homeAutoJoinCancelled
            : Speech.t.homeAutoJoinArmed(_subject(next)),
      ),
    );
  }

  String _primaryLabel() {
    final t = Speech.t;
    final live = _live;
    if (live != null) return t.homeJoinClass(_subject(live));
    final next = _next;
    if (next == null) return t.homeNoClassNow;
    return _autoJoinFor == _occurrenceKey(next)
        ? t.homeCancelAutoJoin
        : t.homeJoinWhenStarts(_subject(next), '${next['start_clock']}');
  }

  /// Opening anything else ends automatic joining (S17), with a reason.
  void _leaveWaiting() {
    if (_autoJoinFor == null) return;
    _autoJoinFor = null;
    MessageCenter.show(Speech.t.homeAutoJoinLeft);
  }

  void _push(Widget screen) {
    _leaveWaiting();
    unawaited(
      Navigator.of(
        context,
      ).push<void>(MaterialPageRoute(builder: (_) => screen)),
    );
  }

  void _more() => _push(
    HomeMoreMenu(
      choices: [
        JourneyChoice(
          DashboardText.library,
          () => unawaited(
            Navigator.of(context).push<void>(
              MaterialPageRoute(
                builder: (_) => const OfflineAudioLibraryScreen(),
              ),
            ),
          ),
        ),
        JourneyChoice(
          DashboardText.playlists,
          () => unawaited(
            Navigator.of(context).push<void>(
              MaterialPageRoute(builder: (_) => const StudentPlaylistsScreen()),
            ),
          ),
        ),
        JourneyChoice(
          Speech.t.keySettings,
          () => unawaited(Navigator.of(context).pushNamed('/settings')),
        ),
      ],
    ),
  );

  String _details() {
    final className = home?['class_name'];
    return [
      if (className != null) Speech.t.homeYourClass('$className'),
      _brief(),
    ].join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final t = Speech.t;
    return JourneyMenu(
      title: Speech.t.homeTitle,
      autoPlay: false,
      brief: homeLoaded ? _brief() : t.homeChecking,
      status: homeLoaded ? _now() : t.homeChecking,
      issue: homeIssue,
      details: _details(),
      backLabel: DashboardText.logout,
      onBack: () => unawaited(AuthSessionService.logoutFrom(context)),
      // Back keeps the student signed in; it only leaves the app.
      onSystemBack: () => unawaited(SystemNavigator.pop()),
      choices: _choices,
    );
  }

  List<JourneyChoice> get _choices {
    final t = Speech.t;
    return [
      JourneyChoice(_primaryLabel(), _primary),
      JourneyChoice(t.homeContinueLearning, () {
        _leaveWaiting();
        unawaited(LearningAutopilot.continueLearning(context));
      }),
      JourneyChoice(t.homeJourneys, () => _push(const StudentJourneysScreen())),
      JourneyChoice(t.homeQuizzes, () => _push(const StudentQuizScreen())),
      JourneyChoice(t.homeMore, _more),
    ];
  }
}
