import 'dart:async';

import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/tts_service.dart';
import '../utils/keypad_actions.dart';
import '../utils/ui_utils.dart';
import '../widgets/key_instruction_wrapper.dart';
import '../widgets/keypad_confirmation_dialog.dart';

class AccessibleAction {
  const AccessibleAction({
    required this.value,
    required this.label,
    required this.icon,
  });

  final String value;
  final String label;
  final IconData icon;
}

class AccessibleActionDialog extends StatefulWidget {
  const AccessibleActionDialog({
    super.key,
    required this.title,
    required this.actions,
  });

  final String title;
  final List<AccessibleAction> actions;

  @override
  State<AccessibleActionDialog> createState() => _AccessibleActionDialogState();
}

class _AccessibleActionDialogState extends State<AccessibleActionDialog> {
  late final List<FocusNode> _focuses = List.generate(
    widget.actions.length,
    (index) => FocusNode(debugLabel: 'action-dialog-option-$index'),
  );
  final _cancelFocus = FocusNode(debugLabel: 'action-dialog-cancel');

  @override
  void dispose() {
    for (final focus in _focuses) {
      focus.dispose();
    }
    _cancelFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    void select(String? value) => Navigator.pop(context, value);

    return KeypadInstructionWrapper(
      screenName: widget.title,
      labels: const {0: 'Cancel'},
      actions: {0: () => select(null)},
      focusTargets: [
        for (var index = 0; index < widget.actions.length; index++)
          KeypadFocusTarget(
            node: _focuses[index],
            label: widget.actions[index].label,
            onActivate: () => select(widget.actions[index].value),
          ),
        KeypadFocusTarget(
          node: _cancelFocus,
          label: 'Cancel and return',
          onActivate: () => select(null),
        ),
      ],
      child: AlertDialog(
        title: Text(widget.title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var index = 0; index < widget.actions.length; index++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ElevatedButton.icon(
                    focusNode: _focuses[index],
                    onPressed: () => select(widget.actions[index].value),
                    icon: Icon(widget.actions[index].icon),
                    label: Text(widget.actions[index].label),
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            focusNode: _cancelFocus,
            onPressed: () => select(null),
            child: const Text('0: Cancel'),
          ),
        ],
      ),
    );
  }
}

class TeacherQuizScreen extends StatefulWidget {
  const TeacherQuizScreen({
    super.key,
    required this.classId,
    required this.className,
    required this.subjectId,
    required this.subjectName,
  });

  final int classId;
  final String className;
  final int subjectId;
  final String subjectName;

  @override
  State<TeacherQuizScreen> createState() => _TeacherQuizScreenState();
}

