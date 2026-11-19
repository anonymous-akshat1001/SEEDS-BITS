import 'dart:async';

import 'package:flutter/material.dart';

import '../../announcers/session_text.dart';
import '../../services/tts_service.dart';
import '../../widgets/journey_menu.dart';
import '../../widgets/journey_prompts.dart';
import 'live_session.dart';

/// Key 9 in class: the less used actions, kept off the main class screen
/// so it only shows what is needed every minute. The class keeps running
/// underneath. [choices] is rebuilt whenever the class changes.
class SessionMoreScreen extends StatelessWidget {
  const SessionMoreScreen({
    super.key,
    required this.session,
    required this.choices,
  });

  final LiveSession session;
  final List<JourneyChoice> Function() choices;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: session.changes,
    builder: (context, _) => JourneyMenu(
      title: SessionText.moreTitle,
      details: session.classStatus(),
      backLabel: SessionText.backToClass,
      choices: choices(),
    ),
  );
}

/// Key 4 for teachers (S44): who is here, who joined and left, and who has
/// not joined, read as counts first and names on request; one key rings
/// everyone not yet joined (S45). Raised hands are here too.
class ClassRosterScreen extends StatefulWidget {
  const ClassRosterScreen({super.key, required this.session});

  final LiveSession session;

  @override
  State<ClassRosterScreen> createState() => _ClassRosterScreenState();
}

class _ClassRosterScreenState extends State<ClassRosterScreen> {
  Map<String, dynamic>? _roster;
  bool _busy = true;

  LiveSession get _session => widget.session;

  @override
  void initState() {
    super.initState();
    unawaited(_load(announce: true));
  }

  List<Map<String, dynamic>> _group(String key) => [
    for (final item in (_roster?[key] as List?) ?? const [])
      Map<String, dynamic>.from(item as Map),
  ];

  String _counts() {
    final counts = SessionText.rosterCounts(
      _group('connected').length,
      _group('left').length,
      _group('not_joined').length,
    );
    final activity = _roster?['activity'];
    if (activity is! Map) return counts;
    return '$counts ${SessionText.activityProgress('${activity['title']}', activity['started'] as int? ?? 0, activity['finished'] as int? ?? 0)}';
  }

  Future<void> _load({bool announce = false}) async {
    setState(() => _busy = true);
    final roster = await _session.loadRoster();
    if (!mounted) return;
    setState(() {
      _roster = roster ?? _roster;
      _busy = false;
    });
    if (announce && roster != null) unawaited(TtsService.speak(_counts()));
  }

  String _name(Map<String, dynamic> person) => person['removed'] == true
      ? SessionText.removedName('${person['name']}')
      : '${person['name']}';

  Future<void> _read(String title, String key) async {
    await _load();
    if (!mounted) return;
    final people = _group(key);
    if (people.isEmpty) {
      unawaited(TtsService.speak(SessionText.nobody));
      return;
    }
    final chosen = await JourneyPrompts.choose<Map<String, dynamic>>(
      context,
      title: title,
      items: people,
      labelOf: _name,
    );
    if (chosen == null || !mounted) return;
    if (key == 'connected') {
      await _manage(chosen);
    } else {
      unawaited(TtsService.speak(_name(chosen)));
    }
  }

  /// A connected student: hear their state, or remove them from the class.
  Future<void> _manage(Map<String, dynamic> person) async {
    final live = _session.participants
        .where((participant) => participant['user_id'] == person['user_id'])
        .firstOrNull;
    final name = '${person['name']}';
    if (live == null) {
      unawaited(TtsService.speak(SessionText.participantGone));
      return;
    }
    final action = await JourneyPrompts.pick(
      context,
      title: name,
      introduction: _session.participantSummary(live),
      choices: [SessionText.hearDetails, SessionText.removeParticipant(name)],
    );
    if (action == 0) {
      unawaited(TtsService.speak(_session.participantSummary(live)));
    } else if (action == 1) {
      await _session.removeParticipant(live['id'] as int);
      await _load();
    }
  }

  Future<void> _remind() async {
    await _session.remindNotJoined();
    await _load();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _session.changes,
    builder: (context, _) => JourneyMenu(
      title: SessionText.classListTitle,
      busy: _busy,
      autoPlay: false,
      brief: _roster == null ? null : _counts(),
      status: _roster == null ? null : _counts(),
      details: _roster == null ? null : _counts(),
      backLabel: SessionText.backToClass,
      choices: [
        JourneyChoice(
          SessionText.hereNow(_group('connected').length),
          () => unawaited(_read(SessionText.hereNowTitle, 'connected')),
        ),
        JourneyChoice(
          SessionText.leftClass(_group('left').length),
          () => unawaited(_read(SessionText.leftClassTitle, 'left')),
        ),
        JourneyChoice(
          SessionText.notJoined(_group('not_joined').length),
          () => unawaited(_read(SessionText.notJoinedTitle, 'not_joined')),
        ),
        JourneyChoice(
          SessionText.remindNotJoined,
          () => unawaited(_remind()),
          enabled: _group('not_joined').isNotEmpty,
          unavailableReason: SessionText.everyoneJoined,
        ),
        JourneyChoice(
          SessionText.handQueue(_session.raisedHandCount),
          () => unawaited(_session.openHandQueue()),
        ),
      ],
    ),
  );
}
