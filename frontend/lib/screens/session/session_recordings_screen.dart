import 'dart:async';

import 'package:flutter/material.dart';

import '../../announcers/session_text.dart';
import '../../l10n/speech.dart';
import '../../services/tts_service.dart';
import '../../utils/keypad_actions.dart';
import '../../utils/ui_utils.dart';
import '../../widgets/journey_prompts.dart';
import '../../widgets/key_instruction_wrapper.dart';
import 'live_session.dart';

/// Teacher class recordings: choose, upload, and control the recording that
/// plays for the whole class. Player keys match every other audio screen:
/// 4 back, 5 play or pause, 6 forward, 7 slower, 9 faster. The position
/// control also moves with D-pad left and right.
class SessionRecordingsScreen extends StatefulWidget {
  const SessionRecordingsScreen({
    super.key,
    required this.session,
    this.startWhenReady = false,
  });

  final LiveSession session;

  /// Starts the selected recording for the class once the screen's keys
  /// have been read, so the teacher knows the controls before it plays.
  final bool startWhenReady;

  @override
  State<SessionRecordingsScreen> createState() =>
      _SessionRecordingsScreenState();
}

class _SessionRecordingsScreenState extends State<SessionRecordingsScreen> {
  final _status = FocusNode(debugLabel: 'recordings-status');
  final _position = FocusNode(debugLabel: 'recordings-position');
  final _play = FocusNode(debugLabel: 'recordings-play');
  final _slower = FocusNode(debugLabel: 'recordings-slower');
  final _faster = FocusNode(debugLabel: 'recordings-faster');
  final _choose = FocusNode(debugLabel: 'recordings-choose');
  final _upload = FocusNode(debugLabel: 'recordings-upload');
  final _back = FocusNode(debugLabel: 'recordings-back');

  LiveSession get _session => widget.session;
  VoidCallback? _speechListener;
  bool _teacherActed = false;
  Timer? _startTimer;

  @override
  void initState() {
    super.initState();
    if (widget.startWhenReady) {
      // The keys are spoken shortly after opening; start when they finish.
      _startTimer = Timer(const Duration(milliseconds: 900), _startAfterSpeech);
    }
  }

  void _startAfterSpeech() {
    if (!mounted) return;
    void start() {
      final listener = _speechListener;
      if (listener != null) TtsService.speaking.removeListener(listener);
      _speechListener = null;
      if (mounted &&
          !_teacherActed &&
          _session.recordingId != null &&
          !_session.recordingPlaying) {
        _session.toggleRecording();
      }
    }

    if (!TtsService.speaking.value) {
      start();
      return;
    }
    void listener() {
      if (!TtsService.speaking.value) start();
    }

    _speechListener = listener;
    TtsService.speaking.addListener(listener);
  }

  @override
  void dispose() {
    _startTimer?.cancel();
    final listener = _speechListener;
    if (listener != null) TtsService.speaking.removeListener(listener);
    for (final node in [
      _status,
      _position,
      _play,
      _slower,
      _faster,
      _choose,
      _upload,
      _back,
    ]) {
      node.dispose();
    }
    super.dispose();
  }

  String _statusText() => SessionText.recordingStatus(
    title: _session.recordingTitle,
    playing: _session.recordingPlaying,
    position: _session.recordingPosition,
    duration: _session.recordingDuration,
    speedValue: _session.recordingSpeed,
  );

  void _speak(String text) => unawaited(TtsService.speak(text));

  void _seek(double seconds) {
    if (_session.recordingId == null) {
      _speak(SessionText.noRecording);
      return;
    }
    unawaited(_session.seekRecordingBy(seconds));
  }

  void _speed(double delta) {
    if (_session.recordingId == null) {
      _speak(SessionText.noRecording);
      return;
    }
    unawaited(_session.changeRecordingSpeed(delta));
  }

  Future<void> _chooseRecording() async {
    if (!_session.audioLibraryLoaded) {
      _speak(SessionText.libraryLoading);
      unawaited(_session.reloadAudioLibrary());
      return;
    }
    final files = _session.audioFiles
        .where((audio) => (audio['audio_id'] ?? audio['id']) is int)
        .toList();
    if (files.isEmpty) {
      _speak(SessionText.libraryEmpty);
      return;
    }
    String label(Map<String, dynamic> audio) {
      final id = (audio['audio_id'] ?? audio['id']) as int;
      return SessionText.fileLabel(
        audio,
        active: id == _session.recordingId,
        previewing: id == _session.previewingAudioId,
      );
    }

    final audio = await JourneyPrompts.choose<Map<String, dynamic>>(
      context,
      title: SessionText.recordingsTitle,
      items: files,
      labelOf: label,
    );
    if (audio == null || !mounted) return;
    final id = (audio['audio_id'] ?? audio['id']) as int;
    final title = audio['title'] as String? ?? SessionText.untitled;
    final previewing = _session.previewingAudioId == id;
    final choice = await JourneyPrompts.pick(
      context,
      title: title,
      introduction: audio['description'] as String?,
      choices: [
        SessionText.playForClass,
        SessionText.selectOnly,
        previewing ? SessionText.stopPreview : SessionText.previewPrivately,
      ],
    );
    if (!mounted) return;
    switch (choice) {
      case 0:
        await _session.selectAudio(id, title, play: true);
      case 1:
        await _session.selectAudio(id, title, play: false);
      case 2:
        await _session.previewAudio(id, title);
    }
  }

  void _uploadRecording() {
    if (_session.uploadingAudio) {
      _speak(SessionText.uploadInProgress);
      return;
    }
    unawaited(_session.uploadAudio());
  }

  TextStyle _style({double size = 14, FontWeight? weight}) => TextStyle(
    color: UIUtils.textColor,
    fontSize: UIUtils.fontSize(context, size),
    fontWeight: weight,
  );

