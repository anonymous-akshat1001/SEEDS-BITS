import 'package:flutter/material.dart';

import '../../l10n/speech.dart';
import '../../services/admin_setup_api.dart';
import 'admin_common.dart';

const _none = -1;

enum _Arrange { day, teacher, schoolClass }

String _entryTitle(JsonMap entry) => Speech.t.adminSetupEntryTitle(
  '${entry['start_time']}',
  '${entry['end_time']}',
  '${entry['subject_name']}',
  '${entry['class_name']}',
);

/// Weekly timetable: filter, add, edit, deactivate, and per-date changes.
class TimetableSection extends StatefulWidget {
  const TimetableSection({super.key});

  @override
  State<TimetableSection> createState() => _TimetableSectionState();
}

class _TimetableSectionState extends State<TimetableSection> {
  List<JsonMap> _entries = const [];
  List<JsonMap> _teachers = const [];
  List<JsonMap> _classes = const [];
  int _teacherFilter = _none;
  int _classFilter = _none;
  bool _includeInactive = false;
  _Arrange _arrange = _Arrange.day;
  final _search = TextEditingController();
  bool _loading = true;
  String? _error;
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    _search.addListener(() => setState(() {}));
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final generation = ++_generation;
    setState(() {
      _loading = true;
      _error = null;
    });
    final results = await Future.wait([
      AdminSetupApi.timetable(
        teacherId: _teacherFilter == _none ? null : _teacherFilter,
        classId: _classFilter == _none ? null : _classFilter,
        includeInactive: _includeInactive,
      ),
      AdminSetupApi.users(role: 'teacher', limit: 200),
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
      _entries = results[0].data!;
      _teachers = results[1].data!;
      _classes = results[2].data!
          .where((entry) => entry['is_active'] != false)
          .toList();
    });
  }

  /// Class filter choices: every active class, or only the classes the
  /// filtered teacher is assigned to.
  List<(int, String)> get _classOptions {
    if (_teacherFilter == _none) {
      return [
        for (final schoolClass in _classes)
          (schoolClass['class_id'] as int, '${schoolClass['name']}'),
      ];
    }
    final teacher = _teachers
        .where((teacher) => teacher['user_id'] == _teacherFilter)
        .firstOrNull;
    final seen = <int>{};
    return [
      for (final pair in (teacher?['assignments'] as List?) ?? const [])
        if (pair is Map &&
            pair['class_id'] is int &&
            seen.add(pair['class_id'] as int))
          (pair['class_id'] as int, '${pair['class_name']}'),
    ];
  }

  Future<void> _openEntry([JsonMap? entry]) async {
    final saved = await showDialog<JsonMap>(
      context: context,
      barrierDismissible: false,
      builder: (_) => TimetableEntryDialog(
        entry: entry,
        teachers: _teachers,
        classes: _classes,
      ),
    );
    if (!mounted || saved == null) return;
    final added = (saved['entries'] as List?)?.length ?? 0;
    adminNotify(
      added > 1
          ? Speech.t.adminSetupLessonsAdded(added)
          : Speech.t.adminSetupLessonSaved,
    );
    await _load();
  }

  Future<void> _setActive(JsonMap entry, bool active) async {
    final t = Speech.t;
    if (!active &&
        !await adminConfirm(
          context,
          title: t.adminSetupDeactivateLessonTitle,
          message: t.adminSetupDeactivateLessonMessage(
            '${entry['subject_name']}',
            '${entry['class_name']}',
            adminWeekdayName(entry['weekday'] as int),
            '${entry['start_time']}',
          ),
          confirmLabel: t.adminSetupDeactivateLesson,
        )) {
      return;
    }
    final result = await AdminSetupApi.updateTimetableEntry(
      entry['entry_id'] as int,
      {'is_active': active},
    );
    if (!mounted) return;
    if (adminReport(
      result,
      active ? t.adminSetupLessonReactivated : t.adminSetupLessonDeactivated,
    )) {
      await _load();
    }
  }

  Future<void> _dateChanges(JsonMap entry) => showDialog<void>(
    context: context,
    builder: (_) => OccurrencesDialog(entry: entry, teachers: _teachers),
  );

  Widget _entryCard(JsonMap entry) {
    final t = Speech.t;
    final active = entry['is_active'] != false;
    final title = _arrange == _Arrange.day
        ? _entryTitle(entry)
        : t.adminSetupEntryDayTitle(
            adminWeekdayName(entry['weekday'] as int),
            _entryTitle(entry),
          );
    return AdminItemCard(
      title: title,
      status: active ? null : t.adminSetupInactive,
      lines: [
        if (_arrange != _Arrange.teacher)
          t.adminSetupEntryTeacher('${entry['teacher_name']}'),
        entry['lesson_title'] == null
            ? t.adminSetupEntryNoLesson
            : t.adminSetupEntryLesson('${entry['lesson_title']}'),
        if (entry['valid_from'] != null)
          t.adminSetupEntryFrom(adminIsoDateText(entry['valid_from'])),
        if (entry['valid_until'] != null)
          t.adminSetupEntryUntil(adminIsoDateText(entry['valid_until'])),
      ],
      actions: [
        AdminActionButton(
          label: t.adminSetupEdit,
          semanticLabel: t.adminSetupEditNamed(title),
          icon: Icons.edit,
          onPressed: () => _openEntry(entry),
        ),
        if (active)
          AdminActionButton(
            label: t.adminSetupDateChanges,
            semanticLabel: t.adminSetupDateChangesNamed(title),
            icon: Icons.event_busy,
            onPressed: () => _dateChanges(entry),
          ),
        AdminActionButton(
          label: active
              ? t.adminSetupDeactivateLesson
              : t.adminSetupReactivateLesson,
          semanticLabel: active
              ? t.adminSetupDeactivateNamed(title)
              : t.adminSetupActivateNamed(title),
          onPressed: () => _setActive(entry, !active),
        ),
      ],
    );
  }

  /// Lessons matching the search, grouped by the chosen arrangement. Days
  /// keep week order; teachers and classes are alphabetical. Within a group
  /// lessons run by day, then start time.
  List<(String, List<JsonMap>)> _groups() {
    final query = _search.text.trim().toLowerCase();
    final entries =
        [
          for (final entry in _entries)
            if (query.isEmpty ||
                [
                  entry['teacher_name'],
                  entry['class_name'],
                  entry['subject_name'],
                  entry['lesson_title'],
                ].any(
                  (value) => '${value ?? ''}'.toLowerCase().contains(query),
                ))
              entry,
        ]..sort((a, b) {
          final day = (a['weekday'] as int).compareTo(b['weekday'] as int);
          return day != 0
              ? day
              : '${a['start_time']}'.compareTo('${b['start_time']}');
        });
    final groups = <String, List<JsonMap>>{};
    String nameOf(JsonMap entry) => switch (_arrange) {
      _Arrange.day => adminWeekdayName(entry['weekday'] as int),
      _Arrange.teacher => '${entry['teacher_name']}',
      _Arrange.schoolClass => '${entry['class_name']}',
    };
    for (final entry in entries) {
      groups.putIfAbsent(nameOf(entry), () => []).add(entry);
    }
    final ordered = groups.entries
        .map((group) => (group.key, group.value))
        .toList();
    if (_arrange != _Arrange.day) {
      ordered.sort((a, b) => a.$1.toLowerCase().compareTo(b.$1.toLowerCase()));
    }
    return ordered;
  }

  @override
  Widget build(BuildContext context) {
    final t = Speech.t;
    final items = <Widget>[];
    for (final group in _groups()) {
      items
        ..add(AdminHeading(t.adminSetupGroupHeading(group.$1, group.$2.length)))
        ..addAll(group.$2.map(_entryCard));
    }
    return AdminSectionBody(
      loading: _loading,
      error: _error,
      onRetry: _load,
      emptyText: _search.text.trim().isEmpty
          ? t.adminSetupNoTimetable
          : t.adminSetupNoMatchingLessons,
      header: [
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.icon(
            onPressed: _loading || _error != null ? null : () => _openEntry(),
            icon: const Icon(Icons.add),
            label: Text(t.adminSetupAddLesson),
          ),
        ),
        const SizedBox(height: 12),
        AdminDropdown<int>(
          label: t.adminSetupTeacherField,
          value: _teacherFilter,
          options: [
            (_none, t.adminSetupAllTeachers),
            for (final teacher in _teachers)
              (teacher['user_id'] as int, '${teacher['name']}'),
          ],
          onChanged: (value) {
            setState(() {
              _teacherFilter = value ?? _none;
              if (!_classOptions.any((option) => option.$1 == _classFilter)) {
                _classFilter = _none;
              }
            });
            _load();
          },
        ),
        const SizedBox(height: 8),
        AdminDropdown<int>(
          label: t.adminSetupClassField,
          value: _classFilter,
          options: [(_none, t.adminSetupAllClasses), ..._classOptions],
          onChanged: (value) {
            setState(() => _classFilter = value ?? _none);
            _load();
          },
        ),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          title: Text(t.adminSetupShowInactive),
          value: _includeInactive,
          onChanged: (value) {
            setState(() => _includeInactive = value ?? false);
            _load();
          },
        ),
        AdminChoiceChips<_Arrange>(
          heading: t.adminSetupArrangeBy,
          options: [
            (_Arrange.day, t.adminSetupArrangeDay),
            (_Arrange.teacher, t.adminSetupArrangeTeacher),
            (_Arrange.schoolClass, t.adminSetupArrangeClass),
          ],
          selected: _arrange,
          onSelected: (value) => setState(() => _arrange = value),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _search,
          decoration: InputDecoration(
            labelText: t.adminSetupTimetableSearch,
            prefixIcon: const Icon(Icons.search),
          ),
        ),
      ],
      items: items,
    );
  }
}

