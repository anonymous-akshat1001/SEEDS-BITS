import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  static const _labels = ['Year', 'Month', 'Day', 'Hour (0 to 23)', 'Minute'];
  static const _names = ['Year', 'Month', 'Day', 'Hour', 'Minute'];
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
      _showError('Enter a number in every date and time field.');
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
        'Choose a valid date from ${_dateLabel(widget.firstDate)} '
        'to ${_dateLabel(widget.lastDate)}.',
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
      _showError(
        'Enter a valid date, an hour from 0 to 23, and a minute from 0 to 59.',
      );
      return;
    }
    final date = DateUtils.dateOnly(value);
    if (date.isBefore(DateUtils.dateOnly(widget.firstDate)) ||
        date.isAfter(DateUtils.dateOnly(widget.lastDate))) {
      _showError(
        'Choose a date from ${_dateLabel(widget.firstDate)} '
        'to ${_dateLabel(widget.lastDate)}.',
      );
      return;
    }
    Navigator.pop(context, value);
  }

  String _range(int index) {
    switch (index) {
      case 0:
        return widget.firstDate.year == widget.lastDate.year
            ? '${widget.firstDate.year}'
            : '${widget.firstDate.year} to ${widget.lastDate.year}';
      case 1:
        return '1 to 12';
      case 2:
        return '1 to 31';
      case 3:
        return '0 to 23';
      default:
        return '0 to 59';
    }
  }

  String _fieldLabel(int index) {
    final value = _fields[index].text.trim();
    return '${_names[index]}, ${_range(index)}, '
        '${value.isEmpty ? 'currently empty' : 'currently $value'}';
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
    return KeypadInstructionWrapper(
      screenName:
          'Set date and time in the phone\'s local time. '
          'Choose a date from ${_dateLabel(widget.firstDate)} '
          'to ${_dateLabel(widget.lastDate)}.',
      labels: const {0: 'Cancel', 1: 'Save date and time'},
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
          label: 'Cancel',
          onActivate: () => Navigator.pop(context),
        ),
        KeypadFocusTarget(
          node: _save,
          label: 'Save date and time',
          onActivate: _saveDateTime,
        ),
      ],
      child: AlertDialog(
        title: const Text('Set date and time'),
        scrollable: true,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Use local time. Press OK to edit each number.',
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
            child: const Text('0: Cancel'),
          ),
          ElevatedButton(
            focusNode: _save,
            onPressed: _saveDateTime,
            child: const Text('1: Save'),
          ),
        ],
      ),
    );
  }
}
