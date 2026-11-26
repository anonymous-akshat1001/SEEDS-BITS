import 'dart:async';

import 'package:flutter/material.dart';
import '../widgets/keypad_choice_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../announcers/quiz_text.dart';
import '../l10n/speech.dart';
import '../services/api_service.dart';
import '../services/feedback_cues.dart';
import '../services/message_center.dart';
import '../services/pending_action.dart';
import '../services/quiz_speech_speed.dart';
import '../services/tts_service.dart';
import '../utils/keypad_actions.dart';
import '../utils/spoken_format.dart';
import '../utils/ui_utils.dart';
import '../widgets/key_instruction_wrapper.dart';
import '../widgets/keypad_confirmation_dialog.dart';
import '../widgets/keypad_date_time_dialog.dart';
import '../widgets/quiz_extra_time_dialog.dart';
import '../widgets/quiz_speech_speed_control.dart';
import 'question_revisions_screen.dart';

void _revealQuizError(GlobalKey key) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(context, alignment: 0.1);
    }
  });
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
      navigationSections: QuizText.actionNavigation,
      labels: {
        0: QuizText.cancel,
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
          label: QuizText.cancelAndReturn,
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
                child: Text(Speech.t.uiCancelKey0),
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

  Future<void> _load({bool preserveError = false, String? announce}) async {
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
      _showError(QuizText.teacherLoadFailed);
      return;
    }
    setState(() {
      _questions = results[0].data as List;
      _quizzes = results[1].data as List;
      _loading = false;
      if (!preserveError) _error = null;
      _quizSaveUncertain = false;
    });
    final summary = QuizText.teacherLoaded(_questions.length, _quizzes.length);
    if (_initialAnnouncementPending) {
      _initialAnnouncementPending = false;
      await TtsService.speak(
        '${buildTtsInstructions(teacherQuizKeyLabels, screenName: QuizText.teacherScreen(widget.className, widget.subjectName))} '
        '${QuizText.teacherIntro} $summary',
      );
    } else {
      if (_error != null) _revealQuizError(_errorKey);
      await TtsService.speak(
        _error ?? (announce == null ? summary : '$announce $summary'),
      );
    }
  }

  /// Shows and cues [message], then refreshes and speaks it with the counts.
  Future<void> _done(String message) async {
    MessageCenter.success(message, speak: false);
    await _load(announce: message);
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
        _showError(QuizText.accountChangedBank);
        return;
      }
      if (!response.isSuccess ||
          result?['question_id'] is! int ||
          result?['revision'] != 1 ||
          result?['question_text'] != value['question_text']) {
        _showError(
          QuizText.questionSaveUnconfirmed(
            response.failure?.message ??
                (result?['revision'] == null && response.isSuccess
                    ? QuizText.missingRevision
                    : QuizText.savedQuestionMismatch),
          ),
        );
        if (response.isSuccess) await _load(preserveError: true);
        return;
      }
      await _done(QuizText.questionSaved);
    } finally {
      _savingQuestion = false;
    }
  }

  Future<void> _editQuestion(Map question) async {
    if (_savingQuestion) return;
    if (question['revision'] is! int) {
      _showError(QuizText.noRevisionForEdit);
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
        _showError(QuizText.accountChangedBank);
        return;
      }
      if (!response.isSuccess ||
          result?['question_id'] != question['question_id'] ||
          result?['revision'] != (question['revision'] as int? ?? 0) + 1 ||
          result?['question_text'] != value['question_text']) {
        _showError(
          QuizText.questionUpdateUnconfirmed(response.failure?.message),
        );
        if (response.isSuccess) await _load(preserveError: true);
        return;
      }
      await TtsService.speak(QuizText.questionUpdated);
      await _load();
    } finally {
      _savingQuestion = false;
    }
  }

  Future<void> _archiveQuestion(Map question) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => KeypadConfirmationDialog(
        title: QuizText.archiveTitle,
        message: QuizText.archiveMessage,
        confirmLabel: QuizText.archiveConfirm,
      ),
    );
    if (confirmed != true) return;
    final result = await ApiService.archiveBankQuestion(
      question['question_id'] as int,
    );
    if (result == null) {
      _showError(QuizText.archiveFailed);
      return;
    }
    await TtsService.speak(QuizText.bankArchived);
    await _load();
  }

  Future<void> _duplicateQuestion(Map question) async {
    final result = await ApiService.duplicateBankQuestion(
      question['question_id'] as int,
    );
    if (result == null) {
      _showError(QuizText.duplicateQuestionFailed);
      return;
    }
    await TtsService.speak(QuizText.bankCopied);
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
        title: QuizText.questionActions(question),
        actions: [
          AccessibleAction(
            value: 'edit',
            label: QuizText.actionEdit,
            icon: Icons.edit,
          ),
          AccessibleAction(
            value: 'duplicate',
            label: QuizText.actionDuplicate,
            icon: Icons.copy,
          ),
          AccessibleAction(
            value: 'archive',
            label: QuizText.actionArchive,
            icon: Icons.archive_outlined,
          ),
          AccessibleAction(
            value: 'revisions',
            label: QuizText.actionRevisions,
            icon: Icons.history,
          ),
          for (final quiz in drafts)
            AccessibleAction(
              value: 'add:${quiz['quiz_id']}',
              label: QuizText.actionAddTo(quiz['title']),
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
      _showError(QuizText.refreshBeforeDraft);
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
        _showError(QuizText.draftUnconfirmed(response.failure?.message));
        return;
      }
      await TtsService.speak(QuizText.draftSaved);
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
      _showError(QuizText.addToQuizFailed);
      return;
    }
    await TtsService.speak(QuizText.snapshotAdded);
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
        title: QuizText.publishTitle,
        message: Speech.t.quizPublishMessageSnapshots('${quiz['title']}'),
        confirmLabel: QuizText.publishConfirm,
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
      _showError(QuizText.publishUnconfirmed);
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
        ? Speech.t.quizNoEligibleToNotify
        : QuizText.published(recipients, sent, failures);
    MessageCenter.show(
      notificationMessage,
      kind: sent == 0 && recipients > 0
          ? MessageKind.error
          : MessageKind.success,
    );
    await _load();
  }

  Future<void> _close(Map quiz) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => KeypadConfirmationDialog(
        title: QuizText.closeTitle,
        message: Speech.t.quizCloseMessageFinalized('${quiz['title']}'),
        confirmLabel: QuizText.closeConfirm,
      ),
    );
    if (confirmed != true) return;
    final result = await ApiService.closeQuiz(quiz['quiz_id'] as int);
    if (result == null) {
      _showError(QuizText.closeFailed);
      return;
    }
    await TtsService.speak(QuizText.quizClosed);
    await _load();
  }

  Future<void> _duplicate(Map quiz) async {
    final result = await ApiService.duplicateQuiz(quiz['quiz_id'] as int);
    if (result == null) {
      _showError(QuizText.duplicateQuizFailed);
      return;
    }
    await TtsService.speak(QuizText.draftCreated);
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
    MessageCenter.error(message);
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
    final t = Speech.t;
    return KeypadInstructionWrapper(
      screenName: QuizText.teacherScreen(widget.className, widget.subjectName),
      navigationSections: t.quizTeacherNavigationPrivate,
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
          label: QuizText.refreshQuizzes,
          onActivate: _load,
        ),
        KeypadFocusTarget(
          node: _searchFocus,
          label: QuizText.searchBank,
          isTextField: true,
        ),
        KeypadFocusTarget(
          node: _createQuestionFocus,
          label: QuizText.createQuestion,
          onActivate: _createQuestion,
        ),
        KeypadFocusTarget(
          node: _createQuizFocus,
          label: QuizText.createQuiz,
          onActivate: _createQuiz,
        ),
        KeypadFocusTarget(
          node: _createPracticeFocus,
          label: QuizText.createPractice,
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
            label: t.quizBankQuestionItem(
              '${question['spoken_question_text'] ?? question['question_text']}',
              '${question['revision'] ?? t.quizRevisionUnknownLegacy}',
            ),
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
                ? t.quizContinueCreatingRaw(
                    '${quiz['title']}',
                    '${quiz['question_count']}',
                  )
                : quiz['status'] == 'published'
                ? t.quizCloseNamed('${quiz['title']}')
                : t.quizIsClosed('${quiz['title']}'),
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
            label: QuizText.quizDuplicate(quiz),
            onActivate: () => _duplicate(quiz),
          ),
          KeypadFocusTarget(
            node: _quizResultsFocuses.putIfAbsent(
              quiz['quiz_id'] as int,
              () => FocusNode(
                debugLabel: 'teacher-quiz-results-${quiz['quiz_id']}',
              ),
            ),
            label: QuizText.quizResults(quiz),
            onActivate: () => _showSummary(quiz),
          ),
        ],
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(Speech.t.quizQuizzesTitle),
          actions: [
            IconButton(
              focusNode: _refreshFocus,
              onPressed: _load,
              tooltip: Speech.t.quizRefreshQuizzesTooltip,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: _loading
            ? Center(
                child: Semantics(
                  liveRegion: true,
                  label: Speech.t.quizLoadingQuizzes,
                  child: const CircularProgressIndicator(),
                ),
              )
            : RefreshIndicator(
                onRefresh: _load,
                child: ListView(
                  padding: UIUtils.paddingAll(context, 12),
                  children: [
                    Text(
                      Speech.t.quizClassSubjectHeading(
                        widget.className,
                        widget.subjectName,
                      ),
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
                      decoration: InputDecoration(
                        labelText: Speech.t.quizSearchBank,
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
                          label: Text(Speech.t.quizNewBankQuestionKey2),
                        ),
                        ElevatedButton.icon(
                          focusNode: _createQuizFocus,
                          onPressed: _createQuiz,
                          icon: const Icon(Icons.quiz_outlined),
                          label: Text(Speech.t.quizNewDraftKey3),
                        ),
                        OutlinedButton(
                          focusNode: _createPracticeFocus,
                          onPressed: () => _createQuiz(practice: true),
                          child: Text(Speech.t.quizCreatePracticeKey4),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      Speech.t.quizPrivateBankHeading,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(Speech.t.quizBankEditNote),
                    if (_questions.isEmpty)
                      ListTile(
                        leading: const Icon(Icons.inbox_outlined),
                        title: Text(Speech.t.quizNoBankQuestions),
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
                              Speech.t.quizOptionsCount(
                                '${(question['options'] as List).length}',
                              ),
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
                              label: Text(Speech.t.quizOptionsButton),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    Text(
                      Speech.t.quizManagementHeading,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (_quizzes.isEmpty)
                      ListTile(
                        leading: const Icon(Icons.inbox_outlined),
                        title: Text(Speech.t.quizNoQuizzesYet),
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
    _report(QuizText.accountChanged);
    return false;
  }

  Future<void> _load() async {
    if (!_sameAccount) {
      if (mounted) setState(() => _busy = false);
      _report(QuizText.accountChanged);
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
      _report(QuizText.draftAccountChanged);
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
      _report(QuizText.draftLoadFailed);
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
        // Every saved question this teacher owns, so one question can be
        // reused in many quizzes, in this or another class or subject.
        final response = await ApiService.getResult(
          '/question-bank?limit=200',
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
          _report(QuizText.bankRefreshFailed(response.failure?.message));
          return;
        }
        setState(() => _bank = bank.cast<Map<String, dynamic>>());
        final existing = _questions
            .map((item) => (item as Map)['source_question_id'])
            .toSet();
        bool here(Map<String, dynamic> item) =>
            item['class_id'] == widget.classId &&
            item['subject_id'] == widget.subjectId;
        final eligible =
            _bank
                .where(
                  (item) =>
                      item['is_archived'] != true &&
                      !existing.contains(item['question_id']),
                )
                .toList()
              // This class and subject first; the rest keep their order.
              ..sort((a, b) => (here(a) ? 0 : 1).compareTo(here(b) ? 0 : 1));
        if (eligible.isEmpty) {
          _report(Speech.t.quizAllSavedQuestionsUsed);
          return;
        }
        final selected = await showDialog<String>(
          context: context,
          builder: (_) => AccessibleActionDialog(
            title: QuizText.chooseSaved,
            actions: [
              for (final question in eligible)
                AccessibleAction(
                  value: '${question['question_id']}',
                  label: here(question)
                      ? '${question['spoken_question_text'] ?? question['question_text']}'
                      : Speech.t.quizSavedQuestionFrom(
                          '${question['spoken_question_text'] ?? question['question_text']}',
                          '${question['class_name'] ?? Speech.t.quizAnotherClass}',
                          '${question['subject_name'] ?? Speech.t.quizAnotherSubject}',
                        ),
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
        _report(QuizText.addUnconfirmed(response.failure?.message));
        return;
      }
      setState(() {
        _quiz = saved;
        _error = null;
      });
      await TtsService.speak(
        [
          Speech.t.quizQuestionAddedSentence,
          Speech.t.quizQuestionsSavedRaw('${_questions.length}'),
          Speech.t.quizAddAnotherOrReview,
        ].join(' '),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String get _summary {
    final t = Speech.t;
    final quiz = _quiz!;
    return [
      t.quizDraftSummaryHeadRaw(
        '${quiz['title']}',
        '${quiz['description'] ?? ''}',
        '${_questions.length}',
      ),
      quiz['mode'] == 'practice'
          ? t.quizUngradedPracticeSummary
          : '${t.quizGradedSummaryRaw('${quiz['attempt_limit']}')} '
                '${quiz['time_limit_minutes'] == null ? t.quizNoTimer : t.quizMinutesPerAttemptRaw('${quiz['time_limit_minutes']}')}',
      QuizText.feedbackPolicy(quiz),
      t.quizOpensColon('${quiz['opens_at'] ?? t.quizWhenPublished}'),
      t.quizClosesColon('${quiz['closes_at'] ?? t.quizNotScheduled}'),
      t.quizShuffleQuestionsColon(
        SpokenFormat.onOff(quiz['shuffle_questions'] == true),
      ),
      t.quizShuffleOptionsColon(
        SpokenFormat.onOff(quiz['shuffle_options'] == true),
      ),
    ].join(' ');
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
          title: QuizText.removeChoose,
          actions: [
            for (var i = 0; i < _questions.length; i++)
              AccessibleAction(
                value: '${_questions[i]['quiz_question_id']}',
                label: QuizText.removeOption(i, _questions[i]['question_text']),
                icon: Icons.remove_circle_outline,
              ),
          ],
        ),
      );
      if (selected == null || !mounted || !_requireAccount()) return;
      final confirmed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => KeypadConfirmationDialog(
          title: QuizText.removeTitle,
          message: QuizText.removeMessage,
          confirmLabel: QuizText.removeConfirm,
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
        _report(QuizText.removeUnconfirmed);
        return;
      }
      await TtsService.speak(
        '${Speech.t.quizQuestionRemovedSentence} '
        '${Speech.t.quizQuestionsSavedRaw('${_questions.length}')}',
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
        _report(QuizText.settingsUnconfirmed);
        return;
      }
      setState(() {
        _quiz = saved;
        _error = null;
      });
      await TtsService.speak(QuizText.settingsSaved);
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
    final t = Speech.t;
    final published = _quiz?['status'] == 'published';
    final targets = <KeypadFocusTarget>[
      KeypadFocusTarget(
        node: _node('refresh'),
        label: t.quizRefreshSavedDraft,
        onActivate: _load,
        isEnabled: () => !_busy,
      ),
      if (_draft && !_review) ...[
        KeypadFocusTarget(
          node: _node('write'),
          label: t.quizWriteQuestionTarget,
          onActivate: () => _add(reuse: false),
          isEnabled: () => !_busy && !_needsRefresh,
        ),
        KeypadFocusTarget(
          node: _node('reuse'),
          label: QuizText.chooseSaved,
          onActivate: () => _add(reuse: true),
          isEnabled: () => !_busy && !_needsRefresh,
        ),
        KeypadFocusTarget(
          node: _node('review'),
          label: t.quizReviewBeforePublishingTarget,
          onActivate: () => setState(() => _review = true),
          isEnabled: () => !_busy && !_needsRefresh && _questions.isNotEmpty,
        ),
        if (_questions.isNotEmpty)
          KeypadFocusTarget(
            node: _node('remove'),
            label: t.quizRemoveQuestionTarget,
            onActivate: _removeQuestion,
            isEnabled: () => !_busy && !_needsRefresh,
          ),
        for (var index = 0; index < _questions.length; index++)
          KeypadFocusTarget(
            node: _node('saved-question-$index'),
            label: QuizText.savedQuestion(
              index,
              _questions[index]['question_text'],
            ),
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
            label: t.quizChangeSettingsTarget,
            onActivate: _editSettings,
            isEnabled: () => !_busy && !_needsRefresh,
          ),
        if (_draft)
          KeypadFocusTarget(
            node: _node('back'),
            label: t.quizBackToAdding,
            onActivate: () => setState(() => _review = false),
            isEnabled: () => !_busy,
          ),
        if (_draft)
          KeypadFocusTarget(
            node: _node('publish'),
            label: t.quizPublishWithConfirmation,
            onActivate: _publish,
            isEnabled: () => !_busy && !_needsRefresh && _questions.isNotEmpty,
          ),
      ],
      KeypadFocusTarget(
        node: _node('finish'),
        label: published ? QuizText.returnToQuizzes : t.quizSaveForLaterTarget,
        onActivate: () => Navigator.pop(context),
        isEnabled: () => !_busy,
      ),
    ];
    return PopScope(
      canPop: !_busy,
      child: KeypadInstructionWrapper(
        navigationSections: _review
            ? t.quizDraftNavigationReview
            : t.quizDraftNavigationAdd,
        screenName: published
            ? t.quizPublishedScreen
            : _review
            ? t.quizDraftStep3
            : t.quizDraftStep2,
        labels: {
          0: t.quizSaveForLater,
          1: t.keyRefresh,
          if (_draft && !_review) 2: t.quizWriteQuestion,
          if (_draft && !_review) 3: t.quizUseSavedQuestion,
          if (_draft && !_review && _questions.isNotEmpty)
            4: t.quizRemoveQuestion,
          if (_draft && !_review) 5: t.quizReview,
          if (_draft && _review) 3: t.quizPublishConfirmLabel,
          if (_draft && _review) 2: t.quizChangeSettingsLabel,
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
            5: () {
              if (!_busy && !_needsRefresh && _questions.isNotEmpty) {
                setState(() => _review = true);
              }
            },
          if (_draft && _review) 3: _publish,
          if (_draft && _review) 2: _editSettings,
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
                        ? Speech.t.quizPublishedScreen
                        : _review
                        ? Speech.t.quizStepReviewPublish
                        : Speech.t.quizStepAddQuestions,
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

  String _reviewQuestion(int index) =>
      QuizText.reviewDraftQuestion(_questions[index] as Map, index);
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
                      label: Text(Speech.t.quizContinueCreation),
                    ),
                  if (quiz['status'] == 'published')
                    TextButton.icon(
                      focusNode: primaryFocus,
                      onPressed: onClose,
                      icon: const Icon(Icons.lock_clock),
                      label: Text(Speech.t.quizCloseButton),
                    ),
                  TextButton.icon(
                    focusNode: duplicateFocus,
                    onPressed: onDuplicate,
                    icon: const Icon(Icons.copy),
                    label: Text(Speech.t.quizDuplicateButton),
                  ),
                  TextButton.icon(
                    focusNode: resultsFocus,
                    onPressed: onResults,
                    icon: const Icon(Icons.analytics_outlined),
                    label: Text(Speech.t.quizResultsButton),
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
    final t = Speech.t;
    final summary = _summary!;
    String value(Object? score) => '${score ?? t.quizNotAvailableCapital}';
    return [
      t.quizStatEligible('${summary['eligible_students']}'),
      t.quizStatStarted('${summary['started']}'),
      t.quizStatCompleted('${summary['completed']}'),
      t.quizStatNotAttempted('${summary['not_attempted']}'),
      t.quizStatCompletionPercent('${summary['completion_percentage']}'),
      summary['mode'] == 'practice'
          ? t.quizPracticeParticipation
          : [
              t.quizStatAverageHighest(value(summary['average_highest_score'])),
              t.quizHighestScoreValue(value(summary['highest_score'])),
              t.quizStatLowest(value(summary['lowest_completed_score'])),
            ].join('\n'),
    ].join('\n');
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
        _error = QuizText.resultsFailed;
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
      Speech.t.quizResultsLoadedRaw(
        '${_summary!['completed']}',
        '${_summary!['not_attempted']}',
      ),
    );
  }

  String _studentDetails(Map student) {
    final t = Speech.t;
    final name = '${student['student_name']}';
    final attempts = student['attempts'] as List? ?? const [];
    if (attempts.isEmpty) {
      return t.quizStudentNotAttempted(name);
    }
    if (_summary?['mode'] == 'practice') {
      return t.quizStudentPracticeRaw(name, '${attempts.length}');
    }
    final scores = attempts
        .map(
          (attempt) => t.quizStudentAttemptRaw(
            '${attempt['attempt_number']}',
            '${attempt['percentage_score']}',
            '${attempt['status']}',
          ),
        )
        .join('. ');
    return t.quizStudentScoresRaw(
      name,
      '${student['highest_score'] ?? t.quizNotAvailable}',
      scores,
    );
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
        final message = result.failure?.message ?? QuizText.extraMismatch;
        setState(() => _error = message);
        await TtsService.speak(message);
        return;
      }
      await _load();
      await TtsService.speak(QuizText.extraSaved);
    } finally {
      if (mounted) setState(() => _savingExtra.remove(id));
    }
  }

  Future<void> _remind() async {
    if (_notAttempted.isEmpty) {
      await TtsService.speak(QuizText.everyoneAttempted);
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => KeypadConfirmationDialog(
        title: QuizText.remindTitle,
        message: Speech.t.quizRemindMessageRaw(
          '${_notAttempted.length}',
          widget.quizTitle,
        ),
        confirmLabel: QuizText.remindConfirm,
      ),
    );
    if (confirmed != true) return;
    final result = await ApiService.remindQuizStudents(widget.quizId);
    if (!mounted) return;
    if (result == null) {
      setState(() => _error = QuizText.remindFailed);
      await TtsService.speak(_error!);
      return;
    }
    final message = Speech.t.quizReminderProcessed(
      '${result['students_notified']}',
      '${result['device_notifications_queued']}',
    );
    MessageCenter.success(message);
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
    final t = Speech.t;
    return KeypadInstructionWrapper(
      screenName: QuizText.resultsScreen(widget.quizTitle),
      navigationSections: QuizText.resultsNavigation,
      labels: {
        0: QuizText.returnToQuizzes,
        1: t.quizRefreshResultsLabel,
        2: t.quizRemindAllLabel,
      },
      actions: {0: () => Navigator.pop(context), 1: _load, 2: _remind},
      focusTargets: [
        KeypadFocusTarget(
          node: _refreshFocus,
          label: QuizText.refreshResults,
          onActivate: _load,
        ),
        KeypadFocusTarget(
          node: _remindFocus,
          label: _notAttempted.isEmpty
              ? QuizText.remindUnavailable
              : t.quizRemindTargetRaw('${_notAttempted.length}'),
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
              label: t.quizExtraTargetRaw(
                '${student['student_name']}',
                '${student['extra_time_minutes'] ?? 0}',
              ),
              isEnabled: () => !_savingExtra.contains(student['student_id']),
              onActivate: () => _extraTime(student as Map),
            ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(Speech.t.quizResultsTitle(widget.quizTitle)),
          actions: [
            IconButton(
              focusNode: _refreshFocus,
              onPressed: _load,
              tooltip: Speech.t.quizRefreshResultsTooltip,
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
                        Speech.t.quizClassStatistics,
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
                            ? Speech.t.quizAllAttempted
                            : Speech.t.quizRemindAllKey2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      Speech.t.quizStudentsYetToAttempt,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      _notAttempted.isEmpty
                          ? Speech.t.uiNoneCapital
                          : _notAttempted
                                .map((student) => student['student_name'])
                                .join(', '),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      summary?['mode'] == 'practice'
                          ? Speech.t.quizPracticeParticipationHeading
                          : Speech.t.quizIndividualScores,
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
                                    ? Speech.t.quizNotAttempted
                                    : '${summary?['mode'] == 'practice' ? Speech.t.quizPracticeNotGraded : Speech.t.quizHighestScore('${student['highest_score'] ?? Speech.t.quizAttemptInProgress}')}\n'
                                          '${Speech.t.quizAttemptCount((student['attempts'] as List).length)}',
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
  static String get _navigationHelp => Speech.t.quizStudentNavigationHelp;
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
        ? Speech.t.quizNoQuizzesAvailable
        : Speech.t.quizQuizzesAvailableRaw('${quizzes.length}');
    if (_initialAnnouncementPending) {
      _initialAnnouncementPending = false;
      await TtsService.speak(
        '${buildTtsInstructions(studentQuizKeyLabels, screenName: QuizText.studentScreen)} '
        '$_navigationHelp $summary',
      );
    } else {
      await TtsService.speak(summary);
    }
  }

  Future<void> _openQuiz(Map quiz) async {
    final t = Speech.t;
    final inProgress = quiz['in_progress_attempt_id'];
    if (!_canOpenQuiz(quiz)) {
      _announceError(t.quizAttemptLimitReached('${quiz['title']}'));
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => KeypadConfirmationDialog(
        title: QuizText.startTitle(inProgress != null),
        message: [
          t.quizTitleSentence('${quiz['title']}'),
          QuizText.attemptsText(quiz),
          quiz['time_limit_minutes'] == null
              ? t.quizNoPerAttemptLimit
              : t.quizTimeLimitRaw('${quiz['time_limit_minutes']}'),
          QuizText.answerLockNotice,
          t.quizCannotGoBack,
          QuizText.feedbackPolicy(quiz),
        ].join(' '),
        confirmLabel: QuizText.startConfirm(inProgress != null),
      ),
    );
    if (confirmed != true) return;
    final attempt = await ApiService.startQuizAttempt(quiz['quiz_id'] as int);
    if (!mounted) return;
    if (attempt == null) {
      _announceError(t.quizStartFailedAvailability);
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
      _announceError(QuizText.historyFailed);
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
    MessageCenter.error(message);
  }

  void _cycleState(int direction) {
    const states = <String?>[null, 'scheduled', 'open', 'closed'];
    var index = states.indexOf(_stateFilter);
    index = (index + direction) % states.length;
    if (index < 0) index += states.length;
    setState(() => _stateFilter = states[index]);
    TtsService.speak(
      KeypadChoiceField.describe(
        Speech.t.quizStateFieldName,
        states,
        _stateFilter,
        _stateName,
      ),
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
      KeypadChoiceField.describe(
        Speech.t.quizSubjectFieldName,
        subjects,
        _subjectFilter,
        (_) => selected == null ? QuizText.allSubjects : '${selected['name']}',
      ),
    );
    _load();
  }

  static const _stateChoices = <String?>[null, 'scheduled', 'open', 'closed'];
  static String _stateName(String? state) => switch (state) {
    'scheduled' || 'open' || 'closed' => QuizText.stateName(state),
    _ => QuizText.stateName(null),
  };

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
    final t = Speech.t;
    String subjectName(int? id) => id == null
        ? QuizText.allSubjects
        : '${_subjects.firstWhere((item) => item['id'] == id)['name']}';
    return KeypadInstructionWrapper(
      screenName: QuizText.studentScreen,
      introduction: _navigationHelp,
      navigationSections: t.quizStudentNavigationSections,
      labels: studentQuizKeyLabels,
      autoPlay: false,
      actions: {0: () => Navigator.pop(context), 1: _load},
      focusTargets: [
        KeypadFocusTarget(
          node: _refreshFocus,
          label: t.keyRefreshQuizzes,
          onActivate: _load,
        ),
        KeypadFocusTarget(
          node: _stateFilterFocus,
          label: t.quizUseLeftRightToChange(
            KeypadChoiceField.describe(
              t.quizStateFieldName,
              _stateChoices,
              _stateFilter,
              _stateName,
            ),
          ),
          onActivate: () => _cycleState(1),
          onDecrease: () => _cycleState(-1),
          onIncrease: () => _cycleState(1),
        ),
        KeypadFocusTarget(
          node: _subjectFilterFocus,
          label: t.quizUseLeftRightToChange(
            KeypadChoiceField.describe<int?>(
              t.quizSubjectFieldName,
              [null, ..._subjects.map((item) => item['id'] as int)],
              _subjectFilter,
              subjectName,
            ),
          ),
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
              label: [
                t.quizRowHead(
                  '${quiz['subject_name']}',
                  '${quiz['title']}',
                  '${quiz['display_status']}',
                ),
                QuizText.attemptsText(quiz),
                quiz['in_progress_attempt_id'] == null
                    ? t.quizStartQuiz
                    : t.quizResumeQuiz,
              ].join(' '),
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
              label: t.quizHistoryRow(
                '${quiz['title']}',
                '${quiz['highest_score'] ?? t.quizNotAvailable}',
              ),
              onActivate: () => _history(quiz),
            ),
        ],
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(Speech.t.quizQuizzesTitle),
          actions: [
            IconButton(
              focusNode: _refreshFocus,
              onPressed: _load,
              tooltip: Speech.t.quizRefreshQuizzesTooltip,
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
                        KeypadChoiceField<String?>(
                          label: t.quizStateFieldName,
                          focusNode: _stateFilterFocus,
                          values: _stateChoices,
                          value: _stateFilter,
                          nameOf: _stateName,
                          onChanged: (value) {
                            setState(() => _stateFilter = value);
                            _load();
                          },
                        ),
                        KeypadChoiceField<int?>(
                          label: t.quizSubjectFieldName,
                          focusNode: _subjectFilterFocus,
                          values: [
                            null,
                            ..._subjects.map((item) => item['id'] as int),
                          ],
                          value: _subjectFilter,
                          nameOf: subjectName,
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
                        child: ListTile(
                          leading: const Icon(Icons.inbox_outlined),
                          title: Text(Speech.t.quizNoQuizzesAvailableLabel),
                        ),
                      )
                    else
                      ..._quizzes.map(
                        (quiz) => Semantics(
                          label:
                              '${quiz['subject_name']}, ${quiz['title']}. Status ${quiz['display_status']}. ${QuizText.attemptsText(quiz)}',
                          child: Card(
                            child: ListTile(
                              leading: const Icon(Icons.quiz_outlined),
                              title: Text('${quiz['title']}'),
                              subtitle: Text(
                                '${quiz['subject_name']} · ${quiz['display_status']}\n'
                                '${quiz['description'] ?? 'No description'}\n'
                                '${QuizText.attemptsText(quiz)}'
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
                                          ? Speech.t.quizStartQuiz
                                          : Speech.t.quizResumeQuiz,
                                      icon: const Icon(Icons.play_arrow),
                                    ),
                                  if (!_canOpenQuiz(quiz) &&
                                      quiz['display_status'] == 'open' &&
                                      quiz['mode'] != 'practice' &&
                                      (quiz['attempts_remaining'] as int? ??
                                              0) ==
                                          0)
                                    Tooltip(
                                      message:
                                          Speech.t.quizAttemptLimitReachedLabel,
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
                                      tooltip: Speech.t.quizHistoryTooltip,
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
    this.returnWhenFinished = false,
  });

  final String quizTitle;
  final Map<String, dynamic> initialAttempt;

  /// Opened from a live class: once the quiz is finished, say so and go
  /// back to the class by itself. From Home the result screen stays.
  final bool returnWhenFinished;

  @override
  State<QuizAttemptScreen> createState() => _QuizAttemptScreenState();
}

class _QuizAttemptScreenState extends State<QuizAttemptScreen> {
  final _keypad = KeypadNavigationController();
  late final _speechSpeed = QuizSpeechSpeed(this);
  final _speedFocus = FocusNode(debugLabel: 'quiz-speech-speed');
  late Map<String, dynamic> _attempt;
  int? _selectedOptionId;
  Map<String, dynamic>? _feedback;
  bool _submitting = false;

  /// The answer is kept on the phone until the connection is back.
  bool _answerQueued = false;
  bool _completing = false;
  String? _completionError;
  Timer? _timer;
  Duration? _remaining;
  // Each warning is spoken once when its threshold is crossed, so a late or
  // skipped timer tick can never swallow it.
  static const _timeWarnings = [
    Duration(minutes: 5),
    Duration(minutes: 2),
    Duration(minutes: 1),
    Duration(seconds: 30),
    Duration(seconds: 10),
  ];
  final Set<Duration> _spokenWarnings = {};
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
  final _previousFeedbackFocus = FocusNode(
    debugLabel: 'quiz-previous-feedback',
  );
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
    unawaited(
      _speechSpeed.start().then((_) {
        if (mounted) setState(() {});
      }),
    );
    _configureTimer();
    if (_attempt['status'] != 'in_progress') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _keypad.focusAndAnnounce(
            _returnFocus,
            '${Speech.t.quizAttemptCompletePrivate} $_navigationHelp',
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
      final saved = _attempt['answered_count'] as int? ?? 0;
      unawaited(
        TtsService.speak(
          QuizText.timeUp(saved),
          priority: SpeechPriority.critical,
        ),
      );
      _complete();
      return;
    }
    final crossed = _timeWarnings.where(
      (threshold) =>
          remaining <= threshold && !_spokenWarnings.contains(threshold),
    );
    if (crossed.isNotEmpty) {
      // Several thresholds can be crossed at once (for example when the quiz
      // opens late or the phone resumes); speak once, with the true time.
      final smallest = crossed.last;
      _spokenWarnings.addAll(crossed);
      final spoken = smallest - remaining < const Duration(seconds: 2)
          ? smallest
          : Duration(seconds: remaining.inSeconds);
      unawaited(
        TtsService.speak(
          QuizText.timeWarning(spoken),
          priority: SpeechPriority.critical,
        ),
      );
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

  int get _questionNumber {
    final answered = _attempt['answered_count'] as int? ?? 0;
    return _feedback == null ? answered + 1 : answered;
  }

  String get _questionAnnouncement => QuizText.question(
    _questionNumber,
    _attempt['total_questions'],
    _question?['spoken_question_text'] ?? _question?['question_text'] ?? '',
  );

  String get _optionsAnnouncement {
    final options = _question?['options'] as List? ?? const [];
    return QuizText.options([
      for (final option in options)
        '${option['spoken_option_text'] ?? option['option_text']}',
    ]);
  }

  String get _questionAndOptions =>
      '$_questionAnnouncement $_optionsAnnouncement';

  String get _navigationHelp {
    final t = Speech.t;
    final speed = '${QuizText.speedHelp} ';
    if (_attempt['status'] != 'in_progress') {
      return '${t.quizHelpCompleted} $speed';
    }
    if (_completionError != null) {
      return '${t.quizHelpRetry} $speed';
    }
    if (_feedback != null || _allAnswersSaved) {
      return '${t.quizHelpNext} $speed';
    }
    final count = _question?['options'] is List
        ? (_question!['options'] as List).length
        : 4;
    return '${t.quizHelpChoose('$count')} $speed${t.quizHelpFinishLeave}';
  }

  void _readOptions() => TtsService.speak(_optionsAnnouncement);

  Future<void> _changeSpeechSpeed(int steps) async {
    await _speechSpeed.change(steps);
    if (mounted) setState(() {});
  }

  void _readSelection() {
    final options = _question?['options'] as List? ?? const [];
    for (var index = 0; index < options.length; index++) {
      if (options[index]['quiz_option_id'] == _selectedOptionId) {
        final number = '${index + 1}';
        final text =
            '${options[index]['spoken_option_text'] ?? options[index]['option_text']}';
        TtsService.speak(
          _feedback == null
              ? Speech.t.quizSelectedOptionNotSubmitted(number, text)
              : Speech.t.quizSelectedOptionConfirmed(number, text),
        );
        return;
      }
    }
    TtsService.speak(QuizText.noAnswerSelected);
  }

  String get _feedbackAnnouncement => _feedbackText(_feedback!);

  String _feedbackText(Map<String, dynamic> feedback) {
    if (feedback['feedback_released'] == false) {
      return '${QuizText.answerSaved(hasFeedback: false)} ${feedback['feedback_message']}';
    }
    final answer =
        '${feedback['correct_option_spoken_text'] ?? feedback['correct_option_text']}';
    final explanation =
        '${feedback['spoken_explanation'] ?? feedback['explanation'] ?? ''}';
    return feedback['is_correct'] == true
        ? Speech.t.quizFeedbackCorrect(answer, explanation)
        : Speech.t.quizFeedbackIncorrect(answer, explanation);
  }

  /// Released feedback for the question just answered. The attempt moves on
  /// by itself, so feedback stays available here, read only on request.
  Map<String, dynamic>? _previousFeedback;

  void _selectOption(int index) {
    if (!_canAnswer) return;
    final options = _question?['options'];
    if (options is! List || index >= options.length) return;
    final option = options[index] as Map;
    setState(() => _selectedOptionId = option['quiz_option_id'] as int);
    TtsService.speak(
      Speech.t.quizOptionSelectedNotSubmitted(
        '${index + 1}',
        '${option['spoken_option_text'] ?? option['option_text']}',
      ),
    );
  }

  void _readPrivateFeedback() {
    final feedback = _feedback ?? _previousFeedback;
    if (feedback == null) return;
    setState(() => _feedbackReadRequested = true);
    // Correctness sounds only when the student asks, like the spoken
    // feedback, so classmates nearby cannot hear the result.
    if (feedback['feedback_released'] != false) {
      unawaited(
        FeedbackCues.play(
          feedback['is_correct'] == true ? Cue.correct : Cue.wrong,
        ),
      );
    }
    TtsService.speak(_feedbackText(feedback));
  }

  void _readPrivateResult() {
    setState(() => _resultReadRequested = true);
    TtsService.speak(QuizText.attemptResult(_attempt));
  }

  Future<void> _submit() async {
    if (!_canAnswer) return;
    final question = _question;
    if (question == null || _selectedOptionId == null) {
      TtsService.speak(QuizText.selectBeforeSubmit);
      return;
    }
    setState(() => _submitting = true);
    final attemptId = _attempt['attempt_id'] as int;
    final questionId = question['quiz_question_id'] as int;
    final optionId = _selectedOptionId!;
    // With no connection the answer is kept and sent when it is back, so
    // the student never has to answer again.
    final response = await sendWhenConnected(
      () => ApiService.submitQuizAnswer(
        attemptId: attemptId,
        questionId: questionId,
        optionId: optionId,
      ),
      stillWanted: () => mounted && _attempt['status'] == 'in_progress',
      onQueued: () {
        if (!mounted) return;
        setState(() => _answerQueued = true);
        unawaited(TtsService.speak(Speech.t.quizAnswerQueued));
      },
    );
    if (!mounted) return;
    setState(() {
      _submitting = false;
      _answerQueued = false;
    });
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
      MessageCenter.error(QuizText.answerFailed(response.failure?.message));
      return;
    }
    unawaited(FeedbackCues.play(Cue.saved));
    setState(() {
      _feedback = result;
      _feedbackReadRequested = false;
      _attempt = {
        ..._attempt,
        'answered_count': (_attempt['answered_count'] as int? ?? 0) + 1,
      };
    });
    // Say only that it is saved (feedback stays private), then move on by
    // itself once that has been spoken.
    await TtsService.speak(
      QuizText.answerSaved(hasFeedback: result['feedback_released'] != false),
    );
    _afterSpeech(() {
      if (mounted && identical(_feedback, result)) unawaited(_next());
    });
  }

  /// Runs [action] once current speech ends (or at once if silent).
  void _afterSpeech(VoidCallback action) {
    if (!TtsService.speaking.value) {
      action();
      return;
    }
    void listener() {
      if (TtsService.speaking.value) return;
      TtsService.speaking.removeListener(listener);
      action();
    }

    TtsService.speaking.addListener(listener);
  }

  String get _whereAmI {
    final options = _question?['options'] as List? ?? const [];
    final selected = options.indexWhere(
      (option) => option['quiz_option_id'] == _selectedOptionId,
    );
    final answered = _attempt['answered_count'] as int? ?? 0;
    if (_attempt['status'] != 'in_progress') {
      return Speech.t.quizAttemptFinishedWhere;
    }
    return QuizText.where(
      number: _feedback == null ? answered + 1 : answered,
      total: _attempt['total_questions'],
      answered: answered,
      selection: selected < 0
          ? (_feedback == null ? Speech.t.quizNoOptionChosenYet : null)
          : Speech.t.quizOptionChosen('${selected + 1}'),
      remaining: _remaining,
      timed: _remaining != null,
    );
  }

  Future<void> _next() async {
    if (_attempt['status'] != 'in_progress' ||
        _submitting ||
        _completing ||
        _exitDialog) {
      return;
    }
    if (_feedback == null && !_allAnswersSaved) {
      await TtsService.speak(QuizText.submitBeforeContinuing);
      return;
    }
    final next = _feedback?['next_question'];
    if (next == null) {
      await _complete();
      return;
    }
    setState(() {
      _previousFeedback = _feedback?['feedback_released'] == false
          ? null
          : _feedback;
      _attempt = {..._attempt, 'question': next};
      _selectedOptionId = null;
      _feedback = null;
      _feedbackReadRequested = false;
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
      final message = Speech.t.quizCompletionFailedRetry(
        response.failure?.message ?? Speech.t.quizCompletionNotConfirmed,
      );
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
    if (widget.returnWhenFinished) {
      await TtsService.speak(
        Speech.t.quizAttemptStatusPrivate('${result['status']}'),
      );
      _afterSpeech(() {
        if (mounted) Navigator.pop(context);
      });
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _keypad.focusAndAnnounce(
          _returnFocus,
          '${Speech.t.quizAttemptStatusPrivate('${result['status']}')} $_navigationHelp',
        );
      }
    });
  }

  String get _remainingText {
    final value = _remaining;
    if (value == null) return Speech.t.quizNoTimeLimitShort;
    final minutes = value.inMinutes;
    final seconds = value.inSeconds.remainder(60).toString().padLeft(2, '0');
    return Speech.t.quizClockRemaining('$minutes:$seconds');
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
        final message = Speech.t.quizEarlyCountUnconfirmed;
        setState(() => _earlyFinishError = message);
        await TtsService.speak(message);
        return;
      }
      final unanswered = total - answered;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (_) => KeypadConfirmationDialog(
          title: Speech.t.quizEarlyTitle,
          message: Speech.t.quizEarlyMessage('$unanswered'),
          confirmLabel: Speech.t.quizEarlyConfirm,
          cancelLabel: QuizText.finishCancel,
        ),
      );
      if (confirmed == true && mounted && _attempt['status'] == 'in_progress') {
        await _complete();
      }
    } on TimeoutException {
      final message = Speech.t.quizEarlyTimedOut;
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
    // A queued answer may wait a long time; the student can still leave.
    if ((_submitting && !_answerQueued) || _completing) {
      await TtsService.speak(Speech.t.quizWaitPending);
      return;
    }
    _exitDialog = true;
    try {
      final leave = await showDialog<bool>(
        context: context,
        builder: (_) => KeypadConfirmationDialog(
          title: QuizText.leaveTitle,
          message: Speech.t.quizLeaveMessageServer,
          confirmLabel: QuizText.leaveConfirm,
          cancelLabel: Speech.t.quizStayInAttempt,
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
    unawaited(_speechSpeed.stop());
    _speedFocus.dispose();
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
    _previousFeedbackFocus.dispose();
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
        screenName: QuizText.attemptScreen(widget.quizTitle),
        introduction: completed
            ? '${Speech.t.quizAttemptCompletePrivate} $_navigationHelp'
            : choosing
            ? '$_questionAndOptions $_navigationHelp'
            : _completionError != null
            ? '$_completionError $_navigationHelp'
            : '${QuizText.answerSaved(hasFeedback: false)} $_navigationHelp',
        labels: {
          0: completed ? QuizText.returnToQuizzes : QuizText.leave,
          7: quizAttemptKeyLabels[7]!,
          8: completed ? QuizText.readResult : quizAttemptKeyLabels[8]!,
          9: quizAttemptKeyLabels[9]!,
          if (choosing) ...{
            for (var index = 1; index <= options.length && index <= 4; index++)
              index: quizAttemptKeyLabels[index]!,
            5: quizAttemptKeyLabels[5]!,
          },
          6: completed ? QuizText.returnToQuizzes : quizAttemptKeyLabels[6]!,
          if (!completed && _completionError != null)
            5: QuizText.retryFinishing,
          if (!completed && _completionError == null && _allAnswersSaved)
            5: QuizText.finishAndHear,
          if (!completed &&
              _completionError == null &&
              !_allAnswersSaved &&
              _feedback != null)
            5: Speech.t.quizNextQuestionNow,
        },
        actions: {
          0: _exit,
          7: () => _changeSpeechSpeed(-1),
          8: completed
              ? _readPrivateResult
              : () => unawaited(TtsService.speak(_whereAmI)),
          9: () => _changeSpeechSpeed(1),
          if (!completed) ...{
            for (var index = 0; index < 4; index++)
              index + 1: () => _selectOption(index),
            5: _completionError != null || _allAnswersSaved
                ? _complete
                : _feedback != null
                ? _next
                : _submit,
          },
          6: completed
              ? () => Navigator.pop(context)
              : () => unawaited(
                  TtsService.speak(
                    choosing ? _questionAndOptions : _questionAnnouncement,
                  ),
                ),
        },
        stateSummary: () => _whereAmI,
        focusTargets: [
          if (completed)
            KeypadFocusTarget(
              node: _returnFocus,
              label: QuizText.returnToQuizzes,
              onActivate: () => Navigator.pop(context),
            ),
          if (completed)
            KeypadFocusTarget(
              node: _resultFocus,
              label: QuizText.readResult,
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
              label: Speech.t.quizReadAllOptions,
              onActivate: _readOptions,
            ),
          for (var index = 0; choosing && index < options.length; index++)
            KeypadFocusTarget(
              node: _optionFocuses[index],
              label: _selectedOptionId == options[index]['quiz_option_id']
                  ? Speech.t.quizOptionTargetSelectedSubmit(
                      '${index + 1}',
                      '${options[index]['spoken_option_text'] ?? options[index]['option_text']}',
                    )
                  : Speech.t.quizOptionTargetNotSelectedSubmit(
                      '${index + 1}',
                      '${options[index]['spoken_option_text'] ?? options[index]['option_text']}',
                    ),
              onActivate: () => _selectOption(index),
              isEnabled: () => _canAnswer,
            ),
          if (choosing && _previousFeedback != null)
            KeypadFocusTarget(
              node: _previousFeedbackFocus,
              label: QuizText.previousFeedback,
              onActivate: _readPrivateFeedback,
            ),
          if (choosing)
            KeypadFocusTarget(
              node: _selectionRepeatFocus,
              label: Speech.t.quizReadSelectionTarget,
              onActivate: _readSelection,
            ),
          KeypadFocusTarget(
            node: _stopSpeechFocus,
            label: Speech.t.quizStopSpeech,
            onActivate: TtsService.stop,
          ),
          KeypadFocusTarget(
            node: _speedFocus,
            label: QuizText.speedTarget(_speechSpeed.description),
            onActivate: _speechSpeed.read,
            onDecrease: () => _changeSpeechSpeed(-1),
            onIncrease: () => _changeSpeechSpeed(1),
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
              label: Speech.t.keySubmitSelectedAnswer,
              onActivate: _submit,
              isEnabled: () => _canAnswer,
            ),
          if (!completed && _feedback != null)
            KeypadFocusTarget(
              node: _feedbackFocus,
              label: _feedback == null
                  ? Speech.t.quizAnswerFeedback
                  : Speech.t.quizAnswerConfirmedReadFeedback,
              onActivate: _feedback == null ? null : _readPrivateFeedback,
            ),
          if (!completed && !choosing)
            KeypadFocusTarget(
              node: _nextFocus,
              label: _completionError != null
                  ? Speech.t.quizRetryCompletion
                  : _feedback?['next_question'] == null
                  ? Speech.t.quizViewResult
                  : Speech.t.quizNextQuestion,
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
              label: QuizText.finishNow,
              isEnabled: () =>
                  !_submitting &&
                  !_completing &&
                  !_exitDialog &&
                  _completionError == null,
              onActivate: _earlyFinish,
            ),
            KeypadFocusTarget(
              node: _exitFocus,
              label: QuizText.leave,
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
                    tooltip: Speech.t.quizLeaveWithoutSubmitting,
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
                          ? QuizText.attemptResult(_attempt)
                          : Speech.t.quizAttemptCompletePrivateLabel,
                      child: Card(
                        child: ListTile(
                          leading: const Icon(Icons.emoji_events_outlined),
                          title: Text(Speech.t.quizResultHeading),
                          subtitle: Text(QuizText.attemptResult(_attempt)),
                        ),
                      ),
                    ),
                    TextButton(
                      focusNode: _resultFocus,
                      onPressed: _readPrivateResult,
                      child: Text(Speech.t.quizReadResultKey8),
                    ),
                    ElevatedButton(
                      focusNode: _returnFocus,
                      onPressed: () => Navigator.pop(context),
                      child: Text(Speech.t.quizReturnKey0),
                    ),
                  ] else if (question != null) ...[
                    Text(
                      QuizText.questionHeading(
                        _questionNumber,
                        _attempt['total_questions'],
                      ),
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
                        child: Text(Speech.t.quizReadAllOptionsLabel),
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
                              Builder(
                                builder: (context) {
                                  final option = options[index];
                                  final selected =
                                      _selectedOptionId ==
                                      option['quiz_option_id'];
                                  final spoken =
                                      option['spoken_option_text'] ??
                                      option['option_text'];
                                  // RadioListTile merges its title into one
                                  // radio node that already reports checked
                                  // state, so no outer wrapper is needed.
                                  return Card(
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                        color: selected
                                            ? UIUtils.accentColor
                                            : UIUtils.cardBorderColor,
                                        width: selected ? 4 : 1.5,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: RadioListTile<int>(
                                      focusNode: _optionFocuses[index],
                                      value: option['quiz_option_id'] as int,
                                      enabled: _canAnswer,
                                      title: Semantics(
                                        label: Speech.t.quizOptionLabel(
                                          '${index + 1}',
                                          '${options.length}',
                                          '$spoken',
                                        ),
                                        excludeSemantics: true,
                                        child: Text(
                                          '${index + 1}. ${option['option_text']}',
                                          style: const TextStyle(fontSize: 18),
                                        ),
                                      ),
                                      subtitle: selected
                                          ? ExcludeSemantics(
                                              child: Text(
                                                'Selected',
                                                style: TextStyle(
                                                  color: UIUtils.accentColor,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            )
                                          : null,
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    if (choosing && _previousFeedback != null)
                      OutlinedButton.icon(
                        focusNode: _previousFeedbackFocus,
                        onPressed: _readPrivateFeedback,
                        icon: const Icon(Icons.hearing),
                        label: Text(QuizText.previousFeedback),
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
                        label: Text(Speech.t.quizSubmitAnswerKey5),
                      ),
                    if (_feedback != null)
                      Focus(
                        focusNode: _feedbackFocus,
                        child: Semantics(
                          liveRegion: _feedbackReadRequested,
                          excludeSemantics: true,
                          label: _feedbackReadRequested
                              ? _feedbackAnnouncement
                              : Speech.t.quizAnswerLockedActivate,
                          button: true,
                          onTap: _readPrivateFeedback,
                          child: Card(
                            color: UIUtils.cardColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: _feedback!['feedback_released'] == false
                                    ? UIUtils.cardBorderColor
                                    : _feedback!['is_correct'] == true
                                    ? UIUtils.successColor
                                    : UIUtils.errorColor,
                                width: 4,
                              ),
                            ),
                            child: ListTile(
                              leading: Icon(
                                _feedback!['feedback_released'] == false
                                    ? Icons.save_outlined
                                    : _feedback!['is_correct'] == true
                                    ? Icons.check_circle
                                    : Icons.cancel,
                                color: _feedback!['feedback_released'] == false
                                    ? UIUtils.textColor
                                    : _feedback!['is_correct'] == true
                                    ? UIUtils.successColor
                                    : UIUtils.errorColor,
                              ),
                              title: Text(
                                _feedback!['feedback_released'] == false
                                    ? Speech.t.quizAnswerSavedLockedTitle
                                    : _feedback!['is_correct'] == true
                                    ? Speech.t.quizCorrectHeading
                                    : Speech.t.quizWrongHeading,
                                style: TextStyle(
                                  color: UIUtils.textColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                'You selected: ${_feedback!['selected_option_text']}\n'
                                '${_feedback!['feedback_released'] == false ? _feedback!['feedback_message'] : 'Correct answer: ${_feedback!['correct_option_text']}\n${_feedback!['explanation'] ?? 'No explanation provided.'}'}',
                                style: TextStyle(
                                  color: UIUtils.textColor,
                                  fontSize: 16,
                                ),
                              ),
                              onTap: _readPrivateFeedback,
                            ),
                          ),
                        ),
                      ),
                  ] else if (_allAnswersSaved)
                    Text(Speech.t.quizAllSavedViewResult),
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
                      child: Text(
                        Speech.t.quizAsksToConfirm(QuizText.finishNowButton),
                      ),
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
                              ? Speech.t.quizConfirmingCompletion
                              : _completionError != null
                              ? Speech.t.quizRetryCompletionKey5
                              : _feedback?['next_question'] == null
                              ? Speech.t.quizViewResultKey5
                              : Speech.t.quizNextQuestion,
                        ),
                      ),
                  ],
                  if (choosing)
                    TextButton(
                      focusNode: _selectionRepeatFocus,
                      onPressed: completed ? null : _readSelection,
                      child: Text(Speech.t.quizReadSelectedAnswer),
                    ),
                  TextButton(
                    focusNode: _stopSpeechFocus,
                    onPressed: TtsService.stop,
                    child: Text(Speech.t.quizStopSpeech),
                  ),
                  QuizSpeechSpeedControl(
                    focusNode: _speedFocus,
                    speed: _speechSpeed,
                    onChange: _changeSpeechSpeed,
                  ),
                  if (!completed && _remaining != null)
                    TextButton(
                      focusNode: _timeFocus,
                      onPressed: () => TtsService.speak(_remainingText),
                      child: Text(Speech.t.quizReadRemainingTime),
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
      await TtsService.speak(Speech.t.quizAttemptInProgressResume);
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
        final message = QuizText.reviewFailed;
        setState(() => _error = message);
        await TtsService.speak(message);
        return;
      }
      await Navigator.push<void>(
        context,
        MaterialPageRoute(builder: (_) => QuizReviewScreen(review: review)),
      );
    } on TimeoutException {
      final message = Speech.t.quizReviewTimedOutShort;
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
    final t = Speech.t;
    final scoreSummary =
        attempts.any((attempt) => attempt['is_graded'] == false)
        ? t.quizPracticeHistory
        : history['highest_score'] != null
        ? t.quizHighestScoreValue('${history['highest_score']}')
        : attempts.any((attempt) => attempt['status'] != 'in_progress')
        ? t.quizNoScoreCurrentlyReleased
        : t.quizNoCompletedAttempt;
    return KeypadInstructionWrapper(
      screenName: t.quizHistoryScreenNavigate,
      labels: {0: QuizText.goBack},
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
            label: t.quizHistoryAttemptRaw(
              '${attempt['attempt_number']}',
              '${attempt['status']}',
              QuizText.attemptResult(attempt),
            ),
            onActivate: () => _open(attempt),
            isEnabled: () => !_opening,
          ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: UIUtils.useStackedLayout(context)
              ? null
              : Text(Speech.t.quizHistoryTitle(quizTitle)),
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
                    Speech.t.quizHistoryTitle(quizTitle),
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
                ListTile(title: Text(Speech.t.quizNoAttemptsYet))
              else
                ...attempts.map(
                  (attempt) => Card(
                    child: ListTile(
                      focusNode: _node(attempt as Map),
                      leading: const Icon(Icons.history),
                      title: Text('Attempt ${attempt['attempt_number']}'),
                      subtitle: Text(
                        '${attempt['status']}. ${QuizText.attemptResult(attempt)}',
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
  late final _speechSpeed = QuizSpeechSpeed(this);
  final _speedFocus = FocusNode(debugLabel: 'quiz-review-speech-speed');
  FocusNode _node(int index) => _questionNodes.putIfAbsent(
    index,
    () => FocusNode(debugLabel: 'quiz-review-question-$index'),
  );

  @override
  void initState() {
    super.initState();
    unawaited(
      _speechSpeed.start().then((_) {
        if (mounted) setState(() {});
      }),
    );
  }

  Future<void> _changeSpeechSpeed(int steps) async {
    await _speechSpeed.change(steps);
    if (mounted) setState(() {});
  }

  String _announcement(Map question, int index) {
    final t = Speech.t;
    final number = '${index + 1}';
    final text =
        '${question['spoken_question_text'] ?? question['question_text']}';
    final selected =
        '${question['selected_option_spoken_text'] ?? question['selected_option_text'] ?? t.quizNoAnswerCapital}';
    final answer =
        '${question['correct_option_spoken_text'] ?? question['correct_option_text']}';
    final explanation =
        '${question['spoken_explanation'] ?? question['explanation'] ?? t.quizNoExplanation}';
    return question['is_correct'] == true
        ? t.quizReviewAnswerCorrect(number, text, selected, answer, explanation)
        : t.quizReviewAnswerIncorrect(
            number,
            text,
            selected,
            answer,
            explanation,
          );
  }

  @override
  void dispose() {
    unawaited(_speechSpeed.stop());
    _speedFocus.dispose();
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
    final speedControl = QuizSpeechSpeedControl(
      focusNode: _speedFocus,
      speed: _speechSpeed,
      onChange: _changeSpeechSpeed,
    );
    return KeypadInstructionWrapper(
      screenName: questions.isEmpty && message != null
          ? Speech.t.quizReviewScreenMessage(message)
          : Speech.t.quizReviewScreenRaw('${questions.length}'),
      introduction: QuizText.speedHelp,
      labels: {
        0: QuizText.goBack,
        playerSlowerKey: Speech.t.keySlowerQuizSpeech,
        playerFasterKey: Speech.t.keyFasterQuizSpeech,
      },
      actions: {
        0: () => Navigator.pop(context),
        playerSlowerKey: () => _changeSpeechSpeed(-1),
        playerFasterKey: () => _changeSpeechSpeed(1),
      },
      focusTargets: [
        KeypadFocusTarget(
          node: _speedFocus,
          label: QuizText.speedTarget(_speechSpeed.description),
          onActivate: _speechSpeed.read,
          onDecrease: () => _changeSpeechSpeed(-1),
          onIncrease: () => _changeSpeechSpeed(1),
        ),
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
        appBar: AppBar(title: Text(Speech.t.quizAttemptReviewTitle)),
        body: questions.isEmpty && review['feedback_message'] is String
            ? SingleChildScrollView(
                padding: UIUtils.paddingAll(context, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    speedControl,
                    Focus(focusNode: _messageNode, child: Text(message!)),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: UIUtils.paddingAll(context, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    speedControl,
                    ...List.generate(questions.length, (index) {
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
                                  ? UIUtils.successColor
                                  : UIUtils.errorColor,
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
                  ],
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
  static Map<String, String> get _metadataLabels {
    final t = Speech.t;
    return {
      'topics': t.quizMetaTopics,
      'spoken_question_text': t.quizMetaSpokenQuestion,
      'spoken_option_1': t.quizMetaSpokenOption('1'),
      'spoken_option_2': t.quizMetaSpokenOption('2'),
      'spoken_option_3': t.quizMetaSpokenOption('3'),
      'spoken_option_4': t.quizMetaSpokenOption('4'),
      'spoken_explanation': t.quizMetaSpokenExplanation,
    };
  }

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
        _error = QuizText.editorInvalid;
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
        _error = QuizText.editorSpokenInvalid;
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
      text.isEmpty
          ? Speech.t.quizCorrectSelected('${next + 1}')
          : Speech.t.quizCorrectSelectedWithText('${next + 1}', text),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Speech.t;
    final title = widget.initialQuestion == null
        ? t.quizCreateBankQuestion
        : t.quizEditBankQuestion;
    final metadataLabels = _metadataLabels;
    return KeypadInstructionWrapper(
      screenName: title,
      navigationSections: t.quizEditorNavigation,
      labels: {0: QuizText.cancel, 1: t.quizSaveQuestion},
      actions: {0: () => Navigator.pop(context), 1: _save},
      navigationController: _navigationController,
      focusTargets: [
        KeypadFocusTarget(
          node: _questionFocus,
          label: t.quizPressOkToEdit(t.quizQuestionTextTitle),
          isTextField: true,
        ),
        for (var index = 0; index < 4; index++)
          KeypadFocusTarget(
            node: _optionFocuses[index],
            label: t.quizPressOkToEdit(t.quizOptionNumber('${index + 1}')),
            isTextField: true,
          ),
        KeypadFocusTarget(
          node: _correctFocus,
          label: _correct == null
              ? t.quizCorrectNotSelected
              : t.quizCorrectIsOption(
                  '${_correct! + 1}',
                  _options[_correct!].text,
                ),
          onActivate: () => _cycleCorrect(1),
          onDecrease: () => _cycleCorrect(-1),
          onIncrease: () => _cycleCorrect(1),
        ),
        KeypadFocusTarget(
          node: _optionalFocus,
          label: _showOptional
              ? t.quizHideOptionalExplanation
              : t.quizShowOptionalExplanation,
          onActivate: () => setState(() => _showOptional = !_showOptional),
        ),
        if (_showOptional) ...[
          KeypadFocusTarget(
            node: _explanationFocus,
            label: t.quizPressOkToEdit(t.quizOptionalExplanation),
            isTextField: true,
          ),
          KeypadFocusTarget(
            node: _notationFocus,
            label: t.quizPressOkToChange(QuizText.notation(_described)),
            onActivate: () => setState(() {
              _described = !_described;
              _reviewed = false;
            }),
          ),
          for (final key in metadataLabels.keys)
            KeypadFocusTarget(
              node: _metadataFocuses[key]!,
              label: t.quizPressOkToEdit(metadataLabels[key]!),
              isTextField: true,
            ),
          KeypadFocusTarget(
            node: _reviewFocus,
            label: t.quizPressOkToChange(QuizText.reviewed(_reviewed)),
            onActivate: () => setState(() => _reviewed = !_reviewed),
          ),
        ],
        KeypadFocusTarget(
          node: _cancelFocus,
          label: t.quizCancelQuestion,
          onActivate: () => Navigator.pop(context),
        ),
        KeypadFocusTarget(
          node: _saveFocus,
          label: t.quizSaveQuestion,
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
                Text(Speech.t.quizEditorIntro),
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
                  decoration: InputDecoration(
                    label: Text(Speech.t.quizQuestionTextTitle),
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
                      label: Text(Speech.t.quizOptionNumber('${index + 1}')),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                OutlinedButton(
                  focusNode: _correctFocus,
                  onPressed: () => _cycleCorrect(1),
                  child: Column(
                    children: [
                      Text(Speech.t.quizWhichCorrect),
                      Text(
                        _correct == null
                            ? Speech.t.quizChooseCorrectOption
                            : Speech.t.quizOptionWithText(
                                '${_correct! + 1}',
                                _options[_correct!].text,
                              ),
                      ),
                      Text(Speech.t.quizCorrectChoiceHint),
                    ],
                  ),
                ),
                OutlinedButton(
                  focusNode: _optionalFocus,
                  onPressed: () =>
                      setState(() => _showOptional = !_showOptional),
                  child: Text(
                    _showOptional
                        ? Speech.t.quizHideOptionalExplanation
                        : Speech.t.quizShowOptionalExplanation,
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
                    decoration: InputDecoration(
                      label: Text(Speech.t.quizExplanationOptional),
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
                      _described
                          ? Speech.t.quizContentDescribedText
                          : Speech.t.quizContentPlain,
                    ),
                  ),
                  Text(Speech.t.quizNotationNote),
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
                    title: Text(Speech.t.quizReviewedAlternatives),
                  ),
                ],
                TextButton(
                  focusNode: _cancelFocus,
                  onPressed: () => Navigator.pop(context),
                  child: Text(Speech.t.uiCancelKey0),
                ),
                ElevatedButton(
                  focusNode: _saveFocus,
                  onPressed: _save,
                  child: Text(Speech.t.quizSaveQuestionKey1),
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
    return Speech.t.quizNumericDateTime(
      '${local.day}',
      '${local.month}',
      '${local.year}',
      '${local.hour}',
      minute,
    );
  }

  Future<void> _pickOpeningTime() async {
    await TtsService.speak(QuizText.setOpening);
    final value = await _pickDateTime(_opensAt);
    if (value == null || !mounted) return;
    setState(() => _opensAt = value);
    await TtsService.speak(QuizText.openingSet(value));
    _opensFocus.requestFocus();
  }

  Future<void> _pickClosingTime() async {
    await TtsService.speak(QuizText.setClosing);
    final value = await _pickDateTime(_closesAt);
    if (value == null || !mounted) return;
    setState(() => _closesAt = value);
    await TtsService.speak(QuizText.closingSet(value));
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
        _error = Speech.t.quizCheckTitleLimits;
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
    final t = Speech.t;
    return KeypadInstructionWrapper(
      navigationSections: t.quizSettingsNavigation,
      screenName: widget.initialQuiz != null
          ? t.quizChangeSettingsScreen
          : widget.practice
          ? t.quizCreatePracticeScreen
          : QuizText.createQuiz,
      labels: {
        0: QuizText.cancel,
        1: widget.initialQuiz == null
            ? t.quizContinueToQuestions
            : t.quizSaveSettingsReturn,
      },
      actions: {0: () => Navigator.pop(context), 1: _save},
      navigationController: _navigationController,
      focusTargets: [
        KeypadFocusTarget(
          node: _titleFocus,
          label: t.quizPressOkToEdit(t.quizQuizTitle),
          isTextField: true,
        ),
        KeypadFocusTarget(
          node: _optionalFocus,
          label: _showOptional
              ? t.quizHideOptionalSettings
              : t.quizShowOptionalSettings,
          onActivate: () => setState(() => _showOptional = !_showOptional),
        ),
        if (_showOptional) ...[
          KeypadFocusTarget(
            node: _descriptionFocus,
            label: t.quizPressOkToEdit(t.quizOptionalDescription),
            isTextField: true,
          ),
          KeypadFocusTarget(
            node: _attemptsFocus,
            label: QuizText.attemptLimit(_attempts.text),
            isTextField: true,
            isEnabled: () => !widget.practice,
          ),
          KeypadFocusTarget(
            node: _timeLimitFocus,
            label: QuizText.timeLimitField(_timeLimit.text),
            isTextField: true,
            isEnabled: () => !widget.practice,
          ),
          KeypadFocusTarget(
            node: _opensFocus,
            label: t.quizSetOrClear(
              _dateTimeLabel(_opensAt, t.quizNoOpeningTime),
            ),
            onActivate: _pickOpeningTime,
            onDecrease: () {
              setState(() => _opensAt = null);
              TtsService.speak(QuizText.openingCleared);
            },
            onIncrease: _pickOpeningTime,
          ),
          KeypadFocusTarget(
            node: _closesFocus,
            label: t.quizSetOrClear(
              _dateTimeLabel(_closesAt, t.quizNoClosingTime),
            ),
            onActivate: _pickClosingTime,
            onDecrease: () {
              setState(() => _closesAt = null);
              TtsService.speak(QuizText.closingCleared);
            },
            onIncrease: _pickClosingTime,
          ),
          KeypadFocusTarget(
            node: _shuffleQuestionsFocus,
            label: t.quizShuffleQuestionsToggle(
              SpokenFormat.onOff(_shuffleQuestions),
            ),
            onActivate: () =>
                setState(() => _shuffleQuestions = !_shuffleQuestions),
            onDecrease: () =>
                setState(() => _shuffleQuestions = !_shuffleQuestions),
            onIncrease: () =>
                setState(() => _shuffleQuestions = !_shuffleQuestions),
          ),
          KeypadFocusTarget(
            node: _shuffleOptionsFocus,
            label: t.quizShuffleOptionsToggle(
              SpokenFormat.onOff(_shuffleOptions),
            ),
            onActivate: () =>
                setState(() => _shuffleOptions = !_shuffleOptions),
            onDecrease: () =>
                setState(() => _shuffleOptions = !_shuffleOptions),
            onIncrease: () =>
                setState(() => _shuffleOptions = !_shuffleOptions),
          ),
          KeypadFocusTarget(
            node: _cancelFocus,
            label: t.quizCancelQuizCreation,
            onActivate: () => Navigator.pop(context),
          ),
          if (!widget.practice) ...[
            KeypadFocusTarget(
              node: _policyFocus,
              label: t.quizFeedbackPolicyTarget(_policy),
              onActivate: () => _cyclePolicy(1),
              onDecrease: () => _cyclePolicy(-1),
              onIncrease: () => _cyclePolicy(1),
            ),
            KeypadFocusTarget(
              node: _releaseFocus,
              label: t.quizScheduledRelease(
                _dateTimeLabel(_releaseAt, t.quizNotSet),
              ),
              isEnabled: () => _policy == 'scheduled',
              onActivate: _pickRelease,
            ),
          ],
        ],
        KeypadFocusTarget(
          node: _saveFocus,
          label: widget.initialQuiz == null
              ? t.quizSaveDraftContinue
              : t.quizSaveSettingsReturn,
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
                      ? Speech.t.quizChangeSettings
                      : widget.practice
                      ? Speech.t.quizCreatePracticeText
                      : Speech.t.quizStepName,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                if (widget.practice) Text(Speech.t.quizPracticeInfo),
                Semantics(
                  label: Speech.t.quizSettingsNavLabel,
                  child: Text(Speech.t.quizSettingsNavText),
                ),
                const SizedBox(height: 10),
                if (_error != null)
                  Semantics(liveRegion: true, child: Text(_error!)),
                TextField(
                  controller: _title,
                  focusNode: _titleFocus,
                  onTap: () =>
                      _navigationController.enterTextEditing(_titleFocus),
                  decoration: InputDecoration(
                    label: Text(Speech.t.quizQuizTitle),
                  ),
                ),
                Text(
                  widget.initialQuiz != null
                      ? Speech.t.quizSettingsReviewInfo
                      : widget.practice
                      ? Speech.t.quizPracticeDefaults
                      : Speech.t.quizGradedDefaults,
                ),
                OutlinedButton(
                  focusNode: _optionalFocus,
                  onPressed: () =>
                      setState(() => _showOptional = !_showOptional),
                  child: Text(
                    _showOptional
                        ? Speech.t.quizHideOptionalSettingsText
                        : Speech.t.quizShowOptionalSettingsText,
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
                    decoration: InputDecoration(
                      label: Text(Speech.t.libraryDescriptionOptional),
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
                    decoration: InputDecoration(
                      label: Text(Speech.t.quizAttemptLimitFieldText),
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
                    decoration: InputDecoration(
                      label: Text(Speech.t.quizTimeLimitFieldText),
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (widget.practice) Text(Speech.t.quizUntimedInfo),
                  if (!widget.practice) ...[
                    TextButton(
                      focusNode: _policyFocus,
                      onPressed: () => _cyclePolicy(1),
                      child: Text(
                        Speech.t.quizFeedbackValue(
                          QuizText.policyName(_policy),
                        ),
                      ),
                    ),
                    TextButton(
                      focusNode: _releaseFocus,
                      onPressed: _policy == 'scheduled' ? _pickRelease : null,
                      child: Text(
                        Speech.t.quizReleaseValue(
                          _dateTimeLabel(_releaseAt, Speech.t.quizNotSet),
                        ),
                      ),
                    ),
                  ],
                  Semantics(
                    button: true,
                    label: Speech.t.quizOpeningTimeLabel(
                      _dateTimeLabel(_opensAt, Speech.t.quizNoOpeningTimeSet),
                    ),
                    child: ListTile(
                      focusNode: _opensFocus,
                      leading: const Icon(Icons.event_available),
                      title: Text(
                        _dateTimeLabel(
                          _opensAt,
                          Speech.t.quizNoOpeningTimeShort,
                        ),
                      ),
                      subtitle: Text(Speech.t.quizOpeningTimeHint),
                      trailing: const Icon(Icons.edit_calendar),
                      onTap: _pickOpeningTime,
                    ),
                  ),
                  Semantics(
                    button: true,
                    label: Speech.t.quizClosingTimeLabel(
                      _dateTimeLabel(_closesAt, Speech.t.quizNoClosingTimeSet),
                    ),
                    child: ListTile(
                      focusNode: _closesFocus,
                      leading: const Icon(Icons.event_busy),
                      title: Text(
                        _dateTimeLabel(
                          _closesAt,
                          Speech.t.quizNoClosingTimeShort,
                        ),
                      ),
                      subtitle: Text(Speech.t.quizClosingTimeHint),
                      trailing: const Icon(Icons.edit_calendar),
                      onTap: _pickClosingTime,
                    ),
                  ),
                  SwitchListTile(
                    focusNode: _shuffleQuestionsFocus,
                    value: _shuffleQuestions,
                    onChanged: (value) =>
                        setState(() => _shuffleQuestions = value),
                    title: Text(Speech.t.quizShuffleQuestions),
                  ),
                  SwitchListTile(
                    focusNode: _shuffleOptionsFocus,
                    value: _shuffleOptions,
                    onChanged: (value) =>
                        setState(() => _shuffleOptions = value),
                    title: Text(Speech.t.quizShuffleOptions),
                  ),
                ],
                TextButton(
                  focusNode: _cancelFocus,
                  onPressed: () => Navigator.pop(context),
                  child: Text(Speech.t.uiCancelKey0),
                ),
                ElevatedButton(
                  focusNode: _saveFocus,
                  onPressed: _save,
                  child: Text(
                    widget.initialQuiz == null
                        ? Speech.t.quizContinueToQuestionsKey1
                        : Speech.t.quizSaveSettingsKey1,
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
