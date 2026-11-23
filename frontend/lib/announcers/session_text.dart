import '../l10n/speech.dart';
import '../utils/spoken_format.dart';
import 'announce.dart';

/// Every sentence spoken or shown by the live class (session) screens, kept
/// in one place so wording stays consistent. Text comes from the ARB files
/// in the current speech language.
abstract final class SessionText {
  static AppLocalizations get _t => Speech.t;

  // ─── Main screen ──────────────────────────────────────────────────────────
  static String screenName({
    required bool teacher,
    required String title,
    String? className,
    String? subjectName,
  }) => [
    teacher ? _t.sessionScreenTeacherClass : _t.sessionScreenClass,
    title,
    ?className,
    ?subjectName,
  ].join(', ');

  static String get defaultTitle => _t.sessionDefaultTitle;
  static String get joining => _t.sessionJoining;
  static String get connecting => _t.sessionConnecting;
  static String get joinFailed => _t.sessionJoinFailed;
  static String get leaveKeyHint => _t.sessionLeaveKeyHint;
  static String get keyLine => _t.sessionKeyLine;

  static String joined({
    required bool teacher,
    required String status,
    required String keys,
  }) => _t.sessionJoinedDetailed(status, keys);

  static String keyHelp(Map<int, String> labels) {
    final keys = labels.entries.toList()
      ..sort(
        (a, b) => (a.key == 0 ? 10 : a.key).compareTo(b.key == 0 ? 10 : b.key),
      );
    return keys
        .map((e) => _t.sessionPressKeyFor('${e.key}', e.value))
        .join(' ');
  }

  // Focus labels and visible button text on the main screen.
  static String muteLabel(bool muted, bool pending) => pending
      ? _t.sessionMicWaitingLabel
      : muted
      ? _t.sessionUnmuteMicrophone
      : _t.sessionMuteMicrophone;
  static String muteButton(bool muted, bool pending) => pending
      ? _t.sessionMuteButtonWaiting
      : muted
      ? _t.sessionMuteButtonUnmute
      : _t.sessionMuteButtonMute;
  static String handLabel(bool raised, bool pending) => pending
      ? _t.sessionHandWaitingLabel
      : raised
      ? _t.sessionLowerHand
      : _t.sessionRaiseHand;
  static String handButton(bool raised, bool pending) => pending
      ? _t.sessionHandButtonWaiting
      : raised
      ? _t.sessionHandButtonLower
      : _t.sessionHandButtonRaise;
  static String get statusLabel => _t.sessionStatusLabel;
  static String get statusButton => _t.sessionStatusButton;
  static String chatLabel(int count) => _t.sessionChatLabel(count);
  static String get chatButton => _t.sessionChatButton;
  static String recordingLabel({
    required bool teacher,
    required String? title,
    required bool playing,
  }) {
    if (teacher) {
      return title == null
          ? _t.sessionRecordingPlayerNone
          : playing
          ? _t.sessionRecordingPlayerPlaying(title)
          : _t.sessionRecordingPlayerPaused(title);
    }
    if (title == null) return _t.sessionRecordingStudentNone;
    return playing
        ? _t.sessionRecordingStudentPlaying(title)
        : _t.sessionRecordingStudentPaused(title);
  }

  /// Student key 5: read only, the teacher controls the recording.
  static String get recordingStatusButton => _t.sessionRecordingStatusButton;
  static String studentRecordingStatus({
    required String? title,
    required bool playing,
    required String position,
  }) => title == null
      ? _t.sessionStudentRecordingNone
      : playing
      ? _t.sessionStudentRecordingPlaying(title, position)
      : _t.sessionStudentRecordingPaused(title, position);
  static String get recordingPlayerButton => _t.sessionRecordingPlayerButton;
  static String get openingPlayerToChoose => _t.sessionOpeningPlayerToChoose;
  // Teacher-only main screen controls.
  static String handsLabel(int count) =>
      _t.sessionHandsLabel(handsWaiting(count));
  static String handsButton(int count) =>
      count == 0 ? _t.sessionHandsButton : _t.sessionHandsButtonCount(count);
  static String participantsLabel(int count) =>
      _t.sessionParticipantsLabel(people(count));
  static String get participantsButton => _t.sessionParticipantsButton;
  static String get toolsLabel => _t.sessionToolsLabel;
  static String get toolsButton => _t.sessionToolsButton;
  static String get voiceStartLabel => _t.sessionVoiceStartLabel;
  static String get voiceStopLabel => _t.sessionVoiceStopLabel;
  static String get voiceStartButton => _t.sessionVoiceStartButton;
  static String get voiceStopButton => _t.sessionVoiceStopButton;
  static String get updatesLabel => _t.sessionUpdatesLabel;
  static String get updatesButton => _t.sessionUpdatesButton;
  static String get retryLabel => _t.sessionRetryLabel;
  static String get retryButton => _t.sessionRetryButton;
  static String get leaveLabel => _t.sessionLeaveLabel;
  static String get leaveButton => _t.sessionLeaveButton;

