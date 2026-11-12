import '../utils/spoken_format.dart';
import 'announce.dart';

/// Every sentence spoken or shown by the live class (session) screens, kept
/// in one place so wording stays consistent and can be translated later.
abstract final class SessionText {
  // ─── Main screen ──────────────────────────────────────────────────────────
  static String screenName({
    required bool teacher,
    required String title,
    String? className,
    String? subjectName,
  }) => [
    teacher ? 'Teacher class' : 'Class',
    title,
    ?className,
    ?subjectName,
  ].join(', ');

  static const joining = 'Joining the class. Please wait.';
  static const connecting = 'Connecting to the class.';
  static const joinFailed =
      'The class could not be joined. Press 0 to leave, then try again.';
  static const leaveKeyHint = 'Press 0 to leave the class. It asks to confirm.';
  static const keyLine = '*: Help. #: Stop app speech. 8: Last message.';

  static String joined({
    required bool teacher,
    required String status,
    required String keys,
  }) => Announce.pick(
    brief: 'In class. $status Press star for help.',
    detailed:
        'You are in the class. $status $keys '
        'Use up and down to move between controls and OK to select. '
        'Press star for where you are and help. Press hash to stop speech.',
  );

  static String keyHelp(Map<int, String> labels) {
    final keys = labels.entries.toList()
      ..sort((a, b) => (a.key == 0 ? 10 : a.key).compareTo(b.key == 0 ? 10 : b.key));
    return keys.map((e) => 'Press ${e.key} for ${e.value}.').join(' ');
  }

  // Focus labels and visible button text on the main screen.
  static String muteLabel(bool muted, bool pending) => pending
      ? 'Microphone waiting for confirmation'
      : muted
      ? 'Unmute microphone'
      : 'Mute microphone';
  static String muteButton(bool muted, bool pending) =>
      pending ? '1: Waiting' : '1: ${muted ? 'Unmute' : 'Mute'}';
  static String handLabel(bool raised, bool pending) => pending
      ? 'Hand waiting for confirmation'
      : raised
      ? 'Lower hand'
      : 'Raise hand';
  static String handButton(bool raised, bool pending) =>
      pending ? '2: Waiting' : '2: ${raised ? 'Lower hand' : 'Raise hand'}';
  static const statusLabel = 'Hear class status';
  static const statusButton = '3: Class status';
  static String chatLabel(int count) => count == 0
      ? 'Chat. No messages yet'
      : 'Chat. ${SpokenFormat.count(count, 'message')}';
  static const chatButton = '4: Chat';
  static String recordingLabel({
    required bool teacher,
    required String? title,
    required bool playing,
  }) {
    if (teacher) {
      return title == null
          ? 'Class recording player. No recording selected yet'
          : 'Class recording player. $title, ${playing ? 'playing' : 'paused'}';
    }
    if (title == null) {
      return 'Class recording. Nothing playing. Only the teacher controls it';
    }
    return 'Class recording, $title, ${playing ? 'playing' : 'paused'} by the '
        'teacher. Hear where it is';
  }

