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
  static const labels = {
    'understood': 'Understood',
    'repeat': 'Please repeat',
    'help': 'Need help',
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
    if (id == null) {
      return 'No current check in the last received classroom state. Refresh to check.';
    }
    final status = open
        ? 'Check open.'
        : 'Check closed. Responses cannot be changed.';
    if (!teacher) {
      return '$status ${responses.isEmpty ? 'No response confirmed yet.' : 'Your confirmed response: ${labels[responses.single.choice]}.'} Only you and the session teacher can read your response. This is not graded.';
    }
    final counts = labels.entries
        .map(
          (entry) =>
              '${entry.value}: ${responses.where((response) => response.choice == entry.key).length}',
        )
        .join('. ');
    final named = responses
        .map((response) => '${response.name}: ${labels[response.choice]}')
        .join('. ');
    return '$status ${responses.length} students responded. $counts. ${named.isEmpty ? 'No responses yet.' : named} Responses are private to you and each responding student, and are not grades.';
  }
}
