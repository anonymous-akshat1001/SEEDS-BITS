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
      ScaffoldMessenger.of(context).showSnackBar(
        // Spoken below; excluded so TalkBack does not read it twice.
        SnackBar(content: ExcludeSemantics(child: Text(error))),
      );
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
      // Incidental: batched and deferred while live audio is active.
      TtsService.speak(
        'Message from $from: $text',
        priority: SpeechPriority.incidental,
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
    final textSize = UIUtils.fontSize(context, 16);
    // Fills the space it is given instead of a fixed width, so it never
    // overflows a 240 px keypad-phone screen.
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: Container(
        decoration: BoxDecoration(
          color: UIUtils.cardColor,
          border: Border.all(color: UIUtils.cardBorderColor, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: UIUtils.paddingAll(context, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
              child: OutlinedButton.icon(
                focusNode: _readFocus,
                onPressed: _readLatest,
                icon: const Icon(Icons.mark_chat_read_outlined),
                label: const Text('Read latest message'),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: messages.length,
                itemBuilder: (_, i) {
                  final m = messages[i];
                  final me = m['from'] == 'me';
                  final delivery = m['delivery'];
                  return Semantics(
                    label:
                        '${me ? 'You said' : '${m['from']} said'}: ${m['text'] ?? ''}'
                        '${delivery == null ? '' : '. $delivery'}',
                    excludeSemantics: true,
                    child: Align(
                      alignment: me
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: UIUtils.paddingSymmetric(context, vertical: 3),
                        padding: UIUtils.paddingAll(context, 8),
                        decoration: BoxDecoration(
                          color: me
                              ? UIUtils.accentColor
                              : UIUtils.backgroundColor,
                          border: Border.all(
                            color: UIUtils.cardBorderColor,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!me)
                              Text(
                                '${m['from']}',
                                style: TextStyle(
                                  color: UIUtils.subtextColor,
                                  fontSize: UIUtils.fontSize(context, 14),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            Text(
                              '${m['text'] ?? ''}${delivery == null ? '' : '\n$delivery'}',
                              style: TextStyle(
                                color: me
                                    ? UIUtils.onAccentColor
                                    : UIUtils.textColor,
                                fontSize: textSize,
                              ),
                            ),
                          ],
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
                    style: TextStyle(fontSize: textSize),
                    decoration: InputDecoration(
                      labelText: 'Chat message',
                      contentPadding: UIUtils.paddingSymmetric(
                        context,
                        horizontal: 8,
                        vertical: 8,
                      ),
                    ),
                    onSubmitted: (_) => _sendText(),
                  ),
                ),
                IconButton(
                  tooltip: 'Send message',
                  onPressed: _sending ? null : _sendText,
                  icon: Icon(Icons.send, size: UIUtils.iconSize(context, 24)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