  /// Student key 5: read only, the teacher controls the recording.
  static const recordingStatusButton = '5: Recording status';
  static String studentRecordingStatus({
    required String? title,
    required bool playing,
    required String position,
  }) => title == null
      ? 'No class recording is playing. Only the teacher can play one.'
      : '$title, ${playing ? 'playing' : 'paused'}, at $position. '
            'Only the teacher can play, pause or move the class recording.';
  static const recordingPlayerButton = '5: Recording player';
  static const openingPlayerToChoose =
      'No recording is selected yet. Press 1 to choose one.';
  static const checkLabel = 'Answer classroom check. Private and ungraded';
  static const checkButton = '6: Classroom check';
  // Teacher-only main screen controls.
  static String handsLabel(int count) =>
      'Raised hands. ${handsWaiting(count)} Acknowledge and lower hands in order';
  static String handsButton(int count) =>
      count == 0 ? '2: Raised hands' : '2: Raised hands ($count)';
  static const teacherCheckLabel =
      'Classroom check. Start a private check, close it and hear responses';
  static String participantsLabel(int count) =>
      'Participants. ${people(count)} Mute or remove someone, or hear a summary';
  static const participantsButton = '7: Participants';
  static const toolsLabel =
      'Teacher tools. Invite students or end the class for everyone';
  static const toolsButton = '9: Teacher tools';
  static const voiceStartLabel =
      'Listen for one voice command, up to 12 seconds. Starts only when you press OK';
  static const voiceStopLabel = 'Stop listening for a voice command';
  static const voiceStartButton = 'Listen for command';
  static const voiceStopButton = 'Stop listening';
  static const updatesLabel = 'Read class updates';
  static const updatesButton = 'Class updates';
  static const retryLabel = 'Retry class connection';
  static const retryButton = 'Retry connection';
  static const leaveLabel = 'Leave class and return to your dashboard';
  static const leaveButton = '0: Leave class';

  // ─── Status ("where am I" and key 3) ─────────────────────────────────────
  static String micState(bool muted, bool pending) => pending
      ? 'Microphone waiting for confirmation.'
      : muted
      ? 'Muted.'
      : 'Unmuted. Others can hear you.';
  static String handState(bool raised, bool pending) => pending
      ? 'Hand waiting for confirmation.'
      : raised
      ? 'Hand raised.'
      : 'Hand down.';
  static String handsWaiting(int count) => count == 0
      ? 'No hands waiting.'
      : '${SpokenFormat.count(count, 'hand')} waiting.';
  static String people(int count) =>
      '${SpokenFormat.count(count, 'person', 'people')} in the class.';
  static String recordingState({
    required String? title,
    required bool playing,
  }) {
    if (title == null) {
      return Announce.pick(brief: '', detailed: 'No recording selected.');
    }
    return 'Recording ${playing ? 'playing' : 'paused'}: $title.';
  }

  static const checkOpen = 'Classroom check open.';
  static String connection(String label) => '$label.';
  static String messages(int count) =>
      count == 0 ? '' : '${SpokenFormat.count(count, 'chat message')}.';

  // ─── Connection ──────────────────────────────────────────────────────────
  static String connectionRestored(String message) =>
      'Connection restored. $message';
  static String connectionLost(bool everConnected, String message) =>
      '${everConnected ? 'Connection lost.' : 'Could not connect.'} $message';

  // ─── Microphone ──────────────────────────────────────────────────────────
  static const micDialogTitle = 'Microphone access';
  static const micDialogMessage =
      'In this class SEEDS uses the microphone for live audio and explicitly '
      'activated voice commands. You can stay without microphone access, but '
      'others will not hear you. Separate private-note recording requires its '
      'own explicit start outside live classes.';
  static const micDialogConfirm = 'Continue to class';
  static const micSkipped =
      'Microphone access was skipped. You joined the class muted.';
  static const micUnavailable =
      'Microphone access is unavailable. You joined the class muted.';
  static const waitingMic = 'Waiting for microphone confirmation.';
  static const muted = 'Muted';
  static String get unmuted =>
      Announce.pick(brief: 'Unmuted', detailed: 'Unmuted. Others can hear you.');
  static const mutedLocallyOnly =
      'Microphone muted on this phone. The class confirmation was not received.';
  static const mutedByTeacher = 'The teacher muted your microphone.';

  // ─── Hand ────────────────────────────────────────────────────────────────
  static const waitingHand = 'Waiting for hand status confirmation.';
  static const handRaised = 'Hand raised';
  static const handLowered = 'Hand lowered';
  static const handNotConfirmed =
      'Your hand change was not confirmed. Press 2 to try again.';
  static String raisedHandBy(String? name) =>
      '${name ?? 'A participant'} raised hand. Press 2 for raised hands.';