  // ─── Status ("where am I" and key 3) ─────────────────────────────────────
  static String micState(bool muted, bool pending) => pending
      ? _t.sessionMicWaiting
      : muted
      ? _t.sessionMicMuted
      : _t.sessionMicUnmutedHeard;
  static String handState(bool raised, bool pending) => pending
      ? _t.sessionHandWaiting
      : raised
      ? _t.sessionHandRaisedState
      : _t.sessionHandDown;
  static String handsWaiting(int count) => _t.sessionHandsWaiting(count);
  static String people(int count) => _t.sessionPeople(count);
  static String recordingState({
    required String? title,
    required bool playing,
  }) {
    if (title == null) {
      return Announce.pick(brief: '', detailed: _t.sessionNoRecordingSelected);
    }
    return playing
        ? _t.sessionRecordingStatePlaying(title)
        : _t.sessionRecordingStatePaused(title);
  }

  static String connection(String label) => _t.sessionConnectionLabel(label);
  static String messages(int count) =>
      count == 0 ? '' : _t.sessionChatMessages(count);

  /// Title used for a selected recording without a title.
  static String get recordingFallback => _t.sessionRecordingFallback;
  static String get recordingFallbackLower => _t.sessionRecordingFallbackLower;
  static String userFallback(Object? userId) =>
      _t.sessionUserFallback('$userId');

  // ─── Connection ──────────────────────────────────────────────────────────
  static String connectionRestored(String message) =>
      _t.sessionConnectionRestored(message);
  static String connectionLost(bool everConnected, String message) =>
      everConnected
      ? _t.sessionConnectionLost(message)
      : _t.sessionCouldNotConnect(message);

  // ─── Microphone ──────────────────────────────────────────────────────────
  static String get micDialogTitle => _t.sessionMicDialogTitle;
  static String get micDialogMessage => _t.sessionMicDialogMessage;
  static String get micDialogConfirm => _t.sessionMicDialogConfirm;
  static String get micSkipped => _t.sessionMicSkipped;
  static String get micUnavailable => _t.sessionMicUnavailable;
  static String get waitingMic => _t.sessionWaitingMic;
  static String get muted => _t.sessionMuted;
  static String get unmuted => Announce.pick(
    brief: _t.sessionUnmuted,
    detailed: _t.sessionMicUnmutedHeard,
  );
  static String get mutedLocallyOnly => _t.sessionMutedLocallyOnly;
  static String get mutedByTeacher => _t.sessionMutedByTeacher;

  // ─── Hand ────────────────────────────────────────────────────────────────
  static String get waitingHand => _t.sessionWaitingHand;
  static String get handRaised => _t.sessionHandRaised;
  static String get handLowered => _t.sessionHandLowered;
  static String get handNotConfirmed => _t.sessionHandNotConfirmed;
  static String raisedHandBy(String? name) =>
      name == null ? _t.sessionRaisedHandUnknown : _t.sessionRaisedHandBy(name);

  // ─── Participants ────────────────────────────────────────────────────────
  static String get participantJoined => _t.sessionParticipantJoined;

  /// "Akshat", "Akshat and Meena", "Akshat, Meena and Ravi".
  static String names(List<String> names) => names.length < 2
      ? names.join()
      : _t.sessionNamesAnd(
          names.sublist(0, names.length - 1).join(', '),
          names.last,
        );

  /// "Akshat and Meena joined. Ravi left. 4 of 5 here."
  static String presence({
    required List<String> joined,
    required List<String> left,
    required int here,
    int? total,
  }) => [
    if (joined.isNotEmpty) _t.sessionPeopleJoined(names(joined)),
    if (left.isNotEmpty) _t.sessionPeopleLeft(names(left)),
    total == null ? _t.sessionHereCount(here) : _t.sessionHereOf(here, total),
  ].join(' ');

