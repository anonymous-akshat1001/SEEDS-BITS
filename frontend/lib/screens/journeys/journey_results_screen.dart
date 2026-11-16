import 'dart:async';

import 'package:flutter/material.dart';

import '../../l10n/speech.dart';
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
    final t = Speech.t;
    final summary = _results?['summary'];
    if (summary is! Map) return _issue ?? t.journeyResultsLoading;
    final average = summary['average_percentage'];
    return [
      t.journeyResultsSummary(
        '${summary['completed']}',
        '${summary['eligible']}',
        '${summary['in_progress']}',
        '${summary['not_started']}',
      ),
      if (average is num) t.journeyResultsAverage('${average.round()}'),
    ].join(' ');
  }

  String _student(Map row) {
    final t = Speech.t;
    final status = switch (row['status']) {
      'completed' => t.journeyResultFinished,
      'in_progress' => t.journeyStatusInProgress,
      _ => t.journeyResultNotStarted,
    };
    return [
      t.journeyResultStudent('${row['name']}', status),
      if (row['question_count'] is int && row['question_count'] > 0)
        t.journeyResultFirstTime(
          '${row['first_try_correct']}',
          '${row['question_count']}',
        ),
      if (row['percentage'] is num)
        t.journeyRowScore('${(row['percentage'] as num).round()}'),
      if (row['replays'] is int && row['replays'] > 0)
        t.journeyResultWrongAnswers('${row['replays']}'),
    ].join(' ');
  }

  String _question(Map row) {
    final t = Speech.t;
    final rate = row['first_try_rate'];
    final attempts = row['average_attempts'];
    return [
      t.journeyResultQuestion(
        '${(row['step_index'] as int) + 1}',
        '${row['text']}',
        '${row['answered']}',
      ),
      rate is num
          ? t.journeyResultRate('${rate.round()}')
          : t.journeyResultNoAnswers,
      if (attempts is num) t.journeyResultAverageTries('$attempts'),
    ].join(' ');
  }

  String _poll(Map row) {
    final options = ((row['options'] as List?) ?? const [])
        .whereType<Map>()
        .map((option) => '${option['text']}: ${option['count']}')
        .join(', ');
    return Speech.t.journeyResultPoll(
      '${(row['step_index'] as int) + 1}',
      '${row['text']}',
      '${row['answered']}',
      options,
    );
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
    final t = Speech.t;
    final students = _list('students');
    final questions = _list('questions');
    final polls = _list('polls');
    return JourneyMenu(
      title: t.journeyResultsTitle(widget.journey.title),
      introduction: _summary(),
      details: _summary(),
      issue: _issue,
      busy: _busy,
      choices: [
        JourneyChoice(
          t.journeyResultsHearSummary,
          () => unawaited(TtsService.speak(_summary())),
        ),
        JourneyChoice(
          t.journeyResultsStudents('${students.length}'),
          () => unawaited(
            _browse(t.journeyResultsStudentsTitle, students, _student),
          ),
          enabled: students.isNotEmpty,
          unavailableReason: t.journeyResultsNoStudents,
        ),
        JourneyChoice(
          t.journeyResultsQuestions('${questions.length}'),
          () => unawaited(
            _browse(t.journeyResultsQuestionsTitle, questions, _question),
          ),
          enabled: questions.isNotEmpty,
          unavailableReason: t.journeyResultsNoQuestions,
        ),
        JourneyChoice(
          t.journeyResultsPolls('${polls.length}'),
          () => unawaited(_browse(t.journeyResultsPollsTitle, polls, _poll)),
          enabled: polls.isNotEmpty,
          unavailableReason: t.journeyResultsNoPolls,
        ),
        JourneyChoice(
          t.journeyResultsRefresh,
          () => unawaited(_load(announce: true)),
        ),
      ],
    );
  }
}
