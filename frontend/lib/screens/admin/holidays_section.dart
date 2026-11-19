import 'package:flutter/material.dart';

import '../../l10n/speech.dart';
import '../../services/admin_setup_api.dart';
import 'admin_common.dart';

/// School holidays: no lessons are scheduled on these dates.
class HolidaysSection extends StatefulWidget {
  const HolidaysSection({super.key});

  @override
  State<HolidaysSection> createState() => _HolidaysSectionState();
}

class _HolidaysSectionState extends State<HolidaysSection> {
  List<JsonMap> _holidays = const [];
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
    final result = await AdminSetupApi.holidays();
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (result.isSuccess) {
        _holidays = result.data!;
      } else {
        _error = Speech.t.adminSetupLoadFailed(
          AdminSetupApi.errorText(result.failure),
        );
      }
    });
  }

  Future<void> _add() async {
    final added = await showDialog<JsonMap>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const HolidayDialog(),
    );
    if (!mounted || added == null) return;
    adminNotify(
      Speech.t.adminSetupHolidayAdded(
        '${added['name']}',
        adminIsoDateText(added['holiday_date']),
      ),
    );
    await _load();
  }

  Future<void> _delete(JsonMap holiday) async {
    final t = Speech.t;
    final name = '${holiday['name']}';
    final date = adminIsoDateText(holiday['holiday_date']);
    if (!await adminConfirm(
      context,
      title: t.adminSetupDeleteHolidayTitle,
      message: t.adminSetupDeleteHolidayMessage(name, date),
      confirmLabel: t.adminSetupDelete,
    )) {
      return;
    }
    final result = await AdminSetupApi.deleteHoliday(
      holiday['holiday_id'] as int,
    );
    if (!mounted) return;
    if (adminReport(result, t.adminSetupHolidayDeleted)) await _load();
  }

  @override
  Widget build(BuildContext context) {
    final t = Speech.t;
    return AdminSectionBody(
      loading: _loading,
      error: _error,
      onRetry: _load,
      emptyText: t.adminSetupNoHolidays,
      header: [
        AdminNote(t.adminSetupHolidayNote),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.icon(
            onPressed: _loading ? null : _add,
            icon: const Icon(Icons.add),
            label: Text(t.adminSetupAddHoliday),
          ),
        ),
      ],
      items: [
        for (final holiday in _holidays)
          AdminItemCard(
            title: adminIsoDateText(holiday['holiday_date']),
            lines: ['${holiday['name']}'],
            actions: [
              AdminActionButton(
                label: t.adminSetupDelete,
                semanticLabel: t.adminSetupDeleteHolidayNamed(
                  '${holiday['name']}',
                  adminIsoDateText(holiday['holiday_date']),
                ),
                icon: Icons.delete_outline,
                onPressed: () => _delete(holiday),
              ),
            ],
          ),
      ],
    );
  }
}

class HolidayDialog extends StatefulWidget {
  const HolidayDialog({super.key});

  @override
  State<HolidayDialog> createState() => _HolidayDialogState();
}

class _HolidayDialogState extends State<HolidayDialog> {
  final _name = TextEditingController();
  DateTime? _date;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final t = Speech.t;
    final name = _name.text.trim();
    final date = _date;
    if (date == null) {
      setState(() => _error = t.adminSetupChooseDateFirst);
      return;
    }
    if (name.isEmpty) {
      setState(
        () => _error = t.adminSetupRequiredField(t.adminSetupHolidayName),
      );
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final result = await AdminSetupApi.addHoliday(date, name);
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
      title: t.adminSetupAddHoliday,
      busy: _busy,
      error: _error,
      onSave: _save,
      children: [
        AdminDateField(
          label: t.adminSetupDateField,
          value: _date,
          allowClear: false,
          onChanged: (value) => setState(() => _date = value),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _name,
          enabled: !_busy,
          decoration: InputDecoration(labelText: t.adminSetupHolidayName),
        ),
      ],
    );
  }
}
