import 'dart:async';
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/speech.dart';
import '../main.dart' show routeObserver;
import '../services/api_service.dart';
import '../services/private_note_recorder.dart';
import '../services/private_note_store.dart';
import '../services/tts_service.dart';
import '../utils/ui_utils.dart';
import '../widgets/accessible_tile.dart';
import '../widgets/key_instruction_wrapper.dart';
import '../widgets/keypad_confirmation_dialog.dart';
import '../announcers/library_text.dart';

class PrivateNotesScreen extends StatefulWidget {
  const PrivateNotesScreen({
    super.key,
    this.audioId,
    this.lessonTitle,
    this.position,
  });
  final int? audioId;
  final String? lessonTitle;
  final Duration? position;
  @override
  State<PrivateNotesScreen> createState() => _PrivateNotesScreenState();
}

class _PrivateNotesScreenState extends State<PrivateNotesScreen>
    with WidgetsBindingObserver, RouteAware {
  final _recorder = PrivateNoteRecorder();
  final _player = AudioPlayer();
  final _nodes = <String, FocusNode>{};
  final _reviewed = <String>{};
  PrivateNoteStore? _store;
  List<PrivateNote> _notes = [];
  int _used = 0;
  bool _teacher = false;
  bool _busy = false;
  bool _wasRecording = false;
  String? _playing;
  String? _issue;
  String _status = '';
  DateTime? _recordingSince;
  Timer? _elapsedTimer;
  ModalRoute<void>? _route;
  SharedPreferences? _preferences;
  Timer? _reviewAccountTimer;
  http.Client? _publicationClient;
  bool get _current =>
      mounted &&
      _route?.isCurrent == true &&
      WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
  FocusNode _node(String id) =>
      _nodes.putIfAbsent(id, () => FocusNode(debugLabel: 'notes-$id'));

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _recorder.addListener(_recordingChanged);
    _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _playing = null);
    });
    TtsService.registerRecordedPlayback(
      _player,
      isPlaying: () => _playing != null,
      item: () => _playing,
      canResume: () =>
          _current && _preferences?.getInt('user_id') == _store?.userId,
      pause: _player.pause,
      resume: _player.resume,
      onResumeSkipped: () {
        if (mounted) setState(() => _playing = null);
      },
    );
    unawaited(_load());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != _route) {
      routeObserver.unsubscribe(this);
      _route = route;
      if (route != null) routeObserver.subscribe(this, route);
    }
  }

  @override
  void didPushNext() {
    unawaited(_recorder.stop());
    unawaited(_stopReview());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      unawaited(_recorder.stop());
      unawaited(_stopReview());
    }
  }

  void _recordingChanged() {
    if (!mounted) return;
    final stopped = _wasRecording && !_recorder.recording;
    final started = !_wasRecording && _recorder.recording;
    _wasRecording = _recorder.recording;
    if (started) {
      _recordingSince = DateTime.now();
      _elapsedTimer?.cancel();
      _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {});
      });
      // App speech stops recording, so only screen readers hear this.
      if (TtsService.mode == SpeechMode.screenReader) {
        unawaited(TtsService.speak(Speech.t.notesRecordingStarted));
      }
    }
    if (stopped) {
      _elapsedTimer?.cancel();
      _elapsedTimer = null;
      _recordingSince = null;
    }
    setState(() {});
    if (stopped) unawaited(_load());
  }

  void _report(String message) {
    if (!mounted) return;
    setState(() => _issue = message);
    unawaited(TtsService.speak(message, priority: SpeechPriority.critical));
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _issue = null;
    });
    try {
      await action();
    } on PrivateNoteException catch (error) {
      _report(error.message);
    } on Exception catch (error) {
      debugPrint('[NOTES] Screen operation failed (${error.runtimeType}).');
      _report(Speech.t.notesActionNotConfirmed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _read() async {
    final store = _store ??= await PrivateNoteStore.forCurrentUser();
    final notes = await store.list();
    final used = await store.usedBytes();
    final prefs = await SharedPreferences.getInstance();
    await store.checkAccount();
    if (mounted) {
      setState(() {
        _notes = notes;
        _used = used;
        _teacher = prefs.getString('role') == 'teacher';
        _preferences = prefs;
      });
    }
  }

  Future<void> _load({bool announce = false}) => _run(() async {
    await _read();
    if (!announce || !mounted) return;
    unawaited(
      TtsService.speak(
        _notes.isEmpty
            ? Speech.t.notesNoneYet
            : Speech.t.notesLoaded(_notes.length),
      ),
    );
  });
  Future<void> _stopReview() async {
    _reviewAccountTimer?.cancel();
    _reviewAccountTimer = null;
    await _player.stop();
    if (mounted) setState(() => _playing = null);
  }

  Future<void> _start() => _run(() async {
    if (_recorder.active) return;
    await _stopReview();
    if (!mounted) return;
    final name = await showDialog<String>(
      context: context,
      builder: (_) => _NoteTitleDialog(
        title: Speech.t.notesNameDialogTitle,
        initial: widget.lessonTitle == null
            ? Speech.t.notesDefaultTitle
            : Speech.t.notesDefaultLessonTitle(widget.lessonTitle!),
      ),
    );
    if (name == null || !mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => KeypadConfirmationDialog(
        title: Speech.t.notesRecordConfirmTitle,
        message: Speech.t.notesRecordConfirmMessage(
          widget.position == null
              ? ''
              : Speech.t.notesLessonPointSeconds(
                  '${widget.position!.inSeconds}',
                ),
        ),
        confirmLabel: Speech.t.notesStartRecording,
        cancelLabel: Speech.t.notesDoNotRecord,
      ),
    );
    if (confirmed != true || !mounted) return;
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;
    await _recorder.start(
      store: _store!,
      title: name,
      audioId: widget.audioId,
      position: widget.position,
      canRecord: () => _current,
    );
    if (!_recorder.recording) {
      await _read();
      if (_recorder.issue != null) _report(_recorder.issue!);
    }
  });
  Future<void> _stop() => _run(() async {
    await _recorder.stop();
    await _read();
    if (_recorder.issue != null) {
      _report(_recorder.issue!);
    } else {
      await TtsService.speak(_recorder.status);
    }
  });
  Future<void> _review(PrivateNote note) => _run(() async {
    await _stopReview();
    final path = await _store!.localPath(note.id);
    await _player.play(DeviceFileSource(path, mimeType: 'audio/mp4'));
    try {
      await _store!.checkAccount();
    } on Exception {
      await _stopReview();
      rethrow;
    }
    if (!_current) {
      await _stopReview();
      throw PrivateNoteException(Speech.t.notesReviewStoppedChanged);
    }
    if (mounted) {
      setState(() {
        _playing = note.id;
        _reviewed.add(note.id);
      });
    }
    _reviewAccountTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_preferences?.getInt('user_id') != _store?.userId) {
        unawaited(
          _run(() async {
            await _stopReview();
            throw PrivateNoteException(Speech.t.notesReviewStoppedAccount);
          }),
        );
      }
    });
  });
  Future<void> _rename(PrivateNote note) => _run(() async {
    final title = await showDialog<String>(
      context: context,
      builder: (_) => _NoteTitleDialog(
        title: Speech.t.notesRenameDialogTitle,
        initial: note.title,
      ),
    );
    if (title == null) return;
    await _store!.rename(note.id, title);
    await _read();
    await TtsService.speak(LibraryText.noteRenamed);
  });
  Future<void> _remove(PrivateNote note) => _run(() async {
    await _stopReview();
    if (!mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => KeypadConfirmationDialog(
        title: Speech.t.notesRemoveTitle(note.title),
        message: Speech.t.notesRemoveMessage(note.title),
        confirmLabel: Speech.t.notesRemoveSelected,
        cancelLabel: Speech.t.notesKeepNote,
      ),
    );
    if (confirmed != true) {
      if (mounted) _node('remove-${note.id}').requestFocus();
      return;
    }
    await _store!.remove(note.id);
    _reviewed.remove(note.id);
    await _read();
    await TtsService.speak(Speech.t.notesRemoved(note.title));
  });

  Future<Map<String, dynamic>?> _chooseWorkspace(
    List<Map<String, dynamic>> workspaces,
  ) async {
    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => _NoteWorkspaceDialog(workspaces),
    );
  }

  Future<void> _publish(PrivateNote note) => _run(() async {
    if (!_teacher || !_reviewed.contains(note.id)) {
      throw PrivateNoteException(Speech.t.notesReviewBeforePublish);
    }
    await _stopReview();
    final account = _store!;
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    await account.checkAccount();
    if (token == null || prefs.getString('role') != 'teacher') {
      throw PrivateNoteException(Speech.t.notesSignInAsTeacher);
    }
    final access = await ApiService.getAccessContext().timeout(
      const Duration(seconds: 10),
    );
    final workspaces = (access?['workspaces'] as List?)
        ?.whereType<Map<String, dynamic>>()
        .where((w) => w['class_id'] is int && w['subject_id'] is int)
        .toList();
    if (workspaces == null || workspaces.isEmpty) {
      throw PrivateNoteException(Speech.t.notesNoWorkspace);
    }
    if (!mounted) return;
    final selected = await _chooseWorkspace(workspaces);
    if (selected == null || !mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => KeypadConfirmationDialog(
        title: Speech.t.notesPublishTitle,
        message: Speech.t.notesPublishMessage(
          note.title,
          '${selected['class_name'] ?? selected['class_id']}',
          '${selected['subject_name'] ?? selected['subject_id']}',
        ),
        confirmLabel: Speech.t.notesPublishConfirm,
        cancelLabel: Speech.t.notesKeepDraftPrivate,
      ),
    );
    if (confirmed != true) return;
    final path = await account.localPath(note.id);
    await account.checkAccount();
    if (prefs.getString('token') != token ||
        prefs.getString('role') != 'teacher') {
      throw PrivateNoteException(Speech.t.notesSignInChanged);
    }
    final request =
        http.MultipartRequest(
            'POST',
            Uri.parse('${ApiService.baseUrl}/audio/upload'),
          )
          ..followRedirects = false
          ..headers['Authorization'] = 'Bearer $token'
          ..fields.addAll({
            'title': note.title,
            'description': 'Teacher-reviewed recorded lesson note.',
            'class_id': '${selected['class_id']}',
            'subject_id': '${selected['subject_id']}',
          });
    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        path,
        contentType: MediaType('audio', 'mp4'),
      ),
    );
    final client = http.Client();
    _publicationClient = client;
    try {
      await account.checkAccount();
      if (prefs.getString('token') != token || !_current) {
        throw PrivateNoteException(Speech.t.notesSignInChanged);
      }
      final stream = await client
          .send(request)
          .timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(
        stream,
      ).timeout(const Duration(seconds: 30));
      await account.checkAccount();
      if (prefs.getString('token') != token) {
        throw PrivateNoteException(Speech.t.notesAccountChangedBeforePublish);
      }
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw PrivateNoteException(Speech.t.notesPublishNotConfirmed);
      }
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic> ||
          decoded['audio'] is! Map<String, dynamic>) {
        throw PrivateNoteException(Speech.t.notesPublishUnreadable);
      }
      final audio = decoded['audio'] as Map<String, dynamic>;
      if (audio['audio_id'] is! int ||
          audio['class_id'] != selected['class_id'] ||
          audio['subject_id'] != selected['subject_id'] ||
          audio['uploaded_by'] != account.userId) {
        throw PrivateNoteException(Speech.t.notesPublishIdentityMismatch);
      }
      if (mounted) {
        setState(
          () => _status = Speech.t.notesPublished('${audio['audio_id']}'),
        );
      }
      if (mounted) await TtsService.speak(_status);
    } finally {
      if (identical(_publicationClient, client)) _publicationClient = null;
      client.close();
    }
  });

  Future<void> _back() async {
    if (_recorder.active) await _recorder.stop();
    if (_recorder.active) {
      _report(Speech.t.notesStopBeforeLeaving);
      return;
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _reviewAccountTimer?.cancel();
    _elapsedTimer?.cancel();
    _publicationClient?.close();
    routeObserver.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);
    _recorder.removeListener(_recordingChanged);
    _recorder.dispose();
    TtsService.unregisterRecordedPlayback(_player);
    unawaited(_player.dispose());
    for (final node in _nodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  static String get _rules => Speech.t.notesRules;

  static String _spokenSeconds(int total) {
    final minutes = total ~/ 60;
    final seconds = total % 60;
    return [
      if (minutes > 0) Speech.t.spokenMinutes(minutes),
      if (seconds > 0 || minutes == 0) Speech.t.spokenSeconds(seconds),
    ].join(' ');
  }

  int get _elapsedSeconds {
    final since = _recordingSince;
    return since == null ? 0 : DateTime.now().difference(since).inSeconds;
  }

  String get _statusText {
    final elapsed = _recorder.recording
        ? '${Speech.t.notesRecordingFor(_spokenSeconds(_elapsedSeconds))} '
        : '';
    return '$elapsed${_recorder.status} ${_recorder.issue ?? ''} ${_issue ?? ''} '
        '$_status ${Speech.t.notesUsage((_used / 1000000).toStringAsFixed(2))}';
  }

  @override
  Widget build(BuildContext context) {
    final active = _recorder.active;
    final targets = <KeypadFocusTarget>[
      KeypadFocusTarget(
        node: _node('back'),
        label: Speech.t.notesBackStopsRecording,
        onActivate: _back,
      ),
      KeypadFocusTarget(
        node: _node('rules'),
        label: Speech.t.notesReadRules,
        isEnabled: () => !_recorder.recording,
        onActivate: () => TtsService.speak(_rules),
      ),
      KeypadFocusTarget(
        node: _node('refresh'),
        label: Speech.t.notesRefreshPrivate,
        isEnabled: () => !_busy && !active,
        onActivate: () => _load(announce: true),
      ),
      KeypadFocusTarget(
        node: _node('start'),
        label: Speech.t.notesRecordAsksFirst,
        isEnabled: () => !_busy && !active,
        onActivate: _start,
      ),
      KeypadFocusTarget(
        node: _node('stop'),
        label: Speech.t.notesStopRecordingNow,
        isEnabled: () => active && !_recorder.busy,
        onActivate: _stop,
      ),
      KeypadFocusTarget(
        node: _node('status'),
        label: _recorder.recording
            ? Speech.t.notesReadRecordingTimeStops
            : Speech.t.notesReadPrivateStatus,
        onActivate: () => TtsService.speak(_statusText),
      ),
      KeypadFocusTarget(
        node: _node('stop-review'),
        label: _playing == null
            ? Speech.t.notesStopPrivateReview
            : _notes
                      .where((note) => note.id == _playing)
                      .map(
                        (note) => Speech.t.notesStopReviewingTitle(note.title),
                      )
                      .firstOrNull ??
                  Speech.t.notesStopReviewingNote,
        onActivate: () => _run(_stopReview),
      ),
      for (final note in _notes) ...[
        KeypadFocusTarget(
          node: _node('play-${note.id}'),
          label: note.complete
              ? Speech.t.notesReviewTitlePrivately(
                  note.title,
                  _spokenSeconds(note.duration.inSeconds),
                )
              : Speech.t.notesReviewTitleIncomplete(note.title),
          isEnabled: () => !_busy && !active && note.complete,
          onActivate: () => _review(note),
        ),
        KeypadFocusTarget(
          node: _node('rename-${note.id}'),
          label: Speech.t.notesRenameTitle(note.title),
          isEnabled: () => !_busy && !active && note.issue == null,
          onActivate: () => _rename(note),
        ),
        if (_teacher)
          KeypadFocusTarget(
            node: _node('publish-${note.id}'),
            label: Speech.t.notesPublishTitleAsks(note.title),
            isEnabled: () =>
                !_busy &&
                !active &&
                note.complete &&
                _reviewed.contains(note.id),
            onActivate: () => _publish(note),
          ),
        KeypadFocusTarget(
          node: _node('remove-${note.id}'),
          label: Speech.t.notesRemoveTitleAsks(note.title),
          isEnabled: () => !_busy && !active,
          onActivate: () => _remove(note),
        ),
      ],
    ];
    final textStyle = TextStyle(color: UIUtils.textColor, fontSize: 16);
    Widget button(String id, String text) {
      final target = targets.firstWhere((target) => target.node == _node(id));
      return Padding(
        padding: const EdgeInsets.only(top: 6),
        child: OutlinedButton(
          focusNode: target.node,
          style: OutlinedButton.styleFrom(
            foregroundColor: UIUtils.textColor,
            side: BorderSide(color: UIUtils.cardBorderColor, width: 1.5),
            minimumSize: const Size(48, 48),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          onPressed: target.isEnabled?.call() == false
              ? null
              : target.onActivate,
          child: Text(text, semanticsLabel: target.label),
        ),
      );
    }

    final elapsed = _elapsedSeconds;
    return KeypadInstructionWrapper(
      autoPlay: !_busy && !active,
      screenName: Speech.t.notesScreenName,
      introduction: Speech.t.notesIntroduction,
      focusTargets: targets,
      actions: {0: _back},
      labels: {0: Speech.t.notesBack},
      child: PopScope(
        canPop: !active,
        onPopInvokedWithResult: (popped, _) {
          if (!popped) unawaited(_back());
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(Speech.t.notesScreenName),
            leading: IconButton(
              focusNode: _node('back'),
              onPressed: _back,
              tooltip: Speech.t.notesBack,
              icon: const Icon(Icons.arrow_back),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  Speech.t.notesStorageSummary(
                    (_used / 1000000).toStringAsFixed(2),
                  ),
                  style: textStyle,
                ),
                if (widget.lessonTitle != null)
                  Text(
                    Speech.t.notesLessonContext(
                      widget.lessonTitle!,
                      '${widget.position?.inSeconds ?? 0}',
                    ),
                    style: textStyle,
                  ),
                Semantics(
                  liveRegion: true,
                  child: Text(
                    _recorder.status,
                    style: textStyle.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                if (_recorder.recording)
                  ExcludeSemantics(
                    child: Text(
                      Speech.t.notesRecordingTime(
                        '${elapsed ~/ 60}:${(elapsed % 60).toString().padLeft(2, '0')}',
                      ),
                      style: textStyle.copyWith(
                        color: UIUtils.accentColor,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                if (_recorder.issue != null)
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      _recorder.issue!,
                      style: textStyle.copyWith(color: UIUtils.errorColor),
                    ),
                  ),
                if (_issue != null)
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      _issue!,
                      style: textStyle.copyWith(color: UIUtils.errorColor),
                    ),
                  ),
                if (_status.isNotEmpty)
                  Semantics(
                    liveRegion: true,
                    child: Text(_status, style: textStyle),
                  ),
                if (_busy) const LinearProgressIndicator(),
                button('rules', Speech.t.notesReadRules),
                button('refresh', Speech.t.notesRefreshNotes),
                button('start', Speech.t.notesRecordPrivateNote),
                button('stop', Speech.t.notesStopRecording),
                button(
                  'status',
                  _recorder.recording
                      ? Speech.t.notesReadRecordingTime
                      : Speech.t.notesReadNoteStatus,
                ),
                button('stop-review', Speech.t.notesStopPrivateReview),
                if (_notes.isEmpty && !_busy)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(Speech.t.notesNoneYet, style: textStyle),
                  ),
                for (final note in _notes)
                  AccessibleTile(
                    leadingIcon: Icons.mic_none,
                    title: note.title,
                    status: note.issue != null
                        ? Speech.t.notesStatusNeedsAttention
                        : !note.complete
                        ? Speech.t.notesStatusIncomplete
                        : _playing == note.id
                        ? Speech.t.notesStatusPlaying
                        : _reviewed.contains(note.id)
                        ? Speech.t.notesStatusReviewed
                        : Speech.t.notesStatusSaved,
                    statusColor: note.issue != null || !note.complete
                        ? UIUtils.errorColor
                        : null,
                    subtitle: [
                      note.issue ??
                          (note.complete
                              ? Speech.t.notesNoteSeconds(
                                  '${note.duration.inSeconds}',
                                )
                              : Speech.t.notesNoteIncomplete),
                      if (note.audioId != null)
                        Speech.t.notesNoteLessonPoint(
                          '${note.audioId}',
                          '${note.position?.inSeconds ?? 0}',
                        ),
                    ].join(' '),
                    trailing: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        button(
                          'play-${note.id}',
                          _playing == note.id
                              ? Speech.t.notesReviewPlaying
                              : Speech.t.notesReviewPrivately,
                        ),
                        button('rename-${note.id}', Speech.t.notesRename),
                        if (_teacher)
                          button(
                            'publish-${note.id}',
                            Speech.t.notesPublishReviewedNote,
                          ),
                        button(
                          'remove-${note.id}',
                          Speech.t.notesRemoveSelected,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NoteTitleDialog extends StatefulWidget {
  const _NoteTitleDialog({required this.title, required this.initial});
  final String title;
  final String initial;
  @override
  State<_NoteTitleDialog> createState() => _NoteTitleDialogState();
}

class _NoteTitleDialogState extends State<_NoteTitleDialog> {
  late final _text = TextEditingController(
    text: widget.initial.length > 160
        ? widget.initial.substring(0, 160)
        : widget.initial,
  );
  final _field = FocusNode(debugLabel: 'note-name-field');
  final _save = FocusNode(debugLabel: 'note-name-save');
  final _cancel = FocusNode(debugLabel: 'note-name-cancel');
  String? _issue;
  void _submit() {
    if (_text.text.trim().isEmpty) {
      setState(() => _issue = Speech.t.notesEnterNameBeforeSaving);
      TtsService.speak(_issue!);
    } else {
      Navigator.pop(context, _text.text.trim());
    }
  }

  @override
  void dispose() {
    _text.dispose();
    _field.dispose();
    _save.dispose();
    _cancel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => KeypadInstructionWrapper(
    screenName: Speech.t.notesNameDialogInstructions(widget.title),
    actions: const {},
    focusTargets: [
      KeypadFocusTarget(
        node: _field,
        label: Speech.t.notesNoteName,
        isTextField: true,
      ),
      KeypadFocusTarget(
        node: _save,
        label: Speech.t.notesSaveNoteName,
        onActivate: _submit,
      ),
      KeypadFocusTarget(
        node: _cancel,
        label: Speech.t.notesCancel,
        onActivate: () => Navigator.pop(context),
      ),
    ],
    child: AlertDialog(
      title: Text(widget.title),
      scrollable: true,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _text,
            focusNode: _field,
            maxLength: 160,
            decoration: InputDecoration(
              labelText: Speech.t.notesNoteName,
              errorText: _issue,
            ),
          ),
          OutlinedButton(
            focusNode: _save,
            onPressed: _submit,
            child: Text(Speech.t.notesSaveName),
          ),
          TextButton(
            focusNode: _cancel,
            onPressed: () => Navigator.pop(context),
            child: Text(Speech.t.notesCancel),
          ),
        ],
      ),
    ),
  );
}

class _NoteWorkspaceDialog extends StatefulWidget {
  const _NoteWorkspaceDialog(this.workspaces);
  final List<Map<String, dynamic>> workspaces;
  @override
  State<_NoteWorkspaceDialog> createState() => _NoteWorkspaceDialogState();
}

class _NoteWorkspaceDialogState extends State<_NoteWorkspaceDialog> {
  late final _nodes = List.generate(
    widget.workspaces.length,
    (index) => FocusNode(debugLabel: 'note-workspace-$index'),
  );
  final _back = FocusNode(debugLabel: 'note-workspace-back');
  @override
  void dispose() {
    for (final node in [..._nodes, _back]) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String label(int index) {
      final workspace = widget.workspaces[index];
      return Speech.t.notesWorkspaceLabel(
        '${workspace['class_name'] ?? workspace['class_id']}',
        '${workspace['subject_name'] ?? workspace['subject_id']}',
      );
    }

    void choose(int index) => Navigator.pop(context, widget.workspaces[index]);
    return KeypadInstructionWrapper(
      screenName: Speech.t.notesChooseWorkspaceInstructions,
      actions: {0: () => Navigator.pop(context)},
      labels: {0: Speech.t.notesCancel},
      focusTargets: [
        KeypadFocusTarget(
          node: _back,
          label: Speech.t.notesCancelPublication,
          onActivate: () => Navigator.pop(context),
        ),
        for (var index = 0; index < _nodes.length; index++)
          KeypadFocusTarget(
            node: _nodes[index],
            label: label(index),
            onActivate: () => choose(index),
          ),
      ],
      child: AlertDialog(
        title: Text(Speech.t.notesPublishWhichWorkspace),
        scrollable: true,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextButton(
              focusNode: _back,
              onPressed: () => Navigator.pop(context),
              child: Text(Speech.t.notesCancel),
            ),
            for (var index = 0; index < _nodes.length; index++)
              OutlinedButton(
                focusNode: _nodes[index],
                onPressed: () => choose(index),
                child: Text(label(index)),
              ),
          ],
        ),
      ),
    );
  }
}
