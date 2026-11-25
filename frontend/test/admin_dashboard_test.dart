import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/screens/admin_dashboard.dart';
import 'package:frontend/services/admin_setup_api.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'token': 'admin-token',
      'user_id': 1,
      'role': 'admin',
    });
    dotenv.testLoad(fileInput: 'API_BASE_URL=https://example.test');
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
      const MethodChannel('flutter_tts'),
      (_) async => 1,
    );
    for (final name in [
      'xyz.luan/audioplayers',
      'xyz.luan/audioplayers.global',
      'xyz.luan/audioplayers.global/events',
    ]) {
      messenger.setMockMethodCallHandler(
        MethodChannel(name),
        (_) async => null,
      );
    }
  });

  final requests = <http.Request>[];

  /// Answers by "METHOD /path"; anything else is an empty list.
  MockClient server(Map<String, http.Response Function(http.Request)> routes) =>
      MockClient((request) async {
        requests.add(request);
        final handler = routes['${request.method} ${request.url.path}'];
        return handler == null ? http.Response('[]', 200) : handler(request);
      });

  http.Response json(Object body, [int status = 200]) => http.Response.bytes(
    utf8.encode(jsonEncode(body)),
    status,
    headers: {'content-type': 'application/json; charset=utf-8'},
  );

  Future<void> open(WidgetTester tester, AdminSection section) async {
    // Tall enough that every list item and dialog button is laid out.
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(home: AdminDashboard(initialSection: section)),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tap(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  JsonMap? sent(String method, String path) {
    final request = requests
        .where((r) => r.method == method && r.url.path == path)
        .lastOrNull;
    return request == null ? null : jsonDecode(request.body) as JsonMap;
  }

  setUp(requests.clear);

  final classes = [
    {'class_id': 1, 'name': 'Class 5', 'is_active': true, 'sort_order': 0},
  ];
  final classSubjects = [
    {
      'association_id': 3,
      'class_id': 1,
      'subject_id': 2,
      'subject_name': 'Science',
      'is_active': true,
    },
  ];

  Map<String, dynamic> pair(
    int classId,
    String className,
    int subjectId,
    String subjectName,
  ) => {
    'assignment_id': classId * 10 + subjectId,
    'teacher_id': 3,
    'teacher_name': 'Mr Rao',
    'class_id': classId,
    'class_name': className,
    'subject_id': subjectId,
    'subject_name': subjectName,
    'is_active': true,
  };
  final teachers = [
    {
      'user_id': 3,
      'name': 'Mr Rao',
      'role': 'teacher',
      'auth_version': 0,
      'assignments': [pair(1, 'Class 5', 2, 'Science')],
    },
    {
      'user_id': 4,
      'name': 'Ms Iyer',
      'role': 'teacher',
      'auth_version': 0,
      'assignments': [],
    },
  ];

  testWidgets(
    'add person posts a teacher with class and subject pairs; no password reset remains',
    (tester) async {
      await http.runWithClient(
        () async {
          await open(tester, AdminSection.accounts);
          expect(find.textContaining('knows'), findsNothing);
          expect(find.textContaining('Temporary'), findsNothing);
          expect(find.textContaining('Reset'), findsNothing);

          await tap(tester, find.text('Add person'));
          await tester.enterText(
            find.widgetWithText(TextField, 'Name'),
            ' Asha Rao ',
          );
          await tester.enterText(
            find.widgetWithText(TextField, 'Phone number'),
            '9000000001',
          );
          await tap(tester, find.text('Teacher'));
          await tap(tester, find.text('Add class and subject'));
          expect(find.text('Class 5, Science'), findsOneWidget);
          await tap(tester, find.text('Save'));

          expect(sent('POST', '/admin/users'), {
            'name': 'Asha Rao',
            'phone_number': '9000000001',
            'role': 'teacher',
            'assignments': [
              {'class_id': 1, 'subject_id': 2},
            ],
          });
          expect(find.byType(AlertDialog), findsNothing);
        },
        () => server({
          'GET /catalog/classes': (_) => json(classes),
          'GET /admin/classes/1/subjects': (_) => json(classSubjects),
          'POST /admin/users': (_) => json({
            'user_id': 9,
            'name': 'Asha Rao',
            'phone_number': '9000000001',
            'role': 'teacher',
            'is_active': true,
            'auth_version': 0,
          }),
        }),
      );
    },
  );

  testWidgets(
    'a student needs a class; a duplicate phone number shows the server explanation, not JSON',
    (tester) async {
      await http.runWithClient(
        () async {
          await open(tester, AdminSection.accounts);
          await tap(tester, find.text('Add person'));
          await tester.enterText(
            find.widgetWithText(TextField, 'Name'),
            'Ravi',
          );
          await tester.enterText(
            find.widgetWithText(TextField, 'Phone number'),
            '9000000002',
          );
          await tap(tester, find.text('Save'));
          expect(find.text('Class is required.'), findsOneWidget);
          expect(sent('POST', '/admin/users'), isNull);
          await tap(tester, find.byType(DropdownButtonFormField<int>));
          await tap(tester, find.text('Class 5').last);
          await tap(tester, find.text('Save'));
          expect(sent('POST', '/admin/users'), {
            'name': 'Ravi',
            'phone_number': '9000000002',
            'role': 'student',
            'class_id': 1,
          });
          expect(
            find.text('This phone number already belongs to another account.'),
            findsOneWidget,
          );
          expect(find.textContaining('detail'), findsNothing);
        },
        () => server({
          'GET /catalog/classes': (_) => json(classes),
          'POST /admin/users': (_) => json({
            'detail': 'This phone number already belongs to another account.',
          }, 409),
        }),
      );
    },
  );

  testWidgets('sign out everywhere confirms and sends the account version', (
    tester,
  ) async {
    await http.runWithClient(
      () async {
        await open(tester, AdminSection.accounts);
        expect(find.text('Deactivate'), findsOneWidget);
        expect(find.text('Activate'), findsNothing);
        await tap(tester, find.text('Sign out everywhere'));
        expect(find.text('Sign Meena out everywhere?'), findsOneWidget);
        await tap(tester, find.text('Sign out everywhere').last);
        expect(sent('POST', '/admin/users/5/sign-out-everywhere'), {
          'expected_auth_version': 4,
        });
      },
      () => server({
        'GET /catalog/classes': (_) => json(classes),
        'GET /admin/users': (_) => json([
          {
            'user_id': 5,
            'name': 'Meena',
            'phone_number': '9000000005',
            'role': 'student',
            'auth_version': 4,
            'is_active': true,
            'class_id': 1,
            'class_name': 'Class 5',
            'assignments': [],
          },
        ]),
        'POST /admin/users/5/sign-out-everywhere': (_) =>
            json({'ok': true, 'auth_version': 5}),
      }),
    );
  });

  testWidgets('a timetable overlap shows the server message verbatim', (
    tester,
  ) async {
    const overlap =
        'This overlaps Science for Class 5 with Mr Rao (09:00–09:45).';
    await http.runWithClient(
      () async {
        await open(tester, AdminSection.timetable);
        await tap(tester, find.text('Add lesson to timetable'));
        await tester.enterText(
          find.widgetWithText(TextField, 'Start time'),
          '9:00',
        );
        await tester.enterText(
          find.widgetWithText(TextField, 'End time'),
          '09:45',
        );
        await tap(tester, find.text('Save'));
        expect(sent('POST', '/admin/timetable'), {
          'teacher_id': 3,
          'weekday': 0,
          'start_time': '09:00',
          'end_time': '09:45',
          'class_id': 1,
          'subject_id': 2,
        });
        expect(find.text(overlap), findsOneWidget);
      },
      () => server({
        'GET /admin/users': (_) => json(teachers),
        'GET /catalog/classes': (_) => json(classes),
        'POST /admin/timetable': (_) => json({'detail': overlap}, 409),
      }),
    );
  });

  testWidgets(
    'filtering the timetable by a teacher offers only that teacher\'s classes',
    (tester) async {
      await http.runWithClient(
        () async {
          await open(tester, AdminSection.timetable);
          await tap(tester, find.text('All classes'));
          expect(find.text('Class 6'), findsWidgets);
          await tap(tester, find.text('Class 5').last);

          await tap(tester, find.text('All teachers'));
          await tap(tester, find.text('Mr Rao').last);
          await tap(tester, find.text('Class 5'));
          expect(find.text('Class 6'), findsNothing);
          await tap(tester, find.text('Class 5').last);

          // Ms Iyer teaches no class, so the class filter goes back to all.
          await tap(tester, find.text('Mr Rao'));
          await tap(tester, find.text('Ms Iyer').last);
          expect(find.text('All classes'), findsOneWidget);
          final last = requests.lastWhere(
            (r) => r.url.path == '/admin/timetable',
          );
          expect(last.url.queryParameters.containsKey('class_id'), isFalse);
        },
        () => server({
          'GET /admin/users': (_) => json(teachers),
          'GET /catalog/classes': (_) => json([
            ...classes,
            {
              'class_id': 6,
              'name': 'Class 6',
              'is_active': true,
              'sort_order': 1,
            },
          ]),
        }),
      );
    },
  );

  testWidgets(
    'a new lesson offers only the teacher\'s own classes and subjects and can repeat on several days',
    (tester) async {
      await http.runWithClient(
        () async {
          await open(tester, AdminSection.timetable);
          await tap(tester, find.text('Add lesson to timetable'));
          // Ms Iyer teaches nothing, so she cannot be scheduled.
          expect(find.text('Ms Iyer'), findsNothing);
          expect(find.text('Class 6'), findsNothing);
          await tap(tester, find.widgetWithText(FilterChip, 'Wednesday'));
          await tap(tester, find.widgetWithText(FilterChip, 'Friday'));
          await tester.enterText(
            find.widgetWithText(TextField, 'Start time'),
            '10:00',
          );
          await tester.enterText(
            find.widgetWithText(TextField, 'End time'),
            '10:40',
          );
          await tap(tester, find.text('Save'));
          expect(sent('POST', '/admin/timetable'), {
            'teacher_id': 3,
            'weekdays': [0, 2, 4],
            'start_time': '10:00',
            'end_time': '10:40',
            'class_id': 1,
            'subject_id': 2,
          });
          expect(find.byType(AlertDialog), findsNothing);
        },
        () => server({
          'GET /admin/users': (_) => json(teachers),
          'GET /catalog/classes': (_) => json([
            ...classes,
            {'class_id': 2, 'name': 'Class 6', 'is_active': true},
          ]),
          'POST /admin/timetable': (_) => json({
            'entry_id': 1,
            'entries': [{}, {}, {}],
          }),
        }),
      );
    },
  );

  testWidgets('lessons can be arranged by teacher with a count per group', (
    tester,
  ) async {
    Map<String, dynamic> lesson(int id, int day, String teacher, String time) =>
        {
          'entry_id': id,
          'teacher_id': id,
          'teacher_name': teacher,
          'class_id': 1,
          'class_name': 'Class 5',
          'subject_id': 2,
          'subject_name': 'Science',
          'weekday': day,
          'start_time': time,
          'end_time': '11:00',
          'is_active': true,
        };
    await http.runWithClient(
      () async {
        await open(tester, AdminSection.timetable);
        expect(find.text('Monday · 2 lessons'), findsOneWidget);
        await tap(tester, find.widgetWithText(ChoiceChip, 'Teacher'));
        expect(find.text('Mr Rao · 2 lessons'), findsOneWidget);
        expect(find.text('Ms Iyer · 1 lesson'), findsOneWidget);
        expect(find.textContaining('Monday, 09:00'), findsOneWidget);
        await tester.enterText(
          find.widgetWithText(TextField, 'Search lessons'),
          'iyer',
        );
        await tester.pumpAndSettle();
        expect(find.text('Mr Rao · 2 lessons'), findsNothing);
        expect(find.text('Ms Iyer · 1 lesson'), findsOneWidget);
      },
      () => server({
        'GET /admin/users': (_) => json(teachers),
        'GET /catalog/classes': (_) => json(classes),
        'GET /admin/timetable': (_) => json([
          lesson(1, 2, 'Mr Rao', '10:00'),
          lesson(2, 0, 'Mr Rao', '09:00'),
          lesson(3, 0, 'Ms Iyer', '10:00'),
        ]),
      }),
    );
  });

  testWidgets('editing a lesson can clear its first date', (tester) async {
    await http.runWithClient(
      () async {
        await open(tester, AdminSection.timetable);
        await tap(tester, find.text('Edit'));
        await tap(tester, find.text('Clear First date'));
        await tap(tester, find.text('Save'));
        final body = sent('PATCH', '/admin/timetable/4')!;
        expect(body['clear_valid_from'], isTrue);
        expect(body.containsKey('valid_from'), isFalse);
        expect(body.containsKey('clear_valid_until'), isFalse);
      },
      () => server({
        'GET /admin/users': (_) => json([
          {'user_id': 3, 'name': 'Mr Rao', 'role': 'teacher'},
        ]),
        'GET /catalog/classes': (_) => json(classes),
        'GET /admin/timetable': (_) => json([
          {
            'entry_id': 4,
            'teacher_id': 3,
            'teacher_name': 'Mr Rao',
            'class_id': 1,
            'class_name': 'Class 5',
            'subject_id': 2,
            'subject_name': 'Science',
            'weekday': 0,
            'start_time': '09:00',
            'end_time': '09:45',
            'valid_from': '2026-11-02',
            'valid_until': null,
            'lesson_playlist_id': null,
            'lesson_title': null,
            'is_active': true,
          },
        ]),
        'PATCH /admin/timetable/4': (_) => json({'entry_id': 4}),
      }),
    );
  });

  testWidgets('a live class can be ended for everyone after confirming', (
    tester,
  ) async {
    await http.runWithClient(
      () async {
        await open(tester, AdminSection.records);
        expect(find.text('Add 15 minutes'), findsOneWidget);
        await tap(tester, find.text('End class for everyone'));
        expect(requests.where((r) => r.method == 'POST'), isEmpty);
        await tap(tester, find.text('End class'));
        expect(sent('POST', '/admin/sessions/7/end'), isEmpty);
      },
      () => server({
        'GET /admin/sessions': (_) => json([
          {
            'session_id': 7,
            'title': 'Plants',
            'class_name': 'Class 5',
            'subject_name': 'Science',
            'teacher_name': 'Mr Rao',
            'is_active': true,
            'started_at': '2026-11-17T03:30:00Z',
            'cutoff_clock': '09:45',
            'ended_at': null,
            'end_reason': null,
            'extension_minutes': 0,
            'students_joined': 12,
          },
        ]),
        'POST /admin/sessions/7/end': (_) => json({'ok': true}),
      }),
    );
  });

  testWidgets(
    'an administrator creates and publishes a quiz for a teacher with new and bank questions',
    (tester) async {
      JsonMap quiz(String status, List<JsonMap> questions) => {
        'quiz_id': 11,
        'owner_teacher_id': 3,
        'class_id': 1,
        'subject_id': 2,
        'title': 'Plants',
        'description': null,
        'mode': 'graded',
        'feedback_policy': 'after_completion',
        'status': status,
        'display_status': status == 'published' ? 'open' : status,
        'attempt_limit': 1,
        'question_count': questions.length,
        'questions': questions,
      };
      JsonMap question(int id, String text, List<String> options) => {
        'quiz_question_id': id,
        'question_text': text,
        'position': id,
        'options': [
          for (final (index, option) in options.indexed)
            {
              'quiz_option_id': id * 10 + index,
              'option_text': option,
              'position': index,
              'is_correct': index == 0,
            },
        ],
      };
      final typed = question(1, 'Which part makes food?', [
        'Leaf',
        'Root',
        'Stem',
        'Flower',
      ]);
      final banked = question(2, 'Which gas do plants take in?', [
        'Carbon dioxide',
        'Helium',
        'Neon',
        'Argon',
      ]);
      var current = quiz('draft', []);
      var listed = <JsonMap>[];
      await http.runWithClient(
        () async {
          await open(tester, AdminSection.authoring);
          expect(find.text('Mr Rao'), findsOneWidget);
          expect(find.text('Class 5, Science'), findsOneWidget);
          await tap(tester, find.text('New quiz'));
          await tester.enterText(
            find.widgetWithText(TextField, 'Title'),
            ' Plants ',
          );
          await tap(tester, find.text('Save'));
          expect(sent('POST', '/teacher/quizzes'), {
            'class_id': 1,
            'subject_id': 2,
            'title': 'Plants',
            'description': null,
            'mode': 'graded',
          });

          expect(find.text('Edit quiz: Plants'), findsOneWidget);
          await tap(tester, find.text('Type a new question'));
          await tester.enterText(
            find.widgetWithText(TextField, 'Question'),
            'Which part makes food?',
          );
          for (final (index, option) in [
            'Leaf',
            'Root',
            'Stem',
            'Flower',
          ].indexed) {
            await tester.enterText(
              find.widgetWithText(TextField, 'Option ${index + 1}'),
              option,
            );
          }
          await tap(tester, find.text('Save'));
          expect(sent('POST', '/teacher/quizzes/11/questions/new'), {
            'question_text': 'Which part makes food?',
            'options': ['Leaf', 'Root', 'Stem', 'Flower'],
            'correct_option_index': 0,
            'explanation': null,
            'save_to_bank': true,
          });
          expect(find.text('1. Which part makes food?'), findsOneWidget);

          await tap(tester, find.text('Add from question bank'));
          expect(find.text('Which gas do plants take in?'), findsOneWidget);
          await tap(tester, find.text('Add'));
          expect(sent('POST', '/teacher/quizzes/11/questions/from-bank'), {
            'question_id': 21,
          });
          expect(find.text('2. Which gas do plants take in?'), findsOneWidget);
          await tap(tester, find.text('Done'));

          expect(find.text('2 questions'), findsOneWidget);
          await tap(tester, find.text('Publish'));
          expect(find.text('Publish this quiz?'), findsOneWidget);
          await tap(tester, find.text('Publish').last);
          expect(
            requests.any(
              (r) =>
                  r.method == 'POST' &&
                  r.url.path == '/teacher/quizzes/11/publish',
            ),
            isTrue,
          );
          expect(find.text('Published'), findsOneWidget);
          expect(find.text('Close quiz'), findsOneWidget);

          final authoring = requests.where(
            (r) =>
                r.url.path.startsWith('/teacher/') ||
                r.url.path.startsWith('/question-bank'),
          );
          expect(authoring.length, greaterThanOrEqualTo(8));
          for (final request in authoring) {
            expect(request.headers['X-Act-As-Teacher'], '3');
          }
          expect(
            requests.any(
              (r) =>
                  r.method == 'GET' &&
                  r.url.path == '/question-bank' &&
                  r.url.queryParameters['class_id'] == '1' &&
                  r.url.queryParameters['subject_id'] == '2',
            ),
            isTrue,
          );
        },
        () => server({
          'GET /admin/users': (_) => json(teachers),
          'GET /teacher/quizzes': (_) => json(listed),
          'POST /teacher/quizzes': (_) {
            listed = [current];
            return json(current);
          },
          'GET /teacher/quizzes/11': (_) => json(current),
          'POST /teacher/quizzes/11/questions/new': (_) {
            current = quiz('draft', [typed]);
            listed = [current];
            return json(current);
          },
          'GET /question-bank': (_) => json([
            {
              'question_id': 21,
              'owner_teacher_id': 3,
              'class_id': 1,
              'subject_id': 2,
              'question_text': 'Which gas do plants take in?',
              'is_archived': false,
              'options': [
                for (final option in banked['options'] as List)
                  {...option as Map, 'option_id': option['quiz_option_id']},
              ],
            },
          ]),
          'POST /teacher/quizzes/11/questions/from-bank': (_) {
            current = quiz('draft', [typed, banked]);
            listed = [current];
            return json(current);
          },
          'GET /teacher/quizzes/11/readiness': (_) =>
              json({'ready': true, 'errors': []}),
          'POST /teacher/quizzes/11/publish': (_) {
            current = quiz('published', [typed, banked]);
            listed = [current];
            return json(current);
          },
        }),
      );
    },
  );

  testWidgets(
    'a journey recording can only be one the teacher uploaded for that class and subject',
    (tester) async {
      final draft = {
        'journey_id': 5,
        'owner_teacher_id': 3,
        'class_id': 1,
        'subject_id': 2,
        'title': 'Water cycle',
        'status': 'draft',
        'revision': 2,
        'graded': false,
        'max_retries': 1,
        'step_count': 1,
        'question_count': 0,
        'steps': [
          {'kind': 'narration', 'text': 'Rain falls.'},
        ],
      };
      Map<String, dynamic> audio(
        int id,
        String title,
        int owner,
        int classId,
      ) => {
        'audio_id': id,
        'title': title,
        'uploaded_by': owner,
        'class_id': classId,
        'subject_id': 2,
        'class_name': 'Class $classId',
        'subject_name': 'Science',
      };
      await http.runWithClient(
        () async {
          await open(tester, AdminSection.authoring);
          await tap(tester, find.widgetWithText(ChoiceChip, 'Journeys'));
          expect(find.text('Water cycle'), findsOneWidget);
          await tap(tester, find.text('Edit'));
          expect(find.text('1. Narration: Rain falls.'), findsOneWidget);
          await tap(tester, find.text('Add recording'));
          expect(find.text('Leaf song'), findsOneWidget);
          expect(find.text('Iyer lesson'), findsNothing);
          expect(find.text('Other class talk'), findsNothing);
          final listing = requests.lastWhere(
            (r) => r.url.path == '/audio/list',
          );
          expect(listing.headers['X-Act-As-Teacher'], '3');
          expect(listing.url.queryParameters['subject_id'], '2');
          await tap(tester, find.text('Add'));
          expect(find.text('2. Recording: Leaf song'), findsOneWidget);
          await tap(tester, find.text('Save journey'));
          expect(sent('PUT', '/teacher/journeys/5'), {
            'revision': 2,
            'title': 'Water cycle',
            'description': null,
            'graded': false,
            'max_retries': 1,
            'steps': [
              {'kind': 'narration', 'text': 'Rain falls.'},
              {'kind': 'audio', 'audio_id': 31},
            ],
          });
          expect(find.byType(AlertDialog), findsNothing);
        },
        () => server({
          'GET /admin/users': (_) => json(teachers),
          'GET /teacher/journeys': (_) => json({
            'class_id': 1,
            'subject_id': 2,
            'journeys': [draft],
          }),
          'GET /teacher/journeys/5': (_) => json({'journey': draft}),
          // The server lists only the named teacher's uploads; other
          // classes are filtered out on the phone as well.
          'GET /audio/list': (request) => json(
            request.headers['X-Act-As-Teacher'] == '3'
                ? [
                    audio(31, 'Leaf song', 3, 1),
                    audio(32, 'Other class talk', 3, 9),
                  ]
                : [audio(41, 'Iyer lesson', 4, 1)],
          ),
          'PUT /teacher/journeys/5': (_) => json({
            'ok': true,
            'journey': {...draft, 'revision': 3},
          }),
        }),
      );
    },
  );

  for (final width in [400.0, 1200.0]) {
    testWidgets('every section opens without layout errors at width $width', (
      tester,
    ) async {
      await http.runWithClient(() async {
        tester.view.physicalSize = Size(width, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        for (final section in AdminSection.values) {
          await tester.pumpWidget(
            MaterialApp(
              key: ValueKey(section),
              home: AdminDashboard(initialSection: section),
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }
        expect(
          width < 840
              ? find.byType(DropdownButtonFormField<AdminSection>)
              : find.byType(NavigationRail),
          findsOneWidget,
        );
      }, () => server({'GET /catalog/classes': (_) => json(classes)}));
    });
  }

  test('server detail is read from JSON or a printed map, never a list', () {
    expect(AdminSetupApi.serverDetail('{"detail":"Use 09:30."}'), 'Use 09:30.');
    expect(AdminSetupApi.serverDetail('{detail: Use 09:30.}'), 'Use 09:30.');
    expect(AdminSetupApi.serverDetail('{detail: [{type: missing}]}'), isNull);
    expect(AdminSetupApi.serverDetail('{"detail":[{"msg":"x"}]}'), isNull);
  });
}
