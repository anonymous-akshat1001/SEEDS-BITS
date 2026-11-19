import 'package:flutter/material.dart';

import '../../l10n/speech.dart';
import '../../services/admin_setup_api.dart';
import 'admin_common.dart';

/// Shared phones: one number used by several people, each choosing their
/// account with a short profile number.
class SharedPhonesSection extends StatefulWidget {
  const SharedPhonesSection({super.key});

  @override
  State<SharedPhonesSection> createState() => _SharedPhonesSectionState();
}

class _SharedPhonesSectionState extends State<SharedPhonesSection> {
  List<JsonMap> _groups = const [];
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
    final result = await AdminSetupApi.deviceGroups();
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (result.isSuccess) {
        _groups = result.data!;
      } else {
        _error = Speech.t.adminSetupLoadFailed(
          AdminSetupApi.errorText(result.failure),
        );
      }
    });
  }

  Future<void> _editGroup([JsonMap? group]) async {
    final saved = await showDialog<JsonMap>(
      context: context,
      barrierDismissible: false,
      builder: (_) => SharedPhoneDialog(group: group),
    );
    if (!mounted || saved == null) return;
    adminNotify(Speech.t.adminSetupSharedPhoneSaved);
    await _load();
  }

  Future<void> _addMember(JsonMap group) async {
    final added = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AddMemberDialog(group: group),
    );
    if (!mounted || added == null) return;
    adminNotify(Speech.t.adminSetupMemberAdded(added, '${group['name']}'));
    await _load();
  }

  Future<void> _removeMember(JsonMap group, Map member) async {
    final t = Speech.t;
    final name = '${member['name']}';
    final groupName = '${group['name']}';
    if (!await adminConfirm(
      context,
      title: t.adminSetupRemoveMemberTitle(name, groupName),
      message: t.adminSetupRemoveMemberMessage(name),
      confirmLabel: t.adminSetupRemove,
    )) {
      return;
    }
    final result = await AdminSetupApi.removeGroupMember(
      group['group_id'] as int,
      member['member_id'] as int,
    );
    if (!mounted) return;
    if (adminReport(result, t.adminSetupMemberRemoved(name, groupName))) {
      await _load();
    }
  }

  Widget _groupCard(JsonMap group) {
    final t = Speech.t;
    final name = '${group['name']}';
    final active = group['is_active'] != false;
    final members = (group['members'] as List? ?? const [])
        .whereType<Map>()
        .toList();
    return AdminItemCard(
      title: name,
      status: active ? t.adminStatusActive : t.adminSetupInactive,
      lines: [
        t.adminSetupGroupNumber('${group['entry_phone_number']}'),
        if (members.isEmpty) t.adminSetupNoMembers,
      ],
      actions: [
        for (final member in members)
          InputChip(
            label: Text(
              t.adminSetupMemberLine(
                '${member['name']}',
                adminRoleName(member['role']),
                '${member['profile_code']}',
              ),
            ),
            deleteButtonTooltipMessage: t.adminSetupRemoveMemberNamed(
              '${member['name']}',
              name,
            ),
            onDeleted: () => _removeMember(group, member),
          ),
        AdminActionButton(
          label: t.adminSetupAddMember,
          semanticLabel: t.adminSetupAddMemberTitle(name),
          icon: Icons.person_add,
          onPressed: active ? () => _addMember(group) : null,
        ),
        AdminActionButton(
          label: t.adminSetupEdit,
          semanticLabel: t.adminSetupEditNamed(name),
          icon: Icons.edit,
          onPressed: () => _editGroup(group),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Speech.t;
    return AdminSectionBody(
      loading: _loading,
      error: _error,
      onRetry: _load,
      emptyText: t.adminSetupNoSharedPhones,
      header: [
        AdminNote(t.adminSetupSharedPhoneNote),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.icon(
            onPressed: _loading ? null : () => _editGroup(),
            icon: const Icon(Icons.add),
            label: Text(t.adminSetupAddSharedPhone),
          ),
        ),
      ],
      items: _groups.map(_groupCard).toList(),
    );
  }
}

/// Creates a shared phone, or renames, renumbers or deactivates one.
class SharedPhoneDialog extends StatefulWidget {
  const SharedPhoneDialog({super.key, this.group});

  final JsonMap? group;

  @override
  State<SharedPhoneDialog> createState() => _SharedPhoneDialogState();
}

class _SharedPhoneDialogState extends State<SharedPhoneDialog> {
  late final _name = TextEditingController(
    text: '${widget.group?['name'] ?? ''}',
  );
  late final _phone = TextEditingController(
    text: '${widget.group?['entry_phone_number'] ?? ''}',
  );
  late bool _active = widget.group?['is_active'] != false;
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
          name.isEmpty
              ? t.adminSetupSharedPhoneName
              : t.adminSetupSharedPhoneNumber,
        ),
      );
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final group = widget.group;
    final result = group == null
        ? await AdminSetupApi.createDeviceGroup(
            name: name,
            entryPhoneNumber: phone,
          )
        : await AdminSetupApi.updateDeviceGroup(
            group['group_id'] as int,
            name: name == '${group['name']}' ? null : name,
            entryPhoneNumber: phone == '${group['entry_phone_number']}'
                ? null
                : phone,
            isActive: _active == (group['is_active'] != false) ? null : _active,
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
      title: widget.group == null
          ? t.adminSetupAddSharedPhone
          : t.adminSetupEditSharedPhone,
      busy: _busy,
      error: _error,
      onSave: _save,
      children: [
        TextField(
          controller: _name,
          autofocus: true,
          enabled: !_busy,
          decoration: InputDecoration(labelText: t.adminSetupSharedPhoneName),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _phone,
          enabled: !_busy,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(labelText: t.adminSetupSharedPhoneNumber),
        ),
        if (widget.group != null)
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(t.adminSetupSharedPhoneActiveSwitch),
            value: _active,
            onChanged: _busy
                ? null
                : (value) => setState(() => _active = value),
          ),
      ],
    );
  }
}

