import '../l10n/speech.dart';
import '../utils/spoken_format.dart';
import 'announce.dart';

/// Every sentence spoken or shown by the quiz screens, kept in one place so
/// wording stays consistent. The wording lives in `lib/l10n/app_*.arb`.
abstract final class QuizText {
  static AppLocalizations get _t => Speech.t;

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
  static String when(Object? raw, {String? fallback}) {
    if (raw is DateTime) return SpokenFormat.dateTime(raw);
    final parsed = parseServerTime(raw);
    return parsed == null
        ? fallback ?? _t.quizNotSet
        : SpokenFormat.dateTime(parsed);
  }

  static String questions(int count) => _t.quizQuestionCount(count);
  static String attempts(int count) => _t.quizAttemptCount(count);
  static String students(int count) => _t.quizStudentCount(count);
  static String minutes(int count) =>
      SpokenFormat.duration(Duration(minutes: count));

  static String percent(Object? value, {String? fallback}) => value is num
      ? SpokenFormat.percent(value)
      : fallback ?? _t.quizNotAvailable;

  static String _int(Object? value) => value is num ? '${value.round()}' : '0';

  static String get accountChanged => _t.quizAccountChanged;

  // ─── Quiz descriptions shared by teachers and students ────────────────────

  static String attemptsText(Map quiz) => quiz['mode'] == 'practice'
      ? _t.quizUnlimitedPractice
      : _t.quizAttemptsRemaining(quiz['attempts_remaining'] as int? ?? 0);

  static String timeLimit(Object? minutesValue) => minutesValue is int
      ? _t.quizTimeLimit(minutes(minutesValue))
      : _t.quizNoTimeLimit;

  static String feedbackPolicy(Map quiz) {
    switch (quiz['feedback_policy']) {
      case 'after_completion':
        return _t.quizFeedbackAfterCompletion;
      case 'scheduled':
        return _t.quizFeedbackScheduled(when(quiz['feedback_release_at']));
      case 'score_only':
        return _t.quizFeedbackScoreOnly;
      default:
        return _t.quizFeedbackImmediate;
    }
  }

  static String policyName(String policy) => switch (policy) {
    'after_completion' => _t.quizPolicyAfterCompletion,
    'scheduled' => _t.quizPolicyScheduled,
    'score_only' => _t.quizPolicyScoreOnly,
    'legacy_immediate' => _t.quizPolicyLegacyImmediate,
    'immediate' => _t.quizPolicyImmediate,
    _ => policy,
  };

  static String attemptResult(Map attempt) {
    final correct = _int(attempt['correct_count']);
    final total = _int(attempt['total_questions']);
    if (attempt['is_graded'] == false) {
      return _t.quizPracticeResult(correct, total);
    }
    if (attempt['score_released'] == false) {
      return _t.quizScoreNotReleased(
        '${attempt['feedback_message'] ?? _t.quizCheckReleasePolicy}',
      );
    }
    return _t.quizScoreResult(
      correct,
      total,
      percent(attempt['percentage_score']),
    );
  }

  static String status(Object? value) => switch (value) {
    'in_progress' => _t.quizStatusInProgress,
    'timed_out' => _t.quizStatusTimedOut,
    'completed' => _t.quizStatusCompleted,
    'published' => _t.quizStatusPublished,
    'draft' => _t.quizStatusDraft,
    'closed' => _t.quizStatusClosed,
    'scheduled' => _t.quizStatusScheduled,
    'open' => _t.quizStatusOpen,
    _ => '$value',
  };

  // ─── Attempt: answering ───────────────────────────────────────────────────

  static String questionHeading(int number, Object? total) =>
      _t.quizQuestionHeading('$number', '$total');

  static String question(int number, Object? total, Object? text) =>
      _t.quizQuestionWithText('$number', '$total', '$text');

  static String options(List<String> spoken) => [
    for (var i = 0; i < spoken.length; i++)
      _t.quizOptionSpoken('${i + 1}', spoken[i]),
  ].join(' ');

  static String optionLabel(int index, int count, String spoken) =>
      _t.quizOptionLabel('${index + 1}', '$count', spoken);

  static String optionTarget(int index, String spoken, bool selected) =>
      selected
      ? _t.quizOptionTargetSelected('${index + 1}', spoken)
      : _t.quizOptionTargetNotSelected('${index + 1}', spoken);

  static String answerKeys(int count) => Announce.pick(
    brief: _t.quizAnswerKeysBrief('$count'),
    detailed: _t.quizAnswerKeysDetailed('$count'),
  );

