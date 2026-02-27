// lib/widgets/participant_tile.dart
import 'package:flutter/material.dart';
import '../utils/ui_utils.dart';

class ParticipantTile extends StatefulWidget {
  final String name;
  final bool isMuted;
  final bool raisedHand;
  final bool isTeacherView;
  final VoidCallback? onMute;
  final VoidCallback? onKick;
  final Widget? remoteAudioWidget;
  final double? micLevel; // Optional mic level for visualization (0.0 to 1.0)

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
  });

  @override
  State<ParticipantTile> createState() => _ParticipantTileState();
}

class _ParticipantTileState extends State<ParticipantTile> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _showingConfirmKick = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _handleKickConfirmation() async {
    if (_showingConfirmKick) return;

    setState(() => _showingConfirmKick = true);

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        title: Text(
          "Confirm Removal",
          style: TextStyle(fontSize: UIUtils.fontSize(context, 16), fontWeight: FontWeight.bold),
        ),
        content: Text(
          "Remove ${widget.name}?",
          style: TextStyle(fontSize: UIUtils.fontSize(context, 13)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancel", style: TextStyle(fontSize: UIUtils.fontSize(context, 13))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text("Remove", style: TextStyle(fontSize: UIUtils.fontSize(context, 13))),
          ),
        ],
      ),
    );

    setState(() => _showingConfirmKick = false);

    if (confirmed == true) {
      widget.onKick?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool tiny = UIUtils.isTiny(context);
    final semanticLabel = '${widget.name}. '
        '${widget.isMuted ? "Muted" : "Unmuted"}. '
        '${widget.raisedHand ? "Hand raised" : "Hand not raised"}. '
        '${widget.isTeacherView ? "Double tap to see options" : ""}';

    return Semantics(
      label: semanticLabel,
      button: true,
      enabled: true,
      child: GestureDetector(
        onTap: () {
          final announcement = '${widget.name}, ${widget.isMuted ? "muted" : "unmuted"}';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(announcement, style: TextStyle(fontSize: UIUtils.fontSize(context, 12))),
              duration: const Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        onLongPress: widget.isTeacherView && widget.onKick != null 
            ? _handleKickConfirmation 
            : null,
        child: Container(
          margin: UIUtils.paddingSymmetric(context, horizontal: 6, vertical: 3),
          padding: UIUtils.paddingAll(context, 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade800,
            borderRadius: BorderRadius.circular(12),
            border: widget.raisedHand
                ? Border.all(color: Colors.amber, width: 2)
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  // Avatar with mic level visualization
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Pulsing circle for speaking indicator
                      if (!widget.isMuted && widget.micLevel != null && widget.micLevel! > 0.1)
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            final pulseSize = 40 * UIUtils.scale(context);
                            return Container(
                              height: pulseSize + (14 * _pulseController.value),
                              width: pulseSize + (14 * _pulseController.value),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.greenAccent.withOpacity(0.3 * (1 - _pulseController.value)),
                              ),
                            );
                          },
                        ),
                      // Main avatar
                      CircleAvatar(
                        radius: UIUtils.iconSize(context, 18),
                        backgroundColor: widget.isMuted ? Colors.grey : Colors.teal,
                        child: Text(
                          widget.name.isNotEmpty ? widget.name[0].toUpperCase() : '?',
                          style: TextStyle(
                            fontSize: UIUtils.fontSize(context, 16),
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      // Mute indicator overlay
                      if (widget.isMuted)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: UIUtils.paddingAll(context, 2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1.5),
                            ),
                            child: Icon(
                              Icons.mic_off,
                              size: UIUtils.iconSize(context, 10),
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                  
                  SizedBox(width: UIUtils.spacing(context, 8)),
                  
                  // Name and status
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.name,
                          style: TextStyle(
                            fontSize: UIUtils.fontSize(context, 14),
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (!tiny) ...[
                          SizedBox(height: UIUtils.spacing(context, 2)),
                          Row(
                            children: [
                              Icon(
                                widget.isMuted ? Icons.mic_off : Icons.mic,
                                size: UIUtils.iconSize(context, 12),
                                color: widget.isMuted ? Colors.red : Colors.green,
                              ),
                              SizedBox(width: UIUtils.spacing(context, 3)),
                              Text(
                                widget.isMuted ? 'Muted' : 'Active',
                                style: TextStyle(
                                  fontSize: UIUtils.fontSize(context, 11),
                                  color: widget.isMuted ? Colors.red.shade300 : Colors.green.shade300,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  // Raised hand indicator
                  if (widget.raisedHand)
                    Padding(
                      padding: EdgeInsets.only(right: UIUtils.spacing(context, 4)),
                      child: Semantics(
                        label: 'Hand raised',
                        child: AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: 1.0 + (0.2 * _pulseController.value),
                              child: Icon(
                                Icons.pan_tool,
                                color: Colors.amber,
                                size: UIUtils.iconSize(context, 22),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  
                  // Mute button (always visible for teacher)
                  if (widget.onMute != null)
                    Semantics(
                      label: widget.isMuted ? 'Unmute participant' : 'Mute participant',
                      button: true,
                      child: IconButton(
                        onPressed: widget.onMute,
                        icon: Icon(
                          widget.isMuted ? Icons.mic_off : Icons.mic,
                          color: widget.isMuted ? Colors.red.shade300 : Colors.green.shade300,
                        ),
                        iconSize: UIUtils.iconSize(context, 20),
                        tooltip: widget.isMuted ? 'Unmute' : 'Mute',
                        splashRadius: UIUtils.iconSize(context, 18),
                        constraints: BoxConstraints(
                          minWidth: UIUtils.iconSize(context, 28),
                          minHeight: UIUtils.iconSize(context, 28),
                        ),
                      ),
                    ),
                  
                  // Kick button (teacher only)
                  if (widget.isTeacherView && widget.onKick != null)
                    Semantics(
                      label: 'Remove participant',
                      button: true,
                      child: IconButton(
                        onPressed: _handleKickConfirmation,
                        icon: const Icon(
                          Icons.person_remove,
                          color: Colors.red,
                        ),
                        iconSize: UIUtils.iconSize(context, 20),
                        tooltip: 'Remove',
                        splashRadius: UIUtils.iconSize(context, 18),
                        constraints: BoxConstraints(
                          minWidth: UIUtils.iconSize(context, 28),
                          minHeight: UIUtils.iconSize(context, 28),
                        ),
                      ),
                    ),
                ],
              ),
              
              // Mic level visualizer (if provided)
              if (widget.micLevel != null && !widget.isMuted && !tiny)
                Padding(
                  padding: EdgeInsets.only(top: UIUtils.spacing(context, 6)),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: widget.micLevel,
                          backgroundColor: Colors.grey.shade700,
                          color: Colors.greenAccent,
                          minHeight: 4,
                        ),
                      ),
                      SizedBox(height: UIUtils.spacing(context, 2)),
                      Text(
                        'Mic Level',
                        style: TextStyle(
                          fontSize: UIUtils.fontSize(context, 8),
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
              
              // Remote audio widget placeholder
              if (widget.remoteAudioWidget != null)
                Padding(
                  padding: EdgeInsets.only(top: UIUtils.spacing(context, 4)),
                  child: widget.remoteAudioWidget,
                ),
            ],
          ),
        ),
      ),
    );
  }
}