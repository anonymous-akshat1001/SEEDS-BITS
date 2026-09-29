import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../services/tts_service.dart';
import 'package:flutter/services.dart';
import 'session_screen.dart';
import 'audio_library_screen.dart';
import 'playlist_screens.dart';
import '../utils/ui_utils.dart';
import '../widgets/key_instruction_wrapper.dart';
import '../widgets/keypad_confirmation_dialog.dart';
import '../utils/keypad_actions.dart';
import '../services/auth_session_service.dart';
import '../utils/session_search.dart';

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
  bool _isRefreshing = false;
  List<dynamic> _workspaces = const [];
  Map<String, dynamic>? _selectedWorkspace;
  final TextEditingController _searchController = TextEditingController();
  final KeypadNavigationController _keypadController =
      KeypadNavigationController();
  final FocusNode _refreshFocusNode = FocusNode(debugLabel: 'teacher-refresh');
  final FocusNode _createFocusNode = FocusNode(debugLabel: 'teacher-create');
  final FocusNode _libraryFocusNode = FocusNode(debugLabel: 'teacher-library');
  final FocusNode _searchFocusNode = FocusNode(debugLabel: 'teacher-search');
  final FocusNode _searchResultsFocusNode = FocusNode(
    debugLabel: 'teacher-search-results',
  );
  final FocusNode _logoutFocusNode = FocusNode(debugLabel: 'teacher-logout');
  final FocusNode _workspaceFocusNode = FocusNode(
    debugLabel: 'teacher-workspace',
  );
  final FocusNode _playlistsFocusNode = FocusNode(
    debugLabel: 'teacher-playlists',
  );
  final Map<int, FocusNode> _sessionOpenFocusNodes = {};
  final Map<int, FocusNode> _sessionDeleteFocusNodes = {};

  // Called once when widget is created - ideal for API calls and reading local variables
  @override
  void initState() {
    super.initState();
    // Starts loading user data immediately
    _loadUserData();
  }

  // Load user data( non blocking )
  Future<void> _loadUserData() async {
    // opens local storage
    final prefs = await SharedPreferences.getInstance();
    // get user id
    final id = prefs.getInt('user_id');
    // fetch user name
    final name =
        prefs.getString('user_name') ??
        prefs.getString('name') ??
        'Teacher $id';

    // saves value into state and forces UI rebuild
    setState(() {
      currentUserId = id;
      currentUserName = name;
    });

    final accessContext = await ApiService.getAccessContext();
    final workspaceData = accessContext?['teacher_workspaces'];
    if (mounted && workspaceData is List) {
      setState(() {
        _workspaces = workspaceData;
        if (_workspaces.isNotEmpty) {
          _selectedWorkspace = Map<String, dynamic>.from(
            _workspaces.first as Map,
          );
        }
      });
    }

    // load session only if user exists
    if (currentUserId != null) {
      await _loadSessions();
    }

    // data loading complete
    if (!mounted) return;
    setState(() {
      // spinner removed
      isLoading = false;
    });
  }

  // Fetch all active sessions for this teacher
  Future<void> _loadSessions() async {
    final previousFocus = FocusManager.instance.primaryFocus;
    if (mounted) setState(() => _isRefreshing = true);
    await TtsService.speak('Refreshing sessions');
    final result = await ApiService.getResult(
      '/sessions/active',
      useAuth: true,
      context: 'session list',
    );

    if (!mounted) return;
    if (result.isSuccess && result.data is List) {
      // Filter sessions created by this teacher
      final teacherSessions = (result.data as List)
          .where((s) => s['created_by'] == currentUserId)
          .toList();

      // saves filtered sessions and updates UI
      setState(() {
        sessions = teacherSessions;
        _isRefreshing = false;
      });
      await TtsService.speak(
        sessions.isEmpty
            ? 'No active sessions found'
            : '${sessions.length} active sessions found',
      );
    } else {
      setState(() => _isRefreshing = false);
      final message = result.failure!.message;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      await TtsService.speak(message);
    }
    if (previousFocus != null && previousFocus.canRequestFocus)
      previousFocus.requestFocus();
  }

  // Funtion to create a new session by the teacher
  Future<void> createSession() async {
    // If user not logged in
    if (currentUserId == null || currentUserName == null) {
      TtsService.speak("User not logged in");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please log in first")));
      // stop execution
      return;
    }
    final workspace = _selectedWorkspace;
    if (workspace == null) {
      await TtsService.speak(
        'No class and subject assignment is available. Ask an administrator to assign one.',
      );
      return;
    }

    // Show dialog to input session title, waits for input and returns a String
    final title = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _CreateSessionDialog(),
    );

    if (title == null) {
      return; // User cancelled
    }
    if (!mounted) return;

    // Show loading
    showDialog(
      context: context,
      // blocks any other interaction and prevents accidental close
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // send session creation request to backend
    final result = await ApiService.postResult(
      '/sessions',
      {
        'title': title,
        'class_id': workspace['class_id'],
        'subject_id': workspace['subject_id'],
      },
      useAuth: true,
      context: 'session creation',
    );

    // Close loading dialog
    if (mounted) {
      Navigator.pop(context);
    }

    // Success case
    if (result.isSuccess && result.data!['session_id'] != null) {
      final res = result.data!;
      // adds new session to the list
      setState(() => sessions.add(res));
      TtsService.speak("Session $title created successfully");

      // Ask if they want to start the session now
      if (mounted) {
        final startNow = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (_) => KeypadConfirmationDialog(
            title: 'Session created',
            message: 'Do you want to start "$title" now?',
            cancelLabel: 'Later',
            confirmLabel: 'Start now',
            cancelKey: 0,
            confirmKey: 1,
          ),
        );

        if (startNow == true) {
          _openSession(res['session_id']);
        }
      }
    } else {
      final message =
          result.failure?.message ??
          'We could not complete that request. Check your connection and try again.';
      TtsService.speak(message);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    }
  }

  void _openSession(int sessionId) {
    if (currentUserId == null || currentUserName == null) {
      TtsService.speak("User not logged in");
      return;
    }

    // Find the session title from the sessions list
    String sessionTitle = 'Session';
    String? className;
    String? subjectName;
    for (final s in sessions) {
      if (s['session_id'] == sessionId) {
        sessionTitle = s['title'] ?? 'Session';
        className = s['class_name']?.toString();
        subjectName = s['subject_name']?.toString();
        break;
      }
    }

    TtsService.speak("Opening session");

    // opens new screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SessionScreen(
          sessionId: sessionId,
          userId: currentUserId!, // the ! claims that these fields are not null
          userName: currentUserName!,
          isTeacher: true,
          sessionTitle: sessionTitle,
          className: className,
          subjectName: subjectName,
        ),
      ),
    ).then((_) {
      // Refresh sessions when returning
      _loadSessions();
    });
  }

  // Open offline audio library (no session context)
  void _openOfflineAudioLibrary() {
    TtsService.speak("Opening offline audio library");
    final workspace = _selectedWorkspace;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OfflineAudioLibraryScreen(
          classId: workspace?['class_id'] as int?,
          subjectId: workspace?['subject_id'] as int?,
        ),
      ),
    );
  }

  void _openPlaylists() {
    final workspace = _selectedWorkspace;
    if (workspace == null) {
      TtsService.speak('No class and subject workspace is assigned');
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TeacherPlaylistsScreen(
          classId: workspace['class_id'] as int,
          className: '${workspace['class_name']}',
          subjectId: workspace['subject_id'] as int,
          subjectName: '${workspace['subject_name']}',
        ),
      ),
    );
  }

  Future<void> _logout() => AuthSessionService.logoutFrom(context);

  List get _filteredSessions {
    final workspace = _selectedWorkspace;
    final workspaceSessions = workspace == null
        ? <dynamic>[]
        : sessions
              .where(
                (session) =>
                    session['class_id'] == workspace['class_id'] &&
                    session['subject_id'] == workspace['subject_id'],
              )
              .toList();
    return filterSessionsByNameOrId(workspaceSessions, _searchController.text);
  }

  void _focusSessionSearch() {
    _keypadController.exitTextEditing();
    _searchFocusNode.requestFocus();
    TtsService.speak(
      'Session search. Press OK to edit, then enter a session name or ID. '
      'Use up or down to leave the field and browse results.',
    );
  }

  void _showSearchResults() {
    _keypadController.exitTextEditing();
    FocusScope.of(context).unfocus();
    final results = _filteredSessions;
    final query = _searchController.text.trim();
    final message = results.isEmpty
        ? 'No sessions match $query'
        : query.isEmpty
        ? 'Showing all ${results.length} sessions. Use down to browse.'
        : '${results.length} sessions match $query. Use down to browse.';
    TtsService.speak(message);
    if (results.isNotEmpty) {
      final id = int.tryParse((results.first['session_id'] ?? '').toString());
      if (id != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _sessionOpenFocusNodes[id]?.requestFocus();
        });
      }
    }
  }

  List<KeypadFocusTarget> _dashboardFocusTargets() {
    final targets = <KeypadFocusTarget>[
      KeypadFocusTarget(
        node: _refreshFocusNode,
        label: 'Refresh sessions',
        onActivate: _loadSessions,
        isEnabled: () => !_isRefreshing,
      ),
      KeypadFocusTarget(
        node: _workspaceFocusNode,
        label: _selectedWorkspace == null
            ? 'No class and subject workspace assigned'
            : 'Workspace ${_selectedWorkspace!['class_name']}, ${_selectedWorkspace!['subject_name']}',
      ),
      KeypadFocusTarget(
        node: _createFocusNode,
        label: 'Create new session',
        onActivate: createSession,
      ),
      KeypadFocusTarget(
        node: _playlistsFocusNode,
        label: 'Class playlists',
        onActivate: _openPlaylists,
      ),
      KeypadFocusTarget(
        node: _libraryFocusNode,
        label: 'Offline audio library',
        onActivate: _openOfflineAudioLibrary,
      ),
      KeypadFocusTarget(
        node: _searchFocusNode,
        label: 'Search sessions by name or ID',
        isTextField: true,
      ),
      KeypadFocusTarget(
        node: _searchResultsFocusNode,
        label: 'Show matching sessions',
        onActivate: _showSearchResults,
      ),
    ];
    for (final session in _filteredSessions) {
      final id = int.tryParse((session['session_id'] ?? '').toString()) ?? 0;
      final title = session['title'] ?? 'session';
      targets.add(
        KeypadFocusTarget(
          node: _sessionOpenFocusNodes.putIfAbsent(
            id,
            () => FocusNode(debugLabel: 'teacher-open-$id'),
          ),
          label: 'Session $id, $title. Press OK to open',
          onActivate: () => _openSession(id),
        ),
      );
      targets.add(
        KeypadFocusTarget(
          node: _sessionDeleteFocusNodes.putIfAbsent(
            id,
            () => FocusNode(debugLabel: 'teacher-delete-$id'),
          ),
          label: 'Delete $title',
          onActivate: () => _deleteSession(id, title),
        ),
      );
    }
    targets.add(
      KeypadFocusTarget(
        node: _logoutFocusNode,
        label: 'Log out',
        onActivate: _logout,
      ),
    );
    return targets;
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
    if (confirmed != true) {
      return;
    }

    // sends deletion request to backend
    final result = await ApiService.deleteResult(
      '/sessions/$sessionId',
      useAuth: true,
      context: 'session deletion',
    );

    if (result.isSuccess) {
      setState(() {
        sessions.removeWhere((s) => s['session_id'] == sessionId);
      });
      TtsService.speak("Session deleted");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Session deleted successfully")),
        );
      }
    } else {
      final message = result.failure!.message;
      TtsService.speak(message);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    }
  }

  // Frees memory
  @override
  void dispose() {
    _searchController.dispose();
    _refreshFocusNode.dispose();
    _createFocusNode.dispose();
    _libraryFocusNode.dispose();
    _searchFocusNode.dispose();
    _searchResultsFocusNode.dispose();
    _logoutFocusNode.dispose();
    _workspaceFocusNode.dispose();
    _playlistsFocusNode.dispose();
    for (final node in _sessionOpenFocusNodes.values) {
      node.dispose();
    }
    for (final node in _sessionDeleteFocusNodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  // Build UI
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) SystemNavigator.pop();
        },
        child: Scaffold(
          body: Center(
            child: Semantics(
              liveRegion: true,
              label: 'Teacher dashboard is loading',
              child: const CircularProgressIndicator(),
            ),
          ),
        ),
      );
    }

    return KeypadInstructionWrapper(
      screenName: 'Teacher Dashboard',
      labels: teacherDashboardKeyLabels,
      actions: {
        0: _logout,
        1: _loadSessions,
        2: createSession,
        3: _openOfflineAudioLibrary,
        4: _focusSessionSearch,
        5: _openPlaylists,
      },
      navigationController: _keypadController,
      focusTargets: _dashboardFocusTargets(),
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) SystemNavigator.pop();
        },
        child: _buildScaffold(context),
      ),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    final bool tiny = UIUtils.isTiny(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Teacher Dashboard",
          style: TextStyle(
            fontSize: UIUtils.fontSize(context, 18),
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: UIUtils.cardColor,
        foregroundColor: UIUtils.textColor,
        toolbarHeight: tiny ? 40 : null,
        actions: [
          if (currentUserName != null && !tiny)
            Padding(
              padding: UIUtils.paddingSymmetric(
                context,
                horizontal: 8,
                vertical: 8,
              ),
              child: Center(
                child: Row(
                  children: [
                    Icon(Icons.person, size: UIUtils.iconSize(context, 16)),
                    SizedBox(width: UIUtils.spacing(context, 4)),
                    Text(
                      currentUserName!,
                      style: TextStyle(
                        fontSize: UIUtils.fontSize(context, 14),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          IconButton(
            focusNode: _refreshFocusNode,
            icon: Icon(
              Icons.refresh_rounded,
              size: UIUtils.iconSize(context, 22),
              color: UIUtils.accentColor,
            ),
            tooltip: "Refresh Sessions",
            onPressed: () {
              TtsService.speak("Refreshing sessions");
              _loadSessions();
            },
          ),
          IconButton(
            focusNode: _logoutFocusNode,
            tooltip: 'Log out',
            onPressed: _logout,
            icon: Icon(Icons.logout, color: UIUtils.accentColor),
          ),
          if (UIUtils.isKeypad(context))
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: Center(
                child: Text(
                  "1",
                  style: TextStyle(
                    color: UIUtils.accentColor,
                    fontSize: UIUtils.fontSize(context, 14),
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
                if (_isRefreshing) ...[
                  Semantics(
                    liveRegion: true,
                    label: 'Refreshing sessions',
                    child: LinearProgressIndicator(),
                  ),
                  SizedBox(height: UIUtils.spacing(context, 8)),
                ],
                // Welcome Card
                Card(
                  elevation: 0,
                  color: UIUtils.cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: UIUtils.isHighContrast
                          ? UIUtils.accentColor
                          : Colors.grey.withOpacity(0.1),
                    ),
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
                              color: UIUtils.subtextColor,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                SizedBox(height: UIUtils.spacing(context, 12)),

                Semantics(
                  label: 'Selected class and subject workspace',
                  child: DropdownButtonFormField<int>(
                    focusNode: _workspaceFocusNode,
                    value: _selectedWorkspace?['assignment_id'] as int?,
                    decoration: const InputDecoration(
                      labelText: 'Class and subject workspace',
                      prefixIcon: Icon(Icons.workspaces_outline),
                    ),
                    items: _workspaces
                        .map<DropdownMenuItem<int>>(
                          (entry) => DropdownMenuItem<int>(
                            value: entry['assignment_id'] as int,
                            child: Text(
                              '${entry['class_name']} · ${entry['subject_name']}',
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (assignmentId) {
                      if (assignmentId == null) return;
                      setState(() {
                        _selectedWorkspace = Map<String, dynamic>.from(
                          _workspaces.firstWhere(
                                (entry) =>
                                    entry['assignment_id'] == assignmentId,
                              )
                              as Map,
                        );
                      });
                      TtsService.speak(
                        '${_selectedWorkspace!['class_name']}, ${_selectedWorkspace!['subject_name']} selected',
                      );
                    },
                  ),
                ),

                SizedBox(height: UIUtils.spacing(context, 8)),

                OutlinedButton.icon(
                  focusNode: _playlistsFocusNode,
                  onPressed: _openPlaylists,
                  icon: const Icon(Icons.playlist_play),
                  label: const Text('5: Class Playlists'),
                ),

                SizedBox(height: UIUtils.spacing(context, 12)),

                // Create Session Button
                ElevatedButton.icon(
                  focusNode: _createFocusNode,
                  onPressed: createSession,
                  icon: Icon(
                    Icons.add_circle_outline,
                    size: UIUtils.iconSize(context, 22),
                  ),
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

                SizedBox(height: UIUtils.spacing(context, 8)),

                // Offline Audio Library Button
                OutlinedButton.icon(
                  focusNode: _libraryFocusNode,
                  onPressed: _openOfflineAudioLibrary,
                  icon: Icon(
                    Icons.library_music_rounded,
                    size: UIUtils.iconSize(context, 22),
                  ),
                  label: Text(
                    "3: Offline Audio Library",
                    style: TextStyle(fontSize: UIUtils.fontSize(context, 15)),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: UIUtils.accentColor,
                    side: BorderSide(color: UIUtils.accentColor, width: 1.5),
                    padding: UIUtils.paddingSymmetric(context, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                SizedBox(height: UIUtils.spacing(context, 12)),

                Card(
                  elevation: 0,
                  color: UIUtils.cardColor,
                  child: Padding(
                    padding: UIUtils.paddingAll(context, 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            focusNode: _searchFocusNode,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.search,
                            onTap: () => _keypadController.enterTextEditing(
                              _searchFocusNode,
                            ),
                            onChanged: (_) => setState(() {}),
                            onSubmitted: (_) => _showSearchResults(),
                            decoration: const InputDecoration(
                              labelText: '4. Session name or ID',
                              hintText: 'Leave empty to list all sessions',
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        SizedBox(width: UIUtils.spacing(context, 8)),
                        Semantics(
                          button: true,
                          label: 'Show matching sessions',
                          child: IconButton.filled(
                            focusNode: _searchResultsFocusNode,
                            onPressed: _showSearchResults,
                            tooltip: 'Show matching sessions',
                            icon: const Icon(Icons.manage_search),
                          ),
                        ),
                      ],
                    ),
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
                    if (_filteredSessions.isNotEmpty)
                      Container(
                        padding: UIUtils.paddingSymmetric(
                          context,
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.indigo,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${_filteredSessions.length}',
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
                if (_filteredSessions.isEmpty)
                  Center(
                    child: Padding(
                      padding: UIUtils.paddingAll(context, 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.school_outlined,
                            size: UIUtils.iconSize(context, 56),
                            color: UIUtils.subtextColor,
                          ),
                          SizedBox(height: UIUtils.spacing(context, 10)),
                          Text(
                            _searchController.text.trim().isEmpty
                                ? "No active sessions yet"
                                : "No matching sessions",
                            style: TextStyle(
                              fontSize: UIUtils.fontSize(context, 15),
                              color: UIUtils.subtextColor,
                            ),
                          ),
                          if (!tiny &&
                              _searchController.text.trim().isEmpty) ...[
                            SizedBox(height: UIUtils.spacing(context, 4)),
                            Text(
                              "Create your first session to get started",
                              style: TextStyle(
                                fontSize: UIUtils.fontSize(context, 12),
                                color: UIUtils.subtextColor,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  )
                else
                  ..._filteredSessions.map((s) {
                    final sessionId = s['session_id'] ?? 0;
                    final title = s['title'] ?? 'Untitled Session';
                    // final participantCount = s['participant_count'] ?? 0;

                    return Card(
                      margin: EdgeInsets.only(
                        bottom: UIUtils.spacing(context, 8),
                      ),
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
                                    Text(
                                      '${s['class_name'] ?? 'Class'} · ${s['subject_name'] ?? 'Subject'}',
                                      style: TextStyle(
                                        fontSize: UIUtils.fontSize(context, 11),
                                        color: UIUtils.subtextColor,
                                      ),
                                    ),
                                    // SizedBox(height: UIUtils.spacing(context, 3)),
                                    // Row(
                                    //   children: [
                                    //     Icon(
                                    //       Icons.people,
                                    //       size: UIUtils.iconSize(context, 14),
                                    //       color: Colors.grey.shade600,
                                    //     ),
                                    //     SizedBox(width: UIUtils.spacing(context, 3)),
                                    //     Text(
                                    //       '$participantCount participant${participantCount != 1 ? 's' : ''}',
                                    //       style: TextStyle(
                                    //         fontSize: UIUtils.fontSize(context, 11),
                                    //         color: Colors.grey.shade600,
                                    //       ),
                                    //     ),
                                    //   ],
                                    // ),
                                  ],
                                ),
                              ),

                              // Action Buttons
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ElevatedButton(
                                    focusNode: _sessionOpenFocusNodes
                                        .putIfAbsent(
                                          sessionId,
                                          () => FocusNode(
                                            debugLabel:
                                                'teacher-open-$sessionId',
                                          ),
                                        ),
                                    onPressed: () => _openSession(sessionId),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      padding: UIUtils.paddingSymmetric(
                                        context,
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(
                                      "Open",
                                      style: TextStyle(
                                        fontSize: UIUtils.fontSize(context, 12),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: UIUtils.spacing(context, 4)),
                                  IconButton(
                                    focusNode: _sessionDeleteFocusNodes
                                        .putIfAbsent(
                                          sessionId as int,
                                          () => FocusNode(
                                            debugLabel:
                                                'teacher-delete-$sessionId',
                                          ),
                                        ),
                                    onPressed: () =>
                                        _deleteSession(sessionId, title),
                                    icon: Icon(
                                      Icons.delete,
                                      size: UIUtils.iconSize(context, 18),
                                    ),
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

                SizedBox(
                  height: UIUtils.spacing(context, 12),
                ), // Bottom padding
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CreateSessionDialog extends StatefulWidget {
  const _CreateSessionDialog();

  @override
  State<_CreateSessionDialog> createState() => _CreateSessionDialogState();
}

class _CreateSessionDialogState extends State<_CreateSessionDialog> {
  final TextEditingController _titleController = TextEditingController();
  final KeypadNavigationController _keypadController =
      KeypadNavigationController();
  final FocusNode _titleFocus = FocusNode(debugLabel: 'create-session-title');
  final FocusNode _cancelFocus = FocusNode(debugLabel: 'create-session-cancel');
  final FocusNode _createFocus = FocusNode(debugLabel: 'create-session-create');

  void _create() {
    final title = _titleController.text.trim();
    Navigator.pop(context, title.isEmpty ? 'New Session' : title);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _titleFocus.dispose();
    _cancelFocus.dispose();
    _createFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeypadInstructionWrapper(
      screenName: 'Create new session',
      labels: const {0: 'Cancel', 1: 'Create session'},
      actions: {0: () => Navigator.pop(context), 1: _create},
      navigationController: _keypadController,
      focusTargets: [
        KeypadFocusTarget(
          node: _titleFocus,
          label: 'Session title field',
          isTextField: true,
        ),
        KeypadFocusTarget(
          node: _cancelFocus,
          label: 'Cancel session creation',
          onActivate: () => Navigator.pop(context),
        ),
        KeypadFocusTarget(
          node: _createFocus,
          label: 'Create session',
          onActivate: _create,
        ),
      ],
      child: AlertDialog(
        title: const Text('Create New Session'),
        content: TextField(
          controller: _titleController,
          focusNode: _titleFocus,
          decoration: const InputDecoration(
            labelText: 'Session Title',
            hintText: 'e.g., English Class - Unit 5',
            border: OutlineInputBorder(),
          ),
          onTap: () => _keypadController.enterTextEditing(_titleFocus),
          onSubmitted: (_) => _create(),
        ),
        actions: [
          TextButton(
            focusNode: _cancelFocus,
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel (0)'),
          ),
          ElevatedButton(
            focusNode: _createFocus,
            onPressed: _create,
            child: const Text('Create (1)'),
          ),
        ],
      ),
    );
  }
}
