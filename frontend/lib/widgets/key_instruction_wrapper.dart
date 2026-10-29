import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../main.dart' show routeObserver;
import '../services/tts_service.dart';
import '../utils/keypad_actions.dart';
import '../utils/keypad_config.dart';

enum KeypadInteractionPolicy { legacy, numbered }

/// Explicit navigation state shared by a screen and its keypad wrapper.
/// OK/Enter explicitly enters editing; focused inputs always retain text keys.
class KeypadNavigationController {
  FocusNode? _editingNode;
  final _focusAnnouncements = <FocusNode, String>{};

  bool get isEditing => _editingNode != null;
  bool isEditingNode(FocusNode node) => identical(_editingNode, node);

  void enterTextEditing(FocusNode node) {
    _editingNode = node;
    node.requestFocus();
  }

  void exitTextEditing() {
    _editingNode = null;
  }

  void focusAndAnnounce(FocusNode node, String message) {
    if (node.hasFocus) {
      _focusAnnouncements.remove(node);
      unawaited(TtsService.speak(message, priority: SpeechPriority.navigation));
    } else {
      _focusAnnouncements[node] = message;
      node.requestFocus();
    }
  }
}

/// One item in a screen's deterministic D-pad reading order.
class KeypadFocusTarget {
  const KeypadFocusTarget({
    required this.node,
    required this.label,
    this.onActivate,
    this.isTextField = false,
    this.onDecrease,
    this.onIncrease,
    this.isEnabled,
  });

  final FocusNode node;
  final String label;
  final VoidCallback? onActivate;
  final bool isTextField;
  final VoidCallback? onDecrease;
  final VoidCallback? onIncrease;
  final bool Function()? isEnabled;

  bool get enabled =>
      node.context != null &&
      node.parent != null &&
      node.canRequestFocus &&
      (isEnabled?.call() ?? true);
}

/// Shared physical-keypad layer.
///
/// D-pad traverses [focusTargets], OK/Enter activates the selected target or
/// enters text editing, OK or Up/Down exits editing, and text inputs always
/// retain digits, star and hash instead of triggering screen shortcuts.
class KeypadInstructionWrapper extends StatefulWidget {
  const KeypadInstructionWrapper({
    super.key,
    required this.child,
    required this.actions,
    this.audioAsset,
    this.labels = const {},
    this.screenName,
    this.autoPlay = true,
    this.showDebugOverlay = const bool.fromEnvironment('SEEDS_KEYPAD_QA'),
    this.onStarKey,
    this.onHashKey,
    this.onSpeechRescued,
    this.focusTargets = const [],
    this.navigationController,
    this.interactionPolicy = KeypadInteractionPolicy.legacy,
    this.initialFocusNode,
    this.navigationSections,
    this.introduction,
  });

  final Widget child;
  final String? audioAsset;
  final Map<int, VoidCallback> actions;
  final Map<int, String> labels;
  final String? screenName;
  final bool autoPlay;
  final bool showDebugOverlay;
  final VoidCallback? onStarKey;
  final VoidCallback? onHashKey;
  final VoidCallback? onSpeechRescued;
  final List<KeypadFocusTarget> focusTargets;
  final KeypadNavigationController? navigationController;
  final KeypadInteractionPolicy interactionPolicy;
  final FocusNode? initialFocusNode;
  final String? navigationSections;
  final String? introduction;

  @override
  State<KeypadInstructionWrapper> createState() =>
      _KeypadInstructionWrapperState();
}

