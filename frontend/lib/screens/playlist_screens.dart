import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/tts_service.dart';
import '../services/learning_playback_controller.dart';
import '../services/learning_progress_store.dart';
import '../utils/ui_utils.dart';
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
      '${_playlists.length} playlists for ${widget.className}, ${widget.subjectName}',
    );
  }

  Future<void> _create() async {
    final title = await _titleDialog('Create class playlist');
    if (title == null || title.isEmpty) return;
    final playlist = await ApiService.createTeacherPlaylist(
      title: title,
      classId: widget.classId,
      subjectId: widget.subjectId,
    );
    if (playlist == null) {
      TtsService.speak('Playlist could not be created');
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
        labels: const {0: 'Cancel', 1: 'Create'},
        actions: {
          0: () => Navigator.pop(dialogContext),
          1: () => Navigator.pop(dialogContext, controller.text.trim()),
        },
        navigationController: dialogKeypad,
        focusTargets: [
          KeypadFocusTarget(
            node: fieldNode,
            label: 'Playlist title',
            isTextField: true,
          ),
          KeypadFocusTarget(
            node: cancelNode,
            label: 'Cancel playlist creation',
            onActivate: () => Navigator.pop(dialogContext),
          ),
          KeypadFocusTarget(
            node: createNode,
            label: 'Create playlist',
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
            decoration: const InputDecoration(labelText: 'Playlist title'),
          ),
          actions: [
            TextButton(
              focusNode: cancelNode,
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel (0)'),
            ),
            FilledButton(
              focusNode: createNode,
              onPressed: () =>
                  Navigator.pop(dialogContext, controller.text.trim()),
              child: const Text('Create (1)'),
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
        label: 'Back',
        onActivate: () => Navigator.pop(context),
      ),
      KeypadFocusTarget(
        node: _refreshNode,
        label: 'Refresh playlists',
        onActivate: _load,
      ),
      KeypadFocusTarget(
        node: _createNode,
        label: 'Create playlist',
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
          label:
              '${playlist['title']}, ${playlist['item_count']} items, ${playlist['is_published'] == true ? 'published' : 'draft'}, ${playlist['is_archived'] == true ? 'archived' : 'active'}',
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
      screenName: 'Class Playlists, ${widget.className}, ${widget.subjectName}',
      labels: const {0: 'Back', 1: 'Refresh', 2: 'Create Playlist'},
      actions: {0: () => Navigator.pop(context), 1: _load, 2: _create},
      navigationController: _keypad,
      focusTargets: _targets(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('${widget.className} · ${widget.subjectName} Playlists'),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: UIUtils.paddingAll(context, 16),
                children: [
                  FilledButton.icon(
                    focusNode: _createNode,
                    onPressed: _create,
                    icon: const Icon(Icons.playlist_add),
                    label: const Text('2: Create playlist'),
                  ),
                  if (_playlists.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('No playlists in this class and subject.'),
                    ),
                  ..._playlists.map((entry) {
                    final playlist = Map<String, dynamic>.from(entry as Map);
                    final id = playlist['playlist_id'] as int;
                    return Card(
                      child: ListTile(
                        focusNode: _playlistNodes.putIfAbsent(
                          id,
                          () => FocusNode(debugLabel: 'teacher-playlist-$id'),
                        ),
                        leading: Icon(
                          playlist['is_published'] == true
                              ? Icons.public
                              : Icons.edit_note,
                        ),
                        title: Text('${playlist['title']}'),
                        subtitle: Text(
                          '${playlist['item_count']} items · ${playlist['is_archived'] == true
                              ? 'Archived'
                              : playlist['is_published'] == true
                              ? 'Published'
                              : 'Draft'}',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _open(id),
                      ),
                    );
                  }),
                ],
              ),
      ),
    );
  }
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
      '${_private.length} private playlists and ${_classPlaylists.length} class playlists',
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
        screenName: 'Create private playlist',
        labels: const {0: 'Cancel', 1: 'Create'},
        actions: {
          0: () => Navigator.pop(dialogContext),
          1: () => Navigator.pop(dialogContext, controller.text.trim()),
        },
        navigationController: dialogKeypad,
        focusTargets: [
          KeypadFocusTarget(
            node: fieldNode,
            label: 'Playlist title',
            isTextField: true,
          ),
          KeypadFocusTarget(
            node: cancelNode,
            label: 'Cancel',
            onActivate: () => Navigator.pop(dialogContext),
          ),
          KeypadFocusTarget(
            node: createNode,
            label: 'Create private playlist',
            onActivate: () =>
                Navigator.pop(dialogContext, controller.text.trim()),
          ),
        ],
        child: AlertDialog(
          title: const Text('Create private playlist'),
          content: TextField(
            controller: controller,
            focusNode: fieldNode,
            autofocus: true,
            onTap: () => dialogKeypad.enterTextEditing(fieldNode),
            decoration: const InputDecoration(labelText: 'Playlist title'),
          ),
          actions: [
            TextButton(
              focusNode: cancelNode,
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel (0)'),
            ),
            FilledButton(
              focusNode: createNode,
              onPressed: () =>
                  Navigator.pop(dialogContext, controller.text.trim()),
              child: const Text('Create (1)'),
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
      TtsService.speak('Private playlist could not be created');
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
        label: 'Back',
        onActivate: () => Navigator.pop(context),
      ),
      KeypadFocusTarget(
        node: _refreshNode,
        label: 'Refresh playlists',
        onActivate: _load,
      ),
      KeypadFocusTarget(
        node: _createNode,
        label: 'Create private playlist',
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
          label:
              '${playlist['title']}, private, ${playlist['item_count']} items',
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
          label:
              '${playlist['title']}, class playlist, ${playlist['subject_name']}, ${playlist['item_count']} items',
          onActivate: () => _openClass(id),
        ),
      );
    }
    return targets;
  }

  @override
  Widget build(BuildContext context) {
    return KeypadInstructionWrapper(
      screenName: 'My Playlists. Private playlists are visible only to you.',
      labels: const {0: 'Back', 1: 'Refresh', 2: 'Create Private Playlist'},
      actions: {0: () => Navigator.pop(context), 1: _load, 2: _create},
      navigationController: _keypad,
      focusTargets: _targets(),
      child: Scaffold(
        appBar: AppBar(title: const Text('My Playlists')),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: UIUtils.paddingAll(context, 16),
                children: [
                  Semantics(
                    label: 'Private. Only you can see your playlist contents.',
                    child: Card(
                      child: ListTile(
                        leading: const Icon(Icons.lock),
                        title: const Text('Your playlists are private'),
                        subtitle: const Text(
                          'Teachers, administrators, and other students cannot view them.',
                        ),
                      ),
                    ),
                  ),
                  FilledButton.icon(
                    focusNode: _createNode,
                    onPressed: _create,
                    icon: const Icon(Icons.playlist_add),
                    label: const Text('2: Create private playlist'),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'My private playlists',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  ..._private.map((entry) => _playlistTile(entry, true)),
                  const SizedBox(height: 16),
                  Text(
                    'Class playlists',
                    style: Theme.of(context).textTheme.titleLarge,
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
    return Card(
      child: ListTile(
        focusNode: _nodes.putIfAbsent(key, () => FocusNode(debugLabel: key)),
        leading: Icon(private ? Icons.lock_outline : Icons.school_outlined),
        title: Text('${playlist['title']}'),
        subtitle: Text(
          private
              ? 'Private · ${playlist['item_count']} items'
              : '${playlist['class_name']} · ${playlist['subject_name']} · ${playlist['item_count']} items',
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => private ? _openPrivate(id) : _openClass(id),
      ),
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
        throw const LearningStorageException(
          'Wait for the playlist player before opening study notes.',
        );
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
    TtsService.speak(message, priority: SpeechPriority.critical);
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
      _learningIssue(
        'Could not refresh this playlist. Check your connection and try again. Existing playback and saved progress have not been changed.',
      );
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
      });
      _learningIssue(
        'The current lesson is no longer available in this playlist. Playback stopped. Your saved progress and bookmarks are kept.',
      );
      return;
    }
    final state = _teacher
        ? (playlist['is_archived'] == true
              ? 'archived'
              : playlist['is_published'] == true
              ? 'published'
              : 'draft')
        : widget.mode == PlaylistMode.studentPrivate
        ? 'private'
        : 'published class playlist';
    TtsService.speak(
      '${playlist['title']}. ${playlist['class_name'] ?? ''} ${playlist['subject_name'] ?? ''}. ${_items.length} items. $state.',
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
      TtsService.speak('No eligible audio is available to add');
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
        screenName: 'Add audio to playlist',
        labels: const {0: 'Cancel'},
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
          title: const Text('Add audio'),
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
      TtsService.speak('Audio added to playlist');
    }
  }

  Future<void> _selectAndPlay(int index) async {
    if (index < 0 || index >= _items.length) return;
    if (_playPending) {
      TtsService.speak('Please wait for the lesson player.');
      return;
    }
    final item = _items[index];
    if (item['available'] == false) {
      TtsService.speak(
        '${item['title']} is no longer available in your current class. You can remove it from this playlist.',
      );
      return;
    }
    final streamPath = item['stream_path']?.toString();
    if (streamPath == null || streamPath.isEmpty) {
      TtsService.speak('${item['title']} is unavailable');
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
      setState(() => _playing = true);
      final duration = await _player.getDuration();
      if (!mounted || revision != _playRevision) return;
      if (duration != null) _learning.updateDuration(duration);
      TtsService.speak(
        'Playing ${item['title']}. Item ${index + 1} of ${_items.length}. '
        'Position ${learningTime(_learning.position)}.',
      );
    } on Exception catch (error) {
      debugPrint('[LEARNING] Playlist playback failed (${error.runtimeType})');
      if (!mounted || revision != _playRevision) return;
      _learning.abort();
      setState(() => _playing = false);
      _learningIssue(
        'Could not play this lesson. Check your connection and try again.',
      );
    } finally {
      settled.complete();
      if (mounted && revision == _playRevision) {
        setState(() => _playPending = false);
      }
    }
  }

  Future<void> _playPause() async {
    if (_playPending) {
      TtsService.speak('Please wait for the lesson player.');
      return;
    }
    if (_items.isEmpty) {
      TtsService.speak('Playlist is empty');
      return;
    }
    if (_playing) {
      await _player.pause();
      if (mounted) setState(() => _playing = false);
      await _learning.flush();
      TtsService.speak('Paused');
    } else {
      if (_player.state == PlayerState.paused && _learning.ready) {
        await _player.resume();
        if (mounted) setState(() => _playing = true);
        TtsService.speak('Playback resumed');
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
      TtsService.speak('Please wait for the lesson player.');
      return;
    }
    if (_items.isEmpty) return;
    if (_selectedIndex >= _items.length - 1) {
      await _player.pause();
      await _learning.flush();
      _learning.abort();
      await _player.stop();
      if (mounted) setState(() => _playing = false);
      TtsService.speak('End of playlist');
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
        screenName: 'Rename playlist',
        labels: const {0: 'Cancel', 1: 'Save'},
        actions: {
          0: () => Navigator.pop(dialogContext),
          1: () => Navigator.pop(dialogContext, controller.text.trim()),
        },
        navigationController: dialogKeypad,
        focusTargets: [
          KeypadFocusTarget(
            node: fieldNode,
            label: 'Playlist title',
            isTextField: true,
          ),
          KeypadFocusTarget(
            node: cancelNode,
            label: 'Cancel rename',
            onActivate: () => Navigator.pop(dialogContext),
          ),
          KeypadFocusTarget(
            node: saveNode,
            label: 'Save playlist title',
            onActivate: () =>
                Navigator.pop(dialogContext, controller.text.trim()),
          ),
        ],
        child: AlertDialog(
          title: const Text('Rename playlist'),
          content: TextField(
            controller: controller,
            focusNode: fieldNode,
            autofocus: true,
            onTap: () => dialogKeypad.enterTextEditing(fieldNode),
            decoration: const InputDecoration(labelText: 'Playlist title'),
          ),
          actions: [
            TextButton(
              focusNode: cancelNode,
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel (0)'),
            ),
            FilledButton(
              focusNode: saveNode,
              onPressed: () =>
                  Navigator.pop(dialogContext, controller.text.trim()),
              child: const Text('Save (1)'),
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
      TtsService.speak('Playlist renamed to $title');
    }
  }

  Future<void> _move(int delta) async {
    if (!_editable || _items.length < 2) return;
    final destination = _selectedIndex + delta;
    if (destination < 0 || destination >= _items.length) return;
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
      TtsService.speak('Item moved to position ${destination + 1}');
    }
  }

  Future<void> _remove(int itemId, String title) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => KeypadConfirmationDialog(
        title: 'Remove audio?',
        message: 'Remove $title from this playlist?',
        cancelLabel: 'Keep',
        confirmLabel: 'Remove',
        cancelKey: 0,
        confirmKey: 1,
      ),
    );
    if (confirmed != true) return;
    final removed = _teacher
        ? await ApiService.removeTeacherPlaylistItem(widget.playlistId, itemId)
        : await ApiService.removeStudentPlaylistItem(widget.playlistId, itemId);
    if (removed) {
      await _load();
      TtsService.speak('Audio removed');
    }
  }

  Future<void> _publish() async {
    if (!_teacher || _playlist == null) return;
    final publishing = _playlist!['is_published'] != true;
    final result = await ApiService.setTeacherPlaylistPublished(
      widget.playlistId,
      publishing,
    );
    if (result != null) {
      await _load();
      TtsService.speak(
        publishing
            ? 'Playlist published to the class'
            : 'Playlist returned to draft',
      );
    }
  }

  Future<void> _archiveOrDelete() async {
    if (_playlist == null || !_editable) return;
    final deleting = widget.mode == PlaylistMode.studentPrivate;
    final restoring = _teacher && _playlist!['is_archived'] == true;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => KeypadConfirmationDialog(
        title: deleting
            ? 'Delete private playlist?'
            : restoring
            ? 'Restore class playlist?'
            : 'Archive class playlist?',
        message: deleting
            ? 'This removes the private playlist and its ordered items.'
            : restoring
            ? 'This returns the playlist to draft so it can be edited and published again.'
            : 'Students will no longer see this playlist. Teacher history is retained.',
        cancelLabel: 'Cancel',
        confirmLabel: deleting
            ? 'Delete'
            : restoring
            ? 'Restore'
            : 'Archive',
        cancelKey: 0,
        confirmKey: 1,
      ),
    );
    if (confirmed != true) return;
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
            ? 'Private playlist deleted'
            : restoring
            ? 'Class playlist restored as a draft'
            : 'Class playlist archived',
      );
      if (deleting) {
        Navigator.pop(context);
      } else {
        await _load();
      }
    }
  }

  List<KeypadFocusTarget> _targets() {
    final targets = <KeypadFocusTarget>[
      KeypadFocusTarget(
        node: _backNode,
        label: 'Back',
        onActivate: () => Navigator.pop(context),
      ),
      KeypadFocusTarget(
        node: _refreshNode,
        label: 'Refresh playlist',
        onActivate: _load,
      ),
      if (_editable)
        KeypadFocusTarget(
          node: _editNode,
          label: 'Rename playlist',
          onActivate: _rename,
        ),
      if (_editable)
        KeypadFocusTarget(node: _addNode, label: 'Add audio', onActivate: _add),
      KeypadFocusTarget(
        node: _playNode,
        label: _playing ? 'Pause' : 'Play',
        onActivate: _playPause,
      ),
      KeypadFocusTarget(
        node: _previousNode,
        label: 'Previous item',
        onActivate: _previous,
      ),
      KeypadFocusTarget(node: _nextNode, label: 'Next item', onActivate: _next),
      KeypadFocusTarget(
        node: _downloadsNode,
        label:
            'Download playlist recordings. Select individually or confirm all listed recordings',
        onActivate: _openDownloads,
      ),
      if (_learning.lesson != null) ..._learningControls.focusTargets(context),
      if (_teacher && _playlist?['is_archived'] != true)
        KeypadFocusTarget(
          node: _publishNode,
          label: _playlist?['is_published'] == true
              ? 'Return playlist to draft'
              : 'Publish playlist',
          onActivate: _publish,
        ),
      if (_editable)
        KeypadFocusTarget(
          node: _archiveNode,
          label: _teacher
              ? (_playlist?['is_archived'] == true
                    ? 'Restore playlist'
                    : 'Archive playlist')
              : 'Delete private playlist',
          onActivate: _archiveOrDelete,
        ),
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
          label:
              '${item['title']}, ${item['subject_name'] ?? ''}, item ${index + 1} of ${_items.length}${item['available'] == false ? ', unavailable in your current class' : ''}',
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
            label: 'Remove ${item['title']} from playlist',
            onActivate: () => _remove(itemId, '${item['title']}'),
          ),
        );
      }
    }
    return targets;
  }

  @override
  Widget build(BuildContext context) {
    final labels = <int, String>{
      0: 'Back',
      1: 'Refresh',
      if (_editable) 2: 'Add Audio',
      3: 'Play or Pause',
      4: 'Previous',
      5: 'Next',
      if (_teacher && _playlist?['is_archived'] != true) 6: 'Publish or Draft',
      if (_editable)
        7: _teacher
            ? (_playlist?['is_archived'] == true ? 'Restore' : 'Archive')
            : 'Delete Private Playlist',
      if (_editable) 8: 'Move Selected Item Up',
      if (_editable) 9: 'Move Selected Item Down',
    };
    return KeypadInstructionWrapper(
      screenName: _playlist == null
          ? 'Playlist'
          : '${_playlist!['title']} playlist',
      labels: labels,
      actions: {
        0: () => Navigator.pop(context),
        1: _load,
        if (_editable) 2: _add,
        3: _playPause,
        4: _previous,
        5: _next,
        if (_teacher && _playlist?['is_archived'] != true) 6: _publish,
        if (_editable) 7: _archiveOrDelete,
        if (_editable) 8: () => _move(-1),
        if (_editable) 9: () => _move(1),
      },
      navigationController: _keypad,
      focusTargets: _targets(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('${_playlist?['title'] ?? 'Playlist'}'),
          actions: [
            if (_editable)
              IconButton(
                focusNode: _editNode,
                onPressed: _rename,
                tooltip: 'Rename playlist',
                icon: const Icon(Icons.edit_outlined),
              ),
          ],
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _playlist == null
            ? const Center(child: Text('Playlist is unavailable.'))
            : ListView(
                padding: UIUtils.paddingAll(context, 16),
                children: [
                  Card(
                    child: ListTile(
                      leading: Icon(
                        widget.mode == PlaylistMode.studentPrivate
                            ? Icons.lock
                            : Icons.playlist_play,
                      ),
                      title: Text('${_playlist!['title']}'),
                      subtitle: Text(
                        [
                          if (_playlist!['class_name'] != null)
                            '${_playlist!['class_name']}',
                          if (_playlist!['subject_name'] != null)
                            '${_playlist!['subject_name']}',
                          '${_items.length} items',
                          if (_teacher)
                            _playlist!['is_published'] == true
                                ? 'Published'
                                : 'Draft',
                          if (widget.mode == PlaylistMode.studentPrivate)
                            'Private',
                        ].join(' · '),
                      ),
                    ),
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (_editable)
                        OutlinedButton.icon(
                          focusNode: _addNode,
                          onPressed: _add,
                          icon: const Icon(Icons.add),
                          label: const Text('2 Add'),
                        ),
                      FilledButton.icon(
                        focusNode: _playNode,
                        onPressed: _playPause,
                        icon: Icon(_playing ? Icons.pause : Icons.play_arrow),
                        label: Text(_playing ? '3 Pause' : '3 Play'),
                      ),
                      OutlinedButton(
                        focusNode: _previousNode,
                        onPressed: _previous,
                        child: const Text('4 Previous'),
                      ),
                      OutlinedButton(
                        focusNode: _nextNode,
                        onPressed: _next,
                        child: const Text('5 Next'),
                      ),
                      if (_teacher && _playlist!['is_archived'] != true)
                        OutlinedButton(
                          focusNode: _publishNode,
                          onPressed: _publish,
                          child: Text(
                            _playlist!['is_published'] == true
                                ? '6 Make draft'
                                : '6 Publish',
                          ),
                        ),
                      if (_editable)
                        OutlinedButton(
                          focusNode: _archiveNode,
                          onPressed: _archiveOrDelete,
                          child: Text(
                            _teacher
                                ? _playlist!['is_archived'] == true
                                      ? '7 Restore'
                                      : '7 Archive'
                                : '7 Delete',
                          ),
                        ),
                    ],
                  ),
                  if (_learning.lesson != null) _learningControls,
                  OutlinedButton(
                    focusNode: _downloadsNode,
                    onPressed: _openDownloads,
                    child: const Text('Download playlist recordings'),
                  ),
                  if (_editable && _items.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'Select an item, then press 8 to move up or 9 to move down.',
                      ),
                    ),
                  if (_items.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('This playlist has no audio yet.'),
                    ),
                  ...List.generate(_items.length, (index) {
                    final item = _items[index];
                    final itemId = item['item_id'] as int;
                    final selected = index == _selectedIndex;
                    final available = item['available'] != false;
                    return Card(
                      color: selected
                          ? UIUtils.accentColor.withValues(alpha: 0.18)
                          : UIUtils.cardColor,
                      child: ListTile(
                        focusNode: _itemNodes.putIfAbsent(
                          itemId,
                          () => FocusNode(debugLabel: 'playlist-item-$itemId'),
                        ),
                        leading: CircleAvatar(child: Text('${index + 1}')),
                        title: Text(
                          available
                              ? '${item['title']}'
                              : '${item['title']} (Unavailable)',
                        ),
                        subtitle: Text(
                          '${item['subject_name'] ?? ''}${selected ? ' · Selected' : ''}',
                        ),
                        onTap: available
                            ? () => _selectAndPlay(index)
                            : () => TtsService.speak(
                                '${item['title']} is unavailable in your current class',
                              ),
                        trailing: _editable
                            ? IconButton(
                                focusNode: _removeNodes.putIfAbsent(
                                  itemId,
                                  () => FocusNode(
                                    debugLabel: 'playlist-remove-$itemId',
                                  ),
                                ),
                                tooltip: 'Remove',
                                onPressed: () =>
                                    _remove(itemId, '${item['title']}'),
                                icon: const Icon(Icons.remove_circle_outline),
                              )
                            : const Icon(Icons.play_arrow),
                      ),
                    );
                  }),
                ],
              ),
      ),
    );
  }
}
