// ignore_for_file: avoid_print

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:convert';
import '../services/api_service.dart';
// Allows reading environment variables
import 'package:flutter_dotenv/flutter_dotenv.dart';


// Backend and websocket URL
final baseUrl = dotenv.env['API_BASE_URL'];
final wsBaseUrl = dotenv.env['WS_BASE_URL'];


class SessionScreen extends StatefulWidget {
  final int sessionId;
  final int userId;
  final bool isTeacher;
  final String userName;

  const SessionScreen({
    super.key,
    required this.sessionId,
    required this.userId,
    this.isTeacher = false,
    required this.userName,
  });

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  // WebRTC
  MediaStream? _localStream;
  final Map<int, RTCPeerConnection> _peerConnections = {};
  final Map<int, RTCVideoRenderer> _remoteRenderers = {};
  
  final FlutterTts _tts = FlutterTts();
  final AudioPlayer _sessionAudioPlayer = AudioPlayer(); // For synchronized session audio

  bool _muted = false;
  bool _handRaised = false;
  bool _ttsEnabled = true;
  bool _isInitializing = true;
  int? _participantId;
  int? _currentAudioId;
  String? _currentAudioTitle;
  bool _isPlayingSessionAudio = false;
  double _audioSpeed = 1.0;
  double? _audioDuration;
  double _currentPosition = 0.0;
  // Timer? _positionTracker;
  bool _isSeeking = false;  


  final TextEditingController _chatController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final Map<int, Map<String, dynamic>> _participants = {};
  
  WebSocketChannel? _wsChannel;
  final ScrollController _chatScrollController = ScrollController();