  static String chosen(int index, String spoken) => Announce.pick(
    brief: _t.quizChosenBrief('${index + 1}', spoken),
    detailed: _t.quizChosenDetailed('${index + 1}', spoken),
  );

  static String chooseFirst(int count) => _t.quizChooseFirst('$count');

  static String noSuchOption(int option, int count) =>
      _t.quizNoSuchOption('$option', '$count');

  static String get submitting => _t.quizSubmitting;

  static String correct(String answer, String? explanation) =>
      '${_t.quizCorrectFeedback(answer)}${_explain(explanation)}';

  static String wrong(String answer, String? explanation) =>
      '${_t.quizWrongFeedback(answer)}${_explain(explanation)}';

  static String _explain(String? text) =>
      text == null || text.trim().isEmpty ? '' : ' $text';

  static String saved(Object? message) => Announce.pick(
    brief: _t.quizAnswerSavedBrief,
    detailed:
        '${_t.quizAnswerSavedLocked}${message == null ? '' : ' $message'}',
  );

  static String get savedHeading => _t.quizSavedHeading;
  static String get correctHeading => _t.quizCorrectHeading;
  static String get wrongHeading => _t.quizWrongHeading;

  static String feedbackDetails(Map feedback) =>
      '${_t.quizYouSelected('${feedback['selected_option_text']}')}\n'
      '${feedback['feedback_released'] == false ? feedback['feedback_message'] : '${_t.quizCorrectAnswerIs('${feedback['correct_option_text']}')}\n${feedback['explanation'] ?? _t.quizNoExplanation}'}';

  static String answerFailed(String? reason) =>
      _t.quizAnswerFailed(reason ?? _t.quizAnswerUnreadable);

  static String selection(int? index, String? spoken, {required bool saved}) =>
      index == null
      ? _t.quizNoOptionSelected
      : saved
      ? _t.quizSelectionSaved('${index + 1}', '$spoken')
      : _t.quizSelectionNotSubmitted('${index + 1}', '$spoken');

  static String get repeatQuestion => _t.quizRepeatQuestion;
  static String answerSaved({required bool hasFeedback}) => hasFeedback
      ? '${_t.quizAnswerConfirmed} ${_t.quizFeedbackStaysAvailable}'
      : _t.quizAnswerConfirmed;
  static String get previousFeedback => _t.quizPreviousFeedback;

  static String get answerLockNotice => _t.quizAnswerLockNotice;

  // ─── Attempt: where am I and time ─────────────────────────────────────────

  static String timeLeft(Duration? remaining) => remaining == null
      ? _t.quizNoTimeLimit
      : _t.quizTimeLeft(SpokenFormat.duration(remaining));

  /// Visual countdown, for example "4:05 left".
  static String clock(Duration? remaining) {
    if (remaining == null) return _t.quizNoTimeLimitShort;
    final seconds = remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
    return _t.quizClockLeft('${remaining.inMinutes}:$seconds');
  }

  static String timeWarning(Duration remaining) =>
      _t.quizTimeWarning(SpokenFormat.duration(remaining));

  static String timeUp(int saved) => _t.quizTimeUp(saved);

  static String where({
    required int number,
    required Object? total,
    required int answered,
    String? selection,
    Duration? remaining,
    bool timed = false,
  }) => [
    _t.quizWhereQuestion('$number', '$total'),
    _t.quizAnsweredCount('$answered'),
    ?selection,
    if (timed) timeLeft(remaining),
  ].join(' ');

  static String allSaved(Duration? remaining, {bool timed = false}) =>
      '${_t.quizAllSaved}${timed ? ' ${timeLeft(remaining)}' : ''}';

  // ─── Attempt: finishing ───────────────────────────────────────────────────

  static String get finishNow => _t.quizFinishNow;
  static String get finishNowButton => _t.quizFinishNowButton;
  static String get finishTitle => _t.quizFinishTitle;

  static String finishMessage(int unanswered) =>
      _t.quizFinishMessage(unanswered);

  static String get finishConfirm => _t.quizFinishConfirm;
  static String get finishCancel => _t.quizFinishCancel;
  static String get finishUnchecked => _t.quizFinishUnchecked;
  static String get finishTimedOut => _t.quizFinishTimedOut;
  static String get finishing => _t.quizFinishing;
  static String get finishAndHear => _t.quizFinishAndHear;
  static String get retryFinishing => _t.quizRetryFinishing;

  static String completionFailed(String? reason) =>
      _t.quizCompletionFailed(reason ?? _t.quizCompletionNotConfirmed);

