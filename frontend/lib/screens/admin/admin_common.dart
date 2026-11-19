import 'package:flutter/material.dart';

import '../../l10n/speech.dart';
import '../../services/api_service.dart';
import '../../services/admin_setup_api.dart';
import '../../services/message_center.dart';
import '../../utils/ui_utils.dart';

/// Shows (and speaks) the result of an administrator action.
void adminNotify(String message, {bool error = false}) =>
    error ? MessageCenter.error(message) : MessageCenter.success(message);

/// Reports [result]; returns whether it succeeded.
bool adminReport(ApiResult<Object?> result, String successMessage) {
  if (result.isSuccess) {
    adminNotify(successMessage);
    return true;
  }
  adminNotify(AdminSetupApi.errorText(result.failure), error: true);
  return false;
}

List<String> _commaList(String text) =>
    text.split(',').map((item) => item.trim()).toList();

/// Weekday name; 0 is Monday, as in the timetable.
String adminWeekdayName(int weekday) {
  final names = _commaList(Speech.t.spokenWeekdays);
  return weekday >= 0 && weekday < names.length ? names[weekday] : '$weekday';
}

String adminDateText(DateTime day) => Speech.t.adminSetupDateFormat(
  adminWeekdayName(day.weekday - 1),
  '${day.day}',
  _commaList(Speech.t.spokenMonths)[day.month - 1],
  '${day.year}',
);

/// "Tuesday 17 November 2026" for an ISO date such as 2026-11-17.
String adminIsoDateText(Object? iso) {
  final parsed = DateTime.tryParse('${iso ?? ''}');
  return parsed == null ? '${iso ?? ''}' : adminDateText(parsed);
}

String adminClockText(DateTime time) =>
    '${time.hour.toString().padLeft(2, '0')}:'
    '${time.minute.toString().padLeft(2, '0')}';

/// Date and time for a server timestamp, in the school's time zone (IST).
/// The server sends school-local times with their offset, so the wall-clock
/// part is shown as written, whatever this computer's clock is set to.
String adminTimestampText(Object? iso) {
  final text = '${iso ?? ''}';
  final match = RegExp(
    r'^(\d{4})-(\d\d)-(\d\d)[T ](\d\d):(\d\d)',
  ).firstMatch(text);
  if (match == null) return text;
  final part = [for (var i = 1; i <= 5; i++) int.parse(match.group(i)!)];
  final local = DateTime(part[0], part[1], part[2], part[3], part[4]);
  return Speech.t.adminSetupDateTime(
    adminDateText(local),
    adminClockText(local),
  );
}

/// Minutes after midnight for "HH:MM", or null when it is not a valid time.
int? adminParseClock(String text) {
  final match = RegExp(r'^([01]?\d|2[0-3]):([0-5]\d)$').firstMatch(text.trim());
  if (match == null) return null;
  return int.parse(match.group(1)!) * 60 + int.parse(match.group(2)!);
}

/// Normalises valid input such as "9:05" to "09:05".
String adminNormalizeClock(String text) {
  final minutes = adminParseClock(text)!;
  return '${(minutes ~/ 60).toString().padLeft(2, '0')}:'
      '${(minutes % 60).toString().padLeft(2, '0')}';
}

String adminRoleName(Object? role) => switch (role) {
  'student' => Speech.t.adminSetupRoleStudent,
  'teacher' => Speech.t.adminSetupRoleTeacher,
  _ => '${role ?? ''}',
};

Future<bool> adminConfirm(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  String? cancelLabel,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: Text(cancelLabel ?? Speech.t.adminSetupCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}

/// Information box; the icon is decorative, the text carries the meaning.
class AdminNote extends StatelessWidget {
  const AdminNote(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: UIUtils.cardColor,
      border: Border.all(color: UIUtils.cardBorderColor),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExcludeSemantics(
          child: Icon(Icons.info_outline, color: UIUtils.textColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: UIUtils.textColor, fontSize: 16),
          ),
        ),
      ],
    ),
  );
}

