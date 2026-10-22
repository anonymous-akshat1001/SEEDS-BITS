import 'package:flutter/material.dart';

import '../services/tts_service.dart';
import 'key_instruction_wrapper.dart';

class SimSuggestionDialog extends StatefulWidget {
  const SimSuggestionDialog({super.key, required this.options});
  final List<({String label, String number})> options;

  @override
  State<SimSuggestionDialog> createState() => _SimSuggestionDialogState();
}

class _SimSuggestionDialogState extends State<SimSuggestionDialog> {
  late final _nodes = List.generate(
    widget.options.length,
    (i) => FocusNode(debugLabel: 'sim-suggestion-$i'),
  );
  final _cancel = FocusNode(debugLabel: 'sim-suggestion-cancel');

  bool _valid(int i) => RegExp(r'^\d{10}$').hasMatch(widget.options[i].number);
  String _label(int i) =>
      '${widget.options[i].label}. ${_valid(i) ? 'Phone number ${widget.options[i].number.split('').join(' ')}. Press OK to fill the phone field.' : 'Number unavailable. Enter the phone number manually.'}';

  void _select(int i) {
    if (_valid(i)) {
      Navigator.pop(context, widget.options[i].number);
    } else {
      TtsService.speak(
        'This SIM does not provide a valid phone-number suggestion. Manual entry still works.',
      );
    }
  }

  @override
  void dispose() {
    for (final node in _nodes) {
      node.dispose();
    }
    _cancel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => KeypadInstructionWrapper(
    screenName:
        'Choose an optional SIM suggestion. Use up and down to review each SIM, then OK to select. This is not account verification.',
    labels: const {0: 'Cancel without changing the phone number'},
    actions: {0: () => Navigator.pop(context)},
    focusTargets: [
      for (var i = 0; i < widget.options.length; i++)
        KeypadFocusTarget(
          node: _nodes[i],
          label: _label(i),
          onActivate: () => _select(i),
        ),
      KeypadFocusTarget(
        node: _cancel,
        label: 'Cancel without changing the phone number',
        onActivate: () => Navigator.pop(context),
      ),
    ],
    child: AlertDialog(
      insetPadding: const EdgeInsets.all(8),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Choose SIM suggestion',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const Text(
              'Selecting fills the phone field only. Your password is still required. Cancel keeps manual entry unchanged.',
            ),
            for (var i = 0; i < widget.options.length; i++)
              TextButton(
                focusNode: _nodes[i],
                onPressed: () => _select(i),
                child: Text(_label(i)),
              ),
            TextButton(
              focusNode: _cancel,
              onPressed: () => Navigator.pop(context),
              child: const Text('0: Cancel'),
            ),
          ],
        ),
      ),
    ),
  );
}
