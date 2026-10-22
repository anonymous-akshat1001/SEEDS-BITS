import 'package:flutter/foundation.dart';

import 'api_service.dart';

class SessionMicrophoneController extends ChangeNotifier {
  SessionMicrophoneController({
    required this.isAvailable,
    required this.setCaptureEnabled,
    required this.sendMute,
  });

  final bool Function() isAvailable;
  final void Function(bool enabled) setCaptureEnabled;
  final Future<ApiResult<Map<String, dynamic>>> Function(bool muted) sendMute;
  bool _muted = true;
  bool _pending = false;
  bool _closed = false;
  int _remoteMuteRevision = 0;

  bool get muted => _muted;
  bool get pending => _pending;

  void applyRemoteMute(bool muted) {
    if (_closed || !muted) return;
    _remoteMuteRevision++;
    _muted = true;
    setCaptureEnabled(false);
    notifyListeners();
  }

  Future<ApiResult<Map<String, dynamic>>> toggle() async {
    if (_closed) {
      return _failure('The class has closed. No microphone action was sent.');
    }
    if (_pending) return _failure('Waiting for microphone confirmation.');
    final nextMuted = !_muted;
    if (!nextMuted && !isAvailable()) {
      return _failure(
        'Microphone access is unavailable. Check microphone '
        'permission and rejoin the class before trying to speak.',
      );
    }
    final revision = _remoteMuteRevision;
    _pending = true;
    try {
      if (nextMuted) {
        _muted = true;
        setCaptureEnabled(false);
      }
      notifyListeners();
      final result = await sendMute(nextMuted);
      if (_closed) {
        return _failure('The class closed before microphone confirmation.');
      }
      if (result.isSuccess && !nextMuted) {
        if (!isAvailable()) {
          return _failure(
            'Microphone access is no longer available. Rejoin '
            'the class before trying to speak.',
          );
        }
        if (revision != _remoteMuteRevision) {
          return _failure(
            'Your microphone stayed muted because the class '
            'mute state changed. Select Unmute when you are ready to speak.',
          );
        }
        setCaptureEnabled(true);
        _muted = false;
      }
      return result;
    } finally {
      if (!_closed) {
        _pending = false;
        notifyListeners();
      }
    }
  }

  ApiResult<Map<String, dynamic>> _failure(String message) {
    debugPrint('[MIC] $message');
    return ApiResult.failure(
      ApiFailure(kind: ApiFailureKind.unknown, message: message),
    );
  }

  @override
  void dispose() {
    _closed = true;
    setCaptureEnabled(false);
    super.dispose();
  }
}
