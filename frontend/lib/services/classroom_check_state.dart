import '../l10n/speech.dart';

class ClassroomCheckResponse {
  const ClassroomCheckResponse(this.userId, this.name, this.choice);
  final int userId;
  final String name;
  final String choice;
}

class ClassroomCheckState {
  const ClassroomCheckState({
    this.id,
    this.revision = 0,
    this.open = false,
    this.responses = const [],
  });
  final String? id;
  final int revision;
  final bool open;
  final List<ClassroomCheckResponse> responses;
  /// Answer ids (sent to the server) and their spoken names.
  static Map<String, String> get labels => {
    'understood': Speech.t.classroomChoiceUnderstood,
    'repeat': Speech.t.classroomChoiceRepeat,
    'help': Speech.t.classroomChoiceHelp,
  };

  factory ClassroomCheckState.parse(
    Object? data, {
    required int userId,
    required bool teacher,
  }) {
    if (data is! Map<String, dynamic> ||
        data['type'] != 'classroom_check' ||
        (data['check_id'] != null && data['check_id'] is! String) ||
        data['revision'] is! int ||
        (data['revision'] as int) < 0 ||
        data['open'] is! bool ||
        data['responses'] is! List) {
      throw const FormatException('Classroom check state was unreadable.');
    }
    final responses = <ClassroomCheckResponse>[];
    final ids = <int>{};
    for (final response in data['responses'] as List) {
      if (response is! Map<String, dynamic> ||
          response['user_id'] is! int ||
          !ids.add(response['user_id'] as int) ||
          (!teacher && response['user_id'] != userId) ||
          response['name'] is! String ||
          !labels.containsKey(response['choice'])) {
        throw const FormatException(
          'Classroom check response was unreadable or not private to this account.',
        );
      }
      responses.add(
        ClassroomCheckResponse(
          response['user_id'] as int,
          response['name'] as String,
          response['choice'] as String,
        ),
      );
    }
    if (data['check_id'] == null &&
        (data['open'] == true || responses.isNotEmpty)) {
      throw const FormatException('Classroom check identity was missing.');
    }
    return ClassroomCheckState(
      id: data['check_id'] as String?,
      revision: data['revision'] as int,
      open: data['open'] as bool,
      responses: List.unmodifiable(responses),
    );
  }

  String describe(bool teacher) {
    final t = Speech.t;
    if (id == null) return t.classroomCheckNone;
    final status = open
        ? t.classroomCheckStatusOpen
        : t.classroomCheckStatusClosed;
    final labels = ClassroomCheckState.labels;
    if (!teacher) {
      return t.classroomCheckStudentSummary(
        status,
        responses.isEmpty
            ? t.classroomCheckNoResponseYet
            : t.classroomCheckYourResponse('${labels[responses.single.choice]}'),
      );
    }
    final counts = labels.entries
        .map(
          (entry) => t.classroomCheckLabelValue(
            entry.value,
            '${responses.where((response) => response.choice == entry.key).length}',
          ),
        )
        .join('. ');
    final named = responses
        .map(
          (response) => t.classroomCheckLabelValue(
            response.name,
            '${labels[response.choice]}',
          ),
        )
        .join('. ');
    return t.classroomCheckTeacherSummary(
      responses.length,
      status,
      counts,
      named.isEmpty ? t.classroomCheckNoResponses : named,
    );
  }
}
