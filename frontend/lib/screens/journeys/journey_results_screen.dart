import 'dart:async';

import 'package:flutter/material.dart';

import '../../services/journey_api.dart';
import '../../services/journey_models.dart';
import '../../services/tts_service.dart';
import '../../widgets/journey_menu.dart';
import '../../widgets/journey_prompts.dart';

/// Class results for one journey, read on demand in short pieces.
class JourneyResultsScreen extends StatefulWidget {
  const JourneyResultsScreen({
    super.key,
    required this.journey,
    this.api = const JourneyApi(),
  });

  final JourneyDraft journey;
  final JourneyApi api;

  @override
  State<JourneyResultsScreen> createState() => _JourneyResultsScreenState();
}

class _JourneyResultsScreenState extends State<JourneyResultsScreen> {
  Map<String, dynamic>? _results;
  String? _issue;
  bool _busy = true;

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
      _results = await widget.api.results(widget.journey.journeyId);
    } on JourneyApiException catch (error) {
      _issue = error.message;
    }
    if (!mounted) return;
    setState(() => _busy = false);
    if (announce || _issue != null) {
      unawaited(TtsService.speak(_issue ?? _summary()));
    }
  }

  List<Map> _list(String key) =>
      ((_results?[key] as List?) ?? const []).whereType<Map>().toList();

  String _summary() {
    final summary = _results?['summary'];
    if (summary is! Map) return _issue ?? 'Results are loading.';
    final average = summary['average_percentage'];
    return '${summary['completed']} of ${summary['eligible']} students finished. '
        '${summary['in_progress']} in progress, ${summary['not_started']} not started.'
        '${average is num ? ' Average first-try score ${average.round()} percent.' : ''}';
  }

  String _student(Map row) {
    final status = switch (row['status']) {
      'completed' => 'Finished',
      'in_progress' => 'In progress',
      _ => 'Not started',
    };
    final questions = row['question_count'] is int && row['question_count'] > 0
        ? ' ${row['first_try_correct']} of ${row['question_count']} right first time.'
        : '';
    final score = row['percentage'] is num
        ? ' Score ${(row['percentage'] as num).round()} percent.'
        : '';
    final replays = row['replays'] is int && row['replays'] > 0
        ? ' ${row['replays']} wrong answers.'
        : '';
    return '${row['name']}. $status.$questions$score$replays';
  }

  String _question(Map row) {
    final rate = row['first_try_rate'];
    final attempts = row['average_attempts'];
    return 'Step ${(row['step_index'] as int) + 1}. ${row['text']}. '
        '${row['answered']} answered. '
        '${rate is num ? '${rate.round()} percent right first time.' : 'No answers yet.'}'
        '${attempts is num ? ' Average $attempts tries.' : ''}';
  }

  String _poll(Map row) {
    final options = ((row['options'] as List?) ?? const [])
        .whereType<Map>()
        .map((option) => '${option['text']}: ${option['count']}')
        .join(', ');
    return 'Step ${(row['step_index'] as int) + 1}. ${row['text']}. '
        '${row['answered']} answered. $options.';
  }

  Future<void> _browse(
    String title,
    List<Map> items,
    String Function(Map) label,
  ) async {
    final chosen = await JourneyPrompts.choose<Map>(
      context,
      title: title,
      items: items,
      labelOf: label,
    );
    if (chosen != null) unawaited(TtsService.speak(label(chosen)));
  }

  @override
  Widget build(BuildContext context) {
    final students = _list('students');
    final questions = _list('questions');
    final polls = _list('polls');
    return JourneyMenu(
      title: 'Results: ${widget.journey.title}',
      introduction: _summary(),
      details: _summary(),
      issue: _issue,
      busy: _busy,
      choices: [
        JourneyChoice(
          'Hear class summary',
          () => unawaited(TtsService.speak(_summary())),
        ),
        JourneyChoice(
          'Students, ${students.length}',
          () => unawaited(_browse('Students', students, _student)),
          enabled: students.isNotEmpty,
          unavailableReason: 'No students are in this class.',
        ),
        JourneyChoice(
          'Questions, ${questions.length}. Shows which parts need teaching again',
          () => unawaited(_browse('Questions', questions, _question)),
          enabled: questions.isNotEmpty,
          unavailableReason: 'This journey has no questions.',
        ),
        JourneyChoice(
          'Poll answers, ${polls.length}',
          () => unawaited(_browse('Poll answers', polls, _poll)),
          enabled: polls.isNotEmpty,
          unavailableReason: 'This journey has no polls.',
        ),
        JourneyChoice('Refresh results', () => unawaited(_load(announce: true))),
      ],
    );
  }
}
