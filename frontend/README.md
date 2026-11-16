# frontend

Release Android artifacts must be named `SEEDS-v<version>.apk` (for example,
`SEEDS-v1.0.0.apk`) after `flutter build apk --release`.

Firebase Cloud Messaging setup and verification steps are documented in
[FCM_SETUP.md](FCM_SETUP.md).

## Physical keypad text entry

While a text field is focused, digits, star and hash belong to text entry.
Typing starts editing even without an initial OK press.
After editing, press OK/Enter to close text input and move to the next
non-text control (or the screen's keypad scope if there is none). The next
number key runs its screen action. Native keyboard Done also returns control
to the screen's keypad shortcuts. Use Up/Down to move between fields and
controls when more text needs to be entered.
On Android, leaving text input also restarts the native input connection so
T9 keyboards cannot keep consuming shortcut keys after the field loses focus.

## Speech languages

All text spoken by app speech lives in `lib/l10n/app_<language>.arb`
(English, Hindi, Kannada, Telugu, Bengali). Users choose the language in
Settings. To add or edit translations, see [lib/l10n/README.md](lib/l10n/README.md).

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
