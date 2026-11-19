"""Administrator exception queue (S41): one deduplicated, actionable record
per underlying problem, so users get a short status instead of diagnostics."""

from __future__ import annotations

import logging
from typing import Optional

from sqlalchemy import select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.ext.asyncio import AsyncSession

import models
from scheduling import utcnow


async def report_issue(
    db: AsyncSession,
    kind: str,
    dedupe_key: str,
    message: str,
    details: Optional[dict] = None,
    *,
    commit: bool = True,
) -> None:
    """Open or refresh an issue. Never raises: reporting must not break the
    request or job that noticed the problem."""
    now = utcnow()
    try:
        async with db.begin_nested():
            issue = (await db.execute(
                select(models.AdminIssue).where(models.AdminIssue.dedupe_key == dedupe_key)
            )).scalar_one_or_none()
            if issue is None:
                db.add(models.AdminIssue(
                    kind=kind, dedupe_key=dedupe_key, message=message,
                    details=details or {}, status="open",
                    created_at=now, last_seen_at=now, occurrences=1,
                ))
            else:
                if issue.status == "resolved":
                    issue.status = "open"
                    issue.resolved_at = None
                    issue.resolved_by = None
                issue.occurrences = (issue.occurrences or 0) + 1
                issue.last_seen_at = now
                issue.message = message
                if details is not None:
                    issue.details = details
        if commit:
            await db.commit()
    except (IntegrityError, Exception):  # noqa: BLE001 - reporting is best effort
        logging.getLogger("seeds").warning(
            "admin_issue_report_failed", extra={"event_code": "admin_issue_report_failed"},
        )
