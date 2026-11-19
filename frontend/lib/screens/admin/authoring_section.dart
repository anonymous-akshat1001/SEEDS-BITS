import 'package:flutter/material.dart';

import '../../l10n/speech.dart';
import '../../services/admin_author_api.dart';
import '../../services/admin_setup_api.dart';
import '../../services/api_service.dart';
import '../../services/journey_models.dart';
import 'admin_common.dart';

enum _Kind { quizzes, journeys }

typedef _Workspace = ({
  int classId,
  String className,
  int subjectId,
  String subjectName,
});

/// Quizzes and learning journeys made on a teacher's behalf. The
/// administrator picks a teacher and one of their classes and subjects; the
/// server then applies exactly the rules it applies to that teacher.
class AuthoringSection extends StatefulWidget {
  const AuthoringSection({super.key});

  @override
  State<AuthoringSection> createState() => _AuthoringSectionState();
}

class _AuthoringSectionState extends State<AuthoringSection> {
  List<JsonMap> _teachers = const [];
  int? _teacherId;
  int _workspaceIndex = 0;
  _Kind _kind = _Kind.quizzes;
  List<JsonMap> _quizzes = const [];
  List<JourneyDraft> _journeys = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTeachers();
  }

  static List<_Workspace> _workspacesOf(JsonMap teacher) => [
    for (final item in (teacher['assignments'] as List? ?? const []))
      if (item is Map &&
          item['class_id'] is int &&
          item['subject_id'] is int &&
          item['is_active'] != false)
        (
          classId: item['class_id'] as int,
          className: '${item['class_name'] ?? item['class_id']}',
          subjectId: item['subject_id'] as int,
          subjectName: '${item['subject_name'] ?? item['subject_id']}',
        ),
  ];

  JsonMap? get _teacher =>
      _teachers.where((item) => item['user_id'] == _teacherId).firstOrNull;

  String get _teacherName => '${_teacher?['name'] ?? ''}';

  _Workspace? get _workspace {
    final teacher = _teacher;
    if (teacher == null) return null;
    final workspaces = _workspacesOf(teacher);
    return _workspaceIndex < workspaces.length
        ? workspaces[_workspaceIndex]
        : null;
  }

  AdminAuthorApi? get _api =>
      _teacherId == null ? null : AdminAuthorApi(_teacherId!);

  Future<void> _loadTeachers() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await AdminSetupApi.users(role: 'teacher');
    if (!mounted) return;
    if (!result.isSuccess) {
      setState(() {
        _loading = false;
        _error = Speech.t.adminSetupLoadFailed(
          AdminSetupApi.errorText(result.failure),
        );
      });
      return;
    }
    _teachers = [
      for (final teacher in result.data!)
        if (teacher['user_id'] is int &&
            teacher['is_active'] != false &&
            _workspacesOf(teacher).isNotEmpty)
          teacher,
    ];
    if (_teacher == null) {
      _teacherId = _teachers.firstOrNull?['user_id'] as int?;
      _workspaceIndex = 0;
    }
    await _loadItems();
  }

  Future<void> _loadItems() async {
    final api = _api;
    final workspace = _workspace;
    if (api == null || workspace == null) {
      setState(() {
        _loading = false;
        _quizzes = const [];
        _journeys = const [];
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    String? error;
    if (_kind == _Kind.quizzes) {
      final result = await api.quizzes(workspace.classId, workspace.subjectId);
      if (result.isSuccess) {
        _quizzes = result.data!;
      } else {
        error = AdminAuthorApi.errorText(result.failure);
      }
    } else {
      final result = await api.journeys(workspace.classId, workspace.subjectId);
      if (result.isSuccess) {
        _journeys = result.data!;
      } else {
        error = AdminAuthorApi.errorText(result.failure);
      }
    }
    if (!mounted) return;
    setState(() {
      _loading = false;
      _error = error == null ? null : Speech.t.adminSetupLoadFailed(error);
    });
  }

  // ─── Quizzes ───────────────────────────────────────────────────────────────

  Future<void> _newQuiz() async {
    final api = _api!;
    final workspace = _workspace!;
    final created = await showDialog<JsonMap>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _QuizSettingsDialog(
        title: Speech.t.adminAuthorNewQuizFor(_teacherName),
        onSave: (title, description, mode) => api.createQuiz(
          classId: workspace.classId,
          subjectId: workspace.subjectId,
          title: title,
          description: description,
          mode: mode,
        ),
      ),
    );
    if (!mounted || created == null) return;
    adminNotify(Speech.t.adminAuthorCreated('${created['title']}'));
    await _editQuiz(created);
  }

  Future<void> _editQuiz(JsonMap quiz) async {
    final workspace = _workspace!;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _QuizEditorDialog(
        api: _api!,
        quizId: quiz['quiz_id'] as int,
        workspace: workspace,
      ),
    );
    if (mounted) await _loadItems();
  }

  Future<void> _publishQuiz(JsonMap quiz) async {
    final t = Speech.t;
    final api = _api!;
    final title = '${quiz['title']}';
    final quizId = quiz['quiz_id'] as int;
    final ready = await api.readiness(quizId);
    if (!mounted) return;
    if (!ready.isSuccess) {
      adminNotify(AdminAuthorApi.errorText(ready.failure), error: true);
      return;
    }
    final problems = (ready.data!['errors'] as List? ?? const [])
        .whereType<String>()
        .toList();
    if (ready.data!['ready'] != true) {
      adminNotify(t.adminAuthorNotReady(problems.join(' ')), error: true);
      return;
    }
    if (!await adminConfirm(
      context,
      title: t.adminAuthorPublishQuizTitle,
      message: t.adminAuthorPublishQuizMessage(title, _teacherName),
      confirmLabel: t.adminAuthorPublish,
    )) {
      return;
    }
    final result = await api.publishQuiz(quizId);
    if (!mounted) return;
    if (adminReport(result, t.adminAuthorPublished(title))) await _loadItems();
  }

  Future<void> _closeQuiz(JsonMap quiz) async {
    final t = Speech.t;
    final title = '${quiz['title']}';
    if (!await adminConfirm(
      context,
      title: t.adminAuthorCloseQuizTitle,
      message: t.adminAuthorCloseQuizMessage(title),
      confirmLabel: t.adminAuthorClose,
    )) {
      return;
    }
    final result = await _api!.closeQuiz(quiz['quiz_id'] as int);
    if (!mounted) return;
    if (adminReport(result, t.adminAuthorClosed(title))) await _loadItems();
  }

  String _quizStatus(JsonMap quiz) {
    final t = Speech.t;
    return switch (quiz['display_status'] ?? quiz['status']) {
      'draft' => t.adminAuthorStatusDraft,
      'scheduled' => t.adminAuthorStatusScheduled,
      'closed' => t.adminAuthorStatusClosed,
      _ => t.adminAuthorStatusPublished,
    };
  }

  Widget _quizCard(JsonMap quiz) {
    final t = Speech.t;
    final title = '${quiz['title']}';
    final count = quiz['question_count'] is int
        ? quiz['question_count'] as int
        : 0;
    return AdminItemCard(
      title: title,
      status: _quizStatus(quiz),
      lines: [
        quiz['mode'] == 'practice'
            ? t.adminAuthorModePractice
            : t.adminAuthorModeGraded,
        t.adminAuthorQuestionCount(count),
      ],
      actions: [
        if (quiz['status'] == 'draft') ...[
          AdminActionButton(
            label: t.adminAuthorEdit,
            semanticLabel: t.adminAuthorEditNamed(title),
            icon: Icons.edit_outlined,
            onPressed: () => _editQuiz(quiz),
          ),
          AdminActionButton(
            label: t.adminAuthorPublish,
            semanticLabel: t.adminAuthorPublishNamed(title),
            icon: Icons.publish,
            filled: true,
            onPressed: () => _publishQuiz(quiz),
          ),
        ],
        if (quiz['status'] == 'published')
          AdminActionButton(
            label: t.adminAuthorClose,
            semanticLabel: t.adminAuthorCloseNamed(title),
            icon: Icons.lock_outline,
            onPressed: () => _closeQuiz(quiz),
          ),
      ],
    );
  }

  // ─── Journeys ──────────────────────────────────────────────────────────────

  Future<void> _newJourney() async {
    final t = Speech.t;
    final api = _api!;
    final workspace = _workspace!;
    final created = await showDialog<JourneyDraft>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _TitleDialog(
        title: t.adminAuthorNewJourneyFor(_teacherName),
        onSave: (title) =>
            api.createJourney(workspace.classId, workspace.subjectId, title),
      ),
    );
    if (!mounted || created == null) return;
    adminNotify(t.adminAuthorCreated(created.title));
    await _editJourney(created);
  }

  Future<void> _editJourney(JourneyDraft journey) async {
    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _JourneyEditorDialog(
        api: _api!,
        journeyId: journey.journeyId,
        workspace: _workspace!,
      ),
    );
    if (!mounted) return;
    if (saved == true) adminNotify(Speech.t.adminAuthorSaved);
    await _loadItems();
  }

  Future<void> _publishJourney(JourneyDraft journey) async {
    final t = Speech.t;
    if (!await adminConfirm(
      context,
      title: t.adminAuthorPublishJourneyTitle,
      message: t.adminAuthorPublishJourneyMessage(journey.title, _teacherName),
      confirmLabel: t.adminAuthorPublish,
    )) {
      return;
    }
    final result = await _api!.publishJourney(journey);
    if (!mounted) return;
    if (result.isSuccess) {
      adminNotify(t.adminAuthorPublished(journey.title));
      await _loadItems();
    } else {
      adminNotify(AdminAuthorApi.errorText(result.failure), error: true);
    }
  }

  Future<void> _archiveJourney(JourneyDraft journey) async {
    final t = Speech.t;
    if (!await adminConfirm(
      context,
      title: t.adminAuthorArchiveTitle,
      message: t.adminAuthorArchiveMessage(journey.title),
      confirmLabel: t.adminAuthorArchive,
    )) {
      return;
    }
    final result = await _api!.archiveJourney(journey);
    if (!mounted) return;
    if (result.isSuccess) {
      adminNotify(t.adminAuthorArchived(journey.title));
      await _loadItems();
    } else {
      adminNotify(AdminAuthorApi.errorText(result.failure), error: true);
    }
  }

  Widget _journeyCard(JourneyDraft journey) {
    final t = Speech.t;
    final base = switch (journey.status) {
      'published' => t.adminAuthorStatusPublished,
      'archived' => t.adminAuthorStatusArchived,
      _ => t.adminAuthorStatusDraft,
    };
    return AdminItemCard(
      title: journey.title,
      status: journey.hasUnpublishedChanges
          ? t.adminAuthorStatusChanged(base)
          : base,
      lines: [
        t.adminAuthorStepCount(journey.stepCount),
        t.adminAuthorQuestionCount(journey.questionCount),
      ],
      actions: [
        if (!journey.isArchived)
          AdminActionButton(
            label: t.adminAuthorEdit,
            semanticLabel: t.adminAuthorEditNamed(journey.title),
            icon: Icons.edit_outlined,
            onPressed: () => _editJourney(journey),
          ),
        if (journey.isDraft || journey.hasUnpublishedChanges)
          AdminActionButton(
            label: t.adminAuthorPublish,
            semanticLabel: t.adminAuthorPublishNamed(journey.title),
            icon: Icons.publish,
            filled: true,
            onPressed: () => _publishJourney(journey),
          ),
        if (journey.isPublished)
          AdminActionButton(
            label: t.adminAuthorArchive,
            semanticLabel: t.adminAuthorArchiveNamed(journey.title),
            icon: Icons.archive_outlined,
            onPressed: () => _archiveJourney(journey),
          ),
      ],
    );
  }

  // ─── Layout ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final t = Speech.t;
    final teacher = _teacher;
    final workspaces = teacher == null
        ? const <_Workspace>[]
        : _workspacesOf(teacher);
    final ready = !_loading && _workspace != null;
    final quizzes = _kind == _Kind.quizzes;
    return AdminSectionBody(
      loading: _loading,
      error: _error,
      onRetry: _loadTeachers,
      emptyText: teacher == null
          ? t.adminAuthorNoTeachers
          : quizzes
          ? t.adminAuthorNoQuizzes
          : t.adminAuthorNoJourneys,
      header: [
        AdminNote(t.adminAuthorNote),
        const SizedBox(height: 12),
        AdminDropdown<int>(
          label: t.adminAuthorTeacher,
          value: _teacherId,
          options: [
            for (final item in _teachers)
              (item['user_id'] as int, '${item['name']}'),
          ],
          onChanged: (value) {
            if (value == null || value == _teacherId) return;
            setState(() {
              _teacherId = value;
              _workspaceIndex = 0;
            });
            _loadItems();
          },
        ),
        const SizedBox(height: 8),
        AdminDropdown<int>(
          label: t.adminAuthorWorkspace,
          value: workspaces.isEmpty ? null : _workspaceIndex,
          options: [
            for (var index = 0; index < workspaces.length; index++)
              (
                index,
                t.adminAuthorWorkspaceName(
                  workspaces[index].className,
                  workspaces[index].subjectName,
                ),
              ),
          ],
          onChanged: (value) {
            if (value == null || value == _workspaceIndex) return;
            setState(() => _workspaceIndex = value);
            _loadItems();
          },
        ),
        const SizedBox(height: 12),
        AdminChoiceChips<_Kind>(
          heading: t.adminAuthorKind,
          options: [
            (_Kind.quizzes, t.adminAuthorKindQuizzes),
            (_Kind.journeys, t.adminAuthorKindJourneys),
          ],
          selected: _kind,
          onSelected: (kind) {
            if (kind == _kind) return;
            setState(() => _kind = kind);
            _loadItems();
          },
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.icon(
            onPressed: ready ? (quizzes ? _newQuiz : _newJourney) : null,
            icon: const Icon(Icons.add),
            label: Text(
              quizzes ? t.adminAuthorNewQuiz : t.adminAuthorNewJourney,
            ),
          ),
        ),
      ],
      items: teacher == null
          ? const []
          : quizzes
          ? [for (final quiz in _quizzes) _quizCard(quiz)]
          : [for (final journey in _journeys) _journeyCard(journey)],
    );
  }
}

