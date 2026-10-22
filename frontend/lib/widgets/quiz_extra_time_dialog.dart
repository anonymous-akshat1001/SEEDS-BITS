import 'package:flutter/material.dart';
import '../services/tts_service.dart';
import 'key_instruction_wrapper.dart';

class QuizExtraTimeDialog extends StatefulWidget {
  const QuizExtraTimeDialog({
    super.key,
    required this.studentName,
    required this.initialMinutes,
  });
  final String studentName;
  final int initialMinutes;
  @override
  State<QuizExtraTimeDialog> createState() => _QuizExtraTimeDialogState();
}

class _QuizExtraTimeDialogState extends State<QuizExtraTimeDialog> {
  late final _text = TextEditingController(text: '${widget.initialMinutes}');
  final _field = FocusNode(debugLabel: 'quiz-extra-minutes');
  final _save = FocusNode(debugLabel: 'quiz-extra-save');
  final _cancel = FocusNode(debugLabel: 'quiz-extra-cancel');
  String? _error;
  void save() {
    final minutes = int.tryParse(_text.text.trim());
    if (minutes == null || minutes < 0 || minutes > 2147483647) {
      setState(
        () => _error =
            'Enter a whole number of minutes, zero or more, within the server integer range.',
      );
      TtsService.speak(_error!);
      return;
    }
    Navigator.pop(context, minutes);
  }

  @override
  void dispose() {
    _text.dispose();
    _field.dispose();
    _save.dispose();
    _cancel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => KeypadInstructionWrapper(
    screenName:
        'Extra time for ${widget.studentName}. Future attempts only; active attempt deadlines stay fixed. Quiz closing time still applies. Zero removes extra time.',
    actions: const {},
    onHashKey: () => Navigator.pop(context),
    focusTargets: [
      KeypadFocusTarget(
        node: _field,
        label: 'Extra minutes. Press OK to edit',
        isTextField: true,
      ),
      KeypadFocusTarget(
        node: _save,
        label: 'Save extra time for future attempts',
        onActivate: save,
      ),
      KeypadFocusTarget(
        node: _cancel,
        label: 'Cancel without changing extra time',
        onActivate: () => Navigator.pop(context),
      ),
    ],
    child: AlertDialog(
      scrollable: true,
      title: Text('Extra time: ${widget.studentName}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Future attempts only. Existing deadlines do not change. Quiz closing time still applies; extend availability separately if needed. Zero removes extra minutes.',
          ),
          TextField(
            focusNode: _field,
            controller: _text,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Extra minutes'),
          ),
          if (_error != null) Text(_error!),
          TextButton(
            focusNode: _save,
            onPressed: save,
            child: const Text('Save future extra time'),
          ),
          TextButton(
            focusNode: _cancel,
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    ),
  );
}
