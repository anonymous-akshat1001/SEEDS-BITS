// this import provides JSON encoding/decoding 
import 'dart:convert';
import 'dart:async';
// Flutter WebRTC library
import 'package:flutter_webrtc/flutter_webrtc.dart';
// Provides websocket support
import 'package:web_socket_channel/web_socket_channel.dart';
// Text to Speech engine
import 'package:flutter_tts/flutter_tts.dart';
// Allows reading environment variables
import 'package:flutter_dotenv/flutter_dotenv.dart';
// Helps build the websocket link
import 'url_helper.dart';

// Backend and websocket URL
final baseUrl = dotenv.env['API_BASE_URL'];
// final wsBaseUrl = dotenv.env['WS_BASE_URL'];

// Define a service class which handles all real time communication logic
class RtcService {
  // constructor parameters
  final int sessionId;
  final int userId;

  // websocket connection, late means will be initialized later but guaranteed before use
  late WebSocketChannel _ws;
  // maps remoteUserId → WebRTC peer connection
  final Map<int, RTCPeerConnection> _peers = {};
  // Stores incoming audio streams, one per remote participant
  final Map<int, MediaStream> _remoteStreams = {};
  // The microphones audio stream(nullable)
  MediaStream? _localStream;

  // WebRTC configuration
  final _rtcConfig = {
    'iceServers': [
      // STUN server helps peers discover public IPs and connect across NATs
      {'urls': 'stun:stun.l.google.com:19302'},
      // Google's STUN serever is free, reliable
    ]
  };

  // TTS instance
  final FlutterTts _tts = FlutterTts();

  // Constructor which forces caller to provide user and session ids
  RtcService({required this.sessionId, required this.userId});

  // Entry point - called when session starts
  Future<void> init() async {
    // Initialize local media - returns a Mediastream
    _localStream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': false,
    });

    // Builds signalling URL
    final wsUrl = buildSessionWebSocketUrl(
      sessionId: sessionId,
      userId: userId,
    );
    // final wsUrl = '$wsBaseUrl/ws/sessions/$sessionId?user_id=$userId';

    // opens websocket connection and keeps it open for real time signalling
    _ws = WebSocketChannel.connect(
      Uri.parse(wsUrl),
    );

    // Continuosly listen for messages
    _ws.stream.listen(
      (event) {
        // Converts JSON string → Map
        final data = jsonDecode(event);
        // this method handles incoming WS events
        _onWsMessage(data); 
      },
      // Triggered when WebSocket closes
      onDone: () => _tts.speak("Connection closed."),
      // Triggered on connection failure
      onError: (e) => _tts.speak("Network error"),
    );

    _tts.speak("Connected to session $sessionId");
  }

  // Exposes local audio stream
  MediaStream? get localStream => _localStream;

  // Handle WebSocket Messages - central router for signaling messages
  void _onWsMessage(Map<String, dynamic> data) async {
    // determine message type
    final event = data['event'];

    // each message has an event type
    switch (event) {
      case 'joined':
        // remote participant idea
        final pid = data['participant_id'];
        _tts.speak("Participant $pid joined.");
        // start WebRTC connection with that participant
        await _createPeer(pid);
        break;

      case 'left':
        final pid = data['participant_id'];
        _tts.speak("Participant $pid left.");
        // close peer connection and free resources
        _closePeer(pid);
        break;

      // backend informed about mute/unmute
      case 'mute_changed':
        final pid = data['participant_id'];
        final muted = data['muted'];
        _tts.speak("Participant $pid is now ${muted ? 'muted' : 'unmuted'}");
        break;

      case 'chat':
        final msg = data['message'];
        // reads message aloud
        _tts.speak("Message: $msg");
        break;

      // audio playback sync
      case 'audio_play':
        final audioId = data['audio_id'];
        _tts.speak("Teacher started playing audio $audioId");
        // Optional: trigger synced playback here
        break;

      default:
        print('Unhandled WS event: $data');
    }
  }

  // Peer Connection Management - creates a peer connection with one participant
  Future<void> _createPeer(int remoteId) async {
    
    // Prevents duplicate connections
    if (_peers.containsKey(remoteId)){
      return;
    }

    // creates webrtc peer connection using STUN config
    final pc = await createPeerConnection(_rtcConfig);
    // stores connection
    _peers[remoteId] = pc;

    // Add local stream(audio) to connection
    if (_localStream != null) {
      // sends mic audio to peer
      for (var track in _localStream!.getTracks()) {
        pc.addTrack(track, _localStream!);
      }
    }

    // Handle remote stream of audio
    pc.onTrack = (RTCTrackEvent event) {
      if (event.streams.isNotEmpty) {
        // Saves incoming audio stream
        _remoteStreams[remoteId] = event.streams[0];
        _tts.speak("Audio stream started for participant $remoteId");
      }
    };

    // Handle ICE - candidates which are network paths
    pc.onIceCandidate = (RTCIceCandidate candidate) {
      // Sends ICE data to backend which forwards it to other peer
      _ws.sink.add(jsonEncode({
        'type': 'ice',
        'to': remoteId,
        'candidate': {
          'candidate': candidate.candidate,
          'sdpMid': candidate.sdpMid,
          'sdpMLineIndex': candidate.sdpMLineIndex,
        },
      }));
    };

    // Create offer - WebRTC offer = “I want to connect like this”
    final offer = await pc.createOffer();

    // saves offer locally
    await pc.setLocalDescription(offer);
    // Sends offer to remote peer via backend
    _ws.sink.add(jsonEncode({
      'type': 'offer',
      'to': remoteId,
      'from': userId,
      'sdp': offer.sdp,
    }));
  }

  // Close peer connection - called when participant leaves
  void _closePeer(int remoteId) {
    final pc = _peers.remove(remoteId);
    final stream = _remoteStreams.remove(remoteId);

    // frees memory
    stream?.dispose();
    pc?.close();
  }

  // Cleanup when session ends or participant leaves
  Future<void> dispose() async {
    // close all peer connections
    for (final pc in _peers.values) {
      await pc.close();
    }
    _peers.clear();
    _remoteStreams.clear();
    // stops microphone
    await _localStream?.dispose();
    await _tts.speak("Disconnected");
    // close signalling channel
    _ws.sink.close();
  }

  // send chat via websocket
  void sendChatMessage(String text) {
    // encodes message and backend distibutes to participants
    _ws.sink.add(jsonEncode({
      'type': 'chat',
      'message': text,
      'from': userId,
    }));
  }
}
