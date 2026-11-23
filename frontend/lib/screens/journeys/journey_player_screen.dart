import 'dart:async';

import 'package:flutter/material.dart';

import '../../l10n/speech.dart';
import '../../services/api_service.dart';
import '../../services/feedback_cues.dart';
import '../../services/message_center.dart';
import '../../announcers/journey_text.dart';
import '../../services/journey_api.dart';
import '../../services/journey_audio.dart';
import '../../services/journey_engine.dart';
import '../../services/journey_models.dart';
import '../../services/offline_journey_store.dart';
import '../../services/offline_lesson_store.dart';
import '../../services/quiz_speech_speed.dart';
import '../../services/tts_service.dart';
import '../../utils/keypad_actions.dart';
import '../../utils/ui_utils.dart';
import '../../widgets/journey_prompts.dart';
import '../../widgets/key_instruction_wrapper.dart';

enum _Mode { content, answer, finished }

/// Plays one learning journey, one step at a time.
///
/// Content steps: 1 where am I, 2 next step, 3 repeat step, 4/6 back or
/// forward 10 seconds, 5 play or pause, 7/9 slower or faster, 8 previous
/// recording or narration. Question and poll steps: 1-4 choose, 5 submit,
/// 6 repeat question, 7/9 quiz speech speed, 8 where am I. 0 always leaves
/// (with confirmation; the place is saved).
class JourneyPlayerScreen extends StatefulWidget {
  const JourneyPlayerScreen({
    super.key,
    required this.snapshot,
    this.preview = false,
    this.store,
    this.api = const JourneyApi(),
    this.audio,
    this.offline = false,
    this.streamUrl,
  });

  final JourneySnapshot snapshot;

  /// Teacher preview: nothing is saved or sent.
  final bool preview;
  final OfflineJourneyStore? store;
  final JourneyApi api;
  final JourneyAudio? audio;

  /// Played from the downloaded copy without internet.
  final bool offline;
  final Future<String> Function(int audioId)? streamUrl;

  @override
  State<JourneyPlayerScreen> createState() => _JourneyPlayerScreenState();
}

