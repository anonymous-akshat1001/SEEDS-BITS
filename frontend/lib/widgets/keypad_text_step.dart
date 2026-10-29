import 'dart:async';

import 'package:flutter/material.dart';

import '../services/tts_service.dart';
import 'key_instruction_wrapper.dart';

class KeypadTextStep extends StatefulWidget {
  const KeypadTextStep({
    super.key,
    required this.title,
    required this.label,
    required this.controller,
    required this.onContinue,
    this.validate,
    this.onBack,
    this.obscureText = false,
    this.keyboardType,
  });

  final String title;
  final String label;
  final TextEditingController controller;
  final Future<void> Function(String) onContinue;
  final String? Function(String)? validate;
  final VoidCallback? onBack;
  final bool obscureText;
  final TextInputType? keyboardType;

  @override
  State<KeypadTextStep> createState() => _KeypadTextStepState();
}

class _KeypadTextStepState extends State<KeypadTextStep> {
  final _input = FocusNode(debugLabel: 'step-input');
  final _continue = FocusNode(debugLabel: 'step-continue');
  final _backNode = FocusNode(debugLabel: 'step-back');
  final _visibility = FocusNode(debugLabel: 'step-visibility');
  bool _busy = false;
  bool _visible = false;
  String? _error;

  void _back() {
    if (_busy) {
      unawaited(TtsService.speak('Waiting for confirmation. Please wait.'));
      return;
    }
    if (widget.onBack != null) {
      widget.onBack!();
    } else {
      unawaited(Navigator.of(context).maybePop());
    }
  }

  Future<void> _submit() async {
    if (_busy) return;
    if (!widget.controller.value.composing.isCollapsed) {
      _report('Finish entering the current word, then press OK.');
      return;
    }
    final error = widget.validate?.call(widget.controller.text);
    if (error != null) {
      _report(error);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.onContinue(widget.controller.text);
    } on Exception catch (error) {
      debugPrint('[INPUT STEP] Continue failed (${error.runtimeType}).');
      _report(
        'This step could not be completed. Your entry is kept. Try again.',
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _report(String message) {
    if (!mounted) return;
    setState(() => _error = message);
    unawaited(TtsService.speak(message, priority: SpeechPriority.critical));
  }

  void _toggleVisibility() {
    setState(() => _visible = !_visible);
    unawaited(
      TtsService.speak(
        _visible ? 'Password is visible.' : 'Password is hidden.',
      ),
    );
  }

  @override
  void dispose() {
    for (final node in [_input, _continue, _backNode, _visibility]) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => KeypadInstructionWrapper(
    interactionPolicy: KeypadInteractionPolicy.numbered,
    initialFocusNode: _input,
    screenName:
        '${widget.title}. ${widget.label}. Editing. Press OK to finish, or use up or down to leave the field.',
    labels: {1: 'Continue', if (widget.obscureText) 2: 'Show or hide password'},
    actions: {
      0: _back,
      1: () => unawaited(_submit()),
      if (widget.obscureText) 2: _toggleVisibility,
    },
    focusTargets: [
      KeypadFocusTarget(
        node: _input,
        label: widget.label,
        isTextField: true,
        isEnabled: () => !_busy,
      ),
      KeypadFocusTarget(
        node: _continue,
        label: 'Continue',
        onActivate: () => unawaited(_submit()),
        isEnabled: () => !_busy,
      ),
      if (widget.obscureText)
        KeypadFocusTarget(
          node: _visibility,
          label: 'Show or hide password',
          onActivate: _toggleVisibility,
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
              TextField(
                controller: widget.controller,
                focusNode: _input,
                enabled: !_busy,
                keyboardType: widget.keyboardType,
                obscureText: widget.obscureText && !_visible,
                autocorrect: !widget.obscureText,
                enableSuggestions: !widget.obscureText,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => unawaited(_submit()),
                decoration: InputDecoration(labelText: widget.label),
              ),
              const Text(
                'While editing, keys enter text. Press OK to finish. '
                'Use up or down if OK does not finish editing.',
              ),
              if (_error != null)
                Semantics(liveRegion: true, child: Text(_error!)),
              if (_busy) const Text('Waiting for confirmation.'),
              ElevatedButton(
                focusNode: _continue,
                onPressed: _busy ? null : () => unawaited(_submit()),
                child: const Text('1: Continue'),
              ),
              if (widget.obscureText)
                TextButton(
                  focusNode: _visibility,
                  onPressed: _toggleVisibility,
                  child: Text(
                    _visible ? '2: Hide password' : '2: Show password',
                  ),
                ),
              TextButton(
                focusNode: _backNode,
                onPressed: _busy ? null : _back,
                child: const Text('0: Back'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
