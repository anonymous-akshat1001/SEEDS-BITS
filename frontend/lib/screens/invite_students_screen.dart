import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
import '../services/api_service.dart';
import '../services/tts_service.dart';
import '../utils/ui_utils.dart';
import '../widgets/accessible_tile.dart';
import '../widgets/key_instruction_wrapper.dart';
import '../l10n/speech.dart';
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
  /// Lists longer than this get a search field so keypad users do not have
  /// to step through every name.
  static const searchThreshold = 8;

  final FocusNode _backFocusNode = FocusNode(debugLabel: 'invite-back');
  final FocusNode _refreshFocusNode = FocusNode(debugLabel: 'invite-refresh');
  final FocusNode _inviteAllFocusNode = FocusNode(debugLabel: 'invite-all');
  final FocusNode _searchFocusNode = FocusNode(debugLabel: 'invite-search');
  final Map<int, FocusNode> _studentFocusNodes = {};
  final TextEditingController _searchController = TextEditingController();
  final KeypadNavigationController _keypadController =
      KeypadNavigationController();

  // Stores student list from backend
  List<Map<String, dynamic>> _students = [];
  // Stores IDs of already-invited students
  final Set<int> _invitedStudents = {};
  bool _isLoading = true;
  bool _invitingAll = false;
  String _status = Speech.t.inviteLoadingStudents;
  bool _statusIsError = false;

  // Called once when screen appears
  @override
  void initState() {
    super.initState();
    // list of students immediately loaded
    _loadStudents();
  }

  void _setStatus(String message, {bool error = false, bool speak = true}) {
    if (!mounted) return;
    setState(() {
      _status = message;
      _statusIsError = error;
    });
    if (speak) {
      TtsService.speak(
        message,
        priority: error ? SpeechPriority.critical : SpeechPriority.requested,
      );
    }
  }

  // Loading students from backend
  Future<void> _loadStudents() async {
    // triggers UI rebuild
    setState(() => _isLoading = true);

    try {
      // calls backend and returns list of students
      final result = await ApiService.get(
        '/users/students?session_id=${widget.sessionId}',
        useAuth: true,
      );
      if (!mounted) return;
      if (result is List) {
        setState(() {
          // Converts dynamic list → strongly typed list
          _students = result.cast<Map<String, dynamic>>();
          _isLoading = false;
        });
        final t = Speech.t;
        _setStatus(
          _students.isEmpty
              ? t.inviteNoStudentsEnrolled
              : '${t.inviteLoadedSummary(_students.length, '${_invitedStudents.length}')}'
                    '${_students.length > searchThreshold ? ' ${t.inviteUseSearch}' : ''}',
        );
      } else {
        setState(() => _isLoading = false);
        _setStatus(Speech.t.inviteLoadFailed, error: true);
      }
    } catch (e) {
      debugPrint('[INVITE] Error loading students: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
      _setStatus(Speech.t.inviteLoadFailed, error: true);
    }
  }

  // Function to invite students to a session - only by teacher
  Future<bool> _inviteStudent(
    int studentId,
    String studentName, {
    bool announce = true,
  }) async {
    if (_invitedStudents.contains(studentId)) {
      if (announce) _setStatus(Speech.t.inviteAlreadyInvited(studentName));
      return true;
    }
    try {
      // Use ApiService for consistency - backend call
      final result = await ApiService.inviteStudent(
        widget.sessionId,
        studentId,
      );
      if (!mounted) return false;

      if (result != null && result['ok'] == true) {
        // Marks student as invited and UI is updated
        setState(() => _invitedStudents.add(studentId));
        if (announce) _setStatus(Speech.t.inviteInvitedOne(studentName));
        return true;
      }
    } catch (e) {
      debugPrint('[INVITE] Error: $e');
    }
    if (announce) {
      _setStatus(Speech.t.inviteOneFailed(studentName), error: true);
    }
    return false;
  }

  // Invites all the students one by one
  Future<void> _inviteAll() async {
    if (_invitingAll) return;
    final pending = _students
        .where((s) => !_invitedStudents.contains(s['user_id'] as int))
        .toList();
    if (pending.isEmpty) {
      _setStatus(
        _students.isEmpty
            ? Speech.t.inviteNoStudentsToInvite
            : Speech.t.inviteAllAlreadyInvited,
      );
      return;
    }
    setState(() => _invitingAll = true);
    _setStatus(Speech.t.inviteInvitingAll('${pending.length}'));
    final failed = <String>[];
    var done = 0;
    var lastQuarter = 0;
    for (final student in pending) {
      final ok = await _inviteStudent(
        student['user_id'] as int,
        '${student['name']}',
        announce: false,
      );
      if (!mounted) return;
      if (!ok) failed.add('${student['name']}');
      done++;
      // Progress is announced at most every 25 percent.
      final quarter = done * 4 ~/ pending.length;
      if (quarter > lastQuarter && done < pending.length) {
        lastQuarter = quarter;
        _setStatus(Speech.t.inviteProgress('$done', '${pending.length}'));
      }
      // Small delay to prevent backend overload.
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;
    }
    setState(() => _invitingAll = false);
    final invited = pending.length - failed.length;
    if (failed.isEmpty) {
      _setStatus(Speech.t.inviteAllDone('$invited'));
    } else {
      _setStatus(
        Speech.t.invitePartialFailed(
          '$invited',
          '${pending.length}',
          failed.join(', '),
        ),
        error: true,
      );
    }
  }

  List<Map<String, dynamic>> get _visibleStudents {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _students;
    return _students
        .where(
          (s) =>
              '${s['name'] ?? ''}'.toLowerCase().contains(query) ||
              '${s['phone_number'] ?? ''}'.contains(query),
        )
        .toList();
  }

  bool get _showSearch => _students.length > searchThreshold;

  void _announceSearchResults() {
    _keypadController.exitTextEditing();
    final query = _searchController.text.trim();
    final count = _visibleStudents.length;
    _setStatus(
      query.isEmpty
          ? Speech.t.inviteShowingAll('${_students.length}')
          : count == 0
          ? Speech.t.inviteNoMatch(query)
          : Speech.t.inviteMatches(count, query),
    );
  }

  FocusNode _studentNode(int studentId) => _studentFocusNodes.putIfAbsent(
    studentId,
    () => FocusNode(debugLabel: 'invite-student-$studentId'),
  );

  String _studentLabel(Map<String, dynamic> student) {
    final invited = _invitedStudents.contains(student['user_id'] as int);
    return invited
        ? Speech.t.inviteStudentInvited('${student['name']}')
        : Speech.t.inviteStudentNotInvited('${student['name']}');
  }

  List<KeypadFocusTarget> get _focusTargets => [
    KeypadFocusTarget(
      node: _backFocusNode,
      label: Speech.t.inviteBackToSession,
      onActivate: () => Navigator.pop(context),
    ),
    KeypadFocusTarget(
      node: _refreshFocusNode,
      label: Speech.t.inviteRefreshList,
      onActivate: _loadStudents,
      isEnabled: () => !_isLoading,
    ),
    KeypadFocusTarget(
      node: _inviteAllFocusNode,
      label: Speech.t.inviteAllStudents,
      onActivate: _inviteAll,
      isEnabled: () =>
          !_invitingAll && _students.length != _invitedStudents.length,
    ),
    if (_showSearch)
      KeypadFocusTarget(
        node: _searchFocusNode,
        label: Speech.t.inviteSearchLabel,
        isTextField: true,
      ),
    for (final student in _visibleStudents)
      KeypadFocusTarget(
        node: _studentNode(student['user_id'] as int),
        label: _studentLabel(student),
        onActivate: () =>
            _inviteStudent(student['user_id'] as int, '${student['name']}'),
      ),
  ];

  // Cleanup
  @override
  void dispose() {
    _backFocusNode.dispose();
    _refreshFocusNode.dispose();
    _inviteAllFocusNode.dispose();
    _searchFocusNode.dispose();
    _searchController.dispose();
    for (final node in _studentFocusNodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  Widget _studentTile(Map<String, dynamic> student) {
    final studentId = student['user_id'] as int;
    final name = '${student['name']}';
    final isInvited = _invitedStudents.contains(studentId);
    return AccessibleTile(
      focusNode: _studentNode(studentId),
      leadingIcon: isInvited
          ? Icons.check_circle_rounded
          : Icons.person_outline_rounded,
      title: name,
      status: isInvited
          ? Speech.t.inviteStatusInvited
          : Speech.t.inviteStatusNotInvited,
      statusColor: isInvited ? UIUtils.successColor : UIUtils.accentColor,
      subtitle: '${student['phone_number'] ?? ''}',
      semanticLabel: _studentLabel(student),
      onActivate: () => _inviteStudent(studentId, name),
    );
  }

  // UI Build
  @override
  Widget build(BuildContext context) {
    final bool tiny = UIUtils.isTiny(context);
    final bool compact = tiny || UIUtils.isShort(context);
    final visible = _visibleStudents;
    return KeypadInstructionWrapper(
      screenName: Speech.t.inviteScreenName(widget.sessionTitle),
      labels: {
        0: Speech.t.inviteKeyBack,
        1: Speech.t.inviteKeyRefresh,
        2: Speech.t.inviteKeyInviteAll,
      },
      actions: {
        0: () => Navigator.pop(context),
        1: _loadStudents,
        2: _inviteAll,
      },
      navigationController: _keypadController,
      focusTargets: _focusTargets,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            Speech.t.inviteTitle,
            style: TextStyle(
              fontSize: UIUtils.fontSize(context, 16),
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: UIUtils.cardColor,
          foregroundColor: UIUtils.textColor,
          elevation: 0,
          toolbarHeight: tiny ? 40 : null,
          leading: IconButton(
            focusNode: _backFocusNode,
            icon: const Icon(Icons.arrow_back),
            tooltip: Speech.t.inviteTooltipBack,
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              focusNode: _refreshFocusNode,
              icon: Icon(
                Icons.refresh_rounded,
                size: UIUtils.iconSize(context, 20),
                color: UIUtils.accentColor,
              ),
              tooltip: Speech.t.inviteTooltipRefresh,
              onPressed: _isLoading ? null : _loadStudents,
            ),
          ],
        ),
        backgroundColor: UIUtils.backgroundColor,
        body: SafeArea(
          // A Column keeps every student mounted so the D-pad reaches all.
          child: SingleChildScrollView(
            padding: UIUtils.paddingAll(context, compact ? 6 : 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Session info
                Container(
                  padding: UIUtils.paddingAll(context, compact ? 8 : 12),
                  decoration: BoxDecoration(
                    color: UIUtils.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: UIUtils.cardBorderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Speech.t.inviteInvitingTo,
                        style: TextStyle(
                          fontSize: UIUtils.fontSize(context, 14),
                          color: UIUtils.subtextColor,
                        ),
                      ),
                      SizedBox(height: UIUtils.spacing(context, 2)),
                      Text(
                        widget.sessionTitle,
                        style: TextStyle(
                          fontSize: UIUtils.fontSize(context, 18),
                          fontWeight: FontWeight.w700,
                          color: UIUtils.textColor,
                        ),
                      ),
                      SizedBox(height: UIUtils.spacing(context, 4)),
                      Text(
                        Speech.t.inviteInvitedCount(
                          '${_invitedStudents.length}',
                          '${_students.length}',
                        ),
                        style: TextStyle(
                          fontSize: UIUtils.fontSize(context, 14),
                          color: UIUtils.subtextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: UIUtils.spacing(context, 8)),
                Semantics(
                  liveRegion: true,
                  child: Text(
                    _status,
                    style: TextStyle(
                      fontSize: UIUtils.fontSize(context, 16),
                      fontWeight: FontWeight.w600,
                      color: _statusIsError
                          ? UIUtils.errorColor
                          : UIUtils.textColor,
                    ),
                  ),
                ),
                SizedBox(height: UIUtils.spacing(context, 8)),

                // Invite all button
                ElevatedButton.icon(
                  focusNode: _inviteAllFocusNode,
                  onPressed:
                      _invitingAll ||
                          _isLoading ||
                          _students.length == _invitedStudents.length
                      ? null
                      : _inviteAll,
                  icon: Icon(
                    Icons.send_rounded,
                    size: UIUtils.iconSize(context, 18),
                  ),
                  label: Text(
                    Speech.t.inviteAllButton,
                    style: TextStyle(
                      fontSize: UIUtils.fontSize(context, 16),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: UIUtils.primaryColor,
                    foregroundColor: UIUtils.onPrimaryColor,
                    padding: UIUtils.paddingSymmetric(
                      context,
                      vertical: compact ? 10 : 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(compact ? 8 : 12),
                    ),
                    elevation: 0,
                  ),
                ),
                if (_showSearch) ...[
                  SizedBox(height: UIUtils.spacing(context, 8)),
                  TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    textInputAction: TextInputAction.search,
                    onTap: () =>
                        _keypadController.enterTextEditing(_searchFocusNode),
                    onChanged: (_) => setState(() {}),
                    onSubmitted: (_) => _announceSearchResults(),
                    decoration: InputDecoration(
                      labelText: Speech.t.inviteSearchField,
                      helperText: Speech.t.inviteSearchHelper,
                      helperMaxLines: 10,
                      prefixIcon: const ExcludeSemantics(child: Icon(Icons.search)),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ],
                SizedBox(height: UIUtils.spacing(context, 8)),

                // Student list
                if (_isLoading)
                  Center(
                    child: Semantics(
                      label: Speech.t.inviteLoadingStudents,
                      child: const CircularProgressIndicator(),
                    ),
                  )
                else if (_students.isNotEmpty && visible.isEmpty)
                  Text(
                    Speech.t.inviteNoMatchShort,
                    style: TextStyle(
                      color: UIUtils.textColor,
                      fontSize: UIUtils.fontSize(context, 16),
                    ),
                  )
                else
                  ...visible.map(_studentTile),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
