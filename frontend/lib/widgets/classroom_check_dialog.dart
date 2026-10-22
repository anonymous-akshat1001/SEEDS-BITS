import 'package:flutter/material.dart';

import '../services/classroom_check_state.dart';
import '../services/tts_service.dart';
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

  Future<void> _act(String type, {String? choice}) async {
    if (_busy) return;
    final id = widget.state.value.id;
    setState(() {
      _busy = true;
      _issue = null;
    });
    try {
      if (type == 'open_check') {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (_) => const KeypadConfirmationDialog(
            title: 'Open a new classroom check?',
            message:
                'This clears all responses from the previous check. Students choose Understood, Please repeat or Need help. Only you and each responding student can read their response. It is not graded or retained as an academic record.',
            confirmLabel: 'Clear previous and open',
            cancelLabel: 'Keep current check',
          ),
        );
        if (confirmed != true || !mounted) return;
      }
      final issue = await widget.act(type, id, choice);
      if (!mounted) return;
      setState(() => _issue = issue);
      await TtsService.speak(
        issue ?? widget.state.value.describe(widget.teacher),
        priority: issue == null
            ? SpeechPriority.requested
            : SpeechPriority.critical,
      );
    } finally {
      if (mounted) setState(() => _busy = false);
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
  Widget build(
    BuildContext context,
  ) => ValueListenableBuilder<ClassroomCheckState>(
    valueListenable: widget.state,
    builder: (_, state, child) {
      final targets = [
        KeypadFocusTarget(
          node: _node('back'),
          label: 'Back to session',
          onActivate: () => Navigator.pop(context),
        ),
        KeypadFocusTarget(
          node: _node('read'),
          label: 'Read check status and confirmed responses',
          onActivate: () => TtsService.speak(
            '${state.describe(widget.teacher)} ${_issue ?? ''}',
          ),
        ),
        KeypadFocusTarget(
          node: _node('refresh'),
          label: 'Refresh private check state. Requires class connection',
          isEnabled: () => !_busy,
          onActivate: () => _act('read_check'),
        ),
        if (widget.teacher) ...[
          KeypadFocusTarget(
            node: _node('open'),
            label: 'Open a new check. Confirm clearing previous responses',
            isEnabled: () => !_busy,
            onActivate: () => _act('open_check'),
          ),
          KeypadFocusTarget(
            node: _node('close'),
            label:
                'Close this check. Keep current results until next check or session end',
            isEnabled: () => !_busy && state.open,
            onActivate: () => _act('close_check'),
          ),
        ] else
          for (final choice in ClassroomCheckState.labels.entries)
            KeypadFocusTarget(
              node: _node(choice.key),
              label:
                  '${choice.value}. Send or change your private, ungraded response',
              isEnabled: () => !_busy && state.open,
              onActivate: () => _act('check_response', choice: choice.key),
            ),
        KeypadFocusTarget(
          node: _node('stop'),
          label: 'Stop speech',
          onActivate: TtsService.stop,
        ),
      ];
      Widget button(String id, String label) {
        final target = targets.firstWhere((target) => target.node == _node(id));
        return OutlinedButton(
          focusNode: target.node,
          onPressed: target.isEnabled?.call() == false
              ? null
              : target.onActivate,
          child: Text(label),
        );
      }

      return KeypadInstructionWrapper(
        screenName:
            'Private classroom check. Understood, Please repeat or Need help. '
            'Only the responding student and session teacher can read a response. '
            'It is not graded. Responses clear on the next check, session end or server restart. '
            'Use Read or Refresh for confirmed state. Stop speech and Back are available.',
        actions: {0: () => Navigator.pop(context)},
        labels: const {0: 'Back'},
        onHashKey: () => Navigator.pop(context),
        focusTargets: targets,
        child: AlertDialog(
          title: const Text('Classroom check'),
          scrollable: true,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(state.describe(widget.teacher)),
              if (_issue != null)
                Semantics(liveRegion: true, child: Text(_issue!)),
              if (_busy) const Text('Waiting for confirmation. Do not resend.'),
              button('read', 'Read status and responses'),
              button('refresh', 'Refresh from server'),
              if (widget.teacher) ...[
                button('open', 'Open new check'),
                button('close', 'Close check'),
              ] else
                for (final choice in ClassroomCheckState.labels.entries)
                  button(choice.key, choice.value),
              button('stop', 'Stop speech'),
              button('back', 'Back to session'),
            ],
          ),
        ),
      );
    },
  );
}
