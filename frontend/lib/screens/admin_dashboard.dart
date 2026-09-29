import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/api_service.dart';
import '../services/auth_session_service.dart';
import '../services/tts_service.dart';
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
  final _unassignedNode = FocusNode(debugLabel: 'admin-unassigned');
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
  bool _unassignedOnly = false;

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
    _unassignedNode.dispose();
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
        unassignedOnly: _unassignedOnly,
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
    await TtsService.speak(
      '${_users.length} accounts shown. ${_classes.length} classes and ${_subjects.length} subjects.',
    );
  }

  void _focusSearch() {
    _searchNode.requestFocus();
    _keypad.enterTextEditing(_searchNode);
  }

  Future<void> _toggleUnassigned() async {
    setState(() => _unassignedOnly = !_unassignedOnly);
    await _refresh();
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
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => KeypadInstructionWrapper(
        screenName: 'Assign class to ${student['name']}',
        labels: const {0: 'Cancel', 1: 'Assign'},
        actions: {
          0: () => Navigator.pop(dialogContext, false),
          1: () => Navigator.pop(dialogContext, true),
        },
        focusTargets: [
          KeypadFocusTarget(node: classNode, label: 'Choose class'),
          KeypadFocusTarget(
            node: cancelNode,
            label: 'Cancel',
            onActivate: () => Navigator.pop(dialogContext, false),
          ),
          KeypadFocusTarget(
            node: assignNode,
            label: 'Assign class',
            onActivate: () => Navigator.pop(dialogContext, true),
          ),
        ],
        child: StatefulBuilder(
          builder: (context, setLocal) => AlertDialog(
            title: Text('Assign class to ${student['name']}'),
            content: DropdownButtonFormField<int>(
              focusNode: classNode,
              initialValue: classId,
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
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancel (0)'),
              ),
              FilledButton(
                focusNode: assignNode,
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Assign (1)'),
              ),
            ],
          ),
        ),
      ),
    );
    classNode.dispose();
    cancelNode.dispose();
    assignNode.dispose();
    if (confirmed != true) return;
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
    final activeSubjects = _subjects
        .where((entry) => entry['is_active'] == true)
        .toList();
    if (activeClasses.isEmpty || activeSubjects.isEmpty) return;
    final assignments = await ApiService.getTeacherAssignments(
      teacher['user_id'] as int,
    );
    if (!mounted) return;
    int classId = activeClasses.first['class_id'] as int;
    int subjectId = activeSubjects.first['subject_id'] as int;
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
          KeypadFocusTarget(node: classNode, label: 'Choose class'),
          KeypadFocusTarget(node: subjectNode, label: 'Choose subject'),
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
          builder: (context, setLocal) => AlertDialog(
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
                  focusNode: classNode,
                  initialValue: classId,
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
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  focusNode: subjectNode,
                  initialValue: subjectId,
                  decoration: const InputDecoration(labelText: 'Subject'),
                  items: activeSubjects
                      .map<DropdownMenuItem<int>>(
                        (entry) => DropdownMenuItem(
                          value: entry['subject_id'] as int,
                          child: Text('${entry['name']}'),
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
          ),
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
        node: _unassignedNode,
        label: _unassignedOnly
            ? 'Show all accounts'
            : 'Show unassigned accounts',
        onActivate: _toggleUnassigned,
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
              '${schoolClass['name']}, ${schoolClass['is_active'] == true ? 'active' : 'archived'}. Press OK to ${schoolClass['is_active'] == true ? 'archive' : 'restore'}',
          onActivate: () => _toggleClass(schoolClass),
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
    for (final entry in _users) {
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
      labels: const {
        0: 'Log Out',
        1: 'Refresh',
        2: 'Search Users',
        3: 'Toggle Unassigned Accounts',
        4: 'Create Subject',
        5: 'Create Class',
      },
      actions: {
        0: () => AuthSessionService.logoutFrom(context),
        1: _refresh,
        2: _focusSearch,
        3: _toggleUnassigned,
        4: _addSubject,
        5: _addClass,
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
                      Focus(
                        focusNode: _unassignedNode,
                        child: SwitchListTile(
                          secondary: const Icon(Icons.person_off_outlined),
                          title: const Text('3. Unassigned accounts only'),
                          value: _unassignedOnly,
                          onChanged: (_) => _toggleUnassigned(),
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
                            label: const Text('4. Create subject'),
                          ),
                          OutlinedButton.icon(
                            focusNode: _classNode,
                            onPressed: _addClass,
                            icon: const Icon(Icons.class_outlined),
                            label: const Text('5. Create class'),
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
                          return ActionChip(
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
                            onPressed: () => _toggleClass(schoolClass),
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
                      ..._users.map((entry) {
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
                            subtitle: Text(
                              '${user['role']} · $detail\n${user['phone_number']}',
                            ),
                            isThreeLine: true,
                            trailing: const Icon(Icons.edit_outlined),
                            onTap: () => _manageUser(user),
                          ),
                        );
                      }),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
