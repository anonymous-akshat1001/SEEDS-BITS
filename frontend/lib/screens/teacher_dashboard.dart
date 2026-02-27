import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../services/tts_service.dart';
import 'package:flutter/services.dart';
import 'session_screen.dart';
import '../utils/ui_utils.dart';
import '../widgets/key_instruction_wrapper.dart';

// Create Teacher Dashboard Widget
class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  // Connect widget to logic
  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

// Defining the state class
class _TeacherDashboardState extends State<TeacherDashboard> {
  // Stores list of sessions created by teacher
  List sessions = [];
  // Stores teacher’s ID, ? means it can be NULL
  int? currentUserId;
  // Stores teacher's name
  String? currentUserName;
  // Controls loading spinner
  bool isLoading = true;
  // Controls text typed into session title field
  final TextEditingController _titleController = TextEditingController();
  final FocusNode _screenFocusNode = FocusNode();

  // Called once when widget is created - ideal for API calls and reading local variables
  @override
  void initState() {
    super.initState();
    // Starts loading user data immediately
    _loadUserData();
    _screenFocusNode.requestFocus();
  }

  // Load user data( non blocking )
  Future<void> _loadUserData() async {
    // opens local storage
    final prefs = await SharedPreferences.getInstance();
    // get user id
    final id = prefs.getInt('user_id');
    // fetch user name
    final name = prefs.getString('user_name') 
    ?? prefs.getString('name') 
    ?? 'Teacher $id';
    
    // saves value into state and forces UI rebuild
    setState(() {
      currentUserId = id;
      currentUserName = name;
    });

    // load session only if user exists
    if (currentUserId != null) {
      await _loadSessions();
    }

    // data loading complete
    setState(() {
      // spinner removed
      isLoading = false;
    });

  }

  // Fetch all active sessions for this teacher
  Future<void> _loadSessions() async {
    final res = await ApiService.get(
      '/sessions/active',
      useAuth: true,
    );

    if (res != null && res is List) {
      // Filter sessions created by this teacher
      final teacherSessions = res.where(
        (s) => s['created_by'] == currentUserId
      ).toList();

      // saves filtered sessions and updates UI
      setState(() {
        sessions = teacherSessions;
      });

    }
  }

  // Funtion to create a new session by the teacher
  Future<void> createSession() async {
    // If user not logged in
    if (currentUserId == null || currentUserName == null) {
      TtsService.speak("User not logged in");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please log in first")),
      );
      // stop execution
      return;
    }

