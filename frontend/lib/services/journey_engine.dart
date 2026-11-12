import 'dart:math';

import 'journey_models.dart';

/// What happened after the learner answered.
enum JourneyOutcome {
  /// Correct answer; the journey moves to the next step.
  correct,

  /// Poll answer saved; the journey moves to the next step.
  pollSaved,

  /// Wrong answer; the linked content plays again before the question returns.
  replay,

  /// Wrong answer with no content to replay; the question is asked again.
  tryAgain,

  /// Wrong answer and no tries left; the correct answer is revealed, then move on.
  revealed,
}

class JourneyAnswerRecord {
  const JourneyAnswerRecord({
    required this.stepIndex,
    required this.attempt,
    required this.selectedOption,
    required this.answeredAt,
    this.correct,
  });

  final int stepIndex;
  final int attempt;
  final int selectedOption;
  final DateTime answeredAt;
  final bool? correct;

  Map<String, dynamic> toJson() => {
    'step_index': stepIndex,
    'attempt': attempt,
    'selected_option': selectedOption,
    'answered_at': answeredAt.toUtc().toIso8601String(),
    if (correct != null) 'correct': correct,
  };

  /// Server payload; correctness is always recomputed by the server.
  Map<String, dynamic> toSyncJson() => {
    'step_index': stepIndex,
    'attempt': attempt,
    'selected_option': selectedOption,
    'answered_at': answeredAt.toUtc().toIso8601String(),
  };

  factory JourneyAnswerRecord.parse(Object? value) {
    if (value is! Map ||
        value['step_index'] is! int ||
        value['attempt'] is! int ||
        value['selected_option'] is! int ||
        value['answered_at'] is! String ||
        DateTime.tryParse(value['answered_at'] as String) == null) {
      throw const FormatException('Saved journey answer could not be read.');
    }
    return JourneyAnswerRecord(
      stepIndex: value['step_index'] as int,
      attempt: value['attempt'] as int,
      selectedOption: value['selected_option'] as int,
      answeredAt: DateTime.parse(value['answered_at'] as String),
      correct: value['correct'] is bool ? value['correct'] as bool : null,
    );
  }
}

