import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import '../services/tts_service.dart';
import '../utils/ui_utils.dart';
import '../utils/keypad_config.dart';
import '../utils/keypad_actions.dart';

/// A wrapper widget that:
///   1. Auto-speaks key-mapping instructions via TTS on page load
///   2. Resolves keypad letter keys (T9 multi-tap) to digit actions
///   3. Debounces rapid key events (300 ms per digit)
///   4. Optionally shows a debug overlay for on-device testing
///
/// Usage:
/// ```dart
/// KeypadInstructionWrapper(
///   actions: { 1: _login, 2: _goToRegister },
///   labels:  { 1: 'Login', 2: 'Register' },
///   child: Scaffold(...),
/// )
/// ```

class KeypadInstructionWrapper extends StatefulWidget {
  final Widget child;

  /// Optional audio asset to play on load (fallback if TTS is unavailable).
  final String? audioAsset;

  /// Digit → callback mapping.  Keys are digits 0-9.
  final Map<int, VoidCallback> actions;

  /// Digit → human-readable label.  Used to auto-build TTS instructions
  /// like "Press 1 for Login. Press 2 for Register."
  final Map<int, String> labels;

  /// Optional screen name spoken before the key instructions,
  /// e.g. "Login Screen. Press 1 for ..."
  final String? screenName;

  /// Whether to auto-play instructions on load.
  final bool autoPlay;

  /// Show a debug overlay that displays raw key events and resolved digits.
  /// Enable this when testing on the physical keypad phone, then set to false.
  final bool showDebugOverlay;

  /// Optional: callback for the * (star) key.
  final VoidCallback? onStarKey;

  /// Optional: callback for the # (hash) key.
  final VoidCallback? onHashKey;

  const KeypadInstructionWrapper({
    super.key,
    required this.child,
    this.audioAsset,
    required this.actions,
    this.labels = const {},
    this.screenName,
    this.autoPlay = true,
    this.showDebugOverlay = false,
    this.onStarKey,
    this.onHashKey,
  });

  @override
  State<KeypadInstructionWrapper> createState() =>
      _KeypadInstructionWrapperState();
}

class _KeypadInstructionWrapperState extends State<KeypadInstructionWrapper> {
  late AudioPlayer _audioPlayer;
  final FocusNode _focusNode = FocusNode();

  // ── Debounce state ──────────────────────────────────────────────────────
  // Prevents multiple firings when a keypad button cycles through letters.
  final Map<int, DateTime> _lastFiredAt = {};
  static const _debounceDuration = Duration(milliseconds: 300);