/// Creates or edits a weekly timetable lesson. Pops with the saved entry.
class TimetableEntryDialog extends StatefulWidget {
  const TimetableEntryDialog({
    super.key,
    this.entry,
    required this.teachers,
    required this.classes,
  });

  final JsonMap? entry;
  final List<JsonMap> teachers;
  final List<JsonMap> classes;

  @override
  State<TimetableEntryDialog> createState() => _TimetableEntryDialogState();
}

class _TimetableEntryDialogState extends State<TimetableEntryDialog> {
  late final bool _editing = widget.entry != null;
  late int? _teacherId =
      widget.entry?['teacher_id'] as int? ??
      _teachersWithPairs.firstOrNull?['user_id'] as int?;
  late int? _classId = widget.entry?['class_id'] as int?;
  late int? _subjectId = widget.entry?['subject_id'] as int?;
  late final Set<int> _weekdays = {widget.entry?['weekday'] as int? ?? 0};
  late final _start = TextEditingController(
    text: '${widget.entry?['start_time'] ?? ''}',
  );
  late final _end = TextEditingController(
    text: '${widget.entry?['end_time'] ?? ''}',
  );
  late DateTime? _from = DateTime.tryParse('${widget.entry?['valid_from']}');
  late DateTime? _until = DateTime.tryParse('${widget.entry?['valid_until']}');
  late int _lessonId = widget.entry?['lesson_playlist_id'] as int? ?? _none;
  List<JsonMap> _lessons = const [];
  bool _loadingLessons = false;
  bool _busy = false;
  String? _error;
  int _lessonGeneration = 0;

