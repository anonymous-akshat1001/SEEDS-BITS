// Replaces WsService (WebSocket) with:
//   • SSE listener  — GET /sse/sessions/{id}?user_id={uid}   (server → client)
//   • HTTP POST     — POST /sessions/{id}/action              (client → server)
//
// The public API is intentionally close to the old WsService so that
// call-sites need minimal changes.


// Architecture:
//   Server → Client : GET /sse/sessions/{id}?user_id={uid}  (SSE stream)
//   Client → Server : POST /sessions/{id}/action             (plain HTTP POST)
//
// Public API intentionally mirrors WsService so session_screen.dart
// and chat_panel.dart need minimal changes.

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

typedef MsgHandler = void Function(Map<String, dynamic>);

class SseService {
  // ── public state ─────────────────────────────────────────────────────────
  int?    sessionId;
  int?    userId;
  MsgHandler? onMessage;

  // ── private ──────────────────────────────────────────────────────────────
  http.Client?              _client;
  StreamSubscription<String>? _sub;
  final List<MsgHandler>    _chatHandlers = [];
  bool                      _disposed     = false;
  bool                      _reconnecting = false;

  // Parsed from the server's 'connected' event.
  // Used to detect own chat messages (avoid showing duplicates).
  int? _myParticipantId;

  String get _baseUrl => dotenv.env['API_BASE_URL'] ?? '';

  // ── connect ──────────────────────────────────────────────────────────────

  /// Open the SSE stream.
  /// [onMsg] receives every inbound server event as a Map.
  void connect(String sessionId_, int userId_, MsgHandler onMsg) {
    sessionId = int.parse(sessionId_);
    userId    = userId_;
    onMessage = onMsg;
    _disposed = false;

    _cancelStream();
    _startStream();
  }

  void _startStream() {
    if (_disposed || sessionId == null || userId == null) return;
    _reconnecting = false;

    // Build the SSE URL.  In devMode the server reads identity from
    // the user_id query param (same as every other API call).
    final url = '$_baseUrl/sse/sessions/$sessionId?user_id=$userId';
    debugPrint('[SSE] Connecting → $url');

    _client = http.Client();

    final request = http.Request('GET', Uri.parse(url));
    request.headers['Accept']        = 'text/event-stream';
    request.headers['Cache-Control'] = 'no-cache';

    // SSE state machine
    String eventType     = 'message';
    final  dataBuffer    = StringBuffer();

    _client!.send(request).then((response) {
      if (_disposed) { _client?.close(); return; }

      if (response.statusCode != 200) {
        debugPrint('[SSE] HTTP ${response.statusCode} — will retry');
        _client?.close();
        _scheduleReconnect();
        return;
      }

      debugPrint('[SSE] Stream opened (HTTP ${response.statusCode})');

      final lineStream = response.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter());

      _sub = lineStream.listen(
        (line) {
          // SSE keep-alive comments start with ':'
          if (line.startsWith(':')) return;

          if (line.startsWith('event:')) {
            eventType = line.substring(6).trim();
          } else if (line.startsWith('data:')) {
            dataBuffer.write(line.substring(5).trim());
          } else if (line.isEmpty) {
            // Blank line → dispatch accumulated event
            final raw = dataBuffer.toString();
            dataBuffer.clear();
            if (raw.isNotEmpty) {
              _dispatch(eventType, raw);
            }
            eventType = 'message';   // reset for next event
          }
        },
        onError: (e) {
          debugPrint('[SSE ERROR] $e');
          _client?.close();
          _scheduleReconnect();
        },
        onDone: () {
          debugPrint('[SSE] Stream ended — reconnecting');
          _client?.close();
          _scheduleReconnect();
        },
        cancelOnError: true,
      );
    }).catchError((e) {
      debugPrint('[SSE CONNECT ERROR] $e');
      _scheduleReconnect();
    });
  }

  void _dispatch(String eventType, String rawData) {
    try {
      final data = Map<String, dynamic>.from(jsonDecode(rawData) as Map);
      // Normalise: always have a 'type' field
      data.putIfAbsent('type', () => eventType);

      final type = data['type'] as String? ?? '';

      // Cache own participant_id from the server's 'connected' event.
      // This lets us detect our own chat messages reliably.
      if (type == 'connected' && data['participant_id'] != null) {
        _myParticipantId = data['participant_id'] as int?;
        debugPrint('[SSE] My participant_id = $_myParticipantId');
      }

      // Annotate chat messages so Flutter knows which are ours.
      if (type == 'chat') {
        final fromId = data['from'] as int?;
        data['is_own'] = (fromId != null && fromId == _myParticipantId);
        for (final h in _chatHandlers) { h(data); }
      }

      onMessage?.call(data);
    } catch (e) {
      debugPrint('[SSE PARSE ERROR] $e  raw=$rawData');
    }
  }

  void _scheduleReconnect() {
    if (_disposed || _reconnecting) return;
    _reconnecting = true;
    debugPrint('[SSE] Reconnecting in 3 s…');
    Future.delayed(const Duration(seconds: 3), () {
      if (!_disposed) _startStream();
    });
  }

  void _cancelStream() {
    _sub?.cancel();
    _sub = null;
    _client?.close();
    _client = null;
  }

  // ── send (HTTP POST) ─────────────────────────────────────────────────────

  /// Send an action to the server.
  /// Mirrors the old WsService.send(map) call signature.
  Future<void> send(Map<String, dynamic> msg) async {
    if (sessionId == null || userId == null) return;

    // Build URL with user_id (devMode identity pattern used throughout the app)
    final url = '$_baseUrl/sessions/$sessionId/action?user_id=$userId';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(msg),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        debugPrint('[SSE SEND] POST failed ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      debugPrint('[SSE SEND ERROR] $e');
    }
  }

  // ── chat helpers ─────────────────────────────────────────────────────────

  void registerChatHandler(MsgHandler h)   => _chatHandlers.add(h);
  void unregisterChatHandler(MsgHandler h) => _chatHandlers.remove(h);

  // ── close ─────────────────────────────────────────────────────────────────

  void close() {
    _disposed = true;
    _cancelStream();
    _myParticipantId = null;
  }
}