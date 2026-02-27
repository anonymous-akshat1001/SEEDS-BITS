// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../services/sse_service.dart';
import 'invite_students_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/services.dart';
import '../utils/ui_utils.dart';



final baseUrl = dotenv.env['API_BASE_URL'];


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
  // ── WebRTC ─────────────────────────────────────────────────────────────
  MediaStream?                         _localStream;
  final Map<int, RTCPeerConnection>    _peerConnections  = {};
  final Map<int, RTCVideoRenderer>     _remoteRenderers  = {};

  // ICE candidate batching — collect candidates for 150 ms then send as one POST
  final Map<int, List<Map<String, dynamic>>> _pendingIceCandidates = {};
  final Map<int, Timer>                      _iceTimers            = {};

  // ── SSE transport ──────────────────────────────────────────────────────
  final SseService _sse = SseService();

  // ── audio ──────────────────────────────────────────────────────────────
  final FlutterTts   _tts              = FlutterTts();
  final AudioPlayer  _sessionAudioPlayer = AudioPlayer();

  // ── UI state ───────────────────────────────────────────────────────────
  bool    _muted                = false;
  bool    _handRaised           = false;
  bool    _ttsEnabled           = true;
  bool    _isInitializing       = true;

  // Set from the SSE 'connected' event — authoritative server-assigned id
  int?    _participantId;

  // Audio
  int?    _currentAudioId;
  String? _currentAudioTitle;
  bool    _isPlayingSessionAudio = false;
  double  _audioSpeed            = 1.0;
  double? _audioDuration;
  double  _currentPosition       = 0.0;
  bool    _isSeeking             = false;

  // Chat & participants
  final TextEditingController          _chatController    = TextEditingController();
  final List<Map<String, dynamic>>     _messages          = [];
  final Map<int, Map<String, dynamic>> _participants      = {};
  final ScrollController               _chatScrollController = ScrollController();

  // ── Audio library panel toggle (teacher) ───────────────────────────────
  bool _showAudioPanel = false;

  // ── Audio library (teacher only) ────────────────────────────────────────
  List<Map<String, dynamic>> _audioFiles        = [];
  bool                       _audioLibraryLoaded = false;
  bool                       _isUploadingAudio   = false;
  int?                       _previewingAudioId;
  final AudioPlayer          _previewPlayer      = AudioPlayer();
  final TextEditingController _uploadTitleCtrl   = TextEditingController();
  final TextEditingController _uploadDescCtrl    = TextEditingController();

  // WebRTC config
  final Map<String, dynamic> _iceServers = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
      {'urls': 'stun:stun1.l.google.com:19302'},
    ],
    'sdpSemantics': 'unified-plan',
  };
  final FocusNode _screenFocusNode = FocusNode();

  // ── lifecycle ───────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _initialize();
    _screenFocusNode.requestFocus();

    _sessionAudioPlayer.onPositionChanged.listen((pos) {
      if (mounted && !_isSeeking) {
        setState(() => _currentPosition = pos.inSeconds.toDouble());
      }
    });
    _sessionAudioPlayer.onDurationChanged.listen((dur) {
      if (mounted) setState(() => _audioDuration = dur.inSeconds.toDouble());
    });
    _sessionAudioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() { _isPlayingSessionAudio = false; _currentPosition = 0; });
        _speakIfEnabled("Playback finished");
      }
    });

    // Preview player for audio library
    _previewPlayer.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _previewingAudioId = null);
    });
    _previewPlayer.onPlayerStateChanged.listen((state) {
      if (mounted && state == PlayerState.stopped) {
        setState(() => _previewingAudioId = null);
      }
    });
  }

  Future<void> _initialize() async {
    try {
      print('[INIT] Starting…');
      await _initializeMedia();

      // Join the session HTTP-side so a Participant row exists before SSE connects.
      // The SSE endpoint also creates the row if absent, but calling join first
      // ensures _participantId is known slightly earlier.
      await _joinSessionHttp();

      // Open the SSE stream — this also creates the participant row server-side
      // and returns the authoritative participant_id via the 'connected' event.
      _connectSse();

      // Pre-load audio library for teacher so the panel is ready immediately
      if (widget.isTeacher) _loadAudioLibrary();

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
      _localStream = await navigator.mediaDevices.getUserMedia({
        'audio': {
          'mandatory': {
            'googEchoCancellation': true,
            'googNoiseSuppression': true,
            'googAutoGainControl':  true,
          },
          'optional': [],
        },
        'video': false,
      });
      _localStream!.getAudioTracks().forEach((t) => t.enabled = !_muted);
      print('[MEDIA] Local stream ready');
    } catch (e) {
      print('[MEDIA ERROR] $e');
      throw Exception('Microphone permission denied');
    }
  }

  /// HTTP join — ensures a Participant row exists and caches participant_id.
  Future<void> _joinSessionHttp() async {
    try {
      final result = await ApiService.joinSession(widget.sessionId);
      if (result != null && result['participant_id'] != null) {
        // This may be overwritten by the SSE 'connected' event, which is fine.
        _participantId = result['participant_id'] as int?;
        print('[JOIN] HTTP participant_id=$_participantId');
      }
    } catch (e) {
      print('[JOIN HTTP ERROR] $e');
      // Non-fatal: SSE endpoint will create the participant row too.
    }
  }

  // ── SSE connection ──────────────────────────────────────────────────────

  void _connectSse() {
    _sse.connect(
      widget.sessionId.toString(),
      widget.userId,
      _handleSseMessage,
    );
  }

  void _handleSseMessage(Map<String, dynamic> data) {
    final type = data['type'] as String? ?? '';
    print('[SSE RECV] $type');

    switch (type) {
      // ── connection bootstrap ─────────────────────────────────────────
      case 'connected':
        // Server tells us our authoritative participant_id
        final pid = data['participant_id'] as int?;
        if (pid != null) {
          setState(() => _participantId = pid);
          print('[SSE] Server assigned participant_id=$pid');
        }

      case 'session_state':
        _updateSessionState(data);

      // ── participant presence ─────────────────────────────────────────
      case 'participant_joined':
        _onParticipantJoined(data);

      case 'participant_left':
        _onParticipantLeft(data);

      case 'participant_kicked':
        // Another participant was kicked — remove them from local list
        final pid = data['participant_id'] as int?;
        if (pid != null && pid != _participantId) {
          setState(() => _participants.remove(pid));
          _closePeerConnection(pid);
        }

      // ── mute / hand ──────────────────────────────────────────────────
      case 'participant_muted':
        _onParticipantMuted(data);

      case 'hand_raised':
        _onHandChanged(data, true);

      case 'hand_lowered':
        _onHandChanged(data, false);

      // ── chat ─────────────────────────────────────────────────────────
      case 'chat':
        _onChatMessage(data);

      // ── kicked / session ended ───────────────────────────────────────
      case 'kicked':
        _onKicked(data);

      case 'session_ended':
      case 'session_ending':
        _onSessionEnded();

      // ── WebRTC signalling ────────────────────────────────────────────
      case 'webrtc_signal':
        _handleWebRTCSignal(data);

      // ── audio ────────────────────────────────────────────────────────
      case 'audio_selected':
        _onAudioSelected(data);

      case 'audio_play':
        _onAudioPlay(data);

      case 'audio_pause':
        _onAudioPause(data);

      case 'audio_seek':
        _onAudioSeek(data);

      case 'audio_speed_change':
        // data['speed'] is a num from JSON
        final newSpeed = (data['speed'] as num?)?.toDouble();
        if (newSpeed != null) _applyAudioSpeedLocally(newSpeed);

      case 'error':
        print('[SSE SERVER ERROR] ${data['detail']}');
        _showSnackError(data['detail']?.toString() ?? 'Server error');

      default:
        print('[SSE] Unhandled type: $type');
    }
  }

  // ── session state snapshot ──────────────────────────────────────────────

  void _updateSessionState(Map<String, dynamic> data) {
    print('[STATE] Updating session state…');
    final participants = data['participants'] as Map<String, dynamic>? ?? {};

    setState(() {
      _participants.clear();

      participants.forEach((key, value) {
        final pid  = int.tryParse(key);
        if (pid == null || pid == 0) return;

        final meta = value as Map<String, dynamic>;
        _participants[pid] = {
          'id':         pid,
          'user_id':    meta['user_id'],
          'name':       meta['name'] ?? 'User ${meta['user_id']}',
          'is_muted':   meta['is_muted']   ?? false,
          'raised_hand': meta['raised_hand'] ?? false,
          // is_teacher is now stored server-side and included in the snapshot
          'is_teacher': meta['is_teacher']  ?? false,
        };
      });
    });

    print('[STATE] ${_participants.length} participants');

    // Also restore audio playback state if the session was already playing
    final playback = data['playback'] as Map<String, dynamic>?;
    if (playback != null && playback['status'] == 'playing') {
      final audioId  = playback['audio_id'] as int?;
      final speed    = (playback['speed']   as num?)?.toDouble() ?? 1.0;
      final position = (playback['position'] as num?)?.toDouble() ?? 0.0;
      if (audioId != null) {
        _onAudioPlay({
          'audio_id': audioId,
          'speed':    speed,
          'position': position,
          'title':    playback['title'],
        });
      }
    }

    // Initiate WebRTC with every existing participant (except self)
    final myPid = _participantId;
    if (myPid != null) {
      _participants.keys
          .where((pid) => pid != myPid)
          .where((pid) => !_peerConnections.containsKey(pid))
          .forEach((pid) => _createPeerConnection(pid, true));
    }
  }

  // ── participant events ──────────────────────────────────────────────────

  void _onParticipantJoined(Map<String, dynamic> data) {
    final pid       = data['participant_id'] as int?;
    final uid       = data['user_id']       as int?;
    final name      = data['name']          as String? ?? 'User $uid';
    final isTeacher = data['is_teacher']    as bool?   ?? false;

    if (pid == null || pid == _participantId) return;

    print('[PARTICIPANT] Joined: $name (pid=$pid)');

    setState(() {
      _participants[pid] = {
        'id':         pid,
        'user_id':    uid,
        'name':       name,
        'is_muted':   false,
        'raised_hand': false,
        'is_teacher': isTeacher,
      };
    });

    _speakIfEnabled('$name joined');

    // Give a short delay so both sides have their SSE streams open
    // before we attempt WebRTC negotiation.
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted && !_peerConnections.containsKey(pid)) {
        // The participant with the higher id creates the offer.
        // This prevents both sides creating offers simultaneously.
        final myPid = _participantId ?? 0;
        _createPeerConnection(pid, myPid > pid);
      }
    });
  }

  void _onParticipantLeft(Map<String, dynamic> data) {
    final pid = data['participant_id'] as int?;
    if (pid == null) return;

    final name = _participants[pid]?['name'] as String? ?? 'Someone';
    setState(() => _participants.remove(pid));
    _closePeerConnection(pid);
    _speakIfEnabled('$name left');
  }

  void _onParticipantMuted(Map<String, dynamic> data) {
    final pid     = data['participant_id'] as int?;
    final isMuted = data['is_muted']       as bool? ?? false;
    if (pid == null) return;

    setState(() {
      if (_participants.containsKey(pid)) {
        _participants[pid]!['is_muted'] = isMuted;
      }
      // If it's about us, update our local mute state too
      if (pid == _participantId) _muted = isMuted;
    });
  }

  void _onHandChanged(Map<String, dynamic> data, bool raised) {
    final pid = data['participant_id'] as int?;
    if (pid == null) return;

    setState(() {
      if (_participants.containsKey(pid)) {
        _participants[pid]!['raised_hand'] = raised;
      }
    });

    if (raised && widget.isTeacher) {
      final name = _participants[pid]?['name'] ?? 'Someone';
      _speakIfEnabled('$name raised their hand');
    }
  }

  // ── chat ────────────────────────────────────────────────────────────────

  void _onChatMessage(Map<String, dynamic> data) {
    final senderName = data['sender_name'] as String? ?? 'Unknown';
    final text       = data['text']        as String? ?? '';
    final isOwn      = data['is_own']      as bool?   ?? false;

    if (text.isEmpty) return;

    // isOwn is set by SseService by comparing data['from'] == _myParticipantId.
    // We already added our own message optimistically in _sendMessage(),
    // so skip duplicates from the echo-back.
    if (isOwn) return;

    setState(() {
      _messages.add({
        'sender':    senderName,
        'text':      text,
        'timestamp': DateTime.now(),
        'isMe':      false,
      });
    });

    _scrollChatToBottom();
    _speakIfEnabled('$senderName: $text');
  }

  void _onKicked(Map<String, dynamic> data) {
    _speakIfEnabled('You have been removed from the session');
    if (mounted) Navigator.pop(context);
  }

  void _onSessionEnded() {
    _speakIfEnabled('Session ended');
    if (mounted) Navigator.pop(context);
  }

  // ── audio playback ──────────────────────────────────────────────────────

  void _onAudioSelected(Map<String, dynamic> data) {
    final audioId = data['audio_id'] as int?;
    final title   = data['title']   as String?;
    if (audioId == null) return;
    setState(() { _currentAudioId = audioId; _currentAudioTitle = title; });
    _speakIfEnabled('Audio selected: ${title ?? "Unknown"}');
  }

  Future<void> _onAudioPlay(Map<String, dynamic> data) async {
    final audioId  = data['audio_id'] as int?;
    final speed    = (data['speed']   as num?)?.toDouble() ?? 1.0;
    final position = (data['position'] as num?)?.toDouble() ?? 0.0;
    final title    = data['title']    as String?;
    final duration = (data['duration'] as num?)?.toDouble();

    if (audioId == null) return;

    try {
      setState(() {
        _currentAudioId        = audioId;
        _currentAudioTitle     = title ?? _currentAudioTitle;
        _isPlayingSessionAudio = true;
        _audioSpeed            = speed;
        _currentPosition       = position;
        if (duration != null) _audioDuration = duration;
      });

      await _sessionAudioPlayer.stop();
      await _sessionAudioPlayer.setPlaybackRate(speed);
      await _sessionAudioPlayer.play(UrlSource('$baseUrl/audio/$audioId/stream'));
      if (position > 0) {
        await _sessionAudioPlayer.seek(Duration(seconds: position.toInt()));
      }
    } catch (e) {
      print('[AUDIO PLAY ERROR] $e');
      setState(() => _isPlayingSessionAudio = false);
    }
  }

  Future<void> _onAudioPause(Map<String, dynamic> data) async {
    final position = (data['position'] as num?)?.toDouble();
    await _sessionAudioPlayer.pause();
    setState(() {
      _isPlayingSessionAudio = false;
      if (position != null) _currentPosition = position;
    });
  }

  Future<void> _onAudioSeek(Map<String, dynamic> data) async {
    final position     = (data['position']      as num?)?.toDouble() ?? 0.0;
    final resumePlaying = data['resume_playing'] as bool? ?? false;
    await _sessionAudioPlayer.seek(Duration(seconds: position.toInt()));
    setState(() => _currentPosition = position);
    if (resumePlaying && !_isPlayingSessionAudio) {
      await _sessionAudioPlayer.resume();
      setState(() => _isPlayingSessionAudio = true);
    }
  }

  void _applyAudioSpeedLocally(double speed) {
    setState(() => _audioSpeed = speed);
    _sessionAudioPlayer.setPlaybackRate(speed);
  }

  // ── teacher audio controls ──────────────────────────────────────────────

  Future<void> _playSessionAudio() async {
    if (_currentAudioId == null) return;
    final result = await ApiService.controlAudio(
      widget.sessionId,
      action:   'play',
      audioId:  _currentAudioId!,
      speed:    _audioSpeed,
      position: _currentPosition,
    );
    if (result != null && result['ok'] == true) {
      setState(() => _isPlayingSessionAudio = true);
    }
  }

  Future<void> _pauseSessionAudio() async {
    final pos = await _sessionAudioPlayer.getCurrentPosition();
    final posSeconds = pos?.inSeconds.toDouble() ?? _currentPosition;
    setState(() { _currentPosition = posSeconds; _isPlayingSessionAudio = false; });
    await _sessionAudioPlayer.pause();
    await ApiService.controlAudio(widget.sessionId, action: 'pause', position: posSeconds);
  }

  Future<void> _seekAudio(double position) async {
    if (!widget.isTeacher) return;
    setState(() => _isSeeking = true);
    try {
      await ApiService.controlAudio(widget.sessionId, action: 'seek', position: position);
      await _sessionAudioPlayer.seek(Duration(seconds: position.toInt()));
      setState(() => _currentPosition = position);
    } finally {
      setState(() => _isSeeking = false);
    }
  }

  Future<void> _changeAudioSpeed(double newSpeed) async {
    if (!widget.isTeacher || _currentAudioId == null) return;
    setState(() => _audioSpeed = newSpeed);
    await _sessionAudioPlayer.setPlaybackRate(newSpeed);
    final pos = await _sessionAudioPlayer.getCurrentPosition();
    await ApiService.controlAudio(
      widget.sessionId,
      action:   'play',
      audioId:  _currentAudioId!,
      speed:    newSpeed,
      position: pos?.inSeconds.toDouble() ?? _currentPosition,
    );
  }

  // ── user actions (sent via HTTP POST) ───────────────────────────────────

  void _toggleMute() async {
    setState(() => _muted = !_muted);
    _localStream?.getAudioTracks().forEach((t) => t.enabled = !_muted);
    await _sse.send({'type': 'mute_self', 'mute': _muted});
    await _speakIfEnabled(_muted ? 'Muted' : 'Unmuted');
  }

  void _toggleHandRaise() async {
    setState(() => _handRaised = !_handRaised);
    await _sse.send({'type': _handRaised ? 'raise_hand' : 'lower_hand'});
    await _speakIfEnabled(_handRaised ? 'Hand raised' : 'Hand lowered');
  }

  /// Chat send: add to UI immediately (optimistic) then POST to server.
  /// The server will echo the message back via SSE, but SseService marks it
  /// is_own=true so _onChatMessage skips it — no duplicate.
  void _sendMessage() {
    final text = _chatController.text.trim();
    if (text.isEmpty) return;

    // Optimistic local insert
    setState(() {
      _messages.add({
        'sender':    widget.userName,
        'text':      text,
        'timestamp': DateTime.now(),
        'isMe':      true,
      });
    });
    _chatController.clear();
    _scrollChatToBottom();

    // Fire-and-forget POST
    _sse.send({'type': 'chat', 'text': text});
  }

  void _muteParticipant(int participantId, bool mute) {
    _sse.send({
      'type':                  mute ? 'mute_participant' : 'unmute_participant',
      'target_participant_id': participantId,
    });
  }

  void _kickParticipant(int participantId) {
    _sse.send({'type': 'kick_participant', 'target_participant_id': participantId});
  }

  void _leaveSession() async {
    await _speakIfEnabled('Leaving session');
    if (mounted) Navigator.pop(context);
  }

  // ── Invite participants (teacher only) ───────────────────────────────────

  void _openInviteScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InviteStudentsScreen(
          sessionId:    widget.sessionId,
          sessionTitle: 'Session ${widget.sessionId}',
        ),
      ),
    );
  }

  // ── Audio library (teacher only) ─────────────────────────────────────────

  Future<void> _loadAudioLibrary() async {
    try {
      final result = await ApiService.get('/audio/list', useAuth: true);
      if (result != null && mounted) {
        setState(() {
          _audioLibraryLoaded = true;
          if (result is List) {
            _audioFiles = result.cast<Map<String, dynamic>>();
          } else if (result is Map && result.containsKey('files')) {
            _audioFiles = (result['files'] as List).cast<Map<String, dynamic>>();
          }
        });
      }
    } catch (e) {
      print('[AUDIO LIST ERROR] $e');
    }
  }

  Future<void> _uploadAudio() async {
    try {
      final picked = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );
      if (picked == null || picked.files.isEmpty) return;
      final file = picked.files.first;

      _uploadTitleCtrl.clear();
      _uploadDescCtrl.clear();

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Upload Audio'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('File: ${file.name}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextField(
                  controller: _uploadTitleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Title *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _uploadDescCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Upload', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
      if (confirmed != true) return;

      final title = _uploadTitleCtrl.text.trim();
      if (title.isEmpty) {
        _showSnackError('Title is required');
        return;
      }

      if (mounted) setState(() => _isUploadingAudio = true);

      final prefs  = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');
      final uri    = Uri.parse('$baseUrl/audio/upload?user_id=$userId');
      final headers = await ApiService.getHeaders();

      final request = http.MultipartRequest('POST', uri)
        ..headers.addAll(headers)
        ..fields['title']       = title
        ..fields['description'] = _uploadDescCtrl.text.trim();

      final ext = file.extension?.toLowerCase() ?? '';
      final contentType = const {
        'mp3':  'audio/mpeg',
        'wav':  'audio/wav',
        'm4a':  'audio/x-m4a',
        'mp4':  'audio/mp4',
        'ogg':  'audio/ogg',
        'webm': 'audio/webm',
      }[ext] ?? 'audio/mpeg';

      if (kIsWeb && file.bytes != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'file', file.bytes!,
          filename: file.name,
          contentType: MediaType.parse(contentType),
        ));
      } else if (!kIsWeb && file.path != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'file', file.path!,
          filename: file.name,
          contentType: MediaType.parse(contentType),
        ));
      }

      final response     = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        _speakIfEnabled('Upload successful');
        await _loadAudioLibrary();
      } else {
        final detail = (jsonDecode(responseBody) as Map)['detail'] ?? 'Upload failed';
        _showSnackError(detail.toString());
      }
    } catch (e) {
      _showSnackError('Upload error: $e');
    } finally {
      if (mounted) setState(() => _isUploadingAudio = false);
    }
  }

  Future<void> _previewAudio(int audioId, String title) async {
    if (_previewingAudioId == audioId) {
      await _previewPlayer.stop();
      if (mounted) setState(() => _previewingAudioId = null);
      return;
    }
    await _previewPlayer.stop();
    await _previewPlayer.play(UrlSource('$baseUrl/audio/$audioId/stream'));
    if (mounted) setState(() => _previewingAudioId = audioId);
    _speakIfEnabled('Previewing $title');
  }

  Future<void> _selectAndPlayAudio(int audioId, String title) async {
    // Tell server which audio is selected — broadcasts audio_selected to all
    final selected = await ApiService.selectAudio(widget.sessionId, audioId);
    if (selected == null || selected['ok'] != true) {
      _showSnackError('Failed to select audio');
      return;
    }
    if (mounted) setState(() { _currentAudioId = audioId; _currentAudioTitle = title; });

    // Ask teacher whether to play now
    if (!mounted) return;
    final play = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Audio Selected'),
        content: Text('Play "$title" for all participants now?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Not Yet'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Play Now', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (play == true) {
      await ApiService.controlAudio(
        widget.sessionId,
        action: 'play',
        audioId: audioId,
        speed: 1.0,
        position: 0.0,
      );
      _speakIfEnabled('Playing $title for all participants');
    }
  }

  // ── WebRTC ──────────────────────────────────────────────────────────────

  Future<void> _createPeerConnection(int participantId, bool createOffer) async {
    if (_peerConnections.containsKey(participantId)) return;

    print('[WebRTC] Creating connection pid=$participantId offer=$createOffer');

    final pc = await createPeerConnection(_iceServers);
    _peerConnections[participantId] = pc;

    _localStream?.getTracks().forEach((track) => pc.addTrack(track, _localStream!));

    pc.onTrack = (event) {
      if (event.streams.isNotEmpty) _handleRemoteStream(participantId, event.streams[0]);
    };

    // Batch ICE candidates: collect for 150 ms then send as a single POST
    pc.onIceCandidate = (candidate) {
      if (candidate == null) return;
      _pendingIceCandidates
          .putIfAbsent(participantId, () => [])
          .add({
            'candidate':     candidate.candidate,
            'sdpMid':        candidate.sdpMid,
            'sdpMLineIndex': candidate.sdpMLineIndex,
          });

      // Reset or start the flush timer
      _iceTimers[participantId]?.cancel();
      _iceTimers[participantId] = Timer(const Duration(milliseconds: 150), () {
        _flushIceCandidates(participantId);
      });
    };

    pc.onConnectionState = (state) {
      print('[WebRTC] State with pid=$participantId: $state');
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateFailed ||
          state == RTCPeerConnectionState.RTCPeerConnectionStateClosed) {
        _closePeerConnection(participantId);
      }
    };

    if (createOffer) {
      await Future.delayed(const Duration(milliseconds: 100));
      final offer = await pc.createOffer();
      await pc.setLocalDescription(offer);
      await _sse.send({
        'type':                  'webrtc_signal',
        'target_participant_id': participantId,
        'payload': {'type': 'offer', 'sdp': offer.sdp},
      });
    }
  }

  /// Send all buffered ICE candidates for a peer in a single POST.
  /// A single POST with multiple candidates is faster than N individual POSTs.
  Future<void> _flushIceCandidates(int participantId) async {
    final candidates = _pendingIceCandidates.remove(participantId);
    _iceTimers.remove(participantId);
    if (candidates == null || candidates.isEmpty) return;

    print('[WebRTC] Flushing ${candidates.length} ICE candidates to pid=$participantId');

    await _sse.send({
      'type':                  'webrtc_signal',
      'target_participant_id': participantId,
      'payload': {'type': 'ice_candidates_batch', 'candidates': candidates},
    });
  }

  void _handleRemoteStream(int participantId, MediaStream stream) {
    if (!_remoteRenderers.containsKey(participantId)) {
      final renderer = RTCVideoRenderer();
      renderer.initialize().then((_) {
        renderer.srcObject = stream;
        if (mounted) setState(() => _remoteRenderers[participantId] = renderer);
      });
    } else {
      _remoteRenderers[participantId]!.srcObject = stream;
    }
  }

  Future<void> _handleWebRTCSignal(Map<String, dynamic> data) async {
    final fromPid  = data['from']    as int?;
    final toPid    = data['to']      as int?;
    final payload  = data['payload'] as Map<String, dynamic>?;

    if (fromPid == null || payload == null) return;
    // Ignore signals not addressed to us
    if (toPid != null && toPid != _participantId) return;

    final signalType = payload['type'] as String?;
    print('[WebRTC] Signal from=$fromPid type=$signalType');

    switch (signalType) {
      case 'offer':
        await _handleOffer(fromPid, payload);
      case 'answer':
        await _handleAnswer(fromPid, payload);
      case 'ice_candidate':
        await _handleIceCandidateSingle(fromPid, payload);
      case 'ice_candidates_batch':
        await _handleIceCandidateBatch(fromPid, payload);
    }
  }

  Future<void> _handleOffer(int fromPid, Map<String, dynamic> payload) async {
    final sdp = payload['sdp'] as String?;
    if (sdp == null) return;
    if (!_peerConnections.containsKey(fromPid)) {
      await _createPeerConnection(fromPid, false);
    }
    final pc = _peerConnections[fromPid]!;
    await pc.setRemoteDescription(RTCSessionDescription(sdp, 'offer'));
    final answer = await pc.createAnswer();
    await pc.setLocalDescription(answer);
    await _sse.send({
      'type':                  'webrtc_signal',
      'target_participant_id': fromPid,
      'payload': {'type': 'answer', 'sdp': answer.sdp},
    });
  }

  Future<void> _handleAnswer(int fromPid, Map<String, dynamic> payload) async {
    final sdp = payload['sdp'] as String?;
    if (sdp == null) return;
    await _peerConnections[fromPid]
        ?.setRemoteDescription(RTCSessionDescription(sdp, 'answer'));
  }

  Future<void> _handleIceCandidateSingle(
      int fromPid, Map<String, dynamic> payload) async {
    final c = payload['candidate'] as Map<String, dynamic>?;
    if (c == null) return;
    await _peerConnections[fromPid]?.addCandidate(RTCIceCandidate(
      c['candidate'], c['sdpMid'], c['sdpMLineIndex'],
    ));
  }

  Future<void> _handleIceCandidateBatch(
      int fromPid, Map<String, dynamic> payload) async {
    final list = payload['candidates'] as List<dynamic>?;
    if (list == null) return;
    final pc = _peerConnections[fromPid];
    if (pc == null) return;
    for (final c in list) {
      final cm = c as Map<String, dynamic>;
      try {
        await pc.addCandidate(RTCIceCandidate(
          cm['candidate'], cm['sdpMid'], cm['sdpMLineIndex'],
        ));
      } catch (e) {
        print('[WebRTC] ICE add error: $e');
      }
    }
    print('[WebRTC] Applied ${list.length} ICE candidates from pid=$fromPid');
  }

  void _closePeerConnection(int participantId) {
    _iceTimers.remove(participantId)?.cancel();
    _pendingIceCandidates.remove(participantId);
    _peerConnections.remove(participantId)?.close();
    _remoteRenderers.remove(participantId)?.dispose();
  }

  // ── helpers ─────────────────────────────────────────────────────────────

  Future<void> _speakIfEnabled(String text) async {
    if (_ttsEnabled && mounted) {
      try { await _tts.speak(text); } catch (_) {}
    }
  }

  void _showSnackError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  void _scrollChatToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_chatScrollController.hasClients) {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve:    Curves.easeOut,
        );
      }
    });
  }

  String _formatDuration(double seconds) {
    final d = Duration(seconds: seconds.toInt());
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    return h > 0
        ? '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}'
        : '$m:${s.toString().padLeft(2, '0')}';
  }

  // ── dispose ─────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _chatController.dispose();
    _chatScrollController.dispose();
    _uploadTitleCtrl.dispose();
    _uploadDescCtrl.dispose();

    _sse.close();

    _localStream?.dispose();
    for (final pc in _peerConnections.values) { pc.close(); }
    for (final r  in _remoteRenderers.values) { r.dispose(); }
    for (final t  in _iceTimers.values)       { t.cancel(); }

    _sessionAudioPlayer.dispose();
    _previewPlayer.stop();
    _previewPlayer.dispose();
    _tts.stop();
    _screenFocusNode.dispose();
    super.dispose();
  }


  // ── UI ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _screenFocusNode,
      onKeyEvent: (KeyEvent event) {
        if (event is KeyDownEvent) {
          final key = event.logicalKey;
          if (key == LogicalKeyboardKey.digit1 || key == LogicalKeyboardKey.numpad1) {
            _toggleMute();
          } else if (key == LogicalKeyboardKey.digit2 || key == LogicalKeyboardKey.numpad2) {
            _toggleHandRaise();
          } else if ((key == LogicalKeyboardKey.digit3 || key == LogicalKeyboardKey.numpad3) && widget.isTeacher) {
            _openInviteScreen();
          } else if ((key == LogicalKeyboardKey.digit4 || key == LogicalKeyboardKey.numpad4) && widget.isTeacher) {
            setState(() => _showAudioPanel = !_showAudioPanel);
          } else if (key == LogicalKeyboardKey.asterisk || key == LogicalKeyboardKey.numpadMultiply) {
            _leaveSession();
          }
        }
      },
      child: _buildMainScaffold(context),
    );
  }

  Widget _buildMainScaffold(BuildContext context) {
    if (_isInitializing) {
      return Scaffold(
        backgroundColor: Colors.grey.shade900,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Colors.teal),
              SizedBox(height: UIUtils.spacing(context, 12)),
              Text(
                'Initializing session...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: UIUtils.fontSize(context, 14),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final bool tiny = UIUtils.isTiny(context);
    final List<Map<String, dynamic>> participantsList = _participants.values.toList();
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isTeacher ? 'Session (Teacher)' : 'Session',
          style: TextStyle(fontSize: UIUtils.fontSize(context, 16)),
        ),
        backgroundColor: Colors.teal,
        toolbarHeight: tiny ? 40 : null,
        actions: [
          // TTS toggle
          IconButton(
            icon: Icon(_ttsEnabled ? Icons.volume_up : Icons.volume_off, size: UIUtils.iconSize(context, 20)),
            tooltip: 'Toggle TTS',
            onPressed: () => setState(() => _ttsEnabled = !_ttsEnabled),
          ),
          // Invite students — teacher only
          if (widget.isTeacher)
            IconButton(
              icon: Icon(Icons.person_add, size: UIUtils.iconSize(context, 20)),
              tooltip: 'Invite Students',
              onPressed: _openInviteScreen,
            ),
          // End session — teacher only
          if (widget.isTeacher)
            IconButton(
              icon: Icon(Icons.stop_circle, color: Colors.red, size: UIUtils.iconSize(context, 20)),
              tooltip: 'End session',
              onPressed: () => _sse.send({'type': 'end_session'}),
            ),
          // Audio Library — teacher only
          if (widget.isTeacher)
            IconButton(
              icon: Icon(Icons.library_music, size: UIUtils.iconSize(context, 20)),
              tooltip: 'Audio Library',
              onPressed: () => setState(() => _showAudioPanel = !_showAudioPanel),
            ),
          // Leave
          IconButton(
            icon: Icon(Icons.exit_to_app, size: UIUtils.iconSize(context, 20)),
            tooltip: 'Leave',
            onPressed: _leaveSession,
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Audio playback bar (visible to everyone when audio is active) ──
          _buildAudioControlSection(),

          // ── Main content ───────────────────────────────────────────────
          Expanded(
            child: isMobile 
                ? _buildMobileLayout(participantsList) 
                : _buildDesktopLayout(participantsList),
          ),

          // ── Audio library panel (teacher only, slides in above action bar) ─
          if (widget.isTeacher && _showAudioPanel) _buildAudioLibraryPanel(),

          // ── Bottom action bar ──────────────────────────────────────────
          _buildActionBar(),
        ],
      ),
    );
  }


  Widget _buildActionBar() {
    final bool isKeypad = UIUtils.isKeypad(context);
    final bool tiny = UIUtils.isTiny(context);

    return Container(
      padding: UIUtils.paddingSymmetric(context, horizontal: 4, vertical: 8),
      color: Colors.grey.shade900,
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Mute
              _actionBarBtn(
                icon: _muted ? Icons.mic_off : Icons.mic,
                label: isKeypad ? '1:Mute' : 'Mute',
                color: _muted ? Colors.red : Colors.green,
                onTap: _toggleMute,
              ),
              SizedBox(width: UIUtils.spacing(context, 8)),
              // Raise / lower hand
              _actionBarBtn(
                icon: _handRaised ? Icons.pan_tool : Icons.pan_tool_outlined,
                label: isKeypad ? '2:Hand' : 'Raise',
                color: _handRaised ? Colors.amber : Colors.grey.shade400,
                onTap: _toggleHandRaise,
              ),
              if (widget.isTeacher) ...[
                SizedBox(width: UIUtils.spacing(context, 8)),
                _actionBarBtn(
                  icon: Icons.person_add,
                  label: isKeypad ? '3:Invite' : 'Invite',
                  color: Colors.lightBlue,
                  onTap: _openInviteScreen,
                ),
                SizedBox(width: UIUtils.spacing(context, 8)),
                _actionBarBtn(
                  icon: Icons.library_music,
                  label: isKeypad ? '4:Audio' : 'Audio',
                  color: Colors.purple.shade300,
                  onTap: () => setState(() => _showAudioPanel = !_showAudioPanel),
                  active: _showAudioPanel,
                ),
              ],
              SizedBox(width: UIUtils.spacing(context, 8)),
              // Leave
              _actionBarBtn(
                icon: Icons.call_end,
                label: isKeypad ? '*:Exit' : 'Leave',
                color: Colors.red.shade400,
                onTap: _leaveSession,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionBarBtn({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool active = false,
  }) {
    final bool isKeypad = UIUtils.isKeypad(context);
    final double btnSize = isKeypad ? 40 : 48;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: UIUtils.scale(context) * btnSize,
              height: UIUtils.scale(context) * btnSize,
              decoration: BoxDecoration(
                color: active ? color.withOpacity(0.3) : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: active ? color : color.withOpacity(0.6),
                  width: 2,
                ),
              ),
              child: Icon(icon, color: color, size: UIUtils.iconSize(context, isKeypad ? 18 : 24)),
            ),
            SizedBox(height: UIUtils.spacing(context, 4)),
            Text(label,
                style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: UIUtils.fontSize(context, 9),
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout(List<Map<String, dynamic>> participantsList) {
    final bool tiny = UIUtils.isTiny(context);
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            tabs: [
              Tab(
                text: 'Participants',
                icon: Icon(Icons.people, size: UIUtils.iconSize(context, 16)),
                height: tiny ? 36 : null,
              ),
              Tab(
                text: 'Chat',
                icon: Icon(Icons.chat, size: UIUtils.iconSize(context, 16)),
                height: tiny ? 36 : null,
              ),
            ],
            labelColor: Colors.teal,
            labelStyle: TextStyle(fontSize: UIUtils.fontSize(context, 11)),
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
      return Center(
        child: Text(
          'Waiting for participants...',
          style: TextStyle(color: Colors.grey, fontSize: UIUtils.fontSize(context, 13)),
        ),
      );
    }

    final bool tiny = UIUtils.isTiny(context);

    return ListView.builder(
      padding: UIUtils.paddingAll(context, 8),
      itemCount: participantsList.length,
      itemBuilder: (_, i) {
        final p          = participantsList[i];
        final pid        = p['id']        as int;
        final isSelf     = pid == _participantId;
        final isMuted    = p['is_muted']  as bool? ?? false;
        final isTeacher  = p['is_teacher'] as bool? ?? false;
        final raisedHand = p['raised_hand'] as bool? ?? false;
        final name       = p['name']      as String? ?? '?';

        return Card(
          margin: EdgeInsets.only(bottom: UIUtils.spacing(context, 4)),
          child: ListTile(
            dense: tiny,
            contentPadding: UIUtils.paddingSymmetric(context, horizontal: 8, vertical: 4),
            leading: CircleAvatar(
              backgroundColor: isMuted ? Colors.red : Colors.green,
              radius: UIUtils.iconSize(context, 18),
              child: Icon(isMuted ? Icons.mic_off : Icons.mic,
                  color: Colors.white, size: UIUtils.iconSize(context, 16)),
            ),
            title: Text(
              isSelf ? '$name (You)' : name,
              style: TextStyle(
                fontWeight: isSelf ? FontWeight.bold : FontWeight.normal,
                fontSize: UIUtils.fontSize(context, 14),
              ),
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              isTeacher ? 'Teacher' : 'Student',
              style: TextStyle(
                color: isTeacher ? Colors.teal : Colors.grey,
                fontSize: UIUtils.fontSize(context, 12),
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (raisedHand)
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Icon(Icons.pan_tool, color: Colors.amber, size: UIUtils.iconSize(context, 18)),
                  ),
                if (widget.isTeacher && !isSelf) ...[
                  IconButton(
                    icon: Icon(isMuted ? Icons.mic : Icons.mic_off, size: UIUtils.iconSize(context, 18)),
                    color: Colors.blue,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => _muteParticipant(pid, !isMuted),
                    tooltip: isMuted ? 'Unmute' : 'Mute',
                  ),
                  SizedBox(width: UIUtils.spacing(context, 2)),
                  IconButton(
                    icon: Icon(Icons.remove_circle, size: UIUtils.iconSize(context, 18)),
                    color: Colors.red,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => _kickParticipant(pid),
                    tooltip: 'Kick',
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
    final bool tiny = UIUtils.isTiny(context);
    return Column(
      children: [
        // Header
        Container(
          padding: UIUtils.paddingAll(context, 8),
          color: Colors.teal.shade50,
          child: Row(
            children: [
              Icon(Icons.chat, color: Colors.teal, size: UIUtils.iconSize(context, 16)),
              SizedBox(width: UIUtils.spacing(context, 4)),
              Expanded(
                child: Text(
                  'Chat',
                  style: TextStyle(fontSize: UIUtils.fontSize(context, 14), fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: Icon(_ttsEnabled ? Icons.volume_up : Icons.volume_off, size: UIUtils.iconSize(context, 16)),
                tooltip: 'Toggle TTS',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  setState(() => _ttsEnabled = !_ttsEnabled);
                  _speakIfEnabled(_ttsEnabled ? "TTS enabled" : "TTS disabled");
                },
              ),
            ],
          ),
        ),
        
        // Messages
        Expanded(
          child: _messages.isEmpty
              ? Center(
                  child: Text(
                    'No messages yet',
                    style: TextStyle(color: Colors.grey, fontSize: UIUtils.fontSize(context, 12)),
                  ),
                )
              : ListView.builder(
                  controller: _chatScrollController,
                  padding: UIUtils.paddingAll(context, 4),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    final isMe = msg['isMe'] ?? false;
                    
                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.only(bottom: UIUtils.spacing(context, 4)),
                        padding: UIUtils.paddingSymmetric(context, horizontal: 8, vertical: 4),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.7,
                        ),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.teal.shade100 : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              msg['sender'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: UIUtils.fontSize(context, 10),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: UIUtils.spacing(context, 2)),
                            Text(
                              msg['text'],
                              style: TextStyle(fontSize: UIUtils.fontSize(context, 12)),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        
        // Input
        Container(
          padding: UIUtils.paddingSymmetric(context, horizontal: 8, vertical: 8),
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
                      hintStyle: TextStyle(fontSize: UIUtils.fontSize(context, 12)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      contentPadding: UIUtils.paddingSymmetric(context, horizontal: 10, vertical: 4),
                      isDense: true,
                    ),
                    onSubmitted: (_) => _sendMessage(),
                    style: TextStyle(fontSize: UIUtils.fontSize(context, 12)),
                    maxLines: 1,
                  ),
                ),
                SizedBox(width: UIUtils.spacing(context, 4)),
                Container(
                  width: 30 * UIUtils.scale(context),
                  height: 30 * UIUtils.scale(context),
                  decoration: const BoxDecoration(
                    color: Colors.teal,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white, size: UIUtils.iconSize(context, 14)),
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

  Widget _buildAudioControlSection() {
    if (_currentAudioId == null) return const SizedBox.shrink();

    final isPlaying = _isPlayingSessionAudio;
    final barColor  = isPlaying ? Colors.deepPurple.shade700 : Colors.grey.shade800;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      color: barColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + speed + time
          Row(children: [
            Icon(
              isPlaying ? Icons.music_note : Icons.audiotrack,
              color: Colors.white, size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _currentAudioTitle ?? 'Audio',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${_audioSpeed.toStringAsFixed(1)}×',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${_formatDuration(_currentPosition)} / '
              '${_audioDuration != null ? _formatDuration(_audioDuration!) : "--:--"}',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ]),

          // Seek bar:
          //   Teacher → interactive slider
          //   Student → read-only LinearProgressIndicator
          if (widget.isTeacher)
            SliderTheme(
              data: SliderThemeData(
                trackHeight: 3,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                activeTrackColor: Colors.tealAccent,
                inactiveTrackColor: Colors.white30,
                thumbColor: Colors.tealAccent,
                overlayColor: Colors.tealAccent.withOpacity(0.2),
              ),
              child: Slider(
                value: (_audioDuration != null && _audioDuration! > 0)
                    ? (_currentPosition / _audioDuration!).clamp(0.0, 1.0)
                    : 0.0,
                onChanged: _audioDuration != null
                    ? (v) => setState(() => _currentPosition = v * _audioDuration!)
                    : null,
                onChangeEnd: _audioDuration != null
                    ? (v) => _seekAudio(v * _audioDuration!)
                    : null,
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: (_audioDuration != null && _audioDuration! > 0)
                      ? (_currentPosition / _audioDuration!).clamp(0.0, 1.0)
                      : 0.0,
                  backgroundColor: Colors.white24,
                  color: Colors.tealAccent,
                  minHeight: 4,
                ),
              ),
            ),

          // Transport controls (teacher only)
          if (widget.isTeacher)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.fast_rewind, color: Colors.white70),
                  tooltip: 'Slower',
                  onPressed: widget.isTeacher 
                    ? (_audioSpeed > 0.5 ? () => _changeAudioSpeed((_audioSpeed - 0.25).clamp(0.5, 2.0)) : null)
                    : () => _applyAudioSpeedLocally((_audioSpeed - 0.25).clamp(0.25, 3.0)),
                ),
                IconButton(
                  icon: const Icon(Icons.replay_10, color: Colors.white70),
                  tooltip: 'Back 10s',
                  onPressed: () =>
                      _seekAudio((_currentPosition - 10).clamp(0.0, _audioDuration ?? 0.0)),
                ),
                ElevatedButton.icon(
                  onPressed: isPlaying ? _pauseSessionAudio : _playSessionAudio,
                  icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                  label: Text(isPlaying ? 'Pause' : 'Play'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isPlaying ? Colors.orange : Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.forward_10, color: Colors.white70),
                  tooltip: 'Forward 10s',
                  onPressed: () =>
                      _seekAudio((_currentPosition + 10).clamp(0.0, _audioDuration ?? 0.0)),
                ),
                IconButton(
                  icon: const Icon(Icons.fast_forward, color: Colors.white70),
                  tooltip: 'Faster',
                  onPressed: _audioSpeed < 2.0
                      ? () => _changeAudioSpeed((_audioSpeed + 0.25).clamp(0.5, 2.0))
                      : null,
                ),
              ],
            )
          // Student status row
          else
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isPlaying ? Icons.hearing : Icons.hearing_disabled,
                    color: isPlaying ? Colors.tealAccent : Colors.white38,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                    Text(
                      isPlaying ? 'Playing — synced' : 'Paused by teacher',
                      style: TextStyle(
                        color: isPlaying ? Colors.tealAccent : Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                    if (isPlaying) ...[
                      const SizedBox(width: 12),
                      IconButton(
                        icon: const Icon(Icons.fast_rewind_rounded, color: Colors.white, size: 18),
                        onPressed: () => _applyAudioSpeedLocally((_audioSpeed - 0.25).clamp(0.25, 3.0)),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        tooltip: 'Slower',
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.fast_forward_rounded, color: Colors.white, size: 18),
                        onPressed: () => _applyAudioSpeedLocally((_audioSpeed + 0.25).clamp(0.25, 3.0)),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        tooltip: 'Faster',
                      ),
                    ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ── Audio Library Panel (teacher only, toggled from action bar) ───────────

  Widget _buildAudioLibraryPanel() {
    if (!_showAudioPanel) return const SizedBox.shrink();

    return Container(
      height: 320,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Panel header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.teal.shade700,
            child: Row(
              children: [

                const Icon(Icons.library_music, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('Audio Library',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15)),
                ),
                // Upload button
                TextButton.icon(
                  onPressed: _isUploadingAudio ? null : _uploadAudio,
                  icon: _isUploadingAudio
                      ? const SizedBox(
                          width: 16, height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.upload_file, color: Colors.white, size: 18),
                  label: Text(
                    _isUploadingAudio ? 'Uploading…' : 'Upload',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                // Refresh
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white, size: 20),
                  tooltip: 'Refresh',
                  onPressed: _loadAudioLibrary,
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 20),
                  onPressed: () => setState(() => _showAudioPanel = false),
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.only(left: 8),
                ),
              ],
            ),
          ),

          // Upload progress
          if (_isUploadingAudio)
            const LinearProgressIndicator(color: Colors.teal, minHeight: 2),

          // File list
          Expanded(
            child: !_audioLibraryLoaded
                ? const Center(child: CircularProgressIndicator(color: Colors.teal))
                : _audioFiles.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.audiotrack,
                                size: 48, color: Colors.grey),
                            const SizedBox(height: 8),
                            const Text('No audio files yet',
                                style: TextStyle(color: Colors.grey)),
                            const SizedBox(height: 8),
                            TextButton.icon(
                              onPressed: _uploadAudio,
                              icon: const Icon(Icons.upload_file),
                              label: const Text('Upload your first file'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: _audioFiles.length,
                        itemBuilder: (_, i) {
                          final audio    = _audioFiles[i];
                          final audioId  = audio['audio_id'] ?? audio['id'] as int;
                          final title    = audio['title']   as String? ?? 'Untitled';
                          final desc     = audio['description'] as String? ?? '';
                          final isPrev   = _previewingAudioId == audioId;
                          final isActive = _currentAudioId    == audioId;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            elevation: isActive ? 3 : 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: isActive
                                  ? BorderSide(
                                      color: Colors.teal.shade400, width: 2)
                                  : BorderSide.none,
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              leading: Container(
                                width: 40, height: 40,
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? Colors.teal.shade50
                                      : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  isPrev ? Icons.graphic_eq : Icons.audiotrack,
                                  color: isActive
                                      ? Colors.teal.shade700
                                      : Colors.grey.shade600,
                                  size: 22,
                                ),
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(title,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14),
                                        overflow: TextOverflow.ellipsis),
                                  ),
                                  if (isActive)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.teal.shade700,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text('ACTIVE',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                ],
                              ),
                              subtitle: desc.isNotEmpty
                                  ? Text(desc,
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis)
                                  : null,
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Preview (local, not broadcast)
                                  IconButton(
                                    icon: Icon(
                                      isPrev ? Icons.stop_circle : Icons.play_circle,
                                      color: isPrev
                                          ? Colors.orange
                                          : Colors.blue.shade600,
                                      size: 26,
                                    ),
                                    tooltip: isPrev ? 'Stop preview' : 'Preview',
                                    onPressed: () => _previewAudio(audioId, title),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                  const SizedBox(width: 8),
                                  // Select & broadcast to all
                                  IconButton(
                                    icon: Icon(
                                      Icons.broadcast_on_personal,
                                      color: Colors.green.shade600,
                                      size: 26,
                                    ),
                                    tooltip: 'Select & Play for session',
                                    onPressed: () =>
                                        _selectAndPlayAudio(audioId, title),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