  static List<JsonMap> _pairsOf(JsonMap? teacher) => [
    for (final pair in (teacher?['assignments'] as List?) ?? const [])
      if (pair is Map && pair['is_active'] != false)
        Map<String, dynamic>.from(pair),
  ];

  /// New lessons: only teachers who teach something can be scheduled.
  /// Editing: only teachers who teach this lesson's class and subject.
  List<JsonMap> get _teachersWithPairs => [
    for (final teacher in widget.teachers)
      if (_editing
          ? teacher['user_id'] == widget.entry!['teacher_id'] ||
                _pairsOf(teacher).any(
                  (pair) =>
                      pair['class_id'] == widget.entry!['class_id'] &&
                      pair['subject_id'] == widget.entry!['subject_id'],
                )
          : _pairsOf(teacher).isNotEmpty)
        teacher,
  ];

  JsonMap? get _teacher => widget.teachers
      .where((teacher) => teacher['user_id'] == _teacherId)
      .firstOrNull;

  /// The chosen teacher's classes, each once, in the order assigned.
  List<(int, String)> get _classOptions {
    final seen = <int>{};
    return [
      for (final pair in _pairsOf(_teacher))
        if (seen.add(pair['class_id'] as int))
          (pair['class_id'] as int, '${pair['class_name']}'),
    ];
  }

