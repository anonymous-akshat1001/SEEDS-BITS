import 'dart:async';

import 'package:flutter/material.dart';

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

  Future<bool> run(
    String done,
    Future<JourneyDraft> Function() action,
  ) async {
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
          issue = '${error.message} The latest version is now loaded.';
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
      unawaited(TtsService.speak([_issue, _status].whereType<String>().join(' ')));
    }
  }

  List<JourneyDraft> _with(bool Function(JourneyDraft) test) =>
      _journeys.where(test).toList();

  String _summary() =>
      '${_with((j) => j.isDraft).length} drafts, '
      '${_with((j) => j.isPublished).length} published, '
      '${_with((j) => j.isArchived).length} archived.';

  Future<void> _create() async {
    final title = await JourneyPrompts.askText(
      context,
      title: 'New learning journey',
      label: 'Journey name, for example: Food around us',
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
        builder: (_) => JourneyOverviewScreen(
          editor: JourneyEditor(widget.api, journey),
        ),
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
    final drafts = _with((j) => j.isDraft);
    final published = _with((j) => j.isPublished);
    final archived = _with((j) => j.isArchived);
    const loadFirst = 'Press 5 to refresh the list first.';
    return JourneyMenu(
      title: 'Learning journeys',
      introduction:
          '${widget.workspaceName}. Build one flow of recordings, narration, questions and polls for students.',
      status: _status,
      issue: _issue,
      busy: _busy,
      details: [_issue, _status].whereType<String>().join(' '),
      choices: [
        JourneyChoice(
          'Create a new journey',
          () => unawaited(_create()),
          enabled: _loaded,
          unavailableReason: loadFirst,
        ),
        JourneyChoice(
          'Drafts, ${drafts.length}',
          () => unawaited(_list('Draft journeys', drafts)),
          enabled: drafts.isNotEmpty,
          unavailableReason: 'There are no drafts.',
        ),
        JourneyChoice(
          'Published, ${published.length}',
          () => unawaited(_list('Published journeys', published)),
          enabled: published.isNotEmpty,
          unavailableReason: 'Nothing is published yet.',
        ),
        JourneyChoice(
          'Archived, ${archived.length}',
          () => unawaited(_list('Archived journeys', archived)),
          enabled: archived.isNotEmpty,
          unavailableReason: 'Nothing is archived.',
        ),
        JourneyChoice(
          'Refresh list',
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

  String _summary(JourneyDraft journey) =>
      '${journey.statusWords}. ${journey.steps.length} steps, '
      '${journey.steps.where((s) => s.kind == JourneyStepKind.question).length} questions. '
      '${journey.graded ? 'Graded' : 'Not graded'}. '
      '${journey.maxRetries} ${journey.maxRetries == 1 ? 'retry' : 'retries'} per question.';

  Future<void> _steps(BuildContext context) async {
    final steps = editor.journey.steps;
    final index = await JourneyPrompts.choose<int>(
      context,
      title: 'Steps',
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
      final kind = await JourneyPrompts.pick(
        context,
        title: 'Add step ${position + 1}',
        introduction: 'The new step goes at the end. You can move it later.',
        choices: ['Recording', 'Narration read by the phone', 'Question', 'Poll, no wrong answer'],
      );
      if (kind == null) return;
      if (!context.mounted) return;
      final (:step, :back) = await _compose(context, kind, position);
      if (back) continue;
      if (step == null || !context.mounted) return;
      await editor.saveSteps(
        [...editor.journey.steps, step],
        'Saved as step ${position + 1}. ${step.spokenName}',
      );
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
    ({JourneyStep? step, bool back}) outcome(JourneyStep? step) =>
        (step: step, back: step == null && !JourneyStepComposer.takeExplained());
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
            title: 'Add a question',
            choices: ['Write a new question', 'Choose from my question bank'],
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
            'Hear and edit steps',
            () => unawaited(_steps(context)),
            enabled: !empty,
            unavailableReason: 'There are no steps yet. Press 2 to add one.',
          ),
          JourneyChoice('Add a step', () => unawaited(_add(context))),
          JourneyChoice(
            'Preview as a student',
            () => unawaited(_preview(context)),
            enabled: !empty,
            unavailableReason: 'Add a step first.',
          ),
          canPublish
              ? JourneyChoice(
                  journey.isDraft ? 'Publish to students' : 'Publish changes',
                  () => _open(context, JourneyPublishScreen(editor: editor)),
                  enabled: !empty,
                  unavailableReason: 'Add a step first.',
                )
              : JourneyChoice(
                  'Student results',
                  () => _open(
                    context,
                    JourneyResultsScreen(journey: journey, api: editor.api),
                  ),
                ),
          JourneyChoice(
            'More options',
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
      'Step ${_index + 1} saved.',
    );
  }

  Future<void> _move(int direction) async {
    final target = _index + direction;
    if (target < 0 || target >= _steps.length) return;
    final saved = await _editor.saveSteps(
      JourneySteps.move(_steps, _index, target),
      'Moved. This is now step ${target + 1} of ${_steps.length}.',
    );
    if (saved && mounted) setState(() => _index = target);
  }

  Future<void> _remove() async {
    final step = _steps[_index];
    final confirmed = await JourneyPrompts.confirm(
      context,
      title: 'Remove step ${_index + 1}?',
      message:
          'Remove ${step.spokenName}? Recordings stay in your library. Questions that replayed this step will replay automatically instead.',
      confirmLabel: 'Remove step',
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
      if (_index >= _steps.length) {
        return JourneyMenu(
          title: 'Step not found',
          introduction: 'This step was removed. Press 0 to go back.',
          choices: const [],
        );
      }
      final details = JourneyAnnouncer.stepDetails(_steps[_index]);
      return JourneyMenu(
        title: 'Step ${_index + 1} of ${_steps.length}',
        introduction: _steps[_index].spokenName,
        status: _editor.status,
        issue: _editor.issue,
        busy: _editor.busy,
        details: details,
        choices: [
          JourneyChoice(
            'Hear this step in full',
            () => unawaited(TtsService.speak(details)),
          ),
          JourneyChoice('Edit this step', () => unawaited(_edit())),
          JourneyChoice(
            'Move earlier',
            () => unawaited(_move(-1)),
            enabled: _index > 0,
            unavailableReason: 'This is already the first step.',
          ),
          JourneyChoice(
            'Move later',
            () => unawaited(_move(1)),
            enabled: _index < _steps.length - 1,
            unavailableReason: 'This is already the last step.',
          ),
          JourneyChoice('Remove this step', () => unawaited(_remove())),
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
      title: 'Rename journey',
      label: 'Journey name',
      initial: editor.journey.title,
      max: 160,
    );
    if (title == null) return;
    await editor.run('Renamed to $title.', () => editor.api.update(editor.journey, title: title));
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
        title: archive ? 'Archive this journey?' : 'Restore this journey?',
        message: JourneyAnnouncer.archiveMessage(journey.title, archive: archive),
        confirmLabel: archive ? 'Archive' : 'Restore',
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
      title: 'Delete this draft?',
      message: JourneyAnnouncer.deleteDraftMessage(journey.title),
      confirmLabel: 'Delete draft',
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
      final journey = editor.journey;
      return JourneyMenu(
        title: 'More options',
        introduction: journey.title,
        status: editor.status,
        issue: editor.issue,
        busy: editor.busy,
        choices: [
          JourneyChoice(
            'Student results',
            () => unawaited(
              Navigator.of(context).push<void>(
                MaterialPageRoute(
                  builder: (_) =>
                      JourneyResultsScreen(journey: journey, api: editor.api),
                ),
              ),
            ),
            enabled: journey.publishedRevision != null,
            unavailableReason: 'Publish the journey first.',
          ),
          JourneyChoice('Rename', () => unawaited(_rename(context))),
          JourneyChoice(
            'Grading and tries, now ${journey.graded ? 'graded' : 'not graded'}',
            () => unawaited(
              Navigator.of(context).push<void>(
                MaterialPageRoute(
                  builder: (_) => JourneyGradingScreen(editor: editor),
                ),
              ),
            ),
          ),
          JourneyChoice('Duplicate as a new draft', () => unawaited(_duplicate(context))),
          JourneyChoice(
            journey.isPublished
                ? 'Archive, hide from students'
                : journey.isArchived
                ? 'Restore for students'
                : 'Delete this draft',
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
      MessageCenter.show(next < 0 ? JourneyAnnouncer.noRetriesLeft : JourneyAnnouncer.maxRetries);
      return;
    }
    await editor.run(
      '$next ${next == 1 ? 'retry' : 'retries'} per question.',
      () => editor.api.update(editor.journey, maxRetries: next),
    );
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: editor,
    builder: (context, _) {
      final journey = editor.journey;
      final summary =
          '${journey.graded ? 'Graded: the first try at each question counts towards a score.' : 'Not graded: questions are for practice only.'} '
          'After a wrong answer, a student gets ${journey.maxRetries} more '
          '${journey.maxRetries == 1 ? 'try' : 'tries'}, with the content replayed first.';
      return JourneyMenu(
        title: 'Grading and tries',
        introduction: summary,
        details: summary,
        status: editor.status,
        issue: editor.issue,
        busy: editor.busy,
        choices: [
          JourneyChoice(
            journey.graded ? 'Turn grading off' : 'Turn grading on',
            () => unawaited(
              editor.run(
                journey.graded ? 'Grading is off.' : 'Grading is on.',
                () => editor.api.update(journey, graded: !journey.graded),
              ),
            ),
          ),
          JourneyChoice('Fewer tries', () => unawaited(_retries(-1))),
          JourneyChoice('More tries', () => unawaited(_retries(1))),
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
      _preview = await widget.editor.api.preview(widget.editor.journey.journeyId);
    } on JourneyApiException catch (error) {
      _issue = error.message;
    }
    if (!mounted) return;
    setState(() => _loading = false);
    unawaited(TtsService.speak(_summary()));
  }

  String _summary() {
    final preview = _preview;
    if (preview == null) return _issue ?? 'Loading the summary.';
    final journey = widget.editor.journey;
    final steps = preview.snapshot.steps;
    int count(JourneyStepKind kind) => steps.where((s) => s.kind == kind).length;
    final problems = preview.issues.isEmpty
        ? 'No problems.'
        : 'Problems to fix before publishing: ${preview.issues.join(' ')}';
    final warnings = preview.warnings.isEmpty
        ? ''
        : ' Things to check: ${preview.warnings.join(' ')}';
    return '${journey.title}. ${steps.length} steps: ${count(JourneyStepKind.audio)} recordings, '
        '${count(JourneyStepKind.narration)} narrations, ${count(JourneyStepKind.question)} questions, '
        '${count(JourneyStepKind.poll)} polls. ${journey.graded ? 'Graded' : 'Not graded'}. '
        '$problems$warnings';
  }

  Future<void> _publish() async {
    final journey = widget.editor.journey;
    final confirmed = await JourneyPrompts.confirm(
      context,
      title: 'Publish ${journey.title}?',
      message:
          'All students in this class will be able to play and download it, and they will get a notification.',
      confirmLabel: 'Publish now',
    );
    if (!confirmed) return;
    var delivered = 0;
    final saved = await widget.editor.run('Published.', () async {
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
      final ready = _preview != null && _preview!.issues.isEmpty;
      return JourneyMenu(
        title: 'Review before publishing',
        introduction: _summary(),
        details: _summary(),
        autoPlay: false,
        issue: widget.editor.issue ?? _issue,
        busy: _loading || widget.editor.busy,
        choices: [
          JourneyChoice(
            'Publish now',
            () => unawaited(_publish()),
            enabled: ready,
            unavailableReason: 'Fix the problems first. Press 8 to hear them.',
          ),
          JourneyChoice(
            'Preview as a student first',
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
        ],
      );
    },
  );
}
