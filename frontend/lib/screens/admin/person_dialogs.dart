import 'package:flutter/material.dart';

import '../../l10n/speech.dart';
import '../../services/admin_setup_api.dart';
import 'admin_common.dart';

typedef ClassSubjectPair = ({
  int classId,
  String className,
  int subjectId,
  String subjectName,
});

/// Chooses a class, then one of that class's subjects, and reports the pair.
class ClassSubjectPicker extends StatefulWidget {
  const ClassSubjectPicker({
    super.key,
    required this.classes,
    required this.onAdd,
    this.enabled = true,
  });

  /// Active classes: maps with class_id and name.
  final List<JsonMap> classes;
  final ValueChanged<ClassSubjectPair> onAdd;
  final bool enabled;

  @override
  State<ClassSubjectPicker> createState() => _ClassSubjectPickerState();
}

class _ClassSubjectPickerState extends State<ClassSubjectPicker> {
  int? _classId;
  int? _subjectId;
  List<JsonMap> _subjects = const [];
  bool _loading = false;
  String? _error;
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    if (widget.classes.isNotEmpty) {
      _selectClass(widget.classes.first['class_id'] as int);
    }
  }

  Future<void> _selectClass(int classId) async {
    final generation = ++_generation;
    setState(() {
      _classId = classId;
      _subjectId = null;
      _subjects = const [];
      _loading = true;
      _error = null;
    });
    final result = await AdminSetupApi.classSubjects(classId);
    if (!mounted || generation != _generation) return;
    setState(() {
      _loading = false;
      if (!result.isSuccess) {
        _error = AdminSetupApi.errorText(result.failure);
        return;
      }
      _subjects = [
        for (final entry in result.data!)
          if (entry['is_active'] != false) entry,
      ];
      _subjectId = _subjects.isEmpty
          ? null
          : _subjects.first['subject_id'] as int;
      if (_subjects.isEmpty) _error = Speech.t.adminSetupNoSubjectsInClass;
    });
  }

  void _add() {
    final classId = _classId;
    final subjectId = _subjectId;
    if (classId == null || subjectId == null) return;
    final schoolClass = widget.classes.firstWhere(
      (entry) => entry['class_id'] == classId,
    );
    final subject = _subjects.firstWhere(
      (entry) => entry['subject_id'] == subjectId,
    );
    widget.onAdd((
      classId: classId,
      className: '${schoolClass['name']}',
      subjectId: subjectId,
      subjectName: '${subject['subject_name'] ?? subject['name']}',
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (widget.classes.isEmpty) {
      return Text(Speech.t.adminSetupNoActiveClasses);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AdminDropdown<int>(
          label: Speech.t.adminSetupClassField,
          value: _classId,
          options: [
            for (final entry in widget.classes)
              (entry['class_id'] as int, '${entry['name']}'),
          ],
          onChanged: widget.enabled
              ? (value) {
                  if (value != null) _selectClass(value);
                }
              : null,
        ),
        const SizedBox(height: 8),
        if (_loading)
          Semantics(
            label: Speech.t.adminSetupLoading,
            child: const LinearProgressIndicator(),
          )
        else if (_error != null)
          Text(_error!)
        else
          AdminDropdown<int>(
            label: Speech.t.adminSetupSubjectField,
            value: _subjectId,
            options: [
              for (final entry in _subjects)
                (
                  entry['subject_id'] as int,
                  '${entry['subject_name'] ?? entry['name']}',
                ),
            ],
            onChanged: widget.enabled
                ? (value) => setState(() => _subjectId = value)
                : null,
          ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: widget.enabled && _subjectId != null && !_loading
                ? _add
                : null,
            icon: const Icon(Icons.add),
            label: Text(Speech.t.adminSetupAddPair),
          ),
        ),
      ],
    );
  }
}

/// "Add person": name, phone number, role, and a class (students) or
/// class and subject pairs (teachers). Pops with the created account.
class AddPersonDialog extends StatefulWidget {
  const AddPersonDialog({super.key, required this.classes});

  /// Active classes.
  final List<JsonMap> classes;

  @override
  State<AddPersonDialog> createState() => _AddPersonDialogState();
}

class _AddPersonDialogState extends State<AddPersonDialog> {
  static const _noClass = -1;
  final _name = TextEditingController();
  final _phone = TextEditingController();
  String _role = 'student';
  int _classId = _noClass;
  final List<ClassSubjectPair> _pairs = [];
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final t = Speech.t;
    final name = _name.text.trim();
    final phone = _phone.text.trim();
    if (name.isEmpty || phone.isEmpty) {
      setState(
        () => _error = t.adminSetupRequiredField(
          name.isEmpty ? t.adminSetupNameField : t.adminSetupPhoneField,
        ),
      );
      return;
    }
    if (_role == 'student' && _classId == _noClass) {
      setState(
        () => _error = t.adminSetupRequiredField(t.adminSetupClassField),
      );
      return;
    }
    if (_role == 'teacher' && _pairs.isEmpty) {
      setState(() => _error = t.adminSetupTeacherNeedsPair);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final result = await AdminSetupApi.createPerson(
      name: name,
      phoneNumber: phone,
      role: _role,
      classId: _role == 'student' ? _classId : null,
      assignments: [
        for (final pair in _pairs)
          (classId: pair.classId, subjectId: pair.subjectId),
      ],
    );
    if (!mounted) return;
    if (!result.isSuccess) {
      setState(() {
        _busy = false;
        _error = AdminSetupApi.errorText(result.failure);
      });
      return;
    }
    Navigator.pop(context, result.data);
  }

