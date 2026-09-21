import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/utils/session_search.dart';

void main() {
  final sessions = <Map<String, dynamic>>[
    {'session_id': 17, 'title': 'English Reading'},
    {'session_id': 204, 'title': 'Mathematics'},
    {'session_id': 31, 'title': 'Music and Stories'},
  ];

  test('empty search lists every session before selection', () {
    expect(filterSessionsByNameOrId(sessions, ''), sessions);
  });

  test('session search matches names and IDs case-insensitively', () {
    expect(
      filterSessionsByNameOrId(sessions, 'reading').single['session_id'],
      17,
    );
    expect(
      filterSessionsByNameOrId(sessions, '204').single['title'],
      'Mathematics',
    );
    expect(
      filterSessionsByNameOrId(sessions, 'MUSIC').single['session_id'],
      31,
    );
  });

  test('nonmatching search returns an empty browsable result set', () {
    expect(filterSessionsByNameOrId(sessions, 'science'), isEmpty);
  });
}
