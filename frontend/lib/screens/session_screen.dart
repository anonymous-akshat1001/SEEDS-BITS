// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb, setEquals;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../services/api_service.dart';
import '../services/sse_service.dart';
import '../services/session_microphone_controller.dart';
import '../services/auth_session_service.dart';
import '../services/session_voice_controller.dart';
import '../services/tts_service.dart';
import '../widgets/key_instruction_wrapper.dart';
import '../widgets/keypad_confirmation_dialog.dart';
import '../widgets/classroom_console_dialog.dart';
import '../widgets/classroom_check_dialog.dart';
import '../services/classroom_check_state.dart';
import '../services/private_note_recorder.dart';
import 'lesson_sequences_screen.dart';
import 'invite_students_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../utils/ui_utils.dart';
import '../utils/keypad_actions.dart';
import '../main.dart' show routeObserver;

final baseUrl = dotenv.env['API_BASE_URL'];

class SessionScreen extends StatefulWidget {
  final int sessionId;
  final int userId;
  final bool isTeacher;
  final String userName;
  final String sessionTitle;
  final String? className;
  final String? subjectName;

  const SessionScreen({
    super.key,
    required this.sessionId,
    required this.userId,
    this.isTeacher = false,
    required this.userName,
    this.sessionTitle = 'Session',
    this.className,
    this.subjectName,
  });

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen>
    with WidgetsBindingObserver, RouteAware {
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
  late final SessionVoiceController _voice = SessionVoiceController(
    initialize: () {
      // SpeechToText caches initialization; its public listeners still belong
      // to the current session, not a previously disposed route.
      _speech.statusListener = _voice.handleStatus;
      _speech.errorListener = (_) => _voice.handleError();
      return _speech.initialize(
        onStatus: _voice.handleStatus,
        onError: (_) => _voice.handleError(),
      );
    },
    listen: (onResult) => _speech.listen(
      listenOptions: stt.SpeechListenOptions(
        listenMode: stt.ListenMode.confirmation,
        partialResults: false,
      ),
      listenFor: const Duration(seconds: 12),
      pauseFor: const Duration(seconds: 3),
      onResult: (result) =>
          onResult(result.recognizedWords, result.finalResult),
    ),
    cancel: _speech.cancel,
    stopSpeech: TtsService.stopForVoiceCommands,
    canAct: () =>
        mounted &&
        _voiceCommandsEnabled &&
        !_isInitializing &&
        (ModalRoute.of(context)?.isCurrent ?? false),
    onCommand: _handleVoiceCommand,
    onIssue: _voiceIssue,
  );
  final _voiceFocus = FocusNode(debugLabel: 'session-listen-command');
  ModalRoute<void>? _voiceRoute;
  bool _voiceUnmuteDialogOpen = false;

  // ── UI state ───────────────────────────────────────────────────────────
  late final _microphone = SessionMicrophoneController(
    isAvailable: () => _localStream?.getAudioTracks().isNotEmpty == true,
    setCaptureEnabled: (enabled) {
      _localStream?.getAudioTracks().forEach(
        (track) => track.enabled = enabled,
      );
    },
    sendMute: (muted) => _sse.send({'type': 'mute_self', 'mute': muted}),
  );
  bool get _muted => _microphone.muted;
  bool _handRaised = false;
  bool _voiceCommandsEnabled = false;
  bool _isInitializing = true;

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
  bool get _mutePending => _microphone.pending;
  bool _handPending = false;
  bool _chatPending = false;
  bool _endingSession = false;
  int _handRevision = 0;
  String _connectionMessage = 'Connecting to the class.';
  bool _everConnected = false;
  bool _connectionLossAnnounced = false;
  String? _speechWhenIdle;
  // Participant ids whose incoming audio is currently above the speaking
  // threshold. Exposed in labels instead of announced (too chatty).
  final Set<int> _speakingParticipants = {};
  Timer? _speakingTimer;
  bool _speakingPollBusy = false;
  // Mobile tab: 0 participants, 1 chat. Only the visible tab has targets.
  int _mobileTab = 0;
  final _connectionFocus = FocusNode(debugLabel: 'session-connection-status');
  final _retryConnectionFocus = FocusNode(
    debugLabel: 'session-retry-connection',
  );

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
  final FocusNode _inviteFocusNode = FocusNode(debugLabel: 'session-invite');
  final FocusNode _endFocusNode = FocusNode(debugLabel: 'session-end');
  final FocusNode _audioPanelFocusNode = FocusNode(
    debugLabel: 'session-audio-panel',
  );
  final FocusNode _leaveFocusNode = FocusNode(debugLabel: 'session-leave');
  final FocusNode _muteFocusNode = FocusNode(debugLabel: 'session-mute');
  final FocusNode _handFocusNode = FocusNode(debugLabel: 'session-hand');
  final FocusNode _participantsTabFocusNode = FocusNode(
    debugLabel: 'session-participants-tab',
  );
  final FocusNode _chatTabFocusNode = FocusNode(debugLabel: 'session-chat-tab');
  final _readMessageFocus = FocusNode(debugLabel: 'session-read-message');
  final _readUpdatesFocus = FocusNode(debugLabel: 'session-read-updates');
  final _stopSpeechFocus = FocusNode(debugLabel: 'session-stop-speech');
  final _repeatHelpFocus = FocusNode(debugLabel: 'session-repeat-help');
  final _consoleFocus = FocusNode(debugLabel: 'session-classroom-console');
  final _consoleRevision = ValueNotifier<int>(0);
  bool _consoleOpen = false;
  final _checkFocus = FocusNode(debugLabel: 'session-classroom-check');
  final _sequencesFocus = FocusNode(debugLabel: 'session-sequences');
  final _checkState = ValueNotifier(const ClassroomCheckState());
  bool _checkOpen = false;
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
  final Map<int, FocusNode> _participantRowFocusNodes = {};
  final Map<int, FocusNode> _participantMuteFocusNodes = {};
  final Map<int, FocusNode> _participantKickFocusNodes = {};
  final Map<int, FocusNode> _previewAudioFocusNodes = {};
  final Map<int, FocusNode> _selectAudioFocusNodes = {};
  bool _isReturningToDashboard = false;
  bool _leaveConfirmationOpen = false;

  // ── lifecycle ───────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    PrivateNoteRecorder.liveSessions++;
    WidgetsBinding.instance.addObserver(this);
    _voice.addListener(_voiceChanged);
    TtsService.speaking.addListener(_speechActivityChanged);
    _microphone.addListener(() {
      if (mounted) setState(() {});
    });
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
    TtsService.registerLiveSession(this);
    TtsService.registerRecordedPlayback(
      _previewPlayer,
      isPlaying: () => mounted && _previewingAudioId != null,
      canResume: () => mounted && (ModalRoute.of(context)?.isCurrent ?? true),
      onResumeSkipped: () {
        if (mounted) setState(() => _previewingAudioId = null);
      },
      item: () => _previewPlayer.source,
      pause: _previewPlayer.pause,
      resume: _previewPlayer.resume,
    );
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
      if (!mounted) return;
      await _initializeMedia();
      if (!mounted) return;

      // Join the session HTTP-side so a Participant row exists before SSE connects.
      // The SSE endpoint also creates the row if absent, but calling join first
      // ensures _participantId is known slightly earlier.
      await _joinSessionHttp();
      if (!mounted) return;

      // Open the SSE stream — this also creates the participant row server-side
      // and returns the authoritative participant_id via the 'connected' event.
      _connectSse();

      // Pre-load audio library for teacher so the panel is ready immediately
      if (widget.isTeacher) _loadAudioLibrary();
      if (widget.isTeacher) _loadTeacherSessions();

      setState(() => _isInitializing = false);
      // Speak key mappings for this screen
      await _repeatSessionInstructions();
    } catch (e) {
      print('[INIT ERROR] $e');
      if (!mounted) return;
      await _speakIfEnabled("Failed to initialize session");
      if (mounted) setState(() => _isInitializing = false);
    }
  }

  Future<void> _loadAccessibilitySettings() async {
    final prefs = await SharedPreferences.getInstance();
    final ttsEnabled = prefs.getBool('tts_enabled') ?? true;
    final voiceEnabled = prefs.getBool('voice_commands_enabled') ?? false;
    final volume = prefs.getDouble('tts_volume') ?? 1.0;
    final speechRate =
        prefs.getDouble('tts_speech_rate') ?? TtsService.defaultSpeechRate;

    await TtsService.configure(
      enabled: ttsEnabled,
      volume: volume,
      speechRate: speechRate,
    );

    if (!mounted) return;
    setState(() {
      _voiceCommandsEnabled = voiceEnabled;
    });
  }

  Future<void> _loadTeacherSessions() async {
    final sessions = await ApiService.getActiveSessions();
    if (sessions != null && mounted) {
      final mapped = sessions
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      final current = mapped.where(
        (session) => session['session_id'] == widget.sessionId,
      );
      final currentSession = current.isEmpty ? null : current.first;
      setState(() {
        _teacherSessions = currentSession == null
            ? mapped
            : mapped
                  .where(
                    (session) =>
                        session['class_id'] == currentSession['class_id'] &&
                        session['subject_id'] == currentSession['subject_id'],
                  )
                  .toList();
      });
    }
  }

  Future<void> _initializeMedia() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
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
              'In this session SEEDS uses the microphone for live audio and explicitly activated voice commands. You can stay without microphone access, but others will not hear you. Separate private-note recording requires its own explicit start outside live sessions.',
          confirmLabel: 'Continue to session',
        ),
      );
      if (!mounted) return;
      if (confirmed != true) {
        _microphone.applyRemoteMute(true);
        _showSnackError(
          'Microphone access was skipped. You joined the session muted.',
        );
        return;
      }
      await prefs.setBool('microphone_permission_explained', true);
      if (!mounted) return;
    }

    try {
      final stream = await navigator.mediaDevices.getUserMedia({
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
      stream.getAudioTracks().forEach((t) => t.enabled = false);
      if (!mounted) {
        await stream.dispose();
        return;
      }
      _localStream = stream;
      print('[MEDIA] Local stream ready');
    } catch (e) {
      print('[MEDIA ERROR] $e');
      if (!mounted) return;
      _microphone.applyRemoteMute(true);
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
      case 'connection_status':
        if (!mounted) return;
        setState(() => _connectionMessage = '${data['message']}');
        if (_sse.state == SessionConnectionState.authenticationExpired) {
          unawaited(_onAuthenticationRevoked());
          return;
        }
        _announceConnection(_sse.state);
      case 'action_unconfirmed':
        _showSnackError('${data['message']}');
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
        _applyClassroomCheck(data['classroom_check'], bootstrap: true);

      case 'classroom_check':
        _applyClassroomCheck(data);

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

      case 'authentication_revoked':
        _onAuthenticationRevoked();

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
    if (mounted &&
        const {
          'connection_status',
          'session_state',
          'participant_joined',
          'participant_left',
          'participant_kicked',
          'participant_muted',
          'hand_raised',
          'hand_lowered',
          'audio_selected',
          'audio_play',
          'audio_pause',
        }.contains(type)) {
      _consoleRevision.value++;
    }
  }

  // ── session state snapshot ──────────────────────────────────────────────

  void _announceConnection(SessionConnectionState state) {
    switch (state) {
      case SessionConnectionState.connecting:
        // The joining instructions already include the connection message.
        if (!_isInitializing) _speakIfEnabled(_connectionMessage);
      case SessionConnectionState.connected:
        final restored = _everConnected || _connectionLossAnnounced;
        _everConnected = true;
        _connectionLossAnnounced = false;
        if (restored) {
          _speakIfEnabled('Connection restored. $_connectionMessage');
        } else {
          _speakWhenIdle(_connectionMessage);
        }
      case SessionConnectionState.reconnecting:
        // Each retry republishes "reconnecting"; only the first loss is spoken.
        if (_connectionLossAnnounced) return;
        _connectionLossAnnounced = true;
        _speakIfEnabled(
          '${_everConnected ? 'Connection lost.' : 'Could not connect.'} '
          '$_connectionMessage',
          priority: SpeechPriority.critical,
        );
      case SessionConnectionState.unavailable:
        _speakIfEnabled(_connectionMessage, priority: SpeechPriority.critical);
      default:
        break;
    }
  }

  /// Speaks [text] once current speech (such as joining help) has finished,
  /// instead of interrupting it.
  void _speakWhenIdle(String text) {
    if (!TtsService.speaking.value) {
      _speakIfEnabled(text);
    } else {
      _speechWhenIdle = text;
    }
  }

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
          'hand_queue_order': meta['hand_queue_order'],
          'hand_revision': meta['hand_revision'] ?? 0,
          // is_teacher is now stored server-side and included in the snapshot
          'is_teacher': meta['is_teacher'] ?? false,
        };
      });
      final own = _participants[_participantId];
      if (own != null) {
        _handRaised = own['raised_hand'] == true;
        _handRevision++;
      }
    });
    if (_participants[_participantId]?['is_muted'] == true) {
      _microphone.applyRemoteMute(true);
    }

    for (final participant in _peerConnections.keys.toList()) {
      if (!_participants.containsKey(participant)) {
        _closePeerConnection(participant);
      }
    }
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
    } else if (playback != null) {
      _onAudioPause(playback);
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
    final previous = _participants[pid];
    final revision = data['hand_revision'] as int? ?? 0;
    final keepHand =
        previous != null && (previous['hand_revision'] as int? ?? 0) > revision;

    setState(() {
      _participants[pid] = {
        'id': pid,
        'user_id': uid,
        'name': name,
        'is_muted': data['is_muted'] ?? true,
        'raised_hand': keepHand
            ? previous['raised_hand']
            : data['raised_hand'] ?? false,
        'hand_queue_order': keepHand
            ? previous['hand_queue_order']
            : data['hand_queue_order'],
        'hand_revision': keepHand ? previous['hand_revision'] : revision,
        'is_teacher': isTeacher,
      };
    });

    _speakIfEnabled(
      'A participant joined.',
      priority: SpeechPriority.incidental,
      group: 'Participants joined',
    );

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

    setState(() => _participants.remove(pid));
    _closePeerConnection(pid);
    _speakIfEnabled(
      'A participant left.',
      priority: SpeechPriority.incidental,
      group: 'Participants left',
    );
  }

  void _onParticipantMuted(Map<String, dynamic> data) {
    final pid = data['participant_id'] as int?;
    final isMuted = data['is_muted'] as bool? ?? false;
    if (pid == null) return;

    setState(() {
      if (_participants.containsKey(pid)) {
        _participants[pid]!['is_muted'] = isMuted;
      }
    });
    if (pid == _participantId) _microphone.applyRemoteMute(isMuted);
  }

  void _onHandChanged(Map<String, dynamic> data, bool raised) {
    final pid = data['participant_id'] as int?;
    if (pid == null) return;
    final participant = _participants[pid];
    if (participant == null) return;
    final revision = data['hand_revision'];
    final currentRevision = participant['hand_revision'] as int? ?? 0;
    if ((revision is int && revision < currentRevision) ||
        (revision == null && currentRevision > 0)) {
      return;
    }

    setState(() {
      if (_participants.containsKey(pid)) {
        _participants[pid]!['raised_hand'] = raised;
        _participants[pid]!['hand_queue_order'] = raised
            ? data['hand_queue_order']
            : null;
        _participants[pid]!['hand_revision'] = revision ?? currentRevision;
      }
      if (pid == _participantId) {
        _handRaised = raised;
        _handRevision++;
      }
    });

    if (raised && widget.isTeacher && pid != _participantId) {
      // Requested (not incidental) so teachers hear it during live audio.
      _speakIfEnabled('${participant['name'] ?? 'A participant'} raised hand');
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
    _speakIfEnabled(
      'Message from $senderName: $text',
      priority: SpeechPriority.incidental,
    );
  }

  void _onKicked(Map<String, dynamic> data) {
    _returnToDashboard();
  }

  void _onSessionEnded() {
    _returnToDashboard();
  }

  Future<void> _onAuthenticationRevoked() async {
    if (_isReturningToDashboard || !mounted) return;
    _isReturningToDashboard = true;
    _microphone.applyRemoteMute(true);
    _sse.close();
    try {
      await _voice.stop();
      await Future.wait(
        _peerConnections.values.map((peer) => peer.close()),
      ).timeout(const Duration(seconds: 2));
      await Future.wait([
        _sessionAudioPlayer.stop(),
        _previewPlayer.stop(),
      ]).timeout(const Duration(seconds: 2));
    } on PlatformException {
      debugPrint(
        '[SESSION] Native media cleanup failed after sign-in revocation',
      );
      _showSnackError(
        'Sign-in ended. Native audio cleanup could not be confirmed. Close SEEDS if audio continues.',
      );
    } on TimeoutException {
      debugPrint(
        '[SESSION] Native media cleanup timed out after sign-in revocation',
      );
      _showSnackError(
        'Sign-in ended. Audio cleanup timed out. Close SEEDS if audio continues.',
      );
    } finally {
      await AuthSessionService.clearLoginState();
      if (mounted) {
        TtsService.speak(
          'Your sign-in changed. Sign in again or contact your school administrator.',
        );
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
      }
    }
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
    _speakIfEnabled(
      'The class recording selection changed. Use Read class updates for details.',
      priority: SpeechPriority.incidental,
      group: 'Class recording selection',
    );
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
        UrlSource(await ApiService.mediaUrl('/audio/$audioId/stream')),
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
    if (!mounted) return;
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
      canSend: () => mounted,
    );
    if (!mounted) return;
    if (!result.isSuccess) {
      _showSnackError(result.failure!.message);
    }
  }

  Future<void> _pauseSessionAudio() async {
    final pos = await _sessionAudioPlayer.getCurrentPosition();
    if (!mounted) return;
    final posSeconds = pos?.inSeconds.toDouble() ?? _currentPosition;
    setState(() {
      _currentPosition = posSeconds;
      _isPlayingSessionAudio = false;
    });
    await _sessionAudioPlayer.pause();
    final result = await ApiService.controlAudio(
      widget.sessionId,
      action: 'pause',
      position: posSeconds,
      canSend: () => mounted,
    );
    if (mounted && !result.isSuccess) {
      _showSnackError(
        'Your local audio is paused. The class pause was not '
        'confirmed. ${result.failure!.message}',
      );
    }
  }

  Future<void> _seekAudio(double position) async {
    if (!widget.isTeacher || _isSeeking) return;
    setState(() => _isSeeking = true);
    try {
      final result = await ApiService.controlAudio(
        widget.sessionId,
        action: 'seek',
        position: position,
        canSend: () => mounted,
      );
      if (!mounted) return;
      if (!result.isSuccess) {
        _showSnackError(result.failure!.message);
        return;
      }
      await _sessionAudioPlayer.seek(Duration(seconds: position.toInt()));
      if (!mounted) return;
      setState(() => _currentPosition = position);
    } finally {
      if (mounted) setState(() => _isSeeking = false);
    }
  }

  Future<void> _changeAudioSpeed(double newSpeed) async {
    if (!widget.isTeacher || _currentAudioId == null) return;
    final pos = await _sessionAudioPlayer.getCurrentPosition();
    if (!mounted) return;
    final result = await ApiService.controlAudio(
      widget.sessionId,
      action: 'play',
      audioId: _currentAudioId!,
      speed: newSpeed,
      position: pos?.inSeconds.toDouble() ?? _currentPosition,
      canSend: () => mounted,
    );
    if (!mounted) return;
    if (!result.isSuccess) {
      _showSnackError(result.failure!.message);
      return;
    }
    await _sessionAudioPlayer.setPlaybackRate(newSpeed);
    if (mounted) setState(() => _audioSpeed = newSpeed);
  }

  // ── user actions (sent via HTTP POST) ───────────────────────────────────

  void _toggleMute() async {
    if (_mutePending) {
      _speakIfEnabled('Waiting for microphone confirmation.');
      return;
    }
    final nextMuted = !_muted;
    final result = await _microphone.toggle();
    if (!mounted) return;
    if (result.isSuccess) {
      await _speakIfEnabled(_muted ? 'Muted' : 'Unmuted');
    } else if (nextMuted) {
      await _speakIfEnabled(
        'Microphone muted on this phone. The class confirmation was not received.',
        priority: SpeechPriority.critical,
      );
    } else {
      _showSnackError(result.failure!.message);
    }
  }

  void _toggleHandRaise() async {
    if (_handPending) {
      _speakIfEnabled('Waiting for hand status confirmation.');
      return;
    }
    final raised = !_handRaised;
    final revision = _handRevision;
    setState(() => _handPending = true);
    final result = await _sse.send({
      'type': raised ? 'raise_hand' : 'lower_hand',
    });
    if (!mounted) return;
    setState(() {
      _handPending = false;
      if (result.isSuccess && revision == _handRevision) _handRaised = raised;
    });
    if (result.isSuccess) {
      await _speakIfEnabled(_handRaised ? 'Hand raised' : 'Hand lowered');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is ModalRoute<void> && !identical(route, _voiceRoute)) {
      if (_voiceRoute != null) routeObserver.unsubscribe(this);
      _voiceRoute = route;
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void didPushNext() => unawaited(_voice.stop());

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) unawaited(_voice.stop());
  }

  void _voiceChanged() {
    if (mounted) setState(() {});
  }

  void _speechActivityChanged() {
    if (TtsService.speaking.value && _voice.hasWindow) {
      unawaited(_voice.stop());
    }
    final pending = _speechWhenIdle;
    if (!TtsService.speaking.value && pending != null && mounted) {
      _speechWhenIdle = null;
      unawaited(_speakIfEnabled(pending));
    }
  }

  void _voiceIssue(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      // Spoken below; excluded so TalkBack does not read it twice.
      SnackBar(content: ExcludeSemantics(child: Text(message))),
    );
    TtsService.speak(message, priority: SpeechPriority.critical);
  }

  Future<void> _toggleVoiceListening() async {
    if (_voice.busy) {
      final stopped = await _voice.stop();
      if (stopped && mounted) await _speakIfEnabled('Voice listening stopped.');
    } else {
      await _voice.start();
    }
  }

  Future<void> _confirmVoiceUnmute() async {
    if (_voiceUnmuteDialogOpen || !_muted || _mutePending) return;
    _voiceUnmuteDialogOpen = true;
    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (_) => const KeypadConfirmationDialog(
          title: 'Unmute your microphone?',
          message:
              'A voice command requested unmute. Confirm with a key or touch. Other class members will be able to hear you.',
          confirmLabel: 'Unmute',
          cancelLabel: 'Stay muted',
        ),
      );
      if (confirmed == true && mounted && _muted && !_mutePending) {
        _toggleMute();
      }
    } finally {
      _voiceUnmuteDialogOpen = false;
    }
  }

  Future<void> _handleVoiceCommand(String words) async {
    final command = words
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[.!?,]+$'), '')
        .replaceAll(RegExp(r'\s+'), ' ');
    if (command.isEmpty) return;

    if (const {
      'unmute',
      'unmute me',
      'unmute microphone',
      'unmute my microphone',
    }.contains(command)) {
      if (_muted) {
        await _confirmVoiceUnmute();
      } else {
        _speakIfEnabled('Already unmuted');
      }
      return;
    }

    if (const {
      'mute',
      'mute me',
      'mute microphone',
      'mute my microphone',
    }.contains(command)) {
      if (!_muted) {
        _toggleMute();
      } else {
        _speakIfEnabled('Already muted');
      }
      return;
    }

    if (const {'lower hand', 'lower my hand'}.contains(command)) {
      if (_handRaised) {
        _toggleHandRaise();
      } else {
        _speakIfEnabled('Hand is already lowered');
      }
      return;
    }

    if (const {'raise hand', 'raise my hand'}.contains(command)) {
      if (!_handRaised) {
        _toggleHandRaise();
      } else {
        _speakIfEnabled('Hand is already raised');
      }
      return;
    }

    if (const {
      'repeat',
      'instructions',
      'repeat instructions',
    }.contains(command)) {
      _repeatSessionInstructions();
      return;
    }

    if (widget.isTeacher &&
        const {'invite', 'invite students'}.contains(command)) {
      _openInviteScreen();
      return;
    }

    if (widget.isTeacher &&
        const {'audio', 'audio library'}.contains(command)) {
      setState(() => _showAudioPanel = !_showAudioPanel);
      _speakIfEnabled(
        _showAudioPanel ? 'Audio library opened' : 'Audio library closed',
      );
      return;
    }

    if (const {
      'leave',
      'exit',
      'leave session',
      'exit session',
    }.contains(command)) {
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
      screenName:
          'Session controls. $_connectionMessage '
          'Your microphone is ${_muted ? 'muted' : 'unmuted'} on this phone.',
    );
    await _speakIfEnabled(
      '$instructions Use up and down to explore connection and microphone status, '
      'lesson playback, participants and the hand queue, chat'
      '${widget.isTeacher ? ', and teacher classroom tools' : ''}. '
      'Press OK to activate a control or edit chat. While editing chat, numbers '
      'are typed into the message. Press 0 to '
      '${widget.isTeacher ? 'end the session' : 'leave the session'}. '
      'Press hash to stop speech.',
    );
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
    void enterChat() {
      if (!mounted || _chatFieldFocusNode.context == null) return;
      _keypadController.enterTextEditing(_chatFieldFocusNode);
      _speakIfEnabled(
        'Chat message. Editing. Use up or down to leave the field.',
      );
    }

    if (_chatFieldFocusNode.context == null) {
      _selectTab(1, moveFocus: false);
      WidgetsBinding.instance.addPostFrameCallback((_) => enterChat());
    } else {
      enterChat();
    }
  }

  /// Shows the participants (0) or chat (1) tab on phone layouts, announces
  /// it, and moves focus to the first control inside it.
  void _selectTab(int index, {bool moveFocus = true}) {
    final tabContext =
        _participantsTabFocusNode.context ?? _chatTabFocusNode.context;
    if (tabContext != null) {
      final controller = DefaultTabController.maybeOf(tabContext);
      if (controller != null && controller.index != index) {
        controller.animateTo(index);
      }
    }
    if (_mobileTab != index) setState(() => _mobileTab = index);
    if (!moveFocus) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final tabName = index == 0 ? 'Participants tab' : 'Chat tab';
      if (index == 1) {
        if (_readMessageFocus.context != null) {
          _keypadController.focusAndAnnounce(
            _readMessageFocus,
            '$tabName. Read latest message',
          );
          return;
        }
      } else {
        final people = _participants.values.toList();
        if (people.isNotEmpty) {
          final pid = people.first['id'] as int;
          final node = _participantRowFocusNodes[pid];
          if (node != null && node.context != null) {
            _keypadController.focusAndAnnounce(
              node,
              '$tabName. ${_participantSummary(people.first)}',
            );
            return;
          }
        }
        _speakIfEnabled('$tabName. Waiting for participants.');
        return;
      }
      _speakIfEnabled(tabName);
    });
  }

  void _restoreFocus(FocusNode? node) {
    if (node == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && node.context != null && node.canRequestFocus) {
        node.requestFocus();
      }
    });
  }

  Future<void> _confirmEndSession() async {
    if (!widget.isTeacher || !mounted) return;
    if (_endingSession) {
      _speakIfEnabled('Waiting for end-session confirmation.');
      return;
    }
    final opener = FocusManager.instance.primaryFocus;
    setState(() => _endingSession = true);
    var confirmed = false;
    try {
      confirmed =
          await showDialog<bool>(
            context: context,
            builder: (_) => const KeypadConfirmationDialog(
              title: 'End session?',
              message:
                  'This stops the session for every participant and returns '
                  'everyone to their dashboard. Nobody will be logged out.',
              cancelLabel: 'Cancel',
              confirmLabel: 'End for everyone',
              cancelKey: 0,
              confirmKey: 1,
            ),
          ) ==
          true;
      if (confirmed && mounted) {
        await _sse.send({'type': 'end_session'});
      }
    } finally {
      if (mounted) setState(() => _endingSession = false);
      if (!confirmed) _restoreFocus(opener);
    }
  }

  Future<void> _sendMessage() async {
    if (_chatPending) {
      _speakIfEnabled('Waiting for message confirmation.');
      return;
    }
    final text = _chatController.text.trim();
    if (text.isEmpty) {
      _speakIfEnabled('Enter a message before selecting Send.');
      return;
    }

    final message = <String, dynamic>{
      'sender': widget.userName,
      'text': text,
      'timestamp': DateTime.now(),
      'isMe': true,
      'delivery': 'Sending',
    };
    setState(() {
      _chatPending = true;
      _messages.add(message);
    });
    _scrollChatToBottom();
    final result = await _sse.send({'type': 'chat', 'text': text});
    if (!mounted) return;
    setState(() {
      _chatPending = false;
      message['delivery'] = result.isSuccess ? 'Sent' : 'Not confirmed';
    });
    if (result.isSuccess) {
      if (_chatController.text.trim() == text) _chatController.clear();
      _speakIfEnabled('Message sent.');
    }
  }

  Future<void> _muteParticipant(int participantId) async {
    final participant = _participants[participantId];
    final name = participant?['name'] as String? ?? 'This participant';
    if (participant?['is_muted'] == true) {
      _speakIfEnabled('$name is muted. Only $name can unmute.');
      return;
    }

    final result = await _sse.send({
      'type': 'mute_participant',
      'target_participant_id': participantId,
    });
    if (!mounted) return;
    if (result.isSuccess) {
      _speakIfEnabled('$name muted.');
    } else {
      _showSnackError(result.failure!.message);
    }
  }

  String _classroomSummary() {
    final people = _participants.values;
    final hands = people.where((p) => p['raised_hand'] == true).length;
    final muted = people.where((p) => p['is_muted'] == true).length;
    final speakingNames = _speakingParticipants
        .map((id) => _participants[id]?['name'])
        .whereType<String>()
        .toList();
    return 'Local connection: $_connectionMessage. '
        'Last received classroom state: ${people.length} participants, '
        '$hands raised hands, $muted microphones reported muted. '
        'Remote reconnecting counts are unavailable. '
        '${speakingNames.isEmpty ? 'Nobody detected speaking.' : 'Detected speaking: ${speakingNames.join(', ')}.'} '
        '${_currentAudioId == null ? 'No class recording selected.' : 'Class recording $_currentAudioTitle. ${_isPlayingSessionAudio ? 'Playing requested.' : 'Paused.'}'} '
        '${_previewingAudioId == null ? 'Private preview stopped.' : 'Private preview active on this phone only.'} '
        'Microphone flags and accepted playback requests do not prove that anyone spoke or heard audio.';
  }

  bool _applyClassroomCheck(Object? data, {bool bootstrap = false}) {
    if (data == null && bootstrap) {
      _checkState.value = const ClassroomCheckState();
      return true;
    }
    try {
      final next = ClassroomCheckState.parse(
        data,
        userId: widget.userId,
        teacher: widget.isTeacher,
      );
      if (bootstrap || next.revision >= _checkState.value.revision) {
        _checkState.value = next;
      }
      return true;
    } on FormatException catch (error) {
      debugPrint('[CHECK] ${error.message}');
      _showSnackError(
        'Classroom check state could not be read. Refresh before responding.',
      );
      return false;
    }
  }

  Future<String?> _classroomCheckAction(
    String type,
    String? id,
    String? choice,
  ) async {
    final previous = _checkState.value;
    final result = await _sse.send({
      'type': type,
      'check_id': id,
      if (choice != null) 'choice': choice,
    });
    if (!mounted) return null;
    if (!result.isSuccess) {
      return result.failure?.message ??
          'The classroom check action was not confirmed. Refresh before trying again.';
    }
    if (!_applyClassroomCheck(
      result.data?['check_state'],
      bootstrap: type == 'read_check' && identical(previous, _checkState.value),
    )) {
      return 'The classroom check confirmation was unreadable. Refresh before trying again.';
    }
    return null;
  }

  Future<void> _openClassroomCheck() async {
    if (_checkOpen) return;
    _checkOpen = true;
    try {
      await showDialog<void>(
        context: context,
        builder: (_) => ClassroomCheckDialog(
          state: _checkState,
          teacher: widget.isTeacher,
          act: _classroomCheckAction,
        ),
      );
    } finally {
      _checkOpen = false;
    }
  }

  Future<void> _openSequences() => Navigator.push<void>(
    context,
    MaterialPageRoute(
      builder: (_) => LessonSequencesScreen(
        sessionId: widget.sessionId,
        execute: (step) async {
          if (!mounted) return;
          if (step.kind == LessonStepKind.audio) {
            await _selectAndPlayAudio(step.audioId!, step.text);
          } else {
            await TtsService.speak(
              step.text,
              priority: SpeechPriority.requested,
            );
            if (mounted && step.kind == LessonStepKind.check) {
              await _openClassroomCheck();
            }
          }
        },
      ),
    ),
  );
  Future<String?> _acknowledgeHand(int id, int? order) async {
    if (!widget.isTeacher) {
      return 'Only the session teacher may acknowledge a hand.';
    }
    final participant = _participants[id];
    if (participant == null ||
        participant['raised_hand'] != true ||
        participant['hand_queue_order'] != order) {
      return 'The selected hand changed. Read the queue again.';
    }
    final name = participant['name'] ?? 'Participant';
    final result = await _sse.send({
      'type': 'acknowledge_hand',
      'target_participant_id': id,
      'hand_queue_order': order,
    });
    if (!mounted) return null;
    if (!result.isSuccess) {
      return result.failure?.message ??
          'The hand acknowledgment was not confirmed. Read the queue before retrying.';
    }
    final state = result.data?['hand_state'];
    if (state is! Map<String, dynamic> ||
        state['participant_id'] != id ||
        state['raised_hand'] != false ||
        state['hand_revision'] is! int) {
      return 'Hand acknowledgment was not readable. Check the queue before trying again.';
    }
    _onHandChanged(state, false);
    _consoleRevision.value++;
    await _speakIfEnabled(
      _participants[id]?['raised_hand'] == true
          ? '$name acknowledged earlier. Their hand has since changed; read the queue again. Their microphone was not changed.'
          : '$name acknowledged. The selected hand was lowered. Their microphone was not changed.',
    );
    return null;
  }

  Future<void> _openClassroomConsole() async {
    if (!widget.isTeacher || _consoleOpen) return;
    _consoleOpen = true;
    try {
      await showDialog<void>(
        context: context,
        builder: (_) => ClassroomConsoleDialog(
          revision: _consoleRevision,
          participants: () => _participants.values.toList(),
          summary: _classroomSummary,
          acknowledge: _acknowledgeHand,
        ),
      );
    } finally {
      _consoleOpen = false;
    }
  }

  Future<void> _kickParticipant(int participantId) async {
    final participant = _participants[participantId];
    if (participant == null) return;
    final name = participant['name'] as String? ?? 'This participant';
    final opener = FocusManager.instance.primaryFocus;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => KeypadConfirmationDialog(
        title: 'Remove $name?',
        message:
            '$name will be removed from this session and returned to their '
            'dashboard. They can be invited again later.',
        cancelLabel: 'Keep $name',
        confirmLabel: 'Remove $name',
      ),
    );
    if (!mounted) return;
    if (confirmed != true) {
      _restoreFocus(opener);
      return;
    }
    final result = await _sse.send({
      'type': 'kick_participant',
      'target_participant_id': participantId,
    });
    if (!mounted) return;
    if (result.isSuccess) {
      _speakIfEnabled('$name removed from the session.');
    } else {
      _showSnackError(result.failure!.message);
      _restoreFocus(opener);
    }
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
    if (!mounted || _leaveConfirmationOpen || _isReturningToDashboard) return;
    _leaveConfirmationOpen = true;
    final opener = FocusManager.instance.primaryFocus;
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
      _microphone.applyRemoteMute(true);
      final result = await _sse.send({'type': 'leave_session'});
      if (!mounted) return;
      if (!result.isSuccess) {
        final leaveLocally = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (_) => const KeypadConfirmationDialog(
            title: 'Leave without server confirmation?',
            message:
                'This phone is muted. The server did not confirm clearing your raised hand. Leave locally now, or stay and retry? A fresh join resets your hand.',
            cancelLabel: 'Stay and retry',
            confirmLabel: 'Leave locally',
          ),
        );
        if (leaveLocally != true || !mounted) {
          _leaveConfirmationOpen = false;
          _restoreFocus(opener);
          return;
        }
      }
      await _returnToDashboard();
    } else {
      _restoreFocus(opener);
    }
    _leaveConfirmationOpen = false;
  }

  // ── Invite participants (teacher only) ───────────────────────────────────

  void _openInviteScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InviteStudentsScreen(
          sessionId: widget.sessionId,
          sessionTitle: [
            widget.sessionTitle,
            if (widget.className != null) widget.className!,
            if (widget.subjectName != null) widget.subjectName!,
          ].join(', '),
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
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) {
                      controller.exitTextEditing();
                      cancelNode.requestFocus();
                    },
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: UIUtils.primaryColor,
                  foregroundColor: UIUtils.onPrimaryColor,
                ),
                onPressed: () => submit(dialogContext),
                child: const Text('Upload (3)'),
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

      final sessionState = await ApiService.getSessionState(widget.sessionId);
      final classId = sessionState?['class_id'] as int?;
      final subjectId = sessionState?['subject_id'] as int?;
      if (classId == null || subjectId == null) {
        _showSnackError(
          'The session class and subject could not be determined',
        );
        return;
      }
      final uri = Uri.parse('$baseUrl/audio/upload');
      final headers = await ApiService.getHeaders();

      final request = http.MultipartRequest('POST', uri)
        ..headers.addAll(headers)
        ..fields['title'] = title
        ..fields['description'] = _uploadDescCtrl.text.trim()
        ..fields['session_ids'] = jsonEncode(selectedSessionIds.toList())
        ..fields['class_id'] = classId.toString()
        ..fields['subject_id'] = subjectId.toString();

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
    final url = await ApiService.mediaUrl('/audio/$audioId/stream');
    await _previewPlayer.play(UrlSource(url));
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: UIUtils.primaryColor,
                  foregroundColor: UIUtils.onPrimaryColor,
                ),
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Play Now (1)'),
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
    final selected = await ApiService.selectAudio(
      widget.sessionId,
      audioId,
      canSend: () => mounted,
    );
    if (!mounted) return;
    if (!selected.isSuccess) {
      _showSnackError(selected.failure!.message);
      return;
    }
    if (mounted) {
      setState(() {
        _currentAudioId = audioId;
        _currentAudioTitle = title;
      });
    }

    // Ask teacher whether to play now
    if (!mounted) return;
    final play = await _confirmPlayAudio(title);

    if (play == true && mounted) {
      final result = await ApiService.controlAudio(
        widget.sessionId,
        action: 'play',
        audioId: audioId,
        speed: 1.0,
        position: 0.0,
        canSend: () => mounted,
      );
      if (!mounted) return;
      if (result.isSuccess) {
        _speakIfEnabled('Class playback request accepted for $title.');
      } else {
        _showSnackError(result.failure!.message);
      }
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
    _ensureSpeakingPoll();

    _localStream?.getTracks().forEach(
      (track) => pc.addTrack(track, _localStream!),
    );

    pc.onTrack = (event) {
      if (event.streams.isNotEmpty) {
        _handleRemoteStream(participantId, event.streams[0]);
      }
    };

    // Batch ICE candidates: collect for 150 ms then send as a single POST
    pc.onIceCandidate = (candidate) {
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
    _speakingParticipants.remove(participantId);
    if (_peerConnections.isEmpty) {
      _speakingTimer?.cancel();
      _speakingTimer = null;
    }
  }

  void _ensureSpeakingPoll() {
    if (_speakingTimer != null || _peerConnections.isEmpty) return;
    _speakingTimer = Timer.periodic(
      const Duration(milliseconds: 1500),
      (_) => unawaited(_pollSpeaking()),
    );
  }

  /// Reads incoming audio levels so participant labels can say "speaking".
  /// Not announced: speech for every speaker change would be too chatty.
  Future<void> _pollSpeaking() async {
    if (_speakingPollBusy || !mounted) return;
    _speakingPollBusy = true;
    final speaking = <int>{};
    try {
      for (final entry in _peerConnections.entries.toList()) {
        if (_participants[entry.key]?['is_muted'] == true) continue;
        try {
          final reports = await entry.value.getStats();
          for (final report in reports) {
            if (report.type != 'inbound-rtp') continue;
            final values = report.values;
            final kind = values['kind'] ?? values['mediaType'];
            if (kind != null && kind != 'audio') continue;
            final raw = values['audioLevel'];
            final level = raw is num
                ? raw.toDouble()
                : double.tryParse('${raw ?? ''}');
            if (level != null && level > 0.05) {
              speaking.add(entry.key);
              break;
            }
          }
        } catch (error) {
          debugPrint('[WebRTC] Audio level unavailable: $error');
        }
      }
    } finally {
      _speakingPollBusy = false;
    }
    if (!mounted || setEquals(speaking, _speakingParticipants)) return;
    setState(() {
      _speakingParticipants
        ..clear()
        ..addAll(speaking);
    });
  }

  // ── helpers ─────────────────────────────────────────────────────────────

  Future<void> _speakIfEnabled(
    String text, {
    SpeechPriority priority = SpeechPriority.requested,
    String? group,
  }) async {
    if (TtsService.isEnabled && mounted) {
      await TtsService.speak(text, priority: priority, group: group);
    }
  }

  void _readLatestMessage() {
    if (_messages.isEmpty) {
      TtsService.speak('No messages yet.');
    } else {
      final message = _messages.last;
      final delivery = message['delivery'];
      TtsService.speak(
        '${message['sender']}: ${message['text']}'
        '${delivery == null ? '' : '\nDelivery status: $delivery.'}',
      );
    }
  }

  void _showSnackError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        // Spoken below; excluded so TalkBack does not read it twice.
        content: ExcludeSemantics(
          child: Text(msg, style: TextStyle(color: UIUtils.textColor)),
        ),
        backgroundColor: UIUtils.cardColor,
        shape: Border.all(color: UIUtils.errorColor, width: 2),
      ),
    );
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

  bool get _canRetryConnection =>
      _sse.state == SessionConnectionState.interrupted ||
      _sse.state == SessionConnectionState.reconnecting;

  bool get _stackedLayout =>
      UIUtils.isTiny(context) || UIUtils.useStackedLayout(context);

  /// Phones show participants and chat as tabs; wide screens show both.
  bool get _usesTabs =>
      _stackedLayout || MediaQuery.sizeOf(context).width < 600;

  bool get _audioCompact => UIUtils.isTiny(context) || UIUtils.isShort(context);

  String get _micStatus => _mutePending
      ? 'Microphone waiting for confirmation'
      : _muted
      ? 'Microphone muted'
      : 'Microphone on';

  String get _handStatus => _handPending
      ? 'Hand waiting for confirmation'
      : _handRaised
      ? 'Hand raised'
      : 'Hand down';

  String get _statusText => '${_sse.state.label}. $_micStatus. $_handStatus.';

  bool _isParticipantMuted(Map<String, dynamic> participant) =>
      participant['id'] == _participantId
      ? _muted
      : participant['is_muted'] == true;

  /// Read-only participant description, most important word first:
  /// "Asha, student, hand raised, muted, speaking".
  String _participantSummary(Map<String, dynamic> participant) {
    final pid = participant['id'];
    final name = participant['name'] as String? ?? 'Participant';
    return [
      pid == _participantId ? '$name, you' : name,
      participant['is_teacher'] == true ? 'teacher' : 'student',
      if (participant['raised_hand'] == true) 'hand raised',
      _isParticipantMuted(participant) ? 'muted' : 'unmuted',
      if (_speakingParticipants.contains(pid)) 'speaking',
    ].join(', ');
  }

  String _participantMuteLabel(String name, bool muted) =>
      muted ? '$name is muted. Only $name can unmute' : 'Mute $name';

  // Order matches the visual order built in [_buildMainScaffold].
  List<KeypadFocusTarget> get _sessionFocusTargets {
    final usesTabs = _usesTabs;
    final showParticipants = !usesTabs || _mobileTab == 0;
    final showChat = !usesTabs || _mobileTab == 1;
    final hasAudio = widget.isTeacher && _currentAudioId != null;
    final targets = <KeypadFocusTarget>[
      KeypadFocusTarget(
        node: _connectionFocus,
        label: 'Status. $_statusText',
        onActivate: () =>
            TtsService.speak('$_connectionMessage $_micStatus. $_handStatus.'),
      ),
      if (_canRetryConnection)
        KeypadFocusTarget(
          node: _retryConnectionFocus,
          label: 'Retry class connection',
          onActivate: _sse.reconnect,
          isEnabled: () => _canRetryConnection,
        ),
      if (widget.isTeacher)
        KeypadFocusTarget(
          node: _consoleFocus,
          label: 'Open classroom console. Raised hands and classroom summary',
          onActivate: _openClassroomConsole,
        ),
      KeypadFocusTarget(
        node: _checkFocus,
        label: 'Open private classroom check. Ungraded responses',
        onActivate: _openClassroomCheck,
      ),
      if (widget.isTeacher)
        KeypadFocusTarget(
          node: _sequencesFocus,
          label: 'Reusable lesson sequences. Select before explicit Run',
          onActivate: _openSequences,
        ),
      if (_voiceCommandsEnabled)
        KeypadFocusTarget(
          node: _voiceFocus,
          label:
              '${_voice.busy ? 'Stop listening' : 'Listen for command'}. ${_voice.status}',
          onActivate: _toggleVoiceListening,
        ),
      KeypadFocusTarget(
        node: _readUpdatesFocus,
        label: 'Read class updates',
        onActivate: TtsService.readPendingUpdates,
      ),
      KeypadFocusTarget(
        node: _stopSpeechFocus,
        label: 'Stop speech',
        onActivate: TtsService.stop,
      ),
      KeypadFocusTarget(
        node: _repeatHelpFocus,
        label: 'Repeat session help',
        onActivate: _repeatSessionInstructions,
      ),
      if (hasAudio && !_audioCompact)
        KeypadFocusTarget(
          node: _seekFocusNode,
          label: 'Audio position. Use left and right to seek ten seconds',
          onDecrease: () => _seekBy(-10),
          onIncrease: () => _seekBy(10),
        ),
      if (hasAudio) ...[
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
      ],
      if (usesTabs) ...[
        KeypadFocusTarget(
          node: _participantsTabFocusNode,
          label: 'Participants tab${_mobileTab == 0 ? ', selected' : ''}',
          onActivate: () => _selectTab(0),
        ),
        KeypadFocusTarget(
          node: _chatTabFocusNode,
          label: 'Chat tab${_mobileTab == 1 ? ', selected' : ''}',
          onActivate: () => _selectTab(1),
        ),
      ],
    ];

    if (showParticipants) {
      for (final participant in _participants.values) {
        final participantId = participant['id'] as int?;
        if (participantId == null) continue;
        final name = participant['name'] as String? ?? 'Participant';
        targets.add(
          KeypadFocusTarget(
            node: _focusNodeFor(
              _participantRowFocusNodes,
              participantId,
              'participant-row',
            ),
            label: _participantSummary(participant),
            onActivate: () => _speakIfEnabled(_participantSummary(participant)),
          ),
        );
        if (!widget.isTeacher || participantId == _participantId) continue;
        targets.addAll([
          KeypadFocusTarget(
            node: _focusNodeFor(
              _participantMuteFocusNodes,
              participantId,
              'participant-mute',
            ),
            label: _participantMuteLabel(
              name,
              _isParticipantMuted(participant),
            ),
            onActivate: () => _muteParticipant(participantId),
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
    }

    if (showChat) {
      targets.addAll([
        KeypadFocusTarget(
          node: _readMessageFocus,
          label: 'Read latest message',
          onActivate: _readLatestMessage,
        ),
        KeypadFocusTarget(
          node: _chatFieldFocusNode,
          label: 'Chat message',
          isTextField: true,
        ),
        KeypadFocusTarget(
          node: _chatSendFocusNode,
          label: 'Send message',
          onActivate: _sendMessage,
          isEnabled: () => !_chatPending,
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
        isEnabled: () => !_mutePending,
      ),
      KeypadFocusTarget(
        node: _handFocusNode,
        label: _handRaised ? 'Lower hand' : 'Raise hand',
        onActivate: _toggleHandRaise,
        isEnabled: () => !_handPending,
      ),
      if (widget.isTeacher) ...[
        KeypadFocusTarget(
          node: _inviteFocusNode,
          label: 'Invite students',
          onActivate: _openInviteScreen,
        ),
        KeypadFocusTarget(
          node: _audioPanelFocusNode,
          label: _showAudioPanel ? 'Close audio library' : 'Open audio library',
          onActivate: _toggleAudioPanel,
        ),
        KeypadFocusTarget(
          node: _endFocusNode,
          label: 'End session for everyone',
          onActivate: _confirmEndSession,
          isEnabled: () => !_endingSession,
        ),
      ],
      KeypadFocusTarget(
        node: _leaveFocusNode,
        label: 'Leave session and return to dashboard',
        onActivate: _leaveSession,
      ),
    ]);
    return targets;
  }

  Map<int, VoidCallback> get _sessionKeyActions => {
    1: _toggleMute,
    2: _toggleHandRaise,
    3: widget.isTeacher ? _openInviteScreen : _focusChat,
    if (widget.isTeacher) playerRewindKey: () => _seekBy(-10),
    if (widget.isTeacher) playerPlayPauseKey: _toggleSessionAudio,
    if (widget.isTeacher) playerForwardKey: () => _seekBy(10),
    if (widget.isTeacher) 8: _toggleAudioPanel,
    0: widget.isTeacher ? _confirmEndSession : _leaveSession,
  };

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    routeObserver.unsubscribe(this);
    TtsService.speaking.removeListener(_speechActivityChanged);
    _voice.removeListener(_voiceChanged);
    _voice.dispose();
    _voiceFocus.dispose();
    _microphone.dispose();
    PrivateNoteRecorder.liveSessions--;
    _connectionFocus.dispose();
    _retryConnectionFocus.dispose();
    TtsService.unregisterLiveSession(this);
    TtsService.unregisterRecordedPlayback(_previewPlayer);
    _readMessageFocus.dispose();
    _readUpdatesFocus.dispose();
    _stopSpeechFocus.dispose();
    _repeatHelpFocus.dispose();
    _chatController.dispose();
    _chatScrollController.dispose();
    _uploadTitleCtrl.dispose();
    _uploadDescCtrl.dispose();
    _voiceCommandsEnabled = false;

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
    _speakingTimer?.cancel();

    _sessionAudioPlayer.dispose();
    _previewPlayer.stop();
    _previewPlayer.dispose();
    for (final node in [
      _inviteFocusNode,
      _endFocusNode,
      _audioPanelFocusNode,
      _leaveFocusNode,
      _muteFocusNode,
      _handFocusNode,
      _consoleFocus,
      _checkFocus,
      _sequencesFocus,
      _participantsTabFocusNode,
      _chatTabFocusNode,
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
      ..._participantRowFocusNodes.values,
      ..._participantMuteFocusNodes.values,
      ..._participantKickFocusNodes.values,
      ..._previewAudioFocusNodes.values,
      ..._selectAudioFocusNodes.values,
    ]) {
      node.dispose();
    }
    _consoleRevision.dispose();
    _checkState.dispose();
    TtsService.stop();
    super.dispose();
  }

  // ── UI ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return KeypadInstructionWrapper(
      navigationSections:
          'connection and microphone status, lesson playback, participants and hand queue, chat${widget.isTeacher ? ', and teacher classroom tools' : ''}',
      screenName: [
        widget.isTeacher ? 'Teacher session' : 'Student session',
        widget.sessionTitle,
        if (widget.className != null) widget.className!,
        if (widget.subjectName != null) widget.subjectName!,
      ].join(', '),
      actions: _sessionKeyActions,
      labels: widget.isTeacher
          ? sessionTeacherKeyLabels
          : sessionStudentKeyLabels,
      onStarKey: _repeatSessionInstructions,
      navigationController: _keypadController,
      focusTargets: _sessionFocusTargets,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) _leaveSession();
        },
        child: _buildMainScaffold(context),
      ),
    );
  }

  TextStyle _textStyle({double size = 14, Color? color, FontWeight? weight}) =>
      TextStyle(
        color: color ?? UIUtils.textColor,
        fontSize: UIUtils.fontSize(context, size),
        fontWeight: weight,
      );

  Widget _buildMainScaffold(BuildContext context) {
    if (_isInitializing) {
      return Scaffold(
        backgroundColor: UIUtils.backgroundColor,
        body: Center(
          child: SingleChildScrollView(
            padding: UIUtils.paddingAll(context, 12),
            child: Semantics(
              liveRegion: true,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: UIUtils.accentColor),
                  SizedBox(height: UIUtils.spacing(context, 12)),
                  Text(
                    'Joining session…',
                    textAlign: TextAlign.center,
                    style: _textStyle(size: 16),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final stacked = _stackedLayout;
    final participantsList = _participants.values.toList();
    final content = _usesTabs
        ? _buildMobileLayout(participantsList, scrollable: stacked)
        : _buildDesktopLayout(participantsList);
    final title = widget.isTeacher
        ? '${widget.sessionTitle} (Teacher)'
        : widget.sessionTitle;
    final subtitle = [
      widget.className,
      widget.subjectName,
    ].whereType<String>().join(' · ');

    final before = <Widget>[
      if (stacked)
        Container(
          color: UIUtils.cardColor,
          padding: UIUtils.paddingSymmetric(
            context,
            horizontal: 8,
            vertical: 6,
          ),
          child: Semantics(
            header: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: _textStyle(size: 18, weight: FontWeight.bold),
                ),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    style: _textStyle(color: UIUtils.subtextColor),
                  ),
              ],
            ),
          ),
        ),
      _buildStatusLine(),
      _buildToolsSection(stacked),
      _buildAudioControlSection(),
    ];
    final after = <Widget>[
      if (widget.isTeacher && _showAudioPanel) _buildAudioLibraryPanel(),
      _buildActionBar(stacked),
    ];

    return Scaffold(
      backgroundColor: UIUtils.backgroundColor,
      appBar: stacked
          ? null
          : AppBar(
              backgroundColor: UIUtils.cardColor,
              foregroundColor: UIUtils.textColor,
              automaticallyImplyLeading: false,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: _textStyle(size: 18, weight: FontWeight.bold),
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: _textStyle(color: UIUtils.subtextColor),
                    ),
                ],
              ),
            ),
      body: stacked
          // Tiny screens and large text: one full-width scrolling column so
          // nothing is clipped at 240x320.
          ? SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [...before, content, ...after],
                ),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ...before,
                Expanded(child: content),
                ...after,
              ],
            ),
    );
  }

  Widget _buildStatusLine() {
    final state = _sse.state;
    final problem = const {
      SessionConnectionState.interrupted,
      SessionConnectionState.reconnecting,
      SessionConnectionState.authenticationExpired,
      SessionConnectionState.unavailable,
      SessionConnectionState.closed,
    }.contains(state);
    final showMessage = state != SessionConnectionState.connected;
    return Focus(
      focusNode: _connectionFocus,
      child: Semantics(
        container: true,
        liveRegion: true,
        label: showMessage ? '$_statusText $_connectionMessage' : _statusText,
        child: ExcludeSemantics(
          child: Container(
            padding: UIUtils.paddingSymmetric(
              context,
              horizontal: 8,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: UIUtils.cardColor,
              border: Border(
                bottom: BorderSide(
                  color: problem ? UIUtils.errorColor : UIUtils.cardBorderColor,
                  width: problem ? 3 : 1,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_statusText, style: _textStyle(weight: FontWeight.bold)),
                if (showMessage)
                  Text(
                    _connectionMessage,
                    style: _textStyle(
                      color: problem
                          ? UIUtils.errorColor
                          : UIUtils.subtextColor,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Full-width column on small screens, wrapping row otherwise.
  Widget _buttonGroup(
    List<Widget> buttons,
    bool stacked, {
    WrapAlignment alignment = WrapAlignment.center,
  }) {
    if (stacked) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final button in buttons)
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: UIUtils.spacing(context, 2),
              ),
              child: button,
            ),
        ],
      );
    }
    return Wrap(
      alignment: alignment,
      spacing: UIUtils.spacing(context, 6),
      runSpacing: UIUtils.spacing(context, 6),
      children: buttons,
    );
  }

  /// Outlined button whose visible text may be short (or carry a key hint)
  /// while its accessible name identifies the action and its target.
  Widget _labelledButton({
    required FocusNode node,
    required IconData icon,
    required String text,
    required String semanticLabel,
    required VoidCallback? onPressed,
    required bool stacked,
    Color? iconColor,
    bool selected = false,
  }) {
    final foreground = selected ? UIUtils.onAccentColor : UIUtils.textColor;
    return OutlinedButton.icon(
      focusNode: node,
      onPressed: onPressed,
      icon: Icon(
        icon,
        color: selected ? foreground : iconColor ?? foreground,
        size: UIUtils.iconSize(context, 20),
      ),
      label: Semantics(
        label: semanticLabel,
        selected: selected ? true : null,
        child: ExcludeSemantics(
          child: Text(
            text,
            textAlign: stacked ? TextAlign.start : TextAlign.center,
            style: _textStyle(color: foreground, weight: FontWeight.w600),
          ),
        ),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: foreground,
        backgroundColor: selected ? UIUtils.accentColor : UIUtils.cardColor,
        side: BorderSide(
          color: selected ? UIUtils.accentColor : UIUtils.cardBorderColor,
          width: selected ? 2 : 1,
        ),
        minimumSize: const Size(48, 44),
        alignment: stacked ? Alignment.centerLeft : Alignment.center,
        padding: UIUtils.paddingSymmetric(context, horizontal: 8, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildToolsSection(bool stacked) {
    final buttons = <Widget>[
      if (_canRetryConnection)
        _labelledButton(
          node: _retryConnectionFocus,
          icon: Icons.refresh,
          text: 'Retry connection',
          semanticLabel: 'Retry class connection',
          onPressed: _sse.reconnect,
          stacked: stacked,
          iconColor: UIUtils.errorColor,
        ),
      if (widget.isTeacher)
        _labelledButton(
          node: _consoleFocus,
          icon: Icons.pan_tool_outlined,
          text: 'Classroom console',
          semanticLabel:
              'Open classroom console. Raised hands and classroom summary',
          onPressed: _openClassroomConsole,
          stacked: stacked,
        ),
      _labelledButton(
        node: _checkFocus,
        icon: Icons.question_answer_outlined,
        text: 'Classroom check',
        semanticLabel: 'Open private classroom check. Ungraded responses',
        onPressed: _openClassroomCheck,
        stacked: stacked,
      ),
      if (widget.isTeacher)
        _labelledButton(
          node: _sequencesFocus,
          icon: Icons.format_list_numbered,
          text: 'Lesson sequences',
          semanticLabel:
              'Reusable lesson sequences. Select before explicit Run',
          onPressed: _openSequences,
          stacked: stacked,
        ),
      if (_voiceCommandsEnabled)
        _labelledButton(
          node: _voiceFocus,
          icon: _voice.busy
              ? Icons.mic_off_outlined
              : Icons.keyboard_voice_outlined,
          text: _voice.busy ? 'Stop listening' : 'Listen for command',
          semanticLabel:
              '${_voice.busy ? 'Stop listening' : 'Listen for command'}. ${_voice.status}',
          onPressed: _toggleVoiceListening,
          stacked: stacked,
        ),
      _labelledButton(
        node: _readUpdatesFocus,
        icon: Icons.notifications_active_outlined,
        text: 'Class updates',
        semanticLabel: 'Read class updates',
        onPressed: TtsService.readPendingUpdates,
        stacked: stacked,
      ),
      _labelledButton(
        node: _stopSpeechFocus,
        icon: Icons.stop_circle_outlined,
        text: 'Stop speech',
        semanticLabel: 'Stop speech',
        onPressed: TtsService.stop,
        stacked: stacked,
      ),
      _labelledButton(
        node: _repeatHelpFocus,
        icon: Icons.help_outline,
        text: 'Help',
        semanticLabel: 'Repeat session help',
        onPressed: _repeatSessionInstructions,
        stacked: stacked,
      ),
    ];
    return Padding(
      padding: UIUtils.paddingAll(context, 6),
      child: _buttonGroup(buttons, stacked),
    );
  }

  Widget _buildActionBar(bool stacked) {
    final keypad = UIUtils.isKeypad(context);
    String hint(int key, String text) => keypad ? '$key:$text' : text;

    final buttons = <Widget>[
      _labelledButton(
        node: _muteFocusNode,
        icon: _muted ? Icons.mic_off : Icons.mic,
        text: _mutePending ? 'Waiting' : hint(1, _muted ? 'Unmute' : 'Mute'),
        semanticLabel: _mutePending
            ? 'Waiting for microphone confirmation'
            : _muted
            ? 'Unmute microphone'
            : 'Mute microphone',
        onPressed: _mutePending ? null : _toggleMute,
        stacked: stacked,
        iconColor: _muted ? UIUtils.errorColor : UIUtils.successColor,
      ),
      _labelledButton(
        node: _handFocusNode,
        icon: _handRaised ? Icons.pan_tool : Icons.pan_tool_outlined,
        text: _handPending
            ? 'Waiting'
            : hint(2, _handRaised ? 'Lower hand' : 'Raise hand'),
        semanticLabel: _handPending
            ? 'Waiting for hand confirmation'
            : _handRaised
            ? 'Lower hand'
            : 'Raise hand',
        onPressed: _handPending ? null : _toggleHandRaise,
        stacked: stacked,
        selected: _handRaised,
      ),
      if (widget.isTeacher) ...[
        _labelledButton(
          node: _inviteFocusNode,
          icon: Icons.person_add,
          text: hint(3, 'Invite'),
          semanticLabel: 'Invite students',
          onPressed: _openInviteScreen,
          stacked: stacked,
        ),
        _labelledButton(
          node: _audioPanelFocusNode,
          icon: Icons.library_music,
          text: hint(8, 'Audio library'),
          semanticLabel: _showAudioPanel
              ? 'Close audio library'
              : 'Open audio library',
          onPressed: _toggleAudioPanel,
          stacked: stacked,
          selected: _showAudioPanel,
        ),
        _labelledButton(
          node: _endFocusNode,
          icon: Icons.stop_circle,
          text: hint(0, 'End session'),
          semanticLabel: 'End session for everyone',
          onPressed: _endingSession ? null : _confirmEndSession,
          stacked: stacked,
          iconColor: UIUtils.errorColor,
        ),
      ],
      _labelledButton(
        node: _leaveFocusNode,
        icon: Icons.call_end,
        text: widget.isTeacher ? 'Leave' : hint(0, 'Leave'),
        semanticLabel: 'Leave session and return to dashboard',
        onPressed: _leaveSession,
        stacked: stacked,
        iconColor: UIUtils.errorColor,
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: UIUtils.cardColor,
        border: Border(top: BorderSide(color: UIUtils.cardBorderColor)),
      ),
      padding: UIUtils.paddingAll(context, 6),
      child: SafeArea(top: false, child: _buttonGroup(buttons, stacked)),
    );
  }

  Widget _buildMobileLayout(
    List<Map<String, dynamic>> participantsList, {
    required bool scrollable,
  }) {
    final content = _mobileTab == 0
        ? _buildParticipantsList(participantsList, scrollable: scrollable)
        : _buildChatPanel(scrollable: scrollable);
    final participantsName = 'Participants (${participantsList.length})';

    if (scrollable) {
      // Full-width tab buttons: a TabBar clips at 240 px with large text.
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: UIUtils.paddingSymmetric(context, horizontal: 6),
            child: _buttonGroup([
              _labelledButton(
                node: _participantsTabFocusNode,
                icon: Icons.people,
                text: participantsName,
                semanticLabel: 'Participants tab',
                onPressed: () => _selectTab(0),
                stacked: true,
                selected: _mobileTab == 0,
              ),
              _labelledButton(
                node: _chatTabFocusNode,
                icon: Icons.chat,
                text: 'Chat',
                semanticLabel: 'Chat tab',
                onPressed: () => _selectTab(1),
                stacked: true,
                selected: _mobileTab == 1,
              ),
            ], true),
          ),
          content,
        ],
      );
    }

    final tabHeight =
        MediaQuery.textScalerOf(context).scale(UIUtils.fontSize(context, 14)) *
            1.4 +
        16;
    return DefaultTabController(
      length: 2,
      initialIndex: _mobileTab,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TabBar(
            onTap: (index) => _selectTab(index),
            tabs: [
              Focus(
                focusNode: _participantsTabFocusNode,
                child: Semantics(
                  label: 'Participants tab',
                  child: ExcludeSemantics(
                    child: Tab(text: participantsName, height: tabHeight),
                  ),
                ),
              ),
              Focus(
                focusNode: _chatTabFocusNode,
                child: Semantics(
                  label: 'Chat tab',
                  child: ExcludeSemantics(
                    child: Tab(text: 'Chat', height: tabHeight),
                  ),
                ),
              ),
            ],
            labelColor: UIUtils.accentColor,
            unselectedLabelColor: UIUtils.textColor,
            indicatorColor: UIUtils.accentColor,
            indicatorWeight: 4,
            labelStyle: _textStyle(weight: FontWeight.bold),
            unselectedLabelStyle: _textStyle(),
          ),
          Expanded(child: content),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(List<Map<String, dynamic>> participantsList) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(flex: 2, child: _buildParticipantsList(participantsList)),
        VerticalDivider(width: 1, color: UIUtils.cardBorderColor),
        Expanded(flex: 3, child: _buildChatPanel()),
      ],
    );
  }

  Widget _buildParticipantsList(
    List<Map<String, dynamic>> participantsList, {
    bool scrollable = false,
  }) {
    if (participantsList.isEmpty) {
      return Padding(
        padding: UIUtils.paddingAll(context, 12),
        child: Text(
          'Waiting for participants...',
          textAlign: TextAlign.center,
          style: _textStyle(color: UIUtils.subtextColor),
        ),
      );
    }

    final stacked = _stackedLayout;
    if (scrollable) {
      return Padding(
        padding: UIUtils.paddingAll(context, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final participant in participantsList)
              _buildParticipantRow(participant, stacked),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: UIUtils.paddingAll(context, 6),
      itemCount: participantsList.length,
      itemBuilder: (_, i) => _buildParticipantRow(participantsList[i], stacked),
    );
  }

  Widget _buildParticipantRow(Map<String, dynamic> p, bool stacked) {
    final pid = p['id'] as int;
    final isSelf = pid == _participantId;
    final name = p['name'] as String? ?? 'Participant';
    final raisedHand = p['raised_hand'] == true;
    final isMuted = _isParticipantMuted(p);
    final speaking = _speakingParticipants.contains(pid);
    final statusWords = [
      p['is_teacher'] == true ? 'Teacher' : 'Student',
      isMuted ? 'Muted' : 'Unmuted',
      if (raisedHand) 'Hand raised',
      if (speaking) 'Speaking',
    ].join(' · ');
    final buttons = <Widget>[
      if (widget.isTeacher && !isSelf) ...[
        _labelledButton(
          node: _focusNodeFor(
            _participantMuteFocusNodes,
            pid,
            'participant-mute',
          ),
          icon: isMuted ? Icons.mic_off : Icons.mic_off_outlined,
          text: isMuted ? '$name muted' : 'Mute $name',
          semanticLabel: _participantMuteLabel(name, isMuted),
          onPressed: () => _muteParticipant(pid),
          stacked: stacked,
        ),
        _labelledButton(
          node: _focusNodeFor(
            _participantKickFocusNodes,
            pid,
            'participant-remove',
          ),
          icon: Icons.person_remove,
          text: 'Remove $name',
          semanticLabel: 'Remove $name from session',
          onPressed: () => _kickParticipant(pid),
          stacked: stacked,
          iconColor: UIUtils.errorColor,
        ),
      ],
    ];

    return Card(
      color: UIUtils.cardColor,
      margin: EdgeInsets.only(bottom: UIUtils.spacing(context, 6)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: raisedHand ? UIUtils.accentColor : UIUtils.cardBorderColor,
          width: raisedHand ? 3 : 1,
        ),
      ),
      child: Padding(
        padding: UIUtils.paddingAll(context, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Focus(
              focusNode: _focusNodeFor(
                _participantRowFocusNodes,
                pid,
                'participant-row',
              ),
              child: Semantics(
                container: true,
                label: _participantSummary(p),
                child: ExcludeSemantics(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        raisedHand
                            ? Icons.pan_tool
                            : isMuted
                            ? Icons.mic_off
                            : Icons.mic,
                        color: raisedHand
                            ? UIUtils.accentColor
                            : isMuted
                            ? UIUtils.errorColor
                            : UIUtils.successColor,
                        size: UIUtils.iconSize(context, 20),
                      ),
                      SizedBox(width: UIUtils.spacing(context, 8)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isSelf ? '$name (You)' : name,
                              style: _textStyle(
                                size: 16,
                                weight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              statusWords,
                              style: _textStyle(color: UIUtils.subtextColor),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (buttons.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: UIUtils.spacing(context, 6)),
                child: _buttonGroup(
                  buttons,
                  stacked,
                  alignment: WrapAlignment.start,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatPanel({bool scrollable = false}) {
    if (scrollable) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildChatHeader(),
          _buildMessagesColumn(),
          _buildChatInput(),
        ],
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxHeight < 180) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildChatHeader(),
                _buildMessagesColumn(),
                _buildChatInput(),
              ],
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildChatHeader(),
            Expanded(child: _buildMessagesList()),
            _buildChatInput(),
          ],
        );
      },
    );
  }

  Widget _buildChatHeader() {
    return Container(
      padding: UIUtils.paddingSymmetric(context, horizontal: 8, vertical: 4),
      color: UIUtils.cardColor,
      child: Row(
        children: [
          Icon(
            Icons.chat,
            color: UIUtils.accentColor,
            size: UIUtils.iconSize(context, 16),
          ),
          SizedBox(width: UIUtils.spacing(context, 4)),
          Expanded(
            child: Semantics(
              header: true,
              child: Text(
                'Chat',
                style: _textStyle(size: 16, weight: FontWeight.bold),
              ),
            ),
          ),
          IconButton(
            focusNode: _readMessageFocus,
            tooltip: 'Read latest message',
            icon: Icon(
              Icons.mark_chat_read_outlined,
              color: UIUtils.textColor,
              size: UIUtils.iconSize(context, 22),
            ),
            onPressed: _readLatestMessage,
            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          ),
        ],
      ),
    );
  }

  Widget _emptyChat() => Padding(
    padding: UIUtils.paddingAll(context, 8),
    child: Text(
      'No messages yet',
      textAlign: TextAlign.center,
      style: _textStyle(color: UIUtils.subtextColor),
    ),
  );

  Widget _buildMessagesColumn() {
    if (_messages.isEmpty) return _emptyChat();
    return Padding(
      padding: UIUtils.paddingAll(context, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [for (final msg in _messages) _buildMessageBubble(msg)],
      ),
    );
  }

  Widget _buildMessagesList() {
    if (_messages.isEmpty) return Center(child: _emptyChat());
    return ListView.builder(
      controller: _chatScrollController,
      padding: UIUtils.paddingAll(context, 4),
      itemCount: _messages.length,
      itemBuilder: (context, index) => _buildMessageBubble(_messages[index]),
    );
  }

  /// One semantic node per message: "Ravi said: ...".
  Widget _buildMessageBubble(Map<String, dynamic> msg) {
    final isMe = msg['isMe'] == true;
    final sender = isMe ? 'You' : '${msg['sender'] ?? 'Unknown'}';
    final text = '${msg['text'] ?? ''}';
    final delivery = msg['delivery'];
    final foreground = isMe ? UIUtils.onPrimaryColor : UIUtils.textColor;
    return Semantics(
      container: true,
      label: '$sender said: $text${delivery == null ? '' : '. $delivery'}',
      child: ExcludeSemantics(
        child: Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: EdgeInsets.only(bottom: UIUtils.spacing(context, 4)),
            padding: UIUtils.paddingSymmetric(
              context,
              horizontal: 8,
              vertical: 4,
            ),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.sizeOf(context).width * 0.85,
            ),
            decoration: BoxDecoration(
              color: isMe ? UIUtils.primaryColor : UIUtils.cardColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: UIUtils.cardBorderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  sender,
                  style: _textStyle(color: foreground, weight: FontWeight.bold),
                ),
                Text(text, style: _textStyle(color: foreground)),
                if (delivery != null)
                  Text('$delivery', style: _textStyle(color: foreground)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChatInput() {
    final keypadHint = UIUtils.isKeypad(context) && !widget.isTeacher;
    return Container(
      padding: UIUtils.paddingSymmetric(context, horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: UIUtils.cardColor,
        border: Border(top: BorderSide(color: UIUtils.cardBorderColor)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _chatController,
                focusNode: _chatFieldFocusNode,
                onTap: _focusChat,
                decoration: InputDecoration(
                  hintText: keypadHint ? '3: chat message' : 'Chat message',
                  hintStyle: _textStyle(color: UIUtils.subtextColor),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: UIUtils.cardBorderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: UIUtils.accentColor,
                      width: 2,
                    ),
                  ),
                  contentPadding: UIUtils.paddingSymmetric(
                    context,
                    horizontal: 8,
                    vertical: 6,
                  ),
                  isDense: true,
                ),
                onSubmitted: (_) => _sendMessage(),
                style: _textStyle(),
                maxLines: 1,
              ),
            ),
            SizedBox(width: UIUtils.spacing(context, 4)),
            IconButton(
              focusNode: _chatSendFocusNode,
              tooltip: 'Send message',
              icon: Icon(
                Icons.send,
                color: UIUtils.onPrimaryColor,
                size: UIUtils.iconSize(context, 20),
              ),
              style: IconButton.styleFrom(
                backgroundColor: UIUtils.primaryColor,
                disabledBackgroundColor: UIUtils.cardBorderColor,
              ),
              constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
              onPressed: _chatPending ? null : _sendMessage,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioControlSection() {
    if (_currentAudioId == null) return const SizedBox.shrink();

    final isPlaying = _isPlayingSessionAudio;
    final compact = _audioCompact;
    final progress = (_audioDuration != null && _audioDuration! > 0)
        ? (_currentPosition / _audioDuration!).clamp(0.0, 1.0)
        : 0.0;
    final time =
        '${_formatDuration(_currentPosition)} / '
        '${_audioDuration != null ? _formatDuration(_audioDuration!) : '--:--'}';
    final stateWords = isPlaying
        ? (widget.isTeacher ? 'Playing' : 'Playing, synced')
        : (widget.isTeacher ? 'Paused' : 'Paused by teacher');
    final title = _currentAudioTitle ?? 'Class recording';
    final speed = '${_audioSpeed.toStringAsFixed(2)}×';

    Widget transport(
      FocusNode node,
      IconData icon,
      String tooltip,
      VoidCallback? onPressed, {
      bool primary = false,
    }) => IconButton(
      focusNode: node,
      tooltip: tooltip,
      icon: Icon(
        icon,
        color: primary ? UIUtils.onPrimaryColor : UIUtils.textColor,
        size: UIUtils.iconSize(context, primary ? 26 : 22),
      ),
      style: primary
          ? IconButton.styleFrom(backgroundColor: UIUtils.primaryColor)
          : null,
      constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
      onPressed: onPressed,
    );

    return Container(
      padding: UIUtils.paddingSymmetric(context, horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: UIUtils.cardColor,
        border: Border(
          bottom: BorderSide(
            color: isPlaying ? UIUtils.accentColor : UIUtils.cardBorderColor,
            width: 2,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            container: true,
            label: 'Class recording: $title. $stateWords. Speed $speed. $time',
            child: ExcludeSemantics(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: _textStyle(size: 16, weight: FontWeight.bold),
                  ),
                  Text(
                    '$stateWords · $speed · $time',
                    style: _textStyle(color: UIUtils.subtextColor),
                  ),
                ],
              ),
            ),
          ),
          if (widget.isTeacher && !compact)
            Focus(
              focusNode: _seekFocusNode,
              child: ExcludeFocus(
                child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 4,
                    activeTrackColor: UIUtils.accentColor,
                    inactiveTrackColor: UIUtils.cardBorderColor,
                    thumbColor: UIUtils.accentColor,
                  ),
                  child: Slider(
                    value: progress,
                    semanticFormatterCallback: (_) => time,
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
          else
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: UIUtils.spacing(context, 4),
              ),
              child: ExcludeSemantics(
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: UIUtils.cardBorderColor,
                  color: UIUtils.accentColor,
                  minHeight: 4,
                ),
              ),
            ),
          if (widget.isTeacher) ...[
            Wrap(
              alignment: WrapAlignment.center,
              spacing: UIUtils.spacing(context, 4),
              runSpacing: UIUtils.spacing(context, 4),
              children: [
                transport(
                  _slowerFocusNode,
                  Icons.fast_rewind,
                  'Decrease audio speed',
                  _audioSpeed > 0.5
                      ? () => _changeAudioSpeed(
                          (_audioSpeed - 0.25).clamp(0.5, 2.0),
                        )
                      : null,
                ),
                transport(
                  _rewindFocusNode,
                  Icons.replay_10,
                  'Back 10 seconds',
                  () => _seekBy(-10),
                ),
                transport(
                  _playFocusNode,
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  isPlaying ? 'Pause audio' : 'Play audio',
                  _toggleSessionAudio,
                  primary: true,
                ),
                transport(
                  _forwardFocusNode,
                  Icons.forward_10,
                  'Forward 10 seconds',
                  () => _seekBy(10),
                ),
                transport(
                  _fasterFocusNode,
                  Icons.fast_forward,
                  'Increase audio speed',
                  _audioSpeed < 2.0
                      ? () => _changeAudioSpeed(
                          (_audioSpeed + 0.25).clamp(0.5, 2.0),
                        )
                      : null,
                ),
              ],
            ),
            if (UIUtils.isKeypad(context))
              ExcludeSemantics(
                child: Text(
                  '$playerRewindKey: back 10 s · $playerPlayPauseKey: play or pause · '
                  '$playerForwardKey: forward 10 s',
                  textAlign: TextAlign.center,
                  style: _textStyle(color: UIUtils.subtextColor),
                ),
              ),
          ],
        ],
      ),
    );
  }

  // ── Audio Library Panel (teacher only, toggled from action bar) ───────────

  Widget _buildAudioLibraryPanel() {
    if (!_showAudioPanel) return const SizedBox.shrink();
    final stacked = _stackedLayout;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final panelHeight =
        (screenHeight < 520
                ? (screenHeight * 0.36).clamp(120.0, 220.0)
                : (screenHeight * 0.4).clamp(240.0, 320.0))
            .toDouble();

    final header = Container(
      padding: UIUtils.paddingAll(context, 6),
      color: UIUtils.cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text(
              'Audio library',
              style: _textStyle(size: 16, weight: FontWeight.bold),
            ),
          ),
          SizedBox(height: UIUtils.spacing(context, 4)),
          _buttonGroup(
            [
              _labelledButton(
                node: _uploadFocusNode,
                icon: Icons.upload_file,
                text: _isUploadingAudio ? 'Uploading?' : 'Upload audio',
                semanticLabel: _isUploadingAudio
                    ? 'Audio upload in progress'
                    : 'Upload audio',
                onPressed: _isUploadingAudio ? null : _uploadAudio,
                stacked: stacked,
              ),
              _labelledButton(
                node: _refreshAudioFocusNode,
                icon: Icons.refresh,
                text: 'Refresh',
                semanticLabel: 'Refresh audio library',
                onPressed: _loadAudioLibrary,
                stacked: stacked,
              ),
              _labelledButton(
                node: _closeAudioFocusNode,
                icon: Icons.close,
                text: 'Close library',
                semanticLabel: 'Close audio library',
                onPressed: _toggleAudioPanel,
                stacked: stacked,
              ),
            ],
            stacked,
            alignment: WrapAlignment.start,
          ),
          if (_isUploadingAudio)
            Padding(
              padding: EdgeInsets.only(top: UIUtils.spacing(context, 4)),
              child: LinearProgressIndicator(
                color: UIUtils.accentColor,
                backgroundColor: UIUtils.cardBorderColor,
                minHeight: 3,
              ),
            ),
        ],
      ),
    );

    Widget audioCard(Map<String, dynamic> audio) {
      final audioId = (audio['audio_id'] ?? audio['id']) as int;
      final title = audio['title'] as String? ?? 'Untitled';
      final desc = audio['description'] as String? ?? '';
      final isPrev = _previewingAudioId == audioId;
      final isActive = _currentAudioId == audioId;
      return Card(
        color: UIUtils.cardColor,
        margin: EdgeInsets.only(bottom: UIUtils.spacing(context, 6)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: isActive ? UIUtils.accentColor : UIUtils.cardBorderColor,
            width: isActive ? 3 : 1,
          ),
        ),
        child: Padding(
          padding: UIUtils.paddingAll(context, 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isActive ? '$title (active)' : title,
                style: _textStyle(weight: FontWeight.bold),
              ),
              if (desc.isNotEmpty)
                Text(desc, style: _textStyle(color: UIUtils.subtextColor)),
              SizedBox(height: UIUtils.spacing(context, 4)),
              _buttonGroup(
                [
                  _labelledButton(
                    node: _focusNodeFor(
                      _previewAudioFocusNodes,
                      audioId,
                      'audio-preview',
                    ),
                    icon: isPrev ? Icons.stop_circle : Icons.headphones_rounded,
                    text: isPrev ? 'Stop preview' : 'Preview privately',
                    semanticLabel: isPrev
                        ? 'Stop preview of $title'
                        : 'Preview $title privately',
                    onPressed: () => _previewAudio(audioId, title),
                    stacked: stacked,
                  ),
                  _labelledButton(
                    node: _focusNodeFor(
                      _selectAudioFocusNodes,
                      audioId,
                      'audio-select',
                    ),
                    icon: Icons.campaign_rounded,
                    text: 'Play for class',
                    semanticLabel: 'Select and play $title for the session',
                    onPressed: () => _selectAndPlayAudio(audioId, title),
                    stacked: stacked,
                  ),
                ],
                stacked,
                alignment: WrapAlignment.start,
              ),
            ],
          ),
        ),
      );
    }

    final Widget list = !_audioLibraryLoaded
        ? Center(child: CircularProgressIndicator(color: UIUtils.accentColor))
        : _audioFiles.isEmpty
        ? Padding(
            padding: UIUtils.paddingAll(context, 8),
            child: Text(
              'No audio files yet. Use Upload audio to add one.',
              textAlign: TextAlign.center,
              style: _textStyle(color: UIUtils.subtextColor),
            ),
          )
        : stacked
        ? Padding(
            padding: UIUtils.paddingAll(context, 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [for (final audio in _audioFiles) audioCard(audio)],
            ),
          )
        : ListView.builder(
            padding: UIUtils.paddingAll(context, 6),
            itemCount: _audioFiles.length,
            itemBuilder: (_, i) => audioCard(_audioFiles[i]),
          );

    final decoration = BoxDecoration(
      color: UIUtils.backgroundColor,
      border: Border(top: BorderSide(color: UIUtils.accentColor, width: 2)),
    );
    if (stacked) {
      // Inside the page scroll: grow with content instead of clipping.
      return DecoratedBox(
        decoration: decoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [header, list],
        ),
      );
    }
    return Container(
      height: panelHeight,
      decoration: decoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header,
          Expanded(child: list),
        ],
      ),
    );
  }
}
