import 'dart:async';

import 'package:flutter/material.dart';

import '../announcers/session_text.dart';
import '../l10n/speech.dart';
import '../services/classroom_check_state.dart';
import '../services/tts_service.dart';
import '../utils/ui_utils.dart';
import 'key_instruction_wrapper.dart';
import 'keypad_confirmation_dialog.dart';

class ClassroomCheckDialog extends StatefulWidget {
  const ClassroomCheckDialog({
    super.key,
    required this.state,
    required this.teacher,
    required this.act,
  });
  final ValueNotifier<ClassroomCheckState> state;
  final bool teacher;
  final Future<String?> Function(String type, String? id, String? choice) act;
  @override
  State<ClassroomCheckDialog> createState() => _ClassroomCheckDialogState();
}

class _ClassroomCheckDialogState extends State<ClassroomCheckDialog> {
  final _nodes = <String, FocusNode>{};
  bool _busy = false;
  String? _issue;
  FocusNode _node(String id) =>
      _nodes.putIfAbsent(id, () => FocusNode(debugLabel: 'check-$id'));

  /// Moves keypad focus once the frame that re-enables controls is built.
  /// Falls back to Read so focus is never lost to a disabled button.
  void _focusAfter(String id) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final node = _node(id);
      if (node.context != null && node.canRequestFocus) {
        node.requestFocus();
      } else {
        _node('read').requestFocus();
      }
    });
  }

  Future<void> _act(String type, {String? choice}) async {
    if (_busy) return;
    final id = widget.state.value.id;
    final origin = switch (type) {
      'open_check' => 'open',
      'close_check' => 'close',
      'read_check' => 'refresh',
      _ => choice ?? 'read',
    };
    var next = origin;
    setState(() {
      _busy = true;
      _issue = null;
    });
    try {
      if (type == 'open_check') {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (_) => KeypadConfirmationDialog(
            title: SessionText.checkNewTitle,
            message: SessionText.checkNewMessage,
            confirmLabel: SessionText.checkNewConfirm,
            cancelLabel: SessionText.checkNewCancel,
          ),
        );
        if (confirmed != true || !mounted) return;
      }
      unawaited(
        TtsService.speak(
          SessionText.checkSending,
          priority: SpeechPriority.navigation,
        ),
      );
      final issue = await widget.act(type, id, choice);
      if (!mounted) return;
      setState(() => _issue = issue);
      if (issue == null) {
        next = switch (type) {
          'open_check' => 'close',
          'close_check' => 'open',
          _ => origin,
        };
      }
      await TtsService.speak(
        issue ?? widget.state.value.describe(widget.teacher),
        priority: issue == null
            ? SpeechPriority.requested
            : SpeechPriority.critical,
      );
    } finally {
      if (mounted) {
        setState(() => _busy = false);
        _focusAfter(next);
      }
    }
  }

  @override
  void dispose() {
    for (final node in _nodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      ValueListenableBuilder<ClassroomCheckState>(
        valueListenable: widget.state,
        builder: (_, state, child) {
          final targets = [
            KeypadFocusTarget(
              node: _node('back'),
              label: SessionText.backToSession,
              onActivate: () => Navigator.pop(context),
            ),
            KeypadFocusTarget(
              node: _node('read'),
              label: SessionText.checkRead,
              onActivate: () => TtsService.speak(
                '${state.describe(widget.teacher)} ${_issue ?? ''}',
              ),
            ),
            KeypadFocusTarget(
              node: _node('refresh'),
              label: SessionText.checkRefresh,
              isEnabled: () => !_busy,
              onActivate: () => _act('read_check'),
            ),
            if (widget.teacher) ...[
              KeypadFocusTarget(
                node: _node('open'),
                label: SessionText.checkOpenLabel,
                isEnabled: () => !_busy,
                onActivate: () => _act('open_check'),
              ),
              KeypadFocusTarget(
                node: _node('close'),
                label: SessionText.checkCloseLabel,
                isEnabled: () => !_busy && state.open,
                onActivate: () => _act('close_check'),
              ),
            ] else
              for (final choice in ClassroomCheckState.labels.entries)
                KeypadFocusTarget(
                  node: _node(choice.key),
                  label: SessionText.checkAnswer(choice.value),
                  isEnabled: () => !_busy && state.open,
                  onActivate: () => _act('check_response', choice: choice.key),
                ),
            KeypadFocusTarget(
              node: _node('stop'),
              label: SessionText.stopSpeech,
              onActivate: TtsService.stop,
            ),
          ];
          Widget button(String id, String label) {
            final target = targets.firstWhere(
              (target) => target.node == _node(id),
            );
            return OutlinedButton(
              focusNode: target.node,
              onPressed: target.isEnabled?.call() == false
                  ? null
                  : target.onActivate,
              child: Text(label),
            );
          }

          return KeypadInstructionWrapper(
            screenName: SessionText.checkHelp,
            actions: {0: () => Navigator.pop(context)},
            labels: {0: SessionText.back},
            focusTargets: targets,
            child: AlertDialog(
              title: Text(Speech.t.classroomCheckTitle),
              scrollable: true,
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Semantics(
                    liveRegion: true,
                    child: Text(state.describe(widget.teacher)),
                  ),
                  if (_issue != null)
                    Semantics(
                      liveRegion: true,
                      child: Text(
                        _issue!,
                        style: TextStyle(
                          color: UIUtils.errorColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  if (_busy)
                    Semantics(
                      liveRegion: true,
                      child: Text(SessionText.checkWaiting),
                    ),
                  button('read', SessionText.checkReadButton),
                  button('refresh', SessionText.checkRefreshButton),
                  if (widget.teacher) ...[
                    button('open', SessionText.checkOpenButton),
                    button('close', SessionText.checkCloseButton),
                  ] else
                    for (final choice in ClassroomCheckState.labels.entries)
                      button(choice.key, choice.value),
                  button('stop', SessionText.stopSpeech),
                  button('back', SessionText.backToSession),
                ],
              ),
            ),
          );
        },
      );
}
