import 'dart:async';
import 'package:flutter/foundation.dart';

class SessionVoiceController extends ChangeNotifier {
  SessionVoiceController({
    required this.initialize,
    required this.listen,
    required this.cancel,
    required this.stopSpeech,
    required this.canAct,
    required this.onCommand,
    required this.onIssue,
  });

  final Future<bool> Function() initialize;
  final Future<void> Function(void Function(String, bool)) listen;
  final Future<void> Function() cancel;
  final Future<bool> Function() stopSpeech;
  final bool Function() canAct;
  final Future<void> Function(String) onCommand;
  final void Function(String) onIssue;
  bool _window = false;
  bool _starting = false;
  bool _nativeStopped = false;
  bool _acceptingNative = false;
  bool _stopUnconfirmed = false;
  bool _closed = false;
  int _generation = 0;
  Timer? _deadline;
  Timer? _finalGrace;
  Future<bool>? _stopping;
  Future<void>? _pendingListen;

  bool get hasWindow => _window;
  bool get busy => _window || _stopping != null || _stopUnconfirmed;
  String get status => _stopUnconfirmed
      ? 'Voice listening stop not confirmed. Retry stopping.'
      : _stopping != null
      ? 'Stopping voice listening.'
      : _starting
      ? 'Starting voice commands.'
      : _window
      ? (_nativeStopped
            ? 'Finishing voice recognition.'
            : 'Listening for one command, up to 12 seconds.')
      : 'Not listening. Activate Listen for command to start.';

  bool _owns(int generation) =>
      !_closed && _window && generation == _generation;
  void _notify() {
    if (!_closed) notifyListeners();
  }

  Future<void> start() async {
    if (_closed || busy || !canAct()) return;
    final generation = ++_generation;
    _window = true;
    _starting = true;
    _nativeStopped = false;
    _acceptingNative = false;
    _notify();
    try {
      final quiet = await stopSpeech().timeout(const Duration(seconds: 3));
      if (!_owns(generation)) return;
      if (!quiet) {
        await _fail(
          'App speech could not be stopped. Try Stop speech before listening.',
        );
        return;
      }
      final available = await initialize().timeout(const Duration(seconds: 10));
      if (!_owns(generation)) return;
      if (!available) {
        await _fail(
          'Voice commands are unavailable. Check microphone permission and Android English speech services.',
        );
        return;
      }
      _deadline = Timer(const Duration(seconds: 12), () {
        unawaited(_finishWithoutCommand());
      });
      _acceptingNative = true;
      final pending = listen((words, isFinal) {
        if (isFinal && _owns(generation)) {
          unawaited(_consume(words, generation));
        }
      });
      _pendingListen = pending;
      try {
        await pending.timeout(const Duration(seconds: 2));
      } finally {
        // A timeout is not proof the native start has finished. Retain that
        // future until it settles so Stop cannot race an unfinished start.
        unawaited(
          pending.then<void>(
            (_) {
              if (identical(_pendingListen, pending)) _pendingListen = null;
            },
            onError: (Object error, StackTrace stack) {
              if (identical(_pendingListen, pending)) _pendingListen = null;
            },
          ),
        );
      }
      if (!_owns(generation)) return;
      _starting = false;
      _notify();
    } on Exception catch (error) {
      debugPrint('[VOICE] Start failed (${error.runtimeType})');
      if (_owns(generation)) {
        await _fail(
          'Voice commands could not start. Check microphone permission and English speech services, then try again.',
        );
      }
    }
  }

  void handleStatus(String status) {
    if (!_window || !_acceptingNative || _closed) return;
    if (status == 'done' || status == 'notListening') {
      _nativeStopped = true;
      _notify();
      // Some recognizers send the final result just after their done status.
      _finalGrace ??= Timer(const Duration(milliseconds: 500), () {
        unawaited(_finishWithoutCommand());
      });
    }
  }

  void handleError() {
    if (_window && !_closed) {
      unawaited(
        _fail(
          'Voice recognition could not finish. Check permission and English speech services, then activate Listen to retry.',
        ),
      );
    }
  }

  Future<void> _consume(String words, int generation) async {
    final command = words.trim();
    final stopped = await stop();
    if (!stopped || _closed || _generation != generation + 1 || !canAct()) {
      return;
    }
    if (command.isEmpty) {
      onIssue('No command heard. Activate Listen for command to try again.');
      return;
    }
    try {
      await onCommand(command);
    } on Exception catch (error) {
      debugPrint('[VOICE] Command action failed (${error.runtimeType})');
      if (!_closed && canAct()) {
        onIssue(
          'The voice command could not be completed. Use its keypad control or try again.',
        );
      }
    }
  }

  Future<void> _finishWithoutCommand() async {
    final generation = _generation;
    final stopped = await stop();
    if (stopped && !_closed && _generation == generation + 1 && canAct()) {
      onIssue('No command heard. Activate Listen for command to try again.');
    }
  }

  Future<void> _fail(String message) async {
    final generation = _generation;
    final stopped = await stop();
    if (stopped && !_closed && _generation == generation + 1) onIssue(message);
  }

  Future<bool> stop() {
    final needsStop = _window || _stopUnconfirmed;
    ++_generation;
    _window = false;
    _starting = false;
    _acceptingNative = false;
    _deadline?.cancel();
    _deadline = null;
    _finalGrace?.cancel();
    _finalGrace = null;
    if (_stopping != null) return _stopping!;
    if (!needsStop) {
      _notify();
      return Future.value(true);
    }
    final pending = _cancelNative();
    _stopping = pending;
    _notify();
    return pending;
  }

  Future<bool> _cancelNative() async {
    try {
      var startSettled = true;
      try {
        await _pendingListen?.timeout(const Duration(seconds: 2));
      } on TimeoutException {
        startSettled = false;
      } on Exception catch (error) {
        debugPrint('[VOICE] Native start failed (${error.runtimeType})');
      }
      await Future<void>.sync(cancel).timeout(const Duration(seconds: 2));
      if (!startSettled) {
        throw TimeoutException('Native listening start has not settled');
      }
      _stopUnconfirmed = false;
      return true;
    } on Exception catch (error) {
      debugPrint('[VOICE] Stop not confirmed (${error.runtimeType})');
      _stopUnconfirmed = true;
      if (!_closed) {
        onIssue(
          'Voice listening could not be stopped. Retry Stop listening or leave the session and check the Android microphone indicator.',
        );
      }
      return false;
    } finally {
      _stopping = null;
      _notify();
    }
  }

  @override
  void dispose() {
    _closed = true;
    unawaited(stop());
    super.dispose();
  }
}
