import 'dart:async';

import 'package:flutter/material.dart';

import '../../announcers/session_text.dart';
import '../../services/tts_service.dart';
import '../../widgets/journey_menu.dart';
import '../../widgets/journey_prompts.dart';
import '../../widgets/keypad_paged_list.dart';
import 'live_session.dart';

/// Key 4 in a live class: read messages (newest first), write one, or send
/// a quick phrase. The class keeps running underneath.
class SessionChatScreen extends StatelessWidget {
  const SessionChatScreen({super.key, required this.session});

  final LiveSession session;

  Map<String, dynamic>? get _newest =>
      session.messages.isEmpty ? null : session.messages.last;

  Future<void> _read(BuildContext context) async {
    if (session.messages.isEmpty) {
      unawaited(TtsService.speak(SessionText.noMessages));
      return;
    }
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => SessionMessagesScreen(session: session),
      ),
    );
  }

  Future<void> _write(BuildContext context) async {
    final text = await JourneyPrompts.askText(
      context,
      title: SessionText.writeMessage,
      label: SessionText.messageField,
      max: 500,
    );
    if (text == null || text.isEmpty) return;
    await session.sendChat(text);
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: session.changes,
    builder: (context, _) => JourneyMenu(
      title: SessionText.chatTitle,
      introduction: SessionText.chatHelp,
      busy: session.chatPending,
      status: session.chatPending
          ? SessionText.waitingMessage
          : SessionText.chatCount(session.messages.length),
      details: SessionText.latestMessage(_newest),
      backLabel: SessionText.backToClass,
      choices: [
        JourneyChoice(SessionText.readMessages, () => _read(context)),
        JourneyChoice(SessionText.writeMessage, () => _write(context)),
        for (final phrase in SessionText.quickPhrases)
          JourneyChoice(
            SessionText.sendPhrase(phrase),
            () => unawaited(session.sendChat(phrase)),
          ),
      ],
    ),
  );
}

/// Five messages per page, newest first. 7 and 9 change page; selecting a
/// message reads it in full with its time and delivery status.
class SessionMessagesScreen extends StatelessWidget {
  const SessionMessagesScreen({super.key, required this.session});

  final LiveSession session;

  @override
  Widget build(BuildContext context) => KeypadPagedList<Map<String, dynamic>>(
    title: SessionText.messagesTitle,
    scope: session,
    // Read live, so "Refresh this page" (6) shows messages that arrived.
    loadPage: (query) async => JourneyPrompts.memoryPage(
      session.messages.reversed.toList(),
      SessionText.messageLine,
      query,
    ),
    labelOf: SessionText.messageLine,
    onSelected: (message) =>
        unawaited(TtsService.speak(SessionText.messageDetail(message))),
  );
}
