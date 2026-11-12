import '../utils/spoken_format.dart';
import 'announce.dart';

/// Every sentence spoken or shown by the quiz screens, kept in one place so
/// wording stays consistent and can be translated later.
abstract final class QuizText {
  // ─── Shared formatting ────────────────────────────────────────────────────

  /// Server timestamps without a zone are UTC.
  static DateTime? parseServerTime(Object? raw) {
    final text = raw?.toString().trim() ?? '';
    if (text.isEmpty || text == 'null') return null;
    final hasTime = text.contains('T') || text.contains(' ');
    final hasZone = RegExp(r'(Z|[+-]\d{2}:?\d{2})$').hasMatch(text);
    return DateTime.tryParse(
      hasTime && !hasZone ? '${text.replaceFirst(' ', 'T')}Z' : text,
    );
  }

  /// "today at 10:30 in the morning", or [fallback] when there is no time.
  static String when(Object? raw, {String fallback = 'not set'}) {
    if (raw is DateTime) return SpokenFormat.dateTime(raw);
    final parsed = parseServerTime(raw);
    return parsed == null ? fallback : SpokenFormat.dateTime(parsed);
  }

  static String questions(int count) => SpokenFormat.count(count, 'question');
  static String attempts(int count) => SpokenFormat.count(count, 'attempt');
  static String students(int count) => SpokenFormat.count(count, 'student');
  static String minutes(int count) =>
      SpokenFormat.duration(Duration(minutes: count));

  static String percent(Object? value, {String fallback = 'not available'}) =>
      value is num ? SpokenFormat.percent(value) : fallback;

  static String _int(Object? value) => value is num ? '${value.round()}' : '0';

  static const accountChanged =
      'Your account changed. Return to quizzes and sign in again.';

  // ─── Quiz descriptions shared by teachers and students ────────────────────

  static String attemptsText(Map quiz) => quiz['mode'] == 'practice'
      ? 'Unlimited practice attempts. Not graded.'
      : '${attempts(quiz['attempts_remaining'] as int? ?? 0)} remaining.';

  static String timeLimit(Object? minutesValue) => minutesValue is int
      ? 'Time limit ${minutes(minutesValue)}.'
      : 'No time limit.';

  static String feedbackPolicy(Map quiz) {
    switch (quiz['feedback_policy']) {
      case 'after_completion':
        return 'Answer feedback and scores are released after you finish the quiz.';
      case 'scheduled':
        return 'Feedback and scores are released after you finish and after '
            '${when(quiz['feedback_release_at'])}.';
      case 'score_only':
        return 'Only the score is released after you finish. Answers and explanations are not released.';
      default:
        return 'You hear whether each answer is right as soon as you submit it.';
    }
  }

  static String policyName(String policy) => switch (policy) {
    'after_completion' => 'after the quiz is finished',
    'scheduled' => 'at a scheduled time',
    'score_only' => 'score only',
    'legacy_immediate' => 'immediately, older setting',
    'immediate' => 'immediately after each answer',
    _ => policy,
  };

  static String attemptResult(Map attempt) {
    final correct = _int(attempt['correct_count']);
    final total = _int(attempt['total_questions']);
    if (attempt['is_graded'] == false) {
      return 'Practice, not an academic grade. $correct of $total correct in this practice.';
    }
    if (attempt['score_released'] == false) {
      return 'Score not released. ${attempt['feedback_message'] ?? 'Check the release policy.'}';
    }
    return 'Score $correct of $total, ${percent(attempt['percentage_score'])}.';
  }

  static String status(Object? value) => switch (value) {
    'in_progress' => 'in progress',
    'timed_out' => 'finished when time ran out',
    'completed' => 'finished',
    'published' => 'published',
    'draft' => 'draft',
    'closed' => 'closed',
    'scheduled' => 'scheduled',
    'open' => 'open',
    _ => '$value',
  };

  // ─── Attempt: answering ───────────────────────────────────────────────────

  static String questionHeading(int number, Object? total) =>
      'Question $number of $total';

  static String question(int number, Object? total, Object? text) =>
      '${questionHeading(number, total)}. $text';

  static String options(List<String> spoken) => [
    for (var i = 0; i < spoken.length; i++) 'Option ${i + 1}. ${spoken[i]}.',
  ].join(' ');

  static String optionLabel(int index, int count, String spoken) =>
      'Option ${index + 1} of $count, $spoken';

  static String optionTarget(int index, String spoken, bool selected) =>
      'Option ${index + 1}, $spoken, ${selected ? 'selected' : 'not selected'}. '
      'Press OK or ${index + 1} to choose';

