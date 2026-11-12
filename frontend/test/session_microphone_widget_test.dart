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
  final actionBodies = <Map<String, dynamic>>[];
  final audioControls = <Map<String, dynamic>>[];
  late final client = MockClient.streaming((request, body) async {
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
    if (request.url.path.endsWith('/action')) {
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
            // One short list: the main keys, then the extras, then leave.
            expect(
              reached,
              containsAll([
                'session-mute',
                'session-status',
                'session-chat',
                'session-recording',
                'session-classroom-check',
                if (teacher) ...[
                  'session-raised-hands',
                  'session-participants',
                  'session-teacher-tools',
                ] else ...[
                  'session-hand',
                  'session-members',
                ],
                'session-read-updates',
                'session-leave',
              ]),
            );
            // Chat is its own screen on key 4; the class keeps running.
            await tester.sendKeyEvent(LogicalKeyboardKey.digit4);
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

  for (final outcome in ['confirmed', 'malformed', 'failed']) {
    testWidgets(
      'student private check native session acknowledgment: $outcome',
      (tester) async {
        final server = _ClassServer();
        await _withClass(tester, server, () async {
          server.emit({
            'type': 'classroom_check',
            'check_id': 'one',
            'revision': 1,
            'open': true,
            'responses': [],
          });
          await tester.pumpAndSettle();
          for (
            var press = 0;
            press < 40 &&
                FocusManager.instance.primaryFocus?.debugLabel !=
                    'session-classroom-check';
            press++
          ) {
            await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
            await tester.pump();
          }
          expect(
            FocusManager.instance.primaryFocus?.debugLabel,
            'session-classroom-check',
          );
          await tester.sendKeyEvent(LogicalKeyboardKey.enter);
          await tester.pumpAndSettle();
          for (
            var press = 0;
            press < 40 &&
                FocusManager.instance.primaryFocus?.debugLabel != 'check-help';
            press++
          ) {
            await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
            await tester.pump();
          }
          await tester.sendKeyEvent(LogicalKeyboardKey.enter);
          await tester.pump();
          expect(server.actionBodies.single, {
            'type': 'check_response',
            'check_id': 'one',
            'choice': 'help',
          });
          expect(
            find.textContaining('No response confirmed yet.'),
            findsOneWidget,
          );
          server.acknowledge(
            outcome == 'failed' ? 503 : 200,
            body: outcome == 'malformed'
                ? {'ok': true}
                : {
                    'ok': true,
                    'check_state': {
                      'type': 'classroom_check',
                      'check_id': 'one',
                      'revision': 2,
                      'open': true,
                      'responses': [
                        {'user_id': 7, 'name': 'Test user', 'choice': 'help'},
                      ],
                    },
                  },
          );
          await tester.pumpAndSettle();
          if (outcome == 'confirmed') {
            expect(
              find.textContaining('Your confirmed response: Need help.'),
              findsOneWidget,
            );
            server.emit({
              'type': 'classroom_check',
              'check_id': 'one',
              'revision': 1,
              'open': true,
              'responses': [],
            });
            await tester.pumpAndSettle();
            expect(
              find.textContaining('Your confirmed response: Need help.'),
              findsOneWidget,
            );
          } else {
            expect(
              find.textContaining('No response confirmed yet.'),
              findsOneWidget,
            );
            expect(
              find.textContaining('Your confirmed response:'),
              findsNothing,
            );
          }
          expect(captureChanges, everyElement(isFalse));
          expect(tester.takeException(), isNull);
        });
      },
    );
  }

  for (final failed in [false, true]) {
    testWidgets(
      'explicit leave clears hand only after acknowledgment or disclosed local exit: failure=$failed',
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
          if (failed) {
            expect(
              find.text('Leave without server confirmation?'),
              findsOneWidget,
            );
            expect(find.text('Returned to dashboard'), findsNothing);
            for (
              var press = 0;
              press < 3 &&
                  FocusManager.instance.primaryFocus?.debugLabel !=
                      'dialog-confirm';
              press++
            ) {
              await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
              await tester.pump();
            }
            expect(
              FocusManager.instance.primaryFocus?.debugLabel,
              'dialog-confirm',
            );
            await tester.sendKeyEvent(LogicalKeyboardKey.enter);
            await tester.pumpAndSettle();
          }
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

  for (final outcome in ['confirmed', 'reraised', 'malformed', 'failed']) {
    testWidgets('teacher console selected-hand acknowledgment: $outcome', (
      tester,
    ) async {
      final server = _ClassServer();
      await _withClass(tester, server, () async {
        server.emit({
          'type': 'hand_raised',
          'participant_id': 11,
          'raised_hand': true,
          'hand_queue_order': 2,
          'hand_revision': 1,
        });
        await tester.pumpAndSettle();
        // Teacher key 2 opens the raised hands queue directly.
        await tester.sendKeyEvent(LogicalKeyboardKey.digit2);
        await tester.pumpAndSettle();
        expect(
          find.descendant(
            of: find.byType(AlertDialog),
            matching: find.text('Classroom console'),
          ),
          findsOneWidget,
        );
        for (
          var press = 0;
          press < 30 &&
              FocusManager.instance.primaryFocus?.debugLabel !=
                  'console-acknowledge';
          press++
        ) {
          await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
          await tester.pump();
        }
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pump();
        expect(server.actions, 1);
        expect(server.actionBodies.single, {
          'type': 'acknowledge_hand',
          'target_participant_id': 11,
          'hand_queue_order': 2,
        });
        expect(find.textContaining('Hand 1 of 1,'), findsOneWidget);
        if (outcome == 'reraised') {
          server.emit({
            'type': 'hand_raised',
            'participant_id': 11,
            'raised_hand': true,
            'hand_queue_order': 3,
            'hand_revision': 3,
          });
        }
        server.acknowledge(
          outcome == 'failed' ? 503 : 200,
          body: outcome == 'malformed'
              ? {'ok': true}
              : {
                  'ok': true,
                  'hand_state': {
                    'type': 'hand_lowered',
                    'participant_id': 11,
                    'raised_hand': false,
                    'hand_queue_order': null,
                    'hand_revision': 2,
                  },
                },
        );
        await tester.pumpAndSettle();
        if (outcome == 'confirmed') {
          expect(find.textContaining('No raised hands'), findsOneWidget);
          expect(
            spoken.any(
              (text) => text.contains('The selected hand was lowered'),
            ),
            isTrue,
          );
        } else {
          expect(find.textContaining('Hand 1 of 1,'), findsOneWidget);
          if (outcome == 'reraised') {
            expect(
              spoken.any(
                (text) => text.contains('Their hand has since changed'),
              ),
              isTrue,
            );
          } else {
            expect(
              find.descendant(
                of: find.byType(AlertDialog),
                matching: find.textContaining(
                  outcome == 'failed'
                      ? 'The action was not confirmed'
                      : 'Hand acknowledgment was not readable',
                ),
              ),
              findsOneWidget,
            );
            expect(
              spoken.any(
                (text) => text.contains('The selected hand was lowered'),
              ),
              isFalse,
            );
          }
        }
        expect(captureChanges, everyElement(isFalse));
        expect(tester.takeException(), isNull);
      }, teacher: true);
    });
  }

  testWidgets('7 lists everyone in the class for a student, teacher first', (
    tester,
  ) async {
    final server = _ClassServer();
    await _withClass(tester, server, () async {
      for (final person in [
        {'participant_id': 13, 'user_id': 9, 'name': 'Zara'},
        {'participant_id': 12, 'user_id': 8, 'name': 'Ms Rao', 'is_teacher': true},
        {'participant_id': 14, 'user_id': 10, 'name': 'Asha', 'raised_hand': true},
      ]) {
        server.emit({'type': 'participant_joined', 'is_muted': true, ...person});
      }
      await tester.pumpAndSettle();
      expect(find.text('7: Who is in class'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.digit7);
      await tester.pumpAndSettle();
      final rows = tester
          .widgetList<Text>(find.byType(Text))
          .map((text) => text.data ?? '')
          .where((text) => text.contains(', student') || text.contains(', teacher'))
          .toList();
      expect(rows.length, 4, reason: '$rows');
      expect(rows[0], startsWith('1: Ms Rao, teacher'));
      expect(rows[1], startsWith('2: Test user, you'));
      expect(rows[2], startsWith('3: Asha, student, hand raised'));
      expect(rows[3], startsWith('4: Zara, student'));
      expect(server.actions, 0, reason: 'The list is read only.');
    });
  });

  for (final teacher in [false, true]) {
    testWidgets('main screen shows only the options of the role: teacher=$teacher', (
      tester,
    ) async {
      final server = _ClassServer();
      await _withClass(tester, server, () async {
        final teacherOnly = [
          '2: Raised hands',
          '7: Participants',
          '9: Teacher tools',
          '5: Recording player',
        ];
        final studentOnly = [
          '2: Raise hand',
          '7: Who is in class',
          '5: Recording status',
        ];
        for (final text in teacherOnly) {
          expect(find.text(text), teacher ? findsOneWidget : findsNothing);
        }
        for (final text in studentOnly) {
          expect(find.text(text), teacher ? findsNothing : findsOneWidget);
        }
        spoken.clear();
        await tester.sendKeyEvent(LogicalKeyboardKey.digit3);
        await tester.pump();
        expect(
          spoken.last.contains('Hand down'),
          !teacher,
          reason: 'Teachers have no hand to raise: ${spoken.last}',
        );
        if (teacher) {
          // 9 Teacher tools, and the raised hands queue is one key away.
          await tester.sendKeyEvent(LogicalKeyboardKey.digit9);
          await tester.pumpAndSettle();
          expect(find.textContaining('Invite students'), findsOneWidget);
          expect(find.textContaining('End class for everyone'), findsOneWidget);
        } else {
          // Key 9 does nothing for a student.
          await tester.sendKeyEvent(LogicalKeyboardKey.digit9);
          await tester.pumpAndSettle();
          expect(find.textContaining('Invite students'), findsNothing);
        }
      }, teacher: teacher);
    });
  }

  testWidgets(
    'confirmed end of class returns the teacher without waiting for the event',
    (tester) async {
      final server = _ClassServer();
      await _withClass(tester, server, () async {
        // 9 Teacher tools, 2 End class, then 1 confirms (0 would cancel).
        await tester.sendKeyEvent(LogicalKeyboardKey.digit9);
        await tester.pumpAndSettle();
        await tester.sendKeyEvent(LogicalKeyboardKey.digit2);
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
      await tester.pumpAndSettle();
      expect(server.actions, 0);
      expect(captureChanges, isEmpty);
      expect(
        spoken.any((text) => text.contains('Check microphone permission')),
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
                find.text(
                  teacher ? '5: Recording player' : '5: Recording status',
                ),
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
      '5 controls class audio for teachers; students only hear its status: teacher=$teacher',
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
              // 5 opens the recording player; inside it, 5 pauses for the class.
              expect(find.text('5: Recording player'), findsOneWidget);
              await tester.sendKeyEvent(LogicalKeyboardKey.digit5);
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
              expect(find.text('5: Recording status'), findsOneWidget);
              spoken.clear();
              await tester.sendKeyEvent(LogicalKeyboardKey.digit5);
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
                  (call) => const {'pause', 'resume', 'seek'}.contains(call.method),
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
