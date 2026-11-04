import 'dart:async';
import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/offline_lesson_store.dart';
import '../services/tts_service.dart';
import '../utils/ui_utils.dart';
import '../widgets/accessible_tile.dart';
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
  int _lastMilestone = 0;
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
      if (!mounted) return;
      final complete = _lessons.where((lesson) => lesson.complete).length;
      final message = _lessons.isEmpty
          ? 'No downloads yet. Press 2 to find recordings online.'
          : '$complete downloaded lessons ready to play'
                '${_lessons.length > complete ? ', ${_lessons.length - complete} partial downloads' : ''}.';
      unawaited(TtsService.speak(message, priority: SpeechPriority.incidental));
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
    if (!mounted) return;
    setState(() {});
    final operation = _operation;
    if (operation == null || operation.total <= 0) return;
    final percent = (operation.received * 100 ~/ operation.total).clamp(0, 100);
    final milestone = percent ~/ 25 * 25;
    if (milestone > _lastMilestone) {
      _lastMilestone = milestone;
      TtsService.speak('${_titleFor(_downloadingId)} $milestone percent downloaded.');
    }
  }

  String _titleFor(int? id) {
    for (final audio in _candidates) {
      if (audio['audio_id'] == id) return '${audio['title']}';
    }
    for (final lesson in _lessons) {
      if (lesson.audioId == id) return lesson.title;
    }
    return 'Recording $id';
  }

  Future<void> _transfer(int id) async {
    final operation = OfflineDownload();
    _operation = operation;
    _downloadingId = id;
    _lastMilestone = 0;
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
        '${_titleFor(id)} downloaded, verified and saved for offline playback.',
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
        title: 'Remove download of $title?',
        message:
            'Remove the downloaded or partial audio for $title? Learning progress and bookmarks are kept. Other recordings and accounts are not affected.',
        confirmLabel: 'Remove download',
        cancelLabel: 'Keep download',
      ),
    );
    if (confirmed != true || !mounted) {
      if (mounted) _node('remove-$id').requestFocus();
      return;
    }
    await _run(() async {
      await _store!.remove(id);
      await _readLocal();
      await TtsService.speak(
        'Download of $title removed. Progress and bookmarks kept.',
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

  static const _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  String _date(DateTime value) {
    final local = value.toLocal();
    return '${local.day} ${_months[local.month - 1]} ${local.year}';
  }

  @override
  Widget build(BuildContext context) {
    final storageStatus = _reservedBytes == null
        ? 'Storage reservation unavailable. Refresh downloads or remove the selected unreadable records before downloading.'
        : '${(_reservedBytes! / 1000000).toStringAsFixed(2)} of 50 MB reserved for this account.';
    final progress = _operation;
    final percent = progress == null || progress.total <= 0
        ? null
        : (progress.received * 100 ~/ progress.total).clamp(0, 100);
    final targets = <KeypadFocusTarget>[
      KeypadFocusTarget(node: _node('back'), label: 'Back', onActivate: _back),
      KeypadFocusTarget(
        node: _node('refresh'),
        label: 'Refresh saved downloads, key 1',
        isEnabled: () => !_busy,
        onActivate: _load,
      ),
      KeypadFocusTarget(
        node: _node('online'),
        label: 'Find recordings to download, key 2. Requires internet',
        isEnabled: () => !_busy,
        onActivate: _onlineList,
      ),
      KeypadFocusTarget(
        node: _node('status'),
        label: 'Read download status, key 3',
        onActivate: () => TtsService.speak(
          '$storageStatus $_status ${_issue ?? ''} '
          '${progress == null ? '' : '${_titleFor(_downloadingId)} ${percent ?? 0} percent downloaded.'}',
        ),
      ),
      if (progress != null)
        KeypadFocusTarget(
          node: _node('cancel'),
          label:
              'Cancel download of ${_titleFor(_downloadingId)}, key 4. Keep partial data for retry',
          onActivate: progress.cancel,
        ),
      for (final id in _unreadableIds)
        KeypadFocusTarget(
          node: _node('remove-$id'),
          label:
              'Unreadable download record $id. Remove only this download, asks to confirm',
          isEnabled: () => !_busy,
          onActivate: () => _removeId(id, 'unreadable recording $id'),
        ),
      for (final lesson in _lessons) ...[
        KeypadFocusTarget(
          node: _node('play-${lesson.audioId}'),
          label:
              'Play ${lesson.title}. ${lesson.complete ? 'Downloaded' : 'Partial download, cannot play yet'}',
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
          label: 'Remove download of ${lesson.title}, asks to confirm',
          isEnabled: () => !_busy,
          onActivate: () => _remove(lesson),
        ),
      ],
      if (_candidates.isNotEmpty)
        KeypadFocusTarget(
          node: _node('pack'),
          label: 'Download all listed recordings, key 5, asks to confirm',
          isEnabled: () => !_busy,
          onActivate: _pack,
        ),
      for (final audio in _candidates)
        if (audio['audio_id'] is int)
          KeypadFocusTarget(
            node: _node('download-${audio['audio_id']}'),
            label: 'Download or resume ${audio['title']}',
            isEnabled: () => !_busy,
            onActivate: () => _download(audio['audio_id'] as int),
          ),
    ];
    final textStyle = TextStyle(color: UIUtils.textColor, fontSize: 16);
    Widget button(String id, String label) {
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
          child: Text(label, semanticsLabel: target.label),
        ),
      );
    }

    return KeypadInstructionWrapper(
      screenName: 'Downloaded Lessons',
      introduction:
          '50 MB per account. Up to 30 days offline before online access renewal. Files and progress stay separate.',
      navigationSections:
          'saved files to play, renew or remove, and online recordings to download or resume',
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
                  style: textStyle,
                ),
                Text(
                  '30-day offline access. Other accounts have separate allowances. No automatic deletion.',
                  style: textStyle.copyWith(color: UIUtils.subtextColor),
                ),
                if (_loading) const LinearProgressIndicator(),
                if (_issue != null)
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      _issue!,
                      style: textStyle.copyWith(
                        color: UIUtils.errorColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                if (_status.isNotEmpty)
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      _status,
                      style: textStyle.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                button('refresh', '1: Refresh downloads'),
                button('online', '2: Find recordings online'),
                button('status', '3: Read status'),
                if (progress != null) ...[
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      '${_titleFor(_downloadingId)}: '
                      '${percent == null ? 'starting' : '${percent ~/ 25 * 25} percent'} downloaded',
                      style: textStyle,
                    ),
                  ),
                  ExcludeSemantics(
                    child: LinearProgressIndicator(
                      minHeight: 8,
                      color: UIUtils.accentColor,
                      backgroundColor: UIUtils.cardBorderColor,
                      value: progress.total > 0
                          ? progress.received / progress.total
                          : null,
                    ),
                  ),
                  button('cancel', '4: Cancel download'),
                ],
                for (final id in _unreadableIds) ...[
                  Text(
                    'Download record $id could not be read. Files are kept. Remove only this download to recover; progress and bookmarks are kept.',
                    style: textStyle.copyWith(color: UIUtils.errorColor),
                  ),
                  button('remove-$id', 'Remove unreadable download $id'),
                ],
                if (_lessons.isEmpty && !_loading)
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      'No downloads yet. Find recordings online or open Downloads from a class or playlist.',
                      style: textStyle,
                    ),
                  ),
                for (final lesson in _lessons)
                  AccessibleTile(
                    leadingIcon: lesson.complete
                        ? Icons.download_done
                        : Icons.downloading,
                    title: lesson.title,
                    status: lesson.complete ? 'Downloaded' : 'Partial download',
                    statusColor: lesson.complete
                        ? UIUtils.successColor
                        : UIUtils.errorColor,
                    subtitle:
                        '${(lesson.bytes / 1000000).toStringAsFixed(2)} MB. '
                        '${lesson.revoked ? 'Access renewal required.' : 'Access expires on ${_date(lesson.expiresAt)}.'}',
                    trailing: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
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
                if (_candidates.isNotEmpty) ...[
                  button('pack', '5: Download listed recordings'),
                  Text(
                    'Available recordings. Downloads use internet data.',
                    style: textStyle,
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
