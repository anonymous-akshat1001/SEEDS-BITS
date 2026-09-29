# Class, Subject, and Playlist Rollout

This release introduces destructive schema changes. Use it first on the current test database, not on a database whose data must be retained.

## 1. Configure production-safe authentication

Copy the relevant values from `.env.example` into the deployment environment. In production, keep:

```text
ALLOW_DEV_USER_IMPERSONATION=false
```

Generate a long, private `JWT_SECRET`. Do not place the Firebase service-account JSON or any real password in the repository.

## 2. Set the one-time bootstrap administrator

Set `BOOTSTRAP_ADMIN_NAME`, `BOOTSTRAP_ADMIN_PHONE`, and a password of at least eight characters in the backend process environment. These values are consumed only by the reset command.

## 3. Reset and seed the test database

From the repository root, run:

```powershell
python -m backend.reset_db --confirm-reset
```

The command refuses to run without the explicit confirmation flag. It drops all SEEDS tables, recreates them, seeds LKG, UKG, Classes 1–12, and English, Maths, and Science, then creates the bootstrap administrator.

Remove the bootstrap password from reusable shell profiles after the command completes.

## 4. Assign accounts before rollout

Sign in as the bootstrap administrator. Use the accessible Admin Dashboard to:

1. assign every student to exactly one class;
2. assign each teacher to one or more class-subject workspaces;
3. review the unassigned-account filter;
4. archive or restore catalogue entries and teacher assignments as required.

Students without an active class and teachers without an active workspace are intentionally denied class-sensitive content.

## 5. Deployment checks

- Serve the API and authenticated audio streams over HTTPS.
- Confirm Firebase notifications contain only eligible same-class recipients.
- Run `pytest`, `flutter analyze`, and `flutter test`.
- Manually verify administrator, teacher, and student paths on a BlackZone keypad device and a mainstream Android device.
- Verify cross-class session, chat, SSE, invitation, notification, audio-stream, and playlist URLs return 403 or 404 as appropriate.
