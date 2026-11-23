import 'dart:async';

import 'package:flutter/material.dart';

import '../../l10n/speech.dart';
import '../../services/undo_service.dart';
import '../../services/message_center.dart';
import '../../announcers/announce.dart';
import '../../announcers/journey_text.dart';
import '../../services/journey_api.dart';
import '../../services/journey_models.dart';
import '../../services/tts_service.dart';
import '../../widgets/journey_menu.dart';
import '../../widgets/journey_prompts.dart';
import 'journey_player_screen.dart';
import 'journey_results_screen.dart';
import 'journey_step_composer.dart';

/// Holds the journey being edited so every small screen shows the latest
/// saved version and reports results the same way.
class JourneyEditor extends ChangeNotifier {
  JourneyEditor(this.api, this.journey);

  final JourneyApi api;
  JourneyDraft journey;
  bool busy = false;
  String? issue;
  String? status;

  Future<bool> run(String done, Future<JourneyDraft> Function() action) async {
    if (busy) {
      unawaited(TtsService.speak(CommonText.pleaseWait));
      return false;
    }
    busy = true;
    issue = null;
    notifyListeners();
    try {
      journey = await action();
      status = done;
      MessageCenter.success(done);
      return true;
    } on JourneyApiException catch (error) {
      issue = error.message;
      if (error.statusCode == 409) {
        try {
          journey = await api.teacherJourney(journey.journeyId);
          issue = Speech.t.journeyLatestLoaded(error.message);
        } on JourneyApiException {
          // Keep the older copy; the message already says to refresh.
        }
      }
      MessageCenter.error(issue!);
      return false;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<bool> saveSteps(List<JourneyStep> steps, String done) =>
      run(done, () => api.update(journey, steps: steps));
}

/// Teacher entry point for one class-and-subject workspace.
class TeacherJourneysScreen extends StatefulWidget {
  const TeacherJourneysScreen({
    super.key,
    required this.classId,
    required this.subjectId,
    required this.workspaceName,
    this.api = const JourneyApi(),
  });

  final int classId;
  final int subjectId;
  final String workspaceName;
  final JourneyApi api;

  @override
  State<TeacherJourneysScreen> createState() => _TeacherJourneysScreenState();
}

class _TeacherJourneysScreenState extends State<TeacherJourneysScreen> {
  List<JourneyDraft> _journeys = [];
  bool _busy = true;
  bool _loaded = false;
  String? _issue;
  String? _status;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load({bool announce = false}) async {
    setState(() {
      _busy = true;
      _issue = null;
    });
    try {
      _journeys = await widget.api.teacherJourneys(
        widget.classId,
        widget.subjectId,
      );
      _loaded = true;
      _status = _summary();
    } on JourneyApiException catch (error) {
      _issue = error.message;
    }
    if (!mounted) return;
    setState(() => _busy = false);
    if (announce || _issue != null) {
      unawaited(
        TtsService.speak([_issue, _status].whereType<String>().join(' ')),
      );
    }
  }

  List<JourneyDraft> _with(bool Function(JourneyDraft) test) =>
      _journeys.where(test).toList();

  String _summary() => Speech.t.journeyTeacherSummary(
    '${_with((j) => j.isDraft).length}',
    '${_with((j) => j.isPublished).length}',
    '${_with((j) => j.isArchived).length}',
  );

  Future<void> _create() async {
    final title = await JourneyPrompts.askText(
      context,
      title: Speech.t.journeyNewJourneyTitle,
      label: Speech.t.journeyNameExample,
      max: 160,
    );
    if (title == null || !mounted) return;
    setState(() => _busy = true);
    try {
      final journey = await widget.api.create(
        widget.classId,
        widget.subjectId,
        title,
      );
      if (!mounted) return;
      setState(() => _busy = false);
      MessageCenter.success(JourneyAnnouncer.created(title));
      await _open(journey);
    } on JourneyApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _issue = error.message;
      });
      MessageCenter.error(error.message);
    }
  }

  Future<void> _open(JourneyDraft journey) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) =>
            JourneyOverviewScreen(editor: JourneyEditor(widget.api, journey)),
      ),
    );
    if (mounted) await _load();
  }

  Future<void> _list(String title, List<JourneyDraft> items) async {
    final chosen = await JourneyPrompts.choose<JourneyDraft>(
      context,
      title: title,
      items: items,
      labelOf: JourneyAnnouncer.teacherRow,
    );
    if (chosen != null && mounted) await _open(chosen);
  }

  @override
  Widget build(BuildContext context) {
    final t = Speech.t;
    final drafts = _with((j) => j.isDraft);
    final published = _with((j) => j.isPublished);
    final archived = _with((j) => j.isArchived);
    final loadFirst = t.journeyRefreshFirst;
    return JourneyMenu(
      title: t.journeyLearningJourneys,
      introduction: t.journeyTeacherIntro(widget.workspaceName),
      status: _status,
      issue: _issue,
      busy: _busy,
      details: [_issue, _status].whereType<String>().join(' '),
      choices: [
        JourneyChoice(
          t.journeyCreateNew,
          () => unawaited(_create()),
          enabled: _loaded,
          unavailableReason: loadFirst,
        ),
        JourneyChoice(
          t.journeyDraftsCount('${drafts.length}'),
          () => unawaited(_list(t.journeyDraftJourneys, drafts)),
          enabled: drafts.isNotEmpty,
          unavailableReason: t.journeyNoDrafts,
        ),
        JourneyChoice(
          t.journeyPublishedCount('${published.length}'),
          () => unawaited(_list(t.journeyPublishedJourneys, published)),
          enabled: published.isNotEmpty,
          unavailableReason: t.journeyNothingPublished,
        ),
        JourneyChoice(
          t.journeyArchivedCount('${archived.length}'),
          () => unawaited(_list(t.journeyArchivedJourneys, archived)),
          enabled: archived.isNotEmpty,
          unavailableReason: t.journeyNothingArchived,
        ),
        JourneyChoice(
          t.journeyRefreshList,
          () => unawaited(_load(announce: true)),
        ),
      ],
    );
  }
}