  static String answerKeys(int count) => Announce.pick(
    brief: 'Press 1 to $count, then 5.',
    detailed:
        'Press 1 to $count to choose an answer, then 5 to submit it. '
        'Press 6 to repeat the question, 8 to hear where you are.',
  );

  static String chosen(int index, String spoken) => Announce.pick(
    brief: 'Option ${index + 1}, $spoken, selected.',
    detailed:
        'Option ${index + 1}, $spoken, selected. Press 5 to submit, or choose another number.',
  );

  static String chooseFirst(int count) =>
      'Choose an answer first. Press 1 to $count, then 5 to submit.';

  static String noSuchOption(int option, int count) =>
      'There is no option $option. Press 1 to $count.';

  static const submitting = 'Submitting your answer.';

  static String correct(String answer, String? explanation) =>
      'Correct! $answer.${_explain(explanation)}';

  static String wrong(String answer, String? explanation) =>
      'Not quite. The answer is $answer.${_explain(explanation)}';

  static String _explain(String? text) =>
      text == null || text.trim().isEmpty ? '' : ' $text';

  static String saved(Object? message) => Announce.pick(
    brief: 'Answer saved.',
    detailed: 'Answer saved and locked.${message == null ? '' : ' $message'}',
  );

  static const savedHeading = 'Answer saved and locked';
  static const correctHeading = 'Correct';
  static const wrongHeading = 'Incorrect';

  static String feedbackDetails(Map feedback) =>
      'You selected: ${feedback['selected_option_text']}\n'
      '${feedback['feedback_released'] == false ? feedback['feedback_message'] : 'Correct answer: ${feedback['correct_option_text']}\n${feedback['explanation'] ?? 'No explanation provided.'}'}';

  static String answerFailed(String? reason) =>
      '${reason ?? 'The answer confirmation could not be read.'} '
      'Your selection is preserved. Press 5 to try again.';

  static String selection(int? index, String? spoken, {required bool saved}) =>
      index == null
      ? 'No option selected.'
      : 'Selected option ${index + 1}, $spoken. ${saved ? 'Answer saved.' : 'Not submitted yet.'}';

  static const repeatQuestion = 'Repeat question and options';
  static String answerSaved({required bool hasFeedback}) =>
      'Answer confirmed saved and locked.'
      '${hasFeedback ? ' Feedback for it stays available privately on the next question.' : ''}';
  static const previousFeedback = 'Hear feedback for the previous answer, privately';

  static const answerLockNotice =
      'Each answer is saved and locked when you press 5.';

  // ─── Attempt: where am I and time ─────────────────────────────────────────

  static String timeLeft(Duration? remaining) => remaining == null
      ? 'No time limit.'
      : 'Time left: ${SpokenFormat.duration(remaining)}.';

  /// Visual countdown, for example "4:05 left".
  static String clock(Duration? remaining) {
    if (remaining == null) return 'No time limit';
    final seconds = remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '${remaining.inMinutes}:$seconds left';
  }

  static String timeWarning(Duration remaining) =>
      '${SpokenFormat.duration(remaining)} left in this quiz.';

  static String timeUp(int saved) =>
      'Time is up. ${SpokenFormat.count(saved, 'answer')} saved. Finishing the quiz.';

  static String where({
    required int number,
    required Object? total,
    required int answered,
    String? selection,
    Duration? remaining,
    bool timed = false,
  }) => [
    '${questionHeading(number, total)}.',
    '$answered answered.',
    ?selection,
    if (timed) timeLeft(remaining),
  ].join(' ');

  static String allSaved(Duration? remaining, {bool timed = false}) =>
      'All answers are saved. Press 5 to finish and hear your result.'
      '${timed ? ' ${timeLeft(remaining)}' : ''}';

  // ─── Attempt: finishing ───────────────────────────────────────────────────

  static const finishNow = 'Finish quiz now, with confirmation';
  static const finishNowButton = 'Finish quiz now';
  static const finishTitle = 'Finish quiz now?';

  static String finishMessage(int unanswered) =>
      'The server shows ${questions(unanswered)} not answered. '
      'Only saved answers count. A selected answer that you did not submit is not included. '
      'You cannot change answers after finishing.';

  static const finishConfirm = 'Finish quiz';
  static const finishCancel = 'Keep working';
  static const finishUnchecked =
      'Your saved answers could not be checked, or this attempt has ended. '
      'The quiz was not finished. Return to the quiz list to refresh it.';
  static const finishTimedOut =
      'Checking your saved answers took too long. The quiz was not finished. '
      'Check your connection and try again.';
  static const finishing = 'Finishing the quiz';
  static const finishAndHear = 'Finish and hear result';
  static const retryFinishing = 'Retry finishing';

