import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../announcers/quiz_text.dart';
import '../services/api_service.dart';
import '../services/tts_service.dart';
import '../utils/ui_utils.dart';
import '../widgets/key_instruction_wrapper.dart';

class QuestionRevisionsScreen extends StatefulWidget {
  const QuestionRevisionsScreen({super.key, required this.questionId});
  final int questionId;

  @override
  State<QuestionRevisionsScreen> createState() =>
      _QuestionRevisionsScreenState();
}

class _QuestionRevisionsScreenState extends State<QuestionRevisionsScreen> {
  final _focuses = <String, FocusNode>{};
  SharedPreferences? _preferences;
  String? _token;
  int? _account;
  List<Map<String, dynamic>> _revisions = [];
  int _offset = 0;
  int _index = 0;
  bool _hasMore = false;
  bool _loading = true;
  String? _error;

  FocusNode _node(String key) => _focuses.putIfAbsent(
    key,
    () => FocusNode(debugLabel: 'question-revision-$key'),
  );
  bool get _sameAccount =>
      _token != null &&
      _preferences?.getString('token') == _token &&
      _preferences?.getInt('user_id') == _account;

  bool _validRevision(dynamic row) {
    if (row is! Map<String, dynamic> ||
        row['revision'] is! int ||
        (row['revision'] as int) < 1) {
      return false;
    }
    final content = row['content'];
    if (content is! Map<String, dynamic>) return false;
    final options = content['options'];
    final correct = content['correct_option_index'];
    final topics = content['topics'];
    final spoken = content['spoken_options'];
    return content['question_text'] is String &&
        options is List &&
        options.length == 4 &&
        options.every((option) => option is String) &&
        correct is int &&
        correct >= 0 &&
        correct < 4 &&
        (topics == null ||
            (topics is List && topics.every((topic) => topic is String))) &&
        (spoken == null ||
            (spoken is List &&
                spoken.length == 4 &&
                spoken.every((option) => option is String))) &&
        [
          'spoken_question_text',
          'explanation',
          'spoken_explanation',
        ].every((field) => content[field] == null || content[field] is String);
  }

  @override
  void initState() {
    super.initState();
    _load(0);
  }

