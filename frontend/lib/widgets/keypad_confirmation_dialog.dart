import 'package:flutter/material.dart';

import '../utils/ui_utils.dart';
import 'key_instruction_wrapper.dart';

/// A two-choice dialog that is usable with touch, screen readers, and a
/// physical D-pad. Key 1 cancels and key 2 confirms.
class KeypadConfirmationDialog extends StatefulWidget {
  const KeypadConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    required this.confirmLabel,
    this.cancelLabel = 'Not now',
    this.cancelKey = 1,
    this.confirmKey = 2,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final int cancelKey;
  final int confirmKey;

  @override
  State<KeypadConfirmationDialog> createState() =>
      _KeypadConfirmationDialogState();
}

class _KeypadConfirmationDialogState extends State<KeypadConfirmationDialog> {
  final FocusNode _cancelFocus = FocusNode(debugLabel: 'dialog-cancel');
  final FocusNode _confirmFocus = FocusNode(debugLabel: 'dialog-confirm');

  @override
  void dispose() {
    _cancelFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    void close(bool confirmed) => Navigator.pop(context, confirmed);

    return KeypadInstructionWrapper(
      screenName: widget.title,
      labels: {
        widget.cancelKey: widget.cancelLabel,
        widget.confirmKey: widget.confirmLabel,
      },
      actions: {
        widget.cancelKey: () => close(false),
        widget.confirmKey: () => close(true),
      },
      focusTargets: [
        KeypadFocusTarget(
          node: _cancelFocus,
          label: widget.cancelLabel,
          onActivate: () => close(false),
        ),
        KeypadFocusTarget(
          node: _confirmFocus,
          label: widget.confirmLabel,
          onActivate: () => close(true),
        ),
      ],
      child: AlertDialog(
        title: Text(widget.title),
        content: Semantics(liveRegion: true, child: Text(widget.message)),
        actions: [
          TextButton(
            focusNode: _cancelFocus,
            onPressed: () => close(false),
            child: Text('${widget.cancelKey}: ${widget.cancelLabel}'),
          ),
          ElevatedButton(
            focusNode: _confirmFocus,
            onPressed: () => close(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: UIUtils.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: Text('${widget.confirmKey}: ${widget.confirmLabel}'),
          ),
        ],
      ),
    );
  }
}
