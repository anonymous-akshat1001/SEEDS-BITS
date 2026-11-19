import 'package:flutter/material.dart';

import '../../l10n/speech.dart';
import '../../services/admin_setup_api.dart';
import 'admin_common.dart';

/// Every lesson on one date (today by default) with its current state.
class ScheduleSection extends StatefulWidget {
  const ScheduleSection({super.key});

  @override
  State<ScheduleSection> createState() => _ScheduleSectionState();
}

class _ScheduleSectionState extends State<ScheduleSection> {
  late DateTime _day = _today();
  List<JsonMap> _lessons = const [];
  bool _loading = true;
  String? _error;
  int _generation = 0;

  static DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

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
    final result = await AdminSetupApi.schedule(_day);
    if (!mounted || generation != _generation) return;
    setState(() {
      _loading = false;
      if (result.isSuccess) {
        _lessons = result.data!;
      } else {
        _error = Speech.t.adminSetupLoadFailed(
          AdminSetupApi.errorText(result.failure),
        );
      }
    });
  }

  void _setDay(DateTime? day) {
    if (day == null) return;
    setState(() => _day = DateTime(day.year, day.month, day.day));
    _load();
  }

  String _stateName(Object? state) {
    final t = Speech.t;
    return switch (state) {
      'upcoming' => t.adminSetupStateUpcoming,
      'live' => t.adminSetupStateLive,
      'held' => t.adminSetupStateHeld,
      'cancelled' => t.adminSetupStateCancelled,
      'not_started' => t.adminSetupStateNotStarted,
      _ => '${state ?? ''}',
    };
  }

  @override
  Widget build(BuildContext context) {
    final t = Speech.t;
    return AdminSectionBody(
      loading: _loading,
      error: _error,
      onRetry: _load,
      emptyText: t.adminSetupNoLessonsOnDay,
      header: [
        AdminHeading(t.adminSetupScheduleFor(adminDateText(_day))),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            OutlinedButton.icon(
              onPressed: () =>
                  _setDay(DateTime(_day.year, _day.month, _day.day - 1)),
              icon: const Icon(Icons.chevron_left),
              label: Text(t.adminSetupPreviousDay),
            ),
            OutlinedButton(
              onPressed: () => _setDay(_today()),
              child: Text(t.adminSetupToday),
            ),
            OutlinedButton.icon(
              onPressed: () =>
                  _setDay(DateTime(_day.year, _day.month, _day.day + 1)),
              icon: const Icon(Icons.chevron_right),
              label: Text(t.adminSetupNextDay),
            ),
            AdminDateField(
              label: t.adminSetupDateField,
              value: _day,
              allowClear: false,
              onChanged: _setDay,
            ),
          ],
        ),
      ],
      items: [
        for (final lesson in _lessons)
          AdminItemCard(
            title: t.adminSetupEntryTitle(
              '${lesson['start_time']}',
              '${lesson['end_time']}',
              '${lesson['subject_name']}',
              '${lesson['class_name']}',
            ),
            status: t.adminSetupStateLabel(_stateName(lesson['state'])),
            lines: [
              lesson['substitute'] == true
                  ? t.adminSetupScheduleSubstitute('${lesson['teacher_name']}')
                  : t.adminSetupEntryTeacher('${lesson['teacher_name']}'),
              lesson['has_lesson'] == true
                  ? t.adminSetupLessonReady
                  : t.adminSetupEntryNoLesson,
            ],
          ),
      ],
    );
  }
}