    // Show dialog to input session title, waits for input and returns a String
    final title = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Session'),
        content: TextField(
          controller: _titleController,         // input for session title
          decoration: const InputDecoration(
            labelText: 'Session Title',
            hintText: 'e.g., English Class - Unit 5',
            border: OutlineInputBorder(),
          ),
          autofocus: true,                     // keyboard opens automatically
        ),

        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),

          ElevatedButton(
            onPressed: () {
              final text = _titleController.text.trim();
              Navigator.pop(context, text.isEmpty ? 'New Session' : text);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (title == null){
      return; // User cancelled
    }

    // Show loading
    showDialog(
      context: context,
      // blocks any other interaction and prevents accidental close
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // send session creation request to backend
    final res = await ApiService.post(
      '/sessions',
      {'title': title},
      useAuth: true,
    );

    // Close loading dialog
    if (mounted){
      Navigator.pop(context);
    }

    // Success case
    if (res != null && res['session_id'] != null) {
      // adds new session to the list
      setState(() => sessions.add(res));
      TtsService.speak("Session $title created successfully");
      
      // clears input for session title
      _titleController.clear();
      
      // Ask if they want to start the session now
      if (mounted) {
        final startNow = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Session Created'),
            content: Text('Do you want to start "$title" now?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Later'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Start Now'),
              ),
            ],
          ),
        );

        if (startNow == true) {
          _openSession(res['session_id']);
        }
      }
    } 
    else {
      TtsService.speak("Failed to create session");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to create session")),
        );
      }
    }
  }


  void _openSession(int sessionId) {
    if (currentUserId == null || currentUserName == null) {
      TtsService.speak("User not logged in");
      return;
    }

    TtsService.speak("Opening session");

    // opens new screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SessionScreen(
          sessionId: sessionId,
          userId: currentUserId!,            // the ! claims that these fields are not null
          userName: currentUserName!,
          isTeacher: true,
        ),
      ),
    ).then((_) {
      // Refresh sessions when returning
      _loadSessions();
    });
  }

  // Function to delete the session created previously
  Future<void> _deleteSession(int sessionId, String title) async {
    // confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Session'),
        content: Text('Are you sure you want to delete "$title"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    // cancel deletion
    if (confirmed != true){
      return;
    }

    // sends deletion request to backend
    final success = await ApiService.delete('/sessions/$sessionId');
    
    if (success) {
      setState(() {
        sessions.removeWhere((s) => s['session_id'] == sessionId);
      });
      TtsService.speak("Session deleted");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Session deleted successfully")),
        );
      }
    } 
    else {
      TtsService.speak("Failed to delete session");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to delete session")),
        );
      }
    }
  }

  // Frees memory
  @override
  void dispose() {
    _titleController.dispose();
    _screenFocusNode.dispose();
    super.dispose();
  }

  // Build UI
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return KeypadInstructionWrapper(
      audioAsset: 'audio/teacher_dashboard_instructions.mp3',
      ttsInstructions: "Teacher Dashboard. Press 1 to refresh sessions, 2 to create a new session.",
      actions: {
        LogicalKeyboardKey.digit1: _loadSessions,
        LogicalKeyboardKey.digit2: createSession,
      },
      child: _buildScaffold(context),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    final bool tiny = UIUtils.isTiny(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Teacher Dashboard", style: TextStyle(fontSize: UIUtils.fontSize(context, 18), fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        foregroundColor: UIUtils.textColor,
        toolbarHeight: tiny ? 40 : null,
        actions: [
          if (currentUserName != null && !tiny)
            Padding(
              padding: UIUtils.paddingSymmetric(context, horizontal: 8, vertical: 8),
              child: Center(
                child: Row(
                  children: [
                    Icon(Icons.person, size: UIUtils.iconSize(context, 16)),
                    SizedBox(width: UIUtils.spacing(context, 4)),
                    Text(
                      currentUserName!,
                      style: TextStyle(fontSize: UIUtils.fontSize(context, 14), fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),


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
        child: SingleChildScrollView(  
          child: Padding(
            padding: UIUtils.paddingAll(context, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Welcome Card
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
                          "Welcome, ${currentUserName ?? 'Teacher'}!",
                          style: TextStyle(
                            fontSize: UIUtils.fontSize(context, 20),
                            fontWeight: FontWeight.w700,
                            color: UIUtils.textColor,
                          ),
                        ),
                        if (!tiny) ...[
                          SizedBox(height: UIUtils.spacing(context, 4)),
                          Text(
                            "Manage your sessions and connect with students",
                            style: TextStyle(
                              fontSize: UIUtils.fontSize(context, 13),
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: UIUtils.spacing(context, 12)),
                
                // Create Session Button
                ElevatedButton.icon(
                  onPressed: createSession,
                  icon: Icon(Icons.add_circle_outline, size: UIUtils.iconSize(context, 22)),
                  label: Text(
                    "2: Create New Session",
                    style: TextStyle(fontSize: UIUtils.fontSize(context, 15)),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: UIUtils.primaryColor,
                    foregroundColor: Colors.white,
                    padding: UIUtils.paddingSymmetric(context, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
                
                SizedBox(height: UIUtils.spacing(context, 12)),
                
                // Sessions Header
                Row(
                  children: [
                    Text(
                      "Your Sessions",
                      style: TextStyle(
                        fontSize: UIUtils.fontSize(context, 16),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: UIUtils.spacing(context, 6)),
                    if (sessions.isNotEmpty)
                      Container(
                        padding: UIUtils.paddingSymmetric(context, horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.indigo,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${sessions.length}',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: UIUtils.fontSize(context, 13),
                          ),
                        ),
                      ),
                  ],
                ),
                
                SizedBox(height: UIUtils.spacing(context, 8)),
                
                // Sessions List
                if (sessions.isEmpty)
                  Center(
                    child: Padding(
                      padding: UIUtils.paddingAll(context, 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.school_outlined,
                            size: UIUtils.iconSize(context, 56),
                            color: Colors.grey.shade400,
                          ),
                          SizedBox(height: UIUtils.spacing(context, 10)),
                          Text(
                            "No active sessions yet",
                            style: TextStyle(
                              fontSize: UIUtils.fontSize(context, 15),
                              color: Colors.grey.shade600,
                            ),
                          ),
                          if (!tiny) ...[
                            SizedBox(height: UIUtils.spacing(context, 4)),
                            Text(
                              "Create your first session to get started",
                              style: TextStyle(
                                fontSize: UIUtils.fontSize(context, 12),
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  )
                else
                  ...sessions.map((s) {
                    final sessionId = s['session_id'] ?? 0;
                    final title = s['title'] ?? 'Untitled Session';
                    final participantCount = s['participant_count'] ?? 0;
                    final createdAt = s['created_at'] ?? '';
                    
                    return Card(
                      margin: EdgeInsets.only(bottom: UIUtils.spacing(context, 8)),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: InkWell(
                        onTap: () => _openSession(sessionId),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: UIUtils.paddingAll(context, 12),
                          child: Row(
                            children: [
                              // Session Icon
                              Container(
                                width: 40 * UIUtils.scale(context),
                                height: 40 * UIUtils.scale(context),
                                decoration: BoxDecoration(
                                  color: UIUtils.backgroundColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    '$sessionId',
                                    style: TextStyle(
                                      fontSize: UIUtils.fontSize(context, 14),
                                      fontWeight: FontWeight.bold,
                                      color: UIUtils.primaryColor,
                                    ),
                                  ),
                                ),
                              ),
                              
                              SizedBox(width: UIUtils.spacing(context, 8)),
                              
                              // Session Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      style: TextStyle(
                                        fontSize: UIUtils.fontSize(context, 14),
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: UIUtils.spacing(context, 3)),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.people,
                                          size: UIUtils.iconSize(context, 14),
                                          color: Colors.grey.shade600,
                                        ),
                                        SizedBox(width: UIUtils.spacing(context, 3)),
                                        Text(
                                          '$participantCount participant${participantCount != 1 ? 's' : ''}',
                                          style: TextStyle(
                                            fontSize: UIUtils.fontSize(context, 11),
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Action Buttons
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ElevatedButton(
                                    onPressed: () => _openSession(sessionId),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      padding: UIUtils.paddingSymmetric(context, horizontal: 10, vertical: 4),
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text("Open", style: TextStyle(fontSize: UIUtils.fontSize(context, 12))),
                                  ),
                                  SizedBox(height: UIUtils.spacing(context, 4)),
                                  IconButton(
                                    onPressed: () => _deleteSession(sessionId, title),
                                    icon: Icon(Icons.delete, size: UIUtils.iconSize(context, 18)),
                                    color: Colors.red,
                                    tooltip: "Delete Session",
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                            ],
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