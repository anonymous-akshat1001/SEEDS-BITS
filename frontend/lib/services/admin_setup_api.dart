import 'dart:convert';

import 'package:http/http.dart' as http;

import '../l10n/speech.dart';
import 'api_service.dart';

typedef JsonMap = Map<String, dynamic>;

/// Speech the administrator chose for a person: a language code
/// (en, hi, kn, te, bn) and a flutter_tts speed; null means not chosen.
typedef AdminSpeech = ({String? language, double? rate});

/// Administrator setup calls: people, shared phones, timetable, holidays,
/// issues and class records. Every call needs the admin's bearer token.
abstract final class AdminSetupApi {
  static const _timeout = Duration(seconds: 20);

  /// Text to show for a failed request. Readable server explanations (for
  /// example a timetable overlap) are shown as written; anything else uses
  /// the app's friendly message so raw JSON never reaches the screen.
  static String errorText(ApiFailure? failure) {
    if (failure == null) return Speech.t.adminSetupUnknownError;
    final status = failure.statusCode;
    if (status != null &&
        status >= 400 &&
        status < 500 &&
        status != 401 &&
        status != 403) {
      final detail = serverDetail(failure.debugDetails);
      if (detail != null) return detail;
    }
    return failure.message;
  }

  /// Reads a string `detail` from an error body, whether it was kept as JSON
  /// or as a decoded map printed with `toString()`.
  static String? serverDetail(String? raw) {
    if (raw == null) return null;
    final text = raw.trim();
    if (text.isEmpty) return null;
    try {
      final decoded = jsonDecode(text);
      if (decoded is Map && decoded['detail'] is String) {
        final detail = (decoded['detail'] as String).trim();
        return detail.isEmpty ? null : detail;
      }
      return null;
    } on FormatException {
      // Not JSON: fall through to the printed-map form.
    }
    const prefix = '{detail: ';
    if (text.startsWith(prefix) && text.endsWith('}')) {
      final detail = text.substring(prefix.length, text.length - 1).trim();
      if (detail.isEmpty || detail.startsWith('[') || detail.startsWith('{')) {
        return null;
      }
      return detail;
    }
    return null;
  }

  static String isoDate(DateTime day) =>
      '${day.year.toString().padLeft(4, '0')}-'
      '${day.month.toString().padLeft(2, '0')}-'
      '${day.day.toString().padLeft(2, '0')}';

  static String _query(Map<String, Object?> values) {
    final query = Uri(
      queryParameters: {
        for (final entry in values.entries)
          if (entry.value != null && '${entry.value}'.isNotEmpty)
            entry.key: '${entry.value}',
      },
    ).query;
    return query.isEmpty ? '' : '?$query';
  }

  static Future<ApiResult<List<JsonMap>>> _list(String path) async {
    final result = await ApiService.getResult(
      path,
      useAuth: true,
      requestTimeout: _timeout,
    );
    if (!result.isSuccess) return ApiResult.failure(result.failure);
    final data = result.data;
    if (data is! List) {
      return ApiResult.failure(
        ApiFailure(
          kind: ApiFailureKind.unknown,
          message: Speech.t.apiResponseUnreadable,
        ),
      );
    }
    return ApiResult.success([
      for (final item in data)
        if (item is Map) Map<String, dynamic>.from(item),
    ]);
  }

  static Future<ApiResult<JsonMap>> _post(String path, JsonMap body) =>
      ApiService.postResult(path, body, useAuth: true);

  static Future<ApiResult<JsonMap>> _put(String path, JsonMap body) =>
      ApiService.putResult(path, body, useAuth: true);

  static Future<ApiResult<void>> _delete(String path) =>
      ApiService.deleteResult(path, useAuth: true, requestTimeout: _timeout);