// ─── Shared dialogs ──────────────────────────────────────────────────────────

/// Asks for a title and saves it; stays open with the server's explanation
/// when saving fails.
class _TitleDialog extends StatefulWidget {
  const _TitleDialog({required this.title, required this.onSave});

  final String title;
  final Future<ApiResult<JourneyDraft>> Function(String title) onSave;

  @override
  State<_TitleDialog> createState() => _TitleDialogState();
}

class _TitleDialogState extends State<_TitleDialog> {
  final _title = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final t = Speech.t;
    final title = _title.text.trim();
    if (title.isEmpty) {
      setState(() => _error = t.adminAuthorRequired(t.adminAuthorTitle));
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final result = await widget.onSave(title);
    if (!mounted) return;
    if (!result.isSuccess) {
      setState(() {
        _busy = false;
        _error = AdminAuthorApi.errorText(result.failure);
      });
      return;
    }
    Navigator.pop(context, result.data);
  }

  @override
  Widget build(BuildContext context) => AdminFormDialog(
    title: widget.title,
    busy: _busy,
    error: _error,
    onSave: _save,
    children: [
      TextField(
        controller: _title,
        enabled: !_busy,
        maxLength: 160,
        decoration: InputDecoration(labelText: Speech.t.adminAuthorTitle),
      ),
    ],
  );
}

