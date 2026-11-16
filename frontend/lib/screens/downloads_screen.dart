import 'dart:async';
import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/offline_lesson_store.dart';
import '../services/tts_service.dart';
import '../services/undo_service.dart';
import '../services/message_center.dart';
import '../announcers/library_text.dart';
import '../l10n/speech.dart';
import '../utils/spoken_format.dart';
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
  // Removed downloads waiting for the undo window to close.
  static final _hidden = <int>{};
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
      _report(LibraryText.downloadsActionFailed);
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
        _lessons = records.lessons
            .where((lesson) => !_hidden.contains(lesson.audioId))
            .toList();
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
      final t = Speech.t;
      final message = _lessons.isEmpty
          ? t.downloadNoneYet
          : _lessons.length > complete
          ? t.downloadScreenLoadedWithPartial(
              '$complete',
              '${_lessons.length - complete}',
            )
          : t.downloadScreenLoaded('$complete');
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
      throw OfflineLessonException(LibraryText.onlineListFailed);
    }
    setState(
      () => _candidates = list.whereType<Map<String, dynamic>>().toList(),
    );
    await TtsService.speak(
      Speech.t.downloadAvailableCount('${_candidates.length}'),
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
      TtsService.speak(
        LibraryText.downloadProgress(_titleFor(_downloadingId), milestone),
      );
    }
  }

  String _titleFor(int? id) {
    for (final audio in _candidates) {
      if (audio['audio_id'] == id) return '${audio['title']}';
    }
    for (final lesson in _lessons) {
      if (lesson.audioId == id) return lesson.title;
    }
    return Speech.t.downloadRecordingFallback('$id');
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
        setState(() => _status = LibraryText.downloadVerified);
      }
      await TtsService.speak(LibraryText.downloaded(_titleFor(id)));
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
        title: Speech.t.downloadPackDialogTitle,
        message: Speech.t.downloadPackDialogMessage('${ids.length}'),
        confirmLabel: Speech.t.downloadPackConfirm,
        cancelLabel: Speech.t.downloadPackCancel,
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
              () => _status = LibraryText.packProgress(completed, ids.length),
            );
          }
        }
        if (mounted) {
          await TtsService.speak(LibraryText.packDone(completed, ids.length));
        }
      } on OfflineLessonException catch (error) {
        throw OfflineLessonException(
          '${LibraryText.packProgress(completed, ids.length)} ${error.message}',
        );
      } finally {
        await _readLocal();
      }
    });
  }

  Future<void> _renew(OfflineLesson lesson) => _run(() async {
    await _store!.renew(lesson.audioId);
    await _readLocal();
    await TtsService.speak(LibraryText.renewed(lesson.title));
  });

  Future<void> _remove(OfflineLesson lesson) =>
      _removeId(lesson.audioId, lesson.title);

  Future<void> _removeId(int id, String title) async {
    if (_busy) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => KeypadConfirmationDialog(
        title: LibraryText.removeDownloadTitle(title),
        message: LibraryText.removeDownloadQuestion(title),
        confirmLabel: Speech.t.downloadRemoveConfirm,
        cancelLabel: Speech.t.downloadKeep,
      ),
    );
    if (confirmed != true || !mounted) {
      if (mounted) _node('remove-$id').requestFocus();
      return;
    }
    final store = _store!;
    if (_unreadableIds.contains(id)) {
      // A damaged record has nothing to restore; remove it at once.
      await _run(() async {
        await store.remove(id);
        await _readLocal();
        MessageCenter.success(LibraryText.downloadRemoved(title));
      });
      if (mounted) _node('refresh').requestFocus();
      return;
    }
    // Hidden now; the file is deleted only when the undo window closes.
    setState(() {
      _hidden.add(id);
      _lessons = _lessons.where((lesson) => lesson.audioId != id).toList();
    });
    if (mounted) _node('refresh').requestFocus();
    await UndoService.offer(
      done: LibraryText.downloadRemoved(title),
      undo: () async {
        _hidden.remove(id);
        if (mounted) await _readLocal();
      },
      commit: () async {
        try {
          await store.remove(id);
        } finally {
          _hidden.remove(id);
        }
      },
    );
  }

  Future<void> _play(OfflineLesson lesson) async {
    if (_busy) return;
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => ClassAudioScreen(
          sessionId: 0,
          sessionTitle: Speech.t.downloadScreenName,
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
        builder: (_) => KeypadConfirmationDialog(
          title: Speech.t.downloadCancelBackTitle,
          message: Speech.t.downloadCancelBackMessage,
          confirmLabel: Speech.t.downloadCancelBackConfirm,
          cancelLabel: Speech.t.downloadKeepDownloading,
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

  String _date(DateTime value) => SpokenFormat.date(value);

  @override
  Widget build(BuildContext context) {
    final t = Speech.t;
    final storageStatus = _reservedBytes == null
        ? LibraryText.storageUnknown
        : t.downloadReserved((_reservedBytes! / 1000000).toStringAsFixed(2));
    final progress = _operation;
    final percent = progress == null || progress.total <= 0
        ? null
        : (progress.received * 100 ~/ progress.total).clamp(0, 100);
    final targets = <KeypadFocusTarget>[
      KeypadFocusTarget(
        node: _node('back'),
        label: t.downloadBack,
        onActivate: _back,
      ),
      KeypadFocusTarget(
        node: _node('refresh'),
        label: t.downloadRefreshLabel,
        isEnabled: () => !_busy,
        onActivate: _load,
      ),
      KeypadFocusTarget(
        node: _node('online'),
        label: t.downloadFindOnlineLabel,
        isEnabled: () => !_busy,
        onActivate: _onlineList,
      ),
      KeypadFocusTarget(
        node: _node('status'),
        label: t.downloadReadStatusLabel,
        onActivate: () => TtsService.speak(
          '$storageStatus $_status ${_issue ?? ''} '
          '${progress == null ? '' : LibraryText.downloadProgress(_titleFor(_downloadingId), percent ?? 0)}',
        ),
      ),
      if (progress != null)
        KeypadFocusTarget(
          node: _node('cancel'),
          label: LibraryText.cancelDownloadLabel(_titleFor(_downloadingId)),
          onActivate: progress.cancel,
        ),
      for (final id in _unreadableIds)
        KeypadFocusTarget(
          node: _node('remove-$id'),
          label: LibraryText.unreadableLabel(id),
          isEnabled: () => !_busy,
          onActivate: () => _removeId(id, LibraryText.unreadableTitle(id)),
        ),
      for (final lesson in _lessons) ...[
        KeypadFocusTarget(
          node: _node('play-${lesson.audioId}'),
          label: lesson.complete
              ? t.downloadPlayDownloadedLabel(lesson.title)
              : t.downloadPlayPartialLabel(lesson.title),
          isEnabled: () => !_busy && lesson.complete,
          onActivate: () => _play(lesson),
        ),
        KeypadFocusTarget(
          node: _node('renew-${lesson.audioId}'),
          label: LibraryText.renewLabel(lesson.title),
          isEnabled: () => !_busy,
          onActivate: () => _renew(lesson),
        ),
        KeypadFocusTarget(
          node: _node('remove-${lesson.audioId}'),
          label: LibraryText.removeDownloadLabel(lesson.title),
          isEnabled: () => !_busy,
          onActivate: () => _remove(lesson),
        ),
      ],
      if (_candidates.isNotEmpty)
        KeypadFocusTarget(
          node: _node('pack'),
          label: t.downloadPackLabel,
          isEnabled: () => !_busy,
          onActivate: _pack,
        ),
      for (final audio in _candidates)
        if (audio['audio_id'] is int)
          KeypadFocusTarget(
            node: _node('download-${audio['audio_id']}'),
            label: LibraryText.downloadLabel('${audio['title']}'),
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
      screenName: t.downloadScreenName,
      introduction: t.downloadIntroduction,
      navigationSections: t.downloadNavigationSections,
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
              TtsService.speak(LibraryText.unavailableWhileBusy(target.label));
            }
          },
      },
      labels: {
        0: t.downloadBack,
        1: t.downloadKeyRefresh,
        2: t.downloadKeyFindOnline,
        3: t.downloadKeyReadStatus,
        if (progress != null) 4: t.downloadKeyCancel,
        if (_candidates.isNotEmpty) 5: t.downloadKeyPack,
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
              tooltip: Speech.t.settingsBack,
              onPressed: _back,
              icon: const Icon(Icons.arrow_back),
            ),
            title: Text(Speech.t.downloadTitle),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '$storageStatus ${Speech.t.downloadPartialReserve}',
                  style: textStyle,
                ),
                Text(
                  Speech.t.downloadAccessInfo,
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
                button('refresh', Speech.t.downloadRefreshKey1),
                button('online', Speech.t.downloadFindOnlineKey2),
                button('status', Speech.t.downloadReadStatusKey3),
                if (progress != null) ...[
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      percent == null
                          ? Speech.t.downloadProgressStarting(
                              _titleFor(_downloadingId),
                            )
                          : Speech.t.downloadPercentDone(
                              _titleFor(_downloadingId),
                              '${percent ~/ 25 * 25}',
                            ),
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
                  button('cancel', Speech.t.downloadCancelKey4),
                ],
                for (final id in _unreadableIds) ...[
                  Text(
                    Speech.t.downloadRecordUnreadable('$id'),
                    style: textStyle.copyWith(color: UIUtils.errorColor),
                  ),
                  button(
                    'remove-$id',
                    Speech.t.downloadRemoveUnreadable('$id'),
                  ),
                ],
                if (_lessons.isEmpty && !_loading)
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      Speech.t.downloadNoneYetFindOnline,
                      style: textStyle,
                    ),
                  ),
                for (final lesson in _lessons)
                  AccessibleTile(
                    leadingIcon: lesson.complete
                        ? Icons.download_done
                        : Icons.downloading,
                    title: lesson.title,
                    status: lesson.complete
                        ? Speech.t.downloadStatusDownloaded
                        : Speech.t.downloadStatusPartial,
                    statusColor: lesson.complete
                        ? UIUtils.successColor
                        : UIUtils.errorColor,
                    subtitle: lesson.revoked
                        ? Speech.t.downloadSizeRenewal(
                            (lesson.bytes / 1000000).toStringAsFixed(2),
                          )
                        : Speech.t.downloadSizeExpires(
                            (lesson.bytes / 1000000).toStringAsFixed(2),
                            _date(lesson.expiresAt),
                          ),
                    trailing: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        button(
                          'play-${lesson.audioId}',
                          Speech.t.downloadPlayLesson,
                        ),
                        button(
                          'renew-${lesson.audioId}',
                          Speech.t.downloadRenewOnline,
                        ),
                        button(
                          'remove-${lesson.audioId}',
                          Speech.t.downloadRemove,
                        ),
                      ],
                    ),
                  ),
                if (_candidates.isNotEmpty) ...[
                  button('pack', Speech.t.downloadListedKey5),
                  Text(Speech.t.downloadAvailableInfo, style: textStyle),
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