  static String completed({bool timedOut = false}) =>
      timedOut ? _t.quizCompletedTimedOut : _t.quizCompleted;

  static String get resultPrivate => _t.quizResultPrivate;
  static String get resultHeading => _t.quizResultHeading;
  static String get readResult => _t.quizReadResult;
  static String get returnToQuizzes => _t.quizReturnToQuizzes;

  // ─── Attempt: leaving ─────────────────────────────────────────────────────

  static String get leave => _t.quizLeave;
  static String get leaveTitle => _t.quizLeaveTitle;
  static String get leaveMessage => _t.quizLeaveMessage;
  static String get leaveConfirm => _t.quizLeaveConfirm;
  static String get leaveCancel => _t.quizLeaveCancel;
  static String get waitBeforeLeaving => _t.quizWaitBeforeLeaving;

  static String attemptScreen(String title) => _t.quizAttemptScreen(title);

  static String attemptNavigation({
    required bool completed,
    required bool timed,
  }) => completed
      ? _t.quizAttemptNavigationCompleted
      : timed
      ? _t.quizAttemptNavigationTimed
      : _t.quizAttemptNavigationUntimed;

  // ─── Speech speed ─────────────────────────────────────────────────────────

  static String get speedHelp => _t.quizSpeedHelp;
  static String get speedScreenReader => _t.quizSpeedScreenReader;
  static String get speedHeading => _t.quizSpeedHeading;

  static String speedTarget(String description) =>
      _t.quizSpeedTarget(description);

  static String speedRead(String description) => _t.quizSpeedRead(description);

  static String speedChanged(bool faster, String description) => faster
      ? _t.quizSpeedFaster(description)
      : _t.quizSpeedSlower(description);

  static String speedLimit(bool faster, String description) => faster
      ? _t.quizSpeedFastest(description)
      : _t.quizSpeedSlowest(description);

  /// Whether [text] is one of the speed announcements above, in the current
  /// speech language.
  static bool isSpeedAnnouncement(String text) {
    const marker = '\u0000';
    String before(String message) {
      final end = message.indexOf(marker);
      return end < 0 ? message : message.substring(0, end);
    }

    final prefixes = [
      before(_t.quizSpeedFaster(marker)),
      before(_t.quizSpeedSlower(marker)),
      before(_t.quizSpeedFastest(marker)),
      before(_t.quizSpeedSlowest(marker)),
      speedHeading,
    ];
    return prefixes.any(
      (prefix) => prefix.trim().isNotEmpty && text.startsWith(prefix),
    );
  }

  // ─── Student quiz list ────────────────────────────────────────────────────

  static String get studentScreen => _t.quizStudentScreen;
  static String get studentNavigation => _t.quizStudentNavigation;
  static String get studentIntro => Announce.pick(
    brief: _t.quizStudentIntroBrief,
    detailed: _t.quizStudentIntroDetailed,
  );

  static String available(int count) => _t.quizAvailable(count);

  static String studentState(int open, int total) =>
      _t.quizStudentState(total, '$open');

  static String stateName(String? state) => switch (state) {
    null => _t.quizStateAll,
    'scheduled' => _t.quizStateScheduled,
    'open' => _t.quizStateOpen,
    'closed' => _t.quizStateClosed,
    _ => state,
  };

  static String stateFilter(String name, int position, int count) =>
      _t.quizStateFilter(name, '$position', '$count');

  static String subjectFilter(String name, int position, int count) =>
      _t.quizSubjectFilter(name, '$position', '$count');

  static String get changeWithArrows => _t.quizChangeWithArrows;
  static String get allSubjects => _t.quizAllSubjects;

  static String quizRow(Map quiz) => [
    _t.quizRowHead(
      '${quiz['subject_name']}',
      '${quiz['title']}',
      status(quiz['display_status']),
    ),
    attemptsText(quiz),
    quiz['in_progress_attempt_id'] == null ? _t.quizStartQuiz : _t.quizResumeQuiz,
  ].join(' ');

  static String historyRow(Map quiz) =>
      _t.quizHistoryRow('${quiz['title']}', percent(quiz['highest_score']));

  static String limitReached(Object? title) => _t.quizLimitReached('$title');

  static String startTitle(bool resume) =>
      resume ? _t.quizResumeTitle : _t.quizStartTitle;

