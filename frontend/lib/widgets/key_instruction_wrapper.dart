import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../main.dart' show routeObserver;
import '../services/tts_service.dart';
import '../utils/keypad_actions.dart';
import '../utils/keypad_config.dart';

/// Explicit navigation state shared by a screen and its keypad wrapper.
/// Text fields enter edit mode only after OK/Enter (or a direct touch).
class KeypadNavigationController {
  FocusNode? _editingNode;

  bool get isEditing => _editingNode != null;
  bool isEditingNode(FocusNode node) => identical(_editingNode, node);

  void enterTextEditing(FocusNode node) {
    _editingNode = node;
    node.requestFocus();
  }

  void exitTextEditing() {
    _editingNode = null;
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
      node.canRequestFocus &&
      (isEnabled?.call() ?? true);
}

/// Shared physical-keypad layer.
///
/// D-pad traverses [focusTargets], OK/Enter activates the selected target or
/// enters text editing, Up/Down exits editing, digits are screen shortcuts
/// only in navigation mode, and star repeats the current instructions.
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
    this.focusTargets = const [],
    this.navigationController,
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
  final List<KeypadFocusTarget> focusTargets;
  final KeypadNavigationController? navigationController;

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
  Timer? _instructionTimer;
  ModalRoute<void>? _subscribedRoute;
  static const _debounceDuration = Duration(milliseconds: 300);
  static bool _userInteracted = false;

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _scopeFocusNode.requestFocus();
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _navigationController.exitTextEditing();
        _scopeFocusNode.requestFocus();
      }
    });
    if (widget.autoPlay) {
      _scheduleInstructions(const Duration(milliseconds: 400));
    }
  }

  @override
  void didPushNext() {
    _instructionTimer?.cancel();
    _navigationController.exitTextEditing();
    _navigationOnlyTextNode = null;
    unawaited(_audioPlayer.stop());
    unawaited(TtsService.stop());
  }

  @override
  void didPop() {
    _instructionTimer?.cancel();
    unawaited(_audioPlayer.stop());
    unawaited(TtsService.stop());
  }

  void _attachFocusListeners() {
    for (final target in widget.focusTargets) {
      void listener() {
        if (target.node.hasFocus && target.enabled) {
          _speakSafely(target.label);
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

  Future<void> _playInstructions() async {
    if (kIsWeb && !_userInteracted) return;
    final route = ModalRoute.of(context);
    if (route != null && !route.isCurrent) return;
    try {
      await TtsService.stop();
      if (widget.audioAsset != null) {
        await _audioPlayer.stop();
        await _audioPlayer.play(AssetSource(widget.audioAsset!));
        return;
      }
      // Stopping a platform audio player can complete late on some devices.
      // Do not let that delay or suppress the destination screen's TTS.
      unawaited(_audioPlayer.stop());
      final instructions = _instructionText();
      if (instructions.isNotEmpty) await TtsService.speak(instructions);
    } catch (error) {
      debugPrint('[KEYPAD INSTRUCTIONS] $error');
    }
  }

  void _scheduleInstructions(Duration delay) {
    _instructionTimer?.cancel();
    // Stop the outgoing screen now, then speak only after the destination
    // route has completed its first frame. This avoids a late route-transition
    // stop cancelling the destination screen's announcement.
    unawaited(_audioPlayer.stop());
    unawaited(TtsService.stop());
    _instructionTimer = Timer(delay, () {
      if (!mounted) return;
      final route = ModalRoute.of(context);
      if (route == null || route.isCurrent) {
        unawaited(_playInstructions());
      }
    });
  }

  void _speakSafely(String text) {
    unawaited(
      TtsService.speak(text).catchError((Object error) {
        debugPrint('[KEYPAD TTS] $error');
      }),
    );
  }

  String _instructionText() {
    if (widget.labels.isNotEmpty) {
      return '${buildTtsInstructions(widget.labels, screenName: widget.screenName)} '
          'Use the direction keys to move. Press OK to activate a control or edit a field. '
          'While editing, use up or down to leave the field.';
    }
    if ((widget.screenName ?? '').isNotEmpty) {
      return '${widget.screenName}. Use the direction keys to move and OK to select. '
          'Press star to repeat these instructions.';
    }
    return '';
  }

  void _onInteraction() {
    if (_userInteracted) return;
    _userInteracted = true;
    if (kIsWeb) {
      _playInstructions();
    }
  }

  KeypadFocusTarget? get _currentTarget {
    final primary = FocusManager.instance.primaryFocus;
    if (primary == null) return null;
    for (final target in widget.focusTargets) {
      if (identical(primary, target.node) || target.node.hasFocus)
        return target;
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

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    _onInteraction();

    final key = event.logicalKey;
    final character = event.character;

    if (isStarKey(key)) {
      (widget.onStarKey ?? _playInstructions).call();
      _updateDebug(key.keyLabel, character, null, true, isStar: true);
      return KeyEventResult.handled;
    }
    if (isHashKey(key) && widget.onHashKey != null) {
      widget.onHashKey!();
      _updateDebug(key.keyLabel, character, null, true, isHash: true);
      return KeyEventResult.handled;
    }

    final current = _currentTarget;
    final unregisteredEditable = current == null && _isEditableInputFocused();
    // A text field reached by D-pad remains a selectable control until Enter.
    // A field focused by touch or by a screen shortcut is already an editing
    // surface, so digits must never leak through to numeric screen shortcuts.
    final editing =
        current != null &&
        current.isTextField &&
        (_navigationController.isEditingNode(current.node) ||
            !identical(_navigationOnlyTextNode, current.node));

    if (unregisteredEditable) {
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

    if (editing) {
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
        _moveFocus(1);
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
    _instructionTimer?.cancel();
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
