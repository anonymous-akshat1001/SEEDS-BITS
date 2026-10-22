import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_service.dart';
import '../services/tts_service.dart';
import '../widgets/key_instruction_wrapper.dart';
import '../widgets/keypad_confirmation_dialog.dart';
import 'audio_library_screen.dart';

enum LessonStepKind { audio, prompt, check }

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
  SharedPreferences? _preferences;
  bool _busy = false;
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
    if (!result.isSuccess) throw _PlanException(result.failure!.message);
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
      _position = next.steps.isEmpty
          ? 0
          : _position.clamp(0, next.steps.length - 1);
      _status = 'Plan saved on the server. No classroom action was run.';
    });
  }

  Future<void> _create() => _run(() async {
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
      final index = await showDialog<int>(
        context: context,
        builder: (_) => _SequenceChoiceDialog(
          labels: audio.map((audio) => audio['title'] as String).toList(),
        ),
      );
      if (index == null) return;
      step = LessonSequenceStep(
        kind,
        audio[index]['title'] as String,
        audioId: audio[index]['audio_id'] as int,
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
  @override
  Widget build(BuildContext context) {
    final step = _selected;
    void select(int offset) {
      if (_plan!.steps.isEmpty) return;
      setState(() {
        _position = (_position + offset) % _plan!.steps.length;
        _status =
            'Selected step ${_position + 1}: ${_selected!.text}. Not run.';
      });
      unawaited(TtsService.speak(_status));
    }

    final targets = <KeypadFocusTarget>[
      KeypadFocusTarget(
        node: _node('back'),
        label: 'Back. Does not run or submit anything',
        onActivate: () => Navigator.pop(context),
      ),
      KeypadFocusTarget(
        node: _node('refresh'),
        label: 'Refresh saved lesson plans',
        isEnabled: () => !_busy,
        onActivate: () => _run(_load),
      ),
      KeypadFocusTarget(
        node: _node('create'),
        label: 'Create reusable private lesson plan',
        isEnabled: () => !_busy && _classId != null,
        onActivate: _create,
      ),
      KeypadFocusTarget(
        node: _node('read'),
        label: 'Read plan status',
        onActivate: () =>
            TtsService.speak('${_issue ?? ''} $_status ${step?.text ?? ''}'),
      ),
      for (final plan in _plans)
        KeypadFocusTarget(
          node: _node('plan-${plan.id}'),
          label:
              '${plan.title}. ${plan.steps.length} steps. Select without running',
          isEnabled: () => !_busy,
          onActivate: () => setState(() {
            _plan = plan;
            _position = 0;
            _status = 'Plan selected, not run.';
          }),
        ),
      if (_plan != null) ...[
        KeypadFocusTarget(
          node: _node('rename'),
          label: 'Rename selected plan',
          isEnabled: () => !_busy,
          onActivate: _rename,
        ),
        KeypadFocusTarget(
          node: _node('add-audio'),
          label: 'Add authorized recording',
          isEnabled: () => !_busy,
          onActivate: () => _add(LessonStepKind.audio),
        ),
        KeypadFocusTarget(
          node: _node('add-prompt'),
          label: 'Add teacher instruction prompt',
          isEnabled: () => !_busy,
          onActivate: () => _add(LessonStepKind.prompt),
        ),
        KeypadFocusTarget(
          node: _node('add-check'),
          label: 'Add ungraded understanding check prompt',
          isEnabled: () => !_busy,
          onActivate: () => _add(LessonStepKind.check),
        ),
        KeypadFocusTarget(
          node: _node('previous'),
          label: 'Previous step. Selection only',
          isEnabled: () => !_busy && step != null,
          onActivate: () => select(-1),
        ),
        KeypadFocusTarget(
          node: _node('next'),
          label: 'Next step. Selection only',
          isEnabled: () => !_busy && step != null,
          onActivate: () => select(1),
        ),
        KeypadFocusTarget(
          node: _node('edit'),
          label: 'Edit selected prompt',
          isEnabled: () =>
              !_busy && step != null && step.kind != LessonStepKind.audio,
          onActivate: _edit,
        ),
        KeypadFocusTarget(
          node: _node('earlier'),
          label: 'Save selected step earlier in plan',
          isEnabled: () => !_busy && step != null && _position > 0,
          onActivate: () => _move(-1),
        ),
        KeypadFocusTarget(
          node: _node('later'),
          label: 'Save selected step later in plan',
          isEnabled: () =>
              !_busy && step != null && _position < _plan!.steps.length - 1,
          onActivate: () => _move(1),
        ),
        KeypadFocusTarget(
          node: _node('run'),
          label:
              'Run only selected step with confirmation. No automatic advancement',
          isEnabled: () => !_busy && step != null,
          onActivate: _execute,
        ),
        KeypadFocusTarget(
          node: _node('remove-step'),
          label: 'Remove selected step with confirmation',
          isEnabled: () => !_busy && step != null,
          onActivate: _removeStep,
        ),
        KeypadFocusTarget(
          node: _node('remove-plan'),
          label: 'Remove selected plan with confirmation',
          isEnabled: () => !_busy,
          onActivate: _removePlan,
        ),
      ],
    ];
    Widget button(String id, String label) {
      final target = targets.firstWhere((target) => target.node == _node(id));
      return OutlinedButton(
        focusNode: target.node,
        onPressed: target.isEnabled?.call() == false ? null : target.onActivate,
        child: Text(label),
      );
    }

    return KeypadInstructionWrapper(
      screenName:
          'Teacher lesson plans. Select without running. Run needs confirmation. Steps never advance automatically.',
      focusTargets: targets,
      actions: {0: () => Navigator.pop(context)},
      labels: const {0: 'Back'},
      onHashKey: () => Navigator.pop(context),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Lesson sequences'),
          leading: IconButton(
            focusNode: _node('back'),
            tooltip: 'Back',
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Teacher-private reusable plans. Selection does not run classroom actions. No automatic recording, microphone activation or advancement.',
              ),
              if (_busy) const LinearProgressIndicator(),
              if (_issue != null)
                Semantics(liveRegion: true, child: Text(_issue!)),
              Text(_status),
              button('read', 'Read plan status'),
              button('refresh', 'Refresh plans'),
              button('create', 'Create lesson plan'),
              for (final plan in _plans)
                button(
                  'plan-${plan.id}',
                  '${plan.title} (${plan.steps.length} steps)',
                ),
              if (_plan != null) ...[
                Text('Selected: ${_plan!.title}. Revision ${_plan!.revision}.'),
                Text(
                  step == null
                      ? 'No steps yet.'
                      : 'Step ${_position + 1} of ${_plan!.steps.length}: ${step.kind.name}. ${step.text}',
                ),
                button('rename', 'Rename plan'),
                button('add-audio', 'Add recording'),
                button('add-prompt', 'Add teacher prompt'),
                button('add-check', 'Add understanding check'),
                button('previous', 'Previous step'),
                button('next', 'Next step'),
                button('edit', 'Edit selected prompt'),
                button('earlier', 'Move selected step earlier'),
                button('later', 'Move selected step later'),
                button('run', 'Run selected step'),
                button('remove-step', 'Remove selected step'),
                button('remove-plan', 'Remove selected plan'),
              ],
            ],
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
    screenName: widget.title,
    actions: const {},
    onHashKey: () => Navigator.pop(context),
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
            decoration: InputDecoration(labelText: widget.title),
          ),
          if (_issue != null) Text(_issue!),
          TextButton(
            focusNode: _save,
            onPressed: save,
            child: const Text('Save text'),
          ),
          TextButton(
            focusNode: _cancel,
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    ),
  );
}

class _SequenceChoiceDialog extends StatefulWidget {
  const _SequenceChoiceDialog({required this.labels});
  final List<String> labels;
  @override
  State<_SequenceChoiceDialog> createState() => _SequenceChoiceDialogState();
}

class _SequenceChoiceDialogState extends State<_SequenceChoiceDialog> {
  late final _nodes = List.generate(
    widget.labels.length,
    (i) => FocusNode(debugLabel: 'sequence-recording-$i'),
  );
  final _cancel = FocusNode(debugLabel: 'sequence-recording-cancel');
  @override
  void dispose() {
    for (final node in _nodes) {
      node.dispose();
    }
    _cancel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => KeypadInstructionWrapper(
    screenName:
        'Choose authorized recording. Selection only adds a plan step, never broadcasts.',
    actions: const {},
    onHashKey: () => Navigator.pop(context),
    focusTargets: [
      KeypadFocusTarget(
        node: _cancel,
        label: 'Cancel selection',
        onActivate: () => Navigator.pop(context),
      ),
      for (var i = 0; i < _nodes.length; i++)
        KeypadFocusTarget(
          node: _nodes[i],
          label: widget.labels[i],
          onActivate: () => Navigator.pop(context, i),
        ),
    ],
    child: AlertDialog(
      scrollable: true,
      title: const Text('Add authorized recording'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            focusNode: _cancel,
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          for (var i = 0; i < _nodes.length; i++)
            TextButton(
              focusNode: _nodes[i],
              onPressed: () => Navigator.pop(context, i),
              child: Text(widget.labels[i]),
            ),
        ],
      ),
    ),
  );
}
