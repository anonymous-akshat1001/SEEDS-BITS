import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../services/tts_service.dart';
import 'package:flutter/services.dart';
import 'session_screen.dart';
import '../announcers/announce.dart';
import '../announcers/dashboard_text.dart';
import '../services/feedback_cues.dart';
import '../services/message_center.dart';
import 'audio_library_screen.dart';
import 'playlist_screens.dart';
import 'journeys/teacher_journeys_screen.dart';
import 'quiz_screens.dart';
import '../utils/ui_utils.dart';
import '../widgets/key_instruction_wrapper.dart';
import '../widgets/keypad_confirmation_dialog.dart';
import '../utils/keypad_actions.dart';
import '../services/auth_session_service.dart';
import '../utils/session_search.dart';
import '../widgets/keypad_paged_list.dart';
import '../widgets/accessible_tile.dart';
import '../l10n/speech.dart';

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
  final _journeysFocus = FocusNode(debugLabel: 'teacher-journeys');
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
        Speech.t.teacherHomeFallbackName('$id');

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
        DashboardText.refreshing,
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
        if (doneMessage == null) {
          await TtsService.speak(_status);
        } else {
          MessageCenter.success(DashboardText.withDone(doneMessage, _status));
        }
      }
    } else {
      final message = DashboardText.notRefreshed(result.failure!.message);
      setState(() {
        _isRefreshing = false;
        _status = message;
      });
      MessageCenter.error(DashboardText.withDone(doneMessage, message));
    }
    if (previousFocus != null && previousFocus.canRequestFocus) {
      previousFocus.requestFocus();
    }
  }

  // Funtion to create a new session by the teacher
  Future<void> createSession() async {
    // If user not logged in
    if (currentUserId == null || currentUserName == null) {
      MessageCenter.error(CommonText.signInFirst);
      // stop execution
      return;
    }
    final workspace = _selectedWorkspace;
    if (workspace == null) {
      MessageCenter.error(DashboardText.noAssignment);
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
          label: DashboardText.creatingSession,
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
      MessageCenter.success(DashboardText.created(title));

      // Ask if they want to start the session now
      if (mounted) {
        final startNow = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (_) => KeypadConfirmationDialog(
            title: DashboardText.createdTitle,
            message: DashboardText.startNow(title),
            cancelLabel: Speech.t.teacherHomeLater,
            confirmLabel: Speech.t.teacherHomeStartNow,
            cancelKey: 0,
            confirmKey: 1,
          ),
        );

        if (startNow == true) {
          _openSession(res['session_id']);
        }
      }
    } else {
      MessageCenter.error(
        result.failure?.message ?? DashboardText.requestFailed,
      );
    }
  }

  void _openSession(int sessionId) {
    if (currentUserId == null || currentUserName == null) {
      MessageCenter.error(CommonText.signInFirst);
      return;
    }

    // Find the session title from the sessions list
    String sessionTitle = Speech.t.sessionDefaultTitle;
    String? className;
    String? subjectName;
    for (final s in sessions) {
      if (s['session_id'] == sessionId) {
        sessionTitle = s['title'] ?? Speech.t.sessionDefaultTitle;
        className = s['class_name']?.toString();
        subjectName = s['subject_name']?.toString();
        break;
      }
    }

    TtsService.speak(DashboardText.openingSession);

    // opens new screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TeacherSessionScreen(
          sessionId: sessionId,
          userId: currentUserId!, // the ! claims that these fields are not null
          userName: currentUserName!,
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
      MessageCenter.error(DashboardText.noAssignment);
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
      DashboardText.workspaceSelected(
        _workspaceName!,
        next,
        _workspaces.length,
        _status,
      ),
    );
  }

  Future<void> _chooseWorkspace() async {
    if (_workspaces.isEmpty) {
      MessageCenter.error(DashboardText.noAssignment);
      return;
    }
    final workspaces = _workspaces
        .map((entry) => Map<String, dynamic>.from(entry as Map))
        .toList();
    final selected = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (listContext) => KeypadPagedList<Map<String, dynamic>>(
          title: Speech.t.teacherHomeChooseWorkspaceTitle,
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
          labelOf: (entry) => Speech.t.teacherHomeWorkspaceItem(
            '${entry['class_name']}',
            '${entry['subject_name']}',
          ),
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
        Speech.t.teacherHomeWorkspaceChosen(
          '${selected['class_name']}',
          '${selected['subject_name']}',
          _status,
        ),
      );
    });
  }

  // Open offline audio library (no session context)
  void _openOfflineAudioLibrary() {
    TtsService.speak(DashboardText.openingLibrary());
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
      MessageCenter.error(DashboardText.noAssignment);
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

  void _openJourneys() {
    final workspace = _selectedWorkspace;
    if (workspace == null) {
      MessageCenter.error(DashboardText.noAssignment);
      return;
    }
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => TeacherJourneysScreen(
          classId: workspace['class_id'] as int,
          subjectId: workspace['subject_id'] as int,
          workspaceName: Speech.t.teacherHomeWorkspaceItem(
            '${workspace['class_name']}',
            '${workspace['subject_name']}',
          ),
        ),
      ),
    );
  }

  void _openQuizzes() {
    final workspace = _selectedWorkspace;
    if (workspace == null) {
      MessageCenter.error(DashboardText.noAssignment);
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

  String? get _workspaceName {
    final workspace = _selectedWorkspace;
    return workspace == null
        ? null
        : DashboardText.workspace(
            '${workspace['class_name']}',
            '${workspace['subject_name']}',
          );
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
    if (all.isEmpty) return DashboardText.noSessionsYet;
    final live = all.where((s) => s['is_active'] == true).length;
    return DashboardText.teacherCount(all.length, live);
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
    final title = '${session['title'] ?? Speech.t.teacherHomeUntitledSession}';
    final place = [
      session['class_name'],
      session['subject_name'],
    ].where((part) => part != null && '$part'.isNotEmpty).join(', ');
    return DashboardText.teacherSession(
      title: title,
      place: place,
      active: session['is_active'] == true,
      joined: session['participant_count'],
      id: id is int ? id : int.tryParse('$id') ?? 0,
    );
  }

  void _focusSessionSearch() {
    _keypadController.exitTextEditing();
    _searchFocusNode.requestFocus();
    TtsService.speak(DashboardText.teacherSearchHelp);
  }

  void _showSearchResults() {
    _keypadController.exitTextEditing();
    FocusScope.of(context).unfocus();
    final results = _filteredSessions;
    final query = _searchController.text.trim();
    final message = results.isEmpty
        ? DashboardText.teacherNoMatch(query)
        : query.isEmpty
        ? DashboardText.showingAll(results.length)
        : DashboardText.nameMatches(results.length, query);
    final first = results.isEmpty
        ? null
        : int.tryParse((results.first['session_id'] ?? '').toString());
    if (first == null) {
      TtsService.speak(message);
      return;
    }
    // Focus moves to the first result; its label must not cut off the
    // result message, so both are one announcement.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final node = _sessionOpenFocusNodes[first];
      if (!mounted || node == null) {
        TtsService.speak(message);
        return;
      }
      _keypadController.focusAndAnnounce(node, message);
    });
  }

  List<KeypadFocusTarget> _dashboardFocusTargets() {
    final targets = <KeypadFocusTarget>[
      KeypadFocusTarget(
        node: _refreshFocusNode,
        label: DashboardText.refresh,
        onActivate: _loadSessions,
        isEnabled: () => !_isRefreshing,
      ),
      KeypadFocusTarget(
        node: _logoutFocusNode,
        label: DashboardText.logout,
        onActivate: _logout,
      ),
      KeypadFocusTarget(
        node: _workspaceFocusNode,
        label: DashboardText.workspaceLabel(
          _workspaceName,
          _workspaces
              .indexWhere(
                (entry) =>
                    entry['assignment_id'] ==
                    _selectedWorkspace?['assignment_id'],
              )
              .clamp(0, _workspaces.length),
          _workspaces.length,
        ),
        onActivate: _chooseWorkspace,
        onDecrease: () => _cycleWorkspace(-1),
        onIncrease: () => _cycleWorkspace(1),
      ),
      KeypadFocusTarget(
        node: _createFocusNode,
        label: DashboardText.create,
        onActivate: createSession,
      ),
      KeypadFocusTarget(
        node: _playlistsFocusNode,
        label: DashboardText.classPlaylists,
        onActivate: _openPlaylists,
      ),
      KeypadFocusTarget(
        node: _journeysFocus,
        label: DashboardText.teacherJourneys,
        onActivate: _openJourneys,
      ),
      KeypadFocusTarget(
        node: _quizzesFocusNode,
        label: DashboardText.teacherQuizzes,
        onActivate: _openQuizzes,
      ),
      KeypadFocusTarget(
        node: _libraryFocusNode,
        label: DashboardText.offlineLibrary,
        onActivate: _openOfflineAudioLibrary,
      ),
      KeypadFocusTarget(
        node: _searchFocusNode,
        label: Speech.t.teacherHomeSearchLabel,
        isTextField: true,
      ),
      KeypadFocusTarget(
        node: _searchResultsFocusNode,
        label: DashboardText.showMatching,
        onActivate: _showSearchResults,
      ),
    ];
    for (final session in _filteredSessions) {
      final id = int.tryParse((session['session_id'] ?? '').toString()) ?? 0;
      final title =
          '${session['title'] ?? Speech.t.teacherHomeSessionFallback}';
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
              ? DashboardText.endLabel(title)
              : DashboardText.deleteLabel(title),
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
        title: DashboardText.endTitle,
        message: DashboardText.endMessage(title),
        cancelLabel: Speech.t.teacherHomeKeepSessionOpen,
        confirmLabel: Speech.t.teacherHomeEndForEveryone,
        cancelKey: 0,
        confirmKey: 1,
      ),
    );

    if (confirmed != true) return;

    final ended = await ApiService.endSession(sessionId);

    if (ended) {
      unawaited(FeedbackCues.play(Cue.leave));
      await _loadSessions(doneMessage: DashboardText.ended);
    } else {
      MessageCenter.error(DashboardText.endFailed);
    }
  }

  Future<void> _reactivateSession(int sessionId, String title) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => KeypadConfirmationDialog(
        title: DashboardText.reactivateTitle,
        message: DashboardText.reactivateMessage(title),
        cancelLabel: Speech.t.teacherHomeKeepEnded,
        confirmLabel: Speech.t.teacherHomeReactivate,
        cancelKey: 0,
        confirmKey: 1,
      ),
    );
    if (confirmed != true) return;

    final reactivated = await ApiService.reactivateSession(sessionId);
    if (!reactivated) {
      MessageCenter.error(DashboardText.reactivateFailed);
      return;
    }

    await _loadSessions(doneMessage: DashboardText.reactivated);
    if (!mounted) return;
    final openNow = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => KeypadConfirmationDialog(
        title: DashboardText.openNowTitle,
        message: DashboardText.openNowMessage(title),
        cancelLabel: Speech.t.teacherHomeOpenLater,
        confirmLabel: Speech.t.teacherHomeOpenNow,
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
        title: DashboardText.deleteTitle,
        message: DashboardText.deleteMessage(title),
        cancelLabel: Speech.t.teacherHomeKeepSession,
        confirmLabel: Speech.t.teacherHomeDeletePermanently,
        cancelKey: 0,
        confirmKey: 1,
      ),
    );
    if (confirmed != true) return;

    final deleted = await ApiService.permanentlyDeleteSession(sessionId);
    if (deleted) {
      await _loadSessions(doneMessage: DashboardText.deleted);
    } else {
      MessageCenter.error(DashboardText.deleteFailed);
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
    _journeysFocus.dispose();
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
              label: DashboardText.teacherLoading,
              child: const CircularProgressIndicator(),
            ),
          ),
        ),
      );
    }

    return KeypadInstructionWrapper(
      screenName: DashboardText.teacherScreen,
      introduction: _introduction,
      navigationSections: DashboardText.teacherSections,
      stateSummary: () => DashboardText.teacherState(
        workspace: _workspaceName,
        all: _workspaceSessions.length,
        live: _workspaceSessions.where((s) => s['is_active'] == true).length,
        search: _searchController.text.trim(),
        refreshing: _isRefreshing,
      ),
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
        8: _openJourneys,
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
                Speech.t.dashboardTeacherScreen,
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
                  label: Speech.t.dashboardSignedInAs(currentUserName!),
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
            tooltip: Speech.t.dashboardRefreshSessionsKey1,
            onPressed: _loadSessions,
          ),
          IconButton(
            focusNode: _logoutFocusNode,
            tooltip: Speech.t.dashboardLogOutKey0,
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
                      Speech.t.dashboardTeacherScreen,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                if (_isRefreshing) ...[
                  Semantics(
                    liveRegion: true,
                    label: Speech.t.dashboardRefreshingSessions,
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
                          Speech.t.teacherHomeWelcome(
                            currentUserName ?? Speech.t.authRoleTeacher,
                          ),
                          style: TextStyle(
                            fontSize: UIUtils.fontSize(context, 20),
                            fontWeight: FontWeight.w700,
                            color: UIUtils.textColor,
                          ),
                        ),
                        if (!tiny) ...[
                          SizedBox(height: UIUtils.spacing(context, 4)),
                          Text(
                            Speech.t.teacherHomeTagline,
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
                        ? Speech.t.teacherHomeChooseWorkspaceKey7
                        : Speech.t.teacherHomeChangeWorkspaceKey7(
                            '${_selectedWorkspace!['class_name']}',
                            '${_selectedWorkspace!['subject_name']}',
                          ),
                  ),
                  onPressed: _chooseWorkspace,
                ),

                SizedBox(height: UIUtils.spacing(context, 8)),

                OutlinedButton.icon(
                  focusNode: _playlistsFocusNode,
                  onPressed: _openPlaylists,
                  icon: const Icon(Icons.playlist_play),
                  label: Text(Speech.t.teacherHomePlaylistsKey5),
                ),
                OutlinedButton.icon(
                  focusNode: _journeysFocus,
                  onPressed: _openJourneys,
                  icon: const Icon(Icons.format_list_numbered),
                  label: Text(Speech.t.teacherHomeJourneysKey8),
                ),

                SizedBox(height: UIUtils.spacing(context, 8)),

                OutlinedButton.icon(
                  focusNode: _quizzesFocusNode,
                  onPressed: _openQuizzes,
                  icon: const Icon(Icons.quiz_outlined),
                  label: Text(Speech.t.teacherHomeQuizzesKey6),
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
                    Speech.t.teacherHomeCreateSessionKey2,
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
                    Speech.t.dashboardAudioLibraryKey3,
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
                          decoration: InputDecoration(
                            label: Text(Speech.t.teacherHomeSearchKey4),
                            prefixIcon: ExcludeSemantics(
                              child: Icon(Icons.search),
                            ),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: UIUtils.spacing(context, 4)),
                        Text(
                          Speech.t.teacherHomeSearchHint,
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
                          label: Text(Speech.t.dashboardShowMatching),
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
                      ? Speech.t.teacherHomeYourSessions
                      : Speech.t.teacherHomeYourSessionsCount(
                          '${_filteredSessions.length}',
                        ),
                  excludeSemantics: true,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          Speech.t.teacherHomeYourSessionsHeading,
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
                              ? Speech.t.teacherHomeNoSessions
                              : Speech.t.teacherHomeNoMatches,
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
                    final title =
                        '${s['title'] ?? Speech.t.teacherHomeUntitledSessionTitle}';
                    final isActive = s['is_active'] == true;
                    final joined = s['participant_count'];
                    final place = [
                      s['class_name'],
                      s['subject_name'],
                    ].where((part) => part != null).join(', ');
                    final endLabel = isActive
                        ? Speech.t.teacherHomeEndTitleForEveryone(title)
                        : Speech.t.teacherHomeDeleteTitlePermanently(title);

                    return AccessibleTile(
                      focusNode: _sessionOpenFocusNodes.putIfAbsent(
                        sessionId,
                        () => FocusNode(debugLabel: 'teacher-open-$sessionId'),
                      ),
                      title: title,
                      status: isActive
                          ? (joined is int
                                ? Speech.t.teacherHomeLiveJoined('$joined')
                                : Speech.t.dashboardLiveNow)
                          : Speech.t.dashboardEnded,
                      statusColor: isActive
                          ? UIUtils.successColor
                          : UIUtils.subtextColor,
                      subtitle: place.isEmpty
                          ? Speech.t.teacherHomeSessionNumber('$sessionId')
                          : Speech.t.teacherHomePlaceSessionNumber(
                              place,
                              '$sessionId',
                            ),
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
                              isActive
                                  ? Speech.t.sessionEndConfirm
                                  : Speech.t.teacherHomeDelete,
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
    Navigator.pop(
      context,
      title.isEmpty ? Speech.t.teacherHomeNewSessionTitle : title,
    );
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
      screenName: Speech.t.teacherHomeCreateScreen,
      labels: {0: Speech.t.uiCancel, 1: Speech.t.teacherHomeCreateSessionKey},
      actions: {0: () => Navigator.pop(context), 1: _create},
      navigationController: _keypadController,
      focusTargets: [
        KeypadFocusTarget(
          node: _titleFocus,
          label: Speech.t.teacherHomeTitleField,
          isTextField: true,
        ),
        KeypadFocusTarget(
          node: _cancelFocus,
          label: Speech.t.teacherHomeCancelCreate,
          onActivate: () => Navigator.pop(context),
        ),
        KeypadFocusTarget(
          node: _createFocus,
          label: Speech.t.teacherHomeCreateSessionKey,
          onActivate: _create,
        ),
      ],
      child: AlertDialog(
        title: Text(Speech.t.dashboardCreate),
        content: TextField(
          controller: _titleController,
          focusNode: _titleFocus,
          decoration: InputDecoration(
            labelText: Speech.t.teacherHomeSessionTitleField,
            hintText: Speech.t.teacherHomeSessionTitleHint,
            border: OutlineInputBorder(),
          ),
          onTap: () => _keypadController.enterTextEditing(_titleFocus),
          onSubmitted: (_) => _create(),
        ),
        actions: [
          TextButton(
            focusNode: _cancelFocus,
            onPressed: () => Navigator.pop(context),
            child: Text(Speech.t.libraryCancelKey0Button),
          ),
          ElevatedButton(
            focusNode: _createFocus,
            onPressed: _create,
            child: Text(Speech.t.teacherHomeCreateKey1),
          ),
        ],
      ),
    );
  }
}
