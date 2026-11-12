import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../../services/undo_service.dart';
import '../../services/message_center.dart';
import '../../services/feedback_cues.dart';
import '../../announcers/journey_text.dart';
import '../../services/journey_api.dart';
import '../../services/journey_models.dart';
import '../../services/offline_journey_store.dart';
import '../../services/offline_lesson_store.dart';
import '../../services/tts_service.dart';
import '../../widgets/journey_menu.dart';
import '../../widgets/journey_prompts.dart';
import 'journey_player_screen.dart';

typedef JourneyStoreOpener = Future<OfflineJourneyStore> Function();

/// Student home for learning journeys: five numbered choices, each opening a
/// short list or the most recent journey. Downloaded journeys open without
/// internet.
class StudentJourneysScreen extends StatefulWidget {
  const StudentJourneysScreen({
    super.key,
    this.api = const JourneyApi(),
    this.openStore = OfflineJourneyStore.forCurrentUser,
  });

  final JourneyApi api;
  final JourneyStoreOpener openStore;

  @override
  State<StudentJourneysScreen> createState() => _StudentJourneysScreenState();
}

class _StudentJourneysScreenState extends State<StudentJourneysScreen> {
  List<StudentJourneySummary> _journeys = [];
  List<JourneySnapshot> _downloaded = [];
  OfflineJourneyStore? _store;
  bool _busy = true;
  bool _online = false;
  String? _issue;
  String? _status;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load({bool announce = false}) async {
    setState(() {
      _busy = true;
      _issue = null;
    });
    try {
      _store ??= await widget.openStore();
    } on OfflineJourneyException catch (error) {
      _issue = error.message;
    } catch (error) {
      // Never leave the screen stuck on "please wait".
      debugPrint('[JOURNEY] Storage failed to open: $error');
      _issue = JourneyAnnouncer.storageUnavailable;
    }
    final store = _store;
    var sync = const JourneySyncReport();
    if (store != null) {
      try {
        sync = await store.syncPending(widget.api);
        _downloaded = await store.savedSnapshots();
      } catch (error) {
        debugPrint('[JOURNEY] Saved journeys unreadable: $error');
        _issue = JourneyAnnouncer.storageUnavailable;
      }
    }
    try {
      _journeys = await widget.api.studentJourneys();
      _online = true;
    } on JourneyApiException catch (error) {
      _online = false;
      _issue = error.network
          ? 'No internet. Downloaded journeys still work. Press 5 for downloaded journeys.'
          : error.message;
    }
    if (!mounted) return;
    final waiting = sync.remaining == 0
        ? ''
        : ' ${sync.remaining} finished ${sync.remaining == 1 ? 'journey is' : 'journeys are'} waiting to be sent.';
    setState(() {
      _busy = false;
      _status = _online ? '${_summary()}$waiting' : waiting.trim();
    });
    if (announce || _issue != null) {
      unawaited(TtsService.speak([_issue, _status].whereType<String>().join(' ')));
    }
  }

  Iterable<StudentJourneySummary> _with(String status) =>
      _journeys.where((journey) => journey.status == status);

  String _summary() =>
      '${_with('new').length} new, ${_with('in_progress').length} in progress, '
      '${_with('completed').length} completed, ${_downloaded.length} downloaded.';

  bool _isDownloaded(int id) => _downloaded.any((s) => s.journeyId == id);

  Future<void> _openList(String title, List<StudentJourneySummary> items) async {
    final chosen = await JourneyPrompts.choose<StudentJourneySummary>(
      context,
      title: title,
      items: items,
      labelOf: (journey) => JourneyAnnouncer.studentRow(
        journey,
        downloaded: _isDownloaded(journey.journeyId),
      ),
    );
    if (chosen == null || !mounted) return;
    await _openOptions(
      journeyId: chosen.journeyId,
      title: chosen.title,
      description: chosen.description,
      revision: chosen.revision,
    );
  }

  Future<void> _openDownloaded() async {
    final chosen = await JourneyPrompts.choose<JourneySnapshot>(
      context,
      title: 'Downloaded journeys',
      items: _downloaded,
      labelOf: (snapshot) =>
          '${snapshot.title}. ${snapshot.steps.length} steps. Downloaded.',
    );
    if (chosen == null || !mounted) return;
    await _openOptions(
      journeyId: chosen.journeyId,
      title: chosen.title,
      description: chosen.description,
      revision: chosen.revision,
    );
  }

