# Class, Subject, and Playlist Rollout

This release includes a data-preserving Alembic migration for existing
databases and a separate destructive reset command for disposable databases.

## 1. Configure production-safe authentication

Copy the relevant values from `.env.example` into the deployment environment. In production, keep:

```text
ALLOW_DEV_USER_IMPERSONATION=false
```

Generate a long, private `JWT_SECRET`. Do not place the Firebase service-account JSON or any real password in the repository.

## 2. Set the one-time bootstrap administrator

Set `BOOTSTRAP_ADMIN_NAME`, `BOOTSTRAP_ADMIN_PHONE`, and a password of at least
eight characters in the backend process environment. Startup creates the
administrator only when the configured phone number does not already exist; it
does not overwrite the password of an existing administrator. Public
registration cannot create administrators.

## 3. Upgrade an existing database

From the repository root, run:

```powershell
alembic upgrade head
```

The migration creates explicit class-subject associations, backfills pairs
from sessions, audio, and teacher assignments, and preserves historical data.
If it reports invalid legacy references, repair those records and rerun the
migration.

## 4. Reset and seed a disposable database

From the repository root, run:

```powershell
python -m backend.reset_db --confirm-reset
```

The command refuses to run without the explicit confirmation flag. It drops all SEEDS tables, recreates them, seeds LKG, UKG, Classes 1–12, and English, Maths, and Science, then creates the bootstrap administrator.

Remove the bootstrap password from reusable shell profiles after the command completes.

## 5. Configure catalog associations and accounts

Sign in as the bootstrap administrator. Use the accessible Admin Dashboard to:

1. configure the active subjects for every class;
2. assign every student to exactly one class;
3. assign each teacher to one or more valid class-subject workspaces;
4. review the All, Enrolled/Assigned, and Unassigned filters; and
5. archive or restore catalog entries, associations, and assignments as
   required.

Students without an active class and teachers without an active workspace are intentionally denied class-sensitive content.

## 6. Deployment checks

- Serve the API and authenticated audio streams over HTTPS.
- Confirm Firebase notifications contain only eligible same-class recipients.
- Run `pytest`, `flutter analyze`, and `flutter test`.
- Manually verify administrator, teacher, and student paths on a BlackZone keypad device and a mainstream Android device.
- Verify cross-class session, chat, SSE, invitation, notification, audio-stream, and playlist URLs return 403 or 404 as appropriate.