class _QuizSettingsDialog extends StatefulWidget {
  const _QuizSettingsDialog({
    required this.title,
    required this.onSave,
    this.initial,
  });

  final String title;
  final JsonMap? initial;
  final Future<ApiResult<JsonMap>> Function(
    String title,
    String? description,
    String mode,
  )
  onSave;

  @override
  State<_QuizSettingsDialog> createState() => _QuizSettingsDialogState();
}

class _QuizSettingsDialogState extends State<_QuizSettingsDialog> {
  late final _title = TextEditingController(
    text: '${widget.initial?['title'] ?? ''}',
  );
  late final _description = TextEditingController(
    text: '${widget.initial?['description'] ?? ''}',
  );
  late String _mode = widget.initial?['mode'] == 'practice'
      ? 'practice'
      : 'graded';
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final t = Speech.t;
    final title = _title.text.trim();
    if (title.isEmpty) {
      setState(() => _error = t.adminAuthorRequired(t.adminAuthorTitle));
      return;
    }
    final description = _description.text.trim();
    setState(() {
      _busy = true;
      _error = null;
    });
    final result = await widget.onSave(
      title,
      description.isEmpty ? null : description,
      _mode,
    );
    if (!mounted) return;
    if (!result.isSuccess) {
      setState(() {
        _busy = false;
        _error = AdminAuthorApi.errorText(result.failure);
      });
      return;
    }
    Navigator.pop(context, result.data);
  }

  @override
  Widget build(BuildContext context) {
    final t = Speech.t;
    return AdminFormDialog(
      title: widget.title,
      busy: _busy,
      error: _error,
      onSave: _save,
      children: [
        TextField(
          controller: _title,
          enabled: !_busy,
          maxLength: 300,
          decoration: InputDecoration(labelText: t.adminAuthorTitle),
        ),
        TextField(
          controller: _description,
          enabled: !_busy,
          maxLines: 3,
          minLines: 1,
          decoration: InputDecoration(labelText: t.adminAuthorDescription),
        ),
        const SizedBox(height: 12),
        AdminChoiceChips<String>(
          heading: t.adminAuthorMode,
          options: [
            ('graded', t.adminAuthorModeGraded),
            ('practice', t.adminAuthorModePractice),
          ],
          selected: _mode,
          onSelected: (mode) => setState(() => _mode = mode),
        ),
      ],
    );
  }
}

