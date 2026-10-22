import 'dart:async';
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/services/sse_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Server {
  int streamRequests = 0;
  int actionRequests = 0;
  int streamStatus = 200;
  String contentType = 'text/event-stream';
  String actionBody = '{"ok":true}';
  int actionStatus = 200;
  Completer<http.StreamedResponse>? actionResponse;
  Completer<http.StreamedResponse>? streamResponse;
  final streams = <StreamController<List<int>>>[];

  late final client = MockClient.streaming((request, body) async {
    if (request.method == 'POST') {
      actionRequests++;
      if (actionResponse != null) return actionResponse!.future;
      return response(actionBody, actionStatus);
    }
    streamRequests++;
    if (streamResponse != null) return streamResponse!.future;
    if (streamStatus != 200) return response('{}', streamStatus);
    final stream = StreamController<List<int>>();
    streams.add(stream);
    return http.StreamedResponse(
      stream.stream,
      200,
      headers: {'content-type': contentType},
    );
  });

  static http.StreamedResponse response(String body, int status) =>
      http.StreamedResponse(Stream.value(utf8.encode(body)), status);

  void emit(Map<String, dynamic> data, {int? index}) =>
      raw('data: ${jsonEncode(data)}\n\n', index: index);

  void raw(String text, {int? index}) =>
      streams[index ?? streams.length - 1].add(utf8.encode(text));

  void connected({int participant = 11}) =>
      emit({'type': 'connected', 'participant_id': participant});

  void dispose() {
    for (final stream in streams) {
      unawaited(stream.close());
    }
  }
}

Future<void> _withService(
  WidgetTester tester,
  _Server server,
  Future<void> Function(SseService, List<Map<String, dynamic>>) check,
) => http.runWithClient(() async {
  final service = SseService();
  final events = <Map<String, dynamic>>[];
  try {
    service.connect('42', 7, events.add);
    await tester.pump();
    await check(service, events);
  } finally {
    service.close();
    server.dispose();
    await tester.pump();
  }
}, () => server.client);

