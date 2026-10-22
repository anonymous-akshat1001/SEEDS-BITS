import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart'
    show MissingPlatformDirectoryException;

import 'learning_progress_store.dart';

class LearningPlaybackController extends ChangeNotifier {
  LearningPlaybackController({
    required this.seek,
    required this.setSpeed,
    required this.resume,
    required this.isPlaying,
    required this.onIssue,
    Future<LearningProgressStore> Function()? openStore,
  }) : _openStore = openStore ?? LearningProgressStore.forCurrentUser;

  final Future<void> Function(Duration) seek;
  final Future<void> Function(double) setSpeed;
  final Future<void> Function() resume;
  final bool Function() isPlaying;
  final void Function(String) onIssue;
  final Future<LearningProgressStore> Function() _openStore;
  LearningProgressStore? _storage;
  LessonProgress? _lesson;
  Duration _position = Duration.zero;
  Duration? _duration;
  double _speed = 1;
  bool _ready = false;
  bool _closed = false;
  bool _readOnly = false;
  bool _saveFailed = false;
  bool _repeatEnabled = false;
  Future<void>? _loopOperation;
  bool _resumeAfterLoop = false;
  String? _issue;
  Timer? _saveTimer;
  int _generation = 0;

  LessonProgress? get lesson => _lesson;
  int get revision => _generation;
  Duration get position => _position;
  Duration? get duration => _duration;
  double get speed => _speed;
  bool get ready => _ready;
  String? get issue => _issue;
  bool get canSave => _ready && !_readOnly && !_saveFailed;
  bool get repeatEnabled => _repeatEnabled;
  bool get hasRepeatRegion =>
      _lesson?.repeatStart != null &&
      _lesson?.repeatEnd != null &&
      (_duration == null || _lesson!.repeatEnd! <= _duration!);

  Future<LearningProgressStore> _store() async {
    if (_storage != null) return _storage!;
    try {
      return _storage = await _openStore();
    } on LearningStorageException {
      rethrow;
    } on MissingPluginException {
      throw const LearningStorageException(
        'Learning storage is unavailable on this device. Your existing data has not been changed.',
      );
    } on PlatformException {
      throw const LearningStorageException(
        'Learning storage could not be opened. Check free space and retry.',
      );
    } on FileSystemException {
      throw const LearningStorageException(
        'Learning storage could not be opened. Check free space and retry.',
      );
    } on MissingPlatformDirectoryException {
      throw const LearningStorageException(
        'This device did not provide a learning storage location. Your existing data has not been changed.',
      );
    }
  }

  Future<bool> prepare(
    int audioId,
    String title, {
    bool withoutSavedProgress = false,
  }) async {
    if (_closed) throw StateError('Learning player has closed');
    final generation = ++_generation;
    final wasReady = _ready;
    _saveTimer?.cancel();
    _saveTimer = null;
    if (wasReady) await flush();
    if (_closed || generation != _generation) return false;
    _ready = false;
    try {
      final saved = withoutSavedProgress
          ? null
          : await (await _store()).lesson(audioId);
      if (_closed || generation != _generation) return false;
      _lesson =
          saved ??
          LessonProgress(
            audioId: audioId,
            title: title,
            position: Duration.zero,
            updatedAt: DateTime.now().toUtc(),
          );
      _position = saved?.position ?? Duration.zero;
      _duration = saved?.duration;
      _speed = saved?.speed ?? 1;
      _repeatEnabled = false;
      _loopOperation = null;
      _resumeAfterLoop = false;
      _readOnly = withoutSavedProgress;
      _saveFailed = false;
      if (!withoutSavedProgress) _issue = null;
      notifyListeners();
      return true;
    } on LearningStorageException catch (error) {
      if (!_closed && generation == _generation) {
        _ready = wasReady;
        _issue = error.message;
        notifyListeners();
      }
      rethrow;
    }
  }

  void activate() {
    if (_closed || _lesson == null) return;
    _ready = true;
    notifyListeners();
    if (!_readOnly) unawaited(flush());
  }

