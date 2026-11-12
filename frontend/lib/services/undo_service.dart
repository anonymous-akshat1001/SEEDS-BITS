import 'dart:async';

import 'package:flutter/foundation.dart';

import 'feedback_cues.dart';
import 'message_center.dart';
import 'tts_service.dart';

class _PendingUndo {
  _PendingUndo(this.label, this.undo, this.commit, this.timer);
  final String label;
  final FutureOr<void> Function() undo;
  final FutureOr<void> Function()? commit;
  final Timer timer;
}

/// "Press 1 within 10 seconds to undo" after a removal.
///
/// While an undo is pending, key 1 on any keypad screen undoes it (the
/// keypad wrapper checks [handleKey] before the screen's own key 1). When
/// the window ends, [commit] runs so slow-to-reverse work (such as deleting
/// downloaded files) only happens after the user had a chance to undo.
class UndoService {
  const UndoService._();

  static const window = Duration(seconds: 10);
  static _PendingUndo? _pending;

  static bool get pending => _pending != null;

  /// Announces [done] and offers undo for [window].
  static Future<void> offer({
    required String done,
    required FutureOr<void> Function() undo,
    FutureOr<void> Function()? commit,
    Duration duration = window,
  }) async {
    await _finish(commitNow: true);
    final timer = Timer(duration, () => unawaited(_finish(commitNow: true)));
    _pending = _PendingUndo(done, undo, commit, timer);
    MessageCenter.show(
      '$done Press 1 within ${duration.inSeconds} seconds to undo.',
      kind: MessageKind.success,
    );
  }

  /// Undoes the pending removal, if any. Returns true when key 1 was used.
  static bool handleKey() {
    final pending = _pending;
    if (pending == null) return false;
    _pending = null;
    pending.timer.cancel();
    unawaited(_runUndo(pending));
    return true;
  }

  static Future<void> _runUndo(_PendingUndo pending) async {
    try {
      await pending.undo();
      unawaited(FeedbackCues.play(Cue.ok));
      MessageCenter.show('Undone. ${pending.label.replaceAll(RegExp(r'\.$'), '')} was reversed.',
          kind: MessageKind.info, priority: SpeechPriority.critical);
    } catch (error) {
      debugPrint('[UNDO] Failed (${error.runtimeType})');
      MessageCenter.error('Undo did not work. Check the item and add it again if needed.');
    }
  }

  /// Commits a pending removal now (for example when leaving the app).
  static Future<void> commitPending() => _finish(commitNow: true);

  static Future<void> _finish({required bool commitNow}) async {
    final pending = _pending;
    if (pending == null) return;
    _pending = null;
    pending.timer.cancel();
    if (commitNow && pending.commit != null) {
      try {
        await pending.commit!();
      } catch (error) {
        debugPrint('[UNDO] Commit failed (${error.runtimeType})');
      }
    }
  }

  @visibleForTesting
  static void reset() {
    _pending?.timer.cancel();
    _pending = null;
  }
}
