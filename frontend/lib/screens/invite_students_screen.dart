import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
import '../services/api_service.dart';
import '../services/tts_service.dart';
import '../utils/ui_utils.dart';
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
  final FocusNode _backFocusNode = FocusNode(debugLabel: 'invite-back');
  final FocusNode _ttsFocusNode = FocusNode(debugLabel: 'invite-tts');
  final FocusNode _refreshFocusNode = FocusNode(debugLabel: 'invite-refresh');
  final FocusNode _inviteAllFocusNode = FocusNode(debugLabel: 'invite-all');
  final Map<int, FocusNode> _studentFocusNodes = {};

  // Stores student list from backend
  List<Map<String, dynamic>> _students = [];
  // Stores IDs of already-invited students
  Set<int> _invitedStudents = {};
  bool _isLoading = true;
  bool _ttsEnabled = true;

  // Called once when screen appears
  @override
  void initState() {
    super.initState();
    // list of students immediately loaded
    _loadStudents();
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

      if (result != null) {
        setState(() {
          if (result is List) {
            // Converts dynamic list → strongly typed list
            _students = result.cast<Map<String, dynamic>>();
          }
        });

        await _speakIfEnabled("Loaded ${_students.length} students");
      }
    } catch (e) {
      print('[INVITE] Error loading students: $e');
      _showError("Failed to load students");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Function to invite students to a session - only by teacher
  Future<void> _inviteStudent(int studentId, String studentName) async {
    try {
      await _speakIfEnabled('Inviting $studentName');
      // Use ApiService for consistency - backend call
      final result = await ApiService.inviteStudent(
        widget.sessionId,
        studentId,
      );

      if (result != null && result['ok'] == true) {
        // Marks student as invited and UI is updated
        setState(() => _invitedStudents.add(studentId));
        await _speakIfEnabled("Invited $studentName");

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Invited $studentName to join session'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        _showError("Failed to invite $studentName");
      }
    } catch (e) {
      print('[INVITE] Error: $e');
      _showError("Failed to invite $studentName");
    }
  }

  // Invites all the students one by one
  Future<void> _inviteAll() async {
    for (var student in _students) {
      final studentId = student['user_id'] as int;
      // Avoids re-inviting same student
      if (!_invitedStudents.contains(studentId)) {
        await _inviteStudent(studentId, student['name']);
        // Small delay to prevent UI freeze, backend overload and keep speech understandable
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }

    await _speakIfEnabled("Invited all students");
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
    _speakIfEnabled(message);
  }

  Future<void> _speakIfEnabled(String text) async {
    if (_ttsEnabled) {
      await TtsService.speak(text);
    }
  }

  void _toggleTts() {
    setState(() => _ttsEnabled = !_ttsEnabled);
    TtsService.configure(enabled: _ttsEnabled);
    if (_ttsEnabled) {
      _speakIfEnabled('Text to speech enabled');
    } else {
      TtsService.stop();
    }
  }

  FocusNode _studentNode(int studentId) => _studentFocusNodes.putIfAbsent(
    studentId,
    () => FocusNode(debugLabel: 'invite-student-$studentId'),
  );

  List<KeypadFocusTarget> get _focusTargets => [
    KeypadFocusTarget(
      node: _backFocusNode,
      label: 'Back to session',
      onActivate: () => Navigator.pop(context),
    ),
    KeypadFocusTarget(
      node: _ttsFocusNode,
      label: _ttsEnabled ? 'Turn text to speech off' : 'Turn text to speech on',
      onActivate: _toggleTts,
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
      isEnabled: () => _students.length != _invitedStudents.length,
    ),
    for (final student in _students)
      if (!_invitedStudents.contains(student['user_id'] as int))
        KeypadFocusTarget(
          node: _studentNode(student['user_id'] as int),
          label: '${student['name']}. Press OK to invite this student',
          onActivate: () => _inviteStudent(
            student['user_id'] as int,
            student['name'] as String,
          ),
        ),
  ];

  // Cleanup
  @override
  void dispose() {
    _backFocusNode.dispose();
    _ttsFocusNode.dispose();
    _refreshFocusNode.dispose();
    _inviteAllFocusNode.dispose();
    for (final node in _studentFocusNodes.values) {
      node.dispose();
    }
    TtsService.stop();
    super.dispose();
  }

  // UI Build
  @override
  Widget build(BuildContext context) {
    final bool tiny = UIUtils.isTiny(context);
    final bool compact = tiny || UIUtils.isShort(context);
    return KeypadInstructionWrapper(
      screenName: 'Invite students',
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
            tooltip: 'Back to session',
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
              tooltip: 'Refresh students',
              onPressed: _isLoading ? null : _loadStudents,
            ),
            IconButton(
              focusNode: _ttsFocusNode,
              icon: Icon(
                _ttsEnabled
                    ? Icons.volume_up_rounded
                    : Icons.volume_off_rounded,
                size: UIUtils.iconSize(context, 20),
                color: UIUtils.accentColor,
              ),
              tooltip: 'Toggle TTS',
              onPressed: _toggleTts,
            ),
          ],
        ),
        backgroundColor: UIUtils.backgroundColor,
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // Session info
                  Container(
                    width: double.infinity,
                    padding: UIUtils.paddingAll(context, compact ? 8 : 12),
                    color: UIUtils.cardColor,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Inviting students to:',
                          style: TextStyle(
                            fontSize: UIUtils.fontSize(context, 11),
                            color: UIUtils.subtextColor,
                          ),
                        ),
                        SizedBox(height: UIUtils.spacing(context, 2)),
                        Text(
                          widget.sessionTitle,
                          style: TextStyle(
                            fontSize: UIUtils.fontSize(
                              context,
                              compact ? 14 : 16,
                            ),
                            fontWeight: FontWeight.w700,
                            color: UIUtils.textColor,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(
                          height: UIUtils.spacing(context, compact ? 2 : 4),
                        ),
                        Text(
                          '${_invitedStudents.length} of ${_students.length} invited',
                          style: TextStyle(
                            fontSize: UIUtils.fontSize(context, 11),
                            color: UIUtils.subtextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),

                  // Invite all button
                  Padding(
                    padding: UIUtils.paddingAll(context, compact ? 6 : 10),
                    child: ElevatedButton.icon(
                      focusNode: _inviteAllFocusNode,
                      onPressed: _students.length == _invitedStudents.length
                          ? null
                          : _inviteAll,
                      icon: Icon(
                        Icons.send_rounded,
                        size: UIUtils.iconSize(context, 18),
                      ),
                      label: Text(
                        compact ? 'Invite All' : 'Invite All Students',
                        style: TextStyle(
                          fontSize: UIUtils.fontSize(
                            context,
                            compact ? 12 : 14,
                          ),
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: UIUtils.primaryColor,
                        foregroundColor: Colors.white,
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
                  ),
                  const Divider(),

                  // Student list
                  Expanded(
                    child: _students.isEmpty
                        ? Center(
                            child: Text(
                              'No students found',
                              style: TextStyle(
                                color: UIUtils.subtextColor,
                                fontSize: UIUtils.fontSize(context, 13),
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: UIUtils.paddingAll(
                              context,
                              compact ? 4 : 8,
                            ),
                            itemCount: _students.length,
                            itemBuilder: (context, index) {
                              final student = _students[index];
                              final studentId = student['user_id'] as int;
                              final name = student['name'] as String;
                              final phone = student['phone_number'] as String;
                              final isInvited = _invitedStudents.contains(
                                studentId,
                              );

                              return Card(
                                margin: EdgeInsets.only(
                                  bottom: UIUtils.spacing(
                                    context,
                                    compact ? 5 : 8,
                                  ),
                                  left: compact ? 4 : 12,
                                  right: compact ? 4 : 12,
                                ),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: UIUtils.isHighContrast
                                        ? UIUtils.accentColor
                                        : Colors.grey.withOpacity(0.1),
                                  ),
                                ),
                                color: isInvited
                                    ? (UIUtils.isHighContrast
                                          ? UIUtils.cardColor
                                          : Colors.green.withOpacity(0.05))
                                    : UIUtils.cardColor,
                                child: ListTile(
                                  dense: compact,
                                  contentPadding: UIUtils.paddingSymmetric(
                                    context,
                                    horizontal: compact ? 6 : 8,
                                    vertical: compact ? 0 : 2,
                                  ),
                                  leading: CircleAvatar(
                                    backgroundColor: isInvited
                                        ? Colors.green
                                        : UIUtils.backgroundColor,
                                    radius: UIUtils.iconSize(context, 18),
                                    child: Icon(
                                      isInvited
                                          ? Icons.check_rounded
                                          : Icons.person_outline_rounded,
                                      color: isInvited
                                          ? Colors.white
                                          : UIUtils.primaryColor,
                                      size: UIUtils.iconSize(context, 18),
                                    ),
                                  ),
                                  title: Text(
                                    name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: UIUtils.fontSize(context, 14),
                                      color: isInvited
                                          ? (UIUtils.isHighContrast
                                                ? UIUtils.accentColor
                                                : Colors.green.shade700)
                                          : UIUtils.textColor,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Text(
                                    phone,
                                    style: TextStyle(
                                      color: isInvited
                                          ? (UIUtils.isHighContrast
                                                ? UIUtils.subtextColor
                                                : Colors.green.shade600)
                                          : UIUtils.subtextColor,
                                      fontSize: UIUtils.fontSize(context, 11),
                                    ),
                                  ),
                                  trailing: isInvited
                                      ? compact
                                            ? Icon(
                                                Icons.check_circle_rounded,
                                                color: Colors.green,
                                                size: UIUtils.iconSize(
                                                  context,
                                                  22,
                                                ),
                                              )
                                            : Container(
                                                padding:
                                                    UIUtils.paddingSymmetric(
                                                      context,
                                                      horizontal: 8,
                                                      vertical: 3,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.green,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Text(
                                                  'INVITED',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: UIUtils.fontSize(
                                                      context,
                                                      9,
                                                    ),
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              )
                                      : compact
                                      ? IconButton(
                                          focusNode: _studentNode(studentId),
                                          onPressed: () =>
                                              _inviteStudent(studentId, name),
                                          icon: Icon(
                                            Icons.send_rounded,
                                            size: UIUtils.iconSize(context, 18),
                                          ),
                                          color: UIUtils.accentColor,
                                          tooltip: 'Invite',
                                          padding: EdgeInsets.zero,
                                          constraints: BoxConstraints.tightFor(
                                            width: UIUtils.iconSize(
                                              context,
                                              34,
                                            ),
                                            height: UIUtils.iconSize(
                                              context,
                                              34,
                                            ),
                                          ),
                                        )
                                      : ElevatedButton.icon(
                                          focusNode: _studentNode(studentId),
                                          onPressed: () =>
                                              _inviteStudent(studentId, name),
                                          icon: Icon(
                                            Icons.send_rounded,
                                            size: UIUtils.iconSize(context, 14),
                                          ),
                                          label: Text(
                                            'Invite',
                                            style: TextStyle(
                                              fontSize: UIUtils.fontSize(
                                                context,
                                                12,
                                              ),
                                            ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                UIUtils.accentColor,
                                            foregroundColor: Colors.white,
                                            padding: UIUtils.paddingSymmetric(
                                              context,
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            elevation: 0,
                                          ),
                                        ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}
