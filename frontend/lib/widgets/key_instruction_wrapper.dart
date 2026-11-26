import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../announcers/announce.dart';
import '../l10n/speech.dart';
import '../main.dart' show routeObserver;
import '../services/feedback_cues.dart';
import '../services/message_center.dart';
import '../services/tts_service.dart';
import '../services/undo_service.dart';
import '../utils/keypad_actions.dart';
import '../utils/keypad_config.dart';

enum KeypadInteractionPolicy { legacy, numbered }

/// Explicit navigation state shared by a screen and its keypad wrapper.
/// OK/Enter or typing enters editing; focused inputs always retain text keys.
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
/// enters text editing, OK leaves text input for the next non-text control,
/// and Up/Down moves between fields and controls. Text inputs retain digits,
/// star and hash instead of triggering screen shortcuts.
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
    this.onSpeechRescued,
    this.focusTargets = const [],
    this.navigationController,
    this.interactionPolicy = KeypadInteractionPolicy.legacy,
    this.initialFocusNode,
    this.navigationSections,
    this.introduction,
    this.stateSummary,
    this.brief,
    this.loadingNotice,
  });

  final Widget child;
  final String? audioAsset;
  final Map<int, VoidCallback> actions;
  final Map<int, String> labels;
  final String? screenName;
  final bool autoPlay;
  final bool showDebugOverlay;
  final VoidCallback? onStarKey;
  final VoidCallback? onSpeechRescued;
  final List<KeypadFocusTarget> focusTargets;
  final KeypadNavigationController? navigationController;
  final KeypadInteractionPolicy interactionPolicy;
  final FocusNode? initialFocusNode;
  final String? navigationSections;
  final String? introduction;

  /// Current state read by star after the focused item, for example
  /// "Muted. Hand raised. 3 hands waiting. Recording playing."
  final String? Function()? stateSummary;

  /// The screen's current state in one sentence ("English is live. Press 1
  /// to join."). Spoken first whenever the screen opens or is returned to,
  /// followed by every key.
  final String? brief;

  /// Spoken instead of the opening help while the screen is still loading,
  /// so it never reads counts or choices that are not known yet.
  final String? loadingNotice;

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
  TextEditingController? _observedInput;
  VoidCallback? _inputListener;
  FocusNode? _returnFocusNode;
  String? _wrapNotice;
  Timer? _instructionTimer;
  VoidCallback? _speechCompletionListener;
  bool _returnHelpPending = false;
  // The opening speech is still to come: the field focused on opening must
  // not cut it off.
  bool _arrivalPending = false;
  // Set when a screen above this one closed; the next speech is shorter.
  bool _cameBack = false;
  // Set when a screen above this one closes; the next announcement is short.
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
    _scopeFocusNode.addListener(_handleScopeFocusChange);
    _attachFocusListeners();
    if (_keypadScopes.isEmpty) {
      FocusManager.instance.addEarlyKeyEventHandler(_releaseActionKey);
    }
    _keypadScopes.add(_scopeFocusNode);
    FocusManager.instance.addEarlyKeyEventHandler(_handleEarlyKeyEvent);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      (widget.initialFocusNode ?? _scopeFocusNode).requestFocus();
      // A field on the previous screen (sign-in's phone number) can leave a
      // T9 keypad IME attached that swallows the digit keys here.
      _releaseNativeTextInput();
      if (widget.autoPlay) {
        _arrivalPending = true;
        _scheduleInstructions(const Duration(milliseconds: 350));
      } else if (widget.loadingNotice != null) {
        _speakSafely(widget.loadingNotice!);
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
      // Not during this rebuild: stopping speech notifies listeners that
      // may call setState on screens that are still building.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _scheduleInstructions(const Duration(milliseconds: 350));
      });
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
    _cameBack = true;
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
        _releaseNativeTextInput();
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
          if (target.isTextField) _observeTextInput(target.node);
          // The opening speech names this field; do not cut it off.
          if (_arrivalPending &&
              target.isTextField &&
              identical(target.node, widget.initialFocusNode)) {
            return;
          }
          if (_returnHelpPending) {
            final message = _navigationController._focusAnnouncements.remove(
              target.node,
            );
            if (message != null) _speakSafely(message);
            return;
          }
          _cancelInstructions();
          final override = _navigationController._focusAnnouncements.remove(
            target.node,
          );
          final wrapNotice = _wrapNotice;
          _wrapNotice = null;
          _speakSafely(
            '${wrapNotice ?? ''}${override ?? '${target.label}${_positionOf(target)}'}',
          );
        }
      }

      _focusListeners[target.node] = listener;
      target.node.addListener(listener);
      if (target.node.hasFocus && target.isTextField) {
        _observeTextInput(target.node);
      }
    }
  }

  static final _hasEnglishPosition = RegExp(r'\b\d+ of \d+\b');

  /// Matches the current language's "3 of 7" so labels that already say
  /// where they are do not get a second position.
  static bool _hasPosition(String label) {
    if (_hasEnglishPosition.hasMatch(label)) return true;
    final pattern = Speech.t
        .keypadPosition('\u0000', '\u0001')
        .replaceFirst(RegExp(r'^[\s,]+'), '');
    final regex = RegExp(
      RegExp.escape(
        pattern,
      ).replaceAll('\u0000', r'\d+').replaceAll('\u0001', r'\d+'),
    );
    return regex.hasMatch(label);
  }

  /// Spoken ", 3 of 7" suffix so blind users always know where they are.
  String _positionOf(KeypadFocusTarget target) {
    if (TtsService.verbosity == SpeechVerbosity.essential ||
        _hasPosition(target.label)) {
      return '';
    }
    final targets = widget.focusTargets.where((item) => item.enabled).toList();
    final index = targets.indexOf(target);
    if (targets.length < 2 || index < 0) return '';
    return Speech.t.keypadPosition('${index + 1}', '${targets.length}');
  }

  String get _screenName => widget.screenName ?? Speech.t.appName;

  void _detachFocusListeners() {
    _stopObservingTextInput();
    for (final entry in _focusListeners.entries) {
      entry.key.removeListener(entry.value);
    }
    _focusListeners.clear();
  }

  void _observeTextInput(FocusNode node) {
    _stopObservingTextInput();
    final controller = _focusedEditableInput()?.controller;
    if (controller == null) return;
    var previousText = controller.text;
    void listener() {
      if (node.hasFocus && controller.text != previousText) {
        _navigationOnlyTextNode = null;
        _navigationController.enterTextEditing(node);
      }
      previousText = controller.text;
    }

    _observedInput = controller;
    _inputListener = listener;
    controller.addListener(listener);
  }

  void _stopObservingTextInput() {
    final listener = _inputListener;
    if (listener != null) _observedInput?.removeListener(listener);
    _observedInput = null;
    _inputListener = null;
  }

  void _handleScopeFocusChange() {
    if (_scopeFocusNode.hasFocus) return;
    _navigationController.exitTextEditing();
    _navigationOnlyTextNode = null;
    final primary = FocusManager.instance.primaryFocus;
    // IME Done can unfocus the field without sending an Enter key event.
    // Reclaim only focus dropped to our enclosing scope, never another control.
    if (primary is FocusScopeNode &&
        _scopeFocusNode.ancestors.contains(primary) &&
        (ModalRoute.of(context)?.isCurrent ?? true)) {
      _scopeFocusNode.requestFocus();
      _releaseNativeTextInput();
    }
  }

  void _releaseNativeTextInput() {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    // Let EditableText close its client before Android restarts the IME.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || !_scopeFocusNode.hasFocus || _isEditableInputFocused()) {
        return;
      }
      try {
        await const MethodChannel(
          'seeds/keypad',
        ).invokeMethod<void>('finishTextEditing');
      } on PlatformException catch (error) {
        debugPrint('[KEYPAD] Could not release native text input: $error');
      } on MissingPluginException catch (error) {
        debugPrint('[KEYPAD] Native text input release unavailable: $error');
      }
    });
  }

  /// [lead] is spoken before the screen's help, for example a message that
  /// could not be spoken earlier.
  Future<void> _playInstructions({bool detailed = false, String? lead}) async {
    if (kIsWeb && !_userInteracted) return;
    final route = ModalRoute.of(context);
    if (route != null && !route.isCurrent) return;
    _arrivalPending = false;
    final cameBack = _cameBack && !detailed;
    _cameBack = false;
    final arrival = detailed
        ? lead
        : [?lead, ?MessageCenter.takeArrivalMessage()].join(' ');
    final opening = arrival == null || arrival.isEmpty ? null : arrival;
    if (TtsService.mode == SpeechMode.screenReader) {
      // TalkBack reads the screen itself; announce only where the user is
      // unless they asked for full help with star.
      // Every key is still announced, so the keypad is learnable with
      // TalkBack on too.
      final text = [
        ?opening,
        detailed
            ? _whereAmIText()
            : cameBack
            ? _returnText()
            : _instructionText(),
      ].join(' ');
      await TtsService.speak(text, priority: SpeechPriority.navigation);
      return;
    }
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
      final instructions = [
        ?opening,
        detailed
            ? _whereAmIText()
            : cameBack
            ? _returnText()
            : _instructionText(detailed: detailed),
      ].where((part) => part.isNotEmpty).join(' ');
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

  /// The screen's labels plus a spoken name for any key that has an action
  /// but no label, so help never leaves a working key out.
  Map<int, String> get _labels {
    final missing = widget.actions.keys
        .where((key) => key != 0 && !widget.labels.containsKey(key))
        .toList();
    if (missing.isEmpty) return widget.labels;
    // Player screens map 7 and 9 to speed; elsewhere those keys mean other things.
    // Lists also use 7 and 9 (pages), so a screen counts as a player only
    // when it has seek keys and 7 is unlabelled or means slower.
    final slower = widget.labels[playerSlowerKey];
    final slowerLabels = {
      playerSpeedKeyLabels[playerSlowerKey],
      playerFallbackKeyLabels[playerSlowerKey],
      quizAttemptKeyLabels[playerSlowerKey],
    };
    final player =
        widget.actions.containsKey(playerRewindKey) &&
        widget.actions.containsKey(playerForwardKey) &&
        widget.actions.containsKey(playerSlowerKey) &&
        widget.actions.containsKey(playerFasterKey) &&
        (slower == null ||
            slowerLabels.contains(slower) ||
            slower.toLowerCase().contains('slow'));
    final labels = Map<int, String>.of(widget.labels);
    final unnamed = <int>[];
    for (final key in missing) {
      final fallback = player ? playerFallbackKeyLabels[key] : null;
      if (fallback != null) {
        labels[key] = fallback;
      } else {
        unnamed.add(key);
      }
    }
    assert(() {
      debugPrint(
        '[KEYPAD] ${widget.screenName ?? 'Screen'} maps keys $missing without '
        'labels${unnamed.isEmpty ? '' : '; $unnamed are not spoken'}.',
      );
      return true;
    }());
    return labels;
  }

  /// Coming back from a screen opened on top: the screen, its state and
  /// only the two main keys (the first choice and 0), then that star reads
  /// every key.
  String _returnText() {
    final t = Speech.t;
    final brief = widget.brief == null || widget.brief!.isEmpty
        ? widget.stateSummary?.call()
        : widget.brief;
    final keys = _keysWithBack;
    final forward = keys.keys.where((key) => key != 0).toList()..sort();
    final major = {
      if (forward.isNotEmpty) forward.first: keys[forward.first]!,
      if (keys.containsKey(0))
        0: keys[0]!
      else if (forward.length > 1)
        forward[1]: keys[forward[1]]!,
    };
    return [
      '$_screenName.',
      if (brief != null && brief.isNotEmpty) brief,
      if (major.isNotEmpty) spokenKeyList(major),
      t.sessionStarForKeys,
    ].join(' ');
  }

  /// The screen's keys, with 0 named Back when the screen does not label it
  /// and there is somewhere to go back to (not on the first screen).
  Map<int, String> get _keysWithBack => {
    ..._labels,
    if (!_labels.containsKey(0) &&
        (Navigator.maybeOf(context)?.canPop() ?? false) &&
        (widget.interactionPolicy == KeypadInteractionPolicy.numbered ||
            _labels.isNotEmpty))
      0: Speech.t.uiBack,
  };

  bool get _hasTextField =>
      widget.focusTargets.any((target) => target.isTextField);

  /// When a screen opens with a text field already focused (sign-in), say
  /// which field, before the keys; how editing works is in the star help.
  String _focusedFieldNote() {
    final current = _currentTarget;
    if (current == null || !current.isTextField || !current.node.hasFocus) {
      return '';
    }
    return '${Speech.t.uiFocusedField(current.label)} ';
  }

  /// Opening a screen reads its name, state and every key in one short
  /// sentence. Star ([detailed]) adds how to move, hash, and how editing
  /// works when the screen has a text field.
  String _instructionText({bool detailed = false, bool withName = true}) {
    final t = Speech.t;
    final name = withName ? '$_screenName. ' : '';
    final brief = widget.brief == null || widget.brief!.isEmpty
        ? null
        : widget.brief;
    final introduction = [
      if (!detailed && brief != null) brief,
      ?widget.introduction,
    ].map((part) => '$part ').join();
    final keys = _keysWithBack;
    final how = !detailed
        ? keys.isEmpty
              ? '${t.keypadDirectionKeysAndOk} ${t.keypadStarHelp}'
              : t.keypadStarHelp
        : [
            widget.navigationSections != null
                ? t.keypadMoveThroughSections(widget.navigationSections!)
                : t.keypadDirectionKeysAndOk,
            t.keypadHashAndStar,
            if (_hasTextField) t.keypadLeaveField,
          ].join(' ');
    final keyText = keys.isEmpty ? '' : '${spokenKeyList(keys)} ';
    if (keys.isEmpty && (widget.screenName ?? '').isEmpty) return '';
    final field = detailed ? '' : _focusedFieldNote();
    return '$name$introduction$field$keyText$how';
  }

  /// Star: screen, focused item, current state and last message, then keys.
  String _whereAmIText() {
    final current = _currentTarget;
    final where = CommonText.whereAmI(
      screen: _screenName,
      focused: current == null || !current.enabled
          ? null
          : '${current.label}${_positionOf(current)}',
      state: widget.stateSummary?.call(),
      message: MessageCenter.spoken(),
    );
    return '$where ${_instructionText(detailed: true, withName: false)}';
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
        // Speech the browser refused before this first interaction.
        final blocked = TtsService.takeBlockedSpeech();
        final current = _currentTarget;
        if (current != null) {
          _cancelInstructions();
          _speakSafely([?blocked, current.label].join(' '));
        } else {
          unawaited(_playInstructions(lead: blocked));
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

  bool _isEditableInputFocused() => _focusedEditableInput() != null;

  EditableText? _focusedEditableInput() {
    final primary = FocusManager.instance.primaryFocus;
    final focusContext = primary?.context;
    if (primary == null || focusContext == null || primary == _scopeFocusNode) {
      return null;
    }
    final focusedWidget = focusContext.widget;
    if (focusedWidget is EditableText) return focusedWidget;

    EditableText? found;
    focusContext.visitAncestorElements((element) {
      final widget = element.widget;
      if (widget is EditableText) {
        found = widget;
        return false;
      }
      return true;
    });
    if (found == null) {
      void visit(Element element) {
        final widget = element.widget;
        if (widget is EditableText && widget.focusNode.hasFocus) {
          found = widget;
          return;
        }
        if (found == null) element.visitChildren(visit);
      }

      focusContext.visitChildElements(visit);
    }
    return found;
  }

  void _moveFocus(int direction, {bool skipTextFields = false}) {
    if (_isEditableInputFocused()) _releaseNativeTextInput();
    final targets = widget.focusTargets
        .where((target) => target.enabled)
        .toList();
    if (targets.isEmpty ||
        (skipTextFields && targets.every((target) => target.isTextField))) {
      _navigationController.exitTextEditing();
      _navigationOnlyTextNode = null;
      if (skipTextFields) {
        _scopeFocusNode.requestFocus();
      } else {
        direction > 0
            ? FocusScope.of(context).nextFocus()
            : FocusScope.of(context).previousFocus();
      }
      return;
    }

    final current = _currentTarget;
    var index = current == null
        ? (direction > 0 ? -1 : 0)
        : targets.indexOf(current);
    if (index < 0) index = direction > 0 ? -1 : 0;
    var unwrapped = index + direction;
    if (skipTextFields) {
      while (targets[unwrapped % targets.length].isTextField) {
        unwrapped += direction;
      }
    }
    _wrapNotice = current == null || targets.length < 2
        ? null
        : unwrapped >= targets.length
        ? CommonText.endOfList
        : unwrapped < 0
        ? CommonText.topOfList
        : null;
    if (_wrapNotice != null) unawaited(FeedbackCues.play(Cue.endOfList));
    index = unwrapped % targets.length;
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

  /// A key or touch before the opening speech starts: the person is already
  /// acting, so the delayed opening help must not talk over what follows.
  void _actedBeforeArrival() {
    if (!_arrivalPending) return;
    _arrivalPending = false;
    _cancelInstructions();
  }

  /// True when [primary] belongs to no keypad screen, nor to a text field,
  /// and this is the innermost keypad screen on the visible route.
  bool _ownsStrayFocus(FocusNode? primary) {
    if (!mounted || _scopeFocusNode.context == null) return false;
    if (!(ModalRoute.of(context)?.isCurrent ?? true)) return false;
    if (primary != null) {
      if (_keypadScopes.contains(primary) ||
          primary.ancestors.any(_keypadScopes.contains)) {
        return false;
      }
      if (primary.context?.widget is EditableText ||
          primary.context?.findAncestorStateOfType<EditableTextState>() !=
              null) {
        return false;
      }
    }
    var passedSelf = false;
    for (final other in _keypadScopes) {
      if (identical(other, _scopeFocusNode)) {
        passedSelf = true;
        continue;
      }
      if (!passedSelf) continue;
      final otherContext = other.context;
      if (otherContext == null || !otherContext.mounted) continue;
      if (!(ModalRoute.of(otherContext)?.isCurrent ?? true)) continue;
      // A later keypad scope on the visible route (nested inside this one or
      // beside it) answers instead, so a key never runs twice.
      if (!_scopeFocusNode.ancestors.contains(other)) return false;
    }
    return true;
  }

  KeyEventResult _handleEarlyKeyEvent(KeyEvent event) {
    final primary = FocusManager.instance.primaryFocus;
    if (primary == null || !_scopeFocusNode.hasFocus) {
      // Focus can drop outside every keypad screen (TalkBack moving focus,
      // a closed overlay). The screen on top then still answers its keys
      // instead of ignoring them.
      if (event is! KeyDownEvent || !_ownsStrayFocus(primary)) {
        return KeyEventResult.ignored;
      }
      _scopeFocusNode.requestFocus();
      _actedBeforeArrival();
      return _handleKeyEvent(_scopeFocusNode, event);
    }
    if (event is KeyDownEvent) _actedBeforeArrival();
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
        _moveFocus(1, skipTextFields: true);
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
          _speakSafely(Speech.t.keypadEditingPressOk(current.label));
        } else {
          _moveFocus(1, skipTextFields: true);
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
      // One meaning on every screen: stop the app talking. Never navigates.
      unawaited(TtsService.stop());
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
        _speakSafely(Speech.t.keypadControlUnavailable);
      } else if (current.isTextField) {
        _navigationOnlyTextNode = null;
        _navigationController.enterTextEditing(current.node);
        _speakSafely(Speech.t.keypadEditingUseUpDown(current.label));
      } else {
        current.onActivate?.call();
      }
      return KeyEventResult.handled;
    }

    final digit = resolveKeyToDigit(key, character);
    if (digit == 1 && UndoService.pending) {
      if (_heldActionKeys.add(event.physicalKey)) UndoService.handleKey();
      return KeyEventResult.handled;
    }
    if (digit == 8 && !widget.actions.containsKey(8)) {
      MessageCenter.repeat();
      return KeyEventResult.handled;
    }
    if (digit != null && widget.actions.containsKey(digit)) {
      if (widget.interactionPolicy == KeypadInteractionPolicy.numbered) {
        if (!_heldActionKeys.add(event.physicalKey)) {
          return KeyEventResult.handled;
        }
        MessageCenter.noteKey(digit);
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
      MessageCenter.noteKey(digit);
      widget.actions[digit]!();
      _updateDebug(key.keyLabel, character, digit, true);
      return KeyEventResult.handled;
    }
    if (digit == 0) {
      // 0 always means back, even on screens that did not map it.
      final navigator = Navigator.of(context);
      if (navigator.canPop()) {
        unawaited(navigator.maybePop());
      } else {
        _speakSafely(Speech.t.keypadMainScreen);
      }
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
    _scopeFocusNode.removeListener(_handleScopeFocusChange);
    unawaited(_audioPlayer.stop());
    _audioPlayer.dispose();
    // No TtsService.stop() here: navigation already stopped this screen's
    // speech (didPop, didPushNext, route observer). Disposal happens after the
    // exit transition, so stopping now would cut off the next screen's
    // introduction or the feedback spoken after a dialog closes.
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
        // A Listener sees every touch or click, including ones a button
        // claims; browsers only allow speech after such an interaction.
        child: Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: (_) {
            _actedBeforeArrival();
            _onInteraction();
          },
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