  static String startSummary(int here, int? total) => total == null
      ? _t.sessionHereCount(here)
      : _t.sessionStartSummary(here, total);
  static String get participantsJoinedGroup =>
      _t.sessionParticipantsJoinedGroup;
  static String get participantLeft => _t.sessionParticipantLeft;
  static String get participantsLeftGroup => _t.sessionParticipantsLeftGroup;
  static String get participantFallback => _t.sessionParticipantFallback;
  static String get thisParticipant => _t.sessionThisParticipant;
  static String participant(
    Map<String, dynamic> p, {
    required bool self,
    required bool muted,
    required bool speaking,
  }) {
    final name = p['name'] as String? ?? participantFallback;
    return [
      self ? _t.sessionParticipantSelf(name) : name,
      p['is_teacher'] == true ? _t.sessionRoleTeacher : _t.sessionRoleStudent,
      if (p['raised_hand'] == true) _t.sessionStateHandRaised,
      muted ? _t.sessionStateMuted : _t.sessionStateUnmuted,
      if (speaking) _t.sessionStateSpeaking,
    ].join(', ');
  }

  static String alreadyMuted(String name) => _t.sessionAlreadyMuted(name);
  static String participantMuted(String name) =>
      _t.sessionParticipantMuted(name);
  static String removeTitle(String name) => _t.sessionRemoveTitle(name);
  static String removeMessage(String name) => _t.sessionRemoveMessage(name);
  static String keep(String name) => _t.sessionKeep(name);
  static String remove(String name) => _t.sessionRemove(name);
  static String removed(String name) => _t.sessionRemoved(name);

  // ─── Chat ────────────────────────────────────────────────────────────────
  static String messageFrom(String sender, String text) =>
      _t.chatMessageFrom(sender, text);
  static String get unknownSender => _t.chatSenderUnknown;
  static String get waitingMessage => _t.chatWaitingConfirmation;
  static String get emptyMessage => _t.chatEmptyMessage;
  static String get messageSent => _t.chatMessageSent;
  static String get sending => _t.chatSending;
  static String get sent => _t.chatSent;
  static String get notConfirmed => _t.chatNotConfirmed;
  static String get noMessages => _t.chatNoMessages;
  static String get chatTitle => _t.chatTitle;
  static String get readMessages => _t.chatReadMessages;
  static String get writeMessage => _t.chatWriteMessage;
  static String get messageField => _t.chatMessageField;
  static String get messagesTitle => _t.chatMessagesTitle;
  static List<String> get quickPhrases => [
    _t.chatPhraseUnderstood,
    _t.chatPhraseRepeat,
    _t.chatPhraseQuestion,
  ];
  static String sendPhrase(String phrase) => _t.chatSendPhrase(phrase);
  static String chatCount(int count) =>
      count == 0 ? noMessages : _t.chatCount(count);
  static String get chatHelp =>
      Announce.pick(brief: _t.chatHelpBrief, detailed: _t.chatHelpDetailed);
  static String messageLine(Map<String, dynamic> message) {
    final sender = message['isMe'] == true
        ? _t.chatYou
        : '${message['sender']}';
    final delivery = message['delivery'];
    final text = '${message['text']}';
    return delivery == null
        ? _t.chatMessageLine(sender, text)
        : _t.chatMessageLineDelivery(sender, text, '$delivery');
  }

  static String messageDetail(Map<String, dynamic> message) {
    final at = message['timestamp'];
    final line = messageLine(message);
    return at is DateTime
        ? _t.chatMessageDetailSent(line, SpokenFormat.timeOfDay(at))
        : _t.chatMessageDetail(line);
  }

  static String latestMessage(Map<String, dynamic>? message) => message == null
      ? noMessages
      : _t.chatNewestMessage(messageDetail(message));

  // ─── Leaving and ending ─────────────────────────────────────────────────
  static String get leaveTitle => _t.sessionLeaveTitle;
  static String get leaveMessage => _t.sessionLeaveMessage;
  static String get teacherLeaveMessage => _t.sessionTeacherLeaveMessage;
  static String get stay => _t.sessionStay;
  static String get leave => _t.sessionLeave;
  static String get leaveLocallyTitle => _t.sessionLeaveLocallyTitle;
  static String get leaveLocallyMessage => _t.sessionLeaveLocallyMessage;
  static String get stayAndRetry => _t.sessionStayAndRetry;
  static String get leaveLocally => _t.sessionLeaveLocally;
  static String get endTitle => _t.sessionEndTitle;
  static String get endMessage => _t.sessionEndMessage;
  static String get endCancel => _t.sessionEndCancel;
  static String get endConfirm => _t.sessionEndConfirm;
  static String get waitingEnd => _t.sessionWaitingEnd;
  static String get endNotConfirmed => _t.sessionEndNotConfirmed;
  static String get endingForEveryone => _t.sessionEndingForEveryone;
  static String get youLeft => _t.sessionYouLeft;
  static String get classEnded => _t.sessionClassEnded;
  static String get youWereRemoved => _t.sessionYouWereRemoved;
  static String get signInChanged => _t.sessionSignInChanged;
  static String get cleanupFailed => _t.sessionCleanupFailed;
  static String get cleanupTimedOut => _t.sessionCleanupTimedOut;
  static String get requestFailed => _t.sessionRequestFailed;

