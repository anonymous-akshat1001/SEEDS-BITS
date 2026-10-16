import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/api_service.dart';
import '../services/auth_session_service.dart';
import '../services/tts_service.dart';
import '../utils/keypad_actions.dart';
import '../utils/ui_utils.dart';
import '../widgets/key_instruction_wrapper.dart';
import '../widgets/keypad_confirmation_dialog.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final _keypad = KeypadNavigationController();
  final _searchController = TextEditingController();
  final _searchNode = FocusNode(debugLabel: 'admin-user-search');
  final _refreshNode = FocusNode(debugLabel: 'admin-refresh');
  final _roleFilterNode = FocusNode(debugLabel: 'admin-account-type-filter');
  final _assignmentFilterNode = FocusNode(
    debugLabel: 'admin-assignment-filter',
  );
  final _subjectNode = FocusNode(debugLabel: 'admin-add-subject');
  final _classNode = FocusNode(debugLabel: 'admin-add-class');
  final _logoutNode = FocusNode(debugLabel: 'admin-logout');
  final Map<int, FocusNode> _userNodes = {};
  final Map<int, FocusNode> _classNodes = {};
  final Map<int, FocusNode> _subjectNodes = {};

  List<dynamic> _users = const [];
  List<dynamic> _classes = const [];
  List<dynamic> _subjects = const [];
  bool _loading = true;
  bool _initialAnnouncementPending = true;
  String? _roleFilter;
  String _assignmentStatus = 'all';

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchNode.dispose();
    _refreshNode.dispose();
    _roleFilterNode.dispose();
    _assignmentFilterNode.dispose();
    _subjectNode.dispose();
    _classNode.dispose();
    _logoutNode.dispose();
    for (final node in _userNodes.values) {
      node.dispose();
    }
    for (final node in _classNodes.values) {
      node.dispose();
    }
    for (final node in _subjectNodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  Future<void> _refresh() async {
    if (mounted) setState(() => _loading = true);
    final results = await Future.wait([
      ApiService.getAdminUsers(
        search: _searchController.text.trim(),
        role: _roleFilter,
        assignmentStatus: _assignmentStatus,
      ),
      ApiService.getClasses(includeArchived: true),
      ApiService.getSubjects(includeArchived: true),
    ]);
    if (!mounted) return;
    setState(() {
      _users = results[0];
      _classes = results[1];
      _subjects = results[2];
      _loading = false;
    });
    final summary =
        '${_users.length} accounts shown. ${_classes.length} classes and ${_subjects.length} subjects.';
    if (_initialAnnouncementPending) {
      _initialAnnouncementPending = false;
      await TtsService.speak(
        '${buildTtsInstructions(adminDashboardKeyLabels, screenName: 'Administrator Dashboard')} $summary',
      );
    } else {
      await TtsService.speak(summary);
    }
  }

  void _focusSearch() {
    _searchNode.requestFocus();
    _keypad.enterTextEditing(_searchNode);
  }

  Future<void> _setRoleFilter(String? role) async {
    if (_roleFilter == role) return;
    setState(() {
      _roleFilter = role;
      _assignmentStatus = 'all';
    });
    await TtsService.speak(
      'Showing ${_roleFilterLabel().toLowerCase()}. Loading accounts.',
    );
    await _refresh();
  }

  Future<void> _cycleRoleFilter(int direction) async {
    const filters = <String?>[null, 'student', 'teacher'];
    final current = filters.indexOf(_roleFilter);
    var next = (current + direction) % filters.length;
    if (next < 0) next += filters.length;
    await _setRoleFilter(filters[next]);
  }

  Future<void> _cycleAssignmentFilter(int direction) async {
    const filters = ['all', 'assigned', 'unassigned'];
    final current = filters.indexOf(_assignmentStatus);
    var next = (current + direction) % filters.length;
    if (next < 0) next += filters.length;
    setState(() => _assignmentStatus = filters[next]);
    await TtsService.speak(
      'Assignment filter ${_assignmentFilterLabel()}. Loading accounts.',
    );
    await _refresh();
  }

  String _roleFilterLabel() => switch (_roleFilter) {
    'student' => 'Students only',
    'teacher' => 'Teachers only',
    _ => 'All registered accounts',
  };

  String _assignmentFilterLabel() => switch (_assignmentStatus) {
    'assigned' =>
      _roleFilter == 'student'
          ? 'Enrolled'
          : _roleFilter == 'teacher'
          ? 'Assigned'
          : 'Enrolled or assigned',
    'unassigned' => 'Unassigned',
    _ => 'All assignment states',
  };

  List<dynamic> get _orderedUsers {
    if (_roleFilter != null) return _users;
    return [
      ..._users.where((entry) => entry['role'] == 'teacher'),
      ..._users.where((entry) => entry['role'] == 'student'),
    ];
  }

  Widget _accountCard(dynamic entry) {
    final user = Map<String, dynamic>.from(entry as Map);
    final id = user['user_id'] as int;
    final detail = user['role'] == 'student'
        ? (user['class_name'] ?? 'No class assigned')
        : '${user['assignment_count']} active assignments';
    return Card(
      child: ListTile(
        focusNode: _userNodes.putIfAbsent(
          id,
          () => FocusNode(debugLabel: 'admin-user-$id'),
        ),
        title: Text('${user['name']}'),
        subtitle: Text('$detail\n${user['phone_number']}'),
        isThreeLine: true,
        trailing: const Icon(Icons.edit_outlined),
        onTap: () => _manageUser(user),
      ),
    );
  }

  List<Widget> _accountSection(String heading, Iterable<dynamic> accounts) {
    final entries = accounts.toList();
    if (entries.isEmpty) return const [];
    return [
      Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 4),
        child: Semantics(
          header: true,
          child: Text(
            '$heading (${entries.length})',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ),
      ...entries.map(_accountCard),
    ];
  }

  Future<String?> _textDialog({
    required String title,
    required String label,
    String initialValue = '',
  }) async {
    final controller = TextEditingController(text: initialValue);
    final fieldNode = FocusNode(debugLabel: '$label-field');
    final cancelNode = FocusNode(debugLabel: '$label-cancel');
    final saveNode = FocusNode(debugLabel: '$label-save');
    final dialogKeypad = KeypadNavigationController();
    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => KeypadInstructionWrapper(
        screenName: title,
        labels: const {0: 'Cancel', 1: 'Save'},
        actions: {
          0: () => Navigator.pop(dialogContext),
          1: () => Navigator.pop(dialogContext, controller.text.trim()),
        },
        navigationController: dialogKeypad,
        focusTargets: [
          KeypadFocusTarget(node: fieldNode, label: label, isTextField: true),
          KeypadFocusTarget(
            node: cancelNode,
            label: 'Cancel',
            onActivate: () => Navigator.pop(dialogContext),
          ),
          KeypadFocusTarget(
            node: saveNode,
            label: 'Save',
            onActivate: () =>
                Navigator.pop(dialogContext, controller.text.trim()),
          ),
        ],
        child: AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            focusNode: fieldNode,
            onTap: () => dialogKeypad.enterTextEditing(fieldNode),
            decoration: InputDecoration(labelText: label),
          ),
          actions: [
            TextButton(
              focusNode: cancelNode,
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel (0)'),
            ),
            FilledButton(
              focusNode: saveNode,
              onPressed: () =>
                  Navigator.pop(dialogContext, controller.text.trim()),
              child: const Text('Save (1)'),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    fieldNode.dispose();
    cancelNode.dispose();
    saveNode.dispose();
    return result;
  }

  Future<void> _addSubject() async {
    final name = await _textDialog(
      title: 'Create subject',
      label: 'Subject name',
    );
    if (name == null || name.isEmpty) return;
    final result = await ApiService.createSubject(name);
    await _announceResult(result != null, 'Subject $name created');
  }

  Future<void> _addClass() async {
    final name = await _textDialog(title: 'Create class', label: 'Class name');
    if (name == null || name.isEmpty) return;
    final activeOrders = _classes
        .map((entry) => int.tryParse('${entry['sort_order']}') ?? 0)
        .toList();
    final nextOrder = activeOrders.isEmpty
        ? 0
        : activeOrders.reduce((a, b) => a > b ? a : b) + 1;
    final result = await ApiService.createClass(name, nextOrder);
    await _announceResult(result != null, 'Class $name created');
  }

  Future<void> _announceResult(bool success, String successMessage) async {
    final message = success ? successMessage : 'The change could not be saved';
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
    await TtsService.speak(message);
    if (success) await _refresh();
  }

  Future<void> _toggleClass(Map<String, dynamic> schoolClass) async {
    final currentlyActive = schoolClass['is_active'] == true;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => KeypadConfirmationDialog(
        title: currentlyActive ? 'Archive class?' : 'Restore class?',
        message: currentlyActive
            ? 'New sessions, audio, and assignments cannot use ${schoolClass['name']} while it is archived.'
            : '${schoolClass['name']} will become available for assignments again.',
        cancelLabel: 'Cancel',
        confirmLabel: currentlyActive ? 'Archive' : 'Restore',
        cancelKey: 0,
        confirmKey: 1,
      ),
    );
    if (confirmed != true) return;
    final result = await ApiService.setClassArchived(
      schoolClass['class_id'] as int,
      currentlyActive,
    );
    await _announceResult(
      result != null,
      currentlyActive ? 'Class archived' : 'Class restored',
    );
  }

  Future<void> _manageClassSubjects(Map<String, dynamic> schoolClass) async {
    final associations = await ApiService.getClassSubjects(
      schoolClass['class_id'] as int,
      includeArchived: true,
    );
    if (!mounted) return;
    final activeBySubject = <int, Map<String, dynamic>>{
      for (final entry in associations)
        if (entry['is_active'] == true)
          entry['subject_id'] as int: Map<String, dynamic>.from(entry as Map),
    };
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text('Subjects for ${schoolClass['name']}'),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520, maxHeight: 460),
          child: ListView(
            shrinkWrap: true,
            children: _subjects.map((entry) {
              final subject = Map<String, dynamic>.from(entry as Map);
              final subjectId = subject['subject_id'] as int;
              final association = activeBySubject[subjectId];
              final available = subject['is_active'] == true;
              return Semantics(
                toggled: association != null,
                child: ListTile(
                  enabled: available || association != null,
                  title: Text('${subject['name']}'),
                  subtitle: Text(
                    !available
                        ? 'Subject archived'
                        : association == null
                        ? 'Not available in this class'
                        : 'Available in this class',
                  ),
                  trailing: Icon(
                    association == null
                        ? Icons.add_circle_outline
                        : Icons.remove_circle_outline,
                  ),
                  onTap: () => Navigator.pop(dialogContext, {
                    'subject_id': subjectId,
                    'association_id': association?['association_id'],
                    'remove': association != null,
                  }),
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
    if (result == null) return;
    final remove = result['remove'] == true;
    final success = remove
        ? await ApiService.archiveClassSubject(
            schoolClass['class_id'] as int,
            result['association_id'] as int,
          )
        : await ApiService.associateClassSubject(
                schoolClass['class_id'] as int,
                result['subject_id'] as int,
              ) !=
              null;
    await _announceResult(
      success,
      remove
          ? 'Subject removed from ${schoolClass['name']}'
          : 'Subject added to ${schoolClass['name']}',
    );
  }

  Future<void> _toggleSubject(Map<String, dynamic> subject) async {
    final currentlyActive = subject['is_active'] == true;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => KeypadConfirmationDialog(
        title: currentlyActive ? 'Archive subject?' : 'Restore subject?',
        message: currentlyActive
            ? 'New sessions, audio, and assignments cannot use ${subject['name']} while it is archived.'
            : '${subject['name']} will become available for assignments again.',
        cancelLabel: 'Cancel',
        confirmLabel: currentlyActive ? 'Archive' : 'Restore',
        cancelKey: 0,
        confirmKey: 1,
      ),
    );
    if (confirmed != true) return;
    final result = await ApiService.setSubjectArchived(
      subject['subject_id'] as int,
      currentlyActive,
    );
    await _announceResult(
      result != null,
      currentlyActive ? 'Subject archived' : 'Subject restored',
    );
  }

  Future<void> _manageUser(Map<String, dynamic> user) async {
    if (user['role'] == 'student') {
      await _assignStudent(user);
    } else {
      await _assignTeacher(user);
    }
    if (mounted) {
      _userNodes[user['user_id'] as int]?.requestFocus();
    }
  }

  Future<void> _assignStudent(Map<String, dynamic> student) async {
    final activeClasses = _classes
        .where((entry) => entry['is_active'] == true)
        .toList();
    if (activeClasses.isEmpty) return;
    final currentClassId = int.tryParse('${student['class_id']}');
    int classId =
        activeClasses.any((entry) => entry['class_id'] == currentClassId)
        ? currentClassId!
        : activeClasses.first['class_id'] as int;
    final classNode = FocusNode(debugLabel: 'student-class-selection');
    final cancelNode = FocusNode(debugLabel: 'student-class-cancel');
    final assignNode = FocusNode(debugLabel: 'student-class-assign');
    final removeNode = FocusNode(debugLabel: 'student-class-remove');
    late StateSetter updateDialog;
    void moveClass(int direction) {
      final current = activeClasses.indexWhere(
        (entry) => entry['class_id'] == classId,
      );
      var next = (current + direction) % activeClasses.length;
      if (next < 0) next += activeClasses.length;
      updateDialog(() => classId = activeClasses[next]['class_id'] as int);
      TtsService.speak(
        '${activeClasses[next]['name']} selected. Use left or right to change class.',
      );
    }

    final action = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => KeypadInstructionWrapper(
        screenName: 'Assign class to ${student['name']}',
        labels: {
          0: 'Cancel',
          1: 'Assign',
          if (currentClassId != null) 2: 'Remove class',
        },
        actions: {
          0: () => Navigator.pop(dialogContext),
          1: () => Navigator.pop(dialogContext, 'assign'),
          if (currentClassId != null)
            2: () => Navigator.pop(dialogContext, 'remove'),
        },
        focusTargets: [
          KeypadFocusTarget(
            node: classNode,
            label: 'Choose class. Use left or right to change',
            onActivate: () => moveClass(1),
            onDecrease: () => moveClass(-1),
            onIncrease: () => moveClass(1),
          ),
          KeypadFocusTarget(
            node: cancelNode,
            label: 'Cancel',
            onActivate: () => Navigator.pop(dialogContext, false),
          ),
          KeypadFocusTarget(
            node: assignNode,
            label: 'Assign class',
            onActivate: () => Navigator.pop(dialogContext, 'assign'),
          ),
          if (currentClassId != null)
            KeypadFocusTarget(
              node: removeNode,
              label: 'Remove class',
              onActivate: () => Navigator.pop(dialogContext, 'remove'),
            ),
        ],
        child: StatefulBuilder(
          builder: (context, setLocal) {
            updateDialog = setLocal;
            return AlertDialog(
              title: Text('Assign class to ${student['name']}'),
              content: DropdownButtonFormField<int>(
                key: ValueKey(classId),
                focusNode: classNode,
                initialValue: classId,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Class'),
                items: activeClasses
                    .map<DropdownMenuItem<int>>(
                      (entry) => DropdownMenuItem(
                        value: entry['class_id'] as int,
                        child: Text('${entry['name']}'),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) setLocal(() => classId = value);
                },
              ),
              actions: [
                TextButton(
                  focusNode: cancelNode,
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel (0)'),
                ),
                if (currentClassId != null)
                  TextButton(
                    focusNode: removeNode,
                    onPressed: () => Navigator.pop(dialogContext, 'remove'),
                    child: const Text('Remove class (2)'),
                  ),
                FilledButton(
                  focusNode: assignNode,
                  onPressed: () => Navigator.pop(dialogContext, 'assign'),
                  child: const Text('Assign (1)'),
                ),
              ],
            );
          },
        ),
      ),
    );
    classNode.dispose();
    cancelNode.dispose();
    assignNode.dispose();
    removeNode.dispose();
    if (action == 'remove') {
      final removed = await ApiService.removeStudentClass(
        student['user_id'] as int,
      );
      await _announceResult(removed, '${student['name']} removed from class');
      return;
    }
    if (action != 'assign') return;
    final result = await ApiService.enrollStudent(
      student['user_id'] as int,
      classId,
    );
    final className = activeClasses.firstWhere(
      (entry) => entry['class_id'] == classId,
    )['name'];
    await _announceResult(
      result != null,
      '${student['name']} assigned to $className',
    );
  }

  Future<void> _assignTeacher(Map<String, dynamic> teacher) async {
    final activeClasses = _classes
        .where((entry) => entry['is_active'] == true)
        .toList();
    if (activeClasses.isEmpty) return;
    final assignments = await ApiService.getTeacherAssignments(
      teacher['user_id'] as int,
    );
    if (!mounted) return;
    int classId = activeClasses.first['class_id'] as int;
    var classSubjects = await ApiService.getClassSubjects(classId);
    if (!mounted) return;
    if (classSubjects.isEmpty) {
      await TtsService.speak('This class has no active subjects.');
      return;
    }
    int subjectId = classSubjects.first['subject_id'] as int;
    final classNode = FocusNode(debugLabel: 'teacher-class-selection');
    final subjectNode = FocusNode(debugLabel: 'teacher-subject-selection');
    final cancelNode = FocusNode(debugLabel: 'teacher-assignment-cancel');
    final assignNode = FocusNode(debugLabel: 'teacher-assignment-save');
    final assignmentNodes = <int, FocusNode>{
      for (final entry in assignments)
        entry['assignment_id'] as int: FocusNode(
          debugLabel: 'teacher-assignment-${entry['assignment_id']}',
        ),
    };
    late StateSetter updateDialog;
    Future<void> selectClass(int value) async {
      final subjects = await ApiService.getClassSubjects(value);
      if (subjects.isEmpty) {
        await TtsService.speak('The selected class has no active subjects.');
        return;
      }
      final selectedClass = activeClasses.firstWhere(
        (entry) => entry['class_id'] == value,
      );
      updateDialog(() {
        classId = value;
        classSubjects = subjects;
        subjectId = subjects.first['subject_id'] as int;
      });
      await TtsService.speak(
        '${selectedClass['name']} selected. '
        '${subjects.first['subject_name']} subject selected.',
      );
    }

    void moveTeacherClass(int direction) {
      final current = activeClasses.indexWhere(
        (entry) => entry['class_id'] == classId,
      );
      var next = (current + direction) % activeClasses.length;
      if (next < 0) next += activeClasses.length;
      selectClass(activeClasses[next]['class_id'] as int);
    }

    void moveSubject(int direction) {
      final current = classSubjects.indexWhere(
        (entry) => entry['subject_id'] == subjectId,
      );
      var next = (current + direction) % classSubjects.length;
      if (next < 0) next += classSubjects.length;
      updateDialog(() => subjectId = classSubjects[next]['subject_id'] as int);
      TtsService.speak(
        '${classSubjects[next]['subject_name']} selected. '
        'Use left or right to change subject.',
      );
    }

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => KeypadInstructionWrapper(
        screenName: 'Assign ${teacher['name']} to a class and subject',
        labels: const {0: 'Cancel', 1: 'Assign'},
        actions: {
          0: () => Navigator.pop(dialogContext, false),
          1: () => Navigator.pop(dialogContext, true),
        },
        focusTargets: [
          for (final entry in assignments)
            KeypadFocusTarget(
              node: assignmentNodes[entry['assignment_id']]!,
              label:
                  '${entry['class_name']}, ${entry['subject_name']}. Remove assignment',
              onActivate: () => _removeTeacherAssignment(
                teacher,
                Map<String, dynamic>.from(entry as Map),
                dialogContext,
              ),
            ),
          KeypadFocusTarget(
            node: classNode,
            label: 'Choose class. Use left or right to change',
            onActivate: () => moveTeacherClass(1),
            onDecrease: () => moveTeacherClass(-1),
            onIncrease: () => moveTeacherClass(1),
          ),
          KeypadFocusTarget(
            node: subjectNode,
            label: 'Choose subject. Use left or right to change',
            onActivate: () => moveSubject(1),
            onDecrease: () => moveSubject(-1),
            onIncrease: () => moveSubject(1),
          ),
          KeypadFocusTarget(
            node: cancelNode,
            label: 'Cancel',
            onActivate: () => Navigator.pop(dialogContext, false),
          ),
          KeypadFocusTarget(
            node: assignNode,
            label: 'Save assignment',
            onActivate: () => Navigator.pop(dialogContext, true),
          ),
        ],
        child: StatefulBuilder(
          builder: (context, setLocal) {
            updateDialog = setLocal;
            return AlertDialog(
              title: Text('Assign ${teacher['name']}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (assignments.isNotEmpty) ...[
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Current assignments'),
                    ),
                    const SizedBox(height: 8),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 180),
                      child: SingleChildScrollView(
                        child: Column(
                          children: assignments.map<Widget>((entry) {
                            final assignmentId = entry['assignment_id'] as int;
                            return ListTile(
                              dense: true,
                              title: Text('${entry['class_name']}'),
                              subtitle: Text('${entry['subject_name']}'),
                              trailing: IconButton(
                                focusNode: assignmentNodes[assignmentId],
                                tooltip: 'Remove assignment',
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: () => _removeTeacherAssignment(
                                  teacher,
                                  Map<String, dynamic>.from(entry as Map),
                                  dialogContext,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const Divider(),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Add an assignment'),
                    ),
                  ],
                  DropdownButtonFormField<int>(
                    key: ValueKey('teacher-class-$classId'),
                    focusNode: classNode,
                    initialValue: classId,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Class'),
                    items: activeClasses
                        .map<DropdownMenuItem<int>>(
                          (entry) => DropdownMenuItem(
                            value: entry['class_id'] as int,
                            child: Text('${entry['name']}'),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) selectClass(value);
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    key: ValueKey('teacher-subject-$subjectId'),
                    focusNode: subjectNode,
                    initialValue: subjectId,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Subject'),
                    items: classSubjects
                        .map<DropdownMenuItem<int>>(
                          (entry) => DropdownMenuItem(
                            value: entry['subject_id'] as int,
                            child: Text('${entry['subject_name']}'),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setLocal(() => subjectId = value);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  focusNode: cancelNode,
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Cancel (0)'),
                ),
                FilledButton(
                  focusNode: assignNode,
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: const Text('Assign (1)'),
                ),
              ],
            );
          },
        ),
      ),
    );
    classNode.dispose();
    subjectNode.dispose();
    cancelNode.dispose();
    assignNode.dispose();
    for (final node in assignmentNodes.values) {
      node.dispose();
    }
    if (confirmed != true) return;
    final result = await ApiService.assignTeacher(
      teacher['user_id'] as int,
      classId,
      subjectId,
    );
    await _announceResult(result != null, 'Teacher assignment saved');
  }

  Future<void> _removeTeacherAssignment(
    Map<String, dynamic> teacher,
    Map<String, dynamic> assignment,
    BuildContext dialogContext,
  ) async {
    final remove = await showDialog<bool>(
      context: dialogContext,
      builder: (_) => KeypadConfirmationDialog(
        title: 'Remove assignment?',
        message:
            'Remove ${teacher['name']} from ${assignment['class_name']}, ${assignment['subject_name']}?',
        cancelLabel: 'Keep',
        confirmLabel: 'Remove',
        cancelKey: 0,
        confirmKey: 1,
      ),
    );
    if (remove != true) return;
    final removed = await ApiService.archiveTeacherAssignment(
      teacher['user_id'] as int,
      assignment['assignment_id'] as int,
    );
    if (dialogContext.mounted) {
      Navigator.pop(dialogContext, false);
    }
    await _announceResult(removed, 'Teacher assignment removed');
  }

  List<KeypadFocusTarget> _focusTargets() {
    final targets = <KeypadFocusTarget>[
      KeypadFocusTarget(
        node: _refreshNode,
        label: 'Refresh admin data',
        onActivate: _refresh,
      ),
      KeypadFocusTarget(
        node: _searchNode,
        label: 'Search users',
        isTextField: true,
      ),
      KeypadFocusTarget(
        node: _roleFilterNode,
        label:
            'Account type filter. ${_roleFilterLabel()}. Use left or right to change',
        onActivate: () => _cycleRoleFilter(1),
        onDecrease: () => _cycleRoleFilter(-1),
        onIncrease: () => _cycleRoleFilter(1),
      ),
      KeypadFocusTarget(
        node: _assignmentFilterNode,
        label:
            'Assignment filter. ${_assignmentFilterLabel()}. Use left or right to change',
        onActivate: () => _cycleAssignmentFilter(1),
        onDecrease: () => _cycleAssignmentFilter(-1),
        onIncrease: () => _cycleAssignmentFilter(1),
      ),
      KeypadFocusTarget(
        node: _subjectNode,
        label: 'Create subject',
        onActivate: _addSubject,
      ),
      KeypadFocusTarget(
        node: _classNode,
        label: 'Create class',
        onActivate: _addClass,
      ),
    ];
    for (final entry in _classes) {
      final schoolClass = Map<String, dynamic>.from(entry as Map);
      final id = schoolClass['class_id'] as int;
      targets.add(
        KeypadFocusTarget(
          node: _classNodes.putIfAbsent(
            id,
            () => FocusNode(debugLabel: 'admin-class-$id'),
          ),
          label:
              '${schoolClass['name']}, ${schoolClass['is_active'] == true ? 'active' : 'archived'}. Press OK to ${schoolClass['is_active'] == true ? 'manage subjects' : 'restore'}',
          onActivate: () => schoolClass['is_active'] == true
              ? _manageClassSubjects(schoolClass)
              : _toggleClass(schoolClass),
        ),
      );
    }
    for (final entry in _subjects) {
      final subject = Map<String, dynamic>.from(entry as Map);
      final id = subject['subject_id'] as int;
      targets.add(
        KeypadFocusTarget(
          node: _subjectNodes.putIfAbsent(
            id,
            () => FocusNode(debugLabel: 'admin-subject-$id'),
          ),
          label:
              '${subject['name']}, ${subject['is_active'] == true ? 'active' : 'archived'}. Press OK to ${subject['is_active'] == true ? 'archive' : 'restore'}',
          onActivate: () => _toggleSubject(subject),
        ),
      );
    }
    for (final entry in _orderedUsers) {
      final user = Map<String, dynamic>.from(entry as Map);
      final id = user['user_id'] as int;
      final node = _userNodes.putIfAbsent(
        id,
        () => FocusNode(debugLabel: 'admin-user-$id'),
      );
      final accessDescription = user['role'] == 'student'
          ? (user['class_name'] ?? 'No class assigned')
          : '${user['assignment_count']} assignments';
      targets.add(
        KeypadFocusTarget(
          node: node,
          label:
              '${user['name']}, ${user['role']}. $accessDescription. Press OK to manage',
          onActivate: () => _manageUser(user),
        ),
      );
    }
    targets.add(
      KeypadFocusTarget(
        node: _logoutNode,
        label: 'Log out',
        onActivate: () => AuthSessionService.logoutFrom(context),
      ),
    );
    return targets;
  }

  @override
  Widget build(BuildContext context) {
    return KeypadInstructionWrapper(
      screenName: 'Administrator Dashboard',
      labels: adminDashboardKeyLabels,
      autoPlay: false,
      actions: {
        0: () => AuthSessionService.logoutFrom(context),
        1: _refresh,
        2: _focusSearch,
        3: () => _cycleRoleFilter(1),
        4: () => _cycleAssignmentFilter(1),
        5: _addSubject,
        6: _addClass,
      },
      navigationController: _keypad,
      focusTargets: _focusTargets(),
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) SystemNavigator.pop();
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('SEEDS Administration'),
            actions: [
              IconButton(
                focusNode: _refreshNode,
                onPressed: _refresh,
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh',
              ),
              IconButton(
                focusNode: _logoutNode,
                onPressed: () => AuthSessionService.logoutFrom(context),
                icon: const Icon(Icons.logout),
                tooltip: 'Log out',
              ),
            ],
          ),
          body: SafeArea(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: UIUtils.paddingAll(context, 16),
                    children: [
                      TextField(
                        controller: _searchController,
                        focusNode: _searchNode,
                        onTap: () => _keypad.enterTextEditing(_searchNode),
                        onSubmitted: (_) => _refresh(),
                        decoration: const InputDecoration(
                          labelText: '2. Search by name or phone number',
                          prefixIcon: Icon(Icons.search),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Focus(
                        focusNode: _roleFilterNode,
                        child: Semantics(
                          label:
                              'Account type filter. ${_roleFilterLabel()}. Use left and right arrows to change.',
                          liveRegion: true,
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              ChoiceChip(
                                avatar: const Icon(Icons.groups_outlined),
                                label: const Text('3 All accounts'),
                                selected: _roleFilter == null,
                                onSelected: (_) => _setRoleFilter(null),
                              ),
                              ChoiceChip(
                                avatar: const Icon(Icons.school_outlined),
                                label: const Text('Students'),
                                selected: _roleFilter == 'student',
                                onSelected: (_) => _setRoleFilter('student'),
                              ),
                              ChoiceChip(
                                avatar: const Icon(Icons.person_outline),
                                label: const Text('Teachers'),
                                selected: _roleFilter == 'teacher',
                                onSelected: (_) => _setRoleFilter('teacher'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Focus(
                        focusNode: _assignmentFilterNode,
                        child: Semantics(
                          label:
                              'Assignment filter. ${_assignmentFilterLabel()}. Use left and right arrows to change.',
                          liveRegion: true,
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              ChoiceChip(
                                label: const Text('4 All'),
                                selected: _assignmentStatus == 'all',
                                onSelected: (_) async {
                                  setState(() => _assignmentStatus = 'all');
                                  await _refresh();
                                },
                              ),
                              ChoiceChip(
                                label: Text(
                                  _roleFilter == 'student'
                                      ? 'Enrolled'
                                      : _roleFilter == 'teacher'
                                      ? 'Assigned'
                                      : 'Enrolled or assigned',
                                ),
                                selected: _assignmentStatus == 'assigned',
                                onSelected: (_) async {
                                  setState(
                                    () => _assignmentStatus = 'assigned',
                                  );
                                  await _refresh();
                                },
                              ),
                              ChoiceChip(
                                label: const Text('Unassigned'),
                                selected: _assignmentStatus == 'unassigned',
                                onSelected: (_) async {
                                  setState(
                                    () => _assignmentStatus = 'unassigned',
                                  );
                                  await _refresh();
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          FilledButton.icon(
                            focusNode: _subjectNode,
                            onPressed: _addSubject,
                            icon: const Icon(Icons.menu_book),
                            label: const Text('5. Create subject'),
                          ),
                          OutlinedButton.icon(
                            focusNode: _classNode,
                            onPressed: _addClass,
                            icon: const Icon(Icons.class_outlined),
                            label: const Text('6. Create class'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Classes',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _classes.map((entry) {
                          final schoolClass = Map<String, dynamic>.from(
                            entry as Map,
                          );
                          final id = schoolClass['class_id'] as int;
                          return InputChip(
                            focusNode: _classNodes.putIfAbsent(
                              id,
                              () => FocusNode(debugLabel: 'admin-class-$id'),
                            ),
                            avatar: Icon(
                              schoolClass['is_active'] == true
                                  ? Icons.check_circle_outline
                                  : Icons.archive_outlined,
                            ),
                            label: Text(
                              '${schoolClass['name']} · ${schoolClass['is_active'] == true ? 'Active' : 'Archived'}',
                            ),
                            tooltip: schoolClass['is_active'] == true
                                ? 'Manage class subjects'
                                : 'Archived class',
                            onPressed: schoolClass['is_active'] == true
                                ? () => _manageClassSubjects(schoolClass)
                                : null,
                            onDeleted: () => _toggleClass(schoolClass),
                            deleteIcon: Icon(
                              schoolClass['is_active'] == true
                                  ? Icons.archive_outlined
                                  : Icons.unarchive_outlined,
                            ),
                            deleteButtonTooltipMessage:
                                schoolClass['is_active'] == true
                                ? 'Archive class'
                                : 'Restore class',
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Subjects',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _subjects.map((entry) {
                          final subject = Map<String, dynamic>.from(
                            entry as Map,
                          );
                          final id = subject['subject_id'] as int;
                          return ActionChip(
                            focusNode: _subjectNodes.putIfAbsent(
                              id,
                              () => FocusNode(debugLabel: 'admin-subject-$id'),
                            ),
                            avatar: Icon(
                              subject['is_active'] == true
                                  ? Icons.check_circle_outline
                                  : Icons.archive_outlined,
                            ),
                            label: Text(
                              '${subject['name']} · ${subject['is_active'] == true ? 'Active' : 'Archived'}',
                            ),
                            onPressed: () => _toggleSubject(subject),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Accounts',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      if (_users.isEmpty)
                        Semantics(
                          liveRegion: true,
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Text('No matching accounts.'),
                          ),
                        ),
                      if (_roleFilter == null) ...[
                        ..._accountSection(
                          'Teachers',
                          _users.where((entry) => entry['role'] == 'teacher'),
                        ),
                        ..._accountSection(
                          'Students',
                          _users.where((entry) => entry['role'] == 'student'),
                        ),
                      ] else
                        ..._users.map(_accountCard),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
