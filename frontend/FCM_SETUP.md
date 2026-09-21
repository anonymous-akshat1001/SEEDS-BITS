# Enabling Firebase Cloud Messaging for SEEDS

The Android client is already wired for the Firebase project `seeds-bits` and
package `com.example.frontend`. The repository contains:

- `android/app/google-services.json`
- generated `lib/firebase_options.dart` Android/Web options
- the Google Services Gradle plugin
- `firebase_core`, `firebase_messaging`, and local-notification packages
- Android 13 notification permission and the `session_channel`
- foreground, background, terminated-launch, and token-refresh handlers
- backend token registration and session-invitation delivery endpoints

The missing production prerequisite is the backend service-account credential.
Apple platforms also still need to be registered and configured separately.

## 1. Confirm the Firebase project and Android app

1. Open Firebase Console and select `seeds-bits`.
2. In **Project settings > General > Your apps**, confirm an Android app exists
   with package name `com.example.frontend`.
3. Download a fresh `google-services.json` and replace
   `android/app/google-services.json` if the Firebase app was changed.
4. From this `frontend` directory, update the generated configuration:

   ```powershell
   firebase login
   dart pub global activate flutterfire_cli
   flutterfire configure --project=seeds-bits --platforms=android,web
   flutter pub get
   ```

Do not change the Android `applicationId` without also registering that new
package in Firebase and downloading a matching configuration file.

### If FlutterFire reports zero projects or an HTTP 401

Do not create another project. The checked-in client configuration already
targets `seeds-bits`. On Windows PowerShell, use the `.cmd` launcher to avoid
script-execution-policy errors:

```powershell
firebase.cmd logout
firebase.cmd login --reauth
firebase.cmd projects:list
```

If browser login cannot return to localhost, use:

```powershell
firebase.cmd login --reauth --no-localhost
```

Only after `seeds-bits` appears in `projects:list`, run:

```powershell
flutterfire configure --project=seeds-bits --platforms=android,web
```

If authentication succeeds but `seeds-bits` is absent, ask a project Owner to
add the signed-in Google account under **Project settings > Users and
permissions**. Creating `seeds-frontend` would produce a second, incompatible
Firebase project and should be cancelled.

## 2. Configure the backend sender credential

1. In Firebase Console, open **Project settings > Service accounts**.
2. Generate a new private key for a service account authorized to send FCM
   HTTP v1 messages.
3. Store the downloaded JSON outside the Git repository. Never put this private
   key in the Flutter app, commit it, or include it in an APK.
4. Set `FIREBASE_SERVICE_ACCOUNT_KEY` to its absolute path before starting the
   FastAPI backend. For the current PowerShell session:

   ```powershell
   $env:FIREBASE_SERVICE_ACCOUNT_KEY = 'C:\secure\seeds-bits-firebase.json'
   ```

5. Start the backend from the same environment. In production, configure this
   value through the host's secret manager or a read-only secret mount.
6. Confirm the startup log contains:

   ```text
   [FCM] Loaded credentials for project: seeds-bits
   ```

If it instead reports a credential-loading error, the backend can still run,
but it cannot send push notifications.

## 3. Register a device token

1. Use a physical Android phone with working Google Play services, or an
   emulator image that includes Google Play.
2. Install a fresh SEEDS build, open it once, and allow notifications when the
   Android permission prompt appears.
3. Log in. Before login, the client stores the device token locally; after
   login it sends that token to `POST /users/fcm-token` for the current user.
4. Confirm the backend returns `{"ok": true}` and that a row exists for the
   user in the `fcm_tokens` table.

On the BlackZone phone, first check for Google Mobile Services:

```powershell
adb shell pm list packages | Select-String 'com.google.android.gms'
```

If no package is returned, standard FCM cannot obtain a token on that device.
Use a GMS-enabled firmware/device or plan a non-FCM delivery channel.

## 4. Send an end-to-end test

For a basic transport test, use **Firebase Console > Messaging > Send test
message** and target the device registration token.

For the real SEEDS journey:

1. Log in as a student and confirm their token is registered.
2. Log in as a teacher on another device.
3. Create a session and invite the student.
4. The backend calls FCM HTTP v1 with these data fields:

   ```json
   {
     "type": "session_invitation",
     "session_id": "123",
     "session_title": "English Unit 5",
     "teacher_name": "Teacher name"
   }
   ```

5. Verify notification receipt with SEEDS foregrounded, backgrounded, and
   terminated. Tapping it should open the corresponding session route.
6. Log out and verify the token is unregistered/invalidated so the logged-out
   user no longer receives session invitations on that app installation.

## 5. Optional Apple setup

The current `firebase_options.dart` intentionally reports iOS/macOS as not
configured. To enable iOS:

1. Register the iOS bundle ID in Firebase and run `flutterfire configure` with
   `ios` selected.
2. Add the generated `GoogleService-Info.plist` to the Runner target in Xcode.
3. Enable **Push Notifications** and **Background Modes > Remote notifications**.
4. Upload an APNs authentication key in Firebase Console under
   **Project settings > Cloud Messaging**.
5. Test on a physical Apple device.

## Troubleshooting checklist

- Notification permission is enabled in Android Settings for SEEDS.
- The installed APK's package matches `google-services.json`.
- The device has network access and current Google Play services.
- `FIREBASE_SERVICE_ACCOUNT_KEY` points to a readable private JSON file.
- The service account and client config both belong to project `seeds-bits`.
- Login completed after the FCM token was generated.
- The backend stores the token for the intended user.
- Foreground notifications use channel ID `session_channel`.
- After force-stopping the app in Android Settings, reopen it once before
  testing again.

Official references:

- [Firebase for Flutter setup](https://firebase.google.com/docs/flutter/setup)
- [FCM setup for Flutter](https://firebase.google.com/docs/cloud-messaging/flutter/get-started)
- [Receiving FCM messages in Flutter](https://firebase.google.com/docs/cloud-messaging/flutter/receive-messages)
- [FCM HTTP v1 authorization](https://firebase.google.com/docs/cloud-messaging/send/v1-api)
