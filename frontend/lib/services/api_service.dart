import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Allows reading environment variables
import 'package:flutter_dotenv/flutter_dotenv.dart';

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

    if (statusCode == 422 || statusCode == 400) {
      if (normalizedContext.contains('password') ||
          (normalized.contains('password') &&
              (normalized.contains('6') || normalized.contains('too_short')))) {
        return ApiFailure(
          kind: ApiFailureKind.validation,
          statusCode: statusCode,
          message: 'Password must be at least 6 characters.',
          debugDetails: raw,
        );
      }
      return ApiFailure(
        kind: ApiFailureKind.validation,
        statusCode: statusCode,
        message: 'Please check the information and try again.',
        debugDetails: raw,
      );
    }
    if (statusCode == 401 || statusCode == 403) {
      return ApiFailure(
        kind: ApiFailureKind.unauthorized,
        statusCode: statusCode,
        message: normalizedContext.contains('login')
            ? 'Invalid phone number or password.'
            : 'You do not have permission to do that.',
        debugDetails: raw,
      );
    }
    if (statusCode == 404) {
      return ApiFailure(
        kind: ApiFailureKind.notFound,
        statusCode: statusCode,
        message: normalizedContext.contains('session')
            ? 'Session not found. Check the session ID and try again.'
            : 'The requested item was not found.',
        debugDetails: raw,
      );
    }
    if (statusCode != null && statusCode >= 500) {
      return ApiFailure(
        kind: ApiFailureKind.server,
        statusCode: statusCode,
        message: 'The service is temporarily unavailable. Please try again.',
        debugDetails: raw,
      );
    }
    if (error != null || statusCode == null) {
      return ApiFailure(
        kind: ApiFailureKind.network,
        statusCode: statusCode,
        message:
            'We could not complete that request. Check your connection and try again.',
        debugDetails: raw,
      );
    }
    return ApiFailure(
      kind: ApiFailureKind.unknown,
      statusCode: statusCode,
      message: 'We could not complete that request. Please try again.',
      debugDetails: raw,
    );
  }

  static void _debugFailure(String operation, ApiFailure failure) {
    if (kDebugMode) {
      debugPrint(
        '[API] $operation failed (${failure.statusCode}): ${failure.debugDetails}',
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
  }) async {
    final uri = await _buildUri(path);
    final headers = await _buildHeaders(useAuth: useAuth);
    try {
      final response = await http.get(uri, headers: headers);
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
  }) async {
    final uri = await _buildUri(path);
    final headers = await _buildHeaders(useAuth: useAuth);
    try {
      final response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode(data),
      );
      final body = _decodeBody(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResult<Map<String, dynamic>>.success(
          body is Map<String, dynamic> ? body : <String, dynamic>{'ok': true},
        );
      }
      final failure = mapFailure(
        statusCode: response.statusCode,
        responseBody: body,
        context: context,
      );
      _debugFailure('POST $path', failure);
      return ApiResult<Map<String, dynamic>>.failure(failure);
    } catch (error) {
      final failure = mapFailure(error: error, context: context);
      _debugFailure('POST $path', failure);
      return ApiResult<Map<String, dynamic>>.failure(failure);
    }
  }

  static Future<ApiResult<void>> deleteResult(
    String path, {
    bool useAuth = false,
    String context = '',
    Map<String, dynamic>? data,
  }) async {
    final uri = await _buildUri(path);
    final headers = await _buildHeaders(useAuth: useAuth);
    try {
      final response = await http.delete(
        uri,
        headers: headers,
        body: data == null ? null : jsonEncode(data),
      );
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

  static Future<ApiResult<Map<String, dynamic>>> loginResult({
    required String phoneNumber,
    required String password,
  }) async {
    final uri = await _buildUri('/auth/login');
    try {
      final response = await http.post(
        uri,
        headers: const {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'username': phoneNumber, 'password': password},
      );
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
        print('POST $path failed: ${res.statusCode} ${res.body}');
        try {
          final decoded = jsonDecode(res.body);
          if (decoded is Map<String, dynamic>) {
            return {...decoded, 'status_code': res.statusCode};
          }
        } catch (_) {
          // Fall through to a plain error message below.
        }
        return {
          'detail': res.body.isNotEmpty ? res.body : 'Request failed',
          'status_code': res.statusCode,
        };
      }
    } catch (e) {
      print('POST $path error: $e');
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
        print('GET $path failed: ${res.statusCode} ${res.body}');
        return null;
      }
    } catch (e) {
      print('GET $path error: $e');
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
        print('DELETE $path failed: ${res.statusCode} ${res.body}');
        return false;
      }
    } catch (e) {
      print('DELETE $path error: $e');
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
        print('PUT $path failed: ${res.statusCode} ${res.body}');
        return null;
      }
    } catch (e) {
      print('PUT $path error: $e');
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
      debugPrint('PATCH $path error: $error');
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
        print('UPLOAD $path failed: ${res.statusCode} $body');
        return null;
      }
    } catch (e) {
      print('UPLOAD $path error: $e');
      return null;
    }
  }

  /////////////////////////// AUTHENTICATION ENDPOINTS /////////////////////////

  /// Register a new user
  static Future<Map<String, dynamic>?> register({
    required String name,
    required String phoneNumber,
    required String password,
    required String role,
  }) async {
    return await post('/auth/register', {
      'name': name,
      'phone_number': phoneNumber,
      'password': password,
      'role': role,
    });
  }

  /// Login
  static Future<Map<String, dynamic>?> login({
    required String phoneNumber,
    required String password,
  }) async {
    // Using OAuth2 form format
    final uri = await _buildUri('/auth/login');

    try {
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'username': phoneNumber, 'password': password},
      );

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final data = jsonDecode(res.body);

        // Store token and user info
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['access_token'] ?? '');
        await prefs.setInt('user_id', data['user_id'] ?? 0);
        await prefs.setString('role', data['role'] ?? '');

        return data;
      } else {
        print('LOGIN failed: ${res.statusCode} ${res.body}');
        return null;
      }
    } catch (e) {
      print('LOGIN error: $e');
      return null;
    }
  }

  /////////////////////////// SESSION ENDPOINTS /////////////////////////

  /// Create a new session (teacher only)
  static Future<Map<String, dynamic>?> createSession(
    String title, {
    required int classId,
    required int subjectId,
  }) async {
    return await post('/sessions', {
      'title': title,
      'class_id': classId,
      'subject_id': subjectId,
    }, useAuth: true);
  }

  /// Get all active sessions
  static Future<List<dynamic>?> getActiveSessions() async {
    final result = await get('/sessions/active', useAuth: true);
    if (result is List) {
      return result;
    }
    return null;
  }

  /// Delete/end a session (teacher only)
  static Future<bool> deleteSession(int sessionId) async {
    return await delete('/sessions/$sessionId', useAuth: true);
  }

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
        print('JOIN SESSION failed: ${res.statusCode} $body');
        return null;
      }
    } catch (e) {
      print('JOIN SESSION error: $e');
      return null;
    }
  }

  /// Add a student to a session (teacher only)
  static Future<Map<String, dynamic>?> addStudentToSession(
    int sessionId,
    int studentId,
  ) async {
    final uri = await _buildUri('/sessions/$sessionId/join');
    final prefs = await SharedPreferences.getInstance();

    try {
      var req = http.MultipartRequest("POST", uri);
      req.fields['user_id'] = studentId.toString();

      if (!devMode) {
        final token = prefs.getString('token');
        if (token != null) {
          req.headers['Authorization'] = 'Bearer $token';
        }
      }

      var res = await req.send();
      final body = await res.stream.bytesToString();

      if (res.statusCode >= 200 && res.statusCode < 300) {
        return jsonDecode(body);
      }
      return null;
    } catch (e) {
      print('ADD STUDENT error: $e');
      return null;
    }
  }

  /// Mute/unmute a participant (teacher only)
  static Future<Map<String, dynamic>?> muteParticipant(
    int sessionId,
    int participantId,
    bool mute,
  ) async {
    return await post('/sessions/$sessionId/participants/$participantId/mute', {
      'mute': mute,
    }, useAuth: true);
  }

  /// Remove a participant from session (teacher only)
  static Future<bool> kickParticipant(int sessionId, int participantId) async {
    return await delete(
      '/sessions/$sessionId/participants/$participantId',
      useAuth: true,
    );
  }

  /// Invite student to session (teacher only)
  static Future<Map<String, dynamic>?> inviteStudent(
    int sessionId,
    int studentId,
  ) async {
    final uri = await _buildUri('/sessions/$sessionId/invite');
    final prefs = await SharedPreferences.getInstance();

    try {
      var req = http.MultipartRequest("POST", uri);

      // Add student_id as form field
      req.fields['student_id'] = studentId.toString();

      // Add auth if not in dev mode
      if (!devMode) {
        final token = prefs.getString('token');
        if (token != null && token.isNotEmpty) {
          req.headers['Authorization'] = 'Bearer $token';
        }
      }

      var res = await req.send();
      final body = await res.stream.bytesToString();

      if (res.statusCode >= 200 && res.statusCode < 300) {
        return body.isEmpty ? {'ok': true} : jsonDecode(body);
      } else {
        print('INVITE STUDENT failed: ${res.statusCode} $body');
        return null;
      }
    } catch (e) {
      print('INVITE STUDENT error: $e');
      return null;
    }
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
        print('UPLOAD BYTES $path failed: ${res.statusCode} $body');
        return null;
      }
    } catch (e) {
      print('UPLOAD BYTES $path error: $e');
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
    bool unassignedOnly = false,
  }) async {
    final query = Uri(
      queryParameters: {
        if (search.isNotEmpty) 'search': search,
        'unassigned_only': unassignedOnly.toString(),
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
  static Future<Map<String, dynamic>?> selectAudio(
    int sessionId,
    int audioId,
  ) => post(
    '/sessions/$sessionId/audio/select?audio_id=$audioId',
    const {},
    useAuth: true,
  );

  /// Unified audio control endpoint
  static Future<Map<String, dynamic>?> controlAudio(
    int sessionId, {
    required String action, // 'play', 'pause', 'seek'
    int? audioId,
    double speed = 1.0,
    double position = 0.0,
  }) async {
    try {
      final result = await post('/sessions/$sessionId/audio/control', {
        'audio_id': audioId,
        'speed': speed,
        'position': position,
        'action': action,
      }, useAuth: true);
      return result;
    } catch (e) {
      print('[API] Error controlling audio: $e');
      return null;
    }
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
      print('[API] Error getting playback state: $e');
      return null;
    }
  }

  // Update the existing playAudio method to use the new unified endpoint:
  static Future<Map<String, dynamic>?> playAudio(
    int sessionId, {
    int? audioId,
    double speed = 1.0,
    double position = 0.0,
  }) async {
    return await controlAudio(
      sessionId,
      action: 'play',
      audioId: audioId,
      speed: speed,
      position: position,
    );
  }

  // Update the existing pauseAudio method:
  static Future<Map<String, dynamic>?> pauseAudio(
    int sessionId, {
    double position = 0.0,
  }) async {
    return await controlAudio(sessionId, action: 'pause', position: position);
  }

  /// Seek to a specific position in the audio
  static Future<Map<String, dynamic>?> seekAudio(
    int sessionId,
    double position,
  ) async {
    return await controlAudio(sessionId, action: 'seek', position: position);
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
