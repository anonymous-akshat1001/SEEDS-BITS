import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_service.dart';
import '../services/tts_service.dart';
import '../widgets/key_instruction_wrapper.dart';
import '../widgets/keypad_confirmation_dialog.dart';
import '../widgets/keypad_paged_list.dart';
import 'audio_library_screen.dart';

enum LessonStepKind { audio, prompt, check }

enum _LessonPage { plans, steps, add, planActions, stepActions }

class LessonSequenceStep {
  const LessonSequenceStep(this.kind, this.text, {this.audioId});
  final LessonStepKind kind;
  final String text;
  final int? audioId;
  factory LessonSequenceStep.parse(Object? value) {
    if (value is! Map<String, dynamic> ||
        value['text'] is! String ||
        (value['text'] as String).trim().isEmpty) {
      throw const FormatException('Unreadable lesson step');
    }
    final kind = LessonStepKind.values
        .where((kind) => kind.name == value['kind'])
        .firstOrNull;
    final audio = value['audio_id'];
    if (kind == null ||
        (kind == LessonStepKind.audio
            ? audio is! int || audio <= 0
            : audio != null)) {
      throw const FormatException('Invalid lesson step kind or recording');
    }
    return LessonSequenceStep(
      kind,
      value['text'] as String,
      audioId: audio as int?,
    );
  }
  Map<String, dynamic> toJson() => {
    'kind': kind.name,
    'text': text,
    'audio_id': audioId,
  };
}

class _Plan {
  const _Plan(
    this.id,
    this.owner,
    this.classId,
    this.subjectId,
    this.revision,
    this.title,
    this.steps,
  );
  final int id, owner, classId, subjectId, revision;
  final String title;
  final List<LessonSequenceStep> steps;
  factory _Plan.parse(Object? value) {
    if (value is! Map<String, dynamic> ||
        [
          'sequence_id',
          'owner_teacher_id',
          'class_id',
          'subject_id',
          'revision',
        ].any((key) => value[key] is! int || (value[key] as int) <= 0) ||
        value['title'] is! String ||
        (value['title'] as String).trim().isEmpty ||
        value['steps'] is! List) {
      throw const FormatException('Unreadable lesson sequence');
    }
    return _Plan(
      value['sequence_id'] as int,
      value['owner_teacher_id'] as int,
      value['class_id'] as int,
      value['subject_id'] as int,
      value['revision'] as int,
      value['title'] as String,
      (value['steps'] as List).map(LessonSequenceStep.parse).toList(),
    );
  }
}

class LessonSequencesScreen extends StatefulWidget {
  const LessonSequencesScreen({
    super.key,
    this.classId,
    this.subjectId,
    this.sessionId,
    this.execute,
  });
  final int? classId, subjectId, sessionId;
  final Future<void> Function(LessonSequenceStep step)? execute;
  @override
  State<LessonSequencesScreen> createState() => _LessonSequencesScreenState();
}

class _LessonSequencesScreenState extends State<LessonSequencesScreen> {
  final _nodes = <String, FocusNode>{};
  List<_Plan> _plans = [];
  _Plan? _plan;
  int _position = 0;
  int? _account, _classId, _subjectId;
  String? _token;
  bool _workspaceReady = false;
  SharedPreferences? _preferences;
  bool _busy = false;
  _LessonPage _page = _LessonPage.plans;
  String? _issue;
  String _status =
      'Select a plan and a step. Selection never runs a classroom action.';
  FocusNode _node(String id) =>
      _nodes.putIfAbsent(id, () => FocusNode(debugLabel: 'sequence-$id'));
  LessonSequenceStep? get _selected =>
      _plan == null || _plan!.steps.isEmpty ? null : _plan!.steps[_position];
  bool get _sameAccount =>
      mounted &&
      _account != null &&
      _token != null &&
      _preferences?.getString('token') == _token &&
      _preferences?.getInt('user_id') == _account &&
      _preferences?.getString('role') == 'teacher';
  @override
  void initState() {
    super.initState();
    unawaited(_run(_load));
  }

