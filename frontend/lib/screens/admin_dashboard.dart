import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/api_service.dart';
import '../services/auth_session_service.dart';
import '../services/tts_service.dart';
import '../utils/keypad_actions.dart';
import '../utils/ui_utils.dart';
import '../widgets/key_instruction_wrapper.dart';
import '../widgets/keypad_confirmation_dialog.dart';
import '../widgets/admin_password_reset_dialog.dart';
import '../widgets/numbered_menu.dart';
import '../widgets/keypad_paged_list.dart';

enum _AdminSection { accounts, classes, subjects }

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
  final _sectionNode = FocusNode(debugLabel: 'admin-sections');
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
  _AdminSection _section = _AdminSection.accounts;
  int _refreshGeneration = 0;
  String? _issue;

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
    _sectionNode.dispose();
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

  Future<void> _refresh({
    FocusNode? retainFocus,
    String? filterFeedback,
  }) async {
    final generation = ++_refreshGeneration;
    if (mounted) {
      setState(() {
        _loading = true;
        _issue = null;
      });
    }
    final query = Uri(
      queryParameters: {
        if (_searchController.text.trim().isNotEmpty)
          'search': _searchController.text.trim(),
        if (_roleFilter != null) 'role': _roleFilter!,
        'assignment_status': _assignmentStatus,
      },
    ).query;
    final results = await Future.wait([
      ApiService.getResult(
        '/admin/users?$query',
        useAuth: true,
        requestTimeout: const Duration(seconds: 20),
      ),
      ApiService.getResult(
        '/catalog/classes?include_archived=true',
        useAuth: true,
        requestTimeout: const Duration(seconds: 20),
      ),
      ApiService.getResult(
        '/catalog/subjects?include_archived=true',
        useAuth: true,
        requestTimeout: const Duration(seconds: 20),
      ),
    ]);
    if (!mounted || generation != _refreshGeneration) return;
    if (results.any((result) => !result.isSuccess || result.data is! List)) {
      final failure = results
          .where((result) => !result.isSuccess)
          .firstOrNull
          ?.failure;
      final message =
          '${failure?.message ?? 'The administration list could not be read.'} '
          'Administration data was not refreshed. Press 1 to retry.';
      setState(() {
        _loading = false;
        _issue = message;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || generation != _refreshGeneration) return;
        if (retainFocus?.context != null) {
          _keypad.focusAndAnnounce(
            retainFocus!,
            '${filterFeedback ?? ''} $message',
          );
        } else {
          TtsService.speak(message);
        }
      });
      return;
    }
    setState(() {
      _users = results[0].data as List;
      _classes = results[1].data as List;
      _subjects = results[2].data as List;
      _loading = false;
    });
    final summary =
        '${_users.length} accounts shown. ${_classes.length} classes and ${_subjects.length} subjects.';
    if (_initialAnnouncementPending) {
      _initialAnnouncementPending = false;
      await TtsService.speak(
        '${buildTtsInstructions(_sectionKeyLabels, screenName: _sectionTitle)} '
        'Use D-pad up and down to explore $_sectionNavigation. Press OK to select. $summary',
      );
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || generation != _refreshGeneration) return;
        final message = '${filterFeedback ?? ''} $summary';
        if (retainFocus?.context != null) {
          _keypad.focusAndAnnounce(retainFocus!, message);
        } else {
          TtsService.speak(message);
        }
      });
    }
  }

  String get _sectionTitle => 'Administration. ${_section.name} section';

  String get _sectionNavigation => switch (_section) {
    _AdminSection.accounts =>
      'account search, account type and enrollment filters, and account management. '
          'Use left or right on a filter to change it',
    _AdminSection.classes =>
      'create class and the list of active or archived classes. '
          'Press OK on a class for its subject assignments and archive or restore actions',
    _AdminSection.subjects =>
      'create subject and the list of active or archived subjects. '
          'Press OK on a subject to archive or restore it',
  };

  Map<int, String> get _sectionKeyLabels => {
    0: adminDashboardKeyLabels[0]!,
    1: adminDashboardKeyLabels[1]!,
    if (_section == _AdminSection.accounts)
      for (final key in [2, 3, 4]) key: adminDashboardKeyLabels[key]!,
    if (_section == _AdminSection.subjects) 5: adminDashboardKeyLabels[5]!,
    if (_section == _AdminSection.classes) 6: adminDashboardKeyLabels[6]!,
    7: adminDashboardKeyLabels[7]!,
  };

  Future<void> _chooseSection() async {
    final section = await Navigator.push<_AdminSection>(
      context,
      MaterialPageRoute(
        builder: (menuContext) => NumberedMenu(
          title: 'Administration sections',
          choices: [
            for (final section in _AdminSection.values)
              NumberedChoice(
                label: switch (section) {
                  _AdminSection.accounts => 'Accounts and enrollment',
                  _AdminSection.classes => 'Classes and their subjects',
                  _AdminSection.subjects => 'Subjects',
                },
                onSelected: () => Navigator.pop(menuContext, section),
              ),
          ],
        ),
      ),
    );
    if (!mounted || section == null) return;
    setState(() => _section = section);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _keypad.focusAndAnnounce(
        _sectionNode,
        '${section.name} section. Use the D-pad to explore '
        '${section == _AdminSection.accounts
            ? 'account filters, search and account management'
            : section == _AdminSection.classes
            ? 'class creation, subject assignments, and archive or restore actions'
            : 'subject creation and archive or restore actions'}. '
        'Press 7 to change section.',
      );
    });
  }

  void _focusSearch() {
    setState(() => _section = _AdminSection.accounts);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _searchNode.requestFocus();
      _keypad.enterTextEditing(_searchNode);
    });
  }

  Future<void> _setRoleFilter(String? role) async {
    if (_roleFilter == role) return;
    setState(() {
      _section = _AdminSection.accounts;
      _roleFilter = role;
      _assignmentStatus = 'all';
    });
    await _refresh(
      retainFocus: _roleFilterNode,
      filterFeedback: 'Account type filter button. ${_roleFilterLabel()}.',
    );
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
    await _setAssignmentFilter(filters[next]);
  }

  Future<void> _setAssignmentFilter(String value) async {
    setState(() {
      _section = _AdminSection.accounts;
      _assignmentStatus = value;
    });
    await _refresh(
      retainFocus: _assignmentFilterNode,
      filterFeedback: 'Assignment filter button. ${_assignmentFilterLabel()}.',
    );
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

  Future<void> _manageClass(Map<String, dynamic> schoolClass) async {
    final active = schoolClass['is_active'] == true;
    final action = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (menuContext) => NumberedMenu(
          title: 'Manage ${schoolClass['name']}',
          choices: [
            if (active)
              NumberedChoice(
                label: 'Manage class subjects',
                onSelected: () => Navigator.pop(menuContext, 'subjects'),
              ),
            NumberedChoice(
              label: active
                  ? 'Archive class with confirmation'
                  : 'Restore class with confirmation',
              onSelected: () => Navigator.pop(menuContext, 'archive'),
            ),
          ],
        ),
      ),
    );
    if (!mounted || action == null) return;
    if (action == 'subjects') {
      await _manageClassSubjects(schoolClass);
    } else {
      await _toggleClass(schoolClass);
    }
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
    final subjects = _subjects
        .map((entry) => Map<String, dynamic>.from(entry as Map))
        .where(
          (subject) =>
              subject['is_active'] == true ||
              activeBySubject.containsKey(subject['subject_id']),
        )
        .toList();
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (listContext) => KeypadPagedList<Map<String, dynamic>>(
          title: 'Subjects for ${schoolClass['name']}',
          scope: schoolClass['class_id'] as int,
          loadPage: (query) async {
            final matches = subjects
                .where(
                  (subject) => '${subject['name']}'.toLowerCase().contains(
                    query.search.trim().toLowerCase(),
                  ),
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
          labelOf: (subject) =>
              '${subject['name']}. '
              '${activeBySubject.containsKey(subject['subject_id']) ? 'Available in this class. Select to remove' : 'Not available in this class. Select to add'}',
          onSelected: (subject) {
            final association = activeBySubject[subject['subject_id']];
            Navigator.pop(listContext, {
              'subject_id': subject['subject_id'],
              'association_id': association?['association_id'],
              'remove': association != null,
            });
          },
        ),
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
    final nodes = List.generate(
      3,
      (i) => FocusNode(debugLabel: 'admin-account-action-$i'),
    );
    final action = await showDialog<int>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => KeypadInstructionWrapper(
        screenName:
            'Manage selected account. Choose assignments, password recovery, or Cancel.',
        labels: const {
          0: 'Cancel',
          1: 'Manage assignments',
          2: 'Password recovery',
        },
        actions: {
          for (var i = 0; i < 3; i++) i: () => Navigator.pop(dialogContext, i),
        },
        focusTargets: [
          for (var i = 0; i < 3; i++)
            KeypadFocusTarget(
              node: nodes[i],
              label: ['Cancel', 'Manage assignments', 'Password recovery'][i],
              onActivate: () => Navigator.pop(dialogContext, i),
            ),
        ],
        child: AlertDialog(
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Manage ${user['name']}'),
                for (var i = 0; i < 3; i++)
                  TextButton(
                    focusNode: nodes[i],
                    onPressed: () => Navigator.pop(dialogContext, i),
                    child: Text(
                      [
                        '0: Cancel',
                        '1: Manage assignments',
                        '2: Password recovery',
                      ][i],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
    for (final node in nodes) {
      node.dispose();
    }
    if (!mounted) return;
    if (action == 1) {
      if (user['role'] == 'student') {
        await _assignStudent(user);
      } else {
        await _assignTeacher(user);
      }
    } else if (action == 2) {
      final version = user['auth_version'];
      if (version is! int || version < 0) {
        await _announceResult(
          false,
          'Account recovery requires a current server version. Refresh the account.',
        );
        return;
      }
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => AdminPasswordResetDialog(
          accountId: user['user_id'] as int,
          authVersion: version,
          accountName: user['name'].toString(),
          phoneNumber: user['phone_number'].toString(),
        ),
      );
      await _refresh();
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
        node: _sectionNode,
        label: '${_section.name} section. Change administration section',
        onActivate: _chooseSection,
      ),
      if (_section == _AdminSection.accounts) ...[
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
      ],
      if (_section == _AdminSection.subjects)
        KeypadFocusTarget(
          node: _subjectNode,
          label: 'Create subject',
          onActivate: _addSubject,
        ),
      if (_section == _AdminSection.classes)
        KeypadFocusTarget(
          node: _classNode,
          label: 'Create class',
          onActivate: _addClass,
        ),
    ];
    for (final entry
        in _section == _AdminSection.classes ? _classes : const []) {
      final schoolClass = Map<String, dynamic>.from(entry as Map);
      final id = schoolClass['class_id'] as int;
      targets.add(
        KeypadFocusTarget(
          node: _classNodes.putIfAbsent(
            id,
            () => FocusNode(debugLabel: 'admin-class-$id'),
          ),
          label:
              '${schoolClass['name']}, ${schoolClass['is_active'] == true ? 'active' : 'archived'}. Press OK for class subjects and archive or restore actions',
          onActivate: () => _manageClass(schoolClass),
        ),
      );
    }
    for (final entry
        in _section == _AdminSection.subjects ? _subjects : const []) {
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
    for (final entry
        in _section == _AdminSection.accounts && !_loading && _issue == null
            ? _orderedUsers
            : const []) {
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
      screenName: _sectionTitle,
      navigationSections: _sectionNavigation,
      labels: _sectionKeyLabels,
      autoPlay: false,
      actions: {
        0: () => AuthSessionService.logoutFrom(context),
        1: _refresh,
        2: _focusSearch,
        3: () => _cycleRoleFilter(1),
        4: () => _cycleAssignmentFilter(1),
        5: _addSubject,
        6: _addClass,
        7: _chooseSection,
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
            child: ListView(
              padding: UIUtils.paddingAll(context, 16),
              children: [
                if (_loading) const LinearProgressIndicator(),
                if (_issue != null)
                  Semantics(liveRegion: true, child: Text(_issue!)),
                OutlinedButton(
                  focusNode: _sectionNode,
                  onPressed: _chooseSection,
                  child: Text('7. Change section: ${_section.name}'),
                ),
                if (_section == _AdminSection.accounts) ...[
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
                            onSelected: (_) => _setAssignmentFilter('all'),
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
                            onSelected: (_) => _setAssignmentFilter('assigned'),
                          ),
                          ChoiceChip(
                            label: const Text('Unassigned'),
                            selected: _assignmentStatus == 'unassigned',
                            onSelected: (_) =>
                                _setAssignmentFilter('unassigned'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (_section == _AdminSection.subjects)
                      FilledButton.icon(
                        focusNode: _subjectNode,
                        onPressed: _addSubject,
                        icon: const Icon(Icons.menu_book),
                        label: const Text('5. Create subject'),
                      ),
                    if (_section == _AdminSection.classes)
                      OutlinedButton.icon(
                        focusNode: _classNode,
                        onPressed: _addClass,
                        icon: const Icon(Icons.class_outlined),
                        label: const Text('6. Create class'),
                      ),
                  ],
                ),
                if (_section == _AdminSection.classes) ...[
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
                        onPressed: () => _manageClass(schoolClass),
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
                ],
                if (_section == _AdminSection.subjects) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Subjects',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _subjects.map((entry) {
                      final subject = Map<String, dynamic>.from(entry as Map);
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
                ],
                if (_section == _AdminSection.accounts) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Accounts',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  if (!_loading && _issue == null && _users.isEmpty)
                    Semantics(
                      liveRegion: true,
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text('No matching accounts.'),
                      ),
                    ),
                  if (!_loading && _issue == null) ...[
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
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