/// One journey: hear and edit steps, add a step, preview, publish, more.
class JourneyOverviewScreen extends StatelessWidget {
  const JourneyOverviewScreen({super.key, required this.editor});
  final JourneyEditor editor;

  String _summary(JourneyDraft journey) {
    final t = Speech.t;
    return t.journeyOverviewSummary(
      journey.statusWords,
      '${journey.steps.length}',
      '${journey.steps.where((s) => s.kind == JourneyStepKind.question).length}',
      journey.graded ? t.journeyGraded : t.journeyNotGraded,
      t.journeyRetriesPerQuestion(journey.maxRetries),
    );
  }

  Future<void> _steps(BuildContext context) async {
    final steps = editor.journey.steps;
    final index = await JourneyPrompts.choose<int>(
      context,
      title: Speech.t.journeySteps,
      items: List.generate(steps.length, (i) => i),
      labelOf: (i) => JourneyAnnouncer.stepRow(steps, i),
    );
    if (index == null || !context.mounted) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => JourneyStepMenu(editor: editor, index: index),
      ),
    );
  }

  Future<void> _add(BuildContext context) async {
    final journey = editor.journey;
    final position = journey.steps.length;
    // Back from a step's first screen returns here, not to the journey.
    while (true) {
      if (!context.mounted) return;
      final t = Speech.t;
      final kind = await JourneyPrompts.pick(
        context,
        title: t.journeyAddStepTitle('${position + 1}'),
        introduction: t.journeyAddStepIntro,
        choices: [
          t.journeyChoiceRecording,
          t.journeyChoiceNarration,
          t.journeyChoiceQuestion,
          t.journeyChoicePoll,
        ],
      );
      if (kind == null) return;
      if (!context.mounted) return;
      final (:step, :back) = await _compose(context, kind, position);
      if (back) continue;
      if (step == null || !context.mounted) return;
      await editor.saveSteps([
        ...editor.journey.steps,
        step,
      ], Speech.t.journeySavedAsStep('${position + 1}', step.spokenName));
      return;
    }
  }

  /// One step of [kind]. back is true when the teacher went back from the
  /// first screen, so the previous menu opens again.
  Future<({JourneyStep? step, bool back})> _compose(
    BuildContext context,
    int kind,
    int position,
  ) async {
    final journey = editor.journey;
    ({JourneyStep? step, bool back}) outcome(JourneyStep? step) => (
      step: step,
      back: step == null && !JourneyStepComposer.takeExplained(),
    );
    JourneyStepComposer.takeExplained();
    switch (kind) {
      case 0:
        return outcome(
          await JourneyStepComposer.recording(
            context,
            api: editor.api,
            classId: journey.classId,
            subjectId: journey.subjectId,
          ),
        );
      case 1:
        return outcome(await JourneyStepComposer.narration(context));
      case 2:
        while (true) {
          if (!context.mounted) return (step: null, back: false);
          final source = await JourneyPrompts.pick(
            context,
            title: Speech.t.journeyAddQuestion,
            choices: [
              Speech.t.journeyWriteNewQuestion,
              Speech.t.journeyChooseFromBank,
            ],
          );
          if (source == null) return (step: null, back: true);
          if (!context.mounted) return (step: null, back: false);
          final JourneyStep? step;
          if (source == 0) {
            step = await JourneyStepComposer.question(
              context,
              steps: journey.steps,
              position: position,
            );
          } else {
            step = await JourneyStepComposer.fromBank(
              context,
              api: editor.api,
              classId: journey.classId,
              subjectId: journey.subjectId,
              steps: journey.steps,
              position: position,
            );
          }
          final result = outcome(step);
          if (!result.back) return result;
        }
      default:
        return outcome(await JourneyStepComposer.poll(context));
    }
  }

  Future<void> _preview(BuildContext context) async {
    try {
      final preview = await editor.api.preview(editor.journey.journeyId);
      if (!context.mounted) return;
      if (preview.issues.isNotEmpty) {
        MessageCenter.show(JourneyAnnouncer.previewSkips(preview.issues));
      }
      await Navigator.of(context).push<void>(
        MaterialPageRoute(
          builder: (_) => JourneyPlayerScreen(
            snapshot: preview.snapshot,
            preview: true,
            api: editor.api,
          ),
        ),
      );
    } on JourneyApiException catch (error) {
      MessageCenter.error(error.message);
    }
  }

  void _open(BuildContext context, Widget screen) => unawaited(
    Navigator.of(context).push<void>(MaterialPageRoute(builder: (_) => screen)),
  );

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: editor,
    builder: (context, _) {
      final t = Speech.t;
      final journey = editor.journey;
      final empty = journey.steps.isEmpty;
      final canPublish = journey.isDraft || journey.hasUnpublishedChanges;
      return JourneyMenu(
        title: journey.title,
        introduction: _summary(journey),
        status: editor.status,
        issue: editor.issue,
        busy: editor.busy,
        details: _summary(journey),
        choices: [
          JourneyChoice(
            t.journeyHearAndEdit,
            () => unawaited(_steps(context)),
            enabled: !empty,
            unavailableReason: t.journeyNoStepsYet,
          ),
          JourneyChoice(t.journeyAddStep, () => unawaited(_add(context))),
          JourneyChoice(
            t.journeyPreviewAsStudent,
            () => unawaited(_preview(context)),
            enabled: !empty,
            unavailableReason: t.journeyAddStepFirst,
          ),
          canPublish
              ? JourneyChoice(
                  journey.isDraft
                      ? t.journeyPublishToStudents
                      : t.journeyPublishChanges,
                  () => _open(context, JourneyPublishScreen(editor: editor)),
                  enabled: !empty,
                  unavailableReason: t.journeyAddStepFirst,
                )
              : JourneyChoice(
                  t.journeyStudentResults,
                  () => _open(
                    context,
                    JourneyResultsScreen(journey: journey, api: editor.api),
                  ),
                ),
          JourneyChoice(
            t.journeyMoreOptions,
            () => _open(context, JourneyMoreOptionsScreen(editor: editor)),
          ),
        ],
      );
    },
  );
}

