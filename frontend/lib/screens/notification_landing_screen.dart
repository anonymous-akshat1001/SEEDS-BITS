import 'dart:async';

import 'package:flutter/material.dart';

import '../announcers/notification_text.dart';
import '../l10n/speech.dart';
import '../services/journey_api.dart';
import '../services/message_center.dart';
import '../services/offline_journey_store.dart';
import '../widgets/journey_menu.dart';
import 'journeys/student_journeys_screen.dart';
import 'quiz_screens.dart';

/// Opened from a tapped notification. Says what arrived and waits for the
/// user: 1 opens it, 0 goes back. Class alerts never come here: opening one
/// joins the class directly (see ClassEntry).
class NotificationLandingScreen extends StatefulWidget {
  const NotificationLandingScreen({
    super.key,
    required this.data,
    this.api = const JourneyApi(),
  });

  final Map<String, dynamic> data;
  final JourneyApi api;

  @override
  State<NotificationLandingScreen> createState() =>
      _NotificationLandingScreenState();
}

class _NotificationLandingScreenState extends State<NotificationLandingScreen> {
  bool _busy = false;

  String get _type => '${widget.data['type'] ?? ''}';
  int? _id(String key) => int.tryParse('${widget.data[key] ?? ''}');

  Future<void> _open() async {
    final navigator = Navigator.of(context);
    switch (_type) {
      case 'journey_published':
        final id = _id('journey_id');
        if (id == null) {
          await navigator.pushReplacement(
            MaterialPageRoute(builder: (_) => const StudentJourneysScreen()),
          );
          return;
        }
        setState(() => _busy = true);
        try {
          final snapshot = await widget.api.studentJourney(id);
          final store = await OfflineJourneyStore.forCurrentUser();
          if (!mounted) return;
          await navigator.pushReplacement(
            MaterialPageRoute(
              builder: (_) => StudentJourneyOptionsScreen(
                journeyId: snapshot.journeyId,
                title: snapshot.title,
                description: snapshot.description,
                revision: snapshot.revision,
                api: widget.api,
                store: store,
              ),
            ),
          );
        } on JourneyApiException catch (error) {
          MessageCenter.error(error.message);
        } on OfflineJourneyException catch (error) {
          MessageCenter.error(error.message);
        } finally {
          if (mounted) setState(() => _busy = false);
        }
      case 'quiz_published' || 'quiz_reminder':
        await navigator.pushReplacement(
          MaterialPageRoute(builder: (_) => const StudentQuizScreen()),
        );
      default:
        navigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final message = NotificationText.arrived(_type);
    return JourneyMenu(
      title: NotificationText.title(_type),
      introduction: message,
      details: message,
      busy: _busy,
      backLabel: Speech.t.uiNotNow,
      choices: [
        JourneyChoice(NotificationText.openLabel(_type), () => unawaited(_open())),
      ],
    );
  }
}
