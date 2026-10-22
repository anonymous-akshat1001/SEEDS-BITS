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
and advertises `/seeds` as its public root path. The previously configured
environment is `/home/seeds/backend/venv310`; the Python 3.11 environment
confirmed working on this VM is **`/home/seeds/.venv-seeds311`**. Reuse it;
do not create another environment under the permission-restricted backend
directory. Keep the previous environment for rollback. Creating or activating
an environment does not switch systemd; verify its effective command separately.

The backend requires **Python 3.10 or newer**. On the Ubuntu 18.04.6 VM,
unqualified `python` currently invokes Python 2.7.17. Do not use that interpreter
for SEEDS, remove the system Python, or repoint `/usr/bin/python` or
`/usr/bin/python3`. Install the newer version alongside them.

## Production assets that must not be overwritten

The deployment commands preserve:

- `/home/seeds/.env`
- `/home/seeds/.venv-seeds311/` (outside the backend archive and sync target)
- `/home/seeds/backend/data/`
- `/home/seeds/backend/venv/`
- `/home/seeds/backend/venv310/`
- `/home/seeds/backend/venv311/`
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
  --exclude=backend/venv311 `
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

sudo rm -rf "$STAGING"
sudo install -d -o seeds -g seeds -m 755 "$STAGING"
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

### 5.1 Install Python 3.11 on Ubuntu 18.04 if needed

Skip compilation if a supported interpreter and working environment already
exist. These commands run on the **Ubuntu VM**, not Windows. Ubuntu 18.04 is
outside standard support; plan a supported OS upgrade separately. Installing
Python does not update or secure the rest of the OS.

Check available interpreters first:

```bash
python --version
python3 --version
command -v python3.11
```

If Python 3.11 is unavailable, install build dependencies:

```bash
sudo apt update
sudo apt install -y \
  build-essential curl ca-certificates \
  libssl-dev zlib1g-dev libbz2-dev \
  libreadline-dev libsqlite3-dev \
  libffi-dev liblzma-dev libncursesw5-dev \
  xz-utils tk-dev uuid-dev
```

Stop on repository, package or certificate errors; do not disable signature or
TLS verification. Use the approved Ubuntu repositories/security-support
configuration for this VM.

Download a maintained Python 3.11 source release from the
[official source releases page](https://www.python.org/downloads/source/).
The example uses 3.11.17; review the current release and its published
verification information before installation.

```bash
mkdir -p "$HOME/python-build"
cd "$HOME/python-build"

curl --fail --location --output Python-3.11.17.tgz \
  https://www.python.org/ftp/python/3.11.17/Python-3.11.17.tgz
tar -xzf Python-3.11.17.tgz
cd Python-3.11.17

./configure --with-ensurepip=install
make -j2
sudo make altinstall
```

Run each command only after the preceding one succeeds. `make altinstall`
installs the versioned interpreter without replacing Ubuntu's default Python.
Compilation can take several minutes.

Verify the interpreter, HTTPS support and required standard-library modules:

```bash
/usr/local/bin/python3.11 --version
/usr/local/bin/python3.11 -c \
  "import ssl, sqlite3, bz2, lzma, ctypes; print('Python modules OK'); print(ssl.OPENSSL_VERSION)"
/usr/local/bin/python3.11 -m pip --version
```

Do not continue if a module is missing. Python 3.11 requires OpenSSL 1.1.1 or
newer; an outdated `libssl-dev` can leave the interpreter without working SSL.
Resolve the supported OS/dependency configuration and rebuild rather than
bypassing HTTPS verification.

The VM already has `/home/seeds/.venv-seeds311`. Verify and reuse it:

```bash
/home/seeds/.venv-seeds311/bin/python --version
/home/seeds/.venv-seeds311/bin/python -m pip --version
```

**Only on a fresh server where that directory does not exist**, create it as
the `seeds` user:

```bash
python3.11 -m venv /home/seeds/.venv-seeds311
```

If the directory exists but its interpreter is missing or broken, stop and
inspect it rather than overwriting it. Do not use `sudo pip`, change backend
ownership, or recreate a working environment to resolve a path/permission error.

Do not copy packages from an old environment. Install production requirements
with the selected interpreter in step 6, including the Ubuntu 18.04 PyAV
workaround. Do not install the unfiltered requirements on this VM.

### 5.2 Select and verify the deployment environment

For the confirmed Python 3.11 environment:

```bash
VENV=/home/seeds/.venv-seeds311
PYTHON="$VENV/bin/python"
```

If retaining the existing supported Python 3.10 environment instead, set
`VENV=/home/seeds/backend/venv310` and then `PYTHON="$VENV/bin/python"`.
Set these variables again if reconnecting to the server. Explicit interpreter
paths below do not depend on virtual-environment activation.

```bash
test -f /home/seeds/.env || {
  echo "ERROR: /home/seeds/.env is missing"
  exit 1
}

test -x "$PYTHON" || {
  echo "ERROR: the selected Python environment is missing"
  exit 1
}

"$PYTHON" --version
"$PYTHON" -c \
  "import sys, ssl; assert sys.version_info >= (3, 10), 'Python 3.10+ required'; print(sys.executable); print(ssl.OPENSSL_VERSION)"
