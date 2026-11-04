"""Synthetic, campus-local intent benchmark. No real student data or raw output is saved."""

import asyncio
import argparse
import json
import math
import os
import sys
import time
from collections import Counter

from analytics_schemas import Intent
from model_client import interpret
from fastapi import HTTPException

QUESTIONS = {
    "sessions_created": [
        "How many sessions were created?", "Count distinct sessions created.",
        "What is the number of sessions originally created?", "How many new sessions are there?",
        "Count session creations, not reopenings.", "Give the total original session count.",
        "How many classrooms were created as sessions?", "Count new live sessions.",
        "How many logical sessions were created?", "Show the count of sessions created.",
    ],
    "session_openings": [
        "How many times were sessions opened?", "Count session openings including reopens.",
        "How many opening runs were there?", "Count the times sessions opened.",
        "What is the session opening count?", "Count starts including reopened sessions.",
        "How many session runs started?", "Give the number of session openings.",
        "Count all opening runs.", "Show opening runs, not original creations.",
    ],
    "attendance": [
        "How many unique students actually joined?", "Count distinct student attendees.",
        "How many different students connected to class?", "Give unique student attendance.",
        "Count students who actually connected, not invitations.", "How many unique learners joined class?",
        "What is the distinct student attendance count?", "Count actual attendees, excluding teachers.",
        "How many unique students attended sessions?", "Show unique confirmed student joins.",
    ],
    "quiz_average": [
        "What is the average quiz percentage?", "Average finalized graded attempt percentages.",
        "Give the mean graded quiz score across all finalized attempts.",
        "Show average percentage including timed-out graded attempts.",
        "Average all finalized graded quiz attempts, not best scores.",
        "What is the mean quiz percentage across submitted attempts?",
        "Calculate the average percentage for graded quizzes.",
        "Give the all-attempt graded score mean.", "Show the mean finalized quiz score.",
        "Average quiz scores excluding practice and in-progress attempts.",
    ],
    "quiz_attempts": [
        "How many graded quiz attempts were finalized?", "Count completed and timed-out graded attempts.",
        "What is the finalized graded attempt count?", "Count finalized quiz submissions.",
        "How many final graded attempts are recorded?", "Show finalized graded quiz attempt totals.",
        "Count graded quiz submissions including timeouts.", "How many graded attempts are complete?",
        "Give the number of final graded quiz attempts.", "Count graded attempts excluding practice and in-progress.",
    ],
    "activity_counts": [
        "Count recorded activity events.", "What are the activity counts?",
        "Show action counts grouped by activity type.", "Summarize activity event totals.",
        "How many logged actions are there?", "Count recorded actions.",
        "Show event counts by activity.", "Give the number of activity observations.",
        "Summarize logged activity counts.", "Count audit activity events.",
    ],
}


def benchmark_cases():
    cases = [(text, Intent(metric=metric)) for metric, questions in QUESTIONS.items() for text in questions]
    # Named-entity fixtures exercise extraction as well as metric selection.
    cases += [
        ("How many sessions were created by Teacher X for Subject Y and Class Z?",
         Intent(metric="sessions_created", teacher="Teacher X", subject="Subject Y", class_name="Class Z")),
        ("What is Student A's average graded quiz score for Subject Y in Class Z?",
         Intent(metric="quiz_average", student="Student A", subject="Subject Y", class_name="Class Z")),
        ("How many unique students joined Learning Room for all time?",
         Intent(metric="attendance", session="Learning Room", all_time=True)),
    ]
    return cases


async def benchmark(limit=None, progress=False):
    cases = benchmark_cases()
    total = len(cases)
    if limit is not None:
        cases = cases[:limit]
    passed, failures, durations = 0, [], []
    for index, (question, expected) in enumerate(cases, 1):
        started = time.monotonic()
        try:
            actual = await interpret(question)
            correct = actual.model_dump() == expected.model_dump()
            if not correct:
                failures.append({
                    "case": index, "error_type": "intent_mismatch",
                    "mismatched_fields": [
                        key for key, value in expected.model_dump().items()
                        if actual.model_dump()[key] != value
                    ],
                })
        except HTTPException as error:
            failures.append({
                "case": index,
                "error_type": (error.headers or {}).get("X-Analytics-Error-Code", "http_error"),
                "http_status": error.status_code,
            })
            correct = False
        durations.append(time.monotonic() - started)
        if correct:
            passed += 1
        if progress:
            status = "matched" if correct else failures[-1]["error_type"]
            print(f"Case {index}/{len(cases)}: {status} ({durations[-1]:.2f}s)", file=sys.stderr, flush=True)
    durations.sort()
    report = {
        "synthetic_cases": len(cases), "exact_intent_matches": passed,
        "total_available_cases": total, "complete_run": len(cases) == total,
        "runtime": os.getenv("LOCAL_MODEL_RUNTIME", "ollama"),
        "model": os.getenv("LOCAL_MODEL_NAME", "not_configured"),
        "accuracy": passed / len(cases),
        "meets_95_percent_gate": len(cases) == total and passed / len(cases) >= .95,
        "p95_seconds": round(durations[math.ceil(len(durations) * .95) - 1], 3),
        "failure_counts": dict(Counter(failure["error_type"] for failure in failures)),
        "failures": failures,
        "limitations": "Synthetic smoke corpus only; also validate ambiguity, adversarial/date cases, real approved English speech, concurrency, memory and campus isolation.",
    }
    print(json.dumps(report, indent=2))
    return report["meets_95_percent_gate"]


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--limit", type=int, help="Run only the first N cases; partial runs cannot pass the quality gate.")
    parser.add_argument("--progress", action="store_true", help="Print content-free per-case progress to stderr.")
    args = parser.parse_args()
    if args.limit is not None and args.limit < 1:
        parser.error("--limit must be positive")
    raise SystemExit(0 if asyncio.run(benchmark(args.limit, args.progress)) else 1)
