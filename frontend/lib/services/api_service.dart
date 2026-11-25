import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Allows reading environment variables
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../l10n/speech.dart';

// Backend and websocket URL
final baseUrl = dotenv.env['API_BASE_URL'];
final wsBaseUrl = dotenv.env['WS_BASE_URL'];

enum ApiFailureKind {
  validation,
  unauthorized,
  notFound,
  server,
  network,
  unknown,
}

class ApiFailure {
  const ApiFailure({
    required this.kind,
    required this.message,
    this.statusCode,
    this.debugDetails,
  });

  final ApiFailureKind kind;
  final String message;
  final int? statusCode;
  final String? debugDetails;
}

class ApiResult<T> {
  const ApiResult.success(this.data) : failure = null;
  const ApiResult.failure(this.failure) : data = null;

  final T? data;
  final ApiFailure? failure;
  bool get isSuccess => failure == null;
}

// A static service class
class ApiService {
  static final String baseUrl =
      dotenv.env['API_BASE_URL'] ?? 'http://127.0.0.1:8000';
  static const bool devMode = false;

  static String? cachedToken; // set this right after reading from prefs

  /// Converts HTTP and transport failures into text safe for UI and TTS.
  /// Raw response details remain available only for debug logging.
  static ApiFailure mapFailure({
    int? statusCode,
    Object? responseBody,
    Object? error,
    String context = '',
  }) {
    final raw = responseBody?.toString() ?? error?.toString() ?? '';
    final normalized = raw.toLowerCase();
    final normalizedContext = context.toLowerCase();

    if (normalizedContext.contains('phone login') && statusCode != null) {
      if (statusCode == 403) {
        return ApiFailure(
          kind: ApiFailureKind.unauthorized,
          statusCode: statusCode,
          message: Speech.t.loginAdminUsesPassword,
          debugDetails: raw,
        );
      }
      if (statusCode == 401) {
        return ApiFailure(
          kind: ApiFailureKind.unauthorized,
          statusCode: statusCode,
          message: normalized.contains('profile')
              ? Speech.t.loginProfileNotRecognised
              : Speech.t.loginNumberNotRegistered,
          debugDetails: raw,
        );
      }
    }
    // Class lifecycle refusals explain themselves ("This class can start
    // from 08:50."); say that instead of a generic failure.
    final detail = responseBody is Map ? responseBody['detail'] : null;
    if (normalizedContext.startsWith('class ') &&
        (statusCode == 409 || statusCode == 404) &&
        detail is String &&
        detail.isNotEmpty) {
      return ApiFailure(
        kind: statusCode == 404
            ? ApiFailureKind.notFound
            : ApiFailureKind.validation,
        statusCode: statusCode,
        message: detail,
        debugDetails: raw,
      );
    }

    if (normalizedContext.contains('login') ||
        normalizedContext.contains('password change')) {
      if (statusCode == 429) {
        return ApiFailure(
          kind: ApiFailureKind.unauthorized,
          statusCode: statusCode,
          message: Speech.t.apiTemporarySignInPaused,
        );
      }
      if (statusCode == 401 &&
          normalized.contains('temporary credential expired')) {
        return ApiFailure(
          kind: ApiFailureKind.unauthorized,
          statusCode: statusCode,
          message: Speech.t.apiTemporaryCredentialExpired,
        );
      }
      if (statusCode == 400 &&
          normalized.contains('different from the temporary credential')) {
        return ApiFailure(
          kind: ApiFailureKind.validation,
          statusCode: statusCode,
          message: Speech.t.apiPasswordMustDiffer,
        );
      }
      if (statusCode == 401 && normalizedContext.contains('password change')) {
        return ApiFailure(
          kind: ApiFailureKind.unauthorized,
          statusCode: statusCode,
          message: normalized.contains('invalid credentials')
              ? Speech.t.apiTemporaryCredentialRejected
              : Speech.t.apiRecoverySignInExpired,
        );
      }
    }
    if (statusCode == 422 || statusCode == 400) {
      if (normalizedContext.contains('password') ||
          (normalized.contains('password') &&
              (normalized.contains('6') || normalized.contains('too_short')))) {
        return ApiFailure(
          kind: ApiFailureKind.validation,
          statusCode: statusCode,
          message: Speech.t.authErrorPasswordTooShort,
          debugDetails: raw,
        );
      }
      return ApiFailure(
        kind: ApiFailureKind.validation,
        statusCode: statusCode,
        message: Speech.t.apiCheckInformation,
        debugDetails: raw,
      );
    }
    if (statusCode == 401 || statusCode == 403) {
      return ApiFailure(
        kind: ApiFailureKind.unauthorized,
        statusCode: statusCode,
        message: normalizedContext.contains('login')
            ? Speech.t.apiInvalidLogin
            : Speech.t.apiNoPermission,
        debugDetails: raw,
      );
    }
    if (statusCode == 404) {
      return ApiFailure(
        kind: ApiFailureKind.notFound,
        statusCode: statusCode,
        message: normalizedContext.contains('session')
            ? Speech.t.apiSessionNotFound
            : Speech.t.apiItemNotFound,
        debugDetails: raw,
      );
    }
    if (statusCode != null && statusCode >= 500) {
      return ApiFailure(
        kind: ApiFailureKind.server,
        statusCode: statusCode,
        message: Speech.t.apiServiceUnavailable,
        debugDetails: raw,
      );
    }
    if (error != null || statusCode == null) {
      return ApiFailure(
        kind: ApiFailureKind.network,
        statusCode: statusCode,
        message: Speech.t.apiNetworkFailure,
        debugDetails: raw,
      );
    }
    return ApiFailure(
      kind: ApiFailureKind.unknown,
      statusCode: statusCode,
      message: Speech.t.apiUnknownFailure,
      debugDetails: raw,
    );
  }

  static void _debugFailure(String operation, ApiFailure failure) {
    if (kDebugMode) {
      debugPrint(
        '[API] Request failed (${failure.statusCode}, ${failure.kind.name}).',
      );
    }
  }

  static Object? _decodeBody(String body) {
    if (body.isEmpty) return null;
    try {
      return jsonDecode(body);
    } catch (_) {
      return body;
    }
  }