  // ─── Voice commands ──────────────────────────────────────────────────────
  static String get voiceStopped => _t.sessionVoiceStopped;
  static String get voiceUnmuteTitle => _t.sessionVoiceUnmuteTitle;
  static String get voiceUnmuteMessage => _t.sessionVoiceUnmuteMessage;
  static String get voiceUnmuteConfirm => _t.sessionVoiceUnmuteConfirm;
  static String get voiceUnmuteCancel => _t.sessionVoiceUnmuteCancel;
  static String get alreadyUnmuted => _t.sessionAlreadyUnmuted;
  static String get alreadyMutedSelf => _t.sessionAlreadyMutedSelf;
  static String get handAlreadyLowered => _t.sessionHandAlreadyLowered;
  static String get handAlreadyRaised => _t.sessionHandAlreadyRaised;
  static String get commandNotRecognized => _t.sessionCommandNotRecognized;
  // Voice controller status and issues.
  static String get voiceStopUnconfirmed => _t.sessionVoiceStopUnconfirmed;
  static String get voiceStopping => _t.sessionVoiceStopping;
  static String get voiceStarting => _t.sessionVoiceStarting;
  static String get voiceFinishing => _t.sessionVoiceFinishing;
  static String get voiceListening => _t.sessionVoiceListening;
  static String get voiceIdle => _t.sessionVoiceIdle;
  static String get voiceSpeechNotStopped => _t.sessionVoiceSpeechNotStopped;
  static String get voiceUnavailable => _t.sessionVoiceUnavailable;
  static String get voiceCouldNotStart => _t.sessionVoiceCouldNotStart;
  static String get voiceCouldNotFinish => _t.sessionVoiceCouldNotFinish;
  static String get voiceNoCommand => _t.sessionVoiceNoCommand;
  static String get voiceCommandFailed => _t.sessionVoiceCommandFailed;
  static String get voiceCannotStop => _t.sessionVoiceCannotStop;

