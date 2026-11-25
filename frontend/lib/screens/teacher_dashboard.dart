import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../announcers/dashboard_text.dart';
import '../l10n/speech.dart';
import '../services/api_service.dart';
import '../services/auth_session_service.dart';
import '../services/class_entry.dart';
import '../services/message_center.dart';
import '../services/tts_service.dart';
import '../widgets/journey_menu.dart';
import '../widgets/journey_prompts.dart';
import 'audio_library_screen.dart';
import 'home_more_menu.dart';
import 'home_updates.dart';
import 'journeys/teacher_journeys_screen.dart';
import 'playlist_screens.dart';
import 'quiz_screens.dart';

/// Teacher home: the class from the timetable is one key away (start it, or
/// return to it), with no title to type, no students to invite and no
/// session list to manage. Lesson tools use that class automatically.
class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard>
    with WidgetsBindingObserver, HomeUpdates {
  bool _starting = false;
  bool _spokeArrival = false;

  /// Class and subject chosen for lesson tools; otherwise the current class.
  Map<String, dynamic>? _chosenWorkspace;

  Map<String, dynamic>? get _live => home?['live_class'] is Map
      ? Map<String, dynamic>.from(home!['live_class'] as Map)
      : null;

  List<Map<String, dynamic>> get _today => [
    for (final item in (home?['today'] as List?) ?? const [])
      Map<String, dynamic>.from(item as Map),
  ];

  List<Map<String, dynamic>> get _workspaces => [
    for (final item in (home?['workspaces'] as List?) ?? const [])
      Map<String, dynamic>.from(item as Map),
  ];

  /// The class to act on now: startable first, else the next one.
  Map<String, dynamic>? get _current =>
      _today.where((item) => item['can_start'] == true).firstOrNull ??
      _today.firstOrNull;

  Map<String, dynamic>? get _workspace {
    final chosen = _chosenWorkspace;
    if (chosen != null) return chosen;
    final source = _live ?? _current;
    if (source != null) {
      return _workspaces
              .where(
                (item) =>
                    item['class_id'] == source['class_id'] &&
                    item['subject_id'] == source['subject_id'],
              )
              .firstOrNull ??
          {
            'class_id': source['class_id'],
            'class_name': source['class_name'],
            'subject_id': source['subject_id'],
            'subject_name': source['subject_name'],
          };
    }
    return _workspaces.firstOrNull;
  }

  @override
  void initState() {
    super.initState();
    startHomeUpdates();
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
    // Something the administrator did while Home is open.
    if (onScreen && _spokeArrival) {
      final notices = takeNotices();
      if (notices != null) unawaited(TtsService.speak(notices));
    }
  }

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

  String _place(Map<String, dynamic> item) => Speech.t.homeSubjectInClass(
    '${item['subject_name']}',
    '${item['class_name']}',
  );

  String _now() {
    final t = Speech.t;
    final live = _live;
    if (live != null) return t.teacherHomeBriefLive('${live['subject_name']}');
    final current = _current;
    if (current == null) return t.teacherHomeBriefNoClass;
    if (current['can_start'] == true) {
      return t.teacherHomeBriefReady(_place(current));
    }
    return t.teacherHomeBriefNext(_place(current), '${current['start_clock']}');
  }

  String _brief() => [?homeIssue, _now()].join(' ');

  String _primaryLabel() {
    final t = Speech.t;
    final live = _live;
    if (live != null) return t.teacherHomeReturn('${live['subject_name']}');
    final current = _current;
    if (current == null) return t.homeNoClassNow;
    if (current['can_start'] == true) {
      return t.teacherHomeStart(_place(current));
    }
    return t.teacherHomeNext(_place(current), '${current['start_clock']}');
  }

  Future<void> _primary() async {
    final live = _live;
    if (live != null) {
      await ClassEntry.open(live['session_id'] as int, liveClass: live);
      return;
    }
    final current = _current;
    if (current == null) {
      unawaited(TtsService.speak(Speech.t.teacherHomeNoClassReason));
      return;
    }
    if (current['can_start'] != true) {
      final opens = DateTime.tryParse('${current['opens_at']}')?.toLocal();
      final clock = opens == null
          ? '${current['start_clock']}'
          : '${opens.hour.toString().padLeft(2, '0')}:'
                '${opens.minute.toString().padLeft(2, '0')}';
      unawaited(TtsService.speak(Speech.t.teacherHomeOpensAt(clock)));
      return;
    }
    await _start(
      entryId: current['entry_id'] as int,
      occurrenceDate: '${current['occurrence_date']}',
    );
  }

  /// One press starts the class and opens it; students are alerted by the
  /// server. Repeated presses return to the same class.
  Future<void> _start({
    int? entryId,
    String? occurrenceDate,
    int? classId,
    int? subjectId,
  }) async {
    if (_starting) return;
    setState(() => _starting = true);
    unawaited(TtsService.speak(Speech.t.teacherHomeStarting));
    try {
      final result = await ApiService.startClass(
        entryId: entryId,
        occurrenceDate: occurrenceDate,
        classId: classId,
        subjectId: subjectId,
      );
      if (!mounted) return;
      if (!result.isSuccess) {
        MessageCenter.error(result.failure!.message);
        unawaited(checkHome());
        return;
      }
      final live = Map<String, dynamic>.from(result.data!['live_class'] as Map);
      await ClassEntry.open(
        live['session_id'] as int,
        liveClass: live,
        arrival: Speech.t.teacherHomeStarted('${live['subject_name']}'),
      );
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  Future<Map<String, dynamic>?> _pickWorkspace(String title) async {
    final options = _workspaces;
    if (options.isEmpty) {
      MessageCenter.error(DashboardText.noAssignment);
      return null;
    }
    if (options.length == 1) return options.single;
    return JourneyPrompts.choose<Map<String, dynamic>>(
      context,
      title: title,
      items: options,
      labelOf: _place,
    );
  }

  Future<void> _startUnscheduled() async {
    final workspace = await _pickWorkspace(
      Speech.t.teacherHomeUnscheduledTitle,
    );
    if (workspace == null || !mounted) return;
    await _start(
      classId: workspace['class_id'] as int,
      subjectId: workspace['subject_id'] as int,
    );
  }

  Future<void> _changeWorkspace() async {
    final workspace = await _pickWorkspace(
      Speech.t.teacherHomeChooseWorkspaceTitle,
    );
    if (workspace == null || !mounted) return;
    setState(() => _chosenWorkspace = workspace);
    MessageCenter.show(Speech.t.teacherHomeContentFor(_place(workspace)));
  }

  /// Lesson tools for the current class and subject.
  void _withWorkspace(Widget Function(Map<String, dynamic>) build) {
    final workspace = _workspace;
    if (workspace == null) {
      MessageCenter.error(DashboardText.noAssignment);
      return;
    }
    unawaited(
      Navigator.of(
        context,
      ).push<void>(MaterialPageRoute(builder: (_) => build(workspace))),
    );
  }

  void _quizzes() => _withWorkspace(
    (workspace) => TeacherQuizScreen(
      classId: workspace['class_id'] as int,
      className: '${workspace['class_name']}',
      subjectId: workspace['subject_id'] as int,
      subjectName: '${workspace['subject_name']}',
    ),
  );

  void _journeys() => _withWorkspace(
    (workspace) => TeacherJourneysScreen(
      classId: workspace['class_id'] as int,
      subjectId: workspace['subject_id'] as int,
      workspaceName: _place(workspace),
    ),
  );

  void _playlists() => _withWorkspace(
    (workspace) => TeacherPlaylistsScreen(
      classId: workspace['class_id'] as int,
      className: '${workspace['class_name']}',
      subjectId: workspace['subject_id'] as int,
      subjectName: '${workspace['subject_name']}',
    ),
  );

  void _more() {
    final t = Speech.t;
    unawaited(
      Navigator.of(context).push<void>(
        MaterialPageRoute(
          builder: (_) => HomeMoreMenu(
            choices: [
              JourneyChoice(
                DashboardText.offlineLibrary,
                () => _withWorkspace(
                  (workspace) => OfflineAudioLibraryScreen(
                    classId: workspace['class_id'] as int?,
                    subjectId: workspace['subject_id'] as int?,
                  ),
                ),
              ),
              JourneyChoice(
                t.teacherHomeChangeWorkspace,
                () => unawaited(_changeWorkspace()),
                enabled: _workspaces.length > 1,
                unavailableReason: t.teacherHomeOneWorkspace,
              ),
              JourneyChoice(
                t.teacherHomeUnscheduled,
                () => unawaited(_startUnscheduled()),
                enabled: _live == null,
                unavailableReason: t.teacherHomeAlreadyLive,
              ),
              JourneyChoice(
                t.keySettings,
                () => unawaited(Navigator.of(context).pushNamed('/settings')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _details() {
    final t = Speech.t;
    final workspace = _workspace;
    final later = _today
        .skip(1)
        .map(
          (item) =>
              t.teacherHomeLaterItem(_place(item), '${item['start_clock']}'),
        );
    return [
      _brief(),
      if (workspace != null) t.teacherHomeContentFor(_place(workspace)),
      ...later,
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
      busy: _starting,
      details: _details(),
      backLabel: DashboardText.logout,
      onBack: () => unawaited(AuthSessionService.logoutFrom(context)),
      onSystemBack: () => unawaited(SystemNavigator.pop()),
      choices: _choices,
    );
  }

  List<JourneyChoice> get _choices {
    final t = Speech.t;
    return [
      JourneyChoice(_primaryLabel(), () => unawaited(_primary())),
      JourneyChoice(t.homeQuizzes, _quizzes),
      JourneyChoice(t.homeJourneys, _journeys),
      JourneyChoice(DashboardText.classPlaylists, _playlists),
      JourneyChoice(t.homeMore, _more),
    ];
  }
}
