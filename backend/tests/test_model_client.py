import json
import sys
from pathlib import Path

import httpx
import pytest
from fastapi import HTTPException

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

import benchmark_intents
import model_client
from analytics_schemas import Intent


@pytest.fixture
def local_model(monkeypatch):
    monkeypatch.setenv("ANALYTICS_MODEL_ENABLED", "true")
    monkeypatch.setenv("LOCAL_MODEL_RUNTIME", "ollama")
    monkeypatch.setenv("LOCAL_MODEL_URL", "http://127.0.0.1:11434")
    monkeypatch.setenv("LOCAL_MODEL_NAME", "synthetic-model")
    original = httpx.AsyncClient
    captured = []

    def respond_with(body, *, status=200, error=None):
        def respond(request):
            captured.append(json.loads(request.content))
            if error is not None:
                raise error
            return httpx.Response(status, json=body)
        monkeypatch.setattr(
            model_client.httpx, "AsyncClient",
            lambda **kwargs: original(transport=httpx.MockTransport(respond), **kwargs),
        )

    return captured, respond_with


@pytest.mark.asyncio
async def test_minimal_intent_leaves_unrequested_filters_unset(local_model):
    captured, respond_with = local_model
    respond_with({"message": {"content": '{"metric":"sessions_created"}'}, "done_reason": "stop"})
    intent = await model_client.interpret("Count newly created sessions.")
    assert intent == Intent(metric="sessions_created")
    schema = captured[0]["format"]
    assert schema["required"] == ["metric"]
    assert "clarification_required" in schema["properties"]["metric"]["enum"]
    assert not any(key.endswith("_id") for key in schema["properties"])
    assert "page" not in schema["properties"]
    assert "OMIT start, end and all_time" in captured[0]["messages"][0]["content"]


@pytest.mark.asyncio
@pytest.mark.parametrize("text,code", [
    ('{"metric":"clarification_required"}', "clarification_required"),
    ('{"metric":"attendance","start":"2026-01-01T00:00:00Z","end":"2026-01-01T00:00:00Z"}', "invalid_intent"),
    ('{"metric":"quiz_average","session":"sessions_created"}', "invalid_intent"),
    ('{"metric":"attendance","sql":"SELECT secret"}', "invalid_intent"),
    ('{"metric":"attendance","student_id":123}', "invalid_model_response"),
    ('{"metric":"attendance","start":"2026-01-01T00:00:00"}', "invalid_intent"),
    ('not JSON', "invalid_model_response"),
])
async def test_invalid_or_unclear_output_never_becomes_an_answer(local_model, text, code):
    _, respond_with = local_model
    respond_with({"message": {"content": text}})
    with pytest.raises(HTTPException) as error:
        await model_client.interpret("Synthetic question.")
    assert error.value.status_code == 422
    assert error.value.headers["X-Analytics-Error-Code"] == code
    assert text not in error.value.detail


@pytest.mark.asyncio
@pytest.mark.parametrize("body,status,code", [
    ({"message": {"content": '{"metric":"attendance"}'}, "done_reason": "length"}, 200, "model_output_truncated"),
    ([], 200, "invalid_model_response"),
    ({"error": "private runtime details"}, 404, "model_http_404"),
])
async def test_runtime_failures_have_content_free_codes(local_model, body, status, code):
    _, respond_with = local_model
    respond_with(body, status=status)
    with pytest.raises(HTTPException) as error:
        await model_client.interpret("Synthetic question.")
    assert error.value.headers["X-Analytics-Error-Code"] == code
    assert "private runtime details" not in error.value.detail


@pytest.mark.asyncio
@pytest.mark.parametrize("exception,code", [
    (httpx.ReadTimeout("private input"), "model_timeout"),
    (httpx.ConnectError("private input"), "model_unavailable"),
])
async def test_transport_failures_are_distinguished(local_model, exception, code):
    _, respond_with = local_model
    respond_with({}, error=exception)
    with pytest.raises(HTTPException) as error:
        await model_client.interpret("Synthetic question.")
    assert error.value.status_code == 503
    assert error.value.headers["X-Analytics-Error-Code"] == code
    assert "private input" not in error.value.detail


@pytest.mark.asyncio
async def test_openai_runtime_uses_the_same_validated_contract(local_model, monkeypatch):
    captured, respond_with = local_model
    monkeypatch.setenv("LOCAL_MODEL_RUNTIME", "llama_cpp")
    respond_with({"choices": [{
        "message": {"content": '{"metric":"attendance","session":"Reading room"}'},
        "finish_reason": "stop",
    }]})
    intent = await model_client.interpret("Count attendees in Reading room.")
    assert intent == Intent(metric="attendance", session="Reading room")
    assert captured[0]["response_format"]["json_schema"]["schema"] == model_client.model_schema()


@pytest.mark.asyncio
async def test_partial_benchmark_never_passes_full_quality_gate(monkeypatch, capsys):
    expected = Intent(metric="attendance")
    monkeypatch.setattr(benchmark_intents, "benchmark_cases",
                        lambda: [("synthetic one", expected), ("synthetic two", expected)])
    async def interpret(question):
        return expected
    monkeypatch.setattr(benchmark_intents, "interpret", interpret)
    assert not await benchmark_intents.benchmark(limit=1, progress=True)
    output = capsys.readouterr()
    report = json.loads(output.out)
    assert report["accuracy"] == 1
    assert not report["complete_run"]
    assert not report["meets_95_percent_gate"]
    assert "synthetic one" not in output.err


@pytest.mark.asyncio
async def test_benchmark_reports_error_categories_and_mismatched_fields(monkeypatch, capsys):
    expected = Intent(metric="attendance")
    monkeypatch.setattr(benchmark_intents, "benchmark_cases",
                        lambda: [("one", expected), ("two", expected)])
    async def interpret(question):
        if question == "one":
            raise model_client.inference_error(503, "model_timeout", "safe message")
        return Intent(metric="attendance", all_time=True)
    monkeypatch.setattr(benchmark_intents, "interpret", interpret)
    assert not await benchmark_intents.benchmark()
    report = json.loads(capsys.readouterr().out)
    assert report["failure_counts"] == {"model_timeout": 1, "intent_mismatch": 1}
    assert report["failures"][0]["http_status"] == 503
    assert report["failures"][1]["mismatched_fields"] == ["all_time"]
