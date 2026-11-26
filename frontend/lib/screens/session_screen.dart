// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'
    show MissingPluginException, PlatformException;
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../announcers/announce.dart';
import '../announcers/session_text.dart';
import '../l10n/speech.dart';
import '../main.dart' show routeObserver;
import '../services/api_service.dart';
import '../services/auth_session_service.dart';
import '../services/class_entry.dart';
import '../services/feedback_cues.dart';
import '../services/journey_api.dart';
import '../services/message_center.dart';
import '../services/offline_journey_store.dart';
import '../services/pending_action.dart';
import '../services/private_note_recorder.dart';
import '../services/session_microphone_controller.dart';
import '../services/session_voice_controller.dart';
import '../services/sse_service.dart';
import '../services/tts_service.dart';
import '../utils/keypad_actions.dart';
import '../utils/ui_utils.dart';
import '../widgets/journey_menu.dart';
import '../widgets/journey_prompts.dart';
import '../widgets/key_instruction_wrapper.dart';
import '../widgets/keypad_confirmation_dialog.dart';
import 'journeys/journey_player_screen.dart';
import 'quiz_screens.dart' show QuizAttemptScreen;
import 'session/class_console_screen.dart';
import 'session/class_members_screen.dart';
import 'session/live_session.dart';
import 'session/session_audio_upload.dart';
import 'session/session_chat_screen.dart';
import 'session/session_peers.dart';
import 'session/session_recordings_screen.dart';

/// The live class as a teacher runs it: 1 mute, 2 raised hands queue,
/// 3 mute all students, 4 class list, 5 start a quiz, journey or recording,
/// 6 status of what is running (only while something runs), 7 More (add
/// time, chat, class status), 8 end class for everyone, 0 leave. Teachers
/// have no hand to raise.
class TeacherSessionScreen extends SessionScreen {
  const TeacherSessionScreen({
    super.key,
    required super.sessionId,
    required super.userId,
    required super.userName,
    super.sessionTitle,
    super.className,
    super.subjectName,
    super.liveClass,
  }) : super(isTeacher: true);
}

/// The live class as a student takes part: 1 mute, 2 raise or lower hand,
/// 3 hear what the teacher is playing (read only), 4 start the quiz or
/// journey the teacher opened (only while one is open), 7 More (chat, who is
/// in class, class status), 0 leave. Students cannot control the class, its
/// recording or anyone else.
class StudentSessionScreen extends SessionScreen {
  const StudentSessionScreen({
    super.key,
    required super.sessionId,
    required super.userId,
    required super.userName,
    super.sessionTitle,
    super.className,
    super.subjectName,
    super.liveClass,
  }) : super(isTeacher: false);
}

/// Shared live class: connection, WebRTC, microphone and the class
/// recording. Its main screen shows only the options of the account's role;
/// prefer [TeacherSessionScreen] or [StudentSessionScreen]. Chat, the
/// participants list and recordings open as their own screens while this
/// screen keeps the class connection, WebRTC and microphone.
class SessionScreen extends StatefulWidget {
  final int sessionId;
  final int userId;
  final bool isTeacher;
  final String userName;
  final String? _sessionTitle;
  final String? className;
  final String? subjectName;

  /// The class summary from `/me/home`: end time, whether more time can be
  /// added and, for teachers, today's prepared lesson.
  final Map<String, dynamic>? liveClass;

  String get sessionTitle => _sessionTitle ?? SessionText.defaultTitle;

  const SessionScreen({
    super.key,
    required this.sessionId,
    required this.userId,
    this.isTeacher = false,
    required this.userName,
    String? sessionTitle,
    this.className,
    this.subjectName,
    this.liveClass,
  }) : _sessionTitle = sessionTitle;

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen>
    with WidgetsBindingObserver, RouteAware
    implements LiveSession {
  // ── transport and media ────────────────────────────────────────────────
  final SseService _sse = SseService();
  MediaStream? _localStream;
  late final _peers = SessionPeers(
    send: _sse.send,
    localStream: () => _localStream,
    ownParticipantId: () => _participantId,
    isMuted: (id) => _participants[id]?['is_muted'] == true,
    isActive: () => mounted,
    onChanged: setState,
  );
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
  ModalRoute<void>? _voiceRoute;
  bool _voiceUnmuteDialogOpen = false;

  late final _microphone = SessionMicrophoneController(
    isAvailable: () => _localStream?.getAudioTracks().isNotEmpty == true,
    setCaptureEnabled: (enabled) {
      _localStream?.getAudioTracks().forEach(
        (track) => track.enabled = enabled,
      );
    },
    sendMute: (muted) => _sse.send({'type': 'mute_self', 'mute': muted}),
  );

  // ── class state ────────────────────────────────────────────────────────
  bool get _muted => _microphone.muted;
  bool get _mutePending => _microphone.pending;
  bool _handRaised = false;
  bool _handPending = false;
  int _handRevision = 0;
  bool _voiceCommandsEnabled = false;
  bool _isInitializing = true;
  // Set from the SSE 'connected' event — authoritative server-assigned id
  int? _participantId;
  final Map<int, Map<String, dynamic>> _participants = {};
  final List<Map<String, dynamic>> _messages = [];
  bool _chatPending = false;
  bool _endingSession = false;
  String _connectionMessage = SessionText.connecting;
  bool _everConnected = false;
  bool _connectionLossAnnounced = false;
  String? _speechWhenIdle;
  // Teacher: who joined or left, spoken together after a short pause, and
  // one "4 of 5 students here" a minute after the class starts.
  int? _enrolledStudents;
  final _joinedNames = <String>[];
  final _leftNames = <String>[];
  Timer? _presenceTimer;
  Timer? _startSummaryTimer;
  static const _presencePause = Duration(seconds: 2);
  static const _startSummaryDelay = Duration(minutes: 1);

  // The quiz or journey the teacher opened for the class: kind, id, title.
  Map<String, dynamic>? _activity;
  bool _activityBusy = false;
  bool _isReturningToDashboard = false;
  bool _leaveConfirmationOpen = false;

  // ── class lifecycle (S06/S20/S22/S44/S45) ──────────────────────────────
  late String? _cutoffClock = widget.liveClass?['cutoff_clock']?.toString();
  late bool _canExtend = widget.liveClass?['can_extend'] == true;
  bool _extending = false;
  bool _muteAllPending = false;
  bool _reminding = false;

  /// Today's prepared lesson, played in order with key 5.
  late final List<Map<String, dynamic>> _lessonItems = [
    for (final item in (widget.liveClass?['lesson_items'] as List?) ?? const [])
      Map<String, dynamic>.from(item as Map),
  ];
  int _lessonIndex = -1;

  /// Bumped on every state change so open sub-screens rebuild.
  final _changes = ValueNotifier<int>(0);

  // ── class recording ────────────────────────────────────────────────────
  int? _currentAudioId;
  String? _currentAudioTitle;
  bool _isPlayingSessionAudio = false;
  double _audioSpeed = 1.0;
  double? _audioDuration;
  double _currentPosition = 0.0;
  bool _isSeeking = false;

  // ── audio library (teacher) ────────────────────────────────────────────
  List<Map<String, dynamic>> _audioFiles = [];
  List<Map<String, dynamic>> _teacherSessions = [];
  bool _audioLibraryLoaded = false;
  bool _isUploadingAudio = false;
  int? _previewingAudioId;
  final AudioPlayer _previewPlayer = AudioPlayer();
  final _uploadTitle = TextEditingController();
  final _uploadDescription = TextEditingController();

  // ── keypad ─────────────────────────────────────────────────────────────
  final _keypadController = KeypadNavigationController();
  final _muteFocus = FocusNode(debugLabel: 'session-mute');
  final _handFocus = FocusNode(debugLabel: 'session-hand');
  final _recordingFocus = FocusNode(debugLabel: 'session-recording');
  final _participantsFocus = FocusNode(debugLabel: 'session-participants');
  final _muteAllFocus = FocusNode(debugLabel: 'session-mute-all');
  final _moreFocus = FocusNode(debugLabel: 'session-more');
  final _activityFocus = FocusNode(debugLabel: 'session-activity');
  final _endClassFocus = FocusNode(debugLabel: 'session-end-class');
  final _journeyFocus = FocusNode(debugLabel: 'session-journey');
  final _voiceFocus = FocusNode(debugLabel: 'session-listen-command');
  final _retryFocus = FocusNode(debugLabel: 'session-retry-connection');
  final _leaveFocus = FocusNode(debugLabel: 'session-leave');

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
    _changes.value++;
  }