void main() {
  setUp(() {
    dotenv.testLoad(fileInput: 'API_BASE_URL=https://example.test');
    SharedPreferences.setMockInitialValues({
      'token': 'test-account-a',
      'user_id': 7,
    });
  });

  testWidgets(
    'server revocation is terminal and never reconnects with the revoked token',
    (tester) async {
      final server = _Server();
      await _withService(tester, server, (service, events) async {
        server.connected();
        await tester.pump();
        server.emit({'type': 'authentication_revoked'});
        await tester.pump();
        expect(service.state, SessionConnectionState.authenticationExpired);
        expect(
          events.any((event) => event['type'] == 'authentication_revoked'),
          isTrue,
        );
        await tester.pump(const Duration(minutes: 1));
        expect(server.streamRequests, 1);
        expect(service.state, SessionConnectionState.authenticationExpired);
      });
    },
  );

  for (final command
      in <String, Future<ApiResult<Map<String, dynamic>>> Function()>{
        'select': () => ApiService.selectAudio(42, 9),
        'play': () => ApiService.playAudio(42, audioId: 9),
        'pause': () => ApiService.pauseAudio(42),
        'seek': () => ApiService.seekAudio(42, 30),
        'speed': () => ApiService.controlAudio(42, action: 'play', speed: 1.5),
        'mute participant': () => ApiService.muteParticipant(42, 11),
      }.entries) {
    testWidgets(
      'class audio ${command.key} requires a confirmed acknowledgment',
      (tester) async {
        final server = _Server();
        await http.runWithClient(() async {
          expect((await command.value()).isSuccess, isTrue);
          server.actionBody = '{}';
          expect((await command.value()).isSuccess, isFalse);
          server.actionBody = '{"ok":true}';
          server.actionStatus = 503;
          final failure = await command.value();
          expect(failure.isSuccess, isFalse);
          expect(failure.failure!.message, contains('may have reached'));
          expect(server.actionRequests, 3);
        }, () => server.client);
      },
    );
  }

  testWidgets('a departed classroom cannot send an audio command', (
    tester,
  ) async {
    final server = _Server();
    await http.runWithClient(() async {
      final result = await ApiService.playAudio(
        42,
        audioId: 9,
        canSend: () => false,
      );
      expect(result.isSuccess, isFalse);
      expect(server.actionRequests, 0);
    }, () => server.client);
  });

  testWidgets('connection requires a valid participant acknowledgment', (
    tester,
  ) async {
    final server = _Server();
    await _withService(tester, server, (service, events) async {
      expect(service.state, SessionConnectionState.connecting);
      server.connected();
      server.raw(
        'event: session_state\n'
        'data: {"participant_id":11,\n'
        'data: "participants":{"11":{"user_id":7,"raised_hand":true}}}\n\n',
      );
      await tester.pump();
      expect(service.state, SessionConnectionState.connected);
      final snapshot = events.singleWhere((e) => e['type'] == 'session_state');
      expect(snapshot['participants']['11']['raised_hand'], isTrue);
      final chat = <Map<String, dynamic>>[];
      service.registerChatHandler(chat.add);
      server.emit({'type': 'chat', 'from': 11, 'text': 'My message'});
      server.emit({'type': 'chat', 'from': 12, 'text': 'Another message'});
      await tester.pump();
      expect(chat.map((e) => e['is_own']), [true, false]);
    });
  });

  testWidgets('missing credentials never open or retry a stream', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final server = _Server();
    await _withService(tester, server, (service, events) async {
      expect(service.state, SessionConnectionState.authenticationExpired);
      await tester.pump(const Duration(minutes: 2));
      service.reconnect();
      await tester.pump();
      expect(server.streamRequests, 0);
      expect(
        (await service.send({'type': 'chat', 'text': 'No'})).isSuccess,
        isFalse,
      );
      expect(server.actionRequests, 0);
    });
  });

  for (final status in [401, 403, 404, 410]) {
    testWidgets('HTTP $status stops reconnecting until access is renewed', (
      tester,
    ) async {
      final server = _Server()..streamStatus = status;
      await _withService(tester, server, (service, events) async {
        expect(
          service.state,
          status == 401
              ? SessionConnectionState.authenticationExpired
              : SessionConnectionState.unavailable,
        );
        service.reconnect();
        await tester.pump(const Duration(minutes: 2));
        expect(server.streamRequests, 1);
      });
    });
  }

  for (final frame in [
    'data: not json\n\n',
    'data: []\n\n',
    'data: {"type":"connected","participant_id":"11"}\n\n',
    'data: {"type":"connected","participant_id":0}\n\n',
  ]) {
    testWidgets('invalid acknowledgment is not a connected class: $frame', (
      tester,
    ) async {
      final server = _Server();
      await _withService(tester, server, (service, events) async {
        server.raw(frame);
        await tester.pump();
        expect(service.state, SessionConnectionState.reconnecting);
        expect(events.where((e) => e['state'] == 'connected'), isEmpty);
      });
    });
  }

  testWidgets('HTTP 200 with HTML is not a class connection', (tester) async {
    final server = _Server()..contentType = 'text/html';
    await _withService(tester, server, (service, events) async {
      expect(service.state, SessionConnectionState.reconnecting);
      expect(events.where((e) => e['state'] == 'connected'), isEmpty);
    });
  });

  testWidgets('unacknowledged stream expires at exactly ten seconds', (
    tester,
  ) async {
    final server = _Server();
    await _withService(tester, server, (service, events) async {
      await tester.pump(const Duration(milliseconds: 9999));
      expect(service.state, SessionConnectionState.connecting);
      await tester.pump(const Duration(milliseconds: 1));
      expect(service.state, SessionConnectionState.reconnecting);
    });
  });

  testWidgets('connection headers also have a ten-second bound', (
    tester,
  ) async {
    final server = _Server()
      ..streamResponse = Completer<http.StreamedResponse>();
    await _withService(tester, server, (service, events) async {
      await tester.pump(const Duration(milliseconds: 9999));
      expect(service.state, SessionConnectionState.connecting);
      await tester.pump(const Duration(milliseconds: 1));
      expect(service.state, SessionConnectionState.reconnecting);
      server.streamResponse!.complete(_Server.response('', 503));
      await tester.pump();
      expect(server.streamRequests, 1);
    });
  });

  testWidgets('keepalive resets the sixty-second liveness bound', (
    tester,
  ) async {
    final server = _Server();
    await _withService(tester, server, (service, events) async {
      server.connected();
      await tester.pump();
      await tester.pump(const Duration(seconds: 59));
      server.raw(': keep-alive\n\n');
      await tester.pump();
      await tester.pump(const Duration(seconds: 59));
      expect(service.state, SessionConnectionState.connected);
      await tester.pump(const Duration(seconds: 1));
      expect(service.state, SessionConnectionState.reconnecting);
      service.close();
      await tester.pump(const Duration(minutes: 2));
      expect(server.streamRequests, 1);
    });
  });

  testWidgets(
    'retries back off from two to thirty seconds plus bounded jitter',
    (tester) async {
      final server = _Server()..streamStatus = 503;
      await _withService(tester, server, (service, events) async {
        for (final delay in [2000, 4000, 8000, 16000, 30000, 30000]) {
          final before = server.streamRequests;
          await tester.pump(Duration(milliseconds: delay - 1));
          expect(server.streamRequests, before);
          for (
            var jitter = 0;
            jitter <= 250 && server.streamRequests == before;
            jitter++
          ) {
            await tester.pump(const Duration(milliseconds: 1));
          }
          expect(server.streamRequests, before + 1);
        }
        service.close();
        await tester.pump(const Duration(minutes: 2));
        expect(server.actionRequests, 0);
      });
    },
  );

  testWidgets(
    'manual reconnect cancels old streams and receives a new snapshot',
    (tester) async {
      final server = _Server();
      await _withService(tester, server, (service, events) async {
        server.connected();
        await tester.pump();
        service.reconnect();
        await tester.pump();
        expect(server.streams.first.hasListener, isFalse);
        final eventCount = events.length;
        server.emit({'type': 'session_ended'}, index: 0);
        await tester.pump();
        expect(events.length, eventCount);
        server.connected(participant: 22);
        server.emit({'type': 'session_state', 'participants': {}});
        await tester.pump();
        expect(service.state, SessionConnectionState.connected);
        expect(events.last['type'], 'session_state');
        expect(server.streamRequests, 2);
      });
    },
  );

  for (final type in ['session_ended', 'session_ending', 'kicked']) {
    testWidgets('$type is terminal and never replays actions', (tester) async {
      final server = _Server();
      await _withService(tester, server, (service, events) async {
        server.connected();
        server.emit({'type': type});
        await tester.pump();
        expect(
          service.state,
          type == 'kicked'
              ? SessionConnectionState.unavailable
              : SessionConnectionState.ended,
        );
        service.reconnect();
        await tester.pump(const Duration(minutes: 2));
        expect(server.streamRequests, 1);
        expect(server.actionRequests, 0);
      });
    });
  }

  for (final body in ['', '<html>Error</html>', '[]', '{}', '{"ok":false}']) {
    testWidgets('an action requires ok true, not just HTTP 200: $body', (
      tester,
    ) async {
      final server = _Server()..actionBody = body;
      await _withService(tester, server, (service, events) async {
        server.connected();
        await tester.pump();
        final result = await service.send({'type': 'chat', 'text': 'Hello'});
        expect(result.isSuccess, isFalse);
        expect(result.failure!.message.toLowerCase(), contains('check'));
        expect(events.last['type'], 'action_unconfirmed');
        expect(server.actionRequests, 1);
      });
    });
  }

  testWidgets('server failure is unconfirmed, not permission to replay', (
    tester,
  ) async {
    final server = _Server()..actionStatus = 503;
    await _withService(tester, server, (service, events) async {
      final result = await service.send({'type': 'chat', 'text': 'Hello'});
      expect(result.isSuccess, isFalse);
      expect(result.failure!.message, contains('may have reached'));
      expect(server.actionRequests, 1);
    });
  });

  testWidgets('HTTP 401 on an action stops automatic reconnection', (
    tester,
  ) async {
    final server = _Server()..actionStatus = 401;
    await _withService(tester, server, (service, events) async {
      expect((await service.send({'type': 'raise_hand'})).isSuccess, isFalse);
      expect(service.state, SessionConnectionState.authenticationExpired);
      await tester.pump(const Duration(minutes: 2));
      expect(server.streamRequests, 1);
    });
  });

  testWidgets(
    'action timeout is exactly ten seconds and late ack is not replayed',
    (tester) async {
      final server = _Server()
        ..actionResponse = Completer<http.StreamedResponse>();
      await _withService(tester, server, (service, events) async {
        server.connected();
        await tester.pump();
        ApiResult<Map<String, dynamic>>? result;
        unawaited(
          service
              .send({'type': 'chat', 'text': 'Hello'})
              .then((r) => result = r),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 9999));
        expect(result, isNull);
        await tester.pump(const Duration(milliseconds: 1));
        expect(result!.isSuccess, isFalse);
        expect(result!.failure!.message, contains('may have reached'));
        server.actionResponse!.complete(_Server.response('{"ok":true}', 200));
        await tester.pump();
        expect(server.actionRequests, 1);
        expect(result!.isSuccess, isFalse);
      });
    },
  );

  testWidgets(
    'an SSE-only reconnect does not invalidate an HTTP acknowledgment',
    (tester) async {
      final server = _Server()
        ..actionResponse = Completer<http.StreamedResponse>();
      await _withService(tester, server, (service, events) async {
        server.connected();
        await tester.pump();
        final pending = service.send({'type': 'raise_hand'});
        await tester.pump();
        service.reconnect();
        await tester.pump();
        server.connected();
        server.actionResponse!.complete(_Server.response('{"ok":true}', 200));
        expect((await pending).isSuccess, isTrue);
        expect(server.actionRequests, 1);
      });
    },
  );

  testWidgets('switching session invalidates an old acknowledgment', (
    tester,
  ) async {
    final server = _Server()
      ..actionResponse = Completer<http.StreamedResponse>();
    await _withService(tester, server, (service, events) async {
      final pending = service.send({'type': 'chat', 'text': 'Old class'});
      await tester.pump();
      final newEvents = <Map<String, dynamic>>[];
      service.connect('43', 7, newEvents.add);
      await tester.pump();
      server.actionResponse!.complete(_Server.response('{"ok":true}', 200));
      expect((await pending).isSuccess, isFalse);
      expect(
        newEvents.where((e) => e['type'] == 'action_unconfirmed'),
        isEmpty,
      );
    });
  });

  testWidgets(
    'account change during request preparation never posts as new user',
    (tester) async {
      final server = _Server();
      await _withService(tester, server, (service, events) async {
        final prefs = await SharedPreferences.getInstance();
        final pending = service.send({'type': 'chat', 'text': 'Private draft'});
        scheduleMicrotask(() {
          unawaited(prefs.setString('token', 'test-account-b'));
          unawaited(prefs.setInt('user_id', 8));
        });
        final result = await pending;
        expect(result.isSuccess, isFalse);
        expect(server.actionRequests, 0);
      });
    },
  );

  testWidgets(
    'account change discards pending acknowledgment and blocks reconnect',
    (tester) async {
      final server = _Server()
        ..actionResponse = Completer<http.StreamedResponse>();
      await _withService(tester, server, (service, events) async {
        final pending = service.send({'type': 'chat', 'text': 'Private draft'});
        await tester.pump();
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', 'test-account-b');
        await prefs.setInt('user_id', 8);
        server.actionResponse!.complete(_Server.response('{"ok":true}', 200));
        expect((await pending).isSuccess, isFalse);
        service.reconnect();
        await tester.pump();
        expect(service.state, SessionConnectionState.authenticationExpired);
        expect(server.streamRequests, 1);
      });
    },
  );
}