/// Error message announced to screen readers, marked with an icon and bold
/// text so it is not conveyed by colour alone.
class AdminErrorText extends StatelessWidget {
  const AdminErrorText(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExcludeSemantics(
          child: Icon(Icons.error_outline, color: UIUtils.errorColor),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: UIUtils.errorColor,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );
}

class AdminHeading extends StatelessWidget {
  const AdminHeading(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 16, bottom: 8),
    child: Semantics(
      header: true,
      child: Text(text, style: Theme.of(context).textTheme.titleLarge),
    ),
  );
}

/// A labelled group of choice chips; the selected chip shows a check mark,
/// so the choice is not shown by colour alone.
class AdminChoiceChips<T> extends StatelessWidget {
  const AdminChoiceChips({
    super.key,
    required this.heading,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final String heading;
  final List<(T, String)> options;
  final T selected;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        heading,
        style: TextStyle(
          color: UIUtils.textColor,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 4),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final option in options)
            ChoiceChip(
              showCheckmark: true,
              label: Text(option.$2),
              selected: option.$1 == selected,
              onSelected: (_) => onSelected(option.$1),
            ),
        ],
      ),
    ],
  );
}

/// Scrollable body of a section: tools, then loading, error, empty or items.
class AdminSectionBody extends StatelessWidget {
  const AdminSectionBody({
    super.key,
    required this.loading,
    required this.error,
    required this.onRetry,
    required this.header,
    required this.items,
    required this.emptyText,
  });

  final bool loading;
  final String? error;
  final VoidCallback onRetry;
  final List<Widget> header;
  final List<Widget> items;
  final String emptyText;

  @override
  Widget build(BuildContext context) => ListView(
    padding: UIUtils.paddingAll(context, 16),
    children: [
      ...header,
      const SizedBox(height: 12),
      if (loading)
        Semantics(
          label: Speech.t.adminSetupLoading,
          child: const LinearProgressIndicator(),
        )
      else if (error != null) ...[
        AdminErrorText(error!),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: Text(Speech.t.adminSetupRetry),
          ),
        ),
      ] else if (items.isEmpty)
        Text(
          emptyText,
          style: TextStyle(color: UIUtils.textColor, fontSize: 16),
        )
      else
        ...items,
    ],
  );
}

/// A bordered card listing an item's facts, with its action buttons below.
class AdminItemCard extends StatelessWidget {
  const AdminItemCard({
    super.key,
    required this.title,
    this.status,
    this.lines = const [],
    this.actions = const [],
  });

  final String title;

  /// Short visible state such as "Deactivated", always shown as text.
  final String? status;
  final List<String> lines;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 12),
    shape: RoundedRectangleBorder(
      side: BorderSide(color: UIUtils.cardBorderColor),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MergeSemantics(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (status != null)
                  Text(
                    status!,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                for (final line in lines)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(line),
                  ),
              ],
            ),
          ),
          if (actions.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: actions),
          ],
        ],
      ),
    ),
  );
}

/// A button with short visible text and a fuller spoken label that names
/// the item it acts on, e.g. "Remove" / "Remove Asha from Class 5 phone".
class AdminActionButton extends StatelessWidget {
  const AdminActionButton({
    super.key,
    required this.label,
    required this.semanticLabel,
    required this.onPressed,
    this.icon,
    this.filled = false,
  });

  final String label;
  final String semanticLabel;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final text = Text(label);
    final child = Semantics(
      label: semanticLabel,
      excludeSemantics: true,
      child: text,
    );
    if (filled) {
      return icon == null
          ? FilledButton(onPressed: onPressed, child: child)
          : FilledButton.icon(
              onPressed: onPressed,
              icon: Icon(icon),
              label: child,
            );
    }
    return icon == null
        ? OutlinedButton(onPressed: onPressed, child: child)
        : OutlinedButton.icon(
            onPressed: onPressed,
            icon: Icon(icon),
            label: child,
          );
  }
}

