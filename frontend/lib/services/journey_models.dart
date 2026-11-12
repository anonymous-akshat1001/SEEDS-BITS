/// Data contracts for learning journeys, shared by teacher and student screens.
library;

enum JourneyStepKind { audio, narration, question, poll }

class JourneyStep {
  const JourneyStep({
    required this.kind,
    this.audioId,
    this.title,
    this.mimeType,
    this.text = '',
    this.options = const [],
    this.correctIndex,
    this.explanation,
    this.replayFrom,
    this.sourceQuestionId,
  });

  final JourneyStepKind kind;
  final int? audioId;
  final String? title;
  final String? mimeType;
  final String text;
  final List<String> options;
  final int? correctIndex;
  final String? explanation;
  final int? replayFrom;
  final int? sourceQuestionId;

  bool get isContent =>
      kind == JourneyStepKind.audio || kind == JourneyStepKind.narration;
  bool get isAnswer => !isContent;

  static int? _int(Object? value) => value is int ? value : null;

  factory JourneyStep.parse(Object? value) {
    if (value is! Map) throw const FormatException('Unreadable journey step');
    final kind = JourneyStepKind.values
        .where((kind) => kind.name == value['kind'])
        .firstOrNull;
    if (kind == null) throw const FormatException('Unknown journey step');
    final options = value['options'];
    final step = JourneyStep(
      kind: kind,
      audioId: _int(value['audio_id']),
      title: value['title'] is String ? value['title'] as String : null,
      mimeType: value['mime_type'] is String
          ? value['mime_type'] as String
          : null,
      text: value['text'] is String ? value['text'] as String : '',
      options: options is List ? options.whereType<String>().toList() : [],
      correctIndex: _int(value['correct_index']),
      explanation: value['explanation'] is String
          ? value['explanation'] as String
          : null,
      replayFrom: _int(value['replay_from']),
      sourceQuestionId: _int(value['source_question_id']),
    );
    final valid = switch (kind) {
      JourneyStepKind.audio => (step.audioId ?? 0) > 0,
      JourneyStepKind.narration => step.text.trim().isNotEmpty,
      JourneyStepKind.question =>
        step.text.trim().isNotEmpty &&
            step.options.length >= 2 &&
            step.options.length <= 4 &&
            step.correctIndex != null &&
            step.correctIndex! >= 0 &&
            step.correctIndex! < step.options.length,
      JourneyStepKind.poll =>
        step.text.trim().isNotEmpty &&
            step.options.length >= 2 &&
            step.options.length <= 4,
    };
    if (!valid) throw const FormatException('Incomplete journey step');
    return step;
  }

  /// Draft payload sent to the server. Server-filled fields are omitted.
  Map<String, dynamic> toDraftJson() => switch (kind) {
    JourneyStepKind.audio => {'kind': 'audio', 'audio_id': audioId},
    JourneyStepKind.narration => {'kind': 'narration', 'text': text},
    JourneyStepKind.question => {
      'kind': 'question',
      'text': text,
      'options': options,
      'correct_index': correctIndex,
      'explanation': explanation,
      'replay_from': replayFrom,
      'source_question_id': sourceQuestionId,
    },
    JourneyStepKind.poll => {'kind': 'poll', 'text': text, 'options': options},
  };

  Map<String, dynamic> toJson() => {
    ...toDraftJson(),
    if (title != null) 'title': title,
    if (mimeType != null) 'mime_type': mimeType,
  };

  JourneyStep copyWith({
    String? text,
    List<String>? options,
    int? correctIndex,
    String? explanation,
    bool clearExplanation = false,
    int? replayFrom,
    bool clearReplay = false,
  }) => JourneyStep(
    kind: kind,
    audioId: audioId,
    title: title,
    mimeType: mimeType,
    text: text ?? this.text,
    options: options ?? this.options,
    correctIndex: correctIndex ?? this.correctIndex,
    explanation: clearExplanation ? null : explanation ?? this.explanation,
    replayFrom: clearReplay ? null : replayFrom ?? this.replayFrom,
    sourceQuestionId: sourceQuestionId,
  );

  /// Short spoken name, for example "Question. What is dal made from?".
  String get spokenName => switch (kind) {
    JourneyStepKind.audio => 'Recording. ${title ?? 'Untitled recording'}',
    JourneyStepKind.narration => 'Narration. $text',
    JourneyStepKind.question => 'Question. $text',
    JourneyStepKind.poll => 'Poll. $text',
  };
}

