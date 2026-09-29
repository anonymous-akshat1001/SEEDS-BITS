import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/utils/class_access_utils.dart';
import 'package:frontend/utils/keypad_actions.dart';

void main() {
  test('subject filter returns only matching class-safe sessions', () {
    final sessions = <dynamic>[
      {'session_id': 1, 'subject_id': 10, 'title': 'English'},
      {'session_id': 2, 'subject_id': 20, 'title': 'Maths'},
      {'session_id': 3, 'subject_id': 10, 'title': 'Reading'},
    ];

    expect(
      filterSessionsBySubject(sessions, 10).map((entry) => entry['session_id']),
      [1, 3],
    );
    expect(filterSessionsBySubject(sessions, null), hasLength(3));
  });

  test('playlist reorder moves one item without losing item identity', () {
    expect(movePlaylistItem([11, 22, 33], 1, -1), [22, 11, 33]);
    expect(movePlaylistItem([11, 22, 33], 1, 1), [11, 33, 22]);
    expect(movePlaylistItem([11, 22, 33], 0, -1), [11, 22, 33]);
  });

  test('dashboard keypad maps expose playlist entries', () {
    expect(studentDashboardKeyLabels[4], contains('Private Playlists'));
    expect(teacherDashboardKeyLabels[5], contains('Class Playlists'));
  });
}
