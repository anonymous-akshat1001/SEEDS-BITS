// lib/widgets/chat_panel.dart
import 'package:flutter/material.dart';
import '../services/tts_service.dart';
import '../services/sse_service.dart';
import '../utils/ui_utils.dart';

class ChatPanel extends StatefulWidget {
  final SseService ws; // ← type changed from WsService
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
  final _readFocus = FocusNode(debugLabel: 'chat-read-latest');
  bool _sending = false;

  void _readLatest() {
    if (messages.isEmpty) {
      TtsService.speak('No messages yet.');
    } else {
      final message = messages.last;
      final delivery = message['delivery'];
      TtsService.speak(
        '${message['from']}: ${message['text']}'
        '${delivery == null ? '' : '\nDelivery status: $delivery.'}',
      );
    }
  }

  Future<void> _sendText() async {
    if (_sending) {
      TtsService.speak('Waiting for message confirmation.');
      return;
    }
    final txt = _ctrl.text.trim();
    if (txt.isEmpty) {
      TtsService.speak('Enter a message before selecting Send.');
      return;
    }
    final message = {'from': 'me', 'text': txt, 'delivery': 'Sending'};
    setState(() {
      _sending = true;
      messages.add(message);
    });
    final result = await widget.ws.send({'type': 'chat', 'text': txt});
    if (!mounted) return;
    setState(() {
      _sending = false;
      message['delivery'] = result.isSuccess ? 'Sent' : 'Not confirmed';
    });
    if (result.isSuccess) {
      if (_ctrl.text.trim() == txt) _ctrl.clear();
      TtsService.speak('Message sent.');
    } else {
      final error = result.failure!.message;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      TtsService.speak(error, priority: SpeechPriority.critical);
    }
  }

  void onReceive(Map<String, dynamic> msg) {
    if (!mounted || msg['is_own'] == true) return;
    if (msg['type'] == 'chat') {
      final text = msg['text'] ?? msg['message'] ?? '';
      final from =
          msg['sender_name'] ?? msg['participant_id']?.toString() ?? 'unknown';
      if (text.toString().isEmpty) return;
      setState(() => messages.add({'from': from, 'text': text.toString()}));
      TtsService.speak(
        'New chat messages.',
        priority: SpeechPriority.incidental,
        group: 'New chat messages',
      );
    }
  }

  @override
  void initState() {
    super.initState();
    TtsService.registerLiveSession(this);
    widget.ws.registerChatHandler(onReceive);
  }

  @override
  void dispose() {
    TtsService.unregisterLiveSession(this);
    widget.ws.unregisterChatHandler(onReceive);
    _readFocus.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: UIUtils.scale(context) * 260,
      color: UIUtils.cardColor,
      padding: UIUtils.paddingAll(context, 6),
      child: Column(
        children: [
          Focus(
            canRequestFocus: false,
            onFocusChange: (focused) {
              if (focused) {
                TtsService.speak(
                  'Read latest message',
                  priority: SpeechPriority.navigation,
                );
              }
            },
            child: IconButton(
              focusNode: _readFocus,
              tooltip: 'Read latest message',
              onPressed: _readLatest,
              icon: const Icon(Icons.mark_chat_read_outlined),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (_, i) {
                final m = messages[i];
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
                      '${m['text'] ?? ''}${m['delivery'] == null ? '' : '\n${m['delivery']}'}',
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
                    hintStyle: TextStyle(
                      fontSize: UIUtils.fontSize(context, 12),
                    ),
                    isDense: true,
                    contentPadding: UIUtils.paddingSymmetric(
                      context,
                      horizontal: 8,
                      vertical: 6,
                    ),
                  ),
                  onSubmitted: (_) => _sendText(),
                ),
              ),
              IconButton(
                onPressed: _sending ? null : _sendText,
                icon: Icon(Icons.send, size: UIUtils.iconSize(context, 18)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
