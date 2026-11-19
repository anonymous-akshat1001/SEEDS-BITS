import 'package:flutter/material.dart';

import '../../l10n/speech.dart';
import '../../services/admin_setup_api.dart';
import '../../services/api_service.dart';
import 'admin_common.dart';

/// Classes and subjects: create, archive or restore, and choose which
/// subjects each class has.
class CatalogSection extends StatefulWidget {
  const CatalogSection({super.key});

  @override
  State<CatalogSection> createState() => _CatalogSectionState();
}

class _CatalogSectionState extends State<CatalogSection> {
  List<JsonMap> _classes = const [];
  List<JsonMap> _subjects = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final results = await Future.wait([
      AdminSetupApi.classes(includeArchived: true),
      AdminSetupApi.subjects(includeArchived: true),
    ]);
    if (!mounted) return;
    final failed = results.where((result) => !result.isSuccess).firstOrNull;
    setState(() {
      _loading = false;
      if (failed != null) {
        _error = Speech.t.adminSetupLoadFailed(
          AdminSetupApi.errorText(failed.failure),
        );
        return;
      }
      _classes = results[0].data!;
      _subjects = results[1].data!;
    });
  }

  Future<String?> _askName(String title, String label) async {
    final controller = TextEditingController();
    String? error;
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setLocal) {
          void save() {
            final value = controller.text.trim();
            if (value.isEmpty) {
              setLocal(() => error = Speech.t.adminSetupRequiredField(label));
              return;
            }
            Navigator.pop(dialogContext, value);
          }

          return AdminFormDialog(
            title: title,
            error: error,
            onSave: save,
            children: [
              TextField(
                controller: controller,
                autofocus: true,
                onSubmitted: (_) => save(),
                decoration: InputDecoration(labelText: label),
              ),
            ],
          );
        },
      ),
    );
    controller.dispose();
    return name;
  }

  Future<void> _addClass() async {
    final t = Speech.t;
    final name = await _askName(t.adminCreateClassTitle, t.adminClassNameField);
    if (name == null) return;
    final orders = _classes
        .map((entry) => int.tryParse('${entry['sort_order']}') ?? 0)
        .toList();
    final next = orders.isEmpty
        ? 0
        : orders.reduce((a, b) => a > b ? a : b) + 1;
    final created = await ApiService.createClass(name, next);
    _finish(created != null, t.adminClassCreated(name));
  }

  Future<void> _addSubject() async {
    final t = Speech.t;
    final name = await _askName(
      t.adminCreateSubjectTitle,
      t.adminSubjectNameField,
    );
    if (name == null) return;
    final created = await ApiService.createSubject(name);
    _finish(created != null, t.adminSubjectCreated(name));
  }

  void _finish(bool success, String message) {
    if (!mounted) return;
    adminNotify(
      success ? message : Speech.t.adminSetupNotSaved,
      error: !success,
    );
    if (success) _load();
  }

  Future<void> _toggleClass(JsonMap schoolClass) async {
    final t = Speech.t;
    final active = schoolClass['is_active'] != false;
    final name = '${schoolClass['name']}';
    if (!await adminConfirm(
      context,
      title: active ? t.adminArchiveClassTitle : t.adminRestoreClassTitle,
      message: active
          ? t.adminArchiveItemMessage(name)
          : t.adminRestoreItemMessage(name),
      confirmLabel: active ? t.adminArchive : t.adminRestore,
    )) {
      return;
    }
    final result = await ApiService.setClassArchived(
      schoolClass['class_id'] as int,
      active,
    );
    _finish(
      result != null,
      active ? t.adminClassArchived : t.adminClassRestored,
    );
  }

  Future<void> _toggleSubject(JsonMap subject) async {
    final t = Speech.t;
    final active = subject['is_active'] != false;
    final name = '${subject['name']}';
    if (!await adminConfirm(
      context,
      title: active ? t.adminArchiveSubjectTitle : t.adminRestoreSubjectTitle,
      message: active
          ? t.adminArchiveItemMessage(name)
          : t.adminRestoreItemMessage(name),
      confirmLabel: active ? t.adminArchive : t.adminRestore,
    )) {
      return;
    }
    final result = await ApiService.setSubjectArchived(
      subject['subject_id'] as int,
      active,
    );
    _finish(
      result != null,
      active ? t.adminSubjectArchived : t.adminSubjectRestored,
    );
  }

  Future<void> _classSubjects(JsonMap schoolClass) async {
    await showDialog<void>(
      context: context,
      builder: (_) => ClassSubjectsDialog(
        schoolClass: schoolClass,
        subjects: _subjects
            .where((subject) => subject['is_active'] != false)
            .toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Speech.t;
    return AdminSectionBody(
      loading: _loading,
      error: _error,
      onRetry: _load,
      emptyText: '',
      header: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.icon(
              onPressed: _loading ? null : _addClass,
              icon: const Icon(Icons.class_outlined),
              label: Text(t.adminSetupAddClass),
            ),
            FilledButton.icon(
              onPressed: _loading ? null : _addSubject,
              icon: const Icon(Icons.menu_book),
              label: Text(t.adminSetupAddSubject),
            ),
          ],
        ),
      ],
      items: [
        AdminHeading(t.adminSetupClassesHeading),
        if (_classes.isEmpty) Text(t.adminSetupNoClasses),
        for (final schoolClass in _classes)
          Builder(
            builder: (_) {
              final active = schoolClass['is_active'] != false;
              final name = '${schoolClass['name']}';
              return AdminItemCard(
                title: name,
                status: active ? t.adminStatusActive : t.playlistStatusArchived,
                actions: [
                  if (active)
                    AdminActionButton(
                      label: t.adminSetupSubjectsButton,
                      semanticLabel: t.adminSetupClassSubjects(name),
                      icon: Icons.checklist,
                      onPressed: () => _classSubjects(schoolClass),
                    ),
                  AdminActionButton(
                    label: active ? t.adminArchive : t.adminRestore,
                    semanticLabel: active
                        ? t.adminSetupArchiveNamed(name)
                        : t.adminSetupRestoreNamed(name),
                    onPressed: () => _toggleClass(schoolClass),
                  ),
                ],
              );
            },
          ),
        AdminHeading(t.adminSetupSubjectsHeading),
        if (_subjects.isEmpty) Text(t.adminSetupNoSubjects),
        for (final subject in _subjects)
          Builder(
            builder: (_) {
              final active = subject['is_active'] != false;
              final name = '${subject['name']}';
              return AdminItemCard(
                title: name,
                status: active ? t.adminStatusActive : t.playlistStatusArchived,
                actions: [
                  AdminActionButton(
                    label: active ? t.adminArchive : t.adminRestore,
                    semanticLabel: active
                        ? t.adminSetupArchiveNamed(name)
                        : t.adminSetupRestoreNamed(name),
                    onPressed: () => _toggleSubject(subject),
                  ),
                ],
              );
            },
          ),
      ],
    );
  }
}

