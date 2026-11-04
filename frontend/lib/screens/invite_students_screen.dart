import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
import '../services/api_service.dart';
import '../services/tts_service.dart';
import '../utils/ui_utils.dart';
import '../widgets/accessible_tile.dart';
import '../widgets/key_instruction_wrapper.dart';
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
  String _status = 'Loading students';
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
        _setStatus(
          _students.isEmpty
              ? 'No students are enrolled in this class. Press 1 to refresh.'
              : '${_students.length} ${_students.length == 1 ? 'student' : 'students'}, '
                    '${_invitedStudents.length} invited.'
                    '${_students.length > searchThreshold ? ' Use the search field to find a name.' : ''}',
        );
      } else {
        setState(() => _isLoading = false);
        _setStatus(
          'Could not load students. Check your connection and press 1 to try again.',
          error: true,
        );
      }
    } catch (e) {
      debugPrint('[INVITE] Error loading students: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
      _setStatus(
        'Could not load students. Check your connection and press 1 to try again.',
        error: true,
      );
    }
  }

  // Function to invite students to a session - only by teacher
  Future<bool> _inviteStudent(
    int studentId,
    String studentName, {
    bool announce = true,
  }) async {
    if (_invitedStudents.contains(studentId)) {
      if (announce) _setStatus('$studentName is already invited.');
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
        if (announce) _setStatus('Invited $studentName.');
        return true;
      }
    } catch (e) {
      debugPrint('[INVITE] Error: $e');
    }
    if (announce) {
      _setStatus(
        'Could not invite $studentName. Check your connection and press OK to try again.',
        error: true,
      );
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
            ? 'There are no students to invite.'
            : 'All students are already invited.',
      );
      return;
    }
    setState(() => _invitingAll = true);
    _setStatus('Inviting ${pending.length} students. Please wait.');
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
        _setStatus('Inviting students: $done of ${pending.length} done.');
      }
      // Small delay to prevent backend overload.
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;
    }
    setState(() => _invitingAll = false);
    final invited = pending.length - failed.length;
    if (failed.isEmpty) {
      _setStatus('Invited all $invited students.');
    } else {
      _setStatus(
        'Invited $invited of ${pending.length} students. '
        'Could not invite ${failed.join(', ')}. Press 2 to try again.',
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
          ? 'Showing all ${_students.length} students.'
          : count == 0
          ? 'No students match $query. Clear the search to list everyone.'
          : '$count ${count == 1 ? 'student matches' : 'students match'} $query. Use down to browse.',
    );
  }

  FocusNode _studentNode(int studentId) => _studentFocusNodes.putIfAbsent(
    studentId,
    () => FocusNode(debugLabel: 'invite-student-$studentId'),
  );

  String _studentLabel(Map<String, dynamic> student) {
    final invited = _invitedStudents.contains(student['user_id'] as int);
    return invited
        ? '${student['name']}, invited'
        : '${student['name']}, not invited. Press OK to invite';
  }

  List<KeypadFocusTarget> get _focusTargets => [
    KeypadFocusTarget(
      node: _backFocusNode,
      label: 'Back to session',
      onActivate: () => Navigator.pop(context),
    ),
    KeypadFocusTarget(
      node: _refreshFocusNode,
      label: 'Refresh student list',
      onActivate: _loadStudents,
      isEnabled: () => !_isLoading,
    ),
    KeypadFocusTarget(
      node: _inviteAllFocusNode,
      label: 'Invite all students',
      onActivate: _inviteAll,
      isEnabled: () =>
          !_invitingAll && _students.length != _invitedStudents.length,
    ),
    if (_showSearch)
      KeypadFocusTarget(
        node: _searchFocusNode,
        label: 'Search students by name or phone number. Press OK to type',
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
    TtsService.stop();
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
      status: isInvited ? 'Invited' : 'Not invited. OK to invite',
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
      screenName: 'Invite students to ${widget.sessionTitle}',
      labels: const {
        0: 'Back to Session',
        1: 'Refresh Students',
        2: 'Invite All',
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
            'Invite Students',
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
            tooltip: '0: Back to session',
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
              tooltip: '1: Refresh student list',
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
                        'Inviting students to:',
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
                        '${_invitedStudents.length} of ${_students.length} invited',
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
                    '2: Invite All Students',
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
                    decoration: const InputDecoration(
                      labelText: 'Search by name or phone number',
                      helperText: 'Leave empty to list every student',
                      helperMaxLines: 10,
                      prefixIcon: ExcludeSemantics(child: Icon(Icons.search)),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
                SizedBox(height: UIUtils.spacing(context, 8)),

                // Student list
                if (_isLoading)
                  Center(
                    child: Semantics(
                      label: 'Loading students',
                      child: const CircularProgressIndicator(),
                    ),
                  )
                else if (_students.isNotEmpty && visible.isEmpty)
                  Text(
                    'No students match. Clear the search to list everyone.',
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
