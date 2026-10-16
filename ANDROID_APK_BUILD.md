# Android APK Build Runbook

This runbook builds the SEEDS Flutter application into an Android APK from a
Windows development machine.

## Current Android configuration

- Flutter project: `frontend/`
- Android application ID: `com.example.frontend`
- Application version: defined in `frontend/pubspec.yaml`
- Firebase Android configuration:
  `frontend/android/app/google-services.json`
- Runtime environment: `frontend/assets/.env`

The current Android Gradle configuration signs release builds with Flutter's
debug signing key. These APKs are suitable for testing and direct installation,
but not for Google Play or formal production distribution. Configure a private
release keystore before publishing the application.

## 1. Open the frontend project

Run in PowerShell:

```powershell
Set-Location C:\dev\SEEDS\frontend
```

## 2. Verify the production environment

```powershell
Get-Content .\assets\.env
```

The deployment configuration should contain:

```env
API_BASE_URL=https://responsible-tech.bits-hyderabad.ac.in/seeds
WS_BASE_URL=wss://responsible-tech.bits-hyderabad.ac.in/seeds
WEB_VAPID_KEY=your-firebase-web-vapid-public-key
```

Do not use `/docs` as the API URL and do not add a trailing slash.

The VAPID public key may be bundled into the application. Never place a
Firebase service-account JSON, private key, database password, JWT secret, or
other backend credential in the Flutter environment.

## 3. Check the build tools

```powershell
flutter --version
flutter doctor
flutter devices
```

Resolve Android toolchain errors reported by `flutter doctor` before building.

## 4. Clean and restore dependencies

```powershell
flutter clean
flutter pub get
```

Do not run `flutter pub upgrade` merely to create a build. It can change locked
dependency versions and should be handled as a separate tested change.

## 5. Validate the application

```powershell
flutter analyze
flutter test
```

Fix analyzer errors and test failures before creating a distributable APK.

## 6. Choose the application version

The default version is defined in `frontend/pubspec.yaml`:

```yaml
version: 1.0.0+1
```

The value before `+` is Android's version name. The number after `+` is the
version code.

Every update installed over an existing release should have a higher build
number. The build command can override both values without editing
`pubspec.yaml`.

Example:

```powershell
$BuildName = "1.0.0"
$BuildNumber = "2"
```

## 7. Build one universal APK

A universal APK supports all bundled Android CPU architectures but is larger
than architecture-specific APKs:

```powershell
$BuildName = "1.0.0"
$BuildNumber = "2"

flutter build apk `
  --release `
  --build-name $BuildName `
  --build-number $BuildNumber
```

Output:

```text
C:\dev\SEEDS\frontend\build\app\outputs\flutter-apk\app-release.apk
```

Open the output directory:

```powershell
Invoke-Item .\build\app\outputs\flutter-apk
```

## 8. Alternatively, build smaller architecture-specific APKs

Use this instead of the universal build when separate APKs are acceptable:

```powershell
$BuildName = "1.0.0"
$BuildNumber = "2"

flutter build apk `
  --release `
  --split-per-abi `
  --build-name $BuildName `
  --build-number $BuildNumber
```

Outputs:

```text
build\app\outputs\flutter-apk\app-arm64-v8a-release.apk
build\app\outputs\flutter-apk\app-armeabi-v7a-release.apk
build\app\outputs\flutter-apk\app-x86_64-release.apk
```

Most current physical Android phones use `arm64-v8a`. Check a connected
device:

```powershell
adb shell getprop ro.product.cpu.abi
```

## 9. Install the APK on a connected device

Enable USB debugging on the device and confirm that ADB can see it:

```powershell
adb devices
```

Install or update the universal APK:

```powershell
adb install -r `
  .\build\app\outputs\flutter-apk\app-release.apk
```

For an ARM64 split APK:

```powershell
adb install -r `
  .\build\app\outputs\flutter-apk\app-arm64-v8a-release.apk
```

If Android reports a signing-certificate conflict, the installed application
was signed with a different key. Uninstalling it deletes its local application
data:

```powershell
adb uninstall com.example.frontend
adb install .\build\app\outputs\flutter-apk\app-release.apk
```

## 10. Verify the installed application

After installation:

1. Open SEEDS.
2. Confirm login reaches the public backend.
3. Test both teacher and student dashboards.
4. Confirm classes, subjects, sessions, and audio load.
5. Allow notifications and verify FCM token registration.
6. Test a session invitation and any required WebSocket/SSE behavior.

Useful device logs:

```powershell
adb logcat
```

Filter Flutter and application messages:

```powershell
adb logcat | Select-String "flutter|com.example.frontend|FIREBASE|FCM"
```

Stop log output with `Ctrl+C`.

## 11. Generate a checksum

Generate and record a SHA-256 checksum before distributing an APK:

```powershell
Get-FileHash `
  .\build\app\outputs\flutter-apk\app-release.apk `
  -Algorithm SHA256
```

Recipients can use the checksum to confirm that the APK was transferred
without modification.

## Production signing

The current `frontend/android/app/build.gradle.kts` contains:

```kotlin
signingConfig = signingConfigs.getByName("debug")
```

Before publishing:

1. Generate a private Android upload/release keystore.
2. Store it outside the Git repository.
3. Keep aliases and passwords outside source control.
4. Configure a release signing profile in Gradle.
5. Back up the keystore securely. Losing it can prevent future application
   updates.
6. Use an Android App Bundle for Google Play:

   ```powershell
   flutter build appbundle `
     --release `
     --build-name $BuildName `
     --build-number $BuildNumber
   ```

The App Bundle output is:

```text
build\app\outputs\bundle\release\app-release.aab
```

Do not commit `.jks`, `.keystore`, `key.properties`, passwords, or other
signing material.

## Common failures

### Flutter cannot delete an `ephemeral` or `.plugin_symlinks` directory

A running Flutter debug session, browser launched by Flutter, IDE task, or
other process may still hold generated desktop files open.

1. In every terminal running `flutter run`, press `q` and wait for it to exit.
2. Close browsers launched by those Flutter sessions.
3. Close any File Explorer window displaying a generated `ephemeral` folder.
4. From `frontend/`, remove only the generated platform directories:

   ```powershell
   Remove-Item -LiteralPath .\windows\flutter\ephemeral `
     -Recurse -Force -ErrorAction SilentlyContinue
   Remove-Item -LiteralPath .\macos\Flutter\ephemeral `
     -Recurse -Force -ErrorAction SilentlyContinue
   Remove-Item -LiteralPath .\ios\Flutter\ephemeral `
     -Recurse -Force -ErrorAction SilentlyContinue
   ```

5. Restore dependencies:

   ```powershell
   flutter pub get
   ```

These directories contain generated files and will be recreated when needed.
If Windows still reports that a directory is in use, restart Windows, then run
`flutter pub get` before reopening a Flutter debug session.

### The application still uses an old backend URL

Confirm `frontend/assets/.env`, then rebuild from a clean state:

```powershell
flutter clean
flutter pub get
flutter build apk --release
```

Environment assets are bundled at build time. Hot reload does not update an
already distributed APK.

### Firebase initialization fails

Confirm that `frontend/android/app/google-services.json` belongs to the
Firebase project used by the backend and contains the Android application
`com.example.frontend`.

### Installation reports `INSTALL_FAILED_UPDATE_INCOMPATIBLE`

The installed APK uses a different signing key. Uninstall the old application
or rebuild with the same signing key that signed the installed version.

### Installation reports a lower version code

Rebuild with a larger `--build-number`.

### Build output contains stale files

Run:

```powershell
flutter clean
flutter pub get
```

Then rebuild the APK.
