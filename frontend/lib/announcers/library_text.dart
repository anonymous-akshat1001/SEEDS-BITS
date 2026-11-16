import '../l10n/speech.dart';
import '../utils/spoken_format.dart';
import 'announce.dart';

/// Every sentence spoken by the recorded library, lesson players, playlists,
/// downloads and learning controls, kept in one place so wording stays
/// consistent and can be translated later.
abstract final class LibraryText {
  // ── Shared formats ────────────────────────────────────────────────────────

  /// "1.25" for 1.25x, "1" for 1x.
  static String speedNumber(double speed) =>
      speed.toStringAsFixed(2).replaceFirst(RegExp(r'\.?0+$'), '');

  /// "1.25 times".
  static String speed(double speed) =>
      Speech.t.librarySpeedTimes(speedNumber(speed));

  /// "1 minute 5 seconds of 4 minutes".
  static String position(Duration at, Duration? total) =>
      SpokenFormat.position(at, total);

  static String get noClassForSession => Speech.t.libraryNoClassForSession;

  /// "Subject filter: Science, 2 of 4. Key 2, or left or right to change".
  static String subjectFilterLabel(String? name, int index, int total) {
    final subject = name ?? Speech.t.libraryAllSubjects;
    return total > 1 && index >= 0
        ? Speech.t.librarySubjectFilterLabelPosition(
            subject,
            '${index + 1}',
            '$total',
          )
        : Speech.t.librarySubjectFilterLabel(subject);
  }

  static String restoredToPlaylist(String title) =>
      Speech.t.libraryRestoredToPlaylist(title);

  /// "12 megabytes", "1.5 megabytes", "less than 0.1 megabytes".
  static String size(int bytes) {
    if (bytes <= 0) return Speech.t.librarySizeZero;
    final megabytes = bytes / 1000000;
    if (megabytes < 0.1) return Speech.t.librarySizeTiny;
    final text = megabytes < 10
        ? megabytes.toStringAsFixed(1).replaceFirst(RegExp(r'\.0$'), '')
        : '${megabytes.round()}';
    return text == '1'
        ? Speech.t.librarySizeOne
        : Speech.t.librarySizeMegabytes(text);
  }

  /// "12 megabytes used of 50."
  static String storageUsed(int bytes, int limitMegabytes) =>
      Speech.t.libraryStorageUsed(size(bytes), '$limitMegabytes');

  static String recordings(int count) => Speech.t.libraryRecordingCount(count);

  // ── Lesson player ─────────────────────────────────────────────────────────

  static String playing(
    String title,
    Duration at,
    Duration? total,
    double rate,
  ) => Announce.pick(
    brief: Speech.t.libraryPlayingBrief(title, position(at, total)),
    detailed: Speech.t.libraryPlayingDetailed(
      title,
      position(at, total),
      speed(rate),
    ),
  );

  static String paused(Duration at, Duration? total) =>
      Speech.t.libraryPausedAt(position(at, total));

  /// Star summary: "Playing Food story, 1 minute 5 seconds of 4 minutes,
  /// speed 1.25 times."
  static String playerState({
    required String? title,
    required bool playing,
    required Duration at,
    required Duration? total,
    required double rate,
  }) => title == null
      ? Speech.t.libraryPlayerStateNothing
      : playing
      ? Speech.t.libraryPlayerStatePlaying(
          title,
          position(at, total),
          speed(rate),
        )
      : Speech.t.libraryPlayerStatePaused(
          title,
          position(at, total),
          speed(rate),
        );

  static String speedChanged(double rate) =>
      Speech.t.librarySpeedChanged(speed(rate));
  static String get slowest => Speech.t.librarySlowest;
  static String get fastest => Speech.t.libraryFastest;
  static String get noLessonLoaded => Speech.t.libraryNoLessonLoaded;
  static String noLessonPlaying(int playKey) =>
      Speech.t.libraryNoLessonPlayingPress('$playKey');
  static String get nothingPlaying => Speech.t.libraryNothingIsPlaying;
  static String get nothingPlayingHint => Speech.t.libraryNothingPlayingHint;
  static String stopped(String title) => Speech.t.libraryStopped(title);
  static String finished(String title) => Speech.t.libraryFinished(title);
  static String get waitForPlayer => Speech.t.libraryWaitForPlayer;
  static String get seekFailed => Speech.t.librarySeekFailed;
  static String get speedFailed => Speech.t.librarySpeedFailed;
  static String playFailed(String title) => Speech.t.libraryPlayFailed(title);
  static String get checkingOfflineAccess =>
      Speech.t.libraryCheckingOfflineAccess;
  static String get lessonGone => Speech.t.libraryLessonGone;