  // ─── Class recording ─────────────────────────────────────────────────────
  static String get recordingSelectionChanged =>
      _t.sessionRecordingSelectionChanged;
  static String get recordingSelectionGroup =>
      _t.sessionRecordingSelectionGroup;
  static String get playbackFinished => _t.sessionPlaybackFinished;
  static String get noRecording => _t.sessionNoRecording;
  static String get noRecordingTeacher => _t.sessionNoRecordingTeacher;
  static String get previewFailed => _t.sessionPreviewFailed;
  static String classPauseUnconfirmed(String reason) =>
      _t.sessionClassPauseUnconfirmed(reason);
  static String position(double seconds, double? total) =>
      SpokenFormat.position(
        Duration(seconds: seconds.round()),
        total == null ? null : Duration(seconds: total.round()),
      );
  static String speed(double value) => _t.sessionSpeed(
    value.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), ''),
  );
  static String playbackAccepted(String title) =>
      _t.sessionPlaybackAccepted(title);
  static String selected(String title) => _t.sessionSelected(title);
  static String previewing(String title) => _t.sessionPreviewing(title);
  static String get previewStopped => _t.sessionPreviewStopped;

  // Recordings screen (teacher).
  static String get recordingsTitle => _t.sessionRecordingsTitle;
  static String get chooseRecording => _t.sessionChooseRecording;
  static String get uploadRecording => _t.sessionUploadRecording;
  static String get hearRecording => _t.sessionHearRecording;
  static String get back10 => _t.keyBack10Seconds;
  static String get playPauseClass => _t.sessionPlayPauseClass;
  static String get forward10 => _t.keyForward10Seconds;
  static String get slower => _t.keySlower;
  static String get faster => _t.keyFaster;
  static String get libraryLoading => _t.sessionLibraryLoading;
  static String get libraryEmpty => _t.sessionLibraryEmpty;
  static String get positionHint => _t.sessionPositionHint;
  static String recordingStatus({
    required String? title,
    required bool playing,
    required double position,
    required double? duration,
    required double speedValue,
  }) {
    if (title == null) return noRecording;
    final at = SessionText.position(position, duration);
    return playing
        ? _t.sessionRecordingStatusPlaying(title, at, speed(speedValue))
        : _t.sessionRecordingStatusPaused(title, at, speed(speedValue));
  }

  static String positionLabel(double position, double? duration) =>
      _t.sessionPositionLabel(SessionText.position(position, duration));
  static String get untitled => _t.sessionUntitled;
  static String fileLabel(
    Map<String, dynamic> audio, {
    required bool active,
    required bool previewing,
  }) => [
    audio['title'] as String? ?? untitled,
    if (active) _t.sessionFileSelectedForClass,
    if (previewing) _t.sessionFilePreviewing,
  ].join(', ');
  static String get playForClass => _t.sessionPlayForClass;
  static String get selectOnly => _t.sessionSelectOnly;
  static String get previewPrivately => _t.sessionPreviewPrivately;
  static String get stopPreview => _t.sessionStopPreview;

  // Upload.
  static String get uploadDetailsTitle => _t.sessionUploadDetailsTitle;
  static String get uploadTitle => _t.sessionUploadTitle;
  static String uploadFile(String name) => _t.sessionUploadFile(name);
  static String get titleField => _t.sessionTitleField;
  static String get descriptionField => _t.sessionDescriptionField;
  static String get cancelUpload => _t.sessionCancelUpload;
  static String get confirmUpload => _t.sessionConfirmUpload;
  static String get titleRequired => _t.sessionTitleRequired;
  static String get chooseSessionsTitle => _t.sessionChooseSessionsTitle;
  static String get addToSessions => _t.sessionAddToSessions;
  static String get confirmSessions => _t.sessionConfirmSessions;
  static String get selectAtLeastOne => _t.sessionSelectAtLeastOne;
  static String get sessionSelected => _t.sessionSessionSelected;
  static String get sessionUnselected => _t.sessionSessionUnselected;
  static String sessionChoice(String title, bool selected) => selected
      ? _t.sessionChoiceSelected(title)
      : _t.sessionChoiceNotSelected(title);
  static String sessionTitle(Map<String, dynamic> session) =>
      session['title']?.toString() ??
      _t.sessionClassNumbered(
        SpokenFormat.identifier(session['session_id'] as int),
      );
  static String get uploadContextMissing => _t.sessionUploadContextMissing;
  static String get uploadSuccess => _t.sessionUploadSuccess;
  static String get uploadInProgress => _t.sessionUploadInProgress;
  static String get playNowTitle => _t.sessionPlayNowTitle;
  static String playNowMessage(String title) => _t.sessionPlayNowMessage(title);
  static String get playNow => _t.sessionPlayNow;
  static String get notYet => _t.sessionNotYet;
  static String get editTitleKey => _t.sessionUploadEditTitle;
  static String get editDescriptionKey => _t.sessionUploadEditDescription;
  static String get uploadKey => _t.sessionUploadKey;
  static String get cancelKey => _t.sessionCancel;

  // ─── Leaving sub-screens ──────────────────────────────────────────────────
  static String get backToClass => _t.sessionBackToClass;
  static String get backToSession => _t.classroomBackToSession;
  static String get back => _t.classroomBack;
  static String get stopSpeech => _t.sessionStopSpeech;

  // ─── Hands queue (classroom console dialog) ─────────────────────────────
  static String get onlyTeacherAcknowledges =>
      _t.classroomOnlyTeacherAcknowledges;
  static String get handChanged => _t.classroomHandChanged;
  static String get ackUnconfirmed => _t.classroomAckUnconfirmed;
  static String get ackUnreadable => _t.classroomAckUnreadable;
  static String acknowledged(String name, {required bool changedSince}) =>
      changedSince
      ? _t.classroomAcknowledgedChanged(name)
      : _t.classroomAcknowledged(name);
  static String get consoleHelp => _t.classroomHandsHelp;
  static String get handsTitle => _t.classroomHandsTitle;
  static String get noHands => _t.classroomNoHands;
  static String selectedGone(int count) => _t.classroomSelectedGone(count);
  static String handTitle(int index, int total, String name) =>
      _t.classroomHandTitle('${index + 1}', '$total', name);
  static String get knownOrder => _t.classroomKnownOrder;
  static String get unknownOrder => _t.classroomUnknownOrder;
  static String get reportedMuted => _t.classroomReportedMuted;
  static String get reportedUnmuted => _t.classroomReportedUnmuted;
  static String get noHandsShort => _t.classroomNoHandsShort;
  static String get noHandSelected => _t.classroomNoHandSelected;
  static String lowering(String name) => _t.classroomLowering(name);
  static String loweredLast(String name) => _t.classroomLoweredLast(name);
  static String loweredNext(String name, String next) =>
      _t.classroomLoweredNext(name, next);
  static String get noSummary => _t.classroomNoSummary;
  static String get readSummary => _t.classroomReadSummary;
  static String get previousHand => _t.classroomPreviousHand;
  static String get readHand => _t.classroomReadHand;
  static String get nextHand => _t.classroomNextHand;
  static String get waitingAck => _t.classroomWaitingAck;
  static String get ackNoneSelected => _t.classroomAckNoneSelected;
  static String ackLabel(String name) => _t.classroomAckLabel(name);
  static String get ackButton => _t.classroomAckButton;
  static String get repeatConsoleHelp => _t.classroomRepeatConsoleHelp;
  static String get consoleSections => _t.classroomConsoleSections;
  static String get snapshotNote => _t.classroomSnapshotNote;
  static String get waitingAckNote => _t.classroomWaitingAckNote;
  static String classroomSummary({
    required String connection,
    required int people,
    required int hands,
    required int muted,
    required List<String> speaking,
    required String? recording,
    required bool recordingPlaying,
    required bool previewing,
  }) => _t.classroomSummary(
    connection,
    _t.classroomSummaryParticipants(people),
    _t.classroomSummaryHands(hands),
    _t.classroomSummaryMicrophones(muted),
    speaking.isEmpty
        ? _t.classroomSummaryNobodySpeaking
        : _t.classroomSummarySpeaking(speaking.join(', ')),
    recording == null
        ? _t.classroomSummaryNoRecording
        : recordingPlaying
        ? _t.classroomSummaryRecordingPlaying(recording)
        : _t.classroomSummaryRecordingPaused(recording),
    previewing
        ? _t.classroomSummaryPreviewActive
        : _t.classroomSummaryPreviewStopped,
  );

  // ─── Teacher tools menu (teacher, key 9) ────────────────────────────────
  static String get toolsTitle => _t.sessionToolsTitle;
  static String consoleStatus(int hands, int people) =>
      '${handsWaiting(hands)} ${SessionText.people(people)}';
  static String get invite => _t.sessionInvite;
  static String get endClass => _t.sessionEndClass;
  static String get peopleTitle => _t.sessionPeopleTitle;
  static String handQueue(int hands) => _t.sessionHandQueue(hands);
  static String participantList(int count) => _t.sessionParticipantList(count);
  static String get summaryChoice => _t.sessionSummaryChoice;
  static String get participantsTitle => _t.sessionParticipantsTitle;

  // ─── Who is in the class (students, key 7) ──────────────────────────────
  static String get membersTitle => _t.sessionMembersTitle;
  static String get membersButton => _t.sessionMembersButton;
  static String membersLabel(int count) =>
      _t.sessionMembersLabel(people(count));
  static String get hearDetails => _t.sessionHearDetails;
  static String muteParticipant(String name) => _t.sessionMuteParticipant(name);
  static String removeParticipant(String name) =>
      _t.sessionRemoveParticipant(name);
  static String get participantGone => _t.sessionParticipantGone;
  static String get noOtherParticipants => _t.sessionNoOtherParticipants;

  // ─── Legacy chat panel and participant tile ──────────────────────────────
  static String get readLatest => _t.chatReadLatest;
  static String get chatMessage => _t.chatMessageLabel;
  static String get sendMessage => _t.chatSendMessage;
  static String said(String sender, String text, String? delivery) =>
      delivery == null
      ? _t.chatSaid(sender, text)
      : _t.chatSaidDelivery(sender, text, delivery);
  static String latestLine(String sender, String text, String? delivery) =>
      delivery == null
      ? _t.chatMessageLine(sender, text)
      : _t.chatLatestLineDelivery(sender, text, delivery);
  static String tileSummary({
    required String name,
    required bool raisedHand,
    required bool muted,
    required bool speaking,
  }) => [
    name,
    if (raisedHand) _t.sessionStateHandRaised,
    muted ? _t.sessionStateMuted : _t.sessionStateUnmuted,
    if (speaking) _t.sessionStateSpeaking,
  ].join(', ');
  static String tileRemoveMessage(String name) =>
      _t.sessionTileRemoveMessage(name);
  static String unmuteParticipant(String name) =>
      _t.sessionUnmuteParticipant(name);
  static String removeFromClass(String name) => _t.sessionRemoveFromClass(name);

  // ─── Class lifecycle (S06/S19/S20/S22/S44/S45) ──────────────────────────
  static String get micAskOnce => _t.sessionMicAskOnce;
  static String get micAskAgain => _t.sessionMicAskAgain;
  static String get micStillOff => _t.sessionMicStillOff;
  static String get micSettingsTitle => _t.sessionMicSettingsTitle;
  static String get micSettingsMessage => _t.sessionMicSettingsMessage;
  static String get micSettingsOpen => _t.sessionMicSettingsOpen;
  static String get micSettingsCancel => _t.sessionMicSettingsCancel;
  static String get muteAllButton => _t.sessionMuteAllButton;
  static String get muteAllLabel => _t.sessionMuteAllLabel;
  static String get muteAllWaiting => _t.sessionMuteAllWaiting;
  static String muteAllDone(int count) => _t.sessionMuteAllDone(count);
  static String get muteAllNone => _t.sessionMuteAllNone;
  static String muteAllNotConfirmed(String reason) =>
      _t.sessionMuteAllNotConfirmed(reason);
  static String get classListButton => _t.sessionClassListButton;
  static String classListLabel(int people) =>
      _t.sessionClassListLabel(SessionText.people(people));
  static String get classListTitle => _t.sessionClassListTitle;
  static String rosterCounts(int here, int left, int notJoined) =>
      _t.sessionRosterCounts(here, left, notJoined);
  static String hereNow(int count) => _t.sessionHereNow(count);
  static String leftClass(int count) => _t.sessionLeftClass(count);
  static String notJoined(int count) => _t.sessionNotJoined(count);
  static String get hereNowTitle => _t.sessionHereNowTitle;
  static String get leftClassTitle => _t.sessionLeftClassTitle;
  static String get notJoinedTitle => _t.sessionNotJoinedTitle;
  static String removedName(String name) => _t.sessionRemovedName(name);
  static String get nobody => _t.sessionNobody;
  static String get remindNotJoined => _t.sessionRemindNotJoined;
  static String get everyoneJoined => _t.sessionEveryoneJoined;
  static String reminderResult(int queued, int cooling) => cooling == 0
      ? _t.sessionReminderSent(queued)
      : _t.sessionReminderSentSomeWaiting(queued, cooling);
  static String get rosterUnavailable => _t.sessionRosterUnavailable;
  static String get addTime => _t.sessionAddTime;
  static String get cannotAddTime => _t.sessionCannotAddTime;
  static String endsBy(String clock) => _t.sessionEndsBy(clock);
  static String extendedUntil(String clock) => _t.sessionExtendedUntil(clock);
  static String endingSoonTeacher(int minutes, bool canExtend) => canExtend
      ? _t.sessionEndingSoonTeacherExtend(minutes)
      : _t.sessionEndingSoonTeacher(minutes);
  static String endingSoonStudent(int minutes) =>
      _t.sessionEndingSoonStudent(minutes);
  static String get lessonReady => _t.sessionLessonReady;
  static String get lessonNextReady => _t.sessionLessonNextReady;
  static String get joinedStudentBrief => _t.sessionJoinedStudentBrief;
  static String get joinedTeacherBrief => _t.sessionJoinedTeacherBrief;
  static String get starForKeys => _t.sessionStarForKeys;

  // Teacher keys 6 and 7, student keys 3 and 4.
  static String get endClassButton => _t.sessionEndClassButton;
  static String get endClassLabel => _t.sessionEndClassLabel;
  static String kindButton(String kind) =>
      kind == 'quiz' ? _t.sessionQuizButton : _t.sessionJourneyButton;
  static String kindLabel(String kind, {String? open}) => open != null
      ? _t.sessionOpenLabel(open)
      : kind == 'quiz'
      ? _t.sessionQuizLabel
      : _t.sessionJourneyLabel;
  static String pickTitle(String kind) =>
      kind == 'quiz' ? _t.sessionPickQuizTitle : _t.sessionPickJourneyTitle;
  static String noneToStart(String kind) =>
      kind == 'quiz' ? _t.sessionNoQuizToStart : _t.sessionNoJourneyToStart;
  static String startDifferent(String kind) => kind == 'quiz'
      ? _t.sessionStartDifferentQuiz
      : _t.sessionStartDifferentJourney;
  static String finishedOf(int finished, int enrolled) =>
      _t.sessionFinishedOf(finished, enrolled);
  static String leftInClass(int count) => _t.sessionLeftInClass(count);
  static String leftWholeClass(int count) => _t.sessionLeftWholeClass(count);
  static String get leftInClassTitle => _t.sessionLeftInClassTitle;
  static String get leftWholeClassTitle => _t.sessionLeftWholeClassTitle;
  static String get remindLeft => _t.sessionRemindLeft;
  static String leftPerson(Map<String, dynamic> person, {required bool whole}) {
    final name = '${person['name']}';
    final state = person['status'] == 'in_progress'
        ? _t.sessionLeftStarted(name)
        : _t.sessionLeftNotStarted(name);
    if (!whole) return state;
    return '$state, ${person['in_class'] == true ? _t.sessionLeftHere : _t.sessionLeftAway}';
  }

  static String leftNobody({required bool inClass}) =>
      inClass ? _t.sessionLeftNobodyInClass : _t.sessionLeftNobody;
  static String remindedLeft(int count) => _t.sessionRemindedLeft(count);
  static String activityReminder(String kind, String title) => kind == 'quiz'
      ? _t.sessionActivityReminderQuiz(title)
      : _t.sessionActivityReminderJourney(title);
  static String activityQuizItem(String title, int questions) =>
      _t.sessionActivityQuizItem(title, questions);
  static String activityJourneyItem(String title) =>
      _t.sessionActivityJourneyItem(title);
  static String activityStopItem(String title) =>
      _t.sessionActivityStopItem(title);
  static String activityStartedTeacher(String title) =>
      _t.sessionActivityStartedTeacher(title);
  static String activityStoppedTeacher(String title) =>
      _t.sessionActivityStoppedTeacher(title);
  static String activityStartedStudent(String kind, String title) =>
      kind == 'quiz'
      ? _t.sessionActivityQuizStarted(title)
      : _t.sessionActivityJourneyStarted(title);
  static String activityStoppedStudent(String title) =>
      _t.sessionActivityStoppedStudent(title);
  static String activityStartButton(String kind, String title) => kind == 'quiz'
      ? _t.sessionStartQuizButton(title)
      : _t.sessionStartJourneyButton(title);
  static String activityStartLabel(String kind, String title) => kind == 'quiz'
      ? _t.sessionActivityStartQuizLabel(title)
      : _t.sessionActivityStartJourneyLabel(title);
  static String activityState({required bool teacher, required String title}) =>
      teacher
      ? _t.sessionActivityStateTeacher(title)
      : _t.sessionActivityStateStudent(title);
  static String activityOpening(String title) =>
      _t.sessionActivityOpening(title);
  static String activityCouldNotOpen(String title) =>
      _t.sessionActivityCouldNotOpen(title);
  static String get backInClass => _t.sessionBackInClass;
  static String activityProgress(String title, int started, int finished) =>
      _t.sessionActivityProgress(title, started, finished);
  static String get whatIsPlayingButton => _t.sessionWhatIsPlayingButton;

  // Teacher 5 Start and 6 Status.
  static String get startButton => _t.sessionStartButton;
  static String get startLabel => _t.sessionStartLabel;
  static String get startTitle => _t.sessionStartTitle;
  static String get startQuiz => _t.sessionStartQuiz;
  static String get startJourney => _t.sessionStartJourney;
  static String get startRecording => _t.sessionStartRecording;
  static String statusKeyButton(String title) =>
      _t.sessionStatusKeyButton(title);
  static String statusKeyLabel(String title) => _t.sessionStatusKeyLabel(title);
  static String activityCounts(int present, int started, int finished) =>
      _t.sessionActivityCounts(present, started, finished);
  static String get nowPlayingTitle => _t.sessionNowPlayingTitle;

  // More (key 7)
  static String get moreButton => _t.sessionMoreButton;
  static String get moreLabel => _t.sessionMoreLabel;
  static String get moreTitle => _t.sessionMoreTitle;
  static String get moreStatus => _t.sessionMoreStatus;
  static String get moreWhatIsPlaying => _t.sessionMoreWhatIsPlaying;
  static String get moreWhoIsHere => _t.sessionMoreWhoIsHere;
}
