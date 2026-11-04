import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../services/tts_service.dart';
import '../utils/ui_utils.dart';
import 'key_instruction_wrapper.dart';

class ClassroomConsoleDialog extends StatefulWidget {
  const ClassroomConsoleDialog({
    super.key,
    required this.revision,
    required this.participants,
    required this.summary,
    required this.acknowledge,
  });

  final ValueListenable<int> revision;
  final List<Map<String, dynamic>> Function() participants;
  final String Function() summary;
  final Future<String?> Function(int id, int? order) acknowledge;

  @override
  State<ClassroomConsoleDialog> createState() => _ClassroomConsoleDialogState();
}

class _ClassroomConsoleDialogState extends State<ClassroomConsoleDialog> {
  final _nodes = <String, FocusNode>{};
  int? _selectedId;
  bool _pending = false;
  String? _issue;
  String? _result;
  static const _help =
      'Classroom console. Read summary for the last received classroom state. '
      'Previous and Next select a raised hand without changing it. '
      'Acknowledge lowers only the selected hand after server confirmation. '
      'It never unmutes anyone. Older hands with unknown order are labelled separately.';

  FocusNode _node(String id) =>
      _nodes.putIfAbsent(id, () => FocusNode(debugLabel: 'console-$id'));

  @override
  void initState() {
    super.initState();
    final queue = _queue;
    if (queue.isNotEmpty) _selectedId = queue.first['id'] as int;
  }

  List<Map<String, dynamic>> get _queue {
    final hands = widget
        .participants()
        .where((p) => p['raised_hand'] == true && p['id'] is int)
        .toList();
    hands.sort((a, b) {
      final left = a['hand_queue_order'];
      final right = b['hand_queue_order'];
      if (left is int && right is int) return left.compareTo(right);
      if (left is int) return 1;
      if (right is int) return -1;
      return (a['id'] as int).compareTo(b['id'] as int);
    });
    return hands;
  }

  int _index(List<Map<String, dynamic>> queue) {
    final index = queue.indexWhere((p) => p['id'] == _selectedId);
    return index;
  }

  String _description(List<Map<String, dynamic>> queue) {
    if (queue.isEmpty) {
      return 'No raised hands in the last received classroom state.';
    }
    final index = _index(queue);
    if (index < 0) {
      return 'The selected hand is no longer in the queue. ${queue.length} raised hands remain. Use Next or Previous to select a hand.';
    }
    final hand = queue[index];
    return '${_handTitle(queue, index)}. '
        '${hand['hand_queue_order'] is int ? 'Server-recorded queue order.' : 'Original raise order unknown; shown before known-order hands.'} '
        '${hand['is_muted'] == true ? 'Microphone reported muted.' : 'Microphone reported unmuted; this is not proof of speech.'}';
  }

  /// Short identity of a raised hand, position first:
  /// "Hand 2 of 5, Ravi, waiting".
  String _handTitle(List<Map<String, dynamic>> queue, int index) {
    final hand = queue[index];
    return 'Hand ${index + 1} of ${queue.length}, '
        '${hand['name'] ?? 'Participant ${hand['id']}'}, waiting';
  }

  String _selectedTitle(List<Map<String, dynamic>> queue) {
    if (queue.isEmpty) return 'No raised hands';
    final index = _index(queue);
    return index < 0 ? 'No hand selected' : _handTitle(queue, index);
  }

  /// Moves keypad focus once the frame that re-enables controls is built.
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

  Future<void> _move(int direction) async {
    final queue = _queue;
    if (queue.isNotEmpty) {
      final index = _index(queue);
      final next = index < 0
          ? (direction > 0 ? 0 : queue.length - 1)
          : (index + direction) % queue.length;
      setState(() => _selectedId = queue[next]['id'] as int);
    }
    await TtsService.speak(_description(queue));
  }

