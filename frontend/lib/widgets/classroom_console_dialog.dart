import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../services/tts_service.dart';
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
    return '${hand['name'] ?? 'Participant ${hand['id']}'}. '
        'Hand ${index + 1} of ${queue.length}. '
        '${hand['hand_queue_order'] is int ? 'Server-recorded queue order.' : 'Original raise order unknown; shown before known-order hands.'} '
        '${hand['is_muted'] == true ? 'Microphone reported muted.' : 'Microphone reported unmuted; this is not proof of speech.'}';
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
    if (_pending || queue.isEmpty || _index(queue) < 0) return;
    final hand = queue[_index(queue)];
    setState(() {
      _pending = true;
      _issue = null;
    });
    try {
      final issue = await widget.acknowledge(
        hand['id'] as int,
        hand['hand_queue_order'] as int?,
      );
      if (mounted) {
        setState(() => _issue = issue);
        if (issue != null) {
          await TtsService.speak(issue, priority: SpeechPriority.critical);
        }
      }
    } finally {
      if (mounted) setState(() => _pending = false);
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
  Widget build(BuildContext context) => ValueListenableBuilder<int>(
    valueListenable: widget.revision,
    builder: (_, revision, child) {
      final queue = _queue;
      final targets = [
        KeypadFocusTarget(
          node: _node('back'),
          label: 'Back to session',
          onActivate: () => Navigator.pop(context),
        ),
        KeypadFocusTarget(
          node: _node('summary'),
          label: 'Read classroom summary',
          onActivate: () => TtsService.speak(widget.summary()),
        ),
        KeypadFocusTarget(
          node: _node('previous'),
          label: 'Previous raised hand',
          isEnabled: () => queue.isNotEmpty && !_pending,
          onActivate: () => _move(-1),
        ),
        KeypadFocusTarget(
          node: _node('read'),
          label:
              'Read selected hand and action status. ${_description(queue)} ${_issue ?? ''}',
          onActivate: () =>
              TtsService.speak('${_description(_queue)} ${_issue ?? ''}'),
        ),
        KeypadFocusTarget(
          node: _node('next'),
          label: 'Next raised hand',
          isEnabled: () => queue.isNotEmpty && !_pending,
          onActivate: () => _move(1),
        ),
        KeypadFocusTarget(
          node: _node('acknowledge'),
          label: _pending
              ? 'Waiting for hand acknowledgment'
              : 'Acknowledge and lower selected hand. Never unmute',
          isEnabled: () => queue.isNotEmpty && _index(queue) >= 0 && !_pending,
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
        actions: {0: () => Navigator.pop(context)},
        labels: const {0: 'Back to session'},
        onHashKey: () => Navigator.pop(context),
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
                Semantics(liveRegion: true, child: Text(_issue!)),
              if (_pending)
                const Text(
                  'Waiting for server acknowledgment. No microphone is changed.',
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