class JourneySnapshot {
  const JourneySnapshot({
    required this.journeyId,
    required this.revision,
    required this.title,
    required this.steps,
    this.description,
    this.subjectName,
    this.classId,
    this.subjectId,
    this.graded = false,
    this.maxRetries = 1,
  });

  final int journeyId;
  final int revision;
  final String title;
  final String? description;
  final String? subjectName;
  final int? classId;
  final int? subjectId;
  final bool graded;
  final int maxRetries;
  final List<JourneyStep> steps;

  int get questionCount =>
      steps.where((step) => step.kind == JourneyStepKind.question).length;
  List<int> get audioIds => [
    for (final step in steps)
      if (step.kind == JourneyStepKind.audio) step.audioId!,
  ];

  factory JourneySnapshot.parse(Object? value) {
    if (value is! Map ||
        value['journey_id'] is! int ||
        value['revision'] is! int ||
        value['title'] is! String ||
        value['steps'] is! List) {
      throw const FormatException('The journey could not be read.');
    }
    final steps = (value['steps'] as List).map(JourneyStep.parse).toList();
    for (var index = 0; index < steps.length; index++) {
      final replay = steps[index].replayFrom;
      if (replay != null &&
          (replay >= index || replay < 0 || !steps[replay].isContent)) {
        throw const FormatException('The journey replay points are invalid.');
      }
    }
    final retries = value['max_retries'];
    return JourneySnapshot(
      journeyId: value['journey_id'] as int,
      revision: value['revision'] as int,
      title: value['title'] as String,
      description: value['description'] is String
          ? value['description'] as String
          : null,
      subjectName: value['subject_name'] is String
          ? value['subject_name'] as String
          : null,
      classId: value['class_id'] is int ? value['class_id'] as int : null,
      subjectId: value['subject_id'] is int ? value['subject_id'] as int : null,
      graded: value['graded'] == true,
      maxRetries: retries is int && retries >= 0 && retries <= 5 ? retries : 1,
      steps: steps,
    );
  }

  Map<String, dynamic> toJson() => {
    'journey_id': journeyId,
    'revision': revision,
    'title': title,
    'description': description,
    'subject_name': subjectName,
    'class_id': classId,
    'subject_id': subjectId,
    'graded': graded,
    'max_retries': maxRetries,
    'steps': [
      for (final step in steps)
        {...step.toJson(), 'replay_from': step.replayFrom},
    ],
  };
}

/// A teacher's journey with its editable draft.
class JourneyDraft {
  const JourneyDraft({
    required this.journeyId,
    required this.classId,
    required this.subjectId,
    required this.title,
    required this.status,
    required this.revision,
    required this.steps,
    this.description,
    this.graded = false,
    this.maxRetries = 1,
    this.publishedRevision,
    this.hasUnpublishedChanges = false,
    this.stepCount = 0,
    this.questionCount = 0,
  });

  final int journeyId;
  final int classId;
  final int subjectId;
  final String title;
  final String? description;
  final String status;
  final int revision;
  final bool graded;
  final int maxRetries;
  final int? publishedRevision;
  final bool hasUnpublishedChanges;
  final List<JourneyStep> steps;
  final int stepCount;
  final int questionCount;

  bool get isDraft => status == 'draft';
  bool get isPublished => status == 'published';
  bool get isArchived => status == 'archived';

  String get statusWords {
    final base = switch (status) {
      'published' => 'Published',
      'archived' => 'Archived',
      _ => 'Draft, not yet published',
    };
    return hasUnpublishedChanges ? '$base, with unpublished changes' : base;
  }

  factory JourneyDraft.parse(Object? value) {
    if (value is! Map ||
        value['journey_id'] is! int ||
        value['class_id'] is! int ||
        value['subject_id'] is! int ||
        value['revision'] is! int ||
        value['title'] is! String ||
        value['status'] is! String) {
      throw const FormatException('The journey could not be read.');
    }
    final steps = value['steps'] is List
        ? (value['steps'] as List).map(JourneyStep.parse).toList()
        : <JourneyStep>[];
    final retries = value['max_retries'];
    return JourneyDraft(
      journeyId: value['journey_id'] as int,
      classId: value['class_id'] as int,
      subjectId: value['subject_id'] as int,
      title: value['title'] as String,
      description: value['description'] is String
          ? value['description'] as String
          : null,
      status: value['status'] as String,
      revision: value['revision'] as int,
      graded: value['graded'] == true,
      maxRetries: retries is int ? retries : 1,
      publishedRevision: value['published_revision'] is int
          ? value['published_revision'] as int
          : null,
      hasUnpublishedChanges: value['has_unpublished_changes'] == true,
      steps: steps,
      stepCount: value['step_count'] is int
          ? value['step_count'] as int
          : steps.length,
      questionCount: value['question_count'] is int
          ? value['question_count'] as int
          : steps.where((s) => s.kind == JourneyStepKind.question).length,
    );
  }