  Future<void> _fail(String message) async {
    if (!mounted) return;
    setState(() {
      _loading = false;
      _error = message;
      _revisions = [];
      _index = 0;
      _hasMore = false;
    });
    debugPrint('[QUIZ] $message');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final retry = _node('refresh');
      if (retry.context != null && retry.canRequestFocus) {
        retry.requestFocus();
      }
      // Runs after the focus change so the error is not cut off by the
      // focus announcement of the retry control.
      scheduleMicrotask(
        () => TtsService.speak(
          QuizText.revisionFailed(message),
          priority: SpeechPriority.critical,
        ),
      );
    });
  }

  Future<void> _load(int offset, {bool last = false}) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    if (_preferences == null) {
      _preferences = await SharedPreferences.getInstance();
      _token = _preferences!.getString('token');
      _account = _preferences!.getInt('user_id');
    }
    if (!mounted) return;
    if (!_sameAccount) {
      return _fail(QuizText.revisionsAccount);
    }
    try {
      final result = await ApiService.getResult(
        '/question-bank/${widget.questionId}/revisions?offset=$offset',
        useAuth: true,
      ).timeout(const Duration(seconds: 10));
      if (!mounted) return;
      if (!_sameAccount) return _fail(QuizText.revisionsCleared);
      if (!result.isSuccess) return _fail(result.failure!.message);
      final data = result.data;
      if (data is! Map ||
          data['question_id'] != widget.questionId ||
          data['has_more'] is! bool ||
          data['revisions'] is! List) {
        return _fail(QuizText.revisionsUnverified);
      }
      final rows = data['revisions'] as List;
      if (rows.any((row) => !_validRevision(row))) {
        return _fail(QuizText.revisionsContentUnverified);
      }
      setState(() {
        _revisions = rows.cast<Map<String, dynamic>>();
        _offset = offset;
        _index = last && rows.isNotEmpty ? rows.length - 1 : 0;
        _hasMore = data['has_more'] as bool;
        _loading = false;
      });
      await TtsService.speak(
        _revisions.isEmpty
            ? QuizText.noRevisions
            : QuizText.revisionsLoaded(
                _revisions.length,
                _revisions[_index]['revision'],
                _revisions[_index]['recorded_at'],
              ),
      );
    } on TimeoutException {
      await _fail(QuizText.revisionsTimedOut);
    }
  }

  Future<void> _move(bool older) async {
    if (_loading) return;
    if (!_sameAccount) return _fail(QuizText.revisionsCleared);
    final next = _index + (older ? 1 : -1);
    if (next >= 0 && next < _revisions.length) {
      setState(() => _index = next);
      await TtsService.speak(
        QuizText.revisionSelected(
          _revisions[_index]['revision'],
          _offset + _index + 1,
          _hasMore ? null : _offset + _revisions.length,
        ),
      );
    } else if (older && _hasMore) {
      await _load(_offset + 20);
    } else if (!older && _offset > 0) {
      await _load(_offset - 20, last: true);
    }
  }

  Future<void> _read(String text) async {
    if (!_sameAccount) return _fail(QuizText.revisionsCleared);
    await TtsService.speak(text);
  }

  @override
  void dispose() {
    for (final node in _focuses.values) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final revision = _revisions.isEmpty ? null : _revisions[_index];
    final sections = QuizText.revisionSections(revision);
    final titles = QuizText.revisionTitles(revision);
    String fullRevision() => sections.entries
        .where((entry) => entry.key != 'notice')
        .map((entry) => entry.value)
        .join(' ');
    String readText(String key) =>
        key == 'version' ? fullRevision() : sections[key]!;
    final canOlder = !_loading && (_index + 1 < _revisions.length || _hasMore);
    final canNewer = !_loading && (_index > 0 || _offset > 0);
    return KeypadInstructionWrapper(
      screenName: QuizText.revisionsScreen,
      stateSummary: () => QuizText.revisionState(revision?['revision']),
      labels: const {0: QuizText.goBack},
      actions: {0: () => Navigator.pop(context)},
      focusTargets: [
        KeypadFocusTarget(
          node: _node('back'),
          label: QuizText.goBack,
          onActivate: () => Navigator.pop(context),
        ),
        KeypadFocusTarget(
          node: _node('refresh'),
          label: QuizText.refreshRevisions,
          onActivate: () => _load(_offset),
          isEnabled: () => !_loading,
        ),
        KeypadFocusTarget(
          node: _node('newer'),
          label: QuizText.newerRevision,
          onActivate: () => _move(false),
          isEnabled: () => canNewer,
        ),
        KeypadFocusTarget(
          node: _node('older'),
          label: QuizText.olderRevision,
          onActivate: () => _move(true),
          isEnabled: () => canOlder,
        ),
        for (final section in sections.entries)
          KeypadFocusTarget(
            node: _node(section.key),
            label: QuizText.revisionSection(
              titles[section.key]!,
              sameAccount: _sameAccount,
            ),
            onActivate: () => _read(readText(section.key)),
          ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Question revisions'),
          leading: IconButton(
            focusNode: _node('back'),
            tooltip: 'Go back from question revisions',
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_loading) const LinearProgressIndicator(),
              if (_error != null)
                Semantics(
                  liveRegion: true,
                  child: Text(
                    _error!,
                    style: TextStyle(
                      color: UIUtils.errorColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              TextButton(
                focusNode: _node('refresh'),
                onPressed: _loading ? null : () => _load(_offset),
                child: const Text('Refresh revisions'),
              ),
              TextButton(
                focusNode: _node('newer'),
                onPressed: canNewer ? () => _move(false) : null,
                child: const Text('Newer revision'),
              ),
              TextButton(
                focusNode: _node('older'),
                onPressed: canOlder ? () => _move(true) : null,
                child: const Text('Older revision'),
              ),
              for (final section in sections.entries)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Semantics(
                    button: true,
                    excludeSemantics: true,
                    label: _sameAccount
                        ? '${titles[section.key]}. Double tap to hear it'
                        : 'Account changed. Return and sign in again.',
                    onTap: () => _read(readText(section.key)),
                    child: OutlinedButton(
                      focusNode: _node(section.key),
                      onPressed: () => _read(readText(section.key)),
                      style: OutlinedButton.styleFrom(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.all(12),
                        side: BorderSide(color: UIUtils.cardBorderColor),
                        backgroundColor: UIUtils.cardColor,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            titles[section.key]!,
                            style: TextStyle(
                              color: UIUtils.textColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            section.value,
                            style: TextStyle(
                              color: UIUtils.subtextColor,
                              fontSize: 16,
                            ),
                          ),
                        ],
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
