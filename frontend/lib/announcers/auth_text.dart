import '../l10n/speech.dart';

/// Spoken text for sign-in, registration and password screens.
abstract final class AuthText {
  static String get loginSuccessful => Speech.t.authLoginSuccessful;
  static String roleAlreadySelected(String role) =>
      Speech.t.authRoleAlreadySelected(role);
  static String roleSelected(String role) => Speech.t.authRoleSelected(role);
  static String recoveryStep(int number, String step) =>
      Speech.t.authRecoveryStep('$number', step);
  static String get enterPhone => Speech.t.authEnterPhone;
  static String get enterPassword => Speech.t.authEnterPassword;
  static String get enterName => Speech.t.authEnterName;
  static String get registering => Speech.t.authRegistering;
  static String get passwordChanged => Speech.t.authPasswordChanged;
}