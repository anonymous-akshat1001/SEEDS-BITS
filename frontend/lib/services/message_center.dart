import 'dart:async';

import 'package:flutter/material.dart';

import '../l10n/speech.dart';
import '../utils/ui_utils.dart';
import 'feedback_cues.dart';
import 'tts_service.dart';

enum MessageKind { info, success, error }

class AppMessage {
  const AppMessage(this.text, this.kind, this.at);
  final String text;
  final MessageKind kind;
  final DateTime at;
}

/// One persistent "last message" for the whole app, replacing pop-ups that
/// vanish on a timer. It stays visible in [LastMessageBar], star reads it as
/// part of "where am I", and key 8 re-reads it on screens that do not use 8.
class MessageCenter {
  const MessageCenter._();

  static final ValueNotifier<AppMessage?> last = ValueNotifier(null);

  static AppMessage? _carried;
  static String? _arrival;
  static Timer? _arrivalTimer;

  /// For a message followed at once by a page change (sign out, leaving a
  /// class, password changed). Speaking it now would be cut off when the new
  /// page opens, so the destination screen speaks it before its own
  /// introduction and keeps it as the last message.
  static void carryToNextScreen(
    String text, {
    MessageKind kind = MessageKind.info,
  }) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    _carried = AppMessage(trimmed, kind, DateTime.now());
    if (kind == MessageKind.error) unawaited(FeedbackCues.play(Cue.error));
  }

  /// Called by the route observer when a new page is shown.
  static void pageChanged() {
    final carried = _carried;
    _carried = null;
    _arrivalTimer?.cancel();
    _arrivalTimer = null;
    last.value = carried;
    _arrival = carried?.text;
    if (carried == null) return;
    // A screen without an automatic introduction never takes the message;
    // speak it on its own so it is never lost.
    _arrivalTimer = Timer(const Duration(seconds: 2), () {
      final text = takeArrivalMessage();
      if (text != null) {
        unawaited(
          TtsService.speak(
            text,
            priority: carried.kind == MessageKind.error
                ? SpeechPriority.critical
                : SpeechPriority.requested,
          ),
        );
      }
    });
  }

  /// The message carried to this page, once; the screen introduction
  /// speaks it first.
  static String? takeArrivalMessage() {
    _arrivalTimer?.cancel();
    _arrivalTimer = null;
    final text = _arrival;
    _arrival = null;
    return text;
  }

  /// Shows, speaks and cues [text]. Errors use critical speech and the error
  /// cue; successes use the saved cue.
  static void show(
    String text, {
    MessageKind kind = MessageKind.info,
    bool speak = true,
    bool cue = true,
    SpeechPriority? priority,
  }) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    last.value = AppMessage(trimmed, kind, DateTime.now());
    if (cue) {
      switch (kind) {
        case MessageKind.success:
          unawaited(FeedbackCues.play(Cue.saved));
        case MessageKind.error:
          unawaited(FeedbackCues.play(Cue.error));
        case MessageKind.info:
          break;
      }
    }
    if (speak) {
      unawaited(
        TtsService.speak(
          trimmed,
          priority:
              priority ??
              (kind == MessageKind.error
                  ? SpeechPriority.critical
                  : SpeechPriority.requested),
        ),
      );
    }
  }

  static void success(String text, {bool speak = true}) =>
      show(text, kind: MessageKind.success, speak: speak);

  static void error(String text, {bool speak = true}) =>
      show(text, kind: MessageKind.error, speak: speak);

  /// "Last message: ...", or null when there is none.
  static String? spoken() {
    final message = last.value;
    if (message == null) return null;
    return message.kind == MessageKind.error
        ? Speech.t.messageLastProblem(message.text)
        : Speech.t.messageLast(message.text);
  }

  static void repeat() =>
      unawaited(TtsService.speak(spoken() ?? Speech.t.commonNoMessages));

  static void clear() => last.value = null;
}

/// A persistent strip at the bottom of every screen showing the last message.
/// Tapping it reads the message again.
class LastMessageBar extends StatelessWidget {
  const LastMessageBar({super.key});

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<AppMessage?>(
    valueListenable: MessageCenter.last,
    builder: (context, message, _) {
      if (message == null) return const SizedBox.shrink();
      final error = message.kind == MessageKind.error;
      return Material(
        color: error ? UIUtils.errorColor : UIUtils.cardColor,
        child: SafeArea(
          top: false,
          child: InkWell(
            // Not a keypad target; star and 8 read it without moving focus.
            canRequestFocus: false,
            onTap: MessageCenter.repeat,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: UIUtils.cardBorderColor, width: 2),
                ),
              ),
              // Already spoken when shown; screen readers reach it on demand.
              child: Semantics(
                label: MessageCenter.spoken(),
                excludeSemantics: true,
                child: Text(
                  error
                      ? Speech.t.messageProblem(message.text)
                      : Speech.t.messageMessage(message.text),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: error ? Colors.white : UIUtils.textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}
