import 'dart:async';

import 'package:flutter/material.dart';

import '../l10n/speech.dart';
import '../services/tts_service.dart';
import '../utils/ui_utils.dart';
import 'key_instruction_wrapper.dart';

/// A keypad replacement for drop-downs: one focus stop whose value changes
/// with D-pad left and right (and wraps), announcing "Subject: Science, 2 of
/// 4". Touch users tap the arrows. Register [target] in the screen's
/// KeypadInstructionWrapper focus targets.
class KeypadChoiceField<T> extends StatelessWidget {
  const KeypadChoiceField({
    super.key,
    required this.label,
    required this.values,
    required this.value,
    required this.nameOf,
    required this.onChanged,
    required this.focusNode,
    this.enabled = true,
  });

  final String label;
  final List<T> values;
  final T value;
  final String Function(T) nameOf;
  final ValueChanged<T> onChanged;
  final FocusNode focusNode;
  final bool enabled;

  int get _index {
    final index = values.indexOf(value);
    return index < 0 ? 0 : index;
  }

  /// "Subject: Science, 2 of 4".
  static String describe<T>(
    String label,
    List<T> values,
    T value,
    String Function(T) nameOf,
  ) {
    final index = values.indexOf(value);
    return values.length > 1 && index >= 0
        ? Speech.t.uiChoiceValuePosition(
            label,
            nameOf(value),
            '${index + 1}',
            '${values.length}',
          )
        : Speech.t.uiChoiceValue(label, nameOf(value));
  }

  /// Moves [delta] steps with wrap-around, then announces the new value.
  static void step<T>({
    required String label,
    required List<T> values,
    required T value,
    required String Function(T) nameOf,
    required ValueChanged<T> onChanged,
    required int delta,
  }) {
    if (values.isEmpty) return;
    final current = values.indexOf(value);
    final next = values[((current < 0 ? 0 : current) + delta) % values.length];
    onChanged(next);
    unawaited(
      TtsService.speak(
        describe(label, values, next, nameOf),
        priority: SpeechPriority.navigation,
      ),
    );
  }

  KeypadFocusTarget get target => KeypadFocusTarget(
    node: focusNode,
    label: Speech.t.uiChoiceChange(describe(label, values, value, nameOf)),
    onActivate: () => _move(1),
    onDecrease: () => _move(-1),
    onIncrease: () => _move(1),
    isEnabled: () => enabled && values.isNotEmpty,
  );

  void _move(int delta) => step(
    label: label,
    values: values,
    value: value,
    nameOf: nameOf,
    onChanged: onChanged,
    delta: delta,
  );

  @override
  Widget build(BuildContext context) {
    final text = Speech.t.uiChoiceValue(
      label,
      values.isEmpty ? Speech.t.uiNone : nameOf(values[_index]),
    );
    return Semantics(
      label: label,
      value: values.isEmpty ? Speech.t.uiNone : nameOf(values[_index]),
      increasedValue: values.length > 1
          ? nameOf(values[(_index + 1) % values.length])
          : null,
      decreasedValue: values.length > 1
          ? nameOf(values[(_index - 1 + values.length) % values.length])
          : null,
      onIncrease: enabled && values.length > 1 ? () => _move(1) : null,
      onDecrease: enabled && values.length > 1 ? () => _move(-1) : null,
      excludeSemantics: true,
      child: Focus(
        focusNode: focusNode,
        canRequestFocus: enabled,
        child: Builder(
          builder: (context) {
            final focused = Focus.of(context).hasFocus;
            return Container(
              constraints: const BoxConstraints(minHeight: 48),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: focused
                      ? UIUtils.focusRingColor
                      : UIUtils.cardBorderColor,
                  width: focused ? 3 : 2,
                ),
              ),
              child: Row(
                children: [
                  ExcludeFocus(
                    child: IconButton(
                      tooltip: Speech.t.uiPreviousOf(label),
                      onPressed: enabled ? () => _move(-1) : null,
                      icon: const Icon(Icons.chevron_left),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      text,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  ExcludeFocus(
                    child: IconButton(
                      tooltip: Speech.t.uiNextOf(label),
                      onPressed: enabled ? () => _move(1) : null,
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