  // ─── Participants ────────────────────────────────────────────────────────
  static const participantJoined = 'A participant joined.';
  static const participantsJoinedGroup = 'Participants joined';
  static const participantLeft = 'A participant left.';
  static const participantsLeftGroup = 'Participants left';
  static String participant(Map<String, dynamic> p, {
    required bool self,
    required bool muted,
    required bool speaking,
  }) {
    final name = p['name'] as String? ?? 'Participant';
    return [
      self ? '$name, you' : name,
      p['is_teacher'] == true ? 'teacher' : 'student',
      if (p['raised_hand'] == true) 'hand raised',
      muted ? 'muted' : 'unmuted',
      if (speaking) 'speaking',
    ].join(', ');
  }

  static String alreadyMuted(String name) =>
      '$name is muted. Only $name can unmute.';
  static String participantMuted(String name) => '$name muted.';
  static String removeTitle(String name) => 'Remove $name?';
  static String removeMessage(String name) =>
      '$name will be removed from this class and returned to their '
      'dashboard. They can be invited again later.';
  static String keep(String name) => 'Keep $name';
  static String remove(String name) => 'Remove $name';
  static String removed(String name) => '$name removed from the class.';

  // ─── Chat ────────────────────────────────────────────────────────────────
  static String messageFrom(String sender, String text) =>
      'Message from $sender: $text';
  static const waitingMessage = 'Waiting for message confirmation.';
  static const emptyMessage = 'Enter a message before selecting Send.';
  static const messageSent = 'Message sent.';
  static const sending = 'Sending';
  static const sent = 'Sent';
  static const notConfirmed = 'Not confirmed';
  static const noMessages = 'No messages yet.';
  static const chatTitle = 'Chat';
  static const readMessages = 'Read messages, newest first';
  static const writeMessage = 'Write a message';
  static const messageField = 'Your message to the class';
  static const messagesTitle = 'Chat messages';
  static const quickPhrases = [
    'I understood',
    'Please repeat',
    'I have a question',
  ];
  static String sendPhrase(String phrase) => 'Send: $phrase';
  static String chatCount(int count) =>
      count == 0 ? noMessages : '${SpokenFormat.count(count, 'message')}.';
  static String get chatHelp => Announce.pick(
    brief: 'Read, write or send a quick phrase.',
    detailed:
        'Press 1 to read messages, 2 to write one, or 3 to 5 to send a quick '
        'phrase. Press 8 to hear the newest message.',
  );
  static String messageLine(Map<String, dynamic> message) {
    final sender = message['isMe'] == true ? 'You' : '${message['sender']}';
    final delivery = message['delivery'];
    return '$sender: ${message['text']}${delivery == null ? '' : '. $delivery'}';
  }

  static String messageDetail(Map<String, dynamic> message) {
    final at = message['timestamp'];
    return '${messageLine(message)}.'
        '${at is DateTime ? ' Sent ${SpokenFormat.timeOfDay(at)}.' : ''}';
  }

  static String latestMessage(Map<String, dynamic>? message) =>
      message == null ? noMessages : 'Newest message. ${messageDetail(message)}';

