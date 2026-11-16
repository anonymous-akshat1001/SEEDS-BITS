import 'package:flutter/material.dart';

import '../l10n/speech.dart';
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
    String? cancelLabel,
    this.cancelKey = 1,
    this.confirmKey = 2,
  }) : _cancelLabel = cancelLabel;

  final String title;
  final String message;
  final String confirmLabel;
  final String? _cancelLabel;

  /// "Not now" unless the caller names the cancel choice.
  String get cancelLabel => _cancelLabel ?? Speech.t.uiNotNow;
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
      screenName: '${widget.title}. ${widget.message}',
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
        scrollable: true,
        title: Text(widget.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              liveRegion: true,
              child: Text(
                widget.message,
                style: TextStyle(color: UIUtils.textColor, fontSize: 18),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              focusNode: _cancelFocus,
              onPressed: () => close(false),
              child: Text('${widget.cancelKey}: ${widget.cancelLabel}'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              focusNode: _confirmFocus,
              onPressed: () => close(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: UIUtils.primaryColor,
                foregroundColor: UIUtils.onPrimaryColor,
              ),
              child: Text('${widget.confirmKey}: ${widget.confirmLabel}'),
            ),
          ],
        ),
      ),
    );
  }
}
