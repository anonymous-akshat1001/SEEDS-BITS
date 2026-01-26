import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../services/tts_service.dart';
import 'session_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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

  // Called once when widget is created
  @override
  void initState() {
    super.initState();
    // start loading the user data immediately
    _loadUserData();
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
    // calls parent dispose class
    super.dispose();
  }


  // UI Build - reruns on every setState
  @override
  Widget build(BuildContext context) {
    // show while spinner is loading
    if (isLoading) {
      return const Scaffold(
        // simple loading screen
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        // Screen Title
        title: const Text("Student Dashboard"),
        backgroundColor: Colors.teal,
        // Right sodde appbar actions
        actions: [
          if (currentUserName != null)
            // show name of current logged in user
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Center(
                child: Text(
                  currentUserName!,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          
          // Refresh Button
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Refresh Sessions",
            onPressed: () {
              TtsService.speak("Refreshing sessions");
              _loadSessions();
            },
          ),
        ],
      ),
      
      
      body: SafeArea(
        // prevents overflow on smaller screens
        child: SingleChildScrollView( 
          child: Padding(
            padding: const EdgeInsets.all(20),
            // Column defines vertical alignment
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // User Info Card
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Welcome, ${currentUserName ?? 'Student'}!",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "User ID: $currentUserId",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Manual join section
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Join Session by ID",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: sessionCtrl,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: "Session ID",
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.meeting_room),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
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
                              icon: const Icon(Icons.login),
                              label: const Text("Join"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Active sessions header
                Row(
                  children: [
                    const Text(
                      "Active Sessions",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(width: 8),
                    if (sessions.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.teal,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${sessions.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Active sessions list - NO EXPANDED, just list items
                if (sessions.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_busy,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "No active sessions available",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: _loadSessions,
                            icon: const Icon(Icons.refresh),
                            label: const Text("Refresh"),
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
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          backgroundColor: Colors.teal,
                          child: Text(
                            '$sessionId',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.person, size: 16),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text('Teacher: $teacherName'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.people, size: 16),
                                const SizedBox(width: 4),
                                Text('$participantCount participants'),
                              ],
                            ),
                          ],
                        ),
                        trailing: ElevatedButton.icon(
                          onPressed: () => joinSession(sessionId),
                          icon: const Icon(Icons.login, size: 18),
                          label: const Text("Join"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  
                const SizedBox(height: 20), // Bottom padding
              ],
            ),
          ),
        ),
      ),
    );
  }
}