  void abort() {
    _generation++;
    _ready = false;
    _loopOperation = null;
    _resumeAfterLoop = false;
    _saveTimer?.cancel();
    _saveTimer = null;
    if (!_closed) notifyListeners();
  }

  void updateDuration(Duration duration) {
    if (_closed || _lesson == null || duration <= Duration.zero) return;
    _duration = duration;
    if (!hasRepeatRegion) _repeatEnabled = false;
    notifyListeners();
  }

  void updatePosition(Duration position) {
    if (_closed || !_ready || position.isNegative) return;
    final secondsChanged = position.inSeconds != _position.inSeconds;
    _position = position;
    if (_repeatEnabled &&
        hasRepeatRegion &&
        isPlaying() &&
        position >= _lesson!.repeatEnd! &&
        _loopOperation == null) {
      unawaited(_loop(resumePlayback: false));
    }
    if (!_readOnly && !_saveFailed && _saveTimer == null) {
      _saveTimer = Timer(const Duration(seconds: 5), () {
        _saveTimer = null;
        unawaited(flush());
      });
    }
    if (secondsChanged) notifyListeners();
  }

  LessonProgress _snapshot({bool completed = false}) => _lesson!.copyWith(
    position: completed ? Duration.zero : _position,
    duration: _duration,
    speed: _speed,
    completed: completed,
  );

  Future<bool> _persist(LessonProgress snapshot, int generation) async {
    try {
      final result = await (await _store()).savePosition(
        audioId: snapshot.audioId,
        title: snapshot.title,
        position: snapshot.position,
        duration: snapshot.duration,
        speed: snapshot.speed,
        completed: snapshot.completed,
      );
      if (!_closed && generation == _generation) {
        _lesson = result;
        _saveFailed = false;
        _issue = null;
        notifyListeners();
      }
      return true;
    } on LearningStorageException catch (error) {
      _report(error.message, generation);
      return false;
    }
  }

  void _report(String message, int generation) {
    debugPrint('[LEARNING] $message');
    if (_closed || generation != _generation) return;
    _saveFailed = true;
    final changed = _issue != message;
    _issue = message;
    notifyListeners();
    if (changed) onIssue(message);
  }

  Future<bool> flush() {
    _saveTimer?.cancel();
    _saveTimer = null;
    if (_lesson == null || !_ready || _readOnly) return Future.value(false);
    return _persist(_snapshot(), _generation);
  }

  Future<void> retrySaving() async {
    final generation = _generation;
    final current = _lesson;
    if (!_ready || current == null) {
      throw const LearningStorageException(
        'Start a lesson before retrying progress saving.',
      );
    }
    if (_readOnly) {
      final restored = await (await _store()).lesson(current.audioId);
      if (_closed || generation != _generation) return;
      if (restored != null) _lesson = restored;
      _readOnly = false;
    }
    if (!await flush()) {
      throw LearningStorageException(
        _issue ??
            'Learning progress was not saved. Retry when storage is available.',
      );
    }
  }

  Future<void> moveTo(Duration position) async {
    if (!_ready ||
        position.isNegative ||
        (_duration != null && position > _duration!)) {
      throw ArgumentError('Choose a position within the lesson');
    }
    final generation = _generation;
    await seek(position);
    if (_closed || generation != _generation) return;
    if (_repeatEnabled &&
        (position < _lesson!.repeatStart! || position > _lesson!.repeatEnd!)) {
      _repeatEnabled = false;
    }
    _position = position;
    notifyListeners();
    if (!_readOnly) await flush();
  }

  Future<void> changeSpeed(double speed) async {
    if (!_ready || !speed.isFinite || speed < 0.25 || speed > 3) {
      throw ArgumentError('Choose a playback speed from 0.25 to 3');
    }
    final generation = _generation;
    await setSpeed(speed);
    if (_closed || generation != _generation) return;
    _speed = speed;
    notifyListeners();
    if (!_readOnly) await flush();
  }