  static String completionFailed(String? reason) =>
      '${reason ?? 'Completion was not confirmed.'} '
      'Your saved answers are preserved. Press 5 to retry finishing.';

  static String completed({bool timedOut = false}) =>
      '${timedOut ? 'Time ran out. ' : ''}Quiz finished. Your result is private. '
      'Press 8 to hear it, or 0 to return to quizzes.';

  static const resultPrivate =
      'Quiz finished. Result private. Use Read result privately.';
  static const resultHeading = 'Attempt complete';
  static const readResult = 'Read result privately';
  static const returnToQuizzes = 'Return to quizzes';

  // ─── Attempt: leaving ─────────────────────────────────────────────────────

  static const leave = 'Leave without submitting, with confirmation';
  static const leaveTitle = 'Leave and resume later?';
  static const leaveMessage =
      'This does not submit your attempt. Only saved answers are kept; a selected answer that you did not submit may be lost. '
      'Any time limit keeps running. You can resume while the quiz allows it.';
  static const leaveConfirm = 'Leave without submitting';
  static const leaveCancel = 'Stay in quiz';
  static const waitBeforeLeaving =
      'Please wait. Your answer is still being saved.';

  static String attemptScreen(String title) => 'Quiz attempt, $title';

  static String attemptNavigation({
    required bool completed,
    required bool timed,
  }) => completed
      ? 'return to quizzes, read result privately and quiz speech speed'
      : 'the question, each answer option, the selected answer, quiz speech speed, '
            '${timed ? 'time left, ' : ''}submit, Finish quiz now and Leave. '
            'Moving focus never selects or submits';

  // ─── Speech speed ─────────────────────────────────────────────────────────

  static const speedHelp =
      'Press 7 or 9 to make quiz speech slower or faster.';
  static const speedScreenReader =
      'Quiz speech speed changes app speech only. '
      'Change your screen reader speed in Android settings.';
  static const speedHeading = 'Quiz speech speed';

  static String speedTarget(String description) =>
      'Quiz speech speed, $description. Left or right to change, or press 7 or 9';

  static String speedRead(String description) =>
      'Quiz speech speed, $description. Press 7 for slower or 9 for faster. '
      'This speed is used only in quizzes.';

  static String speedChanged(bool faster, String description) =>
      '${faster ? 'Faster' : 'Slower'}. $description.';

  static String speedLimit(bool faster, String description) =>
      '${faster ? 'Fastest' : 'Slowest'} quiz speech, $description.';

  static bool isSpeedAnnouncement(String text) =>
      text.startsWith('Faster. ') ||
      text.startsWith('Slower. ') ||
      text.startsWith('Fastest quiz speech') ||
      text.startsWith('Slowest quiz speech') ||
      text.startsWith('Quiz speech speed');

  // ─── Student quiz list ────────────────────────────────────────────────────

  static const studentScreen = 'Student quizzes';
  static const studentNavigation =
      'refresh, quiz state and subject filters, available quizzes, and attempt history';
  static String get studentIntro => Announce.pick(
    brief: 'Use left or right on a filter to change it.',
    detailed:
        'Use left or right on a filter to change it. Press OK on a quiz to hear its details '
        'and confirm starting. Moving focus never starts a quiz.',
  );

  static String available(int count) => count == 0
      ? 'No quizzes available.'
      : '${SpokenFormat.count(count, 'quiz', 'quizzes')} available.';

  static String studentState(int open, int total) =>
      '${SpokenFormat.count(total, 'quiz', 'quizzes')} shown, $open open.';

  static String stateName(String? state) => switch (state) {
    null => 'All states',
    'scheduled' => 'Scheduled',
    'open' => 'Open',
    'closed' => 'Closed',
    _ => state,
  };

  static String stateFilter(String name, int position, int count) =>
      'Quiz state: $name, $position of $count.';

  static String subjectFilter(String name, int position, int count) =>
      'Subject: $name, $position of $count.';

  static const changeWithArrows = 'Left or right to change';
  static const allSubjects = 'All subjects';

  static String quizRow(Map quiz) =>
      '${quiz['subject_name']}, ${quiz['title']}, ${status(quiz['display_status'])}. '
      '${attemptsText(quiz)} '
      '${quiz['in_progress_attempt_id'] == null ? 'Start quiz' : 'Resume quiz'}';

  static String historyRow(Map quiz) =>
      'Review ${quiz['title']} attempt history. Highest score ${percent(quiz['highest_score'])}';

