import 'package:flutter/material.dart';

import '../../l10n/speech.dart';
import '../../services/admin_setup_api.dart';
import '../../services/api_service.dart';
import 'admin_common.dart';
import 'person_dialogs.dart';

/// Accounts: search and filter people, add a person, edit, activate or
/// deactivate, sign out everywhere, and manage class or subject access.
class AccountsSection extends StatefulWidget {
  const AccountsSection({super.key});

  @override
  State<AccountsSection> createState() => _AccountsSectionState();
}

class _AccountsSectionState extends State<AccountsSection> {
  final _search = TextEditingController();
  List<JsonMap> _users = const [];
  List<JsonMap> _classes = const [];
  bool _loading = true;
  String? _error;
  String? _role;
  String _assignment = 'all';
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<JsonMap> get _activeClasses =>
      _classes.where((entry) => entry['is_active'] != false).toList();

  Future<void> _load() async {
    final generation = ++_generation;
    setState(() {
      _loading = true;
      _error = null;
    });
    final results = await Future.wait([
      AdminSetupApi.users(
        search: _search.text,
        role: _role,
        assignmentStatus: _assignment,
      ),
      AdminSetupApi.classes(),
    ]);
    if (!mounted || generation != _generation) return;
    final failed = results.where((result) => !result.isSuccess).firstOrNull;
    setState(() {
      _loading = false;
      if (failed != null) {
        _error = Speech.t.adminSetupLoadFailed(
          AdminSetupApi.errorText(failed.failure),
        );
        return;
      }
      _users = results[0].data!;
      _classes = results[1].data!;
    });
  }

