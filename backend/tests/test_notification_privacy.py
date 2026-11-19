import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

import notification_service


@pytest.mark.asyncio
async def test_actual_fcm_wire_payload_has_generic_preview_and_no_personal_metadata(monkeypatch):
    service = object.__new__(notification_service.FCMNotificationService)
    service.project_id = "test-project"
    service._get_access_token = lambda: "fake-access-token"
    sent = []

    class Client:
        async def __aenter__(self):
            return self

        async def __aexit__(self, *_):
            pass

        async def post(self, url, *, json, headers):
            sent.append(json["message"])
            return type("Response", (), {"status_code": 200})()

    monkeypatch.setattr(notification_service.httpx, "AsyncClient", Client)
    assert await service.send_notification(
        "fake-device-token", "Personal lesson title", "Private teacher and student names",
        {"type": "session_invitation", "session_id": 7, "teacher_name": "Private teacher",
         "session_title": "Private title", "class_name": "Private class", "subject_name": "Private subject",
         "quiz_title": "Private quiz", "phone_number": "9000000001", "grade": "100"},
    )
    assert sent[0]["notification"] == {"title": "SEEDS update", "body": "Open SEEDS to review your updates."}
    assert sent[0]["android"]["notification"]["visibility"] == "PRIVATE"
    assert sent[0]["data"] == {"type": "session_invitation", "session_id": "7"}


@pytest.mark.asyncio
async def test_class_alert_is_data_only_and_carries_only_routing_identifiers(monkeypatch):
    service = object.__new__(notification_service.FCMNotificationService)
    service.project_id = "test-project"
    service._get_access_token = lambda: "fake-access-token"
    sent = []

    class Client:
        async def __aenter__(self):
            return self

        async def __aexit__(self, *_):
            pass

        async def post(self, url, *, json, headers):
            sent.append(json["message"])
            return type("Response", (), {"status_code": 200})()

    monkeypatch.setattr(notification_service.httpx, "AsyncClient", Client)
    assert await service.send_class_alert(
        "fake-token", session_id=8, alert_id="a1", alert_kind="start", ring_until_ms=123,
    )
    assert "notification" not in sent[0]
    assert sent[0]["android"]["priority"] == "high"
    assert sent[0]["data"] == {
        "type": "class_alert", "session_id": "8", "alert_id": "a1",
        "alert_kind": "start", "ring_until": "123",
    }
