import '../utils/spoken_format.dart';
import 'announce.dart';

/// Spoken text for the administrator dashboard.
abstract final class AdminText {
  static const saveFailed =
      'The change could not be saved. Press 1 to refresh, then try again.';

  /// "Class: Class 5, 2 of 6. Use left or right to change".
  static String choiceLabel(String what, String name, int index, int total) =>
      '$what: $name${total > 1 ? ', ${index + 1} of $total' : ''}. Use left or right to change';

  /// Spoken after left or right: "Class 5, 2 of 6."
  static String choiceChanged(String name, int index, int total) =>
      '$name${total > 1 ? ', ${index + 1} of $total' : ''}.';

  static String classAndSubject(String className, String subject) =>
      '$className selected. $subject subject selected.';

  static const noSubjects = 'The selected class has no active subjects.';

  /// Star summary: "Section: accounts. Showing 12 students. Filter: all."
  static String state({
    required String section,
    required int shown,
    String? filter,
    String search = '',
  }) => Announce.pick(
    brief: 'Section: $section. ${SpokenFormat.count(shown, 'item')} shown.',
    detailed: [
      'Section: $section.',
      '${SpokenFormat.count(shown, 'item')} shown.',
      if (filter != null) 'Filter: $filter.',
      if (search.isNotEmpty) 'Search: $search.',
    ].join(' '),
  );

  static const noSubjectName = 'No subject name entered. Nothing was created.';
  static const noClassName = 'No class name entered. Nothing was created.';
  static const noActiveSubjects = 'This class has no active subjects.';
}
