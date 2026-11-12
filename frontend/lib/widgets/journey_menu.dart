import 'dart:async';

import 'package:flutter/material.dart';

import '../services/feedback_cues.dart';
import '../services/tts_service.dart';
import '../utils/ui_utils.dart';
import 'key_instruction_wrapper.dart';

class JourneyChoice {
  const JourneyChoice(
    this.label,
    this.onSelected, {
    this.enabled = true,
    this.unavailableReason,
  });
  final String label;
  final VoidCallback onSelected;
  final bool enabled;

  /// Spoken when the choice is pressed while unavailable.
  final String? unavailableReason;
}

/// One small, single-purpose keypad screen used by every learning-journey
/// page: at most five numbered choices, 8 reads details, 0 goes back,
/// star repeats help and hash stops speech. Each choice is also a D-pad
/// focus target with the same spoken label.
class JourneyMenu extends StatefulWidget {
  JourneyMenu({
    super.key,
    required this.title,
    required this.choices,
    this.introduction,
    this.status,
    this.issue,
    this.busy = false,
    this.onBack,
    this.details,
    this.autoPlay = true,
    this.backLabel = 'Back',
  }) {
    if (choices.length > 5) {
      throw ArgumentError('A journey menu supports at most five choices.');
    }
  }

  final String title;
  final List<JourneyChoice> choices;

  /// Spoken with the screen help and shown under the title.
  final String? introduction;

  /// Latest result, shown in a live region (speak it separately).
  final String? status;
  final String? issue;
  final bool busy;
  final VoidCallback? onBack;

  /// Text read by key 8.
  final String? details;
  final bool autoPlay;
  final String backLabel;

  @override
  State<JourneyMenu> createState() => _JourneyMenuState();
}

class _JourneyMenuState extends State<JourneyMenu> {
  final _nodes = List.generate(
    5,
    (index) => FocusNode(debugLabel: 'journey-choice-${index + 1}'),
  );
  final _readNode = FocusNode(debugLabel: 'journey-read');
  final _backNode = FocusNode(debugLabel: 'journey-back');

  /// True until the screen's first load finishes; then its choices, which
  /// were not known when the screen opened, are read once.
  late bool _awaitingFirstLoad = widget.busy;

  @override
  void didUpdateWidget(covariant JourneyMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.busy && !oldWidget.busy) {
      unawaited(FeedbackCues.play(Cue.loading));
    }
    if (_awaitingFirstLoad && !widget.busy && widget.autoPlay) {
      _awaitingFirstLoad = false;
      final route = ModalRoute.of(context);
      if (route == null || route.isCurrent) {
        unawaited(TtsService.speak(_readyText()));
      }
    }
  }

  /// "Ready. 2 new, 1 in progress. Press 1 for ..., press 0 for Back."
  String _readyText() => [
    'Ready.',
    ?widget.issue,
    ?widget.status,
    for (var index = 0; index < widget.choices.length; index++)
      'Press ${index + 1} for ${_label(index)}.',
    if (widget.details != null || widget.introduction != null)
      'Press 8 to read details again.',
    'Press 0 for ${widget.backLabel}. Press star for help.',
  ].join(' ');

  @override
  void dispose() {
    for (final node in [..._nodes, _readNode, _backNode]) {
      node.dispose();
    }
    super.dispose();
  }

  void _back() {
    // 0 always leaves, even while loading, so nobody is ever stuck here.
    if (widget.onBack != null) {
      widget.onBack!();
    } else {
      unawaited(Navigator.of(context).maybePop());
    }
  }

  void _select(int index) {
    if (index >= widget.choices.length) {
      unawaited(TtsService.speak('Nothing is assigned to ${index + 1}.'));
      return;
    }
    final choice = widget.choices[index];
    if (widget.busy) {
      unawaited(
        TtsService.speak('Please wait. Still working. Press 0 to go back.'),
      );
    } else if (choice.enabled) {
      choice.onSelected();
    } else {
      unawaited(
        TtsService.speak(
          '${choice.label} is not available. ${choice.unavailableReason ?? ''}',
        ),
      );
    }
  }

  void _read() => unawaited(
    TtsService.speak(
      [
        widget.issue,
        widget.status,
        widget.details ?? widget.introduction,
      ].whereType<String>().join(' '),
    ),
  );

  String _label(int index) {
    final choice = widget.choices[index];
    return '${choice.label}${choice.enabled ? '' : ', unavailable'}';
  }

  @override
  Widget build(BuildContext context) {
    final hasDetails = widget.details != null || widget.introduction != null;
    return PopScope(
      canPop: widget.onBack == null,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: KeypadInstructionWrapper(
        interactionPolicy: KeypadInteractionPolicy.numbered,
        screenName: widget.title,
        introduction: widget.introduction,
        stateSummary: () => [
          if (widget.busy) 'Working, please wait.',
          widget.issue,
          widget.status,
        ].whereType<String>().join(' '),
        autoPlay: widget.autoPlay,
        labels: {
          for (var index = 0; index < widget.choices.length; index++)
            index + 1: _label(index),
          if (hasDetails) 8: 'Read details again',
        },
        actions: {
          0: _back,
          for (var index = 0; index < 5; index++)
            index + 1: () => _select(index),
          if (hasDetails) 8: _read,
        },
        focusTargets: [
          for (var index = 0; index < widget.choices.length; index++)
            KeypadFocusTarget(
              node: _nodes[index],
              label: '${index + 1}. ${_label(index)}',
              onActivate: () => _select(index),
            ),
          if (hasDetails)
            KeypadFocusTarget(
              node: _readNode,
              label: '8. Read details again',
              onActivate: _read,
            ),
          KeypadFocusTarget(
            node: _backNode,
            label: '0. ${widget.backLabel}',
            onActivate: _back,
          ),
        ],
        child: Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      widget.title,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  if (widget.introduction != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(widget.introduction!),
                    ),
                  if (widget.busy)
                    Semantics(
                      label: 'Working. Please wait',
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: LinearProgressIndicator(),
                      ),
                    ),
                  if (widget.issue != null)
                    Semantics(
                      liveRegion: true,
                      child: Text(
                        widget.issue!,
                        style: TextStyle(
                          color: UIUtils.errorColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  if (widget.status != null)
                    Semantics(liveRegion: true, child: Text(widget.status!)),
                  for (var index = 0; index < widget.choices.length; index++)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: ElevatedButton(
                        focusNode: _nodes[index],
                        onPressed: () => _select(index),
                        child: Text(
                          '${index + 1}: ${widget.choices[index].label}'
                          '${widget.choices[index].enabled ? '' : ' (unavailable)'}',
                        ),
                      ),
                    ),
                  if (hasDetails)
                    TextButton(
                      focusNode: _readNode,
                      onPressed: _read,
                      child: const Text('8: Read details again'),
                    ),
                  TextButton(
                    focusNode: _backNode,
                    onPressed: _back,
                    child: Text('0: ${widget.backLabel}'),
                  ),
                  const Text('*: Help. #: Stop app speech.'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