  static String startMessage(Map quiz) => [
    _t.quizTitleSentence('${quiz['title']}'),
    attemptsText(quiz),
    timeLimit(quiz['time_limit_minutes']),
    if (quiz['closes_at'] != null) _t.quizClosesSentence(when(quiz['closes_at'])),
    answerLockNotice,
    feedbackPolicy(quiz),
  ].join(' ');

  static String startConfirm(bool resume) =>
      resume ? _t.quizResumeAttempt : _t.quizStartAttempt;

  static String get startFailed => _t.quizStartFailed;
  static String get historyFailed => _t.quizHistoryFailed;

  // ─── Attempt history and review ───────────────────────────────────────────

  static String get historyScreen => _t.quizHistoryScreen;

  static String historySummary(Map history) {
    final attempts = history['attempts'] as List? ?? const [];
    if (attempts.any((attempt) => attempt['is_graded'] == false)) {
      return _t.quizPracticeHistory;
    }
    if (history['highest_score'] != null) {
      return _t.quizHighestScoreValue(percent(history['highest_score']));
    }
    return attempts.any((attempt) => attempt['status'] != 'in_progress')
        ? _t.quizNoScoreReleasedYet
        : _t.quizNoCompletedAttempt;
  }

  static String historyAttempt(Map attempt) => _t.quizHistoryAttempt(
    '${attempt['attempt_number']}',
    status(attempt['status']),
    attemptResult(attempt),
  );

  static String get resumeFromList => _t.quizResumeFromList;
  static String get reviewFailed => _t.quizReviewFailed;
  static String get reviewTimedOut => _t.quizReviewTimedOut;

  static String reviewScreen(int count, String? message) =>
      count == 0 && message != null
      ? _t.quizReviewScreenMessage(message)
      : _t.quizReviewScreen(count);

  static String reviewQuestion(Map question, int index) {
    final number = '${index + 1}';
    final text =
        '${question['spoken_question_text'] ?? question['question_text']}';
    final chosen =
        '${question['selected_option_spoken_text'] ?? question['selected_option_text'] ?? _t.quizNoAnswer}';
    final answer =
        '${question['correct_option_spoken_text'] ?? question['correct_option_text']}';
    final explanation =
        '${question['spoken_explanation'] ?? question['explanation'] ?? _t.quizNoExplanation}';
    return question['is_correct'] == true
        ? _t.quizReviewQuestionCorrect(number, text, chosen, answer, explanation)
        : _t.quizReviewQuestionIncorrect(
            number,
            text,
            chosen,
            answer,
            explanation,
          );
  }

  // ─── Teacher quiz list ────────────────────────────────────────────────────

  static String teacherScreen(String className, String subjectName) =>
      _t.quizTeacherScreen(className, subjectName);

  static String get teacherNavigation => _t.quizTeacherNavigation;

  static String get teacherIntro =>
      Announce.pick(brief: '', detailed: _t.quizTeacherIntroDetailed);

  static String teacherLoaded(int questionCount, int quizCount) =>
      _t.quizTeacherLoaded(
        _t.quizBankQuestionCount(questionCount),
        _t.quizQuizCount(quizCount),
      );

  static String teacherState(List quizzes, int bankCount) {
    int count(String status) =>
        quizzes.where((quiz) => quiz['status'] == status).length;
    return _t.quizTeacherState(
      _t.quizDraftCount(count('draft')),
      '${count('published')}',
      '${count('closed')}',
      _t.quizBankQuestionCount(bankCount),
    );
  }

  static String get teacherLoadFailed => _t.quizTeacherLoadFailed;
  static String get refreshQuizzes => _t.quizRefreshQuizzes;
  static String get searchBank => _t.quizSearchBank;
  static String get createQuestion => _t.quizCreateQuestion;
  static String get createQuiz => _t.quizCreateQuiz;
  static String get createPractice => _t.quizCreatePractice;

  static String bankQuestion(Map question) => _t.quizBankQuestionItem(
    '${question['spoken_question_text'] ?? question['question_text']}',
    '${question['revision'] ?? _t.quizRevisionUnknownOlder}',
  );

  static String quizPrimary(Map quiz) => quiz['status'] == 'draft'
      ? _t.quizContinueCreating(
          '${quiz['title']}',
          questions(quiz['question_count'] as int? ?? 0),
        )
      : quiz['status'] == 'published'
      ? _t.quizCloseWithConfirmation('${quiz['title']}')
      : _t.quizIsClosed('${quiz['title']}');

  static String quizDuplicate(Map quiz) =>
      _t.quizDuplicateTarget('${quiz['title']}');
  static String quizResults(Map quiz) =>
      _t.quizResultsTarget('${quiz['title']}');