  Future<void> _openOptions({
    required int journeyId,
    required String title,
    required int revision,
    String? description,
  }) async {
    final store = _store;
    if (store == null) {
      MessageCenter.error(_issue ?? JourneyAnnouncer.storageUnavailable);
      return;
    }
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => StudentJourneyOptionsScreen(
          journeyId: journeyId,
          title: title,
          description: description,
          revision: revision,
          api: widget.api,
          store: store,
        ),
      ),
    );
    if (mounted) await _load();
  }

  Future<void> _continueLast() async {
    final recent = _with('in_progress').firstOrNull;
    if (recent != null) {
      await _openOptions(
        journeyId: recent.journeyId,
        title: recent.title,
        description: recent.description,
        revision: recent.revision,
      );
      return;
    }
    final store = _store;
    if (store != null) {
      for (final snapshot in _downloaded) {
        if (await store.loadProgress(snapshot.journeyId) != null) {
          await _openOptions(
            journeyId: snapshot.journeyId,
            title: snapshot.title,
            description: snapshot.description,
            revision: snapshot.revision,
          );
          return;
        }
      }
    }
    unawaited(
      TtsService.speak(JourneyAnnouncer.nothingInProgress),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fresh = _with('new').toList();
    final started = _with('in_progress').toList();
    final completed = _with('completed').toList();
    const offlineReason = 'This needs internet. Press 5 for downloaded journeys.';
    return JourneyMenu(
      title: 'Learning journeys',
      introduction:
          'Listen to stories and lessons, answer questions as you go, and repeat parts you need.',
      status: _status,
      issue: _issue,
      busy: _busy,
      choices: [
        JourneyChoice('Continue my last journey', () => unawaited(_continueLast())),
        JourneyChoice(
          'New journeys, ${fresh.length}',
          () => unawaited(_openList('New journeys', fresh)),
          enabled: _online && fresh.isNotEmpty,
          unavailableReason: _online ? 'There are no new journeys.' : offlineReason,
        ),
        JourneyChoice(
          'In progress, ${started.length}',
          () => unawaited(_openList('Journeys in progress', started)),
          enabled: _online && started.isNotEmpty,
          unavailableReason: _online ? 'Nothing is in progress.' : offlineReason,
        ),
        JourneyChoice(
          'Completed, ${completed.length}',
          () => unawaited(_openList('Completed journeys', completed)),
          enabled: _online && completed.isNotEmpty,
          unavailableReason: _online ? 'No journeys completed yet.' : offlineReason,
        ),
        JourneyChoice(
          'Downloaded, ${_downloaded.length}',
          () => unawaited(_openDownloaded()),
          enabled: _downloaded.isNotEmpty,
          unavailableReason:
              'Nothing is downloaded. Open a journey and choose Download.',
        ),
      ],
      details: [_issue, _status].whereType<String>().join(' '),
    );
  }
}

/// Start, hear about, download or restart one journey.
class StudentJourneyOptionsScreen extends StatefulWidget {
  const StudentJourneyOptionsScreen({
    super.key,
    required this.journeyId,
    required this.title,
    required this.revision,
    required this.api,
    required this.store,
    this.description,
  });

  final int journeyId;
  final String title;
  final String? description;
  final int revision;
  final JourneyApi api;
  final OfflineJourneyStore store;

  @override
  State<StudentJourneyOptionsScreen> createState() =>
      _StudentJourneyOptionsScreenState();
}