  // ── lifecycle ──────────────────────────────────────────────────────────

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
      final seconds = pos.inSeconds.toDouble();
      // Rebuild once a second, not on every player tick; keypad phones are slow.
      if (mounted && !_isSeeking && seconds != _currentPosition) {
        setState(() => _currentPosition = seconds);
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
        _speakIfEnabled(SessionText.playbackFinished);
        if (widget.isTeacher) unawaited(_advanceLesson());
      }
    });

    TtsService.registerLiveSession(this);
    // Private preview player for the teacher's audio library.
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
      await _joinSessionHttp();
      if (!mounted) return;

      // The SSE stream also creates the participant row server-side and
      // returns the authoritative participant_id via the 'connected' event.
      _connectSse();

      if (widget.isTeacher) {
        _loadAudioLibrary();
        _loadTeacherSessions();
      }

      setState(() => _isInitializing = false);
      if (widget.isTeacher) _scheduleStartSummary();
      // State, then every key; star or "repeat" reads them again.
      final carried = MessageCenter.takeArrivalMessage();
      await _speakIfEnabled(
        [
          ?carried,
          widget.isTeacher
              ? SessionText.joinedTeacherBrief
              : SessionText.joinedStudentBrief,
          if (_cutoffClock != null) SessionText.endsBy(_cutoffClock!),
          // Every key once on joining, so nothing has to be discovered.
          SessionText.keyHelp(_keyLabels),
        ].join(' '),
      );
    } catch (e) {
      print('[INIT ERROR] $e');
      if (!mounted) return;
      _error(SessionText.joinFailed);
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
    setState(() => _voiceCommandsEnabled = voiceEnabled);
  }

  Future<void> _loadTeacherSessions() async {
    final sessions = await ApiService.getActiveSessions();
    if (sessions == null || !mounted) return;
    final mapped = sessions
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    final current = mapped
        .where((session) => session['session_id'] == widget.sessionId)
        .firstOrNull;
    setState(() {
      _teacherSessions = current == null
          ? mapped
          : mapped
                .where(
                  (session) =>
                      session['class_id'] == current['class_id'] &&
                      session['subject_id'] == current['subject_id'],
                )
                .toList();
    });
  }

  static const _micDeclinedKey = 'microphone_permission_declined';

  /// S19: everyone joins muted and can listen without a microphone. The
  /// first class asks once; after a refusal later classes do not ask again,
  /// and pressing Unmute asks again (or offers Android settings).
  Future<void> _initializeMedia() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final status = await _micStatus();
    if (status == null || status.isGranted || status.isLimited) {
      // Already allowed (or a platform without a permission step).
      if (!await _openMicrophone()) _microphone.applyRemoteMute(true);
      return;
    }
    _microphone.applyRemoteMute(true);
    if (prefs.getBool(_micDeclinedKey) == true) return;
    await _speakIfEnabled(SessionText.micAskOnce);
    if (!mounted) return;
    if (!await _requestMicrophone(status)) {
      await prefs.setBool(_micDeclinedKey, true);
      if (mounted) _error(SessionText.micSkipped);
    }
  }

  Future<PermissionStatus?> _micStatus() async {
    if (kIsWeb) return null;
    try {
      // A stalled platform answer must never hold a student outside class.
      return await Permission.microphone.status.timeout(
        const Duration(seconds: 3),
      );
    } on TimeoutException {
      return null;
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
  }

  /// [status] null means the platform has no permission step (getUserMedia
  /// itself asks, as on the web).
  Future<bool> _requestMicrophone(PermissionStatus? status) async {
    if (status != null) {
      try {
        final result = await Permission.microphone.request();
        if (!result.isGranted && !result.isLimited) return false;
      } on PlatformException {
        // Fall through: getUserMedia asks where the plugin is unavailable.
      } on MissingPluginException {
        // As above.
      }
    }
    return _openMicrophone();
  }

  /// Opens the microphone with every track switched off (still muted).
  Future<bool> _openMicrophone() async {
    if (_localStream != null) return true;
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
        return false;
      }
      _localStream = stream;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_micDeclinedKey);
      if (!_isInitializing) unawaited(_peers.addLocalStream(stream));
      print('[MEDIA] Local stream ready');
      return true;
    } catch (e) {
      print('[MEDIA ERROR] $e');
      if (mounted) _microphone.applyRemoteMute(true);
      return false;
    }
  }

  /// Unmute without a microphone: ask again, or explain how to allow it in
  /// Android settings when Android will no longer show its question.
  Future<bool> _ensureMicrophoneForUnmute() async {
    if (_localStream != null) return true;
    final status = await _micStatus();
    if (status != null && status.isPermanentlyDenied) {
      if (!mounted) return false;
      final open = await showDialog<bool>(
        context: context,
        builder: (_) => KeypadConfirmationDialog(
          title: SessionText.micSettingsTitle,
          message: SessionText.micSettingsMessage,
          cancelLabel: SessionText.micSettingsCancel,
          confirmLabel: SessionText.micSettingsOpen,
        ),
      );
      if (open == true) await openAppSettings();
      return false;
    }
    await _speakIfEnabled(SessionText.micAskAgain);
    final granted = await _requestMicrophone(status);
    if (!granted && mounted) _error(SessionText.micStillOff);
    return granted;
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
      // Non-fatal: SSE endpoint will create the participant row too.
      print('[JOIN HTTP ERROR] $e');
    }
  }

  // ── SSE connection ─────────────────────────────────────────────────────

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
        _error('${data['message']}');
      case 'connected':
        final pid = data['participant_id'] as int?;
        if (pid != null) {
          setState(() => _participantId = pid);
          print('[SSE] Server assigned participant_id=$pid');
        }
      case 'session_state':
        _updateSessionState(data);
        // Announced once if it is new to this student (joined late).
        _applyActivity(data['activity'], announce: false);
        if (widget.isTeacher) unawaited(_prepareLesson());
      case 'activity_started':
        _applyActivity(data, announce: true);
      case 'activity_stopped':
        _applyActivity(null, announce: true);
      case 'activity_reminder':
        if (!widget.isTeacher && data['id'] == _activity?['id']) {
          unawaited(FeedbackCues.play(Cue.ok));
          _speakIfEnabled(
            SessionText.activityReminder('${data['kind']}', '${data['title']}'),
            priority: SpeechPriority.critical,
          );
        }
      case 'participant_joined':
        _onParticipantJoined(data);
      case 'participant_left':
        _onParticipantLeft(data);
      case 'participant_kicked':
        // Another participant was kicked — remove them from local list
        final pid = data['participant_id'] as int?;
        if (pid != null && pid != _participantId) {
          setState(() => _participants.remove(pid));
          _peers.close(pid);
        }
      case 'participant_muted':
        _onParticipantMuted(data);
      case 'hand_raised':
        _onHandChanged(data, true);
      case 'hand_lowered':
        _onHandChanged(data, false);
      case 'chat':
        _onChatMessage(data);
      case 'kicked':
        _returnToDashboard(reason: SessionText.youWereRemoved);
      case 'authentication_revoked':
        _onAuthenticationRevoked();
      case 'session_ended':
      case 'session_ending':
        _returnToDashboard(reason: SessionText.classEnded);
      case 'webrtc_signal':
        _peers.handleSignal(data);
      case 'audio_selected':
        _onAudioSelected(data);
      case 'audio_cleared':
        unawaited(_onAudioCleared(data));
      case 'audio_play':
        _onAudioPlay(data);
      case 'audio_pause':
        _onAudioPause(data);
      case 'audio_seek':
        _onAudioSeek(data);
      case 'audio_speed_change':
        final newSpeed = (data['speed'] as num?)?.toDouble();
        if (newSpeed != null) _applyAudioSpeedLocally(newSpeed);
      case 'class_ending_soon':
        _onEndingSoon(data);
      case 'class_extended':
        _onExtended(data);
      case 'error':
        print('[SSE SERVER ERROR] ${data['detail']}');
        _error(SessionText.requestFailed);
      default:
        print('[SSE] Unhandled type: $type');
    }
  }

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
          _speakIfEnabled(SessionText.connectionRestored(_connectionMessage));
        } else {
          _speakWhenIdle(_connectionMessage);
        }
      case SessionConnectionState.reconnecting:
        // Each retry republishes "reconnecting"; only the first loss is spoken.
        if (_connectionLossAnnounced) return;
        _connectionLossAnnounced = true;
        _speakIfEnabled(
          SessionText.connectionLost(_everConnected, _connectionMessage),
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
    final participants = data['participants'] as Map<String, dynamic>? ?? {};
    _enrolledStudents = data['enrolled_students'] as int? ?? _enrolledStudents;
    setState(() {
      _participants.clear();
      participants.forEach((key, value) {
        final pid = int.tryParse(key);
        if (pid == null || pid == 0) return;
        final meta = value as Map<String, dynamic>;
        _participants[pid] = {
          'id': pid,
          'user_id': meta['user_id'],
          'name': meta['name'] ?? SessionText.userFallback(meta['user_id']),
          'is_muted': meta['is_muted'] ?? false,
          'raised_hand': meta['raised_hand'] ?? false,
          'hand_queue_order': meta['hand_queue_order'],
          'hand_revision': meta['hand_revision'] ?? 0,
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
    for (final participant in _peers.ids.toList()) {
      if (!_participants.containsKey(participant)) _peers.close(participant);
    }
    print('[STATE] ${_participants.length} participants');

    // Restore audio playback state if the session was already playing
    final playback = data['playback'] as Map<String, dynamic>?;
    if (playback != null && playback['status'] == 'playing') {
      final audioId = playback['audio_id'] as int?;
      if (audioId != null) {
        _onAudioPlay({
          'audio_id': audioId,
          'speed': (playback['speed'] as num?)?.toDouble() ?? 1.0,
          'position': (playback['position'] as num?)?.toDouble() ?? 0.0,
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
          .where((pid) => pid != myPid && !_peers.contains(pid))
          .forEach((pid) => _peers.create(pid, true));
    }
  }

  // ── participant events ─────────────────────────────────────────────────

  void _onParticipantJoined(Map<String, dynamic> data) {
    final pid = data['participant_id'] as int?;
    final uid = data['user_id'] as int?;
    if (pid == null || pid == _participantId) return;
    final name = data['name'] as String? ?? SessionText.userFallback(uid);
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
        'is_teacher': data['is_teacher'] as bool? ?? false,
      };
    });
    if (data['is_teacher'] != true) _notePresence(joined: name);

    // Give both sides time to open their SSE streams before WebRTC
    // negotiation. The participant with the higher id creates the offer.
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted && !_peers.contains(pid)) {
        _peers.create(pid, (_participantId ?? 0) > pid);
      }
    });
  }

  int get _studentsHere =>
      _participants.values.where((p) => p['is_teacher'] != true).length;

  /// Teacher only: collects names and speaks them together ("Akshat and
  /// Meena joined. 4 of 5 here.") once the joins pause. During the first
  /// minute nothing is spoken; the start summary covers it.
  void _notePresence({String? joined, String? left}) {
    if (!widget.isTeacher) return;
    if (joined != null) {
      if (!_leftNames.remove(joined)) _joinedNames.add(joined);
    }
    if (left != null) {
      if (!_joinedNames.remove(left)) _leftNames.add(left);
    }
    if (_startSummaryTimer?.isActive ?? false) {
      _joinedNames.clear();
      _leftNames.clear();
      return;
    }
    _presenceTimer?.cancel();
    _presenceTimer = Timer(_presencePause, _speakPresence);
  }

  void _speakPresence() {
    if (!mounted || (_joinedNames.isEmpty && _leftNames.isEmpty)) return;
    final text = SessionText.presence(
      joined: List.of(_joinedNames),
      left: List.of(_leftNames),
      here: _studentsHere,
      total: _enrolledStudents,
    );
    _joinedNames.clear();
    _leftNames.clear();
    _speakIfEnabled(text, priority: SpeechPriority.navigation);
  }

  /// One "4 of 5 students here" a minute after the class started, instead
  /// of an announcement for each student who joins at the start.
  void _scheduleStartSummary() {
    final started =
        DateTime.tryParse('${widget.liveClass?['started_at']}') ??
        DateTime.now();
    final wait = started.add(_startSummaryDelay).difference(DateTime.now());
    if (wait <= Duration.zero) return;
    _startSummaryTimer = Timer(wait, () {
      if (!mounted) return;
      _joinedNames.clear();
      _leftNames.clear();
      _speakIfEnabled(
        SessionText.startSummary(_studentsHere, _enrolledStudents),
        priority: SpeechPriority.navigation,
      );
    });
  }

  void _onParticipantLeft(Map<String, dynamic> data) {
    final pid = data['participant_id'] as int?;
    if (pid == null) return;
    final gone = _participants[pid];
    setState(() => _participants.remove(pid));
    _peers.close(pid);
    if (gone != null && gone['is_teacher'] != true) {
      _notePresence(left: '${gone['name']}');
    }
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
    if (pid != _participantId) return;
    final wasLive = !_muted && !_mutePending;
    _microphone.applyRemoteMute(isMuted);
    if (isMuted && wasLive) {
      // The class muted this phone (for example the teacher did).
      unawaited(FeedbackCues.play(Cue.muted));
      MessageCenter.show(SessionText.mutedByTeacher, cue: false);
    }
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
      participant['raised_hand'] = raised;
      participant['hand_queue_order'] = raised
          ? data['hand_queue_order']
          : null;
      participant['hand_revision'] = revision ?? currentRevision;
      if (pid == _participantId) {
        _handRaised = raised;
        _handRevision++;
      }
    });
    if (raised && widget.isTeacher && pid != _participantId) {
      // Requested (not incidental) so teachers hear it during live audio.
      _speakIfEnabled(SessionText.raisedHandBy(participant['name'] as String?));
    }
  }

  void _onChatMessage(Map<String, dynamic> data) {
    final senderName =
        data['sender_name'] as String? ?? SessionText.unknownSender;
    final text = data['text'] as String? ?? '';
    // Own messages were added when sent; skip the echo.
    if (text.isEmpty || data['is_own'] == true) return;
    setState(() {
      _messages.add({
        'sender': senderName,
        'text': text,
        'timestamp': DateTime.now(),
        'isMe': false,
      });
    });
    _speakIfEnabled(
      SessionText.messageFrom(senderName, text),
      priority: SpeechPriority.incidental,
    );
  }

  Future<void> _onAuthenticationRevoked() async {
    if (_isReturningToDashboard || !mounted) return;
    _isReturningToDashboard = true;
    _microphone.applyRemoteMute(true);
    _sse.close();
    unawaited(FeedbackCues.play(Cue.leave));
    try {
      await _voice.stop();
      await _peers.closeAll().timeout(const Duration(seconds: 2));
      await Future.wait([
        _sessionAudioPlayer.stop(),
        _previewPlayer.stop(),
      ]).timeout(const Duration(seconds: 2));
    } on PlatformException {
      debugPrint(
        '[SESSION] Native media cleanup failed after sign-in revocation',
      );
      _error(SessionText.cleanupFailed);
    } on TimeoutException {
      debugPrint(
        '[SESSION] Native media cleanup timed out after sign-in revocation',
      );
      _error(SessionText.cleanupTimedOut);
    } finally {
      await AuthSessionService.clearLoginState();
      if (mounted) {
        MessageCenter.carryToNextScreen(
          SessionText.signInChanged,
          kind: MessageKind.error,
        );
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
      }
    }
  }

  // ── class recording (synchronised for everyone) ────────────────────────

  void _onAudioSelected(Map<String, dynamic> data) {
    final audioId = data['audio_id'] as int?;
    if (audioId == null) return;
    setState(() {
      _currentAudioId = audioId;
      _currentAudioTitle = data['title'] as String?;
    });
    _speakIfEnabled(
      SessionText.recordingSelectionChanged,
      priority: SpeechPriority.incidental,
      group: SessionText.recordingSelectionGroup,
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
      if (mounted) setState(() => _isPlayingSessionAudio = false);
    }
  }

  /// The teacher closed the class recording: stop it here and forget it, so
  /// nothing is playing and Status (7) goes away.
  Future<void> _onAudioCleared(Map<String, dynamic> data) async {
    final hadRecording = _currentAudioId != null;
    final title = data['title'] as String? ?? _currentAudioTitle;
    if (!mounted) return;
    setState(() {
      _currentAudioId = null;
      _currentAudioTitle = null;
      _isPlayingSessionAudio = false;
      _currentPosition = 0;
      _audioDuration = null;
      _recordingRunning = false;
    });
    if (!widget.isTeacher && hadRecording) {
      _speakIfEnabled(
        SessionText.recordingClosedStudent(
          title ?? SessionText.recordingFallbackLower,
        ),
      );
    }
    // A slow native player must not delay the state or the announcement.
    try {
      await _sessionAudioPlayer.stop().timeout(const Duration(seconds: 2));
    } catch (error) {
      debugPrint('[AUDIO STOP ERROR] $error');
    }
  }

  @override
  Future<bool> closeRecording() async {
    final title = _currentAudioTitle ?? SessionText.recordingFallbackLower;
    final closed = await ApiService.closeClassRecording(widget.sessionId);
    if (!mounted) return false;
    if (!closed.isSuccess) {
      _error(closed.failure!.message);
      return false;
    }
    unawaited(_onAudioCleared({'title': title}));
    unawaited(FeedbackCues.play(Cue.ok));
    _speakIfEnabled(SessionText.recordingClosedTeacher(title));
    return true;
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
    if (!mounted) return;
    setState(() => _currentPosition = position);
    if (resumePlaying && !_isPlayingSessionAudio) {
      await _sessionAudioPlayer.resume();
      if (mounted) setState(() => _isPlayingSessionAudio = true);
    }
  }

  void _applyAudioSpeedLocally(double speed) {
    setState(() => _audioSpeed = speed);
    _sessionAudioPlayer.setPlaybackRate(speed);
  }

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
    if (result.isSuccess) {
      unawaited(FeedbackCues.play(Cue.ok));
    } else {
      _error(result.failure!.message);
    }
  }

  Future<void> _pauseSessionAudio() async {
    // Show and announce the pause at once; a slow player must not make
    // key 5 look as if nothing happened.
    setState(() => _isPlayingSessionAudio = false);
    Duration? pos;
    try {
      pos = await _sessionAudioPlayer.getCurrentPosition().timeout(
        const Duration(seconds: 2),
      );
    } on Exception catch (error) {
      debugPrint('[SESSION] Reading the recording position failed: $error');
    }
    if (!mounted) return;
    final posSeconds = pos?.inSeconds.toDouble() ?? _currentPosition;
    setState(() => _currentPosition = posSeconds);
    try {
      await _sessionAudioPlayer.pause().timeout(const Duration(seconds: 3));
    } on Exception catch (error) {
      debugPrint('[SESSION] Pausing the recording failed: $error');
    }
    if (!mounted) return;
    final result = await ApiService.controlAudio(
      widget.sessionId,
      action: 'pause',
      position: posSeconds,
      canSend: () => mounted,
    );
    if (!mounted) return;
    if (result.isSuccess) {
      unawaited(FeedbackCues.play(Cue.ok));
    } else {
      _error(SessionText.classPauseUnconfirmed(result.failure!.message));
    }
  }

  /// Students: read only. Says what the teacher is playing and where it is;
  /// only the teacher can play, pause, seek or change speed.
  void _speakRecordingStatus() => _speakIfEnabled(
    SessionText.studentRecordingStatus(
      title: recordingTitle,
      playing: _isPlayingSessionAudio,
      position: SessionText.position(_currentPosition, _audioDuration),
    ),
  );

  Future<bool> _seekAudio(double position) async {
    if (!widget.isTeacher || _isSeeking) return false;
    setState(() => _isSeeking = true);
    try {
      final result = await ApiService.controlAudio(
        widget.sessionId,
        action: 'seek',
        position: position,
        canSend: () => mounted,
      );
      if (!mounted) return false;
      if (!result.isSuccess) {
        _error(result.failure!.message);
        return false;
      }
      await _sessionAudioPlayer.seek(Duration(seconds: position.toInt()));
      if (!mounted) return false;
      setState(() => _currentPosition = position);
      return true;
    } finally {
      if (mounted) setState(() => _isSeeking = false);
    }
  }

  Future<bool> _changeAudioSpeed(double newSpeed) async {
    if (!widget.isTeacher || _currentAudioId == null) return false;
    Duration? pos;
    try {
      pos = await _sessionAudioPlayer.getCurrentPosition().timeout(
        const Duration(seconds: 2),
      );
    } on Exception catch (error) {
      debugPrint('[SESSION] Reading the recording position failed: $error');
    }
    if (!mounted) return false;
    final result = await ApiService.controlAudio(
      widget.sessionId,
      action: 'play',
      audioId: _currentAudioId!,
      speed: newSpeed,
      position: pos?.inSeconds.toDouble() ?? _currentPosition,
      canSend: () => mounted,
    );
    if (!mounted) return false;
    if (!result.isSuccess) {
      _error(result.failure!.message);
      return false;
    }
    await _sessionAudioPlayer.setPlaybackRate(newSpeed);
    if (mounted) setState(() => _audioSpeed = newSpeed);
    return true;
  }

  // ── microphone and hand ────────────────────────────────────────────────

  Future<void> _toggleMute() async {
    if (_mutePending) {
      _speakIfEnabled(SessionText.waitingMic);
      return;
    }
    final nextMuted = !_muted;
    // Joining never needs the microphone; speaking does.
    if (!nextMuted && !await _ensureMicrophoneForUnmute()) return;
    if (!mounted) return;
    final result = await _microphone.toggle();
    if (!mounted) return;
    if (result.isSuccess) {
      // Server-confirmed state of this phone's microphone.
      unawaited(FeedbackCues.play(_muted ? Cue.muted : Cue.unmuted));
      await _speakIfEnabled(_muted ? SessionText.muted : SessionText.unmuted);
    } else if (nextMuted) {
      _error(SessionText.mutedLocallyOnly);
    } else {
      _error(result.failure!.message);
    }
  }

  /// Each press of 2 is a new request; a newer one (or cancelling a queued
  /// one) makes an older request stop retrying.
  int _handRequest = 0;

  /// The request is waiting for the connection to come back.
  bool _handQueued = false;

  Future<void> _toggleHandRaise() async {
    if (_handQueued) {
      _handRequest++;
      setState(() {
        _handQueued = false;
        _handPending = false;
      });
      _speakIfEnabled(SessionText.handQueueCancelled);
      return;
    }
    if (_handPending) {
      _speakIfEnabled(SessionText.waitingHand);
      return;
    }
    final raised = !_handRaised;
    final revision = _handRevision;
    final request = ++_handRequest;
    bool current() => mounted && request == _handRequest;
    setState(() => _handPending = true);
    // With no connection the hand is kept and sent when it is back, instead
    // of failing and asking the student to try again.
    final result = await sendWhenConnected(
      () => _sse.send({'type': raised ? 'raise_hand' : 'lower_hand'}),
      stillWanted: current,
      onQueued: () {
        if (!current()) return;
        setState(() => _handQueued = true);
        _speakIfEnabled(SessionText.handQueued(raised));
      },
    );
    if (!current()) return;
    setState(() {
      _handPending = false;
      _handQueued = false;
      if (result.isSuccess && revision == _handRevision) _handRaised = raised;
    });
    if (result.isSuccess) {
      unawaited(FeedbackCues.play(Cue.ok));
      await _speakIfEnabled(
        _handRaised ? SessionText.handRaised : SessionText.handLowered,
      );
    } else {
      _error(result.failure?.message ?? SessionText.handNotConfirmed);
    }
  }

  // ── voice commands (explicitly started, one command, 12 seconds) ──────

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
    if (mounted) MessageCenter.error(message);
  }

  Future<void> _toggleVoiceListening() async {
    if (_voice.busy) {
      final stopped = await _voice.stop();
      if (stopped && mounted) await _speakIfEnabled(SessionText.voiceStopped);
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
        builder: (_) => KeypadConfirmationDialog(
          title: SessionText.voiceUnmuteTitle,
          message: SessionText.voiceUnmuteMessage,
          confirmLabel: SessionText.voiceUnmuteConfirm,
          cancelLabel: SessionText.voiceUnmuteCancel,
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

    bool matches(Set<String> phrases) => phrases.contains(command);

    if (matches(const {
      'unmute',
      'unmute me',
      'unmute microphone',
      'unmute my microphone',
    })) {
      _muted
          ? await _confirmVoiceUnmute()
          : _speakIfEnabled(SessionText.alreadyUnmuted);
    } else if (matches(const {
      'mute',
      'mute me',
      'mute microphone',
      'mute my microphone',
    })) {
      !_muted ? _toggleMute() : _speakIfEnabled(SessionText.alreadyMutedSelf);
    } else if (!widget.isTeacher &&
        matches(const {'lower hand', 'lower my hand'})) {
      _handRaised
          ? _toggleHandRaise()
          : _speakIfEnabled(SessionText.handAlreadyLowered);
    } else if (!widget.isTeacher &&
        matches(const {'raise hand', 'raise my hand'})) {
      !_handRaised
          ? _toggleHandRaise()
          : _speakIfEnabled(SessionText.handAlreadyRaised);
    } else if (matches(const {'quiz', 'start quiz'})) {
      widget.isTeacher
          ? unawaited(_pickActivity('quiz'))
          : _activityKey('quiz');
    } else if (matches(const {'journey', 'start journey'})) {
      widget.isTeacher
          ? unawaited(_pickActivity('journey'))
          : _activityKey('journey');
    } else if (matches(const {
      'repeat',
      'instructions',
      'repeat instructions',
    })) {
      _repeatSessionInstructions();
    } else if (matches(const {'status', 'class status'})) {
      _speakClassStatus();
    } else if (matches(const {'chat', 'open chat'})) {
      _openChat();
    } else if (widget.isTeacher &&
        matches(const {'mute all', 'mute everyone', 'mute all students'})) {
      muteAllStudents();
    } else if (widget.isTeacher && matches(const {'audio', 'audio library'})) {
      _push(SessionRecordingsScreen(session: this));
    } else if (widget.isTeacher &&
        matches(const {'tools', 'teacher tools', 'more', 'more options'})) {
      _openMore();
    } else if (widget.isTeacher &&
        matches(const {'end class', 'end session'})) {
      confirmEndSession();
    } else if (matches(const {
      'who is here',
      'who is in class',
      'people',
      'participants',
    })) {
      widget.isTeacher ? _openParticipants() : _openMembers();
    } else if (matches(const {
      'leave',
      'exit',
      'leave session',
      'exit session',
    })) {
      _leaveSession();
    } else {
      _speakIfEnabled(SessionText.commandNotRecognized);
    }
  }

  Map<int, String> get _keyLabels => widget.isTeacher
      ? sessionTeacherKeyLabels(running: _running != null)
      : sessionStudentKeyLabels(activityOpen: _activity != null);

  Future<void> _repeatSessionInstructions() => _speakIfEnabled(
    SessionText.joined(
      teacher: widget.isTeacher,
      status: _stateSummary(),
      keys: SessionText.keyHelp(_keyLabels),
    ),
  );

  // ── status ("where am I" and key 3) ────────────────────────────────────

  /// Only what has changed from the ordinary: muted, any hands up, what is
  /// playing, an open quiz or journey, the end time and a connection problem.
  /// Counts and full detail are under More, Class status.
  String _stateSummary() => [
    SessionText.micState(_muted, _mutePending),
    if (widget.isTeacher) ...[
      if (raisedHandCount > 0) SessionText.handsWaiting(raisedHandCount),
    ] else if (_handRaised || _handPending)
      SessionText.handState(_handRaised, _handPending),
    SessionText.recordingState(
      title: _currentAudioId == null
          ? null
          : _currentAudioTitle ?? SessionText.recordingFallbackLower,
      playing: _isPlayingSessionAudio,
    ),
    if (_activityTitle != null)
      SessionText.activityState(
        teacher: widget.isTeacher,
        title: _activityTitle!,
      ),
    if (_cutoffClock != null) SessionText.endsBy(_cutoffClock!),
    if (_sse.state != SessionConnectionState.connected)
      SessionText.connection(_sse.state.label),
  ].where((part) => part.isNotEmpty).join(' ');

  @override
  String classStatus() => Announce.pick(
    brief: _stateSummary(),
    detailed: [
      _stateSummary(),
      if (_sse.state != SessionConnectionState.connected) _connectionMessage,
      SessionText.people(_participants.length),
      SessionText.messages(_messages.length),
    ].where((part) => part.isNotEmpty).join(' '),
  );

  void _speakClassStatus() => unawaited(
    TtsService.speak(classStatus(), priority: SpeechPriority.requested),
  );

  // ── LiveSession: participants ──────────────────────────────────────────

  @override
  Listenable get changes => _changes;

  @override
  bool get isTeacher => widget.isTeacher;

  @override
  int? get ownParticipantId => _participantId;

  @override
  List<Map<String, dynamic>> get participants => _participants.values.toList();

  @override
  int get raisedHandCount =>
      _participants.values.where((p) => p['raised_hand'] == true).length;

  bool _isParticipantMuted(Map<String, dynamic> participant) =>
      participant['id'] == _participantId
      ? _muted
      : participant['is_muted'] == true;

  @override
  String participantSummary(Map<String, dynamic> participant) =>
      SessionText.participant(
        participant,
        self: participant['id'] == _participantId,
        muted: _isParticipantMuted(participant),
        speaking: _peers.speaking.contains(participant['id']),
      );

  /// One key mutes every student (S20); the teacher's own microphone is not
  /// touched and students can unmute themselves afterwards. A retried press
  /// carries the same request id, so it is answered once and never
  /// silences a student who has since unmuted.
  String? _muteAllRequest;

  @override
  Future<void> muteAllStudents() async {
    if (!widget.isTeacher) return;
    if (_muteAllPending) {
      _speakIfEnabled(SessionText.muteAllWaiting);
      return;
    }
    final requestId = _muteAllRequest ??=
        '${widget.sessionId}-${DateTime.now().microsecondsSinceEpoch}';
    setState(() => _muteAllPending = true);
    try {
      final result = await _sse.send({
        'type': 'mute_all_students',
        'request_id': requestId,
      });
      if (!mounted) return;
      if (!result.isSuccess) {
        // Keep the id: pressing 2 again retries the same request.
        _error(SessionText.muteAllNotConfirmed(result.failure!.message));
        return;
      }
      _muteAllRequest = null;
      final muted = result.data?['muted'];
      unawaited(FeedbackCues.play(Cue.ok));
      _speakIfEnabled(
        muted is int && muted > 0
            ? SessionText.muteAllDone(muted)
            : SessionText.muteAllNone,
      );
    } finally {
      if (mounted) setState(() => _muteAllPending = false);
    }
  }

  @override
  Future<Map<String, dynamic>?> loadRoster() async {
    final result = await ApiService.classRoster(widget.sessionId);
    if (!mounted) return null;
    if (!result.isSuccess || result.data is! Map) {
      _error(result.failure?.message ?? SessionText.rosterUnavailable);
      return null;
    }
    return Map<String, dynamic>.from(result.data as Map);
  }

  @override
  Future<void> remindNotJoined() async {
    if (_reminding) return;
    setState(() => _reminding = true);
    try {
      final result = await ApiService.remindNotJoined(widget.sessionId);
      if (!mounted) return;
      if (!result.isSuccess) {
        _error(result.failure!.message);
        return;
      }
      final queued = result.data?['queued'] as int? ?? 0;
      final cooling = result.data?['cooldown'] as int? ?? 0;
      _speakIfEnabled(SessionText.reminderResult(queued, cooling));
    } finally {
      if (mounted) setState(() => _reminding = false);
    }
  }

  @override
  bool get canExtend => _canExtend;

  @override
  String? get endsAt => _cutoffClock;

  @override
  Future<void> extendClass() async {
    if (!widget.isTeacher || _extending) return;
    setState(() => _extending = true);
    try {
      final result = await ApiService.extendClass(widget.sessionId);
      if (!mounted) return;
      if (!result.isSuccess) {
        setState(() => _canExtend = false);
        _error(result.failure!.message);
        return;
      }
      _onExtended(result.data!);
    } finally {
      if (mounted) setState(() => _extending = false);
    }
  }

  void _onExtended(Map<String, dynamic> data) {
    setState(() {
      _cutoffClock = data['cutoff_clock']?.toString() ?? _cutoffClock;
      _canExtend = data['can_extend'] == true;
    });
    final clock = _cutoffClock;
    if (clock != null) _speakIfEnabled(SessionText.extendedUntil(clock));
  }

  void _onEndingSoon(Map<String, dynamic> data) {
    final minutes = data['minutes'] as int? ?? 0;
    setState(() => _canExtend = data['can_extend'] == true);
    _speakIfEnabled(
      widget.isTeacher
          ? SessionText.endingSoonTeacher(minutes, _canExtend)
          : SessionText.endingSoonStudent(minutes),
      priority: SpeechPriority.critical,
    );
  }

  /// Selects (never plays) today's prepared lesson, so key 5 plays it.
  Future<void> _prepareLesson() async {
    if (_lessonItems.isEmpty || _lessonIndex >= 0) return;
    final current = _lessonItems.indexWhere(
      (item) => item['audio_id'] == _currentAudioId,
    );
    if (current >= 0) {
      _lessonIndex = current;
      return;
    }
    if (_currentAudioId != null) return;
    _lessonIndex = 0;
    await _selectLessonItem(0, ready: SessionText.lessonReady);
  }

  Future<void> _advanceLesson() async {
    final next = _lessonIndex + 1;
    if (_lessonIndex < 0 || next >= _lessonItems.length) return;
    _lessonIndex = next;
    await _selectLessonItem(next, ready: SessionText.lessonNextReady);
  }

  Future<void> _selectLessonItem(int index, {required String ready}) async {
    final item = _lessonItems[index];
    final selected = await ApiService.selectAudio(
      widget.sessionId,
      item['audio_id'] as int,
      canSend: () => mounted,
    );
    if (!mounted || !selected.isSuccess) return;
    setState(() {
      _currentAudioId = item['audio_id'] as int;
      _currentAudioTitle = '${item['title']}';
    });
    _speakWhenIdle(ready);
  }

  @override
  Future<void> removeParticipant(int participantId) async {
    final participant = _participants[participantId];
    if (participant == null) return;
    final name = participant['name'] as String? ?? SessionText.thisParticipant;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => KeypadConfirmationDialog(
        title: SessionText.removeTitle(name),
        message: SessionText.removeMessage(name),
        cancelLabel: SessionText.keep(name),
        confirmLabel: SessionText.remove(name),
      ),
    );
    if (!mounted || confirmed != true) return;
    final result = await _sse.send({
      'type': 'kick_participant',
      'target_participant_id': participantId,
    });
    if (!mounted) return;
    if (result.isSuccess) {
      MessageCenter.success(SessionText.removed(name));
    } else {
      _error(result.failure!.message);
    }
  }

  // ── LiveSession: chat ──────────────────────────────────────────────────

  @override
  List<Map<String, dynamic>> get messages => List.unmodifiable(_messages);

  @override
  bool get chatPending => _chatPending;

  @override
  Future<bool> sendChat(String text) async {
    if (_chatPending) {
      _speakIfEnabled(SessionText.waitingMessage);
      return false;
    }
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      _speakIfEnabled(SessionText.emptyMessage);
      return false;
    }
    final message = <String, dynamic>{
      'sender': widget.userName,
      'text': trimmed,
      'timestamp': DateTime.now(),
      'isMe': true,
      'delivery': SessionText.sending,
    };
    setState(() {
      _chatPending = true;
      _messages.add(message);
    });
    final result = await _sse.send({'type': 'chat', 'text': trimmed});
    if (!mounted) return false;
    setState(() {
      _chatPending = false;
      message['delivery'] = result.isSuccess
          ? SessionText.sent
          : SessionText.notConfirmed;
    });
    if (result.isSuccess) {
      MessageCenter.success(SessionText.messageSent);
    } else {
      _error(result.failure!.message);
    }
    return result.isSuccess;
  }

  // ── LiveSession: recording ─────────────────────────────────────────────

  @override
  int? get recordingId => _currentAudioId;

  @override
  String? get recordingTitle => _currentAudioId == null
      ? null
      : _currentAudioTitle ?? SessionText.recordingFallback;

  @override
  bool get recordingPlaying => _isPlayingSessionAudio;

  @override
  double get recordingPosition => _currentPosition;

  @override
  double? get recordingDuration => _audioDuration;

  @override
  double get recordingSpeed => _audioSpeed;

  @override
  void toggleRecording() {
    if (!widget.isTeacher) {
      _speakRecordingStatus();
      return;
    }
    if (_currentAudioId == null) {
      _speakIfEnabled(SessionText.noRecordingTeacher);
      return;
    }
    _isPlayingSessionAudio ? _pauseSessionAudio() : _playSessionAudio();
  }

  @override
  Future<void> seekRecordingBy(double seconds) async {
    if (!widget.isTeacher) {
      _speakRecordingStatus();
      return;
    }
    if (_currentAudioId == null) {
      _speakIfEnabled(SessionText.noRecording);
      return;
    }
    final duration = _audioDuration;
    var target = math.max(0.0, _currentPosition + seconds);
    if (duration != null && duration > 0) target = math.min(target, duration);
    if (await _seekAudio(target)) {
      _speakIfEnabled(SessionText.position(target, duration));
    }
  }

  @override
  Future<void> changeRecordingSpeed(double delta) async {
    if (!widget.isTeacher) {
      _speakRecordingStatus();
      return;
    }
    final next = (_audioSpeed + delta).clamp(0.5, 2.0).toDouble();
    if (next == _audioSpeed) {
      unawaited(FeedbackCues.play(Cue.endOfList));
      _speakIfEnabled(SessionText.speed(_audioSpeed));
      return;
    }
    if (await _changeAudioSpeed(next)) {
      _speakIfEnabled(SessionText.speed(next));
    }
  }

  // ── LiveSession: audio library (teacher) ──────────────────────────────

  @override
  List<Map<String, dynamic>> get audioFiles => _audioFiles;

  @override
  bool get audioLibraryLoaded => _audioLibraryLoaded;

  @override
  int? get previewingAudioId => _previewingAudioId;

  @override
  bool get uploadingAudio => _isUploadingAudio;

  @override
  Future<void> reloadAudioLibrary() => _loadAudioLibrary();

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

  @override
  Future<void> uploadAudio() => SessionAudioUpload(
    context: context,
    sessionId: widget.sessionId,
    teacherSessions: _teacherSessions,
    isActive: () => mounted,
    setUploading: (uploading) => setState(() => _isUploadingAudio = uploading),
    reload: _loadAudioLibrary,
    title: _uploadTitle,
    description: _uploadDescription,
  ).run();

  @override
  Future<void> previewAudio(int audioId, String title) async {
    if (_previewingAudioId == audioId) {
      await _previewPlayer.stop();
      if (mounted) setState(() => _previewingAudioId = null);
      _speakIfEnabled(SessionText.previewStopped);
      return;
    }
    try {
      await _previewPlayer.stop();
      final url = await ApiService.mediaUrl('/audio/$audioId/stream');
      await _previewPlayer.play(UrlSource(url));
    } on Exception catch (error) {
      debugPrint('[SESSION] Private preview failed: $error');
      if (mounted) setState(() => _previewingAudioId = null);
      _error(SessionText.previewFailed);
      return;
    }
    if (mounted) setState(() => _previewingAudioId = audioId);
    _speakIfEnabled(SessionText.previewing(title));
  }

  @override
  Future<void> selectAudio(
    int audioId,
    String title, {
    required bool play,
  }) async {
    // Tells the server which audio is selected; it broadcasts audio_selected.
    final selected = await ApiService.selectAudio(
      widget.sessionId,
      audioId,
      canSend: () => mounted,
    );
    if (!mounted) return;
    if (!selected.isSuccess) {
      _error(selected.failure!.message);
      return;
    }
    setState(() {
      _currentAudioId = audioId;
      _currentAudioTitle = title;
    });
    if (!play) {
      unawaited(FeedbackCues.play(Cue.ok));
      _speakIfEnabled(SessionText.selected(title));
      return;
    }
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
      unawaited(FeedbackCues.play(Cue.ok));
      _speakIfEnabled(SessionText.playbackAccepted(title));
    } else {
      _error(result.failure!.message);
    }
  }

  // ── LiveSession: teacher tools ─────────────────────────────────────────

  // ── In-class quiz or journey ───────────────────────────────────────────

  String? get _activityTitle => _activity?['title']?.toString();

  /// The class's open quiz or journey changed (or was read on joining).
  void _applyActivity(Object? data, {required bool announce}) {
    final previousTitle = _activityTitle;
    final next =
        data is Map &&
            data['id'] is int &&
            const {'quiz', 'journey'}.contains(data['kind'])
        ? Map<String, dynamic>.from(data)
        : null;
    if (!mounted) return;
    setState(() => _activity = next);
    if (widget.isTeacher) return;
    if (next != null) {
      final key = '${next['kind']}:${next['id']}';
      if (key == _heardActivity) return;
      _heardActivity = key;
      unawaited(FeedbackCues.play(Cue.ok));
      _speakIfEnabled(
        SessionText.activityStartedStudent(
          '${next['kind']}',
          '${next['title']}',
        ),
        // Live: interrupt. On joining: after the class's own arrival speech.
        priority: announce ? SpeechPriority.critical : SpeechPriority.requested,
      );
    } else if (announce && previousTitle != null) {
      _heardActivity = null;
      _speakIfEnabled(SessionText.activityStoppedStudent(previousTitle));
    }
  }

  /// The quiz or journey a student has already been told about.
  String? _heardActivity;

  /// Voice commands "quiz" and "journey"; students start the open one (5).
  /// Teachers: start one, or, while that kind is open, the follow-up menu.
  void _activityKey(String kind) {
    if (!widget.isTeacher) {
      if (_activity != null) unawaited(_startActivity());
      return;
    }
    unawaited(
      _activity?['kind'] == kind
          ? _openActivityMenu(kind)
          : _pickActivity(kind),
    );
  }

  /// Teacher: choose a published quiz or journey and open it for the class.
  /// It replaces whatever was open. Students hear it at once.
  Future<void> _pickActivity(String kind) async {
    if (!widget.isTeacher || _activityBusy) return;
    setState(() => _activityBusy = true);
    try {
      final result = await ApiService.classActivities(widget.sessionId);
      if (!mounted) return;
      if (!result.isSuccess) {
        _error(result.failure!.message);
        return;
      }
      final items = <Map<String, dynamic>>[
        for (final item
            in (result.data![kind == 'quiz' ? 'quizzes' : 'journeys']
                    as List?) ??
                const [])
          if (item is Map) Map<String, dynamic>.from(item),
      ];
      if (items.isEmpty) {
        _speakIfEnabled(SessionText.noneToStart(kind));
        return;
      }
      final chosen = await JourneyPrompts.choose<Map<String, dynamic>>(
        context,
        title: SessionText.pickTitle(kind),
        items: items,
        labelOf: (item) => kind == 'quiz'
            ? SessionText.activityQuizItem(
                '${item['title']}',
                item['questions'] as int? ?? 0,
              )
            : SessionText.activityJourneyItem('${item['title']}'),
      );
      if (chosen == null || !mounted) return;
      final started = await ApiService.startClassActivity(
        widget.sessionId,
        kind: kind,
        id: chosen['id'] as int,
      );
      if (!mounted) return;
      if (!started.isSuccess) {
        _error(started.failure!.message);
        return;
      }
      _applyActivity(started.data?['activity'], announce: false);
      if (_isPlayingSessionAudio) unawaited(_pauseSessionAudio());
      setState(() => _recordingRunning = false);
      unawaited(FeedbackCues.play(Cue.ok));
      _speakIfEnabled(SessionText.activityStartedTeacher('${chosen['title']}'));
    } finally {
      if (mounted) setState(() => _activityBusy = false);
    }
  }

  /// Teacher, while a quiz or journey is open: who in class and who in the
  /// whole class has not finished, remind those in class, start a different
  /// one, or stop offering it.
  Future<void> _openActivityMenu(String kind) async {
    final title = _activityTitle;
    if (!widget.isTeacher || _activityBusy || title == null) return;
    setState(() => _activityBusy = true);
    Map<String, dynamic> left;
    try {
      final result = await ApiService.classActivityLeft(widget.sessionId);
      if (!mounted) return;
      if (!result.isSuccess) {
        _error(result.failure!.message);
        return;
      }
      left = result.data!;
    } finally {
      if (mounted) setState(() => _activityBusy = false);
    }
    List<Map<String, dynamic>> group(String key) => [
      for (final item in (left[key] as List?) ?? const [])
        if (item is Map) Map<String, dynamic>.from(item),
    ];
    final inClass = group('in_class');
    final whole = group('whole_class');
    final choice = await JourneyPrompts.pick(
      context,
      title: title,
      introduction: SessionText.activityCounts(
        left['present'] as int? ?? 0,
        left['started'] as int? ?? 0,
        left['finished'] as int? ?? 0,
      ),
      choices: [
        SessionText.leftInClass(inClass.length),
        SessionText.leftWholeClass(whole.length),
        SessionText.remindLeft,
        SessionText.startDifferent(kind),
        SessionText.activityStopItem(title),
      ],
    );
    if (!mounted || choice == null) return;
    switch (choice) {
      case 0 || 1:
        final people = choice == 0 ? inClass : whole;
        if (people.isEmpty) {
          _speakIfEnabled(SessionText.leftNobody(inClass: choice == 0));
          return;
        }
        final picked = await JourneyPrompts.choose<Map<String, dynamic>>(
          context,
          title: choice == 0
              ? SessionText.leftInClassTitle
              : SessionText.leftWholeClassTitle,
          items: people,
          labelOf: (person) =>
              SessionText.leftPerson(person, whole: choice == 1),
        );
        if (picked != null && mounted) {
          _speakIfEnabled(SessionText.leftPerson(picked, whole: choice == 1));
        }
      case 2:
        final reminded = await ApiService.remindClassActivity(widget.sessionId);
        if (!mounted) return;
        if (!reminded.isSuccess) {
          _error(reminded.failure!.message);
          return;
        }
        _speakIfEnabled(
          SessionText.remindedLeft(reminded.data?['reminded'] as int? ?? 0),
        );
      case 3:
        await _pickActivity(kind);
      case 4:
        final stopped = await ApiService.stopClassActivity(widget.sessionId);
        if (!mounted) return;
        if (!stopped.isSuccess) {
          _error(stopped.failure!.message);
          return;
        }
        _applyActivity(null, announce: false);
        _speakIfEnabled(SessionText.activityStoppedTeacher(title));
    }
  }

  /// Student key 5: straight into the quiz's first question or the
  /// journey's first step, with no list or confirmation in between. The
  /// class keeps running underneath; leaving returns here.
  Future<void> _startActivity() async {
    final activity = _activity;
    if (widget.isTeacher || activity == null || _activityBusy) return;
    final title = '${activity['title']}';
    setState(() => _activityBusy = true);
    try {
      _speakIfEnabled(SessionText.activityOpening(title));
      final Widget screen;
      if (activity['kind'] == 'quiz') {
        final attempt = await ApiService.startClassQuiz(activity['id'] as int);
        if (!mounted) return;
        if (!attempt.isSuccess) {
          _error(attempt.failure!.message);
          return;
        }
        screen = QuizAttemptScreen(
          quizTitle: title,
          initialAttempt: attempt.data!,
          returnWhenFinished: true,
        );
      } else {
        const api = JourneyApi();
        try {
          final snapshot = await api.studentJourney(activity['id'] as int);
          final store = await OfflineJourneyStore.forCurrentUser();
          screen = JourneyPlayerScreen(
            snapshot: snapshot,
            store: store,
            api: api,
            returnWhenFinished: true,
          );
        } catch (error) {
          if (!mounted) return;
          _error(
            error is JourneyApiException && !error.network
                ? error.message
                : SessionText.activityCouldNotOpen(title),
          );
          return;
        }
        if (!mounted) return;
      }
      await Navigator.of(
        context,
      ).push<void>(MaterialPageRoute(builder: (_) => screen));
      if (mounted) _speakIfEnabled(SessionText.backInClass);
    } finally {
      if (mounted) setState(() => _activityBusy = false);
    }
  }

  @override
  Future<void> confirmEndSession() async {
    if (!widget.isTeacher || !mounted) return;
    if (_endingSession) {
      _speakIfEnabled(SessionText.waitingEnd);
      return;
    }
    setState(() => _endingSession = true);
    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (_) => KeypadConfirmationDialog(
          title: SessionText.endTitle,
          message: SessionText.endMessage,
          cancelLabel: SessionText.endCancel,
          confirmLabel: SessionText.endConfirm,
          cancelKey: 0,
          confirmKey: 1,
        ),
      );
      if (confirmed != true || !mounted) return;
      final result = await _sse.send({'type': 'end_session'});
      if (!mounted) return;
      if (result.isSuccess) {
        // The server ended the class; leave now rather than waiting for the
        // session_ended event, which a dropped connection may never deliver.
        await _returnToDashboard(reason: SessionText.endingForEveryone);
      } else {
        _error('${SessionText.endNotConfirmed} ${result.failure!.message}');
      }
    } finally {
      if (mounted) setState(() => _endingSession = false);
    }
  }

  // ── leaving ────────────────────────────────────────────────────────────

  Future<void> _returnToDashboard({String? reason}) async {
    if (_isReturningToDashboard || !mounted) return;
    _isReturningToDashboard = true;
    // Left on purpose or the class ended: do not bring this phone back.
    unawaited(ClassEntry.forget());
    unawaited(FeedbackCues.play(Cue.leave));
    await _sessionAudioPlayer.stop();
    await _previewPlayer.stop();
    await TtsService.stop();
    if (!mounted) return;
    // Spoken by the dashboard as it opens; said now, the page change would
    // cut it off and the student would not learn why the class closed.
    if (reason != null) MessageCenter.carryToNextScreen(reason);
    Navigator.of(context).pushNamedAndRemoveUntil(
      widget.isTeacher ? '/teacher_dashboard' : '/student_dashboard',
      (route) => false,
    );
  }

  Future<void> _leaveSession() async {
    if (!mounted || _leaveConfirmationOpen || _isReturningToDashboard) return;
    _leaveConfirmationOpen = true;
    try {
      final confirmed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => KeypadConfirmationDialog(
          title: SessionText.leaveTitle,
          message: widget.isTeacher
              ? SessionText.teacherLeaveMessage
              : SessionText.leaveMessage,
          cancelLabel: SessionText.stay,
          confirmLabel: SessionText.leave,
          cancelKey: 0,
          confirmKey: 1,
        ),
      );
      if (confirmed != true || !mounted) return;
      _microphone.applyRemoteMute(true);
      // One confirmation is enough: leave even if the server is slow to
      // answer. Closing the class connection also tells the server.
      await _sse
          .send({'type': 'leave_session'})
          .timeout(
            const Duration(seconds: 3),
            onTimeout: () => ApiResult.failure(
              ApiFailure(
                kind: ApiFailureKind.network,
                message: SessionText.youLeft,
              ),
            ),
          );
      if (!mounted) return;
      await _returnToDashboard(reason: SessionText.youLeft);
    } finally {
      _leaveConfirmationOpen = false;
    }
  }

  // ── navigation to sub-screens ──────────────────────────────────────────

  void _push(Widget screen) => unawaited(
    Navigator.of(context).push<void>(MaterialPageRoute(builder: (_) => screen)),
  );

  void _openChat() => _push(SessionChatScreen(session: this));

  void _openMore() =>
      _push(SessionMoreScreen(session: this, choices: _moreChoices));

  void _openParticipants() {
    if (widget.isTeacher) _push(ClassRosterScreen(session: this));
  }

  void _openMembers() => _push(ClassMembersScreen(session: this));

  // ── helpers ────────────────────────────────────────────────────────────

  Future<void> _speakIfEnabled(
    String text, {
    SpeechPriority priority = SpeechPriority.requested,
    String? group,
  }) async {
    if (TtsService.isEnabled && mounted) {
      await TtsService.speak(text, priority: priority, group: group);
    }
  }

  void _error(String message) {
    if (mounted) MessageCenter.error(message);
  }

  bool get _canRetryConnection =>
      _sse.state == SessionConnectionState.interrupted ||
      _sse.state == SessionConnectionState.reconnecting;

  // ── dispose ────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _presenceTimer?.cancel();
    _startSummaryTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    routeObserver.unsubscribe(this);
    TtsService.speaking.removeListener(_speechActivityChanged);
    _voice.removeListener(_voiceChanged);
    _voice.dispose();
    _microphone.dispose();
    PrivateNoteRecorder.liveSessions--;
    TtsService.unregisterLiveSession(this);
    TtsService.unregisterRecordedPlayback(_previewPlayer);
    _uploadTitle.dispose();
    _uploadDescription.dispose();
    _voiceCommandsEnabled = false;
    _sse.close();
    _localStream?.dispose();
    _peers.dispose();
    _sessionAudioPlayer.dispose();
    _previewPlayer.stop();
    _previewPlayer.dispose();
    for (final node in [
      _muteFocus,
      _handFocus,
      _recordingFocus,
      _participantsFocus,
      _muteAllFocus,
      _moreFocus,
      _activityFocus,
      _endClassFocus,
      _journeyFocus,
      _voiceFocus,
      _retryFocus,
      _leaveFocus,
    ]) {
      node.dispose();
    }
    _changes.dispose();
    super.dispose();
  }

  // ── UI ─────────────────────────────────────────────────────────────────

  bool get _recordingActive => _isPlayingSessionAudio;

  /// Every control on the main screen, in focus order. Keys, focus labels
  /// and buttons all come from this one list, so the spoken help, D-pad
  /// order and visible buttons always match the account's role. Only what
  /// is needed every minute is here; More opens the rest. 0 leaves; the
  /// teacher ends the class for everyone with 6.
  List<_SessionOption> get _options => [
    _SessionOption(
      key: 1,
      node: _muteFocus,
      icon: _muted ? Icons.mic_off : Icons.mic,
      button: SessionText.muteButton(_muted, _mutePending),
      label: SessionText.muteLabel(_muted, _mutePending),
      onActivate: _toggleMute,
      isEnabled: () => !_mutePending,
      iconColor: _muted ? UIUtils.errorColor : UIUtils.successColor,
    ),
    ...widget.isTeacher ? _teacherOptions : _studentOptions,
    if (_voiceCommandsEnabled)
      _SessionOption(
        node: _voiceFocus,
        icon: _voice.busy
            ? Icons.mic_off_outlined
            : Icons.keyboard_voice_outlined,
        button: _voice.busy
            ? SessionText.voiceStopButton
            : SessionText.voiceStartButton,
        label: _voice.busy
            ? '${SessionText.voiceStopLabel}. ${_voice.status}'
            : SessionText.voiceStartLabel,
        onActivate: _toggleVoiceListening,
      ),
    if (_canRetryConnection)
      _SessionOption(
        node: _retryFocus,
        icon: Icons.refresh,
        button: SessionText.retryButton,
        label: SessionText.retryLabel,
        onActivate: _sse.reconnect,
        isEnabled: () => _canRetryConnection,
        iconColor: UIUtils.errorColor,
      ),
    _SessionOption(
      key: widget.isTeacher ? 5 : 4,
      node: _moreFocus,
      icon: Icons.more_horiz,
      button: SessionText.moreButton(widget.isTeacher ? 5 : 4),
      label: SessionText.moreLabel,
      onActivate: _openMore,
    ),
    if (widget.isTeacher)
      _SessionOption(
        key: 6,
        node: _endClassFocus,
        icon: Icons.stop_circle_outlined,
        button: SessionText.endClassButton,
        label: SessionText.endClassLabel,
        onActivate: () => unawaited(confirmEndSession()),
        iconColor: UIUtils.errorColor,
      ),
    ...widget.isTeacher ? _teacherLastOptions : _studentLastOptions,
    _SessionOption(
      key: 0,
      node: _leaveFocus,
      icon: Icons.call_end,
      button: SessionText.leaveButton,
      label: SessionText.leaveLabel,
      onActivate: _leaveSession,
      iconColor: UIUtils.errorColor,
    ),
  ];

  /// Students: their microphone, hand and what is playing; More (4) has
  /// chat and who is here. The teacher's quiz or journey (5) is listed last,
  /// only while one is open.
  List<_SessionOption> get _studentOptions => [
    _SessionOption(
      key: 2,
      node: _handFocus,
      icon: _handRaised ? Icons.pan_tool : Icons.pan_tool_outlined,
      button: SessionText.handButton(_handRaised, _handPending),
      label: SessionText.handLabel(_handRaised, _handPending),
      onActivate: _toggleHandRaise,
      // While waiting for the connection, 2 cancels the request.
      isEnabled: () => !_handPending || _handQueued,
      selected: _handRaised,
    ),
    _SessionOption(
      key: 3,
      node: _recordingFocus,
      icon: Icons.graphic_eq,
      button: SessionText.whatIsPlayingButton,
      label: SessionText.recordingLabel(
        teacher: false,
        title: recordingTitle,
        playing: _recordingActive,
      ),
      onActivate: _speakRecordingStatus,
    ),
  ];

  /// Teachers: mute all (2), the class list (3) and Start (4). More (5) has
  /// adding time and chat; 6 ends the class. A raised hand is announced as
  /// it happens, so there is no hand queue to manage.
  List<_SessionOption> get _teacherOptions => [
    _SessionOption(
      key: 2,
      node: _muteAllFocus,
      icon: Icons.volume_off_outlined,
      button: SessionText.muteAllButton,
      label: SessionText.muteAllLabel,
      onActivate: () => unawaited(muteAllStudents()),
      isEnabled: () => !_muteAllPending,
    ),
    _SessionOption(
      key: 3,
      node: _participantsFocus,
      icon: Icons.people_outline,
      button: SessionText.classListButton,
      label: SessionText.classListLabel(_participants.length),
      onActivate: _openParticipants,
    ),
    _SessionOption(
      key: 4,
      node: _activityFocus,
      icon: Icons.play_circle_outline,
      button: SessionText.startButton,
      label: SessionText.startLabel,
      onActivate: () => unawaited(_openStart()),
      isEnabled: () => !_activityBusy,
    ),
  ];

  /// Listed after More and End so the numbers run in order.
  List<_SessionOption> get _teacherLastOptions => [
    if (_running != null)
      _SessionOption(
        key: 7,
        node: _journeyFocus,
        icon: _running == 'recording'
            ? (_recordingActive ? Icons.pause : Icons.play_arrow)
            : Icons.insights_outlined,
        button: SessionText.statusKeyButton(_runningTitle),
        label: SessionText.statusKeyLabel(_runningTitle),
        onActivate: () => unawaited(_openRunningStatus()),
        isEnabled: () => !_activityBusy,
        selected: true,
      ),
  ];

  List<_SessionOption> get _studentLastOptions => [
    if (_activity != null)
      _SessionOption(
        key: 5,
        node: _activityFocus,
        icon: _activity!['kind'] == 'quiz'
            ? Icons.quiz_outlined
            : Icons.route_outlined,
        button: SessionText.activityStartButton(
          '${_activity!['kind']}',
          _activityTitle!,
        ),
        label: SessionText.activityStartLabel(
          '${_activity!['kind']}',
          _activityTitle!,
        ),
        onActivate: () => unawaited(_startActivity()),
        isEnabled: () => !_activityBusy,
        selected: true,
      ),
  ];

  // ── Start (4) and Status (7) ──────────────────────────────────────────
  // One thing runs at a time: a quiz, a journey or a recording. Starting
  // one stops the others.

  /// Set when the teacher starts a recording for the class; cleared when a
  /// quiz or journey is started instead.
  bool _recordingRunning = false;

  /// 'quiz', 'journey', 'recording' or null.
  String? get _running => _activity != null
      ? '${_activity!['kind']}'
      : _recordingRunning && _currentAudioId != null
      ? 'recording'
      : null;

  String get _runningTitle => _activity != null
      ? _activityTitle!
      : recordingTitle ?? SessionText.nowPlayingTitle;

  /// Teacher key 4: choose a quiz, a journey or a recording.
  Future<void> _openStart() async {
    if (!widget.isTeacher || _activityBusy) return;
    final choice = await JourneyPrompts.pick(
      context,
      title: SessionText.startTitle,
      choices: [
        SessionText.startQuiz,
        SessionText.startJourney,
        SessionText.startRecording,
      ],
    );
    if (!mounted || choice == null) return;
    switch (choice) {
      case 0 || 1:
        await _pickActivity(choice == 0 ? 'quiz' : 'journey');
      case 2:
        await _startRecording();
    }
  }

  /// Opens the recording player. Its keys are read first; the selected
  /// recording then starts for the class. A quiz or journey that was open
  /// is closed, since one thing runs at a time.
  Future<void> _startRecording() async {
    if (_activity != null) {
      final stopped = await ApiService.stopClassActivity(widget.sessionId);
      if (!mounted) return;
      if (stopped.isSuccess) _applyActivity(null, announce: false);
    }
    setState(() => _recordingRunning = true);
    if (_currentAudioId == null) {
      MessageCenter.show(SessionText.openingPlayerToChoose, cue: false);
    }
    _push(SessionRecordingsScreen(session: this, startWhenReady: true));
  }

  /// Teacher key 7: the status of what is running.
  Future<void> _openRunningStatus() async {
    final running = _running;
    if (running == null) return;
    if (running == 'recording') {
      _push(SessionRecordingsScreen(session: this));
    } else {
      await _openActivityMenu(running);
    }
  }

  /// More (teacher 5, student 4): everything used less than every minute.
  List<JourneyChoice> _moreChoices() => [
    if (widget.isTeacher)
      JourneyChoice(
        SessionText.addTime,
        () => unawaited(extendClass()),
        enabled: canExtend,
        unavailableReason: SessionText.cannotAddTime,
      ),
    JourneyChoice(SessionText.chatLabel(_messages.length), _openChat),
    if (!widget.isTeacher)
      JourneyChoice(SessionText.moreWhoIsHere, _openMembers),
  ];

  Map<int, VoidCallback> get _keyActions => {
    for (final option in _options)
      if (option.key != null) option.key!: option.onActivate,
  };

  List<KeypadFocusTarget> get _focusTargets => [
    for (final option in _options)
      KeypadFocusTarget(
        node: option.node,
        label: option.key == null
            ? option.label
            : '${option.key}. ${option.label}',
        onActivate: option.onActivate,
        isEnabled: option.isEnabled,
      ),
  ];

  @override
  Widget build(BuildContext context) => KeypadInstructionWrapper(
    interactionPolicy: KeypadInteractionPolicy.numbered,
    // The joining announcement is spoken once the class is ready.
    autoPlay: false,
    screenName: SessionText.screenName(
      teacher: widget.isTeacher,
      title: widget.sessionTitle,
      className: widget.className,
      subjectName: widget.subjectName,
    ),
    // Returning from chat or a list: state in one sentence, not every key.
    brief: _stateSummary(),
    stateSummary: _stateSummary,
    labels: _keyLabels,
    actions: _keyActions,
    navigationController: _keypadController,
    focusTargets: _focusTargets,
    child: PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _leaveSession();
      },
      child: _buildScaffold(context),
    ),
  );

  TextStyle _textStyle({double size = 14, Color? color, FontWeight? weight}) =>
      TextStyle(
        color: color ?? UIUtils.textColor,
        fontSize: UIUtils.fontSize(context, size),
        fontWeight: weight,
      );

  Widget _buildScaffold(BuildContext context) {
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
                    SessionText.joining,
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

    final subtitle = [
      widget.className,
      widget.subjectName,
    ].whereType<String>().join(' · ');
    return Scaffold(
      backgroundColor: UIUtils.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: UIUtils.paddingAll(context, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                header: true,
                child: Text(
                  widget.isTeacher
                      ? Speech.t.sessionTitleTeacher(widget.sessionTitle)
                      : widget.sessionTitle,
                  style: _textStyle(size: 18, weight: FontWeight.bold),
                ),
              ),
              if (subtitle.isNotEmpty)
                Text(subtitle, style: _textStyle(color: UIUtils.subtextColor)),
              _buildStatusPanel(),
              for (final option in _options)
                _button(
                  node: option.node,
                  icon: option.icon,
                  text: option.button,
                  semanticLabel: option.label,
                  onPressed: (option.isEnabled?.call() ?? true)
                      ? option.onActivate
                      : null,
                  iconColor: option.iconColor,
                  selected: option.selected,
                ),
              ExcludeSemantics(
                child: Text(
                  SessionText.keyLine,
                  style: _textStyle(color: UIUtils.subtextColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Read-only summary; key 3 and star speak it.
  Widget _buildStatusPanel() {
    final problem = const {
      SessionConnectionState.interrupted,
      SessionConnectionState.reconnecting,
      SessionConnectionState.authenticationExpired,
      SessionConnectionState.unavailable,
      SessionConnectionState.closed,
    }.contains(_sse.state);
    final summary = _stateSummary();
    final showMessage = _sse.state != SessionConnectionState.connected;
    return Semantics(
      container: true,
      liveRegion: true,
      label: showMessage ? '$summary $_connectionMessage' : summary,
      child: ExcludeSemantics(
        child: Container(
          margin: EdgeInsets.symmetric(vertical: UIUtils.spacing(context, 4)),
          padding: UIUtils.paddingSymmetric(
            context,
            horizontal: 8,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: UIUtils.cardColor,
            border: Border.all(
              color: problem ? UIUtils.errorColor : UIUtils.cardBorderColor,
              width: problem ? 3 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(summary, style: _textStyle(weight: FontWeight.bold)),
              if (showMessage)
                Text(
                  _connectionMessage,
                  style: _textStyle(
                    color: problem ? UIUtils.errorColor : UIUtils.subtextColor,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Full-width button whose visible text carries the key while its
  /// accessible name describes the action.
  Widget _button({
    required FocusNode node,
    required IconData icon,
    required String text,
    required String semanticLabel,
    required VoidCallback? onPressed,
    Color? iconColor,
    bool selected = false,
  }) {
    final foreground = selected ? UIUtils.onAccentColor : UIUtils.textColor;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: UIUtils.spacing(context, 2)),
      child: OutlinedButton.icon(
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
          alignment: Alignment.centerLeft,
          padding: UIUtils.paddingSymmetric(
            context,
            horizontal: 8,
            vertical: 6,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}

/// One control on the class main screen: its key (if any), focus node,
/// visible button and spoken label.
class _SessionOption {
  const _SessionOption({
    this.key,
    required this.node,
    required this.icon,
    required this.button,
    required this.label,
    required this.onActivate,
    this.isEnabled,
    this.iconColor,
    this.selected = false,
  });

  final int? key;
  final FocusNode node;
  final IconData icon;
  final String button;
  final String label;
  final VoidCallback onActivate;
  final bool Function()? isEnabled;
  final Color? iconColor;
  final bool selected;
}
