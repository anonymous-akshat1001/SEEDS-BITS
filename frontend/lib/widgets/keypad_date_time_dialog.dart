import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/speech.dart';
import '../services/tts_service.dart';
import '../utils/ui_utils.dart';
import 'key_instruction_wrapper.dart';

class KeypadDateTimeDialog extends StatefulWidget {
  const KeypadDateTimeDialog({
    super.key,
    required this.initial,
    required this.firstDate,
    required this.lastDate,
  });

  final DateTime initial;
  final DateTime firstDate;
  final DateTime lastDate;

  @override
  State<KeypadDateTimeDialog> createState() => _KeypadDateTimeDialogState();
}

class _KeypadDateTimeDialogState extends State<KeypadDateTimeDialog> {
  static List<String> get _labels {
    final t = Speech.t;
    return [t.uiYear, t.uiMonth, t.uiDay, t.uiHourRange, t.uiMinute];
  }

  static List<String> get _names {
    final t = Speech.t;
    return [t.uiYear, t.uiMonth, t.uiDay, t.uiHour, t.uiMinute];
  }

  final _navigation = KeypadNavigationController();
  final _cancel = FocusNode(debugLabel: 'date-time-cancel');
  final _save = FocusNode(debugLabel: 'date-time-save');
  late final List<TextEditingController> _fields;
  final _nodes = List.generate(
    5,
    (index) => FocusNode(debugLabel: 'date-time-field-$index'),
  );
  String? _error;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial.toLocal();
    _fields = [
      initial.year,
      initial.month,
      initial.day,
      initial.hour,
      initial.minute,
    ].map((value) => TextEditingController(text: '$value')).toList();
  }

  void _saveDateTime() {
    final values = _fields.map((field) => int.tryParse(field.text)).toList();
    if (values.any((value) => value == null)) {
      _showError(Speech.t.uiDateEnterNumbers);
      return;
    }
    final year = values[0]!;
    final month = values[1]!;
    final day = values[2]!;
    final hour = values[3]!;
    final minute = values[4]!;
    if (year < widget.firstDate.year ||
        year > widget.lastDate.year ||
        month < 1 ||
        month > 12 ||
        day < 1 ||
        day > 31) {
      _showError(
        Speech.t.uiDateChooseValid(
          _dateLabel(widget.firstDate),
          _dateLabel(widget.lastDate),
        ),
      );
      return;
    }
    final value = DateTime(year, month, day, hour, minute);
    if (value.year != year ||
        value.month != month ||
        value.day != day ||
        hour < 0 ||
        hour > 23 ||
        minute < 0 ||
        minute > 59) {
      _showError(Speech.t.uiDateInvalid);
      return;
    }
    final date = DateUtils.dateOnly(value);
    if (date.isBefore(DateUtils.dateOnly(widget.firstDate)) ||
        date.isAfter(DateUtils.dateOnly(widget.lastDate))) {
      _showError(
        Speech.t.uiDateChoose(
          _dateLabel(widget.firstDate),
          _dateLabel(widget.lastDate),
        ),
      );
      return;
    }
    Navigator.pop(context, value);
  }

  String _range(int index) {
    final t = Speech.t;
    switch (index) {
      case 0:
        return widget.firstDate.year == widget.lastDate.year
            ? '${widget.firstDate.year}'
            : t.uiRange('${widget.firstDate.year}', '${widget.lastDate.year}');
      case 1:
        return t.uiRange('1', '12');
      case 2:
        return t.uiRange('1', '31');
      case 3:
        return t.uiRange('0', '23');
      default:
        return t.uiRange('0', '59');
    }
  }

  String _fieldLabel(int index) {
    final value = _fields[index].text.trim();
    return value.isEmpty
        ? Speech.t.uiDateFieldEmpty(_names[index], _range(index))
        : Speech.t.uiDateFieldValue(_names[index], _range(index), value);
  }

  String _dateLabel(DateTime value) =>
      '${value.day}/${value.month}/${value.year}';

  void _showError(String message) {
    setState(() => _error = message);
    TtsService.speak(message, priority: SpeechPriority.critical);
  }

  @override
  void dispose() {
    for (final field in _fields) {
      field.dispose();
    }
    for (final node in _nodes) {
      node.dispose();
    }
    _cancel.dispose();
    _save.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Speech.t;
    return KeypadInstructionWrapper(
      screenName: t.uiDateScreen(
        _dateLabel(widget.firstDate),
        _dateLabel(widget.lastDate),
      ),
      labels: {0: t.uiCancel, 1: t.uiSaveDateTime},
      actions: {0: () => Navigator.pop(context), 1: _saveDateTime},
      navigationController: _navigation,
      focusTargets: [
        for (var index = 0; index < _nodes.length; index++)
          KeypadFocusTarget(
            node: _nodes[index],
            label: _fieldLabel(index),
            isTextField: true,
          ),
        KeypadFocusTarget(
          node: _cancel,
          label: t.uiCancel,
          onActivate: () => Navigator.pop(context),
        ),
        KeypadFocusTarget(
          node: _save,
          label: t.uiSaveDateTime,
          onActivate: _saveDateTime,
        ),
      ],
      child: AlertDialog(
        title: Text(Speech.t.uiSetDateTimeTitle),
        scrollable: true,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              Speech.t.uiSetDateTimeHint,
              style: TextStyle(color: UIUtils.textColor, fontSize: 16),
            ),
            for (var index = 0; index < _fields.length; index++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: TextField(
                  controller: _fields[index],
                  focusNode: _nodes[index],
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: TextStyle(color: UIUtils.textColor, fontSize: 18),
                  decoration: InputDecoration(
                    labelText: _labels[index],
                    helperText: _range(index),
                  ),
                  onTap: () => _navigation.enterTextEditing(_nodes[index]),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            if (_error != null)
              Semantics(
                liveRegion: true,
                child: Text(
                  _error!,
                  style: TextStyle(
                    color: UIUtils.errorColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            focusNode: _cancel,
            onPressed: () => Navigator.pop(context),
            child: Text(Speech.t.uiCancelKey0),
          ),
          ElevatedButton(
            focusNode: _save,
            onPressed: _saveDateTime,
            child: Text(Speech.t.uiSaveKey1),
          ),
        ],
      ),
    );
  }
}