  static String quizCard(Map quiz) => _t.quizCard(
    '${quiz['title']}',
    status(quiz['display_status']),
    questions(quiz['question_count'] as int? ?? 0),
  );

  static String get accountChangedBank => _t.quizAccountChangedBank;

  static String questionSaveUnconfirmed(String reason) =>
      _t.quizQuestionSaveUnconfirmed(reason);

  static String get missingRevision => _t.quizMissingRevision;
  static String get savedQuestionMismatch => _t.quizSavedQuestionMismatch;
  static String get questionSaved => _t.quizQuestionSaved;
  static String get noRevisionForEdit => _t.quizNoRevisionForEdit;

  static String questionUpdateUnconfirmed(String? reason) =>
      _t.quizQuestionUpdateUnconfirmed(reason ?? _t.quizSavedRevisionMismatch);

  static String get questionUpdated => _t.quizQuestionUpdated;
  static String get archiveTitle => _t.quizArchiveTitle;
  static String get archiveMessage => _t.quizArchiveMessage;
  static String get archiveConfirm => _t.quizArchiveConfirm;
  static String get archiveFailed => _t.quizArchiveFailed;
  static String get archived => _t.quizArchived;
  static String get duplicateQuestionFailed => _t.quizDuplicateQuestionFailed;
  static String get questionDuplicated => _t.quizQuestionDuplicated;

  static String questionActions(Map question) => _t.quizQuestionActions(
    '${question['spoken_question_text'] ?? question['question_text']}',
  );

  static String get actionEdit => _t.quizActionEdit;
  static String get actionDuplicate => _t.quizActionDuplicate;
  static String get actionArchive => _t.quizActionArchive;
  static String get actionRevisions => _t.quizActionRevisions;
  static String actionAddTo(Object? title) => _t.quizActionAddTo('$title');

  static String get refreshBeforeDraft => _t.quizRefreshBeforeDraft;

  static String draftUnconfirmed(String? reason) =>
      _t.quizDraftUnconfirmed(reason ?? _t.quizSavedDraftMismatch);

  static String get draftSaved => _t.quizDraftSaved;
  static String get addToQuizFailed => _t.quizAddToQuizFailed;
  static String get addedToQuiz => _t.quizAddedToQuiz;
  static String get publishTitle => _t.quizPublishTitle;

  static String publishMessage(Object? title) => _t.quizPublishMessage('$title');

  static String get publishConfirm => _t.quizPublishConfirm;
  static String get publishUnconfirmed => _t.quizPublishUnconfirmed;

  static String published(int recipients, int sent, int failures) =>
      recipients == 0
      ? _t.quizPublishedNoRecipients
      : sent == 0
      ? _t.quizPublishedNoneDelivered
      : failures > 0
      ? _t.quizPublishedWithFailures('$sent', '$failures')
      : _t.quizPublishedSent('$sent');

  static String get closeTitle => _t.quizCloseTitle;

  static String closeMessage(Object? title) => _t.quizCloseMessage('$title');

  static String get closeConfirm => _t.quizCloseConfirm;
  static String get closeFailed => _t.quizCloseFailed;
  static String get closed => _t.quizClosed;
  static String get duplicateQuizFailed => _t.quizDuplicateQuizFailed;
  static String get quizDuplicated => _t.quizQuizDuplicated;

  // ─── Guided draft ─────────────────────────────────────────────────────────

  static String get draftAccountChanged => _t.quizDraftAccountChanged;
  static String get draftLoadFailed => _t.quizDraftLoadFailed;

  static String bankRefreshFailed(String? reason) =>
      _t.quizBankRefreshFailed(reason ?? _t.quizSavedListUnreadable);

  static String get noUnusedQuestions => _t.quizNoUnusedQuestions;
  static String get chooseSaved => _t.quizChooseSaved;

  static String addUnconfirmed(String? reason) =>
      _t.quizAddUnconfirmed(reason ?? _t.quizSavedDraftMismatch);

  static String questionAdded(int count) => [
    _t.quizQuestionAddedSentence,
    _t.quizQuestionsSaved(count),
    _t.quizAddAnotherOrReview,
  ].join(' ');

