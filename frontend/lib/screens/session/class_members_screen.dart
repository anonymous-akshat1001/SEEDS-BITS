import 'dart:async';

import 'package:flutter/material.dart';

import '../../announcers/session_text.dart';
import '../../services/tts_service.dart';
import '../../widgets/journey_prompts.dart';
import '../../widgets/keypad_paged_list.dart';
import 'live_session.dart';

/// Key 6 for students: everyone in the class, read only. The teacher comes
/// first, then this phone's user, then everyone else by name. Selecting a
/// person reads whether their hand is raised and their microphone is on.
class ClassMembersScreen extends StatelessWidget {
  const ClassMembersScreen({super.key, required this.session});

  final LiveSession session;

  /// Teacher first, then you, then the others alphabetically.
  static List<Map<String, dynamic>> ordered(
    List<Map<String, dynamic>> people,
    int? ownId,
  ) {
    int rank(Map<String, dynamic> person) => person['is_teacher'] == true
        ? 0
        : person['id'] == ownId
        ? 1
        : 2;
    return [...people]..sort((a, b) {
      final byRank = rank(a).compareTo(rank(b));
      if (byRank != 0) return byRank;
      return '${a['name'] ?? ''}'.toLowerCase().compareTo(
        '${b['name'] ?? ''}'.toLowerCase(),
      );
    });
  }

  @override
  Widget build(BuildContext context) => KeypadPagedList<Map<String, dynamic>>(
    title: SessionText.membersTitle,
    scope: session,
    // Read live, so "Refresh this page" (6) shows people who joined or left.
    loadPage: (query) async => JourneyPrompts.memoryPage(
      ordered(session.participants, session.ownParticipantId),
      session.participantSummary,
      query,
    ),
    labelOf: session.participantSummary,
    onSelected: (person) =>
        unawaited(TtsService.speak(session.participantSummary(person))),
  );
}