  @override
  Widget build(BuildContext context) {
    final t = Speech.t;
    return AdminFormDialog(
      title: t.adminSetupAddPerson,
      busy: _busy,
      error: _error,
      onSave: _save,
      children: [
        TextField(
          controller: _name,
          autofocus: true,
          enabled: !_busy,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(labelText: t.adminSetupNameField),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _phone,
          enabled: !_busy,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(labelText: t.adminSetupPhoneField),
        ),
        const SizedBox(height: 12),
        AdminChoiceChips<String>(
          heading: t.adminSetupRoleField,
          options: [
            ('student', t.adminSetupRoleStudent),
            ('teacher', t.adminSetupRoleTeacher),
          ],
          selected: _role,
          onSelected: (role) {
            if (!_busy) setState(() => _role = role);
          },
        ),
        const SizedBox(height: 12),
        if (_role == 'student')
          AdminDropdown<int>(
            label: t.adminSetupClassField,
            value: _classId == _noClass ? null : _classId,
            options: [
              for (final entry in widget.classes)
                (entry['class_id'] as int, '${entry['name']}'),
            ],
            onChanged: _busy
                ? null
                : (value) => setState(() => _classId = value ?? _noClass),
          )
        else ...[
          Text(
            t.adminSetupTeacherPairsHeading,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          if (_pairs.isEmpty)
            Text(t.adminSetupNoPairs)
          else
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final pair in _pairs)
                  InputChip(
                    label: Text(
                      t.adminSetupPairLabel(pair.className, pair.subjectName),
                    ),
                    deleteButtonTooltipMessage: t.adminSetupRemovePair(
                      pair.className,
                      pair.subjectName,
                    ),
                    onDeleted: _busy
                        ? null
                        : () => setState(() => _pairs.remove(pair)),
                  ),
              ],
            ),
          const SizedBox(height: 8),
          ClassSubjectPicker(
            classes: widget.classes,
            enabled: !_busy,
            onAdd: (pair) {
              if (_pairs.any(
                (item) =>
                    item.classId == pair.classId &&
                    item.subjectId == pair.subjectId,
              )) {
                return;
              }
              setState(() => _pairs.add(pair));
            },
          ),
        ],
      ],
    );
  }
}

/// Edits a person's name and phone number; pops with the updated account.
class EditPersonDialog extends StatefulWidget {
  const EditPersonDialog({super.key, required this.person});

  final JsonMap person;

  @override
  State<EditPersonDialog> createState() => _EditPersonDialogState();
}

class _EditPersonDialogState extends State<EditPersonDialog> {
  late final _name = TextEditingController(text: '${widget.person['name']}');
  late final _phone = TextEditingController(
    text: '${widget.person['phone_number'] ?? ''}',
  );
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final t = Speech.t;
    final name = _name.text.trim();
    final phone = _phone.text.trim();
    if (name.isEmpty || phone.isEmpty) {
      setState(
        () => _error = t.adminSetupRequiredField(
          name.isEmpty ? t.adminSetupNameField : t.adminSetupPhoneField,
        ),
      );
      return;
    }
    final nameChanged = name != '${widget.person['name']}';
    final phoneChanged = phone != '${widget.person['phone_number']}';
    if (!nameChanged && !phoneChanged) {
      Navigator.pop(context);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final result = await AdminSetupApi.updatePerson(
      widget.person['user_id'] as int,
      name: nameChanged ? name : null,
      phoneNumber: phoneChanged ? phone : null,
    );
    if (!mounted) return;
    if (!result.isSuccess) {
      setState(() {
        _busy = false;
        _error = AdminSetupApi.errorText(result.failure);
      });
      return;
    }
    Navigator.pop(context, result.data);
  }

  @override
  Widget build(BuildContext context) {
    final t = Speech.t;
    return AdminFormDialog(
      title: t.adminSetupEditPerson('${widget.person['name']}'),
      busy: _busy,
      error: _error,
      onSave: _save,
      children: [
        TextField(
          controller: _name,
          autofocus: true,
          enabled: !_busy,
          decoration: InputDecoration(labelText: t.adminSetupNameField),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _phone,
          enabled: !_busy,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: t.adminSetupPhoneField,
            helperText: t.adminSetupPhoneChangeNote,
            helperMaxLines: 3,
          ),
        ),
      ],
    );
  }
}