typedef _ChoiceQuestion = ({
  String text,
  List<String> options,
  int? correctIndex,
  String? explanation,
  bool saveToBank,
});

/// A question or poll with up to four options. Quizzes need exactly four
/// options; journey questions and polls need two to four.
class _ChoiceQuestionDialog extends StatefulWidget {
  const _ChoiceQuestionDialog({
    required this.title,
    required this.textLabel,
    required this.onSave,
    this.minOptions = 2,
    this.withAnswer = true,
    this.offerBank = false,
  });

  final String title;
  final String textLabel;
  final int minOptions;
  final bool withAnswer;
  final bool offerBank;

  /// Returns an error to show, or null when saved.
  final Future<String?> Function(_ChoiceQuestion question) onSave;

  @override
  State<_ChoiceQuestionDialog> createState() => _ChoiceQuestionDialogState();
}

class _ChoiceQuestionDialogState extends State<_ChoiceQuestionDialog> {
  final _text = TextEditingController();
  final _options = List.generate(4, (_) => TextEditingController());
  final _explanation = TextEditingController();
  int _correct = 0;
  bool _saveToBank = true;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _text.dispose();
    _explanation.dispose();
    for (final option in _options) {
      option.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final t = Speech.t;
    final text = _text.text.trim();
    final filled = [for (final option in _options) option.text.trim()];
    String? problem;
    if (text.isEmpty) {
      problem = t.adminAuthorRequired(widget.textLabel);
    } else if (widget.minOptions == 4 && filled.any((o) => o.isEmpty)) {
      problem = t.adminAuthorNeedFourOptions;
    } else if (filled.where((o) => o.isNotEmpty).length < widget.minOptions) {
      problem = t.adminAuthorNeedTwoOptions;
    } else if (widget.withAnswer && filled[_correct].isEmpty) {
      problem = t.adminAuthorCorrectIsBlank;
    }
    final options = [
      for (final option in filled)
        if (option.isNotEmpty) option,
    ];
    if (problem == null &&
        options.map((o) => o.toLowerCase()).toSet().length != options.length) {
      problem = t.adminAuthorDuplicateOptions;
    }
    if (problem != null) {
      setState(() => _error = problem);
      return;
    }
    // Blank options are dropped, so count only filled ones before the answer.
    final correct = widget.withAnswer
        ? filled.take(_correct).where((o) => o.isNotEmpty).length
        : null;
    final explanation = _explanation.text.trim();
    setState(() {
      _busy = true;
      _error = null;
    });
    final error = await widget.onSave((
      text: text,
      options: options,
      correctIndex: correct,
      explanation: explanation.isEmpty ? null : explanation,
      saveToBank: widget.offerBank && _saveToBank,
    ));
    if (!mounted) return;
    if (error != null) {
      setState(() {
        _busy = false;
        _error = error;
      });
      return;
    }
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final t = Speech.t;
    return AdminFormDialog(
      title: widget.title,
      busy: _busy,
      error: _error,
      onSave: _save,
      children: [
        TextField(
          controller: _text,
          enabled: !_busy,
          maxLines: 3,
          minLines: 1,
          decoration: InputDecoration(labelText: widget.textLabel),
        ),
        for (var index = 0; index < 4; index++)
          TextField(
            controller: _options[index],
            enabled: !_busy,
            decoration: InputDecoration(
              labelText: index < widget.minOptions
                  ? t.adminAuthorOption(index + 1)
                  : t.adminAuthorOptionalOption(index + 1),
            ),
          ),
        if (widget.withAnswer) ...[
          const SizedBox(height: 12),
          AdminChoiceChips<int>(
            heading: t.adminAuthorCorrectOption,
            options: [
              for (var index = 0; index < 4; index++)
                (index, t.adminAuthorOption(index + 1)),
            ],
            selected: _correct,
            onSelected: (index) => setState(() => _correct = index),
          ),
          TextField(
            controller: _explanation,
            enabled: !_busy,
            maxLines: 3,
            minLines: 1,
            decoration: InputDecoration(labelText: t.adminAuthorExplanation),
          ),
        ],
        if (widget.offerBank)
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: _saveToBank,
            onChanged: _busy
                ? null
                : (value) => setState(() => _saveToBank = value ?? false),
            title: Text(t.adminAuthorSaveToBank),
          ),
      ],
    );
  }
}

