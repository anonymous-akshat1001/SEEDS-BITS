/// Spoken text for sign-in, registration and password screens.
abstract final class AuthText {
  static const loginSuccessful = 'Login successful';
  static String roleAlreadySelected(String role) => '$role account already selected';
  static String roleSelected(String role) => '$role account selected';
  static String recoveryStep(int number, String step) => 'Step $number. $step';
  static const enterPhone = 'Enter phone number';
  static const enterPassword = 'Enter password';
  static const enterName = 'Enter name';
  static const registering = 'Registering, please wait.';
  static const passwordChanged = 'Password changed. Signed in.';
}