  static String seekLabel(Duration at, Duration? total) =>
      Speech.t.librarySeekLabel(position(at, total));
  static String rewindLabel(int key) => Speech.t.libraryRewindLabel('$key');
  static String forwardLabel(int key) => Speech.t.libraryForwardLabel('$key');
  static String slowerLabel(int key, double rate) =>
      Speech.t.librarySlowerLabel('$key', speed(rate));
  static String fasterLabel(int key, double rate) =>
      Speech.t.libraryFasterLabel('$key', speed(rate));
  static String playPauseLabel(bool playing, String title, int key) => playing
      ? Speech.t.libraryPauseLabel(title, '$key')
      : Speech.t.libraryPlayLabel(title, '$key');
  static String resumeLabel(String title, int key) =>
      Speech.t.libraryResumeLabel(title, '$key');
  static String stopLabel(String title, int key) =>
      Speech.t.libraryStopLabel(title, '$key');

  static String playerKeyHelp({
    required int rewind,
    required int playPause,
    required int forward,
    required int slower,
    required int faster,
  }) => Speech.t.libraryPlayerKeyHelp(
    '$rewind',
    '$playPause',
    '$forward',
    '$slower',
    '$faster',
  );

  // ── Learning controls ─────────────────────────────────────────────────────

  static String learningStatus({
    required String title,
    required Duration at,
    required Duration? total,
    required double rate,
    required int bookmarks,
    required bool repeat,
    required bool saving,
    String? issue,
    required String keyHelp,
  }) =>
      '${Speech.t.libraryLearningStatus(title, position(at, total), speed(rate), Speech.t.libraryBookmarkCount(bookmarks), SpokenFormat.onOff(repeat), SpokenFormat.onOff(saving))} '
      '${issue == null ? '' : '$issue '}$keyHelp';

  static String readStatusLabel(String status) =>
      Speech.t.libraryReadStatusLabel(status);
  static String addBookmarkLabel(Duration at) =>
      Speech.t.libraryAddBookmarkLabel(SpokenFormat.duration(at));
  static String bookmarksLabel(int count) =>
      Speech.t.libraryBookmarksLabel(count);
  static String notesLabel(Duration at) =>
      Speech.t.libraryNotesLabel(SpokenFormat.duration(at));
  static String get repeatStartLabel => Speech.t.libraryRepeatStartLabel;
  static String get repeatEndLabel => Speech.t.libraryRepeatEndLabel;
  static String repeatToggleLabel(bool on) => on
      ? Speech.t.libraryRepeatTurnOffLabel
      : Speech.t.libraryRepeatTurnOnLabel;
  static String get repeatClearLabel => Speech.t.libraryRepeatClearLabel;
  static String retryLabel(String issue) => Speech.t.libraryRetryLabel(issue);

  static String bookmarkSaved(Duration at) =>
      Speech.t.libraryBookmarkSaved(SpokenFormat.duration(at));
  static String repeatStartSet(Duration at) =>
      Speech.t.libraryRepeatStartSet(SpokenFormat.duration(at));
  static String repeatEndSet(Duration at) => Announce.pick(
    brief: Speech.t.libraryRepeatEndSetBrief(SpokenFormat.duration(at)),
    detailed: Speech.t.libraryRepeatEndSetDetailed(SpokenFormat.duration(at)),
  );
  static String repeatState(bool on) =>
      Speech.t.libraryRepeatState(SpokenFormat.onOff(on));
  static String get repeatCleared => Speech.t.libraryRepeatCleared;
  static String get progressSaved => Speech.t.libraryProgressSaved;
  static String get actionFailed => Speech.t.libraryActionFailed;
  static String get checkPosition => Speech.t.libraryCheckPosition;