  Future<void> _acknowledge() async {
    final queue = _queue;
    if (_pending) return;
    if (queue.isEmpty || _index(queue) < 0) {
      await TtsService.speak(_description(queue));
      return;
    }
    final index = _index(queue);
    final hand = queue[index];
    final name = hand['name'] ?? 'Participant ${hand['id']}';
    var next = 'acknowledge';
    setState(() {
      _pending = true;
      _issue = null;
      _result = null;
    });
    unawaited(
      TtsService.speak(
        'Lowering hand for $name. Waiting for the server.',
        priority: SpeechPriority.navigation,
      ),
    );
    try {
      final issue = await widget.acknowledge(
        hand['id'] as int,
        hand['hand_queue_order'] as int?,
      );
      if (!mounted) return;
      if (issue != null) {
        setState(() => _issue = issue);
        await TtsService.speak(issue, priority: SpeechPriority.critical);
        return;
      }
      // Select the hand that followed the lowered one so the teacher can
      // continue down the queue with one more OK.
      final remaining = [
        for (final p in queue)
          if (p['id'] != hand['id']) p,
      ];
      final result = remaining.isEmpty
          ? 'Hand lowered for $name. The hand queue is now empty.'
          : 'Hand lowered for $name. Next: '
                '${_handTitle(remaining, index % remaining.length)}.';
      setState(() {
        if (remaining.isNotEmpty) {
          _selectedId = remaining[index % remaining.length]['id'] as int;
        }
        _result = result;
      });
      if (remaining.isEmpty) next = 'read';
      await TtsService.speak(result);
    } finally {
      if (mounted) {
        setState(() => _pending = false);
        _focusAfter(next);
      }
    }
  }

  Future<void> _readSummary() async {
    final summary = widget.summary().trim();
    await TtsService.speak(
      summary.isEmpty ? 'No classroom summary is available yet.' : summary,
    );
  }

  @override
  void dispose() {
    for (final node in _nodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<int>(
    valueListenable: widget.revision,
    builder: (_, revision, child) {
      final queue = _queue;
      final targets = [
        KeypadFocusTarget(
          node: _node('summary'),
          label: 'Read classroom summary',
          onActivate: _readSummary,
        ),
        KeypadFocusTarget(
          node: _node('previous'),
          label: 'Previous raised hand',
          isEnabled: () => !_pending,
          onActivate: () => _move(-1),
        ),
        KeypadFocusTarget(
          node: _node('read'),
          label: 'Read selected hand. ${_selectedTitle(queue)}',
          onActivate: () => TtsService.speak(
            '${_description(_queue)} ${_issue ?? _result ?? ''}',
          ),
        ),
        KeypadFocusTarget(
          node: _node('next'),
          label: 'Next raised hand',
          isEnabled: () => !_pending,
          onActivate: () => _move(1),
        ),
        KeypadFocusTarget(
          node: _node('acknowledge'),
          label: _pending
              ? 'Waiting for hand acknowledgment'
              : queue.isEmpty || _index(queue) < 0
              ? 'Acknowledge and lower selected hand. No hand selected'
              : 'Lower ${queue[_index(queue)]['name'] ?? 'selected hand'}. Never unmutes',
          isEnabled: () => !_pending,
          onActivate: _acknowledge,
        ),
        KeypadFocusTarget(
          node: _node('stop'),
          label: 'Stop speech',
          onActivate: TtsService.stop,
        ),
        KeypadFocusTarget(
          node: _node('help'),
          label: 'Repeat console help',
          onActivate: () => TtsService.speak(_help),
        ),
        KeypadFocusTarget(
          node: _node('back'),
          label: 'Back to session',
          onActivate: () => Navigator.pop(context),
        ),
      ];
      Widget button(String id, String label) {
        final target = targets.firstWhere((t) => t.node == _node(id));
        return OutlinedButton(
          focusNode: target.node,
          onPressed: target.isEnabled?.call() == false
              ? null
              : target.onActivate,
          child: Text(label),
        );
      }

      return KeypadInstructionWrapper(
        screenName: _help,
        navigationSections:
            'read classroom summary, previous hand, read selected hand, next hand, acknowledge hand, stop speech, help and back. If no hands or summary are available, selecting their controls reads that status',
        actions: {0: () => Navigator.pop(context)},
        labels: const {0: 'Back to session'},
        focusTargets: targets,
        child: AlertDialog(
          title: const Text('Classroom console'),
          scrollable: true,
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              button('summary', 'Read classroom summary'),
              const Text(
                'Counts reflect the last received snapshot, not guaranteed audio delivery. Active speaker identification is unavailable.',
              ),
              Text(_description(queue)),
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
                )
              else if (_result != null && !_pending)
                Semantics(
                  liveRegion: true,
                  child: Text(
                    _result!,
                    style: TextStyle(color: UIUtils.successColor),
                  ),
                ),
              if (_pending)
                Semantics(
                  liveRegion: true,
                  child: const Text(
                    'Waiting for server acknowledgment. No microphone is changed.',
                  ),
                ),
              button('previous', 'Previous raised hand'),
              button('read', 'Read selected hand'),
              button('next', 'Next raised hand'),
              button('acknowledge', 'Acknowledge and lower hand'),
              button('stop', 'Stop speech'),
              button('help', 'Repeat console help'),
              button('back', 'Back to session'),
            ],
          ),
        ),
      );
    },
  );
}