/// Adds a student or teacher to a shared phone with a profile number.
/// Pops with the person's name.
class AddMemberDialog extends StatefulWidget {
  const AddMemberDialog({super.key, required this.group});

  final JsonMap group;

  @override
  State<AddMemberDialog> createState() => _AddMemberDialogState();
}

class _AddMemberDialogState extends State<AddMemberDialog> {
  final _search = TextEditingController();
  final _code = TextEditingController();
  List<JsonMap> _people = const [];
  int? _userId;
  bool _loading = true;
  bool _busy = false;
  String? _error;
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    _loadPeople();
  }

  @override
  void dispose() {
    _search.dispose();
    _code.dispose();
    super.dispose();
  }

  Future<void> _loadPeople() async {
    final generation = ++_generation;
    setState(() => _loading = true);
    final result = await AdminSetupApi.users(search: _search.text, limit: 200);
    if (!mounted || generation != _generation) return;
    final members = {
      for (final member in widget.group['members'] as List? ?? const [])
        if (member is Map) member['user_id'],
    };
    setState(() {
      _loading = false;
      if (!result.isSuccess) {
        _error = AdminSetupApi.errorText(result.failure);
        _people = const [];
      } else {
        _people = result.data!
            .where((person) => !members.contains(person['user_id']))
            .toList();
      }
      if (!_people.any((person) => person['user_id'] == _userId)) {
        _userId = _people.firstOrNull?['user_id'] as int?;
      }
    });
  }

  Future<void> _save() async {
    final t = Speech.t;
    final userId = _userId;
    final code = _code.text.trim();
    if (userId == null) {
      setState(() => _error = t.adminSetupChoosePerson);
      return;
    }
    if (!RegExp(r'^\d{1,4}$').hasMatch(code)) {
      setState(() => _error = t.adminSetupProfileCodeInvalid);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final result = await AdminSetupApi.addGroupMember(
      widget.group['group_id'] as int,
      userId: userId,
      profileCode: code,
    );
    if (!mounted) return;
    if (!result.isSuccess) {
      setState(() {
        _busy = false;
        _error = AdminSetupApi.errorText(result.failure);
      });
      return;
    }
    final person = _people.firstWhere((entry) => entry['user_id'] == userId);
    Navigator.pop(context, '${person['name']}');
  }

  @override
  Widget build(BuildContext context) {
    final t = Speech.t;
    return AdminFormDialog(
      title: t.adminSetupAddMemberTitle('${widget.group['name']}'),
      busy: _busy,
      error: _error,
      onSave: _save,
      children: [
        TextField(
          controller: _search,
          enabled: !_busy,
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => _loadPeople(),
          decoration: InputDecoration(
            labelText: t.adminSetupSearchPeople,
            suffixIcon: IconButton(
              tooltip: t.adminSetupSearchButton,
              icon: const Icon(Icons.search),
              onPressed: _loadPeople,
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (_loading)
          Semantics(
            label: t.adminSetupLoading,
            child: const LinearProgressIndicator(),
          )
        else if (_people.isEmpty)
          Text(t.adminSetupNoPeopleFound)
        else
          AdminDropdown<int>(
            label: t.adminSetupPersonField,
            value: _userId,
            options: [
              for (final person in _people)
                (
                  person['user_id'] as int,
                  t.adminSetupPersonOption(
                    '${person['name']}',
                    adminRoleName(person['role']),
                    '${person['phone_number'] ?? ''}',
                  ),
                ),
            ],
            onChanged: _busy
                ? null
                : (value) => setState(() => _userId = value),
          ),
        const SizedBox(height: 8),
        TextField(
          controller: _code,
          enabled: !_busy,
          keyboardType: TextInputType.number,
          maxLength: 4,
          decoration: InputDecoration(
            labelText: t.adminSetupProfileCodeField,
            helperText: t.adminSetupProfileCodeHelper,
            helperMaxLines: 3,
          ),
        ),
      ],
    );
  }
}
