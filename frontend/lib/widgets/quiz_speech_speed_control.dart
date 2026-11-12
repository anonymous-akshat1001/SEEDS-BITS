import 'package:flutter/material.dart';

import '../announcers/quiz_text.dart';
import '../services/quiz_speech_speed.dart';
import '../services/tts_service.dart';
import '../utils/ui_utils.dart';

/// One keypad stop showing the quiz speech speed. D-pad left/right (handled
/// by the screen's keypad targets), keys 7 and 9, TalkBack's adjust gestures
/// and the two touch buttons all change it.
class QuizSpeechSpeedControl extends StatelessWidget {
  const QuizSpeechSpeedControl({
    super.key,
    required this.focusNode,
    required this.speed,
    required this.onChange,
  });

  final FocusNode focusNode;
  final QuizSpeechSpeed speed;
  final Future<void> Function(int steps) onChange;

  @override
  Widget build(BuildContext context) {
    final rate = speed.rate;
    final canSlow = rate > TtsService.minSpeechRate;
    final canSpeed = rate < TtsService.maxSpeechRate;
    String describe(double value) =>
        TtsService.describeSpeed(TtsService.clampSpeechRate(value));

    Widget button(String text, IconData icon, bool enabled, int steps) =>
        ExcludeFocus(
          child: OutlinedButton.icon(
            onPressed: enabled ? () => onChange(steps) : null,
            icon: Icon(icon),
            label: Text(text),
          ),
        );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Focus(
        focusNode: focusNode,
        child: Semantics(
          container: true,
          label: QuizText.speedHeading,
          value: speed.description,
          increasedValue: canSpeed
              ? describe(rate + TtsService.speechRateStep)
              : null,
          decreasedValue: canSlow
              ? describe(rate - TtsService.speechRateStep)
              : null,
          onIncrease: canSpeed ? () => onChange(1) : null,
          onDecrease: canSlow ? () => onChange(-1) : null,
          excludeSemantics: true,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: UIUtils.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: UIUtils.cardBorderColor, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Quiz speech speed: '
                  '${TtsService.formatSpeedMultiple(rate)}×',
                  style: TextStyle(
                    color: UIUtils.textColor,
                    fontSize: UIUtils.fontSize(context, 16),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    button('7: Slower', Icons.remove, canSlow, -1),
                    button('9: Faster', Icons.add, canSpeed, 1),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
