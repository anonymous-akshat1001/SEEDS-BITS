import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/services/activity_telemetry.dart';
import 'package:frontend/services/learning_playback_controller.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'confirmed playback transitions are deduplicated and contain no titles',
    () async {
      final types = <String>[];
      final controller = LearningPlaybackController(
        seek: (_) async {},
        setSpeed: (_) async {},
        resume: () async {},
        isPlaying: () => false,
        onIssue: (_) {},
      );
      await http.runWithClient(
        () async {
          await controller.prepare(
            7,
            'private-display-title',
            withoutSavedProgress: true,
          );
          controller.activate(offline: true);
          controller.observePlayback(true);
          controller.observePlayback(false);
          controller.observePlayback(false);
          await ActivityTelemetry.waitForPending();
        },
        () => MockClient((request) async {
          expect(request.body, isNot(contains('private-display-title')));
          final event =
              ((jsonDecode(request.body) as Map)['events'] as List).single
                  as Map;
          types.add(event['event_type'] as String);
          expect(event['details'], {'offline': true});
          return http.Response(
            jsonEncode({
              'accepted': [event['event_id']],
              'duplicates': [],
              'rejected': [],
            }),
            200,
          );
        }),
      );
      controller.dispose();
      expect(types, ['learning_play', 'learning_pause']);
    },
  );

  setUp(() async {
    dotenv.testLoad(fileInput: 'API_BASE_URL=http://127.0.0.1:8000');
    SharedPreferences.setMockInitialValues({
      'user_id': 1,
      'token': 'synthetic-test-token',
    });
    ActivityTelemetry.accountChanged();
    await ActivityTelemetry.waitForPending();
  });

  test(
    'removes only acknowledged events and never sends private labels',
    () async {
      expect(
        ActivityTelemetry.enabled,
        isTrue,
        reason: 'Run with --dart-define=TELEMETRY_ENABLED=true',
      );
      final requests = <Map<String, dynamic>>[];
      await http.runWithClient(
        () async {
          ActivityTelemetry.record(
            'bookmark_added',
            audioId: 7,
            details: {'position': 10},
          );
          await ActivityTelemetry.waitForPending();
        },
        () => MockClient((request) async {
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          requests.add(body);
          final event = (body['events'] as List).single as Map<String, dynamic>;
          return http.Response(
            jsonEncode({
              'accepted': [event['event_id']],
              'duplicates': [],
              'rejected': [],
            }),
            200,
          );
        }),
      );
      expect(requests, hasLength(1));
      final event = (requests.single['events'] as List).single as Map;
      expect(event['details'], {'position': 10});
      expect(
        event['event_id'],
        matches(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
        ),
      );
      final prefs = await SharedPreferences.getInstance();
      expect(jsonDecode(prefs.getString('seeds_activity_1')!), isEmpty);

      ActivityTelemetry.record(
        'bookmark_added',
        audioId: 7,
        details: {'label': 'must-never-leave-device'},
      );
      await ActivityTelemetry.waitForPending();
      expect(ActivityTelemetry.syncIssue.value, isNotNull);
      expect(requests, hasLength(1));
    },
  );

  test(
    'network failure retains the event and subsequent events respect backoff',
    () async {
      var calls = 0;
      await http.runWithClient(
        () async {
          ActivityTelemetry.record('learning_play', audioId: 7);
          await ActivityTelemetry.waitForPending();
          ActivityTelemetry.record('learning_pause', audioId: 7);
          await ActivityTelemetry.waitForPending();
        },
        () => MockClient((request) async {
          calls++;
          throw http.ClientException('synthetic network failure');
        }),
      );
      expect(calls, 1);
      final prefs = await SharedPreferences.getInstance();
      expect(jsonDecode(prefs.getString('seeds_activity_1')!), hasLength(2));
      expect(ActivityTelemetry.syncIssue.value, contains('unavailable'));
    },
  );

  test(
    'late acknowledgment cannot overwrite queues after an account switch',
    () async {
      final started = Completer<void>();
      final response = Completer<http.Response>();
      await http.runWithClient(
        () async {
          ActivityTelemetry.record('learning_play', audioId: 7);
          await started.future;
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('user_id', 2);
          await prefs.setString('token', 'second-synthetic-token');
          ActivityTelemetry.accountChanged();
          response.complete(
            http.Response(
              jsonEncode({'accepted': [], 'duplicates': [], 'rejected': []}),
              200,
            ),
          );
          await ActivityTelemetry.waitForPending();
          expect(
            jsonDecode(prefs.getString('seeds_activity_1')!),
            hasLength(1),
          );
          expect(prefs.getString('seeds_activity_2'), isNull);
        },
        () => MockClient((request) {
          started.complete();
          return response.future;
        }),
      );
    },
  );

  test(
    'account transition purges expired data from every account queue',
    () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'seeds_activity_99',
        jsonEncode([
          {
            'occurred_at': DateTime.now()
                .toUtc()
                .subtract(const Duration(days: 31))
                .toIso8601String(),
          },
          {'occurred_at': DateTime.now().toUtc().toIso8601String()},
        ]),
      );
      ActivityTelemetry.accountChanged();
      await ActivityTelemetry.waitForPending();
      expect(jsonDecode(prefs.getString('seeds_activity_99')!), hasLength(1));
    },
  );
}