/// Lists choices with an Add button each; returns the one picked.
class _PickerDialog<T> extends StatefulWidget {
  const _PickerDialog({
    required this.title,
    required this.load,
    required this.emptyText,
    required this.titleOf,
    this.linesOf,
    this.note,
  });

  final String title;
  final Future<ApiResult<List<T>>> Function() load;
  final String emptyText;
  final String Function(T item) titleOf;
  final List<String> Function(T item)? linesOf;
  final String? note;

  @override
  State<_PickerDialog<T>> createState() => _PickerDialogState<T>();
}

class _PickerDialogState<T> extends State<_PickerDialog<T>> {
  late final Future<ApiResult<List<T>>> _load = widget.load();

  @override
  Widget build(BuildContext context) {
    final t = Speech.t;
    final note = widget.note;
    final titleOf = widget.titleOf;
    final linesOf = widget.linesOf;
    return AlertDialog(
      scrollable: true,
      insetPadding: const EdgeInsets.all(12),
      title: Text(widget.title),
      content: SizedBox(
        width: 520,
        child: FutureBuilder<ApiResult<List<T>>>(
          future: _load,
          builder: (context, snapshot) {
            final result = snapshot.data;
            if (result == null) {
              return Semantics(
                label: t.adminSetupLoading,
                child: const LinearProgressIndicator(),
              );
            }
            if (!result.isSuccess) {
              return AdminErrorText(
                t.adminSetupLoadFailed(
                  AdminAuthorApi.errorText(result.failure),
                ),
              );
            }
            final items = result.data!;
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (note != null) ...[
                  AdminNote(note),
                  const SizedBox(height: 12),
                ],
                if (items.isEmpty) Text(widget.emptyText),
                for (final item in items)
                  AdminItemCard(
                    title: titleOf(item),
                    lines: linesOf?.call(item) ?? const [],
                    actions: [
                      AdminActionButton(
                        label: t.adminAuthorAdd,
                        semanticLabel: t.adminAuthorAddNamed(titleOf(item)),
                        icon: Icons.add,
                        onPressed: () => Navigator.pop(context, item),
                      ),
                    ],
                  ),
              ],
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(t.adminSetupCancel),
        ),
      ],
    );
  }
}

List<String> _bankOptionTexts(JsonMap question) {
  final options =
      [...(question['options'] as List? ?? const []).whereType<Map>()]..sort(
        (a, b) => ((a['position'] as int?) ?? 0).compareTo(
          (b['position'] as int?) ?? 0,
        ),
      );
  return [for (final option in options) '${option['option_text']}'];
}

int _bankCorrectIndex(JsonMap question) {
  final options =
      [...(question['options'] as List? ?? const []).whereType<Map>()]..sort(
        (a, b) => ((a['position'] as int?) ?? 0).compareTo(
          (b['position'] as int?) ?? 0,
        ),
      );
  return options.indexWhere((option) => option['is_correct'] == true);
}