/// Actions on one selected step.
class JourneyStepMenu extends StatefulWidget {
  const JourneyStepMenu({super.key, required this.editor, required this.index});
  final JourneyEditor editor;
  final int index;

  @override
  State<JourneyStepMenu> createState() => _JourneyStepMenuState();
}

class _JourneyStepMenuState extends State<JourneyStepMenu> {
  late int _index = widget.index;

  JourneyEditor get _editor => widget.editor;
  List<JourneyStep> get _steps => _editor.journey.steps;

  Future<void> _edit() async {
    final step = _steps[_index];
    final journey = _editor.journey;
    JourneyStepComposer.takeExplained();
    final pending = switch (step.kind) {
      JourneyStepKind.audio => JourneyStepComposer.recording(
        context,
        api: _editor.api,
        classId: journey.classId,
        subjectId: journey.subjectId,
      ),
      JourneyStepKind.narration => JourneyStepComposer.narration(
        context,
        initial: step,
      ),
      JourneyStepKind.question => JourneyStepComposer.question(
        context,
        steps: _steps,
        position: _index,
        initial: step,
      ),
      JourneyStepKind.poll => JourneyStepComposer.poll(context, initial: step),
    };
    final edited = await pending;
    if (edited == null) {
      if (!JourneyStepComposer.takeExplained()) {
        MessageCenter.show(CommonText.nothingChanged);
      }
      return;
    }
    await _editor.saveSteps(
      JourneySteps.replace(_steps, _index, edited),
      Speech.t.journeyStepSaved('${_index + 1}'),
    );
  }

