import 'package:flutter/material.dart';
import '../services/message_center.dart';

import '../announcers/library_text.dart';
import '../l10n/speech.dart';
import '../services/learning_playback_controller.dart';
import '../services/learning_progress_store.dart';
import '../services/tts_service.dart';
import '../screens/private_notes_screen.dart';
import '../utils/keypad_actions.dart';
import '../utils/spoken_format.dart';
import '../utils/ui_utils.dart';
import 'key_instruction_wrapper.dart';
import 'keypad_confirmation_dialog.dart';

String learningTime(Duration position) {
  final minutes = position.inMinutes;
  final seconds = position.inSeconds.remainder(60);
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}

/// Spoken form of a lesson time: "3 minutes 20 seconds".
String learningSpokenTime(Duration time) => SpokenFormat.duration(time);

/// "3 minutes 20 seconds of 12 minutes" (or only the position when the
/// length is not known yet).
String learningSpokenPosition(Duration position, Duration? duration) =>
    LibraryText.position(position, duration);

/// "1.5" for 1.5x, "1" for 1x.
String learningSpeedNumber(double speed) => LibraryText.speedNumber(speed);

/// Announcement used whenever a lesson starts or resumes.
String learningPlayingAnnouncement(
  String title,
  Duration position,
  Duration? duration,
  double speed,
) => LibraryText.playing(title, position, duration, speed);

/// Spoken reminder of the shared audio player keys.
String get learningPlayerKeyHelp => LibraryText.playerKeyHelp(
  rewind: playerRewindKey,
  playPause: playerPlayPauseKey,
  forward: playerForwardKey,
  slower: playerSlowerKey,
  faster: playerFasterKey,
);

/// Lesson position bar. It is a keypad focus stop (not a touch-only slider):
/// left and right move 10 seconds through the screen's [KeypadFocusTarget]
/// `onDecrease`/`onIncrease`, the screen reader's increase and decrease
/// gestures do the same, and a tap moves to that point.
class PlayerSeekBar extends StatelessWidget {
  const PlayerSeekBar({
    super.key,
    required this.position,
    required this.duration,
    required this.onSeek,
    this.focusNode,
  });

  final Duration position;
  final Duration? duration;
  final ValueChanged<Duration> onSeek;
  final FocusNode? focusNode;

  /// Seconds moved by one left or right press.
  static const step = 10;

  /// [position] moved by [seconds], kept inside the lesson.
  static Duration offset(Duration position, Duration? duration, int seconds) {
    final next = position + Duration(seconds: seconds);
    if (next.isNegative) return Duration.zero;
    return duration != null && next > duration ? duration : next;
  }