  static Future<ApiResult<dynamic>> getResult(
    String path, {
    bool useAuth = false,
    String context = '',
    Duration? requestTimeout,
    bool Function()? canSend,
  }) async {
    final uri = await _buildUri(path);
    final headers = await _buildHeaders(useAuth: useAuth);
    if (canSend != null && !canSend()) {
      return ApiResult.failure(
        ApiFailure(
          kind: ApiFailureKind.unauthorized,
          message: Speech.t.apiAccountChangedRequestNotSent,
        ),
      );
    }
    try {
      final request = http.get(uri, headers: headers);
      final response = requestTimeout == null
          ? await request
          : await request.timeout(requestTimeout);
      final body = _decodeBody(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResult<dynamic>.success(body ?? <String, dynamic>{});
      }
      final failure = mapFailure(
        statusCode: response.statusCode,
        responseBody: body,
        context: context,
      );
      _debugFailure('GET $path', failure);
      return ApiResult<dynamic>.failure(failure);
    } catch (error) {
      final failure = mapFailure(error: error, context: context);
      _debugFailure('GET $path', failure);
      return ApiResult<dynamic>.failure(failure);
    }
  }

  static Future<ApiResult<Map<String, dynamic>>> postResult(
    String path,
    Map<String, dynamic> data, {
    bool useAuth = false,
    String context = '',
    Duration requestTimeout = const Duration(seconds: 20),
    bool requireJsonObject = false,
    bool Function()? canSend,
  }) => _writeResult(
    path,
    data,
    useAuth: useAuth,
    context: context,
    requestTimeout: requestTimeout,
    requireJsonObject: requireJsonObject,
    canSend: canSend,
  );

  static Future<ApiResult<Map<String, dynamic>>> putResult(
    String path,
    Map<String, dynamic> data, {
    bool useAuth = false,
    String context = '',
    Duration requestTimeout = const Duration(seconds: 20),
    bool requireJsonObject = true,
    bool Function()? canSend,
  }) => _writeResult(
    path,
    data,
    method: 'PUT',
    useAuth: useAuth,
    context: context,
    requestTimeout: requestTimeout,
    requireJsonObject: requireJsonObject,
    canSend: canSend,
  );

  static Future<ApiResult<Map<String, dynamic>>> _writeResult(
    String path,
    Map<String, dynamic> data, {
    String method = 'POST',
    bool useAuth = false,
    String context = '',
    Duration requestTimeout = const Duration(seconds: 20),
    bool requireJsonObject = false,
    bool Function()? canSend,
  }) async {
    final uri = await _buildUri(path);
    final headers = await _buildHeaders(useAuth: useAuth);
    if (canSend != null && !canSend()) {
      final failure = ApiFailure(
        kind: ApiFailureKind.unauthorized,
        message: Speech.t.apiAccountOrSessionChanged,
      );
      _debugFailure('$method $path', failure);
      return ApiResult.failure(failure);
    }
    try {
      final request = method == 'PUT'
          ? http.put(uri, headers: headers, body: jsonEncode(data))
          : http.post(uri, headers: headers, body: jsonEncode(data));
      final response = await request.timeout(requestTimeout);
      final body = _decodeBody(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (requireJsonObject && body is! Map<String, dynamic>) {
          final failure = ApiFailure(
            kind: ApiFailureKind.unknown,
            statusCode: response.statusCode,
            message: Speech.t.apiResponseUnreadable,
            debugDetails: 'Expected a JSON object response.',
          );
          _debugFailure('$method $path', failure);
          return ApiResult<Map<String, dynamic>>.failure(failure);
        }
        return ApiResult<Map<String, dynamic>>.success(
          body is Map<String, dynamic> ? body : <String, dynamic>{'ok': true},
        );
      }
      final failure = mapFailure(
        statusCode: response.statusCode,
        responseBody: body,
        context: context,
      );
      _debugFailure('$method $path', failure);
      return ApiResult<Map<String, dynamic>>.failure(failure);
    } catch (error) {
      final failure = mapFailure(error: error, context: context);
      _debugFailure('$method $path', failure);
      return ApiResult<Map<String, dynamic>>.failure(failure);
    }
  }

  static Future<ApiResult<Map<String, dynamic>>> postAcknowledged(
    String path,
    Map<String, dynamic> data, {
    String context = '',
    bool Function()? canSend,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    final token = preferences.getString('token');
    final account = preferences.getInt('user_id');
    if (token == null || token.isEmpty) {
      final failure = ApiFailure(
        kind: ApiFailureKind.unauthorized,
        message: Speech.t.apiSignInBeforeAction,
      );
      _debugFailure('POST $path', failure);
      return ApiResult.failure(failure);
    }
    bool currentAccount() =>
        preferences.getString('token') == token &&
        preferences.getInt('user_id') == account;
    final result = await postResult(
      path,
      data,
      useAuth: true,
      context: context,
      requestTimeout: const Duration(seconds: 10),
      requireJsonObject: true,
      canSend: () => currentAccount() && (canSend?.call() ?? true),
    );
    if (!currentAccount()) {
      final failure = ApiFailure(
        kind: ApiFailureKind.unauthorized,
        message: Speech.t.apiAccountChangedNotConfirmed,
      );
      _debugFailure('POST $path', failure);
      return ApiResult.failure(failure);
    }
    if (result.isSuccess && result.data?['ok'] == true) return result;
    final original = result.failure;
    final ambiguous =
        original == null ||
        original.kind == ApiFailureKind.network ||
        original.kind == ApiFailureKind.server ||
        original.kind == ApiFailureKind.unknown;
    final failure = ApiFailure(
      kind: original?.kind ?? ApiFailureKind.unknown,
      statusCode: original?.statusCode,
      debugDetails: original?.debugDetails,
      message: ambiguous ? Speech.t.apiActionNotConfirmed : original.message,
    );
    _debugFailure('POST $path', failure);
    return ApiResult.failure(failure);
  }

  static Future<ApiResult<void>> deleteResult(
    String path, {
    bool useAuth = false,
    String context = '',
    Map<String, dynamic>? data,
    Duration? requestTimeout,
    bool Function()? canSend,
  }) async {
    final uri = await _buildUri(path);
    final headers = await _buildHeaders(useAuth: useAuth);
    if (canSend != null && !canSend()) {
      return ApiResult.failure(
        ApiFailure(
          kind: ApiFailureKind.unauthorized,
          message: Speech.t.apiAccountChangedActionNotSent,
        ),
      );
    }
    try {
      final request = http.delete(
        uri,
        headers: headers,
        body: data == null ? null : jsonEncode(data),
      );
      final response = requestTimeout == null
          ? await request
          : await request.timeout(requestTimeout);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return const ApiResult<void>.success(null);
      }
      final failure = mapFailure(
        statusCode: response.statusCode,
        responseBody: _decodeBody(response.body),
        context: context,
      );
      _debugFailure('DELETE $path', failure);
      return ApiResult<void>.failure(failure);
    } catch (error) {
      final failure = mapFailure(error: error, context: context);
      _debugFailure('DELETE $path', failure);
      return ApiResult<void>.failure(failure);
    }
  }

