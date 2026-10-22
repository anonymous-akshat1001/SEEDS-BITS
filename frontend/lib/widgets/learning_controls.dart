import 'package:flutter/material.dart';

import '../services/learning_playback_controller.dart';
import '../services/learning_progress_store.dart';
import '../services/tts_service.dart';
import '../screens/private_notes_screen.dart';
import 'key_instruction_wrapper.dart';
import 'keypad_confirmation_dialog.dart';

String learningTime(Duration position) {
  final minutes = position.inMinutes;
  final seconds = position.inSeconds.remainder(60);
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
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
          title: 'Saved progress unavailable',
          message:
              '${error.message} Listen from the beginning without changing '
              'saved data? Saving stays off until you retry successfully.',
          cancelLabel: 'Cancel',
          confirmLabel: 'Listen from beginning',
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
    final point = controller.position;
    final lesson = controller.lesson;
    return '${lesson?.title ?? 'Recorded lesson'}. '
        'Position ${point.inMinutes} minutes ${point.inSeconds.remainder(60)} seconds. '
        'Speed ${controller.speed.toStringAsFixed(2)} times. '
        '${lesson?.bookmarks.length ?? 0} bookmarks. '
        'A-B repeat ${controller.repeatEnabled ? 'on' : 'off'}. '
        'Progress saving ${controller.canSave ? 'on' : 'off'}. '
        '${controller.issue ?? ''}';
  }

  static void _error(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
    TtsService.speak(message, priority: SpeechPriority.critical);
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
        error.message?.toString() ?? 'Check the lesson position and try again.',
      );
    } on Exception catch (error) {
      debugPrint('[LEARNING] Player action failed (${error.runtimeType})');
      _error(
        context,
        'The player could not complete this action. Check playback and try again.',
      );
    }
    return false;
  }

  Future<void> _addBookmark(BuildContext context) async {
    final revision = controller.revision;
    final position = controller.position;
    final defaultLabel = 'Bookmark ${controller.lesson?.nextBookmarkId ?? 1}';
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
          'Bookmark saved at ${learningTime(controller.lesson!.bookmarks.last.position)}.',
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
      label: 'Read learning status. $_status',
      onActivate: () => TtsService.speak(_status),
    ),
    KeypadFocusTarget(
      node: nodeFor('bookmark-add'),
      label: 'Add bookmark at ${learningTime(controller.position)}',
      isEnabled: () => controller.canSave,
      onActivate: () => _addBookmark(context),
    ),
    KeypadFocusTarget(
      node: nodeFor('bookmarks'),
      label:
          'Bookmarks. ${controller.lesson?.bookmarks.length ?? 0} saved points',
      isEnabled: () => controller.ready,
      onActivate: () => _bookmarks(context),
    ),
    if (pauseForNotes != null)
      KeypadFocusTarget(
        node: nodeFor('private-notes'),
        label:
            'Private study notes at ${learningTime(controller.position)}. Pause lesson before opening',
        isEnabled: () => controller.ready,
        onActivate: () => _notes(context),
      ),
    KeypadFocusTarget(
      node: nodeFor('repeat-a'),
      label: 'Set repeat start A at the current position',
      isEnabled: () => controller.canSave,
      onActivate: () => _run(
        context,
        controller.markRepeatStart,
        announcement: () =>
            'Repeat start set at ${learningTime(controller.lesson!.repeatStart!)}.',
      ),
    ),
    KeypadFocusTarget(
      node: nodeFor('repeat-b'),
      label: 'Set repeat end B after start A',
      isEnabled: () =>
          controller.canSave && controller.lesson?.repeatStart != null,
      onActivate: () => _run(
        context,
        controller.markRepeatEnd,
        announcement: () =>
            'Repeat end set at ${learningTime(controller.lesson!.repeatEnd!)}. Select Repeat on to start looping.',
      ),
    ),
    KeypadFocusTarget(
      node: nodeFor('repeat-toggle'),
      label: controller.repeatEnabled
          ? 'Turn A-B repeat off'
          : 'Turn A-B repeat on',
      isEnabled: () => controller.ready && controller.hasRepeatRegion,
      onActivate: () => _run(
        context,
        () async => controller.toggleRepeat(),
        announcement: () =>
            'A-B repeat ${controller.repeatEnabled ? 'on' : 'off'}.',
      ),
    ),
    KeypadFocusTarget(
      node: nodeFor('repeat-clear'),
      label: 'Clear saved A-B repeat points',
      isEnabled: () =>
          controller.canSave && controller.lesson?.repeatStart != null,
      onActivate: () => _run(
        context,
        controller.clearRepeat,
        announcement: () => 'A-B repeat points cleared.',
      ),
    ),
    if (showSeekControls) ...[
      KeypadFocusTarget(
        node: nodeFor('learning-back-ten'),
        label: 'Review the previous ten seconds',
        isEnabled: () =>
            controller.ready && controller.position > Duration.zero,
        onActivate: () =>
            _run(context, () => controller.moveTo(_offsetPosition(-10))),
      ),
      KeypadFocusTarget(
        node: nodeFor('learning-forward-ten'),
        label: 'Move forward ten seconds',
        isEnabled: () =>
            controller.ready &&
            controller.duration != null &&
            controller.position < controller.duration!,
        onActivate: () =>
            _run(context, () => controller.moveTo(_offsetPosition(10))),
      ),
    ],
    if (showSpeedControls) ...[
      KeypadFocusTarget(
        node: nodeFor('learning-slower'),
        label: 'Slower playback',
        isEnabled: () => controller.ready && controller.speed > 0.25,
        onActivate: () => _run(
          context,
          () => controller.changeSpeed(
            (controller.speed - 0.25).clamp(0.25, 3.0),
          ),
        ),
      ),
      KeypadFocusTarget(
        node: nodeFor('learning-faster'),
        label: 'Faster playback',
        isEnabled: () => controller.ready && controller.speed < 3,
        onActivate: () => _run(
          context,
          () => controller.changeSpeed(
            (controller.speed + 0.25).clamp(0.25, 3.0),
          ),
        ),
      ),
    ],
    if (controller.issue != null)
      KeypadFocusTarget(
        node: nodeFor('learning-retry'),
        label: 'Retry saving learning progress. ${controller.issue}',
        isEnabled: () => controller.ready,
        onActivate: () => _run(
          context,
          controller.retrySaving,
          announcement: () => 'Learning progress saved.',
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
        onPressed: action.isEnabled?.call() == false ? null : action.onActivate,
        child: Text(label, textAlign: TextAlign.center),
      );
    }

    final lesson = controller.lesson;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (controller.issue != null)
          Semantics(liveRegion: true, child: Text(controller.issue!)),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: [
            button('learning-status', 'Read learning status'),
            button('bookmark-add', 'Add bookmark'),
            button('bookmarks', 'Bookmarks (${lesson?.bookmarks.length ?? 0})'),
            if (pauseForNotes != null)
              button('private-notes', 'Private study notes'),
            button(
              'repeat-a',
              'Set A${lesson?.repeatStart == null ? '' : ' ${learningTime(lesson!.repeatStart!)}'}',
            ),
            button(
              'repeat-b',
              'Set B${lesson?.repeatEnd == null ? '' : ' ${learningTime(lesson!.repeatEnd!)}'}',
            ),
            button(
              'repeat-toggle',
              controller.repeatEnabled ? 'Repeat off' : 'Repeat on',
            ),
            button('repeat-clear', 'Clear A-B'),
            if (showSeekControls) ...[
              button('learning-back-ten', 'Back 10 seconds'),
              button('learning-forward-ten', 'Forward 10 seconds'),
            ],
            if (showSpeedControls) ...[
              button('learning-slower', 'Slower'),
              button('learning-faster', 'Faster'),
            ],
            if (controller.issue != null)
              button('learning-retry', 'Retry saving'),
          ],
        ),
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
      setState(() => _error = 'Enter a bookmark name.');
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
    screenName: 'Name bookmark. Press OK to edit. Up or down leaves editing.',
    navigationController: _navigation,
    labels: const {0: 'Cancel', 1: 'Edit name', 2: 'Save bookmark'},
    actions: {
      0: () => Navigator.pop(context),
      1: () => _navigation.enterTextEditing(_field),
      2: _submit,
    },
    focusTargets: [
      KeypadFocusTarget(
        node: _field,
        label: 'Bookmark name',
        isTextField: true,
      ),
      KeypadFocusTarget(
        node: _cancel,
        label: 'Cancel',
        onActivate: () => Navigator.pop(context),
      ),
      KeypadFocusTarget(
        node: _save,
        label: 'Save bookmark',
        onActivate: _submit,
      ),
    ],
    child: AlertDialog(
      scrollable: true,
      title: const Text('Name bookmark'),
      content: TextField(
        controller: _text,
        focusNode: _field,
        onTap: () => _navigation.enterTextEditing(_field),
        decoration: InputDecoration(labelText: 'Name', errorText: _error),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          focusNode: _cancel,
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          focusNode: _save,
          onPressed: _submit,
          child: const Text('Save'),
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
        '${bookmark.label}. Position ${learningTime(bookmark.position)}.',
      );
    }
  }

  Future<void> _remove(LessonBookmark bookmark) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => KeypadConfirmationDialog(
        title: 'Remove bookmark?',
        message:
            'Remove ${bookmark.label}? This does not remove the lesson or any other bookmarks.',
        cancelLabel: 'Keep bookmark',
        confirmLabel: 'Remove bookmark',
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
      announcement: () => 'Bookmark removed.',
    );
    if (mounted) _node('close').requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final bookmarks = _sameLesson
        ? widget.controller.lesson?.bookmarks ?? const <LessonBookmark>[]
        : const <LessonBookmark>[];
    return KeypadInstructionWrapper(
      screenName:
          'Bookmarks. Select a point to jump. This does not start paused playback. Remove asks for confirmation.',
      labels: const {0: 'Close bookmarks'},
      actions: {0: () => Navigator.pop(context)},
      focusTargets: [
        KeypadFocusTarget(
          node: _node('close'),
          label: 'Close bookmarks',
          onActivate: () => Navigator.pop(context),
        ),
        for (final bookmark in bookmarks) ...[
          KeypadFocusTarget(
            node: _node('jump-${bookmark.id}'),
            label:
                '${bookmark.label}. ${learningTime(bookmark.position)}. Jump to bookmark',
            isEnabled: () =>
                widget.controller.ready &&
                (widget.controller.duration == null ||
                    bookmark.position <= widget.controller.duration!),
            onActivate: () => _jump(bookmark),
          ),
          KeypadFocusTarget(
            node: _node('remove-${bookmark.id}'),
            label: 'Remove ${bookmark.label}',
            isEnabled: () => widget.controller.canSave,
            onActivate: () => _remove(bookmark),
          ),
        ],
      ],
      child: AlertDialog(
        scrollable: true,
        title: const Text('Bookmarks'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!_sameLesson)
              const Text(
                'The lesson changed. Close this list and open bookmarks for the current lesson.',
              ),
            if (_sameLesson && bookmarks.isEmpty)
              Text(
                widget.controller.issue == null
                    ? 'No bookmarks yet. Use Add bookmark at a position you want to remember.'
                    : 'Saved bookmarks are unavailable. Retry saving to restore access to saved progress.',
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
                      '${bookmark.label} at ${learningTime(bookmark.position)}',
                    ),
                  ),
                  TextButton(
                    focusNode: _node('remove-${bookmark.id}'),
                    onPressed: widget.controller.canSave
                        ? () => _remove(bookmark)
                        : null,
                    child: const Text('Remove bookmark'),
                  ),
                ],
              ),
          ],
        ),
        actions: [
          TextButton(
            focusNode: _node('close'),
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
