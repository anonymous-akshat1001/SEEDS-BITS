import '../l10n/speech.dart';
import 'announce.dart';

/// Spoken text for the administrator dashboard.
abstract final class AdminText {
  static String get saveFailed => Speech.t.adminSaveFailed;

  static String _position(int index, int total) =>
      Speech.t.dashboardPosition('${index + 1}', '$total');

  /// "Class: Class 5, 2 of 6. Use left or right to change".
  static String choiceLabel(String what, String name, int index, int total) =>
      total > 1
      ? Speech.t.adminChoiceLabel(what, name, _position(index, total))
      : Speech.t.adminChoiceLabelSingle(what, name);

  /// Spoken after left or right: "Class 5, 2 of 6."
  static String choiceChanged(String name, int index, int total) => total > 1
      ? Speech.t.adminChoiceChanged(name, _position(index, total))
      : Speech.t.adminChoiceChangedSingle(name);

  static String classAndSubject(String className, String subject) =>
      Speech.t.adminClassAndSubject(className, subject);

  static String get noSubjects => Speech.t.adminNoSubjects;

  /// Star summary: "Section: accounts. Showing 12 students. Filter: all."
  static String state({
    required String section,
    required int shown,
    String? filter,
    String search = '',
  }) {
    final t = Speech.t;
    return Announce.pick(
      brief: '${t.adminStateSection(section)} ${t.adminStateShown(shown)}',
      detailed: [
        t.adminStateSection(section),
        t.adminStateShown(shown),
        if (filter != null) t.adminStateFilter(filter),
        if (search.isNotEmpty) t.adminStateSearch(search),
      ].join(' '),
    );
  }

  static String get noSubjectName => Speech.t.adminNoSubjectName;
  static String get noClassName => Speech.t.adminNoClassName;
  static String get noActiveSubjects => Speech.t.adminNoActiveSubjects;
}
