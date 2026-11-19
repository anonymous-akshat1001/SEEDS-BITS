import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb, visibleForTesting;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/speech.dart';
import '../main.dart' show navigatorKey;
import '../utils/ui_utils.dart';
import '../widgets/key_instruction_wrapper.dart';
import 'api_service.dart';
import 'private_note_recorder.dart';
import 'tts_service.dart';

/// Android's FLAG_INSISTENT: repeat the sound until cancelled or timed out.
const _insistentFlag = 4;

/// One class alert from the server (S13/S15/S45).
class ClassAlert {
  const ClassAlert({
    required this.sessionId,
    required this.alertId,
    required this.ringUntil,
  });

  final int sessionId;
  final String alertId;
  final DateTime ringUntil;

  static ClassAlert? parse(Map<String, dynamic> data) {
    if (data['type'] != 'class_alert') return null;
    final session = int.tryParse('${data['session_id'] ?? ''}');
    final ring = int.tryParse('${data['ring_until'] ?? ''}');
    final alert = '${data['alert_id'] ?? ''}';
    if (session == null || ring == null || alert.isEmpty) return null;
    return ClassAlert(
      sessionId: session,
      alertId: alert,
      ringUntil: DateTime.fromMillisecondsSinceEpoch(ring, isUtc: true),
    );
  }

  /// Ringing time left; a late push rings only for what remains.
  Duration remaining(DateTime now) {
    final left = ringUntil.difference(now.toUtc());
    return left.isNegative ? Duration.zero : left;
  }
}

/// Rings for at most one minute, then leaves a silent notification that
/// still opens the class while it is live. Opening either joins directly.
class ClassAlerts {
  ClassAlerts._();

  static final ClassAlerts instance = ClassAlerts._();

  /// The app's notification plugin (a singleton); replaced in tests.
  FlutterLocalNotificationsPlugin plugin = FlutterLocalNotificationsPlugin();

  /// Joins the class; set by the app once navigation is ready.
  Future<bool> Function(int sessionId)? onJoin;

  @visibleForTesting
  DateTime Function() now = DateTime.now;

  static const _seenKey = 'class_alerts_seen';
  static int ringId(int sessionId) => 710000 + sessionId % 100000;
  static int waitingId(int sessionId) => 720000 + sessionId % 100000;
  static String payloadFor(int sessionId) =>
      'type=class_alert&session_id=$sessionId';

  bool _dialogOpen = false;
  int? _dialogSession;

  /// True if this alert was already handled on this phone, so a repeated or
  /// late push never restarts the ringing.
  Future<bool> _alreadySeen(ClassAlert alert) async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getStringList(_seenKey) ?? const [];
    if (seen.contains(alert.alertId)) return true;
    final updated = [...seen, alert.alertId];
    await prefs.setStringList(
      _seenKey,
      updated.length > 20 ? updated.sublist(updated.length - 20) : updated,
    );
    return false;
  }

  /// Shows the ringing and the waiting notification. [inApp] also opens a
  /// keypad dialog where OK joins (the app is in front).
  Future<void> present(
    Map<String, dynamic> data, {
    bool inApp = false,
  }) async {
    final alert = ClassAlert.parse(data);
    if (alert == null || kIsWeb) return;
    if (await _alreadySeen(alert)) return;
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString('role') != 'student') return;
    if (prefs.getInt('active_session_id') == alert.sessionId &&
        PrivateNoteRecorder.liveSessions > 0) {
      return; // already in this class
    }
    final remaining = alert.remaining(now());
    try {
      await _showNotifications(alert.sessionId, remaining);
    } catch (error) {
      debugPrint('[CLASS ALERT] Could not show the alert: $error');
    }
    if (inApp && remaining > Duration.zero) {
      unawaited(_showDialog(alert.sessionId, remaining));
    }
  }

  Future<void> _showNotifications(int sessionId, Duration remaining) async {
    final t = Speech.t;
    final payload = payloadFor(sessionId);
    if (remaining > Duration.zero) {
      await plugin.show(
        ringId(sessionId),
        t.classAlertTitle,
        t.classAlertBody,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'class_ring',
            t.classAlertChannelName,
            channelDescription: t.classAlertChannelDescription,
            importance: Importance.max,
            priority: Priority.max,
            category: AndroidNotificationCategory.reminder,
            visibility: NotificationVisibility.private,
            audioAttributesUsage: AudioAttributesUsage.notificationRingtone,
            fullScreenIntent: true,
            additionalFlags: Int32List.fromList([_insistentFlag]),
            timeoutAfter: remaining.inMilliseconds,
            autoCancel: true,
            icon: '@mipmap/ic_launcher',
          ),
        ),
        payload: payload,
      );
    }
    await plugin.show(
      waitingId(sessionId),
      t.classAlertTitle,
      t.classAlertWaitingBody,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'class_waiting',
          t.classAlertWaitingChannelName,
          channelDescription: t.classAlertWaitingChannelDescription,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          playSound: false,
          enableVibration: false,
          onlyAlertOnce: true,
          visibility: NotificationVisibility.private,
          autoCancel: true,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      payload: payload,
    );
  }

  /// Stops ringing and removes both notifications for a class.
  Future<void> cancelFor(int sessionId) async {
    if (_dialogOpen && _dialogSession == sessionId) {
      navigatorKey.currentState?.pop();
    }
    if (kIsWeb) return;
    try {
      await plugin.cancel(ringId(sessionId));
      await plugin.cancel(waitingId(sessionId));
    } catch (error) {
      // Never let notification cleanup stop someone joining their class.
      debugPrint('[CLASS ALERT] Cancel unavailable: $error');
    }
  }

  /// Stops the ringing but keeps the silent "class is live" notification.
  Future<void> cancelRinging(int sessionId) async {
    try {
      await plugin.cancel(ringId(sessionId));
    } catch (error) {
      debugPrint('[CLASS ALERT] Cancel unavailable: $error');
    }
  }

  /// Stops ringing everywhere, for example when switching account.
  Future<void> cancelAll() async {
    if (kIsWeb) return;
    try {
      final active = await plugin.getActiveNotifications();
      for (final notification in active) {
        final id = notification.id;
        if (id != null && id >= 710000 && id < 730000) await plugin.cancel(id);
      }
    } catch (error) {
      debugPrint('[CLASS ALERT] Cancel unavailable: $error');
    }
  }

  Future<void> _showDialog(int sessionId, Duration remaining) async {
    final context = navigatorKey.currentContext;
    if (_dialogOpen || context == null || !context.mounted) return;
    _dialogOpen = true;
    _dialogSession = sessionId;
    String? subject;
    final home = await ApiService.home();
    final live = home.isSuccess && home.data is Map
        ? (home.data as Map)['live_class']
        : null;
    if (live is Map && live['session_id'] == sessionId) {
      subject = live['subject_name']?.toString();
    }
    if (!context.mounted) {
      _dialogOpen = false;
      return;
    }
    try {
      final join = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => ClassAlertDialog(subject: subject, remaining: remaining),
      );
      _dialogOpen = false;
      if (join == true) {
        await cancelFor(sessionId);
        await onJoin?.call(sessionId);
      } else if (join == false) {
        // Stop ringing; the silent notification stays until the class ends.
        await cancelRinging(sessionId);
      }
    } finally {
      _dialogOpen = false;
      _dialogSession = null;
    }
  }
}

