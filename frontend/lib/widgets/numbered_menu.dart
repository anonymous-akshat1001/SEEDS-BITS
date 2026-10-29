import 'dart:async';

import 'package:flutter/material.dart';

import '../services/tts_service.dart';
import 'key_instruction_wrapper.dart';

class NumberedChoice {
  const NumberedChoice({
    required this.label,
    required this.onSelected,
    this.enabled = true,
  });

  final String label;
  final VoidCallback onSelected;
  final bool enabled;
}

class NumberedMenu extends StatefulWidget {
  NumberedMenu({
    super.key,
    required this.title,
    required this.choices,
    this.message,
    this.onBack,
    this.isHome = false,
    this.autoPlay = true,
  }) {
    if (choices.length > 5) {
      throw ArgumentError('A numbered menu supports at most five choices.');
    }
  }

  final String title;
  final List<NumberedChoice> choices;
  final String? message;
  final VoidCallback? onBack;
  final bool isHome;
  final bool autoPlay;

  @override
  State<NumberedMenu> createState() => _NumberedMenuState();
}

class _NumberedMenuState extends State<NumberedMenu> {
  final _nodes = List.generate(
    5,
    (index) => FocusNode(debugLabel: 'numbered-choice-${index + 1}'),
  );
  final _backNode = FocusNode(debugLabel: 'numbered-back');

  void _back() {
    if (widget.onBack != null) {
      widget.onBack!();
    } else if (widget.isHome) {
      unawaited(TtsService.speak('You are already home.'));
    } else {
      unawaited(Navigator.of(context).maybePop());
    }
  }

  void _select(int index) {
    final choice = widget.choices[index];
    if (choice.enabled) {
      choice.onSelected();
    } else {
      unawaited(
        TtsService.speak('${choice.label} is not available right now.'),
      );
    }
  }

  @override
  void dispose() {
    for (final node in [..._nodes, _backNode]) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => KeypadInstructionWrapper(
    interactionPolicy: KeypadInteractionPolicy.numbered,
    screenName: widget.title,
    autoPlay: widget.autoPlay,
    labels: {
      for (var index = 0; index < widget.choices.length; index++)
        index + 1:
            '${widget.choices[index].label}${widget.choices[index].enabled ? '' : ', unavailable'}',
    },
    actions: {
      0: _back,
      for (var index = 0; index < widget.choices.length; index++)
        index + 1: () => _select(index),
    },
    focusTargets: [
      for (var index = 0; index < widget.choices.length; index++)
        KeypadFocusTarget(
          node: _nodes[index],
          label: widget.choices[index].label,
          onActivate: () => _select(index),
          isEnabled: () => widget.choices[index].enabled,
        ),
      KeypadFocusTarget(node: _backNode, label: 'Back', onActivate: _back),
    ],
    child: Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                header: true,
                child: Text(
                  widget.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              if (widget.message != null) Text(widget.message!),
              for (var index = 0; index < widget.choices.length; index++)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: ElevatedButton(
                    focusNode: _nodes[index],
                    onPressed: widget.choices[index].enabled
                        ? () => _select(index)
                        : null,
                    child: Text('${index + 1}: ${widget.choices[index].label}'),
                  ),
                ),
              TextButton(
                focusNode: _backNode,
                onPressed: _back,
                child: const Text('0: Back'),
              ),
              const Text('*: Help. #: Stop app speech.'),
            ],
          ),
        ),
      ),
    ),
  );
}
