List<dynamic> filterSessionsBySubject(List<dynamic> sessions, int? subjectId) {
  if (subjectId == null) return List<dynamic>.from(sessions);
  return sessions
      .where((session) => session is Map && session['subject_id'] == subjectId)
      .toList();
}

List<int> movePlaylistItem(
  List<int> orderedItemIds,
  int selectedIndex,
  int delta,
) {
  final reordered = List<int>.from(orderedItemIds);
  final destination = selectedIndex + delta;
  if (selectedIndex < 0 ||
      selectedIndex >= reordered.length ||
      destination < 0 ||
      destination >= reordered.length) {
    return reordered;
  }
  final moved = reordered.removeAt(selectedIndex);
  reordered.insert(destination, moved);
  return reordered;
}