  static String draftSummary(Map quiz, int questionCount) => [
    _t.quizDraftSummaryHead(
      '${quiz['title']}',
      '${quiz['description'] ?? ''}',
      questions(questionCount),
    ),
    quiz['mode'] == 'practice'
        ? _t.quizUngradedPracticeSummary
        : '${_t.quizGradedSummary(attempts(quiz['attempt_limit'] as int? ?? 1))} '
              '${quiz['time_limit_minutes'] == null ? _t.quizNoTimer : _t.quizPerAttempt(minutes(quiz['time_limit_minutes'] as int))}',
    feedbackPolicy(quiz),
    _t.quizOpensSentence(when(quiz['opens_at'], fallback: _t.quizWhenPublished)),
    _t.quizClosesSentence(
      when(quiz['closes_at'], fallback: _t.quizNeverNotScheduled),
    ),
    _t.quizShuffleQuestionsState(
      SpokenFormat.onOff(quiz['shuffle_questions'] == true),
    ),
    _t.quizShuffleOptionsState(
      SpokenFormat.onOff(quiz['shuffle_options'] == true),
    ),
  ].join(' ');

  static String get removeChoose => _t.quizRemoveChoose;
  static String removeOption(int index, Object? text) =>
      _t.quizRemoveOption('${index + 1}', '$text');
  static String get removeTitle => _t.quizRemoveTitle;
  static String get removeMessage => _t.quizRemoveMessage;
  static String get removeConfirm => _t.quizRemoveConfirm;
  static String get removeUnconfirmed => _t.quizRemoveUnconfirmed;

  static String removed(int count) =>
      '${_t.quizQuestionRemovedSentence} ${_t.quizQuestionsSaved(count)}';

  static String get settingsUnconfirmed => _t.quizSettingsUnconfirmed;
  static String get settingsSaved => _t.quizSettingsSaved;

  static String draftHeader(Object? title, int count) =>
      '${_t.quizTitleSentence('$title')} ${_t.quizQuestionsSaved(count)}';

  static String savedQuestion(int index, Object? text) =>
      _t.quizSavedQuestion('${index + 1}', '$text');

  static String reviewDraftQuestion(Map question, int index) {
    final options = question['options'] as List? ?? const [];
    final spoken = question['spoken_options'] as List?;
    final head = _t.quizQuestionNumbered(
      '${index + 1}',
      '${question['spoken_question_text'] ?? question['question_text']}',
    );
    final spokenOptions = [
      for (var i = 0; i < options.length; i++)
        options[i]['is_correct'] == true
            ? _t.quizDraftOptionCorrect(
                '${i + 1}',
                '${spoken != null && i < spoken.length ? spoken[i] : options[i]['option_text']}',
              )
            : _t.quizDraftOption(
                '${i + 1}',
                '${spoken != null && i < spoken.length ? spoken[i] : options[i]['option_text']}',
              ),
    ].join(' ');
    return '$head $spokenOptions '
        '${question['spoken_explanation'] ?? question['explanation'] ?? ''}';
  }

  static String draftState(int count, {required bool review}) =>
      '${_t.quizQuestionsSaved(count)} '
      '${review ? _t.quizReviewingBeforePublishing : _t.quizAddingQuestions}';

  // ─── Results ──────────────────────────────────────────────────────────────

  static String resultsScreen(String title) => _t.quizResultsScreen(title);
  static String get resultsNavigation => _t.quizResultsNavigation;
  static String get resultsFailed => _t.quizResultsFailed;

  static String resultsLoaded(Map summary) =>
      '${_t.quizStudentsCompleted(_intValue(summary['completed']))} '
      '${_t.quizStudentsNotAttemptedYet(_intValue(summary['not_attempted']))}';

  static int _intValue(Object? value) => value is num ? value.round() : 0;

  static String statistics(Map summary) => [
    _t.quizStatEligible('${summary['eligible_students']}'),
    _t.quizStatStarted('${summary['started']}'),
    _t.quizStatCompleted('${summary['completed']}'),
    _t.quizStatNotAttempted('${summary['not_attempted']}'),
    _t.quizStatCompletion(percent(summary['completion_percentage'])),
    summary['mode'] == 'practice'
        ? _t.quizPracticeParticipation
        : [
            _t.quizStatAverageHighest(percent(summary['average_highest_score'])),
            _t.quizHighestScoreValue(percent(summary['highest_score'])),
            _t.quizStatLowest(percent(summary['lowest_completed_score'])),
          ].join('\n'),
  ].join('\n');

  static String studentResult(Map student, {required bool practice}) {
    final attemptList = student['attempts'] as List? ?? const [];
    final name = '${student['student_name']}';
    if (attemptList.isEmpty) {
      return _t.quizStudentNotAttempted(name);
    }
    if (practice) {
      return _t.quizStudentPractice(attemptList.length, name);
    }
    final scores = attemptList
        .map(
          (attempt) => _t.quizStudentAttemptScore(
            '${attempt['attempt_number']}',
            percent(attempt['percentage_score']),
            status(attempt['status']),
          ),
        )
        .join('. ');
    return _t.quizStudentScores(name, percent(student['highest_score']), scores);
  }

