// lib/widgets/chat_panel.dart
import 'package:flutter/material.dart';
import '../services/tts_service.dart';
import '../services/ws_service.dart';

class ChatPanel extends StatefulWidget {
  final WsService ws;
  final String sessionId;
  final String participantId;
  const ChatPanel({super.key, required this.ws, required this.sessionId, required this.participantId});

  @override
  State<ChatPanel> createState() => _ChatPanelState();
}

class _ChatPanelState extends State<ChatPanel> {
  final List<Map<String, String>> messages = [];
  final TextEditingController _ctrl = TextEditingController();

  void _sendText() {
    final txt = _ctrl.text.trim();
    if (txt.isEmpty) return;
    final payload = {
      'type': 'chat',
      'participant_id': int.parse(widget.participantId),
      'text': txt,
    };
    widget.ws.send(payload);
    setState(() => messages.add({'from': 'me', 'text': txt}));
    _ctrl.clear();
  }

  // Called by parent WS handler when a chat arrives
  void onReceive(Map msg) {
    if (msg['type'] == 'chat') {
      final text = msg['message'] ?? msg['text'] ?? '';
      final from = msg['participant_id']?.toString() ?? 'system';
      setState(() => messages.add({'from': from, 'text': text}));
      TtsService.speak(text);
    }
  }

  @override
  void initState() {
    super.initState();
    // attach the onReceive hook to ws (parent will call it too from session screen)
    widget.ws.registerChatHandler(onReceive);
  }

  @override
  void dispose() {
    widget.ws.unregisterChatHandler(onReceive);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      color: Colors.grey,
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (c, i) {
                final m = messages[i];
                final me = m['from'] == 'me';
                return Align(
                  alignment: me ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: me ? Colors.blue : Colors.grey.shade700,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(m['text'] ?? ''),
                  ),
                );
              },
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(controller: _ctrl, decoration: const InputDecoration(hintText: 'Message')),
              ),
              IconButton(onPressed: _sendText, icon: const Icon(Icons.send))
            ],
          )
        ],
      ),
    );
  }
}