  Widget _button(FocusNode node, String text, VoidCallback? onPressed) =>
      Padding(
        padding: const EdgeInsets.only(top: 6),
        child: OutlinedButton(
          focusNode: node,
          onPressed: onPressed,
          child: Text(text, style: _style(weight: FontWeight.w600)),
        ),
      );

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _session.changes,
    builder: (context, _) {
      final hasRecording = _session.recordingId != null;
      final playing = _session.recordingPlaying;
      final duration = _session.recordingDuration;
      final progress = duration != null && duration > 0
          ? (_session.recordingPosition / duration).clamp(0.0, 1.0)
          : 0.0;
      final controls = <int, VoidCallback>{
        1: () => unawaited(_chooseRecording()),
        2: _uploadRecording,
        3: () => _speak(_statusText()),
        playerRewindKey: () => _seek(-10),
        playerPlayPauseKey: _session.toggleRecording,
        playerForwardKey: () => _seek(10),
        playerSlowerKey: () => _speed(-0.25),
        playerFasterKey: () => _speed(0.25),
        0: () => Navigator.of(context).maybePop(),
      };
      // Any key means the teacher has taken control: no automatic start.
      final actions = {
        for (final entry in controls.entries)
          entry.key: () {
            _teacherActed = true;
            entry.value();
          },
      };
      return KeypadInstructionWrapper(
        interactionPolicy: KeypadInteractionPolicy.numbered,
        screenName: SessionText.recordingsTitle,
        stateSummary: _statusText,
        labels: {
          1: SessionText.chooseRecording,
          2: SessionText.uploadRecording,
          3: SessionText.hearRecording,
          playerRewindKey: SessionText.back10,
          playerPlayPauseKey: SessionText.playPauseClass,
          playerForwardKey: SessionText.forward10,
          playerSlowerKey: SessionText.slower,
          playerFasterKey: SessionText.faster,
        },
        actions: actions,
        focusTargets: [
          KeypadFocusTarget(
            node: _status,
            label: _statusText(),
            onActivate: () => _speak(_statusText()),
          ),
          if (hasRecording) ...[
            KeypadFocusTarget(
              node: _position,
              label: SessionText.positionLabel(
                _session.recordingPosition,
                duration,
              ),
              onDecrease: () => _seek(-10),
              onIncrease: () => _seek(10),
              onActivate: () => _speak(
                SessionText.position(_session.recordingPosition, duration),
              ),
            ),
            KeypadFocusTarget(
              node: _play,
              label:
                  '5. ${SessionText.recordingLabel(teacher: true, title: _session.recordingTitle, playing: playing)}',
              onActivate: _session.toggleRecording,
            ),
            KeypadFocusTarget(
              node: _slower,
              label: '7. ${SessionText.slower}',
              onActivate: () => _speed(-0.25),
              isEnabled: () => _session.recordingSpeed > 0.5,
            ),
            KeypadFocusTarget(
              node: _faster,
              label: '9. ${SessionText.faster}',
              onActivate: () => _speed(0.25),
              isEnabled: () => _session.recordingSpeed < 2.0,
            ),
          ],
          KeypadFocusTarget(
            node: _choose,
            label: '1. ${SessionText.chooseRecording}',
            onActivate: () => unawaited(_chooseRecording()),
          ),
          KeypadFocusTarget(
            node: _upload,
            label: _session.uploadingAudio
                ? SessionText.uploadInProgress
                : '2. ${SessionText.uploadRecording}',
            onActivate: _uploadRecording,
          ),
          KeypadFocusTarget(
            node: _back,
            label: '0. ${SessionText.backToClass}',
            onActivate: () => Navigator.of(context).maybePop(),
          ),
        ],
        child: Scaffold(
          backgroundColor: UIUtils.backgroundColor,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      SessionText.recordingsTitle,
                      style: _style(size: 18, weight: FontWeight.bold),
                    ),
                  ),
                  Focus(
                    focusNode: _status,
                    child: Semantics(
                      liveRegion: true,
                      child: Text(_statusText(), style: _style()),
                    ),
                  ),
                  if (hasRecording)
                    Focus(
                      focusNode: _position,
                      child: Semantics(
                        label: SessionText.positionLabel(
                          _session.recordingPosition,
                          duration,
                        ),
                        child: ExcludeSemantics(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 6,
                              color: UIUtils.accentColor,
                              backgroundColor: UIUtils.cardBorderColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (hasRecording) ...[
                    _button(
                      _play,
                      playing
                          ? Speech.t.libraryKey5PauseForClass
                          : Speech.t.libraryKey5PlayForClass,
                      _session.toggleRecording,
                    ),
                    Text(Speech.t.libraryRecordingsSeekKeysHint),
                    _button(
                      _slower,
                      '7: ${SessionText.slower}',
                      _session.recordingSpeed > 0.5
                          ? () => _speed(-0.25)
                          : null,
                    ),
                    _button(
                      _faster,
                      '9: ${SessionText.faster}',
                      _session.recordingSpeed < 2.0 ? () => _speed(0.25) : null,
                    ),
                  ],
                  _button(
                    _choose,
                    Speech.t.libraryKey1ChooseRecording,
                    () => unawaited(_chooseRecording()),
                  ),
                  _button(
                    _upload,
                    _session.uploadingAudio
                        ? Speech.t.libraryUploadingButton
                        : Speech.t.libraryKey2Upload,
                    _session.uploadingAudio ? null : _uploadRecording,
                  ),
                  _button(
                    _back,
                    '0: ${SessionText.backToClass}',
                    () => Navigator.of(context).maybePop(),
                  ),
                  Text(Speech.t.libraryRecordingsFooterKeysHint),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