  static String limitReached(Object? title) =>
      'No attempts left for $title. Open attempt history to review your scores.';

  static String startTitle(bool resume) =>
      resume ? 'Resume quiz?' : 'Start quiz?';

  static String startMessage(Map quiz) =>
      '${quiz['title']}. ${attemptsText(quiz)} ${timeLimit(quiz['time_limit_minutes'])} '
      '${quiz['closes_at'] == null ? '' : 'Closes ${when(quiz['closes_at'])}. '}'
      'Each answer is saved and locked when you press 5. ${feedbackPolicy(quiz)}';

  static String startConfirm(bool resume) =>
      resume ? 'Resume attempt' : 'Start attempt';

  static const startFailed =
      'The quiz could not be started. Check that it is open.';
  static const historyFailed = 'Attempt history could not be loaded.';

  // ─── Attempt history and review ───────────────────────────────────────────

  static const historyScreen =
      'Attempt history. Scores are private. Move to the summary or an attempt to review it.';

  static String historySummary(Map history) {
    final attempts = history['attempts'] as List? ?? const [];
    if (attempts.any((attempt) => attempt['is_graded'] == false)) {
      return 'Practice history. Not academic grades.';
    }
    if (history['highest_score'] != null) {
      return 'Highest score: ${percent(history['highest_score'])}';
    }
    return attempts.any((attempt) => attempt['status'] != 'in_progress')
        ? 'Completed attempts exist; no score is released yet.'
        : 'No completed attempt';
  }

  static String historyAttempt(Map attempt) =>
      'Attempt ${attempt['attempt_number']}. ${status(attempt['status'])}. '
      '${attemptResult(attempt)} Press OK to review.';

  static const resumeFromList =
      'This attempt is in progress. Return to the quiz list to resume it. Leaving does not submit.';
  static const reviewFailed =
      'Attempt review could not be loaded. Check your connection and try again.';
  static const reviewTimedOut =
      'Attempt review took too long. Check your connection and try again.';

  static String reviewScreen(int count, String? message) =>
      'Attempt review. ${count == 0 && message != null ? message : '${questions(count)}. Use up and down to review each answer.'}';

  static String reviewQuestion(Map question, int index) =>
      'Question ${index + 1}. ${question['is_correct'] == true ? 'Correct' : 'Incorrect'}. '
      '${question['spoken_question_text'] ?? question['question_text']}. '
      'You chose ${question['selected_option_spoken_text'] ?? question['selected_option_text'] ?? 'no answer'}. '
      'Correct answer ${question['correct_option_spoken_text'] ?? question['correct_option_text']}. '
      '${question['spoken_explanation'] ?? question['explanation'] ?? 'No explanation provided.'}';

  // ─── Teacher quiz list ────────────────────────────────────────────────────

  static String teacherScreen(String className, String subjectName) =>
      'Teacher quizzes for $className, $subjectName';

  static const teacherNavigation =
      'bank search and saved questions, quiz drafts, published quizzes, and their results';

  static String get teacherIntro => Announce.pick(
    brief: '',
    detailed:
        'Use the D-pad to explore bank search and saved questions, quiz drafts, published quizzes and results.',
  );

  static String teacherLoaded(int questionCount, int quizCount) =>
      '${SpokenFormat.count(questionCount, 'bank question')} and '
      '${SpokenFormat.count(quizCount, 'quiz', 'quizzes')} loaded.';

  static String teacherState(List quizzes, int bankCount) {
    int count(String status) =>
        quizzes.where((quiz) => quiz['status'] == status).length;
    return '${SpokenFormat.count(count('draft'), 'draft')}, '
        '${count('published')} published, ${count('closed')} closed. '
        '${SpokenFormat.count(bankCount, 'bank question')}.';
  }

  static const teacherLoadFailed =
      'The question bank or quiz list could not be refreshed. Press 1 to try again before creating another quiz.';
  static const refreshQuizzes = 'Refresh quiz content';
  static const searchBank = 'Search private question bank';
  static const createQuestion = 'Create four option question';
  static const createQuiz = 'Create quiz draft';
  static const createPractice =
      'Create separate untimed ungraded practice. Unlimited retries';

  static String bankQuestion(Map question) =>
      'Question bank item, ${question['spoken_question_text'] ?? question['question_text']}. '
      'Revision ${question['revision'] ?? 'unknown, older question'}. '
      'Press OK for edit, revision history, duplicate, archive, or add actions';

  static String quizPrimary(Map quiz) => quiz['status'] == 'draft'
      ? 'Continue creating ${quiz['title']}. ${questions(quiz['question_count'] as int? ?? 0)}'
      : quiz['status'] == 'published'
      ? 'Close ${quiz['title']}, with confirmation'
      : '${quiz['title']} is closed';

