import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../services/tts_service.dart';
import 'package:flutter/services.dart';
import 'session_screen.dart';
import 'audio_library_screen.dart';
import 'playlist_screens.dart';
import 'lesson_sequences_screen.dart';
import 'quiz_screens.dart';
import '../utils/ui_utils.dart';
import '../widgets/key_instruction_wrapper.dart';
import '../widgets/keypad_confirmation_dialog.dart';
import '../utils/keypad_actions.dart';
import '../services/auth_session_service.dart';
import '../utils/session_search.dart';
import '../widgets/keypad_paged_list.dart';
import '../widgets/accessible_tile.dart';

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
  String _status = '';
  // Spoken once with the screen help; later counts are announced directly so
  // the full help is not repeated on every refresh.
  String? _introduction;
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
  final _sequencesFocus = FocusNode(debugLabel: 'teacher-sequences');
  final FocusNode _quizzesFocusNode = FocusNode(debugLabel: 'teacher-quizzes');
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
      // The screen introduction reads the count once the dashboard appears.
      await _loadSessions(announce: false);
    }

    // data loading complete
    if (!mounted) return;
    setState(() {
      // spinner removed
      isLoading = false;
      if (_status.isEmpty && currentUserId != null) {
        _status = _sessionCountSummary();
      }
      _introduction = _status.isEmpty ? null : '$_status.';
    });
  }

  // Fetch active and ended sessions for this teacher.
  // [doneMessage] is spoken together with the new count so a completed
  // action is not cut off by the refresh announcement.
  Future<void> _loadSessions({
    String? doneMessage,
    bool announce = true,
  }) async {
    final previousFocus = FocusManager.instance.primaryFocus;
    if (mounted) setState(() => _isRefreshing = true);
    if (doneMessage == null && announce) {
      await TtsService.speak(
        'Refreshing sessions',
        priority: SpeechPriority.navigation,
      );
    }
    final result = await ApiService.getResult(
      '/sessions/active?include_ended=true',
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
        _status = _sessionCountSummary();
      });
      if (announce) {
        await TtsService.speak(
          doneMessage == null ? _status : '$doneMessage. $_status',
        );
      }
    } else {
      final message =
          '${result.failure!.message} Sessions were not refreshed. Press 1 to try again.';
      setState(() {
        _isRefreshing = false;
        _status = message;
      });
      await TtsService.speak(
        doneMessage == null ? message : '$doneMessage. $message',
        priority: SpeechPriority.critical,
      );
    }
    if (previousFocus != null && previousFocus.canRequestFocus) {
      previousFocus.requestFocus();
    }
  }

  // Funtion to create a new session by the teacher
  Future<void> createSession() async {
    // If user not logged in
    if (currentUserId == null || currentUserName == null) {
      TtsService.speak('Please log in first');
      _showSnack('Please log in first');
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
      builder: (context) => Center(
        child: Semantics(
          liveRegion: true,
          label: 'Creating session',
          child: const CircularProgressIndicator(),
        ),
      ),
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
      TtsService.speak(message, priority: SpeechPriority.critical);
      _showSnack(message);
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

  void _cycleWorkspace(int direction) {
    if (_workspaces.isEmpty) {
      TtsService.speak('No class and subject workspace is assigned');
      return;
    }
    final currentId = _selectedWorkspace?['assignment_id'];
    var current = _workspaces.indexWhere(
      (entry) => entry['assignment_id'] == currentId,
    );
    if (current < 0) current = 0;
    var next = (current + direction) % _workspaces.length;
    if (next < 0) next += _workspaces.length;
    setState(() {
      _selectedWorkspace = Map<String, dynamic>.from(_workspaces[next] as Map);
      _status = _sessionCountSummary();
    });
    TtsService.speak(
      '${_selectedWorkspace!['class_name']}, '
      '${_selectedWorkspace!['subject_name']} selected. $_status',
    );
  }

  Future<void> _chooseWorkspace() async {
    if (_workspaces.isEmpty) {
      await TtsService.speak('No class and subject workspace is assigned.');
      return;
    }
    final workspaces = _workspaces
        .map((entry) => Map<String, dynamic>.from(entry as Map))
        .toList();
    final selected = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (listContext) => KeypadPagedList<Map<String, dynamic>>(
          title: 'Choose class and subject',
          scope: (currentUserId, 'teacher-workspaces'),
          loadPage: (query) async {
            final matches = workspaces
                .where(
                  (entry) => '${entry['class_name']} ${entry['subject_name']}'
                      .toLowerCase()
                      .contains(query.search.trim().toLowerCase()),
                )
                .toList();
            final start = int.parse(query.cursor ?? '0');
            final end = (start + KeypadListQuery.pageSize).clamp(
              0,
              matches.length,
            );
            return KeypadListPage(
              items: matches.sublist(start, end),
              nextCursor: end < matches.length ? '$end' : null,
            );
          },
          labelOf: (entry) =>
              '${entry['class_name']}, ${entry['subject_name']}',
          onSelected: (entry) => Navigator.pop(listContext, entry),
        ),
      ),
    );
    if (!mounted || selected == null) return;
    setState(() {
      _selectedWorkspace = selected;
      _status = _sessionCountSummary();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _keypadController.focusAndAnnounce(
        _workspaceFocusNode,
        '${selected['class_name']}, ${selected['subject_name']} selected. '
        '$_status. Press 7 to choose another workspace.',
      );
    });
  }

  // Open offline audio library (no session context)
  void _openOfflineAudioLibrary() {
    TtsService.speak('Opening recorded audio library. Internet is required.');
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

  void _openSequences() {
    final workspace = _selectedWorkspace;
    if (workspace == null) {
      TtsService.speak('No class and subject workspace is assigned');
      return;
    }
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => LessonSequencesScreen(
          classId: workspace['class_id'] as int,
          subjectId: workspace['subject_id'] as int,
        ),
      ),
    );
  }

  void _openQuizzes() {
    final workspace = _selectedWorkspace;
    if (workspace == null) {
      TtsService.speak('No class and subject workspace is assigned');
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TeacherQuizScreen(
          classId: workspace['class_id'] as int,
          className: '${workspace['class_name']}',
          subjectId: workspace['subject_id'] as int,
          subjectName: '${workspace['subject_name']}',
        ),
      ),
    );
  }

  Future<void> _logout() => AuthSessionService.logoutFrom(context);

  /// Shows a visual-only message; callers speak the same text through
  /// TtsService, so screen readers must not read the SnackBar a second time.
  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: ExcludeSemantics(child: Text(message))));
  }

  List get _workspaceSessions {
    final workspace = _selectedWorkspace;
    if (workspace == null) return const [];
    return sessions
        .where(
          (session) =>
              session['class_id'] == workspace['class_id'] &&
              session['subject_id'] == workspace['subject_id'],
        )
        .toList();
  }

  String _sessionCountSummary() {
    final all = _workspaceSessions;
    if (all.isEmpty) return 'No sessions yet. Press 2 to create one';
    final live = all.where((s) => s['is_active'] == true).length;
    return '${all.length} ${all.length == 1 ? 'session' : 'sessions'}'
        '${live > 0 ? ', $live live now' : ''}';
  }

  static final _digitsOnly = RegExp(r'^\d+$');

  /// Name or session-number search. Keypad users often type only digits, so
  /// a digit-only query lists the exact session number first, then numbers
  /// that start with or contain those digits, then title matches.
  List get _filteredSessions {
    final query = _searchController.text.trim();
    final matches = filterSessionsByNameOrId(_workspaceSessions, query);
    if (!_digitsOnly.hasMatch(query)) return matches;
    int rank(dynamic session) {
      final id = '${session['session_id'] ?? ''}';
      if (id == query) return 0;
      if (id.startsWith(query)) return 1;
      if (id.contains(query)) return 2;
      return 3;
    }

    final indexed = matches.asMap().entries.toList()
      ..sort((a, b) {
        final byRank = rank(a.value).compareTo(rank(b.value));
        return byRank != 0 ? byRank : a.key.compareTo(b.key);
      });
    return indexed.map((entry) => entry.value).toList();
  }

  String _sessionLabel(dynamic session) {
    final id = session['session_id'];
    final title = '${session['title'] ?? 'Untitled session'}';
    final place = [
      session['class_name'],
      session['subject_name'],
    ].where((part) => part != null && '$part'.isNotEmpty).join(', ');
    final joined = session['participant_count'];
    final isActive = session['is_active'] == true;
    return [
          title,
          if (place.isNotEmpty) place,
          if (isActive) 'live now' else 'ended',
          if (isActive && joined is int) '$joined joined',
          'session number $id',
        ].join(', ') +
        (isActive ? '. Press OK to open' : '. Press OK to reactivate');
  }

  void _focusSessionSearch() {
    _keypadController.exitTextEditing();
    _searchFocusNode.requestFocus();
    TtsService.speak(
      'Session search. Press OK to edit, then type a session name, or the '
      'session number using the number keys. '
      'Use up or down to leave the field and browse results.',
    );
  }

  void _showSearchResults() {
    _keypadController.exitTextEditing();
    FocusScope.of(context).unfocus();
    final results = _filteredSessions;
    final query = _searchController.text.trim();
    final message = results.isEmpty
        ? 'No sessions match $query. Clear the search to list all sessions.'
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
        node: _logoutFocusNode,
        label: 'Log out, asks to confirm',
        onActivate: _logout,
      ),
      KeypadFocusTarget(
        node: _workspaceFocusNode,
        label: _selectedWorkspace == null
            ? 'No class and subject workspace assigned'
            : 'Workspace ${_selectedWorkspace!['class_name']}, ${_selectedWorkspace!['subject_name']}. Press OK or 7 to choose from numbered assignments',
        onActivate: _chooseWorkspace,
        onDecrease: () => _cycleWorkspace(-1),
        onIncrease: () => _cycleWorkspace(1),
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
        node: _sequencesFocus,
        label: 'Reusable teacher lesson sequences',
        onActivate: _openSequences,
      ),
      KeypadFocusTarget(
        node: _quizzesFocusNode,
        label: 'Quizzes and private question bank',
        onActivate: _openQuizzes,
      ),
      KeypadFocusTarget(
        node: _libraryFocusNode,
        label: 'Offline audio library',
        onActivate: _openOfflineAudioLibrary,
      ),
      KeypadFocusTarget(
        node: _searchFocusNode,
        label:
            'Search sessions. Press OK, then type a name or the session number',
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
      final title = '${session['title'] ?? 'session'}';
      final isActive = session['is_active'] == true;
      targets.add(
        KeypadFocusTarget(
          node: _sessionOpenFocusNodes.putIfAbsent(
            id,
            () => FocusNode(debugLabel: 'teacher-open-$id'),
          ),
          label: _sessionLabel(session),
          onActivate: isActive
              ? () => _openSession(id)
              : () => _reactivateSession(id, title),
        ),
      );
      targets.add(
        KeypadFocusTarget(
          node: _sessionDeleteFocusNodes.putIfAbsent(
            id,
            () => FocusNode(
              debugLabel: isActive ? 'teacher-end-$id' : 'teacher-delete-$id',
            ),
          ),
          label: isActive
              ? 'End $title for everyone, asks to confirm'
              : 'Delete ended session $title permanently, asks to confirm',
          onActivate: isActive
              ? () => _endSession(id, title)
              : () => _permanentlyDeleteSession(id, title),
        ),
      );
    }
    return targets;
  }

  Future<void> _endSession(int sessionId, String title) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => KeypadConfirmationDialog(
        title: 'End session for everyone?',
        message:
            'End "$title" and close it for every participant? The session will remain in your dashboard history.',
        cancelLabel: 'Keep session open',
        confirmLabel: 'End for everyone',
        cancelKey: 0,
        confirmKey: 1,
      ),
    );

    if (confirmed != true) return;

    final ended = await ApiService.endSession(sessionId);

    if (ended) {
      await _loadSessions(
        doneMessage: 'Session ended for everyone and kept in session history',
      );
      _showSnack('Session ended and retained in history');
    } else {
      const message = 'The session could not be ended. Please try again.';
      TtsService.speak(message, priority: SpeechPriority.critical);
      _showSnack(message);
    }
  }

  Future<void> _reactivateSession(int sessionId, String title) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => KeypadConfirmationDialog(
        title: 'Reactivate session?',
        message: 'Reactivate "$title" so participants can join it again?',
        cancelLabel: 'Keep ended',
        confirmLabel: 'Reactivate',
        cancelKey: 0,
        confirmKey: 1,
      ),
    );
    if (confirmed != true) return;

    final reactivated = await ApiService.reactivateSession(sessionId);
    if (!reactivated) {
      const message = 'The session could not be reactivated. Please try again.';
      await TtsService.speak(message, priority: SpeechPriority.critical);
      _showSnack(message);
      return;
    }

    await _loadSessions(doneMessage: 'Session reactivated');
    if (!mounted) return;
    final openNow = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => KeypadConfirmationDialog(
        title: 'Open session now?',
        message:
            '"$title" is active again. Open it now, or return to it later from the dashboard.',
        cancelLabel: 'Open later',
        confirmLabel: 'Open now',
        cancelKey: 0,
        confirmKey: 1,
      ),
    );
    if (openNow == true && mounted) _openSession(sessionId);
  }

  Future<void> _permanentlyDeleteSession(int sessionId, String title) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => KeypadConfirmationDialog(
        title: 'Permanently delete session?',
        message:
            'Permanently delete "$title", including its participants, chat, and logs? This cannot be undone.',
        cancelLabel: 'Keep session',
        confirmLabel: 'Delete permanently',
        cancelKey: 0,
        confirmKey: 1,
      ),
    );
    if (confirmed != true) return;

    final deleted = await ApiService.permanentlyDeleteSession(sessionId);
    final message = deleted
        ? 'Session permanently deleted'
        : 'The session could not be deleted. Please try again.';
    if (deleted) {
      await _loadSessions(doneMessage: message);
    } else {
      await TtsService.speak(message, priority: SpeechPriority.critical);
    }
    if (!mounted) return;
    _showSnack(message);
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
    _sequencesFocus.dispose();
    _quizzesFocusNode.dispose();
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
      introduction: _introduction,
      navigationSections:
          'class and subject selection, teaching tools, session search, and active or ended sessions',
      labels: teacherDashboardKeyLabels,
      actions: {
        0: _logout,
        1: _loadSessions,
        2: createSession,
        3: _openOfflineAudioLibrary,
        4: _focusSessionSearch,
        5: _openPlaylists,
        6: _openQuizzes,
        7: _chooseWorkspace,
        8: _openSequences,
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
        title: UIUtils.useStackedLayout(context)
            ? null
            : Text(
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
                child: Semantics(
                  label: 'Signed in as ${currentUserName!}',
                  excludeSemantics: true,
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
            ),

          IconButton(
            focusNode: _refreshFocusNode,
            icon: Icon(
              Icons.refresh_rounded,
              size: UIUtils.iconSize(context, 22),
              color: UIUtils.accentColor,
            ),
            tooltip: '1: Refresh sessions',
            onPressed: _loadSessions,
          ),
          IconButton(
            focusNode: _logoutFocusNode,
            tooltip: '0: Log out',
            onPressed: _logout,
            icon: Icon(Icons.logout, color: UIUtils.accentColor),
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
                if (UIUtils.useStackedLayout(context))
                  Semantics(
                    header: true,
                    child: Text(
                      'Teacher Dashboard',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
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
                    side: BorderSide(color: UIUtils.cardBorderColor),
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
                              fontSize: UIUtils.fontSize(context, 14),
                              color: UIUtils.subtextColor,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                SizedBox(height: UIUtils.spacing(context, 12)),

                OutlinedButton.icon(
                  focusNode: _workspaceFocusNode,
                  icon: const Icon(Icons.workspaces_outline),
                  label: Text(
                    _selectedWorkspace == null
                        ? '7: Choose class and subject workspace'
                        : '7: ${_selectedWorkspace!['class_name']}, ${_selectedWorkspace!['subject_name']}. Change workspace',
                  ),
                  onPressed: _chooseWorkspace,
                ),

                SizedBox(height: UIUtils.spacing(context, 8)),

                OutlinedButton.icon(
                  focusNode: _playlistsFocusNode,
                  onPressed: _openPlaylists,
                  icon: const Icon(Icons.playlist_play),
                  label: const Text('5: Class Playlists'),
                ),
                OutlinedButton.icon(
                  focusNode: _sequencesFocus,
                  onPressed: _openSequences,
                  icon: const Icon(Icons.format_list_numbered),
                  label: const Text('8: Lesson plans'),
                ),

                SizedBox(height: UIUtils.spacing(context, 8)),

                OutlinedButton.icon(
                  focusNode: _quizzesFocusNode,
                  onPressed: _openQuizzes,
                  icon: const Icon(Icons.quiz_outlined),
                  label: const Text('6: Quizzes & Question Bank'),
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
                    foregroundColor: UIUtils.onPrimaryColor,
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
                    '3: Recorded Audio Library',
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: UIUtils.cardBorderColor),
                  ),
                  child: Padding(
                    padding: UIUtils.paddingAll(context, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
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
                            label: Text('4: Search by name or number'),
                            prefixIcon: ExcludeSemantics(
                              child: Icon(Icons.search),
                            ),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: UIUtils.spacing(context, 4)),
                        Text(
                          'Type a session name, or the session number with '
                          'the number keys. Leave empty to list all.',
                          style: TextStyle(
                            fontSize: UIUtils.fontSize(context, 14),
                            color: UIUtils.subtextColor,
                          ),
                        ),
                        SizedBox(height: UIUtils.spacing(context, 8)),
                        OutlinedButton.icon(
                          focusNode: _searchResultsFocusNode,
                          onPressed: _showSearchResults,
                          icon: const Icon(Icons.manage_search),
                          label: const Text('Show matching sessions'),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: UIUtils.spacing(context, 12)),

                // Sessions Header
                Semantics(
                  header: true,
                  label: _filteredSessions.isEmpty
                      ? 'Your sessions'
                      : 'Your sessions, ${_filteredSessions.length}',
                  excludeSemantics: true,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Your Sessions",
                          style: TextStyle(
                            fontSize: UIUtils.fontSize(context, 18),
                            fontWeight: FontWeight.bold,
                            color: UIUtils.textColor,
                          ),
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
                            color: UIUtils.accentColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${_filteredSessions.length}',
                            style: TextStyle(
                              color: UIUtils.onAccentColor,
                              fontWeight: FontWeight.bold,
                              fontSize: UIUtils.fontSize(context, 14),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                if (_status.isNotEmpty)
                  Semantics(
                    liveRegion: true,
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: UIUtils.spacing(context, 4),
                      ),
                      child: Text(
                        _status,
                        style: TextStyle(
                          fontSize: UIUtils.fontSize(context, 16),
                          color: UIUtils.subtextColor,
                        ),
                      ),
                    ),
                  ),

                SizedBox(height: UIUtils.spacing(context, 8)),

                // Sessions List
                if (_filteredSessions.isEmpty)
                  Padding(
                    padding: UIUtils.paddingAll(context, 16),
                    child: Column(
                      children: [
                        ExcludeSemantics(
                          child: Icon(
                            Icons.school_outlined,
                            size: UIUtils.iconSize(context, 48),
                            color: UIUtils.subtextColor,
                          ),
                        ),
                        SizedBox(height: UIUtils.spacing(context, 10)),
                        Text(
                          _searchController.text.trim().isEmpty
                              ? 'No sessions yet. Press 2 to create one.'
                              : 'No matching sessions. Clear the search to '
                                    'list all sessions.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: UIUtils.fontSize(context, 16),
                            color: UIUtils.textColor,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ..._filteredSessions.map((s) {
                    final sessionId =
                        int.tryParse('${s['session_id'] ?? ''}') ?? 0;
                    final title = '${s['title'] ?? 'Untitled Session'}';
                    final isActive = s['is_active'] == true;
                    final joined = s['participant_count'];
                    final place = [
                      s['class_name'],
                      s['subject_name'],
                    ].where((part) => part != null).join(', ');
                    final endLabel = isActive
                        ? 'End $title for everyone'
                        : 'Delete $title permanently';

                    return AccessibleTile(
                      focusNode: _sessionOpenFocusNodes.putIfAbsent(
                        sessionId,
                        () => FocusNode(debugLabel: 'teacher-open-$sessionId'),
                      ),
                      title: title,
                      status: isActive
                          ? 'Live now${joined is int ? ', $joined joined' : ''}'
                          : 'Ended',
                      statusColor: isActive
                          ? UIUtils.successColor
                          : UIUtils.subtextColor,
                      subtitle:
                          '${place.isEmpty ? '' : '$place. '}Session number $sessionId',
                      semanticLabel: _sessionLabel(s),
                      onActivate: isActive
                          ? () => _openSession(sessionId)
                          : () => _reactivateSession(sessionId, title),
                      trailing: Align(
                        alignment: Alignment.centerLeft,
                        child: Semantics(
                          button: true,
                          label: endLabel,
                          excludeSemantics: true,
                          child: OutlinedButton.icon(
                            focusNode: _sessionDeleteFocusNodes.putIfAbsent(
                              sessionId,
                              () => FocusNode(
                                debugLabel: isActive
                                    ? 'teacher-end-$sessionId'
                                    : 'teacher-delete-$sessionId',
                              ),
                            ),
                            onPressed: isActive
                                ? () => _endSession(sessionId, title)
                                : () => _permanentlyDeleteSession(
                                    sessionId,
                                    title,
                                  ),
                            icon: Icon(
                              isActive
                                  ? Icons.stop_circle_outlined
                                  : Icons.delete_forever,
                            ),
                            label: Text(
                              isActive ? 'End for everyone' : 'Delete',
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: UIUtils.errorColor,
                              side: BorderSide(color: UIUtils.errorColor),
                              textStyle: TextStyle(
                                fontSize: UIUtils.fontSize(context, 14),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),

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