class _TeacherQuizScreenState extends State<TeacherQuizScreen> {
  final _createQuestionFocus = FocusNode(debugLabel: 'quiz-create-question');
  final _createQuizFocus = FocusNode(debugLabel: 'quiz-create-quiz');
  final _refreshFocus = FocusNode(debugLabel: 'quiz-refresh');
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode(debugLabel: 'quiz-bank-search');
  final Map<int, FocusNode> _questionActionFocuses = {};
  final Map<int, FocusNode> _quizPrimaryFocuses = {};
  final Map<int, FocusNode> _quizDuplicateFocuses = {};
  final Map<int, FocusNode> _quizResultsFocuses = {};
  List<dynamic> _questions = const [];
  List<dynamic> _quizzes = const [];
  bool _loading = true;
  bool _initialAnnouncementPending = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) setState(() => _loading = true);
    final results = await Future.wait([
      ApiService.getBankQuestions(
        classId: widget.classId,
        subjectId: widget.subjectId,
        search: _searchController.text,
      ),
      ApiService.getTeacherQuizzes(
        classId: widget.classId,
        subjectId: widget.subjectId,
      ),
    ]);
    if (!mounted) return;
    setState(() {
      _questions = results[0];
      _quizzes = results[1];
      _loading = false;
      _error = null;
    });
    final summary =
        '${_questions.length} bank questions and ${_quizzes.length} quizzes loaded.';
    if (_initialAnnouncementPending) {
      _initialAnnouncementPending = false;
      await TtsService.speak(
        '${buildTtsInstructions(teacherQuizKeyLabels, screenName: 'Teacher quizzes for ${widget.className}, ${widget.subjectName}')} $summary',
      );
    } else {
      await TtsService.speak(summary);
    }
  }

  Future<void> _createQuestion() async {
    final value = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AccessibleQuestionEditorDialog(),
    );
    if (value == null) return;
    final result = await ApiService.createBankQuestion(
      classId: widget.classId,
      subjectId: widget.subjectId,
      questionText: value['question_text'] as String,
      options: List<String>.from(value['options'] as List),
      correctOptionIndex: value['correct_option_index'] as int,
      explanation: value['explanation'] as String?,
    );
    if (!mounted) return;
    if (result == null) {
      _showError('Question could not be saved. Check all four options.');
      return;
    }
    await TtsService.speak(
      'Question saved. Editing this bank question later will not change existing quizzes.',
    );
    await _load();
  }

  Future<void> _editQuestion(Map question) async {
    final value = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AccessibleQuestionEditorDialog(
        initialQuestion: Map<String, dynamic>.from(question),
      ),
    );
    if (value == null) return;
    final result = await ApiService.updateBankQuestion(
      questionId: question['question_id'] as int,
      classId: widget.classId,
      subjectId: widget.subjectId,
      questionText: value['question_text'] as String,
      options: List<String>.from(value['options'] as List),
      correctOptionIndex: value['correct_option_index'] as int,
      explanation: value['explanation'] as String?,
    );
    if (result == null) {
      _showError('The bank question could not be updated.');
      return;
    }
    await TtsService.speak(
      'Bank question updated. Existing quiz snapshots were not changed.',
    );
    await _load();
  }

  Future<void> _archiveQuestion(Map question) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const KeypadConfirmationDialog(
        title: 'Archive bank question?',
        message:
            'Archive this private bank question? Existing quiz snapshots and attempts are not changed.',
        confirmLabel: 'Archive question',
      ),
    );
    if (confirmed != true) return;
    final result = await ApiService.archiveBankQuestion(
      question['question_id'] as int,
    );
    if (result == null) {
      _showError('The bank question could not be archived.');
      return;
    }
    await TtsService.speak('Bank question archived');
    await _load();
  }

  Future<void> _duplicateQuestion(Map question) async {
    final result = await ApiService.duplicateBankQuestion(
      question['question_id'] as int,
    );
    if (result == null) {
      _showError('The bank question could not be duplicated.');
      return;
    }
    await TtsService.speak('Bank question copy created');
    await _load();
  }

  Future<void> _handleQuestionAction(String action, Map question) async {
    if (action == 'edit') return _editQuestion(question);
    if (action == 'archive') return _archiveQuestion(question);
    if (action == 'duplicate') return _duplicateQuestion(question);
    if (action.startsWith('add:')) {
      final quizId = int.tryParse(action.substring(4));
      if (quizId != null) {
        await _addQuestion(quizId, question['question_id'] as int);
      }
    }
  }

  Future<void> _showQuestionActions(Map question) async {
    final drafts = _quizzes.where((quiz) => quiz['status'] == 'draft').toList();
    final action = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AccessibleActionDialog(
        title: 'Actions for ${question['question_text']}',
        actions: [
          const AccessibleAction(
            value: 'edit',
            label: 'Edit bank question',
            icon: Icons.edit,
          ),
          const AccessibleAction(
            value: 'duplicate',
            label: 'Duplicate bank question',
            icon: Icons.copy,
          ),
          const AccessibleAction(
            value: 'archive',
            label: 'Archive bank question',
            icon: Icons.archive_outlined,
          ),
          for (final quiz in drafts)
            AccessibleAction(
              value: 'add:${quiz['quiz_id']}',
              label: 'Add to ${quiz['title']}',
              icon: Icons.playlist_add,
            ),
        ],
      ),
    );
    if (action != null) await _handleQuestionAction(action, question);
  }

  Future<void> _createQuiz() async {
    final value = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AccessibleQuizEditorDialog(),
    );
    if (value == null) return;
    final result = await ApiService.createQuiz({
      ...value,
      'class_id': widget.classId,
      'subject_id': widget.subjectId,
    });
    if (!mounted) return;
    if (result == null) {
      _showError('Quiz draft could not be saved. Check its settings.');
      return;
    }
    await TtsService.speak('Quiz draft saved');
    await _load();
  }

  Future<void> _addQuestion(int quizId, int questionId) async {
    final result = await ApiService.addBankQuestionToQuiz(quizId, questionId);
    if (result == null) {
      _showError('The question could not be added to this quiz.');
      return;
    }
    await TtsService.speak('Question snapshot added to quiz');
    await _load();
  }

  Future<void> _publish(Map quiz) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => KeypadConfirmationDialog(
        title: 'Publish quiz?',
        message:
            'Publish "${quiz['title']}" to eligible students? Questions become academic snapshots.',
        confirmLabel: 'Publish quiz',
      ),
    );
    if (confirmed != true) return;
    final result = await ApiService.publishQuiz(quiz['quiz_id'] as int);
    if (result == null) {
      _showError(
        'Quiz is not ready. Add at least one valid question and verify the workspace.',
      );
      return;
    }
    final recipients = result['notification_recipients'] as int? ?? 0;
    final sent = result['notifications_sent'] as int? ?? 0;
    final failures = result['notification_failures'] as int? ?? 0;
    final notificationMessage = recipients == 0
        ? 'There are no eligible students to notify.'
        : sent == 0
        ? 'Quiz published, but no student device notifications were delivered. Check notification registration and server Firebase credentials.'
        : failures > 0
        ? 'Quiz published. $sent device notifications sent and $failures failed.'
        : 'Quiz published. $sent device notifications sent.';
    if (sent == 0 && recipients > 0 && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(notificationMessage)));
    }
    await TtsService.speak(notificationMessage);
    await _load();
  }

  Future<void> _close(Map quiz) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => KeypadConfirmationDialog(
        title: 'Close quiz?',
        message:
            'Close "${quiz['title']}"? No new attempts can start and active attempts will be finalized.',
        confirmLabel: 'Close quiz',
      ),
    );
    if (confirmed != true) return;
    final result = await ApiService.closeQuiz(quiz['quiz_id'] as int);
    if (result == null) {
      _showError('The quiz could not be closed.');
      return;
    }
    await TtsService.speak('Quiz closed');
    await _load();
  }

  Future<void> _duplicate(Map quiz) async {
    final result = await ApiService.duplicateQuiz(quiz['quiz_id'] as int);
    if (result == null) {
      _showError('The quiz could not be duplicated.');
      return;
    }
    await TtsService.speak('Editable quiz draft created');
    await _load();
  }

  Future<void> _showSummary(Map quiz) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizResultsScreen(
          quizId: quiz['quiz_id'] as int,
          quizTitle: '${quiz['title']}',
        ),
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    setState(() => _error = message);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
    TtsService.speak(message);
  }

  @override
  void dispose() {
    _createQuestionFocus.dispose();
    _createQuizFocus.dispose();
    _refreshFocus.dispose();
    _searchController.dispose();
    _searchFocus.dispose();
    for (final focus in [
      ..._questionActionFocuses.values,
      ..._quizPrimaryFocuses.values,
      ..._quizDuplicateFocuses.values,
      ..._quizResultsFocuses.values,
    ]) {
      focus.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeypadInstructionWrapper(
      screenName:
          'Teacher quizzes for ${widget.className}, ${widget.subjectName}',
      labels: teacherQuizKeyLabels,
      autoPlay: false,
      actions: {
        0: () => Navigator.pop(context),
        1: _load,
        2: _createQuestion,
        3: _createQuiz,
      },
      focusTargets: [
        KeypadFocusTarget(
          node: _refreshFocus,
          label: 'Refresh quiz content',
          onActivate: _load,
        ),
        KeypadFocusTarget(
          node: _searchFocus,
          label: 'Search private question bank',
          isTextField: true,
        ),
        KeypadFocusTarget(
          node: _createQuestionFocus,
          label: 'Create four option question',
          onActivate: _createQuestion,
        ),
        KeypadFocusTarget(
          node: _createQuizFocus,
          label: 'Create quiz draft',
          onActivate: _createQuiz,
        ),
        for (final question in _questions)
          KeypadFocusTarget(
            node: _questionActionFocuses.putIfAbsent(
              question['question_id'] as int,
              () => FocusNode(
                debugLabel: 'bank-question-actions-${question['question_id']}',
              ),
            ),
            label:
                'Question bank item, ${question['question_text']}. Press OK for edit, duplicate, archive, or add actions',
            onActivate: () => _showQuestionActions(question),
          ),
        for (final quiz in _quizzes) ...[
          KeypadFocusTarget(
            node: _quizPrimaryFocuses.putIfAbsent(
              quiz['quiz_id'] as int,
              () => FocusNode(
                debugLabel: 'teacher-quiz-primary-${quiz['quiz_id']}',
              ),
            ),
            label: quiz['status'] == 'draft'
                ? 'Publish ${quiz['title']}. ${quiz['question_count']} questions'
                : quiz['status'] == 'published'
                ? 'Close ${quiz['title']}'
                : '${quiz['title']} is closed',
            onActivate: quiz['status'] == 'draft'
                ? () => _publish(quiz)
                : quiz['status'] == 'published'
                ? () => _close(quiz)
                : null,
            isEnabled: () => quiz['status'] != 'closed',
          ),
          KeypadFocusTarget(
            node: _quizDuplicateFocuses.putIfAbsent(
              quiz['quiz_id'] as int,
              () => FocusNode(
                debugLabel: 'teacher-quiz-duplicate-${quiz['quiz_id']}',
              ),
            ),
            label: 'Duplicate ${quiz['title']} into a new editable draft',
            onActivate: () => _duplicate(quiz),
          ),
          KeypadFocusTarget(
            node: _quizResultsFocuses.putIfAbsent(
              quiz['quiz_id'] as int,
              () => FocusNode(
                debugLabel: 'teacher-quiz-results-${quiz['quiz_id']}',
              ),
            ),
            label: 'View results for ${quiz['title']}',
            onActivate: () => _showSummary(quiz),
          ),
        ],
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Quizzes'),
          actions: [
            IconButton(
              focusNode: _refreshFocus,
              onPressed: _load,
              tooltip: 'Refresh quizzes',
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: _loading
            ? Center(
                child: Semantics(
                  liveRegion: true,
                  label: 'Loading quizzes',
                  child: const CircularProgressIndicator(),
                ),
              )
            : RefreshIndicator(
                onRefresh: _load,
                child: ListView(
                  padding: UIUtils.paddingAll(context, 12),
                  children: [
                    Text(
                      '${widget.className} · ${widget.subjectName}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    if (_error != null)
                      Semantics(
                        liveRegion: true,
                        child: Card(
                          color: Theme.of(context).colorScheme.errorContainer,
                          child: ListTile(
                            leading: const Icon(Icons.error_outline),
                            title: Text(_error!),
                          ),
                        ),
                      ),
                    TextField(
                      controller: _searchController,
                      focusNode: _searchFocus,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) => _load(),
                      decoration: const InputDecoration(
                        labelText: 'Search private question bank',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ElevatedButton.icon(
                          focusNode: _createQuestionFocus,
                          onPressed: _createQuestion,
                          icon: const Icon(Icons.add),
                          label: const Text('2: New bank question'),
                        ),
                        ElevatedButton.icon(
                          focusNode: _createQuizFocus,
                          onPressed: _createQuiz,
                          icon: const Icon(Icons.quiz_outlined),
                          label: const Text('3: New quiz draft'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Private question bank',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Text(
                      'Editing a bank question never changes an existing quiz snapshot.',
                    ),
                    if (_questions.isEmpty)
                      const ListTile(
                        leading: Icon(Icons.inbox_outlined),
                        title: Text('No bank questions yet'),
                      )
                    else
                      ..._questions.map(
                        (question) => Card(
                          child: ListTile(
                            leading: const Icon(Icons.help_outline),
                            title: Text('${question['question_text']}'),
                            subtitle: Text(
                              '${(question['options'] as List).length} options',
                            ),
                            trailing: OutlinedButton.icon(
                              focusNode: _questionActionFocuses.putIfAbsent(
                                question['question_id'] as int,
                                () => FocusNode(
                                  debugLabel:
                                      'bank-question-actions-${question['question_id']}',
                                ),
                              ),
                              onPressed: () => _showQuestionActions(question),
                              icon: const Icon(Icons.tune),
                              label: const Text('Options'),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    Text(
                      'Quiz management',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (_quizzes.isEmpty)
                      const ListTile(
                        leading: Icon(Icons.inbox_outlined),
                        title: Text('No quizzes yet'),
                      )
                    else
                      ..._quizzes.map(
                        (quiz) => _TeacherQuizCard(
                          quiz: Map<String, dynamic>.from(quiz as Map),
                          primaryFocus: _quizPrimaryFocuses.putIfAbsent(
                            quiz['quiz_id'] as int,
                            () => FocusNode(
                              debugLabel:
                                  'teacher-quiz-primary-${quiz['quiz_id']}',
                            ),
                          ),
                          duplicateFocus: _quizDuplicateFocuses.putIfAbsent(
                            quiz['quiz_id'] as int,
                            () => FocusNode(
                              debugLabel:
                                  'teacher-quiz-duplicate-${quiz['quiz_id']}',
                            ),
                          ),
                          resultsFocus: _quizResultsFocuses.putIfAbsent(
                            quiz['quiz_id'] as int,
                            () => FocusNode(
                              debugLabel:
                                  'teacher-quiz-results-${quiz['quiz_id']}',
                            ),
                          ),
                          onPublish: () => _publish(quiz),
                          onClose: () => _close(quiz),
                          onDuplicate: () => _duplicate(quiz),
                          onResults: () => _showSummary(quiz),
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _TeacherQuizCard extends StatelessWidget {
  const _TeacherQuizCard({
    required this.quiz,
    required this.primaryFocus,
    required this.duplicateFocus,
    required this.resultsFocus,
    required this.onPublish,
    required this.onClose,
    required this.onDuplicate,
    required this.onResults,
  });

  final Map<String, dynamic> quiz;
  final FocusNode primaryFocus;
  final FocusNode duplicateFocus;
  final FocusNode resultsFocus;
  final VoidCallback onPublish;
  final VoidCallback onClose;
  final VoidCallback onDuplicate;
  final VoidCallback onResults;

  @override
  Widget build(BuildContext context) {
    final status = '${quiz['display_status']}';
    return Semantics(
      label:
          '${quiz['title']}. Status $status. ${quiz['question_count']} questions.',
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.quiz),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${quiz['title']}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Chip(label: Text(status.toUpperCase())),
                ],
              ),
              if (quiz['description'] != null) Text('${quiz['description']}'),
              Text(
                '${quiz['question_count']} questions · ${quiz['attempt_limit']} attempts'
                '${quiz['time_limit_minutes'] == null ? '' : ' · ${quiz['time_limit_minutes']} minutes'}',
              ),
              Wrap(
                spacing: 6,
                children: [
                  if (quiz['status'] == 'draft')
                    TextButton.icon(
                      focusNode: primaryFocus,
                      onPressed: onPublish,
                      icon: const Icon(Icons.publish),
                      label: const Text('Publish'),
                    ),
                  if (quiz['status'] == 'published')
                    TextButton.icon(
                      focusNode: primaryFocus,
                      onPressed: onClose,
                      icon: const Icon(Icons.lock_clock),
                      label: const Text('Close'),
                    ),
                  TextButton.icon(
                    focusNode: duplicateFocus,
                    onPressed: onDuplicate,
                    icon: const Icon(Icons.copy),
                    label: const Text('Duplicate'),
                  ),
                  TextButton.icon(
                    focusNode: resultsFocus,
                    onPressed: onResults,
                    icon: const Icon(Icons.analytics_outlined),
                    label: const Text('Results'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QuizResultsScreen extends StatefulWidget {
  const QuizResultsScreen({
    super.key,
    required this.quizId,
    required this.quizTitle,
  });

  final int quizId;
  final String quizTitle;

  @override
  State<QuizResultsScreen> createState() => _QuizResultsScreenState();
}

class _QuizResultsScreenState extends State<QuizResultsScreen> {
  final _refreshFocus = FocusNode(debugLabel: 'quiz-results-refresh');
  final _remindFocus = FocusNode(debugLabel: 'quiz-results-remind');
  final Map<int, FocusNode> _studentFocuses = {};
  Map<String, dynamic>? _summary;
  List<dynamic> _students = const [];
  bool _loading = true;
  String? _error;

  List<dynamic> get _notAttempted =>
      _students.where((student) => student['started'] != true).toList();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    final results = await Future.wait([
      ApiService.getQuizSummary(widget.quizId),
      ApiService.getTeacherQuizResults(widget.quizId),
    ]);
    if (!mounted) return;
    final summary = results[0];
    if (summary is! Map) {
      setState(() {
        _loading = false;
        _error = 'Quiz results could not be loaded.';
      });
      await TtsService.speak(_error!);
      return;
    }
    setState(() {
      _summary = Map<String, dynamic>.from(summary);
      _students = results[1] as List<dynamic>;
      _loading = false;
    });
    await TtsService.speak(
      '${_summary!['completed']} students completed. '
      '${_summary!['not_attempted']} students have not attempted.',
    );
  }

  String _studentDetails(Map student) {
    final attempts = student['attempts'] as List? ?? const [];
    if (attempts.isEmpty) {
      return '${student['student_name']} has not attempted this quiz.';
    }
    final scores = attempts
        .map(
          (attempt) =>
              'attempt ${attempt['attempt_number']}, ${attempt['percentage_score']} percent, ${attempt['status']}',
        )
        .join('. ');
    return '${student['student_name']}. Highest score '
        '${student['highest_score'] ?? 'not available'} percent. $scores.';
  }

  Future<void> _remind() async {
    if (_notAttempted.isEmpty) {
      await TtsService.speak('Every eligible student has attempted this quiz.');
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => KeypadConfirmationDialog(
        title: 'Remind students?',
        message:
            'Send one quiz reminder to all ${_notAttempted.length} students who have not attempted ${widget.quizTitle}?',
        confirmLabel: 'Send reminder',
      ),
    );
    if (confirmed != true) return;
    final result = await ApiService.remindQuizStudents(widget.quizId);
    if (!mounted) return;
    if (result == null) {
      setState(() => _error = 'Quiz reminders could not be sent.');
      await TtsService.speak(_error!);
      return;
    }
    final message =
        'Reminder processed for ${result['students_notified']} students. '
        '${result['device_notifications_queued']} device notifications queued.';
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
    await TtsService.speak(message);
  }

  @override
  void dispose() {
    _refreshFocus.dispose();
    _remindFocus.dispose();
    for (final focus in _studentFocuses.values) {
      focus.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final summary = _summary;
    return KeypadInstructionWrapper(
      screenName: 'Results for ${widget.quizTitle}',
      labels: const {
        0: 'Return to quizzes',
        1: 'Refresh results',
        2: 'Remind all students who have not attempted',
      },
      actions: {0: () => Navigator.pop(context), 1: _load, 2: _remind},
      focusTargets: [
        KeypadFocusTarget(
          node: _refreshFocus,
          label: 'Refresh quiz results',
          onActivate: _load,
        ),
        KeypadFocusTarget(
          node: _remindFocus,
          label: _notAttempted.isEmpty
              ? 'All students have attempted. Reminder unavailable'
              : 'Send a reminder to all ${_notAttempted.length} students who have not attempted',
          onActivate: _remind,
          isEnabled: () => _notAttempted.isNotEmpty,
        ),
        for (final student in _students)
          KeypadFocusTarget(
            node: _studentFocuses.putIfAbsent(
              student['student_id'] as int,
              () => FocusNode(
                debugLabel: 'quiz-result-student-${student['student_id']}',
              ),
            ),
            label: _studentDetails(student as Map),
            onActivate: () => TtsService.speak(_studentDetails(student)),
          ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text('${widget.quizTitle} results'),
          actions: [
            IconButton(
              focusNode: _refreshFocus,
              onPressed: _load,
              tooltip: 'Refresh results',
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: UIUtils.paddingAll(context, 12),
                children: [
                  if (_error != null)
                    Semantics(
                      liveRegion: true,
                      child: Card(
                        color: Theme.of(context).colorScheme.errorContainer,
                        child: ListTile(
                          leading: const Icon(Icons.error_outline),
                          title: Text(_error!),
                        ),
                      ),
                    ),
                  if (summary != null) ...[
                    Text(
                      'Class statistics',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          'Eligible: ${summary['eligible_students']}\n'
                          'Started: ${summary['started']}\n'
                          'Completed: ${summary['completed']}\n'
                          'Not attempted: ${summary['not_attempted']}\n'
                          'Completion: ${summary['completion_percentage']} percent\n'
                          'Average highest score: ${summary['average_highest_score'] ?? 'Not available'}\n'
                          'Highest score: ${summary['highest_score'] ?? 'Not available'}\n'
                          'Lowest completed score: ${summary['lowest_completed_score'] ?? 'Not available'}',
                        ),
                      ),
                    ),
                  ],
                  ElevatedButton.icon(
                    focusNode: _remindFocus,
                    onPressed: _notAttempted.isEmpty ? null : _remind,
                    icon: const Icon(Icons.notifications_active_outlined),
                    label: Text(
                      _notAttempted.isEmpty
                          ? 'All students have attempted'
                          : '2: Remind all not attempted',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Students yet to attempt',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    _notAttempted.isEmpty
                        ? 'None'
                        : _notAttempted
                              .map((student) => student['student_name'])
                              .join(', '),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Individual student scores',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  for (final student in _students)
                    Card(
                      child: ListTile(
                        focusNode: _studentFocuses.putIfAbsent(
                          student['student_id'] as int,
                          () => FocusNode(
                            debugLabel:
                                'quiz-result-student-${student['student_id']}',
                          ),
                        ),
                        leading: Icon(
                          student['started'] == true
                              ? Icons.person
                              : Icons.person_off_outlined,
                        ),
                        title: Text('${student['student_name']}'),
                        subtitle: Text(
                          student['started'] != true
                              ? 'Not attempted'
                              : 'Highest score: ${student['highest_score'] ?? 'Attempt in progress'}\n'
                                    '${(student['attempts'] as List).length} attempt(s)',
                        ),
                        onTap: () =>
                            TtsService.speak(_studentDetails(student as Map)),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}

class StudentQuizScreen extends StatefulWidget {
  const StudentQuizScreen({super.key});

  @override
  State<StudentQuizScreen> createState() => _StudentQuizScreenState();
}

class _StudentQuizScreenState extends State<StudentQuizScreen> {
  final _refreshFocus = FocusNode(debugLabel: 'student-quiz-refresh');
  final _stateFilterFocus = FocusNode(debugLabel: 'student-quiz-state-filter');
  final _subjectFilterFocus = FocusNode(
    debugLabel: 'student-quiz-subject-filter',
  );
  final Map<int, FocusNode> _openFocuses = {};
  final Map<int, FocusNode> _historyFocuses = {};
  List<dynamic> _quizzes = const [];
  bool _loading = true;
  bool _initialAnnouncementPending = true;
  String? _stateFilter;
  int? _subjectFilter;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) setState(() => _loading = true);
    final quizzes = await ApiService.getStudentQuizzes(
      subjectId: _subjectFilter,
      status: _stateFilter,
    );
    if (!mounted) return;
    setState(() {
      _quizzes = quizzes;
      _loading = false;
    });
    final summary = quizzes.isEmpty
        ? 'No quizzes available.'
        : '${quizzes.length} quizzes available.';
    if (_initialAnnouncementPending) {
      _initialAnnouncementPending = false;
      await TtsService.speak(
        '${buildTtsInstructions(studentQuizKeyLabels, screenName: 'Student quizzes')} $summary',
      );
    } else {
      await TtsService.speak(summary);
    }
  }

  Future<void> _openQuiz(Map quiz) async {
    final inProgress = quiz['in_progress_attempt_id'];
    if (!_canOpenQuiz(quiz)) {
      _announceError(
        'Attempt limit reached for ${quiz['title']}. Open attempt history to review your scores.',
      );
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => KeypadConfirmationDialog(
        title: inProgress == null ? 'Start quiz?' : 'Resume quiz?',
        message:
            '${quiz['title']}. ${quiz['attempts_remaining']} attempts remaining. '
            '${quiz['time_limit_minutes'] == null ? 'No per-attempt time limit.' : 'Time limit ${quiz['time_limit_minutes']} minutes.'} '
            'Answers are final after submission and feedback is immediate.',
        confirmLabel: inProgress == null ? 'Start attempt' : 'Resume attempt',
      ),
    );
    if (confirmed != true) return;
    final attempt = await ApiService.startQuizAttempt(quiz['quiz_id'] as int);
    if (!mounted) return;
    if (attempt == null) {
      _announceError('The quiz could not be started. Check its availability.');
      return;
    }
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizAttemptScreen(
          quizTitle: '${quiz['title']}',
          initialAttempt: attempt,
        ),
      ),
    );
    await _load();
  }

  bool _canOpenQuiz(Map quiz) {
    if (quiz['in_progress_attempt_id'] != null) return true;
    final explicit = quiz['can_start_attempt'];
    if (explicit is bool) return explicit;
    return quiz['display_status'] == 'open' &&
        (quiz['attempts_remaining'] as int? ?? 0) > 0;
  }

  Future<void> _history(Map quiz) async {
    final history = await ApiService.getQuizAttemptHistory(
      quiz['quiz_id'] as int,
    );
    if (!mounted || history == null) {
      _announceError('Attempt history could not be loaded.');
      return;
    }
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            QuizHistoryScreen(quizTitle: '${quiz['title']}', history: history),
      ),
    );
  }

  void _announceError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
    TtsService.speak(message);
  }

  void _cycleState(int direction) {
    const states = <String?>[null, 'scheduled', 'open', 'closed'];
    var index = states.indexOf(_stateFilter);
    index = (index + direction) % states.length;
    if (index < 0) index += states.length;
    setState(() => _stateFilter = states[index]);
    TtsService.speak(
      _stateFilter == null
          ? 'All quiz states'
          : 'Showing $_stateFilter quizzes',
    );
    _load();
  }

  void _cycleSubject(int direction) {
    final subjects = <int?>[
      null,
      ..._subjects.map((item) => item['id'] as int),
    ];
    var index = subjects.indexOf(_subjectFilter);
    if (index < 0) index = 0;
    index = (index + direction) % subjects.length;
    if (index < 0) index += subjects.length;
    setState(() => _subjectFilter = subjects[index]);
    final selected = _subjects.cast<Map<String, dynamic>?>().firstWhere(
      (item) => item?['id'] == _subjectFilter,
      orElse: () => null,
    );
    TtsService.speak(
      selected == null ? 'All subjects' : 'Subject ${selected['name']}',
    );
    _load();
  }

  List<Map<String, dynamic>> get _subjects {
    final values = <int, Map<String, dynamic>>{};
    for (final quiz in _quizzes) {
      final id = quiz['subject_id'];
      if (id is int) {
        values[id] = {'id': id, 'name': quiz['subject_name']};
      }
    }
    return values.values.toList();
  }

  @override
  void dispose() {
    _refreshFocus.dispose();
    _stateFilterFocus.dispose();
    _subjectFilterFocus.dispose();
    for (final focus in _openFocuses.values) {
      focus.dispose();
    }
    for (final focus in _historyFocuses.values) {
      focus.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeypadInstructionWrapper(
      screenName: 'Student quizzes',
      labels: studentQuizKeyLabels,
      autoPlay: false,
      actions: {0: () => Navigator.pop(context), 1: _load},
      focusTargets: [
        KeypadFocusTarget(
          node: _refreshFocus,
          label: 'Refresh quizzes',
          onActivate: _load,
        ),
        KeypadFocusTarget(
          node: _stateFilterFocus,
          label:
              'Quiz state filter, ${_stateFilter ?? 'all states'}. Use left or right to change',
          onActivate: () => _cycleState(1),
          onDecrease: () => _cycleState(-1),
          onIncrease: () => _cycleState(1),
        ),
        KeypadFocusTarget(
          node: _subjectFilterFocus,
          label: 'Subject filter. Use left or right to change',
          onActivate: () => _cycleSubject(1),
          onDecrease: () => _cycleSubject(-1),
          onIncrease: () => _cycleSubject(1),
        ),
        for (final quiz in _quizzes) ...[
          if (_canOpenQuiz(quiz))
            KeypadFocusTarget(
              node: _openFocuses.putIfAbsent(
                quiz['quiz_id'] as int,
                () => FocusNode(
                  debugLabel: 'student-open-quiz-${quiz['quiz_id']}',
                ),
              ),
              label:
                  '${quiz['subject_name']}, ${quiz['title']}, ${quiz['display_status']}. '
                  '${quiz['attempts_remaining']} attempts remaining. '
                  '${quiz['in_progress_attempt_id'] == null ? 'Start quiz' : 'Resume quiz'}',
              onActivate: () => _openQuiz(quiz),
            ),
          if ((quiz['attempts_used'] as int) > 0)
            KeypadFocusTarget(
              node: _historyFocuses.putIfAbsent(
                quiz['quiz_id'] as int,
                () => FocusNode(
                  debugLabel: 'student-quiz-history-${quiz['quiz_id']}',
                ),
              ),
              label:
                  'Review ${quiz['title']} attempt history. Highest score ${quiz['highest_score'] ?? 'not available'}',
              onActivate: () => _history(quiz),
            ),
        ],
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Quizzes'),
          actions: [
            IconButton(
              focusNode: _refreshFocus,
              onPressed: _load,
              tooltip: 'Refresh quizzes',
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _load,
                child: ListView(
                  padding: UIUtils.paddingAll(context, 12),
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        DropdownButton<String?>(
                          focusNode: _stateFilterFocus,
                          value: _stateFilter,
                          hint: const Text('All quiz states'),
                          items: const [
                            DropdownMenuItem(
                              value: null,
                              child: Text('All states'),
                            ),
                            DropdownMenuItem(
                              value: 'scheduled',
                              child: Text('Scheduled'),
                            ),
                            DropdownMenuItem(
                              value: 'open',
                              child: Text('Open'),
                            ),
                            DropdownMenuItem(
                              value: 'closed',
                              child: Text('Closed'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() => _stateFilter = value);
                            _load();
                          },
                        ),
                        DropdownButton<int?>(
                          focusNode: _subjectFilterFocus,
                          value: _subjectFilter,
                          hint: const Text('All subjects'),
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('All subjects'),
                            ),
                            ..._subjects.map(
                              (subject) => DropdownMenuItem(
                                value: subject['id'] as int,
                                child: Text('${subject['name']}'),
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() => _subjectFilter = value);
                            _load();
                          },
                        ),
                      ],
                    ),
                    if (_quizzes.isEmpty)
                      Semantics(
                        liveRegion: true,
                        child: const ListTile(
                          leading: Icon(Icons.inbox_outlined),
                          title: Text('No quizzes available'),
                        ),
                      )
                    else
                      ..._quizzes.map(
                        (quiz) => Semantics(
                          label:
                              '${quiz['subject_name']}, ${quiz['title']}. Status ${quiz['display_status']}. ${quiz['attempts_remaining']} attempts remaining.',
                          child: Card(
                            child: ListTile(
                              leading: const Icon(Icons.quiz_outlined),
                              title: Text('${quiz['title']}'),
                              subtitle: Text(
                                '${quiz['subject_name']} · ${quiz['display_status']}\n'
                                '${quiz['description'] ?? 'No description'}\n'
                                '${quiz['attempts_remaining']} attempts remaining'
                                '${quiz['highest_score'] == null ? '' : ' · Highest ${quiz['highest_score']}%'}',
                              ),
                              isThreeLine: true,
                              trailing: Wrap(
                                children: [
                                  if (_canOpenQuiz(quiz))
                                    IconButton(
                                      focusNode: _openFocuses.putIfAbsent(
                                        quiz['quiz_id'] as int,
                                        () => FocusNode(
                                          debugLabel:
                                              'student-open-quiz-${quiz['quiz_id']}',
                                        ),
                                      ),
                                      onPressed: () => _openQuiz(quiz),
                                      tooltip:
                                          quiz['in_progress_attempt_id'] == null
                                          ? 'Start quiz'
                                          : 'Resume quiz',
                                      icon: const Icon(Icons.play_arrow),
                                    ),
                                  if (!_canOpenQuiz(quiz) &&
                                      quiz['display_status'] == 'open' &&
                                      (quiz['attempts_remaining'] as int) == 0)
                                    const Tooltip(
                                      message: 'Attempt limit reached',
                                      child: Icon(Icons.block),
                                    ),
                                  if ((quiz['attempts_used'] as int) > 0)
                                    IconButton(
                                      focusNode: _historyFocuses.putIfAbsent(
                                        quiz['quiz_id'] as int,
                                        () => FocusNode(
                                          debugLabel:
                                              'student-quiz-history-${quiz['quiz_id']}',
                                        ),
                                      ),
                                      onPressed: () => _history(quiz),
                                      tooltip: 'Attempt history and review',
                                      icon: const Icon(Icons.history),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}

class QuizAttemptScreen extends StatefulWidget {
  const QuizAttemptScreen({
    super.key,
    required this.quizTitle,
    required this.initialAttempt,
  });

  final String quizTitle;
  final Map<String, dynamic> initialAttempt;

  @override
  State<QuizAttemptScreen> createState() => _QuizAttemptScreenState();
}

class _QuizAttemptScreenState extends State<QuizAttemptScreen> {
  late Map<String, dynamic> _attempt;
  int? _selectedOptionId;
  Map<String, dynamic>? _feedback;
  bool _submitting = false;
  Timer? _timer;
  Duration? _remaining;
  DateTime? _serverAnchor;
  DateTime? _deadline;
  final Stopwatch _elapsed = Stopwatch();
  final _submitFocus = FocusNode(debugLabel: 'quiz-submit-answer');
  final _nextFocus = FocusNode(debugLabel: 'quiz-next-question');
  final _feedbackFocus = FocusNode(debugLabel: 'quiz-feedback');
  final _returnFocus = FocusNode(debugLabel: 'quiz-return-to-list');
  final List<FocusNode> _optionFocuses = List.generate(
    4,
    (index) => FocusNode(debugLabel: 'quiz-option-${index + 1}'),
  );

  @override
  void initState() {
    super.initState();
    _attempt = widget.initialAttempt;
    _configureTimer();
    if (_attempt['status'] != 'in_progress') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _returnFocus.requestFocus();
      });
    }
  }

  void _configureTimer() {
    final server = DateTime.tryParse('${_attempt['server_time']}');
    final deadline = DateTime.tryParse('${_attempt['deadline_at'] ?? ''}');
    if (server == null || deadline == null) return;
    _serverAnchor = server.toUtc();
    _deadline = deadline.toUtc();
    _elapsed.start();
    _updateRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateRemaining();
    });
  }

  void _updateRemaining() {
    if (!mounted || _serverAnchor == null || _deadline == null) return;
    final authoritativeNow = _serverAnchor!.add(_elapsed.elapsed);
    final remaining = _deadline!.difference(authoritativeNow);
    setState(() {
      _remaining = remaining.isNegative ? Duration.zero : remaining;
    });
    if (remaining.isNegative || remaining == Duration.zero) {
      _timer?.cancel();
      _complete();
    } else if (remaining.inSeconds == 60 || remaining.inSeconds == 300) {
      TtsService.speak('${remaining.inMinutes} minutes remaining');
    }
  }

  Map<String, dynamic>? get _question {
    final value = _attempt['question'];
    return value is Map ? Map<String, dynamic>.from(value) : null;
  }

  void _selectOption(int index) {
    if (_feedback != null || _submitting) return;
    final options = _question?['options'];
    if (options is! List || index >= options.length) return;
    final option = options[index] as Map;
    setState(() => _selectedOptionId = option['quiz_option_id'] as int);
    TtsService.speak('Option ${index + 1} selected. Press 5 to submit.');
  }

  Future<void> _submit() async {
    final question = _question;
    if (question == null || _selectedOptionId == null || _submitting) {
      TtsService.speak('Select one option before submitting.');
      return;
    }
    setState(() => _submitting = true);
    final result = await ApiService.submitQuizAnswer(
      attemptId: _attempt['attempt_id'] as int,
      questionId: question['quiz_question_id'] as int,
      optionId: _selectedOptionId!,
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Answer was not confirmed. Your selection is preserved; retry submission.',
          ),
        ),
      );
      await TtsService.speak(
        'Answer was not accepted yet. Your selection is preserved. Retry submission.',
      );
      return;
    }
    setState(() => _feedback = result);
    final spoken =
        '${result['is_correct'] == true ? 'Correct' : 'Incorrect'}. '
        'Correct answer: ${result['correct_option_text']}. '
        '${result['explanation'] ?? ''}';
    await TtsService.speak(spoken);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _feedbackFocus.requestFocus();
    });
  }

  Future<void> _next() async {
    final next = _feedback?['next_question'];
    if (next == null) {
      await _complete();
      return;
    }
    setState(() {
      _attempt = {..._attempt, 'question': next};
      _selectedOptionId = null;
      _feedback = null;
    });
    await TtsService.speak('Next question');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _optionFocuses.first.requestFocus();
    });
  }

  Future<void> _complete() async {
    if (_attempt['status'] != 'in_progress') return;
    final result = await ApiService.completeQuizAttempt(
      _attempt['attempt_id'] as int,
    );
    if (!mounted || result == null) return;
    _timer?.cancel();
    setState(() => _attempt = result);
    final message =
        'Attempt ${result['status']}. Score ${result['correct_count']} of ${result['total_questions']}, ${result['percentage_score']} percent.';
    await TtsService.speak(message);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _returnFocus.requestFocus();
    });
  }

  String get _remainingText {
    final value = _remaining;
    if (value == null) return 'No time limit';
    final minutes = value.inMinutes;
    final seconds = value.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds remaining';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _elapsed.stop();
    _submitFocus.dispose();
    _nextFocus.dispose();
    _feedbackFocus.dispose();
    _returnFocus.dispose();
    for (final node in _optionFocuses) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final question = _question;
    final options = question?['options'] as List? ?? const [];
    final completed = _attempt['status'] != 'in_progress';
    return KeypadInstructionWrapper(
      screenName: 'Quiz attempt, ${widget.quizTitle}',
      labels: {
        if (completed) 0: 'Return to quizzes',
        1: 'Select option 1',
        2: 'Select option 2',
        3: 'Select option 3',
        4: 'Select option 4',
        5: 'Submit selected answer',
        6: completed ? 'Return to quizzes' : 'Next question or view result',
      },
      actions: {
        if (completed) 0: () => Navigator.pop(context),
        for (var index = 0; index < 4; index++)
          index + 1: () => _selectOption(index),
        5: _submit,
        6: completed ? () => Navigator.pop(context) : _next,
      },
      focusTargets: [
        if (completed)
          KeypadFocusTarget(
            node: _returnFocus,
            label: 'Return to quizzes',
            onActivate: () => Navigator.pop(context),
          ),
        for (var index = 0; index < options.length; index++)
          KeypadFocusTarget(
            node: _optionFocuses[index],
            label: 'Option ${index + 1}, ${options[index]['option_text']}',
            onActivate: () => _selectOption(index),
          ),
        KeypadFocusTarget(
          node: _submitFocus,
          label: 'Submit selected answer',
          onActivate: _submit,
          isEnabled: () => _feedback == null && !_submitting,
        ),
        KeypadFocusTarget(
          node: _feedbackFocus,
          label: _feedback == null
              ? 'Answer feedback'
              : '${_feedback!['is_correct'] == true ? 'Correct' : 'Incorrect'}. Correct answer ${_feedback!['correct_option_text']}',
        ),
        KeypadFocusTarget(
          node: _nextFocus,
          label: _feedback?['next_question'] == null
              ? 'View result'
              : 'Next question',
          onActivate: _next,
          isEnabled: () => _feedback != null,
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.quizTitle),
          automaticallyImplyLeading: completed,
        ),
        body: SafeArea(
          child: ListView(
            padding: UIUtils.paddingAll(context, 16),
            children: [
              Semantics(
                liveRegion: true,
                label: _remainingText,
                child: Row(
                  children: [
                    const Icon(Icons.timer_outlined),
                    const SizedBox(width: 8),
                    Text(_remainingText),
                  ],
                ),
              ),
              if (completed) ...[
                Semantics(
                  liveRegion: true,
                  child: Card(
                    child: ListTile(
                      leading: const Icon(Icons.emoji_events_outlined),
                      title: const Text('Attempt complete'),
                      subtitle: Text(
                        '${_attempt['correct_count']} of ${_attempt['total_questions']} correct\n'
                        '${_attempt['percentage_score']} percent',
                      ),
                    ),
                  ),
                ),
                ElevatedButton(
                  focusNode: _returnFocus,
                  onPressed: () => Navigator.pop(context),
                  child: const Text('0: Return to quizzes'),
                ),
              ] else if (question != null) ...[
                Text(
                  'Question ${(_attempt['answered_count'] as int? ?? 0) + 1} of ${_attempt['total_questions']}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  '${question['question_text']}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                RadioGroup<int>(
                  groupValue: _selectedOptionId,
                  onChanged: (value) {
                    if (_feedback != null || value == null) return;
                    final index = options.indexWhere(
                      (option) => option['quiz_option_id'] == value,
                    );
                    if (index >= 0) _selectOption(index);
                  },
                  child: Column(
                    children: [
                      for (var index = 0; index < options.length; index++)
                        Semantics(
                          selected:
                              _selectedOptionId ==
                              options[index]['quiz_option_id'],
                          button: true,
                          label:
                              'Option ${index + 1}, ${options[index]['option_text']}',
                          child: Card(
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                color:
                                    _selectedOptionId ==
                                        options[index]['quiz_option_id']
                                    ? UIUtils.accentColor
                                    : Colors.transparent,
                                width: 3,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: RadioListTile<int>(
                              focusNode: _optionFocuses[index],
                              value: options[index]['quiz_option_id'] as int,
                              enabled: _feedback == null,
                              title: Text(
                                '${index + 1}. ${options[index]['option_text']}',
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  focusNode: _submitFocus,
                  onPressed: _feedback == null && !_submitting ? _submit : null,
                  icon: _submitting
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check),
                  label: const Text('5: Submit answer'),
                ),
                if (_feedback != null)
                  Focus(
                    focusNode: _feedbackFocus,
                    child: Semantics(
                      liveRegion: true,
                      label:
                          '${_feedback!['is_correct'] == true ? 'Correct' : 'Incorrect'}. '
                          'Correct answer ${_feedback!['correct_option_text']}. '
                          '${_feedback!['explanation'] ?? ''}',
                      child: Card(
                        color: _feedback!['is_correct'] == true
                            ? Colors.green.shade100
                            : Colors.orange.shade100,
                        child: ListTile(
                          leading: Icon(
                            _feedback!['is_correct'] == true
                                ? Icons.check_circle
                                : Icons.cancel,
                            color: Colors.black,
                          ),
                          title: Text(
                            _feedback!['is_correct'] == true
                                ? 'Correct'
                                : 'Incorrect',
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            'You selected: ${_feedback!['selected_option_text']}\n'
                            'Correct answer: ${_feedback!['correct_option_text']}\n'
                            '${_feedback!['explanation'] ?? 'No explanation provided.'}',
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                  ),
                if (_feedback != null)
                  ElevatedButton(
                    focusNode: _nextFocus,
                    onPressed: _next,
                    child: Text(
                      _feedback!['next_question'] == null
                          ? '6: View result'
                          : '6: Next question',
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class QuizHistoryScreen extends StatelessWidget {
  const QuizHistoryScreen({
    super.key,
    required this.quizTitle,
    required this.history,
  });

  final String quizTitle;
  final Map<String, dynamic> history;

  @override
  Widget build(BuildContext context) {
    final attempts = history['attempts'] as List? ?? const [];
    return KeypadInstructionWrapper(
      screenName:
          '$quizTitle attempt history. Highest score ${history['highest_score'] ?? 'not available'}',
      labels: const {0: 'Go back'},
      actions: {0: () => Navigator.pop(context)},
      child: Scaffold(
        appBar: AppBar(title: Text('$quizTitle history')),
        body: ListView(
          padding: UIUtils.paddingAll(context, 12),
          children: [
            Semantics(
              liveRegion: true,
              child: Text(
                'Highest score: ${history['highest_score'] ?? 'No completed attempt'}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            if (attempts.isEmpty)
              const ListTile(title: Text('No attempts yet'))
            else
              ...attempts.map(
                (attempt) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.history),
                    title: Text('Attempt ${attempt['attempt_number']}'),
                    subtitle: Text(
                      '${attempt['status']} · ${attempt['correct_count']} of ${attempt['total_questions']} correct · ${attempt['percentage_score']}%',
                    ),
                    trailing: attempt['status'] == 'in_progress'
                        ? null
                        : const Icon(Icons.chevron_right),
                    onTap: attempt['status'] == 'in_progress'
                        ? null
                        : () async {
                            final review = await ApiService.getQuizReview(
                              attempt['attempt_id'] as int,
                            );
                            if (!context.mounted || review == null) return;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    QuizReviewScreen(review: review),
                              ),
                            );
                          },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class QuizReviewScreen extends StatelessWidget {
  const QuizReviewScreen({super.key, required this.review});

  final Map<String, dynamic> review;

  @override
  Widget build(BuildContext context) {
    final questions = review['questions'] as List? ?? const [];
    return KeypadInstructionWrapper(
      screenName:
          'Attempt review. ${questions.length} questions. Use up and down to review each answer.',
      labels: const {0: 'Go back'},
      actions: {0: () => Navigator.pop(context)},
      child: Scaffold(
        appBar: AppBar(title: const Text('Attempt review')),
        body: ListView.builder(
          padding: UIUtils.paddingAll(context, 12),
          itemCount: questions.length,
          itemBuilder: (context, index) {
            final question = questions[index] as Map;
            final correct = question['is_correct'] == true;
            final announcement =
                'Question ${index + 1}. ${correct ? 'Correct' : 'Incorrect'}. '
                'Selected ${question['selected_option_text'] ?? 'No answer'}. '
                'Correct answer ${question['correct_option_text']}. '
                '${question['explanation'] ?? 'No explanation provided.'}';
            return Semantics(
              label: announcement,
              button: true,
              child: Card(
                child: ListTile(
                  onTap: () => TtsService.speak(announcement),
                  leading: Icon(
                    correct ? Icons.check_circle : Icons.cancel,
                    color: correct
                        ? Colors.green.shade800
                        : Colors.red.shade800,
                  ),
                  title: Text('${index + 1}. ${question['question_text']}'),
                  subtitle: Text(
                    'Your answer: ${question['selected_option_text'] ?? 'Unanswered'}\n'
                    'Correct answer: ${question['correct_option_text']}\n'
                    '${question['explanation'] ?? 'No explanation provided.'}',
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class AccessibleQuestionEditorDialog extends StatefulWidget {
  const AccessibleQuestionEditorDialog({super.key, this.initialQuestion});

  final Map<String, dynamic>? initialQuestion;

  @override
  State<AccessibleQuestionEditorDialog> createState() =>
      _AccessibleQuestionEditorDialogState();
}

class _AccessibleQuestionEditorDialogState
    extends State<AccessibleQuestionEditorDialog> {
  late final TextEditingController _question;
  late final TextEditingController _explanation;
  late final List<TextEditingController> _options;
  final _navigationController = KeypadNavigationController();
  final _questionFocus = FocusNode(debugLabel: 'bank-question-text');
  final _explanationFocus = FocusNode(debugLabel: 'bank-question-explanation');
  final _correctFocus = FocusNode(debugLabel: 'bank-question-correct-answer');
  final _cancelFocus = FocusNode(debugLabel: 'bank-question-cancel');
  final _saveFocus = FocusNode(debugLabel: 'bank-question-save');
  late final List<FocusNode> _optionFocuses;
  int? _correct;
  String? _error;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialQuestion;
    final initialOptions = initial?['options'] as List? ?? const [];
    _question = TextEditingController(
      text: initial?['question_text']?.toString() ?? '',
    );
    _explanation = TextEditingController(
      text: initial?['explanation']?.toString() ?? '',
    );
    _options = List.generate(
      4,
      (index) => TextEditingController(
        text: index < initialOptions.length
            ? initialOptions[index]['option_text']?.toString() ?? ''
            : '',
      ),
    );
    _optionFocuses = List.generate(
      4,
      (index) => FocusNode(debugLabel: 'bank-question-option-${index + 1}'),
    );
    final correctIndex = initialOptions.indexWhere(
      (option) => option['is_correct'] == true,
    );
    if (correctIndex >= 0) _correct = correctIndex;
  }

  void _save() {
    final question = _question.text.trim();
    final options = _options
        .map((controller) => controller.text.trim())
        .toList();
    if (question.isEmpty ||
        options.any((option) => option.isEmpty) ||
        options.map((option) => option.toLowerCase()).toSet().length != 4 ||
        _correct == null) {
      setState(() {
        _error =
            'Enter a question, four different non-empty options, and then choose the correct answer.';
      });
      TtsService.speak(_error!);
      return;
    }
    Navigator.pop(context, {
      'question_text': question,
      'options': options,
      'correct_option_index': _correct!,
      'explanation': _explanation.text.trim().isEmpty
          ? null
          : _explanation.text.trim(),
    });
  }

  @override
  void dispose() {
    _question.dispose();
    _explanation.dispose();
    for (final controller in _options) {
      controller.dispose();
    }
    for (final focus in _optionFocuses) {
      focus.dispose();
    }
    _questionFocus.dispose();
    _explanationFocus.dispose();
    _correctFocus.dispose();
    _cancelFocus.dispose();
    _saveFocus.dispose();
    super.dispose();
  }

  void _cycleCorrect(int direction) {
    final current = _correct ?? (direction > 0 ? -1 : 0);
    var next = (current + direction) % 4;
    if (next < 0) next += 4;
    setState(() => _correct = next);
    final text = _options[next].text.trim();
    TtsService.speak(
      'Option ${next + 1} selected as correct answer${text.isEmpty ? '' : ', $text'}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.initialQuestion == null
        ? 'Create bank question'
        : 'Edit bank question';
    return KeypadInstructionWrapper(
      screenName: title,
      labels: const {0: 'Cancel', 9: 'Save question'},
      actions: {0: () => Navigator.pop(context), 9: _save},
      navigationController: _navigationController,
      focusTargets: [
        KeypadFocusTarget(
          node: _questionFocus,
          label: 'Question text. Press OK to edit',
          isTextField: true,
        ),
        for (var index = 0; index < 4; index++)
          KeypadFocusTarget(
            node: _optionFocuses[index],
            label: 'Option ${index + 1}. Press OK to edit',
            isTextField: true,
          ),
        KeypadFocusTarget(
          node: _correctFocus,
          label: _correct == null
              ? 'Correct answer not selected. Use left or right to choose'
              : 'Option ${_correct! + 1} is the correct answer. Use left or right to change',
          onActivate: () => _cycleCorrect(1),
          onDecrease: () => _cycleCorrect(-1),
          onIncrease: () => _cycleCorrect(1),
        ),
        KeypadFocusTarget(
          node: _explanationFocus,
          label: 'Optional answer explanation. Press OK to edit',
          isTextField: true,
        ),
        KeypadFocusTarget(
          node: _cancelFocus,
          label: 'Cancel question',
          onActivate: () => Navigator.pop(context),
        ),
        KeypadFocusTarget(
          node: _saveFocus,
          label: 'Save question',
          onActivate: _save,
        ),
      ],
      child: AlertDialog(
        insetPadding: const EdgeInsets.all(8),
        title: Text(title),
        contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Complete the question and all four options first. Then choose the correct answer in the separate selector below.',
                ),
                const SizedBox(height: 12),
                if (_error != null)
                  Semantics(liveRegion: true, child: Text(_error!)),
                TextField(
                  controller: _question,
                  focusNode: _questionFocus,
                  onTap: () =>
                      _navigationController.enterTextEditing(_questionFocus),
                  decoration: const InputDecoration(labelText: 'Question text'),
                  minLines: 2,
                  maxLines: 4,
                ),
                const SizedBox(height: 10),
                for (var index = 0; index < 4; index++) ...[
                  TextField(
                    controller: _options[index],
                    focusNode: _optionFocuses[index],
                    onTap: () => _navigationController.enterTextEditing(
                      _optionFocuses[index],
                    ),
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: 'Option ${index + 1}',
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                DropdownButtonFormField<int>(
                  key: ValueKey(_correct),
                  focusNode: _correctFocus,
                  initialValue: _correct,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Which answer is correct?',
                    prefixIcon: Icon(Icons.check_circle_outline),
                  ),
                  hint: const Text('Choose the correct option'),
                  items: List.generate(
                    4,
                    (index) => DropdownMenuItem(
                      value: index,
                      child: Text(
                        'Option ${index + 1}: ${_options[index].text.trim().isEmpty ? 'Not filled in yet' : _options[index].text.trim()}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() => _correct = value);
                    if (value != null) {
                      TtsService.speak(
                        'Option ${value + 1} selected as correct answer',
                      );
                    }
                  },
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _explanation,
                  focusNode: _explanationFocus,
                  onTap: () =>
                      _navigationController.enterTextEditing(_explanationFocus),
                  decoration: const InputDecoration(
                    labelText: 'Explanation (optional)',
                  ),
                  minLines: 2,
                  maxLines: 4,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            focusNode: _cancelFocus,
            onPressed: () => Navigator.pop(context),
            child: const Text('0: Cancel'),
          ),
          ElevatedButton(
            focusNode: _saveFocus,
            onPressed: _save,
            child: const Text('9: Save question'),
          ),
        ],
      ),
    );
  }
}

class AccessibleQuizEditorDialog extends StatefulWidget {
  const AccessibleQuizEditorDialog({super.key});

  @override
  State<AccessibleQuizEditorDialog> createState() =>
      _AccessibleQuizEditorDialogState();
}

class _AccessibleQuizEditorDialogState
    extends State<AccessibleQuizEditorDialog> {
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _attempts = TextEditingController(text: '1');
  final _timeLimit = TextEditingController();
  final _navigationController = KeypadNavigationController();
  final _titleFocus = FocusNode(debugLabel: 'quiz-title');
  final _descriptionFocus = FocusNode(debugLabel: 'quiz-description');
  final _attemptsFocus = FocusNode(debugLabel: 'quiz-attempt-limit');
  final _timeLimitFocus = FocusNode(debugLabel: 'quiz-time-limit');
  final _opensFocus = FocusNode(debugLabel: 'quiz-opens-at');
  final _closesFocus = FocusNode(debugLabel: 'quiz-closes-at');
  final _shuffleQuestionsFocus = FocusNode(
    debugLabel: 'quiz-shuffle-questions',
  );
  final _shuffleOptionsFocus = FocusNode(debugLabel: 'quiz-shuffle-options');
  final _cancelFocus = FocusNode(debugLabel: 'quiz-cancel');
  final _saveFocus = FocusNode(debugLabel: 'quiz-save');
  DateTime? _opensAt;
  DateTime? _closesAt;
  bool _shuffleQuestions = false;
  bool _shuffleOptions = false;
  String? _error;

  String _dateTimeLabel(DateTime? value, String emptyLabel) {
    if (value == null) return emptyLabel;
    final local = value.toLocal();
    final minute = local.minute.toString().padLeft(2, '0');
    return '${local.day}/${local.month}/${local.year} at ${local.hour}:$minute';
  }

  Future<void> _pickOpeningTime() async {
    await TtsService.speak(
      'Set opening time. First choose a date, then choose a time. Use the direction keys and OK.',
    );
    final value = await _pickDateTime(_opensAt);
    if (value == null || !mounted) return;
    setState(() => _opensAt = value);
    await TtsService.speak('Opening time set to ${_dateTimeLabel(value, '')}');
    _opensFocus.requestFocus();
  }

  Future<void> _pickClosingTime() async {
    await TtsService.speak(
      'Set closing time. First choose a date, then choose a time. Use the direction keys and OK.',
    );
    final value = await _pickDateTime(_closesAt);
    if (value == null || !mounted) return;
    setState(() => _closesAt = value);
    await TtsService.speak('Closing time set to ${_dateTimeLabel(value, '')}');
    _closesFocus.requestFocus();
  }

  Future<DateTime?> _pickDateTime(DateTime? initial) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: initial ?? now,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 730)),
    );
    if (date == null || !mounted) return null;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial ?? now),
    );
    if (time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  void _save() {
    final attempts = int.tryParse(_attempts.text.trim());
    final timeLimit = _timeLimit.text.trim().isEmpty
        ? null
        : int.tryParse(_timeLimit.text.trim());
    if (_title.text.trim().isEmpty ||
        attempts == null ||
        attempts < 1 ||
        attempts > 20 ||
        (_timeLimit.text.trim().isNotEmpty &&
            (timeLimit == null || timeLimit < 1 || timeLimit > 1440)) ||
        (_opensAt != null &&
            _closesAt != null &&
            !_opensAt!.isBefore(_closesAt!))) {
      setState(() => _error = 'Check the title, limits, and schedule.');
      TtsService.speak(_error!);
      return;
    }
    Navigator.pop(context, {
      'title': _title.text.trim(),
      'description': _description.text.trim().isEmpty
          ? null
          : _description.text.trim(),
      'attempt_limit': attempts,
      'opens_at': _opensAt?.toUtc().toIso8601String(),
      'closes_at': _closesAt?.toUtc().toIso8601String(),
      'time_limit_minutes': timeLimit,
      'shuffle_questions': _shuffleQuestions,
      'shuffle_options': _shuffleOptions,
    });
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _attempts.dispose();
    _timeLimit.dispose();
    _titleFocus.dispose();
    _descriptionFocus.dispose();
    _attemptsFocus.dispose();
    _timeLimitFocus.dispose();
    _opensFocus.dispose();
    _closesFocus.dispose();
    _shuffleQuestionsFocus.dispose();
    _shuffleOptionsFocus.dispose();
    _cancelFocus.dispose();
    _saveFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeypadInstructionWrapper(
      screenName: 'Create quiz draft',
      labels: const {0: 'Cancel', 8: 'Save draft'},
      actions: {0: () => Navigator.pop(context), 8: _save},
      navigationController: _navigationController,
      focusTargets: [
        KeypadFocusTarget(
          node: _titleFocus,
          label: 'Quiz title. Press OK to edit',
          isTextField: true,
        ),
        KeypadFocusTarget(
          node: _descriptionFocus,
          label: 'Optional quiz description. Press OK to edit',
          isTextField: true,
        ),
        KeypadFocusTarget(
          node: _attemptsFocus,
          label: 'Attempt limit, currently ${_attempts.text}. Press OK to edit',
          isTextField: true,
        ),
        KeypadFocusTarget(
          node: _timeLimitFocus,
          label:
              'Optional time limit in minutes, ${_timeLimit.text.isEmpty ? 'not set' : _timeLimit.text}. Press OK to edit',
          isTextField: true,
        ),
        KeypadFocusTarget(
          node: _opensFocus,
          label:
              '${_dateTimeLabel(_opensAt, 'No opening time set')}. Press OK to set it. Use left to clear it',
          onActivate: _pickOpeningTime,
          onDecrease: () {
            setState(() => _opensAt = null);
            TtsService.speak('Opening time cleared');
          },
          onIncrease: _pickOpeningTime,
        ),
        KeypadFocusTarget(
          node: _closesFocus,
          label:
              '${_dateTimeLabel(_closesAt, 'No closing time set')}. Press OK to set it. Use left to clear it',
          onActivate: _pickClosingTime,
          onDecrease: () {
            setState(() => _closesAt = null);
            TtsService.speak('Closing time cleared');
          },
          onIncrease: _pickClosingTime,
        ),
        KeypadFocusTarget(
          node: _shuffleQuestionsFocus,
          label:
              'Shuffle questions ${_shuffleQuestions ? 'on' : 'off'}. Press OK or left or right to toggle',
          onActivate: () =>
              setState(() => _shuffleQuestions = !_shuffleQuestions),
          onDecrease: () =>
              setState(() => _shuffleQuestions = !_shuffleQuestions),
          onIncrease: () =>
              setState(() => _shuffleQuestions = !_shuffleQuestions),
        ),
        KeypadFocusTarget(
          node: _shuffleOptionsFocus,
          label:
              'Shuffle answer options ${_shuffleOptions ? 'on' : 'off'}. Press OK or left or right to toggle',
          onActivate: () => setState(() => _shuffleOptions = !_shuffleOptions),
          onDecrease: () => setState(() => _shuffleOptions = !_shuffleOptions),
          onIncrease: () => setState(() => _shuffleOptions = !_shuffleOptions),
        ),
        KeypadFocusTarget(
          node: _cancelFocus,
          label: 'Cancel quiz creation',
          onActivate: () => Navigator.pop(context),
        ),
        KeypadFocusTarget(
          node: _saveFocus,
          label: 'Save quiz draft',
          onActivate: _save,
        ),
      ],
      child: AlertDialog(
        insetPadding: const EdgeInsets.all(8),
        title: const Text('Create quiz draft'),
        contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Semantics(
                  label:
                      'Use up and down to move through quiz settings. Press OK to edit text fields. Opening and closing times are optional.',
                  child: const Text(
                    'Opening and closing times are optional. Select either time control to choose a date and then a time.',
                  ),
                ),
                const SizedBox(height: 10),
                if (_error != null)
                  Semantics(liveRegion: true, child: Text(_error!)),
                TextField(
                  controller: _title,
                  focusNode: _titleFocus,
                  onTap: () =>
                      _navigationController.enterTextEditing(_titleFocus),
                  decoration: const InputDecoration(labelText: 'Quiz title'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _description,
                  focusNode: _descriptionFocus,
                  onTap: () =>
                      _navigationController.enterTextEditing(_descriptionFocus),
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _attempts,
                  focusNode: _attemptsFocus,
                  onTap: () =>
                      _navigationController.enterTextEditing(_attemptsFocus),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Attempt limit, 1 to 20',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _timeLimit,
                  focusNode: _timeLimitFocus,
                  onTap: () =>
                      _navigationController.enterTextEditing(_timeLimitFocus),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Time limit in minutes (optional)',
                  ),
                ),
                const SizedBox(height: 10),
                Semantics(
                  button: true,
                  label:
                      '${_dateTimeLabel(_opensAt, 'No opening time set')}. Press OK to set opening time. Left clears it.',
                  child: ListTile(
                    focusNode: _opensFocus,
                    leading: const Icon(Icons.event_available),
                    title: Text(_dateTimeLabel(_opensAt, 'No opening time')),
                    subtitle: const Text('Optional · choose date, then time'),
                    trailing: const Icon(Icons.edit_calendar),
                    onTap: _pickOpeningTime,
                  ),
                ),
                Semantics(
                  button: true,
                  label:
                      '${_dateTimeLabel(_closesAt, 'No closing time set')}. Press OK to set closing time. Left clears it.',
                  child: ListTile(
                    focusNode: _closesFocus,
                    leading: const Icon(Icons.event_busy),
                    title: Text(_dateTimeLabel(_closesAt, 'No closing time')),
                    subtitle: const Text(
                      'Optional · must be after opening time',
                    ),
                    trailing: const Icon(Icons.edit_calendar),
                    onTap: _pickClosingTime,
                  ),
                ),
                SwitchListTile(
                  focusNode: _shuffleQuestionsFocus,
                  value: _shuffleQuestions,
                  onChanged: (value) =>
                      setState(() => _shuffleQuestions = value),
                  title: const Text('Shuffle questions once per attempt'),
                ),
                SwitchListTile(
                  focusNode: _shuffleOptionsFocus,
                  value: _shuffleOptions,
                  onChanged: (value) => setState(() => _shuffleOptions = value),
                  title: const Text('Shuffle options once per attempt'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            focusNode: _cancelFocus,
            onPressed: () => Navigator.pop(context),
            child: const Text('0: Cancel'),
          ),
          ElevatedButton(
            focusNode: _saveFocus,
            onPressed: _save,
            child: const Text('8: Save draft'),
          ),
        ],
      ),
    );
  }
}
