import '../services/journey_engine.dart';
import '../services/journey_models.dart';
import '../utils/spoken_format.dart';
import 'announce.dart';

/// Every sentence spoken by learning-journey screens, kept in one place so
/// wording stays consistent and can be localised later.
class JourneyAnnouncer {
  const JourneyAnnouncer._();

  static String where(JourneyEngine engine) {
    final step = engine.current;
    if (step == null) return 'Journey finished. ${engine.snapshot.title}.';
    final replay = engine.replaying ? ' Listening again before the question.' : '';
    return 'Step ${engine.index + 1} of ${engine.stepCount}. '
        '${_kindName(step.kind)}. ${engine.snapshot.title}.$replay';
  }

  static String _kindName(JourneyStepKind kind) => switch (kind) {
    JourneyStepKind.audio => 'Recording',
    JourneyStepKind.narration => 'Narration',
    JourneyStepKind.question => 'Question',
    JourneyStepKind.poll => 'Poll',
  };

  static String options(JourneyStep step) => [
    for (var i = 0; i < step.options.length; i++)
      'Option ${i + 1}: ${step.options[i]}.',
  ].join(' ');

  static String question(JourneyEngine engine) {
    final step = engine.current!;
    final keys = 'Press 1 to ${step.options.length} to choose, then 5 to submit.';
    if (step.kind == JourneyStepKind.poll) {
      return 'Poll. There is no wrong answer. ${step.text} ${options(step)} $keys';
    }
    final tries = engine.attemptsUsed(engine.index) > 0
        ? ' Try again. ${engine.triesLeft} ${engine.triesLeft == 1 ? 'try' : 'tries'} left.'
        : '';
    return 'Question.$tries ${step.text} ${options(step)} $keys';
  }

  static String chosen(JourneyStep step, int option) =>
      'Option ${option + 1}, ${step.options[option]}, selected. Press 5 to submit, or choose another number.';

  static String content(JourneyStep step) => switch (step.kind) {
    JourneyStepKind.audio =>
      'Recording: ${step.title ?? 'Untitled'}. Press 5 to pause or play. Press 2 when you are ready to move on.',
    _ => step.text,
  };

  static const contentKeys =
      'Press 2 for the next step, 3 to repeat this step, 1 to hear where you are, '
      '8 to go back to the previous recording or narration.';

  static String outcome(JourneyOutcome outcome, JourneyStep step) =>
      switch (outcome) {
        JourneyOutcome.correct =>
          'Correct! ${step.options[step.correctIndex!]}.',
        JourneyOutcome.pollSaved => 'Thank you. Your answer is saved.',
        JourneyOutcome.replay =>
          'Not quite. Let us listen to that part again, then try once more.',
        JourneyOutcome.tryAgain => 'Not quite. Think again and choose another answer.',
        JourneyOutcome.revealed =>
          'Not quite. The answer is option ${step.correctIndex! + 1}, '
              '${step.options[step.correctIndex!]}. ${step.explanation ?? ''}',
      };

  static String finished(JourneyEngine engine) {
    final questions = engine.questionCount;
    final score = questions == 0
        ? ''
        : 'You answered ${engine.firstTryCorrect} of $questions '
              '${questions == 1 ? 'question' : 'questions'} correctly on the first try. ';
    return 'Well done! You finished ${engine.snapshot.title}. $score'
        'Press 1 to play again, or 0 to go back to your journeys.';
  }

  static String studentRow(StudentJourneySummary journey, {bool downloaded = false}) {
    final status = switch (journey.status) {
      'completed' => 'Completed',
      'in_progress' => 'In progress',
      _ => 'New',
    };
    final score = journey.percentage == null
        ? ''
        : ' Score ${journey.percentage!.round()} percent.';
    return '${journey.title}. ${journey.subjectName ?? ''}. ${journey.stepCount} steps, '
        '${journey.questionCount} questions. $status.$score'
        '${downloaded ? ' Downloaded.' : ''}';
  }

  static String teacherRow(JourneyDraft journey) =>
      '${journey.title}. ${journey.statusWords}. ${journey.stepCount} steps, '
      '${journey.questionCount} questions.${journey.graded ? ' Graded.' : ''}';

  static String stepRow(List<JourneyStep> steps, int index) {
    final step = steps[index];
    final replay = step.kind == JourneyStepKind.question
        ? step.replayFrom == null
              ? ' Replays automatically.'
              : ' Replays from step ${step.replayFrom! + 1}.'
        : '';
    return 'Step ${index + 1} of ${steps.length}. ${step.spokenName}.$replay';
  }

  // ??? Player ???????????????????????????????????????????????????????????????

  /// Star state: step, selection and playback.
  static String state(
    JourneyEngine engine, {
    int? selected,
    bool playing = false,
  }) {
    final step = engine.current;
    if (step == null) return 'Journey finished.';
    final parts = <String>[where(engine)];
    if (step.kind == JourneyStepKind.audio) {
      parts.add(playing ? 'Recording playing.' : 'Recording paused.');
    }
    if (step.isAnswer) {
      parts.add(
        selected == null
            ? 'No option chosen yet.'
            : 'Option ${selected + 1}, ${step.options[selected]}, selected.',
      );
      if (step.kind == JourneyStepKind.question &&
          engine.attemptsUsed(engine.index) > 0) {
        parts.add('${engine.triesLeft} ${engine.triesLeft == 1 ? 'try' : 'tries'} left.');
      }
    }
    return parts.join(' ');
  }