  Future<void> _move(int direction) async {
    final target = _index + direction;
    if (target < 0 || target >= _steps.length) return;
    final saved = await _editor.saveSteps(
      JourneySteps.move(_steps, _index, target),
      Speech.t.journeyMoved('${target + 1}', '${_steps.length}'),
    );
    if (saved && mounted) setState(() => _index = target);
  }

  Future<void> _remove() async {
    final step = _steps[_index];
    final confirmed = await JourneyPrompts.confirm(
      context,
      title: Speech.t.journeyRemoveStepTitle('${_index + 1}'),
      message: Speech.t.journeyRemoveStepMessage(step.spokenName),
      confirmLabel: Speech.t.journeyRemoveStep,
    );
    if (!confirmed) return;
    final before = _steps;
    final saved = await _editor.saveSteps(
      JourneySteps.remove(_steps, _index),
      JourneyAnnouncer.stepRemoved(_steps.length - 1),
    );
    if (!saved) return;
    await UndoService.offer(
      done: JourneyAnnouncer.stepRemovedUndo(step),
      undo: () async {
        if (!await _editor.saveSteps(before, JourneyAnnouncer.stepRestored)) {
          throw StateError('Step could not be restored');
        }
      },
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _editor,
    builder: (context, _) {
      final t = Speech.t;
      if (_index >= _steps.length) {
        return JourneyMenu(
          title: t.journeyStepNotFound,
          introduction: t.journeyStepWasRemoved,
          choices: const [],
        );
      }
      final details = JourneyAnnouncer.stepDetails(_steps[_index]);
      return JourneyMenu(
        title: t.journeyStepPosition('${_index + 1}', '${_steps.length}'),
        introduction: _steps[_index].spokenName,
        status: _editor.status,
        issue: _editor.issue,
        busy: _editor.busy,
        details: details,
        choices: [
          JourneyChoice(
            t.journeyHearStepInFull,
            () => unawaited(TtsService.speak(details)),
          ),
          JourneyChoice(t.journeyEditStep, () => unawaited(_edit())),
          JourneyChoice(
            t.journeyMoveEarlier,
            () => unawaited(_move(-1)),
            enabled: _index > 0,
            unavailableReason: t.journeyAlreadyFirst,
          ),
          JourneyChoice(
            t.journeyMoveLater,
            () => unawaited(_move(1)),
            enabled: _index < _steps.length - 1,
            unavailableReason: t.journeyAlreadyLast,
          ),
          JourneyChoice(t.journeyRemoveThisStep, () => unawaited(_remove())),
        ],
      );
    },
  );
}

/// Results, rename, grading, duplicate and archive or delete.
class JourneyMoreOptionsScreen extends StatelessWidget {
  const JourneyMoreOptionsScreen({super.key, required this.editor});
  final JourneyEditor editor;

  Future<void> _rename(BuildContext context) async {
    final title = await JourneyPrompts.askText(
      context,
      title: Speech.t.journeyRenameTitle,
      label: Speech.t.journeyNameLabel,
      initial: editor.journey.title,
      max: 160,
    );
    if (title == null) return;
    await editor.run(
      Speech.t.journeyRenamed(title),
      () => editor.api.update(editor.journey, title: title),
    );
  }

