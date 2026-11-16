import 'package:flutter/material.dart';
import '../announcers/quiz_text.dart';
import '../l10n/speech.dart';
import '../services/tts_service.dart';
import '../utils/ui_utils.dart';
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
      setState(() => _error = QuizText.extraInvalid);
      TtsService.speak(
        '${_error!} ${QuizText.extraCorrect}',
        priority: SpeechPriority.critical,
      );
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
    screenName: QuizText.extraScreen(widget.studentName),
    stateSummary: () => QuizText.extraField(_text.text.trim()),
    actions: const {},
    focusTargets: [
      KeypadFocusTarget(
        node: _field,
        label: QuizText.extraField(_text.text.trim()),
        isTextField: true,
      ),
      KeypadFocusTarget(
        node: _save,
        label: QuizText.extraSave,
        onActivate: save,
      ),
      KeypadFocusTarget(
        node: _cancel,
        label: QuizText.extraCancel,
        onActivate: () => Navigator.pop(context),
      ),
    ],
    child: AlertDialog(
      scrollable: true,
      title: Text(Speech.t.quizExtraTitle(widget.studentName)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            Speech.t.quizExtraInfo,
            style: TextStyle(color: UIUtils.textColor, fontSize: 16),
          ),
          TextField(
            focusNode: _field,
            controller: _text,
            keyboardType: TextInputType.number,
            style: TextStyle(color: UIUtils.textColor, fontSize: 18),
            decoration: InputDecoration(
              labelText: Speech.t.quizExtraMinutesField,
            ),
            onChanged: (_) => setState(() {}),
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
          TextButton(
            focusNode: _save,
            onPressed: save,
            child: Text(Speech.t.quizExtraSaveButton),
          ),
          TextButton(
            focusNode: _cancel,
            onPressed: () => Navigator.pop(context),
            child: Text(Speech.t.uiCancelKey0),
          ),
        ],
      ),
    ),
  );
}