  Future<void> addBookmark({String? label, Duration? at}) async {
    final generation = _generation;
    final audioId = _lesson?.audioId;
    final position = at ?? _position;
    if (position.isNegative || (_duration != null && position > _duration!)) {
      throw ArgumentError('Choose a bookmark position within the lesson');
    }
    if (!await flush()) {
      throw LearningStorageException(
        _issue ?? 'Progress saving is unavailable. The bookmark was not saved.',
      );
    }
    if (_closed || generation != _generation || audioId == null) return;
    final storage = await _store();
    if (_closed || generation != _generation) return;
    final updated = await storage.addBookmark(audioId, position, label: label);
    if (_closed || generation != _generation) return;
    _lesson = updated;
    notifyListeners();
  }

  Future<void> removeBookmark(int id) async {
    if (!canSave || _lesson == null) {
      throw const LearningStorageException(
        'Bookmark changes are unavailable until progress saving is restored.',
      );
    }
    final generation = _generation;
    final audioId = _lesson!.audioId;
    final storage = await _store();
    if (_closed || generation != _generation) return;
    final updated = await storage.removeBookmark(audioId, id);
    if (_closed || generation != _generation) return;
    _lesson = updated;
    notifyListeners();
  }

  Future<void> markRepeatStart() => _setRepeat(_position, null);
  Future<void> markRepeatEnd() => _setRepeat(_lesson?.repeatStart, _position);
  Future<void> clearRepeat() => _setRepeat(null, null);

  Future<void> _setRepeat(Duration? start, Duration? end) async {
    final generation = _generation;
    final audioId = _lesson?.audioId;
    if (!await flush()) {
      throw LearningStorageException(
        _issue ??
            'Progress saving is unavailable. Repeat points were not saved.',
      );
    }
    if (_closed || generation != _generation || audioId == null) return;
    final storage = await _store();
    if (_closed || generation != _generation) return;
    final updated = await storage.setRepeat(audioId, start, end);
    if (_closed || generation != _generation) return;
    _lesson = updated;
    _repeatEnabled = false;
    notifyListeners();
  }

  void toggleRepeat() {
    if (!_ready || !hasRepeatRegion) {
      throw ArgumentError(
        'Set a start point and a later end point within this lesson first',
      );
    }
    _repeatEnabled = !_repeatEnabled;
    notifyListeners();
  }

  Future<void> _loop({required bool resumePlayback}) {
    _resumeAfterLoop = _resumeAfterLoop || resumePlayback;
    return _loopOperation ??= _performLoop();
  }

  Future<void> _performLoop() async {
    final generation = _generation;
    final start = _lesson!.repeatStart!;
    try {
      await seek(start);
      if (_closed || generation != _generation) return;
      _position = start;
      if (_resumeAfterLoop) await resume();
    } on Exception catch (error) {
      debugPrint('[LEARNING] Repeat playback failed (${error.runtimeType})');
      if (!_closed && generation == _generation) {
        _repeatEnabled = false;
        onIssue('Repeat playback failed. Pause and try again.');
      }
    } finally {
      if (!_closed && generation == _generation) {
        _loopOperation = null;
        _resumeAfterLoop = false;
        notifyListeners();
      }
    }
  }

  Future<bool> handleCompletion() async {
    if (_closed) return false;
    final generation = _generation;
    if (_repeatEnabled && hasRepeatRegion && !_closed) {
      await _loop(resumePlayback: true);
      if (_closed || generation != _generation) return false;
      if (_repeatEnabled) return true;
    }
    if (_lesson == null || !_ready) return false;
    final snapshot = _snapshot(completed: true);
    _ready = false;
    _position = Duration.zero;
    _saveTimer?.cancel();
    _saveTimer = null;
    if (!_readOnly) await _persist(snapshot, _generation);
    if (!_closed) notifyListeners();
    return false;
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    if (_ready && !_readOnly && _lesson != null) {
      unawaited(_persist(_snapshot(), _generation));
    }
    _closed = true;
    super.dispose();
  }
}
