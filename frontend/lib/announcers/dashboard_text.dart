import '../l10n/speech.dart';
import '../utils/spoken_format.dart';
import 'announce.dart';

/// Every sentence spoken by the student and teacher dashboards.
abstract final class DashboardText {
  // ── Shared ────────────────────────────────────────────────────────────────
  static String get refreshing => Speech.t.dashboardRefreshing;
  static String get showMatching => Speech.t.dashboardShowMatching;
  static String get logout => Speech.t.dashboardLogout;
  static String get refresh => Speech.t.dashboardRefresh;
  static String openingLibrary() =>
      CommonText.opening(Speech.t.dashboardLibraryWhat, needsInternet: true);
  static String openingQuizzes() =>
      CommonText.opening(Speech.t.dashboardQuizzesWhat);
  static String sessions(int count) => Speech.t.dashboardSessions(count);

  /// "3 of 6" for left/right value controls.
  static String position(int index, int total) =>
      Speech.t.dashboardPosition('${index + 1}', '$total');

  // ── Student dashboard ─────────────────────────────────────────────────────
  static String get studentScreen => Speech.t.dashboardStudentScreen;
  static String get studentLoading => Speech.t.dashboardStudentLoading;
  static String get studentSections => Speech.t.dashboardStudentSections;
  static String get noLiveSessions => Speech.t.dashboardNoLiveSessions;
  static String get noFilterMatch => Speech.t.dashboardNoFilterMatch;
  static String get noMatchVisible => Speech.t.dashboardNoMatchVisible;
  static String available(int count) => Announce.pick(
    brief: Speech.t.dashboardAvailable(count),
    detailed: Speech.t.dashboardAvailableDetailed(count),
  );
  static String refreshFailed(String reason) =>
      Speech.t.dashboardRefreshFailed(reason);
  static String get joining => Speech.t.dashboardJoining;
  static String joined(int id) =>
      Speech.t.dashboardJoined(SpokenFormat.session(id));
  static String get openingPlaylists => Speech.t.dashboardOpeningPlaylists;
  static String get sessionSearchHelp => Speech.t.dashboardSessionSearchHelp;
  static String sessionNumberField(String typed) => typed.isEmpty
      ? Speech.t.dashboardSessionNumberFieldEmpty
      : Speech.t.dashboardSessionNumberField(SpokenFormat.digits(typed));
  static String get nameField => Speech.t.dashboardNameField;
  static String noSessionNumber(String id) =>
      Speech.t.dashboardNoSessionNumber(SpokenFormat.digits(id));
  static String found(String label) => Speech.t.dashboardFound(label);
  static String noNameMatch(String query) =>
      Speech.t.dashboardNoNameMatch(query);
  static String showingAll(int count) => Announce.pick(
    brief: Speech.t.dashboardShowingAll(count),
    detailed: Speech.t.dashboardShowingAllDetailed(count),
  );
  static String nameMatches(int count, String query) =>
      Speech.t.dashboardNameMatches(count, query);
  static String subjectName(String? name) =>
      name ?? Speech.t.dashboardAllSubjects;
  static String subjectFilterLabel(String? name, int index, int total) =>
      Speech.t.dashboardSubjectFilterLabel(
        subjectName(name),
        position(index, total),
      );
  static String subjectFilterChanged(
    String? name,
    int index,
    int total,
    String summary,
  ) => Speech.t.dashboardSubjectFilterChanged(
    subjectName(name),
    position(index, total),
    summary,
  );
  static String get library => Speech.t.dashboardLibrary;
  static String get playlists => Speech.t.dashboardPlaylists;
  static String get quizzes => Speech.t.dashboardQuizzes;
  static String get studentJourneys => Speech.t.dashboardStudentJourneys;

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
    if (teacher != null && teacher.isNotEmpty)
      Speech.t.dashboardTeacherName(teacher),
    Speech.t.dashboardLiveNow,
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
    if (refreshing) Speech.t.dashboardStateRefreshing,
    Speech.t.dashboardStateLiveSessions(live),
    Speech.t.dashboardStateSubjectFilter(subjectName(subject)),
    if (sessionNumber.isNotEmpty)
      Speech.t.dashboardStateSessionNumber(SpokenFormat.digits(sessionNumber)),
    if (nameSearch.isNotEmpty) Speech.t.dashboardStateNameSearch(nameSearch),
    if (shown != live) Speech.t.dashboardStateShown(shown),
  ].join(' ');

  // ── Teacher dashboard ─────────────────────────────────────────────────────
  static String get teacherScreen => Speech.t.dashboardTeacherScreen;
  static String get teacherLoading => Speech.t.dashboardTeacherLoading;
  static String get teacherSections => Speech.t.dashboardTeacherSections;
  static String get noSessionsYet => Speech.t.dashboardNoSessionsYet;
  static String get noTeacherMatch => Speech.t.dashboardNoTeacherMatch;
  static String teacherCount(int all, int live) => live > 0
      ? Speech.t.dashboardTeacherCountLive(all, '$live')
      : Speech.t.dashboardTeacherCount(all);
  static String notRefreshed(String reason) =>
      Speech.t.dashboardNotRefreshed(reason);
  static String withDone(String? done, String message) =>
      done == null ? message : '$done $message';
  static String get noAssignment => Speech.t.dashboardNoAssignment;
  static String get creatingSession => Speech.t.dashboardCreatingSession;
  static String created(String title) => Speech.t.dashboardCreated(title);
  static String get createdTitle => Speech.t.dashboardCreatedTitle;
  static String startNow(String title) => Speech.t.dashboardStartNow(title);
  static String get requestFailed => Speech.t.dashboardRequestFailed;
  static String get openingSession => Speech.t.dashboardOpeningSession;
  static String workspace(String className, String subject) =>
      Speech.t.dashboardWorkspace(className, subject);
  static String workspaceSelected(
    String name,
    int index,
    int total,
    String status,
  ) => Speech.t.dashboardWorkspaceSelected(name, position(index, total), status);
  static String workspaceChosen(String name, String status) =>
      Speech.t.dashboardWorkspaceChosen(name, status);
  static String get chooseWorkspaceTitle =>
      Speech.t.dashboardChooseWorkspaceTitle;
  static String workspaceLabel(String? name, int index, int total) =>
      name == null
      ? Speech.t.dashboardNoWorkspace
      : Speech.t.dashboardWorkspaceLabel(name, position(index, total));
  static String get create => Speech.t.dashboardCreate;
  static String get classPlaylists => Speech.t.dashboardClassPlaylists;
  static String get teacherJourneys => Speech.t.dashboardTeacherJourneys;
  static String get teacherQuizzes => Speech.t.dashboardTeacherQuizzes;
  static String get offlineLibrary => Speech.t.dashboardOfflineLibrary;
  static String get searchField => Speech.t.dashboardSearchField;
  static String get teacherSearchHelp => Speech.t.dashboardTeacherSearchHelp;
  static String teacherNoMatch(String query) =>
      Speech.t.dashboardTeacherNoMatch(query);

  /// "Science test, Class 5, Science, live now, 3 joined, session four two.
  /// Press OK to open".
  static String teacherSession({
    required String title,
    required String place,
    required bool active,
    Object? joined,
    required int id,
  }) {
    final t = Speech.t;
    final parts = [
      title,
      if (place.isNotEmpty) place,
      if (active) t.dashboardLiveNow else t.dashboardEnded,
      if (active && joined is int) t.dashboardJoinedCount('$joined'),
      SpokenFormat.session(id),
    ].join(', ');
    return '$parts. ${active ? t.dashboardPressOkToOpen : t.dashboardPressOkToReactivate}';
  }

  static String endLabel(String title) => Speech.t.dashboardEndLabel(title);
  static String deleteLabel(String title) =>
      Speech.t.dashboardDeleteLabel(title);
  static String get endTitle => Speech.t.dashboardEndTitle;
  static String endMessage(String title) => Speech.t.dashboardEndMessage(title);
  static String get ended => Speech.t.dashboardEndedForEveryone;
  static String get endFailed => Speech.t.dashboardEndFailed;
  static String get reactivateTitle => Speech.t.dashboardReactivateTitle;
  static String reactivateMessage(String title) =>
      Speech.t.dashboardReactivateMessage(title);
  static String get reactivated => Speech.t.dashboardReactivated;
  static String get reactivateFailed => Speech.t.dashboardReactivateFailed;
  static String get openNowTitle => Speech.t.dashboardOpenNowTitle;
  static String openNowMessage(String title) =>
      Speech.t.dashboardOpenNowMessage(title);
  static String get deleteTitle => Speech.t.dashboardDeleteTitle;
  static String deleteMessage(String title) =>
      Speech.t.dashboardDeleteMessage(title);
  static String get deleted => Speech.t.dashboardDeleted;
  static String get deleteFailed => Speech.t.dashboardDeleteFailed;

  /// Star summary: "Workspace: Class 5, Science. 2 active sessions."
  static String teacherState({
    String? workspace,
    required int all,
    required int live,
    String search = '',
    bool refreshing = false,
  }) => [
    if (refreshing) Speech.t.dashboardStateRefreshing,
    workspace == null
        ? Speech.t.dashboardStateNoWorkspace
        : Speech.t.dashboardStateWorkspace(workspace),
    Speech.t.dashboardStateTotals(
      Speech.t.dashboardActiveSessions(live),
      sessions(all),
    ),
    if (search.isNotEmpty) Speech.t.dashboardStateSearch(search),
  ].join(' ');
}
