import 'package:flutter/material.dart';

import '../l10n/speech.dart';
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
  String _label(int i) => _valid(i)
      ? Speech.t.authSimOptionValid(
          widget.options[i].label,
          widget.options[i].number.split('').join(' '),
        )
      : Speech.t.authSimOptionInvalid(widget.options[i].label);

  void _select(int i) {
    if (_valid(i)) {
      Navigator.pop(context, widget.options[i].number);
    } else {
      TtsService.speak(Speech.t.authSimInvalidSuggestion);
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
    screenName: Speech.t.authSimChooseScreenName,
    labels: {0: Speech.t.authSimCancelLabel},
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
        label: Speech.t.authSimCancelLabel,
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
              Speech.t.authSimChooseTitle,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(Speech.t.authSimChooseInfo),
            for (var i = 0; i < widget.options.length; i++)
              TextButton(
                focusNode: _nodes[i],
                onPressed: () => _select(i),
                child: Text(_label(i)),
              ),
            TextButton(
              focusNode: _cancel,
              onPressed: () => Navigator.pop(context),
              child: Text(Speech.t.authSimCancelKey),
            ),
          ],
        ),
      ),
    ),
  );
}
