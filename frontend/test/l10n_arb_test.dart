import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/l10n/speech.dart';

/// Guards the translator workflow: translations only need to be typed into
/// lib/l10n/app_<code>.arb, so mistakes there must fail loudly.
void main() {
  Map<String, dynamic> readArb(String code) =>
      jsonDecode(File('lib/l10n/app_$code.arb').readAsStringSync())
          as Map<String, dynamic>;

  final english = readArb('en');
  const lists = {
    'spokenDigitWords': 10,
    'spokenMonths': 12,
    'spokenWeekdays': 7,
  };

  Set<String> declared(String key) =>
      ((english['@$key'] as Map<String, dynamic>?)?['placeholders']
                  as Map<String, dynamic>? ??
              const {})
          .keys
          .toSet();

  // Minimal ICU reader: `{name}` and `{name, plural|select, case{text} ...}`
  // are placeholders; case bodies are messages that may hold more of them.
  Set<String> usedPlaceholders(String message) {
    final names = <String>{};
    var i = 0;
    void skipSpace() {
      while (i < message.length && message[i].trim().isEmpty) {
        i++;
      }
    }

    String readUntil(Pattern stop) {
      final start = i;
      while (i < message.length && !message[i].startsWith(stop)) {
        i++;
      }
      return message.substring(start, i).trim();
    }

    void readMessage({required bool nested}) {
      while (i < message.length) {
        final char = message[i];
        if (char == '}' && nested) return;
        i++;
        if (char != '{') continue;
        names.add(readUntil(RegExp('[,}]')));
        if (i < message.length && message[i] == ',') {
          i++;
          readUntil(RegExp('[,}]'));
          if (i < message.length && message[i] == ',') i++;
          while (true) {
            skipSpace();
            if (i >= message.length || message[i] == '}') break;
            readUntil('{');
            i++;
            readMessage(nested: true);
            i++;
          }
        }
        i++;
      }
    }

    readMessage(nested: false);
    return names;
  }

  for (final language in SpeechLanguage.values) {
    group('app_${language.code}.arb', () {
      final arb = readArb(language.code);
      final messages = {
        for (final entry in arb.entries)
          if (!entry.key.startsWith('@')) entry.key: entry.value,
      };

      test('declares its locale', () {
        expect(arb['@@locale'], language.code);
      });

      test('only translates keys that exist in app_en.arb', () {
        expect(
          messages.keys.where((key) => !english.containsKey(key)),
          isEmpty,
        );
      });

      test('keeps every placeholder and balanced braces', () {
        final problems = <String>[];
        messages.forEach((key, value) {
          if (value is! String) {
            problems.add('$key is not text');
            return;
          }
          var depth = 0;
          for (final char in value.split('')) {
            if (char == '{') depth++;
            if (char == '}' && --depth < 0) break;
          }
          if (depth != 0) problems.add('$key has unbalanced { }');
          final expected = declared(key);
          final used = usedPlaceholders(value);
          final missing = expected.difference(used);
          final unknown = used.difference(expected);
          if (missing.isNotEmpty) problems.add('$key is missing $missing');
          if (unknown.isNotEmpty) problems.add('$key has unknown $unknown');
        });
        expect(problems, isEmpty);
      });

      test('keeps the number of items in comma-separated lists', () {
        lists.forEach((key, count) {
          final value = messages[key] as String? ?? english[key] as String;
          expect(value.split(',').length, count, reason: key);
        });
      });

      test('is spoken through Speech.t with English fallback', () {
        final previous = Speech.language;
        addTearDown(() => Speech.language = previous);
        Speech.language = language;
        expect(Speech.t.localeName, language.code);
        expect(
          Speech.t.settingsSaved,
          messages['settingsSaved'] ?? english['settingsSaved'],
        );
      });
    });
  }
}
