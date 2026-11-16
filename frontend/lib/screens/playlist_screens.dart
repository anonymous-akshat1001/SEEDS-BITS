import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../services/message_center.dart';
import '../services/undo_service.dart';
import '../announcers/library_text.dart';
import '../l10n/speech.dart';

import '../services/api_service.dart';
import '../services/tts_service.dart';
import '../services/learning_playback_controller.dart';
import '../services/learning_progress_store.dart';
import '../utils/ui_utils.dart';
import '../utils/keypad_actions.dart';
import '../widgets/accessible_tile.dart';
import '../widgets/key_instruction_wrapper.dart';
import '../widgets/keypad_confirmation_dialog.dart';
import '../widgets/learning_controls.dart';
import '../utils/class_access_utils.dart';
import 'downloads_screen.dart';

class TeacherPlaylistsScreen extends StatefulWidget {
  const TeacherPlaylistsScreen({
    super.key,
    required this.classId,
    required this.className,
    required this.subjectId,
    required this.subjectName,
  });

  final int classId;
  final String className;
  final int subjectId;
  final String subjectName;

  @override
  State<TeacherPlaylistsScreen> createState() => _TeacherPlaylistsScreenState();
}

class _TeacherPlaylistsScreenState extends State<TeacherPlaylistsScreen> {
  final _keypad = KeypadNavigationController();
  final _backNode = FocusNode(debugLabel: 'teacher-playlists-back');
  final _refreshNode = FocusNode(debugLabel: 'teacher-playlists-refresh');
  final _createNode = FocusNode(debugLabel: 'teacher-playlists-create');
  final Map<int, FocusNode> _playlistNodes = {};
  List<dynamic> _playlists = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _backNode.dispose();
    _refreshNode.dispose();
    _createNode.dispose();
    for (final node in _playlistNodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    if (mounted) setState(() => _loading = true);
    final all = await ApiService.getTeacherPlaylists(includeArchived: true);
    if (!mounted) return;
    setState(() {
      _playlists = all
          .where(
            (playlist) =>
                playlist['class_id'] == widget.classId &&
                playlist['subject_id'] == widget.subjectId,
          )
          .toList();
      _loading = false;
    });
    TtsService.speak(
      _playlists.isEmpty
          ? Speech.t.playlistTeacherNone(widget.className, widget.subjectName)
          : Speech.t.playlistTeacherLoaded(
              _playlists.length,
              widget.className,
              widget.subjectName,
            ),
    );
  }