  /// The chosen teacher's subjects in the chosen class.
  List<(int, String)> get _subjectOptions => [
    for (final pair in _pairsOf(_teacher))
      if (pair['class_id'] == _classId)
        (pair['subject_id'] as int, '${pair['subject_name']}'),
  ];

  @override
  void initState() {
    super.initState();
    if (!_editing) _chooseTeacher(_teacherId, reload: false);
    _loadLessons();
  }

  @override
  void dispose() {
    _start.dispose();
    _end.dispose();
    super.dispose();
  }

  /// A new teacher narrows the class and subject lists to what they teach.
  void _chooseTeacher(int? teacherId, {bool reload = true}) {
    _teacherId = teacherId;
    if (!_editing) {
      final classes = _classOptions;
      if (!classes.any((option) => option.$1 == _classId)) {
        _classId = classes.firstOrNull?.$1;
      }
      _chooseClass(_classId, reload: false);
    }
    if (reload) {
      setState(() {});
      _loadLessons();
    }
  }

  void _chooseClass(int? classId, {bool reload = true}) {
    _classId = classId;
    final subjects = _subjectOptions;
    if (!subjects.any((option) => option.$1 == _subjectId)) {
      _subjectId = subjects.firstOrNull?.$1;
    }
    if (reload) {
      setState(() {});
      _loadLessons();
    }
  }

  Future<void> _loadLessons() async {
    final teacherId = _teacherId;
    final classId = _classId;
    final subjectId = _subjectId;
    final generation = ++_lessonGeneration;
    if (teacherId == null || classId == null || subjectId == null) {
      setState(() => _lessons = const []);
      return;
    }
    setState(() => _loadingLessons = true);
    final result = await AdminSetupApi.teacherLessons(
      teacherId,
      classId: classId,
      subjectId: subjectId,
    );
    if (!mounted || generation != _lessonGeneration) return;
    setState(() {
      _loadingLessons = false;
      _lessons = result.data ?? const [];
      if (!_lessons.any((lesson) => lesson['playlist_id'] == _lessonId)) {
        _lessonId = _none;
      }
    });
  }