  static String get extraMismatch => _t.quizExtraMismatch;
  static String get extraSaved => _t.quizExtraSaved;
  static String get everyoneAttempted => _t.quizEveryoneAttempted;
  static String get remindTitle => _t.quizRemindTitle;

  static String remindMessage(int count, String title) =>
      _t.quizRemindMessage(count, title);

  static String get remindConfirm => _t.quizRemindConfirm;
  static String get remindFailed => _t.quizRemindFailed;

  static String reminded(Object? notified, Object? queued) =>
      _t.quizReminded('$notified', '$queued');

  static String get refreshResults => _t.quizRefreshResults;
  static String get remindUnavailable => _t.quizRemindUnavailable;

  static String remindTarget(int count) => _t.quizRemindTarget(count);

  static String extraTarget(Map student) => _t.quizExtraTarget(
    '${student['student_name']}',
    minutes(student['extra_time_minutes'] as int? ?? 0),
  );

  static String extraButton(Map student) =>
      _t.quizExtraButton('${student['extra_time_minutes'] ?? 0}');

  static String resultsState(Map? summary, int notAttempted) => summary == null
      ? _t.quizResultsNotLoaded
      : '${resultsLoaded(summary)} '
            '${_t.quizCompletionSentence(percent(summary['completion_percentage']))}';

  // ─── Extra time dialog ────────────────────────────────────────────────────

  static String extraScreen(String name) => _t.quizExtraScreen(name);

  static String extraField(String text) =>
      _t.quizExtraField(text.isEmpty ? _t.quizEmpty : text);

  static String get extraSave => _t.quizExtraSave;
  static String get extraCancel => _t.quizExtraCancel;
  static String get extraInvalid => _t.quizExtraInvalid;
  static String get extraCorrect => _t.quizExtraCorrect;

  // ─── Question editor ──────────────────────────────────────────────────────

  static String get editorInvalid => _t.quizEditorInvalid;
  static String get editorSpokenInvalid => _t.quizEditorSpokenInvalid;

  static String correctChosen(int index, String text, int count) =>
      text.isEmpty
      ? _t.quizCorrectChosen('${index + 1}', '$count')
      : _t.quizCorrectChosenWithText('${index + 1}', text, '$count');

  static String correctTarget(int? index, String text) => index == null
      ? _t.quizCorrectNotSelected
      : _t.quizCorrectTarget('${index + 1}', text);

  static String toggled(String name, bool on) =>
      _t.quizToggled(name, SpokenFormat.onOff(on));

  static String notation(bool described) =>
      described ? _t.quizContentDescribed : _t.quizContentPlain;

  static String reviewed(bool value) =>
      value ? _t.quizReviewedYes : _t.quizReviewedNo;

  // ─── Quiz settings editor ─────────────────────────────────────────────────

  static String get settingsInvalid => _t.quizSettingsInvalid;
  static String get setOpening => _t.quizSetOpening;
  static String get setClosing => _t.quizSetClosing;

  static String openingSet(DateTime value) =>
      _t.quizOpeningSet(SpokenFormat.dateTime(value));
  static String closingSet(DateTime value) =>
      _t.quizClosingSet(SpokenFormat.dateTime(value));
  static String releaseSet(DateTime value) =>
      _t.quizReleaseSet(SpokenFormat.dateTime(value));
  static String get openingCleared => _t.quizOpeningCleared;
  static String get closingCleared => _t.quizClosingCleared;

  static String opening(DateTime? value) => value == null
      ? _t.quizNoOpeningTime
      : _t.quizOpensAt(SpokenFormat.dateTime(value));
  static String closing(DateTime? value) => value == null
      ? _t.quizNoClosingTime
      : _t.quizClosesAt(SpokenFormat.dateTime(value));

  static String policy(String policy, int position, int count) =>
      _t.quizPolicyChoice(policyName(policy), '$position', '$count');

  static String release(DateTime? value) => _t.quizScheduledRelease(
    value == null ? _t.quizNotSet : SpokenFormat.dateTime(value),
  );

  static String attemptLimit(String text) => _t.quizAttemptLimitField(text);

  static String timeLimitField(String text) =>
      _t.quizTimeLimitField(text.isEmpty ? _t.quizNotSet : text);