  // ─── Leaving and ending ─────────────────────────────────────────────────
  static const leaveTitle = 'Leave class?';
  static const leaveMessage =
      'You will leave this class and return to your dashboard. '
      'You will remain logged in.';
  static const teacherLeaveMessage =
      'You will leave and return to your dashboard. The class keeps running '
      'for students. To end it for everyone, use 9, Teacher tools.';
  static const stay = 'Stay in class';
  static const leave = 'Leave class';
  static const leaveLocallyTitle = 'Leave without server confirmation?';
  static const leaveLocallyMessage =
      'This phone is muted. The server did not confirm clearing your raised '
      'hand. Leave locally now, or stay and retry? A fresh join resets your hand.';
  static const stayAndRetry = 'Stay and retry';
  static const leaveLocally = 'Leave locally';
  static const endTitle = 'End class for everyone?';
  static const endMessage =
      'This stops the class for every participant and returns everyone to '
      'their dashboard. Nobody will be logged out.';
  static const endCancel = 'Keep the class going';
  static const endConfirm = 'End for everyone';
  static const waitingEnd = 'Waiting for end-class confirmation.';
  static const endNotConfirmed =
      'Ending the class was not confirmed. The class is still running.';
  static const endingForEveryone = 'Ending the class for everyone.';
  static const youLeft = 'You left the class.';
  static const classEnded = 'The class has ended.';
  static const youWereRemoved = 'You were removed from the class.';
  static const signInChanged =
      'Your sign-in changed. Sign in again or contact your school administrator.';
  static const cleanupFailed =
      'Sign-in ended. Native audio cleanup could not be confirmed. Close SEEDS if audio continues.';
  static const cleanupTimedOut =
      'Sign-in ended. Audio cleanup timed out. Close SEEDS if audio continues.';
  static const requestFailed =
      'We could not complete that request. Please try again.';

  // ─── Voice commands ──────────────────────────────────────────────────────
  static const voiceStopped = 'Voice listening stopped.';
  static const voiceUnmuteTitle = 'Unmute your microphone?';
  static const voiceUnmuteMessage =
      'A voice command requested unmute. Confirm with a key or touch. Other '
      'class members will be able to hear you.';
  static const voiceUnmuteConfirm = 'Unmute';
  static const voiceUnmuteCancel = 'Stay muted';
  static const alreadyUnmuted = 'Already unmuted';
  static const alreadyMutedSelf = 'Already muted';
  static const handAlreadyLowered = 'Hand is already lowered';
  static const handAlreadyRaised = 'Hand is already raised';
  static const commandNotRecognized = 'Command not recognized';
  // Voice controller status and issues.
  static const voiceStopUnconfirmed =
      'Voice listening stop not confirmed. Retry stopping.';
  static const voiceStopping = 'Stopping voice listening.';
  static const voiceStarting = 'Starting voice commands.';
  static const voiceFinishing = 'Finishing voice recognition.';
  static const voiceListening = 'Listening for one command, up to 12 seconds.';
  static const voiceIdle = 'Not listening. Activate Listen for command to start.';
  static const voiceSpeechNotStopped =
      'App speech could not be stopped. Try Stop speech before listening.';
  static const voiceUnavailable =
      'Voice commands are unavailable. Check microphone permission and Android English speech services.';
  static const voiceCouldNotStart =
      'Voice commands could not start. Check microphone permission and English speech services, then try again.';
  static const voiceCouldNotFinish =
      'Voice recognition could not finish. Check permission and English speech services, then activate Listen to retry.';
  static const voiceNoCommand =
      'No command heard. Activate Listen for command to try again.';
  static const voiceCommandFailed =
      'The voice command could not be completed. Use its keypad control or try again.';
  static const voiceCannotStop =
      'Voice listening could not be stopped. Retry Stop listening or leave the class and check the Android microphone indicator.';

  // ─── Class recording ─────────────────────────────────────────────────────
  static const recordingSelectionChanged =
      'The class recording selection changed. Use Read class updates for details.';
  static const recordingSelectionGroup = 'Class recording selection';
  static const playbackFinished = 'Recording finished.';
  static const noRecording = 'No class recording is selected.';
  static const noRecordingTeacher =
      'No class recording is selected. In the recording player, press 1 to choose one.';
  static const previewFailed =
      'The private preview could not start. Check the connection and try again.';
  static String classPauseUnconfirmed(String reason) =>
      'Your local audio is paused. The class pause was not confirmed. $reason';
  static String position(double seconds, double? total) => SpokenFormat.position(
    Duration(seconds: seconds.round()),
    total == null ? null : Duration(seconds: total.round()),
  );
  static String speed(double value) =>
      '${value.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '')} times speed';
  static String playbackAccepted(String title) =>
      'Class playback request accepted for $title.';
  static String selected(String title) =>
      '$title selected for the class. Press 5 to play it.';
  static String previewing(String title) => 'Previewing $title on this phone only.';
  static const previewStopped = 'Preview stopped.';