  @override
  Widget build(BuildContext context) {
    final total = duration;
    final enabled = total != null && total > Duration.zero;
    final value = enabled
        ? (position.inMilliseconds / total.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;
    return Semantics(
      slider: true,
      label: Speech.t.learningLessonPositionLabel,
      value: LibraryText.position(position, total),
      increasedValue: enabled
          ? LibraryText.position(offset(position, total, step), total)
          : null,
      decreasedValue: enabled
          ? LibraryText.position(offset(position, total, -step), total)
          : null,
      onIncrease: enabled ? () => onSeek(offset(position, total, step)) : null,
      onDecrease: enabled ? () => onSeek(offset(position, total, -step)) : null,
      excludeSemantics: true,
      child: Focus(
        focusNode: focusNode,
        canRequestFocus: enabled,
        child: Builder(
          builder: (context) {
            final focused = Focus.of(context).hasFocus;
            return LayoutBuilder(
              builder: (context, constraints) => GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapUp: enabled && constraints.maxWidth > 0
                    ? (details) => onSeek(
                        Duration(
                          milliseconds:
                              (details.localPosition.dx /
                                      constraints.maxWidth *
                                      total.inMilliseconds)
                                  .clamp(0, total.inMilliseconds)
                                  .round(),
                        ),
                      )
                    : null,
                child: Container(
                  constraints: const BoxConstraints(minHeight: 48),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: focused
                          ? UIUtils.accentColor
                          : UIUtils.cardBorderColor,
                      width: focused ? 3 : 1.5,
                    ),
                  ),
                  child: LinearProgressIndicator(
                    value: value,
                    minHeight: 8,
                    color: UIUtils.accentColor,
                    backgroundColor: UIUtils.cardBorderColor,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class LearningControls extends StatelessWidget {
  const LearningControls({
    super.key,
    required this.controller,
    required this.nodeFor,
    this.showSpeedControls = true,
    this.showSeekControls = true,
    this.pauseForNotes,
  });

  final LearningPlaybackController controller;
  final FocusNode Function(String) nodeFor;
  final bool showSpeedControls;
  final bool showSeekControls;
  final Future<void> Function()? pauseForNotes;

  Duration _offsetPosition(int seconds) {
    final next = controller.position + Duration(seconds: seconds);
    final end = controller.duration;
    if (next.isNegative) return Duration.zero;
    return end != null && next > end ? end : next;
  }

  static Future<bool> prepare(
    BuildContext context,
    LearningPlaybackController controller,
    int audioId,
    String title,
  ) async {
    try {
      final prepared = await controller.prepare(audioId, title);
      return prepared && context.mounted;
    } on LearningStorageException catch (error) {
      if (!context.mounted) return false;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (_) => KeypadConfirmationDialog(
          title: Speech.t.learningSavedProgressUnavailableTitle,
          message:
              '${error.message} ${Speech.t.learningListenWithoutSavedPrompt}',
          cancelLabel: Speech.t.uiCancel,
          confirmLabel: Speech.t.learningListenFromBeginning,
          cancelKey: 0,
          confirmKey: 1,
        ),
      );
      if (confirmed != true || !context.mounted) return false;
      final prepared = await controller.prepare(
        audioId,
        title,
        withoutSavedProgress: true,
      );
      return prepared && context.mounted;
    }
  }

  String get _status {
    final t = Speech.t;
    final lesson = controller.lesson;
    return '${lesson?.title ?? t.learningRecordedLesson}. '
        '${t.learningStatusPosition(learningSpokenPosition(controller.position, controller.duration))} '
        '${t.learningSpeedTimes(learningSpeedNumber(controller.speed))} '
        '${t.learningStatusBookmarks(lesson?.bookmarks.length ?? 0)} '
        '${t.learningStatusRepeat(SpokenFormat.onOff(controller.repeatEnabled))} '
        '${t.learningStatusSaving(SpokenFormat.onOff(controller.canSave))} '
        '${controller.issue ?? ''} $learningPlayerKeyHelp';
  }

  /// Moves the lesson by [seconds] (negative goes back) and speaks the new
  /// position. Used by the 4 and 6 player keys and the matching buttons.
  Future<void> seekBy(BuildContext context, int seconds) async {
    if (!controller.ready) {
      TtsService.speak(Speech.t.learningNoLessonLoaded);
      return;
    }
    await _run(
      context,
      () => controller.moveTo(_offsetPosition(seconds)),
      announcement: () => learningSpokenPosition(
        controller.position,
        controller.duration,
      ),
    );
  }

  /// Changes speed by [delta] (7 slower, 9 faster) and speaks the result.
  Future<void> changeSpeedBy(BuildContext context, double delta) async {
    if (!controller.ready) {
      TtsService.speak(Speech.t.learningNoLessonLoaded);
      return;
    }
    final next = (controller.speed + delta).clamp(0.25, 3.0).toDouble();
    if (next == controller.speed) {
      TtsService.speak(
        delta < 0
            ? Speech.t.learningSlowestSpeed
            : Speech.t.learningFastestSpeed,
      );
      return;
    }
    await _run(
      context,
      () => controller.changeSpeed(next),
      announcement: () =>
          Speech.t.learningSpeedTimes(learningSpeedNumber(controller.speed)),
    );
  }

  /// Player keys shared by every lesson player: 4 back 10 s, 6 forward 10 s,
  /// 7 slower, 9 faster. The screen supplies 5 (play or pause).
  Map<int, VoidCallback> playerKeyActions(BuildContext context) => {
    playerRewindKey: () => seekBy(context, -10),
    playerForwardKey: () => seekBy(context, 10),
    playerSlowerKey: () => changeSpeedBy(context, -0.25),
    playerFasterKey: () => changeSpeedBy(context, 0.25),
  };

  static void _error(BuildContext context, String message) {
    if (!context.mounted) return;
    MessageCenter.error(message);
  }

  Future<bool> _run(
    BuildContext context,
    Future<void> Function() action, {
    String Function()? announcement,
  }) async {
    final revision = controller.revision;
    try {
      await action();
      if (!context.mounted || revision != controller.revision) return false;
      if (announcement != null && controller.issue == null) {
        TtsService.speak(announcement());
      }
      return true;
    } on LearningStorageException catch (error) {
      _error(context, error.message);
    } on ArgumentError catch (error) {
      _error(
        context,
        error.message?.toString() ?? Speech.t.learningCheckPosition,
      );
    } on Exception catch (error) {
      debugPrint('[LEARNING] Player action failed (${error.runtimeType})');
      _error(
        context,
        Speech.t.learningPlayerActionFailed,
      );
    }
    return false;
  }

  Future<void> _addBookmark(BuildContext context) async {
    final revision = controller.revision;
    final position = controller.position;
    final defaultLabel = Speech.t.learningDefaultBookmarkLabel(
      '${controller.lesson?.nextBookmarkId ?? 1}',
    );
    final label = await showDialog<String>(
      context: context,
      builder: (_) => _BookmarkNameDialog(initialLabel: defaultLabel),
    );
    if (label == null || !context.mounted || revision != controller.revision) {
      return;
    }
    await _run(
      context,
      () => controller.addBookmark(
        label: label == defaultLabel ? null : label,
        at: position,
      ),
      announcement: () =>
          Speech.t.learningBookmarkSavedAt(
            learningTime(controller.lesson!.bookmarks.last.position),
          ),
    );
  }

  Future<void> _bookmarks(BuildContext context) => showDialog<void>(
    context: context,
    builder: (_) => _BookmarksDialog(controller: controller),
  );

  Future<void> _notes(BuildContext context) async {
    final lesson = controller.lesson;
    final position = controller.position;
    if (lesson == null || pauseForNotes == null) return;
    await _run(context, () async {
      await pauseForNotes!();
      if (!context.mounted) return;
      await Navigator.push<void>(
        context,
        MaterialPageRoute(
          builder: (_) => PrivateNotesScreen(
            audioId: lesson.audioId,
            lessonTitle: lesson.title,
            position: position,
          ),
        ),
      );
    });
  }

  List<KeypadFocusTarget> focusTargets(BuildContext context) => [
    KeypadFocusTarget(
      node: nodeFor('learning-status'),
      label: Speech.t.learningReadStatusLabel(_status),
      onActivate: () => TtsService.speak(_status),
    ),
    KeypadFocusTarget(
      node: nodeFor('bookmark-add'),
      label: Speech.t.learningAddBookmarkAt(learningTime(controller.position)),
      isEnabled: () => controller.canSave,
      onActivate: () => _addBookmark(context),
    ),
    KeypadFocusTarget(
      node: nodeFor('bookmarks'),
      label: Speech.t.learningBookmarksSavedPoints(
        controller.lesson?.bookmarks.length ?? 0,
      ),
      isEnabled: () => controller.ready,
      onActivate: () => _bookmarks(context),
    ),
    if (pauseForNotes != null)
      KeypadFocusTarget(
        node: nodeFor('private-notes'),
        label: Speech.t.learningPrivateNotesAt(
          learningTime(controller.position),
        ),
        isEnabled: () => controller.ready,
        onActivate: () => _notes(context),
      ),
    KeypadFocusTarget(
      node: nodeFor('repeat-a'),
      label: Speech.t.learningSetRepeatStartLabel,
      isEnabled: () => controller.canSave,
      onActivate: () => _run(
        context,
        controller.markRepeatStart,
        announcement: () =>
            Speech.t.learningRepeatStartSet(
              learningTime(controller.lesson!.repeatStart!),
            ),
      ),
    ),
    KeypadFocusTarget(
      node: nodeFor('repeat-b'),
      label: Speech.t.learningSetRepeatEndLabel,
      isEnabled: () =>
          controller.canSave && controller.lesson?.repeatStart != null,
      onActivate: () => _run(
        context,
        controller.markRepeatEnd,
        announcement: () =>
            Speech.t.learningRepeatEndSet(
              learningTime(controller.lesson!.repeatEnd!),
            ),
      ),
    ),
    KeypadFocusTarget(
      node: nodeFor('repeat-toggle'),
      label: controller.repeatEnabled
          ? Speech.t.learningTurnRepeatOff
          : Speech.t.learningTurnRepeatOn,
      isEnabled: () => controller.ready && controller.hasRepeatRegion,
      onActivate: () => _run(
        context,
        () async => controller.toggleRepeat(),
        announcement: () =>
            Speech.t.learningStatusRepeat(
              SpokenFormat.onOff(controller.repeatEnabled),
            ),
      ),
    ),
    KeypadFocusTarget(
      node: nodeFor('repeat-clear'),
      label: Speech.t.learningClearRepeatLabel,
      isEnabled: () =>
          controller.canSave && controller.lesson?.repeatStart != null,
      onActivate: () => _run(
        context,
        controller.clearRepeat,
        announcement: () => Speech.t.learningRepeatCleared,
      ),
    ),
    if (showSeekControls) ...[
      KeypadFocusTarget(
        node: nodeFor('learning-back-ten'),
        label: Speech.t.learningBackTenLabel('$playerRewindKey'),
        isEnabled: () =>
            controller.ready && controller.position > Duration.zero,
        onActivate: () => seekBy(context, -10),
      ),
      KeypadFocusTarget(
        node: nodeFor('learning-forward-ten'),
        label: Speech.t.learningForwardTenLabel('$playerForwardKey'),
        isEnabled: () =>
            controller.ready &&
            controller.duration != null &&
            controller.position < controller.duration!,
        onActivate: () => seekBy(context, 10),
      ),
    ],
    if (showSpeedControls) ...[
      KeypadFocusTarget(
        node: nodeFor('learning-slower'),
        label: Speech.t.learningSlowerLabel(
          '$playerSlowerKey',
          learningSpeedNumber(controller.speed),
        ),
        isEnabled: () => controller.ready && controller.speed > 0.25,
        onActivate: () => changeSpeedBy(context, -0.25),
      ),
      KeypadFocusTarget(
        node: nodeFor('learning-faster'),
        label: Speech.t.learningFasterLabel(
          '$playerFasterKey',
          learningSpeedNumber(controller.speed),
        ),
        isEnabled: () => controller.ready && controller.speed < 3,
        onActivate: () => changeSpeedBy(context, 0.25),
      ),
    ],
    if (controller.issue != null)
      KeypadFocusTarget(
        node: nodeFor('learning-retry'),
        label: Speech.t.learningRetrySavingLabel('${controller.issue}'),
        isEnabled: () => controller.ready,
        onActivate: () => _run(
          context,
          controller.retrySaving,
          announcement: () => Speech.t.learningProgressSaved,
        ),
      ),
  ];

  @override
  Widget build(BuildContext context) {
    final actions = focusTargets(context);
    Widget button(String name, String label) {
      final node = nodeFor(name);
      final action = actions.firstWhere(
        (target) => identical(target.node, node),
      );
      return OutlinedButton(
        focusNode: node,
        style: OutlinedButton.styleFrom(
          foregroundColor: UIUtils.textColor,
          side: BorderSide(color: UIUtils.cardBorderColor, width: 1.5),
          minimumSize: const Size(48, 48),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        onPressed: action.isEnabled?.call() == false ? null : action.onActivate,
        child: Text(
          label,
          textAlign: TextAlign.center,
          semanticsLabel: name == 'learning-status' ? null : action.label,
        ),
      );
    }

    final lesson = controller.lesson;
    final t = Speech.t;
    final buttons = <Widget>[
      button('learning-status', t.learningReadStatusButton),
      button('bookmark-add', t.learningAddBookmarkButton),
      button(
        'bookmarks',
        t.learningBookmarksButton('${lesson?.bookmarks.length ?? 0}'),
      ),
      if (pauseForNotes != null)
        button('private-notes', t.learningPrivateNotesButton),
      button(
        'repeat-a',
        lesson?.repeatStart == null
            ? t.learningSetAButton
            : t.learningSetAAtButton(learningTime(lesson!.repeatStart!)),
      ),
      button(
        'repeat-b',
        lesson?.repeatEnd == null
            ? t.learningSetBButton
            : t.learningSetBAtButton(learningTime(lesson!.repeatEnd!)),
      ),
      button(
        'repeat-toggle',
        controller.repeatEnabled
            ? t.learningRepeatOffButton
            : t.learningRepeatOnButton,
      ),
      button('repeat-clear', t.learningClearABButton),
      if (showSeekControls) ...[
        button('learning-back-ten', t.learningBackTenButton('$playerRewindKey')),
        button(
          'learning-forward-ten',
          t.learningForwardTenButton('$playerForwardKey'),
        ),
      ],
      if (showSpeedControls) ...[
        button('learning-slower', t.learningSlowerButton('$playerSlowerKey')),
        button('learning-faster', t.learningFasterButton('$playerFasterKey')),
      ],
      if (controller.issue != null)
        button('learning-retry', t.learningRetrySavingButton),
    ];
    final stacked = UIUtils.isTiny(context) || UIUtils.useStackedLayout(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (controller.issue != null)
          Semantics(
            liveRegion: true,
            child: Text(
              controller.issue!,
              style: TextStyle(color: UIUtils.errorColor, fontSize: 16),
            ),
          ),
        if (stacked)
          for (final child in buttons)
            Padding(padding: const EdgeInsets.only(top: 4), child: child)
        else
          Wrap(spacing: 6, runSpacing: 4, children: buttons),
      ],
    );
  }
}

class _BookmarkNameDialog extends StatefulWidget {
  const _BookmarkNameDialog({required this.initialLabel});
  final String initialLabel;
  @override
  State<_BookmarkNameDialog> createState() => _BookmarkNameDialogState();
}

class _BookmarkNameDialogState extends State<_BookmarkNameDialog> {
  late final _text = TextEditingController(text: widget.initialLabel);
  final _field = FocusNode(debugLabel: 'bookmark-name');
  final _cancel = FocusNode(debugLabel: 'bookmark-cancel');
  final _save = FocusNode(debugLabel: 'bookmark-save');
  final _navigation = KeypadNavigationController();
  String? _error;

  void _submit() {
    final label = _text.text.trim();
    if (label.isEmpty) {
      setState(() => _error = Speech.t.learningEnterBookmarkName);
      TtsService.speak(_error!, priority: SpeechPriority.critical);
    } else {
      Navigator.pop(context, label);
    }
  }

  @override
  void dispose() {
    _text.dispose();
    _field.dispose();
    _cancel.dispose();
    _save.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => KeypadInstructionWrapper(
    screenName: Speech.t.learningNameBookmarkScreen,
    navigationController: _navigation,
    labels: {
      0: Speech.t.uiCancel,
      1: Speech.t.learningEditName,
      2: Speech.t.learningSaveBookmark,
    },
    actions: {
      0: () => Navigator.pop(context),
      1: () => _navigation.enterTextEditing(_field),
      2: _submit,
    },
    focusTargets: [
      KeypadFocusTarget(
        node: _field,
        label: Speech.t.learningBookmarkNameField,
        isTextField: true,
      ),
      KeypadFocusTarget(
        node: _cancel,
        label: Speech.t.uiCancel,
        onActivate: () => Navigator.pop(context),
      ),
      KeypadFocusTarget(
        node: _save,
        label: Speech.t.learningSaveBookmark,
        onActivate: _submit,
      ),
    ],
    child: AlertDialog(
      scrollable: true,
      title: Text(Speech.t.learningNameBookmarkTitle),
      content: TextField(
        controller: _text,
        focusNode: _field,
        onTap: () => _navigation.enterTextEditing(_field),
        decoration: InputDecoration(
          labelText: Speech.t.learningBookmarkNameFieldLabel,
          errorText: _error,
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          focusNode: _cancel,
          onPressed: () => Navigator.pop(context),
          child: Text(Speech.t.uiCancel),
        ),
        FilledButton(
          focusNode: _save,
          onPressed: _submit,
          child: Text(Speech.t.uiSave),
        ),
      ],
    ),
  );
}

class _BookmarksDialog extends StatefulWidget {
  const _BookmarksDialog({required this.controller});
  final LearningPlaybackController controller;
  @override
  State<_BookmarksDialog> createState() => _BookmarksDialogState();
}

class _BookmarksDialogState extends State<_BookmarksDialog> {
  final _nodes = <String, FocusNode>{};
  late final _revision = widget.controller.revision;
  bool get _sameLesson => widget.controller.revision == _revision;
  FocusNode _node(String name) =>
      _nodes.putIfAbsent(name, () => FocusNode(debugLabel: 'bookmark-$name'));

  void _changed() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_changed);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_changed);
    for (final node in _nodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  Future<void> _jump(LessonBookmark bookmark) async {
    if (!_sameLesson) return;
    final controls = LearningControls(
      controller: widget.controller,
      nodeFor: _node,
    );
    final ok = await controls._run(
      context,
      () => widget.controller.moveTo(bookmark.position),
    );
    if (ok && mounted) {
      Navigator.pop(context);
      TtsService.speak(
        Speech.t.learningBookmarkJumped(
          bookmark.label,
          learningSpokenTime(bookmark.position),
        ),
      );
    }
  }

  Future<void> _remove(LessonBookmark bookmark) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => KeypadConfirmationDialog(
        title: Speech.t.learningRemoveBookmarkTitle,
        message: Speech.t.learningRemoveBookmarkMessage(bookmark.label),
        cancelLabel: Speech.t.learningKeepBookmark,
        confirmLabel: Speech.t.learningRemoveBookmark,
        cancelKey: 0,
        confirmKey: 1,
      ),
    );
    if (confirmed != true || !mounted || !_sameLesson) return;
    final controls = LearningControls(
      controller: widget.controller,
      nodeFor: _node,
    );
    await controls._run(
      context,
      () => widget.controller.removeBookmark(bookmark.id),
      announcement: () => Speech.t.learningBookmarkRemoved(bookmark.label),
    );
    if (mounted) _node('close').requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final bookmarks = _sameLesson
        ? widget.controller.lesson?.bookmarks ?? const <LessonBookmark>[]
        : const <LessonBookmark>[];
    return KeypadInstructionWrapper(
      screenName: Speech.t.learningBookmarksScreen,
      labels: {0: Speech.t.learningCloseBookmarks},
      actions: {0: () => Navigator.pop(context)},
      focusTargets: [
        KeypadFocusTarget(
          node: _node('close'),
          label: Speech.t.learningCloseBookmarks,
          onActivate: () => Navigator.pop(context),
        ),
        for (final bookmark in bookmarks) ...[
          KeypadFocusTarget(
            node: _node('jump-${bookmark.id}'),
            label: Speech.t.learningJumpToBookmarkLabel(
              bookmark.label,
              learningTime(bookmark.position),
            ),
            isEnabled: () =>
                widget.controller.ready &&
                (widget.controller.duration == null ||
                    bookmark.position <= widget.controller.duration!),
            onActivate: () => _jump(bookmark),
          ),
          KeypadFocusTarget(
            node: _node('remove-${bookmark.id}'),
            label: Speech.t.learningRemoveBookmarkLabel(bookmark.label),
            isEnabled: () => widget.controller.canSave,
            onActivate: () => _remove(bookmark),
          ),
        ],
      ],
      child: AlertDialog(
        scrollable: true,
        title: Text(Speech.t.learningBookmarksTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!_sameLesson) Text(Speech.t.learningBookmarksLessonChanged),
            if (_sameLesson && bookmarks.isEmpty)
              Text(
                widget.controller.issue == null
                    ? Speech.t.learningBookmarksEmpty
                    : Speech.t.learningBookmarksUnavailable,
              ),
            for (final bookmark in bookmarks)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextButton(
                    focusNode: _node('jump-${bookmark.id}'),
                    onPressed:
                        widget.controller.duration != null &&
                            bookmark.position > widget.controller.duration!
                        ? null
                        : () => _jump(bookmark),
                    child: Text(
                      Speech.t.learningBookmarkAtButton(
                        bookmark.label,
                        learningTime(bookmark.position),
                      ),
                    ),
                  ),
                  TextButton(
                    focusNode: _node('remove-${bookmark.id}'),
                    onPressed: widget.controller.canSave
                        ? () => _remove(bookmark)
                        : null,
                    child: Text(
                      Speech.t.learningRemoveBookmarkLabel(bookmark.label),
                      semanticsLabel: Speech.t.learningRemoveBookmarkSemantics(
                        bookmark.label,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
        actions: [
          TextButton(
            focusNode: _node('close'),
            onPressed: () => Navigator.pop(context),
            child: Text(Speech.t.uiClose),
          ),
        ],
      ),
    );
  }
}
