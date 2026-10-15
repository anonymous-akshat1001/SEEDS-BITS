# Backend Deployment Runbook

This runbook deploys the backend from a Windows development machine to:

```text
/home/seeds/backend
```

The internal server is reached through the campus jump server:

```text
Windows -> seeds@182.75.45.22:10022 -> seeds@172.16.108.26
```

The production service is `seeds-backend.service`. It runs one Uvicorn worker
from `/home/seeds/backend/venv310` and advertises `/seeds` as its public root
path.

## Production assets that must not be overwritten

The deployment commands preserve:

- `/home/seeds/.env`
- `/home/seeds/backend/data/`
- `/home/seeds/backend/venv/`
- `/home/seeds/backend/venv310/`
- `/home/seeds/backend/seeds-bits-firebase.json`
- other Firebase service-account JSON files

Never copy a development `.env`, database dump, private key, Firebase
credential, or local audio directory into the deployment archive.

## 1. Validate the backend locally

From PowerShell:

```powershell
Set-Location C:\dev\SEEDS

.\.venv\Scripts\Activate.ps1
python -m pytest backend\tests
```

Do not deploy if the relevant tests fail.

## 2. Create the deployment archive

Run from PowerShell:

```powershell
Set-Location C:\dev\SEEDS

$DeployArchive = "$env:TEMP\seeds-backend-deploy.tar.gz"

Remove-Item $DeployArchive -ErrorAction SilentlyContinue

tar -czf $DeployArchive `
  --exclude=backend/data `
  --exclude=backend/tests `
  --exclude=backend/__pycache__ `
  --exclude=backend/.pytest_cache `
  --exclude=backend/venv `
  --exclude=backend/venv310 `
  --exclude=backend/.venv `
  --exclude=backend/*.pyc `
  --exclude=backend/*firebase*.json `
  --exclude=backend/*service-account*.json `
  --exclude=backend/*service_account*.json `
  backend alembic.ini

Get-Item $DeployArchive
```

This packages the current working-tree files, including uncommitted backend
changes. Review and commit the intended changes before deployment whenever
possible.

## 3. Upload through the jump server

Run from PowerShell:

```powershell
scp -o ProxyJump=seeds@182.75.45.22:10022 `
  "$env:TEMP\seeds-backend-deploy.tar.gz" `
  seeds@172.16.108.26:/tmp/seeds-backend-deploy.tar.gz
```

Confirm the upload:

```powershell
ssh -J seeds@182.75.45.22:10022 seeds@172.16.108.26 `
  "ls -lh /tmp/seeds-backend-deploy.tar.gz"
```

Connect to the backend server:

```powershell
ssh -J seeds@182.75.45.22:10022 seeds@172.16.108.26
```

All remaining commands in this runbook run on the backend server.

## 4. Verify and stage the archive

```bash
set -e

SERVICE=seeds-backend
ARCHIVE=/tmp/seeds-backend-deploy.tar.gz
STAGING=/tmp/seeds-backend-staging

test -f "$ARCHIVE" || {
  echo "ERROR: $ARCHIVE is missing"
  exit 1
}

rm -rf "$STAGING"
mkdir -p "$STAGING"
tar -xzf "$ARCHIVE" -C "$STAGING"

test -f "$STAGING/backend/main.py" || {
  echo "ERROR: backend/main.py is missing from the archive"
  exit 1
}

test -f "$STAGING/backend/requirements.txt" || {
  echo "ERROR: backend/requirements.txt is missing from the archive"
  exit 1
}

test -f "$STAGING/alembic.ini" || {
  echo "ERROR: alembic.ini is missing from the archive"
  exit 1
}
```

## 5. Confirm the production prerequisites

```bash
test -f /home/seeds/.env || {
  echo "ERROR: /home/seeds/.env is missing"
  exit 1
}

test -x /home/seeds/backend/venv310/bin/python || {
  echo "ERROR: the Python 3.10 virtual environment is missing"
  exit 1
}

/home/seeds/backend/venv310/bin/python --version
sudo systemctl cat "$SERVICE"
```

The effective `ExecStart` must use:

```text
/home/seeds/backend/venv310/bin/uvicorn
```

and include:

```text
--workers 1 --root-path /seeds
```

One worker is required because live session state is currently held in process
memory.

## 6. Prepare dependencies

Ubuntu 18.04 has FFmpeg libraries that are too old for the current PyAV pulled
in by `aiortc`. The backend currently has no `aiortc` imports, so production
installation excludes that unused dependency:

```bash
grep -v -E '^[[:space:]]*aiortc([=<>!~].*)?[[:space:]]*$' \
  "$STAGING/backend/requirements.txt" \
  > /tmp/seeds-production-requirements.txt

grep -iE 'aiortc|^[[:space:]]*av([=<>!~].*)?$' \
  /tmp/seeds-production-requirements.txt || \
  echo "aiortc and av are excluded"

/home/seeds/backend/venv310/bin/python -m pip install \
  -r /tmp/seeds-production-requirements.txt
```

If backend code starts using `aiortc`, do not continue excluding it. Upgrade
the server OS/FFmpeg stack and validate a compatible `aiortc`/PyAV installation
before deploying that change.

## 7. Back up the current deployment

```bash
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
BACKUP_DIR="/home/seeds/deployment-backups/$TIMESTAMP"

mkdir -p "$BACKUP_DIR"

rsync -a \
  --exclude='data/' \
  --exclude='venv/' \
  --exclude='venv310/' \
  --exclude='__pycache__/' \
  /home/seeds/backend/ \
  "$BACKUP_DIR/backend/"

if [ -f /home/seeds/alembic.ini ]; then
  cp /home/seeds/alembic.ini "$BACKUP_DIR/alembic.ini"
fi

echo "Code backup created at $BACKUP_DIR"
```

For a release with risky or irreversible database changes, also create a
PostgreSQL backup using the production database name:

```bash
sudo -u postgres pg_dump -Fc seeds_db > "$BACKUP_DIR/seeds_db.dump"
```

Replace `seeds_db` if production uses a different database name. Keep database
credentials and dumps out of the repository.

## 8. Stop the service and deploy

```bash
sudo systemctl stop "$SERVICE"
sudo systemctl is-active "$SERVICE"
```

The expected state is `inactive`.

Synchronize the code while preserving production data, credentials, and
virtual environments:

```bash
rsync -av --delete \
  --exclude='data/' \
  --exclude='.env' \
  --exclude='venv/' \
  --exclude='venv310/' \
  --exclude='.venv/' \
  --exclude='__pycache__/' \
  --exclude='*.pyc' \
  --exclude='*firebase*.json' \
  --exclude='*service-account*.json' \
  --exclude='*service_account*.json' \
  "$STAGING/backend/" \
  /home/seeds/backend/

install -m 644 "$STAGING/alembic.ini" /home/seeds/alembic.ini

sudo chown -R seeds:seeds /home/seeds/backend
sudo chown seeds:seeds /home/seeds/alembic.ini
```

## 9. Validate imports and apply migrations

```bash
cd /home/seeds/backend

/home/seeds/backend/venv310/bin/python -c \
  "import main; print('Backend import successful')"
```

A shell-only warning about a relative Firebase credential can be ignored if
`firebase.conf` configures the absolute credential path for the systemd
service. An import exception must be fixed before continuing.

Run data-preserving migrations from `/home/seeds`:

```bash
cd /home/seeds

/home/seeds/backend/venv310/bin/python -m alembic \
  -c /home/seeds/alembic.ini \
  upgrade head

/home/seeds/backend/venv310/bin/python -m alembic \
  -c /home/seeds/alembic.ini \
  current
```

Never run `backend.reset_db` in production.

## 10. Start and verify the service

```bash
sudo systemctl start "$SERVICE"

sleep 5

sudo systemctl status "$SERVICE" --no-pager
```

Confirm that it remains active rather than entering an automatic restart loop:

```bash
sleep 10
sudo systemctl is-active "$SERVICE"
```

The expected result is `active`.

Check the latest complete logs:

```bash
sudo journalctl -u "$SERVICE" -n 100 --no-pager -l
```

Test the local API:

```bash
curl --fail --show-error \
  http://127.0.0.1:8000/openapi.json \
  > /dev/null \
  && echo "Local API successful"
```

Test the public API and documentation:

```bash
curl --fail --show-error \
  https://responsible-tech.bits-hyderabad.ac.in/seeds/openapi.json \
  > /dev/null \
  && echo "Public OpenAPI successful"

curl --fail --show-error \
  https://responsible-tech.bits-hyderabad.ac.in/seeds/docs \
  > /dev/null \
  && echo "Public Swagger successful"
```

Open the Swagger UI:

```text
https://responsible-tech.bits-hyderabad.ac.in/seeds/docs
```

If Swagger tries to fetch `/openapi.json` instead of
`/seeds/openapi.json`, confirm that the systemd `ExecStart` still includes
`--root-path /seeds`, then run `sudo systemctl daemon-reload` and restart the
service.

## 11. Clean up after a successful deployment

```bash
rm -rf "$STAGING"
rm -f "$ARCHIVE"
rm -f /tmp/seeds-production-requirements.txt
```

Exit the server:

```bash
exit
```

Remove the local archive in PowerShell:

```powershell
Remove-Item "$env:TEMP\seeds-backend-deploy.tar.gz" -ErrorAction SilentlyContinue
```

## Roll back the code

Use the backup path printed during deployment:

```bash
SERVICE=seeds-backend
BACKUP_DIR=/home/seeds/deployment-backups/YYYYMMDD-HHMMSS

test -f "$BACKUP_DIR/backend/main.py" || {
  echo "ERROR: invalid backup directory"
  exit 1
}

sudo systemctl stop "$SERVICE"

rsync -av --delete \
  --exclude='data/' \
  --exclude='venv/' \
  --exclude='venv310/' \
  --exclude='__pycache__/' \
  --exclude='*.pyc' \
  --exclude='*firebase*.json' \
  --exclude='*service-account*.json' \
  --exclude='*service_account*.json' \
  "$BACKUP_DIR/backend/" \
  /home/seeds/backend/

if [ -f "$BACKUP_DIR/alembic.ini" ]; then
  cp "$BACKUP_DIR/alembic.ini" /home/seeds/alembic.ini
fi

sudo chown -R seeds:seeds /home/seeds/backend
sudo systemctl start "$SERVICE"
sudo systemctl status "$SERVICE" --no-pager
```

Code rollback does not automatically reverse database migrations. Restore a
database backup only when the release migration requires it and after
understanding how much production data would be lost.

## Troubleshooting

### Service reports `activating (auto-restart)`

Stop the restart loop and inspect the complete traceback:

```bash
sudo systemctl stop seeds-backend
sudo journalctl -u seeds-backend -n 150 --no-pager -l
```

### Bootstrap administrator configuration fails

The production `/home/seeds/.env` must configure:

```text
BOOTSTRAP_ADMIN_NAME
BOOTSTRAP_ADMIN_PHONE
BOOTSTRAP_ADMIN_PASSWORD
```

The password must contain at least eight characters. The configured phone must
not belong to an existing teacher or student. Do not print or commit the
password.

### PyAV fails to build

Confirm that `/tmp/seeds-production-requirements.txt` excludes the currently
unused `aiortc` dependency. Do not repeatedly install PyAV against Ubuntu
18.04's incompatible FFmpeg development libraries.

### Alembic cannot import `async_engine_from_config`

The command is using the obsolete Python 3.9 environment or an incomplete
dependency installation. Use:

```text
/home/seeds/backend/venv310/bin/python
```

and confirm that SQLAlchemy satisfies the version constraint in
`backend/requirements.txt`.
