import 'dart:async';

import 'package:flutter/material.dart';

import '../l10n/speech.dart';
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
      unawaited(TtsService.speak(Speech.t.uiWaitingConfirmation));
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
      _report(Speech.t.uiFinishWord);
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
      _report(Speech.t.uiStepFailed);
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
        _visible ? Speech.t.uiPasswordVisible : Speech.t.uiPasswordHidden,
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
  Widget build(BuildContext context) {
    final t = Speech.t;
    return KeypadInstructionWrapper(
      interactionPolicy: KeypadInteractionPolicy.numbered,
      initialFocusNode: _input,
      screenName: t.uiTextStepScreen(widget.title, widget.label),
      labels: {
        1: t.uiContinue,
        if (widget.obscureText) 2: t.uiShowOrHidePassword,
      },
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
          label: t.uiContinue,
          onActivate: () => unawaited(_submit()),
          isEnabled: () => !_busy,
        ),
        if (widget.obscureText)
          KeypadFocusTarget(
            node: _visibility,
            label: t.uiShowOrHidePassword,
            onActivate: _toggleVisibility,
          ),
        KeypadFocusTarget(node: _backNode, label: t.uiBack, onActivate: _back),
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
                Text(Speech.t.keypadTextEditingHint),
                if (_error != null)
                  Semantics(liveRegion: true, child: Text(_error!)),
                if (_busy) Text(Speech.t.keypadWaitingConfirmation),
                ElevatedButton(
                  focusNode: _continue,
                  onPressed: _busy ? null : () => unawaited(_submit()),
                  child: Text(Speech.t.keypadContinueKey1),
                ),
                if (widget.obscureText)
                  TextButton(
                    focusNode: _visibility,
                    onPressed: _toggleVisibility,
                    child: Text(
                      _visible
                          ? Speech.t.keypadHidePasswordKey2
                          : Speech.t.keypadShowPasswordKey2,
                    ),
                  ),
                TextButton(
                  focusNode: _backNode,
                  onPressed: _busy ? null : _back,
                  child: Text(Speech.t.keypadBackKey0),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
