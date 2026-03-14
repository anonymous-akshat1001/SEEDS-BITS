import 'package:flutter/services.dart';

/// Standard T9 / multi-tap letter → digit mapping.
///
/// On keypad phones (e.g. Blackzone Winx 4G), pressing physical button "2"
/// emits letter key events (d, e, f or a, b, c depending on the phone)
/// before cycling to the digit character.  This map lets us resolve any
/// letter to its parent digit instantly, so we can fire the shortcut action
/// on the **first** key-down rather than waiting for the user to cycle to
/// the digit.
const Map<String, int> _letterToDigit = {
  // Button 2
  'a': 2, 'b': 2, 'c': 2,
  // Button 3
  'd': 3, 'e': 3, 'f': 3,
  // Button 4
  'g': 4, 'h': 4, 'i': 4,
  // Button 5
  'j': 5, 'k': 5, 'l': 5,
  // Button 6
  'm': 6, 'n': 6, 'o': 6,
  // Button 7
  'p': 7, 'q': 7, 'r': 7, 's': 7,
  // Button 8
  't': 8, 'u': 8, 'v': 8,
  // Button 9
  'w': 9, 'x': 9, 'y': 9, 'z': 9,
};

/// Map from [LogicalKeyboardKey] labels to digit values for digit & numpad keys.
final Map<LogicalKeyboardKey, int> _directDigitKeys = {
  LogicalKeyboardKey.digit0: 0,
  LogicalKeyboardKey.digit1: 1,
  LogicalKeyboardKey.digit2: 2,
  LogicalKeyboardKey.digit3: 3,
  LogicalKeyboardKey.digit4: 4,
  LogicalKeyboardKey.digit5: 5,
  LogicalKeyboardKey.digit6: 6,
  LogicalKeyboardKey.digit7: 7,
  LogicalKeyboardKey.digit8: 8,
  LogicalKeyboardKey.digit9: 9,
  LogicalKeyboardKey.numpad0: 0,
  LogicalKeyboardKey.numpad1: 1,
  LogicalKeyboardKey.numpad2: 2,
  LogicalKeyboardKey.numpad3: 3,
  LogicalKeyboardKey.numpad4: 4,
  LogicalKeyboardKey.numpad5: 5,
  LogicalKeyboardKey.numpad6: 6,
  LogicalKeyboardKey.numpad7: 7,
  LogicalKeyboardKey.numpad8: 8,
  LogicalKeyboardKey.numpad9: 9,
};

/// Resolves a key event to its digit (0-9), or `null` if the key isn't
/// digit-related.
///
/// Resolution order:
/// 1. Direct digit / numpad key  → immediate digit
/// 2. `event.character` is '0'-'9' → that digit (some phones report the
///    character even when the logical key is a letter)
/// 3. Letter key (a-z) → T9 digit via [_letterToDigit]
///
/// The [character] parameter should be [KeyEvent.character] (nullable).
int? resolveKeyToDigit(LogicalKeyboardKey key, String? character) {
  // 1. Standard digit / numpad keys
  final direct = _directDigitKeys[key];
  if (direct != null) return direct;

  // 2. Character-based resolution (covers phones that report '2' as the
  //    character even when logicalKey is something unexpected)
  if (character != null && character.length == 1) {
    final code = character.codeUnitAt(0);
    // '0' = 48, '9' = 57
    if (code >= 48 && code <= 57) return code - 48;

    // Also try letter resolution via character in case logicalKey is wrong
    final fromChar = _letterToDigit[character.toLowerCase()];
    if (fromChar != null) return fromChar;
  }

  // 3. Letter logical key → T9 digit
  //    LogicalKeyboardKey.keyA has keyLabel 'A', keyB has 'B', etc.
  final label = key.keyLabel;
  if (label.length == 1) {
    final fromLabel = _letterToDigit[label.toLowerCase()];
    if (fromLabel != null) return fromLabel;
  }

  return null;
}

/// Special key resolution for the * (star/asterisk) key.
/// Returns true if the key event represents the asterisk/star button.
bool isStarKey(LogicalKeyboardKey key) {
  return key == LogicalKeyboardKey.asterisk ||
      key == LogicalKeyboardKey.numpadMultiply;
}

/// Special key resolution for the # (hash/pound) key.
bool isHashKey(LogicalKeyboardKey key) {
  return key == LogicalKeyboardKey.numberSign;
}
