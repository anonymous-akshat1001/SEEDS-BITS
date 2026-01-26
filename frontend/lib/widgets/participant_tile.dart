// lib/widgets/participant_tile.dart
import 'package:flutter/material.dart';

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
        title: const Text(
          "Confirm Removal",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        content: Text(
          "Are you sure you want to remove ${widget.name} from this session?",
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel", style: TextStyle(fontSize: 16)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text("Remove", style: TextStyle(fontSize: 16)),
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
          // Announce current state when tapped
          final announcement = '${widget.name}, ${widget.isMuted ? "muted" : "unmuted"}';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(announcement),
              duration: const Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        onLongPress: widget.isTeacherView && widget.onKick != null 
            ? _handleKickConfirmation 
            : null,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade800,
            borderRadius: BorderRadius.circular(16),
            border: widget.raisedHand
                ? Border.all(color: Colors.amber, width: 3)
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
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
                            return Container(
                              height: 60 + (20 * _pulseController.value),
                              width: 60 + (20 * _pulseController.value),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.greenAccent.withOpacity(0.3 * (1 - _pulseController.value)),
                              ),
                            );
                          },
                        ),
                      // Main avatar
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: widget.isMuted ? Colors.grey : Colors.teal,
                        child: Text(
                          widget.name.isNotEmpty ? widget.name[0].toUpperCase() : '?',
                          style: const TextStyle(
                            fontSize: 24,
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
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.mic_off,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Name and status
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              widget.isMuted ? Icons.mic_off : Icons.mic,
                              size: 16,
                              color: widget.isMuted ? Colors.red : Colors.green,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              widget.isMuted ? 'Muted' : 'Active',
                              style: TextStyle(
                                fontSize: 14,
                                color: widget.isMuted ? Colors.red.shade300 : Colors.green.shade300,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Raised hand indicator
                  if (widget.raisedHand)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Semantics(
                        label: 'Hand raised',
                        child: AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: 1.0 + (0.2 * _pulseController.value),
                              child: const Icon(
                                Icons.pan_tool,
                                color: Colors.amber,
                                size: 32,
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
                        iconSize: 28,
                        tooltip: widget.isMuted ? 'Unmute' : 'Mute',
                        splashRadius: 24,
                      ),
                    ),
                  
                  // Kick button (teacher only, with long-press protection)
                  if (widget.isTeacherView && widget.onKick != null)
                    Semantics(
                      label: 'Remove participant. Long press to confirm',
                      button: true,
                      child: IconButton(
                        onPressed: _handleKickConfirmation,
                        icon: const Icon(
                          Icons.person_remove,
                          color: Colors.red,
                        ),
                        iconSize: 28,
                        tooltip: 'Remove participant (Long press)',
                        splashRadius: 24,
                      ),
                    ),
                ],
              ),
              
              // Mic level visualizer (if provided)
              if (widget.micLevel != null && !widget.isMuted)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: widget.micLevel,
                          backgroundColor: Colors.grey.shade700,
                          color: Colors.greenAccent,
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Mic Level',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
              
              // Remote audio widget placeholder
              if (widget.remoteAudioWidget != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: widget.remoteAudioWidget,
                ),
            ],
          ),
        ),
      ),
    );
  }
}