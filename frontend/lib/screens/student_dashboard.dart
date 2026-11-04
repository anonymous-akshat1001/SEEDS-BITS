import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../services/tts_service.dart';
import 'session_screen.dart';
import 'audio_library_screen.dart';
import 'playlist_screens.dart';
import 'quiz_screens.dart';
import 'package:flutter/services.dart';
import '../utils/ui_utils.dart';
import '../widgets/accessible_tile.dart';
import '../widgets/key_instruction_wrapper.dart';
import '../utils/keypad_actions.dart';
import '../services/auth_session_service.dart';
import '../utils/session_search.dart';
import '../utils/class_access_utils.dart';

// Define the Student Dashboard as a Stateful Widget
class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  // Connect UI to its State
  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

// Define the state class where logic resides
class _StudentDashboardState extends State<StudentDashboard> {
  // input/control the session search text
  final sessionCtrl = TextEditingController();
  // Session number typed on the keypad (digits only).
  final _sessionIdCtrl = TextEditingController();
  // Stores list of active sessions from backend
  List sessions = [];
  // Stores logged-in user’s ID, the ? means that it can be NULL
  int? currentUserId;
  // Stores the logged in users name
  String? currentUserName;
  bool isLoading = true;
  bool _isRefreshing = false;
  String? _className;
  int? _selectedSubjectId;
  String? _statusMessage;
  bool _statusIsError = false;
  Timer? _idSearchTimer;
  Timer? _summaryTimer;
  VoidCallback? _pendingSummaryListener;
  final KeypadNavigationController _keypadController =
      KeypadNavigationController();
  final FocusNode _refreshFocusNode = FocusNode(debugLabel: 'student-refresh');
  final FocusNode _sessionIdFocusNode = FocusNode(
    debugLabel: 'student-session-number',
  );
  final FocusNode _inputFocusNode = FocusNode(debugLabel: 'student-search');
  final FocusNode _joinFocusNode = FocusNode(
    debugLabel: 'student-search-results',
  );
  final FocusNode _libraryFocusNode = FocusNode(debugLabel: 'student-library');
  final FocusNode _logoutFocusNode = FocusNode(debugLabel: 'student-logout');
  final FocusNode _subjectFocusNode = FocusNode(
    debugLabel: 'student-subject-filter',
  );
  final FocusNode _playlistsFocusNode = FocusNode(
    debugLabel: 'student-playlists',
  );
  final FocusNode _quizzesFocusNode = FocusNode(debugLabel: 'student-quizzes');
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

    if (!mounted) return;
    // saves data into state and rebuild UI
    setState(() {
      currentUserId = id;
      currentUserName = name;
    });

    final accessContext = await ApiService.getAccessContext();
    final classData = accessContext?['student_class'];
    if (mounted && classData is Map) {
      setState(() => _className = classData['class_name']?.toString());
    }

    // Load session only if user exists
    if (currentUserId != null) {
      await _loadSessions(announce: false);
    }