  @override
  void dispose() {
    for (final node in _nodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  void _error(String message) {
    if (!mounted) return;
    setState(() => _issue = message);
    unawaited(TtsService.speak(message, priority: SpeechPriority.critical));
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _issue = null;
    });
    try {
      await action();
    } on Exception catch (error) {
      debugPrint('[SEQUENCE] Action failed (${error.runtimeType}).');
      _error(
        error is FormatException
            ? error.message
            : error is _PlanException
            ? error.message
            : 'The lesson-plan action was not confirmed. Refresh before retrying. No automatic classroom action or advancement occurs.',
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _load() async {
    _preferences ??= await SharedPreferences.getInstance();
    _account ??= _preferences!.getInt('user_id');
    _token ??= _preferences!.getString('token');
    _workspaceReady = false;
    if (!_sameAccount) {
      throw const _PlanException(
        'Sign in with the original teacher account and reopen lesson sequences.',
      );
    }
    final query = widget.sessionId != null
        ? 'session_id=${widget.sessionId}'
        : 'class_id=${widget.classId}&subject_id=${widget.subjectId}';
    final result = await ApiService.getResult(
      '/teacher-sequences?$query',
      useAuth: true,
    ).timeout(const Duration(seconds: 10));
    if (!result.isSuccess) {
      throw _PlanException(
        result.failure?.statusCode == 404
            ? 'Lesson plans are unavailable on this server or workspace. Ask the school administrator to verify the teacher-sequences backend routes and deploy the current backend and migrations. No plan was created. Refresh after the server is updated.'
            : result.failure!.message,
      );
    }
    if (!_sameAccount) {
      throw const _PlanException(
        'Your account changed. Reopen lesson sequences.',
      );
    }
    final data = result.data;
    if (data is! Map<String, dynamic> ||
        data['plans'] is! List ||
        data['class_id'] is! int ||
        data['subject_id'] is! int) {
      throw const FormatException('The lesson-plan list could not be read.');
    }
    final plans = (data['plans'] as List).map(_Plan.parse).toList();
    _classId = data['class_id'] as int;
    _subjectId = data['subject_id'] as int;
    if (plans.any(
          (plan) =>
              plan.owner != _account ||
              plan.classId != _classId ||
              plan.subjectId != _subjectId,
        ) ||
        plans.map((plan) => plan.id).toSet().length != plans.length) {
      throw const FormatException(
        'The lesson-plan identity did not match this workspace.',
      );
    }
    if (widget.sessionId == null &&
        (_classId != widget.classId || _subjectId != widget.subjectId)) {
      throw const FormatException(
        'The returned lesson workspace did not match.',
      );
    }
    final previous = _plan;
    final next = plans.where((plan) => plan.id == previous?.id).firstOrNull;
    if (next?.revision != previous?.revision) {
      _position = 0;
      _status =
          'The plan changed or was removed. Select the intended step again before running.';
    }
    if (mounted) {
      setState(() {
        _plans = plans;
        _plan = next;
        if (next == null) _page = _LessonPage.plans;
        _workspaceReady = true;
      });
    }
  }

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body,
  ) async {
    final result = await ApiService.postAcknowledged(
      path,
      body,
      canSend: () => _sameAccount,
    );
    if (!result.isSuccess) {
      if (result.failure?.statusCode == 409) {
        throw const _PlanException(
          'The plan or recording changed or is unavailable. Refresh and select the intended step before retrying. No classroom step was run.',
        );
      }
      throw _PlanException(result.failure!.message);
    }
    if (!_sameAccount) {
      throw const _PlanException(
        'Your account changed. The action cannot be confirmed here.',
      );
    }
    return result.data!;
  }

  Future<String?> _text(String title, String initial, {int max = 160}) =>
      showDialog<String>(
        context: context,
        builder: (_) =>
            _SequenceTextDialog(title: title, initial: initial, maximum: max),
      );
  Future<bool> _confirm(String title, String message, String label) async =>
      await showDialog<bool>(
        context: context,
        builder: (_) => KeypadConfirmationDialog(
          title: title,
          message: message,
          confirmLabel: label,
        ),
      ) ==
      true;
  void _install(Object? data, {int? expectedId, int? previousRevision}) {
    final next = _Plan.parse(data);
    if (next.owner != _account ||
        next.classId != _classId ||
        next.subjectId != _subjectId ||
        (expectedId != null && next.id != expectedId) ||
        (previousRevision != null && next.revision != previousRevision + 1)) {
      throw const FormatException(
        'The saved plan identity or revision did not match. Refresh before retrying.',
      );
    }
    if (!mounted) return;
    setState(() {
      _plans = [..._plans.where((plan) => plan.id != next.id), next];
      _plan = next;
      _page = _LessonPage.steps;
      _position = next.steps.isEmpty
          ? 0
          : _position.clamp(0, next.steps.length - 1);
      _status = 'Plan saved on the server. No classroom action was run.';
    });
  }

  Future<void> _create() => _run(() async {
    if (!_workspaceReady || _classId == null || _subjectId == null) {
      throw const _PlanException(
        'Load the lesson-plan workspace successfully before creating a plan. Press Refresh plans. No plan was created.',
      );
    }
    final name = await _text('Name reusable lesson plan', '');
    if (name == null || !_sameAccount) return;
    final result = await _post('/teacher-sequences', {
      'title': name,
      'class_id': _classId,
      'subject_id': _subjectId,
      'steps': [],
    });
    _position = 0;
    _install(result['plan']);
  });
  Future<void> _save(List<LessonSequenceStep> steps, {String? title}) async {
    final plan = _plan!;
    final result = await _post('/teacher-sequences/${plan.id}/update', {
      'title': title ?? plan.title,
      'revision': plan.revision,
      'steps': steps.map((step) => step.toJson()).toList(),
    });
    _install(
      result['plan'],
      expectedId: plan.id,
      previousRevision: plan.revision,
    );
  }

  Future<void> _add(LessonStepKind kind) => _run(() async {
    final plan = _plan!;
    LessonSequenceStep? step;
    if (kind == LessonStepKind.audio) {
      final result = await ApiService.getResult(
        '/audio/list',
        useAuth: true,
      ).timeout(const Duration(seconds: 10));
      if (!result.isSuccess) throw _PlanException(result.failure!.message);
      if (!_sameAccount || !mounted) return;
      if (result.data is! List) {
        throw const FormatException('The recording list could not be read.');
      }
      final audio = (result.data as List)
          .whereType<Map<String, dynamic>>()
          .where(
            (audio) =>
                audio['class_id'] == _classId &&
                audio['subject_id'] == _subjectId &&
                audio['audio_id'] is int &&
                audio['title'] is String,
          )
          .toList();
      if (audio.isEmpty) {
        throw const _PlanException(
          'No authorized recordings were found for this class and subject.',
        );
      }
      final recording = await _choose<Map<String, dynamic>>(
        'Choose an authorized recording. Selection adds a step, never broadcasts',
        audio,
        (recording) => recording['title'] as String,
      );
      if (recording == null) return;
      step = LessonSequenceStep(
        kind,
        recording['title'] as String,
        audioId: recording['audio_id'] as int,
      );
    } else {
      final text = await _text(
        kind == LessonStepKind.check
            ? 'Teacher prompt for understanding check'
            : 'Teacher instruction prompt',
        '',
        max: 4000,
      );
      if (text == null) return;
      step = LessonSequenceStep(kind, text);
    }
    if (!_sameAccount || !identical(_plan, plan)) return;
    await _save([...plan.steps, step]);
    if (mounted) setState(() => _position = _plan!.steps.length - 1);
  });
  Future<void> _rename() => _run(() async {
    final plan = _plan!;
    final name = await _text('Rename lesson plan', plan.title);
    if (name != null) await _save(plan.steps, title: name);
  });
  Future<void> _edit() => _run(() async {
    final step = _selected!;
    if (step.kind == LessonStepKind.audio) {
      throw const _PlanException(
        'To replace a recording, remove this selected step and add the intended recording.',
      );
    }
    final text = await _text(
      'Edit selected teacher prompt',
      step.text,
      max: 4000,
    );
    if (text == null) return;
    final steps = [..._plan!.steps];
    steps[_position] = LessonSequenceStep(step.kind, text);
    await _save(steps);
  });
  Future<void> _move(int direction) => _run(() async {
    final next = _position + direction;
    if (next < 0 || next >= _plan!.steps.length) return;
    final steps = [..._plan!.steps];
    final step = steps.removeAt(_position);
    steps.insert(next, step);
    await _save(steps);
    if (mounted) setState(() => _position = next);
  });
  Future<void> _removeStep() => _run(() async {
    if (!await _confirm(
      'Remove selected step?',
      'Remove only step ${_position + 1}: ${_selected!.text}? The recording itself and classroom state are not deleted.',
      'Remove selected step',
    )) {
      return;
    }
    final steps = [..._plan!.steps]..removeAt(_position);
    await _save(steps);
  });
  Future<void> _removePlan() => _run(() async {
    final plan = _plan!;
    if (!await _confirm(
      'Remove this private lesson plan?',
      'Remove ${plan.title} only? Recordings, other plans and classroom state remain.',
      'Remove selected plan',
    )) {
      return;
    }
    await _post(
      '/teacher-sequences/${plan.id}/remove?revision=${plan.revision}',
      {},
    );
    if (mounted) {
      setState(() {
        _plans = _plans.where((item) => item.id != plan.id).toList();
        _plan = null;
        _page = _LessonPage.plans;
        _position = 0;
        _status = 'Selected plan removed. No classroom action was run.';
      });
    }
  });
  Future<void> _execute() => _run(() async {
    final plan = _plan!;
    final position = _position;
    final step = _selected!;
    final scope = widget.sessionId != null
        ? step.kind == LessonStepKind.audio
              ? 'Select this recording for the class, then separately choose whether to play it. This is not a private preview.'
              : step.kind == LessonStepKind.check
              ? 'Read the teacher prompt on this phone and open the classroom check controls. Opening a fresh check requires its own confirmation and clears previous responses.'
              : 'Read this teacher prompt on this phone; do not send it as a classroom message.'
        : step.kind == LessonStepKind.audio
        ? 'Open private lesson playback on this phone. No classroom broadcast.'
        : step.kind == LessonStepKind.check
        ? 'Read this teacher prompt on this phone only. Join your live session to collect an understanding check.'
        : 'Read this teacher prompt on this phone only.';
    if (!await _confirm(
      'Run selected step?',
      'Step ${position + 1}: ${step.text}. $scope No automatic next step, microphone activation or recording.',
      'Run only this step',
    )) {
      return;
    }
    final suffix = widget.sessionId == null
        ? ''
        : '&session_id=${widget.sessionId}';
    final result = await _post(
      '/teacher-sequences/${plan.id}/steps/$position/prepare?revision=${plan.revision}$suffix',
      {},
    );
    if (result['sequence_id'] != plan.id ||
        result['revision'] != plan.revision ||
        result['position'] != position) {
      throw const FormatException(
        'The prepared step did not match the selection. No action was run.',
      );
    }
    final prepared = LessonSequenceStep.parse(result['step']);
    if (prepared.kind != step.kind ||
        prepared.audioId != step.audioId ||
        (step.kind != LessonStepKind.audio && prepared.text != step.text)) {
      throw const FormatException(
        'The prepared lesson content changed. Refresh before running.',
      );
    }
    if (!mounted || !_sameAccount) return;
    if (widget.execute != null) {
      await widget.execute!(prepared);
    } else if (prepared.kind == LessonStepKind.audio) {
      await Navigator.push<void>(
        context,
        MaterialPageRoute(
          builder: (_) => ClassAudioScreen(
            sessionId: 0,
            sessionTitle: 'Private sequence recording',
            initialAudioId: prepared.audioId,
          ),
        ),
      );
    } else {
      await TtsService.speak(prepared.text, priority: SpeechPriority.requested);
    }
    if (mounted) {
      setState(
        () => _status =
            'Selected step requested. Verify the playback or check controls. No automatic advancement.',
      );
    }
  });
  Future<T?> _choose<T>(
    String title,
    List<T> items,
    String Function(T) label,
  ) => Navigator.push<T>(
    context,
    MaterialPageRoute(
      builder: (listContext) => KeypadPagedList<T>(
        title: title,
        scope: items,
        labelOf: label,
        onSelected: (item) => Navigator.pop(listContext, item),
        loadPage: (query) async {
          final matches = items
              .where(
                (item) => label(
                  item,
                ).toLowerCase().contains(query.search.toLowerCase()),
              )
              .toList();
          final start = int.parse(query.cursor ?? '0');
          final end = (start + KeypadListQuery.pageSize).clamp(
            0,
            matches.length,
          );
          return KeypadListPage(
            items: matches.sublist(start, end),
            nextCursor: end < matches.length ? '$end' : null,
          );
        },
      ),
    ),
  );

  Future<void> _choosePlan() async {
    final plan = await _choose<_Plan>(
      'Choose a saved lesson plan',
      _plans,
      (plan) =>
          '${plan.title}. ${plan.steps.length} steps. Select without running',
    );
    if (plan == null || !_sameAccount) return;
    setState(() {
      _plan = plan;
      _position = 0;
      _page = _LessonPage.steps;
      _status = 'Plan selected, not run.';
    });
  }

  Future<void> _chooseStep() async {
    final plan = _plan!;
    final index = await _choose<int>(
      'Choose a lesson step. Selection does not run it',
      List.generate(plan.steps.length, (index) => index),
      (index) =>
          'Step ${index + 1}. ${plan.steps[index].kind.name}. ${plan.steps[index].text}',
    );
    if (index == null || !_sameAccount || !identical(plan, _plan)) return;
    setState(() {
      _position = index;
      _status = 'Selected step ${index + 1}. Not run.';
    });
  }

  void _back() {
    if (_busy) {
      unawaited(TtsService.speak('Wait for the lesson-plan action to finish.'));
      return;
    }
    if (_page == _LessonPage.plans) {
      Navigator.pop(context);
    } else {
      setState(() {
        _page = _page == _LessonPage.steps
            ? _LessonPage.plans
            : _LessonPage.steps;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final step = _selected;
    void page(_LessonPage value) => setState(() => _page = value);
    final ready = !_busy && _workspaceReady;
    final controls = <(String, String, VoidCallback, bool)>[
      ...switch (_page) {
        _LessonPage.plans => [
          ('create', 'Create lesson plan', _create, ready),
          (
            'choose-plan',
            'Choose saved lesson plan',
            _choosePlan,
            ready && _plans.isNotEmpty,
          ),
          ('refresh', 'Refresh plans', () => _run(_load), !_busy),
        ],
        _LessonPage.steps => [
          ('add', 'Add a step', () => page(_LessonPage.add), ready),
          (
            'choose-step',
            'Choose a step. Selection only',
            _chooseStep,
            ready && step != null,
          ),
          (
            'run',
            'Run selected step with confirmation',
            _execute,
            ready && step != null,
          ),
          (
            'step-actions',
            'Edit or reorder selected step',
            () => page(_LessonPage.stepActions),
            ready && step != null,
          ),
          (
            'plan-actions',
            'Rename or remove this plan',
            () => page(_LessonPage.planActions),
            ready,
          ),
        ],
        _LessonPage.add => [
          (
            'add-audio',
            'Add authorized recording',
            () => _add(LessonStepKind.audio),
            ready,
          ),
          (
            'add-prompt',
            'Add teacher instruction prompt',
            () => _add(LessonStepKind.prompt),
            ready,
          ),
          (
            'add-check',
            'Add understanding check prompt',
            () => _add(LessonStepKind.check),
            ready,
          ),
        ],
        _LessonPage.planActions => [
          ('rename', 'Rename plan', _rename, ready),
          ('remove-plan', 'Remove plan with confirmation', _removePlan, ready),
        ],
        _LessonPage.stepActions => [
          (
            'edit',
            'Edit selected prompt',
            _edit,
            ready && step != null && step.kind != LessonStepKind.audio,
          ),
          (
            'earlier',
            'Move selected step earlier',
            () => _move(-1),
            ready && step != null && _position > 0,
          ),
          (
            'later',
            'Move selected step later',
            () => _move(1),
            ready && step != null && _position < _plan!.steps.length - 1,
          ),
          (
            'remove-step',
            'Remove selected step with confirmation',
            _removeStep,
            ready && step != null,
          ),
        ],
      },
    ];
    final title = switch (_page) {
      _LessonPage.plans => 'Lesson plans. Create or choose a plan',
      _LessonPage.steps => 'Lesson plan. Choose what to do next',
      _LessonPage.add => 'Add one lesson step. Choose its type',
      _LessonPage.planActions => 'Manage this lesson plan',
      _LessonPage.stepActions => 'Manage the selected lesson step',
    };
    final selected = step == null
        ? 'No steps yet. Choose Add a step to begin.'
        : 'Step ${_position + 1} of ${_plan!.steps.length}: ${step.kind.name}. ${step.text}';
    void activate(int index) {
      final control = controls[index];
      if (control.$4) {
        control.$3();
      } else {
        unawaited(
          TtsService.speak(
            '${control.$2} is unavailable. ${_issue ?? (_busy
                    ? 'Please wait.'
                    : _page == _LessonPage.plans
                    ? 'Refresh plans, or create a plan if none are saved.'
                    : selected)}',
          ),
        );
      }
    }

    void read() => unawaited(
      TtsService.speak(
        '${_issue ?? ''} $_status ${_plan == null ? '${_plans.length} saved plans.' : selected}',
      ),
    );

    return PopScope(
      canPop: _page == _LessonPage.plans && !_busy,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: KeypadInstructionWrapper(
        interactionPolicy: KeypadInteractionPolicy.numbered,
        screenName: title,
        introduction: _page == _LessonPage.plans
            ? 'Teacher-private reusable plans. ${_plans.length} saved plans.'
            : '${_plan!.title}. $selected Selection never runs a step. Run requires confirmation. No automatic next step.',
        navigationSections:
            '${controls.map((control) => control.$2).join(', ')}, read status and back',
        actions: {
          0: _back,
          for (var index = 0; index < controls.length; index++)
            index + 1: () => activate(index),
          8: read,
        },
        labels: {
          for (var index = 0; index < controls.length; index++)
            index + 1:
                '${controls[index].$2}${controls[index].$4 ? '' : ', unavailable'}',
          8: 'Read plan status',
        },
        focusTargets: [
          for (var index = 0; index < controls.length; index++)
            KeypadFocusTarget(
              node: _node(controls[index].$1),
              label:
                  '${index + 1}. ${controls[index].$2}${controls[index].$4 ? '' : ', unavailable'}',
              onActivate: () => activate(index),
            ),
          KeypadFocusTarget(
            node: _node('read'),
            label: '8. Read plan status',
            onActivate: read,
          ),
          KeypadFocusTarget(
            node: _node('back'),
            label: '0. Back without running a step',
            onActivate: _back,
          ),
        ],
        child: Scaffold(
          appBar: AppBar(title: Text(title), automaticallyImplyLeading: false),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_busy) const LinearProgressIndicator(),
                if (_issue != null)
                  Semantics(liveRegion: true, child: Text(_issue!)),
                Text(_status),
                if (_page != _LessonPage.plans) ...[
                  Text(
                    'Selected: ${_plan!.title}. Revision ${_plan!.revision}.',
                  ),
                  Text(selected),
                ],
                for (var index = 0; index < controls.length; index++)
                  OutlinedButton(
                    focusNode: _node(controls[index].$1),
                    onPressed: () => activate(index),
                    child: Text(
                      '${index + 1}. ${controls[index].$2}${controls[index].$4 ? '' : ' (unavailable)'}',
                    ),
                  ),
                TextButton(
                  focusNode: _node('read'),
                  onPressed: read,
                  child: const Text('8. Read plan status'),
                ),
                TextButton(
                  focusNode: _node('back'),
                  onPressed: _back,
                  child: const Text('0. Back'),
                ),
                const Text('*: Help. #: Stop app speech.'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlanException implements Exception {
  const _PlanException(this.message);
  final String message;
}

class _SequenceTextDialog extends StatefulWidget {
  const _SequenceTextDialog({
    required this.title,
    required this.initial,
    required this.maximum,
  });
  final String title, initial;
  final int maximum;
  @override
  State<_SequenceTextDialog> createState() => _SequenceTextDialogState();
}

class _SequenceTextDialogState extends State<_SequenceTextDialog> {
  late final _text = TextEditingController(text: widget.initial);
  final _field = FocusNode(debugLabel: 'sequence-entry-field');
  final _save = FocusNode(debugLabel: 'sequence-entry-save');
  final _cancel = FocusNode(debugLabel: 'sequence-entry-cancel');
  String? _issue;
  void save() {
    if (_text.text.trim().isEmpty) {
      setState(() => _issue = 'Enter text before saving.');
      unawaited(TtsService.speak(_issue!));
      return;
    }
    Navigator.pop(context, _text.text.trim());
  }

  @override
  void dispose() {
    _text.dispose();
    _field.dispose();
    _save.dispose();
    _cancel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => KeypadInstructionWrapper(
    interactionPolicy: KeypadInteractionPolicy.numbered,
    screenName: widget.title,
    introduction:
        'Use D-pad down to reach the text field. Enter the text, then press OK to leave editing. '
        'Outside the field, press 1 to save or 0 to cancel without saving.',
    navigationSections: 'the text field, save text and cancel',
    labels: const {1: 'Save text', 2: 'Cancel without saving'},
    actions: {
      0: () => Navigator.pop(context),
      1: save,
      2: () => Navigator.pop(context),
    },
    focusTargets: [
      KeypadFocusTarget(node: _field, label: widget.title, isTextField: true),
      KeypadFocusTarget(
        node: _save,
        label: 'Save entered text',
        onActivate: save,
      ),
      KeypadFocusTarget(
        node: _cancel,
        label: 'Cancel without saving',
        onActivate: () => Navigator.pop(context),
      ),
    ],
    child: AlertDialog(
      scrollable: true,
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            focusNode: _field,
            controller: _text,
            maxLength: widget.maximum,
            maxLines: null,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _save.requestFocus(),
            decoration: InputDecoration(labelText: widget.title),
          ),
          if (_issue != null) Text(_issue!),
          TextButton(
            focusNode: _save,
            onPressed: save,
            child: const Text('1. Save text'),
          ),
          TextButton(
            focusNode: _cancel,
            onPressed: () => Navigator.pop(context),
            child: const Text('0. Cancel'),
          ),
        ],
      ),
    ),
  );
}
