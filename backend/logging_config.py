"""Content-free diagnostics: bodies, URLs, exception messages and bind values are excluded."""

import json
import logging
import os
import time
import traceback
from contextvars import ContextVar
from datetime import datetime, timezone
from logging.handlers import TimedRotatingFileHandler
from pathlib import Path
from uuid import uuid4

request_id = ContextVar("request_id", default=None)
HEALTH = {"requests": 0, "errors": 0, "last_error_at": None}


class SafeFormatter(logging.Formatter):
    def format(self, record):
        # Only constant event codes are accepted; third-party text can contain secrets.
        code = getattr(record, "event_code", None)
        if code is None:
            code = "library_diagnostic"
        result = {
            "time": datetime.now(timezone.utc).isoformat(),
            "level": record.levelname, "event": code,
            "request_id": request_id.get(),
        }
        for field in ("status", "method", "duration_ms", "error_type", "route"):
            value = getattr(record, field, None)
            if value is not None:
                result[field] = value
        if record.exc_info and record.exc_info[0]:
            result["error_type"] = record.exc_info[0].__name__
            result["frames"] = [
                {"file": Path(frame.filename).name, "line": frame.lineno, "function": frame.name}
                for frame in traceback.extract_tb(record.exc_info[2])[-8:]
            ]
        return json.dumps(result, ensure_ascii=True)


def configure_logging():
    logger = logging.getLogger("seeds")
    if logger.handlers:
        return
    logger.setLevel(logging.INFO)
    console = logging.StreamHandler()
    console.setFormatter(SafeFormatter())
    logger.addHandler(console)
    directory = os.getenv("LOG_DIRECTORY")
    if directory:
        Path(directory).mkdir(parents=True, exist_ok=True)
        handler = TimedRotatingFileHandler(
            str(Path(directory) / "seeds.jsonl"), when="midnight", utc=True,
            backupCount=29, encoding="utf-8",
        )
        handler.setFormatter(SafeFormatter())
        logger.addHandler(handler)
    logger.propagate = False
    for name in ("uvicorn.access", "uvicorn.error", "sqlalchemy.engine", "httpx", "httpcore"):
        library = logging.getLogger(name)
        library.handlers = [console]
        library.propagate = False
        library.setLevel(logging.INFO if name == "uvicorn.error" else logging.WARNING)


def configure_app(app):
    configure_logging()
    logger = logging.getLogger("seeds")

    @app.middleware("http")
    async def diagnostics(request, call_next):
        token = request_id.set(str(uuid4()))
        started = time.monotonic()
        HEALTH["requests"] += 1
        try:
            response = await call_next(request)
            if response.status_code >= 500:
                HEALTH["errors"] += 1
                HEALTH["last_error_at"] = datetime.utcnow().isoformat()
            response.headers["X-Request-ID"] = request_id.get()
            logger.info("request", extra={
                "event_code": "http_request", "status": response.status_code,
                "method": request.method,
                "duration_ms": round((time.monotonic() - started) * 1000, 2),
                "route": getattr(request.scope.get("route"), "path", "unmatched"),
            })
            if os.getenv("ACTIVITY_COLLECTION_ENABLED", "false").lower() == "true":
                from database import AsyncSessionLocal
                from activity_events import record_event
                from sqlalchemy.exc import SQLAlchemyError
                try:
                    async with AsyncSessionLocal() as db:
                        record_event(db, "http_request", resource_type="global",
                                     outcome="failed" if response.status_code >= 400 else "success",
                                     details={"status": response.status_code,
                                              "duration_ms": round((time.monotonic() - started) * 1000, 2)})
                        await db.commit()
                except SQLAlchemyError as error:
                    HEALTH["audit_write_failures"] = HEALTH.get("audit_write_failures", 0) + 1
                    logger.error("diagnostic_persistence_failed", extra={
                        "event_code": "diagnostic_persistence_failed", "error_type": type(error).__name__,
                    })
            return response
        except Exception as error:
            HEALTH["errors"] += 1
            HEALTH["last_error_at"] = datetime.utcnow().isoformat()
            logger.error("request_failed", exc_info=True, extra={
                "event_code": "request_failed", "error_type": type(error).__name__,
            })
            raise
        finally:
            request_id.reset(token)