List<String> _answerLines(List<String> options, int? correct) => [
  options.join(' · '),
  if (correct != null && correct >= 0 && correct < options.length)
    Speech.t.adminAuthorCorrectAnswer(options[correct]),
];

Future<JsonMap?> _pickBankQuestion(
  BuildContext context,
  AdminAuthorApi api,
  _Workspace workspace,
) => showDialog<JsonMap>(
  context: context,
  builder: (_) => _PickerDialog<JsonMap>(
    title: Speech.t.adminAuthorBankTitle,
    load: () => api.bankQuestions(workspace.classId, workspace.subjectId),
    emptyText: Speech.t.adminAuthorBankEmpty,
    titleOf: (question) => '${question['question_text']}',
    linesOf: (question) =>
        _answerLines(_bankOptionTexts(question), _bankCorrectIndex(question)),
  ),
);

// ─── Quiz editor ─────────────────────────────────────────────────────────────

class _QuizEditorDialog extends StatefulWidget {
  const _QuizEditorDialog({
    required this.api,
    required this.quizId,
    required this.workspace,
  });

  final AdminAuthorApi api;
  final int quizId;
  final _Workspace workspace;

  @override
  State<_QuizEditorDialog> createState() => _QuizEditorDialogState();
}

class _QuizEditorDialogState extends State<_QuizEditorDialog> {
  JsonMap? _quiz;
  bool _busy = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _apply(widget.api.quiz(widget.quizId));
  }

  Future<void> _apply(Future<ApiResult<JsonMap>> request) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final result = await request;
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (result.isSuccess) {
        _quiz = result.data;
      } else {
        _error = AdminAuthorApi.errorText(result.failure);
      }
    });
  }

  Future<void> _editSettings() async {
    final quiz = _quiz!;
    final saved = await showDialog<JsonMap>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _QuizSettingsDialog(
        title: Speech.t.adminAuthorQuizSettings,
        initial: quiz,
        onSave: (title, description, mode) => widget.api.updateQuiz(
          quiz,
          title: title,
          description: description,
          mode: mode,
        ),
      ),
    );
    if (mounted && saved != null) setState(() => _quiz = saved);
  }

  Future<void> _addNew() async {
    final t = Speech.t;
    await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ChoiceQuestionDialog(
        title: t.adminAuthorAddNewQuestion,
        textLabel: t.adminAuthorQuestionText,
        minOptions: 4,
        offerBank: true,
        onSave: (question) async {
          final result = await widget.api.addNewQuestion(
            widget.quizId,
            text: question.text,
            options: question.options,
            correctIndex: question.correctIndex!,
            explanation: question.explanation,
            saveToBank: question.saveToBank,
          );
          if (!result.isSuccess) {
            return AdminAuthorApi.errorText(result.failure);
          }
          if (mounted) setState(() => _quiz = result.data);
          return null;
        },
      ),
    );
  }

  Future<void> _addFromBank() async {
    final picked = await _pickBankQuestion(
      context,
      widget.api,
      widget.workspace,
    );
    if (!mounted || picked == null) return;
    await _apply(
      widget.api.addBankQuestion(widget.quizId, picked['question_id'] as int),
    );
  }

  Future<void> _remove(JsonMap question) => _apply(
    widget.api.removeQuestion(
      widget.quizId,
      question['quiz_question_id'] as int,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final t = Speech.t;
    final quiz = _quiz;
    final questions = [
      for (final item in (quiz?['questions'] as List? ?? const []))
        if (item is Map) JsonMap.from(item),
    ];
    return AlertDialog(
      scrollable: true,
      insetPadding: const EdgeInsets.all(12),
      title: Text(t.adminAuthorEditQuiz('${quiz?['title'] ?? ''}')),
      content: SizedBox(
        width: 560,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (quiz != null) ...[
              Text(
                quiz['mode'] == 'practice'
                    ? t.adminAuthorModePractice
                    : t.adminAuthorModeGraded,
              ),
              if (quiz['description'] is String) Text('${quiz['description']}'),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: _busy ? null : _editSettings,
                  icon: const Icon(Icons.tune),
                  label: Text(t.adminAuthorQuizSettings),
                ),
              ),
              AdminHeading(t.adminAuthorQuestions),
              if (questions.isEmpty) Text(t.adminAuthorNoQuestions),
              for (final (index, question) in questions.indexed)
                _questionCard(index, question),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.icon(
                    onPressed: _busy ? null : _addNew,
                    icon: const Icon(Icons.add),
                    label: Text(t.adminAuthorAddNewQuestion),
                  ),
                  OutlinedButton.icon(
                    onPressed: _busy ? null : _addFromBank,
                    icon: const Icon(Icons.library_books_outlined),
                    label: Text(t.adminAuthorAddBankQuestion),
                  ),
                ],
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 12),
              AdminErrorText(_error!),
            ],
            if (_busy) ...[
              const SizedBox(height: 12),
              Semantics(
                label: t.adminSetupLoading,
                child: const LinearProgressIndicator(),
              ),
            ],
          ],
        ),
      ),
      actions: [
        FilledButton(
          onPressed: _busy ? null : () => Navigator.pop(context),
          child: Text(t.adminAuthorDone),
        ),
      ],
    );
  }

  Widget _questionCard(int index, JsonMap question) {
    final t = Speech.t;
    final text = '${question['question_text']}';
    final options =
        [...(question['options'] as List? ?? const []).whereType<Map>()]..sort(
          (a, b) => ((a['position'] as int?) ?? 0).compareTo(
            (b['position'] as int?) ?? 0,
          ),
        );
    final texts = [for (final option in options) '${option['option_text']}'];
    final label = t.adminAuthorQuestionLine(index + 1, text);
    return AdminItemCard(
      title: label,
      lines: _answerLines(
        texts,
        options.indexWhere((option) => option['is_correct'] == true),
      ),
      actions: [
        AdminActionButton(
          label: t.adminAuthorRemove,
          semanticLabel: t.adminAuthorRemoveNamed(label),
          icon: Icons.delete_outline,
          onPressed: _busy ? null : () => _remove(question),
        ),
      ],
    );
  }
}

