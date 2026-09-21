// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../services/api_service.dart';
import '../services/sse_service.dart';
import '../services/tts_service.dart';
import '../widgets/key_instruction_wrapper.dart';
import '../widgets/keypad_confirmation_dialog.dart';
import 'invite_students_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../utils/ui_utils.dart';
import '../utils/keypad_actions.dart';

final baseUrl = dotenv.env['API_BASE_URL'];

class SessionScreen extends StatefulWidget {
  final int sessionId;
  final int userId;
  final bool isTeacher;
  final String userName;
  final String sessionTitle;

  const SessionScreen({
    super.key,
    required this.sessionId,
    required this.userId,
    this.isTeacher = false,
    required this.userName,
    this.sessionTitle = 'Session',
  });

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  // ── WebRTC ─────────────────────────────────────────────────────────────
  MediaStream? _localStream;
  final Map<int, RTCPeerConnection> _peerConnections = {};
  final Map<int, RTCVideoRenderer> _remoteRenderers = {};

  // ICE candidate batching — collect candidates for 150 ms then send as one POST
  final Map<int, List<Map<String, dynamic>>> _pendingIceCandidates = {};
  final Map<int, Timer> _iceTimers = {};

  // ── SSE transport ──────────────────────────────────────────────────────
  final SseService _sse = SseService();

  // ── audio ──────────────────────────────────────────────────────────────
  final AudioPlayer _sessionAudioPlayer = AudioPlayer();
  final stt.SpeechToText _speech = stt.SpeechToText();

  // ── UI state ───────────────────────────────────────────────────────────
  bool _muted = false;
  bool _handRaised = false;
  bool _ttsEnabled = true;
  bool _voiceCommandsEnabled = false;
  bool _voiceCommandsAvailable = false;
  bool _isInitializing = true;
  Timer? _voiceRestartTimer;

  // Set from the SSE 'connected' event — authoritative server-assigned id
  int? _participantId;

  // Audio
  int? _currentAudioId;
  String? _currentAudioTitle;
  bool _isPlayingSessionAudio = false;
  double _audioSpeed = 1.0;
  double? _audioDuration;
  double _currentPosition = 0.0;
  bool _isSeeking = false;

  // Chat & participants
  final TextEditingController _chatController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final Map<int, Map<String, dynamic>> _participants = {};
  final ScrollController _chatScrollController = ScrollController();

  // ── Audio library panel toggle (teacher) ───────────────────────────────
  bool _showAudioPanel = false;

  // ── Audio library (teacher only) ────────────────────────────────────────
  List<Map<String, dynamic>> _audioFiles = [];
  List<Map<String, dynamic>> _teacherSessions = [];
  bool _audioLibraryLoaded = false;
  bool _isUploadingAudio = false;
  int? _previewingAudioId;
  final AudioPlayer _previewPlayer = AudioPlayer();
  final TextEditingController _uploadTitleCtrl = TextEditingController();
  final TextEditingController _uploadDescCtrl = TextEditingController();