sudo systemctl cat "$SERVICE"
```

The effective `ExecStart` must use the selected environment, for example:

```text
/home/seeds/.venv-seeds311/bin/uvicorn
```

and include:

```text
--workers 1 --root-path /seeds
```

One worker is required because live session state is currently held in process
memory.

When switching environments, prepare dependencies first. At the maintenance
window in step 8, stop the service and use `sudo systemctl edit "$SERVICE"`.
Override `ExecStart` with an empty `ExecStart=` followed by a replacement line.
Copy the existing complete command and change **only its interpreter/executable
path** to the selected environment. Preserve the application target, binding,
port, working directory, environment/Firebase configuration, worker count and
root path. Then run `sudo systemctl daemon-reload` and inspect
`sudo systemctl cat "$SERVICE"` again before starting it. Shell variables such
as `$VENV` are not expanded in a systemd unit; use the literal absolute path.
Record the previous effective command for rollback.

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

"$PYTHON" -m pip install --upgrade pip
"$PYTHON" -m pip install \
  -r /tmp/seeds-production-requirements.txt
"$PYTHON" -m pip check
"$PYTHON" -c \
  "import ssl; from dotenv import load_dotenv; print('Python and dotenv are ready')"
```

Run each command only after the previous one succeeds. Install and run with
the same `$PYTHON`: `dotenv` is supplied by `python-dotenv` in the requirements,
not by a package named `dotenv`. Do not continue to migrations or service startup
if installation, dependency checks or imports fail.

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
  --exclude='venv311/' \
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
  --exclude='venv311/' \
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

"$PYTHON" -c \
  "import main; print('Backend import successful')"
```

A shell-only warning about a relative Firebase credential can be ignored if
`firebase.conf` configures the absolute credential path for the systemd
service. An import exception must be fixed before continuing.

Run data-preserving migrations from `/home/seeds`:

```bash
cd /home/seeds

"$PYTHON" -m alembic \
  -c /home/seeds/alembic.ini \
  upgrade head

"$PYTHON" -m alembic \
  -c /home/seeds/alembic.ini \
  current
```

Never run `backend.reset_db` in production.

The migration configuration is `/home/seeds/alembic.ini`, **not**
`/home/seeds/backend/alembic.ini`. Run Alembic from `/home/seeds`, as shown,
because its script paths are relative to the repository root.

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
sudo rm -rf "$STAGING"
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
  --exclude='venv311/' \
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
If deployment switched Python environments, also restore the recorded previous
systemd executable path and run `sudo systemctl daemon-reload` before restarting.
The old environment must still contain dependencies compatible with that code.

## Troubleshooting

### Missing `backend/venv311`, permission denied, or SSH disconnect

`/home/seeds/backend/venv311` is not the working environment on this VM.
Creating it failed because the `seeds` user could not write to that location.
Use the existing environment instead:

```bash
SERVICE=seeds-backend
VENV=/home/seeds/.venv-seeds311
PYTHON="$VENV/bin/python"
"$PYTHON" --version
source "$VENV/bin/activate"
which python
python -m pip --version
```

The Python and pip paths must point inside `/home/seeds/.venv-seeds311`.
Assignments such as `VENV=...` define paths; they do not create environments.
No backend ownership change or second environment is necessary.

With `set -e`, a failed command in an interactive SSH shell can terminate the
shell and close the connection. Reconnect using step 3, then troubleshoot
commands individually **without `set -e`** (or run `set +e` in an existing
shell). Stop manually after any failed check; do not continue deployment with
missing prerequisites. Restore the step 4 variables when resuming deployment.

### `ModuleNotFoundError: No module named 'dotenv'`

Python 3 is running, but the selected interpreter lacks backend dependencies.
Select `/home/seeds/.venv-seeds311` as above and complete step 6 with that
interpreter, including the filtered Ubuntu 18.04 requirements and import check.
Installing packages in another environment or activating an empty environment
does not resolve the missing dependency. A database reset is not a remedy.

### `SyntaxError` in `reset_db.py`, with `/usr/lib/python2.7/runpy.py`

The command used system Python 2.7, which cannot parse SEEDS's Python 3 syntax.
Do not rewrite the source for Python 2 or change system interpreter symlinks.
Use the verified `$PYTHON` path selected in step 5.

For routine production upgrades, run the data-preserving Alembic commands in
step 9. **Reset deletes existing database data** and is not a deployment step.
Only on a disposable development/test database, with confirmed target
configuration and bootstrap administrator variables, use:

```bash
cd /home/seeds
"$PYTHON" -m backend.reset_db --confirm-reset
```

For an interactive shell, optional activation is:

```bash
source "$VENV/bin/activate"
python --version
```

Activation affects only that shell, not systemd or subsequent SSH sessions.

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

The command may be using an old or incomplete SQLAlchemy installation. Check
the selected interpreter rather than assuming the shell's `python` is correct:

```bash
"$PYTHON" --version
"$PYTHON" -c "import sqlalchemy; print(sqlalchemy.__version__); print(sqlalchemy.__file__)"
"$PYTHON" -m pip check
```

Confirm that SQLAlchemy satisfies the version constraint in
`backend/requirements.txt`.