  Future<void> _addPerson() async {
    final created = await showDialog<JsonMap>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AddPersonDialog(classes: _activeClasses),
    );
    if (!mounted || created == null) return;
    adminNotify(Speech.t.adminSetupPersonAdded('${created['name']}'));
    await _load();
  }

  Future<void> _edit(JsonMap user) async {
    final updated = await showDialog<JsonMap>(
      context: context,
      barrierDismissible: false,
      builder: (_) => EditPersonDialog(person: user),
    );
    if (!mounted || updated == null) return;
    adminNotify(Speech.t.adminSetupPersonSaved('${updated['name']}'));
    await _load();
  }

  Future<void> _setActive(JsonMap user, bool active) async {
    final t = Speech.t;
    final name = '${user['name']}';
    if (!active &&
        !await adminConfirm(
          context,
          title: t.adminSetupDeactivateTitle(name),
          message: t.adminSetupDeactivateMessage(name),
          confirmLabel: t.adminSetupDeactivate,
        )) {
      return;
    }
    final result = await AdminSetupApi.updatePerson(
      user['user_id'] as int,
      isActive: active,
    );
    if (!mounted) return;
    if (adminReport(
      result,
      active ? t.adminSetupActivated(name) : t.adminSetupDeactivated(name),
    )) {
      await _load();
    }
  }

  Future<void> _signOutEverywhere(JsonMap user) async {
    final t = Speech.t;
    final name = '${user['name']}';
    if (!await adminConfirm(
      context,
      title: t.adminSetupSignOutTitle(name),
      message: t.adminSetupSignOutMessage(name),
      confirmLabel: t.adminSetupSignOutEverywhere,
    )) {
      return;
    }
    final id = user['user_id'] as int;
    var result = await AdminSetupApi.signOutEverywhere(
      id,
      (user['auth_version'] as int?) ?? 0,
    );
    if (result.failure?.statusCode == 409) {
      // The account changed since the list loaded: read the current version
      // and try once more.
      final fresh = await AdminSetupApi.users(
        search: '${user['phone_number'] ?? user['name']}',
        role: user['role'] as String?,
      );
      final current = fresh.data
          ?.where((entry) => entry['user_id'] == id)
          .firstOrNull;
      if (current?['auth_version'] is int) {
        result = await AdminSetupApi.signOutEverywhere(
          id,
          current!['auth_version'] as int,
        );
      }
    }
    if (!mounted) return;
    adminReport(result, t.adminSetupSignedOut(name));
    await _load();
  }

  Future<void> _changeClass(JsonMap user) async {
    final changed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          StudentClassDialog(student: user, classes: _activeClasses),
    );
    if (mounted && changed == true) await _load();
  }

  Future<void> _manageAssignments(JsonMap user) async {
    final changed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          TeacherAssignmentsDialog(teacher: user, classes: _activeClasses),
    );
    if (mounted && changed == true) await _load();
  }

  void _setRole(String? role) {
    setState(() {
      _role = role;
      _assignment = 'all';
    });
    _load();
  }

  void _setAssignment(String value) {
    setState(() => _assignment = value);
    _load();
  }

  Widget _userCard(JsonMap user) {
    final t = Speech.t;
    final name = '${user['name']}';
    final isStudent = user['role'] == 'student';
    final active = user['is_active'] != false;
    final assignments = (user['assignments'] as List? ?? const [])
        .whereType<Map>()
        .map(
          (entry) => t.adminSetupPairLabel(
            '${entry['class_name']}',
            '${entry['subject_name']}',
          ),
        )
        .toList();
    return AdminItemCard(
      title: name,
      status: active ? t.adminStatusActive : t.adminSetupInactive,
      lines: [
        if (isStudent)
          user['class_name'] == null
              ? t.adminSetupStudentNoClass
              : t.adminSetupStudentDetail('${user['class_name']}')
        else if (assignments.isEmpty)
          t.adminSetupTeacherNoPairs
        else
          t.adminSetupTeacherDetail(assignments.join('; ')),
        t.adminSetupPhoneDetail('${user['phone_number'] ?? ''}'),
      ],
      actions: [
        AdminActionButton(
          label: t.adminSetupEdit,
          semanticLabel: t.adminSetupEditPerson(name),
          icon: Icons.edit,
          onPressed: () => _edit(user),
        ),
        AdminActionButton(
          label: isStudent
              ? t.adminSetupStudentClassAction
              : t.adminSetupTeacherAssignmentsAction,
          semanticLabel: isStudent
              ? t.adminSetupClassDialogTitle(name)
              : t.adminSetupAssignmentsTitle(name),
          icon: isStudent ? Icons.class_outlined : Icons.menu_book,
          onPressed: () =>
              isStudent ? _changeClass(user) : _manageAssignments(user),
        ),
        if (active)
          AdminActionButton(
            label: t.adminSetupDeactivate,
            semanticLabel: t.adminSetupDeactivateNamed(name),
            icon: Icons.block,
            onPressed: () => _setActive(user, false),
          )
        else
          AdminActionButton(
            label: t.adminSetupActivate,
            semanticLabel: t.adminSetupActivateNamed(name),
            icon: Icons.check_circle_outline,
            onPressed: () => _setActive(user, true),
          ),
        AdminActionButton(
          label: t.adminSetupSignOutEverywhere,
          semanticLabel: t.adminSetupSignOutNamed(name),
          icon: Icons.logout,
          onPressed: () => _signOutEverywhere(user),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Speech.t;
    final teachers = _users.where((user) => user['role'] == 'teacher');
    final students = _users.where((user) => user['role'] == 'student');
    return AdminSectionBody(
      loading: _loading,
      error: _error,
      onRetry: _load,
      emptyText: t.adminSetupAccountsShown(0),
      header: [
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.icon(
            onPressed: _loading ? null : _addPerson,
            icon: const Icon(Icons.person_add),
            label: Text(t.adminSetupAddPerson),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _search,
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => _load(),
          decoration: InputDecoration(
            labelText: t.adminSetupSearchLabel,
            suffixIcon: IconButton(
              tooltip: t.adminSetupSearchButton,
              icon: const Icon(Icons.search),
              onPressed: _load,
            ),
          ),
        ),
        const SizedBox(height: 12),
        AdminChoiceChips<String?>(
          heading: t.adminSetupAccountTypeHeading,
          options: [
            (null, t.adminChipAllAccounts),
            ('student', t.adminChipStudents),
            ('teacher', t.adminChipTeachers),
          ],
          selected: _role,
          onSelected: _setRole,
        ),
        const SizedBox(height: 12),
        AdminChoiceChips<String>(
          heading: t.adminSetupAssignmentHeading,
          options: [
            ('all', t.adminChipAll),
            (
              'assigned',
              _role == 'student'
                  ? t.adminAssignmentEnrolled
                  : _role == 'teacher'
                  ? t.adminAssignmentAssigned
                  : t.adminAssignmentEnrolledOrAssigned,
            ),
            ('unassigned', t.adminAssignmentUnassigned),
          ],
          selected: _assignment,
          onSelected: _setAssignment,
        ),
        if (!_loading && _error == null && _users.isNotEmpty) ...[
          const SizedBox(height: 12),
          Semantics(
            liveRegion: true,
            child: Text(t.adminSetupAccountsShown(_users.length)),
          ),
        ],
      ],
      items: [
        if (teachers.isNotEmpty) ...[
          AdminHeading(t.adminSetupTeachersHeading(teachers.length)),
          ...teachers.map(_userCard),
        ],
        if (students.isNotEmpty) ...[
          AdminHeading(t.adminSetupStudentsHeading(students.length)),
          ...students.map(_userCard),
        ],
      ],
    );
  }
}

/// Puts a student in a class, or removes them from their class.
class StudentClassDialog extends StatefulWidget {
  const StudentClassDialog({
    super.key,
    required this.student,
    required this.classes,
  });

  final JsonMap student;
  final List<JsonMap> classes;

  @override
  State<StudentClassDialog> createState() => _StudentClassDialogState();
}

class _StudentClassDialogState extends State<StudentClassDialog> {
  late int? _classId =
      widget.classes.any(
        (entry) => entry['class_id'] == widget.student['class_id'],
      )
      ? widget.student['class_id'] as int
      : widget.classes.firstOrNull?['class_id'] as int?;
  bool _busy = false;
  String? _error;

  String get _name => '${widget.student['name']}';

  Future<void> _save() async {
    final classId = _classId;
    if (classId == null) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final result = await ApiService.enrollStudent(
      widget.student['user_id'] as int,
      classId,
    );
    if (!mounted) return;
    if (result == null) {
      setState(() {
        _busy = false;
        _error = Speech.t.adminSetupNotSaved;
      });
      return;
    }
    final className = widget.classes.firstWhere(
      (entry) => entry['class_id'] == classId,
    )['name'];
    adminNotify(Speech.t.adminSetupStudentEnrolled(_name, '$className'));
    Navigator.pop(context, true);
  }

  Future<void> _remove() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final removed = await ApiService.removeStudentClass(
      widget.student['user_id'] as int,
    );
    if (!mounted) return;
    if (!removed) {
      setState(() {
        _busy = false;
        _error = Speech.t.adminSetupNotSaved;
      });
      return;
    }
    adminNotify(Speech.t.adminSetupStudentRemoved(_name));
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final t = Speech.t;
    return AdminFormDialog(
      title: t.adminSetupClassDialogTitle(_name),
      busy: _busy,
      error: _error,
      onSave: _save,
      children: [
        if (widget.classes.isEmpty)
          Text(t.adminSetupNoActiveClasses)
        else
          AdminDropdown<int>(
            label: t.adminSetupClassField,
            value: _classId,
            options: [
              for (final entry in widget.classes)
                (entry['class_id'] as int, '${entry['name']}'),
            ],
            onChanged: _busy
                ? null
                : (value) => setState(() => _classId = value),
          ),
        if (widget.student['class_id'] != null) ...[
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: _busy ? null : _remove,
              icon: const Icon(Icons.remove_circle_outline),
              label: Text(
                t.adminSetupRemoveFromClass(
                  '${widget.student['class_name'] ?? ''}',
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Lists a teacher's class and subject pairs; adds and removes pairs.
/// Pops with true when anything changed.
class TeacherAssignmentsDialog extends StatefulWidget {
  const TeacherAssignmentsDialog({
    super.key,
    required this.teacher,
    required this.classes,
  });

  final JsonMap teacher;
  final List<JsonMap> classes;

  @override
  State<TeacherAssignmentsDialog> createState() =>
      _TeacherAssignmentsDialogState();
}

class _TeacherAssignmentsDialogState extends State<TeacherAssignmentsDialog> {
  List<dynamic> _assignments = const [];
  bool _loading = true;
  bool _busy = false;
  bool _changed = false;
  String? _error;

  int get _teacherId => widget.teacher['user_id'] as int;
  String get _name => '${widget.teacher['name']}';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final assignments = await ApiService.getTeacherAssignments(_teacherId);
    if (!mounted) return;
    setState(() {
      _assignments = assignments
          .where((entry) => entry is Map && entry['is_active'] != false)
          .toList();
      _loading = false;
    });
  }

  Future<void> _add(ClassSubjectPair pair) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final result = await ApiService.assignTeacher(
      _teacherId,
      pair.classId,
      pair.subjectId,
    );
    if (!mounted) return;
    if (result == null) {
      setState(() {
        _busy = false;
        _error = Speech.t.adminSetupNotSaved;
      });
      return;
    }
    adminNotify(
      Speech.t.adminSetupPairAdded(_name, pair.className, pair.subjectName),
    );
    _changed = true;
    await _load();
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _remove(Map assignment) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final removed = await ApiService.archiveTeacherAssignment(
      _teacherId,
      assignment['assignment_id'] as int,
    );
    if (!mounted) return;
    if (!removed) {
      setState(() {
        _busy = false;
        _error = Speech.t.adminSetupNotSaved;
      });
      return;
    }
    adminNotify(
      Speech.t.adminSetupPairRemoved(
        _name,
        '${assignment['class_name']}',
        '${assignment['subject_name']}',
      ),
    );
    _changed = true;
    await _load();
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final t = Speech.t;
    return AlertDialog(
      scrollable: true,
      insetPadding: const EdgeInsets.all(12),
      title: Text(t.adminSetupAssignmentsTitle(_name)),
      content: SizedBox(
        width: 520,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              t.adminSetupCurrentPairs,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            if (_loading)
              Semantics(
                label: t.adminSetupLoading,
                child: const LinearProgressIndicator(),
              )
            else if (_assignments.isEmpty)
              Text(t.adminSetupNoPairs)
            else
              for (final entry in _assignments.cast<Map>())
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    t.adminSetupPairLabel(
                      '${entry['class_name']}',
                      '${entry['subject_name']}',
                    ),
                  ),
                  trailing: IconButton(
                    tooltip: t.adminRemoveTeacherAssignment(
                      _name,
                      '${entry['class_name']}',
                      '${entry['subject_name']}',
                    ),
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: _busy ? null : () => _remove(entry),
                  ),
                ),
            const Divider(height: 24),
            ClassSubjectPicker(
              classes: widget.classes,
              enabled: !_busy,
              onAdd: _add,
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              AdminErrorText(_error!),
            ],
          ],
        ),
      ),
      actions: [
        FilledButton(
          onPressed: _busy ? null : () => Navigator.pop(context, _changed),
          child: Text(t.adminSetupClose),
        ),
      ],
    );
  }
}