  // STUN/TURN Configuration
  final Map<String, dynamic> _iceServers = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
      {'urls': 'stun:stun1.l.google.com:19302'},
      {'urls': 'stun:stun2.l.google.com:19302'},
    ],
    'sdpSemantics': 'unified-plan',
  };

  @override
  void initState() {
    super.initState();
    _initialize();

    // Listen to audio player position updates
    _sessionAudioPlayer.onPositionChanged.listen((position) {
      if (mounted && !_isSeeking) {
        setState(() {
          _currentPosition = position.inSeconds.toDouble();
        });
      }
    });
    
    // Listen to duration
    _sessionAudioPlayer.onDurationChanged.listen((duration) {
      if (mounted) {
        setState(() {
          _audioDuration = duration.inSeconds.toDouble();
        });
      }
    });

    // Listen to playback completion
    _sessionAudioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _isPlayingSessionAudio = false;
          _currentPosition = 0.0;
        });
        _speakIfEnabled("Playback finished");
      }
    });
  }


  Future<void> _initialize() async {
    try {
      print('[INIT] Starting initialization...');
      await _initializeMedia();
      await _joinSession();
      await _connectWebSocket();
      setState(() => _isInitializing = false);
      await _speakIfEnabled("Session ready");
    } catch (e) {
      print('[INIT ERROR] $e');
      await _speakIfEnabled("Failed to initialize session");
      setState(() => _isInitializing = false);
    }
  }

  Future<void> _initializeMedia() async {
    try {
      print('[MEDIA] Requesting permissions...');
      
      // Request audio with optimal settings
      final Map<String, dynamic> mediaConstraints = {
        'audio': {
          'mandatory': {
            'googEchoCancellation': true,
            'googNoiseSuppression': true,
            'googAutoGainControl': true,
            'googHighpassFilter': true,
          },
          'optional': [],
        },
        'video': false,
      };

      _localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
      
      if (_localStream == null) {
        throw Exception('Failed to get media stream');
      }

      // Set initial mute state
      _localStream!.getAudioTracks().forEach((track) {
        track.enabled = !_muted;
        print('[MEDIA] Audio track: ${track.id}, enabled: ${track.enabled}');
      });
      
      print('[MEDIA] Local stream initialized successfully');
    } catch (e) {
      print('[MEDIA ERROR] $e');
      throw Exception('Microphone permission denied or unavailable');
    }
  }

  Future<void> _joinSession() async {
    try {
      print('[JOIN] Joining session ${widget.sessionId}...');
      final result = await ApiService.joinSession(widget.sessionId);
      if (result != null && result['participant_id'] != null) {
        _participantId = result['participant_id'];
        print('[JOIN] Success! Participant ID: $_participantId');
      } else {
        print('[JOIN] No participant_id in response');
      }
    } catch (e) {
      print('[JOIN ERROR] $e');
      throw Exception('Failed to join session');
    }
  }

  Future<void> _connectWebSocket() async {
    try {
      final wsUrl = '$wsBaseUrl/ws/sessions/${widget.sessionId}?user_id=${widget.userId}';
      print('[WS] Connecting to: $wsUrl');
      
      _wsChannel = WebSocketChannel.connect(Uri.parse(wsUrl));
      
      _wsChannel!.stream.listen(
        (message) => _handleWebSocketMessage(message),
        onError: (error) {
          print('[WS ERROR] $error');
          _reconnectWebSocket();
        },
        onDone: () {
          print('[WS] Connection closed, reconnecting...');
          _reconnectWebSocket();
        },
      );
      
      print('[WS] Connected successfully');
    } catch (e) {
      print('[WS ERROR] Failed to connect: $e');
      Future.delayed(const Duration(seconds: 3), _reconnectWebSocket);
    }
  }

  Future<void> _reconnectWebSocket() async {
    if (!mounted) return;
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      await _connectWebSocket();
    }
  }

  void _sendWebSocketMessage(Map<String, dynamic> message) {
    try {
      if (_wsChannel != null) {
        final json = jsonEncode(message);
        _wsChannel!.sink.add(json);
        print('[WS SEND] ${message['type']}');
      }
    } catch (e) {
      print('[WS SEND ERROR] $e');
    }
  }

  void _handleWebSocketMessage(dynamic message) {
    try {
      final data = jsonDecode(message);
      final type = data['type'];

      print('[WS RECEIVE] $type');

      switch (type) {
        case 'connected':
          print('[WS] Connection confirmed');
          break;
        case 'session_state':
          _updateSessionState(data);
          break;
        case 'participant_joined':
          _onParticipantJoined(data);
          break;
        case 'participant_left':
          _onParticipantLeft(data);
          break;
        case 'participant_muted':
          _onParticipantMuted(data);
          break;
        case 'hand_raised':
          _onHandRaised(data, true);
          break;
        case 'hand_lowered':
          _onHandRaised(data, false);
          break;
        case 'chat':
          _onChatMessage(data);
          break;
        case 'kicked':
          _onKicked(data);
          break;
        case 'session_ended':
          _onSessionEnded();
          break;
        case 'webrtc_signal':
          _handleWebRTCSignal(data);
          break;
        case 'audio_selected':
          _onAudioSelected(data);
          break;
        case 'audio_play':
          _onAudioPlay(data);
          break;
        case 'audio_pause':
          _onAudioPause(data);
          break;
        case 'audio_seek':
          _onAudioSeek(data);
          break;
        case 'audio_speed_change':
          _changeAudioSpeed(data);
          break;
        case 'error':
          print('[WS ERROR] ${data['detail']}');
          _showError(message);
          break;
        default:
          print('[WS] Unknown message type: $type');
      }
    } catch (e) {
      print('[WS PARSE ERROR] $e');
    }
  }

  void _updateSessionState(Map<String, dynamic> data) {
    print('[STATE] Updating session state...');
    setState(() {
      _participants.clear();
      final participants = data['participants'] as Map<String, dynamic>? ?? {};
      
      participants.forEach((key, value) {
        final participantId = int.tryParse(key) ?? 0;
        if (participantId == 0) return;
        
        final participantData = value as Map<String, dynamic>;
        
        _participants[participantId] = {
          'id': participantId,
          'user_id': participantData['user_id'],
          'name': participantData['name'] ?? 'User ${participantData['user_id']}',
          'is_muted': participantData['is_muted'] ?? false,
          'raised_hand': participantData['raised_hand'] ?? false,
          'is_teacher': false,
        };
      });
    });
    
    print('[STATE] ${_participants.length} participants loaded');
    
    // Create WebRTC connections for all participants (except self)
    _participants.keys.where((id) => id != _participantId).forEach((participantId) {
      if (!_peerConnections.containsKey(participantId)) {
        print('[WebRTC] Creating connection for participant $participantId');
        _createPeerConnection(participantId, true); // true = create offer
      }
    });
  }

  void _onParticipantJoined(Map<String, dynamic> data) {
    final participantId = data['participant_id'] as int?;
    final userId = data['user_id'] as int?;
    final name = data['name'] ?? 'User $userId';
    final isTeacher = data['is_teacher'] ?? false;
    
    if (participantId == null || participantId == _participantId) return;
    
    print('[PARTICIPANT] Joined: $name ($participantId)');
    
    setState(() {
      _participants[participantId] = {
        'id': participantId,
        'user_id': userId,
        'name': name,
        'is_muted': false,
        'raised_hand': false,
        'is_teacher': isTeacher,
      };
    });
    
    _speakIfEnabled('$name joined');
    
    // Create WebRTC connection (we'll wait for their offer)
    if (!_isInitializing && participantId != _participantId) {
      // Don't create offer immediately, wait for their offer or create ours after delay
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!_peerConnections.containsKey(participantId)) {
          _createPeerConnection(participantId, participantId > (_participantId ?? 0));
        }
      });
    }
  }

  void _onParticipantLeft(Map<String, dynamic> data) {
    final participantId = data['participant_id'] as int?;
    if (participantId == null) return;
    
    final participant = _participants[participantId];
    if (participant != null) {
      final name = participant['name'] as String;
      print('[PARTICIPANT] Left: $name ($participantId)');
      
      setState(() {
        _participants.remove(participantId);
      });
      
      // Clean up WebRTC connection
      _closePeerConnection(participantId);
      
      _speakIfEnabled('$name left');
    }
  }

  void _onParticipantMuted(Map<String, dynamic> data) {
    final participantId = data['participant_id'] as int?;
    final isMuted = data['is_muted'] ?? false;
    
    if (participantId == null) return;
    
    setState(() {
      if (_participants.containsKey(participantId)) {
        _participants[participantId]!['is_muted'] = isMuted;
      }
    });
  }

  void _onHandRaised(Map<String, dynamic> data, bool raised) {
    final participantId = data['participant_id'] as int?;
    if (participantId == null) return;
    
    setState(() {
      if (_participants.containsKey(participantId)) {
        _participants[participantId]!['raised_hand'] = raised;
      }
    });
    
    if (raised && widget.isTeacher) {
      final name = _participants[participantId]?['name'] ?? 'Someone';
      _speakIfEnabled('$name raised their hand');
    }
  }

  void _onChatMessage(Map<String, dynamic> data) {
    final senderName = data['sender_name'] ?? data['from']?.toString() ?? 'Unknown';
    final text = data['text'] ?? data['message'] ?? '';
    
    if (text.isEmpty) return;
    
    setState(() {
      _messages.add({
        'sender': senderName,
        'text': text,
        'timestamp': DateTime.now(),
        'isMe': senderName == widget.userName,
      });
    });
    
    // Auto-scroll
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_chatScrollController.hasClients) {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
    
    // TTS for others' messages
    if (senderName != widget.userName) {
      _speakIfEnabled('$senderName: $text');
    }
  }

  void _onKicked(Map<String, dynamic> data) {
    _speakIfEnabled('You have been removed');
    Navigator.pop(context);
  }

  void _onSessionEnded() {
    _speakIfEnabled('Session ended');
    Navigator.pop(context);
  }

  // Audio playback handlers
  void _onAudioSelected(Map<String, dynamic> data) {
    final audioId = data['audio_id'] as int?;
    final title = data['title'] as String?;
    
    if (audioId != null) {
      setState(() {
        _currentAudioId = audioId;
        _currentAudioTitle = title;
      });
      _speakIfEnabled('Audio selected: ${title ?? "Unknown"}');
    }
  }

  Future<void> _onAudioPlay(Map<String, dynamic> data) async {
    final audioId = data['audio_id'] as int?;
    final speed = (data['speed'] as num?)?.toDouble() ?? 1.0;
    final position = (data['position'] as num?)?.toDouble() ?? 0.0;
    final title = data['title'] as String?;
    final duration = (data['duration'] as num?)?.toDouble();
    
    if (audioId == null) return;

    try {
      setState(() {
        _currentAudioId = audioId;
        _currentAudioTitle = title;
        _isPlayingSessionAudio = true;
        _audioSpeed = speed;
        _currentPosition = position;
        _audioDuration = duration;
      });

      await _sessionAudioPlayer.stop();
      
      final url = '$baseUrl/audio/$audioId/stream';
      await _sessionAudioPlayer.setPlaybackRate(speed);
      await _sessionAudioPlayer.play(UrlSource(url));
      
      // Seek to position if not starting from beginning
      if (position > 0) {
        await _sessionAudioPlayer.seek(Duration(seconds: position.toInt()));
      }
      
      print('[AUDIO] Playing from position: ${position}s at speed $speed');
    } catch (e) {
      print('[AUDIO] Error: $e');
      setState(() => _isPlayingSessionAudio = false);
    }
  }


  Future<void> _onAudioPause(Map<String, dynamic> data) async {
    final position = (data['position'] as num?)?.toDouble();
    
    try {
      await _sessionAudioPlayer.pause();
      
      if (position != null) {
        setState(() {
          _isPlayingSessionAudio = false;
          _currentPosition = position;
        });
      } else {
        // Get current position from player
        final currentPos = await _sessionAudioPlayer.getCurrentPosition();
        setState(() {
          _isPlayingSessionAudio = false;
          _currentPosition = currentPos?.inSeconds.toDouble() ?? 0.0;
        });
      }
      
      print('[AUDIO] Paused at position: ${_currentPosition}s');
    } catch (e) {
      print('[AUDIO] Error pausing: $e');
    }
  }


  Future<void> _onAudioSeek(Map<String, dynamic> data) async {
    final position = (data['position'] as num?)?.toDouble() ?? 0.0;
    final resumePlaying = data['resume_playing'] as bool? ?? false;
    
    try {
      await _sessionAudioPlayer.seek(Duration(seconds: position.toInt()));
      
      setState(() {
        _currentPosition = position;
      });
      
      if (resumePlaying && !_isPlayingSessionAudio) {
        await _sessionAudioPlayer.resume();
        setState(() => _isPlayingSessionAudio = true);
      }
      
      print('[AUDIO] Seeked to position: ${position}s');
    } catch (e) {
      print('[AUDIO] Error seeking: $e');
    }
  }


  // Teacher audio controls
  Future<void> _playSessionAudio() async {
    if (_currentAudioId == null) return;

    try {
      final result = await ApiService.controlAudio(
        widget.sessionId,
        action: 'play',
        audioId: _currentAudioId!,
        speed: _audioSpeed,
        position: _currentPosition,
      );

      if (result != null && result['ok'] == true) {
        setState(() => _isPlayingSessionAudio = true);
      }
    } catch (e) {
      print('[AUDIO CONTROL] Error: $e');
    }
  }

  Future<void> _pauseSessionAudio() async {
    // Get current position before pausing
    final position = await _sessionAudioPlayer.getCurrentPosition();
    final positionSeconds = position?.inSeconds.toDouble() ?? _currentPosition;
    
    setState(() {
      _currentPosition = positionSeconds;
      _isPlayingSessionAudio = false;
    });
    
    // Pause local playback
    await _sessionAudioPlayer.pause();
    
    // Broadcast pause with position to all participants
    try {
      await ApiService.controlAudio(
        widget.sessionId,
        action: 'pause',
        position: positionSeconds,
      );
    } catch (e) {
      print('[AUDIO CONTROL] Error: $e');
    }
  }

  Future<void> _seekAudio(double position) async {
    if (!widget.isTeacher) return;
    
    setState(() => _isSeeking = true);
    
    try {
      await ApiService.controlAudio(
        widget.sessionId,
        action: 'seek',
        position: position,
      );
      
      // Local seek
      await _sessionAudioPlayer.seek(Duration(seconds: position.toInt()));
      
      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      print('[SEEK] Error: $e');
    } finally {
      setState(() => _isSeeking = false);
    }
  }

  void _changeAudioSpeed(double newSpeed) async {
    if (!widget.isTeacher) return;
    
    setState(() => _audioSpeed = newSpeed);
    
    try {
      // Get current position
      final position = await _sessionAudioPlayer.getCurrentPosition();
      final positionSeconds = position?.inSeconds.toDouble() ?? _currentPosition;
      
      // Update speed locally
      await _sessionAudioPlayer.setPlaybackRate(newSpeed);
      
      // Broadcast to participants
      await ApiService.controlAudio(
        widget.sessionId,
        action: 'play',
        audioId: _currentAudioId!,
        speed: newSpeed,
        position: positionSeconds,
      );
    } catch (e) {
      print('[SPEED CHANGE] Error: $e');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  // Open audio library
  void _openAudioLibrary() {
    if (!widget.isTeacher) {
      _speakIfEnabled('Only teachers can manage audio');
      return;
    }

    Navigator.pushNamed(
      context,
      '/audio_library',
      arguments: {'sessionId': widget.sessionId},
    );
  }

  // WebRTC Implementation
  Future<void> _createPeerConnection(int participantId, bool createOffer) async {
    try {
      print('[WebRTC] Creating peer connection for $participantId (offer: $createOffer)');
      
      RTCPeerConnection pc = await createPeerConnection(_iceServers);
      
      // Add local stream
      if (_localStream != null) {
        _localStream!.getTracks().forEach((track) {
          pc.addTrack(track, _localStream!);
          print('[WebRTC] Added local track: ${track.kind}');
        });
      }

      // Handle remote stream
      pc.onTrack = (RTCTrackEvent event) {
        print('[WebRTC] Received track from $participantId: ${event.track.kind}');
        if (event.streams.isNotEmpty) {
          _handleRemoteStream(participantId, event.streams[0]);
        }
      };

      // Handle ICE candidates
      pc.onIceCandidate = (RTCIceCandidate? candidate) {
        if (candidate != null) {
          print('[WebRTC] Sending ICE candidate to $participantId');
          _sendWebSocketMessage({
            'type': 'webrtc_signal',
            'target_participant_id': participantId,
            'payload': {
              'type': 'ice_candidate',
              'candidate': candidate.toMap(),
            },
          });
        }
      };

      // Connection state monitoring
      pc.onConnectionState = (RTCPeerConnectionState state) {
        print('[WebRTC] Connection state with $participantId: $state');
        if (state == RTCPeerConnectionState.RTCPeerConnectionStateFailed ||
            state == RTCPeerConnectionState.RTCPeerConnectionStateClosed) {
          _closePeerConnection(participantId);
        }
      };

      _peerConnections[participantId] = pc;

      // Create offer if needed
      if (createOffer) {
        await Future.delayed(const Duration(milliseconds: 100));
        RTCSessionDescription offer = await pc.createOffer();
        await pc.setLocalDescription(offer);

        print('[WebRTC] Sending offer to $participantId');
        _sendWebSocketMessage({
          'type': 'webrtc_signal',
          'target_participant_id': participantId,
          'payload': {
            'type': 'offer',
            'sdp': offer.sdp,
          },
        });
      }
    } catch (e) {
      print('[WebRTC ERROR] Failed to create peer connection: $e');
    }
  }

  void _handleRemoteStream(int participantId, MediaStream stream) {
    print('[WebRTC] Setting up remote stream for $participantId');
    
    // Create renderer if doesn't exist
    if (!_remoteRenderers.containsKey(participantId)) {
      RTCVideoRenderer renderer = RTCVideoRenderer();
      renderer.initialize().then((_) {
        renderer.srcObject = stream;
        setState(() {
          _remoteRenderers[participantId] = renderer;
        });
        print('[WebRTC] Remote renderer initialized for $participantId');
      });
    } else {
      _remoteRenderers[participantId]!.srcObject = stream;
    }
  }

  Future<void> _handleWebRTCSignal(Map<String, dynamic> data) async {
    try {
      final fromParticipantId = data['from'] as int?;
      final toParticipantId = data['to'] as int?;
      final payload = data['payload'] as Map<String, dynamic>?;

      if (fromParticipantId == null || payload == null) return;
      if (toParticipantId != null && toParticipantId != _participantId) return;

      final signalType = payload['type'] as String?;
      print('[WebRTC] Received signal from $fromParticipantId: $signalType');

      switch (signalType) {
        case 'offer':
          await _handleOffer(fromParticipantId, payload);
          break;
        case 'answer':
          await _handleAnswer(fromParticipantId, payload);
          break;
        case 'ice_candidate':
          await _handleICECandidate(fromParticipantId, payload);
          break;
      }
    } catch (e) {
      print('[WebRTC SIGNAL ERROR] $e');
    }
  }

  Future<void> _handleOffer(int fromParticipantId, Map<String, dynamic> payload) async {
    try {
      final sdp = payload['sdp'] as String?;
      if (sdp == null) return;

      print('[WebRTC] Handling offer from $fromParticipantId');

      // Create connection if doesn't exist
      if (!_peerConnections.containsKey(fromParticipantId)) {
        await _createPeerConnection(fromParticipantId, false);
      }

      final pc = _peerConnections[fromParticipantId]!;
      await pc.setRemoteDescription(RTCSessionDescription(sdp, 'offer'));

      // Create answer
      RTCSessionDescription answer = await pc.createAnswer();
      await pc.setLocalDescription(answer);

      print('[WebRTC] Sending answer to $fromParticipantId');
      _sendWebSocketMessage({
        'type': 'webrtc_signal',
        'target_participant_id': fromParticipantId,
        'payload': {
          'type': 'answer',
          'sdp': answer.sdp,
        },
      });
    } catch (e) {
      print('[WebRTC] Error handling offer: $e');
    }
  }

  Future<void> _handleAnswer(int fromParticipantId, Map<String, dynamic> payload) async {
    try {
      final sdp = payload['sdp'] as String?;
      if (sdp == null) return;

      print('[WebRTC] Handling answer from $fromParticipantId');

      final pc = _peerConnections[fromParticipantId];
      if (pc != null) {
        await pc.setRemoteDescription(RTCSessionDescription(sdp, 'answer'));
        print('[WebRTC] Remote description set for $fromParticipantId');
      }
    } catch (e) {
      print('[WebRTC] Error handling answer: $e');
    }
  }

  Future<void> _handleICECandidate(int fromParticipantId, Map<String, dynamic> payload) async {
    try {
      final candidateMap = payload['candidate'] as Map<String, dynamic>?;
      if (candidateMap == null) return;

      final pc = _peerConnections[fromParticipantId];
      if (pc != null) {
        final candidate = RTCIceCandidate(
          candidateMap['candidate'],
          candidateMap['sdpMid'],
          candidateMap['sdpMLineIndex'],
        );
        await pc.addCandidate(candidate);
        print('[WebRTC] Added ICE candidate from $fromParticipantId');
      }
    } catch (e) {
      print('[WebRTC] Error handling ICE candidate: $e');
    }
  }

  void _closePeerConnection(int participantId) {
    _peerConnections[participantId]?.close();
    _peerConnections.remove(participantId);
    _remoteRenderers[participantId]?.dispose();
    _remoteRenderers.remove(participantId);
    print('[WebRTC] Closed connection for $participantId');
  }

  Future<void> _speakIfEnabled(String text) async {
    if (_ttsEnabled && mounted) {
      try {
        await _tts.speak(text);
      } catch (e) {
        print('[TTS ERROR] $e');
      }
    }
  }

  @override
  void dispose() {
    _chatController.dispose();
    _chatScrollController.dispose();
    
    // Close WebSocket
    _wsChannel?.sink.close();
    
    // Clean up WebRTC
    _localStream?.dispose();
    _peerConnections.forEach((_, pc) => pc.close());
    _remoteRenderers.forEach((_, renderer) => renderer.dispose());
    
    // Stop audio
    _sessionAudioPlayer.dispose();
    _tts.stop();
    
    super.dispose();
  }

  // UI Actions
  void _toggleMute() async {
    setState(() => _muted = !_muted);

    // Toggle local audio tracks
    if (_localStream != null) {
      _localStream!.getAudioTracks().forEach((track) {
        track.enabled = !_muted;
        print('[AUDIO] Track ${track.id} enabled: ${track.enabled}');
      });
    }

    _sendWebSocketMessage({
      'type': 'mute_self',
      'mute': _muted,
    });

    await _speakIfEnabled(_muted ? "Muted" : "Unmuted");
  }

  void _toggleHandRaise() async {
    setState(() => _handRaised = !_handRaised);
    
    _sendWebSocketMessage({
      'type': _handRaised ? 'raise_hand' : 'lower_hand',
    });
    
    await _speakIfEnabled(_handRaised ? "Hand raised" : "Hand lowered");
  }

  void _sendMessage() {
    final text = _chatController.text.trim();
    if (text.isEmpty) return;

    _sendWebSocketMessage({
      'type': 'chat',
      'text': text,
    });
    
    // Add to local messages
    setState(() {
      _messages.add({
        'sender': widget.userName,
        'text': text,
        'timestamp': DateTime.now(),
        'isMe': true,
      });
    });
    
    _chatController.clear();
    
    // Auto-scroll
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_chatScrollController.hasClients) {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _muteParticipant(int participantId, bool mute) {
    _sendWebSocketMessage({
      'type': mute ? 'mute_participant' : 'unmute_participant',
      'target_participant_id': participantId,
    });
  }

  void _kickParticipant(int participantId) {
    _sendWebSocketMessage({
      'type': 'kick_participant',
      'target_participant_id': participantId,
    });
  }

  void _leaveSession() async {
    await _speakIfEnabled("Leaving session");
    Navigator.pop(context);
  }




  // Helper function to format duration
  String _formatDuration(double seconds) {
    final duration = Duration(seconds: seconds.toInt());
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final secs = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${hours}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes}:${secs.toString().padLeft(2, '0')}';
  }



  // Add this widget for the enhanced audio control UI
  Widget _buildAudioControlSection() {
    if (_currentAudioId == null) return const SizedBox.shrink();
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isPlayingSessionAudio ? Colors.purple.shade100 : Colors.grey.shade200,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Title and speed
          Row(
            children: [
              Icon(
                _isPlayingSessionAudio ? Icons.music_note : Icons.audiotrack,
                color: _isPlayingSessionAudio ? Colors.purple.shade700 : Colors.grey.shade700,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentAudioTitle ?? 'Audio Selected',
                      style: TextStyle(
                        color: _isPlayingSessionAudio ? Colors.purple.shade700 : Colors.grey.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_formatDuration(_currentPosition)} / ${_audioDuration != null ? _formatDuration(_audioDuration!) : '--:--'}',
                      style: TextStyle(
                        color: _isPlayingSessionAudio ? Colors.purple.shade600 : Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _isPlayingSessionAudio ? Colors.purple.shade700 : Colors.grey.shade600,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_audioSpeed.toStringAsFixed(1)}x',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Progress bar with seek functionality
          Column(
            children: [
              SliderTheme(
                data: SliderThemeData(
                  trackHeight: 4,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                  activeTrackColor: Colors.purple.shade700,
                  inactiveTrackColor: Colors.grey.shade400,
                  thumbColor: Colors.purple.shade700,
                  overlayColor: Colors.purple.shade700.withOpacity(0.2),
                ),
                child: Slider(
                  value: _audioDuration != null && _audioDuration! > 0
                      ? (_currentPosition / _audioDuration!).clamp(0.0, 1.0)
                      : 0.0,
                  onChanged: widget.isTeacher
                      ? (value) {
                          if (_audioDuration != null) {
                            final newPosition = value * _audioDuration!;
                            setState(() => _currentPosition = newPosition);
                          }
                        }
                      : null,
                  onChangeEnd: widget.isTeacher
                      ? (value) {
                          if (_audioDuration != null) {
                            final newPosition = value * _audioDuration!;
                            _seekAudio(newPosition);
                          }
                        }
                      : null,
                ),
              ),
            ],
          ),
          
          // Teacher controls
          if (widget.isTeacher) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Slower button
                IconButton(
                  icon: const Icon(Icons.fast_rewind),
                  tooltip: 'Slower (0.25x)',
                  onPressed: _audioSpeed > 0.5
                      ? () => _changeAudioSpeed((_audioSpeed - 0.25).clamp(0.5, 2.0))
                      : null,
                  color: Colors.purple.shade700,
                  iconSize: 28,
                ),
                
                const SizedBox(width: 8),
                
                // Skip backward 10s
                IconButton(
                  icon: const Icon(Icons.replay_10),
                  tooltip: 'Rewind 10s',
                  onPressed: () {
                    final newPosition = (_currentPosition - 10).clamp(0.0, _audioDuration ?? 0.0);
                    _seekAudio(newPosition);
                  },
                  color: Colors.purple.shade700,
                  iconSize: 28,
                ),
                
                const SizedBox(width: 16),
                
                // Play/Pause
                ElevatedButton.icon(
                  onPressed: _isPlayingSessionAudio ? _pauseSessionAudio : _playSessionAudio,
                  icon: Icon(
                    _isPlayingSessionAudio ? Icons.pause : Icons.play_arrow,
                    size: 28,
                  ),
                  label: Text(
                    _isPlayingSessionAudio ? 'Pause' : 'Play',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isPlayingSessionAudio ? Colors.orange : Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Skip forward 10s
                IconButton(
                  icon: const Icon(Icons.forward_10),
                  tooltip: 'Forward 10s',
                  onPressed: () {
                    final newPosition = (_currentPosition + 10).clamp(0.0, _audioDuration ?? 0.0);
                    _seekAudio(newPosition);
                  },
                  color: Colors.purple.shade700,
                  iconSize: 28,
                ),
                
                const SizedBox(width: 8),
                
                // Faster button
                IconButton(
                  icon: const Icon(Icons.fast_forward),
                  tooltip: 'Faster (0.25x)',
                  onPressed: _audioSpeed < 2.0
                      ? () => _changeAudioSpeed((_audioSpeed + 0.25).clamp(0.5, 2.0))
                      : null,
                  color: Colors.purple.shade700,
                  iconSize: 28,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Make UI more phone-friendly with larger touch targets
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    if (_isInitializing) {
      return Scaffold(
        backgroundColor: Colors.grey.shade900,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Colors.teal),
              const SizedBox(height: 20),
              Text(
                'Initializing session...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isMobile ? 16 : 18,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final participantsList = _participants.values.toList();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(
          'Session ${widget.sessionId}',
          style: TextStyle(fontSize: MediaQuery.of(context).size.width < 400 ? 16 : 20),
        ),
        backgroundColor: Colors.teal,
        actions: [
          // Invite students button for teachers
          if (widget.isTeacher)
            IconButton(
              icon: const Icon(Icons.person_add),
              tooltip: 'Invite Students',
              iconSize: 24,
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/invite_students',
                  arguments: {
                    'sessionId': widget.sessionId,
                    'sessionTitle': 'Session ${widget.sessionId}',
                  },
                );
              },
            ),
          // Audio library button for teachers
          if (widget.isTeacher)
            IconButton(
              icon: const Icon(Icons.library_music),
              tooltip: 'Audio Library',
              iconSize: 24,
              onPressed: _openAudioLibrary,
            ),
          // REMOVED: Participant count badge (causes overflow on small screens)
          // Leave button
          IconButton(
            icon: const Icon(Icons.call_end),
            tooltip: 'Leave',
            iconSize: 24,
            onPressed: _leaveSession,
          ),
        ],
      ),
      body: Column(
        children: [
          // Session audio status indicator with controls
          if (_currentAudioId != null)
            _buildAudioControlSection(),
          
          // Large mic status indicator - make more compact on small screens
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(MediaQuery.of(context).size.width < 400 ? 12 : 20),
            color: _muted ? Colors.red.shade50 : Colors.green.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width < 400 ? 50 : 80,
                  height: MediaQuery.of(context).size.width < 400 ? 50 : 80,
                  decoration: BoxDecoration(
                    color: _muted ? Colors.red : Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _muted ? Icons.mic_off : Icons.mic,
                    size: MediaQuery.of(context).size.width < 400 ? 24 : 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _muted ? 'MUTED' : 'LIVE',
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width < 400 ? 18 : 24,
                          fontWeight: FontWeight.bold,
                          color: _muted ? Colors.red : Colors.green,
                        ),
                      ),
                      Text(
                        widget.userName,
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width < 400 ? 12 : 16,
                          color: Colors.grey.shade700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Large action buttons - more compact on mobile
          Container(
            padding: EdgeInsets.all(MediaQuery.of(context).size.width < 400 ? 8 : 16),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _toggleMute,
                    icon: Icon(
                      _muted ? Icons.mic : Icons.mic_off,
                      size: MediaQuery.of(context).size.width < 400 ? 20 : 24,
                    ),
                    label: Text(
                      _muted ? 'Unmute' : 'Mute',
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width < 400 ? 14 : 16,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _muted ? Colors.green : Colors.red,
                      padding: EdgeInsets.symmetric(
                        vertical: MediaQuery.of(context).size.width < 400 ? 12 : 16,
                      ),
                      minimumSize: const Size(0, 48),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _toggleHandRaise,
                    icon: Icon(
                      _handRaised ? Icons.pan_tool : Icons.pan_tool_outlined,
                      size: MediaQuery.of(context).size.width < 400 ? 20 : 24,
                    ),
                    label: Text(
                      _handRaised ? 'Lower' : 'Raise',
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width < 400 ? 14 : 16,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _handRaised ? Colors.amber : Colors.grey,
                      padding: EdgeInsets.symmetric(
                        vertical: MediaQuery.of(context).size.width < 400 ? 12 : 16,
                      ),
                      minimumSize: const Size(0, 48),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // Participants and Chat split
          Expanded(
            child: MediaQuery.of(context).size.width < 600
                ? _buildMobileLayout(participantsList)
                : _buildDesktopLayout(participantsList),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(List<Map<String, dynamic>> participantsList) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Participants', icon: Icon(Icons.people)),
              Tab(text: 'Chat', icon: Icon(Icons.chat)),
            ],
            labelColor: Colors.teal,
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildParticipantsList(participantsList),
                _buildChatPanel(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(List<Map<String, dynamic>> participantsList) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _buildParticipantsList(participantsList),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          flex: 3,
          child: _buildChatPanel(),
        ),
      ],
    );
  }

  Widget _buildParticipantsList(List<Map<String, dynamic>> participantsList) {
    if (participantsList.isEmpty) {
      return const Center(
        child: Text(
          'Waiting for participants...',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: participantsList.length,
      itemBuilder: (context, index) {
        final p = participantsList[index];
        final participantId = p['id'] as int;
        final isSelf = participantId == _participantId;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            // Make it more compact for mobile
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            
            leading: CircleAvatar(
              backgroundColor: p['is_muted'] ? Colors.red : Colors.green,
              radius: 20, // Slightly smaller
              child: Icon(
                p['is_muted'] ? Icons.mic_off : Icons.mic,
                color: Colors.white,
                size: 18,
              ),
            ),
            
            title: Text(
              isSelf ? '${p['name']} (You)' : p['name'],
              style: TextStyle(
                fontWeight: isSelf ? FontWeight.bold : FontWeight.normal,
                fontSize: 14, // Smaller font for mobile
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            
            subtitle: Text(
              p['is_teacher'] ? 'Teacher' : 'Student',
              style: TextStyle(
                color: p['is_teacher'] ? Colors.teal : Colors.grey,
                fontSize: 12,
              ),
            ),
            
            trailing: Row(
              mainAxisSize: MainAxisSize.min, // IMPORTANT: Prevent overflow
              children: [
                // Raised hand indicator
                if (p['raised_hand'])
                  const Padding(
                    padding: EdgeInsets.only(right: 4),
                    child: Icon(Icons.pan_tool, color: Colors.amber, size: 20),
                  ),
                
                // Teacher controls - more compact
                if (widget.isTeacher && !isSelf) ...[
                  IconButton(
                    icon: Icon(
                      p['is_muted'] ? Icons.mic : Icons.mic_off,
                      size: 20,
                    ),
                    color: Colors.blue,
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(), // Remove default constraints
                    onPressed: () => _muteParticipant(participantId, !p['is_muted']),
                    tooltip: p['is_muted'] ? 'Unmute' : 'Mute',
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove_circle, size: 20),
                    color: Colors.red,
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(),
                    onPressed: () => _kickParticipant(participantId),
                    tooltip: 'Remove',
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }


  Widget _buildChatPanel() {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(12),
          color: Colors.teal.shade50,
          child: Row(
            children: [
              const Icon(Icons.chat, color: Colors.teal, size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Chat',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: Icon(_ttsEnabled ? Icons.volume_up : Icons.volume_off, size: 20),
                tooltip: 'Toggle TTS',
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(),
                onPressed: () {
                  setState(() => _ttsEnabled = !_ttsEnabled);
                  _speakIfEnabled(_ttsEnabled ? "TTS enabled" : "TTS disabled");
                },
              ),
            ],
          ),
        ),
        
        // Messages - with proper flex
        Expanded(
          child: _messages.isEmpty
              ? const Center(
                  child: Text(
                    'No messages yet',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                )
              : ListView.builder(
                  controller: _chatScrollController,
                  padding: const EdgeInsets.all(8),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    final isMe = msg['isMe'] ?? false;
                    
                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.7,
                        ),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.teal.shade100 : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              msg['sender'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              msg['text'],
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        
        // Input - more compact for mobile
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300,
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _chatController,
                    decoration: InputDecoration(
                      hintText: "Message...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      isDense: true,
                    ),
                    onSubmitted: (_) => _sendMessage(),
                    style: const TextStyle(fontSize: 14),
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Colors.teal,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 20),
                    padding: EdgeInsets.zero,
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}