  /// Students and teachers sign in with their phone number only; a shared
  /// phone also needs the person's short [profileCode]. The result may be
  /// `{"profile_required": true, "code_length": n}` instead of a session.
  static Future<ApiResult<Map<String, dynamic>>> phoneLoginResult({
    required String phoneNumber,
    String? profileCode,
  }) async {
    final uri = await _buildUri('/auth/phone-login');
    try {
      final response = await http
          .post(
            uri,
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({
              'phone_number': phoneNumber,
              'profile_code': ?profileCode,
            }),
          )
          .timeout(const Duration(seconds: 10));
      final body = _decodeBody(response.body);
      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          body is Map<String, dynamic>) {
        return ApiResult<Map<String, dynamic>>.success(body);
      }
      final failure = mapFailure(
        statusCode: response.statusCode,
        responseBody: body,
        context: 'phone login',
      );
      _debugFailure('PHONE LOGIN', failure);
      return ApiResult<Map<String, dynamic>>.failure(failure);
    } catch (error) {
      final failure = mapFailure(error: error, context: 'phone login');
      _debugFailure('PHONE LOGIN', failure);
      return ApiResult<Map<String, dynamic>>.failure(failure);
    }
  }

  /// Administrator password sign-in.
  static Future<ApiResult<Map<String, dynamic>>> loginResult({
    required String phoneNumber,
    required String password,
  }) async {
    final uri = await _buildUri('/auth/login');
    try {
      final response = await http
          .post(
            uri,
            headers: const {
              'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: {'username': phoneNumber, 'password': password},
          )
          .timeout(const Duration(seconds: 10));
      final body = _decodeBody(response.body);
      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          body is Map<String, dynamic>) {
        return ApiResult<Map<String, dynamic>>.success(body);
      }
      final failure = mapFailure(
        statusCode: response.statusCode,
        responseBody: body,
        context: 'login',
      );
      _debugFailure('LOGIN', failure);
      return ApiResult<Map<String, dynamic>>.failure(failure);
    } catch (error) {
      final failure = mapFailure(error: error, context: 'login');
      _debugFailure('LOGIN', failure);
      return ApiResult<Map<String, dynamic>>.failure(failure);
    }
  }

  static Future<ApiResult<Map<String, dynamic>>> joinSessionResult(
    int sessionId,
  ) async {
    final uri = await _buildUri('/sessions/$sessionId/join');
    final prefs = await SharedPreferences.getInstance();
    try {
      final request = http.MultipartRequest('POST', uri);
      if (!devMode) {
        final token = prefs.getString('token');
        if (token != null) request.headers['Authorization'] = 'Bearer $token';
      }
      final streamed = await request.send();
      final responseBody = await streamed.stream.bytesToString();
      final body = _decodeBody(responseBody);
      if (streamed.statusCode >= 200 &&
          streamed.statusCode < 300 &&
          body is Map<String, dynamic>) {
        return ApiResult<Map<String, dynamic>>.success(body);
      }
      final failure = mapFailure(
        statusCode: streamed.statusCode,
        responseBody: body,
        context: 'session join',
      );
      _debugFailure('JOIN SESSION', failure);
      return ApiResult<Map<String, dynamic>>.failure(failure);
    } catch (error) {
      final failure = mapFailure(error: error, context: 'session join');
      _debugFailure('JOIN SESSION', failure);
      return ApiResult<Map<String, dynamic>>.failure(failure);
    }
  }

  // Build full URL for endpoint (synchronous)
  static Future<Uri> _buildUri(String path) async {
    String uri = '$baseUrl$path';

    if (devMode) {
      // opens local storage
      final prefs = await SharedPreferences.getInstance();
      // reads locally stored user id
      final userId = prefs.getInt('user_id');

      if (userId != null) {
        // Add ?user_id=123 or &user_id=123 depending on existing params
        uri += uri.contains('?') ? '&user_id=$userId' : '?user_id=$userId';
      }
    }

    // converts string to Uri
    return Uri.parse(uri);
  }

  // Add Authorization header if token exists
  static Future<Map<String, String>> _buildHeaders({
    bool useAuth = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // tells backend the request body is JSON
    final headers = {'Content-Type': 'application/json'};

    // only attach token if auth required and production mode
    if (useAuth && !devMode) {
      final token = prefs.getString('token');

      cachedToken = token;

      if (token != null && token.isNotEmpty) {
        // standard JWT auth header
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // Public wrapper which allows other code to reuse headers
  static Future<Map<String, String>> getHeaders() async {
    return await _buildHeaders(useAuth: true);
  }

  /// Builds an authenticated URL for media clients that cannot attach headers.
  static Future<String> mediaUrl(String path) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final uri = Uri.parse('$baseUrl$path');
    if (token == null || token.isEmpty) return uri.toString();
    return uri
        .replace(
          queryParameters: {...uri.queryParameters, 'access_token': token},
        )
        .toString();
  }

  ////////////////////// POST /////////////////////////////

  // Sends POST request
  static Future<Map<String, dynamic>?> post(
    String path,
    Map<String, dynamic> data, {
    bool useAuth = false,
  }) async {
    // builds URL and headers automatically
    final uri = await _buildUri(path);
    final headers = await _buildHeaders(useAuth: useAuth);

    try {
      // converts Dart map to JSON and sends request
      final res = await http.post(
        uri,
        headers: headers,
        body: jsonEncode(data),
      );

      if (res.statusCode >= 200 && res.statusCode < 300) {
        if (res.body.isEmpty) {
          return {'ok': true};
        }
        // Converts response JSON → Dart map
        return jsonDecode(res.body);
      } else {
        debugPrint('[API] POST failed (${res.statusCode}).');
        try {
          final decoded = jsonDecode(res.body);
          if (decoded is Map<String, dynamic>) {
            return {...decoded, 'status_code': res.statusCode};
          }
        } catch (_) {
          // Fall through to a plain error message below.
        }
        return {
          'detail': res.body.isNotEmpty ? res.body : Speech.t.apiRequestFailed,
          'status_code': res.statusCode,
        };
      }
    } catch (e) {
      debugPrint('[API] POST error (${e.runtimeType}).');
      return null;
    }
  }

  ////////////////  GET  /////////////////////////

  // Fetches data
  static Future<dynamic> get(String path, {bool useAuth = false}) async {
    final uri = await _buildUri(path);
    final headers = await _buildHeaders(useAuth: useAuth);

    try {
      final res = await http.get(uri, headers: headers);
      if (res.statusCode >= 200 && res.statusCode < 300) {
        if (res.body.isEmpty) return {};
        // Converts JSON array/object automatically
        return jsonDecode(res.body);
      } else {
        debugPrint('[API] GET failed (${res.statusCode}).');
        return null;
      }
    } catch (e) {
      debugPrint('[API] GET error (${e.runtimeType}).');
      return null;
    }
  }

  /////////////////////////// DELETE /////////////////////////

  // deletes resources
  static Future<bool> delete(String path, {bool useAuth = false}) async {
    final uri = await _buildUri(path);
    final headers = await _buildHeaders(useAuth: useAuth);

    try {
      final res = await http.delete(uri, headers: headers);
      if (res.statusCode >= 200 && res.statusCode < 300) {
        return true;
      } else {
        debugPrint('[API] DELETE failed (${res.statusCode}).');
        return false;
      }
    } catch (e) {
      debugPrint('[API] DELETE error (${e.runtimeType}).');
      return false;
    }
  }

  /////////////////////////// PUT  /////////////////////////

  // updates resources
  static Future<Map<String, dynamic>?> put(
    String path,
    Map<String, dynamic> data, {
    bool useAuth = false,
  }) async {
    final uri = await _buildUri(path);
    final headers = await _buildHeaders(useAuth: useAuth);

    try {
      final res = await http.put(uri, headers: headers, body: jsonEncode(data));

      if (res.statusCode >= 200 && res.statusCode < 300) {
        return jsonDecode(res.body);
      } else {
        debugPrint('[API] PUT failed (${res.statusCode}).');
        return null;
      }
    } catch (e) {
      debugPrint('[API] PUT error (${e.runtimeType}).');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> patch(
    String path,
    Map<String, dynamic> data, {
    bool useAuth = true,
  }) async {
    final uri = await _buildUri(path);
    final headers = await _buildHeaders(useAuth: useAuth);
    try {
      final response = await http.patch(
        uri,
        headers: headers,
        body: jsonEncode(data),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response.body.isEmpty
            ? <String, dynamic>{'ok': true}
            : Map<String, dynamic>.from(jsonDecode(response.body) as Map);
      }
      return null;
    } catch (error) {
      debugPrint('[API] PATCH error (${error.runtimeType}).');
      return null;
    }
  }

  /////////////////////////// FILE UPLOAD  /////////////////////////

  // Uploads file using multipart/form-data
  static Future<Map<String, dynamic>?> uploadFile(
    String path,
    String filePath, {
    bool useAuth = false,
    Map<String, String>? additionalFields,
  }) async {
    final uri = await _buildUri(path);
    final prefs = await SharedPreferences.getInstance();

    try {
      // Multipart request allows files + form fields
      var req = http.MultipartRequest("POST", uri);

      if (useAuth && !devMode) {
        final token = prefs.getString('token');

        cachedToken = token;

        if (token != null && token.isNotEmpty) {
          req.headers['Authorization'] = 'Bearer $token';
        }
      }

      // Add additional form fields if provided
      if (additionalFields != null) {
        additionalFields.forEach((key, value) {
          req.fields[key] = value;
        });
      }

      // Reads file from device and attaches it to request
      req.files.add(await http.MultipartFile.fromPath("file", filePath));

      var res = await req.send();
      final body = await res.stream.bytesToString();

      if (res.statusCode >= 200 && res.statusCode < 300) {
        return jsonDecode(body);
      } else {
        debugPrint('[API] Upload failed (${res.statusCode}).');
        return null;
      }
    } catch (e) {
      debugPrint('[API] Upload error (${e.runtimeType}).');
      return null;
    }
  }

  /////////////////////////// AUTHENTICATION ENDPOINTS /////////////////////////

  /////////////////////////// SESSION ENDPOINTS /////////////////////////

  /// Get all active sessions
  static Future<List<dynamic>?> getActiveSessions() async {
    final result = await get('/sessions/active', useAuth: true);
    if (result is List) {
      return result;
    }
    return null;
  }

  /// End a session for everyone while preserving its history.
  static Future<bool> endSession(int sessionId) async {
    final result = await postResult(
      '/sessions/$sessionId/end',
      const {},
      useAuth: true,
      context: 'session ending',
    );
    return result.isSuccess;
  }

  /// What this person can do now: the live class, today's classes and,
  /// for teachers, their class and subject workspaces.
  static Future<ApiResult<dynamic>> home() => getResult(
    '/me/home',
    useAuth: true,
    context: 'home',
    requestTimeout: const Duration(seconds: 15),
  );

  /// Starts (or returns to) a timetabled class, or an unscheduled class for
  /// an assigned class and subject.
  static Future<ApiResult<Map<String, dynamic>>> startClass({
    int? entryId,
    String? occurrenceDate,
    int? classId,
    int? subjectId,
  }) => postResult(
    '/classes/start',
    {
      'entry_id': ?entryId,
      'occurrence_date': ?occurrenceDate,
      'class_id': ?classId,
      'subject_id': ?subjectId,
    },
    useAuth: true,
    context: 'class start',
    requireJsonObject: true,
  );

  static Future<ApiResult<Map<String, dynamic>>> extendClass(int sessionId) =>
      postResult(
        '/sessions/$sessionId/extend',
        const {},
        useAuth: true,
        context: 'class extension',
        requireJsonObject: true,
      );

  static Future<ApiResult<dynamic>> classRoster(int sessionId) => getResult(
    '/sessions/$sessionId/roster',
    useAuth: true,
    context: 'class roster',
  );

  static Future<ApiResult<Map<String, dynamic>>> remindNotJoined(
    int sessionId,
  ) => postResult(
    '/sessions/$sessionId/remind-not-joined',
    const {},
    useAuth: true,
    context: 'class reminder',
    requireJsonObject: true,
  );

  /// Marks the administrator's notices on the teacher's Home as heard.
  static Future<ApiResult<Map<String, dynamic>>> markNoticesSeen(
    List<int> noticeIds,
  ) => postResult(
    '/me/notices/seen',
    {'notice_ids': noticeIds},
    useAuth: true,
    context: 'home notices',
    requireJsonObject: true,
  );

  /// Published quizzes and journeys the teacher can start in this class.
  static Future<ApiResult<Map<String, dynamic>>> classActivities(
    int sessionId,
  ) async {
    final result = await getResult(
      '/sessions/$sessionId/activities',
      useAuth: true,
      context: 'class activities',
    );
    if (!result.isSuccess) return ApiResult.failure(result.failure!);
    return result.data is Map
        ? ApiResult.success(Map<String, dynamic>.from(result.data as Map))
        : ApiResult.success(const {'quizzes': [], 'journeys': []});
  }

  static Future<ApiResult<Map<String, dynamic>>> startClassActivity(
    int sessionId, {
    required String kind,
    required int id,
  }) => postResult(
    '/sessions/$sessionId/activity',
    {'kind': kind, 'id': id},
    useAuth: true,
    context: 'class activity',
    requireJsonObject: true,
  );

  static Future<ApiResult<void>> stopClassActivity(int sessionId) =>
      deleteResult(
        '/sessions/$sessionId/activity',
        useAuth: true,
        context: 'class activity',
      );

  /// Closes the class recording for everyone (the recording is kept).
  static Future<ApiResult<void>> closeClassRecording(int sessionId) =>
      deleteResult(
        '/sessions/$sessionId/audio',
        useAuth: true,
        context: 'class recording',
      );

  /// Enrolled students who have not finished the open quiz or journey.
  static Future<ApiResult<Map<String, dynamic>>> classActivityLeft(
    int sessionId,
  ) async {
    final result = await getResult(
      '/sessions/$sessionId/activity/left',
      useAuth: true,
      context: 'class activity',
    );
    if (!result.isSuccess) return ApiResult.failure(result.failure!);
    return result.data is Map
        ? ApiResult.success(Map<String, dynamic>.from(result.data as Map))
        : ApiResult.success(const {'in_class': [], 'whole_class': []});
  }

  static Future<ApiResult<Map<String, dynamic>>> remindClassActivity(
    int sessionId,
  ) => postResult(
    '/sessions/$sessionId/activity/remind',
    const {},
    useAuth: true,
    context: 'class activity',
    requireJsonObject: true,
  );

  /// Starts or resumes a quiz attempt; the failure carries the server's
  /// reason ("This quiz is closed.") so it can be spoken as is.
  static Future<ApiResult<Map<String, dynamic>>> startClassQuiz(int quizId) =>
      postResult(
        '/student/quizzes/$quizId/attempts',
        const {},
        useAuth: true,
        context: 'class quiz',
        requireJsonObject: true,
      );

  /// Get session state
  static Future<Map<String, dynamic>?> getSessionState(int sessionId) async {
    return await get('/sessions/$sessionId/state', useAuth: true);
  }

  /////////////////////////// PARTICIPANT ENDPOINTS /////////////////////////

  /// Join a session as a participant
  static Future<Map<String, dynamic>?> joinSession(int sessionId) async {
    final uri = await _buildUri('/sessions/$sessionId/join');
    final prefs = await SharedPreferences.getInstance();

    try {
      var req = http.MultipartRequest("POST", uri);

      if (!devMode) {
        final token = prefs.getString('token');
        cachedToken = token;
        if (token != null) {
          req.headers['Authorization'] = 'Bearer $token';
        }
      }

      var res = await req.send();
      final body = await res.stream.bytesToString();

      if (res.statusCode >= 200 && res.statusCode < 300) {
        return jsonDecode(body);
      } else {
        debugPrint('[API] Join failed (${res.statusCode}).');
        return null;
      }
    } catch (e) {
      debugPrint('[API] Join error (${e.runtimeType}).');
      return null;
    }
  }

  /// Remove a participant from session (teacher only)
  static Future<bool> kickParticipant(int sessionId, int participantId) async {
    return await delete(
      '/sessions/$sessionId/participants/$participantId',
      useAuth: true,
    );
  }

  // Uploads file using bytes (for web support)
  static Future<Map<String, dynamic>?> uploadFileBytes(
    String path,
    Uint8List fileBytes,
    String filename, {
    bool useAuth = false,
    Map<String, String>? additionalFields,
  }) async {
    final uri = await _buildUri(path);
    final prefs = await SharedPreferences.getInstance();

    try {
      var req = http.MultipartRequest("POST", uri);

      if (useAuth && !devMode) {
        final token = prefs.getString('token');
        cachedToken = token;
        if (token != null && token.isNotEmpty) {
          req.headers['Authorization'] = 'Bearer $token';
        }
      }

      if (additionalFields != null) {
        additionalFields.forEach((key, value) {
          req.fields[key] = value;
        });
      }

      final ext = filename.split('.').last.toLowerCase();
      String subType = 'mpeg';
      switch (ext) {
        case 'wav':
          subType = 'wav';
          break;
        case 'ogg':
          subType = 'ogg';
          break;
        case 'webm':
          subType = 'webm';
          break;
        case 'm4a':
          subType = 'x-m4a';
          break;
        case 'mp4':
          subType = 'mp4';
          break;
        case 'mp3':
        default:
          subType = 'mpeg';
          break;
      }

      req.files.add(
        http.MultipartFile.fromBytes(
          "file",
          fileBytes,
          filename: filename,
          contentType: MediaType('audio', subType),
        ),
      );

      var res = await req.send();
      final body = await res.stream.bytesToString();

      if (res.statusCode >= 200 && res.statusCode < 300) {
        return jsonDecode(body);
      } else {
        debugPrint('[API] Upload failed (${res.statusCode}).');
        return null;
      }
    } catch (e) {
      debugPrint('[API] Upload error (${e.runtimeType}).');
      return null;
    }
  }

  /////////////////////////// AUDIO ENDPOINTS /////////////////////////

  /// Upload audio file (teacher only) - works on mobile
  static Future<Map<String, dynamic>?> uploadAudio({
    required String filePath,
    required String title,
    String description = '',
    List<int> sessionIds = const [],
    required int classId,
    required int subjectId,
  }) async {
    return await uploadFile(
      '/audio/upload',
      filePath,
      useAuth: true,
      additionalFields: {
        'title': title,
        'description': description,
        'session_ids': jsonEncode(sessionIds),
        'class_id': classId.toString(),
        'subject_id': subjectId.toString(),
      },
    );
  }

  /// Upload audio file using bytes (teacher only) - works on web
  static Future<Map<String, dynamic>?> uploadAudioBytes({
    required Uint8List fileBytes,
    required String filename,
    required String title,
    String description = '',
    List<int> sessionIds = const [],
    required int classId,
    required int subjectId,
  }) async {
    return await uploadFileBytes(
      '/audio/upload',
      fileBytes,
      filename,
      useAuth: true,
      additionalFields: {
        'title': title,
        'description': description,
        'session_ids': jsonEncode(sessionIds),
        'class_id': classId.toString(),
        'subject_id': subjectId.toString(),
      },
    );
  }

  /// Get list of uploaded audio files
  static Future<List<dynamic>?> getAudioList() async {
    final result = await get('/audio/list', useAuth: true);
    if (result is List) {
      return result;
    } else if (result is Map && result.containsKey('files')) {
      return result['files'] as List?;
    }
    return null;
  }

  static Future<Map<String, dynamic>?> getAccessContext() async {
    final result = await get('/me/access-context', useAuth: true);
    return result is Map ? Map<String, dynamic>.from(result) : null;
  }

  static Future<List<dynamic>> getClasses({
    bool includeArchived = false,
  }) async {
    final result = await get(
      '/catalog/classes?include_archived=$includeArchived',
      useAuth: true,
    );
    return result is List ? result : const [];
  }

  static Future<List<dynamic>> getSubjects({
    bool includeArchived = false,
  }) async {
    final result = await get(
      '/catalog/subjects?include_archived=$includeArchived',
      useAuth: true,
    );
    return result is List ? result : const [];
  }

  static Future<List<dynamic>> getAdminUsers({
    String search = '',
    String? role,
    String assignmentStatus = 'all',
  }) async {
    final query = Uri(
      queryParameters: {
        if (search.isNotEmpty) 'search': search,
        if (role != null) 'role': role,
        'assignment_status': assignmentStatus,
      },
    ).query;
    final result = await get('/admin/users?$query', useAuth: true);
    return result is List ? result : const [];
  }

  static Future<Map<String, dynamic>?> enrollStudent(
    int studentId,
    int classId,
  ) => post('/admin/students/$studentId/class', {
    'class_id': classId,
  }, useAuth: true);

  static Future<bool> removeStudentClass(int studentId) =>
      delete('/admin/students/$studentId/class', useAuth: true);

  static Future<List<dynamic>> getClassSubjects(
    int classId, {
    bool includeArchived = false,
  }) async {
    final result = await get(
      '/admin/classes/$classId/subjects?include_archived=$includeArchived',
      useAuth: true,
    );
    return result is List ? result : const [];
  }

  static Future<Map<String, dynamic>?> associateClassSubject(
    int classId,
    int subjectId,
  ) => post('/admin/classes/$classId/subjects', {
    'subject_id': subjectId,
  }, useAuth: true);

  static Future<bool> archiveClassSubject(int classId, int associationId) =>
      delete('/admin/classes/$classId/subjects/$associationId', useAuth: true);

  static Future<Map<String, dynamic>?> assignTeacher(
    int teacherId,
    int classId,
    int subjectId,
  ) => post('/admin/teachers/$teacherId/assignments', {
    'class_id': classId,
    'subject_id': subjectId,
  }, useAuth: true);

  static Future<List<dynamic>> getTeacherAssignments(int teacherId) async {
    final result = await get(
      '/admin/teachers/$teacherId/assignments',
      useAuth: true,
    );
    return result is List ? result : const [];
  }

  static Future<bool> archiveTeacherAssignment(
    int teacherId,
    int assignmentId,
  ) => delete(
    '/admin/teachers/$teacherId/assignments/$assignmentId',
    useAuth: true,
  );

  static Future<Map<String, dynamic>?> createSubject(String name) =>
      post('/admin/subjects', {'name': name}, useAuth: true);

  static Future<Map<String, dynamic>?> createClass(
    String name,
    int sortOrder,
  ) => post('/admin/classes', {
    'name': name,
    'sort_order': sortOrder,
  }, useAuth: true);

  static Future<Map<String, dynamic>?> setSubjectArchived(
    int subjectId,
    bool archived,
  ) => post(
    '/admin/subjects/$subjectId/archive?archived=$archived',
    const {},
    useAuth: true,
  );

  static Future<Map<String, dynamic>?> setClassArchived(
    int classId,
    bool archived,
  ) => post(
    '/admin/classes/$classId/archive?archived=$archived',
    const {},
    useAuth: true,
  );

  static Future<List<dynamic>> getTeacherPlaylists({
    bool includeArchived = false,
  }) async {
    final result = await get(
      '/teacher-playlists?include_archived=$includeArchived',
      useAuth: true,
    );
    return result is List ? result : const [];
  }

  static Future<Map<String, dynamic>?> createTeacherPlaylist({
    required String title,
    required int classId,
    required int subjectId,
    String description = '',
  }) => post('/teacher-playlists', {
    'title': title,
    'description': description,
    'class_id': classId,
    'subject_id': subjectId,
  }, useAuth: true);

  static Future<Map<String, dynamic>?> getTeacherPlaylist(
    int playlistId,
  ) async {
    final result = await get('/teacher-playlists/$playlistId', useAuth: true);
    return result is Map ? Map<String, dynamic>.from(result) : null;
  }

  static Future<Map<String, dynamic>?> updateTeacherPlaylist(
    int playlistId, {
    required String title,
    String? description,
  }) => patch('/teacher-playlists/$playlistId', {
    'title': title,
    if (description != null) 'description': description,
  });

  static Future<Map<String, dynamic>?> addTeacherPlaylistItem(
    int playlistId,
    int audioId,
  ) => post('/teacher-playlists/$playlistId/items', {
    'audio_id': audioId,
  }, useAuth: true);

  static Future<Map<String, dynamic>?> reorderTeacherPlaylist(
    int playlistId,
    List<int> itemIds,
  ) => post('/teacher-playlists/$playlistId/reorder', {
    'item_ids': itemIds,
  }, useAuth: true);

  static Future<Map<String, dynamic>?> setTeacherPlaylistPublished(
    int playlistId,
    bool published,
  ) => post(
    '/teacher-playlists/$playlistId/publish?published=$published',
    const {},
    useAuth: true,
  );

  static Future<Map<String, dynamic>?> setTeacherPlaylistArchived(
    int playlistId,
    bool archived,
  ) => post(
    '/teacher-playlists/$playlistId/archive?archived=$archived',
    const {},
    useAuth: true,
  );

  static Future<bool> removeTeacherPlaylistItem(int playlistId, int itemId) =>
      delete('/teacher-playlists/$playlistId/items/$itemId', useAuth: true);

  static Future<List<dynamic>> getVisibleTeacherPlaylists({
    int? subjectId,
  }) async {
    final suffix = subjectId == null ? '' : '?subject_id=$subjectId';
    final result = await get(
      '/student/teacher-playlists$suffix',
      useAuth: true,
    );
    return result is List ? result : const [];
  }

  static Future<Map<String, dynamic>?> getVisibleTeacherPlaylist(
    int playlistId,
  ) async {
    final result = await get(
      '/student/teacher-playlists/$playlistId',
      useAuth: true,
    );
    return result is Map ? Map<String, dynamic>.from(result) : null;
  }

  static Future<List<dynamic>> getStudentPlaylists() async {
    final result = await get('/student-playlists', useAuth: true);
    return result is List ? result : const [];
  }

  static Future<Map<String, dynamic>?> getStudentPlaylist(
    int playlistId,
  ) async {
    final result = await get('/student-playlists/$playlistId', useAuth: true);
    return result is Map ? Map<String, dynamic>.from(result) : null;
  }

  static Future<Map<String, dynamic>?> createStudentPlaylist({
    required String title,
    String description = '',
  }) => post('/student-playlists', {
    'title': title,
    'description': description,
  }, useAuth: true);

  static Future<Map<String, dynamic>?> updateStudentPlaylist(
    int playlistId, {
    required String title,
    String? description,
  }) => patch('/student-playlists/$playlistId', {
    'title': title,
    if (description != null) 'description': description,
  });

  static Future<Map<String, dynamic>?> addStudentPlaylistItem(
    int playlistId,
    int audioId,
  ) => post('/student-playlists/$playlistId/items', {
    'audio_id': audioId,
  }, useAuth: true);

  static Future<Map<String, dynamic>?> reorderStudentPlaylist(
    int playlistId,
    List<int> itemIds,
  ) => post('/student-playlists/$playlistId/reorder', {
    'item_ids': itemIds,
  }, useAuth: true);

  static Future<bool> removeStudentPlaylistItem(int playlistId, int itemId) =>
      delete('/student-playlists/$playlistId/items/$itemId', useAuth: true);

  static Future<bool> deleteStudentPlaylist(int playlistId) =>
      delete('/student-playlists/$playlistId', useAuth: true);

  static Future<List<dynamic>> getBankQuestions({
    int? classId,
    int? subjectId,
    String search = '',
  }) async {
    final query = Uri(
      queryParameters: {
        if (classId != null) 'class_id': '$classId',
        if (subjectId != null) 'subject_id': '$subjectId',
        if (search.trim().isNotEmpty) 'search': search.trim(),
      },
    ).query;
    final result = await get('/question-bank?$query', useAuth: true);
    return result is List ? result : const [];
  }

  static Future<Map<String, dynamic>?> createBankQuestion({
    required int classId,
    required int subjectId,
    required String questionText,
    required List<String> options,
    required int correctOptionIndex,
    String? explanation,
    Map<String, dynamic> accessibility = const {},
  }) => post('/question-bank', {
    ...accessibility,
    'class_id': classId,
    'subject_id': subjectId,
    'question_text': questionText,
    'options': options,
    'correct_option_index': correctOptionIndex,
    'explanation': explanation,
  }, useAuth: true);

  static Future<Map<String, dynamic>?> updateBankQuestion({
    required int questionId,
    required int classId,
    required int subjectId,
    required String questionText,
    required List<String> options,
    required int correctOptionIndex,
    String? explanation,
    Map<String, dynamic> accessibility = const {},
    int? expectedRevision,
  }) => put('/question-bank/$questionId', {
    ...accessibility,
    'expected_revision': expectedRevision,
    'class_id': classId,
    'subject_id': subjectId,
    'question_text': questionText,
    'options': options,
    'correct_option_index': correctOptionIndex,
    'explanation': explanation,
  }, useAuth: true);

  static Future<Map<String, dynamic>?> archiveBankQuestion(int questionId) =>
      post(
        '/question-bank/$questionId/archive?archived=true',
        const {},
        useAuth: true,
      );

  static Future<Map<String, dynamic>?> duplicateBankQuestion(int questionId) =>
      post('/question-bank/$questionId/duplicate', const {}, useAuth: true);

  static Future<List<dynamic>> getTeacherQuizzes({
    int? classId,
    int? subjectId,
  }) async {
    final query = Uri(
      queryParameters: {
        if (classId != null) 'class_id': '$classId',
        if (subjectId != null) 'subject_id': '$subjectId',
      },
    ).query;
    final result = await get('/teacher/quizzes?$query', useAuth: true);
    return result is List ? result : const [];
  }

  static Future<Map<String, dynamic>?> createQuiz(
    Map<String, dynamic> payload,
  ) => post('/teacher/quizzes', payload, useAuth: true);

  static Future<Map<String, dynamic>?> addBankQuestionToQuiz(
    int quizId,
    int questionId,
  ) => post('/teacher/quizzes/$quizId/questions/from-bank', {
    'question_id': questionId,
  }, useAuth: true);

  static Future<Map<String, dynamic>?> publishQuiz(int quizId) =>
      post('/teacher/quizzes/$quizId/publish', const {}, useAuth: true);

  static Future<Map<String, dynamic>?> closeQuiz(int quizId) =>
      post('/teacher/quizzes/$quizId/close', const {}, useAuth: true);

  static Future<Map<String, dynamic>?> duplicateQuiz(int quizId) =>
      post('/teacher/quizzes/$quizId/duplicate', const {}, useAuth: true);

  static Future<Map<String, dynamic>?> getQuizSummary(int quizId) async {
    final result = await get('/teacher/quizzes/$quizId/summary', useAuth: true);
    return result is Map ? Map<String, dynamic>.from(result) : null;
  }

  static Future<List<dynamic>> getTeacherQuizResults(int quizId) async {
    final result = await get('/teacher/quizzes/$quizId/results', useAuth: true);
    return result is List ? result : const [];
  }

  static Future<Map<String, dynamic>?> remindQuizStudents(int quizId) => post(
    '/teacher/quizzes/$quizId/remind-not-attempted',
    const {},
    useAuth: true,
  );

  static Future<List<dynamic>> getStudentQuizzes({
    int? subjectId,
    String? status,
  }) async {
    final query = Uri(
      queryParameters: {
        if (subjectId != null) 'subject_id': '$subjectId',
        if (status != null) 'status': status,
      },
    ).query;
    final result = await get('/student/quizzes?$query', useAuth: true);
    return result is List ? result : const [];
  }

  static Future<Map<String, dynamic>?> startQuizAttempt(int quizId) =>
      post('/student/quizzes/$quizId/attempts', const {}, useAuth: true);

  static Future<Map<String, dynamic>?> getQuizAttempt(int attemptId) async {
    final result = await get('/student/attempts/$attemptId', useAuth: true);
    return result is Map ? Map<String, dynamic>.from(result) : null;
  }

  static Future<ApiResult<Map<String, dynamic>>> submitQuizAnswer({
    required int attemptId,
    required int questionId,
    required int optionId,
  }) => postResult('/student/attempts/$attemptId/answers', {
    'quiz_question_id': questionId,
    'selected_option_id': optionId,
  }, useAuth: true);

  static Future<ApiResult<Map<String, dynamic>>> completeQuizAttempt(
    int attemptId,
  ) => postResult(
    '/student/attempts/$attemptId/complete',
    const {},
    useAuth: true,
  );

  static Future<Map<String, dynamic>?> getQuizAttemptHistory(int quizId) async {
    final result = await get(
      '/student/quizzes/$quizId/attempts',
      useAuth: true,
    );
    return result is Map ? Map<String, dynamic>.from(result) : null;
  }

  static Future<Map<String, dynamic>?> getQuizReview(int attemptId) async {
    final result = await get(
      '/student/attempts/$attemptId/review',
      useAuth: true,
    );
    return result is Map ? Map<String, dynamic>.from(result) : null;
  }

  static Future<List<dynamic>?> getAudioListBySession(int sessionId) async {
    final result = await get('/audio/session/$sessionId', useAuth: true);
    if (result is List) {
      return result;
    }
    return null;
  }

  /// Link an already existing audio file to a session
  static Future<Map<String, dynamic>?> linkAudioToSession(
    int sessionId,
    int audioId,
  ) async {
    return await post(
      '/sessions/$sessionId/audio/$audioId/link',
      {},
      useAuth: true,
    );
  }

  /// Select audio for playback (teacher only)
  static Future<ApiResult<Map<String, dynamic>>> selectAudio(
    int sessionId,
    int audioId, {
    bool Function()? canSend,
  }) => postAcknowledged(
    '/sessions/$sessionId/audio/select?audio_id=$audioId',
    const {},
    context: 'session audio selection',
    canSend: canSend,
  );

  /// Unified audio control endpoint
  static Future<ApiResult<Map<String, dynamic>>> controlAudio(
    int sessionId, {
    required String action, // 'play', 'pause', 'seek'
    int? audioId,
    double speed = 1.0,
    double position = 0.0,
    bool Function()? canSend,
  }) async {
    return postAcknowledged(
      '/sessions/$sessionId/audio/control',
      {
        'audio_id': audioId,
        'speed': speed,
        'position': position,
        'action': action,
      },
      context: 'session audio control',
      canSend: canSend,
    );
  }

  /// Get current audio playback state
  static Future<Map<String, dynamic>?> getAudioPlaybackState(
    int sessionId,
  ) async {
    try {
      final result = await get(
        '/sessions/$sessionId/audio/state',
        useAuth: true,
      );
      return result;
    } catch (e) {
      debugPrint('[API] Playback state error (${e.runtimeType}).');
      return null;
    }
  }

  // Update the existing playAudio method to use the new unified endpoint:
  static Future<ApiResult<Map<String, dynamic>>> playAudio(
    int sessionId, {
    int? audioId,
    double speed = 1.0,
    double position = 0.0,
    bool Function()? canSend,
  }) async {
    return await controlAudio(
      sessionId,
      action: 'play',
      audioId: audioId,
      speed: speed,
      position: position,
      canSend: canSend,
    );
  }

  // Update the existing pauseAudio method:
  static Future<ApiResult<Map<String, dynamic>>> pauseAudio(
    int sessionId, {
    double position = 0.0,
    bool Function()? canSend,
  }) async {
    return await controlAudio(
      sessionId,
      action: 'pause',
      position: position,
      canSend: canSend,
    );
  }

  /// Seek to a specific position in the audio
  static Future<ApiResult<Map<String, dynamic>>> seekAudio(
    int sessionId,
    double position, {
    bool Function()? canSend,
  }) async {
    return await controlAudio(
      sessionId,
      action: 'seek',
      position: position,
      canSend: canSend,
    );
  }

  /////////////////////////// CHAT ENDPOINTS  /////////////////////////

  /// Send chat message to backend and disributed via websocket
  static Future<Map<String, dynamic>?> sendChatMessage(
    int sessionId,
    int participantId,
    String message,
  ) async {
    return await post('/sessions/$sessionId/chat', {
      'participant_id': participantId,
      'message': message,
    }, useAuth: true);
  }

  /// Get chat history
  static Future<List<dynamic>?> getChatHistory(int sessionId) async {
    final result = await get('/sessions/$sessionId/chat', useAuth: true);
    if (result is List) {
      return result;
    } else if (result is Map && result.containsKey('messages')) {
      return result['messages'] as List?;
    }
    return null;
  }
}
