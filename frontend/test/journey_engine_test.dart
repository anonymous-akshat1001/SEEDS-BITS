import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/services/journey_engine.dart';
import 'package:frontend/services/journey_models.dart';

JourneySnapshot foodJourney({int maxRetries = 1, bool graded = false}) =>
    JourneySnapshot.parse({
      'journey_id': 7,
      'revision': 2,
      'title': 'Food around us',
      'graded': graded,
      'max_retries': maxRetries,
      'steps': [
        {'kind': 'narration', 'text': 'Let us hear about food.'},
        {'kind': 'audio', 'audio_id': 3, 'title': 'Food story'},
        {
          'kind': 'question',
          'text': 'Which grain?',
          'options': ['Rice', 'Stone'],
          'correct_index': 0,
          'explanation': 'The story says rice.',
          'replay_from': 1,
        },
        {
          'kind': 'poll',
          'text': 'Eaten rice this week?',
          'options': ['Yes', 'No'],
        },
        {
          'kind': 'question',
          'text': 'No content before me in this segment',
          'options': ['A', 'B', 'C'],
          'correct_index': 2,
        },
      ],
    });

void main() {
  var tick = DateTime.utc(2026, 11, 9, 10);
  DateTime clock() => tick = tick.add(const Duration(seconds: 1));

  test('correct answers and polls move straight on and finish', () {
    final engine = JourneyEngine(foodJourney(), clock: clock);
    expect(engine.current!.kind, JourneyStepKind.narration);
    expect(() => engine.answer(0), throwsStateError);
    engine.next();
    engine.next();
    expect(engine.current!.kind, JourneyStepKind.question);
    expect(() => engine.next(), throwsStateError);
    expect(engine.answer(0), JourneyOutcome.correct);
    expect(engine.answer(1), JourneyOutcome.pollSaved);
    expect(engine.answer(2), JourneyOutcome.correct);
    expect(engine.finished, isTrue);
    expect(engine.firstTryCorrect, 2);
    expect(engine.completedAt, isNotNull);
  });

  test('a wrong answer replays linked content, then asks again', () {
    final engine = JourneyEngine(foodJourney(), clock: clock)
      ..next()
      ..next();
    expect(engine.answer(1), JourneyOutcome.replay);
    expect(engine.index, 1);
    expect(engine.replaying, isTrue);
    engine.next();
    expect(engine.index, 2);
    expect(engine.replaying, isFalse);
    expect(engine.triesLeft, 1);
    expect(engine.answer(0), JourneyOutcome.correct);
    expect(engine.firstTryCorrect, 0);
    expect(engine.answers.map((a) => a.attempt), [0, 1]);
  });

  test('used-up tries reveal the answer; no replay content asks again', () {
    final engine = JourneyEngine(foodJourney(maxRetries: 1), clock: clock)
      ..next()
      ..next();
    expect(engine.answer(1), JourneyOutcome.replay);
    engine.next();
    expect(engine.answer(1), JourneyOutcome.revealed);
    expect(engine.current!.kind, JourneyStepKind.poll);
    engine.answer(0);
    expect(engine.answer(0), JourneyOutcome.tryAgain);
    expect(engine.index, 4);
    expect(engine.answer(1), JourneyOutcome.revealed);
    expect(engine.finished, isTrue);
  });

  test('going back skips finished questions so attempts stay within limits', () {
    final engine = JourneyEngine(foodJourney(), clock: clock)
      ..next()
      ..next();
    engine.answer(0);
    expect(engine.previous(), isTrue);
    expect(engine.index, 1);
    engine.next();
    expect(engine.current!.kind, JourneyStepKind.poll);
    expect(engine.attemptsUsed(2), 1);
  });

  test('going back from an unanswered question returns to it', () {
    final engine = JourneyEngine(foodJourney(), clock: clock)
      ..next()
      ..next();
    expect(engine.previous(), isTrue);
    expect(engine.index, 1);
    engine.next();
    expect(engine.index, 2);
  });

  test('progress restores exactly and sync payload omits correctness', () {
    final engine = JourneyEngine(foodJourney(), clock: clock)
      ..next()
      ..next();
    engine.answer(1);
    final restored = JourneyEngine.restore(foodJourney(), engine.toJson());
    expect(restored.runId, engine.runId);
    expect(restored.index, 1);
    expect(restored.returnTo, 2);
    expect(restored.answers.single.correct, isFalse);
    final payload = restored.toSyncJson(playedOffline: true);
    expect(payload['journey_revision'], 2);
    expect(payload['played_offline'], isTrue);
    expect((payload['answers'] as List).single, isNot(contains('correct')));
    expect(RegExp(r'^[0-9a-f-]{36}$').hasMatch(engine.runId), isTrue);

    final other = JourneySnapshot.parse({
      ...foodJourney().toJson(),
      'revision': 3,
    });
    expect(
      () => JourneyEngine.restore(other, engine.toJson()),
      throwsFormatException,
    );
  });

  test('snapshots reject replay points that are not earlier content', () {
    final data = foodJourney().toJson();
    (data['steps'] as List)[2] = {
      ...(data['steps'] as List)[2] as Map<String, dynamic>,
      'replay_from': 3,
    };
    expect(() => JourneySnapshot.parse(data), throwsFormatException);
  });

  test('moving and removing steps keeps replay points on the same content', () {
    final steps = foodJourney().steps;
    final moved = JourneySteps.move(steps, 1, 0);
    expect(moved[2].replayFrom, 0);
    final removed = JourneySteps.remove(steps, 1);
    expect(removed[1].replayFrom, isNull);
    final after = JourneySteps.move(steps, 1, 3);
    expect(after[1].kind, JourneyStepKind.question);
    expect(after[1].replayFrom, isNull);
    expect(JourneySteps.autoReplay(steps, 2), 0);
    expect(JourneySteps.autoReplay(steps, 4), isNull);
  });
}