String newRunId([Random? random]) {
  final source = random ?? Random.secure();
  final bytes = List<int>.generate(16, (_) => source.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;
  final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
      '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
}

/// Pure state machine for one play-through ("run") of a journey.
///
/// Rules: content plays in order. A correct answer or a saved poll moves on.
/// A wrong answer replays the question's linked content (then asks again)
/// until the journey's retries are used, after which the answer is revealed
/// and the journey moves on. Finished questions and polls are skipped if the
/// learner goes back and forward again, so attempts never exceed the limit.
class JourneyEngine {
  JourneyEngine(
    this.snapshot, {
    String? runId,
    DateTime? startedAt,
    DateTime Function()? clock,
  }) : runId = runId ?? newRunId(),
       _clock = clock ?? DateTime.now,
       startedAt = startedAt ?? (clock ?? DateTime.now)();

  final JourneySnapshot snapshot;
  final String runId;
  final DateTime startedAt;
  final DateTime Function() _clock;

  int _index = 0;
  int? _returnTo;
  DateTime? _completedAt;
  final List<JourneyAnswerRecord> _answers = [];
  final Set<int> _done = {};

  int get index => _index;
  int get stepCount => snapshot.steps.length;
  bool get finished => _completedAt != null || snapshot.steps.isEmpty;
  DateTime? get completedAt => _completedAt;
  bool get replaying => _returnTo != null;
  int? get returnTo => _returnTo;
  List<JourneyAnswerRecord> get answers => List.unmodifiable(_answers);
  JourneyStep? get current => finished ? null : snapshot.steps[_index];

  int attemptsUsed(int stepIndex) =>
      _answers.where((answer) => answer.stepIndex == stepIndex).length;

  int get triesLeft {
    final step = current;
    if (step == null || step.kind != JourneyStepKind.question) return 0;
    return snapshot.maxRetries + 1 - attemptsUsed(_index);
  }

  bool isDone(int stepIndex) => _done.contains(stepIndex);

  int get questionCount => snapshot.questionCount;
  int get firstTryCorrect => _answers
      .where((answer) => answer.attempt == 0 && answer.correct == true)
      .length;
  int get wrongAnswers =>
      _answers.where((answer) => answer.correct == false).length;

  JourneyOutcome answer(int option) {
    final step = current;
    if (step == null || !step.isAnswer || _done.contains(_index)) {
      throw StateError('The current step does not accept an answer.');
    }
    if (option < 0 || option >= step.options.length) {
      throw RangeError.index(option, step.options, 'option');
    }
    final attempt = attemptsUsed(_index);
    if (step.kind == JourneyStepKind.poll) {
      _answers.add(
        JourneyAnswerRecord(
          stepIndex: _index,
          attempt: 0,
          selectedOption: option,
          answeredAt: _clock(),
        ),
      );
      _done.add(_index);
      _advance();
      return JourneyOutcome.pollSaved;
    }
    final correct = option == step.correctIndex;
    _answers.add(
      JourneyAnswerRecord(
        stepIndex: _index,
        attempt: attempt,
        selectedOption: option,
        answeredAt: _clock(),
        correct: correct,
      ),
    );
    if (correct) {
      _done.add(_index);
      _advance();
      return JourneyOutcome.correct;
    }
    if (attempt >= snapshot.maxRetries) {
      _done.add(_index);
      _advance();
      return JourneyOutcome.revealed;
    }
    final replay = step.replayFrom;
    if (replay == null) return JourneyOutcome.tryAgain;
    _returnTo = _index;
    _index = replay;
    return JourneyOutcome.replay;
  }

  /// Moves past the current content step.
  void next() {
    final step = current;
    if (step == null) return;
    if (step.isAnswer && !_done.contains(_index)) {
      throw StateError('Answer the question before moving on.');
    }
    _advance();
  }

  void _advance() {
    var target = _index + 1;
    while (target < stepCount) {
      if (_returnTo != null && target == _returnTo) break;
      if (!_done.contains(target)) break;
      target++;
    }
    if (_returnTo != null && target >= _returnTo!) {
      target = _returnTo!;
      _returnTo = null;
    }
    if (target >= stepCount) {
      _completedAt ??= _clock();
      _index = stepCount - 1;
      return;
    }
    _index = target;
  }

  /// Goes back to the nearest earlier recording or narration.
  bool previous() {
    if (finished) return false;
    for (var target = _index - 1; target >= 0; target--) {
      if (snapshot.steps[target].isContent) {
        if (_returnTo == null && snapshot.steps[_index].isAnswer) {
          // Coming back to an unanswered question after reviewing content.
          if (!_done.contains(_index)) _returnTo = _index;
        }
        _index = target;
        return true;
      }
    }
    return false;
  }

  Map<String, dynamic> toJson() => {
    'version': 1,
    'run_id': runId,
    'journey_id': snapshot.journeyId,
    'revision': snapshot.revision,
    'started_at': startedAt.toUtc().toIso8601String(),
    'completed_at': _completedAt?.toUtc().toIso8601String(),
    'index': _index,
    'return_to': _returnTo,
    'done': _done.toList()..sort(),
    'answers': [for (final answer in _answers) answer.toJson()],
  };

  /// Run payload for `/student/journeys/sync`.
  Map<String, dynamic> toSyncJson({bool playedOffline = false}) => {
    'run_id': runId,
    'journey_id': snapshot.journeyId,
    'journey_revision': snapshot.revision,
    'started_at': startedAt.toUtc().toIso8601String(),
    'completed_at': _completedAt?.toUtc().toIso8601String(),
    'played_offline': playedOffline,
    'answers': [for (final answer in _answers) answer.toSyncJson()],
  };

  /// Restores saved progress; throws [FormatException] if it does not match.
  factory JourneyEngine.restore(
    JourneySnapshot snapshot,
    Object? saved, {
    DateTime Function()? clock,
  }) {
    if (saved is! Map ||
        saved['version'] != 1 ||
        saved['journey_id'] != snapshot.journeyId ||
        saved['revision'] != snapshot.revision ||
        saved['run_id'] is! String ||
        saved['started_at'] is! String ||
        saved['index'] is! int ||
        saved['answers'] is! List ||
        saved['done'] is! List) {
      throw const FormatException('Saved journey progress does not match.');
    }
    final started = DateTime.tryParse(saved['started_at'] as String);
    final index = saved['index'] as int;
    final returnTo = saved['return_to'];
    if (started == null ||
        index < 0 ||
        (snapshot.steps.isNotEmpty && index >= snapshot.steps.length) ||
        (returnTo != null &&
            (returnTo is! int || returnTo <= index ||
                returnTo >= snapshot.steps.length))) {
      throw const FormatException('Saved journey progress does not match.');
    }
    final engine = JourneyEngine(
      snapshot,
      runId: saved['run_id'] as String,
      startedAt: started,
      clock: clock,
    );
    engine._index = index;
    engine._returnTo = returnTo as int?;
    final completed = saved['completed_at'];
    if (completed is String) engine._completedAt = DateTime.tryParse(completed);
    for (final value in saved['done'] as List) {
      if (value is int && value >= 0 && value < snapshot.steps.length) {
        engine._done.add(value);
      }
    }
    for (final value in saved['answers'] as List) {
      final answer = JourneyAnswerRecord.parse(value);
      if (answer.stepIndex >= snapshot.steps.length ||
          !snapshot.steps[answer.stepIndex].isAnswer) {
        throw const FormatException('Saved journey progress does not match.');
      }
      engine._answers.add(answer);
    }
    return engine;
  }
}
