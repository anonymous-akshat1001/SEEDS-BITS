import json
import sys
from collections import Counter
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

import benchmark_heldout
from benchmark_intents import benchmark_cases
from heldout_intents import EvaluationCase, heldout_cases
from model_client import inference_error
from analytics_schemas import Intent, QueryRequest


def test_corpus_is_separate_valid_and_covers_all_challenges():
    cases = heldout_cases()
    assert len(cases) == 200
    assert len({case.id for case in cases}) == 200
    assert len({(case.question, case.context.model_dump_json() if case.context else None)
                for case in cases}) == 200
    assert not {case.question for case in cases} & {question for question, _ in benchmark_cases()}
    assert Counter(case.category for case in cases) == {
        "metric": 60, "entities": 48, "dates": 24, "followups": 24,
        "clarification": 24, "adversarial": 20,
    }
    assert sum(case.expected is None for case in cases) == 32
    assert {case.expected.metric for case in cases if case.expected} == {
        "sessions_created", "session_openings", "attendance", "quiz_average",
        "quiz_attempts", "activity_counts",
    }
    for case in cases:
        QueryRequest(question=case.question, context=case.context)
        if case.expected:
            assert Intent.model_validate_json(case.expected.model_dump_json()) == case.expected
            assert not any(value is not None for key, value in case.expected.model_dump().items()
                           if key.endswith("_id"))
    assert benchmark_heldout.corpus_digest(cases) == benchmark_heldout.corpus_digest(heldout_cases())


@pytest.mark.asyncio
async def test_exact_oracle_passes_but_partial_run_does_not(monkeypatch, capsys):
    cases = heldout_cases()
    lookup = {(case.question, case.context.model_dump_json() if case.context else None): case
              for case in cases}

    async def oracle(question, context):
        case = lookup[question, context.model_dump_json() if context else None]
        if case.expected is None:
            raise inference_error(422, "clarification_required", "safe")
        return case.expected.model_copy(deep=True)

    monkeypatch.setattr(benchmark_heldout, "interpret", oracle)
    assert await benchmark_heldout.benchmark(progress=True)
    output = capsys.readouterr()
    report = json.loads(output.out)
    assert report["answerable"] == {"cases": 168, "matches": 168, "accuracy": 1}
    assert report["clarification"] == {"cases": 32, "matches": 32, "accuracy": 1}
    assert report["failures"] == []
    assert all(case.question not in output.out + output.err for case in cases)
    assert not await benchmark_heldout.benchmark(limit=1)
    assert not json.loads(capsys.readouterr().out)["meets_heldout_gate"]


@pytest.mark.asyncio
async def test_errors_are_not_successful_clarifications_and_filters_must_match(monkeypatch):
    cases = [
        EvaluationCase("a", "clarification", "unsupported", None),
        EvaluationCase("b", "clarification", "ambiguous", None),
        EvaluationCase("c", "metric", "answerable", Intent(metric="attendance")),
        EvaluationCase("d", "adversarial", "unsafe", None),
    ]

    async def fake(question, context):
        if question == "unsupported":
            raise inference_error(503, "model_timeout", "private details")
        if question == "ambiguous":
            raise inference_error(422, "invalid_intent", "private details")
        return Intent(metric="attendance", teacher="Invented")

    monkeypatch.setattr(benchmark_heldout, "interpret", fake)
    outcomes, _ = await benchmark_heldout.evaluate(cases)
    assert not any(outcome["correct"] for outcome in outcomes)
    assert [outcome["error_type"] for outcome in outcomes] == [
        "model_timeout", "invalid_intent", "intent_mismatch", "unsafe_or_unsupported_answer",
    ]
    assert outcomes[2]["mismatched_fields"] == ["teacher"]


@pytest.mark.asyncio
async def test_refusing_every_question_cannot_pass(monkeypatch, capsys):
    async def refuse(question, context):
        raise inference_error(422, "clarification_required", "safe")

    monkeypatch.setattr(benchmark_heldout, "interpret", refuse)
    assert not await benchmark_heldout.benchmark()
    report = json.loads(capsys.readouterr().out)
    assert report["clarification"]["accuracy"] == 1
    assert report["answerable"]["accuracy"] == 0