/// Checkbox per active subject: checked subjects are taught in the class.
class ClassSubjectsDialog extends StatefulWidget {
  const ClassSubjectsDialog({
    super.key,
    required this.schoolClass,
    required this.subjects,
  });

  final JsonMap schoolClass;
  final List<JsonMap> subjects;

  @override
  State<ClassSubjectsDialog> createState() => _ClassSubjectsDialogState();
}

class _ClassSubjectsDialogState extends State<ClassSubjectsDialog> {
  /// Active associations by subject id.
  Map<int, JsonMap> _associations = const {};
  bool _loading = true;
  bool _busy = false;
  String? _error;

  int get _classId => widget.schoolClass['class_id'] as int;
  String get _className => '${widget.schoolClass['name']}';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await AdminSetupApi.classSubjects(
      _classId,
      includeArchived: true,
    );
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (!result.isSuccess) {
        _error = AdminSetupApi.errorText(result.failure);
        return;
      }
      _associations = {
        for (final entry in result.data!)
          if (entry['is_active'] != false) entry['subject_id'] as int: entry,
      };
    });
  }

  Future<void> _toggle(JsonMap subject, bool include) async {
    final t = Speech.t;
    final subjectId = subject['subject_id'] as int;
    setState(() {
      _busy = true;
      _error = null;
    });
    final success = include
        ? await ApiService.associateClassSubject(_classId, subjectId) != null
        : await ApiService.archiveClassSubject(
            _classId,
            _associations[subjectId]!['association_id'] as int,
          );
    if (!mounted) return;
    if (success) {
      adminNotify(
        include
            ? t.adminSubjectAddedTo(_className)
            : t.adminSubjectRemovedFrom(_className),
      );
      await _load();
    } else {
      _error = t.adminSetupNotSaved;
    }
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final t = Speech.t;
    return AlertDialog(
      scrollable: true,
      insetPadding: const EdgeInsets.all(12),
      title: Text(t.adminSetupClassSubjects(_className)),
      content: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_loading)
              Semantics(
                label: t.adminSetupLoading,
                child: const LinearProgressIndicator(),
              )
            else if (widget.subjects.isEmpty)
              Text(t.adminSetupNoSubjectsToChoose)
            else
              for (final subject in widget.subjects)
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('${subject['name']}'),
                  value: _associations.containsKey(subject['subject_id']),
                  onChanged: _busy
                      ? null
                      : (value) => _toggle(subject, value ?? false),
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
          onPressed: () => Navigator.pop(context),
          child: Text(t.adminSetupClose),
        ),
      ],
    );
  }
}
