import 'dart:async';
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart' show routeObserver;
import '../services/api_service.dart';
import '../services/private_note_recorder.dart';
import '../services/private_note_store.dart';
import '../services/tts_service.dart';
import '../widgets/key_instruction_wrapper.dart';
import '../widgets/keypad_confirmation_dialog.dart';

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
    _wasRecording = _recorder.recording;
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
      _report(
        'This note action could not be confirmed. Check storage, microphone permission or connection. Your drafts are kept.',
      );
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

  Future<void> _load() => _run(_read);
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
        title: 'Name private note',
        initial: widget.lessonTitle == null
            ? 'Private note'
            : 'Note for ${widget.lessonTitle}',
      ),
    );
    if (name == null || !mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => KeypadConfirmationDialog(
        title: 'Record private note?',
        message:
            'Record microphone audio on this phone only, for up to five minutes or the remaining separate 10 MB note allowance. Stop recording before using spoken controls. App speech, leaving this screen or app interruption stops recording. Live-session recording is blocked. ${widget.position == null ? '' : 'Lesson point: ${widget.position!.inSeconds} seconds.'} No automatic upload or sharing. Microphone permission may be requested.',
        confirmLabel: 'Start recording',
        cancelLabel: 'Do not record',
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
      throw const PrivateNoteException(
        'Review stopped because the screen or app changed. Open this note again to review.',
      );
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
            throw const PrivateNoteException(
              'Review stopped because your account changed. Open private notes again.',
            );
          }),
        );
      }
    });
  });
  Future<void> _rename(PrivateNote note) => _run(() async {
    final title = await showDialog<String>(
      context: context,
      builder: (_) =>
          _NoteTitleDialog(title: 'Rename private note', initial: note.title),
    );
    if (title == null) return;
    await _store!.rename(note.id, title);
    await _read();
    await TtsService.speak('Private note renamed.');
  });
  Future<void> _remove(PrivateNote note) => _run(() async {
    await _stopReview();
    if (!mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => KeypadConfirmationDialog(
        title: 'Remove this private note?',
        message:
            'Remove only ${note.title} from this account on this phone? Other notes, learning progress and bookmarks are kept. If previously published, the online recording and downloaded copies are not removed.',
        confirmLabel: 'Remove selected note',
        cancelLabel: 'Keep note',
      ),
    );
    if (confirmed != true) return;
    await _store!.remove(note.id);
    _reviewed.remove(note.id);
    await _read();
    await TtsService.speak(
      'Selected private note removed. Other notes and learning progress kept.',
    );
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
      throw const PrivateNoteException(
        'Play and review this note privately before publishing.',
      );
    }
    await _stopReview();
    final account = _store!;
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    await account.checkAccount();
    if (token == null || prefs.getString('role') != 'teacher') {
      throw const PrivateNoteException(
        'Sign in as the teacher before publishing.',
      );
    }
    final access = await ApiService.getAccessContext().timeout(
      const Duration(seconds: 10),
    );
    final workspaces = (access?['workspaces'] as List?)
        ?.whereType<Map<String, dynamic>>()
        .where((w) => w['class_id'] is int && w['subject_id'] is int)
        .toList();
    if (workspaces == null || workspaces.isEmpty) {
      throw const PrivateNoteException(
        'No authorized class/subject workspace was confirmed. Your draft is kept.',
      );
    }
    if (!mounted) return;
    final selected = await _chooseWorkspace(workspaces);
    if (selected == null || !mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => KeypadConfirmationDialog(
        title: 'Publish reviewed note to class?',
        message:
            'Confirm you reviewed ${note.title} and want to publish it to ${selected['class_name'] ?? selected['class_id']}, ${selected['subject_name'] ?? selected['subject_id']}. Authorized class members can stream or download it for up to 30 days offline. Disconnected copies cannot be instantly revoked. Your local draft stays. An unconfirmed upload may already have published; check the library before retrying to avoid duplicates.',
        confirmLabel: 'Publish to selected class',
        cancelLabel: 'Keep draft private',
      ),
    );
    if (confirmed != true) return;
    final path = await account.localPath(note.id);
    await account.checkAccount();
    if (prefs.getString('token') != token ||
        prefs.getString('role') != 'teacher') {
      throw const PrivateNoteException(
        'Sign-in changed. The draft was not sent.',
      );
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
        throw const PrivateNoteException(
          'Sign-in changed. The draft was not sent.',
        );
      }
      final stream = await client
          .send(request)
          .timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(
        stream,
      ).timeout(const Duration(seconds: 30));
      await account.checkAccount();
      if (prefs.getString('token') != token) {
        throw const PrivateNoteException(
          'Your account changed before publication was confirmed. Check the original teacher library before retrying.',
        );
      }
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw const PrivateNoteException(
          'Publication was not confirmed. Check the class library before retrying; your private draft is kept.',
        );
      }
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic> ||
          decoded['audio'] is! Map<String, dynamic>) {
        throw const PrivateNoteException(
          'Publication confirmation was unreadable. Check the library before retrying; your draft is kept.',
        );
      }
      final audio = decoded['audio'] as Map<String, dynamic>;
      if (audio['audio_id'] is! int ||
          audio['class_id'] != selected['class_id'] ||
          audio['subject_id'] != selected['subject_id'] ||
          audio['uploaded_by'] != account.userId) {
        throw const PrivateNoteException(
          'Publication identity did not match. Check the library before retrying; your draft is kept.',
        );
      }
      if (mounted) {
        setState(
          () => _status =
              'Published as recording ${audio['audio_id']}. Your local draft is kept. Do not publish again unless you intend another recording.',
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
      _report(
        'Recording stop was not confirmed. Stop again or background the app before leaving.',
      );
      return;
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _reviewAccountTimer?.cancel();
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

  @override
  Widget build(BuildContext context) {
    final active = _recorder.active;
    final targets = <KeypadFocusTarget>[
      KeypadFocusTarget(
        node: _node('back'),
        label: 'Back. Stop any recording first',
        onActivate: _back,
      ),
      KeypadFocusTarget(
        node: _node('refresh'),
        label: 'Refresh private notes',
        isEnabled: () => !_busy && !active,
        onActivate: _load,
      ),
      KeypadFocusTarget(
        node: _node('start'),
        label:
            'Record private note. Explicit start with permission and confirmation',
        isEnabled: () => !_busy && !active,
        onActivate: _start,
      ),
      KeypadFocusTarget(
        node: _node('stop'),
        label: 'Stop recording now',
        isEnabled: () => active && !_recorder.busy,
        onActivate: _stop,
      ),
      KeypadFocusTarget(
        node: _node('status'),
        label: 'Read private note status. Reading stops recording',
        onActivate: () => TtsService.speak(
          '${_recorder.status} ${_recorder.issue ?? ''} ${_issue ?? ''} $_status ${(_used / 1000000).toStringAsFixed(2)} of 10 MB private notes used.',
        ),
      ),
      KeypadFocusTarget(
        node: _node('stop-review'),
        label: 'Stop private review',
        onActivate: () => _run(_stopReview),
      ),
      for (final note in _notes) ...[
        KeypadFocusTarget(
          node: _node('play-${note.id}'),
          label:
              'Review ${note.title} privately. ${note.complete ? '${note.duration.inSeconds} seconds.' : 'Incomplete recording; cannot play.'}',
          isEnabled: () => !_busy && !active && note.complete,
          onActivate: () => _review(note),
        ),
        KeypadFocusTarget(
          node: _node('rename-${note.id}'),
          label: 'Rename ${note.title}',
          isEnabled: () => !_busy && !active && note.issue == null,
          onActivate: () => _rename(note),
        ),
        if (_teacher)
          KeypadFocusTarget(
            node: _node('publish-${note.id}'),
            label:
                'Publish reviewed ${note.title} to a selected authorized class and subject with confirmation',
            isEnabled: () =>
                !_busy &&
                !active &&
                note.complete &&
                _reviewed.contains(note.id),
            onActivate: () => _publish(note),
          ),
        KeypadFocusTarget(
          node: _node('remove-${note.id}'),
          label: 'Remove ${note.title} with confirmation',
          isEnabled: () => !_busy && !active,
          onActivate: () => _remove(note),
        ),
      ],
    ];
    Widget button(String id, String text) {
      final target = targets.firstWhere((target) => target.node == _node(id));
      return OutlinedButton(
        focusNode: target.node,
        onPressed: target.isEnabled?.call() == false ? null : target.onActivate,
        child: Text(text),
      );
    }

    return KeypadInstructionWrapper(
      autoPlay: !_busy && !active,
      screenName:
          'Private notes. Five minutes per note, separate 10 MB per account. Explicit recording only, never inside a live session. Student notes stay private on this phone. Teacher drafts require review and confirmation before publishing. Retained across logout. Stop recording before using spoken controls.',
      focusTargets: targets,
      actions: {0: _back},
      labels: const {0: 'Back'},
      onHashKey: _back,
      child: PopScope(
        canPop: !active,
        onPopInvokedWithResult: (popped, _) {
          if (!popped) unawaited(_back());
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Private notes'),
            leading: IconButton(
              focusNode: _node('back'),
              onPressed: _back,
              tooltip: 'Back',
              icon: const Icon(Icons.arrow_back),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '${(_used / 1000000).toStringAsFixed(2)} / 10 MB private notes. Separate from lesson downloads. No automatic deletion.',
                ),
                if (widget.lessonTitle != null)
                  Text(
                    '${widget.lessonTitle}. Captured lesson point: ${widget.position?.inSeconds ?? 0} seconds.',
                  ),
                Text(_recorder.status),
                if (_recorder.issue != null) Text(_recorder.issue!),
                if (_issue != null)
                  Semantics(liveRegion: true, child: Text(_issue!)),
                if (_status.isNotEmpty) Text(_status),
                if (_busy) const LinearProgressIndicator(),
                button('refresh', 'Refresh notes'),
                button('start', 'Record a private note'),
                button('stop', 'Stop recording'),
                button('status', 'Read note status'),
                button('stop-review', 'Stop private review'),
                for (final note in _notes)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(note.title),
                          Text(
                            note.issue ??
                                (note.complete
                                    ? '${note.duration.inSeconds} seconds. Private local note.'
                                    : 'Interrupted or incomplete note. Cannot play or publish.'),
                          ),
                          if (note.audioId != null)
                            Text(
                              'Lesson ${note.audioId}, point ${note.position?.inSeconds ?? 0} seconds.',
                            ),
                          button(
                            'play-${note.id}',
                            _playing == note.id
                                ? 'Review playing'
                                : 'Review privately',
                          ),
                          button('rename-${note.id}', 'Rename'),
                          if (_teacher)
                            button(
                              'publish-${note.id}',
                              'Publish reviewed note',
                            ),
                          button('remove-${note.id}', 'Remove selected note'),
                        ],
                      ),
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
      setState(() => _issue = 'Enter a name before saving.');
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
    screenName:
        '${widget.title}. OK enters editing. Up or Down leaves editing, then choose Save or Cancel.',
    onHashKey: () => Navigator.pop(context),
    actions: const {},
    focusTargets: [
      KeypadFocusTarget(node: _field, label: 'Note name', isTextField: true),
      KeypadFocusTarget(
        node: _save,
        label: 'Save note name',
        onActivate: _submit,
      ),
      KeypadFocusTarget(
        node: _cancel,
        label: 'Cancel',
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
              labelText: 'Note name',
              errorText: _issue,
            ),
          ),
          OutlinedButton(
            focusNode: _save,
            onPressed: _submit,
            child: const Text('Save name'),
          ),
          TextButton(
            focusNode: _cancel,
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
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
      return '${workspace['class_name'] ?? workspace['class_id']}, ${workspace['subject_name'] ?? workspace['subject_id']}';
    }

    void choose(int index) => Navigator.pop(context, widget.workspaces[index]);
    return KeypadInstructionWrapper(
      screenName:
          'Choose an authorized class and subject before publishing. Nothing is uploaded until the next confirmation.',
      actions: {0: () => Navigator.pop(context)},
      labels: const {0: 'Cancel'},
      onHashKey: () => Navigator.pop(context),
      focusTargets: [
        KeypadFocusTarget(
          node: _back,
          label: 'Cancel publication',
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
        title: const Text('Publish to which workspace?'),
        scrollable: true,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextButton(
              focusNode: _back,
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
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
