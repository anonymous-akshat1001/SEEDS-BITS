import 'dart:async';
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/screens/session_screen.dart';
import 'package:frontend/services/tts_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _ClassServer {
  final events = StreamController<List<int>>();
  final acknowledgment = Completer<http.StreamedResponse>();
  int actions = 0;
  bool offlineActions = false;
  final actionBodies = <Map<String, dynamic>>[];
  final audioControls = <Map<String, dynamic>>[];
  final activityRequests = <String>[];
  Map<String, dynamic> left = const {};
  Map<String, dynamic> activities = const {
    'current': null,
    'quizzes': [],
    'journeys': [],
  };
  (int, Map<String, dynamic>) quizStart = (
    409,
    {'detail': 'This quiz is closed.'},
  );
  late final client = MockClient.streaming((request, body) async {
    final path = request.url.path;
    if (path.endsWith('/activities') ||
        path.contains('/activity') ||
        path.startsWith('/student/quizzes/')) {
      final sent = await utf8.decodeStream(body);
      activityRequests.add('${request.method} $path $sent'.trim());
      final (status, reply) = path.endsWith('/activities')
          ? (200, activities)
          : path.endsWith('/activity/left')
          ? (200, left)
          : path.endsWith('/activity/remind')
          ? (200, {'ok': true, 'reminded': 1})
          : path.startsWith('/student/quizzes/')
          ? quizStart
          : (
              200,
              {
                'ok': true,
                'activity': {
                  ...jsonDecode(sent) as Map<String, dynamic>,
                  'title': 'Plants',
                },
              },
            );
      return http.StreamedResponse(
        Stream.value(utf8.encode(jsonEncode(reply))),
        status,
      );
    }
    if (request.url.path.startsWith('/sse/')) {
      return http.StreamedResponse(
        events.stream,
        200,
        headers: {'content-type': 'text/event-stream'},
      );
    }
    if (request.url.path.endsWith('/audio/control')) {
      audioControls.add(
        jsonDecode(await utf8.decodeStream(body)) as Map<String, dynamic>,
      );
      return http.StreamedResponse(
        Stream.value(utf8.encode('{"ok":true}')),
        200,
      );
    }
    if (request.method == 'DELETE' && request.url.path.endsWith('/audio')) {
      audioControls.add({'action': 'close'});
      return http.StreamedResponse(
        Stream.value(utf8.encode('{"ok":true}')),
        200,
      );
    }
    if (request.url.path.endsWith('/action')) {
      if (offlineActions) throw http.ClientException('offline');
      actions++;
      final decoded = jsonDecode(await utf8.decodeStream(body));
      if (decoded is! Map<String, dynamic>) throw StateError('Invalid action');
      actionBodies.add(decoded);
      return acknowledgment.future;
    }
    final response = request.method == 'POST'
        ? '{"ok":true,"participant_id":11}'
        : '[]';
    return http.StreamedResponse(Stream.value(utf8.encode(response)), 200);
  });

  void emit(Map<String, dynamic> data) =>
      events.add(utf8.encode('data: ${jsonEncode(data)}\n\n'));

  void acknowledge(
    int status, {
    Map<String, dynamic> body = const {'ok': true},
  }) => acknowledgment.complete(
    http.StreamedResponse(Stream.value(utf8.encode(jsonEncode(body))), status),
  );
}