  // Recordings screen (teacher).
  static const recordingsTitle = 'Class recording player';
  static const chooseRecording = 'Choose a recording from the library';
  static const uploadRecording = 'Upload a new recording';
  static const hearRecording = 'Hear recording status';
  static const back10 = 'Back 10 seconds';
  static const playPauseClass = 'Play or pause for the class';
  static const forward10 = 'Forward 10 seconds';
  static const slower = 'Slower';
  static const faster = 'Faster';
  static const libraryLoading = 'The recording library is still loading. Try again shortly.';
  static const libraryEmpty =
      'No recordings for this class yet. Press 2 to upload one.';
  static const positionHint = 'Use left and right to move 10 seconds';
  static String recordingStatus({
    required String? title,
    required bool playing,
    required double position,
    required double? duration,
    required double speedValue,
  }) => title == null
      ? noRecording
      : '$title. ${playing ? 'Playing for the class' : 'Paused'}. '
            '${SessionText.position(position, duration)}. ${speed(speedValue)}.';
  static String positionLabel(double position, double? duration) =>
      'Position ${SessionText.position(position, duration)}. $positionHint';
  static String fileLabel(
    Map<String, dynamic> audio, {
    required bool active,
    required bool previewing,
  }) => [
    audio['title'] as String? ?? 'Untitled',
    if (active) 'selected for the class',
    if (previewing) 'previewing',
  ].join(', ');
  static const playForClass = 'Select and play for the class now';
  static const selectOnly = 'Select only, play later with 5';
  static const previewPrivately = 'Preview privately on this phone';
  static const stopPreview = 'Stop the private preview';

  // Upload.
  static const uploadDetailsTitle = 'Upload audio details';
  static const uploadTitle = 'Upload Audio';
  static String uploadFile(String name) => 'File: $name';
  static const titleField = 'Audio title, required';
  static const descriptionField = 'Audio description, optional';
  static const cancelUpload = 'Cancel upload';
  static const confirmUpload = 'Upload audio';
  static const titleRequired = 'Title is required';
  static const chooseSessionsTitle = 'Choose classes for this audio';
  static const addToSessions = 'Add audio to classes';
  static const confirmSessions = 'Confirm selected classes';
  static const selectAtLeastOne = 'Select at least one class';
  static const sessionSelected = 'Class selected';
  static const sessionUnselected = 'Class unselected';
  static String sessionChoice(String title, bool selected) =>
      '${selected ? 'Selected' : 'Not selected'}, $title';
  static String sessionTitle(Map<String, dynamic> session) =>
      session['title']?.toString() ??
      'Class ${SpokenFormat.identifier(session['session_id'] as int)}';
  static const uploadContextMissing =
      'The class and subject of this class could not be determined.';
  static const uploadSuccess = 'Upload successful.';
  static const uploadInProgress = 'Audio upload in progress';
  static const playNowTitle = 'Play for everyone now?';
  static String playNowMessage(String title) =>
      '$title is selected. Play it for all participants now?';
  static const playNow = 'Play now';
  static const notYet = 'Not yet';