class _KeypadInstructionWrapperState extends State<KeypadInstructionWrapper>
    with RouteAware {
  late final AudioPlayer _audioPlayer;
  late final KeypadNavigationController _navigationController;
  final FocusNode _scopeFocusNode = FocusNode(debugLabel: 'keypad-scope');
  final Map<FocusNode, VoidCallback> _focusListeners = {};
  final Map<int, DateTime> _lastFiredAt = {};
  FocusNode? _navigationOnlyTextNode;
  FocusNode? _returnFocusNode;
  Timer? _instructionTimer;
  VoidCallback? _speechCompletionListener;
  bool _returnHelpPending = false;
  ModalRoute<void>? _subscribedRoute;
  static const _debounceDuration = Duration(milliseconds: 300);
  static bool _userInteracted = false;
  static final _keypadScopes = <FocusNode>{};
  static final _heldActionKeys = <PhysicalKeyboardKey>{};

  static KeyEventResult _releaseActionKey(KeyEvent event) {
    if (event is KeyUpEvent) _heldActionKeys.remove(event.physicalKey);
    return KeyEventResult.ignored;
  }

  String _debugLastKey = '';
  String _debugLastChar = '';
  int? _debugResolvedDigit;
  bool _debugActionFired = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _navigationController =
        widget.navigationController ?? KeypadNavigationController();
    _attachFocusListeners();
    if (_keypadScopes.isEmpty) {
      FocusManager.instance.addEarlyKeyEventHandler(_releaseActionKey);
    }
    _keypadScopes.add(_scopeFocusNode);
    FocusManager.instance.addEarlyKeyEventHandler(_handleEarlyKeyEvent);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      (widget.initialFocusNode ?? _scopeFocusNode).requestFocus();
      if (widget.autoPlay) {
        _scheduleInstructions(const Duration(milliseconds: 350));
      }
    });
  }

  @override
  void didUpdateWidget(covariant KeypadInstructionWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    _detachFocusListeners();
    _attachFocusListeners();
    if (widget.autoPlay &&
        (oldWidget.screenName != widget.screenName ||
            oldWidget.introduction != widget.introduction)) {
      _scheduleInstructions(const Duration(milliseconds: 350));
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is ModalRoute<void> && !identical(route, _subscribedRoute)) {
      if (_subscribedRoute != null) {
        routeObserver.unsubscribe(this);
      }
      _subscribedRoute = route;
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void didPopNext() {
    _returnHelpPending = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _navigationController.exitTextEditing();
        final previous = _returnFocusNode;
        if (previous != null &&
            previous.context != null &&
            previous.canRequestFocus) {
          previous.requestFocus();
        } else {
          _scopeFocusNode.requestFocus();
        }
      }
    });
    _scheduleInstructions(const Duration(milliseconds: 400));
  }

  @override
  void didPushNext() {
    _returnHelpPending = false;
    final primary = FocusManager.instance.primaryFocus;
    if (primary != null && primary.ancestors.contains(_scopeFocusNode)) {
      _returnFocusNode = primary;
    }
    _cancelInstructions();
    _navigationController.exitTextEditing();
    _navigationOnlyTextNode = null;
    unawaited(_audioPlayer.stop());
    unawaited(TtsService.stop());
  }

  @override
  void didPop() {
    _cancelInstructions();
    unawaited(_audioPlayer.stop());
    unawaited(TtsService.stop());
  }

  void _attachFocusListeners() {
    for (final target in widget.focusTargets) {
      void listener() {
        if (target.node.hasFocus && target.enabled) {
          if (_returnHelpPending) {
            final message = _navigationController._focusAnnouncements.remove(
              target.node,
            );
            if (message != null) _speakSafely(message);
            return;
          }
          _cancelInstructions();
          _speakSafely(
            _navigationController._focusAnnouncements.remove(target.node) ??
                target.label,
          );
        }
      }

      _focusListeners[target.node] = listener;
      target.node.addListener(listener);
    }
  }

  void _detachFocusListeners() {
    for (final entry in _focusListeners.entries) {
      entry.key.removeListener(entry.value);
    }
    _focusListeners.clear();
  }

  Future<void> _playInstructions({bool detailed = false}) async {
    if (TtsService.mode == SpeechMode.screenReader) return;
    if (kIsWeb && !_userInteracted) return;
    final route = ModalRoute.of(context);
    if (route != null && !route.isCurrent) return;
    try {
      if (widget.audioAsset != null) {
        await TtsService.stop();
        await _audioPlayer.stop();
        await _audioPlayer.play(AssetSource(widget.audioAsset!));
        return;
      }
      // Stopping a platform audio player can complete late on some devices.
      // Do not let that delay or suppress the destination screen's TTS.
      unawaited(_audioPlayer.stop());
      final instructions = _instructionText(detailed: detailed);
      if (instructions.isNotEmpty) await TtsService.speak(instructions);
    } catch (error) {
      debugPrint('[KEYPAD INSTRUCTIONS] $error');
    }
  }

  void _cancelInstructions() {
    _instructionTimer?.cancel();
    final listener = _speechCompletionListener;
    if (listener != null) TtsService.speaking.removeListener(listener);
    _speechCompletionListener = null;
  }

  void _scheduleInstructions(Duration delay) {
    _cancelInstructions();
    // Stop the outgoing screen now, then speak only after the destination
    // route has completed its first frame. This avoids a late route-transition
    // stop cancelling the destination screen's announcement.
    unawaited(_audioPlayer.stop());
    unawaited(TtsService.stop());
    _instructionTimer = Timer(delay, _deliverInstructions);
  }

  void _deliverInstructions() {
    if (!mounted || !(ModalRoute.of(context)?.isCurrent ?? true)) return;
    // Let action feedback finish before repeating the returning screen's help.
    if (_returnHelpPending && TtsService.speaking.value) {
      void listener() {
        if (TtsService.speaking.value) return;
        _cancelInstructions();
        _deliverInstructions();
      }

      _speechCompletionListener = listener;
      TtsService.speaking.addListener(listener);
      return;
    }
    _returnHelpPending = false;
    unawaited(_playInstructions());
  }

  void _speakSafely(String text) {
    unawaited(
      TtsService.speak(text, priority: SpeechPriority.navigation).catchError((
        Object error,
      ) {
        debugPrint('[KEYPAD TTS] $error');
      }),
    );
  }

  String _instructionText({bool detailed = false}) {
    final introduction = widget.introduction == null
        ? ''
        : '${widget.introduction} ';
    final sections = widget.navigationSections == null
        ? ''
        : 'Use D-pad up and down to move through ${widget.navigationSections}. '
              'Press OK to activate the focused control. ';
    if (widget.interactionPolicy == KeypadInteractionPolicy.numbered) {
      final choices = widget.labels.entries
          .where((entry) => entry.key >= 1 && entry.key <= 5)
          .map((entry) => 'Press ${entry.key} for ${entry.value}.')
          .join(' ');
      final extra =
          '${widget.labels.entries.where((entry) => entry.key > 5).map((entry) => 'Press ${entry.key} for ${entry.value}.').join(' ')} '
          'Press 0 to go back or cancel. Press hash to stop app speech. '
          '${detailed ? 'While editing, keys enter text. Press OK to finish, or use up or down to leave the field.' : ''}';
      return '${widget.screenName ?? 'SEEDS'}. $introduction$choices '
          '${sections.isEmpty ? 'Use D-pad up and down to move between choices and OK to select. ' : sections}$extra '
          'Press star to repeat full help.';
    }
    if (!detailed && TtsService.verbosity == SpeechVerbosity.essential) {
      return '${widget.screenName ?? 'SEEDS'}. '
          '$introduction${sections.isEmpty ? 'Use up and down to move, and OK to select. ' : sections}Press star for all shortcuts.';
    }
    if (widget.labels.isNotEmpty) {
      return '$introduction${buildTtsInstructions(widget.labels, screenName: widget.screenName)} '
          '${sections.isEmpty ? 'Use the direction keys to move. ' : sections}Press OK to activate a control or edit a field. '
          'While editing, press OK or use up or down to leave the field.';
    }
    if ((widget.screenName ?? '').isNotEmpty) {
      return '${widget.screenName}. $introduction${sections.isEmpty ? 'Use the direction keys to move and OK to select. ' : sections}'
          'Press star to repeat these instructions.';
    }
    return '';
  }

  Future<void> _repeatHelp() async {
    await TtsService.rescue();
    if (!mounted) return;
    if (TtsService.mode == SpeechMode.selfVoicing) {
      widget.onSpeechRescued?.call();
    }
    final route = ModalRoute.of(context);
    if (route != null && !route.isCurrent) return;
    if (widget.onStarKey != null) {
      widget.onStarKey!();
    } else {
      await _playInstructions(detailed: true);
    }
  }

  void _onInteraction() {
    if (_userInteracted) return;
    _userInteracted = true;
    if (kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final current = _currentTarget;
        if (current != null) {
          _cancelInstructions();
          _speakSafely(current.label);
        } else {
          unawaited(_playInstructions());
        }
      });
    }
  }

  KeypadFocusTarget? get _currentTarget {
    final primary = FocusManager.instance.primaryFocus;
    if (primary == null) return null;
    for (final target in widget.focusTargets) {
      if (identical(primary, target.node) || target.node.hasFocus) {
        return target;
      }
    }
    return null;
  }

  bool _isEditableInputFocused() {
    final primary = FocusManager.instance.primaryFocus;
    final focusContext = primary?.context;
    if (primary == null || focusContext == null || primary == _scopeFocusNode) {
      return false;
    }
    if (focusContext.widget is EditableText) return true;

    var found = false;
    focusContext.visitAncestorElements((element) {
      if (element.widget is EditableText) {
        found = true;
        return false;
      }
      return true;
    });
    if (!found) {
      void visit(Element element) {
        final widget = element.widget;
        if (widget is EditableText && widget.focusNode.hasFocus) {
          found = true;
          return;
        }
        if (!found) element.visitChildren(visit);
      }

      focusContext.visitChildElements(visit);
    }
    return found;
  }

  void _moveFocus(int direction) {
    final targets = widget.focusTargets
        .where((target) => target.enabled)
        .toList();
    if (targets.isEmpty) {
      _navigationController.exitTextEditing();
      _navigationOnlyTextNode = null;
      direction > 0
          ? FocusScope.of(context).nextFocus()
          : FocusScope.of(context).previousFocus();
      return;
    }

    final current = _currentTarget;
    var index = current == null
        ? (direction > 0 ? -1 : 0)
        : targets.indexOf(current);
    if (index < 0) index = direction > 0 ? -1 : 0;
    index = (index + direction) % targets.length;
    if (index < 0) index += targets.length;

    _navigationController.exitTextEditing();
    final next = targets[index];
    _navigationOnlyTextNode = next.isTextField ? next.node : null;
    next.node.requestFocus();
    final targetContext = next.node.context;
    if (targetContext != null) {
      Scrollable.ensureVisible(
        targetContext,
        alignment: 0.45,
        duration: const Duration(milliseconds: 160),
      );
    }
  }

  bool _isEnterKey(LogicalKeyboardKey key) {
    return key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter ||
        key == LogicalKeyboardKey.select;
  }

  KeyEventResult _handleEarlyKeyEvent(KeyEvent event) {
    final primary = FocusManager.instance.primaryFocus;
    if (primary == null || !_scopeFocusNode.hasFocus) {
      return KeyEventResult.ignored;
    }
    // Native sliders consume arrows before bubbling reaches the screen.
    // Only the innermost keypad scope may handle a key ahead of those controls.
    for (final node in [primary, ...primary.ancestors]) {
      if (_keypadScopes.contains(node)) {
        return identical(node, _scopeFocusNode)
            ? _handleKeyEvent(_scopeFocusNode, event)
            : KeyEventResult.ignored;
      }
    }
    return KeyEventResult.ignored;
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (_returnHelpPending) {
      _returnHelpPending = false;
      _cancelInstructions();
    }
    _onInteraction();

    final key = event.logicalKey;
    final character = event.character;

    final current = _currentTarget;
    final unregisteredEditable =
        current?.isTextField != true && _isEditableInputFocused();
    // IMEs may start accepting text as soon as focus arrives, before OK.
    final editing = current != null && current.isTextField;

    if (unregisteredEditable) {
      if (key == LogicalKeyboardKey.arrowUp) {
        _moveFocus(-1);
        return KeyEventResult.handled;
      }
      if (key == LogicalKeyboardKey.arrowDown) {
        _moveFocus(1);
        return KeyEventResult.handled;
      }
      if (_isEnterKey(key)) {
        _moveFocus(1);
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    }

    if (editing) {
      if (_isEnterKey(key)) {
        if (identical(_navigationOnlyTextNode, current.node) &&
            !_navigationController.isEditingNode(current.node)) {
          _navigationOnlyTextNode = null;
          _navigationController.enterTextEditing(current.node);
          _speakSafely('${current.label}. Editing. Press OK when finished.');
        } else {
          _moveFocus(1);
        }
        return KeyEventResult.handled;
      }
      if (key == LogicalKeyboardKey.arrowUp) {
        _moveFocus(-1);
        return KeyEventResult.handled;
      }
      if (key == LogicalKeyboardKey.arrowDown) {
        _moveFocus(1);
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    }

    if (isStarKey(key)) {
      unawaited(_repeatHelp());
      _updateDebug(key.keyLabel, character, null, true, isStar: true);
      return KeyEventResult.handled;
    }
    if (isHashKey(key)) {
      if (widget.interactionPolicy == KeypadInteractionPolicy.numbered) {
        unawaited(TtsService.stop());
      } else if (widget.onHashKey != null) {
        widget.onHashKey!();
      } else {
        unawaited(Navigator.of(context).maybePop());
      }
      _updateDebug(key.keyLabel, character, null, true, isHash: true);
      return KeyEventResult.handled;
    }

    if (key == LogicalKeyboardKey.arrowUp) {
      _moveFocus(-1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowDown) {
      _moveFocus(1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowLeft) {
      current?.onDecrease != null ? current!.onDecrease!() : _moveFocus(-1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowRight) {
      current?.onIncrease != null ? current!.onIncrease!() : _moveFocus(1);
      return KeyEventResult.handled;
    }
    if (_isEnterKey(key)) {
      if (current == null) {
        final primary = FocusManager.instance.primaryFocus;
        if (primary != null &&
            primary != _scopeFocusNode &&
            primary.context != null) {
          Actions.maybeInvoke(primary.context!, const ActivateIntent());
        } else {
          _moveFocus(1);
        }
      } else if (!current.enabled) {
        _speakSafely('This control is not available right now.');
      } else if (current.isTextField) {
        _navigationOnlyTextNode = null;
        _navigationController.enterTextEditing(current.node);
        _speakSafely(
          '${current.label}. Editing. Use up or down to leave this field.',
        );
      } else {
        current.onActivate?.call();
      }
      return KeyEventResult.handled;
    }

    final digit = resolveKeyToDigit(key, character);
    if (digit != null && widget.actions.containsKey(digit)) {
      if (widget.interactionPolicy == KeypadInteractionPolicy.numbered) {
        if (!_heldActionKeys.add(event.physicalKey)) {
          return KeyEventResult.handled;
        }
        widget.actions[digit]!();
        _updateDebug(key.keyLabel, character, digit, true);
        return KeyEventResult.handled;
      }
      final now = DateTime.now();
      final lastFired = _lastFiredAt[digit];
      if (lastFired != null && now.difference(lastFired) < _debounceDuration) {
        _updateDebug(key.keyLabel, character, digit, false);
        return KeyEventResult.handled;
      }
      _lastFiredAt[digit] = now;
      widget.actions[digit]!();
      _updateDebug(key.keyLabel, character, digit, true);
      return KeyEventResult.handled;
    }

    _updateDebug(key.keyLabel, character, digit, false);
    return KeyEventResult.ignored;
  }

  void _updateDebug(
    String keyLabel,
    String? character,
    int? digit,
    bool fired, {
    bool isStar = false,
    bool isHash = false,
  }) {
    if (!widget.showDebugOverlay) return;
    setState(() {
      _debugLastKey = keyLabel;
      _debugLastChar = character ?? '(null)';
      _debugResolvedDigit = isStar ? -1 : (isHash ? -2 : digit);
      _debugActionFired = fired;
    });
  }

  @override
  void dispose() {
    FocusManager.instance.removeEarlyKeyEventHandler(_handleEarlyKeyEvent);
    _keypadScopes.remove(_scopeFocusNode);
    if (_keypadScopes.isEmpty) {
      FocusManager.instance.removeEarlyKeyEventHandler(_releaseActionKey);
      _heldActionKeys.clear();
    }
    _cancelInstructions();
    if (_subscribedRoute != null) routeObserver.unsubscribe(this);
    _detachFocusListeners();
    unawaited(_audioPlayer.stop());
    _audioPlayer.dispose();
    unawaited(TtsService.stop());
    _scopeFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget result = FocusTraversalGroup(
      policy: OrderedTraversalPolicy(),
      child: Focus(
        focusNode: _scopeFocusNode,
        onKeyEvent: _handleKeyEvent,
        autofocus: true,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _onInteraction,
          child: widget.child,
        ),
      ),
    );

    if (widget.showDebugOverlay) {
      result = Stack(
        children: [
          result,
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: Colors.black.withValues(alpha: 0.88),
              padding: const EdgeInsets.all(8),
              child: DefaultTextStyle(
                style: const TextStyle(color: Colors.greenAccent, fontSize: 11),
                child: Text(
                  'Key: $_debugLastKey  Char: $_debugLastChar  '
                  'Digit: ${_debugResolvedDigit ?? 'none'}  '
                  'Fired: ${_debugActionFired ? 'yes' : 'no'}',
                ),
              ),
            ),
          ),
        ],
      );
    }
    return result;
  }
}