Future<void> _withClass(
  WidgetTester tester,
  _ClassServer server,
  Future<void> Function() check, {
  bool teacher = false,
  double textScale = 1,
  Size size = const Size(240, 320),
}) => http.runWithClient(() async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  try {
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        routes: {
          '/student_dashboard': (_) =>
              const Scaffold(body: Text('Returned to dashboard')),
          '/teacher_dashboard': (_) =>
              const Scaffold(body: Text('Returned to dashboard')),
          '/login': (_) => const Scaffold(body: Text('Sign-in required')),
        },
        home: SessionScreen(
          sessionId: 42,
          userId: 7,
          userName: 'Test user',
          isTeacher: teacher,
        ),
      ),
    );
    await tester.pump();
    server.emit({'type': 'connected', 'participant_id': 11});
    server.emit({
      'type': 'session_state',
      'participant_id': 11,
      'participants': {
        '11': {'user_id': 7, 'name': 'Test user', 'is_muted': false},
      },
      'playback': {'status': 'stopped'},
    });
    await tester.pumpAndSettle();
    await check();
  } finally {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    unawaited(server.events.close());
    await TtsService.stop();
  }
}, () => server.client);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final captureChanges = <bool>[];
  final spoken = <String>[];
  final voiceCalls = <MethodCall>[];
  final audioCalls = <MethodCall>[];
  var denyCapture = false;

  setUp(() async {
    captureChanges.clear();
    spoken.clear();
    voiceCalls.clear();
    audioCalls.clear();
    denyCapture = false;
    dotenv.testLoad(fileInput: 'API_BASE_URL=https://example.test');
    SharedPreferences.setMockInitialValues({
      'token': 'test-account',
      'user_id': 7,
      'microphone_permission_explained': true,
    });
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
      const MethodChannel('plugin.csdcorp.com/speech_to_text'),
      (call) async {
        voiceCalls.add(call);
        return true;
      },
    );
    messenger.setMockMethodCallHandler(const MethodChannel('flutter_tts'), (
      call,
    ) async {
      if (call.method == 'speak') {
        final arguments = call.arguments;
        final text = arguments is Map ? arguments['text'] : arguments;
        if (text is! String) throw StateError('Unexpected speech arguments');
        spoken.add(text);
      }
      return 1;
    });
    for (final channel in [
      'xyz.luan/audioplayers.global',
      'xyz.luan/audioplayers.global/events',
      'FlutterWebRTC.Event',
    ]) {
      messenger.setMockMethodCallHandler(
        MethodChannel(channel),
        (_) async => null,
      );
    }
    messenger.setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers'),
      (call) async {
        audioCalls.add(call);
        if (call.method == 'create') {
          final id = (call.arguments as Map)['playerId'];
          messenger.setMockMethodCallHandler(
            MethodChannel('xyz.luan/audioplayers/events/$id'),
            (_) async => null,
          );
        }
        return null;
      },
    );
    messenger.setMockMethodCallHandler(
      const MethodChannel('FlutterWebRTC.Method'),
      (call) async {
        if (call.method == 'getUserMedia') {
          if (denyCapture) throw PlatformException(code: 'permission_denied');
          return {
            'streamId': 'local',
            'audioTracks': [
              {
                'id': 'microphone',
                'kind': 'audio',
                'label': 'Microphone',
                'enabled': true,
              },
            ],
            'videoTracks': [],
          };
        }
        if (call.method == 'mediaStreamTrackSetEnable') {
          final enabled = (call.arguments as Map)['enabled'];
          if (enabled is! bool) throw StateError('Unexpected capture flag');
          captureChanges.add(enabled);
        }
        return null;
      },
    );
    await AudioPlayer.global.ensureInitialized();
    await TtsService.stop();
    await TtsService.configure(enabled: true, mode: SpeechMode.selfVoicing);
  });

  Future<void> voiceResult(WidgetTester tester, String words) async {
    await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .handlePlatformMessage(
          'plugin.csdcorp.com/speech_to_text',
          const StandardMethodCodec().encodeMethodCall(
            MethodCall(
              'textRecognition',
              jsonEncode({
                'finalResult': true,
                'alternates': [
                  {'recognizedWords': words, 'confidence': 0.99},
                ],
              }),
            ),
          ),
          (_) {},
        );
    await tester.pump();
  }

  Future<void> enableVoice() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool('voice_commands_enabled', true);
  }

  Future<void> listen(WidgetTester tester) async {
    for (var press = 0; press < 60; press++) {
      if (FocusManager.instance.primaryFocus?.debugLabel ==
          'session-listen-command') {
        break;
      }
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump(const Duration(milliseconds: 200));
    }
    expect(
      FocusManager.instance.primaryFocus?.debugLabel,
      'session-listen-command',
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
  }

  for (final teacher in [false, true]) {
    testWidgets(
      'live session retains reachable controls and muted capture at 240x320 and 3x text: teacher=$teacher',
      (tester) async {
        final server = _ClassServer();
        await _withClass(
          tester,
          server,
          () async {
            final reached = <String>{};
            for (var index = 0; index < 60; index++) {
              await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
              await tester.pump(const Duration(milliseconds: 40));
              reached.add(FocusManager.instance.primaryFocus?.debugLabel ?? '');
            }
            // One short list: the everyday keys, More, then leave.
            expect(reached, {
              'session-mute',
              if (teacher) ...[
                'session-mute-all',
                'session-participants',
                'session-activity',
                'session-end-class',
              ] else ...[
                'session-hand',
                'session-recording',
              ],
              'session-more',
              'session-leave',
            });
            // Chat is under More (teacher 5, student 4); the class keeps running.
            await tester.sendKeyEvent(
              teacher ? LogicalKeyboardKey.digit5 : LogicalKeyboardKey.digit4,
            );
            await tester.pumpAndSettle();
            await tester.sendKeyEvent(
              teacher ? LogicalKeyboardKey.digit2 : LogicalKeyboardKey.digit1,
            );
            await tester.pumpAndSettle();
            expect(find.text('Chat'), findsWidgets);
            expect(find.textContaining('Read messages'), findsOneWidget);
            expect(captureChanges, isNot(contains(true)));
            expect(tester.takeException(), isNull);
          },
          teacher: teacher,
          textScale: 3,
        );
      },
    );
  }

  testWidgets(
    'revoked sign-in immediately mutes native capture and returns to login without leaving with stale credentials',
    (tester) async {
      final server = _ClassServer();
      await _withClass(tester, server, () async {
        await tester.runAsync(() => AudioPlayer.global.ensureInitialized());
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.digit1);
        await tester.pump();
        server.emit({
          'type': 'participant_muted',
          'participant_id': 11,
          'is_muted': false,
        });
        server.acknowledge(200);
        await tester.pumpAndSettle();
        expect(captureChanges.last, isTrue);
        server.emit({'type': 'authentication_revoked'});
        await tester.pumpAndSettle();
        expect(captureChanges.last, isFalse);
        for (
          var i = 0;
          i < 40 && find.text('Sign-in required').evaluate().isEmpty;
          i++
        ) {
          await tester.pump(const Duration(milliseconds: 200));
        }
        expect(find.text('Sign-in required'), findsOneWidget);
        expect(
          audioCalls.where((call) => call.method == 'stop').length,
          greaterThanOrEqualTo(2),
        );
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString('token'), isNull);
        expect(prefs.getInt('user_id'), isNull);
        expect(server.actions, 1);
        expect(find.text('Returned to dashboard'), findsNothing);
      });
    },
  );

  for (final failed in [false, true]) {
    testWidgets(
      'leave needs one confirmation and returns even if the server does not confirm: failure=$failed',
      (tester) async {
        final server = _ClassServer();
        await _withClass(tester, server, () async {
          for (
            var press = 0;
            press < 40 &&
                FocusManager.instance.primaryFocus?.debugLabel !=
                    'session-leave';
            press++
          ) {
            await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
            await tester.pump();
          }
          expect(
            FocusManager.instance.primaryFocus?.debugLabel,
            'session-leave',
          );
          await tester.sendKeyEvent(LogicalKeyboardKey.enter);
          await tester.pump(const Duration(milliseconds: 300));
          await tester.sendKeyEvent(LogicalKeyboardKey.digit1);
          await tester.pump(const Duration(milliseconds: 300));
          expect(server.actionBodies.single['type'], 'leave_session');
          expect(find.text('Returned to dashboard'), findsNothing);
          server.acknowledge(failed ? 503 : 200);
          await tester.pumpAndSettle();
          expect(find.text('Leave without server confirmation?'), findsNothing);
          for (
            var wait = 0;
            wait < 60 && find.text('Returned to dashboard').evaluate().isEmpty;
            wait++
          ) {
            await tester.runAsync(
              () => Future<void>.delayed(const Duration(milliseconds: 10)),
            );
            await tester.pump(const Duration(milliseconds: 100));
          }
          expect(
            find.text('Returned to dashboard'),
            findsOneWidget,
            reason:
                'Visible: ${tester.widgetList<Text>(find.byType(Text)).map((text) => text.data).toList()}. Focus: ${FocusManager.instance.primaryFocus?.debugLabel}. Speech: ${spoken.take(12).toList()}',
          );
          expect(captureChanges, everyElement(isFalse));
        });
      },
    );
  }

  testWidgets(
    'teacher only hears who raised a hand; there is no queue to manage',
    (tester) async {
      final server = _ClassServer();
      await _withClass(tester, server, () async {
        server.emit({
          'type': 'participant_joined',
          'participant_id': 16,
          'user_id': 7,
          'name': 'Asha',
          'is_muted': true,
        });
        await tester.pumpAndSettle();
        spoken.clear();
        server.emit({
          'type': 'hand_raised',
          'participant_id': 16,
          'raised_hand': true,
          'hand_queue_order': 1,
          'hand_revision': 1,
        });
        await tester.pumpAndSettle();
        expect(spoken, contains('Asha raised a hand.'));
        expect(find.textContaining('Raised hands'), findsNothing);
        expect(find.text('Classroom console'), findsNothing);
        await tester.pump(const Duration(seconds: 6));
        await tester.pumpAndSettle();
        expect(captureChanges, everyElement(isFalse));
        expect(tester.takeException(), isNull);
      }, teacher: true);
    },
  );

  testWidgets('a raised hand with no connection goes up when it is back', (
    tester,
  ) async {
    final server = _ClassServer()..offlineActions = true;
    await _withClass(tester, server, () async {
      await tester.sendKeyEvent(LogicalKeyboardKey.digit2);
      await tester.pump(const Duration(seconds: 12));
      expect(
        spoken.join(' '),
        contains('Your hand will go up when the connection is back'),
      );
      expect(server.actions, 0);
      server.offlineActions = false;
      await tester.pump(const Duration(seconds: 4));
      expect(server.actionBodies.single['type'], 'raise_hand');
      server.acknowledge(
        200,
        body: {
          'ok': true,
          'hand_state': {
            'type': 'hand_raised',
            'participant_id': 11,
            'raised_hand': true,
          },
        },
      );
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(find.text('2: Lower hand'), findsOneWidget);
      await tester.pump(const Duration(seconds: 6));
      await tester.pumpAndSettle();
    });
  });

  testWidgets(
    'More, Who is in class lists everyone for a student, teacher first',
    (tester) async {
      final server = _ClassServer();
      await _withClass(tester, server, () async {
        for (final person in [
          {'participant_id': 13, 'user_id': 9, 'name': 'Zara'},
          {
            'participant_id': 12,
            'user_id': 8,
            'name': 'Ms Rao',
            'is_teacher': true,
          },
          {
            'participant_id': 14,
            'user_id': 10,
            'name': 'Asha',
            'raised_hand': true,
          },
        ]) {
          server.emit({
            'type': 'participant_joined',
            'is_muted': true,
            ...person,
          });
        }
        await tester.pumpAndSettle();
        await tester.sendKeyEvent(LogicalKeyboardKey.digit4);
        await tester.pumpAndSettle();
        expect(find.text('2: Who is in class'), findsOneWidget);
        await tester.sendKeyEvent(LogicalKeyboardKey.digit2);
        await tester.pumpAndSettle();
        final rows = tester
            .widgetList<Text>(find.byType(Text))
            .map((text) => text.data ?? '')
            .where(
              (text) =>
                  text.contains(', student') || text.contains(', teacher'),
            )
            .toList();
        expect(rows.length, 4, reason: '$rows');
        expect(rows[0], startsWith('1: Ms Rao, teacher'));
        expect(rows[1], startsWith('2: Test user, you'));
        expect(rows[2], startsWith('3: Asha, student, hand raised'));
        expect(rows[3], startsWith('4: Zara, student'));
        expect(server.actions, 0, reason: 'The list is read only.');
      });
    },
  );

  for (final teacher in [false, true]) {
    testWidgets(
      'main screen shows only the options of the role: teacher=$teacher',
      (tester) async {
        final server = _ClassServer();
        await _withClass(tester, server, () async {
          final teacherOnly = [
            '2: Mute all students',
            '3: Class list',
            '4: Start',
            '6: End class for everyone',
          ];
          final studentOnly = ['2: Raise hand', '3: What is playing'];
          for (final text in teacherOnly) {
            expect(find.text(text), teacher ? findsOneWidget : findsNothing);
          }
          for (final text in studentOnly) {
            expect(find.text(text), teacher ? findsNothing : findsOneWidget);
          }
          // Everything else waits under More; no quiz or journey is open yet.
          for (final text in [
            '2: Raised hands',
            '5: Start quiz: Plants',
            '4: Chat',
            '3: Class status',
            'Class updates',
            '9: Teacher tools',
          ]) {
            expect(find.text(text), findsNothing);
          }
          final more = teacher ? 5 : 4;
          expect(find.text('$more: More'), findsOneWidget);
          // Status (7) appears only while something runs.
          expect(find.textContaining('7: Status'), findsNothing);
          // Joining reads every key once, in one short sentence.
          final joined = spoken.join(' ');
          expect(joined, contains('Press 1 for Mute or unmute, '));
          expect(joined, contains('$more for More options, '));
          expect(joined, contains('0 for Leave class.'));
          expect(joined, isNot(contains('Press 2 for')));
          if (teacher) {
            expect(
              joined,
              contains('4 for Start a quiz, journey or recording, '),
            );
            expect(joined, contains('6 for End class for everyone, '));
          }
          expect(find.text('0: Leave class'), findsOneWidget);
          await tester.sendKeyEvent(
            teacher ? LogicalKeyboardKey.digit5 : LogicalKeyboardKey.digit4,
          );
          await tester.pumpAndSettle();
          expect(
            find.textContaining('Add 15 minutes'),
            teacher ? findsOneWidget : findsNothing,
          );
          expect(find.textContaining('Classroom check'), findsNothing);
          expect(find.textContaining('Invite students'), findsNothing);
          expect(find.textContaining('Chat'), findsOneWidget);
          expect(find.textContaining('Class status'), findsNothing);
        }, teacher: teacher);
      },
    );
  }

  testWidgets(
    'teacher hears one summary after a minute, then names grouped as they join and leave',
    (tester) async {
      final server = _ClassServer();
      await _withClass(tester, server, () async {
        server.emit({
          'type': 'session_state',
          'participants': <String, dynamic>{},
          'playback': <String, dynamic>{},
          'enrolled_students': 5,
        });
        for (final person in [
          {'participant_id': 13, 'user_id': 9, 'name': 'Asha'},
          {'participant_id': 14, 'user_id': 10, 'name': 'Ravi'},
        ]) {
          server.emit({
            'type': 'participant_joined',
            'is_muted': true,
            ...person,
          });
        }
        await tester.pump(const Duration(seconds: 3));
        expect(spoken.join(' '), isNot(contains('joined')));
        // Like the server's keepalive, so the stream stays open.
        await tester.pump(const Duration(seconds: 30));
        server.emit({'type': 'keepalive'});
        await tester.pump(const Duration(seconds: 30));
        expect(spoken.join(' '), contains('2 of 5 students here.'));
        server.emit({
          'type': 'participant_joined',
          'is_muted': true,
          'participant_id': 15,
          'user_id': 11,
          'name': 'Zara',
        });
        await tester.pump(const Duration(milliseconds: 500));
        server.emit({'type': 'participant_left', 'participant_id': 13});
        await tester.pump(const Duration(seconds: 3));
        // The test server sends no keepalives, so a watchdog message may follow.
        expect(spoken, contains('Zara joined. Asha left. 2 of 5 here.'));
      }, teacher: true);
    },
  );

  testWidgets('students are not told each time someone joins', (tester) async {
    final server = _ClassServer();
    await _withClass(tester, server, () async {
      server.emit({
        'type': 'participant_joined',
        'is_muted': true,
        'participant_id': 13,
        'user_id': 9,
        'name': 'Asha',
      });
      await tester.pump(const Duration(seconds: 3));
      expect(spoken.join(' '), isNot(contains('joined')));
    });
  });

  testWidgets('teacher 4 then 1 starts a published quiz; its status is on 7', (
    tester,
  ) async {
    final server = _ClassServer()
      ..activities = {
        'current': null,
        'quizzes': [
          {'kind': 'quiz', 'id': 5, 'title': 'Plants', 'questions': 3},
        ],
        'journeys': [
          {'kind': 'journey', 'id': 8, 'title': 'Leaves'},
        ],
      };
    await _withClass(tester, server, () async {
      await tester.sendKeyEvent(LogicalKeyboardKey.digit4);
      await tester.pumpAndSettle();
      expect(find.textContaining('1: Quiz'), findsOneWidget);
      expect(find.textContaining('2: Journey'), findsOneWidget);
      expect(find.textContaining('3: Recording'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.digit1);
      await tester.pumpAndSettle();
      expect(find.textContaining('Quiz: Plants, 3 questions'), findsOneWidget);
      expect(find.textContaining('Journey: Leaves'), findsNothing);
      await tester.tap(find.textContaining('Quiz: Plants'));
      await tester.pumpAndSettle();
      expect(
        server.activityRequests.last,
        endsWith('/activity {"kind":"quiz","id":5}'),
      );
      expect(spoken.join(' '), contains('Plants is open for the class.'));
      expect(spoken.join(' '), contains('Press 7 for its status'));
      expect(find.text('7: Status of Plants'), findsOneWidget);
    }, teacher: true);
  });

  testWidgets(
    'teacher 7 status: students in class and attempts, who is left, remind',
    (tester) async {
      final server = _ClassServer()
        ..left = {
          'kind': 'quiz',
          'id': 5,
          'title': 'Plants',
          'finished': 1,
          'enrolled': 3,
          'present': 1,
          'started': 2,
          'in_class': [
            {'name': 'Ravi', 'status': 'in_progress', 'in_class': true},
          ],
          'whole_class': [
            {'name': 'Ravi', 'status': 'in_progress', 'in_class': true},
            {'name': 'Zara', 'status': 'not_started', 'in_class': false},
          ],
        };
      await _withClass(tester, server, () async {
        server.emit({
          'type': 'activity_started',
          'kind': 'quiz',
          'id': 5,
          'title': 'Plants',
        });
        await tester.pumpAndSettle();
        await tester.sendKeyEvent(LogicalKeyboardKey.digit7);
        await tester.pumpAndSettle();
        expect(
          spoken.join(' '),
          contains('1 students in class. 2 have attempted it, 1 finished.'),
        );
        expect(find.textContaining('In class, not done (1)'), findsOneWidget);
        expect(
          find.textContaining('Whole class, not done (2)'),
          findsOneWidget,
        );
        expect(find.textContaining('Stop offering Plants'), findsOneWidget);
        await tester.tap(find.textContaining('Whole class, not done'));
        await tester.pumpAndSettle();
        expect(
          find.textContaining('Ravi, started, not finished, in class'),
          findsOneWidget,
        );
        expect(
          find.textContaining('Zara, not started, not in class'),
          findsOneWidget,
        );
        await tester.sendKeyEvent(LogicalKeyboardKey.digit0);
        await tester.pumpAndSettle();
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 350)),
        );
        await tester.sendKeyEvent(LogicalKeyboardKey.digit7);
        await tester.pumpAndSettle();
        expect(find.textContaining('Remind those in class'), findsOneWidget);
        await tester.sendKeyEvent(LogicalKeyboardKey.digit3);
        await tester.pumpAndSettle();
        expect(server.activityRequests.last, contains('POST'));
        expect(server.activityRequests.last, contains('/activity/remind'));
        expect(spoken.join(' '), contains('Reminded 1 student.'));
      }, teacher: true);
    },
  );

  testWidgets(
    'a student hears the quiz, presses 5 once, and hears why it cannot open',
    (tester) async {
      final server = _ClassServer();
      await _withClass(tester, server, () async {
        expect(find.textContaining('5: Start'), findsNothing);
        server.emit({
          'type': 'activity_started',
          'kind': 'quiz',
          'id': 5,
          'title': 'Plants',
        });
        await tester.pumpAndSettle();
        expect(
          spoken.join(' '),
          contains(
            'Your teacher assigned a quiz: Plants. Press 5 to start it.',
          ),
        );
        expect(find.text('5: Start quiz: Plants'), findsOneWidget);
        await tester.sendKeyEvent(LogicalKeyboardKey.digit5);
        await tester.pumpAndSettle();
        expect(
          server.activityRequests.single,
          'POST /student/quizzes/5/attempts {}',
        );
        expect(spoken.join(' '), contains('This quiz is closed.'));
        server.emit({'type': 'activity_stopped'});
        await tester.pumpAndSettle();
        expect(find.text('5: Start quiz: Plants'), findsNothing);
        expect(spoken.last, contains('Plants is closed in class'));
      });
    },
  );

  testWidgets(
    'starting a recording reads the player keys first, then plays it, and 7 returns to the player',
    (tester) async {
      final server = _ClassServer();
      await _withClass(tester, server, () async {
        server.emit({
          'type': 'audio_selected',
          'audio_id': 5,
          'title': 'Plants',
        });
        await tester.pumpAndSettle();
        await tester.sendKeyEvent(LogicalKeyboardKey.digit4);
        await tester.pumpAndSettle();
        spoken.clear();
        await tester.sendKeyEvent(LogicalKeyboardKey.digit3);
        for (var i = 0; i < 8; i++) {
          await tester.pump(const Duration(milliseconds: 100));
        }
        expect(spoken.join(' '), contains('5 for'));
        expect(server.audioControls, isEmpty, reason: 'Keys are read first.');
        await tester.pump(const Duration(seconds: 2));
        await tester.pumpAndSettle();
        expect(server.audioControls.single['action'], 'play');
        await tester.sendKeyEvent(LogicalKeyboardKey.digit0);
        await tester.pumpAndSettle();
        expect(find.text('7: Status of Plants'), findsOneWidget);
        // 7 reopens the player; 8 closes the recording for everyone, like
        // stopping a quiz, and Status goes away.
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 350)),
        );
        await tester.sendKeyEvent(LogicalKeyboardKey.digit7);
        await tester.pumpAndSettle();
        expect(find.text('8: Close recording for the class'), findsOneWidget);
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 350)),
        );
        await tester.sendKeyEvent(LogicalKeyboardKey.digit8);
        await tester.pumpAndSettle();
        expect(server.audioControls.last['action'], 'close');
        expect(spoken.join(' '), contains('Plants is closed for the class.'));
        expect(find.textContaining('7: Status'), findsNothing);
        expect(find.text('Class recording player'), findsNothing);
      }, teacher: true);
    },
  );

  testWidgets('a student hears when the teacher closes the recording', (
    tester,
  ) async {
    final server = _ClassServer();
    await _withClass(tester, server, () async {
      server.emit({
        'type': 'audio_play',
        'audio_id': 5,
        'title': 'Plants',
        'speed': 1.0,
        'position': 0.0,
      });
      await tester.pumpAndSettle();
      spoken.clear();
      server.emit({'type': 'audio_cleared', 'audio_id': 5, 'title': 'Plants'});
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      expect(spoken, contains('Your teacher closed the recording Plants.'));
      await tester.pump(const Duration(seconds: 6));
      await tester.pumpAndSettle();
    });
  });

  testWidgets(
    'confirmed end of class returns the teacher without waiting for the event',
    (tester) async {
      final server = _ClassServer();
      await _withClass(tester, server, () async {
        // 6 End class for everyone, then 1 confirms (0 would cancel).
        await tester.sendKeyEvent(LogicalKeyboardKey.digit6);
        await tester.pumpAndSettle();
        expect(find.text('End class for everyone?'), findsOneWidget);
        await tester.sendKeyEvent(LogicalKeyboardKey.digit1);
        await tester.pump();
        expect(server.actionBodies.single['type'], 'end_session');
        expect(find.text('Returned to dashboard'), findsNothing);
        server.acknowledge(200);
        // No session_ended event is sent: the server's confirmation is enough.
        for (
          var wait = 0;
          wait < 40 && find.text('Returned to dashboard').evaluate().isEmpty;
          wait++
        ) {
          await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 10)),
          );
          await tester.pump(const Duration(milliseconds: 100));
        }
        expect(find.text('Returned to dashboard'), findsOneWidget);
      }, teacher: true);
    },
  );

  testWidgets(
    'voice enabled never listens on join; unmute requires key confirmation and acknowledgment',
    (tester) async {
      await enableVoice();
      final server = _ClassServer();
      await _withClass(tester, server, () async {
        expect(voiceCalls.where((call) => call.method == 'listen'), isEmpty);
        await listen(tester);
        expect(voiceCalls.where((call) => call.method == 'listen').length, 1);
        await voiceResult(tester, 'unmute');
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.text('Unmute your microphone?'), findsOneWidget);
        expect(server.actions, 0);
        expect(captureChanges, everyElement(isFalse));
        expect(voiceCalls.where((call) => call.method == 'cancel'), isNotEmpty);
        await tester.sendKeyEvent(LogicalKeyboardKey.digit2);
        await tester.pump();
        expect(server.actions, 1);
        expect(captureChanges, everyElement(isFalse));
        server.acknowledge(200);
        await tester.pumpAndSettle();
        expect(captureChanges.last, isTrue);
        await tester.pump(const Duration(seconds: 20));
        expect(voiceCalls.where((call) => call.method == 'listen').length, 1);
        expect(tester.takeException(), isNull);
      });
    },
  );

  testWidgets(
    'voice-unmute cancel keeps capture closed; negative phrases are not commands',
    (tester) async {
      await enableVoice();
      final server = _ClassServer();
      await _withClass(tester, server, () async {
        await listen(tester);
        await voiceResult(tester, 'do not unmute');
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.text('Unmute your microphone?'), findsNothing);
        expect(server.actions, 0);
        await listen(tester);
        await voiceResult(tester, 'unmute');
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.text('Unmute your microphone?'), findsOneWidget);
        await tester.sendKeyEvent(LogicalKeyboardKey.digit1);
        await tester.pumpAndSettle();
        expect(server.actions, 0);
        expect(captureChanges, everyElement(isFalse));
      });
    },
  );

  testWidgets(
    'backgrounding ends explicit voice capture without an automatic restart',
    (tester) async {
      await enableVoice();
      final server = _ClassServer();
      await _withClass(tester, server, () async {
        await listen(tester);
        final cancels = voiceCalls
            .where((call) => call.method == 'cancel')
            .length;
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.inactive,
        );
        await tester.pump();
        expect(
          voiceCalls.where((call) => call.method == 'cancel').length,
          cancels + 1,
        );
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
        await voiceResult(tester, 'unmute');
        await tester.pump(const Duration(seconds: 15));
        expect(find.text('Unmute your microphone?'), findsNothing);
        expect(server.actions, 0);
        expect(voiceCalls.where((call) => call.method == 'listen').length, 1);
      });
    },
  );

  testWidgets(
    'app narration cancels voice capture and stale recognition cannot unmute',
    (tester) async {
      await enableVoice();
      final server = _ClassServer();
      await _withClass(tester, server, () async {
        await listen(tester);
        final cancels = voiceCalls
            .where((call) => call.method == 'cancel')
            .length;
        await TtsService.speak('An application announcement.');
        await tester.pump();
        expect(
          voiceCalls.where((call) => call.method == 'cancel').length,
          cancels + 1,
        );
        await voiceResult(tester, 'unmute');
        await tester.pump(const Duration(seconds: 15));
        expect(find.text('Unmute your microphone?'), findsNothing);
        expect(server.actions, 0);
        expect(voiceCalls.where((call) => call.method == 'listen').length, 1);
      });
    },
  );

  for (final teacher in [false, true]) {
    testWidgets('${teacher ? 'teacher' : 'student'} joins muted at 240x320', (
      tester,
    ) async {
      final server = _ClassServer();
      await _withClass(tester, server, () async {
        expect(find.text('1: Unmute'), findsOneWidget);
        expect(captureChanges, isNotEmpty);
        expect(captureChanges, everyElement(isFalse));
        expect(server.actions, 0);
        expect(tester.takeException(), isNull);
      }, teacher: teacher);
    });
  }

  testWidgets('unmute echo plus HTTP failure never enables native capture', (
    tester,
  ) async {
    final server = _ClassServer();
    await _withClass(tester, server, () async {
      await tester.sendKeyEvent(LogicalKeyboardKey.digit1);
      await tester.pump();
      server.emit({
        'type': 'participant_muted',
        'participant_id': 11,
        'is_muted': false,
      });
      await tester.pump();
      expect(captureChanges, everyElement(isFalse));
      server.acknowledge(503);
      await tester.pumpAndSettle();
      expect(find.text('1: Unmute'), findsOneWidget);
      expect(server.actions, 1);
      expect(captureChanges, everyElement(isFalse));
      expect(spoken, isNot(contains('Unmuted')));
    });
  });

  testWidgets(
    'only self-unmute acknowledgment activates; teacher mute disables',
    (tester) async {
      final server = _ClassServer();
      await _withClass(tester, server, () async {
        await tester.sendKeyEvent(LogicalKeyboardKey.digit1);
        await tester.pump();
        server.emit({
          'type': 'participant_muted',
          'participant_id': 11,
          'is_muted': false,
        });
        server.acknowledge(200);
        await tester.pumpAndSettle();
        expect(captureChanges.last, isTrue);
        expect(find.text('1: Mute'), findsOneWidget);
        server.emit({
          'type': 'participant_muted',
          'participant_id': 11,
          'is_muted': true,
        });
        await tester.pumpAndSettle();
        expect(captureChanges.last, isFalse);
        expect(find.text('1: Unmute'), findsOneWidget);
        server.emit({
          'type': 'participant_muted',
          'participant_id': 11,
          'is_muted': false,
        });
        await tester.pumpAndSettle();
        expect(captureChanges.last, isFalse);
        expect(find.text('1: Unmute'), findsOneWidget);
      });
    },
  );

  testWidgets('permission failure exposes recovery, not false unmute', (
    tester,
  ) async {
    denyCapture = true;
    final server = _ClassServer();
    await _withClass(tester, server, () async {
      await tester.sendKeyEvent(LogicalKeyboardKey.digit1);
      // The permission check gives up after 3 seconds on a silent platform.
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
      expect(server.actions, 0);
      expect(captureChanges, isEmpty);
      // Unmute asks for the microphone again; refusal keeps listening.
      expect(
        spoken.any((text) => text.contains('microphone is still off')),
        isTrue,
      );
      expect(spoken, isNot(contains('Unmuted')));
    });
  });

  // Common Android phone sizes, including short ones where the player, tools
  // and action bar together are taller than the screen.
  for (final size in const [Size(360, 640), Size(393, 740), Size(800, 600)]) {
    for (final teacher in [false, true]) {
      testWidgets(
        'playing class audio never overflows at ${size.width.toInt()}x${size.height.toInt()}: teacher=$teacher',
        (tester) async {
          final server = _ClassServer();
          await _withClass(
            tester,
            server,
            () async {
              server.emit({
                'type': 'audio_play',
                'audio_id': 5,
                'title': 'Chapter 3. Plants and their parts',
                'speed': 1.0,
                'position': 0.0,
                'duration': 600,
              });
              await tester.pumpAndSettle();
              final semantics = tester.ensureSemantics();
              expect(
                find.bySemanticsLabel(
                  RegExp('Chapter 3. Plants and their parts'),
                ),
                findsWidgets,
              );
              expect(
                find.text(teacher ? '4: Start' : '3: What is playing'),
                findsOneWidget,
              );
              semantics.dispose();
              expect(tester.takeException(), isNull);
            },
            teacher: teacher,
            size: size,
          );
        },
      );
    }
  }

  for (final teacher in [false, true]) {
    testWidgets(
      'teacher plays class audio from Start; students only hear its status with 3: teacher=$teacher',
      (tester) async {
        final server = _ClassServer();
        await _withClass(
          tester,
          server,
          () async {
            server.emit({
              'type': 'audio_play',
              'audio_id': 5,
              'title': 'Plants',
              'speed': 1.0,
              'position': 0.0,
              'duration': 600,
            });
            await tester.pumpAndSettle();
            if (teacher) {
              // 4 Start, 3 Recording opens the player; inside it, 5 pauses.
              await tester.sendKeyEvent(LogicalKeyboardKey.digit4);
              await tester.pumpAndSettle();
              await tester.sendKeyEvent(LogicalKeyboardKey.digit3);
              await tester.pumpAndSettle();
              expect(find.text('Class recording player'), findsWidgets);
              expect(find.text('5: Pause for class'), findsOneWidget);
              await tester.runAsync(
                () => Future<void>.delayed(const Duration(milliseconds: 350)),
              );
              await tester.sendKeyEvent(LogicalKeyboardKey.digit5);
              await tester.pump();
              expect(find.text('5: Play for class'), findsOneWidget);
            } else {
              // Students hear it with key 3.
              spoken.clear();
              await tester.sendKeyEvent(LogicalKeyboardKey.digit3);
              await tester.pump();
              expect(spoken.last, contains('Plants, playing'));
              expect(spoken.last, contains('Only the teacher'));
            }
            // Lets the time-limited player calls finish.
            await tester.pump(const Duration(seconds: 6));
            await tester.pumpAndSettle();
            if (teacher) {
              expect(server.audioControls.last['action'], 'pause');
            } else {
              // Students never pause, play or move the recording, even locally.
              expect(server.audioControls, isEmpty);
              expect(
                audioCalls.where(
                  (call) =>
                      const {'pause', 'resume', 'seek'}.contains(call.method),
                ),
                isEmpty,
              );
            }
          },
          teacher: teacher,
          size: const Size(360, 640),
        );
      },
    );
  }
}
