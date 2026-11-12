import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../services/tts_service.dart';
import '../announcers/announce.dart';
import '../announcers/dashboard_text.dart';
import '../services/feedback_cues.dart';
import '../services/message_center.dart';
import '../widgets/keypad_choice_field.dart';
import 'session_screen.dart';
import 'audio_library_screen.dart';
import 'playlist_screens.dart';
import 'quiz_screens.dart';
import 'journeys/student_journeys_screen.dart';
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
  final FocusNode _journeysFocusNode = FocusNode(debugLabel: 'student-journeys');
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
    if (sessions.isEmpty) return DashboardText.noLiveSessions;
    if (count == 0) return DashboardText.noFilterMatch;
    return DashboardText.available(count);
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
    if (announce) await TtsService.speak(DashboardText.refreshing);
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
        _statusMessage = DashboardText.refreshFailed(result.failure!.message);
        _statusIsError = true;
      });
      if (announce) MessageCenter.error(_statusMessage!);
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
      _showStatus(CommonText.signInFirst, error: true);
      return;
    }

    if (currentUserName == null) {
      _showStatus(CommonText.accountChanged, error: true);
      return;
    }

    try {
      await TtsService.speak(DashboardText.joining);
      final result = await ApiService.joinSessionResult(sessionId);
      if (result.isSuccess) {
        unawaited(FeedbackCues.play(Cue.ok));
        TtsService.speak(DashboardText.joined(sessionId));

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
              builder: (_) => StudentSessionScreen(
                sessionId: sessionId,
                userId: currentUserId!,
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
    _journeysFocusNode.dispose();
    for (final node in _sessionFocusNodes.values) {
      node.dispose();
    }
    // calls parent dispose class
    super.dispose();
  }

  // Open offline audio library (no session context)
  void _openOfflineAudioLibrary() {
    TtsService.speak(DashboardText.openingLibrary());
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const OfflineAudioLibraryScreen()),
    );
  }

  void _openMyPlaylists() {
    TtsService.speak(DashboardText.openingPlaylists);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const StudentPlaylistsScreen()),
    );
  }

  void _openQuizzes() {
    TtsService.speak(DashboardText.openingQuizzes());
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const StudentQuizScreen()),
    );
  }

  void _openJourneys() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const StudentJourneysScreen()),
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

  /// Typing only updates the field. Searching happens when the user chooses
  /// Show matching sessions; nothing happens just because typing paused.
  void _onSessionIdChanged(String _) => setState(() {});

  void _showSearchResults() {
    _keypadController.exitTextEditing();
    FocusScope.of(context).unfocus();
    final results = _filteredSessions;
    final query = sessionCtrl.text.trim();
    final id = _sessionIdCtrl.text.trim();
    final message = id.isNotEmpty
        ? results.isEmpty
              ? DashboardText.noSessionNumber(id)
              : DashboardText.found(_sessionLabel(results.first as Map))
        : results.isEmpty
        ? DashboardText.noNameMatch(query)
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
      final node = _sessionFocusNodes[first];
      if (!mounted || node == null) {
        TtsService.speak(message);
        return;
      }
      _keypadController.focusAndAnnounce(node, message);
    });
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
    TtsService.speak(
      DashboardText.subjectFilterChanged(
        _subjectName(ids[next]),
        next,
        ids.length,
        _sessionSummary(),
      ),
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
    return DashboardText.studentSession(
      title: title,
      subject: subject,
      className: className,
      teacher: teacher,
      id: _sessionIdOf(session),
    );
  }

  String? _subjectName(int? id) => id == null
      ? null
      : _availableSubjects
            .where((entry) => entry['subject_id'] == id)
            .map((entry) => '${entry['subject_name']}')
            .firstOrNull;

  List<int?> get _subjectChoices => [
    null,
    ..._availableSubjects.map((entry) => entry['subject_id'] as int),
  ];

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
        label: DashboardText.refresh,
        onActivate: _loadSessions,
        isEnabled: () => !_isRefreshing,
      ),
      KeypadFocusTarget(
        node: _sessionIdFocusNode,
        label: DashboardText.sessionNumberField(_sessionIdCtrl.text),
        isTextField: true,
      ),
      KeypadFocusTarget(
        node: _inputFocusNode,
        label: DashboardText.nameField,
        isTextField: true,
      ),
      KeypadFocusTarget(
        node: _joinFocusNode,
        label: DashboardText.showMatching,
        onActivate: _showSearchResults,
      ),
      KeypadFocusTarget(
        node: _subjectFocusNode,
        label: DashboardText.subjectFilterLabel(
          selectedSubject == null ? null : '${selectedSubject['subject_name']}',
          _subjectChoices.indexOf(_selectedSubjectId).clamp(0, _subjectChoices.length),
          _subjectChoices.length,
        ),
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
        label: DashboardText.library,
        onActivate: _openOfflineAudioLibrary,
      ),
      KeypadFocusTarget(
        node: _playlistsFocusNode,
        label: DashboardText.playlists,
        onActivate: _openMyPlaylists,
      ),
      KeypadFocusTarget(
        node: _quizzesFocusNode,
        label: DashboardText.quizzes,
        onActivate: _openQuizzes,
      ),
      KeypadFocusTarget(
        node: _journeysFocusNode,
        label: DashboardText.studentJourneys,
        onActivate: _openJourneys,
      ),
      KeypadFocusTarget(
        node: _logoutFocusNode,
        label: DashboardText.logout,
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
      screenName: DashboardText.studentScreen,
      navigationSections: DashboardText.studentSections,
      stateSummary: () => DashboardText.studentState(
        live: sessions.length,
        shown: _filteredSessions.length,
        subject: _subjectName(_selectedSubjectId),
        sessionNumber: _sessionIdCtrl.text.trim(),
        nameSearch: sessionCtrl.text.trim(),
        refreshing: _isRefreshing,
      ),
      labels: studentDashboardKeyLabels,
      actions: {
        0: _logout,
        1: _loadSessions,
        2: _focusSessionInput,
        3: _openOfflineAudioLibrary,
        4: _openMyPlaylists,
        5: _openQuizzes,
        6: _openJourneys,
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
                // Left/right control, not a drop-down; the focus target
                // above handles the keypad and announces each change.
                KeypadChoiceField<int?>(
                  label: 'Subject filter',
                  focusNode: _subjectFocusNode,
                  values: _subjectChoices,
                  value: _selectedSubjectId,
                  nameOf: (id) => DashboardText.subjectName(_subjectName(id)),
                  onChanged: (value) =>
                      setState(() => _selectedSubjectId = value),
                ),
                SizedBox(height: UIUtils.spacing(context, 8)),

                // Active sessions list: every session is a keypad stop.
                if (filtered.isEmpty)
                  Container(
                    padding: UIUtils.paddingAll(context, 12),
                    decoration: cardDecoration,
                    child: Text(
                      sessions.isEmpty
                          ? DashboardText.noLiveSessions
                          : DashboardText.noMatchVisible,
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
                  focusNode: _journeysFocusNode,
                  onPressed: _openJourneys,
                  icon: Icons.route,
                  text: '6: Learning Journeys',
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