  // ─── Classroom checks ───────────────────────────────────────────────────
  static const checkUnreadable =
      'Classroom check state could not be read. Refresh before responding.';
  static const checkUnconfirmed =
      'The classroom check action was not confirmed. Refresh before trying again.';
  static const checkConfirmationUnreadable =
      'The classroom check confirmation was unreadable. Refresh before trying again.';
  static const checkOpenedForYou =
      'Your teacher opened a classroom check. Use the D-pad to reach Answer classroom check.';
  static const checkHelp =
      'Private classroom check. Understood, Please repeat or Need help. '
      'Only the responding student and session teacher can read a response. '
      'It is not graded. Responses clear on the next check, session end or server restart. '
      'Use Read or Refresh for confirmed state. Stop speech and Back are available.';
  static const checkTitle = 'Classroom check';
  static const checkNewTitle = 'Open a new classroom check?';
  static const checkNewMessage =
      'This clears all responses from the previous check. Students choose '
      'Understood, Please repeat or Need help. Only you and each responding '
      'student can read their response. It is not graded or retained as an '
      'academic record.';
  static const checkNewConfirm = 'Clear previous and open';
  static const checkNewCancel = 'Keep current check';
  static const checkSending = 'Sending. Waiting for confirmation.';
  static const checkWaiting = 'Waiting for confirmation. Do not resend.';
  static const backToClass = 'Back to class';
  static const checkRead = 'Read check status and confirmed responses';
  static const checkReadButton = 'Read status and responses';
  static const checkRefresh =
      'Refresh private check state. Requires class connection';
  static const checkRefreshButton = 'Refresh from server';
  static const checkOpenLabel =
      'Open a new check. Confirm clearing previous responses';
  static const checkOpenButton = 'Open new check';
  static const checkCloseLabel =
      'Close this check. Keep current results until next check or session end';
  static const checkCloseButton = 'Close check';
  static String checkAnswer(String choice) =>
      '$choice. Send or change your private, ungraded response';
  static const stopSpeech = 'Stop speech';

  // ─── Hands queue (classroom console dialog) ─────────────────────────────
  static const onlyTeacherAcknowledges =
      'Only the session teacher may acknowledge a hand.';
  static const handChanged = 'The selected hand changed. Read the queue again.';
  static const ackUnconfirmed =
      'The hand acknowledgment was not confirmed. Read the queue before retrying.';
  static const ackUnreadable =
      'Hand acknowledgment was not readable. Check the queue before trying again.';
  static String acknowledged(String name, {required bool changedSince}) =>
      changedSince
      ? '$name acknowledged earlier. Their hand has since changed; read the queue again. Their microphone was not changed.'
      : '$name acknowledged. The selected hand was lowered. Their microphone was not changed.';
  static const consoleHelp =
      'Raised hands. Read summary for the last received classroom state. '
      'Previous and Next select a raised hand without changing it. '
      'Acknowledge lowers only the selected hand after server confirmation. '
      'It never unmutes anyone. Older hands with unknown order are labelled separately.';
  static const handsTitle = 'Raised hands';
  static const noHands = 'No raised hands in the last received classroom state.';
  static String selectedGone(int count) =>
      'The selected hand is no longer in the queue. '
      '${SpokenFormat.count(count, 'raised hand')} remain. Use Next or Previous to select a hand.';
  static String handTitle(int index, int total, String name) =>
      'Hand ${index + 1} of $total, $name, waiting';
  static const knownOrder = 'Server-recorded queue order.';
  static const unknownOrder =
      'Original raise order unknown; shown before known-order hands.';
  static const reportedMuted = 'Microphone reported muted.';
  static const reportedUnmuted =
      'Microphone reported unmuted; this is not proof of speech.';
  static const noHandsShort = 'No raised hands';
  static const noHandSelected = 'No hand selected';
  static String lowering(String name) =>
      'Lowering hand for $name. Waiting for the server.';
  static String loweredLast(String name) =>
      'Hand lowered for $name. The hand queue is now empty.';
  static String loweredNext(String name, String next) =>
      'Hand lowered for $name. Next: $next.';
  static const noSummary = 'No classroom summary is available yet.';
  static const readSummary = 'Read classroom summary';
  static const previousHand = 'Previous raised hand';
  static const readHand = 'Read selected hand';
  static const nextHand = 'Next raised hand';
  static const waitingAck = 'Waiting for hand acknowledgment';
  static const ackNoneSelected =
      'Acknowledge and lower selected hand. No hand selected';
  static String ackLabel(String name) => 'Lower $name. Never unmutes';
  static const ackButton = 'Acknowledge and lower hand';
  static const repeatConsoleHelp = 'Repeat console help';
  static const consoleSections =
      'read classroom summary, previous hand, read selected hand, next hand, acknowledge hand, stop speech, help and back. If no hands or summary are available, selecting their controls reads that status';
  static const snapshotNote =
      'Counts reflect the last received snapshot, not guaranteed audio delivery. Active speaker identification is unavailable.';
  static const waitingAckNote =
      'Waiting for server acknowledgment. No microphone is changed.';
  static String classroomSummary({
    required String connection,
    required int people,
    required int hands,
    required int muted,
    required List<String> speaking,
    required String? recording,
    required bool recordingPlaying,
    required bool previewing,
  }) =>
      'Local connection: $connection. '
      'Last received classroom state: ${SpokenFormat.count(people, 'participant')}, '
      '${SpokenFormat.count(hands, 'raised hand')}, '
      '${SpokenFormat.count(muted, 'microphone')} reported muted. '
      'Remote reconnecting counts are unavailable. '
      '${speaking.isEmpty ? 'Nobody detected speaking.' : 'Detected speaking: ${speaking.join(', ')}.'} '
      '${recording == null ? 'No class recording selected.' : 'Class recording $recording. ${recordingPlaying ? 'Playing requested.' : 'Paused.'}'} '
      '${previewing ? 'Private preview active on this phone only.' : 'Private preview stopped.'} '
      'Microphone flags and accepted playback requests do not prove that anyone spoke or heard audio.';

