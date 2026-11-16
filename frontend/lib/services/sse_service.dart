import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/speech.dart';
import 'api_service.dart';

typedef MsgHandler = void Function(Map<String, dynamic>);

enum SessionConnectionState {
  connecting,
  connected,
  interrupted,
  reconnecting,
  authenticationExpired,
  unavailable,
  ended,
  closed;

  /// Spoken name of this state in the current speech language.
  String get label {
    final t = Speech.t;
    return switch (this) {
      connecting => t.sessionConnStateConnecting,
      connected => t.sessionConnStateConnected,
      interrupted => t.sessionConnStateInterrupted,
      reconnecting => t.sessionConnStateReconnecting,
      authenticationExpired => t.sessionConnStateSignInRequired,
      unavailable => t.sessionConnStateUnavailable,
      ended => t.sessionConnStateEnded,
      closed => t.sessionConnStateDisconnected,
    };
  }
}

class SseService {
  int? sessionId;
  int? userId;
  MsgHandler? onMessage;
  SessionConnectionState state = SessionConnectionState.closed;

  http.Client? _client;
  StreamSubscription<String>? _sub;
  Timer? _reconnectTimer;
  Timer? _heartbeatTimer;
  Timer? _bootstrapTimer;
  final List<MsgHandler> _chatHandlers = [];
  final Random _random = Random();
  bool _disposed = true;
  bool _terminal = false;
  int _generation = 0;
  int _contextGeneration = 0;
  int _retries = 0;
  int? _myParticipantId;
  String? _sessionToken;

  String get _baseUrl => dotenv.env['API_BASE_URL'] ?? '';

  void connect(String sessionId_, int userId_, MsgHandler onMsg) {
    sessionId = int.parse(sessionId_);
    userId = userId_;
    onMessage = onMsg;
    ++_contextGeneration;
    _disposed = false;
    _terminal = false;
    _retries = 0;
    _myParticipantId = null;
    _sessionToken = null;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    unawaited(_startStream());
  }

  bool _current(int generation) =>
      !_disposed && !_terminal && generation == _generation;

