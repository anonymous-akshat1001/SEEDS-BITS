import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import '../l10n/speech.dart';
import 'private_note_store.dart';
import 'tts_service.dart';

class PrivateNoteRecorder extends ChangeNotifier {
  PrivateNoteRecorder({
    MethodChannel? channel,
    Future<bool> Function()? permission,
  }) : _channel = channel ?? const MethodChannel('seeds/private_notes'),
       _permission =
           permission ??
           (() async => (await Permission.microphone.request()).isGranted) {
    TtsService.speaking.addListener(_narrationChanged);
  }
  final MethodChannel _channel;
  final Future<bool> Function() _permission;
  static int liveSessions = 0;
  static PrivateNoteRecorder? _nativeOwner;
  bool _stopRequested = false;
  PrivateNoteStore? _store;
  String? _id;
  Timer? _timer;
  Future<void>? _stopping;
  bool busy = false;
  bool _finishing = false;
  bool get active => busy || recording || _id != null || _finishing;
  bool recording = false;
  String status = Speech.t.notesNoRecordingActive;
  String? issue;
  bool _disposed = false;
  void _changed() {
    if (!_disposed) notifyListeners();
  }

  void _report(Object error) {
    debugPrint('[NOTES] Recording operation failed (${error.runtimeType}).');
    issue = error is PrivateNoteException
        ? error.message
        : error is PlatformException
        ? (error.message ?? Speech.t.notesMicCouldNotRecord)
        : Speech.t.notesRecordingNotConfirmed;
    _changed();
  }

  void _narrationChanged() {
    if (recording && TtsService.speaking.value) unawaited(stop());
  }

  Future<void> start({
    required PrivateNoteStore store,
    required String title,
    required bool Function() canRecord,
    int? audioId,
    Duration? position,
  }) async {
    if (active) return;
    _stopRequested = false;
    busy = true;
    issue = null;
    _changed();
    try {
      if (liveSessions > 0 || !canRecord()) {
        throw PrivateNoteException(
          Speech.t.notesLeaveLiveSession,
        );
      }
      if (!await _permission()) {
        throw PrivateNoteException(
          Speech.t.notesMicPermissionDenied,
        );
      }
      if (!canRecord() || liveSessions > 0 || _disposed || _stopRequested) {
        throw PrivateNoteException(
          Speech.t.notesRecordingCancelledChanged,
        );
      }
      if (!await TtsService.stopForVoiceCommands()) {
        throw PrivateNoteException(
          Speech.t.notesSpeechDidNotStop,
        );
      }
      final draft = await store.prepare(
        title: title,
        audioId: audioId,
        position: position,
      );
      _store = store;
      _id = draft.note.id;
      if (!canRecord() || liveSessions > 0 || _disposed || _stopRequested) {
        throw PrivateNoteException(
          Speech.t.notesRecordingDidNotStart,
        );
      }
      final owner = _nativeOwner;
      if (owner != null && !identical(owner, this) && owner.active) {
        throw PrivateNoteException(
          Speech.t.notesAnotherRecorderStopping,
        );
      }
      _nativeOwner = this;
      _channel.setMethodCallHandler((call) async {
        if (call.method == 'stopped') await _finish(call.arguments);
      });
      final started = await _channel
          .invokeMethod<bool>('start', {
            'id': draft.note.id,
            'path': draft.path,
            'max_bytes': draft.allowance,
          })
          .timeout(const Duration(seconds: 10));
      if (started != true) {
        throw PrivateNoteException(
          Speech.t.notesNativeStartNotConfirmed,
        );
      }
      if (_id != draft.note.id) return;
      recording = true;
      status =
          Speech.t.notesRecordingInProgress;
      _timer = Timer.periodic(const Duration(seconds: 1), (_) async {
        try {
          await store.checkAccount();
          if (!canRecord() || liveSessions > 0) await stop();
        } on Exception catch (error) {
          _report(error);
          await stop();
        }
      });
      if (!canRecord() || liveSessions > 0 || _disposed || _stopRequested) {
        await stop();
      }
    } on Exception catch (error) {
      _report(error);
      // A timed-out native start can have begun capture; always issue Stop.
      if (_id != null && identical(_nativeOwner, this)) {
        await stop();
      } else if (!identical(_nativeOwner, this)) {
        _id = null;
      }
    } finally {
      busy = false;
      _changed();
    }
  }

  Future<void> stop() {
    _stopRequested = true;
    final pending = _stopping;
    if (pending != null) return pending;
    if (_id == null) return Future<void>.value();
    final operation = _stop();
    _stopping = operation;
    return operation.whenComplete(() {
      if (identical(_stopping, operation)) _stopping = null;
      _changed();
    });
  }

  Future<void> _stop() async {
    _timer?.cancel();
    _timer = null;
    try {
      final result = await _channel
          .invokeMethod<Object?>('stop')
          .timeout(const Duration(seconds: 10));
      if (result is Map && result['id'] == null) {
        _id = null;
        recording = false;
        status =
            Speech.t.notesNativeCaptureStopped;
        return;
      }
      if (result is! Map || result['id'] != _id) {
        if (_id == null) return;
        throw PrivateNoteException(
          Speech.t.notesNativeStopNotConfirmed,
        );
      }
      await _finish(result);
    } on Exception catch (error) {
      _report(error);
      status =
          Speech.t.notesRecorderStopNotConfirmed;
    } finally {
      _changed();
    }
  }

  Future<void> _finish(Object? result) async {
    if (result is! Map || result['id'] != _id || _id == null) return;
    _timer?.cancel();
    _timer = null;
    recording = false;
    _finishing = true;
    final id = _id!;
    _id = null;
    try {
      if (result['error'] != null || result['reason'] == 'recorder_error') {
        throw PrivateNoteException(
          result['error']?.toString() ??
              Speech.t.notesRecorderFailed,
        );
      }
      if (result['duration_ms'] is! int) {
        throw PrivateNoteException(
          Speech.t.notesDurationUnreadable,
        );
      }
      await _store!.finish(
        id,
        Duration(milliseconds: result['duration_ms'] as int),
      );
      status =
          '${result['reason'] == 'limit'
              ? Speech.t.notesRecordingLimitReached
              : result['reason'] == 'interrupted'
              ? Speech.t.notesRecordingInterrupted
              : Speech.t.notesRecordingStopped} ${Speech.t.notesSavedOnPhone}';
    } on Exception catch (error) {
      _report(error);
      status =
          Speech.t.notesNotFinalized;
    }
    _finishing = false;
    if (_disposed) _releaseNative();
    _changed();
  }

  void _releaseNative() {
    if (identical(_nativeOwner, this) && !recording && _id == null) {
      _nativeOwner = null;
      _channel.setMethodCallHandler(null);
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    TtsService.speaking.removeListener(_narrationChanged);
    if (_id != null) {
      unawaited(stop().whenComplete(_releaseNative));
    } else {
      _releaseNative();
    }
    super.dispose();
  }
}
