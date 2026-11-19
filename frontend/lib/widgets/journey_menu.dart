import 'dart:async';

import 'package:flutter/material.dart';

import '../l10n/speech.dart';
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
    this.brief,
    this.onSystemBack,
    String? backLabel,
  }) : _backLabel = backLabel {
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
  final String? _backLabel;

  /// Short arrival speech instead of every choice; star reads them all.
  final String? brief;

  /// Android Back, when it must differ from key 0 (home: Back leaves the
  /// app, 0 signs out after asking).
  final VoidCallback? onSystemBack;

  /// Label of key 0; "Back" unless the screen names it.
  String get backLabel => _backLabel ?? Speech.t.uiBack;

  /// "Press 1 for ..., press 0 for ..." for screens that speak their own
  /// arrival (the homes), so every key is still read when they open.
  static String spokenKeys(List<JourneyChoice> choices, String backLabel) {
    final t = Speech.t;
    return [
      for (var index = 0; index < choices.length; index++)
        t.uiPressFor(
          '${index + 1}',
          choices[index].enabled
              ? choices[index].label
              : t.uiLabelUnavailable(choices[index].label),
        ),
      t.journeyMenuBackHelp(backLabel),
    ].join(' ');
  }

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
  String _readyText() {
    final t = Speech.t;
    return [
      t.journeyMenuReady,
      ?widget.issue,
      ?widget.status,
      for (var index = 0; index < widget.choices.length; index++)
        t.uiPressFor('${index + 1}', _label(index)),
      if (widget.details != null || widget.introduction != null)
        t.journeyMenuReadDetailsHelp,
      t.journeyMenuBackHelp(widget.backLabel),
    ].join(' ');
  }

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
      unawaited(
        TtsService.speak(Speech.t.journeyMenuNothingAssigned('${index + 1}')),
      );
      return;
    }
    final choice = widget.choices[index];
    if (widget.busy) {
      unawaited(TtsService.speak(Speech.t.journeyMenuPleaseWait));
    } else if (choice.enabled) {
      choice.onSelected();
    } else {
      unawaited(
        TtsService.speak(
          Speech.t.commonUnavailableBecause(
            choice.label,
            choice.unavailableReason ?? '',
          ),
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
    return choice.enabled
        ? choice.label
        : Speech.t.uiLabelUnavailable(choice.label);
  }

  @override
  Widget build(BuildContext context) {
    final t = Speech.t;
    final hasDetails = widget.details != null || widget.introduction != null;
    return PopScope(
      canPop: widget.onBack == null && widget.onSystemBack == null,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) (widget.onSystemBack ?? _back)();
      },
      child: KeypadInstructionWrapper(
        interactionPolicy: KeypadInteractionPolicy.numbered,
        screenName: widget.title,
        introduction: widget.introduction,
        brief: widget.brief,
        stateSummary: () => [
          if (widget.busy) t.journeyMenuWorking,
          widget.issue,
          widget.status,
        ].whereType<String>().join(' '),
        autoPlay: widget.autoPlay,
        labels: {
          for (var index = 0; index < widget.choices.length; index++)
            index + 1: _label(index),
          if (hasDetails) 8: t.journeyMenuReadDetails,
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
              label: '8. ${t.journeyMenuReadDetails}',
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
                      label: Speech.t.journeyMenuWorking,
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
                          widget.choices[index].enabled
                              ? '${index + 1}: ${widget.choices[index].label}'
                              : Speech.t.uiKeyedLabelUnavailable(
                                  '${index + 1}',
                                  widget.choices[index].label,
                                ),
                        ),
                      ),
                    ),
                  if (hasDetails)
                    TextButton(
                      focusNode: _readNode,
                      onPressed: _read,
                      child: Text(Speech.t.journeyMenuReadDetailsKey8),
                    ),
                  TextButton(
                    focusNode: _backNode,
                    onPressed: _back,
                    child: Text('0: ${widget.backLabel}'),
                  ),
                  Text(Speech.t.uiKeypadFooter),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
