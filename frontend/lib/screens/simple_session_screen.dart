import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
import '../services/api_service.dart';
import '../services/tts_service.dart';
import '../utils/ui_utils.dart';
import '../widgets/key_instruction_wrapper.dart';
import '../utils/keypad_actions.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

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
  WebSocketChannel? _wsChannel;
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _muted = false;
  bool _handRaised = false;
  bool _ttsEnabled = true;
  bool _voiceCommandsEnabled = false;
  bool _voiceCommandsAvailable = false;
  String _statusText = "Connecting...";
  String _currentSpeaker = "None";
  int _participantCount = 0;
  
  // Audio state
  final AudioPlayer _sessionAudioPlayer = AudioPlayer();
  double _audioSpeed = 1.0;
  int? _currentAudioId;
  String? _currentAudioTitle;
  bool _isPlayingSessionAudio = false;
  double _currentPosition = 0.0;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadAccessibilitySettings();
    await _joinSession();
    await _connectWebSocket();
    await _speak("Connected to session ${widget.sessionId}");
    if (_voiceCommandsEnabled) {
      _startVoiceCommands();
    }
  }

  Future<void> _loadAccessibilitySettings() async {
    final prefs = await SharedPreferences.getInstance();
    final ttsEnabled = prefs.getBool('tts_enabled') ?? true;
    final voiceEnabled = prefs.getBool('voice_commands_enabled') ?? false;
    final volume = prefs.getDouble('tts_volume') ?? 1.0;
    final speechRate = prefs.getDouble('tts_speech_rate') ?? 0.5;

    await TtsService.configure(
      enabled: ttsEnabled,
      volume: volume,
      speechRate: speechRate,
    );

    if (!mounted) return;
    setState(() {
      _ttsEnabled = ttsEnabled;
      _voiceCommandsEnabled = voiceEnabled;
    });
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
        case 'session_ending':
          _speak("Session ended");
          Navigator.pop(context);
          break;
          
        case 'audio_selected':
          final audioId = data['audio_id'] as int?;
          final title = data['title'] as String?;
          if (audioId != null) {
            setState(() {
              _currentAudioId = audioId;
              _currentAudioTitle = title;
            });
            _speak("Audio selected: ${title ?? 'Unknown'}");
          }
          break;
          
        case 'audio_play':
          final audioId = data['audio_id'] as int?;
          final speed = (data['speed'] as num?)?.toDouble() ?? 1.0;
          final position = (data['position'] as num?)?.toDouble() ?? 0.0;
          final title = data['title'] as String?;
          
          if (audioId != null) {
            _onAudioPlay(audioId, title, speed, position);
          }
          break;
          
        case 'audio_pause':
          _onAudioPause();
          break;
          
        case 'audio_seek':
          final position = (data['position'] as num?)?.toDouble() ?? 0.0;
          _onAudioSeek(position);
          break;
      }
    } catch (e) {
      print('[WS PARSE ERROR] $e');
    }
  }

  Future<void> _speak(String text) async {
    if (_ttsEnabled) {
      try {
        await TtsService.speak(text);
      } catch (e) {
        print('[TTS ERROR] $e');
      }
    }
  }

  Future<void> _startVoiceCommands() async {
    try {
      final available = await _speech.initialize(
        onStatus: _handleSpeechStatus,
        onError: _handleSpeechError,
      );
      if (!mounted) return;
      setState(() => _voiceCommandsAvailable = available);
      if (available) {
        await _listenForVoiceCommand();
        await _speak("Voice commands ready");
      } else {
        await _speak("Voice commands are not available on this device");
      }
    } catch (e) {
      print('[VOICE COMMAND ERROR] $e');
    }
  }

  Future<void> _listenForVoiceCommand() async {
    if (!_voiceCommandsEnabled ||
        !_voiceCommandsAvailable ||
        !mounted ||
        _speech.isListening) {
      return;
    }

    await _speech.listen(
      listenMode: stt.ListenMode.confirmation,
      partialResults: false,
      listenFor: const Duration(seconds: 12),
      pauseFor: const Duration(seconds: 3),
      onResult: (result) {
        if (result.finalResult) {
          _handleVoiceCommand(result.recognizedWords);
        }
      },
    );
  }

  void _handleSpeechStatus(String status) {
    if (!_voiceCommandsEnabled || !mounted) return;
    if (status == 'done' || status == 'notListening') {
      Future.delayed(const Duration(milliseconds: 700), () {
        if (mounted && _voiceCommandsEnabled) _listenForVoiceCommand();
      });
    }
  }

  void _handleSpeechError(dynamic error) {
    print('[VOICE COMMAND SPEECH ERROR] $error');
    if (_voiceCommandsEnabled && mounted) {
      Future.delayed(const Duration(milliseconds: 700), () {
        if (mounted && _voiceCommandsEnabled) _listenForVoiceCommand();
      });
    }
  }

  void _handleVoiceCommand(String words) {
    final command = words.toLowerCase().trim();
    if (command.isEmpty) return;

    if (command.contains('unmute')) {
      if (_muted) {
        _toggleMute();
      } else {
        _speak("Already unmuted");
      }
      return;
    }

    if (command.contains('mute')) {
      if (!_muted) {
        _toggleMute();
      } else {
        _speak("Already muted");
      }
      return;
    }

    if (command.contains('lower hand')) {
      if (_handRaised) {
        _toggleHand();
      } else {
        _speak("Hand is already lowered");
      }
      return;
    }

    if (command.contains('raise hand')) {
      if (!_handRaised) {
        _toggleHand();
      } else {
        _speak("Hand is already raised");
      }
      return;
    }

    if (command.contains('repeat') || command.contains('instructions')) {
      _speak(buildTtsInstructions(simpleSessionKeyLabels, screenName: 'Session active'));
      return;
    }

    if (command.contains('leave') || command.contains('exit')) {
      _leave();
      return;
    }

    _speak("Command not recognized");
  }

  // Audio helper methods
  Future<void> _onAudioPlay(int audioId, String? title, double speed, double position) async {
    try {
      setState(() {
        _currentAudioId = audioId;
        _currentAudioTitle = title ?? _currentAudioTitle;
        _isPlayingSessionAudio = true;
        _currentPosition = position;
        // We use our local speed preference if set, otherwise the broadcast speed
        // Actually, let's stick to broadcast speed initially unless user changed it
      });

      await _sessionAudioPlayer.stop();
      // Apply our local speed preference
      await _sessionAudioPlayer.setPlaybackRate(_audioSpeed);
      await _sessionAudioPlayer.play(UrlSource('${ApiService.baseUrl}/audio/$audioId/stream'));
      if (position > 0) {
        await _sessionAudioPlayer.seek(Duration(seconds: position.toInt()));
      }
      _speak("Playing audio");
    } catch (e) {
      print('[AUDIO PLAY ERROR] $e');
      setState(() => _isPlayingSessionAudio = false);
    }
  }

  Future<void> _onAudioPause() async {
    await _sessionAudioPlayer.pause();
    setState(() => _isPlayingSessionAudio = false);
    _speak("Audio paused");
  }

  Future<void> _onAudioSeek(double position) async {
    await _sessionAudioPlayer.seek(Duration(seconds: position.toInt()));
    setState(() => _currentPosition = position);
  }

  void _increaseSpeed() {
    if (_audioSpeed < 3.0) {
      setState(() {
        _audioSpeed += 0.25;
        if (_audioSpeed > 3.0) _audioSpeed = 3.0;
      });
      _sessionAudioPlayer.setPlaybackRate(_audioSpeed);
      _speak("Speed increased to ${_audioSpeed}x");
    } else {
      _speak("Maximum speed 3x reached");
    }
  }

  void _decreaseSpeed() {
    if (_audioSpeed > 0.25) {
      setState(() {
        _audioSpeed -= 0.25;
        if (_audioSpeed < 0.25) _audioSpeed = 0.25;
      });
      _sessionAudioPlayer.setPlaybackRate(_audioSpeed);
      _speak("Speed decreased to ${_audioSpeed}x");
    } else {
      _speak("Minimum speed 0.25x reached");
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
    TtsService.configure(enabled: _ttsEnabled);
    _speak(_ttsEnabled ? "TTS on" : "TTS off");
  }

  void _leave() {
    _speak("Leaving");
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _voiceCommandsEnabled = false;
    if (_speech.isListening) {
      _speech.stop();
    }
    _wsChannel?.sink.close();
    _sessionAudioPlayer.stop();
    _sessionAudioPlayer.dispose();
    super.dispose();
  }

  Widget _buildBigButton(BuildContext context, {
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
        padding: UIUtils.paddingSymmetric(context, vertical: 16, horizontal: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: UIUtils.iconSize(context, 32)),
          SizedBox(height: UIUtils.spacing(context, 6)),
          Text(
            label,
            style: TextStyle(
              fontSize: UIUtils.fontSize(context, 14),
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
    final bool tiny = UIUtils.isTiny(context);
    return KeypadInstructionWrapper(
      screenName: 'Session active',
      labels: simpleSessionKeyLabels,
      actions: {
        1: _toggleMute,
        2: _toggleHand,
        3: _toggleTTS,
        4: _leave,
        7: _decreaseSpeed,
        9: _increaseSpeed,
      },
      onHashKey: _leave,
      child: Scaffold(
        backgroundColor: UIUtils.backgroundColor,
        appBar: AppBar(
          title: Text(
            'Session ${widget.sessionId}',
            style: TextStyle(fontSize: UIUtils.fontSize(context, 16), fontWeight: FontWeight.w600),
          ),
          backgroundColor: UIUtils.cardColor,
          foregroundColor: UIUtils.textColor,
          elevation: 0,
          toolbarHeight: tiny ? 40 : null,
          centerTitle: true,
        ),
        body: Column(
          children: [
            // Status bar
            Container(
              width: double.infinity,
              padding: UIUtils.paddingAll(context, 16),
              color: UIUtils.backgroundColor,
              child: Column(
                children: [
                  Text(
                    _statusText,
                    style: TextStyle(
                      color: UIUtils.textColor,
                      fontSize: UIUtils.fontSize(context, 20),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: UIUtils.spacing(context, 6)),
                  Text(
                    'Participants: $_participantCount',
                    style: TextStyle(
                      color: UIUtils.subtextColor,
                      fontSize: UIUtils.fontSize(context, 14),
                    ),
                  ),
                  if (_currentSpeaker != "None" && !tiny) ...[
                    SizedBox(height: UIUtils.spacing(context, 4)),
                    Text(
                      'Speaking: $_currentSpeaker',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontSize: UIUtils.fontSize(context, 12),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  if (_isPlayingSessionAudio) ...[
                    SizedBox(height: UIUtils.spacing(context, 8)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.speed_rounded, size: UIUtils.iconSize(context, 16), color: UIUtils.accentColor),
                        const SizedBox(width: 4),
                        Text(
                          'Playback Speed: ${_audioSpeed}x',
                          style: TextStyle(
                            color: UIUtils.textColor,
                            fontSize: UIUtils.fontSize(context, 12),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            
            SizedBox(height: UIUtils.spacing(context, 12)),
            
            // Large mic indicator
            Container(
              width: 80 * UIUtils.scale(context),
              height: 80 * UIUtils.scale(context),
              decoration: BoxDecoration(
                color: _muted ? Colors.red : Colors.green,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _muted ? Icons.mic_off : Icons.mic,
                size: UIUtils.iconSize(context, 40),
                color: Colors.white,
              ),
            ),
            
            SizedBox(height: UIUtils.spacing(context, 8)),
            
            Text(
              _muted ? 'MUTED' : 'LIVE',
              style: TextStyle(
                color: _muted ? Colors.red : Colors.green,
                fontSize: UIUtils.fontSize(context, 24),
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
            
            SizedBox(height: UIUtils.spacing(context, 16)),
            
            // Button grid
            Expanded(
              child: Padding(
                padding: UIUtils.paddingAll(context, 10),
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: UIUtils.spacing(context, 10),
                  crossAxisSpacing: UIUtils.spacing(context, 10),
                  childAspectRatio: tiny ? 1.3 : 1.1,
                  children: [
                    _buildBigButton(context,
                      label: _muted ? '1: Unmute' : '1: Mute',
                      icon: _muted ? Icons.mic : Icons.mic_off,
                      onPressed: _toggleMute,
                      color: _muted ? Colors.green : Colors.red,
                      isActive: !_muted,
                    ),
                    _buildBigButton(context,
                      label: _handRaised ? '2: Lower' : '2: Raise',
                      icon: _handRaised ? Icons.pan_tool : Icons.pan_tool_outlined,
                      onPressed: _toggleHand,
                      color: Colors.amber,
                      isActive: _handRaised,
                    ),
                    _buildBigButton(context,
                      label: '3: TTS',
                      icon: _ttsEnabled ? Icons.volume_up : Icons.volume_off,
                      onPressed: _toggleTTS,
                      color: Colors.blue,
                      isActive: _ttsEnabled,
                    ),
                    _buildBigButton(context,
                      label: '4: Leave',
                      icon: Icons.call_end,
                      onPressed: _leave,
                      color: Colors.red.shade700,
                    ),
                    _buildBigButton(context,
                      label: '7: Slower',
                      icon: Icons.fast_rewind_rounded,
                      onPressed: _decreaseSpeed,
                      color: Colors.blueGrey,
                    ),
                    _buildBigButton(context,
                      label: '9: Faster',
                      icon: Icons.fast_forward_rounded,
                      onPressed: _increaseSpeed,
                      color: Colors.blueGrey,
                    ),
                  ],
                ),
              ),
            ),
            
            // Info footer
            Container(
              width: double.infinity,
              padding: UIUtils.paddingAll(context, 12),
              color: UIUtils.backgroundColor,
              child: Text(
                'Keypad: 1:Mute, 2:Hand, 3:TTS, 4:Exit, 7:Slow, 9:Fast',
                style: TextStyle(
                  color: UIUtils.subtextColor,
                  fontSize: UIUtils.fontSize(context, 10),
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