  static String quizDuplicate(Map quiz) =>
      'Duplicate ${quiz['title']} into a new editable draft';
  static String quizResults(Map quiz) => 'View results for ${quiz['title']}';

  static String quizCard(Map quiz) =>
      '${quiz['title']}. Status ${status(quiz['display_status'])}. '
      '${questions(quiz['question_count'] as int? ?? 0)}.';

  static const accountChangedBank =
      'Your account changed. Reopen the question bank before continuing.';

  static String questionSaveUnconfirmed(String reason) =>
      '$reason Question save could not be confirmed. Check the bank and refresh before retrying; do not create a duplicate.';

  static const missingRevision =
      'The server returned a question without a revision. Ask the administrator to update the quiz backend.';
  static const savedQuestionMismatch = 'The saved question did not match.';
  static const questionSaved =
      'Question saved. Editing this bank question later will not change existing quizzes.';
  static const noRevisionForEdit =
      'This server did not supply a question revision. Ask the administrator to update the quiz backend before editing.';

  static String questionUpdateUnconfirmed(String? reason) =>
      '${reason ?? 'The saved revision did not match.'} The bank question could not be confirmed updated. Refresh and review its current revision before retrying.';

  static const questionUpdated =
      'Bank question updated. Existing quiz snapshots were not changed.';
  static const archiveTitle = 'Archive bank question?';
  static const archiveMessage =
      'Archive this private bank question? Existing quiz snapshots and attempts are not changed.';
  static const archiveConfirm = 'Archive question';
  static const archiveFailed = 'The bank question could not be archived.';
  static const archived = 'Bank question archived.';
  static const duplicateQuestionFailed =
      'The bank question could not be duplicated.';
  static const questionDuplicated = 'Bank question copy created.';

  static String questionActions(Map question) =>
      'Actions for ${question['spoken_question_text'] ?? question['question_text']}';

  static const actionEdit = 'Edit bank question';
  static const actionDuplicate = 'Duplicate bank question';
  static const actionArchive = 'Archive bank question';
  static const actionRevisions = 'Read question revision history';
  static String actionAddTo(Object? title) => 'Add to $title';

  static const refreshBeforeDraft =
      'Refresh and review the quiz list before creating another draft.';

  static String draftUnconfirmed(String? reason) =>
      '${reason ?? 'The saved draft did not match.'} Draft save could not be confirmed. Refresh the quiz list before creating another draft.';

  static const draftSaved = 'Quiz draft saved.';
  static const addToQuizFailed = 'The question could not be added to this quiz.';
  static const addedToQuiz = 'Question added to the quiz.';
  static const publishTitle = 'Publish quiz?';

  static String publishMessage(Object? title) =>
      'Publish "$title" to eligible students? Questions become fixed for this quiz.';

  static const publishConfirm = 'Publish quiz';
  static const publishUnconfirmed =
      'Publishing could not be confirmed. Refresh and review the quiz status before trying again.';

  static String published(int recipients, int sent, int failures) =>
      recipients == 0
      ? 'Quiz published. There are no eligible students to notify.'
      : sent == 0
      ? 'Quiz published, but no student device notifications were delivered. Check notification registration and server Firebase credentials.'
      : failures > 0
      ? 'Quiz published. $sent device notifications sent and $failures failed.'
      : 'Quiz published. $sent device notifications sent.';

  static const closeTitle = 'Close quiz?';

  static String closeMessage(Object? title) =>
      'Close "$title"? No new attempts can start and active attempts will be finished.';

  static const closeConfirm = 'Close quiz';
  static const closeFailed = 'The quiz could not be closed.';
  static const closed = 'Quiz closed.';
  static const duplicateQuizFailed = 'The quiz could not be duplicated.';
  static const quizDuplicated = 'Editable quiz draft created.';

  // ─── Guided draft ─────────────────────────────────────────────────────────

  static const draftAccountChanged =
      'Your account changed. This draft cannot be reviewed here.';
  static const draftLoadFailed =
      'The draft or question bank could not be loaded. Refresh before continuing.';

  static String bankRefreshFailed(String? reason) =>
      '${reason ?? 'The saved question list could not be read.'} '
      'The question bank could not be refreshed. No question was added. Try Choose a saved question again.';

  static const noUnusedQuestions =
      'No unused questions are available in this workspace. Choose Write a question.';
  static const chooseSaved = 'Choose a saved question';

  static String addUnconfirmed(String? reason) =>
      '${reason ?? 'The saved draft did not match.'} Adding the question could not be confirmed. Refresh and review saved questions before adding again; it may already be saved.';

