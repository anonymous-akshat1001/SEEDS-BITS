import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
import '../services/api_service.dart';

/// Simplified UI optimized for button/keypad phones and low-resolution screens
/// Focuses on essential controls with large buttons
class SimpleSessionScreen extends StatefulWidget {
  final int sessionId;
  final int userId;
  final String userName;
  final bool isTeacher;

  const SimpleSessionScreen({
    super.key,
    required this.sessionId,
    required this.userId,
    required this.userName,
    this.isTeacher = false,
  });

  @override
  State<SimpleSessionScreen> createState() => _SimpleSessionScreenState();
}

class _SimpleSessionScreenState extends State<SimpleSessionScreen> {
  final FlutterTts _tts = FlutterTts();
  
  WebSocketChannel? _wsChannel;
  bool _muted = false;
  bool _handRaised = false;
  bool _ttsEnabled = true;
  String _statusText = "Connecting...";
  String _currentSpeaker = "None";
  int _participantCount = 0;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _joinSession();
    await _connectWebSocket();
    await _speak("Connected to session ${widget.sessionId}");
  }

  Future<void> _joinSession() async {
    try {
      await ApiService.joinSession(widget.sessionId);
      setState(() => _statusText = "Joined session");
    } catch (e) {
      setState(() => _statusText = "Failed to join");
      print('[JOIN ERROR] $e');
    }
  }

  Future<void> _connectWebSocket() async {
    try {
      final wsUrl = 'ws://127.0.0.1:8000/ws/sessions/${widget.sessionId}?user_id=${widget.userId}';
      _wsChannel = WebSocketChannel.connect(Uri.parse(wsUrl));
      
      _wsChannel!.stream.listen(
        (message) => _handleWebSocketMessage(message),
        onError: (error) => _reconnect(),
        onDone: () => _reconnect(),
      );
      
      setState(() => _statusText = "Connected");
    } catch (e) {
      setState(() => _statusText = "Connection failed");
      Future.delayed(const Duration(seconds: 3), _reconnect);
    }
  }

  Future<void> _reconnect() async {
    if (!mounted) return;
    setState(() => _statusText = "Reconnecting...");
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) await _connectWebSocket();
  }

  void _sendMessage(Map<String, dynamic> message) {
    try {
      _wsChannel?.sink.add(jsonEncode(message));
    } catch (e) {
      print('[WS SEND ERROR] $e');
    }
  }

  void _handleWebSocketMessage(dynamic message) {
    try {
      final data = jsonDecode(message);
      final type = data['type'];

      switch (type) {
        case 'session_state':
          final participants = data['participants'] as Map<String, dynamic>? ?? {};
          setState(() => _participantCount = participants.length);
          _speak("${participants.length} participants in session");
          break;
          
        case 'participant_joined':
          final name = data['name'] ?? 'Someone';
          setState(() {
            _participantCount++;
            _currentSpeaker = name;
          });
          _speak("$name joined");
          break;
          
        case 'participant_left':
          setState(() => _participantCount--);
          _speak("Someone left");
          break;
          
        case 'chat':
          final sender = data['sender_name'] ?? 'Someone';
          final text = data['text'] ?? '';
          _speak("$sender says: $text");
          break;
          
        case 'kicked':
          _speak("You have been removed");
          Navigator.pop(context);
          break;
          
        case 'session_ended':
          _speak("Session ended");
          Navigator.pop(context);
          break;
      }
    } catch (e) {
      print('[WS PARSE ERROR] $e');
    }
  }

  Future<void> _speak(String text) async {
    if (_ttsEnabled) {
      try {
        await _tts.speak(text);
      } catch (e) {
        print('[TTS ERROR] $e');
      }
    }
  }

  // Action handlers
  void _toggleMute() {
    setState(() => _muted = !_muted);
    _sendMessage({'type': 'mute_self', 'mute': _muted});
    _speak(_muted ? "Muted" : "Unmuted");
  }

  void _toggleHand() {
    setState(() => _handRaised = !_handRaised);
    _sendMessage({'type': _handRaised ? 'raise_hand' : 'lower_hand'});
    _speak(_handRaised ? "Hand raised" : "Hand lowered");
  }

  void _toggleTTS() {
    setState(() => _ttsEnabled = !_ttsEnabled);
    _speak(_ttsEnabled ? "TTS on" : "TTS off");
  }

  void _leave() {
    _speak("Leaving");
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _wsChannel?.sink.close();
    _tts.stop();
    super.dispose();
  }

  Widget _buildBigButton({
    required String label,
    required VoidCallback onPressed,
    required IconData icon,
    Color? color,
    bool isActive = false,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive 
            ? Colors.orange 
            : (color ?? Colors.teal),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 4,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Session ${widget.sessionId}',
          style: const TextStyle(fontSize: 20),
        ),
        backgroundColor: Colors.grey.shade900,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Status bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: Colors.grey.shade900,
            child: Column(
              children: [
                Text(
                  _statusText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Participants: $_participantCount',
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 18,
                  ),
                ),
                if (_currentSpeaker != "None") ...[
                  const SizedBox(height: 8),
                  Text(
                    'Speaking: $_currentSpeaker',
                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontSize: 16,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Large mic indicator
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: _muted ? Colors.red : Colors.green,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _muted ? Icons.mic_off : Icons.mic,
              size: 70,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(height: 16),
          
          Text(
            _muted ? 'MUTED' : 'LIVE',
            style: TextStyle(
              color: _muted ? Colors.red : Colors.green,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Button grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                childAspectRatio: 1.1,
                children: [
                  _buildBigButton(
                    label: _muted ? 'Unmute' : 'Mute',
                    icon: _muted ? Icons.mic : Icons.mic_off,
                    onPressed: _toggleMute,
                    color: _muted ? Colors.green : Colors.red,
                    isActive: !_muted,
                  ),
                  _buildBigButton(
                    label: _handRaised ? 'Lower Hand' : 'Raise Hand',
                    icon: _handRaised ? Icons.pan_tool : Icons.pan_tool_outlined,
                    onPressed: _toggleHand,
                    color: Colors.amber,
                    isActive: _handRaised,
                  ),
                  _buildBigButton(
                    label: 'Toggle TTS',
                    icon: _ttsEnabled ? Icons.volume_up : Icons.volume_off,
                    onPressed: _toggleTTS,
                    color: Colors.blue,
                    isActive: _ttsEnabled,
                  ),
                  _buildBigButton(
                    label: 'Leave',
                    icon: Icons.call_end,
                    onPressed: _leave,
                    color: Colors.red.shade700,
                  ),
                ],
              ),
            ),
          ),
          
          // Info footer
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade900,
            child: Text(
              'Tap buttons or use touch',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}