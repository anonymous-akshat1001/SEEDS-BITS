import 'dart:async';

import 'package:flutter/material.dart';

import '../l10n/speech.dart';
import '../services/api_service.dart';
import '../services/auth_session_service.dart';
import '../services/message_center.dart';
import '../services/notification_services.dart';

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
            seconds: (interval.inSeconds * (1 << _failures.clamp(0, 3)))
                .clamp(interval.inSeconds, longestWait.inSeconds),
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
      setState(() {
        home = result.data is Map
            ? Map<String, dynamic>.from(result.data as Map)
            : <String, dynamic>{};
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
