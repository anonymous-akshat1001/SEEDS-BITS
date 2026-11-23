// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get spokenDigitWords =>
      'zero, one, two, three, four, five, six, seven, eight, nine';

  @override
  String get spokenMonths =>
      'January, February, March, April, May, June, July, August, September, October, November, December';

  @override
  String get spokenWeekdays =>
      'Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday';

  @override
  String get spokenPlus => 'plus';

  @override
  String spokenSession(String number) {
    return 'session $number';
  }

  @override
  String get spokenNoon => '12 noon';

  @override
  String get spokenMidnight => 'midnight';

  @override
  String spokenOClock(String hour) {
    return '$hour o\'clock';
  }

  @override
  String spokenMorning(String clock) {
    return '$clock in the morning';
  }

  @override
  String spokenAfternoon(String clock) {
    return '$clock in the afternoon';
  }

  @override
  String spokenEvening(String clock) {
    return '$clock in the evening';
  }

  @override
  String spokenNight(String clock) {
    return '$clock at night';
  }

  @override
  String get spokenToday => 'today';

  @override
  String get spokenTomorrow => 'tomorrow';

  @override
  String get spokenYesterday => 'yesterday';

  @override
  String spokenDate(String weekday, String day, String month) {
    return '$weekday $day $month';
  }

  @override
  String spokenDateWithYear(
    String weekday,
    String day,
    String month,
    String year,
  ) {
    return '$weekday $day $month $year';
  }

  @override
  String spokenDateAtTime(String date, String time) {
    return '$date at $time';
  }

  @override
  String spokenHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hours',
      one: '1 hour',
    );
    return '$_temp0';
  }

  @override
  String spokenMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutes',
      one: '1 minute',
    );
    return '$_temp0';
  }

  @override
  String spokenSeconds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count seconds',
      one: '1 second',
    );
    return '$_temp0';
  }

  @override
  String spokenPositionOf(String position, String total) {
    return '$position of $total';
  }

  @override
  String spokenPercent(String value) {
    return '$value percent';
  }

  @override
  String get spokenOn => 'on';

  @override
  String get spokenOff => 'off';

  @override
  String get keyBack10Seconds => 'Back 10 seconds';

  @override
  String get keyPlayOrPause => 'Play or pause';

  @override
  String get keyForward10Seconds => 'Forward 10 seconds';

  @override
  String get keySlower => 'Slower';

  @override
  String get keyFaster => 'Faster';

  @override
  String get keySlowerPlaybackSpeed => 'Slower playback speed';

  @override
  String get keyFasterPlaybackSpeed => 'Faster playback speed';

  @override
  String get keyLogin => 'Login';

  @override
  String get keyRegister => 'Register';

  @override
  String get keySettings => 'Settings';

  @override
  String get keySelectStudentAccount => 'Select Student Account';

  @override
  String get keySelectTeacherAccount => 'Select Teacher Account';

  @override
  String get keySelectAdministratorAccount => 'Select Administrator Account';

  @override
  String get keyGoToLogin => 'Go to Login';

  @override
  String get keyToggleTeacherRegistration => 'Toggle Teacher Registration';

  @override
  String get keyGoBack => 'Go Back';

  @override
  String get keyToggleTTS => 'Toggle T T S';

  @override
  String get keyToggleVoiceCommands => 'Toggle Voice Commands';

  @override
  String get keyShowOrHideShortcuts => 'Show or Hide Shortcuts';

  @override
  String get keyToggleHighContrast => 'Toggle High Contrast';

  @override
  String get keyTestTTS => 'Test T T S';

  @override
  String get keySaveSettings => 'Save Settings';

  @override
  String get keyCheckVoice => 'Check voice';

  @override
  String get keySoundCuesOnOrOff => 'Sound cues on or off';

  @override
  String get keyVibrationOnOrOff => 'Vibration on or off';

  @override
  String get keyLogOutAsksToConfirm => 'Log out, asks to confirm';

  @override
  String get keyRefreshSessions => 'Refresh Sessions';

  @override
  String get keySearchSessionsByNameOrID => 'Search Sessions by Name or ID';

  @override
  String get keyRecordedAudioLibrary => 'Recorded Audio Library';

  @override
  String get keyMyPrivatePlaylists => 'My Private Playlists';

  @override
  String get keyQuizzes => 'Quizzes';

  @override
  String get keyLearningJourneys => 'Learning journeys';

  @override
  String get keyCreateSession => 'Create Session';

  @override
  String get keyClassPlaylists => 'Class Playlists';

  @override
  String get keyChooseClassAndSubjectWorkspace =>
      'Choose class and subject workspace';

  @override
  String get keyRefresh => 'Refresh';

  @override
  String get keySearchUsers => 'Search Users';

  @override
  String get keyChangeAccountTypeFilter => 'Change Account Type Filter';

  @override
  String get keyChangeAssignmentFilter => 'Change Assignment Filter';

  @override
  String get keyCreateSubject => 'Create Subject';

  @override
  String get keyCreateClass => 'Create Class';

  @override
  String get keyChooseAccountsClassesOrSubjectsSection =>
      'Choose Accounts, Classes, or Subjects section';

  @override
  String get keyGoBackAlt => 'Go back';

  @override
  String get keyCreateBankQuestion => 'Create bank question';

  @override
  String get keyCreateQuizDraft => 'Create quiz draft';

  @override
  String get keyCreateUntimedUngradedPractice =>
      'Create untimed ungraded practice';

  @override
  String get keyRefreshQuizzes => 'Refresh quizzes';

  @override
  String get keyChooseOption1 => 'Choose option 1';

  @override
  String get keyChooseOption2 => 'Choose option 2';

  @override
  String get keyChooseOption3 => 'Choose option 3';

  @override
  String get keyChooseOption4 => 'Choose option 4';

  @override
  String get keySubmitSelectedAnswer => 'Submit selected answer';

  @override
  String get keyRepeatQuestionAndOptions => 'Repeat question and options';

  @override
  String get keySlowerQuizSpeech => 'Slower quiz speech';

  @override
  String get keyWhereAmIIncludingTimeLeft => 'Where am I, including time left';

  @override
  String get keyFasterQuizSpeech => 'Faster quiz speech';

  @override
  String get keyMuteOrUnmute => 'Mute or unmute';

  @override
  String get keyRaiseOrLowerHand => 'Raise or lower hand';

  @override
  String get keyHearClassStatus => 'Hear class status';

  @override
  String get keyChat => 'Chat';

  @override
  String get keyHearWhatTheTeacherIsPlaying =>
      'Hear what the teacher is playing';

  @override
  String get keyAnswerClassroomCheck => 'Answer classroom check';

  @override
  String get keyWhoIsInTheClass => 'Who is in the class';

  @override
  String get keyLeaveSessionAsksToConfirm => 'Leave session, asks to confirm';

  @override
  String get keyRaisedHandsAcknowledgeAndLowerThemInOrder =>
      'Raised hands: acknowledge and lower them in order';

  @override
  String get keyClassRecordingPlayerPlayAndControlTheRecording =>
      'Class recording player: play and control the recording';

  @override
  String get keyClassroomCheckStartCloseAndHearResponses =>
      'Classroom check: start, close and hear responses';

  @override
  String get keyParticipantsMuteOrRemoveSomeone =>
      'Participants: mute or remove someone';

  @override
  String get keyTeacherToolsInviteStudentsEndClassForEveryone =>
      'Teacher tools: invite students, end class for everyone';

  @override
  String get keyRefreshClasses => 'Refresh Classes';

  @override
  String get keySearchClassByName => 'Search Class by Name';

  @override
  String get keyAllAudioFiles => 'All Audio Files';

  @override
  String get keyFocusFirstActiveClassUseDPadToBrowseClasses =>
      'Focus first active class; use D-pad to browse classes';

  @override
  String get keyRefreshFiles => 'Refresh files';

  @override
  String get keyNextSubjectFilter => 'Next subject filter';

  @override
  String get keyStopPlayback => 'Stop playback';

  @override
  String get keyAddAudioFile => 'Add audio file';

  @override
  String get keyUploadNewFile => 'Upload New File';

  @override
  String get keySelectFromExistingLibrary => 'Select from Existing Library';

  @override
  String get keyRefreshList => 'Refresh List';

  @override
  String get appName => 'SEEDS';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageHindi => 'Hindi';

  @override
  String get languageKannada => 'Kannada';

  @override
  String get languageTelugu => 'Telugu';

  @override
  String get languageBengali => 'Bengali';

  @override
  String get commonPleaseWait => 'Please wait. Still working.';

  @override
  String get commonSignInFirst => 'Please sign in first.';

  @override
  String get commonAccountChanged =>
      'Your account changed on this phone. Sign in again.';

  @override
  String get commonNoWorkspace =>
      'No class and subject is chosen. Press 7 to choose a workspace.';

  @override
  String get commonNoConnection =>
      'No connection to the school server. Check your internet and try again.';

  @override
  String get commonNotAvailable => 'This is not available right now.';

  @override
  String get commonNothingChanged => 'Nothing was changed.';

  @override
  String get commonNoMessages => 'There are no messages on this screen.';

  @override
  String get commonEndOfList => 'End of list. Back to the first item.';

  @override
  String get commonTopOfList => 'Top of list. Moved to the last item.';

  @override
  String commonOpening(String what) {
    return 'Opening $what.';
  }

  @override
  String commonOpeningNeedsInternet(String what) {
    return 'Opening $what. Internet is required.';
  }

  @override
  String commonUnavailable(String what) {
    return '$what is not available.';
  }

  @override
  String commonUnavailableBecause(String what, String reason) {
    return '$what is not available. $reason';
  }

  @override
  String commonWhereScreen(String screen) {
    return '$screen.';
  }

  @override
  String commonWhereFocused(String item) {
    return 'Focused: $item.';
  }

  @override
  String keypadPressFor(String key, String action) {
    return 'Press $key for $action';
  }

  @override
  String get keypadListSeparator => '. ';

  @override
  String get keypadRepeatInstructions =>
      'Press star to repeat these instructions.';

  @override
  String get keypadRepeatFullHelp => 'Press star to repeat full help.';

  @override
  String get keypadStarForShortcuts => 'Press star for all shortcuts.';

  @override
  String keypadScreenReaderIntro(String screen) {
    return '$screen. Press star for keypad help.';
  }

  @override
  String keypadMoveThroughSections(String sections) {
    return 'Use D-pad up and down to move through $sections. Press OK to activate the focused control.';
  }

  @override
  String get keypadNumberedBackAndStop =>
      'Press 0 to go back or cancel. Press hash to stop app speech.';

  @override
  String get keypadNumberedEditing =>
      'While editing, keys enter text. Press OK to finish, or use up or down to leave the field.';

  @override
  String get keypadNumberedMove =>
      'Use D-pad up and down to move between choices and OK to select.';

  @override
  String get keypadEssentialMove =>
      'Use up and down to move, and OK to select.';

  @override
  String get keypadPressZeroBack => 'Press 0 to go back.';

  @override
  String get keypadHashAndStar =>
      'Press hash to stop speech. Press star to repeat these instructions.';

  @override
  String get keypadDirectionKeys => 'Use the direction keys to move.';

  @override
  String get keypadDirectionKeysAndOk =>
      'Use the direction keys to move and OK to select.';

  @override
  String get keypadActivateOrEdit =>
      'Press OK to activate a control or edit a field.';

  @override
  String get keypadLeaveField =>
      'While editing, press OK or use up or down to leave the field.';

  @override
  String keypadPosition(String index, String total) {
    return ', $index of $total';
  }

  @override
  String keypadEditingPressOk(String label) {
    return '$label. Editing. Press OK when finished.';
  }

  @override
  String keypadEditingUseUpDown(String label) {
    return '$label. Editing. Use up or down to leave this field.';
  }

  @override
  String get keypadControlUnavailable =>
      'This control is not available right now.';

  @override
  String get keypadMainScreen =>
      'This is the main screen. There is nothing to go back to.';

  @override
  String messageLast(String text) {
    return 'Last message: $text';
  }

  @override
  String messageLastProblem(String text) {
    return 'Last problem: $text';
  }

  @override
  String ttsSpeedDescription(String speed) {
    return '$speed times normal speed';
  }

  @override
  String get ttsUnavailable =>
      'Speech is unavailable. Enable an English Android text-to-speech voice, then use Test TTS in Settings.';

  @override
  String ttsLanguageFallback(String language) {
    return 'No $language voice is available on this phone, so SEEDS will speak English. Install the $language voice in Android text-to-speech settings, then check the voice in Settings.';
  }

  @override
  String get ttsScreenReaderDetected =>
      'Screen reader detected. SEEDS will send its announcements to your screen reader.';

  @override
  String get ttsScreenReaderOff =>
      'Screen reader turned off. SEEDS will speak for itself.';

  @override
  String ttsVoiceInstalled(String language) {
    return 'Android reports installed $language voice data. Use Test TTS in Settings, then test it again in airplane mode before relying on offline speech. This check cannot prove that you can hear it.';
  }

  @override
  String ttsVoiceNotOffline(String language) {
    return '$language is available, but installed offline voice data was not confirmed. Speech may need internet.';
  }

  @override
  String ttsVoiceMissing(String language) {
    return 'No $language voice was detected.';
  }

  @override
  String ttsVoiceUnverified(String language) {
    return '$language voice availability could not be verified.';
  }

  @override
  String ttsVoiceRecovery(String language) {
    return 'Open Android Settings, find Text-to-speech output, select the $language voice and install its voice data. Return here and check again. You can use your Android screen reader instead of app speech.';
  }

  @override
  String get ttsSpeedChangeFailed =>
      'Speech speed could not be changed. Try again.';

  @override
  String get ttsSettingsFailed =>
      'Speech settings could not be applied. Try Test TTS again.';

  @override
  String get ttsCouldNotStart =>
      'Speech could not start. Try Test TTS in Settings.';

  @override
  String get ttsNotAvailable =>
      'Speech was not available. Try Test TTS in Settings.';

  @override
  String get ttsFailed => 'Speech failed. Try Test TTS in Settings.';

  @override
  String get ttsLessonResumeFailed =>
      'The recorded lesson could not resume. Select Play to retry.';

  @override
  String get ttsStopFailed =>
      'Speech could not be stopped. Check the Android TTS engine.';

  @override
  String get ttsNoPendingUpdates => 'No pending updates.';

  @override
  String get ttsOtherUpdates => 'Other updates';

  @override
  String ttsUpdateGroup(String group) {
    return '$group.';
  }

  @override
  String ttsUpdateGroupCount(String group, int count) {
    return '$group, $count updates.';
  }

  @override
  String ttsOtherUpdateGroups(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count other update groups.',
      one: '1 other update group.',
    );
    return '$_temp0';
  }

  @override
  String get settingsScreenName => 'Settings';

  @override
  String get settingsSections =>
      'four sections: Speech, Display, Keys and help, then Save settings';

  @override
  String get settingsLoaded => 'Settings loaded';

  @override
  String get settingsSaved => 'Settings saved';

  @override
  String get settingsResetSaved => 'Settings reset to defaults and saved';

  @override
  String settingsTestSpeech(String volume, String speed) {
    return 'This is a test of the text to speech system. Volume is $volume percent. Speech speed is $speed.';
  }

  @override
  String settingsFastestSpeed(String speed) {
    return 'Fastest speech speed, $speed';
  }

  @override
  String settingsSlowestSpeed(String speed) {
    return 'Slowest speech speed, $speed';
  }

  @override
  String settingsSpeechSpeed(String speed) {
    return 'Speech speed $speed';
  }

  @override
  String get settingsVoiceCommandsEnabled => 'Voice commands enabled';

  @override
  String get settingsVoiceCommandsDisabled => 'Voice commands disabled';

  @override
  String get settingsHighContrastOn => 'High contrast on';

  @override
  String get settingsHighContrastOff => 'High contrast off';

  @override
  String get settingsShortcutsShown => 'Keypad shortcuts shown';

  @override
  String get settingsShortcutsHidden => 'Keypad shortcuts hidden';

  @override
  String get settingsVoiceHelp =>
      'In a session, activate Listen for command, then say mute, unmute, raise hand, lower hand, leave, or repeat. Listening does not restart automatically. Unmute asks for a key or touch confirmation.';

  @override
  String settingsModeAutomatic(String current) {
    return 'Automatic: follows TalkBack unless you choose. Now $current.';
  }

  @override
  String get settingsModeUsingScreenReader => 'using the screen reader';

  @override
  String get settingsModeUsingSelfVoicing => 'self-voicing';

  @override
  String get settingsModeScreenReader =>
      'Screen reader: announcements go to TalkBack. App narration is off.';

  @override
  String get settingsModeSelfVoicing =>
      'Self-voicing: the app speaks for itself.';

  @override
  String settingsSoundCues(String state) {
    return 'Sound cues $state.';
  }

  @override
  String settingsSoundCuesOnSaved(String state) {
    return 'Sound cues $state. This is the saved sound.';
  }

  @override
  String settingsVibration(String state) {
    return 'Vibration $state.';
  }

  @override
  String settingsVibrationOnBuzz(String state) {
    return 'Vibration $state. One short buzz means OK.';
  }

  @override
  String settingsSoundCuesLabel(String state) {
    return 'Sound cues, $state. Short sounds for correct, wrong, saved, errors and your turn to speak';
  }

  @override
  String settingsVibrationLabel(String state) {
    return 'Vibration, $state. One buzz for OK, two for an error, a long buzz for leaving';
  }

  @override
  String get settingsSoundCuesHelp =>
      'Short sounds for correct, wrong, saved, errors, end of list and your turn to speak. Saved immediately.';

  @override
  String get settingsVibrationHelp =>
      'One short buzz for OK, two for an error, one long buzz for leaving or ending. Saved immediately.';

  @override
  String settingsState(
    String speech,
    String speed,
    String volume,
    String textSize,
    String highContrast,
    String soundCues,
    String vibration,
    String language,
  ) {
    return 'App speech $speech, speed $speed, volume $volume percent. Text size $textSize percent. High contrast $highContrast. Sound cues $soundCues. Vibration $vibration. Speech language $language.';
  }

  @override
  String settingsVolume(String percent) {
    return 'Volume $percent percent';
  }

  @override
  String settingsTextSize(String percent) {
    return 'Text size $percent percent';
  }

  @override
  String get settingsSpeechOff => 'App speech off';

  @override
  String get settingsSpeechOn => 'App speech on';

  @override
  String settingsSpeechMode(String description) {
    return 'Speech mode. $description';
  }

  @override
  String settingsNarration(String level) {
    return 'Narration level $level.';
  }

  @override
  String get settingsNarrationEssential => 'essential';

  @override
  String get settingsNarrationStandard => 'standard';

  @override
  String get settingsNarrationDetailed => 'detailed';

  @override
  String settingsLanguage(String language) {
    return 'Speech language $language.';
  }

  @override
  String settingsLanguageLabel(String language) {
    return 'Speech language, $language. Press OK to change.';
  }

  @override
  String get settingsBack => 'Back';

  @override
  String get settingsResetLabel =>
      'Reset settings to defaults, asks to confirm';

  @override
  String settingsSpeechSectionLabel(String state) {
    return 'Speech section. App speech, $state';
  }

  @override
  String settingsVolumeLabel(String percent) {
    return 'Volume $percent percent. Left or right to change';
  }

  @override
  String settingsSpeedLabel(String speed) {
    return 'Speech speed $speed. Left or right to change';
  }

  @override
  String get settingsTestLabel => 'Test speech';

  @override
  String settingsModeLabel(String description) {
    return 'Speech mode. $description Press OK to change.';
  }

  @override
  String settingsNarrationLabel(String level) {
    return 'Narration level $level. Press OK to change.';
  }

  @override
  String settingsCheckVoiceLabel(String language) {
    return 'Check $language voice';
  }

  @override
  String get settingsStopLabel => 'Stop speech';

  @override
  String settingsContrastLabel(String state) {
    return 'Display section. High contrast, $state. On by default';
  }

  @override
  String settingsTextSizeLabel(String percent) {
    return 'Text size $percent percent. Left or right to change';
  }

  @override
  String settingsShortcutsLabel(String state) {
    return 'Keys and help section. Show keypad shortcuts, $state';
  }

  @override
  String settingsVoiceCommandsLabel(String state) {
    return 'Voice commands in sessions, $state';
  }

  @override
  String get settingsVoiceHelpLabel => 'Voice command help';

  @override
  String get settingsRepeatHelpLabel => 'Repeat Settings help';

  @override
  String get settingsSaveLabel => 'Save settings';

  @override
  String get settingsResetQuestion =>
      'Reset all settings to defaults? Speech, display and key settings return to their original values.';

  @override
  String settingsResetScreen(String question) {
    return 'Reset settings. $question';
  }

  @override
  String get settingsResetCancel => 'Cancel';

  @override
  String get settingsResetConfirm => 'Reset';

  @override
  String get settingsResetCancelLabel => 'Cancel, keep my settings';

  @override
  String get settingsResetConfirmLabel => 'Reset all settings to defaults';

  @override
  String get quizNotSet => 'not set';

  @override
  String get quizNotAvailable => 'not available';

  @override
  String get quizNotAvailableCapital => 'Not available';

  @override
  String quizQuestionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count questions',
      one: '1 question',
    );
    return '$_temp0';
  }

  @override
  String quizAttemptCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count attempts',
      one: '1 attempt',
    );
    return '$_temp0';
  }

  @override
  String quizStudentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count students',
      one: '1 student',
    );
    return '$_temp0';
  }

  @override
  String get quizAccountChanged =>
      'Your account changed. Return to quizzes and sign in again.';

  @override
  String get quizUnlimitedPractice =>
      'Unlimited practice attempts. Not graded.';

  @override
  String quizAttemptsRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count attempts remaining.',
      one: '1 attempt remaining.',
    );
    return '$_temp0';
  }

  @override
  String quizTimeLimit(String duration) {
    return 'Time limit $duration.';
  }

  @override
  String get quizNoTimeLimit => 'No time limit.';

  @override
  String get quizNoTimeLimitShort => 'No time limit';

  @override
  String get quizFeedbackAfterCompletion =>
      'Answer feedback and scores are released after you finish the quiz.';

  @override
  String quizFeedbackScheduled(String when) {
    return 'Feedback and scores are released after you finish and after $when.';
  }

  @override
  String get quizFeedbackScoreOnly =>
      'Only the score is released after you finish. Answers and explanations are not released.';

  @override
  String get quizFeedbackImmediate =>
      'You hear whether each answer is right as soon as you submit it.';

  @override
  String get quizPolicyAfterCompletion => 'after the quiz is finished';

  @override
  String get quizPolicyScheduled => 'at a scheduled time';

  @override
  String get quizPolicyScoreOnly => 'score only';

  @override
  String get quizPolicyLegacyImmediate => 'immediately, older setting';

  @override
  String get quizPolicyImmediate => 'immediately after each answer';

  @override
  String quizPracticeResult(String correct, String total) {
    return 'Practice, not an academic grade. $correct of $total correct in this practice.';
  }

  @override
  String quizScoreNotReleased(String message) {
    return 'Score not released. $message';
  }

  @override
  String get quizCheckReleasePolicy => 'Check the release policy.';

  @override
  String quizScoreResult(String correct, String total, String percent) {
    return 'Score $correct of $total, $percent.';
  }

  @override
  String get quizStatusInProgress => 'in progress';

  @override
  String get quizStatusTimedOut => 'finished when time ran out';

  @override
  String get quizStatusCompleted => 'finished';

  @override
  String get quizStatusPublished => 'published';

  @override
  String get quizStatusDraft => 'draft';

  @override
  String get quizStatusClosed => 'closed';

  @override
  String get quizStatusScheduled => 'scheduled';

  @override
  String get quizStatusOpen => 'open';

  @override
  String quizQuestionHeading(String number, String total) {
    return 'Question $number of $total';
  }

  @override
  String quizQuestionWithText(String number, String total, String text) {
    return 'Question $number of $total. $text';
  }

  @override
  String quizOptionSpoken(String number, String text) {
    return 'Option $number. $text.';
  }

  @override
  String quizOptionLabel(String number, String count, String text) {
    return 'Option $number of $count, $text';
  }

  @override
  String quizOptionTargetSelected(String number, String text) {
    return 'Option $number, $text, selected. Press OK or $number to choose';
  }

  @override
  String quizOptionTargetNotSelected(String number, String text) {
    return 'Option $number, $text, not selected. Press OK or $number to choose';
  }

  @override
  String quizAnswerKeysBrief(String count) {
    return 'Press 1 to $count, then 5.';
  }

  @override
  String quizAnswerKeysDetailed(String count) {
    return 'Press 1 to $count to choose an answer, then 5 to submit it. Press 6 to repeat the question, 8 to hear where you are.';
  }

  @override
  String quizChosenBrief(String number, String text) {
    return 'Option $number, $text, selected.';
  }

  @override
  String quizChosenDetailed(String number, String text) {
    return 'Option $number, $text, selected. Press 5 to submit, or choose another number.';
  }

  @override
  String quizChooseFirst(String count) {
    return 'Choose an answer first. Press 1 to $count, then 5 to submit.';
  }

  @override
  String quizNoSuchOption(String option, String count) {
    return 'There is no option $option. Press 1 to $count.';
  }

  @override
  String get quizSubmitting => 'Submitting your answer.';

  @override
  String quizCorrectFeedback(String answer) {
    return 'Correct! $answer.';
  }

  @override
  String quizWrongFeedback(String answer) {
    return 'Not quite. The answer is $answer.';
  }

  @override
  String get quizAnswerSavedBrief => 'Answer saved.';

  @override
  String get quizAnswerSavedLocked => 'Answer saved and locked.';

  @override
  String get quizSavedHeading => 'Answer saved and locked';

  @override
  String get quizCorrectHeading => 'Correct';

  @override
  String get quizWrongHeading => 'Incorrect';

  @override
  String quizYouSelected(String text) {
    return 'You selected: $text';
  }

  @override
  String quizCorrectAnswerIs(String text) {
    return 'Correct answer: $text';
  }

  @override
  String get quizNoExplanation => 'No explanation provided.';

  @override
  String quizAnswerFailed(String reason) {
    return '$reason Your selection is preserved. Press 5 to try again.';
  }

  @override
  String get quizAnswerUnreadable =>
      'The answer confirmation could not be read.';

  @override
  String get quizNoOptionSelected => 'No option selected.';

  @override
  String quizSelectionSaved(String number, String text) {
    return 'Selected option $number, $text. Answer saved.';
  }

  @override
  String quizSelectionNotSubmitted(String number, String text) {
    return 'Selected option $number, $text. Not submitted yet.';
  }

  @override
  String get quizRepeatQuestion => 'Repeat question and options';

  @override
  String get quizAnswerConfirmed => 'Answer confirmed saved and locked.';

  @override
  String get quizFeedbackStaysAvailable =>
      'Feedback for it stays available privately on the next question.';

  @override
  String get quizPreviousFeedback =>
      'Hear feedback for the previous answer, privately';

  @override
  String get quizAnswerLockNotice =>
      'Each answer is saved and locked when you press 5.';

  @override
  String quizTimeLeft(String duration) {
    return 'Time left: $duration.';
  }

  @override
  String quizClockLeft(String clock) {
    return '$clock left';
  }

  @override
  String quizClockRemaining(String clock) {
    return '$clock remaining';
  }

  @override
  String quizTimeWarning(String duration) {
    return '$duration left in this quiz.';
  }

  @override
  String quizTimeUp(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Time is up. $count answers saved. Finishing the quiz.',
      one: 'Time is up. 1 answer saved. Finishing the quiz.',
    );
    return '$_temp0';
  }

  @override
  String quizWhereQuestion(String number, String total) {
    return 'Question $number of $total.';
  }

  @override
  String quizAnsweredCount(String count) {
    return '$count answered.';
  }

  @override
  String get quizAllSaved =>
      'All answers are saved. Press 5 to finish and hear your result.';

  @override
  String get quizFinishNow => 'Finish quiz now, with confirmation';

  @override
  String get quizFinishNowButton => 'Finish quiz now';

  @override
  String get quizFinishTitle => 'Finish quiz now?';

  @override
  String quizFinishMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'The server shows $count questions not answered. Only saved answers count. A selected answer that you did not submit is not included. You cannot change answers after finishing.',
      one:
          'The server shows 1 question not answered. Only saved answers count. A selected answer that you did not submit is not included. You cannot change answers after finishing.',
    );
    return '$_temp0';
  }

  @override
  String get quizFinishConfirm => 'Finish quiz';

  @override
  String get quizFinishCancel => 'Keep working';

  @override
  String get quizFinishUnchecked =>
      'Your saved answers could not be checked, or this attempt has ended. The quiz was not finished. Return to the quiz list to refresh it.';

  @override
  String get quizFinishTimedOut =>
      'Checking your saved answers took too long. The quiz was not finished. Check your connection and try again.';

  @override
  String get quizFinishing => 'Finishing the quiz';

  @override
  String get quizFinishAndHear => 'Finish and hear result';

  @override
  String get quizRetryFinishing => 'Retry finishing';

  @override
  String quizCompletionFailed(String reason) {
    return '$reason Your saved answers are preserved. Press 5 to retry finishing.';
  }

  @override
  String get quizCompletionNotConfirmed => 'Completion was not confirmed.';

  @override
  String get quizCompleted =>
      'Quiz finished. Your result is private. Press 8 to hear it, or 0 to return to quizzes.';

  @override
  String get quizCompletedTimedOut =>
      'Time ran out. Quiz finished. Your result is private. Press 8 to hear it, or 0 to return to quizzes.';

  @override
  String get quizResultPrivate =>
      'Quiz finished. Result private. Use Read result privately.';

  @override
  String get quizResultHeading => 'Attempt complete';

  @override
  String get quizReadResult => 'Read result privately';

  @override
  String get quizReturnToQuizzes => 'Return to quizzes';

  @override
  String get quizLeave => 'Leave without submitting, with confirmation';

  @override
  String get quizLeaveTitle => 'Leave and resume later?';

  @override
  String get quizLeaveMessage =>
      'This does not submit your attempt. Only saved answers are kept; a selected answer that you did not submit may be lost. Any time limit keeps running. You can resume while the quiz allows it.';

  @override
  String get quizLeaveConfirm => 'Leave without submitting';

  @override
  String get quizLeaveCancel => 'Stay in quiz';

  @override
  String get quizWaitBeforeLeaving =>
      'Please wait. Your answer is still being saved.';

  @override
  String quizAttemptScreen(String title) {
    return 'Quiz attempt, $title';
  }

  @override
  String get quizAttemptNavigationCompleted =>
      'return to quizzes, read result privately and quiz speech speed';

  @override
  String get quizAttemptNavigationTimed =>
      'the question, each answer option, the selected answer, quiz speech speed, time left, submit, Finish quiz now and Leave. Moving focus never selects or submits';

  @override
  String get quizAttemptNavigationUntimed =>
      'the question, each answer option, the selected answer, quiz speech speed, submit, Finish quiz now and Leave. Moving focus never selects or submits';

  @override
  String get quizSpeedHelp =>
      'Press 7 or 9 to make quiz speech slower or faster.';

  @override
  String get quizSpeedScreenReader =>
      'Quiz speech speed changes app speech only. Change your screen reader speed in Android settings.';

  @override
  String get quizSpeedHeading => 'Quiz speech speed';

  @override
  String quizSpeedTarget(String description) {
    return 'Quiz speech speed, $description. Left or right to change, or press 7 or 9';
  }

  @override
  String quizSpeedRead(String description) {
    return 'Quiz speech speed, $description. Press 7 for slower or 9 for faster. This speed is used only in quizzes.';
  }

  @override
  String quizSpeedFaster(String description) {
    return 'Faster. $description.';
  }

  @override
  String quizSpeedSlower(String description) {
    return 'Slower. $description.';
  }

  @override
  String quizSpeedFastest(String description) {
    return 'Fastest quiz speech, $description.';
  }

  @override
  String quizSpeedSlowest(String description) {
    return 'Slowest quiz speech, $description.';
  }

  @override
  String get quizStudentScreen => 'Student quizzes';

  @override
  String get quizStudentNavigation =>
      'refresh, quiz state and subject filters, available quizzes, and attempt history';

  @override
  String get quizStudentIntroBrief =>
      'Use left or right on a filter to change it.';

  @override
  String get quizStudentIntroDetailed =>
      'Use left or right on a filter to change it. Press OK on a quiz to hear its details and confirm starting. Moving focus never starts a quiz.';

  @override
  String quizAvailable(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count quizzes available.',
      one: '1 quiz available.',
      zero: 'No quizzes available.',
    );
    return '$_temp0';
  }

  @override
  String quizStudentState(int count, String open) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count quizzes shown, $open open.',
      one: '1 quiz shown, $open open.',
    );
    return '$_temp0';
  }

  @override
  String get quizStateAll => 'All states';

  @override
  String get quizStateScheduled => 'Scheduled';

  @override
  String get quizStateOpen => 'Open';

  @override
  String get quizStateClosed => 'Closed';

  @override
  String quizStateFilter(String name, String position, String count) {
    return 'Quiz state: $name, $position of $count.';
  }

  @override
  String quizSubjectFilter(String name, String position, String count) {
    return 'Subject: $name, $position of $count.';
  }

  @override
  String get quizChangeWithArrows => 'Left or right to change';

  @override
  String get quizAllSubjects => 'All subjects';

  @override
  String quizRowHead(String subject, String title, String status) {
    return '$subject, $title, $status.';
  }

  @override
  String get quizStartQuiz => 'Start quiz';

  @override
  String get quizResumeQuiz => 'Resume quiz';

  @override
  String quizHistoryRow(String title, String score) {
    return 'Review $title attempt history. Highest score $score';
  }

  @override
  String quizLimitReached(String title) {
    return 'No attempts left for $title. Open attempt history to review your scores.';
  }

  @override
  String get quizStartTitle => 'Start quiz?';

  @override
  String get quizResumeTitle => 'Resume quiz?';

  @override
  String quizTitleSentence(String title) {
    return '$title.';
  }

  @override
  String quizClosesSentence(String when) {
    return 'Closes $when.';
  }

  @override
  String get quizStartAttempt => 'Start attempt';

  @override
  String get quizResumeAttempt => 'Resume attempt';

  @override
  String get quizStartFailed =>
      'The quiz could not be started. Check that it is open.';

  @override
  String get quizHistoryFailed => 'Attempt history could not be loaded.';

  @override
  String get quizHistoryScreen =>
      'Attempt history. Scores are private. Move to the summary or an attempt to review it.';

  @override
  String get quizPracticeHistory => 'Practice history. Not academic grades.';

  @override
  String quizHighestScoreValue(String score) {
    return 'Highest score: $score';
  }

  @override
  String get quizNoScoreReleasedYet =>
      'Completed attempts exist; no score is released yet.';

  @override
  String get quizNoCompletedAttempt => 'No completed attempt';

  @override
  String quizHistoryAttempt(String number, String status, String result) {
    return 'Attempt $number. $status. $result Press OK to review.';
  }

  @override
  String get quizResumeFromList =>
      'This attempt is in progress. Return to the quiz list to resume it. Leaving does not submit.';

  @override
  String get quizReviewFailed =>
      'Attempt review could not be loaded. Check your connection and try again.';

  @override
  String get quizReviewTimedOut =>
      'Attempt review took too long. Check your connection and try again.';

  @override
  String quizReviewScreenMessage(String message) {
    return 'Attempt review. $message';
  }

  @override
  String quizReviewScreen(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Attempt review. $count questions. Use up and down to review each answer.',
      one: 'Attempt review. 1 question. Use up and down to review each answer.',
    );
    return '$_temp0';
  }

  @override
  String quizReviewQuestionCorrect(
    String number,
    String question,
    String chosen,
    String answer,
    String explanation,
  ) {
    return 'Question $number. Correct. $question. You chose $chosen. Correct answer $answer. $explanation';
  }

  @override
  String quizReviewQuestionIncorrect(
    String number,
    String question,
    String chosen,
    String answer,
    String explanation,
  ) {
    return 'Question $number. Incorrect. $question. You chose $chosen. Correct answer $answer. $explanation';
  }

  @override
  String get quizNoAnswer => 'no answer';

  @override
  String quizTeacherScreen(String className, String subjectName) {
    return 'Teacher quizzes for $className, $subjectName';
  }

  @override
  String get quizTeacherNavigation =>
      'bank search and saved questions, quiz drafts, published quizzes, and their results';

  @override
  String get quizTeacherIntroDetailed =>
      'Use the D-pad to explore bank search and saved questions, quiz drafts, published quizzes and results.';

  @override
  String quizBankQuestionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bank questions',
      one: '1 bank question',
    );
    return '$_temp0';
  }

  @override
  String quizQuizCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count quizzes',
      one: '1 quiz',
    );
    return '$_temp0';
  }

  @override
  String quizDraftCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count drafts',
      one: '1 draft',
    );
    return '$_temp0';
  }

  @override
  String quizTeacherLoaded(String questions, String quizzes) {
    return '$questions and $quizzes loaded.';
  }

  @override
  String quizTeacherState(
    String drafts,
    String published,
    String closed,
    String bankQuestions,
  ) {
    return '$drafts, $published published, $closed closed. $bankQuestions.';
  }

  @override
  String get quizTeacherLoadFailed =>
      'The question bank or quiz list could not be refreshed. Press 1 to try again before creating another quiz.';

  @override
  String get quizRefreshQuizzes => 'Refresh quiz content';

  @override
  String get quizSearchBank => 'Search private question bank';

  @override
  String get quizCreateQuestion => 'Create four option question';

  @override
  String get quizCreateQuiz => 'Create quiz draft';

  @override
  String get quizCreatePractice =>
      'Create separate untimed ungraded practice. Unlimited retries';

  @override
  String quizBankQuestionItem(String question, String revision) {
    return 'Question bank item, $question. Revision $revision. Press OK for edit, revision history, duplicate, archive, or add actions';
  }

  @override
  String get quizRevisionUnknownOlder => 'unknown, older question';

  @override
  String get quizRevisionUnknownLegacy => 'unknown legacy';

  @override
  String quizContinueCreating(String title, String questions) {
    return 'Continue creating $title. $questions';
  }

  @override
  String quizContinueCreatingRaw(String title, String count) {
    return 'Continue creating $title. $count questions';
  }

  @override
  String quizCloseWithConfirmation(String title) {
    return 'Close $title, with confirmation';
  }

  @override
  String quizCloseNamed(String title) {
    return 'Close $title';
  }

  @override
  String quizIsClosed(String title) {
    return '$title is closed';
  }

  @override
  String quizDuplicateTarget(String title) {
    return 'Duplicate $title into a new editable draft';
  }

  @override
  String quizResultsTarget(String title) {
    return 'View results for $title';
  }

  @override
  String quizCard(String title, String status, String questions) {
    return '$title. Status $status. $questions.';
  }

  @override
  String get quizAccountChangedBank =>
      'Your account changed. Reopen the question bank before continuing.';

  @override
  String quizQuestionSaveUnconfirmed(String reason) {
    return '$reason Question save could not be confirmed. Check the bank and refresh before retrying; do not create a duplicate.';
  }

  @override
  String get quizMissingRevision =>
      'The server returned a question without a revision. Ask the administrator to update the quiz backend.';

  @override
  String get quizSavedQuestionMismatch => 'The saved question did not match.';

  @override
  String get quizQuestionSaved =>
      'Question saved. Editing this bank question later will not change existing quizzes.';

  @override
  String get quizNoRevisionForEdit =>
      'This server did not supply a question revision. Ask the administrator to update the quiz backend before editing.';

  @override
  String quizQuestionUpdateUnconfirmed(String reason) {
    return '$reason The bank question could not be confirmed updated. Refresh and review its current revision before retrying.';
  }

  @override
  String get quizSavedRevisionMismatch => 'The saved revision did not match.';

  @override
  String get quizQuestionUpdated =>
      'Bank question updated. Existing quiz snapshots were not changed.';

  @override
  String get quizArchiveTitle => 'Archive bank question?';

  @override
  String get quizArchiveMessage =>
      'Archive this private bank question? Existing quiz snapshots and attempts are not changed.';

  @override
  String get quizArchiveConfirm => 'Archive question';

  @override
  String get quizArchiveFailed => 'The bank question could not be archived.';

  @override
  String get quizArchived => 'Bank question archived.';

  @override
  String get quizDuplicateQuestionFailed =>
      'The bank question could not be duplicated.';

  @override
  String get quizQuestionDuplicated => 'Bank question copy created.';

  @override
  String quizQuestionActions(String question) {
    return 'Actions for $question';
  }

  @override
  String get quizActionEdit => 'Edit bank question';

  @override
  String get quizActionDuplicate => 'Duplicate bank question';

  @override
  String get quizActionArchive => 'Archive bank question';

  @override
  String get quizActionRevisions => 'Read question revision history';

  @override
  String quizActionAddTo(String title) {
    return 'Add to $title';
  }

  @override
  String get quizRefreshBeforeDraft =>
      'Refresh and review the quiz list before creating another draft.';

  @override
  String quizDraftUnconfirmed(String reason) {
    return '$reason Draft save could not be confirmed. Refresh the quiz list before creating another draft.';
  }

  @override
  String get quizSavedDraftMismatch => 'The saved draft did not match.';

  @override
  String get quizDraftSaved => 'Quiz draft saved.';

  @override
  String get quizAddToQuizFailed =>
      'The question could not be added to this quiz.';

  @override
  String get quizAddedToQuiz => 'Question added to the quiz.';

  @override
  String get quizPublishTitle => 'Publish quiz?';

  @override
  String quizPublishMessage(String title) {
    return 'Publish \"$title\" to eligible students? Questions become fixed for this quiz.';
  }

  @override
  String quizPublishMessageSnapshots(String title) {
    return 'Publish \"$title\" to eligible students? Questions become academic snapshots.';
  }

  @override
  String get quizPublishConfirm => 'Publish quiz';

  @override
  String get quizPublishUnconfirmed =>
      'Publishing could not be confirmed. Refresh and review the quiz status before trying again.';

  @override
  String get quizPublishedNoRecipients =>
      'Quiz published. There are no eligible students to notify.';

  @override
  String get quizNoEligibleToNotify =>
      'There are no eligible students to notify.';

  @override
  String get quizPublishedNoneDelivered =>
      'Quiz published, but no student device notifications were delivered. Check notification registration and server Firebase credentials.';

  @override
  String quizPublishedWithFailures(String sent, String failures) {
    return 'Quiz published. $sent device notifications sent and $failures failed.';
  }

  @override
  String quizPublishedSent(String sent) {
    return 'Quiz published. $sent device notifications sent.';
  }

  @override
  String get quizCloseTitle => 'Close quiz?';

  @override
  String quizCloseMessage(String title) {
    return 'Close \"$title\"? No new attempts can start and active attempts will be finished.';
  }

  @override
  String quizCloseMessageFinalized(String title) {
    return 'Close \"$title\"? No new attempts can start and active attempts will be finalized.';
  }

  @override
  String get quizCloseConfirm => 'Close quiz';

  @override
  String get quizCloseFailed => 'The quiz could not be closed.';

  @override
  String get quizClosed => 'Quiz closed.';

  @override
  String get quizDuplicateQuizFailed => 'The quiz could not be duplicated.';

  @override
  String get quizQuizDuplicated => 'Editable quiz draft created.';

  @override
  String get quizDraftAccountChanged =>
      'Your account changed. This draft cannot be reviewed here.';

  @override
  String get quizDraftLoadFailed =>
      'The draft or question bank could not be loaded. Refresh before continuing.';

  @override
  String quizBankRefreshFailed(String reason) {
    return '$reason The question bank could not be refreshed. No question was added. Try Choose a saved question again.';
  }

  @override
  String get quizSavedListUnreadable =>
      'The saved question list could not be read.';

  @override
  String get quizNoUnusedQuestions =>
      'No unused questions are available in this workspace. Choose Write a question.';

  @override
  String get quizAllSavedQuestionsUsed =>
      'Every saved question is already in this quiz. Choose Write a question.';

  @override
  String get quizChooseSaved => 'Choose a saved question';

  @override
  String quizSavedQuestionFrom(
    String question,
    String className,
    String subjectName,
  ) {
    return '$question. From $className, $subjectName';
  }

  @override
  String get quizAnotherClass => 'another class';

  @override
  String get quizAnotherSubject => 'another subject';

  @override
  String quizAddUnconfirmed(String reason) {
    return '$reason Adding the question could not be confirmed. Refresh and review saved questions before adding again; it may already be saved.';
  }

  @override
  String get quizQuestionAddedSentence => 'Question added.';

  @override
  String get quizAddAnotherOrReview => 'Add another or choose Review.';

  @override
  String quizQuestionsSaved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count questions saved.',
      one: '1 question saved.',
    );
    return '$_temp0';
  }

  @override
  String quizQuestionsSavedRaw(String count) {
    return '$count questions saved.';
  }

  @override
  String quizDraftSummaryHead(
    String title,
    String description,
    String questions,
  ) {
    return '$title. $description $questions.';
  }

  @override
  String quizDraftSummaryHeadRaw(
    String title,
    String description,
    String count,
  ) {
    return '$title. $description $count questions.';
  }

  @override
  String get quizUngradedPracticeSummary =>
      'Ungraded practice. Unlimited attempts. No timer.';

  @override
  String quizGradedSummary(String attempts) {
    return 'Graded quiz. $attempts.';
  }

  @override
  String quizGradedSummaryRaw(String count) {
    return 'Graded quiz. $count attempts.';
  }

  @override
  String get quizNoTimer => 'No timer.';

  @override
  String quizPerAttempt(String duration) {
    return '$duration per attempt.';
  }

  @override
  String quizMinutesPerAttemptRaw(String minutes) {
    return '$minutes minutes per attempt.';
  }

  @override
  String quizOpensSentence(String when) {
    return 'Opens $when.';
  }

  @override
  String quizOpensColon(String value) {
    return 'Opens: $value.';
  }

  @override
  String quizClosesColon(String value) {
    return 'Closes: $value.';
  }

  @override
  String get quizWhenPublished => 'when published';

  @override
  String get quizNeverNotScheduled => 'never, not scheduled';

  @override
  String get quizNotScheduled => 'not scheduled';

  @override
  String quizShuffleQuestionsState(String state) {
    return 'Shuffle questions $state.';
  }

  @override
  String quizShuffleOptionsState(String state) {
    return 'Shuffle options $state.';
  }

  @override
  String quizShuffleQuestionsColon(String state) {
    return 'Shuffle questions: $state.';
  }

  @override
  String quizShuffleOptionsColon(String state) {
    return 'Shuffle options: $state.';
  }

  @override
  String get quizRemoveChoose => 'Choose a question to remove from this draft';

  @override
  String quizRemoveOption(String number, String text) {
    return 'Question $number: $text';
  }

  @override
  String get quizRemoveTitle => 'Remove selected question?';

  @override
  String get quizRemoveMessage =>
      'Remove this question from the draft? The reusable question bank is not changed.';

  @override
  String get quizRemoveConfirm => 'Remove question';

  @override
  String get quizRemoveUnconfirmed =>
      'Removal could not be confirmed. Review the refreshed draft before trying again.';

  @override
  String get quizQuestionRemovedSentence => 'Question removed from the draft.';

  @override
  String get quizSettingsUnconfirmed =>
      'Settings save could not be confirmed. Refresh and review the saved settings before publishing.';

  @override
  String get quizSettingsSaved =>
      'Quiz settings saved. Review them before publishing.';

  @override
  String quizSavedQuestion(String number, String text) {
    return 'Saved question $number: $text. Already in this draft. Press OK to read its options';
  }

  @override
  String quizQuestionNumbered(String number, String text) {
    return 'Question $number. $text.';
  }

  @override
  String quizDraftOption(String number, String text) {
    return 'Option $number: $text.';
  }

  @override
  String quizDraftOptionCorrect(String number, String text) {
    return 'Option $number: $text, correct answer.';
  }

  @override
  String get quizReviewingBeforePublishing => 'Reviewing before publishing.';

  @override
  String get quizAddingQuestions => 'Adding questions.';

  @override
  String get quizRefreshSavedDraft => 'Refresh saved draft';

  @override
  String get quizWriteQuestionTarget =>
      'Write a question and save it to this quiz and your question bank';

  @override
  String get quizReviewBeforePublishingTarget =>
      'Review questions and quiz settings before publishing';

  @override
  String get quizRemoveQuestionTarget =>
      'Remove a question from this draft, with confirmation';

  @override
  String get quizChangeSettingsTarget =>
      'Change title or optional quiz settings';

  @override
  String get quizBackToAdding => 'Back to adding questions';

  @override
  String get quizPublishWithConfirmation => 'Publish quiz, with confirmation';

  @override
  String get quizSaveForLaterTarget =>
      'Save for later and return. Confirmed changes are already saved as a draft';

  @override
  String get quizDraftNavigationReview =>
      'saved questions, quiz settings, and publishing with confirmation';

  @override
  String get quizDraftNavigationAdd =>
      'write or choose saved questions, remove questions, and review the draft';

  @override
  String get quizPublishedScreen => 'Quiz published';

  @override
  String get quizDraftStep3 =>
      'Step 3 of 3. Review before publishing. Nothing is published until you confirm.';

  @override
  String get quizDraftStep2 =>
      'Step 2 of 3. Add questions. Choose Write or Use saved question. Then Review.';

  @override
  String get quizSaveForLater => 'Save for later and return';

  @override
  String get quizWriteQuestion => 'Write a question';

  @override
  String get quizUseSavedQuestion => 'Use saved question';

  @override
  String get quizRemoveQuestion => 'Remove a question';

  @override
  String get quizReview => 'Review';

  @override
  String get quizPublishConfirmLabel => 'Publish with confirmation';

  @override
  String get quizChangeSettingsLabel => 'Change title or optional settings';

  @override
  String quizResultsScreen(String title) {
    return 'Results for $title';
  }

  @override
  String get quizResultsNavigation =>
      'quiz summary, student results, and available result actions';

  @override
  String get quizResultsFailed => 'Quiz results could not be loaded.';

  @override
  String quizStudentsCompleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count students completed.',
      one: '1 student completed.',
    );
    return '$_temp0';
  }

  @override
  String quizStudentsNotAttemptedYet(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count students not attempted yet.',
      one: '1 student not attempted yet.',
    );
    return '$_temp0';
  }

  @override
  String quizResultsLoadedRaw(String completed, String notAttempted) {
    return '$completed students completed. $notAttempted students have not attempted.';
  }

  @override
  String quizStatEligible(String value) {
    return 'Eligible: $value';
  }

  @override
  String quizStatStarted(String value) {
    return 'Started: $value';
  }

  @override
  String quizStatCompleted(String value) {
    return 'Completed: $value';
  }

  @override
  String quizStatNotAttempted(String value) {
    return 'Not attempted: $value';
  }

  @override
  String quizStatCompletion(String value) {
    return 'Completion: $value';
  }

  @override
  String quizStatCompletionPercent(String value) {
    return 'Completion: $value percent';
  }

  @override
  String get quizPracticeParticipation =>
      'Practice participation, not academic grades.';

  @override
  String quizStatAverageHighest(String value) {
    return 'Average highest score: $value';
  }

  @override
  String quizStatLowest(String value) {
    return 'Lowest completed score: $value';
  }

  @override
  String quizStudentNotAttempted(String name) {
    return '$name has not attempted this quiz.';
  }

  @override
  String quizStudentPractice(int count, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$name. $count practice attempts. Not academic grades.',
      one: '$name. 1 practice attempt. Not academic grades.',
    );
    return '$_temp0';
  }

  @override
  String quizStudentPracticeRaw(String name, String count) {
    return '$name. $count practice attempts. Not academic grades.';
  }

  @override
  String quizStudentAttemptScore(String number, String score, String status) {
    return 'attempt $number, $score, $status';
  }

  @override
  String quizStudentAttemptRaw(String number, String score, String status) {
    return 'attempt $number, $score percent, $status';
  }

  @override
  String quizStudentScores(String name, String highest, String scores) {
    return '$name. Highest score $highest. $scores.';
  }

  @override
  String quizStudentScoresRaw(String name, String highest, String scores) {
    return '$name. Highest score $highest percent. $scores.';
  }

  @override
  String get quizExtraMismatch =>
      'The extra-time confirmation did not match. Refresh before retrying.';

  @override
  String get quizExtraSaved =>
      'Extra time confirmed for future attempts only. Existing attempt deadlines are unchanged and quiz closing time still applies.';

  @override
  String get quizEveryoneAttempted =>
      'Every eligible student has attempted this quiz.';

  @override
  String get quizRemindTitle => 'Remind students?';

  @override
  String quizRemindMessage(int count, String title) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Send one quiz reminder to all $count students who have not attempted $title?',
      one:
          'Send one quiz reminder to all 1 student who have not attempted $title?',
    );
    return '$_temp0';
  }

  @override
  String quizRemindMessageRaw(String count, String title) {
    return 'Send one quiz reminder to all $count students who have not attempted $title?';
  }

  @override
  String get quizRemindConfirm => 'Send reminder';

  @override
  String get quizRemindFailed => 'Quiz reminders could not be sent.';

  @override
  String quizReminded(String notified, String queued) {
    return 'Reminder sent to $notified students. $queued device notifications queued.';
  }

  @override
  String quizReminderProcessed(String notified, String queued) {
    return 'Reminder processed for $notified students. $queued device notifications queued.';
  }

  @override
  String get quizRefreshResults => 'Refresh quiz results';

  @override
  String get quizRefreshResultsLabel => 'Refresh results';

  @override
  String get quizRemindAllLabel => 'Remind all students who have not attempted';

  @override
  String get quizRemindUnavailable =>
      'All students have attempted. Reminder unavailable';

  @override
  String quizRemindTarget(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Send a reminder to all $count students who have not attempted',
      one: 'Send a reminder to all 1 student who have not attempted',
    );
    return '$_temp0';
  }

  @override
  String quizRemindTargetRaw(String count) {
    return 'Send a reminder to all $count students who have not attempted';
  }

  @override
  String quizExtraTarget(String name, String duration) {
    return 'Set extra time for $name. Future attempts only. Current extra time $duration';
  }

  @override
  String quizExtraTargetRaw(String name, String minutes) {
    return 'Set extra minutes for $name. Future attempts only. Current extra $minutes minutes';
  }

  @override
  String quizExtraButton(String minutes) {
    return 'Future extra time: $minutes minutes. Set';
  }

  @override
  String get quizResultsNotLoaded => 'Results not loaded.';

  @override
  String quizCompletionSentence(String percent) {
    return 'Completion $percent.';
  }

  @override
  String quizExtraScreen(String name) {
    return 'Extra time for $name. Future attempts only; active attempt deadlines stay fixed. Quiz closing time still applies. Entering zero minutes removes extra time. Press 0 outside the field to cancel.';
  }

  @override
  String quizExtraField(String value) {
    return 'Extra minutes, currently $value. Press OK to edit';
  }

  @override
  String get quizEmpty => 'empty';

  @override
  String get quizExtraSave => 'Save extra time for future attempts';

  @override
  String get quizExtraCancel => 'Cancel without changing extra time';

  @override
  String get quizExtraInvalid =>
      'Enter a whole number of minutes, zero or more, within the server integer range.';

  @override
  String get quizExtraCorrect => 'Move up to Extra minutes to correct it.';

  @override
  String get quizEditorInvalid =>
      'Enter a question, four different non-empty options, and then choose the correct answer.';

  @override
  String get quizEditorSpokenInvalid =>
      'Use up to 20 different topics of 80 characters each. Described notation needs a spoken question, all four spoken options, and a spoken explanation if an explanation is provided. Review and confirm every spoken alternative before saving.';

  @override
  String quizCorrectChosen(String number, String count) {
    return 'Correct answer: option $number, $number of $count.';
  }

  @override
  String quizCorrectChosenWithText(String number, String text, String count) {
    return 'Correct answer: option $number, $text, $number of $count.';
  }

  @override
  String get quizCorrectNotSelected =>
      'Correct answer not selected. Use left or right to choose';

  @override
  String quizCorrectTarget(String number, String text) {
    return 'Correct answer: option $number, $text. Use left or right to change';
  }

  @override
  String quizToggled(String name, String state) {
    return '$name $state.';
  }

  @override
  String get quizContentDescribed =>
      'Content: teacher-described notation or diagram';

  @override
  String get quizContentPlain => 'Content: English plain text';

  @override
  String get quizReviewedYes => 'Spoken alternatives reviewed by teacher: yes';

  @override
  String get quizReviewedNo => 'Spoken alternatives reviewed by teacher: no';

  @override
  String get quizSettingsInvalid =>
      'Check the title, attempt limit from 1 to 20, time limit, and schedule. The closing time must be after the opening time.';

  @override
  String get quizSetOpening =>
      'Set opening time using the date and time number fields.';

  @override
  String get quizSetClosing =>
      'Set closing time using the date and time number fields.';

  @override
  String quizOpeningSet(String when) {
    return 'Opening time set to $when.';
  }

  @override
  String quizClosingSet(String when) {
    return 'Closing time set to $when.';
  }

  @override
  String quizReleaseSet(String when) {
    return 'Feedback release set to $when.';
  }

  @override
  String get quizOpeningCleared => 'Opening time cleared.';

  @override
  String get quizClosingCleared => 'Closing time cleared.';

  @override
  String get quizNoOpeningTime => 'No opening time set';

  @override
  String get quizNoClosingTime => 'No closing time set';

  @override
  String quizOpensAt(String when) {
    return 'Opens $when';
  }

  @override
  String quizClosesAt(String when) {
    return 'Closes $when';
  }

  @override
  String quizPolicyChoice(String name, String position, String count) {
    return 'Feedback: $name, $position of $count.';
  }

  @override
  String quizScheduledRelease(String when) {
    return 'Scheduled feedback release $when';
  }

  @override
  String quizAttemptLimitField(String value) {
    return 'Attempt limit, currently $value. Press OK to edit';
  }

  @override
  String quizTimeLimitField(String value) {
    return 'Optional time limit in minutes, $value. Press OK to edit';
  }

  @override
  String get quizRevisionsScreen =>
      'Private read-only question revision history. Use older and newer revision controls, then read each section.';

  @override
  String get quizRevisionsAccount =>
      'Your account changed. Return and sign in again before viewing private question history.';

  @override
  String get quizRevisionsCleared =>
      'Your account changed. Private question history was cleared.';

  @override
  String get quizRevisionsUnverified =>
      'Question revision history could not be verified. Retry loading.';

  @override
  String get quizRevisionsContentUnverified =>
      'Question revision content could not be verified. Retry loading.';

  @override
  String get quizRevisionsTimedOut =>
      'Question history took too long. Check your connection and retry.';

  @override
  String get quizNoRevisions =>
      'No tracked revisions. Older question history is unknown, not reconstructed.';

  @override
  String quizRevisionsLoaded(int count, String revision, String when) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count revisions loaded. Read-only question revision $revision, saved $when. Existing quiz and attempt snapshots are not changed.',
      one:
          '1 revision loaded. Read-only question revision $revision, saved $when. Existing quiz and attempt snapshots are not changed.',
    );
    return '$_temp0';
  }

  @override
  String get quizDateUnknown => 'date unknown';

  @override
  String quizRevisionSelected(String revision) {
    return 'Revision $revision selected. Read-only.';
  }

  @override
  String quizRevisionSelectedOf(
    String revision,
    String position,
    String count,
  ) {
    return 'Revision $revision selected, $position of $count. Read-only.';
  }

  @override
  String quizRevisionFailed(String message) {
    return '$message Focus is on Refresh revisions.';
  }

  @override
  String get quizNoRevisionLoaded => 'No revision loaded.';

  @override
  String quizShowingRevision(String revision) {
    return 'Showing revision $revision. Read-only.';
  }

  @override
  String quizRevisionVersion(String revision, String when) {
    return 'Revision $revision. Saved $when. Read-only.';
  }

  @override
  String quizRevisionQuestion(String text) {
    return 'Question: $text';
  }

  @override
  String quizRevisionTopics(String topics) {
    return 'Topics: $topics';
  }

  @override
  String quizRevisionOption(String number, String text) {
    return 'Option $number: $text.';
  }

  @override
  String get quizCorrectAnswerSentence => 'Correct answer.';

  @override
  String quizRevisionExplanation(String text) {
    return 'Explanation: $text';
  }

  @override
  String get quizNotProvided => 'Not provided';

  @override
  String get quizRevisionNotice =>
      'Only revisions saved after tracking was introduced are available. Older history is unknown. Existing quiz and attempt snapshots are never rewritten.';

  @override
  String quizRevisionVersionTitle(String revision, String when) {
    return 'Revision $revision, $when';
  }

  @override
  String get quizQuestionTextTitle => 'Question text';

  @override
  String get quizTopicsTitle => 'Topics';

  @override
  String quizOptionNumber(String number) {
    return 'Option $number';
  }

  @override
  String quizOptionNumberCorrect(String number) {
    return 'Option $number, correct answer';
  }

  @override
  String get quizExplanationTitle => 'Explanation';

  @override
  String get quizRevisionNoticeTitle => 'About revision history';

  @override
  String quizRevisionSectionTarget(String title) {
    return '$title. Press OK to hear it';
  }

  @override
  String get quizAccountChangedSignIn =>
      'Account changed. Return and sign in again.';

  @override
  String get quizGoBack => 'Go back';

  @override
  String get quizCancel => 'Cancel';

  @override
  String get quizCancelAndReturn => 'Cancel and return';

  @override
  String get quizActionNavigation => 'the available actions and cancel';

  @override
  String get quizRefreshRevisions => 'Refresh revisions';

  @override
  String get quizNewerRevision => 'Newer revision';

  @override
  String get quizOlderRevision => 'Older revision';

  @override
  String get quizBankArchived => 'Bank question archived';

  @override
  String get quizBankCopied => 'Bank question copy created';

  @override
  String get quizSnapshotAdded => 'Question snapshot added to quiz';

  @override
  String get quizQuizClosed => 'Quiz closed';

  @override
  String get quizDraftCreated => 'Editable quiz draft created';

  @override
  String get quizNoAnswerSelected => 'No answer selected.';

  @override
  String get quizSelectBeforeSubmit => 'Select one option before submitting.';

  @override
  String get quizSubmitBeforeContinuing =>
      'Submit your answer before continuing.';

  @override
  String get quizTeacherNavigationPrivate =>
      'private bank search and saved questions, quiz drafts, published quizzes, and their results';

  @override
  String get quizStudentNavigationHelp =>
      'Use D-pad up and down to reach refresh, quiz state filter, subject filter, each available quiz or practice activity, and its attempt history. Use left or right on a filter to change it. Press OK on a quiz to hear its details and confirm starting or resuming; press OK on attempt history to review past attempts. Moving focus never starts an attempt.';

  @override
  String get quizNoQuizzesAvailable => 'No quizzes available.';

  @override
  String quizQuizzesAvailableRaw(String count) {
    return '$count quizzes available.';
  }

  @override
  String get quizStudentNavigationSections =>
      'refresh, quiz state and subject filters, available quizzes and practice activities, and previous attempts';

  @override
  String quizAttemptLimitReached(String title) {
    return 'Attempt limit reached for $title. Open attempt history to review your scores.';
  }

  @override
  String get quizNoPerAttemptLimit => 'No per-attempt time limit.';

  @override
  String quizTimeLimitRaw(String minutes) {
    return 'Time limit $minutes minutes.';
  }

  @override
  String get quizCannotGoBack => 'You cannot go back to change it.';

  @override
  String get quizStartFailedAvailability =>
      'The quiz could not be started. Check its availability.';

  @override
  String get quizStateFieldName => 'Quiz state';

  @override
  String get quizSubjectFieldName => 'Subject';

  @override
  String quizUseLeftRightToChange(String item) {
    return '$item. Use left or right to change';
  }

  @override
  String get quizAttemptCompletePrivate =>
      'Attempt complete. Your result remains private.';

  @override
  String get quizHelpCompleted =>
      'Use D-pad up and down to move between return to quizzes and read result privately. Press OK to activate a button. Press 8 to read your result privately or 0 to return.';

  @override
  String get quizHelpRetry =>
      'Press 5 to retry finishing, 8 to hear where you are, or 0 to leave with confirmation. Use D-pad up and down for the other controls.';

  @override
  String get quizHelpNext =>
      'The next question follows automatically. Press 6 to repeat, 8 to hear where you are.';

  @override
  String quizHelpChoose(String count) {
    return 'Press 1 to $count to choose, then 5 to submit. Press 6 to repeat the question and options, 8 to hear where you are and the time left.';
  }

  @override
  String get quizHelpFinishLeave =>
      'Finish quiz now is in the D-pad list and asks to confirm. Press 0 to leave without submitting.';

  @override
  String quizSelectedOptionNotSubmitted(String number, String text) {
    return 'Selected option $number. $text. Not submitted yet.';
  }

  @override
  String quizSelectedOptionConfirmed(String number, String text) {
    return 'Selected option $number. $text. Answer confirmed.';
  }

  @override
  String quizFeedbackCorrect(String answer, String explanation) {
    return 'Correct. Correct answer: $answer. $explanation';
  }

  @override
  String quizFeedbackIncorrect(String answer, String explanation) {
    return 'Incorrect. Correct answer: $answer. $explanation';
  }

  @override
  String quizOptionSelectedNotSubmitted(String number, String text) {
    return 'Option $number. $text. Selected, not submitted. Press 5 to save your answer.';
  }

  @override
  String get quizAttemptFinishedWhere =>
      'Attempt finished. Press 8 to hear your result privately.';

  @override
  String get quizNoOptionChosenYet => 'No option chosen yet.';

  @override
  String quizOptionChosen(String number) {
    return 'Option $number chosen.';
  }

  @override
  String quizCompletionFailedRetry(String reason) {
    return '$reason Your saved answers are preserved. Select Retry completion to check the result.';
  }

  @override
  String quizAttemptStatusPrivate(String status) {
    return 'Attempt $status. Your result is private.';
  }

  @override
  String get quizEarlyCountUnconfirmed =>
      'The current saved-answer count could not be confirmed, or this attempt has ended. No early submission was sent. Return to the quiz list to refresh its status.';

  @override
  String get quizEarlyTitle => 'Submit this attempt early?';

  @override
  String quizEarlyMessage(String count) {
    return 'The server check confirms $count unanswered questions. Only answers saved on the server when finalized are included. A selected but unsaved answer is not included. Final submission cannot be undone or edited. Back never submits.';
  }

  @override
  String get quizEarlyConfirm => 'Finalize saved answers';

  @override
  String get quizEarlyTimedOut =>
      'Checking saved answers timed out. No early submission was sent. Check your connection and retry.';

  @override
  String get quizWaitPending =>
      'Wait for the pending answer or completion confirmation before leaving.';

  @override
  String get quizLeaveMessageServer =>
      'This does not submit your attempt. Only server-confirmed answers are saved; an unsaved selection may be lost. Any timer keeps running. Resume is allowed only while the server permits this attempt.';

  @override
  String get quizStayInAttempt => 'Stay in attempt';

  @override
  String get quizNextQuestionNow => 'Next question now';

  @override
  String get quizReadAllOptions => 'Read all answer options';

  @override
  String quizOptionTargetSelectedSubmit(String number, String text) {
    return 'Option $number, $text, selected. Press OK or $number to select. Press 5 to submit only when ready';
  }

  @override
  String quizOptionTargetNotSelectedSubmit(String number, String text) {
    return 'Option $number, $text, not selected. Press OK or $number to select. Press 5 to submit only when ready';
  }

  @override
  String get quizReadSelectionTarget => 'Read selected answer and saved status';

  @override
  String get quizStopSpeech => 'Stop speech';

  @override
  String get quizAnswerFeedback => 'Answer feedback';

  @override
  String get quizAnswerConfirmedReadFeedback =>
      'Answer confirmed saved and locked. Press OK to read feedback privately.';

  @override
  String get quizRetryCompletion => 'Retry completion';

  @override
  String get quizViewResult => 'View result';

  @override
  String get quizNextQuestion => 'Next question';

  @override
  String get quizAttemptInProgressResume =>
      'Attempt in progress. Return to the quiz list to resume it. Leaving does not submit.';

  @override
  String get quizReviewTimedOutShort =>
      'Attempt review timed out. Check your connection and try again.';

  @override
  String get quizNoScoreCurrentlyReleased =>
      'Completed attempts exist; no score is currently released.';

  @override
  String get quizHistoryScreenNavigate =>
      'Attempt history. Scores are private. Navigate to the summary or an attempt to review.';

  @override
  String quizHistoryAttemptRaw(String number, String status, String result) {
    return 'Attempt $number. $status. $result. Press OK to review.';
  }

  @override
  String quizReviewAnswerCorrect(
    String number,
    String question,
    String selected,
    String answer,
    String explanation,
  ) {
    return 'Question $number. Correct. $question. Selected $selected. Correct answer $answer. $explanation';
  }

  @override
  String quizReviewAnswerIncorrect(
    String number,
    String question,
    String selected,
    String answer,
    String explanation,
  ) {
    return 'Question $number. Incorrect. $question. Selected $selected. Correct answer $answer. $explanation';
  }

  @override
  String get quizNoAnswerCapital => 'No answer';

  @override
  String quizReviewScreenRaw(String count) {
    return 'Attempt review. $count questions. Use up and down to review each answer.';
  }

  @override
  String get quizMetaTopics => 'Topics or concepts, one per line (optional)';

  @override
  String get quizMetaSpokenQuestion => 'Teacher-written spoken question';

  @override
  String quizMetaSpokenOption(String number) {
    return 'Spoken option $number';
  }

  @override
  String get quizMetaSpokenExplanation => 'Teacher-written spoken explanation';

  @override
  String quizCorrectSelected(String number) {
    return 'Option $number selected as correct answer';
  }

  @override
  String quizCorrectSelectedWithText(String number, String text) {
    return 'Option $number selected as correct answer, $text';
  }

  @override
  String get quizEditBankQuestion => 'Edit bank question';

  @override
  String get quizCreateBankQuestion => 'Create bank question';

  @override
  String get quizEditorNavigation =>
      'question text, four answer fields, correct-answer selection, optional spoken descriptions, and save or cancel';

  @override
  String get quizSaveQuestion => 'Save question';

  @override
  String get quizCancelQuestion => 'Cancel question';

  @override
  String quizPressOkToEdit(String item) {
    return '$item. Press OK to edit';
  }

  @override
  String quizPressOkToChange(String item) {
    return '$item. Press OK to change';
  }

  @override
  String quizCorrectIsOption(String number, String text) {
    return 'Option $number, $text, is the correct answer. Use left or right to change';
  }

  @override
  String get quizHideOptionalExplanation =>
      'Hide optional explanation, topics and spoken notation';

  @override
  String get quizShowOptionalExplanation =>
      'Show optional explanation, topics and spoken notation';

  @override
  String get quizOptionalExplanation => 'Optional answer explanation';

  @override
  String quizNumericDateTime(
    String day,
    String month,
    String year,
    String hour,
    String minute,
  ) {
    return '$day/$month/$year at $hour:$minute';
  }

  @override
  String get quizCheckTitleLimits => 'Check the title, limits, and schedule.';

  @override
  String get quizSettingsNavigation =>
      'title, optional description, timing and attempt settings, feedback and shuffle choices, and continue or cancel';

  @override
  String get quizChangeSettingsScreen =>
      'Change quiz title and optional settings. Saving does not publish.';

  @override
  String get quizCreatePracticeScreen =>
      'Create untimed ungraded practice. Unlimited retries and immediate feedback.';

  @override
  String get quizContinueToQuestions => 'Continue to questions';

  @override
  String get quizSaveSettingsReturn => 'Save settings and return to review';

  @override
  String get quizQuizTitle => 'Quiz title';

  @override
  String get quizHideOptionalSettings =>
      'Hide optional settings: description, attempts, timing, feedback and shuffle';

  @override
  String get quizShowOptionalSettings =>
      'Show optional settings: description, attempts, timing, feedback and shuffle';

  @override
  String get quizOptionalDescription => 'Optional quiz description';

  @override
  String quizSetOrClear(String item) {
    return '$item. Press OK to set it. Use left to clear it';
  }

  @override
  String quizShuffleQuestionsToggle(String state) {
    return 'Shuffle questions $state. Press OK or left or right to toggle';
  }

  @override
  String quizShuffleOptionsToggle(String state) {
    return 'Shuffle answer options $state. Press OK or left or right to toggle';
  }

  @override
  String get quizCancelQuizCreation => 'Cancel quiz creation';

  @override
  String quizFeedbackPolicyTarget(String policy) {
    return 'Feedback policy $policy. Left or right changes it';
  }

  @override
  String get quizSaveDraftContinue => 'Save draft and continue to questions';

  @override
  String get sessionScreenTeacherClass => 'Teacher class';

  @override
  String get sessionScreenClass => 'Class';

  @override
  String get sessionDefaultTitle => 'Session';

  @override
  String get sessionJoining => 'Joining the class. Please wait.';

  @override
  String get sessionConnecting => 'Connecting to the class.';

  @override
  String get sessionJoinFailed =>
      'The class could not be joined. Press 0 to leave, then try again.';

  @override
  String get sessionLeaveKeyHint =>
      'Press 0 to leave the class. It asks to confirm.';

  @override
  String get sessionKeyLine => '*: Help and last message. #: Stop speech.';

  @override
  String sessionJoinedBrief(String status) {
    return 'In class. $status Press star for help.';
  }

  @override
  String sessionJoinedDetailed(String status, String keys) {
    return 'You are in the class. $status $keys Use up and down to move between controls and OK to select. Press star for where you are and help. Press hash to stop speech.';
  }

  @override
  String sessionPressKeyFor(String key, String action) {
    return 'Press $key for $action.';
  }

  @override
  String get sessionMicWaitingLabel => 'Microphone waiting for confirmation';

  @override
  String get sessionUnmuteMicrophone => 'Unmute microphone';

  @override
  String get sessionMuteMicrophone => 'Mute microphone';

  @override
  String get sessionMuteButtonWaiting => '1: Waiting';

  @override
  String get sessionMuteButtonUnmute => '1: Unmute';

  @override
  String get sessionMuteButtonMute => '1: Mute';

  @override
  String get sessionHandWaitingLabel => 'Hand waiting for confirmation';

  @override
  String get sessionLowerHand => 'Lower hand';

  @override
  String get sessionRaiseHand => 'Raise hand';

  @override
  String get sessionHandButtonWaiting => '2: Waiting';

  @override
  String get sessionHandButtonLower => '2: Lower hand';

  @override
  String get sessionHandButtonRaise => '2: Raise hand';

  @override
  String get sessionStatusLabel => 'Hear class status';

  @override
  String get sessionStatusButton => '3: Class status';

  @override
  String sessionChatLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Chat. $count messages',
      one: 'Chat. 1 message',
      zero: 'Chat. No messages yet',
    );
    return '$_temp0';
  }

  @override
  String get sessionChatButton => '4: Chat';

  @override
  String get sessionRecordingPlayerNone => 'Lesson recording. None chosen yet';

  @override
  String sessionRecordingPlayerPlaying(String title) {
    return 'Lesson recording. $title, playing';
  }

  @override
  String sessionRecordingPlayerPaused(String title) {
    return 'Lesson recording. $title, paused';
  }

  @override
  String get sessionRecordingStudentNone =>
      'Class recording. Nothing playing. Only the teacher controls it';

  @override
  String sessionRecordingStudentPlaying(String title) {
    return 'Class recording, $title, playing by the teacher. Hear where it is';
  }

  @override
  String sessionRecordingStudentPaused(String title) {
    return 'Class recording, $title, paused by the teacher. Hear where it is';
  }

  @override
  String get sessionRecordingStatusButton => '5: Recording status';

  @override
  String get sessionStudentRecordingNone =>
      'No class recording is playing. Only the teacher can play one.';

  @override
  String sessionStudentRecordingPlaying(String title, String position) {
    return '$title, playing, at $position. Only the teacher can play, pause or move the class recording.';
  }

  @override
  String sessionStudentRecordingPaused(String title, String position) {
    return '$title, paused, at $position. Only the teacher can play, pause or move the class recording.';
  }

  @override
  String get sessionRecordingPlayerButton => '5: Lesson recording';

  @override
  String get sessionOpeningPlayerToChoose =>
      'No recording is selected yet. Press 1 to choose one.';

  @override
  String get sessionCheckLabel => 'Answer the teacher\'s question';

  @override
  String get sessionCheckButton => '3: Answer the question';

  @override
  String sessionHandsLabel(String waiting) {
    return 'Raised hands. $waiting';
  }

  @override
  String get sessionHandsButton => '2: Raised hands';

  @override
  String sessionHandsButtonCount(int count) {
    return '2: Raised hands ($count)';
  }

  @override
  String get sessionTeacherCheckLabel =>
      'Classroom check. Start a private check, close it and hear responses';

  @override
  String sessionParticipantsLabel(String people) {
    return 'Participants. $people Mute or remove someone, or hear a summary';
  }

  @override
  String get sessionParticipantsButton => '7: Participants';

  @override
  String get sessionToolsLabel =>
      'Teacher tools. Add time or end the class for everyone';

  @override
  String get sessionToolsButton => '9: Teacher tools';

  @override
  String get sessionVoiceStartLabel =>
      'Listen for one voice command, up to 12 seconds. Starts only when you press OK';

  @override
  String get sessionVoiceStopLabel => 'Stop listening for a voice command';

  @override
  String get sessionVoiceStartButton => 'Listen for command';

  @override
  String get sessionVoiceStopButton => 'Stop listening';

  @override
  String get sessionUpdatesLabel => 'Read class updates';

  @override
  String get sessionUpdatesButton => 'Class updates';

  @override
  String get sessionRetryLabel => 'Retry class connection';

  @override
  String get sessionRetryButton => 'Retry connection';

  @override
  String get sessionLeaveLabel => 'Leave class';

  @override
  String get sessionLeaveButton => '0: Leave class';

  @override
  String get sessionMicWaiting => 'Microphone waiting for confirmation.';

  @override
  String get sessionMicMuted => 'Muted.';

  @override
  String get sessionMicUnmutedHeard => 'Unmuted. Others can hear you.';

  @override
  String get sessionHandWaiting => 'Hand waiting for confirmation.';

  @override
  String get sessionHandRaisedState => 'Hand raised.';

  @override
  String get sessionHandDown => 'Hand down.';

  @override
  String sessionHandsWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hands waiting.',
      one: '1 hand waiting.',
      zero: 'No hands waiting.',
    );
    return '$_temp0';
  }

  @override
  String sessionPeople(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count people in the class.',
      one: '1 person in the class.',
    );
    return '$_temp0';
  }

  @override
  String get sessionNoRecordingSelected => 'No recording selected.';

  @override
  String sessionRecordingStatePlaying(String title) {
    return 'Recording playing: $title.';
  }

  @override
  String sessionRecordingStatePaused(String title) {
    return 'Recording paused: $title.';
  }

  @override
  String get sessionCheckOpen => 'Classroom check open.';

  @override
  String sessionConnectionLabel(String label) {
    return '$label.';
  }

  @override
  String sessionChatMessages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count chat messages.',
      one: '1 chat message.',
    );
    return '$_temp0';
  }

  @override
  String get sessionRecordingFallback => 'Class recording';

  @override
  String get sessionRecordingFallbackLower => 'class recording';

  @override
  String sessionUserFallback(String id) {
    return 'User $id';
  }

  @override
  String sessionConnectionRestored(String message) {
    return 'Connection restored. $message';
  }

  @override
  String sessionConnectionLost(String message) {
    return 'Connection lost. $message';
  }

  @override
  String sessionCouldNotConnect(String message) {
    return 'Could not connect. $message';
  }

  @override
  String get sessionMicDialogTitle => 'Microphone access';

  @override
  String get sessionMicDialogMessage =>
      'In this class SEEDS uses the microphone for live audio and explicitly activated voice commands. You can stay without microphone access, but others will not hear you. Separate private-note recording requires its own explicit start outside live classes.';

  @override
  String get sessionMicDialogConfirm => 'Continue to class';

  @override
  String get sessionMicSkipped =>
      'Microphone access was skipped. You joined the class muted.';

  @override
  String get sessionMicUnavailable =>
      'Microphone access is unavailable. You joined the class muted.';

  @override
  String get sessionWaitingMic => 'Waiting for microphone confirmation.';

  @override
  String get sessionMuted => 'Muted';

  @override
  String get sessionUnmuted => 'Unmuted';

  @override
  String get sessionMutedLocallyOnly =>
      'Microphone muted on this phone. The class confirmation was not received.';

  @override
  String get sessionMutedByTeacher => 'The teacher muted your microphone.';

  @override
  String get sessionMicClassClosed =>
      'The class has closed. No microphone action was sent.';

  @override
  String get sessionMicUnavailableRejoin =>
      'Microphone access is unavailable. Check microphone permission and rejoin the class before trying to speak.';

  @override
  String get sessionMicClosedBeforeConfirm =>
      'The class closed before microphone confirmation.';

  @override
  String get sessionMicNoLongerAvailable =>
      'Microphone access is no longer available. Rejoin the class before trying to speak.';

  @override
  String get sessionMicStayedMuted =>
      'Your microphone stayed muted because the class mute state changed. Select Unmute when you are ready to speak.';

  @override
  String get sessionWaitingHand => 'Waiting for hand status confirmation.';

  @override
  String get sessionHandRaised => 'Hand raised';

  @override
  String get sessionHandLowered => 'Hand lowered';

  @override
  String get sessionHandNotConfirmed =>
      'Your hand change was not confirmed. Press 2 to try again.';

  @override
  String sessionRaisedHandBy(String name) {
    return '$name raised hand. Press 2 for raised hands.';
  }

  @override
  String get sessionRaisedHandUnknown =>
      'A participant raised hand. Press 2 for raised hands.';

  @override
  String get sessionParticipantJoined => 'A participant joined.';

  @override
  String get sessionParticipantsJoinedGroup => 'Participants joined';

  @override
  String get sessionParticipantLeft => 'A participant left.';

  @override
  String get sessionParticipantsLeftGroup => 'Participants left';

  @override
  String get sessionParticipantFallback => 'Participant';

  @override
  String get sessionThisParticipant => 'This participant';

  @override
  String sessionParticipantSelf(String name) {
    return '$name, you';
  }

  @override
  String get sessionRoleTeacher => 'teacher';

  @override
  String get sessionRoleStudent => 'student';

  @override
  String get sessionStateHandRaised => 'hand raised';

  @override
  String get sessionStateMuted => 'muted';

  @override
  String get sessionStateUnmuted => 'unmuted';

  @override
  String get sessionStateSpeaking => 'speaking';

  @override
  String sessionAlreadyMuted(String name) {
    return '$name is muted. Only $name can unmute.';
  }

  @override
  String sessionParticipantMuted(String name) {
    return '$name muted.';
  }

  @override
  String sessionRemoveTitle(String name) {
    return 'Remove $name?';
  }

  @override
  String sessionRemoveMessage(String name) {
    return '$name will be removed from this class and returned to their dashboard. They can be invited again later.';
  }

  @override
  String sessionKeep(String name) {
    return 'Keep $name';
  }

  @override
  String sessionRemove(String name) {
    return 'Remove $name';
  }

  @override
  String sessionRemoved(String name) {
    return '$name removed from the class.';
  }

  @override
  String chatMessageFrom(String sender, String text) {
    return 'Message from $sender: $text';
  }

  @override
  String get chatSenderUnknown => 'Unknown';

  @override
  String get chatSenderUnknownLower => 'unknown';

  @override
  String get chatWaitingConfirmation => 'Waiting for message confirmation.';

  @override
  String get chatEmptyMessage => 'Enter a message before selecting Send.';

  @override
  String get chatMessageSent => 'Message sent.';

  @override
  String get chatSending => 'Sending';

  @override
  String get chatSent => 'Sent';

  @override
  String get chatNotConfirmed => 'Not confirmed';

  @override
  String get chatNoMessages => 'No messages yet.';

  @override
  String get chatTitle => 'Chat';

  @override
  String get chatReadMessages => 'Read messages, newest first';

  @override
  String get chatWriteMessage => 'Write a message';

  @override
  String get chatMessageField => 'Your message to the class';

  @override
  String get chatMessagesTitle => 'Chat messages';

  @override
  String get chatPhraseUnderstood => 'I understood';

  @override
  String get chatPhraseRepeat => 'Please repeat';

  @override
  String get chatPhraseQuestion => 'I have a question';

  @override
  String chatSendPhrase(String phrase) {
    return 'Send: $phrase';
  }

  @override
  String chatCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count messages.',
      one: '1 message.',
    );
    return '$_temp0';
  }

  @override
  String get chatHelpBrief => 'Read, write or send a quick phrase.';

  @override
  String get chatHelpDetailed =>
      'Press 1 to read messages, 2 to write one, or 3 to 5 to send a quick phrase. Press 8 to hear the newest message.';

  @override
  String get chatYou => 'You';

  @override
  String chatMessageLine(String sender, String text) {
    return '$sender: $text';
  }

  @override
  String chatMessageLineDelivery(String sender, String text, String delivery) {
    return '$sender: $text. $delivery';
  }

  @override
  String chatMessageDetail(String line) {
    return '$line.';
  }

  @override
  String chatMessageDetailSent(String line, String time) {
    return '$line. Sent $time.';
  }

  @override
  String chatNewestMessage(String detail) {
    return 'Newest message. $detail';
  }

  @override
  String get chatReadLatest => 'Read latest message';

  @override
  String get chatMessageLabel => 'Chat message';

  @override
  String get chatSendMessage => 'Send message';

  @override
  String chatSaid(String sender, String text) {
    return '$sender said: $text';
  }

  @override
  String chatSaidDelivery(String sender, String text, String delivery) {
    return '$sender said: $text. $delivery';
  }

  @override
  String chatLatestLineDelivery(String sender, String text, String delivery) {
    return '$sender: $text\nDelivery status: $delivery.';
  }

  @override
  String get sessionLeaveTitle => 'Leave class?';

  @override
  String get sessionLeaveMessage =>
      'You will leave this class and return to your dashboard. You will remain logged in.';

  @override
  String get sessionTeacherLeaveMessage =>
      'You will leave and return to your dashboard. The class keeps running for students. To end it for everyone, use 9, Teacher tools.';

  @override
  String get sessionStay => 'Stay in class';

  @override
  String get sessionLeave => 'Leave class';

  @override
  String get sessionLeaveLocallyTitle => 'Leave without server confirmation?';

  @override
  String get sessionLeaveLocallyMessage =>
      'This phone is muted. The server did not confirm clearing your raised hand. Leave locally now, or stay and retry? A fresh join resets your hand.';

  @override
  String get sessionStayAndRetry => 'Stay and retry';

  @override
  String get sessionLeaveLocally => 'Leave locally';

  @override
  String get sessionEndTitle => 'End class for everyone?';

  @override
  String get sessionEndMessage =>
      'This stops the class for every participant and returns everyone to their dashboard. Nobody will be logged out.';

  @override
  String get sessionEndCancel => 'Keep the class going';

  @override
  String get sessionEndConfirm => 'End for everyone';

  @override
  String get sessionWaitingEnd => 'Waiting for end-class confirmation.';

  @override
  String get sessionEndNotConfirmed =>
      'Ending the class was not confirmed. The class is still running.';

  @override
  String get sessionEndingForEveryone => 'Ending the class for everyone.';

  @override
  String get sessionYouLeft => 'You left the class.';

  @override
  String get sessionClassEnded => 'The class has ended.';

  @override
  String get sessionYouWereRemoved => 'You were removed from the class.';

  @override
  String get sessionSignInChanged =>
      'Your sign-in changed. Sign in again or contact your school administrator.';

  @override
  String get sessionCleanupFailed =>
      'Sign-in ended. Native audio cleanup could not be confirmed. Close SEEDS if audio continues.';

  @override
  String get sessionCleanupTimedOut =>
      'Sign-in ended. Audio cleanup timed out. Close SEEDS if audio continues.';

  @override
  String get sessionRequestFailed =>
      'We could not complete that request. Please try again.';

  @override
  String get sessionVoiceStopped => 'Voice listening stopped.';

  @override
  String get sessionVoiceUnmuteTitle => 'Unmute your microphone?';

  @override
  String get sessionVoiceUnmuteMessage =>
      'A voice command requested unmute. Confirm with a key or touch. Other class members will be able to hear you.';

  @override
  String get sessionVoiceUnmuteConfirm => 'Unmute';

  @override
  String get sessionVoiceUnmuteCancel => 'Stay muted';

  @override
  String get sessionAlreadyUnmuted => 'Already unmuted';

  @override
  String get sessionAlreadyMutedSelf => 'Already muted';

  @override
  String get sessionHandAlreadyLowered => 'Hand is already lowered';

  @override
  String get sessionHandAlreadyRaised => 'Hand is already raised';

  @override
  String get sessionCommandNotRecognized => 'Command not recognized';

  @override
  String get sessionVoiceStopUnconfirmed =>
      'Voice listening stop not confirmed. Retry stopping.';

  @override
  String get sessionVoiceStopping => 'Stopping voice listening.';

  @override
  String get sessionVoiceStarting => 'Starting voice commands.';

  @override
  String get sessionVoiceFinishing => 'Finishing voice recognition.';

  @override
  String get sessionVoiceListening =>
      'Listening for one command, up to 12 seconds.';

  @override
  String get sessionVoiceIdle =>
      'Not listening. Activate Listen for command to start.';

  @override
  String get sessionVoiceSpeechNotStopped =>
      'App speech could not be stopped. Try Stop speech before listening.';

  @override
  String get sessionVoiceUnavailable =>
      'Voice commands are unavailable. Check microphone permission and Android English speech services.';

  @override
  String get sessionVoiceCouldNotStart =>
      'Voice commands could not start. Check microphone permission and English speech services, then try again.';

  @override
  String get sessionVoiceCouldNotFinish =>
      'Voice recognition could not finish. Check permission and English speech services, then activate Listen to retry.';

  @override
  String get sessionVoiceNoCommand =>
      'No command heard. Activate Listen for command to try again.';

  @override
  String get sessionVoiceCommandFailed =>
      'The voice command could not be completed. Use its keypad control or try again.';

  @override
  String get sessionVoiceCannotStop =>
      'Voice listening could not be stopped. Retry Stop listening or leave the class and check the Android microphone indicator.';

  @override
  String get sessionRecordingSelectionChanged =>
      'The class recording selection changed. Use Read class updates for details.';

  @override
  String get sessionRecordingSelectionGroup => 'Class recording selection';

  @override
  String get sessionPlaybackFinished => 'Recording finished.';

  @override
  String get sessionNoRecording => 'No class recording is selected.';

  @override
  String get sessionNoRecordingTeacher =>
      'No class recording is selected. In the recording player, press 1 to choose one.';

  @override
  String get sessionPreviewFailed =>
      'The private preview could not start. Check the connection and try again.';

  @override
  String sessionClassPauseUnconfirmed(String reason) {
    return 'Your local audio is paused. The class pause was not confirmed. $reason';
  }

  @override
  String sessionSpeed(String speed) {
    return '$speed times speed';
  }

  @override
  String sessionPlaybackAccepted(String title) {
    return 'Class playback request accepted for $title.';
  }

  @override
  String sessionSelected(String title) {
    return '$title selected for the class. Press 5 to play it.';
  }

  @override
  String sessionPreviewing(String title) {
    return 'Previewing $title on this phone only.';
  }

  @override
  String get sessionPreviewStopped => 'Preview stopped.';

  @override
  String get sessionRecordingsTitle => 'Class recording player';

  @override
  String get sessionChooseRecording => 'Choose a recording from the library';

  @override
  String get sessionUploadRecording => 'Upload a new recording';

  @override
  String get sessionHearRecording => 'Hear recording status';

  @override
  String get sessionPlayPauseClass => 'Play or pause for the class';

  @override
  String get sessionLibraryLoading =>
      'The recording library is still loading. Try again shortly.';

  @override
  String get sessionLibraryEmpty =>
      'No recordings for this class yet. Press 2 to upload one.';

  @override
  String get sessionPositionHint => 'Use left and right to move 10 seconds';

  @override
  String sessionRecordingStatusPlaying(
    String title,
    String position,
    String speed,
  ) {
    return '$title. Playing for the class. $position. $speed.';
  }

  @override
  String sessionRecordingStatusPaused(
    String title,
    String position,
    String speed,
  ) {
    return '$title. Paused. $position. $speed.';
  }

  @override
  String sessionPositionLabel(String position) {
    return 'Position $position. Use left and right to move 10 seconds';
  }

  @override
  String get sessionUntitled => 'Untitled';

  @override
  String get sessionFileSelectedForClass => 'selected for the class';

  @override
  String get sessionFilePreviewing => 'previewing';

  @override
  String get sessionPlayForClass => 'Select and play for the class now';

  @override
  String get sessionSelectOnly => 'Select only, play later with 5';

  @override
  String get sessionPreviewPrivately => 'Preview privately on this phone';

  @override
  String get sessionStopPreview => 'Stop the private preview';

  @override
  String get sessionUploadDetailsTitle => 'Upload audio details';

  @override
  String get sessionUploadTitle => 'Upload Audio';

  @override
  String sessionUploadFile(String name) {
    return 'File: $name';
  }

  @override
  String get sessionTitleField => 'Audio title, required';

  @override
  String get sessionDescriptionField => 'Audio description, optional';

  @override
  String get sessionCancelUpload => 'Cancel upload';

  @override
  String get sessionConfirmUpload => 'Upload audio';

  @override
  String get sessionTitleRequired => 'Title is required';

  @override
  String get sessionChooseSessionsTitle => 'Choose classes for this audio';

  @override
  String get sessionAddToSessions => 'Add audio to classes';

  @override
  String get sessionConfirmSessions => 'Confirm selected classes';

  @override
  String get sessionSelectAtLeastOne => 'Select at least one class';

  @override
  String get sessionSessionSelected => 'Class selected';

  @override
  String get sessionSessionUnselected => 'Class unselected';

  @override
  String sessionChoiceSelected(String title) {
    return 'Selected, $title';
  }

  @override
  String sessionChoiceNotSelected(String title) {
    return 'Not selected, $title';
  }

  @override
  String sessionClassNumbered(String number) {
    return 'Class $number';
  }

  @override
  String get sessionUploadContextMissing =>
      'The class and subject of this class could not be determined.';

  @override
  String get sessionUploadSuccess => 'Upload successful.';

  @override
  String get sessionUploadInProgress => 'Audio upload in progress';

  @override
  String get sessionPlayNowTitle => 'Play for everyone now?';

  @override
  String sessionPlayNowMessage(String title) {
    return '$title is selected. Play it for all participants now?';
  }

  @override
  String get sessionPlayNow => 'Play now';

  @override
  String get sessionNotYet => 'Not yet';

  @override
  String get sessionUploadEditTitle => 'Edit Title';

  @override
  String get sessionUploadEditDescription => 'Edit Description';

  @override
  String get sessionUploadKey => 'Upload';

  @override
  String get sessionCancel => 'Cancel';

  @override
  String get classroomCheckUnreadable =>
      'Classroom check state could not be read. Refresh before responding.';

  @override
  String get classroomCheckUnconfirmed =>
      'The classroom check action was not confirmed. Refresh before trying again.';

  @override
  String get classroomCheckConfirmationUnreadable =>
      'The classroom check confirmation was unreadable. Refresh before trying again.';

  @override
  String get classroomCheckOpenedForYou =>
      'Your teacher asked a question. Press 3 to answer.';

  @override
  String get classroomCheckHelp =>
      'Private classroom check. Understood, Please repeat or Need help. Only the responding student and session teacher can read a response. It is not graded. Responses clear on the next check, session end or server restart. Use Read or Refresh for confirmed state. Stop speech and Back are available.';

  @override
  String get classroomCheckTitle => 'Classroom check';

  @override
  String get classroomCheckNewTitle => 'Open a new classroom check?';

  @override
  String get classroomCheckNewMessage =>
      'This clears all responses from the previous check. Students choose Understood, Please repeat or Need help. Only you and each responding student can read their response. It is not graded or retained as an academic record.';

  @override
  String get classroomCheckNewConfirm => 'Clear previous and open';

  @override
  String get classroomCheckNewCancel => 'Keep current check';

  @override
  String get classroomCheckSending => 'Sending. Waiting for confirmation.';

  @override
  String get classroomCheckWaiting =>
      'Waiting for confirmation. Do not resend.';

  @override
  String get sessionBackToClass => 'Back to class';

  @override
  String get classroomBackToSession => 'Back to session';

  @override
  String get classroomBack => 'Back';

  @override
  String get classroomCheckRead => 'Read check status and confirmed responses';

  @override
  String get classroomCheckReadButton => 'Read status and responses';

  @override
  String get classroomCheckRefresh =>
      'Refresh private check state. Requires class connection';

  @override
  String get classroomCheckRefreshButton => 'Refresh from server';

  @override
  String get classroomCheckOpenLabel =>
      'Open a new check. Confirm clearing previous responses';

  @override
  String get classroomCheckOpenButton => 'Open new check';

  @override
  String get classroomCheckCloseLabel =>
      'Close this check. Keep current results until next check or session end';

  @override
  String get classroomCheckCloseButton => 'Close check';

  @override
  String classroomCheckAnswer(String choice) {
    return '$choice. Send or change your private, ungraded response';
  }

  @override
  String get sessionStopSpeech => 'Stop speech';

  @override
  String get classroomChoiceUnderstood => 'Understood';

  @override
  String get classroomChoiceRepeat => 'Please repeat';

  @override
  String get classroomChoiceHelp => 'Need help';

  @override
  String get classroomCheckNone =>
      'No current check in the last received classroom state. Refresh to check.';

  @override
  String get classroomCheckStatusOpen => 'Check open.';

  @override
  String get classroomCheckStatusClosed =>
      'Check closed. Responses cannot be changed.';

  @override
  String get classroomCheckNoResponseYet => 'No response confirmed yet.';

  @override
  String classroomCheckYourResponse(String choice) {
    return 'Your confirmed response: $choice.';
  }

  @override
  String classroomCheckStudentSummary(String status, String response) {
    return '$status $response Only you and the session teacher can read your response. This is not graded.';
  }

  @override
  String classroomCheckLabelValue(String label, String value) {
    return '$label: $value';
  }

  @override
  String get classroomCheckNoResponses => 'No responses yet.';

  @override
  String classroomCheckTeacherSummary(
    int count,
    String status,
    String counts,
    String named,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$status $count students responded. $counts. $named Responses are private to you and each responding student, and are not grades.',
    );
    return '$_temp0';
  }

  @override
  String get classroomOnlyTeacherAcknowledges =>
      'Only the session teacher may acknowledge a hand.';

  @override
  String get classroomHandChanged =>
      'The selected hand changed. Read the queue again.';

  @override
  String get classroomAckUnconfirmed =>
      'The hand acknowledgment was not confirmed. Read the queue before retrying.';

  @override
  String get classroomAckUnreadable =>
      'Hand acknowledgment was not readable. Check the queue before trying again.';

  @override
  String classroomAcknowledgedChanged(String name) {
    return '$name acknowledged earlier. Their hand has since changed; read the queue again. Their microphone was not changed.';
  }

  @override
  String classroomAcknowledged(String name) {
    return '$name acknowledged. The selected hand was lowered. Their microphone was not changed.';
  }

  @override
  String get classroomHandsHelp =>
      'Raised hands. Read summary for the last received classroom state. Previous and Next select a raised hand without changing it. Acknowledge lowers only the selected hand after server confirmation. It never unmutes anyone. Older hands with unknown order are labelled separately.';

  @override
  String get classroomConsoleHelp =>
      'Classroom console. Read summary for the last received classroom state. Previous and Next select a raised hand without changing it. Acknowledge lowers only the selected hand after server confirmation. It never unmutes anyone. Older hands with unknown order are labelled separately.';

  @override
  String get classroomHandsTitle => 'Raised hands';

  @override
  String get classroomNoHands =>
      'No raised hands in the last received classroom state.';

  @override
  String classroomSelectedGone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'The selected hand is no longer in the queue. $count raised hands remain. Use Next or Previous to select a hand.',
      one:
          'The selected hand is no longer in the queue. 1 raised hand remain. Use Next or Previous to select a hand.',
    );
    return '$_temp0';
  }

  @override
  String classroomConsoleSelectedGone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'The selected hand is no longer in the queue. $count raised hands remain. Use Next or Previous to select a hand.',
    );
    return '$_temp0';
  }

  @override
  String classroomHandTitle(String position, String total, String name) {
    return 'Hand $position of $total, $name, waiting';
  }

  @override
  String classroomParticipantNumbered(String id) {
    return 'Participant $id';
  }

  @override
  String get classroomKnownOrder => 'Server-recorded queue order.';

  @override
  String get classroomUnknownOrder =>
      'Original raise order unknown; shown before known-order hands.';

  @override
  String get classroomReportedMuted => 'Microphone reported muted.';

  @override
  String get classroomReportedUnmuted =>
      'Microphone reported unmuted; this is not proof of speech.';

  @override
  String get classroomNoHandsShort => 'No raised hands';

  @override
  String get classroomNoHandSelected => 'No hand selected';

  @override
  String classroomLowering(String name) {
    return 'Lowering hand for $name. Waiting for the server.';
  }

  @override
  String classroomLoweredLast(String name) {
    return 'Hand lowered for $name. The hand queue is now empty.';
  }

  @override
  String classroomLoweredNext(String name, String next) {
    return 'Hand lowered for $name. Next: $next.';
  }

  @override
  String get classroomNoSummary => 'No classroom summary is available yet.';

  @override
  String get classroomReadSummary => 'Read classroom summary';

  @override
  String get classroomPreviousHand => 'Previous raised hand';

  @override
  String get classroomReadHand => 'Read selected hand';

  @override
  String classroomReadHandLabel(String hand) {
    return 'Read selected hand. $hand';
  }

  @override
  String get classroomNextHand => 'Next raised hand';

  @override
  String get classroomWaitingAck => 'Waiting for hand acknowledgment';

  @override
  String get classroomAckNoneSelected =>
      'Acknowledge and lower selected hand. No hand selected';

  @override
  String classroomAckLabel(String name) {
    return 'Lower $name. Never unmutes';
  }

  @override
  String get classroomAckSelectedLabel => 'Lower selected hand. Never unmutes';

  @override
  String get classroomAckButton => 'Acknowledge and lower hand';

  @override
  String get classroomRepeatConsoleHelp => 'Repeat console help';

  @override
  String get classroomConsoleSections =>
      'read classroom summary, previous hand, read selected hand, next hand, acknowledge hand, stop speech, help and back. If no hands or summary are available, selecting their controls reads that status';

  @override
  String get classroomSnapshotNote =>
      'Counts reflect the last received snapshot, not guaranteed audio delivery. Active speaker identification is unavailable.';

  @override
  String get classroomWaitingAckNote =>
      'Waiting for server acknowledgment. No microphone is changed.';

  @override
  String classroomSummaryParticipants(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count participants',
      one: '1 participant',
    );
    return '$_temp0';
  }

  @override
  String classroomSummaryHands(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count raised hands',
      one: '1 raised hand',
    );
    return '$_temp0';
  }

  @override
  String classroomSummaryMicrophones(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count microphones',
      one: '1 microphone',
    );
    return '$_temp0';
  }

  @override
  String get classroomSummaryNobodySpeaking => 'Nobody detected speaking.';

  @override
  String classroomSummarySpeaking(String names) {
    return 'Detected speaking: $names.';
  }

  @override
  String get classroomSummaryNoRecording => 'No class recording selected.';

  @override
  String classroomSummaryRecordingPlaying(String title) {
    return 'Class recording $title. Playing requested.';
  }

  @override
  String classroomSummaryRecordingPaused(String title) {
    return 'Class recording $title. Paused.';
  }

  @override
  String get classroomSummaryPreviewActive =>
      'Private preview active on this phone only.';

  @override
  String get classroomSummaryPreviewStopped => 'Private preview stopped.';

  @override
  String classroomSummary(
    String connection,
    String people,
    String hands,
    String muted,
    String speaking,
    String recording,
    String preview,
  ) {
    return 'Local connection: $connection. Last received classroom state: $people, $hands, $muted reported muted. Remote reconnecting counts are unavailable. $speaking $recording $preview Microphone flags and accepted playback requests do not prove that anyone spoke or heard audio.';
  }

  @override
  String get sessionToolsTitle => 'Teacher tools';

  @override
  String get sessionInvite => 'Invite students';

  @override
  String get sessionEndClass => 'End class for everyone, asks to confirm';

  @override
  String get sessionPeopleTitle => 'Participants and raised hands';

  @override
  String sessionHandQueue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Raised hands queue, $count hands waiting',
      one: 'Raised hands queue, 1 hand waiting',
      zero: 'Raised hands queue, No hands waiting',
    );
    return '$_temp0';
  }

  @override
  String sessionParticipantList(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Participants list, $count people',
      one: 'Participants list, 1 person',
    );
    return '$_temp0';
  }

  @override
  String get sessionSummaryChoice => 'Hear classroom summary';

  @override
  String get sessionParticipantsTitle => 'Participants';

  @override
  String get sessionMembersTitle => 'People in the class';

  @override
  String get sessionMembersButton => '7: Who is in class';

  @override
  String sessionMembersLabel(String people) {
    return 'Who is in the class. $people Select a person to hear details';
  }

  @override
  String get sessionHearDetails => 'Hear details';

  @override
  String sessionMuteParticipant(String name) {
    return 'Mute $name';
  }

  @override
  String sessionRemoveParticipant(String name) {
    return 'Remove $name from the class, asks to confirm';
  }

  @override
  String get sessionParticipantGone => 'That participant has left the class.';

  @override
  String get sessionNoOtherParticipants => 'Nobody else is in the class yet.';

  @override
  String sessionTileRemoveMessage(String name) {
    return '$name will be removed from this class and returned to their dashboard.';
  }

  @override
  String sessionTileRemoveFromSessionMessage(String name) {
    return '$name will be removed from this session and returned to their dashboard.';
  }

  @override
  String sessionUnmuteParticipant(String name) {
    return 'Unmute $name';
  }

  @override
  String sessionRemoveFromClass(String name) {
    return 'Remove $name from class';
  }

  @override
  String get sessionConnStateConnecting => 'Connecting';

  @override
  String get sessionConnStateConnected => 'Connected';

  @override
  String get sessionConnStateInterrupted => 'Connection interrupted';

  @override
  String get sessionConnStateReconnecting => 'Reconnecting';

  @override
  String get sessionConnStateSignInRequired => 'Sign-in required';

  @override
  String get sessionConnStateUnavailable => 'Class unavailable';

  @override
  String get sessionConnStateEnded => 'Class ended';

  @override
  String get sessionConnStateDisconnected => 'Disconnected';

  @override
  String get sessionReconnectingToClass => 'Reconnecting to the class.';

  @override
  String get sessionSignInRequiredLeave =>
      'Sign-in is required. Leave the session and sign in again.';

  @override
  String get sessionSignInExpiredLeave =>
      'Sign-in expired. Leave the session and sign in again.';

  @override
  String get sessionClassNoLongerAvailable =>
      'This class is no longer available to your account. You can go back.';

  @override
  String get sessionServiceUnavailable => 'The class service is unavailable.';

  @override
  String get sessionConnectionUnreadable =>
      'The class connection response could not be read.';

  @override
  String get sessionConnectionNotConfirmed =>
      'The class did not confirm the connection.';

  @override
  String get sessionConnectionInterrupted =>
      'The class connection was interrupted.';

  @override
  String get sessionConnectionClosed => 'The class connection closed.';

  @override
  String get sessionConnectionCouldNotConfirm =>
      'The class connection could not be confirmed.';

  @override
  String get sessionNoUpdates => 'No updates were received from the class.';

  @override
  String get sessionUpdateUnreadable => 'A class update could not be read.';

  @override
  String get sessionUpdateUnexpectedFormat =>
      'A class update had an unexpected format.';

  @override
  String get sessionUpdateTypeUnreadable =>
      'A class update type could not be read.';

  @override
  String get sessionParticipationNotConfirmed =>
      'Your class participation was not confirmed.';

  @override
  String get sessionConnectedToClass => 'Connected to the class.';

  @override
  String get sessionSignInChangedShort =>
      'Your sign-in changed. Sign in again.';

  @override
  String get sessionRemovedGoBack =>
      'You have been removed from the class. You can go back.';

  @override
  String sessionConnectionLostReconnecting(String reason) {
    return '$reason Reconnecting. Previous actions will not be sent again automatically.';
  }

  @override
  String get sessionActionClassUnavailable =>
      'The class is not available. This action was not sent.';

  @override
  String get sessionActionSessionChanged =>
      'The session changed. This action was not sent.';

  @override
  String get sessionActionSignInRequired =>
      'Sign-in is required. This action was not sent.';

  @override
  String get sessionActionConnectionChanged =>
      'The connection changed before confirmation. The action may have been received; check its status before retrying.';

  @override
  String get sessionAccountChangedLeave =>
      'Your account changed. Leave the session and sign in again.';

  @override
  String get sessionActionAccountChanged =>
      'Your account changed before the action could be confirmed.';

  @override
  String get sessionActionNotConfirmedByClass =>
      'The class did not confirm the action. Check its status before trying again.';

  @override
  String get sessionActionMayHaveReached =>
      'The action was not confirmed. It may have reached the class. Check its status before trying again.';

  @override
  String get sessionRtcConnectionClosed => 'Connection closed.';

  @override
  String get sessionRtcNetworkError => 'Network error';

  @override
  String sessionRtcConnected(String id) {
    return 'Connected to session $id';
  }

  @override
  String sessionRtcParticipantJoined(String id) {
    return 'Participant $id joined.';
  }

  @override
  String sessionRtcParticipantLeft(String id) {
    return 'Participant $id left.';
  }

  @override
  String sessionRtcParticipantMuted(String id) {
    return 'Participant $id is now muted';
  }

  @override
  String sessionRtcParticipantUnmuted(String id) {
    return 'Participant $id is now unmuted';
  }

  @override
  String sessionRtcMessage(String text) {
    return 'Message: $text';
  }

  @override
  String sessionRtcTeacherPlaying(String id) {
    return 'Teacher started playing audio $id';
  }

  @override
  String sessionRtcAudioStarted(String id) {
    return 'Audio stream started for participant $id';
  }

  @override
  String librarySpeedTimes(String speed) {
    return '$speed times';
  }

  @override
  String get libraryNoClassForSession =>
      'No class found with this session name.';

  @override
  String librarySubjectFilterLabel(String name) {
    return 'Subject filter: $name. Key 2, or left or right to change';
  }

  @override
  String librarySubjectFilterLabelPosition(
    String name,
    String index,
    String total,
  ) {
    return 'Subject filter: $name, $index of $total. Key 2, or left or right to change';
  }

  @override
  String get libraryAllSubjects => 'All subjects';

  @override
  String libraryRestoredToPlaylist(String title) {
    return '$title is back in the playlist.';
  }

  @override
  String get librarySizeZero => '0 megabytes';

  @override
  String get librarySizeTiny => 'less than 0.1 megabytes';

  @override
  String get librarySizeOne => '1 megabyte';

  @override
  String librarySizeMegabytes(String value) {
    return '$value megabytes';
  }

  @override
  String libraryStorageUsed(String size, String limit) {
    return '$size used of $limit.';
  }

  @override
  String libraryRecordingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recordings',
      one: '1 recording',
    );
    return '$_temp0';
  }

  @override
  String libraryPlayingBrief(String title, String position) {
    return '$title, playing from $position.';
  }

  @override
  String libraryPlayingDetailed(String title, String position, String speed) {
    return '$title, playing from $position, speed $speed.';
  }

  @override
  String libraryPausedAt(String position) {
    return 'Paused at $position.';
  }

  @override
  String get libraryPlayerStateNothing => 'Nothing playing.';

  @override
  String libraryPlayerStatePlaying(
    String title,
    String position,
    String speed,
  ) {
    return 'Playing $title, $position, speed $speed.';
  }

  @override
  String libraryPlayerStatePaused(String title, String position, String speed) {
    return 'Paused $title, $position, speed $speed.';
  }

  @override
  String librarySpeedChanged(String speed) {
    return 'Speed $speed.';
  }

  @override
  String get librarySlowest => 'Already at the slowest speed.';

  @override
  String get libraryFastest => 'Already at the fastest speed.';

  @override
  String get libraryNoLessonLoaded =>
      'No lesson is loaded. Choose a lesson to play first.';

  @override
  String libraryNoLessonPlayingPress(String key) {
    return 'No lesson is playing. Press $key to play the first lesson.';
  }

  @override
  String get libraryNothingIsPlaying => 'Nothing is playing.';

  @override
  String get libraryNothingPlayingHint =>
      'Nothing playing. Select a lesson or press 5.';

  @override
  String libraryStopped(String title) {
    return '$title stopped.';
  }

  @override
  String libraryFinished(String title) {
    return '$title finished.';
  }

  @override
  String get libraryWaitForPlayer => 'Please wait for the lesson player.';

  @override
  String get librarySeekFailed =>
      'Could not move to that lesson position. Try again.';

  @override
  String get librarySpeedFailed =>
      'Could not change playback speed. Try again.';

  @override
  String libraryPlayFailed(String title) {
    return 'Could not play $title. Check your connection, then select it again.';
  }

  @override
  String get libraryCheckingOfflineAccess =>
      'Internet unavailable. Checking your saved offline access.';

  @override
  String get libraryLessonGone =>
      'This lesson is no longer available. Your saved progress and bookmarks are kept.';

  @override
  String librarySeekLabel(String position) {
    return 'Lesson position $position. Use left or right to move 10 seconds.';
  }

  @override
  String libraryRewindLabel(String key) {
    return 'Back 10 seconds, key $key';
  }

  @override
  String libraryForwardLabel(String key) {
    return 'Forward 10 seconds, key $key';
  }

  @override
  String librarySlowerLabel(String key, String speed) {
    return 'Slower, key $key. Now $speed';
  }

  @override
  String libraryFasterLabel(String key, String speed) {
    return 'Faster, key $key. Now $speed';
  }

  @override
  String libraryPauseLabel(String title, String key) {
    return 'Pause $title, key $key';
  }

  @override
  String libraryPlayLabel(String title, String key) {
    return 'Play $title, key $key';
  }

  @override
  String libraryResumeLabel(String title, String key) {
    return 'Resume $title, key $key';
  }

  @override
  String libraryStopLabel(String title, String key) {
    return 'Stop $title, key $key';
  }

  @override
  String libraryPlayerKeyHelp(
    String rewind,
    String playPause,
    String forward,
    String slower,
    String faster,
  ) {
    return 'Press $rewind to go back 10 seconds, $playPause to play or pause, $forward to go forward 10 seconds, $slower for slower and $faster for faster.';
  }

  @override
  String libraryBookmarkCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bookmarks',
      one: '1 bookmark',
    );
    return '$_temp0';
  }

  @override
  String libraryLearningStatus(
    String title,
    String position,
    String speed,
    String bookmarks,
    String repeat,
    String saving,
  ) {
    return '$title. Position $position. Speed $speed. $bookmarks. A-B repeat $repeat. Progress saving $saving.';
  }

  @override
  String libraryReadStatusLabel(String status) {
    return 'Read learning status. $status';
  }

  @override
  String libraryAddBookmarkLabel(String time) {
    return 'Add bookmark at $time';
  }

  @override
  String libraryBookmarksLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Bookmarks. $count saved points',
      one: 'Bookmarks. 1 saved point',
    );
    return '$_temp0';
  }

  @override
  String libraryNotesLabel(String time) {
    return 'Private study notes at $time. Pauses the lesson before opening';
  }

  @override
  String get libraryRepeatStartLabel =>
      'Set repeat start A at the current position';

  @override
  String get libraryRepeatEndLabel => 'Set repeat end B after start A';

  @override
  String get libraryRepeatTurnOffLabel => 'Turn A-B repeat off';

  @override
  String get libraryRepeatTurnOnLabel => 'Turn A-B repeat on';

  @override
  String get libraryRepeatClearLabel => 'Clear saved A-B repeat points';

  @override
  String libraryRetryLabel(String issue) {
    return 'Retry saving learning progress. $issue';
  }

  @override
  String libraryBookmarkSaved(String time) {
    return 'Bookmark saved at $time.';
  }

  @override
  String libraryRepeatStartSet(String time) {
    return 'Repeat start set at $time.';
  }

  @override
  String libraryRepeatEndSetBrief(String time) {
    return 'Repeat end set at $time.';
  }

  @override
  String libraryRepeatEndSetDetailed(String time) {
    return 'Repeat end set at $time. Select Repeat on to start looping.';
  }

  @override
  String libraryRepeatState(String state) {
    return 'A-B repeat $state.';
  }

  @override
  String get libraryRepeatCleared => 'A-B repeat points cleared.';

  @override
  String get libraryProgressSaved => 'Learning progress saved.';

  @override
  String get libraryActionFailed =>
      'The player could not complete this action. Check playback and try again.';

  @override
  String get libraryCheckPosition => 'Check the lesson position and try again.';

  @override
  String get libraryProgressUnavailableTitle => 'Saved progress unavailable';

  @override
  String libraryProgressUnavailable(String reason) {
    return '$reason Listen from the beginning without changing saved data? Saving stays off until you retry successfully.';
  }

  @override
  String get libraryListenFromBeginning => 'Listen from beginning';

  @override
  String get libraryBookmarkNameScreen =>
      'Name bookmark. Press OK to edit. Up or down leaves editing.';

  @override
  String get libraryEnterBookmarkName => 'Enter a bookmark name.';

  @override
  String libraryBookmarkLabel(String label, String time) {
    return '$label. $time. Jump to bookmark';
  }

  @override
  String libraryBookmarkJumped(String label, String time) {
    return '$label. Position $time.';
  }

  @override
  String libraryRemoveBookmarkLabel(String label) {
    return 'Remove $label';
  }

  @override
  String libraryRemoveBookmarkQuestion(String label) {
    return 'Remove $label? This does not remove the lesson or any other bookmarks.';
  }

  @override
  String libraryBookmarkRemoved(String label) {
    return '$label removed.';
  }

  @override
  String get libraryBookmarksScreen =>
      'Bookmarks. Select a point to jump. This does not start paused playback. Remove asks for confirmation.';

  @override
  String get libraryNoRecordingsUpload =>
      'No recordings yet. Press 2 to upload audio.';

  @override
  String libraryRecordingsLoaded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recordings loaded.',
      one: '1 recording loaded.',
    );
    return '$_temp0';
  }

  @override
  String get libraryLoadFailed =>
      'Could not load recordings. Check your internet connection, then press 1 to retry.';

  @override
  String get libraryTitleRequired => 'Title is required.';

  @override
  String get libraryPickFailed =>
      'Could not open the file. Try choosing it again.';

  @override
  String get libraryChooseWorkspaceFirst =>
      'Choose a class and subject workspace on the Teacher Dashboard before uploading audio.';

  @override
  String libraryUploadingBrief(String title) {
    return 'Uploading $title.';
  }

  @override
  String libraryUploadingDetailed(String title) {
    return 'Uploading $title. You will hear progress every 25 percent.';
  }

  @override
  String libraryUploadingOnceDetailed(String title) {
    return 'Uploading $title. Please wait; you will hear when it finishes.';
  }

  @override
  String libraryUploadProgress(String title, String percent) {
    return '$title: $percent uploaded.';
  }

  @override
  String libraryUploaded(String title) {
    return '$title uploaded.';
  }

  @override
  String libraryUploadFailed(String title) {
    return '$title could not be uploaded. Check your connection, then press 3 to try again.';
  }

  @override
  String get libraryUploadNoSession =>
      'Upload cancelled. Select at least one session, then press 3 to add audio again.';

  @override
  String get libraryUploadNoClass =>
      'The session class and subject could not be determined.';

  @override
  String get libraryFileUnreadable =>
      'Could not read the file. Choose it again.';

  @override
  String libraryPreviewStopped(String title) {
    return 'Preview of $title stopped.';
  }

  @override
  String libraryPreviewing(String title) {
    return 'Previewing $title privately.';
  }

  @override
  String get libraryPreviewFinished => 'Preview finished.';

  @override
  String libraryPreviewFailed(String title) {
    return 'Could not play $title. Check your connection and try again.';
  }

  @override
  String get libraryNoActiveSession => 'No active session.';

  @override
  String librarySelectedForSession(String title) {
    return 'Selected $title for the session.';
  }

  @override
  String get librarySelectFailed => 'Could not select the audio. Try again.';

  @override
  String get libraryClassPlayAccepted => 'Class playback request accepted.';

  @override
  String get libraryClassPlayFailed =>
      'Could not start class playback. Try again.';

  @override
  String get libraryClassPauseAccepted => 'Class pause request accepted.';

  @override
  String get libraryClassPauseFailed =>
      'Could not pause class audio. Try again.';

  @override
  String libraryStopPreviewLabel(String title) {
    return 'Stop preview of $title privately. Only you can hear this.';
  }

  @override
  String libraryPreviewLabel(String title) {
    return 'Preview $title privately. Only you can hear this.';
  }

  @override
  String libraryBroadcastLabel(String title) {
    return 'Play $title for everyone in the session';
  }

  @override
  String libraryRecordingsSentence(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recordings.',
      one: '1 recording.',
    );
    return '$_temp0';
  }

  @override
  String libraryPreviewingState(String title) {
    return 'Previewing $title.';
  }

  @override
  String get libraryUploadInProgress => 'Upload in progress.';

  @override
  String get libraryAccountChanged =>
      'Your account changed. Open the library again.';

  @override
  String get libraryNoUnfinished =>
      'No unfinished lesson is saved for this account. Choose a recorded lesson to start learning.';

  @override
  String get libraryCannotCheckAccess =>
      'Could not check lesson access. Connect to the internet and retry. Your saved progress is kept.';

  @override
  String get libraryUnfinishedUnavailable =>
      'Your unfinished lessons are not currently available in this library. Your saved progress and bookmarks are kept.';

  @override
  String get libraryOpeningNextUnfinished =>
      'The most recent lesson is unavailable here. Opening your next most recent available unfinished lesson. Saved progress is kept.';

  @override
  String get libraryContinueFailed =>
      'Could not open saved learning progress. Check storage, your connection, and sign-in, then retry.';

  @override
  String get libraryNoActiveClassesNow =>
      'No active classes right now. Press 3 for all audio files.';

  @override
  String libraryClassesLoaded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count active classes loaded.',
      one: '1 active class loaded.',
    );
    return '$_temp0';
  }

  @override
  String libraryClassesFailed(String reason) {
    return '$reason Active classes could not be refreshed. Press 1 to retry. Saved downloads remain available.';
  }

  @override
  String get libraryClassesLoading =>
      'Classes are still loading. Try key 5 again shortly.';

  @override
  String get libraryNoActiveClassesStaying =>
      'There are no active classes. Staying in the audio library.';

  @override
  String libraryFirstActiveClass(String title) {
    return '$title. First active class. Use D-pad up and down to browse active class sessions. Press OK to open the selected class recordings.';
  }

  @override
  String get libraryOpeningPlaylists =>
      'Opening My Playlists. Playlist contents are private.';

  @override
  String libraryClassLabel(String title, String index, String count) {
    return '$title. Class $index of $count';
  }

  @override
  String get libraryLoadingActiveClasses => 'Loading active classes.';

  @override
  String libraryActiveClassesSentence(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count active classes.',
      one: '1 active class.',
    );
    return '$_temp0';
  }

  @override
  String libraryNoRecordingsFor(String where) {
    return 'No recordings yet for $where.';
  }

  @override
  String libraryRecordingsLoadedFor(int count, String where) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recordings loaded for $where.',
      one: '1 recording loaded for $where.',
    );
    return '$_temp0';
  }

  @override
  String get libraryDownloadsReadFailed =>
      'Could not read downloaded lessons. Press 1 to retry.';

  @override
  String get libraryClassLoadFailed =>
      'Could not load recordings. Check your internet connection and sign-in, then press 1 to retry.';

  @override
  String libraryRetryAfter(String reason) {
    return '$reason Press 1 to retry.';
  }

  @override
  String get libraryDownloadedDescription =>
      'Downloaded recording. Access renewal required after 30 days.';

  @override
  String get libraryDownloadedHelp =>
      'Downloaded lessons. Existing offline access is checked before playing.';

  @override
  String get libraryOnlineHelp =>
      'Audio Library. Online recordings require internet. Download lessons for offline playback.';

  @override
  String librarySubjectChoice(String name, String index, String count) {
    return 'Subject: $name, $index of $count';
  }

  @override
  String librarySubjectLabel(String choice) {
    return '$choice. Press 2, or left and right, to change';
  }

  @override
  String get librarySubjectFixed =>
      'This library is already limited to one subject.';

  @override
  String libraryLength(String time) {
    return 'Length $time';
  }

  @override
  String libraryRecordingsInSubject(int count, String subject) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recordings in $subject.',
      one: '1 recording in $subject.',
    );
    return '$_temp0';
  }

  @override
  String libraryNoTeacherPlaylists(String className, String subject) {
    return 'No playlists yet for $className, $subject. Press 2 to create one.';
  }

  @override
  String libraryTeacherPlaylistsLoaded(
    int count,
    String className,
    String subject,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count playlists loaded for $className, $subject.',
      one: '1 playlist loaded for $className, $subject.',
    );
    return '$_temp0';
  }

  @override
  String get libraryPlaylistCreateFailed => 'Playlist could not be created.';

  @override
  String get libraryNoMyPlaylists =>
      'No playlists yet. Press 2 to create a private playlist.';

  @override
  String libraryPrivatePlaylistCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count private playlists',
      one: '1 private playlist',
    );
    return '$_temp0';
  }

  @override
  String libraryClassPlaylistCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count class playlists',
      one: '1 class playlist',
    );
    return '$_temp0';
  }

  @override
  String libraryMyPlaylistsLoaded(
    String privatePlaylists,
    String classPlaylists,
  ) {
    return '$privatePlaylists and $classPlaylists loaded.';
  }

  @override
  String get libraryPrivatePlaylistCreateFailed =>
      'Private playlist could not be created.';

  @override
  String libraryPlaylistsSentence(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count playlists.',
      one: '1 playlist.',
    );
    return '$_temp0';
  }

  @override
  String libraryItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String libraryPlaylistLoaded(String title, String items, String state) {
    return '$title. $items. $state.';
  }

  @override
  String libraryPlaylistLoadedWithPlace(
    String title,
    String place,
    String items,
    String state,
  ) {
    return '$title. $place. $items. $state.';
  }

  @override
  String get libraryPlaylistRefreshFailed =>
      'Could not refresh this playlist. Check your connection and try again. Existing playback and saved progress have not been changed.';

  @override
  String get libraryPlaylistLessonGone =>
      'The current lesson is no longer available in this playlist. Playback stopped. Your saved progress and bookmarks are kept.';

  @override
  String get libraryNothingToAdd => 'No eligible audio is available to add.';

  @override
  String libraryAddedToPlaylist(String title) {
    return '$title added to the playlist.';
  }

  @override
  String get libraryAddFailed =>
      'Could not add the audio. Check your connection and try again.';

  @override
  String libraryItemUnavailable(String title) {
    return '$title is no longer available in your current class. You can remove it from this playlist.';
  }

  @override
  String libraryItemCannotPlay(String title) {
    return '$title is unavailable.';
  }

  @override
  String libraryPlayingItem(String announcement, String index, String count) {
    return '$announcement Item $index of $count.';
  }

  @override
  String get libraryPlaylistPlayFailed =>
      'Could not play this lesson. Check your connection and try again.';

  @override
  String get libraryPlaylistEmpty => 'Playlist is empty.';

  @override
  String get libraryPlaylistEnded => 'End of playlist. Playback stopped.';

  @override
  String libraryRenamed(String title) {
    return 'Playlist renamed to $title.';
  }

  @override
  String get libraryRenameFailed =>
      'Could not rename the playlist. Check your connection and try again.';

  @override
  String get libraryAlreadyFirst => 'The selected item is already first.';

  @override
  String get libraryAlreadyLast => 'The selected item is already last.';

  @override
  String libraryMoved(String title, String position, String count) {
    return '$title moved to position $position of $count.';
  }

  @override
  String libraryMoveFailed(String title) {
    return 'Could not move $title. Check your connection and try again.';
  }

  @override
  String libraryRemovedFromPlaylist(String title, String playlist) {
    return 'Removed $title from $playlist.';
  }

  @override
  String libraryRemoveFailed(String title) {
    return 'Could not remove $title. Check your connection and try again.';
  }

  @override
  String libraryRemoveItemQuestion(String title, String playlist) {
    return 'Remove $title from $playlist? The recording itself is kept in the library.';
  }

  @override
  String libraryRemoveItemLabel(String title) {
    return 'Remove $title from playlist, asks to confirm';
  }

  @override
  String libraryPublished(String title) {
    return '$title published to the class.';
  }

  @override
  String libraryReturnedToDraft(String title) {
    return '$title returned to draft.';
  }

  @override
  String libraryChangeFailed(String title) {
    return 'Could not change $title. Check your connection and try again.';
  }

  @override
  String libraryDeleted(String title) {
    return '$title deleted.';
  }

  @override
  String libraryRestoredAsDraft(String title) {
    return '$title restored as a draft.';
  }

  @override
  String libraryArchived(String title) {
    return '$title archived.';
  }

  @override
  String get libraryPlaylistIsEmpty => 'The playlist is empty.';

  @override
  String librarySelectedItem(String selected, String items) {
    return 'Selected item $selected of $items.';
  }

  @override
  String librarySelectedItemTitled(
    String selected,
    String items,
    String title,
  ) {
    return 'Selected item $selected of $items, $title.';
  }

  @override
  String get libraryAlreadyOneSubject =>
      'This library is already limited to one subject';

  @override
  String get libraryNoLessonIsPlaying => 'No lesson is playing.';

  @override
  String libraryAddedToSession(String title) {
    return '$title added to this session.';
  }

  @override
  String get libraryPlaylistNotCreated => 'Playlist could not be created';

  @override
  String get libraryPrivatePlaylistNotCreated =>
      'Private playlist could not be created';

  @override
  String get libraryNoEligibleAudio => 'No eligible audio is available to add';

  @override
  String get libraryAudioAddedToPlaylist => 'Audio added to playlist';

  @override
  String libraryUnavailable(String title) {
    return '$title is unavailable';
  }

  @override
  String libraryPlaylistRenamed(String title) {
    return 'Playlist renamed to $title';
  }

  @override
  String libraryMovedTo(String title, String position) {
    return '$title moved to position $position';
  }

  @override
  String get libraryNoteRenamed => 'Private note renamed.';

  @override
  String get downloadNoneYet =>
      'No downloads yet. Press 2 to find recordings online.';

  @override
  String downloadLessonCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count downloaded lessons',
      one: '1 downloaded lesson',
    );
    return '$_temp0';
  }

  @override
  String downloadPartialCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count partial downloads',
      one: '1 partial download',
    );
    return '$_temp0';
  }

  @override
  String downloadReadyToPlay(String lessons) {
    return '$lessons ready to play.';
  }

  @override
  String downloadReadyToPlayWithPartial(String lessons, String partial) {
    return '$lessons ready to play, $partial.';
  }

  @override
  String get downloadActionFailed =>
      'Could not complete this download action. Check storage, your connection and sign-in, then retry.';

  @override
  String get downloadOnlineListFailed =>
      'Could not load available recordings. Existing downloads still work until their access expires.';

  @override
  String downloadAvailable(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count recordings are available to download. Select the recordings you want.',
      one:
          '1 recording is available to download. Select the recordings you want.',
    );
    return '$_temp0';
  }

  @override
  String downloadStarting(String title) {
    return 'Downloading $title. You will hear progress every 25 percent.';
  }

  @override
  String downloadProgress(String title, String percent) {
    return '$title $percent downloaded.';
  }

  @override
  String get downloadVerified =>
      'Download verified and saved for offline playback.';

  @override
  String downloadDone(String title) {
    return '$title downloaded, verified and saved for offline playback.';
  }

  @override
  String downloadPackQuestion(String recordings) {
    return 'Download $recordings one at a time? This uses internet data and your account’s 50 MB allowance. On failure or cancellation, verified downloads and partial data are kept. No existing lesson is deleted.';
  }

  @override
  String downloadPackStarting(String recordings) {
    return 'Downloading $recordings, one at a time.';
  }

  @override
  String downloadPackProgress(String done, String total) {
    return '$done of $total recordings verified.';
  }

  @override
  String downloadPackDone(String done, String total) {
    return '$done of $total recordings verified and saved.';
  }

  @override
  String downloadRenewed(String title) {
    return 'Access renewed for $title. Up to 30 days of offline playback.';
  }

  @override
  String downloadRemoveTitle(String title) {
    return 'Remove download of $title?';
  }

  @override
  String downloadRemoveQuestion(String title) {
    return 'Remove the downloaded or partial audio for $title? Learning progress and bookmarks are kept. Other recordings and accounts are not affected.';
  }

  @override
  String downloadRemoved(String title) {
    return 'Removed the download of $title. Progress and bookmarks kept.';
  }

  @override
  String downloadUnreadableTitle(String id) {
    return 'unreadable recording $id';
  }

  @override
  String get downloadRenewalRequired => 'Access renewal required.';

  @override
  String downloadAccessExpires(String date) {
    return 'Access expires $date.';
  }

  @override
  String downloadPlayLabelComplete(String title, String size, String expiry) {
    return 'Play $title. Downloaded. $size. $expiry';
  }

  @override
  String downloadPlayLabelPartial(String title, String size, String expiry) {
    return 'Play $title. Partial download, cannot play yet. $size. $expiry';
  }

  @override
  String downloadRenewLabel(String title) {
    return 'Renew access for $title. Requires internet';
  }

  @override
  String downloadRemoveLabel(String title) {
    return 'Remove download of $title, asks to confirm';
  }

  @override
  String downloadUnreadableLabel(String id) {
    return 'Unreadable download record $id. Remove only this download, asks to confirm';
  }

  @override
  String downloadOrResumeLabel(String title) {
    return 'Download or resume $title';
  }

  @override
  String downloadCancelLabel(String title) {
    return 'Cancel download of $title, key 4. Keep partial data for retry';
  }

  @override
  String downloadUnavailableWhileBusy(String label) {
    return '$label is unavailable while downloads are busy.';
  }

  @override
  String get downloadStorageUnknown =>
      'Storage reservation unavailable. Refresh downloads or remove the selected unreadable records before downloading.';

  @override
  String downloadCountComma(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count downloads,',
      one: '1 download,',
    );
    return '$_temp0';
  }

  @override
  String get downloadStorageUseUnknown => 'storage use unknown.';

  @override
  String downloadDownloadingStarting(String title) {
    return 'Downloading $title, starting.';
  }

  @override
  String downloadDownloadingPercent(String title, String percent) {
    return 'Downloading $title, $percent.';
  }

  @override
  String downloadScreenLoaded(String complete) {
    return '$complete downloaded lessons ready to play.';
  }

  @override
  String downloadScreenLoadedWithPartial(String complete, String partial) {
    return '$complete downloaded lessons ready to play, $partial partial downloads.';
  }

  @override
  String downloadAvailableCount(String count) {
    return '$count recordings are available to download. Select the recordings you want.';
  }

  @override
  String downloadRecordingFallback(String id) {
    return 'Recording $id';
  }

  @override
  String get downloadPackDialogTitle => 'Download listed recordings?';

  @override
  String downloadPackDialogMessage(String count) {
    return 'Download $count listed recordings one at a time? This uses internet data and your account’s 50 MB allowance. On failure or cancellation, verified downloads and partial data are kept. No existing lesson is deleted.';
  }

  @override
  String get downloadPackConfirm => 'Download listed';

  @override
  String get downloadPackCancel => 'Choose individually';

  @override
  String get downloadRemoveConfirm => 'Remove download';

  @override
  String get downloadKeep => 'Keep download';

  @override
  String get downloadScreenName => 'Downloaded Lessons';

  @override
  String get downloadCancelBackTitle => 'Cancel download and go back?';

  @override
  String get downloadCancelBackMessage =>
      'Stop this download? Verified recordings and partial data are kept for an explicit retry.';

  @override
  String get downloadCancelBackConfirm => 'Cancel and go back';

  @override
  String get downloadKeepDownloading => 'Keep downloading';

  @override
  String downloadReserved(String megabytes) {
    return '$megabytes of 50 MB reserved for this account.';
  }

  @override
  String get downloadBack => 'Back';

  @override
  String get downloadRefreshLabel => 'Refresh saved downloads, key 1';

  @override
  String get downloadFindOnlineLabel =>
      'Find recordings to download, key 2. Requires internet';

  @override
  String get downloadReadStatusLabel => 'Read download status, key 3';

  @override
  String downloadPlayDownloadedLabel(String title) {
    return 'Play $title. Downloaded';
  }

  @override
  String downloadPlayPartialLabel(String title) {
    return 'Play $title. Partial download, cannot play yet';
  }

  @override
  String get downloadPackLabel =>
      'Download all listed recordings, key 5, asks to confirm';

  @override
  String get downloadIntroduction =>
      '50 MB per account. Up to 30 days offline before online access renewal. Files and progress stay separate.';

  @override
  String get downloadNavigationSections =>
      'saved files to play, renew or remove, and online recordings to download or resume';

  @override
  String get downloadKeyRefresh => 'Refresh downloads';

  @override
  String get downloadKeyFindOnline => 'Find recordings online';

  @override
  String get downloadKeyReadStatus => 'Read status';

  @override
  String get downloadKeyCancel => 'Cancel download';

  @override
  String get downloadKeyPack => 'Download listed recordings';

  @override
  String get downloadErrInvalidInfo =>
      'Download information is invalid or belongs to a different account. Existing files are kept.';

  @override
  String get downloadErrSignInToOpen =>
      'Sign in before opening downloaded lessons.';

  @override
  String get downloadErrAccountChanged =>
      'Your account changed. Open Downloads again.';

  @override
  String get downloadErrNoStorage =>
      'Download storage is unavailable on this device.';

  @override
  String get downloadErrStorageUnavailable =>
      'Download storage is unavailable. Check free space and retry. Existing files have not been intentionally removed.';

  @override
  String get downloadErrRecordsUnreadable =>
      'Download records could not be read. Existing files are kept.';

  @override
  String get downloadErrRecordUnreadable =>
      'A download record could not be read. Existing files are kept.';

  @override
  String get downloadErrIdentityMismatch =>
      'Download identity does not match its record.';

  @override
  String get downloadErrSignInToRenew =>
      'Sign in online before renewing download access.';

  @override
  String get downloadErrSignInChanged =>
      'Your sign-in changed. Open Downloads again.';

  @override
  String get downloadErrAccessNotConfirmed =>
      'Recording access is no longer confirmed for this account. Reconnect and sign in to renew. The saved file is kept.';

  @override
  String get downloadErrTooLarge =>
      'This recording is larger than the 50 MB download limit.';

  @override
  String get downloadErrRenewServer =>
      'The server could not renew this recording. Try again later.';

  @override
  String get downloadErrInvalidServerInfo =>
      'The server returned invalid download information.';

  @override
  String get downloadErrDifferentRecording =>
      'The server returned a different recording.';

  @override
  String get downloadErrTimedOut =>
      'The connection timed out. Reconnect and retry.';

  @override
  String get downloadErrRenewConnect =>
      'Could not connect to renew this recording. Check your internet connection.';

  @override
  String get downloadErrClockUnreadable =>
      'The offline time record could not be read. Connect and renew access.';

  @override
  String get downloadErrClockBackwards =>
      'The phone clock moved backwards. Correct its date and reconnect to renew access.';

  @override
  String get downloadErrExpired =>
      'Offline access expired after 30 days. Connect to the internet and renew this lesson. Your progress and downloaded file are kept.';

  @override
  String get downloadErrIncompleteForPlayback =>
      'Download this lesson completely before offline playback.';

  @override
  String get downloadErrRenewalRequired =>
      'Access renewal is required. Connect and renew before playing this download.';

  @override
  String get downloadErrDamaged =>
      'The downloaded recording is incomplete or damaged. Remove this download and download it again. Progress and bookmarks are separate.';

  @override
  String get downloadErrDownloadFirst => 'Download this lesson first.';

  @override
  String get downloadErrRecordingChangedRenew =>
      'This recording has changed. Remove its download and download the current recording. Progress and bookmarks are kept.';

  @override
  String get downloadErrCancelledAnyPartial =>
      'Download cancelled. Any partial file is kept for an explicit retry.';

  @override
  String get downloadErrRecordingChanged =>
      'The recording changed. Remove its old download before downloading the current version. Progress is kept.';

  @override
  String get downloadErrSavedDamaged =>
      'The saved recording is damaged. Remove its download before retrying.';

  @override
  String get downloadErrQuota =>
      'Your account has reached its 50 MB download limit. Choose which of your downloads to remove, then retry. Nothing was deleted.';

  @override
  String get downloadErrPartialInvalid =>
      'The partial download is invalid. Remove it before retrying.';

  @override
  String get downloadErrIntegrityPartial =>
      'Download integrity check failed. Remove this partial download before retrying.';

  @override
  String get downloadErrSignInToDownload => 'Sign in before downloading.';

  @override
  String get downloadErrCancelledExplicit =>
      'Download cancelled. Partial data is kept for an explicit retry.';

  @override
  String get downloadErrAccessDenied =>
      'Download access was denied. Reconnect and renew access.';

  @override
  String get downloadErrUnexpectedPartial =>
      'The server returned an unexpected partial recording. Retry without deleting existing data.';

  @override
  String get downloadErrCouldNotDownload =>
      'The recording could not be downloaded. Check your connection and retry.';

  @override
  String get downloadErrSizeChanged =>
      'The recording size changed. Retry downloading.';

  @override
  String get downloadErrAccountChangedStopped =>
      'Your account changed. The download was stopped.';

  @override
  String get downloadErrExceededSize =>
      'The recording exceeded its declared size. Download stopped.';

  @override
  String get downloadErrIntegrity =>
      'Download integrity check failed. Retry an incomplete download, or remove damaged partial data before retrying.';

  @override
  String get downloadErrSignInChangedStopped =>
      'Your sign-in changed. Download stopped before installation.';

  @override
  String get downloadErrTimedOutPartial =>
      'Download timed out. Partial data is kept; activate Download to retry.';

  @override
  String get downloadErrCancelledRetry =>
      'Download cancelled. Partial data is kept for retry.';

  @override
  String get downloadErrInterrupted =>
      'Download interrupted. Partial data is kept; activate Download to retry.';

  @override
  String get libraryErrStorageUnavailable =>
      'Learning storage is unavailable on this device. Your existing data has not been changed.';

  @override
  String get libraryErrStorageNotOpened =>
      'Learning storage could not be opened. Check free space and retry.';

  @override
  String get libraryErrNoStorageLocation =>
      'This device did not provide a learning storage location. Your existing data has not been changed.';

  @override
  String get libraryErrStartLessonFirst =>
      'Start a lesson before retrying progress saving.';

  @override
  String get libraryErrProgressNotSaved =>
      'Learning progress was not saved. Retry when storage is available.';

  @override
  String get libraryErrChoosePosition => 'Choose a position within the lesson';

  @override
  String get libraryErrChooseSpeed => 'Choose a playback speed from 0.25 to 3';

  @override
  String get libraryErrChooseBookmarkPosition =>
      'Choose a bookmark position within the lesson';

  @override
  String get libraryErrBookmarkNotSaved =>
      'Progress saving is unavailable. The bookmark was not saved.';

  @override
  String get libraryErrBookmarkChangesUnavailable =>
      'Bookmark changes are unavailable until progress saving is restored.';

  @override
  String get libraryErrRepeatNotSaved =>
      'Progress saving is unavailable. Repeat points were not saved.';

  @override
  String get libraryErrSetRepeatFirst =>
      'Set a start point and a later end point within this lesson first';

  @override
  String get libraryErrRepeatFailed =>
      'Repeat playback failed. Pause and try again.';

  @override
  String get libraryScreenBack => 'Back';

  @override
  String get libraryScreenRefreshTarget => 'Refresh audio files, key 1';

  @override
  String get libraryScreenPauseSessionTarget =>
      'Pause audio for the whole session, key 3';

  @override
  String get libraryScreenUploadTarget => 'Upload audio, key 2';

  @override
  String libraryScreenStopPreviewTarget(String title) {
    return 'Stop preview of $title privately. Only you can hear this.';
  }

  @override
  String libraryScreenPreviewTarget(String title) {
    return 'Preview $title privately. Only you can hear this.';
  }

  @override
  String libraryScreenBroadcastTarget(String title) {
    return 'Play $title for everyone in the session';
  }

  @override
  String get libraryScreenPreviewFinished => 'Preview finished';

  @override
  String get libraryScreenNoRecordings =>
      'No recordings yet. Press 2 to upload audio.';

  @override
  String libraryScreenRecordingsLoaded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recordings loaded.',
    );
    return '$_temp0';
  }

  @override
  String get libraryScreenLoadFailed =>
      'Could not load recordings. Check your internet connection, then press 1 to retry.';

  @override
  String get libraryScreenTitleRequired => 'Title is required';

  @override
  String get libraryScreenUploadDialogName => 'Upload audio';

  @override
  String get libraryScreenEditTitleKey => 'Edit Title';

  @override
  String get libraryScreenEditDescriptionKey => 'Edit Description';

  @override
  String get libraryScreenUploadKey => 'Upload';

  @override
  String get libraryScreenCancelKey => 'Cancel';

  @override
  String get libraryScreenTitleField => 'Audio title, required';

  @override
  String get libraryScreenDescriptionField => 'Audio description, optional';

  @override
  String get libraryScreenCancelUpload => 'Cancel upload';

  @override
  String get libraryScreenPickFailed => 'Failed to pick file';

  @override
  String get libraryScreenChooseWorkspace =>
      'Choose a class and subject workspace on the Teacher Dashboard before uploading audio.';

  @override
  String libraryScreenUploading(String title) {
    return 'Uploading $title. You will hear progress every 25 percent.';
  }

  @override
  String libraryScreenUploaded(String title) {
    return '$title uploaded.';
  }

  @override
  String libraryScreenUploadProgress(String title, String percent) {
    return '$title: $percent percent uploaded.';
  }

  @override
  String libraryScreenPreviewStopped(String title) {
    return 'Preview of $title stopped';
  }

  @override
  String libraryScreenPreviewing(String title) {
    return 'Previewing $title privately';
  }

  @override
  String libraryScreenPlayFailed(String title) {
    return 'Could not play $title. Check your connection and try again.';
  }

  @override
  String get libraryScreenNoActiveSession => 'No active session';

  @override
  String libraryScreenSelectedForSession(String title) {
    return 'Selected $title for session';
  }

  @override
  String get libraryScreenAudioSelectedTitle => 'Audio Selected';

  @override
  String libraryScreenPlayForEveryoneNow(String title) {
    return 'Play \"$title\" for everyone in the session now?';
  }

  @override
  String get libraryScreenNotYet => 'Not Yet';

  @override
  String get libraryScreenPlayNow => 'Play Now';

  @override
  String get libraryScreenSelectFailed => 'Failed to select audio';

  @override
  String get libraryScreenPlaybackAccepted => 'Class playback request accepted';

  @override
  String get libraryScreenPlaybackFailed => 'Failed to start playback';

  @override
  String get libraryScreenPauseAccepted => 'Class pause request accepted';

  @override
  String get libraryScreenPauseFailed => 'Failed to pause audio';

  @override
  String get libraryScreenAudioLibraryName => 'Audio library';

  @override
  String get libraryScreenAudioLibrarySections =>
      'recordings, playback and speech controls, recording sharing, and upload tools when available';

  @override
  String get libraryScreenRefreshKey => 'Refresh Audio Files';

  @override
  String get libraryScreenUploadAudioKey => 'Upload Audio';

  @override
  String get libraryScreenPauseSessionKey => 'Pause Session Audio';

  @override
  String get libraryScreenBrowseTarget =>
      'Focus first active class. Use D-pad to browse active sessions';

  @override
  String get libraryScreenRefreshClassesTarget => 'Refresh classes';

  @override
  String get libraryScreenSearchClassField => 'Search class by name';

  @override
  String get libraryScreenSearchTarget => 'Search';

  @override
  String get libraryScreenAllRecordedTarget => 'All recorded audio files';

  @override
  String get libraryScreenContinueTarget =>
      'Continue learning. Find your last unfinished recorded lesson';

  @override
  String get libraryScreenDownloadsTarget =>
      'Downloaded lessons. Open saved recordings without loading online lists';

  @override
  String get libraryScreenNotesTarget =>
      'Private notes and teacher recording drafts. Works from local storage';

  @override
  String get libraryScreenMyPlaylistsTarget => 'My private playlists';

  @override
  String libraryScreenClassTarget(String title, String position, String total) {
    return '$title. Class $position of $total';
  }

  @override
  String get libraryScreenAccountChanged =>
      'Your account changed. Open the library again.';

  @override
  String get libraryScreenNoUnfinishedLesson =>
      'No unfinished lesson is saved for this account. Choose a recorded lesson to start learning.';

  @override
  String get libraryScreenAccessCheckFailed =>
      'Could not check lesson access. Connect to the internet and retry. Your saved progress is kept.';

  @override
  String get libraryScreenUnfinishedUnavailable =>
      'Your unfinished lessons are not currently available in this library. Your saved progress and bookmarks are kept.';

  @override
  String get libraryScreenOpeningNextUnfinished =>
      'The most recent lesson is unavailable here. Opening your next most recent available unfinished lesson. Saved progress is kept.';

  @override
  String get libraryScreenProgressOpenFailed =>
      'Could not open saved learning progress. Check storage, your connection, and sign-in, then retry.';

  @override
  String get libraryScreenContinueLearningTitle => 'Continue Learning';

  @override
  String get libraryScreenNoActiveClasses =>
      'No active classes right now. Press 3 for all audio files.';

  @override
  String libraryScreenActiveClassesLoaded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count active classes loaded.',
    );
    return '$_temp0';
  }

  @override
  String libraryScreenClassesRefreshFailed(String reason) {
    return '$reason Active classes could not be refreshed. Press 1 to retry. Saved downloads remain available.';
  }

  @override
  String get libraryScreenClassListUnreadable =>
      'The class list could not be read.';

  @override
  String get libraryScreenSessionFallback => 'Session';

  @override
  String get libraryScreenMyAudioLibraryTitle => 'My Audio Library';

  @override
  String get libraryScreenAllAudioFilesTitle => 'All Audio Files';

  @override
  String get libraryScreenNoActiveClassesStaying =>
      'There are no active classes. Staying in the audio library.';

  @override
  String libraryScreenFirstActiveClass(String title) {
    return '$title. First active class. Use D-pad up and down to browse active class sessions. Press OK to open the selected class recordings.';
  }

  @override
  String get libraryScreenRecordedLibraryName =>
      'Recorded Audio Library. Online lists require internet. Downloaded lessons open separately for offline playback.';

  @override
  String get libraryScreenRecordedLibrarySections =>
      'continue learning, saved downloads and private notes, class search, and active class sessions';

  @override
  String get libraryScreenMyPlaylistsKey => 'My Private Playlists';

  @override
  String get libraryScreenWaitForPlayerNotes =>
      'Wait for the recording player before opening study notes.';

  @override
  String get libraryScreenStatusPlaying => 'Playing';

  @override
  String get libraryScreenStatusPaused => 'Paused';

  @override
  String get libraryScreenUntitled => 'Untitled';

  @override
  String get libraryScreenSubjectFallback => 'Subject';

  @override
  String get libraryScreenDownloadedLessonsName =>
      'Downloaded lessons. Existing offline access is checked before playing.';

  @override
  String get libraryScreenClassAudioName =>
      'Audio Library. Online recordings require internet. Download lessons for offline playback.';

  @override
  String libraryScreenLessonPositionTarget(String position) {
    return 'Lesson position $position. Use left or right to move 10 seconds.';
  }

  @override
  String libraryScreenBack10Target(String key) {
    return 'Back 10 seconds, key $key';
  }

  @override
  String libraryScreenPauseTarget(String title, String key) {
    return 'Pause $title, key $key';
  }

  @override
  String libraryScreenResumeTarget(String title, String key) {
    return 'Resume $title, key $key';
  }

  @override
  String get libraryScreenLessonFallback => 'lesson';

  @override
  String libraryScreenForward10Target(String key) {
    return 'Forward 10 seconds, key $key';
  }

  @override
  String libraryScreenSlowerTarget(String key, String speed) {
    return 'Slower, key $key. Now $speed times';
  }

  @override
  String libraryScreenStopTarget(String title) {
    return 'Stop $title, key 8';
  }

  @override
  String libraryScreenFasterTarget(String key, String speed) {
    return 'Faster, key $key. Now $speed times';
  }

  @override
  String get libraryScreenDownloadsManageTarget =>
      'Download lessons or manage saved recordings';

  @override
  String get libraryScreenStopSpeechTarget => 'Stop speech';

  @override
  String get libraryScreenUploadFirstTarget => 'Upload first audio';

  @override
  String get libraryScreenRefreshEmptyTarget => 'Refresh empty audio library';

  @override
  String get libraryScreenAddAudioTarget => 'Add audio, key 3';

  @override
  String get libraryScreenLessonTitleFallback => 'Lesson';

  @override
  String get libraryScreenDownloadedDescription =>
      'Downloaded recording. Access renewal required after 30 days.';

  @override
  String libraryScreenSavedSubject(String id) {
    return 'Saved subject $id';
  }

  @override
  String get libraryScreenDownloadsReadFailed =>
      'Could not read downloaded lessons. Press 1 to retry.';

  @override
  String get libraryScreenLoadFailedSignIn =>
      'Could not load recordings. Check your internet connection and sign-in, then press 1 to retry.';

  @override
  String libraryScreenNoRecordingsFor(String name) {
    return 'No recordings yet for $name.';
  }

  @override
  String libraryScreenRecordingsLoadedFor(int count, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recordings loaded for $name.',
    );
    return '$_temp0';
  }

  @override
  String get libraryScreenLessonNoLongerAvailable =>
      'This lesson is no longer available. Your saved progress and bookmarks are kept.';

  @override
  String libraryScreenFailurePressRetry(String reason) {
    return '$reason Press 1 to retry.';
  }

  @override
  String libraryScreenSubjectNumber(String id) {
    return 'Subject $id';
  }

  @override
  String get libraryScreenShowingAllSubjects =>
      'Showing audio from all subjects';

  @override
  String libraryScreenShowingSubject(String subject, String count) {
    return 'Showing $subject audio. $count files';
  }

  @override
  String libraryScreenPausedAt(String position) {
    return 'Paused at $position.';
  }

  @override
  String get libraryScreenCheckingOfflineAccess =>
      'Internet unavailable. Checking your saved offline access.';

  @override
  String libraryScreenPlayFailedSelectAgain(String title) {
    return 'Could not play $title. Check your connection, then select it again.';
  }

  @override
  String get libraryScreenNothingPlaying => 'Nothing is playing.';

  @override
  String libraryScreenTitleStopped(String title) {
    return '$title stopped.';
  }

  @override
  String libraryScreenNoLessonPlayingPress(String key) {
    return 'No lesson is playing. Press $key to play the first lesson.';
  }

  @override
  String get libraryScreenSeekFailed =>
      'Could not move to that lesson position. Try again.';

  @override
  String get libraryScreenSlowestSpeed => 'Already at the slowest speed.';

  @override
  String get libraryScreenFastestSpeed => 'Already at the fastest speed.';

  @override
  String get libraryScreenSpeedFailed =>
      'Could not change playback speed. Try again.';

  @override
  String get libraryScreenReadFileFailed => 'Failed to read file data.';

  @override
  String get libraryScreenTitleFieldPlain => 'Audio title';

  @override
  String get libraryScreenChooseSessionsName =>
      'Choose sessions for this audio';

  @override
  String get libraryScreenConfirmSessionsKey => 'Confirm Selected Sessions';

  @override
  String libraryScreenSessionNumber(String id) {
    return 'Session $id';
  }

  @override
  String libraryScreenSessionSelected(String name) {
    return '$name, selected';
  }

  @override
  String libraryScreenSessionNotSelected(String name) {
    return '$name, not selected';
  }

  @override
  String libraryScreenConfirmSelectedSessions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Confirm $count selected sessions',
    );
    return '$_temp0';
  }

  @override
  String get libraryScreenUploadCancelledNoSession =>
      'Upload cancelled. Select at least one session, then press 3 to add audio again.';

  @override
  String libraryScreenUploadingWait(String title) {
    return 'Uploading $title. Please wait; you will hear when it finishes.';
  }

  @override
  String get libraryScreenClassSubjectUnknown =>
      'The session class and subject could not be determined';

  @override
  String libraryScreenUploadFailedRetry(String title) {
    return '$title could not be uploaded. Check your connection, then press 3 to try again.';
  }

  @override
  String get libraryScreenAudioFallback => 'Audio';

  @override
  String get libraryScreenClassLibraryName => 'Class Audio Library';

  @override
  String get libraryScreenClassLibrarySections =>
      'playback controls, bookmarks and learning progress, subject filter, downloads, recordings, and teacher upload tools when available';

  @override
  String get libraryScreenSubjectFilterField => 'Subject filter (key 2)';

  @override
  String get libraryScreenAllSubjects => 'All subjects';

  @override
  String get libraryScreenAddAudioOptionsName => 'Add Audio Options';

  @override
  String get libraryScreenCloseAddAudioTarget => 'Close add audio options';

  @override
  String get libraryScreenUploadNewTarget => 'Upload new file, key 1';

  @override
  String get libraryScreenSelectExistingTarget =>
      'Select from existing library, key 2';

  @override
  String libraryScreenRecordingsAvailable(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recordings available.',
    );
    return '$_temp0';
  }

  @override
  String libraryScreenNoRecordingsMatch(String query) {
    return 'No recordings match $query.';
  }

  @override
  String libraryScreenRecordingsMatch(int count, String query) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recordings match $query.',
    );
    return '$_temp0';
  }

  @override
  String get libraryScreenNoUnlinkedRecordings =>
      'No unlinked recordings available for this class.';

  @override
  String libraryScreenRecordingsAvailableChoose(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count recordings available. Use up and down to choose, or search by title.',
    );
    return '$_temp0';
  }

  @override
  String libraryScreenAddFailed(String title) {
    return 'Could not add $title. Check your connection and try again.';
  }

  @override
  String get libraryScreenSelectExistingName => 'Select Existing Audio';

  @override
  String get libraryScreenSelectExistingSections =>
      'search and every available recording';

  @override
  String get libraryScreenRefreshAvailableTarget =>
      'Refresh available audio, key 1';

  @override
  String get libraryScreenSearchRecordingsField =>
      'Search recordings by title. Press OK to type';

  @override
  String libraryScreenSearchRecordingsWithQuery(String query, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Search recordings, $query. $count matches',
    );
    return '$_temp0';
  }

  @override
  String libraryScreenAddToSessionTarget(String title) {
    return 'Add $title to this session';
  }

  @override
  String get libraryScreenRepeatHelpTarget => 'Repeat audio library help';

  @override
  String get playlistBack => 'Back';

  @override
  String get playlistCancel => 'Cancel';

  @override
  String get playlistCreate => 'Create';

  @override
  String get playlistRefresh => 'Refresh';

  @override
  String playlistTeacherNone(String className, String subject) {
    return 'No playlists yet for $className, $subject. Press 2 to create one.';
  }

  @override
  String playlistTeacherLoaded(int count, String className, String subject) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count playlists',
    );
    return '$_temp0 loaded for $className, $subject';
  }

  @override
  String get playlistCreateClassTitle => 'Create class playlist';

  @override
  String get playlistTitleField => 'Playlist title';

  @override
  String get playlistCancelCreation => 'Cancel playlist creation';

  @override
  String get playlistCreatePlaylist => 'Create playlist';

  @override
  String get playlistCreatePlaylistKey => 'Create Playlist';

  @override
  String get playlistRefreshPlaylists => 'Refresh playlists';

  @override
  String playlistTeacherItemLabel(String title, String status, String count) {
    return '$title. $status. $count items';
  }

  @override
  String playlistTeacherScreen(String className, String subject) {
    return 'Class Playlists, $className, $subject';
  }

  @override
  String get playlistStatusArchived => 'Archived';

  @override
  String get playlistStatusPublished => 'Published';

  @override
  String get playlistStatusDraft => 'Draft';

  @override
  String get playlistStudentNone =>
      'No playlists yet. Press 2 to create a private playlist.';

  @override
  String playlistStudentLoaded(int privateCount, int classCount) {
    String _temp0 = intl.Intl.pluralLogic(
      privateCount,
      locale: localeName,
      other: '$privateCount private playlists',
    );
    String _temp1 = intl.Intl.pluralLogic(
      classCount,
      locale: localeName,
      other: '$classCount class playlists',
    );
    return '$_temp0 and $_temp1 loaded';
  }

  @override
  String get playlistCreatePrivate => 'Create private playlist';

  @override
  String get playlistCreatePrivateKey => 'Create Private Playlist';

  @override
  String playlistPrivateItemLabel(String title, String count) {
    return '$title, private, $count items';
  }

  @override
  String playlistClassItemLabel(String title, String subject, String count) {
    return '$title, class playlist, $subject, $count items';
  }

  @override
  String get playlistStudentScreen =>
      'My Playlists. Private playlists are visible only to you.';

  @override
  String get playlistWaitBeforeNotes =>
      'Wait for the playlist player before opening study notes.';

  @override
  String get playlistRefreshFailed =>
      'Could not refresh this playlist. Check your connection and try again. Existing playback and saved progress have not been changed.';

  @override
  String get playlistLessonGone =>
      'The current lesson is no longer available in this playlist. Playback stopped. Your saved progress and bookmarks are kept.';

  @override
  String get playlistStateArchived => 'archived';

  @override
  String get playlistStatePublished => 'published';

  @override
  String get playlistStateDraft => 'draft';

  @override
  String get playlistStatePrivate => 'private';

  @override
  String get playlistStatePublishedClass => 'published class playlist';

  @override
  String playlistLoaded(
    String title,
    String className,
    String subject,
    int count,
    String state,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
    );
    return '$title. $className $subject. $_temp0. $state.';
  }

  @override
  String get playlistAddAudioScreen => 'Add audio to playlist';

  @override
  String playlistItemNoLongerAvailable(String title) {
    return '$title is no longer available in your current class. You can remove it from this playlist.';
  }

  @override
  String playlistItemPosition(String index, String total) {
    return 'Item $index of $total.';
  }

  @override
  String get playlistPlayFailed =>
      'Could not play this lesson. Check your connection and try again.';

  @override
  String playlistPausedAt(String position) {
    return 'Paused at $position.';
  }

  @override
  String get playlistLessonDefault => 'Lesson';

  @override
  String get playlistSave => 'Save';

  @override
  String get playlistRenameScreen => 'Rename playlist';

  @override
  String get playlistCancelRename => 'Cancel rename';

  @override
  String get playlistSaveTitle => 'Save playlist title';

  @override
  String get playlistAlreadyFirst => 'The selected item is already first.';

  @override
  String get playlistAlreadyLast => 'The selected item is already last.';

  @override
  String playlistMoveFailed(String title) {
    return 'Could not move $title. Check your connection and try again.';
  }

  @override
  String get playlistThisPlaylist => 'this playlist';

  @override
  String playlistRemoveItemTitle(String title) {
    return 'Remove $title?';
  }

  @override
  String playlistRemoveItemMessage(String title, String playlist) {
    return 'Remove $title from $playlist? The recording itself is kept in the library.';
  }

  @override
  String playlistKeepItem(String title) {
    return 'Keep $title';
  }

  @override
  String playlistRemoveItem(String title) {
    return 'Remove $title';
  }

  @override
  String playlistRemoveFailed(String title) {
    return 'Could not remove $title. Check your connection and try again.';
  }

  @override
  String playlistPublishedToClass(String title) {
    return '$title published to the class';
  }

  @override
  String playlistReturnedToDraft(String title) {
    return '$title returned to draft';
  }

  @override
  String playlistChangeFailed(String title) {
    return 'Could not change $title. Check your connection and try again.';
  }

  @override
  String playlistDeleteTitle(String title) {
    return 'Delete $title?';
  }

  @override
  String playlistRestoreTitle(String title) {
    return 'Restore $title?';
  }

  @override
  String playlistArchiveTitle(String title) {
    return 'Archive $title?';
  }

  @override
  String playlistDeleteMessage(String title) {
    return 'This removes the private playlist $title and its ordered items. Recordings stay in the library.';
  }

  @override
  String playlistRestoreMessage(String title) {
    return 'This returns $title to draft so it can be edited and published again.';
  }

  @override
  String playlistArchiveMessage(String title) {
    return 'Students will no longer see $title. Teacher history is retained.';
  }

  @override
  String playlistDeleteConfirm(String title) {
    return 'Delete $title';
  }

  @override
  String playlistRestoreConfirm(String title) {
    return 'Restore $title';
  }

  @override
  String playlistArchiveConfirm(String title) {
    return 'Archive $title';
  }

  @override
  String playlistDeleted(String title) {
    return '$title deleted';
  }

  @override
  String playlistRestoredDraft(String title) {
    return '$title restored as a draft';
  }

  @override
  String playlistArchived(String title) {
    return '$title archived';
  }

  @override
  String get playlistSelectedItem => 'selected item';

  @override
  String get playlistSeekFailed =>
      'Could not move to that lesson position. Try again.';

  @override
  String get playlistRefreshPlaylist => 'Refresh playlist';

  @override
  String get playlistWordPlaylist => 'playlist';

  @override
  String playlistRenameLabel(String title) {
    return 'Rename $title';
  }

  @override
  String get playlistAddAudioLabel => 'Add audio, key 2';

  @override
  String playlistPauseLabel(String title, String key) {
    return 'Pause $title, key $key';
  }

  @override
  String playlistPlayLabel(String title, String key) {
    return 'Play $title, key $key';
  }

  @override
  String get playlistPreviousLabel => 'Previous item, key 3';

  @override
  String get playlistNextLabel => 'Next item, key 8';

  @override
  String playlistReturnToDraftLabel(String title) {
    return 'Return $title to draft';
  }

  @override
  String playlistPublishLabel(String title) {
    return 'Publish $title to the class';
  }

  @override
  String playlistRestoreLabel(String title) {
    return 'Restore $title';
  }

  @override
  String playlistArchiveLabel(String title) {
    return 'Archive $title, asks to confirm';
  }

  @override
  String playlistDeleteLabel(String title) {
    return 'Delete $title, asks to confirm';
  }

  @override
  String playlistSeekLabel(String position) {
    return 'Lesson position $position. Use left or right to move 10 seconds';
  }

  @override
  String get playlistDownloadsLabel =>
      'Download playlist recordings. Select individually or confirm all listed recordings';

  @override
  String playlistMoveUpLabel(String title) {
    return 'Move $title up';
  }

  @override
  String playlistMoveDownLabel(String title) {
    return 'Move $title down';
  }

  @override
  String playlistRemoveItemLabel(String title) {
    return 'Remove $title from playlist, asks to confirm';
  }

  @override
  String get playlistItemUnavailableInClass =>
      'Unavailable in your current class';

  @override
  String get playlistItemSelected => 'Selected';

  @override
  String get playlistItemPlaying => 'Playing';

  @override
  String get playlistItemSelectedPaused => 'Selected, paused';

  @override
  String get playlistAddAudioKey => 'Add Audio';

  @override
  String get playlistPreviousItem => 'Previous item';

  @override
  String get playlistNextItem => 'Next item';

  @override
  String get playlistScreenDefault => 'Playlist';

  @override
  String playlistScreen(String title) {
    return '$title playlist';
  }

  @override
  String playlistItemUnavailable(String title) {
    return '$title is unavailable in your current class';
  }

  @override
  String get notesNoRecordingActive => 'No recording active.';

  @override
  String get notesMicCouldNotRecord =>
      'The microphone could not record this note.';

  @override
  String get notesRecordingNotConfirmed =>
      'Recording could not be confirmed. Its partial files are kept. Check microphone permission and storage.';

  @override
  String get notesLeaveLiveSession =>
      'Leave the live session and open private notes before recording.';

  @override
  String get notesMicPermissionDenied =>
      'Microphone permission was not granted. No recording started. Enable it in Android settings and retry.';

  @override
  String get notesRecordingCancelledChanged =>
      'Recording was cancelled because the screen or app changed. Start again when ready.';

  @override
  String get notesSpeechDidNotStop =>
      'App speech did not stop. Check the TTS engine before recording.';

  @override
  String get notesRecordingDidNotStart =>
      'Recording did not start because the app changed. Its empty draft is kept for selected removal.';

  @override
  String get notesAnotherRecorderStopping =>
      'Another private recorder is still stopping. Return to it or background the app before recording.';

  @override
  String get notesNativeStartNotConfirmed =>
      'The native recorder did not confirm starting. The draft is kept.';

  @override
  String get notesNativeStopNotConfirmed =>
      'Native recording stop was not confirmed. Background the app to stop capture before retrying.';

  @override
  String get notesDurationUnreadable =>
      'The recorder duration was unreadable. Its incomplete file is kept.';

  @override
  String get notesRecordingInProgress =>
      'Recording. Stop before speaking to app controls. Maximum five minutes; stops on app narration or interruption.';

  @override
  String get notesNativeCaptureStopped =>
      'Native capture is stopped. Any unfinished draft is kept for selected removal.';

  @override
  String get notesRecorderStopNotConfirmed =>
      'Recorder stop was not confirmed. Leave this screen or background the app to stop native capture before retrying.';

  @override
  String get notesRecorderFailed =>
      'The recorder failed. Its incomplete file is retained for selected removal.';

  @override
  String get notesNotFinalized =>
      'Recording stopped, but the note could not be finalized. Files are kept for selected removal.';

  @override
  String get notesRecordingLimitReached => 'Recording limit reached.';

  @override
  String get notesRecordingInterrupted => 'Recording interrupted.';

  @override
  String get notesRecordingStopped => 'Recording stopped.';

  @override
  String get notesSavedOnPhone =>
      'Private note saved on this phone. Review before publishing or sharing.';

  @override
  String get notesSignInFirst => 'Sign in before opening private notes.';

  @override
  String get notesInvalidIdentity => 'Invalid note identity.';

  @override
  String get notesAccountChanged =>
      'Your account changed. Open private notes again.';

  @override
  String get notesStorageUnavailable =>
      'Private note storage is unavailable. Check free space and retry. Existing files are kept.';

  @override
  String get notesInvalidNameOrPosition =>
      'Enter a note name of up to 160 characters and a valid lesson position.';

  @override
  String get notesAllowanceFull =>
      'Your private note allowance is full. Remove a chosen note before recording. No note was deleted.';

  @override
  String get notesInterruptedOrInvalid =>
      'The note was interrupted or its duration is invalid. Its files are retained for selected removal.';

  @override
  String get notesEmptyOrTooLarge =>
      'This recording is empty or exceeds the private-note allowance. Its partial file is kept; review storage and remove the selected recording.';

  @override
  String get notesIncompleteUnavailable =>
      'This note is incomplete or unavailable. It has not been deleted.';

  @override
  String get notesInvalidName => 'Enter a note name of up to 160 characters.';

  @override
  String notesUnreadableTitle(String id) {
    return 'Unreadable note $id';
  }

  @override
  String get notesRecordUnreadable =>
      'This note record cannot be read. Its files are kept; only explicit selected removal changes them.';

  @override
  String notesInterruptedTitle(String id) {
    return 'Interrupted recording $id';
  }

  @override
  String get notesMetadataMissing =>
      'Recording metadata is missing. The file is retained for selected removal.';

  @override
  String get learningSavedLessonInvalid =>
      'Saved lesson information is invalid. Your saved data has not been changed.';

  @override
  String get learningSavedBookmarkUnreadable =>
      'A saved bookmark could not be read. Your saved data has not been changed.';

  @override
  String get learningSavedBookmarkIdsInvalid =>
      'Saved bookmark identifiers are invalid. Your saved data has not been changed.';

  @override
  String get learningSavedRepeatInvalid =>
      'Saved repeat bounds are invalid. Your saved data has not been changed.';

  @override
  String get learningSignInFirst =>
      'Sign in before using saved learning progress.';

  @override
  String get learningAccountChanged =>
      'Your account changed. Open the learning library again.';

  @override
  String get learningUnsupportedFormat =>
      'Saved learning data has an unsupported format or account. Your saved data has not been changed.';

  @override
  String get learningIdentityMismatch =>
      'Saved lesson identity does not match. Your saved data has not been changed.';

  @override
  String get learningDataUnreadable =>
      'Saved learning data could not be read. Your saved data has not been changed.';

  @override
  String get learningStorageUnavailableFreeSpace =>
      'Learning storage is unavailable. Check free space and retry. Your saved data has not been intentionally removed.';

  @override
  String get learningStorageUnavailable =>
      'Learning storage is unavailable. Check storage and retry.';

  @override
  String get learningSaveFailed =>
      'Learning progress could not be saved. Check free space and retry.';

  @override
  String get learningProgressUnavailable =>
      'Saved learning progress is unavailable. Check storage and retry.';

  @override
  String get learningStartLessonFirst =>
      'Start this lesson before adding bookmarks or repeat points.';

  @override
  String learningSavedFieldUnreadable(String field) {
    return 'The saved $field could not be read. Your saved data has not been changed.';
  }

  @override
  String get learningFieldBookmarkId => 'bookmark id';

  @override
  String get learningFieldBookmarkLabel => 'bookmark label';

  @override
  String get learningFieldBookmarkPosition => 'bookmark position';

  @override
  String get learningFieldUpdateTime => 'update time';

  @override
  String get learningFieldNextBookmarkId => 'next bookmark id';

  @override
  String get learningFieldLessonId => 'lesson id';

  @override
  String get learningFieldLessonTitle => 'lesson title';

  @override
  String get learningFieldPosition => 'position';

  @override
  String get learningInvalidProgress => 'Invalid lesson progress';

  @override
  String get learningBookmarkNeedsPositionLabel =>
      'A bookmark needs a valid position and label';

  @override
  String get learningBookmarkExceedsDuration =>
      'Bookmark position exceeds lesson duration';

  @override
  String learningDefaultBookmarkLabel(String number) {
    return 'Bookmark $number';
  }

  @override
  String get learningBookmarkNotFound => 'Bookmark not found';

  @override
  String get learningRepeatEndAfterStart =>
      'Set the end point after the start point';

  @override
  String get learningRepeatExceedsDuration =>
      'Repeat points exceed lesson duration';

  @override
  String get learningSavedProgressUnavailableTitle =>
      'Saved progress unavailable';

  @override
  String get learningListenWithoutSavedPrompt =>
      'Listen from the beginning without changing saved data? Saving stays off until you retry successfully.';

  @override
  String get learningListenFromBeginning => 'Listen from beginning';

  @override
  String get learningRecordedLesson => 'Recorded lesson';

  @override
  String learningStatusPosition(String position) {
    return 'Position $position.';
  }

  @override
  String learningSpeedTimes(String speed) {
    return 'Speed $speed times.';
  }

  @override
  String learningStatusBookmarks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bookmarks',
    );
    return '$_temp0';
  }

  @override
  String learningStatusRepeat(String state) {
    return 'A-B repeat $state.';
  }

  @override
  String learningStatusSaving(String state) {
    return 'Progress saving $state.';
  }

  @override
  String get learningNoLessonLoaded =>
      'No lesson is loaded. Choose a lesson to play first.';

  @override
  String get learningSlowestSpeed => 'Already at the slowest speed.';

  @override
  String get learningFastestSpeed => 'Already at the fastest speed.';

  @override
  String get learningCheckPosition =>
      'Check the lesson position and try again.';

  @override
  String get learningPlayerActionFailed =>
      'The player could not complete this action. Check playback and try again.';

  @override
  String learningBookmarkSavedAt(String time) {
    return 'Bookmark saved at $time.';
  }

  @override
  String learningReadStatusLabel(String status) {
    return 'Read learning status. $status';
  }

  @override
  String learningAddBookmarkAt(String time) {
    return 'Add bookmark at $time';
  }

  @override
  String learningBookmarksSavedPoints(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Bookmarks. $count saved points',
    );
    return '$_temp0';
  }

  @override
  String learningPrivateNotesAt(String time) {
    return 'Private study notes at $time. Pause lesson before opening';
  }

  @override
  String get learningSetRepeatStartLabel =>
      'Set repeat start A at the current position';

  @override
  String learningRepeatStartSet(String time) {
    return 'Repeat start set at $time.';
  }

  @override
  String get learningSetRepeatEndLabel => 'Set repeat end B after start A';

  @override
  String learningRepeatEndSet(String time) {
    return 'Repeat end set at $time. Select Repeat on to start looping.';
  }

  @override
  String get learningTurnRepeatOff => 'Turn A-B repeat off';

  @override
  String get learningTurnRepeatOn => 'Turn A-B repeat on';

  @override
  String get learningClearRepeatLabel => 'Clear saved A-B repeat points';

  @override
  String get learningRepeatCleared => 'A-B repeat points cleared.';

  @override
  String learningBackTenLabel(String key) {
    return 'Back 10 seconds, key $key';
  }

  @override
  String learningForwardTenLabel(String key) {
    return 'Forward 10 seconds, key $key';
  }

  @override
  String learningSlowerLabel(String key, String speed) {
    return 'Slower, key $key. Now $speed times';
  }

  @override
  String learningFasterLabel(String key, String speed) {
    return 'Faster, key $key. Now $speed times';
  }

  @override
  String learningRetrySavingLabel(String issue) {
    return 'Retry saving learning progress. $issue';
  }

  @override
  String get learningProgressSaved => 'Learning progress saved.';

  @override
  String get learningEnterBookmarkName => 'Enter a bookmark name.';

  @override
  String get learningNameBookmarkScreen =>
      'Name bookmark. Press OK to edit. Up or down leaves editing.';

  @override
  String get learningEditName => 'Edit name';

  @override
  String get learningSaveBookmark => 'Save bookmark';

  @override
  String get learningBookmarkNameField => 'Bookmark name';

  @override
  String learningBookmarkJumped(String label, String position) {
    return '$label. Position $position.';
  }

  @override
  String get learningRemoveBookmarkTitle => 'Remove bookmark?';

  @override
  String learningRemoveBookmarkMessage(String label) {
    return 'Remove $label? This does not remove the lesson or any other bookmarks.';
  }

  @override
  String get learningKeepBookmark => 'Keep bookmark';

  @override
  String get learningRemoveBookmark => 'Remove bookmark';

  @override
  String learningBookmarkRemoved(String label) {
    return '$label removed.';
  }

  @override
  String get learningBookmarksScreen =>
      'Bookmarks. Select a point to jump. This does not start paused playback. Remove asks for confirmation.';

  @override
  String get learningCloseBookmarks => 'Close bookmarks';

  @override
  String learningJumpToBookmarkLabel(String label, String time) {
    return '$label. $time. Jump to bookmark';
  }

  @override
  String learningRemoveBookmarkLabel(String label) {
    return 'Remove $label';
  }

  @override
  String get dashboardRefreshing => 'Refreshing sessions.';

  @override
  String get dashboardShowMatching => 'Show matching sessions';

  @override
  String get dashboardLogout => 'Log out, asks to confirm';

  @override
  String get dashboardRefresh => 'Refresh sessions';

  @override
  String get dashboardLibraryWhat => 'recorded audio library';

  @override
  String get dashboardQuizzesWhat => 'quizzes';

  @override
  String dashboardSessions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sessions',
      one: '1 session',
    );
    return '$_temp0';
  }

  @override
  String dashboardPosition(String index, String total) {
    return '$index of $total';
  }

  @override
  String get dashboardStudentScreen => 'Student Dashboard';

  @override
  String get dashboardStudentLoading => 'Student dashboard is loading';

  @override
  String get dashboardStudentSections =>
      'refresh, session search, live sessions, recorded lessons, playlists, quizzes, learning journeys, and log out';

  @override
  String get dashboardNoLiveSessions =>
      'No live sessions right now. Press 1 to refresh.';

  @override
  String get dashboardNoFilterMatch => 'No sessions match your filter.';

  @override
  String get dashboardNoMatchVisible =>
      'No matching sessions. Clear the search or change the subject filter.';

  @override
  String dashboardAvailable(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sessions available.',
      one: '1 session available.',
    );
    return '$_temp0';
  }

  @override
  String dashboardAvailableDetailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sessions available. Use down to browse.',
      one: '1 session available. Use down to browse.',
    );
    return '$_temp0';
  }

  @override
  String dashboardRefreshFailed(String reason) {
    return '$reason Press 1 to try again.';
  }

  @override
  String get dashboardJoining => 'Joining session.';

  @override
  String dashboardJoined(String session) {
    return 'Joined $session.';
  }

  @override
  String get dashboardOpeningPlaylists =>
      'Opening My Playlists. These playlists are private.';

  @override
  String get dashboardSessionSearchHelp =>
      'Session search. Press OK to type a session number, then go down to Show matching sessions and press OK. You can also search by name.';

  @override
  String get dashboardSessionNumberFieldEmpty =>
      'Session number field. Type a number, then choose Show matching sessions';

  @override
  String dashboardSessionNumberField(String digits) {
    return 'Session number field, $digits';
  }

  @override
  String get dashboardNameField => 'Search sessions by name';

  @override
  String dashboardNoSessionNumber(String digits) {
    return 'No live session number $digits.';
  }

  @override
  String dashboardFound(String label) {
    return 'Found: $label. Press OK to join.';
  }

  @override
  String dashboardNoNameMatch(String query) {
    return 'No sessions match $query.';
  }

  @override
  String dashboardShowingAll(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Showing all $count sessions.',
      one: 'Showing all 1 session.',
    );
    return '$_temp0';
  }

  @override
  String dashboardShowingAllDetailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Showing all $count sessions. Use down to browse.',
      one: 'Showing all 1 session. Use down to browse.',
    );
    return '$_temp0';
  }

  @override
  String dashboardNameMatches(int count, String query) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sessions match $query. Use down to browse.',
      one: '1 session match $query. Use down to browse.',
    );
    return '$_temp0';
  }

  @override
  String get dashboardAllSubjects => 'all subjects';

  @override
  String dashboardSubjectFilterLabel(String subject, String position) {
    return 'Subject filter: $subject, $position. Use left or right to change';
  }

  @override
  String dashboardSubjectFilterChanged(
    String subject,
    String position,
    String summary,
  ) {
    return 'Subject filter: $subject, $position. $summary';
  }

  @override
  String get dashboardLibrary => 'Recorded audio library';

  @override
  String get dashboardPlaylists => 'My private playlists';

  @override
  String get dashboardQuizzes => 'Quizzes';

  @override
  String get dashboardStudentJourneys =>
      'Learning journeys: listen, answer and repeat, works offline';

  @override
  String dashboardTeacherName(String name) {
    return 'Teacher $name';
  }

  @override
  String get dashboardLiveNow => 'live now';

  @override
  String get dashboardStateRefreshing => 'Refreshing.';

  @override
  String dashboardStateLiveSessions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count live sessions.',
      one: '1 live session.',
    );
    return '$_temp0';
  }

  @override
  String dashboardStateSubjectFilter(String subject) {
    return 'Subject filter: $subject.';
  }

  @override
  String dashboardStateSessionNumber(String digits) {
    return 'Session number typed: $digits.';
  }

  @override
  String dashboardStateNameSearch(String query) {
    return 'Name search: $query.';
  }

  @override
  String dashboardStateShown(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sessions shown.',
      one: '1 session shown.',
    );
    return '$_temp0';
  }

  @override
  String get dashboardTeacherScreen => 'Teacher Dashboard';

  @override
  String get dashboardTeacherLoading => 'Teacher dashboard is loading';

  @override
  String get dashboardTeacherSections =>
      'class and subject selection, teaching tools, session search, and active or ended sessions';

  @override
  String get dashboardNoSessionsYet =>
      'No sessions yet. Press 2 to create one.';

  @override
  String get dashboardNoTeacherMatch =>
      'No matching sessions. Clear the search to list all sessions.';

  @override
  String dashboardTeacherCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sessions.',
      one: '1 session.',
    );
    return '$_temp0';
  }

  @override
  String dashboardTeacherCountLive(int count, String live) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sessions, $live live now.',
      one: '1 session, $live live now.',
    );
    return '$_temp0';
  }

  @override
  String dashboardNotRefreshed(String reason) {
    return '$reason Sessions were not refreshed. Press 1 to try again.';
  }

  @override
  String get dashboardNoAssignment =>
      'No class and subject is assigned to you. Ask an administrator to assign one.';

  @override
  String get dashboardCreatingSession => 'Creating session';

  @override
  String dashboardCreated(String title) {
    return 'Session $title created.';
  }

  @override
  String get dashboardCreatedTitle => 'Session created';

  @override
  String dashboardStartNow(String title) {
    return 'Do you want to start \"$title\" now?';
  }

  @override
  String get dashboardRequestFailed =>
      'We could not complete that request. Check your connection and try again.';

  @override
  String get dashboardOpeningSession => 'Opening session.';

  @override
  String dashboardWorkspace(String className, String subject) {
    return '$className, $subject';
  }

  @override
  String dashboardWorkspaceSelected(
    String name,
    String position,
    String status,
  ) {
    return 'Workspace: $name, $position. $status';
  }

  @override
  String dashboardWorkspaceChosen(String name, String status) {
    return '$name selected. $status Press 7 to choose another workspace.';
  }

  @override
  String get dashboardChooseWorkspaceTitle => 'Choose class and subject';

  @override
  String get dashboardNoWorkspace => 'No class and subject workspace assigned';

  @override
  String dashboardWorkspaceLabel(String name, String position) {
    return 'Workspace: $name, $position. Left or right to change, OK or 7 for a numbered list';
  }

  @override
  String get dashboardCreate => 'Create new session';

  @override
  String get dashboardClassPlaylists => 'Class playlists';

  @override
  String get dashboardTeacherJourneys =>
      'Learning journeys: recordings, questions and polls in one flow';

  @override
  String get dashboardTeacherQuizzes => 'Quizzes and private question bank';

  @override
  String get dashboardOfflineLibrary => 'Offline audio library';

  @override
  String get dashboardSearchField =>
      'Search sessions. Press OK, then type a name or the session number';

  @override
  String get dashboardTeacherSearchHelp =>
      'Session search. Press OK to edit, then type a session name, or the session number using the number keys. Use up or down to leave the field and browse results.';

  @override
  String dashboardTeacherNoMatch(String query) {
    return 'No sessions match $query. Clear the search to list all sessions.';
  }

  @override
  String get dashboardEnded => 'ended';

  @override
  String dashboardJoinedCount(String count) {
    return '$count joined';
  }

  @override
  String get dashboardPressOkToOpen => 'Press OK to open';

  @override
  String get dashboardPressOkToReactivate => 'Press OK to reactivate';

  @override
  String dashboardEndLabel(String title) {
    return 'End $title for everyone, asks to confirm';
  }

  @override
  String dashboardDeleteLabel(String title) {
    return 'Delete ended session $title permanently, asks to confirm';
  }

  @override
  String get dashboardEndTitle => 'End session for everyone?';

  @override
  String dashboardEndMessage(String title) {
    return 'End \"$title\" and close it for every participant? The session will remain in your dashboard history.';
  }

  @override
  String get dashboardEndedForEveryone =>
      'Session ended for everyone and kept in session history.';

  @override
  String get dashboardEndFailed =>
      'The session could not be ended. Please try again.';

  @override
  String get dashboardReactivateTitle => 'Reactivate session?';

  @override
  String dashboardReactivateMessage(String title) {
    return 'Reactivate \"$title\" so participants can join it again?';
  }

  @override
  String get dashboardReactivated => 'Session reactivated.';

  @override
  String get dashboardReactivateFailed =>
      'The session could not be reactivated. Please try again.';

  @override
  String get dashboardOpenNowTitle => 'Open session now?';

  @override
  String dashboardOpenNowMessage(String title) {
    return '\"$title\" is active again. Open it now, or return to it later from the dashboard.';
  }

  @override
  String get dashboardDeleteTitle => 'Permanently delete session?';

  @override
  String dashboardDeleteMessage(String title) {
    return 'Permanently delete \"$title\", including its participants, chat, and logs? This cannot be undone.';
  }

  @override
  String get dashboardDeleted => 'Session permanently deleted.';

  @override
  String get dashboardDeleteFailed =>
      'The session could not be deleted. Please try again.';

  @override
  String get dashboardStateNoWorkspace => 'No workspace chosen.';

  @override
  String dashboardStateWorkspace(String name) {
    return 'Workspace: $name.';
  }

  @override
  String dashboardActiveSessions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count active sessions',
      one: '1 active session',
    );
    return '$_temp0';
  }

  @override
  String dashboardStateTotals(String active, String total) {
    return '$active, $total in total.';
  }

  @override
  String dashboardStateSearch(String query) {
    return 'Search: $query.';
  }

  @override
  String get adminSaveFailed =>
      'The change could not be saved. Press 1 to refresh, then try again.';

  @override
  String adminChoiceLabel(String what, String name, String position) {
    return '$what: $name, $position. Use left or right to change';
  }

  @override
  String adminChoiceLabelSingle(String what, String name) {
    return '$what: $name. Use left or right to change';
  }

  @override
  String adminChoiceChanged(String name, String position) {
    return '$name, $position.';
  }

  @override
  String adminChoiceChangedSingle(String name) {
    return '$name.';
  }

  @override
  String adminClassAndSubject(String className, String subject) {
    return '$className selected. $subject subject selected.';
  }

  @override
  String get adminNoSubjects => 'The selected class has no active subjects.';

  @override
  String adminStateSection(String section) {
    return 'Section: $section.';
  }

  @override
  String adminStateShown(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items shown.',
      one: '1 item shown.',
    );
    return '$_temp0';
  }

  @override
  String adminStateFilter(String filter) {
    return 'Filter: $filter.';
  }

  @override
  String adminStateSearch(String query) {
    return 'Search: $query.';
  }

  @override
  String get adminNoSubjectName =>
      'No subject name entered. Nothing was created.';

  @override
  String get adminNoClassName => 'No class name entered. Nothing was created.';

  @override
  String get adminNoActiveSubjects => 'This class has no active subjects.';

  @override
  String get adminListReadFailed =>
      'The administration list could not be read.';

  @override
  String adminNotRefreshed(String reason) {
    return '$reason Administration data was not refreshed. Press 1 to retry.';
  }

  @override
  String adminExploreIntro(String sections) {
    return 'Use D-pad up and down to explore $sections. Press OK to select.';
  }

  @override
  String adminSectionTitle(String section) {
    return 'Administration. $section section';
  }

  @override
  String get adminSectionNameAccounts => 'accounts';

  @override
  String get adminSectionNameClasses => 'classes';

  @override
  String get adminSectionNameSubjects => 'subjects';

  @override
  String get adminNoMatchingAccounts =>
      'No matching accounts. Change the search or filters.';

  @override
  String adminNoMatchingAccountsFor(String search) {
    return 'No matching accounts for $search. Change the search or filters.';
  }

  @override
  String adminClasses(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count classes',
      one: '1 class',
    );
    return '$_temp0';
  }

  @override
  String adminSubjects(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count subjects',
      one: '1 subject',
    );
    return '$_temp0';
  }

  @override
  String adminAccountsSummary(int count, String classes, String subjects) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count accounts. $classes and $subjects.',
      one: '1 account. $classes and $subjects.',
    );
    return '$_temp0';
  }

  @override
  String adminAccountsSummarySearch(
    int count,
    String search,
    String classes,
    String subjects,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count accounts match $search. $classes and $subjects.',
      one: '1 account match $search. $classes and $subjects.',
    );
    return '$_temp0';
  }

  @override
  String adminClassesSentence(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count classes.',
      one: '1 class.',
    );
    return '$_temp0';
  }

  @override
  String adminSubjectsSentence(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count subjects.',
      one: '1 subject.',
    );
    return '$_temp0';
  }

  @override
  String get adminNavigationAccounts =>
      'account search, account type and enrollment filters, and account management. Use left or right on a filter to change it';

  @override
  String get adminNavigationClasses =>
      'create class and the list of active or archived classes. Press OK on a class for its subject assignments and archive or restore actions';

  @override
  String get adminNavigationSubjects =>
      'create subject and the list of active or archived subjects. Press OK on a subject to archive or restore it';

  @override
  String get adminSectionsTitle => 'Administration sections';

  @override
  String get adminSectionAccounts => 'Accounts and enrollment';

  @override
  String get adminSectionClasses => 'Classes and their subjects';

  @override
  String get adminSectionSubjects => 'Subjects';

  @override
  String adminSectionChosen(String section) {
    return '$section section.';
  }

  @override
  String adminSectionExplore(String what) {
    return 'Use the D-pad to explore $what. Press 7 to change section.';
  }

  @override
  String get adminExploreAccounts =>
      'account filters, search and account management';

  @override
  String get adminExploreClasses =>
      'class creation, subject assignments, and archive or restore actions';

  @override
  String get adminExploreSubjects =>
      'subject creation and archive or restore actions';

  @override
  String adminRoleFilterSelected(String label) {
    return 'Account type filter: $label, selected.';
  }

  @override
  String adminAssignmentFilterSelected(String label) {
    return 'Assignment filter: $label, selected.';
  }

  @override
  String get adminRoleFilterStudents => 'Students only';

  @override
  String get adminRoleFilterTeachers => 'Teachers only';

  @override
  String get adminRoleFilterAll => 'All registered accounts';

  @override
  String get adminAssignmentEnrolled => 'Enrolled';

  @override
  String get adminAssignmentAssigned => 'Assigned';

  @override
  String get adminAssignmentEnrolledOrAssigned => 'Enrolled or assigned';

  @override
  String get adminAssignmentUnassigned => 'Unassigned';

  @override
  String get adminAssignmentAll => 'All assignment states';

  @override
  String get adminRoleStudent => 'student';

  @override
  String get adminRoleTeacher => 'teacher';

  @override
  String get adminNoClassAssigned => 'No class assigned';

  @override
  String adminAssignmentCount(String count) {
    return '$count assignments';
  }

  @override
  String adminAccountLabel(String name, String role, String access) {
    return '$name, $role. $access. Press OK to manage';
  }

  @override
  String get adminCancel => 'Cancel';

  @override
  String get adminSave => 'Save';

  @override
  String get adminCreateSubjectTitle => 'Create subject';

  @override
  String get adminSubjectNameField => 'Subject name';

  @override
  String adminSubjectCreated(String name) {
    return 'Subject $name created';
  }

  @override
  String get adminCreateClassTitle => 'Create class';

  @override
  String get adminClassNameField => 'Class name';

  @override
  String adminClassCreated(String name) {
    return 'Class $name created';
  }

  @override
  String get adminArchiveClassTitle => 'Archive class?';

  @override
  String get adminRestoreClassTitle => 'Restore class?';

  @override
  String adminArchiveItemMessage(String name) {
    return 'New sessions, audio, and assignments cannot use $name while it is archived.';
  }

  @override
  String adminRestoreItemMessage(String name) {
    return '$name will become available for assignments again.';
  }

  @override
  String get adminArchive => 'Archive';

  @override
  String get adminRestore => 'Restore';

  @override
  String get adminClassArchived => 'Class archived';

  @override
  String get adminClassRestored => 'Class restored';

  @override
  String adminManageTitle(String name) {
    return 'Manage $name';
  }

  @override
  String get adminManageClassSubjects => 'Manage class subjects';

  @override
  String get adminArchiveClassChoice => 'Archive class with confirmation';

  @override
  String get adminRestoreClassChoice => 'Restore class with confirmation';

  @override
  String adminSubjectsForClass(String name) {
    return 'Subjects for $name';
  }

  @override
  String adminSubjectRemovedFrom(String name) {
    return 'Subject removed from $name';
  }

  @override
  String adminSubjectAddedTo(String name) {
    return 'Subject added to $name';
  }

  @override
  String get adminArchiveSubjectTitle => 'Archive subject?';

  @override
  String get adminRestoreSubjectTitle => 'Restore subject?';

  @override
  String get adminSubjectArchived => 'Subject archived';

  @override
  String get adminSubjectRestored => 'Subject restored';

  @override
  String get adminManageAssignments => 'Manage assignments';

  @override
  String get adminPasswordRecovery => 'Password recovery';

  @override
  String adminManageUserScreen(String name) {
    return 'Manage $name. Choose assignments, password recovery, or Cancel.';
  }

  @override
  String get adminRecoveryNeedsVersion =>
      'Account recovery requires a current server version. Refresh the account.';

  @override
  String get adminNoActiveClasses =>
      'No active classes. Create or restore a class in the classes section first.';

  @override
  String get adminTheCurrentClass => 'the current class';

  @override
  String adminAssignClassTo(String name) {
    return 'Assign class to $name';
  }

  @override
  String get adminAssign => 'Assign';

  @override
  String get adminRemoveClass => 'Remove class';

  @override
  String get adminClassField => 'Class';

  @override
  String adminRemoveStudentLabel(String name, String className) {
    return 'Remove $name from $className, asks to confirm';
  }

  @override
  String adminAssignStudentLabel(String name) {
    return 'Assign $name to the selected class';
  }

  @override
  String get adminRemoveFromClassTitle => 'Remove from class?';

  @override
  String adminRemoveFromClassMessage(String name, String className) {
    return 'Remove $name from $className? They will no longer see that class until assigned again.';
  }

  @override
  String get adminKeepInClass => 'Keep in class';

  @override
  String get adminRemoveFromClass => 'Remove from class';

  @override
  String adminStudentRemovedFromClass(String name) {
    return '$name removed from class';
  }

  @override
  String adminStudentAssignedTo(String name, String className) {
    return '$name assigned to $className';
  }

  @override
  String adminAssignTeacherScreen(String name) {
    return 'Assign $name to a class and subject';
  }

  @override
  String adminRemoveAssignmentLabel(
    String name,
    String className,
    String subject,
  ) {
    return 'Remove $name from $className, $subject, asks to confirm';
  }

  @override
  String get adminSubjectField => 'Subject';

  @override
  String get adminSaveAssignment => 'Save assignment';

  @override
  String get adminTeacherAssignmentSaved => 'Teacher assignment saved';

  @override
  String get adminRemoveAssignmentTitle => 'Remove assignment?';

  @override
  String adminRemoveAssignmentMessage(
    String name,
    String className,
    String subject,
  ) {
    return 'Remove $name from $className, $subject?';
  }

  @override
  String get adminKeep => 'Keep';

  @override
  String get adminRemove => 'Remove';

  @override
  String get adminTeacherAssignmentRemoved => 'Teacher assignment removed';

  @override
  String get adminRefreshData => 'Refresh admin data';

  @override
  String get adminLogout => 'Log out, asks to confirm';

  @override
  String adminSectionButton(String section) {
    return '$section section. Change administration section';
  }

  @override
  String get adminSearchAccounts =>
      'Search accounts by name or phone number. Press OK to type';

  @override
  String adminRoleFilterLabel(String label) {
    return 'Account type filter: $label, selected. Use left or right to change';
  }

  @override
  String adminAssignmentFilterLabel(String label) {
    return 'Assignment filter: $label, selected. Use left or right to change';
  }

  @override
  String adminClassActiveLabel(String name) {
    return '$name, active. Press OK for class subjects and archive or restore actions';
  }

  @override
  String adminClassArchivedLabel(String name) {
    return '$name, archived. Press OK for class subjects and archive or restore actions';
  }

  @override
  String adminSubjectActiveLabel(String name) {
    return '$name, active. Press OK to archive';
  }

  @override
  String adminSubjectArchivedLabel(String name) {
    return '$name, archived. Press OK to restore';
  }

  @override
  String adminSubjectInClass(String name) {
    return '$name. Available in this class. Select to remove';
  }

  @override
  String adminSubjectNotInClass(String name) {
    return '$name. Not available in this class. Select to add';
  }

  @override
  String get teacherHomeLater => 'Later';

  @override
  String get teacherHomeStartNow => 'Start now';

  @override
  String get teacherHomeChooseWorkspaceTitle => 'Choose class and subject';

  @override
  String teacherHomeWorkspaceItem(String className, String subjectName) {
    return '$className, $subjectName';
  }

  @override
  String teacherHomeWorkspaceChosen(
    String className,
    String subjectName,
    String status,
  ) {
    return '$className, $subjectName selected. $status. Press 7 to choose another workspace.';
  }

  @override
  String get teacherHomeUntitledSession => 'Untitled session';

  @override
  String get teacherHomeUntitledSessionTitle => 'Untitled Session';

  @override
  String get teacherHomeSessionFallback => 'session';

  @override
  String get teacherHomeSearchLabel =>
      'Search sessions. Press OK, then type a name or the session number';

  @override
  String get teacherHomeKeepSessionOpen => 'Keep session open';

  @override
  String get teacherHomeEndForEveryone => 'End for everyone';

  @override
  String get teacherHomeKeepEnded => 'Keep ended';

  @override
  String get teacherHomeReactivate => 'Reactivate';

  @override
  String get teacherHomeOpenLater => 'Open later';

  @override
  String get teacherHomeOpenNow => 'Open now';

  @override
  String get teacherHomeKeepSession => 'Keep session';

  @override
  String get teacherHomeDeletePermanently => 'Delete permanently';

  @override
  String get teacherHomeNewSessionTitle => 'New Session';

  @override
  String get teacherHomeCreateScreen => 'Create new session';

  @override
  String get teacherHomeCreateSessionKey => 'Create session';

  @override
  String get teacherHomeTitleField => 'Session title field';

  @override
  String get teacherHomeCancelCreate => 'Cancel session creation';

  @override
  String get studentHomeSearchHelp =>
      'Session search. Type a session number with the keypad, or move down to search by name. Press OK to edit. Use down to browse results.';

  @override
  String studentHomeSubjectFallback(String id) {
    return 'Subject $id';
  }

  @override
  String get studentHomeUntitledSession => 'Untitled session';

  @override
  String studentHomeSessionJoinLabel(String session) {
    return '$session. Press OK to join';
  }

  @override
  String get inviteNoStudentsEnrolled =>
      'No students are enrolled in this class. Press 1 to refresh.';

  @override
  String inviteLoadedSummary(int count, String invited) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count students, $invited invited.',
      one: '1 student, $invited invited.',
    );
    return '$_temp0';
  }

  @override
  String get inviteUseSearch => 'Use the search field to find a name.';

  @override
  String get inviteLoadFailed =>
      'Could not load students. Check your connection and press 1 to try again.';

  @override
  String inviteAlreadyInvited(String name) {
    return '$name is already invited.';
  }

  @override
  String inviteInvitedOne(String name) {
    return 'Invited $name.';
  }

  @override
  String inviteOneFailed(String name) {
    return 'Could not invite $name. Check your connection and press OK to try again.';
  }

  @override
  String get inviteNoStudentsToInvite => 'There are no students to invite.';

  @override
  String get inviteAllAlreadyInvited => 'All students are already invited.';

  @override
  String inviteInvitingAll(String count) {
    return 'Inviting $count students. Please wait.';
  }

  @override
  String inviteProgress(String done, String total) {
    return 'Inviting students: $done of $total done.';
  }

  @override
  String inviteAllDone(String count) {
    return 'Invited all $count students.';
  }

  @override
  String invitePartialFailed(String invited, String total, String names) {
    return 'Invited $invited of $total students. Could not invite $names. Press 2 to try again.';
  }

  @override
  String inviteShowingAll(String count) {
    return 'Showing all $count students.';
  }

  @override
  String inviteNoMatch(String query) {
    return 'No students match $query. Clear the search to list everyone.';
  }

  @override
  String inviteMatches(int count, String query) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count students match $query. Use down to browse.',
      one: '1 student matches $query. Use down to browse.',
    );
    return '$_temp0';
  }

  @override
  String inviteStudentInvited(String name) {
    return '$name, invited';
  }

  @override
  String inviteStudentNotInvited(String name) {
    return '$name, not invited. Press OK to invite';
  }

  @override
  String get inviteBackToSession => 'Back to session';

  @override
  String get inviteRefreshList => 'Refresh student list';

  @override
  String get inviteAllStudents => 'Invite all students';

  @override
  String get inviteSearchLabel =>
      'Search students by name or phone number. Press OK to type';

  @override
  String inviteScreenName(String title) {
    return 'Invite students to $title';
  }

  @override
  String get inviteKeyBack => 'Back to Session';

  @override
  String get inviteKeyRefresh => 'Refresh Students';

  @override
  String get inviteKeyInviteAll => 'Invite All';

  @override
  String get notificationTitleSessionInvitation => 'Live class';

  @override
  String get notificationTitleJourneyPublished => 'New learning journey';

  @override
  String get notificationTitleQuizPublished => 'New quiz';

  @override
  String get notificationTitleQuizReminder => 'Quiz reminder';

  @override
  String get notificationTitleDefault => 'SEEDS update';

  @override
  String get notificationArrivedSessionInvitation =>
      'Your teacher started a class. Press 1 to join, or 0 for not now.';

  @override
  String get notificationArrivedJourneyPublished =>
      'Your teacher shared a new learning journey. Press 1 to open it, or 0 for not now.';

  @override
  String get notificationArrivedQuizPublished =>
      'Your teacher published a new quiz. Press 1 to open your quizzes, or 0 for not now.';

  @override
  String get notificationArrivedQuizReminder =>
      'Reminder: you have a quiz to take. Press 1 to open your quizzes, or 0 for not now.';

  @override
  String get notificationArrivedDefault =>
      'You have a new update. Press 0 to go back.';

  @override
  String get notificationForegroundSessionInvitation =>
      'Your teacher started a class. Join it from Live sessions on your dashboard.';

  @override
  String get notificationForegroundJourneyPublished =>
      'Your teacher shared a new learning journey. Find it under Learning journeys.';

  @override
  String get notificationForegroundQuizPublished =>
      'Your teacher published a new quiz.';

  @override
  String get notificationForegroundQuizReminder =>
      'Reminder: you have a quiz to take.';

  @override
  String get notificationForegroundDefault => 'You have a new update.';

  @override
  String get notificationOpenJoinClass => 'Join class';

  @override
  String get notificationOpenJourney => 'Open journey';

  @override
  String get notificationOpenQuizzes => 'Open quizzes';

  @override
  String get notificationOpenBack => 'Back';

  @override
  String get notificationCannotOpen =>
      'This could not be opened. Sign in again, then open it from your dashboard.';

  @override
  String get authLoginSuccessful => 'Login successful';

  @override
  String authRoleAlreadySelected(String role) {
    return '$role account already selected';
  }

  @override
  String authRoleSelected(String role) {
    return '$role account selected';
  }

  @override
  String authRecoveryStep(String number, String step) {
    return 'Step $number. $step';
  }

  @override
  String get authEnterPhone => 'Enter phone number';

  @override
  String get authEnterPassword => 'Enter password';

  @override
  String get authEnterName => 'Enter name';

  @override
  String get authRegistering => 'Registering, please wait.';

  @override
  String get authPasswordChanged => 'Password changed. Signed in.';

  @override
  String journeyWhereFinished(String title) {
    return 'Journey finished. $title.';
  }

  @override
  String journeyWhere(String number, String total, String kind, String title) {
    return 'Step $number of $total. $kind. $title.';
  }

  @override
  String journeyWhereReplaying(
    String number,
    String total,
    String kind,
    String title,
  ) {
    return 'Step $number of $total. $kind. $title. Listening again before the question.';
  }

  @override
  String get journeyKindRecording => 'Recording';

  @override
  String get journeyKindNarration => 'Narration';

  @override
  String get journeyKindQuestion => 'Question';

  @override
  String get journeyKindPoll => 'Poll';

  @override
  String journeyOption(String number, String text) {
    return 'Option $number: $text.';
  }

  @override
  String journeyChooseKeys(String count) {
    return 'Press 1 to $count to choose, then 5 to submit.';
  }

  @override
  String journeyPollQuestion(String question, String options, String keys) {
    return 'Poll. There is no wrong answer. $question $options $keys';
  }

  @override
  String journeyQuestion(String question, String options, String keys) {
    return 'Question. $question $options $keys';
  }

  @override
  String journeyQuestionTryAgain(
    String triesLeft,
    String question,
    String options,
    String keys,
  ) {
    return 'Question. Try again. $triesLeft $question $options $keys';
  }

  @override
  String journeyTriesLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tries left.',
      one: '1 try left.',
    );
    return '$_temp0';
  }

  @override
  String journeyChosen(String number, String option) {
    return 'Option $number, $option, selected. Press 5 to submit, or choose another number.';
  }

  @override
  String journeyRecordingContent(String title) {
    return 'Recording: $title. Press 5 to pause or play. Press 2 when you are ready to move on.';
  }

  @override
  String get journeyUntitled => 'Untitled';

  @override
  String get journeyContentKeys =>
      'Press 2 for the next step, 3 to repeat this step, 1 to hear where you are, 8 to go back to the previous recording or narration.';

  @override
  String journeyCorrect(String answer) {
    return 'Correct! $answer.';
  }

  @override
  String get journeyPollSaved => 'Thank you. Your answer is saved.';

  @override
  String get journeyReplayOutcome =>
      'Not quite. Let us listen to that part again, then try once more.';

  @override
  String get journeyTryAgainOutcome =>
      'Not quite. Think again and choose another answer.';

  @override
  String journeyRevealed(String number, String answer, String explanation) {
    return 'Not quite. The answer is option $number, $answer. $explanation';
  }

  @override
  String journeyWellDone(String title) {
    return 'Well done! You finished $title.';
  }

  @override
  String journeyFirstTryScore(int questions, String correct) {
    String _temp0 = intl.Intl.pluralLogic(
      questions,
      locale: localeName,
      other:
          'You answered $correct of $questions questions correctly on the first try.',
      one: 'You answered $correct of 1 question correctly on the first try.',
    );
    return '$_temp0';
  }

  @override
  String get journeyPlayAgainHelp =>
      'Press 1 to play again, or 0 to go back to your journeys.';

  @override
  String get journeyStatusCompleted => 'Completed';

  @override
  String get journeyStatusInProgress => 'In progress';

  @override
  String get journeyStatusNew => 'New';

  @override
  String journeyRowScore(String percent) {
    return 'Score $percent percent.';
  }

  @override
  String get journeyRowDownloaded => 'Downloaded.';

  @override
  String journeyStudentRow(
    String title,
    String subject,
    String steps,
    String questions,
    String status,
  ) {
    return '$title. $subject. $steps steps, $questions questions. $status.';
  }

  @override
  String journeyTeacherRow(
    String title,
    String status,
    String steps,
    String questions,
  ) {
    return '$title. $status. $steps steps, $questions questions.';
  }

  @override
  String get journeyRowGraded => 'Graded.';

  @override
  String journeyStepRow(String number, String total, String name) {
    return 'Step $number of $total. $name.';
  }

  @override
  String get journeyReplaysAutomatically => 'Replays automatically.';

  @override
  String journeyReplaysFrom(String number) {
    return 'Replays from step $number.';
  }

  @override
  String get journeyFinishedStatus => 'Journey finished.';

  @override
  String get journeyRecordingPlaying => 'Recording playing.';

  @override
  String get journeyRecordingPaused => 'Recording paused.';

  @override
  String get journeyNoOptionChosen => 'No option chosen yet.';

  @override
  String journeyOptionSelected(String number, String option) {
    return 'Option $number, $option, selected.';
  }

  @override
  String journeyPreviewStart(String title) {
    return 'Preview of $title. Nothing is saved.';
  }

  @override
  String journeyWelcomeBack(String title) {
    return 'Welcome back to $title. Continuing where you left off.';
  }

  @override
  String journeyStartingBrief(String title) {
    return 'Starting $title.';
  }

  @override
  String journeyStartingDetailed(String title, String steps) {
    return 'Starting $title. $steps steps. Press star at any time for help.';
  }

  @override
  String journeyNotSaved(String reason) {
    return 'Your place could not be saved. $reason';
  }

  @override
  String get journeyListeningAgain => 'Listening again.';

  @override
  String journeyNarration(String text) {
    return '$text Press 2 to continue.';
  }

  @override
  String journeyRecordingStatus(String title) {
    return 'Recording: $title';
  }

  @override
  String get journeyRecordingFailed =>
      'This recording could not be played. Check your internet.';

  @override
  String get journeyRecordingRetry =>
      'Press 3 to try again, or 2 to skip to the next step.';

  @override
  String get journeyNotDownloaded =>
      'This recording is not downloaded on this phone.';

  @override
  String get journeyRecordingFinished => 'Recording finished.';

  @override
  String journeyAnswerFirst(String count) {
    return 'Answer first. Press 1 to $count to choose, then 5.';
  }

  @override
  String get journeyNoEarlierContent =>
      'There is no earlier recording or narration.';

  @override
  String get journeyGoingBack => 'Going back.';

  @override
  String journeyNoSuchOption(String option, String count) {
    return 'There is no option $option. Choose 1 to $count.';
  }

  @override
  String journeyChooseFirst(String count) {
    return 'Choose an answer first with 1 to $count.';
  }

  @override
  String get journeySendLater =>
      'Journey finished. Your answers will be sent when you are online.';

  @override
  String get journeyStartingAgain => 'Starting again.';

  @override
  String get journeyPaused => 'Paused.';

  @override
  String get journeySeekRecordingsOnly => 'Seeking works on recordings only.';

  @override
  String get journeySpeedRecordingsOnly =>
      'Recording speed changes on recordings only.';

  @override
  String get journeyFastest => 'Fastest speed.';

  @override
  String get journeySlowest => 'Slowest speed.';

  @override
  String journeySpeed(String rate) {
    return 'Recording speed $rate times.';
  }

  @override
  String get journeyLeaveTitle => 'Leave this journey?';

  @override
  String journeyLeaveMessage(String step) {
    return 'Your place is saved on this phone. Next time you can continue from step $step.';
  }

  @override
  String get journeyAnswerHelp =>
      'Press a number to choose, 5 to submit, 6 to repeat the question.';

  @override
  String journeyStepRemoved(String remaining) {
    return 'Step removed. The journey now has $remaining steps.';
  }

  @override
  String journeyStepRemovedUndo(String name) {
    return 'Removed $name.';
  }

  @override
  String get journeyStepRestored => 'Step restored.';

  @override
  String journeyCreated(String title) {
    return 'Created $title. Now add its first step.';
  }

  @override
  String get journeyNoStepAdded => 'No step was added.';

  @override
  String journeyPreviewSkips(String issues) {
    return 'Some steps are skipped in this preview. $issues';
  }

  @override
  String journeyDuplicated(String title) {
    return 'Created $title as a new draft. Find it under Drafts.';
  }

  @override
  String journeyArchiveMessage(String title) {
    return 'Students will no longer see $title. Results are kept. You can restore it later.';
  }

  @override
  String journeyRestoreMessage(String title) {
    return 'Students will see $title again.';
  }

  @override
  String get journeyArchived => 'Archived. Students no longer see it.';

  @override
  String get journeyRestored => 'Restored for students.';

  @override
  String journeyDeleteDraftMessage(String title) {
    return 'Delete $title permanently? Recordings stay in your library.';
  }

  @override
  String get journeyDraftDeleted => 'Draft deleted.';

  @override
  String get journeyNoRetriesLeft => 'Already no retries.';

  @override
  String get journeyMaxRetries => 'Five retries is the most.';

  @override
  String journeyPublished(String count) {
    return 'Published. Students can play it now. Notifications reached $count phones.';
  }

  @override
  String get journeyOptionUsed =>
      'That option is already used. Type a different option.';

  @override
  String get journeyNothingToReplay =>
      'There is no recording or narration before this question yet, so a wrong answer asks again. You can add content earlier and edit this later.';

  @override
  String get journeyBankEmpty =>
      'Your question bank for this class and subject is empty. Choose Write a new question instead.';

  @override
  String get journeyRecordViaNotes =>
      'Opening private notes. Record, review, then choose Publish to this class and subject. Come back with 0, and choose your new recording.';

  @override
  String get journeyNoRecordings =>
      'There are no audio files in this class and subject yet, so nothing was added. You are back on the previous screen. To add one, choose Recording again, then 2 to upload a recording file or 3 to record a new one.';

  @override
  String get journeyOpeningFiles =>
      'Opening the file chooser for an audio file.';

  @override
  String get journeyNoFile => 'No file chosen.';

  @override
  String get journeyUploading => 'Uploading. Please wait.';

  @override
  String get journeyUploadUnconfirmed =>
      'The upload was not confirmed. Check My recordings before trying again, to avoid a duplicate.';

  @override
  String journeyUploaded(String title) {
    return 'Uploaded $title.';
  }

  @override
  String get journeyStorageUnavailable => 'Journey storage is unavailable.';

  @override
  String get journeyNothingInProgress =>
      'There is no journey in progress. Press 2 for new journeys.';

  @override
  String get journeyTeacherUpdated =>
      'Your teacher updated this journey. Download it again to play the new version offline.';

  @override
  String journeyStartOverMessage(String title) {
    return 'Start $title again from step 1? Answers you already gave are still sent to your teacher.';
  }

  @override
  String journeyRemoveDownloadMessage(String title) {
    return 'Remove $title from this phone? Your place in the journey is kept. You can download it again with internet.';
  }

  @override
  String journeyDownloadRemoved(String title) {
    return 'Removed the download of $title.';
  }

  @override
  String journeyDownloading(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Downloading $count recordings. Press 0 to cancel.',
      one: 'Downloading 1 recording. Press 0 to cancel.',
    );
    return '$_temp0';
  }

  @override
  String journeyDownloaded(String title) {
    return 'Downloaded. You can play $title without internet.';
  }

  @override
  String get journeyCancellingDownload =>
      'Cancelling download. Saved recordings are kept.';

  @override
  String journeyStepDetailsQuestion(
    String name,
    String options,
    String number,
    String explanation,
  ) {
    return '$name $options Correct answer: option $number. $explanation';
  }

  @override
  String get journeyNoExplanation => 'No explanation.';

  @override
  String journeyExplanation(String text) {
    return 'Explanation: $text';
  }

  @override
  String journeyStepNameRecording(String title) {
    return 'Recording. $title';
  }

  @override
  String get journeyUntitledRecording => 'Untitled recording';

  @override
  String journeyStepNameNarration(String text) {
    return 'Narration. $text';
  }

  @override
  String journeyStepNameQuestion(String text) {
    return 'Question. $text';
  }

  @override
  String journeyStepNamePoll(String text) {
    return 'Poll. $text';
  }

  @override
  String get journeyStatusPublished => 'Published';

  @override
  String get journeyStatusArchived => 'Archived';

  @override
  String get journeyStatusDraft => 'Draft, not yet published';

  @override
  String journeyStatusWithChanges(String status) {
    return '$status, with unpublished changes';
  }

  @override
  String get journeyErrorChanged =>
      'This journey changed. Refresh and try again.';

  @override
  String get journeyErrorSignInExpired =>
      'Your sign-in expired. Sign in again.';

  @override
  String get journeyErrorPermission => 'You do not have permission to do that.';

  @override
  String get journeyErrorNotAvailable => 'This journey is no longer available.';

  @override
  String get journeyErrorInvalid =>
      'Some of the information could not be accepted. Check it and try again.';

  @override
  String get journeyErrorServer =>
      'The school server had a problem. Try again later.';

  @override
  String get journeyErrorRequestFailed =>
      'The request did not succeed. Try again.';

  @override
  String get journeyErrorResponseUnreadable =>
      'The server response could not be read. Refresh before trying again.';

  @override
  String get journeyErrorSavedUnreadable =>
      'The saved journey could not be read. Refresh before trying again.';

  @override
  String get journeyErrorListUnreadable =>
      'The journey list could not be read.';

  @override
  String get journeyErrorMismatch =>
      'The saved journey did not match. Refresh before trying again.';

  @override
  String get journeyErrorPreviewUnreadable =>
      'The journey preview could not be read.';

  @override
  String get journeyErrorRecordingsUnreadable =>
      'The recording list could not be read.';

  @override
  String get journeyErrorBankUnreadable =>
      'The question bank could not be read.';

  @override
  String get journeyErrorJourneyUnreadable => 'This journey could not be read.';

  @override
  String get journeyDownloadNeedsApp =>
      'Downloading for offline use needs the SEEDS Android app. In the browser, journeys play while you are online.';

  @override
  String get journeySignInFirst => 'Sign in before opening learning journeys.';

  @override
  String get journeyStorageUnavailableDevice =>
      'Journey storage is unavailable on this device.';

  @override
  String get journeyStorageFull =>
      'Journey storage is unavailable. Check free space and try again. Nothing was deleted.';

  @override
  String get journeyDownloadCancelled =>
      'Download cancelled. Recordings already saved are kept.';

  @override
  String journeyRecordingsSaved(String done, String total) {
    return '$done of $total recordings are saved.';
  }

  @override
  String get journeyLeaveJourney => 'Leave journey';

  @override
  String get journeyLeaveSaved => 'Leave journey. Your place is saved';

  @override
  String get journeyKeyPlayAgain => 'Play again';

  @override
  String get journeyKeySubmitAnswer => 'Submit answer';

  @override
  String get journeyKeyRepeatQuestion => 'Repeat question';

  @override
  String get journeyKeySlowerSpeech => 'Slower speech';

  @override
  String get journeyKeyWhereAmI => 'Where am I';

  @override
  String get journeyKeyFasterSpeech => 'Faster speech';

  @override
  String get journeyKeyNextStep => 'Next step';

  @override
  String get journeyKeyRepeatStep => 'Repeat this step';

  @override
  String get journeyKeyReadAgain => 'Read again';

  @override
  String get journeyKeyPreviousContent => 'Previous recording or narration';

  @override
  String journeyPreviewTitle(String title) {
    return 'Preview: $title';
  }

  @override
  String get journeyPositionFinished => 'Finished';

  @override
  String journeyStepPosition(String number, String total) {
    return 'Step $number of $total';
  }

  @override
  String journeySelectedLabel(String label) {
    return '$label, selected';
  }

  @override
  String get journeyResultsLoading => 'Results are loading.';

  @override
  String journeyResultsSummary(
    String completed,
    String eligible,
    String inProgress,
    String notStarted,
  ) {
    return '$completed of $eligible students finished. $inProgress in progress, $notStarted not started.';
  }

  @override
  String journeyResultsAverage(String percent) {
    return 'Average first-try score $percent percent.';
  }

  @override
  String get journeyResultFinished => 'Finished';

  @override
  String get journeyResultNotStarted => 'Not started';

  @override
  String journeyResultStudent(String name, String status) {
    return '$name. $status.';
  }

  @override
  String journeyResultFirstTime(String correct, String total) {
    return '$correct of $total right first time.';
  }

  @override
  String journeyResultWrongAnswers(String count) {
    return '$count wrong answers.';
  }

  @override
  String journeyResultQuestion(String number, String text, String answered) {
    return 'Step $number. $text. $answered answered.';
  }

  @override
  String journeyResultRate(String percent) {
    return '$percent percent right first time.';
  }

  @override
  String get journeyResultNoAnswers => 'No answers yet.';

  @override
  String journeyResultAverageTries(String attempts) {
    return 'Average $attempts tries.';
  }

  @override
  String journeyResultPoll(
    String number,
    String text,
    String answered,
    String options,
  ) {
    return 'Step $number. $text. $answered answered. $options.';
  }

  @override
  String get journeyResultsStudentsTitle => 'Students';

  @override
  String get journeyResultsQuestionsTitle => 'Questions';

  @override
  String get journeyResultsPollsTitle => 'Poll answers';

  @override
  String journeyResultsTitle(String title) {
    return 'Results: $title';
  }

  @override
  String get journeyResultsHearSummary => 'Hear class summary';

  @override
  String journeyResultsStudents(String count) {
    return 'Students, $count';
  }

  @override
  String journeyResultsQuestions(String count) {
    return 'Questions, $count. Shows which parts need teaching again';
  }

  @override
  String journeyResultsPolls(String count) {
    return 'Poll answers, $count';
  }

  @override
  String get journeyResultsRefresh => 'Refresh results';

  @override
  String get journeyResultsNoStudents => 'No students are in this class.';

  @override
  String get journeyResultsNoQuestions => 'This journey has no questions.';

  @override
  String get journeyResultsNoPolls => 'This journey has no polls.';

  @override
  String get journeyNarrationLabel =>
      'Words the phone reads aloud, for example: Let us hear about some food today';

  @override
  String journeyAddOptionTitle(String number) {
    return 'Add option $number?';
  }

  @override
  String journeyQuestionOptionsSoFar(String count) {
    return 'The question has $count options so far.';
  }

  @override
  String journeyPollOptionsSoFar(String count) {
    return 'The poll has $count options so far.';
  }

  @override
  String journeyAddOption(String number) {
    return 'Add option $number';
  }

  @override
  String get journeyNoMoreOptions => 'No more options, continue';

  @override
  String journeyOptionTitle(String number) {
    return 'Option $number';
  }

  @override
  String journeyTypeOption(String number) {
    return 'Type option $number';
  }

  @override
  String get journeyReplayAutoNone => 'Automatic: ask again without replaying';

  @override
  String journeyReplayAutoFrom(String number, String name) {
    return 'Automatic: replay from step $number, $name';
  }

  @override
  String get journeyAfterWrongTitle => 'After a wrong answer';

  @override
  String get journeyAfterWrongIntro =>
      'When a student answers wrongly, which part should play again before they try once more?';

  @override
  String get journeyReplayChooseStep => 'Choose a different step to replay';

  @override
  String get journeyReplayWhichStep => 'Replay from which step?';

  @override
  String journeyStepLabel(String number, String name) {
    return 'Step $number. $name';
  }

  @override
  String journeyReviewReplayFrom(String number) {
    return 'After a wrong answer, step $number plays again.';
  }

  @override
  String get journeyReviewReplayAuto =>
      'After a wrong answer, it replays automatically.';

  @override
  String get journeyCheckBeforeSaving => 'Check before saving';

  @override
  String get journeySaveStep => 'Save this step';

  @override
  String get journeyRestartStep => 'Start this step again';

  @override
  String get journeyQuestionLabel => 'Type the question students will hear';

  @override
  String get journeyWhichCorrect => 'Which option is correct?';

  @override
  String journeyCurrentlyCorrect(String number) {
    return 'Currently option $number is correct.';
  }

  @override
  String journeyOptionChoice(String number, String text) {
    return 'Option $number: $text';
  }

  @override
  String get journeyExplanationTitle => 'Explanation';

  @override
  String get journeyExplanationLabel =>
      'What students hear after the right answer is revealed';

  @override
  String get journeyPollQuestionTitle => 'Poll question';

  @override
  String get journeyPollQuestionLabel =>
      'A question with no wrong answer, for example: Have you eaten rice this week?';

  @override
  String get journeyQuestionBank => 'Question bank';

  @override
  String journeyBankQuestionLabel(String text, String count) {
    return '$text. $count options.';
  }

  @override
  String get journeyAddRecording => 'Add a recording';

  @override
  String get journeyChooseMyRecordings => 'Choose from my recordings';

  @override
  String get journeyUploadRecordingFile => 'Upload a recording file';

  @override
  String get journeyRecordNew => 'Record a new recording';

  @override
  String get journeyMyRecordings => 'My recordings';

  @override
  String get journeyRecordingName => 'Recording name';

  @override
  String get journeyRecordingNameLabel => 'Name for this recording';

  @override
  String journeyOptionalLabel(String label) {
    return '$label. Optional, leave empty to skip';
  }

  @override
  String get journeyNothingEntered =>
      'Nothing entered. Press OK on the field and type, or press 0 to go back.';

  @override
  String journeyTooLong(String max) {
    return 'Too long. Use at most $max characters.';
  }

  @override
  String get journeySkipped => 'Skipped.';

  @override
  String journeyYouEntered(String text) {
    return 'You entered: $text';
  }

  @override
  String get journeyMenuReady => 'Ready.';

  @override
  String get journeyMenuReadDetailsHelp => 'Press 8 to read details again.';

  @override
  String journeyMenuBackHelp(String back) {
    return 'Press 0 for $back. Press star for help.';
  }

  @override
  String journeyMenuNothingAssigned(String number) {
    return 'Nothing is assigned to $number.';
  }

  @override
  String get journeyMenuPleaseWait =>
      'Please wait. Still working. Press 0 to go back.';

  @override
  String get journeyMenuWorking => 'Working, please wait.';

  @override
  String get journeyMenuReadDetails => 'Read details again';

  @override
  String get journeyNoInternetDownloaded =>
      'No internet. Downloaded journeys still work. Press 5 for downloaded journeys.';

  @override
  String journeyWaitingToSend(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count finished journeys are waiting to be sent.',
      one: '1 finished journey is waiting to be sent.',
    );
    return '$_temp0';
  }

  @override
  String journeyStudentSummary(
    String newCount,
    String inProgress,
    String completed,
    String downloaded,
  ) {
    return '$newCount new, $inProgress in progress, $completed completed, $downloaded downloaded.';
  }

  @override
  String get journeyDownloadedJourneys => 'Downloaded journeys';

  @override
  String journeyDownloadedRow(String title, String steps) {
    return '$title. $steps steps. Downloaded.';
  }

  @override
  String get journeyOfflineReason =>
      'This needs internet. Press 5 for downloaded journeys.';

  @override
  String get journeyLearningJourneys => 'Learning journeys';

  @override
  String get journeyStudentIntro =>
      'Listen to stories and lessons, answer questions as you go, and repeat parts you need.';

  @override
  String get journeyContinueLast => 'Continue my last journey';

  @override
  String journeyNewJourneys(String count) {
    return 'New journeys, $count';
  }

  @override
  String get journeyNewJourneysTitle => 'New journeys';

  @override
  String get journeyNoNewJourneys => 'There are no new journeys.';

  @override
  String journeyInProgressCount(String count) {
    return 'In progress, $count';
  }

  @override
  String get journeyInProgressTitle => 'Journeys in progress';

  @override
  String get journeyNothingInProgressShort => 'Nothing is in progress.';

  @override
  String journeyCompletedCount(String count) {
    return 'Completed, $count';
  }

  @override
  String get journeyCompletedTitle => 'Completed journeys';

  @override
  String get journeyNoneCompleted => 'No journeys completed yet.';

  @override
  String journeyDownloadedCount(String count) {
    return 'Downloaded, $count';
  }

  @override
  String get journeyNothingDownloaded =>
      'Nothing is downloaded. Open a journey and choose Download.';

  @override
  String get journeyNoInternetNotDownloaded =>
      'No internet, and this journey is not downloaded.';

  @override
  String get journeyStartOverTitle => 'Start over?';

  @override
  String get journeyStartOver => 'Start over';

  @override
  String get journeyRemoveDownloadTitle => 'Remove download?';

  @override
  String get journeyRemoveDownload => 'Remove download';

  @override
  String journeySavedRecordings(String done, String total) {
    return 'Saved $done of $total recordings.';
  }

  @override
  String get journeyDownloadedOnPhone => 'Downloaded on this phone.';

  @override
  String get journeyNotDownloadedShort => 'Not downloaded.';

  @override
  String get journeyStartedThis => 'You have started this journey.';

  @override
  String get journeyWorksOffline => 'Downloaded. Works without internet.';

  @override
  String get journeyContinueJourney => 'Continue journey';

  @override
  String get journeyStartJourney => 'Start journey';

  @override
  String get journeyHearAbout => 'Hear about this journey';

  @override
  String get journeyDownloadOffline => 'Download to play without internet';

  @override
  String get journeyDownloadInProgress =>
      'A download is in progress. Press 0 to cancel it.';

  @override
  String get journeyStartFromBeginning => 'Start over from the beginning';

  @override
  String get journeyNotStartedYet => 'You have not started this journey yet.';

  @override
  String journeyLatestLoaded(String message) {
    return '$message The latest version is now loaded.';
  }

  @override
  String journeyTeacherSummary(
    String drafts,
    String published,
    String archived,
  ) {
    return '$drafts drafts, $published published, $archived archived.';
  }

  @override
  String get journeyNewJourneyTitle => 'New learning journey';

  @override
  String get journeyNameExample => 'Journey name, for example: Food around us';

  @override
  String get journeyRefreshFirst => 'Press 5 to refresh the list first.';

  @override
  String journeyTeacherIntro(String workspace) {
    return '$workspace. Build one flow of recordings, narration, questions and polls for students.';
  }

  @override
  String get journeyCreateNew => 'Create a new journey';

  @override
  String journeyDraftsCount(String count) {
    return 'Drafts, $count';
  }

  @override
  String get journeyDraftJourneys => 'Draft journeys';

  @override
  String get journeyNoDrafts => 'There are no drafts.';

  @override
  String journeyPublishedCount(String count) {
    return 'Published, $count';
  }

  @override
  String get journeyPublishedJourneys => 'Published journeys';

  @override
  String get journeyNothingPublished => 'Nothing is published yet.';

  @override
  String journeyArchivedCount(String count) {
    return 'Archived, $count';
  }

  @override
  String get journeyArchivedJourneys => 'Archived journeys';

  @override
  String get journeyNothingArchived => 'Nothing is archived.';

  @override
  String get journeyRefreshList => 'Refresh list';

  @override
  String journeyOverviewSummary(
    String status,
    String steps,
    String questions,
    String graded,
    String retries,
  ) {
    return '$status. $steps steps, $questions questions. $graded. $retries';
  }

  @override
  String get journeyGraded => 'Graded';

  @override
  String get journeyNotGraded => 'Not graded';

  @override
  String journeyRetriesPerQuestion(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count retries per question.',
      one: '1 retry per question.',
    );
    return '$_temp0';
  }

  @override
  String get journeySteps => 'Steps';

  @override
  String journeyAddStepTitle(String number) {
    return 'Add step $number';
  }

  @override
  String get journeyAddStepIntro =>
      'The new step goes at the end. You can move it later.';

  @override
  String get journeyChoiceRecording => 'Recording';

  @override
  String get journeyChoiceNarration => 'Narration read by the phone';

  @override
  String get journeyChoiceQuestion => 'Question';

  @override
  String get journeyChoicePoll => 'Poll, no wrong answer';

  @override
  String journeySavedAsStep(String number, String name) {
    return 'Saved as step $number. $name';
  }

  @override
  String get journeyAddQuestion => 'Add a question';

  @override
  String get journeyWriteNewQuestion => 'Write a new question';

  @override
  String get journeyChooseFromBank => 'Choose from my question bank';

  @override
  String get journeyHearAndEdit => 'Hear and edit steps';

  @override
  String get journeyNoStepsYet => 'There are no steps yet. Press 2 to add one.';

  @override
  String get journeyAddStep => 'Add a step';

  @override
  String get journeyPreviewAsStudent => 'Preview as a student';

  @override
  String get journeyAddStepFirst => 'Add a step first.';

  @override
  String get journeyPublishToStudents => 'Publish to students';

  @override
  String get journeyPublishChanges => 'Publish changes';

  @override
  String get journeyStudentResults => 'Student results';

  @override
  String get journeyMoreOptions => 'More options';

  @override
  String journeyStepSaved(String number) {
    return 'Step $number saved.';
  }

  @override
  String journeyMoved(String number, String total) {
    return 'Moved. This is now step $number of $total.';
  }

  @override
  String journeyRemoveStepTitle(String number) {
    return 'Remove step $number?';
  }

  @override
  String journeyRemoveStepMessage(String name) {
    return 'Remove $name? Recordings stay in your library. Questions that replayed this step will replay automatically instead.';
  }

  @override
  String get journeyRemoveStep => 'Remove step';

  @override
  String get journeyStepNotFound => 'Step not found';

  @override
  String get journeyStepWasRemoved =>
      'This step was removed. Press 0 to go back.';

  @override
  String get journeyHearStepInFull => 'Hear this step in full';

  @override
  String get journeyEditStep => 'Edit this step';

  @override
  String get journeyMoveEarlier => 'Move earlier';

  @override
  String get journeyAlreadyFirst => 'This is already the first step.';

  @override
  String get journeyMoveLater => 'Move later';

  @override
  String get journeyAlreadyLast => 'This is already the last step.';

  @override
  String get journeyRemoveThisStep => 'Remove this step';

  @override
  String get journeyRenameTitle => 'Rename journey';

  @override
  String get journeyNameLabel => 'Journey name';

  @override
  String journeyRenamed(String title) {
    return 'Renamed to $title.';
  }

  @override
  String get journeyArchiveTitle => 'Archive this journey?';

  @override
  String get journeyRestoreTitle => 'Restore this journey?';

  @override
  String get journeyArchive => 'Archive';

  @override
  String get journeyRestore => 'Restore';

  @override
  String get journeyDeleteDraftTitle => 'Delete this draft?';

  @override
  String get journeyDeleteDraft => 'Delete draft';

  @override
  String get journeyPublishFirst => 'Publish the journey first.';

  @override
  String get journeyRename => 'Rename';

  @override
  String get journeyGradingNowGraded => 'Grading and tries, now graded';

  @override
  String get journeyGradingNowNotGraded => 'Grading and tries, now not graded';

  @override
  String get journeyDuplicate => 'Duplicate as a new draft';

  @override
  String get journeyArchiveHide => 'Archive, hide from students';

  @override
  String get journeyRestoreForStudents => 'Restore for students';

  @override
  String get journeyDeleteThisDraft => 'Delete this draft';

  @override
  String get journeyGradedSummary =>
      'Graded: the first try at each question counts towards a score.';

  @override
  String get journeyNotGradedSummary =>
      'Not graded: questions are for practice only.';

  @override
  String journeyMoreTriesSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'After a wrong answer, a student gets $count more tries, with the content replayed first.',
      one:
          'After a wrong answer, a student gets 1 more try, with the content replayed first.',
    );
    return '$_temp0';
  }

  @override
  String get journeyGradingTitle => 'Grading and tries';

  @override
  String get journeyTurnGradingOff => 'Turn grading off';

  @override
  String get journeyTurnGradingOn => 'Turn grading on';

  @override
  String get journeyGradingIsOff => 'Grading is off.';

  @override
  String get journeyGradingIsOn => 'Grading is on.';

  @override
  String get journeyFewerTries => 'Fewer tries';

  @override
  String get journeyMoreTries => 'More tries';

  @override
  String get journeyLoadingSummary => 'Loading the summary.';

  @override
  String get journeyNoProblems => 'No problems.';

  @override
  String journeyProblems(String issues) {
    return 'Problems to fix before publishing: $issues';
  }

  @override
  String journeyThingsToCheck(String warnings) {
    return 'Things to check: $warnings';
  }

  @override
  String journeyPublishSummary(
    String title,
    String steps,
    String recordings,
    String narrations,
    String questions,
    String polls,
    String graded,
  ) {
    return '$title. $steps steps: $recordings recordings, $narrations narrations, $questions questions, $polls polls. $graded.';
  }

  @override
  String journeyPublishTitle(String title) {
    return 'Publish $title?';
  }

  @override
  String get journeyPublishMessage =>
      'All students in this class will be able to play and download it, and they will get a notification.';

  @override
  String get journeyPublishNow => 'Publish now';

  @override
  String get journeyPublishedShort => 'Published.';

  @override
  String get journeyReviewBeforePublishing => 'Review before publishing';

  @override
  String get journeyFixProblemsFirst =>
      'Fix the problems first. Press 8 to hear them.';

  @override
  String get journeyPreviewFirst => 'Preview as a student first';

  @override
  String undoOffer(String seconds) {
    return 'Press 1 within $seconds seconds to undo.';
  }

  @override
  String undoDone(String action) {
    return 'Undone. $action was reversed.';
  }

  @override
  String get undoFailed =>
      'Undo did not work. Check the item and add it again if needed.';

  @override
  String get uiBack => 'Back';

  @override
  String get uiCancel => 'Cancel';

  @override
  String get uiContinue => 'Continue';

  @override
  String get uiNotNow => 'Not now';

  @override
  String uiPressFor(String key, String action) {
    return 'Press $key for $action.';
  }

  @override
  String uiLabelUnavailable(String label) {
    return '$label, unavailable';
  }

  @override
  String get uiAlreadyHome => 'You are already home.';

  @override
  String uiNotAvailableNow(String label) {
    return '$label is not available right now.';
  }

  @override
  String uiListLoading(String title) {
    return 'Loading $title. Press 0 to go back.';
  }

  @override
  String uiListPage(String title, String number) {
    return '$title. Page $number.';
  }

  @override
  String uiListScreenName(String title, String number) {
    return '$title. Page $number';
  }

  @override
  String get uiListNoMatches => 'No matching items.';

  @override
  String get uiListHelp =>
      'Press 6 for list options, including refresh. Press 7 for the previous page. Press 8 to search all items. Press 9 for the next page. Press 0 to go back. Use D-pad up and down to move between items and page controls, and OK to select. Press star to repeat help. Press hash to stop speech.';

  @override
  String get uiListLoadFailed =>
      'This page could not be loaded. Press 6 for retry options. Your previous page is kept.';

  @override
  String get uiListLoadingWait =>
      'Loading. Please wait, or press 0 to go back.';

  @override
  String uiListNoItem(String number) {
    return 'No item is assigned to $number on this page.';
  }

  @override
  String get uiListFirstPage => 'This is the first page.';

  @override
  String get uiListLastPage => 'This is the last page.';

  @override
  String uiListSearchTitle(String title) {
    return 'Search $title';
  }

  @override
  String get uiListSearchLabel => 'Search all available items';

  @override
  String get uiListSearchTooLong => 'Use at most 200 characters for search.';

  @override
  String get uiListOptions => 'List options';

  @override
  String get uiListSearch => 'Search';

  @override
  String get uiListClearSearch => 'Clear search';

  @override
  String get uiListRefreshPage => 'Refresh this page';

  @override
  String get uiListRetry => 'Retry';

  @override
  String get uiListFilters => 'Filters';

  @override
  String get uiListPreviousPage => 'Previous page';

  @override
  String get uiListSearchAll => 'Search all items';

  @override
  String get uiListNextPage => 'Next page';

  @override
  String get uiListSections =>
      'items, list options, previous page, search, next page and back';

  @override
  String get uiWaitingConfirmation => 'Waiting for confirmation. Please wait.';

  @override
  String get uiFinishWord => 'Finish entering the current word, then press OK.';

  @override
  String get uiStepFailed =>
      'This step could not be completed. Your entry is kept. Try again.';

  @override
  String get uiPasswordVisible => 'Password is visible.';

  @override
  String get uiPasswordHidden => 'Password is hidden.';

  @override
  String uiTextStepScreen(String title, String label) {
    return '$title. $label. Editing. Press OK to finish, or use up or down to leave the field.';
  }

  @override
  String get uiShowOrHidePassword => 'Show or hide password';

  @override
  String get uiDateEnterNumbers =>
      'Enter a number in every date and time field.';

  @override
  String uiDateChooseValid(String from, String to) {
    return 'Choose a valid date from $from to $to.';
  }

  @override
  String get uiDateInvalid =>
      'Enter a valid date, an hour from 0 to 23, and a minute from 0 to 59.';

  @override
  String uiDateChoose(String from, String to) {
    return 'Choose a date from $from to $to.';
  }

  @override
  String uiRange(String from, String to) {
    return '$from to $to';
  }

  @override
  String get uiYear => 'Year';

  @override
  String get uiMonth => 'Month';

  @override
  String get uiDay => 'Day';

  @override
  String get uiHour => 'Hour';

  @override
  String get uiMinute => 'Minute';

  @override
  String uiDateFieldEmpty(String name, String range) {
    return '$name, $range, currently empty';
  }

  @override
  String uiDateFieldValue(String name, String range, String value) {
    return '$name, $range, currently $value';
  }

  @override
  String uiDateScreen(String from, String to) {
    return 'Set date and time in the phone\'s local time. Choose a date from $from to $to.';
  }

  @override
  String get uiSaveDateTime => 'Save date and time';

  @override
  String uiChoiceValue(String label, String value) {
    return '$label: $value';
  }

  @override
  String uiChoiceValuePosition(
    String label,
    String value,
    String position,
    String total,
  ) {
    return '$label: $value, $position of $total';
  }

  @override
  String uiChoiceChange(String description) {
    return '$description. Use left or right to change';
  }

  @override
  String get startupPreferencesFailed =>
      'Some preferences could not be loaded. Defaults are being used.';

  @override
  String get startupNotificationsTitle => 'Session notifications';

  @override
  String get startupNotificationsMessage =>
      'SEEDS uses notifications to tell you about session invitations and updates. You can continue using the app if you choose Not now.';

  @override
  String get startupEnableNotifications => 'Enable notifications';

  @override
  String get startupLoading => 'SEEDS is loading';

  @override
  String get startupWelcomeScreenName => 'Welcome to SEEDS';

  @override
  String get startupLoginButton => 'Login, button';

  @override
  String get startupRegisterButton => 'Register, button';

  @override
  String get startupSettingsButton => 'Settings, button';

  @override
  String get startupRepeatInstructionsButton => 'Repeat instructions, button';

  @override
  String get authSimAutofillOptional => 'SIM phone-number autofill is optional';

  @override
  String get authRegisteredNowLogIn =>
      'Registered. Now log in. Phone number field. Press star for help.';

  @override
  String get authSimUnavailableOnDevice =>
      'SIM suggestions are unavailable on this device. Enter the phone number manually.';

  @override
  String get authSimDialogTitle => 'Optional SIM autofill';

  @override
  String get authSimDialogMessage =>
      'Read optional phone-number suggestions from this device? You will choose a suggestion before it replaces the phone field. This does not verify who owns an account. SIM access is never required for login, registration, Wi-Fi, or joining a session.';

  @override
  String get authSimDialogConfirm => 'Read SIM suggestions';

  @override
  String get authSimAutofillSkipped =>
      'SIM autofill skipped. Enter the phone number manually.';

  @override
  String get authSimDetecting => 'Detecting SIM card...';

  @override
  String get authSimAutofillUnavailable =>
      'SIM autofill unavailable. Enter the phone number manually.';

  @override
  String get authSimNoneFound =>
      'No SIM card found. Enter the phone number manually.';

  @override
  String authSimCardsDetected(String count) {
    return '$count SIM cards detected. Please choose one.';
  }

  @override
  String get authSimSuggestionUnavailable =>
      'SIM suggestion unavailable. Enter the phone number manually.';

  @override
  String authSimOptionLabel(String number, String carrier) {
    return 'SIM $number, $carrier';
  }

  @override
  String get authSimUnknownCarrier => 'Unknown carrier';

  @override
  String get authSimSelectedFilled =>
      'Selected suggestion filled. This is not proof of account ownership.';

  @override
  String get authSimSuggestionFilledSpoken =>
      'Phone-number suggestion filled. Enter your password to sign in. No sign-in was sent.';

  @override
  String get authErrorEnterPhone => 'Enter your phone number.';

  @override
  String get authErrorInvalidPhone => 'Enter a valid 10-digit phone number.';

  @override
  String get authErrorEnterPassword => 'Enter your password.';

  @override
  String get authErrorPasswordTooShort =>
      'Password must be at least 6 characters.';

  @override
  String get authErrorInvalidServerResponse => 'Invalid response from server';

  @override
  String get authErrorNotRegisteredAdmin =>
      'This phone number is not registered as an admin account. Press 1, 2 or 3 to choose the account type.';

  @override
  String get authErrorNotRegisteredTeacher =>
      'This phone number is not registered as a teacher account. Press 1, 2 or 3 to choose the account type.';

  @override
  String get authErrorNotRegisteredStudent =>
      'This phone number is not registered as a student account. Press 1, 2 or 3 to choose the account type.';

  @override
  String get authErrorResponseNotVerified =>
      'The sign-in response could not be verified. Please try again.';

  @override
  String authErrorMovedToPhone(String message) {
    return '$message Moved to phone number field.';
  }

  @override
  String authErrorMovedToAccountType(String message) {
    return '$message Moved to account type.';
  }

  @override
  String authErrorMovedToPassword(String message) {
    return '$message Moved to password field.';
  }

  @override
  String get authRoleAdministrator => 'Administrator';

  @override
  String get authRoleTeacher => 'Teacher';

  @override
  String get authRoleStudent => 'Student';

  @override
  String get authRecoveryStep1 =>
      'Ask your school administrator to reset your password. They must check who you are in person. A phone number or SIM alone does not prove it. Never send anyone your permanent password.';

  @override
  String get authRecoveryStep2 =>
      'The administrator gives you a private 12-digit temporary password. It works for 24 hours. Ask for a new one if it expires.';

  @override
  String get authRecoveryStep3 =>
      'Sign in with your phone number and the temporary password, then choose a new password.';

  @override
  String get authRecoveryStep4 =>
      'After 10 wrong tries, sign-in pauses for 15 minutes. Recovery needs internet. Files already on other phones are not removed instantly.';

  @override
  String get authRecoveryHelpTitle => 'Password recovery help';

  @override
  String authRecoveryHelpIntro(String count) {
    return '$count short steps. Press down to hear each step.';
  }

  @override
  String get authBackToLogin => 'Back to login';

  @override
  String get authBackToLoginButton => 'Back to login, button';

  @override
  String get notesRecordingStarted =>
      'Recording started. Select Stop recording when finished.';

  @override
  String get notesActionNotConfirmed =>
      'This note action could not be confirmed. Check storage, microphone permission or connection. Your drafts are kept.';

  @override
  String get notesNoneYet => 'No private notes yet.';

  @override
  String notesLoaded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count private notes loaded.',
      one: '1 private note loaded.',
    );
    return '$_temp0';
  }

  @override
  String get notesNameDialogTitle => 'Name private note';

  @override
  String get notesDefaultTitle => 'Private note';

  @override
  String notesDefaultLessonTitle(String lesson) {
    return 'Note for $lesson';
  }

  @override
  String get notesRecordConfirmTitle => 'Record private note?';

  @override
  String notesRecordConfirmMessage(String lessonPoint) {
    return 'Record microphone audio on this phone only, for up to five minutes or the remaining separate 10 MB note allowance. Stop recording before using spoken controls. App speech, leaving this screen or app interruption stops recording. Live-session recording is blocked. $lessonPoint No automatic upload or sharing. Microphone permission may be requested.';
  }

  @override
  String notesLessonPointSeconds(String seconds) {
    return 'Lesson point: $seconds seconds.';
  }

  @override
  String get notesStartRecording => 'Start recording';

  @override
  String get notesDoNotRecord => 'Do not record';

  @override
  String get notesReviewStoppedChanged =>
      'Review stopped because the screen or app changed. Open this note again to review.';

  @override
  String get notesReviewStoppedAccount =>
      'Review stopped because your account changed. Open private notes again.';

  @override
  String get notesRenameDialogTitle => 'Rename private note';

  @override
  String notesRemoveTitle(String title) {
    return 'Remove $title?';
  }

  @override
  String notesRemoveMessage(String title) {
    return 'Remove only $title from this account on this phone? Other notes, learning progress and bookmarks are kept. If previously published, the online recording and downloaded copies are not removed.';
  }

  @override
  String get notesRemoveSelected => 'Remove selected note';

  @override
  String get notesKeepNote => 'Keep note';

  @override
  String notesRemoved(String title) {
    return '$title removed. Other notes and learning progress kept.';
  }

  @override
  String get notesReviewBeforePublish =>
      'Play and review this note privately before publishing.';

  @override
  String get notesSignInAsTeacher =>
      'Sign in as the teacher before publishing.';

  @override
  String get notesNoWorkspace =>
      'No authorized class/subject workspace was confirmed. Your draft is kept.';

  @override
  String get notesPublishTitle => 'Publish reviewed note to class?';

  @override
  String notesPublishMessage(
    String title,
    String className,
    String subjectName,
  ) {
    return 'Confirm you reviewed $title and want to publish it to $className, $subjectName. Authorized class members can stream or download it for up to 30 days offline. Disconnected copies cannot be instantly revoked. Your local draft stays. An unconfirmed upload may already have published; check the library before retrying to avoid duplicates.';
  }

  @override
  String get notesPublishConfirm => 'Publish to selected class';

  @override
  String get notesKeepDraftPrivate => 'Keep draft private';

  @override
  String get notesSignInChanged => 'Sign-in changed. The draft was not sent.';

  @override
  String get notesAccountChangedBeforePublish =>
      'Your account changed before publication was confirmed. Check the original teacher library before retrying.';

  @override
  String get notesPublishNotConfirmed =>
      'Publication was not confirmed. Check the class library before retrying; your private draft is kept.';

  @override
  String get notesPublishUnreadable =>
      'Publication confirmation was unreadable. Check the library before retrying; your draft is kept.';

  @override
  String get notesPublishIdentityMismatch =>
      'Publication identity did not match. Check the library before retrying; your draft is kept.';

  @override
  String notesPublished(String audioId) {
    return 'Published as recording $audioId. Your local draft is kept. Do not publish again unless you intend another recording.';
  }

  @override
  String get notesStopBeforeLeaving =>
      'Recording stop was not confirmed. Stop again or background the app before leaving.';

  @override
  String get notesRules =>
      'Private note rules. Each note can be up to five minutes. Notes use a separate 10 megabyte allowance for each account. Recording only starts when you confirm it, and never inside a live session. App speech, leaving this screen or an interruption stops recording, so stop recording before using spoken controls. Student notes stay private on this phone. Teacher drafts must be reviewed and confirmed before publishing. Notes are kept after you log out.';

  @override
  String notesRecordingFor(String duration) {
    return 'Recording for $duration.';
  }

  @override
  String notesUsage(String megabytes) {
    return '$megabytes of 10 MB private notes used.';
  }

  @override
  String authRecoveryStepListItem(String number, String step) {
    return '$number. $step';
  }

  @override
  String get authBackToLoginKey => '0: Back to login';

  @override
  String get authRoleRowSelected => 'Selected';

  @override
  String get authLoginScreenName => 'Login Screen';

  @override
  String get authLoginNavigationSections =>
      'phone number, password, account type, login, registration, SIM suggestions and recovery help';

  @override
  String get authLoginKeySimLabel =>
      'Read optional SIM phone-number suggestions';

  @override
  String get authLoginKeyRecoveryLabel => 'School-admin password recovery help';

  @override
  String get authPhoneNumberField => 'Phone number field';

  @override
  String get authPasswordField => 'Password field';

  @override
  String get authHidePassword => 'Hide password';

  @override
  String get authShowPassword => 'Show password';

  @override
  String authRoleFieldNavLabel(String role) {
    return 'Account type: $role, selected. Press 1, 2 or 3 to change, or use left and right';
  }

  @override
  String authLoginAsButton(String role) {
    return 'Login as $role, button';
  }

  @override
  String get authRegisterNewAccountButton => 'Register a new account, button';

  @override
  String get authSimSuggestionsTargetLabel =>
      'Read optional SIM phone-number suggestions. Manual entry always works.';

  @override
  String get authForgotPasswordTargetLabel =>
      'Forgot password? School-admin recovery help';

  @override
  String get authWelcomeBack => 'Welcome Back';

  @override
  String get authRegisteredBanner => 'Registered. Now log in.';

  @override
  String get authPhoneNumber => 'Phone number';

  @override
  String get authPassword => 'Password';

  @override
  String get authAccountType => 'Account type';

  @override
  String authRoleFieldValue(String role) {
    return '$role, selected. Press 1, 2 or 3 to change';
  }

  @override
  String get authRoleOptionStudent => '1 Student';

  @override
  String get authRoleOptionTeacher => '2 Teacher';

  @override
  String get authRoleOptionAdmin => '3 Admin';

  @override
  String get authSigningIn => 'Signing in, please wait';

  @override
  String authLoginAsKey(String role) {
    return '4: Login as $role';
  }

  @override
  String get authNoAccountRegisterKey => '5: Don\'t have an account? Register';

  @override
  String get authReadSimSuggestionsKey => '6: Read optional SIM suggestions';

  @override
  String get authForgotPasswordKey => '7: Forgot password? Recovery help';

  @override
  String authErrorMovedToName(String message) {
    return '$message Moved to name field.';
  }

  @override
  String get authErrorEnterName => 'Enter your name.';

  @override
  String get authErrorEnterAPassword => 'Enter a password.';

  @override
  String get authRegisteringAsTeacher => 'Registering as teacher';

  @override
  String get authRegisteringAsStudent => 'Registering as student';

  @override
  String get authRegistrationScreenName => 'Registration Screen';

  @override
  String get authRegisterNavigationSections =>
      'name, phone number, password, student or teacher account type, register, and login';

  @override
  String get authNameField => 'Name field';

  @override
  String get authRegisterRoleTeacherLabel =>
      'Account type: Teacher. Press OK or 3 to switch to student';

  @override
  String get authRegisterRoleStudentLabel =>
      'Account type: Student. Press OK or 3 to switch to teacher';

  @override
  String get authRegisterAsTeacherButton => 'Register as teacher, button';

  @override
  String get authRegisterAsStudentButton => 'Register as student, button';

  @override
  String get authGoToLoginLabel => 'Already have an account? Go to login';

  @override
  String get authRegisterTitle => 'Register';

  @override
  String get authName => 'Name';

  @override
  String get authRegisterAsTeacherKey =>
      '3: Register as Teacher. Change account type';

  @override
  String get authRegisterAsStudentKey =>
      '3: Register as Student. Change account type';

  @override
  String get authRegisteringPleaseWait => 'Registering, please wait';

  @override
  String get authRegisterKey => '1: Register';

  @override
  String get authHaveAccountLoginKey => '2: Already have an account? Login';

  @override
  String get authChangePasswordBusy =>
      'Saving. Waiting for password-change confirmation.';

  @override
  String get authChangePasswordErrorEnterTemporary =>
      'Enter your temporary credential. Moved to that field.';

  @override
  String get authChangePasswordErrorTooShort =>
      'Enter a new password of at least 6 characters. Moved to new password.';

  @override
  String get authChangePasswordErrorMismatch =>
      'The new passwords do not match. Moved to repeat new password.';

  @override
  String get authChangePasswordErrorSameAsTemporary =>
      'Choose a password different from the temporary credential. Moved to new password.';

  @override
  String get authChangePasswordSessionInactive =>
      'This recovery session is no longer active. Sign in again.';

  @override
  String get authChangePasswordAccountChanged =>
      'Your account changed. No replacement sign-in was saved.';

  @override
  String authChangePasswordNotConfirmed(String message) {
    return '$message Password change is not confirmed. If the connection failed, try signing in with your new password before requesting another reset.';
  }

  @override
  String get authChangePasswordResponseNotVerified =>
      'The password-change response could not be verified. Try signing in again with your new password.';

  @override
  String get authChangePasswordReplacementNotVerified =>
      'The replacement sign-in could not be verified. Sign in again with your new password.';

  @override
  String get authChangePasswordSignInNotSaved =>
      'Your sign-in could not be saved. Sign in again with your new password.';

  @override
  String get authChangePasswordSignInNotSavedOnPhone =>
      'Your sign-in could not be saved on this phone. Sign in again with your new password.';

  @override
  String get authTemporaryCredential => 'Temporary credential';

  @override
  String get authNewPassword => 'New password';

  @override
  String get authRepeatNewPassword => 'Repeat new password';

  @override
  String get authChangePasswordScreenName => 'Change temporary password';

  @override
  String get authChangePasswordIntro =>
      'Enter the temporary credential from your administrator, then a new password of at least 6 characters, twice. Internet is required. The dashboard opens after the new password is confirmed.';

  @override
  String get authSaveNewPassword => 'Save new password';

  @override
  String get authSignOut => 'Sign out';

  @override
  String get authTemporaryCredentialField =>
      'Temporary credential. Hidden input.';

  @override
  String get authNewPasswordField =>
      'New password. At least 6 characters. Hidden input.';

  @override
  String get authRepeatNewPasswordField => 'Repeat new password. Hidden input.';

  @override
  String get authSaveNewPasswordButton => 'Save new password, button';

  @override
  String get authSignOutConfirmButton => 'Sign out, asks to confirm';

  @override
  String get authChangePasswordTitle => 'Change password';

  @override
  String get authChangePasswordInfo =>
      'Your school administrator issued a temporary credential. It lasts 24 hours. After 10 wrong attempts, sign-in pauses for 15 minutes. Choose a different password of at least 6 characters. This requires internet.';

  @override
  String get authSignOutKey => '0: Sign out';

  @override
  String authSimOptionValid(String label, String digits) {
    return '$label. Phone number $digits. Press OK to fill the phone field.';
  }

  @override
  String authSimOptionInvalid(String label) {
    return '$label. Number unavailable. Enter the phone number manually.';
  }

  @override
  String get authSimInvalidSuggestion =>
      'This SIM does not provide a valid phone-number suggestion. Manual entry still works.';

  @override
  String get authSimChooseScreenName =>
      'Choose an optional SIM suggestion. Use up and down to review each SIM, then OK to select. This is not account verification.';

  @override
  String get authSimCancelLabel => 'Cancel without changing the phone number';

  @override
  String get authSimChooseTitle => 'Choose SIM suggestion';

  @override
  String get authSimChooseInfo =>
      'Selecting fills the phone field only. Your password is still required. Cancel keeps manual entry unchanged.';

  @override
  String get authSimCancelKey => '0: Cancel';

  @override
  String get inviteStatusInvited => 'Invited';

  @override
  String get inviteStatusNotInvited => 'Not invited. OK to invite';

  @override
  String get inviteTitle => 'Invite Students';

  @override
  String get inviteTooltipBack => '0: Back to session';

  @override
  String get inviteTooltipRefresh => '1: Refresh student list';

  @override
  String get inviteInvitingTo => 'Inviting students to:';

  @override
  String inviteInvitedCount(String invited, String total) {
    return '$invited of $total invited';
  }

  @override
  String get inviteAllButton => '2: Invite All Students';

  @override
  String get inviteSearchField => 'Search by name or phone number';

  @override
  String get inviteSearchHelper => 'Leave empty to list every student';

  @override
  String get inviteLoadingStudents => 'Loading students';

  @override
  String get inviteNoMatchShort =>
      'No students match. Clear the search to list everyone.';

  @override
  String get libraryUploadTitleField => 'Title *';

  @override
  String get libraryUploadDescriptionField => 'Description';

  @override
  String get libraryCancelKey0Button => 'Cancel (0)';

  @override
  String get libraryUploadKey3Button => 'Upload (3)';

  @override
  String get libraryConfirmKey1Button => 'Confirm (1)';

  @override
  String librarySessionNumber(String id) {
    return 'Session #$id';
  }

  @override
  String get libraryKey5PauseForClass => '5: Pause for class';

  @override
  String get libraryKey5PlayForClass => '5: Play for class';

  @override
  String get libraryRecordingsSeekKeysHint => '4: Back 10 s. 6: Forward 10 s.';

  @override
  String get libraryKey1ChooseRecording => '1: Choose recording';

  @override
  String get libraryUploadingButton => 'Uploading';

  @override
  String get libraryKey2Upload => '2: Upload';

  @override
  String get libraryRecordingsFooterKeysHint =>
      '3: Status. *: Help. #: Stop speech.';

  @override
  String get notesBackStopsRecording => 'Back. Stops any recording first';

  @override
  String get notesReadRules => 'Read note rules';

  @override
  String get notesRefreshPrivate => 'Refresh private notes';

  @override
  String get notesRecordAsksFirst =>
      'Record a private note. Asks for a name and confirmation first';

  @override
  String get notesStopRecordingNow => 'Stop recording now';

  @override
  String get notesReadRecordingTimeStops =>
      'Read recording time. Reading aloud stops recording';

  @override
  String get notesReadPrivateStatus => 'Read private note status';

  @override
  String get notesStopPrivateReview => 'Stop private review';

  @override
  String notesStopReviewingTitle(String title) {
    return 'Stop reviewing $title';
  }

  @override
  String get notesStopReviewingNote => 'Stop reviewing note';

  @override
  String notesReviewTitlePrivately(String title, String duration) {
    return 'Review $title privately. $duration.';
  }

  @override
  String notesReviewTitleIncomplete(String title) {
    return 'Review $title privately. Incomplete recording; cannot play.';
  }

  @override
  String notesRenameTitle(String title) {
    return 'Rename $title';
  }

  @override
  String notesPublishTitleAsks(String title) {
    return 'Publish reviewed $title to a class and subject, asks to confirm';
  }

  @override
  String notesRemoveTitleAsks(String title) {
    return 'Remove $title, asks to confirm';
  }

  @override
  String get notesScreenName => 'Private notes';

  @override
  String get notesIntroduction =>
      'Use Read note rules to hear how notes are kept.';

  @override
  String get notesBack => 'Back';

  @override
  String notesStorageSummary(String megabytes) {
    return '$megabytes / 10 MB private notes. Separate from lesson downloads. No automatic deletion.';
  }

  @override
  String notesLessonContext(String title, String seconds) {
    return '$title. Captured lesson point: $seconds seconds.';
  }

  @override
  String notesRecordingTime(String time) {
    return 'Recording time $time';
  }

  @override
  String get notesRefreshNotes => 'Refresh notes';

  @override
  String get notesRecordPrivateNote => 'Record a private note';

  @override
  String get notesStopRecording => 'Stop recording';

  @override
  String get notesReadRecordingTime => 'Read recording time';

  @override
  String get notesReadNoteStatus => 'Read note status';

  @override
  String get notesStatusNeedsAttention => 'Needs attention';

  @override
  String get notesStatusIncomplete => 'Incomplete';

  @override
  String get notesStatusPlaying => 'Playing';

  @override
  String get notesStatusReviewed => 'Reviewed';

  @override
  String get notesStatusSaved => 'Saved';

  @override
  String notesNoteSeconds(String seconds) {
    return '$seconds seconds. Private local note.';
  }

  @override
  String get notesNoteIncomplete =>
      'Interrupted or incomplete note. Cannot play or publish.';

  @override
  String notesNoteLessonPoint(String lesson, String seconds) {
    return 'Lesson $lesson, point $seconds seconds.';
  }

  @override
  String get notesReviewPlaying => 'Review playing';

  @override
  String get notesReviewPrivately => 'Review privately';

  @override
  String get notesRename => 'Rename';

  @override
  String get notesPublishReviewedNote => 'Publish reviewed note';

  @override
  String get notesEnterNameBeforeSaving => 'Enter a name before saving.';

  @override
  String notesNameDialogInstructions(String title) {
    return '$title. OK enters editing. Up or Down leaves editing, then choose Save or Cancel.';
  }

  @override
  String get notesNoteName => 'Note name';

  @override
  String get notesSaveNoteName => 'Save note name';

  @override
  String get notesCancel => 'Cancel';

  @override
  String get notesSaveName => 'Save name';

  @override
  String notesWorkspaceLabel(String className, String subjectName) {
    return '$className, $subjectName';
  }

  @override
  String get notesChooseWorkspaceInstructions =>
      'Choose an authorized class and subject before publishing. Nothing is uploaded until the next confirmation.';

  @override
  String get notesCancelPublication => 'Cancel publication';

  @override
  String get notesPublishWhichWorkspace => 'Publish to which workspace?';

  @override
  String settingsDecrease(String setting) {
    return 'Decrease $setting';
  }

  @override
  String settingsIncrease(String setting) {
    return 'Increase $setting';
  }

  @override
  String get settingsResetTooltip => 'Reset to Defaults';

  @override
  String get settingsSectionSpeech => 'Speech';

  @override
  String get settingsAppSpeechTitle => 'App speech';

  @override
  String get settingsAppSpeechSubtitle =>
      'The app reads out screens and messages';

  @override
  String settingsLanguageButton(String language) {
    return 'Speech language: $language';
  }

  @override
  String get settingsVolumeTitle => 'Volume';

  @override
  String get settingsVolumeSubtitle => 'How loud app speech is';

  @override
  String settingsPercentValue(String percent) {
    return '$percent percent';
  }

  @override
  String get settingsSpeedTitle => 'Speech speed';

  @override
  String get settingsSpeedSubtitle =>
      'How fast app speech is. Quizzes can use their own speed';

  @override
  String settingsTimesNormal(String speed) {
    return '$speed times normal';
  }

  @override
  String get settingsTestButton => '5: Test speech';

  @override
  String settingsNarrationButton(String level) {
    return 'Narration level: $level';
  }

  @override
  String settingsCheckingVoice(String language) {
    return 'Checking $language voice...';
  }

  @override
  String settingsCheckVoiceButton(String language) {
    return '7: Check $language voice';
  }

  @override
  String get settingsStopButton => '#: Stop speech';

  @override
  String get settingsSectionDisplay => 'Display';

  @override
  String get settingsHighContrastTitle => 'High Contrast';

  @override
  String get settingsHighContrastSubtitle =>
      'On by default: white and yellow on black for low vision';

  @override
  String get settingsTextSizeTitle => 'Text size';

  @override
  String get settingsTextSizeSubtitle =>
      'App text size; system font scaling is also respected';

  @override
  String get settingsSectionKeys => 'Keys and help';

  @override
  String get settingsShortcutsTitle => 'Show keypad shortcuts';

  @override
  String get settingsShortcutsSubtitle => 'Show key numbers on buttons';

  @override
  String get settingsGlobalKeysHint =>
      'On every screen: 0 back, star help, hash stop speech.';

  @override
  String get settingsVoiceCommandsTitle => 'Voice commands';

  @override
  String get settingsVoiceCommandsSubtitle =>
      'Enable Listen for command in sessions. No automatic listening.';

  @override
  String get settingsSoundCuesTitle => '8: Sound cues';

  @override
  String get settingsVibrationTitle => '9: Vibration';

  @override
  String get settingsVoiceHelpButton =>
      'Voice command help: say mute, unmute, raise hand, lower hand, leave or repeat.';

  @override
  String get uiSave => 'Save';

  @override
  String get uiClose => 'Close';

  @override
  String get learningLessonPositionLabel => 'Lesson position';

  @override
  String get learningReadStatusButton => 'Read learning status';

  @override
  String get learningAddBookmarkButton => 'Add bookmark';

  @override
  String learningBookmarksButton(String count) {
    return 'Bookmarks ($count)';
  }

  @override
  String get learningPrivateNotesButton => 'Private study notes';

  @override
  String get learningSetAButton => 'Set A';

  @override
  String learningSetAAtButton(String time) {
    return 'Set A $time';
  }

  @override
  String get learningSetBButton => 'Set B';

  @override
  String learningSetBAtButton(String time) {
    return 'Set B $time';
  }

  @override
  String get learningRepeatOffButton => 'Repeat off';

  @override
  String get learningRepeatOnButton => 'Repeat on';

  @override
  String get learningClearABButton => 'Clear A-B';

  @override
  String learningBackTenButton(String key) {
    return '$key: Back 10 seconds';
  }

  @override
  String learningForwardTenButton(String key) {
    return '$key: Forward 10 seconds';
  }

  @override
  String learningSlowerButton(String key) {
    return '$key: Slower';
  }

  @override
  String learningFasterButton(String key) {
    return '$key: Faster';
  }

  @override
  String get learningRetrySavingButton => 'Retry saving';

  @override
  String get learningNameBookmarkTitle => 'Name bookmark';

  @override
  String get learningBookmarkNameFieldLabel => 'Name';

  @override
  String get learningBookmarksTitle => 'Bookmarks';

  @override
  String get learningBookmarksLessonChanged =>
      'The lesson changed. Close this list and open bookmarks for the current lesson.';

  @override
  String get learningBookmarksEmpty =>
      'No bookmarks yet. Use Add bookmark at a position you want to remember.';

  @override
  String get learningBookmarksUnavailable =>
      'Saved bookmarks are unavailable. Retry saving to restore access to saved progress.';

  @override
  String learningBookmarkAtButton(String label, String time) {
    return '$label at $time';
  }

  @override
  String learningRemoveBookmarkSemantics(String label) {
    return 'Remove bookmark $label';
  }

  @override
  String uiKeyedLabel(String key, String label) {
    return '$key: $label';
  }

  @override
  String get uiKeypadFooter => '*: Help. #: Stop app speech.';

  @override
  String uiListSearchValue(String query) {
    return 'Search: $query';
  }

  @override
  String get uiListLoadingShort => 'Loading. Press 0 to go back.';

  @override
  String get keypadTextEditingHint =>
      'While editing, keys enter text. Press OK to finish. Use up or down if OK does not finish editing.';

  @override
  String get keypadWaitingConfirmation => 'Waiting for confirmation.';

  @override
  String get keypadContinueKey1 => '1: Continue';

  @override
  String get keypadHidePasswordKey2 => '2: Hide password';

  @override
  String get keypadShowPasswordKey2 => '2: Show password';

  @override
  String get keypadBackKey0 => '0: Back';

  @override
  String uiKeyedLabelUnavailable(String number, String label) {
    return '$number: $label (unavailable)';
  }

  @override
  String get journeyMenuReadDetailsKey8 => '8: Read details again';

  @override
  String get sessionTileHandRaised => 'Hand raised';

  @override
  String get sessionTileSpeaking => 'Speaking';

  @override
  String sessionRemoveFromSession(String name) {
    return 'Remove $name from session';
  }

  @override
  String get classroomConsoleTitle => 'Classroom console';

  @override
  String get uiHourRange => 'Hour (0 to 23)';

  @override
  String get uiSetDateTimeTitle => 'Set date and time';

  @override
  String get uiSetDateTimeHint =>
      'Use local time. Press OK to edit each number.';

  @override
  String quizExtraTitle(String name) {
    return 'Extra time: $name';
  }

  @override
  String get quizExtraInfo =>
      'Future attempts only. Existing deadlines do not change. Quiz closing time still applies; extend availability separately if needed. Zero removes extra minutes.';

  @override
  String get quizExtraMinutesField => 'Extra minutes';

  @override
  String get quizExtraSaveButton => 'Save future extra time';

  @override
  String quizSpeedValue(String speed) {
    return 'Quiz speech speed: $speed×';
  }

  @override
  String get uiCancelKey0 => '0: Cancel';

  @override
  String get uiSaveKey1 => '1: Save';

  @override
  String get uiNone => 'none';

  @override
  String uiPreviousOf(String label) {
    return 'Previous $label';
  }

  @override
  String uiNextOf(String label) {
    return 'Next $label';
  }

  @override
  String get journeyOpening => 'Opening journey';

  @override
  String journeyStepHeading(String position, String kind) {
    return '$position. $kind';
  }

  @override
  String journeyStepHeadingReplay(String position, String kind) {
    return '$position. $kind. Listening again';
  }

  @override
  String journeyFirstTryShort(String correct, String total) {
    return '$correct of $total correct on the first try.';
  }

  @override
  String get journeyLeaveKey0 => '0: Leave journey';

  @override
  String get quizRevisionsTitle => 'Question revisions';

  @override
  String get quizRevisionsBackTooltip => 'Go back from question revisions';

  @override
  String quizRevisionSectionHear(String section) {
    return '$section. Double tap to hear it';
  }

  @override
  String get adminResetAttested => 'Identity verification attested.';

  @override
  String get adminResetNotAttested => 'Identity verification not attested.';

  @override
  String get adminResetConfirmTitle => 'Reset this password?';

  @override
  String adminResetConfirmMessage(String name, String phone) {
    return 'Reset $name, phone $phone? This replaces the old password and ends online sessions. Disconnected downloaded lessons cannot be instantly revoked. Existing lessons, notes and learning records are retained. A 12-digit temporary credential lasts 24 hours and requires password change. After 10 wrong attempts, temporary-credential sign-in pauses for 15 minutes.';
  }

  @override
  String get adminResetKeepPassword => 'Keep password';

  @override
  String get adminResetResetPassword => 'Reset password';

  @override
  String get adminResetSignInChanged =>
      'Administrator sign-in changed. No reset was sent.';

  @override
  String get adminResetSending =>
      'Sending reset. Waiting for server confirmation.';

  @override
  String adminResetNotConfirmed(String reason) {
    return 'Reset not confirmed. $reason It may already have taken effect. Close and refresh this account before considering another reset.';
  }

  @override
  String get adminResetResponseNotVerified =>
      'The reset response could not be verified. The password may already have changed. Close and refresh before considering another reset.';

  @override
  String get adminResetConfirmedSpoken =>
      'Password reset confirmed. The credential is hidden. Use Read credential only when it is private. Closing discards this copy.';

  @override
  String get adminResetPhoneNotConfirmed =>
      'Reset could not be confirmed on this phone. Close and refresh the account before considering another reset.';

  @override
  String get adminResetStorageUnavailable =>
      'Account storage is unavailable. Close recovery and restart SEEDS before considering a reset.';

  @override
  String adminResetCredentialSpoken(String digits, String expires) {
    return 'Temporary credential: $digits. Expires at $expires, UTC. Deliver privately to the verified person. It must be replaced at sign-in.';
  }

  @override
  String get adminResetDiscardTitle => 'Discard this credential copy?';

  @override
  String get adminResetDiscardMessage =>
      'Confirm that you delivered the temporary credential privately, or accept that another verified administrator reset will be needed. SEEDS will not show this copy again. This does not cancel the completed reset.';

  @override
  String get adminResetKeepReviewing => 'Keep reviewing';

  @override
  String get adminResetCloseDiscard => 'Close and discard';

  @override
  String get adminResetScreenName =>
      'Administrator password recovery. Verify identity outside SEEDS before resetting. Credentials are hidden until explicitly requested.';

  @override
  String get adminResetCloseRecovery => 'Close recovery';

  @override
  String get adminResetReadAccount => 'Read selected account details';

  @override
  String adminResetAccountDetails(String name, String phone) {
    return '$name. Phone $phone.';
  }

  @override
  String get adminResetIdentityChecked =>
      'Identity verified outside SEEDS. Checked. Press OK to change.';

  @override
  String get adminResetIdentityNotChecked =>
      'Identity verified outside SEEDS. Not checked. Press OK to change.';

  @override
  String get adminResetResetAndEnd => 'Reset password and end online sessions';

  @override
  String get adminResetReadCredentialLabel =>
      'Read and reveal temporary credential. Only use privately.';

  @override
  String get adminResetCloseRefresh => 'Close and refresh account';

  @override
  String get adminResetTitle => 'Password recovery';

  @override
  String get adminResetVerifyInfo =>
      'Verify the person outside SEEDS. A phone number or SIM suggestion is not identity verification. Never reset based only on a message or a claimed name.';

  @override
  String get adminResetVerifiedCheckbox =>
      'I verified this person outside SEEDS';

  @override
  String get adminResetWaiting => 'Waiting for reset confirmation.';

  @override
  String get adminResetConfirmedInfo =>
      'Reset confirmed. Credential hidden until requested. It is valid for 24 hours. Closing discards this copy. Deliver privately; never post it in a class.';

  @override
  String get adminResetRevealButton => 'Read and reveal credential privately';

  @override
  String adminResetCredentialShown(String digits, String expires) {
    return 'Temporary credential: $digits\nExpires: $expires UTC';
  }

  @override
  String get adminResetCloseRefreshKey0 => '0: Close and refresh account';

  @override
  String get apiTemporarySignInPaused =>
      'Temporary-credential sign-in is paused for 15 minutes. Try later or contact your school administrator.';

  @override
  String get apiTemporaryCredentialExpired =>
      'Your temporary credential expired. Contact your school administrator for a replacement.';

  @override
  String get apiPasswordMustDiffer =>
      'Choose a password different from the temporary credential.';

  @override
  String get apiTemporaryCredentialRejected =>
      'The temporary credential was not accepted. Check it and try again.';

  @override
  String get apiRecoverySignInExpired =>
      'Your recovery sign-in expired or changed. Sign in again.';

  @override
  String get apiCheckInformation =>
      'Please check the information and try again.';

  @override
  String get apiInvalidLogin => 'Invalid phone number or password.';

  @override
  String get apiNoPermission => 'You do not have permission to do that.';

  @override
  String get apiSessionNotFound =>
      'Session not found. Check the session ID and try again.';

  @override
  String get apiItemNotFound => 'The requested item was not found.';

  @override
  String get apiServiceUnavailable =>
      'The service is temporarily unavailable. Please try again.';

  @override
  String get apiNetworkFailure =>
      'We could not complete that request. Check your connection and try again.';

  @override
  String get apiUnknownFailure =>
      'We could not complete that request. Please try again.';

  @override
  String get apiAccountChangedRequestNotSent =>
      'Your account changed. This request was not sent.';

  @override
  String get apiAccountOrSessionChanged =>
      'Your account or session changed. This action was not sent.';

  @override
  String get apiResponseUnreadable =>
      'The service response could not be read. The action may have been received; check its status before trying again.';

  @override
  String get apiSignInBeforeAction =>
      'Sign in again before sending this action.';

  @override
  String get apiAccountChangedNotConfirmed =>
      'Your account changed. This action could not be confirmed.';

  @override
  String get apiActionNotConfirmed =>
      'The action was not confirmed. It may have reached the class. Check its status before trying again.';

  @override
  String get apiAccountChangedActionNotSent =>
      'Your account changed. This action was not sent.';

  @override
  String get apiRequestFailed => 'Request failed';

  @override
  String get notificationPrivateTitle => 'SEEDS update';

  @override
  String get notificationPrivateBody => 'Open SEEDS to review your updates.';

  @override
  String get notificationRegistrationFailed =>
      'Notifications could not be registered. Refresh SEEDS to check class invitations.';

  @override
  String get notificationChannelName => 'Session Notifications';

  @override
  String get notificationChannelDescription =>
      'Notifications for session invitations and updates';

  @override
  String get notificationDisplayFailed =>
      'An update arrived, but the phone notification could not be displayed. Open SEEDS to check updates.';

  @override
  String get activityCleanupFailed =>
      'Expired activity could not be cleaned. Check device storage.';

  @override
  String get activitySyncUnavailable =>
      'Activity sync is unavailable. Learning is still available.';

  @override
  String get activitySignInToSync => 'Sign in to sync activity.';

  @override
  String get activityQueueFull =>
      'Activity queue is full. Some older actions cannot be reported.';

  @override
  String get activityWaitingToSync => 'Some activity is waiting to sync.';

  @override
  String get activityRejected =>
      'Some activity was expired or no longer permitted and was not synced.';

  @override
  String get authLogoutTitle => 'Log out of SEEDS?';

  @override
  String get authLogoutMessage =>
      'You will need to enter your phone number and password again.';

  @override
  String get authLogoutCancel => 'Cancel';

  @override
  String get authLogoutConfirm => 'Log out';

  @override
  String get authLoggedOut => 'Logged out.';

  @override
  String get startupLoadingTools => 'Loading accessible learning tools…';

  @override
  String get startupTagline => 'Connecting everyone, everywhere';

  @override
  String get startupLoginKey1 => '1. Login';

  @override
  String get startupLogin => 'Login';

  @override
  String get startupRegisterKey2 => '2. Register';

  @override
  String get startupRegister => 'Register';

  @override
  String get startupSettings => 'Settings';

  @override
  String get startupRepeatInstructions => 'Repeat instructions';

  @override
  String get startupFeatureAudioTitle => 'Real-time Audio';

  @override
  String get startupFeatureAudioText => 'Crystal clear voice communication';

  @override
  String get startupFeatureAccessibleTitle => 'Fully Accessible';

  @override
  String get startupFeatureAccessibleText =>
      'Speech, large buttons and keypad control';

  @override
  String get startupFeatureCollaborationTitle => 'Collaboration';

  @override
  String get startupFeatureCollaborationText => 'Raise hands and interact';

  @override
  String get settingsResetTitle => 'Reset Settings';

  @override
  String get settingsResetCancelButton => '1: Cancel';

  @override
  String get settingsResetConfirmButton => '2: Reset';

  @override
  String teacherHomeFallbackName(String id) {
    return 'Teacher $id';
  }

  @override
  String dashboardSignedInAs(String name) {
    return 'Signed in as $name';
  }

  @override
  String get dashboardRefreshSessionsKey1 => '1: Refresh sessions';

  @override
  String get dashboardLogOutKey0 => '0: Log out';

  @override
  String get dashboardRefreshingSessions => 'Refreshing sessions';

  @override
  String teacherHomeWelcome(String name) {
    return 'Welcome, $name!';
  }

  @override
  String get teacherHomeTagline =>
      'Manage your sessions and connect with students';

  @override
  String get teacherHomeChooseWorkspaceKey7 =>
      '7: Choose class and subject workspace';

  @override
  String teacherHomeChangeWorkspaceKey7(String className, String subjectName) {
    return '7: $className, $subjectName. Change workspace';
  }

  @override
  String get teacherHomePlaylistsKey5 => '5: Class Playlists';

  @override
  String get teacherHomeJourneysKey8 => '8: Learning Journeys';

  @override
  String get teacherHomeQuizzesKey6 => '6: Quizzes & Question Bank';

  @override
  String get teacherHomeCreateSessionKey2 => '2: Create New Session';

  @override
  String get dashboardAudioLibraryKey3 => '3: Recorded Audio Library';

  @override
  String get teacherHomeSearchKey4 => '4: Search by name or number';

  @override
  String get teacherHomeSearchHint =>
      'Type a session name, or the session number with the number keys. Leave empty to list all.';

  @override
  String get teacherHomeYourSessions => 'Your sessions';

  @override
  String teacherHomeYourSessionsCount(String count) {
    return 'Your sessions, $count';
  }

  @override
  String get teacherHomeYourSessionsHeading => 'Your Sessions';

  @override
  String get teacherHomeNoSessions => 'No sessions yet. Press 2 to create one.';

  @override
  String get teacherHomeNoMatches =>
      'No matching sessions. Clear the search to list all sessions.';

  @override
  String teacherHomeEndTitleForEveryone(String title) {
    return 'End $title for everyone';
  }

  @override
  String teacherHomeDeleteTitlePermanently(String title) {
    return 'Delete $title permanently';
  }

  @override
  String teacherHomeLiveJoined(String count) {
    return 'Live now, $count joined';
  }

  @override
  String teacherHomeSessionNumber(String number) {
    return 'Session number $number';
  }

  @override
  String teacherHomePlaceSessionNumber(String place, String number) {
    return '$place. Session number $number';
  }

  @override
  String get teacherHomeDelete => 'Delete';

  @override
  String get teacherHomeSessionTitleField => 'Session Title';

  @override
  String get teacherHomeSessionTitleHint => 'e.g., English Class - Unit 5';

  @override
  String get teacherHomeCreateKey1 => 'Create (1)';

  @override
  String studentHomeFallbackName(String id) {
    return 'Student $id';
  }

  @override
  String get studentHomeLoading => 'Student dashboard is loading';

  @override
  String studentHomeWelcome(String name) {
    return 'Welcome, $name';
  }

  @override
  String studentHomeClass(String name) {
    return 'Class: $name';
  }

  @override
  String get studentHomeAssignmentPending => 'assignment pending';

  @override
  String get studentHomeLiveSessionsNone => 'Live sessions: none';

  @override
  String studentHomeLiveSessionsCount(String count) {
    return 'Live sessions: $count';
  }

  @override
  String get studentHomeSessionNumberKey2 => '2: Session number';

  @override
  String get studentHomeSessionName => 'Session name';

  @override
  String get studentHomeSubjectFilter => 'Subject filter';

  @override
  String get studentHomePlaylistsKey4 => '4: My Playlists · Private';

  @override
  String get studentHomeQuizzesKey5 => '5: Quizzes';

  @override
  String get studentHomeJourneysKey6 => '6: Learning Journeys';

  @override
  String studentHomeTeacher(String name) {
    return 'Teacher: $name';
  }

  @override
  String studentHomeSessionOkToJoin(String number) {
    return 'Session $number. OK to join';
  }

  @override
  String studentHomeJoinSessionLabel(String session) {
    return '$session. Join session';
  }

  @override
  String adminActiveAssignmentCount(String count) {
    return '$count active assignments';
  }

  @override
  String adminHeadingCount(String heading, String count) {
    return '$heading ($count)';
  }

  @override
  String get adminTextDialogHelper =>
      'Press OK to type, then 1 to save or 0 to cancel';

  @override
  String get adminSaveKey1 => 'Save (1)';

  @override
  String adminManageUser(String name) {
    return 'Manage $name';
  }

  @override
  String get adminManageAssignmentsKey1 => '1: Manage assignments';

  @override
  String get adminPasswordRecoveryKey2 => '2: Password recovery';

  @override
  String adminRemoveStudentFromClass(String name, String className) {
    return 'Remove $name from $className (2)';
  }

  @override
  String get adminRemoveClassKey2 => 'Remove class (2)';

  @override
  String get adminAssignKey1 => 'Assign (1)';

  @override
  String adminAssignTeacher(String name) {
    return 'Assign $name';
  }

  @override
  String get adminCurrentAssignments => 'Current assignments';

  @override
  String adminRemoveTeacherAssignment(
    String name,
    String className,
    String subjectName,
  ) {
    return 'Remove $name from $className, $subjectName';
  }

  @override
  String get adminAddAssignment => 'Add an assignment';

  @override
  String get adminAppBarTitle => 'SEEDS Administration';

  @override
  String get adminRefreshKey1 => '1: Refresh administration data';

  @override
  String get adminLoading => 'Loading administration data';

  @override
  String adminChangeSectionKey7(String section) {
    return '7: Change section. Now: $section';
  }

  @override
  String get adminSearchKey2 => '2: Search by name or phone number';

  @override
  String get adminSearchHelper => 'Press OK when done to show matches';

  @override
  String adminRoleFilterChipsLabel(String label) {
    return 'Account type filter: $label, selected. Use left and right arrows to change.';
  }

  @override
  String get adminAccountTypeKey3 => '3: Account type';

  @override
  String get adminChipAllAccounts => 'All accounts';

  @override
  String get adminChipStudents => 'Students';

  @override
  String get adminChipTeachers => 'Teachers';

  @override
  String adminAssignmentFilterChipsLabel(String label) {
    return 'Assignment filter: $label, selected. Use left and right arrows to change.';
  }

  @override
  String get adminAssignmentKey4 => '4: Assignment';

  @override
  String get adminChipAll => 'All';

  @override
  String get adminCreateSubjectKey5 => '5: Create subject';

  @override
  String get adminCreateClassKey6 => '6: Create class';

  @override
  String get adminStatusActive => 'Active';

  @override
  String get adminClassTileHint => 'Press OK for subjects, or to archive';

  @override
  String get adminPressOkRestore => 'Press OK to restore';

  @override
  String get adminPressOkArchive => 'Press OK to archive';

  @override
  String sessionTitleTeacher(String title) {
    return '$title (Teacher)';
  }

  @override
  String get libraryStatusStopped => 'Stopped';

  @override
  String libraryUploadFileName(String name) {
    return 'File: $name';
  }

  @override
  String libraryAudioSessionTitle(String number) {
    return 'Audio - Session $number';
  }

  @override
  String libraryRecordingsCount(String count) {
    return '$count recordings';
  }

  @override
  String libraryUploadedAt(String date) {
    return 'Uploaded: $date';
  }

  @override
  String libraryStopPreviewOf(String title) {
    return 'Stop preview of $title';
  }

  @override
  String libraryPreviewPrivately(String title) {
    return 'Preview $title privately';
  }

  @override
  String libraryPlayForEveryone(String title) {
    return 'Play $title for everyone in the session';
  }

  @override
  String get librarySelectClassHint =>
      'Select a class to play recorded lessons. Online lessons require internet. Use Downloaded lessons for saved audio.';

  @override
  String libraryFoundCount(String count) {
    return '$count found';
  }

  @override
  String get librarySearchSessionHint =>
      'Use \"Search by Session Name\" above to access a class quickly.';

  @override
  String librarySessionHash(String number) {
    return 'Session #$number';
  }

  @override
  String libraryStatusFinished(String title) {
    return 'Finished $title';
  }

  @override
  String libraryStatusPaused(String title) {
    return 'Paused $title';
  }

  @override
  String libraryStatusPlaying(String title) {
    return 'Playing $title';
  }

  @override
  String get libraryTitleField => 'Title';

  @override
  String get libraryDescriptionOptional => 'Description (optional)';

  @override
  String libraryAudioLibrarySession(String number) {
    return 'Audio Library, session $number';
  }

  @override
  String get libraryUploadingAudio => 'Uploading audio';

  @override
  String get libraryAddAudioKey3Tooltip => 'Add audio, key 3';

  @override
  String get libraryAddAudioKey3 => '3: Add audio';

  @override
  String get libraryNoRecordingsForClass => 'No recordings for this class yet.';

  @override
  String get libraryNoRecordingsAskTeacher =>
      'No recordings available yet. Ask your teacher to upload some.';

  @override
  String libraryPositionSpeed(String position, String total, String speed) {
    return '$position of $total. Speed ${speed}x';
  }

  @override
  String libraryNowPlaying(String title) {
    return 'Now playing: $title';
  }

  @override
  String libraryRecordingsMatch(String count, String total) {
    return '$count of $total recordings match';
  }

  @override
  String get libraryNoUnlinkedAudio => 'No unlinked audio available.';

  @override
  String get libraryNoSearchMatches => 'No recordings match your search.';

  @override
  String get libraryFindingLesson => 'Finding your lesson';

  @override
  String get libraryTitleRequiredField => 'Title *';

  @override
  String get libraryUploadNewAudio => 'Upload New Audio';

  @override
  String get libraryStopPreview => 'Stop Preview';

  @override
  String get libraryPreviewOnlyMe => 'Preview (Only Me)';

  @override
  String get libraryPreview => 'Preview';

  @override
  String get libraryStop => 'Stop';

  @override
  String get libraryPlayInSession => 'Play in Session';

  @override
  String get librarySessionShort => 'Session';

  @override
  String get libraryNotesTooltip => 'Private notes and recording drafts';

  @override
  String get libraryBrowseClassesKey5 => '5: Browse active classes';

  @override
  String get librarySearchClassByName => 'Search Class by Name';

  @override
  String get librarySearchClassHint => 'Enter Session/Class Name';

  @override
  String get libraryMyAudioLibrary => 'My Audio Library';

  @override
  String get libraryAllAudioFiles => 'All Audio Files';

  @override
  String get libraryManageAudioFiles => 'Manage and upload your audio files';

  @override
  String get libraryBrowseAudioFiles => 'Browse all uploaded audio files';

  @override
  String get libraryActiveClasses => 'Active Classes';

  @override
  String get libraryNoActiveClasses => 'No active classes found.';

  @override
  String get libraryAddAudioToSessions => 'Add audio to sessions';

  @override
  String get libraryConfirmKey1 => '1: Confirm';

  @override
  String get libraryDownloadLessons => 'Download lessons';

  @override
  String get libraryRepeatHelp => 'Repeat help';

  @override
  String get libraryBack10s => 'Back 10 s';

  @override
  String get libraryPause => 'Pause';

  @override
  String get libraryPlay => 'Play';

  @override
  String get libraryForward10s => 'Forward 10 s';

  @override
  String get libraryCloseAddAudio => 'Close add audio options';

  @override
  String get libraryUploadNewFileKey1 => '1: Upload New File';

  @override
  String get librarySelectExistingKey2 => '2: Select from Existing Library';

  @override
  String get librarySelectAudio => 'Select Audio';

  @override
  String get libraryRefreshAvailable => 'Refresh available audio';

  @override
  String get librarySearchByTitle => 'Search by title';

  @override
  String get libraryNothingPlaying =>
      'Nothing playing. Select a lesson or press 5.';

  @override
  String spokenDayMonthYear(String day, String month, String year) {
    return '$day $month $year';
  }

  @override
  String get downloadPartialReserve =>
      'Partial files reserve their complete size.';

  @override
  String downloadProgressStarting(String title) {
    return '$title: starting downloaded';
  }

  @override
  String downloadPercentDone(String title, String percent) {
    return '$title: $percent percent downloaded';
  }

  @override
  String downloadRecordUnreadable(String id) {
    return 'Download record $id could not be read. Files are kept. Remove only this download to recover; progress and bookmarks are kept.';
  }

  @override
  String downloadRemoveUnreadable(String id) {
    return 'Remove unreadable download $id';
  }

  @override
  String get downloadStatusDownloaded => 'Downloaded';

  @override
  String get downloadStatusPartial => 'Partial download';

  @override
  String downloadSizeRenewal(String megabytes) {
    return '$megabytes MB. Access renewal required.';
  }

  @override
  String downloadSizeExpires(String megabytes, String date) {
    return '$megabytes MB. Access expires on $date.';
  }

  @override
  String get downloadTitle => 'Downloads';

  @override
  String get downloadAccessInfo =>
      '30-day offline access. Other accounts have separate allowances. No automatic deletion.';

  @override
  String get downloadRefreshKey1 => '1: Refresh downloads';

  @override
  String get downloadFindOnlineKey2 => '2: Find recordings online';

  @override
  String get downloadReadStatusKey3 => '3: Read status';

  @override
  String get downloadCancelKey4 => '4: Cancel download';

  @override
  String get downloadNoneYetFindOnline =>
      'No downloads yet. Find recordings online or open Downloads from a class or playlist.';

  @override
  String get downloadPlayLesson => 'Play downloaded lesson';

  @override
  String get downloadRenewOnline => 'Renew access online';

  @override
  String get downloadRemove => 'Remove download';

  @override
  String get downloadListedKey5 => '5: Download listed recordings';

  @override
  String get downloadAvailableInfo =>
      'Available recordings. Downloads use internet data.';

  @override
  String playlistClassSubjectTitle(String className, String subjectName) {
    return '$className · $subjectName Playlists';
  }

  @override
  String get playlistStatusPrivate => 'Private';

  @override
  String get playlistClassPlaylist => 'Class playlist';

  @override
  String playlistItemCount(String count) {
    return '$count items';
  }

  @override
  String playlistClassItemCount(
    String className,
    String subjectName,
    String count,
  ) {
    return '$className, $subjectName, $count items';
  }

  @override
  String get playlistFinished => 'Finished. End of playlist';

  @override
  String get playlistAddKey2 => '2 Add';

  @override
  String get playlistAddAudioKey2Label => 'Add audio, key 2';

  @override
  String get playlistPauseKey5 => '5 Pause';

  @override
  String get playlistPlayKey5 => '5 Play';

  @override
  String playlistPauseTitleKey5(String title) {
    return 'Pause $title, key 5';
  }

  @override
  String playlistPlayTitleKey5(String title) {
    return 'Play $title, key 5';
  }

  @override
  String get playlistPreviousKey3 => '3 Previous';

  @override
  String get playlistPreviousItemKey3 => 'Previous item, key 3';

  @override
  String get playlistNextKey8 => '8 Next';

  @override
  String get playlistNextItemKey8 => 'Next item, key 8';

  @override
  String get playlistRestore => 'Restore';

  @override
  String get playlistArchive => 'Archive';

  @override
  String get playlistDeletePlaylist => 'Delete playlist';

  @override
  String playlistRestoreNamedButton(String title) {
    return 'Restore $title';
  }

  @override
  String playlistArchiveNamedButton(String title) {
    return 'Archive $title';
  }

  @override
  String playlistDeleteNamedButton(String title) {
    return 'Delete $title';
  }

  @override
  String playlistMoveUp(String title) {
    return 'Move $title up';
  }

  @override
  String playlistMoveDown(String title) {
    return 'Move $title down';
  }

  @override
  String get playlistCreateKey2 => '2: Create playlist';

  @override
  String get playlistNoneInClass =>
      'No playlists in this class and subject. Press 2 to create one.';

  @override
  String get playlistMyPlaylists => 'My Playlists';

  @override
  String get playlistPrivateNoticeTitle => 'Your playlists are private';

  @override
  String get playlistPrivateNoticeText =>
      'Teachers, administrators, and other students cannot view them.';

  @override
  String get playlistCreatePrivateKey2 => '2: Create private playlist';

  @override
  String get playlistMyPrivateHeading => 'My private playlists';

  @override
  String get playlistNoPrivate => 'No private playlists yet.';

  @override
  String get playlistClassHeading => 'Class playlists';

  @override
  String get playlistNoClassPublished => 'No class playlists published yet.';

  @override
  String get playlistAddAudioTitle => 'Add audio';

  @override
  String get playlistUnavailableRetry =>
      'Playlist is unavailable. Press 1 to try again.';

  @override
  String get playlistDownloadRecordings => 'Download playlist recordings';

  @override
  String get playlistMoveHint =>
      'Play or select an item, then move it up or down.';

  @override
  String get playlistNoAudio => 'This playlist has no audio yet.';

  @override
  String quizClassSubjectHeading(String className, String subjectName) {
    return '$className · $subjectName';
  }

  @override
  String get quizBankEditNote =>
      'Editing a bank question never changes an existing quiz snapshot.';

  @override
  String get quizNoBankQuestions => 'No bank questions yet';

  @override
  String quizOptionsCount(String count) {
    return '$count options';
  }

  @override
  String get quizNoQuizzesYet => 'No quizzes yet';

  @override
  String get quizStepReviewPublish => 'Step 3: Review and publish';

  @override
  String get quizStepAddQuestions => 'Step 2: Add questions';

  @override
  String quizResultsTitle(String title) {
    return '$title results';
  }

  @override
  String get quizAllAttempted => 'All students have attempted';

  @override
  String get quizRemindAllKey2 => '2: Remind all not attempted';

  @override
  String get uiNoneCapital => 'None';

  @override
  String get quizPracticeParticipationHeading =>
      'Practice participation, not academic grades';

  @override
  String get quizIndividualScores => 'Individual student scores';

  @override
  String get quizNotAttempted => 'Not attempted';

  @override
  String get quizPracticeNotGraded => 'Practice, not graded';

  @override
  String quizHighestScore(String score) {
    return 'Highest score: $score';
  }

  @override
  String get quizAttemptInProgress => 'Attempt in progress';

  @override
  String get quizQuizzesTitle => 'Quizzes';

  @override
  String get quizRefreshQuizzesTooltip => 'Refresh quizzes';

  @override
  String get quizLoadingQuizzes => 'Loading quizzes';

  @override
  String get quizNewBankQuestionKey2 => '2: New bank question';

  @override
  String get quizNewDraftKey3 => '3: New quiz draft';

  @override
  String get quizCreatePracticeKey4 => '4: Create untimed practice';

  @override
  String get quizPrivateBankHeading => 'Private question bank';

  @override
  String get quizOptionsButton => 'Options';

  @override
  String get quizManagementHeading => 'Quiz management';

  @override
  String get quizContinueCreation => 'Continue creation';

  @override
  String get quizCloseButton => 'Close';

  @override
  String get quizDuplicateButton => 'Duplicate';

  @override
  String get quizResultsButton => 'Results';

  @override
  String get quizRefreshResultsTooltip => 'Refresh results';

  @override
  String get quizClassStatistics => 'Class statistics';

  @override
  String get quizStudentsYetToAttempt => 'Students yet to attempt';

  @override
  String get quizNoQuizzesAvailableLabel => 'No quizzes available';

  @override
  String get quizAttemptLimitReachedLabel => 'Attempt limit reached';

  @override
  String get quizAnswerSavedLockedTitle => 'Answer saved and locked';

  @override
  String get quizAllSavedViewResult =>
      'All answers are saved. Select View result to confirm completion.';

  @override
  String quizAsksToConfirm(String label) {
    return '$label, asks to confirm';
  }

  @override
  String get quizConfirmingCompletion => 'Confirming completion';

  @override
  String get quizRetryCompletionKey5 => '5: Retry completion';

  @override
  String get quizViewResultKey5 => '5: View result';

  @override
  String quizHistoryTitle(String title) {
    return '$title history';
  }

  @override
  String get quizNoAttemptsYet => 'No attempts yet';

  @override
  String get quizHistoryTooltip => 'Attempt history and review';

  @override
  String get quizLeaveWithoutSubmitting => 'Leave without submitting';

  @override
  String get quizAttemptCompletePrivateLabel =>
      'Attempt complete. Result private. Use Read result privately.';

  @override
  String get quizReadResultKey8 => '8: Read result privately';

  @override
  String get quizReturnKey0 => '0: Return to quizzes';

  @override
  String get quizReadAllOptionsLabel => 'Read all options';

  @override
  String get quizSubmitAnswerKey5 => '5: Submit answer';

  @override
  String get quizAnswerLockedActivate =>
      'Answer saved and locked. Activate to read feedback privately.';

  @override
  String get quizReadSelectedAnswer => 'Read selected answer';

  @override
  String get quizReadRemainingTime => 'Read remaining time';

  @override
  String get quizAttemptReviewTitle => 'Attempt review';

  @override
  String get quizEditorIntro =>
      'Complete the question and all four options, then choose the correct answer. For equations or diagrams, expand optional spoken notation and review the alternatives.';

  @override
  String get quizWhichCorrect => 'Which answer is correct?';

  @override
  String get quizChooseCorrectOption => 'Choose the correct option';

  @override
  String quizOptionWithText(String number, String text) {
    return 'Option $number: $text';
  }

  @override
  String get quizCorrectChoiceHint =>
      'Use Left or Right to change. OK or tap selects the next option.';

  @override
  String get quizExplanationOptional => 'Explanation (optional)';

  @override
  String get quizContentDescribedText =>
      'Content: Teacher-described notation or diagram';

  @override
  String get quizNotationNote =>
      'No automatic equation or diagram interpretation is provided. Teachers must write and review English spoken alternatives. For described notation, include the question, all options, and any explanation.';

  @override
  String get quizReviewedAlternatives =>
      'I have reviewed the spoken alternatives for accuracy';

  @override
  String get quizChangeSettings => 'Change quiz settings';

  @override
  String get quizCreatePracticeText => 'Create untimed practice';

  @override
  String get quizStepName => 'Step 1: Name your quiz';

  @override
  String get quizPracticeInfo =>
      'Practice has no per-attempt timer or retry cap. An optional closing time still ends availability.';

  @override
  String get quizSettingsNavLabel =>
      'Use up and down to move through quiz settings. Press OK to edit text fields. Opening and closing times are optional.';

  @override
  String get quizSettingsNavText =>
      'Use Up and Down to move through settings, and OK to edit. Saving a draft or its settings does not publish the quiz.';

  @override
  String get quizSettingsReviewInfo =>
      'Review and change the saved settings below. Saving does not publish the quiz.';

  @override
  String get quizPracticeDefaults =>
      'Ungraded practice. Unlimited attempts, no timer, immediate feedback.';

  @override
  String get quizGradedDefaults =>
      'Default graded settings: one attempt, no timer, feedback after final submission.';

  @override
  String get quizHideOptionalSettingsText => 'Hide optional settings';

  @override
  String get quizShowOptionalSettingsText => 'Show optional settings';

  @override
  String get quizAttemptLimitFieldText => 'Attempt limit, 1 to 20';

  @override
  String get quizTimeLimitFieldText => 'Time limit in minutes (optional)';

  @override
  String get quizUntimedInfo =>
      'Untimed and ungraded, unlimited retries. Availability times still apply if set.';

  @override
  String quizFeedbackValue(String policy) {
    return 'Feedback: $policy';
  }

  @override
  String quizReleaseValue(String time) {
    return 'Release: $time';
  }

  @override
  String quizOpeningTimeLabel(String time) {
    return '$time. Press OK to set opening time. Left clears it.';
  }

  @override
  String get quizNoOpeningTimeSet => 'No opening time set';

  @override
  String get quizNoOpeningTimeShort => 'No opening time';

  @override
  String get quizOpeningTimeHint =>
      'Optional · enter year, month, day, hour and minute';

  @override
  String quizClosingTimeLabel(String time) {
    return '$time. Press OK to set closing time. Left clears it.';
  }

  @override
  String get quizNoClosingTimeSet => 'No closing time set';

  @override
  String get quizNoClosingTimeShort => 'No closing time';

  @override
  String get quizClosingTimeHint => 'Optional · must be after opening time';

  @override
  String get quizShuffleQuestions => 'Shuffle questions once per attempt';

  @override
  String get quizShuffleOptions => 'Shuffle options once per attempt';

  @override
  String messageProblem(String text) {
    return 'Problem: $text';
  }

  @override
  String messageMessage(String text) {
    return 'Message: $text';
  }

  @override
  String get adminSetupSectionAccounts => 'Accounts';

  @override
  String get adminSetupSectionCatalog => 'Classes and subjects';

  @override
  String get adminSetupSectionTimetable => 'Timetable';

  @override
  String get adminSetupSectionSchedule => 'Today\'s schedule';

  @override
  String get adminSetupSectionSharedPhones => 'Shared phones';

  @override
  String get adminSetupSectionHolidays => 'Holidays';

  @override
  String get adminSetupSectionIssues => 'Issues';

  @override
  String get adminSetupSectionRecords => 'Class records';

  @override
  String get adminSetupSectionPicker => 'Section';

  @override
  String adminSetupRefresh(String section) {
    return 'Refresh $section';
  }

  @override
  String get adminSetupLogOut => 'Log out';

  @override
  String get adminSetupLoading => 'Loading';

  @override
  String get adminSetupSaving => 'Saving';

  @override
  String get adminSetupRetry => 'Try again';

  @override
  String adminSetupLoadFailed(String reason) {
    return 'This list could not be loaded. $reason';
  }

  @override
  String get adminSetupUnknownError =>
      'Something went wrong. Please try again.';

  @override
  String get adminSetupNotSaved =>
      'The change could not be saved. Refresh and try again.';

  @override
  String get adminSetupCancel => 'Cancel';

  @override
  String get adminSetupSave => 'Save';

  @override
  String get adminSetupClose => 'Close';

  @override
  String get adminSetupDelete => 'Delete';

  @override
  String get adminSetupRemove => 'Remove';

  @override
  String get adminSetupEdit => 'Edit';

  @override
  String adminSetupEditNamed(String name) {
    return 'Edit $name';
  }

  @override
  String adminSetupRequiredField(String field) {
    return '$field is required.';
  }

  @override
  String get adminSetupNoDate => 'Not set';

  @override
  String adminSetupDateValue(String field, String date) {
    return '$field: $date';
  }

  @override
  String adminSetupClearDate(String field) {
    return 'Clear $field';
  }

  @override
  String adminSetupDateFormat(
    String weekday,
    String day,
    String month,
    String year,
  ) {
    return '$weekday $day $month $year';
  }

  @override
  String adminSetupDateTime(String date, String time) {
    return '$date, $time';
  }

  @override
  String get adminSetupDateField => 'Date';

  @override
  String get adminSetupInactive => 'Deactivated';

  @override
  String get adminSetupFilterAll => 'All';

  @override
  String get adminSetupShowFilter => 'Show';

  @override
  String get adminSetupRoleStudent => 'Student';

  @override
  String get adminSetupRoleTeacher => 'Teacher';

  @override
  String get adminSetupAddPerson => 'Add person';

  @override
  String get adminSetupSearchLabel => 'Search by name or phone number';

  @override
  String get adminSetupSearchButton => 'Search';

  @override
  String get adminSetupAccountTypeHeading => 'Account type';

  @override
  String get adminSetupAssignmentHeading => 'Class or subject assignment';

  @override
  String adminSetupAccountsShown(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count accounts shown.',
      one: '1 account shown.',
      zero: 'No matching accounts.',
    );
    return '$_temp0';
  }

  @override
  String adminSetupTeachersHeading(int count) {
    return 'Teachers ($count)';
  }

  @override
  String adminSetupStudentsHeading(int count) {
    return 'Students ($count)';
  }

  @override
  String get adminSetupNameField => 'Name';

  @override
  String get adminSetupPhoneField => 'Phone number';

  @override
  String get adminSetupRoleField => 'Role';

  @override
  String get adminSetupTeacherPairsHeading =>
      'Classes and subjects this teacher teaches';

  @override
  String get adminSetupNoPairs => 'None yet. You can add them later.';

  @override
  String get adminSetupClassField => 'Class';

  @override
  String get adminSetupSubjectField => 'Subject';

  @override
  String get adminSetupAddPair => 'Add class and subject';

  @override
  String adminSetupPairLabel(String className, String subject) {
    return '$className, $subject';
  }

  @override
  String adminSetupRemovePair(String className, String subject) {
    return 'Remove $className, $subject';
  }

  @override
  String get adminSetupNoSubjectsInClass =>
      'This class has no subjects yet. Add subjects under Classes and subjects.';

  @override
  String get adminSetupNoActiveClasses =>
      'There are no active classes yet. Add one under Classes and subjects.';

  @override
  String adminSetupPersonAdded(String name) {
    return '$name was added.';
  }

  @override
  String adminSetupEditPerson(String name) {
    return 'Edit $name';
  }

  @override
  String get adminSetupPhoneChangeNote =>
      'Changing the phone number signs this person out on every phone.';

  @override
  String adminSetupPersonSaved(String name) {
    return 'Changes to $name were saved.';
  }

  @override
  String get adminSetupDeactivate => 'Deactivate';

  @override
  String get adminSetupActivate => 'Activate';

  @override
  String adminSetupDeactivateNamed(String name) {
    return 'Deactivate $name';
  }

  @override
  String adminSetupActivateNamed(String name) {
    return 'Activate $name';
  }

  @override
  String adminSetupDeactivateTitle(String name) {
    return 'Deactivate $name?';
  }

  @override
  String adminSetupDeactivateMessage(String name) {
    return '$name will be signed out and cannot sign in until the account is activated again.';
  }

  @override
  String adminSetupActivated(String name) {
    return '$name can sign in again.';
  }

  @override
  String adminSetupDeactivated(String name) {
    return '$name was deactivated.';
  }

  @override
  String get adminSetupSignOutEverywhere => 'Sign out everywhere';

  @override
  String adminSetupSignOutNamed(String name) {
    return 'Sign $name out everywhere';
  }

  @override
  String adminSetupSignOutTitle(String name) {
    return 'Sign $name out everywhere?';
  }

  @override
  String adminSetupSignOutMessage(String name) {
    return 'This ends $name\'s sign-in on every phone, for example if someone else used their number. They can sign in again with their phone number.';
  }

  @override
  String adminSetupSignedOut(String name) {
    return '$name was signed out everywhere.';
  }

  @override
  String get adminSetupStudentClassAction => 'Change class';

  @override
  String get adminSetupTeacherAssignmentsAction => 'Classes and subjects';

  @override
  String adminSetupStudentDetail(String className) {
    return 'Student. Class: $className';
  }

  @override
  String get adminSetupStudentNoClass => 'Student. No class yet.';

  @override
  String adminSetupTeacherDetail(String pairs) {
    return 'Teacher. Teaches: $pairs';
  }

  @override
  String get adminSetupTeacherNoPairs => 'Teacher. No classes or subjects yet.';

  @override
  String adminSetupPhoneDetail(String phone) {
    return 'Phone: $phone';
  }

  @override
  String adminSetupClassDialogTitle(String name) {
    return 'Class for $name';
  }

  @override
  String adminSetupRemoveFromClass(String className) {
    return 'Remove from $className';
  }

  @override
  String adminSetupStudentEnrolled(String name, String className) {
    return '$name is now in $className.';
  }

  @override
  String adminSetupStudentRemoved(String name) {
    return '$name was removed from their class.';
  }

  @override
  String adminSetupAssignmentsTitle(String name) {
    return 'Classes and subjects for $name';
  }

  @override
  String get adminSetupCurrentPairs => 'Currently teaches';

  @override
  String adminSetupPairAdded(String name, String className, String subject) {
    return '$name now teaches $className, $subject.';
  }

  @override
  String adminSetupPairRemoved(String name, String className, String subject) {
    return '$name no longer teaches $className, $subject.';
  }

  @override
  String get adminSetupClassesHeading => 'Classes';

  @override
  String get adminSetupSubjectsHeading => 'Subjects';

  @override
  String get adminSetupAddClass => 'Add class';

  @override
  String get adminSetupAddSubject => 'Add subject';

  @override
  String get adminSetupNoClasses => 'No classes yet.';

  @override
  String get adminSetupNoSubjects => 'No subjects yet.';

  @override
  String get adminSetupSubjectsButton => 'Subjects';

  @override
  String adminSetupClassSubjects(String className) {
    return 'Subjects in $className';
  }

  @override
  String adminSetupArchiveNamed(String name) {
    return 'Archive $name';
  }

  @override
  String adminSetupRestoreNamed(String name) {
    return 'Restore $name';
  }

  @override
  String get adminSetupNoSubjectsToChoose =>
      'There are no active subjects yet. Add a subject first.';

  @override
  String get adminSetupAddLesson => 'Add lesson to timetable';

  @override
  String get adminSetupEditLesson => 'Edit timetable lesson';

  @override
  String get adminSetupAllTeachers => 'All teachers';

  @override
  String get adminSetupAllClasses => 'All classes';

  @override
  String get adminSetupTeacherField => 'Teacher';

  @override
  String get adminSetupWeekdayField => 'Day of the week';

  @override
  String get adminSetupStartField => 'Start time';

  @override
  String get adminSetupEndField => 'End time';

  @override
  String get adminSetupTimeHelper =>
      '24-hour India time (IST), for example 09:30';

  @override
  String adminSetupTimeInvalid(String field) {
    return 'Enter the $field as 24-hour time, for example 09:30.';
  }

  @override
  String get adminSetupEndBeforeStart => 'The lesson must end after it starts.';

  @override
  String get adminSetupUntilBeforeFrom =>
      'The last date must be on or after the first date.';

  @override
  String get adminSetupValidFrom => 'First date';

  @override
  String get adminSetupValidUntil => 'Last date';

  @override
  String get adminSetupLessonField => 'Lesson playlist (optional)';

  @override
  String get adminSetupNoLesson => 'No lesson playlist';

  @override
  String get adminSetupNoLessonsFound =>
      'This teacher has no lesson playlists for this class and subject yet.';

  @override
  String get adminSetupShowInactive => 'Show deactivated lessons';

  @override
  String get adminSetupNoTimetable => 'No timetable lessons match.';

  @override
  String adminSetupEntryTitle(
    String start,
    String end,
    String subject,
    String className,
  ) {
    return '$start to $end: $subject, $className';
  }

  @override
  String adminSetupEntryTeacher(String name) {
    return 'Teacher: $name';
  }

  @override
  String adminSetupEntryLesson(String title) {
    return 'Lesson playlist: $title';
  }

  @override
  String get adminSetupEntryNoLesson => 'No lesson playlist chosen.';

  @override
  String adminSetupEntryFrom(String date) {
    return 'From $date';
  }

  @override
  String adminSetupEntryUntil(String date) {
    return 'Until $date';
  }

  @override
  String get adminSetupDateChanges => 'Date changes';

  @override
  String adminSetupDateChangesNamed(String title) {
    return 'Date changes for $title';
  }

  @override
  String get adminSetupDeactivateLesson => 'Deactivate';

  @override
  String get adminSetupReactivateLesson => 'Reactivate';

  @override
  String get adminSetupDeactivateLessonTitle => 'Deactivate this lesson?';

  @override
  String adminSetupDeactivateLessonMessage(
    String subject,
    String className,
    String weekday,
    String start,
  ) {
    return '$subject for $className on $weekday at $start will no longer be scheduled.';
  }

  @override
  String get adminSetupLessonSaved => 'Timetable saved.';

  @override
  String get adminSetupLessonDeactivated => 'Lesson deactivated.';

  @override
  String get adminSetupLessonReactivated => 'Lesson reactivated.';

  @override
  String adminSetupClassSubjectFixed(String className, String subject) {
    return '$className, $subject. To change the class or subject, deactivate this lesson and add a new one.';
  }

  @override
  String adminSetupDateChangesTitle(String lesson, String weekday) {
    return 'Date changes: $lesson, every $weekday';
  }

  @override
  String get adminSetupNoDateChanges => 'No date changes.';

  @override
  String get adminSetupAddDateChange => 'Change one date';

  @override
  String get adminSetupCancelledLabel => 'Cancelled on this date.';

  @override
  String adminSetupSubstituteLabel(String name) {
    return 'Substitute teacher: $name';
  }

  @override
  String get adminSetupDifferentLesson =>
      'A different lesson playlist is used on this date.';

  @override
  String adminSetupNoteLabel(String note) {
    return 'Note: $note';
  }

  @override
  String get adminSetupClearChange => 'Clear change';

  @override
  String adminSetupClearChangeNamed(String date) {
    return 'Clear the change for $date';
  }

  @override
  String adminSetupEditDateChangeNamed(String date) {
    return 'Edit the change for $date';
  }

  @override
  String adminSetupChangeCleared(String date) {
    return 'The change for $date was cleared.';
  }

  @override
  String adminSetupDateChangeTitle(String lesson) {
    return 'Change one date: $lesson';
  }

  @override
  String get adminSetupCancelOnDate => 'Cancel the lesson on this date';

  @override
  String get adminSetupSubstituteField => 'Substitute teacher (optional)';

  @override
  String adminSetupRegularTeacher(String name) {
    return 'No substitute ($name teaches)';
  }

  @override
  String get adminSetupDateLessonField => 'Lesson playlist on this date';

  @override
  String get adminSetupUsualLesson => 'Same as usual';

  @override
  String get adminSetupNoteField => 'Note (optional)';

  @override
  String adminSetupDateChangeSaved(String date) {
    return 'The change for $date was saved.';
  }

  @override
  String get adminSetupChooseDateFirst => 'Choose a date.';

  @override
  String get adminSetupPreviousDay => 'Previous day';

  @override
  String get adminSetupNextDay => 'Next day';

  @override
  String get adminSetupToday => 'Today';

  @override
  String adminSetupScheduleFor(String date) {
    return 'Lessons on $date';
  }

  @override
  String get adminSetupNoLessonsOnDay => 'No lessons on this date.';

  @override
  String adminSetupScheduleSubstitute(String name) {
    return 'Teacher: $name (substitute)';
  }

  @override
  String adminSetupStateLabel(String state) {
    return 'Status: $state';
  }

  @override
  String get adminSetupStateUpcoming => 'Upcoming';

  @override
  String get adminSetupStateLive => 'Live now';

  @override
  String get adminSetupStateHeld => 'Held';

  @override
  String get adminSetupStateCancelled => 'Cancelled';

  @override
  String get adminSetupStateNotStarted => 'Not started';

  @override
  String get adminSetupLessonReady => 'Lesson playlist ready.';

  @override
  String get adminSetupSharedPhoneNote =>
      'On a shared phone, each person enters the shared phone number, then their short profile number. The profile number only chooses whose account opens. It is not a password.';

  @override
  String get adminSetupAddSharedPhone => 'Add shared phone';

  @override
  String get adminSetupEditSharedPhone => 'Edit shared phone';

  @override
  String get adminSetupSharedPhoneName => 'Name, for example Class 5 phone';

  @override
  String get adminSetupSharedPhoneNumber => 'Shared phone number';

  @override
  String get adminSetupSharedPhoneActiveSwitch => 'Shared phone can be used';

  @override
  String get adminSetupSharedPhoneSaved => 'Shared phone saved.';

  @override
  String get adminSetupNoSharedPhones => 'No shared phones yet.';

  @override
  String adminSetupGroupNumber(String phone) {
    return 'Number: $phone';
  }

  @override
  String adminSetupMemberLine(String name, String role, String code) {
    return '$name, $role. Profile number $code';
  }

  @override
  String get adminSetupNoMembers => 'No people on this phone yet.';

  @override
  String get adminSetupAddMember => 'Add person';

  @override
  String adminSetupAddMemberTitle(String group) {
    return 'Add a person to $group';
  }

  @override
  String get adminSetupSearchPeople => 'Search people by name or phone number';

  @override
  String get adminSetupNoPeopleFound => 'No matching people.';

  @override
  String get adminSetupPersonField => 'Person';

  @override
  String adminSetupPersonOption(String name, String role, String phone) {
    return '$name, $role, $phone';
  }

  @override
  String get adminSetupChoosePerson => 'Choose a person.';

  @override
  String get adminSetupProfileCodeField => 'Profile number';

  @override
  String get adminSetupProfileCodeHelper =>
      '1 to 4 digits, different for each person on this phone.';

  @override
  String get adminSetupProfileCodeInvalid =>
      'Enter a profile number of 1 to 4 digits.';

  @override
  String adminSetupMemberAdded(String name, String group) {
    return '$name was added to $group.';
  }

  @override
  String adminSetupRemoveMemberNamed(String name, String group) {
    return 'Remove $name from $group';
  }

  @override
  String adminSetupRemoveMemberTitle(String name, String group) {
    return 'Remove $name from $group?';
  }

  @override
  String adminSetupRemoveMemberMessage(String name) {
    return '$name will no longer be able to choose their profile on this shared phone.';
  }

  @override
  String adminSetupMemberRemoved(String name, String group) {
    return '$name was removed from $group.';
  }

  @override
  String get adminSetupHolidayNote => 'No lessons are scheduled on holidays.';

  @override
  String get adminSetupAddHoliday => 'Add holiday';

  @override
  String get adminSetupHolidayName => 'Holiday name';

  @override
  String get adminSetupNoHolidays => 'No holidays yet.';

  @override
  String adminSetupHolidayAdded(String name, String date) {
    return '$name on $date was added.';
  }

  @override
  String adminSetupDeleteHolidayNamed(String name, String date) {
    return 'Delete $name on $date';
  }

  @override
  String get adminSetupDeleteHolidayTitle => 'Delete this holiday?';

  @override
  String adminSetupDeleteHolidayMessage(String name, String date) {
    return '$name on $date will be removed, and lessons will be scheduled on that date again.';
  }

  @override
  String get adminSetupHolidayDeleted => 'The holiday was deleted.';

  @override
  String get adminSetupIssuesOpen => 'Open';

  @override
  String get adminSetupIssuesResolved => 'Resolved';

  @override
  String get adminSetupNoIssues => 'No issues to show.';

  @override
  String adminSetupIssueSeen(int count, String when) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Seen $count times.',
      one: 'Seen once.',
    );
    return '$_temp0 Last seen $when.';
  }

  @override
  String get adminSetupMarkResolved => 'Mark resolved';

  @override
  String adminSetupMarkResolvedNamed(String message) {
    return 'Mark resolved: $message';
  }

  @override
  String get adminSetupIssueResolved => 'Issue marked resolved.';

  @override
  String get adminSetupRecordsLive => 'Live';

  @override
  String get adminSetupRecordsEnded => 'Ended';

  @override
  String get adminSetupNoRecords => 'No classes to show.';

  @override
  String adminSetupRecordTitle(String subject, String className) {
    return '$subject, $className';
  }

  @override
  String get adminSetupRecordLive => 'Live now';

  @override
  String adminSetupRecordLiveUntil(String clock) {
    return 'Live now. Ends at $clock';
  }

  @override
  String adminSetupRecordStarted(String when) {
    return 'Started $when';
  }

  @override
  String adminSetupRecordEnded(String when) {
    return 'Ended $when';
  }

  @override
  String get adminSetupEndedByTeacher => 'The teacher ended the class.';

  @override
  String get adminSetupEndedByAdmin => 'An administrator ended the class.';

  @override
  String get adminSetupEndedAutomatically =>
      'The class ended automatically at its end time.';

  @override
  String adminSetupEndedOther(String reason) {
    return 'End reason: $reason';
  }

  @override
  String adminSetupStudentsJoined(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count students joined.',
      one: '1 student joined.',
      zero: 'No students joined.',
    );
    return '$_temp0';
  }

  @override
  String adminSetupExtensionMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count extra minutes added.',
      one: '1 extra minute added.',
      zero: 'No extra time added.',
    );
    return '$_temp0';
  }

  @override
  String get adminSetupAddFifteen => 'Add 15 minutes';

  @override
  String adminSetupAddFifteenNamed(String title) {
    return 'Add 15 minutes to $title';
  }

  @override
  String get adminSetupEndForEveryone => 'End class for everyone';

  @override
  String adminSetupEndForEveryoneNamed(String title) {
    return 'End $title for everyone';
  }

  @override
  String get adminSetupEndTitle => 'End this class for everyone?';

  @override
  String adminSetupEndMessage(String title) {
    return '$title will end now for the teacher and every student.';
  }

  @override
  String get adminSetupKeepClass => 'Keep class going';

  @override
  String get adminSetupEndClass => 'End class';

  @override
  String get adminSetupEnded => 'The class was ended.';

  @override
  String adminSetupExtended(String clock) {
    return 'The class now ends at $clock.';
  }

  @override
  String get loginScreenName => 'Sign in';

  @override
  String get loginIntro => 'Type your phone number, then press 1 to sign in.';

  @override
  String get loginPhoneField => 'Phone number. Type it with the number keys.';

  @override
  String get loginPhoneLabel => 'Phone number';

  @override
  String get loginProfileField => 'Your profile number on this shared phone';

  @override
  String get loginProfileLabel => 'Profile number';

  @override
  String get loginEnterProfileCode =>
      'This phone is shared. Type your profile number, then press 1.';

  @override
  String get loginKeySignIn => 'Sign in';

  @override
  String get loginKeyContinue => 'Continue';

  @override
  String get loginKeySim => 'Fill in my number from the SIM card';

  @override
  String get loginKeyAdmin => 'Administrator sign in';

  @override
  String get loginKeyChangeNumber => 'Use a different number';

  @override
  String get loginErrorEnterPhone => 'Type your phone number first.';

  @override
  String get loginErrorEnterProfile => 'Type your profile number first.';

  @override
  String get loginNumberNotRegistered =>
      'This number is not registered. Ask your school administrator to add you.';

  @override
  String get loginProfileNotRecognised =>
      'That profile number is not on this phone. Try again.';

  @override
  String get loginAdminUsesPassword =>
      'Administrators sign in with a password. Press 3.';

  @override
  String get loginSigningIn => 'Signing in.';

  @override
  String get adminLoginScreenName => 'Administrator sign in';

  @override
  String get adminLoginIntro =>
      'Type your phone number and password, then press 1.';

  @override
  String get classNoLongerLive => 'That class is not live now.';

  @override
  String get classAlertTitle => 'Class has started';

  @override
  String get classAlertBody => 'Your class has started. Open to join.';

  @override
  String get classAlertWaitingBody => 'Your class is live. Open to join.';

  @override
  String get classAlertChannelName => 'Class starting';

  @override
  String get classAlertChannelDescription =>
      'Rings for up to one minute when your class starts.';

  @override
  String get classAlertWaitingChannelName => 'Class live';

  @override
  String get classAlertWaitingChannelDescription =>
      'Stays while your class is live so you can join.';

  @override
  String get classAlertStarted => 'Your class has started.';

  @override
  String classAlertSubjectStarted(String subject) {
    return '$subject class has started.';
  }

  @override
  String get classAlertKeys =>
      'Press OK or 1 to join. Press 0 to stop the ringing.';

  @override
  String get classAlertJoin => 'Join class';

  @override
  String get classAlertNotNow => 'Not now';

  @override
  String get homeTitle => 'Home';

  @override
  String get homeChecking => 'Checking for your class.';

  @override
  String get homeOffline =>
      'No internet. Your class will appear when you are back online.';

  @override
  String get homeSignInAgain => 'Please sign in again.';

  @override
  String get homeStarForAll => 'Press star for all options.';

  @override
  String homeBriefLive(String subject) {
    return '$subject class is live. Press 1 to join.';
  }

  @override
  String homeBriefNext(String subject, String time) {
    return 'Next class: $subject at $time. You can use other options while you wait.';
  }

  @override
  String get homeBriefNoClass =>
      'No class right now. Press 2 to continue learning.';

  @override
  String homeJoinClass(String subject) {
    return 'Join $subject class';
  }

  @override
  String get homeNoClassNow => 'No class now';

  @override
  String get homeNoClassReason =>
      'Your class will appear here by itself when your teacher starts it.';

  @override
  String homeJoinWhenStarts(String subject, String time) {
    return 'Join $subject automatically when it starts at $time';
  }

  @override
  String get homeCancelAutoJoin => 'Stop joining automatically';

  @override
  String homeAutoJoinArmed(String subject) {
    return 'I will open $subject when your teacher starts it, if you stay on this screen. You will join muted. Press 1 to cancel.';
  }

  @override
  String get homeAutoJoinCancelled => 'Automatic joining cancelled.';

  @override
  String get homeAutoJoinLeft =>
      'Automatic joining stopped because you left the home screen.';

  @override
  String homeAutoJoined(String subject) {
    return '$subject has started. Joining you now, muted.';
  }

  @override
  String get homeReturningToClass => 'Returning to your class.';

  @override
  String get homeContinueLearning => 'Continue learning';

  @override
  String get homeNothingToContinue =>
      'Nothing to continue yet. Press 3 for learning journeys.';

  @override
  String homeContinuing(String title) {
    return 'Continuing $title.';
  }

  @override
  String get homeJourneys => 'Learning journeys';

  @override
  String get homeQuizzes => 'Quizzes';

  @override
  String get homeMore => 'More';

  @override
  String get homeMoreBrief => 'Less used options.';

  @override
  String homeYourClass(String className) {
    return 'Your class: $className.';
  }

  @override
  String homeSubjectInClass(String subject, String className) {
    return '$subject, $className';
  }

  @override
  String teacherHomeBriefLive(String subject) {
    return 'Your $subject class is live. Press 1 to return to it.';
  }

  @override
  String teacherHomeBriefReady(String place) {
    return '$place is ready. Press 1 to start it.';
  }

  @override
  String teacherHomeBriefNext(String place, String time) {
    return 'Next class: $place at $time.';
  }

  @override
  String get teacherHomeBriefNoClass => 'No class on your timetable now.';

  @override
  String teacherHomeReturn(String subject) {
    return 'Return to $subject class';
  }

  @override
  String teacherHomeStart(String place) {
    return 'Start $place';
  }

  @override
  String teacherHomeNext(String place, String time) {
    return 'Next: $place at $time';
  }

  @override
  String teacherHomeOpensAt(String time) {
    return 'You can start it from $time.';
  }

  @override
  String get teacherHomeNoClassReason =>
      'Nothing is scheduled now. To teach anyway, press 5 for More, then 3.';

  @override
  String get teacherHomeStarting => 'Starting your class.';

  @override
  String teacherHomeStarted(String subject) {
    return '$subject class started. Your students are being called.';
  }

  @override
  String get teacherHomeUnscheduled => 'Start an unscheduled class';

  @override
  String get teacherHomeUnscheduledTitle =>
      'Which class do you want to teach now?';

  @override
  String get teacherHomeAlreadyLive =>
      'You already have a live class. Press 1 on Home to return to it.';

  @override
  String get teacherHomeChangeWorkspace =>
      'Change class and subject for lessons';

  @override
  String get teacherHomeOneWorkspace => 'You teach one class and subject.';

  @override
  String teacherHomeContentFor(String place) {
    return 'Lessons, quizzes and playlists are for $place.';
  }

  @override
  String teacherHomeLaterItem(String place, String time) {
    return 'Later: $place at $time.';
  }

  @override
  String get keyClassListWhoJoined =>
      'Class list: who is here, who left, who has not joined';

  @override
  String get keyMuteAllStudents => 'Mute all students';

  @override
  String get keyTeacherToolsAddTimeOrEnd =>
      'Teacher tools: add time or end the class for everyone';

  @override
  String get sessionMicAskOnce =>
      'You join muted. SEEDS will now ask to use the microphone, so you can speak when you choose.';

  @override
  String get sessionMicAskAgain => 'To speak, allow the microphone.';

  @override
  String get sessionMicStillOff =>
      'The microphone is still off. You can keep listening.';

  @override
  String get sessionMicSettingsTitle => 'Microphone is blocked';

  @override
  String get sessionMicSettingsMessage =>
      'Android will not ask again. To speak, open Settings, choose Permissions, and allow the microphone. You can keep listening.';

  @override
  String get sessionMicSettingsOpen => 'Open settings';

  @override
  String get sessionMicSettingsCancel => 'Keep listening';

  @override
  String get sessionMuteAllButton => '3: Mute all students';

  @override
  String get sessionMuteAllLabel => 'Mute all students';

  @override
  String get sessionMuteAllWaiting => 'Still muting everyone. Please wait.';

  @override
  String sessionMuteAllDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count students muted.',
      one: '1 student muted.',
    );
    return '$_temp0';
  }

  @override
  String get sessionMuteAllNone => 'Every student was already muted.';

  @override
  String sessionMuteAllNotConfirmed(String reason) {
    return 'Muting everyone was not confirmed. $reason Press 3 to try again.';
  }

  @override
  String get sessionClassListButton => '4: Class list';

  @override
  String sessionClassListLabel(String people) {
    return 'Class list. $people';
  }

  @override
  String get sessionClassListTitle => 'Class list';

  @override
  String sessionRosterCounts(int here, int left, int notJoined) {
    return '$here here, $left left, $notJoined not joined yet.';
  }

  @override
  String sessionHereNow(int count) {
    return 'Here now: $count';
  }

  @override
  String sessionLeftClass(int count) {
    return 'Joined, then left: $count';
  }

  @override
  String sessionNotJoined(int count) {
    return 'Not joined yet: $count';
  }

  @override
  String get sessionHereNowTitle => 'Here now';

  @override
  String get sessionLeftClassTitle => 'Joined, then left';

  @override
  String get sessionNotJoinedTitle => 'Not joined yet';

  @override
  String sessionRemovedName(String name) {
    return '$name, removed by you';
  }

  @override
  String get sessionNobody => 'Nobody.';

  @override
  String get sessionRemindNotJoined => 'Ring students who have not joined';

  @override
  String get sessionEveryoneJoined => 'Everyone has joined.';

  @override
  String sessionReminderSent(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ringing $count students.',
      one: 'Ringing 1 student.',
      zero: 'Nobody to ring now.',
    );
    return '$_temp0';
  }

  @override
  String sessionReminderSentSomeWaiting(int queued, int cooling) {
    return 'Ringing $queued. $cooling were rung in the last 5 minutes and will not be rung again yet.';
  }

  @override
  String get sessionRosterUnavailable =>
      'The class list could not be read. Try again.';

  @override
  String get sessionAddTime => 'Add 15 minutes';

  @override
  String get sessionCannotAddTime =>
      'No more time can be added before the next class.';

  @override
  String sessionEndsBy(String clock) {
    return 'Class ends by $clock.';
  }

  @override
  String sessionExtendedUntil(String clock) {
    return 'Done. The class now ends by $clock.';
  }

  @override
  String sessionEndingSoonTeacher(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: 'The class ends automatically in $minutes minutes.',
      one: 'The class ends automatically in 1 minute.',
    );
    return '$_temp0';
  }

  @override
  String sessionEndingSoonTeacherExtend(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other:
          'The class ends automatically in $minutes minutes. To add 15 minutes, press 7 then 1.',
      one:
          'The class ends automatically in 1 minute. To add 15 minutes, press 7 then 1.',
    );
    return '$_temp0';
  }

  @override
  String sessionEndingSoonStudent(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: 'The class ends in $minutes minutes.',
      one: 'The class ends in 1 minute.',
    );
    return '$_temp0';
  }

  @override
  String get sessionLessonReady =>
      'Today\'s lesson is ready. Press 5, then 3, to play it for the class.';

  @override
  String get sessionLessonNextReady =>
      'The next part of today\'s lesson is ready. Press 6 to play it.';

  @override
  String get sessionJoinedStudentBrief =>
      'You are in class and muted. Press 1 to speak, 2 to raise your hand.';

  @override
  String get sessionJoinedTeacherBrief =>
      'Your class is live. You are muted. Press 1 to speak, 3 to mute all students.';

  @override
  String get sessionStarForKeys => 'Press star for all keys.';

  @override
  String settingsAutoDownload(String state) {
    return 'Prepare new journeys for offline use on Wi-Fi: $state';
  }

  @override
  String get settingsAutoDownloadOn => 'Journeys will be prepared on Wi-Fi.';

  @override
  String get settingsAutoDownloadOff =>
      'Journeys will not be prepared automatically.';

  @override
  String get adminSetupTeacherNeedsPair =>
      'Add at least one class and subject for the teacher.';

  @override
  String get adminSetupTeacherHasNoPairs =>
      'No teacher has a class and subject yet. Add them to a teacher in People first.';

  @override
  String get adminSetupDaysField => 'Days';

  @override
  String get adminSetupChooseDays => 'Choose at least one day.';

  @override
  String adminSetupLessonsAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lessons added, one for each day.',
      one: 'Lesson added.',
    );
    return '$_temp0';
  }

  @override
  String get adminSetupArrangeBy => 'Arrange by';

  @override
  String get adminSetupArrangeDay => 'Day';

  @override
  String get adminSetupArrangeTeacher => 'Teacher';

  @override
  String get adminSetupArrangeClass => 'Class';

  @override
  String adminSetupGroupHeading(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lessons',
      one: '1 lesson',
    );
    return '$name · $_temp0';
  }

  @override
  String adminSetupEntryDayTitle(String day, String title) {
    return '$day, $title';
  }

  @override
  String get adminSetupTimetableSearch => 'Search lessons';

  @override
  String get adminSetupNoMatchingLessons => 'No lessons match.';

  @override
  String get sessionMoreButton => '7: More';

  @override
  String get sessionMoreLabel => 'More options';

  @override
  String get sessionMoreTitle => 'More options';

  @override
  String get sessionMoreClassroomCheck => 'Classroom check';

  @override
  String get sessionMoreStatus => 'Class status';

  @override
  String get sessionMoreWhatIsPlaying => 'What is playing';

  @override
  String get sessionMoreWhoIsHere => 'Who is in class';

  @override
  String get sessionKeyRaisedHands => 'Raised hands';

  @override
  String get sessionKeyClassList => 'Class list';

  @override
  String get sessionKeyLessonRecording => 'Lesson recording';

  @override
  String get sessionKeyAnswerQuestion => 'Answer the question';

  @override
  String get sessionKeyMore => 'More options';

  @override
  String get sessionKeyLeave => 'Leave class';

  @override
  String get sessionEndClassButton => '8: End class for everyone';

  @override
  String get sessionEndClassLabel => 'End class for everyone. Asks to confirm';

  @override
  String sessionActivityQuizItem(String title, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count questions',
      one: '1 question',
    );
    return 'Quiz: $title, $_temp0';
  }

  @override
  String sessionActivityJourneyItem(String title) {
    return 'Journey: $title';
  }

  @override
  String sessionActivityStopItem(String title) {
    return 'Stop offering $title';
  }

  @override
  String sessionActivityStartedTeacher(String title) {
    return '$title is open for the class. Press 6 for its status.';
  }

  @override
  String sessionActivityStoppedTeacher(String title) {
    return '$title is no longer offered in class. Students can still find it on Home.';
  }

  @override
  String sessionActivityQuizStarted(String title) {
    return 'Your teacher started a quiz: $title. Press 4 to begin.';
  }

  @override
  String sessionActivityJourneyStarted(String title) {
    return 'Your teacher started a journey: $title. Press 4 to begin.';
  }

  @override
  String sessionActivityStoppedStudent(String title) {
    return '$title is closed in class. You can still find it on Home.';
  }

  @override
  String sessionActivityStartQuizLabel(String title) {
    return 'Start the quiz $title';
  }

  @override
  String sessionActivityStartJourneyLabel(String title) {
    return 'Start the journey $title';
  }

  @override
  String sessionActivityStateStudent(String title) {
    return '$title is open.';
  }

  @override
  String sessionActivityStateTeacher(String title) {
    return '$title is open for the class.';
  }

  @override
  String sessionActivityOpening(String title) {
    return 'Opening $title.';
  }

  @override
  String sessionActivityCouldNotOpen(String title) {
    return '$title could not be opened. Check your connection and try again.';
  }

  @override
  String get sessionBackInClass => 'Back in class.';

  @override
  String sessionActivityProgress(String title, int started, int finished) {
    return '$title: $started started, $finished finished.';
  }

  @override
  String get sessionWhatIsPlayingButton => '3: What is playing';

  @override
  String get sessionKeyEndClass => 'End class for everyone';

  @override
  String get sessionKeyWhatIsPlaying => 'What is playing';

  @override
  String get sessionQuizButton => '6: Quiz';

  @override
  String get sessionJourneyButton => '7: Journey';

  @override
  String get sessionQuizLabel => 'Start a quiz for the class';

  @override
  String get sessionJourneyLabel => 'Start a journey for the class';

  @override
  String sessionOpenLabel(String title) {
    return '$title is open. Hear who is left, remind them, or stop it';
  }

  @override
  String get sessionKeyQuiz => 'Quiz for the class';

  @override
  String get sessionKeyJourney => 'Journey for the class';

  @override
  String sessionStartQuizButton(String title) {
    return '4: Start quiz: $title';
  }

  @override
  String sessionStartJourneyButton(String title) {
    return '4: Start journey: $title';
  }

  @override
  String get sessionPickQuizTitle => 'Start a quiz for the class';

  @override
  String get sessionPickJourneyTitle => 'Start a journey for the class';

  @override
  String get sessionNoQuizToStart =>
      'No published quiz is open for this class and subject. Publish one from Quizzes on Home first.';

  @override
  String get sessionNoJourneyToStart =>
      'No published journey for this class and subject. Publish one from Journeys on Home first.';

  @override
  String sessionFinishedOf(int finished, int enrolled) {
    return '$finished of $enrolled finished.';
  }

  @override
  String sessionLeftInClass(int count) {
    return 'In class, not done ($count)';
  }

  @override
  String sessionLeftWholeClass(int count) {
    return 'Whole class, not done ($count)';
  }

  @override
  String get sessionLeftInClassTitle => 'In class, not done';

  @override
  String get sessionLeftWholeClassTitle => 'Whole class, not done';

  @override
  String get sessionRemindLeft => 'Remind those in class who are not done';

  @override
  String get sessionStartDifferentQuiz => 'Start a different quiz';

  @override
  String get sessionStartDifferentJourney => 'Start a different journey';

  @override
  String sessionLeftNotStarted(String name) {
    return '$name, not started';
  }

  @override
  String sessionLeftStarted(String name) {
    return '$name, started, not finished';
  }

  @override
  String get sessionLeftHere => 'in class';

  @override
  String get sessionLeftAway => 'not in class';

  @override
  String get sessionLeftNobodyInClass => 'Everyone in class has finished.';

  @override
  String get sessionLeftNobody => 'Everyone in the class has finished.';

  @override
  String sessionRemindedLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Reminded $count students.',
      one: 'Reminded 1 student.',
      zero: 'Nobody in class needs a reminder.',
    );
    return '$_temp0';
  }

  @override
  String sessionActivityReminderQuiz(String title) {
    return 'Your teacher reminds you to do the quiz $title. Press 4 to begin.';
  }

  @override
  String sessionActivityReminderJourney(String title) {
    return 'Your teacher reminds you to do the journey $title. Press 4 to begin.';
  }

  @override
  String get sessionKeyStartActivity => 'Start the quiz or journey';

  @override
  String get startupSettingsKey2 => '2. Settings';

  @override
  String get libraryPauseSessionKey3 =>
      'Pause audio for the whole session, key 3';

  @override
  String get authSaveNewPasswordKey1 => '1: Save new password';

  @override
  String get quizSaveSettingsKey1 => '1: Save settings';

  @override
  String get quizSaveQuestionKey1 => '1: Save question';

  @override
  String get quizContinueToQuestionsKey1 => '1: Continue to questions';

  @override
  String get adminAuthorSection => 'Quizzes and journeys';

  @override
  String get adminAuthorNote =>
      'Create and publish quizzes and learning journeys for a teacher. Everything you make belongs to that teacher, uses only their question bank and their own recordings, and the teacher is told about it on their Home.';

  @override
  String get adminAuthorTeacher => 'Teacher';

  @override
  String get adminAuthorWorkspace => 'Class and subject';

  @override
  String adminAuthorWorkspaceName(String className, String subjectName) {
    return '$className, $subjectName';
  }

  @override
  String get adminAuthorNoTeachers =>
      'No teacher has a class and subject yet. Assign one in Accounts first.';

  @override
  String get adminAuthorKind => 'Show';

  @override
  String get adminAuthorKindQuizzes => 'Quizzes';

  @override
  String get adminAuthorKindJourneys => 'Journeys';

  @override
  String get adminAuthorNewQuiz => 'New quiz';

  @override
  String get adminAuthorNewJourney => 'New journey';

  @override
  String adminAuthorNewQuizFor(String teacher) {
    return 'New quiz for $teacher';
  }

  @override
  String adminAuthorNewJourneyFor(String teacher) {
    return 'New journey for $teacher';
  }

  @override
  String get adminAuthorNoQuizzes =>
      'This teacher has no quizzes for this class and subject.';

  @override
  String get adminAuthorNoJourneys =>
      'This teacher has no journeys for this class and subject.';

  @override
  String get adminAuthorStatusDraft => 'Draft';

  @override
  String get adminAuthorStatusPublished => 'Published';

  @override
  String get adminAuthorStatusScheduled => 'Published, opens later';

  @override
  String get adminAuthorStatusClosed => 'Closed';

  @override
  String get adminAuthorStatusArchived => 'Archived';

  @override
  String adminAuthorStatusChanged(String status) {
    return '$status, with unpublished changes';
  }

  @override
  String adminAuthorQuestionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count questions',
      one: '1 question',
    );
    return '$_temp0';
  }

  @override
  String adminAuthorStepCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count steps',
      one: '1 step',
    );
    return '$_temp0';
  }

  @override
  String get adminAuthorMode => 'Quiz type';

  @override
  String get adminAuthorModeGraded => 'Graded';

  @override
  String get adminAuthorModePractice => 'Practice';

  @override
  String get adminAuthorEdit => 'Edit';

  @override
  String adminAuthorEditNamed(String title) {
    return 'Edit $title';
  }

  @override
  String get adminAuthorPublish => 'Publish';

  @override
  String adminAuthorPublishNamed(String title) {
    return 'Publish $title';
  }

  @override
  String get adminAuthorClose => 'Close quiz';

  @override
  String adminAuthorCloseNamed(String title) {
    return 'Close $title';
  }

  @override
  String get adminAuthorArchive => 'Archive';

  @override
  String adminAuthorArchiveNamed(String title) {
    return 'Archive $title';
  }

  @override
  String get adminAuthorPublishQuizTitle => 'Publish this quiz?';

  @override
  String adminAuthorPublishQuizMessage(String title, String teacher) {
    return '$title will open to the class as $teacher\'s quiz, and the students will be notified.';
  }

  @override
  String get adminAuthorPublishJourneyTitle => 'Publish this journey?';

  @override
  String adminAuthorPublishJourneyMessage(String title, String teacher) {
    return '$title will be available to the class as $teacher\'s journey, and the students will be notified.';
  }

  @override
  String get adminAuthorCloseQuizTitle => 'Close this quiz?';

  @override
  String adminAuthorCloseQuizMessage(String title) {
    return 'Students can no longer answer $title. Unfinished attempts are submitted as they are.';
  }

  @override
  String get adminAuthorArchiveTitle => 'Archive this journey?';

  @override
  String adminAuthorArchiveMessage(String title) {
    return 'Students will no longer see $title.';
  }

  @override
  String adminAuthorPublished(String title) {
    return '$title published.';
  }

  @override
  String adminAuthorClosed(String title) {
    return '$title closed.';
  }

  @override
  String adminAuthorArchived(String title) {
    return '$title archived.';
  }

  @override
  String adminAuthorCreated(String title) {
    return '$title created as a draft.';
  }

  @override
  String get adminAuthorSaved => 'Journey saved.';

  @override
  String adminAuthorNotReady(String problems) {
    return 'This quiz is not ready to publish. $problems';
  }

  @override
  String get adminAuthorTitle => 'Title';

  @override
  String get adminAuthorDescription => 'Description (optional)';

  @override
  String get adminAuthorQuizSettings => 'Quiz settings';

  @override
  String adminAuthorEditQuiz(String title) {
    return 'Edit quiz: $title';
  }

  @override
  String adminAuthorEditJourney(String title) {
    return 'Edit journey: $title';
  }

  @override
  String get adminAuthorQuestions => 'Questions';

  @override
  String get adminAuthorNoQuestions => 'No questions yet.';

  @override
  String adminAuthorQuestionLine(int number, String text) {
    return '$number. $text';
  }

  @override
  String adminAuthorCorrectAnswer(String answer) {
    return 'Correct answer: $answer';
  }

  @override
  String get adminAuthorRemove => 'Remove';

  @override
  String adminAuthorRemoveNamed(String item) {
    return 'Remove $item';
  }

  @override
  String get adminAuthorAddNewQuestion => 'Type a new question';

  @override
  String get adminAuthorAddBankQuestion => 'Add from question bank';

  @override
  String get adminAuthorQuestionText => 'Question';

  @override
  String adminAuthorOption(int number) {
    return 'Option $number';
  }

  @override
  String adminAuthorOptionalOption(int number) {
    return 'Option $number (optional)';
  }

  @override
  String get adminAuthorCorrectOption => 'Correct answer';

  @override
  String get adminAuthorCorrectIsBlank =>
      'The correct answer is blank. Fill it in or choose another option.';

  @override
  String get adminAuthorExplanation => 'Explanation (optional)';

  @override
  String get adminAuthorSaveToBank =>
      'Also save to the teacher\'s question bank';

  @override
  String get adminAuthorNeedFourOptions => 'Fill in all four options.';

  @override
  String get adminAuthorNeedTwoOptions => 'Fill in at least two options.';

  @override
  String get adminAuthorDuplicateOptions => 'Each option must be different.';

  @override
  String adminAuthorRequired(String field) {
    return '$field is required.';
  }

  @override
  String get adminAuthorAdd => 'Add';

  @override
  String adminAuthorAddNamed(String item) {
    return 'Add $item';
  }

  @override
  String get adminAuthorBankTitle => 'Teacher\'s question bank';

  @override
  String get adminAuthorBankEmpty =>
      'This teacher has no saved questions for this class and subject.';

  @override
  String get adminAuthorDone => 'Done';

  @override
  String get adminAuthorGraded => 'Graded: score the questions';

  @override
  String get adminAuthorRetries => 'Retries after a wrong answer';

  @override
  String get adminAuthorSteps => 'Steps';

  @override
  String get adminAuthorNoSteps => 'No steps yet.';

  @override
  String adminAuthorStepRecording(String title) {
    return 'Recording: $title';
  }

  @override
  String adminAuthorStepNarration(String text) {
    return 'Narration: $text';
  }

  @override
  String adminAuthorStepQuestion(String text) {
    return 'Question: $text';
  }

  @override
  String adminAuthorStepPoll(String text) {
    return 'Poll: $text';
  }

  @override
  String get adminAuthorMoveUp => 'Move up';

  @override
  String adminAuthorMoveUpNamed(String item) {
    return 'Move $item up';
  }

  @override
  String get adminAuthorMoveDown => 'Move down';

  @override
  String adminAuthorMoveDownNamed(String item) {
    return 'Move $item down';
  }

  @override
  String get adminAuthorAddRecording => 'Add recording';

  @override
  String get adminAuthorAddNarration => 'Add narration';

  @override
  String get adminAuthorAddQuestion => 'Add question';

  @override
  String get adminAuthorAddPoll => 'Add poll';

  @override
  String get adminAuthorRecordingsTitle => 'Teacher\'s recordings';

  @override
  String get adminAuthorRecordingsNote =>
      'Only recordings this teacher uploaded for this class and subject can be used.';

  @override
  String get adminAuthorNoRecordings =>
      'This teacher has not uploaded a recording for this class and subject.';

  @override
  String get adminAuthorNarrationText => 'Narration text';

  @override
  String get adminAuthorPollText => 'Poll question';

  @override
  String get adminAuthorSaveJourney => 'Save journey';

  @override
  String teacherHomeNotice(String kind, String title, String action) {
    return '$kind $title: $action for you by your administrator.';
  }

  @override
  String get teacherHomeNoticeQuiz => 'Quiz';

  @override
  String get teacherHomeNoticeJourney => 'Journey';

  @override
  String get teacherHomeNoticeCreated => 'added';

  @override
  String get teacherHomeNoticePublished => 'published';

  @override
  String get teacherHomeNoticeClosed => 'closed';

  @override
  String get teacherHomeNoticeArchived => 'archived';

  @override
  String sessionPeopleJoined(String names) {
    return '$names joined.';
  }

  @override
  String sessionPeopleLeft(String names) {
    return '$names left.';
  }

  @override
  String sessionNamesAnd(String first, String last) {
    return '$first and $last';
  }

  @override
  String sessionHereOf(int here, int total) {
    return '$here of $total here.';
  }

  @override
  String sessionHereCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count students here.',
      one: '1 student here.',
      zero: 'No students here.',
    );
    return '$_temp0';
  }

  @override
  String sessionStartSummary(int here, int total) {
    return '$here of $total students here.';
  }

  @override
  String uiFocusedField(String field) {
    return 'You are in $field.';
  }

  @override
  String get sessionStartButton => '5: Start';

  @override
  String get sessionStartLabel =>
      'Start a quiz, journey or recording for the class';

  @override
  String get sessionStartTitle => 'Start for the class';

  @override
  String get sessionStartQuiz => 'Quiz';

  @override
  String get sessionStartJourney => 'Journey';

  @override
  String get sessionStartRecording => 'Recording';

  @override
  String sessionStatusKeyButton(String title) {
    return '6: Status of $title';
  }

  @override
  String sessionStatusKeyLabel(String title) {
    return 'Status of $title';
  }

  @override
  String get sessionKeyStart => 'Start a quiz, journey or recording';

  @override
  String get sessionKeyStatus => 'Status of what is running';

  @override
  String sessionActivityCounts(int present, int started, int finished) {
    return '$present students in class. $started have attempted it, $finished finished.';
  }

  @override
  String get sessionNowPlayingTitle => 'the recording';
}