    // data loading finished and the loading spinner is removed
    if (!mounted) return;
    setState(() => isLoading = false);
    // The screen's own instructions play first; then say what loaded.
    _announceAfterInstructions(_statusMessage ?? _sessionSummary());
  }

  String _sessionSummary() {
    final count = _filteredSessions.length;
    if (sessions.isEmpty) return 'No live sessions right now. Press 1 to refresh.';
    if (count == 0) return 'No sessions match your filter.';
    return '$count ${count == 1 ? 'session' : 'sessions'} available. '
        'Use down to browse.';
  }

  void _announceAfterInstructions(String message) {
    _summaryTimer?.cancel();
    _summaryTimer = Timer(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      if (!TtsService.speaking.value) {
        TtsService.speak(message);
        return;
      }
      void listener() {
        if (TtsService.speaking.value) return;
        TtsService.speaking.removeListener(listener);
        _pendingSummaryListener = null;
        if (mounted) TtsService.speak(message);
      }

      _pendingSummaryListener = listener;
      TtsService.speaking.addListener(listener);
    });
  }

  /// Shows a short status line and speaks it once (TtsService also reaches
  /// TalkBack, so no SnackBar is used for the same text).
  void _showStatus(String message, {bool error = false}) {
    if (!mounted) return;
    setState(() {
      _statusMessage = message;
      _statusIsError = error;
    });
    TtsService.speak(
      message,
      priority: error ? SpeechPriority.critical : SpeechPriority.requested,
    );
  }

  // Fetch active sessions from backend
  Future<void> _loadSessions({bool announce = true}) async {
    if (_isRefreshing) return;
    final previousFocus = FocusManager.instance.primaryFocus;
    if (mounted) setState(() => _isRefreshing = true);
    if (announce) await TtsService.speak('Refreshing sessions');
    final result = await ApiService.getResult(
      '/sessions/active',
      useAuth: true,
      context: 'session list',
    );
    if (!mounted) return;
    if (result.isSuccess && result.data is List) {
      setState(() {
        sessions = result.data as List;
        if (_selectedSubjectId != null &&
            !_availableSubjects.any(
              (entry) => entry['subject_id'] == _selectedSubjectId,
            )) {
          _selectedSubjectId = null;
        }
        _isRefreshing = false;
        _statusMessage = null;
      });
      if (announce) await TtsService.speak(_sessionSummary());
    } else {
      setState(() {
        _isRefreshing = false;
        _statusMessage =
            '${result.failure!.message} Press 1 to try again.';
        _statusIsError = true;
      });
      if (announce) {
        await TtsService.speak(
          _statusMessage!,
          priority: SpeechPriority.critical,
        );
      }
    }
    if (previousFocus != null &&
        previousFocus.context != null &&
        previousFocus.canRequestFocus) {
      previousFocus.requestFocus();
    }
  }

  // Join a session using form data
  Future<void> joinSession(int sessionId) async {
    if (currentUserId == null) {
      _showStatus('You are not logged in. Please log in first.', error: true);
      return;
    }

    if (currentUserName == null) {
      _showStatus(
        'User name not found. Please log in again.',
        error: true,
      );
      return;
    }

    try {
      await TtsService.speak('Joining session');
      final result = await ApiService.joinSessionResult(sessionId);
      if (result.isSuccess) {
        TtsService.speak("Joined session $sessionId");

        // Navigate to Session Screen once the session has been joined
        if (mounted) {
          // Find session title from sessions list
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

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SessionScreen(
                sessionId: sessionId,
                userId: currentUserId!,
                userName: currentUserName!,
                isTeacher: false,
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
      } else {
        _showStatus(result.failure!.message, error: true);
      }
    } catch (e) {
      _showStatus(
        ApiService.mapFailure(error: e, context: 'session join').message,
        error: true,
      );
    }
  }

  // Called when the screen is destroyed
  @override
  void dispose() {
    _idSearchTimer?.cancel();
    _summaryTimer?.cancel();
    final listener = _pendingSummaryListener;
    if (listener != null) TtsService.speaking.removeListener(listener);
    // Frees memory - crictical for low RAM devices like button phones
    sessionCtrl.dispose();
    _sessionIdCtrl.dispose();
    _refreshFocusNode.dispose();
    _sessionIdFocusNode.dispose();
    _inputFocusNode.dispose();
    _joinFocusNode.dispose();
    _libraryFocusNode.dispose();
    _logoutFocusNode.dispose();
    _subjectFocusNode.dispose();
    _playlistsFocusNode.dispose();
    _quizzesFocusNode.dispose();
    for (final node in _sessionFocusNodes.values) {
      node.dispose();
    }
    // calls parent dispose class
    super.dispose();
  }

  // Open offline audio library (no session context)
  void _openOfflineAudioLibrary() {
    TtsService.speak('Opening recorded audio library. Internet is required.');
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const OfflineAudioLibraryScreen()),
    );
  }

  void _openMyPlaylists() {
    TtsService.speak('Opening My Playlists. These playlists are private.');
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const StudentPlaylistsScreen()),
    );
  }

  void _openQuizzes() {
    TtsService.speak('Opening quizzes');
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const StudentQuizScreen()),
    );
  }

  void _focusSessionInput() {
    _keypadController.exitTextEditing();
    _sessionIdFocusNode.requestFocus();
    TtsService.speak(
      'Session search. Type a session number with the keypad, or move down '
      'to search by name. Press OK to edit. Use down to browse results.',
    );
  }

  List get _filteredSessions {
    final bySubject = filterSessionsBySubject(sessions, _selectedSubjectId);
    final byName = filterSessionsByNameOrId(bySubject, sessionCtrl.text);
    final id = _sessionIdCtrl.text.trim();
    if (id.isEmpty) return byName;
    return byName
        .where((session) => '${(session as Map)['session_id']}' == id)
        .toList();
  }

  List<Map<String, dynamic>> get _availableSubjects {
    final byId = <int, Map<String, dynamic>>{};
    for (final session in sessions) {
      final id = session['subject_id'];
      if (id is int) {
        byId[id] = {
          'subject_id': id,
          'subject_name': session['subject_name'] ?? 'Subject $id',
        };
      }
    }
    return byId.values.toList()..sort(
      (a, b) => '${a['subject_name']}'.compareTo('${b['subject_name']}'),
    );
  }

  /// Called as digits are typed: waits for a pause, then says whether the
  /// session number exists so the user can move down and press OK to join.
  void _onSessionIdChanged(String _) {
    setState(() {});
    _idSearchTimer?.cancel();
    _idSearchTimer = Timer(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      final id = _sessionIdCtrl.text.trim();
      if (id.isEmpty) {
        TtsService.speak('Session number cleared. ${_sessionSummary()}');
        return;
      }
      final matches = _filteredSessions;
      TtsService.speak(
        matches.isEmpty
            ? 'No live session number $id.'
            : 'Found: ${_sessionLabel(matches.first as Map)}. '
                  'Press down, then OK.',
      );
    });
  }

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

  // Asks "Log out of SEEDS?" with a keypad confirmation dialog first.
  Future<void> _logout() => AuthSessionService.logoutFrom(context);

  void _cycleSubjectFilter(int direction) {
    final ids = <int?>[
      null,
      ..._availableSubjects.map((entry) => entry['subject_id'] as int),
    ];
    if (ids.isEmpty) return;
    var current = ids.indexOf(_selectedSubjectId);
    if (current < 0) current = 0;
    var next = (current + direction) % ids.length;
    if (next < 0) next += ids.length;
    setState(() => _selectedSubjectId = ids[next]);
    final selected = ids[next] == null
        ? null
        : _availableSubjects.firstWhere(
            (entry) => entry['subject_id'] == ids[next],
          );
    TtsService.speak(
      selected == null
          ? 'Showing all subjects. ${_sessionSummary()}'
          : 'Showing ${selected['subject_name']} sessions. ${_sessionSummary()}',
    );
  }

  int _sessionIdOf(Map session) =>
      int.tryParse((session['session_id'] ?? '').toString()) ?? 0;

  /// Concise spoken label, most important first:
  /// "Science, Class 6, Teacher Mrs Rao, live now, session 12".
  String _sessionLabel(Map session) {
    final title = '${session['title'] ?? 'Untitled session'}'.trim();
    final subject = session['subject_name']?.toString().trim();
    final className = (session['class_name'] ?? _className)?.toString().trim();
    final teacher = session['teacher_name']?.toString().trim();
    return [
      title,
      if (subject != null &&
          subject.isNotEmpty &&
          subject.toLowerCase() != title.toLowerCase())
        subject,
      if (className != null && className.isNotEmpty) className,
      if (teacher != null && teacher.isNotEmpty) 'Teacher $teacher',
      'live now',
      'session ${_sessionIdOf(session)}',
    ].join(', ');
  }

  // Same order as the controls appear on screen, top to bottom.
  List<KeypadFocusTarget> _dashboardFocusTargets() {
    final selectedSubject = _selectedSubjectId == null
        ? null
        : _availableSubjects.cast<Map<String, dynamic>?>().firstWhere(
            (entry) => entry?['subject_id'] == _selectedSubjectId,
            orElse: () => null,
          );
    final targets = <KeypadFocusTarget>[
      KeypadFocusTarget(
        node: _refreshFocusNode,
        label: 'Refresh sessions',
        onActivate: _loadSessions,
        isEnabled: () => !_isRefreshing,
      ),
      KeypadFocusTarget(
        node: _sessionIdFocusNode,
        label: _sessionIdCtrl.text.isEmpty
            ? 'Session number field. Type a number to find a session'
            : 'Session number field, ${_sessionIdCtrl.text}',
        isTextField: true,
      ),
      KeypadFocusTarget(
        node: _inputFocusNode,
        label: 'Search sessions by name',
        isTextField: true,
      ),
      KeypadFocusTarget(
        node: _joinFocusNode,
        label: 'Show matching sessions',
        onActivate: _showSearchResults,
      ),
      KeypadFocusTarget(
        node: _subjectFocusNode,
        label: selectedSubject == null
            ? 'Subject filter: all subjects. Use left or right to change'
            : 'Subject filter: ${selectedSubject['subject_name']}. Use left or right to change',
        onActivate: () => _cycleSubjectFilter(1),
        onDecrease: () => _cycleSubjectFilter(-1),
        onIncrease: () => _cycleSubjectFilter(1),
      ),
    ];
    for (final session in _filteredSessions) {
      final id = _sessionIdOf(session as Map);
      final node = _sessionFocusNodes.putIfAbsent(
        id,
        () => FocusNode(debugLabel: 'student-session-$id'),
      );
      targets.add(
        KeypadFocusTarget(
          node: node,
          label: '${_sessionLabel(session)}. Press OK to join',
          onActivate: () => joinSession(id),
        ),
      );
    }
    targets.addAll([
      KeypadFocusTarget(
        node: _libraryFocusNode,
        label: 'Recorded audio library',
        onActivate: _openOfflineAudioLibrary,
      ),
      KeypadFocusTarget(
        node: _playlistsFocusNode,
        label: 'My private playlists',
        onActivate: _openMyPlaylists,
      ),
      KeypadFocusTarget(
        node: _quizzesFocusNode,
        label: 'Quizzes',
        onActivate: _openQuizzes,
      ),
      KeypadFocusTarget(
        node: _logoutFocusNode,
        label: 'Log out, asks to confirm',
        onActivate: _logout,
      ),
    ]);
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
          backgroundColor: UIUtils.backgroundColor,
          body: Center(
            child: Semantics(
              liveRegion: true,
              label: 'Student dashboard is loading',
              child: CircularProgressIndicator(color: UIUtils.accentColor),
            ),
          ),
        ),
      );
    }

    return KeypadInstructionWrapper(
      screenName: 'Student Dashboard',
      navigationSections:
          'refresh, session search, live sessions, recorded lessons, playlists, quizzes, and log out',
      labels: studentDashboardKeyLabels,
      actions: {
        0: _logout,
        1: _loadSessions,
        2: _focusSessionInput,
        3: _openOfflineAudioLibrary,
        4: _openMyPlaylists,
        5: _openQuizzes,
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

  OutlineInputBorder _border(Color color, double width) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: BorderSide(color: color, width: width),
  );

  InputDecoration _fieldDecoration(
    BuildContext context, {
    required String label,
    required IconData icon,
  }) => InputDecoration(
    label: Text(label),
    labelStyle: TextStyle(
      fontSize: UIUtils.fontSize(context, 14),
      color: UIUtils.subtextColor,
    ),
    filled: true,
    fillColor: UIUtils.backgroundColor,
    border: _border(UIUtils.cardBorderColor, 1.5),
    enabledBorder: _border(UIUtils.cardBorderColor, 1.5),
    focusedBorder: _border(UIUtils.accentColor, 3),
    prefixIcon: ExcludeSemantics(
      child: Icon(
        icon,
        size: UIUtils.iconSize(context, 18),
        color: UIUtils.accentColor,
      ),
    ),
    contentPadding: UIUtils.paddingSymmetric(
      context,
      horizontal: 12,
      vertical: 12,
    ),
    isDense: true,
  );

  Widget _navButton(
    BuildContext context, {
    required FocusNode focusNode,
    required VoidCallback onPressed,
    required IconData icon,
    required String text,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: UIUtils.spacing(context, 8)),
      child: OutlinedButton.icon(
        focusNode: focusNode,
        onPressed: onPressed,
        icon: ExcludeSemantics(
          child: Icon(icon, size: UIUtils.iconSize(context, 22)),
        ),
        label: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: UIUtils.fontSize(context, 16),
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: UIUtils.textColor,
          side: BorderSide(color: UIUtils.cardBorderColor, width: 1.5),
          padding: UIUtils.paddingSymmetric(
            context,
            horizontal: 8,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    final bool tiny = UIUtils.isTiny(context);
    final bool compact = tiny || UIUtils.isShort(context);
    final bool largeText = MediaQuery.textScalerOf(context).scale(1) > 1.15;
    final filtered = _filteredSessions;
    final cardDecoration = BoxDecoration(
      color: UIUtils.cardColor,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: UIUtils.cardBorderColor, width: 1.5),
    );

    return Scaffold(
      backgroundColor: UIUtils.backgroundColor,
      appBar: AppBar(
        // Screen Title
        title: UIUtils.useStackedLayout(context)
            ? null
            : Semantics(
                header: true,
                child: Text(
                  'Student Dashboard',
                  style: TextStyle(
                    fontSize: UIUtils.fontSize(context, 18),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
        backgroundColor: UIUtils.cardColor,
        foregroundColor: UIUtils.textColor,
        elevation: 0,
        shape: Border(
          bottom: BorderSide(color: UIUtils.cardBorderColor, width: 1.5),
        ),
        toolbarHeight: tiny ? 44 : null,
        actions: [
          IconButton(
            focusNode: _refreshFocusNode,
            icon: Icon(
              Icons.refresh_rounded,
              size: UIUtils.iconSize(context, 22),
              color: UIUtils.accentColor,
            ),
            tooltip: '1: Refresh sessions',
            onPressed: _isRefreshing ? null : _loadSessions,
          ),
        ],
      ),

      body: SafeArea(
        // prevents overflow on smaller screens
        child: SingleChildScrollView(
          child: Padding(
            padding: UIUtils.paddingAll(context, tiny ? 8 : 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (UIUtils.useStackedLayout(context))
                  Semantics(
                    header: true,
                    child: Text(
                      'Student Dashboard',
                      style: TextStyle(
                        fontSize: UIUtils.fontSize(context, 20),
                        fontWeight: FontWeight.bold,
                        color: UIUtils.textColor,
                      ),
                    ),
                  ),
                // Welcome and class (plain text, not a keypad stop)
                Container(
                  margin: EdgeInsets.only(top: UIUtils.spacing(context, 6)),
                  padding: UIUtils.paddingAll(context, 12),
                  decoration: cardDecoration,
                  child: MergeSemantics(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome, ${currentUserName ?? 'Student'}',
                          style: TextStyle(
                            fontSize: UIUtils.fontSize(context, 18),
                            fontWeight: FontWeight.bold,
                            color: UIUtils.textColor,
                          ),
                        ),
                        SizedBox(height: UIUtils.spacing(context, 4)),
                        Text(
                          'Class: ${_className ?? 'assignment pending'}',
                          style: TextStyle(
                            fontSize: UIUtils.fontSize(context, 16),
                            color: UIUtils.subtextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: UIUtils.spacing(context, 10)),

                if (_isRefreshing) ...[
                  Semantics(
                    liveRegion: true,
                    label: 'Refreshing sessions',
                    child: LinearProgressIndicator(
                      color: UIUtils.accentColor,
                      backgroundColor: UIUtils.cardColor,
                    ),
                  ),
                  SizedBox(height: UIUtils.spacing(context, 8)),
                ],

                // Live sessions header with a visible count in words.
                Semantics(
                  header: true,
                  child: Text(
                    filtered.isEmpty
                        ? 'Live sessions: none'
                        : 'Live sessions: ${filtered.length}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: UIUtils.fontSize(context, 18),
                      color: UIUtils.textColor,
                    ),
                  ),
                ),
                if (_statusMessage != null) ...[
                  SizedBox(height: UIUtils.spacing(context, 6)),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _statusIsError
                            ? UIUtils.errorColor
                            : UIUtils.cardBorderColor,
                        width: 2,
                      ),
                    ),
                    child: Text(
                      _statusMessage!,
                      style: TextStyle(
                        fontSize: UIUtils.fontSize(context, 16),
                        color: _statusIsError
                            ? UIUtils.errorColor
                            : UIUtils.textColor,
                      ),
                    ),
                  ),
                ],
                SizedBox(height: UIUtils.spacing(context, 8)),

                // Find a session: by number (keypad digits) or by name.
                TextField(
                  controller: _sessionIdCtrl,
                  focusNode: _sessionIdFocusNode,
                  onTap: () =>
                      _keypadController.enterTextEditing(_sessionIdFocusNode),
                  onChanged: _onSessionIdChanged,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: TextStyle(
                    fontSize: UIUtils.fontSize(context, 16),
                    color: UIUtils.textColor,
                  ),
                  decoration: _fieldDecoration(
                    context,
                    label: '2: Session number',
                    icon: Icons.pin_outlined,
                  ),
                ),
                SizedBox(height: UIUtils.spacing(context, 8)),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: sessionCtrl,
                        focusNode: _inputFocusNode,
                        onTap: () =>
                            _keypadController.enterTextEditing(_inputFocusNode),
                        onChanged: (_) => setState(() {}),
                        onSubmitted: (_) => _showSearchResults(),
                        keyboardType: TextInputType.text,
                        style: TextStyle(
                          fontSize: UIUtils.fontSize(context, 16),
                          color: UIUtils.textColor,
                        ),
                        decoration: _fieldDecoration(
                          context,
                          label: 'Session name',
                          icon: Icons.search,
                        ),
                      ),
                    ),
                    SizedBox(width: UIUtils.spacing(context, 6)),
                    compact || largeText
                        ? IconButton.filled(
                            focusNode: _joinFocusNode,
                            onPressed: _showSearchResults,
                            tooltip: 'Show matching sessions',
                            style: IconButton.styleFrom(
                              backgroundColor: UIUtils.primaryColor,
                              foregroundColor: UIUtils.onPrimaryColor,
                            ),
                            icon: Icon(
                              Icons.search,
                              size: UIUtils.iconSize(context, 20),
                            ),
                          )
                        : ElevatedButton(
                            focusNode: _joinFocusNode,
                            onPressed: _showSearchResults,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: UIUtils.primaryColor,
                              foregroundColor: UIUtils.onPrimaryColor,
                              padding: UIUtils.paddingSymmetric(
                                context,
                                horizontal: 12,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'Results',
                              style: TextStyle(
                                fontSize: UIUtils.fontSize(context, 14),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                  ],
                ),
                SizedBox(height: UIUtils.spacing(context, 8)),
                DropdownButtonFormField<int?>(
                  key: ValueKey(_selectedSubjectId),
                  focusNode: _subjectFocusNode,
                  initialValue: _selectedSubjectId,
                  isExpanded: true,
                  dropdownColor: UIUtils.cardColor,
                  style: TextStyle(
                    fontSize: UIUtils.fontSize(context, 16),
                    color: UIUtils.textColor,
                  ),
                  decoration: _fieldDecoration(
                    context,
                    label: 'Subject filter',
                    icon: Icons.filter_alt_outlined,
                  ),
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('All subjects'),
                    ),
                    ..._availableSubjects.map(
                      (entry) => DropdownMenuItem<int?>(
                        value: entry['subject_id'] as int,
                        child: Text('${entry['subject_name']}'),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedSubjectId = value);
                    TtsService.speak(
                      value == null
                          ? 'Showing all subjects. ${_sessionSummary()}'
                          : 'Subject filter selected. ${_sessionSummary()}',
                    );
                  },
                ),
                SizedBox(height: UIUtils.spacing(context, 8)),

                // Active sessions list: every session is a keypad stop.
                if (filtered.isEmpty)
                  Container(
                    padding: UIUtils.paddingAll(context, 12),
                    decoration: cardDecoration,
                    child: Text(
                      sessions.isEmpty
                          ? 'No live sessions right now. Press 1 to refresh.'
                          : 'No matching sessions. Clear the search or change the subject filter.',
                      style: TextStyle(
                        fontSize: UIUtils.fontSize(context, 16),
                        color: UIUtils.textColor,
                      ),
                    ),
                  )
                else
                  for (final s in filtered)
                    _buildSessionTile(context, s as Map),

                SizedBox(height: UIUtils.spacing(context, 12)),
                Semantics(
                  header: true,
                  child: Text(
                    'More',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: UIUtils.fontSize(context, 18),
                      color: UIUtils.textColor,
                    ),
                  ),
                ),
                SizedBox(height: UIUtils.spacing(context, 8)),
                _navButton(
                  context,
                  focusNode: _libraryFocusNode,
                  onPressed: _openOfflineAudioLibrary,
                  icon: Icons.library_music_rounded,
                  text: '3: Recorded Audio Library',
                ),
                _navButton(
                  context,
                  focusNode: _playlistsFocusNode,
                  onPressed: _openMyPlaylists,
                  icon: Icons.queue_music,
                  text: '4: My Playlists · Private',
                ),
                _navButton(
                  context,
                  focusNode: _quizzesFocusNode,
                  onPressed: _openQuizzes,
                  icon: Icons.quiz_outlined,
                  text: '5: Quizzes',
                ),
                _navButton(
                  context,
                  focusNode: _logoutFocusNode,
                  onPressed: _logout,
                  icon: Icons.logout,
                  text: '0: Log out',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSessionTile(BuildContext context, Map s) {
    final sessionId = _sessionIdOf(s);
    final title = '${s['title'] ?? 'Untitled session'}';
    final subject = s['subject_name']?.toString();
    final className = (s['class_name'] ?? _className)?.toString();
    final teacherName = s['teacher_name']?.toString() ?? 'Unknown';
    return AccessibleTile(
      focusNode: _sessionFocusNodes.putIfAbsent(
        sessionId,
        () => FocusNode(debugLabel: 'student-session-$sessionId'),
      ),
      title: title,
      status: 'Live now',
      statusColor: UIUtils.successColor,
      subtitle: [
        [
          if (subject != null && subject.isNotEmpty) subject,
          if (className != null && className.isNotEmpty) className,
        ].join(' · '),
        'Teacher: $teacherName',
        'Session $sessionId. OK to join',
      ].where((line) => line.isNotEmpty).join('\n'),
      semanticLabel: '${_sessionLabel(s)}. Join session',
      onActivate: () => joinSession(sessionId),
    );
  }
}
