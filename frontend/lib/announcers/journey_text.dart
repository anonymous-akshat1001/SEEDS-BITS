import '../l10n/speech.dart';
import '../services/journey_engine.dart';
import '../services/journey_models.dart';
import 'announce.dart';

/// Every sentence spoken by learning-journey screens, kept in one place so
/// wording stays consistent. The text comes from the ARB translation files.
class JourneyAnnouncer {
  const JourneyAnnouncer._();

  static AppLocalizations get _t => Speech.t;

  static String where(JourneyEngine engine) {
    final step = engine.current;
    if (step == null) return _t.journeyWhereFinished(engine.snapshot.title);
    final number = '${engine.index + 1}';
    final total = '${engine.stepCount}';
    final kind = _kindName(step.kind);
    return engine.replaying
        ? _t.journeyWhereReplaying(number, total, kind, engine.snapshot.title)
        : _t.journeyWhere(number, total, kind, engine.snapshot.title);
  }

  static String _kindName(JourneyStepKind kind) => switch (kind) {
    JourneyStepKind.audio => _t.journeyKindRecording,
    JourneyStepKind.narration => _t.journeyKindNarration,
    JourneyStepKind.question => _t.journeyKindQuestion,
    JourneyStepKind.poll => _t.journeyKindPoll,
  };

  static String options(JourneyStep step) => [
    for (var i = 0; i < step.options.length; i++)
      _t.journeyOption('${i + 1}', step.options[i]),
  ].join(' ');

  static String question(JourneyEngine engine) {
    final step = engine.current!;
    final keys = _t.journeyChooseKeys('${step.options.length}');
    if (step.kind == JourneyStepKind.poll) {
      return _t.journeyPollQuestion(step.text, options(step), keys);
    }
    if (engine.attemptsUsed(engine.index) > 0) {
      return _t.journeyQuestionTryAgain(
        _t.journeyTriesLeft(engine.triesLeft),
        step.text,
        options(step),
        keys,
      );
    }
    return _t.journeyQuestion(step.text, options(step), keys);
  }

  static String chosen(JourneyStep step, int option) =>
      _t.journeyChosen('${option + 1}', step.options[option]);

  static String content(JourneyStep step) => switch (step.kind) {
    JourneyStepKind.audio => _t.journeyRecordingContent(
      step.title ?? _t.journeyUntitled,
    ),
    _ => step.text,
  };

  static String get contentKeys => _t.journeyContentKeys;

  static String outcome(JourneyOutcome outcome, JourneyStep step) =>
      switch (outcome) {
        JourneyOutcome.correct => _t.journeyCorrect(
          step.options[step.correctIndex!],
        ),
        JourneyOutcome.pollSaved => _t.journeyPollSaved,
        JourneyOutcome.replay => _t.journeyReplayOutcome,
        JourneyOutcome.tryAgain => _t.journeyTryAgainOutcome,
        JourneyOutcome.revealed => _t.journeyRevealed(
          '${step.correctIndex! + 1}',
          step.options[step.correctIndex!],
          step.explanation ?? '',
        ),
      };

  static String finished(JourneyEngine engine) {
    final questions = engine.questionCount;
    return [
      _t.journeyWellDone(engine.snapshot.title),
      if (questions > 0)
        _t.journeyFirstTryScore(questions, '${engine.firstTryCorrect}'),
      _t.journeyPlayAgainHelp,
    ].join(' ');
  }

  static String studentRow(
    StudentJourneySummary journey, {
    bool downloaded = false,
  }) {
    final status = switch (journey.status) {
      'completed' => _t.journeyStatusCompleted,
      'in_progress' => _t.journeyStatusInProgress,
      _ => _t.journeyStatusNew,
    };
    return [
      _t.journeyStudentRow(
        journey.title,
        journey.subjectName ?? '',
        '${journey.stepCount}',
        '${journey.questionCount}',
        status,
      ),
      if (journey.percentage != null)
        _t.journeyRowScore('${journey.percentage!.round()}'),
      if (downloaded) _t.journeyRowDownloaded,
    ].join(' ');
  }

  static String teacherRow(JourneyDraft journey) => [
    _t.journeyTeacherRow(
      journey.title,
      journey.statusWords,
      '${journey.stepCount}',
      '${journey.questionCount}',
    ),
    if (journey.graded) _t.journeyRowGraded,
  ].join(' ');

  static String stepRow(List<JourneyStep> steps, int index) {
    final step = steps[index];
    return [
      _t.journeyStepRow('${index + 1}', '${steps.length}', step.spokenName),
      if (step.kind == JourneyStepKind.question)
        step.replayFrom == null
            ? _t.journeyReplaysAutomatically
            : _t.journeyReplaysFrom('${step.replayFrom! + 1}'),
    ].join(' ');
  }

  // ─── Player ───────────────────────────────────────────────────────────────

  /// Star state: step, selection and playback.
  static String state(
    JourneyEngine engine, {
    int? selected,
    bool playing = false,
  }) {
    final step = engine.current;
    if (step == null) return _t.journeyFinishedStatus;
    final parts = <String>[where(engine)];
    if (step.kind == JourneyStepKind.audio) {
      parts.add(
        playing ? _t.journeyRecordingPlaying : _t.journeyRecordingPaused,
      );
    }
    if (step.isAnswer) {
      parts.add(
        selected == null
            ? _t.journeyNoOptionChosen
            : _t.journeyOptionSelected(
                '${selected + 1}',
                step.options[selected],
              ),
      );
      if (step.kind == JourneyStepKind.question &&
          engine.attemptsUsed(engine.index) > 0) {
        parts.add(_t.journeyTriesLeft(engine.triesLeft));
      }
    }
    return parts.join(' ');
  }