  static String get progressUnavailableTitle =>
      Speech.t.libraryProgressUnavailableTitle;
  static String progressUnavailable(String reason) =>
      Speech.t.libraryProgressUnavailable(reason);
  static String get listenFromBeginning => Speech.t.libraryListenFromBeginning;

  static String get bookmarkNameScreen => Speech.t.libraryBookmarkNameScreen;
  static String get enterBookmarkName => Speech.t.libraryEnterBookmarkName;
  static String bookmarkLabel(String label, Duration at) =>
      Speech.t.libraryBookmarkLabel(label, SpokenFormat.duration(at));
  static String bookmarkJumped(String label, Duration at) =>
      Speech.t.libraryBookmarkJumped(label, SpokenFormat.duration(at));
  static String removeBookmarkLabel(String label) =>
      Speech.t.libraryRemoveBookmarkLabel(label);
  static String removeBookmarkQuestion(String label) =>
      Speech.t.libraryRemoveBookmarkQuestion(label);
  static String bookmarkRemoved(String label) =>
      Speech.t.libraryBookmarkRemoved(label);
  static String get bookmarksScreen => Speech.t.libraryBookmarksScreen;

  // ── Recorded library (teacher session library) ───────────────────────────

  static String recordingsLoaded(int count) => count == 0
      ? Speech.t.libraryNoRecordingsUpload
      : Speech.t.libraryRecordingsLoaded(count);
  static String get loadFailed => Speech.t.libraryLoadFailed;
  static String get titleRequired => Speech.t.libraryTitleRequired;
  static String get pickFailed => Speech.t.libraryPickFailed;
  static String get chooseWorkspaceFirst =>
      Speech.t.libraryChooseWorkspaceFirst;
  static String uploading(String title) => Announce.pick(
    brief: Speech.t.libraryUploadingBrief(title),
    detailed: Speech.t.libraryUploadingDetailed(title),
  );
  static String uploadingOnce(String title) => Announce.pick(
    brief: Speech.t.libraryUploadingBrief(title),
    detailed: Speech.t.libraryUploadingOnceDetailed(title),
  );
  static String uploadProgress(String title, int percent) =>
      Speech.t.libraryUploadProgress(title, SpokenFormat.percent(percent));
  static String uploaded(String title) => Speech.t.libraryUploaded(title);
  static String uploadFailed(String title) =>
      Speech.t.libraryUploadFailed(title);
  static String get uploadNoSession => Speech.t.libraryUploadNoSession;
  static String get uploadNoClass => Speech.t.libraryUploadNoClass;
  static String get fileUnreadable => Speech.t.libraryFileUnreadable;
  static String previewStopped(String title) =>
      Speech.t.libraryPreviewStopped(title);
  static String previewing(String title) => Speech.t.libraryPreviewing(title);
  static String get previewFinished => Speech.t.libraryPreviewFinished;
  static String previewFailed(String title) =>
      Speech.t.libraryPreviewFailed(title);
  static String get noActiveSession => Speech.t.libraryNoActiveSession;
  static String selectedForSession(String title) =>
      Speech.t.librarySelectedForSession(title);
  static String get selectFailed => Speech.t.librarySelectFailed;
  static String get classPlayAccepted => Speech.t.libraryClassPlayAccepted;
  static String get classPlayFailed => Speech.t.libraryClassPlayFailed;
  static String get classPauseAccepted => Speech.t.libraryClassPauseAccepted;
  static String get classPauseFailed => Speech.t.libraryClassPauseFailed;
  static String previewLabel(bool playing, String title, String description) =>
      '${playing ? Speech.t.libraryStopPreviewLabel(title) : Speech.t.libraryPreviewLabel(title)}'
      '${description.isEmpty ? '' : ' $description'}';
  static String broadcastLabel(String title) =>
      Speech.t.libraryBroadcastLabel(title);
  static String sessionLibraryState({
    required int count,
    String? previewing,
    bool uploading = false,
  }) => [
    Speech.t.libraryRecordingsSentence(count),
    if (previewing != null) Speech.t.libraryPreviewingState(previewing),
    if (uploading) Speech.t.libraryUploadInProgress,
  ].join(' ');

  // ── Recorded library home ────────────────────────────────────────────────