class _JourneyPlayerScreenState extends State<JourneyPlayerScreen>
    with WidgetsBindingObserver {
  late JourneyEngine _engine = JourneyEngine(widget.snapshot);
  late final JourneyAudio _audio = widget.audio ?? AudioPlayersJourneyAudio();
  late final QuizSpeechSpeed _quizSpeed = QuizSpeechSpeed(this);
  final _nodes = <String, FocusNode>{};
  StreamSubscription<void>? _completion;
  int? _selected;
  String? _status;
  String? _issue;
  bool _ready = false;
  bool _audioFailed = false;
  bool _leaving = false;
  double _rate = 1.0;
  int _presentation = 0;

  FocusNode _node(String id) =>
      _nodes.putIfAbsent(id, () => FocusNode(debugLabel: 'journey-player-$id'));

  _Mode get _mode {
    final step = _engine.current;
    if (step == null) return _Mode.finished;
    return step.isAnswer ? _Mode.answer : _Mode.content;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _completion = _audio.completed.listen((_) => unawaited(_audioDone()));
    TtsService.registerRecordedPlayback(
      this,
      isPlaying: () => mounted && _audio.playing,
      item: () => _audio.item,
      pause: _audio.pause,
      resume: _audio.resume,
      canResume: () => mounted && (ModalRoute.of(context)?.isCurrent ?? true),
    );
    unawaited(_start());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      if (_audio.playing) unawaited(_audio.pause());
      unawaited(_save());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    TtsService.unregisterRecordedPlayback(this);
    unawaited(_completion?.cancel());
    unawaited(_quizSpeed.stop());
    if (widget.audio == null) unawaited(_audio.dispose());
    for (final node in _nodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  Future<void> _start() async {
    final store = widget.store;
    var resumed = false;
    if (!widget.preview && store != null) {
      try {
        final saved = await store.loadProgress(widget.snapshot.journeyId);
        if (saved != null) {
          final engine = JourneyEngine.restore(widget.snapshot, saved);
          if (!engine.finished) {
            _engine = engine;
            resumed = true;
          }
        }
      } on FormatException {
        // Progress from an older version of this journey starts fresh.
      } on OfflineJourneyException catch (error) {
        _issue = error.message;
      }
    }
    if (!mounted) return;
    setState(() => _ready = true);
    final intro = JourneyAnnouncer.start(
      widget.snapshot,
      preview: widget.preview,
      resumed: resumed,
    );
    await _present(prefix: intro);
  }

  Future<void> _save() async {
    final store = widget.store;
    if (widget.preview || store == null) return;
    try {
      await store.saveProgress(_engine, offline: widget.offline);
    } on OfflineJourneyException catch (error) {
      _fail(JourneyAnnouncer.notSaved(error.message));
    }
  }

  void _say(String text) => unawaited(TtsService.speak(text));

  bool _keysSpoken = false;

  /// Every key of the current step, once, when the journey opens.
  String _firstKeys() {
    if (_keysSpoken) return '';
    _keysSpoken = true;
    return ' ${buildTtsInstructions({for (final entry in _keys().entries) entry.key: entry.value.$1, 0: Speech.t.journeyLeaveJourney}, includeRepeatHint: false)}';
  }

  void _fail(String message) {
    if (!mounted) return;
    setState(() => _issue = message);
    MessageCenter.error(message);
  }

  Future<void> _present({String prefix = ''}) async {
    final presentation = ++_presentation;
    final step = _engine.current;
    setState(() {
      _selected = null;
      _issue = null;
      _audioFailed = false;
    });
    if (step == null) {
      await _finish(prefix);
      return;
    }
    final lead = prefix.isEmpty ? '' : '$prefix ';
    final where = _engine.replaying ? JourneyAnnouncer.listeningAgain : '';
    if (step.isAnswer) {
      await _audio.stop();
      await _quizSpeed.start();
      if (presentation != _presentation || !mounted) return;
      setState(() => _status = step.text);
      _say('$lead${JourneyAnnouncer.question(_engine)}${_firstKeys()}');
      return;
    }
    await _quizSpeed.stop();
    if (step.kind == JourneyStepKind.narration) {
      await _audio.stop();
      if (presentation != _presentation || !mounted) return;
      setState(() => _status = step.text);
      _say(
        '$lead$where${JourneyAnnouncer.narration(step.text)}${_firstKeys()}',
      );
      return;
    }
    setState(() => _status = JourneyAnnouncer.recordingStatus(step));
    try {
      await _play(step);
      if (presentation != _presentation || !mounted) return;
      _say('$lead$where${JourneyAnnouncer.content(step)}${_firstKeys()}');
    } on Exception catch (error) {
      debugPrint('[JOURNEY] Recording failed (${error.runtimeType}).');
      if (presentation != _presentation || !mounted) return;
      setState(() => _audioFailed = true);
      final reason = error is OfflineJourneyException
          ? error.message
          : error is OfflineLessonException
          ? error.message
          : JourneyAnnouncer.recordingFailed;
      _fail('$lead$reason ${JourneyAnnouncer.recordingRetry}');
    }
  }

  Future<void> _play(JourneyStep step) async {
    final id = step.audioId!;
    final store = widget.store;
    if (store != null) {
      final complete = await store.media.completeIds();
      if (complete.contains(id)) {
        final path = await store.media.localPath(id);
        await _audio.setRate(_rate);
        await _audio.playFile(path, mimeType: step.mimeType);
        return;
      }
    }
    if (widget.offline) {
      throw OfflineJourneyException(JourneyAnnouncer.notDownloaded);
    }
    final resolve =
        widget.streamUrl ?? (id) => ApiService.mediaUrl('/audio/$id/stream');
    final url = await resolve(id);
    await _audio.setRate(_rate);
    await _audio.playUrl(url);
  }

  Future<void> _audioDone() async {
    if (!mounted || _engine.current?.kind != JourneyStepKind.audio) return;
    _engine.next();
    await _save();
    if (!mounted) return;
    await _present(prefix: JourneyAnnouncer.recordingFinished);
  }

  Future<void> _next() async {
    final step = _engine.current;
    if (step == null) return;
    if (step.isAnswer) {
      _say(JourneyAnnouncer.answerFirst(step.options.length));
      return;
    }
    _engine.next();
    await _save();
    if (mounted) await _present();
  }

  Future<void> _previous() async {
    if (!_engine.previous()) {
      _say(JourneyAnnouncer.noEarlierContent);
      return;
    }
    await _save();
    if (mounted) await _present(prefix: JourneyAnnouncer.goingBack);
  }

  void _where() => _say(JourneyAnnouncer.where(_engine));

  void _choose(int option) {
    final step = _engine.current;
    if (step == null || !step.isAnswer) return;
    if (option >= step.options.length) {
      _say(JourneyAnnouncer.noSuchOption(option + 1, step.options.length));
      return;
    }
    setState(() => _selected = option);
    _say(JourneyAnnouncer.chosen(step, option));
  }

  Future<void> _submit() async {
    final step = _engine.current;
    final selected = _selected;
    if (step == null || !step.isAnswer) return;
    if (selected == null) {
      _say(JourneyAnnouncer.chooseFirst(step.options.length));
      return;
    }
    final outcome = _engine.answer(selected);
    unawaited(
      FeedbackCues.play(switch (outcome) {
        JourneyOutcome.correct => Cue.correct,
        JourneyOutcome.pollSaved => Cue.saved,
        _ => Cue.wrong,
      }),
    );
    await _save();
    if (!mounted) return;
    final said = JourneyAnnouncer.outcome(outcome, step);
    if (outcome == JourneyOutcome.tryAgain) {
      setState(() => _selected = null);
      _say('$said ${JourneyAnnouncer.question(_engine)}');
      return;
    }
    await _present(prefix: said);
  }

  Future<void> _finish(String prefix) async {
    await _audio.stop();
    await _quizSpeed.stop();
    if (!mounted) return;
    setState(() => _status = JourneyAnnouncer.finishedStatus);
    _say(
      '${prefix.isEmpty ? '' : '$prefix '}${JourneyAnnouncer.finished(_engine)}',
    );
    final store = widget.store;
    if (widget.preview || store == null) return;
    await _save();
    try {
      await store.clearProgress(widget.snapshot.journeyId);
    } on OfflineJourneyException {
      // The completed run is already queued; stale progress restarts fresh.
    }
    final report = await store.syncPending(widget.api);
    if (mounted && report.remaining > 0 && report.offline) {
      setState(() => _status = JourneyAnnouncer.sendLater);
    }
  }

  Future<void> _playAgain() async {
    setState(() => _engine = JourneyEngine(widget.snapshot));
    await _present(prefix: JourneyAnnouncer.startingAgain);
  }

  Future<void> _togglePlay() async {
    final step = _engine.current;
    if (step == null || step.kind != JourneyStepKind.audio) {
      if (step?.kind == JourneyStepKind.narration) {
        _say(JourneyAnnouncer.narration(step!.text));
      }
      return;
    }
    if (_audioFailed) {
      await _present();
    } else if (_audio.playing) {
      await _audio.pause();
      _say(JourneyAnnouncer.paused);
    } else {
      await _audio.resume();
    }
    if (mounted) setState(() {});
  }

  Future<void> _seek(int seconds) async {
    if (_engine.current?.kind != JourneyStepKind.audio) {
      _say(JourneyAnnouncer.seekRecordingsOnly);
      return;
    }
    await _audio.seekBy(Duration(seconds: seconds));
  }

  Future<void> _speed(int direction) async {
    if (_mode == _Mode.answer) {
      await _quizSpeed.change(direction);
      return;
    }
    if (_engine.current?.kind != JourneyStepKind.audio) {
      _say(JourneyAnnouncer.speedRecordingsOnly);
      return;
    }
    final next = (_rate + direction * 0.25).clamp(0.5, 2.0);
    if (next == _rate) {
      _say(direction > 0 ? JourneyAnnouncer.fastest : JourneyAnnouncer.slowest);
      return;
    }
    _rate = next;
    await _audio.setRate(_rate);
    _say(JourneyAnnouncer.speed(_rate));
  }

  Future<void> _leave() async {
    if (_leaving) return;
    final finished = _mode == _Mode.finished;
    if (!finished && !widget.preview) {
      final paused = _audio.playing;
      if (paused) await _audio.pause();
      if (!mounted) return;
      final leave = await JourneyPrompts.confirm(
        context,
        title: JourneyAnnouncer.leaveTitle,
        message: JourneyAnnouncer.leaveMessage(_engine.index + 1),
        confirmLabel: Speech.t.journeyLeaveJourney,
      );
      if (!leave) {
        if (paused) await _audio.resume();
        return;
      }
    }
    _leaving = true;
    unawaited(FeedbackCues.play(Cue.leave));
    await _audio.stop();
    await _save();
    final store = widget.store;
    if (!widget.preview && store != null) {
      unawaited(store.syncPending(widget.api));
    }
    if (mounted) Navigator.of(context).pop();
  }

  Map<int, (String, VoidCallback)> _keys() {
    final t = Speech.t;
    switch (_mode) {
      case _Mode.finished:
        return {1: (t.journeyKeyPlayAgain, () => unawaited(_playAgain()))};
      case _Mode.answer:
        final step = _engine.current!;
        return {
          for (var i = 0; i < step.options.length; i++)
            i + 1: (step.options[i], () => _choose(i)),
          5: (t.journeyKeySubmitAnswer, () => unawaited(_submit())),
          6: (
            t.journeyKeyRepeatQuestion,
            () => _say(JourneyAnnouncer.question(_engine)),
          ),
          7: (t.journeyKeySlowerSpeech, () => unawaited(_speed(-1))),
          8: (t.journeyKeyWhereAmI, _where),
          9: (t.journeyKeyFasterSpeech, () => unawaited(_speed(1))),
        };
      case _Mode.content:
        final audio = _engine.current!.kind == JourneyStepKind.audio;
        return {
          1: (t.journeyKeyWhereAmI, _where),
          2: (t.journeyKeyNextStep, () => unawaited(_next())),
          3: (t.journeyKeyRepeatStep, () => unawaited(_present())),
          if (audio) 4: (t.keyBack10Seconds, () => unawaited(_seek(-10))),
          5: (
            audio ? t.keyPlayOrPause : t.journeyKeyReadAgain,
            () => unawaited(_togglePlay()),
          ),
          if (audio) 6: (t.keyForward10Seconds, () => unawaited(_seek(10))),
          if (audio) 7: (t.keySlower, () => unawaited(_speed(-1))),
          8: (t.journeyKeyPreviousContent, () => unawaited(_previous())),
          if (audio) 9: (t.keyFaster, () => unawaited(_speed(1))),
        };
    }
  }

  String _kindWord(JourneyStepKind kind) => switch (kind) {
    JourneyStepKind.audio => Speech.t.journeyKindRecording,
    JourneyStepKind.narration => Speech.t.journeyKindNarration,
    JourneyStepKind.question => Speech.t.journeyKindQuestion,
    JourneyStepKind.poll => Speech.t.journeyKindPoll,
  };

  @override
  Widget build(BuildContext context) {
    final keys = _keys();
    final step = _engine.current;
    final mode = _mode;
    final t = Speech.t;
    final title = widget.preview
        ? t.journeyPreviewTitle(widget.snapshot.title)
        : widget.snapshot.title;
    final position = step == null
        ? t.journeyPositionFinished
        : t.journeyStepPosition('${_engine.index + 1}', '${_engine.stepCount}');
    final ordered = keys.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    String label(MapEntry<int, (String, VoidCallback)> entry) {
      final selected = mode == _Mode.answer && _selected == entry.key - 1;
      return selected ? t.journeySelectedLabel(entry.value.$1) : entry.value.$1;
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) unawaited(_leave());
      },
      child: KeypadInstructionWrapper(
        interactionPolicy: KeypadInteractionPolicy.numbered,
        screenName: '$title. $position',
        autoPlay: false,
        stateSummary: () => JourneyAnnouncer.state(
          _engine,
          selected: _selected,
          playing: _audio.playing,
        ),
        introduction: switch (mode) {
          _Mode.content => JourneyAnnouncer.contentKeys,
          _Mode.answer => JourneyAnnouncer.answerHelp,
          _Mode.finished => JourneyAnnouncer.finishedStatus,
        },
        labels: {
          for (final entry in ordered) entry.key: entry.value.$1,
          0: t.journeyLeaveJourney,
        },
        actions: {
          for (final entry in ordered) entry.key: entry.value.$2,
          0: () => unawaited(_leave()),
        },
        focusTargets: [
          for (final entry in ordered)
            KeypadFocusTarget(
              node: _node('${mode.name}-${entry.key}'),
              label: '${entry.key}. ${label(entry)}',
              onActivate: entry.value.$2,
            ),
          KeypadFocusTarget(
            node: _node('leave'),
            label: '0. ${t.journeyLeaveSaved}',
            onActivate: () => unawaited(_leave()),
          ),
        ],
        child: Scaffold(
          body: SafeArea(
            child: !_ready
                ? Center(
                    child: Semantics(
                      label: Speech.t.journeyOpening,
                      child: const CircularProgressIndicator(),
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Semantics(
                          header: true,
                          child: Text(
                            title,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ),
                        Text(
                          step == null
                              ? position
                              : _engine.replaying
                              ? Speech.t.journeyStepHeadingReplay(
                                  position,
                                  _kindWord(step.kind),
                                )
                              : Speech.t.journeyStepHeading(
                                  position,
                                  _kindWord(step.kind),
                                ),
                        ),
                        if (_issue != null)
                          Semantics(
                            liveRegion: true,
                            child: Text(
                              _issue!,
                              style: TextStyle(
                                color: UIUtils.errorColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        if (_status != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              _status!,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        if (mode == _Mode.finished && _engine.questionCount > 0)
                          Text(
                            Speech.t.journeyFirstTryShort(
                              '${_engine.firstTryCorrect}',
                              '${_engine.questionCount}',
                            ),
                          ),
                        for (final entry in ordered)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: ElevatedButton(
                              focusNode: _node('${mode.name}-${entry.key}'),
                              onPressed: entry.value.$2,
                              child: Text('${entry.key}: ${label(entry)}'),
                            ),
                          ),
                        TextButton(
                          focusNode: _node('leave'),
                          onPressed: () => unawaited(_leave()),
                          child: Text(Speech.t.journeyLeaveKey0),
                        ),
                        Text(Speech.t.uiKeypadFooter),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
