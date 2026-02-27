import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
// import 'package:http/http.dart' as http;
import '../services/api_service.dart';
import '../utils/ui_utils.dart';
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
    final bool tiny = UIUtils.isTiny(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Invite Students', style: TextStyle(fontSize: UIUtils.fontSize(context, 16), fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        foregroundColor: UIUtils.textColor,
        elevation: 0,
        toolbarHeight: tiny ? 40 : null,
        actions: [
          IconButton(
            icon: Icon(_ttsEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded, size: UIUtils.iconSize(context, 20), color: UIUtils.accentColor),
            tooltip: 'Toggle TTS',
            onPressed: () {
              setState(() => _ttsEnabled = !_ttsEnabled);
            },
          ),
        ],
      ),
      backgroundColor: UIUtils.backgroundColor,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Session info
                Container(
                  width: double.infinity,
                  padding: UIUtils.paddingAll(context, 12),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Inviting students to:',
                        style: TextStyle(
                          fontSize: UIUtils.fontSize(context, 11),
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: UIUtils.spacing(context, 2)),
                      Text(
                        widget.sessionTitle,
                        style: TextStyle(
                          fontSize: UIUtils.fontSize(context, 16),
                          fontWeight: FontWeight.w700,
                          color: UIUtils.textColor,
                        ),
                      ),
                      SizedBox(height: UIUtils.spacing(context, 4)),
                      Text(
                        '${_invitedStudents.length} of ${_students.length} invited',
                        style: TextStyle(
                          fontSize: UIUtils.fontSize(context, 11),
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                
                // Invite all button
                Padding(
                  padding: UIUtils.paddingAll(context, 10),
                    child: ElevatedButton.icon(
                      onPressed: _students.length == _invitedStudents.length
                          ? null
                          : _inviteAll,
                      icon: Icon(Icons.send_rounded, size: UIUtils.iconSize(context, 18)),
                      label: Text('Invite All Students', style: TextStyle(fontSize: UIUtils.fontSize(context, 14), fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: UIUtils.primaryColor,
                        foregroundColor: Colors.white,
                        padding: UIUtils.paddingSymmetric(context, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                    ),
                ),
                const Divider(),
                
                // Student list
                Expanded(
                  child: _students.isEmpty
                      ? Center(
                          child: Text(
                            'No students found',
                            style: TextStyle(color: Colors.grey, fontSize: UIUtils.fontSize(context, 13)),
                          ),
                        )
                      : ListView.builder(
                          padding: UIUtils.paddingAll(context, 8),
                          itemCount: _students.length,
                          itemBuilder: (context, index) {
                            final student = _students[index];
                            final studentId = student['user_id'] as int;
                            final name = student['name'] as String;
                            final phone = student['phone_number'] as String;
                            final isInvited = _invitedStudents.contains(studentId);

                            return Card(
                              margin: EdgeInsets.only(bottom: UIUtils.spacing(context, 8), left: 12, right: 12),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: Colors.grey.withOpacity(0.1)),
                              ),
                              color: isInvited ? Colors.green.withOpacity(0.05) : Colors.white,
                              child: ListTile(
                                dense: tiny,
                                contentPadding: UIUtils.paddingSymmetric(context, horizontal: 8, vertical: 2),
                                leading: CircleAvatar(
                                  backgroundColor: isInvited ? Colors.green : UIUtils.backgroundColor,
                                  radius: UIUtils.iconSize(context, 18),
                                  child: Icon(
                                    isInvited ? Icons.check_rounded : Icons.person_outline_rounded,
                                    color: isInvited ? Colors.white : UIUtils.primaryColor,
                                    size: UIUtils.iconSize(context, 18),
                                  ),
                                ),
                                title: Text(
                                  name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: UIUtils.fontSize(context, 14),
                                    color: isInvited ? Colors.green.shade700 : UIUtils.textColor,
                                  ),
                                ),
                                subtitle: Text(
                                  phone,
                                  style: TextStyle(
                                    color: isInvited ? Colors.green.shade600 : Colors.grey,
                                    fontSize: UIUtils.fontSize(context, 11),
                                  ),
                                ),
                                trailing: isInvited
                                    ? Container(
                                        padding: UIUtils.paddingSymmetric(context, horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          'INVITED',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: UIUtils.fontSize(context, 9),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      )
                                    : ElevatedButton.icon(
                                        onPressed: () => _inviteStudent(studentId, name),
                                        icon: Icon(Icons.send_rounded, size: UIUtils.iconSize(context, 14)),
                                        label: Text('Invite', style: TextStyle(fontSize: UIUtils.fontSize(context, 12))),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: UIUtils.accentColor,
                                          foregroundColor: Colors.white,
                                          padding: UIUtils.paddingSymmetric(context, horizontal: 10, vertical: 4),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          elevation: 0,
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