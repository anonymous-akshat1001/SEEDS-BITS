// lib/widgets/chat_panel.dart
import 'package:flutter/material.dart';
import '../services/tts_service.dart';
import '../services/sse_service.dart';
import '../utils/ui_utils.dart';

class ChatPanel extends StatefulWidget {
  final SseService ws;                   // ← type changed from WsService
  final String sessionId;
  final String participantId;

  const ChatPanel({
    super.key,
    required this.ws,
    required this.sessionId,
    required this.participantId,
  });

  @override
  State<ChatPanel> createState() => _ChatPanelState();
}

class _ChatPanelState extends State<ChatPanel> {
  final List<Map<String, String>> messages = [];
  final TextEditingController _ctrl = TextEditingController();

  void _sendText() {
    final txt = _ctrl.text.trim();
    if (txt.isEmpty) return;
    // SseService.send() mirrors WsService.send() — same Map signature
    widget.ws.send({'type': 'chat', 'text': txt});
    setState(() => messages.add({'from': 'me', 'text': txt}));
    _ctrl.clear();
  }

  // Called by SseService when a chat event arrives.
  // is_own=true messages are already skipped by SseService, so every
  // message that reaches here is from another participant.
  void onReceive(Map<String, dynamic> msg) {
    if (msg['type'] == 'chat') {
      final text = msg['text'] ?? msg['message'] ?? '';
      final from = msg['sender_name'] ??
                   msg['participant_id']?.toString() ??
                   'unknown';
      if (text.toString().isEmpty) return;
      setState(() => messages.add({'from': from, 'text': text.toString()}));
      TtsService.speak(text.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    widget.ws.registerChatHandler(onReceive);
  }

  @override
  void dispose() {
    widget.ws.unregisterChatHandler(onReceive);
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: UIUtils.scale(context) * 260,
      color: Colors.grey.shade100,
      padding: UIUtils.paddingAll(context, 6),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (_, i) {
                final m  = messages[i];
                final me = m['from'] == 'me';
                return Align(
                  alignment: me ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: UIUtils.paddingSymmetric(context, vertical: 2),
                    padding: UIUtils.paddingAll(context, 6),
                    decoration: BoxDecoration(
                      color: me ? Colors.teal.shade200 : Colors.grey.shade700,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      m['text'] ?? '',
                      style: TextStyle(
                        color: me ? Colors.black : Colors.white,
                        fontSize: UIUtils.fontSize(context, 12),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  style: TextStyle(fontSize: UIUtils.fontSize(context, 12)),
                  decoration: InputDecoration(
                    hintText: 'Message',
                    hintStyle: TextStyle(fontSize: UIUtils.fontSize(context, 12)),
                    isDense: true,
                    contentPadding: UIUtils.paddingSymmetric(context, horizontal: 8, vertical: 6),
                  ),
                  onSubmitted: (_) => _sendText(),
                ),
              ),
              IconButton(
                onPressed: _sendText,
                icon: Icon(Icons.send, size: UIUtils.iconSize(context, 18)),
              )
            ],
          ),
        ],
      ),
    );
  }
}