  // WebRTC config
  final Map<String, dynamic> _iceServers = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
      {'urls': 'stun:stun1.l.google.com:19302'},
    ],
    'sdpSemantics': 'unified-plan',
  };
  final KeypadNavigationController _keypadController =
      KeypadNavigationController();
  final FocusNode _ttsFocusNode = FocusNode(debugLabel: 'session-tts');
  final FocusNode _inviteFocusNode = FocusNode(debugLabel: 'session-invite');
  final FocusNode _endFocusNode = FocusNode(debugLabel: 'session-end');
  final FocusNode _audioPanelFocusNode = FocusNode(
    debugLabel: 'session-audio-panel',
  );
  final FocusNode _leaveFocusNode = FocusNode(debugLabel: 'session-leave');
  final FocusNode _muteFocusNode = FocusNode(debugLabel: 'session-mute');
  final FocusNode _handFocusNode = FocusNode(debugLabel: 'session-hand');
  final FocusNode _bottomInviteFocusNode = FocusNode(
    debugLabel: 'session-bottom-invite',
  );
  final FocusNode _bottomAudioFocusNode = FocusNode(
    debugLabel: 'session-bottom-audio',
  );
  final FocusNode _bottomLeaveFocusNode = FocusNode(
    debugLabel: 'session-bottom-leave',
  );
  final FocusNode _participantsTabFocusNode = FocusNode(
    debugLabel: 'session-participants-tab',
  );
  final FocusNode _chatTabFocusNode = FocusNode(debugLabel: 'session-chat-tab');
  final FocusNode _chatTtsFocusNode = FocusNode(debugLabel: 'session-chat-tts');
  final FocusNode _chatFieldFocusNode = FocusNode(
    debugLabel: 'session-chat-field',
  );
  final FocusNode _chatSendFocusNode = FocusNode(
    debugLabel: 'session-chat-send',
  );
  final FocusNode _seekFocusNode = FocusNode(debugLabel: 'session-audio-seek');
  final FocusNode _slowerFocusNode = FocusNode(
    debugLabel: 'session-audio-slower',
  );
  final FocusNode _rewindFocusNode = FocusNode(
    debugLabel: 'session-audio-rewind',
  );
  final FocusNode _playFocusNode = FocusNode(debugLabel: 'session-audio-play');
  final FocusNode _forwardFocusNode = FocusNode(
    debugLabel: 'session-audio-forward',
  );
  final FocusNode _fasterFocusNode = FocusNode(
    debugLabel: 'session-audio-faster',
  );
  final FocusNode _uploadFocusNode = FocusNode(
    debugLabel: 'session-audio-upload',
  );
  final FocusNode _refreshAudioFocusNode = FocusNode(
    debugLabel: 'session-audio-refresh',
  );
  final FocusNode _closeAudioFocusNode = FocusNode(
    debugLabel: 'session-audio-close',
  );
  final Map<int, FocusNode> _participantMuteFocusNodes = {};
  final Map<int, FocusNode> _participantKickFocusNodes = {};
  final Map<int, FocusNode> _previewAudioFocusNodes = {};
  final Map<int, FocusNode> _selectAudioFocusNodes = {};
  bool _isReturningToDashboard = false;

  // ── lifecycle ───────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _initialize();

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
        setState(() {
          _isPlayingSessionAudio = false;
          _currentPosition = 0;
        });
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
      await _loadAccessibilitySettings();
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
      if (widget.isTeacher) _loadTeacherSessions();

      setState(() => _isInitializing = false);
      // Speak key mappings for this screen
      await _repeatSessionInstructions();
      if (_voiceCommandsEnabled) {
        await _startVoiceCommands();
      }
    } catch (e) {
      print('[INIT ERROR] $e');
      await _speakIfEnabled("Failed to initialize session");
      setState(() => _isInitializing = false);
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

  Future<void> _loadTeacherSessions() async {
    final sessions = await ApiService.getActiveSessions();
    if (sessions != null && mounted) {
      setState(() {
        _teacherSessions = sessions
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      });
    }
  }

  Future<void> _initializeMedia() async {
    final prefs = await SharedPreferences.getInstance();
    final explanationSeen =
        prefs.getBool('microphone_permission_explained') ?? false;
    if (!explanationSeen) {
      if (!mounted) return;
      final confirmed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => const KeypadConfirmationDialog(
          title: 'Microphone access',
          message:
              'SEEDS uses the microphone only during an active session for live audio and enabled voice commands. You can stay in the session without microphone access, but others will not hear you.',
          confirmLabel: 'Continue to session',
        ),
      );
      if (confirmed != true) {
        _muted = true;
        _showSnackError(
          'Microphone access was skipped. You joined the session muted.',
        );
        return;
      }
      await prefs.setBool('microphone_permission_explained', true);
    }

    try {
      _localStream = await navigator.mediaDevices.getUserMedia({
        'audio': {
          'mandatory': {
            'googEchoCancellation': true,
            'googNoiseSuppression': true,
            'googAutoGainControl': true,
          },
          'optional': [],
        },
        'video': false,
      });
      _localStream!.getAudioTracks().forEach((t) => t.enabled = !_muted);
      print('[MEDIA] Local stream ready');
    } catch (e) {
      print('[MEDIA ERROR] $e');
      _muted = true;
      _showSnackError(
        'Microphone access is unavailable. You joined the session muted.',
      );
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
    _sse.connect(widget.sessionId.toString(), widget.userId, _handleSseMessage);
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
        _showSnackError(
          'We could not complete that request. Please try again.',
        );

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
        final pid = int.tryParse(key);
        if (pid == null || pid == 0) return;

        final meta = value as Map<String, dynamic>;
        _participants[pid] = {
          'id': pid,
          'user_id': meta['user_id'],
          'name': meta['name'] ?? 'User ${meta['user_id']}',
          'is_muted': meta['is_muted'] ?? false,
          'raised_hand': meta['raised_hand'] ?? false,
          // is_teacher is now stored server-side and included in the snapshot
          'is_teacher': meta['is_teacher'] ?? false,
        };
      });
    });

    print('[STATE] ${_participants.length} participants');

    // Also restore audio playback state if the session was already playing
    final playback = data['playback'] as Map<String, dynamic>?;
    if (playback != null && playback['status'] == 'playing') {
      final audioId = playback['audio_id'] as int?;
      final speed = (playback['speed'] as num?)?.toDouble() ?? 1.0;
      final position = (playback['position'] as num?)?.toDouble() ?? 0.0;
      if (audioId != null) {
        _onAudioPlay({
          'audio_id': audioId,
          'speed': speed,
          'position': position,
          'title': playback['title'],
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
    final pid = data['participant_id'] as int?;
    final uid = data['user_id'] as int?;
    final name = data['name'] as String? ?? 'User $uid';
    final isTeacher = data['is_teacher'] as bool? ?? false;

    if (pid == null || pid == _participantId) return;

    print('[PARTICIPANT] Joined: $name (pid=$pid)');

    setState(() {
      _participants[pid] = {
        'id': pid,
        'user_id': uid,
        'name': name,
        'is_muted': false,
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
    final pid = data['participant_id'] as int?;
    final isMuted = data['is_muted'] as bool? ?? false;
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
    final text = data['text'] as String? ?? '';
    final isOwn = data['is_own'] as bool? ?? false;

    if (text.isEmpty) return;

    // isOwn is set by SseService by comparing data['from'] == _myParticipantId.
    // We already added our own message optimistically in _sendMessage(),
    // so skip duplicates from the echo-back.
    if (isOwn) return;

    setState(() {
      _messages.add({
        'sender': senderName,
        'text': text,
        'timestamp': DateTime.now(),
        'isMe': false,
      });
    });

    _scrollChatToBottom();
    _speakIfEnabled('$senderName: $text');
  }

  void _onKicked(Map<String, dynamic> data) {
    _returnToDashboard();
  }

  void _onSessionEnded() {
    _returnToDashboard();
  }

  // ── audio playback ──────────────────────────────────────────────────────

  void _onAudioSelected(Map<String, dynamic> data) {
    final audioId = data['audio_id'] as int?;
    final title = data['title'] as String?;
    if (audioId == null) return;
    setState(() {
      _currentAudioId = audioId;
      _currentAudioTitle = title;
    });
    _speakIfEnabled('Audio selected: ${title ?? "Unknown"}');
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
        _currentAudioTitle = title ?? _currentAudioTitle;
        _isPlayingSessionAudio = true;
        _audioSpeed = speed;
        _currentPosition = position;
        if (duration != null) _audioDuration = duration;
      });

      await _sessionAudioPlayer.stop();
      await _sessionAudioPlayer.setPlaybackRate(speed);
      await _sessionAudioPlayer.play(
        UrlSource('$baseUrl/audio/$audioId/stream'),
      );
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
    final position = (data['position'] as num?)?.toDouble() ?? 0.0;
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
      action: 'play',
      audioId: _currentAudioId!,
      speed: _audioSpeed,
      position: _currentPosition,
    );
    if (result != null && result['ok'] == true) {
      setState(() => _isPlayingSessionAudio = true);
    }
  }

  Future<void> _pauseSessionAudio() async {
    final pos = await _sessionAudioPlayer.getCurrentPosition();
    final posSeconds = pos?.inSeconds.toDouble() ?? _currentPosition;
    setState(() {
      _currentPosition = posSeconds;
      _isPlayingSessionAudio = false;
    });
    await _sessionAudioPlayer.pause();
    await ApiService.controlAudio(
      widget.sessionId,
      action: 'pause',
      position: posSeconds,
    );
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
      action: 'play',
      audioId: _currentAudioId!,
      speed: newSpeed,
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

  Future<void> _startVoiceCommands() async {
    if (!_voiceCommandsEnabled) return;

    try {
      final available = await _speech.initialize(
        onStatus: _handleSpeechStatus,
        onError: _handleSpeechError,
      );

      if (!mounted) return;
      setState(() => _voiceCommandsAvailable = available);

      if (!available) {
        await _speakIfEnabled(
          'Voice commands are not available on this device',
        );
        return;
      }

      await _listenForVoiceCommand();
      await _speakIfEnabled('Voice commands ready');
    } catch (e) {
      print('[VOICE COMMAND ERROR] $e');
      await _speakIfEnabled('Voice commands could not start');
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
      _scheduleVoiceRestart();
    }
  }

  void _handleSpeechError(dynamic error) {
    print('[VOICE COMMAND SPEECH ERROR] $error');
    if (_voiceCommandsEnabled && mounted) {
      _scheduleVoiceRestart();
    }
  }

  void _scheduleVoiceRestart() {
    _voiceRestartTimer?.cancel();
    _voiceRestartTimer = Timer(const Duration(milliseconds: 700), () {
      if (mounted && _voiceCommandsEnabled) {
        _listenForVoiceCommand();
      }
    });
  }

  void _handleVoiceCommand(String words) {
    final command = words.toLowerCase().trim();
    if (command.isEmpty) return;

    print('[VOICE COMMAND] $command');

    if (command.contains('unmute')) {
      if (_muted) {
        _toggleMute();
      } else {
        _speakIfEnabled('Already unmuted');
      }
      return;
    }

    if (command.contains('mute')) {
      if (!_muted) {
        _toggleMute();
      } else {
        _speakIfEnabled('Already muted');
      }
      return;
    }

    if (command.contains('lower hand') || command.contains('lower my hand')) {
      if (_handRaised) {
        _toggleHandRaise();
      } else {
        _speakIfEnabled('Hand is already lowered');
      }
      return;
    }

    if (command.contains('raise hand') || command.contains('raise my hand')) {
      if (!_handRaised) {
        _toggleHandRaise();
      } else {
        _speakIfEnabled('Hand is already raised');
      }
      return;
    }

    if (command.contains('repeat') || command.contains('instructions')) {
      _repeatSessionInstructions();
      return;
    }

    if (widget.isTeacher && command.contains('invite')) {
      _openInviteScreen();
      return;
    }

    if (widget.isTeacher && command.contains('audio')) {
      setState(() => _showAudioPanel = !_showAudioPanel);
      _speakIfEnabled(
        _showAudioPanel ? 'Audio library opened' : 'Audio library closed',
      );
      return;
    }

    if (command.contains('leave') || command.contains('exit')) {
      _leaveSession();
      return;
    }

    _speakIfEnabled('Command not recognized');
  }

  Future<void> _repeatSessionInstructions() async {
    final labels = widget.isTeacher
        ? sessionTeacherKeyLabels
        : sessionStudentKeyLabels;
    final instructions = buildTtsInstructions(
      labels,
      screenName: 'Session ready',
    );
    await _speakIfEnabled(
      '$instructions Use up and down to move through every session control. '
      'Press OK to activate a control or edit chat. While editing chat, numbers '
      'are typed into the message. Press hash to leave the session.',
    );
  }

  void _toggleTts() {
    setState(() => _ttsEnabled = !_ttsEnabled);
    TtsService.configure(enabled: _ttsEnabled);
    if (_ttsEnabled) {
      _speakIfEnabled('Text to speech enabled');
    } else {
      TtsService.stop();
    }
  }

  void _toggleAudioPanel() {
    if (!widget.isTeacher) return;
    setState(() => _showAudioPanel = !_showAudioPanel);
    _speakIfEnabled(
      _showAudioPanel ? 'Audio library opened' : 'Audio library closed',
    );
    if (_showAudioPanel) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_showAudioPanel) return;
        if (_audioFiles.isNotEmpty) {
          final firstId = int.tryParse(
            (_audioFiles.first['audio_id'] ?? _audioFiles.first['id'] ?? '')
                .toString(),
          );
          if (firstId != null) {
            _previewAudioFocusNodes[firstId]?.requestFocus();
            return;
          }
        }
        _uploadFocusNode.requestFocus();
      });
    }
  }

  void _focusChat() {
    _keypadController.enterTextEditing(_chatFieldFocusNode);
    _speakIfEnabled(
      'Chat message. Editing. Use up or down to leave the field.',
    );
  }

  void _uploadAudioShortcut() {
    if (!_showAudioPanel) {
      setState(() => _showAudioPanel = true);
    }
    if (!_isUploadingAudio) _uploadAudio();
  }

  Future<void> _confirmEndSession() async {
    if (!widget.isTeacher || !mounted) return;
    final cancelNode = FocusNode(debugLabel: 'cancel-end-session');
    final confirmNode = FocusNode(debugLabel: 'confirm-end-session');
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => KeypadInstructionWrapper(
        screenName: 'End session confirmation',
        labels: const {0: 'Cancel', 1: 'End Session for Everyone'},
        actions: {
          0: () => Navigator.pop(dialogContext, false),
          1: () => Navigator.pop(dialogContext, true),
        },
        focusTargets: [
          KeypadFocusTarget(
            node: cancelNode,
            label: 'Cancel. Return to the session',
            onActivate: () => Navigator.pop(dialogContext, false),
          ),
          KeypadFocusTarget(
            node: confirmNode,
            label: 'End session for everyone',
            onActivate: () => Navigator.pop(dialogContext, true),
          ),
        ],
        child: AlertDialog(
          title: const Text('End session?'),
          content: const Text(
            'This stops the session for every participant and returns everyone '
            'to their dashboard. Nobody will be logged out.',
          ),
          actions: [
            TextButton(
              focusNode: cancelNode,
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel (0)'),
            ),
            ElevatedButton(
              focusNode: confirmNode,
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('End for everyone (1)'),
            ),
          ],
        ),
      ),
    );
    cancelNode.dispose();
    confirmNode.dispose();
    if (confirmed == true && mounted) {
      await _sse.send({'type': 'end_session'});
    }
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
        'sender': widget.userName,
        'text': text,
        'timestamp': DateTime.now(),
        'isMe': true,
      });
    });
    _chatController.clear();
    _scrollChatToBottom();
    _speakIfEnabled('${widget.userName}: $text');

    // Fire-and-forget POST
    _sse.send({'type': 'chat', 'text': text});
  }

  void _muteParticipant(int participantId, bool mute) {
    _sse.send({
      'type': mute ? 'mute_participant' : 'unmute_participant',
      'target_participant_id': participantId,
    });
  }

  void _kickParticipant(int participantId) {
    _sse.send({
      'type': 'kick_participant',
      'target_participant_id': participantId,
    });
  }

  Future<void> _returnToDashboard() async {
    if (_isReturningToDashboard || !mounted) return;
    _isReturningToDashboard = true;
    await _sessionAudioPlayer.stop();
    await _previewPlayer.stop();
    await TtsService.stop();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(
      widget.isTeacher ? '/teacher_dashboard' : '/student_dashboard',
      (route) => false,
    );
  }

  Future<void> _leaveSession() async {
    if (!mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const KeypadConfirmationDialog(
        title: 'Leave session?',
        message:
            'You will leave this session and return to your dashboard. You will remain logged in.',
        cancelLabel: 'Stay in session',
        confirmLabel: 'Leave session',
        cancelKey: 0,
        confirmKey: 1,
      ),
    );
    if (confirmed == true && mounted) {
      await _returnToDashboard();
    }
  }

  // ── Invite participants (teacher only) ───────────────────────────────────

  void _openInviteScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InviteStudentsScreen(
          sessionId: widget.sessionId,
          sessionTitle: widget.sessionTitle,
        ),
      ),
    );
  }

  // ── Audio library (teacher only) ─────────────────────────────────────────

  Future<void> _loadAudioLibrary() async {
    try {
      final result = await ApiService.get(
        '/audio/session/${widget.sessionId}',
        useAuth: true,
      );
      if (result != null && mounted) {
        setState(() {
          _audioLibraryLoaded = true;
          if (result is List) {
            _audioFiles = result.cast<Map<String, dynamic>>();
          } else if (result is Map && result.containsKey('files')) {
            _audioFiles = (result['files'] as List)
                .cast<Map<String, dynamic>>();
          }
        });
      }
    } catch (e) {
      print('[AUDIO LIST ERROR] $e');
    }
  }

  Future<bool?> _showUploadMetadataDialog(String fileName) async {
    final titleNode = FocusNode(debugLabel: 'upload-audio-title');
    final descriptionNode = FocusNode(debugLabel: 'upload-audio-description');
    final cancelNode = FocusNode(debugLabel: 'upload-audio-cancel');
    final uploadNode = FocusNode(debugLabel: 'upload-audio-confirm');
    final controller = KeypadNavigationController();

    void submit(BuildContext dialogContext) {
      if (_uploadTitleCtrl.text.trim().isEmpty) {
        _speakIfEnabled('Title is required');
        titleNode.requestFocus();
        controller.enterTextEditing(titleNode);
        return;
      }
      Navigator.pop(dialogContext, true);
    }

    try {
      return await showDialog<bool>(
        context: context,
        builder: (dialogContext) => KeypadInstructionWrapper(
          screenName: 'Upload audio details',
          labels: const {
            1: 'Edit Title',
            2: 'Edit Description',
            3: 'Upload',
            0: 'Cancel',
          },
          actions: {
            1: () => controller.enterTextEditing(titleNode),
            2: () => controller.enterTextEditing(descriptionNode),
            3: () => submit(dialogContext),
            0: () => Navigator.pop(dialogContext, false),
          },
          navigationController: controller,
          focusTargets: [
            KeypadFocusTarget(
              node: titleNode,
              label: 'Audio title, required',
              isTextField: true,
            ),
            KeypadFocusTarget(
              node: descriptionNode,
              label: 'Audio description, optional',
              isTextField: true,
            ),
            KeypadFocusTarget(
              node: cancelNode,
              label: 'Cancel upload',
              onActivate: () => Navigator.pop(dialogContext, false),
            ),
            KeypadFocusTarget(
              node: uploadNode,
              label: 'Upload audio',
              onActivate: () => submit(dialogContext),
            ),
          ],
          child: AlertDialog(
            title: const Text('Upload Audio'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'File: $fileName',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _uploadTitleCtrl,
                    focusNode: titleNode,
                    onTap: () => controller.enterTextEditing(titleNode),
                    decoration: const InputDecoration(
                      labelText: 'Title *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _uploadDescCtrl,
                    focusNode: descriptionNode,
                    onTap: () => controller.enterTextEditing(descriptionNode),
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
                focusNode: cancelNode,
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancel (0)'),
              ),
              ElevatedButton(
                focusNode: uploadNode,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                onPressed: () => submit(dialogContext),
                child: const Text(
                  'Upload (3)',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    } finally {
      titleNode.dispose();
      descriptionNode.dispose();
      cancelNode.dispose();
      uploadNode.dispose();
    }
  }

  Future<bool?> _showSessionSelectionDialog(Set<int> selectedSessionIds) async {
    final cancelNode = FocusNode(debugLabel: 'audio-sessions-cancel');
    final confirmNode = FocusNode(debugLabel: 'audio-sessions-confirm');
    final sessionNodes = <int, FocusNode>{
      for (final session in _teacherSessions)
        session['session_id'] as int: FocusNode(
          debugLabel: 'audio-session-${session['session_id']}',
        ),
    };
    StateSetter? updateDialog;

    void toggle(int id) {
      if (selectedSessionIds.contains(id)) {
        selectedSessionIds.remove(id);
      } else {
        selectedSessionIds.add(id);
      }
      updateDialog?.call(() {});
      _speakIfEnabled(
        selectedSessionIds.contains(id)
            ? 'Session selected'
            : 'Session unselected',
      );
    }

    void confirm(BuildContext dialogContext) {
      if (selectedSessionIds.isEmpty) {
        _speakIfEnabled('Select at least one session');
        return;
      }
      Navigator.pop(dialogContext, true);
    }

    try {
      return await showDialog<bool>(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
          builder: (context, setLocalState) {
            updateDialog = setLocalState;
            return KeypadInstructionWrapper(
              screenName: 'Choose sessions for this audio',
              labels: const {0: 'Cancel', 1: 'Confirm Selected Sessions'},
              actions: {
                0: () => Navigator.pop(dialogContext, false),
                1: () => confirm(dialogContext),
              },
              focusTargets: [
                for (final session in _teacherSessions)
                  KeypadFocusTarget(
                    node: sessionNodes[session['session_id'] as int]!,
                    label:
                        '${selectedSessionIds.contains(session['session_id']) ? 'Selected' : 'Not selected'}, ${session['title'] ?? 'Session ${session['session_id']}'}',
                    onActivate: () => toggle(session['session_id'] as int),
                  ),
                KeypadFocusTarget(
                  node: cancelNode,
                  label: 'Cancel audio upload',
                  onActivate: () => Navigator.pop(dialogContext, false),
                ),
                KeypadFocusTarget(
                  node: confirmNode,
                  label: 'Confirm selected sessions',
                  onActivate: () => confirm(dialogContext),
                ),
              ],
              child: AlertDialog(
                title: const Text('Add audio to sessions'),
                content: SizedBox(
                  width: 360,
                  child: ListView(
                    shrinkWrap: true,
                    children: _teacherSessions.map((session) {
                      final id = session['session_id'] as int;
                      final title =
                          session['title']?.toString() ?? 'Session $id';
                      return Focus(
                        focusNode: sessionNodes[id],
                        child: ExcludeFocus(
                          child: CheckboxListTile(
                            value: selectedSessionIds.contains(id),
                            title: Text(title),
                            subtitle: Text('Session #$id'),
                            onChanged: (_) => toggle(id),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                actions: [
                  TextButton(
                    focusNode: cancelNode,
                    onPressed: () => Navigator.pop(dialogContext, false),
                    child: const Text('Cancel (0)'),
                  ),
                  ElevatedButton(
                    focusNode: confirmNode,
                    onPressed: () => confirm(dialogContext),
                    child: const Text('Confirm (1)'),
                  ),
                ],
              ),
            );
          },
        ),
      );
    } finally {
      cancelNode.dispose();
      confirmNode.dispose();
      for (final node in sessionNodes.values) {
        node.dispose();
      }
    }
  }

  Future<void> _uploadAudio() async {
    try {
      await TtsService.stop();
      final picked = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );
      if (picked == null || picked.files.isEmpty) return;
      final file = picked.files.first;

      _uploadTitleCtrl.clear();
      _uploadDescCtrl.clear();

      final confirmed = await _showUploadMetadataDialog(file.name);
      if (confirmed != true) return;

      final title = _uploadTitleCtrl.text.trim();
      if (title.isEmpty) {
        _showSnackError('Title is required');
        return;
      }

      if (mounted) setState(() => _isUploadingAudio = true);

      final selectedSessionIds = <int>{widget.sessionId};
      if (_teacherSessions.isNotEmpty && mounted) {
        final confirmedSessions = await _showSessionSelectionDialog(
          selectedSessionIds,
        );
        if (confirmedSessions != true || selectedSessionIds.isEmpty) {
          if (mounted) setState(() => _isUploadingAudio = false);
          return;
        }
      }

      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');
      final uri = Uri.parse('$baseUrl/audio/upload?user_id=$userId');
      final headers = await ApiService.getHeaders();

      final request = http.MultipartRequest('POST', uri)
        ..headers.addAll(headers)
        ..fields['title'] = title
        ..fields['description'] = _uploadDescCtrl.text.trim()
        ..fields['session_ids'] = jsonEncode(selectedSessionIds.toList());

      final ext = file.extension?.toLowerCase() ?? '';
      final contentType =
          const {
            'mp3': 'audio/mpeg',
            'wav': 'audio/wav',
            'm4a': 'audio/x-m4a',
            'mp4': 'audio/mp4',
            'ogg': 'audio/ogg',
            'webm': 'audio/webm',
          }[ext] ??
          'audio/mpeg';

      if (kIsWeb && file.bytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            file.bytes!,
            filename: file.name,
            contentType: MediaType.parse(contentType),
          ),
        );
      } else if (!kIsWeb && file.path != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'file',
            file.path!,
            filename: file.name,
            contentType: MediaType.parse(contentType),
          ),
        );
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        _speakIfEnabled('Upload successful');
        await _loadAudioLibrary();
      } else {
        _showSnackError(
          ApiService.mapFailure(
            statusCode: response.statusCode,
            responseBody: responseBody,
            context: 'audio upload',
          ).message,
        );
      }
    } catch (e) {
      print('[AUDIO UPLOAD ERROR] $e');
      _showSnackError(
        ApiService.mapFailure(error: e, context: 'audio upload').message,
      );
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

  Future<bool?> _confirmPlayAudio(String title) async {
    final notYetNode = FocusNode(debugLabel: 'audio-not-yet');
    final playNode = FocusNode(debugLabel: 'audio-play-now');
    try {
      return await showDialog<bool>(
        context: context,
        builder: (dialogContext) => KeypadInstructionWrapper(
          screenName: 'Audio selected. Play $title for everyone now?',
          labels: const {0: 'Not Yet', 1: 'Play Now'},
          actions: {
            0: () => Navigator.pop(dialogContext, false),
            1: () => Navigator.pop(dialogContext, true),
          },
          focusTargets: [
            KeypadFocusTarget(
              node: notYetNode,
              label: 'Not yet. Keep the audio selected',
              onActivate: () => Navigator.pop(dialogContext, false),
            ),
            KeypadFocusTarget(
              node: playNode,
              label: 'Play now for all participants',
              onActivate: () => Navigator.pop(dialogContext, true),
            ),
          ],
          child: AlertDialog(
            title: const Text('Audio Selected'),
            content: Text('Play "$title" for all participants now?'),
            actions: [
              TextButton(
                focusNode: notYetNode,
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Not Yet (0)'),
              ),
              ElevatedButton(
                focusNode: playNode,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text(
                  'Play Now (1)',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    } finally {
      notYetNode.dispose();
      playNode.dispose();
    }
  }

  Future<void> _selectAndPlayAudio(int audioId, String title) async {
    // Tell server which audio is selected — broadcasts audio_selected to all
    final selected = await ApiService.selectAudio(widget.sessionId, audioId);
    if (selected == null || selected['ok'] != true) {
      _showSnackError('Failed to select audio');
      return;
    }
    if (mounted)
      setState(() {
        _currentAudioId = audioId;
        _currentAudioTitle = title;
      });

    // Ask teacher whether to play now
    if (!mounted) return;
    final play = await _confirmPlayAudio(title);

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

  Future<void> _createPeerConnection(
    int participantId,
    bool createOffer,
  ) async {
    if (_peerConnections.containsKey(participantId)) return;

    print('[WebRTC] Creating connection pid=$participantId offer=$createOffer');

    final pc = await createPeerConnection(_iceServers);
    _peerConnections[participantId] = pc;

    _localStream?.getTracks().forEach(
      (track) => pc.addTrack(track, _localStream!),
    );

    pc.onTrack = (event) {
      if (event.streams.isNotEmpty)
        _handleRemoteStream(participantId, event.streams[0]);
    };

    // Batch ICE candidates: collect for 150 ms then send as a single POST
    pc.onIceCandidate = (candidate) {
      if (candidate == null) return;
      _pendingIceCandidates.putIfAbsent(participantId, () => []).add({
        'candidate': candidate.candidate,
        'sdpMid': candidate.sdpMid,
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
        'type': 'webrtc_signal',
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

    print(
      '[WebRTC] Flushing ${candidates.length} ICE candidates to pid=$participantId',
    );

    await _sse.send({
      'type': 'webrtc_signal',
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
    final fromPid = data['from'] as int?;
    final toPid = data['to'] as int?;
    final payload = data['payload'] as Map<String, dynamic>?;

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
      'type': 'webrtc_signal',
      'target_participant_id': fromPid,
      'payload': {'type': 'answer', 'sdp': answer.sdp},
    });
  }

  Future<void> _handleAnswer(int fromPid, Map<String, dynamic> payload) async {
    final sdp = payload['sdp'] as String?;
    if (sdp == null) return;
    await _peerConnections[fromPid]?.setRemoteDescription(
      RTCSessionDescription(sdp, 'answer'),
    );
  }

  Future<void> _handleIceCandidateSingle(
    int fromPid,
    Map<String, dynamic> payload,
  ) async {
    final c = payload['candidate'] as Map<String, dynamic>?;
    if (c == null) return;
    await _peerConnections[fromPid]?.addCandidate(
      RTCIceCandidate(c['candidate'], c['sdpMid'], c['sdpMLineIndex']),
    );
  }

  Future<void> _handleIceCandidateBatch(
    int fromPid,
    Map<String, dynamic> payload,
  ) async {
    final list = payload['candidates'] as List<dynamic>?;
    if (list == null) return;
    final pc = _peerConnections[fromPid];
    if (pc == null) return;
    for (final c in list) {
      final cm = c as Map<String, dynamic>;
      try {
        await pc.addCandidate(
          RTCIceCandidate(cm['candidate'], cm['sdpMid'], cm['sdpMLineIndex']),
        );
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
      try {
        await TtsService.speak(text);
      } catch (_) {}
    }
  }

  void _showSnackError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
    unawaited(_speakIfEnabled(msg));
  }

  void _scrollChatToBottom() {
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

  FocusNode _focusNodeFor(
    Map<int, FocusNode> nodes,
    int id,
    String debugLabel,
  ) {
    return nodes.putIfAbsent(
      id,
      () => FocusNode(debugLabel: '$debugLabel-$id'),
    );
  }

  void _seekBy(double seconds) {
    if (_currentAudioId == null) {
      _speakIfEnabled('No audio is selected');
      return;
    }
    _seekAudio((_currentPosition + seconds).clamp(0.0, _audioDuration ?? 0.0));
  }

  void _toggleSessionAudio() {
    if (_currentAudioId == null) {
      _speakIfEnabled('No audio is selected');
      return;
    }
    _isPlayingSessionAudio ? _pauseSessionAudio() : _playSessionAudio();
  }

  List<KeypadFocusTarget> get _sessionFocusTargets {
    final targets = <KeypadFocusTarget>[
      KeypadFocusTarget(
        node: _ttsFocusNode,
        label: _ttsEnabled
            ? 'Turn text to speech off'
            : 'Turn text to speech on',
        onActivate: _toggleTts,
      ),
      if (widget.isTeacher)
        KeypadFocusTarget(
          node: _inviteFocusNode,
          label: 'Invite students',
          onActivate: _openInviteScreen,
        ),
      if (widget.isTeacher)
        KeypadFocusTarget(
          node: _endFocusNode,
          label: 'End session for everyone',
          onActivate: _confirmEndSession,
        ),
      if (widget.isTeacher)
        KeypadFocusTarget(
          node: _audioPanelFocusNode,
          label: _showAudioPanel ? 'Close audio library' : 'Open audio library',
          onActivate: _toggleAudioPanel,
        ),
      KeypadFocusTarget(
        node: _leaveFocusNode,
        label: 'Leave session and return to dashboard',
        onActivate: _leaveSession,
      ),
      KeypadFocusTarget(
        node: _participantsTabFocusNode,
        label: 'Participants tab',
        onActivate: () {
          final nodeContext = _participantsTabFocusNode.context;
          if (nodeContext != null)
            DefaultTabController.of(nodeContext).animateTo(0);
        },
      ),
      KeypadFocusTarget(
        node: _chatTabFocusNode,
        label: 'Chat tab',
        onActivate: () {
          final nodeContext = _chatTabFocusNode.context;
          if (nodeContext != null)
            DefaultTabController.of(nodeContext).animateTo(1);
        },
      ),
    ];

    for (final participant in _participants.values) {
      final participantId = participant['id'] as int?;
      if (!widget.isTeacher ||
          participantId == null ||
          participantId == _participantId) {
        continue;
      }
      final name = participant['name'] as String? ?? 'participant';
      final isMuted = participant['is_muted'] as bool? ?? false;
      targets.addAll([
        KeypadFocusTarget(
          node: _focusNodeFor(
            _participantMuteFocusNodes,
            participantId,
            'participant-mute',
          ),
          label: '${isMuted ? 'Unmute' : 'Mute'} $name',
          onActivate: () => _muteParticipant(participantId, !isMuted),
        ),
        KeypadFocusTarget(
          node: _focusNodeFor(
            _participantKickFocusNodes,
            participantId,
            'participant-remove',
          ),
          label: 'Remove $name from session',
          onActivate: () => _kickParticipant(participantId),
        ),
      ]);
    }

    targets.addAll([
      KeypadFocusTarget(
        node: _chatTtsFocusNode,
        label: _ttsEnabled ? 'Turn chat speech off' : 'Turn chat speech on',
        onActivate: _toggleTts,
      ),
      KeypadFocusTarget(
        node: _chatFieldFocusNode,
        label: 'Chat message',
        isTextField: true,
      ),
      KeypadFocusTarget(
        node: _chatSendFocusNode,
        label: 'Send chat message',
        onActivate: _sendMessage,
      ),
    ]);

    if (widget.isTeacher && _currentAudioId != null) {
      targets.addAll([
        KeypadFocusTarget(
          node: _seekFocusNode,
          label: 'Audio position. Use left and right to seek ten seconds',
          onDecrease: () => _seekBy(-10),
          onIncrease: () => _seekBy(10),
        ),
        KeypadFocusTarget(
          node: _slowerFocusNode,
          label: 'Decrease audio speed',
          onActivate: () =>
              _changeAudioSpeed((_audioSpeed - 0.25).clamp(0.5, 2.0)),
          isEnabled: () => _audioSpeed > 0.5,
        ),
        KeypadFocusTarget(
          node: _rewindFocusNode,
          label: 'Back ten seconds',
          onActivate: () => _seekBy(-10),
        ),
        KeypadFocusTarget(
          node: _playFocusNode,
          label: _isPlayingSessionAudio ? 'Pause audio' : 'Play audio',
          onActivate: _toggleSessionAudio,
        ),
        KeypadFocusTarget(
          node: _forwardFocusNode,
          label: 'Forward ten seconds',
          onActivate: () => _seekBy(10),
        ),
        KeypadFocusTarget(
          node: _fasterFocusNode,
          label: 'Increase audio speed',
          onActivate: () =>
              _changeAudioSpeed((_audioSpeed + 0.25).clamp(0.5, 2.0)),
          isEnabled: () => _audioSpeed < 2.0,
        ),
      ]);
    }

    if (widget.isTeacher && _showAudioPanel) {
      targets.addAll([
        KeypadFocusTarget(
          node: _uploadFocusNode,
          label: _isUploadingAudio
              ? 'Audio upload in progress'
              : 'Upload audio',
          onActivate: _uploadAudio,
          isEnabled: () => !_isUploadingAudio,
        ),
        KeypadFocusTarget(
          node: _refreshAudioFocusNode,
          label: 'Refresh audio library',
          onActivate: _loadAudioLibrary,
        ),
        KeypadFocusTarget(
          node: _closeAudioFocusNode,
          label: 'Close audio library',
          onActivate: _toggleAudioPanel,
        ),
      ]);
      for (final audio in _audioFiles) {
        final audioId = (audio['audio_id'] ?? audio['id']) as int?;
        if (audioId == null) continue;
        final title = audio['title'] as String? ?? 'Untitled';
        targets.addAll([
          KeypadFocusTarget(
            node: _focusNodeFor(
              _previewAudioFocusNodes,
              audioId,
              'audio-preview',
            ),
            label: _previewingAudioId == audioId
                ? 'Stop preview of $title'
                : 'Preview $title privately',
            onActivate: () => _previewAudio(audioId, title),
          ),
          KeypadFocusTarget(
            node: _focusNodeFor(
              _selectAudioFocusNodes,
              audioId,
              'audio-select',
            ),
            label: 'Select and play $title for the session',
            onActivate: () => _selectAndPlayAudio(audioId, title),
          ),
        ]);
      }
    }

    targets.addAll([
      KeypadFocusTarget(
        node: _muteFocusNode,
        label: _muted ? 'Unmute microphone' : 'Mute microphone',
        onActivate: _toggleMute,
      ),
      KeypadFocusTarget(
        node: _handFocusNode,
        label: _handRaised ? 'Lower hand' : 'Raise hand',
        onActivate: _toggleHandRaise,
      ),
      if (widget.isTeacher)
        KeypadFocusTarget(
          node: _bottomInviteFocusNode,
          label: 'Invite students',
          onActivate: _openInviteScreen,
        ),
      if (widget.isTeacher)
        KeypadFocusTarget(
          node: _bottomAudioFocusNode,
          label: _showAudioPanel ? 'Close audio library' : 'Open audio library',
          onActivate: _toggleAudioPanel,
        ),
      KeypadFocusTarget(
        node: _bottomLeaveFocusNode,
        label: 'Leave session and return to dashboard',
        onActivate: _leaveSession,
      ),
    ]);
    return targets;
  }

  Map<int, VoidCallback> get _sessionKeyActions => {
    1: _toggleMute,
    2: _toggleHandRaise,
    3: widget.isTeacher ? _openInviteScreen : _toggleTts,
    4: widget.isTeacher ? _toggleAudioPanel : _focusChat,
    if (widget.isTeacher) 5: _uploadAudioShortcut,
    if (widget.isTeacher) 6: _loadAudioLibrary,
    if (widget.isTeacher) 7: () => _seekBy(-10),
    if (widget.isTeacher) 8: _toggleSessionAudio,
    if (widget.isTeacher) 9: () => _seekBy(10),
    if (widget.isTeacher) 0: _confirmEndSession,
  };

  @override
  void dispose() {
    _chatController.dispose();
    _chatScrollController.dispose();
    _uploadTitleCtrl.dispose();
    _uploadDescCtrl.dispose();
    _voiceCommandsEnabled = false;
    _voiceRestartTimer?.cancel();
    if (_speech.isListening) {
      _speech.stop();
    }

    _sse.close();

    _localStream?.dispose();
    for (final pc in _peerConnections.values) {
      pc.close();
    }
    for (final r in _remoteRenderers.values) {
      r.dispose();
    }
    for (final t in _iceTimers.values) {
      t.cancel();
    }

    _sessionAudioPlayer.dispose();
    _previewPlayer.stop();
    _previewPlayer.dispose();
    for (final node in [
      _ttsFocusNode,
      _inviteFocusNode,
      _endFocusNode,
      _audioPanelFocusNode,
      _leaveFocusNode,
      _muteFocusNode,
      _handFocusNode,
      _bottomInviteFocusNode,
      _bottomAudioFocusNode,
      _bottomLeaveFocusNode,
      _participantsTabFocusNode,
      _chatTabFocusNode,
      _chatTtsFocusNode,
      _chatFieldFocusNode,
      _chatSendFocusNode,
      _seekFocusNode,
      _slowerFocusNode,
      _rewindFocusNode,
      _playFocusNode,
      _forwardFocusNode,
      _fasterFocusNode,
      _uploadFocusNode,
      _refreshAudioFocusNode,
      _closeAudioFocusNode,
      ..._participantMuteFocusNodes.values,
      ..._participantKickFocusNodes.values,
      ..._previewAudioFocusNodes.values,
      ..._selectAudioFocusNodes.values,
    ]) {
      node.dispose();
    }
    TtsService.stop();
    super.dispose();
  }

  // ── UI ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return KeypadInstructionWrapper(
      screenName: widget.isTeacher ? 'Teacher session' : 'Student session',
      actions: _sessionKeyActions,
      labels: widget.isTeacher
          ? sessionTeacherKeyLabels
          : sessionStudentKeyLabels,
      onStarKey: _repeatSessionInstructions,
      onHashKey: _leaveSession,
      navigationController: _keypadController,
      focusTargets: _sessionFocusTargets,
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
    final List<Map<String, dynamic>> participantsList = _participants.values
        .toList();
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isTeacher
              ? '${widget.sessionTitle} (Teacher)'
              : widget.sessionTitle,
          style: TextStyle(fontSize: UIUtils.fontSize(context, 16)),
        ),
        backgroundColor: Colors.teal,
        toolbarHeight: tiny ? 40 : null,
        actions: [
          // TTS toggle
          IconButton(
            focusNode: _ttsFocusNode,
            icon: Icon(
              _ttsEnabled ? Icons.volume_up : Icons.volume_off,
              size: UIUtils.iconSize(context, 20),
            ),
            tooltip: _ttsEnabled
                ? 'Turn text-to-speech off'
                : 'Turn text-to-speech on',
            onPressed: _toggleTts,
          ),
          // Invite students — teacher only
          if (widget.isTeacher)
            IconButton(
              focusNode: _inviteFocusNode,
              icon: Icon(Icons.person_add, size: UIUtils.iconSize(context, 20)),
              tooltip: 'Invite Students',
              onPressed: _openInviteScreen,
            ),
          // End session — teacher only
          if (widget.isTeacher)
            IconButton(
              focusNode: _endFocusNode,
              icon: Icon(
                Icons.stop_circle,
                color: Colors.red,
                size: UIUtils.iconSize(context, 20),
              ),
              tooltip: 'End session',
              onPressed: _confirmEndSession,
            ),
          // Audio Library — teacher only
          if (widget.isTeacher)
            IconButton(
              focusNode: _audioPanelFocusNode,
              icon: Icon(
                Icons.library_music,
                size: UIUtils.iconSize(context, 20),
              ),
              tooltip: 'Audio Library',
              onPressed: _toggleAudioPanel,
            ),
          // Leave
          IconButton(
            focusNode: _leaveFocusNode,
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
    final bool short = UIUtils.isShort(context);

    return Container(
      padding: UIUtils.paddingSymmetric(
        context,
        horizontal: 4,
        vertical: short ? 4 : 8,
      ),
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
                focusNode: _muteFocusNode,
                icon: _muted ? Icons.mic_off : Icons.mic,
                label: isKeypad ? '1:Mute' : 'Mute',
                color: _muted ? Colors.red : Colors.green,
                onTap: _toggleMute,
              ),
              SizedBox(width: UIUtils.spacing(context, 8)),
              // Raise / lower hand
              _actionBarBtn(
                focusNode: _handFocusNode,
                icon: _handRaised ? Icons.pan_tool : Icons.pan_tool_outlined,
                label: isKeypad ? '2:Hand' : 'Raise',
                color: _handRaised ? Colors.amber : Colors.grey.shade400,
                onTap: _toggleHandRaise,
              ),
              if (widget.isTeacher) ...[
                SizedBox(width: UIUtils.spacing(context, 8)),
                _actionBarBtn(
                  focusNode: _bottomInviteFocusNode,
                  icon: Icons.person_add,
                  label: isKeypad ? '3:Invite' : 'Invite',
                  color: Colors.lightBlue,
                  onTap: _openInviteScreen,
                ),
                SizedBox(width: UIUtils.spacing(context, 8)),
                _actionBarBtn(
                  focusNode: _bottomAudioFocusNode,
                  icon: Icons.library_music,
                  label: isKeypad ? '4:Audio' : 'Audio',
                  color: Colors.purple.shade300,
                  onTap: _toggleAudioPanel,
                  active: _showAudioPanel,
                ),
              ],
              SizedBox(width: UIUtils.spacing(context, 8)),
              // Leave
              _actionBarBtn(
                focusNode: _bottomLeaveFocusNode,
                icon: Icons.call_end,
                label: isKeypad ? '#:Exit' : 'Leave',
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
    required FocusNode focusNode,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool active = false,
  }) {
    final bool isKeypad = UIUtils.isKeypad(context);
    final bool short = UIUtils.isShort(context);
    final double btnSize = short ? 34 : (isKeypad ? 40 : 48);

    return InkWell(
      focusNode: focusNode,
      onTap: onTap,
      focusColor: color.withOpacity(0.28),
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
              child: Icon(
                icon,
                color: color,
                size: UIUtils.iconSize(context, short || isKeypad ? 18 : 24),
              ),
            ),
            SizedBox(height: UIUtils.spacing(context, short ? 2 : 4)),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: UIUtils.fontSize(context, short ? 8 : 9),
                fontWeight: FontWeight.w500,
              ),
            ),
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
              Focus(
                focusNode: _participantsTabFocusNode,
                child: Tab(
                  text: 'Participants',
                  icon: Icon(Icons.people, size: UIUtils.iconSize(context, 16)),
                  height: tiny ? 36 : null,
                ),
              ),
              Focus(
                focusNode: _chatTabFocusNode,
                child: Tab(
                  text: 'Chat',
                  icon: Icon(Icons.chat, size: UIUtils.iconSize(context, 16)),
                  height: tiny ? 36 : null,
                ),
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
        Expanded(flex: 2, child: _buildParticipantsList(participantsList)),
        const VerticalDivider(width: 1),
        Expanded(flex: 3, child: _buildChatPanel()),
      ],
    );
  }

  Widget _buildParticipantsList(List<Map<String, dynamic>> participantsList) {
    if (participantsList.isEmpty) {
      return Center(
        child: Text(
          'Waiting for participants...',
          style: TextStyle(
            color: UIUtils.subtextColor,
            fontSize: UIUtils.fontSize(context, 13),
          ),
        ),
      );
    }

    final bool tiny = UIUtils.isTiny(context);

    return ListView.builder(
      padding: UIUtils.paddingAll(context, 8),
      itemCount: participantsList.length,
      itemBuilder: (_, i) {
        final p = participantsList[i];
        final pid = p['id'] as int;
        final isSelf = pid == _participantId;
        final isMuted = p['is_muted'] as bool? ?? false;
        final isTeacher = p['is_teacher'] as bool? ?? false;
        final raisedHand = p['raised_hand'] as bool? ?? false;
        final name = p['name'] as String? ?? '?';

        return Card(
          margin: EdgeInsets.only(bottom: UIUtils.spacing(context, 4)),
          child: ListTile(
            dense: tiny,
            contentPadding: UIUtils.paddingSymmetric(
              context,
              horizontal: 8,
              vertical: 4,
            ),
            leading: CircleAvatar(
              backgroundColor: isMuted ? Colors.red : Colors.green,
              radius: UIUtils.iconSize(context, 18),
              child: Icon(
                isMuted ? Icons.mic_off : Icons.mic,
                color: Colors.white,
                size: UIUtils.iconSize(context, 16),
              ),
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
                    child: Icon(
                      Icons.pan_tool,
                      color: Colors.amber,
                      size: UIUtils.iconSize(context, 18),
                    ),
                  ),
                if (widget.isTeacher && !isSelf) ...[
                  IconButton(
                    focusNode: _focusNodeFor(
                      _participantMuteFocusNodes,
                      pid,
                      'participant-mute',
                    ),
                    icon: Icon(
                      isMuted ? Icons.mic : Icons.mic_off,
                      size: UIUtils.iconSize(context, 18),
                    ),
                    color: Colors.blue,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => _muteParticipant(pid, !isMuted),
                    tooltip: isMuted ? 'Unmute' : 'Mute',
                  ),
                  SizedBox(width: UIUtils.spacing(context, 2)),
                  IconButton(
                    focusNode: _focusNodeFor(
                      _participantKickFocusNodes,
                      pid,
                      'participant-remove',
                    ),
                    icon: Icon(
                      Icons.remove_circle,
                      size: UIUtils.iconSize(context, 18),
                    ),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 180;

        if (compact) {
          return SingleChildScrollView(
            padding: EdgeInsets.zero,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (constraints.maxHeight >= 120)
                  _buildChatHeader(compact: true),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight >= 120 ? 34 : 24,
                    maxHeight: constraints.maxHeight >= 120 ? 72 : 42,
                  ),
                  child: _buildMessagesList(compact: true),
                ),
                _buildChatInput(compact: true),
              ],
            ),
          );
        }

        return Column(
          children: [
            _buildChatHeader(),
            Expanded(child: _buildMessagesList()),
            _buildChatInput(),
          ],
        );
      },
    );
  }

  Widget _buildChatHeader({bool compact = false}) {
    return Container(
      padding: UIUtils.paddingSymmetric(
        context,
        horizontal: compact ? 6 : 8,
        vertical: compact ? 4 : 8,
      ),
      color: UIUtils.isHighContrast ? UIUtils.cardColor : Colors.teal.shade50,
      child: Row(
        children: [
          Icon(
            Icons.chat,
            color: UIUtils.accentColor,
            size: UIUtils.iconSize(context, compact ? 14 : 16),
          ),
          SizedBox(width: UIUtils.spacing(context, 4)),
          Expanded(
            child: Text(
              'Chat',
              style: TextStyle(
                fontSize: UIUtils.fontSize(context, compact ? 12 : 14),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            focusNode: _chatTtsFocusNode,
            icon: Icon(
              _ttsEnabled ? Icons.volume_up : Icons.volume_off,
              size: UIUtils.iconSize(context, compact ? 14 : 16),
            ),
            tooltip: _ttsEnabled
                ? 'Turn text-to-speech off'
                : 'Turn text-to-speech on',
            padding: EdgeInsets.zero,
            constraints: BoxConstraints.tightFor(
              width: UIUtils.iconSize(context, compact ? 24 : 28),
              height: UIUtils.iconSize(context, compact ? 24 : 28),
            ),
            onPressed: _toggleTts,
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList({bool compact = false}) {
    if (_messages.isEmpty) {
      return Center(
        child: Text(
          'No messages yet',
          style: TextStyle(
            color: UIUtils.subtextColor,
            fontSize: UIUtils.fontSize(context, compact ? 10 : 12),
          ),
        ),
      );
    }

    final itemCount = compact
        ? (_messages.length > 2 ? 2 : _messages.length)
        : _messages.length;
    final startIndex = compact ? _messages.length - itemCount : 0;

    return ListView.builder(
      controller: compact ? null : _chatScrollController,
      shrinkWrap: compact,
      physics: compact ? const NeverScrollableScrollPhysics() : null,
      padding: UIUtils.paddingAll(context, compact ? 2 : 4),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        final msg = _messages[startIndex + index];
        final isMe = msg['isMe'] ?? false;

        return Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: EdgeInsets.only(
              bottom: UIUtils.spacing(context, compact ? 2 : 4),
            ),
            padding: UIUtils.paddingSymmetric(
              context,
              horizontal: compact ? 6 : 8,
              vertical: compact ? 3 : 4,
            ),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            decoration: BoxDecoration(
              color: isMe
                  ? (UIUtils.isHighContrast
                        ? UIUtils.primaryColor
                        : Colors.teal.shade100)
                  : (UIUtils.isHighContrast
                        ? UIUtils.cardColor
                        : Colors.grey.shade200),
              borderRadius: BorderRadius.circular(compact ? 8 : 10),
              border: UIUtils.isHighContrast
                  ? Border.all(color: UIUtils.accentColor.withOpacity(0.5))
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  msg['sender'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: UIUtils.fontSize(context, compact ? 9 : 10),
                    color: UIUtils.textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (!compact) SizedBox(height: UIUtils.spacing(context, 2)),
                Text(
                  msg['text'],
                  style: TextStyle(
                    fontSize: UIUtils.fontSize(context, compact ? 10 : 12),
                    color: UIUtils.textColor,
                  ),
                  maxLines: compact ? 1 : null,
                  overflow: compact ? TextOverflow.ellipsis : null,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildChatInput({bool compact = false}) {
    return Container(
      padding: UIUtils.paddingSymmetric(
        context,
        horizontal: compact ? 6 : 8,
        vertical: compact ? 4 : 8,
      ),
      decoration: BoxDecoration(
        color: UIUtils.cardColor,
        boxShadow: compact
            ? null
            : [
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
              child: SizedBox(
                height: compact ? 32 : null,
                child: TextField(
                  controller: _chatController,
                  focusNode: _chatFieldFocusNode,
                  onTap: _focusChat,
                  decoration: InputDecoration(
                    hintText: "Message...",
                    hintStyle: TextStyle(
                      fontSize: UIUtils.fontSize(context, compact ? 10 : 12),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    contentPadding: UIUtils.paddingSymmetric(
                      context,
                      horizontal: compact ? 8 : 10,
                      vertical: compact ? 2 : 4,
                    ),
                    isDense: true,
                  ),
                  onSubmitted: (_) => _sendMessage(),
                  style: TextStyle(
                    fontSize: UIUtils.fontSize(context, compact ? 10 : 12),
                  ),
                  maxLines: 1,
                ),
              ),
            ),
            SizedBox(width: UIUtils.spacing(context, 4)),
            SizedBox(
              width: UIUtils.iconSize(context, compact ? 28 : 30),
              height: UIUtils.iconSize(context, compact ? 28 : 30),
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  color: Colors.teal,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  focusNode: _chatSendFocusNode,
                  icon: Icon(
                    Icons.send,
                    color: Colors.white,
                    size: UIUtils.iconSize(context, compact ? 12 : 14),
                  ),
                  tooltip: 'Send message',
                  padding: EdgeInsets.zero,
                  onPressed: _sendMessage,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioControlSection() {
    if (_currentAudioId == null) return const SizedBox.shrink();

    final isPlaying = _isPlayingSessionAudio;
    final barColor = isPlaying
        ? Colors.deepPurple.shade700
        : Colors.grey.shade800;
    final compact = UIUtils.isTiny(context) || UIUtils.isShort(context);

    return Container(
      padding: EdgeInsets.fromLTRB(12, compact ? 6 : 10, 12, compact ? 4 : 6),
      color: barColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + speed + time
          Row(
            children: [
              Icon(
                isPlaying ? Icons.music_note : Icons.audiotrack,
                color: Colors.white,
                size: compact ? 16 : 20,
              ),
              SizedBox(width: compact ? 6 : 8),
              Expanded(
                child: Text(
                  _currentAudioTitle ?? 'Audio',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: compact ? 12 : 15,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: compact ? 6 : 8,
                  vertical: compact ? 2 : 3,
                ),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${_audioSpeed.toStringAsFixed(1)}×',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: compact ? 10 : 12,
                  ),
                ),
              ),
              if (!compact) ...[
                const SizedBox(width: 8),
                Text(
                  '${_formatDuration(_currentPosition)} / '
                  '${_audioDuration != null ? _formatDuration(_audioDuration!) : "--:--"}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ],
          ),

          // Seek bar:
          //   Teacher → interactive slider
          //   Student → read-only LinearProgressIndicator
          if (widget.isTeacher && !compact)
            Focus(
              focusNode: _seekFocusNode,
              child: ExcludeFocus(
                child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 3,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 7,
                    ),
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
                        ? (v) => setState(
                            () => _currentPosition = v * _audioDuration!,
                          )
                        : null,
                    onChangeEnd: _audioDuration != null
                        ? (v) => _seekAudio(v * _audioDuration!)
                        : null,
                  ),
                ),
              ),
            )
          else if (compact)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: (_audioDuration != null && _audioDuration! > 0)
                      ? (_currentPosition / _audioDuration!).clamp(0.0, 1.0)
                      : 0.0,
                  backgroundColor: Colors.white24,
                  color: Colors.tealAccent,
                  minHeight: 2,
                ),
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
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    focusNode: _slowerFocusNode,
                    icon: Icon(
                      Icons.fast_rewind,
                      color: Colors.white70,
                      size: compact ? 18 : 24,
                    ),
                    tooltip: 'Slower',
                    constraints: compact
                        ? const BoxConstraints.tightFor(width: 32, height: 30)
                        : null,
                    padding: EdgeInsets.zero,
                    onPressed: widget.isTeacher
                        ? (_audioSpeed > 0.5
                              ? () => _changeAudioSpeed(
                                  (_audioSpeed - 0.25).clamp(0.5, 2.0),
                                )
                              : null)
                        : () => _applyAudioSpeedLocally(
                            (_audioSpeed - 0.25).clamp(0.25, 3.0),
                          ),
                  ),
                  IconButton(
                    focusNode: _rewindFocusNode,
                    icon: Icon(
                      Icons.replay_10,
                      color: Colors.white70,
                      size: compact ? 18 : 24,
                    ),
                    tooltip: 'Back 10s',
                    constraints: compact
                        ? const BoxConstraints.tightFor(width: 32, height: 30)
                        : null,
                    padding: EdgeInsets.zero,
                    onPressed: () => _seekAudio(
                      (_currentPosition - 10).clamp(0.0, _audioDuration ?? 0.0),
                    ),
                  ),
                  compact
                      ? IconButton(
                          focusNode: _playFocusNode,
                          icon: Icon(
                            isPlaying ? Icons.pause_circle : Icons.play_circle,
                            color: Colors.white,
                            size: 24,
                          ),
                          tooltip: isPlaying ? 'Pause' : 'Play',
                          constraints: const BoxConstraints.tightFor(
                            width: 36,
                            height: 30,
                          ),
                          padding: EdgeInsets.zero,
                          onPressed: isPlaying
                              ? _pauseSessionAudio
                              : _playSessionAudio,
                        )
                      : ElevatedButton.icon(
                          focusNode: _playFocusNode,
                          onPressed: isPlaying
                              ? _pauseSessionAudio
                              : _playSessionAudio,
                          icon: Icon(
                            isPlaying ? Icons.pause : Icons.play_arrow,
                          ),
                          label: Text(isPlaying ? 'Pause' : 'Play'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isPlaying
                                ? Colors.orange
                                : Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                  IconButton(
                    focusNode: _forwardFocusNode,
                    icon: Icon(
                      Icons.forward_10,
                      color: Colors.white70,
                      size: compact ? 18 : 24,
                    ),
                    tooltip: 'Forward 10s',
                    constraints: compact
                        ? const BoxConstraints.tightFor(width: 32, height: 30)
                        : null,
                    padding: EdgeInsets.zero,
                    onPressed: () => _seekAudio(
                      (_currentPosition + 10).clamp(0.0, _audioDuration ?? 0.0),
                    ),
                  ),
                  IconButton(
                    focusNode: _fasterFocusNode,
                    icon: Icon(
                      Icons.fast_forward,
                      color: Colors.white70,
                      size: compact ? 18 : 24,
                    ),
                    tooltip: 'Faster',
                    constraints: compact
                        ? const BoxConstraints.tightFor(width: 32, height: 30)
                        : null,
                    padding: EdgeInsets.zero,
                    onPressed: _audioSpeed < 2.0
                        ? () => _changeAudioSpeed(
                            (_audioSpeed + 0.25).clamp(0.5, 2.0),
                          )
                        : null,
                  ),
                ],
              ),
            ),
          // Student status row
          if (!widget.isTeacher && !compact)
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
    final screenHeight = MediaQuery.of(context).size.height;
    final panelHeight =
        (screenHeight < 520
                ? (screenHeight * 0.36).clamp(120.0, 220.0)
                : (screenHeight * 0.4).clamp(240.0, 320.0))
            .toDouble();

    return Container(
      height: panelHeight,
      decoration: BoxDecoration(
        color: UIUtils.cardColor,
        border: Border(
          top: BorderSide(
            color: UIUtils.isHighContrast
                ? UIUtils.accentColor
                : Colors.grey.shade300,
          ),
        ),
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
                  child: Text(
                    'Audio Library',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                // Upload button
                TextButton.icon(
                  focusNode: _uploadFocusNode,
                  onPressed: _isUploadingAudio ? null : _uploadAudio,
                  icon: _isUploadingAudio
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.upload_file,
                          color: Colors.white,
                          size: 18,
                        ),
                  label: Text(
                    _isUploadingAudio ? 'Uploading…' : 'Upload',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                // Refresh
                IconButton(
                  focusNode: _refreshAudioFocusNode,
                  icon: const Icon(
                    Icons.refresh,
                    color: Colors.white,
                    size: 20,
                  ),
                  tooltip: 'Refresh',
                  onPressed: _loadAudioLibrary,
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
                IconButton(
                  focusNode: _closeAudioFocusNode,
                  icon: const Icon(Icons.close, color: Colors.white, size: 20),
                  tooltip: 'Close audio library',
                  onPressed: _toggleAudioPanel,
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
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.teal),
                  )
                : _audioFiles.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.audiotrack,
                          size: 48,
                          color: UIUtils.subtextColor,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No audio files yet',
                          style: TextStyle(color: UIUtils.subtextColor),
                        ),
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
                      final audio = _audioFiles[i];
                      final audioId = audio['audio_id'] ?? audio['id'] as int;
                      final title = audio['title'] as String? ?? 'Untitled';
                      final desc = audio['description'] as String? ?? '';
                      final isPrev = _previewingAudioId == audioId;
                      final isActive = _currentAudioId == audioId;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        elevation: isActive ? 3 : 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: isActive
                              ? BorderSide(
                                  color: Colors.teal.shade400,
                                  width: 2,
                                )
                              : BorderSide.none,
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? (UIUtils.isHighContrast
                                        ? UIUtils.backgroundColor
                                        : Colors.teal.shade50)
                                  : UIUtils.backgroundColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              isPrev ? Icons.graphic_eq : Icons.audiotrack,
                              color: isActive
                                  ? (UIUtils.isHighContrast
                                        ? UIUtils.accentColor
                                        : Colors.teal.shade700)
                                  : UIUtils.subtextColor,
                              size: 22,
                            ),
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isActive)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.teal.shade700,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'ACTIVE',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          subtitle: desc.isNotEmpty
                              ? Text(
                                  desc,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: UIUtils.subtextColor,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                )
                              : null,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Preview (local, not broadcast)
                              IconButton(
                                focusNode: _focusNodeFor(
                                  _previewAudioFocusNodes,
                                  audioId,
                                  'audio-preview',
                                ),
                                icon: Icon(
                                  isPrev
                                      ? Icons.stop_circle
                                      : Icons.headphones_rounded,
                                  color: isPrev
                                      ? Colors.orange
                                      : Colors.blue.shade600,
                                  size: 26,
                                ),
                                tooltip: isPrev
                                    ? 'Stop preview (only you)'
                                    : 'Preview (only you)',
                                onPressed: () => _previewAudio(audioId, title),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                              const SizedBox(width: 8),
                              // Select & broadcast to all
                              IconButton(
                                focusNode: _focusNodeFor(
                                  _selectAudioFocusNodes,
                                  audioId,
                                  'audio-select',
                                ),
                                icon: Icon(
                                  Icons.campaign_rounded,
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
