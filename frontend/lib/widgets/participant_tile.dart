// lib/widgets/participant_tile.dart
import 'package:flutter/material.dart';
import '../utils/ui_utils.dart';
import 'keypad_confirmation_dialog.dart';

/// One participant: a read-only status summary followed, when callbacks are
/// provided, by separate labelled "Mute <name>" and "Remove <name>" buttons.
class ParticipantTile extends StatefulWidget {
  final String name;
  final bool isMuted;
  final bool raisedHand;
  final bool isTeacherView;
  final VoidCallback? onMute;
  final VoidCallback? onKick;
  final Widget? remoteAudioWidget;
  final double? micLevel; // Optional mic level for visualization (0.0 to 1.0)
  final bool? isSpeaking; // Overrides the micLevel-based speaking estimate.

  const ParticipantTile({
    super.key,
    required this.name,
    required this.isMuted,
    required this.raisedHand,
    this.isTeacherView = false,
    this.onMute,
    this.onKick,
    this.remoteAudioWidget,
    this.micLevel,
    this.isSpeaking,
  });

  @override
  State<ParticipantTile> createState() => _ParticipantTileState();
}

class _ParticipantTileState extends State<ParticipantTile> {
  final _removeFocus = FocusNode(debugLabel: 'participant-tile-remove');
  bool _confirmingRemoval = false;

  bool get _speaking =>
      widget.isSpeaking ??
      (!widget.isMuted && (widget.micLevel ?? 0) > 0.1);

  /// "Asha, hand raised, muted, speaking" — most important word first.
  String get _summary => [
    widget.name,
    if (widget.raisedHand) 'hand raised',
    widget.isMuted ? 'muted' : 'unmuted',
    if (_speaking) 'speaking',
  ].join(', ');

  @override
  void dispose() {
    _removeFocus.dispose();
    super.dispose();
  }

  Future<void> _confirmRemoval() async {
    if (_confirmingRemoval || widget.onKick == null) return;
    _confirmingRemoval = true;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => KeypadConfirmationDialog(
        title: 'Remove ${widget.name}?',
        message:
            '${widget.name} will be removed from this session and returned '
            'to their dashboard.',
        cancelLabel: 'Keep ${widget.name}',
        confirmLabel: 'Remove ${widget.name}',
      ),
    );
    _confirmingRemoval = false;
    if (!mounted) return;
    if (confirmed == true) {
      widget.onKick?.call();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _removeFocus.canRequestFocus) {
          _removeFocus.requestFocus();
        }
      });
    }
  }

  Widget _button({
    required IconData icon,
    required String text,
    required String semanticLabel,
    required VoidCallback onPressed,
    required bool fullWidth,
    Color? iconColor,
    FocusNode? focusNode,
  }) {
    final button = OutlinedButton.icon(
      focusNode: focusNode,
      onPressed: onPressed,
      icon: Icon(
        icon,
        color: iconColor ?? UIUtils.textColor,
        size: UIUtils.iconSize(context, 20),
      ),
      label: Semantics(
        label: semanticLabel,
        child: ExcludeSemantics(
          child: Text(
            text,
            style: TextStyle(
              color: UIUtils.textColor,
              fontSize: UIUtils.fontSize(context, 14),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: UIUtils.textColor,
        backgroundColor: UIUtils.cardColor,
        side: BorderSide(color: UIUtils.cardBorderColor),
        minimumSize: const Size(48, 44),
        alignment: fullWidth ? Alignment.centerLeft : Alignment.center,
        padding: UIUtils.paddingSymmetric(context, horizontal: 8, vertical: 6),
      ),
    );
    return fullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }

  @override
  Widget build(BuildContext context) {
    final stacked = UIUtils.isTiny(context) || UIUtils.useStackedLayout(context);
    final statusWords = [
      widget.isMuted ? 'Muted' : 'Unmuted',
      if (widget.raisedHand) 'Hand raised',
      if (_speaking) 'Speaking',
    ].join(' · ');
    final buttons = <Widget>[
      if (widget.onMute != null)
        _button(
          icon: widget.isMuted ? Icons.mic : Icons.mic_off,
          text: widget.isMuted ? 'Unmute ${widget.name}' : 'Mute ${widget.name}',
          semanticLabel: widget.isMuted
              ? 'Unmute ${widget.name}'
              : 'Mute ${widget.name}',
          onPressed: widget.onMute!,
          fullWidth: stacked,
        ),
      if (widget.isTeacherView && widget.onKick != null)
        _button(
          focusNode: _removeFocus,
          icon: Icons.person_remove,
          text: 'Remove ${widget.name}',
          semanticLabel: 'Remove ${widget.name} from session',
          onPressed: _confirmRemoval,
          fullWidth: stacked,
          iconColor: UIUtils.errorColor,
        ),
    ];

    return Container(
      margin: UIUtils.paddingSymmetric(context, horizontal: 6, vertical: 3),
      padding: UIUtils.paddingAll(context, 8),
      decoration: BoxDecoration(
        color: UIUtils.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: widget.raisedHand
              ? UIUtils.accentColor
              : UIUtils.cardBorderColor,
          width: widget.raisedHand ? 3 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            container: true,
            label: _summary,
            child: ExcludeSemantics(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    widget.raisedHand
                        ? Icons.pan_tool
                        : widget.isMuted
                        ? Icons.mic_off
                        : Icons.mic,
                    color: widget.raisedHand
                        ? UIUtils.accentColor
                        : widget.isMuted
                        ? UIUtils.errorColor
                        : UIUtils.successColor,
                    size: UIUtils.iconSize(context, 22),
                  ),
                  SizedBox(width: UIUtils.spacing(context, 8)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.name,
                          style: TextStyle(
                            fontSize: UIUtils.fontSize(context, 16),
                            fontWeight: FontWeight.bold,
                            color: UIUtils.textColor,
                          ),
                        ),
                        Text(
                          statusWords,
                          style: TextStyle(
                            fontSize: UIUtils.fontSize(context, 14),
                            color: UIUtils.subtextColor,
                          ),
                        ),
                        if (widget.micLevel != null && !widget.isMuted)
                          Padding(
                            padding: EdgeInsets.only(
                              top: UIUtils.spacing(context, 4),
                            ),
                            child: LinearProgressIndicator(
                              value: widget.micLevel!.clamp(0.0, 1.0),
                              backgroundColor: UIUtils.cardBorderColor,
                              color: UIUtils.successColor,
                              minHeight: 4,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (buttons.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: UIUtils.spacing(context, 6)),
              child: stacked
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final button in buttons)
                          Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: UIUtils.spacing(context, 2),
                            ),
                            child: button,
                          ),
                      ],
                    )
                  : Wrap(
                      spacing: UIUtils.spacing(context, 6),
                      runSpacing: UIUtils.spacing(context, 6),
                      children: buttons,
                    ),
            ),
          if (widget.remoteAudioWidget != null)
            Padding(
              padding: EdgeInsets.only(top: UIUtils.spacing(context, 4)),
              child: widget.remoteAudioWidget,
            ),
        ],
      ),
    );
  }
}
