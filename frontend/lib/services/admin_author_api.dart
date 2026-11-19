import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../l10n/speech.dart';
import 'admin_setup_api.dart';
import 'api_service.dart';
import 'journey_models.dart';

/// Teacher authoring calls made by an administrator on a teacher's behalf.
/// Every request names the teacher in the X-Act-As-Teacher header, so the
/// server applies that teacher's ownership and class-and-subject rules.
class AdminAuthorApi {
  const AdminAuthorApi(this.teacherId);

  final int teacherId;

  static const actAsHeader = 'X-Act-As-Teacher';
  static const _timeout = Duration(seconds: 20);

  /// Server explanations are shown as written, including refusals such as
  /// "Step 2 must use your own recording from this class and subject."
  static String errorText(ApiFailure? failure) {
    final status = failure?.statusCode;
    if (status == 403) {
      final detail = AdminSetupApi.serverDetail(failure?.debugDetails);
      if (detail != null) return detail;
    }
    return AdminSetupApi.errorText(failure);
  }

  Future<ApiResult<Object?>> _send(
    String method,
    String path, [
    Map<String, dynamic>? body,
  ]) async {
    try {
      final uri = Uri.parse('${ApiService.baseUrl}$path');
      final headers = {
        ...await ApiService.getHeaders(),
        actAsHeader: '$teacherId',
      };
      final encoded = body == null ? null : jsonEncode(body);
      final response = await switch (method) {
        'GET' => http.get(uri, headers: headers),
        'PUT' => http.put(uri, headers: headers, body: encoded),
        'DELETE' => http.delete(uri, headers: headers),
        _ => http.post(uri, headers: headers, body: encoded),
      }.timeout(_timeout);
      final text = utf8.decode(response.bodyBytes);
      Object? decoded;
      if (text.isNotEmpty) {
        try {
          decoded = jsonDecode(text);
        } on FormatException {
          decoded = text;
        }
      }
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResult.success(decoded);
      }
      return ApiResult.failure(
        ApiService.mapFailure(
          statusCode: response.statusCode,
          responseBody: text,
        ),
      );
    } catch (error) {
      return ApiResult.failure(ApiService.mapFailure(error: error));
    }
  }

  static ApiResult<T> _unreadable<T>() => ApiResult.failure(
    ApiFailure(
      kind: ApiFailureKind.unknown,
      message: Speech.t.apiResponseUnreadable,
    ),
  );

  Future<ApiResult<JsonMap>> _object(
    String method,
    String path, [
    Map<String, dynamic>? body,
  ]) async {
    final result = await _send(method, path, body);
    if (!result.isSuccess) return ApiResult.failure(result.failure);
    final data = result.data;
    return data is Map ? ApiResult.success(JsonMap.from(data)) : _unreadable();
  }

  Future<ApiResult<List<JsonMap>>> _list(String path) async {
    final result = await _send('GET', path);
    if (!result.isSuccess) return ApiResult.failure(result.failure);
    final data = result.data;
    if (data is! List) return _unreadable();
    return ApiResult.success([
      for (final item in data)
        if (item is Map) JsonMap.from(item),
    ]);
  }

  // ─── Quizzes ───────────────────────────────────────────────────────────────

  Future<ApiResult<List<JsonMap>>> quizzes(int classId, int subjectId) =>
      _list('/teacher/quizzes?class_id=$classId&subject_id=$subjectId');

  Future<ApiResult<JsonMap>> quiz(int quizId) =>
      _object('GET', '/teacher/quizzes/$quizId');

  Future<ApiResult<JsonMap>> createQuiz({
    required int classId,
    required int subjectId,
    required String title,
    String? description,
    String mode = 'graded',
  }) => _object('POST', '/teacher/quizzes', {
    'class_id': classId,
    'subject_id': subjectId,
    'title': title,
    'description': description,
    'mode': mode,
  });

  /// Saves the editable settings, keeping every other setting as it was.
  Future<ApiResult<JsonMap>> updateQuiz(
    JsonMap quiz, {
    required String title,
    String? description,
    required String mode,
  }) {
    var feedback = quiz['feedback_policy'];
    if (mode == 'graded' && feedback == 'immediate') {
      feedback = 'after_completion';
    }
    return _object('PUT', '/teacher/quizzes/${quiz['quiz_id']}', {
      'class_id': quiz['class_id'],
      'subject_id': quiz['subject_id'],
      'title': title,
      'description': description,
      'mode': mode,
      'feedback_policy': feedback,
      'feedback_release_at': quiz['feedback_release_at'],
      'attempt_limit': quiz['attempt_limit'] ?? 1,
      'opens_at': quiz['opens_at'],
      'closes_at': quiz['closes_at'],
      'time_limit_minutes': mode == 'practice'
          ? null
          : quiz['time_limit_minutes'],
      'shuffle_questions': quiz['shuffle_questions'] ?? false,
      'shuffle_options': quiz['shuffle_options'] ?? false,
    });
  }

  Future<ApiResult<JsonMap>> addNewQuestion(
    int quizId, {
    required String text,
    required List<String> options,
    required int correctIndex,
    String? explanation,
    bool saveToBank = true,
  }) => _object('POST', '/teacher/quizzes/$quizId/questions/new', {
    'question_text': text,
    'options': options,
    'correct_option_index': correctIndex,
    'explanation': explanation,
    'save_to_bank': saveToBank,
  });

  Future<ApiResult<JsonMap>> addBankQuestion(int quizId, int questionId) =>
      _object('POST', '/teacher/quizzes/$quizId/questions/from-bank', {
        'question_id': questionId,
      });

  Future<ApiResult<JsonMap>> removeQuestion(int quizId, int quizQuestionId) =>
      _object('DELETE', '/teacher/quizzes/$quizId/questions/$quizQuestionId');

  Future<ApiResult<JsonMap>> readiness(int quizId) =>
      _object('GET', '/teacher/quizzes/$quizId/readiness');

  Future<ApiResult<JsonMap>> publishQuiz(int quizId) =>
      _object('POST', '/teacher/quizzes/$quizId/publish');

  Future<ApiResult<JsonMap>> closeQuiz(int quizId) =>
      _object('POST', '/teacher/quizzes/$quizId/close');

  /// The teacher's own question bank for this class and subject.
  Future<ApiResult<List<JsonMap>>> bankQuestions(int classId, int subjectId) =>
      _list('/question-bank?class_id=$classId&subject_id=$subjectId');

  // ─── Journeys ──────────────────────────────────────────────────────────────

  ApiResult<JourneyDraft> _journey(ApiResult<JsonMap> result) {
    if (!result.isSuccess) return ApiResult.failure(result.failure);
    try {
      return ApiResult.success(JourneyDraft.parse(result.data!['journey']));
    } on FormatException {
      return _unreadable();
    }
  }

  Future<ApiResult<List<JourneyDraft>>> journeys(
    int classId,
    int subjectId,
  ) async {
    final result = await _object(
      'GET',
      '/teacher/journeys?class_id=$classId&subject_id=$subjectId',
    );
    if (!result.isSuccess) return ApiResult.failure(result.failure);
    final list = result.data!['journeys'];
    if (list is! List) return _unreadable();
    try {
      return ApiResult.success(list.map(JourneyDraft.parse).toList());
    } on FormatException {
      return _unreadable();
    }
  }

  Future<ApiResult<JourneyDraft>> journey(int journeyId) async =>
      _journey(await _object('GET', '/teacher/journeys/$journeyId'));

  Future<ApiResult<JourneyDraft>> createJourney(
    int classId,
    int subjectId,
    String title,
  ) async => _journey(
    await _object('POST', '/teacher/journeys', {
      'class_id': classId,
      'subject_id': subjectId,
      'title': title,
    }),
  );

  Future<ApiResult<JourneyDraft>> updateJourney(
    JourneyDraft journey, {
    required String title,
    required bool graded,
    required int maxRetries,
    required List<JourneyStep> steps,
  }) async => _journey(
    await _object(
      'PUT',
      '/teacher/journeys/${journey.journeyId}',
      journey.toUpdateJson(
        title: title,
        graded: graded,
        maxRetries: maxRetries,
        steps: steps,
      ),
    ),
  );

  Future<ApiResult<JourneyDraft>> publishJourney(JourneyDraft journey) async =>
      _journey(
        await _object(
          'POST',
          '/teacher/journeys/${journey.journeyId}/publish',
          {'revision': journey.revision},
        ),
      );

  Future<ApiResult<JourneyDraft>> archiveJourney(JourneyDraft journey) async =>
      _journey(
        await _object(
          'POST',
          '/teacher/journeys/${journey.journeyId}/archive',
          {'revision': journey.revision},
        ),
      );

  /// Recordings this teacher uploaded for this class and subject, the only
  /// ones a journey step may use.
  Future<ApiResult<List<({int id, String title})>>> recordings(
    int classId,
    int subjectId,
  ) async {
    final result = await _list('/audio/list?subject_id=$subjectId');
    if (!result.isSuccess) return ApiResult.failure(result.failure);
    return ApiResult.success([
      for (final item in result.data!)
        if (item['audio_id'] is int &&
            item['title'] is String &&
            item['uploaded_by'] == teacherId &&
            item['class_id'] == classId &&
            item['subject_id'] == subjectId)
          (id: item['audio_id'] as int, title: item['title'] as String),
    ]);
  }
}