  static String start(
    JourneySnapshot journey, {
    required bool preview,
    required bool resumed,
  }) => preview
      ? _t.journeyPreviewStart(journey.title)
      : resumed
      ? _t.journeyWelcomeBack(journey.title)
      : Announce.pick(
          brief: _t.journeyStartingBrief(journey.title),
          detailed: _t.journeyStartingDetailed(
            journey.title,
            '${journey.steps.length}',
          ),
        );

  static String notSaved(String reason) => _t.journeyNotSaved(reason);
  static String get listeningAgain => '${_t.journeyListeningAgain} ';
  static String narration(String text) => _t.journeyNarration(text);
  static String recordingStatus(JourneyStep step) =>
      _t.journeyRecordingStatus(step.title ?? _t.journeyUntitled);
  static String get recordingFailed => _t.journeyRecordingFailed;
  static String get recordingRetry => _t.journeyRecordingRetry;
  static String get notDownloaded => _t.journeyNotDownloaded;
  static String get recordingFinished => _t.journeyRecordingFinished;
  static String answerFirst(int options) => _t.journeyAnswerFirst('$options');
  static String get noEarlierContent => _t.journeyNoEarlierContent;
  static String get goingBack => _t.journeyGoingBack;
  static String noSuchOption(int option, int options) =>
      _t.journeyNoSuchOption('$option', '$options');
  static String chooseFirst(int options) => _t.journeyChooseFirst('$options');
  static String get finishedStatus => _t.journeyFinishedStatus;
  static String get sendLater => _t.journeySendLater;
  static String get startingAgain => _t.journeyStartingAgain;
  static String get paused => _t.journeyPaused;
  static String get seekRecordingsOnly => _t.journeySeekRecordingsOnly;
  static String get speedRecordingsOnly => _t.journeySpeedRecordingsOnly;
  static String get fastest => _t.journeyFastest;
  static String get slowest => _t.journeySlowest;
  static String speed(double rate) =>
      _t.journeySpeed(rate.toStringAsFixed(2));
  static String get leaveTitle => _t.journeyLeaveTitle;
  static String leaveMessage(int step) => _t.journeyLeaveMessage('$step');
  static String get answerHelp => _t.journeyAnswerHelp;

  // ─── Authoring and lists ──────────────────────────────────────────────────
  static String stepRemoved(int remaining) =>
      _t.journeyStepRemoved('$remaining');
  static String stepRemovedUndo(JourneyStep step) =>
      _t.journeyStepRemovedUndo(step.spokenName);
  static String get stepRestored => _t.journeyStepRestored;
  static String created(String title) => _t.journeyCreated(title);
  static String get noStepAdded => _t.journeyNoStepAdded;
  static String previewSkips(List<String> issues) =>
      _t.journeyPreviewSkips(issues.join(' '));
  static String duplicated(String title) => _t.journeyDuplicated(title);
  static String archiveMessage(String title, {required bool archive}) =>
      archive ? _t.journeyArchiveMessage(title) : _t.journeyRestoreMessage(title);
  static String get archived => _t.journeyArchived;
  static String get restored => _t.journeyRestored;
  static String deleteDraftMessage(String title) =>
      _t.journeyDeleteDraftMessage(title);
  static String get draftDeleted => _t.journeyDraftDeleted;
  static String get noRetriesLeft => _t.journeyNoRetriesLeft;
  static String get maxRetries => _t.journeyMaxRetries;
  static String published(int delivered) => _t.journeyPublished('$delivered');
  static String get optionUsed => _t.journeyOptionUsed;
  static String get nothingToReplay => _t.journeyNothingToReplay;
  static String get bankEmpty => _t.journeyBankEmpty;
  static String get recordViaNotes => _t.journeyRecordViaNotes;
  static String get noRecordings => _t.journeyNoRecordings;
  static String get openingFiles => _t.journeyOpeningFiles;
  static String get noFile => _t.journeyNoFile;
  static String get uploading => _t.journeyUploading;
  static String get uploadUnconfirmed => _t.journeyUploadUnconfirmed;
  static String uploaded(String title) => _t.journeyUploaded(title);
  static String get storageUnavailable => _t.journeyStorageUnavailable;
  static String get nothingInProgress => _t.journeyNothingInProgress;
  static String get teacherUpdated => _t.journeyTeacherUpdated;
  static String startOverMessage(String title) =>
      _t.journeyStartOverMessage(title);
  static String removeDownloadMessage(String title) =>
      _t.journeyRemoveDownloadMessage(title);
  static String downloadRemoved(String title) =>
      _t.journeyDownloadRemoved(title);
  static String downloading(int recordings) =>
      _t.journeyDownloading(recordings);
  static String downloaded(String title) => _t.journeyDownloaded(title);
  static String get cancellingDownload => _t.journeyCancellingDownload;

  static String stepDetails(JourneyStep step) => switch (step.kind) {
    JourneyStepKind.audio => step.spokenName,
    JourneyStepKind.narration => step.spokenName,
    JourneyStepKind.question => _t.journeyStepDetailsQuestion(
      step.spokenName,
      options(step),
      '${step.correctIndex! + 1}',
      step.explanation == null
          ? _t.journeyNoExplanation
          : _t.journeyExplanation(step.explanation!),
    ),
    JourneyStepKind.poll => '${step.spokenName} ${options(step)}',
  };
}