  /// PATCH with the same failure mapping as the other calls, so validation
  /// and conflict explanations reach the administrator.
  static Future<ApiResult<JsonMap>> _patch(String path, JsonMap body) async {
    try {
      final response = await http
          .patch(
            Uri.parse('${ApiService.baseUrl}$path'),
            headers: await ApiService.getHeaders(),
            body: jsonEncode(body),
          )
          .timeout(_timeout);
      Object? decoded;
      if (response.body.isNotEmpty) {
        try {
          decoded = jsonDecode(response.body);
        } on FormatException {
          decoded = response.body;
        }
      }
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResult.success(
          decoded is Map ? Map<String, dynamic>.from(decoded) : {'ok': true},
        );
      }
      return ApiResult.failure(
        ApiService.mapFailure(
          statusCode: response.statusCode,
          responseBody: decoded,
        ),
      );
    } catch (error) {
      return ApiResult.failure(ApiService.mapFailure(error: error));
    }
  }

  // ─── Catalog ───────────────────────────────────────────────────────────────

  static Future<ApiResult<List<JsonMap>>> classes({
    bool includeArchived = false,
  }) => _list('/catalog/classes?include_archived=$includeArchived');

  static Future<ApiResult<List<JsonMap>>> subjects({
    bool includeArchived = false,
  }) => _list('/catalog/subjects?include_archived=$includeArchived');

  static Future<ApiResult<List<JsonMap>>> classSubjects(
    int classId, {
    bool includeArchived = false,
  }) => _list(
    '/admin/classes/$classId/subjects?include_archived=$includeArchived',
  );

  // ─── Accounts ──────────────────────────────────────────────────────────────

  static Future<ApiResult<List<JsonMap>>> users({
    String search = '',
    String? role,
    String assignmentStatus = 'all',
    int? limit,
  }) => _list(
    '/admin/users${_query({'search': search.trim(), 'role': role, 'assignment_status': assignmentStatus, 'limit': limit})}',
  );

  /// [classId] is for students; [assignments] (class_id/subject_id pairs)
  /// is for teachers.
  static Future<ApiResult<JsonMap>> createPerson({
    required String name,
    required String phoneNumber,
    required String role,
    int? classId,
    List<({int classId, int subjectId})> assignments = const [],
    AdminSpeech speech = (language: null, rate: null),
  }) => _post('/admin/users', {
    'name': name,
    'phone_number': phoneNumber,
    'role': role,
    if (role == 'student' && classId != null) 'class_id': classId,
    if (role == 'teacher')
      'assignments': [
        for (final pair in assignments)
          {'class_id': pair.classId, 'subject_id': pair.subjectId},
      ],
    'speech_language': ?speech.language,
    'speech_rate': ?speech.rate,
  });

  /// [speech], when given, replaces both values (null clears one).
  static Future<ApiResult<JsonMap>> updatePerson(
    int accountId, {
    String? name,
    String? phoneNumber,
    bool? isActive,
    AdminSpeech? speech,
  }) => _patch('/admin/users/$accountId', {
    'name': ?name,
    'phone_number': ?phoneNumber,
    'is_active': ?isActive,
    if (speech != null) ...{
      'speech_language': speech.language,
      'speech_rate': speech.rate,
    },
  });

  static Future<ApiResult<JsonMap>> signOutEverywhere(
    int accountId,
    int expectedAuthVersion,
  ) => _post('/admin/users/$accountId/sign-out-everywhere', {
    'expected_auth_version': expectedAuthVersion,
  });

  // ─── Shared phones ─────────────────────────────────────────────────────────

  static Future<ApiResult<List<JsonMap>>> deviceGroups() =>
      _list('/admin/device-groups');

  static Future<ApiResult<JsonMap>> createDeviceGroup({
    required String name,
    required String entryPhoneNumber,
  }) => _post('/admin/device-groups', {
    'name': name,
    'entry_phone_number': entryPhoneNumber,
  });

  static Future<ApiResult<JsonMap>> updateDeviceGroup(
    int groupId, {
    String? name,
    String? entryPhoneNumber,
    bool? isActive,
  }) => _patch('/admin/device-groups/$groupId', {
    'name': ?name,
    'entry_phone_number': ?entryPhoneNumber,
    'is_active': ?isActive,
  });

  static Future<ApiResult<JsonMap>> addGroupMember(
    int groupId, {
    required int userId,
    required String profileCode,
  }) => _post('/admin/device-groups/$groupId/members', {
    'user_id': userId,
    'profile_code': profileCode,
  });

  static Future<ApiResult<void>> removeGroupMember(int groupId, int memberId) =>
      _delete('/admin/device-groups/$groupId/members/$memberId');

  // ─── Timetable ─────────────────────────────────────────────────────────────

  static Future<ApiResult<List<JsonMap>>> timetable({
    int? teacherId,
    int? classId,
    bool includeInactive = false,
  }) => _list(
    '/admin/timetable${_query({'teacher_id': teacherId, 'class_id': classId, 'include_inactive': includeInactive})}',
  );

  static Future<ApiResult<JsonMap>> createTimetableEntry(JsonMap body) =>
      _post('/admin/timetable', body);

  static Future<ApiResult<JsonMap>> updateTimetableEntry(
    int entryId,
    JsonMap body,
  ) => _patch('/admin/timetable/$entryId', body);

  static Future<ApiResult<List<JsonMap>>> occurrences(int entryId) =>
      _list('/admin/timetable/$entryId/occurrences');

  static Future<ApiResult<JsonMap>> setOccurrence(
    int entryId,
    String day, {
    required bool isCancelled,
    int? substituteTeacherId,
    int? lessonPlaylistId,
    String? note,
  }) => _put('/admin/timetable/$entryId/occurrences/$day', {
    'is_cancelled': isCancelled,
    'substitute_teacher_id': substituteTeacherId,
    'lesson_playlist_id': lessonPlaylistId,
    'note': (note?.trim().isEmpty ?? true) ? null : note!.trim(),
  });

  static Future<ApiResult<void>> clearOccurrence(int entryId, String day) =>
      _delete('/admin/timetable/$entryId/occurrences/$day');

  static Future<ApiResult<List<JsonMap>>> teacherLessons(
    int teacherId, {
    required int classId,
    required int subjectId,
  }) => _list(
    '/admin/teachers/$teacherId/lessons?class_id=$classId&subject_id=$subjectId',
  );

  static Future<ApiResult<List<JsonMap>>> schedule(DateTime day) =>
      _list('/admin/schedule?day=${isoDate(day)}');

  // ─── Holidays, issues and class records ────────────────────────────────────

  static Future<ApiResult<List<JsonMap>>> holidays() =>
      _list('/admin/holidays');

  static Future<ApiResult<JsonMap>> addHoliday(DateTime day, String name) =>
      _post('/admin/holidays', {'holiday_date': isoDate(day), 'name': name});

  static Future<ApiResult<void>> deleteHoliday(int holidayId) =>
      _delete('/admin/holidays/$holidayId');

  static Future<ApiResult<List<JsonMap>>> issues(String status) =>
      _list('/admin/issues?status=$status');

  static Future<ApiResult<JsonMap>> resolveIssue(int issueId) =>
      _post('/admin/issues/$issueId/resolve', const {});

  static Future<ApiResult<List<JsonMap>>> sessions(
    String status, {
    int limit = 100,
  }) => _list('/admin/sessions?status=$status&limit=$limit');

  static Future<ApiResult<JsonMap>> endSession(int sessionId) =>
      _post('/admin/sessions/$sessionId/end', const {});

  static Future<ApiResult<JsonMap>> extendSession(int sessionId) =>
      _post('/admin/sessions/$sessionId/extend', const {});
}
