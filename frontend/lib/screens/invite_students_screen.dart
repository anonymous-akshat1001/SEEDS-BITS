import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
// import 'package:http/http.dart' as http;
import '../services/api_service.dart';
// Allows reading environment variables
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Backend and websocket URL
final baseUrl = dotenv.env['API_BASE_URL'];
final wsBaseUrl = dotenv.env['WS_BASE_URL'];


// This screen changes over time hence it must be Stateful
class InviteStudentsScreen extends StatefulWidget {
  // Required inputs
  final int sessionId;
  final String sessionTitle;

  // Constructor
  const InviteStudentsScreen({
    super.key,
    // required means screen cannot be created without these values
    required this.sessionId,
    required this.sessionTitle,
  });

  @override
  State<InviteStudentsScreen> createState() => _InviteStudentsScreenState();
}

// State class
class _InviteStudentsScreenState extends State<InviteStudentsScreen> {
  // instance of TTS engine
  final FlutterTts _tts = FlutterTts();
  
  // Stores student list from backend
  List<Map<String, dynamic>> _students = [];
  // Stores IDs of already-invited students
  Set<int> _invitedStudents = {};
  bool _isLoading = true;
  bool _ttsEnabled = true;

  // Called once when screen appears
  @override
  void initState() {
    super.initState();
    // list of students immediately loaded
    _loadStudents();
  }

  // Loading students from backend
  Future<void> _loadStudents() async {
    // triggers UI rebuild
    setState(() => _isLoading = true);
    
    try {
      // calls backend and returns list of students
      final result = await ApiService.get('/users/students', useAuth: true);
      
      if (result != null) {
        setState(() {
          if (result is List) {
            // Converts dynamic list → strongly typed list
            _students = result.cast<Map<String, dynamic>>();
          }
        });
        
        await _speakIfEnabled("Loaded ${_students.length} students");
      }
    } 
    catch (e) {
      print('[INVITE] Error loading students: $e');
      _showError("Failed to load students");
    } 
    finally {
      setState(() => _isLoading = false);
    }
  }

  // Function to invite students to a session - only by teacher
  Future<void> _inviteStudent(int studentId, String studentName) async {
    try {
      // Use ApiService for consistency - backend call
      final result = await ApiService.inviteStudent(widget.sessionId, studentId);

      if (result != null && result['ok'] == true) {
        // Marks student as invited and UI is updated
        setState(() => _invitedStudents.add(studentId));
        await _speakIfEnabled("Invited $studentName");
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Invited $studentName to join session'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        _showError("Failed to invite $studentName");
      }
    } catch (e) {
      print('[INVITE] Error: $e');
      _showError("Failed to invite $studentName");
    }
  }


  // Invites all the students one by one
  Future<void> _inviteAll() async {
    for (var student in _students) {
      final studentId = student['user_id'] as int;
      // Avoids re-inviting same student
      if (!_invitedStudents.contains(studentId)) {
        await _inviteStudent(studentId, student['name']);
        // Small delay to prevent UI freeze, backend overload and keep speech understandable
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }
    
    await _speakIfEnabled("Invited all students");
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _speakIfEnabled(String text) async {
    if (_ttsEnabled) {
      try {
        await _tts.speak(text);
      } catch (e) {
        print('[TTS] Error: $e');
      }
    }
  }

  // Cleanup
  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }


  // UI Build
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invite Students'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: Icon(_ttsEnabled ? Icons.volume_up : Icons.volume_off),
            tooltip: 'Toggle TTS',
            onPressed: () {
              setState(() => _ttsEnabled = !_ttsEnabled);
            },
          ),
        ],
      ),
      body: _isLoading                  // Shows loader or contents
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Session info
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: Colors.teal.shade50,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Inviting students to:',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.sessionTitle,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_invitedStudents.length} of ${_students.length} invited',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Invite all button
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _students.length == _invitedStudents.length
                          ? null
                          : _inviteAll,
                      icon: const Icon(Icons.send),
                      label: const Text('Invite All Students'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                  ),
                ),
                
                const Divider(),
                
                // Student list
                Expanded(
                  child: _students.isEmpty
                      ? const Center(
                          child: Text(
                            'No students found',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _students.length,
                          itemBuilder: (context, index) {
                            final student = _students[index];
                            final studentId = student['user_id'] as int;
                            final name = student['name'] as String;
                            final phone = student['phone_number'] as String;
                            final isInvited = _invitedStudents.contains(studentId);

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: isInvited ? 1 : 2,
                              color: isInvited ? Colors.green.shade50 : null,
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: isInvited ? Colors.green : Colors.teal,
                                  child: Icon(
                                    isInvited ? Icons.check : Icons.person,
                                    color: Colors.white,
                                  ),
                                ),
                                title: Text(
                                  name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isInvited ? Colors.green.shade700 : null,
                                  ),
                                ),
                                subtitle: Text(
                                  phone,
                                  style: TextStyle(
                                    color: isInvited ? Colors.green.shade600 : Colors.grey,
                                  ),
                                ),
                                trailing: isInvited
                                    ? Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Text(
                                          'INVITED',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      )
                                    : ElevatedButton.icon(
                                        onPressed: () => _inviteStudent(studentId, name),
                                        icon: const Icon(Icons.send, size: 18),
                                        label: const Text('Invite'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.teal,
                                        ),
                                      ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}