  static String start(JourneySnapshot journey, {required bool preview, required bool resumed}) =>
      preview
      ? 'Preview of ${journey.title}. Nothing is saved.'
      : resumed
      ? 'Welcome back to ${journey.title}. Continuing where you left off.'
      : Announce.pick(
          brief: 'Starting ${journey.title}.',
          detailed:
              'Starting ${journey.title}. ${journey.steps.length} steps. Press star at any time for help.',
        );

  static String notSaved(String reason) => 'Your place could not be saved. $reason';
  static const listeningAgain = 'Listening again. ';
  static String narration(String text) => '$text Press 2 to continue.';
  static String recordingStatus(JourneyStep step) => 'Recording: ${step.title ?? 'Untitled'}';
  static const recordingFailed = 'This recording could not be played. Check your internet.';
  static const recordingRetry = 'Press 3 to try again, or 2 to skip to the next step.';
  static const notDownloaded = 'This recording is not downloaded on this phone.';
  static const recordingFinished = 'Recording finished.';
  static String answerFirst(int options) => 'Answer first. Press 1 to $options to choose, then 5.';
  static const noEarlierContent = 'There is no earlier recording or narration.';
  static const goingBack = 'Going back.';
  static String noSuchOption(int option, int options) =>
      'There is no option $option. Choose 1 to $options.';
  static String chooseFirst(int options) => 'Choose an answer first with 1 to $options.';
  static const finishedStatus = 'Journey finished.';
  static const sendLater = 'Journey finished. Your answers will be sent when you are online.';
  static const startingAgain = 'Starting again.';
  static const paused = 'Paused.';
  static const seekRecordingsOnly = 'Seeking works on recordings only.';
  static const speedRecordingsOnly = 'Recording speed changes on recordings only.';
  static const fastest = 'Fastest speed.';
  static const slowest = 'Slowest speed.';
  static String speed(double rate) => 'Recording speed ${rate.toStringAsFixed(2)} times.';
  static const leaveTitle = 'Leave this journey?';
  static String leaveMessage(int step) =>
      'Your place is saved on this phone. Next time you can continue from step $step.';
  static const answerHelp = 'Press a number to choose, 5 to submit, 6 to repeat the question.';

  // ??? Authoring and lists ??????????????????????????????????????????????????
  static String stepRemoved(int remaining) =>
      'Step removed. The journey now has $remaining steps.';
  static String stepRemovedUndo(JourneyStep step) => 'Removed ${step.spokenName}.';
  static const stepRestored = 'Step restored.';
  static String created(String title) => 'Created $title. Now add its first step.';
  static const noStepAdded = 'No step was added.';
  static String previewSkips(List<String> issues) =>
      'Some steps are skipped in this preview. ${issues.join(' ')}';
  static String duplicated(String title) =>
      'Created $title as a new draft. Find it under Drafts.';
  static String archiveMessage(String title, {required bool archive}) => archive
      ? 'Students will no longer see $title. Results are kept. You can restore it later.'
      : 'Students will see $title again.';
  static const archived = 'Archived. Students no longer see it.';
  static const restored = 'Restored for students.';
  static String deleteDraftMessage(String title) =>
      'Delete $title permanently? Recordings stay in your library.';
  static const draftDeleted = 'Draft deleted.';
  static const noRetriesLeft = 'Already no retries.';
  static const maxRetries = 'Five retries is the most.';
  static String published(int delivered) =>
      'Published. Students can play it now. Notifications reached $delivered phones.';
  static const optionUsed = 'That option is already used. Type a different option.';
  static const nothingToReplay =
      'There is no recording or narration before this question yet, so a '
      'wrong answer asks again. You can add content earlier and edit this later.';
  static const bankEmpty =
      'Your question bank for this class and subject is empty. Choose Write a new question instead.';
  static const recordViaNotes =
      'Opening private notes. Record, review, then choose Publish to this '
      'class and subject. Come back with 0, and choose your new recording.';
  static const noRecordings =
      'There are no audio files in this class and subject yet, so nothing was '
      'added. You are back on the previous screen. To add one, choose '
      'Recording again, then 2 to upload a recording file or 3 to record a new one.';
  static const openingFiles = 'Opening the file chooser for an audio file.';
  static const noFile = 'No file chosen.';
  static const uploading = 'Uploading. Please wait.';
  static const uploadUnconfirmed =
      'The upload was not confirmed. Check My recordings before trying again, to avoid a duplicate.';
  static String uploaded(String title) => 'Uploaded $title.';
  static const storageUnavailable = 'Journey storage is unavailable.';
  static const nothingInProgress = 'There is no journey in progress. Press 2 for new journeys.';
  static const teacherUpdated =
      'Your teacher updated this journey. Download it again to play the new version offline.';
  static String startOverMessage(String title) =>
      'Start $title again from step 1? Answers you already gave are still sent to your teacher.';
  static String removeDownloadMessage(String title) =>
      'Remove $title from this phone? Your place in the journey is kept. You can download it again with internet.';
  static String downloadRemoved(String title) => 'Removed the download of $title.';
  static String downloading(int recordings) =>
      'Downloading ${SpokenFormat.count(recordings, 'recording')}. Press 0 to cancel.';
  static String downloaded(String title) => 'Downloaded. You can play $title without internet.';
  static const cancellingDownload = 'Cancelling download. Saved recordings are kept.';

  static String stepDetails(JourneyStep step) => switch (step.kind) {
    JourneyStepKind.audio => step.spokenName,
    JourneyStepKind.narration => step.spokenName,
    JourneyStepKind.question =>
      '${step.spokenName} ${options(step)} Correct answer: option '
          '${step.correctIndex! + 1}. ${step.explanation == null ? 'No explanation.' : 'Explanation: ${step.explanation}'}',
    JourneyStepKind.poll => '${step.spokenName} ${options(step)}',
  };
}