  static String questionAdded(int count) =>
      'Question added. ${questions(count)} saved. Add another or choose Review.';

  static String draftSummary(Map quiz, int questionCount) =>
      '${quiz['title']}. ${quiz['description'] ?? ''} ${questions(questionCount)}. '
      '${quiz['mode'] == 'practice' ? 'Ungraded practice. Unlimited attempts. No timer.' : 'Graded quiz. ${attempts(quiz['attempt_limit'] as int? ?? 1)}. ${quiz['time_limit_minutes'] == null ? 'No timer.' : '${minutes(quiz['time_limit_minutes'] as int)} per attempt.'}'} '
      '${feedbackPolicy(quiz)} '
      'Opens ${when(quiz['opens_at'], fallback: 'when published')}. '
      'Closes ${when(quiz['closes_at'], fallback: 'never, not scheduled')}. '
      'Shuffle questions ${quiz['shuffle_questions'] == true ? 'on' : 'off'}. '
      'Shuffle options ${quiz['shuffle_options'] == true ? 'on' : 'off'}.';

  static const removeChoose = 'Choose a question to remove from this draft';
  static String removeOption(int index, Object? text) =>
      'Question ${index + 1}: $text';
  static const removeTitle = 'Remove selected question?';
  static const removeMessage =
      'Remove this question from the draft? The reusable question bank is not changed.';
  static const removeConfirm = 'Remove question';
  static const removeUnconfirmed =
      'Removal could not be confirmed. Review the refreshed draft before trying again.';

  static String removed(int count) =>
      'Question removed from the draft. ${questions(count)} saved.';

  static const settingsUnconfirmed =
      'Settings save could not be confirmed. Refresh and review the saved settings before publishing.';
  static const settingsSaved =
      'Quiz settings saved. Review them before publishing.';

  static String draftHeader(Object? title, int count) =>
      '$title. ${questions(count)} saved.';

  static String savedQuestion(int index, Object? text) =>
      'Saved question ${index + 1}: $text. Already in this draft. Press OK to read its options';

  static String reviewDraftQuestion(Map question, int index) {
    final options = question['options'] as List? ?? const [];
    final spoken = question['spoken_options'] as List?;
    return 'Question ${index + 1}. ${question['spoken_question_text'] ?? question['question_text']}. '
        '${[for (var i = 0; i < options.length; i++) 'Option ${i + 1}: ${spoken != null && i < spoken.length ? spoken[i] : options[i]['option_text']}${options[i]['is_correct'] == true ? ', correct answer' : ''}.'].join(' ')} '
        '${question['spoken_explanation'] ?? question['explanation'] ?? ''}';
  }

  static String draftState(int count, {required bool review}) =>
      '${questions(count)} saved. ${review ? 'Reviewing before publishing.' : 'Adding questions.'}';

  // ─── Results ──────────────────────────────────────────────────────────────

  static String resultsScreen(String title) => 'Results for $title';
  static const resultsNavigation =
      'quiz summary, student results, and available result actions';
  static const resultsFailed = 'Quiz results could not be loaded.';

  static String resultsLoaded(Map summary) =>
      '${students(_intValue(summary['completed']))} completed. '
      '${students(_intValue(summary['not_attempted']))} not attempted yet.';

  static int _intValue(Object? value) => value is num ? value.round() : 0;

  static String statistics(Map summary) =>
      'Eligible: ${summary['eligible_students']}\n'
      'Started: ${summary['started']}\n'
      'Completed: ${summary['completed']}\n'
      'Not attempted: ${summary['not_attempted']}\n'
      'Completion: ${percent(summary['completion_percentage'])}\n'
      '${summary['mode'] == 'practice' ? 'Practice participation, not academic grades.' : 'Average highest score: ${percent(summary['average_highest_score'])}\nHighest score: ${percent(summary['highest_score'])}\nLowest completed score: ${percent(summary['lowest_completed_score'])}'}';

  static String studentResult(Map student, {required bool practice}) {
    final attemptList = student['attempts'] as List? ?? const [];
    if (attemptList.isEmpty) {
      return '${student['student_name']} has not attempted this quiz.';
    }
    if (practice) {
      return '${student['student_name']}. ${SpokenFormat.count(attemptList.length, 'practice attempt')}. Not academic grades.';
    }
    final scores = attemptList
        .map(
          (attempt) =>
              'attempt ${attempt['attempt_number']}, ${percent(attempt['percentage_score'])}, ${status(attempt['status'])}',
        )
        .join('. ');
    return '${student['student_name']}. Highest score '
        '${percent(student['highest_score'])}. $scores.';
  }

