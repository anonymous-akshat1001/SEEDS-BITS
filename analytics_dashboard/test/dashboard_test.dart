import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seeds_analytics/main.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  Future<void> signIn(WidgetTester tester) async {
    await tester.enterText(find.byType(TextField).first, '123');
    await tester.enterText(find.byType(TextField).last, 'synthetic-password');
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();
  }

  http.Response login(String role) => http.Response(
    jsonEncode({
      'access_token': 'synthetic-token',
      'role': role,
      'must_change_password': false,
    }),
    200,
  );

  testWidgets('dashboard starts without collecting audio or showing queries', (
    tester,
  ) async {
    await tester.pumpWidget(const AnalyticsApp());
    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('Record English question'), findsNothing);
    expect(find.byType(TextField), findsNWidgets(2));
  });

  test('voice PCM is wrapped in a bounded mono 16kHz WAV', () {
    final result = wav(Uint8List.fromList([1, 2, 3, 4]));
    expect(String.fromCharCodes(result.sublist(0, 4)), 'RIFF');
    expect(result.length, 48);
    expect(ByteData.sublistView(result).getUint32(24, Endian.little), 16000);
    expect(ByteData.sublistView(result).getUint32(40, Endian.little), 4);
  });

  testWidgets(
    'teacher queries retain only ephemeral filters, not raw questions',
    (tester) async {
      final requests = <Map<String, dynamic>>[];
      final client = MockClient((request) async {
        if (request.url.path == '/auth/login') return login('teacher');
        requests.add(jsonDecode(request.body) as Map<String, dynamic>);
        return http.Response(
          jsonEncode({
            'answer': 'Sessions created: 3.',
            'count': 3,
            'filters': {'teacher': 'Teacher X'},
            'as_of': '2026-01-01T00:00:00Z',
            'coverage': 'Synthetic coverage',
            'intent': {'metric': 'sessions_created', 'teacher': 'Teacher X'},
            'rows': [],
            'has_more': false,
          }),
          200,
        );
      });
      await tester.pumpWidget(AnalyticsApp(client: client));
      await signIn(tester);
      expect(find.text('Health'), findsNothing);
      await tester.enterText(
        find.byType(TextField).first,
        'How many sessions?',
      );
      await tester.tap(find.text('Ask'));
      await tester.pumpAndSettle();
      expect(requests.single.containsKey('context'), isFalse);
      await tester.enterText(find.byType(TextField).first, 'And openings?');
      await tester.tap(find.text('Ask'));
      await tester.pumpAndSettle();
      expect(requests.last['context'], {
        'metric': 'sessions_created',
        'teacher': 'Teacher X',
      });
      expect(
        jsonEncode(requests.last['context']),
        isNot(contains('How many sessions?')),
      );
      await tester.pump(const Duration(minutes: 5));
      expect(
        (tester.widget(find.byType(TextField).first) as TextField)
            .controller!
            .text,
        isEmpty,
      );
      expect(
        find.textContaining('Conversation context cleared'),
        findsOneWidget,
      );
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  for (final size in const [Size(360, 740), Size(1280, 800)]) {
    testWidgets('admin layout fits a ${size.width.toInt()}px wide screen', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final client = MockClient((request) async {
        if (request.url.path == '/auth/login') return login('admin');
        if (request.url.path == '/analytics/health') {
          return http.Response(
            jsonEncode({
              'database': 'reachable',
              'diagnostics': {'last_error': null},
              'collection_enabled': true,
              'model_enabled': false,
              'runtime': 'not_selected',
              'speech_enabled': false,
              'smtp_configured': false,
              'maintenance': [
                {
                  'name': 'retention',
                  'status': 'ok',
                  'succeeded_at': '2026-01-01T00:00:00',
                  'count': 4,
                },
              ],
              'daily': [
                {'day': '2026-01-01', 'requests': 120, 'errors': 2},
              ],
              'chart_coverage': 'Last 30 days.',
              'deployment_gates': ['Benchmark campus runtime'],
            }),
            200,
          );
        }
        return http.Response(
          jsonEncode({
            'answer': 'Activity groups: 2.',
            'count': 2,
            'filters': {'teacher': 'Teacher X', 'class_name': 'Class 6'},
            'as_of': '2026-01-01T00:00:00Z',
            'coverage': 'Synthetic coverage',
            'intent': {'metric': 'activity_counts'},
            'rows': [
              {'event_type': 'session_join', 'source': 'app', 'count': 5},
            ],
            'has_more': true,
          }),
          200,
        );
      });
      await tester.pumpWidget(AnalyticsApp(client: client));
      await signIn(tester);
      final phone = size.width < 840;
      expect(find.byType(NavigationBar), phone ? findsOneWidget : findsNothing);
      expect(
        find.byType(NavigationRail),
        phone ? findsNothing : findsOneWidget,
      );
      await tester.tap(find.text('Structured filters'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, 'Activity?');
      await tester.tap(find.text('Ask'));
      await tester.pumpAndSettle();
      expect(find.text('Activity groups: 2.'), findsOneWidget);
      expect(find.text('Next 100 activity groups'), findsOneWidget);
      await tester.tap(find.text('Health'));
      await tester.pumpAndSettle();
      expect(find.text('System status'), findsOneWidget);
      expect(find.text('reachable'), findsOneWidget);
      expect(find.text('retention'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }

  testWidgets(
    'late unauthorized response cannot log out a newly signed-in account',
    (tester) async {
      final response = Completer<http.Response>();
      final client = MockClient((request) async {
        if (request.url.path == '/auth/login') return login('admin');
        return response.future;
      });
      await tester.pumpWidget(AnalyticsApp(client: client));
      await signIn(tester);
      await tester.enterText(
        find.byType(TextField).first,
        'How many sessions?',
      );
      await tester.tap(find.text('Ask'));
      await tester.pump();
      await tester.tap(find.text('Log out'));
      await tester.pumpAndSettle();
      await signIn(tester);
      response.complete(http.Response('{}', 401));
      await tester.pumpAndSettle();
      expect(find.text('Log out'), findsOneWidget);
      expect(find.text('Sign in'), findsNothing);
      expect(find.textContaining('Sign-in expired'), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
