import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
// Allows reading environment variables
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Backend and websocket URL
final baseUrl = dotenv.env['API_BASE_URL'];
final wsBaseUrl = dotenv.env['WS_BASE_URL'];


// A static service class
class ApiService {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://127.0.0.1:8000';
  static const bool devMode = true; // Set to false for JWT mode

  static String? cachedToken;   // set this right after reading from prefs

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
  static Future<Map<String, String>> _buildHeaders({bool useAuth = false}) async {
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
    return await _buildHeaders();
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
      final res = await http.post(uri, headers: headers, body: jsonEncode(data));

      if (res.statusCode >= 200 && res.statusCode < 300) {
        if (res.body.isEmpty){
          return {'ok': true};
        }
        // Converts response JSON → Dart map
        return jsonDecode(res.body);
      } 
      else {
        print('POST $path failed: ${res.statusCode} ${res.body}');
        return null;
      }
    } 
    catch (e) {
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
      } 
      else {
        print('GET $path failed: ${res.statusCode} ${res.body}');
        return null;
      }
    } 
    catch (e) {
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
      } 
      else {
        print('PUT $path failed: ${res.statusCode} ${res.body}');
        return null;
      }
    } 
    catch (e) {
      print('PUT $path error: $e');
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
      } 
      else {
        print('UPLOAD $path failed: ${res.statusCode} $body');
        return null;
      }
    } 
    catch (e) {
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
        body: {
          'username': phoneNumber,
          'password': password,
        },
      );

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final data = jsonDecode(res.body);
        
        // Store token and user info
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['access_token'] ?? '');
        await prefs.setInt('user_id', data['user_id'] ?? 0);
        await prefs.setString('role', data['role'] ?? '');
        
        return data;
      } 
      else {
        print('LOGIN failed: ${res.statusCode} ${res.body}');
        return null;
      }
    } 
    catch (e) {
      print('LOGIN error: $e');
      return null;
    }
  }



  /////////////////////////// SESSION ENDPOINTS /////////////////////////



  /// Create a new session (teacher only)
  static Future<Map<String, dynamic>?> createSession(String title) async {
    return await post('/sessions', {'title': title}, useAuth: true);
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
  static Future<Map<String, dynamic>?> joinSession(int sessionId, {int? userId}) async {
    final uri = await _buildUri('/sessions/$sessionId/join');
    final prefs = await SharedPreferences.getInstance();
    
    try {
      var req = http.MultipartRequest("POST", uri);
      
      if (userId != null) {
        req.fields['user_id'] = userId.toString();
      }
      
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
      } 
      else {
        print('JOIN SESSION failed: ${res.statusCode} $body');
        return null;
      }
    } 
    catch (e) {
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
    } 
    catch (e) {
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
    return await delete('/sessions/$sessionId/participants/$participantId', useAuth: true);
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
  


  /////////////////////////// AUDIO ENDPOINTS /////////////////////////


  /// Upload audio file (teacher only)
  static Future<Map<String, dynamic>?> uploadAudio({
    required String filePath,
    required String title,
    String description = '',
  }) async {
    return await uploadFile(
      '/audio/upload',
      filePath,
      useAuth: true,
      additionalFields: {
        'title': title,
        'description': description,
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

  /// Select audio for playback (teacher only)
  static Future<Map<String, dynamic>?> selectAudio(
    int sessionId,
    int audioId,
  ) async {
    // Build base path first
    String path = '/sessions/$sessionId/audio/select';
    
    // Manually construct the full URI with query params
    String fullUri = '$baseUrl$path';
    
    // Add user_id if in dev mode
    if (devMode) {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');
      if (userId != null) {
        fullUri += '?user_id=$userId';
        fullUri += '&audio_id=$audioId';  // Add audio_id after user_id
      } 
      else {
        fullUri += '?audio_id=$audioId';
      }
    } 
    else {
      fullUri += '?audio_id=$audioId';
    }
    
    final uri = Uri.parse(fullUri);
    final headers = await _buildHeaders(useAuth: true);

    try {
      final res = await http.post(uri, headers: headers);
      
      if (res.statusCode >= 200 && res.statusCode < 300) {
        if (res.body.isEmpty) return {'ok': true};
        return jsonDecode(res.body);
      } 
      else {
        print('SELECT AUDIO failed: ${res.statusCode} ${res.body}');
        return null;
      }
    } 
    catch (e) {
      print('SELECT AUDIO error: $e');
      return null;
    }
  }


  /// Unified audio control endpoint
  static Future<Map<String, dynamic>?> controlAudio(
    int sessionId, {
    required String action, // 'play', 'pause', 'seek'
    int? audioId,
    double speed = 1.0,
    double position = 0.0,
  }) async {
    try {
      final result = await post(
        '/sessions/$sessionId/audio/control',
        {
          'audio_id': audioId,
          'speed': speed,
          'position': position,
          'action': action,
        },
        useAuth: true,
      );
      return result;
    } catch (e) {
      print('[API] Error controlling audio: $e');
      return null;
    }
  }

  /// Get current audio playback state
  static Future<Map<String, dynamic>?> getAudioPlaybackState(int sessionId) async {
    try {
      final result = await get('/sessions/$sessionId/audio/state', useAuth: true);
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
    return await controlAudio(
      sessionId,
      action: 'pause',
      position: position,
    );
  }

  /// Seek to a specific position in the audio
  static Future<Map<String, dynamic>?> seekAudio(
    int sessionId,
    double position,
  ) async {
    return await controlAudio(
      sessionId,
      action: 'seek',
      position: position,
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