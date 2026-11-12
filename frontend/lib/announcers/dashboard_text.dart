import '../utils/spoken_format.dart';
import 'announce.dart';

/// Every sentence spoken by the student and teacher dashboards.
abstract final class DashboardText {
  // ── Shared ────────────────────────────────────────────────────────────────
  static const refreshing = 'Refreshing sessions.';
  static const showMatching = 'Show matching sessions';
  static const logout = 'Log out, asks to confirm';
  static const refresh = 'Refresh sessions';
  static String openingLibrary() =>
      CommonText.opening('recorded audio library', needsInternet: true);
  static String openingQuizzes() => CommonText.opening('quizzes');
  static String sessions(int count) => SpokenFormat.count(count, 'session');

  /// "3 of 6" for left/right value controls.
  static String position(int index, int total) => '${index + 1} of $total';

  // ── Student dashboard ─────────────────────────────────────────────────────
  static const studentScreen = 'Student Dashboard';
  static const studentLoading = 'Student dashboard is loading';
  static const studentSections =
      'refresh, session search, live sessions, recorded lessons, playlists, quizzes, learning journeys, and log out';
  static const noLiveSessions =
      'No live sessions right now. Press 1 to refresh.';
  static const noFilterMatch = 'No sessions match your filter.';
  static const noMatchVisible =
      'No matching sessions. Clear the search or change the subject filter.';
  static String available(int count) => Announce.pick(
    brief: '${sessions(count)} available.',
    detailed: '${sessions(count)} available. Use down to browse.',
  );
  static String refreshFailed(String reason) => '$reason Press 1 to try again.';
  static const joining = 'Joining session.';
  static String joined(int id) => 'Joined ${SpokenFormat.session(id)}.';
  static const openingPlaylists =
      'Opening My Playlists. These playlists are private.';
  static const sessionSearchHelp =
      'Session search. Press OK to type a session number, then go down to '
      'Show matching sessions and press OK. You can also search by name.';
  static String sessionNumberField(String typed) => typed.isEmpty
      ? 'Session number field. Type a number, then choose Show matching sessions'
      : 'Session number field, ${SpokenFormat.digits(typed)}';
  static const nameField = 'Search sessions by name';
  static String noSessionNumber(String id) =>
      'No live session number ${SpokenFormat.digits(id)}.';
  static String found(String label) => 'Found: $label. Press OK to join.';
  static String noNameMatch(String query) => 'No sessions match $query.';
  static String showingAll(int count) => Announce.pick(
    brief: 'Showing all ${sessions(count)}.',
    detailed: 'Showing all ${sessions(count)}. Use down to browse.',
  );
  static String nameMatches(int count, String query) =>
      '${sessions(count)} match $query. Use down to browse.';
  static String subjectName(String? name) => name ?? 'all subjects';
  static String subjectFilterLabel(String? name, int index, int total) =>
      'Subject filter: ${subjectName(name)}, ${position(index, total)}. Use left or right to change';
  static String subjectFilterChanged(
    String? name,
    int index,
    int total,
    String summary,
  ) => 'Subject filter: ${subjectName(name)}, ${position(index, total)}. $summary';
  static const library = 'Recorded audio library';
  static const playlists = 'My private playlists';
  static const quizzes = 'Quizzes';
  static const studentJourneys =
      'Learning journeys: listen, answer and repeat, works offline';

  /// "Science, Class 6, Teacher Mrs Rao, live now, session one two".
  static String studentSession({
    required String title,
    String? subject,
    String? className,
    String? teacher,
    required int id,
  }) => [
    title,
    if (subject != null &&
        subject.isNotEmpty &&
        subject.toLowerCase() != title.toLowerCase())
      subject,
    if (className != null && className.isNotEmpty) className,
    if (teacher != null && teacher.isNotEmpty) 'Teacher $teacher',
    'live now',
    SpokenFormat.session(id),
  ].join(', ');

  /// Star summary: "3 live sessions. Subject filter: all subjects."
  static String studentState({
    required int live,
    required int shown,
    String? subject,
    String sessionNumber = '',
    String nameSearch = '',
    bool refreshing = false,
  }) => [
    if (refreshing) 'Refreshing.',
    '${SpokenFormat.count(live, 'live session')}.',
    'Subject filter: ${subjectName(subject)}.',
    if (sessionNumber.isNotEmpty)
      'Session number typed: ${SpokenFormat.digits(sessionNumber)}.',
    if (nameSearch.isNotEmpty) 'Name search: $nameSearch.',
    if (shown != live) '${SpokenFormat.count(shown, 'session')} shown.',
  ].join(' ');

