import 'dart:async';
import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/offline_lesson_store.dart';
import '../services/tts_service.dart';
import '../widgets/key_instruction_wrapper.dart';
import '../widgets/keypad_confirmation_dialog.dart';
import 'audio_library_screen.dart';

class DownloadsScreen extends StatefulWidget {
  const DownloadsScreen({super.key, this.candidates = const []});
  final List<Map<String, dynamic>> candidates;
  @override
  State<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen> {
  final _nodes = <String, FocusNode>{};
  OfflineLessonStore? _store;
  List<OfflineLesson> _lessons = [];
  List<int> _unreadableIds = [];
  int? _reservedBytes;
  late List<Map<String, dynamic>> _candidates;
  OfflineDownload? _operation;
  int? _downloadingId;
  bool _loading = true;
  bool _busy = false;
  String? _issue;
  String _status = '';
  FocusNode _node(String key) =>
      _nodes.putIfAbsent(key, () => FocusNode(debugLabel: 'downloads-$key'));

  @override
  void initState() {
    super.initState();
    _candidates = widget.candidates;
    unawaited(_load());
  }

  void _report(String message) {
    if (!mounted) return;
    setState(() => _issue = message);
    TtsService.speak(message, priority: SpeechPriority.critical);
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _issue = null;
    });
    try {
      await action();
    } on OfflineLessonException catch (error) {
      _report(error.message);
    } on Exception catch (error) {
      debugPrint(
        '[OFFLINE] Download screen operation failed (${error.runtimeType})',
      );
      _report(
        'Could not complete this download action. Check storage, your connection and sign-in, then retry.',
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _readLocal() async {
    final store = _store ??= await OfflineLessonStore.forCurrentUser();
    final records = await store.inspectRecords();
    final reserved = records.unreadableIds.isEmpty
        ? await store.reservedBytes()
        : null;
    if (mounted) {
      setState(() {
        _lessons = records.lessons;
        _unreadableIds = records.unreadableIds;
        _reservedBytes = reserved;
        _loading = false;
      });
    }
  }

  Future<void> _load() => _run(() async {
    try {
      await _readLocal();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  });

  Future<void> _onlineList() => _run(() async {
    final store = _store ??= await OfflineLessonStore.forCurrentUser();
    final list = await ApiService.getAudioList();
    await store.credentials();
    if (!mounted) return;
    if (list == null) {
      throw const OfflineLessonException(
        'Could not load available recordings. Existing downloads still work until their access expires.',
      );
    }
    setState(
      () => _candidates = list.whereType<Map<String, dynamic>>().toList(),
    );
    await TtsService.speak(
      '${_candidates.length} recordings are available to download. Select the recordings you want.',
    );
  });

  void _progressChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _transfer(int id) async {
    final operation = OfflineDownload();
    _operation = operation;
    _downloadingId = id;
    operation.addListener(_progressChanged);
    if (mounted) setState(() {});
    try {
      final store = _store ??= await OfflineLessonStore.forCurrentUser();
      await store.download(id, operation);
    } finally {
      operation.removeListener(_progressChanged);
      _operation = null;
      _downloadingId = null;
      operation.dispose();
      if (mounted) setState(() {});
    }
  }

  Future<void> _download(int id) => _run(() async {
    try {
      await _transfer(id);
      if (mounted) {
        setState(
          () => _status = 'Download verified and saved for offline playback.',
        );
      }
      await TtsService.speak(
        'Download verified and saved for offline playback.',
      );
    } finally {
      await _readLocal();
    }
  });

  Future<void> _pack() async {
    if (_busy || _candidates.isEmpty) return;
    final ids = _candidates
        .map((entry) => entry['audio_id'])
        .whereType<int>()
        .toSet()
        .toList();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => KeypadConfirmationDialog(
        title: 'Download listed recordings?',
        message:
            'Download ${ids.length} listed recordings one at a time? This uses internet data and your account’s 50 MB allowance. On failure or cancellation, verified downloads and partial data are kept. No existing lesson is deleted.',
        confirmLabel: 'Download listed',
        cancelLabel: 'Choose individually',
      ),
    );
    if (confirmed != true || !mounted) return;
    await _run(() async {
      var completed = 0;
      try {
        for (final id in ids) {
          if (!mounted) break;
          await _transfer(id);
          completed++;
          if (mounted) {
            setState(
              () =>
                  _status = '$completed of ${ids.length} recordings verified.',
            );
          }
        }
        if (mounted) {
          await TtsService.speak(
            '$completed of ${ids.length} recordings verified and saved.',
          );
        }
      } on OfflineLessonException catch (error) {
        throw OfflineLessonException(
          '$completed of ${ids.length} recordings verified. ${error.message}',
        );
      } finally {
        await _readLocal();
      }
    });
  }

  Future<void> _renew(OfflineLesson lesson) => _run(() async {
    await _store!.renew(lesson.audioId);
    await _readLocal();
    await TtsService.speak(
      'Access renewed for ${lesson.title}. Up to 30 days of offline playback.',
    );
  });

  Future<void> _remove(OfflineLesson lesson) =>
      _removeId(lesson.audioId, lesson.title);

  Future<void> _removeId(int id, String title) async {
    if (_busy) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => KeypadConfirmationDialog(
        title: 'Remove this download?',
        message:
            'Remove the downloaded or partial audio for $title? Learning progress and bookmarks are kept. Other recordings and accounts are not affected.',
        confirmLabel: 'Remove download',
        cancelLabel: 'Keep download',
      ),
    );
    if (confirmed != true || !mounted) return;
    await _run(() async {
      await _store!.remove(id);
      await _readLocal();
      await TtsService.speak(
        'Selected download removed. Progress and bookmarks kept.',
      );
    });
    if (mounted) _node('refresh').requestFocus();
  }

  Future<void> _play(OfflineLesson lesson) async {
    if (_busy) return;
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => ClassAudioScreen(
          sessionId: 0,
          sessionTitle: 'Downloaded Lessons',
          initialAudioId: lesson.audioId,
          downloadedOnly: true,
        ),
      ),
    );
    if (mounted) await _load();
  }

  Future<void> _back() async {
    if (_operation != null) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (_) => const KeypadConfirmationDialog(
          title: 'Cancel download and go back?',
          message:
              'Stop this download? Verified recordings and partial data are kept for an explicit retry.',
          confirmLabel: 'Cancel and go back',
          cancelLabel: 'Keep downloading',
        ),
      );
      if (confirmed != true || !mounted) return;
      _operation?.cancel();
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _operation?.removeListener(_progressChanged);
    _operation?.cancel();
    for (final node in _nodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final storageStatus = _reservedBytes == null
        ? 'Storage reservation unavailable. Refresh downloads or remove the selected unreadable records before downloading.'
        : '${(_reservedBytes! / 1000000).toStringAsFixed(2)} of 50 MB reserved for this account.';
    final progress = _operation;
    final targets = <KeypadFocusTarget>[
      KeypadFocusTarget(node: _node('back'), label: 'Back', onActivate: _back),
      KeypadFocusTarget(
        node: _node('refresh'),
        label: 'Refresh saved downloads',
        isEnabled: () => !_busy,
        onActivate: _load,
      ),
      KeypadFocusTarget(
        node: _node('online'),
        label: 'Find recordings to download. Requires internet',
        isEnabled: () => !_busy,
        onActivate: _onlineList,
      ),
      KeypadFocusTarget(
        node: _node('status'),
        label: 'Read download status',
        onActivate: () => TtsService.speak(
          '$storageStatus $_status ${_issue ?? ''} '
          '${progress == null ? '' : '${progress.received} of ${progress.total} bytes received.'}',
        ),
      ),
      if (progress != null)
        KeypadFocusTarget(
          node: _node('cancel'),
          label: 'Cancel download. Keep partial data for retry',
          onActivate: progress.cancel,
        ),
      if (_candidates.isNotEmpty)
        KeypadFocusTarget(
          node: _node('pack'),
          label: 'Download all listed recordings with confirmation',
          isEnabled: () => !_busy,
          onActivate: _pack,
        ),
      for (final id in _unreadableIds)
        KeypadFocusTarget(
          node: _node('remove-$id'),
          label:
              'Unreadable download record $id. Remove only this download with confirmation',
          isEnabled: () => !_busy,
          onActivate: () => _removeId(id, 'unreadable recording $id'),
        ),
      for (final lesson in _lessons) ...[
        KeypadFocusTarget(
          node: _node('play-${lesson.audioId}'),
          label:
              'Play downloaded ${lesson.title}. ${lesson.complete ? 'Verified download' : 'Incomplete download'}',
          isEnabled: () => !_busy && lesson.complete,
          onActivate: () => _play(lesson),
        ),
        KeypadFocusTarget(
          node: _node('renew-${lesson.audioId}'),
          label: 'Renew access for ${lesson.title}. Requires internet',
          isEnabled: () => !_busy,
          onActivate: () => _renew(lesson),
        ),
        KeypadFocusTarget(
          node: _node('remove-${lesson.audioId}'),
          label: 'Remove downloaded ${lesson.title}. Requires confirmation',
          isEnabled: () => !_busy,
          onActivate: () => _remove(lesson),
        ),
      ],
      for (final audio in _candidates)
        if (audio['audio_id'] is int)
          KeypadFocusTarget(
            node: _node('download-${audio['audio_id']}'),
            label: 'Download or resume ${audio['title']}',
            isEnabled: () => !_busy,
            onActivate: () => _download(audio['audio_id'] as int),
          ),
    ];
    Widget button(String id, String label) {
      final target = targets.firstWhere((target) => target.node == _node(id));
      return OutlinedButton(
        focusNode: target.node,
        onPressed: target.isEnabled?.call() == false ? null : target.onActivate,
        child: Text(label),
      );
    }

    return KeypadInstructionWrapper(
      screenName:
          'Downloaded Lessons. 50 MB per account. Up to 30 days offline before online access renewal. Files and progress stay separate.',
      navigationSections:
          'saved files to play, renew or remove, and online recordings to download or resume',
      onHashKey: _back,
      actions: {
        0: _back,
        for (final (key, id) in [
          (1, 'refresh'),
          (2, 'online'),
          (3, 'status'),
          if (progress != null) (4, 'cancel'),
          if (_candidates.isNotEmpty) (5, 'pack'),
        ])
          key: () {
            final target = targets.firstWhere(
              (target) => target.node == _node(id),
            );
            if (target.enabled) {
              target.onActivate?.call();
            } else {
              TtsService.speak(
                '${target.label} is unavailable while downloads are busy.',
              );
            }
          },
      },
      labels: {
        0: 'Back',
        1: 'Refresh downloads',
        2: 'Find recordings online',
        3: 'Read status',
        if (progress != null) 4: 'Cancel download',
        if (_candidates.isNotEmpty) 5: 'Download listed recordings',
      },
      focusTargets: targets,
      child: PopScope(
        canPop: progress == null,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) unawaited(_back());
        },
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              focusNode: _node('back'),
              tooltip: 'Back',
              onPressed: _back,
              icon: const Icon(Icons.arrow_back),
            ),
            title: const Text('Downloads'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '$storageStatus Partial files reserve their complete size.',
                ),
                const Text(
                  '30-day offline access. Other accounts have separate allowances. No automatic deletion.',
                ),
                if (_loading) const LinearProgressIndicator(),
                if (_issue != null)
                  Semantics(liveRegion: true, child: Text(_issue!)),
                if (_status.isNotEmpty) Text(_status),
                for (final id in _unreadableIds) ...[
                  Text(
                    'Download record $id could not be read. Files are kept. Remove only this download to recover; progress and bookmarks are kept.',
                  ),
                  button('remove-$id', 'Remove unreadable download $id'),
                ],
                Wrap(
                  spacing: 8,
                  children: [
                    button('refresh', '1: Refresh downloads'),
                    button('online', '2: Find recordings online'),
                    button('status', '3: Read status'),
                  ],
                ),
                if (progress != null) ...[
                  Text(
                    'Recording $_downloadingId: ${progress.received} / ${progress.total} bytes',
                  ),
                  LinearProgressIndicator(
                    value: progress.total > 0
                        ? progress.received / progress.total
                        : null,
                  ),
                  button('cancel', '4: Cancel download'),
                ],
                if (_lessons.isEmpty && !_loading)
                  const Text(
                    'No downloads yet. Find recordings online or open Downloads from a class or playlist.',
                  ),
                for (final lesson in _lessons)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(lesson.title),
                          Text(
                            '${lesson.complete ? 'Downloaded' : 'Partial download'}. '
                            '${(lesson.bytes / 1000000).toStringAsFixed(2)} MB. '
                            '${lesson.revoked ? 'Access renewal required.' : 'Access expires ${lesson.expiresAt.toLocal()}.'}',
                          ),
                          button(
                            'play-${lesson.audioId}',
                            'Play downloaded lesson',
                          ),
                          button(
                            'renew-${lesson.audioId}',
                            'Renew access online',
                          ),
                          button('remove-${lesson.audioId}', 'Remove download'),
                        ],
                      ),
                    ),
                  ),
                if (_candidates.isNotEmpty) ...[
                  button('pack', '5: Download listed recordings'),
                  const Text(
                    'Available recordings. Downloads use internet data.',
                  ),
                  for (final audio in _candidates)
                    if (audio['audio_id'] is int)
                      button(
                        'download-${audio['audio_id']}',
                        'Download or resume ${audio['title']}',
                      ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