  Future<void> _duplicate(BuildContext context) async {
    try {
      final copy = await editor.api.duplicate(editor.journey.journeyId);
      MessageCenter.success(JourneyAnnouncer.duplicated(copy.title));
    } on JourneyApiException catch (error) {
      MessageCenter.error(error.message);
    }
  }

  Future<void> _archiveOrDelete(BuildContext context) async {
    final journey = editor.journey;
    if (journey.isPublished || journey.isArchived) {
      final archive = journey.isPublished;
      final confirmed = await JourneyPrompts.confirm(
        context,
        title: archive
            ? Speech.t.journeyArchiveTitle
            : Speech.t.journeyRestoreTitle,
        message: JourneyAnnouncer.archiveMessage(
          journey.title,
          archive: archive,
        ),
        confirmLabel: archive
            ? Speech.t.journeyArchive
            : Speech.t.journeyRestore,
      );
      if (!confirmed) return;
      await editor.run(
        archive ? JourneyAnnouncer.archived : JourneyAnnouncer.restored,
        () => editor.api.setArchived(journey, archive),
      );
      return;
    }
    final confirmed = await JourneyPrompts.confirm(
      context,
      title: Speech.t.journeyDeleteDraftTitle,
      message: JourneyAnnouncer.deleteDraftMessage(journey.title),
      confirmLabel: Speech.t.journeyDeleteDraft,
    );
    if (!confirmed || !context.mounted) return;
    try {
      await editor.api.delete(journey);
      MessageCenter.success(JourneyAnnouncer.draftDeleted);
      if (context.mounted) {
        Navigator.of(context)
          ..pop()
          ..pop();
      }
    } on JourneyApiException catch (error) {
      MessageCenter.error(error.message);
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: editor,
    builder: (context, _) {
      final t = Speech.t;
      final journey = editor.journey;
      return JourneyMenu(
        title: t.journeyMoreOptions,
        introduction: journey.title,
        status: editor.status,
        issue: editor.issue,
        busy: editor.busy,
        choices: [
          JourneyChoice(
            t.journeyStudentResults,
            () => unawaited(
              Navigator.of(context).push<void>(
                MaterialPageRoute(
                  builder: (_) =>
                      JourneyResultsScreen(journey: journey, api: editor.api),
                ),
              ),
            ),
            enabled: journey.publishedRevision != null,
            unavailableReason: t.journeyPublishFirst,
          ),
          JourneyChoice(t.journeyRename, () => unawaited(_rename(context))),
          JourneyChoice(
            journey.graded
                ? t.journeyGradingNowGraded
                : t.journeyGradingNowNotGraded,
            () => unawaited(
              Navigator.of(context).push<void>(
                MaterialPageRoute(
                  builder: (_) => JourneyGradingScreen(editor: editor),
                ),
              ),
            ),
          ),
          JourneyChoice(
            t.journeyDuplicate,
            () => unawaited(_duplicate(context)),
          ),
          JourneyChoice(
            journey.isPublished
                ? t.journeyArchiveHide
                : journey.isArchived
                ? t.journeyRestoreForStudents
                : t.journeyDeleteThisDraft,
            () => unawaited(_archiveOrDelete(context)),
          ),
        ],
      );
    },
  );
}

class JourneyGradingScreen extends StatelessWidget {
  const JourneyGradingScreen({super.key, required this.editor});
  final JourneyEditor editor;

