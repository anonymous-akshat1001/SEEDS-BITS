import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/screens/audio_library_screen.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> expectKeypadTargets(
  WidgetTester tester,
  Set<String> expected,
) async {
  tester.view.physicalSize = const Size(240, 320);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpAndSettle();
  final reached = <String>{};
  for (var press = 0; press < expected.length * 4 + 30; press++) {
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump(const Duration(milliseconds: 200));
    final label = FocusManager.instance.primaryFocus?.debugLabel;
    if (label != null) reached.add(label);
    if (reached.containsAll(expected)) break;
  }
  expect(reached, containsAll(expected));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'token': 'test-token',
      'user_id': 3,
      'role': 'student',
    });
    dotenv.testLoad(fileInput: 'API_BASE_URL=https://example.test');
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
      const MethodChannel('flutter_tts'),
      (_) async => 1,
    );
    for (final name in [
      'xyz.luan/audioplayers.global',
      'xyz.luan/audioplayers.global/events',
    ]) {
      messenger.setMockMethodCallHandler(
        MethodChannel(name),
        (_) async => null,
      );
    }
    messenger.setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers'),
      (call) async {
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
  });

  testWidgets('D-pad reaches every lesson beyond the subject filter', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(240, 320);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final audio = List.generate(
      25,
      (index) => {
        'audio_id': index + 1,
        'title': 'Lesson ${index + 1}',
        'description': 'Accessible recording',
        'class_id': 1,
        'class_name': 'Class 1',
        'subject_id': 1,
        'subject_name': 'English',
      },
    );
    await http.runWithClient(() async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ClassAudioScreen(
            sessionId: 0,
            sessionTitle: 'Recorded lessons',
          ),
        ),
      );
      await tester.pumpAndSettle();
      final reached = <int>{};
      for (var press = 0; press < 100 && reached.length < 25; press++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pump(const Duration(milliseconds: 200));
        final label = FocusManager.instance.primaryFocus?.debugLabel ?? '';
        if (label.startsWith('audio-item-')) {
          reached.add(int.parse(label.substring('audio-item-'.length)));
        }
      }
      expect(reached, containsAll(List.generate(25, (index) => index + 1)));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    }, () => MockClient((_) async => http.Response(jsonEncode(audio), 200)));
  });

  testWidgets(
    'teacher can reach private preview and broadcast for every item',
    (tester) async {
      final audio = List.generate(
        12,
        (index) => {
          'audio_id': index + 1,
          'title': 'Lesson ${index + 1}',
          'description': 'Teacher recording',
        },
      );
      await http.runWithClient(() async {
        await tester.pumpWidget(
          const MaterialApp(home: AudioLibraryScreen(sessionId: 1)),
        );
        await tester.pumpAndSettle();
        await expectKeypadTargets(tester, {
          'audio-library-back',
          'audio-library-refresh',
          'audio-library-tts',
          'audio-library-pause-session',
          'audio-library-upload',
          for (var id = 1; id <= 12; id++) ...[
            'audio-library-preview-$id',
            'audio-library-broadcast-$id',
          ],
        });
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
      }, () => MockClient((_) async => http.Response(jsonEncode(audio), 200)));
    },
  );

  testWidgets('recorded library exposes search, playlists and every class', (
    tester,
  ) async {
    final sessions = List.generate(
      12,
      (index) => {
        'session_id': index + 1,
        'title': 'English class ${index + 1}',
        'created_by': 2,
        'teacher_name': 'Teacher',
        'class_id': 1,
        'subject_id': 1,
      },
    );
    await http.runWithClient(() async {
      await tester.pumpWidget(
        const MaterialApp(home: OfflineAudioLibraryScreen()),
      );
      await tester.pumpAndSettle();
      expect(
        find.textContaining(RegExp('internet', caseSensitive: false)),
        findsWidgets,
      );
      await expectKeypadTargets(tester, {
        'recorded-library-back',
        'recorded-library-refresh',
        'recorded-library-search',
        'recorded-library-all',
        'recorded-library-playlists',
        for (var id = 1; id <= 12; id++) 'recorded-library-session-$id',
      });
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    }, () => MockClient((_) async => http.Response(jsonEncode(sessions), 200)));
  });

  testWidgets(
    'existing-audio picker reaches items beyond the numeric shortcuts',
    (tester) async {
      final audio = List.generate(
        20,
        (index) => {
          'audio_id': index + 1,
          'title': 'Lesson ${index + 1}',
          'class_id': 1,
          'subject_id': 1,
        },
      );
      await http.runWithClient(() async {
        await tester.pumpWidget(
          MaterialApp(
            home: SelectExistingAudioScreen(
              sessionId: 1,
              classId: 1,
              subjectId: 1,
              currentAudioIds: const {1},
              onAudioAdded: () {},
            ),
          ),
        );
        await tester.pumpAndSettle();
        await expectKeypadTargets(tester, {
          'existing-audio-back',
          'existing-audio-refresh',
          for (var id = 2; id <= 20; id++) 'existing-audio-$id',
        });
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
      }, () => MockClient((_) async => http.Response(jsonEncode(audio), 200)));
    },
  );
}