  static const extraMismatch =
      'The extra-time confirmation did not match. Refresh before retrying.';
  static const extraSaved =
      'Extra time confirmed for future attempts only. Existing attempt deadlines are unchanged and quiz closing time still applies.';
  static const everyoneAttempted =
      'Every eligible student has attempted this quiz.';
  static const remindTitle = 'Remind students?';

  static String remindMessage(int count, String title) =>
      'Send one quiz reminder to all ${students(count)} who have not attempted $title?';

  static const remindConfirm = 'Send reminder';
  static const remindFailed = 'Quiz reminders could not be sent.';

  static String reminded(Object? notified, Object? queued) =>
      'Reminder sent to $notified students. $queued device notifications queued.';

  static const refreshResults = 'Refresh quiz results';
  static const remindUnavailable =
      'All students have attempted. Reminder unavailable';

  static String remindTarget(int count) =>
      'Send a reminder to all ${students(count)} who have not attempted';

  static String extraTarget(Map student) =>
      'Set extra time for ${student['student_name']}. Future attempts only. '
      'Current extra time ${minutes(student['extra_time_minutes'] as int? ?? 0)}';

  static String extraButton(Map student) =>
      'Future extra time: ${student['extra_time_minutes'] ?? 0} minutes. Set';

  static String resultsState(Map? summary, int notAttempted) => summary == null
      ? 'Results not loaded.'
      : '${resultsLoaded(summary)} Completion ${percent(summary['completion_percentage'])}.';

  // ─── Extra time dialog ────────────────────────────────────────────────────

  static String extraScreen(String name) =>
      'Extra time for $name. Future attempts only; active attempt deadlines stay fixed. '
      'Quiz closing time still applies. Entering zero minutes removes extra time. '
      'Press 0 outside the field to cancel.';

  static String extraField(String text) =>
      'Extra minutes, currently ${text.isEmpty ? 'empty' : text}. Press OK to edit';

  static const extraSave = 'Save extra time for future attempts';
  static const extraCancel = 'Cancel without changing extra time';
  static const extraInvalid =
      'Enter a whole number of minutes, zero or more, within the server integer range.';
  static const extraCorrect = 'Move up to Extra minutes to correct it.';

  // ─── Question editor ──────────────────────────────────────────────────────

  static const editorInvalid =
      'Enter a question, four different non-empty options, and then choose the correct answer.';
  static const editorSpokenInvalid =
      'Use up to 20 different topics of 80 characters each. Described notation needs a spoken question, all four spoken options, and a spoken explanation if an explanation is provided. Review and confirm every spoken alternative before saving.';

  static String correctChosen(int index, String text, int count) =>
      'Correct answer: option ${index + 1}${text.isEmpty ? '' : ', $text'}, ${index + 1} of $count.';

  static String correctTarget(int? index, String text) => index == null
      ? 'Correct answer not selected. Use left or right to choose'
      : 'Correct answer: option ${index + 1}, $text. Use left or right to change';

  static String toggled(String name, bool on) => '$name ${on ? 'on' : 'off'}.';

  static String notation(bool described) =>
      'Content: ${described ? 'teacher-described notation or diagram' : 'English plain text'}';

  static String reviewed(bool value) =>
      'Spoken alternatives reviewed by teacher: ${value ? 'yes' : 'no'}';

  // ─── Quiz settings editor ─────────────────────────────────────────────────

  static const settingsInvalid =
      'Check the title, attempt limit from 1 to 20, time limit, and schedule. The closing time must be after the opening time.';
  static const setOpening =
      'Set opening time using the date and time number fields.';
  static const setClosing =
      'Set closing time using the date and time number fields.';

  static String openingSet(DateTime value) =>
      'Opening time set to ${SpokenFormat.dateTime(value)}.';
  static String closingSet(DateTime value) =>
      'Closing time set to ${SpokenFormat.dateTime(value)}.';
  static String releaseSet(DateTime value) =>
      'Feedback release set to ${SpokenFormat.dateTime(value)}.';
  static const openingCleared = 'Opening time cleared.';
  static const closingCleared = 'Closing time cleared.';

  static String opening(DateTime? value) => value == null
      ? 'No opening time set'
      : 'Opens ${SpokenFormat.dateTime(value)}';
  static String closing(DateTime? value) => value == null
      ? 'No closing time set'
      : 'Closes ${SpokenFormat.dateTime(value)}';

  static String policy(String policy, int position, int count) =>
      'Feedback: ${policyName(policy)}, $position of $count.';