// ─── Journey editor ──────────────────────────────────────────────────────────

class _JourneyEditorDialog extends StatefulWidget {
  const _JourneyEditorDialog({
    required this.api,
    required this.journeyId,
    required this.workspace,
  });

  final AdminAuthorApi api;
  final int journeyId;
  final _Workspace workspace;

  @override
  State<_JourneyEditorDialog> createState() => _JourneyEditorDialogState();
}

class _JourneyEditorDialogState extends State<_JourneyEditorDialog> {
  JourneyDraft? _journey;
  final _title = TextEditingController();
  bool _graded = false;
  int _retries = 1;
  List<JourneyStep> _steps = const [];
  bool _busy = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final result = await widget.api.journey(widget.journeyId);
    if (!mounted) return;
    setState(() {
      _busy = false;
      final journey = result.data;
      if (journey == null) {
        _error = AdminAuthorApi.errorText(result.failure);
        return;
      }
      _journey = journey;
      _title.text = journey.title;
      _graded = journey.graded;
      _retries = journey.maxRetries;
      _steps = journey.steps;
    });
  }

  Future<void> _save() async {
    final t = Speech.t;
    final journey = _journey;
    if (journey == null) return;
    final title = _title.text.trim();
    if (title.isEmpty) {
      setState(() => _error = t.adminAuthorRequired(t.adminAuthorTitle));
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final result = await widget.api.updateJourney(
      journey,
      title: title,
      graded: _graded,
      maxRetries: _retries,
      steps: _steps,
    );
    if (!mounted) return;
    if (!result.isSuccess) {
      setState(() {
        _busy = false;
        _error = AdminAuthorApi.errorText(result.failure);
      });
      return;
    }
    Navigator.pop(context, true);
  }

  void _addStep(JourneyStep step) => setState(() => _steps = [..._steps, step]);

  Future<void> _addRecording() async {
    final t = Speech.t;
    final picked = await showDialog<({int id, String title})>(
      context: context,
      builder: (_) => _PickerDialog<({int id, String title})>(
        title: t.adminAuthorRecordingsTitle,
        note: t.adminAuthorRecordingsNote,
        load: () => widget.api.recordings(
          widget.workspace.classId,
          widget.workspace.subjectId,
        ),
        emptyText: t.adminAuthorNoRecordings,
        titleOf: (recording) => recording.title,
      ),
    );
    if (!mounted || picked == null) return;
    _addStep(
      JourneyStep(
        kind: JourneyStepKind.audio,
        audioId: picked.id,
        title: picked.title,
      ),
    );
  }

  Future<void> _addNarration() async {
    final t = Speech.t;
    final text = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _NarrationDialog(title: t.adminAuthorAddNarration),
    );
    if (!mounted || text == null) return;
    _addStep(JourneyStep(kind: JourneyStepKind.narration, text: text));
  }

  Future<void> _addChoice({required bool poll}) async {
    final t = Speech.t;
    await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ChoiceQuestionDialog(
        title: poll ? t.adminAuthorAddPoll : t.adminAuthorAddQuestion,
        textLabel: poll ? t.adminAuthorPollText : t.adminAuthorQuestionText,
        withAnswer: !poll,
        onSave: (question) async {
          _addStep(
            JourneyStep(
              kind: poll ? JourneyStepKind.poll : JourneyStepKind.question,
              text: question.text,
              options: question.options,
              correctIndex: question.correctIndex,
              explanation: question.explanation,
            ),
          );
          return null;
        },
      ),
    );
  }

  Future<void> _addFromBank() async {
    final picked = await _pickBankQuestion(
      context,
      widget.api,
      widget.workspace,
    );
    if (!mounted || picked == null) return;
    _addStep(
      JourneyStep(
        kind: JourneyStepKind.question,
        text: '${picked['question_text']}',
        options: _bankOptionTexts(picked),
        correctIndex: _bankCorrectIndex(picked),
        explanation: picked['explanation'] is String
            ? picked['explanation'] as String
            : null,
        sourceQuestionId: picked['question_id'] as int,
      ),
    );
  }

  String _stepName(JourneyStep step) {
    final t = Speech.t;
    return switch (step.kind) {
      JourneyStepKind.audio => t.adminAuthorStepRecording(
        step.title ?? '${step.audioId}',
      ),
      JourneyStepKind.narration => t.adminAuthorStepNarration(step.text),
      JourneyStepKind.question => t.adminAuthorStepQuestion(step.text),
      JourneyStepKind.poll => t.adminAuthorStepPoll(step.text),
    };
  }

  Widget _stepCard(int index) {
    final t = Speech.t;
    final step = _steps[index];
    final name = t.adminAuthorQuestionLine(index + 1, _stepName(step));
    return AdminItemCard(
      title: name,
      lines: switch (step.kind) {
        JourneyStepKind.question => _answerLines(
          step.options,
          step.correctIndex,
        ),
        JourneyStepKind.poll => [step.options.join(' · ')],
        _ => const [],
      },
      actions: [
        if (index > 0)
          AdminActionButton(
            label: t.adminAuthorMoveUp,
            semanticLabel: t.adminAuthorMoveUpNamed(name),
            icon: Icons.arrow_upward,
            onPressed: _busy
                ? null
                : () => setState(
                    () => _steps = JourneySteps.move(_steps, index, index - 1),
                  ),
          ),
        if (index < _steps.length - 1)
          AdminActionButton(
            label: t.adminAuthorMoveDown,
            semanticLabel: t.adminAuthorMoveDownNamed(name),
            icon: Icons.arrow_downward,
            onPressed: _busy
                ? null
                : () => setState(
                    () => _steps = JourneySteps.move(_steps, index, index + 1),
                  ),
          ),
        AdminActionButton(
          label: t.adminAuthorRemove,
          semanticLabel: t.adminAuthorRemoveNamed(name),
          icon: Icons.delete_outline,
          onPressed: _busy
              ? null
              : () =>
                    setState(() => _steps = JourneySteps.remove(_steps, index)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Speech.t;
    final journey = _journey;
    return AdminFormDialog(
      title: t.adminAuthorEditJourney(journey?.title ?? ''),
      busy: _busy,
      error: _error,
      onSave: _save,
      saveLabel: t.adminAuthorSaveJourney,
      children: [
        if (journey != null) ...[
          TextField(
            controller: _title,
            enabled: !_busy,
            maxLength: 160,
            decoration: InputDecoration(labelText: t.adminAuthorTitle),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _graded,
            onChanged: _busy
                ? null
                : (value) => setState(() => _graded = value),
            title: Text(t.adminAuthorGraded),
          ),
          AdminDropdown<int>(
            label: t.adminAuthorRetries,
            value: _retries,
            options: [
              for (var count = 0; count <= 5; count++) (count, '$count'),
            ],
            onChanged: _busy
                ? null
                : (value) => setState(() => _retries = value ?? _retries),
          ),
          AdminHeading(t.adminAuthorSteps),
          if (_steps.isEmpty) Text(t.adminAuthorNoSteps),
          for (var index = 0; index < _steps.length; index++) _stepCard(index),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: _busy ? null : _addRecording,
                icon: const Icon(Icons.audiotrack),
                label: Text(t.adminAuthorAddRecording),
              ),
              OutlinedButton.icon(
                onPressed: _busy ? null : _addNarration,
                icon: const Icon(Icons.record_voice_over_outlined),
                label: Text(t.adminAuthorAddNarration),
              ),
              OutlinedButton.icon(
                onPressed: _busy ? null : () => _addChoice(poll: false),
                icon: const Icon(Icons.quiz_outlined),
                label: Text(t.adminAuthorAddQuestion),
              ),
              OutlinedButton.icon(
                onPressed: _busy ? null : _addFromBank,
                icon: const Icon(Icons.library_books_outlined),
                label: Text(t.adminAuthorAddBankQuestion),
              ),
              OutlinedButton.icon(
                onPressed: _busy ? null : () => _addChoice(poll: true),
                icon: const Icon(Icons.poll_outlined),
                label: Text(t.adminAuthorAddPoll),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _NarrationDialog extends StatefulWidget {
  const _NarrationDialog({required this.title});

  final String title;

  @override
  State<_NarrationDialog> createState() => _NarrationDialogState();
}

class _NarrationDialogState extends State<_NarrationDialog> {
  final _text = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Speech.t;
    return AdminFormDialog(
      title: widget.title,
      error: _error,
      onSave: () {
        final text = _text.text.trim();
        if (text.isEmpty) {
          setState(
            () => _error = t.adminAuthorRequired(t.adminAuthorNarrationText),
          );
          return;
        }
        Navigator.pop(context, text);
      },
      children: [
        TextField(
          controller: _text,
          maxLines: 5,
          minLines: 2,
          maxLength: 2000,
          decoration: InputDecoration(labelText: t.adminAuthorNarrationText),
        ),
      ],
    );
  }
}
