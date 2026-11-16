import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/speech.dart';
import '../services/api_service.dart';
import '../services/auth_session_service.dart';
import '../services/tts_service.dart';
import '../announcers/admin_text.dart';
import '../services/message_center.dart';
import '../widgets/keypad_choice_field.dart';
import '../utils/keypad_actions.dart';
import '../utils/ui_utils.dart';
import '../widgets/key_instruction_wrapper.dart';
import '../widgets/keypad_confirmation_dialog.dart';
import '../widgets/admin_password_reset_dialog.dart';
import '../widgets/numbered_menu.dart';
import '../widgets/keypad_paged_list.dart';
import '../widgets/accessible_tile.dart';

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
  String _summary = '';

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
      final message = Speech.t.adminNotRefreshed(
        failure?.message ?? Speech.t.adminListReadFailed,
      );
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
      _summary = _resultSummary();
    });
    final summary = _summary;
    if (_initialAnnouncementPending) {
      _initialAnnouncementPending = false;
      await TtsService.speak(
        '${buildTtsInstructions(_sectionKeyLabels, screenName: _sectionTitle)} '
        '${Speech.t.adminExploreIntro(_sectionNavigation)} $summary',
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

  String get _sectionTitle =>
      Speech.t.adminSectionTitle(_sectionName(_section));

  /// Spoken section name, e.g. "accounts".
  String _sectionName(_AdminSection section) => switch (section) {
    _AdminSection.accounts => Speech.t.adminSectionNameAccounts,
    _AdminSection.classes => Speech.t.adminSectionNameClasses,
    _AdminSection.subjects => Speech.t.adminSectionNameSubjects,
  };

  /// Result counts for the current section, naming the active search so the
  /// user knows why the list changed.
  String _resultSummary() {
    final t = Speech.t;
    final search = _searchController.text.trim();
    return switch (_section) {
      _AdminSection.accounts =>
        _users.isEmpty
            ? (search.isEmpty
                  ? t.adminNoMatchingAccounts
                  : t.adminNoMatchingAccountsFor(search))
            : search.isEmpty
            ? t.adminAccountsSummary(
                _users.length,
                t.adminClasses(_classes.length),
                t.adminSubjects(_subjects.length),
              )
            : t.adminAccountsSummarySearch(
                _users.length,
                search,
                t.adminClasses(_classes.length),
                t.adminSubjects(_subjects.length),
              ),
      _AdminSection.classes => t.adminClassesSentence(_classes.length),
      _AdminSection.subjects => t.adminSubjectsSentence(_subjects.length),
    };
  }

  String get _sectionNavigation => switch (_section) {
    _AdminSection.accounts => Speech.t.adminNavigationAccounts,
    _AdminSection.classes => Speech.t.adminNavigationClasses,
    _AdminSection.subjects => Speech.t.adminNavigationSubjects,
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
          title: Speech.t.adminSectionsTitle,
          choices: [
            for (final section in _AdminSection.values)
              NumberedChoice(
                label: switch (section) {
                  _AdminSection.accounts => Speech.t.adminSectionAccounts,
                  _AdminSection.classes => Speech.t.adminSectionClasses,
                  _AdminSection.subjects => Speech.t.adminSectionSubjects,
                },
                onSelected: () => Navigator.pop(menuContext, section),
              ),
          ],
        ),
      ),
    );
    if (!mounted || section == null) return;
    setState(() {
      _section = section;
      if (!_loading && _issue == null) _summary = _resultSummary();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final t = Speech.t;
      final explore = switch (section) {
        _AdminSection.accounts => t.adminExploreAccounts,
        _AdminSection.classes => t.adminExploreClasses,
        _AdminSection.subjects => t.adminExploreSubjects,
      };
      _keypad.focusAndAnnounce(
        _sectionNode,
        '${t.adminSectionChosen(_sectionName(section))} '
        '${_issue == null ? _summary : ''} '
        '${t.adminSectionExplore(explore)}',
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
      filterFeedback: Speech.t.adminRoleFilterSelected(_roleFilterLabel()),
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
      filterFeedback: Speech.t.adminAssignmentFilterSelected(
        _assignmentFilterLabel(),
      ),
    );
  }

  String _roleFilterLabel() => switch (_roleFilter) {
    'student' => Speech.t.adminRoleFilterStudents,
    'teacher' => Speech.t.adminRoleFilterTeachers,
    _ => Speech.t.adminRoleFilterAll,
  };

  String _assignmentFilterLabel() => switch (_assignmentStatus) {
    'assigned' =>
      _roleFilter == 'student'
          ? Speech.t.adminAssignmentEnrolled
          : _roleFilter == 'teacher'
          ? Speech.t.adminAssignmentAssigned
          : Speech.t.adminAssignmentEnrolledOrAssigned,
    'unassigned' => Speech.t.adminAssignmentUnassigned,
    _ => Speech.t.adminAssignmentAll,
  };

  /// Spoken role word for an account ("student" or "teacher").
  String _roleName(Object? role) => switch (role) {
    'student' => Speech.t.adminRoleStudent,
    'teacher' => Speech.t.adminRoleTeacher,
    _ => '$role',
  };

  List<dynamic> get _orderedUsers {
    if (_roleFilter != null) return _users;
    return [
      ..._users.where((entry) => entry['role'] == 'teacher'),
      ..._users.where((entry) => entry['role'] == 'student'),
    ];
  }

  String _accountLabel(Map<String, dynamic> user) {
    final t = Speech.t;
    final accessDescription = user['role'] == 'student'
        ? (user['class_name'] ?? t.adminNoClassAssigned)
        : t.adminAssignmentCount('${user['assignment_count']}');
    return t.adminAccountLabel(
      '${user['name']}',
      _roleName(user['role']),
      '$accessDescription',
    );
  }

  Widget _accountCard(dynamic entry) {
    final user = Map<String, dynamic>.from(entry as Map);
    final id = user['user_id'] as int;
    final detail = user['role'] == 'student'
        ? (user['class_name'] ?? Speech.t.adminNoClassAssigned)
        : Speech.t.adminActiveAssignmentCount('${user['assignment_count']}');
    return AccessibleTile(
      focusNode: _userNodes.putIfAbsent(
        id,
        () => FocusNode(debugLabel: 'admin-user-$id'),
      ),
      title: '${user['name']}',
      status: user['role'] == 'student' ? 'Student' : 'Teacher',
      subtitle: '$detail\n${user['phone_number']}',
      semanticLabel: _accountLabel(user),
      onActivate: () => _manageUser(user),
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
            Speech.t.adminHeadingCount(heading, '${entries.length}'),
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
        labels: {0: Speech.t.adminCancel, 1: Speech.t.adminSave},
        actions: {
          0: () => Navigator.pop(dialogContext),
          1: () => Navigator.pop(dialogContext, controller.text.trim()),
        },
        navigationController: dialogKeypad,
        focusTargets: [
          KeypadFocusTarget(node: fieldNode, label: label, isTextField: true),
          KeypadFocusTarget(
            node: cancelNode,
            label: Speech.t.adminCancel,
            onActivate: () => Navigator.pop(dialogContext),
          ),
          KeypadFocusTarget(
            node: saveNode,
            label: Speech.t.adminSave,
            onActivate: () =>
                Navigator.pop(dialogContext, controller.text.trim()),
          ),
        ],
        child: AlertDialog(
          scrollable: true,
          insetPadding: const EdgeInsets.all(8),
          title: Text(title),
          content: TextField(
            controller: controller,
            focusNode: fieldNode,
            onTap: () => dialogKeypad.enterTextEditing(fieldNode),
            decoration: InputDecoration(
              labelText: label,
              helperText: Speech.t.adminTextDialogHelper,
              helperMaxLines: 10,
            ),
          ),
          actions: [
            TextButton(
              focusNode: cancelNode,
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(Speech.t.libraryCancelKey0Button),
            ),
            FilledButton(
              focusNode: saveNode,
              onPressed: () =>
                  Navigator.pop(dialogContext, controller.text.trim()),
              child: Text(Speech.t.adminSaveKey1),
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
      title: Speech.t.adminCreateSubjectTitle,
      label: Speech.t.adminSubjectNameField,
    );
    if (name == null) return;
    if (name.isEmpty) {
      await TtsService.speak(AdminText.noSubjectName);
      return;
    }
    final result = await ApiService.createSubject(name);
    await _announceResult(result != null, Speech.t.adminSubjectCreated(name));
  }

  Future<void> _addClass() async {
    final name = await _textDialog(
      title: Speech.t.adminCreateClassTitle,
      label: Speech.t.adminClassNameField,
    );
    if (name == null) return;
    if (name.isEmpty) {
      await TtsService.speak(AdminText.noClassName);
      return;
    }
    final activeOrders = _classes
        .map((entry) => int.tryParse('${entry['sort_order']}') ?? 0)
        .toList();
    final nextOrder = activeOrders.isEmpty
        ? 0
        : activeOrders.reduce((a, b) => a > b ? a : b) + 1;
    final result = await ApiService.createClass(name, nextOrder);
    await _announceResult(result != null, Speech.t.adminClassCreated(name));
  }

  Future<void> _announceResult(
    bool success,
    String successMessage, {
    String? failureMessage,
  }) async {
    final message = success
        ? successMessage
        : failureMessage ?? AdminText.saveFailed;
    if (success) {
      // The refresh speaks this message together with the new counts.
      MessageCenter.show('$message.', kind: MessageKind.success, speak: false);
      await _refresh(filterFeedback: '$message.');
    } else {
      MessageCenter.error(message);
    }
  }

  Future<void> _toggleClass(Map<String, dynamic> schoolClass) async {
    final currentlyActive = schoolClass['is_active'] == true;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => KeypadConfirmationDialog(
        title: currentlyActive
            ? Speech.t.adminArchiveClassTitle
            : Speech.t.adminRestoreClassTitle,
        message: currentlyActive
            ? Speech.t.adminArchiveItemMessage('${schoolClass['name']}')
            : Speech.t.adminRestoreItemMessage('${schoolClass['name']}'),
        cancelLabel: Speech.t.adminCancel,
        confirmLabel: currentlyActive
            ? Speech.t.adminArchive
            : Speech.t.adminRestore,
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
      currentlyActive
          ? Speech.t.adminClassArchived
          : Speech.t.adminClassRestored,
    );
  }

  Future<void> _manageClass(Map<String, dynamic> schoolClass) async {
    final active = schoolClass['is_active'] == true;
    final action = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (menuContext) => NumberedMenu(
          title: Speech.t.adminManageTitle('${schoolClass['name']}'),
          choices: [
            if (active)
              NumberedChoice(
                label: Speech.t.adminManageClassSubjects,
                onSelected: () => Navigator.pop(menuContext, 'subjects'),
              ),
            NumberedChoice(
              label: active
                  ? Speech.t.adminArchiveClassChoice
                  : Speech.t.adminRestoreClassChoice,
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
          title: Speech.t.adminSubjectsForClass('${schoolClass['name']}'),
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
              activeBySubject.containsKey(subject['subject_id'])
              ? Speech.t.adminSubjectInClass('${subject['name']}')
              : Speech.t.adminSubjectNotInClass('${subject['name']}'),
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
          ? Speech.t.adminSubjectRemovedFrom('${schoolClass['name']}')
          : Speech.t.adminSubjectAddedTo('${schoolClass['name']}'),
    );
  }

  Future<void> _toggleSubject(Map<String, dynamic> subject) async {
    final currentlyActive = subject['is_active'] == true;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => KeypadConfirmationDialog(
        title: currentlyActive
            ? Speech.t.adminArchiveSubjectTitle
            : Speech.t.adminRestoreSubjectTitle,
        message: currentlyActive
            ? Speech.t.adminArchiveItemMessage('${subject['name']}')
            : Speech.t.adminRestoreItemMessage('${subject['name']}'),
        cancelLabel: Speech.t.adminCancel,
        confirmLabel: currentlyActive
            ? Speech.t.adminArchive
            : Speech.t.adminRestore,
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
      currentlyActive
          ? Speech.t.adminSubjectArchived
          : Speech.t.adminSubjectRestored,
    );
  }

  Future<void> _manageUser(Map<String, dynamic> user) async {
    final nodes = List.generate(
      3,
      (i) => FocusNode(debugLabel: 'admin-account-action-$i'),
    );
    final t = Speech.t;
    final actionLabels = [
      t.adminCancel,
      t.adminManageAssignments,
      t.adminPasswordRecovery,
    ];
    final action = await showDialog<int>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => KeypadInstructionWrapper(
        screenName: t.adminManageUserScreen('${user['name']}'),
        labels: {for (var i = 0; i < 3; i++) i: actionLabels[i]},
        actions: {
          for (var i = 0; i < 3; i++) i: () => Navigator.pop(dialogContext, i),
        },
        focusTargets: [
          for (var i = 0; i < 3; i++)
            KeypadFocusTarget(
              node: nodes[i],
              label: actionLabels[i],
              onActivate: () => Navigator.pop(dialogContext, i),
            ),
        ],
        child: AlertDialog(
          insetPadding: const EdgeInsets.all(8),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  Speech.t.adminManageUser('${user['name']}'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                for (var i = 0; i < 3; i++)
                  TextButton(
                    focusNode: nodes[i],
                    onPressed: () => Navigator.pop(dialogContext, i),
                    child: Text(
                      [
                        Speech.t.uiCancelKey0,
                        Speech.t.adminManageAssignmentsKey1,
                        Speech.t.adminPasswordRecoveryKey2,
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
          '',
          failureMessage: Speech.t.adminRecoveryNeedsVersion,
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
    if (activeClasses.isEmpty) {
      await TtsService.speak(Speech.t.adminNoActiveClasses);
      return;
    }
    final t = Speech.t;
    final currentClassId = int.tryParse('${student['class_id']}');
    final currentClassName = student['class_name'] ?? t.adminTheCurrentClass;
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
        AdminText.choiceChanged(
          '${activeClasses[next]['name']}',
          next,
          activeClasses.length,
        ),
      );
    }

    final action = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => KeypadInstructionWrapper(
        screenName: t.adminAssignClassTo('${student['name']}'),
        labels: {
          0: t.adminCancel,
          1: t.adminAssign,
          if (currentClassId != null) 2: t.adminRemoveClass,
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
            label: AdminText.choiceLabel(
              t.adminClassField,
              '${activeClasses.firstWhere((e) => e['class_id'] == classId, orElse: () => activeClasses.first)['name']}',
              activeClasses
                  .indexWhere((e) => e['class_id'] == classId)
                  .clamp(0, activeClasses.length),
              activeClasses.length,
            ),
            onActivate: () => moveClass(1),
            onDecrease: () => moveClass(-1),
            onIncrease: () => moveClass(1),
          ),
          KeypadFocusTarget(
            node: cancelNode,
            label: t.adminCancel,
            onActivate: () => Navigator.pop(dialogContext),
          ),
          if (currentClassId != null)
            KeypadFocusTarget(
              node: removeNode,
              label: t.adminRemoveStudentLabel(
                '${student['name']}',
                '$currentClassName',
              ),
              onActivate: () => Navigator.pop(dialogContext, 'remove'),
            ),
          KeypadFocusTarget(
            node: assignNode,
            label: t.adminAssignStudentLabel('${student['name']}'),
            onActivate: () => Navigator.pop(dialogContext, 'assign'),
          ),
        ],
        child: StatefulBuilder(
          builder: (context, setLocal) {
            updateDialog = setLocal;
            return AlertDialog(
              scrollable: true,
              insetPadding: const EdgeInsets.all(8),
              title: Text(Speech.t.adminAssignClassTo('${student['name']}')),
              content: KeypadChoiceField<int>(
                label: t.adminClassField,
                focusNode: classNode,
                values: [
                  for (final entry in activeClasses) entry['class_id'] as int,
                ],
                value: classId,
                nameOf: (id) =>
                    '${activeClasses.firstWhere((e) => e['class_id'] == id)['name']}',
                onChanged: (value) => setLocal(() => classId = value),
              ),
              actions: [
                TextButton(
                  focusNode: cancelNode,
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(Speech.t.libraryCancelKey0Button),
                ),
                if (currentClassId != null)
                  TextButton(
                    focusNode: removeNode,
                    onPressed: () => Navigator.pop(dialogContext, 'remove'),
                    child: Semantics(
                      label: Speech.t.adminRemoveStudentFromClass(
                        '${student['name']}',
                        '$currentClassName',
                      ),
                      excludeSemantics: true,
                      child: Text(Speech.t.adminRemoveClassKey2),
                    ),
                  ),
                FilledButton(
                  focusNode: assignNode,
                  onPressed: () => Navigator.pop(dialogContext, 'assign'),
                  child: Text(Speech.t.adminAssignKey1),
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
      if (!mounted) return;
      final confirmed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => KeypadConfirmationDialog(
          title: t.adminRemoveFromClassTitle,
          message: t.adminRemoveFromClassMessage(
            '${student['name']}',
            '$currentClassName',
          ),
          cancelLabel: t.adminKeepInClass,
          confirmLabel: t.adminRemoveFromClass,
          cancelKey: 0,
          confirmKey: 1,
        ),
      );
      if (confirmed != true) return;
      final removed = await ApiService.removeStudentClass(
        student['user_id'] as int,
      );
      await _announceResult(
        removed,
        t.adminStudentRemovedFromClass('${student['name']}'),
      );
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
      t.adminStudentAssignedTo('${student['name']}', '$className'),
    );
  }

  Future<void> _assignTeacher(Map<String, dynamic> teacher) async {
    final activeClasses = _classes
        .where((entry) => entry['is_active'] == true)
        .toList();
    if (activeClasses.isEmpty) {
      await TtsService.speak(Speech.t.adminNoActiveClasses);
      return;
    }
    final assignments = await ApiService.getTeacherAssignments(
      teacher['user_id'] as int,
    );
    if (!mounted) return;
    int classId = activeClasses.first['class_id'] as int;
    var classSubjects = await ApiService.getClassSubjects(classId);
    if (!mounted) return;
    if (classSubjects.isEmpty) {
      await TtsService.speak(AdminText.noActiveSubjects);
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
        MessageCenter.error(AdminText.noSubjects);
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
        AdminText.classAndSubject(
          '${selectedClass['name']}',
          '${subjects.first['subject_name']}',
        ),
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
        AdminText.choiceChanged(
          '${classSubjects[next]['subject_name']}',
          next,
          classSubjects.length,
        ),
      );
    }

    final t = Speech.t;
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => KeypadInstructionWrapper(
        screenName: t.adminAssignTeacherScreen('${teacher['name']}'),
        labels: {0: t.adminCancel, 1: t.adminAssign},
        actions: {
          0: () => Navigator.pop(dialogContext, false),
          1: () => Navigator.pop(dialogContext, true),
        },
        focusTargets: [
          for (final entry in assignments)
            KeypadFocusTarget(
              node: assignmentNodes[entry['assignment_id']]!,
              label: t.adminRemoveAssignmentLabel(
                '${teacher['name']}',
                '${entry['class_name']}',
                '${entry['subject_name']}',
              ),
              onActivate: () => _removeTeacherAssignment(
                teacher,
                Map<String, dynamic>.from(entry as Map),
                dialogContext,
              ),
            ),
          KeypadFocusTarget(
            node: classNode,
            label: AdminText.choiceLabel(
              t.adminClassField,
              '${activeClasses.firstWhere((e) => e['class_id'] == classId, orElse: () => activeClasses.first)['name']}',
              activeClasses
                  .indexWhere((e) => e['class_id'] == classId)
                  .clamp(0, activeClasses.length),
              activeClasses.length,
            ),
            onActivate: () => moveTeacherClass(1),
            onDecrease: () => moveTeacherClass(-1),
            onIncrease: () => moveTeacherClass(1),
          ),
          KeypadFocusTarget(
            node: subjectNode,
            label: classSubjects.isEmpty
                ? AdminText.noSubjects
                : AdminText.choiceLabel(
                    t.adminSubjectField,
                    '${classSubjects.firstWhere((e) => e['subject_id'] == subjectId, orElse: () => classSubjects.first)['subject_name']}',
                    classSubjects
                        .indexWhere((e) => e['subject_id'] == subjectId)
                        .clamp(0, classSubjects.length),
                    classSubjects.length,
                  ),
            onActivate: () => moveSubject(1),
            onDecrease: () => moveSubject(-1),
            onIncrease: () => moveSubject(1),
          ),
          KeypadFocusTarget(
            node: cancelNode,
            label: t.adminCancel,
            onActivate: () => Navigator.pop(dialogContext, false),
          ),
          KeypadFocusTarget(
            node: assignNode,
            label: t.adminSaveAssignment,
            onActivate: () => Navigator.pop(dialogContext, true),
          ),
        ],
        child: StatefulBuilder(
          builder: (context, setLocal) {
            updateDialog = setLocal;
            return AlertDialog(
              scrollable: true,
              insetPadding: const EdgeInsets.all(8),
              title: Text(Speech.t.adminAssignTeacher('${teacher['name']}')),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (assignments.isNotEmpty) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(Speech.t.adminCurrentAssignments),
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
                                tooltip: Speech.t.adminRemoveTeacherAssignment(
                                  '${teacher['name']}',
                                  '${entry['class_name']}',
                                  '${entry['subject_name']}',
                                ),
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
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(Speech.t.adminAddAssignment),
                    ),
                  ],
                  KeypadChoiceField<int>(
                    label: t.adminClassField,
                    focusNode: classNode,
                    values: [
                      for (final entry in activeClasses)
                        entry['class_id'] as int,
                    ],
                    value: classId,
                    nameOf: (id) =>
                        '${activeClasses.firstWhere((e) => e['class_id'] == id)['name']}',
                    onChanged: (value) => unawaited(selectClass(value)),
                  ),
                  const SizedBox(height: 12),
                  KeypadChoiceField<int>(
                    label: t.adminSubjectField,
                    focusNode: subjectNode,
                    values: [
                      for (final entry in classSubjects)
                        entry['subject_id'] as int,
                    ],
                    value: subjectId,
                    nameOf: (id) =>
                        '${classSubjects.firstWhere((e) => e['subject_id'] == id)['subject_name']}',
                    onChanged: (value) => setLocal(() => subjectId = value),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  focusNode: cancelNode,
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: Text(Speech.t.libraryCancelKey0Button),
                ),
                FilledButton(
                  focusNode: assignNode,
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: Text(Speech.t.adminAssignKey1),
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
    await _announceResult(result != null, Speech.t.adminTeacherAssignmentSaved);
  }

  Future<void> _removeTeacherAssignment(
    Map<String, dynamic> teacher,
    Map<String, dynamic> assignment,
    BuildContext dialogContext,
  ) async {
    final remove = await showDialog<bool>(
      context: dialogContext,
      builder: (_) => KeypadConfirmationDialog(
        title: Speech.t.adminRemoveAssignmentTitle,
        message: Speech.t.adminRemoveAssignmentMessage(
          '${teacher['name']}',
          '${assignment['class_name']}',
          '${assignment['subject_name']}',
        ),
        cancelLabel: Speech.t.adminKeep,
        confirmLabel: Speech.t.adminRemove,
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
    await _announceResult(removed, Speech.t.adminTeacherAssignmentRemoved);
  }

  List<KeypadFocusTarget> _focusTargets() {
    final t = Speech.t;
    final targets = <KeypadFocusTarget>[
      KeypadFocusTarget(
        node: _refreshNode,
        label: t.adminRefreshData,
        onActivate: _refresh,
      ),
      KeypadFocusTarget(
        node: _logoutNode,
        label: t.adminLogout,
        onActivate: () => AuthSessionService.logoutFrom(context),
      ),
      KeypadFocusTarget(
        node: _sectionNode,
        label: t.adminSectionButton(_sectionName(_section)),
        onActivate: _chooseSection,
      ),
      if (_section == _AdminSection.accounts) ...[
        KeypadFocusTarget(
          node: _searchNode,
          label: t.adminSearchAccounts,
          isTextField: true,
        ),
        KeypadFocusTarget(
          node: _roleFilterNode,
          label: t.adminRoleFilterLabel(_roleFilterLabel()),
          onActivate: () => _cycleRoleFilter(1),
          onDecrease: () => _cycleRoleFilter(-1),
          onIncrease: () => _cycleRoleFilter(1),
        ),
        KeypadFocusTarget(
          node: _assignmentFilterNode,
          label: t.adminAssignmentFilterLabel(_assignmentFilterLabel()),
          onActivate: () => _cycleAssignmentFilter(1),
          onDecrease: () => _cycleAssignmentFilter(-1),
          onIncrease: () => _cycleAssignmentFilter(1),
        ),
      ],
      if (_section == _AdminSection.subjects)
        KeypadFocusTarget(
          node: _subjectNode,
          label: t.adminCreateSubjectTitle,
          onActivate: _addSubject,
        ),
      if (_section == _AdminSection.classes)
        KeypadFocusTarget(
          node: _classNode,
          label: t.adminCreateClassTitle,
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
          label: schoolClass['is_active'] == true
              ? t.adminClassActiveLabel('${schoolClass['name']}')
              : t.adminClassArchivedLabel('${schoolClass['name']}'),
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
          label: subject['is_active'] == true
              ? t.adminSubjectActiveLabel('${subject['name']}')
              : t.adminSubjectArchivedLabel('${subject['name']}'),
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
      targets.add(
        KeypadFocusTarget(
          node: node,
          label: _accountLabel(user),
          onActivate: () => _manageUser(user),
        ),
      );
    }
    return targets;
  }

  /// One keypad stop for a filter. The chips stay individually tappable and
  /// expose their selected state; on tiny screens they stack vertically.
  Widget _filterGroup({
    required FocusNode node,
    required String label,
    required String heading,
    required List<(String, bool, VoidCallback)> chips,
  }) {
    final children = [
      for (final chip in chips)
        ChoiceChip(
          label: Text(
            chip.$1,
            style: const TextStyle(fontSize: UIUtils.minimumFontSize),
          ),
          selected: chip.$2,
          onSelected: (_) => chip.$3(),
        ),
    ];
    return Focus(
      focusNode: node,
      child: Semantics(
        container: true,
        label: label,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExcludeSemantics(
              child: Text(
                heading,
                style: TextStyle(
                  color: UIUtils.textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 4),
            if (UIUtils.isTiny(context))
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final chip in children)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: chip,
                    ),
                ],
              )
            else
              Wrap(spacing: 8, runSpacing: 8, children: children),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return KeypadInstructionWrapper(
      screenName: _sectionTitle,
      navigationSections: _sectionNavigation,
      stateSummary: () => AdminText.state(
        section: _sectionName(_section),
        shown: switch (_section) {
          _AdminSection.accounts => _users.length,
          _AdminSection.classes => _classes.length,
          _AdminSection.subjects => _subjects.length,
        },
        filter: _section == _AdminSection.accounts
            ? _assignmentFilterLabel()
            : null,
        search: _searchController.text.trim(),
      ),
      labels: _sectionKeyLabels,
      autoPlay: false,
      actions: {
        0: () => AuthSessionService.logoutFrom(context),
        1: _refresh,
        // Only the keys the current section announces do anything.
        if (_section == _AdminSection.accounts) ...{
          2: _focusSearch,
          3: () => _cycleRoleFilter(1),
          4: () => _cycleAssignmentFilter(1),
        },
        if (_section == _AdminSection.subjects) 5: _addSubject,
        if (_section == _AdminSection.classes) 6: _addClass,
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
            title: Text(Speech.t.adminAppBarTitle),
            actions: [
              IconButton(
                focusNode: _refreshNode,
                onPressed: _refresh,
                icon: const Icon(Icons.refresh),
                tooltip: Speech.t.adminRefreshKey1,
              ),
              IconButton(
                focusNode: _logoutNode,
                onPressed: () => AuthSessionService.logoutFrom(context),
                icon: const Icon(Icons.logout),
                tooltip: Speech.t.dashboardLogOutKey0,
              ),
            ],
          ),
          // A Column (not a lazy ListView) keeps every list item mounted, so
          // the D-pad can reach all accounts, classes and subjects.
          body: SafeArea(
            child: SingleChildScrollView(
              padding: UIUtils.paddingAll(context, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_loading)
                    Semantics(
                      label: Speech.t.adminLoading,
                      child: const LinearProgressIndicator(),
                    ),
                  if (_issue != null)
                    Semantics(
                      liveRegion: true,
                      child: Text(
                        _issue!,
                        style: TextStyle(
                          color: UIUtils.errorColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                  else if (!_loading && _summary.isNotEmpty)
                    Semantics(
                      liveRegion: true,
                      child: Text(
                        _summary,
                        style: TextStyle(
                          color: UIUtils.textColor,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    focusNode: _sectionNode,
                    onPressed: _chooseSection,
                    child: Text(
                      Speech.t.adminChangeSectionKey7(_sectionName(_section)),
                    ),
                  ),
                  if (_section == _AdminSection.accounts) ...[
                    const SizedBox(height: 8),
                    TextField(
                      controller: _searchController,
                      focusNode: _searchNode,
                      onTap: () => _keypad.enterTextEditing(_searchNode),
                      onSubmitted: (_) => _refresh(),
                      decoration: InputDecoration(
                        labelText: Speech.t.adminSearchKey2,
                        helperText: Speech.t.adminSearchHelper,
                        helperMaxLines: 10,
                        prefixIcon: ExcludeSemantics(child: Icon(Icons.search)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _filterGroup(
                      node: _roleFilterNode,
                      label: Speech.t.adminRoleFilterChipsLabel(
                        _roleFilterLabel(),
                      ),
                      heading: Speech.t.adminAccountTypeKey3,
                      chips: [
                        (
                          Speech.t.adminChipAllAccounts,
                          _roleFilter == null,
                          () => _setRoleFilter(null),
                        ),
                        (
                          Speech.t.adminChipStudents,
                          _roleFilter == 'student',
                          () => _setRoleFilter('student'),
                        ),
                        (
                          Speech.t.adminChipTeachers,
                          _roleFilter == 'teacher',
                          () => _setRoleFilter('teacher'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _filterGroup(
                      node: _assignmentFilterNode,
                      label: Speech.t.adminAssignmentFilterChipsLabel(
                        _assignmentFilterLabel(),
                      ),
                      heading: Speech.t.adminAssignmentKey4,
                      chips: [
                        (
                          Speech.t.adminChipAll,
                          _assignmentStatus == 'all',
                          () => _setAssignmentFilter('all'),
                        ),
                        (
                          _roleFilter == 'student'
                              ? Speech.t.adminAssignmentEnrolled
                              : _roleFilter == 'teacher'
                              ? Speech.t.adminAssignmentAssigned
                              : Speech.t.adminAssignmentEnrolledOrAssigned,
                          _assignmentStatus == 'assigned',
                          () => _setAssignmentFilter('assigned'),
                        ),
                        (
                          Speech.t.adminAssignmentUnassigned,
                          _assignmentStatus == 'unassigned',
                          () => _setAssignmentFilter('unassigned'),
                        ),
                      ],
                    ),
                  ],
                  if (_section == _AdminSection.subjects) ...[
                    const SizedBox(height: 8),
                    FilledButton.icon(
                      focusNode: _subjectNode,
                      onPressed: _addSubject,
                      icon: const Icon(Icons.menu_book),
                      label: Text(Speech.t.adminCreateSubjectKey5),
                    ),
                  ],
                  if (_section == _AdminSection.classes) ...[
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      focusNode: _classNode,
                      onPressed: _addClass,
                      icon: const Icon(Icons.class_outlined),
                      label: Text(Speech.t.adminCreateClassKey6),
                    ),
                  ],
                  if (_section == _AdminSection.classes) ...[
                    const SizedBox(height: 16),
                    Semantics(
                      header: true,
                      child: Text(
                        'Classes',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    for (final entry in _classes)
                      Builder(
                        builder: (_) {
                          final schoolClass = Map<String, dynamic>.from(
                            entry as Map,
                          );
                          final id = schoolClass['class_id'] as int;
                          final active = schoolClass['is_active'] == true;
                          return AccessibleTile(
                            focusNode: _classNodes.putIfAbsent(
                              id,
                              () => FocusNode(debugLabel: 'admin-class-$id'),
                            ),
                            title: '${schoolClass['name']}',
                            status: active
                                ? Speech.t.adminStatusActive
                                : Speech.t.playlistStatusArchived,
                            statusColor: active
                                ? UIUtils.successColor
                                : UIUtils.subtextColor,
                            subtitle: active
                                ? Speech.t.adminClassTileHint
                                : Speech.t.adminPressOkRestore,
                            semanticLabel: active
                                ? Speech.t.adminClassActiveLabel(
                                    '${schoolClass['name']}',
                                  )
                                : Speech.t.adminClassArchivedLabel(
                                    '${schoolClass['name']}',
                                  ),
                            onActivate: () => _manageClass(schoolClass),
                          );
                        },
                      ),
                  ],
                  if (_section == _AdminSection.subjects) ...[
                    const SizedBox(height: 16),
                    Semantics(
                      header: true,
                      child: Text(
                        'Subjects',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    for (final entry in _subjects)
                      Builder(
                        builder: (_) {
                          final subject = Map<String, dynamic>.from(
                            entry as Map,
                          );
                          final id = subject['subject_id'] as int;
                          final active = subject['is_active'] == true;
                          return AccessibleTile(
                            focusNode: _subjectNodes.putIfAbsent(
                              id,
                              () => FocusNode(debugLabel: 'admin-subject-$id'),
                            ),
                            title: '${subject['name']}',
                            status: active
                                ? Speech.t.adminStatusActive
                                : Speech.t.playlistStatusArchived,
                            statusColor: active
                                ? UIUtils.successColor
                                : UIUtils.subtextColor,
                            subtitle: active
                                ? Speech.t.adminPressOkArchive
                                : Speech.t.adminPressOkRestore,
                            semanticLabel: active
                                ? Speech.t.adminSubjectActiveLabel(
                                    '${subject['name']}',
                                  )
                                : Speech.t.adminSubjectArchivedLabel(
                                    '${subject['name']}',
                                  ),
                            onActivate: () => _toggleSubject(subject),
                          );
                        },
                      ),
                  ],
                  if (_section == _AdminSection.accounts) ...[
                    const SizedBox(height: 16),
                    Semantics(
                      header: true,
                      child: Text(
                        'Accounts',
                        style: Theme.of(context).textTheme.titleLarge,
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
      ),
    );
  }
}