  static String release(DateTime? value) =>
      'Scheduled feedback release ${value == null ? 'not set' : SpokenFormat.dateTime(value)}';

  static String attemptLimit(String text) =>
      'Attempt limit, currently $text. Press OK to edit';

  static String timeLimitField(String text) =>
      'Optional time limit in minutes, ${text.isEmpty ? 'not set' : text}. Press OK to edit';

  // ─── Revision history ─────────────────────────────────────────────────────

  static const revisionsScreen =
      'Private read-only question revision history. Use older and newer revision controls, then read each section.';
  static const revisionsAccount =
      'Your account changed. Return and sign in again before viewing private question history.';
  static const revisionsCleared =
      'Your account changed. Private question history was cleared.';
  static const revisionsUnverified =
      'Question revision history could not be verified. Retry loading.';
  static const revisionsContentUnverified =
      'Question revision content could not be verified. Retry loading.';
  static const revisionsTimedOut =
      'Question history took too long. Check your connection and retry.';
  static const noRevisions =
      'No tracked revisions. Older question history is unknown, not reconstructed.';

  static String revisionsLoaded(int count, Object? revision, Object? at) =>
      '${SpokenFormat.count(count, 'revision')} loaded. '
      'Read-only question revision $revision, saved ${when(at, fallback: 'date unknown')}. '
      'Existing quiz and attempt snapshots are not changed.';

  static String revisionSelected(Object? revision, int position, int? count) =>
      'Revision $revision selected${count == null ? '' : ', $position of $count'}. Read-only.';

  static String revisionFailed(String message) =>
      '$message Focus is on Refresh revisions.';

  static String revisionState(Object? revision) => revision == null
      ? 'No revision loaded.'
      : 'Showing revision $revision. Read-only.';

  /// Readable sections of one revision, keyed by section id.
  static Map<String, String> revisionSections(Map? revision) {
    final content = revision?['content'] as Map?;
    final options = content?['options'] as List? ?? const [];
    final spoken = content?['spoken_options'] as List? ?? const [];
    return {
      if (revision != null)
        'version':
            'Revision ${revision['revision']}. Saved ${when(revision['recorded_at'], fallback: 'date unknown')}. Read-only.',
      if (content != null) ...{
        'question':
            'Question: ${content['spoken_question_text'] ?? content['question_text']}',
        'topics':
            'Topics: ${(content['topics'] as List? ?? const []).join(', ')}',
        for (var i = 0; i < options.length; i++)
          'option-$i':
              'Option ${i + 1}: ${i < spoken.length ? spoken[i] : options[i]}. ${content['correct_option_index'] == i ? 'Correct answer.' : ''}',
        'explanation':
            'Explanation: ${content['spoken_explanation'] ?? content['explanation'] ?? 'Not provided'}',
      },
      'notice':
          'Only revisions saved after tracking was introduced are available. Older history is unknown. Existing quiz and attempt snapshots are never rewritten.',
    };
  }

  static Map<String, String> revisionTitles(Map? revision) {
    final content = revision?['content'] as Map?;
    final options = content?['options'] as List? ?? const [];
    return {
      if (revision != null)
        'version':
            'Revision ${revision['revision']}, ${when(revision['recorded_at'], fallback: 'date unknown')}',
      if (content != null) ...{
        'question': 'Question text',
        'topics': 'Topics',
        for (var i = 0; i < options.length; i++)
          'option-$i':
              'Option ${i + 1}${content['correct_option_index'] == i ? ', correct answer' : ''}',
        'explanation': 'Explanation',
      },
      'notice': 'About revision history',
    };
  }

  static String revisionSection(String title, {required bool sameAccount}) =>
      sameAccount
      ? '$title. Press OK to hear it'
      : 'Account changed. Return and sign in again.';

  static const goBack = 'Go back';
  static const cancel = 'Cancel';
  static const cancelAndReturn = 'Cancel and return';
  static const actionNavigation = 'the available actions and cancel';
  static const refreshRevisions = 'Refresh revisions';
  static const newerRevision = 'Newer revision';
  static const olderRevision = 'Older revision';

  // Teacher authoring and attempt messages moved out of the screens.
  static const bankArchived = 'Bank question archived';
  static const bankCopied = 'Bank question copy created';
  static const snapshotAdded = 'Question snapshot added to quiz';
  static const quizClosed = 'Quiz closed';
  static const draftCreated = 'Editable quiz draft created';
  static const noAnswerSelected = 'No answer selected.';
  static const selectBeforeSubmit = 'Select one option before submitting.';
  static const submitBeforeContinuing = 'Submit your answer before continuing.';
}