/// In-app alert while the class rings: OK or 1 joins, 0 or Back stops the
/// ringing. Closes itself when the ringing ends.
class ClassAlertDialog extends StatefulWidget {
  const ClassAlertDialog({super.key, this.subject, required this.remaining});

  final String? subject;
  final Duration remaining;

  @override
  State<ClassAlertDialog> createState() => _ClassAlertDialogState();
}

class _ClassAlertDialogState extends State<ClassAlertDialog> {
  final _joinFocus = FocusNode(debugLabel: 'class-alert-join');
  final _dismissFocus = FocusNode(debugLabel: 'class-alert-dismiss');
  Timer? _timeout;

  @override
  void initState() {
    super.initState();
    _timeout = Timer(widget.remaining, () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    _timeout?.cancel();
    _joinFocus.dispose();
    _dismissFocus.dispose();
    super.dispose();
  }

  void _close(bool join) => Navigator.of(context).pop(join);

  @override
  Widget build(BuildContext context) {
    final t = Speech.t;
    final message = widget.subject == null
        ? t.classAlertStarted
        : t.classAlertSubjectStarted(widget.subject!);
    return KeypadInstructionWrapper(
      interactionPolicy: KeypadInteractionPolicy.numbered,
      screenName: t.classAlertTitle,
      brief: '$message ${t.classAlertKeys}',
      initialFocusNode: _joinFocus,
      labels: {1: t.classAlertJoin, 0: t.classAlertNotNow},
      actions: {1: () => _close(true), 0: () => _close(false)},
      focusTargets: [
        KeypadFocusTarget(
          node: _joinFocus,
          // Focused on arrival, so this is the first thing heard.
          label: '$message ${t.classAlertKeys}',
          onActivate: () => _close(true),
        ),
        KeypadFocusTarget(
          node: _dismissFocus,
          label: '0. ${t.classAlertNotNow}',
          onActivate: () => _close(false),
        ),
      ],
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _close(false);
        },
        child: AlertDialog(
          title: Semantics(header: true, child: Text(t.classAlertTitle)),
          content: Text(message, style: const TextStyle(fontSize: 20)),
          actions: [
            TextButton(
              focusNode: _dismissFocus,
              onPressed: () => _close(false),
              child: Text('0: ${t.classAlertNotNow}'),
            ),
            ElevatedButton(
              focusNode: _joinFocus,
              autofocus: true,
              style: ElevatedButton.styleFrom(
                backgroundColor: UIUtils.successColor,
              ),
              onPressed: () => _close(true),
              child: Text('1: ${t.classAlertJoin}'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Speaks a short "class started" line on the home screen.
void announceClassStarted(String? subject) => unawaited(
  TtsService.speak(
    subject == null
        ? Speech.t.classAlertStarted
        : Speech.t.classAlertSubjectStarted(subject),
    priority: SpeechPriority.critical,
  ),
);