  Future<void> _startStream() async {
    if (_disposed || _terminal || sessionId == null || userId == null) return;
    final generation = ++_generation;
    _cancelActiveStream();
    _publish(
      _retries == 0
          ? SessionConnectionState.connecting
          : SessionConnectionState.reconnecting,
      _retries == 0
          ? Speech.t.sessionConnecting
          : Speech.t.sessionReconnectingToClass,
    );
    final preferences = await SharedPreferences.getInstance();
    if (!_current(generation)) return;
    final token = preferences.getString('token');
    if (token == null ||
        token.isEmpty ||
        (_sessionToken != null && token != _sessionToken) ||
        (preferences.getInt('user_id') != null &&
            preferences.getInt('user_id') != userId)) {
      _stopPermanently(
        SessionConnectionState.authenticationExpired,
        Speech.t.sessionSignInRequiredLeave,
      );
      return;
    }
    _sessionToken = token;
    final url = Uri.parse(
      '$_baseUrl/sse/sessions/$sessionId',
    ).replace(queryParameters: {'access_token': token});
    final client = http.Client();
    _client = client;
    debugPrint('[SSE] Opening session $sessionId stream');
    try {
      final request = http.Request('GET', url)
        ..headers['Accept'] = 'text/event-stream'
        ..headers['Cache-Control'] = 'no-cache';
      final response = await client
          .send(request)
          .timeout(const Duration(seconds: 10));
      if (!_current(generation)) {
        client.close();
        return;
      }
      if (response.statusCode != 200) {
        if (response.statusCode == 401) {
          _stopPermanently(
            SessionConnectionState.authenticationExpired,
            Speech.t.sessionSignInExpiredLeave,
          );
        } else if ([403, 404, 410].contains(response.statusCode)) {
          _stopPermanently(
            SessionConnectionState.unavailable,
            Speech.t.sessionClassNoLongerAvailable,
          );
        } else {
          _connectionLost(generation, Speech.t.sessionServiceUnavailable);
        }
        return;
      }
      if (!(response.headers['content-type'] ?? '').toLowerCase().startsWith(
        'text/event-stream',
      )) {
        _connectionLost(
          generation,
          Speech.t.sessionConnectionUnreadable,
        );
        return;
      }

      _bootstrapTimer = Timer(const Duration(seconds: 10), () {
        _connectionLost(
          generation,
          Speech.t.sessionConnectionNotConfirmed,
        );
      });
      _watchHeartbeat(generation);
      var eventType = 'message';
      final data = <String>[];
      _sub = response.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
            (line) {
              if (!_current(generation)) return;
              _watchHeartbeat(generation);
              if (line.startsWith(':')) return;
              if (line.startsWith('event:')) {
                eventType = line.substring(6).trim();
              } else if (line.startsWith('data:')) {
                final value = line.substring(5);
                data.add(value.startsWith(' ') ? value.substring(1) : value);
              } else if (line.isEmpty) {
                if (data.isNotEmpty) {
                  final raw = data.join('\n');
                  data.clear();
                  _dispatch(eventType, raw, generation);
                }
                eventType = 'message';
              }
            },
            onError: (Object error) {
              debugPrint('[SSE] Stream interrupted: ${error.runtimeType}');
              _connectionLost(
                generation,
                Speech.t.sessionConnectionInterrupted,
              );
            },
            onDone: () =>
                _connectionLost(generation, Speech.t.sessionConnectionClosed),
            cancelOnError: true,
          );
    } catch (error) {
      debugPrint('[SSE] Connection failed: ${error.runtimeType}');
      _connectionLost(
        generation,
        Speech.t.sessionConnectionCouldNotConfirm,
      );
    }
  }

  void _watchHeartbeat(int generation) {
    _heartbeatTimer?.cancel();
    // The server emits a keep-alive every 25 seconds.
    _heartbeatTimer = Timer(const Duration(seconds: 60), () {
      _connectionLost(generation, Speech.t.sessionNoUpdates);
    });
  }

  void _dispatch(String eventType, String raw, int generation) {
    Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException {
      _connectionLost(generation, Speech.t.sessionUpdateUnreadable);
      return;
    }
    if (decoded is! Map<String, dynamic>) {
      _connectionLost(generation, Speech.t.sessionUpdateUnexpectedFormat);
      return;
    }
    final data = decoded;
    data.putIfAbsent('type', () => eventType);
    final type = data['type'];
    if (type is! String) {
      _connectionLost(generation, Speech.t.sessionUpdateTypeUnreadable);
      return;
    }
    if (type == 'connected') {
      final participant = data['participant_id'];
      if (participant is! int || participant <= 0) {
        _connectionLost(
          generation,
          Speech.t.sessionParticipationNotConfirmed,
        );
        return;
      }
      _myParticipantId = participant;
      _bootstrapTimer?.cancel();
      _bootstrapTimer = null;
      _retries = 0;
      _publish(SessionConnectionState.connected, Speech.t.sessionConnectedToClass);
    }
    if (type == 'chat') {
      data['is_own'] = data['from'] != null && data['from'] == _myParticipantId;
      for (final handler in _chatHandlers.toList()) {
        handler(data);
      }
    }
    if (type == 'authentication_revoked') {
      _stopPermanently(
        SessionConnectionState.authenticationExpired,
        Speech.t.sessionSignInChangedShort,
      );
    } else if (type == 'session_ended' || type == 'session_ending') {
      _stopPermanently(SessionConnectionState.ended, Speech.t.sessionClassEnded);
    } else if (type == 'kicked') {
      _stopPermanently(
        SessionConnectionState.unavailable,
        Speech.t.sessionRemovedGoBack,
      );
    }
    onMessage?.call(data);
  }

  void _publish(SessionConnectionState value, String message) {
    state = value;
    if (_disposed) return;
    onMessage?.call({
      'type': 'connection_status',
      'state': value.name,
      'message': message,
    });
  }

  void _stopPermanently(SessionConnectionState value, String message) {
    _terminal = true;
    ++_generation;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _cancelActiveStream();
    _publish(value, message);
  }

  void _connectionLost(int generation, String message) {
    if (!_current(generation)) return;
    ++_generation;
    _cancelActiveStream();
    _publish(SessionConnectionState.interrupted, message);
    final seconds = min(30, 2 * pow(2, min(_retries, 4))).toInt();
    _retries++;
    final delay = Duration(milliseconds: seconds * 1000 + _random.nextInt(251));
    _publish(
      SessionConnectionState.reconnecting,
      Speech.t.sessionConnectionLostReconnecting(message),
    );
    _reconnectTimer = Timer(delay, () {
      _reconnectTimer = null;
      unawaited(_startStream());
    });
  }

  void reconnect() {
    if (_disposed || _terminal) return;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    unawaited(_startStream());
  }

  void _cancelActiveStream() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    _bootstrapTimer?.cancel();
    _bootstrapTimer = null;
    final subscription = _sub;
    _sub = null;
    if (subscription != null) unawaited(subscription.cancel());
    _client?.close();
    _client = null;
  }

  Future<ApiResult<Map<String, dynamic>>> send(
    Map<String, dynamic> message,
  ) async {
    final id = sessionId;
    final contextGeneration = _contextGeneration;
    if (_disposed || _terminal || id == null || userId == null) {
      return _actionFailure(
        ApiFailure(
          kind: ApiFailureKind.unknown,
          message: Speech.t.sessionActionClassUnavailable,
        ),
      );
    }
    final preferences = await SharedPreferences.getInstance();
    if (_disposed ||
        _terminal ||
        id != sessionId ||
        contextGeneration != _contextGeneration) {
      return ApiResult.failure(
        ApiFailure(
          kind: ApiFailureKind.unknown,
          message: Speech.t.sessionActionSessionChanged,
        ),
      );
    }
    final token = preferences.getString('token');
    if (token == null ||
        token.isEmpty ||
        (_sessionToken != null && token != _sessionToken) ||
        (preferences.getInt('user_id') != null &&
            preferences.getInt('user_id') != userId)) {
      _stopPermanently(
        SessionConnectionState.authenticationExpired,
        Speech.t.sessionSignInRequiredLeave,
      );
      return _actionFailure(
        ApiFailure(
          kind: ApiFailureKind.unauthorized,
          message: Speech.t.sessionActionSignInRequired,
        ),
      );
    }
    _sessionToken = token;
    final result = await ApiService.postAcknowledged(
      '/sessions/$id/action',
      message,
      context: 'session action',
      canSend: () =>
          !_disposed &&
          !_terminal &&
          id == sessionId &&
          contextGeneration == _contextGeneration &&
          preferences.getString('token') == token &&
          (preferences.getInt('user_id') == null ||
              preferences.getInt('user_id') == userId),
    );
    if (_disposed ||
        _terminal ||
        id != sessionId ||
        contextGeneration != _contextGeneration) {
      return ApiResult.failure(
        ApiFailure(
          kind: ApiFailureKind.unknown,
          message: Speech.t.sessionActionConnectionChanged,
        ),
      );
    }
    if (preferences.getString('token') != token ||
        (preferences.getInt('user_id') != null &&
            preferences.getInt('user_id') != userId)) {
      _stopPermanently(
        SessionConnectionState.authenticationExpired,
        Speech.t.sessionAccountChangedLeave,
      );
      return _actionFailure(
        ApiFailure(
          kind: ApiFailureKind.unauthorized,
          message: Speech.t.sessionActionAccountChanged,
        ),
      );
    }
    if (result.isSuccess && result.data?['ok'] == true) return result;
    final failure = result.failure;
    if (failure?.statusCode == 401) {
      _stopPermanently(
        SessionConnectionState.authenticationExpired,
        Speech.t.sessionSignInExpiredLeave,
      );
    }
    if (failure == null) {
      return _actionFailure(
        ApiFailure(
          kind: ApiFailureKind.unknown,
          message: Speech.t.sessionActionNotConfirmedByClass,
        ),
      );
    }
    return _actionFailure(
      ApiFailure(
        kind: failure.kind,
        statusCode: failure.statusCode,
        message:
            failure.kind == ApiFailureKind.network ||
                failure.kind == ApiFailureKind.server
            ? Speech.t.sessionActionMayHaveReached
            : failure.message,
      ),
    );
  }

  ApiResult<Map<String, dynamic>> _actionFailure(ApiFailure failure) {
    debugPrint('[SSE] Action unconfirmed (${failure.kind.name})');
    if (!_disposed) {
      onMessage?.call({
        'type': 'action_unconfirmed',
        'message': failure.message,
      });
    }
    return ApiResult.failure(failure);
  }

  void registerChatHandler(MsgHandler handler) => _chatHandlers.add(handler);
  void unregisterChatHandler(MsgHandler handler) =>
      _chatHandlers.remove(handler);

  void close() {
    _disposed = true;
    _terminal = true;
    ++_contextGeneration;
    ++_generation;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _cancelActiveStream();
    _myParticipantId = null;
    _sessionToken = null;
    state = SessionConnectionState.closed;
    onMessage = null;
  }
}
