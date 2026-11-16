import 'package:flutter/foundation.dart';

import '../l10n/speech.dart';
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
      return _failure(Speech.t.sessionMicClassClosed);
    }
    if (_pending) return _failure(Speech.t.sessionWaitingMic);
    final nextMuted = !_muted;
    if (!nextMuted && !isAvailable()) {
      return _failure(Speech.t.sessionMicUnavailableRejoin);
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
        return _failure(Speech.t.sessionMicClosedBeforeConfirm);
      }
      if (result.isSuccess && !nextMuted) {
        if (!isAvailable()) {
          return _failure(Speech.t.sessionMicNoLongerAvailable);
        }
        if (revision != _remoteMuteRevision) {
          return _failure(Speech.t.sessionMicStayedMuted);
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
