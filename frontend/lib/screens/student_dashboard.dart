import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../services/tts_service.dart';
import 'session_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/services.dart';
import '../utils/ui_utils.dart';
import '../widgets/key_instruction_wrapper.dart';


// Backend URL
final baseUrl = dotenv.env['API_BASE_URL'];

// Define the Student Dashboard as a Stateful Widget
class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  // Connect UI to its State
  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

// Define the state class where logic resides
class _StudentDashboardState extends State<StudentDashboard> {
  // input/control the session id variable
  final sessionCtrl = TextEditingController();
  // Stores list of active sessions from backend
  List sessions = [];
  // Stores logged-in user’s ID, the ? means that it can be NULL
  int? currentUserId;
  // Stores the logged in users name
  String? currentUserName;
  bool isLoading = true;
  final FocusNode _screenFocusNode = FocusNode();
  final FocusNode _inputFocusNode = FocusNode();


  // Called once when widget is created
  @override
  void initState() {
    super.initState();
    // start loading the user data immediately
    _loadUserData();
    _screenFocusNode.requestFocus();
  }

  // Function to load the user data 
  Future<void> _loadUserData() async {
    // open local storage and read login data
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('user_id');
    // ?? means “if null, try next”
    final name = prefs.getString('user_name') 
    ?? prefs.getString('name') 
    ?? 'Student $id';
    
    // saves data into state and rebuild UI
    setState(() {
      currentUserId = id;
      currentUserName = name;
    });

    // Load session only if user exists
    if (currentUserId != null){
      await _loadSessions();
    }

    // data loading finished and the loading spinner is removed
    setState(() => isLoading = false);
  }

  // Fetch active sessions from backend
  Future<void> _loadSessions() async {
    final res = await ApiService.get('/sessions/active', useAuth: true);
    if (res != null && res is List) {
      setState(() => sessions = res);
    }
  }

  // Join a session using form data
  Future<void> joinSession(int sessionId) async {
    if (currentUserId == null) {
      TtsService.speak("User not logged in");
      // Visual feedback, appears at bottom
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please log in first")),
      );
      return;
    }

