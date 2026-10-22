import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_service.dart';
import '../services/tts_service.dart';
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
    await TtsService.speak(message);
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
      return _fail(
        'Your account changed. Return and sign in again before viewing private question history.',
      );
    }
    try {
      final result = await ApiService.getResult(
        '/question-bank/${widget.questionId}/revisions?offset=$offset',
        useAuth: true,
      ).timeout(const Duration(seconds: 10));
      if (!mounted) return;
      if (!_sameAccount) {
        return _fail(
          'Your account changed. Private question history was cleared.',
        );
      }
      if (!result.isSuccess) return _fail(result.failure!.message);
      final data = result.data;
      if (data is! Map ||
          data['question_id'] != widget.questionId ||
          data['has_more'] is! bool ||
          data['revisions'] is! List) {
        return _fail(
          'Question revision history could not be verified. Retry loading.',
        );
      }
      final rows = data['revisions'] as List;
      if (rows.any((row) => !_validRevision(row))) {
        return _fail(
          'Question revision content could not be verified. Retry loading.',
        );
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
            ? 'No tracked revisions. Older question history is unknown, not reconstructed.'
            : 'Read-only question revision ${_revisions[_index]['revision']}. Existing quiz and attempt snapshots are not changed.',
      );
    } on TimeoutException {
      await _fail(
        'Question history timed out. Check your connection and retry.',
      );
    }
  }

  Future<void> _move(bool older) async {
    if (_loading) return;
    if (!_sameAccount) {
      return _fail(
        'Your account changed. Private question history was cleared.',
      );
    }
    final next = _index + (older ? 1 : -1);
    if (next >= 0 && next < _revisions.length) {
      setState(() => _index = next);
      await TtsService.speak(
        'Revision ${_revisions[_index]['revision']} selected. Read-only.',
      );
    } else if (older && _hasMore) {
      await _load(_offset + 20);
    } else if (!older && _offset > 0) {
      await _load(_offset - 20, last: true);
    }
  }

  Future<void> _read(String text) async {
    if (!_sameAccount) {
      return _fail(
        'Your account changed. Private question history was cleared.',
      );
    }
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
    final content = revision?['content'] as Map<String, dynamic>?;
    final options = content?['options'] as List? ?? const [];
    final spokenOptions = content?['spoken_options'] as List? ?? const [];
    final sections = <String, String>{
      if (revision != null)
        'version':
            'Revision ${revision['revision']}. Saved ${revision['recorded_at']}. Read-only.',
      if (content != null) ...{
        'question':
            'Question: ${content['spoken_question_text'] ?? content['question_text']}',
        'topics':
            'Topics: ${(content['topics'] as List? ?? const []).join(', ')}',
        for (var i = 0; i < options.length; i++)
          'option-$i':
              'Option ${i + 1}: ${i < spokenOptions.length ? spokenOptions[i] : options[i]}. ${content['correct_option_index'] == i ? 'Correct answer.' : ''}',
        'explanation':
            'Explanation: ${content['spoken_explanation'] ?? content['explanation'] ?? 'Not provided'}',
      },
      'notice':
          'Only revisions saved after tracking was introduced are available. Older history is unknown. Existing quiz and attempt snapshots are never rewritten.',
    };
    final canOlder = !_loading && (_index + 1 < _revisions.length || _hasMore);
    final canNewer = !_loading && (_index > 0 || _offset > 0);
    return KeypadInstructionWrapper(
      screenName:
          'Private read-only question revision history. Use older and newer revision controls, then read each section.',
      labels: const {0: 'Go back'},
      actions: {0: () => Navigator.pop(context)},
      focusTargets: [
        KeypadFocusTarget(
          node: _node('back'),
          label: 'Go back',
          onActivate: () => Navigator.pop(context),
        ),
        KeypadFocusTarget(
          node: _node('refresh'),
          label: 'Refresh revisions',
          onActivate: () => _load(_offset),
          isEnabled: () => !_loading,
        ),
        KeypadFocusTarget(
          node: _node('newer'),
          label: 'Newer revision',
          onActivate: () => _move(false),
          isEnabled: () => canNewer,
        ),
        KeypadFocusTarget(
          node: _node('older'),
          label: 'Older revision',
          onActivate: () => _move(true),
          isEnabled: () => canOlder,
        ),
        for (final section in sections.entries)
          KeypadFocusTarget(
            node: _node(section.key),
            label: _sameAccount
                ? section.value
                : 'Account changed. Return and sign in again.',
            onActivate: () => _read(section.value),
          ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Question revisions'),
          leading: IconButton(
            focusNode: _node('back'),
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
                Semantics(liveRegion: true, child: Text(_error!)),
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
                TextButton(
                  focusNode: _node(section.key),
                  onPressed: () => _read(section.value),
                  child: Text(section.value),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