  Future<void> _create() async {
    final title = await _titleDialog(Speech.t.playlistCreateClassTitle);
    if (title == null || title.isEmpty) return;
    final playlist = await ApiService.createTeacherPlaylist(
      title: title,
      classId: widget.classId,
      subjectId: widget.subjectId,
    );
    if (playlist == null) {
      TtsService.speak(LibraryText.playlistNotCreated);
      return;
    }
    await _load();
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlaylistDetailScreen.teacher(
          playlistId: playlist['playlist_id'] as int,
        ),
      ),
    );
    _load();
  }

  Future<String?> _titleDialog(String title) async {
    final controller = TextEditingController();
    final fieldNode = FocusNode(debugLabel: 'playlist-title');
    final cancelNode = FocusNode(debugLabel: 'playlist-create-cancel');
    final createNode = FocusNode(debugLabel: 'playlist-create-confirm');
    final dialogKeypad = KeypadNavigationController();
    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => KeypadInstructionWrapper(
        screenName: title,
        labels: {0: Speech.t.playlistCancel, 1: Speech.t.playlistCreate},
        actions: {
          0: () => Navigator.pop(dialogContext),
          1: () => Navigator.pop(dialogContext, controller.text.trim()),
        },
        navigationController: dialogKeypad,
        focusTargets: [
          KeypadFocusTarget(
            node: fieldNode,
            label: Speech.t.playlistTitleField,
            isTextField: true,
          ),
          KeypadFocusTarget(
            node: cancelNode,
            label: Speech.t.playlistCancelCreation,
            onActivate: () => Navigator.pop(dialogContext),
          ),
          KeypadFocusTarget(
            node: createNode,
            label: Speech.t.playlistCreatePlaylist,
            onActivate: () =>
                Navigator.pop(dialogContext, controller.text.trim()),
          ),
        ],
        child: AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            focusNode: fieldNode,
            onTap: () => dialogKeypad.enterTextEditing(fieldNode),
            decoration: InputDecoration(labelText: Speech.t.playlistTitleField),
          ),
          actions: [
            TextButton(
              focusNode: cancelNode,
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(Speech.t.libraryCancelKey0Button),
            ),
            FilledButton(
              focusNode: createNode,
              onPressed: () =>
                  Navigator.pop(dialogContext, controller.text.trim()),
              child: Text(Speech.t.teacherHomeCreateKey1),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    fieldNode.dispose();
    cancelNode.dispose();
    createNode.dispose();
    return result;
  }

  List<KeypadFocusTarget> _targets() {
    final targets = <KeypadFocusTarget>[
      KeypadFocusTarget(
        node: _backNode,
        label: Speech.t.playlistBack,
        onActivate: () => Navigator.pop(context),
      ),
      KeypadFocusTarget(
        node: _refreshNode,
        label: Speech.t.playlistRefreshPlaylists,
        onActivate: _load,
      ),
      KeypadFocusTarget(
        node: _createNode,
        label: Speech.t.playlistCreatePlaylist,
        onActivate: _create,
      ),
    ];
    for (final entry in _playlists) {
      final playlist = Map<String, dynamic>.from(entry as Map);
      final id = playlist['playlist_id'] as int;
      targets.add(
        KeypadFocusTarget(
          node: _playlistNodes.putIfAbsent(
            id,
            () => FocusNode(debugLabel: 'teacher-playlist-$id'),
          ),
          label: Speech.t.playlistTeacherItemLabel(
            '${playlist['title']}',
            _teacherStatus(playlist),
            '${playlist['item_count']}',
          ),
          onActivate: () => _open(id),
        ),
      );
    }
    return targets;
  }

  Future<void> _open(int id) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlaylistDetailScreen.teacher(playlistId: id),
      ),
    );
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return KeypadInstructionWrapper(
      screenName: Speech.t.playlistTeacherScreen(
        widget.className,
        widget.subjectName,
      ),
      labels: {
        0: Speech.t.playlistBack,
        1: Speech.t.playlistRefresh,
        2: Speech.t.playlistCreatePlaylistKey,
      },
      actions: {0: () => Navigator.pop(context), 1: _load, 2: _create},
      navigationController: _keypad,
      focusTargets: _targets(),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            focusNode: _backNode,
            tooltip: Speech.t.settingsBack,
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
          ),
          title: Text(
            Speech.t.playlistClassSubjectTitle(
              widget.className,
              widget.subjectName,
            ),
          ),
          actions: [
            IconButton(
              focusNode: _refreshNode,
              tooltip: Speech.t.playlistRefreshPlaylists,
              onPressed: _load,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: UIUtils.paddingAll(context, 12),
                children: [
                  FilledButton.icon(
                    focusNode: _createNode,
                    style: FilledButton.styleFrom(
                      backgroundColor: UIUtils.accentColor,
                      foregroundColor: UIUtils.onAccentColor,
                      minimumSize: const Size(48, 48),
                    ),
                    onPressed: _create,
                    icon: const Icon(Icons.playlist_add),
                    label: Text(Speech.t.playlistCreateKey2),
                  ),
                  if (_playlists.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Semantics(
                        liveRegion: true,
                        child: Text(
                          Speech.t.playlistNoneInClass,
                          style: TextStyle(
                            color: UIUtils.textColor,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ..._playlists.map((entry) {
                    final playlist = Map<String, dynamic>.from(entry as Map);
                    final id = playlist['playlist_id'] as int;
                    return AccessibleTile(
                      focusNode: _playlistNodes.putIfAbsent(
                        id,
                        () => FocusNode(debugLabel: 'teacher-playlist-$id'),
                      ),
                      leadingIcon: playlist['is_published'] == true
                          ? Icons.public
                          : Icons.edit_note,
                      title: '${playlist['title']}',
                      status: _teacherStatus(playlist),
                      subtitle: '${playlist['item_count']} items',
                      onActivate: () => _open(id),
                    );
                  }),
                ],
              ),
      ),
    );
  }

  String _teacherStatus(Map<String, dynamic> playlist) =>
      playlist['is_archived'] == true
      ? Speech.t.playlistStatusArchived
      : playlist['is_published'] == true
      ? Speech.t.playlistStatusPublished
      : Speech.t.playlistStatusDraft;
}

class StudentPlaylistsScreen extends StatefulWidget {
  const StudentPlaylistsScreen({super.key});

  @override
  State<StudentPlaylistsScreen> createState() => _StudentPlaylistsScreenState();
}

class _StudentPlaylistsScreenState extends State<StudentPlaylistsScreen> {
  final _keypad = KeypadNavigationController();
  final _backNode = FocusNode(debugLabel: 'my-playlists-back');
  final _refreshNode = FocusNode(debugLabel: 'my-playlists-refresh');
  final _createNode = FocusNode(debugLabel: 'my-playlists-create');
  final Map<String, FocusNode> _nodes = {};
  List<dynamic> _private = const [];
  List<dynamic> _classPlaylists = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _backNode.dispose();
    _refreshNode.dispose();
    _createNode.dispose();
    for (final node in _nodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    if (mounted) setState(() => _loading = true);
    final results = await Future.wait([
      ApiService.getStudentPlaylists(),
      ApiService.getVisibleTeacherPlaylists(),
    ]);
    if (!mounted) return;
    setState(() {
      _private = results[0];
      _classPlaylists = results[1];
      _loading = false;
    });
    TtsService.speak(
      _private.isEmpty && _classPlaylists.isEmpty
          ? Speech.t.playlistStudentNone
          : Speech.t.playlistStudentLoaded(
              _private.length,
              _classPlaylists.length,
            ),
    );
  }

  Future<void> _create() async {
    final controller = TextEditingController();
    final fieldNode = FocusNode(debugLabel: 'private-playlist-title');
    final cancelNode = FocusNode(debugLabel: 'private-playlist-cancel');
    final createNode = FocusNode(debugLabel: 'private-playlist-confirm');
    final dialogKeypad = KeypadNavigationController();
    final title = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => KeypadInstructionWrapper(
        screenName: Speech.t.playlistCreatePrivate,
        labels: {0: Speech.t.playlistCancel, 1: Speech.t.playlistCreate},
        actions: {
          0: () => Navigator.pop(dialogContext),
          1: () => Navigator.pop(dialogContext, controller.text.trim()),
        },
        navigationController: dialogKeypad,
        focusTargets: [
          KeypadFocusTarget(
            node: fieldNode,
            label: Speech.t.playlistTitleField,
            isTextField: true,
          ),
          KeypadFocusTarget(
            node: cancelNode,
            label: Speech.t.playlistCancel,
            onActivate: () => Navigator.pop(dialogContext),
          ),
          KeypadFocusTarget(
            node: createNode,
            label: Speech.t.playlistCreatePrivate,
            onActivate: () =>
                Navigator.pop(dialogContext, controller.text.trim()),
          ),
        ],
        child: AlertDialog(
          title: Text(Speech.t.playlistCreatePrivate),
          content: TextField(
            controller: controller,
            focusNode: fieldNode,
            autofocus: true,
            onTap: () => dialogKeypad.enterTextEditing(fieldNode),
            decoration: InputDecoration(labelText: Speech.t.playlistTitleField),
          ),
          actions: [
            TextButton(
              focusNode: cancelNode,
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(Speech.t.libraryCancelKey0Button),
            ),
            FilledButton(
              focusNode: createNode,
              onPressed: () =>
                  Navigator.pop(dialogContext, controller.text.trim()),
              child: Text(Speech.t.teacherHomeCreateKey1),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    fieldNode.dispose();
    cancelNode.dispose();
    createNode.dispose();
    if (title == null || title.isEmpty) return;
    final result = await ApiService.createStudentPlaylist(title: title);
    if (result == null) {
      TtsService.speak(LibraryText.privatePlaylistNotCreated);
      return;
    }
    await _load();
  }

  Future<void> _openPrivate(int id) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlaylistDetailScreen.studentPrivate(playlistId: id),
      ),
    );
    _load();
  }

  Future<void> _openClass(int id) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlaylistDetailScreen.studentClass(playlistId: id),
      ),
    );
  }

  List<KeypadFocusTarget> _targets() {
    final targets = <KeypadFocusTarget>[
      KeypadFocusTarget(
        node: _backNode,
        label: Speech.t.playlistBack,
        onActivate: () => Navigator.pop(context),
      ),
      KeypadFocusTarget(
        node: _refreshNode,
        label: Speech.t.playlistRefreshPlaylists,
        onActivate: _load,
      ),
      KeypadFocusTarget(
        node: _createNode,
        label: Speech.t.playlistCreatePrivate,
        onActivate: _create,
      ),
    ];
    for (final entry in _private) {
      final playlist = Map<String, dynamic>.from(entry as Map);
      final id = playlist['playlist_id'] as int;
      targets.add(
        KeypadFocusTarget(
          node: _nodes.putIfAbsent(
            'private-$id',
            () => FocusNode(debugLabel: 'private-playlist-$id'),
          ),
          label: Speech.t.playlistPrivateItemLabel(
            '${playlist['title']}',
            '${playlist['item_count']}',
          ),
          onActivate: () => _openPrivate(id),
        ),
      );
    }
    for (final entry in _classPlaylists) {
      final playlist = Map<String, dynamic>.from(entry as Map);
      final id = playlist['playlist_id'] as int;
      targets.add(
        KeypadFocusTarget(
          node: _nodes.putIfAbsent(
            'class-$id',
            () => FocusNode(debugLabel: 'class-playlist-$id'),
          ),
          label: Speech.t.playlistClassItemLabel(
            '${playlist['title']}',
            '${playlist['subject_name']}',
            '${playlist['item_count']}',
          ),
          onActivate: () => _openClass(id),
        ),
      );
    }
    return targets;
  }

  @override
  Widget build(BuildContext context) {
    return KeypadInstructionWrapper(
      screenName: Speech.t.playlistStudentScreen,
      labels: {
        0: Speech.t.playlistBack,
        1: Speech.t.playlistRefresh,
        2: Speech.t.playlistCreatePrivateKey,
      },
      actions: {0: () => Navigator.pop(context), 1: _load, 2: _create},
      navigationController: _keypad,
      focusTargets: _targets(),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            focusNode: _backNode,
            tooltip: Speech.t.settingsBack,
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
          ),
          title: Text(Speech.t.playlistMyPlaylists),
          actions: [
            IconButton(
              focusNode: _refreshNode,
              tooltip: Speech.t.playlistRefreshPlaylists,
              onPressed: _load,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: UIUtils.paddingAll(context, 12),
                children: [
                  AccessibleTile(
                    leadingIcon: Icons.lock,
                    title: Speech.t.playlistPrivateNoticeTitle,
                    subtitle: Speech.t.playlistPrivateNoticeText,
                  ),
                  FilledButton.icon(
                    focusNode: _createNode,
                    style: FilledButton.styleFrom(
                      backgroundColor: UIUtils.accentColor,
                      foregroundColor: UIUtils.onAccentColor,
                      minimumSize: const Size(48, 48),
                    ),
                    onPressed: _create,
                    icon: const Icon(Icons.playlist_add),
                    label: Text(Speech.t.playlistCreatePrivateKey2),
                  ),
                  const SizedBox(height: 16),
                  Semantics(
                    header: true,
                    child: Text(
                      Speech.t.playlistMyPrivateHeading,
                      style: TextStyle(
                        color: UIUtils.textColor,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (_private.isEmpty)
                    Text(
                      Speech.t.playlistNoPrivate,
                      style: TextStyle(color: UIUtils.textColor, fontSize: 16),
                    ),
                  ..._private.map((entry) => _playlistTile(entry, true)),
                  const SizedBox(height: 16),
                  Semantics(
                    header: true,
                    child: Text(
                      Speech.t.playlistClassHeading,
                      style: TextStyle(
                        color: UIUtils.textColor,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (_classPlaylists.isEmpty)
                    Text(
                      Speech.t.playlistNoClassPublished,
                      style: TextStyle(color: UIUtils.textColor, fontSize: 16),
                    ),
                  ..._classPlaylists.map(
                    (entry) => _playlistTile(entry, false),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _playlistTile(dynamic entry, bool private) {
    final playlist = Map<String, dynamic>.from(entry as Map);
    final id = playlist['playlist_id'] as int;
    final key = '${private ? 'private' : 'class'}-$id';
    return AccessibleTile(
      focusNode: _nodes.putIfAbsent(key, () => FocusNode(debugLabel: key)),
      leadingIcon: private ? Icons.lock_outline : Icons.school_outlined,
      title: '${playlist['title']}',
      status: private
          ? Speech.t.playlistStatusPrivate
          : Speech.t.playlistClassPlaylist,
      subtitle: private
          ? Speech.t.playlistItemCount('${playlist['item_count']}')
          : Speech.t.playlistClassItemCount(
              '${playlist['class_name']}',
              '${playlist['subject_name']}',
              '${playlist['item_count']}',
            ),
      onActivate: () => private ? _openPrivate(id) : _openClass(id),
    );
  }
}

enum PlaylistMode { teacher, studentPrivate, studentClass }

class PlaylistDetailScreen extends StatefulWidget {
  const PlaylistDetailScreen._({required this.playlistId, required this.mode});

  factory PlaylistDetailScreen.teacher({required int playlistId}) =>
      PlaylistDetailScreen._(
        playlistId: playlistId,
        mode: PlaylistMode.teacher,
      );
  factory PlaylistDetailScreen.studentPrivate({required int playlistId}) =>
      PlaylistDetailScreen._(
        playlistId: playlistId,
        mode: PlaylistMode.studentPrivate,
      );
  factory PlaylistDetailScreen.studentClass({required int playlistId}) =>
      PlaylistDetailScreen._(
        playlistId: playlistId,
        mode: PlaylistMode.studentClass,
      );

  final int playlistId;
  final PlaylistMode mode;

  @override
  State<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen>
    with WidgetsBindingObserver {
  final _player = AudioPlayer();
  late final _learning = LearningPlaybackController(
    seek: _player.seek,
    setSpeed: _player.setPlaybackRate,
    resume: () async {
      await _player.resume();
      if (mounted) setState(() => _playing = true);
    },
    isPlaying: () =>
        mounted && _playing && _player.state == PlayerState.playing,
    onIssue: _learningIssue,
  );
  final _learningNodes = <String, FocusNode>{};
  final _downloadsNode = FocusNode(debugLabel: 'playlist-downloads');
  FocusNode _learningNode(String name) => _learningNodes.putIfAbsent(
    name,
    () => FocusNode(debugLabel: 'playlist-$name'),
  );
  LearningControls get _learningControls => LearningControls(
    controller: _learning,
    nodeFor: _learningNode,
    pauseForNotes: () async {
      if (_playPending) {
        throw LearningStorageException(Speech.t.playlistWaitBeforeNotes);
      }
      await _player.pause();
      if (mounted) setState(() => _playing = false);
      await _learning.flush();
    },
  );
  bool _playPending = false;
  Completer<void>? _playSettled;
  int _playRevision = 0;
  final _keypad = KeypadNavigationController();
  final _backNode = FocusNode(debugLabel: 'playlist-detail-back');
  final _refreshNode = FocusNode(debugLabel: 'playlist-detail-refresh');
  final _editNode = FocusNode(debugLabel: 'playlist-detail-edit');
  final _addNode = FocusNode(debugLabel: 'playlist-detail-add');
  final _playNode = FocusNode(debugLabel: 'playlist-detail-play');
  final _previousNode = FocusNode(debugLabel: 'playlist-detail-previous');
  final _nextNode = FocusNode(debugLabel: 'playlist-detail-next');
  final _publishNode = FocusNode(debugLabel: 'playlist-detail-publish');
  final _archiveNode = FocusNode(debugLabel: 'playlist-detail-archive');
  final _seekNode = FocusNode(debugLabel: 'playlist-detail-seek');
  final _moveUpNode = FocusNode(debugLabel: 'playlist-detail-move-up');
  final _moveDownNode = FocusNode(debugLabel: 'playlist-detail-move-down');
  String _playbackStatus = 'Stopped';
  final Map<int, FocusNode> _itemNodes = {};
  final Map<int, FocusNode> _removeNodes = {};
  Map<String, dynamic>? _playlist;
  List<dynamic> _availableAudio = const [];
  bool _loading = true;
  bool _playing = false;
  int _selectedIndex = 0;

  bool get _editable => widget.mode != PlaylistMode.studentClass;
  bool get _teacher => widget.mode == PlaylistMode.teacher;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _learning.addListener(_learningChanged);
    _player.onPlayerStateChanged.listen((state) {
      if (mounted &&
          (state == PlayerState.playing || state == PlayerState.paused)) {
        _learning.observePlayback(state == PlayerState.playing);
      }
    });
    _player.onPositionChanged.listen((position) {
      if (mounted) _learning.updatePosition(position);
    });
    _player.onDurationChanged.listen((duration) {
      if (mounted && _learning.ready) _learning.updateDuration(duration);
    });
    _player.onPlayerComplete.listen((_) async {
      if (!mounted) return;
      final revision = _playRevision;
      if (_playPending) await _playSettled?.future;
      if (!mounted || revision != _playRevision || !_learning.ready) return;
      final looping = await _learning.handleCompletion();
      if (!mounted || revision != _playRevision || looping) return;
      setState(() => _playing = false);
      await _next();
    });
    TtsService.registerRecordedPlayback(
      _player,
      isPlaying: () => mounted && _playing,
      canResume: () => mounted && (ModalRoute.of(context)?.isCurrent ?? true),
      onResumeSkipped: () {
        if (mounted) setState(() => _playing = false);
      },
      item: () => _player.source,
      pause: _player.pause,
      resume: _player.resume,
    );
    _load();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      unawaited(_learning.flush());
    }
  }

  void _learningChanged() {
    if (mounted) setState(() {});
  }

  void _learningIssue(String message) {
    if (!mounted) return;
    MessageCenter.error(message);
  }

  Future<void> _openDownloads() async {
    final candidates = _items
        .whereType<Map>()
        .where((item) => item['available'] != false)
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => DownloadsScreen(candidates: candidates),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    TtsService.unregisterRecordedPlayback(_player);
    _learning.removeListener(_learningChanged);
    _learning.dispose();
    _downloadsNode.dispose();
    _player.dispose();
    _backNode.dispose();
    _refreshNode.dispose();
    _editNode.dispose();
    _addNode.dispose();
    _playNode.dispose();
    _previousNode.dispose();
    _nextNode.dispose();
    _publishNode.dispose();
    _archiveNode.dispose();
    _seekNode.dispose();
    _moveUpNode.dispose();
    _moveDownNode.dispose();
    for (final node in _itemNodes.values) {
      node.dispose();
    }
    for (final node in _removeNodes.values) {
      node.dispose();
    }
    for (final node in _learningNodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  List<dynamic> get _items =>
      _playlist?['items'] is List ? _playlist!['items'] as List : const [];

  Future<void> _load() async {
    if (mounted) setState(() => _loading = true);
    Map<String, dynamic>? playlist;
    if (_teacher) {
      playlist = await ApiService.getTeacherPlaylist(widget.playlistId);
    } else if (widget.mode == PlaylistMode.studentPrivate) {
      playlist = await ApiService.getStudentPlaylist(widget.playlistId);
    } else {
      playlist = await ApiService.getVisibleTeacherPlaylist(widget.playlistId);
    }
    final audio = _editable
        ? await ApiService.getAudioList()
        : const <dynamic>[];
    if (!mounted) return;
    if (playlist == null ||
        playlist['items'] is! List ||
        playlist['title'] is! String) {
      setState(() => _loading = false);
      _learningIssue(Speech.t.playlistRefreshFailed);
      return;
    }
    final activeAudioId = _learning.ready ? _learning.lesson?.audioId : null;
    var activeUnavailable = false;
    setState(() {
      _playlist = playlist;
      _availableAudio = audio ?? const [];
      _loading = false;
      if (_selectedIndex >= _items.length) {
        _selectedIndex = _items.isEmpty ? 0 : _items.length - 1;
      }
      if (activeAudioId != null) {
        final index = _items.indexWhere(
          (item) =>
              item is Map &&
              item['audio_id'] == activeAudioId &&
              item['available'] != false,
        );
        if (index >= 0) {
          _selectedIndex = index;
        } else {
          activeUnavailable = true;
        }
      }
    });
    if (activeUnavailable) {
      ++_playRevision;
      await _player.pause();
      await _learning.flush();
      _learning.abort();
      await _player.stop();
      if (!mounted) return;
      setState(() {
        _playing = false;
        _playPending = false;
        _playbackStatus = 'Stopped';
      });
      _learningIssue(Speech.t.playlistLessonGone);
      return;
    }
    final t = Speech.t;
    final state = _teacher
        ? (playlist['is_archived'] == true
              ? t.playlistStateArchived
              : playlist['is_published'] == true
              ? t.playlistStatePublished
              : t.playlistStateDraft)
        : widget.mode == PlaylistMode.studentPrivate
        ? t.playlistStatePrivate
        : t.playlistStatePublishedClass;
    TtsService.speak(
      t.playlistLoaded(
        '${playlist['title']}',
        '${playlist['class_name'] ?? ''}',
        '${playlist['subject_name'] ?? ''}',
        _items.length,
        state,
      ),
    );
  }

  Future<void> _add() async {
    if (!_editable || _playlist == null) return;
    final existingIds = _items.map((item) => item['audio_id']).toSet();
    final candidates = _availableAudio.where((audio) {
      if (existingIds.contains(audio['audio_id'])) return false;
      if (_teacher) {
        return audio['class_id'] == _playlist!['class_id'] &&
            audio['subject_id'] == _playlist!['subject_id'];
      }
      return true;
    }).toList();
    if (candidates.isEmpty) {
      TtsService.speak(LibraryText.noEligibleAudio);
      return;
    }
    final dialogKeypad = KeypadNavigationController();
    final candidateNodes = <int, FocusNode>{
      for (final audio in candidates)
        audio['audio_id'] as int: FocusNode(
          debugLabel: 'playlist-audio-${audio['audio_id']}',
        ),
    };
    final selected = await showDialog<int>(
      context: context,
      builder: (dialogContext) => KeypadInstructionWrapper(
        screenName: Speech.t.playlistAddAudioScreen,
        labels: {0: Speech.t.playlistCancel},
        actions: {0: () => Navigator.pop(dialogContext)},
        navigationController: dialogKeypad,
        focusTargets: candidates
            .map<KeypadFocusTarget>(
              (audio) => KeypadFocusTarget(
                node: candidateNodes[audio['audio_id']]!,
                label: '${audio['title']}, ${audio['subject_name']}',
                onActivate: () =>
                    Navigator.pop(dialogContext, audio['audio_id'] as int),
              ),
            )
            .toList(),
        child: SimpleDialog(
          title: Text(Speech.t.playlistAddAudioTitle),
          children: candidates
              .map<Widget>(
                (audio) => SimpleDialogOption(
                  onPressed: () =>
                      Navigator.pop(dialogContext, audio['audio_id'] as int),
                  child: Semantics(
                    button: true,
                    label: '${audio['title']}, ${audio['subject_name']}',
                    child: ListTile(
                      focusNode: candidateNodes[audio['audio_id']],
                      title: Text('${audio['title']}'),
                      subtitle: Text('${audio['subject_name'] ?? ''}'),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
    for (final node in candidateNodes.values) {
      node.dispose();
    }
    if (selected == null) return;
    final result = _teacher
        ? await ApiService.addTeacherPlaylistItem(widget.playlistId, selected)
        : await ApiService.addStudentPlaylistItem(widget.playlistId, selected);
    if (result != null) {
      await _load();
      TtsService.speak(LibraryText.audioAddedToPlaylist);
    }
  }

  Future<void> _selectAndPlay(int index) async {
    if (index < 0 || index >= _items.length) return;
    if (_playPending) {
      TtsService.speak(LibraryText.waitForPlayer);
      return;
    }
    final item = _items[index];
    if (item['available'] == false) {
      TtsService.speak(
        Speech.t.playlistItemNoLongerAvailable('${item['title']}'),
      );
      return;
    }
    final streamPath = item['stream_path']?.toString();
    if (streamPath == null || streamPath.isEmpty) {
      TtsService.speak(LibraryText.unavailable(item['title']));
      return;
    }
    final revision = ++_playRevision;
    final settled = _playSettled = Completer<void>();
    setState(() => _playPending = true);
    try {
      await _player.pause();
      if (!mounted || revision != _playRevision) return;
      setState(() => _playing = false);
      if (!await LearningControls.prepare(
        context,
        _learning,
        item['audio_id'] as int,
        '${item['title']}',
      )) {
        return;
      }
      if (!mounted || revision != _playRevision) return;
      setState(() => _selectedIndex = index);
      final url = await ApiService.mediaUrl(streamPath);
      if (!mounted || revision != _playRevision) return;
      await _player.setReleaseMode(ReleaseMode.stop);
      if (!mounted || revision != _playRevision) return;
      await _player.setPlaybackRate(_learning.speed);
      if (!mounted || revision != _playRevision) return;
      await _player.play(UrlSource(url), position: _learning.position);
      if (!mounted || revision != _playRevision) return;
      _learning.activate();
      setState(() {
        _playing = true;
        _playbackStatus = Speech.t.libraryStatusPlaying('${item['title']}');
      });
      final duration = await _player.getDuration();
      if (!mounted || revision != _playRevision) return;
      if (duration != null) _learning.updateDuration(duration);
      TtsService.speak(
        '${learningPlayingAnnouncement('${item['title']}', _learning.position, _learning.duration, _learning.speed)} '
        '${Speech.t.playlistItemPosition('${index + 1}', '${_items.length}')}',
      );
    } on Exception catch (error) {
      debugPrint('[LEARNING] Playlist playback failed (${error.runtimeType})');
      if (!mounted || revision != _playRevision) return;
      _learning.abort();
      setState(() => _playing = false);
      _learningIssue(Speech.t.playlistPlayFailed);
    } finally {
      settled.complete();
      if (mounted && revision == _playRevision) {
        setState(() => _playPending = false);
      }
    }
  }

  Future<void> _playPause() async {
    if (_playPending) {
      TtsService.speak(LibraryText.waitForPlayer);
      return;
    }
    if (_items.isEmpty) {
      TtsService.speak(LibraryText.playlistEmpty);
      return;
    }
    if (_playing) {
      await _player.pause();
      if (mounted) {
        setState(() {
          _playing = false;
          _playbackStatus = Speech.t
              .libraryStatusPaused(_learning.lesson?.title ?? '')
              .trim();
        });
      }
      await _learning.flush();
      TtsService.speak(
        Speech.t.playlistPausedAt(
          learningSpokenPosition(_learning.position, _learning.duration),
        ),
      );
    } else {
      if (_player.state == PlayerState.paused && _learning.ready) {
        await _player.resume();
        final title = _learning.lesson?.title ?? Speech.t.playlistLessonDefault;
        if (mounted) {
          setState(() {
            _playing = true;
            _playbackStatus = Speech.t.libraryStatusPlaying(title);
          });
        }
        TtsService.speak(
          learningPlayingAnnouncement(
            title,
            _learning.position,
            _learning.duration,
            _learning.speed,
          ),
        );
      } else {
        await _selectAndPlay(_selectedIndex);
      }
    }
  }

  Future<void> _previous() async {
    if (_items.isEmpty) return;
    await _selectAndPlay(
      (_selectedIndex - 1).clamp(0, _items.length - 1).toInt(),
    );
  }

  Future<void> _next() async {
    if (_playPending) {
      TtsService.speak(LibraryText.waitForPlayer);
      return;
    }
    if (_items.isEmpty) return;
    if (_selectedIndex >= _items.length - 1) {
      await _player.pause();
      await _learning.flush();
      _learning.abort();
      await _player.stop();
      if (mounted) {
        setState(() {
          _playing = false;
          _playbackStatus = Speech.t.playlistFinished;
        });
      }
      TtsService.speak(LibraryText.playlistEnded);
      return;
    }
    await _selectAndPlay(_selectedIndex + 1);
  }

  Future<void> _rename() async {
    if (!_editable || _playlist == null) return;
    final controller = TextEditingController(text: '${_playlist!['title']}');
    final fieldNode = FocusNode(debugLabel: 'rename-playlist-title');
    final cancelNode = FocusNode(debugLabel: 'rename-playlist-cancel');
    final saveNode = FocusNode(debugLabel: 'rename-playlist-save');
    final dialogKeypad = KeypadNavigationController();
    final title = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => KeypadInstructionWrapper(
        screenName: Speech.t.playlistRenameScreen,
        labels: {0: Speech.t.playlistCancel, 1: Speech.t.playlistSave},
        actions: {
          0: () => Navigator.pop(dialogContext),
          1: () => Navigator.pop(dialogContext, controller.text.trim()),
        },
        navigationController: dialogKeypad,
        focusTargets: [
          KeypadFocusTarget(
            node: fieldNode,
            label: Speech.t.playlistTitleField,
            isTextField: true,
          ),
          KeypadFocusTarget(
            node: cancelNode,
            label: Speech.t.playlistCancelRename,
            onActivate: () => Navigator.pop(dialogContext),
          ),
          KeypadFocusTarget(
            node: saveNode,
            label: Speech.t.playlistSaveTitle,
            onActivate: () =>
                Navigator.pop(dialogContext, controller.text.trim()),
          ),
        ],
        child: AlertDialog(
          title: Text(Speech.t.playlistRenameScreen),
          content: TextField(
            controller: controller,
            focusNode: fieldNode,
            autofocus: true,
            onTap: () => dialogKeypad.enterTextEditing(fieldNode),
            decoration: InputDecoration(labelText: Speech.t.playlistTitleField),
          ),
          actions: [
            TextButton(
              focusNode: cancelNode,
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(Speech.t.libraryCancelKey0Button),
            ),
            FilledButton(
              focusNode: saveNode,
              onPressed: () =>
                  Navigator.pop(dialogContext, controller.text.trim()),
              child: Text(Speech.t.adminSaveKey1),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    fieldNode.dispose();
    cancelNode.dispose();
    saveNode.dispose();
    if (title == null || title.isEmpty || title == _playlist!['title']) return;
    final result = _teacher
        ? await ApiService.updateTeacherPlaylist(
            widget.playlistId,
            title: title,
          )
        : await ApiService.updateStudentPlaylist(
            widget.playlistId,
            title: title,
          );
    if (result != null) {
      await _load();
      TtsService.speak(LibraryText.playlistRenamed(title));
    }
  }

  Future<void> _move(int delta) async {
    if (!_editable || _items.length < 2) return;
    final destination = _selectedIndex + delta;
    if (destination < 0 || destination >= _items.length) {
      TtsService.speak(
        delta < 0
            ? Speech.t.playlistAlreadyFirst
            : Speech.t.playlistAlreadyLast,
      );
      return;
    }
    final title = '${_items[_selectedIndex]['title']}';
    final currentIds = _items
        .map<int>((item) => item['item_id'] as int)
        .toList();
    final ids = movePlaylistItem(currentIds, _selectedIndex, delta);
    final result = _teacher
        ? await ApiService.reorderTeacherPlaylist(widget.playlistId, ids)
        : await ApiService.reorderStudentPlaylist(widget.playlistId, ids);
    if (result != null) {
      setState(() => _selectedIndex = destination);
      await _load();
      TtsService.speak(LibraryText.movedTo(title, destination + 1));
    } else {
      TtsService.speak(
        Speech.t.playlistMoveFailed(title),
        priority: SpeechPriority.critical,
      );
    }
  }

  Future<void> _remove(int itemId, String title) async {
    final t = Speech.t;
    final playlistTitle = '${_playlist?['title'] ?? t.playlistThisPlaylist}';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => KeypadConfirmationDialog(
        title: t.playlistRemoveItemTitle(title),
        message: t.playlistRemoveItemMessage(title, playlistTitle),
        cancelLabel: t.playlistKeepItem(title),
        confirmLabel: t.playlistRemoveItem(title),
        cancelKey: 0,
        confirmKey: 1,
      ),
    );
    if (confirmed != true) {
      _removeNodes[itemId]?.requestFocus();
      return;
    }
    final index = _items.indexWhere((item) => item['item_id'] == itemId);
    final audioId = index < 0 ? null : _items[index]['audio_id'] as int?;
    final removed = _teacher
        ? await ApiService.removeTeacherPlaylistItem(widget.playlistId, itemId)
        : await ApiService.removeStudentPlaylistItem(widget.playlistId, itemId);
    if (removed) {
      await _load();
      if (!mounted) return;
      final next = _items.isEmpty
          ? null
          : _items[index.clamp(0, _items.length - 1)]['item_id'] as int;
      (next == null ? _playNode : _itemNodes[next])?.requestFocus();
      if (audioId != null) {
        await UndoService.offer(
          done: LibraryText.removedFromPlaylist(title, playlistTitle),
          undo: () => _restoreItem(audioId, index, title),
        );
      }
    } else {
      TtsService.speak(
        t.playlistRemoveFailed(title),
        priority: SpeechPriority.critical,
      );
    }
  }

  /// Undo for a removed item: adds the recording back at its old position.
  Future<void> _restoreItem(int audioId, int index, String title) async {
    final before = _items.map((item) => item['item_id'] as int).toSet();
    final added = _teacher
        ? await ApiService.addTeacherPlaylistItem(widget.playlistId, audioId)
        : await ApiService.addStudentPlaylistItem(widget.playlistId, audioId);
    if (added == null) throw StateError('Playlist item was not restored');
    await _load();
    final ids = _items.map((item) => item['item_id'] as int).toList();
    final restored = ids.where((id) => !before.contains(id)).firstOrNull;
    if (restored != null && index >= 0 && index < ids.length - 1) {
      ids
        ..remove(restored)
        ..insert(index, restored);
      final reordered = _teacher
          ? await ApiService.reorderTeacherPlaylist(widget.playlistId, ids)
          : await ApiService.reorderStudentPlaylist(widget.playlistId, ids);
      if (reordered != null) await _load();
    }
    if (mounted) MessageCenter.success(LibraryText.restoredToPlaylist(title));
  }

  Future<void> _publish() async {
    if (!_teacher || _playlist == null) return;
    final publishing = _playlist!['is_published'] != true;
    final title = '${_playlist!['title']}';
    final result = await ApiService.setTeacherPlaylistPublished(
      widget.playlistId,
      publishing,
    );
    if (result != null) {
      await _load();
      TtsService.speak(
        publishing
            ? Speech.t.playlistPublishedToClass(title)
            : Speech.t.playlistReturnedToDraft(title),
      );
    } else {
      TtsService.speak(
        Speech.t.playlistChangeFailed(title),
        priority: SpeechPriority.critical,
      );
    }
  }

  Future<void> _archiveOrDelete() async {
    if (_playlist == null || !_editable) return;
    final deleting = widget.mode == PlaylistMode.studentPrivate;
    final restoring = _teacher && _playlist!['is_archived'] == true;
    final title = '${_playlist!['title']}';
    final t = Speech.t;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => KeypadConfirmationDialog(
        title: deleting
            ? t.playlistDeleteTitle(title)
            : restoring
            ? t.playlistRestoreTitle(title)
            : t.playlistArchiveTitle(title),
        message: deleting
            ? t.playlistDeleteMessage(title)
            : restoring
            ? t.playlistRestoreMessage(title)
            : t.playlistArchiveMessage(title),
        cancelLabel: t.playlistCancel,
        confirmLabel: deleting
            ? t.playlistDeleteConfirm(title)
            : restoring
            ? t.playlistRestoreConfirm(title)
            : t.playlistArchiveConfirm(title),
        cancelKey: 0,
        confirmKey: 1,
      ),
    );
    if (confirmed != true) {
      _archiveNode.requestFocus();
      return;
    }
    final success = deleting
        ? await ApiService.deleteStudentPlaylist(widget.playlistId)
        : await ApiService.setTeacherPlaylistArchived(
                widget.playlistId,
                !restoring,
              ) !=
              null;
    if (success && mounted) {
      TtsService.speak(
        deleting
            ? t.playlistDeleted(title)
            : restoring
            ? t.playlistRestoredDraft(title)
            : t.playlistArchived(title),
      );
      if (deleting) {
        Navigator.pop(context);
      } else {
        await _load();
      }
    }
  }

  String get _selectedTitle => _items.isEmpty
      ? Speech.t.playlistSelectedItem
      : '${_items[_selectedIndex.clamp(0, _items.length - 1)]['title']}';

  Future<void> _seekTo(Duration position) async {
    try {
      await _learning.moveTo(position);
    } on Exception catch (error) {
      debugPrint('[LEARNING] Seek failed (${error.runtimeType})');
      _learningIssue(Speech.t.playlistSeekFailed);
    } on ArgumentError catch (error) {
      _learningIssue(error.message.toString());
    }
  }

  List<KeypadFocusTarget> _targets() {
    final t = Speech.t;
    final targets = <KeypadFocusTarget>[
      KeypadFocusTarget(
        node: _backNode,
        label: t.playlistBack,
        onActivate: () => Navigator.pop(context),
      ),
      KeypadFocusTarget(
        node: _refreshNode,
        label: t.playlistRefreshPlaylist,
        onActivate: _load,
      ),
      if (_editable)
        KeypadFocusTarget(
          node: _editNode,
          label: t.playlistRenameLabel(
            '${_playlist?['title'] ?? t.playlistWordPlaylist}',
          ),
          onActivate: _rename,
        ),
      if (_editable)
        KeypadFocusTarget(
          node: _addNode,
          label: t.playlistAddAudioLabel,
          onActivate: _add,
        ),
      KeypadFocusTarget(
        node: _playNode,
        label: _playing
            ? t.playlistPauseLabel(_selectedTitle, '$playerPlayPauseKey')
            : t.playlistPlayLabel(_selectedTitle, '$playerPlayPauseKey'),
        onActivate: _playPause,
      ),
      KeypadFocusTarget(
        node: _previousNode,
        label: t.playlistPreviousLabel,
        onActivate: _previous,
      ),
      KeypadFocusTarget(
        node: _nextNode,
        label: t.playlistNextLabel,
        onActivate: _next,
      ),
      if (_teacher && _playlist?['is_archived'] != true)
        KeypadFocusTarget(
          node: _publishNode,
          label: _playlist?['is_published'] == true
              ? t.playlistReturnToDraftLabel('${_playlist?['title']}')
              : t.playlistPublishLabel('${_playlist?['title']}'),
          onActivate: _publish,
        ),
      if (_editable)
        KeypadFocusTarget(
          node: _archiveNode,
          label: _teacher
              ? (_playlist?['is_archived'] == true
                    ? t.playlistRestoreLabel('${_playlist?['title']}')
                    : t.playlistArchiveLabel('${_playlist?['title']}'))
              : t.playlistDeleteLabel('${_playlist?['title']}'),
          onActivate: _archiveOrDelete,
        ),
      if (_learning.lesson != null) ...[
        KeypadFocusTarget(
          node: _seekNode,
          label: t.playlistSeekLabel(
            learningSpokenPosition(_learning.position, _learning.duration),
          ),
          isEnabled: () => _learning.ready && _learning.duration != null,
          onDecrease: () => _learningControls.seekBy(context, -10),
          onIncrease: () => _learningControls.seekBy(context, 10),
        ),
        ..._learningControls.focusTargets(context),
      ],
      KeypadFocusTarget(
        node: _downloadsNode,
        label: t.playlistDownloadsLabel,
        onActivate: _openDownloads,
      ),
      if (_editable && _items.length > 1) ...[
        KeypadFocusTarget(
          node: _moveUpNode,
          label: t.playlistMoveUpLabel(_selectedTitle),
          onActivate: () => _move(-1),
        ),
        KeypadFocusTarget(
          node: _moveDownNode,
          label: t.playlistMoveDownLabel(_selectedTitle),
          onActivate: () => _move(1),
        ),
      ],
    ];
    for (var index = 0; index < _items.length; index++) {
      final item = _items[index];
      final itemId = item['item_id'] as int;
      targets.add(
        KeypadFocusTarget(
          node: _itemNodes.putIfAbsent(
            itemId,
            () => FocusNode(debugLabel: 'playlist-item-$itemId'),
          ),
          label: _itemLabel(index),
          onActivate: () => _selectAndPlay(index),
        ),
      );
      if (_editable) {
        targets.add(
          KeypadFocusTarget(
            node: _removeNodes.putIfAbsent(
              itemId,
              () => FocusNode(debugLabel: 'playlist-remove-$itemId'),
            ),
            label: t.playlistRemoveItemLabel('${item['title']}'),
            onActivate: () => _remove(itemId, '${item['title']}'),
          ),
        );
      }
    }
    return targets;
  }

  String? _itemStatus(int index) {
    final item = _items[index];
    final t = Speech.t;
    if (item['available'] == false) return t.playlistItemUnavailableInClass;
    if (index != _selectedIndex || _learning.lesson == null) {
      return index == _selectedIndex ? t.playlistItemSelected : null;
    }
    return _playing ? t.playlistItemPlaying : t.playlistItemSelectedPaused;
  }

  String _itemLabel(int index) {
    final item = _items[index];
    final status = _itemStatus(index);
    return [
      '${item['title']}',
      if (status != null) status,
      if ((item['subject_name'] ?? '').toString().isNotEmpty)
        '${item['subject_name']}',
    ].join('. ');
  }

  @override
  Widget build(BuildContext context) {
    final controls = _learningControls;
    final t = Speech.t;
    final labels = <int, String>{
      0: t.playlistBack,
      1: t.playlistRefresh,
      if (_editable) 2: t.playlistAddAudioKey,
      3: t.playlistPreviousItem,
      ...playerTransportKeyLabels,
      ...playerSpeedKeyLabels,
      8: t.playlistNextItem,
    };
    final stacked =
        UIUtils.isTiny(context) || UIUtils.useStackedLayout(context);
    final textStyle = TextStyle(color: UIUtils.textColor, fontSize: 16);
    final borderStyle = OutlinedButton.styleFrom(
      foregroundColor: UIUtils.textColor,
      side: BorderSide(color: UIUtils.cardBorderColor, width: 1.5),
      minimumSize: const Size(48, 48),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    );
    final playerButtons = <Widget>[
      if (_editable)
        OutlinedButton.icon(
          focusNode: _addNode,
          style: borderStyle,
          onPressed: _add,
          icon: const Icon(Icons.add),
          label: Text(
            Speech.t.playlistAddKey2,
            semanticsLabel: Speech.t.playlistAddAudioKey2Label,
          ),
        ),
      FilledButton.icon(
        focusNode: _playNode,
        style: FilledButton.styleFrom(
          backgroundColor: UIUtils.accentColor,
          foregroundColor: UIUtils.onAccentColor,
          minimumSize: const Size(48, 48),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        onPressed: _playPause,
        icon: Icon(_playing ? Icons.pause : Icons.play_arrow),
        label: Text(
          _playing ? Speech.t.playlistPauseKey5 : Speech.t.playlistPlayKey5,
          semanticsLabel: _playing
              ? Speech.t.playlistPauseTitleKey5(_selectedTitle)
              : Speech.t.playlistPlayTitleKey5(_selectedTitle),
        ),
      ),
      OutlinedButton(
        focusNode: _previousNode,
        style: borderStyle,
        onPressed: _previous,
        child: Text(
          Speech.t.playlistPreviousKey3,
          semanticsLabel: Speech.t.playlistPreviousItemKey3,
        ),
      ),
      OutlinedButton(
        focusNode: _nextNode,
        style: borderStyle,
        onPressed: _next,
        child: Text(
          Speech.t.playlistNextKey8,
          semanticsLabel: Speech.t.playlistNextItemKey8,
        ),
      ),
      if (_teacher && _playlist?['is_archived'] != true)
        OutlinedButton(
          focusNode: _publishNode,
          style: borderStyle,
          onPressed: _publish,
          child: Text(
            _playlist?['is_published'] == true ? 'Make draft' : 'Publish',
            semanticsLabel: _playlist?['is_published'] == true
                ? 'Return ${_playlist?['title']} to draft'
                : 'Publish ${_playlist?['title']} to the class',
          ),
        ),
      if (_editable)
        OutlinedButton(
          focusNode: _archiveNode,
          style: borderStyle,
          onPressed: _archiveOrDelete,
          child: Text(
            _teacher
                ? (_playlist?['is_archived'] == true
                      ? Speech.t.playlistRestore
                      : Speech.t.playlistArchive)
                : Speech.t.playlistDeletePlaylist,
            semanticsLabel: _teacher
                ? (_playlist?['is_archived'] == true
                      ? Speech.t.playlistRestoreNamedButton(
                          '${_playlist?['title']}',
                        )
                      : Speech.t.playlistArchiveNamedButton(
                          '${_playlist?['title']}',
                        ))
                : Speech.t.playlistDeleteNamedButton('${_playlist?['title']}'),
          ),
        ),
    ];
    return KeypadInstructionWrapper(
      screenName: _playlist == null
          ? t.playlistScreenDefault
          : t.playlistScreen('${_playlist!['title']}'),
      labels: labels,
      actions: {
        0: () => Navigator.pop(context),
        1: _load,
        if (_editable) 2: _add,
        3: _previous,
        ...controls.playerKeyActions(context),
        playerPlayPauseKey: _playPause,
        8: _next,
      },
      navigationController: _keypad,
      focusTargets: _targets(),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            focusNode: _backNode,
            tooltip: Speech.t.settingsBack,
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
          ),
          title: Text('${_playlist?['title'] ?? 'Playlist'}'),
          actions: [
            IconButton(
              focusNode: _refreshNode,
              onPressed: _load,
              tooltip: Speech.t.playlistRefreshPlaylist,
              icon: const Icon(Icons.refresh),
            ),
            if (_editable)
              IconButton(
                focusNode: _editNode,
                onPressed: _rename,
                tooltip: 'Rename ${_playlist?['title'] ?? 'playlist'}',
                icon: const Icon(Icons.edit_outlined),
              ),
          ],
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _playlist == null
            ? Center(
                child: Semantics(
                  liveRegion: true,
                  child: Text(
                    Speech.t.playlistUnavailableRetry,
                    style: textStyle,
                  ),
                ),
              )
            : ListView(
                padding: UIUtils.paddingAll(context, 12),
                children: [
                  AccessibleTile(
                    title: '${_playlist!['title']}',
                    leadingIcon: widget.mode == PlaylistMode.studentPrivate
                        ? Icons.lock
                        : Icons.playlist_play,
                    status: [
                      Speech.t.playlistItemCount('${_items.length}'),
                      if (_teacher)
                        _playlist!['is_archived'] == true
                            ? Speech.t.playlistStatusArchived
                            : _playlist!['is_published'] == true
                            ? Speech.t.playlistStatusPublished
                            : Speech.t.playlistStatusDraft,
                      if (widget.mode == PlaylistMode.studentPrivate)
                        Speech.t.playlistStatusPrivate,
                    ].join(', '),
                    subtitle: [
                      if (_playlist!['class_name'] != null)
                        '${_playlist!['class_name']}',
                      if (_playlist!['subject_name'] != null)
                        '${_playlist!['subject_name']}',
                    ].join(', '),
                  ),
                  Semantics(
                    liveRegion: true,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Text(
                        _playbackStatus,
                        style: textStyle.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  if (stacked)
                    for (final button in playerButtons)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: button,
                      )
                  else
                    Wrap(spacing: 8, runSpacing: 8, children: playerButtons),
                  if (_learning.lesson != null) ...[
                    ExcludeSemantics(
                      child: Text(
                        Speech.t.libraryPositionSpeed(
                          learningTime(_learning.position),
                          _learning.duration == null
                              ? '--:--'
                              : learningTime(_learning.duration!),
                          learningSpeedNumber(_learning.speed),
                        ),
                        style: textStyle,
                      ),
                    ),
                    PlayerSeekBar(
                      focusNode: _seekNode,
                      position: _learning.position,
                      duration: _learning.duration,
                      onSeek: _seekTo,
                    ),
                    controls,
                  ],
                  OutlinedButton(
                    focusNode: _downloadsNode,
                    style: borderStyle,
                    onPressed: _openDownloads,
                    child: Text(Speech.t.playlistDownloadRecordings),
                  ),
                  if (_editable && _items.length > 1) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(Speech.t.playlistMoveHint, style: textStyle),
                    ),
                    OutlinedButton(
                      focusNode: _moveUpNode,
                      style: borderStyle,
                      onPressed: () => _move(-1),
                      child: Text(Speech.t.playlistMoveUp(_selectedTitle)),
                    ),
                    OutlinedButton(
                      focusNode: _moveDownNode,
                      style: borderStyle,
                      onPressed: () => _move(1),
                      child: Text(Speech.t.playlistMoveDown(_selectedTitle)),
                    ),
                  ],
                  if (_items.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(Speech.t.playlistNoAudio, style: textStyle),
                    ),
                  ...List.generate(_items.length, (index) {
                    final item = _items[index];
                    final itemId = item['item_id'] as int;
                    final available = item['available'] != false;
                    return AccessibleTile(
                      title: '${index + 1}. ${item['title']}',
                      semanticLabel: _itemLabel(index),
                      status: _itemStatus(index),
                      statusColor: available ? null : UIUtils.errorColor,
                      subtitle: '${item['subject_name'] ?? ''}',
                      selected: index == _selectedIndex,
                      focusNode: _itemNodes.putIfAbsent(
                        itemId,
                        () => FocusNode(debugLabel: 'playlist-item-$itemId'),
                      ),
                      onActivate: available
                          ? () => _selectAndPlay(index)
                          : () => TtsService.speak(
                              t.playlistItemUnavailable('${item['title']}'),
                            ),
                      trailing: _editable
                          ? OutlinedButton.icon(
                              focusNode: _removeNodes.putIfAbsent(
                                itemId,
                                () => FocusNode(
                                  debugLabel: 'playlist-remove-$itemId',
                                ),
                              ),
                              style: borderStyle,
                              onPressed: () =>
                                  _remove(itemId, '${item['title']}'),
                              icon: const Icon(Icons.remove_circle_outline),
                              label: Text(
                                'Remove',
                                semanticsLabel:
                                    'Remove ${item['title']} from playlist',
                              ),
                            )
                          : null,
                    );
                  }),
                ],
              ),
      ),
    );
  }
}
