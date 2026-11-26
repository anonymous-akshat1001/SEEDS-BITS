import 'dart:async';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/services/message_center.dart';
import 'package:frontend/services/pending_action.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('maps supported HTTP and network failures to safe messages', () {
    expect(
      ApiService.mapFailure(statusCode: 400, responseBody: 'bad input').message,
      'Please check the information and try again.',
    );
    expect(
      ApiService.mapFailure(statusCode: 401, context: 'login').message,
      'Invalid phone number or password.',
    );
    expect(
      ApiService.mapFailure(statusCode: 404, context: 'session join').message,
      'Session not found. Check the session ID and try again.',
    );
    expect(
      ApiService.mapFailure(
        statusCode: 422,
        context: 'registration password',
      ).message,
      'Password must be at least 6 characters.',
    );
    expect(
      ApiService.mapFailure(statusCode: 500).message,
      'The service is not answering right now.',
    );
    expect(
      ApiService.mapFailure(error: Exception('socket')).message,
      'No connection, so that did not go through.',
    );
  });

  group('quiet retries', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({'token': 't', 'user_id': 1});
      dotenv.testLoad(fileInput: 'API_BASE_URL=https://example.test');
    });

    testWidgets('a short connection loss is retried unheard', (tester) async {
      var calls = 0;
      ApiResult<dynamic>? result;
      http.runWithClient(
        () => ApiService.getResult('/me/home').then((value) => result = value),
        () => MockClient((_) async {
          calls++;
          if (calls < 3) throw http.ClientException('offline');
          return http.Response('{"ok":true}', 200);
        }),
      );
      await tester.pump(const Duration(seconds: 5));
      expect(calls, 3);
      expect(result!.isSuccess, isTrue);
    });

    testWidgets('after about 10 seconds the person is told', (tester) async {
      var calls = 0;
      ApiResult<dynamic>? result;
      http.runWithClient(
        () => ApiService.getResult('/me/home').then((value) => result = value),
        () => MockClient((_) async {
          calls++;
          throw http.ClientException('offline');
        }),
      );
      await tester.pump(const Duration(seconds: 9));
      expect(result, isNull);
      await tester.pump(const Duration(seconds: 3));
      expect(result!.failure!.kind, ApiFailureKind.network);
      expect(calls, greaterThan(3));
    });

    testWidgets('a write that timed out is not sent twice', (tester) async {
      var calls = 0;
      ApiResult<Map<String, dynamic>>? result;
      http.runWithClient(
        () => ApiService.postResult(
          '/x',
          const {},
          requestTimeout: const Duration(seconds: 1),
        ).then((value) => result = value),
        () => MockClient((_) {
          calls++;
          return Completer<http.Response>().future;
        }),
      );
      await tester.pump(const Duration(seconds: 12));
      expect(calls, 1);
      expect(result!.failure!.kind, ApiFailureKind.network);
    });
  });

  test('a connection problem ends with the key that tries again', () {
    const network = 'No connection, so that did not go through.';
    MessageCenter.noteKey(3);
    expect(
      MessageCenter.withRetryKey(network),
      '$network Press 3 to try again.',
    );
    expect(
      MessageCenter.withRetryKey('This number is not registered.'),
      'This number is not registered.',
    );
    MessageCenter.noteKey(0);
    expect(MessageCenter.withRetryKey(network), network);
  });

  testWidgets('an action waiting for the connection is sent when it returns', (
    tester,
  ) async {
    var attempts = 0;
    var queued = 0;
    ApiResult<int>? result;
    sendWhenConnected<int>(
      () async {
        attempts++;
        return attempts < 4
            ? const ApiResult.failure(
                ApiFailure(kind: ApiFailureKind.network, message: 'offline'),
              )
            : const ApiResult.success(7);
      },
      stillWanted: () => true,
      onQueued: () => queued++,
    ).then((value) => result = value);
    await tester.pump(const Duration(seconds: 10));
    expect(queued, 1);
    expect(attempts, 4);
    expect(result!.data, 7);
  });
}
