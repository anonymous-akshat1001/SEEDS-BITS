import 'package:flutter/material.dart';

import '../../l10n/speech.dart';
import '../../services/admin_setup_api.dart';
import 'admin_common.dart';

/// Records of live and ended classes; live ones can be extended or ended.
class ClassRecordsSection extends StatefulWidget {
  const ClassRecordsSection({super.key});

  @override
  State<ClassRecordsSection> createState() => _ClassRecordsSectionState();
}

class _ClassRecordsSectionState extends State<ClassRecordsSection> {
  List<JsonMap> _sessions = const [];
  String _status = 'all';
  bool _loading = true;
  String? _error;
  int _generation = 0;
  final Set<int> _busy = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final generation = ++_generation;
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await AdminSetupApi.sessions(_status);
    if (!mounted || generation != _generation) return;
    setState(() {
      _loading = false;
      if (result.isSuccess) {
        _sessions = result.data!;
      } else {
        _error = Speech.t.adminSetupLoadFailed(
          AdminSetupApi.errorText(result.failure),
        );
      }
    });
  }

  String _title(JsonMap session) => Speech.t.adminSetupRecordTitle(
    '${session['subject_name'] ?? session['title'] ?? ''}',
    '${session['class_name'] ?? ''}',
  );

  Future<void> _extend(JsonMap session) async {
    final id = session['session_id'] as int;
    setState(() => _busy.add(id));
    final result = await AdminSetupApi.extendSession(id);
    if (!mounted) return;
    setState(() => _busy.remove(id));
    if (adminReport(
      result,
      Speech.t.adminSetupExtended('${result.data?['cutoff_clock'] ?? ''}'),
    )) {
      await _load();
    }
  }

  Future<void> _end(JsonMap session) async {
    final t = Speech.t;
    final title = _title(session);
    if (!await adminConfirm(
      context,
      title: t.adminSetupEndTitle,
      message: t.adminSetupEndMessage(title),
      confirmLabel: t.adminSetupEndClass,
      cancelLabel: t.adminSetupKeepClass,
    )) {
      return;
    }
    final id = session['session_id'] as int;
    setState(() => _busy.add(id));
    final result = await AdminSetupApi.endSession(id);
    if (!mounted) return;
    setState(() => _busy.remove(id));
    if (adminReport(result, t.adminSetupEnded)) await _load();
  }

  String? _endReason(Object? reason) {
    final t = Speech.t;
    return switch (reason) {
      null || '' => null,
      'teacher' => t.adminSetupEndedByTeacher,
      'admin' => t.adminSetupEndedByAdmin,
      'automatic' => t.adminSetupEndedAutomatically,
      _ => t.adminSetupEndedOther('$reason'),
    };
  }

  Widget _card(JsonMap session) {
    final t = Speech.t;
    final id = session['session_id'] as int;
    final live = session['is_active'] == true;
    final title = _title(session);
    final reason = live ? null : _endReason(session['end_reason']);
    final busy = _busy.contains(id);
    return AdminItemCard(
      title: title,
      status: live
          ? (session['cutoff_clock'] == null
                ? t.adminSetupRecordLive
                : t.adminSetupRecordLiveUntil('${session['cutoff_clock']}'))
          : t.adminSetupRecordsEnded,
      lines: [
        t.adminSetupEntryTeacher('${session['teacher_name'] ?? ''}'),
        t.adminSetupRecordStarted(adminTimestampText(session['started_at'])),
        if (session['ended_at'] != null)
          t.adminSetupRecordEnded(adminTimestampText(session['ended_at'])),
        ?reason,
        t.adminSetupStudentsJoined(
          (session['students_joined'] as num?)?.toInt() ?? 0,
        ),
        t.adminSetupExtensionMinutes(
          (session['extension_minutes'] as num?)?.toInt() ?? 0,
        ),
      ],
      actions: [
        if (live) ...[
          AdminActionButton(
            label: t.adminSetupAddFifteen,
            semanticLabel: t.adminSetupAddFifteenNamed(title),
            icon: Icons.more_time,
            onPressed: busy ? null : () => _extend(session),
          ),
          AdminActionButton(
            label: t.adminSetupEndForEveryone,
            semanticLabel: t.adminSetupEndForEveryoneNamed(title),
            icon: Icons.stop_circle_outlined,
            onPressed: busy ? null : () => _end(session),
          ),
        ],
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
      emptyText: t.adminSetupNoRecords,
      header: [
        AdminChoiceChips<String>(
          heading: t.adminSetupShowFilter,
          options: [
            ('live', t.adminSetupRecordsLive),
            ('ended', t.adminSetupRecordsEnded),
            ('all', t.adminSetupFilterAll),
          ],
          selected: _status,
          onSelected: (value) {
            setState(() => _status = value);
            _load();
          },
        ),
      ],
      items: _sessions.map(_card).toList(),
    );
  }
}
