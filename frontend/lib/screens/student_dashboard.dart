import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../services/tts_service.dart';
import 'session_screen.dart';
import 'audio_library_screen.dart';
import 'package:flutter/services.dart';
import '../utils/ui_utils.dart';
import '../widgets/key_instruction_wrapper.dart';
import '../utils/keypad_actions.dart';
import '../services/auth_session_service.dart';
import '../utils/session_search.dart';

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
  bool _isRefreshing = false;
  final KeypadNavigationController _keypadController =
      KeypadNavigationController();
  final FocusNode _refreshFocusNode = FocusNode(debugLabel: 'student-refresh');
  final FocusNode _inputFocusNode = FocusNode(debugLabel: 'student-search');
  final FocusNode _joinFocusNode = FocusNode(
    debugLabel: 'student-search-results',
  );
  final FocusNode _libraryFocusNode = FocusNode(debugLabel: 'student-library');
  final FocusNode _logoutFocusNode = FocusNode(debugLabel: 'student-logout');
  final Map<int, FocusNode> _sessionFocusNodes = {};

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
    final name =
        prefs.getString('user_name') ??
        prefs.getString('name') ??
        'Student $id';

    // saves data into state and rebuild UI
    setState(() {
      currentUserId = id;
      currentUserName = name;
    });

    // Load session only if user exists
    if (currentUserId != null) {
      await _loadSessions();
    }

    // data loading finished and the loading spinner is removed
    if (!mounted) return;
    setState(() => isLoading = false);
  }

  // Fetch active sessions from backend
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
      setState(() {
        sessions = result.data as List;
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

  // Join a session using form data
  Future<void> joinSession(int sessionId) async {
    if (currentUserId == null) {
      TtsService.speak("User not logged in");
      // Visual feedback, appears at bottom
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please log in first")));
      return;
    }

    if (currentUserName == null) {
      TtsService.speak("User name not found");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("User name not found. Please log in again."),
        ),
      );
      return;
    }

    try {
      await TtsService.speak('Joining session');
      final result = await ApiService.joinSessionResult(
        sessionId,
        userId: currentUserId,
      );
      if (result.isSuccess) {
        TtsService.speak("Joined session $sessionId");

        // Navigate to Session Screen once the session has been joined
        if (mounted) {
          // Find session title from sessions list
          String sessionTitle = 'Session';
          for (final s in sessions) {
            if (s['session_id'] == sessionId) {
              sessionTitle = s['title'] ?? 'Session';
              break;
            }
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SessionScreen(
                sessionId: sessionId,
                userId: currentUserId!,
                userName: currentUserName!,
                isTeacher: false,
                sessionTitle: sessionTitle,
              ),
            ),
          ).then((_) {
            // Refresh sessions when returning
            _loadSessions();
          });
        }
      } else {
        final message = result.failure!.message;
        await TtsService.speak(message);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
        }
      }
    } catch (e) {
      final message = ApiService.mapFailure(
        error: e,
        context: 'session join',
      ).message;
      await TtsService.speak(message);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    }
  }

  // Called when the screen is destroyed
  @override
  void dispose() {
    // Frees memory - crictical for low RAM devices like button phones
    sessionCtrl.dispose();
    _refreshFocusNode.dispose();
    _inputFocusNode.dispose();
    _joinFocusNode.dispose();
    _libraryFocusNode.dispose();
    _logoutFocusNode.dispose();
    for (final node in _sessionFocusNodes.values) {
      node.dispose();
    }
    // calls parent dispose class
    super.dispose();
  }

  // Open offline audio library (no session context)
  void _openOfflineAudioLibrary() {
    TtsService.speak("Opening offline audio library");
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const OfflineAudioLibraryScreen()),
    );
  }

  void _focusSessionInput() {
    _keypadController.exitTextEditing();
    _inputFocusNode.requestFocus();
    TtsService.speak(
      'Session search. Press OK to edit, then enter a session name or ID. '
      'Use up or down to leave the field and browse results.',
    );
  }

  List get _filteredSessions =>
      filterSessionsByNameOrId(sessions, sessionCtrl.text);

  void _showSearchResults() {
    _keypadController.exitTextEditing();
    FocusScope.of(context).unfocus();
    final results = _filteredSessions;
    final query = sessionCtrl.text.trim();
    final message = results.isEmpty
        ? 'No sessions match $query'
        : query.isEmpty
        ? 'Showing all ${results.length} active sessions. Use down to browse.'
        : '${results.length} sessions match $query. Use down to browse.';
    TtsService.speak(message);
    if (results.isNotEmpty) {
      final id = int.tryParse((results.first['session_id'] ?? '').toString());
      if (id != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _sessionFocusNodes[id]?.requestFocus();
        });
      }
    }
  }

  Future<void> _logout() => AuthSessionService.logoutFrom(context);

  List<KeypadFocusTarget> _dashboardFocusTargets() {
    final targets = <KeypadFocusTarget>[
      KeypadFocusTarget(
        node: _refreshFocusNode,
        label: 'Refresh sessions',
        onActivate: _loadSessions,
        isEnabled: () => !_isRefreshing,
      ),
      KeypadFocusTarget(
        node: _inputFocusNode,
        label: 'Search sessions by name or ID',
        isTextField: true,
      ),
      KeypadFocusTarget(
        node: _joinFocusNode,
        label: 'Show matching sessions',
        onActivate: _showSearchResults,
      ),
      KeypadFocusTarget(
        node: _libraryFocusNode,
        label: 'Offline audio library',
        onActivate: _openOfflineAudioLibrary,
      ),
    ];
    for (final session in _filteredSessions) {
      final id = int.tryParse((session['session_id'] ?? '').toString()) ?? 0;
      final node = _sessionFocusNodes.putIfAbsent(
        id,
        () => FocusNode(debugLabel: 'student-session-$id'),
      );
      targets.add(
        KeypadFocusTarget(
          node: node,
          label:
              'Session $id, ${session['title'] ?? 'untitled'}, teacher ${session['teacher_name'] ?? 'unknown'}. Press OK to join',
          onActivate: () => joinSession(id),
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

  // UI Build - reruns on every setState
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
              label: 'Student dashboard is loading',
              child: const CircularProgressIndicator(),
            ),
          ),
        ),
      );
    }

    return KeypadInstructionWrapper(
      screenName: 'Student Dashboard',
      labels: studentDashboardKeyLabels,
      actions: {
        0: _logout,
        1: _loadSessions,
        2: _focusSessionInput,
        3: _openOfflineAudioLibrary,
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
    final bool compact = tiny || UIUtils.isShort(context);

    return Scaffold(
      appBar: AppBar(
        // Screen Title
        title: Text(
          "Student Dashboard",
          style: TextStyle(
            fontSize: UIUtils.fontSize(context, 18),
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: UIUtils.cardColor,
        foregroundColor: UIUtils.textColor,
        elevation: 0,
        toolbarHeight: tiny ? 40 : null,
        // Right side appbar actions
        actions: [
          if (currentUserName != null && !tiny)
            // show name of current logged in user
            Padding(
              padding: UIUtils.paddingSymmetric(
                context,
                horizontal: 8,
                vertical: 8,
              ),
              child: Center(
                child: Text(
                  currentUserName!,
                  style: TextStyle(
                    fontSize: UIUtils.fontSize(context, 14),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

          // Refresh Button
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
        // prevents overflow on smaller screens
        child: SingleChildScrollView(
          child: Padding(
            padding: UIUtils.paddingAll(context, 12),
            // Column defines vertical alignment
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
                // User Info Card
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
                            color: UIUtils.subtextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: UIUtils.spacing(context, 12)),

                // Search and browse section
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
                          "Find a Session",
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
                                onTap: () => _keypadController.enterTextEditing(
                                  _inputFocusNode,
                                ),
                                onChanged: (_) => setState(() {}),
                                onSubmitted: (_) {
                                  _showSearchResults();
                                },
                                keyboardType: TextInputType.text,
                                style: TextStyle(
                                  fontSize: UIUtils.fontSize(context, 14),
                                ),
                                decoration: InputDecoration(
                                  labelText: "2. Session name or ID",
                                  labelStyle: TextStyle(
                                    fontSize: UIUtils.fontSize(context, 12),
                                    color: UIUtils.subtextColor,
                                  ),
                                  filled: true,
                                  fillColor: UIUtils.backgroundColor,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.meeting_room_rounded,
                                    size: UIUtils.iconSize(context, 18),
                                    color: UIUtils.accentColor,
                                  ),
                                  contentPadding: UIUtils.paddingSymmetric(
                                    context,
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  isDense: true,
                                ),
                              ),
                            ),
                            SizedBox(width: UIUtils.spacing(context, 8)),
                            compact
                                ? SizedBox(
                                    width: 40,
                                    height: 40,
                                    child: ElevatedButton(
                                      focusNode: _joinFocusNode,
                                      onPressed: _showSearchResults,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: UIUtils.primaryColor,
                                        foregroundColor: Colors.white,
                                        padding: EdgeInsets.zero,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: Icon(
                                        Icons.search,
                                        size: UIUtils.iconSize(context, 18),
                                      ),
                                    ),
                                  )
                                : ElevatedButton.icon(
                                    focusNode: _joinFocusNode,
                                    onPressed: _showSearchResults,
                                    icon: Icon(
                                      Icons.search,
                                      size: UIUtils.iconSize(context, 16),
                                    ),
                                    label: Text(
                                      "Results",
                                      style: TextStyle(
                                        fontSize: UIUtils.fontSize(context, 13),
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: UIUtils.primaryColor,
                                      foregroundColor: Colors.white,
                                      padding: UIUtils.paddingSymmetric(
                                        context,
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
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

                // Active sessions header
                Row(
                  children: [
                    Text(
                      "Active Sessions",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: UIUtils.fontSize(context, 16),
                      ),
                    ),
                    SizedBox(width: UIUtils.spacing(context, 6)),
                    if (_filteredSessions.isNotEmpty)
                      Container(
                        padding: UIUtils.paddingSymmetric(
                          context,
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: UIUtils.accentColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${_filteredSessions.length}',
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
                if (_filteredSessions.isEmpty)
                  Center(
                    child: Padding(
                      padding: UIUtils.paddingAll(context, 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_busy,
                            size: UIUtils.iconSize(context, 48),
                            color: UIUtils.subtextColor,
                          ),
                          SizedBox(height: UIUtils.spacing(context, 10)),
                          Text(
                            sessionCtrl.text.trim().isEmpty
                                ? "No active sessions"
                                : "No matching sessions",
                            style: TextStyle(
                              fontSize: UIUtils.fontSize(context, 14),
                              color: UIUtils.subtextColor,
                            ),
                          ),
                          SizedBox(height: UIUtils.spacing(context, 6)),
                          TextButton.icon(
                            onPressed: _loadSessions,
                            icon: Icon(
                              Icons.refresh,
                              size: UIUtils.iconSize(context, 16),
                            ),
                            label: Text(
                              "Refresh",
                              style: TextStyle(
                                fontSize: UIUtils.fontSize(context, 13),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  // Converts list → widgets using ... operator
                  ..._filteredSessions.map((s) {
                    final sessionId = s['session_id'] ?? 0;
                    final title = s['title'] ?? 'Untitled Session';
                    final teacherName = s['teacher_name'] ?? 'Unknown';
                    // final participantCount = s['participant_count'] ?? 0;

                    return Card(
                      margin: EdgeInsets.only(
                        bottom: UIUtils.spacing(context, 8),
                      ),
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
                                  Icon(
                                    Icons.person,
                                    size: UIUtils.iconSize(context, 14),
                                  ),
                                  SizedBox(width: UIUtils.spacing(context, 3)),
                                  Expanded(
                                    child: Text(
                                      'Teacher: $teacherName',
                                      style: TextStyle(
                                        fontSize: UIUtils.fontSize(context, 11),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              // SizedBox(height: UIUtils.spacing(context, 2)),
                              // Row(
                              //   children: [
                              //     Icon(Icons.people, size: UIUtils.iconSize(context, 14)),
                              //     SizedBox(width: UIUtils.spacing(context, 3)),
                              //     Text('$participantCount participants',
                              //         style: TextStyle(fontSize: UIUtils.fontSize(context, 11))),
                              //   ],
                              // ),
                            ],
                          ),
                          trailing: ElevatedButton(
                            focusNode: _sessionFocusNodes.putIfAbsent(
                              sessionId as int,
                              () => FocusNode(
                                debugLabel: 'student-session-$sessionId',
                              ),
                            ),
                            onPressed: () => joinSession(sessionId),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: UIUtils.primaryColor,
                              foregroundColor: Colors.white,
                              padding: UIUtils.paddingSymmetric(
                                context,
                                horizontal: 12,
                                vertical: 8,
                              ),
                              minimumSize: Size.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              elevation: 0,
                            ),
                            child: Text(
                              "Join",
                              style: TextStyle(
                                fontSize: UIUtils.fontSize(context, 12),
                              ),
                            ),
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