  // ─── Teacher tools menu (teacher, key 9) ────────────────────────────────
  static const toolsTitle = 'Teacher tools';
  static String consoleStatus(int hands, int people) =>
      '${handsWaiting(hands)} ${SessionText.people(people)}';
  static const invite = 'Invite students';
  static const endClass = 'End class for everyone, asks to confirm';
  static const peopleTitle = 'Participants and raised hands';
  static String handQueue(int hands) => 'Raised hands queue, ${handsWaiting(hands).replaceAll('.', '')}';
  static String participantList(int count) =>
      'Participants list, ${SpokenFormat.count(count, 'person', 'people')}';
  static const summaryChoice = 'Hear classroom summary';
  static const participantsTitle = 'Participants';

  // ─── Who is in the class (students, key 7) ──────────────────────────────
  static const membersTitle = 'People in the class';
  static const membersButton = '7: Who is in class';
  static String membersLabel(int count) =>
      'Who is in the class. ${people(count)} Select a person to hear details';
  static const hearDetails = 'Hear details';
  static String muteParticipant(String name) => 'Mute $name';
  static String removeParticipant(String name) =>
      'Remove $name from the class, asks to confirm';
  static const participantGone = 'That participant has left the class.';
  static const noOtherParticipants = 'Nobody else is in the class yet.';

  // ─── Legacy chat panel and participant tile ──────────────────────────────
  static const readLatest = 'Read latest message';
  static const chatMessage = 'Chat message';
  static const sendMessage = 'Send message';
  static String said(String sender, String text, String? delivery) =>
      '$sender said: $text${delivery == null ? '' : '. $delivery'}';
  static String latestLine(String sender, String text, String? delivery) =>
      '$sender: $text${delivery == null ? '' : '\nDelivery status: $delivery.'}';
  static String tileSummary({
    required String name,
    required bool raisedHand,
    required bool muted,
    required bool speaking,
  }) => [
    name,
    if (raisedHand) 'hand raised',
    muted ? 'muted' : 'unmuted',
    if (speaking) 'speaking',
  ].join(', ');
  static String tileRemoveMessage(String name) =>
      '$name will be removed from this class and returned to their dashboard.';
  static String unmuteParticipant(String name) => 'Unmute $name';
  static String removeFromClass(String name) => 'Remove $name from class';
}