  Map<String, dynamic> toUpdateJson({
    String? title,
    bool? graded,
    int? maxRetries,
    List<JourneyStep>? steps,
  }) => {
    'revision': revision,
    'title': title ?? this.title,
    'description': description,
    'graded': graded ?? this.graded,
    'max_retries': maxRetries ?? this.maxRetries,
    'steps': [for (final step in steps ?? this.steps) step.toDraftJson()],
  };
}

/// Step-list edits that keep each question's replay point pointing at the
/// same content. A replay point that would no longer be earlier content
/// falls back to automatic.
class JourneySteps {
  const JourneySteps._();

  static List<JourneyStep> move(List<JourneyStep> steps, int from, int to) {
    final order = List<int>.generate(steps.length, (i) => i);
    final moved = order.removeAt(from);
    order.insert(to, moved);
    return _remap(steps, order);
  }

  static List<JourneyStep> remove(List<JourneyStep> steps, int index) {
    final order = List<int>.generate(steps.length, (i) => i)..removeAt(index);
    return _remap(steps, order);
  }

  static List<JourneyStep> replace(
    List<JourneyStep> steps,
    int index,
    JourneyStep step,
  ) {
    final result = [...steps];
    result[index] = step;
    return _remap(result, List<int>.generate(result.length, (i) => i));
  }

  /// The content step a question replays when its replay point is automatic:
  /// the first recording or narration since the previous question or poll.
  static int? autoReplay(List<JourneyStep> steps, int index) {
    var start = 0;
    for (var position = index - 1; position >= 0; position--) {
      if (steps[position].isAnswer) {
        start = position + 1;
        break;
      }
    }
    for (var position = start; position < index; position++) {
      if (steps[position].isContent) return position;
    }
    return null;
  }

  /// [order] lists, for each new position, the old index of its step.
  static List<JourneyStep> _remap(List<JourneyStep> steps, List<int> order) {
    final newIndex = {for (var i = 0; i < order.length; i++) order[i]: i};
    final result = [for (final old in order) steps[old]];
    for (var position = 0; position < result.length; position++) {
      final step = result[position];
      final replay = step.replayFrom;
      if (step.kind != JourneyStepKind.question || replay == null) continue;
      final target = newIndex[replay];
      if (target == null || target >= position || !result[target].isContent) {
        result[position] = step.copyWith(clearReplay: true);
      } else if (target != replay) {
        result[position] = step.copyWith(replayFrom: target);
      }
    }
    return result;
  }
}

/// A published journey as listed for a student.
class StudentJourneySummary {
  const StudentJourneySummary({
    required this.journeyId,
    required this.title,
    required this.revision,
    required this.stepCount,
    required this.questionCount,
    required this.status,
    this.description,
    this.subjectName,
    this.graded = false,
    this.percentage,
  });

  final int journeyId;
  final String title;
  final String? description;
  final String? subjectName;
  final int revision;
  final int stepCount;
  final int questionCount;
  final bool graded;
  final String status;
  final double? percentage;

  factory StudentJourneySummary.parse(Object? value) {
    if (value is! Map ||
        value['journey_id'] is! int ||
        value['title'] is! String ||
        value['revision'] is! int) {
      throw const FormatException('The journey list could not be read.');
    }
    final percentage = value['my_percentage'];
    return StudentJourneySummary(
      journeyId: value['journey_id'] as int,
      title: value['title'] as String,
      description: value['description'] is String
          ? value['description'] as String
          : null,
      subjectName: value['subject_name'] is String
          ? value['subject_name'] as String
          : null,
      revision: value['revision'] as int,
      stepCount: value['step_count'] is int ? value['step_count'] as int : 0,
      questionCount: value['question_count'] is int
          ? value['question_count'] as int
          : 0,
      graded: value['graded'] == true,
      status: value['my_status'] is String
          ? value['my_status'] as String
          : 'new',
      percentage: percentage is num ? percentage.toDouble() : null,
    );
  }
}