    if (currentUserName == null) {
      TtsService.speak("User name not found");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User name not found. Please log in again.")),
      );
      return;
    }

    // Show loading indicator
    showDialog(
      context: context,
      // user cannot close dialog box by accident
      barrierDismissible: false,
      // create a spinner which shows request in progress
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Read the auth token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      // Construct URL
      final uri = Uri.parse(ApiService.devMode
          ? '$baseUrl/sessions/$sessionId/join?user_id=$currentUserId'
          : '$baseUrl/sessions/$sessionId/join');

      // Send POST request
      final res = await http.post(
        uri,
        // backend expects form type data
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          // Adds auth header in production
          if (!ApiService.devMode && token != null)
            'Authorization': 'Bearer $token',
        },
        // Must be a string for Form(...)
        body: {
          'user_id': currentUserId.toString(), 
        },
      );

      // Close loading dialog
      if (mounted){
        Navigator.pop(context);
      }

      if (res.statusCode >= 200 && res.statusCode < 300) {
        TtsService.speak("Joined session $sessionId");

        // Navigate to Session Screen once the session has been joined
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SessionScreen(
                sessionId: sessionId,
                userId: currentUserId!,
                userName: currentUserName!,
                isTeacher: false,
              ),
            ),
          ).then((_) {
            // Refresh sessions when returning
            _loadSessions();
          });
        }
      } else {
        TtsService.speak("Failed to join session");
        debugPrint("Join failed: ${res.statusCode} -> ${res.body}");
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to join session: ${res.statusCode}")),
          );
        }
      }
    } catch (e) {
      // Close loading dialog if still open
      if (mounted) Navigator.pop(context);
      
      TtsService.speak("Error joining session");
      debugPrint("Join session error: $e");
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString()}")),
        );
      }
    }
  }

  // Called when the screen is destroyed
  @override
  void dispose() {
    // Frees memory - crictical for low RAM devices like button phones
    sessionCtrl.dispose();
    _screenFocusNode.dispose();
    _inputFocusNode.dispose();
    // calls parent dispose class
    super.dispose();
  }


  // UI Build - reruns on every setState
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return KeypadInstructionWrapper(
      audioAsset: 'audio/student_dashboard_instructions.mp3',
      ttsInstructions: "Student Dashboard. Press 1 to refresh sessions, 2 to join a session by ID.",
      actions: {
        LogicalKeyboardKey.digit1: _loadSessions,
        LogicalKeyboardKey.digit2: () => _inputFocusNode.requestFocus(),
      },
      child: _buildScaffold(context),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    final bool tiny = UIUtils.isTiny(context);

    return Scaffold(
      appBar: AppBar(
        // Screen Title
        title: Text("Student Dashboard", style: TextStyle(fontSize: UIUtils.fontSize(context, 18), fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        foregroundColor: UIUtils.textColor,
        elevation: 0,
        toolbarHeight: tiny ? 40 : null,
        // Right side appbar actions
        actions: [
          if (currentUserName != null && !tiny)
            // show name of current logged in user
            Padding(
              padding: UIUtils.paddingSymmetric(context, horizontal: 8, vertical: 8),
              child: Center(
                child: Text(
                  currentUserName!,
                  style: TextStyle(fontSize: UIUtils.fontSize(context, 14), fontWeight: FontWeight.w500),
                ),
              ),
            ),
          
          // Refresh Button
          IconButton(
            icon: Icon(Icons.refresh_rounded, size: UIUtils.iconSize(context, 22), color: UIUtils.accentColor),
            tooltip: "Refresh Sessions",
            onPressed: () {
              TtsService.speak("Refreshing sessions");
              _loadSessions();
            },
          ),
          if (UIUtils.isKeypad(context))
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: Center(
                child: Text("1", style: TextStyle(color: UIUtils.accentColor, fontSize: UIUtils.fontSize(context, 14), fontWeight: FontWeight.bold)),
              ),
            ),
        ],
      ),
      
      
      body: SafeArea(
        // prevents overflow on smaller screens
        child: SingleChildScrollView( 
          child: Padding(
            padding: UIUtils.paddingAll(context, 12),
            // Column defines vertical alignment
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // User Info Card
                Card(
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.withOpacity(0.1)),
                  ),
                  child: Padding(
                    padding: UIUtils.paddingAll(context, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Welcome, ${currentUserName ?? 'Student'}!",
                          style: TextStyle(
                            fontSize: UIUtils.fontSize(context, 16),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: UIUtils.spacing(context, 4)),
                        Text(
                          "User ID: $currentUserId",
                          style: TextStyle(
                            fontSize: UIUtils.fontSize(context, 12),
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: UIUtils.spacing(context, 12)),
                
                // Manual join section
                Card(
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.withOpacity(0.1)),
                  ),
                  child: Padding(
                    padding: UIUtils.paddingAll(context, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Join Session by ID",
                          style: TextStyle(
                            fontSize: UIUtils.fontSize(context, 14),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: UIUtils.spacing(context, 8)),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: sessionCtrl,
                                focusNode: _inputFocusNode,
                                keyboardType: TextInputType.number,
                                style: TextStyle(fontSize: UIUtils.fontSize(context, 14)),
                                decoration: InputDecoration(
                                  labelText: "2. Session ID",
                                  labelStyle: TextStyle(fontSize: UIUtils.fontSize(context, 12), color: UIUtils.subtextColor),
                                  filled: true,
                                  fillColor: UIUtils.backgroundColor,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none,
                                  ),
                                  prefixIcon: Icon(Icons.meeting_room_rounded, size: UIUtils.iconSize(context, 18), color: UIUtils.accentColor),
                                  contentPadding: UIUtils.paddingSymmetric(context, horizontal: 12, vertical: 12),
                                  isDense: true,
                                ),
                              ),
                            ),
                            SizedBox(width: UIUtils.spacing(context, 8)),
                            ElevatedButton.icon(
                              onPressed: () {
                                final idText = sessionCtrl.text.trim();
                                if (idText.isEmpty) {
                                  TtsService.speak("Please enter a session ID");
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Please enter a session ID"),
                                    ),
                                  );
                                  return;
                                }
                                
                                final sessionId = int.tryParse(idText);
                                if (sessionId == null) {
                                  TtsService.speak("Invalid session ID");
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Please enter a valid number"),
                                    ),
                                  );
                                  return;
                                }
                                
                                joinSession(sessionId);
                              },
                              icon: Icon(Icons.login, size: UIUtils.iconSize(context, 16)),
                              label: Text("Join", style: TextStyle(fontSize: UIUtils.fontSize(context, 13))),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: UIUtils.primaryColor,
                                foregroundColor: Colors.white,
                                padding: UIUtils.paddingSymmetric(context, horizontal: 16, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 0,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: UIUtils.spacing(context, 12)),
                
                // Active sessions header
                Row(
                  children: [
                    Text(
                      "Active Sessions",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: UIUtils.fontSize(context, 16)),
                    ),
                    SizedBox(width: UIUtils.spacing(context, 6)),
                    if (sessions.isNotEmpty)
                      Container(
                        padding: UIUtils.paddingSymmetric(context, horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: UIUtils.accentColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${sessions.length}',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: UIUtils.fontSize(context, 12),
                          ),
                        ),
                      ),
                  ],
                ),
                
                SizedBox(height: UIUtils.spacing(context, 8)),
                
                // Active sessions list
                if (sessions.isEmpty)
                  Center(
                    child: Padding(
                      padding: UIUtils.paddingAll(context, 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_busy,
                            size: UIUtils.iconSize(context, 48),
                            color: Colors.grey.shade400,
                          ),
                          SizedBox(height: UIUtils.spacing(context, 10)),
                          Text(
                            "No active sessions",
                            style: TextStyle(
                              fontSize: UIUtils.fontSize(context, 14),
                              color: Colors.grey.shade600,
                            ),
                          ),
                          SizedBox(height: UIUtils.spacing(context, 6)),
                          TextButton.icon(
                            onPressed: _loadSessions,
                            icon: Icon(Icons.refresh, size: UIUtils.iconSize(context, 16)),
                            label: Text("Refresh", style: TextStyle(fontSize: UIUtils.fontSize(context, 13))),
                          ),
                        ],
                      ),
                    ),
                  )
                
                else

                  // Converts list → widgets using ... operator
                  ...sessions.map((s) {
                    final sessionId = s['session_id'] ?? 0;
                    final title = s['title'] ?? 'Untitled Session';
                    final teacherName = s['teacher_name'] ?? 'Unknown';
                    final participantCount = s['participant_count'] ?? 0;
                    
                    return Card(
                      margin: EdgeInsets.only(bottom: UIUtils.spacing(context, 8)),
                      elevation: 2,
                      child: InkWell(
                        onTap: () => joinSession(sessionId),
                        focusColor: Colors.teal.withOpacity(0.1),
                        child: ListTile(
                        dense: tiny,
                        contentPadding: UIUtils.paddingAll(context, 10),
                        leading: CircleAvatar(
                          radius: UIUtils.iconSize(context, 18),
                          backgroundColor: UIUtils.backgroundColor,
                          child: Text(
                            '$sessionId',
                            style: TextStyle(
                              color: UIUtils.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: UIUtils.fontSize(context, 12),
                            ),
                          ),
                        ),
                        title: Text(
                          title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: UIUtils.fontSize(context, 14),
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: UIUtils.spacing(context, 4)),
                            Row(
                              children: [
                                Icon(Icons.person, size: UIUtils.iconSize(context, 14)),
                                SizedBox(width: UIUtils.spacing(context, 3)),
                                Expanded(
                                  child: Text('Teacher: $teacherName',
                                      style: TextStyle(fontSize: UIUtils.fontSize(context, 11))),
                                ),
                              ],
                            ),
                            SizedBox(height: UIUtils.spacing(context, 2)),
                            Row(
                              children: [
                                Icon(Icons.people, size: UIUtils.iconSize(context, 14)),
                                SizedBox(width: UIUtils.spacing(context, 3)),
                                Text('$participantCount participants',
                                    style: TextStyle(fontSize: UIUtils.fontSize(context, 11))),
                              ],
                            ),
                          ],
                        ),
                        trailing: ElevatedButton(
                          onPressed: () => joinSession(sessionId),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: UIUtils.primaryColor,
                            foregroundColor: Colors.white,
                            padding: UIUtils.paddingSymmetric(context, horizontal: 12, vertical: 8),
                            minimumSize: Size.zero,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            elevation: 0,
                          ),
                          child: Text("Join", style: TextStyle(fontSize: UIUtils.fontSize(context, 12))),
                        ),
                      ),
                    ),
                  );
                  }).toList(),
                  
                SizedBox(height: UIUtils.spacing(context, 12)), // Bottom padding
              ],
            ),
          ),
        ),
      ),
    );
  }
}