  // ─── Revision history ─────────────────────────────────────────────────────

  static String get revisionsScreen => _t.quizRevisionsScreen;
  static String get revisionsAccount => _t.quizRevisionsAccount;
  static String get revisionsCleared => _t.quizRevisionsCleared;
  static String get revisionsUnverified => _t.quizRevisionsUnverified;
  static String get revisionsContentUnverified =>
      _t.quizRevisionsContentUnverified;
  static String get revisionsTimedOut => _t.quizRevisionsTimedOut;
  static String get noRevisions => _t.quizNoRevisions;

  static String revisionsLoaded(int count, Object? revision, Object? at) =>
      _t.quizRevisionsLoaded(
        count,
        '$revision',
        when(at, fallback: _t.quizDateUnknown),
      );

  static String revisionSelected(Object? revision, int position, int? count) =>
      count == null
      ? _t.quizRevisionSelected('$revision')
      : _t.quizRevisionSelectedOf('$revision', '$position', '$count');

  static String revisionFailed(String message) =>
      _t.quizRevisionFailed(message);

  static String revisionState(Object? revision) => revision == null
      ? _t.quizNoRevisionLoaded
      : _t.quizShowingRevision('$revision');

  /// Readable sections of one revision, keyed by section id.
  static Map<String, String> revisionSections(Map? revision) {
    final content = revision?['content'] as Map?;
    final options = content?['options'] as List? ?? const [];
    final spoken = content?['spoken_options'] as List? ?? const [];
    return {
      if (revision != null)
        'version': _t.quizRevisionVersion(
          '${revision['revision']}',
          when(revision['recorded_at'], fallback: _t.quizDateUnknown),
        ),
      if (content != null) ...{
        'question': _t.quizRevisionQuestion(
          '${content['spoken_question_text'] ?? content['question_text']}',
        ),
        'topics': _t.quizRevisionTopics(
          (content['topics'] as List? ?? const []).join(', '),
        ),
        for (var i = 0; i < options.length; i++)
          'option-$i':
              '${_t.quizRevisionOption('${i + 1}', '${i < spoken.length ? spoken[i] : options[i]}')} '
              '${content['correct_option_index'] == i ? _t.quizCorrectAnswerSentence : ''}',
        'explanation': _t.quizRevisionExplanation(
          '${content['spoken_explanation'] ?? content['explanation'] ?? _t.quizNotProvided}',
        ),
      },
      'notice': _t.quizRevisionNotice,
    };
  }

  static Map<String, String> revisionTitles(Map? revision) {
    final content = revision?['content'] as Map?;
    final options = content?['options'] as List? ?? const [];
    return {
      if (revision != null)
        'version': _t.quizRevisionVersionTitle(
          '${revision['revision']}',
          when(revision['recorded_at'], fallback: _t.quizDateUnknown),
        ),
      if (content != null) ...{
        'question': _t.quizQuestionTextTitle,
        'topics': _t.quizTopicsTitle,
        for (var i = 0; i < options.length; i++)
          'option-$i': content['correct_option_index'] == i
              ? _t.quizOptionNumberCorrect('${i + 1}')
              : _t.quizOptionNumber('${i + 1}'),
        'explanation': _t.quizExplanationTitle,
      },
      'notice': _t.quizRevisionNoticeTitle,
    };
  }

  static String revisionSection(String title, {required bool sameAccount}) =>
      sameAccount
      ? _t.quizRevisionSectionTarget(title)
      : _t.quizAccountChangedSignIn;

  static String get goBack => _t.quizGoBack;
  static String get cancel => _t.quizCancel;
  static String get cancelAndReturn => _t.quizCancelAndReturn;
  static String get actionNavigation => _t.quizActionNavigation;
  static String get refreshRevisions => _t.quizRefreshRevisions;
  static String get newerRevision => _t.quizNewerRevision;
  static String get olderRevision => _t.quizOlderRevision;

  // Teacher authoring and attempt messages moved out of the screens.
  static String get bankArchived => _t.quizBankArchived;
  static String get bankCopied => _t.quizBankCopied;
  static String get snapshotAdded => _t.quizSnapshotAdded;
  static String get quizClosed => _t.quizQuizClosed;
  static String get draftCreated => _t.quizDraftCreated;
  static String get noAnswerSelected => _t.quizNoAnswerSelected;
  static String get selectBeforeSubmit => _t.quizSelectBeforeSubmit;
  static String get submitBeforeContinuing => _t.quizSubmitBeforeContinuing;
}
