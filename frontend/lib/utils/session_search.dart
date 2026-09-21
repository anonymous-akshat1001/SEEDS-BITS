/// Returns active sessions whose title or identifier contains [query].
/// An empty query intentionally returns every session so keyboard users can
/// browse the full result list before choosing one.
List filterSessionsByNameOrId(List sessions, String query) {
  final normalized = query.trim().toLowerCase();
  if (normalized.isEmpty) return List.of(sessions);

  return sessions.where((session) {
    if (session is! Map) return false;
    final id = (session['session_id'] ?? '').toString().toLowerCase();
    final title = (session['title'] ?? '').toString().toLowerCase();
    return id.contains(normalized) || title.contains(normalized);
  }).toList();
}