class _StudentJourneyOptionsScreenState
    extends State<StudentJourneyOptionsScreen> {
  JourneySnapshot? _saved;
  bool _downloaded = false;
  bool _hasProgress = false;
  bool _busy = true;
  String? _status;
  String? _issue;
  OfflineDownload? _download;

  @override
  void initState() {
    super.initState();
    unawaited(_refresh());
  }

  Future<void> _refresh() async {
    JourneySnapshot? saved;
    var downloaded = false;
    Object? progress;
    try {
      saved = await widget.store.savedSnapshot(widget.journeyId);
      downloaded = saved != null && await widget.store.isDownloaded(saved);
      progress = await widget.store.loadProgress(widget.journeyId);
    } catch (error) {
      debugPrint('[JOURNEY] Saved progress unreadable: $error');
      if (mounted) _issue = JourneyAnnouncer.storageUnavailable;
    }
    if (!mounted) return;
    setState(() {
      _saved = saved;
      _downloaded = downloaded;
      _hasProgress = progress != null;
      _busy = false;
    });
  }

  void _fail(String message) {
    if (!mounted) return;
    setState(() {
      _issue = message;
      _busy = false;
    });
    MessageCenter.error(message);
  }

  void _report(String message) {
    if (!mounted) return;
    setState(() {
      _status = message;
      _issue = null;
    });
    MessageCenter.show(message);
  }

  /// The current online version, or the downloaded copy when offline.
  Future<(JourneySnapshot, bool)?> _snapshot() async {
    try {
      return (await widget.api.studentJourney(widget.journeyId), false);
    } on JourneyApiException catch (error) {
      final saved = _saved;
      if (error.network && saved != null) return (saved, true);
      _fail(
        error.network
            ? 'No internet, and this journey is not downloaded.'
            : error.message,
      );
      return null;
    }
  }

  Future<void> _start() async {
    setState(() => _busy = true);
    final loaded = await _snapshot();
    if (!mounted || loaded == null) return;
    final (snapshot, offline) = loaded;
    setState(() => _busy = false);
    if (!offline && _saved != null && _saved!.revision != snapshot.revision) {
      _report(JourneyAnnouncer.teacherUpdated);
    }
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => JourneyPlayerScreen(
          snapshot: snapshot,
          store: widget.store,
          api: widget.api,
          offline: offline,
        ),
      ),
    );
    if (mounted) await _refresh();
  }

  Future<void> _startOver() async {
    final confirmed = await JourneyPrompts.confirm(
      context,
      title: 'Start over?',
      message: JourneyAnnouncer.startOverMessage(widget.title),
      confirmLabel: 'Start over',
    );
    if (!confirmed) return;
    await widget.store.clearProgress(widget.journeyId);
    await _start();
  }

  Future<void> _toggleDownload() async {
    if (_downloaded || _saved != null) {
      final confirmed = await JourneyPrompts.confirm(
        context,
        title: 'Remove download?',
        message: JourneyAnnouncer.removeDownloadMessage(widget.title),
        confirmLabel: 'Remove download',
      );
      if (!confirmed) return;
      // Files are deleted only after the undo window closes.
      final store = widget.store;
      final journeyId = widget.journeyId;
      setState(() {
        _downloaded = false;
        _saved = null;
      });
      await UndoService.offer(
        done: JourneyAnnouncer.downloadRemoved(widget.title),
        undo: () async {
          if (mounted) await _refresh();
        },
        commit: () => store.removeDownload(journeyId),
      );
      return;
    }
    setState(() => _busy = true);
    await UndoService.commitPending();
    try {
      final snapshot = await widget.api.studentJourney(widget.journeyId);
      final operation = _download = OfflineDownload();
      unawaited(FeedbackCues.play(Cue.loading));
      _report(JourneyAnnouncer.downloading(snapshot.audioIds.toSet().length));
      await widget.store.download(
        snapshot,
        operation: operation,
        onProgress: (done, total) {
          if (mounted && total > 0) {
            setState(() => _status = 'Saved $done of $total recordings.');
          }
        },
      );
      await _refresh();
      MessageCenter.success(JourneyAnnouncer.downloaded(widget.title));
    } on JourneyApiException catch (error) {
      _fail(error.message);
    } on OfflineJourneyException catch (error) {
      _fail(error.message);
    } finally {
      _download = null;
      if (mounted) setState(() => _busy = false);
    }
  }

  void _back() {
    final download = _download;
    if (download != null) {
      download.cancel();
      _report(JourneyAnnouncer.cancellingDownload);
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final about = [
      widget.title,
      if (widget.description != null) widget.description!,
      _downloaded ? 'Downloaded on this phone.' : 'Not downloaded.',
      _hasProgress ? 'You have started this journey.' : '',
    ].where((part) => part.isNotEmpty).join(' ');
    return JourneyMenu(
      title: widget.title,
      introduction: _downloaded ? 'Downloaded. Works without internet.' : null,
      status: _status,
      issue: _issue,
      busy: _busy && _download == null,
      onBack: _back,
      details: about,
      choices: [
        JourneyChoice(
          _hasProgress ? 'Continue journey' : 'Start journey',
          () => unawaited(_start()),
        ),
        JourneyChoice(
          'Hear about this journey',
          () => unawaited(TtsService.speak(about)),
        ),
        JourneyChoice(
          _downloaded || _saved != null
              ? 'Remove download'
              : 'Download to play without internet',
          () => unawaited(_toggleDownload()),
          enabled: _download == null && (!kIsWeb || _saved != null),
          unavailableReason: kIsWeb
              ? StreamOnlyMedia.unavailable
              : 'A download is in progress. Press 0 to cancel it.',
        ),
        JourneyChoice(
          'Start over from the beginning',
          () => unawaited(_startOver()),
          enabled: _hasProgress,
          unavailableReason: 'You have not started this journey yet.',
        ),
      ],
    );
  }
}
