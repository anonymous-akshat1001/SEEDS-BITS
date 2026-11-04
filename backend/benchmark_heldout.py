"""Run evaluation-only synthetic questions; never use their answers as prompt examples."""

import argparse
import asyncio
import hashlib
import json
import math
import os
import sys
import time
from collections import Counter

from fastapi import HTTPException

from heldout_intents import VERSION, heldout_cases
from model_client import interpret


def corpus_digest(cases):
    content = [{
        "id": case.id, "category": case.category, "question": case.question,
        "expected": case.expected.model_dump(mode="json") if case.expected else None,
        "context": case.context.model_dump(mode="json") if case.context else None,
    } for case in cases]
    return hashlib.sha256(json.dumps(content, sort_keys=True).encode()).hexdigest()


async def evaluate(cases, *, progress=False):
    outcomes, durations = [], []
    for case in cases:
        started = time.monotonic()
        outcome = {"case": case.id, "category": case.category,
                   "expected": "intent" if case.expected else "clarification", "correct": False}
        try:
            actual = await interpret(case.question, case.context)
            if case.expected is None:
                outcome["error_type"] = "unsafe_or_unsupported_answer"
            else:
                differences = [key for key, value in case.expected.model_dump().items()
                               if actual.model_dump()[key] != value]
                outcome["correct"] = not differences
                if differences:
                    outcome.update(error_type="intent_mismatch", mismatched_fields=differences)
        except HTTPException as error:
            code = (error.headers or {}).get("X-Analytics-Error-Code", "http_error")
            outcome["correct"] = (case.expected is None and error.status_code == 422
                                  and code == "clarification_required")
            if not outcome["correct"]:
                outcome.update(error_type=code, http_status=error.status_code)
        durations.append(time.monotonic() - started)
        outcomes.append(outcome)
        if progress:
            status = "matched" if outcome["correct"] else outcome["error_type"]
            print(f"{case.id}: {status} ({durations[-1]:.2f}s)", file=sys.stderr, flush=True)
    return outcomes, durations


def summarize(outcomes):
    total = len(outcomes)
    matches = sum(outcome["correct"] for outcome in outcomes)
    return {"cases": total, "matches": matches, "accuracy": matches / total if total else None}


async def benchmark(limit=None, progress=False):
    complete = heldout_cases()
    cases = complete if limit is None else complete[:limit]
    outcomes, durations = await evaluate(cases, progress=progress)
    intents = [outcome for outcome in outcomes if outcome["expected"] == "intent"]
    clarifications = [outcome for outcome in outcomes if outcome["expected"] == "clarification"]
    intent_stats, clarification_stats = summarize(intents), summarize(clarifications)
    challenge = [outcome for outcome in outcomes
                 if outcome["category"] in {"adversarial", "clarification", "metric"}]
    full_run = len(cases) == len(complete)
    passed = (full_run and intent_stats["accuracy"] is not None
              and intent_stats["accuracy"] >= .95 and bool(clarifications)
              and all(outcome["correct"] for outcome in clarifications)
              and all(outcome["correct"] for outcome in challenge))
    failures = [outcome for outcome in outcomes if not outcome["correct"]]
    report = {
        "suite": VERSION, "corpus_sha256": corpus_digest(complete),
        "runtime": os.getenv("LOCAL_MODEL_RUNTIME", "ollama"),
        "model": os.getenv("LOCAL_MODEL_NAME", "not_configured"),
        "total_available_cases": len(complete), "complete_run": full_run,
        **summarize(outcomes),
        "answerable": intent_stats, "clarification": clarification_stats,
        "categories": {category: summarize([o for o in outcomes if o["category"] == category])
                       for category in sorted({case.category for case in complete})},
        "p95_seconds": round(sorted(durations)[math.ceil(len(durations) * .95) - 1], 3),
        "failure_counts": dict(Counter(outcome["error_type"] for outcome in failures)),
        "failures": failures, "meets_heldout_gate": passed,
        "gate": "Full corpus; >=95% exact answerable intents; 100% clarification, "
                "adversarial and unfiltered metric challenges.",
        "limitations": "Synthetic evaluation, not independent human validation. Absolute dates "
                       "test extraction, not retained-data availability. No live database, "
                       "speech, resource, concurrency or latency acceptance gate.",
    }
    print(json.dumps(report, indent=2))
    return passed


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--limit", type=int, help="Positive case limit; partial runs cannot pass.")
    parser.add_argument("--progress", action="store_true", help="Content-free per-case progress.")
    args = parser.parse_args()
    if args.limit is not None and args.limit < 1:
        parser.error("--limit must be positive")
    raise SystemExit(0 if asyncio.run(benchmark(args.limit, args.progress)) else 1)
