import 'dart:async';

import 'package:flutter/material.dart';

import '../../announcers/session_text.dart';
import '../../services/tts_service.dart';
import '../../widgets/journey_menu.dart';
import '../../widgets/journey_prompts.dart';
import 'live_session.dart';

/// Key 9 for teachers: rarely used actions that affect the whole class.
/// Everything needed every minute (hands, checks, participants, recording)
/// has its own key on the teacher's class screen. The class keeps running
/// underneath.
class TeacherToolsScreen extends StatelessWidget {
  const TeacherToolsScreen({super.key, required this.session});

  final LiveSession session;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: session.changes,
    builder: (context, _) => JourneyMenu(
      title: SessionText.toolsTitle,
      status: SessionText.consoleStatus(
        session.raisedHandCount,
        session.participants.length,
      ),
      details: session.classStatus(),
      backLabel: SessionText.backToClass,
      choices: [
        JourneyChoice(SessionText.invite, session.openInvite),
        JourneyChoice(
          SessionText.endClass,
          () => unawaited(session.confirmEndSession()),
        ),
        JourneyChoice(
          SessionText.summaryChoice,
          () => unawaited(TtsService.speak(session.classroomSummary())),
        ),
      ],
    ),
  );
}

/// Key 7 for teachers: raised hands queue, the participants list (mute or
/// remove someone) and the classroom summary.
class ClassPeopleScreen extends StatelessWidget {
  const ClassPeopleScreen({super.key, required this.session});

  final LiveSession session;

  List<Map<String, dynamic>> get _others => [
    for (final participant in session.participants)
      if (participant['id'] != session.ownParticipantId) participant,
  ];

  Future<void> _openParticipants(BuildContext context) async {
    final others = _others;
    if (others.isEmpty) {
      unawaited(TtsService.speak(SessionText.noOtherParticipants));
      return;
    }
    final chosen = await JourneyPrompts.choose<Map<String, dynamic>>(
      context,
      title: SessionText.participantsTitle,
      items: others,
      labelOf: session.participantSummary,
    );
    if (chosen == null || !context.mounted) return;
    final id = chosen['id'] as int;
    final name = chosen['name'] as String? ?? SessionText.participantFallback;
    final action = await JourneyPrompts.pick(
      context,
      title: name,
      introduction: session.participantSummary(chosen),
      choices: [
        SessionText.hearDetails,
        SessionText.muteParticipant(name),
        SessionText.removeParticipant(name),
      ],
    );
    final current = session.participants
        .where((participant) => participant['id'] == id)
        .firstOrNull;
    if (action == null) return;
    if (current == null) {
      unawaited(TtsService.speak(SessionText.participantGone));
      return;
    }
    switch (action) {
      case 0:
        unawaited(TtsService.speak(session.participantSummary(current)));
      case 1:
        await session.muteParticipant(id);
      case 2:
        await session.removeParticipant(id);
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: session.changes,
    builder: (context, _) => JourneyMenu(
      title: SessionText.peopleTitle,
      status: SessionText.consoleStatus(
        session.raisedHandCount,
        session.participants.length,
      ),
      backLabel: SessionText.backToClass,
      choices: [
        JourneyChoice(
          SessionText.handQueue(session.raisedHandCount),
          () => unawaited(session.openHandQueue()),
        ),
        JourneyChoice(
          SessionText.participantList(session.participants.length),
          () => unawaited(_openParticipants(context)),
        ),
        JourneyChoice(
          SessionText.summaryChoice,
          () => unawaited(TtsService.speak(session.classroomSummary())),
        ),
      ],
    ),
  );
}