/// Picks an optional date; shows the chosen date as text with a Clear button.
class AdminDateField extends StatelessWidget {
  const AdminDateField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.allowClear = true,
    this.selectableDay,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;
  final bool allowClear;
  final bool Function(DateTime)? selectableDay;

  Future<void> _pick(BuildContext context) async {
    final now = DateTime.now();
    final first = DateTime(now.year - 2);
    final last = DateTime(now.year + 3, 12, 31);
    var initial = value ?? DateTime(now.year, now.month, now.day);
    if (initial.isBefore(first)) initial = first;
    if (initial.isAfter(last)) initial = last;
    final allowed = selectableDay;
    if (allowed != null && !allowed(initial)) {
      DateTime? found;
      for (
        var day = initial;
        found == null && !day.isAfter(last);
        day = DateTime(day.year, day.month, day.day + 1)
      ) {
        if (allowed(day)) found = day;
      }
      for (
        var day = initial;
        found == null && !day.isBefore(first);
        day = DateTime(day.year, day.month, day.day - 1)
      ) {
        if (allowed(day)) found = day;
      }
      if (found == null) return;
      initial = found;
    }
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
      helpText: label,
      selectableDayPredicate: selectableDay,
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final text = value == null
        ? Speech.t.adminSetupNoDate
        : adminDateText(value!);
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      runSpacing: 4,
      children: [
        OutlinedButton.icon(
          onPressed: () => _pick(context),
          icon: const Icon(Icons.calendar_today),
          label: Text(Speech.t.adminSetupDateValue(label, text)),
        ),
        if (allowClear && value != null)
          TextButton(
            onPressed: () => onChanged(null),
            child: Text(Speech.t.adminSetupClearDate(label)),
          ),
      ],
    );
  }
}

/// Standard form dialog: scrollable content, inline error, Cancel and Save.
class AdminFormDialog extends StatelessWidget {
  const AdminFormDialog({
    super.key,
    required this.title,
    required this.children,
    required this.onSave,
    this.error,
    this.busy = false,
    this.saveLabel,
  });

  final String title;
  final List<Widget> children;
  final VoidCallback onSave;
  final String? error;
  final bool busy;
  final String? saveLabel;

  @override
  Widget build(BuildContext context) => AlertDialog(
    scrollable: true,
    insetPadding: const EdgeInsets.all(12),
    title: Text(title),
    content: SizedBox(
      width: 520,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...children,
          if (error != null) ...[
            const SizedBox(height: 12),
            AdminErrorText(error!),
          ],
          if (busy) ...[
            const SizedBox(height: 12),
            Semantics(
              label: Speech.t.adminSetupSaving,
              child: const LinearProgressIndicator(),
            ),
          ],
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: busy ? null : () => Navigator.pop(context),
        child: Text(Speech.t.adminSetupCancel),
      ),
      FilledButton(
        onPressed: busy ? null : onSave,
        child: Text(saveLabel ?? Speech.t.adminSetupSave),
      ),
    ],
  );
}

/// Dropdown whose items are (value, label) pairs. Rebuilds its field when
/// the options change so an outside change of [value] is always shown.
class AdminDropdown<T> extends StatelessWidget {
  const AdminDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.helperText,
  });

  final String label;
  final T? value;
  final List<(T, String)> options;
  final ValueChanged<T?>? onChanged;
  final String? helperText;

  @override
  Widget build(BuildContext context) {
    final current = options.any((option) => option.$1 == value) ? value : null;
    return DropdownButtonFormField<T>(
      key: ValueKey(
        '$label|$current|${options.map((option) => option.$1).join(',')}',
      ),
      initialValue: current,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
        helperMaxLines: 4,
      ),
      items: [
        for (final option in options)
          DropdownMenuItem<T>(
            value: option.$1,
            child: Text(option.$2, overflow: TextOverflow.ellipsis),
          ),
      ],
      onChanged: onChanged,
    );
  }
}