  static String get accountChanged => Speech.t.libraryAccountChanged;
  static String get noUnfinished => Speech.t.libraryNoUnfinished;
  static String get cannotCheckAccess => Speech.t.libraryCannotCheckAccess;
  static String get unfinishedUnavailable =>
      Speech.t.libraryUnfinishedUnavailable;
  static String get openingNextUnfinished =>
      Speech.t.libraryOpeningNextUnfinished;
  static String get continueFailed => Speech.t.libraryContinueFailed;
  static String classesLoaded(int count) => count == 0
      ? Speech.t.libraryNoActiveClassesNow
      : Speech.t.libraryClassesLoaded(count);
  static String classesFailed(String reason) =>
      Speech.t.libraryClassesFailed(reason);
  static String get classNotFound => Speech.t.libraryNoClassForSession;
  static String get classesLoading => Speech.t.libraryClassesLoading;
  static String get noActiveClasses => Speech.t.libraryNoActiveClassesStaying;
  static String firstActiveClass(String title) =>
      Speech.t.libraryFirstActiveClass(title);
  static String get openingPlaylists => Speech.t.libraryOpeningPlaylists;
  static String classLabel(String title, int index, int count) =>
      Speech.t.libraryClassLabel(title, '$index', '$count');
  static String homeState({
    required bool loading,
    required int classes,
    String? issue,
  }) => loading
      ? Speech.t.libraryLoadingActiveClasses
      : issue ?? Speech.t.libraryActiveClassesSentence(classes);

  // ── Class audio library ───────────────────────────────────────────────────

  static String classRecordingsLoaded(int count, String where) => count == 0
      ? Speech.t.libraryNoRecordingsFor(where)
      : Speech.t.libraryRecordingsLoadedFor(count, where);
  static String get downloadsReadFailed => Speech.t.libraryDownloadsReadFailed;
  static String get classLoadFailed => Speech.t.libraryClassLoadFailed;
  static String retryAfter(String reason) => Speech.t.libraryRetryAfter(reason);
  static String get downloadedDescription =>
      Speech.t.libraryDownloadedDescription;
  static String get downloadedHelp => Speech.t.libraryDownloadedHelp;
  static String get onlineHelp => Speech.t.libraryOnlineHelp;
  static String get allSubjects => Speech.t.libraryAllSubjects;
  static String subjectChoice(String name, int index, int count) =>
      Speech.t.librarySubjectChoice(name, '$index', '$count');
  static String subjectLabel(String name, int index, int count) =>
      Speech.t.librarySubjectLabel(subjectChoice(name, index, count));
  static String subjectChanged(
    String name,
    int index,
    int count,
    int files,
  ) =>
      '${subjectChoice(name, index, count)}. '
      '${Speech.t.libraryRecordingsSentence(files)}';
  static String get subjectFixed => Speech.t.librarySubjectFixed;
  static String audioLabel({
    required String title,
    String? status,
    required String subject,
    String? description,
    Duration? length,
  }) => [
    title,
    ?status,
    subject,
    if (length != null)
      Speech.t.libraryLength(SpokenFormat.duration(length)),
    if (description != null && description.isNotEmpty) description,
  ].join('. ');
  static String classLibraryState({
    required String player,
    required int count,
    String? subject,
  }) => [
    player,
    subject == null
        ? Speech.t.libraryRecordingsSentence(count)
        : Speech.t.libraryRecordingsInSubject(count, subject),
  ].join(' ');

  // ── Playlists ─────────────────────────────────────────────────────────────

