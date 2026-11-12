import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_service.dart';
import 'journey_models.dart';

class JourneyApiException implements Exception {
  const JourneyApiException(
    this.message, {
    this.statusCode,
    this.network = false,
  });
  final String message;
  final int? statusCode;

  /// True when the server could not be reached; downloaded copies may be used.
  final bool network;
  @override
  String toString() => message;
}

/// Learning-journey endpoints. Screens accept an instance so tests can
/// substitute a fake without a server.
class JourneyApi {
  const JourneyApi();

  static const _timeout = Duration(seconds: 15);

  Future<Object?> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('${ApiService.baseUrl}$path');
    final headers = await ApiService.getHeaders();
    final http.Response response;
    try {
      final encoded = body == null ? null : jsonEncode(body);
      response = await switch (method) {
        'GET' => http.get(uri, headers: headers),
        'PUT' => http.put(uri, headers: headers, body: encoded),
        'DELETE' => http.delete(uri, headers: headers),
        _ => http.post(uri, headers: headers, body: encoded),
      }.timeout(_timeout);
    } on Exception {
      throw const JourneyApiException(
        'No connection to the school server. Check your internet and try again.',
        network: true,
      );
    }
    Object? decoded;
    try {
      decoded = response.body.isEmpty ? null : jsonDecode(response.body);
    } on FormatException {
      decoded = null;
    }
    final code = response.statusCode;
    if (code >= 200 && code < 300) return decoded;
    final detail = decoded is Map && decoded['detail'] is String
        ? decoded['detail'] as String
        : null;
    throw JourneyApiException(switch (code) {
      409 => detail ?? 'This journey changed. Refresh and try again.',
      401 => 'Your sign-in expired. Sign in again.',
      403 => detail ?? 'You do not have permission to do that.',
      404 => 'This journey is no longer available.',
      422 => 'Some of the information could not be accepted. Check it and try again.',
      >= 500 => 'The school server had a problem. Try again later.',
      _ => 'The request did not succeed. Try again.',
    }, statusCode: code);
  }

  Map<String, dynamic> _object(Object? value) {
    if (value is Map<String, dynamic>) return value;
    throw const JourneyApiException(
      'The server response could not be read. Refresh before trying again.',
    );
  }

  JourneyDraft _journey(Object? value) {
    try {
      return JourneyDraft.parse(_object(value)['journey']);
    } on FormatException {
      throw const JourneyApiException(
        'The saved journey could not be read. Refresh before trying again.',
      );
    }
  }

  // ─── Teacher ──────────────────────────────────────────────────────────────

  Future<List<JourneyDraft>> teacherJourneys(int classId, int subjectId) async {
    final data = _object(
      await _send(
        'GET',
        '/teacher/journeys?class_id=$classId&subject_id=$subjectId',
      ),
    );
    final list = data['journeys'];
    if (list is! List) {
      throw const JourneyApiException('The journey list could not be read.');
    }
    return list.map(JourneyDraft.parse).toList();
  }

  Future<JourneyDraft> teacherJourney(int id) async =>
      _journey(await _send('GET', '/teacher/journeys/$id'));

  Future<JourneyDraft> create(int classId, int subjectId, String title) async =>
      _journey(
        await _send(
          'POST',
          '/teacher/journeys',
          body: {'class_id': classId, 'subject_id': subjectId, 'title': title},
        ),
      );

  Future<JourneyDraft> update(
    JourneyDraft journey, {
    String? title,
    bool? graded,
    int? maxRetries,
    List<JourneyStep>? steps,
  }) async {
    final saved = _journey(
      await _send(
        'PUT',
        '/teacher/journeys/${journey.journeyId}',
        body: journey.toUpdateJson(
          title: title,
          graded: graded,
          maxRetries: maxRetries,
          steps: steps,
        ),
      ),
    );
    if (saved.journeyId != journey.journeyId ||
        saved.revision != journey.revision + 1) {
      throw const JourneyApiException(
        'The saved journey did not match. Refresh before trying again.',
      );
    }
    return saved;
  }

  Future<JourneyPreview> preview(int id) async {
    final data = _object(await _send('GET', '/teacher/journeys/$id/preview'));
    try {
      return JourneyPreview(
        snapshot: JourneySnapshot.parse(data['snapshot']),
        issues: (data['issues'] as List? ?? const []).whereType<String>().toList(),
        warnings: (data['warnings'] as List? ?? const [])
            .whereType<String>()
            .toList(),
      );
    } on FormatException {
      throw const JourneyApiException('The journey preview could not be read.');
    }
  }

  Future<(JourneyDraft, int)> publish(JourneyDraft journey) async {
    final data = _object(
      await _send(
        'POST',
        '/teacher/journeys/${journey.journeyId}/publish',
        body: {'revision': journey.revision},
      ),
    );
    final notifications = data['notifications'];
    final delivered = notifications is Map && notifications['success'] is int
        ? notifications['success'] as int
        : 0;
    return (_journey(data), delivered);
  }

  Future<JourneyDraft> setArchived(JourneyDraft journey, bool archived) async =>
      _journey(
        await _send(
          'POST',
          '/teacher/journeys/${journey.journeyId}/${archived ? 'archive' : 'restore'}',
          body: {'revision': journey.revision},
        ),
      );

  Future<JourneyDraft> duplicate(int id) async =>
      _journey(await _send('POST', '/teacher/journeys/$id/duplicate'));

  Future<void> delete(JourneyDraft journey) => _send(
    'DELETE',
    '/teacher/journeys/${journey.journeyId}?revision=${journey.revision}',
  );

  Future<Map<String, dynamic>> results(int id) async =>
      _object(await _send('GET', '/teacher/journeys/$id/results'));

  /// The teacher's own recordings for this class and subject.
  Future<List<({int id, String title})>> recordings(
    int classId,
    int subjectId,
  ) async {
    final data = await _send('GET', '/audio/list?subject_id=$subjectId');
    if (data is! List) {
      throw const JourneyApiException('The recording list could not be read.');
    }
    return [
      for (final item in data)
        if (item is Map &&
            item['audio_id'] is int &&
            item['title'] is String &&
            item['class_id'] == classId &&
            item['subject_id'] == subjectId)
          (id: item['audio_id'] as int, title: item['title'] as String),
    ];
  }

  /// The teacher's question bank for this class and subject.
  Future<List<JourneyStep>> bankQuestions(int classId, int subjectId) async {
    final data = await _send(
      'GET',
      '/question-bank?class_id=$classId&subject_id=$subjectId',
    );
    if (data is! List) {
      throw const JourneyApiException('The question bank could not be read.');
    }
    final questions = <JourneyStep>[];
    for (final item in data) {
      if (item is! Map ||
          item['question_id'] is! int ||
          item['question_text'] is! String ||
          item['options'] is! List) {
        continue;
      }
      final options = [...(item['options'] as List).whereType<Map>()]
        ..sort(
          (a, b) => ((a['position'] as int?) ?? 0).compareTo(
            (b['position'] as int?) ?? 0,
          ),
        );
      final correct = options.indexWhere((option) => option['is_correct'] == true);
      if (options.length < 2 || correct < 0) continue;
      questions.add(
        JourneyStep(
          kind: JourneyStepKind.question,
          text: item['question_text'] as String,
          options: [for (final option in options) '${option['option_text']}'],
          correctIndex: correct,
          explanation: item['explanation'] is String
              ? item['explanation'] as String
              : null,
          sourceQuestionId: item['question_id'] as int,
        ),
      );
    }
    return questions;
  }

  // ─── Student ──────────────────────────────────────────────────────────────

  Future<List<StudentJourneySummary>> studentJourneys() async {
    final data = _object(await _send('GET', '/student/journeys'));
    final list = data['journeys'];
    if (list is! List) {
      throw const JourneyApiException('The journey list could not be read.');
    }
    try {
      return list.map(StudentJourneySummary.parse).toList();
    } on FormatException {
      throw const JourneyApiException('The journey list could not be read.');
    }
  }

  Future<JourneySnapshot> studentJourney(int id) async {
    final data = _object(await _send('GET', '/student/journeys/$id'));
    try {
      return JourneySnapshot.parse(data['snapshot']);
    } on FormatException {
      throw const JourneyApiException('This journey could not be read.');
    }
  }

  /// Returns accepted and permanently rejected run IDs.
  Future<({List<String> accepted, List<String> rejected})> sync(
    List<Map<String, dynamic>> runs,
  ) async {
    final data = _object(
      await _send('POST', '/student/journeys/sync', body: {'runs': runs}),
    );
    final accepted = (data['accepted'] as List? ?? const [])
        .whereType<String>()
        .toList();
    final rejected = [
      for (final item in (data['rejected'] as List? ?? const []))
        if (item is Map && item['run_id'] is String) item['run_id'] as String,
    ];
    return (accepted: accepted, rejected: rejected);
  }
}

class JourneyPreview {
  const JourneyPreview({
    required this.snapshot,
    required this.issues,
    required this.warnings,
  });
  final JourneySnapshot snapshot;
  final List<String> issues;
  final List<String> warnings;
}
