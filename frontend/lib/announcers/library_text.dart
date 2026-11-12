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
  static String speed(double speed) => '${speedNumber(speed)} times';

  /// "1 minute 5 seconds of 4 minutes".
  static String position(Duration at, Duration? total) =>
      SpokenFormat.position(at, total);

  static const noClassForSession = 'No class found with this session name.';

  /// "Subject filter: Science, 2 of 4. Key 2, or left or right to change".
  static String subjectFilterLabel(String? name, int index, int total) =>
      'Subject filter: ${name ?? 'All subjects'}'
      '${total > 1 && index >= 0 ? ', ${index + 1} of $total' : ''}. '
      'Key 2, or left or right to change';

  static String restoredToPlaylist(String title) =>
      '$title is back in the playlist.';

  /// "12 megabytes", "1.5 megabytes", "less than 0.1 megabytes".
  static String size(int bytes) {
    if (bytes <= 0) return '0 megabytes';
    final megabytes = bytes / 1000000;
    if (megabytes < 0.1) return 'less than 0.1 megabytes';
    final text = megabytes < 10
        ? megabytes.toStringAsFixed(1).replaceFirst(RegExp(r'\.0$'), '')
        : '${megabytes.round()}';
    return '$text ${text == '1' ? 'megabyte' : 'megabytes'}';
  }

  /// "12 megabytes used of 50."
  static String storageUsed(int bytes, int limitMegabytes) =>
      '${size(bytes)} used of $limitMegabytes.';

  static String recordings(int count) => SpokenFormat.count(count, 'recording');

  // ── Lesson player ─────────────────────────────────────────────────────────

  static String playing(
    String title,
    Duration at,
    Duration? total,
    double rate,
  ) => Announce.pick(
    brief: '$title, playing from ${position(at, total)}.',
    detailed:
        '$title, playing from ${position(at, total)}, speed ${speed(rate)}.',
  );

  static String paused(Duration at, Duration? total) =>
      'Paused at ${position(at, total)}.';

  /// Star summary: "Playing Food story, 1 minute 5 seconds of 4 minutes,
  /// speed 1.25 times."
  static String playerState({
    required String? title,
    required bool playing,
    required Duration at,
    required Duration? total,
    required double rate,
  }) => title == null
      ? 'Nothing playing.'
      : '${playing ? 'Playing' : 'Paused'} $title, ${position(at, total)}, '
            'speed ${speed(rate)}.';

  static String speedChanged(double rate) => 'Speed ${speed(rate)}.';
  static const slowest = 'Already at the slowest speed.';
  static const fastest = 'Already at the fastest speed.';
  static const noLessonLoaded =
      'No lesson is loaded. Choose a lesson to play first.';
  static String noLessonPlaying(int playKey) =>
      'No lesson is playing. Press $playKey to play the first lesson.';
  static const nothingPlaying = 'Nothing is playing.';
  static const nothingPlayingHint =
      'Nothing playing. Select a lesson or press 5.';
  static String stopped(String title) => '$title stopped.';
  static String finished(String title) => '$title finished.';
  static const waitForPlayer = 'Please wait for the lesson player.';
  static const seekFailed = 'Could not move to that lesson position. Try again.';
  static const speedFailed = 'Could not change playback speed. Try again.';
  static String playFailed(String title) =>
      'Could not play $title. Check your connection, then select it again.';
  static const checkingOfflineAccess =
      'Internet unavailable. Checking your saved offline access.';
  static const lessonGone =
      'This lesson is no longer available. Your saved progress and bookmarks are kept.';

  static String seekLabel(Duration at, Duration? total) =>
      'Lesson position ${position(at, total)}. '
      'Use left or right to move 10 seconds.';
  static String rewindLabel(int key) => 'Back 10 seconds, key $key';
  static String forwardLabel(int key) => 'Forward 10 seconds, key $key';
  static String slowerLabel(int key, double rate) =>
      'Slower, key $key. Now ${speed(rate)}';
  static String fasterLabel(int key, double rate) =>
      'Faster, key $key. Now ${speed(rate)}';
  static String playPauseLabel(bool playing, String title, int key) =>
      '${playing ? 'Pause' : 'Play'} $title, key $key';
  static String resumeLabel(String title, int key) => 'Resume $title, key $key';
  static String stopLabel(String title, int key) => 'Stop $title, key $key';

  static String playerKeyHelp({
    required int rewind,
    required int playPause,
    required int forward,
    required int slower,
    required int faster,
  }) =>
      'Press $rewind to go back 10 seconds, $playPause to play or pause, '
      '$forward to go forward 10 seconds, $slower for slower and $faster for faster.';

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
      '$title. Position ${position(at, total)}. Speed ${speed(rate)}. '
      '${SpokenFormat.count(bookmarks, 'bookmark')}. '
      'A-B repeat ${repeat ? 'on' : 'off'}. '
      'Progress saving ${saving ? 'on' : 'off'}. '
      '${issue == null ? '' : '$issue '}$keyHelp';

  static String readStatusLabel(String status) =>
      'Read learning status. $status';
  static String addBookmarkLabel(Duration at) =>
      'Add bookmark at ${SpokenFormat.duration(at)}';
  static String bookmarksLabel(int count) =>
      'Bookmarks. ${SpokenFormat.count(count, 'saved point')}';
  static String notesLabel(Duration at) =>
      'Private study notes at ${SpokenFormat.duration(at)}. '
      'Pauses the lesson before opening';
  static const repeatStartLabel = 'Set repeat start A at the current position';
  static const repeatEndLabel = 'Set repeat end B after start A';
  static String repeatToggleLabel(bool on) =>
      on ? 'Turn A-B repeat off' : 'Turn A-B repeat on';
  static const repeatClearLabel = 'Clear saved A-B repeat points';
  static String retryLabel(String issue) =>
      'Retry saving learning progress. $issue';

  static String bookmarkSaved(Duration at) =>
      'Bookmark saved at ${SpokenFormat.duration(at)}.';
  static String repeatStartSet(Duration at) =>
      'Repeat start set at ${SpokenFormat.duration(at)}.';
  static String repeatEndSet(Duration at) => Announce.pick(
    brief: 'Repeat end set at ${SpokenFormat.duration(at)}.',
    detailed:
        'Repeat end set at ${SpokenFormat.duration(at)}. '
        'Select Repeat on to start looping.',
  );
  static String repeatState(bool on) => 'A-B repeat ${on ? 'on' : 'off'}.';
  static const repeatCleared = 'A-B repeat points cleared.';
  static const progressSaved = 'Learning progress saved.';
  static const actionFailed =
      'The player could not complete this action. Check playback and try again.';
  static const checkPosition = 'Check the lesson position and try again.';

  static const progressUnavailableTitle = 'Saved progress unavailable';
  static String progressUnavailable(String reason) =>
      '$reason Listen from the beginning without changing saved data? '
      'Saving stays off until you retry successfully.';
  static const listenFromBeginning = 'Listen from beginning';

  static const bookmarkNameScreen =
      'Name bookmark. Press OK to edit. Up or down leaves editing.';
  static const enterBookmarkName = 'Enter a bookmark name.';
  static String bookmarkLabel(String label, Duration at) =>
      '$label. ${SpokenFormat.duration(at)}. Jump to bookmark';
  static String bookmarkJumped(String label, Duration at) =>
      '$label. Position ${SpokenFormat.duration(at)}.';
  static String removeBookmarkLabel(String label) => 'Remove $label';
  static String removeBookmarkQuestion(String label) =>
      'Remove $label? This does not remove the lesson or any other bookmarks.';
  static String bookmarkRemoved(String label) => '$label removed.';
  static const bookmarksScreen =
      'Bookmarks. Select a point to jump. This does not start paused playback. '
      'Remove asks for confirmation.';

  // ── Recorded library (teacher session library) ───────────────────────────

  static String recordingsLoaded(int count) => count == 0
      ? 'No recordings yet. Press 2 to upload audio.'
      : '${recordings(count)} loaded.';
  static const loadFailed =
      'Could not load recordings. Check your internet connection, then press 1 to retry.';
  static const titleRequired = 'Title is required.';
  static const pickFailed = 'Could not open the file. Try choosing it again.';
  static const chooseWorkspaceFirst =
      'Choose a class and subject workspace on the Teacher Dashboard before uploading audio.';
  static String uploading(String title) => Announce.pick(
    brief: 'Uploading $title.',
    detailed: 'Uploading $title. You will hear progress every 25 percent.',
  );
  static String uploadingOnce(String title) => Announce.pick(
    brief: 'Uploading $title.',
    detailed: 'Uploading $title. Please wait; you will hear when it finishes.',
  );
  static String uploadProgress(String title, int percent) =>
      '$title: ${SpokenFormat.percent(percent)} uploaded.';
  static String uploaded(String title) => '$title uploaded.';
  static String uploadFailed(String title) =>
      '$title could not be uploaded. Check your connection, then press 3 to try again.';
  static const uploadNoSession =
      'Upload cancelled. Select at least one session, then press 3 to add audio again.';
  static const uploadNoClass =
      'The session class and subject could not be determined.';
  static const fileUnreadable = 'Could not read the file. Choose it again.';
  static String previewStopped(String title) => 'Preview of $title stopped.';
  static String previewing(String title) => 'Previewing $title privately.';
  static const previewFinished = 'Preview finished.';
  static String previewFailed(String title) =>
      'Could not play $title. Check your connection and try again.';
  static const noActiveSession = 'No active session.';
  static String selectedForSession(String title) =>
      'Selected $title for the session.';
  static const selectFailed = 'Could not select the audio. Try again.';
  static const classPlayAccepted = 'Class playback request accepted.';
  static const classPlayFailed = 'Could not start class playback. Try again.';
  static const classPauseAccepted = 'Class pause request accepted.';
  static const classPauseFailed = 'Could not pause class audio. Try again.';
  static String previewLabel(bool playing, String title, String description) =>
      '${playing ? 'Stop preview of' : 'Preview'} $title privately. '
      'Only you can hear this.${description.isEmpty ? '' : ' $description'}';
  static String broadcastLabel(String title) =>
      'Play $title for everyone in the session';
  static String sessionLibraryState({
    required int count,
    String? previewing,
    bool uploading = false,
  }) => [
    '${recordings(count)}.',
    if (previewing != null) 'Previewing $previewing.',
    if (uploading) 'Upload in progress.',
  ].join(' ');

  // ── Recorded library home ────────────────────────────────────────────────

  static const accountChanged = 'Your account changed. Open the library again.';
  static const noUnfinished =
      'No unfinished lesson is saved for this account. Choose a recorded lesson to start learning.';
  static const cannotCheckAccess =
      'Could not check lesson access. Connect to the internet and retry. Your saved progress is kept.';
  static const unfinishedUnavailable =
      'Your unfinished lessons are not currently available in this library. Your saved progress and bookmarks are kept.';
  static const openingNextUnfinished =
      'The most recent lesson is unavailable here. Opening your next most recent available unfinished lesson. Saved progress is kept.';
  static const continueFailed =
      'Could not open saved learning progress. Check storage, your connection, and sign-in, then retry.';
  static String classesLoaded(int count) => count == 0
      ? 'No active classes right now. Press 3 for all audio files.'
      : '${SpokenFormat.count(count, 'active class', 'active classes')} loaded.';
  static String classesFailed(String reason) =>
      '$reason Active classes could not be refreshed. Press 1 to retry. Saved downloads remain available.';
  static const classNotFound = 'No class found with this session name.';
  static const classesLoading =
      'Classes are still loading. Try key 5 again shortly.';
  static const noActiveClasses =
      'There are no active classes. Staying in the audio library.';
  static String firstActiveClass(String title) =>
      '$title. First active class. '
      'Use D-pad up and down to browse active class sessions. '
      'Press OK to open the selected class recordings.';
  static const openingPlaylists =
      'Opening My Playlists. Playlist contents are private.';
  static String classLabel(String title, int index, int count) =>
      '$title. Class $index of $count';
  static String homeState({
    required bool loading,
    required int classes,
    String? issue,
  }) => loading
      ? 'Loading active classes.'
      : issue ??
            '${SpokenFormat.count(classes, 'active class', 'active classes')}.';

  // ── Class audio library ───────────────────────────────────────────────────

  static String classRecordingsLoaded(int count, String where) => count == 0
      ? 'No recordings yet for $where.'
      : '${recordings(count)} loaded for $where.';
  static const downloadsReadFailed =
      'Could not read downloaded lessons. Press 1 to retry.';
  static const classLoadFailed =
      'Could not load recordings. Check your internet connection and sign-in, then press 1 to retry.';
  static String retryAfter(String reason) => '$reason Press 1 to retry.';
  static const downloadedDescription =
      'Downloaded recording. Access renewal required after 30 days.';
  static const downloadedHelp =
      'Downloaded lessons. Existing offline access is checked before playing.';
  static const onlineHelp =
      'Audio Library. Online recordings require internet. Download lessons for offline playback.';
  static const allSubjects = 'All subjects';
  static String subjectChoice(String name, int index, int count) =>
      'Subject: $name, $index of $count';
  static String subjectLabel(String name, int index, int count) =>
      '${subjectChoice(name, index, count)}. '
      'Press 2, or left and right, to change';
  static String subjectChanged(
    String name,
    int index,
    int count,
    int files,
  ) => '${subjectChoice(name, index, count)}. ${recordings(files)}.';
  static const subjectFixed =
      'This library is already limited to one subject.';
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
    if (length != null) 'Length ${SpokenFormat.duration(length)}',
    if (description != null && description.isNotEmpty) description,
  ].join('. ');
  static String classLibraryState({
    required String player,
    required int count,
    String? subject,
  }) => [
    player,
    '${recordings(count)}${subject == null ? '' : ' in $subject'}.',
  ].join(' ');

  // ── Playlists ─────────────────────────────────────────────────────────────

  static String teacherPlaylistsLoaded(int count, String className, String subject) =>
      count == 0
      ? 'No playlists yet for $className, $subject. Press 2 to create one.'
      : '${SpokenFormat.count(count, 'playlist')} loaded for $className, $subject.';
  static const playlistCreateFailed = 'Playlist could not be created.';
  static String myPlaylistsLoaded(int private, int classPlaylists) =>
      private == 0 && classPlaylists == 0
      ? 'No playlists yet. Press 2 to create a private playlist.'
      : '${SpokenFormat.count(private, 'private playlist')} and '
            '${SpokenFormat.count(classPlaylists, 'class playlist')} loaded.';
  static const privatePlaylistCreateFailed =
      'Private playlist could not be created.';
  static String playlistsState(int count) =>
      '${SpokenFormat.count(count, 'playlist')}.';
  static String playlistLoaded(
    String title,
    String place,
    int items,
    String state,
  ) => '$title. ${place.isEmpty ? '' : '$place. '}'
      '${SpokenFormat.count(items, 'item')}. $state.';
  static const playlistRefreshFailed =
      'Could not refresh this playlist. Check your connection and try again. Existing playback and saved progress have not been changed.';
  static const playlistLessonGone =
      'The current lesson is no longer available in this playlist. Playback stopped. Your saved progress and bookmarks are kept.';
  static const nothingToAdd = 'No eligible audio is available to add.';
  static String added(String title) => '$title added to the playlist.';
  static const addFailed =
      'Could not add the audio. Check your connection and try again.';
  static String itemUnavailable(String title) =>
      '$title is no longer available in your current class. You can remove it from this playlist.';
  static String itemCannotPlay(String title) => '$title is unavailable.';
  static String playingItem(String announcement, int index, int count) =>
      '$announcement Item $index of $count.';
  static const playlistPlayFailed =
      'Could not play this lesson. Check your connection and try again.';
  static const playlistEmpty = 'Playlist is empty.';
  static const playlistEnded = 'End of playlist. Playback stopped.';
  static String renamed(String title) => 'Playlist renamed to $title.';
  static const renameFailed =
      'Could not rename the playlist. Check your connection and try again.';
  static const alreadyFirst = 'The selected item is already first.';
  static const alreadyLast = 'The selected item is already last.';
  static String moved(String title, int position, int count) =>
      '$title moved to position $position of $count.';
  static String moveFailed(String title) =>
      'Could not move $title. Check your connection and try again.';
  static String removedFromPlaylist(String title, String playlist) =>
      'Removed $title from $playlist.';
  static String removeFailed(String title) =>
      'Could not remove $title. Check your connection and try again.';
  static String removeItemQuestion(String title, String playlist) =>
      'Remove $title from $playlist? The recording itself is kept in the library.';
  static String removeItemLabel(String title) =>
      'Remove $title from playlist, asks to confirm';
  static String published(String title, bool publishing) => publishing
      ? '$title published to the class.'
      : '$title returned to draft.';
  static String publishFailed(String title) =>
      'Could not change $title. Check your connection and try again.';
  static String archived(String title, {required bool deleted, required bool restored}) =>
      deleted
      ? '$title deleted.'
      : restored
      ? '$title restored as a draft.'
      : '$title archived.';
  static String archiveFailed(String title) =>
      'Could not change $title. Check your connection and try again.';
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
      'The playlist is empty.'
    else
      'Selected item $selected of $items${selectedTitle == null ? '' : ', $selectedTitle'}.',
  ].join(' ');

  // ── Downloads ─────────────────────────────────────────────────────────────

  static String downloadsLoaded(int complete, int partial) =>
      complete + partial == 0
      ? 'No downloads yet. Press 2 to find recordings online.'
      : '${SpokenFormat.count(complete, 'downloaded lesson')} ready to play'
            '${partial > 0 ? ', ${SpokenFormat.count(partial, 'partial download')}' : ''}.';
  static const downloadsActionFailed =
      'Could not complete this download action. Check storage, your connection and sign-in, then retry.';
  static const onlineListFailed =
      'Could not load available recordings. Existing downloads still work until their access expires.';
  static String availableToDownload(int count) =>
      '${SpokenFormat.count(count, 'recording is', 'recordings are')} available to download. '
      'Select the recordings you want.';
  static String downloadStarting(String title) =>
      'Downloading $title. You will hear progress every 25 percent.';
  static String downloadProgress(String title, num percent) =>
      '$title ${SpokenFormat.percent(percent)} downloaded.';
  static const downloadVerified =
      'Download verified and saved for offline playback.';
  static String downloaded(String title) =>
      '$title downloaded, verified and saved for offline playback.';
  static String packQuestion(int count) =>
      'Download ${recordings(count)} one at a time? This uses internet data and your account’s 50 MB allowance. On failure or cancellation, verified downloads and partial data are kept. No existing lesson is deleted.';
  static String packStarting(int count) =>
      'Downloading ${recordings(count)}, one at a time.';
  static String packProgress(int done, int total) =>
      '$done of $total recordings verified.';
  static String packDone(int done, int total) =>
      '$done of $total recordings verified and saved.';
  static String renewed(String title) =>
      'Access renewed for $title. Up to 30 days of offline playback.';
  static String removeDownloadTitle(String title) =>
      'Remove download of $title?';
  static String removeDownloadQuestion(String title) =>
      'Remove the downloaded or partial audio for $title? Learning progress and bookmarks are kept. Other recordings and accounts are not affected.';
  static String downloadRemoved(String title) =>
      'Removed the download of $title. Progress and bookmarks kept.';
  static String unreadableTitle(int id) => 'unreadable recording $id';
  static String expiry(DateTime expiresAt, {bool revoked = false}) => revoked
      ? 'Access renewal required.'
      : 'Access expires ${SpokenFormat.dateTime(expiresAt)}.';
  static String downloadPlayLabel(String title, bool complete, int bytes, String expiry) =>
      'Play $title. ${complete ? 'Downloaded' : 'Partial download, cannot play yet'}. '
      '${size(bytes)}. $expiry';
  static String renewLabel(String title) =>
      'Renew access for $title. Requires internet';
  static String removeDownloadLabel(String title) =>
      'Remove download of $title, asks to confirm';
  static String unreadableLabel(int id) =>
      'Unreadable download record $id. Remove only this download, asks to confirm';
  static String downloadLabel(String title) => 'Download or resume $title';
  static String cancelDownloadLabel(String title) =>
      'Cancel download of $title, key 4. Keep partial data for retry';
  static String unavailableWhileBusy(String label) =>
      '$label is unavailable while downloads are busy.';
  static const storageUnknown =
      'Storage reservation unavailable. Refresh downloads or remove the selected unreadable records before downloading.';
  static String downloadsState({
    required int count,
    required int? usedBytes,
    String? downloading,
    int? percent,
  }) => [
    '${SpokenFormat.count(count, 'download')},',
    usedBytes == null ? 'storage use unknown.' : storageUsed(usedBytes, 50),
    if (downloading != null)
      'Downloading $downloading, ${percent == null ? 'starting' : SpokenFormat.percent(percent)}.',
  ].join(' ');

  // Library, playlist and notes messages moved out of the screens.
  static const alreadyOneSubject = 'This library is already limited to one subject';
  static const noLessonIsPlaying = 'No lesson is playing.';
  static String addedToSession(String title) => '$title added to this session.';
  static const playlistNotCreated = 'Playlist could not be created';
  static const privatePlaylistNotCreated = 'Private playlist could not be created';
  static const noEligibleAudio = 'No eligible audio is available to add';
  static const audioAddedToPlaylist = 'Audio added to playlist';
  static String unavailable(Object? title) => '$title is unavailable';
  static String playlistRenamed(String title) => 'Playlist renamed to $title';
  static String movedTo(String title, int position) =>
      '$title moved to position $position';
  static const noteRenamed = 'Private note renamed.';
}
