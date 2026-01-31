# SEEDS-BITS Backend

## Session Logging Implementation

Comprehensive session logging has been added to track:
- Session creation/end
- Participant join/leave/kick
- Chat messages
- Audio events (upload, select, play, pause)

### How to Test Session Logs

1. **Deploy the Backend**: Ensure the latest code is running on the server.

2. **Access Swagger UI**: 
   - Go to `http://responsible-tech.bits-hyderabad.ac.in/seeds/docs` (or your local URL).

3. **Find the Endpoints**:
   - Scroll to the **Session Logging** section (or `default` section).
   - Locate `GET /sessions/{session_id}/logs`.

4. **Execute Request**:
   - Click **Try it out**.
   - Enter a valid `session_id` (e.g., `1`).
   - Click **Execute**.

5. **Verify Response**:
   - You should see a list of log entries for that session.

### API Response Example
```json
{
  "session_id": 1,
  "total_logs": 12,
  "logs": [
    {
      "event_type": "session_created",
      "user_id": 1,
      "event_details": { "title": "Physics 101" },
      "created_at": "2024-03-20T10:00:00"
    },
    {
      "event_type": "audio_uploaded",
      "user_id": 1,
      "event_details": { "title": "Lecture 1", "duration": 3600 },
      "created_at": "2024-03-20T10:05:00"
    }
  ]
}
```