  Future<void> _save() async {
    final t = Speech.t;
    final teacherId = _teacherId;
    final classId = _classId;
    final subjectId = _subjectId;
    if (teacherId == null || classId == null || subjectId == null) {
      setState(
        () => _error = t.adminSetupRequiredField(
          teacherId == null
              ? t.adminSetupTeacherField
              : classId == null
              ? t.adminSetupClassField
              : t.adminSetupSubjectField,
        ),
      );
      return;
    }
    final start = adminParseClock(_start.text);
    final end = adminParseClock(_end.text);
    if (start == null || end == null) {
      setState(
        () => _error = t.adminSetupTimeInvalid(
          start == null ? t.adminSetupStartField : t.adminSetupEndField,
        ),
      );
      return;
    }
    if (start >= end) {
      setState(() => _error = t.adminSetupEndBeforeStart);
      return;
    }
    if (_from != null && _until != null && _until!.isBefore(_from!)) {
      setState(() => _error = t.adminSetupUntilBeforeFrom);
      return;
    }
    if (_weekdays.isEmpty) {
      setState(() => _error = t.adminSetupChooseDays);
      return;
    }
    final days = _weekdays.toList()..sort();
    setState(() {
      _busy = true;
      _error = null;
    });
    final body = <String, dynamic>{
      'teacher_id': teacherId,
      if (_editing || days.length == 1)
        'weekday': days.first
      else
        'weekdays': days,
      'start_time': adminNormalizeClock(_start.text),
      'end_time': adminNormalizeClock(_end.text),
      if (_from != null) 'valid_from': AdminSetupApi.isoDate(_from!),
      if (_until != null) 'valid_until': AdminSetupApi.isoDate(_until!),
    };
    final result = _editing
        ? await AdminSetupApi.updateTimetableEntry(
            widget.entry!['entry_id'] as int,
            {
              ...body,
              if (_from == null && widget.entry!['valid_from'] != null)
                'clear_valid_from': true,
              if (_until == null && widget.entry!['valid_until'] != null)
                'clear_valid_until': true,
              if (_lessonId == _none)
                'clear_lesson': true
              else
                'lesson_playlist_id': _lessonId,
            },
          )
        : await AdminSetupApi.createTimetableEntry({
            ...body,
            'class_id': classId,
            'subject_id': subjectId,
            if (_lessonId != _none) 'lesson_playlist_id': _lessonId,
          });
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
    final enabled = !_busy;
    return AdminFormDialog(
      title: _editing ? t.adminSetupEditLesson : t.adminSetupAddLesson,
      busy: _busy,
      error: _error,
      onSave: _save,
      children: [
        AdminDropdown<int>(
          label: t.adminSetupTeacherField,
          value: _teacherId,
          options: [
            for (final teacher in _teachersWithPairs)
              (teacher['user_id'] as int, '${teacher['name']}'),
          ],
          helperText: _teachersWithPairs.isEmpty
              ? t.adminSetupTeacherHasNoPairs
              : null,
          onChanged: enabled ? _chooseTeacher : null,
        ),
        const SizedBox(height: 8),
        if (_editing)
          Text(
            t.adminSetupClassSubjectFixed(
              '${widget.entry!['class_name']}',
              '${widget.entry!['subject_name']}',
            ),
          )
        else if (_teacher != null) ...[
          AdminDropdown<int>(
            label: t.adminSetupClassField,
            value: _classId,
            options: _classOptions,
            onChanged: enabled ? _chooseClass : null,
          ),
          const SizedBox(height: 8),
          AdminDropdown<int>(
            label: t.adminSetupSubjectField,
            value: _subjectId,
            options: _subjectOptions,
            onChanged: enabled
                ? (value) {
                    setState(() => _subjectId = value);
                    _loadLessons();
                  }
                : null,
          ),
        ],
        const SizedBox(height: 8),
        if (_editing)
          AdminDropdown<int>(
            label: t.adminSetupWeekdayField,
            value: _weekdays.first,
            options: [
              for (var day = 0; day < 7; day++) (day, adminWeekdayName(day)),
            ],
            onChanged: enabled
                ? (value) => setState(
                    () => _weekdays
                      ..clear()
                      ..add(value ?? 0),
                  )
                : null,
          )
        else ...[
          Semantics(
            header: true,
            child: Text(
              t.adminSetupDaysField,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (var day = 0; day < 7; day++)
                FilterChip(
                  label: Text(adminWeekdayName(day)),
                  selected: _weekdays.contains(day),
                  onSelected: enabled
                      ? (selected) => setState(
                          () => selected
                              ? _weekdays.add(day)
                              : _weekdays.remove(day),
                        )
                      : null,
                ),
            ],
          ),
        ],
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                controller: _start,
                enabled: enabled,
                keyboardType: TextInputType.datetime,
                decoration: InputDecoration(
                  labelText: t.adminSetupStartField,
                  helperText: t.adminSetupTimeHelper,
                  helperMaxLines: 2,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _end,
                enabled: enabled,
                keyboardType: TextInputType.datetime,
                decoration: InputDecoration(
                  labelText: t.adminSetupEndField,
                  helperText: t.adminSetupTimeHelper,
                  helperMaxLines: 2,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        AdminDateField(
          label: t.adminSetupValidFrom,
          value: _from,
          onChanged: (value) => setState(() => _from = value),
        ),
        const SizedBox(height: 8),
        AdminDateField(
          label: t.adminSetupValidUntil,
          value: _until,
          onChanged: (value) => setState(() => _until = value),
        ),
        const SizedBox(height: 12),
        if (_loadingLessons)
          Semantics(
            label: t.adminSetupLoading,
            child: const LinearProgressIndicator(),
          )
        else
          AdminDropdown<int>(
            label: t.adminSetupLessonField,
            value: _lessonId,
            helperText: _lessons.isEmpty ? t.adminSetupNoLessonsFound : null,
            options: [
              (_none, t.adminSetupNoLesson),
              for (final lesson in _lessons)
                (lesson['playlist_id'] as int, '${lesson['title']}'),
            ],
            onChanged: enabled
                ? (value) => setState(() => _lessonId = value ?? _none)
                : null,
          ),
      ],
    );
  }
}

/// Changes to single dates of one weekly lesson.
class OccurrencesDialog extends StatefulWidget {
  const OccurrencesDialog({
    super.key,
    required this.entry,
    required this.teachers,
  });

  final JsonMap entry;
  final List<JsonMap> teachers;

  @override
  State<OccurrencesDialog> createState() => _OccurrencesDialogState();
}

class _OccurrencesDialogState extends State<OccurrencesDialog> {
  List<JsonMap> _changes = const [];
  bool _loading = true;
  String? _error;

  int get _entryId => widget.entry['entry_id'] as int;

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
    final result = await AdminSetupApi.occurrences(_entryId);
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (result.isSuccess) {
        _changes = result.data!;
      } else {
        _error = AdminSetupApi.errorText(result.failure);
      }
    });
  }

  Future<void> _edit([JsonMap? change]) async {
    final saved = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => OccurrenceFormDialog(
        entry: widget.entry,
        teachers: widget.teachers,
        change: change,
      ),
    );
    if (!mounted || saved == null) return;
    adminNotify(Speech.t.adminSetupDateChangeSaved(adminIsoDateText(saved)));
    await _load();
  }

  Future<void> _clear(JsonMap change) async {
    final day = '${change['occurrence_date']}';
    final result = await AdminSetupApi.clearOccurrence(_entryId, day);
    if (!mounted) return;
    if (adminReport(
      result,
      Speech.t.adminSetupChangeCleared(adminIsoDateText(day)),
    )) {
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Speech.t;
    return AlertDialog(
      scrollable: true,
      insetPadding: const EdgeInsets.all(12),
      title: Text(
        t.adminSetupDateChangesTitle(
          _entryTitle(widget.entry),
          adminWeekdayName(widget.entry['weekday'] as int),
        ),
      ),
      content: SizedBox(
        width: 520,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.icon(
                onPressed: () => _edit(),
                icon: const Icon(Icons.add),
                label: Text(t.adminSetupAddDateChange),
              ),
            ),
            const SizedBox(height: 12),
            if (_loading)
              Semantics(
                label: t.adminSetupLoading,
                child: const LinearProgressIndicator(),
              )
            else if (_error != null)
              AdminErrorText(_error!)
            else if (_changes.isEmpty)
              Text(t.adminSetupNoDateChanges)
            else
              for (final change in _changes)
                Builder(
                  builder: (_) {
                    final date = adminIsoDateText(change['occurrence_date']);
                    return AdminItemCard(
                      title: date,
                      lines: [
                        if (change['is_cancelled'] == true)
                          t.adminSetupCancelledLabel,
                        if (change['substitute_name'] != null)
                          t.adminSetupSubstituteLabel(
                            '${change['substitute_name']}',
                          ),
                        if (change['lesson_playlist_id'] != null)
                          t.adminSetupDifferentLesson,
                        if ('${change['note'] ?? ''}'.isNotEmpty)
                          t.adminSetupNoteLabel('${change['note']}'),
                      ],
                      actions: [
                        AdminActionButton(
                          label: t.adminSetupEdit,
                          semanticLabel: t.adminSetupEditDateChangeNamed(date),
                          icon: Icons.edit,
                          onPressed: () => _edit(change),
                        ),
                        AdminActionButton(
                          label: t.adminSetupClearChange,
                          semanticLabel: t.adminSetupClearChangeNamed(date),
                          icon: Icons.undo,
                          onPressed: () => _clear(change),
                        ),
                      ],
                    );
                  },
                ),
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

/// Sets one date of a weekly lesson: cancel it, or use a substitute teacher
/// and/or a different lesson playlist. Pops with the ISO date saved.
class OccurrenceFormDialog extends StatefulWidget {
  const OccurrenceFormDialog({
    super.key,
    required this.entry,
    required this.teachers,
    this.change,
  });

  final JsonMap entry;
  final List<JsonMap> teachers;
  final JsonMap? change;

  @override
  State<OccurrenceFormDialog> createState() => _OccurrenceFormDialogState();
}

class _OccurrenceFormDialogState extends State<OccurrenceFormDialog> {
  late DateTime? _date = DateTime.tryParse(
    '${widget.change?['occurrence_date']}',
  );
  late bool _cancelled = widget.change?['is_cancelled'] == true;
  late int _substituteId =
      widget.change?['substitute_teacher_id'] as int? ?? _none;
  late int _lessonId = widget.change?['lesson_playlist_id'] as int? ?? _none;
  late final _note = TextEditingController(
    text: '${widget.change?['note'] ?? ''}',
  );
  List<JsonMap> _lessons = const [];
  bool _busy = false;
  String? _error;
  int _generation = 0;

  int get _regularTeacher => widget.entry['teacher_id'] as int;

  @override
  void initState() {
    super.initState();
    _loadLessons();
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _loadLessons() async {
    final generation = ++_generation;
    final result = await AdminSetupApi.teacherLessons(
      _substituteId == _none ? _regularTeacher : _substituteId,
      classId: widget.entry['class_id'] as int,
      subjectId: widget.entry['subject_id'] as int,
    );
    if (!mounted || generation != _generation) return;
    setState(() {
      _lessons = result.data ?? const [];
      if (!_lessons.any((lesson) => lesson['playlist_id'] == _lessonId)) {
        _lessonId = _none;
      }
    });
  }

  bool _selectable(DateTime day) {
    if (day.weekday - 1 != widget.entry['weekday']) return false;
    final from = DateTime.tryParse('${widget.entry['valid_from']}');
    final until = DateTime.tryParse('${widget.entry['valid_until']}');
    if (from != null && day.isBefore(from)) return false;
    if (until != null && day.isAfter(until)) return false;
    return true;
  }

  Future<void> _save() async {
    final date = _date;
    if (date == null) {
      setState(() => _error = Speech.t.adminSetupChooseDateFirst);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final day = AdminSetupApi.isoDate(date);
    final result = await AdminSetupApi.setOccurrence(
      widget.entry['entry_id'] as int,
      day,
      isCancelled: _cancelled,
      substituteTeacherId: _cancelled || _substituteId == _none
          ? null
          : _substituteId,
      lessonPlaylistId: _cancelled || _lessonId == _none ? null : _lessonId,
      note: _note.text,
    );
    if (!mounted) return;
    if (!result.isSuccess) {
      setState(() {
        _busy = false;
        _error = AdminSetupApi.errorText(result.failure);
      });
      return;
    }
    Navigator.pop(context, day);
  }

  @override
  Widget build(BuildContext context) {
    final t = Speech.t;
    final enabled = !_busy;
    return AdminFormDialog(
      title: t.adminSetupDateChangeTitle(_entryTitle(widget.entry)),
      busy: _busy,
      error: _error,
      onSave: _save,
      children: [
        if (widget.change != null)
          Text(
            t.adminSetupDateValue(t.adminSetupDateField, adminDateText(_date!)),
          )
        else
          AdminDateField(
            label: t.adminSetupDateField,
            value: _date,
            allowClear: false,
            selectableDay: _selectable,
            onChanged: (value) => setState(() => _date = value),
          ),
        const SizedBox(height: 8),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          title: Text(t.adminSetupCancelOnDate),
          value: _cancelled,
          onChanged: enabled
              ? (value) => setState(() => _cancelled = value ?? false)
              : null,
        ),
        if (!_cancelled) ...[
          AdminDropdown<int>(
            label: t.adminSetupSubstituteField,
            value: _substituteId,
            options: [
              (
                _none,
                t.adminSetupRegularTeacher('${widget.entry['teacher_name']}'),
              ),
              for (final teacher in widget.teachers)
                if (teacher['user_id'] != _regularTeacher)
                  (teacher['user_id'] as int, '${teacher['name']}'),
            ],
            onChanged: enabled
                ? (value) {
                    setState(() => _substituteId = value ?? _none);
                    _loadLessons();
                  }
                : null,
          ),
          const SizedBox(height: 8),
          AdminDropdown<int>(
            label: t.adminSetupDateLessonField,
            value: _lessonId,
            helperText: _lessons.isEmpty ? t.adminSetupNoLessonsFound : null,
            options: [
              (_none, t.adminSetupUsualLesson),
              for (final lesson in _lessons)
                (lesson['playlist_id'] as int, '${lesson['title']}'),
            ],
            onChanged: enabled
                ? (value) => setState(() => _lessonId = value ?? _none)
                : null,
          ),
        ],
        const SizedBox(height: 8),
        TextField(
          controller: _note,
          enabled: enabled,
          maxLength: 500,
          decoration: InputDecoration(labelText: t.adminSetupNoteField),
        ),
      ],
    );
  }
}
