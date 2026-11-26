import 'dart:async';

import 'package:flutter/material.dart';

import '../l10n/speech.dart';
import '../services/api_service.dart';
import '../services/auth_session_service.dart';
import '../services/message_center.dart';
import '../services/notification_services.dart';
import '../utils/spoken_format.dart';

/// Keeps a home screen current without a Refresh button (S12): it asks the
/// server what to do now when it opens, every 20 seconds while it is on
/// screen, when the app returns to the front, and when a push arrives.
/// Failed checks back off up to two minutes instead of polling constantly.
mixin HomeUpdates<T extends StatefulWidget>
    on State<T>, WidgetsBindingObserver {
  static const interval = Duration(seconds: 20);
  static const longestWait = Duration(minutes: 2);

  Map<String, dynamic>? home;
  String? homeIssue;
  bool homeLoaded = false;
  Timer? _timer;
  StreamSubscription<Map<String, dynamic>>? _pushes;
  int _failures = 0;
  bool _checking = false;

  /// Called after every successful check with the previous answer.
  void homeChanged(Map<String, dynamic>? previous, {required bool first});

  final _heardNotices = <int>{};

  /// What someone else changed for this account since it was last heard
  /// ("Your administrator added lesson English, Class 6."), spoken once and
  /// marked as heard. Null when there is nothing new.
  String? takeNotices() {
    final list = home?['notices'] ?? home?['admin_notices'];
    final fresh = [
      for (final item in list is List ? list : const [])
        if (item is Map &&
            item['notice_id'] is int &&
            !_heardNotices.contains(item['notice_id']))
          Map<String, dynamic>.from(item),
    ];
    if (fresh.isEmpty) return null;
    final ids = [for (final item in fresh) item['notice_id'] as int];
    _heardNotices.addAll(ids);
    unawaited(ApiService.markNoticesSeen(ids));
    return fresh.map(noticeText).whereType<String>().join(' ');
  }

  /// One notice as a sentence; null for a kind this app does not know.
  static String? noticeText(Map<String, dynamic> item) {
    final t = Speech.t;
    final name = item['actor_name'];
    final actor = item['actor_role'] == 'admin' || name is! String
        ? t.noticeActorAdmin
        : name;
    final title = '${item['title']}';
    final detail = item['detail'];
    final day = detail is String ? DateTime.tryParse(detail) : null;
    final date = day == null ? '' : SpokenFormat.date(day);
    return switch ((item['kind'], item['action'])) {
      ('quiz', 'published') => t.noticeQuizPublished(actor, title),
      ('quiz', 'closed') => t.noticeQuizClosed(actor, title),
      ('quiz', _) => t.noticeQuizCreated(actor, title),
      ('journey', 'published') => t.noticeJourneyPublished(actor, title),
      ('journey', 'archived') => t.noticeJourneyArchived(actor, title),
      ('journey', _) => t.noticeJourneyCreated(actor, title),
      ('playlist', _) => t.noticePlaylistPublished(actor, title),
      ('lesson', 'updated') => t.noticeLessonUpdated(actor, title),
      ('lesson', 'removed') when day != null => t.noticeLessonRemovedOn(
        actor,
        title,
        date,
      ),
      ('lesson', 'removed') => t.noticeLessonRemoved(actor, title),
      ('lesson', 'cancelled') => t.noticeLessonCancelled(actor, title, date),
      ('lesson', 'substitute') => t.noticeLessonSubstitute(actor, title, date),
      ('lesson', 'covered') => t.noticeLessonCovered(actor, title, date),
      ('lesson', _) => t.noticeLessonCreated(actor, title),
      _ => null,
    };
  }

  void startHomeUpdates() {
    WidgetsBinding.instance.addObserver(this);
    _pushes = NotificationService().foregroundMessages.listen(
      (_) => unawaited(checkHome()),
    );
    unawaited(checkHome(first: true));
  }

  void stopHomeUpdates() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    unawaited(_pushes?.cancel());
  }

  bool get onScreen => mounted && (ModalRoute.of(context)?.isCurrent ?? true);

  void _schedule() {
    _timer?.cancel();
    final wait = _failures == 0
        ? interval
        : Duration(
            seconds: (interval.inSeconds * (1 << _failures.clamp(0, 3))).clamp(
              interval.inSeconds,
              longestWait.inSeconds,
            ),
          );
    _timer = Timer(wait, () {
      // Off screen (a class or a quiz is open): check again on return.
      if (onScreen) unawaited(checkHome());
    });
  }

  Future<void> checkHome({bool first = false}) async {
    if (_checking) return;
    _checking = true;
    try {
      final result = await ApiService.home();
      if (!mounted) return;
      if (!result.isSuccess) {
        final failure = result.failure!;
        if (failure.statusCode == 401) {
          await _signInAgain();
          return;
        }
        _failures++;
        setState(() {
          homeIssue = failure.kind == ApiFailureKind.network
              ? Speech.t.homeOffline
              : failure.message;
          homeLoaded = true;
        });
        if (first) homeChanged(null, first: true);
        return;
      }
      _failures = 0;
      final previous = home;
      final data = result.data is Map
          ? Map<String, dynamic>.from(result.data as Map)
          : <String, dynamic>{};
      // A new language or speed from the administrator is applied before
      // anything is spoken, so Home already speaks the right way.
      await AuthSessionService.applyAdministratorSpeech(data['speech']);
      if (!mounted) return;
      setState(() {
        home = data;
        homeIssue = null;
        homeLoaded = true;
      });
      homeChanged(previous, first: first);
    } finally {
      _checking = false;
      if (mounted) _schedule();
    }
  }

  /// Signed out elsewhere or expired: one clear path back to sign in.
  Future<void> _signInAgain() async {
    _timer?.cancel();
    await AuthSessionService.clearLoginState();
    if (!mounted) return;
    MessageCenter.carryToNextScreen(Speech.t.homeSignInAgain);
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && onScreen) {
      unawaited(checkHome());
    }
  }
}