  // ── Debug overlay state ─────────────────────────────────────────────────
  String _debugLastKey = '';
  String _debugLastChar = '';
  int? _debugResolvedDigit;
  bool _debugActionFired = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    if (widget.autoPlay) {
      _playInstructions();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  static bool _userInteracted = false;

  Future<void> _playInstructions() async {
    // On Web, browsers block audio/TTS until user interaction
    if (kIsWeb && !_userInteracted) {
      debugPrint('[AUDIO] Web auto-play blocked. Waiting for first interaction.');
      return;
    }

    try {
      // Try audio asset first
      if (widget.audioAsset != null) {
        debugPrint('[AUDIO] Playing asset: ${widget.audioAsset}');
        await _audioPlayer.play(AssetSource(widget.audioAsset!));
        return; // audio played OK, don't also speak TTS
      }

      // Auto-generate TTS from labels
      if (widget.labels.isNotEmpty) {
        final instructions = buildTtsInstructions(
          widget.labels,
          screenName: widget.screenName,
        );
        debugPrint('[TTS] Speaking: $instructions');
        await TtsService.speak(instructions);
      }
    } catch (e) {
      debugPrint('[AUDIO ERROR] $e');
      // Fallback: try TTS even if audio failed
      if (widget.labels.isNotEmpty) {
        try {
          final instructions = buildTtsInstructions(
            widget.labels,
            screenName: widget.screenName,
          );
          await TtsService.speak(instructions);
        } catch (ttsErr) {
          debugPrint('[TTS FALLBACK ERROR] $ttsErr');
        }
      }
    }
  }

  void _onInteraction() {
    if (!_userInteracted) {
      _userInteracted = true;
      _playInstructions();
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// Returns true if the currently-focused widget is a text input field.
  /// In that case we should NOT intercept key presses — let the user type.
  bool _isTextInputFocused() {
    final focus = FocusManager.instance.primaryFocus;
    if (focus == null || !focus.hasPrimaryFocus) return false;
    if (focus == _focusNode) return false;

    final context = focus.context;
    if (context == null) return false;

    final widgetType = context.widget.runtimeType.toString();
    if (widgetType.contains('EditableText') ||
        widgetType.contains('TextField') ||
        widgetType.contains('TextFormField')) {
      return true;
    }

    bool foundInput = false;
    context.visitAncestorElements((element) {
      final t = element.widget.runtimeType.toString();
      if (t.contains('EditableText') ||
          t.contains('TextField') ||
          t.contains('TextFormField')) {
        foundInput = true;
        return false;
      }
      return true;
    });

    return foundInput;
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    // Don't intercept when the user is typing in a text field
    if (_isTextInputFocused()) return KeyEventResult.ignored;

    _onInteraction();

    final key = event.logicalKey;
    final character = event.character;

    // ── Special keys (* and #) ────────────────────────────────────────────
    if (isStarKey(key) && widget.onStarKey != null) {
      widget.onStarKey!();
      _updateDebug(key.keyLabel, character, null, true, isStar: true);
      return KeyEventResult.handled;
    }
    if (isHashKey(key) && widget.onHashKey != null) {
      widget.onHashKey!();
      _updateDebug(key.keyLabel, character, null, true, isHash: true);
      return KeyEventResult.handled;
    }

    // ── Resolve key to digit ──────────────────────────────────────────────
    final digit = resolveKeyToDigit(key, character);

    if (digit != null && widget.actions.containsKey(digit)) {
      // Debounce: skip if we fired this digit less than 300ms ago
      final now = DateTime.now();
      final lastFired = _lastFiredAt[digit];
      if (lastFired != null &&
          now.difference(lastFired) < _debounceDuration) {
        _updateDebug(key.keyLabel, character, digit, false);
        return KeyEventResult.handled; // consume but don't fire again
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
      _debugResolvedDigit = digit;
      _debugActionFired = fired;
      if (isStar) _debugResolvedDigit = -1; // sentinel for display
      if (isHash) _debugResolvedDigit = -2;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget child = Focus(
      focusNode: _focusNode,
      onKeyEvent: _handleKeyEvent,
      autofocus: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _onInteraction,
        child: widget.child,
      ),
    );

    if (widget.showDebugOverlay) {
      child = Stack(
        children: [
          child,
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildDebugOverlay(context),
          ),
        ],
      );
    }

    return child;
  }

  Widget _buildDebugOverlay(BuildContext context) {
    String digitDisplay;
    if (_debugResolvedDigit == null) {
      digitDisplay = 'none';
    } else if (_debugResolvedDigit == -1) {
      digitDisplay = '* (star)';
    } else if (_debugResolvedDigit == -2) {
      digitDisplay = '# (hash)';
    } else {
      digitDisplay = '$_debugResolvedDigit';
    }

    return Container(
      color: Colors.black.withOpacity(0.85),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: DefaultTextStyle(
        style: const TextStyle(
          color: Colors.greenAccent,
          fontFamily: 'monospace',
          fontSize: 11,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('─── KEYPAD DEBUG ───',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Key:      $_debugLastKey'),
            Text('Char:     $_debugLastChar'),
            Text('Digit:    $digitDisplay'),
            Text(
              'Fired:    ${_debugActionFired ? "YES ✓" : "no"}',
              style: TextStyle(
                color: _debugActionFired ? Colors.greenAccent : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