  static String teacherPlaylistsLoaded(int count, String className, String subject) =>
      count == 0
      ? Speech.t.libraryNoTeacherPlaylists(className, subject)
      : Speech.t.libraryTeacherPlaylistsLoaded(count, className, subject);
  static String get playlistCreateFailed =>
      Speech.t.libraryPlaylistCreateFailed;
  static String myPlaylistsLoaded(int private, int classPlaylists) =>
      private == 0 && classPlaylists == 0
      ? Speech.t.libraryNoMyPlaylists
      : Speech.t.libraryMyPlaylistsLoaded(
          Speech.t.libraryPrivatePlaylistCount(private),
          Speech.t.libraryClassPlaylistCount(classPlaylists),
        );
  static String get privatePlaylistCreateFailed =>
      Speech.t.libraryPrivatePlaylistCreateFailed;
  static String playlistsState(int count) =>
      Speech.t.libraryPlaylistsSentence(count);
  static String playlistLoaded(
    String title,
    String place,
    int items,
    String state,
  ) => place.isEmpty
      ? Speech.t.libraryPlaylistLoaded(
          title,
          Speech.t.libraryItemCount(items),
          state,
        )
      : Speech.t.libraryPlaylistLoadedWithPlace(
          title,
          place,
          Speech.t.libraryItemCount(items),
          state,
        );
  static String get playlistRefreshFailed =>
      Speech.t.libraryPlaylistRefreshFailed;
  static String get playlistLessonGone => Speech.t.libraryPlaylistLessonGone;
  static String get nothingToAdd => Speech.t.libraryNothingToAdd;
  static String added(String title) => Speech.t.libraryAddedToPlaylist(title);
  static String get addFailed => Speech.t.libraryAddFailed;
  static String itemUnavailable(String title) =>
      Speech.t.libraryItemUnavailable(title);
  static String itemCannotPlay(String title) =>
      Speech.t.libraryItemCannotPlay(title);
  static String playingItem(String announcement, int index, int count) =>
      Speech.t.libraryPlayingItem(announcement, '$index', '$count');
  static String get playlistPlayFailed => Speech.t.libraryPlaylistPlayFailed;
  static String get playlistEmpty => Speech.t.libraryPlaylistEmpty;
  static String get playlistEnded => Speech.t.libraryPlaylistEnded;
  static String renamed(String title) => Speech.t.libraryRenamed(title);
  static String get renameFailed => Speech.t.libraryRenameFailed;
  static String get alreadyFirst => Speech.t.libraryAlreadyFirst;
  static String get alreadyLast => Speech.t.libraryAlreadyLast;
  static String moved(String title, int position, int count) =>
      Speech.t.libraryMoved(title, '$position', '$count');
  static String moveFailed(String title) => Speech.t.libraryMoveFailed(title);
  static String removedFromPlaylist(String title, String playlist) =>
      Speech.t.libraryRemovedFromPlaylist(title, playlist);
  static String removeFailed(String title) =>
      Speech.t.libraryRemoveFailed(title);
  static String removeItemQuestion(String title, String playlist) =>
      Speech.t.libraryRemoveItemQuestion(title, playlist);
  static String removeItemLabel(String title) =>
      Speech.t.libraryRemoveItemLabel(title);
  static String published(String title, bool publishing) => publishing
      ? Speech.t.libraryPublished(title)
      : Speech.t.libraryReturnedToDraft(title);
  static String publishFailed(String title) =>
      Speech.t.libraryChangeFailed(title);
  static String archived(String title, {required bool deleted, required bool restored}) =>
      deleted
      ? Speech.t.libraryDeleted(title)
      : restored
      ? Speech.t.libraryRestoredAsDraft(title)
      : Speech.t.libraryArchived(title);
  static String archiveFailed(String title) =>
      Speech.t.libraryChangeFailed(title);
  static String playlistItemLabel(String title, String? status, String? subject) =>
      [
        title,
        ?status,
        if (subject != null && subject.isNotEmpty) subject,
      ].join('. ');
  static String playlistState({
    required String player,
    required int items,
    required int selected,
    required String? selectedTitle,
  }) => [
    player,
    if (items == 0)
      Speech.t.libraryPlaylistIsEmpty
    else if (selectedTitle == null)
      Speech.t.librarySelectedItem('$selected', '$items')
    else
      Speech.t.librarySelectedItemTitled('$selected', '$items', selectedTitle),
  ].join(' ');

  // ── Downloads ─────────────────────────────────────────────────────────────