  // ── Teacher dashboard ─────────────────────────────────────────────────────
  static const teacherScreen = 'Teacher Dashboard';
  static const teacherLoading = 'Teacher dashboard is loading';
  static const teacherSections =
      'class and subject selection, teaching tools, session search, and active or ended sessions';
  static const noSessionsYet = 'No sessions yet. Press 2 to create one.';
  static const noTeacherMatch =
      'No matching sessions. Clear the search to list all sessions.';
  static String teacherCount(int all, int live) =>
      '${sessions(all)}${live > 0 ? ', $live live now' : ''}.';
  static String notRefreshed(String reason) =>
      '$reason Sessions were not refreshed. Press 1 to try again.';
  static String withDone(String? done, String message) =>
      done == null ? message : '$done $message';
  static const noAssignment =
      'No class and subject is assigned to you. Ask an administrator to assign one.';
  static const creatingSession = 'Creating session';
  static String created(String title) => 'Session $title created.';
  static const createdTitle = 'Session created';
  static String startNow(String title) => 'Do you want to start "$title" now?';
  static const requestFailed =
      'We could not complete that request. Check your connection and try again.';
  static const openingSession = 'Opening session.';
  static String workspace(String className, String subject) =>
      '$className, $subject';
  static String workspaceSelected(
    String name,
    int index,
    int total,
    String status,
  ) => 'Workspace: $name, ${position(index, total)}. $status';
  static String workspaceChosen(String name, String status) =>
      '$name selected. $status Press 7 to choose another workspace.';
  static const chooseWorkspaceTitle = 'Choose class and subject';
  static String workspaceLabel(String? name, int index, int total) =>
      name == null
      ? 'No class and subject workspace assigned'
      : 'Workspace: $name, ${position(index, total)}. Left or right to change, OK or 7 for a numbered list';
  static const create = 'Create new session';
  static const classPlaylists = 'Class playlists';
  static const teacherJourneys =
      'Learning journeys: recordings, questions and polls in one flow';
  static const teacherQuizzes = 'Quizzes and private question bank';
  static const offlineLibrary = 'Offline audio library';
  static const searchField =
      'Search sessions. Press OK, then type a name or the session number';
  static const teacherSearchHelp =
      'Session search. Press OK to edit, then type a session name, or the '
      'session number using the number keys. '
      'Use up or down to leave the field and browse results.';
  static String teacherNoMatch(String query) =>
      'No sessions match $query. Clear the search to list all sessions.';

  /// "Science test, Class 5, Science, live now, 3 joined, session four two.
  /// Press OK to open".
  static String teacherSession({
    required String title,
    required String place,
    required bool active,
    Object? joined,
    required int id,
  }) =>
      [
        title,
        if (place.isNotEmpty) place,
        if (active) 'live now' else 'ended',
        if (active && joined is int) '$joined joined',
        SpokenFormat.session(id),
      ].join(', ') +
      (active ? '. Press OK to open' : '. Press OK to reactivate');
  static String endLabel(String title) =>
      'End $title for everyone, asks to confirm';
  static String deleteLabel(String title) =>
      'Delete ended session $title permanently, asks to confirm';
  static const endTitle = 'End session for everyone?';
  static String endMessage(String title) =>
      'End "$title" and close it for every participant? The session will remain in your dashboard history.';
  static const ended = 'Session ended for everyone and kept in session history.';
  static const endFailed = 'The session could not be ended. Please try again.';
  static const reactivateTitle = 'Reactivate session?';
  static String reactivateMessage(String title) =>
      'Reactivate "$title" so participants can join it again?';
  static const reactivated = 'Session reactivated.';
  static const reactivateFailed =
      'The session could not be reactivated. Please try again.';
  static const openNowTitle = 'Open session now?';
  static String openNowMessage(String title) =>
      '"$title" is active again. Open it now, or return to it later from the dashboard.';
  static const deleteTitle = 'Permanently delete session?';
  static String deleteMessage(String title) =>
      'Permanently delete "$title", including its participants, chat, and logs? This cannot be undone.';
  static const deleted = 'Session permanently deleted.';
  static const deleteFailed =
      'The session could not be deleted. Please try again.';

  /// Star summary: "Workspace: Class 5, Science. 2 active sessions."
  static String teacherState({
    String? workspace,
    required int all,
    required int live,
    String search = '',
    bool refreshing = false,
  }) => [
    if (refreshing) 'Refreshing.',
    workspace == null ? 'No workspace chosen.' : 'Workspace: $workspace.',
    '${SpokenFormat.count(live, 'active session')}, ${sessions(all)} in total.',
    if (search.isNotEmpty) 'Search: $search.',
  ].join(' ');
}