  Future<void> _retries(int delta) async {
    final next = editor.journey.maxRetries + delta;
    if (next < 0 || next > 5) {
      MessageCenter.show(
        next < 0 ? JourneyAnnouncer.noRetriesLeft : JourneyAnnouncer.maxRetries,
      );
      return;
    }
    await editor.run(
      Speech.t.journeyRetriesPerQuestion(next),
      () => editor.api.update(editor.journey, maxRetries: next),
    );
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: editor,
    builder: (context, _) {
      final t = Speech.t;
      final journey = editor.journey;
      final summary = [
        journey.graded ? t.journeyGradedSummary : t.journeyNotGradedSummary,
        t.journeyMoreTriesSummary(journey.maxRetries),
      ].join(' ');
      return JourneyMenu(
        title: t.journeyGradingTitle,
        introduction: summary,
        details: summary,
        status: editor.status,
        issue: editor.issue,
        busy: editor.busy,
        choices: [
          JourneyChoice(
            journey.graded ? t.journeyTurnGradingOff : t.journeyTurnGradingOn,
            () => unawaited(
              editor.run(
                journey.graded ? t.journeyGradingIsOff : t.journeyGradingIsOn,
                () => editor.api.update(journey, graded: !journey.graded),
              ),
            ),
          ),
          JourneyChoice(t.journeyFewerTries, () => unawaited(_retries(-1))),
          JourneyChoice(t.journeyMoreTries, () => unawaited(_retries(1))),
        ],
      );
    },
  );
}

/// Reads a full summary with any problems before the teacher confirms.
class JourneyPublishScreen extends StatefulWidget {
  const JourneyPublishScreen({super.key, required this.editor});
  final JourneyEditor editor;

  @override
  State<JourneyPublishScreen> createState() => _JourneyPublishScreenState();
}

class _JourneyPublishScreenState extends State<JourneyPublishScreen> {
  JourneyPreview? _preview;
  String? _issue;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    try {
      _preview = await widget.editor.api.preview(
        widget.editor.journey.journeyId,
      );
    } on JourneyApiException catch (error) {
      _issue = error.message;
    }
    if (!mounted) return;
    setState(() => _loading = false);
    unawaited(
      TtsService.speak(
        '${_summary()} ${JourneyMenu.spokenKeys(_choices(), Speech.t.uiBack)}',
      ),
    );
  }

  String _summary() {
    final t = Speech.t;
    final preview = _preview;
    if (preview == null) return _issue ?? t.journeyLoadingSummary;
    final journey = widget.editor.journey;
    final steps = preview.snapshot.steps;
    String count(JourneyStepKind kind) =>
        '${steps.where((s) => s.kind == kind).length}';
    return [
      t.journeyPublishSummary(
        journey.title,
        '${steps.length}',
        count(JourneyStepKind.audio),
        count(JourneyStepKind.narration),
        count(JourneyStepKind.question),
        count(JourneyStepKind.poll),
        journey.graded ? t.journeyGraded : t.journeyNotGraded,
      ),
      preview.issues.isEmpty
          ? t.journeyNoProblems
          : t.journeyProblems(preview.issues.join(' ')),
      if (preview.warnings.isNotEmpty)
        t.journeyThingsToCheck(preview.warnings.join(' ')),
    ].join(' ');
  }

  Future<void> _publish() async {
    final t = Speech.t;
    final journey = widget.editor.journey;
    final confirmed = await JourneyPrompts.confirm(
      context,
      title: t.journeyPublishTitle(journey.title),
      message: t.journeyPublishMessage,
      confirmLabel: t.journeyPublishNow,
    );
    if (!confirmed) return;
    var delivered = 0;
    final saved = await widget.editor.run(t.journeyPublishedShort, () async {
      final (published, sent) = await widget.editor.api.publish(journey);
      delivered = sent;
      return published;
    });
    if (saved && mounted) {
      MessageCenter.success(JourneyAnnouncer.published(delivered));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.editor,
    builder: (context, _) {
      final t = Speech.t;
      return JourneyMenu(
        title: t.journeyReviewBeforePublishing,
        introduction: _summary(),
        details: _summary(),
        autoPlay: false,
        issue: widget.editor.issue ?? _issue,
        busy: _loading || widget.editor.busy,
        choices: _choices(),
      );
    },
  );

  List<JourneyChoice> _choices() {
    final t = Speech.t;
    final ready = _preview != null && _preview!.issues.isEmpty;
    return [
      JourneyChoice(
        t.journeyPublishNow,
        () => unawaited(_publish()),
        enabled: ready,
        unavailableReason: t.journeyFixProblemsFirst,
      ),
      JourneyChoice(
        t.journeyPreviewFirst,
        () => unawaited(
          Navigator.of(context).push<void>(
            MaterialPageRoute(
              builder: (_) => JourneyPlayerScreen(
                snapshot: _preview!.snapshot,
                preview: true,
                api: widget.editor.api,
              ),
            ),
          ),
        ),
        enabled: _preview != null,
      ),
    ];
  }
}