  static String downloadsLoaded(int complete, int partial) =>
      complete + partial == 0
      ? Speech.t.downloadNoneYet
      : partial > 0
      ? Speech.t.downloadReadyToPlayWithPartial(
          Speech.t.downloadLessonCount(complete),
          Speech.t.downloadPartialCount(partial),
        )
      : Speech.t.downloadReadyToPlay(Speech.t.downloadLessonCount(complete));
  static String get downloadsActionFailed => Speech.t.downloadActionFailed;
  static String get onlineListFailed => Speech.t.downloadOnlineListFailed;
  static String availableToDownload(int count) =>
      Speech.t.downloadAvailable(count);
  static String downloadStarting(String title) =>
      Speech.t.downloadStarting(title);
  static String downloadProgress(String title, num percent) =>
      Speech.t.downloadProgress(title, SpokenFormat.percent(percent));
  static String get downloadVerified => Speech.t.downloadVerified;
  static String downloaded(String title) => Speech.t.downloadDone(title);
  static String packQuestion(int count) =>
      Speech.t.downloadPackQuestion(recordings(count));
  static String packStarting(int count) =>
      Speech.t.downloadPackStarting(recordings(count));
  static String packProgress(int done, int total) =>
      Speech.t.downloadPackProgress('$done', '$total');
  static String packDone(int done, int total) =>
      Speech.t.downloadPackDone('$done', '$total');
  static String renewed(String title) => Speech.t.downloadRenewed(title);
  static String removeDownloadTitle(String title) =>
      Speech.t.downloadRemoveTitle(title);
  static String removeDownloadQuestion(String title) =>
      Speech.t.downloadRemoveQuestion(title);
  static String downloadRemoved(String title) =>
      Speech.t.downloadRemoved(title);
  static String unreadableTitle(int id) =>
      Speech.t.downloadUnreadableTitle('$id');
  static String expiry(DateTime expiresAt, {bool revoked = false}) => revoked
      ? Speech.t.downloadRenewalRequired
      : Speech.t.downloadAccessExpires(SpokenFormat.dateTime(expiresAt));
  static String downloadPlayLabel(String title, bool complete, int bytes, String expiry) =>
      complete
      ? Speech.t.downloadPlayLabelComplete(title, size(bytes), expiry)
      : Speech.t.downloadPlayLabelPartial(title, size(bytes), expiry);
  static String renewLabel(String title) => Speech.t.downloadRenewLabel(title);
  static String removeDownloadLabel(String title) =>
      Speech.t.downloadRemoveLabel(title);
  static String unreadableLabel(int id) =>
      Speech.t.downloadUnreadableLabel('$id');
  static String downloadLabel(String title) =>
      Speech.t.downloadOrResumeLabel(title);
  static String cancelDownloadLabel(String title) =>
      Speech.t.downloadCancelLabel(title);
  static String unavailableWhileBusy(String label) =>
      Speech.t.downloadUnavailableWhileBusy(label);
  static String get storageUnknown => Speech.t.downloadStorageUnknown;
  static String downloadsState({
    required int count,
    required int? usedBytes,
    String? downloading,
    int? percent,
  }) => [
    Speech.t.downloadCountComma(count),
    usedBytes == null
        ? Speech.t.downloadStorageUseUnknown
        : storageUsed(usedBytes, 50),
    if (downloading != null)
      percent == null
          ? Speech.t.downloadDownloadingStarting(downloading)
          : Speech.t.downloadDownloadingPercent(
              downloading,
              SpokenFormat.percent(percent),
            ),
  ].join(' ');

  // Library, playlist and notes messages moved out of the screens.
  static String get alreadyOneSubject => Speech.t.libraryAlreadyOneSubject;
  static String get noLessonIsPlaying => Speech.t.libraryNoLessonIsPlaying;
  static String addedToSession(String title) =>
      Speech.t.libraryAddedToSession(title);
  static String get playlistNotCreated => Speech.t.libraryPlaylistNotCreated;
  static String get privatePlaylistNotCreated =>
      Speech.t.libraryPrivatePlaylistNotCreated;
  static String get noEligibleAudio => Speech.t.libraryNoEligibleAudio;
  static String get audioAddedToPlaylist => Speech.t.libraryAudioAddedToPlaylist;
  static String unavailable(Object? title) =>
      Speech.t.libraryUnavailable('$title');
  static String playlistRenamed(String title) =>
      Speech.t.libraryPlaylistRenamed(title);
  static String movedTo(String title, int position) =>
      Speech.t.libraryMovedTo(title, '$position');
  static String get noteRenamed => Speech.t.libraryNoteRenamed;
}
