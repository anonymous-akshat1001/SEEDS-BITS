# Spoken-text translations

Everything SEEDS says through text-to-speech comes from the ARB files in this
folder. Speech language is chosen in **Settings → Speech language**, and the app uses the matching
text-to-speech voice.

| File | Language | Voice |
| --- | --- | --- |
| `app_en.arb` | English (source, complete) | `en-IN` (falls back to `en-US`) |
| `app_hi.arb` | Hindi | `hi-IN` |
| `app_kn.arb` | Kannada | `kn-IN` |
| `app_te.arb` | Telugu | `te-IN` |
| `app_bn.arb` | Bengali | `bn-IN` |

## Adding translations

1. Copy a key and its English text from `app_en.arb` into the language file,
   then replace only the text:

   ```json
   {
     "@@locale": "hi",
     "settingsSaved": "सेटिंग्स सहेजी गईं"
   }
   ```

2. Keep every `{placeholder}` unchanged; you may move it within the sentence.
   Do not translate keys or entries that begin with `@`; `app_en.arb` keeps
   descriptions and placeholder details there.
3. Plurals use ICU syntax. Translate the text inside each branch; you may add
   branches that the language needs:

   ```json
   "spokenMinutes": "{count, plural, =1{1 मिनट} other{{count} मिनट}}"
   ```

4. Comma-separated lists (`spokenDigitWords`, `spokenMonths`,
   `spokenWeekdays`) must keep the same number of items, in the same order.
5. Run `flutter gen-l10n`; `flutter run` and `flutter build` also run it automatically.
6. Run `flutter test test/l10n_arb_test.dart`. It fails if a translation drops
   or renames a `{placeholder}`, has unbalanced braces, changes the number of
   items in a list, or uses a key that is not in `app_en.arb`.

Any message missing from a language file is spoken in English. After
generation, `untranslated.json` lists the remaining keys for each language.

Labels such as `5: Test speech` start with the keypad key to press; keep the
digit and the symbols `*` and `#` as they are.

## What stays in English

- Voice commands spoken by the user in a live session (`mute`, `raise hand`,
  …) are matched against English speech recognition.
- Text that comes from the server or from teachers (lesson titles, names,
  quiz questions) is spoken exactly as entered.

## Voices

The phone must have a text-to-speech voice for the chosen language. If none is
available, SEEDS switches back to English text and voice, then explains how to
install the voice. **Settings → Check voice** tests the selected language.

## Adding another language

1. Create `app_<code>.arb` containing `{"@@locale": "<code>"}`.
2. Add the language to `SpeechLanguage` in `speech.dart` with its voice locale.
3. Add its spoken name (`languageXxx`) to `app_en.arb` and update
   `TtsService.languageName`.

## For developers

Do not put spoken or displayed English directly in Dart code. Add a message to
`app_en.arb`, then use `Speech.t.yourKey` (import `lib/l10n/speech.dart`).
Write whole sentences with `{placeholders}` rather than joining English
fragments, so translators can reorder words. `Speech.t` needs no
`BuildContext`, so it also works in services and static getters; it cannot be
used inside `const` expressions.
Generated `app_localizations*.dart` files are overwritten by `flutter gen-l10n`;
do not edit them.
