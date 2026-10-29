import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/keypad_date_time_dialog.dart';

import '../services/api_service.dart';
import '../services/tts_service.dart';
import '../utils/keypad_actions.dart';
import '../utils/ui_utils.dart';
import '../widgets/key_instruction_wrapper.dart';
import '../widgets/keypad_confirmation_dialog.dart';
import '../widgets/quiz_extra_time_dialog.dart';
import 'question_revisions_screen.dart';

void _revealQuizError(GlobalKey key) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(context, alignment: 0.1);
    }
  });
}

String _attemptsText(Map quiz) => quiz['mode'] == 'practice'
    ? 'Unlimited practice attempts. Not graded.'
    : '${quiz['attempts_remaining']} attempts remaining.';

String _quizFeedbackText(Map quiz) {
  switch (quiz['feedback_policy']) {
    case 'after_completion':
      return 'Answer feedback and scores are released after final submission.';
    case 'scheduled':
      return 'Feedback and scores require final submission and the scheduled release: ${quiz['feedback_release_at']} UTC.';
    case 'score_only':
      return 'Only the score is released after final submission. Answer keys and explanations are not released.';
    default:
      return 'Feedback follows each confirmed saved answer.';
  }
}

String _attemptResultText(Map attempt) {
  if (attempt['is_graded'] == false) {
    return 'Practice, not an academic grade. ${attempt['correct_count']} of ${attempt['total_questions']} correct in this practice.';
  }
  if (attempt['score_released'] == false) {
    return 'Score not released. ${attempt['feedback_message'] ?? 'Check the release policy.'}';
  }
  return 'Score ${attempt['correct_count']} of ${attempt['total_questions']}, ${attempt['percentage_score']} percent.';
}

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
      navigationSections: 'the available actions and cancel',
      labels: {
        0: 'Cancel',
        for (var index = 0; index < widget.actions.length && index < 5; index++)
          index + 1: widget.actions[index].label,
      },
      actions: {
        0: () => select(null),
        for (var index = 0; index < widget.actions.length && index < 5; index++)
          index + 1: () => select(widget.actions[index].value),
      },
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
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              for (var index = 0; index < widget.actions.length; index++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ElevatedButton.icon(
                    focusNode: _focuses[index],
                    onPressed: () => select(widget.actions[index].value),
                    icon: Icon(widget.actions[index].icon),
                    label: Text(
                      '${index < 5 ? '${index + 1}: ' : ''}${widget.actions[index].label}',
                    ),
                  ),
                ),
              TextButton(
                focusNode: _cancelFocus,
                onPressed: () => select(null),
                child: const Text('0: Cancel'),
              ),
            ],
          ),
        ),
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
  final _createPracticeFocus = FocusNode(debugLabel: 'quiz-create-practice');
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
  bool _creatingQuiz = false;
  bool _quizSaveUncertain = false;
  bool _savingQuestion = false;
  final _errorKey = GlobalKey();
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool preserveError = false}) async {
    if (mounted) setState(() => _loading = true);
    final query = Uri(
      queryParameters: {
        'class_id': '${widget.classId}',
        'subject_id': '${widget.subjectId}',
        'search': _searchController.text,
      },
    ).query;
    final results = await Future.wait([
      ApiService.getResult(
        '/question-bank?$query',
        useAuth: true,
        requestTimeout: const Duration(seconds: 20),
      ),
      ApiService.getResult(
        '/teacher/quizzes?class_id=${widget.classId}&subject_id=${widget.subjectId}',
        useAuth: true,
        requestTimeout: const Duration(seconds: 20),
      ),
    ]);
    if (!mounted) return;
    if (results.any((result) => !result.isSuccess || result.data is! List)) {
      setState(() => _loading = false);
      _showError(
        'The question bank or quiz list could not be refreshed. Try Refresh again before creating another quiz.',
      );
      return;
    }
    setState(() {
      _questions = results[0].data as List;
      _quizzes = results[1].data as List;
      _loading = false;
      if (!preserveError) _error = null;
      _quizSaveUncertain = false;
    });
    final summary =
        '${_questions.length} bank questions and ${_quizzes.length} quizzes loaded.';
    if (_initialAnnouncementPending) {
      _initialAnnouncementPending = false;
      await TtsService.speak(
        '${buildTtsInstructions(teacherQuizKeyLabels, screenName: 'Teacher quizzes for ${widget.className}, ${widget.subjectName}')} '
        'Use the D-pad to explore bank search and saved questions, quiz drafts, published quizzes and results. $summary',
      );
    } else {
      if (_error != null) _revealQuizError(_errorKey);
      await TtsService.speak(_error ?? summary);
    }
  }

  Future<void> _createQuestion() async {
    if (_savingQuestion) return;
    _savingQuestion = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final account = prefs.getInt('user_id');
      if (!mounted) return;
      final value = await showDialog<Map<String, dynamic>>(
        context: context,
        barrierDismissible: false,
        builder: (_) => const AccessibleQuestionEditorDialog(),
      );
      if (value == null) return;
      final response = await ApiService.postResult(
        '/question-bank',
        {...value, 'class_id': widget.classId, 'subject_id': widget.subjectId},
        useAuth: true,
        requireJsonObject: true,
        canSend: () =>
            mounted &&
            token != null &&
            prefs.getString('token') == token &&
            prefs.getInt('user_id') == account,
      );
      final result = response.data;
      if (!mounted) return;
      if (prefs.getString('token') != token ||
          prefs.getInt('user_id') != account) {
        _showError(
          'Your account changed. Reopen the question bank before continuing.',
        );
        return;
      }
      if (!response.isSuccess ||
          result?['question_id'] is! int ||
          result?['revision'] != 1 ||
          result?['question_text'] != value['question_text']) {
        _showError(
          '${response.failure?.message ?? (result?['revision'] == null && response.isSuccess ? 'The server returned a question without a revision. Ask the administrator to update the quiz backend.' : 'The saved question did not match.')} '
          'Question save could not be confirmed. Check the bank and refresh before retrying; do not create a duplicate.',
        );
        if (response.isSuccess) await _load(preserveError: true);
        return;
      }
      await TtsService.speak(
        'Question saved. Editing this bank question later will not change existing quizzes.',
      );
      await _load();
    } finally {
      _savingQuestion = false;
    }
  }

  Future<void> _editQuestion(Map question) async {
    if (_savingQuestion) return;
    if (question['revision'] is! int) {
      _showError(
        'This server did not supply a question revision. Ask the administrator to update the quiz backend before editing.',
      );
      return;
    }
    _savingQuestion = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final account = prefs.getInt('user_id');
      if (!mounted) return;
      bool sameAccount() =>
          mounted &&
          token != null &&
          prefs.getString('token') == token &&
          prefs.getInt('user_id') == account;
      final value = await showDialog<Map<String, dynamic>>(
        context: context,
        barrierDismissible: false,
        builder: (_) => AccessibleQuestionEditorDialog(
          initialQuestion: Map<String, dynamic>.from(question),
        ),
      );
      if (value == null) return;
      final response = await ApiService.putResult(
        '/question-bank/${question['question_id']}',
        {
          ...value,
          'class_id': widget.classId,
          'subject_id': widget.subjectId,
          'expected_revision': question['revision'],
        },
        useAuth: true,
        canSend: sameAccount,
      );
      final result = response.data;
      if (!mounted) return;
      if (!sameAccount()) {
        _showError(
          'Your account changed. Reopen the question bank before continuing.',
        );
        return;
      }
      if (!response.isSuccess ||
          result?['question_id'] != question['question_id'] ||
          result?['revision'] != (question['revision'] as int? ?? 0) + 1 ||
          result?['question_text'] != value['question_text']) {
        _showError(
          '${response.failure?.message ?? 'The saved revision did not match.'} The bank question could not be confirmed updated. Refresh and review its current revision before retrying.',
        );
        if (response.isSuccess) await _load(preserveError: true);
        return;
      }
      await TtsService.speak(
        'Bank question updated. Existing quiz snapshots were not changed.',
      );
      await _load();
    } finally {
      _savingQuestion = false;
    }
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
    if (action == 'revisions') {
      await Navigator.push<void>(
        context,
        MaterialPageRoute(
          builder: (_) => QuestionRevisionsScreen(
            questionId: question['question_id'] as int,
          ),
        ),
      );
      return;
    }
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
        title:
            'Actions for ${question['spoken_question_text'] ?? question['question_text']}',
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
          const AccessibleAction(
            value: 'revisions',
            label: 'Read question revision history',
            icon: Icons.history,
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

  Future<void> _createQuiz({bool practice = false}) async {
    if (_creatingQuiz) return;
    if (_quizSaveUncertain) {
      _showError(
        'Refresh and review the quiz list before creating another draft.',
      );
      return;
    }
    _creatingQuiz = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final account = prefs.getInt('user_id');
      if (!mounted) return;
      final value = await showDialog<Map<String, dynamic>>(
        context: context,
        barrierDismissible: false,
        builder: (_) => AccessibleQuizEditorDialog(practice: practice),
      );
      if (value == null) return;
      final response = await ApiService.postResult(
        '/teacher/quizzes',
        {...value, 'class_id': widget.classId, 'subject_id': widget.subjectId},
        useAuth: true,
        requireJsonObject: true,
        canSend: () =>
            token != null &&
            prefs.getString('token') == token &&
            prefs.getInt('user_id') == account,
      );
      final result = response.data;
      if (!mounted) return;
      if (!response.isSuccess ||
          prefs.getString('token') != token ||
          prefs.getInt('user_id') != account ||
          result?['quiz_id'] is! int ||
          result?['status'] != 'draft') {
        _quizSaveUncertain = true;
        _showError(
          '${response.failure?.message ?? 'The saved draft did not match.'} Draft save could not be confirmed. Refresh the quiz list before creating another draft.',
        );
        return;
      }
      await TtsService.speak('Quiz draft saved');
      if (!mounted) return;
      await _buildDraft(result!['quiz_id'] as int);
    } finally {
      _creatingQuiz = false;
    }
  }

  Future<void> _buildDraft(int quizId) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => GuidedQuizDraftScreen(
          quizId: quizId,
          classId: widget.classId,
          subjectId: widget.subjectId,
          onPublish: _publish,
        ),
      ),
    );
    if (!mounted) return;
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
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final account = prefs.getInt('user_id');
    if (!mounted) return;
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
    final response = await ApiService.postResult(
      '/teacher/quizzes/${quiz['quiz_id']}/publish',
      const {},
      useAuth: true,
      requireJsonObject: true,
      canSend: () =>
          token != null &&
          prefs.getString('token') == token &&
          prefs.getInt('user_id') == account,
    );
    final result = response.data;
    if (!response.isSuccess ||
        result == null ||
        result['quiz_id'] != quiz['quiz_id'] ||
        result['status'] != 'published') {
      _showError(
        'Publishing could not be confirmed. Refresh and review the quiz status before trying again.',
      );
      return;
    }
    if (!mounted ||
        prefs.getString('token') != token ||
        prefs.getInt('user_id') != account) {
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
    _revealQuizError(_errorKey);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
    TtsService.speak(message);
  }

  @override
  void dispose() {
    _createQuestionFocus.dispose();
    _createQuizFocus.dispose();
    _createPracticeFocus.dispose();
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
      navigationSections:
          'private bank search and saved questions, quiz drafts, published quizzes, and their results',
      labels: teacherQuizKeyLabels,
      autoPlay: false,
      actions: {
        0: () => Navigator.pop(context),
        1: _load,
        2: _createQuestion,
        3: _createQuiz,
        4: () => _createQuiz(practice: true),
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
        KeypadFocusTarget(
          node: _createPracticeFocus,
          label: 'Create separate untimed ungraded practice. Unlimited retries',
          onActivate: () => _createQuiz(practice: true),
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
                'Question bank item, ${question['spoken_question_text'] ?? question['question_text']}. Revision ${question['revision'] ?? 'unknown legacy'}. Press OK for edit, revision history, duplicate, archive, or add actions',
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
                ? 'Continue creating ${quiz['title']}. ${quiz['question_count']} questions'
                : quiz['status'] == 'published'
                ? 'Close ${quiz['title']}'
                : '${quiz['title']} is closed',
            onActivate: quiz['status'] == 'draft'
                ? () => _buildDraft(quiz['quiz_id'] as int)
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
                        key: _errorKey,
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
                        OutlinedButton(
                          focusNode: _createPracticeFocus,
                          onPressed: () => _createQuiz(practice: true),
                          child: const Text('4: Create untimed practice'),
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
                            title: Semantics(
                              label:
                                  '${question['spoken_question_text'] ?? question['question_text']}',
                              excludeSemantics: true,
                              child: Text('${question['question_text']}'),
                            ),
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
                          onPublish: () => _buildDraft(quiz['quiz_id'] as int),
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

class GuidedQuizDraftScreen extends StatefulWidget {
  const GuidedQuizDraftScreen({
    super.key,
    required this.quizId,
    required this.classId,
    required this.subjectId,
    required this.onPublish,
  });

  final int quizId;
  final int classId;
  final int subjectId;
  final Future<void> Function(Map<String, dynamic>) onPublish;

  @override
  State<GuidedQuizDraftScreen> createState() => _GuidedQuizDraftScreenState();
}

class _GuidedQuizDraftScreenState extends State<GuidedQuizDraftScreen> {
  final _nodes = <String, FocusNode>{};
  Map<String, dynamic>? _quiz;
  List<Map<String, dynamic>> _bank = [];
  bool _busy = true;
  bool _review = false;
  bool _needsRefresh = false;
  String? _error;
  final _errorKey = GlobalKey();
  SharedPreferences? _preferences;
  String? _token;
  int? _account;
  FocusNode _node(String name) => _nodes.putIfAbsent(
    name,
    () => FocusNode(debugLabel: 'guided-quiz-$name'),
  );
  bool get _sameAccount =>
      _token != null &&
      _account != null &&
      _preferences?.getString('token') == _token &&
      _preferences?.getInt('user_id') == _account;
  List get _questions => _quiz?['questions'] as List? ?? const [];
  bool get _draft => _quiz?['status'] == 'draft';

  bool _validQuiz(Object? value) {
    if (value is! Map<String, dynamic> ||
        value['quiz_id'] != widget.quizId ||
        value['class_id'] != widget.classId ||
        value['subject_id'] != widget.subjectId ||
        value['title'] is! String ||
        !const ['draft', 'published', 'closed'].contains(value['status']) ||
        !const ['practice', 'graded'].contains(value['mode']) ||
        value['attempt_limit'] is! int ||
        value['questions'] is! List) {
      return false;
    }
    final questions = value['questions'] as List;
    return value['question_count'] == questions.length &&
        questions.every((question) {
          if (question is! Map<String, dynamic> ||
              question['quiz_question_id'] is! int ||
              question['question_text'] is! String ||
              question['options'] is! List) {
            return false;
          }
          final options = question['options'] as List;
          final spoken = question['spoken_options'];
          return options.length == 4 &&
              options.every(
                (option) =>
                    option is Map<String, dynamic> &&
                    option['option_text'] is String &&
                    option['is_correct'] is bool,
              ) &&
              options.where((option) => option['is_correct'] == true).length ==
                  1 &&
              (spoken == null ||
                  (spoken is List &&
                      spoken.length == 4 &&
                      spoken.every((option) => option is String)));
        });
  }

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    _preferences = await SharedPreferences.getInstance();
    _token = _preferences!.getString('token');
    _account = _preferences!.getInt('user_id');
    if (mounted) await _load();
  }

  void _report(String message) {
    if (!mounted) return;
    setState(() => _error = message);
    _revealQuizError(_errorKey);
    TtsService.speak(message);
  }

  bool _requireAccount() {
    if (_sameAccount) return true;
    _report('Your account changed. Return to quizzes and sign in again.');
    return false;
  }

  Future<void> _load() async {
    if (!_sameAccount) {
      if (mounted) setState(() => _busy = false);
      _report('Your account changed. Return to quizzes and sign in again.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
      _needsRefresh = true;
    });
    final results = await Future.wait([
      ApiService.getResult(
        '/teacher/quizzes/${widget.quizId}',
        useAuth: true,
        context: 'quiz draft',
        requestTimeout: const Duration(seconds: 20),
        canSend: () => mounted && _sameAccount,
      ),
      ApiService.getResult(
        '/question-bank?class_id=${widget.classId}&subject_id=${widget.subjectId}',
        useAuth: true,
        context: 'question bank',
        requestTimeout: const Duration(seconds: 20),
        canSend: () => mounted && _sameAccount,
      ),
    ]);
    if (!mounted) return;
    setState(() => _busy = false);
    if (!_sameAccount) {
      _report('Your account changed. This draft cannot be reviewed here.');
      return;
    }
    final draft = results[0].data;
    final bank = results[1].data;
    if (!results[0].isSuccess ||
        !_validQuiz(draft) ||
        !results[1].isSuccess ||
        bank is! List ||
        bank.any(
          (item) =>
              item is! Map<String, dynamic> ||
              item['question_id'] is! int ||
              item['question_text'] is! String,
        )) {
      _report(
        'The draft or question bank could not be loaded. Refresh before continuing.',
      );
      return;
    }
    setState(() {
      _quiz = draft as Map<String, dynamic>;
      _bank = bank.cast<Map<String, dynamic>>();
      _needsRefresh = false;
    });
  }

  Future<void> _add({required bool reuse}) async {
    if (_busy || _needsRefresh || !_draft || !_requireAccount()) return;
    setState(() => _busy = true);
    try {
      Map<String, dynamic>? content;
      String path;
      if (reuse) {
        final response = await ApiService.getResult(
          '/question-bank?class_id=${widget.classId}&subject_id=${widget.subjectId}',
          useAuth: true,
          canSend: () => mounted && _sameAccount,
          requestTimeout: const Duration(seconds: 20),
        );
        if (!mounted || !_requireAccount()) return;
        final bank = response.data;
        if (!response.isSuccess ||
            bank is! List ||
            bank.any(
              (item) =>
                  item is! Map<String, dynamic> ||
                  item['question_id'] is! int ||
                  item['question_text'] is! String,
            )) {
          _report(
            '${response.failure?.message ?? 'The saved question list could not be read.'} '
            'The question bank could not be refreshed. No question was added. Try Choose a saved question again.',
          );
          return;
        }
        setState(() => _bank = bank.cast<Map<String, dynamic>>());
        final existing = _questions
            .map((item) => (item as Map)['source_question_id'])
            .toSet();
        final eligible = _bank
            .where(
              (item) =>
                  item['is_archived'] != true &&
                  !existing.contains(item['question_id']),
            )
            .toList();
        if (eligible.isEmpty) {
          _report(
            'No unused questions are available in this workspace. Choose Write a question.',
          );
          return;
        }
        final selected = await showDialog<String>(
          context: context,
          builder: (_) => AccessibleActionDialog(
            title: 'Choose a saved question',
            actions: [
              for (final question in eligible)
                AccessibleAction(
                  value: '${question['question_id']}',
                  label:
                      '${question['spoken_question_text'] ?? question['question_text']}',
                  icon: Icons.help_outline,
                ),
            ],
          ),
        );
        if (selected == null) return;
        content = {'question_id': int.parse(selected)};
        path = 'from-bank';
      } else {
        content = await showDialog<Map<String, dynamic>>(
          context: context,
          barrierDismissible: false,
          builder: (_) => const AccessibleQuestionEditorDialog(),
        );
        if (content == null) return;
        content = {...content, 'save_to_bank': true};
        path = 'new';
      }
      if (!mounted || !_requireAccount()) return;
      final previousCount = _questions.length;
      final response = await ApiService.postResult(
        '/teacher/quizzes/${widget.quizId}/questions/$path',
        content,
        useAuth: true,
        requireJsonObject: true,
        canSend: () => _sameAccount,
      );
      if (!mounted) return;
      final saved = response.data;
      if (!_sameAccount ||
          !response.isSuccess ||
          saved == null ||
          !_validQuiz(saved) ||
          saved['status'] != 'draft' ||
          (saved['questions'] as List).length != previousCount + 1 ||
          saved['question_count'] != previousCount + 1) {
        setState(() => _needsRefresh = true);
        _report(
          '${response.failure?.message ?? 'The saved draft did not match.'} Adding the question could not be confirmed. Refresh and review saved questions before adding again; it may already be saved.',
        );
        return;
      }
      setState(() {
        _quiz = saved;
        _error = null;
      });
      await TtsService.speak(
        'Question added. ${_questions.length} questions saved. Add another or choose Review.',
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String get _summary {
    final quiz = _quiz!;
    return '${quiz['title']}. ${quiz['description'] ?? ''} ${_questions.length} questions. '
        '${quiz['mode'] == 'practice' ? 'Ungraded practice. Unlimited attempts. No timer.' : 'Graded quiz. ${quiz['attempt_limit']} attempts. ${quiz['time_limit_minutes'] == null ? 'No timer.' : '${quiz['time_limit_minutes']} minutes per attempt.'}'} '
        '${_quizFeedbackText(quiz)} '
        'Opens: ${quiz['opens_at'] ?? 'when published'}. Closes: ${quiz['closes_at'] ?? 'not scheduled'}. '
        'Shuffle questions: ${quiz['shuffle_questions'] == true ? 'on' : 'off'}. '
        'Shuffle options: ${quiz['shuffle_options'] == true ? 'on' : 'off'}.';
  }

  Future<void> _publish() async {
    if (_busy ||
        _needsRefresh ||
        !_draft ||
        _questions.isEmpty ||
        !_requireAccount()) {
      return;
    }
    setState(() => _busy = true);
    try {
      await widget.onPublish(_quiz!);
      if (mounted && _sameAccount) await _load();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _removeQuestion() async {
    if (_busy ||
        _needsRefresh ||
        !_draft ||
        !_requireAccount() ||
        _questions.isEmpty) {
      return;
    }
    setState(() => _busy = true);
    try {
      final selected = await showDialog<String>(
        context: context,
        builder: (_) => AccessibleActionDialog(
          title: 'Choose a question to remove from this draft',
          actions: [
            for (var i = 0; i < _questions.length; i++)
              AccessibleAction(
                value: '${_questions[i]['quiz_question_id']}',
                label: 'Question ${i + 1}: ${_questions[i]['question_text']}',
                icon: Icons.remove_circle_outline,
              ),
          ],
        ),
      );
      if (selected == null || !mounted || !_requireAccount()) return;
      final confirmed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => const KeypadConfirmationDialog(
          title: 'Remove selected question?',
          message:
              'Remove this question from the draft? The reusable question bank is not changed.',
          confirmLabel: 'Remove question',
        ),
      );
      if (confirmed != true || !mounted || !_requireAccount()) return;
      final response = await ApiService.deleteResult(
        '/teacher/quizzes/${widget.quizId}/questions/$selected',
        useAuth: true,
        requestTimeout: const Duration(seconds: 20),
        canSend: () => mounted && _sameAccount,
      );
      if (!mounted) return;
      await _load();
      if (!mounted) return;
      if (!response.isSuccess ||
          _needsRefresh ||
          !_sameAccount ||
          _questions.any(
            (question) => '${question['quiz_question_id']}' == selected,
          )) {
        _report(
          'Removal could not be confirmed. Review the refreshed draft before trying again.',
        );
        return;
      }
      await TtsService.speak(
        'Question removed from the draft. ${_questions.length} questions saved.',
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _editSettings() async {
    if (_busy || _needsRefresh || !_draft || !_requireAccount()) return;
    setState(() => _busy = true);
    try {
      final content = await showDialog<Map<String, dynamic>>(
        context: context,
        barrierDismissible: false,
        builder: (_) => AccessibleQuizEditorDialog(
          practice: _quiz!['mode'] == 'practice',
          initialQuiz: _quiz,
        ),
      );
      if (content == null || !mounted || !_requireAccount()) return;
      final response = await ApiService.putResult(
        '/teacher/quizzes/${widget.quizId}',
        {
          ...content,
          'class_id': widget.classId,
          'subject_id': widget.subjectId,
        },
        useAuth: true,
        canSend: () => mounted && _sameAccount,
      );
      if (!mounted) return;
      final saved = response.data;
      if (!_sameAccount ||
          !response.isSuccess ||
          saved == null ||
          !_validQuiz(saved) ||
          saved['status'] != 'draft' ||
          saved['title'] != content['title'] ||
          saved['questions'] is! List ||
          saved['question_count'] != _questions.length) {
        setState(() => _needsRefresh = true);
        _report(
          'Settings save could not be confirmed. Refresh and review the saved settings before publishing.',
        );
        return;
      }
      setState(() {
        _quiz = saved;
        _error = null;
      });
      await TtsService.speak(
        'Quiz settings saved. Review them before publishing.',
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    for (final node in _nodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final published = _quiz?['status'] == 'published';
    final targets = <KeypadFocusTarget>[
      KeypadFocusTarget(
        node: _node('refresh'),
        label: 'Refresh saved draft',
        onActivate: _load,
        isEnabled: () => !_busy,
      ),
      if (_draft && !_review) ...[
        KeypadFocusTarget(
          node: _node('write'),
          label:
              'Write a question and save it to this quiz and your question bank',
          onActivate: () => _add(reuse: false),
          isEnabled: () => !_busy && !_needsRefresh,
        ),
        KeypadFocusTarget(
          node: _node('reuse'),
          label: 'Choose a saved question',
          onActivate: () => _add(reuse: true),
          isEnabled: () => !_busy && !_needsRefresh,
        ),
        KeypadFocusTarget(
          node: _node('review'),
          label: 'Review questions and quiz settings before publishing',
          onActivate: () => setState(() => _review = true),
          isEnabled: () => !_busy && !_needsRefresh && _questions.isNotEmpty,
        ),
        if (_questions.isNotEmpty)
          KeypadFocusTarget(
            node: _node('remove'),
            label: 'Remove a question from this draft, with confirmation',
            onActivate: _removeQuestion,
            isEnabled: () => !_busy && !_needsRefresh,
          ),
        for (var index = 0; index < _questions.length; index++)
          KeypadFocusTarget(
            node: _node('saved-question-$index'),
            label:
                'Saved question ${index + 1}: ${_questions[index]['question_text']}. Already in this draft. Press OK to read its options',
            onActivate: () => TtsService.speak(_reviewQuestion(index)),
            isEnabled: () => !_busy,
          ),
      ],
      if (_quiz != null && _review) ...[
        KeypadFocusTarget(
          node: _node('summary'),
          label: _summary,
          onActivate: () => TtsService.speak(_summary),
        ),
        for (var i = 0; i < _questions.length; i++)
          KeypadFocusTarget(
            node: _node('question-$i'),
            label: _reviewQuestion(i),
            onActivate: () => TtsService.speak(_reviewQuestion(i)),
          ),
        if (_draft)
          KeypadFocusTarget(
            node: _node('settings'),
            label: 'Change title or optional quiz settings',
            onActivate: _editSettings,
            isEnabled: () => !_busy && !_needsRefresh,
          ),
        if (_draft)
          KeypadFocusTarget(
            node: _node('back'),
            label: 'Back to adding questions',
            onActivate: () => setState(() => _review = false),
            isEnabled: () => !_busy,
          ),
        if (_draft)
          KeypadFocusTarget(
            node: _node('publish'),
            label: 'Publish quiz, with confirmation',
            onActivate: _publish,
            isEnabled: () => !_busy && !_needsRefresh && _questions.isNotEmpty,
          ),
      ],
      KeypadFocusTarget(
        node: _node('finish'),
        label: published
            ? 'Return to quizzes'
            : 'Save for later and return. Confirmed changes are already saved as a draft',
        onActivate: () => Navigator.pop(context),
        isEnabled: () => !_busy,
      ),
    ];
    return PopScope(
      canPop: !_busy,
      child: KeypadInstructionWrapper(
        navigationSections: _review
            ? 'saved questions, quiz settings, and publishing with confirmation'
            : 'write or choose saved questions, remove questions, and review the draft',
        screenName: published
            ? 'Quiz published'
            : _review
            ? 'Step 3 of 3. Review before publishing. Nothing is published until you confirm.'
            : 'Step 2 of 3. Add questions. Choose Write or Use saved question. Then Review.',
        labels: {
          0: 'Save for later and return',
          1: 'Refresh',
          if (_draft && !_review) 2: 'Write a question',
          if (_draft && !_review) 3: 'Use saved question',
          if (_draft && !_review && _questions.isNotEmpty)
            4: 'Remove a question',
          if (_draft && !_review) 6: 'Review',
          if (_draft && _review) 8: 'Publish with confirmation',
          if (_draft && _review) 5: 'Change title or optional settings',
        },
        actions: {
          0: () {
            if (!_busy) Navigator.pop(context);
          },
          1: () {
            if (!_busy) _load();
          },
          if (_draft && !_review) 2: () => _add(reuse: false),
          if (_draft && !_review) 3: () => _add(reuse: true),
          if (_draft && !_review && _questions.isNotEmpty) 4: _removeQuestion,
          if (_draft && !_review)
            6: () {
              if (!_busy && !_needsRefresh && _questions.isNotEmpty) {
                setState(() => _review = true);
              }
            },
          if (_draft && _review) 8: _publish,
          if (_draft && _review) 5: _editSettings,
        },
        focusTargets: targets,
        child: Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    published
                        ? 'Quiz published'
                        : _review
                        ? 'Step 3: Review and publish'
                        : 'Step 2: Add questions',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  if (_quiz != null)
                    Text(
                      '${_quiz!['title']}. ${_questions.length} questions saved.',
                    ),
                  if (_busy && ModalRoute.of(context)?.isCurrent != false)
                    const LinearProgressIndicator(),
                  if (_error != null)
                    Semantics(
                      key: _errorKey,
                      liveRegion: true,
                      child: Text(_error!),
                    ),
                  for (final target in targets)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: OutlinedButton(
                        focusNode: target.node,
                        onPressed: target.isEnabled?.call() == false
                            ? null
                            : target.onActivate,
                        child: Text(target.label),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _reviewQuestion(int index) {
    final question = _questions[index] as Map;
    final options = question['options'] as List? ?? const [];
    final spokenOptions = question['spoken_options'] as List?;
    return 'Question ${index + 1}. ${question['spoken_question_text'] ?? question['question_text']}. '
        '${[for (var i = 0; i < options.length; i++) 'Option ${i + 1}: ${spokenOptions != null && i < spokenOptions.length ? spokenOptions[i] : options[i]['option_text']}${options[i]['is_correct'] == true ? ', correct answer' : ''}.'].join(' ')} '
        '${question['spoken_explanation'] ?? question['explanation'] ?? ''}';
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
                '${quiz['question_count']} questions · ${quiz['mode'] == 'practice' ? 'Ungraded practice, unlimited attempts' : '${quiz['attempt_limit']} attempts'}'
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
                      label: const Text('Continue creation'),
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
  final Map<int, FocusNode> _extraFocuses = {};
  final _savingExtra = <int>{};
  final _statisticsFocus = FocusNode(debugLabel: 'quiz-results-statistics');
  String get _statisticsText {
    final summary = _summary!;
    return 'Eligible: ${summary['eligible_students']}\n'
        'Started: ${summary['started']}\n'
        'Completed: ${summary['completed']}\n'
        'Not attempted: ${summary['not_attempted']}\n'
        'Completion: ${summary['completion_percentage']} percent\n'
        '${summary['mode'] == 'practice' ? 'Practice participation, not academic grades.' : 'Average highest score: ${summary['average_highest_score'] ?? 'Not available'}\nHighest score: ${summary['highest_score'] ?? 'Not available'}\nLowest completed score: ${summary['lowest_completed_score'] ?? 'Not available'}'}';
  }

  FocusNode _extraNode(int id) => _extraFocuses.putIfAbsent(
    id,
    () => FocusNode(debugLabel: 'quiz-extra-student-$id'),
  );
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
    if (_summary?['mode'] == 'practice') {
      return '${student['student_name']}. ${attempts.length} practice attempts. Not academic grades.';
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

  Future<void> _extraTime(Map student) async {
    final id = student['student_id'] as int;
    if (_savingExtra.contains(id)) return;
    setState(() => _savingExtra.add(id));
    try {
      final minutes = await showDialog<int>(
        context: context,
        builder: (_) => QuizExtraTimeDialog(
          studentName: '${student['student_name']}',
          initialMinutes: student['extra_time_minutes'] as int? ?? 0,
        ),
      );
      if (minutes == null || !mounted) return;
      final result = await ApiService.postAcknowledged(
        '/teacher/quizzes/${widget.quizId}/accommodations',
        {'student_id': id, 'extra_minutes': minutes},
        canSend: () => mounted,
      );
      if (!mounted) return;
      if (!result.isSuccess ||
          result.data?['student_id'] != id ||
          result.data?['extra_minutes'] != minutes) {
        final message =
            result.failure?.message ??
            'The extra-time confirmation did not match. Refresh before retrying.';
        setState(() => _error = message);
        await TtsService.speak(message);
        return;
      }
      await _load();
      await TtsService.speak(
        'Extra time confirmed for future attempts only. Existing attempt deadlines are unchanged and quiz closing time still applies.',
      );
    } finally {
      if (mounted) setState(() => _savingExtra.remove(id));
    }
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
    for (final focus in _extraFocuses.values) {
      focus.dispose();
    }
    _statisticsFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final summary = _summary;
    return KeypadInstructionWrapper(
      screenName: 'Results for ${widget.quizTitle}',
      navigationSections:
          'quiz summary, student results, and available result actions',
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
        if (summary != null)
          KeypadFocusTarget(
            node: _statisticsFocus,
            label: _statisticsText,
            onActivate: () => TtsService.speak(_statisticsText),
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
        if (_summary?['time_limit_minutes'] is int &&
            _summary?['mode'] != 'practice')
          for (final student in _students)
            KeypadFocusTarget(
              node: _extraNode(student['student_id'] as int),
              label:
                  'Set extra minutes for ${student['student_name']}. Future attempts only. Current extra ${student['extra_time_minutes'] ?? 0} minutes',
              isEnabled: () => !_savingExtra.contains(student['student_id']),
              onActivate: () => _extraTime(student as Map),
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
            : SingleChildScrollView(
                padding: UIUtils.paddingAll(context, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
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
                          child: Focus(
                            focusNode: _statisticsFocus,
                            child: Text(_statisticsText),
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
                      summary?['mode'] == 'practice'
                          ? 'Practice participation, not academic grades'
                          : 'Individual student scores',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    for (final student in _students)
                      Card(
                        child: Column(
                          children: [
                            ListTile(
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
                                    : '${summary?['mode'] == 'practice' ? 'Practice, not graded' : 'Highest score: ${student['highest_score'] ?? 'Attempt in progress'}'}\n'
                                          '${(student['attempts'] as List).length} attempt(s)',
                              ),
                              onTap: () => TtsService.speak(
                                _studentDetails(student as Map),
                              ),
                            ),
                            if (summary?['time_limit_minutes'] is int &&
                                summary?['mode'] != 'practice')
                              TextButton(
                                focusNode: _extraNode(
                                  student['student_id'] as int,
                                ),
                                onPressed:
                                    _savingExtra.contains(student['student_id'])
                                    ? null
                                    : () => _extraTime(student as Map),
                                child: Text(
                                  'Future extra time: ${student['extra_time_minutes'] ?? 0} minutes. Set',
                                ),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
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
  static const _navigationHelp =
      'Use D-pad up and down to reach refresh, quiz state filter, subject filter, '
      'each available quiz or practice activity, and its attempt history. '
      'Use left or right on a filter to change it. '
      'Press OK on a quiz to hear its details and confirm starting or resuming; '
      'press OK on attempt history to review past attempts. Moving focus never starts an attempt.';
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
        '${buildTtsInstructions(studentQuizKeyLabels, screenName: 'Student quizzes')} '
        '$_navigationHelp $summary',
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
            '${quiz['title']}. ${_attemptsText(quiz)} '
            '${quiz['time_limit_minutes'] == null ? 'No per-attempt time limit.' : 'Time limit ${quiz['time_limit_minutes']} minutes.'} '
            'Each confirmed answer is locked. ${_quizFeedbackText(quiz)}',
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
        (quiz['mode'] == 'practice' ||
            (quiz['attempts_remaining'] as int? ?? 0) > 0);
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
      introduction: _navigationHelp,
      navigationSections:
          'refresh, quiz state and subject filters, available quizzes and practice activities, and previous attempts',
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
                  '${_attemptsText(quiz)} '
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
                              '${quiz['subject_name']}, ${quiz['title']}. Status ${quiz['display_status']}. ${_attemptsText(quiz)}',
                          child: Card(
                            child: ListTile(
                              leading: const Icon(Icons.quiz_outlined),
                              title: Text('${quiz['title']}'),
                              subtitle: Text(
                                '${quiz['subject_name']} · ${quiz['display_status']}\n'
                                '${quiz['description'] ?? 'No description'}\n'
                                '${_attemptsText(quiz)}'
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
                                      quiz['mode'] != 'practice' &&
                                      (quiz['attempts_remaining'] as int? ??
                                              0) ==
                                          0)
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
  final _keypad = KeypadNavigationController();
  late Map<String, dynamic> _attempt;
  int? _selectedOptionId;
  Map<String, dynamic>? _feedback;
  bool _submitting = false;
  bool _completing = false;
  String? _completionError;
  Timer? _timer;
  Duration? _remaining;
  DateTime? _serverAnchor;
  DateTime? _deadline;
  final Stopwatch _elapsed = Stopwatch();
  final _submitFocus = FocusNode(debugLabel: 'quiz-submit-answer');
  final _nextFocus = FocusNode(debugLabel: 'quiz-next-question');
  final _feedbackFocus = FocusNode(debugLabel: 'quiz-feedback');
  final _returnFocus = FocusNode(debugLabel: 'quiz-return-to-list');
  final _resultFocus = FocusNode(debugLabel: 'quiz-read-private-result');
  bool _feedbackReadRequested = false;
  bool _resultReadRequested = false;
  final _questionFocus = FocusNode(debugLabel: 'quiz-question-prompt');
  final _optionsRepeatFocus = FocusNode(debugLabel: 'quiz-repeat-options');
  final _selectionRepeatFocus = FocusNode(debugLabel: 'quiz-repeat-selection');
  final _stopSpeechFocus = FocusNode(debugLabel: 'quiz-stop-speech');
  final _timeFocus = FocusNode(debugLabel: 'quiz-remaining-time');
  final _earlyFinishFocus = FocusNode(debugLabel: 'quiz-early-finish');
  final _exitFocus = FocusNode(debugLabel: 'quiz-exit-attempt');
  bool _allowExit = false;
  bool _exitDialog = false;
  String? _earlyFinishError;
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
        if (mounted) {
          _keypad.focusAndAnnounce(
            _returnFocus,
            'Attempt complete. Your result remains private. $_navigationHelp',
          );
        }
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

  bool get _allAnswersSaved =>
      _question == null &&
      (_attempt['total_questions'] as int? ?? 0) > 0 &&
      (_attempt['answered_count'] as int? ?? 0) >=
          (_attempt['total_questions'] as int);

  bool get _canAnswer =>
      _attempt['status'] == 'in_progress' &&
      _feedback == null &&
      !_submitting &&
      !_completing &&
      !_exitDialog &&
      _completionError == null &&
      (_remaining == null || _remaining! > Duration.zero);

  String get _questionAnnouncement {
    final answered = _attempt['answered_count'] as int? ?? 0;
    final number = _feedback == null ? answered + 1 : answered;
    return 'Question $number of ${_attempt['total_questions']}. '
        '${_question?['spoken_question_text'] ?? _question?['question_text'] ?? ''}';
  }

  String get _optionsAnnouncement {
    final options = _question?['options'] as List? ?? const [];
    return [
      for (var index = 0; index < options.length; index++)
        'Option ${index + 1}. ${options[index]['spoken_option_text'] ?? options[index]['option_text']}.',
    ].join(' ');
  }

  String get _questionAndOptions =>
      '$_questionAnnouncement $_optionsAnnouncement';

  String get _navigationHelp {
    if (_attempt['status'] != 'in_progress') {
      return 'Use D-pad up and down to move between return to quizzes and read result privately. '
          'Press OK to activate a button. Press 8 to read your result privately or 0 to return.';
    }
    if (_completionError != null) {
      return 'Use D-pad up and down to reach Retry completion, stop speech, time remaining if timed, or leave without submitting. '
          'Press OK to activate a control. Press 6 to retry completion or 0 to leave with confirmation.';
    }
    if (_feedback != null || _allAnswersSaved) {
      return 'Use D-pad up and down to reach saved-answer status, read feedback privately, '
          'stop speech, time remaining if timed, next question or view result, finish early, and leave. '
          'Press OK on a control. Press 6 for the next question or result, 7 to finish early with confirmation, or 0 to leave without submitting.';
    }
    return 'Use D-pad up and down to move through read question, read all options, '
        'each answer option, read selected answer, stop speech, time remaining if timed, '
        'submit answer, finish early, and leave without submitting. '
        'Press OK on an option to select it; moving focus does not select or submit. '
        'Press 1 to ${_question?['options'] is List ? (_question!['options'] as List).length : 4} to select an option, then 5 to save your answer. '
        'Press 7 to finish early with confirmation, or 0 to leave without submitting. '
        'Press star to repeat question, options and help.';
  }

  void _readOptions() => TtsService.speak(_optionsAnnouncement);

  void _readSelection() {
    final options = _question?['options'] as List? ?? const [];
    for (var index = 0; index < options.length; index++) {
      if (options[index]['quiz_option_id'] == _selectedOptionId) {
        TtsService.speak(
          'Selected option ${index + 1}. ${options[index]['spoken_option_text'] ?? options[index]['option_text']}. '
          '${_feedback == null ? 'Not submitted yet.' : 'Answer confirmed.'}',
        );
        return;
      }
    }
    TtsService.speak('No answer selected.');
  }

  String get _feedbackAnnouncement => _feedback!['feedback_released'] == false
      ? 'Answer confirmed saved and locked. ${_feedback!['feedback_message']}'
      : '${_feedback!['is_correct'] == true ? 'Correct' : 'Incorrect'}. '
            'Correct answer: ${_feedback!['correct_option_spoken_text'] ?? _feedback!['correct_option_text']}. '
            '${_feedback!['spoken_explanation'] ?? _feedback!['explanation'] ?? ''}';

  void _selectOption(int index) {
    if (!_canAnswer) return;
    final options = _question?['options'];
    if (options is! List || index >= options.length) return;
    final option = options[index] as Map;
    setState(() => _selectedOptionId = option['quiz_option_id'] as int);
    TtsService.speak(
      'Option ${index + 1}. ${option['spoken_option_text'] ?? option['option_text']}. '
      'Selected, not submitted. Press 5 to save your answer.',
    );
  }

  void _readPrivateFeedback() {
    if (_feedback == null) return;
    setState(() => _feedbackReadRequested = true);
    TtsService.speak(_feedbackAnnouncement);
  }

  void _readPrivateResult() {
    setState(() => _resultReadRequested = true);
    TtsService.speak(_attemptResultText(_attempt));
  }

  Future<void> _submit() async {
    if (!_canAnswer) return;
    final question = _question;
    if (question == null || _selectedOptionId == null) {
      TtsService.speak('Select one option before submitting.');
      return;
    }
    setState(() => _submitting = true);
    final response = await ApiService.submitQuizAnswer(
      attemptId: _attempt['attempt_id'] as int,
      questionId: question['quiz_question_id'] as int,
      optionId: _selectedOptionId!,
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    final result = response.data;
    if (!response.isSuccess ||
        result == null ||
        !((result['feedback_released'] == false &&
                result['feedback_message'] is String &&
                result['is_correct'] == null &&
                result['correct_option_text'] == null) ||
            (result['is_correct'] is bool &&
                result['correct_option_text'] is String)) ||
        !result.containsKey('next_question') ||
        (result['next_question'] != null &&
            result['next_question'] is! Map<String, dynamic>)) {
      if (response.isSuccess) {
        debugPrint('[QUIZ] Answer confirmation has an invalid response shape.');
      }
      final message =
          '${response.failure?.message ?? 'The answer confirmation could not be read.'} '
          'Your selection is preserved; retry submission.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      await TtsService.speak(message);
      return;
    }
    setState(() {
      _feedback = result;
      _feedbackReadRequested = false;
      _attempt = {
        ..._attempt,
        'answered_count': (_attempt['answered_count'] as int? ?? 0) + 1,
      };
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _keypad.focusAndAnnounce(
          _feedbackFocus,
          'Answer confirmed saved and locked. Press OK to read feedback privately. $_navigationHelp',
        );
      }
    });
  }

  Future<void> _next() async {
    if (_attempt['status'] != 'in_progress' ||
        _submitting ||
        _completing ||
        _exitDialog) {
      return;
    }
    if (_feedback == null && !_allAnswersSaved) {
      await TtsService.speak('Submit your answer before continuing.');
      return;
    }
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _keypad.focusAndAnnounce(
          _questionFocus,
          '$_questionAndOptions $_navigationHelp',
        );
      }
    });
  }

  Future<void> _complete() async {
    if (_attempt['status'] != 'in_progress' || _completing) return;
    setState(() {
      _completing = true;
      _completionError = null;
    });
    final response = await ApiService.completeQuizAttempt(
      _attempt['attempt_id'] as int,
    );
    if (!mounted) return;
    final result = response.data;
    if (!response.isSuccess ||
        result == null ||
        result['attempt_id'] != _attempt['attempt_id'] ||
        (result['status'] != 'completed' && result['status'] != 'timed_out') ||
        result['total_questions'] is! int ||
        !((result['score_released'] == false &&
                result['correct_count'] == null &&
                result['percentage_score'] == null &&
                result['feedback_message'] is String) ||
            (result['is_graded'] == false &&
                result['correct_count'] is int &&
                result['percentage_score'] == null) ||
            (result['correct_count'] is int &&
                result['percentage_score'] is num))) {
      if (response.isSuccess) {
        debugPrint('[QUIZ] Completion has an invalid response shape.');
      }
      final message =
          '${response.failure?.message ?? 'Completion was not confirmed.'} '
          'Your saved answers are preserved. '
          'Select Retry completion to check the result.';
      setState(() {
        _completing = false;
        _completionError = message;
      });
      await TtsService.speak(message);
      return;
    }
    _timer?.cancel();
    setState(() {
      _attempt = result;
      _completing = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _keypad.focusAndAnnounce(
          _returnFocus,
          'Attempt ${result['status']}. Your result is private. $_navigationHelp',
        );
      }
    });
  }

  String get _remainingText {
    final value = _remaining;
    if (value == null) return 'No time limit';
    final minutes = value.inMinutes;
    final seconds = value.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds remaining';
  }

  Future<void> _earlyFinish() async {
    if (_attempt['status'] != 'in_progress' ||
        _submitting ||
        _completing ||
        _completionError != null ||
        _exitDialog) {
      return;
    }
    setState(() {
      _exitDialog = true;
      _earlyFinishError = null;
    });
    try {
      final current = await ApiService.getQuizAttempt(
        _attempt['attempt_id'] as int,
      ).timeout(const Duration(seconds: 10));
      if (!mounted) return;
      final answered = current?['answered_count'];
      final total = current?['total_questions'];
      if (current?['attempt_id'] != _attempt['attempt_id'] ||
          current?['quiz_id'] != _attempt['quiz_id'] ||
          current?['status'] != 'in_progress' ||
          answered is! int ||
          total is! int ||
          total != _attempt['total_questions'] ||
          answered < 0 ||
          answered > total ||
          _attempt['status'] != 'in_progress' ||
          _completing) {
        const message =
            'The current saved-answer count could not be confirmed, or this attempt has ended. No early submission was sent. Return to the quiz list to refresh its status.';
        setState(() => _earlyFinishError = message);
        await TtsService.speak(message);
        return;
      }
      final unanswered = total - answered;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (_) => KeypadConfirmationDialog(
          title: 'Submit this attempt early?',
          message:
              'The server check confirms $unanswered unanswered questions. Only answers saved on the server when finalized are included. A selected but unsaved answer is not included. Final submission cannot be undone or edited. Back never submits.',
          confirmLabel: 'Finalize saved answers',
          cancelLabel: 'Keep working',
        ),
      );
      if (confirmed == true && mounted && _attempt['status'] == 'in_progress') {
        await _complete();
      }
    } on TimeoutException {
      const message =
          'Checking saved answers timed out. No early submission was sent. Check your connection and retry.';
      debugPrint('[QUIZ] $message');
      if (mounted) {
        setState(() => _earlyFinishError = message);
        await TtsService.speak(message);
      }
    } finally {
      if (mounted) setState(() => _exitDialog = false);
    }
  }

  Future<void> _exit() async {
    if (_attempt['status'] != 'in_progress') {
      Navigator.pop(context);
      return;
    }
    if (_exitDialog) return;
    if (_submitting || _completing) {
      await TtsService.speak(
        'Wait for the pending answer or completion confirmation before leaving.',
      );
      return;
    }
    _exitDialog = true;
    try {
      final leave = await showDialog<bool>(
        context: context,
        builder: (_) => const KeypadConfirmationDialog(
          title: 'Leave and resume later?',
          message:
              'This does not submit your attempt. Only server-confirmed answers are saved; an unsaved selection may be lost. Any timer keeps running. Resume is allowed only while the server permits this attempt.',
          confirmLabel: 'Leave without submitting',
          cancelLabel: 'Stay in attempt',
        ),
      );
      if (leave == true && mounted) {
        setState(() => _allowExit = true);
        Navigator.pop(context);
      }
    } finally {
      _exitDialog = false;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _elapsed.stop();
    _submitFocus.dispose();
    _nextFocus.dispose();
    _feedbackFocus.dispose();
    _returnFocus.dispose();
    _resultFocus.dispose();
    _questionFocus.dispose();
    _optionsRepeatFocus.dispose();
    _selectionRepeatFocus.dispose();
    _stopSpeechFocus.dispose();
    _timeFocus.dispose();
    _earlyFinishFocus.dispose();
    _exitFocus.dispose();
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
    final choosing =
        !completed &&
        question != null &&
        _feedback == null &&
        _completionError == null;
    return PopScope(
      canPop: completed || _allowExit,
      onPopInvokedWithResult: (popped, _) {
        if (!popped) unawaited(_exit());
      },
      child: KeypadInstructionWrapper(
        navigationController: _keypad,
        onHashKey: _exit,
        screenName: 'Quiz attempt, ${widget.quizTitle}',
        introduction: completed
            ? 'Attempt complete. Your result remains private. $_navigationHelp'
            : choosing
            ? '$_questionAndOptions $_navigationHelp'
            : _completionError != null
            ? '$_completionError $_navigationHelp'
            : 'Answer confirmed saved and locked. $_navigationHelp',
        labels: {
          0: completed
              ? 'Return to quizzes'
              : 'Leave without submitting, with confirmation',
          if (!completed) 7: 'Submit attempt early, with confirmation',
          if (completed) 8: 'Read result privately',
          if (choosing) ...{
            1: 'Select option 1',
            2: 'Select option 2',
            3: 'Select option 3',
            4: 'Select option 4',
            5: 'Submit selected answer',
          },
          if (!completed && !choosing)
            6: _completionError != null
                ? 'Retry completion'
                : 'Next question or view result',
        },
        actions: {
          0: _exit,
          if (!completed) 7: _earlyFinish,
          if (completed) 8: _readPrivateResult,
          for (var index = 0; index < 4; index++)
            index + 1: () => _selectOption(index),
          5: _submit,
          6: completed
              ? () => Navigator.pop(context)
              : _completionError != null
              ? _complete
              : _next,
        },
        focusTargets: [
          if (completed)
            KeypadFocusTarget(
              node: _returnFocus,
              label: 'Return to quizzes',
              onActivate: () => Navigator.pop(context),
            ),
          if (completed)
            KeypadFocusTarget(
              node: _resultFocus,
              label: 'Read result privately',
              onActivate: _readPrivateResult,
            ),
          if (!completed)
            KeypadFocusTarget(
              node: _questionFocus,
              label: choosing ? _questionAndOptions : _questionAnnouncement,
              onActivate: () => TtsService.speak(
                choosing ? _questionAndOptions : _questionAnnouncement,
              ),
            ),
          if (choosing)
            KeypadFocusTarget(
              node: _optionsRepeatFocus,
              label: 'Read all answer options',
              onActivate: _readOptions,
            ),
          for (var index = 0; choosing && index < options.length; index++)
            KeypadFocusTarget(
              node: _optionFocuses[index],
              label:
                  'Option ${index + 1}, ${options[index]['spoken_option_text'] ?? options[index]['option_text']}, '
                  '${_selectedOptionId == options[index]['quiz_option_id'] ? 'selected' : 'not selected'}. '
                  'Press OK or ${index + 1} to select. Press 5 to submit only when ready',
              onActivate: () => _selectOption(index),
              isEnabled: () => _canAnswer,
            ),
          if (choosing)
            KeypadFocusTarget(
              node: _selectionRepeatFocus,
              label: 'Read selected answer and saved status',
              onActivate: _readSelection,
            ),
          KeypadFocusTarget(
            node: _stopSpeechFocus,
            label: 'Stop speech',
            onActivate: TtsService.stop,
          ),
          if (!completed && _remaining != null)
            KeypadFocusTarget(
              node: _timeFocus,
              label: _remainingText,
              onActivate: () => TtsService.speak(_remainingText),
            ),
          if (choosing)
            KeypadFocusTarget(
              node: _submitFocus,
              label: 'Submit selected answer',
              onActivate: _submit,
              isEnabled: () => _canAnswer,
            ),
          if (!completed && _feedback != null)
            KeypadFocusTarget(
              node: _feedbackFocus,
              label: _feedback == null
                  ? 'Answer feedback'
                  : 'Answer confirmed saved and locked. Press OK to read feedback privately.',
              onActivate: _feedback == null ? null : _readPrivateFeedback,
            ),
          if (!completed && !choosing)
            KeypadFocusTarget(
              node: _nextFocus,
              label: _completionError != null
                  ? 'Retry completion'
                  : _feedback?['next_question'] == null
                  ? 'View result'
                  : 'Next question',
              onActivate: _completionError == null ? _next : _complete,
              isEnabled: () =>
                  !completed &&
                  !_completing &&
                  (_feedback != null ||
                      _allAnswersSaved ||
                      _completionError != null),
            ),
          if (!completed) ...[
            KeypadFocusTarget(
              node: _earlyFinishFocus,
              label:
                  'Finalize saved answers early with unanswered-count warning',
              isEnabled: () =>
                  !_submitting &&
                  !_completing &&
                  !_exitDialog &&
                  _completionError == null,
              onActivate: _earlyFinish,
            ),
            KeypadFocusTarget(
              node: _exitFocus,
              label: 'Leave without submitting, with confirmation',
              onActivate: _exit,
            ),
          ],
        ],
        child: Scaffold(
          appBar: AppBar(
            title: UIUtils.useStackedLayout(context)
                ? null
                : Text(widget.quizTitle),
            automaticallyImplyLeading: completed,
            leading: completed
                ? null
                : IconButton(
                    focusNode: _exitFocus,
                    tooltip: 'Leave without submitting',
                    onPressed: _exit,
                    icon: const Icon(Icons.arrow_back),
                  ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: UIUtils.paddingAll(context, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (UIUtils.useStackedLayout(context))
                    Semantics(
                      header: true,
                      child: Text(
                        widget.quizTitle,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                  if (!completed && _remaining != null)
                    Semantics(
                      liveRegion: false,
                      label: _remainingText,
                      child: Row(
                        children: [
                          const Icon(Icons.timer_outlined),
                          const SizedBox(width: 8),
                          Expanded(child: Text(_remainingText)),
                        ],
                      ),
                    ),
                  if (completed) ...[
                    Semantics(
                      liveRegion: _resultReadRequested,
                      excludeSemantics: true,
                      label: _resultReadRequested
                          ? _attemptResultText(_attempt)
                          : 'Attempt complete. Result private. Use Read result privately.',
                      child: Card(
                        child: ListTile(
                          leading: const Icon(Icons.emoji_events_outlined),
                          title: const Text('Attempt complete'),
                          subtitle: Text(_attemptResultText(_attempt)),
                        ),
                      ),
                    ),
                    TextButton(
                      focusNode: _resultFocus,
                      onPressed: _readPrivateResult,
                      child: const Text('8: Read result privately'),
                    ),
                    ElevatedButton(
                      focusNode: _returnFocus,
                      onPressed: () => Navigator.pop(context),
                      child: const Text('0: Return to quizzes'),
                    ),
                  ] else if (question != null) ...[
                    Text(
                      _questionAnnouncement.split('. ').first,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Focus(
                      focusNode: _questionFocus,
                      child: Semantics(
                        label: _questionAnnouncement,
                        excludeSemantics: true,
                        child: Text(
                          '${question['question_text']}',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                    ),
                    if (choosing)
                      TextButton(
                        focusNode: _optionsRepeatFocus,
                        onPressed: _readOptions,
                        child: const Text('Read all options'),
                      ),
                    const SizedBox(height: 12),
                    if (choosing)
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
                                    'Option ${index + 1}, ${options[index]['spoken_option_text'] ?? options[index]['option_text']}',
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
                                    value:
                                        options[index]['quiz_option_id'] as int,
                                    enabled: _canAnswer,
                                    title: Semantics(
                                      label:
                                          '${index + 1}. ${options[index]['spoken_option_text'] ?? options[index]['option_text']}',
                                      excludeSemantics: true,
                                      child: Text(
                                        '${index + 1}. ${options[index]['option_text']}',
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    if (choosing)
                      ElevatedButton.icon(
                        focusNode: _submitFocus,
                        onPressed: _canAnswer ? _submit : null,
                        icon: _submitting
                            ? const SizedBox.square(
                                dimension: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.check),
                        label: const Text('5: Submit answer'),
                      ),
                    if (_feedback != null)
                      Focus(
                        focusNode: _feedbackFocus,
                        child: Semantics(
                          liveRegion: _feedbackReadRequested,
                          excludeSemantics: true,
                          label: _feedbackReadRequested
                              ? _feedbackAnnouncement
                              : 'Answer saved and locked. Activate to read feedback privately.',
                          button: true,
                          onTap: _readPrivateFeedback,
                          child: Card(
                            color: _feedback!['is_correct'] == true
                                ? Colors.green.shade100
                                : Colors.orange.shade100,
                            child: ListTile(
                              leading: Icon(
                                _feedback!['feedback_released'] == false
                                    ? Icons.save_outlined
                                    : _feedback!['is_correct'] == true
                                    ? Icons.check_circle
                                    : Icons.cancel,
                                color: Colors.black,
                              ),
                              title: Text(
                                _feedback!['feedback_released'] == false
                                    ? 'Answer saved and locked'
                                    : _feedback!['is_correct'] == true
                                    ? 'Correct'
                                    : 'Incorrect',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                'You selected: ${_feedback!['selected_option_text']}\n'
                                '${_feedback!['feedback_released'] == false ? _feedback!['feedback_message'] : 'Correct answer: ${_feedback!['correct_option_text']}\n${_feedback!['explanation'] ?? 'No explanation provided.'}'}',
                                style: const TextStyle(color: Colors.black),
                              ),
                              onTap: _readPrivateFeedback,
                            ),
                          ),
                        ),
                      ),
                  ] else if (_allAnswersSaved)
                    const Text(
                      'All answers are saved. Select View result to confirm completion.',
                    ),
                  if (!completed) ...[
                    OutlinedButton(
                      focusNode: _earlyFinishFocus,
                      onPressed:
                          _submitting ||
                              _completing ||
                              _exitDialog ||
                              _completionError != null
                          ? null
                          : _earlyFinish,
                      child: const Text('7: Submit attempt early'),
                    ),
                    if (_earlyFinishError != null)
                      Semantics(
                        liveRegion: true,
                        child: Text(_earlyFinishError!),
                      ),
                    if (_completionError != null)
                      Semantics(
                        liveRegion: true,
                        child: Text(_completionError!),
                      ),
                    if (_feedback != null ||
                        _allAnswersSaved ||
                        _completionError != null)
                      ElevatedButton(
                        focusNode: _nextFocus,
                        onPressed: _completing
                            ? null
                            : (_completionError == null ? _next : _complete),
                        child: Text(
                          _completing
                              ? 'Confirming completion'
                              : _completionError != null
                              ? 'Retry completion'
                              : _feedback?['next_question'] == null
                              ? '6: View result'
                              : '6: Next question',
                        ),
                      ),
                  ],
                  if (choosing)
                    TextButton(
                      focusNode: _selectionRepeatFocus,
                      onPressed: completed ? null : _readSelection,
                      child: const Text('Read selected answer'),
                    ),
                  TextButton(
                    focusNode: _stopSpeechFocus,
                    onPressed: TtsService.stop,
                    child: const Text('Stop speech'),
                  ),
                  if (!completed && _remaining != null)
                    TextButton(
                      focusNode: _timeFocus,
                      onPressed: () => TtsService.speak(_remainingText),
                      child: const Text('Read remaining time'),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class QuizHistoryScreen extends StatefulWidget {
  const QuizHistoryScreen({
    super.key,
    required this.quizTitle,
    required this.history,
  });

  final String quizTitle;
  final Map<String, dynamic> history;

  @override
  State<QuizHistoryScreen> createState() => _QuizHistoryScreenState();
}

class _QuizHistoryScreenState extends State<QuizHistoryScreen> {
  final _nodes = <int, FocusNode>{};
  final _summaryNode = FocusNode(debugLabel: 'quiz-history-summary');
  bool _opening = false;
  String? _error;

  FocusNode _node(Map attempt) => _nodes.putIfAbsent(
    attempt['attempt_id'] as int,
    () =>
        FocusNode(debugLabel: 'quiz-history-attempt-${attempt['attempt_id']}'),
  );

  Future<void> _open(Map attempt) async {
    if (_opening) return;
    if (attempt['status'] == 'in_progress') {
      await TtsService.speak(
        'Attempt in progress. Return to the quiz list to resume it. Leaving does not submit.',
      );
      return;
    }
    setState(() {
      _opening = true;
      _error = null;
    });
    try {
      final review = await ApiService.getQuizReview(
        attempt['attempt_id'] as int,
      ).timeout(const Duration(seconds: 10));
      if (!mounted) return;
      if (review == null) {
        const message =
            'Attempt review could not be loaded. Check your connection and try again.';
        setState(() => _error = message);
        await TtsService.speak(message);
        return;
      }
      await Navigator.push<void>(
        context,
        MaterialPageRoute(builder: (_) => QuizReviewScreen(review: review)),
      );
    } on TimeoutException {
      const message =
          'Attempt review timed out. Check your connection and try again.';
      debugPrint('[QUIZ] $message');
      if (mounted) setState(() => _error = message);
      await TtsService.speak(message);
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  @override
  void dispose() {
    for (final node in _nodes.values) {
      node.dispose();
    }
    _summaryNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final history = widget.history;
    final quizTitle = widget.quizTitle;
    final attempts = history['attempts'] as List? ?? const [];
    final scoreSummary =
        attempts.any((attempt) => attempt['is_graded'] == false)
        ? 'Practice history. Not academic grades.'
        : history['highest_score'] != null
        ? 'Highest score: ${history['highest_score']}'
        : attempts.any((attempt) => attempt['status'] != 'in_progress')
        ? 'Completed attempts exist; no score is currently released.'
        : 'No completed attempt';
    return KeypadInstructionWrapper(
      screenName:
          'Attempt history. Scores are private. Navigate to the summary or an attempt to review.',
      labels: const {0: 'Go back'},
      actions: {0: () => Navigator.pop(context)},
      focusTargets: [
        KeypadFocusTarget(
          node: _summaryNode,
          label: scoreSummary,
          onActivate: () => TtsService.speak(scoreSummary),
        ),
        for (final attempt in attempts)
          KeypadFocusTarget(
            node: _node(attempt as Map),
            label:
                'Attempt ${attempt['attempt_number']}. ${attempt['status']}. ${_attemptResultText(attempt)}. Press OK to review.',
            onActivate: () => _open(attempt),
            isEnabled: () => !_opening,
          ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: UIUtils.useStackedLayout(context)
              ? null
              : Text('$quizTitle history'),
        ),
        body: SingleChildScrollView(
          padding: UIUtils.paddingAll(context, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (UIUtils.useStackedLayout(context))
                Semantics(
                  header: true,
                  child: Text(
                    '$quizTitle history',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
              if (_error != null)
                Semantics(liveRegion: true, child: Text(_error!)),
              if (_opening) const LinearProgressIndicator(),
              Semantics(
                liveRegion: false,
                child: Focus(
                  focusNode: _summaryNode,
                  child: Text(
                    scoreSummary,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
              if (attempts.isEmpty)
                const ListTile(title: Text('No attempts yet'))
              else
                ...attempts.map(
                  (attempt) => Card(
                    child: ListTile(
                      focusNode: _node(attempt as Map),
                      leading: const Icon(Icons.history),
                      title: Text('Attempt ${attempt['attempt_number']}'),
                      subtitle: Text(
                        '${attempt['status']}. ${_attemptResultText(attempt)}',
                      ),
                      trailing: attempt['status'] == 'in_progress'
                          ? null
                          : const Icon(Icons.chevron_right),
                      onTap: _opening ? null : () => _open(attempt),
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

class QuizReviewScreen extends StatefulWidget {
  const QuizReviewScreen({super.key, required this.review});

  final Map<String, dynamic> review;

  @override
  State<QuizReviewScreen> createState() => _QuizReviewScreenState();
}

class _QuizReviewScreenState extends State<QuizReviewScreen> {
  final _questionNodes = <int, FocusNode>{};
  final _messageNode = FocusNode(debugLabel: 'quiz-review-message');
  FocusNode _node(int index) => _questionNodes.putIfAbsent(
    index,
    () => FocusNode(debugLabel: 'quiz-review-question-$index'),
  );

  String _announcement(Map question, int index) =>
      'Question ${index + 1}. ${question['is_correct'] == true ? 'Correct' : 'Incorrect'}. '
      '${question['spoken_question_text'] ?? question['question_text']}. '
      'Selected ${question['selected_option_spoken_text'] ?? question['selected_option_text'] ?? 'No answer'}. '
      'Correct answer ${question['correct_option_spoken_text'] ?? question['correct_option_text']}. '
      '${question['spoken_explanation'] ?? question['explanation'] ?? 'No explanation provided.'}';

  @override
  void dispose() {
    for (final node in _questionNodes.values) {
      node.dispose();
    }
    _messageNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final review = widget.review;
    final questions = review['questions'] as List? ?? const [];
    final message = review['feedback_message'] as String?;
    return KeypadInstructionWrapper(
      screenName:
          'Attempt review. ${questions.isEmpty && message != null ? message : '${questions.length} questions. Use up and down to review each answer.'}',
      labels: const {0: 'Go back'},
      actions: {0: () => Navigator.pop(context)},
      focusTargets: [
        if (questions.isEmpty && message != null)
          KeypadFocusTarget(
            node: _messageNode,
            label: message,
            onActivate: () => TtsService.speak(message),
          ),
        for (var i = 0; i < questions.length; i++)
          KeypadFocusTarget(
            node: _node(i),
            label: _announcement(questions[i] as Map, i),
            onActivate: () =>
                TtsService.speak(_announcement(questions[i] as Map, i)),
          ),
      ],
      child: Scaffold(
        appBar: AppBar(title: const Text('Attempt review')),
        body: questions.isEmpty && review['feedback_message'] is String
            ? SingleChildScrollView(
                padding: UIUtils.paddingAll(context, 12),
                child: Focus(focusNode: _messageNode, child: Text(message!)),
              )
            : SingleChildScrollView(
                padding: UIUtils.paddingAll(context, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: List.generate(questions.length, (index) {
                    final question = questions[index] as Map;
                    final correct = question['is_correct'] == true;
                    final announcement = _announcement(question, index);
                    return Semantics(
                      label: announcement,
                      excludeSemantics: true,
                      button: true,
                      onTap: () => TtsService.speak(announcement),
                      child: Card(
                        child: ListTile(
                          focusNode: _node(index),
                          onTap: () => TtsService.speak(announcement),
                          leading: Icon(
                            correct ? Icons.check_circle : Icons.cancel,
                            color: correct
                                ? Colors.green.shade800
                                : Colors.red.shade800,
                          ),
                          title: Text(
                            '${index + 1}. ${question['question_text']}',
                          ),
                          subtitle: Text(
                            'Your answer: ${question['selected_option_text'] ?? 'Unanswered'}\n'
                            'Correct answer: ${question['correct_option_text']}\n'
                            '${question['explanation'] ?? 'No explanation provided.'}',
                          ),
                        ),
                      ),
                    );
                  }),
                ),
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
  final _validationKey = GlobalKey();
  final _cancelFocus = FocusNode(debugLabel: 'bank-question-cancel');
  final _saveFocus = FocusNode(debugLabel: 'bank-question-save');
  late final List<FocusNode> _optionFocuses;
  static const _metadataLabels = {
    'topics': 'Topics or concepts, one per line (optional)',
    'spoken_question_text': 'Teacher-written spoken question',
    'spoken_option_1': 'Spoken option 1',
    'spoken_option_2': 'Spoken option 2',
    'spoken_option_3': 'Spoken option 3',
    'spoken_option_4': 'Spoken option 4',
    'spoken_explanation': 'Teacher-written spoken explanation',
  };
  final _metadata = <String, TextEditingController>{};
  final _metadataFocuses = <String, FocusNode>{};
  final _notationFocus = FocusNode(debugLabel: 'bank-question-notation');
  final _reviewFocus = FocusNode(debugLabel: 'bank-question-reviewed');
  final _optionalFocus = FocusNode(debugLabel: 'bank-question-optional');
  bool _showOptional = false;
  bool _described = false;
  bool _reviewed = false;
  int? _correct;
  String? _error;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialQuestion;
    final initialOptions = initial?['options'] as List? ?? const [];
    final spokenOptions = initial?['spoken_options'] as List? ?? const [];
    _described = initial?['notation'] == 'described';
    _reviewed = initial?['spoken_reviewed'] == true;
    for (final key in _metadataLabels.keys) {
      final optionIndex = key.startsWith('spoken_option_')
          ? int.parse(key.substring('spoken_option_'.length)) - 1
          : null;
      _metadata[key] = TextEditingController(
        text: key == 'topics'
            ? (initial?['topics'] as List? ?? const []).join('\n')
            : optionIndex != null
            ? (optionIndex < spokenOptions.length
                  ? '${spokenOptions[optionIndex]}'
                  : '')
            : initial?[key] as String? ?? '',
      );
      _metadataFocuses[key] = FocusNode(debugLabel: 'bank-question-$key');
    }
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
    _showOptional =
        _described ||
        _reviewed ||
        _explanation.text.isNotEmpty ||
        _metadata.values.any((controller) => controller.text.isNotEmpty);
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
      _revealQuizError(_validationKey);
      TtsService.speak(_error!);
      return;
    }
    final topics = _metadata['topics']!.text
        .split('\n')
        .map((topic) => topic.trim())
        .where((topic) => topic.isNotEmpty)
        .toList();
    final spokenQuestion = _metadata['spoken_question_text']!.text.trim();
    final spokenOptions = List.generate(
      4,
      (index) => _metadata['spoken_option_${index + 1}']!.text.trim(),
    );
    final spokenExplanation = _metadata['spoken_explanation']!.text.trim();
    final hasSpokenOptions = spokenOptions.any((option) => option.isNotEmpty);
    final hasSpoken =
        hasSpokenOptions ||
        spokenQuestion.isNotEmpty ||
        spokenExplanation.isNotEmpty;
    if (topics.length > 20 ||
        topics.any((topic) => topic.length > 80) ||
        topics.map((topic) => topic.toLowerCase()).toSet().length !=
            topics.length ||
        ((_described || hasSpoken) && !_reviewed) ||
        ((_described || hasSpokenOptions) &&
            spokenOptions.any((option) => option.isEmpty)) ||
        (_described &&
            (spokenQuestion.isEmpty ||
                (_explanation.text.trim().isNotEmpty &&
                    spokenExplanation.isEmpty)))) {
      setState(() {
        _showOptional = true;
        _error =
            'Use up to 20 different topics of 80 characters each. Described notation needs a spoken question, all four spoken options, and a spoken explanation if an explanation is provided. Review and confirm every spoken alternative before saving.';
      });
      _revealQuizError(_validationKey);
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
      'topics': topics,
      'notation': _described ? 'described' : 'plain_text',
      'spoken_question_text': spokenQuestion.isEmpty ? null : spokenQuestion,
      'spoken_options': hasSpokenOptions ? spokenOptions : null,
      'spoken_explanation': spokenExplanation.isEmpty
          ? null
          : spokenExplanation,
      'spoken_reviewed': _reviewed,
    });
  }

  @override
  void dispose() {
    for (final controller in _metadata.values) {
      controller.dispose();
    }
    for (final node in _metadataFocuses.values) {
      node.dispose();
    }
    _notationFocus.dispose();
    _optionalFocus.dispose();
    _reviewFocus.dispose();
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
      navigationSections:
          'question text, four answer fields, correct-answer selection, optional spoken descriptions, and save or cancel',
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
              : 'Option ${_correct! + 1}, ${_options[_correct!].text}, is the correct answer. Use left or right to change',
          onActivate: () => _cycleCorrect(1),
          onDecrease: () => _cycleCorrect(-1),
          onIncrease: () => _cycleCorrect(1),
        ),
        KeypadFocusTarget(
          node: _optionalFocus,
          label:
              '${_showOptional ? 'Hide' : 'Show'} optional explanation, topics and spoken notation',
          onActivate: () => setState(() => _showOptional = !_showOptional),
        ),
        if (_showOptional) ...[
          KeypadFocusTarget(
            node: _explanationFocus,
            label: 'Optional answer explanation. Press OK to edit',
            isTextField: true,
          ),
          KeypadFocusTarget(
            node: _notationFocus,
            label:
                'Content: ${_described ? 'teacher-described notation or diagram' : 'English plain text'}. Press OK to change',
            onActivate: () => setState(() {
              _described = !_described;
              _reviewed = false;
            }),
          ),
          for (final key in _metadataLabels.keys)
            KeypadFocusTarget(
              node: _metadataFocuses[key]!,
              label: '${_metadataLabels[key]}. Press OK to edit',
              isTextField: true,
            ),
          KeypadFocusTarget(
            node: _reviewFocus,
            label:
                'Spoken alternatives reviewed by teacher: ${_reviewed ? 'yes' : 'no'}. Press OK to change',
            onActivate: () => setState(() => _reviewed = !_reviewed),
          ),
        ],
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
        contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(title, style: Theme.of(context).textTheme.headlineSmall),
                const Text(
                  'Complete the question and all four options, then choose the correct answer. For equations or diagrams, expand optional spoken notation and review the alternatives.',
                ),
                const SizedBox(height: 12),
                if (widget.initialQuestion != null)
                  Text(
                    'Revision ${widget.initialQuestion!['revision'] ?? 'unknown (legacy)'}. Saving a new bank revision never rewrites an existing quiz or attempt snapshot.',
                  ),
                if (_error != null)
                  Semantics(
                    key: _validationKey,
                    liveRegion: true,
                    child: Text(_error!),
                  ),
                TextField(
                  controller: _question,
                  focusNode: _questionFocus,
                  onTap: () =>
                      _navigationController.enterTextEditing(_questionFocus),
                  decoration: const InputDecoration(
                    label: Text('Question text'),
                    counterText: '',
                  ),
                  minLines: 2,
                  maxLines: 4,
                  maxLength: 5000,
                  onChanged: (_) => setState(() => _reviewed = false),
                ),
                const SizedBox(height: 10),
                for (var index = 0; index < 4; index++) ...[
                  TextField(
                    controller: _options[index],
                    focusNode: _optionFocuses[index],
                    onTap: () => _navigationController.enterTextEditing(
                      _optionFocuses[index],
                    ),
                    onChanged: (_) => setState(() => _reviewed = false),
                    decoration: InputDecoration(
                      label: Text('Option ${index + 1}'),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                OutlinedButton(
                  focusNode: _correctFocus,
                  onPressed: () => _cycleCorrect(1),
                  child: Column(
                    children: [
                      const Text('Which answer is correct?'),
                      Text(
                        _correct == null
                            ? 'Choose the correct option'
                            : 'Option ${_correct! + 1}: ${_options[_correct!].text}',
                      ),
                      const Text(
                        'Use Left or Right to change. OK or tap selects the next option.',
                      ),
                    ],
                  ),
                ),
                OutlinedButton(
                  focusNode: _optionalFocus,
                  onPressed: () =>
                      setState(() => _showOptional = !_showOptional),
                  child: Text(
                    '${_showOptional ? 'Hide' : 'Show'} optional explanation, topics and spoken notation',
                  ),
                ),
                if (_showOptional) ...[
                  const SizedBox(height: 10),
                  TextField(
                    controller: _explanation,
                    focusNode: _explanationFocus,
                    onTap: () => _navigationController.enterTextEditing(
                      _explanationFocus,
                    ),
                    decoration: const InputDecoration(
                      label: Text('Explanation (optional)'),
                      counterText: '',
                    ),
                    minLines: 2,
                    maxLines: 4,
                    maxLength: 5000,
                    onChanged: (_) => setState(() => _reviewed = false),
                  ),
                  TextButton(
                    focusNode: _notationFocus,
                    onPressed: () => setState(() {
                      _described = !_described;
                      _reviewed = false;
                    }),
                    child: Text(
                      'Content: ${_described ? 'Teacher-described notation or diagram' : 'English plain text'}',
                    ),
                  ),
                  const Text(
                    'No automatic equation or diagram interpretation is provided. Teachers must write and review English spoken alternatives. For described notation, include the question, all options, and any explanation.',
                  ),
                  for (final key in _metadataLabels.keys)
                    TextField(
                      controller: _metadata[key],
                      focusNode: _metadataFocuses[key],
                      onTap: () => _navigationController.enterTextEditing(
                        _metadataFocuses[key]!,
                      ),
                      onChanged: (_) => setState(() => _reviewed = false),
                      minLines: 1,
                      maxLines: key == 'topics' ? 5 : 4,
                      maxLength: key == 'topics' ? null : 5000,
                      decoration: InputDecoration(
                        label: Text(_metadataLabels[key]!),
                        counterText: '',
                      ),
                    ),
                  CheckboxListTile(
                    focusNode: _reviewFocus,
                    value: _reviewed,
                    onChanged: (value) =>
                        setState(() => _reviewed = value == true),
                    title: const Text(
                      'I have reviewed the spoken alternatives for accuracy',
                    ),
                  ),
                ],
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
          ),
        ),
      ),
    );
  }
}

class AccessibleQuizEditorDialog extends StatefulWidget {
  const AccessibleQuizEditorDialog({
    super.key,
    this.practice = false,
    this.initialQuiz,
  });
  final bool practice;
  final Map<String, dynamic>? initialQuiz;

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
  final _optionalFocus = FocusNode(debugLabel: 'quiz-optional-settings');
  bool _showOptional = false;
  final _policyFocus = FocusNode(debugLabel: 'quiz-feedback-policy');
  final _releaseFocus = FocusNode(debugLabel: 'quiz-feedback-release');
  String _policy = 'after_completion';
  DateTime? _releaseAt;
  List<String> get _policies => [
    'after_completion',
    'scheduled',
    'score_only',
    if (widget.initialQuiz?['feedback_policy'] == 'legacy_immediate')
      'legacy_immediate',
    if (widget.initialQuiz?['feedback_policy'] == 'immediate') 'immediate',
  ];
  void _cyclePolicy(int direction) => setState(() {
    _policy =
        _policies[(_policies.indexOf(_policy) + direction) % _policies.length];
    if (_policy != 'scheduled') _releaseAt = null;
  });
  Future<void> _pickRelease() async {
    final selected = await _pickDateTime(_releaseAt);
    if (selected != null && mounted) setState(() => _releaseAt = selected);
  }

  DateTime? _opensAt;
  DateTime? _closesAt;
  bool _shuffleQuestions = false;
  bool _shuffleOptions = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialQuiz;
    if (initial == null) return;
    _title.text = initial['title'] as String;
    _description.text = initial['description'] as String? ?? '';
    _attempts.text = '${initial['attempt_limit'] ?? 1}';
    _timeLimit.text = initial['time_limit_minutes']?.toString() ?? '';
    _opensAt = initial['opens_at'] == null
        ? null
        : DateTime.parse(initial['opens_at'] as String);
    _closesAt = initial['closes_at'] == null
        ? null
        : DateTime.parse(initial['closes_at'] as String);
    _releaseAt = initial['feedback_release_at'] == null
        ? null
        : DateTime.parse(initial['feedback_release_at'] as String);
    _policy = initial['feedback_policy'] as String? ?? 'after_completion';
    _shuffleQuestions = initial['shuffle_questions'] == true;
    _shuffleOptions = initial['shuffle_options'] == true;
    _showOptional = true;
  }

  String _dateTimeLabel(DateTime? value, String emptyLabel) {
    if (value == null) return emptyLabel;
    final local = value.toLocal();
    final minute = local.minute.toString().padLeft(2, '0');
    return '${local.day}/${local.month}/${local.year} at ${local.hour}:$minute';
  }

  Future<void> _pickOpeningTime() async {
    await TtsService.speak(
      'Set opening time using the date and time number fields.',
    );
    final value = await _pickDateTime(_opensAt);
    if (value == null || !mounted) return;
    setState(() => _opensAt = value);
    await TtsService.speak('Opening time set to ${_dateTimeLabel(value, '')}');
    _opensFocus.requestFocus();
  }

  Future<void> _pickClosingTime() async {
    await TtsService.speak(
      'Set closing time using the date and time number fields.',
    );
    final value = await _pickDateTime(_closesAt);
    if (value == null || !mounted) return;
    setState(() => _closesAt = value);
    await TtsService.speak('Closing time set to ${_dateTimeLabel(value, '')}');
    _closesFocus.requestFocus();
  }

  Future<DateTime?> _pickDateTime(DateTime? initial) async {
    final now = DateTime.now();
    return showDialog<DateTime>(
      context: context,
      builder: (_) => KeypadDateTimeDialog(
        initial: (initial ?? now).toLocal(),
        firstDate: now.subtract(const Duration(days: 1)),
        lastDate: now.add(const Duration(days: 730)),
      ),
    );
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
            !_opensAt!.isBefore(_closesAt!)) ||
        (!widget.practice && _policy == 'scheduled' && _releaseAt == null)) {
      setState(() {
        _showOptional = true;
        _error = 'Check the title, limits, and schedule.';
      });
      TtsService.speak(_error!);
      return;
    }
    Navigator.pop(context, {
      'title': _title.text.trim(),
      'mode': widget.practice ? 'practice' : 'graded',
      'feedback_policy': widget.practice ? 'immediate' : _policy,
      'feedback_release_at': widget.practice
          ? null
          : _releaseAt?.toUtc().toIso8601String(),
      'description': _description.text.trim().isEmpty
          ? null
          : _description.text.trim(),
      'attempt_limit': attempts,
      'opens_at': _opensAt?.toUtc().toIso8601String(),
      'closes_at': _closesAt?.toUtc().toIso8601String(),
      'time_limit_minutes': widget.practice ? null : timeLimit,
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
    _optionalFocus.dispose();
    _policyFocus.dispose();
    _releaseFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeypadInstructionWrapper(
      navigationSections:
          'title, optional description, timing and attempt settings, feedback and shuffle choices, and continue or cancel',
      screenName: widget.initialQuiz != null
          ? 'Change quiz title and optional settings. Saving does not publish.'
          : widget.practice
          ? 'Create untimed ungraded practice. Unlimited retries and immediate feedback.'
          : 'Create quiz draft',
      labels: {
        0: 'Cancel',
        8: widget.initialQuiz == null
            ? 'Continue to questions'
            : 'Save settings and return to review',
      },
      actions: {0: () => Navigator.pop(context), 8: _save},
      navigationController: _navigationController,
      focusTargets: [
        KeypadFocusTarget(
          node: _titleFocus,
          label: 'Quiz title. Press OK to edit',
          isTextField: true,
        ),
        KeypadFocusTarget(
          node: _optionalFocus,
          label:
              '${_showOptional ? 'Hide' : 'Show'} optional settings: description, attempts, timing, feedback and shuffle',
          onActivate: () => setState(() => _showOptional = !_showOptional),
        ),
        if (_showOptional) ...[
          KeypadFocusTarget(
            node: _descriptionFocus,
            label: 'Optional quiz description. Press OK to edit',
            isTextField: true,
          ),
          KeypadFocusTarget(
            node: _attemptsFocus,
            label:
                'Attempt limit, currently ${_attempts.text}. Press OK to edit',
            isTextField: true,
            isEnabled: () => !widget.practice,
          ),
          KeypadFocusTarget(
            node: _timeLimitFocus,
            label:
                'Optional time limit in minutes, ${_timeLimit.text.isEmpty ? 'not set' : _timeLimit.text}. Press OK to edit',
            isTextField: true,
            isEnabled: () => !widget.practice,
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
            onActivate: () =>
                setState(() => _shuffleOptions = !_shuffleOptions),
            onDecrease: () =>
                setState(() => _shuffleOptions = !_shuffleOptions),
            onIncrease: () =>
                setState(() => _shuffleOptions = !_shuffleOptions),
          ),
          KeypadFocusTarget(
            node: _cancelFocus,
            label: 'Cancel quiz creation',
            onActivate: () => Navigator.pop(context),
          ),
          if (!widget.practice) ...[
            KeypadFocusTarget(
              node: _policyFocus,
              label: 'Feedback policy $_policy. Left or right changes it',
              onActivate: () => _cyclePolicy(1),
              onDecrease: () => _cyclePolicy(-1),
              onIncrease: () => _cyclePolicy(1),
            ),
            KeypadFocusTarget(
              node: _releaseFocus,
              label:
                  'Scheduled feedback release ${_dateTimeLabel(_releaseAt, 'not set')}',
              isEnabled: () => _policy == 'scheduled',
              onActivate: _pickRelease,
            ),
          ],
        ],
        KeypadFocusTarget(
          node: _saveFocus,
          label: widget.initialQuiz == null
              ? 'Save draft and continue to questions'
              : 'Save settings and return to review',
          onActivate: _save,
        ),
      ],
      child: AlertDialog(
        insetPadding: const EdgeInsets.all(8),
        contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.initialQuiz != null
                      ? 'Change quiz settings'
                      : widget.practice
                      ? 'Create untimed practice'
                      : 'Step 1: Name your quiz',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                if (widget.practice)
                  const Text(
                    'Practice has no per-attempt timer or retry cap. An optional closing time still ends availability.',
                  ),
                Semantics(
                  label:
                      'Use up and down to move through quiz settings. Press OK to edit text fields. Opening and closing times are optional.',
                  child: const Text(
                    'Use Up and Down to move through settings, and OK to edit. Saving a draft or its settings does not publish the quiz.',
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
                  decoration: const InputDecoration(label: Text('Quiz title')),
                ),
                Text(
                  widget.initialQuiz != null
                      ? 'Review and change the saved settings below. Saving does not publish the quiz.'
                      : widget.practice
                      ? 'Ungraded practice. Unlimited attempts, no timer, immediate feedback.'
                      : 'Default graded settings: one attempt, no timer, feedback after final submission.',
                ),
                OutlinedButton(
                  focusNode: _optionalFocus,
                  onPressed: () =>
                      setState(() => _showOptional = !_showOptional),
                  child: Text(
                    '${_showOptional ? 'Hide' : 'Show'} optional settings',
                  ),
                ),
                if (_showOptional) ...[
                  const SizedBox(height: 10),
                  TextField(
                    controller: _description,
                    focusNode: _descriptionFocus,
                    onTap: () => _navigationController.enterTextEditing(
                      _descriptionFocus,
                    ),
                    decoration: const InputDecoration(
                      label: Text('Description (optional)'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _attempts,
                    enabled: !widget.practice,
                    focusNode: _attemptsFocus,
                    onTap: () =>
                        _navigationController.enterTextEditing(_attemptsFocus),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      label: Text('Attempt limit, 1 to 20'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _timeLimit,
                    enabled: !widget.practice,
                    focusNode: _timeLimitFocus,
                    onTap: () =>
                        _navigationController.enterTextEditing(_timeLimitFocus),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      label: Text('Time limit in minutes (optional)'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (widget.practice)
                    const Text(
                      'Untimed and ungraded, unlimited retries. Availability times still apply if set.',
                    ),
                  if (!widget.practice) ...[
                    TextButton(
                      focusNode: _policyFocus,
                      onPressed: () => _cyclePolicy(1),
                      child: Text('Feedback: $_policy'),
                    ),
                    TextButton(
                      focusNode: _releaseFocus,
                      onPressed: _policy == 'scheduled' ? _pickRelease : null,
                      child: Text(
                        'Release: ${_dateTimeLabel(_releaseAt, 'not set')}',
                      ),
                    ),
                  ],
                  Semantics(
                    button: true,
                    label:
                        '${_dateTimeLabel(_opensAt, 'No opening time set')}. Press OK to set opening time. Left clears it.',
                    child: ListTile(
                      focusNode: _opensFocus,
                      leading: const Icon(Icons.event_available),
                      title: Text(_dateTimeLabel(_opensAt, 'No opening time')),
                      subtitle: const Text(
                        'Optional · enter year, month, day, hour and minute',
                      ),
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
                    onChanged: (value) =>
                        setState(() => _shuffleOptions = value),
                    title: const Text('Shuffle options once per attempt'),
                  ),
                ],
                TextButton(
                  focusNode: _cancelFocus,
                  onPressed: () => Navigator.pop(context),
                  child: const Text('0: Cancel'),
                ),
                ElevatedButton(
                  focusNode: _saveFocus,
                  onPressed: _save,
                  child: Text(
                    widget.initialQuiz == null
                        ? '8: Continue to questions'
                        : '8: Save settings',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
