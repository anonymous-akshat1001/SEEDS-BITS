import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import '../services/tts_service.dart';
import '../utils/ui_utils.dart';

/// A wrapper widget that plays periodic/on-load audio instructions
/// and handles keypad/keyboard numeric shortcuts.
class KeypadInstructionWrapper extends StatefulWidget {
  final Widget child;
  final String? audioAsset;
  final String? ttsInstructions;
  final Map<LogicalKeyboardKey, VoidCallback> actions;
  final bool autoPlay;

  const KeypadInstructionWrapper({
    super.key,
    required this.child,
    this.audioAsset,
    this.ttsInstructions,
    required this.actions,
    this.autoPlay = true,
  });

  @override
  State<KeypadInstructionWrapper> createState() => _KeypadInstructionWrapperState();
}

class _KeypadInstructionWrapperState extends State<KeypadInstructionWrapper> {
  late AudioPlayer _audioPlayer;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    
    if (widget.autoPlay && widget.audioAsset != null) {
      _playInstructions();
    }
    
    // Ensure we have focus to capture key events
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  Future<void> _playInstructions() async {
    try {
      if (widget.audioAsset != null) {
        await _audioPlayer.play(AssetSource(widget.audioAsset!));
      } else if (widget.ttsInstructions != null) {
        await TtsService.speak(widget.ttsInstructions!);
      }
    } catch (e) {
      debugPrint('Error playing instructions: $e');
      // Fallback to TTS if audio player fails
      if (widget.ttsInstructions != null) {
        TtsService.speak(widget.ttsInstructions!);
      }
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  bool _isTextInputFocused() {
    final focus = FocusManager.instance.primaryFocus;
    if (focus == null || !focus.hasPrimaryFocus) return false;
    if (focus == _focusNode) return false; // Wrapper itself has focus, not an input

    final context = focus.context;
    if (context == null) return false;

    bool foundInput = false;
    // Check the widget itself
    final widget = context.widget;
    final type = widget.runtimeType.toString();
    if (type.contains('EditableText') || type.contains('TextField') || type.contains('TextFormField')) {
      return true;
    }

    // Sometimes the focus is on a descendant of the EditableText
    context.visitAncestorElements((element) {
      final w = element.widget;
      final t = w.runtimeType.toString();
      if (t.contains('EditableText') || t.contains('TextField') || t.contains('TextFormField')) {
        foundInput = true;
        return false; // Stop searching
      }
      return true;
    });

    return foundInput;
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    // Check if we should ignore numeric shortcuts because the user is typing
    if (_isTextInputFocused()) {
      return KeyEventResult.ignored;
    }

    final key = event.logicalKey;
    
    // Handle numeric keys (1-9, 0)
    if (widget.actions.containsKey(key)) {
      widget.actions[key]?.call();
      return KeyEventResult.handled;
    }
    
    // Handle Numpad keys by mapping them to Digit keys
    final numpadToDigit = {
      LogicalKeyboardKey.numpad1: LogicalKeyboardKey.digit1,
      LogicalKeyboardKey.numpad2: LogicalKeyboardKey.digit2,
      LogicalKeyboardKey.numpad3: LogicalKeyboardKey.digit3,
      LogicalKeyboardKey.numpad4: LogicalKeyboardKey.digit4,
      LogicalKeyboardKey.numpad5: LogicalKeyboardKey.digit5,
      LogicalKeyboardKey.numpad6: LogicalKeyboardKey.digit6,
      LogicalKeyboardKey.numpad7: LogicalKeyboardKey.digit7,
      LogicalKeyboardKey.numpad8: LogicalKeyboardKey.digit8,
      LogicalKeyboardKey.numpad9: LogicalKeyboardKey.digit9,
      LogicalKeyboardKey.numpad0: LogicalKeyboardKey.digit0,
    };

    if (numpadToDigit.containsKey(key)) {
      final digitKey = numpadToDigit[key]!;
      if (widget.actions.containsKey(digitKey)) {
        widget.actions[digitKey]?.call();
        return KeyEventResult.handled;
      }
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      onKeyEvent: _handleKeyEvent,
      autofocus: true,
      child: widget.child,
    );
  }
}
