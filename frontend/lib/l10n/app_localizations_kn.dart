// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Kannada (`kn`).
class AppLocalizationsKn extends AppLocalizations {
  AppLocalizationsKn([String locale = 'kn']) : super(locale);

  @override
  String get spokenDigitWords =>
      'ಸೊನ್ನೆ, ಒಂದು, ಎರಡು, ಮೂರು, ನಾಲ್ಕು, ಐದು, ಆರು, ಏಳು, ಎಂಟು, ಒಂಬತ್ತು';

  @override
  String get spokenMonths =>
      'ಜನವರಿ, ಫೆಬ್ರವರಿ, ಮಾರ್ಚ್, ಏಪ್ರಿಲ್, ಮೇ, ಜೂನ್, ಜುಲೈ, ಆಗಸ್ಟ್, ಸೆಪ್ಟೆಂಬರ್, ಅಕ್ಟೋಬರ್, ನವೆಂಬರ್, ಡಿಸೆಂಬರ್';

  @override
  String get spokenWeekdays =>
      'ಸೋಮವಾರ, ಮಂಗಳವಾರ, ಬುಧವಾರ, ಗುರುವಾರ, ಶುಕ್ರವಾರ, ಶನಿವಾರ, ಭಾನುವಾರ';

  @override
  String get spokenPlus => 'ಪ್ಲಸ್';

  @override
  String spokenSession(String number) {
    return 'ಸೆಷನ್ $number';
  }

  @override
  String get spokenNoon => 'ಮಧ್ಯಾಹ್ನ 12';

  @override
  String get spokenMidnight => 'ಮಧ್ಯರಾತ್ರಿ';

  @override
  String spokenOClock(String hour) {
    return '$hour ಗಂಟೆ';
  }

  @override
  String spokenMorning(String clock) {
    return 'ಬೆಳಿಗ್ಗೆ $clock';
  }

  @override
  String spokenAfternoon(String clock) {
    return 'ಮಧ್ಯಾಹ್ನ $clock';
  }

  @override
  String spokenEvening(String clock) {
    return 'ಸಂಜೆ $clock';
  }

  @override
  String spokenNight(String clock) {
    return 'ರಾತ್ರಿ $clock';
  }

  @override
  String get spokenToday => 'ಇಂದು';

  @override
  String get spokenTomorrow => 'ನಾಳೆ';

  @override
  String get spokenYesterday => 'ನಿನ್ನೆ';

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
    return '$date, $timeಕ್ಕೆ';
  }

  @override
  String spokenHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ಗಂಟೆಗಳು',
      one: '1 ಗಂಟೆ',
    );
    return '$_temp0';
  }

  @override
  String spokenMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ನಿಮಿಷಗಳು',
      one: '1 ನಿಮಿಷ',
    );
    return '$_temp0';
  }

  @override
  String spokenSeconds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ಸೆಕೆಂಡುಗಳು',
      one: '1 ಸೆಕೆಂಡ್',
    );
    return '$_temp0';
  }

  @override
  String spokenPositionOf(String position, String total) {
    return '$total ರಲ್ಲಿ $position';
  }

  @override
  String spokenPercent(String value) {
    return '$value ಪ್ರತಿಶತ';
  }

  @override
  String get spokenOn => 'ಆನ್';

  @override
  String get spokenOff => 'ಆಫ್';

  @override
  String get keyBack10Seconds => '10 ಸೆಕೆಂಡ್ ಹಿಂದೆ';

  @override
  String get keyPlayOrPause => 'ಪ್ಲೇ ಅಥವಾ ವಿರಾಮ';

  @override
  String get keyForward10Seconds => '10 ಸೆಕೆಂಡ್ ಮುಂದೆ';

  @override
  String get keySlower => 'ನಿಧಾನ';

  @override
  String get keyFaster => 'ವೇಗ';

  @override
  String get keySlowerPlaybackSpeed => 'ಪ್ಲೇಬ್ಯಾಕ್ ವೇಗ ಕಡಿಮೆ';

  @override
  String get keyFasterPlaybackSpeed => 'ಪ್ಲೇಬ್ಯಾಕ್ ವೇಗ ಹೆಚ್ಚು';

  @override
  String get keyLogin => 'ಸೈನ್ ಇನ್';

  @override
  String get keyRegister => 'ನೋಂದಣಿ';

  @override
  String get keySettings => 'ಸೆಟ್ಟಿಂಗ್‌ಗಳು';

  @override
  String get keySelectStudentAccount => 'ವಿದ್ಯಾರ್ಥಿ ಖಾತೆ ಆರಿಸಿ';

  @override
  String get keySelectTeacherAccount => 'ಶಿಕ್ಷಕರ ಖಾತೆ ಆರಿಸಿ';

  @override
  String get keySelectAdministratorAccount => 'ನಿರ್ವಾಹಕರ ಖಾತೆ ಆರಿಸಿ';

  @override
  String get keyGoToLogin => 'ಸೈನ್ ಇನ್‌ಗೆ ಹೋಗಿ';

  @override
  String get keyToggleTeacherRegistration => 'ಶಿಕ್ಷಕರ ನೋಂದಣಿ ಆನ್ ಅಥವಾ ಆಫ್';

  @override
  String get keyGoBack => 'ಹಿಂದೆ ಹೋಗಿ';

  @override
  String get keyToggleTTS => 'ಟಿ ಟಿ ಎಸ್ ಆನ್ ಅಥವಾ ಆಫ್';

  @override
  String get keyToggleVoiceCommands => 'ಧ್ವನಿ ಆಜ್ಞೆಗಳು ಆನ್ ಅಥವಾ ಆಫ್';

  @override
  String get keyShowOrHideShortcuts => 'ಶಾರ್ಟ್‌ಕಟ್‌ಗಳನ್ನು ತೋರಿಸಿ ಅಥವಾ ಮರೆಮಾಡಿ';

  @override
  String get keyToggleHighContrast => 'ಹೈ ಕಾಂಟ್ರಾಸ್ಟ್ ಆನ್ ಅಥವಾ ಆಫ್';

  @override
  String get keyTestTTS => 'ಟಿ ಟಿ ಎಸ್ ಪರೀಕ್ಷಿಸಿ';

  @override
  String get keySaveSettings => 'ಸೆಟ್ಟಿಂಗ್‌ಗಳನ್ನು ಉಳಿಸಿ';

  @override
  String get keyCheckVoice => 'ಧ್ವನಿ ಪರಿಶೀಲಿಸಿ';

  @override
  String get keySoundCuesOnOrOff => 'ಶಬ್ದ ಸೂಚನೆಗಳು ಆನ್ ಅಥವಾ ಆಫ್';

  @override
  String get keyVibrationOnOrOff => 'ಕಂಪನ ಆನ್ ಅಥವಾ ಆಫ್';

  @override
  String get keyLogOutAsksToConfirm => 'ಲಾಗ್ ಔಟ್, ಖಚಿತಪಡಿಸಲು ಕೇಳುತ್ತದೆ';

  @override
  String get keyRefreshSessions => 'ಸೆಷನ್‌ಗಳನ್ನು ರಿಫ್ರೆಶ್ ಮಾಡಿ';

  @override
  String get keySearchSessionsByNameOrID =>
      'ಹೆಸರು ಅಥವಾ ID ಮೂಲಕ ಸೆಷನ್‌ಗಳನ್ನು ಹುಡುಕಿ';

  @override
  String get keyRecordedAudioLibrary => 'ರೆಕಾರ್ಡ್ ಮಾಡಿದ ಆಡಿಯೋ ಲೈಬ್ರರಿ';

  @override
  String get keyMyPrivatePlaylists => 'ನನ್ನ ಖಾಸಗಿ ಪ್ಲೇಲಿಸ್ಟ್‌ಗಳು';

  @override
  String get keyQuizzes => 'ಕ್ವಿಜ್‌ಗಳು';

  @override
  String get keyLearningJourneys => 'ಕಲಿಕೆಯ ಪಯಣಗಳು';

  @override
  String get keyCreateSession => 'ಸೆಷನ್ ರಚಿಸಿ';

  @override
  String get keyClassPlaylists => 'ತರಗತಿ ಪ್ಲೇಲಿಸ್ಟ್‌ಗಳು';

  @override
  String get keyChooseClassAndSubjectWorkspace =>
      'ತರಗತಿ ಮತ್ತು ವಿಷಯದ ಕಾರ್ಯಕ್ಷೇತ್ರ ಆರಿಸಿ';

  @override
  String get keyRefresh => 'ರಿಫ್ರೆಶ್';

  @override
  String get keySearchUsers => 'ಬಳಕೆದಾರರನ್ನು ಹುಡುಕಿ';

  @override
  String get keyChangeAccountTypeFilter => 'ಖಾತೆ ಪ್ರಕಾರದ ಫಿಲ್ಟರ್ ಬದಲಿಸಿ';

  @override
  String get keyChangeAssignmentFilter => 'ನಿಯೋಜನೆ ಫಿಲ್ಟರ್ ಬದಲಿಸಿ';

  @override
  String get keyCreateSubject => 'ವಿಷಯ ರಚಿಸಿ';

  @override
  String get keyCreateClass => 'ತರಗತಿ ರಚಿಸಿ';

  @override
  String get keyChooseAccountsClassesOrSubjectsSection =>
      'ಖಾತೆಗಳು, ತರಗತಿಗಳು ಅಥವಾ ವಿಷಯಗಳ ವಿಭಾಗ ಆರಿಸಿ';

  @override
  String get keyGoBackAlt => 'ಹಿಂದೆ ಹೋಗಿ';

  @override
  String get keyCreateBankQuestion => 'ಪ್ರಶ್ನೆ ಬ್ಯಾಂಕ್ ಪ್ರಶ್ನೆ ರಚಿಸಿ';

  @override
  String get keyCreateQuizDraft => 'ಕ್ವಿಜ್ ಕರಡು ರಚಿಸಿ';

  @override
  String get keyCreateUntimedUngradedPractice =>
      'ಸಮಯ ಮಿತಿ ಮತ್ತು ಅಂಕಗಳಿಲ್ಲದ ಅಭ್ಯಾಸ ರಚಿಸಿ';

  @override
  String get keyRefreshQuizzes => 'ಕ್ವಿಜ್‌ಗಳನ್ನು ರಿಫ್ರೆಶ್ ಮಾಡಿ';

  @override
  String get keyChooseOption1 => 'ಆಯ್ಕೆ 1 ಆರಿಸಿ';

  @override
  String get keyChooseOption2 => 'ಆಯ್ಕೆ 2 ಆರಿಸಿ';

  @override
  String get keyChooseOption3 => 'ಆಯ್ಕೆ 3 ಆರಿಸಿ';

  @override
  String get keyChooseOption4 => 'ಆಯ್ಕೆ 4 ಆರಿಸಿ';

  @override
  String get keySubmitSelectedAnswer => 'ಆರಿಸಿದ ಉತ್ತರವನ್ನು ಸಲ್ಲಿಸಿ';

  @override
  String get keyRepeatQuestionAndOptions =>
      'ಪ್ರಶ್ನೆ ಮತ್ತು ಆಯ್ಕೆಗಳನ್ನು ಮತ್ತೆ ಹೇಳಿ';

  @override
  String get keySlowerQuizSpeech => 'ಕ್ವಿಜ್ ಧ್ವನಿ ನಿಧಾನ';

  @override
  String get keyWhereAmIIncludingTimeLeft => 'ನಾನು ಎಲ್ಲಿದ್ದೇನೆ, ಉಳಿದ ಸಮಯ ಸೇರಿ';

  @override
  String get keyFasterQuizSpeech => 'ಕ್ವಿಜ್ ಧ್ವನಿ ವೇಗ';

  @override
  String get keyMuteOrUnmute => 'ಮ್ಯೂಟ್ ಅಥವಾ ಅನ್‌ಮ್ಯೂಟ್';

  @override
  String get keyRaiseOrLowerHand => 'ಕೈ ಎತ್ತಿ ಅಥವಾ ಕೈ ಇಳಿಸಿ';

  @override
  String get keyHearClassStatus => 'ತರಗತಿಯ ಸ್ಥಿತಿ ಕೇಳಿ';

  @override
  String get keyChat => 'ಚಾಟ್';

  @override
  String get keyHearWhatTheTeacherIsPlaying =>
      'ಶಿಕ್ಷಕರು ಏನು ಪ್ಲೇ ಮಾಡುತ್ತಿದ್ದಾರೆ ಎಂದು ಕೇಳಿ';

  @override
  String get keyAnswerClassroomCheck => 'ತರಗತಿ ಪರಿಶೀಲನೆಗೆ ಉತ್ತರಿಸಿ';

  @override
  String get keyWhoIsInTheClass => 'ತರಗತಿಯಲ್ಲಿ ಯಾರಿದ್ದಾರೆ';

  @override
  String get keyLeaveSessionAsksToConfirm => 'ಸೆಷನ್ ಬಿಡಿ, ಖಚಿತಪಡಿಸಲು ಕೇಳುತ್ತದೆ';

  @override
  String get keyRaisedHandsAcknowledgeAndLowerThemInOrder =>
      'ಎತ್ತಿದ ಕೈಗಳು: ಕ್ರಮವಾಗಿ ಗಮನಿಸಿ ಮತ್ತು ಇಳಿಸಿ';

  @override
  String get keyClassRecordingPlayerPlayAndControlTheRecording =>
      'ತರಗತಿ ರೆಕಾರ್ಡಿಂಗ್ ಪ್ಲೇಯರ್: ರೆಕಾರ್ಡಿಂಗ್ ಪ್ಲೇ ಮಾಡಿ ಮತ್ತು ನಿಯಂತ್ರಿಸಿ';

  @override
  String get keyClassroomCheckStartCloseAndHearResponses =>
      'ತರಗತಿ ಪರಿಶೀಲನೆ: ಪ್ರಾರಂಭಿಸಿ, ಮುಚ್ಚಿ ಮತ್ತು ಉತ್ತರಗಳನ್ನು ಕೇಳಿ';

  @override
  String get keyParticipantsMuteOrRemoveSomeone =>
      'ಭಾಗವಹಿಸುವವರು: ಯಾರನ್ನಾದರೂ ಮ್ಯೂಟ್ ಮಾಡಿ ಅಥವಾ ತೆಗೆದುಹಾಕಿ';

  @override
  String get keyTeacherToolsInviteStudentsEndClassForEveryone =>
      'ಶಿಕ್ಷಕರ ಉಪಕರಣಗಳು: ವಿದ್ಯಾರ್ಥಿಗಳನ್ನು ಆಹ್ವಾನಿಸಿ, ಎಲ್ಲರಿಗೂ ತರಗತಿ ಮುಗಿಸಿ';

  @override
  String get keyRefreshClasses => 'ತರಗತಿಗಳನ್ನು ರಿಫ್ರೆಶ್ ಮಾಡಿ';

  @override
  String get keySearchClassByName => 'ಹೆಸರಿನಿಂದ ತರಗತಿ ಹುಡುಕಿ';

  @override
  String get keyAllAudioFiles => 'ಎಲ್ಲಾ ಆಡಿಯೋ ಫೈಲ್‌ಗಳು';

  @override
  String get keyFocusFirstActiveClassUseDPadToBrowseClasses =>
      'ಮೊದಲ ಸಕ್ರಿಯ ತರಗತಿಗೆ ಹೋಗಿ; ತರಗತಿಗಳನ್ನು ನೋಡಲು D-pad ಬಳಸಿ';

  @override
  String get keyRefreshFiles => 'ಫೈಲ್‌ಗಳನ್ನು ರಿಫ್ರೆಶ್ ಮಾಡಿ';

  @override
  String get keyNextSubjectFilter => 'ಮುಂದಿನ ವಿಷಯ ಫಿಲ್ಟರ್';

  @override
  String get keyStopPlayback => 'ಪ್ಲೇಬ್ಯಾಕ್ ನಿಲ್ಲಿಸಿ';

  @override
  String get keyAddAudioFile => 'ಆಡಿಯೋ ಫೈಲ್ ಸೇರಿಸಿ';

  @override
  String get keyUploadNewFile => 'ಹೊಸ ಫೈಲ್ ಅಪ್‌ಲೋಡ್ ಮಾಡಿ';

  @override
  String get keySelectFromExistingLibrary => 'ಈಗಿರುವ ಲೈಬ್ರರಿಯಿಂದ ಆರಿಸಿ';

  @override
  String get keyRefreshList => 'ಪಟ್ಟಿಯನ್ನು ರಿಫ್ರೆಶ್ ಮಾಡಿ';

  @override
  String get appName => 'SEEDS';

  @override
  String get languageEnglish => 'ಇಂಗ್ಲಿಷ್';

  @override
  String get languageHindi => 'ಹಿಂದಿ';

  @override
  String get languageKannada => 'ಕನ್ನಡ';

  @override
  String get languageTelugu => 'ತೆಲುಗು';

  @override
  String get languageBengali => 'ಬಂಗಾಳಿ';

  @override
  String get commonPleaseWait => 'ದಯವಿಟ್ಟು ಕಾಯಿರಿ. ಇನ್ನೂ ಕೆಲಸ ನಡೆಯುತ್ತಿದೆ.';

  @override
  String get commonSignInFirst => 'ದಯವಿಟ್ಟು ಮೊದಲು ಸೈನ್ ಇನ್ ಮಾಡಿ.';

  @override
  String get commonAccountChanged =>
      'ಈ ಫೋನ್‌ನಲ್ಲಿ ನಿಮ್ಮ ಖಾತೆ ಬದಲಾಗಿದೆ. ಮತ್ತೆ ಸೈನ್ ಇನ್ ಮಾಡಿ.';

  @override
  String get commonNoWorkspace =>
      'ಯಾವುದೇ ತರಗತಿ ಮತ್ತು ವಿಷಯವನ್ನು ಆರಿಸಿಲ್ಲ. ಕಾರ್ಯಕ್ಷೇತ್ರ ಆರಿಸಲು 7 ಒತ್ತಿ.';

  @override
  String get commonNoConnection =>
      'ಶಾಲೆಯ ಸರ್ವರ್‌ಗೆ ಸಂಪರ್ಕವಿಲ್ಲ. ನಿಮ್ಮ ಇಂಟರ್ನೆಟ್ ಪರಿಶೀಲಿಸಿ ಮತ್ತು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get commonNotAvailable => 'ಇದು ಈಗ ಲಭ್ಯವಿಲ್ಲ.';

  @override
  String get commonNothingChanged => 'ಏನನ್ನೂ ಬದಲಾಯಿಸಲಾಗಿಲ್ಲ.';

  @override
  String get commonNoMessages => 'ಈ ಪರದೆಯಲ್ಲಿ ಯಾವುದೇ ಸಂದೇಶಗಳಿಲ್ಲ.';

  @override
  String get commonEndOfList => 'ಪಟ್ಟಿಯ ಕೊನೆ. ಮೊದಲ ಐಟಂಗೆ ಹಿಂತಿರುಗಲಾಗಿದೆ.';

  @override
  String get commonTopOfList => 'ಪಟ್ಟಿಯ ಮೇಲ್ಭಾಗ. ಕೊನೆಯ ಐಟಂಗೆ ಹೋಗಲಾಗಿದೆ.';

  @override
  String commonOpening(String what) {
    return '$what ತೆರೆಯಲಾಗುತ್ತಿದೆ.';
  }

  @override
  String commonOpeningNeedsInternet(String what) {
    return '$what ತೆರೆಯಲಾಗುತ್ತಿದೆ. ಇಂಟರ್ನೆಟ್ ಅಗತ್ಯವಿದೆ.';
  }

  @override
  String commonUnavailable(String what) {
    return '$what ಲಭ್ಯವಿಲ್ಲ.';
  }

  @override
  String commonUnavailableBecause(String what, String reason) {
    return '$what ಲಭ್ಯವಿಲ್ಲ. $reason';
  }

  @override
  String commonWhereScreen(String screen) {
    return '$screen.';
  }

  @override
  String commonWhereFocused(String item) {
    return 'ಆಯ್ಕೆಯಾಗಿರುವುದು: $item.';
  }

  @override
  String keypadPressFor(String key, String action) {
    return '$actionಗಾಗಿ $key ಒತ್ತಿ';
  }

  @override
  String get keypadListSeparator => '. ';

  @override
  String get keypadRepeatInstructions =>
      'ಈ ಸೂಚನೆಗಳನ್ನು ಮತ್ತೆ ಕೇಳಲು ಸ್ಟಾರ್ ಒತ್ತಿ.';

  @override
  String get keypadRepeatFullHelp =>
      'ಪೂರ್ಣ ಸಹಾಯವನ್ನು ಮತ್ತೆ ಕೇಳಲು ಸ್ಟಾರ್ ಒತ್ತಿ.';

  @override
  String get keypadStarForShortcuts => 'ಎಲ್ಲಾ ಶಾರ್ಟ್‌ಕಟ್‌ಗಳಿಗಾಗಿ ಸ್ಟಾರ್ ಒತ್ತಿ.';

  @override
  String keypadScreenReaderIntro(String screen) {
    return '$screen. ಕೀಪ್ಯಾಡ್ ಸಹಾಯಕ್ಕಾಗಿ ಸ್ಟಾರ್ ಒತ್ತಿ.';
  }

  @override
  String keypadMoveThroughSections(String sections) {
    return '$sections ನಡುವೆ ಚಲಿಸಲು D-pad ಮೇಲೆ ಮತ್ತು ಕೆಳಗೆ ಬಳಸಿ. ಆಯ್ಕೆಯಾಗಿರುವ ನಿಯಂತ್ರಣವನ್ನು ಸಕ್ರಿಯಗೊಳಿಸಲು ಓಕೆ ಒತ್ತಿ.';
  }

  @override
  String get keypadNumberedBackAndStop =>
      'ಹಿಂದೆ ಹೋಗಲು ಅಥವಾ ರದ್ದುಮಾಡಲು 0 ಒತ್ತಿ. ಆ್ಯಪ್ ಧ್ವನಿ ನಿಲ್ಲಿಸಲು ಹ್ಯಾಶ್ ಒತ್ತಿ.';

  @override
  String get keypadNumberedEditing =>
      'ಎಡಿಟ್ ಮಾಡುವಾಗ, ಕೀಗಳು ಪಠ್ಯವನ್ನು ನಮೂದಿಸುತ್ತವೆ. ಮುಗಿಸಲು ಓಕೆ ಒತ್ತಿ, ಅಥವಾ ಫೀಲ್ಡ್‌ನಿಂದ ಹೊರಬರಲು ಮೇಲೆ ಅಥವಾ ಕೆಳಗೆ ಬಳಸಿ.';

  @override
  String get keypadNumberedMove =>
      'ಆಯ್ಕೆಗಳ ನಡುವೆ ಚಲಿಸಲು D-pad ಮೇಲೆ ಮತ್ತು ಕೆಳಗೆ ಬಳಸಿ, ಆರಿಸಲು ಓಕೆ ಒತ್ತಿ.';

  @override
  String get keypadEssentialMove =>
      'ಚಲಿಸಲು ಮೇಲೆ ಮತ್ತು ಕೆಳಗೆ ಬಳಸಿ, ಆರಿಸಲು ಓಕೆ ಒತ್ತಿ.';

  @override
  String get keypadPressZeroBack => 'ಹಿಂದೆ ಹೋಗಲು 0 ಒತ್ತಿ.';

  @override
  String get keypadHashAndStar =>
      'ಧ್ವನಿ ನಿಲ್ಲಿಸಲು ಹ್ಯಾಶ್ ಒತ್ತಿ. ಈ ಸೂಚನೆಗಳನ್ನು ಮತ್ತೆ ಕೇಳಲು ಸ್ಟಾರ್ ಒತ್ತಿ.';

  @override
  String get keypadDirectionKeys => 'ಚಲಿಸಲು ದಿಕ್ಕಿನ ಕೀಗಳನ್ನು ಬಳಸಿ.';

  @override
  String get keypadDirectionKeysAndOk =>
      'ಚಲಿಸಲು ದಿಕ್ಕಿನ ಕೀಗಳನ್ನು ಬಳಸಿ, ಆರಿಸಲು ಓಕೆ ಒತ್ತಿ.';

  @override
  String get keypadActivateOrEdit =>
      'ನಿಯಂತ್ರಣವನ್ನು ಸಕ್ರಿಯಗೊಳಿಸಲು ಅಥವಾ ಫೀಲ್ಡ್ ಎಡಿಟ್ ಮಾಡಲು ಓಕೆ ಒತ್ತಿ.';

  @override
  String get keypadLeaveField =>
      'ಎಡಿಟ್ ಮಾಡುವಾಗ, ಫೀಲ್ಡ್‌ನಿಂದ ಹೊರಬರಲು ಓಕೆ ಒತ್ತಿ ಅಥವಾ ಮೇಲೆ ಅಥವಾ ಕೆಳಗೆ ಬಳಸಿ.';

  @override
  String keypadPosition(String index, String total) {
    return ', $total ರಲ್ಲಿ $index';
  }

  @override
  String keypadEditingPressOk(String label) {
    return '$label. ಎಡಿಟ್ ಮಾಡಲಾಗುತ್ತಿದೆ. ಮುಗಿದ ನಂತರ ಓಕೆ ಒತ್ತಿ.';
  }

  @override
  String keypadEditingUseUpDown(String label) {
    return '$label. ಎಡಿಟ್ ಮಾಡಲಾಗುತ್ತಿದೆ. ಈ ಫೀಲ್ಡ್‌ನಿಂದ ಹೊರಬರಲು ಮೇಲೆ ಅಥವಾ ಕೆಳಗೆ ಬಳಸಿ.';
  }

  @override
  String get keypadControlUnavailable => 'ಈ ನಿಯಂತ್ರಣ ಈಗ ಲಭ್ಯವಿಲ್ಲ.';

  @override
  String get keypadMainScreen => 'ಇದು ಮುಖ್ಯ ಪರದೆ. ಹಿಂದೆ ಹೋಗಲು ಏನೂ ಇಲ್ಲ.';

  @override
  String messageLast(String text) {
    return 'ಕೊನೆಯ ಸಂದೇಶ: $text';
  }

  @override
  String messageLastProblem(String text) {
    return 'ಕೊನೆಯ ಸಮಸ್ಯೆ: $text';
  }

  @override
  String ttsSpeedDescription(String speed) {
    return 'ಸಾಮಾನ್ಯ ವೇಗದ $speed ಪಟ್ಟು';
  }

  @override
  String get ttsUnavailable =>
      'ಧ್ವನಿ ಲಭ್ಯವಿಲ್ಲ. ಇಂಗ್ಲಿಷ್ Android ಟೆಕ್ಸ್ಟ್-ಟು-ಸ್ಪೀಚ್ ಧ್ವನಿಯನ್ನು ಆನ್ ಮಾಡಿ, ನಂತರ ಸೆಟ್ಟಿಂಗ್‌ಗಳಲ್ಲಿ \'ಧ್ವನಿ ಪರೀಕ್ಷಿಸಿ\' ಬಟನ್ ಒತ್ತಿ.';

  @override
  String ttsLanguageFallback(String language) {
    return 'ಈ ಫೋನ್‌ನಲ್ಲಿ $language ಧ್ವನಿ ಲಭ್ಯವಿಲ್ಲ, ಆದ್ದರಿಂದ SEEDS ಇಂಗ್ಲಿಷ್‌ನಲ್ಲಿ ಮಾತನಾಡುತ್ತದೆ. Android ಟೆಕ್ಸ್ಟ್-ಟು-ಸ್ಪೀಚ್ ಸೆಟ್ಟಿಂಗ್‌ಗಳಲ್ಲಿ $language ಧ್ವನಿಯನ್ನು ಇನ್‌ಸ್ಟಾಲ್ ಮಾಡಿ, ನಂತರ ಸೆಟ್ಟಿಂಗ್‌ಗಳಲ್ಲಿ ಧ್ವನಿಯನ್ನು ಪರಿಶೀಲಿಸಿ.';
  }

  @override
  String get ttsScreenReaderDetected =>
      'ಸ್ಕ್ರೀನ್ ರೀಡರ್ ಪತ್ತೆಯಾಗಿದೆ. SEEDS ತನ್ನ ಪ್ರಕಟಣೆಗಳನ್ನು ನಿಮ್ಮ ಸ್ಕ್ರೀನ್ ರೀಡರ್‌ಗೆ ಕಳುಹಿಸುತ್ತದೆ.';

  @override
  String get ttsScreenReaderOff =>
      'ಸ್ಕ್ರೀನ್ ರೀಡರ್ ಆಫ್ ಆಗಿದೆ. SEEDS ತಾನೇ ಮಾತನಾಡುತ್ತದೆ.';

  @override
  String ttsVoiceInstalled(String language) {
    return '$language ಧ್ವನಿ ಡೇಟಾ ಇನ್‌ಸ್ಟಾಲ್ ಆಗಿದೆ ಎಂದು Android ಹೇಳುತ್ತಿದೆ. ಸೆಟ್ಟಿಂಗ್‌ಗಳಲ್ಲಿ \'ಧ್ವನಿ ಪರೀಕ್ಷಿಸಿ\' ಬಟನ್ ಒತ್ತಿ, ನಂತರ ಆಫ್‌ಲೈನ್ ಧ್ವನಿಯನ್ನು ನಂಬುವ ಮೊದಲು ಏರ್‌ಪ್ಲೇನ್ ಮೋಡ್‌ನಲ್ಲಿ ಮತ್ತೆ ಪರೀಕ್ಷಿಸಿ. ನಿಮಗೆ ಅದು ಕೇಳಿಸುತ್ತದೆ ಎಂದು ಈ ಪರಿಶೀಲನೆ ಖಚಿತಪಡಿಸಲು ಸಾಧ್ಯವಿಲ್ಲ.';
  }

  @override
  String ttsVoiceNotOffline(String language) {
    return '$language ಲಭ್ಯವಿದೆ, ಆದರೆ ಇನ್‌ಸ್ಟಾಲ್ ಆದ ಆಫ್‌ಲೈನ್ ಧ್ವನಿ ಡೇಟಾ ಖಚಿತವಾಗಿಲ್ಲ. ಧ್ವನಿಗೆ ಇಂಟರ್ನೆಟ್ ಬೇಕಾಗಬಹುದು.';
  }

  @override
  String ttsVoiceMissing(String language) {
    return 'ಯಾವುದೇ $language ಧ್ವನಿ ಪತ್ತೆಯಾಗಿಲ್ಲ.';
  }

  @override
  String ttsVoiceUnverified(String language) {
    return '$language ಧ್ವನಿ ಲಭ್ಯವಿದೆಯೇ ಎಂದು ಪರಿಶೀಲಿಸಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ.';
  }

  @override
  String ttsVoiceRecovery(String language) {
    return 'Android ಸೆಟ್ಟಿಂಗ್‌ಗಳನ್ನು ತೆರೆಯಿರಿ, Text-to-speech output ಹುಡುಕಿ, $language ಧ್ವನಿಯನ್ನು ಆರಿಸಿ ಮತ್ತು ಅದರ ಧ್ವನಿ ಡೇಟಾವನ್ನು ಇನ್‌ಸ್ಟಾಲ್ ಮಾಡಿ. ಇಲ್ಲಿಗೆ ಹಿಂತಿರುಗಿ ಮತ್ತೆ ಪರಿಶೀಲಿಸಿ. ಆ್ಯಪ್ ಧ್ವನಿಯ ಬದಲು ನಿಮ್ಮ Android ಸ್ಕ್ರೀನ್ ರೀಡರ್ ಬಳಸಬಹುದು.';
  }

  @override
  String get ttsSpeedChangeFailed =>
      'ಧ್ವನಿಯ ವೇಗವನ್ನು ಬದಲಾಯಿಸಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ. ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get ttsSettingsFailed =>
      'ಧ್ವನಿ ಸೆಟ್ಟಿಂಗ್‌ಗಳನ್ನು ಅನ್ವಯಿಸಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ. \'ಧ್ವನಿ ಪರೀಕ್ಷಿಸಿ\' ಬಟನ್ ಮತ್ತೆ ಒತ್ತಿ.';

  @override
  String get ttsCouldNotStart =>
      'ಧ್ವನಿ ಪ್ರಾರಂಭವಾಗಲಿಲ್ಲ. ಸೆಟ್ಟಿಂಗ್‌ಗಳಲ್ಲಿ \'ಧ್ವನಿ ಪರೀಕ್ಷಿಸಿ\' ಬಟನ್ ಒತ್ತಿ.';

  @override
  String get ttsNotAvailable =>
      'ಧ್ವನಿ ಲಭ್ಯವಿರಲಿಲ್ಲ. ಸೆಟ್ಟಿಂಗ್‌ಗಳಲ್ಲಿ \'ಧ್ವನಿ ಪರೀಕ್ಷಿಸಿ\' ಬಟನ್ ಒತ್ತಿ.';

  @override
  String get ttsFailed =>
      'ಧ್ವನಿ ವಿಫಲವಾಯಿತು. ಸೆಟ್ಟಿಂಗ್‌ಗಳಲ್ಲಿ \'ಧ್ವನಿ ಪರೀಕ್ಷಿಸಿ\' ಬಟನ್ ಒತ್ತಿ.';

  @override
  String get ttsLessonResumeFailed =>
      'ರೆಕಾರ್ಡ್ ಮಾಡಿದ ಪಾಠವನ್ನು ಮುಂದುವರಿಸಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ. ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಲು Play ಆರಿಸಿ.';

  @override
  String get ttsStopFailed =>
      'ಧ್ವನಿಯನ್ನು ನಿಲ್ಲಿಸಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ. Android TTS ಎಂಜಿನ್ ಪರಿಶೀಲಿಸಿ.';

  @override
  String get ttsNoPendingUpdates => 'ಬಾಕಿ ಇರುವ ಅಪ್‌ಡೇಟ್‌ಗಳಿಲ್ಲ.';

  @override
  String get ttsOtherUpdates => 'ಇತರ ಅಪ್‌ಡೇಟ್‌ಗಳು';

  @override
  String ttsUpdateGroup(String group) {
    return '$group.';
  }

  @override
  String ttsUpdateGroupCount(String group, int count) {
    return '$group, $count ಅಪ್‌ಡೇಟ್‌ಗಳು.';
  }

  @override
  String ttsOtherUpdateGroups(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ಇತರ ಅಪ್‌ಡೇಟ್ ಗುಂಪುಗಳು.',
      one: '1 ಇತರ ಅಪ್‌ಡೇಟ್ ಗುಂಪು.',
    );
    return '$_temp0';
  }

  @override
  String get settingsScreenName => 'ಸೆಟ್ಟಿಂಗ್‌ಗಳು';

  @override
  String get settingsSections =>
      'ನಾಲ್ಕು ವಿಭಾಗಗಳು: ಧ್ವನಿ, ಪ್ರದರ್ಶನ, ಕೀಗಳು ಮತ್ತು ಸಹಾಯ, ನಂತರ ಸೆಟ್ಟಿಂಗ್‌ಗಳನ್ನು ಉಳಿಸಿ';

  @override
  String get settingsLoaded => 'ಸೆಟ್ಟಿಂಗ್‌ಗಳು ಲೋಡ್ ಆಗಿವೆ';

  @override
  String get settingsSaved => 'ಸೆಟ್ಟಿಂಗ್‌ಗಳನ್ನು ಉಳಿಸಲಾಗಿದೆ';

  @override
  String get settingsResetSaved =>
      'ಸೆಟ್ಟಿಂಗ್‌ಗಳನ್ನು ಡೀಫಾಲ್ಟ್‌ಗೆ ಮರುಹೊಂದಿಸಿ ಉಳಿಸಲಾಗಿದೆ';

  @override
  String settingsTestSpeech(String volume, String speed) {
    return 'ಇದು ಟೆಕ್ಸ್ಟ್-ಟು-ಸ್ಪೀಚ್ ವ್ಯವಸ್ಥೆಯ ಪರೀಕ್ಷೆ. ವಾಲ್ಯೂಮ್ $volume ಪ್ರತಿಶತ. ಧ್ವನಿಯ ವೇಗ $speed.';
  }

  @override
  String settingsFastestSpeed(String speed) {
    return 'ಅತಿ ಹೆಚ್ಚು ಧ್ವನಿ ವೇಗ, $speed';
  }

  @override
  String settingsSlowestSpeed(String speed) {
    return 'ಅತಿ ಕಡಿಮೆ ಧ್ವನಿ ವೇಗ, $speed';
  }

  @override
  String settingsSpeechSpeed(String speed) {
    return 'ಧ್ವನಿ ವೇಗ $speed';
  }

  @override
  String get settingsVoiceCommandsEnabled => 'ಧ್ವನಿ ಆಜ್ಞೆಗಳು ಆನ್ ಆಗಿವೆ';

  @override
  String get settingsVoiceCommandsDisabled => 'ಧ್ವನಿ ಆಜ್ಞೆಗಳು ಆಫ್ ಆಗಿವೆ';

  @override
  String get settingsHighContrastOn => 'ಹೈ ಕಾಂಟ್ರಾಸ್ಟ್ ಆನ್';

  @override
  String get settingsHighContrastOff => 'ಹೈ ಕಾಂಟ್ರಾಸ್ಟ್ ಆಫ್';

  @override
  String get settingsShortcutsShown => 'ಕೀಪ್ಯಾಡ್ ಶಾರ್ಟ್‌ಕಟ್‌ಗಳನ್ನು ತೋರಿಸಲಾಗಿದೆ';

  @override
  String get settingsShortcutsHidden =>
      'ಕೀಪ್ಯಾಡ್ ಶಾರ್ಟ್‌ಕಟ್‌ಗಳನ್ನು ಮರೆಮಾಡಲಾಗಿದೆ';

  @override
  String get settingsVoiceHelp =>
      'ಸೆಷನ್‌ನಲ್ಲಿ, ಆಜ್ಞೆಗಾಗಿ ಆಲಿಸಿ ಅನ್ನು ಸಕ್ರಿಯಗೊಳಿಸಿ, ನಂತರ ಮ್ಯೂಟ್, ಅನ್‌ಮ್ಯೂಟ್, ಕೈ ಎತ್ತಿ, ಕೈ ಇಳಿಸಿ, ಬಿಡಿ, ಅಥವಾ ಮತ್ತೆ ಹೇಳಿ ಎಂದು ಹೇಳಿ. ಆಲಿಸುವುದು ತಾನಾಗಿಯೇ ಮತ್ತೆ ಪ್ರಾರಂಭವಾಗುವುದಿಲ್ಲ. ಅನ್‌ಮ್ಯೂಟ್‌ಗೆ ಕೀ ಅಥವಾ ಸ್ಪರ್ಶದ ಮೂಲಕ ಖಚಿತಪಡಿಸುವಿಕೆ ಕೇಳಲಾಗುತ್ತದೆ.';

  @override
  String settingsModeAutomatic(String current) {
    return 'ಸ್ವಯಂಚಾಲಿತ: ನೀವು ಆರಿಸದಿದ್ದರೆ TalkBack ಅನ್ನು ಅನುಸರಿಸುತ್ತದೆ. ಈಗ $current.';
  }

  @override
  String get settingsModeUsingScreenReader => 'ಸ್ಕ್ರೀನ್ ರೀಡರ್ ಬಳಸಲಾಗುತ್ತಿದೆ';

  @override
  String get settingsModeUsingSelfVoicing => 'ಆ್ಯಪ್ ತಾನೇ ಮಾತನಾಡುತ್ತಿದೆ';

  @override
  String get settingsModeScreenReader =>
      'ಸ್ಕ್ರೀನ್ ರೀಡರ್: ಪ್ರಕಟಣೆಗಳು TalkBack ಗೆ ಹೋಗುತ್ತವೆ. ಆ್ಯಪ್ ನಿರೂಪಣೆ ಆಫ್ ಆಗಿದೆ.';

  @override
  String get settingsModeSelfVoicing => 'ಸ್ವಯಂ ಧ್ವನಿ: ಆ್ಯಪ್ ತಾನೇ ಮಾತನಾಡುತ್ತದೆ.';

  @override
  String settingsSoundCues(String state) {
    return 'ಧ್ವನಿ ಸೂಚನೆಗಳು $state.';
  }

  @override
  String settingsSoundCuesOnSaved(String state) {
    return 'ಧ್ವನಿ ಸೂಚನೆಗಳು $state. ಇದು ಉಳಿಸಿದಾಗ ಬರುವ ಧ್ವನಿ.';
  }

  @override
  String settingsVibration(String state) {
    return 'ಕಂಪನ $state.';
  }

  @override
  String settingsVibrationOnBuzz(String state) {
    return 'ಕಂಪನ $state. ಒಂದು ಸಣ್ಣ ಕಂಪನ ಎಂದರೆ ಸರಿ.';
  }

  @override
  String settingsSoundCuesLabel(String state) {
    return 'ಧ್ವನಿ ಸೂಚನೆಗಳು, $state. ಸರಿ, ತಪ್ಪು, ಉಳಿಸಲಾಗಿದೆ, ದೋಷಗಳು ಮತ್ತು ನೀವು ಮಾತನಾಡುವ ಸರದಿಗೆ ಸಣ್ಣ ಧ್ವನಿಗಳು';
  }

  @override
  String settingsVibrationLabel(String state) {
    return 'ಕಂಪನ, $state. ಸರಿಗೆ ಒಂದು ಕಂಪನ, ದೋಷಕ್ಕೆ ಎರಡು, ಹೊರಹೋಗಲು ಒಂದು ದೀರ್ಘ ಕಂಪನ';
  }

  @override
  String get settingsSoundCuesHelp =>
      'ಸರಿ, ತಪ್ಪು, ಉಳಿಸಲಾಗಿದೆ, ದೋಷಗಳು, ಪಟ್ಟಿಯ ಕೊನೆ ಮತ್ತು ನೀವು ಮಾತನಾಡುವ ಸರದಿಗೆ ಸಣ್ಣ ಧ್ವನಿಗಳು. ತಕ್ಷಣ ಉಳಿಸಲಾಗುತ್ತದೆ.';

  @override
  String get settingsVibrationHelp =>
      'ಸರಿಗೆ ಒಂದು ಸಣ್ಣ ಕಂಪನ, ದೋಷಕ್ಕೆ ಎರಡು, ಹೊರಹೋಗಲು ಅಥವಾ ಮುಗಿಸಲು ಒಂದು ದೀರ್ಘ ಕಂಪನ. ತಕ್ಷಣ ಉಳಿಸಲಾಗುತ್ತದೆ.';

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
    return 'ಆ್ಯಪ್ ಧ್ವನಿ $speech, ವೇಗ $speed, ವಾಲ್ಯೂಮ್ $volume ಪ್ರತಿಶತ. ಅಕ್ಷರದ ಗಾತ್ರ $textSize ಪ್ರತಿಶತ. ಹೈ ಕಾಂಟ್ರಾಸ್ಟ್ $highContrast. ಧ್ವನಿ ಸೂಚನೆಗಳು $soundCues. ಕಂಪನ $vibration. ಮಾತಿನ ಭಾಷೆ $language.';
  }

  @override
  String settingsVolume(String percent) {
    return 'ವಾಲ್ಯೂಮ್ $percent ಪ್ರತಿಶತ';
  }

  @override
  String settingsTextSize(String percent) {
    return 'ಅಕ್ಷರದ ಗಾತ್ರ $percent ಪ್ರತಿಶತ';
  }

  @override
  String get settingsSpeechOff => 'ಆ್ಯಪ್ ಧ್ವನಿ ಆಫ್';

  @override
  String get settingsSpeechOn => 'ಆ್ಯಪ್ ಧ್ವನಿ ಆನ್';

  @override
  String settingsSpeechMode(String description) {
    return 'ಮಾತಿನ ವಿಧಾನ. $description';
  }

  @override
  String settingsNarration(String level) {
    return 'ನಿರೂಪಣೆಯ ಮಟ್ಟ $level.';
  }

  @override
  String get settingsNarrationEssential => 'ಅಗತ್ಯ';

  @override
  String get settingsNarrationStandard => 'ಸಾಮಾನ್ಯ';

  @override
  String get settingsNarrationDetailed => 'ವಿವರವಾದ';

  @override
  String settingsLanguage(String language) {
    return 'ಮಾತಿನ ಭಾಷೆ $language.';
  }

  @override
  String settingsLanguageLabel(String language) {
    return 'ಮಾತಿನ ಭಾಷೆ, $language. ಬದಲಾಯಿಸಲು ಓಕೆ ಒತ್ತಿ.';
  }

  @override
  String get settingsBack => 'ಹಿಂದೆ';

  @override
  String get settingsResetLabel =>
      'ಸೆಟ್ಟಿಂಗ್‌ಗಳನ್ನು ಮೂಲ ಸ್ಥಿತಿಗೆ ಮರುಹೊಂದಿಸಿ, ದೃಢೀಕರಣ ಕೇಳುತ್ತದೆ';

  @override
  String settingsSpeechSectionLabel(String state) {
    return 'ಮಾತಿನ ವಿಭಾಗ. ಆ್ಯಪ್ ಧ್ವನಿ, $state';
  }

  @override
  String settingsVolumeLabel(String percent) {
    return 'ವಾಲ್ಯೂಮ್ $percent ಪ್ರತಿಶತ. ಬದಲಾಯಿಸಲು ಎಡ ಅಥವಾ ಬಲ';
  }

  @override
  String settingsSpeedLabel(String speed) {
    return 'ಮಾತಿನ ವೇಗ $speed. ಬದಲಾಯಿಸಲು ಎಡ ಅಥವಾ ಬಲ';
  }

  @override
  String get settingsTestLabel => 'ಧ್ವನಿ ಪರೀಕ್ಷಿಸಿ';

  @override
  String settingsModeLabel(String description) {
    return 'ಮಾತಿನ ವಿಧಾನ. $description ಬದಲಾಯಿಸಲು ಓಕೆ ಒತ್ತಿ.';
  }

  @override
  String settingsNarrationLabel(String level) {
    return 'ನಿರೂಪಣೆಯ ಮಟ್ಟ $level. ಬದಲಾಯಿಸಲು ಓಕೆ ಒತ್ತಿ.';
  }

  @override
  String settingsCheckVoiceLabel(String language) {
    return '$language ಧ್ವನಿ ಪರಿಶೀಲಿಸಿ';
  }

  @override
  String get settingsStopLabel => 'ಮಾತು ನಿಲ್ಲಿಸಿ';

  @override
  String settingsContrastLabel(String state) {
    return 'ಪ್ರದರ್ಶನ ವಿಭಾಗ. ಹೈ ಕಾಂಟ್ರಾಸ್ಟ್, $state. ಮೊದಲಿನಿಂದ ಆನ್ ಆಗಿರುತ್ತದೆ';
  }

  @override
  String settingsTextSizeLabel(String percent) {
    return 'ಅಕ್ಷರದ ಗಾತ್ರ $percent ಪ್ರತಿಶತ. ಬದಲಾಯಿಸಲು ಎಡ ಅಥವಾ ಬಲ';
  }

  @override
  String settingsShortcutsLabel(String state) {
    return 'ಕೀಗಳು ಮತ್ತು ಸಹಾಯ ವಿಭಾಗ. ಕೀಪ್ಯಾಡ್ ಶಾರ್ಟ್‌ಕಟ್‌ಗಳನ್ನು ತೋರಿಸಿ, $state';
  }

  @override
  String settingsVoiceCommandsLabel(String state) {
    return 'ಸೆಷನ್‌ಗಳಲ್ಲಿ ಧ್ವನಿ ಆದೇಶಗಳು, $state';
  }

  @override
  String get settingsVoiceHelpLabel => 'ಧ್ವನಿ ಆದೇಶ ಸಹಾಯ';

  @override
  String get settingsRepeatHelpLabel => 'ಸೆಟ್ಟಿಂಗ್‌ಗಳ ಸಹಾಯವನ್ನು ಮತ್ತೆ ಕೇಳಿ';

  @override
  String get settingsSaveLabel => 'ಸೆಟ್ಟಿಂಗ್‌ಗಳನ್ನು ಉಳಿಸಿ';

  @override
  String get settingsResetQuestion =>
      'ಎಲ್ಲಾ ಸೆಟ್ಟಿಂಗ್‌ಗಳನ್ನು ಮೂಲ ಸ್ಥಿತಿಗೆ ಮರುಹೊಂದಿಸಬೇಕೇ? ಮಾತು, ಪ್ರದರ್ಶನ ಮತ್ತು ಕೀ ಸೆಟ್ಟಿಂಗ್‌ಗಳು ಮೂಲ ಮೌಲ್ಯಗಳಿಗೆ ಹಿಂತಿರುಗುತ್ತವೆ.';

  @override
  String settingsResetScreen(String question) {
    return 'ಸೆಟ್ಟಿಂಗ್‌ಗಳನ್ನು ಮರುಹೊಂದಿಸಿ. $question';
  }

  @override
  String get settingsResetCancel => 'ರದ್ದುಮಾಡಿ';

  @override
  String get settingsResetConfirm => 'ಮರುಹೊಂದಿಸಿ';

  @override
  String get settingsResetCancelLabel =>
      'ರದ್ದುಮಾಡಿ, ನನ್ನ ಸೆಟ್ಟಿಂಗ್‌ಗಳನ್ನು ಉಳಿಸಿಕೊಳ್ಳಿ';

  @override
  String get settingsResetConfirmLabel =>
      'ಎಲ್ಲಾ ಸೆಟ್ಟಿಂಗ್‌ಗಳನ್ನು ಮೂಲ ಸ್ಥಿತಿಗೆ ಮರುಹೊಂದಿಸಿ';

  @override
  String get quizNotSet => 'ಹೊಂದಿಸಿಲ್ಲ';

  @override
  String get quizNotAvailable => 'ಲಭ್ಯವಿಲ್ಲ';

  @override
  String get quizNotAvailableCapital => 'ಲಭ್ಯವಿಲ್ಲ';

  @override
  String quizQuestionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ಪ್ರಶ್ನೆಗಳು',
      one: '1 ಪ್ರಶ್ನೆ',
    );
    return '$_temp0';
  }

  @override
  String quizAttemptCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ಪ್ರಯತ್ನಗಳು',
      one: '1 ಪ್ರಯತ್ನ',
    );
    return '$_temp0';
  }

  @override
  String quizStudentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ವಿದ್ಯಾರ್ಥಿಗಳು',
      one: '1 ವಿದ್ಯಾರ್ಥಿ',
    );
    return '$_temp0';
  }

  @override
  String get quizAccountChanged =>
      'ನಿಮ್ಮ ಖಾತೆ ಬದಲಾಗಿದೆ. ಕ್ವಿಜ್‌ಗಳಿಗೆ ಹಿಂತಿರುಗಿ ಮತ್ತೆ ಸೈನ್ ಇನ್ ಮಾಡಿ.';

  @override
  String get quizUnlimitedPractice =>
      'ಅನಿಯಮಿತ ಅಭ್ಯಾಸ ಪ್ರಯತ್ನಗಳು. ಅಂಕ ನೀಡುವುದಿಲ್ಲ.';

  @override
  String quizAttemptsRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ಪ್ರಯತ್ನಗಳು ಉಳಿದಿವೆ.',
      one: '1 ಪ್ರಯತ್ನ ಉಳಿದಿದೆ.',
    );
    return '$_temp0';
  }

  @override
  String quizTimeLimit(String duration) {
    return 'ಸಮಯ ಮಿತಿ $duration.';
  }

  @override
  String get quizNoTimeLimit => 'ಸಮಯ ಮಿತಿ ಇಲ್ಲ.';

  @override
  String get quizNoTimeLimitShort => 'ಸಮಯ ಮಿತಿ ಇಲ್ಲ';

  @override
  String get quizFeedbackAfterCompletion =>
      'ನೀವು ಕ್ವಿಜ್ ಮುಗಿಸಿದ ನಂತರ ಉತ್ತರದ ಪ್ರತಿಕ್ರಿಯೆ ಮತ್ತು ಅಂಕಗಳನ್ನು ನೀಡಲಾಗುತ್ತದೆ.';

  @override
  String quizFeedbackScheduled(String when) {
    return 'ನೀವು ಮುಗಿಸಿದ ನಂತರ ಮತ್ತು $when ನಂತರ ಪ್ರತಿಕ್ರಿಯೆ ಮತ್ತು ಅಂಕಗಳನ್ನು ನೀಡಲಾಗುತ್ತದೆ.';
  }

  @override
  String get quizFeedbackScoreOnly =>
      'ನೀವು ಮುಗಿಸಿದ ನಂತರ ಅಂಕಗಳನ್ನು ಮಾತ್ರ ನೀಡಲಾಗುತ್ತದೆ. ಉತ್ತರಗಳು ಮತ್ತು ವಿವರಣೆಗಳನ್ನು ನೀಡಲಾಗುವುದಿಲ್ಲ.';

  @override
  String get quizFeedbackImmediate =>
      'ಪ್ರತಿ ಉತ್ತರ ಸಲ್ಲಿಸಿದ ತಕ್ಷಣ ಅದು ಸರಿಯೇ ಎಂದು ನೀವು ಕೇಳುತ್ತೀರಿ.';

  @override
  String get quizPolicyAfterCompletion => 'ಕ್ವಿಜ್ ಮುಗಿದ ನಂತರ';

  @override
  String get quizPolicyScheduled => 'ನಿಗದಿತ ಸಮಯದಲ್ಲಿ';

  @override
  String get quizPolicyScoreOnly => 'ಅಂಕ ಮಾತ್ರ';

  @override
  String get quizPolicyLegacyImmediate => 'ತಕ್ಷಣ, ಹಳೆಯ ಸೆಟ್ಟಿಂಗ್';

  @override
  String get quizPolicyImmediate => 'ಪ್ರತಿ ಉತ್ತರದ ತಕ್ಷಣ';

  @override
  String quizPracticeResult(String correct, String total) {
    return 'ಅಭ್ಯಾಸ, ಶೈಕ್ಷಣಿಕ ಗ್ರೇಡ್ ಅಲ್ಲ. ಈ ಅಭ್ಯಾಸದಲ್ಲಿ $total ರಲ್ಲಿ $correct ಸರಿ.';
  }

  @override
  String quizScoreNotReleased(String message) {
    return 'ಅಂಕ ನೀಡಿಲ್ಲ. $message';
  }

  @override
  String get quizCheckReleasePolicy => 'ಬಿಡುಗಡೆ ನೀತಿಯನ್ನು ಪರಿಶೀಲಿಸಿ.';

  @override
  String quizScoreResult(String correct, String total, String percent) {
    return 'ಅಂಕ $total ರಲ್ಲಿ $correct, $percent.';
  }

  @override
  String get quizStatusInProgress => 'ನಡೆಯುತ್ತಿದೆ';

  @override
  String get quizStatusTimedOut => 'ಸಮಯ ಮುಗಿದಾಗ ಮುಕ್ತಾಯವಾಯಿತು';

  @override
  String get quizStatusCompleted => 'ಮುಗಿದಿದೆ';

  @override
  String get quizStatusPublished => 'ಪ್ರಕಟಿತ';

  @override
  String get quizStatusDraft => 'ಕರಡು';

  @override
  String get quizStatusClosed => 'ಮುಚ್ಚಲಾಗಿದೆ';

  @override
  String get quizStatusScheduled => 'ನಿಗದಿಯಾಗಿದೆ';

  @override
  String get quizStatusOpen => 'ತೆರೆದಿದೆ';

  @override
  String quizQuestionHeading(String number, String total) {
    return 'ಪ್ರಶ್ನೆ $number, ಒಟ್ಟು $total';
  }

  @override
  String quizQuestionWithText(String number, String total, String text) {
    return 'ಪ್ರಶ್ನೆ $number, ಒಟ್ಟು $total. $text';
  }

  @override
  String quizOptionSpoken(String number, String text) {
    return 'ಆಯ್ಕೆ $number. $text.';
  }

  @override
  String quizOptionLabel(String number, String count, String text) {
    return 'ಆಯ್ಕೆ $number, ಒಟ್ಟು $count, $text';
  }

  @override
  String quizOptionTargetSelected(String number, String text) {
    return 'ಆಯ್ಕೆ $number, $text, ಆಯ್ಕೆಮಾಡಲಾಗಿದೆ. ಆರಿಸಲು ಓಕೆ ಅಥವಾ $number ಒತ್ತಿ';
  }

  @override
  String quizOptionTargetNotSelected(String number, String text) {
    return 'ಆಯ್ಕೆ $number, $text, ಆಯ್ಕೆಮಾಡಿಲ್ಲ. ಆರಿಸಲು ಓಕೆ ಅಥವಾ $number ಒತ್ತಿ';
  }

  @override
  String quizAnswerKeysBrief(String count) {
    return '1 ರಿಂದ $count ಒತ್ತಿ, ನಂತರ 5.';
  }

  @override
  String quizAnswerKeysDetailed(String count) {
    return 'ಉತ್ತರ ಆರಿಸಲು 1 ರಿಂದ $count ಒತ್ತಿ, ನಂತರ ಸಲ್ಲಿಸಲು 5 ಒತ್ತಿ. ಪ್ರಶ್ನೆಯನ್ನು ಮತ್ತೆ ಕೇಳಲು 6, ನೀವು ಎಲ್ಲಿದ್ದೀರಿ ಎಂದು ಕೇಳಲು 8 ಒತ್ತಿ.';
  }

  @override
  String quizChosenBrief(String number, String text) {
    return 'ಆಯ್ಕೆ $number, $text, ಆಯ್ಕೆಮಾಡಲಾಗಿದೆ.';
  }

  @override
  String quizChosenDetailed(String number, String text) {
    return 'ಆಯ್ಕೆ $number, $text, ಆಯ್ಕೆಮಾಡಲಾಗಿದೆ. ಸಲ್ಲಿಸಲು 5 ಒತ್ತಿ, ಅಥವಾ ಬೇರೆ ಸಂಖ್ಯೆ ಆರಿಸಿ.';
  }

  @override
  String quizChooseFirst(String count) {
    return 'ಮೊದಲು ಒಂದು ಉತ್ತರ ಆರಿಸಿ. 1 ರಿಂದ $count ಒತ್ತಿ, ನಂತರ ಸಲ್ಲಿಸಲು 5 ಒತ್ತಿ.';
  }

  @override
  String quizNoSuchOption(String option, String count) {
    return 'ಆಯ್ಕೆ $option ಇಲ್ಲ. 1 ರಿಂದ $count ಒತ್ತಿ.';
  }

  @override
  String get quizSubmitting => 'ನಿಮ್ಮ ಉತ್ತರವನ್ನು ಸಲ್ಲಿಸಲಾಗುತ್ತಿದೆ.';

  @override
  String quizCorrectFeedback(String answer) {
    return 'ಸರಿ! $answer.';
  }

  @override
  String quizWrongFeedback(String answer) {
    return 'ಸರಿಯಾಗಿಲ್ಲ. ಉತ್ತರ $answer.';
  }

  @override
  String get quizAnswerSavedBrief => 'ಉತ್ತರ ಉಳಿಸಲಾಗಿದೆ.';

  @override
  String get quizAnswerSavedLocked => 'ಉತ್ತರ ಉಳಿಸಿ ಲಾಕ್ ಮಾಡಲಾಗಿದೆ.';

  @override
  String get quizSavedHeading => 'ಉತ್ತರ ಉಳಿಸಿ ಲಾಕ್ ಮಾಡಲಾಗಿದೆ';

  @override
  String get quizCorrectHeading => 'ಸರಿ';

  @override
  String get quizWrongHeading => 'ತಪ್ಪು';

  @override
  String quizYouSelected(String text) {
    return 'ನೀವು ಆರಿಸಿದ್ದು: $text';
  }

  @override
  String quizCorrectAnswerIs(String text) {
    return 'ಸರಿಯಾದ ಉತ್ತರ: $text';
  }

  @override
  String get quizNoExplanation => 'ಯಾವುದೇ ವಿವರಣೆ ನೀಡಿಲ್ಲ.';

  @override
  String quizAnswerFailed(String reason) {
    return '$reason ನಿಮ್ಮ ಆಯ್ಕೆ ಉಳಿದಿದೆ. ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಲು 5 ಒತ್ತಿ.';
  }

  @override
  String get quizAnswerUnreadable => 'ಉತ್ತರದ ದೃಢೀಕರಣವನ್ನು ಓದಲು ಆಗಲಿಲ್ಲ.';

  @override
  String get quizNoOptionSelected => 'ಯಾವುದೇ ಆಯ್ಕೆ ಆರಿಸಿಲ್ಲ.';

  @override
  String quizSelectionSaved(String number, String text) {
    return 'ಆರಿಸಿದ ಆಯ್ಕೆ $number, $text. ಉತ್ತರ ಉಳಿಸಲಾಗಿದೆ.';
  }

  @override
  String quizSelectionNotSubmitted(String number, String text) {
    return 'ಆರಿಸಿದ ಆಯ್ಕೆ $number, $text. ಇನ್ನೂ ಸಲ್ಲಿಸಿಲ್ಲ.';
  }

  @override
  String get quizRepeatQuestion => 'ಪ್ರಶ್ನೆ ಮತ್ತು ಆಯ್ಕೆಗಳನ್ನು ಮತ್ತೆ ಕೇಳಿ';

  @override
  String get quizAnswerConfirmed => 'ಉತ್ತರ ಉಳಿಸಿ ಲಾಕ್ ಮಾಡಿರುವುದು ದೃಢಪಟ್ಟಿದೆ.';

  @override
  String get quizFeedbackStaysAvailable =>
      'ಇದರ ಪ್ರತಿಕ್ರಿಯೆ ಮುಂದಿನ ಪ್ರಶ್ನೆಯಲ್ಲಿ ಖಾಸಗಿಯಾಗಿ ಸಿಗುತ್ತದೆ.';

  @override
  String get quizPreviousFeedback =>
      'ಹಿಂದಿನ ಉತ್ತರದ ಪ್ರತಿಕ್ರಿಯೆಯನ್ನು ಖಾಸಗಿಯಾಗಿ ಕೇಳಿ';

  @override
  String get quizAnswerLockNotice =>
      'ನೀವು 5 ಒತ್ತಿದಾಗ ಪ್ರತಿ ಉತ್ತರ ಉಳಿಸಿ ಲಾಕ್ ಆಗುತ್ತದೆ.';

  @override
  String quizTimeLeft(String duration) {
    return 'ಉಳಿದ ಸಮಯ: $duration.';
  }

  @override
  String quizClockLeft(String clock) {
    return '$clock ಉಳಿದಿದೆ';
  }

  @override
  String quizClockRemaining(String clock) {
    return '$clock ಬಾಕಿ ಇದೆ';
  }

  @override
  String quizTimeWarning(String duration) {
    return 'ಈ ಕ್ವಿಜ್‌ನಲ್ಲಿ $duration ಉಳಿದಿದೆ.';
  }

  @override
  String quizTimeUp(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'ಸಮಯ ಮುಗಿದಿದೆ. $count ಉತ್ತರಗಳನ್ನು ಉಳಿಸಲಾಗಿದೆ. ಕ್ವಿಜ್ ಮುಗಿಸಲಾಗುತ್ತಿದೆ.',
      one: 'ಸಮಯ ಮುಗಿದಿದೆ. 1 ಉತ್ತರ ಉಳಿಸಲಾಗಿದೆ. ಕ್ವಿಜ್ ಮುಗಿಸಲಾಗುತ್ತಿದೆ.',
    );
    return '$_temp0';
  }

  @override
  String quizWhereQuestion(String number, String total) {
    return '$total ರಲ್ಲಿ ಪ್ರಶ್ನೆ $number.';
  }

  @override
  String quizAnsweredCount(String count) {
    return '$count ಉತ್ತರಿಸಲಾಗಿದೆ.';
  }

  @override
  String get quizAllSaved =>
      'ಎಲ್ಲಾ ಉತ್ತರಗಳನ್ನು ಉಳಿಸಲಾಗಿದೆ. ಮುಗಿಸಿ ನಿಮ್ಮ ಫಲಿತಾಂಶ ಕೇಳಲು 5 ಒತ್ತಿ.';

  @override
  String get quizFinishNow => 'ಈಗ ಕ್ವಿಜ್ ಮುಗಿಸಿ, ದೃಢೀಕರಣದೊಂದಿಗೆ';

  @override
  String get quizFinishNowButton => 'ಈಗ ಕ್ವಿಜ್ ಮುಗಿಸಿ';

  @override
  String get quizFinishTitle => 'ಈಗ ಕ್ವಿಜ್ ಮುಗಿಸಬೇಕೆ?';

  @override
  String quizFinishMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'ಸರ್ವರ್ ಪ್ರಕಾರ $count ಪ್ರಶ್ನೆಗಳಿಗೆ ಉತ್ತರಿಸಿಲ್ಲ. ಉಳಿಸಿದ ಉತ್ತರಗಳು ಮಾತ್ರ ಲೆಕ್ಕಕ್ಕೆ ಬರುತ್ತವೆ. ನೀವು ಆರಿಸಿ ಸಲ್ಲಿಸದ ಉತ್ತರವನ್ನು ಸೇರಿಸಲಾಗುವುದಿಲ್ಲ. ಮುಗಿಸಿದ ನಂತರ ಉತ್ತರಗಳನ್ನು ಬದಲಾಯಿಸಲು ಆಗುವುದಿಲ್ಲ.',
      one:
          'ಸರ್ವರ್ ಪ್ರಕಾರ 1 ಪ್ರಶ್ನೆಗೆ ಉತ್ತರಿಸಿಲ್ಲ. ಉಳಿಸಿದ ಉತ್ತರಗಳು ಮಾತ್ರ ಲೆಕ್ಕಕ್ಕೆ ಬರುತ್ತವೆ. ನೀವು ಆರಿಸಿ ಸಲ್ಲಿಸದ ಉತ್ತರವನ್ನು ಸೇರಿಸಲಾಗುವುದಿಲ್ಲ. ಮುಗಿಸಿದ ನಂತರ ಉತ್ತರಗಳನ್ನು ಬದಲಾಯಿಸಲು ಆಗುವುದಿಲ್ಲ.',
    );
    return '$_temp0';
  }

  @override
  String get quizFinishConfirm => 'ಕ್ವಿಜ್ ಮುಗಿಸಿ';

  @override
  String get quizFinishCancel => 'ಮುಂದುವರಿಸಿ';

  @override
  String get quizFinishUnchecked =>
      'ನಿಮ್ಮ ಉಳಿಸಿದ ಉತ್ತರಗಳನ್ನು ಪರಿಶೀಲಿಸಲು ಆಗಲಿಲ್ಲ, ಅಥವಾ ಈ ಪ್ರಯತ್ನ ಮುಗಿದಿದೆ. ಕ್ವಿಜ್ ಮುಗಿಸಿಲ್ಲ. ರಿಫ್ರೆಶ್ ಮಾಡಲು ಕ್ವಿಜ್ ಪಟ್ಟಿಗೆ ಹಿಂತಿರುಗಿ.';

  @override
  String get quizFinishTimedOut =>
      'ನಿಮ್ಮ ಉಳಿಸಿದ ಉತ್ತರಗಳನ್ನು ಪರಿಶೀಲಿಸಲು ತುಂಬಾ ಸಮಯ ಹಿಡಿಯಿತು. ಕ್ವಿಜ್ ಮುಗಿಸಿಲ್ಲ. ನಿಮ್ಮ ಸಂಪರ್ಕ ಪರಿಶೀಲಿಸಿ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get quizFinishing => 'ಕ್ವಿಜ್ ಮುಗಿಸಲಾಗುತ್ತಿದೆ';

  @override
  String get quizFinishAndHear => 'ಮುಗಿಸಿ ಫಲಿತಾಂಶ ಕೇಳಿ';

  @override
  String get quizRetryFinishing => 'ಮುಗಿಸಲು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ';

  @override
  String quizCompletionFailed(String reason) {
    return '$reason ನಿಮ್ಮ ಉಳಿಸಿದ ಉತ್ತರಗಳು ಸುರಕ್ಷಿತವಾಗಿವೆ. ಮುಗಿಸಲು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಲು 5 ಒತ್ತಿ.';
  }

  @override
  String get quizCompletionNotConfirmed => 'ಪೂರ್ಣಗೊಂಡಿರುವುದು ದೃಢಪಟ್ಟಿಲ್ಲ.';

  @override
  String get quizCompleted =>
      'ಕ್ವಿಜ್ ಮುಗಿದಿದೆ. ನಿಮ್ಮ ಫಲಿತಾಂಶ ಖಾಸಗಿಯಾಗಿದೆ. ಅದನ್ನು ಕೇಳಲು 8 ಒತ್ತಿ, ಅಥವಾ ಕ್ವಿಜ್‌ಗಳಿಗೆ ಹಿಂತಿರುಗಲು 0 ಒತ್ತಿ.';

  @override
  String get quizCompletedTimedOut =>
      'ಸಮಯ ಮುಗಿಯಿತು. ಕ್ವಿಜ್ ಮುಗಿದಿದೆ. ನಿಮ್ಮ ಫಲಿತಾಂಶ ಖಾಸಗಿಯಾಗಿದೆ. ಅದನ್ನು ಕೇಳಲು 8 ಒತ್ತಿ, ಅಥವಾ ಕ್ವಿಜ್‌ಗಳಿಗೆ ಹಿಂತಿರುಗಲು 0 ಒತ್ತಿ.';

  @override
  String get quizResultPrivate =>
      'ಕ್ವಿಜ್ ಮುಗಿದಿದೆ. ಫಲಿತಾಂಶ ಖಾಸಗಿ. ಫಲಿತಾಂಶವನ್ನು ಖಾಸಗಿಯಾಗಿ ಓದಿ ಬಳಸಿ.';

  @override
  String get quizResultHeading => 'ಪ್ರಯತ್ನ ಪೂರ್ಣಗೊಂಡಿದೆ';

  @override
  String get quizReadResult => 'ಫಲಿತಾಂಶವನ್ನು ಖಾಸಗಿಯಾಗಿ ಓದಿ';

  @override
  String get quizReturnToQuizzes => 'ಕ್ವಿಜ್‌ಗಳಿಗೆ ಹಿಂತಿರುಗಿ';

  @override
  String get quizLeave => 'ಸಲ್ಲಿಸದೆ ಹೊರಡಿ, ದೃಢೀಕರಣದೊಂದಿಗೆ';

  @override
  String get quizLeaveTitle => 'ಹೊರಟು ನಂತರ ಮುಂದುವರಿಸಬೇಕೆ?';

  @override
  String get quizLeaveMessage =>
      'ಇದು ನಿಮ್ಮ ಪ್ರಯತ್ನವನ್ನು ಸಲ್ಲಿಸುವುದಿಲ್ಲ. ಉಳಿಸಿದ ಉತ್ತರಗಳು ಮಾತ್ರ ಉಳಿಯುತ್ತವೆ; ನೀವು ಆರಿಸಿ ಸಲ್ಲಿಸದ ಉತ್ತರ ಕಳೆದುಹೋಗಬಹುದು. ಸಮಯ ಮಿತಿ ಇದ್ದರೆ ಅದು ಮುಂದುವರಿಯುತ್ತದೆ. ಕ್ವಿಜ್ ಅನುಮತಿಸುವವರೆಗೆ ನೀವು ಮುಂದುವರಿಸಬಹುದು.';

  @override
  String get quizLeaveConfirm => 'ಸಲ್ಲಿಸದೆ ಹೊರಡಿ';

  @override
  String get quizLeaveCancel => 'ಕ್ವಿಜ್‌ನಲ್ಲೇ ಇರಿ';

  @override
  String get quizWaitBeforeLeaving =>
      'ದಯವಿಟ್ಟು ಕಾಯಿರಿ. ನಿಮ್ಮ ಉತ್ತರ ಇನ್ನೂ ಉಳಿಸಲಾಗುತ್ತಿದೆ.';

  @override
  String quizAttemptScreen(String title) {
    return 'ಕ್ವಿಜ್ ಪ್ರಯತ್ನ, $title';
  }

  @override
  String get quizAttemptNavigationCompleted =>
      'ಕ್ವಿಜ್‌ಗಳಿಗೆ ಹಿಂತಿರುಗಿ, ಫಲಿತಾಂಶವನ್ನು ಖಾಸಗಿಯಾಗಿ ಓದಿ ಮತ್ತು ಕ್ವಿಜ್ ಧ್ವನಿ ವೇಗ';

  @override
  String get quizAttemptNavigationTimed =>
      'ಪ್ರಶ್ನೆ, ಪ್ರತಿ ಉತ್ತರ ಆಯ್ಕೆ, ಆರಿಸಿದ ಉತ್ತರ, ಕ್ವಿಜ್ ಧ್ವನಿ ವೇಗ, ಉಳಿದ ಸಮಯ, ಸಲ್ಲಿಸಿ, ಈಗ ಕ್ವಿಜ್ ಮುಗಿಸಿ ಮತ್ತು ಹೊರಡಿ. ಫೋಕಸ್ ಸರಿಸಿದರೆ ಎಂದಿಗೂ ಆಯ್ಕೆ ಅಥವಾ ಸಲ್ಲಿಕೆ ಆಗುವುದಿಲ್ಲ';

  @override
  String get quizAttemptNavigationUntimed =>
      'ಪ್ರಶ್ನೆ, ಪ್ರತಿ ಉತ್ತರ ಆಯ್ಕೆ, ಆರಿಸಿದ ಉತ್ತರ, ಕ್ವಿಜ್ ಧ್ವನಿ ವೇಗ, ಸಲ್ಲಿಸಿ, ಈಗ ಕ್ವಿಜ್ ಮುಗಿಸಿ ಮತ್ತು ಹೊರಡಿ. ಫೋಕಸ್ ಸರಿಸಿದರೆ ಎಂದಿಗೂ ಆಯ್ಕೆ ಅಥವಾ ಸಲ್ಲಿಕೆ ಆಗುವುದಿಲ್ಲ';

  @override
  String get quizSpeedHelp =>
      'ಕ್ವಿಜ್ ಧ್ವನಿಯನ್ನು ನಿಧಾನ ಅಥವಾ ವೇಗ ಮಾಡಲು 7 ಅಥವಾ 9 ಒತ್ತಿ.';

  @override
  String get quizSpeedScreenReader =>
      'ಕ್ವಿಜ್ ಧ್ವನಿ ವೇಗ ಆ್ಯಪ್ ಧ್ವನಿಯನ್ನು ಮಾತ್ರ ಬದಲಾಯಿಸುತ್ತದೆ. ನಿಮ್ಮ ಸ್ಕ್ರೀನ್ ರೀಡರ್ ವೇಗವನ್ನು Android ಸೆಟ್ಟಿಂಗ್‌ಗಳಲ್ಲಿ ಬದಲಾಯಿಸಿ.';

  @override
  String get quizSpeedHeading => 'ಕ್ವಿಜ್ ಧ್ವನಿ ವೇಗ';

  @override
  String quizSpeedTarget(String description) {
    return 'ಕ್ವಿಜ್ ಧ್ವನಿ ವೇಗ, $description. ಬದಲಾಯಿಸಲು ಎಡ ಅಥವಾ ಬಲ, ಅಥವಾ 7 ಅಥವಾ 9 ಒತ್ತಿ';
  }

  @override
  String quizSpeedRead(String description) {
    return 'ಕ್ವಿಜ್ ಧ್ವನಿ ವೇಗ, $description. ನಿಧಾನಕ್ಕೆ 7 ಅಥವಾ ವೇಗಕ್ಕೆ 9 ಒತ್ತಿ. ಈ ವೇಗವನ್ನು ಕ್ವಿಜ್‌ಗಳಲ್ಲಿ ಮಾತ್ರ ಬಳಸಲಾಗುತ್ತದೆ.';
  }

  @override
  String quizSpeedFaster(String description) {
    return 'ವೇಗವಾಗಿ. $description.';
  }

  @override
  String quizSpeedSlower(String description) {
    return 'ನಿಧಾನವಾಗಿ. $description.';
  }

  @override
  String quizSpeedFastest(String description) {
    return 'ಅತಿ ವೇಗದ ಕ್ವಿಜ್ ಧ್ವನಿ, $description.';
  }

  @override
  String quizSpeedSlowest(String description) {
    return 'ಅತಿ ನಿಧಾನದ ಕ್ವಿಜ್ ಧ್ವನಿ, $description.';
  }

  @override
  String get quizStudentScreen => 'ವಿದ್ಯಾರ್ಥಿ ಕ್ವಿಜ್‌ಗಳು';

  @override
  String get quizStudentNavigation =>
      'ರಿಫ್ರೆಶ್, ಕ್ವಿಜ್ ಸ್ಥಿತಿ ಮತ್ತು ವಿಷಯ ಫಿಲ್ಟರ್‌ಗಳು, ಲಭ್ಯವಿರುವ ಕ್ವಿಜ್‌ಗಳು ಮತ್ತು ಪ್ರಯತ್ನಗಳ ಇತಿಹಾಸ';

  @override
  String get quizStudentIntroBrief =>
      'ಫಿಲ್ಟರ್ ಬದಲಾಯಿಸಲು ಅದರ ಮೇಲೆ ಎಡ ಅಥವಾ ಬಲ ಬಳಸಿ.';

  @override
  String get quizStudentIntroDetailed =>
      'ಫಿಲ್ಟರ್ ಬದಲಾಯಿಸಲು ಅದರ ಮೇಲೆ ಎಡ ಅಥವಾ ಬಲ ಬಳಸಿ. ಕ್ವಿಜ್‌ನ ವಿವರ ಕೇಳಿ ಪ್ರಾರಂಭವನ್ನು ದೃಢೀಕರಿಸಲು ಅದರ ಮೇಲೆ ಓಕೆ ಒತ್ತಿ. ಫೋಕಸ್ ಸರಿಸಿದರೆ ಎಂದಿಗೂ ಕ್ವಿಜ್ ಪ್ರಾರಂಭವಾಗುವುದಿಲ್ಲ.';

  @override
  String quizAvailable(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ಕ್ವಿಜ್‌ಗಳು ಲಭ್ಯವಿವೆ.',
      one: '1 ಕ್ವಿಜ್ ಲಭ್ಯವಿದೆ.',
      zero: 'ಯಾವುದೇ ಕ್ವಿಜ್ ಲಭ್ಯವಿಲ್ಲ.',
    );
    return '$_temp0';
  }

  @override
  String quizStudentState(int count, String open) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ಕ್ವಿಜ್‌ಗಳನ್ನು ತೋರಿಸಲಾಗಿದೆ, $open ತೆರೆದಿವೆ.',
      one: '1 ಕ್ವಿಜ್ ತೋರಿಸಲಾಗಿದೆ, $open ತೆರೆದಿದೆ.',
    );
    return '$_temp0';
  }

  @override
  String get quizStateAll => 'ಎಲ್ಲಾ ಸ್ಥಿತಿಗಳು';

  @override
  String get quizStateScheduled => 'ನಿಗದಿಯಾಗಿದೆ';

  @override
  String get quizStateOpen => 'ತೆರೆದಿದೆ';

  @override
  String get quizStateClosed => 'ಮುಚ್ಚಲಾಗಿದೆ';

  @override
  String quizStateFilter(String name, String position, String count) {
    return 'ಕ್ವಿಜ್ ಸ್ಥಿತಿ: $name, $count ರಲ್ಲಿ $position.';
  }

  @override
  String quizSubjectFilter(String name, String position, String count) {
    return 'ವಿಷಯ: $name, $count ರಲ್ಲಿ $position.';
  }

  @override
  String get quizChangeWithArrows => 'ಬದಲಾಯಿಸಲು ಎಡ ಅಥವಾ ಬಲ';

  @override
  String get quizAllSubjects => 'ಎಲ್ಲಾ ವಿಷಯಗಳು';

  @override
  String quizRowHead(String subject, String title, String status) {
    return '$subject, $title, $status.';
  }

  @override
  String get quizStartQuiz => 'ಕ್ವಿಜ್ ಪ್ರಾರಂಭಿಸಿ';

  @override
  String get quizResumeQuiz => 'ಕ್ವಿಜ್ ಮುಂದುವರಿಸಿ';

  @override
  String quizHistoryRow(String title, String score) {
    return '$title ಪ್ರಯತ್ನಗಳ ಇತಿಹಾಸ ಪರಿಶೀಲಿಸಿ. ಅತಿ ಹೆಚ್ಚು ಅಂಕ $score';
  }

  @override
  String quizLimitReached(String title) {
    return '$title ಗೆ ಯಾವುದೇ ಪ್ರಯತ್ನ ಉಳಿದಿಲ್ಲ. ನಿಮ್ಮ ಅಂಕಗಳನ್ನು ಪರಿಶೀಲಿಸಲು ಪ್ರಯತ್ನಗಳ ಇತಿಹಾಸ ತೆರೆಯಿರಿ.';
  }

  @override
  String get quizStartTitle => 'ಕ್ವಿಜ್ ಪ್ರಾರಂಭಿಸಬೇಕೆ?';

  @override
  String get quizResumeTitle => 'ಕ್ವಿಜ್ ಮುಂದುವರಿಸಬೇಕೆ?';

  @override
  String quizTitleSentence(String title) {
    return '$title.';
  }

  @override
  String quizClosesSentence(String when) {
    return '$when ಮುಚ್ಚುತ್ತದೆ.';
  }

  @override
  String get quizStartAttempt => 'ಪ್ರಯತ್ನ ಪ್ರಾರಂಭಿಸಿ';

  @override
  String get quizResumeAttempt => 'ಪ್ರಯತ್ನ ಮುಂದುವರಿಸಿ';

  @override
  String get quizStartFailed =>
      'ಕ್ವಿಜ್ ಪ್ರಾರಂಭಿಸಲು ಆಗಲಿಲ್ಲ. ಅದು ತೆರೆದಿದೆಯೇ ಎಂದು ಪರಿಶೀಲಿಸಿ.';

  @override
  String get quizHistoryFailed => 'ಪ್ರಯತ್ನಗಳ ಇತಿಹಾಸ ಲೋಡ್ ಮಾಡಲು ಆಗಲಿಲ್ಲ.';

  @override
  String get quizHistoryScreen =>
      'ಪ್ರಯತ್ನಗಳ ಇತಿಹಾಸ. ಅಂಕಗಳು ಖಾಸಗಿ. ಪರಿಶೀಲಿಸಲು ಸಾರಾಂಶ ಅಥವಾ ಒಂದು ಪ್ರಯತ್ನಕ್ಕೆ ಹೋಗಿ.';

  @override
  String get quizPracticeHistory => 'ಅಭ್ಯಾಸ ಇತಿಹಾಸ. ಶೈಕ್ಷಣಿಕ ಅಂಕಗಳಲ್ಲ.';

  @override
  String quizHighestScoreValue(String score) {
    return 'ಅತಿ ಹೆಚ್ಚು ಅಂಕ: $score';
  }

  @override
  String get quizNoScoreReleasedYet =>
      'ಪೂರ್ಣಗೊಂಡ ಪ್ರಯತ್ನಗಳಿವೆ; ಇನ್ನೂ ಯಾವುದೇ ಅಂಕ ಬಿಡುಗಡೆಯಾಗಿಲ್ಲ.';

  @override
  String get quizNoCompletedAttempt => 'ಪೂರ್ಣಗೊಂಡ ಪ್ರಯತ್ನ ಇಲ್ಲ';

  @override
  String quizHistoryAttempt(String number, String status, String result) {
    return 'ಪ್ರಯತ್ನ $number. $status. $result ಪರಿಶೀಲಿಸಲು ಓಕೆ ಒತ್ತಿ.';
  }

  @override
  String get quizResumeFromList =>
      'ಈ ಪ್ರಯತ್ನ ನಡೆಯುತ್ತಿದೆ. ಮುಂದುವರಿಸಲು ಕ್ವಿಜ್ ಪಟ್ಟಿಗೆ ಹಿಂತಿರುಗಿ. ಹೊರಟರೆ ಸಲ್ಲಿಕೆ ಆಗುವುದಿಲ್ಲ.';

  @override
  String get quizReviewFailed =>
      'ಪ್ರಯತ್ನದ ಪರಿಶೀಲನೆ ಲೋಡ್ ಮಾಡಲು ಆಗಲಿಲ್ಲ. ನಿಮ್ಮ ಸಂಪರ್ಕ ಪರಿಶೀಲಿಸಿ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get quizReviewTimedOut =>
      'ಪ್ರಯತ್ನದ ಪರಿಶೀಲನೆಗೆ ತುಂಬಾ ಸಮಯ ಹಿಡಿಯಿತು. ನಿಮ್ಮ ಸಂಪರ್ಕ ಪರಿಶೀಲಿಸಿ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String quizReviewScreenMessage(String message) {
    return 'ಪ್ರಯತ್ನದ ಪರಿಶೀಲನೆ. $message';
  }

  @override
  String quizReviewScreen(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'ಪ್ರಯತ್ನದ ಪರಿಶೀಲನೆ. $count ಪ್ರಶ್ನೆಗಳು. ಪ್ರತಿ ಉತ್ತರವನ್ನು ಪರಿಶೀಲಿಸಲು ಮೇಲೆ ಮತ್ತು ಕೆಳಗೆ ಬಳಸಿ.',
      one:
          'ಪ್ರಯತ್ನದ ಪರಿಶೀಲನೆ. 1 ಪ್ರಶ್ನೆ. ಪ್ರತಿ ಉತ್ತರವನ್ನು ಪರಿಶೀಲಿಸಲು ಮೇಲೆ ಮತ್ತು ಕೆಳಗೆ ಬಳಸಿ.',
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
    return 'ಪ್ರಶ್ನೆ $number. ಸರಿ. $question. ನೀವು ಆರಿಸಿದ್ದು $chosen. ಸರಿಯಾದ ಉತ್ತರ $answer. $explanation';
  }

  @override
  String quizReviewQuestionIncorrect(
    String number,
    String question,
    String chosen,
    String answer,
    String explanation,
  ) {
    return 'ಪ್ರಶ್ನೆ $number. ತಪ್ಪು. $question. ನೀವು ಆರಿಸಿದ್ದು $chosen. ಸರಿಯಾದ ಉತ್ತರ $answer. $explanation';
  }

  @override
  String get quizNoAnswer => 'ಉತ್ತರ ಇಲ್ಲ';

  @override
  String quizTeacherScreen(String className, String subjectName) {
    return '$className, $subjectName ಗಾಗಿ ಶಿಕ್ಷಕರ ಕ್ವಿಜ್‌ಗಳು';
  }

  @override
  String get quizTeacherNavigation =>
      'ಬ್ಯಾಂಕ್ ಹುಡುಕಾಟ ಮತ್ತು ಉಳಿಸಿದ ಪ್ರಶ್ನೆಗಳು, ಕ್ವಿಜ್ ಕರಡುಗಳು, ಪ್ರಕಟಿತ ಕ್ವಿಜ್‌ಗಳು ಮತ್ತು ಅವುಗಳ ಫಲಿತಾಂಶಗಳು';

  @override
  String get quizTeacherIntroDetailed =>
      'ಬ್ಯಾಂಕ್ ಹುಡುಕಾಟ ಮತ್ತು ಉಳಿಸಿದ ಪ್ರಶ್ನೆಗಳು, ಕ್ವಿಜ್ ಕರಡುಗಳು, ಪ್ರಕಟಿತ ಕ್ವಿಜ್‌ಗಳು ಮತ್ತು ಫಲಿತಾಂಶಗಳನ್ನು ನೋಡಲು D-pad ಬಳಸಿ.';

  @override
  String quizBankQuestionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ಬ್ಯಾಂಕ್ ಪ್ರಶ್ನೆಗಳು',
      one: '1 ಬ್ಯಾಂಕ್ ಪ್ರಶ್ನೆ',
    );
    return '$_temp0';
  }

  @override
  String quizQuizCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ಕ್ವಿಜ್‌ಗಳು',
      one: '1 ಕ್ವಿಜ್',
    );
    return '$_temp0';
  }

  @override
  String quizDraftCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ಕರಡುಗಳು',
      one: '1 ಕರಡು',
    );
    return '$_temp0';
  }

  @override
  String quizTeacherLoaded(String questions, String quizzes) {
    return '$questions ಮತ್ತು $quizzes ಲೋಡ್ ಆಗಿವೆ.';
  }

  @override
  String quizTeacherState(
    String drafts,
    String published,
    String closed,
    String bankQuestions,
  ) {
    return '$drafts, $published ಪ್ರಕಟಿತ, $closed ಮುಚ್ಚಲಾಗಿದೆ. $bankQuestions.';
  }

  @override
  String get quizTeacherLoadFailed =>
      'ಪ್ರಶ್ನೆ ಬ್ಯಾಂಕ್ ಅಥವಾ ಕ್ವಿಜ್ ಪಟ್ಟಿಯನ್ನು ರಿಫ್ರೆಶ್ ಮಾಡಲು ಆಗಲಿಲ್ಲ. ಇನ್ನೊಂದು ಕ್ವಿಜ್ ರಚಿಸುವ ಮೊದಲು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಲು 1 ಒತ್ತಿ.';

  @override
  String get quizRefreshQuizzes => 'ಕ್ವಿಜ್ ವಿಷಯವನ್ನು ರಿಫ್ರೆಶ್ ಮಾಡಿ';

  @override
  String get quizSearchBank => 'ಖಾಸಗಿ ಪ್ರಶ್ನೆ ಬ್ಯಾಂಕ್ ಹುಡುಕಿ';

  @override
  String get quizCreateQuestion => 'ನಾಲ್ಕು ಆಯ್ಕೆಗಳ ಪ್ರಶ್ನೆ ರಚಿಸಿ';

  @override
  String get quizCreateQuiz => 'ಕ್ವಿಜ್ ಕರಡು ರಚಿಸಿ';

  @override
  String get quizCreatePractice =>
      'ಸಮಯ ಮಿತಿ ಇಲ್ಲದ, ಅಂಕರಹಿತ ಪ್ರತ್ಯೇಕ ಅಭ್ಯಾಸ ರಚಿಸಿ. ಅನಿಯಮಿತ ಮರುಪ್ರಯತ್ನಗಳು';

  @override
  String quizBankQuestionItem(String question, String revision) {
    return 'ಪ್ರಶ್ನೆ ಬ್ಯಾಂಕ್ ಐಟಂ, $question. ಆವೃತ್ತಿ $revision. ಸಂಪಾದನೆ, ಆವೃತ್ತಿ ಇತಿಹಾಸ, ನಕಲು, ಆರ್ಕೈವ್ ಅಥವಾ ಸೇರಿಸುವ ಕ್ರಿಯೆಗಳಿಗೆ ಓಕೆ ಒತ್ತಿ';
  }

  @override
  String get quizRevisionUnknownOlder => 'ತಿಳಿದಿಲ್ಲ, ಹಳೆಯ ಪ್ರಶ್ನೆ';

  @override
  String get quizRevisionUnknownLegacy => 'ತಿಳಿದಿಲ್ಲ, ಹಳೆಯದು';

  @override
  String quizContinueCreating(String title, String questions) {
    return '$title ರಚಿಸುವುದನ್ನು ಮುಂದುವರಿಸಿ. $questions';
  }

  @override
  String quizContinueCreatingRaw(String title, String count) {
    return '$title ರಚಿಸುವುದನ್ನು ಮುಂದುವರಿಸಿ. $count ಪ್ರಶ್ನೆಗಳು';
  }

  @override
  String quizCloseWithConfirmation(String title) {
    return '$title ಮುಚ್ಚಿ, ದೃಢೀಕರಣದೊಂದಿಗೆ';
  }

  @override
  String quizCloseNamed(String title) {
    return '$title ಮುಚ್ಚಿ';
  }

  @override
  String quizIsClosed(String title) {
    return '$title ಮುಚ್ಚಲಾಗಿದೆ';
  }

  @override
  String quizDuplicateTarget(String title) {
    return '$title ಅನ್ನು ಹೊಸ ಸಂಪಾದಿಸಬಹುದಾದ ಕರಡಾಗಿ ನಕಲಿಸಿ';
  }

  @override
  String quizResultsTarget(String title) {
    return '$title ಫಲಿತಾಂಶಗಳನ್ನು ನೋಡಿ';
  }

  @override
  String quizCard(String title, String status, String questions) {
    return '$title. ಸ್ಥಿತಿ $status. $questions.';
  }

  @override
  String get quizAccountChangedBank =>
      'ನಿಮ್ಮ ಖಾತೆ ಬದಲಾಗಿದೆ. ಮುಂದುವರಿಯುವ ಮೊದಲು ಪ್ರಶ್ನೆ ಬ್ಯಾಂಕ್ ಅನ್ನು ಮತ್ತೆ ತೆರೆಯಿರಿ.';

  @override
  String quizQuestionSaveUnconfirmed(String reason) {
    return '$reason ಪ್ರಶ್ನೆ ಉಳಿಸಿರುವುದು ದೃಢಪಟ್ಟಿಲ್ಲ. ಮತ್ತೆ ಪ್ರಯತ್ನಿಸುವ ಮೊದಲು ಬ್ಯಾಂಕ್ ಪರಿಶೀಲಿಸಿ ರಿಫ್ರೆಶ್ ಮಾಡಿ; ನಕಲು ರಚಿಸಬೇಡಿ.';
  }

  @override
  String get quizMissingRevision =>
      'ಸರ್ವರ್ ಆವೃತ್ತಿ ಇಲ್ಲದ ಪ್ರಶ್ನೆಯನ್ನು ಕಳುಹಿಸಿದೆ. ಕ್ವಿಜ್ ಬ್ಯಾಕೆಂಡ್ ಅಪ್‌ಡೇಟ್ ಮಾಡಲು ನಿರ್ವಾಹಕರನ್ನು ಕೇಳಿ.';

  @override
  String get quizSavedQuestionMismatch => 'ಉಳಿಸಿದ ಪ್ರಶ್ನೆ ಹೊಂದಿಕೆಯಾಗಲಿಲ್ಲ.';

  @override
  String get quizQuestionSaved =>
      'ಪ್ರಶ್ನೆ ಉಳಿಸಲಾಗಿದೆ. ಈ ಬ್ಯಾಂಕ್ ಪ್ರಶ್ನೆಯನ್ನು ನಂತರ ಸಂಪಾದಿಸಿದರೆ ಈಗಿರುವ ಕ್ವಿಜ್‌ಗಳು ಬದಲಾಗುವುದಿಲ್ಲ.';

  @override
  String get quizNoRevisionForEdit =>
      'ಈ ಸರ್ವರ್ ಪ್ರಶ್ನೆಯ ಆವೃತ್ತಿಯನ್ನು ನೀಡಲಿಲ್ಲ. ಸಂಪಾದಿಸುವ ಮೊದಲು ಕ್ವಿಜ್ ಬ್ಯಾಕೆಂಡ್ ಅಪ್‌ಡೇಟ್ ಮಾಡಲು ನಿರ್ವಾಹಕರನ್ನು ಕೇಳಿ.';

  @override
  String quizQuestionUpdateUnconfirmed(String reason) {
    return '$reason ಬ್ಯಾಂಕ್ ಪ್ರಶ್ನೆ ಅಪ್‌ಡೇಟ್ ಆಗಿರುವುದು ದೃಢಪಟ್ಟಿಲ್ಲ. ಮತ್ತೆ ಪ್ರಯತ್ನಿಸುವ ಮೊದಲು ರಿಫ್ರೆಶ್ ಮಾಡಿ ಅದರ ಈಗಿನ ಆವೃತ್ತಿಯನ್ನು ಪರಿಶೀಲಿಸಿ.';
  }

  @override
  String get quizSavedRevisionMismatch => 'ಉಳಿಸಿದ ಆವೃತ್ತಿ ಹೊಂದಿಕೆಯಾಗಲಿಲ್ಲ.';

  @override
  String get quizQuestionUpdated =>
      'ಬ್ಯಾಂಕ್ ಪ್ರಶ್ನೆ ಅಪ್‌ಡೇಟ್ ಆಗಿದೆ. ಈಗಿರುವ ಕ್ವಿಜ್ ಪ್ರತಿಗಳನ್ನು ಬದಲಾಯಿಸಿಲ್ಲ.';

  @override
  String get quizArchiveTitle => 'ಬ್ಯಾಂಕ್ ಪ್ರಶ್ನೆಯನ್ನು ಆರ್ಕೈವ್ ಮಾಡಬೇಕೆ?';

  @override
  String get quizArchiveMessage =>
      'ಈ ಖಾಸಗಿ ಬ್ಯಾಂಕ್ ಪ್ರಶ್ನೆಯನ್ನು ಆರ್ಕೈವ್ ಮಾಡಬೇಕೆ? ಈಗಿರುವ ಕ್ವಿಜ್ ಪ್ರತಿಗಳು ಮತ್ತು ಪ್ರಯತ್ನಗಳು ಬದಲಾಗುವುದಿಲ್ಲ.';

  @override
  String get quizArchiveConfirm => 'ಪ್ರಶ್ನೆ ಆರ್ಕೈವ್ ಮಾಡಿ';

  @override
  String get quizArchiveFailed => 'ಬ್ಯಾಂಕ್ ಪ್ರಶ್ನೆಯನ್ನು ಆರ್ಕೈವ್ ಮಾಡಲು ಆಗಲಿಲ್ಲ.';

  @override
  String get quizArchived => 'ಬ್ಯಾಂಕ್ ಪ್ರಶ್ನೆ ಆರ್ಕೈವ್ ಮಾಡಲಾಗಿದೆ.';

  @override
  String get quizDuplicateQuestionFailed =>
      'ಬ್ಯಾಂಕ್ ಪ್ರಶ್ನೆಯನ್ನು ನಕಲಿಸಲು ಆಗಲಿಲ್ಲ.';

  @override
  String get quizQuestionDuplicated => 'ಬ್ಯಾಂಕ್ ಪ್ರಶ್ನೆಯ ನಕಲು ರಚಿಸಲಾಗಿದೆ.';

  @override
  String quizQuestionActions(String question) {
    return '$question ಗಾಗಿ ಕ್ರಿಯೆಗಳು';
  }

  @override
  String get quizActionEdit => 'ಬ್ಯಾಂಕ್ ಪ್ರಶ್ನೆ ಸಂಪಾದಿಸಿ';

  @override
  String get quizActionDuplicate => 'ಬ್ಯಾಂಕ್ ಪ್ರಶ್ನೆ ನಕಲಿಸಿ';

  @override
  String get quizActionArchive => 'ಬ್ಯಾಂಕ್ ಪ್ರಶ್ನೆ ಆರ್ಕೈವ್ ಮಾಡಿ';

  @override
  String get quizActionRevisions => 'ಪ್ರಶ್ನೆಯ ಆವೃತ್ತಿ ಇತಿಹಾಸ ಓದಿ';

  @override
  String quizActionAddTo(String title) {
    return '$title ಗೆ ಸೇರಿಸಿ';
  }

  @override
  String get quizRefreshBeforeDraft =>
      'ಇನ್ನೊಂದು ಕರಡು ರಚಿಸುವ ಮೊದಲು ಕ್ವಿಜ್ ಪಟ್ಟಿಯನ್ನು ರಿಫ್ರೆಶ್ ಮಾಡಿ ಪರಿಶೀಲಿಸಿ.';

  @override
  String quizDraftUnconfirmed(String reason) {
    return '$reason ಕರಡು ಉಳಿಸಿರುವುದು ದೃಢಪಟ್ಟಿಲ್ಲ. ಇನ್ನೊಂದು ಕರಡು ರಚಿಸುವ ಮೊದಲು ಕ್ವಿಜ್ ಪಟ್ಟಿಯನ್ನು ರಿಫ್ರೆಶ್ ಮಾಡಿ.';
  }

  @override
  String get quizSavedDraftMismatch => 'ಉಳಿಸಿದ ಕರಡು ಹೊಂದಿಕೆಯಾಗಲಿಲ್ಲ.';

  @override
  String get quizDraftSaved => 'ಕ್ವಿಜ್ ಕರಡು ಉಳಿಸಲಾಗಿದೆ.';

  @override
  String get quizAddToQuizFailed => 'ಪ್ರಶ್ನೆಯನ್ನು ಈ ಕ್ವಿಜ್‌ಗೆ ಸೇರಿಸಲು ಆಗಲಿಲ್ಲ.';

  @override
  String get quizAddedToQuiz => 'ಪ್ರಶ್ನೆಯನ್ನು ಕ್ವಿಜ್‌ಗೆ ಸೇರಿಸಲಾಗಿದೆ.';

  @override
  String get quizPublishTitle => 'ಕ್ವಿಜ್ ಪ್ರಕಟಿಸಬೇಕೆ?';

  @override
  String quizPublishMessage(String title) {
    return '\"$title\" ಅನ್ನು ಅರ್ಹ ವಿದ್ಯಾರ್ಥಿಗಳಿಗೆ ಪ್ರಕಟಿಸಬೇಕೆ? ಈ ಕ್ವಿಜ್‌ಗೆ ಪ್ರಶ್ನೆಗಳು ಸ್ಥಿರವಾಗುತ್ತವೆ.';
  }

  @override
  String quizPublishMessageSnapshots(String title) {
    return '\"$title\" ಅನ್ನು ಅರ್ಹ ವಿದ್ಯಾರ್ಥಿಗಳಿಗೆ ಪ್ರಕಟಿಸಬೇಕೆ? ಪ್ರಶ್ನೆಗಳು ಶೈಕ್ಷಣಿಕ ಪ್ರತಿಗಳಾಗುತ್ತವೆ.';
  }

  @override
  String get quizPublishConfirm => 'ಕ್ವಿಜ್ ಪ್ರಕಟಿಸಿ';

  @override
  String get quizPublishUnconfirmed =>
      'ಪ್ರಕಟಣೆ ದೃಢಪಟ್ಟಿಲ್ಲ. ಮತ್ತೆ ಪ್ರಯತ್ನಿಸುವ ಮೊದಲು ರಿಫ್ರೆಶ್ ಮಾಡಿ ಕ್ವಿಜ್ ಸ್ಥಿತಿ ಪರಿಶೀಲಿಸಿ.';

  @override
  String get quizPublishedNoRecipients =>
      'ಕ್ವಿಜ್ ಪ್ರಕಟಿಸಲಾಗಿದೆ. ತಿಳಿಸಲು ಯಾವುದೇ ಅರ್ಹ ವಿದ್ಯಾರ್ಥಿಗಳಿಲ್ಲ.';

  @override
  String get quizNoEligibleToNotify => 'ತಿಳಿಸಲು ಯಾವುದೇ ಅರ್ಹ ವಿದ್ಯಾರ್ಥಿಗಳಿಲ್ಲ.';

  @override
  String get quizPublishedNoneDelivered =>
      'ಕ್ವಿಜ್ ಪ್ರಕಟಿಸಲಾಗಿದೆ, ಆದರೆ ಯಾವುದೇ ವಿದ್ಯಾರ್ಥಿ ಸಾಧನಕ್ಕೆ ಅಧಿಸೂಚನೆ ತಲುಪಿಲ್ಲ. ಅಧಿಸೂಚನೆ ನೋಂದಣಿ ಮತ್ತು ಸರ್ವರ್ Firebase ರುಜುವಾತುಗಳನ್ನು ಪರಿಶೀಲಿಸಿ.';

  @override
  String quizPublishedWithFailures(String sent, String failures) {
    return 'ಕ್ವಿಜ್ ಪ್ರಕಟಿಸಲಾಗಿದೆ. $sent ಸಾಧನ ಅಧಿಸೂಚನೆಗಳನ್ನು ಕಳುಹಿಸಲಾಗಿದೆ ಮತ್ತು $failures ವಿಫಲವಾಗಿವೆ.';
  }

  @override
  String quizPublishedSent(String sent) {
    return 'ಕ್ವಿಜ್ ಪ್ರಕಟಿಸಲಾಗಿದೆ. $sent ಸಾಧನ ಅಧಿಸೂಚನೆಗಳನ್ನು ಕಳುಹಿಸಲಾಗಿದೆ.';
  }

  @override
  String get quizCloseTitle => 'ಕ್ವಿಜ್ ಮುಚ್ಚಬೇಕೆ?';

  @override
  String quizCloseMessage(String title) {
    return '\"$title\" ಮುಚ್ಚಬೇಕೆ? ಯಾವುದೇ ಹೊಸ ಪ್ರಯತ್ನ ಪ್ರಾರಂಭಿಸಲು ಆಗುವುದಿಲ್ಲ ಮತ್ತು ನಡೆಯುತ್ತಿರುವ ಪ್ರಯತ್ನಗಳನ್ನು ಮುಗಿಸಲಾಗುತ್ತದೆ.';
  }

  @override
  String quizCloseMessageFinalized(String title) {
    return '\"$title\" ಮುಚ್ಚಬೇಕೆ? ಯಾವುದೇ ಹೊಸ ಪ್ರಯತ್ನ ಪ್ರಾರಂಭಿಸಲು ಆಗುವುದಿಲ್ಲ ಮತ್ತು ನಡೆಯುತ್ತಿರುವ ಪ್ರಯತ್ನಗಳನ್ನು ಅಂತಿಮಗೊಳಿಸಲಾಗುತ್ತದೆ.';
  }

  @override
  String get quizCloseConfirm => 'ಕ್ವಿಜ್ ಮುಚ್ಚಿ';

  @override
  String get quizCloseFailed => 'ಕ್ವಿಜ್ ಮುಚ್ಚಲು ಆಗಲಿಲ್ಲ.';

  @override
  String get quizClosed => 'ಕ್ವಿಜ್ ಮುಚ್ಚಲಾಗಿದೆ.';

  @override
  String get quizDuplicateQuizFailed => 'ಕ್ವಿಜ್‌ನ ನಕಲು ಮಾಡಲು ಆಗಲಿಲ್ಲ.';

  @override
  String get quizQuizDuplicated => 'ಬದಲಾಯಿಸಬಹುದಾದ ಕ್ವಿಜ್ ಕರಡು ರಚಿಸಲಾಗಿದೆ.';

  @override
  String get quizDraftAccountChanged =>
      'ನಿಮ್ಮ ಖಾತೆ ಬದಲಾಗಿದೆ. ಈ ಕರಡನ್ನು ಇಲ್ಲಿ ಪರಿಶೀಲಿಸಲು ಆಗುವುದಿಲ್ಲ.';

  @override
  String get quizDraftLoadFailed =>
      'ಕರಡು ಅಥವಾ ಪ್ರಶ್ನೆ ಬ್ಯಾಂಕ್ ಲೋಡ್ ಆಗಲಿಲ್ಲ. ಮುಂದುವರಿಯುವ ಮೊದಲು ರಿಫ್ರೆಶ್ ಮಾಡಿ.';

  @override
  String quizBankRefreshFailed(String reason) {
    return '$reason ಪ್ರಶ್ನೆ ಬ್ಯಾಂಕ್ ರಿಫ್ರೆಶ್ ಆಗಲಿಲ್ಲ. ಯಾವುದೇ ಪ್ರಶ್ನೆ ಸೇರಿಸಲಾಗಿಲ್ಲ. ಉಳಿಸಿದ ಪ್ರಶ್ನೆ ಆಯ್ಕೆಮಾಡಿ ಅನ್ನು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';
  }

  @override
  String get quizSavedListUnreadable =>
      'ಉಳಿಸಿದ ಪ್ರಶ್ನೆಗಳ ಪಟ್ಟಿಯನ್ನು ಓದಲು ಆಗಲಿಲ್ಲ.';

  @override
  String get quizNoUnusedQuestions =>
      'ಈ ಕಾರ್ಯಕ್ಷೇತ್ರದಲ್ಲಿ ಬಳಸದ ಪ್ರಶ್ನೆಗಳು ಇಲ್ಲ. ಪ್ರಶ್ನೆ ಬರೆಯಿರಿ ಆಯ್ಕೆಮಾಡಿ.';

  @override
  String get quizAllSavedQuestionsUsed =>
      'ಉಳಿಸಿದ ಎಲ್ಲಾ ಪ್ರಶ್ನೆಗಳು ಈಗಾಗಲೇ ಈ ಕ್ವಿಜ್‌ನಲ್ಲಿವೆ. ಪ್ರಶ್ನೆ ಬರೆಯಿರಿ ಆಯ್ಕೆಮಾಡಿ.';

  @override
  String get quizChooseSaved => 'ಉಳಿಸಿದ ಪ್ರಶ್ನೆ ಆಯ್ಕೆಮಾಡಿ';

  @override
  String quizSavedQuestionFrom(
    String question,
    String className,
    String subjectName,
  ) {
    return '$question. $className, $subjectName ಇಂದ';
  }

  @override
  String get quizAnotherClass => 'ಬೇರೆ ತರಗತಿ';

  @override
  String get quizAnotherSubject => 'ಬೇರೆ ವಿಷಯ';

  @override
  String quizAddUnconfirmed(String reason) {
    return '$reason ಪ್ರಶ್ನೆ ಸೇರಿಸಿದ್ದು ಖಚಿತವಾಗಲಿಲ್ಲ. ಮತ್ತೆ ಸೇರಿಸುವ ಮೊದಲು ರಿಫ್ರೆಶ್ ಮಾಡಿ ಉಳಿಸಿದ ಪ್ರಶ್ನೆಗಳನ್ನು ಪರಿಶೀಲಿಸಿ; ಅದು ಈಗಾಗಲೇ ಉಳಿಸಿರಬಹುದು.';
  }

  @override
  String get quizQuestionAddedSentence => 'ಪ್ರಶ್ನೆ ಸೇರಿಸಲಾಗಿದೆ.';

  @override
  String get quizAddAnotherOrReview =>
      'ಇನ್ನೊಂದು ಸೇರಿಸಿ ಅಥವಾ ಪರಿಶೀಲಿಸಿ ಆಯ್ಕೆಮಾಡಿ.';

  @override
  String quizQuestionsSaved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ಪ್ರಶ್ನೆಗಳನ್ನು ಉಳಿಸಲಾಗಿದೆ.',
      one: '1 ಪ್ರಶ್ನೆ ಉಳಿಸಲಾಗಿದೆ.',
    );
    return '$_temp0';
  }

  @override
  String quizQuestionsSavedRaw(String count) {
    return '$count ಪ್ರಶ್ನೆಗಳನ್ನು ಉಳಿಸಲಾಗಿದೆ.';
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
    return '$title. $description $count ಪ್ರಶ್ನೆಗಳು.';
  }

  @override
  String get quizUngradedPracticeSummary =>
      'ಅಂಕರಹಿತ ಅಭ್ಯಾಸ. ಅಪರಿಮಿತ ಪ್ರಯತ್ನಗಳು. ಟೈಮರ್ ಇಲ್ಲ.';

  @override
  String quizGradedSummary(String attempts) {
    return 'ಅಂಕಸಹಿತ ಕ್ವಿಜ್. $attempts.';
  }

  @override
  String quizGradedSummaryRaw(String count) {
    return 'ಅಂಕಸಹಿತ ಕ್ವಿಜ್. $count ಪ್ರಯತ್ನಗಳು.';
  }

  @override
  String get quizNoTimer => 'ಟೈಮರ್ ಇಲ್ಲ.';

  @override
  String quizPerAttempt(String duration) {
    return 'ಪ್ರತಿ ಪ್ರಯತ್ನಕ್ಕೆ $duration.';
  }

  @override
  String quizMinutesPerAttemptRaw(String minutes) {
    return 'ಪ್ರತಿ ಪ್ರಯತ್ನಕ್ಕೆ $minutes ನಿಮಿಷಗಳು.';
  }

  @override
  String quizOpensSentence(String when) {
    return '$when ತೆರೆಯುತ್ತದೆ.';
  }

  @override
  String quizOpensColon(String value) {
    return 'ತೆರೆಯುವುದು: $value.';
  }

  @override
  String quizClosesColon(String value) {
    return 'ಮುಚ್ಚುವುದು: $value.';
  }

  @override
  String get quizWhenPublished => 'ಪ್ರಕಟಿಸಿದಾಗ';

  @override
  String get quizNeverNotScheduled => 'ಎಂದಿಗೂ ಇಲ್ಲ, ನಿಗದಿಪಡಿಸಿಲ್ಲ';

  @override
  String get quizNotScheduled => 'ನಿಗದಿಪಡಿಸಿಲ್ಲ';

  @override
  String quizShuffleQuestionsState(String state) {
    return 'ಪ್ರಶ್ನೆಗಳ ಕ್ರಮ ಬದಲಾವಣೆ $state.';
  }

  @override
  String quizShuffleOptionsState(String state) {
    return 'ಆಯ್ಕೆಗಳ ಕ್ರಮ ಬದಲಾವಣೆ $state.';
  }

  @override
  String quizShuffleQuestionsColon(String state) {
    return 'ಪ್ರಶ್ನೆಗಳ ಕ್ರಮ ಬದಲಾವಣೆ: $state.';
  }

  @override
  String quizShuffleOptionsColon(String state) {
    return 'ಆಯ್ಕೆಗಳ ಕ್ರಮ ಬದಲಾವಣೆ: $state.';
  }

  @override
  String get quizRemoveChoose =>
      'ಈ ಕರಡಿನಿಂದ ತೆಗೆದುಹಾಕಲು ಒಂದು ಪ್ರಶ್ನೆ ಆಯ್ಕೆಮಾಡಿ';

  @override
  String quizRemoveOption(String number, String text) {
    return 'ಪ್ರಶ್ನೆ $number: $text';
  }

  @override
  String get quizRemoveTitle => 'ಆಯ್ಕೆಮಾಡಿದ ಪ್ರಶ್ನೆಯನ್ನು ತೆಗೆದುಹಾಕಬೇಕೆ?';

  @override
  String get quizRemoveMessage =>
      'ಈ ಪ್ರಶ್ನೆಯನ್ನು ಕರಡಿನಿಂದ ತೆಗೆದುಹಾಕಬೇಕೆ? ಮರುಬಳಕೆಯ ಪ್ರಶ್ನೆ ಬ್ಯಾಂಕ್ ಬದಲಾಗುವುದಿಲ್ಲ.';

  @override
  String get quizRemoveConfirm => 'ಪ್ರಶ್ನೆ ತೆಗೆದುಹಾಕಿ';

  @override
  String get quizRemoveUnconfirmed =>
      'ತೆಗೆದುಹಾಕಿದ್ದು ಖಚಿತವಾಗಲಿಲ್ಲ. ಮತ್ತೆ ಪ್ರಯತ್ನಿಸುವ ಮೊದಲು ರಿಫ್ರೆಶ್ ಆದ ಕರಡನ್ನು ಪರಿಶೀಲಿಸಿ.';

  @override
  String get quizQuestionRemovedSentence =>
      'ಪ್ರಶ್ನೆಯನ್ನು ಕರಡಿನಿಂದ ತೆಗೆದುಹಾಕಲಾಗಿದೆ.';

  @override
  String get quizSettingsUnconfirmed =>
      'ಸೆಟ್ಟಿಂಗ್‌ಗಳು ಉಳಿಸಿದ್ದು ಖಚಿತವಾಗಲಿಲ್ಲ. ಪ್ರಕಟಿಸುವ ಮೊದಲು ರಿಫ್ರೆಶ್ ಮಾಡಿ ಉಳಿಸಿದ ಸೆಟ್ಟಿಂಗ್‌ಗಳನ್ನು ಪರಿಶೀಲಿಸಿ.';

  @override
  String get quizSettingsSaved =>
      'ಕ್ವಿಜ್ ಸೆಟ್ಟಿಂಗ್‌ಗಳನ್ನು ಉಳಿಸಲಾಗಿದೆ. ಪ್ರಕಟಿಸುವ ಮೊದಲು ಅವುಗಳನ್ನು ಪರಿಶೀಲಿಸಿ.';

  @override
  String quizSavedQuestion(String number, String text) {
    return 'ಉಳಿಸಿದ ಪ್ರಶ್ನೆ $number: $text. ಈಗಾಗಲೇ ಈ ಕರಡಿನಲ್ಲಿದೆ. ಅದರ ಆಯ್ಕೆಗಳನ್ನು ಓದಲು ಓಕೆ ಒತ್ತಿ';
  }

  @override
  String quizQuestionNumbered(String number, String text) {
    return 'ಪ್ರಶ್ನೆ $number. $text.';
  }

  @override
  String quizDraftOption(String number, String text) {
    return 'ಆಯ್ಕೆ $number: $text.';
  }

  @override
  String quizDraftOptionCorrect(String number, String text) {
    return 'ಆಯ್ಕೆ $number: $text, ಸರಿಯಾದ ಉತ್ತರ.';
  }

  @override
  String get quizReviewingBeforePublishing =>
      'ಪ್ರಕಟಿಸುವ ಮೊದಲು ಪರಿಶೀಲಿಸಲಾಗುತ್ತಿದೆ.';

  @override
  String get quizAddingQuestions => 'ಪ್ರಶ್ನೆಗಳನ್ನು ಸೇರಿಸಲಾಗುತ್ತಿದೆ.';

  @override
  String get quizRefreshSavedDraft => 'ಉಳಿಸಿದ ಕರಡನ್ನು ರಿಫ್ರೆಶ್ ಮಾಡಿ';

  @override
  String get quizWriteQuestionTarget =>
      'ಒಂದು ಪ್ರಶ್ನೆ ಬರೆದು ಅದನ್ನು ಈ ಕ್ವಿಜ್ ಮತ್ತು ನಿಮ್ಮ ಪ್ರಶ್ನೆ ಬ್ಯಾಂಕ್‌ಗೆ ಉಳಿಸಿ';

  @override
  String get quizReviewBeforePublishingTarget =>
      'ಪ್ರಕಟಿಸುವ ಮೊದಲು ಪ್ರಶ್ನೆಗಳು ಮತ್ತು ಕ್ವಿಜ್ ಸೆಟ್ಟಿಂಗ್‌ಗಳನ್ನು ಪರಿಶೀಲಿಸಿ';

  @override
  String get quizRemoveQuestionTarget =>
      'ಖಚಿತಪಡಿಸುವಿಕೆಯೊಂದಿಗೆ ಈ ಕರಡಿನಿಂದ ಒಂದು ಪ್ರಶ್ನೆ ತೆಗೆದುಹಾಕಿ';

  @override
  String get quizChangeSettingsTarget =>
      'ಶೀರ್ಷಿಕೆ ಅಥವಾ ಐಚ್ಛಿಕ ಕ್ವಿಜ್ ಸೆಟ್ಟಿಂಗ್‌ಗಳನ್ನು ಬದಲಾಯಿಸಿ';

  @override
  String get quizBackToAdding => 'ಪ್ರಶ್ನೆಗಳನ್ನು ಸೇರಿಸುವುದಕ್ಕೆ ಹಿಂತಿರುಗಿ';

  @override
  String get quizPublishWithConfirmation =>
      'ಖಚಿತಪಡಿಸುವಿಕೆಯೊಂದಿಗೆ ಕ್ವಿಜ್ ಪ್ರಕಟಿಸಿ';

  @override
  String get quizSaveForLaterTarget =>
      'ನಂತರಕ್ಕೆ ಉಳಿಸಿ ಹಿಂತಿರುಗಿ. ಖಚಿತವಾದ ಬದಲಾವಣೆಗಳು ಈಗಾಗಲೇ ಕರಡಾಗಿ ಉಳಿಸಲಾಗಿವೆ';

  @override
  String get quizDraftNavigationReview =>
      'ಉಳಿಸಿದ ಪ್ರಶ್ನೆಗಳು, ಕ್ವಿಜ್ ಸೆಟ್ಟಿಂಗ್‌ಗಳು, ಮತ್ತು ಖಚಿತಪಡಿಸುವಿಕೆಯೊಂದಿಗೆ ಪ್ರಕಟಣೆ';

  @override
  String get quizDraftNavigationAdd =>
      'ಪ್ರಶ್ನೆಗಳನ್ನು ಬರೆಯಿರಿ ಅಥವಾ ಉಳಿಸಿದವನ್ನು ಆಯ್ಕೆಮಾಡಿ, ಪ್ರಶ್ನೆಗಳನ್ನು ತೆಗೆದುಹಾಕಿ, ಮತ್ತು ಕರಡನ್ನು ಪರಿಶೀಲಿಸಿ';

  @override
  String get quizPublishedScreen => 'ಕ್ವಿಜ್ ಪ್ರಕಟಿಸಲಾಗಿದೆ';

  @override
  String get quizDraftStep3 =>
      'ಹಂತ 3, 3 ರಲ್ಲಿ. ಪ್ರಕಟಿಸುವ ಮೊದಲು ಪರಿಶೀಲಿಸಿ. ನೀವು ಖಚಿತಪಡಿಸುವವರೆಗೆ ಏನೂ ಪ್ರಕಟವಾಗುವುದಿಲ್ಲ.';

  @override
  String get quizDraftStep2 =>
      'ಹಂತ 2, 3 ರಲ್ಲಿ. ಪ್ರಶ್ನೆಗಳನ್ನು ಸೇರಿಸಿ. ಬರೆಯಿರಿ ಅಥವಾ ಉಳಿಸಿದ ಪ್ರಶ್ನೆ ಬಳಸಿ ಆಯ್ಕೆಮಾಡಿ. ನಂತರ ಪರಿಶೀಲಿಸಿ.';

  @override
  String get quizSaveForLater => 'ನಂತರಕ್ಕೆ ಉಳಿಸಿ ಹಿಂತಿರುಗಿ';

  @override
  String get quizWriteQuestion => 'ಪ್ರಶ್ನೆ ಬರೆಯಿರಿ';

  @override
  String get quizUseSavedQuestion => 'ಉಳಿಸಿದ ಪ್ರಶ್ನೆ ಬಳಸಿ';

  @override
  String get quizRemoveQuestion => 'ಒಂದು ಪ್ರಶ್ನೆ ತೆಗೆದುಹಾಕಿ';

  @override
  String get quizReview => 'ಪರಿಶೀಲಿಸಿ';

  @override
  String get quizPublishConfirmLabel => 'ಖಚಿತಪಡಿಸುವಿಕೆಯೊಂದಿಗೆ ಪ್ರಕಟಿಸಿ';

  @override
  String get quizChangeSettingsLabel =>
      'ಶೀರ್ಷಿಕೆ ಅಥವಾ ಐಚ್ಛಿಕ ಸೆಟ್ಟಿಂಗ್‌ಗಳನ್ನು ಬದಲಾಯಿಸಿ';

  @override
  String quizResultsScreen(String title) {
    return '$title ಫಲಿತಾಂಶಗಳು';
  }

  @override
  String get quizResultsNavigation =>
      'ಕ್ವಿಜ್ ಸಾರಾಂಶ, ವಿದ್ಯಾರ್ಥಿಗಳ ಫಲಿತಾಂಶಗಳು, ಮತ್ತು ಲಭ್ಯವಿರುವ ಫಲಿತಾಂಶ ಕ್ರಿಯೆಗಳು';

  @override
  String get quizResultsFailed => 'ಕ್ವಿಜ್ ಫಲಿತಾಂಶಗಳು ಲೋಡ್ ಆಗಲಿಲ್ಲ.';

  @override
  String quizStudentsCompleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ವಿದ್ಯಾರ್ಥಿಗಳು ಪೂರ್ಣಗೊಳಿಸಿದ್ದಾರೆ.',
      one: '1 ವಿದ್ಯಾರ್ಥಿ ಪೂರ್ಣಗೊಳಿಸಿದ್ದಾರೆ.',
    );
    return '$_temp0';
  }

  @override
  String quizStudentsNotAttemptedYet(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ವಿದ್ಯಾರ್ಥಿಗಳು ಇನ್ನೂ ಪ್ರಯತ್ನಿಸಿಲ್ಲ.',
      one: '1 ವಿದ್ಯಾರ್ಥಿ ಇನ್ನೂ ಪ್ರಯತ್ನಿಸಿಲ್ಲ.',
    );
    return '$_temp0';
  }

  @override
  String quizResultsLoadedRaw(String completed, String notAttempted) {
    return '$completed ವಿದ್ಯಾರ್ಥಿಗಳು ಪೂರ್ಣಗೊಳಿಸಿದ್ದಾರೆ. $notAttempted ವಿದ್ಯಾರ್ಥಿಗಳು ಪ್ರಯತ್ನಿಸಿಲ್ಲ.';
  }

  @override
  String quizStatEligible(String value) {
    return 'ಅರ್ಹರು: $value';
  }

  @override
  String quizStatStarted(String value) {
    return 'ಪ್ರಾರಂಭಿಸಿದವರು: $value';
  }

  @override
  String quizStatCompleted(String value) {
    return 'ಪೂರ್ಣಗೊಳಿಸಿದವರು: $value';
  }

  @override
  String quizStatNotAttempted(String value) {
    return 'ಪ್ರಯತ್ನಿಸದವರು: $value';
  }

  @override
  String quizStatCompletion(String value) {
    return 'ಪೂರ್ಣಗೊಳಿಸುವಿಕೆ: $value';
  }

  @override
  String quizStatCompletionPercent(String value) {
    return 'ಪೂರ್ಣಗೊಳಿಸುವಿಕೆ: $value ಪ್ರತಿಶತ';
  }

  @override
  String get quizPracticeParticipation =>
      'ಅಭ್ಯಾಸದಲ್ಲಿ ಭಾಗವಹಿಸುವಿಕೆ, ಶೈಕ್ಷಣಿಕ ಅಂಕಗಳಲ್ಲ.';

  @override
  String quizStatAverageHighest(String value) {
    return 'ಸರಾಸರಿ ಅತಿ ಹೆಚ್ಚಿನ ಅಂಕ: $value';
  }

  @override
  String quizStatLowest(String value) {
    return 'ಪೂರ್ಣಗೊಂಡವುಗಳಲ್ಲಿ ಅತಿ ಕಡಿಮೆ ಅಂಕ: $value';
  }

  @override
  String quizStudentNotAttempted(String name) {
    return '$name ಈ ಕ್ವಿಜ್ ಪ್ರಯತ್ನಿಸಿಲ್ಲ.';
  }

  @override
  String quizStudentPractice(int count, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$name. $count ಅಭ್ಯಾಸ ಪ್ರಯತ್ನಗಳು. ಶೈಕ್ಷಣಿಕ ಅಂಕಗಳಲ್ಲ.',
      one: '$name. 1 ಅಭ್ಯಾಸ ಪ್ರಯತ್ನ. ಶೈಕ್ಷಣಿಕ ಅಂಕಗಳಲ್ಲ.',
    );
    return '$_temp0';
  }

  @override
  String quizStudentPracticeRaw(String name, String count) {
    return '$name. $count ಅಭ್ಯಾಸ ಪ್ರಯತ್ನಗಳು. ಶೈಕ್ಷಣಿಕ ಅಂಕಗಳಲ್ಲ.';
  }

  @override
  String quizStudentAttemptScore(String number, String score, String status) {
    return 'ಪ್ರಯತ್ನ $number, $score, $status';
  }

  @override
  String quizStudentAttemptRaw(String number, String score, String status) {
    return 'ಪ್ರಯತ್ನ $number, $score ಪ್ರತಿಶತ, $status';
  }

  @override
  String quizStudentScores(String name, String highest, String scores) {
    return '$name. ಅತಿ ಹೆಚ್ಚಿನ ಅಂಕ $highest. $scores.';
  }

  @override
  String quizStudentScoresRaw(String name, String highest, String scores) {
    return '$name. ಅತಿ ಹೆಚ್ಚಿನ ಅಂಕ $highest ಪ್ರತಿಶತ. $scores.';
  }

  @override
  String get quizExtraMismatch =>
      'ಹೆಚ್ಚುವರಿ ಸಮಯದ ಖಚಿತಪಡಿಸುವಿಕೆ ಹೊಂದಿಕೆಯಾಗಲಿಲ್ಲ. ಮತ್ತೆ ಪ್ರಯತ್ನಿಸುವ ಮೊದಲು ರಿಫ್ರೆಶ್ ಮಾಡಿ.';

  @override
  String get quizExtraSaved =>
      'ಹೆಚ್ಚುವರಿ ಸಮಯವನ್ನು ಮುಂದಿನ ಪ್ರಯತ್ನಗಳಿಗೆ ಮಾತ್ರ ಖಚಿತಪಡಿಸಲಾಗಿದೆ. ಈಗಿರುವ ಪ್ರಯತ್ನಗಳ ಗಡುವು ಬದಲಾಗಿಲ್ಲ ಮತ್ತು ಕ್ವಿಜ್ ಮುಚ್ಚುವ ಸಮಯ ಇನ್ನೂ ಅನ್ವಯಿಸುತ್ತದೆ.';

  @override
  String get quizEveryoneAttempted =>
      'ಎಲ್ಲಾ ಅರ್ಹ ವಿದ್ಯಾರ್ಥಿಗಳು ಈ ಕ್ವಿಜ್ ಪ್ರಯತ್ನಿಸಿದ್ದಾರೆ.';

  @override
  String get quizRemindTitle => 'ವಿದ್ಯಾರ್ಥಿಗಳಿಗೆ ನೆನಪಿಸಬೇಕೆ?';

  @override
  String quizRemindMessage(int count, String title) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$title ಪ್ರಯತ್ನಿಸದ ಎಲ್ಲಾ $count ವಿದ್ಯಾರ್ಥಿಗಳಿಗೆ ಒಂದು ಕ್ವಿಜ್ ಜ್ಞಾಪನೆ ಕಳುಹಿಸಬೇಕೆ?',
      one: '$title ಪ್ರಯತ್ನಿಸದ 1 ವಿದ್ಯಾರ್ಥಿಗೆ ಒಂದು ಕ್ವಿಜ್ ಜ್ಞಾಪನೆ ಕಳುಹಿಸಬೇಕೆ?',
    );
    return '$_temp0';
  }

  @override
  String quizRemindMessageRaw(String count, String title) {
    return '$title ಪ್ರಯತ್ನಿಸದ ಎಲ್ಲಾ $count ವಿದ್ಯಾರ್ಥಿಗಳಿಗೆ ಒಂದು ಕ್ವಿಜ್ ಜ್ಞಾಪನೆ ಕಳುಹಿಸಬೇಕೆ?';
  }

  @override
  String get quizRemindConfirm => 'ಜ್ಞಾಪನೆ ಕಳುಹಿಸಿ';

  @override
  String get quizRemindFailed => 'ಕ್ವಿಜ್ ಜ್ಞಾಪನೆಗಳನ್ನು ಕಳುಹಿಸಲು ಆಗಲಿಲ್ಲ.';

  @override
  String quizReminded(String notified, String queued) {
    return '$notified ವಿದ್ಯಾರ್ಥಿಗಳಿಗೆ ಜ್ಞಾಪನೆ ಕಳುಹಿಸಲಾಗಿದೆ. $queued ಸಾಧನ ಅಧಿಸೂಚನೆಗಳು ಸರದಿಯಲ್ಲಿವೆ.';
  }

  @override
  String quizReminderProcessed(String notified, String queued) {
    return '$notified ವಿದ್ಯಾರ್ಥಿಗಳಿಗೆ ಜ್ಞಾಪನೆ ಪ್ರಕ್ರಿಯೆಗೊಳಿಸಲಾಗಿದೆ. $queued ಸಾಧನ ಅಧಿಸೂಚನೆಗಳು ಸರದಿಯಲ್ಲಿವೆ.';
  }

  @override
  String get quizRefreshResults => 'ಕ್ವಿಜ್ ಫಲಿತಾಂಶಗಳನ್ನು ರಿಫ್ರೆಶ್ ಮಾಡಿ';

  @override
  String get quizRefreshResultsLabel => 'ಫಲಿತಾಂಶಗಳನ್ನು ರಿಫ್ರೆಶ್ ಮಾಡಿ';

  @override
  String get quizRemindAllLabel => 'ಪ್ರಯತ್ನಿಸದ ಎಲ್ಲಾ ವಿದ್ಯಾರ್ಥಿಗಳಿಗೆ ನೆನಪಿಸಿ';

  @override
  String get quizRemindUnavailable =>
      'ಎಲ್ಲಾ ವಿದ್ಯಾರ್ಥಿಗಳು ಪ್ರಯತ್ನಿಸಿದ್ದಾರೆ. ಜ್ಞಾಪನೆ ಲಭ್ಯವಿಲ್ಲ';

  @override
  String quizRemindTarget(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ಪ್ರಯತ್ನಿಸದ ಎಲ್ಲಾ $count ವಿದ್ಯಾರ್ಥಿಗಳಿಗೆ ಜ್ಞಾಪನೆ ಕಳುಹಿಸಿ',
      one: 'ಪ್ರಯತ್ನಿಸದ 1 ವಿದ್ಯಾರ್ಥಿಗೆ ಜ್ಞಾಪನೆ ಕಳುಹಿಸಿ',
    );
    return '$_temp0';
  }

  @override
  String quizRemindTargetRaw(String count) {
    return 'ಪ್ರಯತ್ನಿಸದ ಎಲ್ಲಾ $count ವಿದ್ಯಾರ್ಥಿಗಳಿಗೆ ಜ್ಞಾಪನೆ ಕಳುಹಿಸಿ';
  }

  @override
  String quizExtraTarget(String name, String duration) {
    return '$name ಅವರಿಗೆ ಹೆಚ್ಚುವರಿ ಸಮಯ ನಿಗದಿಪಡಿಸಿ. ಮುಂದಿನ ಪ್ರಯತ್ನಗಳಿಗೆ ಮಾತ್ರ. ಈಗಿನ ಹೆಚ್ಚುವರಿ ಸಮಯ $duration';
  }

  @override
  String quizExtraTargetRaw(String name, String minutes) {
    return '$name ಅವರಿಗೆ ಹೆಚ್ಚುವರಿ ನಿಮಿಷಗಳನ್ನು ನಿಗದಿಪಡಿಸಿ. ಮುಂದಿನ ಪ್ರಯತ್ನಗಳಿಗೆ ಮಾತ್ರ. ಈಗಿನ ಹೆಚ್ಚುವರಿ $minutes ನಿಮಿಷಗಳು';
  }

  @override
  String quizExtraButton(String minutes) {
    return 'ಮುಂದಿನ ಹೆಚ್ಚುವರಿ ಸಮಯ: $minutes ನಿಮಿಷಗಳು. ನಿಗದಿಪಡಿಸಿ';
  }

  @override
  String get quizResultsNotLoaded => 'ಫಲಿತಾಂಶಗಳು ಲೋಡ್ ಆಗಿಲ್ಲ.';

  @override
  String quizCompletionSentence(String percent) {
    return 'ಪೂರ್ಣಗೊಳಿಸುವಿಕೆ $percent.';
  }

  @override
  String quizExtraScreen(String name) {
    return '$name ಅವರಿಗೆ ಹೆಚ್ಚುವರಿ ಸಮಯ. ಮುಂದಿನ ಪ್ರಯತ್ನಗಳಿಗೆ ಮಾತ್ರ; ನಡೆಯುತ್ತಿರುವ ಪ್ರಯತ್ನಗಳ ಗಡುವು ಬದಲಾಗುವುದಿಲ್ಲ. ಕ್ವಿಜ್ ಮುಚ್ಚುವ ಸಮಯ ಇನ್ನೂ ಅನ್ವಯಿಸುತ್ತದೆ. ಸೊನ್ನೆ ನಿಮಿಷ ನಮೂದಿಸಿದರೆ ಹೆಚ್ಚುವರಿ ಸಮಯ ತೆಗೆದುಹಾಕಲಾಗುತ್ತದೆ. ರದ್ದುಮಾಡಲು ಫೀಲ್ಡ್‌ನ ಹೊರಗೆ 0 ಒತ್ತಿ.';
  }

  @override
  String quizExtraField(String value) {
    return 'ಹೆಚ್ಚುವರಿ ನಿಮಿಷಗಳು, ಈಗ $value. ಬದಲಾಯಿಸಲು ಓಕೆ ಒತ್ತಿ';
  }

  @override
  String get quizEmpty => 'ಖಾಲಿ';

  @override
  String get quizExtraSave => 'ಮುಂದಿನ ಪ್ರಯತ್ನಗಳಿಗೆ ಹೆಚ್ಚುವರಿ ಸಮಯ ಉಳಿಸಿ';

  @override
  String get quizExtraCancel => 'ಹೆಚ್ಚುವರಿ ಸಮಯ ಬದಲಾಯಿಸದೆ ರದ್ದುಮಾಡಿ';

  @override
  String get quizExtraInvalid =>
      'ಸೊನ್ನೆ ಅಥವಾ ಹೆಚ್ಚಿನ, ಸರ್ವರ್ ಮಿತಿಯೊಳಗಿನ ಪೂರ್ಣ ಸಂಖ್ಯೆಯ ನಿಮಿಷಗಳನ್ನು ನಮೂದಿಸಿ.';

  @override
  String get quizExtraCorrect => 'ಸರಿಪಡಿಸಲು ಹೆಚ್ಚುವರಿ ನಿಮಿಷಗಳಿಗೆ ಮೇಲೆ ಹೋಗಿ.';

  @override
  String get quizEditorInvalid =>
      'ಒಂದು ಪ್ರಶ್ನೆ, ನಾಲ್ಕು ಬೇರೆ ಬೇರೆ ಖಾಲಿಯಿಲ್ಲದ ಆಯ್ಕೆಗಳನ್ನು ನಮೂದಿಸಿ, ನಂತರ ಸರಿಯಾದ ಉತ್ತರ ಆಯ್ಕೆಮಾಡಿ.';

  @override
  String get quizEditorSpokenInvalid =>
      'ತಲಾ 80 ಅಕ್ಷರಗಳ ವರೆಗಿನ, ಗರಿಷ್ಠ 20 ಬೇರೆ ಬೇರೆ ವಿಷಯಗಳನ್ನು ಬಳಸಿ. ವಿವರಿಸಿದ ಸಂಕೇತಕ್ಕೆ ಮಾತಿನ ಪ್ರಶ್ನೆ, ನಾಲ್ಕೂ ಮಾತಿನ ಆಯ್ಕೆಗಳು, ಮತ್ತು ವಿವರಣೆ ನೀಡಿದ್ದರೆ ಮಾತಿನ ವಿವರಣೆ ಬೇಕು. ಉಳಿಸುವ ಮೊದಲು ಪ್ರತಿಯೊಂದು ಮಾತಿನ ಪರ್ಯಾಯವನ್ನು ಪರಿಶೀಲಿಸಿ ಖಚಿತಪಡಿಸಿ.';

  @override
  String quizCorrectChosen(String number, String count) {
    return 'ಸರಿಯಾದ ಉತ್ತರ: ಆಯ್ಕೆ $number, $count ರಲ್ಲಿ $number.';
  }

  @override
  String quizCorrectChosenWithText(String number, String text, String count) {
    return 'ಸರಿಯಾದ ಉತ್ತರ: ಆಯ್ಕೆ $number, $text, $count ರಲ್ಲಿ $number.';
  }

  @override
  String get quizCorrectNotSelected =>
      'ಸರಿಯಾದ ಉತ್ತರ ಆಯ್ಕೆಮಾಡಿಲ್ಲ. ಆಯ್ಕೆಮಾಡಲು ಎಡ ಅಥವಾ ಬಲ ಬಳಸಿ';

  @override
  String quizCorrectTarget(String number, String text) {
    return 'ಸರಿಯಾದ ಉತ್ತರ: ಆಯ್ಕೆ $number, $text. ಬದಲಾಯಿಸಲು ಎಡ ಅಥವಾ ಬಲ ಬಳಸಿ';
  }

  @override
  String quizToggled(String name, String state) {
    return '$name $state.';
  }

  @override
  String get quizContentDescribed => 'ವಿಷಯ: ಶಿಕ್ಷಕರು ವಿವರಿಸಿದ ಸಂಕೇತ ಅಥವಾ ಚಿತ್ರ';

  @override
  String get quizContentPlain => 'ವಿಷಯ: ಇಂಗ್ಲಿಷ್ ಸಾದಾ ಪಠ್ಯ';

  @override
  String get quizReviewedYes =>
      'ಮಾತಿನ ಪರ್ಯಾಯಗಳನ್ನು ಶಿಕ್ಷಕರು ಪರಿಶೀಲಿಸಿದ್ದಾರೆ: ಹೌದು';

  @override
  String get quizReviewedNo =>
      'ಮಾತಿನ ಪರ್ಯಾಯಗಳನ್ನು ಶಿಕ್ಷಕರು ಪರಿಶೀಲಿಸಿದ್ದಾರೆ: ಇಲ್ಲ';

  @override
  String get quizSettingsInvalid =>
      'ಶೀರ್ಷಿಕೆ, 1 ರಿಂದ 20 ರವರೆಗಿನ ಪ್ರಯತ್ನ ಮಿತಿ, ಸಮಯ ಮಿತಿ, ಮತ್ತು ವೇಳಾಪಟ್ಟಿ ಪರಿಶೀಲಿಸಿ. ಮುಚ್ಚುವ ಸಮಯ ತೆರೆಯುವ ಸಮಯದ ನಂತರ ಇರಬೇಕು.';

  @override
  String get quizSetOpening =>
      'ದಿನಾಂಕ ಮತ್ತು ಸಮಯದ ಸಂಖ್ಯೆ ಫೀಲ್ಡ್‌ಗಳನ್ನು ಬಳಸಿ ತೆರೆಯುವ ಸಮಯ ನಿಗದಿಪಡಿಸಿ.';

  @override
  String get quizSetClosing =>
      'ದಿನಾಂಕ ಮತ್ತು ಸಮಯದ ಸಂಖ್ಯೆ ಫೀಲ್ಡ್‌ಗಳನ್ನು ಬಳಸಿ ಮುಚ್ಚುವ ಸಮಯ ನಿಗದಿಪಡಿಸಿ.';

  @override
  String quizOpeningSet(String when) {
    return 'ತೆರೆಯುವ ಸಮಯವನ್ನು $when ಗೆ ನಿಗದಿಪಡಿಸಲಾಗಿದೆ.';
  }

  @override
  String quizClosingSet(String when) {
    return 'ಮುಚ್ಚುವ ಸಮಯವನ್ನು $when ಗೆ ನಿಗದಿಪಡಿಸಲಾಗಿದೆ.';
  }

  @override
  String quizReleaseSet(String when) {
    return 'ಪ್ರತಿಕ್ರಿಯೆ ಬಿಡುಗಡೆಯನ್ನು $when ಗೆ ನಿಗದಿಪಡಿಸಲಾಗಿದೆ.';
  }

  @override
  String get quizOpeningCleared => 'ತೆರೆಯುವ ಸಮಯ ತೆಗೆದುಹಾಕಲಾಗಿದೆ.';

  @override
  String get quizClosingCleared => 'ಮುಚ್ಚುವ ಸಮಯ ತೆಗೆದುಹಾಕಲಾಗಿದೆ.';

  @override
  String get quizNoOpeningTime => 'ತೆರೆಯುವ ಸಮಯ ನಿಗದಿಪಡಿಸಿಲ್ಲ';

  @override
  String get quizNoClosingTime => 'ಮುಚ್ಚುವ ಸಮಯ ನಿಗದಿಪಡಿಸಿಲ್ಲ';

  @override
  String quizOpensAt(String when) {
    return '$when ತೆರೆಯುತ್ತದೆ';
  }

  @override
  String quizClosesAt(String when) {
    return '$when ಮುಚ್ಚುತ್ತದೆ';
  }

  @override
  String quizPolicyChoice(String name, String position, String count) {
    return 'ಪ್ರತಿಕ್ರಿಯೆ: $name, $count ರಲ್ಲಿ $position.';
  }

  @override
  String quizScheduledRelease(String when) {
    return 'ನಿಗದಿತ ಪ್ರತಿಕ್ರಿಯೆ ಬಿಡುಗಡೆ $when';
  }

  @override
  String quizAttemptLimitField(String value) {
    return 'ಪ್ರಯತ್ನ ಮಿತಿ, ಈಗ $value. ಬದಲಾಯಿಸಲು ಓಕೆ ಒತ್ತಿ';
  }

  @override
  String quizTimeLimitField(String value) {
    return 'ನಿಮಿಷಗಳಲ್ಲಿ ಐಚ್ಛಿಕ ಸಮಯ ಮಿತಿ, $value. ಬದಲಾಯಿಸಲು ಓಕೆ ಒತ್ತಿ';
  }

  @override
  String get quizRevisionsScreen =>
      'ಖಾಸಗಿ, ಓದಲು ಮಾತ್ರ ಇರುವ ಪ್ರಶ್ನೆ ಪರಿಷ್ಕರಣೆ ಇತಿಹಾಸ. ಹಳೆಯ ಮತ್ತು ಹೊಸ ಪರಿಷ್ಕರಣೆ ನಿಯಂತ್ರಣಗಳನ್ನು ಬಳಸಿ, ನಂತರ ಪ್ರತಿ ವಿಭಾಗವನ್ನು ಓದಿ.';

  @override
  String get quizRevisionsAccount =>
      'ನಿಮ್ಮ ಖಾತೆ ಬದಲಾಗಿದೆ. ಖಾಸಗಿ ಪ್ರಶ್ನೆ ಇತಿಹಾಸ ನೋಡುವ ಮೊದಲು ಹಿಂತಿರುಗಿ ಮತ್ತೆ ಸೈನ್ ಇನ್ ಮಾಡಿ.';

  @override
  String get quizRevisionsCleared =>
      'ನಿಮ್ಮ ಖಾತೆ ಬದಲಾಗಿದೆ. ಖಾಸಗಿ ಪ್ರಶ್ನೆ ಇತಿಹಾಸವನ್ನು ತೆರವುಗೊಳಿಸಲಾಗಿದೆ.';

  @override
  String get quizRevisionsUnverified =>
      'ಪ್ರಶ್ನೆ ಪರಿಷ್ಕರಣೆ ಇತಿಹಾಸವನ್ನು ಪರಿಶೀಲಿಸಲು ಆಗಲಿಲ್ಲ. ಮತ್ತೆ ಲೋಡ್ ಮಾಡಿ.';

  @override
  String get quizRevisionsContentUnverified =>
      'ಪ್ರಶ್ನೆ ಪರಿಷ್ಕರಣೆಯ ವಿಷಯವನ್ನು ಪರಿಶೀಲಿಸಲು ಆಗಲಿಲ್ಲ. ಮತ್ತೆ ಲೋಡ್ ಮಾಡಿ.';

  @override
  String get quizRevisionsTimedOut =>
      'ಪ್ರಶ್ನೆ ಇತಿಹಾಸಕ್ಕೆ ತುಂಬಾ ಸಮಯ ಹಿಡಿಯಿತು. ನಿಮ್ಮ ಸಂಪರ್ಕ ಪರಿಶೀಲಿಸಿ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get quizNoRevisions =>
      'ದಾಖಲಾದ ಪರಿಷ್ಕರಣೆಗಳಿಲ್ಲ. ಹಳೆಯ ಪ್ರಶ್ನೆ ಇತಿಹಾಸ ತಿಳಿದಿಲ್ಲ, ಅದನ್ನು ಮರುರಚಿಸಲಾಗಿಲ್ಲ.';

  @override
  String quizRevisionsLoaded(int count, String revision, String when) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count ಪರಿಷ್ಕರಣೆಗಳು ಲೋಡ್ ಆಗಿವೆ. ಓದಲು ಮಾತ್ರ ಇರುವ ಪ್ರಶ್ನೆ ಪರಿಷ್ಕರಣೆ $revision, $when ಉಳಿಸಲಾಗಿದೆ. ಈಗಿರುವ ಕ್ವಿಜ್ ಮತ್ತು ಪ್ರಯತ್ನದ ಪ್ರತಿಗಳು ಬದಲಾಗುವುದಿಲ್ಲ.',
      one:
          '1 ಪರಿಷ್ಕರಣೆ ಲೋಡ್ ಆಗಿದೆ. ಓದಲು ಮಾತ್ರ ಇರುವ ಪ್ರಶ್ನೆ ಪರಿಷ್ಕರಣೆ $revision, $when ಉಳಿಸಲಾಗಿದೆ. ಈಗಿರುವ ಕ್ವಿಜ್ ಮತ್ತು ಪ್ರಯತ್ನದ ಪ್ರತಿಗಳು ಬದಲಾಗುವುದಿಲ್ಲ.',
    );
    return '$_temp0';
  }

  @override
  String get quizDateUnknown => 'ದಿನಾಂಕ ತಿಳಿದಿಲ್ಲ';

  @override
  String quizRevisionSelected(String revision) {
    return 'ಪರಿಷ್ಕರಣೆ $revision ಆಯ್ಕೆಮಾಡಲಾಗಿದೆ. ಓದಲು ಮಾತ್ರ.';
  }

  @override
  String quizRevisionSelectedOf(
    String revision,
    String position,
    String count,
  ) {
    return 'ಪರಿಷ್ಕರಣೆ $revision ಆಯ್ಕೆಮಾಡಲಾಗಿದೆ, $count ರಲ್ಲಿ $position. ಓದಲು ಮಾತ್ರ.';
  }

  @override
  String quizRevisionFailed(String message) {
    return '$message ಗಮನ ಪರಿಷ್ಕರಣೆಗಳನ್ನು ರಿಫ್ರೆಶ್ ಮಾಡಿ ಮೇಲಿದೆ.';
  }

  @override
  String get quizNoRevisionLoaded => 'ಯಾವುದೇ ಪರಿಷ್ಕರಣೆ ಲೋಡ್ ಆಗಿಲ್ಲ.';

  @override
  String quizShowingRevision(String revision) {
    return 'ಪರಿಷ್ಕರಣೆ $revision ತೋರಿಸಲಾಗುತ್ತಿದೆ. ಓದಲು ಮಾತ್ರ.';
  }

  @override
  String quizRevisionVersion(String revision, String when) {
    return 'ಪರಿಷ್ಕರಣೆ $revision. $when ಉಳಿಸಲಾಗಿದೆ. ಓದಲು ಮಾತ್ರ.';
  }

  @override
  String quizRevisionQuestion(String text) {
    return 'ಪ್ರಶ್ನೆ: $text';
  }

  @override
  String quizRevisionTopics(String topics) {
    return 'ವಿಷಯಗಳು: $topics';
  }

  @override
  String quizRevisionOption(String number, String text) {
    return 'ಆಯ್ಕೆ $number: $text.';
  }

  @override
  String get quizCorrectAnswerSentence => 'ಸರಿಯಾದ ಉತ್ತರ.';

  @override
  String quizRevisionExplanation(String text) {
    return 'ವಿವರಣೆ: $text';
  }

  @override
  String get quizNotProvided => 'ನೀಡಿಲ್ಲ';

  @override
  String get quizRevisionNotice =>
      'ದಾಖಲಿಸುವಿಕೆ ಆರಂಭವಾದ ನಂತರ ಉಳಿಸಿದ ಪರಿಷ್ಕರಣೆಗಳು ಮಾತ್ರ ಲಭ್ಯವಿವೆ. ಹಳೆಯ ಇತಿಹಾಸ ತಿಳಿದಿಲ್ಲ. ಈಗಿರುವ ಕ್ವಿಜ್ ಮತ್ತು ಪ್ರಯತ್ನದ ಪ್ರತಿಗಳನ್ನು ಎಂದಿಗೂ ಮತ್ತೆ ಬರೆಯಲಾಗುವುದಿಲ್ಲ.';

  @override
  String quizRevisionVersionTitle(String revision, String when) {
    return 'ಪರಿಷ್ಕರಣೆ $revision, $when';
  }

  @override
  String get quizQuestionTextTitle => 'ಪ್ರಶ್ನೆಯ ಪಠ್ಯ';

  @override
  String get quizTopicsTitle => 'ವಿಷಯಗಳು';

  @override
  String quizOptionNumber(String number) {
    return 'ಆಯ್ಕೆ $number';
  }

  @override
  String quizOptionNumberCorrect(String number) {
    return 'ಆಯ್ಕೆ $number, ಸರಿಯಾದ ಉತ್ತರ';
  }

  @override
  String get quizExplanationTitle => 'ವಿವರಣೆ';

  @override
  String get quizRevisionNoticeTitle => 'ಪರಿಷ್ಕರಣೆ ಇತಿಹಾಸದ ಬಗ್ಗೆ';

  @override
  String quizRevisionSectionTarget(String title) {
    return '$title. ಕೇಳಲು ಓಕೆ ಒತ್ತಿ';
  }

  @override
  String get quizAccountChangedSignIn =>
      'ಖಾತೆ ಬದಲಾಗಿದೆ. ಹಿಂತಿರುಗಿ ಮತ್ತೆ ಸೈನ್ ಇನ್ ಮಾಡಿ.';

  @override
  String get quizGoBack => 'ಹಿಂದಕ್ಕೆ ಹೋಗಿ';

  @override
  String get quizCancel => 'ರದ್ದುಮಾಡಿ';

  @override
  String get quizCancelAndReturn => 'ರದ್ದುಮಾಡಿ ಹಿಂತಿರುಗಿ';

  @override
  String get quizActionNavigation => 'ಲಭ್ಯವಿರುವ ಕ್ರಿಯೆಗಳು ಮತ್ತು ರದ್ದುಮಾಡಿ';

  @override
  String get quizRefreshRevisions => 'ಪರಿಷ್ಕರಣೆಗಳನ್ನು ರಿಫ್ರೆಶ್ ಮಾಡಿ';

  @override
  String get quizNewerRevision => 'ಹೊಸ ಪರಿಷ್ಕರಣೆ';

  @override
  String get quizOlderRevision => 'ಹಳೆಯ ಪರಿಷ್ಕರಣೆ';

  @override
  String get quizBankArchived => 'ಬ್ಯಾಂಕ್ ಪ್ರಶ್ನೆ ಆರ್ಕೈವ್ ಮಾಡಲಾಗಿದೆ';

  @override
  String get quizBankCopied => 'ಬ್ಯಾಂಕ್ ಪ್ರಶ್ನೆಯ ಪ್ರತಿ ರಚಿಸಲಾಗಿದೆ';

  @override
  String get quizSnapshotAdded => 'ಪ್ರಶ್ನೆಯ ಪ್ರತಿಯನ್ನು ಕ್ವಿಜ್‌ಗೆ ಸೇರಿಸಲಾಗಿದೆ';

  @override
  String get quizQuizClosed => 'ಕ್ವಿಜ್ ಮುಚ್ಚಲಾಗಿದೆ';

  @override
  String get quizDraftCreated => 'ಬದಲಾಯಿಸಬಹುದಾದ ಕ್ವಿಜ್ ಕರಡು ರಚಿಸಲಾಗಿದೆ';

  @override
  String get quizNoAnswerSelected => 'ಯಾವುದೇ ಉತ್ತರ ಆಯ್ಕೆಮಾಡಿಲ್ಲ.';

  @override
  String get quizSelectBeforeSubmit => 'ಸಲ್ಲಿಸುವ ಮೊದಲು ಒಂದು ಆಯ್ಕೆಯನ್ನು ಆರಿಸಿ.';

  @override
  String get quizSubmitBeforeContinuing =>
      'ಮುಂದುವರಿಯುವ ಮೊದಲು ನಿಮ್ಮ ಉತ್ತರ ಸಲ್ಲಿಸಿ.';

  @override
  String get quizTeacherNavigationPrivate =>
      'ಖಾಸಗಿ ಬ್ಯಾಂಕ್ ಹುಡುಕಾಟ ಮತ್ತು ಉಳಿಸಿದ ಪ್ರಶ್ನೆಗಳು, ಕ್ವಿಜ್ ಕರಡುಗಳು, ಪ್ರಕಟಿತ ಕ್ವಿಜ್‌ಗಳು, ಮತ್ತು ಅವುಗಳ ಫಲಿತಾಂಶಗಳು';

  @override
  String get quizStudentNavigationHelp =>
      'ರಿಫ್ರೆಶ್, ಕ್ವಿಜ್ ಸ್ಥಿತಿ ಫಿಲ್ಟರ್, ವಿಷಯ ಫಿಲ್ಟರ್, ಲಭ್ಯವಿರುವ ಪ್ರತಿ ಕ್ವಿಜ್ ಅಥವಾ ಅಭ್ಯಾಸ ಚಟುವಟಿಕೆ ಮತ್ತು ಅದರ ಪ್ರಯತ್ನಗಳ ಇತಿಹಾಸವನ್ನು ತಲುಪಲು D-pad ಮೇಲೆ ಮತ್ತು ಕೆಳಗೆ ಬಳಸಿ. ಫಿಲ್ಟರ್ ಬದಲಾಯಿಸಲು ಅದರ ಮೇಲೆ ಎಡ ಅಥವಾ ಬಲ ಬಳಸಿ. ಕ್ವಿಜ್‌ನ ವಿವರ ಕೇಳಲು ಮತ್ತು ಪ್ರಾರಂಭಿಸುವುದನ್ನು ಅಥವಾ ಮುಂದುವರಿಸುವುದನ್ನು ಖಚಿತಪಡಿಸಲು ಅದರ ಮೇಲೆ ಓಕೆ ಒತ್ತಿ; ಹಿಂದಿನ ಪ್ರಯತ್ನಗಳನ್ನು ನೋಡಲು ಪ್ರಯತ್ನಗಳ ಇತಿಹಾಸದ ಮೇಲೆ ಓಕೆ ಒತ್ತಿ. ಫೋಕಸ್ ಚಲಿಸಿದರೆ ಯಾವುದೇ ಪ್ರಯತ್ನ ಪ್ರಾರಂಭವಾಗುವುದಿಲ್ಲ.';

  @override
  String get quizNoQuizzesAvailable => 'ಯಾವುದೇ ಕ್ವಿಜ್ ಲಭ್ಯವಿಲ್ಲ.';

  @override
  String quizQuizzesAvailableRaw(String count) {
    return '$count ಕ್ವಿಜ್‌ಗಳು ಲಭ್ಯವಿವೆ.';
  }

  @override
  String get quizStudentNavigationSections =>
      'ರಿಫ್ರೆಶ್, ಕ್ವಿಜ್ ಸ್ಥಿತಿ ಮತ್ತು ವಿಷಯ ಫಿಲ್ಟರ್‌ಗಳು, ಲಭ್ಯವಿರುವ ಕ್ವಿಜ್‌ಗಳು ಮತ್ತು ಅಭ್ಯಾಸ ಚಟುವಟಿಕೆಗಳು, ಮತ್ತು ಹಿಂದಿನ ಪ್ರಯತ್ನಗಳು';

  @override
  String quizAttemptLimitReached(String title) {
    return '$title ಗೆ ಪ್ರಯತ್ನಗಳ ಮಿತಿ ಮುಗಿದಿದೆ. ನಿಮ್ಮ ಅಂಕಗಳನ್ನು ನೋಡಲು ಪ್ರಯತ್ನಗಳ ಇತಿಹಾಸ ತೆರೆಯಿರಿ.';
  }

  @override
  String get quizNoPerAttemptLimit => 'ಪ್ರತಿ ಪ್ರಯತ್ನಕ್ಕೆ ಸಮಯ ಮಿತಿ ಇಲ್ಲ.';

  @override
  String quizTimeLimitRaw(String minutes) {
    return 'ಸಮಯ ಮಿತಿ $minutes ನಿಮಿಷಗಳು.';
  }

  @override
  String get quizCannotGoBack =>
      'ಅದನ್ನು ಬದಲಾಯಿಸಲು ನೀವು ಹಿಂದೆ ಹೋಗಲು ಸಾಧ್ಯವಿಲ್ಲ.';

  @override
  String get quizStartFailedAvailability =>
      'ಕ್ವಿಜ್ ಪ್ರಾರಂಭಿಸಲು ಆಗಲಿಲ್ಲ. ಅದು ಲಭ್ಯವಿದೆಯೇ ಎಂದು ಪರಿಶೀಲಿಸಿ.';

  @override
  String get quizStateFieldName => 'ಕ್ವಿಜ್ ಸ್ಥಿತಿ';

  @override
  String get quizSubjectFieldName => 'ವಿಷಯ';

  @override
  String quizUseLeftRightToChange(String item) {
    return '$item. ಬದಲಾಯಿಸಲು ಎಡ ಅಥವಾ ಬಲ ಬಳಸಿ';
  }

  @override
  String get quizAttemptCompletePrivate =>
      'ಪ್ರಯತ್ನ ಪೂರ್ಣಗೊಂಡಿದೆ. ನಿಮ್ಮ ಫಲಿತಾಂಶ ಖಾಸಗಿಯಾಗಿಯೇ ಇರುತ್ತದೆ.';

  @override
  String get quizHelpCompleted =>
      'ಕ್ವಿಜ್‌ಗಳಿಗೆ ಹಿಂತಿರುಗಿ ಮತ್ತು ಫಲಿತಾಂಶವನ್ನು ಖಾಸಗಿಯಾಗಿ ಓದಿ ಇವುಗಳ ನಡುವೆ ಚಲಿಸಲು D-pad ಮೇಲೆ ಮತ್ತು ಕೆಳಗೆ ಬಳಸಿ. ಬಟನ್ ಸಕ್ರಿಯಗೊಳಿಸಲು ಓಕೆ ಒತ್ತಿ. ನಿಮ್ಮ ಫಲಿತಾಂಶವನ್ನು ಖಾಸಗಿಯಾಗಿ ಓದಲು 8 ಒತ್ತಿ ಅಥವಾ ಹಿಂತಿರುಗಲು 0 ಒತ್ತಿ.';

  @override
  String get quizHelpRetry =>
      'ಮುಗಿಸುವುದನ್ನು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಲು 5, ನೀವು ಎಲ್ಲಿದ್ದೀರಿ ಎಂದು ಕೇಳಲು 8, ಅಥವಾ ಖಚಿತಪಡಿಸಿ ಹೊರಹೋಗಲು 0 ಒತ್ತಿ. ಇತರ ನಿಯಂತ್ರಣಗಳಿಗೆ D-pad ಮೇಲೆ ಮತ್ತು ಕೆಳಗೆ ಬಳಸಿ.';

  @override
  String get quizHelpNext =>
      'ಮುಂದಿನ ಪ್ರಶ್ನೆ ತಾನಾಗಿಯೇ ಬರುತ್ತದೆ. ಮತ್ತೆ ಕೇಳಲು 6, ನೀವು ಎಲ್ಲಿದ್ದೀರಿ ಎಂದು ಕೇಳಲು 8 ಒತ್ತಿ.';

  @override
  String quizHelpChoose(String count) {
    return 'ಆಯ್ಕೆ ಮಾಡಲು 1 ರಿಂದ $count ಒತ್ತಿ, ನಂತರ ಸಲ್ಲಿಸಲು 5 ಒತ್ತಿ. ಪ್ರಶ್ನೆ ಮತ್ತು ಆಯ್ಕೆಗಳನ್ನು ಮತ್ತೆ ಕೇಳಲು 6, ನೀವು ಎಲ್ಲಿದ್ದೀರಿ ಮತ್ತು ಉಳಿದ ಸಮಯ ಕೇಳಲು 8 ಒತ್ತಿ.';
  }

  @override
  String get quizHelpFinishLeave =>
      'ಈಗ ಕ್ವಿಜ್ ಮುಗಿಸಿ ಎಂಬುದು D-pad ಪಟ್ಟಿಯಲ್ಲಿದೆ ಮತ್ತು ಅದು ಖಚಿತಪಡಿಸಲು ಕೇಳುತ್ತದೆ. ಸಲ್ಲಿಸದೆ ಹೊರಹೋಗಲು 0 ಒತ್ತಿ.';

  @override
  String quizSelectedOptionNotSubmitted(String number, String text) {
    return 'ಆಯ್ಕೆ $number ಆರಿಸಲಾಗಿದೆ. $text. ಇನ್ನೂ ಸಲ್ಲಿಸಿಲ್ಲ.';
  }

  @override
  String quizSelectedOptionConfirmed(String number, String text) {
    return 'ಆಯ್ಕೆ $number ಆರಿಸಲಾಗಿದೆ. $text. ಉತ್ತರ ಖಚಿತವಾಗಿದೆ.';
  }

  @override
  String quizFeedbackCorrect(String answer, String explanation) {
    return 'ಸರಿ. ಸರಿಯಾದ ಉತ್ತರ: $answer. $explanation';
  }

  @override
  String quizFeedbackIncorrect(String answer, String explanation) {
    return 'ತಪ್ಪು. ಸರಿಯಾದ ಉತ್ತರ: $answer. $explanation';
  }

  @override
  String quizOptionSelectedNotSubmitted(String number, String text) {
    return 'ಆಯ್ಕೆ $number. $text. ಆರಿಸಲಾಗಿದೆ, ಸಲ್ಲಿಸಿಲ್ಲ. ನಿಮ್ಮ ಉತ್ತರ ಉಳಿಸಲು 5 ಒತ್ತಿ.';
  }

  @override
  String get quizAttemptFinishedWhere =>
      'ಪ್ರಯತ್ನ ಮುಗಿದಿದೆ. ನಿಮ್ಮ ಫಲಿತಾಂಶವನ್ನು ಖಾಸಗಿಯಾಗಿ ಕೇಳಲು 8 ಒತ್ತಿ.';

  @override
  String get quizNoOptionChosenYet => 'ಇನ್ನೂ ಯಾವುದೇ ಆಯ್ಕೆ ಆರಿಸಿಲ್ಲ.';

  @override
  String quizOptionChosen(String number) {
    return 'ಆಯ್ಕೆ $number ಆರಿಸಲಾಗಿದೆ.';
  }

  @override
  String quizCompletionFailedRetry(String reason) {
    return '$reason ನೀವು ಉಳಿಸಿದ ಉತ್ತರಗಳು ಸುರಕ್ಷಿತವಾಗಿವೆ. ಫಲಿತಾಂಶ ಪರಿಶೀಲಿಸಲು ಪೂರ್ಣಗೊಳಿಸುವಿಕೆ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ ಆರಿಸಿ.';
  }

  @override
  String quizAttemptStatusPrivate(String status) {
    return 'ಪ್ರಯತ್ನ $status. ನಿಮ್ಮ ಫಲಿತಾಂಶ ಖಾಸಗಿಯಾಗಿದೆ.';
  }

  @override
  String get quizEarlyCountUnconfirmed =>
      'ಈಗ ಉಳಿಸಿರುವ ಉತ್ತರಗಳ ಸಂಖ್ಯೆಯನ್ನು ಖಚಿತಪಡಿಸಲು ಆಗಲಿಲ್ಲ, ಅಥವಾ ಈ ಪ್ರಯತ್ನ ಮುಗಿದಿದೆ. ಬೇಗನೆ ಸಲ್ಲಿಕೆ ಕಳುಹಿಸಲಾಗಿಲ್ಲ. ಅದರ ಸ್ಥಿತಿ ರಿಫ್ರೆಶ್ ಮಾಡಲು ಕ್ವಿಜ್ ಪಟ್ಟಿಗೆ ಹಿಂತಿರುಗಿ.';

  @override
  String get quizEarlyTitle => 'ಈ ಪ್ರಯತ್ನವನ್ನು ಬೇಗನೆ ಸಲ್ಲಿಸಬೇಕೇ?';

  @override
  String quizEarlyMessage(String count) {
    return 'ಸರ್ವರ್ ಪರಿಶೀಲನೆ ಪ್ರಕಾರ $count ಪ್ರಶ್ನೆಗಳಿಗೆ ಉತ್ತರಿಸಿಲ್ಲ. ಅಂತಿಮಗೊಳಿಸುವಾಗ ಸರ್ವರ್‌ನಲ್ಲಿ ಉಳಿಸಿರುವ ಉತ್ತರಗಳು ಮಾತ್ರ ಸೇರುತ್ತವೆ. ಆರಿಸಿದ ಆದರೆ ಉಳಿಸದ ಉತ್ತರ ಸೇರುವುದಿಲ್ಲ. ಅಂತಿಮ ಸಲ್ಲಿಕೆಯನ್ನು ರದ್ದುಮಾಡಲು ಅಥವಾ ಬದಲಾಯಿಸಲು ಆಗುವುದಿಲ್ಲ. ಹಿಂದೆ ಹೋದರೆ ಎಂದಿಗೂ ಸಲ್ಲಿಕೆ ಆಗುವುದಿಲ್ಲ.';
  }

  @override
  String get quizEarlyConfirm => 'ಉಳಿಸಿದ ಉತ್ತರಗಳನ್ನು ಅಂತಿಮಗೊಳಿಸಿ';

  @override
  String get quizEarlyTimedOut =>
      'ಉಳಿಸಿದ ಉತ್ತರಗಳ ಪರಿಶೀಲನೆಗೆ ಸಮಯ ಮೀರಿತು. ಬೇಗನೆ ಸಲ್ಲಿಕೆ ಕಳುಹಿಸಲಾಗಿಲ್ಲ. ನಿಮ್ಮ ಸಂಪರ್ಕ ಪರಿಶೀಲಿಸಿ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get quizWaitPending =>
      'ಹೊರಹೋಗುವ ಮೊದಲು ಬಾಕಿ ಇರುವ ಉತ್ತರ ಅಥವಾ ಪೂರ್ಣಗೊಳಿಸುವಿಕೆಯ ಖಚಿತತೆಗಾಗಿ ಕಾಯಿರಿ.';

  @override
  String get quizLeaveMessageServer =>
      'ಇದರಿಂದ ನಿಮ್ಮ ಪ್ರಯತ್ನ ಸಲ್ಲಿಕೆಯಾಗುವುದಿಲ್ಲ. ಸರ್ವರ್ ಖಚಿತಪಡಿಸಿದ ಉತ್ತರಗಳು ಮಾತ್ರ ಉಳಿಯುತ್ತವೆ; ಉಳಿಸದ ಆಯ್ಕೆ ಕಳೆದುಹೋಗಬಹುದು. ಯಾವುದೇ ಟೈಮರ್ ಓಡುತ್ತಲೇ ಇರುತ್ತದೆ. ಸರ್ವರ್ ಈ ಪ್ರಯತ್ನಕ್ಕೆ ಅನುಮತಿಸುವವರೆಗೆ ಮಾತ್ರ ಮುಂದುವರಿಸಬಹುದು.';

  @override
  String get quizStayInAttempt => 'ಪ್ರಯತ್ನದಲ್ಲೇ ಇರಿ';

  @override
  String get quizNextQuestionNow => 'ಈಗ ಮುಂದಿನ ಪ್ರಶ್ನೆ';

  @override
  String get quizReadAllOptions => 'ಎಲ್ಲಾ ಉತ್ತರ ಆಯ್ಕೆಗಳನ್ನು ಓದಿ';

  @override
  String quizOptionTargetSelectedSubmit(String number, String text) {
    return 'ಆಯ್ಕೆ $number, $text, ಆರಿಸಲಾಗಿದೆ. ಆರಿಸಲು ಓಕೆ ಅಥವಾ $number ಒತ್ತಿ. ಸಿದ್ಧರಾದಾಗ ಮಾತ್ರ ಸಲ್ಲಿಸಲು 5 ಒತ್ತಿ';
  }

  @override
  String quizOptionTargetNotSelectedSubmit(String number, String text) {
    return 'ಆಯ್ಕೆ $number, $text, ಆರಿಸಿಲ್ಲ. ಆರಿಸಲು ಓಕೆ ಅಥವಾ $number ಒತ್ತಿ. ಸಿದ್ಧರಾದಾಗ ಮಾತ್ರ ಸಲ್ಲಿಸಲು 5 ಒತ್ತಿ';
  }

  @override
  String get quizReadSelectionTarget =>
      'ಆರಿಸಿದ ಉತ್ತರ ಮತ್ತು ಉಳಿಸಿದ ಸ್ಥಿತಿಯನ್ನು ಓದಿ';

  @override
  String get quizStopSpeech => 'ಮಾತು ನಿಲ್ಲಿಸಿ';

  @override
  String get quizAnswerFeedback => 'ಉತ್ತರದ ಪ್ರತಿಕ್ರಿಯೆ';

  @override
  String get quizAnswerConfirmedReadFeedback =>
      'ಉತ್ತರ ಉಳಿಸಲಾಗಿದೆ ಮತ್ತು ಲಾಕ್ ಆಗಿದೆ ಎಂದು ಖಚಿತವಾಗಿದೆ. ಪ್ರತಿಕ್ರಿಯೆಯನ್ನು ಖಾಸಗಿಯಾಗಿ ಓದಲು ಓಕೆ ಒತ್ತಿ.';

  @override
  String get quizRetryCompletion => 'ಪೂರ್ಣಗೊಳಿಸುವಿಕೆ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ';

  @override
  String get quizViewResult => 'ಫಲಿತಾಂಶ ನೋಡಿ';

  @override
  String get quizNextQuestion => 'ಮುಂದಿನ ಪ್ರಶ್ನೆ';

  @override
  String get quizAttemptInProgressResume =>
      'ಪ್ರಯತ್ನ ನಡೆಯುತ್ತಿದೆ. ಅದನ್ನು ಮುಂದುವರಿಸಲು ಕ್ವಿಜ್ ಪಟ್ಟಿಗೆ ಹಿಂತಿರುಗಿ. ಹೊರಹೋದರೆ ಸಲ್ಲಿಕೆ ಆಗುವುದಿಲ್ಲ.';

  @override
  String get quizReviewTimedOutShort =>
      'ಪ್ರಯತ್ನದ ಪರಿಶೀಲನೆಗೆ ಸಮಯ ಮೀರಿತು. ನಿಮ್ಮ ಸಂಪರ್ಕ ಪರಿಶೀಲಿಸಿ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get quizNoScoreCurrentlyReleased =>
      'ಪೂರ್ಣಗೊಂಡ ಪ್ರಯತ್ನಗಳಿವೆ; ಸದ್ಯಕ್ಕೆ ಯಾವುದೇ ಅಂಕ ಬಿಡುಗಡೆಯಾಗಿಲ್ಲ.';

  @override
  String get quizHistoryScreenNavigate =>
      'ಪ್ರಯತ್ನಗಳ ಇತಿಹಾಸ. ಅಂಕಗಳು ಖಾಸಗಿಯಾಗಿವೆ. ಸಾರಾಂಶಕ್ಕೆ ಅಥವಾ ನೋಡಬೇಕಾದ ಪ್ರಯತ್ನಕ್ಕೆ ಹೋಗಿ.';

  @override
  String quizHistoryAttemptRaw(String number, String status, String result) {
    return 'ಪ್ರಯತ್ನ $number. $status. $result. ನೋಡಲು ಓಕೆ ಒತ್ತಿ.';
  }

  @override
  String quizReviewAnswerCorrect(
    String number,
    String question,
    String selected,
    String answer,
    String explanation,
  ) {
    return 'ಪ್ರಶ್ನೆ $number. ಸರಿ. $question. ಆರಿಸಿದ್ದು $selected. ಸರಿಯಾದ ಉತ್ತರ $answer. $explanation';
  }

  @override
  String quizReviewAnswerIncorrect(
    String number,
    String question,
    String selected,
    String answer,
    String explanation,
  ) {
    return 'ಪ್ರಶ್ನೆ $number. ತಪ್ಪು. $question. ಆರಿಸಿದ್ದು $selected. ಸರಿಯಾದ ಉತ್ತರ $answer. $explanation';
  }

  @override
  String get quizNoAnswerCapital => 'ಉತ್ತರವಿಲ್ಲ';

  @override
  String quizReviewScreenRaw(String count) {
    return 'ಪ್ರಯತ್ನದ ಪರಿಶೀಲನೆ. $count ಪ್ರಶ್ನೆಗಳು. ಪ್ರತಿ ಉತ್ತರ ನೋಡಲು ಮೇಲೆ ಮತ್ತು ಕೆಳಗೆ ಬಳಸಿ.';
  }

  @override
  String get quizMetaTopics =>
      'ವಿಷಯಾಂಶಗಳು ಅಥವಾ ಪರಿಕಲ್ಪನೆಗಳು, ಸಾಲಿಗೆ ಒಂದು (ಐಚ್ಛಿಕ)';

  @override
  String get quizMetaSpokenQuestion => 'ಶಿಕ್ಷಕರು ಬರೆದ ಮಾತಿನ ಪ್ರಶ್ನೆ';

  @override
  String quizMetaSpokenOption(String number) {
    return 'ಮಾತಿನ ಆಯ್ಕೆ $number';
  }

  @override
  String get quizMetaSpokenExplanation => 'ಶಿಕ್ಷಕರು ಬರೆದ ಮಾತಿನ ವಿವರಣೆ';

  @override
  String quizCorrectSelected(String number) {
    return 'ಆಯ್ಕೆ $number ಅನ್ನು ಸರಿಯಾದ ಉತ್ತರವಾಗಿ ಆರಿಸಲಾಗಿದೆ';
  }

  @override
  String quizCorrectSelectedWithText(String number, String text) {
    return 'ಆಯ್ಕೆ $number ಅನ್ನು ಸರಿಯಾದ ಉತ್ತರವಾಗಿ ಆರಿಸಲಾಗಿದೆ, $text';
  }

  @override
  String get quizEditBankQuestion => 'ಬ್ಯಾಂಕ್ ಪ್ರಶ್ನೆ ಸಂಪಾದಿಸಿ';

  @override
  String get quizCreateBankQuestion => 'ಬ್ಯಾಂಕ್ ಪ್ರಶ್ನೆ ರಚಿಸಿ';

  @override
  String get quizEditorNavigation =>
      'ಪ್ರಶ್ನೆಯ ಪಠ್ಯ, ನಾಲ್ಕು ಉತ್ತರ ಕ್ಷೇತ್ರಗಳು, ಸರಿಯಾದ ಉತ್ತರದ ಆಯ್ಕೆ, ಐಚ್ಛಿಕ ಮಾತಿನ ವಿವರಣೆಗಳು, ಮತ್ತು ಉಳಿಸಿ ಅಥವಾ ರದ್ದುಮಾಡಿ';

  @override
  String get quizSaveQuestion => 'ಪ್ರಶ್ನೆ ಉಳಿಸಿ';

  @override
  String get quizCancelQuestion => 'ಪ್ರಶ್ನೆ ರದ್ದುಮಾಡಿ';

  @override
  String quizPressOkToEdit(String item) {
    return '$item. ಸಂಪಾದಿಸಲು ಓಕೆ ಒತ್ತಿ';
  }

  @override
  String quizPressOkToChange(String item) {
    return '$item. ಬದಲಾಯಿಸಲು ಓಕೆ ಒತ್ತಿ';
  }

  @override
  String quizCorrectIsOption(String number, String text) {
    return 'ಆಯ್ಕೆ $number, $text, ಸರಿಯಾದ ಉತ್ತರ. ಬದಲಾಯಿಸಲು ಎಡ ಅಥವಾ ಬಲ ಬಳಸಿ';
  }

  @override
  String get quizHideOptionalExplanation =>
      'ಐಚ್ಛಿಕ ವಿವರಣೆ, ವಿಷಯಾಂಶಗಳು ಮತ್ತು ಮಾತಿನ ಸಂಕೇತವನ್ನು ಮರೆಮಾಡಿ';

  @override
  String get quizShowOptionalExplanation =>
      'ಐಚ್ಛಿಕ ವಿವರಣೆ, ವಿಷಯಾಂಶಗಳು ಮತ್ತು ಮಾತಿನ ಸಂಕೇತವನ್ನು ತೋರಿಸಿ';

  @override
  String get quizOptionalExplanation => 'ಐಚ್ಛಿಕ ಉತ್ತರ ವಿವರಣೆ';

  @override
  String quizNumericDateTime(
    String day,
    String month,
    String year,
    String hour,
    String minute,
  ) {
    return '$day/$month/$year ರಂದು $hour:$minute ಕ್ಕೆ';
  }

  @override
  String get quizCheckTitleLimits =>
      'ಶೀರ್ಷಿಕೆ, ಮಿತಿಗಳು ಮತ್ತು ವೇಳಾಪಟ್ಟಿಯನ್ನು ಪರಿಶೀಲಿಸಿ.';

  @override
  String get quizSettingsNavigation =>
      'ಶೀರ್ಷಿಕೆ, ಐಚ್ಛಿಕ ವಿವರಣೆ, ಸಮಯ ಮತ್ತು ಪ್ರಯತ್ನ ಸೆಟ್ಟಿಂಗ್‌ಗಳು, ಪ್ರತಿಕ್ರಿಯೆ ಮತ್ತು ಕಲಸುವ ಆಯ್ಕೆಗಳು, ಮತ್ತು ಮುಂದುವರಿಸಿ ಅಥವಾ ರದ್ದುಮಾಡಿ';

  @override
  String get quizChangeSettingsScreen =>
      'ಕ್ವಿಜ್ ಶೀರ್ಷಿಕೆ ಮತ್ತು ಐಚ್ಛಿಕ ಸೆಟ್ಟಿಂಗ್‌ಗಳನ್ನು ಬದಲಾಯಿಸಿ. ಉಳಿಸಿದರೆ ಪ್ರಕಟವಾಗುವುದಿಲ್ಲ.';

  @override
  String get quizCreatePracticeScreen =>
      'ಸಮಯ ಮಿತಿ ಇಲ್ಲದ, ಅಂಕರಹಿತ ಅಭ್ಯಾಸ ರಚಿಸಿ. ಅಮಿತ ಮರುಪ್ರಯತ್ನಗಳು ಮತ್ತು ತಕ್ಷಣದ ಪ್ರತಿಕ್ರಿಯೆ.';

  @override
  String get quizContinueToQuestions => 'ಪ್ರಶ್ನೆಗಳಿಗೆ ಮುಂದುವರಿಯಿರಿ';

  @override
  String get quizSaveSettingsReturn =>
      'ಸೆಟ್ಟಿಂಗ್‌ಗಳನ್ನು ಉಳಿಸಿ ಪರಿಶೀಲನೆಗೆ ಹಿಂತಿರುಗಿ';

  @override
  String get quizQuizTitle => 'ಕ್ವಿಜ್ ಶೀರ್ಷಿಕೆ';

  @override
  String get quizHideOptionalSettings =>
      'ಐಚ್ಛಿಕ ಸೆಟ್ಟಿಂಗ್‌ಗಳನ್ನು ಮರೆಮಾಡಿ: ವಿವರಣೆ, ಪ್ರಯತ್ನಗಳು, ಸಮಯ, ಪ್ರತಿಕ್ರಿಯೆ ಮತ್ತು ಕಲಸುವಿಕೆ';

  @override
  String get quizShowOptionalSettings =>
      'ಐಚ್ಛಿಕ ಸೆಟ್ಟಿಂಗ್‌ಗಳನ್ನು ತೋರಿಸಿ: ವಿವರಣೆ, ಪ್ರಯತ್ನಗಳು, ಸಮಯ, ಪ್ರತಿಕ್ರಿಯೆ ಮತ್ತು ಕಲಸುವಿಕೆ';

  @override
  String get quizOptionalDescription => 'ಐಚ್ಛಿಕ ಕ್ವಿಜ್ ವಿವರಣೆ';

  @override
  String quizSetOrClear(String item) {
    return '$item. ಹೊಂದಿಸಲು ಓಕೆ ಒತ್ತಿ. ತೆರವುಗೊಳಿಸಲು ಎಡ ಬಳಸಿ';
  }

  @override
  String quizShuffleQuestionsToggle(String state) {
    return 'ಪ್ರಶ್ನೆಗಳನ್ನು ಕಲಸಿ $state. ಬದಲಾಯಿಸಲು ಓಕೆ ಅಥವಾ ಎಡ ಅಥವಾ ಬಲ ಒತ್ತಿ';
  }

  @override
  String quizShuffleOptionsToggle(String state) {
    return 'ಉತ್ತರ ಆಯ್ಕೆಗಳನ್ನು ಕಲಸಿ $state. ಬದಲಾಯಿಸಲು ಓಕೆ ಅಥವಾ ಎಡ ಅಥವಾ ಬಲ ಒತ್ತಿ';
  }

  @override
  String get quizCancelQuizCreation => 'ಕ್ವಿಜ್ ರಚನೆ ರದ್ದುಮಾಡಿ';

  @override
  String quizFeedbackPolicyTarget(String policy) {
    return 'ಪ್ರತಿಕ್ರಿಯೆ ನೀತಿ $policy. ಎಡ ಅಥವಾ ಬಲ ಅದನ್ನು ಬದಲಾಯಿಸುತ್ತದೆ';
  }

  @override
  String get quizSaveDraftContinue => 'ಕರಡು ಉಳಿಸಿ ಪ್ರಶ್ನೆಗಳಿಗೆ ಮುಂದುವರಿಯಿರಿ';

  @override
  String get sessionScreenTeacherClass => 'ಶಿಕ್ಷಕರ ತರಗತಿ';

  @override
  String get sessionScreenClass => 'ತರಗತಿ';

  @override
  String get sessionDefaultTitle => 'ಸೆಷನ್';

  @override
  String get sessionJoining => 'ತರಗತಿಗೆ ಸೇರಲಾಗುತ್ತಿದೆ. ದಯವಿಟ್ಟು ಕಾಯಿರಿ.';

  @override
  String get sessionConnecting => 'ತರಗತಿಗೆ ಸಂಪರ್ಕಿಸಲಾಗುತ್ತಿದೆ.';

  @override
  String get sessionJoinFailed =>
      'ತರಗತಿಗೆ ಸೇರಲು ಆಗಲಿಲ್ಲ. ಹೊರಹೋಗಲು 0 ಒತ್ತಿ, ನಂತರ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get sessionLeaveKeyHint =>
      'ತರಗತಿಯಿಂದ ಹೊರಹೋಗಲು 0 ಒತ್ತಿ. ಅದು ಖಚಿತಪಡಿಸಲು ಕೇಳುತ್ತದೆ.';

  @override
  String get sessionKeyLine => '*: ಸಹಾಯ ಮತ್ತು ಕೊನೆಯ ಸಂದೇಶ. #: ಮಾತು ನಿಲ್ಲಿಸಿ.';

  @override
  String sessionJoinedBrief(String status) {
    return 'ತರಗತಿಯಲ್ಲಿದ್ದೀರಿ. $status ಸಹಾಯಕ್ಕಾಗಿ ಸ್ಟಾರ್ ಒತ್ತಿ.';
  }

  @override
  String sessionJoinedDetailed(String status, String keys) {
    return 'ನೀವು ತರಗತಿಯಲ್ಲಿದ್ದೀರಿ. $status $keys ನಿಯಂತ್ರಣಗಳ ನಡುವೆ ಚಲಿಸಲು ಮೇಲೆ ಮತ್ತು ಕೆಳಗೆ ಬಳಸಿ, ಆರಿಸಲು ಓಕೆ ಒತ್ತಿ. ನೀವು ಎಲ್ಲಿದ್ದೀರಿ ಮತ್ತು ಸಹಾಯಕ್ಕಾಗಿ ಸ್ಟಾರ್ ಒತ್ತಿ. ಮಾತು ನಿಲ್ಲಿಸಲು ಹ್ಯಾಶ್ ಒತ್ತಿ.';
  }

  @override
  String sessionPressKeyFor(String key, String action) {
    return '$action ಗಾಗಿ $key ಒತ್ತಿ.';
  }

  @override
  String get sessionMicWaitingLabel => 'ಮೈಕ್ರೊಫೋನ್ ಖಚಿತತೆಗಾಗಿ ಕಾಯುತ್ತಿದೆ';

  @override
  String get sessionUnmuteMicrophone => 'ಮೈಕ್ರೊಫೋನ್ ಅನ್‌ಮ್ಯೂಟ್ ಮಾಡಿ';

  @override
  String get sessionMuteMicrophone => 'ಮೈಕ್ರೊಫೋನ್ ಮ್ಯೂಟ್ ಮಾಡಿ';

  @override
  String get sessionMuteButtonWaiting => '1: ಕಾಯುತ್ತಿದೆ';

  @override
  String get sessionMuteButtonUnmute => '1: ಅನ್‌ಮ್ಯೂಟ್';

  @override
  String get sessionMuteButtonMute => '1: ಮ್ಯೂಟ್';

  @override
  String get sessionHandWaitingLabel => 'ಕೈ ಖಚಿತತೆಗಾಗಿ ಕಾಯುತ್ತಿದೆ';

  @override
  String get sessionLowerHand => 'ಕೈ ಇಳಿಸಿ';

  @override
  String get sessionRaiseHand => 'ಕೈ ಎತ್ತಿ';

  @override
  String get sessionHandButtonWaiting => '2: ಕಾಯುತ್ತಿದೆ';

  @override
  String get sessionHandButtonLower => '2: ಕೈ ಇಳಿಸಿ';

  @override
  String get sessionHandButtonRaise => '2: ಕೈ ಎತ್ತಿ';

  @override
  String get sessionStatusLabel => 'ತರಗತಿಯ ಸ್ಥಿತಿ ಕೇಳಿ';

  @override
  String get sessionStatusButton => '3: ತರಗತಿಯ ಸ್ಥಿತಿ';

  @override
  String sessionChatLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ಚಾಟ್. $count ಸಂದೇಶಗಳು',
      one: 'ಚಾಟ್. 1 ಸಂದೇಶ',
      zero: 'ಚಾಟ್. ಇನ್ನೂ ಸಂದೇಶಗಳಿಲ್ಲ',
    );
    return '$_temp0';
  }

  @override
  String get sessionChatButton => '4: ಚಾಟ್';

  @override
  String get sessionRecordingPlayerNone =>
      'ಪಾಠದ ರೆಕಾರ್ಡಿಂಗ್. ಇನ್ನೂ ಯಾವುದನ್ನೂ ಆರಿಸಿಲ್ಲ';

  @override
  String sessionRecordingPlayerPlaying(String title) {
    return 'ಪಾಠದ ರೆಕಾರ್ಡಿಂಗ್. $title, ಪ್ಲೇ ಆಗುತ್ತಿದೆ';
  }

  @override
  String sessionRecordingPlayerPaused(String title) {
    return 'ಪಾಠದ ರೆಕಾರ್ಡಿಂಗ್. $title, ವಿರಾಮದಲ್ಲಿದೆ';
  }

  @override
  String get sessionRecordingStudentNone =>
      'ತರಗತಿಯ ರೆಕಾರ್ಡಿಂಗ್. ಏನೂ ಪ್ಲೇ ಆಗುತ್ತಿಲ್ಲ. ಶಿಕ್ಷಕರು ಮಾತ್ರ ಇದನ್ನು ನಿಯಂತ್ರಿಸುತ್ತಾರೆ';

  @override
  String sessionRecordingStudentPlaying(String title) {
    return 'ತರಗತಿಯ ರೆಕಾರ್ಡಿಂಗ್, $title, ಶಿಕ್ಷಕರು ಪ್ಲೇ ಮಾಡುತ್ತಿದ್ದಾರೆ. ಅದು ಎಲ್ಲಿದೆ ಎಂದು ಕೇಳಿ';
  }

  @override
  String sessionRecordingStudentPaused(String title) {
    return 'ತರಗತಿಯ ರೆಕಾರ್ಡಿಂಗ್, $title, ಶಿಕ್ಷಕರು ವಿರಾಮಗೊಳಿಸಿದ್ದಾರೆ. ಅದು ಎಲ್ಲಿದೆ ಎಂದು ಕೇಳಿ';
  }

  @override
  String get sessionRecordingStatusButton => '5: ರೆಕಾರ್ಡಿಂಗ್ ಸ್ಥಿತಿ';

  @override
  String get sessionStudentRecordingNone =>
      'ಯಾವುದೇ ತರಗತಿಯ ರೆಕಾರ್ಡಿಂಗ್ ಪ್ಲೇ ಆಗುತ್ತಿಲ್ಲ. ಶಿಕ್ಷಕರು ಮಾತ್ರ ಪ್ಲೇ ಮಾಡಬಹುದು.';

  @override
  String sessionStudentRecordingPlaying(String title, String position) {
    return '$title, ಪ್ಲೇ ಆಗುತ್ತಿದೆ, $position ನಲ್ಲಿದೆ. ತರಗತಿಯ ರೆಕಾರ್ಡಿಂಗ್ ಅನ್ನು ಶಿಕ್ಷಕರು ಮಾತ್ರ ಪ್ಲೇ, ವಿರಾಮ ಅಥವಾ ಮುಂದೆ-ಹಿಂದೆ ಮಾಡಬಹುದು.';
  }

  @override
  String sessionStudentRecordingPaused(String title, String position) {
    return '$title, ವಿರಾಮದಲ್ಲಿದೆ, $position ನಲ್ಲಿದೆ. ತರಗತಿಯ ರೆಕಾರ್ಡಿಂಗ್ ಅನ್ನು ಶಿಕ್ಷಕರು ಮಾತ್ರ ಪ್ಲೇ, ವಿರಾಮ ಅಥವಾ ಮುಂದೆ-ಹಿಂದೆ ಮಾಡಬಹುದು.';
  }

  @override
  String get sessionRecordingPlayerButton => '5: ಪಾಠದ ರೆಕಾರ್ಡಿಂಗ್';

  @override
  String get sessionOpeningPlayerToChoose =>
      'ಇನ್ನೂ ಯಾವುದೇ ರೆಕಾರ್ಡಿಂಗ್ ಆರಿಸಿಲ್ಲ. ಒಂದನ್ನು ಆರಿಸಲು 1 ಒತ್ತಿ.';

  @override
  String get sessionCheckLabel => 'ಶಿಕ್ಷಕರ ಪ್ರಶ್ನೆಗೆ ಉತ್ತರಿಸಿ';

  @override
  String get sessionCheckButton => '3: ಪ್ರಶ್ನೆಗೆ ಉತ್ತರಿಸಿ';

  @override
  String sessionHandsLabel(String waiting) {
    return 'ಎತ್ತಿದ ಕೈಗಳು. $waiting';
  }

  @override
  String get sessionHandsButton => '2: ಎತ್ತಿದ ಕೈಗಳು';

  @override
  String sessionHandsButtonCount(int count) {
    return '2: ಎತ್ತಿದ ಕೈಗಳು ($count)';
  }

  @override
  String get sessionTeacherCheckLabel =>
      'ತರಗತಿ ಪರಿಶೀಲನೆ. ಖಾಸಗಿ ಪರಿಶೀಲನೆ ಪ್ರಾರಂಭಿಸಿ, ಅದನ್ನು ಮುಚ್ಚಿ ಮತ್ತು ಉತ್ತರಗಳನ್ನು ಕೇಳಿ';

  @override
  String sessionParticipantsLabel(String people) {
    return 'ಭಾಗವಹಿಸುವವರು. $people ಯಾರನ್ನಾದರೂ ಮ್ಯೂಟ್ ಮಾಡಿ ಅಥವಾ ತೆಗೆದುಹಾಕಿ, ಅಥವಾ ಸಾರಾಂಶ ಕೇಳಿ';
  }

  @override
  String get sessionParticipantsButton => '7: ಭಾಗವಹಿಸುವವರು';

  @override
  String get sessionToolsLabel =>
      'ಶಿಕ್ಷಕರ ಉಪಕರಣಗಳು. ಸಮಯ ಸೇರಿಸಿ ಅಥವಾ ಎಲ್ಲರಿಗೂ ತರಗತಿ ಮುಗಿಸಿ';

  @override
  String get sessionToolsButton => '9: ಶಿಕ್ಷಕರ ಉಪಕರಣಗಳು';

  @override
  String get sessionVoiceStartLabel =>
      'ಒಂದು ಧ್ವನಿ ಆದೇಶಕ್ಕಾಗಿ 12 ಸೆಕೆಂಡುಗಳವರೆಗೆ ಆಲಿಸಿ. ನೀವು ಓಕೆ ಒತ್ತಿದಾಗ ಮಾತ್ರ ಪ್ರಾರಂಭವಾಗುತ್ತದೆ';

  @override
  String get sessionVoiceStopLabel => 'ಧ್ವನಿ ಆದೇಶಕ್ಕಾಗಿ ಆಲಿಸುವುದನ್ನು ನಿಲ್ಲಿಸಿ';

  @override
  String get sessionVoiceStartButton => 'ಆದೇಶಕ್ಕಾಗಿ ಆಲಿಸಿ';

  @override
  String get sessionVoiceStopButton => 'ಆಲಿಸುವುದನ್ನು ನಿಲ್ಲಿಸಿ';

  @override
  String get sessionUpdatesLabel => 'ತರಗತಿಯ ಅಪ್‌ಡೇಟ್‌ಗಳನ್ನು ಓದಿ';

  @override
  String get sessionUpdatesButton => 'ತರಗತಿಯ ಅಪ್‌ಡೇಟ್‌ಗಳು';

  @override
  String get sessionRetryLabel => 'ತರಗತಿಯ ಸಂಪರ್ಕ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ';

  @override
  String get sessionRetryButton => 'ಸಂಪರ್ಕ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ';

  @override
  String get sessionLeaveLabel => 'ತರಗತಿಯಿಂದ ಹೊರಹೋಗಿ';

  @override
  String get sessionLeaveButton => '0: ತರಗತಿಯಿಂದ ಹೊರಹೋಗಿ';

  @override
  String get sessionMicWaiting => 'ಮೈಕ್ರೊಫೋನ್ ಖಚಿತತೆಗಾಗಿ ಕಾಯುತ್ತಿದೆ.';

  @override
  String get sessionMicMuted => 'ಮ್ಯೂಟ್ ಆಗಿದೆ.';

  @override
  String get sessionMicUnmutedHeard =>
      'ಅನ್‌ಮ್ಯೂಟ್ ಆಗಿದೆ. ಇತರರು ನಿಮ್ಮನ್ನು ಕೇಳಬಹುದು.';

  @override
  String get sessionHandWaiting => 'ಕೈ ಖಚಿತತೆಗಾಗಿ ಕಾಯುತ್ತಿದೆ.';

  @override
  String get sessionHandRaisedState => 'ಕೈ ಎತ್ತಲಾಗಿದೆ.';

  @override
  String get sessionHandDown => 'ಕೈ ಕೆಳಗಿದೆ.';

  @override
  String sessionHandsWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ಕೈಗಳು ಕಾಯುತ್ತಿವೆ.',
      one: '1 ಕೈ ಕಾಯುತ್ತಿದೆ.',
      zero: 'ಯಾವುದೇ ಕೈ ಕಾಯುತ್ತಿಲ್ಲ.',
    );
    return '$_temp0';
  }

  @override
  String sessionPeople(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ತರಗತಿಯಲ್ಲಿ $count ಜನರು ಇದ್ದಾರೆ.',
      one: 'ತರಗತಿಯಲ್ಲಿ 1 ವ್ಯಕ್ತಿ ಇದ್ದಾರೆ.',
    );
    return '$_temp0';
  }

  @override
  String get sessionNoRecordingSelected => 'ಯಾವುದೇ ರೆಕಾರ್ಡಿಂಗ್ ಆರಿಸಿಲ್ಲ.';

  @override
  String sessionRecordingStatePlaying(String title) {
    return 'ರೆಕಾರ್ಡಿಂಗ್ ಪ್ಲೇ ಆಗುತ್ತಿದೆ: $title.';
  }

  @override
  String sessionRecordingStatePaused(String title) {
    return 'ರೆಕಾರ್ಡಿಂಗ್ ವಿರಾಮದಲ್ಲಿದೆ: $title.';
  }

  @override
  String get sessionCheckOpen => 'ತರಗತಿ ಪರಿಶೀಲನೆ ತೆರೆದಿದೆ.';

  @override
  String sessionConnectionLabel(String label) {
    return '$label.';
  }

  @override
  String sessionChatMessages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ಚಾಟ್ ಸಂದೇಶಗಳು.',
      one: '1 ಚಾಟ್ ಸಂದೇಶ.',
    );
    return '$_temp0';
  }

  @override
  String get sessionRecordingFallback => 'ತರಗತಿಯ ರೆಕಾರ್ಡಿಂಗ್';

  @override
  String get sessionRecordingFallbackLower => 'ತರಗತಿಯ ರೆಕಾರ್ಡಿಂಗ್';

  @override
  String sessionUserFallback(String id) {
    return 'ಬಳಕೆದಾರ $id';
  }

  @override
  String sessionConnectionRestored(String message) {
    return 'ಸಂಪರ್ಕ ಮರಳಿ ಬಂದಿದೆ. $message';
  }

  @override
  String sessionConnectionLost(String message) {
    return 'ಸಂಪರ್ಕ ಕಡಿತಗೊಂಡಿದೆ. $message';
  }

  @override
  String sessionCouldNotConnect(String message) {
    return 'ಸಂಪರ್ಕಿಸಲು ಆಗಲಿಲ್ಲ. $message';
  }

  @override
  String get sessionMicDialogTitle => 'ಮೈಕ್ರೊಫೋನ್ ಪ್ರವೇಶ';

  @override
  String get sessionMicDialogMessage =>
      'ಈ ತರಗತಿಯಲ್ಲಿ SEEDS ಲೈವ್ ಆಡಿಯೋಗಾಗಿ ಮತ್ತು ನೀವೇ ಸ್ಪಷ್ಟವಾಗಿ ಆನ್ ಮಾಡಿದ ಧ್ವನಿ ಆದೇಶಗಳಿಗಾಗಿ ಮೈಕ್ರೊಫೋನ್ ಬಳಸುತ್ತದೆ. ಮೈಕ್ರೊಫೋನ್ ಪ್ರವೇಶ ಇಲ್ಲದೆಯೂ ನೀವು ಇರಬಹುದು, ಆದರೆ ಇತರರು ನಿಮ್ಮನ್ನು ಕೇಳಲು ಆಗುವುದಿಲ್ಲ. ಪ್ರತ್ಯೇಕ ಖಾಸಗಿ ಟಿಪ್ಪಣಿ ರೆಕಾರ್ಡಿಂಗ್‌ಗೆ ಲೈವ್ ತರಗತಿಗಳ ಹೊರಗೆ ತನ್ನದೇ ಆದ ಸ್ಪಷ್ಟ ಪ್ರಾರಂಭ ಬೇಕು.';

  @override
  String get sessionMicDialogConfirm => 'ತರಗತಿಗೆ ಮುಂದುವರಿಯಿರಿ';

  @override
  String get sessionMicSkipped =>
      'ಮೈಕ್ರೊಫೋನ್ ಪ್ರವೇಶ ಬಿಟ್ಟುಬಿಡಲಾಗಿದೆ. ನೀವು ಮ್ಯೂಟ್ ಆಗಿ ತರಗತಿಗೆ ಸೇರಿದ್ದೀರಿ.';

  @override
  String get sessionMicUnavailable =>
      'ಮೈಕ್ರೊಫೋನ್ ಪ್ರವೇಶ ಲಭ್ಯವಿಲ್ಲ. ನೀವು ಮ್ಯೂಟ್ ಆಗಿ ತರಗತಿಗೆ ಸೇರಿದ್ದೀರಿ.';

  @override
  String get sessionWaitingMic => 'ಮೈಕ್ರೊಫೋನ್ ಖಚಿತತೆಗಾಗಿ ಕಾಯಲಾಗುತ್ತಿದೆ.';

  @override
  String get sessionMuted => 'ಮ್ಯೂಟ್ ಆಗಿದೆ';

  @override
  String get sessionUnmuted => 'ಅನ್‌ಮ್ಯೂಟ್ ಆಗಿದೆ';

  @override
  String get sessionMutedLocallyOnly =>
      'ಈ ಫೋನ್‌ನಲ್ಲಿ ಮೈಕ್ರೊಫೋನ್ ಮ್ಯೂಟ್ ಆಗಿದೆ. ತರಗತಿಯಿಂದ ಖಚಿತತೆ ಬಂದಿಲ್ಲ.';

  @override
  String get sessionMutedByTeacher =>
      'ಶಿಕ್ಷಕರು ನಿಮ್ಮ ಮೈಕ್ರೊಫೋನ್ ಮ್ಯೂಟ್ ಮಾಡಿದ್ದಾರೆ.';

  @override
  String get sessionMicClassClosed =>
      'ತರಗತಿ ಮುಚ್ಚಿದೆ. ಯಾವುದೇ ಮೈಕ್ರೊಫೋನ್ ಕ್ರಿಯೆ ಕಳುಹಿಸಲಾಗಿಲ್ಲ.';

  @override
  String get sessionMicUnavailableRejoin =>
      'ಮೈಕ್ರೊಫೋನ್ ಪ್ರವೇಶ ಲಭ್ಯವಿಲ್ಲ. ಮಾತನಾಡಲು ಪ್ರಯತ್ನಿಸುವ ಮೊದಲು ಮೈಕ್ರೊಫೋನ್ ಅನುಮತಿ ಪರಿಶೀಲಿಸಿ ಮತ್ತು ತರಗತಿಗೆ ಮತ್ತೆ ಸೇರಿ.';

  @override
  String get sessionMicClosedBeforeConfirm =>
      'ಮೈಕ್ರೊಫೋನ್ ಖಚಿತತೆಗೆ ಮೊದಲೇ ತರಗತಿ ಮುಚ್ಚಿತು.';

  @override
  String get sessionMicNoLongerAvailable =>
      'ಮೈಕ್ರೊಫೋನ್ ಪ್ರವೇಶ ಈಗ ಲಭ್ಯವಿಲ್ಲ. ಮಾತನಾಡಲು ಪ್ರಯತ್ನಿಸುವ ಮೊದಲು ತರಗತಿಗೆ ಮತ್ತೆ ಸೇರಿ.';

  @override
  String get sessionMicStayedMuted =>
      'ತರಗತಿಯ ಮ್ಯೂಟ್ ಸ್ಥಿತಿ ಬದಲಾದ ಕಾರಣ ನಿಮ್ಮ ಮೈಕ್ರೊಫೋನ್ ಮ್ಯೂಟ್ ಆಗಿಯೇ ಉಳಿದಿದೆ. ಮಾತನಾಡಲು ಸಿದ್ಧರಾದಾಗ ಅನ್‌ಮ್ಯೂಟ್ ಆರಿಸಿ.';

  @override
  String get sessionWaitingHand => 'ಕೈ ಸ್ಥಿತಿಯ ಖಚಿತತೆಗಾಗಿ ಕಾಯಲಾಗುತ್ತಿದೆ.';

  @override
  String get sessionHandRaised => 'ಕೈ ಎತ್ತಲಾಗಿದೆ';

  @override
  String get sessionHandLowered => 'ಕೈ ಇಳಿಸಲಾಗಿದೆ';

  @override
  String get sessionHandNotConfirmed =>
      'ನಿಮ್ಮ ಕೈ ಬದಲಾವಣೆ ಖಚಿತವಾಗಿಲ್ಲ. ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಲು 2 ಒತ್ತಿ.';

  @override
  String sessionRaisedHandBy(String name) {
    return '$name ಕೈ ಎತ್ತಿದ್ದಾರೆ. ಎತ್ತಿದ ಕೈಗಳಿಗಾಗಿ 2 ಒತ್ತಿ.';
  }

  @override
  String get sessionRaisedHandUnknown =>
      'ಒಬ್ಬ ಭಾಗವಹಿಸುವವರು ಕೈ ಎತ್ತಿದ್ದಾರೆ. ಕೈ ಎತ್ತಿದವರಿಗಾಗಿ 2 ಒತ್ತಿ.';

  @override
  String get sessionParticipantJoined => 'ಒಬ್ಬ ಭಾಗವಹಿಸುವವರು ಸೇರಿದ್ದಾರೆ.';

  @override
  String get sessionParticipantsJoinedGroup => 'ಸೇರಿದ ಭಾಗವಹಿಸುವವರು';

  @override
  String get sessionParticipantLeft => 'ಒಬ್ಬ ಭಾಗವಹಿಸುವವರು ಹೊರಟಿದ್ದಾರೆ.';

  @override
  String get sessionParticipantsLeftGroup => 'ಹೊರಟ ಭಾಗವಹಿಸುವವರು';

  @override
  String get sessionParticipantFallback => 'ಭಾಗವಹಿಸುವವರು';

  @override
  String get sessionThisParticipant => 'ಈ ಭಾಗವಹಿಸುವವರು';

  @override
  String sessionParticipantSelf(String name) {
    return '$name, ನೀವು';
  }

  @override
  String get sessionRoleTeacher => 'ಶಿಕ್ಷಕರು';

  @override
  String get sessionRoleStudent => 'ವಿದ್ಯಾರ್ಥಿ';

  @override
  String get sessionStateHandRaised => 'ಕೈ ಎತ್ತಿದ್ದಾರೆ';

  @override
  String get sessionStateMuted => 'ಮ್ಯೂಟ್ ಆಗಿದೆ';

  @override
  String get sessionStateUnmuted => 'ಅನ್‌ಮ್ಯೂಟ್ ಆಗಿದೆ';

  @override
  String get sessionStateSpeaking => 'ಮಾತನಾಡುತ್ತಿದ್ದಾರೆ';

  @override
  String sessionAlreadyMuted(String name) {
    return '$name ಮ್ಯೂಟ್ ಆಗಿದ್ದಾರೆ. $name ಮಾತ್ರ ಅನ್‌ಮ್ಯೂಟ್ ಮಾಡಬಹುದು.';
  }

  @override
  String sessionParticipantMuted(String name) {
    return '$name ಮ್ಯೂಟ್ ಆಗಿದ್ದಾರೆ.';
  }

  @override
  String sessionRemoveTitle(String name) {
    return '$name ಅವರನ್ನು ತೆಗೆದುಹಾಕಬೇಕೇ?';
  }

  @override
  String sessionRemoveMessage(String name) {
    return '$name ಅವರನ್ನು ಈ ತರಗತಿಯಿಂದ ತೆಗೆದುಹಾಕಲಾಗುತ್ತದೆ ಮತ್ತು ಅವರ ಡ್ಯಾಶ್‌ಬೋರ್ಡ್‌ಗೆ ಕಳುಹಿಸಲಾಗುತ್ತದೆ. ನಂತರ ಅವರನ್ನು ಮತ್ತೆ ಆಹ್ವಾನಿಸಬಹುದು.';
  }

  @override
  String sessionKeep(String name) {
    return '$name ಅವರನ್ನು ಉಳಿಸಿ';
  }

  @override
  String sessionRemove(String name) {
    return '$name ಅವರನ್ನು ತೆಗೆದುಹಾಕಿ';
  }

  @override
  String sessionRemoved(String name) {
    return '$name ಅವರನ್ನು ತರಗತಿಯಿಂದ ತೆಗೆದುಹಾಕಲಾಗಿದೆ.';
  }

  @override
  String chatMessageFrom(String sender, String text) {
    return '$sender ಅವರಿಂದ ಸಂದೇಶ: $text';
  }

  @override
  String get chatSenderUnknown => 'ಅಪರಿಚಿತ';

  @override
  String get chatSenderUnknownLower => 'ಅಪರಿಚಿತ';

  @override
  String get chatWaitingConfirmation => 'ಸಂದೇಶದ ದೃಢೀಕರಣಕ್ಕಾಗಿ ಕಾಯಲಾಗುತ್ತಿದೆ.';

  @override
  String get chatEmptyMessage =>
      'ಕಳುಹಿಸಿ ಆಯ್ಕೆ ಮಾಡುವ ಮೊದಲು ಸಂದೇಶವನ್ನು ಬರೆಯಿರಿ.';

  @override
  String get chatMessageSent => 'ಸಂದೇಶ ಕಳುಹಿಸಲಾಗಿದೆ.';

  @override
  String get chatSending => 'ಕಳುಹಿಸಲಾಗುತ್ತಿದೆ';

  @override
  String get chatSent => 'ಕಳುಹಿಸಲಾಗಿದೆ';

  @override
  String get chatNotConfirmed => 'ದೃಢೀಕರಿಸಲಾಗಿಲ್ಲ';

  @override
  String get chatNoMessages => 'ಇನ್ನೂ ಯಾವುದೇ ಸಂದೇಶಗಳಿಲ್ಲ.';

  @override
  String get chatTitle => 'ಚಾಟ್';

  @override
  String get chatReadMessages => 'ಸಂದೇಶಗಳನ್ನು ಓದಿ, ಹೊಸದು ಮೊದಲು';

  @override
  String get chatWriteMessage => 'ಸಂದೇಶ ಬರೆಯಿರಿ';

  @override
  String get chatMessageField => 'ತರಗತಿಗೆ ನಿಮ್ಮ ಸಂದೇಶ';

  @override
  String get chatMessagesTitle => 'ಚಾಟ್ ಸಂದೇಶಗಳು';

  @override
  String get chatPhraseUnderstood => 'ನನಗೆ ಅರ್ಥವಾಯಿತು';

  @override
  String get chatPhraseRepeat => 'ದಯವಿಟ್ಟು ಮತ್ತೆ ಹೇಳಿ';

  @override
  String get chatPhraseQuestion => 'ನನಗೆ ಒಂದು ಪ್ರಶ್ನೆ ಇದೆ';

  @override
  String chatSendPhrase(String phrase) {
    return 'ಕಳುಹಿಸಿ: $phrase';
  }

  @override
  String chatCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ಸಂದೇಶಗಳು.',
      one: '1 ಸಂದೇಶ.',
    );
    return '$_temp0';
  }

  @override
  String get chatHelpBrief => 'ಓದಿ, ಬರೆಯಿರಿ ಅಥವಾ ತ್ವರಿತ ವಾಕ್ಯವನ್ನು ಕಳುಹಿಸಿ.';

  @override
  String get chatHelpDetailed =>
      'ಸಂದೇಶಗಳನ್ನು ಓದಲು 1 ಒತ್ತಿ, ಬರೆಯಲು 2 ಒತ್ತಿ, ಅಥವಾ ತ್ವರಿತ ವಾಕ್ಯ ಕಳುಹಿಸಲು 3 ರಿಂದ 5 ಒತ್ತಿ. ಹೊಸ ಸಂದೇಶವನ್ನು ಕೇಳಲು 8 ಒತ್ತಿ.';

  @override
  String get chatYou => 'ನೀವು';

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
    return '$line. $time ಕ್ಕೆ ಕಳುಹಿಸಲಾಗಿದೆ.';
  }

  @override
  String chatNewestMessage(String detail) {
    return 'ಹೊಸ ಸಂದೇಶ. $detail';
  }

  @override
  String get chatReadLatest => 'ಹೊಸ ಸಂದೇಶವನ್ನು ಓದಿ';

  @override
  String get chatMessageLabel => 'ಚಾಟ್ ಸಂದೇಶ';

  @override
  String get chatSendMessage => 'ಸಂದೇಶ ಕಳುಹಿಸಿ';

  @override
  String chatSaid(String sender, String text) {
    return '$sender ಹೇಳಿದರು: $text';
  }

  @override
  String chatSaidDelivery(String sender, String text, String delivery) {
    return '$sender ಹೇಳಿದರು: $text. $delivery';
  }

  @override
  String chatLatestLineDelivery(String sender, String text, String delivery) {
    return '$sender: $text\nತಲುಪಿಸುವ ಸ್ಥಿತಿ: $delivery.';
  }

  @override
  String get sessionLeaveTitle => 'ತರಗತಿಯಿಂದ ಹೊರಡಬೇಕೇ?';

  @override
  String get sessionLeaveMessage =>
      'ನೀವು ಈ ತರಗತಿಯಿಂದ ಹೊರಟು ನಿಮ್ಮ ಡ್ಯಾಶ್‌ಬೋರ್ಡ್‌ಗೆ ಹಿಂತಿರುಗುತ್ತೀರಿ. ನೀವು ಲಾಗ್ ಇನ್ ಆಗಿಯೇ ಇರುತ್ತೀರಿ.';

  @override
  String get sessionTeacherLeaveMessage =>
      'ನೀವು ಹೊರಟು ನಿಮ್ಮ ಡ್ಯಾಶ್‌ಬೋರ್ಡ್‌ಗೆ ಹಿಂತಿರುಗುತ್ತೀರಿ. ವಿದ್ಯಾರ್ಥಿಗಳಿಗೆ ತರಗತಿ ಮುಂದುವರಿಯುತ್ತದೆ. ಎಲ್ಲರಿಗೂ ಕೊನೆಗೊಳಿಸಲು, 9, ಶಿಕ್ಷಕರ ಉಪಕರಣಗಳನ್ನು ಬಳಸಿ.';

  @override
  String get sessionStay => 'ತರಗತಿಯಲ್ಲೇ ಇರಿ';

  @override
  String get sessionLeave => 'ತರಗತಿಯಿಂದ ಹೊರಡಿ';

  @override
  String get sessionLeaveLocallyTitle => 'ಸರ್ವರ್ ದೃಢೀಕರಣವಿಲ್ಲದೆ ಹೊರಡಬೇಕೇ?';

  @override
  String get sessionLeaveLocallyMessage =>
      'ಈ ಫೋನ್ ಮ್ಯೂಟ್ ಆಗಿದೆ. ನಿಮ್ಮ ಎತ್ತಿದ ಕೈ ಇಳಿಸಿರುವುದನ್ನು ಸರ್ವರ್ ದೃಢೀಕರಿಸಿಲ್ಲ. ಈಗ ಈ ಫೋನ್‌ನಲ್ಲಿ ಮಾತ್ರ ಹೊರಡಬೇಕೇ, ಅಥವಾ ಇದ್ದು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಬೇಕೇ? ಹೊಸದಾಗಿ ಸೇರಿದರೆ ನಿಮ್ಮ ಕೈ ಮರುಹೊಂದಿಸಲಾಗುತ್ತದೆ.';

  @override
  String get sessionStayAndRetry => 'ಇದ್ದು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ';

  @override
  String get sessionLeaveLocally => 'ಈ ಫೋನ್‌ನಲ್ಲಿ ಮಾತ್ರ ಹೊರಡಿ';

  @override
  String get sessionEndTitle => 'ಎಲ್ಲರಿಗೂ ತರಗತಿಯನ್ನು ಕೊನೆಗೊಳಿಸಬೇಕೇ?';

  @override
  String get sessionEndMessage =>
      'ಇದು ಪ್ರತಿಯೊಬ್ಬ ಭಾಗವಹಿಸುವವರಿಗೂ ತರಗತಿಯನ್ನು ನಿಲ್ಲಿಸುತ್ತದೆ ಮತ್ತು ಎಲ್ಲರನ್ನೂ ಅವರ ಡ್ಯಾಶ್‌ಬೋರ್ಡ್‌ಗೆ ಹಿಂತಿರುಗಿಸುತ್ತದೆ. ಯಾರನ್ನೂ ಲಾಗ್ ಔಟ್ ಮಾಡಲಾಗುವುದಿಲ್ಲ.';

  @override
  String get sessionEndCancel => 'ತರಗತಿಯನ್ನು ಮುಂದುವರಿಸಿ';

  @override
  String get sessionEndConfirm => 'ಎಲ್ಲರಿಗೂ ಕೊನೆಗೊಳಿಸಿ';

  @override
  String get sessionWaitingEnd =>
      'ತರಗತಿ ಕೊನೆಗೊಳಿಸುವ ದೃಢೀಕರಣಕ್ಕಾಗಿ ಕಾಯಲಾಗುತ್ತಿದೆ.';

  @override
  String get sessionEndNotConfirmed =>
      'ತರಗತಿ ಕೊನೆಗೊಳಿಸುವುದನ್ನು ದೃಢೀಕರಿಸಲಾಗಿಲ್ಲ. ತರಗತಿ ಇನ್ನೂ ನಡೆಯುತ್ತಿದೆ.';

  @override
  String get sessionEndingForEveryone =>
      'ಎಲ್ಲರಿಗೂ ತರಗತಿಯನ್ನು ಕೊನೆಗೊಳಿಸಲಾಗುತ್ತಿದೆ.';

  @override
  String get sessionYouLeft => 'ನೀವು ತರಗತಿಯಿಂದ ಹೊರಟಿದ್ದೀರಿ.';

  @override
  String get sessionClassEnded => 'ತರಗತಿ ಮುಗಿದಿದೆ.';

  @override
  String get sessionYouWereRemoved => 'ನಿಮ್ಮನ್ನು ತರಗತಿಯಿಂದ ತೆಗೆದುಹಾಕಲಾಗಿದೆ.';

  @override
  String get sessionSignInChanged =>
      'ನಿಮ್ಮ ಸೈನ್ ಇನ್ ಬದಲಾಗಿದೆ. ಮತ್ತೆ ಸೈನ್ ಇನ್ ಮಾಡಿ ಅಥವಾ ನಿಮ್ಮ ಶಾಲೆಯ ನಿರ್ವಾಹಕರನ್ನು ಸಂಪರ್ಕಿಸಿ.';

  @override
  String get sessionCleanupFailed =>
      'ಸೈನ್ ಇನ್ ಕೊನೆಗೊಂಡಿದೆ. ಫೋನ್‌ನ ಆಡಿಯೊ ಸ್ವಚ್ಛಗೊಳಿಸುವಿಕೆಯನ್ನು ದೃಢೀಕರಿಸಲಾಗಲಿಲ್ಲ. ಆಡಿಯೊ ಮುಂದುವರಿದರೆ SEEDS ಅನ್ನು ಮುಚ್ಚಿ.';

  @override
  String get sessionCleanupTimedOut =>
      'ಸೈನ್ ಇನ್ ಕೊನೆಗೊಂಡಿದೆ. ಆಡಿಯೊ ಸ್ವಚ್ಛಗೊಳಿಸುವಿಕೆಯ ಸಮಯ ಮೀರಿದೆ. ಆಡಿಯೊ ಮುಂದುವರಿದರೆ SEEDS ಅನ್ನು ಮುಚ್ಚಿ.';

  @override
  String get sessionRequestFailed =>
      'ಆ ವಿನಂತಿಯನ್ನು ಪೂರ್ಣಗೊಳಿಸಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ. ದಯವಿಟ್ಟು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get sessionVoiceStopped => 'ಧ್ವನಿ ಆಲಿಸುವಿಕೆ ನಿಂತಿದೆ.';

  @override
  String get sessionVoiceUnmuteTitle => 'ನಿಮ್ಮ ಮೈಕ್ರೊಫೋನ್ ಅನ್‌ಮ್ಯೂಟ್ ಮಾಡಬೇಕೇ?';

  @override
  String get sessionVoiceUnmuteMessage =>
      'ಧ್ವನಿ ಆದೇಶವು ಅನ್‌ಮ್ಯೂಟ್ ಕೇಳಿದೆ. ಕೀ ಅಥವಾ ಸ್ಪರ್ಶದಿಂದ ದೃಢೀಕರಿಸಿ. ತರಗತಿಯ ಇತರ ಸದಸ್ಯರು ನಿಮ್ಮನ್ನು ಕೇಳಬಹುದು.';

  @override
  String get sessionVoiceUnmuteConfirm => 'ಅನ್‌ಮ್ಯೂಟ್';

  @override
  String get sessionVoiceUnmuteCancel => 'ಮ್ಯೂಟ್‌ನಲ್ಲೇ ಇರಿ';

  @override
  String get sessionAlreadyUnmuted => 'ಈಗಾಗಲೇ ಅನ್‌ಮ್ಯೂಟ್ ಆಗಿದೆ';

  @override
  String get sessionAlreadyMutedSelf => 'ಈಗಾಗಲೇ ಮ್ಯೂಟ್ ಆಗಿದೆ';

  @override
  String get sessionHandAlreadyLowered => 'ಕೈ ಈಗಾಗಲೇ ಇಳಿಸಲಾಗಿದೆ';

  @override
  String get sessionHandAlreadyRaised => 'ಕೈ ಈಗಾಗಲೇ ಎತ್ತಲಾಗಿದೆ';

  @override
  String get sessionCommandNotRecognized => 'ಆದೇಶ ಗುರುತಿಸಲಾಗಲಿಲ್ಲ';

  @override
  String get sessionVoiceStopUnconfirmed =>
      'ಧ್ವನಿ ಆಲಿಸುವಿಕೆ ನಿಂತಿರುವುದು ದೃಢೀಕರಿಸಲಾಗಿಲ್ಲ. ಮತ್ತೆ ನಿಲ್ಲಿಸಲು ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get sessionVoiceStopping => 'ಧ್ವನಿ ಆಲಿಸುವಿಕೆಯನ್ನು ನಿಲ್ಲಿಸಲಾಗುತ್ತಿದೆ.';

  @override
  String get sessionVoiceStarting => 'ಧ್ವನಿ ಆದೇಶಗಳನ್ನು ಪ್ರಾರಂಭಿಸಲಾಗುತ್ತಿದೆ.';

  @override
  String get sessionVoiceFinishing =>
      'ಧ್ವನಿ ಗುರುತಿಸುವಿಕೆಯನ್ನು ಮುಗಿಸಲಾಗುತ್ತಿದೆ.';

  @override
  String get sessionVoiceListening =>
      'ಒಂದು ಆದೇಶಕ್ಕಾಗಿ ಆಲಿಸಲಾಗುತ್ತಿದೆ, 12 ಸೆಕೆಂಡುಗಳವರೆಗೆ.';

  @override
  String get sessionVoiceIdle =>
      'ಆಲಿಸುತ್ತಿಲ್ಲ. ಪ್ರಾರಂಭಿಸಲು ಆದೇಶಕ್ಕಾಗಿ ಆಲಿಸಿ ಅನ್ನು ಸಕ್ರಿಯಗೊಳಿಸಿ.';

  @override
  String get sessionVoiceSpeechNotStopped =>
      'ಆ್ಯಪ್ ಧ್ವನಿಯನ್ನು ನಿಲ್ಲಿಸಲಾಗಲಿಲ್ಲ. ಆಲಿಸುವ ಮೊದಲು ಧ್ವನಿ ನಿಲ್ಲಿಸಿ ಅನ್ನು ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get sessionVoiceUnavailable =>
      'ಧ್ವನಿ ಆದೇಶಗಳು ಲಭ್ಯವಿಲ್ಲ. ಮೈಕ್ರೊಫೋನ್ ಅನುಮತಿ ಮತ್ತು Android ಇಂಗ್ಲಿಷ್ ಧ್ವನಿ ಸೇವೆಗಳನ್ನು ಪರಿಶೀಲಿಸಿ.';

  @override
  String get sessionVoiceCouldNotStart =>
      'ಧ್ವನಿ ಆದೇಶಗಳನ್ನು ಪ್ರಾರಂಭಿಸಲಾಗಲಿಲ್ಲ. ಮೈಕ್ರೊಫೋನ್ ಅನುಮತಿ ಮತ್ತು ಇಂಗ್ಲಿಷ್ ಧ್ವನಿ ಸೇವೆಗಳನ್ನು ಪರಿಶೀಲಿಸಿ, ನಂತರ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get sessionVoiceCouldNotFinish =>
      'ಧ್ವನಿ ಗುರುತಿಸುವಿಕೆ ಮುಗಿಯಲಿಲ್ಲ. ಅನುಮತಿ ಮತ್ತು ಇಂಗ್ಲಿಷ್ ಧ್ವನಿ ಸೇವೆಗಳನ್ನು ಪರಿಶೀಲಿಸಿ, ನಂತರ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಲು ಆಲಿಸಿ ಅನ್ನು ಸಕ್ರಿಯಗೊಳಿಸಿ.';

  @override
  String get sessionVoiceNoCommand =>
      'ಯಾವುದೇ ಆದೇಶ ಕೇಳಿಸಲಿಲ್ಲ. ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಲು ಆದೇಶಕ್ಕಾಗಿ ಆಲಿಸಿ ಅನ್ನು ಸಕ್ರಿಯಗೊಳಿಸಿ.';

  @override
  String get sessionVoiceCommandFailed =>
      'ಧ್ವನಿ ಆದೇಶವನ್ನು ಪೂರ್ಣಗೊಳಿಸಲಾಗಲಿಲ್ಲ. ಅದರ ಕೀಪ್ಯಾಡ್ ನಿಯಂತ್ರಣವನ್ನು ಬಳಸಿ ಅಥವಾ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get sessionVoiceCannotStop =>
      'ಧ್ವನಿ ಆಲಿಸುವಿಕೆಯನ್ನು ನಿಲ್ಲಿಸಲಾಗಲಿಲ್ಲ. ಆಲಿಸುವುದನ್ನು ನಿಲ್ಲಿಸಿ ಅನ್ನು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ ಅಥವಾ ತರಗತಿಯಿಂದ ಹೊರಟು Android ಮೈಕ್ರೊಫೋನ್ ಸೂಚಕವನ್ನು ಪರಿಶೀಲಿಸಿ.';

  @override
  String get sessionRecordingSelectionChanged =>
      'ತರಗತಿಯ ರೆಕಾರ್ಡಿಂಗ್ ಆಯ್ಕೆ ಬದಲಾಗಿದೆ. ವಿವರಗಳಿಗಾಗಿ ತರಗತಿ ಅಪ್‌ಡೇಟ್‌ಗಳನ್ನು ಓದಿ ಅನ್ನು ಬಳಸಿ.';

  @override
  String get sessionRecordingSelectionGroup => 'ತರಗತಿಯ ರೆಕಾರ್ಡಿಂಗ್ ಆಯ್ಕೆ';

  @override
  String get sessionPlaybackFinished => 'ರೆಕಾರ್ಡಿಂಗ್ ಮುಗಿದಿದೆ.';

  @override
  String get sessionNoRecording => 'ಯಾವುದೇ ತರಗತಿ ರೆಕಾರ್ಡಿಂಗ್ ಆಯ್ಕೆ ಮಾಡಿಲ್ಲ.';

  @override
  String get sessionNoRecordingTeacher =>
      'ಯಾವುದೇ ತರಗತಿ ರೆಕಾರ್ಡಿಂಗ್ ಆಯ್ಕೆ ಮಾಡಿಲ್ಲ. ರೆಕಾರ್ಡಿಂಗ್ ಪ್ಲೇಯರ್‌ನಲ್ಲಿ, ಒಂದನ್ನು ಆಯ್ಕೆ ಮಾಡಲು 1 ಒತ್ತಿ.';

  @override
  String get sessionPreviewFailed =>
      'ಖಾಸಗಿ ಪೂರ್ವವೀಕ್ಷಣೆ ಪ್ರಾರಂಭವಾಗಲಿಲ್ಲ. ಸಂಪರ್ಕವನ್ನು ಪರಿಶೀಲಿಸಿ ಮತ್ತು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String sessionClassPauseUnconfirmed(String reason) {
    return 'ನಿಮ್ಮ ಫೋನ್‌ನ ಆಡಿಯೊ ವಿರಾಮಗೊಂಡಿದೆ. ತರಗತಿಯ ವಿರಾಮವನ್ನು ದೃಢೀಕರಿಸಲಾಗಿಲ್ಲ. $reason';
  }

  @override
  String sessionSpeed(String speed) {
    return '$speed ಪಟ್ಟು ವೇಗ';
  }

  @override
  String sessionPlaybackAccepted(String title) {
    return '$title ಗಾಗಿ ತರಗತಿ ಪ್ಲೇ ವಿನಂತಿಯನ್ನು ಸ್ವೀಕರಿಸಲಾಗಿದೆ.';
  }

  @override
  String sessionSelected(String title) {
    return '$title ಅನ್ನು ತರಗತಿಗಾಗಿ ಆಯ್ಕೆ ಮಾಡಲಾಗಿದೆ. ಅದನ್ನು ಪ್ಲೇ ಮಾಡಲು 5 ಒತ್ತಿ.';
  }

  @override
  String sessionPreviewing(String title) {
    return '$title ಅನ್ನು ಈ ಫೋನ್‌ನಲ್ಲಿ ಮಾತ್ರ ಪೂರ್ವವೀಕ್ಷಿಸಲಾಗುತ್ತಿದೆ.';
  }

  @override
  String get sessionPreviewStopped => 'ಪೂರ್ವವೀಕ್ಷಣೆ ನಿಂತಿದೆ.';

  @override
  String get sessionRecordingsTitle => 'ತರಗತಿ ರೆಕಾರ್ಡಿಂಗ್ ಪ್ಲೇಯರ್';

  @override
  String get sessionChooseRecording => 'ಲೈಬ್ರರಿಯಿಂದ ರೆಕಾರ್ಡಿಂಗ್ ಆಯ್ಕೆ ಮಾಡಿ';

  @override
  String get sessionUploadRecording => 'ಹೊಸ ರೆಕಾರ್ಡಿಂಗ್ ಅಪ್‌ಲೋಡ್ ಮಾಡಿ';

  @override
  String get sessionHearRecording => 'ರೆಕಾರ್ಡಿಂಗ್ ಸ್ಥಿತಿಯನ್ನು ಕೇಳಿ';

  @override
  String get sessionPlayPauseClass => 'ತರಗತಿಗಾಗಿ ಪ್ಲೇ ಅಥವಾ ವಿರಾಮ';

  @override
  String get sessionLibraryLoading =>
      'ರೆಕಾರ್ಡಿಂಗ್ ಲೈಬ್ರರಿ ಇನ್ನೂ ಲೋಡ್ ಆಗುತ್ತಿದೆ. ಸ್ವಲ್ಪ ಸಮಯದ ನಂತರ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get sessionLibraryEmpty =>
      'ಈ ತರಗತಿಗೆ ಇನ್ನೂ ಯಾವುದೇ ರೆಕಾರ್ಡಿಂಗ್‌ಗಳಿಲ್ಲ. ಒಂದನ್ನು ಅಪ್‌ಲೋಡ್ ಮಾಡಲು 2 ಒತ್ತಿ.';

  @override
  String get sessionPositionHint => '10 ಸೆಕೆಂಡುಗಳು ಸರಿಸಲು ಎಡ ಮತ್ತು ಬಲ ಬಳಸಿ';

  @override
  String sessionRecordingStatusPlaying(
    String title,
    String position,
    String speed,
  ) {
    return '$title. ತರಗತಿಗಾಗಿ ಪ್ಲೇ ಆಗುತ್ತಿದೆ. $position. $speed.';
  }

  @override
  String sessionRecordingStatusPaused(
    String title,
    String position,
    String speed,
  ) {
    return '$title. ವಿರಾಮಗೊಂಡಿದೆ. $position. $speed.';
  }

  @override
  String sessionPositionLabel(String position) {
    return 'ಸ್ಥಾನ $position. 10 ಸೆಕೆಂಡುಗಳು ಸರಿಸಲು ಎಡ ಮತ್ತು ಬಲ ಬಳಸಿ';
  }

  @override
  String get sessionUntitled => 'ಶೀರ್ಷಿಕೆ ಇಲ್ಲ';

  @override
  String get sessionFileSelectedForClass => 'ತರಗತಿಗಾಗಿ ಆಯ್ಕೆ ಮಾಡಲಾಗಿದೆ';

  @override
  String get sessionFilePreviewing => 'ಪೂರ್ವವೀಕ್ಷಿಸಲಾಗುತ್ತಿದೆ';

  @override
  String get sessionPlayForClass => 'ಆಯ್ಕೆ ಮಾಡಿ ಮತ್ತು ಈಗ ತರಗತಿಗಾಗಿ ಪ್ಲೇ ಮಾಡಿ';

  @override
  String get sessionSelectOnly => 'ಆಯ್ಕೆ ಮಾತ್ರ ಮಾಡಿ, ನಂತರ 5 ರಿಂದ ಪ್ಲೇ ಮಾಡಿ';

  @override
  String get sessionPreviewPrivately => 'ಈ ಫೋನ್‌ನಲ್ಲಿ ಖಾಸಗಿಯಾಗಿ ಪೂರ್ವವೀಕ್ಷಿಸಿ';

  @override
  String get sessionStopPreview => 'ಖಾಸಗಿ ಪೂರ್ವವೀಕ್ಷಣೆಯನ್ನು ನಿಲ್ಲಿಸಿ';

  @override
  String get sessionUploadDetailsTitle => 'ಆಡಿಯೊ ಅಪ್‌ಲೋಡ್ ವಿವರಗಳು';

  @override
  String get sessionUploadTitle => 'ಆಡಿಯೊ ಅಪ್‌ಲೋಡ್ ಮಾಡಿ';

  @override
  String sessionUploadFile(String name) {
    return 'ಫೈಲ್: $name';
  }

  @override
  String get sessionTitleField => 'ಆಡಿಯೊ ಶೀರ್ಷಿಕೆ, ಅಗತ್ಯವಿದೆ';

  @override
  String get sessionDescriptionField => 'ಆಡಿಯೊ ವಿವರಣೆ, ಐಚ್ಛಿಕ';

  @override
  String get sessionCancelUpload => 'ಅಪ್‌ಲೋಡ್ ರದ್ದುಮಾಡಿ';

  @override
  String get sessionConfirmUpload => 'ಆಡಿಯೊ ಅಪ್‌ಲೋಡ್ ಮಾಡಿ';

  @override
  String get sessionTitleRequired => 'ಶೀರ್ಷಿಕೆ ಅಗತ್ಯವಿದೆ';

  @override
  String get sessionChooseSessionsTitle => 'ಈ ಆಡಿಯೊಗಾಗಿ ತರಗತಿಗಳನ್ನು ಆಯ್ಕೆ ಮಾಡಿ';

  @override
  String get sessionAddToSessions => 'ಆಡಿಯೊವನ್ನು ತರಗತಿಗಳಿಗೆ ಸೇರಿಸಿ';

  @override
  String get sessionConfirmSessions => 'ಆಯ್ಕೆ ಮಾಡಿದ ತರಗತಿಗಳನ್ನು ದೃಢೀಕರಿಸಿ';

  @override
  String get sessionSelectAtLeastOne => 'ಕನಿಷ್ಠ ಒಂದು ತರಗತಿಯನ್ನು ಆಯ್ಕೆ ಮಾಡಿ';

  @override
  String get sessionSessionSelected => 'ತರಗತಿ ಆಯ್ಕೆ ಮಾಡಲಾಗಿದೆ';

  @override
  String get sessionSessionUnselected => 'ತರಗತಿ ಆಯ್ಕೆ ತೆಗೆಯಲಾಗಿದೆ';

  @override
  String sessionChoiceSelected(String title) {
    return 'ಆಯ್ಕೆ ಮಾಡಲಾಗಿದೆ, $title';
  }

  @override
  String sessionChoiceNotSelected(String title) {
    return 'ಆಯ್ಕೆ ಮಾಡಿಲ್ಲ, $title';
  }

  @override
  String sessionClassNumbered(String number) {
    return 'ತರಗತಿ $number';
  }

  @override
  String get sessionUploadContextMissing =>
      'ಈ ತರಗತಿಯ ತರಗತಿ ಮತ್ತು ವಿಷಯವನ್ನು ನಿರ್ಧರಿಸಲಾಗಲಿಲ್ಲ.';

  @override
  String get sessionUploadSuccess => 'ಅಪ್‌ಲೋಡ್ ಯಶಸ್ವಿಯಾಗಿದೆ.';

  @override
  String get sessionUploadInProgress => 'ಆಡಿಯೊ ಅಪ್‌ಲೋಡ್ ನಡೆಯುತ್ತಿದೆ';

  @override
  String get sessionPlayNowTitle => 'ಈಗ ಎಲ್ಲರಿಗೂ ಪ್ಲೇ ಮಾಡಬೇಕೇ?';

  @override
  String sessionPlayNowMessage(String title) {
    return '$title ಆಯ್ಕೆ ಮಾಡಲಾಗಿದೆ. ಈಗ ಎಲ್ಲಾ ಭಾಗವಹಿಸುವವರಿಗೂ ಪ್ಲೇ ಮಾಡಬೇಕೇ?';
  }

  @override
  String get sessionPlayNow => 'ಈಗ ಪ್ಲೇ ಮಾಡಿ';

  @override
  String get sessionNotYet => 'ಈಗ ಬೇಡ';

  @override
  String get sessionUploadEditTitle => 'ಶೀರ್ಷಿಕೆ ಬದಲಿಸಿ';

  @override
  String get sessionUploadEditDescription => 'ವಿವರಣೆ ಬದಲಿಸಿ';

  @override
  String get sessionUploadKey => 'ಅಪ್‌ಲೋಡ್';

  @override
  String get sessionCancel => 'ರದ್ದುಮಾಡಿ';

  @override
  String get classroomCheckUnreadable =>
      'ತರಗತಿ ಪರಿಶೀಲನೆಯ ಸ್ಥಿತಿಯನ್ನು ಓದಲಾಗಲಿಲ್ಲ. ಉತ್ತರಿಸುವ ಮೊದಲು ರಿಫ್ರೆಶ್ ಮಾಡಿ.';

  @override
  String get classroomCheckUnconfirmed =>
      'ತರಗತಿ ಪರಿಶೀಲನೆಯ ಕ್ರಿಯೆಯನ್ನು ದೃಢೀಕರಿಸಲಾಗಿಲ್ಲ. ಮತ್ತೆ ಪ್ರಯತ್ನಿಸುವ ಮೊದಲು ರಿಫ್ರೆಶ್ ಮಾಡಿ.';

  @override
  String get classroomCheckConfirmationUnreadable =>
      'ತರಗತಿ ಪರಿಶೀಲನೆಯ ದೃಢೀಕರಣವನ್ನು ಓದಲಾಗಲಿಲ್ಲ. ಮತ್ತೆ ಪ್ರಯತ್ನಿಸುವ ಮೊದಲು ರಿಫ್ರೆಶ್ ಮಾಡಿ.';

  @override
  String get classroomCheckOpenedForYou =>
      'ನಿಮ್ಮ ಶಿಕ್ಷಕರು ಒಂದು ಪ್ರಶ್ನೆ ಕೇಳಿದ್ದಾರೆ. ಉತ್ತರಿಸಲು 3 ಒತ್ತಿ.';

  @override
  String get classroomCheckHelp =>
      'ಖಾಸಗಿ ತರಗತಿ ಪರಿಶೀಲನೆ. ಅರ್ಥವಾಯಿತು, ದಯವಿಟ್ಟು ಮತ್ತೆ ಹೇಳಿ ಅಥವಾ ಸಹಾಯ ಬೇಕು. ಉತ್ತರಿಸಿದ ವಿದ್ಯಾರ್ಥಿ ಮತ್ತು ಸೆಷನ್ ಶಿಕ್ಷಕರು ಮಾತ್ರ ಉತ್ತರವನ್ನು ಓದಬಹುದು. ಇದಕ್ಕೆ ಅಂಕ ನೀಡುವುದಿಲ್ಲ. ಮುಂದಿನ ಪರಿಶೀಲನೆ, ಸೆಷನ್ ಮುಕ್ತಾಯ ಅಥವಾ ಸರ್ವರ್ ಮರುಪ್ರಾರಂಭದಲ್ಲಿ ಉತ್ತರಗಳು ಅಳಿಸಿಹೋಗುತ್ತವೆ. ದೃಢೀಕರಿಸಿದ ಸ್ಥಿತಿಗಾಗಿ ಓದಿ ಅಥವಾ ರಿಫ್ರೆಶ್ ಬಳಸಿ. ಧ್ವನಿ ನಿಲ್ಲಿಸಿ ಮತ್ತು ಹಿಂದೆ ಲಭ್ಯವಿದೆ.';

  @override
  String get classroomCheckTitle => 'ತರಗತಿ ಪರಿಶೀಲನೆ';

  @override
  String get classroomCheckNewTitle => 'ಹೊಸ ತರಗತಿ ಪರಿಶೀಲನೆ ತೆರೆಯಬೇಕೇ?';

  @override
  String get classroomCheckNewMessage =>
      'ಇದು ಹಿಂದಿನ ಪರಿಶೀಲನೆಯ ಎಲ್ಲಾ ಉತ್ತರಗಳನ್ನು ಅಳಿಸುತ್ತದೆ. ವಿದ್ಯಾರ್ಥಿಗಳು ಅರ್ಥವಾಯಿತು, ದಯವಿಟ್ಟು ಮತ್ತೆ ಹೇಳಿ ಅಥವಾ ಸಹಾಯ ಬೇಕು ಆಯ್ಕೆ ಮಾಡುತ್ತಾರೆ. ನೀವು ಮತ್ತು ಉತ್ತರಿಸಿದ ಪ್ರತಿ ವಿದ್ಯಾರ್ಥಿ ಮಾತ್ರ ಅವರ ಉತ್ತರವನ್ನು ಓದಬಹುದು. ಇದಕ್ಕೆ ಅಂಕ ನೀಡುವುದಿಲ್ಲ ಮತ್ತು ಶೈಕ್ಷಣಿಕ ದಾಖಲೆಯಾಗಿ ಇಡುವುದಿಲ್ಲ.';

  @override
  String get classroomCheckNewConfirm => 'ಹಿಂದಿನದನ್ನು ಅಳಿಸಿ ತೆರೆಯಿರಿ';

  @override
  String get classroomCheckNewCancel => 'ಈಗಿನ ಪರಿಶೀಲನೆಯನ್ನು ಉಳಿಸಿ';

  @override
  String get classroomCheckSending =>
      'ಕಳುಹಿಸಲಾಗುತ್ತಿದೆ. ದೃಢೀಕರಣಕ್ಕಾಗಿ ಕಾಯಲಾಗುತ್ತಿದೆ.';

  @override
  String get classroomCheckWaiting =>
      'ದೃಢೀಕರಣಕ್ಕಾಗಿ ಕಾಯಲಾಗುತ್ತಿದೆ. ಮತ್ತೆ ಕಳುಹಿಸಬೇಡಿ.';

  @override
  String get sessionBackToClass => 'ತರಗತಿಗೆ ಹಿಂತಿರುಗಿ';

  @override
  String get classroomBackToSession => 'ಸೆಷನ್‌ಗೆ ಹಿಂತಿರುಗಿ';

  @override
  String get classroomBack => 'ಹಿಂದೆ';

  @override
  String get classroomCheckRead =>
      'ಪರಿಶೀಲನೆಯ ಸ್ಥಿತಿ ಮತ್ತು ದೃಢೀಕರಿಸಿದ ಉತ್ತರಗಳನ್ನು ಓದಿ';

  @override
  String get classroomCheckReadButton => 'ಸ್ಥಿತಿ ಮತ್ತು ಉತ್ತರಗಳನ್ನು ಓದಿ';

  @override
  String get classroomCheckRefresh =>
      'ಖಾಸಗಿ ಪರಿಶೀಲನೆಯ ಸ್ಥಿತಿಯನ್ನು ರಿಫ್ರೆಶ್ ಮಾಡಿ. ತರಗತಿ ಸಂಪರ್ಕ ಅಗತ್ಯವಿದೆ';

  @override
  String get classroomCheckRefreshButton => 'ಸರ್ವರ್‌ನಿಂದ ರಿಫ್ರೆಶ್ ಮಾಡಿ';

  @override
  String get classroomCheckOpenLabel =>
      'ಹೊಸ ಪರಿಶೀಲನೆ ತೆರೆಯಿರಿ. ಹಿಂದಿನ ಉತ್ತರಗಳನ್ನು ಅಳಿಸುವುದನ್ನು ದೃಢೀಕರಿಸಿ';

  @override
  String get classroomCheckOpenButton => 'ಹೊಸ ಪರಿಶೀಲನೆ ತೆರೆಯಿರಿ';

  @override
  String get classroomCheckCloseLabel =>
      'ಈ ಪರಿಶೀಲನೆಯನ್ನು ಮುಚ್ಚಿ. ಮುಂದಿನ ಪರಿಶೀಲನೆ ಅಥವಾ ಸೆಷನ್ ಮುಕ್ತಾಯದವರೆಗೆ ಈಗಿನ ಫಲಿತಾಂಶಗಳನ್ನು ಉಳಿಸಿ';

  @override
  String get classroomCheckCloseButton => 'ಪರಿಶೀಲನೆ ಮುಚ್ಚಿ';

  @override
  String classroomCheckAnswer(String choice) {
    return '$choice. ನಿಮ್ಮ ಖಾಸಗಿ, ಅಂಕರಹಿತ ಉತ್ತರವನ್ನು ಕಳುಹಿಸಿ ಅಥವಾ ಬದಲಿಸಿ';
  }

  @override
  String get sessionStopSpeech => 'ಧ್ವನಿ ನಿಲ್ಲಿಸಿ';

  @override
  String get classroomChoiceUnderstood => 'ಅರ್ಥವಾಯಿತು';

  @override
  String get classroomChoiceRepeat => 'ದಯವಿಟ್ಟು ಮತ್ತೆ ಹೇಳಿ';

  @override
  String get classroomChoiceHelp => 'ಸಹಾಯ ಬೇಕು';

  @override
  String get classroomCheckNone =>
      'ಕೊನೆಯದಾಗಿ ಪಡೆದ ತರಗತಿ ಸ್ಥಿತಿಯಲ್ಲಿ ಯಾವುದೇ ಪರಿಶೀಲನೆ ಇಲ್ಲ. ಪರಿಶೀಲಿಸಲು ರಿಫ್ರೆಶ್ ಮಾಡಿ.';

  @override
  String get classroomCheckStatusOpen => 'ಪರಿಶೀಲನೆ ತೆರೆದಿದೆ.';

  @override
  String get classroomCheckStatusClosed =>
      'ಪರಿಶೀಲನೆ ಮುಚ್ಚಲಾಗಿದೆ. ಉತ್ತರಗಳನ್ನು ಬದಲಿಸಲು ಸಾಧ್ಯವಿಲ್ಲ.';

  @override
  String get classroomCheckNoResponseYet =>
      'ಇನ್ನೂ ಯಾವುದೇ ಉತ್ತರ ದೃಢೀಕರಿಸಲಾಗಿಲ್ಲ.';

  @override
  String classroomCheckYourResponse(String choice) {
    return 'ನಿಮ್ಮ ದೃಢೀಕರಿಸಿದ ಉತ್ತರ: $choice.';
  }

  @override
  String classroomCheckStudentSummary(String status, String response) {
    return '$status $response ನೀವು ಮತ್ತು ಸೆಷನ್ ಶಿಕ್ಷಕರು ಮಾತ್ರ ನಿಮ್ಮ ಉತ್ತರವನ್ನು ಓದಬಹುದು. ಇದಕ್ಕೆ ಅಂಕ ನೀಡುವುದಿಲ್ಲ.';
  }

  @override
  String classroomCheckLabelValue(String label, String value) {
    return '$label: $value';
  }

  @override
  String get classroomCheckNoResponses => 'ಇನ್ನೂ ಯಾವುದೇ ಉತ್ತರಗಳಿಲ್ಲ.';

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
          '$status $count ವಿದ್ಯಾರ್ಥಿಗಳು ಉತ್ತರಿಸಿದ್ದಾರೆ. $counts. $named ಉತ್ತರಗಳು ನಿಮಗೆ ಮತ್ತು ಉತ್ತರಿಸಿದ ಪ್ರತಿ ವಿದ್ಯಾರ್ಥಿಗೆ ಮಾತ್ರ ಖಾಸಗಿಯಾಗಿವೆ, ಮತ್ತು ಅವು ಅಂಕಗಳಲ್ಲ.',
    );
    return '$_temp0';
  }

  @override
  String get classroomOnlyTeacherAcknowledges =>
      'ಸೆಷನ್ ಶಿಕ್ಷಕರು ಮಾತ್ರ ಎತ್ತಿದ ಕೈಯನ್ನು ಸ್ವೀಕರಿಸಬಹುದು.';

  @override
  String get classroomHandChanged =>
      'ಆಯ್ಕೆ ಮಾಡಿದ ಕೈ ಬದಲಾಗಿದೆ. ಸರದಿಯನ್ನು ಮತ್ತೆ ಓದಿ.';

  @override
  String get classroomAckUnconfirmed =>
      'ಕೈ ಸ್ವೀಕಾರವನ್ನು ದೃಢೀಕರಿಸಲಾಗಿಲ್ಲ. ಮತ್ತೆ ಪ್ರಯತ್ನಿಸುವ ಮೊದಲು ಸರದಿಯನ್ನು ಓದಿ.';

  @override
  String get classroomAckUnreadable =>
      'ಕೈ ಸ್ವೀಕಾರವನ್ನು ಓದಲಾಗಲಿಲ್ಲ. ಮತ್ತೆ ಪ್ರಯತ್ನಿಸುವ ಮೊದಲು ಸರದಿಯನ್ನು ಪರಿಶೀಲಿಸಿ.';

  @override
  String classroomAcknowledgedChanged(String name) {
    return '$name ಅವರನ್ನು ಮೊದಲೇ ಸ್ವೀಕರಿಸಲಾಗಿದೆ. ಅದರ ನಂತರ ಅವರ ಕೈ ಬದಲಾಗಿದೆ; ಸರದಿಯನ್ನು ಮತ್ತೆ ಓದಿ. ಅವರ ಮೈಕ್ರೊಫೋನ್ ಬದಲಾಯಿಸಲಾಗಿಲ್ಲ.';
  }

  @override
  String classroomAcknowledged(String name) {
    return '$name ಅವರನ್ನು ಸ್ವೀಕರಿಸಲಾಗಿದೆ. ಆಯ್ಕೆ ಮಾಡಿದ ಕೈ ಇಳಿಸಲಾಗಿದೆ. ಅವರ ಮೈಕ್ರೊಫೋನ್ ಬದಲಾಯಿಸಲಾಗಿಲ್ಲ.';
  }

  @override
  String get classroomHandsHelp =>
      'ಎತ್ತಿದ ಕೈಗಳು. ಕೊನೆಯದಾಗಿ ಪಡೆದ ತರಗತಿ ಸ್ಥಿತಿಗಾಗಿ ಸಾರಾಂಶ ಓದಿ. ಹಿಂದಿನ ಮತ್ತು ಮುಂದಿನ ಎತ್ತಿದ ಕೈಯನ್ನು ಬದಲಿಸದೆ ಆಯ್ಕೆ ಮಾಡುತ್ತವೆ. ಸ್ವೀಕರಿಸಿ ಸರ್ವರ್ ದೃಢೀಕರಣದ ನಂತರ ಆಯ್ಕೆ ಮಾಡಿದ ಕೈಯನ್ನು ಮಾತ್ರ ಇಳಿಸುತ್ತದೆ. ಇದು ಯಾರನ್ನೂ ಎಂದಿಗೂ ಅನ್‌ಮ್ಯೂಟ್ ಮಾಡುವುದಿಲ್ಲ. ಕ್ರಮ ತಿಳಿಯದ ಹಳೆಯ ಕೈಗಳನ್ನು ಪ್ರತ್ಯೇಕವಾಗಿ ಗುರುತಿಸಲಾಗುತ್ತದೆ.';

  @override
  String get classroomConsoleHelp =>
      'ತರಗತಿ ಕನ್ಸೋಲ್. ಕೊನೆಯದಾಗಿ ಪಡೆದ ತರಗತಿ ಸ್ಥಿತಿಗಾಗಿ ಸಾರಾಂಶ ಓದಿ. ಹಿಂದಿನ ಮತ್ತು ಮುಂದಿನ ಎತ್ತಿದ ಕೈಯನ್ನು ಬದಲಿಸದೆ ಆಯ್ಕೆ ಮಾಡುತ್ತವೆ. ಸ್ವೀಕರಿಸಿ ಸರ್ವರ್ ದೃಢೀಕರಣದ ನಂತರ ಆಯ್ಕೆ ಮಾಡಿದ ಕೈಯನ್ನು ಮಾತ್ರ ಇಳಿಸುತ್ತದೆ. ಇದು ಯಾರನ್ನೂ ಎಂದಿಗೂ ಅನ್‌ಮ್ಯೂಟ್ ಮಾಡುವುದಿಲ್ಲ. ಕ್ರಮ ತಿಳಿಯದ ಹಳೆಯ ಕೈಗಳನ್ನು ಪ್ರತ್ಯೇಕವಾಗಿ ಗುರುತಿಸಲಾಗುತ್ತದೆ.';

  @override
  String get classroomHandsTitle => 'ಎತ್ತಿದ ಕೈಗಳು';

  @override
  String get classroomNoHands =>
      'ಕೊನೆಯದಾಗಿ ಪಡೆದ ತರಗತಿ ಸ್ಥಿತಿಯಲ್ಲಿ ಯಾವುದೇ ಎತ್ತಿದ ಕೈಗಳಿಲ್ಲ.';

  @override
  String classroomSelectedGone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'ಆಯ್ಕೆ ಮಾಡಿದ ಕೈ ಈಗ ಸರದಿಯಲ್ಲಿ ಇಲ್ಲ. $count ಎತ್ತಿದ ಕೈಗಳು ಉಳಿದಿವೆ. ಕೈ ಆಯ್ಕೆ ಮಾಡಲು ಮುಂದಿನ ಅಥವಾ ಹಿಂದಿನ ಬಳಸಿ.',
      one:
          'ಆಯ್ಕೆ ಮಾಡಿದ ಕೈ ಈಗ ಸರದಿಯಲ್ಲಿ ಇಲ್ಲ. 1 ಎತ್ತಿದ ಕೈ ಉಳಿದಿದೆ. ಕೈ ಆಯ್ಕೆ ಮಾಡಲು ಮುಂದಿನ ಅಥವಾ ಹಿಂದಿನ ಬಳಸಿ.',
    );
    return '$_temp0';
  }

  @override
  String classroomConsoleSelectedGone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'ಆಯ್ಕೆ ಮಾಡಿದ ಕೈ ಈಗ ಸರದಿಯಲ್ಲಿ ಇಲ್ಲ. $count ಎತ್ತಿದ ಕೈಗಳು ಉಳಿದಿವೆ. ಕೈ ಆಯ್ಕೆ ಮಾಡಲು ಮುಂದಿನ ಅಥವಾ ಹಿಂದಿನ ಬಳಸಿ.',
    );
    return '$_temp0';
  }

  @override
  String classroomHandTitle(String position, String total, String name) {
    return '$total ರಲ್ಲಿ ಕೈ $position, $name, ಕಾಯುತ್ತಿದ್ದಾರೆ';
  }

  @override
  String classroomParticipantNumbered(String id) {
    return 'ಭಾಗವಹಿಸುವವರು $id';
  }

  @override
  String get classroomKnownOrder => 'ಸರ್ವರ್ ದಾಖಲಿಸಿದ ಸರದಿ ಕ್ರಮ.';

  @override
  String get classroomUnknownOrder =>
      'ಕೈ ಎತ್ತಿದ ಮೂಲ ಕ್ರಮ ತಿಳಿದಿಲ್ಲ; ಕ್ರಮ ತಿಳಿದಿರುವ ಕೈಗಳ ಮೊದಲು ತೋರಿಸಲಾಗಿದೆ.';

  @override
  String get classroomReportedMuted =>
      'ಮೈಕ್ರೊಫೋನ್ ಮ್ಯೂಟ್ ಆಗಿದೆ ಎಂದು ವರದಿಯಾಗಿದೆ.';

  @override
  String get classroomReportedUnmuted =>
      'ಮೈಕ್ರೊಫೋನ್ ಅನ್‌ಮ್ಯೂಟ್ ಆಗಿದೆ ಎಂದು ವರದಿಯಾಗಿದೆ; ಇದು ಮಾತನಾಡುತ್ತಿರುವುದಕ್ಕೆ ಪುರಾವೆಯಲ್ಲ.';

  @override
  String get classroomNoHandsShort => 'ಎತ್ತಿದ ಕೈಗಳಿಲ್ಲ';

  @override
  String get classroomNoHandSelected => 'ಯಾವುದೇ ಕೈ ಆಯ್ಕೆ ಮಾಡಿಲ್ಲ';

  @override
  String classroomLowering(String name) {
    return '$name ಅವರ ಕೈ ಇಳಿಸಲಾಗುತ್ತಿದೆ. ಸರ್ವರ್‌ಗಾಗಿ ಕಾಯಲಾಗುತ್ತಿದೆ.';
  }

  @override
  String classroomLoweredLast(String name) {
    return '$name ಅವರ ಕೈ ಇಳಿಸಲಾಗಿದೆ. ಕೈ ಸರದಿ ಈಗ ಖಾಲಿಯಾಗಿದೆ.';
  }

  @override
  String classroomLoweredNext(String name, String next) {
    return '$name ಅವರ ಕೈ ಇಳಿಸಲಾಗಿದೆ. ಮುಂದಿನದು: $next.';
  }

  @override
  String get classroomNoSummary => 'ಇನ್ನೂ ಯಾವುದೇ ತರಗತಿ ಸಾರಾಂಶ ಲಭ್ಯವಿಲ್ಲ.';

  @override
  String get classroomReadSummary => 'ತರಗತಿ ಸಾರಾಂಶ ಓದಿ';

  @override
  String get classroomPreviousHand => 'ಹಿಂದಿನ ಎತ್ತಿದ ಕೈ';

  @override
  String get classroomReadHand => 'ಆಯ್ಕೆ ಮಾಡಿದ ಕೈಯನ್ನು ಓದಿ';

  @override
  String classroomReadHandLabel(String hand) {
    return 'ಆಯ್ಕೆ ಮಾಡಿದ ಕೈಯನ್ನು ಓದಿ. $hand';
  }

  @override
  String get classroomNextHand => 'ಮುಂದಿನ ಎತ್ತಿದ ಕೈ';

  @override
  String get classroomWaitingAck => 'ಕೈ ಸ್ವೀಕಾರಕ್ಕಾಗಿ ಕಾಯಲಾಗುತ್ತಿದೆ';

  @override
  String get classroomAckNoneSelected =>
      'ಆಯ್ಕೆ ಮಾಡಿದ ಕೈಯನ್ನು ಸ್ವೀಕರಿಸಿ ಇಳಿಸಿ. ಯಾವುದೇ ಕೈ ಆಯ್ಕೆ ಮಾಡಿಲ್ಲ';

  @override
  String classroomAckLabel(String name) {
    return '$name ಅವರ ಕೈ ಇಳಿಸಿ. ಎಂದಿಗೂ ಅನ್‌ಮ್ಯೂಟ್ ಮಾಡುವುದಿಲ್ಲ';
  }

  @override
  String get classroomAckSelectedLabel =>
      'ಆಯ್ಕೆ ಮಾಡಿದ ಕೈ ಇಳಿಸಿ. ಎಂದಿಗೂ ಅನ್‌ಮ್ಯೂಟ್ ಮಾಡುವುದಿಲ್ಲ';

  @override
  String get classroomAckButton => 'ಗಮನಿಸಿ ಮತ್ತು ಕೈ ಇಳಿಸಿ';

  @override
  String get classroomRepeatConsoleHelp => 'ಕನ್ಸೋಲ್ ಸಹಾಯವನ್ನು ಮತ್ತೆ ಕೇಳಿ';

  @override
  String get classroomConsoleSections =>
      'ತರಗತಿ ಸಾರಾಂಶ ಓದಿ, ಹಿಂದಿನ ಕೈ, ಆಯ್ಕೆ ಮಾಡಿದ ಕೈ ಓದಿ, ಮುಂದಿನ ಕೈ, ಕೈ ಗಮನಿಸಿ, ಧ್ವನಿ ನಿಲ್ಲಿಸಿ, ಸಹಾಯ ಮತ್ತು ಹಿಂದೆ. ಯಾವುದೇ ಕೈ ಅಥವಾ ಸಾರಾಂಶ ಲಭ್ಯವಿಲ್ಲದಿದ್ದರೆ, ಅವುಗಳ ನಿಯಂತ್ರಣ ಆಯ್ಕೆ ಮಾಡಿದಾಗ ಆ ಸ್ಥಿತಿಯನ್ನು ಓದುತ್ತದೆ';

  @override
  String get classroomSnapshotNote =>
      'ಎಣಿಕೆಗಳು ಕೊನೆಯದಾಗಿ ಸಿಕ್ಕ ಮಾಹಿತಿಯನ್ನು ತೋರಿಸುತ್ತವೆ, ಆಡಿಯೋ ತಲುಪಿದೆ ಎಂಬ ಖಚಿತತೆ ಇಲ್ಲ. ಯಾರು ಮಾತನಾಡುತ್ತಿದ್ದಾರೆ ಎಂದು ಗುರುತಿಸುವುದು ಲಭ್ಯವಿಲ್ಲ.';

  @override
  String get classroomWaitingAckNote =>
      'ಸರ್ವರ್ ದೃಢೀಕರಣಕ್ಕಾಗಿ ಕಾಯುತ್ತಿದೆ. ಯಾವುದೇ ಮೈಕ್ರೊಫೋನ್ ಬದಲಾಗುವುದಿಲ್ಲ.';

  @override
  String classroomSummaryParticipants(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ಭಾಗವಹಿಸುವವರು',
      one: '1 ಭಾಗವಹಿಸುವವರು',
    );
    return '$_temp0';
  }

  @override
  String classroomSummaryHands(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ಎತ್ತಿದ ಕೈಗಳು',
      one: '1 ಎತ್ತಿದ ಕೈ',
    );
    return '$_temp0';
  }

  @override
  String classroomSummaryMicrophones(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ಮೈಕ್ರೊಫೋನ್‌ಗಳು',
      one: '1 ಮೈಕ್ರೊಫೋನ್',
    );
    return '$_temp0';
  }

  @override
  String get classroomSummaryNobodySpeaking =>
      'ಯಾರೂ ಮಾತನಾಡುತ್ತಿರುವುದು ಕಂಡುಬಂದಿಲ್ಲ.';

  @override
  String classroomSummarySpeaking(String names) {
    return 'ಮಾತನಾಡುತ್ತಿರುವವರು: $names.';
  }

  @override
  String get classroomSummaryNoRecording =>
      'ಯಾವುದೇ ತರಗತಿ ರೆಕಾರ್ಡಿಂಗ್ ಆಯ್ಕೆ ಮಾಡಿಲ್ಲ.';

  @override
  String classroomSummaryRecordingPlaying(String title) {
    return 'ತರಗತಿ ರೆಕಾರ್ಡಿಂಗ್ $title. ಪ್ಲೇ ಮಾಡಲು ವಿನಂತಿಸಲಾಗಿದೆ.';
  }

  @override
  String classroomSummaryRecordingPaused(String title) {
    return 'ತರಗತಿ ರೆಕಾರ್ಡಿಂಗ್ $title. ವಿರಾಮಗೊಳಿಸಲಾಗಿದೆ.';
  }

  @override
  String get classroomSummaryPreviewActive =>
      'ಖಾಸಗಿ ಪೂರ್ವವೀಕ್ಷಣೆ ಈ ಫೋನ್‌ನಲ್ಲಿ ಮಾತ್ರ ನಡೆಯುತ್ತಿದೆ.';

  @override
  String get classroomSummaryPreviewStopped => 'ಖಾಸಗಿ ಪೂರ್ವವೀಕ್ಷಣೆ ನಿಂತಿದೆ.';

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
    return 'ಸ್ಥಳೀಯ ಸಂಪರ್ಕ: $connection. ಕೊನೆಯದಾಗಿ ಸಿಕ್ಕ ತರಗತಿ ಸ್ಥಿತಿ: $people, $hands, $muted ಮ್ಯೂಟ್ ಆಗಿವೆ ಎಂದು ವರದಿಯಾಗಿದೆ. ಇತರರು ಮರುಸಂಪರ್ಕಿಸುತ್ತಿರುವ ಎಣಿಕೆ ಲಭ್ಯವಿಲ್ಲ. $speaking $recording $preview ಮೈಕ್ರೊಫೋನ್ ಸ್ಥಿತಿ ಮತ್ತು ಸ್ವೀಕರಿಸಿದ ಪ್ಲೇ ವಿನಂತಿಗಳು ಯಾರಾದರೂ ಮಾತನಾಡಿದರು ಅಥವಾ ಆಡಿಯೋ ಕೇಳಿದರು ಎಂಬುದನ್ನು ಸಾಬೀತುಪಡಿಸುವುದಿಲ್ಲ.';
  }

  @override
  String get sessionToolsTitle => 'ಶಿಕ್ಷಕರ ಸಾಧನಗಳು';

  @override
  String get sessionInvite => 'ವಿದ್ಯಾರ್ಥಿಗಳನ್ನು ಆಹ್ವಾನಿಸಿ';

  @override
  String get sessionEndClass => 'ಎಲ್ಲರಿಗೂ ತರಗತಿ ಮುಗಿಸಿ, ದೃಢೀಕರಿಸಲು ಕೇಳುತ್ತದೆ';

  @override
  String get sessionPeopleTitle => 'ಭಾಗವಹಿಸುವವರು ಮತ್ತು ಎತ್ತಿದ ಕೈಗಳು';

  @override
  String sessionHandQueue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ಎತ್ತಿದ ಕೈಗಳ ಸಾಲು, $count ಕೈಗಳು ಕಾಯುತ್ತಿವೆ',
      one: 'ಎತ್ತಿದ ಕೈಗಳ ಸಾಲು, 1 ಕೈ ಕಾಯುತ್ತಿದೆ',
      zero: 'ಎತ್ತಿದ ಕೈಗಳ ಸಾಲು, ಯಾವ ಕೈಯೂ ಕಾಯುತ್ತಿಲ್ಲ',
    );
    return '$_temp0';
  }

  @override
  String sessionParticipantList(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ಭಾಗವಹಿಸುವವರ ಪಟ್ಟಿ, $count ಜನರು',
      one: 'ಭಾಗವಹಿಸುವವರ ಪಟ್ಟಿ, 1 ವ್ಯಕ್ತಿ',
    );
    return '$_temp0';
  }

  @override
  String get sessionSummaryChoice => 'ತರಗತಿ ಸಾರಾಂಶ ಕೇಳಿ';

  @override
  String get sessionParticipantsTitle => 'ಭಾಗವಹಿಸುವವರು';

  @override
  String get sessionMembersTitle => 'ತರಗತಿಯಲ್ಲಿರುವ ಜನರು';

  @override
  String get sessionMembersButton => '7: ತರಗತಿಯಲ್ಲಿ ಯಾರಿದ್ದಾರೆ';

  @override
  String sessionMembersLabel(String people) {
    return 'ತರಗತಿಯಲ್ಲಿ ಯಾರಿದ್ದಾರೆ. $people ವಿವರ ಕೇಳಲು ಒಬ್ಬ ವ್ಯಕ್ತಿಯನ್ನು ಆಯ್ಕೆ ಮಾಡಿ';
  }

  @override
  String get sessionHearDetails => 'ವಿವರ ಕೇಳಿ';

  @override
  String sessionMuteParticipant(String name) {
    return '$name ಅವರನ್ನು ಮ್ಯೂಟ್ ಮಾಡಿ';
  }

  @override
  String sessionRemoveParticipant(String name) {
    return '$name ಅವರನ್ನು ತರಗತಿಯಿಂದ ತೆಗೆದುಹಾಕಿ, ದೃಢೀಕರಿಸಲು ಕೇಳುತ್ತದೆ';
  }

  @override
  String get sessionParticipantGone => 'ಆ ಭಾಗವಹಿಸುವವರು ತರಗತಿಯಿಂದ ಹೊರಟಿದ್ದಾರೆ.';

  @override
  String get sessionNoOtherParticipants => 'ಇನ್ನೂ ಬೇರೆ ಯಾರೂ ತರಗತಿಯಲ್ಲಿ ಇಲ್ಲ.';

  @override
  String sessionTileRemoveMessage(String name) {
    return '$name ಅವರನ್ನು ಈ ತರಗತಿಯಿಂದ ತೆಗೆದುಹಾಕಿ ಅವರ ಡ್ಯಾಶ್‌ಬೋರ್ಡ್‌ಗೆ ಕಳುಹಿಸಲಾಗುತ್ತದೆ.';
  }

  @override
  String sessionTileRemoveFromSessionMessage(String name) {
    return '$name ಅವರನ್ನು ಈ ಸೆಷನ್‌ನಿಂದ ತೆಗೆದುಹಾಕಿ ಅವರ ಡ್ಯಾಶ್‌ಬೋರ್ಡ್‌ಗೆ ಕಳುಹಿಸಲಾಗುತ್ತದೆ.';
  }

  @override
  String sessionUnmuteParticipant(String name) {
    return '$name ಅವರನ್ನು ಅನ್‌ಮ್ಯೂಟ್ ಮಾಡಿ';
  }

  @override
  String sessionRemoveFromClass(String name) {
    return '$name ಅವರನ್ನು ತರಗತಿಯಿಂದ ತೆಗೆದುಹಾಕಿ';
  }

  @override
  String get sessionConnStateConnecting => 'ಸಂಪರ್ಕಿಸಲಾಗುತ್ತಿದೆ';

  @override
  String get sessionConnStateConnected => 'ಸಂಪರ್ಕಗೊಂಡಿದೆ';

  @override
  String get sessionConnStateInterrupted => 'ಸಂಪರ್ಕ ಅಡಚಣೆಯಾಗಿದೆ';

  @override
  String get sessionConnStateReconnecting => 'ಮರುಸಂಪರ್ಕಿಸಲಾಗುತ್ತಿದೆ';

  @override
  String get sessionConnStateSignInRequired => 'ಸೈನ್ ಇನ್ ಅಗತ್ಯವಿದೆ';

  @override
  String get sessionConnStateUnavailable => 'ತರಗತಿ ಲಭ್ಯವಿಲ್ಲ';

  @override
  String get sessionConnStateEnded => 'ತರಗತಿ ಮುಗಿದಿದೆ';

  @override
  String get sessionConnStateDisconnected => 'ಸಂಪರ್ಕ ಕಡಿತಗೊಂಡಿದೆ';

  @override
  String get sessionReconnectingToClass => 'ತರಗತಿಗೆ ಮರುಸಂಪರ್ಕಿಸಲಾಗುತ್ತಿದೆ.';

  @override
  String get sessionSignInRequiredLeave =>
      'ಸೈನ್ ಇನ್ ಅಗತ್ಯವಿದೆ. ಸೆಷನ್‌ನಿಂದ ಹೊರಬಂದು ಮತ್ತೆ ಸೈನ್ ಇನ್ ಮಾಡಿ.';

  @override
  String get sessionSignInExpiredLeave =>
      'ಸೈನ್ ಇನ್ ಅವಧಿ ಮುಗಿದಿದೆ. ಸೆಷನ್‌ನಿಂದ ಹೊರಬಂದು ಮತ್ತೆ ಸೈನ್ ಇನ್ ಮಾಡಿ.';

  @override
  String get sessionClassNoLongerAvailable =>
      'ಈ ತರಗತಿ ಇನ್ನು ಮುಂದೆ ನಿಮ್ಮ ಖಾತೆಗೆ ಲಭ್ಯವಿಲ್ಲ. ನೀವು ಹಿಂದೆ ಹೋಗಬಹುದು.';

  @override
  String get sessionServiceUnavailable => 'ತರಗತಿ ಸೇವೆ ಲಭ್ಯವಿಲ್ಲ.';

  @override
  String get sessionConnectionUnreadable =>
      'ತರಗತಿ ಸಂಪರ್ಕದ ಪ್ರತಿಕ್ರಿಯೆಯನ್ನು ಓದಲು ಆಗಲಿಲ್ಲ.';

  @override
  String get sessionConnectionNotConfirmed =>
      'ತರಗತಿ ಸಂಪರ್ಕವನ್ನು ದೃಢೀಕರಿಸಲಿಲ್ಲ.';

  @override
  String get sessionConnectionInterrupted => 'ತರಗತಿ ಸಂಪರ್ಕಕ್ಕೆ ಅಡಚಣೆಯಾಯಿತು.';

  @override
  String get sessionConnectionClosed => 'ತರಗತಿ ಸಂಪರ್ಕ ಮುಚ್ಚಿತು.';

  @override
  String get sessionConnectionCouldNotConfirm =>
      'ತರಗತಿ ಸಂಪರ್ಕವನ್ನು ದೃಢೀಕರಿಸಲು ಆಗಲಿಲ್ಲ.';

  @override
  String get sessionNoUpdates => 'ತರಗತಿಯಿಂದ ಯಾವುದೇ ಅಪ್‌ಡೇಟ್ ಬಂದಿಲ್ಲ.';

  @override
  String get sessionUpdateUnreadable => 'ಒಂದು ತರಗತಿ ಅಪ್‌ಡೇಟ್ ಓದಲು ಆಗಲಿಲ್ಲ.';

  @override
  String get sessionUpdateUnexpectedFormat =>
      'ಒಂದು ತರಗತಿ ಅಪ್‌ಡೇಟ್ ಅನಿರೀಕ್ಷಿತ ರೂಪದಲ್ಲಿತ್ತು.';

  @override
  String get sessionUpdateTypeUnreadable =>
      'ಒಂದು ತರಗತಿ ಅಪ್‌ಡೇಟ್‌ನ ಪ್ರಕಾರ ಓದಲು ಆಗಲಿಲ್ಲ.';

  @override
  String get sessionParticipationNotConfirmed =>
      'ತರಗತಿಯಲ್ಲಿ ನಿಮ್ಮ ಭಾಗವಹಿಸುವಿಕೆ ದೃಢೀಕರಿಸಲಾಗಿಲ್ಲ.';

  @override
  String get sessionConnectedToClass => 'ತರಗತಿಗೆ ಸಂಪರ್ಕಗೊಂಡಿದೆ.';

  @override
  String get sessionSignInChangedShort =>
      'ನಿಮ್ಮ ಸೈನ್ ಇನ್ ಬದಲಾಗಿದೆ. ಮತ್ತೆ ಸೈನ್ ಇನ್ ಮಾಡಿ.';

  @override
  String get sessionRemovedGoBack =>
      'ನಿಮ್ಮನ್ನು ತರಗತಿಯಿಂದ ತೆಗೆದುಹಾಕಲಾಗಿದೆ. ನೀವು ಹಿಂದೆ ಹೋಗಬಹುದು.';

  @override
  String sessionConnectionLostReconnecting(String reason) {
    return '$reason ಮರುಸಂಪರ್ಕಿಸಲಾಗುತ್ತಿದೆ. ಹಿಂದಿನ ಕ್ರಿಯೆಗಳನ್ನು ತಾನಾಗಿಯೇ ಮತ್ತೆ ಕಳುಹಿಸಲಾಗುವುದಿಲ್ಲ.';
  }

  @override
  String get sessionActionClassUnavailable =>
      'ತರಗತಿ ಲಭ್ಯವಿಲ್ಲ. ಈ ಕ್ರಿಯೆಯನ್ನು ಕಳುಹಿಸಲಾಗಿಲ್ಲ.';

  @override
  String get sessionActionSessionChanged =>
      'ಸೆಷನ್ ಬದಲಾಗಿದೆ. ಈ ಕ್ರಿಯೆಯನ್ನು ಕಳುಹಿಸಲಾಗಿಲ್ಲ.';

  @override
  String get sessionActionSignInRequired =>
      'ಸೈನ್ ಇನ್ ಅಗತ್ಯವಿದೆ. ಈ ಕ್ರಿಯೆಯನ್ನು ಕಳುಹಿಸಲಾಗಿಲ್ಲ.';

  @override
  String get sessionActionConnectionChanged =>
      'ದೃಢೀಕರಣಕ್ಕೆ ಮೊದಲೇ ಸಂಪರ್ಕ ಬದಲಾಯಿತು. ಕ್ರಿಯೆ ತಲುಪಿರಬಹುದು; ಮತ್ತೆ ಪ್ರಯತ್ನಿಸುವ ಮೊದಲು ಅದರ ಸ್ಥಿತಿ ಪರಿಶೀಲಿಸಿ.';

  @override
  String get sessionAccountChangedLeave =>
      'ನಿಮ್ಮ ಖಾತೆ ಬದಲಾಗಿದೆ. ಸೆಷನ್‌ನಿಂದ ಹೊರಬಂದು ಮತ್ತೆ ಸೈನ್ ಇನ್ ಮಾಡಿ.';

  @override
  String get sessionActionAccountChanged =>
      'ಕ್ರಿಯೆ ದೃಢೀಕರಿಸುವ ಮೊದಲೇ ನಿಮ್ಮ ಖಾತೆ ಬದಲಾಯಿತು.';

  @override
  String get sessionActionNotConfirmedByClass =>
      'ತರಗತಿ ಈ ಕ್ರಿಯೆಯನ್ನು ದೃಢೀಕರಿಸಲಿಲ್ಲ. ಮತ್ತೆ ಪ್ರಯತ್ನಿಸುವ ಮೊದಲು ಅದರ ಸ್ಥಿತಿ ಪರಿಶೀಲಿಸಿ.';

  @override
  String get sessionActionMayHaveReached =>
      'ಕ್ರಿಯೆ ದೃಢೀಕರಿಸಲಾಗಿಲ್ಲ. ಅದು ತರಗತಿಯನ್ನು ತಲುಪಿರಬಹುದು. ಮತ್ತೆ ಪ್ರಯತ್ನಿಸುವ ಮೊದಲು ಅದರ ಸ್ಥಿತಿ ಪರಿಶೀಲಿಸಿ.';

  @override
  String get sessionRtcConnectionClosed => 'ಸಂಪರ್ಕ ಮುಚ್ಚಿತು.';

  @override
  String get sessionRtcNetworkError => 'ನೆಟ್‌ವರ್ಕ್ ದೋಷ';

  @override
  String sessionRtcConnected(String id) {
    return 'ಸೆಷನ್ $id ಗೆ ಸಂಪರ್ಕಗೊಂಡಿದೆ';
  }

  @override
  String sessionRtcParticipantJoined(String id) {
    return 'ಭಾಗವಹಿಸುವವರು $id ಸೇರಿದರು.';
  }

  @override
  String sessionRtcParticipantLeft(String id) {
    return 'ಭಾಗವಹಿಸುವವರು $id ಹೊರಟರು.';
  }

  @override
  String sessionRtcParticipantMuted(String id) {
    return 'ಭಾಗವಹಿಸುವವರು $id ಈಗ ಮ್ಯೂಟ್ ಆಗಿದ್ದಾರೆ';
  }

  @override
  String sessionRtcParticipantUnmuted(String id) {
    return 'ಭಾಗವಹಿಸುವವರು $id ಈಗ ಅನ್‌ಮ್ಯೂಟ್ ಆಗಿದ್ದಾರೆ';
  }

  @override
  String sessionRtcMessage(String text) {
    return 'ಸಂದೇಶ: $text';
  }

  @override
  String sessionRtcTeacherPlaying(String id) {
    return 'ಶಿಕ್ಷಕರು ಆಡಿಯೋ $id ಪ್ಲೇ ಮಾಡಲು ಆರಂಭಿಸಿದರು';
  }

  @override
  String sessionRtcAudioStarted(String id) {
    return 'ಭಾಗವಹಿಸುವವರು $id ಅವರ ಆಡಿಯೋ ಸ್ಟ್ರೀಮ್ ಆರಂಭವಾಯಿತು';
  }

  @override
  String librarySpeedTimes(String speed) {
    return '$speed ಪಟ್ಟು';
  }

  @override
  String get libraryNoClassForSession =>
      'ಈ ಸೆಷನ್ ಹೆಸರಿನಲ್ಲಿ ಯಾವುದೇ ತರಗತಿ ಸಿಗಲಿಲ್ಲ.';

  @override
  String librarySubjectFilterLabel(String name) {
    return 'ವಿಷಯ ಫಿಲ್ಟರ್: $name. ಬದಲಾಯಿಸಲು ಕೀ 2, ಅಥವಾ ಎಡ ಅಥವಾ ಬಲ';
  }

  @override
  String librarySubjectFilterLabelPosition(
    String name,
    String index,
    String total,
  ) {
    return 'ವಿಷಯ ಫಿಲ್ಟರ್: $name, $total ರಲ್ಲಿ $index. ಬದಲಾಯಿಸಲು ಕೀ 2, ಅಥವಾ ಎಡ ಅಥವಾ ಬಲ';
  }

  @override
  String get libraryAllSubjects => 'ಎಲ್ಲಾ ವಿಷಯಗಳು';

  @override
  String libraryRestoredToPlaylist(String title) {
    return '$title ಮತ್ತೆ ಪ್ಲೇಲಿಸ್ಟ್‌ನಲ್ಲಿದೆ.';
  }

  @override
  String get librarySizeZero => '0 ಮೆಗಾಬೈಟ್';

  @override
  String get librarySizeTiny => '0.1 ಮೆಗಾಬೈಟ್‌ಗಿಂತ ಕಡಿಮೆ';

  @override
  String get librarySizeOne => '1 ಮೆಗಾಬೈಟ್';

  @override
  String librarySizeMegabytes(String value) {
    return '$value ಮೆಗಾಬೈಟ್';
  }

  @override
  String libraryStorageUsed(String size, String limit) {
    return '$limit ರಲ್ಲಿ $size ಬಳಸಲಾಗಿದೆ.';
  }

  @override
  String libraryRecordingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ರೆಕಾರ್ಡಿಂಗ್‌ಗಳು',
      one: '1 ರೆಕಾರ್ಡಿಂಗ್',
    );
    return '$_temp0';
  }

  @override
  String libraryPlayingBrief(String title, String position) {
    return '$title, $position ನಿಂದ ಪ್ಲೇ ಆಗುತ್ತಿದೆ.';
  }

  @override
  String libraryPlayingDetailed(String title, String position, String speed) {
    return '$title, $position ನಿಂದ ಪ್ಲೇ ಆಗುತ್ತಿದೆ, ವೇಗ $speed.';
  }

  @override
  String libraryPausedAt(String position) {
    return '$position ನಲ್ಲಿ ವಿರಾಮಗೊಳಿಸಲಾಗಿದೆ.';
  }

  @override
  String get libraryPlayerStateNothing => 'ಏನೂ ಪ್ಲೇ ಆಗುತ್ತಿಲ್ಲ.';

  @override
  String libraryPlayerStatePlaying(
    String title,
    String position,
    String speed,
  ) {
    return '$title ಪ್ಲೇ ಆಗುತ್ತಿದೆ, $position, ವೇಗ $speed.';
  }

  @override
  String libraryPlayerStatePaused(String title, String position, String speed) {
    return '$title ವಿರಾಮಗೊಂಡಿದೆ, $position, ವೇಗ $speed.';
  }

  @override
  String librarySpeedChanged(String speed) {
    return 'ವೇಗ $speed.';
  }

  @override
  String get librarySlowest => 'ಈಗಾಗಲೇ ಅತಿ ಕಡಿಮೆ ವೇಗದಲ್ಲಿದೆ.';

  @override
  String get libraryFastest => 'ಈಗಾಗಲೇ ಅತಿ ಹೆಚ್ಚು ವೇಗದಲ್ಲಿದೆ.';

  @override
  String get libraryNoLessonLoaded =>
      'ಯಾವುದೇ ಪಾಠ ಲೋಡ್ ಆಗಿಲ್ಲ. ಮೊದಲು ಪ್ಲೇ ಮಾಡಲು ಒಂದು ಪಾಠ ಆಯ್ಕೆ ಮಾಡಿ.';

  @override
  String libraryNoLessonPlayingPress(String key) {
    return 'ಯಾವುದೇ ಪಾಠ ಪ್ಲೇ ಆಗುತ್ತಿಲ್ಲ. ಮೊದಲ ಪಾಠ ಪ್ಲೇ ಮಾಡಲು $key ಒತ್ತಿ.';
  }

  @override
  String get libraryNothingIsPlaying => 'ಏನೂ ಪ್ಲೇ ಆಗುತ್ತಿಲ್ಲ.';

  @override
  String get libraryNothingPlayingHint =>
      'ಏನೂ ಪ್ಲೇ ಆಗುತ್ತಿಲ್ಲ. ಒಂದು ಪಾಠ ಆಯ್ಕೆ ಮಾಡಿ ಅಥವಾ 5 ಒತ್ತಿ.';

  @override
  String libraryStopped(String title) {
    return '$title ನಿಲ್ಲಿಸಲಾಗಿದೆ.';
  }

  @override
  String libraryFinished(String title) {
    return '$title ಮುಗಿದಿದೆ.';
  }

  @override
  String get libraryWaitForPlayer => 'ದಯವಿಟ್ಟು ಪಾಠ ಪ್ಲೇಯರ್‌ಗಾಗಿ ಕಾಯಿರಿ.';

  @override
  String get librarySeekFailed =>
      'ಪಾಠದ ಆ ಸ್ಥಾನಕ್ಕೆ ಹೋಗಲು ಆಗಲಿಲ್ಲ. ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get librarySpeedFailed =>
      'ಪ್ಲೇ ವೇಗ ಬದಲಾಯಿಸಲು ಆಗಲಿಲ್ಲ. ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String libraryPlayFailed(String title) {
    return '$title ಪ್ಲೇ ಮಾಡಲು ಆಗಲಿಲ್ಲ. ನಿಮ್ಮ ಸಂಪರ್ಕ ಪರಿಶೀಲಿಸಿ, ನಂತರ ಅದನ್ನು ಮತ್ತೆ ಆಯ್ಕೆ ಮಾಡಿ.';
  }

  @override
  String get libraryCheckingOfflineAccess =>
      'ಇಂಟರ್ನೆಟ್ ಲಭ್ಯವಿಲ್ಲ. ನಿಮ್ಮ ಉಳಿಸಿದ ಆಫ್‌ಲೈನ್ ಪ್ರವೇಶವನ್ನು ಪರಿಶೀಲಿಸಲಾಗುತ್ತಿದೆ.';

  @override
  String get libraryLessonGone =>
      'ಈ ಪಾಠ ಇನ್ನು ಮುಂದೆ ಲಭ್ಯವಿಲ್ಲ. ನಿಮ್ಮ ಉಳಿಸಿದ ಪ್ರಗತಿ ಮತ್ತು ಬುಕ್‌ಮಾರ್ಕ್‌ಗಳನ್ನು ಇಟ್ಟುಕೊಳ್ಳಲಾಗಿದೆ.';

  @override
  String librarySeekLabel(String position) {
    return 'ಪಾಠದ ಸ್ಥಾನ $position. 10 ಸೆಕೆಂಡ್ ಸರಿಯಲು ಎಡ ಅಥವಾ ಬಲ ಬಳಸಿ.';
  }

  @override
  String libraryRewindLabel(String key) {
    return '10 ಸೆಕೆಂಡ್ ಹಿಂದೆ, ಕೀ $key';
  }

  @override
  String libraryForwardLabel(String key) {
    return '10 ಸೆಕೆಂಡ್ ಮುಂದೆ, ಕೀ $key';
  }

  @override
  String librarySlowerLabel(String key, String speed) {
    return 'ನಿಧಾನ, ಕೀ $key. ಈಗ $speed';
  }

  @override
  String libraryFasterLabel(String key, String speed) {
    return 'ವೇಗ ಹೆಚ್ಚಿಸಿ, ಕೀ $key. ಈಗ $speed';
  }

  @override
  String libraryPauseLabel(String title, String key) {
    return '$title ವಿರಾಮಗೊಳಿಸಿ, ಕೀ $key';
  }

  @override
  String libraryPlayLabel(String title, String key) {
    return '$title ಪ್ಲೇ ಮಾಡಿ, ಕೀ $key';
  }

  @override
  String libraryResumeLabel(String title, String key) {
    return '$title ಮುಂದುವರಿಸಿ, ಕೀ $key';
  }

  @override
  String libraryStopLabel(String title, String key) {
    return '$title ನಿಲ್ಲಿಸಿ, ಕೀ $key';
  }

  @override
  String libraryPlayerKeyHelp(
    String rewind,
    String playPause,
    String forward,
    String slower,
    String faster,
  ) {
    return '10 ಸೆಕೆಂಡ್ ಹಿಂದೆ ಹೋಗಲು $rewind, ಪ್ಲೇ ಅಥವಾ ವಿರಾಮಕ್ಕೆ $playPause, 10 ಸೆಕೆಂಡ್ ಮುಂದೆ ಹೋಗಲು $forward, ನಿಧಾನಕ್ಕೆ $slower ಮತ್ತು ವೇಗಕ್ಕೆ $faster ಒತ್ತಿ.';
  }

  @override
  String libraryBookmarkCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ಬುಕ್‌ಮಾರ್ಕ್‌ಗಳು',
      one: '1 ಬುಕ್‌ಮಾರ್ಕ್',
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
    return '$title. ಸ್ಥಾನ $position. ವೇಗ $speed. $bookmarks. A-B ಪುನರಾವರ್ತನೆ $repeat. ಪ್ರಗತಿ ಉಳಿಸುವಿಕೆ $saving.';
  }

  @override
  String libraryReadStatusLabel(String status) {
    return 'ಕಲಿಕೆಯ ಸ್ಥಿತಿ ಓದಿ. $status';
  }

  @override
  String libraryAddBookmarkLabel(String time) {
    return '$time ನಲ್ಲಿ ಬುಕ್‌ಮಾರ್ಕ್ ಸೇರಿಸಿ';
  }

  @override
  String libraryBookmarksLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ಬುಕ್‌ಮಾರ್ಕ್‌ಗಳು. $count ಉಳಿಸಿದ ಸ್ಥಾನಗಳು',
      one: 'ಬುಕ್‌ಮಾರ್ಕ್‌ಗಳು. 1 ಉಳಿಸಿದ ಸ್ಥಾನ',
    );
    return '$_temp0';
  }

  @override
  String libraryNotesLabel(String time) {
    return '$time ನಲ್ಲಿ ಖಾಸಗಿ ಅಧ್ಯಯನ ಟಿಪ್ಪಣಿಗಳು. ತೆರೆಯುವ ಮೊದಲು ಪಾಠವನ್ನು ವಿರಾಮಗೊಳಿಸುತ್ತದೆ';
  }

  @override
  String get libraryRepeatStartLabel =>
      'ಈಗಿನ ಸ್ಥಾನದಲ್ಲಿ ಪುನರಾವರ್ತನೆಯ ಆರಂಭ A ಹೊಂದಿಸಿ';

  @override
  String get libraryRepeatEndLabel =>
      'ಆರಂಭ A ನಂತರ ಪುನರಾವರ್ತನೆಯ ಅಂತ್ಯ B ಹೊಂದಿಸಿ';

  @override
  String get libraryRepeatTurnOffLabel => 'A-B ಪುನರಾವರ್ತನೆ ಆಫ್ ಮಾಡಿ';

  @override
  String get libraryRepeatTurnOnLabel => 'A-B ಪುನರಾವರ್ತನೆ ಆನ್ ಮಾಡಿ';

  @override
  String get libraryRepeatClearLabel =>
      'ಉಳಿಸಿದ A-B ಪುನರಾವರ್ತನೆ ಸ್ಥಾನಗಳನ್ನು ಅಳಿಸಿ';

  @override
  String libraryRetryLabel(String issue) {
    return 'ಕಲಿಕೆಯ ಪ್ರಗತಿ ಉಳಿಸಲು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ. $issue';
  }

  @override
  String libraryBookmarkSaved(String time) {
    return '$time ನಲ್ಲಿ ಬುಕ್‌ಮಾರ್ಕ್ ಉಳಿಸಲಾಗಿದೆ.';
  }

  @override
  String libraryRepeatStartSet(String time) {
    return 'ಪುನರಾವರ್ತನೆಯ ಆರಂಭ $time ನಲ್ಲಿ ಹೊಂದಿಸಲಾಗಿದೆ.';
  }

  @override
  String libraryRepeatEndSetBrief(String time) {
    return 'ಪುನರಾವರ್ತನೆಯ ಅಂತ್ಯ $time ನಲ್ಲಿ ಹೊಂದಿಸಲಾಗಿದೆ.';
  }

  @override
  String libraryRepeatEndSetDetailed(String time) {
    return 'ಪುನರಾವರ್ತನೆಯ ಅಂತ್ಯ $time ನಲ್ಲಿ ಹೊಂದಿಸಲಾಗಿದೆ. ಮತ್ತೆ ಮತ್ತೆ ಪ್ಲೇ ಮಾಡಲು ಪುನರಾವರ್ತನೆ ಆನ್ ಆಯ್ಕೆ ಮಾಡಿ.';
  }

  @override
  String libraryRepeatState(String state) {
    return 'A-B ಪುನರಾವರ್ತನೆ $state.';
  }

  @override
  String get libraryRepeatCleared => 'A-B ಪುನರಾವರ್ತನೆ ಸ್ಥಾನಗಳನ್ನು ಅಳಿಸಲಾಗಿದೆ.';

  @override
  String get libraryProgressSaved => 'ಕಲಿಕೆಯ ಪ್ರಗತಿ ಉಳಿಸಲಾಗಿದೆ.';

  @override
  String get libraryActionFailed =>
      'ಪ್ಲೇಯರ್ ಈ ಕ್ರಿಯೆಯನ್ನು ಪೂರ್ಣಗೊಳಿಸಲು ಆಗಲಿಲ್ಲ. ಪ್ಲೇಬ್ಯಾಕ್ ಪರಿಶೀಲಿಸಿ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get libraryCheckPosition => 'ಪಾಠದ ಸ್ಥಾನ ಪರಿಶೀಲಿಸಿ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get libraryProgressUnavailableTitle => 'ಉಳಿಸಿದ ಪ್ರಗತಿ ಲಭ್ಯವಿಲ್ಲ';

  @override
  String libraryProgressUnavailable(String reason) {
    return '$reason ಉಳಿಸಿದ ಮಾಹಿತಿಯನ್ನು ಬದಲಾಯಿಸದೆ ಆರಂಭದಿಂದ ಕೇಳುವಿರಾ? ಮತ್ತೆ ಯಶಸ್ವಿಯಾಗಿ ಪ್ರಯತ್ನಿಸುವವರೆಗೆ ಉಳಿಸುವಿಕೆ ಆಫ್ ಆಗಿರುತ್ತದೆ.';
  }

  @override
  String get libraryListenFromBeginning => 'ಆರಂಭದಿಂದ ಕೇಳಿ';

  @override
  String get libraryBookmarkNameScreen =>
      'ಬುಕ್‌ಮಾರ್ಕ್‌ಗೆ ಹೆಸರು ನೀಡಿ. ಬದಲಾಯಿಸಲು ಓಕೆ ಒತ್ತಿ. ಮೇಲೆ ಅಥವಾ ಕೆಳಗೆ ಒತ್ತಿದರೆ ಬದಲಾವಣೆಯಿಂದ ಹೊರಬರುತ್ತದೆ.';

  @override
  String get libraryEnterBookmarkName => 'ಬುಕ್‌ಮಾರ್ಕ್ ಹೆಸರು ನಮೂದಿಸಿ.';

  @override
  String libraryBookmarkLabel(String label, String time) {
    return '$label. $time. ಬುಕ್‌ಮಾರ್ಕ್‌ಗೆ ಹೋಗಿ';
  }

  @override
  String libraryBookmarkJumped(String label, String time) {
    return '$label. ಸ್ಥಾನ $time.';
  }

  @override
  String libraryRemoveBookmarkLabel(String label) {
    return '$label ತೆಗೆದುಹಾಕಿ';
  }

  @override
  String libraryRemoveBookmarkQuestion(String label) {
    return '$label ತೆಗೆದುಹಾಕಬೇಕೇ? ಇದು ಪಾಠವನ್ನು ಅಥವಾ ಬೇರೆ ಯಾವುದೇ ಬುಕ್‌ಮಾರ್ಕ್ ಅನ್ನು ತೆಗೆದುಹಾಕುವುದಿಲ್ಲ.';
  }

  @override
  String libraryBookmarkRemoved(String label) {
    return '$label ತೆಗೆದುಹಾಕಲಾಗಿದೆ.';
  }

  @override
  String get libraryBookmarksScreen =>
      'ಬುಕ್‌ಮಾರ್ಕ್‌ಗಳು. ಹೋಗಲು ಒಂದು ಸ್ಥಾನ ಆಯ್ಕೆ ಮಾಡಿ. ಇದು ವಿರಾಮಗೊಂಡ ಪ್ಲೇಬ್ಯಾಕ್ ಅನ್ನು ಆರಂಭಿಸುವುದಿಲ್ಲ. ತೆಗೆದುಹಾಕುವ ಮೊದಲು ದೃಢೀಕರಣ ಕೇಳುತ್ತದೆ.';

  @override
  String get libraryNoRecordingsUpload =>
      'ಇನ್ನೂ ಯಾವುದೇ ರೆಕಾರ್ಡಿಂಗ್ ಇಲ್ಲ. ಆಡಿಯೋ ಅಪ್‌ಲೋಡ್ ಮಾಡಲು 2 ಒತ್ತಿ.';

  @override
  String libraryRecordingsLoaded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ರೆಕಾರ್ಡಿಂಗ್‌ಗಳು ಲೋಡ್ ಆಗಿವೆ.',
      one: '1 ರೆಕಾರ್ಡಿಂಗ್ ಲೋಡ್ ಆಗಿದೆ.',
    );
    return '$_temp0';
  }

  @override
  String get libraryLoadFailed =>
      'ರೆಕಾರ್ಡಿಂಗ್‌ಗಳನ್ನು ಲೋಡ್ ಮಾಡಲು ಆಗಲಿಲ್ಲ. ನಿಮ್ಮ ಇಂಟರ್ನೆಟ್ ಸಂಪರ್ಕ ಪರಿಶೀಲಿಸಿ, ನಂತರ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಲು 1 ಒತ್ತಿ.';

  @override
  String get libraryTitleRequired => 'ಶೀರ್ಷಿಕೆ ಅಗತ್ಯವಿದೆ.';

  @override
  String get libraryPickFailed =>
      'ಫೈಲ್ ತೆರೆಯಲು ಆಗಲಿಲ್ಲ. ಅದನ್ನು ಮತ್ತೆ ಆಯ್ಕೆ ಮಾಡಿ ನೋಡಿ.';

  @override
  String get libraryChooseWorkspaceFirst =>
      'ಆಡಿಯೋ ಅಪ್‌ಲೋಡ್ ಮಾಡುವ ಮೊದಲು ಶಿಕ್ಷಕರ ಡ್ಯಾಶ್‌ಬೋರ್ಡ್‌ನಲ್ಲಿ ಒಂದು ತರಗತಿ ಮತ್ತು ವಿಷಯದ ವರ್ಕ್‌ಸ್ಪೇಸ್ ಆಯ್ಕೆ ಮಾಡಿ.';

  @override
  String libraryUploadingBrief(String title) {
    return '$title ಅಪ್‌ಲೋಡ್ ಆಗುತ್ತಿದೆ.';
  }

  @override
  String libraryUploadingDetailed(String title) {
    return '$title ಅಪ್‌ಲೋಡ್ ಆಗುತ್ತಿದೆ. ಪ್ರತಿ 25 ಪ್ರತಿಶತಕ್ಕೆ ಪ್ರಗತಿ ಕೇಳಿಸುತ್ತದೆ.';
  }

  @override
  String libraryUploadingOnceDetailed(String title) {
    return '$title ಅಪ್‌ಲೋಡ್ ಆಗುತ್ತಿದೆ. ದಯವಿಟ್ಟು ಕಾಯಿರಿ; ಮುಗಿದಾಗ ನಿಮಗೆ ಕೇಳಿಸುತ್ತದೆ.';
  }

  @override
  String libraryUploadProgress(String title, String percent) {
    return '$title: $percent ಅಪ್‌ಲೋಡ್ ಆಗಿದೆ.';
  }

  @override
  String libraryUploaded(String title) {
    return '$title ಅಪ್‌ಲೋಡ್ ಆಗಿದೆ.';
  }

  @override
  String libraryUploadFailed(String title) {
    return '$title ಅಪ್‌ಲೋಡ್ ಮಾಡಲು ಆಗಲಿಲ್ಲ. ನಿಮ್ಮ ಸಂಪರ್ಕ ಪರಿಶೀಲಿಸಿ, ನಂತರ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಲು 3 ಒತ್ತಿ.';
  }

  @override
  String get libraryUploadNoSession =>
      'ಅಪ್‌ಲೋಡ್ ರದ್ದಾಗಿದೆ. ಕನಿಷ್ಠ ಒಂದು ಸೆಷನ್ ಆಯ್ಕೆ ಮಾಡಿ, ನಂತರ ಮತ್ತೆ ಆಡಿಯೋ ಸೇರಿಸಲು 3 ಒತ್ತಿ.';

  @override
  String get libraryUploadNoClass =>
      'ಸೆಷನ್‌ನ ತರಗತಿ ಮತ್ತು ವಿಷಯವನ್ನು ಗುರುತಿಸಲು ಆಗಲಿಲ್ಲ.';

  @override
  String get libraryFileUnreadable =>
      'ಫೈಲ್ ಓದಲು ಆಗಲಿಲ್ಲ. ಅದನ್ನು ಮತ್ತೆ ಆಯ್ಕೆ ಮಾಡಿ.';

  @override
  String libraryPreviewStopped(String title) {
    return '$title ಪೂರ್ವವೀಕ್ಷಣೆ ನಿಂತಿದೆ.';
  }

  @override
  String libraryPreviewing(String title) {
    return '$title ಖಾಸಗಿಯಾಗಿ ಪೂರ್ವವೀಕ್ಷಣೆ ಆಗುತ್ತಿದೆ.';
  }

  @override
  String get libraryPreviewFinished => 'ಪೂರ್ವವೀಕ್ಷಣೆ ಮುಗಿದಿದೆ.';

  @override
  String libraryPreviewFailed(String title) {
    return '$title ಪ್ಲೇ ಮಾಡಲು ಆಗಲಿಲ್ಲ. ನಿಮ್ಮ ಸಂಪರ್ಕ ಪರಿಶೀಲಿಸಿ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';
  }

  @override
  String get libraryNoActiveSession => 'ಯಾವುದೇ ಸಕ್ರಿಯ ಸೆಷನ್ ಇಲ್ಲ.';

  @override
  String librarySelectedForSession(String title) {
    return 'ಸೆಷನ್‌ಗಾಗಿ $title ಆಯ್ಕೆ ಮಾಡಲಾಗಿದೆ.';
  }

  @override
  String get librarySelectFailed =>
      'ಆಡಿಯೋ ಆಯ್ಕೆ ಮಾಡಲು ಆಗಲಿಲ್ಲ. ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get libraryClassPlayAccepted =>
      'ತರಗತಿಯಲ್ಲಿ ಪ್ಲೇ ಮಾಡುವ ವಿನಂತಿ ಸ್ವೀಕರಿಸಲಾಗಿದೆ.';

  @override
  String get libraryClassPlayFailed =>
      'ತರಗತಿಯಲ್ಲಿ ಪ್ಲೇ ಆರಂಭಿಸಲು ಆಗಲಿಲ್ಲ. ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get libraryClassPauseAccepted => 'ತರಗತಿ ವಿರಾಮದ ವಿನಂತಿ ಸ್ವೀಕರಿಸಲಾಗಿದೆ.';

  @override
  String get libraryClassPauseFailed =>
      'ತರಗತಿ ಆಡಿಯೋ ವಿರಾಮಗೊಳಿಸಲು ಆಗಲಿಲ್ಲ. ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String libraryStopPreviewLabel(String title) {
    return '$title ನ ಖಾಸಗಿ ಪೂರ್ವವೀಕ್ಷಣೆ ನಿಲ್ಲಿಸಿ. ಇದು ನಿಮಗೆ ಮಾತ್ರ ಕೇಳಿಸುತ್ತದೆ.';
  }

  @override
  String libraryPreviewLabel(String title) {
    return '$title ಖಾಸಗಿಯಾಗಿ ಪೂರ್ವವೀಕ್ಷಿಸಿ. ಇದು ನಿಮಗೆ ಮಾತ್ರ ಕೇಳಿಸುತ್ತದೆ.';
  }

  @override
  String libraryBroadcastLabel(String title) {
    return 'ಸೆಷನ್‌ನಲ್ಲಿರುವ ಎಲ್ಲರಿಗೂ $title ಪ್ಲೇ ಮಾಡಿ';
  }

  @override
  String libraryRecordingsSentence(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ರೆಕಾರ್ಡಿಂಗ್‌ಗಳು.',
      one: '1 ರೆಕಾರ್ಡಿಂಗ್.',
    );
    return '$_temp0';
  }

  @override
  String libraryPreviewingState(String title) {
    return '$title ಪೂರ್ವವೀಕ್ಷಣೆ ಆಗುತ್ತಿದೆ.';
  }

  @override
  String get libraryUploadInProgress => 'ಅಪ್‌ಲೋಡ್ ನಡೆಯುತ್ತಿದೆ.';

  @override
  String get libraryAccountChanged =>
      'ನಿಮ್ಮ ಖಾತೆ ಬದಲಾಗಿದೆ. ಲೈಬ್ರರಿಯನ್ನು ಮತ್ತೆ ತೆರೆಯಿರಿ.';

  @override
  String get libraryNoUnfinished =>
      'ಈ ಖಾತೆಗೆ ಯಾವುದೇ ಅಪೂರ್ಣ ಪಾಠ ಉಳಿಸಲಾಗಿಲ್ಲ. ಕಲಿಯಲು ಆರಂಭಿಸಲು ಒಂದು ರೆಕಾರ್ಡ್ ಮಾಡಿದ ಪಾಠ ಆಯ್ಕೆ ಮಾಡಿ.';

  @override
  String get libraryCannotCheckAccess =>
      'ಪಾಠದ ಪ್ರವೇಶ ಪರಿಶೀಲಿಸಲು ಆಗಲಿಲ್ಲ. ಇಂಟರ್ನೆಟ್‌ಗೆ ಸಂಪರ್ಕಿಸಿ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ. ನಿಮ್ಮ ಉಳಿಸಿದ ಪ್ರಗತಿಯನ್ನು ಇಟ್ಟುಕೊಳ್ಳಲಾಗಿದೆ.';

  @override
  String get libraryUnfinishedUnavailable =>
      'ನಿಮ್ಮ ಅಪೂರ್ಣ ಪಾಠಗಳು ಸದ್ಯಕ್ಕೆ ಈ ಲೈಬ್ರರಿಯಲ್ಲಿ ಲಭ್ಯವಿಲ್ಲ. ನಿಮ್ಮ ಉಳಿಸಿದ ಪ್ರಗತಿ ಮತ್ತು ಬುಕ್‌ಮಾರ್ಕ್‌ಗಳನ್ನು ಇಟ್ಟುಕೊಳ್ಳಲಾಗಿದೆ.';

  @override
  String get libraryOpeningNextUnfinished =>
      'ಇತ್ತೀಚಿನ ಪಾಠ ಇಲ್ಲಿ ಲಭ್ಯವಿಲ್ಲ. ಲಭ್ಯವಿರುವ ಮುಂದಿನ ಇತ್ತೀಚಿನ ಅಪೂರ್ಣ ಪಾಠವನ್ನು ತೆರೆಯಲಾಗುತ್ತಿದೆ. ಉಳಿಸಿದ ಪ್ರಗತಿಯನ್ನು ಇಟ್ಟುಕೊಳ್ಳಲಾಗಿದೆ.';

  @override
  String get libraryContinueFailed =>
      'ಉಳಿಸಿದ ಕಲಿಕೆಯ ಪ್ರಗತಿಯನ್ನು ತೆರೆಯಲು ಆಗಲಿಲ್ಲ. ಸ್ಟೋರೇಜ್, ನಿಮ್ಮ ಸಂಪರ್ಕ ಮತ್ತು ಸೈನ್ ಇನ್ ಪರಿಶೀಲಿಸಿ, ನಂತರ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get libraryNoActiveClassesNow =>
      'ಈಗ ಯಾವುದೇ ಸಕ್ರಿಯ ತರಗತಿಗಳಿಲ್ಲ. ಎಲ್ಲಾ ಆಡಿಯೋ ಫೈಲ್‌ಗಳಿಗಾಗಿ 3 ಒತ್ತಿ.';

  @override
  String libraryClassesLoaded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ಸಕ್ರಿಯ ತರಗತಿಗಳು ಲೋಡ್ ಆಗಿವೆ.',
      one: '1 ಸಕ್ರಿಯ ತರಗತಿ ಲೋಡ್ ಆಗಿದೆ.',
    );
    return '$_temp0';
  }

  @override
  String libraryClassesFailed(String reason) {
    return '$reason ಸಕ್ರಿಯ ತರಗತಿಗಳನ್ನು ರಿಫ್ರೆಶ್ ಮಾಡಲು ಆಗಲಿಲ್ಲ. ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಲು 1 ಒತ್ತಿ. ಉಳಿಸಿದ ಡೌನ್‌ಲೋಡ್‌ಗಳು ಲಭ್ಯವಿವೆ.';
  }

  @override
  String get libraryClassesLoading =>
      'ತರಗತಿಗಳು ಇನ್ನೂ ಲೋಡ್ ಆಗುತ್ತಿವೆ. ಸ್ವಲ್ಪ ಸಮಯದ ನಂತರ ಮತ್ತೆ ಕೀ 5 ಒತ್ತಿ.';

  @override
  String get libraryNoActiveClassesStaying =>
      'ಯಾವುದೇ ಸಕ್ರಿಯ ತರಗತಿಗಳಿಲ್ಲ. ಆಡಿಯೋ ಲೈಬ್ರರಿಯಲ್ಲೇ ಇರಲಾಗುತ್ತಿದೆ.';

  @override
  String libraryFirstActiveClass(String title) {
    return '$title. ಮೊದಲ ಸಕ್ರಿಯ ತರಗತಿ. ಸಕ್ರಿಯ ತರಗತಿ ಸೆಷನ್‌ಗಳನ್ನು ನೋಡಲು D-pad ಮೇಲೆ ಮತ್ತು ಕೆಳಗೆ ಬಳಸಿ. ಆಯ್ಕೆ ಮಾಡಿದ ತರಗತಿಯ ರೆಕಾರ್ಡಿಂಗ್‌ಗಳನ್ನು ತೆರೆಯಲು ಓಕೆ ಒತ್ತಿ.';
  }

  @override
  String get libraryOpeningPlaylists =>
      'ನನ್ನ ಪ್ಲೇಲಿಸ್ಟ್‌ಗಳನ್ನು ತೆರೆಯಲಾಗುತ್ತಿದೆ. ಪ್ಲೇಲಿಸ್ಟ್‌ನ ವಿಷಯಗಳು ಖಾಸಗಿಯಾಗಿವೆ.';

  @override
  String libraryClassLabel(String title, String index, String count) {
    return '$title. ತರಗತಿ $index, ಒಟ್ಟು $count ರಲ್ಲಿ';
  }

  @override
  String get libraryLoadingActiveClasses =>
      'ಸಕ್ರಿಯ ತರಗತಿಗಳನ್ನು ಲೋಡ್ ಮಾಡಲಾಗುತ್ತಿದೆ.';

  @override
  String libraryActiveClassesSentence(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ಸಕ್ರಿಯ ತರಗತಿಗಳು.',
      one: '1 ಸಕ್ರಿಯ ತರಗತಿ.',
    );
    return '$_temp0';
  }

  @override
  String libraryNoRecordingsFor(String where) {
    return '$where ಗೆ ಇನ್ನೂ ಯಾವುದೇ ರೆಕಾರ್ಡಿಂಗ್ ಇಲ್ಲ.';
  }

  @override
  String libraryRecordingsLoadedFor(int count, String where) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$where ಗೆ $count ರೆಕಾರ್ಡಿಂಗ್‌ಗಳು ಲೋಡ್ ಆಗಿವೆ.',
      one: '$where ಗೆ 1 ರೆಕಾರ್ಡಿಂಗ್ ಲೋಡ್ ಆಗಿದೆ.',
    );
    return '$_temp0';
  }

  @override
  String get libraryDownloadsReadFailed =>
      'ಡೌನ್‌ಲೋಡ್ ಮಾಡಿದ ಪಾಠಗಳನ್ನು ಓದಲು ಆಗಲಿಲ್ಲ. ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಲು 1 ಒತ್ತಿ.';

  @override
  String get libraryClassLoadFailed =>
      'ರೆಕಾರ್ಡಿಂಗ್‌ಗಳನ್ನು ಲೋಡ್ ಮಾಡಲು ಆಗಲಿಲ್ಲ. ನಿಮ್ಮ ಇಂಟರ್ನೆಟ್ ಸಂಪರ್ಕ ಮತ್ತು ಸೈನ್ ಇನ್ ಪರಿಶೀಲಿಸಿ, ನಂತರ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಲು 1 ಒತ್ತಿ.';

  @override
  String libraryRetryAfter(String reason) {
    return '$reason ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಲು 1 ಒತ್ತಿ.';
  }

  @override
  String get libraryDownloadedDescription =>
      'ಡೌನ್‌ಲೋಡ್ ಮಾಡಿದ ರೆಕಾರ್ಡಿಂಗ್. 30 ದಿನಗಳ ನಂತರ ಪ್ರವೇಶವನ್ನು ನವೀಕರಿಸಬೇಕು.';

  @override
  String get libraryDownloadedHelp =>
      'ಡೌನ್‌ಲೋಡ್ ಮಾಡಿದ ಪಾಠಗಳು. ಪ್ಲೇ ಮಾಡುವ ಮೊದಲು ಈಗಿರುವ ಆಫ್‌ಲೈನ್ ಪ್ರವೇಶವನ್ನು ಪರಿಶೀಲಿಸಲಾಗುತ್ತದೆ.';

  @override
  String get libraryOnlineHelp =>
      'ಆಡಿಯೋ ಲೈಬ್ರರಿ. ಆನ್‌ಲೈನ್ ರೆಕಾರ್ಡಿಂಗ್‌ಗಳಿಗೆ ಇಂಟರ್ನೆಟ್ ಬೇಕು. ಆಫ್‌ಲೈನ್‌ನಲ್ಲಿ ಕೇಳಲು ಪಾಠಗಳನ್ನು ಡೌನ್‌ಲೋಡ್ ಮಾಡಿ.';

  @override
  String librarySubjectChoice(String name, String index, String count) {
    return 'ವಿಷಯ: $name, $count ರಲ್ಲಿ $index';
  }

  @override
  String librarySubjectLabel(String choice) {
    return '$choice. ಬದಲಾಯಿಸಲು 2 ಒತ್ತಿ, ಅಥವಾ ಎಡ ಮತ್ತು ಬಲ ಒತ್ತಿ';
  }

  @override
  String get librarySubjectFixed =>
      'ಈ ಲೈಬ್ರರಿ ಈಗಾಗಲೇ ಒಂದೇ ವಿಷಯಕ್ಕೆ ಸೀಮಿತವಾಗಿದೆ.';

  @override
  String libraryLength(String time) {
    return 'ಅವಧಿ $time';
  }

  @override
  String libraryRecordingsInSubject(int count, String subject) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$subject ನಲ್ಲಿ $count ರೆಕಾರ್ಡಿಂಗ್‌ಗಳು.',
      one: '$subject ನಲ್ಲಿ 1 ರೆಕಾರ್ಡಿಂಗ್.',
    );
    return '$_temp0';
  }

  @override
  String libraryNoTeacherPlaylists(String className, String subject) {
    return '$className, $subject ಗೆ ಇನ್ನೂ ಯಾವುದೇ ಪ್ಲೇಲಿಸ್ಟ್ ಇಲ್ಲ. ಒಂದನ್ನು ರಚಿಸಲು 2 ಒತ್ತಿ.';
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
      other: '$className, $subject ಗೆ $count ಪ್ಲೇಲಿಸ್ಟ್‌ಗಳು ಲೋಡ್ ಆಗಿವೆ.',
      one: '$className, $subject ಗೆ 1 ಪ್ಲೇಲಿಸ್ಟ್ ಲೋಡ್ ಆಗಿದೆ.',
    );
    return '$_temp0';
  }

  @override
  String get libraryPlaylistCreateFailed => 'ಪ್ಲೇಲಿಸ್ಟ್ ರಚಿಸಲು ಆಗಲಿಲ್ಲ.';

  @override
  String get libraryNoMyPlaylists =>
      'ಇನ್ನೂ ಯಾವುದೇ ಪ್ಲೇಲಿಸ್ಟ್ ಇಲ್ಲ. ಖಾಸಗಿ ಪ್ಲೇಲಿಸ್ಟ್ ರಚಿಸಲು 2 ಒತ್ತಿ.';

  @override
  String libraryPrivatePlaylistCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ಖಾಸಗಿ ಪ್ಲೇಲಿಸ್ಟ್‌ಗಳು',
      one: '1 ಖಾಸಗಿ ಪ್ಲೇಲಿಸ್ಟ್',
    );
    return '$_temp0';
  }

  @override
  String libraryClassPlaylistCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ತರಗತಿ ಪ್ಲೇಲಿಸ್ಟ್‌ಗಳು',
      one: '1 ತರಗತಿ ಪ್ಲೇಲಿಸ್ಟ್',
    );
    return '$_temp0';
  }

  @override
  String libraryMyPlaylistsLoaded(
    String privatePlaylists,
    String classPlaylists,
  ) {
    return '$privatePlaylists ಮತ್ತು $classPlaylists ಲೋಡ್ ಆಗಿವೆ.';
  }

  @override
  String get libraryPrivatePlaylistCreateFailed =>
      'ಖಾಸಗಿ ಪ್ಲೇಲಿಸ್ಟ್ ರಚಿಸಲು ಆಗಲಿಲ್ಲ.';

  @override
  String libraryPlaylistsSentence(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ಪ್ಲೇಲಿಸ್ಟ್‌ಗಳು.',
      one: '1 ಪ್ಲೇಲಿಸ್ಟ್.',
    );
    return '$_temp0';
  }

  @override
  String libraryItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ಐಟಂಗಳು',
      one: '1 ಐಟಂ',
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
      'ಈ ಪ್ಲೇಲಿಸ್ಟ್ ಅನ್ನು ರಿಫ್ರೆಶ್ ಮಾಡಲು ಆಗಲಿಲ್ಲ. ನಿಮ್ಮ ಸಂಪರ್ಕ ಪರಿಶೀಲಿಸಿ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ. ಈಗಿನ ಪ್ಲೇಬ್ಯಾಕ್ ಮತ್ತು ಉಳಿಸಿದ ಪ್ರಗತಿಯನ್ನು ಬದಲಾಯಿಸಿಲ್ಲ.';

  @override
  String get libraryPlaylistLessonGone =>
      'ಈಗಿನ ಪಾಠ ಈ ಪ್ಲೇಲಿಸ್ಟ್‌ನಲ್ಲಿ ಇನ್ನು ಲಭ್ಯವಿಲ್ಲ. ಪ್ಲೇಬ್ಯಾಕ್ ನಿಲ್ಲಿಸಲಾಗಿದೆ. ನಿಮ್ಮ ಉಳಿಸಿದ ಪ್ರಗತಿ ಮತ್ತು ಬುಕ್‌ಮಾರ್ಕ್‌ಗಳನ್ನು ಇಟ್ಟುಕೊಳ್ಳಲಾಗಿದೆ.';

  @override
  String get libraryNothingToAdd => 'ಸೇರಿಸಲು ಯಾವುದೇ ಅರ್ಹ ಆಡಿಯೋ ಲಭ್ಯವಿಲ್ಲ.';

  @override
  String libraryAddedToPlaylist(String title) {
    return '$title ಅನ್ನು ಪ್ಲೇಲಿಸ್ಟ್‌ಗೆ ಸೇರಿಸಲಾಗಿದೆ.';
  }

  @override
  String get libraryAddFailed =>
      'ಆಡಿಯೋ ಸೇರಿಸಲು ಆಗಲಿಲ್ಲ. ನಿಮ್ಮ ಸಂಪರ್ಕ ಪರಿಶೀಲಿಸಿ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String libraryItemUnavailable(String title) {
    return '$title ನಿಮ್ಮ ಈಗಿನ ತರಗತಿಯಲ್ಲಿ ಇನ್ನು ಲಭ್ಯವಿಲ್ಲ. ನೀವು ಅದನ್ನು ಈ ಪ್ಲೇಲಿಸ್ಟ್‌ನಿಂದ ತೆಗೆದುಹಾಕಬಹುದು.';
  }

  @override
  String libraryItemCannotPlay(String title) {
    return '$title ಲಭ್ಯವಿಲ್ಲ.';
  }

  @override
  String libraryPlayingItem(String announcement, String index, String count) {
    return '$announcement ಐಟಂ $index, ಒಟ್ಟು $count ರಲ್ಲಿ.';
  }

  @override
  String get libraryPlaylistPlayFailed =>
      'ಈ ಪಾಠವನ್ನು ಪ್ಲೇ ಮಾಡಲು ಆಗಲಿಲ್ಲ. ನಿಮ್ಮ ಸಂಪರ್ಕ ಪರಿಶೀಲಿಸಿ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get libraryPlaylistEmpty => 'ಪ್ಲೇಲಿಸ್ಟ್ ಖಾಲಿ ಇದೆ.';

  @override
  String get libraryPlaylistEnded =>
      'ಪ್ಲೇಲಿಸ್ಟ್ ಮುಗಿದಿದೆ. ಪ್ಲೇಬ್ಯಾಕ್ ನಿಲ್ಲಿಸಲಾಗಿದೆ.';

  @override
  String libraryRenamed(String title) {
    return 'ಪ್ಲೇಲಿಸ್ಟ್‌ನ ಹೆಸರನ್ನು $title ಎಂದು ಬದಲಾಯಿಸಲಾಗಿದೆ.';
  }

  @override
  String get libraryRenameFailed =>
      'ಪ್ಲೇಲಿಸ್ಟ್‌ನ ಹೆಸರು ಬದಲಾಯಿಸಲು ಆಗಲಿಲ್ಲ. ನಿಮ್ಮ ಸಂಪರ್ಕ ಪರಿಶೀಲಿಸಿ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get libraryAlreadyFirst => 'ಆಯ್ಕೆ ಮಾಡಿದ ಐಟಂ ಈಗಾಗಲೇ ಮೊದಲನೆಯದಾಗಿದೆ.';

  @override
  String get libraryAlreadyLast => 'ಆಯ್ಕೆ ಮಾಡಿದ ಐಟಂ ಈಗಾಗಲೇ ಕೊನೆಯದಾಗಿದೆ.';

  @override
  String libraryMoved(String title, String position, String count) {
    return '$title ಅನ್ನು $count ರಲ್ಲಿ $position ನೇ ಸ್ಥಾನಕ್ಕೆ ಸರಿಸಲಾಗಿದೆ.';
  }

  @override
  String libraryMoveFailed(String title) {
    return '$title ಅನ್ನು ಸರಿಸಲು ಆಗಲಿಲ್ಲ. ನಿಮ್ಮ ಸಂಪರ್ಕ ಪರಿಶೀಲಿಸಿ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';
  }

  @override
  String libraryRemovedFromPlaylist(String title, String playlist) {
    return '$title ಅನ್ನು $playlist ನಿಂದ ತೆಗೆದುಹಾಕಲಾಗಿದೆ.';
  }

  @override
  String libraryRemoveFailed(String title) {
    return '$title ಅನ್ನು ತೆಗೆದುಹಾಕಲು ಆಗಲಿಲ್ಲ. ನಿಮ್ಮ ಸಂಪರ್ಕ ಪರಿಶೀಲಿಸಿ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';
  }

  @override
  String libraryRemoveItemQuestion(String title, String playlist) {
    return '$title ಅನ್ನು $playlist ನಿಂದ ತೆಗೆದುಹಾಕಬೇಕೆ? ರೆಕಾರ್ಡಿಂಗ್ ಲೈಬ್ರರಿಯಲ್ಲಿ ಉಳಿಯುತ್ತದೆ.';
  }

  @override
  String libraryRemoveItemLabel(String title) {
    return '$title ಅನ್ನು ಪ್ಲೇಲಿಸ್ಟ್‌ನಿಂದ ತೆಗೆದುಹಾಕಿ, ಖಚಿತಪಡಿಸಲು ಕೇಳುತ್ತದೆ';
  }

  @override
  String libraryPublished(String title) {
    return '$title ಅನ್ನು ತರಗತಿಗೆ ಪ್ರಕಟಿಸಲಾಗಿದೆ.';
  }

  @override
  String libraryReturnedToDraft(String title) {
    return '$title ಅನ್ನು ಮತ್ತೆ ಕರಡಿಗೆ ಹಿಂತಿರುಗಿಸಲಾಗಿದೆ.';
  }

  @override
  String libraryChangeFailed(String title) {
    return '$title ಅನ್ನು ಬದಲಾಯಿಸಲು ಆಗಲಿಲ್ಲ. ನಿಮ್ಮ ಸಂಪರ್ಕ ಪರಿಶೀಲಿಸಿ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';
  }

  @override
  String libraryDeleted(String title) {
    return '$title ಅಳಿಸಲಾಗಿದೆ.';
  }

  @override
  String libraryRestoredAsDraft(String title) {
    return '$title ಅನ್ನು ಕರಡಾಗಿ ಮರುಸ್ಥಾಪಿಸಲಾಗಿದೆ.';
  }

  @override
  String libraryArchived(String title) {
    return '$title ಆರ್ಕೈವ್ ಮಾಡಲಾಗಿದೆ.';
  }

  @override
  String get libraryPlaylistIsEmpty => 'ಪ್ಲೇಲಿಸ್ಟ್ ಖಾಲಿ ಇದೆ.';

  @override
  String librarySelectedItem(String selected, String items) {
    return 'ಆಯ್ಕೆ ಮಾಡಿದ ಐಟಂ $selected, ಒಟ್ಟು $items ರಲ್ಲಿ.';
  }

  @override
  String librarySelectedItemTitled(
    String selected,
    String items,
    String title,
  ) {
    return 'ಆಯ್ಕೆ ಮಾಡಿದ ಐಟಂ $selected, ಒಟ್ಟು $items ರಲ್ಲಿ, $title.';
  }

  @override
  String get libraryAlreadyOneSubject =>
      'ಈ ಲೈಬ್ರರಿ ಈಗಾಗಲೇ ಒಂದೇ ವಿಷಯಕ್ಕೆ ಸೀಮಿತವಾಗಿದೆ';

  @override
  String get libraryNoLessonIsPlaying => 'ಯಾವುದೇ ಪಾಠ ಪ್ಲೇ ಆಗುತ್ತಿಲ್ಲ.';

  @override
  String libraryAddedToSession(String title) {
    return '$title ಅನ್ನು ಈ ಸೆಷನ್‌ಗೆ ಸೇರಿಸಲಾಗಿದೆ.';
  }

  @override
  String get libraryPlaylistNotCreated => 'ಪ್ಲೇಲಿಸ್ಟ್ ರಚಿಸಲು ಆಗಲಿಲ್ಲ';

  @override
  String get libraryPrivatePlaylistNotCreated =>
      'ಖಾಸಗಿ ಪ್ಲೇಲಿಸ್ಟ್ ರಚಿಸಲು ಆಗಲಿಲ್ಲ';

  @override
  String get libraryNoEligibleAudio => 'ಸೇರಿಸಲು ಯಾವುದೇ ಅರ್ಹ ಆಡಿಯೋ ಲಭ್ಯವಿಲ್ಲ';

  @override
  String get libraryAudioAddedToPlaylist =>
      'ಆಡಿಯೋವನ್ನು ಪ್ಲೇಲಿಸ್ಟ್‌ಗೆ ಸೇರಿಸಲಾಗಿದೆ';

  @override
  String libraryUnavailable(String title) {
    return '$title ಲಭ್ಯವಿಲ್ಲ';
  }

  @override
  String libraryPlaylistRenamed(String title) {
    return 'ಪ್ಲೇಲಿಸ್ಟ್‌ನ ಹೆಸರನ್ನು $title ಎಂದು ಬದಲಾಯಿಸಲಾಗಿದೆ';
  }

  @override
  String libraryMovedTo(String title, String position) {
    return '$title ಅನ್ನು $position ನೇ ಸ್ಥಾನಕ್ಕೆ ಸರಿಸಲಾಗಿದೆ';
  }

  @override
  String get libraryNoteRenamed => 'ಖಾಸಗಿ ಟಿಪ್ಪಣಿಯ ಹೆಸರನ್ನು ಬದಲಾಯಿಸಲಾಗಿದೆ.';

  @override
  String get downloadNoneYet =>
      'ಇನ್ನೂ ಯಾವುದೇ ಡೌನ್‌ಲೋಡ್ ಇಲ್ಲ. ಆನ್‌ಲೈನ್‌ನಲ್ಲಿ ರೆಕಾರ್ಡಿಂಗ್‌ಗಳನ್ನು ಹುಡುಕಲು 2 ಒತ್ತಿ.';

  @override
  String downloadLessonCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ಡೌನ್‌ಲೋಡ್ ಮಾಡಿದ ಪಾಠಗಳು',
      one: '1 ಡೌನ್‌ಲೋಡ್ ಮಾಡಿದ ಪಾಠ',
    );
    return '$_temp0';
  }

  @override
  String downloadPartialCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ಅರ್ಧ ಡೌನ್‌ಲೋಡ್‌ಗಳು',
      one: '1 ಅರ್ಧ ಡೌನ್‌ಲೋಡ್',
    );
    return '$_temp0';
  }

  @override
  String downloadReadyToPlay(String lessons) {
    return '$lessons ಪ್ಲೇ ಮಾಡಲು ಸಿದ್ಧವಾಗಿವೆ.';
  }

  @override
  String downloadReadyToPlayWithPartial(String lessons, String partial) {
    return '$lessons ಪ್ಲೇ ಮಾಡಲು ಸಿದ್ಧವಾಗಿವೆ, $partial.';
  }

  @override
  String get downloadActionFailed =>
      'ಈ ಡೌನ್‌ಲೋಡ್ ಕ್ರಿಯೆಯನ್ನು ಪೂರ್ಣಗೊಳಿಸಲು ಆಗಲಿಲ್ಲ. ಸ್ಟೋರೇಜ್, ನಿಮ್ಮ ಸಂಪರ್ಕ ಮತ್ತು ಸೈನ್ ಇನ್ ಪರಿಶೀಲಿಸಿ, ನಂತರ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get downloadOnlineListFailed =>
      'ಲಭ್ಯವಿರುವ ರೆಕಾರ್ಡಿಂಗ್‌ಗಳನ್ನು ಲೋಡ್ ಮಾಡಲು ಆಗಲಿಲ್ಲ. ಈಗಿರುವ ಡೌನ್‌ಲೋಡ್‌ಗಳು ಅವುಗಳ ಪ್ರವೇಶ ಮುಗಿಯುವವರೆಗೆ ಕೆಲಸ ಮಾಡುತ್ತವೆ.';

  @override
  String downloadAvailable(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count ರೆಕಾರ್ಡಿಂಗ್‌ಗಳು ಡೌನ್‌ಲೋಡ್ ಮಾಡಲು ಲಭ್ಯವಿವೆ. ನಿಮಗೆ ಬೇಕಾದ ರೆಕಾರ್ಡಿಂಗ್‌ಗಳನ್ನು ಆಯ್ಕೆ ಮಾಡಿ.',
      one:
          '1 ರೆಕಾರ್ಡಿಂಗ್ ಡೌನ್‌ಲೋಡ್ ಮಾಡಲು ಲಭ್ಯವಿದೆ. ನಿಮಗೆ ಬೇಕಾದ ರೆಕಾರ್ಡಿಂಗ್‌ಗಳನ್ನು ಆಯ್ಕೆ ಮಾಡಿ.',
    );
    return '$_temp0';
  }

  @override
  String downloadStarting(String title) {
    return '$title ಡೌನ್‌ಲೋಡ್ ಆಗುತ್ತಿದೆ. ಪ್ರತಿ 25 ಪ್ರತಿಶತಕ್ಕೆ ನೀವು ಪ್ರಗತಿಯನ್ನು ಕೇಳುತ್ತೀರಿ.';
  }

  @override
  String downloadProgress(String title, String percent) {
    return '$title $percent ಡೌನ್‌ಲೋಡ್ ಆಗಿದೆ.';
  }

  @override
  String get downloadVerified =>
      'ಡೌನ್‌ಲೋಡ್ ಪರಿಶೀಲಿಸಲಾಗಿದೆ ಮತ್ತು ಆಫ್‌ಲೈನ್‌ನಲ್ಲಿ ಕೇಳಲು ಉಳಿಸಲಾಗಿದೆ.';

  @override
  String downloadDone(String title) {
    return '$title ಡೌನ್‌ಲೋಡ್ ಆಗಿದೆ, ಪರಿಶೀಲಿಸಲಾಗಿದೆ ಮತ್ತು ಆಫ್‌ಲೈನ್‌ನಲ್ಲಿ ಕೇಳಲು ಉಳಿಸಲಾಗಿದೆ.';
  }

  @override
  String downloadPackQuestion(String recordings) {
    return '$recordings ಅನ್ನು ಒಂದೊಂದಾಗಿ ಡೌನ್‌ಲೋಡ್ ಮಾಡಬೇಕೆ? ಇದು ಇಂಟರ್ನೆಟ್ ಡೇಟಾ ಮತ್ತು ನಿಮ್ಮ ಖಾತೆಯ 50 MB ಮಿತಿಯನ್ನು ಬಳಸುತ್ತದೆ. ವಿಫಲವಾದರೆ ಅಥವಾ ರದ್ದುಗೊಳಿಸಿದರೆ, ಪರಿಶೀಲಿಸಿದ ಡೌನ್‌ಲೋಡ್‌ಗಳು ಮತ್ತು ಅರ್ಧ ಡೇಟಾವನ್ನು ಇಟ್ಟುಕೊಳ್ಳಲಾಗುತ್ತದೆ. ಈಗಿರುವ ಯಾವುದೇ ಪಾಠವನ್ನು ಅಳಿಸಲಾಗುವುದಿಲ್ಲ.';
  }

  @override
  String downloadPackStarting(String recordings) {
    return '$recordings ಅನ್ನು ಒಂದೊಂದಾಗಿ ಡೌನ್‌ಲೋಡ್ ಮಾಡಲಾಗುತ್ತಿದೆ.';
  }

  @override
  String downloadPackProgress(String done, String total) {
    return '$total ರಲ್ಲಿ $done ರೆಕಾರ್ಡಿಂಗ್‌ಗಳನ್ನು ಪರಿಶೀಲಿಸಲಾಗಿದೆ.';
  }

  @override
  String downloadPackDone(String done, String total) {
    return '$total ರಲ್ಲಿ $done ರೆಕಾರ್ಡಿಂಗ್‌ಗಳನ್ನು ಪರಿಶೀಲಿಸಿ ಉಳಿಸಲಾಗಿದೆ.';
  }

  @override
  String downloadRenewed(String title) {
    return '$title ಗೆ ಪ್ರವೇಶವನ್ನು ನವೀಕರಿಸಲಾಗಿದೆ. 30 ದಿನಗಳವರೆಗೆ ಆಫ್‌ಲೈನ್‌ನಲ್ಲಿ ಕೇಳಬಹುದು.';
  }

  @override
  String downloadRemoveTitle(String title) {
    return '$title ನ ಡೌನ್‌ಲೋಡ್ ತೆಗೆದುಹಾಕಬೇಕೆ?';
  }

  @override
  String downloadRemoveQuestion(String title) {
    return '$title ನ ಡೌನ್‌ಲೋಡ್ ಆದ ಅಥವಾ ಅರ್ಧ ಆಡಿಯೋವನ್ನು ತೆಗೆದುಹಾಕಬೇಕೆ? ಕಲಿಕೆಯ ಪ್ರಗತಿ ಮತ್ತು ಬುಕ್‌ಮಾರ್ಕ್‌ಗಳನ್ನು ಇಟ್ಟುಕೊಳ್ಳಲಾಗುತ್ತದೆ. ಇತರ ರೆಕಾರ್ಡಿಂಗ್‌ಗಳು ಮತ್ತು ಖಾತೆಗಳ ಮೇಲೆ ಪರಿಣಾಮವಿಲ್ಲ.';
  }

  @override
  String downloadRemoved(String title) {
    return '$title ನ ಡೌನ್‌ಲೋಡ್ ತೆಗೆದುಹಾಕಲಾಗಿದೆ. ಪ್ರಗತಿ ಮತ್ತು ಬುಕ್‌ಮಾರ್ಕ್‌ಗಳನ್ನು ಇಟ್ಟುಕೊಳ್ಳಲಾಗಿದೆ.';
  }

  @override
  String downloadUnreadableTitle(String id) {
    return 'ಓದಲಾಗದ ರೆಕಾರ್ಡಿಂಗ್ $id';
  }

  @override
  String get downloadRenewalRequired => 'ಪ್ರವೇಶವನ್ನು ನವೀಕರಿಸಬೇಕು.';

  @override
  String downloadAccessExpires(String date) {
    return 'ಪ್ರವೇಶ $date ಮುಗಿಯುತ್ತದೆ.';
  }

  @override
  String downloadPlayLabelComplete(String title, String size, String expiry) {
    return '$title ಪ್ಲೇ ಮಾಡಿ. ಡೌನ್‌ಲೋಡ್ ಆಗಿದೆ. $size. $expiry';
  }

  @override
  String downloadPlayLabelPartial(String title, String size, String expiry) {
    return '$title ಪ್ಲೇ ಮಾಡಿ. ಅರ್ಧ ಡೌನ್‌ಲೋಡ್, ಇನ್ನೂ ಪ್ಲೇ ಮಾಡಲು ಆಗುವುದಿಲ್ಲ. $size. $expiry';
  }

  @override
  String downloadRenewLabel(String title) {
    return '$title ಗೆ ಪ್ರವೇಶ ನವೀಕರಿಸಿ. ಇಂಟರ್ನೆಟ್ ಬೇಕು';
  }

  @override
  String downloadRemoveLabel(String title) {
    return '$title ನ ಡೌನ್‌ಲೋಡ್ ತೆಗೆದುಹಾಕಿ, ಖಚಿತಪಡಿಸಲು ಕೇಳುತ್ತದೆ';
  }

  @override
  String downloadUnreadableLabel(String id) {
    return 'ಓದಲಾಗದ ಡೌನ್‌ಲೋಡ್ ದಾಖಲೆ $id. ಈ ಡೌನ್‌ಲೋಡ್ ಮಾತ್ರ ತೆಗೆದುಹಾಕಿ, ಖಚಿತಪಡಿಸಲು ಕೇಳುತ್ತದೆ';
  }

  @override
  String downloadOrResumeLabel(String title) {
    return '$title ಡೌನ್‌ಲೋಡ್ ಮಾಡಿ ಅಥವಾ ಮುಂದುವರಿಸಿ';
  }

  @override
  String downloadCancelLabel(String title) {
    return '$title ನ ಡೌನ್‌ಲೋಡ್ ರದ್ದುಗೊಳಿಸಿ, ಕೀ 4. ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಲು ಅರ್ಧ ಡೇಟಾ ಇಟ್ಟುಕೊಳ್ಳಿ';
  }

  @override
  String downloadUnavailableWhileBusy(String label) {
    return 'ಡೌನ್‌ಲೋಡ್‌ಗಳು ನಡೆಯುತ್ತಿರುವಾಗ $label ಲಭ್ಯವಿಲ್ಲ.';
  }

  @override
  String get downloadStorageUnknown =>
      'ಸ್ಟೋರೇಜ್ ಕಾಯ್ದಿರಿಸುವಿಕೆ ಲಭ್ಯವಿಲ್ಲ. ಡೌನ್‌ಲೋಡ್ ಮಾಡುವ ಮೊದಲು ಡೌನ್‌ಲೋಡ್‌ಗಳನ್ನು ರಿಫ್ರೆಶ್ ಮಾಡಿ ಅಥವಾ ಆಯ್ಕೆ ಮಾಡಿದ ಓದಲಾಗದ ದಾಖಲೆಗಳನ್ನು ತೆಗೆದುಹಾಕಿ.';

  @override
  String downloadCountComma(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ಡೌನ್‌ಲೋಡ್‌ಗಳು,',
      one: '1 ಡೌನ್‌ಲೋಡ್,',
    );
    return '$_temp0';
  }

  @override
  String get downloadStorageUseUnknown => 'ಸ್ಟೋರೇಜ್ ಬಳಕೆ ತಿಳಿದಿಲ್ಲ.';

  @override
  String downloadDownloadingStarting(String title) {
    return '$title ಡೌನ್‌ಲೋಡ್ ಆಗುತ್ತಿದೆ, ಪ್ರಾರಂಭವಾಗುತ್ತಿದೆ.';
  }

  @override
  String downloadDownloadingPercent(String title, String percent) {
    return '$title ಡೌನ್‌ಲೋಡ್ ಆಗುತ್ತಿದೆ, $percent.';
  }

  @override
  String downloadScreenLoaded(String complete) {
    return '$complete ಡೌನ್‌ಲೋಡ್ ಮಾಡಿದ ಪಾಠಗಳು ಪ್ಲೇ ಮಾಡಲು ಸಿದ್ಧವಾಗಿವೆ.';
  }

  @override
  String downloadScreenLoadedWithPartial(String complete, String partial) {
    return '$complete ಡೌನ್‌ಲೋಡ್ ಮಾಡಿದ ಪಾಠಗಳು ಪ್ಲೇ ಮಾಡಲು ಸಿದ್ಧವಾಗಿವೆ, $partial ಅರ್ಧ ಡೌನ್‌ಲೋಡ್‌ಗಳು.';
  }

  @override
  String downloadAvailableCount(String count) {
    return '$count ರೆಕಾರ್ಡಿಂಗ್‌ಗಳು ಡೌನ್‌ಲೋಡ್ ಮಾಡಲು ಲಭ್ಯವಿವೆ. ನಿಮಗೆ ಬೇಕಾದ ರೆಕಾರ್ಡಿಂಗ್‌ಗಳನ್ನು ಆಯ್ಕೆ ಮಾಡಿ.';
  }

  @override
  String downloadRecordingFallback(String id) {
    return 'ರೆಕಾರ್ಡಿಂಗ್ $id';
  }

  @override
  String get downloadPackDialogTitle =>
      'ಪಟ್ಟಿಯಲ್ಲಿರುವ ರೆಕಾರ್ಡಿಂಗ್‌ಗಳನ್ನು ಡೌನ್‌ಲೋಡ್ ಮಾಡಬೇಕೆ?';

  @override
  String downloadPackDialogMessage(String count) {
    return 'ಪಟ್ಟಿಯಲ್ಲಿರುವ $count ರೆಕಾರ್ಡಿಂಗ್‌ಗಳನ್ನು ಒಂದೊಂದಾಗಿ ಡೌನ್‌ಲೋಡ್ ಮಾಡಬೇಕೆ? ಇದು ಇಂಟರ್ನೆಟ್ ಡೇಟಾ ಮತ್ತು ನಿಮ್ಮ ಖಾತೆಯ 50 MB ಮಿತಿಯನ್ನು ಬಳಸುತ್ತದೆ. ವಿಫಲವಾದರೆ ಅಥವಾ ರದ್ದುಗೊಳಿಸಿದರೆ, ಪರಿಶೀಲಿಸಿದ ಡೌನ್‌ಲೋಡ್‌ಗಳು ಮತ್ತು ಅರ್ಧ ಡೇಟಾವನ್ನು ಇಟ್ಟುಕೊಳ್ಳಲಾಗುತ್ತದೆ. ಈಗಿರುವ ಯಾವುದೇ ಪಾಠವನ್ನು ಅಳಿಸಲಾಗುವುದಿಲ್ಲ.';
  }

  @override
  String get downloadPackConfirm => 'ಪಟ್ಟಿಯದನ್ನು ಡೌನ್‌ಲೋಡ್ ಮಾಡಿ';

  @override
  String get downloadPackCancel => 'ಒಂದೊಂದಾಗಿ ಆಯ್ಕೆ ಮಾಡಿ';

  @override
  String get downloadRemoveConfirm => 'ಡೌನ್‌ಲೋಡ್ ತೆಗೆದುಹಾಕಿ';

  @override
  String get downloadKeep => 'ಡೌನ್‌ಲೋಡ್ ಇಟ್ಟುಕೊಳ್ಳಿ';

  @override
  String get downloadScreenName => 'ಡೌನ್‌ಲೋಡ್ ಮಾಡಿದ ಪಾಠಗಳು';

  @override
  String get downloadCancelBackTitle => 'ಡೌನ್‌ಲೋಡ್ ರದ್ದುಗೊಳಿಸಿ ಹಿಂದೆ ಹೋಗಬೇಕೆ?';

  @override
  String get downloadCancelBackMessage =>
      'ಈ ಡೌನ್‌ಲೋಡ್ ನಿಲ್ಲಿಸಬೇಕೆ? ಪರಿಶೀಲಿಸಿದ ರೆಕಾರ್ಡಿಂಗ್‌ಗಳು ಮತ್ತು ಅರ್ಧ ಡೇಟಾವನ್ನು ನೀವು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಲು ಇಟ್ಟುಕೊಳ್ಳಲಾಗುತ್ತದೆ.';

  @override
  String get downloadCancelBackConfirm => 'ರದ್ದುಗೊಳಿಸಿ ಹಿಂದೆ ಹೋಗಿ';

  @override
  String get downloadKeepDownloading => 'ಡೌನ್‌ಲೋಡ್ ಮುಂದುವರಿಸಿ';

  @override
  String downloadReserved(String megabytes) {
    return 'ಈ ಖಾತೆಗೆ 50 MB ರಲ್ಲಿ $megabytes ಕಾಯ್ದಿರಿಸಲಾಗಿದೆ.';
  }

  @override
  String get downloadBack => 'ಹಿಂದೆ';

  @override
  String get downloadRefreshLabel =>
      'ಉಳಿಸಿದ ಡೌನ್‌ಲೋಡ್‌ಗಳನ್ನು ರಿಫ್ರೆಶ್ ಮಾಡಿ, ಕೀ 1';

  @override
  String get downloadFindOnlineLabel =>
      'ಡೌನ್‌ಲೋಡ್ ಮಾಡಲು ರೆಕಾರ್ಡಿಂಗ್‌ಗಳನ್ನು ಹುಡುಕಿ, ಕೀ 2. ಇಂಟರ್ನೆಟ್ ಬೇಕು';

  @override
  String get downloadReadStatusLabel => 'ಡೌನ್‌ಲೋಡ್ ಸ್ಥಿತಿಯನ್ನು ಓದಿ, ಕೀ 3';

  @override
  String downloadPlayDownloadedLabel(String title) {
    return '$title ಪ್ಲೇ ಮಾಡಿ. ಡೌನ್‌ಲೋಡ್ ಆಗಿದೆ';
  }

  @override
  String downloadPlayPartialLabel(String title) {
    return '$title ಪ್ಲೇ ಮಾಡಿ. ಅರ್ಧ ಡೌನ್‌ಲೋಡ್, ಇನ್ನೂ ಪ್ಲೇ ಮಾಡಲು ಆಗುವುದಿಲ್ಲ';
  }

  @override
  String get downloadPackLabel =>
      'ಪಟ್ಟಿಯಲ್ಲಿರುವ ಎಲ್ಲಾ ರೆಕಾರ್ಡಿಂಗ್‌ಗಳನ್ನು ಡೌನ್‌ಲೋಡ್ ಮಾಡಿ, ಕೀ 5, ಖಚಿತಪಡಿಸಲು ಕೇಳುತ್ತದೆ';

  @override
  String get downloadIntroduction =>
      'ಪ್ರತಿ ಖಾತೆಗೆ 50 MB. ಆನ್‌ಲೈನ್‌ನಲ್ಲಿ ಪ್ರವೇಶ ನವೀಕರಿಸುವ ಮೊದಲು 30 ದಿನಗಳವರೆಗೆ ಆಫ್‌ಲೈನ್. ಫೈಲ್‌ಗಳು ಮತ್ತು ಪ್ರಗತಿ ಬೇರೆ ಬೇರೆಯಾಗಿ ಇರುತ್ತವೆ.';

  @override
  String get downloadNavigationSections =>
      'ಪ್ಲೇ ಮಾಡಲು, ನವೀಕರಿಸಲು ಅಥವಾ ತೆಗೆದುಹಾಕಲು ಉಳಿಸಿದ ಫೈಲ್‌ಗಳು, ಮತ್ತು ಡೌನ್‌ಲೋಡ್ ಮಾಡಲು ಅಥವಾ ಮುಂದುವರಿಸಲು ಆನ್‌ಲೈನ್ ರೆಕಾರ್ಡಿಂಗ್‌ಗಳು';

  @override
  String get downloadKeyRefresh => 'ಡೌನ್‌ಲೋಡ್‌ಗಳನ್ನು ರಿಫ್ರೆಶ್ ಮಾಡಿ';

  @override
  String get downloadKeyFindOnline =>
      'ಆನ್‌ಲೈನ್‌ನಲ್ಲಿ ರೆಕಾರ್ಡಿಂಗ್‌ಗಳನ್ನು ಹುಡುಕಿ';

  @override
  String get downloadKeyReadStatus => 'ಸ್ಥಿತಿಯನ್ನು ಓದಿ';

  @override
  String get downloadKeyCancel => 'ಡೌನ್‌ಲೋಡ್ ರದ್ದುಗೊಳಿಸಿ';

  @override
  String get downloadKeyPack =>
      'ಪಟ್ಟಿಯಲ್ಲಿರುವ ರೆಕಾರ್ಡಿಂಗ್‌ಗಳನ್ನು ಡೌನ್‌ಲೋಡ್ ಮಾಡಿ';

  @override
  String get downloadErrInvalidInfo =>
      'ಡೌನ್‌ಲೋಡ್ ಮಾಹಿತಿ ಅಮಾನ್ಯವಾಗಿದೆ ಅಥವಾ ಬೇರೆ ಖಾತೆಗೆ ಸೇರಿದೆ. ಈಗಿರುವ ಫೈಲ್‌ಗಳನ್ನು ಇಟ್ಟುಕೊಳ್ಳಲಾಗಿದೆ.';

  @override
  String get downloadErrSignInToOpen =>
      'ಡೌನ್‌ಲೋಡ್ ಮಾಡಿದ ಪಾಠಗಳನ್ನು ತೆರೆಯುವ ಮೊದಲು ಸೈನ್ ಇನ್ ಮಾಡಿ.';

  @override
  String get downloadErrAccountChanged =>
      'ನಿಮ್ಮ ಖಾತೆ ಬದಲಾಗಿದೆ. ಡೌನ್‌ಲೋಡ್‌ಗಳನ್ನು ಮತ್ತೆ ತೆರೆಯಿರಿ.';

  @override
  String get downloadErrNoStorage =>
      'ಈ ಸಾಧನದಲ್ಲಿ ಡೌನ್‌ಲೋಡ್ ಸ್ಟೋರೇಜ್ ಲಭ್ಯವಿಲ್ಲ.';

  @override
  String get downloadErrStorageUnavailable =>
      'ಡೌನ್‌ಲೋಡ್ ಸ್ಟೋರೇಜ್ ಲಭ್ಯವಿಲ್ಲ. ಖಾಲಿ ಜಾಗ ಪರಿಶೀಲಿಸಿ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ. ಈಗಿರುವ ಫೈಲ್‌ಗಳನ್ನು ಉದ್ದೇಶಪೂರ್ವಕವಾಗಿ ತೆಗೆದುಹಾಕಿಲ್ಲ.';

  @override
  String get downloadErrRecordsUnreadable =>
      'ಡೌನ್‌ಲೋಡ್ ದಾಖಲೆಗಳನ್ನು ಓದಲು ಆಗಲಿಲ್ಲ. ಈಗಿರುವ ಫೈಲ್‌ಗಳನ್ನು ಇಟ್ಟುಕೊಳ್ಳಲಾಗಿದೆ.';

  @override
  String get downloadErrRecordUnreadable =>
      'ಒಂದು ಡೌನ್‌ಲೋಡ್ ದಾಖಲೆಯನ್ನು ಓದಲು ಆಗಲಿಲ್ಲ. ಈಗಿರುವ ಫೈಲ್‌ಗಳನ್ನು ಇಟ್ಟುಕೊಳ್ಳಲಾಗಿದೆ.';

  @override
  String get downloadErrIdentityMismatch =>
      'ಡೌನ್‌ಲೋಡ್ ಗುರುತು ಅದರ ದಾಖಲೆಗೆ ಹೊಂದುತ್ತಿಲ್ಲ.';

  @override
  String get downloadErrSignInToRenew =>
      'ಡೌನ್‌ಲೋಡ್ ಪ್ರವೇಶ ನವೀಕರಿಸುವ ಮೊದಲು ಆನ್‌ಲೈನ್‌ನಲ್ಲಿ ಸೈನ್ ಇನ್ ಮಾಡಿ.';

  @override
  String get downloadErrSignInChanged =>
      'ನಿಮ್ಮ ಸೈನ್ ಇನ್ ಬದಲಾಗಿದೆ. ಡೌನ್‌ಲೋಡ್‌ಗಳನ್ನು ಮತ್ತೆ ತೆರೆಯಿರಿ.';

  @override
  String get downloadErrAccessNotConfirmed =>
      'ಈ ಖಾತೆಗೆ ರೆಕಾರ್ಡಿಂಗ್ ಪ್ರವೇಶ ಇನ್ನು ಖಚಿತವಾಗಿಲ್ಲ. ನವೀಕರಿಸಲು ಮತ್ತೆ ಸಂಪರ್ಕಿಸಿ ಮತ್ತು ಸೈನ್ ಇನ್ ಮಾಡಿ. ಉಳಿಸಿದ ಫೈಲ್ ಅನ್ನು ಇಟ್ಟುಕೊಳ್ಳಲಾಗಿದೆ.';

  @override
  String get downloadErrTooLarge =>
      'ಈ ರೆಕಾರ್ಡಿಂಗ್ 50 MB ಡೌನ್‌ಲೋಡ್ ಮಿತಿಗಿಂತ ದೊಡ್ಡದಾಗಿದೆ.';

  @override
  String get downloadErrRenewServer =>
      'ಸರ್ವರ್ ಈ ರೆಕಾರ್ಡಿಂಗ್ ಅನ್ನು ನವೀಕರಿಸಲು ಆಗಲಿಲ್ಲ. ನಂತರ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get downloadErrInvalidServerInfo =>
      'ಸರ್ವರ್ ಅಮಾನ್ಯ ಡೌನ್‌ಲೋಡ್ ಮಾಹಿತಿಯನ್ನು ಕಳುಹಿಸಿದೆ.';

  @override
  String get downloadErrDifferentRecording =>
      'ಸರ್ವರ್ ಬೇರೆ ರೆಕಾರ್ಡಿಂಗ್ ಅನ್ನು ಕಳುಹಿಸಿದೆ.';

  @override
  String get downloadErrTimedOut =>
      'ಸಂಪರ್ಕದ ಸಮಯ ಮೀರಿದೆ. ಮತ್ತೆ ಸಂಪರ್ಕಿಸಿ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get downloadErrRenewConnect =>
      'ಈ ರೆಕಾರ್ಡಿಂಗ್ ನವೀಕರಿಸಲು ಸಂಪರ್ಕಿಸಲು ಆಗಲಿಲ್ಲ. ನಿಮ್ಮ ಇಂಟರ್ನೆಟ್ ಸಂಪರ್ಕ ಪರಿಶೀಲಿಸಿ.';

  @override
  String get downloadErrClockUnreadable =>
      'ಆಫ್‌ಲೈನ್ ಸಮಯದ ದಾಖಲೆಯನ್ನು ಓದಲು ಆಗಲಿಲ್ಲ. ಸಂಪರ್ಕಿಸಿ ಮತ್ತು ಪ್ರವೇಶ ನವೀಕರಿಸಿ.';

  @override
  String get downloadErrClockBackwards =>
      'ಫೋನ್‌ನ ಗಡಿಯಾರ ಹಿಂದಕ್ಕೆ ಹೋಗಿದೆ. ಅದರ ದಿನಾಂಕ ಸರಿಪಡಿಸಿ ಮತ್ತು ಪ್ರವೇಶ ನವೀಕರಿಸಲು ಮತ್ತೆ ಸಂಪರ್ಕಿಸಿ.';

  @override
  String get downloadErrExpired =>
      '30 ದಿನಗಳ ನಂತರ ಆಫ್‌ಲೈನ್ ಪ್ರವೇಶ ಮುಗಿದಿದೆ. ಇಂಟರ್ನೆಟ್‌ಗೆ ಸಂಪರ್ಕಿಸಿ ಈ ಪಾಠವನ್ನು ನವೀಕರಿಸಿ. ನಿಮ್ಮ ಪ್ರಗತಿ ಮತ್ತು ಡೌನ್‌ಲೋಡ್ ಮಾಡಿದ ಫೈಲ್ ಅನ್ನು ಇಟ್ಟುಕೊಳ್ಳಲಾಗಿದೆ.';

  @override
  String get downloadErrIncompleteForPlayback =>
      'ಆಫ್‌ಲೈನ್‌ನಲ್ಲಿ ಕೇಳುವ ಮೊದಲು ಈ ಪಾಠವನ್ನು ಪೂರ್ತಿಯಾಗಿ ಡೌನ್‌ಲೋಡ್ ಮಾಡಿ.';

  @override
  String get downloadErrRenewalRequired =>
      'ಪ್ರವೇಶವನ್ನು ನವೀಕರಿಸಬೇಕು. ಈ ಡೌನ್‌ಲೋಡ್ ಪ್ಲೇ ಮಾಡುವ ಮೊದಲು ಸಂಪರ್ಕಿಸಿ ನವೀಕರಿಸಿ.';

  @override
  String get downloadErrDamaged =>
      'ಡೌನ್‌ಲೋಡ್ ಮಾಡಿದ ರೆಕಾರ್ಡಿಂಗ್ ಅಪೂರ್ಣವಾಗಿದೆ ಅಥವಾ ಹಾಳಾಗಿದೆ. ಈ ಡೌನ್‌ಲೋಡ್ ತೆಗೆದುಹಾಕಿ ಮತ್ತೆ ಡೌನ್‌ಲೋಡ್ ಮಾಡಿ. ಪ್ರಗತಿ ಮತ್ತು ಬುಕ್‌ಮಾರ್ಕ್‌ಗಳು ಬೇರೆಯಾಗಿ ಇರುತ್ತವೆ.';

  @override
  String get downloadErrDownloadFirst => 'ಮೊದಲು ಈ ಪಾಠವನ್ನು ಡೌನ್‌ಲೋಡ್ ಮಾಡಿ.';

  @override
  String get downloadErrRecordingChangedRenew =>
      'ಈ ರೆಕಾರ್ಡಿಂಗ್ ಬದಲಾಗಿದೆ. ಅದರ ಡೌನ್‌ಲೋಡ್ ತೆಗೆದುಹಾಕಿ ಮತ್ತು ಈಗಿನ ರೆಕಾರ್ಡಿಂಗ್ ಡೌನ್‌ಲೋಡ್ ಮಾಡಿ. ಪ್ರಗತಿ ಮತ್ತು ಬುಕ್‌ಮಾರ್ಕ್‌ಗಳನ್ನು ಇಟ್ಟುಕೊಳ್ಳಲಾಗಿದೆ.';

  @override
  String get downloadErrCancelledAnyPartial =>
      'ಡೌನ್‌ಲೋಡ್ ರದ್ದುಗೊಂಡಿದೆ. ನೀವು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಲು ಯಾವುದೇ ಅರ್ಧ ಫೈಲ್ ಅನ್ನು ಇಟ್ಟುಕೊಳ್ಳಲಾಗಿದೆ.';

  @override
  String get downloadErrRecordingChanged =>
      'ರೆಕಾರ್ಡಿಂಗ್ ಬದಲಾಗಿದೆ. ಈಗಿನ ಆವೃತ್ತಿಯನ್ನು ಡೌನ್‌ಲೋಡ್ ಮಾಡುವ ಮೊದಲು ಅದರ ಹಳೆಯ ಡೌನ್‌ಲೋಡ್ ತೆಗೆದುಹಾಕಿ. ಪ್ರಗತಿಯನ್ನು ಇಟ್ಟುಕೊಳ್ಳಲಾಗಿದೆ.';

  @override
  String get downloadErrSavedDamaged =>
      'ಉಳಿಸಿದ ರೆಕಾರ್ಡಿಂಗ್ ಹಾಳಾಗಿದೆ. ಮತ್ತೆ ಪ್ರಯತ್ನಿಸುವ ಮೊದಲು ಅದರ ಡೌನ್‌ಲೋಡ್ ತೆಗೆದುಹಾಕಿ.';

  @override
  String get downloadErrQuota =>
      'ನಿಮ್ಮ ಖಾತೆ ತನ್ನ 50 MB ಡೌನ್‌ಲೋಡ್ ಮಿತಿಯನ್ನು ತಲುಪಿದೆ. ನಿಮ್ಮ ಯಾವ ಡೌನ್‌ಲೋಡ್‌ಗಳನ್ನು ತೆಗೆದುಹಾಕಬೇಕು ಎಂದು ಆಯ್ಕೆ ಮಾಡಿ, ನಂತರ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ. ಏನನ್ನೂ ಅಳಿಸಲಾಗಿಲ್ಲ.';

  @override
  String get downloadErrPartialInvalid =>
      'ಅರ್ಧ ಡೌನ್‌ಲೋಡ್ ಆದ ಡೇಟಾ ಸರಿಯಾಗಿಲ್ಲ. ಮತ್ತೆ ಪ್ರಯತ್ನಿಸುವ ಮೊದಲು ಅದನ್ನು ತೆಗೆದುಹಾಕಿ.';

  @override
  String get downloadErrIntegrityPartial =>
      'ಡೌನ್‌ಲೋಡ್ ಸಮಗ್ರತೆ ಪರಿಶೀಲನೆ ವಿಫಲವಾಯಿತು. ಮತ್ತೆ ಪ್ರಯತ್ನಿಸುವ ಮೊದಲು ಈ ಅರ್ಧ ಡೌನ್‌ಲೋಡ್ ಅನ್ನು ತೆಗೆದುಹಾಕಿ.';

  @override
  String get downloadErrSignInToDownload =>
      'ಡೌನ್‌ಲೋಡ್ ಮಾಡುವ ಮೊದಲು ಸೈನ್ ಇನ್ ಮಾಡಿ.';

  @override
  String get downloadErrCancelledExplicit =>
      'ಡೌನ್‌ಲೋಡ್ ರದ್ದಾಗಿದೆ. ನೀವು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಲು ಅರ್ಧ ಡೇಟಾವನ್ನು ಇಟ್ಟುಕೊಳ್ಳಲಾಗಿದೆ.';

  @override
  String get downloadErrAccessDenied =>
      'ಡೌನ್‌ಲೋಡ್ ಪ್ರವೇಶ ನಿರಾಕರಿಸಲಾಗಿದೆ. ಮತ್ತೆ ಸಂಪರ್ಕಿಸಿ ಮತ್ತು ಪ್ರವೇಶವನ್ನು ನವೀಕರಿಸಿ.';

  @override
  String get downloadErrUnexpectedPartial =>
      'ಸರ್ವರ್ ಅನಿರೀಕ್ಷಿತವಾಗಿ ಅರ್ಧ ರೆಕಾರ್ಡಿಂಗ್ ಕಳುಹಿಸಿದೆ. ಈಗಿರುವ ಡೇಟಾವನ್ನು ಅಳಿಸದೆ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get downloadErrCouldNotDownload =>
      'ರೆಕಾರ್ಡಿಂಗ್ ಡೌನ್‌ಲೋಡ್ ಆಗಲಿಲ್ಲ. ನಿಮ್ಮ ಸಂಪರ್ಕ ಪರಿಶೀಲಿಸಿ ಮತ್ತು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get downloadErrSizeChanged =>
      'ರೆಕಾರ್ಡಿಂಗ್ ಗಾತ್ರ ಬದಲಾಗಿದೆ. ಮತ್ತೆ ಡೌನ್‌ಲೋಡ್ ಮಾಡಲು ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get downloadErrAccountChangedStopped =>
      'ನಿಮ್ಮ ಖಾತೆ ಬದಲಾಗಿದೆ. ಡೌನ್‌ಲೋಡ್ ನಿಲ್ಲಿಸಲಾಗಿದೆ.';

  @override
  String get downloadErrExceededSize =>
      'ರೆಕಾರ್ಡಿಂಗ್ ತಿಳಿಸಿದ ಗಾತ್ರಕ್ಕಿಂತ ದೊಡ್ಡದಾಗಿದೆ. ಡೌನ್‌ಲೋಡ್ ನಿಲ್ಲಿಸಲಾಗಿದೆ.';

  @override
  String get downloadErrIntegrity =>
      'ಡೌನ್‌ಲೋಡ್ ಸಮಗ್ರತೆ ಪರಿಶೀಲನೆ ವಿಫಲವಾಯಿತು. ಅಪೂರ್ಣ ಡೌನ್‌ಲೋಡ್ ಅನ್ನು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ, ಅಥವಾ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸುವ ಮೊದಲು ಹಾಳಾದ ಅರ್ಧ ಡೇಟಾವನ್ನು ತೆಗೆದುಹಾಕಿ.';

  @override
  String get downloadErrSignInChangedStopped =>
      'ನಿಮ್ಮ ಸೈನ್ ಇನ್ ಬದಲಾಗಿದೆ. ಇನ್‌ಸ್ಟಾಲ್ ಆಗುವ ಮೊದಲೇ ಡೌನ್‌ಲೋಡ್ ನಿಲ್ಲಿಸಲಾಗಿದೆ.';

  @override
  String get downloadErrTimedOutPartial =>
      'ಡೌನ್‌ಲೋಡ್ ಸಮಯ ಮೀರಿದೆ. ಅರ್ಧ ಡೇಟಾವನ್ನು ಇಟ್ಟುಕೊಳ್ಳಲಾಗಿದೆ; ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಲು ಡೌನ್‌ಲೋಡ್ ಆಯ್ಕೆ ಮಾಡಿ.';

  @override
  String get downloadErrCancelledRetry =>
      'ಡೌನ್‌ಲೋಡ್ ರದ್ದಾಗಿದೆ. ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಲು ಅರ್ಧ ಡೇಟಾವನ್ನು ಇಟ್ಟುಕೊಳ್ಳಲಾಗಿದೆ.';

  @override
  String get downloadErrInterrupted =>
      'ಡೌನ್‌ಲೋಡ್‌ಗೆ ಅಡಚಣೆಯಾಗಿದೆ. ಅರ್ಧ ಡೇಟಾವನ್ನು ಇಟ್ಟುಕೊಳ್ಳಲಾಗಿದೆ; ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಲು ಡೌನ್‌ಲೋಡ್ ಆಯ್ಕೆ ಮಾಡಿ.';

  @override
  String get libraryErrStorageUnavailable =>
      'ಈ ಸಾಧನದಲ್ಲಿ ಕಲಿಕೆಯ ಸಂಗ್ರಹಣೆ ಲಭ್ಯವಿಲ್ಲ. ನಿಮ್ಮ ಈಗಿರುವ ಡೇಟಾವನ್ನು ಬದಲಾಯಿಸಲಾಗಿಲ್ಲ.';

  @override
  String get libraryErrStorageNotOpened =>
      'ಕಲಿಕೆಯ ಸಂಗ್ರಹಣೆಯನ್ನು ತೆರೆಯಲು ಆಗಲಿಲ್ಲ. ಖಾಲಿ ಜಾಗ ಪರಿಶೀಲಿಸಿ ಮತ್ತು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get libraryErrNoStorageLocation =>
      'ಈ ಸಾಧನವು ಕಲಿಕೆಯ ಸಂಗ್ರಹಣೆಗೆ ಜಾಗವನ್ನು ನೀಡಲಿಲ್ಲ. ನಿಮ್ಮ ಈಗಿರುವ ಡೇಟಾವನ್ನು ಬದಲಾಯಿಸಲಾಗಿಲ್ಲ.';

  @override
  String get libraryErrStartLessonFirst =>
      'ಪ್ರಗತಿ ಉಳಿಸಲು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸುವ ಮೊದಲು ಒಂದು ಪಾಠವನ್ನು ಪ್ರಾರಂಭಿಸಿ.';

  @override
  String get libraryErrProgressNotSaved =>
      'ಕಲಿಕೆಯ ಪ್ರಗತಿ ಉಳಿಸಲಾಗಿಲ್ಲ. ಸಂಗ್ರಹಣೆ ಲಭ್ಯವಾದಾಗ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get libraryErrChoosePosition => 'ಪಾಠದೊಳಗಿನ ಒಂದು ಸ್ಥಾನವನ್ನು ಆಯ್ಕೆ ಮಾಡಿ';

  @override
  String get libraryErrChooseSpeed =>
      '0.25 ರಿಂದ 3 ರ ನಡುವೆ ಪ್ಲೇಬ್ಯಾಕ್ ವೇಗವನ್ನು ಆಯ್ಕೆ ಮಾಡಿ';

  @override
  String get libraryErrChooseBookmarkPosition =>
      'ಪಾಠದೊಳಗೆ ಬುಕ್‌ಮಾರ್ಕ್ ಸ್ಥಾನವನ್ನು ಆಯ್ಕೆ ಮಾಡಿ';

  @override
  String get libraryErrBookmarkNotSaved =>
      'ಪ್ರಗತಿ ಉಳಿಸುವಿಕೆ ಲಭ್ಯವಿಲ್ಲ. ಬುಕ್‌ಮಾರ್ಕ್ ಉಳಿಸಲಾಗಿಲ್ಲ.';

  @override
  String get libraryErrBookmarkChangesUnavailable =>
      'ಪ್ರಗತಿ ಉಳಿಸುವಿಕೆ ಮರಳಿ ಬರುವವರೆಗೆ ಬುಕ್‌ಮಾರ್ಕ್ ಬದಲಾವಣೆಗಳು ಲಭ್ಯವಿಲ್ಲ.';

  @override
  String get libraryErrRepeatNotSaved =>
      'ಪ್ರಗತಿ ಉಳಿಸುವಿಕೆ ಲಭ್ಯವಿಲ್ಲ. ಪುನರಾವರ್ತನೆ ಬಿಂದುಗಳನ್ನು ಉಳಿಸಲಾಗಿಲ್ಲ.';

  @override
  String get libraryErrSetRepeatFirst =>
      'ಮೊದಲು ಈ ಪಾಠದೊಳಗೆ ಪ್ರಾರಂಭ ಬಿಂದು ಮತ್ತು ಅದರ ನಂತರದ ಅಂತ್ಯ ಬಿಂದುವನ್ನು ಹೊಂದಿಸಿ';

  @override
  String get libraryErrRepeatFailed =>
      'ಪುನರಾವರ್ತನೆ ಪ್ಲೇಬ್ಯಾಕ್ ವಿಫಲವಾಯಿತು. ವಿರಾಮಗೊಳಿಸಿ ಮತ್ತು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get libraryScreenBack => 'ಹಿಂದೆ';

  @override
  String get libraryScreenRefreshTarget =>
      'ಆಡಿಯೋ ಫೈಲ್‌ಗಳನ್ನು ರಿಫ್ರೆಶ್ ಮಾಡಿ, ಕೀ 1';

  @override
  String get libraryScreenPauseSessionTarget =>
      'ಇಡೀ ಸೆಷನ್‌ಗೆ ಆಡಿಯೋ ವಿರಾಮಗೊಳಿಸಿ, ಕೀ 3';

  @override
  String get libraryScreenUploadTarget => 'ಆಡಿಯೋ ಅಪ್‌ಲೋಡ್ ಮಾಡಿ, ಕೀ 2';

  @override
  String libraryScreenStopPreviewTarget(String title) {
    return '$title ಖಾಸಗಿ ಪೂರ್ವವೀಕ್ಷಣೆ ನಿಲ್ಲಿಸಿ. ಇದನ್ನು ನೀವು ಮಾತ್ರ ಕೇಳಬಹುದು.';
  }

  @override
  String libraryScreenPreviewTarget(String title) {
    return '$title ಅನ್ನು ಖಾಸಗಿಯಾಗಿ ಪೂರ್ವವೀಕ್ಷಿಸಿ. ಇದನ್ನು ನೀವು ಮಾತ್ರ ಕೇಳಬಹುದು.';
  }

  @override
  String libraryScreenBroadcastTarget(String title) {
    return '$title ಅನ್ನು ಸೆಷನ್‌ನಲ್ಲಿರುವ ಎಲ್ಲರಿಗೂ ಪ್ಲೇ ಮಾಡಿ';
  }

  @override
  String get libraryScreenPreviewFinished => 'ಪೂರ್ವವೀಕ್ಷಣೆ ಮುಗಿದಿದೆ';

  @override
  String get libraryScreenNoRecordings =>
      'ಇನ್ನೂ ಯಾವುದೇ ರೆಕಾರ್ಡಿಂಗ್ ಇಲ್ಲ. ಆಡಿಯೋ ಅಪ್‌ಲೋಡ್ ಮಾಡಲು 2 ಒತ್ತಿ.';

  @override
  String libraryScreenRecordingsLoaded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ರೆಕಾರ್ಡಿಂಗ್‌ಗಳು ಲೋಡ್ ಆಗಿವೆ.',
    );
    return '$_temp0';
  }

  @override
  String get libraryScreenLoadFailed =>
      'ರೆಕಾರ್ಡಿಂಗ್‌ಗಳನ್ನು ಲೋಡ್ ಮಾಡಲು ಆಗಲಿಲ್ಲ. ನಿಮ್ಮ ಇಂಟರ್ನೆಟ್ ಸಂಪರ್ಕ ಪರಿಶೀಲಿಸಿ, ನಂತರ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಲು 1 ಒತ್ತಿ.';

  @override
  String get libraryScreenTitleRequired => 'ಶೀರ್ಷಿಕೆ ಅಗತ್ಯವಿದೆ';

  @override
  String get libraryScreenUploadDialogName => 'ಆಡಿಯೋ ಅಪ್‌ಲೋಡ್ ಮಾಡಿ';

  @override
  String get libraryScreenEditTitleKey => 'ಶೀರ್ಷಿಕೆ ಬದಲಿಸಿ';

  @override
  String get libraryScreenEditDescriptionKey => 'ವಿವರಣೆ ಬದಲಿಸಿ';

  @override
  String get libraryScreenUploadKey => 'ಅಪ್‌ಲೋಡ್';

  @override
  String get libraryScreenCancelKey => 'ರದ್ದುಮಾಡಿ';

  @override
  String get libraryScreenTitleField => 'ಆಡಿಯೋ ಶೀರ್ಷಿಕೆ, ಅಗತ್ಯ';

  @override
  String get libraryScreenDescriptionField => 'ಆಡಿಯೋ ವಿವರಣೆ, ಐಚ್ಛಿಕ';

  @override
  String get libraryScreenCancelUpload => 'ಅಪ್‌ಲೋಡ್ ರದ್ದುಮಾಡಿ';

  @override
  String get libraryScreenPickFailed => 'ಫೈಲ್ ಆಯ್ಕೆ ಮಾಡಲು ವಿಫಲವಾಯಿತು';

  @override
  String get libraryScreenChooseWorkspace =>
      'ಆಡಿಯೋ ಅಪ್‌ಲೋಡ್ ಮಾಡುವ ಮೊದಲು ಶಿಕ್ಷಕರ ಡ್ಯಾಶ್‌ಬೋರ್ಡ್‌ನಲ್ಲಿ ತರಗತಿ ಮತ್ತು ವಿಷಯದ ವರ್ಕ್‌ಸ್ಪೇಸ್ ಆಯ್ಕೆ ಮಾಡಿ.';

  @override
  String libraryScreenUploading(String title) {
    return '$title ಅಪ್‌ಲೋಡ್ ಆಗುತ್ತಿದೆ. ಪ್ರತಿ 25 ಪ್ರತಿಶತಕ್ಕೆ ನೀವು ಪ್ರಗತಿಯನ್ನು ಕೇಳುತ್ತೀರಿ.';
  }

  @override
  String libraryScreenUploaded(String title) {
    return '$title ಅಪ್‌ಲೋಡ್ ಆಗಿದೆ.';
  }

  @override
  String libraryScreenUploadProgress(String title, String percent) {
    return '$title: $percent ಪ್ರತಿಶತ ಅಪ್‌ಲೋಡ್ ಆಗಿದೆ.';
  }

  @override
  String libraryScreenPreviewStopped(String title) {
    return '$title ಪೂರ್ವವೀಕ್ಷಣೆ ನಿಂತಿದೆ';
  }

  @override
  String libraryScreenPreviewing(String title) {
    return '$title ಅನ್ನು ಖಾಸಗಿಯಾಗಿ ಪೂರ್ವವೀಕ್ಷಿಸಲಾಗುತ್ತಿದೆ';
  }

  @override
  String libraryScreenPlayFailed(String title) {
    return '$title ಪ್ಲೇ ಮಾಡಲು ಆಗಲಿಲ್ಲ. ನಿಮ್ಮ ಸಂಪರ್ಕ ಪರಿಶೀಲಿಸಿ ಮತ್ತು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';
  }

  @override
  String get libraryScreenNoActiveSession => 'ಯಾವುದೇ ಸಕ್ರಿಯ ಸೆಷನ್ ಇಲ್ಲ';

  @override
  String libraryScreenSelectedForSession(String title) {
    return 'ಸೆಷನ್‌ಗಾಗಿ $title ಆಯ್ಕೆ ಮಾಡಲಾಗಿದೆ';
  }

  @override
  String get libraryScreenAudioSelectedTitle => 'ಆಡಿಯೋ ಆಯ್ಕೆ ಮಾಡಲಾಗಿದೆ';

  @override
  String libraryScreenPlayForEveryoneNow(String title) {
    return '\"$title\" ಅನ್ನು ಈಗ ಸೆಷನ್‌ನಲ್ಲಿರುವ ಎಲ್ಲರಿಗೂ ಪ್ಲೇ ಮಾಡಬೇಕೇ?';
  }

  @override
  String get libraryScreenNotYet => 'ಈಗ ಬೇಡ';

  @override
  String get libraryScreenPlayNow => 'ಈಗ ಪ್ಲೇ ಮಾಡಿ';

  @override
  String get libraryScreenSelectFailed => 'ಆಡಿಯೋ ಆಯ್ಕೆ ಮಾಡಲು ವಿಫಲವಾಯಿತು';

  @override
  String get libraryScreenPlaybackAccepted =>
      'ತರಗತಿ ಪ್ಲೇಬ್ಯಾಕ್ ವಿನಂತಿ ಸ್ವೀಕರಿಸಲಾಗಿದೆ';

  @override
  String get libraryScreenPlaybackFailed => 'ಪ್ಲೇಬ್ಯಾಕ್ ಪ್ರಾರಂಭಿಸಲು ವಿಫಲವಾಯಿತು';

  @override
  String get libraryScreenPauseAccepted => 'ತರಗತಿ ವಿರಾಮ ವಿನಂತಿ ಸ್ವೀಕರಿಸಲಾಗಿದೆ';

  @override
  String get libraryScreenPauseFailed => 'ಆಡಿಯೋ ವಿರಾಮಗೊಳಿಸಲು ವಿಫಲವಾಯಿತು';

  @override
  String get libraryScreenAudioLibraryName => 'ಆಡಿಯೋ ಲೈಬ್ರರಿ';

  @override
  String get libraryScreenAudioLibrarySections =>
      'ರೆಕಾರ್ಡಿಂಗ್‌ಗಳು, ಪ್ಲೇಬ್ಯಾಕ್ ಮತ್ತು ಧ್ವನಿ ನಿಯಂತ್ರಣಗಳು, ರೆಕಾರ್ಡಿಂಗ್ ಹಂಚಿಕೆ, ಮತ್ತು ಲಭ್ಯವಿದ್ದಾಗ ಅಪ್‌ಲೋಡ್ ಸಾಧನಗಳು';

  @override
  String get libraryScreenRefreshKey => 'ಆಡಿಯೋ ಫೈಲ್‌ಗಳನ್ನು ರಿಫ್ರೆಶ್ ಮಾಡಿ';

  @override
  String get libraryScreenUploadAudioKey => 'ಆಡಿಯೋ ಅಪ್‌ಲೋಡ್ ಮಾಡಿ';

  @override
  String get libraryScreenPauseSessionKey => 'ಸೆಷನ್ ಆಡಿಯೋ ವಿರಾಮಗೊಳಿಸಿ';

  @override
  String get libraryScreenBrowseTarget =>
      'ಮೊದಲ ಸಕ್ರಿಯ ತರಗತಿಗೆ ಹೋಗಿ. ಸಕ್ರಿಯ ಸೆಷನ್‌ಗಳನ್ನು ನೋಡಲು D-pad ಬಳಸಿ';

  @override
  String get libraryScreenRefreshClassesTarget => 'ತರಗತಿಗಳನ್ನು ರಿಫ್ರೆಶ್ ಮಾಡಿ';

  @override
  String get libraryScreenSearchClassField => 'ಹೆಸರಿನಿಂದ ತರಗತಿ ಹುಡುಕಿ';

  @override
  String get libraryScreenSearchTarget => 'ಹುಡುಕಿ';

  @override
  String get libraryScreenAllRecordedTarget =>
      'ಎಲ್ಲಾ ರೆಕಾರ್ಡ್ ಮಾಡಿದ ಆಡಿಯೋ ಫೈಲ್‌ಗಳು';

  @override
  String get libraryScreenContinueTarget =>
      'ಕಲಿಕೆ ಮುಂದುವರಿಸಿ. ನಿಮ್ಮ ಕೊನೆಯ ಅಪೂರ್ಣ ರೆಕಾರ್ಡ್ ಮಾಡಿದ ಪಾಠವನ್ನು ಹುಡುಕಿ';

  @override
  String get libraryScreenDownloadsTarget =>
      'ಡೌನ್‌ಲೋಡ್ ಮಾಡಿದ ಪಾಠಗಳು. ಆನ್‌ಲೈನ್ ಪಟ್ಟಿಗಳನ್ನು ಲೋಡ್ ಮಾಡದೆ ಉಳಿಸಿದ ರೆಕಾರ್ಡಿಂಗ್‌ಗಳನ್ನು ತೆರೆಯಿರಿ';

  @override
  String get libraryScreenNotesTarget =>
      'ಖಾಸಗಿ ಟಿಪ್ಪಣಿಗಳು ಮತ್ತು ಶಿಕ್ಷಕರ ರೆಕಾರ್ಡಿಂಗ್ ಕರಡುಗಳು. ಸಾಧನದ ಸಂಗ್ರಹಣೆಯಿಂದ ಕೆಲಸ ಮಾಡುತ್ತದೆ';

  @override
  String get libraryScreenMyPlaylistsTarget => 'ನನ್ನ ಖಾಸಗಿ ಪ್ಲೇಲಿಸ್ಟ್‌ಗಳು';

  @override
  String libraryScreenClassTarget(String title, String position, String total) {
    return '$title. ತರಗತಿ $position / $total';
  }

  @override
  String get libraryScreenAccountChanged =>
      'ನಿಮ್ಮ ಖಾತೆ ಬದಲಾಗಿದೆ. ಲೈಬ್ರರಿಯನ್ನು ಮತ್ತೆ ತೆರೆಯಿರಿ.';

  @override
  String get libraryScreenNoUnfinishedLesson =>
      'ಈ ಖಾತೆಗೆ ಯಾವುದೇ ಅಪೂರ್ಣ ಪಾಠ ಉಳಿಸಲಾಗಿಲ್ಲ. ಕಲಿಕೆ ಪ್ರಾರಂಭಿಸಲು ಒಂದು ರೆಕಾರ್ಡ್ ಮಾಡಿದ ಪಾಠವನ್ನು ಆಯ್ಕೆ ಮಾಡಿ.';

  @override
  String get libraryScreenAccessCheckFailed =>
      'ಪಾಠದ ಪ್ರವೇಶವನ್ನು ಪರಿಶೀಲಿಸಲು ಆಗಲಿಲ್ಲ. ಇಂಟರ್ನೆಟ್‌ಗೆ ಸಂಪರ್ಕಿಸಿ ಮತ್ತು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ. ನಿಮ್ಮ ಉಳಿಸಿದ ಪ್ರಗತಿಯನ್ನು ಇಟ್ಟುಕೊಳ್ಳಲಾಗಿದೆ.';

  @override
  String get libraryScreenUnfinishedUnavailable =>
      'ನಿಮ್ಮ ಅಪೂರ್ಣ ಪಾಠಗಳು ಸದ್ಯಕ್ಕೆ ಈ ಲೈಬ್ರರಿಯಲ್ಲಿ ಲಭ್ಯವಿಲ್ಲ. ನಿಮ್ಮ ಉಳಿಸಿದ ಪ್ರಗತಿ ಮತ್ತು ಬುಕ್‌ಮಾರ್ಕ್‌ಗಳನ್ನು ಇಟ್ಟುಕೊಳ್ಳಲಾಗಿದೆ.';

  @override
  String get libraryScreenOpeningNextUnfinished =>
      'ಇತ್ತೀಚಿನ ಪಾಠ ಇಲ್ಲಿ ಲಭ್ಯವಿಲ್ಲ. ಅದರ ನಂತರದ ಇತ್ತೀಚಿನ ಲಭ್ಯ ಅಪೂರ್ಣ ಪಾಠವನ್ನು ತೆರೆಯಲಾಗುತ್ತಿದೆ. ಉಳಿಸಿದ ಪ್ರಗತಿಯನ್ನು ಇಟ್ಟುಕೊಳ್ಳಲಾಗಿದೆ.';

  @override
  String get libraryScreenProgressOpenFailed =>
      'ಉಳಿಸಿದ ಕಲಿಕೆಯ ಪ್ರಗತಿಯನ್ನು ತೆರೆಯಲು ಆಗಲಿಲ್ಲ. ಸಂಗ್ರಹಣೆ, ನಿಮ್ಮ ಸಂಪರ್ಕ ಮತ್ತು ಸೈನ್ ಇನ್ ಪರಿಶೀಲಿಸಿ, ನಂತರ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get libraryScreenContinueLearningTitle => 'ಕಲಿಕೆ ಮುಂದುವರಿಸಿ';

  @override
  String get libraryScreenNoActiveClasses =>
      'ಈಗ ಯಾವುದೇ ಸಕ್ರಿಯ ತರಗತಿಗಳಿಲ್ಲ. ಎಲ್ಲಾ ಆಡಿಯೋ ಫೈಲ್‌ಗಳಿಗಾಗಿ 3 ಒತ್ತಿ.';

  @override
  String libraryScreenActiveClassesLoaded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ಸಕ್ರಿಯ ತರಗತಿಗಳು ಲೋಡ್ ಆಗಿವೆ.',
    );
    return '$_temp0';
  }

  @override
  String libraryScreenClassesRefreshFailed(String reason) {
    return '$reason ಸಕ್ರಿಯ ತರಗತಿಗಳನ್ನು ರಿಫ್ರೆಶ್ ಮಾಡಲು ಆಗಲಿಲ್ಲ. ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಲು 1 ಒತ್ತಿ. ಉಳಿಸಿದ ಡೌನ್‌ಲೋಡ್‌ಗಳು ಲಭ್ಯವಿವೆ.';
  }

  @override
  String get libraryScreenClassListUnreadable =>
      'ತರಗತಿ ಪಟ್ಟಿಯನ್ನು ಓದಲು ಆಗಲಿಲ್ಲ.';

  @override
  String get libraryScreenSessionFallback => 'ಸೆಷನ್';

  @override
  String get libraryScreenMyAudioLibraryTitle => 'ನನ್ನ ಆಡಿಯೋ ಲೈಬ್ರರಿ';

  @override
  String get libraryScreenAllAudioFilesTitle => 'ಎಲ್ಲಾ ಆಡಿಯೋ ಫೈಲ್‌ಗಳು';

  @override
  String get libraryScreenNoActiveClassesStaying =>
      'ಯಾವುದೇ ಸಕ್ರಿಯ ತರಗತಿಗಳಿಲ್ಲ. ಆಡಿಯೋ ಲೈಬ್ರರಿಯಲ್ಲೇ ಇರಲಾಗುತ್ತಿದೆ.';

  @override
  String libraryScreenFirstActiveClass(String title) {
    return '$title. ಮೊದಲ ಸಕ್ರಿಯ ತರಗತಿ. ಸಕ್ರಿಯ ತರಗತಿ ಸೆಷನ್‌ಗಳನ್ನು ನೋಡಲು D-pad ಮೇಲೆ ಮತ್ತು ಕೆಳಗೆ ಬಳಸಿ. ಆಯ್ಕೆ ಮಾಡಿದ ತರಗತಿಯ ರೆಕಾರ್ಡಿಂಗ್‌ಗಳನ್ನು ತೆರೆಯಲು ಓಕೆ ಒತ್ತಿ.';
  }

  @override
  String get libraryScreenRecordedLibraryName =>
      'ರೆಕಾರ್ಡ್ ಮಾಡಿದ ಆಡಿಯೋ ಲೈಬ್ರರಿ. ಆನ್‌ಲೈನ್ ಪಟ್ಟಿಗಳಿಗೆ ಇಂಟರ್ನೆಟ್ ಬೇಕು. ಡೌನ್‌ಲೋಡ್ ಮಾಡಿದ ಪಾಠಗಳು ಆಫ್‌ಲೈನ್ ಪ್ಲೇಬ್ಯಾಕ್‌ಗಾಗಿ ಪ್ರತ್ಯೇಕವಾಗಿ ತೆರೆಯುತ್ತವೆ.';

  @override
  String get libraryScreenRecordedLibrarySections =>
      'ಕಲಿಕೆ ಮುಂದುವರಿಸಿ, ಉಳಿಸಿದ ಡೌನ್‌ಲೋಡ್‌ಗಳು ಮತ್ತು ಖಾಸಗಿ ಟಿಪ್ಪಣಿಗಳು, ತರಗತಿ ಹುಡುಕಾಟ, ಮತ್ತು ಸಕ್ರಿಯ ತರಗತಿ ಸೆಷನ್‌ಗಳು';

  @override
  String get libraryScreenMyPlaylistsKey => 'ನನ್ನ ಖಾಸಗಿ ಪ್ಲೇಲಿಸ್ಟ್‌ಗಳು';

  @override
  String get libraryScreenWaitForPlayerNotes =>
      'ಅಧ್ಯಯನ ಟಿಪ್ಪಣಿಗಳನ್ನು ತೆರೆಯುವ ಮೊದಲು ರೆಕಾರ್ಡಿಂಗ್ ಪ್ಲೇಯರ್‌ಗಾಗಿ ಕಾಯಿರಿ.';

  @override
  String get libraryScreenStatusPlaying => 'ಪ್ಲೇ ಆಗುತ್ತಿದೆ';

  @override
  String get libraryScreenStatusPaused => 'ವಿರಾಮಗೊಳಿಸಲಾಗಿದೆ';

  @override
  String get libraryScreenUntitled => 'ಶೀರ್ಷಿಕೆ ಇಲ್ಲ';

  @override
  String get libraryScreenSubjectFallback => 'ವಿಷಯ';

  @override
  String get libraryScreenDownloadedLessonsName =>
      'ಡೌನ್‌ಲೋಡ್ ಮಾಡಿದ ಪಾಠಗಳು. ಪ್ಲೇ ಮಾಡುವ ಮೊದಲು ಈಗಿರುವ ಆಫ್‌ಲೈನ್ ಪ್ರವೇಶವನ್ನು ಪರಿಶೀಲಿಸಲಾಗುತ್ತದೆ.';

  @override
  String get libraryScreenClassAudioName =>
      'ಆಡಿಯೋ ಲೈಬ್ರರಿ. ಆನ್‌ಲೈನ್ ರೆಕಾರ್ಡಿಂಗ್‌ಗಳಿಗೆ ಇಂಟರ್ನೆಟ್ ಬೇಕು. ಆಫ್‌ಲೈನ್ ಪ್ಲೇಬ್ಯಾಕ್‌ಗಾಗಿ ಪಾಠಗಳನ್ನು ಡೌನ್‌ಲೋಡ್ ಮಾಡಿ.';

  @override
  String libraryScreenLessonPositionTarget(String position) {
    return 'ಪಾಠದ ಸ್ಥಾನ $position. 10 ಸೆಕೆಂಡ್ ಸರಿಸಲು ಎಡ ಅಥವಾ ಬಲ ಬಳಸಿ.';
  }

  @override
  String libraryScreenBack10Target(String key) {
    return '10 ಸೆಕೆಂಡ್ ಹಿಂದೆ, ಕೀ $key';
  }

  @override
  String libraryScreenPauseTarget(String title, String key) {
    return '$title ವಿರಾಮಗೊಳಿಸಿ, ಕೀ $key';
  }

  @override
  String libraryScreenResumeTarget(String title, String key) {
    return '$title ಮುಂದುವರಿಸಿ, ಕೀ $key';
  }

  @override
  String get libraryScreenLessonFallback => 'ಪಾಠ';

  @override
  String libraryScreenForward10Target(String key) {
    return '10 ಸೆಕೆಂಡ್ ಮುಂದೆ, ಕೀ $key';
  }

  @override
  String libraryScreenSlowerTarget(String key, String speed) {
    return 'ನಿಧಾನ, ಕೀ $key. ಈಗ $speed ಪಟ್ಟು';
  }

  @override
  String libraryScreenStopTarget(String title) {
    return '$title ನಿಲ್ಲಿಸಿ, ಕೀ 8';
  }

  @override
  String libraryScreenFasterTarget(String key, String speed) {
    return 'ವೇಗ, ಕೀ $key. ಈಗ $speed ಪಟ್ಟು';
  }

  @override
  String get libraryScreenDownloadsManageTarget =>
      'ಪಾಠಗಳನ್ನು ಡೌನ್‌ಲೋಡ್ ಮಾಡಿ ಅಥವಾ ಉಳಿಸಿದ ರೆಕಾರ್ಡಿಂಗ್‌ಗಳನ್ನು ನಿರ್ವಹಿಸಿ';

  @override
  String get libraryScreenStopSpeechTarget => 'ಧ್ವನಿ ನಿಲ್ಲಿಸಿ';

  @override
  String get libraryScreenUploadFirstTarget => 'ಮೊದಲ ಆಡಿಯೋ ಅಪ್‌ಲೋಡ್ ಮಾಡಿ';

  @override
  String get libraryScreenRefreshEmptyTarget =>
      'ಖಾಲಿ ಆಡಿಯೋ ಲೈಬ್ರರಿಯನ್ನು ರಿಫ್ರೆಶ್ ಮಾಡಿ';

  @override
  String get libraryScreenAddAudioTarget => 'ಆಡಿಯೋ ಸೇರಿಸಿ, ಕೀ 3';

  @override
  String get libraryScreenLessonTitleFallback => 'ಪಾಠ';

  @override
  String get libraryScreenDownloadedDescription =>
      'ಡೌನ್‌ಲೋಡ್ ಮಾಡಿದ ರೆಕಾರ್ಡಿಂಗ್. 30 ದಿನಗಳ ನಂತರ ಪ್ರವೇಶ ನವೀಕರಣ ಅಗತ್ಯ.';

  @override
  String libraryScreenSavedSubject(String id) {
    return 'ಉಳಿಸಿದ ವಿಷಯ $id';
  }

  @override
  String get libraryScreenDownloadsReadFailed =>
      'ಡೌನ್‌ಲೋಡ್ ಮಾಡಿದ ಪಾಠಗಳನ್ನು ಓದಲು ಆಗಲಿಲ್ಲ. ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಲು 1 ಒತ್ತಿ.';

  @override
  String get libraryScreenLoadFailedSignIn =>
      'ರೆಕಾರ್ಡಿಂಗ್‌ಗಳನ್ನು ಲೋಡ್ ಮಾಡಲು ಆಗಲಿಲ್ಲ. ನಿಮ್ಮ ಇಂಟರ್ನೆಟ್ ಸಂಪರ್ಕ ಮತ್ತು ಸೈನ್ ಇನ್ ಪರಿಶೀಲಿಸಿ, ನಂತರ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಲು 1 ಒತ್ತಿ.';

  @override
  String libraryScreenNoRecordingsFor(String name) {
    return '$name ಗೆ ಇನ್ನೂ ಯಾವುದೇ ರೆಕಾರ್ಡಿಂಗ್ ಇಲ್ಲ.';
  }

  @override
  String libraryScreenRecordingsLoadedFor(int count, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$name ಗೆ $count ರೆಕಾರ್ಡಿಂಗ್‌ಗಳು ಲೋಡ್ ಆಗಿವೆ.',
    );
    return '$_temp0';
  }

  @override
  String get libraryScreenLessonNoLongerAvailable =>
      'ಈ ಪಾಠ ಈಗ ಲಭ್ಯವಿಲ್ಲ. ನಿಮ್ಮ ಉಳಿಸಿದ ಪ್ರಗತಿ ಮತ್ತು ಬುಕ್‌ಮಾರ್ಕ್‌ಗಳನ್ನು ಇಟ್ಟುಕೊಳ್ಳಲಾಗಿದೆ.';

  @override
  String libraryScreenFailurePressRetry(String reason) {
    return '$reason ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಲು 1 ಒತ್ತಿ.';
  }

  @override
  String libraryScreenSubjectNumber(String id) {
    return 'ವಿಷಯ $id';
  }

  @override
  String get libraryScreenShowingAllSubjects =>
      'ಎಲ್ಲಾ ವಿಷಯಗಳ ಆಡಿಯೋ ತೋರಿಸಲಾಗುತ್ತಿದೆ';

  @override
  String libraryScreenShowingSubject(String subject, String count) {
    return '$subject ಆಡಿಯೋ ತೋರಿಸಲಾಗುತ್ತಿದೆ. $count ಫೈಲ್‌ಗಳು';
  }

  @override
  String libraryScreenPausedAt(String position) {
    return '$position ನಲ್ಲಿ ವಿರಾಮಗೊಳಿಸಲಾಗಿದೆ.';
  }

  @override
  String get libraryScreenCheckingOfflineAccess =>
      'ಇಂಟರ್ನೆಟ್ ಲಭ್ಯವಿಲ್ಲ. ನಿಮ್ಮ ಉಳಿಸಿದ ಆಫ್‌ಲೈನ್ ಪ್ರವೇಶವನ್ನು ಪರಿಶೀಲಿಸಲಾಗುತ್ತಿದೆ.';

  @override
  String libraryScreenPlayFailedSelectAgain(String title) {
    return '$title ಪ್ಲೇ ಮಾಡಲು ಆಗಲಿಲ್ಲ. ನಿಮ್ಮ ಸಂಪರ್ಕ ಪರಿಶೀಲಿಸಿ, ನಂತರ ಅದನ್ನು ಮತ್ತೆ ಆಯ್ಕೆ ಮಾಡಿ.';
  }

  @override
  String get libraryScreenNothingPlaying => 'ಏನೂ ಪ್ಲೇ ಆಗುತ್ತಿಲ್ಲ.';

  @override
  String libraryScreenTitleStopped(String title) {
    return '$title ನಿಂತಿದೆ.';
  }

  @override
  String libraryScreenNoLessonPlayingPress(String key) {
    return 'ಯಾವುದೇ ಪಾಠ ಪ್ಲೇ ಆಗುತ್ತಿಲ್ಲ. ಮೊದಲ ಪಾಠ ಪ್ಲೇ ಮಾಡಲು $key ಒತ್ತಿ.';
  }

  @override
  String get libraryScreenSeekFailed =>
      'ಪಾಠದ ಆ ಸ್ಥಾನಕ್ಕೆ ಹೋಗಲು ಆಗಲಿಲ್ಲ. ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get libraryScreenSlowestSpeed => 'ಈಗಾಗಲೇ ಅತ್ಯಂತ ನಿಧಾನ ವೇಗದಲ್ಲಿದೆ.';

  @override
  String get libraryScreenFastestSpeed => 'ಈಗಾಗಲೇ ಅತ್ಯಂತ ವೇಗದಲ್ಲಿದೆ.';

  @override
  String get libraryScreenSpeedFailed =>
      'ಪ್ಲೇಬ್ಯಾಕ್ ವೇಗ ಬದಲಾಯಿಸಲು ಆಗಲಿಲ್ಲ. ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get libraryScreenReadFileFailed => 'ಫೈಲ್ ಡೇಟಾ ಓದಲು ವಿಫಲವಾಯಿತು.';

  @override
  String get libraryScreenTitleFieldPlain => 'ಆಡಿಯೋ ಶೀರ್ಷಿಕೆ';

  @override
  String get libraryScreenChooseSessionsName =>
      'ಈ ಆಡಿಯೋಗಾಗಿ ಸೆಷನ್‌ಗಳನ್ನು ಆಯ್ಕೆ ಮಾಡಿ';

  @override
  String get libraryScreenConfirmSessionsKey =>
      'ಆಯ್ಕೆ ಮಾಡಿದ ಸೆಷನ್‌ಗಳನ್ನು ದೃಢೀಕರಿಸಿ';

  @override
  String libraryScreenSessionNumber(String id) {
    return 'ಸೆಷನ್ $id';
  }

  @override
  String libraryScreenSessionSelected(String name) {
    return '$name, ಆಯ್ಕೆ ಮಾಡಲಾಗಿದೆ';
  }

  @override
  String libraryScreenSessionNotSelected(String name) {
    return '$name, ಆಯ್ಕೆ ಮಾಡಿಲ್ಲ';
  }

  @override
  String libraryScreenConfirmSelectedSessions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ಆಯ್ಕೆ ಮಾಡಿದ $count ಸೆಷನ್‌ಗಳನ್ನು ದೃಢೀಕರಿಸಿ',
    );
    return '$_temp0';
  }

  @override
  String get libraryScreenUploadCancelledNoSession =>
      'ಅಪ್‌ಲೋಡ್ ರದ್ದಾಗಿದೆ. ಕನಿಷ್ಠ ಒಂದು ಸೆಷನ್ ಆಯ್ಕೆ ಮಾಡಿ, ನಂತರ ಮತ್ತೆ ಆಡಿಯೋ ಸೇರಿಸಲು 3 ಒತ್ತಿ.';

  @override
  String libraryScreenUploadingWait(String title) {
    return '$title ಅಪ್‌ಲೋಡ್ ಆಗುತ್ತಿದೆ. ದಯವಿಟ್ಟು ಕಾಯಿರಿ; ಮುಗಿದಾಗ ನಿಮಗೆ ಕೇಳಿಸುತ್ತದೆ.';
  }

  @override
  String get libraryScreenClassSubjectUnknown =>
      'ಸೆಷನ್‌ನ ತರಗತಿ ಮತ್ತು ವಿಷಯವನ್ನು ಗುರುತಿಸಲು ಆಗಲಿಲ್ಲ';

  @override
  String libraryScreenUploadFailedRetry(String title) {
    return '$title ಅಪ್‌ಲೋಡ್ ಆಗಲಿಲ್ಲ. ನಿಮ್ಮ ಸಂಪರ್ಕ ಪರಿಶೀಲಿಸಿ, ನಂತರ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಲು 3 ಒತ್ತಿ.';
  }

  @override
  String get libraryScreenAudioFallback => 'ಆಡಿಯೋ';

  @override
  String get libraryScreenClassLibraryName => 'ತರಗತಿ ಆಡಿಯೋ ಲೈಬ್ರರಿ';

  @override
  String get libraryScreenClassLibrarySections =>
      'ಪ್ಲೇಬ್ಯಾಕ್ ನಿಯಂತ್ರಣಗಳು, ಬುಕ್‌ಮಾರ್ಕ್‌ಗಳು ಮತ್ತು ಕಲಿಕೆಯ ಪ್ರಗತಿ, ವಿಷಯ ಫಿಲ್ಟರ್, ಡೌನ್‌ಲೋಡ್‌ಗಳು, ರೆಕಾರ್ಡಿಂಗ್‌ಗಳು, ಮತ್ತು ಲಭ್ಯವಿದ್ದಾಗ ಶಿಕ್ಷಕರ ಅಪ್‌ಲೋಡ್ ಸಾಧನಗಳು';

  @override
  String get libraryScreenSubjectFilterField => 'ವಿಷಯ ಫಿಲ್ಟರ್ (ಕೀ 2)';

  @override
  String get libraryScreenAllSubjects => 'ಎಲ್ಲಾ ವಿಷಯಗಳು';

  @override
  String get libraryScreenAddAudioOptionsName => 'ಆಡಿಯೋ ಸೇರಿಸುವ ಆಯ್ಕೆಗಳು';

  @override
  String get libraryScreenCloseAddAudioTarget =>
      'ಆಡಿಯೋ ಸೇರಿಸುವ ಆಯ್ಕೆಗಳನ್ನು ಮುಚ್ಚಿ';

  @override
  String get libraryScreenUploadNewTarget => 'ಹೊಸ ಫೈಲ್ ಅಪ್‌ಲೋಡ್ ಮಾಡಿ, ಕೀ 1';

  @override
  String get libraryScreenSelectExistingTarget =>
      'ಈಗಿರುವ ಲೈಬ್ರರಿಯಿಂದ ಆಯ್ಕೆ ಮಾಡಿ, ಕೀ 2';

  @override
  String libraryScreenRecordingsAvailable(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ರೆಕಾರ್ಡಿಂಗ್‌ಗಳು ಲಭ್ಯವಿವೆ.',
    );
    return '$_temp0';
  }

  @override
  String libraryScreenNoRecordingsMatch(String query) {
    return '$query ಗೆ ಹೊಂದುವ ಯಾವುದೇ ರೆಕಾರ್ಡಿಂಗ್ ಇಲ್ಲ.';
  }

  @override
  String libraryScreenRecordingsMatch(int count, String query) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ರೆಕಾರ್ಡಿಂಗ್‌ಗಳು $query ಗೆ ಹೊಂದುತ್ತವೆ.',
    );
    return '$_temp0';
  }

  @override
  String get libraryScreenNoUnlinkedRecordings =>
      'ಈ ತರಗತಿಗೆ ಜೋಡಿಸದ ಯಾವುದೇ ರೆಕಾರ್ಡಿಂಗ್ ಲಭ್ಯವಿಲ್ಲ.';

  @override
  String libraryScreenRecordingsAvailableChoose(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count ರೆಕಾರ್ಡಿಂಗ್‌ಗಳು ಲಭ್ಯವಿವೆ. ಆಯ್ಕೆ ಮಾಡಲು ಮೇಲೆ ಮತ್ತು ಕೆಳಗೆ ಬಳಸಿ, ಅಥವಾ ಶೀರ್ಷಿಕೆಯಿಂದ ಹುಡುಕಿ.',
    );
    return '$_temp0';
  }

  @override
  String libraryScreenAddFailed(String title) {
    return '$title ಸೇರಿಸಲು ಆಗಲಿಲ್ಲ. ನಿಮ್ಮ ಸಂಪರ್ಕ ಪರಿಶೀಲಿಸಿ ಮತ್ತು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';
  }

  @override
  String get libraryScreenSelectExistingName => 'ಈಗಿರುವ ಆಡಿಯೋ ಆಯ್ಕೆ ಮಾಡಿ';

  @override
  String get libraryScreenSelectExistingSections =>
      'ಹುಡುಕಾಟ ಮತ್ತು ಲಭ್ಯವಿರುವ ಪ್ರತಿಯೊಂದು ರೆಕಾರ್ಡಿಂಗ್';

  @override
  String get libraryScreenRefreshAvailableTarget =>
      'ಲಭ್ಯವಿರುವ ಆಡಿಯೋ ರಿಫ್ರೆಶ್ ಮಾಡಿ, ಕೀ 1';

  @override
  String get libraryScreenSearchRecordingsField =>
      'ಶೀರ್ಷಿಕೆಯಿಂದ ರೆಕಾರ್ಡಿಂಗ್‌ಗಳನ್ನು ಹುಡುಕಿ. ಟೈಪ್ ಮಾಡಲು ಓಕೆ ಒತ್ತಿ';

  @override
  String libraryScreenSearchRecordingsWithQuery(String query, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ರೆಕಾರ್ಡಿಂಗ್‌ಗಳನ್ನು ಹುಡುಕಿ, $query. $count ಹೊಂದಾಣಿಕೆಗಳು',
    );
    return '$_temp0';
  }

  @override
  String libraryScreenAddToSessionTarget(String title) {
    return '$title ಅನ್ನು ಈ ಸೆಷನ್‌ಗೆ ಸೇರಿಸಿ';
  }

  @override
  String get libraryScreenRepeatHelpTarget =>
      'ಆಡಿಯೋ ಲೈಬ್ರರಿ ಸಹಾಯವನ್ನು ಮತ್ತೆ ಕೇಳಿ';

  @override
  String get playlistBack => 'ಹಿಂದೆ';

  @override
  String get playlistCancel => 'ರದ್ದುಮಾಡಿ';

  @override
  String get playlistCreate => 'ರಚಿಸಿ';

  @override
  String get playlistRefresh => 'ರಿಫ್ರೆಶ್ ಮಾಡಿ';

  @override
  String playlistTeacherNone(String className, String subject) {
    return '$className, $subject ಗೆ ಇನ್ನೂ ಯಾವುದೇ ಪ್ಲೇಲಿಸ್ಟ್ ಇಲ್ಲ. ಒಂದನ್ನು ರಚಿಸಲು 2 ಒತ್ತಿ.';
  }

  @override
  String playlistTeacherLoaded(int count, String className, String subject) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ಪ್ಲೇಲಿಸ್ಟ್‌ಗಳು',
    );
    return '$className, $subject ಗೆ $_temp0 ಲೋಡ್ ಆಗಿವೆ';
  }

  @override
  String get playlistCreateClassTitle => 'ತರಗತಿ ಪ್ಲೇಲಿಸ್ಟ್ ರಚಿಸಿ';

  @override
  String get playlistTitleField => 'ಪ್ಲೇಲಿಸ್ಟ್ ಶೀರ್ಷಿಕೆ';

  @override
  String get playlistCancelCreation => 'ಪ್ಲೇಲಿಸ್ಟ್ ರಚನೆ ರದ್ದುಮಾಡಿ';

  @override
  String get playlistCreatePlaylist => 'ಪ್ಲೇಲಿಸ್ಟ್ ರಚಿಸಿ';

  @override
  String get playlistCreatePlaylistKey => 'ಪ್ಲೇಲಿಸ್ಟ್ ರಚಿಸಿ';

  @override
  String get playlistRefreshPlaylists => 'ಪ್ಲೇಲಿಸ್ಟ್‌ಗಳನ್ನು ರಿಫ್ರೆಶ್ ಮಾಡಿ';

  @override
  String playlistTeacherItemLabel(String title, String status, String count) {
    return '$title. $status. $count ಐಟಂಗಳು';
  }

  @override
  String playlistTeacherScreen(String className, String subject) {
    return 'ತರಗತಿ ಪ್ಲೇಲಿಸ್ಟ್‌ಗಳು, $className, $subject';
  }

  @override
  String get playlistStatusArchived => 'ಆರ್ಕೈವ್ ಮಾಡಲಾಗಿದೆ';

  @override
  String get playlistStatusPublished => 'ಪ್ರಕಟಿತ';

  @override
  String get playlistStatusDraft => 'ಕರಡು';

  @override
  String get playlistStudentNone =>
      'ಇನ್ನೂ ಯಾವುದೇ ಪ್ಲೇಲಿಸ್ಟ್ ಇಲ್ಲ. ಖಾಸಗಿ ಪ್ಲೇಲಿಸ್ಟ್ ರಚಿಸಲು 2 ಒತ್ತಿ.';

  @override
  String playlistStudentLoaded(int privateCount, int classCount) {
    String _temp0 = intl.Intl.pluralLogic(
      privateCount,
      locale: localeName,
      other: '$privateCount ಖಾಸಗಿ ಪ್ಲೇಲಿಸ್ಟ್‌ಗಳು',
    );
    String _temp1 = intl.Intl.pluralLogic(
      classCount,
      locale: localeName,
      other: '$classCount ತರಗತಿ ಪ್ಲೇಲಿಸ್ಟ್‌ಗಳು',
    );
    return '$_temp0 ಮತ್ತು $_temp1 ಲೋಡ್ ಆಗಿವೆ';
  }

  @override
  String get playlistCreatePrivate => 'ಖಾಸಗಿ ಪ್ಲೇಲಿಸ್ಟ್ ರಚಿಸಿ';

  @override
  String get playlistCreatePrivateKey => 'ಖಾಸಗಿ ಪ್ಲೇಲಿಸ್ಟ್ ರಚಿಸಿ';

  @override
  String playlistPrivateItemLabel(String title, String count) {
    return '$title, ಖಾಸಗಿ, $count ಐಟಂಗಳು';
  }

  @override
  String playlistClassItemLabel(String title, String subject, String count) {
    return '$title, ತರಗತಿ ಪ್ಲೇಲಿಸ್ಟ್, $subject, $count ಐಟಂಗಳು';
  }

  @override
  String get playlistStudentScreen =>
      'ನನ್ನ ಪ್ಲೇಲಿಸ್ಟ್‌ಗಳು. ಖಾಸಗಿ ಪ್ಲೇಲಿಸ್ಟ್‌ಗಳು ನಿಮಗೆ ಮಾತ್ರ ಕಾಣುತ್ತವೆ.';

  @override
  String get playlistWaitBeforeNotes =>
      'ಅಧ್ಯಯನ ಟಿಪ್ಪಣಿಗಳನ್ನು ತೆರೆಯುವ ಮೊದಲು ಪ್ಲೇಲಿಸ್ಟ್ ಪ್ಲೇಯರ್‌ಗಾಗಿ ಕಾಯಿರಿ.';

  @override
  String get playlistRefreshFailed =>
      'ಈ ಪ್ಲೇಲಿಸ್ಟ್ ರಿಫ್ರೆಶ್ ಮಾಡಲು ಆಗಲಿಲ್ಲ. ನಿಮ್ಮ ಸಂಪರ್ಕ ಪರಿಶೀಲಿಸಿ ಮತ್ತು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ. ಈಗಿನ ಪ್ಲೇಬ್ಯಾಕ್ ಮತ್ತು ಉಳಿಸಿದ ಪ್ರಗತಿಯನ್ನು ಬದಲಾಯಿಸಲಾಗಿಲ್ಲ.';

  @override
  String get playlistLessonGone =>
      'ಈಗಿನ ಪಾಠ ಈ ಪ್ಲೇಲಿಸ್ಟ್‌ನಲ್ಲಿ ಈಗ ಲಭ್ಯವಿಲ್ಲ. ಪ್ಲೇಬ್ಯಾಕ್ ನಿಂತಿದೆ. ನಿಮ್ಮ ಉಳಿಸಿದ ಪ್ರಗತಿ ಮತ್ತು ಬುಕ್‌ಮಾರ್ಕ್‌ಗಳನ್ನು ಇಟ್ಟುಕೊಳ್ಳಲಾಗಿದೆ.';

  @override
  String get playlistStateArchived => 'ಆರ್ಕೈವ್ ಮಾಡಲಾಗಿದೆ';

  @override
  String get playlistStatePublished => 'ಪ್ರಕಟಿತ';

  @override
  String get playlistStateDraft => 'ಕರಡು';

  @override
  String get playlistStatePrivate => 'ಖಾಸಗಿ';

  @override
  String get playlistStatePublishedClass => 'ಪ್ರಕಟಿತ ತರಗತಿ ಪ್ಲೇಲಿಸ್ಟ್';

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
      other: '$count ಐಟಂಗಳು',
    );
    return '$title. $className $subject. $_temp0. $state.';
  }

  @override
  String get playlistAddAudioScreen => 'ಪ್ಲೇಲಿಸ್ಟ್‌ಗೆ ಆಡಿಯೋ ಸೇರಿಸಿ';

  @override
  String playlistItemNoLongerAvailable(String title) {
    return '$title ಈಗ ನಿಮ್ಮ ಪ್ರಸ್ತುತ ತರಗತಿಯಲ್ಲಿ ಲಭ್ಯವಿಲ್ಲ. ನೀವು ಅದನ್ನು ಈ ಪ್ಲೇಲಿಸ್ಟ್‌ನಿಂದ ತೆಗೆದುಹಾಕಬಹುದು.';
  }

  @override
  String playlistItemPosition(String index, String total) {
    return 'ಐಟಂ $index / $total.';
  }

  @override
  String get playlistPlayFailed =>
      'ಈ ಪಾಠವನ್ನು ಪ್ಲೇ ಮಾಡಲು ಆಗಲಿಲ್ಲ. ನಿಮ್ಮ ಸಂಪರ್ಕ ಪರಿಶೀಲಿಸಿ ಮತ್ತು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String playlistPausedAt(String position) {
    return '$position ನಲ್ಲಿ ವಿರಾಮಗೊಳಿಸಲಾಗಿದೆ.';
  }

  @override
  String get playlistLessonDefault => 'ಪಾಠ';

  @override
  String get playlistSave => 'ಉಳಿಸಿ';

  @override
  String get playlistRenameScreen => 'ಪ್ಲೇಲಿಸ್ಟ್ ಮರುಹೆಸರಿಸಿ';

  @override
  String get playlistCancelRename => 'ಮರುಹೆಸರಿಸುವುದನ್ನು ರದ್ದುಮಾಡಿ';

  @override
  String get playlistSaveTitle => 'ಪ್ಲೇಲಿಸ್ಟ್ ಶೀರ್ಷಿಕೆ ಉಳಿಸಿ';

  @override
  String get playlistAlreadyFirst => 'ಆಯ್ಕೆ ಮಾಡಿದ ಐಟಂ ಈಗಾಗಲೇ ಮೊದಲಿನಲ್ಲಿದೆ.';

  @override
  String get playlistAlreadyLast => 'ಆಯ್ಕೆ ಮಾಡಿದ ಐಟಂ ಈಗಾಗಲೇ ಕೊನೆಯಲ್ಲಿದೆ.';

  @override
  String playlistMoveFailed(String title) {
    return '$title ಅನ್ನು ಸರಿಸಲು ಆಗಲಿಲ್ಲ. ನಿಮ್ಮ ಸಂಪರ್ಕ ಪರಿಶೀಲಿಸಿ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';
  }

  @override
  String get playlistThisPlaylist => 'ಈ ಪ್ಲೇಲಿಸ್ಟ್';

  @override
  String playlistRemoveItemTitle(String title) {
    return '$title ತೆಗೆದುಹಾಕಬೇಕೇ?';
  }

  @override
  String playlistRemoveItemMessage(String title, String playlist) {
    return '$playlist ನಿಂದ $title ತೆಗೆದುಹಾಕಬೇಕೇ? ರೆಕಾರ್ಡಿಂಗ್ ಲೈಬ್ರರಿಯಲ್ಲಿ ಹಾಗೆಯೇ ಇರುತ್ತದೆ.';
  }

  @override
  String playlistKeepItem(String title) {
    return '$title ಇರಿಸಿ';
  }

  @override
  String playlistRemoveItem(String title) {
    return '$title ತೆಗೆದುಹಾಕಿ';
  }

  @override
  String playlistRemoveFailed(String title) {
    return '$title ತೆಗೆದುಹಾಕಲು ಆಗಲಿಲ್ಲ. ನಿಮ್ಮ ಸಂಪರ್ಕ ಪರಿಶೀಲಿಸಿ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';
  }

  @override
  String playlistPublishedToClass(String title) {
    return '$title ತರಗತಿಗೆ ಪ್ರಕಟಿಸಲಾಗಿದೆ';
  }

  @override
  String playlistReturnedToDraft(String title) {
    return '$title ಕರಡಿಗೆ ಮರಳಿಸಲಾಗಿದೆ';
  }

  @override
  String playlistChangeFailed(String title) {
    return '$title ಬದಲಾಯಿಸಲು ಆಗಲಿಲ್ಲ. ನಿಮ್ಮ ಸಂಪರ್ಕ ಪರಿಶೀಲಿಸಿ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';
  }

  @override
  String playlistDeleteTitle(String title) {
    return '$title ಅಳಿಸಬೇಕೇ?';
  }

  @override
  String playlistRestoreTitle(String title) {
    return '$title ಮರುಸ್ಥಾಪಿಸಬೇಕೇ?';
  }

  @override
  String playlistArchiveTitle(String title) {
    return '$title ಆರ್ಕೈವ್ ಮಾಡಬೇಕೇ?';
  }

  @override
  String playlistDeleteMessage(String title) {
    return 'ಇದು ಖಾಸಗಿ ಪ್ಲೇಲಿಸ್ಟ್ $title ಮತ್ತು ಅದರ ಕ್ರಮಬದ್ಧ ಐಟಂಗಳನ್ನು ತೆಗೆದುಹಾಕುತ್ತದೆ. ರೆಕಾರ್ಡಿಂಗ್‌ಗಳು ಲೈಬ್ರರಿಯಲ್ಲಿ ಇರುತ್ತವೆ.';
  }

  @override
  String playlistRestoreMessage(String title) {
    return 'ಇದು $title ಅನ್ನು ಕರಡಿಗೆ ಮರಳಿಸುತ್ತದೆ, ಆಗ ಅದನ್ನು ಸಂಪಾದಿಸಿ ಮತ್ತೆ ಪ್ರಕಟಿಸಬಹುದು.';
  }

  @override
  String playlistArchiveMessage(String title) {
    return 'ವಿದ್ಯಾರ್ಥಿಗಳಿಗೆ ಇನ್ನು ಮುಂದೆ $title ಕಾಣುವುದಿಲ್ಲ. ಶಿಕ್ಷಕರ ಇತಿಹಾಸ ಉಳಿಯುತ್ತದೆ.';
  }

  @override
  String playlistDeleteConfirm(String title) {
    return '$title ಅಳಿಸಿ';
  }

  @override
  String playlistRestoreConfirm(String title) {
    return '$title ಮರುಸ್ಥಾಪಿಸಿ';
  }

  @override
  String playlistArchiveConfirm(String title) {
    return '$title ಆರ್ಕೈವ್ ಮಾಡಿ';
  }

  @override
  String playlistDeleted(String title) {
    return '$title ಅಳಿಸಲಾಗಿದೆ';
  }

  @override
  String playlistRestoredDraft(String title) {
    return '$title ಕರಡಾಗಿ ಮರುಸ್ಥಾಪಿಸಲಾಗಿದೆ';
  }

  @override
  String playlistArchived(String title) {
    return '$title ಆರ್ಕೈವ್ ಮಾಡಲಾಗಿದೆ';
  }

  @override
  String get playlistSelectedItem => 'ಆಯ್ಕೆ ಮಾಡಿದ ಐಟಂ';

  @override
  String get playlistSeekFailed =>
      'ಆ ಪಾಠದ ಸ್ಥಾನಕ್ಕೆ ಹೋಗಲು ಆಗಲಿಲ್ಲ. ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get playlistRefreshPlaylist => 'ಪ್ಲೇಲಿಸ್ಟ್ ರಿಫ್ರೆಶ್ ಮಾಡಿ';

  @override
  String get playlistWordPlaylist => 'ಪ್ಲೇಲಿಸ್ಟ್';

  @override
  String playlistRenameLabel(String title) {
    return '$title ಮರುಹೆಸರಿಸಿ';
  }

  @override
  String get playlistAddAudioLabel => 'ಆಡಿಯೋ ಸೇರಿಸಿ, ಕೀ 2';

  @override
  String playlistPauseLabel(String title, String key) {
    return '$title ವಿರಾಮಗೊಳಿಸಿ, ಕೀ $key';
  }

  @override
  String playlistPlayLabel(String title, String key) {
    return '$title ಪ್ಲೇ ಮಾಡಿ, ಕೀ $key';
  }

  @override
  String get playlistPreviousLabel => 'ಹಿಂದಿನ ಐಟಂ, ಕೀ 3';

  @override
  String get playlistNextLabel => 'ಮುಂದಿನ ಐಟಂ, ಕೀ 8';

  @override
  String playlistReturnToDraftLabel(String title) {
    return '$title ಅನ್ನು ಕರಡಿಗೆ ಮರಳಿಸಿ';
  }

  @override
  String playlistPublishLabel(String title) {
    return '$title ಅನ್ನು ತರಗತಿಗೆ ಪ್ರಕಟಿಸಿ';
  }

  @override
  String playlistRestoreLabel(String title) {
    return '$title ಮರುಸ್ಥಾಪಿಸಿ';
  }

  @override
  String playlistArchiveLabel(String title) {
    return '$title ಆರ್ಕೈವ್ ಮಾಡಿ, ದೃಢೀಕರಣ ಕೇಳುತ್ತದೆ';
  }

  @override
  String playlistDeleteLabel(String title) {
    return '$title ಅಳಿಸಿ, ದೃಢೀಕರಣ ಕೇಳುತ್ತದೆ';
  }

  @override
  String playlistSeekLabel(String position) {
    return 'ಪಾಠದ ಸ್ಥಾನ $position. 10 ಸೆಕೆಂಡು ಸರಿಸಲು ಎಡ ಅಥವಾ ಬಲ ಬಳಸಿ';
  }

  @override
  String get playlistDownloadsLabel =>
      'ಪ್ಲೇಲಿಸ್ಟ್ ರೆಕಾರ್ಡಿಂಗ್‌ಗಳನ್ನು ಡೌನ್‌ಲೋಡ್ ಮಾಡಿ. ಒಂದೊಂದಾಗಿ ಆಯ್ಕೆ ಮಾಡಿ ಅಥವಾ ಪಟ್ಟಿಯಲ್ಲಿರುವ ಎಲ್ಲಾ ರೆಕಾರ್ಡಿಂಗ್‌ಗಳನ್ನು ದೃಢೀಕರಿಸಿ';

  @override
  String playlistMoveUpLabel(String title) {
    return '$title ಮೇಲೆ ಸರಿಸಿ';
  }

  @override
  String playlistMoveDownLabel(String title) {
    return '$title ಕೆಳಗೆ ಸರಿಸಿ';
  }

  @override
  String playlistRemoveItemLabel(String title) {
    return '$title ಅನ್ನು ಪ್ಲೇಲಿಸ್ಟ್‌ನಿಂದ ತೆಗೆದುಹಾಕಿ, ದೃಢೀಕರಣ ಕೇಳುತ್ತದೆ';
  }

  @override
  String get playlistItemUnavailableInClass =>
      'ನಿಮ್ಮ ಪ್ರಸ್ತುತ ತರಗತಿಯಲ್ಲಿ ಲಭ್ಯವಿಲ್ಲ';

  @override
  String get playlistItemSelected => 'ಆಯ್ಕೆ ಮಾಡಲಾಗಿದೆ';

  @override
  String get playlistItemPlaying => 'ಪ್ಲೇ ಆಗುತ್ತಿದೆ';

  @override
  String get playlistItemSelectedPaused => 'ಆಯ್ಕೆ ಮಾಡಲಾಗಿದೆ, ವಿರಾಮದಲ್ಲಿದೆ';

  @override
  String get playlistAddAudioKey => 'ಆಡಿಯೋ ಸೇರಿಸಿ';

  @override
  String get playlistPreviousItem => 'ಹಿಂದಿನ ಐಟಂ';

  @override
  String get playlistNextItem => 'ಮುಂದಿನ ಐಟಂ';

  @override
  String get playlistScreenDefault => 'ಪ್ಲೇಲಿಸ್ಟ್';

  @override
  String playlistScreen(String title) {
    return '$title ಪ್ಲೇಲಿಸ್ಟ್';
  }

  @override
  String playlistItemUnavailable(String title) {
    return '$title ನಿಮ್ಮ ಪ್ರಸ್ತುತ ತರಗತಿಯಲ್ಲಿ ಲಭ್ಯವಿಲ್ಲ';
  }

  @override
  String get notesNoRecordingActive => 'ಯಾವುದೇ ರೆಕಾರ್ಡಿಂಗ್ ನಡೆಯುತ್ತಿಲ್ಲ.';

  @override
  String get notesMicCouldNotRecord =>
      'ಮೈಕ್ರೊಫೋನ್ ಈ ಟಿಪ್ಪಣಿಯನ್ನು ರೆಕಾರ್ಡ್ ಮಾಡಲು ಆಗಲಿಲ್ಲ.';

  @override
  String get notesRecordingNotConfirmed =>
      'ರೆಕಾರ್ಡಿಂಗ್ ದೃಢೀಕರಿಸಲು ಆಗಲಿಲ್ಲ. ಅದರ ಅಪೂರ್ಣ ಫೈಲ್‌ಗಳನ್ನು ಇರಿಸಲಾಗಿದೆ. ಮೈಕ್ರೊಫೋನ್ ಅನುಮತಿ ಮತ್ತು ಸಂಗ್ರಹಣೆಯನ್ನು ಪರಿಶೀಲಿಸಿ.';

  @override
  String get notesLeaveLiveSession =>
      'ರೆಕಾರ್ಡ್ ಮಾಡುವ ಮೊದಲು ಲೈವ್ ಸೆಷನ್‌ನಿಂದ ಹೊರಬಂದು ಖಾಸಗಿ ಟಿಪ್ಪಣಿಗಳನ್ನು ತೆರೆಯಿರಿ.';

  @override
  String get notesMicPermissionDenied =>
      'ಮೈಕ್ರೊಫೋನ್ ಅನುಮತಿ ನೀಡಲಾಗಿಲ್ಲ. ಯಾವುದೇ ರೆಕಾರ್ಡಿಂಗ್ ಪ್ರಾರಂಭವಾಗಿಲ್ಲ. Android ಸೆಟ್ಟಿಂಗ್‌ಗಳಲ್ಲಿ ಅದನ್ನು ಆನ್ ಮಾಡಿ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get notesRecordingCancelledChanged =>
      'ಸ್ಕ್ರೀನ್ ಅಥವಾ ಆ್ಯಪ್ ಬದಲಾದ ಕಾರಣ ರೆಕಾರ್ಡಿಂಗ್ ರದ್ದಾಗಿದೆ. ಸಿದ್ಧವಾದಾಗ ಮತ್ತೆ ಪ್ರಾರಂಭಿಸಿ.';

  @override
  String get notesSpeechDidNotStop =>
      'ಆ್ಯಪ್ ಧ್ವನಿ ನಿಲ್ಲಲಿಲ್ಲ. ರೆಕಾರ್ಡ್ ಮಾಡುವ ಮೊದಲು ಟೆಕ್ಸ್ಟ್-ಟು-ಸ್ಪೀಚ್ ಎಂಜಿನ್ ಪರಿಶೀಲಿಸಿ.';

  @override
  String get notesRecordingDidNotStart =>
      'ಆ್ಯಪ್ ಬದಲಾದ ಕಾರಣ ರೆಕಾರ್ಡಿಂಗ್ ಪ್ರಾರಂಭವಾಗಲಿಲ್ಲ. ಅದರ ಖಾಲಿ ಕರಡನ್ನು ಆಯ್ಕೆಮಾಡಿ ತೆಗೆದುಹಾಕಲು ಇರಿಸಲಾಗಿದೆ.';

  @override
  String get notesAnotherRecorderStopping =>
      'ಇನ್ನೊಂದು ಖಾಸಗಿ ರೆಕಾರ್ಡರ್ ಇನ್ನೂ ನಿಲ್ಲುತ್ತಿದೆ. ರೆಕಾರ್ಡ್ ಮಾಡುವ ಮೊದಲು ಅದಕ್ಕೆ ಹಿಂತಿರುಗಿ ಅಥವಾ ಆ್ಯಪ್ ಅನ್ನು ಹಿನ್ನೆಲೆಗೆ ಕಳುಹಿಸಿ.';

  @override
  String get notesNativeStartNotConfirmed =>
      'ಫೋನ್‌ನ ರೆಕಾರ್ಡರ್ ಪ್ರಾರಂಭವಾದುದನ್ನು ದೃಢೀಕರಿಸಲಿಲ್ಲ. ಕರಡನ್ನು ಇರಿಸಲಾಗಿದೆ.';

  @override
  String get notesNativeStopNotConfirmed =>
      'ಫೋನ್‌ನ ರೆಕಾರ್ಡಿಂಗ್ ನಿಂತಿರುವುದು ದೃಢೀಕರಿಸಲಾಗಿಲ್ಲ. ಮತ್ತೆ ಪ್ರಯತ್ನಿಸುವ ಮೊದಲು ರೆಕಾರ್ಡಿಂಗ್ ನಿಲ್ಲಿಸಲು ಆ್ಯಪ್ ಅನ್ನು ಹಿನ್ನೆಲೆಗೆ ಕಳುಹಿಸಿ.';

  @override
  String get notesDurationUnreadable =>
      'ರೆಕಾರ್ಡರ್ ಅವಧಿಯನ್ನು ಓದಲು ಆಗಲಿಲ್ಲ. ಅದರ ಅಪೂರ್ಣ ಫೈಲ್ ಅನ್ನು ಇರಿಸಲಾಗಿದೆ.';

  @override
  String get notesRecordingInProgress =>
      'ರೆಕಾರ್ಡ್ ಆಗುತ್ತಿದೆ. ಆ್ಯಪ್ ನಿಯಂತ್ರಣಗಳಿಗೆ ಮಾತನಾಡುವ ಮೊದಲು ನಿಲ್ಲಿಸಿ. ಗರಿಷ್ಠ ಐದು ನಿಮಿಷ; ಆ್ಯಪ್ ಧ್ವನಿ ಅಥವಾ ಅಡಚಣೆ ಬಂದರೆ ನಿಲ್ಲುತ್ತದೆ.';

  @override
  String get notesNativeCaptureStopped =>
      'ಫೋನ್‌ನ ರೆಕಾರ್ಡಿಂಗ್ ನಿಂತಿದೆ. ಯಾವುದೇ ಅಪೂರ್ಣ ಕರಡನ್ನು ಆಯ್ಕೆಮಾಡಿ ತೆಗೆದುಹಾಕಲು ಇರಿಸಲಾಗಿದೆ.';

  @override
  String get notesRecorderStopNotConfirmed =>
      'ರೆಕಾರ್ಡರ್ ನಿಂತಿರುವುದು ದೃಢೀಕರಿಸಲಾಗಿಲ್ಲ. ಮತ್ತೆ ಪ್ರಯತ್ನಿಸುವ ಮೊದಲು ಫೋನ್‌ನ ರೆಕಾರ್ಡಿಂಗ್ ನಿಲ್ಲಿಸಲು ಈ ಸ್ಕ್ರೀನ್‌ನಿಂದ ಹೊರಬನ್ನಿ ಅಥವಾ ಆ್ಯಪ್ ಅನ್ನು ಹಿನ್ನೆಲೆಗೆ ಕಳುಹಿಸಿ.';

  @override
  String get notesRecorderFailed =>
      'ರೆಕಾರ್ಡರ್ ವಿಫಲವಾಗಿದೆ. ಅದರ ಅಪೂರ್ಣ ಫೈಲ್ ಅನ್ನು ಆಯ್ಕೆಮಾಡಿ ತೆಗೆದುಹಾಕಲು ಇರಿಸಲಾಗಿದೆ.';

  @override
  String get notesNotFinalized =>
      'ರೆಕಾರ್ಡಿಂಗ್ ನಿಂತಿದೆ, ಆದರೆ ಟಿಪ್ಪಣಿಯನ್ನು ಪೂರ್ಣಗೊಳಿಸಲು ಆಗಲಿಲ್ಲ. ಫೈಲ್‌ಗಳನ್ನು ಆಯ್ಕೆಮಾಡಿ ತೆಗೆದುಹಾಕಲು ಇರಿಸಲಾಗಿದೆ.';

  @override
  String get notesRecordingLimitReached => 'ರೆಕಾರ್ಡಿಂಗ್ ಮಿತಿ ತಲುಪಿದೆ.';

  @override
  String get notesRecordingInterrupted => 'ರೆಕಾರ್ಡಿಂಗ್‌ಗೆ ಅಡಚಣೆಯಾಗಿದೆ.';

  @override
  String get notesRecordingStopped => 'ರೆಕಾರ್ಡಿಂಗ್ ನಿಂತಿದೆ.';

  @override
  String get notesSavedOnPhone =>
      'ಖಾಸಗಿ ಟಿಪ್ಪಣಿಯನ್ನು ಈ ಫೋನ್‌ನಲ್ಲಿ ಉಳಿಸಲಾಗಿದೆ. ಪ್ರಕಟಿಸುವ ಅಥವಾ ಹಂಚಿಕೊಳ್ಳುವ ಮೊದಲು ಪರಿಶೀಲಿಸಿ.';

  @override
  String get notesSignInFirst =>
      'ಖಾಸಗಿ ಟಿಪ್ಪಣಿಗಳನ್ನು ತೆರೆಯುವ ಮೊದಲು ಸೈನ್ ಇನ್ ಮಾಡಿ.';

  @override
  String get notesInvalidIdentity => 'ಟಿಪ್ಪಣಿಯ ಗುರುತು ಅಮಾನ್ಯವಾಗಿದೆ.';

  @override
  String get notesAccountChanged =>
      'ನಿಮ್ಮ ಖಾತೆ ಬದಲಾಗಿದೆ. ಖಾಸಗಿ ಟಿಪ್ಪಣಿಗಳನ್ನು ಮತ್ತೆ ತೆರೆಯಿರಿ.';

  @override
  String get notesStorageUnavailable =>
      'ಖಾಸಗಿ ಟಿಪ್ಪಣಿ ಸಂಗ್ರಹಣೆ ಲಭ್ಯವಿಲ್ಲ. ಖಾಲಿ ಜಾಗ ಪರಿಶೀಲಿಸಿ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ. ಈಗಿರುವ ಫೈಲ್‌ಗಳನ್ನು ಇರಿಸಲಾಗಿದೆ.';

  @override
  String get notesInvalidNameOrPosition =>
      '160 ಅಕ್ಷರಗಳವರೆಗಿನ ಟಿಪ್ಪಣಿಯ ಹೆಸರು ಮತ್ತು ಮಾನ್ಯವಾದ ಪಾಠದ ಸ್ಥಾನವನ್ನು ನಮೂದಿಸಿ.';

  @override
  String get notesAllowanceFull =>
      'ನಿಮ್ಮ ಖಾಸಗಿ ಟಿಪ್ಪಣಿ ಮಿತಿ ತುಂಬಿದೆ. ರೆಕಾರ್ಡ್ ಮಾಡುವ ಮೊದಲು ನೀವು ಆರಿಸಿದ ಒಂದು ಟಿಪ್ಪಣಿಯನ್ನು ತೆಗೆದುಹಾಕಿ. ಯಾವುದೇ ಟಿಪ್ಪಣಿ ಅಳಿಸಲಾಗಿಲ್ಲ.';

  @override
  String get notesInterruptedOrInvalid =>
      'ಟಿಪ್ಪಣಿಗೆ ಅಡಚಣೆಯಾಗಿದೆ ಅಥವಾ ಅದರ ಅವಧಿ ಅಮಾನ್ಯವಾಗಿದೆ. ಅದರ ಫೈಲ್‌ಗಳನ್ನು ಆಯ್ಕೆಮಾಡಿ ತೆಗೆದುಹಾಕಲು ಇರಿಸಲಾಗಿದೆ.';

  @override
  String get notesEmptyOrTooLarge =>
      'ಈ ರೆಕಾರ್ಡಿಂಗ್ ಖಾಲಿಯಾಗಿದೆ ಅಥವಾ ಖಾಸಗಿ ಟಿಪ್ಪಣಿ ಮಿತಿಯನ್ನು ಮೀರಿದೆ. ಅದರ ಅಪೂರ್ಣ ಫೈಲ್ ಅನ್ನು ಇರಿಸಲಾಗಿದೆ; ಸಂಗ್ರಹಣೆ ಪರಿಶೀಲಿಸಿ ಮತ್ತು ಆಯ್ಕೆ ಮಾಡಿದ ರೆಕಾರ್ಡಿಂಗ್ ತೆಗೆದುಹಾಕಿ.';

  @override
  String get notesIncompleteUnavailable =>
      'ಈ ಟಿಪ್ಪಣಿ ಅಪೂರ್ಣವಾಗಿದೆ ಅಥವಾ ಲಭ್ಯವಿಲ್ಲ. ಅದನ್ನು ಅಳಿಸಲಾಗಿಲ್ಲ.';

  @override
  String get notesInvalidName => '160 ಅಕ್ಷರಗಳವರೆಗಿನ ಟಿಪ್ಪಣಿಯ ಹೆಸರನ್ನು ನಮೂದಿಸಿ.';

  @override
  String notesUnreadableTitle(String id) {
    return 'ಓದಲಾಗದ ಟಿಪ್ಪಣಿ $id';
  }

  @override
  String get notesRecordUnreadable =>
      'ಈ ಟಿಪ್ಪಣಿಯ ದಾಖಲೆಯನ್ನು ಓದಲು ಆಗುವುದಿಲ್ಲ. ಅದರ ಫೈಲ್‌ಗಳನ್ನು ಇರಿಸಲಾಗಿದೆ; ನೀವು ಸ್ಪಷ್ಟವಾಗಿ ಆಯ್ಕೆಮಾಡಿ ತೆಗೆದುಹಾಕಿದರೆ ಮಾತ್ರ ಅವು ಬದಲಾಗುತ್ತವೆ.';

  @override
  String notesInterruptedTitle(String id) {
    return 'ಅಡಚಣೆಯಾದ ರೆಕಾರ್ಡಿಂಗ್ $id';
  }

  @override
  String get notesMetadataMissing =>
      'ರೆಕಾರ್ಡಿಂಗ್ ಮಾಹಿತಿ ಕಾಣೆಯಾಗಿದೆ. ಫೈಲ್ ಅನ್ನು ಆಯ್ಕೆಮಾಡಿ ತೆಗೆದುಹಾಕಲು ಇರಿಸಲಾಗಿದೆ.';

  @override
  String get learningSavedLessonInvalid =>
      'ಉಳಿಸಿದ ಪಾಠದ ಮಾಹಿತಿ ಅಮಾನ್ಯವಾಗಿದೆ. ನಿಮ್ಮ ಉಳಿಸಿದ ಡೇಟಾ ಬದಲಾಗಿಲ್ಲ.';

  @override
  String get learningSavedBookmarkUnreadable =>
      'ಉಳಿಸಿದ ಒಂದು ಬುಕ್‌ಮಾರ್ಕ್ ಓದಲು ಆಗಲಿಲ್ಲ. ನಿಮ್ಮ ಉಳಿಸಿದ ಡೇಟಾ ಬದಲಾಗಿಲ್ಲ.';

  @override
  String get learningSavedBookmarkIdsInvalid =>
      'ಉಳಿಸಿದ ಬುಕ್‌ಮಾರ್ಕ್ ಗುರುತುಗಳು ಅಮಾನ್ಯವಾಗಿವೆ. ನಿಮ್ಮ ಉಳಿಸಿದ ಡೇಟಾ ಬದಲಾಗಿಲ್ಲ.';

  @override
  String get learningSavedRepeatInvalid =>
      'ಉಳಿಸಿದ ಪುನರಾವರ್ತನೆ ಮಿತಿಗಳು ಅಮಾನ್ಯವಾಗಿವೆ. ನಿಮ್ಮ ಉಳಿಸಿದ ಡೇಟಾ ಬದಲಾಗಿಲ್ಲ.';

  @override
  String get learningSignInFirst =>
      'ಉಳಿಸಿದ ಕಲಿಕೆಯ ಪ್ರಗತಿ ಬಳಸುವ ಮೊದಲು ಸೈನ್ ಇನ್ ಮಾಡಿ.';

  @override
  String get learningAccountChanged =>
      'ನಿಮ್ಮ ಖಾತೆ ಬದಲಾಗಿದೆ. ಕಲಿಕೆಯ ಲೈಬ್ರರಿಯನ್ನು ಮತ್ತೆ ತೆರೆಯಿರಿ.';

  @override
  String get learningUnsupportedFormat =>
      'ಉಳಿಸಿದ ಕಲಿಕೆಯ ಡೇಟಾದ ಸ್ವರೂಪ ಅಥವಾ ಖಾತೆ ಬೆಂಬಲಿತವಾಗಿಲ್ಲ. ನಿಮ್ಮ ಉಳಿಸಿದ ಡೇಟಾ ಬದಲಾಗಿಲ್ಲ.';

  @override
  String get learningIdentityMismatch =>
      'ಉಳಿಸಿದ ಪಾಠದ ಗುರುತು ಹೊಂದಿಕೆಯಾಗುತ್ತಿಲ್ಲ. ನಿಮ್ಮ ಉಳಿಸಿದ ಡೇಟಾ ಬದಲಾಗಿಲ್ಲ.';

  @override
  String get learningDataUnreadable =>
      'ಉಳಿಸಿದ ಕಲಿಕೆಯ ಡೇಟಾ ಓದಲು ಆಗಲಿಲ್ಲ. ನಿಮ್ಮ ಉಳಿಸಿದ ಡೇಟಾ ಬದಲಾಗಿಲ್ಲ.';

  @override
  String get learningStorageUnavailableFreeSpace =>
      'ಕಲಿಕೆಯ ಸಂಗ್ರಹಣೆ ಲಭ್ಯವಿಲ್ಲ. ಖಾಲಿ ಜಾಗ ಪರಿಶೀಲಿಸಿ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ. ನಿಮ್ಮ ಉಳಿಸಿದ ಡೇಟಾವನ್ನು ಉದ್ದೇಶಪೂರ್ವಕವಾಗಿ ತೆಗೆದುಹಾಕಲಾಗಿಲ್ಲ.';

  @override
  String get learningStorageUnavailable =>
      'ಕಲಿಕೆಯ ಸಂಗ್ರಹಣೆ ಲಭ್ಯವಿಲ್ಲ. ಸಂಗ್ರಹಣೆ ಪರಿಶೀಲಿಸಿ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get learningSaveFailed =>
      'ಕಲಿಕೆಯ ಪ್ರಗತಿಯನ್ನು ಉಳಿಸಲು ಆಗಲಿಲ್ಲ. ಖಾಲಿ ಜಾಗ ಪರಿಶೀಲಿಸಿ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get learningProgressUnavailable =>
      'ಉಳಿಸಿದ ಕಲಿಕೆಯ ಪ್ರಗತಿ ಲಭ್ಯವಿಲ್ಲ. ಸಂಗ್ರಹಣೆ ಪರಿಶೀಲಿಸಿ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get learningStartLessonFirst =>
      'ಬುಕ್‌ಮಾರ್ಕ್‌ಗಳು ಅಥವಾ ಪುನರಾವರ್ತನೆ ಬಿಂದುಗಳನ್ನು ಸೇರಿಸುವ ಮೊದಲು ಈ ಪಾಠವನ್ನು ಪ್ರಾರಂಭಿಸಿ.';

  @override
  String learningSavedFieldUnreadable(String field) {
    return 'ಉಳಿಸಿದ $field ಓದಲು ಆಗಲಿಲ್ಲ. ನಿಮ್ಮ ಉಳಿಸಿದ ಡೇಟಾ ಬದಲಾಗಿಲ್ಲ.';
  }

  @override
  String get learningFieldBookmarkId => 'ಬುಕ್‌ಮಾರ್ಕ್ ಐಡಿ';

  @override
  String get learningFieldBookmarkLabel => 'ಬುಕ್‌ಮಾರ್ಕ್ ಹೆಸರು';

  @override
  String get learningFieldBookmarkPosition => 'ಬುಕ್‌ಮಾರ್ಕ್ ಸ್ಥಾನ';

  @override
  String get learningFieldUpdateTime => 'ಅಪ್‌ಡೇಟ್ ಸಮಯ';

  @override
  String get learningFieldNextBookmarkId => 'ಮುಂದಿನ ಬುಕ್‌ಮಾರ್ಕ್ ಐಡಿ';

  @override
  String get learningFieldLessonId => 'ಪಾಠದ ಐಡಿ';

  @override
  String get learningFieldLessonTitle => 'ಪಾಠದ ಶೀರ್ಷಿಕೆ';

  @override
  String get learningFieldPosition => 'ಸ್ಥಾನ';

  @override
  String get learningInvalidProgress => 'ಪಾಠದ ಪ್ರಗತಿ ಅಮಾನ್ಯವಾಗಿದೆ';

  @override
  String get learningBookmarkNeedsPositionLabel =>
      'ಬುಕ್‌ಮಾರ್ಕ್‌ಗೆ ಮಾನ್ಯವಾದ ಸ್ಥಾನ ಮತ್ತು ಹೆಸರು ಬೇಕು';

  @override
  String get learningBookmarkExceedsDuration =>
      'ಬುಕ್‌ಮಾರ್ಕ್ ಸ್ಥಾನ ಪಾಠದ ಅವಧಿಯನ್ನು ಮೀರಿದೆ';

  @override
  String learningDefaultBookmarkLabel(String number) {
    return 'ಬುಕ್‌ಮಾರ್ಕ್ $number';
  }

  @override
  String get learningBookmarkNotFound => 'ಬುಕ್‌ಮಾರ್ಕ್ ಸಿಗಲಿಲ್ಲ';

  @override
  String get learningRepeatEndAfterStart =>
      'ಕೊನೆಯ ಬಿಂದುವನ್ನು ಪ್ರಾರಂಭ ಬಿಂದುವಿನ ನಂತರ ಇರಿಸಿ';

  @override
  String get learningRepeatExceedsDuration =>
      'ಪುನರಾವರ್ತನೆ ಬಿಂದುಗಳು ಪಾಠದ ಅವಧಿಯನ್ನು ಮೀರಿವೆ';

  @override
  String get learningSavedProgressUnavailableTitle => 'ಉಳಿಸಿದ ಪ್ರಗತಿ ಲಭ್ಯವಿಲ್ಲ';

  @override
  String get learningListenWithoutSavedPrompt =>
      'ಉಳಿಸಿದ ಡೇಟಾ ಬದಲಾಯಿಸದೆ ಮೊದಲಿನಿಂದ ಕೇಳಬೇಕೇ? ನೀವು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ ಯಶಸ್ವಿಯಾಗುವವರೆಗೆ ಉಳಿಸುವಿಕೆ ಆಫ್ ಆಗಿರುತ್ತದೆ.';

  @override
  String get learningListenFromBeginning => 'ಮೊದಲಿನಿಂದ ಕೇಳಿ';

  @override
  String get learningRecordedLesson => 'ರೆಕಾರ್ಡ್ ಮಾಡಿದ ಪಾಠ';

  @override
  String learningStatusPosition(String position) {
    return 'ಸ್ಥಾನ $position.';
  }

  @override
  String learningSpeedTimes(String speed) {
    return 'ವೇಗ $speed ಪಟ್ಟು.';
  }

  @override
  String learningStatusBookmarks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ಬುಕ್‌ಮಾರ್ಕ್‌ಗಳು',
    );
    return '$_temp0';
  }

  @override
  String learningStatusRepeat(String state) {
    return 'A-B ಪುನರಾವರ್ತನೆ $state.';
  }

  @override
  String learningStatusSaving(String state) {
    return 'ಪ್ರಗತಿ ಉಳಿಸುವಿಕೆ $state.';
  }

  @override
  String get learningNoLessonLoaded =>
      'ಯಾವುದೇ ಪಾಠ ಲೋಡ್ ಆಗಿಲ್ಲ. ಮೊದಲು ಪ್ಲೇ ಮಾಡಲು ಒಂದು ಪಾಠ ಆರಿಸಿ.';

  @override
  String get learningSlowestSpeed => 'ಈಗಾಗಲೇ ಅತ್ಯಂತ ನಿಧಾನ ವೇಗದಲ್ಲಿದೆ.';

  @override
  String get learningFastestSpeed => 'ಈಗಾಗಲೇ ಅತ್ಯಂತ ವೇಗದ ವೇಗದಲ್ಲಿದೆ.';

  @override
  String get learningCheckPosition => 'ಪಾಠದ ಸ್ಥಾನ ಪರಿಶೀಲಿಸಿ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get learningPlayerActionFailed =>
      'ಪ್ಲೇಯರ್ ಈ ಕ್ರಿಯೆಯನ್ನು ಪೂರ್ಣಗೊಳಿಸಲು ಆಗಲಿಲ್ಲ. ಪ್ಲೇಬ್ಯಾಕ್ ಪರಿಶೀಲಿಸಿ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String learningBookmarkSavedAt(String time) {
    return '$time ನಲ್ಲಿ ಬುಕ್‌ಮಾರ್ಕ್ ಉಳಿಸಲಾಗಿದೆ.';
  }

  @override
  String learningReadStatusLabel(String status) {
    return 'ಕಲಿಕೆಯ ಸ್ಥಿತಿ ಓದಿ. $status';
  }

  @override
  String learningAddBookmarkAt(String time) {
    return '$time ನಲ್ಲಿ ಬುಕ್‌ಮಾರ್ಕ್ ಸೇರಿಸಿ';
  }

  @override
  String learningBookmarksSavedPoints(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ಬುಕ್‌ಮಾರ್ಕ್‌ಗಳು. $count ಉಳಿಸಿದ ಬಿಂದುಗಳು',
    );
    return '$_temp0';
  }

  @override
  String learningPrivateNotesAt(String time) {
    return '$time ನಲ್ಲಿ ಖಾಸಗಿ ಅಧ್ಯಯನ ಟಿಪ್ಪಣಿಗಳು. ತೆರೆಯುವ ಮೊದಲು ಪಾಠವನ್ನು ವಿರಾಮಗೊಳಿಸಿ';
  }

  @override
  String get learningSetRepeatStartLabel =>
      'ಪ್ರಸ್ತುತ ಸ್ಥಾನದಲ್ಲಿ ಪುನರಾವರ್ತನೆ ಪ್ರಾರಂಭ A ಹೊಂದಿಸಿ';

  @override
  String learningRepeatStartSet(String time) {
    return 'ಪುನರಾವರ್ತನೆ ಪ್ರಾರಂಭ $time ನಲ್ಲಿ ಹೊಂದಿಸಲಾಗಿದೆ.';
  }

  @override
  String get learningSetRepeatEndLabel =>
      'ಪ್ರಾರಂಭ A ನಂತರ ಪುನರಾವರ್ತನೆ ಕೊನೆ B ಹೊಂದಿಸಿ';

  @override
  String learningRepeatEndSet(String time) {
    return 'ಪುನರಾವರ್ತನೆ ಕೊನೆ $time ನಲ್ಲಿ ಹೊಂದಿಸಲಾಗಿದೆ. ಮತ್ತೆ ಮತ್ತೆ ಪ್ಲೇ ಮಾಡಲು ಪುನರಾವರ್ತನೆ ಆನ್ ಆಯ್ಕೆಮಾಡಿ.';
  }

  @override
  String get learningTurnRepeatOff => 'A-B ಪುನರಾವರ್ತನೆ ಆಫ್ ಮಾಡಿ';

  @override
  String get learningTurnRepeatOn => 'A-B ಪುನರಾವರ್ತನೆ ಆನ್ ಮಾಡಿ';

  @override
  String get learningClearRepeatLabel =>
      'ಉಳಿಸಿದ A-B ಪುನರಾವರ್ತನೆ ಬಿಂದುಗಳನ್ನು ತೆರವುಗೊಳಿಸಿ';

  @override
  String get learningRepeatCleared =>
      'A-B ಪುನರಾವರ್ತನೆ ಬಿಂದುಗಳನ್ನು ತೆರವುಗೊಳಿಸಲಾಗಿದೆ.';

  @override
  String learningBackTenLabel(String key) {
    return '10 ಸೆಕೆಂಡು ಹಿಂದೆ, ಕೀ $key';
  }

  @override
  String learningForwardTenLabel(String key) {
    return '10 ಸೆಕೆಂಡು ಮುಂದೆ, ಕೀ $key';
  }

  @override
  String learningSlowerLabel(String key, String speed) {
    return 'ನಿಧಾನ, ಕೀ $key. ಈಗ $speed ಪಟ್ಟು';
  }

  @override
  String learningFasterLabel(String key, String speed) {
    return 'ವೇಗ, ಕೀ $key. ಈಗ $speed ಪಟ್ಟು';
  }

  @override
  String learningRetrySavingLabel(String issue) {
    return 'ಕಲಿಕೆಯ ಪ್ರಗತಿ ಉಳಿಸಲು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ. $issue';
  }

  @override
  String get learningProgressSaved => 'ಕಲಿಕೆಯ ಪ್ರಗತಿ ಉಳಿಸಲಾಗಿದೆ.';

  @override
  String get learningEnterBookmarkName => 'ಬುಕ್‌ಮಾರ್ಕ್ ಹೆಸರನ್ನು ನಮೂದಿಸಿ.';

  @override
  String get learningNameBookmarkScreen =>
      'ಬುಕ್‌ಮಾರ್ಕ್‌ಗೆ ಹೆಸರಿಡಿ. ಸಂಪಾದಿಸಲು ಓಕೆ ಒತ್ತಿ. ಮೇಲೆ ಅಥವಾ ಕೆಳಗೆ ಒತ್ತಿದರೆ ಸಂಪಾದನೆಯಿಂದ ಹೊರಬರುತ್ತದೆ.';

  @override
  String get learningEditName => 'ಹೆಸರು ಸಂಪಾದಿಸಿ';

  @override
  String get learningSaveBookmark => 'ಬುಕ್‌ಮಾರ್ಕ್ ಉಳಿಸಿ';

  @override
  String get learningBookmarkNameField => 'ಬುಕ್‌ಮಾರ್ಕ್ ಹೆಸರು';

  @override
  String learningBookmarkJumped(String label, String position) {
    return '$label. ಸ್ಥಾನ $position.';
  }

  @override
  String get learningRemoveBookmarkTitle => 'ಬುಕ್‌ಮಾರ್ಕ್ ತೆಗೆದುಹಾಕಬೇಕೇ?';

  @override
  String learningRemoveBookmarkMessage(String label) {
    return '$label ತೆಗೆದುಹಾಕಬೇಕೇ? ಇದು ಪಾಠವನ್ನಾಗಲಿ ಬೇರೆ ಯಾವುದೇ ಬುಕ್‌ಮಾರ್ಕ್‌ಗಳನ್ನಾಗಲಿ ತೆಗೆದುಹಾಕುವುದಿಲ್ಲ.';
  }

  @override
  String get learningKeepBookmark => 'ಬುಕ್‌ಮಾರ್ಕ್ ಇರಿಸಿ';

  @override
  String get learningRemoveBookmark => 'ಬುಕ್‌ಮಾರ್ಕ್ ತೆಗೆದುಹಾಕಿ';

  @override
  String learningBookmarkRemoved(String label) {
    return '$label ತೆಗೆದುಹಾಕಲಾಗಿದೆ.';
  }

  @override
  String get learningBookmarksScreen =>
      'ಬುಕ್‌ಮಾರ್ಕ್‌ಗಳು. ಅಲ್ಲಿಗೆ ಹೋಗಲು ಒಂದು ಬಿಂದುವನ್ನು ಆಯ್ಕೆಮಾಡಿ. ಇದು ವಿರಾಮದಲ್ಲಿರುವ ಪ್ಲೇಬ್ಯಾಕ್ ಅನ್ನು ಪ್ರಾರಂಭಿಸುವುದಿಲ್ಲ. ತೆಗೆದುಹಾಕುವಾಗ ದೃಢೀಕರಣ ಕೇಳುತ್ತದೆ.';

  @override
  String get learningCloseBookmarks => 'ಬುಕ್‌ಮಾರ್ಕ್‌ಗಳನ್ನು ಮುಚ್ಚಿ';

  @override
  String learningJumpToBookmarkLabel(String label, String time) {
    return '$label. $time. ಬುಕ್‌ಮಾರ್ಕ್‌ಗೆ ಹೋಗಿ';
  }

  @override
  String learningRemoveBookmarkLabel(String label) {
    return '$label ತೆಗೆದುಹಾಕಿ';
  }

  @override
  String get dashboardRefreshing => 'ಸೆಷನ್‌ಗಳನ್ನು ರಿಫ್ರೆಶ್ ಮಾಡಲಾಗುತ್ತಿದೆ.';

  @override
  String get dashboardShowMatching => 'ಹೊಂದುವ ಸೆಷನ್‌ಗಳನ್ನು ತೋರಿಸಿ';

  @override
  String get dashboardLogout => 'ಲಾಗ್ ಔಟ್, ದೃಢೀಕರಣ ಕೇಳುತ್ತದೆ';

  @override
  String get dashboardRefresh => 'ಸೆಷನ್‌ಗಳನ್ನು ರಿಫ್ರೆಶ್ ಮಾಡಿ';

  @override
  String get dashboardLibraryWhat => 'ರೆಕಾರ್ಡ್ ಮಾಡಿದ ಆಡಿಯೋ ಸಂಗ್ರಹ';

  @override
  String get dashboardQuizzesWhat => 'ಕ್ವಿಜ್‌ಗಳು';

  @override
  String dashboardSessions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ಸೆಷನ್‌ಗಳು',
      one: '1 ಸೆಷನ್',
    );
    return '$_temp0';
  }

  @override
  String dashboardPosition(String index, String total) {
    return '$total ರಲ್ಲಿ $index';
  }

  @override
  String get dashboardStudentScreen => 'ವಿದ್ಯಾರ್ಥಿ ಡ್ಯಾಶ್‌ಬೋರ್ಡ್';

  @override
  String get dashboardStudentLoading =>
      'ವಿದ್ಯಾರ್ಥಿ ಡ್ಯಾಶ್‌ಬೋರ್ಡ್ ಲೋಡ್ ಆಗುತ್ತಿದೆ';

  @override
  String get dashboardStudentSections =>
      'ರಿಫ್ರೆಶ್, ಸೆಷನ್ ಹುಡುಕಾಟ, ಲೈವ್ ಸೆಷನ್‌ಗಳು, ರೆಕಾರ್ಡ್ ಮಾಡಿದ ಪಾಠಗಳು, ಪ್ಲೇಲಿಸ್ಟ್‌ಗಳು, ಕ್ವಿಜ್‌ಗಳು, ಕಲಿಕೆಯ ಪಯಣಗಳು ಮತ್ತು ಲಾಗ್ ಔಟ್';

  @override
  String get dashboardNoLiveSessions =>
      'ಈಗ ಯಾವುದೇ ಲೈವ್ ಸೆಷನ್ ಇಲ್ಲ. ರಿಫ್ರೆಶ್ ಮಾಡಲು 1 ಒತ್ತಿ.';

  @override
  String get dashboardNoFilterMatch => 'ನಿಮ್ಮ ಫಿಲ್ಟರ್‌ಗೆ ಹೊಂದುವ ಸೆಷನ್ ಇಲ್ಲ.';

  @override
  String get dashboardNoMatchVisible =>
      'ಹೊಂದುವ ಸೆಷನ್ ಇಲ್ಲ. ಹುಡುಕಾಟವನ್ನು ಅಳಿಸಿ ಅಥವಾ ವಿಷಯ ಫಿಲ್ಟರ್ ಬದಲಿಸಿ.';

  @override
  String dashboardAvailable(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ಸೆಷನ್‌ಗಳು ಲಭ್ಯವಿವೆ.',
      one: '1 ಸೆಷನ್ ಲಭ್ಯವಿದೆ.',
    );
    return '$_temp0';
  }

  @override
  String dashboardAvailableDetailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ಸೆಷನ್‌ಗಳು ಲಭ್ಯವಿವೆ. ನೋಡಲು ಕೆಳಗೆ ಬಳಸಿ.',
      one: '1 ಸೆಷನ್ ಲಭ್ಯವಿದೆ. ನೋಡಲು ಕೆಳಗೆ ಬಳಸಿ.',
    );
    return '$_temp0';
  }

  @override
  String dashboardRefreshFailed(String reason) {
    return '$reason ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಲು 1 ಒತ್ತಿ.';
  }

  @override
  String get dashboardJoining => 'ಸೆಷನ್‌ಗೆ ಸೇರುತ್ತಿದೆ.';

  @override
  String dashboardJoined(String session) {
    return '$session ಗೆ ಸೇರಿದ್ದೀರಿ.';
  }

  @override
  String get dashboardOpeningPlaylists =>
      'ನನ್ನ ಪ್ಲೇಲಿಸ್ಟ್‌ಗಳನ್ನು ತೆರೆಯುತ್ತಿದೆ. ಈ ಪ್ಲೇಲಿಸ್ಟ್‌ಗಳು ಖಾಸಗಿ.';

  @override
  String get dashboardSessionSearchHelp =>
      'ಸೆಷನ್ ಹುಡುಕಾಟ. ಸೆಷನ್ ಸಂಖ್ಯೆ ಟೈಪ್ ಮಾಡಲು ಓಕೆ ಒತ್ತಿ, ನಂತರ ಕೆಳಗೆ ಹೋಗಿ ಹೊಂದುವ ಸೆಷನ್‌ಗಳನ್ನು ತೋರಿಸಿ ಆರಿಸಿ ಓಕೆ ಒತ್ತಿ. ನೀವು ಹೆಸರಿನಿಂದಲೂ ಹುಡುಕಬಹುದು.';

  @override
  String get dashboardSessionNumberFieldEmpty =>
      'ಸೆಷನ್ ಸಂಖ್ಯೆ ಫೀಲ್ಡ್. ಸಂಖ್ಯೆ ಟೈಪ್ ಮಾಡಿ, ನಂತರ ಹೊಂದುವ ಸೆಷನ್‌ಗಳನ್ನು ತೋರಿಸಿ ಆರಿಸಿ';

  @override
  String dashboardSessionNumberField(String digits) {
    return 'ಸೆಷನ್ ಸಂಖ್ಯೆ ಫೀಲ್ಡ್, $digits';
  }

  @override
  String get dashboardNameField => 'ಹೆಸರಿನಿಂದ ಸೆಷನ್‌ಗಳನ್ನು ಹುಡುಕಿ';

  @override
  String dashboardNoSessionNumber(String digits) {
    return '$digits ಸಂಖ್ಯೆಯ ಲೈವ್ ಸೆಷನ್ ಇಲ್ಲ.';
  }

  @override
  String dashboardFound(String label) {
    return 'ಸಿಕ್ಕಿದೆ: $label. ಸೇರಲು ಓಕೆ ಒತ್ತಿ.';
  }

  @override
  String dashboardNoNameMatch(String query) {
    return '$query ಗೆ ಹೊಂದುವ ಸೆಷನ್ ಇಲ್ಲ.';
  }

  @override
  String dashboardShowingAll(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ಎಲ್ಲಾ $count ಸೆಷನ್‌ಗಳನ್ನು ತೋರಿಸಲಾಗುತ್ತಿದೆ.',
      one: 'ಎಲ್ಲಾ 1 ಸೆಷನ್ ತೋರಿಸಲಾಗುತ್ತಿದೆ.',
    );
    return '$_temp0';
  }

  @override
  String dashboardShowingAllDetailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ಎಲ್ಲಾ $count ಸೆಷನ್‌ಗಳನ್ನು ತೋರಿಸಲಾಗುತ್ತಿದೆ. ನೋಡಲು ಕೆಳಗೆ ಬಳಸಿ.',
      one: 'ಎಲ್ಲಾ 1 ಸೆಷನ್ ತೋರಿಸಲಾಗುತ್ತಿದೆ. ನೋಡಲು ಕೆಳಗೆ ಬಳಸಿ.',
    );
    return '$_temp0';
  }

  @override
  String dashboardNameMatches(int count, String query) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ಸೆಷನ್‌ಗಳು $query ಗೆ ಹೊಂದುತ್ತವೆ. ನೋಡಲು ಕೆಳಗೆ ಬಳಸಿ.',
      one: '1 ಸೆಷನ್ $query ಗೆ ಹೊಂದುತ್ತದೆ. ನೋಡಲು ಕೆಳಗೆ ಬಳಸಿ.',
    );
    return '$_temp0';
  }

  @override
  String get dashboardAllSubjects => 'ಎಲ್ಲಾ ವಿಷಯಗಳು';

  @override
  String dashboardSubjectFilterLabel(String subject, String position) {
    return 'ವಿಷಯ ಫಿಲ್ಟರ್: $subject, $position. ಬದಲಿಸಲು ಎಡ ಅಥವಾ ಬಲ ಬಳಸಿ';
  }

  @override
  String dashboardSubjectFilterChanged(
    String subject,
    String position,
    String summary,
  ) {
    return 'ವಿಷಯ ಫಿಲ್ಟರ್: $subject, $position. $summary';
  }

  @override
  String get dashboardLibrary => 'ರೆಕಾರ್ಡ್ ಮಾಡಿದ ಆಡಿಯೊ ಲೈಬ್ರರಿ';

  @override
  String get dashboardPlaylists => 'ನನ್ನ ಖಾಸಗಿ ಪ್ಲೇಲಿಸ್ಟ್‌ಗಳು';

  @override
  String get dashboardQuizzes => 'ಕ್ವಿಜ್‌ಗಳು';

  @override
  String get dashboardStudentJourneys =>
      'ಕಲಿಕೆಯ ಪಯಣಗಳು: ಕೇಳಿ, ಉತ್ತರಿಸಿ ಮತ್ತು ಪುನರಾವರ್ತಿಸಿ, ಆಫ್‌ಲೈನ್‌ನಲ್ಲೂ ಕೆಲಸ ಮಾಡುತ್ತದೆ';

  @override
  String dashboardTeacherName(String name) {
    return 'ಶಿಕ್ಷಕರು $name';
  }

  @override
  String get dashboardLiveNow => 'ಈಗ ಲೈವ್';

  @override
  String get dashboardStateRefreshing => 'ರಿಫ್ರೆಶ್ ಆಗುತ್ತಿದೆ.';

  @override
  String dashboardStateLiveSessions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ಲೈವ್ ಸೆಷನ್‌ಗಳು.',
      one: '1 ಲೈವ್ ಸೆಷನ್.',
    );
    return '$_temp0';
  }

  @override
  String dashboardStateSubjectFilter(String subject) {
    return 'ವಿಷಯ ಫಿಲ್ಟರ್: $subject.';
  }

  @override
  String dashboardStateSessionNumber(String digits) {
    return 'ಟೈಪ್ ಮಾಡಿದ ಸೆಷನ್ ಸಂಖ್ಯೆ: $digits.';
  }

  @override
  String dashboardStateNameSearch(String query) {
    return 'ಹೆಸರು ಹುಡುಕಾಟ: $query.';
  }

  @override
  String dashboardStateShown(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ಸೆಷನ್‌ಗಳನ್ನು ತೋರಿಸಲಾಗಿದೆ.',
      one: '1 ಸೆಷನ್ ತೋರಿಸಲಾಗಿದೆ.',
    );
    return '$_temp0';
  }

  @override
  String get dashboardTeacherScreen => 'ಶಿಕ್ಷಕರ ಡ್ಯಾಶ್‌ಬೋರ್ಡ್';

  @override
  String get dashboardTeacherLoading => 'ಶಿಕ್ಷಕರ ಡ್ಯಾಶ್‌ಬೋರ್ಡ್ ಲೋಡ್ ಆಗುತ್ತಿದೆ';

  @override
  String get dashboardTeacherSections =>
      'ತರಗತಿ ಮತ್ತು ವಿಷಯ ಆಯ್ಕೆ, ಬೋಧನಾ ಸಾಧನಗಳು, ಸೆಷನ್ ಹುಡುಕಾಟ, ಮತ್ತು ಸಕ್ರಿಯ ಅಥವಾ ಮುಗಿದ ಸೆಷನ್‌ಗಳು';

  @override
  String get dashboardNoSessionsYet =>
      'ಇನ್ನೂ ಯಾವುದೇ ಸೆಷನ್ ಇಲ್ಲ. ಒಂದನ್ನು ರಚಿಸಲು 2 ಒತ್ತಿ.';

  @override
  String get dashboardNoTeacherMatch =>
      'ಹೊಂದುವ ಸೆಷನ್ ಇಲ್ಲ. ಎಲ್ಲಾ ಸೆಷನ್‌ಗಳನ್ನು ನೋಡಲು ಹುಡುಕಾಟವನ್ನು ಅಳಿಸಿ.';

  @override
  String dashboardTeacherCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ಸೆಷನ್‌ಗಳು.',
      one: '1 ಸೆಷನ್.',
    );
    return '$_temp0';
  }

  @override
  String dashboardTeacherCountLive(int count, String live) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ಸೆಷನ್‌ಗಳು, $live ಈಗ ಲೈವ್.',
      one: '1 ಸೆಷನ್, $live ಈಗ ಲೈವ್.',
    );
    return '$_temp0';
  }

  @override
  String dashboardNotRefreshed(String reason) {
    return '$reason ಸೆಷನ್‌ಗಳು ರಿಫ್ರೆಶ್ ಆಗಲಿಲ್ಲ. ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಲು 1 ಒತ್ತಿ.';
  }

  @override
  String get dashboardNoAssignment =>
      'ನಿಮಗೆ ಯಾವುದೇ ತರಗತಿ ಮತ್ತು ವಿಷಯವನ್ನು ನೀಡಿಲ್ಲ. ಒಂದನ್ನು ನೀಡಲು ನಿರ್ವಾಹಕರನ್ನು ಕೇಳಿ.';

  @override
  String get dashboardCreatingSession => 'ಸೆಷನ್ ರಚಿಸಲಾಗುತ್ತಿದೆ';

  @override
  String dashboardCreated(String title) {
    return '$title ಸೆಷನ್ ರಚಿಸಲಾಗಿದೆ.';
  }

  @override
  String get dashboardCreatedTitle => 'ಸೆಷನ್ ರಚಿಸಲಾಗಿದೆ';

  @override
  String dashboardStartNow(String title) {
    return '\"$title\" ಅನ್ನು ಈಗ ಪ್ರಾರಂಭಿಸಬೇಕೇ?';
  }

  @override
  String get dashboardRequestFailed =>
      'ಆ ವಿನಂತಿಯನ್ನು ಪೂರ್ಣಗೊಳಿಸಲು ಆಗಲಿಲ್ಲ. ನಿಮ್ಮ ಸಂಪರ್ಕ ಪರಿಶೀಲಿಸಿ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get dashboardOpeningSession => 'ಸೆಷನ್ ತೆರೆಯುತ್ತಿದೆ.';

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
    return 'ವರ್ಕ್‌ಸ್ಪೇಸ್: $name, $position. $status';
  }

  @override
  String dashboardWorkspaceChosen(String name, String status) {
    return '$name ಆಯ್ಕೆ ಮಾಡಲಾಗಿದೆ. $status ಬೇರೆ ವರ್ಕ್‌ಸ್ಪೇಸ್ ಆರಿಸಲು 7 ಒತ್ತಿ.';
  }

  @override
  String get dashboardChooseWorkspaceTitle => 'ತರಗತಿ ಮತ್ತು ವಿಷಯ ಆರಿಸಿ';

  @override
  String get dashboardNoWorkspace =>
      'ಯಾವುದೇ ತರಗತಿ ಮತ್ತು ವಿಷಯ ವರ್ಕ್‌ಸ್ಪೇಸ್ ನೀಡಿಲ್ಲ';

  @override
  String dashboardWorkspaceLabel(String name, String position) {
    return 'ವರ್ಕ್‌ಸ್ಪೇಸ್: $name, $position. ಬದಲಿಸಲು ಎಡ ಅಥವಾ ಬಲ, ಸಂಖ್ಯೆಯ ಪಟ್ಟಿಗೆ ಓಕೆ ಅಥವಾ 7';
  }

  @override
  String get dashboardCreate => 'ಹೊಸ ಸೆಷನ್ ರಚಿಸಿ';

  @override
  String get dashboardClassPlaylists => 'ತರಗತಿ ಪ್ಲೇಲಿಸ್ಟ್‌ಗಳು';

  @override
  String get dashboardTeacherJourneys =>
      'ಕಲಿಕೆಯ ಪಯಣಗಳು: ರೆಕಾರ್ಡಿಂಗ್‌ಗಳು, ಪ್ರಶ್ನೆಗಳು ಮತ್ತು ಪೋಲ್‌ಗಳು ಒಂದೇ ಹರಿವಿನಲ್ಲಿ';

  @override
  String get dashboardTeacherQuizzes =>
      'ಕ್ವಿಜ್‌ಗಳು ಮತ್ತು ಖಾಸಗಿ ಪ್ರಶ್ನೆ ಬ್ಯಾಂಕ್';

  @override
  String get dashboardOfflineLibrary => 'ಆಫ್‌ಲೈನ್ ಆಡಿಯೊ ಲೈಬ್ರರಿ';

  @override
  String get dashboardSearchField =>
      'ಸೆಷನ್‌ಗಳನ್ನು ಹುಡುಕಿ. ಓಕೆ ಒತ್ತಿ, ನಂತರ ಹೆಸರು ಅಥವಾ ಸೆಷನ್ ಸಂಖ್ಯೆ ಟೈಪ್ ಮಾಡಿ';

  @override
  String get dashboardTeacherSearchHelp =>
      'ಸೆಷನ್ ಹುಡುಕಾಟ. ಎಡಿಟ್ ಮಾಡಲು ಓಕೆ ಒತ್ತಿ, ನಂತರ ಸೆಷನ್ ಹೆಸರು ಟೈಪ್ ಮಾಡಿ, ಅಥವಾ ಸಂಖ್ಯೆ ಕೀಗಳಿಂದ ಸೆಷನ್ ಸಂಖ್ಯೆ ಟೈಪ್ ಮಾಡಿ. ಫೀಲ್ಡ್‌ನಿಂದ ಹೊರಬಂದು ಫಲಿತಾಂಶಗಳನ್ನು ನೋಡಲು ಮೇಲೆ ಅಥವಾ ಕೆಳಗೆ ಬಳಸಿ.';

  @override
  String dashboardTeacherNoMatch(String query) {
    return '$query ಗೆ ಹೊಂದುವ ಸೆಷನ್ ಇಲ್ಲ. ಎಲ್ಲಾ ಸೆಷನ್‌ಗಳನ್ನು ನೋಡಲು ಹುಡುಕಾಟವನ್ನು ಅಳಿಸಿ.';
  }

  @override
  String get dashboardEnded => 'ಮುಗಿದಿದೆ';

  @override
  String dashboardJoinedCount(String count) {
    return '$count ಜನ ಸೇರಿದ್ದಾರೆ';
  }

  @override
  String get dashboardPressOkToOpen => 'ತೆರೆಯಲು ಓಕೆ ಒತ್ತಿ';

  @override
  String get dashboardPressOkToReactivate => 'ಮತ್ತೆ ಸಕ್ರಿಯಗೊಳಿಸಲು ಓಕೆ ಒತ್ತಿ';

  @override
  String dashboardEndLabel(String title) {
    return 'ಎಲ್ಲರಿಗೂ $title ಮುಗಿಸಿ, ದೃಢೀಕರಣ ಕೇಳುತ್ತದೆ';
  }

  @override
  String dashboardDeleteLabel(String title) {
    return 'ಮುಗಿದ ಸೆಷನ್ $title ಅನ್ನು ಶಾಶ್ವತವಾಗಿ ಅಳಿಸಿ, ದೃಢೀಕರಣ ಕೇಳುತ್ತದೆ';
  }

  @override
  String get dashboardEndTitle => 'ಎಲ್ಲರಿಗೂ ಸೆಷನ್ ಮುಗಿಸಬೇಕೇ?';

  @override
  String dashboardEndMessage(String title) {
    return '\"$title\" ಅನ್ನು ಮುಗಿಸಿ ಪ್ರತಿಯೊಬ್ಬ ಭಾಗವಹಿಸುವವರಿಗೂ ಮುಚ್ಚಬೇಕೇ? ಸೆಷನ್ ನಿಮ್ಮ ಡ್ಯಾಶ್‌ಬೋರ್ಡ್ ಇತಿಹಾಸದಲ್ಲಿ ಉಳಿಯುತ್ತದೆ.';
  }

  @override
  String get dashboardEndedForEveryone =>
      'ಎಲ್ಲರಿಗೂ ಸೆಷನ್ ಮುಗಿದಿದೆ ಮತ್ತು ಸೆಷನ್ ಇತಿಹಾಸದಲ್ಲಿ ಇರಿಸಲಾಗಿದೆ.';

  @override
  String get dashboardEndFailed =>
      'ಸೆಷನ್ ಮುಗಿಸಲು ಆಗಲಿಲ್ಲ. ದಯವಿಟ್ಟು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get dashboardReactivateTitle => 'ಸೆಷನ್ ಮತ್ತೆ ಸಕ್ರಿಯಗೊಳಿಸಬೇಕೇ?';

  @override
  String dashboardReactivateMessage(String title) {
    return 'ಭಾಗವಹಿಸುವವರು ಮತ್ತೆ ಸೇರಲು \"$title\" ಅನ್ನು ಮತ್ತೆ ಸಕ್ರಿಯಗೊಳಿಸಬೇಕೇ?';
  }

  @override
  String get dashboardReactivated => 'ಸೆಷನ್ ಮತ್ತೆ ಸಕ್ರಿಯಗೊಂಡಿದೆ.';

  @override
  String get dashboardReactivateFailed =>
      'ಸೆಷನ್ ಮತ್ತೆ ಸಕ್ರಿಯಗೊಳಿಸಲು ಆಗಲಿಲ್ಲ. ದಯವಿಟ್ಟು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get dashboardOpenNowTitle => 'ಸೆಷನ್ ಈಗ ತೆರೆಯಬೇಕೇ?';

  @override
  String dashboardOpenNowMessage(String title) {
    return '\"$title\" ಮತ್ತೆ ಸಕ್ರಿಯವಾಗಿದೆ. ಈಗ ತೆರೆಯಿರಿ, ಅಥವಾ ನಂತರ ಡ್ಯಾಶ್‌ಬೋರ್ಡ್‌ನಿಂದ ಅದಕ್ಕೆ ಹಿಂತಿರುಗಿ.';
  }

  @override
  String get dashboardDeleteTitle => 'ಸೆಷನ್ ಶಾಶ್ವತವಾಗಿ ಅಳಿಸಬೇಕೇ?';

  @override
  String dashboardDeleteMessage(String title) {
    return '\"$title\" ಅನ್ನು ಅದರ ಭಾಗವಹಿಸುವವರು, ಚಾಟ್ ಮತ್ತು ಲಾಗ್‌ಗಳ ಸಹಿತ ಶಾಶ್ವತವಾಗಿ ಅಳಿಸಬೇಕೇ? ಇದನ್ನು ರದ್ದುಗೊಳಿಸಲು ಆಗುವುದಿಲ್ಲ.';
  }

  @override
  String get dashboardDeleted => 'ಸೆಷನ್ ಶಾಶ್ವತವಾಗಿ ಅಳಿಸಲಾಗಿದೆ.';

  @override
  String get dashboardDeleteFailed =>
      'ಸೆಷನ್ ಅಳಿಸಲು ಆಗಲಿಲ್ಲ. ದಯವಿಟ್ಟು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get dashboardStateNoWorkspace => 'ಯಾವುದೇ ವರ್ಕ್‌ಸ್ಪೇಸ್ ಆರಿಸಿಲ್ಲ.';

  @override
  String dashboardStateWorkspace(String name) {
    return 'ವರ್ಕ್‌ಸ್ಪೇಸ್: $name.';
  }

  @override
  String dashboardActiveSessions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ಸಕ್ರಿಯ ಸೆಷನ್‌ಗಳು',
      one: '1 ಸಕ್ರಿಯ ಸೆಷನ್',
    );
    return '$_temp0';
  }

  @override
  String dashboardStateTotals(String active, String total) {
    return '$active, ಒಟ್ಟು $total.';
  }

  @override
  String dashboardStateSearch(String query) {
    return 'ಹುಡುಕಾಟ: $query.';
  }

  @override
  String get adminSaveFailed =>
      'ಬದಲಾವಣೆಯನ್ನು ಉಳಿಸಲು ಆಗಲಿಲ್ಲ. ರಿಫ್ರೆಶ್ ಮಾಡಲು 1 ಒತ್ತಿ, ನಂತರ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String adminChoiceLabel(String what, String name, String position) {
    return '$what: $name, $position. ಬದಲಾಯಿಸಲು ಎಡ ಅಥವಾ ಬಲ ಬಳಸಿ';
  }

  @override
  String adminChoiceLabelSingle(String what, String name) {
    return '$what: $name. ಬದಲಾಯಿಸಲು ಎಡ ಅಥವಾ ಬಲ ಬಳಸಿ';
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
    return '$className ಆಯ್ಕೆ ಮಾಡಲಾಗಿದೆ. $subject ವಿಷಯ ಆಯ್ಕೆ ಮಾಡಲಾಗಿದೆ.';
  }

  @override
  String get adminNoSubjects => 'ಆಯ್ಕೆ ಮಾಡಿದ ತರಗತಿಯಲ್ಲಿ ಸಕ್ರಿಯ ವಿಷಯಗಳಿಲ್ಲ.';

  @override
  String adminStateSection(String section) {
    return 'ವಿಭಾಗ: $section.';
  }

  @override
  String adminStateShown(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ಐಟಂಗಳನ್ನು ತೋರಿಸಲಾಗಿದೆ.',
      one: '1 ಐಟಂ ತೋರಿಸಲಾಗಿದೆ.',
    );
    return '$_temp0';
  }

  @override
  String adminStateFilter(String filter) {
    return 'ಫಿಲ್ಟರ್: $filter.';
  }

  @override
  String adminStateSearch(String query) {
    return 'ಹುಡುಕಾಟ: $query.';
  }

  @override
  String get adminNoSubjectName =>
      'ವಿಷಯದ ಹೆಸರು ನಮೂದಿಸಿಲ್ಲ. ಏನನ್ನೂ ರಚಿಸಲಾಗಿಲ್ಲ.';

  @override
  String get adminNoClassName => 'ತರಗತಿಯ ಹೆಸರು ನಮೂದಿಸಿಲ್ಲ. ಏನನ್ನೂ ರಚಿಸಲಾಗಿಲ್ಲ.';

  @override
  String get adminNoActiveSubjects => 'ಈ ತರಗತಿಯಲ್ಲಿ ಸಕ್ರಿಯ ವಿಷಯಗಳಿಲ್ಲ.';

  @override
  String get adminListReadFailed => 'ನಿರ್ವಹಣಾ ಪಟ್ಟಿಯನ್ನು ಓದಲು ಆಗಲಿಲ್ಲ.';

  @override
  String adminNotRefreshed(String reason) {
    return '$reason ನಿರ್ವಹಣಾ ಡೇಟಾ ರಿಫ್ರೆಶ್ ಆಗಿಲ್ಲ. ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಲು 1 ಒತ್ತಿ.';
  }

  @override
  String adminExploreIntro(String sections) {
    return '$sections ನೋಡಲು D-pad ಮೇಲೆ ಮತ್ತು ಕೆಳಗೆ ಬಳಸಿ. ಆಯ್ಕೆ ಮಾಡಲು ಓಕೆ ಒತ್ತಿ.';
  }

  @override
  String adminSectionTitle(String section) {
    return 'ನಿರ್ವಹಣೆ. $section ವಿಭಾಗ';
  }

  @override
  String get adminSectionNameAccounts => 'ಖಾತೆಗಳು';

  @override
  String get adminSectionNameClasses => 'ತರಗತಿಗಳು';

  @override
  String get adminSectionNameSubjects => 'ವಿಷಯಗಳು';

  @override
  String get adminNoMatchingAccounts =>
      'ಹೊಂದಿಕೆಯಾಗುವ ಖಾತೆಗಳಿಲ್ಲ. ಹುಡುಕಾಟ ಅಥವಾ ಫಿಲ್ಟರ್‌ಗಳನ್ನು ಬದಲಾಯಿಸಿ.';

  @override
  String adminNoMatchingAccountsFor(String search) {
    return '$search ಗೆ ಹೊಂದಿಕೆಯಾಗುವ ಖಾತೆಗಳಿಲ್ಲ. ಹುಡುಕಾಟ ಅಥವಾ ಫಿಲ್ಟರ್‌ಗಳನ್ನು ಬದಲಾಯಿಸಿ.';
  }

  @override
  String adminClasses(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ತರಗತಿಗಳು',
      one: '1 ತರಗತಿ',
    );
    return '$_temp0';
  }

  @override
  String adminSubjects(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ವಿಷಯಗಳು',
      one: '1 ವಿಷಯ',
    );
    return '$_temp0';
  }

  @override
  String adminAccountsSummary(int count, String classes, String subjects) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ಖಾತೆಗಳು. $classes ಮತ್ತು $subjects.',
      one: '1 ಖಾತೆ. $classes ಮತ್ತು $subjects.',
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
      other:
          '$search ಗೆ $count ಖಾತೆಗಳು ಹೊಂದಿಕೆಯಾಗಿವೆ. $classes ಮತ್ತು $subjects.',
      one: '$search ಗೆ 1 ಖಾತೆ ಹೊಂದಿಕೆಯಾಗಿದೆ. $classes ಮತ್ತು $subjects.',
    );
    return '$_temp0';
  }

  @override
  String adminClassesSentence(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ತರಗತಿಗಳು.',
      one: '1 ತರಗತಿ.',
    );
    return '$_temp0';
  }

  @override
  String adminSubjectsSentence(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ವಿಷಯಗಳು.',
      one: '1 ವಿಷಯ.',
    );
    return '$_temp0';
  }

  @override
  String get adminNavigationAccounts =>
      'ಖಾತೆ ಹುಡುಕಾಟ, ಖಾತೆ ಪ್ರಕಾರ ಮತ್ತು ದಾಖಲಾತಿ ಫಿಲ್ಟರ್‌ಗಳು, ಮತ್ತು ಖಾತೆ ನಿರ್ವಹಣೆ. ಫಿಲ್ಟರ್ ಬದಲಾಯಿಸಲು ಅದರ ಮೇಲೆ ಎಡ ಅಥವಾ ಬಲ ಬಳಸಿ';

  @override
  String get adminNavigationClasses =>
      'ತರಗತಿ ರಚನೆ ಮತ್ತು ಸಕ್ರಿಯ ಅಥವಾ ಆರ್ಕೈವ್ ಮಾಡಿದ ತರಗತಿಗಳ ಪಟ್ಟಿ. ವಿಷಯ ನಿಯೋಜನೆಗಳು ಮತ್ತು ಆರ್ಕೈವ್ ಅಥವಾ ಮರುಸ್ಥಾಪನೆ ಕ್ರಿಯೆಗಳಿಗಾಗಿ ತರಗತಿಯ ಮೇಲೆ ಓಕೆ ಒತ್ತಿ';

  @override
  String get adminNavigationSubjects =>
      'ವಿಷಯ ರಚನೆ ಮತ್ತು ಸಕ್ರಿಯ ಅಥವಾ ಆರ್ಕೈವ್ ಮಾಡಿದ ವಿಷಯಗಳ ಪಟ್ಟಿ. ವಿಷಯವನ್ನು ಆರ್ಕೈವ್ ಅಥವಾ ಮರುಸ್ಥಾಪಿಸಲು ಅದರ ಮೇಲೆ ಓಕೆ ಒತ್ತಿ';

  @override
  String get adminSectionsTitle => 'ನಿರ್ವಹಣಾ ವಿಭಾಗಗಳು';

  @override
  String get adminSectionAccounts => 'ಖಾತೆಗಳು ಮತ್ತು ದಾಖಲಾತಿ';

  @override
  String get adminSectionClasses => 'ತರಗತಿಗಳು ಮತ್ತು ಅವುಗಳ ವಿಷಯಗಳು';

  @override
  String get adminSectionSubjects => 'ವಿಷಯಗಳು';

  @override
  String adminSectionChosen(String section) {
    return '$section ವಿಭಾಗ.';
  }

  @override
  String adminSectionExplore(String what) {
    return '$what ನೋಡಲು D-pad ಬಳಸಿ. ವಿಭಾಗ ಬದಲಾಯಿಸಲು 7 ಒತ್ತಿ.';
  }

  @override
  String get adminExploreAccounts =>
      'ಖಾತೆ ಫಿಲ್ಟರ್‌ಗಳು, ಹುಡುಕಾಟ ಮತ್ತು ಖಾತೆ ನಿರ್ವಹಣೆ';

  @override
  String get adminExploreClasses =>
      'ತರಗತಿ ರಚನೆ, ವಿಷಯ ನಿಯೋಜನೆಗಳು, ಮತ್ತು ಆರ್ಕೈವ್ ಅಥವಾ ಮರುಸ್ಥಾಪನೆ ಕ್ರಿಯೆಗಳು';

  @override
  String get adminExploreSubjects =>
      'ವಿಷಯ ರಚನೆ ಮತ್ತು ಆರ್ಕೈವ್ ಅಥವಾ ಮರುಸ್ಥಾಪನೆ ಕ್ರಿಯೆಗಳು';

  @override
  String adminRoleFilterSelected(String label) {
    return 'ಖಾತೆ ಪ್ರಕಾರ ಫಿಲ್ಟರ್: $label, ಆಯ್ಕೆ ಮಾಡಲಾಗಿದೆ.';
  }

  @override
  String adminAssignmentFilterSelected(String label) {
    return 'ನಿಯೋಜನೆ ಫಿಲ್ಟರ್: $label, ಆಯ್ಕೆ ಮಾಡಲಾಗಿದೆ.';
  }

  @override
  String get adminRoleFilterStudents => 'ವಿದ್ಯಾರ್ಥಿಗಳು ಮಾತ್ರ';

  @override
  String get adminRoleFilterTeachers => 'ಶಿಕ್ಷಕರು ಮಾತ್ರ';

  @override
  String get adminRoleFilterAll => 'ನೋಂದಾಯಿತ ಎಲ್ಲಾ ಖಾತೆಗಳು';

  @override
  String get adminAssignmentEnrolled => 'ದಾಖಲಾಗಿದ್ದಾರೆ';

  @override
  String get adminAssignmentAssigned => 'ನಿಯೋಜಿಸಲಾಗಿದೆ';

  @override
  String get adminAssignmentEnrolledOrAssigned =>
      'ದಾಖಲಾಗಿದ್ದಾರೆ ಅಥವಾ ನಿಯೋಜಿಸಲಾಗಿದೆ';

  @override
  String get adminAssignmentUnassigned => 'ನಿಯೋಜಿಸಲಾಗಿಲ್ಲ';

  @override
  String get adminAssignmentAll => 'ಎಲ್ಲಾ ನಿಯೋಜನೆ ಸ್ಥಿತಿಗಳು';

  @override
  String get adminRoleStudent => 'ವಿದ್ಯಾರ್ಥಿ';

  @override
  String get adminRoleTeacher => 'ಶಿಕ್ಷಕರು';

  @override
  String get adminNoClassAssigned => 'ಯಾವುದೇ ತರಗತಿ ನಿಯೋಜಿಸಲಾಗಿಲ್ಲ';

  @override
  String adminAssignmentCount(String count) {
    return '$count ನಿಯೋಜನೆಗಳು';
  }

  @override
  String adminAccountLabel(String name, String role, String access) {
    return '$name, $role. $access. ನಿರ್ವಹಿಸಲು ಓಕೆ ಒತ್ತಿ';
  }

  @override
  String get adminCancel => 'ರದ್ದುಮಾಡಿ';

  @override
  String get adminSave => 'ಉಳಿಸಿ';

  @override
  String get adminCreateSubjectTitle => 'ವಿಷಯ ರಚಿಸಿ';

  @override
  String get adminSubjectNameField => 'ವಿಷಯದ ಹೆಸರು';

  @override
  String adminSubjectCreated(String name) {
    return '$name ವಿಷಯ ರಚಿಸಲಾಗಿದೆ';
  }

  @override
  String get adminCreateClassTitle => 'ತರಗತಿ ರಚಿಸಿ';

  @override
  String get adminClassNameField => 'ತರಗತಿಯ ಹೆಸರು';

  @override
  String adminClassCreated(String name) {
    return '$name ತರಗತಿ ರಚಿಸಲಾಗಿದೆ';
  }

  @override
  String get adminArchiveClassTitle => 'ತರಗತಿಯನ್ನು ಆರ್ಕೈವ್ ಮಾಡಬೇಕೇ?';

  @override
  String get adminRestoreClassTitle => 'ತರಗತಿಯನ್ನು ಮರುಸ್ಥಾಪಿಸಬೇಕೇ?';

  @override
  String adminArchiveItemMessage(String name) {
    return '$name ಆರ್ಕೈವ್ ಆಗಿರುವಾಗ ಹೊಸ ಸೆಷನ್‌ಗಳು, ಆಡಿಯೋ ಮತ್ತು ನಿಯೋಜನೆಗಳು ಅದನ್ನು ಬಳಸಲು ಸಾಧ್ಯವಿಲ್ಲ.';
  }

  @override
  String adminRestoreItemMessage(String name) {
    return '$name ಮತ್ತೆ ನಿಯೋಜನೆಗಳಿಗೆ ಲಭ್ಯವಾಗುತ್ತದೆ.';
  }

  @override
  String get adminArchive => 'ಆರ್ಕೈವ್ ಮಾಡಿ';

  @override
  String get adminRestore => 'ಮರುಸ್ಥಾಪಿಸಿ';

  @override
  String get adminClassArchived => 'ತರಗತಿಯನ್ನು ಆರ್ಕೈವ್ ಮಾಡಲಾಗಿದೆ';

  @override
  String get adminClassRestored => 'ತರಗತಿಯನ್ನು ಮರುಸ್ಥಾಪಿಸಲಾಗಿದೆ';

  @override
  String adminManageTitle(String name) {
    return '$name ನಿರ್ವಹಿಸಿ';
  }

  @override
  String get adminManageClassSubjects => 'ತರಗತಿಯ ವಿಷಯಗಳನ್ನು ನಿರ್ವಹಿಸಿ';

  @override
  String get adminArchiveClassChoice =>
      'ದೃಢೀಕರಣದೊಂದಿಗೆ ತರಗತಿಯನ್ನು ಆರ್ಕೈವ್ ಮಾಡಿ';

  @override
  String get adminRestoreClassChoice => 'ದೃಢೀಕರಣದೊಂದಿಗೆ ತರಗತಿಯನ್ನು ಮರುಸ್ಥಾಪಿಸಿ';

  @override
  String adminSubjectsForClass(String name) {
    return '$name ತರಗತಿಯ ವಿಷಯಗಳು';
  }

  @override
  String adminSubjectRemovedFrom(String name) {
    return '$name ಇಂದ ವಿಷಯವನ್ನು ತೆಗೆದುಹಾಕಲಾಗಿದೆ';
  }

  @override
  String adminSubjectAddedTo(String name) {
    return '$name ಗೆ ವಿಷಯವನ್ನು ಸೇರಿಸಲಾಗಿದೆ';
  }

  @override
  String get adminArchiveSubjectTitle => 'ವಿಷಯವನ್ನು ಆರ್ಕೈವ್ ಮಾಡಬೇಕೇ?';

  @override
  String get adminRestoreSubjectTitle => 'ವಿಷಯವನ್ನು ಮರುಸ್ಥಾಪಿಸಬೇಕೇ?';

  @override
  String get adminSubjectArchived => 'ವಿಷಯವನ್ನು ಆರ್ಕೈವ್ ಮಾಡಲಾಗಿದೆ';

  @override
  String get adminSubjectRestored => 'ವಿಷಯವನ್ನು ಮರುಸ್ಥಾಪಿಸಲಾಗಿದೆ';

  @override
  String get adminManageAssignments => 'ನಿಯೋಜನೆಗಳನ್ನು ನಿರ್ವಹಿಸಿ';

  @override
  String get adminPasswordRecovery => 'ಪಾಸ್‌ವರ್ಡ್ ಮರುಪಡೆಯುವಿಕೆ';

  @override
  String adminManageUserScreen(String name) {
    return '$name ನಿರ್ವಹಿಸಿ. ನಿಯೋಜನೆಗಳು, ಪಾಸ್‌ವರ್ಡ್ ಮರುಪಡೆಯುವಿಕೆ ಅಥವಾ ರದ್ದುಮಾಡಿ ಆಯ್ಕೆಮಾಡಿ.';
  }

  @override
  String get adminRecoveryNeedsVersion =>
      'ಖಾತೆ ಮರುಪಡೆಯಲು ಸರ್ವರ್‌ನ ಈಗಿನ ಆವೃತ್ತಿ ಬೇಕು. ಖಾತೆಯನ್ನು ರಿಫ್ರೆಶ್ ಮಾಡಿ.';

  @override
  String get adminNoActiveClasses =>
      'ಸಕ್ರಿಯ ತರಗತಿಗಳಿಲ್ಲ. ಮೊದಲು ತರಗತಿಗಳ ವಿಭಾಗದಲ್ಲಿ ಒಂದು ತರಗತಿಯನ್ನು ರಚಿಸಿ ಅಥವಾ ಮರುಸ್ಥಾಪಿಸಿ.';

  @override
  String get adminTheCurrentClass => 'ಈಗಿನ ತರಗತಿ';

  @override
  String adminAssignClassTo(String name) {
    return '$name ಅವರಿಗೆ ತರಗತಿ ನಿಯೋಜಿಸಿ';
  }

  @override
  String get adminAssign => 'ನಿಯೋಜಿಸಿ';

  @override
  String get adminRemoveClass => 'ತರಗತಿ ತೆಗೆದುಹಾಕಿ';

  @override
  String get adminClassField => 'ತರಗತಿ';

  @override
  String adminRemoveStudentLabel(String name, String className) {
    return '$className ಇಂದ $name ಅವರನ್ನು ತೆಗೆದುಹಾಕಿ, ದೃಢೀಕರಣ ಕೇಳುತ್ತದೆ';
  }

  @override
  String adminAssignStudentLabel(String name) {
    return 'ಆಯ್ಕೆಮಾಡಿದ ತರಗತಿಗೆ $name ಅವರನ್ನು ನಿಯೋಜಿಸಿ';
  }

  @override
  String get adminRemoveFromClassTitle => 'ತರಗತಿಯಿಂದ ತೆಗೆದುಹಾಕಬೇಕೇ?';

  @override
  String adminRemoveFromClassMessage(String name, String className) {
    return '$className ಇಂದ $name ಅವರನ್ನು ತೆಗೆದುಹಾಕಬೇಕೇ? ಮತ್ತೆ ನಿಯೋಜಿಸುವವರೆಗೆ ಅವರಿಗೆ ಆ ತರಗತಿ ಕಾಣುವುದಿಲ್ಲ.';
  }

  @override
  String get adminKeepInClass => 'ತರಗತಿಯಲ್ಲೇ ಇರಿಸಿ';

  @override
  String get adminRemoveFromClass => 'ತರಗತಿಯಿಂದ ತೆಗೆದುಹಾಕಿ';

  @override
  String adminStudentRemovedFromClass(String name) {
    return '$name ಅವರನ್ನು ತರಗತಿಯಿಂದ ತೆಗೆದುಹಾಕಲಾಗಿದೆ';
  }

  @override
  String adminStudentAssignedTo(String name, String className) {
    return '$name ಅವರನ್ನು $className ಗೆ ನಿಯೋಜಿಸಲಾಗಿದೆ';
  }

  @override
  String adminAssignTeacherScreen(String name) {
    return '$name ಅವರನ್ನು ಒಂದು ತರಗತಿ ಮತ್ತು ವಿಷಯಕ್ಕೆ ನಿಯೋಜಿಸಿ';
  }

  @override
  String adminRemoveAssignmentLabel(
    String name,
    String className,
    String subject,
  ) {
    return '$className, $subject ಇಂದ $name ಅವರನ್ನು ತೆಗೆದುಹಾಕಿ, ದೃಢೀಕರಣ ಕೇಳುತ್ತದೆ';
  }

  @override
  String get adminSubjectField => 'ವಿಷಯ';

  @override
  String get adminSaveAssignment => 'ನಿಯೋಜನೆ ಉಳಿಸಿ';

  @override
  String get adminTeacherAssignmentSaved => 'ಶಿಕ್ಷಕರ ನಿಯೋಜನೆ ಉಳಿಸಲಾಗಿದೆ';

  @override
  String get adminRemoveAssignmentTitle => 'ನಿಯೋಜನೆ ತೆಗೆದುಹಾಕಬೇಕೇ?';

  @override
  String adminRemoveAssignmentMessage(
    String name,
    String className,
    String subject,
  ) {
    return '$className, $subject ಇಂದ $name ಅವರನ್ನು ತೆಗೆದುಹಾಕಬೇಕೇ?';
  }

  @override
  String get adminKeep => 'ಇರಿಸಿ';

  @override
  String get adminRemove => 'ತೆಗೆದುಹಾಕಿ';

  @override
  String get adminTeacherAssignmentRemoved => 'ಶಿಕ್ಷಕರ ನಿಯೋಜನೆ ತೆಗೆದುಹಾಕಲಾಗಿದೆ';

  @override
  String get adminRefreshData => 'ನಿರ್ವಾಹಕರ ಡೇಟಾ ರಿಫ್ರೆಶ್ ಮಾಡಿ';

  @override
  String get adminLogout => 'ಲಾಗ್ ಔಟ್, ದೃಢೀಕರಣ ಕೇಳುತ್ತದೆ';

  @override
  String adminSectionButton(String section) {
    return '$section ವಿಭಾಗ. ನಿರ್ವಹಣಾ ವಿಭಾಗ ಬದಲಿಸಿ';
  }

  @override
  String get adminSearchAccounts =>
      'ಹೆಸರು ಅಥವಾ ಫೋನ್ ಸಂಖ್ಯೆಯಿಂದ ಖಾತೆಗಳನ್ನು ಹುಡುಕಿ. ಟೈಪ್ ಮಾಡಲು ಓಕೆ ಒತ್ತಿ';

  @override
  String adminRoleFilterLabel(String label) {
    return 'ಖಾತೆ ಪ್ರಕಾರದ ಫಿಲ್ಟರ್: $label, ಆಯ್ಕೆಯಾಗಿದೆ. ಬದಲಿಸಲು ಎಡ ಅಥವಾ ಬಲ ಬಳಸಿ';
  }

  @override
  String adminAssignmentFilterLabel(String label) {
    return 'ನಿಯೋಜನೆ ಫಿಲ್ಟರ್: $label, ಆಯ್ಕೆಯಾಗಿದೆ. ಬದಲಿಸಲು ಎಡ ಅಥವಾ ಬಲ ಬಳಸಿ';
  }

  @override
  String adminClassActiveLabel(String name) {
    return '$name, ಸಕ್ರಿಯ. ತರಗತಿಯ ವಿಷಯಗಳು ಮತ್ತು ಆರ್ಕೈವ್ ಅಥವಾ ಮರುಸ್ಥಾಪನೆ ಕ್ರಿಯೆಗಳಿಗೆ ಓಕೆ ಒತ್ತಿ';
  }

  @override
  String adminClassArchivedLabel(String name) {
    return '$name, ಆರ್ಕೈವ್ ಮಾಡಲಾಗಿದೆ. ತರಗತಿಯ ವಿಷಯಗಳು ಮತ್ತು ಆರ್ಕೈವ್ ಅಥವಾ ಮರುಸ್ಥಾಪನೆ ಕ್ರಿಯೆಗಳಿಗೆ ಓಕೆ ಒತ್ತಿ';
  }

  @override
  String adminSubjectActiveLabel(String name) {
    return '$name, ಸಕ್ರಿಯ. ಆರ್ಕೈವ್ ಮಾಡಲು ಓಕೆ ಒತ್ತಿ';
  }

  @override
  String adminSubjectArchivedLabel(String name) {
    return '$name, ಆರ್ಕೈವ್ ಮಾಡಲಾಗಿದೆ. ಮರುಸ್ಥಾಪಿಸಲು ಓಕೆ ಒತ್ತಿ';
  }

  @override
  String adminSubjectInClass(String name) {
    return '$name. ಈ ತರಗತಿಯಲ್ಲಿ ಲಭ್ಯವಿದೆ. ತೆಗೆದುಹಾಕಲು ಆಯ್ಕೆಮಾಡಿ';
  }

  @override
  String adminSubjectNotInClass(String name) {
    return '$name. ಈ ತರಗತಿಯಲ್ಲಿ ಲಭ್ಯವಿಲ್ಲ. ಸೇರಿಸಲು ಆಯ್ಕೆಮಾಡಿ';
  }

  @override
  String get teacherHomeLater => 'ನಂತರ';

  @override
  String get teacherHomeStartNow => 'ಈಗ ಪ್ರಾರಂಭಿಸಿ';

  @override
  String get teacherHomeChooseWorkspaceTitle => 'ತರಗತಿ ಮತ್ತು ವಿಷಯ ಆರಿಸಿ';

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
    return '$className, $subjectName ಆಯ್ಕೆ ಮಾಡಲಾಗಿದೆ. $status. ಬೇರೆ ವರ್ಕ್‌ಸ್ಪೇಸ್ ಆರಿಸಲು 7 ಒತ್ತಿ.';
  }

  @override
  String get teacherHomeUntitledSession => 'ಹೆಸರಿಲ್ಲದ ಸೆಷನ್';

  @override
  String get teacherHomeUntitledSessionTitle => 'ಹೆಸರಿಲ್ಲದ ಸೆಷನ್';

  @override
  String get teacherHomeSessionFallback => 'ಸೆಷನ್';

  @override
  String get teacherHomeSearchLabel =>
      'ಸೆಷನ್‌ಗಳನ್ನು ಹುಡುಕಿ. ಓಕೆ ಒತ್ತಿ, ನಂತರ ಹೆಸರು ಅಥವಾ ಸೆಷನ್ ಸಂಖ್ಯೆ ಟೈಪ್ ಮಾಡಿ';

  @override
  String get teacherHomeKeepSessionOpen => 'ಸೆಷನ್ ತೆರೆದೇ ಇಡಿ';

  @override
  String get teacherHomeEndForEveryone => 'ಎಲ್ಲರಿಗೂ ಮುಗಿಸಿ';

  @override
  String get teacherHomeKeepEnded => 'ಮುಗಿದಂತೆಯೇ ಇಡಿ';

  @override
  String get teacherHomeReactivate => 'ಮತ್ತೆ ಸಕ್ರಿಯಗೊಳಿಸಿ';

  @override
  String get teacherHomeOpenLater => 'ನಂತರ ತೆರೆಯಿರಿ';

  @override
  String get teacherHomeOpenNow => 'ಈಗ ತೆರೆಯಿರಿ';

  @override
  String get teacherHomeKeepSession => 'ಸೆಷನ್ ಇಟ್ಟುಕೊಳ್ಳಿ';

  @override
  String get teacherHomeDeletePermanently => 'ಶಾಶ್ವತವಾಗಿ ಅಳಿಸಿ';

  @override
  String get teacherHomeNewSessionTitle => 'ಹೊಸ ಸೆಷನ್';

  @override
  String get teacherHomeCreateScreen => 'ಹೊಸ ಸೆಷನ್ ರಚಿಸಿ';

  @override
  String get teacherHomeCreateSessionKey => 'ಸೆಷನ್ ರಚಿಸಿ';

  @override
  String get teacherHomeTitleField => 'ಸೆಷನ್ ಶೀರ್ಷಿಕೆ ಫೀಲ್ಡ್';

  @override
  String get teacherHomeCancelCreate => 'ಸೆಷನ್ ರಚನೆ ರದ್ದುಮಾಡಿ';

  @override
  String get studentHomeSearchHelp =>
      'ಸೆಷನ್ ಹುಡುಕಾಟ. ಕೀಪ್ಯಾಡ್‌ನಿಂದ ಸೆಷನ್ ಸಂಖ್ಯೆ ಟೈಪ್ ಮಾಡಿ, ಅಥವಾ ಹೆಸರಿನಿಂದ ಹುಡುಕಲು ಕೆಳಗೆ ಹೋಗಿ. ಎಡಿಟ್ ಮಾಡಲು ಓಕೆ ಒತ್ತಿ. ಫಲಿತಾಂಶಗಳನ್ನು ನೋಡಲು ಕೆಳಗೆ ಬಳಸಿ.';

  @override
  String studentHomeSubjectFallback(String id) {
    return 'ವಿಷಯ $id';
  }

  @override
  String get studentHomeUntitledSession => 'ಹೆಸರಿಲ್ಲದ ಸೆಷನ್';

  @override
  String studentHomeSessionJoinLabel(String session) {
    return '$session. ಸೇರಲು ಓಕೆ ಒತ್ತಿ';
  }

  @override
  String get inviteNoStudentsEnrolled =>
      'ಈ ತರಗತಿಯಲ್ಲಿ ಯಾವುದೇ ವಿದ್ಯಾರ್ಥಿಗಳು ದಾಖಲಾಗಿಲ್ಲ. ರಿಫ್ರೆಶ್ ಮಾಡಲು 1 ಒತ್ತಿ.';

  @override
  String inviteLoadedSummary(int count, String invited) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ವಿದ್ಯಾರ್ಥಿಗಳು, $invited ಆಹ್ವಾನಿತರು.',
      one: '1 ವಿದ್ಯಾರ್ಥಿ, $invited ಆಹ್ವಾನಿತರು.',
    );
    return '$_temp0';
  }

  @override
  String get inviteUseSearch => 'ಹೆಸರನ್ನು ಹುಡುಕಲು ಹುಡುಕಾಟದ ಜಾಗವನ್ನು ಬಳಸಿ.';

  @override
  String get inviteLoadFailed =>
      'ವಿದ್ಯಾರ್ಥಿಗಳನ್ನು ಲೋಡ್ ಮಾಡಲು ಆಗಲಿಲ್ಲ. ನಿಮ್ಮ ಸಂಪರ್ಕ ಪರಿಶೀಲಿಸಿ ಮತ್ತು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಲು 1 ಒತ್ತಿ.';

  @override
  String inviteAlreadyInvited(String name) {
    return '$name ಅವರನ್ನು ಈಗಾಗಲೇ ಆಹ್ವಾನಿಸಲಾಗಿದೆ.';
  }

  @override
  String inviteInvitedOne(String name) {
    return '$name ಅವರನ್ನು ಆಹ್ವಾನಿಸಲಾಗಿದೆ.';
  }

  @override
  String inviteOneFailed(String name) {
    return '$name ಅವರನ್ನು ಆಹ್ವಾನಿಸಲು ಆಗಲಿಲ್ಲ. ನಿಮ್ಮ ಸಂಪರ್ಕ ಪರಿಶೀಲಿಸಿ ಮತ್ತು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಲು ಓಕೆ ಒತ್ತಿ.';
  }

  @override
  String get inviteNoStudentsToInvite => 'ಆಹ್ವಾನಿಸಲು ಯಾವುದೇ ವಿದ್ಯಾರ್ಥಿಗಳಿಲ್ಲ.';

  @override
  String get inviteAllAlreadyInvited =>
      'ಎಲ್ಲಾ ವಿದ್ಯಾರ್ಥಿಗಳನ್ನು ಈಗಾಗಲೇ ಆಹ್ವಾನಿಸಲಾಗಿದೆ.';

  @override
  String inviteInvitingAll(String count) {
    return '$count ವಿದ್ಯಾರ್ಥಿಗಳನ್ನು ಆಹ್ವಾನಿಸಲಾಗುತ್ತಿದೆ. ದಯವಿಟ್ಟು ಕಾಯಿರಿ.';
  }

  @override
  String inviteProgress(String done, String total) {
    return 'ವಿದ್ಯಾರ್ಥಿಗಳನ್ನು ಆಹ್ವಾನಿಸಲಾಗುತ್ತಿದೆ: $total ರಲ್ಲಿ $done ಮುಗಿದಿದೆ.';
  }

  @override
  String inviteAllDone(String count) {
    return 'ಎಲ್ಲಾ $count ವಿದ್ಯಾರ್ಥಿಗಳನ್ನು ಆಹ್ವಾನಿಸಲಾಗಿದೆ.';
  }

  @override
  String invitePartialFailed(String invited, String total, String names) {
    return '$total ರಲ್ಲಿ $invited ವಿದ್ಯಾರ್ಥಿಗಳನ್ನು ಆಹ್ವಾನಿಸಲಾಗಿದೆ. $names ಅವರನ್ನು ಆಹ್ವಾನಿಸಲು ಆಗಲಿಲ್ಲ. ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಲು 2 ಒತ್ತಿ.';
  }

  @override
  String inviteShowingAll(String count) {
    return 'ಎಲ್ಲಾ $count ವಿದ್ಯಾರ್ಥಿಗಳನ್ನು ತೋರಿಸಲಾಗುತ್ತಿದೆ.';
  }

  @override
  String inviteNoMatch(String query) {
    return '$query ಗೆ ಹೊಂದುವ ವಿದ್ಯಾರ್ಥಿಗಳಿಲ್ಲ. ಎಲ್ಲರನ್ನೂ ಪಟ್ಟಿ ಮಾಡಲು ಹುಡುಕಾಟವನ್ನು ಅಳಿಸಿ.';
  }

  @override
  String inviteMatches(int count, String query) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ವಿದ್ಯಾರ್ಥಿಗಳು $query ಗೆ ಹೊಂದುತ್ತಾರೆ. ನೋಡಲು ಕೆಳಗೆ ಬಳಸಿ.',
      one: '1 ವಿದ್ಯಾರ್ಥಿ $query ಗೆ ಹೊಂದುತ್ತಾರೆ. ನೋಡಲು ಕೆಳಗೆ ಬಳಸಿ.',
    );
    return '$_temp0';
  }

  @override
  String inviteStudentInvited(String name) {
    return '$name, ಆಹ್ವಾನಿಸಲಾಗಿದೆ';
  }

  @override
  String inviteStudentNotInvited(String name) {
    return '$name, ಆಹ್ವಾನಿಸಿಲ್ಲ. ಆಹ್ವಾನಿಸಲು ಓಕೆ ಒತ್ತಿ';
  }

  @override
  String get inviteBackToSession => 'ಸೆಷನ್‌ಗೆ ಹಿಂತಿರುಗಿ';

  @override
  String get inviteRefreshList => 'ವಿದ್ಯಾರ್ಥಿಗಳ ಪಟ್ಟಿ ರಿಫ್ರೆಶ್ ಮಾಡಿ';

  @override
  String get inviteAllStudents => 'ಎಲ್ಲಾ ವಿದ್ಯಾರ್ಥಿಗಳನ್ನು ಆಹ್ವಾನಿಸಿ';

  @override
  String get inviteSearchLabel =>
      'ಹೆಸರು ಅಥವಾ ಫೋನ್ ಸಂಖ್ಯೆಯಿಂದ ವಿದ್ಯಾರ್ಥಿಗಳನ್ನು ಹುಡುಕಿ. ಟೈಪ್ ಮಾಡಲು ಓಕೆ ಒತ್ತಿ';

  @override
  String inviteScreenName(String title) {
    return '$title ಗೆ ವಿದ್ಯಾರ್ಥಿಗಳನ್ನು ಆಹ್ವಾನಿಸಿ';
  }

  @override
  String get inviteKeyBack => 'ಸೆಷನ್‌ಗೆ ಹಿಂತಿರುಗಿ';

  @override
  String get inviteKeyRefresh => 'ವಿದ್ಯಾರ್ಥಿಗಳನ್ನು ರಿಫ್ರೆಶ್ ಮಾಡಿ';

  @override
  String get inviteKeyInviteAll => 'ಎಲ್ಲರನ್ನೂ ಆಹ್ವಾನಿಸಿ';

  @override
  String get notificationTitleSessionInvitation => 'ಲೈವ್ ತರಗತಿ';

  @override
  String get notificationTitleJourneyPublished => 'ಹೊಸ ಕಲಿಕೆಯ ಪಯಣ';

  @override
  String get notificationTitleQuizPublished => 'ಹೊಸ ಕ್ವಿಜ್';

  @override
  String get notificationTitleQuizReminder => 'ಕ್ವಿಜ್ ಜ್ಞಾಪನೆ';

  @override
  String get notificationTitleDefault => 'SEEDS ಅಪ್‌ಡೇಟ್';

  @override
  String get notificationArrivedSessionInvitation =>
      'ನಿಮ್ಮ ಶಿಕ್ಷಕರು ತರಗತಿ ಪ್ರಾರಂಭಿಸಿದ್ದಾರೆ. ಸೇರಲು 1 ಒತ್ತಿ, ಅಥವಾ ಈಗ ಬೇಡವೆಂದರೆ 0 ಒತ್ತಿ.';

  @override
  String get notificationArrivedJourneyPublished =>
      'ನಿಮ್ಮ ಶಿಕ್ಷಕರು ಹೊಸ ಕಲಿಕೆಯ ಪಯಣ ಹಂಚಿಕೊಂಡಿದ್ದಾರೆ. ತೆರೆಯಲು 1 ಒತ್ತಿ, ಅಥವಾ ಈಗ ಬೇಡವೆಂದರೆ 0 ಒತ್ತಿ.';

  @override
  String get notificationArrivedQuizPublished =>
      'ನಿಮ್ಮ ಶಿಕ್ಷಕರು ಹೊಸ ಕ್ವಿಜ್ ಪ್ರಕಟಿಸಿದ್ದಾರೆ. ನಿಮ್ಮ ಕ್ವಿಜ್‌ಗಳನ್ನು ತೆರೆಯಲು 1 ಒತ್ತಿ, ಅಥವಾ ಈಗ ಬೇಡವೆಂದರೆ 0 ಒತ್ತಿ.';

  @override
  String get notificationArrivedQuizReminder =>
      'ಜ್ಞಾಪನೆ: ನೀವು ತೆಗೆದುಕೊಳ್ಳಬೇಕಾದ ಕ್ವಿಜ್ ಇದೆ. ನಿಮ್ಮ ಕ್ವಿಜ್‌ಗಳನ್ನು ತೆರೆಯಲು 1 ಒತ್ತಿ, ಅಥವಾ ಈಗ ಬೇಡವೆಂದರೆ 0 ಒತ್ತಿ.';

  @override
  String get notificationArrivedDefault =>
      'ನಿಮಗೆ ಹೊಸ ಅಪ್‌ಡೇಟ್ ಇದೆ. ಹಿಂದೆ ಹೋಗಲು 0 ಒತ್ತಿ.';

  @override
  String get notificationForegroundSessionInvitation =>
      'ನಿಮ್ಮ ಶಿಕ್ಷಕರು ತರಗತಿ ಪ್ರಾರಂಭಿಸಿದ್ದಾರೆ. ನಿಮ್ಮ ಡ್ಯಾಶ್‌ಬೋರ್ಡ್‌ನ ಲೈವ್ ಸೆಷನ್‌ಗಳಿಂದ ಸೇರಿ.';

  @override
  String get notificationForegroundJourneyPublished =>
      'ನಿಮ್ಮ ಶಿಕ್ಷಕರು ಹೊಸ ಕಲಿಕೆಯ ಪಯಣ ಹಂಚಿಕೊಂಡಿದ್ದಾರೆ. ಅದನ್ನು ಕಲಿಕೆಯ ಪಯಣಗಳಲ್ಲಿ ಹುಡುಕಿ.';

  @override
  String get notificationForegroundQuizPublished =>
      'ನಿಮ್ಮ ಶಿಕ್ಷಕರು ಹೊಸ ಕ್ವಿಜ್ ಪ್ರಕಟಿಸಿದ್ದಾರೆ.';

  @override
  String get notificationForegroundQuizReminder =>
      'ಜ್ಞಾಪನೆ: ನೀವು ತೆಗೆದುಕೊಳ್ಳಬೇಕಾದ ಕ್ವಿಜ್ ಇದೆ.';

  @override
  String get notificationForegroundDefault => 'ನಿಮಗೆ ಹೊಸ ಅಪ್‌ಡೇಟ್ ಇದೆ.';

  @override
  String get notificationOpenJoinClass => 'ತರಗತಿಗೆ ಸೇರಿ';

  @override
  String get notificationOpenJourney => 'ಪಯಣ ತೆರೆಯಿರಿ';

  @override
  String get notificationOpenQuizzes => 'ಕ್ವಿಜ್‌ಗಳನ್ನು ತೆರೆಯಿರಿ';

  @override
  String get notificationOpenBack => 'ಹಿಂದೆ';

  @override
  String get notificationCannotOpen =>
      'ಇದನ್ನು ತೆರೆಯಲು ಆಗಲಿಲ್ಲ. ಮತ್ತೆ ಸೈನ್ ಇನ್ ಮಾಡಿ, ನಂತರ ನಿಮ್ಮ ಡ್ಯಾಶ್‌ಬೋರ್ಡ್‌ನಿಂದ ತೆರೆಯಿರಿ.';

  @override
  String get authLoginSuccessful => 'ಲಾಗಿನ್ ಯಶಸ್ವಿಯಾಗಿದೆ';

  @override
  String authRoleAlreadySelected(String role) {
    return '$role ಖಾತೆ ಈಗಾಗಲೇ ಆಯ್ಕೆಯಾಗಿದೆ';
  }

  @override
  String authRoleSelected(String role) {
    return '$role ಖಾತೆ ಆಯ್ಕೆಯಾಗಿದೆ';
  }

  @override
  String authRecoveryStep(String number, String step) {
    return 'ಹಂತ $number. $step';
  }

  @override
  String get authEnterPhone => 'ಫೋನ್ ಸಂಖ್ಯೆ ನಮೂದಿಸಿ';

  @override
  String get authEnterPassword => 'ಪಾಸ್‌ವರ್ಡ್ ನಮೂದಿಸಿ';

  @override
  String get authEnterName => 'ಹೆಸರು ನಮೂದಿಸಿ';

  @override
  String get authRegistering => 'ನೋಂದಣಿ ಆಗುತ್ತಿದೆ, ದಯವಿಟ್ಟು ಕಾಯಿರಿ.';

  @override
  String get authPasswordChanged => 'ಪಾಸ್‌ವರ್ಡ್ ಬದಲಾಗಿದೆ. ಸೈನ್ ಇನ್ ಆಗಿದೆ.';

  @override
  String journeyWhereFinished(String title) {
    return 'ಪಯಣ ಮುಗಿದಿದೆ. $title.';
  }

  @override
  String journeyWhere(String number, String total, String kind, String title) {
    return '$total ರಲ್ಲಿ ಹಂತ $number. $kind. $title.';
  }

  @override
  String journeyWhereReplaying(
    String number,
    String total,
    String kind,
    String title,
  ) {
    return '$total ರಲ್ಲಿ ಹಂತ $number. $kind. $title. ಪ್ರಶ್ನೆಗೆ ಮೊದಲು ಮತ್ತೆ ಕೇಳುತ್ತಿದ್ದೇವೆ.';
  }

  @override
  String get journeyKindRecording => 'ರೆಕಾರ್ಡಿಂಗ್';

  @override
  String get journeyKindNarration => 'ನಿರೂಪಣೆ';

  @override
  String get journeyKindQuestion => 'ಪ್ರಶ್ನೆ';

  @override
  String get journeyKindPoll => 'ಪೋಲ್';

  @override
  String journeyOption(String number, String text) {
    return 'ಆಯ್ಕೆ $number: $text.';
  }

  @override
  String journeyChooseKeys(String count) {
    return 'ಆಯ್ಕೆಮಾಡಲು 1 ರಿಂದ $count ಒತ್ತಿ, ನಂತರ ಸಲ್ಲಿಸಲು 5 ಒತ್ತಿ.';
  }

  @override
  String journeyPollQuestion(String question, String options, String keys) {
    return 'ಪೋಲ್. ಇಲ್ಲಿ ತಪ್ಪು ಉತ್ತರ ಇಲ್ಲ. $question $options $keys';
  }

  @override
  String journeyQuestion(String question, String options, String keys) {
    return 'ಪ್ರಶ್ನೆ. $question $options $keys';
  }

  @override
  String journeyQuestionTryAgain(
    String triesLeft,
    String question,
    String options,
    String keys,
  ) {
    return 'ಪ್ರಶ್ನೆ. ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ. $triesLeft $question $options $keys';
  }

  @override
  String journeyTriesLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ಪ್ರಯತ್ನಗಳು ಉಳಿದಿವೆ.',
      one: '1 ಪ್ರಯತ್ನ ಉಳಿದಿದೆ.',
    );
    return '$_temp0';
  }

  @override
  String journeyChosen(String number, String option) {
    return 'ಆಯ್ಕೆ $number, $option, ಆಯ್ಕೆಯಾಗಿದೆ. ಸಲ್ಲಿಸಲು 5 ಒತ್ತಿ, ಅಥವಾ ಬೇರೆ ಸಂಖ್ಯೆ ಆಯ್ಕೆಮಾಡಿ.';
  }

  @override
  String journeyRecordingContent(String title) {
    return 'ರೆಕಾರ್ಡಿಂಗ್: $title. ನಿಲ್ಲಿಸಲು ಅಥವಾ ಪ್ಲೇ ಮಾಡಲು 5 ಒತ್ತಿ. ಮುಂದೆ ಹೋಗಲು ಸಿದ್ಧರಾದಾಗ 2 ಒತ್ತಿ.';
  }

  @override
  String get journeyUntitled => 'ಶೀರ್ಷಿಕೆ ಇಲ್ಲ';

  @override
  String get journeyContentKeys =>
      'ಮುಂದಿನ ಹಂತಕ್ಕೆ 2, ಈ ಹಂತವನ್ನು ಪುನರಾವರ್ತಿಸಲು 3, ನೀವು ಎಲ್ಲಿದ್ದೀರಿ ಎಂದು ಕೇಳಲು 1, ಹಿಂದಿನ ರೆಕಾರ್ಡಿಂಗ್ ಅಥವಾ ನಿರೂಪಣೆಗೆ ಹಿಂತಿರುಗಲು 8 ಒತ್ತಿ.';

  @override
  String journeyCorrect(String answer) {
    return 'ಸರಿ! $answer.';
  }

  @override
  String get journeyPollSaved => 'ಧನ್ಯವಾದಗಳು. ನಿಮ್ಮ ಉತ್ತರ ಉಳಿಸಲಾಗಿದೆ.';

  @override
  String get journeyReplayOutcome =>
      'ಸರಿಯಾಗಿಲ್ಲ. ಆ ಭಾಗವನ್ನು ಮತ್ತೆ ಕೇಳೋಣ, ನಂತರ ಇನ್ನೊಮ್ಮೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get journeyTryAgainOutcome =>
      'ಸರಿಯಾಗಿಲ್ಲ. ಮತ್ತೆ ಯೋಚಿಸಿ ಬೇರೆ ಉತ್ತರ ಆಯ್ಕೆಮಾಡಿ.';

  @override
  String journeyRevealed(String number, String answer, String explanation) {
    return 'ಸರಿಯಾಗಿಲ್ಲ. ಉತ್ತರ ಆಯ್ಕೆ $number, $answer. $explanation';
  }

  @override
  String journeyWellDone(String title) {
    return 'ಚೆನ್ನಾಗಿದೆ! ನೀವು $title ಮುಗಿಸಿದ್ದೀರಿ.';
  }

  @override
  String journeyFirstTryScore(int questions, String correct) {
    String _temp0 = intl.Intl.pluralLogic(
      questions,
      locale: localeName,
      other:
          'ಮೊದಲ ಪ್ರಯತ್ನದಲ್ಲಿ $questions ಪ್ರಶ್ನೆಗಳಲ್ಲಿ $correct ಸರಿಯಾಗಿ ಉತ್ತರಿಸಿದ್ದೀರಿ.',
      one: 'ಮೊದಲ ಪ್ರಯತ್ನದಲ್ಲಿ 1 ಪ್ರಶ್ನೆಯಲ್ಲಿ $correct ಸರಿಯಾಗಿ ಉತ್ತರಿಸಿದ್ದೀರಿ.',
    );
    return '$_temp0';
  }

  @override
  String get journeyPlayAgainHelp =>
      'ಮತ್ತೆ ಪ್ಲೇ ಮಾಡಲು 1 ಒತ್ತಿ, ಅಥವಾ ನಿಮ್ಮ ಪಯಣಗಳಿಗೆ ಹಿಂತಿರುಗಲು 0 ಒತ್ತಿ.';

  @override
  String get journeyStatusCompleted => 'ಮುಗಿದಿದೆ';

  @override
  String get journeyStatusInProgress => 'ನಡೆಯುತ್ತಿದೆ';

  @override
  String get journeyStatusNew => 'ಹೊಸದು';

  @override
  String journeyRowScore(String percent) {
    return 'ಅಂಕ $percent ಪ್ರತಿಶತ.';
  }

  @override
  String get journeyRowDownloaded => 'ಡೌನ್‌ಲೋಡ್ ಆಗಿದೆ.';

  @override
  String journeyStudentRow(
    String title,
    String subject,
    String steps,
    String questions,
    String status,
  ) {
    return '$title. $subject. $steps ಹಂತಗಳು, $questions ಪ್ರಶ್ನೆಗಳು. $status.';
  }

  @override
  String journeyTeacherRow(
    String title,
    String status,
    String steps,
    String questions,
  ) {
    return '$title. $status. $steps ಹಂತಗಳು, $questions ಪ್ರಶ್ನೆಗಳು.';
  }

  @override
  String get journeyRowGraded => 'ಅಂಕಸಹಿತ.';

  @override
  String journeyStepRow(String number, String total, String name) {
    return '$total ರಲ್ಲಿ ಹಂತ $number. $name.';
  }

  @override
  String get journeyReplaysAutomatically => 'ತಾನಾಗಿಯೇ ಮತ್ತೆ ಪ್ಲೇ ಆಗುತ್ತದೆ.';

  @override
  String journeyReplaysFrom(String number) {
    return 'ಹಂತ $number ರಿಂದ ಮತ್ತೆ ಪ್ಲೇ ಆಗುತ್ತದೆ.';
  }

  @override
  String get journeyFinishedStatus => 'ಪಯಣ ಮುಗಿದಿದೆ.';

  @override
  String get journeyRecordingPlaying => 'ರೆಕಾರ್ಡಿಂಗ್ ಪ್ಲೇ ಆಗುತ್ತಿದೆ.';

  @override
  String get journeyRecordingPaused => 'ರೆಕಾರ್ಡಿಂಗ್ ನಿಲ್ಲಿಸಲಾಗಿದೆ.';

  @override
  String get journeyNoOptionChosen => 'ಇನ್ನೂ ಯಾವುದೇ ಆಯ್ಕೆ ಮಾಡಿಲ್ಲ.';

  @override
  String journeyOptionSelected(String number, String option) {
    return 'ಆಯ್ಕೆ $number, $option, ಆಯ್ಕೆಯಾಗಿದೆ.';
  }

  @override
  String journeyPreviewStart(String title) {
    return '$title ನ ಮುನ್ನೋಟ. ಏನನ್ನೂ ಉಳಿಸಲಾಗುವುದಿಲ್ಲ.';
  }

  @override
  String journeyWelcomeBack(String title) {
    return '$title ಗೆ ಮರಳಿ ಸ್ವಾಗತ. ನೀವು ನಿಲ್ಲಿಸಿದ ಜಾಗದಿಂದ ಮುಂದುವರಿಯುತ್ತಿದೆ.';
  }

  @override
  String journeyStartingBrief(String title) {
    return '$title ಪ್ರಾರಂಭವಾಗುತ್ತಿದೆ.';
  }

  @override
  String journeyStartingDetailed(String title, String steps) {
    return '$title ಪ್ರಾರಂಭವಾಗುತ್ತಿದೆ. $steps ಹಂತಗಳು. ಸಹಾಯಕ್ಕಾಗಿ ಯಾವಾಗ ಬೇಕಾದರೂ ಸ್ಟಾರ್ ಒತ್ತಿ.';
  }

  @override
  String journeyNotSaved(String reason) {
    return 'ನಿಮ್ಮ ಸ್ಥಾನವನ್ನು ಉಳಿಸಲು ಆಗಲಿಲ್ಲ. $reason';
  }

  @override
  String get journeyListeningAgain => 'ಮತ್ತೆ ಕೇಳುತ್ತಿದ್ದೇವೆ.';

  @override
  String journeyNarration(String text) {
    return '$text ಮುಂದುವರಿಯಲು 2 ಒತ್ತಿ.';
  }

  @override
  String journeyRecordingStatus(String title) {
    return 'ರೆಕಾರ್ಡಿಂಗ್: $title';
  }

  @override
  String get journeyRecordingFailed =>
      'ಈ ರೆಕಾರ್ಡಿಂಗ್ ಪ್ಲೇ ಮಾಡಲು ಆಗಲಿಲ್ಲ. ನಿಮ್ಮ ಇಂಟರ್ನೆಟ್ ಪರಿಶೀಲಿಸಿ.';

  @override
  String get journeyRecordingRetry =>
      'ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಲು 3 ಒತ್ತಿ, ಅಥವಾ ಮುಂದಿನ ಹಂತಕ್ಕೆ ಹೋಗಲು 2 ಒತ್ತಿ.';

  @override
  String get journeyNotDownloaded =>
      'ಈ ರೆಕಾರ್ಡಿಂಗ್ ಈ ಫೋನ್‌ನಲ್ಲಿ ಡೌನ್‌ಲೋಡ್ ಆಗಿಲ್ಲ.';

  @override
  String get journeyRecordingFinished => 'ರೆಕಾರ್ಡಿಂಗ್ ಮುಗಿದಿದೆ.';

  @override
  String journeyAnswerFirst(String count) {
    return 'ಮೊದಲು ಉತ್ತರಿಸಿ. ಆಯ್ಕೆಮಾಡಲು 1 ರಿಂದ $count ಒತ್ತಿ, ನಂತರ 5 ಒತ್ತಿ.';
  }

  @override
  String get journeyNoEarlierContent =>
      'ಹಿಂದೆ ಯಾವುದೇ ರೆಕಾರ್ಡಿಂಗ್ ಅಥವಾ ನಿರೂಪಣೆ ಇಲ್ಲ.';

  @override
  String get journeyGoingBack => 'ಹಿಂತಿರುಗುತ್ತಿದೆ.';

  @override
  String journeyNoSuchOption(String option, String count) {
    return 'ಆಯ್ಕೆ $option ಇಲ್ಲ. 1 ರಿಂದ $count ಆಯ್ಕೆಮಾಡಿ.';
  }

  @override
  String journeyChooseFirst(String count) {
    return 'ಮೊದಲು 1 ರಿಂದ $count ಬಳಸಿ ಉತ್ತರ ಆಯ್ಕೆಮಾಡಿ.';
  }

  @override
  String get journeySendLater =>
      'ಪಯಣ ಮುಗಿದಿದೆ. ನೀವು ಆನ್‌ಲೈನ್ ಆದಾಗ ನಿಮ್ಮ ಉತ್ತರಗಳನ್ನು ಕಳುಹಿಸಲಾಗುತ್ತದೆ.';

  @override
  String get journeyStartingAgain => 'ಮತ್ತೆ ಪ್ರಾರಂಭಿಸಲಾಗುತ್ತಿದೆ.';

  @override
  String get journeyPaused => 'ನಿಲ್ಲಿಸಲಾಗಿದೆ.';

  @override
  String get journeySeekRecordingsOnly =>
      'ಮುಂದೆ ಅಥವಾ ಹಿಂದೆ ಸರಿಸುವುದು ರೆಕಾರ್ಡಿಂಗ್‌ಗಳಲ್ಲಿ ಮಾತ್ರ ಕೆಲಸ ಮಾಡುತ್ತದೆ.';

  @override
  String get journeySpeedRecordingsOnly =>
      'ರೆಕಾರ್ಡಿಂಗ್ ವೇಗ ರೆಕಾರ್ಡಿಂಗ್‌ಗಳಲ್ಲಿ ಮಾತ್ರ ಬದಲಾಗುತ್ತದೆ.';

  @override
  String get journeyFastest => 'ಅತಿ ಹೆಚ್ಚು ವೇಗ.';

  @override
  String get journeySlowest => 'ಅತಿ ಕಡಿಮೆ ವೇಗ.';

  @override
  String journeySpeed(String rate) {
    return 'ರೆಕಾರ್ಡಿಂಗ್ ವೇಗ $rate ಪಟ್ಟು.';
  }

  @override
  String get journeyLeaveTitle => 'ಈ ಪಯಣದಿಂದ ಹೊರಡಬೇಕೇ?';

  @override
  String journeyLeaveMessage(String step) {
    return 'ನಿಮ್ಮ ಸ್ಥಾನ ಈ ಫೋನ್‌ನಲ್ಲಿ ಉಳಿದಿದೆ. ಮುಂದಿನ ಬಾರಿ ಹಂತ $step ರಿಂದ ಮುಂದುವರಿಸಬಹುದು.';
  }

  @override
  String get journeyAnswerHelp =>
      'ಆಯ್ಕೆಮಾಡಲು ಒಂದು ಸಂಖ್ಯೆ, ಸಲ್ಲಿಸಲು 5, ಪ್ರಶ್ನೆಯನ್ನು ಮತ್ತೆ ಕೇಳಲು 6 ಒತ್ತಿ.';

  @override
  String journeyStepRemoved(String remaining) {
    return 'ಹಂತ ತೆಗೆದುಹಾಕಲಾಗಿದೆ. ಈಗ ಪಯಣದಲ್ಲಿ $remaining ಹಂತಗಳಿವೆ.';
  }

  @override
  String journeyStepRemovedUndo(String name) {
    return '$name ತೆಗೆದುಹಾಕಲಾಗಿದೆ.';
  }

  @override
  String get journeyStepRestored => 'ಹಂತ ಮರುಸ್ಥಾಪಿಸಲಾಗಿದೆ.';

  @override
  String journeyCreated(String title) {
    return '$title ರಚಿಸಲಾಗಿದೆ. ಈಗ ಅದರ ಮೊದಲ ಹಂತ ಸೇರಿಸಿ.';
  }

  @override
  String get journeyNoStepAdded => 'ಯಾವುದೇ ಹಂತ ಸೇರಿಸಲಾಗಿಲ್ಲ.';

  @override
  String journeyPreviewSkips(String issues) {
    return 'ಈ ಮುನ್ನೋಟದಲ್ಲಿ ಕೆಲವು ಹಂತಗಳನ್ನು ಬಿಡಲಾಗಿದೆ. $issues';
  }

  @override
  String journeyDuplicated(String title) {
    return '$title ಅನ್ನು ಹೊಸ ಕರಡಾಗಿ ರಚಿಸಲಾಗಿದೆ. ಕರಡುಗಳಲ್ಲಿ ಅದನ್ನು ಹುಡುಕಿ.';
  }

  @override
  String journeyArchiveMessage(String title) {
    return 'ವಿದ್ಯಾರ್ಥಿಗಳಿಗೆ ಇನ್ನು $title ಕಾಣುವುದಿಲ್ಲ. ಫಲಿತಾಂಶಗಳು ಉಳಿಯುತ್ತವೆ. ನಂತರ ನೀವು ಅದನ್ನು ಮರುಸ್ಥಾಪಿಸಬಹುದು.';
  }

  @override
  String journeyRestoreMessage(String title) {
    return 'ವಿದ್ಯಾರ್ಥಿಗಳಿಗೆ $title ಮತ್ತೆ ಕಾಣುತ್ತದೆ.';
  }

  @override
  String get journeyArchived =>
      'ಆರ್ಕೈವ್ ಮಾಡಲಾಗಿದೆ. ವಿದ್ಯಾರ್ಥಿಗಳಿಗೆ ಇನ್ನು ಕಾಣುವುದಿಲ್ಲ.';

  @override
  String get journeyRestored => 'ವಿದ್ಯಾರ್ಥಿಗಳಿಗಾಗಿ ಮರುಸ್ಥಾಪಿಸಲಾಗಿದೆ.';

  @override
  String journeyDeleteDraftMessage(String title) {
    return '$title ಅನ್ನು ಶಾಶ್ವತವಾಗಿ ಅಳಿಸಬೇಕೇ? ರೆಕಾರ್ಡಿಂಗ್‌ಗಳು ನಿಮ್ಮ ಲೈಬ್ರರಿಯಲ್ಲಿ ಉಳಿಯುತ್ತವೆ.';
  }

  @override
  String get journeyDraftDeleted => 'ಕರಡು ಅಳಿಸಲಾಗಿದೆ.';

  @override
  String get journeyNoRetriesLeft => 'ಈಗಾಗಲೇ ಮರುಪ್ರಯತ್ನಗಳಿಲ್ಲ.';

  @override
  String get journeyMaxRetries => 'ಐದು ಮರುಪ್ರಯತ್ನಗಳೇ ಗರಿಷ್ಠ.';

  @override
  String journeyPublished(String count) {
    return 'ಪ್ರಕಟಿಸಲಾಗಿದೆ. ವಿದ್ಯಾರ್ಥಿಗಳು ಈಗ ಇದನ್ನು ಪ್ಲೇ ಮಾಡಬಹುದು. ಅಧಿಸೂಚನೆಗಳು $count ಫೋನ್‌ಗಳನ್ನು ತಲುಪಿವೆ.';
  }

  @override
  String get journeyOptionUsed =>
      'ಆ ಆಯ್ಕೆ ಈಗಾಗಲೇ ಬಳಕೆಯಲ್ಲಿದೆ. ಬೇರೆ ಆಯ್ಕೆ ಟೈಪ್ ಮಾಡಿ.';

  @override
  String get journeyNothingToReplay =>
      'ಈ ಪ್ರಶ್ನೆಗೆ ಮೊದಲು ಇನ್ನೂ ಯಾವುದೇ ರೆಕಾರ್ಡಿಂಗ್ ಅಥವಾ ನಿರೂಪಣೆ ಇಲ್ಲ, ಆದ್ದರಿಂದ ತಪ್ಪು ಉತ್ತರ ನೀಡಿದರೆ ಮತ್ತೆ ಕೇಳುತ್ತದೆ. ನೀವು ಮೊದಲು ವಿಷಯ ಸೇರಿಸಿ ನಂತರ ಇದನ್ನು ಬದಲಿಸಬಹುದು.';

  @override
  String get journeyBankEmpty =>
      'ಈ ತರಗತಿ ಮತ್ತು ವಿಷಯದ ನಿಮ್ಮ ಪ್ರಶ್ನೆ ಬ್ಯಾಂಕ್ ಖಾಲಿಯಾಗಿದೆ. ಬದಲಿಗೆ ಹೊಸ ಪ್ರಶ್ನೆ ಬರೆಯಿರಿ ಆಯ್ಕೆಮಾಡಿ.';

  @override
  String get journeyRecordViaNotes =>
      'ಖಾಸಗಿ ಟಿಪ್ಪಣಿಗಳನ್ನು ತೆರೆಯಲಾಗುತ್ತಿದೆ. ರೆಕಾರ್ಡ್ ಮಾಡಿ, ಪರಿಶೀಲಿಸಿ, ನಂತರ ಈ ತರಗತಿ ಮತ್ತು ವಿಷಯಕ್ಕೆ ಪ್ರಕಟಿಸಿ ಆಯ್ಕೆಮಾಡಿ. 0 ಒತ್ತಿ ಹಿಂತಿರುಗಿ, ನಿಮ್ಮ ಹೊಸ ರೆಕಾರ್ಡಿಂಗ್ ಆಯ್ಕೆಮಾಡಿ.';

  @override
  String get journeyNoRecordings =>
      'ಈ ತರಗತಿ ಮತ್ತು ವಿಷಯದಲ್ಲಿ ಇನ್ನೂ ಯಾವುದೇ ಆಡಿಯೋ ಫೈಲ್‌ಗಳಿಲ್ಲ, ಆದ್ದರಿಂದ ಏನೂ ಸೇರಿಸಲಾಗಿಲ್ಲ. ನೀವು ಹಿಂದಿನ ಪರದೆಗೆ ಮರಳಿದ್ದೀರಿ. ಒಂದನ್ನು ಸೇರಿಸಲು, ಮತ್ತೆ ರೆಕಾರ್ಡಿಂಗ್ ಆಯ್ಕೆಮಾಡಿ, ನಂತರ ರೆಕಾರ್ಡಿಂಗ್ ಫೈಲ್ ಅಪ್‌ಲೋಡ್ ಮಾಡಲು 2 ಅಥವಾ ಹೊಸದನ್ನು ರೆಕಾರ್ಡ್ ಮಾಡಲು 3 ಒತ್ತಿ.';

  @override
  String get journeyOpeningFiles =>
      'ಆಡಿಯೋ ಫೈಲ್‌ಗಾಗಿ ಫೈಲ್ ಆಯ್ಕೆಯನ್ನು ತೆರೆಯಲಾಗುತ್ತಿದೆ.';

  @override
  String get journeyNoFile => 'ಯಾವುದೇ ಫೈಲ್ ಆಯ್ಕೆಮಾಡಿಲ್ಲ.';

  @override
  String get journeyUploading => 'ಅಪ್‌ಲೋಡ್ ಆಗುತ್ತಿದೆ. ದಯವಿಟ್ಟು ಕಾಯಿರಿ.';

  @override
  String get journeyUploadUnconfirmed =>
      'ಅಪ್‌ಲೋಡ್ ದೃಢಪಟ್ಟಿಲ್ಲ. ನಕಲು ಆಗದಂತೆ, ಮತ್ತೆ ಪ್ರಯತ್ನಿಸುವ ಮೊದಲು ನನ್ನ ರೆಕಾರ್ಡಿಂಗ್‌ಗಳನ್ನು ಪರಿಶೀಲಿಸಿ.';

  @override
  String journeyUploaded(String title) {
    return '$title ಅಪ್‌ಲೋಡ್ ಆಗಿದೆ.';
  }

  @override
  String get journeyStorageUnavailable => 'ಪಯಣದ ಸಂಗ್ರಹಣೆ ಲಭ್ಯವಿಲ್ಲ.';

  @override
  String get journeyNothingInProgress =>
      'ಯಾವುದೇ ಪಯಣ ನಡೆಯುತ್ತಿಲ್ಲ. ಹೊಸ ಪಯಣಗಳಿಗೆ 2 ಒತ್ತಿ.';

  @override
  String get journeyTeacherUpdated =>
      'ನಿಮ್ಮ ಶಿಕ್ಷಕರು ಈ ಪಯಣವನ್ನು ಬದಲಿಸಿದ್ದಾರೆ. ಹೊಸ ಆವೃತ್ತಿಯನ್ನು ಆಫ್‌ಲೈನ್‌ನಲ್ಲಿ ಪ್ಲೇ ಮಾಡಲು ಮತ್ತೆ ಡೌನ್‌ಲೋಡ್ ಮಾಡಿ.';

  @override
  String journeyStartOverMessage(String title) {
    return '$title ಅನ್ನು ಹಂತ 1 ರಿಂದ ಮತ್ತೆ ಪ್ರಾರಂಭಿಸಬೇಕೇ? ನೀವು ಈಗಾಗಲೇ ನೀಡಿದ ಉತ್ತರಗಳು ಈಗಲೂ ನಿಮ್ಮ ಶಿಕ್ಷಕರಿಗೆ ಕಳುಹಿಸಲ್ಪಡುತ್ತವೆ.';
  }

  @override
  String journeyRemoveDownloadMessage(String title) {
    return '$title ಅನ್ನು ಈ ಫೋನ್‌ನಿಂದ ತೆಗೆದುಹಾಕಬೇಕೇ? ಪಯಣದಲ್ಲಿ ನಿಮ್ಮ ಸ್ಥಾನ ಉಳಿಯುತ್ತದೆ. ಇಂಟರ್ನೆಟ್ ಇದ್ದಾಗ ಮತ್ತೆ ಡೌನ್‌ಲೋಡ್ ಮಾಡಬಹುದು.';
  }

  @override
  String journeyDownloadRemoved(String title) {
    return '$title ನ ಡೌನ್‌ಲೋಡ್ ತೆಗೆದುಹಾಕಲಾಗಿದೆ.';
  }

  @override
  String journeyDownloading(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ರೆಕಾರ್ಡಿಂಗ್‌ಗಳು ಡೌನ್‌ಲೋಡ್ ಆಗುತ್ತಿವೆ. ರದ್ದುಮಾಡಲು 0 ಒತ್ತಿ.',
      one: '1 ರೆಕಾರ್ಡಿಂಗ್ ಡೌನ್‌ಲೋಡ್ ಆಗುತ್ತಿದೆ. ರದ್ದುಮಾಡಲು 0 ಒತ್ತಿ.',
    );
    return '$_temp0';
  }

  @override
  String journeyDownloaded(String title) {
    return 'ಡೌನ್‌ಲೋಡ್ ಆಗಿದೆ. ಇಂಟರ್ನೆಟ್ ಇಲ್ಲದೆ $title ಪ್ಲೇ ಮಾಡಬಹುದು.';
  }

  @override
  String get journeyCancellingDownload =>
      'ಡೌನ್‌ಲೋಡ್ ರದ್ದುಮಾಡಲಾಗುತ್ತಿದೆ. ಉಳಿಸಿದ ರೆಕಾರ್ಡಿಂಗ್‌ಗಳು ಉಳಿಯುತ್ತವೆ.';

  @override
  String journeyStepDetailsQuestion(
    String name,
    String options,
    String number,
    String explanation,
  ) {
    return '$name $options ಸರಿಯಾದ ಉತ್ತರ: ಆಯ್ಕೆ $number. $explanation';
  }

  @override
  String get journeyNoExplanation => 'ವಿವರಣೆ ಇಲ್ಲ.';

  @override
  String journeyExplanation(String text) {
    return 'ವಿವರಣೆ: $text';
  }

  @override
  String journeyStepNameRecording(String title) {
    return 'ರೆಕಾರ್ಡಿಂಗ್. $title';
  }

  @override
  String get journeyUntitledRecording => 'ಶೀರ್ಷಿಕೆ ಇಲ್ಲದ ರೆಕಾರ್ಡಿಂಗ್';

  @override
  String journeyStepNameNarration(String text) {
    return 'ನಿರೂಪಣೆ. $text';
  }

  @override
  String journeyStepNameQuestion(String text) {
    return 'ಪ್ರಶ್ನೆ. $text';
  }

  @override
  String journeyStepNamePoll(String text) {
    return 'ಪೋಲ್. $text';
  }

  @override
  String get journeyStatusPublished => 'ಪ್ರಕಟಿತ';

  @override
  String get journeyStatusArchived => 'ಆರ್ಕೈವ್ ಮಾಡಲಾಗಿದೆ';

  @override
  String get journeyStatusDraft => 'ಕರಡು, ಇನ್ನೂ ಪ್ರಕಟಿಸಿಲ್ಲ';

  @override
  String journeyStatusWithChanges(String status) {
    return '$status, ಪ್ರಕಟಿಸದ ಬದಲಾವಣೆಗಳೊಂದಿಗೆ';
  }

  @override
  String get journeyErrorChanged =>
      'ಈ ಪಯಣ ಬದಲಾಗಿದೆ. ರಿಫ್ರೆಶ್ ಮಾಡಿ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get journeyErrorSignInExpired =>
      'ನಿಮ್ಮ ಸೈನ್ ಇನ್ ಅವಧಿ ಮುಗಿದಿದೆ. ಮತ್ತೆ ಸೈನ್ ಇನ್ ಮಾಡಿ.';

  @override
  String get journeyErrorPermission => 'ಅದನ್ನು ಮಾಡಲು ನಿಮಗೆ ಅನುಮತಿ ಇಲ್ಲ.';

  @override
  String get journeyErrorNotAvailable => 'ಈ ಪಯಣ ಇನ್ನು ಲಭ್ಯವಿಲ್ಲ.';

  @override
  String get journeyErrorInvalid =>
      'ಕೆಲವು ಮಾಹಿತಿಯನ್ನು ಸ್ವೀಕರಿಸಲು ಆಗಲಿಲ್ಲ. ಅದನ್ನು ಪರಿಶೀಲಿಸಿ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get journeyErrorServer =>
      'ಶಾಲೆಯ ಸರ್ವರ್‌ನಲ್ಲಿ ಸಮಸ್ಯೆ ಆಗಿದೆ. ನಂತರ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get journeyErrorRequestFailed =>
      'ವಿನಂತಿ ಯಶಸ್ವಿಯಾಗಲಿಲ್ಲ. ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get journeyErrorResponseUnreadable =>
      'ಸರ್ವರ್‌ನ ಪ್ರತಿಕ್ರಿಯೆಯನ್ನು ಓದಲು ಆಗಲಿಲ್ಲ. ಮತ್ತೆ ಪ್ರಯತ್ನಿಸುವ ಮೊದಲು ರಿಫ್ರೆಶ್ ಮಾಡಿ.';

  @override
  String get journeyErrorSavedUnreadable =>
      'ಉಳಿಸಿದ ಪಯಣವನ್ನು ಓದಲು ಆಗಲಿಲ್ಲ. ಮತ್ತೆ ಪ್ರಯತ್ನಿಸುವ ಮೊದಲು ರಿಫ್ರೆಶ್ ಮಾಡಿ.';

  @override
  String get journeyErrorListUnreadable => 'ಪಯಣಗಳ ಪಟ್ಟಿಯನ್ನು ಓದಲು ಆಗಲಿಲ್ಲ.';

  @override
  String get journeyErrorMismatch =>
      'ಉಳಿಸಿದ ಪಯಣ ಹೊಂದಿಕೆಯಾಗಲಿಲ್ಲ. ಮತ್ತೆ ಪ್ರಯತ್ನಿಸುವ ಮೊದಲು ರಿಫ್ರೆಶ್ ಮಾಡಿ.';

  @override
  String get journeyErrorPreviewUnreadable => 'ಪಯಣದ ಮುನ್ನೋಟವನ್ನು ಓದಲು ಆಗಲಿಲ್ಲ.';

  @override
  String get journeyErrorRecordingsUnreadable =>
      'ರೆಕಾರ್ಡಿಂಗ್‌ಗಳ ಪಟ್ಟಿಯನ್ನು ಓದಲು ಆಗಲಿಲ್ಲ.';

  @override
  String get journeyErrorBankUnreadable =>
      'ಪ್ರಶ್ನೆ ಬ್ಯಾಂಕ್ ಅನ್ನು ಓದಲು ಆಗಲಿಲ್ಲ.';

  @override
  String get journeyErrorJourneyUnreadable => 'ಈ ಪಯಣವನ್ನು ಓದಲು ಆಗಲಿಲ್ಲ.';

  @override
  String get journeyDownloadNeedsApp =>
      'ಆಫ್‌ಲೈನ್ ಬಳಕೆಗಾಗಿ ಡೌನ್‌ಲೋಡ್ ಮಾಡಲು SEEDS Android ಆ್ಯಪ್ ಬೇಕು. ಬ್ರೌಸರ್‌ನಲ್ಲಿ, ನೀವು ಆನ್‌ಲೈನ್‌ನಲ್ಲಿರುವಾಗ ಪಯಣಗಳು ಪ್ಲೇ ಆಗುತ್ತವೆ.';

  @override
  String get journeySignInFirst =>
      'ಕಲಿಕೆಯ ಪಯಣಗಳನ್ನು ತೆರೆಯುವ ಮೊದಲು ಸೈನ್ ಇನ್ ಮಾಡಿ.';

  @override
  String get journeyStorageUnavailableDevice =>
      'ಈ ಸಾಧನದಲ್ಲಿ ಪಯಣ ಸಂಗ್ರಹಣೆ ಲಭ್ಯವಿಲ್ಲ.';

  @override
  String get journeyStorageFull =>
      'ಪಯಣ ಸಂಗ್ರಹಣೆ ಲಭ್ಯವಿಲ್ಲ. ಖಾಲಿ ಜಾಗವನ್ನು ಪರಿಶೀಲಿಸಿ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ. ಏನನ್ನೂ ಅಳಿಸಿಲ್ಲ.';

  @override
  String get journeyDownloadCancelled =>
      'ಡೌನ್‌ಲೋಡ್ ರದ್ದಾಗಿದೆ. ಈಗಾಗಲೇ ಉಳಿಸಿದ ರೆಕಾರ್ಡಿಂಗ್‌ಗಳನ್ನು ಇಟ್ಟುಕೊಳ್ಳಲಾಗಿದೆ.';

  @override
  String journeyRecordingsSaved(String done, String total) {
    return '$total ರಲ್ಲಿ $done ರೆಕಾರ್ಡಿಂಗ್‌ಗಳು ಉಳಿಸಲಾಗಿವೆ.';
  }

  @override
  String get journeyLeaveJourney => 'ಪಯಣದಿಂದ ಹೊರಬನ್ನಿ';

  @override
  String get journeyLeaveSaved => 'ಪಯಣದಿಂದ ಹೊರಬನ್ನಿ. ನಿಮ್ಮ ಸ್ಥಳ ಉಳಿಸಲಾಗಿದೆ';

  @override
  String get journeyKeyPlayAgain => 'ಮತ್ತೆ ಪ್ಲೇ ಮಾಡಿ';

  @override
  String get journeyKeySubmitAnswer => 'ಉತ್ತರ ಸಲ್ಲಿಸಿ';

  @override
  String get journeyKeyRepeatQuestion => 'ಪ್ರಶ್ನೆಯನ್ನು ಮತ್ತೆ ಕೇಳಿ';

  @override
  String get journeyKeySlowerSpeech => 'ನಿಧಾನವಾದ ಧ್ವನಿ';

  @override
  String get journeyKeyWhereAmI => 'ನಾನು ಎಲ್ಲಿದ್ದೇನೆ';

  @override
  String get journeyKeyFasterSpeech => 'ವೇಗವಾದ ಧ್ವನಿ';

  @override
  String get journeyKeyNextStep => 'ಮುಂದಿನ ಹಂತ';

  @override
  String get journeyKeyRepeatStep => 'ಈ ಹಂತವನ್ನು ಮತ್ತೆ ಕೇಳಿ';

  @override
  String get journeyKeyReadAgain => 'ಮತ್ತೆ ಓದಿ';

  @override
  String get journeyKeyPreviousContent => 'ಹಿಂದಿನ ರೆಕಾರ್ಡಿಂಗ್ ಅಥವಾ ನಿರೂಪಣೆ';

  @override
  String journeyPreviewTitle(String title) {
    return 'ಮುನ್ನೋಟ: $title';
  }

  @override
  String get journeyPositionFinished => 'ಮುಗಿದಿದೆ';

  @override
  String journeyStepPosition(String number, String total) {
    return '$total ರಲ್ಲಿ ಹಂತ $number';
  }

  @override
  String journeySelectedLabel(String label) {
    return '$label, ಆಯ್ಕೆ ಮಾಡಲಾಗಿದೆ';
  }

  @override
  String get journeyResultsLoading => 'ಫಲಿತಾಂಶಗಳು ಲೋಡ್ ಆಗುತ್ತಿವೆ.';

  @override
  String journeyResultsSummary(
    String completed,
    String eligible,
    String inProgress,
    String notStarted,
  ) {
    return '$eligible ರಲ್ಲಿ $completed ವಿದ್ಯಾರ್ಥಿಗಳು ಮುಗಿಸಿದ್ದಾರೆ. $inProgress ಪ್ರಗತಿಯಲ್ಲಿದೆ, $notStarted ಪ್ರಾರಂಭಿಸಿಲ್ಲ.';
  }

  @override
  String journeyResultsAverage(String percent) {
    return 'ಮೊದಲ ಪ್ರಯತ್ನದ ಸರಾಸರಿ ಅಂಕ $percent ಪ್ರತಿಶತ.';
  }

  @override
  String get journeyResultFinished => 'ಮುಗಿದಿದೆ';

  @override
  String get journeyResultNotStarted => 'ಪ್ರಾರಂಭಿಸಿಲ್ಲ';

  @override
  String journeyResultStudent(String name, String status) {
    return '$name. $status.';
  }

  @override
  String journeyResultFirstTime(String correct, String total) {
    return '$total ರಲ್ಲಿ $correct ಮೊದಲ ಬಾರಿಗೇ ಸರಿ.';
  }

  @override
  String journeyResultWrongAnswers(String count) {
    return '$count ತಪ್ಪು ಉತ್ತರಗಳು.';
  }

  @override
  String journeyResultQuestion(String number, String text, String answered) {
    return 'ಹಂತ $number. $text. $answered ಉತ್ತರಿಸಿದ್ದಾರೆ.';
  }

  @override
  String journeyResultRate(String percent) {
    return '$percent ಪ್ರತಿಶತ ಮೊದಲ ಬಾರಿಗೇ ಸರಿ.';
  }

  @override
  String get journeyResultNoAnswers => 'ಇನ್ನೂ ಯಾವುದೇ ಉತ್ತರಗಳಿಲ್ಲ.';

  @override
  String journeyResultAverageTries(String attempts) {
    return 'ಸರಾಸರಿ $attempts ಪ್ರಯತ್ನಗಳು.';
  }

  @override
  String journeyResultPoll(
    String number,
    String text,
    String answered,
    String options,
  ) {
    return 'ಹಂತ $number. $text. $answered ಉತ್ತರಿಸಿದ್ದಾರೆ. $options.';
  }

  @override
  String get journeyResultsStudentsTitle => 'ವಿದ್ಯಾರ್ಥಿಗಳು';

  @override
  String get journeyResultsQuestionsTitle => 'ಪ್ರಶ್ನೆಗಳು';

  @override
  String get journeyResultsPollsTitle => 'ಪೋಲ್ ಉತ್ತರಗಳು';

  @override
  String journeyResultsTitle(String title) {
    return 'ಫಲಿತಾಂಶಗಳು: $title';
  }

  @override
  String get journeyResultsHearSummary => 'ತರಗತಿಯ ಸಾರಾಂಶ ಕೇಳಿ';

  @override
  String journeyResultsStudents(String count) {
    return 'ವಿದ್ಯಾರ್ಥಿಗಳು, $count';
  }

  @override
  String journeyResultsQuestions(String count) {
    return 'ಪ್ರಶ್ನೆಗಳು, $count. ಯಾವ ಭಾಗಗಳನ್ನು ಮತ್ತೆ ಕಲಿಸಬೇಕು ಎಂದು ತೋರಿಸುತ್ತದೆ';
  }

  @override
  String journeyResultsPolls(String count) {
    return 'ಪೋಲ್ ಉತ್ತರಗಳು, $count';
  }

  @override
  String get journeyResultsRefresh => 'ಫಲಿತಾಂಶಗಳನ್ನು ರಿಫ್ರೆಶ್ ಮಾಡಿ';

  @override
  String get journeyResultsNoStudents =>
      'ಈ ತರಗತಿಯಲ್ಲಿ ಯಾವುದೇ ವಿದ್ಯಾರ್ಥಿಗಳಿಲ್ಲ.';

  @override
  String get journeyResultsNoQuestions => 'ಈ ಪಯಣದಲ್ಲಿ ಯಾವುದೇ ಪ್ರಶ್ನೆಗಳಿಲ್ಲ.';

  @override
  String get journeyResultsNoPolls => 'ಈ ಪಯಣದಲ್ಲಿ ಯಾವುದೇ ಪೋಲ್‌ಗಳಿಲ್ಲ.';

  @override
  String get journeyNarrationLabel =>
      'ಫೋನ್ ಗಟ್ಟಿಯಾಗಿ ಓದುವ ಪದಗಳು, ಉದಾಹರಣೆಗೆ: ಇಂದು ಕೆಲವು ಆಹಾರಗಳ ಬಗ್ಗೆ ಕೇಳೋಣ';

  @override
  String journeyAddOptionTitle(String number) {
    return 'ಆಯ್ಕೆ $number ಸೇರಿಸಬೇಕೇ?';
  }

  @override
  String journeyQuestionOptionsSoFar(String count) {
    return 'ಈ ಪ್ರಶ್ನೆಯಲ್ಲಿ ಇಲ್ಲಿಯವರೆಗೆ $count ಆಯ್ಕೆಗಳಿವೆ.';
  }

  @override
  String journeyPollOptionsSoFar(String count) {
    return 'ಈ ಪೋಲ್‌ನಲ್ಲಿ ಇಲ್ಲಿಯವರೆಗೆ $count ಆಯ್ಕೆಗಳಿವೆ.';
  }

  @override
  String journeyAddOption(String number) {
    return 'ಆಯ್ಕೆ $number ಸೇರಿಸಿ';
  }

  @override
  String get journeyNoMoreOptions => 'ಇನ್ನು ಆಯ್ಕೆಗಳಿಲ್ಲ, ಮುಂದುವರಿಸಿ';

  @override
  String journeyOptionTitle(String number) {
    return 'ಆಯ್ಕೆ $number';
  }

  @override
  String journeyTypeOption(String number) {
    return 'ಆಯ್ಕೆ $number ಟೈಪ್ ಮಾಡಿ';
  }

  @override
  String get journeyReplayAutoNone => 'ಸ್ವಯಂಚಾಲಿತ: ಮತ್ತೆ ಪ್ಲೇ ಮಾಡದೆ ಮತ್ತೆ ಕೇಳಿ';

  @override
  String journeyReplayAutoFrom(String number, String name) {
    return 'ಸ್ವಯಂಚಾಲಿತ: ಹಂತ $number, $name ನಿಂದ ಮತ್ತೆ ಪ್ಲೇ ಮಾಡಿ';
  }

  @override
  String get journeyAfterWrongTitle => 'ತಪ್ಪು ಉತ್ತರದ ನಂತರ';

  @override
  String get journeyAfterWrongIntro =>
      'ವಿದ್ಯಾರ್ಥಿ ತಪ್ಪು ಉತ್ತರ ನೀಡಿದಾಗ, ಮತ್ತೊಮ್ಮೆ ಪ್ರಯತ್ನಿಸುವ ಮೊದಲು ಯಾವ ಭಾಗ ಮತ್ತೆ ಪ್ಲೇ ಆಗಬೇಕು?';

  @override
  String get journeyReplayChooseStep => 'ಮತ್ತೆ ಪ್ಲೇ ಮಾಡಲು ಬೇರೆ ಹಂತವನ್ನು ಆರಿಸಿ';

  @override
  String get journeyReplayWhichStep => 'ಯಾವ ಹಂತದಿಂದ ಮತ್ತೆ ಪ್ಲೇ ಮಾಡಬೇಕು?';

  @override
  String journeyStepLabel(String number, String name) {
    return 'ಹಂತ $number. $name';
  }

  @override
  String journeyReviewReplayFrom(String number) {
    return 'ತಪ್ಪು ಉತ್ತರದ ನಂತರ, ಹಂತ $number ಮತ್ತೆ ಪ್ಲೇ ಆಗುತ್ತದೆ.';
  }

  @override
  String get journeyReviewReplayAuto =>
      'ತಪ್ಪು ಉತ್ತರದ ನಂತರ, ಅದು ಸ್ವಯಂಚಾಲಿತವಾಗಿ ಮತ್ತೆ ಪ್ಲೇ ಆಗುತ್ತದೆ.';

  @override
  String get journeyCheckBeforeSaving => 'ಉಳಿಸುವ ಮೊದಲು ಪರಿಶೀಲಿಸಿ';

  @override
  String get journeySaveStep => 'ಈ ಹಂತವನ್ನು ಉಳಿಸಿ';

  @override
  String get journeyRestartStep => 'ಈ ಹಂತವನ್ನು ಮತ್ತೆ ಪ್ರಾರಂಭಿಸಿ';

  @override
  String get journeyQuestionLabel =>
      'ವಿದ್ಯಾರ್ಥಿಗಳು ಕೇಳುವ ಪ್ರಶ್ನೆಯನ್ನು ಟೈಪ್ ಮಾಡಿ';

  @override
  String get journeyWhichCorrect => 'ಯಾವ ಆಯ್ಕೆ ಸರಿ?';

  @override
  String journeyCurrentlyCorrect(String number) {
    return 'ಈಗ ಆಯ್ಕೆ $number ಸರಿಯಾಗಿದೆ.';
  }

  @override
  String journeyOptionChoice(String number, String text) {
    return 'ಆಯ್ಕೆ $number: $text';
  }

  @override
  String get journeyExplanationTitle => 'ವಿವರಣೆ';

  @override
  String get journeyExplanationLabel =>
      'ಸರಿಯಾದ ಉತ್ತರ ತಿಳಿಸಿದ ನಂತರ ವಿದ್ಯಾರ್ಥಿಗಳು ಕೇಳುವುದು';

  @override
  String get journeyPollQuestionTitle => 'ಪೋಲ್ ಪ್ರಶ್ನೆ';

  @override
  String get journeyPollQuestionLabel =>
      'ತಪ್ಪು ಉತ್ತರವಿಲ್ಲದ ಪ್ರಶ್ನೆ, ಉದಾಹರಣೆಗೆ: ಈ ವಾರ ನೀವು ಅನ್ನ ತಿಂದಿದ್ದೀರಾ?';

  @override
  String get journeyQuestionBank => 'ಪ್ರಶ್ನೆ ಬ್ಯಾಂಕ್';

  @override
  String journeyBankQuestionLabel(String text, String count) {
    return '$text. $count ಆಯ್ಕೆಗಳು.';
  }

  @override
  String get journeyAddRecording => 'ರೆಕಾರ್ಡಿಂಗ್ ಸೇರಿಸಿ';

  @override
  String get journeyChooseMyRecordings => 'ನನ್ನ ರೆಕಾರ್ಡಿಂಗ್‌ಗಳಿಂದ ಆರಿಸಿ';

  @override
  String get journeyUploadRecordingFile => 'ರೆಕಾರ್ಡಿಂಗ್ ಫೈಲ್ ಅಪ್‌ಲೋಡ್ ಮಾಡಿ';

  @override
  String get journeyRecordNew => 'ಹೊಸ ರೆಕಾರ್ಡಿಂಗ್ ಮಾಡಿ';

  @override
  String get journeyMyRecordings => 'ನನ್ನ ರೆಕಾರ್ಡಿಂಗ್‌ಗಳು';

  @override
  String get journeyRecordingName => 'ರೆಕಾರ್ಡಿಂಗ್ ಹೆಸರು';

  @override
  String get journeyRecordingNameLabel => 'ಈ ರೆಕಾರ್ಡಿಂಗ್‌ಗೆ ಹೆಸರು';

  @override
  String journeyOptionalLabel(String label) {
    return '$label. ಐಚ್ಛಿಕ, ಬಿಟ್ಟುಬಿಡಲು ಖಾಲಿ ಬಿಡಿ';
  }

  @override
  String get journeyNothingEntered =>
      'ಏನೂ ನಮೂದಿಸಿಲ್ಲ. ಫೀಲ್ಡ್‌ನಲ್ಲಿ ಓಕೆ ಒತ್ತಿ ಟೈಪ್ ಮಾಡಿ, ಅಥವಾ ಹಿಂದೆ ಹೋಗಲು 0 ಒತ್ತಿ.';

  @override
  String journeyTooLong(String max) {
    return 'ತುಂಬಾ ಉದ್ದವಾಗಿದೆ. ಗರಿಷ್ಠ $max ಅಕ್ಷರಗಳನ್ನು ಬಳಸಿ.';
  }

  @override
  String get journeySkipped => 'ಬಿಟ್ಟುಬಿಡಲಾಗಿದೆ.';

  @override
  String journeyYouEntered(String text) {
    return 'ನೀವು ನಮೂದಿಸಿದ್ದು: $text';
  }

  @override
  String get journeyMenuReady => 'ಸಿದ್ಧವಾಗಿದೆ.';

  @override
  String get journeyMenuReadDetailsHelp => 'ವಿವರಗಳನ್ನು ಮತ್ತೆ ಓದಲು 8 ಒತ್ತಿ.';

  @override
  String journeyMenuBackHelp(String back) {
    return '$back ಗಾಗಿ 0 ಒತ್ತಿ. ಸಹಾಯಕ್ಕಾಗಿ ಸ್ಟಾರ್ ಒತ್ತಿ.';
  }

  @override
  String journeyMenuNothingAssigned(String number) {
    return '$number ಗೆ ಏನನ್ನೂ ನಿಗದಿಪಡಿಸಿಲ್ಲ.';
  }

  @override
  String get journeyMenuPleaseWait =>
      'ದಯವಿಟ್ಟು ಕಾಯಿರಿ. ಇನ್ನೂ ಕೆಲಸ ನಡೆಯುತ್ತಿದೆ. ಹಿಂದೆ ಹೋಗಲು 0 ಒತ್ತಿ.';

  @override
  String get journeyMenuWorking => 'ಕೆಲಸ ನಡೆಯುತ್ತಿದೆ, ದಯವಿಟ್ಟು ಕಾಯಿರಿ.';

  @override
  String get journeyMenuReadDetails => 'ವಿವರಗಳನ್ನು ಮತ್ತೆ ಓದಿ';

  @override
  String get journeyNoInternetDownloaded =>
      'ಇಂಟರ್ನೆಟ್ ಇಲ್ಲ. ಡೌನ್‌ಲೋಡ್ ಮಾಡಿದ ಪಯಣಗಳು ಇನ್ನೂ ಕೆಲಸ ಮಾಡುತ್ತವೆ. ಡೌನ್‌ಲೋಡ್ ಮಾಡಿದ ಪಯಣಗಳಿಗಾಗಿ 5 ಒತ್ತಿ.';

  @override
  String journeyWaitingToSend(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ಮುಗಿದ $count ಪಯಣಗಳನ್ನು ಕಳುಹಿಸಲು ಕಾಯಲಾಗುತ್ತಿದೆ.',
      one: 'ಮುಗಿದ 1 ಪಯಣವನ್ನು ಕಳುಹಿಸಲು ಕಾಯಲಾಗುತ್ತಿದೆ.',
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
    return '$newCount ಹೊಸದು, $inProgress ಪ್ರಗತಿಯಲ್ಲಿದೆ, $completed ಪೂರ್ಣಗೊಂಡಿದೆ, $downloaded ಡೌನ್‌ಲೋಡ್ ಮಾಡಲಾಗಿದೆ.';
  }

  @override
  String get journeyDownloadedJourneys => 'ಡೌನ್‌ಲೋಡ್ ಮಾಡಿದ ಪಯಣಗಳು';

  @override
  String journeyDownloadedRow(String title, String steps) {
    return '$title. $steps ಹಂತಗಳು. ಡೌನ್‌ಲೋಡ್ ಮಾಡಲಾಗಿದೆ.';
  }

  @override
  String get journeyOfflineReason =>
      'ಇದಕ್ಕೆ ಇಂಟರ್ನೆಟ್ ಬೇಕು. ಡೌನ್‌ಲೋಡ್ ಮಾಡಿದ ಪಯಣಗಳಿಗಾಗಿ 5 ಒತ್ತಿ.';

  @override
  String get journeyLearningJourneys => 'ಕಲಿಕೆಯ ಪಯಣಗಳು';

  @override
  String get journeyStudentIntro =>
      'ಕಥೆಗಳು ಮತ್ತು ಪಾಠಗಳನ್ನು ಕೇಳಿ, ನಡುವೆ ಪ್ರಶ್ನೆಗಳಿಗೆ ಉತ್ತರಿಸಿ, ಬೇಕಾದ ಭಾಗಗಳನ್ನು ಮತ್ತೆ ಕೇಳಿ.';

  @override
  String get journeyContinueLast => 'ನನ್ನ ಕೊನೆಯ ಪಯಣವನ್ನು ಮುಂದುವರಿಸಿ';

  @override
  String journeyNewJourneys(String count) {
    return 'ಹೊಸ ಪಯಣಗಳು, $count';
  }

  @override
  String get journeyNewJourneysTitle => 'ಹೊಸ ಪಯಣಗಳು';

  @override
  String get journeyNoNewJourneys => 'ಯಾವುದೇ ಹೊಸ ಪಯಣಗಳಿಲ್ಲ.';

  @override
  String journeyInProgressCount(String count) {
    return 'ಪ್ರಗತಿಯಲ್ಲಿದೆ, $count';
  }

  @override
  String get journeyInProgressTitle => 'ಪ್ರಗತಿಯಲ್ಲಿರುವ ಪಯಣಗಳು';

  @override
  String get journeyNothingInProgressShort => 'ಯಾವುದೂ ಪ್ರಗತಿಯಲ್ಲಿಲ್ಲ.';

  @override
  String journeyCompletedCount(String count) {
    return 'ಪೂರ್ಣಗೊಂಡಿದೆ, $count';
  }

  @override
  String get journeyCompletedTitle => 'ಪೂರ್ಣಗೊಂಡ ಪಯಣಗಳು';

  @override
  String get journeyNoneCompleted => 'ಇನ್ನೂ ಯಾವುದೇ ಪಯಣ ಪೂರ್ಣಗೊಂಡಿಲ್ಲ.';

  @override
  String journeyDownloadedCount(String count) {
    return 'ಡೌನ್‌ಲೋಡ್ ಮಾಡಲಾಗಿದೆ, $count';
  }

  @override
  String get journeyNothingDownloaded =>
      'ಏನನ್ನೂ ಡೌನ್‌ಲೋಡ್ ಮಾಡಿಲ್ಲ. ಒಂದು ಪಯಣವನ್ನು ತೆರೆದು ಡೌನ್‌ಲೋಡ್ ಆರಿಸಿ.';

  @override
  String get journeyNoInternetNotDownloaded =>
      'ಇಂಟರ್ನೆಟ್ ಇಲ್ಲ, ಮತ್ತು ಈ ಪಯಣವನ್ನು ಡೌನ್‌ಲೋಡ್ ಮಾಡಿಲ್ಲ.';

  @override
  String get journeyStartOverTitle => 'ಮೊದಲಿನಿಂದ ಪ್ರಾರಂಭಿಸಬೇಕೇ?';

  @override
  String get journeyStartOver => 'ಮೊದಲಿನಿಂದ ಪ್ರಾರಂಭಿಸಿ';

  @override
  String get journeyRemoveDownloadTitle => 'ಡೌನ್‌ಲೋಡ್ ತೆಗೆದುಹಾಕಬೇಕೇ?';

  @override
  String get journeyRemoveDownload => 'ಡೌನ್‌ಲೋಡ್ ತೆಗೆದುಹಾಕಿ';

  @override
  String journeySavedRecordings(String done, String total) {
    return '$total ರಲ್ಲಿ $done ರೆಕಾರ್ಡಿಂಗ್‌ಗಳನ್ನು ಉಳಿಸಲಾಗಿದೆ.';
  }

  @override
  String get journeyDownloadedOnPhone => 'ಈ ಫೋನ್‌ನಲ್ಲಿ ಡೌನ್‌ಲೋಡ್ ಮಾಡಲಾಗಿದೆ.';

  @override
  String get journeyNotDownloadedShort => 'ಡೌನ್‌ಲೋಡ್ ಮಾಡಿಲ್ಲ.';

  @override
  String get journeyStartedThis => 'ನೀವು ಈ ಪಯಣವನ್ನು ಪ್ರಾರಂಭಿಸಿದ್ದೀರಿ.';

  @override
  String get journeyWorksOffline =>
      'ಡೌನ್‌ಲೋಡ್ ಮಾಡಲಾಗಿದೆ. ಇಂಟರ್ನೆಟ್ ಇಲ್ಲದೆ ಕೆಲಸ ಮಾಡುತ್ತದೆ.';

  @override
  String get journeyContinueJourney => 'ಪಯಣವನ್ನು ಮುಂದುವರಿಸಿ';

  @override
  String get journeyStartJourney => 'ಪಯಣ ಪ್ರಾರಂಭಿಸಿ';

  @override
  String get journeyHearAbout => 'ಈ ಪಯಣದ ಬಗ್ಗೆ ಕೇಳಿ';

  @override
  String get journeyDownloadOffline =>
      'ಇಂಟರ್ನೆಟ್ ಇಲ್ಲದೆ ಪ್ಲೇ ಮಾಡಲು ಡೌನ್‌ಲೋಡ್ ಮಾಡಿ';

  @override
  String get journeyDownloadInProgress =>
      'ಡೌನ್‌ಲೋಡ್ ನಡೆಯುತ್ತಿದೆ. ಅದನ್ನು ರದ್ದುಗೊಳಿಸಲು 0 ಒತ್ತಿ.';

  @override
  String get journeyStartFromBeginning => 'ಮೊದಲಿನಿಂದಲೇ ಮತ್ತೆ ಪ್ರಾರಂಭಿಸಿ';

  @override
  String get journeyNotStartedYet => 'ನೀವು ಇನ್ನೂ ಈ ಪಯಣವನ್ನು ಪ್ರಾರಂಭಿಸಿಲ್ಲ.';

  @override
  String journeyLatestLoaded(String message) {
    return '$message ಇತ್ತೀಚಿನ ಆವೃತ್ತಿಯನ್ನು ಈಗ ಲೋಡ್ ಮಾಡಲಾಗಿದೆ.';
  }

  @override
  String journeyTeacherSummary(
    String drafts,
    String published,
    String archived,
  ) {
    return '$drafts ಕರಡುಗಳು, $published ಪ್ರಕಟಿತ, $archived ಆರ್ಕೈವ್ ಮಾಡಲಾಗಿದೆ.';
  }

  @override
  String get journeyNewJourneyTitle => 'ಹೊಸ ಕಲಿಕೆಯ ಪಯಣ';

  @override
  String get journeyNameExample => 'ಪಯಣದ ಹೆಸರು, ಉದಾಹರಣೆಗೆ: ನಮ್ಮ ಸುತ್ತಲಿನ ಆಹಾರ';

  @override
  String get journeyRefreshFirst => 'ಮೊದಲು ಪಟ್ಟಿಯನ್ನು ರಿಫ್ರೆಶ್ ಮಾಡಲು 5 ಒತ್ತಿ.';

  @override
  String journeyTeacherIntro(String workspace) {
    return '$workspace. ವಿದ್ಯಾರ್ಥಿಗಳಿಗಾಗಿ ರೆಕಾರ್ಡಿಂಗ್‌ಗಳು, ನಿರೂಪಣೆ, ಪ್ರಶ್ನೆಗಳು ಮತ್ತು ಪೋಲ್‌ಗಳ ಒಂದು ಹರಿವನ್ನು ರಚಿಸಿ.';
  }

  @override
  String get journeyCreateNew => 'ಹೊಸ ಪಯಣವನ್ನು ರಚಿಸಿ';

  @override
  String journeyDraftsCount(String count) {
    return 'ಕರಡುಗಳು, $count';
  }

  @override
  String get journeyDraftJourneys => 'ಕರಡು ಪಯಣಗಳು';

  @override
  String get journeyNoDrafts => 'ಯಾವುದೇ ಕರಡುಗಳಿಲ್ಲ.';

  @override
  String journeyPublishedCount(String count) {
    return 'ಪ್ರಕಟಿತ, $count';
  }

  @override
  String get journeyPublishedJourneys => 'ಪ್ರಕಟಿತ ಪಯಣಗಳು';

  @override
  String get journeyNothingPublished => 'ಇನ್ನೂ ಏನನ್ನೂ ಪ್ರಕಟಿಸಿಲ್ಲ.';

  @override
  String journeyArchivedCount(String count) {
    return 'ಆರ್ಕೈವ್ ಮಾಡಲಾಗಿದೆ, $count';
  }

  @override
  String get journeyArchivedJourneys => 'ಆರ್ಕೈವ್ ಮಾಡಿದ ಪಯಣಗಳು';

  @override
  String get journeyNothingArchived => 'ಏನನ್ನೂ ಆರ್ಕೈವ್ ಮಾಡಿಲ್ಲ.';

  @override
  String get journeyRefreshList => 'ಪಟ್ಟಿಯನ್ನು ರಿಫ್ರೆಶ್ ಮಾಡಿ';

  @override
  String journeyOverviewSummary(
    String status,
    String steps,
    String questions,
    String graded,
    String retries,
  ) {
    return '$status. $steps ಹಂತಗಳು, $questions ಪ್ರಶ್ನೆಗಳು. $graded. $retries';
  }

  @override
  String get journeyGraded => 'ಅಂಕಸಹಿತ';

  @override
  String get journeyNotGraded => 'ಅಂಕರಹಿತ';

  @override
  String journeyRetriesPerQuestion(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ಪ್ರತಿ ಪ್ರಶ್ನೆಗೆ $count ಮರುಪ್ರಯತ್ನಗಳು.',
      one: 'ಪ್ರತಿ ಪ್ರಶ್ನೆಗೆ 1 ಮರುಪ್ರಯತ್ನ.',
    );
    return '$_temp0';
  }

  @override
  String get journeySteps => 'ಹಂತಗಳು';

  @override
  String journeyAddStepTitle(String number) {
    return 'ಹಂತ $number ಸೇರಿಸಿ';
  }

  @override
  String get journeyAddStepIntro =>
      'ಹೊಸ ಹಂತ ಕೊನೆಯಲ್ಲಿ ಸೇರುತ್ತದೆ. ನೀವು ಅದನ್ನು ನಂತರ ಸರಿಸಬಹುದು.';

  @override
  String get journeyChoiceRecording => 'ರೆಕಾರ್ಡಿಂಗ್';

  @override
  String get journeyChoiceNarration => 'ಫೋನ್ ಓದುವ ನಿರೂಪಣೆ';

  @override
  String get journeyChoiceQuestion => 'ಪ್ರಶ್ನೆ';

  @override
  String get journeyChoicePoll => 'ಪೋಲ್, ತಪ್ಪು ಉತ್ತರವಿಲ್ಲ';

  @override
  String journeySavedAsStep(String number, String name) {
    return 'ಹಂತ $number ಆಗಿ ಉಳಿಸಲಾಗಿದೆ. $name';
  }

  @override
  String get journeyAddQuestion => 'ಪ್ರಶ್ನೆ ಸೇರಿಸಿ';

  @override
  String get journeyWriteNewQuestion => 'ಹೊಸ ಪ್ರಶ್ನೆ ಬರೆಯಿರಿ';

  @override
  String get journeyChooseFromBank => 'ನನ್ನ ಪ್ರಶ್ನೆ ಬ್ಯಾಂಕ್‌ನಿಂದ ಆರಿಸಿ';

  @override
  String get journeyHearAndEdit => 'ಹಂತಗಳನ್ನು ಕೇಳಿ ಮತ್ತು ಸಂಪಾದಿಸಿ';

  @override
  String get journeyNoStepsYet =>
      'ಇನ್ನೂ ಯಾವುದೇ ಹಂತಗಳಿಲ್ಲ. ಒಂದನ್ನು ಸೇರಿಸಲು 2 ಒತ್ತಿ.';

  @override
  String get journeyAddStep => 'ಹಂತ ಸೇರಿಸಿ';

  @override
  String get journeyPreviewAsStudent => 'ವಿದ್ಯಾರ್ಥಿಯಾಗಿ ಮುನ್ನೋಟ ನೋಡಿ';

  @override
  String get journeyAddStepFirst => 'ಮೊದಲು ಒಂದು ಹಂತ ಸೇರಿಸಿ.';

  @override
  String get journeyPublishToStudents => 'ವಿದ್ಯಾರ್ಥಿಗಳಿಗೆ ಪ್ರಕಟಿಸಿ';

  @override
  String get journeyPublishChanges => 'ಬದಲಾವಣೆಗಳನ್ನು ಪ್ರಕಟಿಸಿ';

  @override
  String get journeyStudentResults => 'ವಿದ್ಯಾರ್ಥಿಗಳ ಫಲಿತಾಂಶಗಳು';

  @override
  String get journeyMoreOptions => 'ಇನ್ನಷ್ಟು ಆಯ್ಕೆಗಳು';

  @override
  String journeyStepSaved(String number) {
    return 'ಹಂತ $number ಉಳಿಸಲಾಗಿದೆ.';
  }

  @override
  String journeyMoved(String number, String total) {
    return 'ಸರಿಸಲಾಗಿದೆ. ಇದು ಈಗ $total ರಲ್ಲಿ ಹಂತ $number.';
  }

  @override
  String journeyRemoveStepTitle(String number) {
    return 'ಹಂತ $number ತೆಗೆದುಹಾಕಬೇಕೇ?';
  }

  @override
  String journeyRemoveStepMessage(String name) {
    return '$name ತೆಗೆದುಹಾಕಬೇಕೇ? ರೆಕಾರ್ಡಿಂಗ್‌ಗಳು ನಿಮ್ಮ ಲೈಬ್ರರಿಯಲ್ಲಿ ಉಳಿಯುತ್ತವೆ. ಈ ಹಂತವನ್ನು ಮತ್ತೆ ಪ್ಲೇ ಮಾಡುತ್ತಿದ್ದ ಪ್ರಶ್ನೆಗಳು ಬದಲಾಗಿ ಸ್ವಯಂಚಾಲಿತವಾಗಿ ಮತ್ತೆ ಪ್ಲೇ ಮಾಡುತ್ತವೆ.';
  }

  @override
  String get journeyRemoveStep => 'ಹಂತ ತೆಗೆದುಹಾಕಿ';

  @override
  String get journeyStepNotFound => 'ಹಂತ ಸಿಗಲಿಲ್ಲ';

  @override
  String get journeyStepWasRemoved =>
      'ಈ ಹಂತವನ್ನು ತೆಗೆದುಹಾಕಲಾಗಿದೆ. ಹಿಂದೆ ಹೋಗಲು 0 ಒತ್ತಿ.';

  @override
  String get journeyHearStepInFull => 'ಈ ಹಂತವನ್ನು ಪೂರ್ತಿಯಾಗಿ ಕೇಳಿ';

  @override
  String get journeyEditStep => 'ಈ ಹಂತವನ್ನು ಸಂಪಾದಿಸಿ';

  @override
  String get journeyMoveEarlier => 'ಮುಂಚೆಗೆ ಸರಿಸಿ';

  @override
  String get journeyAlreadyFirst => 'ಇದು ಈಗಾಗಲೇ ಮೊದಲ ಹಂತ.';

  @override
  String get journeyMoveLater => 'ನಂತರಕ್ಕೆ ಸರಿಸಿ';

  @override
  String get journeyAlreadyLast => 'ಇದು ಈಗಾಗಲೇ ಕೊನೆಯ ಹಂತ.';

  @override
  String get journeyRemoveThisStep => 'ಈ ಹಂತವನ್ನು ತೆಗೆದುಹಾಕಿ';

  @override
  String get journeyRenameTitle => 'ಪಯಣದ ಹೆಸರು ಬದಲಿಸಿ';

  @override
  String get journeyNameLabel => 'ಪಯಣದ ಹೆಸರು';

  @override
  String journeyRenamed(String title) {
    return 'ಹೆಸರನ್ನು $title ಎಂದು ಬದಲಿಸಲಾಗಿದೆ.';
  }

  @override
  String get journeyArchiveTitle => 'ಈ ಪಯಣವನ್ನು ಆರ್ಕೈವ್ ಮಾಡಬೇಕೇ?';

  @override
  String get journeyRestoreTitle => 'ಈ ಪಯಣವನ್ನು ಮರುಸ್ಥಾಪಿಸಬೇಕೇ?';

  @override
  String get journeyArchive => 'ಆರ್ಕೈವ್ ಮಾಡಿ';

  @override
  String get journeyRestore => 'ಮರುಸ್ಥಾಪಿಸಿ';

  @override
  String get journeyDeleteDraftTitle => 'ಈ ಕರಡನ್ನು ಅಳಿಸಬೇಕೇ?';

  @override
  String get journeyDeleteDraft => 'ಕರಡು ಅಳಿಸಿ';

  @override
  String get journeyPublishFirst => 'ಮೊದಲು ಪಯಣವನ್ನು ಪ್ರಕಟಿಸಿ.';

  @override
  String get journeyRename => 'ಹೆಸರು ಬದಲಿಸಿ';

  @override
  String get journeyGradingNowGraded =>
      'ಅಂಕ ನೀಡಿಕೆ ಮತ್ತು ಪ್ರಯತ್ನಗಳು, ಈಗ ಅಂಕಸಹಿತ';

  @override
  String get journeyGradingNowNotGraded =>
      'ಅಂಕ ನೀಡಿಕೆ ಮತ್ತು ಪ್ರಯತ್ನಗಳು, ಈಗ ಅಂಕರಹಿತ';

  @override
  String get journeyDuplicate => 'ಹೊಸ ಕರಡಾಗಿ ನಕಲು ಮಾಡಿ';

  @override
  String get journeyArchiveHide => 'ಆರ್ಕೈವ್ ಮಾಡಿ, ವಿದ್ಯಾರ್ಥಿಗಳಿಂದ ಮರೆಮಾಡಿ';

  @override
  String get journeyRestoreForStudents => 'ವಿದ್ಯಾರ್ಥಿಗಳಿಗಾಗಿ ಮರುಸ್ಥಾಪಿಸಿ';

  @override
  String get journeyDeleteThisDraft => 'ಈ ಕರಡನ್ನು ಅಳಿಸಿ';

  @override
  String get journeyGradedSummary =>
      'ಅಂಕಸಹಿತ: ಪ್ರತಿ ಪ್ರಶ್ನೆಯ ಮೊದಲ ಪ್ರಯತ್ನವನ್ನು ಅಂಕಕ್ಕೆ ಎಣಿಸಲಾಗುತ್ತದೆ.';

  @override
  String get journeyNotGradedSummary => 'ಅಂಕರಹಿತ: ಪ್ರಶ್ನೆಗಳು ಅಭ್ಯಾಸಕ್ಕೆ ಮಾತ್ರ.';

  @override
  String journeyMoreTriesSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'ತಪ್ಪು ಉತ್ತರದ ನಂತರ, ವಿದ್ಯಾರ್ಥಿಗೆ ಇನ್ನೂ $count ಪ್ರಯತ್ನಗಳು ಸಿಗುತ್ತವೆ, ಮೊದಲು ವಿಷಯವನ್ನು ಮತ್ತೆ ಪ್ಲೇ ಮಾಡಲಾಗುತ್ತದೆ.',
      one:
          'ತಪ್ಪು ಉತ್ತರದ ನಂತರ, ವಿದ್ಯಾರ್ಥಿಗೆ ಇನ್ನೂ 1 ಪ್ರಯತ್ನ ಸಿಗುತ್ತದೆ, ಮೊದಲು ವಿಷಯವನ್ನು ಮತ್ತೆ ಪ್ಲೇ ಮಾಡಲಾಗುತ್ತದೆ.',
    );
    return '$_temp0';
  }

  @override
  String get journeyGradingTitle => 'ಅಂಕ ನೀಡಿಕೆ ಮತ್ತು ಪ್ರಯತ್ನಗಳು';

  @override
  String get journeyTurnGradingOff => 'ಅಂಕ ನೀಡಿಕೆ ಆಫ್ ಮಾಡಿ';

  @override
  String get journeyTurnGradingOn => 'ಅಂಕ ನೀಡಿಕೆ ಆನ್ ಮಾಡಿ';

  @override
  String get journeyGradingIsOff => 'ಅಂಕ ನೀಡಿಕೆ ಆಫ್ ಆಗಿದೆ.';

  @override
  String get journeyGradingIsOn => 'ಅಂಕ ನೀಡಿಕೆ ಆನ್ ಆಗಿದೆ.';

  @override
  String get journeyFewerTries => 'ಕಡಿಮೆ ಪ್ರಯತ್ನಗಳು';

  @override
  String get journeyMoreTries => 'ಹೆಚ್ಚು ಪ್ರಯತ್ನಗಳು';

  @override
  String get journeyLoadingSummary => 'ಸಾರಾಂಶ ಲೋಡ್ ಆಗುತ್ತಿದೆ.';

  @override
  String get journeyNoProblems => 'ಯಾವುದೇ ಸಮಸ್ಯೆಗಳಿಲ್ಲ.';

  @override
  String journeyProblems(String issues) {
    return 'ಪ್ರಕಟಿಸುವ ಮೊದಲು ಸರಿಪಡಿಸಬೇಕಾದ ಸಮಸ್ಯೆಗಳು: $issues';
  }

  @override
  String journeyThingsToCheck(String warnings) {
    return 'ಪರಿಶೀಲಿಸಬೇಕಾದ ವಿಷಯಗಳು: $warnings';
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
    return '$title. $steps ಹಂತಗಳು: $recordings ರೆಕಾರ್ಡಿಂಗ್‌ಗಳು, $narrations ನಿರೂಪಣೆಗಳು, $questions ಪ್ರಶ್ನೆಗಳು, $polls ಪೋಲ್‌ಗಳು. $graded.';
  }

  @override
  String journeyPublishTitle(String title) {
    return '$title ಪ್ರಕಟಿಸಬೇಕೇ?';
  }

  @override
  String get journeyPublishMessage =>
      'ಈ ತರಗತಿಯ ಎಲ್ಲಾ ವಿದ್ಯಾರ್ಥಿಗಳು ಇದನ್ನು ಪ್ಲೇ ಮತ್ತು ಡೌನ್‌ಲೋಡ್ ಮಾಡಬಹುದು, ಮತ್ತು ಅವರಿಗೆ ಅಧಿಸೂಚನೆ ಬರುತ್ತದೆ.';

  @override
  String get journeyPublishNow => 'ಈಗ ಪ್ರಕಟಿಸಿ';

  @override
  String get journeyPublishedShort => 'ಪ್ರಕಟಿಸಲಾಗಿದೆ.';

  @override
  String get journeyReviewBeforePublishing => 'ಪ್ರಕಟಿಸುವ ಮೊದಲು ಪರಿಶೀಲಿಸಿ';

  @override
  String get journeyFixProblemsFirst =>
      'ಮೊದಲು ಸಮಸ್ಯೆಗಳನ್ನು ಸರಿಪಡಿಸಿ. ಅವುಗಳನ್ನು ಕೇಳಲು 8 ಒತ್ತಿ.';

  @override
  String get journeyPreviewFirst => 'ಮೊದಲು ವಿದ್ಯಾರ್ಥಿಯಾಗಿ ಮುನ್ನೋಟ ನೋಡಿ';

  @override
  String undoOffer(String seconds) {
    return 'ರದ್ದುಗೊಳಿಸಲು $seconds ಸೆಕೆಂಡುಗಳ ಒಳಗೆ 1 ಒತ್ತಿ.';
  }

  @override
  String undoDone(String action) {
    return 'ರದ್ದುಗೊಳಿಸಲಾಗಿದೆ. $action ಅನ್ನು ಹಿಂಪಡೆಯಲಾಗಿದೆ.';
  }

  @override
  String get undoFailed =>
      'ರದ್ದುಗೊಳಿಸುವುದು ಕೆಲಸ ಮಾಡಲಿಲ್ಲ. ಐಟಂ ಪರಿಶೀಲಿಸಿ, ಬೇಕಿದ್ದರೆ ಮತ್ತೆ ಸೇರಿಸಿ.';

  @override
  String get uiBack => 'ಹಿಂದೆ';

  @override
  String get uiCancel => 'ರದ್ದುಮಾಡಿ';

  @override
  String get uiContinue => 'ಮುಂದುವರಿಸಿ';

  @override
  String get uiNotNow => 'ಈಗ ಬೇಡ';

  @override
  String uiPressFor(String key, String action) {
    return '$actionಗಾಗಿ $key ಒತ್ತಿ.';
  }

  @override
  String uiLabelUnavailable(String label) {
    return '$label, ಲಭ್ಯವಿಲ್ಲ';
  }

  @override
  String get uiAlreadyHome => 'ನೀವು ಈಗಾಗಲೇ ಮುಖಪುಟದಲ್ಲಿದ್ದೀರಿ.';

  @override
  String uiNotAvailableNow(String label) {
    return '$label ಈಗ ಲಭ್ಯವಿಲ್ಲ.';
  }

  @override
  String uiListLoading(String title) {
    return '$title ಲೋಡ್ ಆಗುತ್ತಿದೆ. ಹಿಂದೆ ಹೋಗಲು 0 ಒತ್ತಿ.';
  }

  @override
  String uiListPage(String title, String number) {
    return '$title. ಪುಟ $number.';
  }

  @override
  String uiListScreenName(String title, String number) {
    return '$title. ಪುಟ $number';
  }

  @override
  String get uiListNoMatches => 'ಹೊಂದುವ ಐಟಂಗಳಿಲ್ಲ.';

  @override
  String get uiListHelp =>
      'ರಿಫ್ರೆಶ್ ಸೇರಿದಂತೆ ಪಟ್ಟಿಯ ಆಯ್ಕೆಗಳಿಗಾಗಿ 6 ಒತ್ತಿ. ಹಿಂದಿನ ಪುಟಕ್ಕಾಗಿ 7 ಒತ್ತಿ. ಎಲ್ಲಾ ಐಟಂಗಳನ್ನು ಹುಡುಕಲು 8 ಒತ್ತಿ. ಮುಂದಿನ ಪುಟಕ್ಕಾಗಿ 9 ಒತ್ತಿ. ಹಿಂದೆ ಹೋಗಲು 0 ಒತ್ತಿ. ಐಟಂಗಳು ಮತ್ತು ಪುಟ ನಿಯಂತ್ರಣಗಳ ನಡುವೆ ಚಲಿಸಲು D-pad ಮೇಲೆ ಮತ್ತು ಕೆಳಗೆ ಬಳಸಿ, ಆರಿಸಲು ಓಕೆ ಒತ್ತಿ. ಸಹಾಯವನ್ನು ಮತ್ತೆ ಕೇಳಲು ಸ್ಟಾರ್ ಒತ್ತಿ. ಧ್ವನಿ ನಿಲ್ಲಿಸಲು ಹ್ಯಾಶ್ ಒತ್ತಿ.';

  @override
  String get uiListLoadFailed =>
      'ಈ ಪುಟವನ್ನು ಲೋಡ್ ಮಾಡಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ. ಮತ್ತೆ ಪ್ರಯತ್ನಿಸುವ ಆಯ್ಕೆಗಳಿಗಾಗಿ 6 ಒತ್ತಿ. ನಿಮ್ಮ ಹಿಂದಿನ ಪುಟ ಹಾಗೆಯೇ ಇದೆ.';

  @override
  String get uiListLoadingWait =>
      'ಲೋಡ್ ಆಗುತ್ತಿದೆ. ದಯವಿಟ್ಟು ಕಾಯಿರಿ, ಅಥವಾ ಹಿಂದೆ ಹೋಗಲು 0 ಒತ್ತಿ.';

  @override
  String uiListNoItem(String number) {
    return 'ಈ ಪುಟದಲ್ಲಿ $number ಗೆ ಯಾವುದೇ ಐಟಂ ನಿಗದಿಯಾಗಿಲ್ಲ.';
  }

  @override
  String get uiListFirstPage => 'ಇದು ಮೊದಲ ಪುಟ.';

  @override
  String get uiListLastPage => 'ಇದು ಕೊನೆಯ ಪುಟ.';

  @override
  String uiListSearchTitle(String title) {
    return '$title ಹುಡುಕಿ';
  }

  @override
  String get uiListSearchLabel => 'ಲಭ್ಯವಿರುವ ಎಲ್ಲಾ ಐಟಂಗಳನ್ನು ಹುಡುಕಿ';

  @override
  String get uiListSearchTooLong => 'ಹುಡುಕಾಟಕ್ಕೆ ಗರಿಷ್ಠ 200 ಅಕ್ಷರಗಳನ್ನು ಬಳಸಿ.';

  @override
  String get uiListOptions => 'ಪಟ್ಟಿಯ ಆಯ್ಕೆಗಳು';

  @override
  String get uiListSearch => 'ಹುಡುಕಿ';

  @override
  String get uiListClearSearch => 'ಹುಡುಕಾಟ ತೆರವುಗೊಳಿಸಿ';

  @override
  String get uiListRefreshPage => 'ಈ ಪುಟವನ್ನು ರಿಫ್ರೆಶ್ ಮಾಡಿ';

  @override
  String get uiListRetry => 'ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ';

  @override
  String get uiListFilters => 'ಫಿಲ್ಟರ್‌ಗಳು';

  @override
  String get uiListPreviousPage => 'ಹಿಂದಿನ ಪುಟ';

  @override
  String get uiListSearchAll => 'ಎಲ್ಲಾ ಐಟಂಗಳನ್ನು ಹುಡುಕಿ';

  @override
  String get uiListNextPage => 'ಮುಂದಿನ ಪುಟ';

  @override
  String get uiListSections =>
      'ಐಟಂಗಳು, ಪಟ್ಟಿಯ ಆಯ್ಕೆಗಳು, ಹಿಂದಿನ ಪುಟ, ಹುಡುಕಾಟ, ಮುಂದಿನ ಪುಟ ಮತ್ತು ಹಿಂದೆ';

  @override
  String get uiWaitingConfirmation =>
      'ಖಚಿತಪಡಿಸುವಿಕೆಗಾಗಿ ಕಾಯಲಾಗುತ್ತಿದೆ. ದಯವಿಟ್ಟು ಕಾಯಿರಿ.';

  @override
  String get uiFinishWord => 'ಈಗಿನ ಪದವನ್ನು ಟೈಪ್ ಮಾಡಿ ಮುಗಿಸಿ, ನಂತರ ಓಕೆ ಒತ್ತಿ.';

  @override
  String get uiStepFailed =>
      'ಈ ಹಂತವನ್ನು ಪೂರ್ಣಗೊಳಿಸಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ. ನೀವು ನಮೂದಿಸಿದ್ದು ಹಾಗೆಯೇ ಇದೆ. ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get uiPasswordVisible => 'ಪಾಸ್‌ವರ್ಡ್ ಕಾಣಿಸುತ್ತಿದೆ.';

  @override
  String get uiPasswordHidden => 'ಪಾಸ್‌ವರ್ಡ್ ಮರೆಮಾಡಲಾಗಿದೆ.';

  @override
  String uiTextStepScreen(String title, String label) {
    return '$title. $label. ಎಡಿಟ್ ಮಾಡಲಾಗುತ್ತಿದೆ. ಮುಗಿಸಲು ಓಕೆ ಒತ್ತಿ, ಅಥವಾ ಫೀಲ್ಡ್‌ನಿಂದ ಹೊರಬರಲು ಮೇಲೆ ಅಥವಾ ಕೆಳಗೆ ಬಳಸಿ.';
  }

  @override
  String get uiShowOrHidePassword => 'ಪಾಸ್‌ವರ್ಡ್ ತೋರಿಸಿ ಅಥವಾ ಮರೆಮಾಡಿ';

  @override
  String get uiDateEnterNumbers =>
      'ಪ್ರತಿ ದಿನಾಂಕ ಮತ್ತು ಸಮಯದ ಫೀಲ್ಡ್‌ನಲ್ಲಿ ಒಂದು ಸಂಖ್ಯೆಯನ್ನು ನಮೂದಿಸಿ.';

  @override
  String uiDateChooseValid(String from, String to) {
    return '$from ರಿಂದ $to ವರೆಗಿನ ಸರಿಯಾದ ದಿನಾಂಕವನ್ನು ಆರಿಸಿ.';
  }

  @override
  String get uiDateInvalid =>
      'ಸರಿಯಾದ ದಿನಾಂಕ, 0 ರಿಂದ 23 ರವರೆಗಿನ ಗಂಟೆ, ಮತ್ತು 0 ರಿಂದ 59 ರವರೆಗಿನ ನಿಮಿಷವನ್ನು ನಮೂದಿಸಿ.';

  @override
  String uiDateChoose(String from, String to) {
    return '$from ರಿಂದ $to ವರೆಗಿನ ದಿನಾಂಕವನ್ನು ಆರಿಸಿ.';
  }

  @override
  String uiRange(String from, String to) {
    return '$from ರಿಂದ $to';
  }

  @override
  String get uiYear => 'ವರ್ಷ';

  @override
  String get uiMonth => 'ತಿಂಗಳು';

  @override
  String get uiDay => 'ದಿನ';

  @override
  String get uiHour => 'ಗಂಟೆ';

  @override
  String get uiMinute => 'ನಿಮಿಷ';

  @override
  String uiDateFieldEmpty(String name, String range) {
    return '$name, $range, ಈಗ ಖಾಲಿ ಇದೆ';
  }

  @override
  String uiDateFieldValue(String name, String range, String value) {
    return '$name, $range, ಈಗ $value';
  }

  @override
  String uiDateScreen(String from, String to) {
    return 'ಫೋನ್‌ನ ಸ್ಥಳೀಯ ಸಮಯದಲ್ಲಿ ದಿನಾಂಕ ಮತ್ತು ಸಮಯವನ್ನು ಹೊಂದಿಸಿ. $from ರಿಂದ $to ವರೆಗಿನ ದಿನಾಂಕವನ್ನು ಆರಿಸಿ.';
  }

  @override
  String get uiSaveDateTime => 'ದಿನಾಂಕ ಮತ್ತು ಸಮಯ ಉಳಿಸಿ';

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
    return '$label: $value, $total ರಲ್ಲಿ $position';
  }

  @override
  String uiChoiceChange(String description) {
    return '$description. ಬದಲಾಯಿಸಲು ಎಡ ಅಥವಾ ಬಲ ಬಳಸಿ';
  }

  @override
  String get startupPreferencesFailed =>
      'ಕೆಲವು ಆದ್ಯತೆಗಳನ್ನು ಲೋಡ್ ಮಾಡಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ. ಡೀಫಾಲ್ಟ್‌ಗಳನ್ನು ಬಳಸಲಾಗುತ್ತಿದೆ.';

  @override
  String get startupNotificationsTitle => 'ಸೆಷನ್ ಅಧಿಸೂಚನೆಗಳು';

  @override
  String get startupNotificationsMessage =>
      'ಸೆಷನ್ ಆಹ್ವಾನಗಳು ಮತ್ತು ಅಪ್‌ಡೇಟ್‌ಗಳ ಬಗ್ಗೆ ತಿಳಿಸಲು SEEDS ಅಧಿಸೂಚನೆಗಳನ್ನು ಬಳಸುತ್ತದೆ. ನೀವು ಈಗ ಬೇಡ ಆರಿಸಿದರೂ ಆ್ಯಪ್ ಬಳಸುವುದನ್ನು ಮುಂದುವರಿಸಬಹುದು.';

  @override
  String get startupEnableNotifications => 'ಅಧಿಸೂಚನೆಗಳನ್ನು ಆನ್ ಮಾಡಿ';

  @override
  String get startupLoading => 'SEEDS ಲೋಡ್ ಆಗುತ್ತಿದೆ';

  @override
  String get startupWelcomeScreenName => 'SEEDS ಗೆ ಸ್ವಾಗತ';

  @override
  String get startupLoginButton => 'ಸೈನ್ ಇನ್, ಬಟನ್';

  @override
  String get startupRegisterButton => 'ನೋಂದಣಿ, ಬಟನ್';

  @override
  String get startupSettingsButton => 'ಸೆಟ್ಟಿಂಗ್‌ಗಳು, ಬಟನ್';

  @override
  String get startupRepeatInstructionsButton => 'ಸೂಚನೆಗಳನ್ನು ಮತ್ತೆ ಕೇಳಿ, ಬಟನ್';

  @override
  String get authSimAutofillOptional => 'SIM ನಿಂದ ಫೋನ್ ಸಂಖ್ಯೆ ತುಂಬುವುದು ಐಚ್ಛಿಕ';

  @override
  String get authRegisteredNowLogIn =>
      'ನೋಂದಣಿ ಆಗಿದೆ. ಈಗ ಲಾಗಿನ್ ಮಾಡಿ. ಫೋನ್ ಸಂಖ್ಯೆ ಕ್ಷೇತ್ರ. ಸಹಾಯಕ್ಕಾಗಿ ಸ್ಟಾರ್ ಒತ್ತಿ.';

  @override
  String get authSimUnavailableOnDevice =>
      'ಈ ಫೋನ್‌ನಲ್ಲಿ SIM ಸಲಹೆಗಳು ಲಭ್ಯವಿಲ್ಲ. ಫೋನ್ ಸಂಖ್ಯೆಯನ್ನು ನೀವೇ ನಮೂದಿಸಿ.';

  @override
  String get authSimDialogTitle => 'ಐಚ್ಛಿಕ SIM ಸ್ವಯಂ ತುಂಬುವಿಕೆ';

  @override
  String get authSimDialogMessage =>
      'ಈ ಫೋನ್‌ನಿಂದ ಐಚ್ಛಿಕ ಫೋನ್ ಸಂಖ್ಯೆ ಸಲಹೆಗಳನ್ನು ಓದಬೇಕೇ? ಫೋನ್ ಕ್ಷೇತ್ರದಲ್ಲಿ ತುಂಬುವ ಮೊದಲು ನೀವೇ ಒಂದು ಸಲಹೆಯನ್ನು ಆಯ್ಕೆ ಮಾಡುತ್ತೀರಿ. ಇದು ಖಾತೆ ಯಾರದು ಎಂದು ಪರಿಶೀಲಿಸುವುದಿಲ್ಲ. ಲಾಗಿನ್, ನೋಂದಣಿ, Wi-Fi ಅಥವಾ ಸೆಷನ್‌ಗೆ ಸೇರಲು SIM ಪ್ರವೇಶ ಎಂದಿಗೂ ಬೇಕಿಲ್ಲ.';

  @override
  String get authSimDialogConfirm => 'SIM ಸಲಹೆಗಳನ್ನು ಓದಿ';

  @override
  String get authSimAutofillSkipped =>
      'SIM ಸ್ವಯಂ ತುಂಬುವಿಕೆ ಬಿಡಲಾಗಿದೆ. ಫೋನ್ ಸಂಖ್ಯೆಯನ್ನು ನೀವೇ ನಮೂದಿಸಿ.';

  @override
  String get authSimDetecting => 'SIM ಕಾರ್ಡ್ ಹುಡುಕಲಾಗುತ್ತಿದೆ...';

  @override
  String get authSimAutofillUnavailable =>
      'SIM ಸ್ವಯಂ ತುಂಬುವಿಕೆ ಲಭ್ಯವಿಲ್ಲ. ಫೋನ್ ಸಂಖ್ಯೆಯನ್ನು ನೀವೇ ನಮೂದಿಸಿ.';

  @override
  String get authSimNoneFound =>
      'SIM ಕಾರ್ಡ್ ಸಿಗಲಿಲ್ಲ. ಫೋನ್ ಸಂಖ್ಯೆಯನ್ನು ನೀವೇ ನಮೂದಿಸಿ.';

  @override
  String authSimCardsDetected(String count) {
    return '$count SIM ಕಾರ್ಡ್‌ಗಳು ಸಿಕ್ಕಿವೆ. ದಯವಿಟ್ಟು ಒಂದನ್ನು ಆಯ್ಕೆ ಮಾಡಿ.';
  }

  @override
  String get authSimSuggestionUnavailable =>
      'SIM ಸಲಹೆ ಲಭ್ಯವಿಲ್ಲ. ಫೋನ್ ಸಂಖ್ಯೆಯನ್ನು ನೀವೇ ನಮೂದಿಸಿ.';

  @override
  String authSimOptionLabel(String number, String carrier) {
    return 'SIM $number, $carrier';
  }

  @override
  String get authSimUnknownCarrier => 'ಅಪರಿಚಿತ ನೆಟ್‌ವರ್ಕ್';

  @override
  String get authSimSelectedFilled =>
      'ಆಯ್ಕೆ ಮಾಡಿದ ಸಲಹೆ ತುಂಬಲಾಗಿದೆ. ಇದು ಖಾತೆ ನಿಮ್ಮದು ಎಂಬುದಕ್ಕೆ ಪುರಾವೆಯಲ್ಲ.';

  @override
  String get authSimSuggestionFilledSpoken =>
      'ಫೋನ್ ಸಂಖ್ಯೆ ಸಲಹೆ ತುಂಬಲಾಗಿದೆ. ಸೈನ್ ಇನ್ ಮಾಡಲು ನಿಮ್ಮ ಪಾಸ್‌ವರ್ಡ್ ನಮೂದಿಸಿ. ಯಾವುದೇ ಸೈನ್ ಇನ್ ಕಳುಹಿಸಿಲ್ಲ.';

  @override
  String get authErrorEnterPhone => 'ನಿಮ್ಮ ಫೋನ್ ಸಂಖ್ಯೆ ನಮೂದಿಸಿ.';

  @override
  String get authErrorInvalidPhone => 'ಸರಿಯಾದ 10 ಅಂಕಿಯ ಫೋನ್ ಸಂಖ್ಯೆ ನಮೂದಿಸಿ.';

  @override
  String get authErrorEnterPassword => 'ನಿಮ್ಮ ಪಾಸ್‌ವರ್ಡ್ ನಮೂದಿಸಿ.';

  @override
  String get authErrorPasswordTooShort => 'ಪಾಸ್‌ವರ್ಡ್ ಕನಿಷ್ಠ 6 ಅಕ್ಷರಗಳಿರಬೇಕು.';

  @override
  String get authErrorInvalidServerResponse =>
      'ಸರ್ವರ್‌ನಿಂದ ತಪ್ಪಾದ ಉತ್ತರ ಬಂದಿದೆ';

  @override
  String get authErrorNotRegisteredAdmin =>
      'ಈ ಫೋನ್ ಸಂಖ್ಯೆ ನಿರ್ವಾಹಕರ ಖಾತೆಯಾಗಿ ನೋಂದಣಿಯಾಗಿಲ್ಲ. ಖಾತೆಯ ಪ್ರಕಾರ ಆಯ್ಕೆ ಮಾಡಲು 1, 2 ಅಥವಾ 3 ಒತ್ತಿ.';

  @override
  String get authErrorNotRegisteredTeacher =>
      'ಈ ಫೋನ್ ಸಂಖ್ಯೆ ಶಿಕ್ಷಕರ ಖಾತೆಯಾಗಿ ನೋಂದಣಿಯಾಗಿಲ್ಲ. ಖಾತೆಯ ಪ್ರಕಾರ ಆಯ್ಕೆ ಮಾಡಲು 1, 2 ಅಥವಾ 3 ಒತ್ತಿ.';

  @override
  String get authErrorNotRegisteredStudent =>
      'ಈ ಫೋನ್ ಸಂಖ್ಯೆ ವಿದ್ಯಾರ್ಥಿ ಖಾತೆಯಾಗಿ ನೋಂದಣಿಯಾಗಿಲ್ಲ. ಖಾತೆಯ ಪ್ರಕಾರ ಆಯ್ಕೆ ಮಾಡಲು 1, 2 ಅಥವಾ 3 ಒತ್ತಿ.';

  @override
  String get authErrorResponseNotVerified =>
      'ಸೈನ್ ಇನ್ ಉತ್ತರವನ್ನು ಪರಿಶೀಲಿಸಲು ಆಗಲಿಲ್ಲ. ದಯವಿಟ್ಟು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String authErrorMovedToPhone(String message) {
    return '$message ಫೋನ್ ಸಂಖ್ಯೆ ಕ್ಷೇತ್ರಕ್ಕೆ ಸರಿಸಲಾಗಿದೆ.';
  }

  @override
  String authErrorMovedToAccountType(String message) {
    return '$message ಖಾತೆಯ ಪ್ರಕಾರಕ್ಕೆ ಸರಿಸಲಾಗಿದೆ.';
  }

  @override
  String authErrorMovedToPassword(String message) {
    return '$message ಪಾಸ್‌ವರ್ಡ್ ಕ್ಷೇತ್ರಕ್ಕೆ ಸರಿಸಲಾಗಿದೆ.';
  }

  @override
  String get authRoleAdministrator => 'ನಿರ್ವಾಹಕರು';

  @override
  String get authRoleTeacher => 'ಶಿಕ್ಷಕರು';

  @override
  String get authRoleStudent => 'ವಿದ್ಯಾರ್ಥಿ';

  @override
  String get authRecoveryStep1 =>
      'ನಿಮ್ಮ ಪಾಸ್‌ವರ್ಡ್ ಮರುಹೊಂದಿಸಲು ನಿಮ್ಮ ಶಾಲೆಯ ನಿರ್ವಾಹಕರನ್ನು ಕೇಳಿ. ಅವರು ನೀವು ಯಾರು ಎಂದು ನೇರವಾಗಿ ಭೇಟಿಯಾಗಿ ಪರಿಶೀಲಿಸಬೇಕು. ಕೇವಲ ಫೋನ್ ಸಂಖ್ಯೆ ಅಥವಾ SIM ಅದನ್ನು ಸಾಬೀತುಪಡಿಸುವುದಿಲ್ಲ. ನಿಮ್ಮ ಶಾಶ್ವತ ಪಾಸ್‌ವರ್ಡ್ ಅನ್ನು ಯಾರಿಗೂ ಎಂದಿಗೂ ಕಳುಹಿಸಬೇಡಿ.';

  @override
  String get authRecoveryStep2 =>
      'ನಿರ್ವಾಹಕರು ನಿಮಗೆ ಖಾಸಗಿಯಾದ 12 ಅಂಕಿಯ ತಾತ್ಕಾಲಿಕ ಪಾಸ್‌ವರ್ಡ್ ನೀಡುತ್ತಾರೆ. ಅದು 24 ಗಂಟೆ ಕೆಲಸ ಮಾಡುತ್ತದೆ. ಅವಧಿ ಮುಗಿದರೆ ಹೊಸದನ್ನು ಕೇಳಿ.';

  @override
  String get authRecoveryStep3 =>
      'ನಿಮ್ಮ ಫೋನ್ ಸಂಖ್ಯೆ ಮತ್ತು ತಾತ್ಕಾಲಿಕ ಪಾಸ್‌ವರ್ಡ್‌ನಿಂದ ಸೈನ್ ಇನ್ ಮಾಡಿ, ನಂತರ ಹೊಸ ಪಾಸ್‌ವರ್ಡ್ ಆಯ್ಕೆ ಮಾಡಿ.';

  @override
  String get authRecoveryStep4 =>
      '10 ತಪ್ಪು ಪ್ರಯತ್ನಗಳ ನಂತರ, ಸೈನ್ ಇನ್ 15 ನಿಮಿಷ ನಿಲ್ಲುತ್ತದೆ. ಮರುಪಡೆಯಲು ಇಂಟರ್ನೆಟ್ ಬೇಕು. ಈಗಾಗಲೇ ಬೇರೆ ಫೋನ್‌ಗಳಲ್ಲಿರುವ ಫೈಲ್‌ಗಳು ತಕ್ಷಣ ತೆಗೆದುಹಾಕಲ್ಪಡುವುದಿಲ್ಲ.';

  @override
  String get authRecoveryHelpTitle => 'ಪಾಸ್‌ವರ್ಡ್ ಮರುಪಡೆಯುವ ಸಹಾಯ';

  @override
  String authRecoveryHelpIntro(String count) {
    return '$count ಸಣ್ಣ ಹಂತಗಳು. ಪ್ರತಿ ಹಂತವನ್ನು ಕೇಳಲು ಕೆಳಗೆ ಒತ್ತಿ.';
  }

  @override
  String get authBackToLogin => 'ಲಾಗಿನ್‌ಗೆ ಹಿಂತಿರುಗಿ';

  @override
  String get authBackToLoginButton => 'ಲಾಗಿನ್‌ಗೆ ಹಿಂತಿರುಗಿ, ಬಟನ್';

  @override
  String get notesRecordingStarted =>
      'ರೆಕಾರ್ಡಿಂಗ್ ಪ್ರಾರಂಭವಾಗಿದೆ. ಮುಗಿದಾಗ ರೆಕಾರ್ಡಿಂಗ್ ನಿಲ್ಲಿಸಿ ಆರಿಸಿ.';

  @override
  String get notesActionNotConfirmed =>
      'ಈ ಟಿಪ್ಪಣಿ ಕ್ರಿಯೆಯನ್ನು ದೃಢೀಕರಿಸಲು ಆಗಲಿಲ್ಲ. ಸಂಗ್ರಹಣೆ, ಮೈಕ್ರೊಫೋನ್ ಅನುಮತಿ ಅಥವಾ ಸಂಪರ್ಕವನ್ನು ಪರಿಶೀಲಿಸಿ. ನಿಮ್ಮ ಕರಡುಗಳನ್ನು ಇಟ್ಟುಕೊಳ್ಳಲಾಗಿದೆ.';

  @override
  String get notesNoneYet => 'ಇನ್ನೂ ಯಾವುದೇ ಖಾಸಗಿ ಟಿಪ್ಪಣಿಗಳಿಲ್ಲ.';

  @override
  String notesLoaded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ಖಾಸಗಿ ಟಿಪ್ಪಣಿಗಳು ಲೋಡ್ ಆಗಿವೆ.',
      one: '1 ಖಾಸಗಿ ಟಿಪ್ಪಣಿ ಲೋಡ್ ಆಗಿದೆ.',
    );
    return '$_temp0';
  }

  @override
  String get notesNameDialogTitle => 'ಖಾಸಗಿ ಟಿಪ್ಪಣಿಗೆ ಹೆಸರು ನೀಡಿ';

  @override
  String get notesDefaultTitle => 'ಖಾಸಗಿ ಟಿಪ್ಪಣಿ';

  @override
  String notesDefaultLessonTitle(String lesson) {
    return '$lesson ಗಾಗಿ ಟಿಪ್ಪಣಿ';
  }

  @override
  String get notesRecordConfirmTitle => 'ಖಾಸಗಿ ಟಿಪ್ಪಣಿ ರೆಕಾರ್ಡ್ ಮಾಡಬೇಕೇ?';

  @override
  String notesRecordConfirmMessage(String lessonPoint) {
    return 'ಮೈಕ್ರೊಫೋನ್ ಆಡಿಯೊವನ್ನು ಈ ಫೋನ್‌ನಲ್ಲಿ ಮಾತ್ರ ರೆಕಾರ್ಡ್ ಮಾಡಲಾಗುತ್ತದೆ, ಗರಿಷ್ಠ ಐದು ನಿಮಿಷ ಅಥವಾ ಟಿಪ್ಪಣಿಗಳಿಗಾಗಿ ಪ್ರತ್ಯೇಕವಾಗಿ ಉಳಿದಿರುವ 10 MB ಮಿತಿಯವರೆಗೆ. ಧ್ವನಿ ನಿಯಂತ್ರಣಗಳನ್ನು ಬಳಸುವ ಮೊದಲು ರೆಕಾರ್ಡಿಂಗ್ ನಿಲ್ಲಿಸಿ. ಆ್ಯಪ್ ಧ್ವನಿ, ಈ ಪರದೆಯಿಂದ ಹೊರಹೋಗುವುದು ಅಥವಾ ಆ್ಯಪ್ ಅಡಚಣೆ ರೆಕಾರ್ಡಿಂಗ್ ನಿಲ್ಲಿಸುತ್ತದೆ. ಲೈವ್ ಸೆಷನ್ ರೆಕಾರ್ಡಿಂಗ್ ನಿರ್ಬಂಧಿಸಲಾಗಿದೆ. $lessonPoint ಸ್ವಯಂಚಾಲಿತ ಅಪ್‌ಲೋಡ್ ಅಥವಾ ಹಂಚಿಕೆ ಇಲ್ಲ. ಮೈಕ್ರೊಫೋನ್ ಅನುಮತಿ ಕೇಳಬಹುದು.';
  }

  @override
  String notesLessonPointSeconds(String seconds) {
    return 'ಪಾಠದ ಸ್ಥಾನ: $seconds ಸೆಕೆಂಡುಗಳು.';
  }

  @override
  String get notesStartRecording => 'ರೆಕಾರ್ಡಿಂಗ್ ಪ್ರಾರಂಭಿಸಿ';

  @override
  String get notesDoNotRecord => 'ರೆಕಾರ್ಡ್ ಮಾಡಬೇಡಿ';

  @override
  String get notesReviewStoppedChanged =>
      'ಪರದೆ ಅಥವಾ ಆ್ಯಪ್ ಬದಲಾದ ಕಾರಣ ಪರಿಶೀಲನೆ ನಿಂತಿದೆ. ಪರಿಶೀಲಿಸಲು ಈ ಟಿಪ್ಪಣಿಯನ್ನು ಮತ್ತೆ ತೆರೆಯಿರಿ.';

  @override
  String get notesReviewStoppedAccount =>
      'ನಿಮ್ಮ ಖಾತೆ ಬದಲಾದ ಕಾರಣ ಪರಿಶೀಲನೆ ನಿಂತಿದೆ. ಖಾಸಗಿ ಟಿಪ್ಪಣಿಗಳನ್ನು ಮತ್ತೆ ತೆರೆಯಿರಿ.';

  @override
  String get notesRenameDialogTitle => 'ಖಾಸಗಿ ಟಿಪ್ಪಣಿಯ ಹೆಸರು ಬದಲಿಸಿ';

  @override
  String notesRemoveTitle(String title) {
    return '$title ತೆಗೆದುಹಾಕಬೇಕೇ?';
  }

  @override
  String notesRemoveMessage(String title) {
    return 'ಈ ಫೋನ್‌ನಲ್ಲಿರುವ ಈ ಖಾತೆಯಿಂದ $title ಅನ್ನು ಮಾತ್ರ ತೆಗೆದುಹಾಕಬೇಕೇ? ಇತರ ಟಿಪ್ಪಣಿಗಳು, ಕಲಿಕೆಯ ಪ್ರಗತಿ ಮತ್ತು ಬುಕ್‌ಮಾರ್ಕ್‌ಗಳನ್ನು ಇಟ್ಟುಕೊಳ್ಳಲಾಗುತ್ತದೆ. ಹಿಂದೆ ಪ್ರಕಟಿಸಿದ್ದರೆ, ಆನ್‌ಲೈನ್ ರೆಕಾರ್ಡಿಂಗ್ ಮತ್ತು ಡೌನ್‌ಲೋಡ್ ಮಾಡಿದ ಪ್ರತಿಗಳನ್ನು ತೆಗೆದುಹಾಕಲಾಗುವುದಿಲ್ಲ.';
  }

  @override
  String get notesRemoveSelected => 'ಆಯ್ಕೆ ಮಾಡಿದ ಟಿಪ್ಪಣಿ ತೆಗೆದುಹಾಕಿ';

  @override
  String get notesKeepNote => 'ಟಿಪ್ಪಣಿ ಇಟ್ಟುಕೊಳ್ಳಿ';

  @override
  String notesRemoved(String title) {
    return '$title ತೆಗೆದುಹಾಕಲಾಗಿದೆ. ಇತರ ಟಿಪ್ಪಣಿಗಳು ಮತ್ತು ಕಲಿಕೆಯ ಪ್ರಗತಿಯನ್ನು ಇಟ್ಟುಕೊಳ್ಳಲಾಗಿದೆ.';
  }

  @override
  String get notesReviewBeforePublish =>
      'ಪ್ರಕಟಿಸುವ ಮೊದಲು ಈ ಟಿಪ್ಪಣಿಯನ್ನು ಖಾಸಗಿಯಾಗಿ ಪ್ಲೇ ಮಾಡಿ ಪರಿಶೀಲಿಸಿ.';

  @override
  String get notesSignInAsTeacher =>
      'ಪ್ರಕಟಿಸುವ ಮೊದಲು ಶಿಕ್ಷಕರಾಗಿ ಸೈನ್ ಇನ್ ಮಾಡಿ.';

  @override
  String get notesNoWorkspace =>
      'ಯಾವುದೇ ಅಧಿಕೃತ ತರಗತಿ/ವಿಷಯ ಕಾರ್ಯಕ್ಷೇತ್ರವನ್ನು ದೃಢೀಕರಿಸಲಾಗಿಲ್ಲ. ನಿಮ್ಮ ಕರಡನ್ನು ಇಟ್ಟುಕೊಳ್ಳಲಾಗಿದೆ.';

  @override
  String get notesPublishTitle =>
      'ಪರಿಶೀಲಿಸಿದ ಟಿಪ್ಪಣಿಯನ್ನು ತರಗತಿಗೆ ಪ್ರಕಟಿಸಬೇಕೇ?';

  @override
  String notesPublishMessage(
    String title,
    String className,
    String subjectName,
  ) {
    return 'ನೀವು $title ಅನ್ನು ಪರಿಶೀಲಿಸಿದ್ದೀರಿ ಮತ್ತು ಅದನ್ನು $className, $subjectName ಗೆ ಪ್ರಕಟಿಸಲು ಬಯಸುತ್ತೀರಿ ಎಂದು ದೃಢೀಕರಿಸಿ. ಅಧಿಕೃತ ತರಗತಿ ಸದಸ್ಯರು ಇದನ್ನು ಸ್ಟ್ರೀಮ್ ಮಾಡಬಹುದು ಅಥವಾ ಗರಿಷ್ಠ 30 ದಿನಗಳವರೆಗೆ ಆಫ್‌ಲೈನ್‌ಗಾಗಿ ಡೌನ್‌ಲೋಡ್ ಮಾಡಬಹುದು. ಸಂಪರ್ಕ ಕಡಿತಗೊಂಡ ಪ್ರತಿಗಳನ್ನು ತಕ್ಷಣ ಹಿಂಪಡೆಯಲು ಸಾಧ್ಯವಿಲ್ಲ. ನಿಮ್ಮ ಸ್ಥಳೀಯ ಕರಡು ಉಳಿಯುತ್ತದೆ. ದೃಢೀಕರಿಸದ ಅಪ್‌ಲೋಡ್ ಈಗಾಗಲೇ ಪ್ರಕಟವಾಗಿರಬಹುದು; ನಕಲುಗಳನ್ನು ತಪ್ಪಿಸಲು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸುವ ಮೊದಲು ಲೈಬ್ರರಿಯನ್ನು ಪರಿಶೀಲಿಸಿ.';
  }

  @override
  String get notesPublishConfirm => 'ಆಯ್ಕೆ ಮಾಡಿದ ತರಗತಿಗೆ ಪ್ರಕಟಿಸಿ';

  @override
  String get notesKeepDraftPrivate => 'ಕರಡನ್ನು ಖಾಸಗಿಯಾಗಿ ಇಡಿ';

  @override
  String get notesSignInChanged => 'ಸೈನ್ ಇನ್ ಬದಲಾಗಿದೆ. ಕರಡನ್ನು ಕಳುಹಿಸಲಾಗಿಲ್ಲ.';

  @override
  String get notesAccountChangedBeforePublish =>
      'ಪ್ರಕಟಣೆ ದೃಢೀಕರಿಸುವ ಮೊದಲೇ ನಿಮ್ಮ ಖಾತೆ ಬದಲಾಗಿದೆ. ಮತ್ತೆ ಪ್ರಯತ್ನಿಸುವ ಮೊದಲು ಮೂಲ ಶಿಕ್ಷಕರ ಲೈಬ್ರರಿಯನ್ನು ಪರಿಶೀಲಿಸಿ.';

  @override
  String get notesPublishNotConfirmed =>
      'ಪ್ರಕಟಣೆ ದೃಢೀಕರಿಸಲಾಗಿಲ್ಲ. ಮತ್ತೆ ಪ್ರಯತ್ನಿಸುವ ಮೊದಲು ತರಗತಿಯ ಲೈಬ್ರರಿಯನ್ನು ಪರಿಶೀಲಿಸಿ; ನಿಮ್ಮ ಖಾಸಗಿ ಕರಡನ್ನು ಇಟ್ಟುಕೊಳ್ಳಲಾಗಿದೆ.';

  @override
  String get notesPublishUnreadable =>
      'ಪ್ರಕಟಣೆಯ ದೃಢೀಕರಣವನ್ನು ಓದಲು ಆಗಲಿಲ್ಲ. ಮತ್ತೆ ಪ್ರಯತ್ನಿಸುವ ಮೊದಲು ಲೈಬ್ರರಿಯನ್ನು ಪರಿಶೀಲಿಸಿ; ನಿಮ್ಮ ಕರಡನ್ನು ಇಟ್ಟುಕೊಳ್ಳಲಾಗಿದೆ.';

  @override
  String get notesPublishIdentityMismatch =>
      'ಪ್ರಕಟಣೆಯ ಗುರುತು ಹೊಂದಿಕೆಯಾಗಲಿಲ್ಲ. ಮತ್ತೆ ಪ್ರಯತ್ನಿಸುವ ಮೊದಲು ಲೈಬ್ರರಿಯನ್ನು ಪರಿಶೀಲಿಸಿ; ನಿಮ್ಮ ಕರಡನ್ನು ಇಟ್ಟುಕೊಳ್ಳಲಾಗಿದೆ.';

  @override
  String notesPublished(String audioId) {
    return 'ರೆಕಾರ್ಡಿಂಗ್ $audioId ಆಗಿ ಪ್ರಕಟಿಸಲಾಗಿದೆ. ನಿಮ್ಮ ಸ್ಥಳೀಯ ಕರಡನ್ನು ಇಟ್ಟುಕೊಳ್ಳಲಾಗಿದೆ. ಇನ್ನೊಂದು ರೆಕಾರ್ಡಿಂಗ್ ಬೇಕಿದ್ದರೆ ಮಾತ್ರ ಮತ್ತೆ ಪ್ರಕಟಿಸಿ.';
  }

  @override
  String get notesStopBeforeLeaving =>
      'ರೆಕಾರ್ಡಿಂಗ್ ನಿಲ್ಲಿಸಿದ್ದು ದೃಢೀಕರಿಸಲಾಗಿಲ್ಲ. ಹೊರಹೋಗುವ ಮೊದಲು ಮತ್ತೆ ನಿಲ್ಲಿಸಿ ಅಥವಾ ಆ್ಯಪ್ ಅನ್ನು ಹಿನ್ನೆಲೆಗೆ ಕಳುಹಿಸಿ.';

  @override
  String get notesRules =>
      'ಖಾಸಗಿ ಟಿಪ್ಪಣಿ ನಿಯಮಗಳು. ಪ್ರತಿ ಟಿಪ್ಪಣಿ ಐದು ನಿಮಿಷಗಳವರೆಗೆ ಇರಬಹುದು. ಟಿಪ್ಪಣಿಗಳಿಗೆ ಪ್ರತಿ ಖಾತೆಗೆ ಪ್ರತ್ಯೇಕ 10 ಮೆಗಾಬೈಟ್ ಜಾಗ ಇರುತ್ತದೆ. ನೀವು ದೃಢೀಕರಿಸಿದಾಗ ಮಾತ್ರ ರೆಕಾರ್ಡಿಂಗ್ ಶುರುವಾಗುತ್ತದೆ, ಲೈವ್ ಸೆಷನ್ ಒಳಗೆ ಎಂದಿಗೂ ಆಗುವುದಿಲ್ಲ. ಆ್ಯಪ್ ಧ್ವನಿ, ಈ ಪರದೆಯಿಂದ ಹೊರಹೋಗುವುದು ಅಥವಾ ಅಡಚಣೆ ರೆಕಾರ್ಡಿಂಗ್ ನಿಲ್ಲಿಸುತ್ತದೆ, ಆದ್ದರಿಂದ ಧ್ವನಿ ನಿಯಂತ್ರಣಗಳನ್ನು ಬಳಸುವ ಮೊದಲು ರೆಕಾರ್ಡಿಂಗ್ ನಿಲ್ಲಿಸಿ. ವಿದ್ಯಾರ್ಥಿಗಳ ಟಿಪ್ಪಣಿಗಳು ಈ ಫೋನ್‌ನಲ್ಲಿ ಖಾಸಗಿಯಾಗಿ ಇರುತ್ತವೆ. ಶಿಕ್ಷಕರ ಕರಡುಗಳನ್ನು ಪ್ರಕಟಿಸುವ ಮೊದಲು ಪರಿಶೀಲಿಸಿ ದೃಢೀಕರಿಸಬೇಕು. ನೀವು ಲಾಗ್ ಔಟ್ ಮಾಡಿದ ನಂತರವೂ ಟಿಪ್ಪಣಿಗಳು ಉಳಿಯುತ್ತವೆ.';

  @override
  String notesRecordingFor(String duration) {
    return '$duration ರಿಂದ ರೆಕಾರ್ಡಿಂಗ್ ಆಗುತ್ತಿದೆ.';
  }

  @override
  String notesUsage(String megabytes) {
    return '10 MB ಖಾಸಗಿ ಟಿಪ್ಪಣಿ ಜಾಗದಲ್ಲಿ $megabytes ಬಳಸಲಾಗಿದೆ.';
  }

  @override
  String authRecoveryStepListItem(String number, String step) {
    return '$number. $step';
  }

  @override
  String get authBackToLoginKey => '0: ಲಾಗಿನ್‌ಗೆ ಹಿಂತಿರುಗಿ';

  @override
  String get authRoleRowSelected => 'ಆಯ್ಕೆಯಾಗಿದೆ';

  @override
  String get authLoginScreenName => 'ಲಾಗಿನ್ ಪರದೆ';

  @override
  String get authLoginNavigationSections =>
      'ಫೋನ್ ಸಂಖ್ಯೆ, ಪಾಸ್‌ವರ್ಡ್, ಖಾತೆಯ ಪ್ರಕಾರ, ಲಾಗಿನ್, ನೋಂದಣಿ, SIM ಸಲಹೆಗಳು ಮತ್ತು ಮರುಪಡೆಯುವ ಸಹಾಯ';

  @override
  String get authLoginKeySimLabel => 'ಐಚ್ಛಿಕ SIM ಫೋನ್ ಸಂಖ್ಯೆ ಸಲಹೆಗಳನ್ನು ಓದಿ';

  @override
  String get authLoginKeyRecoveryLabel =>
      'ಶಾಲಾ ನಿರ್ವಾಹಕರ ಮೂಲಕ ಪಾಸ್‌ವರ್ಡ್ ಮರುಪಡೆಯುವ ಸಹಾಯ';

  @override
  String get authPhoneNumberField => 'ಫೋನ್ ಸಂಖ್ಯೆ ಕ್ಷೇತ್ರ';

  @override
  String get authPasswordField => 'ಪಾಸ್‌ವರ್ಡ್ ಕ್ಷೇತ್ರ';

  @override
  String get authHidePassword => 'ಪಾಸ್‌ವರ್ಡ್ ಮರೆಮಾಡಿ';

  @override
  String get authShowPassword => 'ಪಾಸ್‌ವರ್ಡ್ ತೋರಿಸಿ';

  @override
  String authRoleFieldNavLabel(String role) {
    return 'ಖಾತೆಯ ಪ್ರಕಾರ: $role, ಆಯ್ಕೆಯಾಗಿದೆ. ಬದಲಾಯಿಸಲು 1, 2 ಅಥವಾ 3 ಒತ್ತಿ, ಅಥವಾ ಎಡ ಮತ್ತು ಬಲ ಬಳಸಿ';
  }

  @override
  String authLoginAsButton(String role) {
    return '$role ಆಗಿ ಲಾಗಿನ್ ಮಾಡಿ, ಬಟನ್';
  }

  @override
  String get authRegisterNewAccountButton => 'ಹೊಸ ಖಾತೆ ನೋಂದಾಯಿಸಿ, ಬಟನ್';

  @override
  String get authSimSuggestionsTargetLabel =>
      'ಐಚ್ಛಿಕ SIM ಫೋನ್ ಸಂಖ್ಯೆ ಸಲಹೆಗಳನ್ನು ಓದಿ. ನೀವೇ ನಮೂದಿಸುವುದು ಯಾವಾಗಲೂ ಸಾಧ್ಯ.';

  @override
  String get authForgotPasswordTargetLabel =>
      'ಪಾಸ್‌ವರ್ಡ್ ಮರೆತಿರಾ? ಶಾಲಾ ನಿರ್ವಾಹಕರ ಮೂಲಕ ಮರುಪಡೆಯುವ ಸಹಾಯ';

  @override
  String get authWelcomeBack => 'ಮರಳಿ ಸ್ವಾಗತ';

  @override
  String get authRegisteredBanner => 'ನೋಂದಣಿ ಆಗಿದೆ. ಈಗ ಲಾಗಿನ್ ಮಾಡಿ.';

  @override
  String get authPhoneNumber => 'ಫೋನ್ ಸಂಖ್ಯೆ';

  @override
  String get authPassword => 'ಪಾಸ್‌ವರ್ಡ್';

  @override
  String get authAccountType => 'ಖಾತೆಯ ಪ್ರಕಾರ';

  @override
  String authRoleFieldValue(String role) {
    return '$role, ಆಯ್ಕೆಯಾಗಿದೆ. ಬದಲಾಯಿಸಲು 1, 2 ಅಥವಾ 3 ಒತ್ತಿ';
  }

  @override
  String get authRoleOptionStudent => '1 ವಿದ್ಯಾರ್ಥಿ';

  @override
  String get authRoleOptionTeacher => '2 ಶಿಕ್ಷಕರು';

  @override
  String get authRoleOptionAdmin => '3 ನಿರ್ವಾಹಕರು';

  @override
  String get authSigningIn => 'ಸೈನ್ ಇನ್ ಆಗುತ್ತಿದೆ, ದಯವಿಟ್ಟು ಕಾಯಿರಿ';

  @override
  String authLoginAsKey(String role) {
    return '4: $role ಆಗಿ ಲಾಗಿನ್ ಮಾಡಿ';
  }

  @override
  String get authNoAccountRegisterKey => '5: ಖಾತೆ ಇಲ್ಲವೇ? ನೋಂದಾಯಿಸಿ';

  @override
  String get authReadSimSuggestionsKey => '6: ಐಚ್ಛಿಕ SIM ಸಲಹೆಗಳನ್ನು ಓದಿ';

  @override
  String get authForgotPasswordKey => '7: ಪಾಸ್‌ವರ್ಡ್ ಮರೆತಿರಾ? ಮರುಪಡೆಯುವ ಸಹಾಯ';

  @override
  String authErrorMovedToName(String message) {
    return '$message ಹೆಸರು ಕ್ಷೇತ್ರಕ್ಕೆ ಸರಿಸಲಾಗಿದೆ.';
  }

  @override
  String get authErrorEnterName => 'ನಿಮ್ಮ ಹೆಸರು ನಮೂದಿಸಿ.';

  @override
  String get authErrorEnterAPassword => 'ಒಂದು ಪಾಸ್‌ವರ್ಡ್ ನಮೂದಿಸಿ.';

  @override
  String get authRegisteringAsTeacher => 'ಶಿಕ್ಷಕರಾಗಿ ನೋಂದಣಿ ಆಗುತ್ತಿದೆ';

  @override
  String get authRegisteringAsStudent => 'ವಿದ್ಯಾರ್ಥಿಯಾಗಿ ನೋಂದಣಿ ಆಗುತ್ತಿದೆ';

  @override
  String get authRegistrationScreenName => 'ನೋಂದಣಿ ಪರದೆ';

  @override
  String get authRegisterNavigationSections =>
      'ಹೆಸರು, ಫೋನ್ ಸಂಖ್ಯೆ, ಪಾಸ್‌ವರ್ಡ್, ವಿದ್ಯಾರ್ಥಿ ಅಥವಾ ಶಿಕ್ಷಕರ ಖಾತೆಯ ಪ್ರಕಾರ, ನೋಂದಣಿ ಮತ್ತು ಲಾಗಿನ್';

  @override
  String get authNameField => 'ಹೆಸರು ಕ್ಷೇತ್ರ';

  @override
  String get authRegisterRoleTeacherLabel =>
      'ಖಾತೆಯ ಪ್ರಕಾರ: ಶಿಕ್ಷಕರು. ವಿದ್ಯಾರ್ಥಿಗೆ ಬದಲಾಯಿಸಲು ಓಕೆ ಅಥವಾ 3 ಒತ್ತಿ';

  @override
  String get authRegisterRoleStudentLabel =>
      'ಖಾತೆಯ ಪ್ರಕಾರ: ವಿದ್ಯಾರ್ಥಿ. ಶಿಕ್ಷಕರಿಗೆ ಬದಲಾಯಿಸಲು ಓಕೆ ಅಥವಾ 3 ಒತ್ತಿ';

  @override
  String get authRegisterAsTeacherButton => 'ಶಿಕ್ಷಕರಾಗಿ ನೋಂದಾಯಿಸಿ, ಬಟನ್';

  @override
  String get authRegisterAsStudentButton => 'ವಿದ್ಯಾರ್ಥಿಯಾಗಿ ನೋಂದಾಯಿಸಿ, ಬಟನ್';

  @override
  String get authGoToLoginLabel => 'ಈಗಾಗಲೇ ಖಾತೆ ಇದೆಯೇ? ಲಾಗಿನ್‌ಗೆ ಹೋಗಿ';

  @override
  String get authRegisterTitle => 'ನೋಂದಣಿ';

  @override
  String get authName => 'ಹೆಸರು';

  @override
  String get authRegisterAsTeacherKey =>
      '3: ಶಿಕ್ಷಕರಾಗಿ ನೋಂದಾಯಿಸಿ. ಖಾತೆಯ ಪ್ರಕಾರ ಬದಲಾಯಿಸಿ';

  @override
  String get authRegisterAsStudentKey =>
      '3: ವಿದ್ಯಾರ್ಥಿಯಾಗಿ ನೋಂದಾಯಿಸಿ. ಖಾತೆಯ ಪ್ರಕಾರ ಬದಲಾಯಿಸಿ';

  @override
  String get authRegisteringPleaseWait => 'ನೋಂದಣಿ ಆಗುತ್ತಿದೆ, ದಯವಿಟ್ಟು ಕಾಯಿರಿ';

  @override
  String get authRegisterKey => '1: ನೋಂದಾಯಿಸಿ';

  @override
  String get authHaveAccountLoginKey => '2: ಈಗಾಗಲೇ ಖಾತೆ ಇದೆಯೇ? ಲಾಗಿನ್ ಮಾಡಿ';

  @override
  String get authChangePasswordBusy =>
      'ಉಳಿಸಲಾಗುತ್ತಿದೆ. ಪಾಸ್‌ವರ್ಡ್ ಬದಲಾವಣೆಯ ದೃಢೀಕರಣಕ್ಕಾಗಿ ಕಾಯಲಾಗುತ್ತಿದೆ.';

  @override
  String get authChangePasswordErrorEnterTemporary =>
      'ನಿಮ್ಮ ತಾತ್ಕಾಲಿಕ ಕೋಡ್ ನಮೂದಿಸಿ. ಆ ಕ್ಷೇತ್ರಕ್ಕೆ ಸರಿಸಲಾಗಿದೆ.';

  @override
  String get authChangePasswordErrorTooShort =>
      'ಕನಿಷ್ಠ 6 ಅಕ್ಷರಗಳ ಹೊಸ ಪಾಸ್‌ವರ್ಡ್ ನಮೂದಿಸಿ. ಹೊಸ ಪಾಸ್‌ವರ್ಡ್‌ಗೆ ಸರಿಸಲಾಗಿದೆ.';

  @override
  String get authChangePasswordErrorMismatch =>
      'ಹೊಸ ಪಾಸ್‌ವರ್ಡ್‌ಗಳು ಹೊಂದಿಕೆಯಾಗುತ್ತಿಲ್ಲ. ಹೊಸ ಪಾಸ್‌ವರ್ಡ್ ಮತ್ತೆ ನಮೂದಿಸುವ ಕ್ಷೇತ್ರಕ್ಕೆ ಸರಿಸಲಾಗಿದೆ.';

  @override
  String get authChangePasswordErrorSameAsTemporary =>
      'ತಾತ್ಕಾಲಿಕ ಕೋಡ್‌ಗಿಂತ ಬೇರೆ ಪಾಸ್‌ವರ್ಡ್ ಆಯ್ಕೆ ಮಾಡಿ. ಹೊಸ ಪಾಸ್‌ವರ್ಡ್‌ಗೆ ಸರಿಸಲಾಗಿದೆ.';

  @override
  String get authChangePasswordSessionInactive =>
      'ಈ ಮರುಪಡೆಯುವ ಅವಧಿ ಈಗ ಸಕ್ರಿಯವಾಗಿಲ್ಲ. ಮತ್ತೆ ಸೈನ್ ಇನ್ ಮಾಡಿ.';

  @override
  String get authChangePasswordAccountChanged =>
      'ನಿಮ್ಮ ಖಾತೆ ಬದಲಾಗಿದೆ. ಬದಲಿ ಸೈನ್ ಇನ್ ಉಳಿಸಲಾಗಿಲ್ಲ.';

  @override
  String authChangePasswordNotConfirmed(String message) {
    return '$message ಪಾಸ್‌ವರ್ಡ್ ಬದಲಾವಣೆ ದೃಢಪಟ್ಟಿಲ್ಲ. ಸಂಪರ್ಕ ವಿಫಲವಾಗಿದ್ದರೆ, ಇನ್ನೊಂದು ಮರುಹೊಂದಿಕೆ ಕೇಳುವ ಮೊದಲು ನಿಮ್ಮ ಹೊಸ ಪಾಸ್‌ವರ್ಡ್‌ನಿಂದ ಸೈನ್ ಇನ್ ಮಾಡಿ ನೋಡಿ.';
  }

  @override
  String get authChangePasswordResponseNotVerified =>
      'ಪಾಸ್‌ವರ್ಡ್ ಬದಲಾವಣೆಯ ಉತ್ತರವನ್ನು ಪರಿಶೀಲಿಸಲು ಆಗಲಿಲ್ಲ. ನಿಮ್ಮ ಹೊಸ ಪಾಸ್‌ವರ್ಡ್‌ನಿಂದ ಮತ್ತೆ ಸೈನ್ ಇನ್ ಮಾಡಿ ನೋಡಿ.';

  @override
  String get authChangePasswordReplacementNotVerified =>
      'ಬದಲಿ ಸೈನ್ ಇನ್ ಅನ್ನು ಪರಿಶೀಲಿಸಲು ಆಗಲಿಲ್ಲ. ನಿಮ್ಮ ಹೊಸ ಪಾಸ್‌ವರ್ಡ್‌ನಿಂದ ಮತ್ತೆ ಸೈನ್ ಇನ್ ಮಾಡಿ.';

  @override
  String get authChangePasswordSignInNotSaved =>
      'ನಿಮ್ಮ ಸೈನ್ ಇನ್ ಉಳಿಸಲು ಆಗಲಿಲ್ಲ. ನಿಮ್ಮ ಹೊಸ ಪಾಸ್‌ವರ್ಡ್‌ನಿಂದ ಮತ್ತೆ ಸೈನ್ ಇನ್ ಮಾಡಿ.';

  @override
  String get authChangePasswordSignInNotSavedOnPhone =>
      'ನಿಮ್ಮ ಸೈನ್ ಇನ್ ಅನ್ನು ಈ ಫೋನ್‌ನಲ್ಲಿ ಉಳಿಸಲು ಆಗಲಿಲ್ಲ. ನಿಮ್ಮ ಹೊಸ ಪಾಸ್‌ವರ್ಡ್‌ನಿಂದ ಮತ್ತೆ ಸೈನ್ ಇನ್ ಮಾಡಿ.';

  @override
  String get authTemporaryCredential => 'ತಾತ್ಕಾಲಿಕ ಕೋಡ್';

  @override
  String get authNewPassword => 'ಹೊಸ ಪಾಸ್‌ವರ್ಡ್';

  @override
  String get authRepeatNewPassword => 'ಹೊಸ ಪಾಸ್‌ವರ್ಡ್ ಮತ್ತೆ ನಮೂದಿಸಿ';

  @override
  String get authChangePasswordScreenName => 'ತಾತ್ಕಾಲಿಕ ಪಾಸ್‌ವರ್ಡ್ ಬದಲಾಯಿಸಿ';

  @override
  String get authChangePasswordIntro =>
      'ನಿಮ್ಮ ನಿರ್ವಾಹಕರು ನೀಡಿದ ತಾತ್ಕಾಲಿಕ ಕೋಡ್ ನಮೂದಿಸಿ, ನಂತರ ಕನಿಷ್ಠ 6 ಅಕ್ಷರಗಳ ಹೊಸ ಪಾಸ್‌ವರ್ಡ್ ಅನ್ನು ಎರಡು ಬಾರಿ ನಮೂದಿಸಿ. ಇಂಟರ್ನೆಟ್ ಬೇಕು. ಹೊಸ ಪಾಸ್‌ವರ್ಡ್ ದೃಢಪಟ್ಟ ನಂತರ ಡ್ಯಾಶ್‌ಬೋರ್ಡ್ ತೆರೆಯುತ್ತದೆ.';

  @override
  String get authSaveNewPassword => 'ಹೊಸ ಪಾಸ್‌ವರ್ಡ್ ಉಳಿಸಿ';

  @override
  String get authSignOut => 'ಸೈನ್ ಔಟ್';

  @override
  String get authTemporaryCredentialField => 'ತಾತ್ಕಾಲಿಕ ಕೋಡ್. ಮರೆಮಾಡಿದ ನಮೂದು.';

  @override
  String get authNewPasswordField =>
      'ಹೊಸ ಪಾಸ್‌ವರ್ಡ್. ಕನಿಷ್ಠ 6 ಅಕ್ಷರಗಳು. ಮರೆಮಾಡಿದ ನಮೂದು.';

  @override
  String get authRepeatNewPasswordField =>
      'ಹೊಸ ಪಾಸ್‌ವರ್ಡ್ ಮತ್ತೆ ನಮೂದಿಸಿ. ಮರೆಮಾಡಿದ ನಮೂದು.';

  @override
  String get authSaveNewPasswordButton => 'ಹೊಸ ಪಾಸ್‌ವರ್ಡ್ ಉಳಿಸಿ, ಬಟನ್';

  @override
  String get authSignOutConfirmButton => 'ಸೈನ್ ಔಟ್, ದೃಢೀಕರಣ ಕೇಳುತ್ತದೆ';

  @override
  String get authChangePasswordTitle => 'ಪಾಸ್‌ವರ್ಡ್ ಬದಲಾಯಿಸಿ';

  @override
  String get authChangePasswordInfo =>
      'ನಿಮ್ಮ ಶಾಲಾ ನಿರ್ವಾಹಕರು ತಾತ್ಕಾಲಿಕ ಕೋಡ್ ನೀಡಿದ್ದಾರೆ. ಅದು 24 ಗಂಟೆ ಇರುತ್ತದೆ. 10 ತಪ್ಪು ಪ್ರಯತ್ನಗಳ ನಂತರ, ಸೈನ್ ಇನ್ 15 ನಿಮಿಷ ನಿಲ್ಲುತ್ತದೆ. ಕನಿಷ್ಠ 6 ಅಕ್ಷರಗಳ ಬೇರೆ ಪಾಸ್‌ವರ್ಡ್ ಆಯ್ಕೆ ಮಾಡಿ. ಇದಕ್ಕೆ ಇಂಟರ್ನೆಟ್ ಬೇಕು.';

  @override
  String get authSignOutKey => '0: ಸೈನ್ ಔಟ್';

  @override
  String authSimOptionValid(String label, String digits) {
    return '$label. ಫೋನ್ ಸಂಖ್ಯೆ $digits. ಫೋನ್ ಕ್ಷೇತ್ರ ತುಂಬಲು ಓಕೆ ಒತ್ತಿ.';
  }

  @override
  String authSimOptionInvalid(String label) {
    return '$label. ಸಂಖ್ಯೆ ಲಭ್ಯವಿಲ್ಲ. ಫೋನ್ ಸಂಖ್ಯೆಯನ್ನು ನೀವೇ ನಮೂದಿಸಿ.';
  }

  @override
  String get authSimInvalidSuggestion =>
      'ಈ SIM ಸರಿಯಾದ ಫೋನ್ ಸಂಖ್ಯೆ ಸಲಹೆ ನೀಡುವುದಿಲ್ಲ. ನೀವೇ ನಮೂದಿಸುವುದು ಇನ್ನೂ ಸಾಧ್ಯ.';

  @override
  String get authSimChooseScreenName =>
      'ಐಚ್ಛಿಕ SIM ಸಲಹೆಯನ್ನು ಆಯ್ಕೆ ಮಾಡಿ. ಪ್ರತಿ SIM ಕೇಳಲು ಮೇಲೆ ಮತ್ತು ಕೆಳಗೆ ಬಳಸಿ, ನಂತರ ಆಯ್ಕೆ ಮಾಡಲು ಓಕೆ ಒತ್ತಿ. ಇದು ಖಾತೆ ಪರಿಶೀಲನೆಯಲ್ಲ.';

  @override
  String get authSimCancelLabel => 'ಫೋನ್ ಸಂಖ್ಯೆ ಬದಲಾಯಿಸದೆ ರದ್ದುಮಾಡಿ';

  @override
  String get authSimChooseTitle => 'SIM ಸಲಹೆ ಆಯ್ಕೆ ಮಾಡಿ';

  @override
  String get authSimChooseInfo =>
      'ಆಯ್ಕೆ ಮಾಡಿದರೆ ಫೋನ್ ಕ್ಷೇತ್ರ ಮಾತ್ರ ತುಂಬುತ್ತದೆ. ನಿಮ್ಮ ಪಾಸ್‌ವರ್ಡ್ ಇನ್ನೂ ಬೇಕು. ರದ್ದುಮಾಡಿದರೆ ನೀವು ನಮೂದಿಸಿದ್ದು ಬದಲಾಗುವುದಿಲ್ಲ.';

  @override
  String get authSimCancelKey => '0: ರದ್ದುಮಾಡಿ';

  @override
  String get inviteStatusInvited => 'ಆಹ್ವಾನಿಸಲಾಗಿದೆ';

  @override
  String get inviteStatusNotInvited => 'ಆಹ್ವಾನಿಸಿಲ್ಲ. ಆಹ್ವಾನಿಸಲು ಓಕೆ';

  @override
  String get inviteTitle => 'ವಿದ್ಯಾರ್ಥಿಗಳನ್ನು ಆಹ್ವಾನಿಸಿ';

  @override
  String get inviteTooltipBack => '0: ಸೆಷನ್‌ಗೆ ಹಿಂತಿರುಗಿ';

  @override
  String get inviteTooltipRefresh => '1: ವಿದ್ಯಾರ್ಥಿ ಪಟ್ಟಿಯನ್ನು ರಿಫ್ರೆಶ್ ಮಾಡಿ';

  @override
  String get inviteInvitingTo => 'ಇಲ್ಲಿಗೆ ವಿದ್ಯಾರ್ಥಿಗಳನ್ನು ಆಹ್ವಾನಿಸಲಾಗುತ್ತಿದೆ:';

  @override
  String inviteInvitedCount(String invited, String total) {
    return '$total ರಲ್ಲಿ $invited ಆಹ್ವಾನಿಸಲಾಗಿದೆ';
  }

  @override
  String get inviteAllButton => '2: ಎಲ್ಲಾ ವಿದ್ಯಾರ್ಥಿಗಳನ್ನು ಆಹ್ವಾನಿಸಿ';

  @override
  String get inviteSearchField => 'ಹೆಸರು ಅಥವಾ ಫೋನ್ ಸಂಖ್ಯೆಯಿಂದ ಹುಡುಕಿ';

  @override
  String get inviteSearchHelper => 'ಎಲ್ಲಾ ವಿದ್ಯಾರ್ಥಿಗಳ ಪಟ್ಟಿಗೆ ಖಾಲಿ ಬಿಡಿ';

  @override
  String get inviteLoadingStudents => 'ವಿದ್ಯಾರ್ಥಿಗಳನ್ನು ಲೋಡ್ ಮಾಡಲಾಗುತ್ತಿದೆ';

  @override
  String get inviteNoMatchShort =>
      'ಯಾವ ವಿದ್ಯಾರ್ಥಿಯೂ ಹೊಂದುತ್ತಿಲ್ಲ. ಎಲ್ಲರ ಪಟ್ಟಿಗೆ ಹುಡುಕಾಟವನ್ನು ತೆರವುಗೊಳಿಸಿ.';

  @override
  String get libraryUploadTitleField => 'ಶೀರ್ಷಿಕೆ *';

  @override
  String get libraryUploadDescriptionField => 'ವಿವರಣೆ';

  @override
  String get libraryCancelKey0Button => 'ರದ್ದುಮಾಡಿ (0)';

  @override
  String get libraryUploadKey3Button => 'ಅಪ್‌ಲೋಡ್ (3)';

  @override
  String get libraryConfirmKey1Button => 'ದೃಢೀಕರಿಸಿ (1)';

  @override
  String librarySessionNumber(String id) {
    return 'ಸೆಷನ್ #$id';
  }

  @override
  String get libraryKey5PauseForClass => '5: ತರಗತಿಗಾಗಿ ವಿರಾಮಗೊಳಿಸಿ';

  @override
  String get libraryKey5PlayForClass => '5: ತರಗತಿಗಾಗಿ ಪ್ಲೇ ಮಾಡಿ';

  @override
  String get libraryRecordingsSeekKeysHint =>
      '4: 10 ಸೆಕೆಂಡ್ ಹಿಂದೆ. 6: 10 ಸೆಕೆಂಡ್ ಮುಂದೆ.';

  @override
  String get libraryKey1ChooseRecording => '1: ರೆಕಾರ್ಡಿಂಗ್ ಆಯ್ಕೆಮಾಡಿ';

  @override
  String get libraryUploadingButton => 'ಅಪ್‌ಲೋಡ್ ಆಗುತ್ತಿದೆ';

  @override
  String get libraryKey2Upload => '2: ಅಪ್‌ಲೋಡ್';

  @override
  String get libraryRecordingsFooterKeysHint =>
      '3: ಸ್ಥಿತಿ. *: ಸಹಾಯ. #: ಧ್ವನಿ ನಿಲ್ಲಿಸಿ.';

  @override
  String get notesBackStopsRecording =>
      'ಹಿಂದೆ. ಮೊದಲು ಯಾವುದೇ ರೆಕಾರ್ಡಿಂಗ್ ನಿಲ್ಲಿಸುತ್ತದೆ';

  @override
  String get notesReadRules => 'ಟಿಪ್ಪಣಿ ನಿಯಮಗಳನ್ನು ಓದಿ';

  @override
  String get notesRefreshPrivate => 'ಖಾಸಗಿ ಟಿಪ್ಪಣಿಗಳನ್ನು ರಿಫ್ರೆಶ್ ಮಾಡಿ';

  @override
  String get notesRecordAsksFirst =>
      'ಖಾಸಗಿ ಟಿಪ್ಪಣಿ ರೆಕಾರ್ಡ್ ಮಾಡಿ. ಮೊದಲು ಹೆಸರು ಮತ್ತು ದೃಢೀಕರಣ ಕೇಳುತ್ತದೆ';

  @override
  String get notesStopRecordingNow => 'ಈಗ ರೆಕಾರ್ಡಿಂಗ್ ನಿಲ್ಲಿಸಿ';

  @override
  String get notesReadRecordingTimeStops =>
      'ರೆಕಾರ್ಡಿಂಗ್ ಸಮಯ ಓದಿ. ಗಟ್ಟಿಯಾಗಿ ಓದಿದರೆ ರೆಕಾರ್ಡಿಂಗ್ ನಿಲ್ಲುತ್ತದೆ';

  @override
  String get notesReadPrivateStatus => 'ಖಾಸಗಿ ಟಿಪ್ಪಣಿ ಸ್ಥಿತಿ ಓದಿ';

  @override
  String get notesStopPrivateReview => 'ಖಾಸಗಿ ಪರಿಶೀಲನೆ ನಿಲ್ಲಿಸಿ';

  @override
  String notesStopReviewingTitle(String title) {
    return '$title ಪರಿಶೀಲನೆ ನಿಲ್ಲಿಸಿ';
  }

  @override
  String get notesStopReviewingNote => 'ಟಿಪ್ಪಣಿ ಪರಿಶೀಲನೆ ನಿಲ್ಲಿಸಿ';

  @override
  String notesReviewTitlePrivately(String title, String duration) {
    return '$title ಅನ್ನು ಖಾಸಗಿಯಾಗಿ ಪರಿಶೀಲಿಸಿ. $duration.';
  }

  @override
  String notesReviewTitleIncomplete(String title) {
    return '$title ಅನ್ನು ಖಾಸಗಿಯಾಗಿ ಪರಿಶೀಲಿಸಿ. ಅಪೂರ್ಣ ರೆಕಾರ್ಡಿಂಗ್; ಪ್ಲೇ ಮಾಡಲು ಸಾಧ್ಯವಿಲ್ಲ.';
  }

  @override
  String notesRenameTitle(String title) {
    return '$title ಮರುಹೆಸರಿಸಿ';
  }

  @override
  String notesPublishTitleAsks(String title) {
    return 'ಪರಿಶೀಲಿಸಿದ $title ಅನ್ನು ತರಗತಿ ಮತ್ತು ವಿಷಯಕ್ಕೆ ಪ್ರಕಟಿಸಿ, ದೃಢೀಕರಿಸಲು ಕೇಳುತ್ತದೆ';
  }

  @override
  String notesRemoveTitleAsks(String title) {
    return '$title ತೆಗೆದುಹಾಕಿ, ದೃಢೀಕರಿಸಲು ಕೇಳುತ್ತದೆ';
  }

  @override
  String get notesScreenName => 'ಖಾಸಗಿ ಟಿಪ್ಪಣಿಗಳು';

  @override
  String get notesIntroduction =>
      'ಟಿಪ್ಪಣಿಗಳನ್ನು ಹೇಗೆ ಇಡಲಾಗುತ್ತದೆ ಎಂದು ಕೇಳಲು ಟಿಪ್ಪಣಿ ನಿಯಮಗಳನ್ನು ಓದಿ ಬಳಸಿ.';

  @override
  String get notesBack => 'ಹಿಂದೆ';

  @override
  String notesStorageSummary(String megabytes) {
    return '$megabytes / 10 MB ಖಾಸಗಿ ಟಿಪ್ಪಣಿಗಳು. ಪಾಠ ಡೌನ್‌ಲೋಡ್‌ಗಳಿಂದ ಪ್ರತ್ಯೇಕ. ಸ್ವಯಂಚಾಲಿತವಾಗಿ ಅಳಿಸುವುದಿಲ್ಲ.';
  }

  @override
  String notesLessonContext(String title, String seconds) {
    return '$title. ಸೆರೆಹಿಡಿದ ಪಾಠದ ಸ್ಥಾನ: $seconds ಸೆಕೆಂಡುಗಳು.';
  }

  @override
  String notesRecordingTime(String time) {
    return 'ರೆಕಾರ್ಡಿಂಗ್ ಸಮಯ $time';
  }

  @override
  String get notesRefreshNotes => 'ಟಿಪ್ಪಣಿಗಳನ್ನು ರಿಫ್ರೆಶ್ ಮಾಡಿ';

  @override
  String get notesRecordPrivateNote => 'ಖಾಸಗಿ ಟಿಪ್ಪಣಿ ರೆಕಾರ್ಡ್ ಮಾಡಿ';

  @override
  String get notesStopRecording => 'ರೆಕಾರ್ಡಿಂಗ್ ನಿಲ್ಲಿಸಿ';

  @override
  String get notesReadRecordingTime => 'ರೆಕಾರ್ಡಿಂಗ್ ಸಮಯ ಓದಿ';

  @override
  String get notesReadNoteStatus => 'ಟಿಪ್ಪಣಿ ಸ್ಥಿತಿ ಓದಿ';

  @override
  String get notesStatusNeedsAttention => 'ಗಮನ ಬೇಕು';

  @override
  String get notesStatusIncomplete => 'ಅಪೂರ್ಣ';

  @override
  String get notesStatusPlaying => 'ಪ್ಲೇ ಆಗುತ್ತಿದೆ';

  @override
  String get notesStatusReviewed => 'ಪರಿಶೀಲಿಸಲಾಗಿದೆ';

  @override
  String get notesStatusSaved => 'ಉಳಿಸಲಾಗಿದೆ';

  @override
  String notesNoteSeconds(String seconds) {
    return '$seconds ಸೆಕೆಂಡುಗಳು. ಖಾಸಗಿ ಸ್ಥಳೀಯ ಟಿಪ್ಪಣಿ.';
  }

  @override
  String get notesNoteIncomplete =>
      'ಅಡಚಣೆಯಾದ ಅಥವಾ ಅಪೂರ್ಣ ಟಿಪ್ಪಣಿ. ಪ್ಲೇ ಅಥವಾ ಪ್ರಕಟಿಸಲು ಸಾಧ್ಯವಿಲ್ಲ.';

  @override
  String notesNoteLessonPoint(String lesson, String seconds) {
    return 'ಪಾಠ $lesson, ಸ್ಥಾನ $seconds ಸೆಕೆಂಡುಗಳು.';
  }

  @override
  String get notesReviewPlaying => 'ಪರಿಶೀಲನೆ ಪ್ಲೇ ಆಗುತ್ತಿದೆ';

  @override
  String get notesReviewPrivately => 'ಖಾಸಗಿಯಾಗಿ ಪರಿಶೀಲಿಸಿ';

  @override
  String get notesRename => 'ಮರುಹೆಸರಿಸಿ';

  @override
  String get notesPublishReviewedNote => 'ಪರಿಶೀಲಿಸಿದ ಟಿಪ್ಪಣಿ ಪ್ರಕಟಿಸಿ';

  @override
  String get notesEnterNameBeforeSaving => 'ಉಳಿಸುವ ಮೊದಲು ಹೆಸರು ನಮೂದಿಸಿ.';

  @override
  String notesNameDialogInstructions(String title) {
    return '$title. ಓಕೆ ಒತ್ತಿದರೆ ಸಂಪಾದನೆ ಶುರುವಾಗುತ್ತದೆ. ಮೇಲೆ ಅಥವಾ ಕೆಳಗೆ ಒತ್ತಿದರೆ ಸಂಪಾದನೆಯಿಂದ ಹೊರಬರುತ್ತದೆ, ನಂತರ ಉಳಿಸಿ ಅಥವಾ ರದ್ದುಮಾಡಿ ಆಯ್ಕೆಮಾಡಿ.';
  }

  @override
  String get notesNoteName => 'ಟಿಪ್ಪಣಿ ಹೆಸರು';

  @override
  String get notesSaveNoteName => 'ಟಿಪ್ಪಣಿ ಹೆಸರು ಉಳಿಸಿ';

  @override
  String get notesCancel => 'ರದ್ದುಮಾಡಿ';

  @override
  String get notesSaveName => 'ಹೆಸರು ಉಳಿಸಿ';

  @override
  String notesWorkspaceLabel(String className, String subjectName) {
    return '$className, $subjectName';
  }

  @override
  String get notesChooseWorkspaceInstructions =>
      'ಪ್ರಕಟಿಸುವ ಮೊದಲು ಅನುಮತಿ ಇರುವ ತರಗತಿ ಮತ್ತು ವಿಷಯವನ್ನು ಆಯ್ಕೆಮಾಡಿ. ಮುಂದಿನ ದೃಢೀಕರಣದವರೆಗೆ ಏನನ್ನೂ ಅಪ್‌ಲೋಡ್ ಮಾಡುವುದಿಲ್ಲ.';

  @override
  String get notesCancelPublication => 'ಪ್ರಕಟಣೆ ರದ್ದುಮಾಡಿ';

  @override
  String get notesPublishWhichWorkspace => 'ಯಾವ ಕಾರ್ಯಸ್ಥಳಕ್ಕೆ ಪ್ರಕಟಿಸಬೇಕು?';

  @override
  String settingsDecrease(String setting) {
    return '$setting ಕಡಿಮೆ ಮಾಡಿ';
  }

  @override
  String settingsIncrease(String setting) {
    return '$setting ಹೆಚ್ಚಿಸಿ';
  }

  @override
  String get settingsResetTooltip => 'ಮೂಲ ಸ್ಥಿತಿಗೆ ಮರುಹೊಂದಿಸಿ';

  @override
  String get settingsSectionSpeech => 'ಮಾತು';

  @override
  String get settingsAppSpeechTitle => 'ಆ್ಯಪ್ ಧ್ವನಿ';

  @override
  String get settingsAppSpeechSubtitle =>
      'ಆ್ಯಪ್ ಪರದೆಗಳು ಮತ್ತು ಸಂದೇಶಗಳನ್ನು ಓದಿ ಹೇಳುತ್ತದೆ';

  @override
  String settingsLanguageButton(String language) {
    return 'ಮಾತಿನ ಭಾಷೆ: $language';
  }

  @override
  String get settingsVolumeTitle => 'ವಾಲ್ಯೂಮ್';

  @override
  String get settingsVolumeSubtitle => 'ಆ್ಯಪ್ ಧ್ವನಿ ಎಷ್ಟು ಜೋರಾಗಿರಬೇಕು';

  @override
  String settingsPercentValue(String percent) {
    return '$percent ಪ್ರತಿಶತ';
  }

  @override
  String get settingsSpeedTitle => 'ಮಾತಿನ ವೇಗ';

  @override
  String get settingsSpeedSubtitle =>
      'ಆ್ಯಪ್ ಧ್ವನಿ ಎಷ್ಟು ವೇಗವಾಗಿರಬೇಕು. ಕ್ವಿಜ್‌ಗಳು ತಮ್ಮದೇ ವೇಗ ಬಳಸಬಹುದು';

  @override
  String settingsTimesNormal(String speed) {
    return 'ಸಾಮಾನ್ಯಕ್ಕಿಂತ $speed ಪಟ್ಟು';
  }

  @override
  String get settingsTestButton => '5: ಧ್ವನಿ ಪರೀಕ್ಷಿಸಿ';

  @override
  String settingsNarrationButton(String level) {
    return 'ನಿರೂಪಣೆಯ ಮಟ್ಟ: $level';
  }

  @override
  String settingsCheckingVoice(String language) {
    return '$language ಧ್ವನಿ ಪರಿಶೀಲಿಸಲಾಗುತ್ತಿದೆ...';
  }

  @override
  String settingsCheckVoiceButton(String language) {
    return '7: $language ಧ್ವನಿ ಪರಿಶೀಲಿಸಿ';
  }

  @override
  String get settingsStopButton => '#: ಮಾತು ನಿಲ್ಲಿಸಿ';

  @override
  String get settingsSectionDisplay => 'ಪ್ರದರ್ಶನ';

  @override
  String get settingsHighContrastTitle => 'ಹೈ ಕಾಂಟ್ರಾಸ್ಟ್';

  @override
  String get settingsHighContrastSubtitle =>
      'ಮೊದಲಿನಿಂದ ಆನ್: ಕಡಿಮೆ ದೃಷ್ಟಿ ಇರುವವರಿಗೆ ಕಪ್ಪು ಹಿನ್ನೆಲೆಯಲ್ಲಿ ಬಿಳಿ ಮತ್ತು ಹಳದಿ';

  @override
  String get settingsTextSizeTitle => 'ಅಕ್ಷರದ ಗಾತ್ರ';

  @override
  String get settingsTextSizeSubtitle =>
      'ಆ್ಯಪ್ ಅಕ್ಷರದ ಗಾತ್ರ; ಫೋನ್‌ನ ಅಕ್ಷರ ಗಾತ್ರದ ಸೆಟ್ಟಿಂಗ್ ಅನ್ನೂ ಪಾಲಿಸಲಾಗುತ್ತದೆ';

  @override
  String get settingsSectionKeys => 'ಕೀಗಳು ಮತ್ತು ಸಹಾಯ';

  @override
  String get settingsShortcutsTitle => 'ಕೀಪ್ಯಾಡ್ ಶಾರ್ಟ್‌ಕಟ್‌ಗಳನ್ನು ತೋರಿಸಿ';

  @override
  String get settingsShortcutsSubtitle => 'ಬಟನ್‌ಗಳ ಮೇಲೆ ಕೀ ಸಂಖ್ಯೆಗಳನ್ನು ತೋರಿಸಿ';

  @override
  String get settingsGlobalKeysHint =>
      'ಪ್ರತಿ ಪರದೆಯಲ್ಲಿ: 0 ಹಿಂದೆ, ಸ್ಟಾರ್ ಸಹಾಯ, ಹ್ಯಾಶ್ ಮಾತು ನಿಲ್ಲಿಸುತ್ತದೆ.';

  @override
  String get settingsVoiceCommandsTitle => 'ಧ್ವನಿ ಆದೇಶಗಳು';

  @override
  String get settingsVoiceCommandsSubtitle =>
      'ಸೆಷನ್‌ಗಳಲ್ಲಿ \'ಆದೇಶಕ್ಕಾಗಿ ಆಲಿಸಿ\' ಆನ್ ಮಾಡಿ. ತಾನಾಗಿಯೇ ಆಲಿಸುವುದಿಲ್ಲ.';

  @override
  String get settingsSoundCuesTitle => '8: ಧ್ವನಿ ಸೂಚನೆಗಳು';

  @override
  String get settingsVibrationTitle => '9: ಕಂಪನ';

  @override
  String get settingsVoiceHelpButton =>
      'ಧ್ವನಿ ಆದೇಶ ಸಹಾಯ: ಮ್ಯೂಟ್, ಅನ್‌ಮ್ಯೂಟ್, ಕೈ ಎತ್ತಿ, ಕೈ ಇಳಿಸಿ, ಹೊರಹೋಗಿ ಅಥವಾ ಮತ್ತೆ ಹೇಳಿ ಎಂದು ಹೇಳಿ.';

  @override
  String get uiSave => 'ಉಳಿಸಿ';

  @override
  String get uiClose => 'ಮುಚ್ಚಿ';

  @override
  String get learningLessonPositionLabel => 'ಪಾಠದ ಸ್ಥಾನ';

  @override
  String get learningReadStatusButton => 'ಕಲಿಕೆಯ ಸ್ಥಿತಿ ಓದಿ';

  @override
  String get learningAddBookmarkButton => 'ಬುಕ್‌ಮಾರ್ಕ್ ಸೇರಿಸಿ';

  @override
  String learningBookmarksButton(String count) {
    return 'ಬುಕ್‌ಮಾರ್ಕ್‌ಗಳು ($count)';
  }

  @override
  String get learningPrivateNotesButton => 'ಖಾಸಗಿ ಅಧ್ಯಯನ ಟಿಪ್ಪಣಿಗಳು';

  @override
  String get learningSetAButton => 'A ಹೊಂದಿಸಿ';

  @override
  String learningSetAAtButton(String time) {
    return 'A ಹೊಂದಿಸಿ $time';
  }

  @override
  String get learningSetBButton => 'B ಹೊಂದಿಸಿ';

  @override
  String learningSetBAtButton(String time) {
    return 'B ಹೊಂದಿಸಿ $time';
  }

  @override
  String get learningRepeatOffButton => 'ಪುನರಾವರ್ತನೆ ಆಫ್';

  @override
  String get learningRepeatOnButton => 'ಪುನರಾವರ್ತನೆ ಆನ್';

  @override
  String get learningClearABButton => 'A-B ತೆರವುಗೊಳಿಸಿ';

  @override
  String learningBackTenButton(String key) {
    return '$key: 10 ಸೆಕೆಂಡ್ ಹಿಂದೆ';
  }

  @override
  String learningForwardTenButton(String key) {
    return '$key: 10 ಸೆಕೆಂಡ್ ಮುಂದೆ';
  }

  @override
  String learningSlowerButton(String key) {
    return '$key: ನಿಧಾನ';
  }

  @override
  String learningFasterButton(String key) {
    return '$key: ವೇಗ';
  }

  @override
  String get learningRetrySavingButton => 'ಉಳಿಸಲು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ';

  @override
  String get learningNameBookmarkTitle => 'ಬುಕ್‌ಮಾರ್ಕ್‌ಗೆ ಹೆಸರಿಡಿ';

  @override
  String get learningBookmarkNameFieldLabel => 'ಹೆಸರು';

  @override
  String get learningBookmarksTitle => 'ಬುಕ್‌ಮಾರ್ಕ್‌ಗಳು';

  @override
  String get learningBookmarksLessonChanged =>
      'ಪಾಠ ಬದಲಾಗಿದೆ. ಈ ಪಟ್ಟಿಯನ್ನು ಮುಚ್ಚಿ, ಈಗಿನ ಪಾಠದ ಬುಕ್‌ಮಾರ್ಕ್‌ಗಳನ್ನು ತೆರೆಯಿರಿ.';

  @override
  String get learningBookmarksEmpty =>
      'ಇನ್ನೂ ಬುಕ್‌ಮಾರ್ಕ್‌ಗಳಿಲ್ಲ. ನೆನಪಿಡಲು ಬಯಸುವ ಸ್ಥಾನದಲ್ಲಿ ಬುಕ್‌ಮಾರ್ಕ್ ಸೇರಿಸಿ ಬಳಸಿ.';

  @override
  String get learningBookmarksUnavailable =>
      'ಉಳಿಸಿದ ಬುಕ್‌ಮಾರ್ಕ್‌ಗಳು ಲಭ್ಯವಿಲ್ಲ. ಉಳಿಸಿದ ಪ್ರಗತಿಯನ್ನು ಮತ್ತೆ ಪಡೆಯಲು ಉಳಿಸಲು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String learningBookmarkAtButton(String label, String time) {
    return '$time ನಲ್ಲಿ $label';
  }

  @override
  String learningRemoveBookmarkSemantics(String label) {
    return 'ಬುಕ್‌ಮಾರ್ಕ್ $label ತೆಗೆದುಹಾಕಿ';
  }

  @override
  String uiKeyedLabel(String key, String label) {
    return '$key: $label';
  }

  @override
  String get uiKeypadFooter => '*: ಸಹಾಯ. #: ಆ್ಯಪ್ ಧ್ವನಿ ನಿಲ್ಲಿಸಿ.';

  @override
  String uiListSearchValue(String query) {
    return 'ಹುಡುಕಾಟ: $query';
  }

  @override
  String get uiListLoadingShort => 'ಲೋಡ್ ಆಗುತ್ತಿದೆ. ಹಿಂದೆ ಹೋಗಲು 0 ಒತ್ತಿ.';

  @override
  String get keypadTextEditingHint =>
      'ಎಡಿಟ್ ಮಾಡುವಾಗ, ಕೀಗಳು ಪಠ್ಯವನ್ನು ನಮೂದಿಸುತ್ತವೆ. ಮುಗಿಸಲು ಓಕೆ ಒತ್ತಿ. ಓಕೆ ಎಡಿಟಿಂಗ್ ಮುಗಿಸದಿದ್ದರೆ ಮೇಲೆ ಅಥವಾ ಕೆಳಗೆ ಬಳಸಿ.';

  @override
  String get keypadWaitingConfirmation => 'ಖಚಿತಪಡಿಸುವಿಕೆಗಾಗಿ ಕಾಯಲಾಗುತ್ತಿದೆ.';

  @override
  String get keypadContinueKey1 => '1: ಮುಂದುವರಿಸಿ';

  @override
  String get keypadHidePasswordKey2 => '2: ಪಾಸ್‌ವರ್ಡ್ ಮರೆಮಾಡಿ';

  @override
  String get keypadShowPasswordKey2 => '2: ಪಾಸ್‌ವರ್ಡ್ ತೋರಿಸಿ';

  @override
  String get keypadBackKey0 => '0: ಹಿಂದೆ';

  @override
  String uiKeyedLabelUnavailable(String number, String label) {
    return '$number: $label (ಲಭ್ಯವಿಲ್ಲ)';
  }

  @override
  String get journeyMenuReadDetailsKey8 => '8: ವಿವರಗಳನ್ನು ಮತ್ತೆ ಓದಿ';

  @override
  String get sessionTileHandRaised => 'ಕೈ ಎತ್ತಿದ್ದಾರೆ';

  @override
  String get sessionTileSpeaking => 'ಮಾತನಾಡುತ್ತಿದ್ದಾರೆ';

  @override
  String sessionRemoveFromSession(String name) {
    return '$name ಅವರನ್ನು ಸೆಷನ್‌ನಿಂದ ತೆಗೆದುಹಾಕಿ';
  }

  @override
  String get classroomConsoleTitle => 'ತರಗತಿ ಕನ್ಸೋಲ್';

  @override
  String get uiHourRange => 'ಗಂಟೆ (0 ರಿಂದ 23)';

  @override
  String get uiSetDateTimeTitle => 'ದಿನಾಂಕ ಮತ್ತು ಸಮಯ ಹೊಂದಿಸಿ';

  @override
  String get uiSetDateTimeHint =>
      'ಸ್ಥಳೀಯ ಸಮಯ ಬಳಸಿ. ಪ್ರತಿ ಸಂಖ್ಯೆಯನ್ನು ಎಡಿಟ್ ಮಾಡಲು ಓಕೆ ಒತ್ತಿ.';

  @override
  String quizExtraTitle(String name) {
    return 'ಹೆಚ್ಚುವರಿ ಸಮಯ: $name';
  }

  @override
  String get quizExtraInfo =>
      'ಮುಂದಿನ ಪ್ರಯತ್ನಗಳಿಗೆ ಮಾತ್ರ. ಈಗಿರುವ ಗಡುವುಗಳು ಬದಲಾಗುವುದಿಲ್ಲ. ಕ್ವಿಜ್ ಮುಚ್ಚುವ ಸಮಯ ಇನ್ನೂ ಅನ್ವಯಿಸುತ್ತದೆ; ಬೇಕಿದ್ದರೆ ಲಭ್ಯತೆಯನ್ನು ಪ್ರತ್ಯೇಕವಾಗಿ ವಿಸ್ತರಿಸಿ. ಸೊನ್ನೆ ಹೆಚ್ಚುವರಿ ನಿಮಿಷಗಳನ್ನು ತೆಗೆದುಹಾಕುತ್ತದೆ.';

  @override
  String get quizExtraMinutesField => 'ಹೆಚ್ಚುವರಿ ನಿಮಿಷಗಳು';

  @override
  String get quizExtraSaveButton => 'ಮುಂದಿನ ಹೆಚ್ಚುವರಿ ಸಮಯ ಉಳಿಸಿ';

  @override
  String quizSpeedValue(String speed) {
    return 'ಕ್ವಿಜ್ ಧ್ವನಿ ವೇಗ: $speed×';
  }

  @override
  String get uiCancelKey0 => '0: ರದ್ದುಮಾಡಿ';

  @override
  String get uiSaveKey1 => '1: ಉಳಿಸಿ';

  @override
  String get uiNone => 'ಯಾವುದೂ ಇಲ್ಲ';

  @override
  String uiPreviousOf(String label) {
    return 'ಹಿಂದಿನ $label';
  }

  @override
  String uiNextOf(String label) {
    return 'ಮುಂದಿನ $label';
  }

  @override
  String get journeyOpening => 'ಪಯಣ ತೆರೆಯಲಾಗುತ್ತಿದೆ';

  @override
  String journeyStepHeading(String position, String kind) {
    return '$position. $kind';
  }

  @override
  String journeyStepHeadingReplay(String position, String kind) {
    return '$position. $kind. ಮತ್ತೆ ಕೇಳಲಾಗುತ್ತಿದೆ';
  }

  @override
  String journeyFirstTryShort(String correct, String total) {
    return 'ಮೊದಲ ಪ್ರಯತ್ನದಲ್ಲಿ $total ರಲ್ಲಿ $correct ಸರಿ.';
  }

  @override
  String get journeyLeaveKey0 => '0: ಪಯಣದಿಂದ ಹೊರಬನ್ನಿ';

  @override
  String get quizRevisionsTitle => 'ಪ್ರಶ್ನೆ ಪರಿಷ್ಕರಣೆಗಳು';

  @override
  String get quizRevisionsBackTooltip => 'ಪ್ರಶ್ನೆ ಪರಿಷ್ಕರಣೆಗಳಿಂದ ಹಿಂದೆ ಹೋಗಿ';

  @override
  String quizRevisionSectionHear(String section) {
    return '$section. ಕೇಳಲು ಎರಡು ಬಾರಿ ಟ್ಯಾಪ್ ಮಾಡಿ';
  }

  @override
  String get adminResetAttested => 'ಗುರುತು ಪರಿಶೀಲನೆಯನ್ನು ದೃಢಪಡಿಸಲಾಗಿದೆ.';

  @override
  String get adminResetNotAttested => 'ಗುರುತು ಪರಿಶೀಲನೆಯನ್ನು ದೃಢಪಡಿಸಿಲ್ಲ.';

  @override
  String get adminResetConfirmTitle => 'ಈ ಪಾಸ್‌ವರ್ಡ್ ಮರುಹೊಂದಿಸಬೇಕೆ?';

  @override
  String adminResetConfirmMessage(String name, String phone) {
    return '$name, ಫೋನ್ $phone ಮರುಹೊಂದಿಸಬೇಕೆ? ಇದು ಹಳೆಯ ಪಾಸ್‌ವರ್ಡ್ ಬದಲಿಸುತ್ತದೆ ಮತ್ತು ಆನ್‌ಲೈನ್ ಸೆಷನ್‌ಗಳನ್ನು ಕೊನೆಗೊಳಿಸುತ್ತದೆ. ಸಂಪರ್ಕವಿಲ್ಲದ ಡೌನ್‌ಲೋಡ್ ಮಾಡಿದ ಪಾಠಗಳನ್ನು ತಕ್ಷಣ ಹಿಂಪಡೆಯಲು ಸಾಧ್ಯವಿಲ್ಲ. ಈಗಿರುವ ಪಾಠಗಳು, ಟಿಪ್ಪಣಿಗಳು ಮತ್ತು ಕಲಿಕೆಯ ದಾಖಲೆಗಳು ಉಳಿಯುತ್ತವೆ. 12 ಅಂಕಿಯ ತಾತ್ಕಾಲಿಕ ಕೋಡ್ 24 ಗಂಟೆ ಇರುತ್ತದೆ ಮತ್ತು ಪಾಸ್‌ವರ್ಡ್ ಬದಲಾವಣೆ ಅಗತ್ಯ. 10 ತಪ್ಪು ಪ್ರಯತ್ನಗಳ ನಂತರ, ತಾತ್ಕಾಲಿಕ ಕೋಡ್ ಸೈನ್ ಇನ್ 15 ನಿಮಿಷ ತಡೆಹಿಡಿಯಲಾಗುತ್ತದೆ.';
  }

  @override
  String get adminResetKeepPassword => 'ಪಾಸ್‌ವರ್ಡ್ ಇರಿಸಿಕೊಳ್ಳಿ';

  @override
  String get adminResetResetPassword => 'ಪಾಸ್‌ವರ್ಡ್ ಮರುಹೊಂದಿಸಿ';

  @override
  String get adminResetSignInChanged =>
      'ನಿರ್ವಾಹಕರ ಸೈನ್ ಇನ್ ಬದಲಾಗಿದೆ. ಯಾವುದೇ ಮರುಹೊಂದಿಕೆ ಕಳುಹಿಸಿಲ್ಲ.';

  @override
  String get adminResetSending =>
      'ಮರುಹೊಂದಿಕೆ ಕಳುಹಿಸಲಾಗುತ್ತಿದೆ. ಸರ್ವರ್ ದೃಢೀಕರಣಕ್ಕಾಗಿ ಕಾಯಲಾಗುತ್ತಿದೆ.';

  @override
  String adminResetNotConfirmed(String reason) {
    return 'ಮರುಹೊಂದಿಕೆ ದೃಢೀಕರಿಸಿಲ್ಲ. $reason ಇದು ಈಗಾಗಲೇ ಜಾರಿಯಾಗಿರಬಹುದು. ಇನ್ನೊಂದು ಮರುಹೊಂದಿಕೆ ಯೋಚಿಸುವ ಮೊದಲು ಮುಚ್ಚಿ ಈ ಖಾತೆಯನ್ನು ರಿಫ್ರೆಶ್ ಮಾಡಿ.';
  }

  @override
  String get adminResetResponseNotVerified =>
      'ಮರುಹೊಂದಿಕೆಯ ಪ್ರತಿಕ್ರಿಯೆಯನ್ನು ಪರಿಶೀಲಿಸಲು ಆಗಲಿಲ್ಲ. ಪಾಸ್‌ವರ್ಡ್ ಈಗಾಗಲೇ ಬದಲಾಗಿರಬಹುದು. ಇನ್ನೊಂದು ಮರುಹೊಂದಿಕೆ ಯೋಚಿಸುವ ಮೊದಲು ಮುಚ್ಚಿ ರಿಫ್ರೆಶ್ ಮಾಡಿ.';

  @override
  String get adminResetConfirmedSpoken =>
      'ಪಾಸ್‌ವರ್ಡ್ ಮರುಹೊಂದಿಕೆ ದೃಢೀಕರಿಸಲಾಗಿದೆ. ಕೋಡ್ ಮರೆಮಾಡಲಾಗಿದೆ. ಖಾಸಗಿಯಾಗಿದ್ದಾಗ ಮಾತ್ರ ಕೋಡ್ ಓದಿ ಬಳಸಿ. ಮುಚ್ಚಿದರೆ ಈ ಪ್ರತಿ ತಿರಸ್ಕರಿಸಲಾಗುತ್ತದೆ.';

  @override
  String get adminResetPhoneNotConfirmed =>
      'ಈ ಫೋನ್‌ನಲ್ಲಿ ಮರುಹೊಂದಿಕೆ ದೃಢೀಕರಿಸಲು ಆಗಲಿಲ್ಲ. ಇನ್ನೊಂದು ಮರುಹೊಂದಿಕೆ ಯೋಚಿಸುವ ಮೊದಲು ಮುಚ್ಚಿ ಖಾತೆಯನ್ನು ರಿಫ್ರೆಶ್ ಮಾಡಿ.';

  @override
  String get adminResetStorageUnavailable =>
      'ಖಾತೆ ಸಂಗ್ರಹಣೆ ಲಭ್ಯವಿಲ್ಲ. ಮರುಹೊಂದಿಕೆ ಯೋಚಿಸುವ ಮೊದಲು ಮರುಪಡೆಯುವಿಕೆ ಮುಚ್ಚಿ SEEDS ಮರುಪ್ರಾರಂಭಿಸಿ.';

  @override
  String adminResetCredentialSpoken(String digits, String expires) {
    return 'ತಾತ್ಕಾಲಿಕ ಕೋಡ್: $digits. $expires, UTC ಕ್ಕೆ ಅವಧಿ ಮುಗಿಯುತ್ತದೆ. ಪರಿಶೀಲಿಸಿದ ವ್ಯಕ್ತಿಗೆ ಖಾಸಗಿಯಾಗಿ ತಲುಪಿಸಿ. ಸೈನ್ ಇನ್ ಸಮಯದಲ್ಲಿ ಇದನ್ನು ಬದಲಿಸಬೇಕು.';
  }

  @override
  String get adminResetDiscardTitle => 'ಈ ಕೋಡ್ ಪ್ರತಿಯನ್ನು ತಿರಸ್ಕರಿಸಬೇಕೆ?';

  @override
  String get adminResetDiscardMessage =>
      'ತಾತ್ಕಾಲಿಕ ಕೋಡ್ ಅನ್ನು ಖಾಸಗಿಯಾಗಿ ತಲುಪಿಸಿದ್ದೀರಿ ಎಂದು ದೃಢೀಕರಿಸಿ, ಅಥವಾ ಪರಿಶೀಲಿತ ನಿರ್ವಾಹಕರಿಂದ ಇನ್ನೊಂದು ಮರುಹೊಂದಿಕೆ ಬೇಕಾಗುತ್ತದೆ ಎಂದು ಒಪ್ಪಿಕೊಳ್ಳಿ. SEEDS ಈ ಪ್ರತಿಯನ್ನು ಮತ್ತೆ ತೋರಿಸುವುದಿಲ್ಲ. ಇದು ಪೂರ್ಣಗೊಂಡ ಮರುಹೊಂದಿಕೆಯನ್ನು ರದ್ದುಮಾಡುವುದಿಲ್ಲ.';

  @override
  String get adminResetKeepReviewing => 'ಪರಿಶೀಲನೆ ಮುಂದುವರಿಸಿ';

  @override
  String get adminResetCloseDiscard => 'ಮುಚ್ಚಿ ತಿರಸ್ಕರಿಸಿ';

  @override
  String get adminResetScreenName =>
      'ನಿರ್ವಾಹಕರ ಪಾಸ್‌ವರ್ಡ್ ಮರುಪಡೆಯುವಿಕೆ. ಮರುಹೊಂದಿಸುವ ಮೊದಲು SEEDS ಹೊರಗೆ ಗುರುತು ಪರಿಶೀಲಿಸಿ. ಸ್ಪಷ್ಟವಾಗಿ ಕೇಳುವವರೆಗೆ ಕೋಡ್‌ಗಳನ್ನು ಮರೆಮಾಡಲಾಗುತ್ತದೆ.';

  @override
  String get adminResetCloseRecovery => 'ಮರುಪಡೆಯುವಿಕೆ ಮುಚ್ಚಿ';

  @override
  String get adminResetReadAccount => 'ಆಯ್ಕೆಮಾಡಿದ ಖಾತೆಯ ವಿವರಗಳನ್ನು ಓದಿ';

  @override
  String adminResetAccountDetails(String name, String phone) {
    return '$name. ಫೋನ್ $phone.';
  }

  @override
  String get adminResetIdentityChecked =>
      'SEEDS ಹೊರಗೆ ಗುರುತು ಪರಿಶೀಲಿಸಲಾಗಿದೆ. ಗುರುತು ಹಾಕಲಾಗಿದೆ. ಬದಲಿಸಲು ಓಕೆ ಒತ್ತಿ.';

  @override
  String get adminResetIdentityNotChecked =>
      'SEEDS ಹೊರಗೆ ಗುರುತು ಪರಿಶೀಲಿಸಲಾಗಿದೆ. ಗುರುತು ಹಾಕಿಲ್ಲ. ಬದಲಿಸಲು ಓಕೆ ಒತ್ತಿ.';

  @override
  String get adminResetResetAndEnd =>
      'ಪಾಸ್‌ವರ್ಡ್ ಮರುಹೊಂದಿಸಿ ಮತ್ತು ಆನ್‌ಲೈನ್ ಸೆಷನ್‌ಗಳನ್ನು ಕೊನೆಗೊಳಿಸಿ';

  @override
  String get adminResetReadCredentialLabel =>
      'ತಾತ್ಕಾಲಿಕ ಕೋಡ್ ಓದಿ ಮತ್ತು ತೋರಿಸಿ. ಖಾಸಗಿಯಾಗಿ ಮಾತ್ರ ಬಳಸಿ.';

  @override
  String get adminResetCloseRefresh => 'ಮುಚ್ಚಿ ಖಾತೆಯನ್ನು ರಿಫ್ರೆಶ್ ಮಾಡಿ';

  @override
  String get adminResetTitle => 'ಪಾಸ್‌ವರ್ಡ್ ಮರುಪಡೆಯುವಿಕೆ';

  @override
  String get adminResetVerifyInfo =>
      'SEEDS ಹೊರಗೆ ವ್ಯಕ್ತಿಯನ್ನು ಪರಿಶೀಲಿಸಿ. ಫೋನ್ ಸಂಖ್ಯೆ ಅಥವಾ SIM ಸಲಹೆ ಗುರುತು ಪರಿಶೀಲನೆ ಅಲ್ಲ. ಕೇವಲ ಸಂದೇಶ ಅಥವಾ ಹೇಳಿಕೊಂಡ ಹೆಸರಿನ ಆಧಾರದ ಮೇಲೆ ಎಂದಿಗೂ ಮರುಹೊಂದಿಸಬೇಡಿ.';

  @override
  String get adminResetVerifiedCheckbox =>
      'ನಾನು ಈ ವ್ಯಕ್ತಿಯನ್ನು SEEDS ಹೊರಗೆ ಪರಿಶೀಲಿಸಿದ್ದೇನೆ';

  @override
  String get adminResetWaiting => 'ಮರುಹೊಂದಿಕೆ ದೃಢೀಕರಣಕ್ಕಾಗಿ ಕಾಯಲಾಗುತ್ತಿದೆ.';

  @override
  String get adminResetConfirmedInfo =>
      'ಮರುಹೊಂದಿಕೆ ದೃಢೀಕರಿಸಲಾಗಿದೆ. ಕೇಳುವವರೆಗೆ ಕೋಡ್ ಮರೆಮಾಡಲಾಗಿದೆ. ಇದು 24 ಗಂಟೆ ಮಾನ್ಯವಾಗಿರುತ್ತದೆ. ಮುಚ್ಚಿದರೆ ಈ ಪ್ರತಿ ತಿರಸ್ಕರಿಸಲಾಗುತ್ತದೆ. ಖಾಸಗಿಯಾಗಿ ತಲುಪಿಸಿ; ತರಗತಿಯಲ್ಲಿ ಎಂದಿಗೂ ಹಾಕಬೇಡಿ.';

  @override
  String get adminResetRevealButton => 'ಕೋಡ್ ಅನ್ನು ಖಾಸಗಿಯಾಗಿ ಓದಿ ಮತ್ತು ತೋರಿಸಿ';

  @override
  String adminResetCredentialShown(String digits, String expires) {
    return 'ತಾತ್ಕಾಲಿಕ ಕೋಡ್: $digits\nಅವಧಿ ಮುಗಿಯುವುದು: $expires UTC';
  }

  @override
  String get adminResetCloseRefreshKey0 => '0: ಮುಚ್ಚಿ ಖಾತೆಯನ್ನು ರಿಫ್ರೆಶ್ ಮಾಡಿ';

  @override
  String get apiTemporarySignInPaused =>
      'ತಾತ್ಕಾಲಿಕ ಕೋಡ್ ಸೈನ್ ಇನ್ 15 ನಿಮಿಷ ತಡೆಹಿಡಿಯಲಾಗಿದೆ. ನಂತರ ಪ್ರಯತ್ನಿಸಿ ಅಥವಾ ನಿಮ್ಮ ಶಾಲೆಯ ನಿರ್ವಾಹಕರನ್ನು ಸಂಪರ್ಕಿಸಿ.';

  @override
  String get apiTemporaryCredentialExpired =>
      'ನಿಮ್ಮ ತಾತ್ಕಾಲಿಕ ಕೋಡ್ ಅವಧಿ ಮುಗಿದಿದೆ. ಬದಲಿ ಕೋಡ್‌ಗಾಗಿ ನಿಮ್ಮ ಶಾಲೆಯ ನಿರ್ವಾಹಕರನ್ನು ಸಂಪರ್ಕಿಸಿ.';

  @override
  String get apiPasswordMustDiffer =>
      'ತಾತ್ಕಾಲಿಕ ಕೋಡ್‌ಗಿಂತ ಬೇರೆ ಪಾಸ್‌ವರ್ಡ್ ಆಯ್ಕೆಮಾಡಿ.';

  @override
  String get apiTemporaryCredentialRejected =>
      'ತಾತ್ಕಾಲಿಕ ಕೋಡ್ ಸ್ವೀಕರಿಸಲಾಗಿಲ್ಲ. ಪರಿಶೀಲಿಸಿ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get apiRecoverySignInExpired =>
      'ನಿಮ್ಮ ಮರುಪಡೆಯುವಿಕೆ ಸೈನ್ ಇನ್ ಅವಧಿ ಮುಗಿದಿದೆ ಅಥವಾ ಬದಲಾಗಿದೆ. ಮತ್ತೆ ಸೈನ್ ಇನ್ ಮಾಡಿ.';

  @override
  String get apiCheckInformation =>
      'ದಯವಿಟ್ಟು ಮಾಹಿತಿಯನ್ನು ಪರಿಶೀಲಿಸಿ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get apiInvalidLogin => 'ತಪ್ಪಾದ ಫೋನ್ ಸಂಖ್ಯೆ ಅಥವಾ ಪಾಸ್‌ವರ್ಡ್.';

  @override
  String get apiNoPermission => 'ಅದನ್ನು ಮಾಡಲು ನಿಮಗೆ ಅನುಮತಿ ಇಲ್ಲ.';

  @override
  String get apiSessionNotFound =>
      'ಸೆಷನ್ ಸಿಗಲಿಲ್ಲ. ಸೆಷನ್ ID ಪರಿಶೀಲಿಸಿ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get apiItemNotFound => 'ಕೇಳಿದ ಐಟಂ ಸಿಗಲಿಲ್ಲ.';

  @override
  String get apiServiceUnavailable =>
      'ಸೇವೆ ತಾತ್ಕಾಲಿಕವಾಗಿ ಲಭ್ಯವಿಲ್ಲ. ದಯವಿಟ್ಟು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get apiNetworkFailure =>
      'ಆ ವಿನಂತಿಯನ್ನು ಪೂರ್ಣಗೊಳಿಸಲು ಆಗಲಿಲ್ಲ. ನಿಮ್ಮ ಸಂಪರ್ಕ ಪರಿಶೀಲಿಸಿ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get apiUnknownFailure =>
      'ಆ ವಿನಂತಿಯನ್ನು ಪೂರ್ಣಗೊಳಿಸಲು ಆಗಲಿಲ್ಲ. ದಯವಿಟ್ಟು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get apiAccountChangedRequestNotSent =>
      'ನಿಮ್ಮ ಖಾತೆ ಬದಲಾಗಿದೆ. ಈ ವಿನಂತಿಯನ್ನು ಕಳುಹಿಸಿಲ್ಲ.';

  @override
  String get apiAccountOrSessionChanged =>
      'ನಿಮ್ಮ ಖಾತೆ ಅಥವಾ ಸೆಷನ್ ಬದಲಾಗಿದೆ. ಈ ಕ್ರಿಯೆಯನ್ನು ಕಳುಹಿಸಿಲ್ಲ.';

  @override
  String get apiResponseUnreadable =>
      'ಸೇವೆಯ ಪ್ರತಿಕ್ರಿಯೆಯನ್ನು ಓದಲು ಆಗಲಿಲ್ಲ. ಕ್ರಿಯೆ ತಲುಪಿರಬಹುದು; ಮತ್ತೆ ಪ್ರಯತ್ನಿಸುವ ಮೊದಲು ಅದರ ಸ್ಥಿತಿ ಪರಿಶೀಲಿಸಿ.';

  @override
  String get apiSignInBeforeAction =>
      'ಈ ಕ್ರಿಯೆಯನ್ನು ಕಳುಹಿಸುವ ಮೊದಲು ಮತ್ತೆ ಸೈನ್ ಇನ್ ಮಾಡಿ.';

  @override
  String get apiAccountChangedNotConfirmed =>
      'ನಿಮ್ಮ ಖಾತೆ ಬದಲಾಗಿದೆ. ಈ ಕ್ರಿಯೆಯನ್ನು ದೃಢೀಕರಿಸಲು ಆಗಲಿಲ್ಲ.';

  @override
  String get apiActionNotConfirmed =>
      'ಕ್ರಿಯೆ ದೃಢೀಕರಿಸಲ್ಪಟ್ಟಿಲ್ಲ. ಅದು ತರಗತಿಯನ್ನು ತಲುಪಿರಬಹುದು. ಮತ್ತೆ ಪ್ರಯತ್ನಿಸುವ ಮೊದಲು ಅದರ ಸ್ಥಿತಿ ಪರಿಶೀಲಿಸಿ.';

  @override
  String get apiAccountChangedActionNotSent =>
      'ನಿಮ್ಮ ಖಾತೆ ಬದಲಾಗಿದೆ. ಈ ಕ್ರಿಯೆಯನ್ನು ಕಳುಹಿಸಿಲ್ಲ.';

  @override
  String get apiRequestFailed => 'ವಿನಂತಿ ವಿಫಲವಾಗಿದೆ';

  @override
  String get notificationPrivateTitle => 'SEEDS ಅಪ್‌ಡೇಟ್';

  @override
  String get notificationPrivateBody =>
      'ನಿಮ್ಮ ಅಪ್‌ಡೇಟ್‌ಗಳನ್ನು ನೋಡಲು SEEDS ತೆರೆಯಿರಿ.';

  @override
  String get notificationRegistrationFailed =>
      'ಅಧಿಸೂಚನೆಗಳನ್ನು ನೋಂದಾಯಿಸಲು ಆಗಲಿಲ್ಲ. ತರಗತಿ ಆಹ್ವಾನಗಳನ್ನು ಪರಿಶೀಲಿಸಲು SEEDS ರಿಫ್ರೆಶ್ ಮಾಡಿ.';

  @override
  String get notificationChannelName => 'ಸೆಷನ್ ಅಧಿಸೂಚನೆಗಳು';

  @override
  String get notificationChannelDescription =>
      'ಸೆಷನ್ ಆಹ್ವಾನಗಳು ಮತ್ತು ಅಪ್‌ಡೇಟ್‌ಗಳ ಅಧಿಸೂಚನೆಗಳು';

  @override
  String get notificationDisplayFailed =>
      'ಒಂದು ಅಪ್‌ಡೇಟ್ ಬಂದಿದೆ, ಆದರೆ ಫೋನ್ ಅಧಿಸೂಚನೆಯನ್ನು ತೋರಿಸಲು ಆಗಲಿಲ್ಲ. ಅಪ್‌ಡೇಟ್‌ಗಳನ್ನು ಪರಿಶೀಲಿಸಲು SEEDS ತೆರೆಯಿರಿ.';

  @override
  String get activityCleanupFailed =>
      'ಅವಧಿ ಮುಗಿದ ಚಟುವಟಿಕೆಯನ್ನು ತೆರವುಗೊಳಿಸಲು ಆಗಲಿಲ್ಲ. ಸಾಧನದ ಸಂಗ್ರಹಣೆ ಪರಿಶೀಲಿಸಿ.';

  @override
  String get activitySyncUnavailable =>
      'ಚಟುವಟಿಕೆ ಸಿಂಕ್ ಲಭ್ಯವಿಲ್ಲ. ಕಲಿಕೆ ಇನ್ನೂ ಲಭ್ಯವಿದೆ.';

  @override
  String get activitySignInToSync => 'ಚಟುವಟಿಕೆ ಸಿಂಕ್ ಮಾಡಲು ಸೈನ್ ಇನ್ ಮಾಡಿ.';

  @override
  String get activityQueueFull =>
      'ಚಟುವಟಿಕೆ ಸರತಿ ತುಂಬಿದೆ. ಕೆಲವು ಹಳೆಯ ಕ್ರಿಯೆಗಳನ್ನು ವರದಿ ಮಾಡಲು ಸಾಧ್ಯವಿಲ್ಲ.';

  @override
  String get activityWaitingToSync => 'ಕೆಲವು ಚಟುವಟಿಕೆ ಸಿಂಕ್‌ಗಾಗಿ ಕಾಯುತ್ತಿದೆ.';

  @override
  String get activityRejected =>
      'ಕೆಲವು ಚಟುವಟಿಕೆಯ ಅವಧಿ ಮುಗಿದಿತ್ತು ಅಥವಾ ಇನ್ನು ಅನುಮತಿ ಇರಲಿಲ್ಲ, ಆದ್ದರಿಂದ ಸಿಂಕ್ ಆಗಿಲ್ಲ.';

  @override
  String get authLogoutTitle => 'SEEDS ನಿಂದ ಲಾಗ್ ಔಟ್ ಆಗಬೇಕೇ?';

  @override
  String get authLogoutMessage =>
      'ನೀವು ನಿಮ್ಮ ಫೋನ್ ಸಂಖ್ಯೆ ಮತ್ತು ಪಾಸ್‌ವರ್ಡ್ ಅನ್ನು ಮತ್ತೆ ನಮೂದಿಸಬೇಕಾಗುತ್ತದೆ.';

  @override
  String get authLogoutCancel => 'ರದ್ದುಮಾಡಿ';

  @override
  String get authLogoutConfirm => 'ಲಾಗ್ ಔಟ್';

  @override
  String get authLoggedOut => 'ಲಾಗ್ ಔಟ್ ಆಗಿದೆ.';

  @override
  String get startupLoadingTools =>
      'ಸುಲಭವಾಗಿ ಬಳಸಬಹುದಾದ ಕಲಿಕೆಯ ಉಪಕರಣಗಳು ಲೋಡ್ ಆಗುತ್ತಿವೆ…';

  @override
  String get startupTagline => 'ಎಲ್ಲರನ್ನೂ, ಎಲ್ಲೆಡೆ ಸಂಪರ್ಕಿಸುತ್ತಿದೆ';

  @override
  String get startupLoginKey1 => '1. ಸೈನ್ ಇನ್';

  @override
  String get startupLogin => 'ಸೈನ್ ಇನ್';

  @override
  String get startupRegisterKey2 => '2. ನೋಂದಣಿ';

  @override
  String get startupRegister => 'ನೋಂದಣಿ';

  @override
  String get startupSettings => 'ಸೆಟ್ಟಿಂಗ್‌ಗಳು';

  @override
  String get startupRepeatInstructions => 'ಸೂಚನೆಗಳನ್ನು ಮತ್ತೆ ಕೇಳಿ';

  @override
  String get startupFeatureAudioTitle => 'ನೇರ ಆಡಿಯೋ';

  @override
  String get startupFeatureAudioText => 'ಸ್ಪಷ್ಟವಾದ ಧ್ವನಿ ಸಂವಹನ';

  @override
  String get startupFeatureAccessibleTitle => 'ಎಲ್ಲರೂ ಬಳಸಬಹುದು';

  @override
  String get startupFeatureAccessibleText =>
      'ಧ್ವನಿ, ದೊಡ್ಡ ಬಟನ್‌ಗಳು ಮತ್ತು ಕೀಪ್ಯಾಡ್ ನಿಯಂತ್ರಣ';

  @override
  String get startupFeatureCollaborationTitle => 'ಸಹಯೋಗ';

  @override
  String get startupFeatureCollaborationText => 'ಕೈ ಎತ್ತಿ ಮತ್ತು ಭಾಗವಹಿಸಿ';

  @override
  String get settingsResetTitle => 'ಸೆಟ್ಟಿಂಗ್‌ಗಳನ್ನು ಮರುಹೊಂದಿಸಿ';

  @override
  String get settingsResetCancelButton => '1: ರದ್ದುಮಾಡಿ';

  @override
  String get settingsResetConfirmButton => '2: ಮರುಹೊಂದಿಸಿ';

  @override
  String teacherHomeFallbackName(String id) {
    return 'ಶಿಕ್ಷಕರು $id';
  }

  @override
  String dashboardSignedInAs(String name) {
    return '$name ಆಗಿ ಸೈನ್ ಇನ್ ಆಗಿದ್ದೀರಿ';
  }

  @override
  String get dashboardRefreshSessionsKey1 => '1: ಸೆಷನ್‌ಗಳನ್ನು ರಿಫ್ರೆಶ್ ಮಾಡಿ';

  @override
  String get dashboardLogOutKey0 => '0: ಲಾಗ್ ಔಟ್';

  @override
  String get dashboardRefreshingSessions =>
      'ಸೆಷನ್‌ಗಳನ್ನು ರಿಫ್ರೆಶ್ ಮಾಡಲಾಗುತ್ತಿದೆ';

  @override
  String teacherHomeWelcome(String name) {
    return 'ಸ್ವಾಗತ, $name!';
  }

  @override
  String get teacherHomeTagline =>
      'ನಿಮ್ಮ ಸೆಷನ್‌ಗಳನ್ನು ನಿರ್ವಹಿಸಿ ಮತ್ತು ವಿದ್ಯಾರ್ಥಿಗಳೊಂದಿಗೆ ಸಂಪರ್ಕಿಸಿ';

  @override
  String get teacherHomeChooseWorkspaceKey7 =>
      '7: ತರಗತಿ ಮತ್ತು ವಿಷಯ ವರ್ಕ್‌ಸ್ಪೇಸ್ ಆರಿಸಿ';

  @override
  String teacherHomeChangeWorkspaceKey7(String className, String subjectName) {
    return '7: $className, $subjectName. ವರ್ಕ್‌ಸ್ಪೇಸ್ ಬದಲಿಸಿ';
  }

  @override
  String get teacherHomePlaylistsKey5 => '5: ತರಗತಿ ಪ್ಲೇಲಿಸ್ಟ್‌ಗಳು';

  @override
  String get teacherHomeJourneysKey8 => '8: ಕಲಿಕೆಯ ಪಯಣಗಳು';

  @override
  String get teacherHomeQuizzesKey6 => '6: ಕ್ವಿಜ್‌ಗಳು ಮತ್ತು ಪ್ರಶ್ನೆ ಬ್ಯಾಂಕ್';

  @override
  String get teacherHomeCreateSessionKey2 => '2: ಹೊಸ ಸೆಷನ್ ರಚಿಸಿ';

  @override
  String get dashboardAudioLibraryKey3 => '3: ರೆಕಾರ್ಡ್ ಮಾಡಿದ ಆಡಿಯೊ ಲೈಬ್ರರಿ';

  @override
  String get teacherHomeSearchKey4 => '4: ಹೆಸರು ಅಥವಾ ಸಂಖ್ಯೆಯಿಂದ ಹುಡುಕಿ';

  @override
  String get teacherHomeSearchHint =>
      'ಸೆಷನ್ ಹೆಸರು ಟೈಪ್ ಮಾಡಿ, ಅಥವಾ ಸಂಖ್ಯೆ ಕೀಗಳಿಂದ ಸೆಷನ್ ಸಂಖ್ಯೆ ಟೈಪ್ ಮಾಡಿ. ಎಲ್ಲವನ್ನೂ ನೋಡಲು ಖಾಲಿ ಬಿಡಿ.';

  @override
  String get teacherHomeYourSessions => 'ನಿಮ್ಮ ಸೆಷನ್‌ಗಳು';

  @override
  String teacherHomeYourSessionsCount(String count) {
    return 'ನಿಮ್ಮ ಸೆಷನ್‌ಗಳು, $count';
  }

  @override
  String get teacherHomeYourSessionsHeading => 'ನಿಮ್ಮ ಸೆಷನ್‌ಗಳು';

  @override
  String get teacherHomeNoSessions =>
      'ಇನ್ನೂ ಯಾವುದೇ ಸೆಷನ್ ಇಲ್ಲ. ಒಂದನ್ನು ರಚಿಸಲು 2 ಒತ್ತಿ.';

  @override
  String get teacherHomeNoMatches =>
      'ಹೊಂದುವ ಸೆಷನ್ ಇಲ್ಲ. ಎಲ್ಲಾ ಸೆಷನ್‌ಗಳನ್ನು ನೋಡಲು ಹುಡುಕಾಟವನ್ನು ಅಳಿಸಿ.';

  @override
  String teacherHomeEndTitleForEveryone(String title) {
    return 'ಎಲ್ಲರಿಗೂ $title ಮುಗಿಸಿ';
  }

  @override
  String teacherHomeDeleteTitlePermanently(String title) {
    return '$title ಅನ್ನು ಶಾಶ್ವತವಾಗಿ ಅಳಿಸಿ';
  }

  @override
  String teacherHomeLiveJoined(String count) {
    return 'ಈಗ ಲೈವ್, $count ಜನ ಸೇರಿದ್ದಾರೆ';
  }

  @override
  String teacherHomeSessionNumber(String number) {
    return 'ಸೆಷನ್ ಸಂಖ್ಯೆ $number';
  }

  @override
  String teacherHomePlaceSessionNumber(String place, String number) {
    return '$place. ಸೆಷನ್ ಸಂಖ್ಯೆ $number';
  }

  @override
  String get teacherHomeDelete => 'ಅಳಿಸಿ';

  @override
  String get teacherHomeSessionTitleField => 'ಸೆಷನ್ ಶೀರ್ಷಿಕೆ';

  @override
  String get teacherHomeSessionTitleHint => 'ಉದಾ., ಇಂಗ್ಲಿಷ್ ತರಗತಿ - ಘಟಕ 5';

  @override
  String get teacherHomeCreateKey1 => 'ರಚಿಸಿ (1)';

  @override
  String studentHomeFallbackName(String id) {
    return 'ವಿದ್ಯಾರ್ಥಿ $id';
  }

  @override
  String get studentHomeLoading => 'ವಿದ್ಯಾರ್ಥಿ ಡ್ಯಾಶ್‌ಬೋರ್ಡ್ ಲೋಡ್ ಆಗುತ್ತಿದೆ';

  @override
  String studentHomeWelcome(String name) {
    return 'ಸ್ವಾಗತ, $name';
  }

  @override
  String studentHomeClass(String name) {
    return 'ತರಗತಿ: $name';
  }

  @override
  String get studentHomeAssignmentPending => 'ತರಗತಿ ನೀಡುವುದು ಬಾಕಿ ಇದೆ';

  @override
  String get studentHomeLiveSessionsNone => 'ಲೈವ್ ಸೆಷನ್‌ಗಳು: ಯಾವುದೂ ಇಲ್ಲ';

  @override
  String studentHomeLiveSessionsCount(String count) {
    return 'ಲೈವ್ ಸೆಷನ್‌ಗಳು: $count';
  }

  @override
  String get studentHomeSessionNumberKey2 => '2: ಸೆಷನ್ ಸಂಖ್ಯೆ';

  @override
  String get studentHomeSessionName => 'ಸೆಷನ್ ಹೆಸರು';

  @override
  String get studentHomeSubjectFilter => 'ವಿಷಯ ಫಿಲ್ಟರ್';

  @override
  String get studentHomePlaylistsKey4 => '4: ನನ್ನ ಪ್ಲೇಲಿಸ್ಟ್‌ಗಳು · ಖಾಸಗಿ';

  @override
  String get studentHomeQuizzesKey5 => '5: ಕ್ವಿಜ್‌ಗಳು';

  @override
  String get studentHomeJourneysKey6 => '6: ಕಲಿಕೆಯ ಪಯಣಗಳು';

  @override
  String studentHomeTeacher(String name) {
    return 'ಶಿಕ್ಷಕರು: $name';
  }

  @override
  String studentHomeSessionOkToJoin(String number) {
    return 'ಸೆಷನ್ $number. ಸೇರಲು ಓಕೆ';
  }

  @override
  String studentHomeJoinSessionLabel(String session) {
    return '$session. ಸೆಷನ್‌ಗೆ ಸೇರಿ';
  }

  @override
  String adminActiveAssignmentCount(String count) {
    return '$count ಸಕ್ರಿಯ ನಿಯೋಜನೆಗಳು';
  }

  @override
  String adminHeadingCount(String heading, String count) {
    return '$heading ($count)';
  }

  @override
  String get adminTextDialogHelper =>
      'ಟೈಪ್ ಮಾಡಲು ಓಕೆ ಒತ್ತಿ, ನಂತರ ಉಳಿಸಲು 1 ಅಥವಾ ರದ್ದುಮಾಡಲು 0 ಒತ್ತಿ';

  @override
  String get adminSaveKey1 => 'ಉಳಿಸಿ (1)';

  @override
  String adminManageUser(String name) {
    return '$name ನಿರ್ವಹಿಸಿ';
  }

  @override
  String get adminManageAssignmentsKey1 => '1: ನಿಯೋಜನೆಗಳನ್ನು ನಿರ್ವಹಿಸಿ';

  @override
  String get adminPasswordRecoveryKey2 => '2: ಪಾಸ್‌ವರ್ಡ್ ಮರುಪಡೆಯುವಿಕೆ';

  @override
  String adminRemoveStudentFromClass(String name, String className) {
    return '$name ಅವರನ್ನು $className ನಿಂದ ತೆಗೆದುಹಾಕಿ (2)';
  }

  @override
  String get adminRemoveClassKey2 => 'ತರಗತಿ ತೆಗೆದುಹಾಕಿ (2)';

  @override
  String get adminAssignKey1 => 'ನಿಯೋಜಿಸಿ (1)';

  @override
  String adminAssignTeacher(String name) {
    return '$name ನಿಯೋಜಿಸಿ';
  }

  @override
  String get adminCurrentAssignments => 'ಈಗಿನ ನಿಯೋಜನೆಗಳು';

  @override
  String adminRemoveTeacherAssignment(
    String name,
    String className,
    String subjectName,
  ) {
    return '$name ಅವರನ್ನು $className, $subjectName ನಿಂದ ತೆಗೆದುಹಾಕಿ';
  }

  @override
  String get adminAddAssignment => 'ನಿಯೋಜನೆ ಸೇರಿಸಿ';

  @override
  String get adminAppBarTitle => 'SEEDS ಆಡಳಿತ';

  @override
  String get adminRefreshKey1 => '1: ಆಡಳಿತ ಡೇಟಾ ರಿಫ್ರೆಶ್ ಮಾಡಿ';

  @override
  String get adminLoading => 'ಆಡಳಿತ ಡೇಟಾ ಲೋಡ್ ಆಗುತ್ತಿದೆ';

  @override
  String adminChangeSectionKey7(String section) {
    return '7: ವಿಭಾಗ ಬದಲಿಸಿ. ಈಗ: $section';
  }

  @override
  String get adminSearchKey2 => '2: ಹೆಸರು ಅಥವಾ ಫೋನ್ ಸಂಖ್ಯೆಯಿಂದ ಹುಡುಕಿ';

  @override
  String get adminSearchHelper => 'ಹೊಂದುವವುಗಳನ್ನು ತೋರಿಸಲು ಮುಗಿದ ನಂತರ ಓಕೆ ಒತ್ತಿ';

  @override
  String adminRoleFilterChipsLabel(String label) {
    return 'ಖಾತೆ ಪ್ರಕಾರ ಫಿಲ್ಟರ್: $label, ಆಯ್ಕೆಯಾಗಿದೆ. ಬದಲಿಸಲು ಎಡ ಮತ್ತು ಬಲ ಬಾಣಗಳನ್ನು ಬಳಸಿ.';
  }

  @override
  String get adminAccountTypeKey3 => '3: ಖಾತೆ ಪ್ರಕಾರ';

  @override
  String get adminChipAllAccounts => 'ಎಲ್ಲಾ ಖಾತೆಗಳು';

  @override
  String get adminChipStudents => 'ವಿದ್ಯಾರ್ಥಿಗಳು';

  @override
  String get adminChipTeachers => 'ಶಿಕ್ಷಕರು';

  @override
  String adminAssignmentFilterChipsLabel(String label) {
    return 'ನಿಯೋಜನೆ ಫಿಲ್ಟರ್: $label, ಆಯ್ಕೆಯಾಗಿದೆ. ಬದಲಿಸಲು ಎಡ ಮತ್ತು ಬಲ ಬಾಣಗಳನ್ನು ಬಳಸಿ.';
  }

  @override
  String get adminAssignmentKey4 => '4: ನಿಯೋಜನೆ';

  @override
  String get adminChipAll => 'ಎಲ್ಲಾ';

  @override
  String get adminCreateSubjectKey5 => '5: ವಿಷಯ ರಚಿಸಿ';

  @override
  String get adminCreateClassKey6 => '6: ತರಗತಿ ರಚಿಸಿ';

  @override
  String get adminStatusActive => 'ಸಕ್ರಿಯ';

  @override
  String get adminClassTileHint => 'ವಿಷಯಗಳಿಗಾಗಿ ಅಥವಾ ಆರ್ಕೈವ್ ಮಾಡಲು ಓಕೆ ಒತ್ತಿ';

  @override
  String get adminPressOkRestore => 'ಮರುಸ್ಥಾಪಿಸಲು ಓಕೆ ಒತ್ತಿ';

  @override
  String get adminPressOkArchive => 'ಆರ್ಕೈವ್ ಮಾಡಲು ಓಕೆ ಒತ್ತಿ';

  @override
  String sessionTitleTeacher(String title) {
    return '$title (ಶಿಕ್ಷಕರು)';
  }

  @override
  String get libraryStatusStopped => 'ನಿಲ್ಲಿಸಲಾಗಿದೆ';

  @override
  String libraryUploadFileName(String name) {
    return 'ಫೈಲ್: $name';
  }

  @override
  String libraryAudioSessionTitle(String number) {
    return 'ಆಡಿಯೊ - ಸೆಷನ್ $number';
  }

  @override
  String libraryRecordingsCount(String count) {
    return '$count ರೆಕಾರ್ಡಿಂಗ್‌ಗಳು';
  }

  @override
  String libraryUploadedAt(String date) {
    return 'ಅಪ್‌ಲೋಡ್ ಮಾಡಿದ್ದು: $date';
  }

  @override
  String libraryStopPreviewOf(String title) {
    return '$title ಮುನ್ನೋಟ ನಿಲ್ಲಿಸಿ';
  }

  @override
  String libraryPreviewPrivately(String title) {
    return '$title ಅನ್ನು ಖಾಸಗಿಯಾಗಿ ಮುನ್ನೋಟ ಮಾಡಿ';
  }

  @override
  String libraryPlayForEveryone(String title) {
    return 'ಸೆಷನ್‌ನಲ್ಲಿರುವ ಎಲ್ಲರಿಗೂ $title ಪ್ಲೇ ಮಾಡಿ';
  }

  @override
  String get librarySelectClassHint =>
      'ರೆಕಾರ್ಡ್ ಮಾಡಿದ ಪಾಠಗಳನ್ನು ಪ್ಲೇ ಮಾಡಲು ತರಗತಿ ಆಯ್ಕೆಮಾಡಿ. ಆನ್‌ಲೈನ್ ಪಾಠಗಳಿಗೆ ಇಂಟರ್ನೆಟ್ ಬೇಕು. ಉಳಿಸಿದ ಆಡಿಯೊಗಾಗಿ ಡೌನ್‌ಲೋಡ್ ಮಾಡಿದ ಪಾಠಗಳನ್ನು ಬಳಸಿ.';

  @override
  String libraryFoundCount(String count) {
    return '$count ಸಿಕ್ಕಿವೆ';
  }

  @override
  String get librarySearchSessionHint =>
      'ತರಗತಿಯನ್ನು ಬೇಗ ತೆರೆಯಲು ಮೇಲಿನ \"ಸೆಷನ್ ಹೆಸರಿನಿಂದ ಹುಡುಕಿ\" ಬಳಸಿ.';

  @override
  String librarySessionHash(String number) {
    return 'ಸೆಷನ್ #$number';
  }

  @override
  String libraryStatusFinished(String title) {
    return '$title ಮುಗಿದಿದೆ';
  }

  @override
  String libraryStatusPaused(String title) {
    return '$title ವಿರಾಮಗೊಂಡಿದೆ';
  }

  @override
  String libraryStatusPlaying(String title) {
    return '$title ಪ್ಲೇ ಆಗುತ್ತಿದೆ';
  }

  @override
  String get libraryTitleField => 'ಶೀರ್ಷಿಕೆ';

  @override
  String get libraryDescriptionOptional => 'ವಿವರಣೆ (ಐಚ್ಛಿಕ)';

  @override
  String libraryAudioLibrarySession(String number) {
    return 'ಆಡಿಯೊ ಲೈಬ್ರರಿ, ಸೆಷನ್ $number';
  }

  @override
  String get libraryUploadingAudio => 'ಆಡಿಯೊ ಅಪ್‌ಲೋಡ್ ಆಗುತ್ತಿದೆ';

  @override
  String get libraryAddAudioKey3Tooltip => 'ಆಡಿಯೊ ಸೇರಿಸಿ, ಕೀ 3';

  @override
  String get libraryAddAudioKey3 => '3: ಆಡಿಯೊ ಸೇರಿಸಿ';

  @override
  String get libraryNoRecordingsForClass =>
      'ಈ ತರಗತಿಗೆ ಇನ್ನೂ ರೆಕಾರ್ಡಿಂಗ್‌ಗಳಿಲ್ಲ.';

  @override
  String get libraryNoRecordingsAskTeacher =>
      'ಇನ್ನೂ ಯಾವುದೇ ರೆಕಾರ್ಡಿಂಗ್ ಲಭ್ಯವಿಲ್ಲ. ಕೆಲವನ್ನು ಅಪ್‌ಲೋಡ್ ಮಾಡಲು ನಿಮ್ಮ ಶಿಕ್ಷಕರನ್ನು ಕೇಳಿ.';

  @override
  String libraryPositionSpeed(String position, String total, String speed) {
    return '$total ರಲ್ಲಿ $position. ವೇಗ ${speed}x';
  }

  @override
  String libraryNowPlaying(String title) {
    return 'ಈಗ ಪ್ಲೇ ಆಗುತ್ತಿದೆ: $title';
  }

  @override
  String libraryRecordingsMatch(String count, String total) {
    return '$total ರಲ್ಲಿ $count ರೆಕಾರ್ಡಿಂಗ್‌ಗಳು ಹೊಂದುತ್ತವೆ';
  }

  @override
  String get libraryNoUnlinkedAudio => 'ಲಿಂಕ್ ಆಗದ ಯಾವುದೇ ಆಡಿಯೊ ಲಭ್ಯವಿಲ್ಲ.';

  @override
  String get libraryNoSearchMatches =>
      'ನಿಮ್ಮ ಹುಡುಕಾಟಕ್ಕೆ ಯಾವುದೇ ರೆಕಾರ್ಡಿಂಗ್ ಹೊಂದುತ್ತಿಲ್ಲ.';

  @override
  String get libraryFindingLesson => 'ನಿಮ್ಮ ಪಾಠವನ್ನು ಹುಡುಕಲಾಗುತ್ತಿದೆ';

  @override
  String get libraryTitleRequiredField => 'ಶೀರ್ಷಿಕೆ *';

  @override
  String get libraryUploadNewAudio => 'ಹೊಸ ಆಡಿಯೋ ಅಪ್‌ಲೋಡ್ ಮಾಡಿ';

  @override
  String get libraryStopPreview => 'ಮುನ್ನೋಟ ನಿಲ್ಲಿಸಿ';

  @override
  String get libraryPreviewOnlyMe => 'ಮುನ್ನೋಟ (ನನಗೆ ಮಾತ್ರ)';

  @override
  String get libraryPreview => 'ಮುನ್ನೋಟ';

  @override
  String get libraryStop => 'ನಿಲ್ಲಿಸಿ';

  @override
  String get libraryPlayInSession => 'ಸೆಷನ್‌ನಲ್ಲಿ ಪ್ಲೇ ಮಾಡಿ';

  @override
  String get librarySessionShort => 'ಸೆಷನ್';

  @override
  String get libraryNotesTooltip =>
      'ಖಾಸಗಿ ಟಿಪ್ಪಣಿಗಳು ಮತ್ತು ರೆಕಾರ್ಡಿಂಗ್ ಕರಡುಗಳು';

  @override
  String get libraryBrowseClassesKey5 => '5: ಸಕ್ರಿಯ ತರಗತಿಗಳನ್ನು ನೋಡಿ';

  @override
  String get librarySearchClassByName => 'ಹೆಸರಿನಿಂದ ತರಗತಿಯನ್ನು ಹುಡುಕಿ';

  @override
  String get librarySearchClassHint => 'ಸೆಷನ್/ತರಗತಿಯ ಹೆಸರು ನಮೂದಿಸಿ';

  @override
  String get libraryMyAudioLibrary => 'ನನ್ನ ಆಡಿಯೋ ಲೈಬ್ರರಿ';

  @override
  String get libraryAllAudioFiles => 'ಎಲ್ಲಾ ಆಡಿಯೋ ಫೈಲ್‌ಗಳು';

  @override
  String get libraryManageAudioFiles =>
      'ನಿಮ್ಮ ಆಡಿಯೋ ಫೈಲ್‌ಗಳನ್ನು ನಿರ್ವಹಿಸಿ ಮತ್ತು ಅಪ್‌ಲೋಡ್ ಮಾಡಿ';

  @override
  String get libraryBrowseAudioFiles =>
      'ಅಪ್‌ಲೋಡ್ ಮಾಡಿದ ಎಲ್ಲಾ ಆಡಿಯೋ ಫೈಲ್‌ಗಳನ್ನು ನೋಡಿ';

  @override
  String get libraryActiveClasses => 'ಸಕ್ರಿಯ ತರಗತಿಗಳು';

  @override
  String get libraryNoActiveClasses => 'ಯಾವುದೇ ಸಕ್ರಿಯ ತರಗತಿಗಳು ಸಿಗಲಿಲ್ಲ.';

  @override
  String get libraryAddAudioToSessions => 'ಸೆಷನ್‌ಗಳಿಗೆ ಆಡಿಯೋ ಸೇರಿಸಿ';

  @override
  String get libraryConfirmKey1 => '1: ಖಚಿತಪಡಿಸಿ';

  @override
  String get libraryDownloadLessons => 'ಪಾಠಗಳನ್ನು ಡೌನ್‌ಲೋಡ್ ಮಾಡಿ';

  @override
  String get libraryRepeatHelp => 'ಸಹಾಯವನ್ನು ಮತ್ತೆ ಕೇಳಿ';

  @override
  String get libraryBack10s => '10 ಸೆಕೆಂಡ್ ಹಿಂದೆ';

  @override
  String get libraryPause => 'ವಿರಾಮ';

  @override
  String get libraryPlay => 'ಪ್ಲೇ ಮಾಡಿ';

  @override
  String get libraryForward10s => '10 ಸೆಕೆಂಡ್ ಮುಂದೆ';

  @override
  String get libraryCloseAddAudio => 'ಆಡಿಯೋ ಸೇರಿಸುವ ಆಯ್ಕೆಗಳನ್ನು ಮುಚ್ಚಿ';

  @override
  String get libraryUploadNewFileKey1 => '1: ಹೊಸ ಫೈಲ್ ಅಪ್‌ಲೋಡ್ ಮಾಡಿ';

  @override
  String get librarySelectExistingKey2 => '2: ಈಗಿರುವ ಲೈಬ್ರರಿಯಿಂದ ಆರಿಸಿ';

  @override
  String get librarySelectAudio => 'ಆಡಿಯೋ ಆರಿಸಿ';

  @override
  String get libraryRefreshAvailable => 'ಲಭ್ಯವಿರುವ ಆಡಿಯೋವನ್ನು ರಿಫ್ರೆಶ್ ಮಾಡಿ';

  @override
  String get librarySearchByTitle => 'ಶೀರ್ಷಿಕೆಯಿಂದ ಹುಡುಕಿ';

  @override
  String get libraryNothingPlaying =>
      'ಏನೂ ಪ್ಲೇ ಆಗುತ್ತಿಲ್ಲ. ಒಂದು ಪಾಠವನ್ನು ಆರಿಸಿ ಅಥವಾ 5 ಒತ್ತಿ.';

  @override
  String spokenDayMonthYear(String day, String month, String year) {
    return '$day $month $year';
  }

  @override
  String get downloadPartialReserve =>
      'ಅಪೂರ್ಣ ಫೈಲ್‌ಗಳು ತಮ್ಮ ಪೂರ್ಣ ಗಾತ್ರದ ಜಾಗವನ್ನು ಕಾಯ್ದಿರಿಸುತ್ತವೆ.';

  @override
  String downloadProgressStarting(String title) {
    return '$title: ಡೌನ್‌ಲೋಡ್ ಪ್ರಾರಂಭವಾಗುತ್ತಿದೆ';
  }

  @override
  String downloadPercentDone(String title, String percent) {
    return '$title: $percent ಪ್ರತಿಶತ ಡೌನ್‌ಲೋಡ್ ಆಗಿದೆ';
  }

  @override
  String downloadRecordUnreadable(String id) {
    return 'ಡೌನ್‌ಲೋಡ್ ದಾಖಲೆ $id ಅನ್ನು ಓದಲು ಆಗಲಿಲ್ಲ. ಫೈಲ್‌ಗಳನ್ನು ಉಳಿಸಲಾಗಿದೆ. ಸರಿಪಡಿಸಲು ಈ ಡೌನ್‌ಲೋಡ್ ಅನ್ನು ಮಾತ್ರ ತೆಗೆದುಹಾಕಿ; ಪ್ರಗತಿ ಮತ್ತು ಬುಕ್‌ಮಾರ್ಕ್‌ಗಳು ಉಳಿಯುತ್ತವೆ.';
  }

  @override
  String downloadRemoveUnreadable(String id) {
    return 'ಓದಲಾಗದ ಡೌನ್‌ಲೋಡ್ $id ಅನ್ನು ತೆಗೆದುಹಾಕಿ';
  }

  @override
  String get downloadStatusDownloaded => 'ಡೌನ್‌ಲೋಡ್ ಆಗಿದೆ';

  @override
  String get downloadStatusPartial => 'ಅಪೂರ್ಣ ಡೌನ್‌ಲೋಡ್';

  @override
  String downloadSizeRenewal(String megabytes) {
    return '$megabytes MB. ಪ್ರವೇಶವನ್ನು ನವೀಕರಿಸಬೇಕು.';
  }

  @override
  String downloadSizeExpires(String megabytes, String date) {
    return '$megabytes MB. ಪ್ರವೇಶ $date ರಂದು ಮುಗಿಯುತ್ತದೆ.';
  }

  @override
  String get downloadTitle => 'ಡೌನ್‌ಲೋಡ್‌ಗಳು';

  @override
  String get downloadAccessInfo =>
      '30 ದಿನಗಳ ಆಫ್‌ಲೈನ್ ಪ್ರವೇಶ. ಇತರ ಖಾತೆಗಳಿಗೆ ಪ್ರತ್ಯೇಕ ಮಿತಿಗಳಿವೆ. ಸ್ವಯಂಚಾಲಿತವಾಗಿ ಅಳಿಸುವುದಿಲ್ಲ.';

  @override
  String get downloadRefreshKey1 => '1: ಡೌನ್‌ಲೋಡ್‌ಗಳನ್ನು ರಿಫ್ರೆಶ್ ಮಾಡಿ';

  @override
  String get downloadFindOnlineKey2 =>
      '2: ಆನ್‌ಲೈನ್‌ನಲ್ಲಿ ರೆಕಾರ್ಡಿಂಗ್‌ಗಳನ್ನು ಹುಡುಕಿ';

  @override
  String get downloadReadStatusKey3 => '3: ಸ್ಥಿತಿಯನ್ನು ಓದಿ';

  @override
  String get downloadCancelKey4 => '4: ಡೌನ್‌ಲೋಡ್ ರದ್ದುಮಾಡಿ';

  @override
  String get downloadNoneYetFindOnline =>
      'ಇನ್ನೂ ಯಾವುದೇ ಡೌನ್‌ಲೋಡ್‌ಗಳಿಲ್ಲ. ಆನ್‌ಲೈನ್‌ನಲ್ಲಿ ರೆಕಾರ್ಡಿಂಗ್‌ಗಳನ್ನು ಹುಡುಕಿ ಅಥವಾ ತರಗತಿ ಅಥವಾ ಪ್ಲೇಲಿಸ್ಟ್‌ನಿಂದ ಡೌನ್‌ಲೋಡ್‌ಗಳನ್ನು ತೆರೆಯಿರಿ.';

  @override
  String get downloadPlayLesson => 'ಡೌನ್‌ಲೋಡ್ ಮಾಡಿದ ಪಾಠವನ್ನು ಪ್ಲೇ ಮಾಡಿ';

  @override
  String get downloadRenewOnline => 'ಆನ್‌ಲೈನ್‌ನಲ್ಲಿ ಪ್ರವೇಶವನ್ನು ನವೀಕರಿಸಿ';

  @override
  String get downloadRemove => 'ಡೌನ್‌ಲೋಡ್ ತೆಗೆದುಹಾಕಿ';

  @override
  String get downloadListedKey5 =>
      '5: ಪಟ್ಟಿಯಲ್ಲಿರುವ ರೆಕಾರ್ಡಿಂಗ್‌ಗಳನ್ನು ಡೌನ್‌ಲೋಡ್ ಮಾಡಿ';

  @override
  String get downloadAvailableInfo =>
      'ಲಭ್ಯವಿರುವ ರೆಕಾರ್ಡಿಂಗ್‌ಗಳು. ಡೌನ್‌ಲೋಡ್‌ಗಳು ಇಂಟರ್ನೆಟ್ ಡೇಟಾ ಬಳಸುತ್ತವೆ.';

  @override
  String playlistClassSubjectTitle(String className, String subjectName) {
    return '$className · $subjectName ಪ್ಲೇಲಿಸ್ಟ್‌ಗಳು';
  }

  @override
  String get playlistStatusPrivate => 'ಖಾಸಗಿ';

  @override
  String get playlistClassPlaylist => 'ತರಗತಿ ಪ್ಲೇಲಿಸ್ಟ್';

  @override
  String playlistItemCount(String count) {
    return '$count ಐಟಂಗಳು';
  }

  @override
  String playlistClassItemCount(
    String className,
    String subjectName,
    String count,
  ) {
    return '$className, $subjectName, $count ಐಟಂಗಳು';
  }

  @override
  String get playlistFinished => 'ಮುಗಿಯಿತು. ಪ್ಲೇಲಿಸ್ಟ್‌ನ ಕೊನೆ';

  @override
  String get playlistAddKey2 => '2 ಸೇರಿಸಿ';

  @override
  String get playlistAddAudioKey2Label => 'ಆಡಿಯೋ ಸೇರಿಸಿ, ಕೀ 2';

  @override
  String get playlistPauseKey5 => '5 ವಿರಾಮ';

  @override
  String get playlistPlayKey5 => '5 ಪ್ಲೇ';

  @override
  String playlistPauseTitleKey5(String title) {
    return '$title ವಿರಾಮಗೊಳಿಸಿ, ಕೀ 5';
  }

  @override
  String playlistPlayTitleKey5(String title) {
    return '$title ಪ್ಲೇ ಮಾಡಿ, ಕೀ 5';
  }

  @override
  String get playlistPreviousKey3 => '3 ಹಿಂದಿನದು';

  @override
  String get playlistPreviousItemKey3 => 'ಹಿಂದಿನ ಐಟಂ, ಕೀ 3';

  @override
  String get playlistNextKey8 => '8 ಮುಂದಿನದು';

  @override
  String get playlistNextItemKey8 => 'ಮುಂದಿನ ಐಟಂ, ಕೀ 8';

  @override
  String get playlistRestore => 'ಮರುಸ್ಥಾಪಿಸಿ';

  @override
  String get playlistArchive => 'ಆರ್ಕೈವ್ ಮಾಡಿ';

  @override
  String get playlistDeletePlaylist => 'ಪ್ಲೇಲಿಸ್ಟ್ ಅಳಿಸಿ';

  @override
  String playlistRestoreNamedButton(String title) {
    return '$title ಮರುಸ್ಥಾಪಿಸಿ';
  }

  @override
  String playlistArchiveNamedButton(String title) {
    return '$title ಆರ್ಕೈವ್ ಮಾಡಿ';
  }

  @override
  String playlistDeleteNamedButton(String title) {
    return '$title ಅಳಿಸಿ';
  }

  @override
  String playlistMoveUp(String title) {
    return '$title ಅನ್ನು ಮೇಲಕ್ಕೆ ಸರಿಸಿ';
  }

  @override
  String playlistMoveDown(String title) {
    return '$title ಅನ್ನು ಕೆಳಕ್ಕೆ ಸರಿಸಿ';
  }

  @override
  String get playlistCreateKey2 => '2: ಪ್ಲೇಲಿಸ್ಟ್ ರಚಿಸಿ';

  @override
  String get playlistNoneInClass =>
      'ಈ ತರಗತಿ ಮತ್ತು ವಿಷಯದಲ್ಲಿ ಯಾವುದೇ ಪ್ಲೇಲಿಸ್ಟ್‌ಗಳಿಲ್ಲ. ಒಂದನ್ನು ರಚಿಸಲು 2 ಒತ್ತಿ.';

  @override
  String get playlistMyPlaylists => 'ನನ್ನ ಪ್ಲೇಲಿಸ್ಟ್‌ಗಳು';

  @override
  String get playlistPrivateNoticeTitle => 'ನಿಮ್ಮ ಪ್ಲೇಲಿಸ್ಟ್‌ಗಳು ಖಾಸಗಿಯಾಗಿವೆ';

  @override
  String get playlistPrivateNoticeText =>
      'ಶಿಕ್ಷಕರು, ನಿರ್ವಾಹಕರು ಮತ್ತು ಇತರ ವಿದ್ಯಾರ್ಥಿಗಳು ಅವುಗಳನ್ನು ನೋಡಲು ಸಾಧ್ಯವಿಲ್ಲ.';

  @override
  String get playlistCreatePrivateKey2 => '2: ಖಾಸಗಿ ಪ್ಲೇಲಿಸ್ಟ್ ರಚಿಸಿ';

  @override
  String get playlistMyPrivateHeading => 'ನನ್ನ ಖಾಸಗಿ ಪ್ಲೇಲಿಸ್ಟ್‌ಗಳು';

  @override
  String get playlistNoPrivate => 'ಇನ್ನೂ ಯಾವುದೇ ಖಾಸಗಿ ಪ್ಲೇಲಿಸ್ಟ್‌ಗಳಿಲ್ಲ.';

  @override
  String get playlistClassHeading => 'ತರಗತಿ ಪ್ಲೇಲಿಸ್ಟ್‌ಗಳು';

  @override
  String get playlistNoClassPublished =>
      'ಇನ್ನೂ ಯಾವುದೇ ತರಗತಿ ಪ್ಲೇಲಿಸ್ಟ್‌ಗಳನ್ನು ಪ್ರಕಟಿಸಿಲ್ಲ.';

  @override
  String get playlistAddAudioTitle => 'ಆಡಿಯೋ ಸೇರಿಸಿ';

  @override
  String get playlistUnavailableRetry =>
      'ಪ್ಲೇಲಿಸ್ಟ್ ಲಭ್ಯವಿಲ್ಲ. ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಲು 1 ಒತ್ತಿ.';

  @override
  String get playlistDownloadRecordings =>
      'ಪ್ಲೇಲಿಸ್ಟ್ ರೆಕಾರ್ಡಿಂಗ್‌ಗಳನ್ನು ಡೌನ್‌ಲೋಡ್ ಮಾಡಿ';

  @override
  String get playlistMoveHint =>
      'ಒಂದು ಐಟಂ ಅನ್ನು ಪ್ಲೇ ಮಾಡಿ ಅಥವಾ ಆರಿಸಿ, ನಂತರ ಅದನ್ನು ಮೇಲಕ್ಕೆ ಅಥವಾ ಕೆಳಕ್ಕೆ ಸರಿಸಿ.';

  @override
  String get playlistNoAudio => 'ಈ ಪ್ಲೇಲಿಸ್ಟ್‌ನಲ್ಲಿ ಇನ್ನೂ ಆಡಿಯೋ ಇಲ್ಲ.';

  @override
  String quizClassSubjectHeading(String className, String subjectName) {
    return '$className · $subjectName';
  }

  @override
  String get quizBankEditNote =>
      'ಬ್ಯಾಂಕ್ ಪ್ರಶ್ನೆಯನ್ನು ಸಂಪಾದಿಸಿದರೆ, ಈಗಾಗಲೇ ಇರುವ ಕ್ವಿಜ್‌ನ ಪ್ರತಿ ಎಂದಿಗೂ ಬದಲಾಗುವುದಿಲ್ಲ.';

  @override
  String get quizNoBankQuestions => 'ಇನ್ನೂ ಯಾವುದೇ ಬ್ಯಾಂಕ್ ಪ್ರಶ್ನೆಗಳಿಲ್ಲ';

  @override
  String quizOptionsCount(String count) {
    return '$count ಆಯ್ಕೆಗಳು';
  }

  @override
  String get quizNoQuizzesYet => 'ಇನ್ನೂ ಯಾವುದೇ ಕ್ವಿಜ್‌ಗಳಿಲ್ಲ';

  @override
  String get quizStepReviewPublish => 'ಹಂತ 3: ಪರಿಶೀಲಿಸಿ ಮತ್ತು ಪ್ರಕಟಿಸಿ';

  @override
  String get quizStepAddQuestions => 'ಹಂತ 2: ಪ್ರಶ್ನೆಗಳನ್ನು ಸೇರಿಸಿ';

  @override
  String quizResultsTitle(String title) {
    return '$title ಫಲಿತಾಂಶಗಳು';
  }

  @override
  String get quizAllAttempted => 'ಎಲ್ಲಾ ವಿದ್ಯಾರ್ಥಿಗಳು ಪ್ರಯತ್ನಿಸಿದ್ದಾರೆ';

  @override
  String get quizRemindAllKey2 => '2: ಪ್ರಯತ್ನಿಸದ ಎಲ್ಲರಿಗೂ ನೆನಪಿಸಿ';

  @override
  String get uiNoneCapital => 'ಯಾವುದೂ ಇಲ್ಲ';

  @override
  String get quizPracticeParticipationHeading =>
      'ಅಭ್ಯಾಸದ ಭಾಗವಹಿಸುವಿಕೆ, ಶೈಕ್ಷಣಿಕ ಅಂಕಗಳಲ್ಲ';

  @override
  String get quizIndividualScores => 'ಪ್ರತಿ ವಿದ್ಯಾರ್ಥಿಯ ಅಂಕಗಳು';

  @override
  String get quizNotAttempted => 'ಪ್ರಯತ್ನಿಸಿಲ್ಲ';

  @override
  String get quizPracticeNotGraded => 'ಅಭ್ಯಾಸ, ಅಂಕಸಹಿತವಲ್ಲ';

  @override
  String quizHighestScore(String score) {
    return 'ಅತಿ ಹೆಚ್ಚು ಅಂಕ: $score';
  }

  @override
  String get quizAttemptInProgress => 'ಪ್ರಯತ್ನ ನಡೆಯುತ್ತಿದೆ';

  @override
  String get quizQuizzesTitle => 'ಕ್ವಿಜ್‌ಗಳು';

  @override
  String get quizRefreshQuizzesTooltip => 'ಕ್ವಿಜ್‌ಗಳನ್ನು ರಿಫ್ರೆಶ್ ಮಾಡಿ';

  @override
  String get quizLoadingQuizzes => 'ಕ್ವಿಜ್‌ಗಳನ್ನು ಲೋಡ್ ಮಾಡಲಾಗುತ್ತಿದೆ';

  @override
  String get quizNewBankQuestionKey2 => '2: ಹೊಸ ಬ್ಯಾಂಕ್ ಪ್ರಶ್ನೆ';

  @override
  String get quizNewDraftKey3 => '3: ಹೊಸ ಕ್ವಿಜ್ ಕರಡು';

  @override
  String get quizCreatePracticeKey4 => '4: ಸಮಯ ಮಿತಿ ಇಲ್ಲದ ಅಭ್ಯಾಸ ರಚಿಸಿ';

  @override
  String get quizPrivateBankHeading => 'ಖಾಸಗಿ ಪ್ರಶ್ನೆ ಬ್ಯಾಂಕ್';

  @override
  String get quizOptionsButton => 'ಆಯ್ಕೆಗಳು';

  @override
  String get quizManagementHeading => 'ಕ್ವಿಜ್ ನಿರ್ವಹಣೆ';

  @override
  String get quizContinueCreation => 'ರಚನೆಯನ್ನು ಮುಂದುವರಿಸಿ';

  @override
  String get quizCloseButton => 'ಮುಚ್ಚಿ';

  @override
  String get quizDuplicateButton => 'ನಕಲು ಮಾಡಿ';

  @override
  String get quizResultsButton => 'ಫಲಿತಾಂಶಗಳು';

  @override
  String get quizRefreshResultsTooltip => 'ಫಲಿತಾಂಶಗಳನ್ನು ರಿಫ್ರೆಶ್ ಮಾಡಿ';

  @override
  String get quizClassStatistics => 'ತರಗತಿಯ ಅಂಕಿಅಂಶಗಳು';

  @override
  String get quizStudentsYetToAttempt => 'ಇನ್ನೂ ಪ್ರಯತ್ನಿಸಬೇಕಾದ ವಿದ್ಯಾರ್ಥಿಗಳು';

  @override
  String get quizNoQuizzesAvailableLabel => 'ಯಾವುದೇ ಕ್ವಿಜ್‌ಗಳು ಲಭ್ಯವಿಲ್ಲ';

  @override
  String get quizAttemptLimitReachedLabel => 'ಪ್ರಯತ್ನದ ಮಿತಿ ತಲುಪಿದೆ';

  @override
  String get quizAnswerSavedLockedTitle => 'ಉತ್ತರ ಉಳಿಸಲಾಗಿದೆ ಮತ್ತು ಲಾಕ್ ಆಗಿದೆ';

  @override
  String get quizAllSavedViewResult =>
      'ಎಲ್ಲಾ ಉತ್ತರಗಳನ್ನು ಉಳಿಸಲಾಗಿದೆ. ಪೂರ್ಣಗೊಂಡಿದೆ ಎಂದು ಖಚಿತಪಡಿಸಲು ಫಲಿತಾಂಶ ನೋಡಿ ಆರಿಸಿ.';

  @override
  String quizAsksToConfirm(String label) {
    return '$label, ಖಚಿತಪಡಿಸಲು ಕೇಳುತ್ತದೆ';
  }

  @override
  String get quizConfirmingCompletion =>
      'ಪೂರ್ಣಗೊಂಡಿರುವುದನ್ನು ಖಚಿತಪಡಿಸಲಾಗುತ್ತಿದೆ';

  @override
  String get quizRetryCompletionKey5 =>
      '5: ಪೂರ್ಣಗೊಳಿಸುವಿಕೆಯನ್ನು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ';

  @override
  String get quizViewResultKey5 => '5: ಫಲಿತಾಂಶ ನೋಡಿ';

  @override
  String quizHistoryTitle(String title) {
    return '$title ಇತಿಹಾಸ';
  }

  @override
  String get quizNoAttemptsYet => 'ಇನ್ನೂ ಯಾವುದೇ ಪ್ರಯತ್ನಗಳಿಲ್ಲ';

  @override
  String get quizHistoryTooltip => 'ಪ್ರಯತ್ನಗಳ ಇತಿಹಾಸ ಮತ್ತು ಪರಿಶೀಲನೆ';

  @override
  String get quizLeaveWithoutSubmitting => 'ಸಲ್ಲಿಸದೆ ಹೊರಹೋಗಿ';

  @override
  String get quizAttemptCompletePrivateLabel =>
      'ಪ್ರಯತ್ನ ಪೂರ್ಣಗೊಂಡಿದೆ. ಫಲಿತಾಂಶ ಖಾಸಗಿಯಾಗಿದೆ. ಫಲಿತಾಂಶವನ್ನು ಖಾಸಗಿಯಾಗಿ ಓದಿ ಬಳಸಿ.';

  @override
  String get quizReadResultKey8 => '8: ಫಲಿತಾಂಶವನ್ನು ಖಾಸಗಿಯಾಗಿ ಓದಿ';

  @override
  String get quizReturnKey0 => '0: ಕ್ವಿಜ್‌ಗಳಿಗೆ ಹಿಂತಿರುಗಿ';

  @override
  String get quizReadAllOptionsLabel => 'ಎಲ್ಲಾ ಆಯ್ಕೆಗಳನ್ನು ಓದಿ';

  @override
  String get quizSubmitAnswerKey5 => '5: ಉತ್ತರ ಸಲ್ಲಿಸಿ';

  @override
  String get quizAnswerLockedActivate =>
      'ಉತ್ತರ ಉಳಿಸಲಾಗಿದೆ ಮತ್ತು ಲಾಕ್ ಆಗಿದೆ. ಪ್ರತಿಕ್ರಿಯೆಯನ್ನು ಖಾಸಗಿಯಾಗಿ ಓದಲು ಸಕ್ರಿಯಗೊಳಿಸಿ.';

  @override
  String get quizReadSelectedAnswer => 'ಆರಿಸಿದ ಉತ್ತರವನ್ನು ಓದಿ';

  @override
  String get quizReadRemainingTime => 'ಉಳಿದ ಸಮಯವನ್ನು ಓದಿ';

  @override
  String get quizAttemptReviewTitle => 'ಪ್ರಯತ್ನದ ಪರಿಶೀಲನೆ';

  @override
  String get quizEditorIntro =>
      'ಪ್ರಶ್ನೆ ಮತ್ತು ಎಲ್ಲಾ ನಾಲ್ಕು ಆಯ್ಕೆಗಳನ್ನು ಪೂರ್ಣಗೊಳಿಸಿ, ನಂತರ ಸರಿಯಾದ ಉತ್ತರವನ್ನು ಆರಿಸಿ. ಸಮೀಕರಣಗಳು ಅಥವಾ ಚಿತ್ರಗಳಿಗೆ, ಐಚ್ಛಿಕ ಮಾತಿನ ಸಂಕೇತವನ್ನು ತೆರೆಯಿರಿ ಮತ್ತು ಪರ್ಯಾಯಗಳನ್ನು ಪರಿಶೀಲಿಸಿ.';

  @override
  String get quizWhichCorrect => 'ಯಾವ ಉತ್ತರ ಸರಿ?';

  @override
  String get quizChooseCorrectOption => 'ಸರಿಯಾದ ಆಯ್ಕೆಯನ್ನು ಆರಿಸಿ';

  @override
  String quizOptionWithText(String number, String text) {
    return 'ಆಯ್ಕೆ $number: $text';
  }

  @override
  String get quizCorrectChoiceHint =>
      'ಬದಲಾಯಿಸಲು ಎಡ ಅಥವಾ ಬಲ ಬಳಸಿ. ಓಕೆ ಅಥವಾ ಟ್ಯಾಪ್ ಮುಂದಿನ ಆಯ್ಕೆಯನ್ನು ಆರಿಸುತ್ತದೆ.';

  @override
  String get quizExplanationOptional => 'ವಿವರಣೆ (ಐಚ್ಛಿಕ)';

  @override
  String get quizContentDescribedText =>
      'ವಿಷಯ: ಶಿಕ್ಷಕರು ವಿವರಿಸಿದ ಸಂಕೇತ ಅಥವಾ ಚಿತ್ರ';

  @override
  String get quizNotationNote =>
      'ಸಮೀಕರಣ ಅಥವಾ ಚಿತ್ರವನ್ನು ಸ್ವಯಂಚಾಲಿತವಾಗಿ ಅರ್ಥೈಸುವುದಿಲ್ಲ. ಶಿಕ್ಷಕರು ಇಂಗ್ಲಿಷ್ ಮಾತಿನ ಪರ್ಯಾಯಗಳನ್ನು ಬರೆದು ಪರಿಶೀಲಿಸಬೇಕು. ವಿವರಿಸಿದ ಸಂಕೇತಕ್ಕಾಗಿ, ಪ್ರಶ್ನೆ, ಎಲ್ಲಾ ಆಯ್ಕೆಗಳು ಮತ್ತು ಯಾವುದೇ ವಿವರಣೆಯನ್ನು ಸೇರಿಸಿ.';

  @override
  String get quizReviewedAlternatives =>
      'ಮಾತಿನ ಪರ್ಯಾಯಗಳು ಸರಿಯಾಗಿವೆಯೇ ಎಂದು ನಾನು ಪರಿಶೀಲಿಸಿದ್ದೇನೆ';

  @override
  String get quizChangeSettings => 'ಕ್ವಿಜ್ ಸೆಟ್ಟಿಂಗ್‌ಗಳನ್ನು ಬದಲಾಯಿಸಿ';

  @override
  String get quizCreatePracticeText => 'ಸಮಯ ಮಿತಿ ಇಲ್ಲದ ಅಭ್ಯಾಸ ರಚಿಸಿ';

  @override
  String get quizStepName => 'ಹಂತ 1: ನಿಮ್ಮ ಕ್ವಿಜ್‌ಗೆ ಹೆಸರು ನೀಡಿ';

  @override
  String get quizPracticeInfo =>
      'ಅಭ್ಯಾಸಕ್ಕೆ ಪ್ರತಿ ಪ್ರಯತ್ನದ ಟೈಮರ್ ಅಥವಾ ಮರುಪ್ರಯತ್ನ ಮಿತಿ ಇಲ್ಲ. ಐಚ್ಛಿಕ ಮುಕ್ತಾಯ ಸಮಯವಿದ್ದರೆ, ಆಗ ಲಭ್ಯತೆ ಕೊನೆಗೊಳ್ಳುತ್ತದೆ.';

  @override
  String get quizSettingsNavLabel =>
      'ಕ್ವಿಜ್ ಸೆಟ್ಟಿಂಗ್‌ಗಳಲ್ಲಿ ಚಲಿಸಲು ಮೇಲೆ ಮತ್ತು ಕೆಳಗೆ ಬಳಸಿ. ಪಠ್ಯ ಕ್ಷೇತ್ರಗಳನ್ನು ಸಂಪಾದಿಸಲು ಓಕೆ ಒತ್ತಿ. ಆರಂಭ ಮತ್ತು ಮುಕ್ತಾಯ ಸಮಯಗಳು ಐಚ್ಛಿಕ.';

  @override
  String get quizSettingsNavText =>
      'ಸೆಟ್ಟಿಂಗ್‌ಗಳಲ್ಲಿ ಚಲಿಸಲು ಮೇಲೆ ಮತ್ತು ಕೆಳಗೆ ಬಳಸಿ, ಸಂಪಾದಿಸಲು ಓಕೆ ಒತ್ತಿ. ಕರಡು ಅಥವಾ ಅದರ ಸೆಟ್ಟಿಂಗ್‌ಗಳನ್ನು ಉಳಿಸಿದರೆ ಕ್ವಿಜ್ ಪ್ರಕಟವಾಗುವುದಿಲ್ಲ.';

  @override
  String get quizSettingsReviewInfo =>
      'ಕೆಳಗಿನ ಉಳಿಸಿದ ಸೆಟ್ಟಿಂಗ್‌ಗಳನ್ನು ಪರಿಶೀಲಿಸಿ ಮತ್ತು ಬದಲಾಯಿಸಿ. ಉಳಿಸಿದರೆ ಕ್ವಿಜ್ ಪ್ರಕಟವಾಗುವುದಿಲ್ಲ.';

  @override
  String get quizPracticeDefaults =>
      'ಅಂಕರಹಿತ ಅಭ್ಯಾಸ. ಅನಿಯಮಿತ ಪ್ರಯತ್ನಗಳು, ಟೈಮರ್ ಇಲ್ಲ, ತಕ್ಷಣದ ಪ್ರತಿಕ್ರಿಯೆ.';

  @override
  String get quizGradedDefaults =>
      'ಡೀಫಾಲ್ಟ್ ಅಂಕಸಹಿತ ಸೆಟ್ಟಿಂಗ್‌ಗಳು: ಒಂದು ಪ್ರಯತ್ನ, ಟೈಮರ್ ಇಲ್ಲ, ಅಂತಿಮ ಸಲ್ಲಿಕೆಯ ನಂತರ ಪ್ರತಿಕ್ರಿಯೆ.';

  @override
  String get quizHideOptionalSettingsText => 'ಐಚ್ಛಿಕ ಸೆಟ್ಟಿಂಗ್‌ಗಳನ್ನು ಮರೆಮಾಡಿ';

  @override
  String get quizShowOptionalSettingsText => 'ಐಚ್ಛಿಕ ಸೆಟ್ಟಿಂಗ್‌ಗಳನ್ನು ತೋರಿಸಿ';

  @override
  String get quizAttemptLimitFieldText => 'ಪ್ರಯತ್ನದ ಮಿತಿ, 1 ರಿಂದ 20';

  @override
  String get quizTimeLimitFieldText => 'ನಿಮಿಷಗಳಲ್ಲಿ ಸಮಯ ಮಿತಿ (ಐಚ್ಛಿಕ)';

  @override
  String get quizUntimedInfo =>
      'ಸಮಯ ಮಿತಿ ಇಲ್ಲ ಮತ್ತು ಅಂಕರಹಿತ, ಅನಿಯಮಿತ ಮರುಪ್ರಯತ್ನಗಳು. ಲಭ್ಯತೆಯ ಸಮಯಗಳನ್ನು ಹೊಂದಿಸಿದ್ದರೆ ಅವು ಅನ್ವಯಿಸುತ್ತವೆ.';

  @override
  String quizFeedbackValue(String policy) {
    return 'ಪ್ರತಿಕ್ರಿಯೆ: $policy';
  }

  @override
  String quizReleaseValue(String time) {
    return 'ಬಿಡುಗಡೆ: $time';
  }

  @override
  String quizOpeningTimeLabel(String time) {
    return '$time. ಆರಂಭ ಸಮಯ ಹೊಂದಿಸಲು ಓಕೆ ಒತ್ತಿ. ಎಡ ಕೀ ಅದನ್ನು ತೆರವುಗೊಳಿಸುತ್ತದೆ.';
  }

  @override
  String get quizNoOpeningTimeSet => 'ಆರಂಭ ಸಮಯ ಹೊಂದಿಸಿಲ್ಲ';

  @override
  String get quizNoOpeningTimeShort => 'ಆರಂಭ ಸಮಯವಿಲ್ಲ';

  @override
  String get quizOpeningTimeHint =>
      'ಐಚ್ಛಿಕ · ವರ್ಷ, ತಿಂಗಳು, ದಿನ, ಗಂಟೆ ಮತ್ತು ನಿಮಿಷ ನಮೂದಿಸಿ';

  @override
  String quizClosingTimeLabel(String time) {
    return '$time. ಮುಕ್ತಾಯ ಸಮಯ ಹೊಂದಿಸಲು ಓಕೆ ಒತ್ತಿ. ಎಡ ಕೀ ಅದನ್ನು ತೆರವುಗೊಳಿಸುತ್ತದೆ.';
  }

  @override
  String get quizNoClosingTimeSet => 'ಮುಕ್ತಾಯ ಸಮಯ ಹೊಂದಿಸಿಲ್ಲ';

  @override
  String get quizNoClosingTimeShort => 'ಮುಕ್ತಾಯ ಸಮಯವಿಲ್ಲ';

  @override
  String get quizClosingTimeHint => 'ಐಚ್ಛಿಕ · ಆರಂಭ ಸಮಯದ ನಂತರ ಇರಬೇಕು';

  @override
  String get quizShuffleQuestions =>
      'ಪ್ರತಿ ಪ್ರಯತ್ನಕ್ಕೆ ಒಮ್ಮೆ ಪ್ರಶ್ನೆಗಳನ್ನು ಬೆರೆಸಿ';

  @override
  String get quizShuffleOptions => 'ಪ್ರತಿ ಪ್ರಯತ್ನಕ್ಕೆ ಒಮ್ಮೆ ಆಯ್ಕೆಗಳನ್ನು ಬೆರೆಸಿ';

  @override
  String messageProblem(String text) {
    return 'ಸಮಸ್ಯೆ: $text';
  }

  @override
  String messageMessage(String text) {
    return 'ಸಂದೇಶ: $text';
  }

  @override
  String get adminSetupSectionAccounts => 'ಖಾತೆಗಳು';

  @override
  String get adminSetupSectionCatalog => 'ತರಗತಿಗಳು ಮತ್ತು ವಿಷಯಗಳು';

  @override
  String get adminSetupSectionTimetable => 'ವೇಳಾಪಟ್ಟಿ';

  @override
  String get adminSetupSectionSchedule => 'ಇಂದಿನ ವೇಳಾಪಟ್ಟಿ';

  @override
  String get adminSetupSectionSharedPhones => 'ಹಂಚಿಕೊಂಡ ಫೋನ್‌ಗಳು';

  @override
  String get adminSetupSectionHolidays => 'ರಜೆಗಳು';

  @override
  String get adminSetupSectionIssues => 'ಸಮಸ್ಯೆಗಳು';

  @override
  String get adminSetupSectionRecords => 'ತರಗತಿ ದಾಖಲೆಗಳು';

  @override
  String get adminSetupSectionPicker => 'ವಿಭಾಗ';

  @override
  String adminSetupRefresh(String section) {
    return '$section ರಿಫ್ರೆಶ್ ಮಾಡಿ';
  }

  @override
  String get adminSetupLogOut => 'ಲಾಗ್ ಔಟ್';

  @override
  String get adminSetupLoading => 'ಲೋಡ್ ಆಗುತ್ತಿದೆ';

  @override
  String get adminSetupSaving => 'ಉಳಿಸಲಾಗುತ್ತಿದೆ';

  @override
  String get adminSetupRetry => 'ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ';

  @override
  String adminSetupLoadFailed(String reason) {
    return 'ಈ ಪಟ್ಟಿಯನ್ನು ಲೋಡ್ ಮಾಡಲು ಆಗಲಿಲ್ಲ. $reason';
  }

  @override
  String get adminSetupUnknownError =>
      'ಏನೋ ತಪ್ಪಾಗಿದೆ. ದಯವಿಟ್ಟು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get adminSetupNotSaved =>
      'ಬದಲಾವಣೆಯನ್ನು ಉಳಿಸಲು ಆಗಲಿಲ್ಲ. ರಿಫ್ರೆಶ್ ಮಾಡಿ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get adminSetupCancel => 'ರದ್ದುಮಾಡಿ';

  @override
  String get adminSetupSave => 'ಉಳಿಸಿ';

  @override
  String get adminSetupClose => 'ಮುಚ್ಚಿ';

  @override
  String get adminSetupDelete => 'ಅಳಿಸಿ';

  @override
  String get adminSetupRemove => 'ತೆಗೆದುಹಾಕಿ';

  @override
  String get adminSetupEdit => 'ಸಂಪಾದಿಸಿ';

  @override
  String adminSetupEditNamed(String name) {
    return '$name ಸಂಪಾದಿಸಿ';
  }

  @override
  String adminSetupRequiredField(String field) {
    return '$field ಅಗತ್ಯವಿದೆ.';
  }

  @override
  String get adminSetupNoDate => 'ಹೊಂದಿಸಿಲ್ಲ';

  @override
  String adminSetupDateValue(String field, String date) {
    return '$field: $date';
  }

  @override
  String adminSetupClearDate(String field) {
    return '$field ತೆರವುಗೊಳಿಸಿ';
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
  String get adminSetupDateField => 'ದಿನಾಂಕ';

  @override
  String get adminSetupInactive => 'ನಿಷ್ಕ್ರಿಯಗೊಳಿಸಲಾಗಿದೆ';

  @override
  String get adminSetupFilterAll => 'ಎಲ್ಲಾ';

  @override
  String get adminSetupShowFilter => 'ತೋರಿಸಿ';

  @override
  String get adminSetupRoleStudent => 'ವಿದ್ಯಾರ್ಥಿ';

  @override
  String get adminSetupRoleTeacher => 'ಶಿಕ್ಷಕರು';

  @override
  String get adminSetupAddPerson => 'ವ್ಯಕ್ತಿಯನ್ನು ಸೇರಿಸಿ';

  @override
  String get adminSetupSearchLabel => 'ಹೆಸರು ಅಥವಾ ಫೋನ್ ಸಂಖ್ಯೆಯಿಂದ ಹುಡುಕಿ';

  @override
  String get adminSetupSearchButton => 'ಹುಡುಕಿ';

  @override
  String get adminSetupAccountTypeHeading => 'ಖಾತೆಯ ಪ್ರಕಾರ';

  @override
  String get adminSetupAssignmentHeading => 'ತರಗತಿ ಅಥವಾ ವಿಷಯ ನಿಯೋಜನೆ';

  @override
  String adminSetupAccountsShown(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ಖಾತೆಗಳನ್ನು ತೋರಿಸಲಾಗಿದೆ.',
      one: '1 ಖಾತೆ ತೋರಿಸಲಾಗಿದೆ.',
      zero: 'ಹೊಂದುವ ಖಾತೆಗಳಿಲ್ಲ.',
    );
    return '$_temp0';
  }

  @override
  String adminSetupTeachersHeading(int count) {
    return 'ಶಿಕ್ಷಕರು ($count)';
  }

  @override
  String adminSetupStudentsHeading(int count) {
    return 'ವಿದ್ಯಾರ್ಥಿಗಳು ($count)';
  }

  @override
  String get adminSetupNameField => 'ಹೆಸರು';

  @override
  String get adminSetupPhoneField => 'ಫೋನ್ ಸಂಖ್ಯೆ';

  @override
  String get adminSetupRoleField => 'ಪಾತ್ರ';

  @override
  String get adminSetupTeacherPairsHeading =>
      'ಈ ಶಿಕ್ಷಕರು ಕಲಿಸುವ ತರಗತಿಗಳು ಮತ್ತು ವಿಷಯಗಳು';

  @override
  String get adminSetupNoPairs =>
      'ಇನ್ನೂ ಯಾವುದೂ ಇಲ್ಲ. ನೀವು ಅವುಗಳನ್ನು ನಂತರ ಸೇರಿಸಬಹುದು.';

  @override
  String get adminSetupClassField => 'ತರಗತಿ';

  @override
  String get adminSetupSubjectField => 'ವಿಷಯ';

  @override
  String get adminSetupAddPair => 'ತರಗತಿ ಮತ್ತು ವಿಷಯ ಸೇರಿಸಿ';

  @override
  String adminSetupPairLabel(String className, String subject) {
    return '$className, $subject';
  }

  @override
  String adminSetupRemovePair(String className, String subject) {
    return '$className, $subject ತೆಗೆದುಹಾಕಿ';
  }

  @override
  String get adminSetupNoSubjectsInClass =>
      'ಈ ತರಗತಿಯಲ್ಲಿ ಇನ್ನೂ ಯಾವುದೇ ವಿಷಯಗಳಿಲ್ಲ. ತರಗತಿಗಳು ಮತ್ತು ವಿಷಯಗಳು ವಿಭಾಗದಲ್ಲಿ ವಿಷಯಗಳನ್ನು ಸೇರಿಸಿ.';

  @override
  String get adminSetupNoActiveClasses =>
      'ಇನ್ನೂ ಯಾವುದೇ ಸಕ್ರಿಯ ತರಗತಿಗಳಿಲ್ಲ. ತರಗತಿಗಳು ಮತ್ತು ವಿಷಯಗಳು ವಿಭಾಗದಲ್ಲಿ ಒಂದನ್ನು ಸೇರಿಸಿ.';

  @override
  String adminSetupPersonAdded(String name) {
    return '$name ಅವರನ್ನು ಸೇರಿಸಲಾಗಿದೆ.';
  }

  @override
  String adminSetupEditPerson(String name) {
    return '$name ಸಂಪಾದಿಸಿ';
  }

  @override
  String get adminSetupPhoneChangeNote =>
      'ಫೋನ್ ಸಂಖ್ಯೆಯನ್ನು ಬದಲಾಯಿಸಿದರೆ ಈ ವ್ಯಕ್ತಿ ಎಲ್ಲಾ ಫೋನ್‌ಗಳಲ್ಲಿ ಸೈನ್ ಔಟ್ ಆಗುತ್ತಾರೆ.';

  @override
  String adminSetupPersonSaved(String name) {
    return '$name ಅವರ ಬದಲಾವಣೆಗಳನ್ನು ಉಳಿಸಲಾಗಿದೆ.';
  }

  @override
  String get adminSetupDeactivate => 'ನಿಷ್ಕ್ರಿಯಗೊಳಿಸಿ';

  @override
  String get adminSetupActivate => 'ಸಕ್ರಿಯಗೊಳಿಸಿ';

  @override
  String adminSetupDeactivateNamed(String name) {
    return '$name ನಿಷ್ಕ್ರಿಯಗೊಳಿಸಿ';
  }

  @override
  String adminSetupActivateNamed(String name) {
    return '$name ಸಕ್ರಿಯಗೊಳಿಸಿ';
  }

  @override
  String adminSetupDeactivateTitle(String name) {
    return '$name ನಿಷ್ಕ್ರಿಯಗೊಳಿಸಬೇಕೇ?';
  }

  @override
  String adminSetupDeactivateMessage(String name) {
    return '$name ಸೈನ್ ಔಟ್ ಆಗುತ್ತಾರೆ ಮತ್ತು ಖಾತೆಯನ್ನು ಮತ್ತೆ ಸಕ್ರಿಯಗೊಳಿಸುವವರೆಗೆ ಸೈನ್ ಇನ್ ಮಾಡಲು ಸಾಧ್ಯವಿಲ್ಲ.';
  }

  @override
  String adminSetupActivated(String name) {
    return '$name ಮತ್ತೆ ಸೈನ್ ಇನ್ ಮಾಡಬಹುದು.';
  }

  @override
  String adminSetupDeactivated(String name) {
    return '$name ಅವರನ್ನು ನಿಷ್ಕ್ರಿಯಗೊಳಿಸಲಾಗಿದೆ.';
  }

  @override
  String get adminSetupSignOutEverywhere => 'ಎಲ್ಲೆಡೆ ಸೈನ್ ಔಟ್ ಮಾಡಿ';

  @override
  String adminSetupSignOutNamed(String name) {
    return '$name ಅವರನ್ನು ಎಲ್ಲೆಡೆ ಸೈನ್ ಔಟ್ ಮಾಡಿ';
  }

  @override
  String adminSetupSignOutTitle(String name) {
    return '$name ಅವರನ್ನು ಎಲ್ಲೆಡೆ ಸೈನ್ ಔಟ್ ಮಾಡಬೇಕೇ?';
  }

  @override
  String adminSetupSignOutMessage(String name) {
    return 'ಇದು ಎಲ್ಲಾ ಫೋನ್‌ಗಳಲ್ಲಿ $name ಅವರ ಸೈನ್ ಇನ್ ಅನ್ನು ಕೊನೆಗೊಳಿಸುತ್ತದೆ, ಉದಾಹರಣೆಗೆ ಬೇರೆ ಯಾರಾದರೂ ಅವರ ಸಂಖ್ಯೆಯನ್ನು ಬಳಸಿದ್ದರೆ. ಅವರು ತಮ್ಮ ಫೋನ್ ಸಂಖ್ಯೆಯಿಂದ ಮತ್ತೆ ಸೈನ್ ಇನ್ ಮಾಡಬಹುದು.';
  }

  @override
  String adminSetupSignedOut(String name) {
    return '$name ಅವರನ್ನು ಎಲ್ಲೆಡೆ ಸೈನ್ ಔಟ್ ಮಾಡಲಾಗಿದೆ.';
  }

  @override
  String get adminSetupStudentClassAction => 'ತರಗತಿ ಬದಲಾಯಿಸಿ';

  @override
  String get adminSetupTeacherAssignmentsAction => 'ತರಗತಿಗಳು ಮತ್ತು ವಿಷಯಗಳು';

  @override
  String adminSetupStudentDetail(String className) {
    return 'ವಿದ್ಯಾರ್ಥಿ. ತರಗತಿ: $className';
  }

  @override
  String get adminSetupStudentNoClass => 'ವಿದ್ಯಾರ್ಥಿ. ಇನ್ನೂ ತರಗತಿ ಇಲ್ಲ.';

  @override
  String adminSetupTeacherDetail(String pairs) {
    return 'ಶಿಕ್ಷಕರು. ಕಲಿಸುವುದು: $pairs';
  }

  @override
  String get adminSetupTeacherNoPairs =>
      'ಶಿಕ್ಷಕರು. ಇನ್ನೂ ತರಗತಿಗಳು ಅಥವಾ ವಿಷಯಗಳಿಲ್ಲ.';

  @override
  String adminSetupPhoneDetail(String phone) {
    return 'ಫೋನ್: $phone';
  }

  @override
  String adminSetupClassDialogTitle(String name) {
    return '$name ಅವರ ತರಗತಿ';
  }

  @override
  String adminSetupRemoveFromClass(String className) {
    return '$className ನಿಂದ ತೆಗೆದುಹಾಕಿ';
  }

  @override
  String adminSetupStudentEnrolled(String name, String className) {
    return '$name ಈಗ $className ನಲ್ಲಿದ್ದಾರೆ.';
  }

  @override
  String adminSetupStudentRemoved(String name) {
    return '$name ಅವರನ್ನು ಅವರ ತರಗತಿಯಿಂದ ತೆಗೆದುಹಾಕಲಾಗಿದೆ.';
  }

  @override
  String adminSetupAssignmentsTitle(String name) {
    return '$name ಅವರ ತರಗತಿಗಳು ಮತ್ತು ವಿಷಯಗಳು';
  }

  @override
  String get adminSetupCurrentPairs => 'ಈಗ ಕಲಿಸುತ್ತಿರುವುದು';

  @override
  String adminSetupPairAdded(String name, String className, String subject) {
    return '$name ಈಗ $className, $subject ಕಲಿಸುತ್ತಾರೆ.';
  }

  @override
  String adminSetupPairRemoved(String name, String className, String subject) {
    return '$name ಇನ್ನು ಮುಂದೆ $className, $subject ಕಲಿಸುವುದಿಲ್ಲ.';
  }

  @override
  String get adminSetupClassesHeading => 'ತರಗತಿಗಳು';

  @override
  String get adminSetupSubjectsHeading => 'ವಿಷಯಗಳು';

  @override
  String get adminSetupAddClass => 'ತರಗತಿ ಸೇರಿಸಿ';

  @override
  String get adminSetupAddSubject => 'ವಿಷಯ ಸೇರಿಸಿ';

  @override
  String get adminSetupNoClasses => 'ಇನ್ನೂ ಯಾವುದೇ ತರಗತಿಗಳಿಲ್ಲ.';

  @override
  String get adminSetupNoSubjects => 'ಇನ್ನೂ ಯಾವುದೇ ವಿಷಯಗಳಿಲ್ಲ.';

  @override
  String get adminSetupSubjectsButton => 'ವಿಷಯಗಳು';

  @override
  String adminSetupClassSubjects(String className) {
    return '$className ನಲ್ಲಿನ ವಿಷಯಗಳು';
  }

  @override
  String adminSetupArchiveNamed(String name) {
    return '$name ಆರ್ಕೈವ್ ಮಾಡಿ';
  }

  @override
  String adminSetupRestoreNamed(String name) {
    return '$name ಮರುಸ್ಥಾಪಿಸಿ';
  }

  @override
  String get adminSetupNoSubjectsToChoose =>
      'ಇನ್ನೂ ಯಾವುದೇ ಸಕ್ರಿಯ ವಿಷಯಗಳಿಲ್ಲ. ಮೊದಲು ಒಂದು ವಿಷಯವನ್ನು ಸೇರಿಸಿ.';

  @override
  String get adminSetupAddLesson => 'ವೇಳಾಪಟ್ಟಿಗೆ ಪಾಠ ಸೇರಿಸಿ';

  @override
  String get adminSetupEditLesson => 'ವೇಳಾಪಟ್ಟಿಯ ಪಾಠವನ್ನು ಸಂಪಾದಿಸಿ';

  @override
  String get adminSetupAllTeachers => 'ಎಲ್ಲಾ ಶಿಕ್ಷಕರು';

  @override
  String get adminSetupAllClasses => 'ಎಲ್ಲಾ ತರಗತಿಗಳು';

  @override
  String get adminSetupTeacherField => 'ಶಿಕ್ಷಕರು';

  @override
  String get adminSetupWeekdayField => 'ವಾರದ ದಿನ';

  @override
  String get adminSetupStartField => 'ಪ್ರಾರಂಭ ಸಮಯ';

  @override
  String get adminSetupEndField => 'ಮುಕ್ತಾಯ ಸಮಯ';

  @override
  String get adminSetupTimeHelper =>
      '24 ಗಂಟೆಯ ಭಾರತೀಯ ಸಮಯ (IST), ಉದಾಹರಣೆಗೆ 09:30';

  @override
  String adminSetupTimeInvalid(String field) {
    return '$field ಅನ್ನು 24 ಗಂಟೆಯ ಸಮಯವಾಗಿ ನಮೂದಿಸಿ, ಉದಾಹರಣೆಗೆ 09:30.';
  }

  @override
  String get adminSetupEndBeforeStart => 'ಪಾಠವು ಪ್ರಾರಂಭವಾದ ನಂತರವೇ ಮುಗಿಯಬೇಕು.';

  @override
  String get adminSetupUntilBeforeFrom =>
      'ಕೊನೆಯ ದಿನಾಂಕವು ಮೊದಲ ದಿನಾಂಕದಂದು ಅಥವಾ ಅದರ ನಂತರ ಇರಬೇಕು.';

  @override
  String get adminSetupValidFrom => 'ಮೊದಲ ದಿನಾಂಕ';

  @override
  String get adminSetupValidUntil => 'ಕೊನೆಯ ದಿನಾಂಕ';

  @override
  String get adminSetupLessonField => 'ಪಾಠದ ಪ್ಲೇಲಿಸ್ಟ್ (ಐಚ್ಛಿಕ)';

  @override
  String get adminSetupNoLesson => 'ಪಾಠದ ಪ್ಲೇಲಿಸ್ಟ್ ಇಲ್ಲ';

  @override
  String get adminSetupNoLessonsFound =>
      'ಈ ಶಿಕ್ಷಕರಿಗೆ ಈ ತರಗತಿ ಮತ್ತು ವಿಷಯಕ್ಕೆ ಇನ್ನೂ ಯಾವುದೇ ಪಾಠದ ಪ್ಲೇಲಿಸ್ಟ್‌ಗಳಿಲ್ಲ.';

  @override
  String get adminSetupShowInactive => 'ನಿಷ್ಕ್ರಿಯಗೊಳಿಸಿದ ಪಾಠಗಳನ್ನು ತೋರಿಸಿ';

  @override
  String get adminSetupNoTimetable => 'ಯಾವುದೇ ವೇಳಾಪಟ್ಟಿ ಪಾಠಗಳು ಹೊಂದುತ್ತಿಲ್ಲ.';

  @override
  String adminSetupEntryTitle(
    String start,
    String end,
    String subject,
    String className,
  ) {
    return '$start ರಿಂದ $end: $subject, $className';
  }

  @override
  String adminSetupEntryTeacher(String name) {
    return 'ಶಿಕ್ಷಕರು: $name';
  }

  @override
  String adminSetupEntryLesson(String title) {
    return 'ಪಾಠದ ಪ್ಲೇಲಿಸ್ಟ್: $title';
  }

  @override
  String get adminSetupEntryNoLesson => 'ಯಾವುದೇ ಪಾಠದ ಪ್ಲೇಲಿಸ್ಟ್ ಆರಿಸಿಲ್ಲ.';

  @override
  String adminSetupEntryFrom(String date) {
    return '$date ರಿಂದ';
  }

  @override
  String adminSetupEntryUntil(String date) {
    return '$date ವರೆಗೆ';
  }

  @override
  String get adminSetupDateChanges => 'ದಿನಾಂಕ ಬದಲಾವಣೆಗಳು';

  @override
  String adminSetupDateChangesNamed(String title) {
    return '$title ಗಾಗಿ ದಿನಾಂಕ ಬದಲಾವಣೆಗಳು';
  }

  @override
  String get adminSetupDeactivateLesson => 'ನಿಷ್ಕ್ರಿಯಗೊಳಿಸಿ';

  @override
  String get adminSetupReactivateLesson => 'ಮತ್ತೆ ಸಕ್ರಿಯಗೊಳಿಸಿ';

  @override
  String get adminSetupDeactivateLessonTitle =>
      'ಈ ಪಾಠವನ್ನು ನಿಷ್ಕ್ರಿಯಗೊಳಿಸಬೇಕೇ?';

  @override
  String adminSetupDeactivateLessonMessage(
    String subject,
    String className,
    String weekday,
    String start,
  ) {
    return '$weekday ರಂದು $start ಕ್ಕೆ $className ಗಾಗಿ ಇರುವ $subject ಇನ್ನು ಮುಂದೆ ವೇಳಾಪಟ್ಟಿಯಲ್ಲಿ ಇರುವುದಿಲ್ಲ.';
  }

  @override
  String get adminSetupLessonSaved => 'ವೇಳಾಪಟ್ಟಿಯನ್ನು ಉಳಿಸಲಾಗಿದೆ.';

  @override
  String get adminSetupLessonDeactivated => 'ಪಾಠವನ್ನು ನಿಷ್ಕ್ರಿಯಗೊಳಿಸಲಾಗಿದೆ.';

  @override
  String get adminSetupLessonReactivated => 'ಪಾಠವನ್ನು ಮತ್ತೆ ಸಕ್ರಿಯಗೊಳಿಸಲಾಗಿದೆ.';

  @override
  String adminSetupClassSubjectFixed(String className, String subject) {
    return '$className, $subject. ತರಗತಿ ಅಥವಾ ವಿಷಯವನ್ನು ಬದಲಾಯಿಸಲು, ಈ ಪಾಠವನ್ನು ನಿಷ್ಕ್ರಿಯಗೊಳಿಸಿ ಮತ್ತು ಹೊಸದನ್ನು ಸೇರಿಸಿ.';
  }

  @override
  String adminSetupDateChangesTitle(String lesson, String weekday) {
    return 'ದಿನಾಂಕ ಬದಲಾವಣೆಗಳು: $lesson, ಪ್ರತಿ $weekday';
  }

  @override
  String get adminSetupNoDateChanges => 'ಯಾವುದೇ ದಿನಾಂಕ ಬದಲಾವಣೆಗಳಿಲ್ಲ.';

  @override
  String get adminSetupAddDateChange => 'ಒಂದು ದಿನಾಂಕವನ್ನು ಬದಲಾಯಿಸಿ';

  @override
  String get adminSetupCancelledLabel => 'ಈ ದಿನಾಂಕದಂದು ರದ್ದಾಗಿದೆ.';

  @override
  String adminSetupSubstituteLabel(String name) {
    return 'ಬದಲಿ ಶಿಕ್ಷಕರು: $name';
  }

  @override
  String get adminSetupDifferentLesson =>
      'ಈ ದಿನಾಂಕದಂದು ಬೇರೆ ಪಾಠದ ಪ್ಲೇಲಿಸ್ಟ್ ಬಳಸಲಾಗುತ್ತದೆ.';

  @override
  String adminSetupNoteLabel(String note) {
    return 'ಟಿಪ್ಪಣಿ: $note';
  }

  @override
  String get adminSetupClearChange => 'ಬದಲಾವಣೆ ತೆರವುಗೊಳಿಸಿ';

  @override
  String adminSetupClearChangeNamed(String date) {
    return '$date ರ ಬದಲಾವಣೆಯನ್ನು ತೆರವುಗೊಳಿಸಿ';
  }

  @override
  String adminSetupEditDateChangeNamed(String date) {
    return '$date ರ ಬದಲಾವಣೆಯನ್ನು ಸಂಪಾದಿಸಿ';
  }

  @override
  String adminSetupChangeCleared(String date) {
    return '$date ರ ಬದಲಾವಣೆಯನ್ನು ತೆರವುಗೊಳಿಸಲಾಗಿದೆ.';
  }

  @override
  String adminSetupDateChangeTitle(String lesson) {
    return 'ಒಂದು ದಿನಾಂಕವನ್ನು ಬದಲಾಯಿಸಿ: $lesson';
  }

  @override
  String get adminSetupCancelOnDate => 'ಈ ದಿನಾಂಕದಂದು ಪಾಠವನ್ನು ರದ್ದುಮಾಡಿ';

  @override
  String get adminSetupSubstituteField => 'ಬದಲಿ ಶಿಕ್ಷಕರು (ಐಚ್ಛಿಕ)';

  @override
  String adminSetupRegularTeacher(String name) {
    return 'ಬದಲಿ ಇಲ್ಲ ($name ಕಲಿಸುತ್ತಾರೆ)';
  }

  @override
  String get adminSetupDateLessonField => 'ಈ ದಿನಾಂಕದ ಪಾಠದ ಪ್ಲೇಲಿಸ್ಟ್';

  @override
  String get adminSetupUsualLesson => 'ಎಂದಿನಂತೆ';

  @override
  String get adminSetupNoteField => 'ಟಿಪ್ಪಣಿ (ಐಚ್ಛಿಕ)';

  @override
  String adminSetupDateChangeSaved(String date) {
    return '$date ರ ಬದಲಾವಣೆಯನ್ನು ಉಳಿಸಲಾಗಿದೆ.';
  }

  @override
  String get adminSetupChooseDateFirst => 'ಒಂದು ದಿನಾಂಕವನ್ನು ಆರಿಸಿ.';

  @override
  String get adminSetupPreviousDay => 'ಹಿಂದಿನ ದಿನ';

  @override
  String get adminSetupNextDay => 'ಮುಂದಿನ ದಿನ';

  @override
  String get adminSetupToday => 'ಇಂದು';

  @override
  String adminSetupScheduleFor(String date) {
    return '$date ರ ಪಾಠಗಳು';
  }

  @override
  String get adminSetupNoLessonsOnDay => 'ಈ ದಿನಾಂಕದಂದು ಯಾವುದೇ ಪಾಠಗಳಿಲ್ಲ.';

  @override
  String adminSetupScheduleSubstitute(String name) {
    return 'ಶಿಕ್ಷಕರು: $name (ಬದಲಿ)';
  }

  @override
  String adminSetupStateLabel(String state) {
    return 'ಸ್ಥಿತಿ: $state';
  }

  @override
  String get adminSetupStateUpcoming => 'ಮುಂಬರುವ';

  @override
  String get adminSetupStateLive => 'ಈಗ ನೇರಪ್ರಸಾರದಲ್ಲಿದೆ';

  @override
  String get adminSetupStateHeld => 'ನಡೆದಿದೆ';

  @override
  String get adminSetupStateCancelled => 'ರದ್ದಾಗಿದೆ';

  @override
  String get adminSetupStateNotStarted => 'ಪ್ರಾರಂಭವಾಗಲಿಲ್ಲ';

  @override
  String get adminSetupLessonReady => 'ಪಾಠದ ಪ್ಲೇಲಿಸ್ಟ್ ಸಿದ್ಧವಾಗಿದೆ.';

  @override
  String get adminSetupSharedPhoneNote =>
      'ಹಂಚಿಕೊಂಡ ಫೋನ್‌ನಲ್ಲಿ, ಪ್ರತಿಯೊಬ್ಬರೂ ಹಂಚಿಕೊಂಡ ಫೋನ್ ಸಂಖ್ಯೆಯನ್ನು ನಮೂದಿಸಿ, ನಂತರ ತಮ್ಮ ಚಿಕ್ಕ ಪ್ರೊಫೈಲ್ ಸಂಖ್ಯೆಯನ್ನು ನಮೂದಿಸುತ್ತಾರೆ. ಪ್ರೊಫೈಲ್ ಸಂಖ್ಯೆ ಯಾರ ಖಾತೆ ತೆರೆಯಬೇಕು ಎಂಬುದನ್ನು ಮಾತ್ರ ಆಯ್ಕೆ ಮಾಡುತ್ತದೆ. ಇದು ಪಾಸ್‌ವರ್ಡ್ ಅಲ್ಲ.';

  @override
  String get adminSetupAddSharedPhone => 'ಹಂಚಿಕೊಂಡ ಫೋನ್ ಸೇರಿಸಿ';

  @override
  String get adminSetupEditSharedPhone => 'ಹಂಚಿಕೊಂಡ ಫೋನ್ ಬದಲಿಸಿ';

  @override
  String get adminSetupSharedPhoneName => 'ಹೆಸರು, ಉದಾಹರಣೆಗೆ ತರಗತಿ 5 ಫೋನ್';

  @override
  String get adminSetupSharedPhoneNumber => 'ಹಂಚಿಕೊಂಡ ಫೋನ್ ಸಂಖ್ಯೆ';

  @override
  String get adminSetupSharedPhoneActiveSwitch => 'ಹಂಚಿಕೊಂಡ ಫೋನ್ ಬಳಸಬಹುದು';

  @override
  String get adminSetupSharedPhoneSaved => 'ಹಂಚಿಕೊಂಡ ಫೋನ್ ಉಳಿಸಲಾಗಿದೆ.';

  @override
  String get adminSetupNoSharedPhones => 'ಇನ್ನೂ ಯಾವುದೇ ಹಂಚಿಕೊಂಡ ಫೋನ್‌ಗಳಿಲ್ಲ.';

  @override
  String adminSetupGroupNumber(String phone) {
    return 'ಸಂಖ್ಯೆ: $phone';
  }

  @override
  String adminSetupMemberLine(String name, String role, String code) {
    return '$name, $role. ಪ್ರೊಫೈಲ್ ಸಂಖ್ಯೆ $code';
  }

  @override
  String get adminSetupNoMembers => 'ಈ ಫೋನ್‌ನಲ್ಲಿ ಇನ್ನೂ ಯಾರೂ ಇಲ್ಲ.';

  @override
  String get adminSetupAddMember => 'ವ್ಯಕ್ತಿಯನ್ನು ಸೇರಿಸಿ';

  @override
  String adminSetupAddMemberTitle(String group) {
    return '$group ಗೆ ಒಬ್ಬ ವ್ಯಕ್ತಿಯನ್ನು ಸೇರಿಸಿ';
  }

  @override
  String get adminSetupSearchPeople =>
      'ಹೆಸರು ಅಥವಾ ಫೋನ್ ಸಂಖ್ಯೆಯಿಂದ ಜನರನ್ನು ಹುಡುಕಿ';

  @override
  String get adminSetupNoPeopleFound => 'ಹೊಂದುವ ಜನರು ಇಲ್ಲ.';

  @override
  String get adminSetupPersonField => 'ವ್ಯಕ್ತಿ';

  @override
  String adminSetupPersonOption(String name, String role, String phone) {
    return '$name, $role, $phone';
  }

  @override
  String get adminSetupChoosePerson => 'ಒಬ್ಬ ವ್ಯಕ್ತಿಯನ್ನು ಆಯ್ಕೆ ಮಾಡಿ.';

  @override
  String get adminSetupProfileCodeField => 'ಪ್ರೊಫೈಲ್ ಸಂಖ್ಯೆ';

  @override
  String get adminSetupProfileCodeHelper =>
      '1 ರಿಂದ 4 ಅಂಕಿಗಳು, ಈ ಫೋನ್‌ನಲ್ಲಿ ಪ್ರತಿಯೊಬ್ಬರಿಗೂ ಬೇರೆ ಬೇರೆ.';

  @override
  String get adminSetupProfileCodeInvalid =>
      '1 ರಿಂದ 4 ಅಂಕಿಗಳ ಪ್ರೊಫೈಲ್ ಸಂಖ್ಯೆಯನ್ನು ನಮೂದಿಸಿ.';

  @override
  String adminSetupMemberAdded(String name, String group) {
    return '$name ಅವರನ್ನು $group ಗೆ ಸೇರಿಸಲಾಗಿದೆ.';
  }

  @override
  String adminSetupRemoveMemberNamed(String name, String group) {
    return '$name ಅವರನ್ನು $group ಇಂದ ತೆಗೆದುಹಾಕಿ';
  }

  @override
  String adminSetupRemoveMemberTitle(String name, String group) {
    return '$name ಅವರನ್ನು $group ಇಂದ ತೆಗೆದುಹಾಕಬೇಕೆ?';
  }

  @override
  String adminSetupRemoveMemberMessage(String name) {
    return '$name ಅವರು ಇನ್ನು ಮುಂದೆ ಈ ಹಂಚಿಕೊಂಡ ಫೋನ್‌ನಲ್ಲಿ ತಮ್ಮ ಪ್ರೊಫೈಲ್ ಆಯ್ಕೆ ಮಾಡಲು ಸಾಧ್ಯವಿಲ್ಲ.';
  }

  @override
  String adminSetupMemberRemoved(String name, String group) {
    return '$name ಅವರನ್ನು $group ಇಂದ ತೆಗೆದುಹಾಕಲಾಗಿದೆ.';
  }

  @override
  String get adminSetupHolidayNote =>
      'ರಜಾದಿನಗಳಲ್ಲಿ ಯಾವುದೇ ಪಾಠಗಳನ್ನು ನಿಗದಿಪಡಿಸಲಾಗುವುದಿಲ್ಲ.';

  @override
  String get adminSetupAddHoliday => 'ರಜಾದಿನ ಸೇರಿಸಿ';

  @override
  String get adminSetupHolidayName => 'ರಜಾದಿನದ ಹೆಸರು';

  @override
  String get adminSetupNoHolidays => 'ಇನ್ನೂ ಯಾವುದೇ ರಜಾದಿನಗಳಿಲ್ಲ.';

  @override
  String adminSetupHolidayAdded(String name, String date) {
    return '$date ರಂದು $name ಸೇರಿಸಲಾಗಿದೆ.';
  }

  @override
  String adminSetupDeleteHolidayNamed(String name, String date) {
    return '$date ರಂದು $name ಅಳಿಸಿ';
  }

  @override
  String get adminSetupDeleteHolidayTitle => 'ಈ ರಜಾದಿನವನ್ನು ಅಳಿಸಬೇಕೆ?';

  @override
  String adminSetupDeleteHolidayMessage(String name, String date) {
    return '$date ರಂದು $name ತೆಗೆದುಹಾಕಲಾಗುತ್ತದೆ, ಮತ್ತು ಆ ದಿನಾಂಕದಂದು ಮತ್ತೆ ಪಾಠಗಳನ್ನು ನಿಗದಿಪಡಿಸಲಾಗುತ್ತದೆ.';
  }

  @override
  String get adminSetupHolidayDeleted => 'ರಜಾದಿನವನ್ನು ಅಳಿಸಲಾಗಿದೆ.';

  @override
  String get adminSetupIssuesOpen => 'ಬಗೆಹರಿದಿಲ್ಲ';

  @override
  String get adminSetupIssuesResolved => 'ಬಗೆಹರಿದಿದೆ';

  @override
  String get adminSetupNoIssues => 'ತೋರಿಸಲು ಯಾವುದೇ ಸಮಸ್ಯೆಗಳಿಲ್ಲ.';

  @override
  String adminSetupIssueSeen(int count, String when) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ಬಾರಿ ಕಂಡುಬಂದಿದೆ.',
      one: 'ಒಮ್ಮೆ ಕಂಡುಬಂದಿದೆ.',
    );
    return '$_temp0 ಕೊನೆಯದಾಗಿ ಕಂಡುಬಂದದ್ದು $when.';
  }

  @override
  String get adminSetupMarkResolved => 'ಬಗೆಹರಿದಿದೆ ಎಂದು ಗುರುತಿಸಿ';

  @override
  String adminSetupMarkResolvedNamed(String message) {
    return 'ಬಗೆಹರಿದಿದೆ ಎಂದು ಗುರುತಿಸಿ: $message';
  }

  @override
  String get adminSetupIssueResolved =>
      'ಸಮಸ್ಯೆಯನ್ನು ಬಗೆಹರಿದಿದೆ ಎಂದು ಗುರುತಿಸಲಾಗಿದೆ.';

  @override
  String get adminSetupRecordsLive => 'ಲೈವ್';

  @override
  String get adminSetupRecordsEnded => 'ಮುಗಿದಿದೆ';

  @override
  String get adminSetupNoRecords => 'ತೋರಿಸಲು ಯಾವುದೇ ತರಗತಿಗಳಿಲ್ಲ.';

  @override
  String adminSetupRecordTitle(String subject, String className) {
    return '$subject, $className';
  }

  @override
  String get adminSetupRecordLive => 'ಈಗ ಲೈವ್';

  @override
  String adminSetupRecordLiveUntil(String clock) {
    return 'ಈಗ ಲೈವ್. $clock ಕ್ಕೆ ಮುಗಿಯುತ್ತದೆ';
  }

  @override
  String adminSetupRecordStarted(String when) {
    return 'ಪ್ರಾರಂಭವಾಯಿತು $when';
  }

  @override
  String adminSetupRecordEnded(String when) {
    return 'ಮುಗಿಯಿತು $when';
  }

  @override
  String get adminSetupEndedByTeacher => 'ಶಿಕ್ಷಕರು ತರಗತಿಯನ್ನು ಮುಗಿಸಿದರು.';

  @override
  String get adminSetupEndedByAdmin => 'ನಿರ್ವಾಹಕರು ತರಗತಿಯನ್ನು ಮುಗಿಸಿದರು.';

  @override
  String get adminSetupEndedAutomatically =>
      'ತರಗತಿ ತನ್ನ ಮುಕ್ತಾಯ ಸಮಯಕ್ಕೆ ತಾನಾಗಿಯೇ ಮುಗಿಯಿತು.';

  @override
  String adminSetupEndedOther(String reason) {
    return 'ಮುಗಿದ ಕಾರಣ: $reason';
  }

  @override
  String adminSetupStudentsJoined(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ವಿದ್ಯಾರ್ಥಿಗಳು ಸೇರಿದರು.',
      one: '1 ವಿದ್ಯಾರ್ಥಿ ಸೇರಿದರು.',
      zero: 'ಯಾವುದೇ ವಿದ್ಯಾರ್ಥಿ ಸೇರಲಿಲ್ಲ.',
    );
    return '$_temp0';
  }

  @override
  String adminSetupExtensionMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ಹೆಚ್ಚುವರಿ ನಿಮಿಷಗಳನ್ನು ಸೇರಿಸಲಾಗಿದೆ.',
      one: '1 ಹೆಚ್ಚುವರಿ ನಿಮಿಷ ಸೇರಿಸಲಾಗಿದೆ.',
      zero: 'ಯಾವುದೇ ಹೆಚ್ಚುವರಿ ಸಮಯ ಸೇರಿಸಿಲ್ಲ.',
    );
    return '$_temp0';
  }

  @override
  String get adminSetupAddFifteen => '15 ನಿಮಿಷ ಸೇರಿಸಿ';

  @override
  String adminSetupAddFifteenNamed(String title) {
    return '$title ಗೆ 15 ನಿಮಿಷ ಸೇರಿಸಿ';
  }

  @override
  String get adminSetupEndForEveryone => 'ಎಲ್ಲರಿಗೂ ತರಗತಿ ಮುಗಿಸಿ';

  @override
  String adminSetupEndForEveryoneNamed(String title) {
    return 'ಎಲ್ಲರಿಗೂ $title ಮುಗಿಸಿ';
  }

  @override
  String get adminSetupEndTitle => 'ಎಲ್ಲರಿಗೂ ಈ ತರಗತಿಯನ್ನು ಮುಗಿಸಬೇಕೆ?';

  @override
  String adminSetupEndMessage(String title) {
    return '$title ಶಿಕ್ಷಕರು ಮತ್ತು ಪ್ರತಿಯೊಬ್ಬ ವಿದ್ಯಾರ್ಥಿಗೂ ಈಗಲೇ ಮುಗಿಯುತ್ತದೆ.';
  }

  @override
  String get adminSetupKeepClass => 'ತರಗತಿ ಮುಂದುವರಿಸಿ';

  @override
  String get adminSetupEndClass => 'ತರಗತಿ ಮುಗಿಸಿ';

  @override
  String get adminSetupEnded => 'ತರಗತಿಯನ್ನು ಮುಗಿಸಲಾಗಿದೆ.';

  @override
  String adminSetupExtended(String clock) {
    return 'ತರಗತಿ ಈಗ $clock ಕ್ಕೆ ಮುಗಿಯುತ್ತದೆ.';
  }

  @override
  String get loginScreenName => 'ಸೈನ್ ಇನ್';

  @override
  String get loginIntro =>
      'ನಿಮ್ಮ ಫೋನ್ ಸಂಖ್ಯೆಯನ್ನು ಟೈಪ್ ಮಾಡಿ, ನಂತರ ಸೈನ್ ಇನ್ ಮಾಡಲು 1 ಒತ್ತಿ.';

  @override
  String get loginPhoneField => 'ಫೋನ್ ಸಂಖ್ಯೆ. ಸಂಖ್ಯೆ ಕೀಗಳಿಂದ ಟೈಪ್ ಮಾಡಿ.';

  @override
  String get loginPhoneLabel => 'ಫೋನ್ ಸಂಖ್ಯೆ';

  @override
  String get loginProfileField => 'ಈ ಹಂಚಿಕೊಂಡ ಫೋನ್‌ನಲ್ಲಿ ನಿಮ್ಮ ಪ್ರೊಫೈಲ್ ಸಂಖ್ಯೆ';

  @override
  String get loginProfileLabel => 'ಪ್ರೊಫೈಲ್ ಸಂಖ್ಯೆ';

  @override
  String get loginEnterProfileCode =>
      'ಈ ಫೋನ್ ಹಂಚಿಕೊಂಡದ್ದು. ನಿಮ್ಮ ಪ್ರೊಫೈಲ್ ಸಂಖ್ಯೆಯನ್ನು ಟೈಪ್ ಮಾಡಿ, ನಂತರ 1 ಒತ್ತಿ.';

  @override
  String get loginKeySignIn => 'ಸೈನ್ ಇನ್';

  @override
  String get loginKeyContinue => 'ಮುಂದುವರಿಸಿ';

  @override
  String get loginKeySim => 'SIM ಕಾರ್ಡ್‌ನಿಂದ ನನ್ನ ಸಂಖ್ಯೆಯನ್ನು ತುಂಬಿಸಿ';

  @override
  String get loginKeyAdmin => 'ನಿರ್ವಾಹಕರ ಸೈನ್ ಇನ್';

  @override
  String get loginKeyChangeNumber => 'ಬೇರೆ ಸಂಖ್ಯೆ ಬಳಸಿ';

  @override
  String get loginErrorEnterPhone => 'ಮೊದಲು ನಿಮ್ಮ ಫೋನ್ ಸಂಖ್ಯೆಯನ್ನು ಟೈಪ್ ಮಾಡಿ.';

  @override
  String get loginErrorEnterProfile =>
      'ಮೊದಲು ನಿಮ್ಮ ಪ್ರೊಫೈಲ್ ಸಂಖ್ಯೆಯನ್ನು ಟೈಪ್ ಮಾಡಿ.';

  @override
  String get loginNumberNotRegistered =>
      'ಈ ಸಂಖ್ಯೆ ನೋಂದಣಿಯಾಗಿಲ್ಲ. ನಿಮ್ಮನ್ನು ಸೇರಿಸಲು ನಿಮ್ಮ ಶಾಲೆಯ ನಿರ್ವಾಹಕರನ್ನು ಕೇಳಿ.';

  @override
  String get loginProfileNotRecognised =>
      'ಆ ಪ್ರೊಫೈಲ್ ಸಂಖ್ಯೆ ಈ ಫೋನ್‌ನಲ್ಲಿ ಇಲ್ಲ. ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get loginAdminUsesPassword =>
      'ನಿರ್ವಾಹಕರು ಪಾಸ್‌ವರ್ಡ್‌ನಿಂದ ಸೈನ್ ಇನ್ ಮಾಡುತ್ತಾರೆ. 3 ಒತ್ತಿ.';

  @override
  String get loginSigningIn => 'ಸೈನ್ ಇನ್ ಆಗುತ್ತಿದೆ.';

  @override
  String get adminLoginScreenName => 'ನಿರ್ವಾಹಕರ ಸೈನ್ ಇನ್';

  @override
  String get adminLoginIntro =>
      'ನಿಮ್ಮ ಫೋನ್ ಸಂಖ್ಯೆ ಮತ್ತು ಪಾಸ್‌ವರ್ಡ್ ಟೈಪ್ ಮಾಡಿ, ನಂತರ 1 ಒತ್ತಿ.';

  @override
  String get classNoLongerLive => 'ಆ ತರಗತಿ ಈಗ ಲೈವ್ ಇಲ್ಲ.';

  @override
  String get classAlertTitle => 'ತರಗತಿ ಪ್ರಾರಂಭವಾಗಿದೆ';

  @override
  String get classAlertBody => 'ನಿಮ್ಮ ತರಗತಿ ಪ್ರಾರಂಭವಾಗಿದೆ. ಸೇರಲು ತೆರೆಯಿರಿ.';

  @override
  String get classAlertWaitingBody => 'ನಿಮ್ಮ ತರಗತಿ ಲೈವ್ ಆಗಿದೆ. ಸೇರಲು ತೆರೆಯಿರಿ.';

  @override
  String get classAlertChannelName => 'ತರಗತಿ ಪ್ರಾರಂಭವಾಗುತ್ತಿದೆ';

  @override
  String get classAlertChannelDescription =>
      'ನಿಮ್ಮ ತರಗತಿ ಪ್ರಾರಂಭವಾದಾಗ ಒಂದು ನಿಮಿಷದವರೆಗೆ ರಿಂಗ್ ಆಗುತ್ತದೆ.';

  @override
  String get classAlertWaitingChannelName => 'ತರಗತಿ ಲೈವ್';

  @override
  String get classAlertWaitingChannelDescription =>
      'ನೀವು ಸೇರಲು ಸಾಧ್ಯವಾಗುವಂತೆ ನಿಮ್ಮ ತರಗತಿ ಲೈವ್ ಇರುವವರೆಗೆ ಇರುತ್ತದೆ.';

  @override
  String get classAlertStarted => 'ನಿಮ್ಮ ತರಗತಿ ಪ್ರಾರಂಭವಾಗಿದೆ.';

  @override
  String classAlertSubjectStarted(String subject) {
    return '$subject ತರಗತಿ ಪ್ರಾರಂಭವಾಗಿದೆ.';
  }

  @override
  String get classAlertKeys =>
      'ಸೇರಲು ಓಕೆ ಅಥವಾ 1 ಒತ್ತಿ. ರಿಂಗ್ ನಿಲ್ಲಿಸಲು 0 ಒತ್ತಿ.';

  @override
  String get classAlertJoin => 'ತರಗತಿಗೆ ಸೇರಿ';

  @override
  String get classAlertNotNow => 'ಈಗ ಬೇಡ';

  @override
  String get homeTitle => 'ಮುಖಪುಟ';

  @override
  String get homeChecking => 'ನಿಮ್ಮ ತರಗತಿಗಾಗಿ ಪರಿಶೀಲಿಸಲಾಗುತ್ತಿದೆ.';

  @override
  String get homeOffline =>
      'ಇಂಟರ್ನೆಟ್ ಇಲ್ಲ. ನೀವು ಮತ್ತೆ ಆನ್‌ಲೈನ್ ಬಂದಾಗ ನಿಮ್ಮ ತರಗತಿ ಕಾಣಿಸುತ್ತದೆ.';

  @override
  String get homeSignInAgain => 'ದಯವಿಟ್ಟು ಮತ್ತೆ ಸೈನ್ ಇನ್ ಮಾಡಿ.';

  @override
  String get homeStarForAll => 'ಎಲ್ಲಾ ಆಯ್ಕೆಗಳಿಗಾಗಿ ಸ್ಟಾರ್ ಒತ್ತಿ.';

  @override
  String homeBriefLive(String subject) {
    return '$subject ತರಗತಿ ಲೈವ್ ಆಗಿದೆ. ಸೇರಲು 1 ಒತ್ತಿ.';
  }

  @override
  String homeBriefNext(String subject, String time) {
    return 'ಮುಂದಿನ ತರಗತಿ: $time ಕ್ಕೆ $subject. ಕಾಯುತ್ತಿರುವಾಗ ನೀವು ಬೇರೆ ಆಯ್ಕೆಗಳನ್ನು ಬಳಸಬಹುದು.';
  }

  @override
  String get homeBriefNoClass =>
      'ಈಗ ಯಾವುದೇ ತರಗತಿ ಇಲ್ಲ. ಕಲಿಕೆ ಮುಂದುವರಿಸಲು 2 ಒತ್ತಿ.';

  @override
  String homeJoinClass(String subject) {
    return '$subject ತರಗತಿಗೆ ಸೇರಿ';
  }

  @override
  String get homeNoClassNow => 'ಈಗ ತರಗತಿ ಇಲ್ಲ';

  @override
  String get homeNoClassReason =>
      'ನಿಮ್ಮ ಶಿಕ್ಷಕರು ತರಗತಿ ಪ್ರಾರಂಭಿಸಿದಾಗ ಅದು ತಾನಾಗಿಯೇ ಇಲ್ಲಿ ಕಾಣಿಸುತ್ತದೆ.';

  @override
  String homeJoinWhenStarts(String subject, String time) {
    return '$time ಕ್ಕೆ $subject ಪ್ರಾರಂಭವಾದಾಗ ತಾನಾಗಿಯೇ ಸೇರಿ';
  }

  @override
  String get homeCancelAutoJoin => 'ತಾನಾಗಿಯೇ ಸೇರುವುದನ್ನು ನಿಲ್ಲಿಸಿ';

  @override
  String homeAutoJoinArmed(String subject) {
    return 'ನೀವು ಈ ಪರದೆಯಲ್ಲೇ ಇದ್ದರೆ, ನಿಮ್ಮ ಶಿಕ್ಷಕರು ಪ್ರಾರಂಭಿಸಿದಾಗ ನಾನು $subject ತೆರೆಯುತ್ತೇನೆ. ನೀವು ಮ್ಯೂಟ್ ಆಗಿ ಸೇರುತ್ತೀರಿ. ರದ್ದುಮಾಡಲು 1 ಒತ್ತಿ.';
  }

  @override
  String get homeAutoJoinCancelled => 'ತಾನಾಗಿಯೇ ಸೇರುವುದನ್ನು ರದ್ದುಮಾಡಲಾಗಿದೆ.';

  @override
  String get homeAutoJoinLeft =>
      'ನೀವು ಮುಖಪುಟದಿಂದ ಹೊರಬಂದ ಕಾರಣ ತಾನಾಗಿಯೇ ಸೇರುವುದು ನಿಂತಿದೆ.';

  @override
  String homeAutoJoined(String subject) {
    return '$subject ಪ್ರಾರಂಭವಾಗಿದೆ. ನಿಮ್ಮನ್ನು ಈಗ ಮ್ಯೂಟ್ ಆಗಿ ಸೇರಿಸಲಾಗುತ್ತಿದೆ.';
  }

  @override
  String get homeReturningToClass => 'ನಿಮ್ಮ ತರಗತಿಗೆ ಮರಳುತ್ತಿದ್ದೇವೆ.';

  @override
  String get homeContinueLearning => 'ಕಲಿಕೆ ಮುಂದುವರಿಸಿ';

  @override
  String get homeNothingToContinue =>
      'ಮುಂದುವರಿಸಲು ಇನ್ನೂ ಏನೂ ಇಲ್ಲ. ಕಲಿಕೆಯ ಪಯಣಗಳಿಗಾಗಿ 3 ಒತ್ತಿ.';

  @override
  String homeContinuing(String title) {
    return '$title ಮುಂದುವರಿಸಲಾಗುತ್ತಿದೆ.';
  }

  @override
  String get homeJourneys => 'ಕಲಿಕೆಯ ಪಯಣಗಳು';

  @override
  String get homeQuizzes => 'ಕ್ವಿಜ್‌ಗಳು';

  @override
  String get homeMore => 'ಇನ್ನಷ್ಟು';

  @override
  String get homeMoreBrief => 'ಕಡಿಮೆ ಬಳಸುವ ಆಯ್ಕೆಗಳು.';

  @override
  String homeYourClass(String className) {
    return 'ನಿಮ್ಮ ತರಗತಿ: $className.';
  }

  @override
  String homeSubjectInClass(String subject, String className) {
    return '$subject, $className';
  }

  @override
  String teacherHomeBriefLive(String subject) {
    return 'ನಿಮ್ಮ $subject ತರಗತಿ ಲೈವ್ ಆಗಿದೆ. ಅದಕ್ಕೆ ಹಿಂತಿರುಗಲು 1 ಒತ್ತಿ.';
  }

  @override
  String teacherHomeBriefReady(String place) {
    return '$place ಸಿದ್ಧವಾಗಿದೆ. ಅದನ್ನು ಪ್ರಾರಂಭಿಸಲು 1 ಒತ್ತಿ.';
  }

  @override
  String teacherHomeBriefNext(String place, String time) {
    return 'ಮುಂದಿನ ತರಗತಿ: $place, $time ಕ್ಕೆ.';
  }

  @override
  String get teacherHomeBriefNoClass =>
      'ಈಗ ನಿಮ್ಮ ವೇಳಾಪಟ್ಟಿಯಲ್ಲಿ ಯಾವುದೇ ತರಗತಿ ಇಲ್ಲ.';

  @override
  String teacherHomeReturn(String subject) {
    return '$subject ತರಗತಿಗೆ ಹಿಂತಿರುಗಿ';
  }

  @override
  String teacherHomeStart(String place) {
    return '$place ಪ್ರಾರಂಭಿಸಿ';
  }

  @override
  String teacherHomeNext(String place, String time) {
    return 'ಮುಂದಿನದು: $place, $time ಕ್ಕೆ';
  }

  @override
  String teacherHomeOpensAt(String time) {
    return 'ನೀವು ಇದನ್ನು $time ರಿಂದ ಪ್ರಾರಂಭಿಸಬಹುದು.';
  }

  @override
  String get teacherHomeNoClassReason =>
      'ಈಗ ಯಾವುದೂ ನಿಗದಿಯಾಗಿಲ್ಲ. ಆದರೂ ಕಲಿಸಲು, ಇನ್ನಷ್ಟು ಆಯ್ಕೆಗಳಿಗಾಗಿ 5 ಒತ್ತಿ, ನಂತರ 3.';

  @override
  String get teacherHomeStarting => 'ನಿಮ್ಮ ತರಗತಿ ಪ್ರಾರಂಭವಾಗುತ್ತಿದೆ.';

  @override
  String teacherHomeStarted(String subject) {
    return '$subject ತರಗತಿ ಪ್ರಾರಂಭವಾಗಿದೆ. ನಿಮ್ಮ ವಿದ್ಯಾರ್ಥಿಗಳನ್ನು ಕರೆಯಲಾಗುತ್ತಿದೆ.';
  }

  @override
  String get teacherHomeUnscheduled => 'ನಿಗದಿಯಾಗದ ತರಗತಿ ಪ್ರಾರಂಭಿಸಿ';

  @override
  String get teacherHomeUnscheduledTitle =>
      'ಈಗ ನೀವು ಯಾವ ತರಗತಿಗೆ ಕಲಿಸಲು ಬಯಸುತ್ತೀರಿ?';

  @override
  String get teacherHomeAlreadyLive =>
      'ನಿಮ್ಮ ಒಂದು ತರಗತಿ ಈಗಾಗಲೇ ಲೈವ್ ಆಗಿದೆ. ಅದಕ್ಕೆ ಹಿಂತಿರುಗಲು ಹೋಮ್‌ನಲ್ಲಿ 1 ಒತ್ತಿ.';

  @override
  String get teacherHomeChangeWorkspace => 'ಪಾಠಗಳಿಗಾಗಿ ತರಗತಿ ಮತ್ತು ವಿಷಯ ಬದಲಿಸಿ';

  @override
  String get teacherHomeOneWorkspace =>
      'ನೀವು ಒಂದು ತರಗತಿ ಮತ್ತು ವಿಷಯವನ್ನು ಕಲಿಸುತ್ತೀರಿ.';

  @override
  String teacherHomeContentFor(String place) {
    return 'ಪಾಠಗಳು, ಕ್ವಿಜ್‌ಗಳು ಮತ್ತು ಪ್ಲೇಲಿಸ್ಟ್‌ಗಳು $place ಗಾಗಿ.';
  }

  @override
  String teacherHomeLaterItem(String place, String time) {
    return 'ನಂತರ: $place, $time ಕ್ಕೆ.';
  }

  @override
  String get keyClassListWhoJoined =>
      'ತರಗತಿ ಪಟ್ಟಿ: ಯಾರು ಇದ್ದಾರೆ, ಯಾರು ಹೊರಟರು, ಯಾರು ಸೇರಿಲ್ಲ';

  @override
  String get keyMuteAllStudents => 'ಎಲ್ಲಾ ವಿದ್ಯಾರ್ಥಿಗಳನ್ನು ಮ್ಯೂಟ್ ಮಾಡಿ';

  @override
  String get keyTeacherToolsAddTimeOrEnd =>
      'ಶಿಕ್ಷಕರ ಉಪಕರಣಗಳು: ಸಮಯ ಸೇರಿಸಿ ಅಥವಾ ಎಲ್ಲರಿಗೂ ತರಗತಿ ಮುಗಿಸಿ';

  @override
  String get sessionMicAskOnce =>
      'ನೀವು ಮ್ಯೂಟ್ ಆಗಿ ಸೇರುತ್ತೀರಿ. ನೀವು ಬಯಸಿದಾಗ ಮಾತನಾಡಲು ಸಾಧ್ಯವಾಗುವಂತೆ SEEDS ಈಗ ಮೈಕ್ರೊಫೋನ್ ಬಳಸಲು ಅನುಮತಿ ಕೇಳುತ್ತದೆ.';

  @override
  String get sessionMicAskAgain => 'ಮಾತನಾಡಲು, ಮೈಕ್ರೊಫೋನ್‌ಗೆ ಅನುಮತಿ ನೀಡಿ.';

  @override
  String get sessionMicStillOff =>
      'ಮೈಕ್ರೊಫೋನ್ ಇನ್ನೂ ಆಫ್ ಆಗಿದೆ. ನೀವು ಕೇಳುತ್ತಲೇ ಇರಬಹುದು.';

  @override
  String get sessionMicSettingsTitle => 'ಮೈಕ್ರೊಫೋನ್ ನಿರ್ಬಂಧಿಸಲಾಗಿದೆ';

  @override
  String get sessionMicSettingsMessage =>
      'Android ಮತ್ತೆ ಕೇಳುವುದಿಲ್ಲ. ಮಾತನಾಡಲು, ಸೆಟ್ಟಿಂಗ್‌ಗಳನ್ನು ತೆರೆಯಿರಿ, ಅನುಮತಿಗಳನ್ನು ಆಯ್ಕೆ ಮಾಡಿ, ಮತ್ತು ಮೈಕ್ರೊಫೋನ್‌ಗೆ ಅನುಮತಿ ನೀಡಿ. ನೀವು ಕೇಳುತ್ತಲೇ ಇರಬಹುದು.';

  @override
  String get sessionMicSettingsOpen => 'ಸೆಟ್ಟಿಂಗ್‌ಗಳನ್ನು ತೆರೆಯಿರಿ';

  @override
  String get sessionMicSettingsCancel => 'ಕೇಳುತ್ತಲೇ ಇರಿ';

  @override
  String get sessionMuteAllButton => '3: ಎಲ್ಲಾ ವಿದ್ಯಾರ್ಥಿಗಳನ್ನು ಮ್ಯೂಟ್ ಮಾಡಿ';

  @override
  String get sessionMuteAllLabel => 'ಎಲ್ಲಾ ವಿದ್ಯಾರ್ಥಿಗಳನ್ನು ಮ್ಯೂಟ್ ಮಾಡಿ';

  @override
  String get sessionMuteAllWaiting =>
      'ಇನ್ನೂ ಎಲ್ಲರನ್ನೂ ಮ್ಯೂಟ್ ಮಾಡಲಾಗುತ್ತಿದೆ. ದಯವಿಟ್ಟು ಕಾಯಿರಿ.';

  @override
  String sessionMuteAllDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ವಿದ್ಯಾರ್ಥಿಗಳನ್ನು ಮ್ಯೂಟ್ ಮಾಡಲಾಗಿದೆ.',
      one: '1 ವಿದ್ಯಾರ್ಥಿಯನ್ನು ಮ್ಯೂಟ್ ಮಾಡಲಾಗಿದೆ.',
    );
    return '$_temp0';
  }

  @override
  String get sessionMuteAllNone =>
      'ಪ್ರತಿಯೊಬ್ಬ ವಿದ್ಯಾರ್ಥಿಯೂ ಈಗಾಗಲೇ ಮ್ಯೂಟ್ ಆಗಿದ್ದರು.';

  @override
  String sessionMuteAllNotConfirmed(String reason) {
    return 'ಎಲ್ಲರನ್ನೂ ಮ್ಯೂಟ್ ಮಾಡಿರುವುದು ಖಚಿತವಾಗಿಲ್ಲ. $reason ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಲು 3 ಒತ್ತಿ.';
  }

  @override
  String get sessionClassListButton => '4: ತರಗತಿ ಪಟ್ಟಿ';

  @override
  String sessionClassListLabel(String people) {
    return 'ತರಗತಿ ಪಟ್ಟಿ. $people';
  }

  @override
  String get sessionClassListTitle => 'ತರಗತಿ ಪಟ್ಟಿ';

  @override
  String sessionRosterCounts(int here, int left, int notJoined) {
    return '$here ಇಲ್ಲಿದ್ದಾರೆ, $left ಹೊರಹೋಗಿದ್ದಾರೆ, $notJoined ಇನ್ನೂ ಸೇರಿಲ್ಲ.';
  }

  @override
  String sessionHereNow(int count) {
    return 'ಈಗ ಇಲ್ಲಿದ್ದಾರೆ: $count';
  }

  @override
  String sessionLeftClass(int count) {
    return 'ಸೇರಿ, ನಂತರ ಹೊರಹೋದವರು: $count';
  }

  @override
  String sessionNotJoined(int count) {
    return 'ಇನ್ನೂ ಸೇರಿಲ್ಲ: $count';
  }

  @override
  String get sessionHereNowTitle => 'ಈಗ ಇಲ್ಲಿದ್ದಾರೆ';

  @override
  String get sessionLeftClassTitle => 'ಸೇರಿ, ನಂತರ ಹೊರಹೋದವರು';

  @override
  String get sessionNotJoinedTitle => 'ಇನ್ನೂ ಸೇರಿಲ್ಲ';

  @override
  String sessionRemovedName(String name) {
    return '$name, ನೀವು ತೆಗೆದುಹಾಕಿದ್ದೀರಿ';
  }

  @override
  String get sessionNobody => 'ಯಾರೂ ಇಲ್ಲ.';

  @override
  String get sessionRemindNotJoined => 'ಸೇರದ ವಿದ್ಯಾರ್ಥಿಗಳಿಗೆ ರಿಂಗ್ ಮಾಡಿ';

  @override
  String get sessionEveryoneJoined => 'ಎಲ್ಲರೂ ಸೇರಿದ್ದಾರೆ.';

  @override
  String sessionReminderSent(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ವಿದ್ಯಾರ್ಥಿಗಳಿಗೆ ರಿಂಗ್ ಮಾಡಲಾಗುತ್ತಿದೆ.',
      one: '1 ವಿದ್ಯಾರ್ಥಿಗೆ ರಿಂಗ್ ಮಾಡಲಾಗುತ್ತಿದೆ.',
      zero: 'ಈಗ ರಿಂಗ್ ಮಾಡಲು ಯಾರೂ ಇಲ್ಲ.',
    );
    return '$_temp0';
  }

  @override
  String sessionReminderSentSomeWaiting(int queued, int cooling) {
    return '$queued ಜನರಿಗೆ ರಿಂಗ್ ಮಾಡಲಾಗುತ್ತಿದೆ. $cooling ಜನರಿಗೆ ಕಳೆದ 5 ನಿಮಿಷಗಳಲ್ಲಿ ರಿಂಗ್ ಮಾಡಲಾಗಿದೆ, ಅವರಿಗೆ ಸದ್ಯಕ್ಕೆ ಮತ್ತೆ ರಿಂಗ್ ಮಾಡಲಾಗುವುದಿಲ್ಲ.';
  }

  @override
  String get sessionRosterUnavailable =>
      'ತರಗತಿ ಪಟ್ಟಿಯನ್ನು ಓದಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ. ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get sessionAddTime => '15 ನಿಮಿಷ ಸೇರಿಸಿ';

  @override
  String get sessionCannotAddTime =>
      'ಮುಂದಿನ ತರಗತಿಗೆ ಮೊದಲು ಇನ್ನು ಸಮಯ ಸೇರಿಸಲು ಸಾಧ್ಯವಿಲ್ಲ.';

  @override
  String sessionEndsBy(String clock) {
    return 'ತರಗತಿ $clock ರೊಳಗೆ ಮುಗಿಯುತ್ತದೆ.';
  }

  @override
  String sessionExtendedUntil(String clock) {
    return 'ಆಯಿತು. ತರಗತಿ ಈಗ $clock ರೊಳಗೆ ಮುಗಿಯುತ್ತದೆ.';
  }

  @override
  String sessionEndingSoonTeacher(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: 'ತರಗತಿ $minutes ನಿಮಿಷಗಳಲ್ಲಿ ತಾನಾಗಿಯೇ ಮುಗಿಯುತ್ತದೆ.',
      one: 'ತರಗತಿ 1 ನಿಮಿಷದಲ್ಲಿ ತಾನಾಗಿಯೇ ಮುಗಿಯುತ್ತದೆ.',
    );
    return '$_temp0';
  }

  @override
  String sessionEndingSoonTeacherExtend(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other:
          'ತರಗತಿ $minutes ನಿಮಿಷಗಳಲ್ಲಿ ತಾನಾಗಿಯೇ ಮುಗಿಯುತ್ತದೆ. 15 ನಿಮಿಷ ಸೇರಿಸಲು, 7 ನಂತರ 1 ಒತ್ತಿ.',
      one:
          'ತರಗತಿ 1 ನಿಮಿಷದಲ್ಲಿ ತಾನಾಗಿಯೇ ಮುಗಿಯುತ್ತದೆ. 15 ನಿಮಿಷ ಸೇರಿಸಲು, 7 ನಂತರ 1 ಒತ್ತಿ.',
    );
    return '$_temp0';
  }

  @override
  String sessionEndingSoonStudent(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: 'ತರಗತಿ $minutes ನಿಮಿಷಗಳಲ್ಲಿ ಮುಗಿಯುತ್ತದೆ.',
      one: 'ತರಗತಿ 1 ನಿಮಿಷದಲ್ಲಿ ಮುಗಿಯುತ್ತದೆ.',
    );
    return '$_temp0';
  }

  @override
  String get sessionLessonReady =>
      'ಇಂದಿನ ಪಾಠ ಸಿದ್ಧವಾಗಿದೆ. ತರಗತಿಗೆ ಪ್ಲೇ ಮಾಡಲು 5, ನಂತರ 3 ಒತ್ತಿ.';

  @override
  String get sessionLessonNextReady =>
      'ಇಂದಿನ ಪಾಠದ ಮುಂದಿನ ಭಾಗ ಸಿದ್ಧವಾಗಿದೆ. ಪ್ಲೇ ಮಾಡಲು 6 ಒತ್ತಿ.';

  @override
  String get sessionJoinedStudentBrief =>
      'ನೀವು ತರಗತಿಯಲ್ಲಿದ್ದೀರಿ ಮತ್ತು ಮ್ಯೂಟ್ ಆಗಿದ್ದೀರಿ. ಮಾತನಾಡಲು 1, ಕೈ ಎತ್ತಲು 2 ಒತ್ತಿ.';

  @override
  String get sessionJoinedTeacherBrief =>
      'ನಿಮ್ಮ ತರಗತಿ ಲೈವ್ ಆಗಿದೆ. ನೀವು ಮ್ಯೂಟ್ ಆಗಿದ್ದೀರಿ. ಮಾತನಾಡಲು 1, ಎಲ್ಲಾ ವಿದ್ಯಾರ್ಥಿಗಳನ್ನು ಮ್ಯೂಟ್ ಮಾಡಲು 3 ಒತ್ತಿ.';

  @override
  String get sessionStarForKeys => 'ಎಲ್ಲಾ ಕೀಗಳಿಗಾಗಿ ಸ್ಟಾರ್ ಒತ್ತಿ.';

  @override
  String settingsAutoDownload(String state) {
    return 'Wi-Fi ನಲ್ಲಿ ಹೊಸ ಪಯಣಗಳನ್ನು ಆಫ್‌ಲೈನ್ ಬಳಕೆಗೆ ಸಿದ್ಧಪಡಿಸಿ: $state';
  }

  @override
  String get settingsAutoDownloadOn =>
      'ಪಯಣಗಳನ್ನು Wi-Fi ನಲ್ಲಿ ಸಿದ್ಧಪಡಿಸಲಾಗುತ್ತದೆ.';

  @override
  String get settingsAutoDownloadOff =>
      'ಪಯಣಗಳನ್ನು ತಾನಾಗಿಯೇ ಸಿದ್ಧಪಡಿಸಲಾಗುವುದಿಲ್ಲ.';

  @override
  String get adminSetupTeacherNeedsPair =>
      'ಶಿಕ್ಷಕರಿಗೆ ಕನಿಷ್ಠ ಒಂದು ತರಗತಿ ಮತ್ತು ವಿಷಯವನ್ನು ಸೇರಿಸಿ.';

  @override
  String get adminSetupTeacherHasNoPairs =>
      'ಇನ್ನೂ ಯಾವ ಶಿಕ್ಷಕರಿಗೂ ತರಗತಿ ಮತ್ತು ವಿಷಯ ಇಲ್ಲ. ಮೊದಲು ಜನರು ವಿಭಾಗದಲ್ಲಿ ಶಿಕ್ಷಕರಿಗೆ ಅವುಗಳನ್ನು ಸೇರಿಸಿ.';

  @override
  String get adminSetupDaysField => 'ದಿನಗಳು';

  @override
  String get adminSetupChooseDays => 'ಕನಿಷ್ಠ ಒಂದು ದಿನವನ್ನು ಆಯ್ಕೆ ಮಾಡಿ.';

  @override
  String adminSetupLessonsAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ಪಾಠಗಳನ್ನು ಸೇರಿಸಲಾಗಿದೆ, ಪ್ರತಿ ದಿನಕ್ಕೆ ಒಂದು.',
      one: 'ಪಾಠ ಸೇರಿಸಲಾಗಿದೆ.',
    );
    return '$_temp0';
  }

  @override
  String get adminSetupArrangeBy => 'ಹೀಗೆ ಜೋಡಿಸಿ';

  @override
  String get adminSetupArrangeDay => 'ದಿನ';

  @override
  String get adminSetupArrangeTeacher => 'ಶಿಕ್ಷಕರು';

  @override
  String get adminSetupArrangeClass => 'ತರಗತಿ';

  @override
  String adminSetupGroupHeading(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ಪಾಠಗಳು',
      one: '1 ಪಾಠ',
    );
    return '$name · $_temp0';
  }

  @override
  String adminSetupEntryDayTitle(String day, String title) {
    return '$day, $title';
  }

  @override
  String get adminSetupTimetableSearch => 'ಪಾಠಗಳನ್ನು ಹುಡುಕಿ';

  @override
  String get adminSetupNoMatchingLessons => 'ಯಾವುದೇ ಪಾಠಗಳು ಹೊಂದುತ್ತಿಲ್ಲ.';

  @override
  String get sessionMoreButton => '7: ಇನ್ನಷ್ಟು';

  @override
  String get sessionMoreLabel => 'ಇನ್ನಷ್ಟು ಆಯ್ಕೆಗಳು';

  @override
  String get sessionMoreTitle => 'ಇನ್ನಷ್ಟು ಆಯ್ಕೆಗಳು';

  @override
  String get sessionMoreClassroomCheck => 'ತರಗತಿ ಪರಿಶೀಲನೆ';

  @override
  String get sessionMoreStatus => 'ತರಗತಿಯ ಸ್ಥಿತಿ';

  @override
  String get sessionMoreWhatIsPlaying => 'ಏನು ಪ್ಲೇ ಆಗುತ್ತಿದೆ';

  @override
  String get sessionMoreWhoIsHere => 'ತರಗತಿಯಲ್ಲಿ ಯಾರಿದ್ದಾರೆ';

  @override
  String get sessionKeyRaisedHands => 'ಎತ್ತಿದ ಕೈಗಳು';

  @override
  String get sessionKeyClassList => 'ತರಗತಿ ಪಟ್ಟಿ';

  @override
  String get sessionKeyLessonRecording => 'ಪಾಠದ ರೆಕಾರ್ಡಿಂಗ್';

  @override
  String get sessionKeyAnswerQuestion => 'ಪ್ರಶ್ನೆಗೆ ಉತ್ತರಿಸಿ';

  @override
  String get sessionKeyMore => 'ಇನ್ನಷ್ಟು ಆಯ್ಕೆಗಳು';

  @override
  String get sessionKeyLeave => 'ತರಗತಿಯಿಂದ ಹೊರಬನ್ನಿ';

  @override
  String get sessionEndClassButton => '8: ಎಲ್ಲರಿಗೂ ತರಗತಿ ಮುಗಿಸಿ';

  @override
  String get sessionEndClassLabel =>
      'ಎಲ್ಲರಿಗೂ ತರಗತಿ ಮುಗಿಸಿ. ಖಚಿತಪಡಿಸಲು ಕೇಳುತ್ತದೆ';

  @override
  String sessionActivityQuizItem(String title, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ಪ್ರಶ್ನೆಗಳು',
      one: '1 ಪ್ರಶ್ನೆ',
    );
    return 'ಕ್ವಿಜ್: $title, $_temp0';
  }

  @override
  String sessionActivityJourneyItem(String title) {
    return 'ಪಯಣ: $title';
  }

  @override
  String sessionActivityStopItem(String title) {
    return '$title ನೀಡುವುದನ್ನು ನಿಲ್ಲಿಸಿ';
  }

  @override
  String sessionActivityStartedTeacher(String title) {
    return '$title ತರಗತಿಗೆ ತೆರೆದಿದೆ. ಅದರ ಸ್ಥಿತಿಗಾಗಿ 6 ಒತ್ತಿ.';
  }

  @override
  String sessionActivityStoppedTeacher(String title) {
    return '$title ಇನ್ನು ತರಗತಿಯಲ್ಲಿ ನೀಡಲಾಗುತ್ತಿಲ್ಲ. ವಿದ್ಯಾರ್ಥಿಗಳು ಅದನ್ನು ಇನ್ನೂ ಮುಖಪುಟದಲ್ಲಿ ಕಾಣಬಹುದು.';
  }

  @override
  String sessionActivityQuizStarted(String title) {
    return 'ನಿಮ್ಮ ಶಿಕ್ಷಕರು ಒಂದು ಕ್ವಿಜ್ ಪ್ರಾರಂಭಿಸಿದ್ದಾರೆ: $title. ಪ್ರಾರಂಭಿಸಲು 4 ಒತ್ತಿ.';
  }

  @override
  String sessionActivityJourneyStarted(String title) {
    return 'ನಿಮ್ಮ ಶಿಕ್ಷಕರು ಒಂದು ಪಯಣ ಪ್ರಾರಂಭಿಸಿದ್ದಾರೆ: $title. ಪ್ರಾರಂಭಿಸಲು 4 ಒತ್ತಿ.';
  }

  @override
  String sessionActivityStoppedStudent(String title) {
    return '$title ತರಗತಿಯಲ್ಲಿ ಮುಚ್ಚಲಾಗಿದೆ. ನೀವು ಅದನ್ನು ಇನ್ನೂ ಮುಖಪುಟದಲ್ಲಿ ಕಾಣಬಹುದು.';
  }

  @override
  String sessionActivityStartQuizLabel(String title) {
    return '$title ಕ್ವಿಜ್ ಪ್ರಾರಂಭಿಸಿ';
  }

  @override
  String sessionActivityStartJourneyLabel(String title) {
    return '$title ಪಯಣ ಪ್ರಾರಂಭಿಸಿ';
  }

  @override
  String sessionActivityStateStudent(String title) {
    return '$title ತೆರೆದಿದೆ.';
  }

  @override
  String sessionActivityStateTeacher(String title) {
    return '$title ತರಗತಿಗೆ ತೆರೆದಿದೆ.';
  }

  @override
  String sessionActivityOpening(String title) {
    return '$title ತೆರೆಯಲಾಗುತ್ತಿದೆ.';
  }

  @override
  String sessionActivityCouldNotOpen(String title) {
    return '$title ತೆರೆಯಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ. ನಿಮ್ಮ ಸಂಪರ್ಕ ಪರಿಶೀಲಿಸಿ ಮತ್ತು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';
  }

  @override
  String get sessionBackInClass => 'ಮತ್ತೆ ತರಗತಿಯಲ್ಲಿ.';

  @override
  String sessionActivityProgress(String title, int started, int finished) {
    return '$title: $started ಪ್ರಾರಂಭಿಸಿದ್ದಾರೆ, $finished ಮುಗಿಸಿದ್ದಾರೆ.';
  }

  @override
  String get sessionWhatIsPlayingButton => '3: ಏನು ಪ್ಲೇ ಆಗುತ್ತಿದೆ';

  @override
  String get sessionKeyEndClass => 'ಎಲ್ಲರಿಗೂ ತರಗತಿ ಮುಗಿಸಿ';

  @override
  String get sessionKeyWhatIsPlaying => 'ಏನು ಪ್ಲೇ ಆಗುತ್ತಿದೆ';

  @override
  String get sessionQuizButton => '6: ಕ್ವಿಜ್';

  @override
  String get sessionJourneyButton => '7: ಪಯಣ';

  @override
  String get sessionQuizLabel => 'ತರಗತಿಗೆ ಒಂದು ಕ್ವಿಜ್ ಪ್ರಾರಂಭಿಸಿ';

  @override
  String get sessionJourneyLabel => 'ತರಗತಿಗೆ ಒಂದು ಪಯಣ ಪ್ರಾರಂಭಿಸಿ';

  @override
  String sessionOpenLabel(String title) {
    return '$title ತೆರೆದಿದೆ. ಯಾರು ಬಾಕಿ ಇದ್ದಾರೆ ಎಂದು ಕೇಳಿ, ಅವರಿಗೆ ನೆನಪಿಸಿ, ಅಥವಾ ಅದನ್ನು ನಿಲ್ಲಿಸಿ';
  }

  @override
  String get sessionKeyQuiz => 'ತರಗತಿಗೆ ಕ್ವಿಜ್';

  @override
  String get sessionKeyJourney => 'ತರಗತಿಗೆ ಪಯಣ';

  @override
  String sessionStartQuizButton(String title) {
    return '4: ಕ್ವಿಜ್ ಪ್ರಾರಂಭಿಸಿ: $title';
  }

  @override
  String sessionStartJourneyButton(String title) {
    return '4: ಪಯಣ ಪ್ರಾರಂಭಿಸಿ: $title';
  }

  @override
  String get sessionPickQuizTitle => 'ತರಗತಿಗೆ ಒಂದು ಕ್ವಿಜ್ ಪ್ರಾರಂಭಿಸಿ';

  @override
  String get sessionPickJourneyTitle => 'ತರಗತಿಗೆ ಒಂದು ಪಯಣ ಪ್ರಾರಂಭಿಸಿ';

  @override
  String get sessionNoQuizToStart =>
      'ಈ ತರಗತಿ ಮತ್ತು ವಿಷಯಕ್ಕೆ ಯಾವುದೇ ಪ್ರಕಟಿತ ಕ್ವಿಜ್ ತೆರೆದಿಲ್ಲ. ಮೊದಲು ಮುಖಪುಟದ ಕ್ವಿಜ್‌ಗಳಿಂದ ಒಂದನ್ನು ಪ್ರಕಟಿಸಿ.';

  @override
  String get sessionNoJourneyToStart =>
      'ಈ ತರಗತಿ ಮತ್ತು ವಿಷಯಕ್ಕೆ ಯಾವುದೇ ಪ್ರಕಟಿತ ಪಯಣ ಇಲ್ಲ. ಮೊದಲು ಮುಖಪುಟದ ಪಯಣಗಳಿಂದ ಒಂದನ್ನು ಪ್ರಕಟಿಸಿ.';

  @override
  String sessionFinishedOf(int finished, int enrolled) {
    return '$enrolled ರಲ್ಲಿ $finished ಮುಗಿಸಿದ್ದಾರೆ.';
  }

  @override
  String sessionLeftInClass(int count) {
    return 'ತರಗತಿಯಲ್ಲಿದ್ದಾರೆ, ಮುಗಿಸಿಲ್ಲ ($count)';
  }

  @override
  String sessionLeftWholeClass(int count) {
    return 'ಇಡೀ ತರಗತಿ, ಮುಗಿಸಿಲ್ಲ ($count)';
  }

  @override
  String get sessionLeftInClassTitle => 'ತರಗತಿಯಲ್ಲಿದ್ದಾರೆ, ಮುಗಿಸಿಲ್ಲ';

  @override
  String get sessionLeftWholeClassTitle => 'ಇಡೀ ತರಗತಿ, ಮುಗಿಸಿಲ್ಲ';

  @override
  String get sessionRemindLeft => 'ತರಗತಿಯಲ್ಲಿದ್ದು ಮುಗಿಸದವರಿಗೆ ನೆನಪಿಸಿ';

  @override
  String get sessionStartDifferentQuiz => 'ಬೇರೆ ಕ್ವಿಜ್ ಪ್ರಾರಂಭಿಸಿ';

  @override
  String get sessionStartDifferentJourney => 'ಬೇರೆ ಪಯಣ ಪ್ರಾರಂಭಿಸಿ';

  @override
  String sessionLeftNotStarted(String name) {
    return '$name, ಪ್ರಾರಂಭಿಸಿಲ್ಲ';
  }

  @override
  String sessionLeftStarted(String name) {
    return '$name, ಪ್ರಾರಂಭಿಸಿದ್ದಾರೆ, ಮುಗಿಸಿಲ್ಲ';
  }

  @override
  String get sessionLeftHere => 'ತರಗತಿಯಲ್ಲಿದ್ದಾರೆ';

  @override
  String get sessionLeftAway => 'ತರಗತಿಯಲ್ಲಿಲ್ಲ';

  @override
  String get sessionLeftNobodyInClass => 'ತರಗತಿಯಲ್ಲಿರುವ ಎಲ್ಲರೂ ಮುಗಿಸಿದ್ದಾರೆ.';

  @override
  String get sessionLeftNobody => 'ತರಗತಿಯ ಎಲ್ಲರೂ ಮುಗಿಸಿದ್ದಾರೆ.';

  @override
  String sessionRemindedLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ವಿದ್ಯಾರ್ಥಿಗಳಿಗೆ ನೆನಪಿಸಲಾಗಿದೆ.',
      one: '1 ವಿದ್ಯಾರ್ಥಿಗೆ ನೆನಪಿಸಲಾಗಿದೆ.',
      zero: 'ತರಗತಿಯಲ್ಲಿ ಯಾರಿಗೂ ನೆನಪಿಸುವ ಅಗತ್ಯವಿಲ್ಲ.',
    );
    return '$_temp0';
  }

  @override
  String sessionActivityReminderQuiz(String title) {
    return '$title ಕ್ವಿಜ್ ಮಾಡಲು ನಿಮ್ಮ ಶಿಕ್ಷಕರು ನೆನಪಿಸುತ್ತಿದ್ದಾರೆ. ಪ್ರಾರಂಭಿಸಲು 4 ಒತ್ತಿ.';
  }

  @override
  String sessionActivityReminderJourney(String title) {
    return '$title ಪಯಣ ಮಾಡಲು ನಿಮ್ಮ ಶಿಕ್ಷಕರು ನೆನಪಿಸುತ್ತಿದ್ದಾರೆ. ಪ್ರಾರಂಭಿಸಲು 4 ಒತ್ತಿ.';
  }

  @override
  String get sessionKeyStartActivity => 'ಕ್ವಿಜ್ ಅಥವಾ ಪಯಣ ಪ್ರಾರಂಭಿಸಿ';

  @override
  String get startupSettingsKey2 => '2. ಸೆಟ್ಟಿಂಗ್‌ಗಳು';

  @override
  String get libraryPauseSessionKey3 => 'ಇಡೀ ಸೆಷನ್‌ಗೆ ಆಡಿಯೋ ವಿರಾಮಗೊಳಿಸಿ, ಕೀ 3';

  @override
  String get authSaveNewPasswordKey1 => '1: ಹೊಸ ಪಾಸ್‌ವರ್ಡ್ ಉಳಿಸಿ';

  @override
  String get quizSaveSettingsKey1 => '1: ಸೆಟ್ಟಿಂಗ್‌ಗಳನ್ನು ಉಳಿಸಿ';

  @override
  String get quizSaveQuestionKey1 => '1: ಪ್ರಶ್ನೆ ಉಳಿಸಿ';

  @override
  String get quizContinueToQuestionsKey1 => '1: ಪ್ರಶ್ನೆಗಳಿಗೆ ಮುಂದುವರಿಸಿ';

  @override
  String get adminAuthorSection => 'ಕ್ವಿಜ್‌ಗಳು ಮತ್ತು ಪಯಣಗಳು';

  @override
  String get adminAuthorNote =>
      'ಶಿಕ್ಷಕರಿಗಾಗಿ ಕ್ವಿಜ್‌ಗಳು ಮತ್ತು ಕಲಿಕೆಯ ಪಯಣಗಳನ್ನು ರಚಿಸಿ ಮತ್ತು ಪ್ರಕಟಿಸಿ. ನೀವು ರಚಿಸುವ ಎಲ್ಲವೂ ಆ ಶಿಕ್ಷಕರಿಗೆ ಸೇರಿರುತ್ತದೆ, ಅವರ ಪ್ರಶ್ನೆ ಬ್ಯಾಂಕ್ ಮತ್ತು ಅವರದೇ ರೆಕಾರ್ಡಿಂಗ್‌ಗಳನ್ನು ಮಾತ್ರ ಬಳಸುತ್ತದೆ, ಮತ್ತು ಶಿಕ್ಷಕರಿಗೆ ಅವರ ಮುಖಪುಟದಲ್ಲಿ ಈ ಬಗ್ಗೆ ತಿಳಿಸಲಾಗುತ್ತದೆ.';

  @override
  String get adminAuthorTeacher => 'ಶಿಕ್ಷಕರು';

  @override
  String get adminAuthorWorkspace => 'ತರಗತಿ ಮತ್ತು ವಿಷಯ';

  @override
  String adminAuthorWorkspaceName(String className, String subjectName) {
    return '$className, $subjectName';
  }

  @override
  String get adminAuthorNoTeachers =>
      'ಇನ್ನೂ ಯಾವ ಶಿಕ್ಷಕರಿಗೂ ತರಗತಿ ಮತ್ತು ವಿಷಯ ಇಲ್ಲ. ಮೊದಲು ಖಾತೆಗಳು ವಿಭಾಗದಲ್ಲಿ ಒಂದನ್ನು ನಿಯೋಜಿಸಿ.';

  @override
  String get adminAuthorKind => 'ತೋರಿಸಿ';

  @override
  String get adminAuthorKindQuizzes => 'ಕ್ವಿಜ್‌ಗಳು';

  @override
  String get adminAuthorKindJourneys => 'ಪಯಣಗಳು';

  @override
  String get adminAuthorNewQuiz => 'ಹೊಸ ಕ್ವಿಜ್';

  @override
  String get adminAuthorNewJourney => 'ಹೊಸ ಪಯಣ';

  @override
  String adminAuthorNewQuizFor(String teacher) {
    return '$teacher ಅವರಿಗೆ ಹೊಸ ಕ್ವಿಜ್';
  }

  @override
  String adminAuthorNewJourneyFor(String teacher) {
    return '$teacher ಅವರಿಗೆ ಹೊಸ ಪಯಣ';
  }

  @override
  String get adminAuthorNoQuizzes =>
      'ಈ ಶಿಕ್ಷಕರಿಗೆ ಈ ತರಗತಿ ಮತ್ತು ವಿಷಯಕ್ಕೆ ಯಾವುದೇ ಕ್ವಿಜ್‌ಗಳಿಲ್ಲ.';

  @override
  String get adminAuthorNoJourneys =>
      'ಈ ಶಿಕ್ಷಕರಿಗೆ ಈ ತರಗತಿ ಮತ್ತು ವಿಷಯಕ್ಕೆ ಯಾವುದೇ ಪಯಣಗಳಿಲ್ಲ.';

  @override
  String get adminAuthorStatusDraft => 'ಕರಡು';

  @override
  String get adminAuthorStatusPublished => 'ಪ್ರಕಟಿತ';

  @override
  String get adminAuthorStatusScheduled => 'ಪ್ರಕಟಿತ, ನಂತರ ತೆರೆಯುತ್ತದೆ';

  @override
  String get adminAuthorStatusClosed => 'ಮುಚ್ಚಲಾಗಿದೆ';

  @override
  String get adminAuthorStatusArchived => 'ಆರ್ಕೈವ್ ಮಾಡಲಾಗಿದೆ';

  @override
  String adminAuthorStatusChanged(String status) {
    return '$status, ಪ್ರಕಟಿಸದ ಬದಲಾವಣೆಗಳೊಂದಿಗೆ';
  }

  @override
  String adminAuthorQuestionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ಪ್ರಶ್ನೆಗಳು',
      one: '1 ಪ್ರಶ್ನೆ',
    );
    return '$_temp0';
  }

  @override
  String adminAuthorStepCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ಹಂತಗಳು',
      one: '1 ಹಂತ',
    );
    return '$_temp0';
  }

  @override
  String get adminAuthorMode => 'ಕ್ವಿಜ್ ಪ್ರಕಾರ';

  @override
  String get adminAuthorModeGraded => 'ಅಂಕಸಹಿತ';

  @override
  String get adminAuthorModePractice => 'ಅಭ್ಯಾಸ';

  @override
  String get adminAuthorEdit => 'ಬದಲಿಸಿ';

  @override
  String adminAuthorEditNamed(String title) {
    return '$title ಸಂಪಾದಿಸಿ';
  }

  @override
  String get adminAuthorPublish => 'ಪ್ರಕಟಿಸಿ';

  @override
  String adminAuthorPublishNamed(String title) {
    return '$title ಪ್ರಕಟಿಸಿ';
  }

  @override
  String get adminAuthorClose => 'ಕ್ವಿಜ್ ಮುಚ್ಚಿ';

  @override
  String adminAuthorCloseNamed(String title) {
    return '$title ಮುಚ್ಚಿ';
  }

  @override
  String get adminAuthorArchive => 'ಆರ್ಕೈವ್ ಮಾಡಿ';

  @override
  String adminAuthorArchiveNamed(String title) {
    return '$title ಆರ್ಕೈವ್ ಮಾಡಿ';
  }

  @override
  String get adminAuthorPublishQuizTitle => 'ಈ ಕ್ವಿಜ್ ಪ್ರಕಟಿಸಬೇಕೇ?';

  @override
  String adminAuthorPublishQuizMessage(String title, String teacher) {
    return '$title ತರಗತಿಗೆ $teacher ಅವರ ಕ್ವಿಜ್ ಆಗಿ ತೆರೆಯುತ್ತದೆ, ಮತ್ತು ವಿದ್ಯಾರ್ಥಿಗಳಿಗೆ ತಿಳಿಸಲಾಗುತ್ತದೆ.';
  }

  @override
  String get adminAuthorPublishJourneyTitle => 'ಈ ಪಯಣ ಪ್ರಕಟಿಸಬೇಕೇ?';

  @override
  String adminAuthorPublishJourneyMessage(String title, String teacher) {
    return '$title ತರಗತಿಗೆ $teacher ಅವರ ಪಯಣವಾಗಿ ಲಭ್ಯವಿರುತ್ತದೆ, ಮತ್ತು ವಿದ್ಯಾರ್ಥಿಗಳಿಗೆ ತಿಳಿಸಲಾಗುತ್ತದೆ.';
  }

  @override
  String get adminAuthorCloseQuizTitle => 'ಈ ಕ್ವಿಜ್ ಮುಚ್ಚಬೇಕೇ?';

  @override
  String adminAuthorCloseQuizMessage(String title) {
    return 'ವಿದ್ಯಾರ್ಥಿಗಳು ಇನ್ನು ಮುಂದೆ $title ಗೆ ಉತ್ತರಿಸಲು ಸಾಧ್ಯವಿಲ್ಲ. ಮುಗಿಯದ ಪ್ರಯತ್ನಗಳನ್ನು ಇದ್ದ ಹಾಗೆಯೇ ಸಲ್ಲಿಸಲಾಗುತ್ತದೆ.';
  }

  @override
  String get adminAuthorArchiveTitle => 'ಈ ಪಯಣ ಆರ್ಕೈವ್ ಮಾಡಬೇಕೇ?';

  @override
  String adminAuthorArchiveMessage(String title) {
    return 'ವಿದ್ಯಾರ್ಥಿಗಳಿಗೆ ಇನ್ನು ಮುಂದೆ $title ಕಾಣಿಸುವುದಿಲ್ಲ.';
  }

  @override
  String adminAuthorPublished(String title) {
    return '$title ಪ್ರಕಟಿಸಲಾಗಿದೆ.';
  }

  @override
  String adminAuthorClosed(String title) {
    return '$title ಮುಚ್ಚಲಾಗಿದೆ.';
  }

  @override
  String adminAuthorArchived(String title) {
    return '$title ಆರ್ಕೈವ್ ಮಾಡಲಾಗಿದೆ.';
  }

  @override
  String adminAuthorCreated(String title) {
    return '$title ಕರಡು ಆಗಿ ರಚಿಸಲಾಗಿದೆ.';
  }

  @override
  String get adminAuthorSaved => 'ಪಯಣ ಉಳಿಸಲಾಗಿದೆ.';

  @override
  String adminAuthorNotReady(String problems) {
    return 'ಈ ಕ್ವಿಜ್ ಪ್ರಕಟಿಸಲು ಸಿದ್ಧವಾಗಿಲ್ಲ. $problems';
  }

  @override
  String get adminAuthorTitle => 'ಶೀರ್ಷಿಕೆ';

  @override
  String get adminAuthorDescription => 'ವಿವರಣೆ (ಐಚ್ಛಿಕ)';

  @override
  String get adminAuthorQuizSettings => 'ಕ್ವಿಜ್ ಸೆಟ್ಟಿಂಗ್‌ಗಳು';

  @override
  String adminAuthorEditQuiz(String title) {
    return 'ಕ್ವಿಜ್ ಸಂಪಾದಿಸಿ: $title';
  }

  @override
  String adminAuthorEditJourney(String title) {
    return 'ಪಯಣ ಸಂಪಾದಿಸಿ: $title';
  }

  @override
  String get adminAuthorQuestions => 'ಪ್ರಶ್ನೆಗಳು';

  @override
  String get adminAuthorNoQuestions => 'ಇನ್ನೂ ಯಾವುದೇ ಪ್ರಶ್ನೆಗಳಿಲ್ಲ.';

  @override
  String adminAuthorQuestionLine(int number, String text) {
    return '$number. $text';
  }

  @override
  String adminAuthorCorrectAnswer(String answer) {
    return 'ಸರಿಯಾದ ಉತ್ತರ: $answer';
  }

  @override
  String get adminAuthorRemove => 'ತೆಗೆದುಹಾಕಿ';

  @override
  String adminAuthorRemoveNamed(String item) {
    return '$item ತೆಗೆದುಹಾಕಿ';
  }

  @override
  String get adminAuthorAddNewQuestion => 'ಹೊಸ ಪ್ರಶ್ನೆ ಟೈಪ್ ಮಾಡಿ';

  @override
  String get adminAuthorAddBankQuestion => 'ಪ್ರಶ್ನೆ ಬ್ಯಾಂಕ್‌ನಿಂದ ಸೇರಿಸಿ';

  @override
  String get adminAuthorQuestionText => 'ಪ್ರಶ್ನೆ';

  @override
  String adminAuthorOption(int number) {
    return 'ಆಯ್ಕೆ $number';
  }

  @override
  String adminAuthorOptionalOption(int number) {
    return 'ಆಯ್ಕೆ $number (ಐಚ್ಛಿಕ)';
  }

  @override
  String get adminAuthorCorrectOption => 'ಸರಿಯಾದ ಉತ್ತರ';

  @override
  String get adminAuthorCorrectIsBlank =>
      'ಸರಿಯಾದ ಉತ್ತರ ಖಾಲಿಯಾಗಿದೆ. ಅದನ್ನು ತುಂಬಿ ಅಥವಾ ಬೇರೆ ಆಯ್ಕೆಯನ್ನು ಆರಿಸಿ.';

  @override
  String get adminAuthorExplanation => 'ವಿವರಣೆ (ಐಚ್ಛಿಕ)';

  @override
  String get adminAuthorSaveToBank => 'ಶಿಕ್ಷಕರ ಪ್ರಶ್ನೆ ಬ್ಯಾಂಕ್‌ಗೂ ಉಳಿಸಿ';

  @override
  String get adminAuthorNeedFourOptions => 'ಎಲ್ಲಾ ನಾಲ್ಕು ಆಯ್ಕೆಗಳನ್ನು ತುಂಬಿ.';

  @override
  String get adminAuthorNeedTwoOptions => 'ಕನಿಷ್ಠ ಎರಡು ಆಯ್ಕೆಗಳನ್ನು ತುಂಬಿ.';

  @override
  String get adminAuthorDuplicateOptions => 'ಪ್ರತಿ ಆಯ್ಕೆಯೂ ಬೇರೆ ಬೇರೆ ಆಗಿರಬೇಕು.';

  @override
  String adminAuthorRequired(String field) {
    return '$field ಅಗತ್ಯವಿದೆ.';
  }

  @override
  String get adminAuthorAdd => 'ಸೇರಿಸಿ';

  @override
  String adminAuthorAddNamed(String item) {
    return '$item ಸೇರಿಸಿ';
  }

  @override
  String get adminAuthorBankTitle => 'ಶಿಕ್ಷಕರ ಪ್ರಶ್ನೆ ಬ್ಯಾಂಕ್';

  @override
  String get adminAuthorBankEmpty =>
      'ಈ ಶಿಕ್ಷಕರು ಈ ತರಗತಿ ಮತ್ತು ವಿಷಯಕ್ಕೆ ಯಾವುದೇ ಪ್ರಶ್ನೆಗಳನ್ನು ಉಳಿಸಿಲ್ಲ.';

  @override
  String get adminAuthorDone => 'ಮುಗಿದಿದೆ';

  @override
  String get adminAuthorGraded => 'ಅಂಕಸಹಿತ: ಪ್ರಶ್ನೆಗಳಿಗೆ ಅಂಕ ನೀಡಿ';

  @override
  String get adminAuthorRetries => 'ತಪ್ಪು ಉತ್ತರದ ನಂತರ ಮರುಪ್ರಯತ್ನಗಳು';

  @override
  String get adminAuthorSteps => 'ಹಂತಗಳು';

  @override
  String get adminAuthorNoSteps => 'ಇನ್ನೂ ಯಾವುದೇ ಹಂತಗಳಿಲ್ಲ.';

  @override
  String adminAuthorStepRecording(String title) {
    return 'ರೆಕಾರ್ಡಿಂಗ್: $title';
  }

  @override
  String adminAuthorStepNarration(String text) {
    return 'ನಿರೂಪಣೆ: $text';
  }

  @override
  String adminAuthorStepQuestion(String text) {
    return 'ಪ್ರಶ್ನೆ: $text';
  }

  @override
  String adminAuthorStepPoll(String text) {
    return 'ಪೋಲ್: $text';
  }

  @override
  String get adminAuthorMoveUp => 'ಮೇಲೆ ಸರಿಸಿ';

  @override
  String adminAuthorMoveUpNamed(String item) {
    return '$item ಮೇಲೆ ಸರಿಸಿ';
  }

  @override
  String get adminAuthorMoveDown => 'ಕೆಳಗೆ ಸರಿಸಿ';

  @override
  String adminAuthorMoveDownNamed(String item) {
    return '$item ಕೆಳಗೆ ಸರಿಸಿ';
  }

  @override
  String get adminAuthorAddRecording => 'ರೆಕಾರ್ಡಿಂಗ್ ಸೇರಿಸಿ';

  @override
  String get adminAuthorAddNarration => 'ನಿರೂಪಣೆ ಸೇರಿಸಿ';

  @override
  String get adminAuthorAddQuestion => 'ಪ್ರಶ್ನೆ ಸೇರಿಸಿ';

  @override
  String get adminAuthorAddPoll => 'ಪೋಲ್ ಸೇರಿಸಿ';

  @override
  String get adminAuthorRecordingsTitle => 'ಶಿಕ್ಷಕರ ರೆಕಾರ್ಡಿಂಗ್‌ಗಳು';

  @override
  String get adminAuthorRecordingsNote =>
      'ಈ ಶಿಕ್ಷಕರು ಈ ತರಗತಿ ಮತ್ತು ವಿಷಯಕ್ಕೆ ಅಪ್‌ಲೋಡ್ ಮಾಡಿದ ರೆಕಾರ್ಡಿಂಗ್‌ಗಳನ್ನು ಮಾತ್ರ ಬಳಸಬಹುದು.';

  @override
  String get adminAuthorNoRecordings =>
      'ಈ ಶಿಕ್ಷಕರು ಈ ತರಗತಿ ಮತ್ತು ವಿಷಯಕ್ಕೆ ಯಾವುದೇ ರೆಕಾರ್ಡಿಂಗ್ ಅಪ್‌ಲೋಡ್ ಮಾಡಿಲ್ಲ.';

  @override
  String get adminAuthorNarrationText => 'ನಿರೂಪಣೆಯ ಪಠ್ಯ';

  @override
  String get adminAuthorPollText => 'ಪೋಲ್ ಪ್ರಶ್ನೆ';

  @override
  String get adminAuthorSaveJourney => 'ಪಯಣ ಉಳಿಸಿ';

  @override
  String teacherHomeNotice(String kind, String title, String action) {
    return '$kind $title: ನಿಮ್ಮ ನಿರ್ವಾಹಕರು ನಿಮಗಾಗಿ $action.';
  }

  @override
  String get teacherHomeNoticeQuiz => 'ಕ್ವಿಜ್';

  @override
  String get teacherHomeNoticeJourney => 'ಪಯಣ';

  @override
  String get teacherHomeNoticeCreated => 'ಸೇರಿಸಿದ್ದಾರೆ';

  @override
  String get teacherHomeNoticePublished => 'ಪ್ರಕಟಿಸಿದ್ದಾರೆ';

  @override
  String get teacherHomeNoticeClosed => 'ಮುಚ್ಚಿದ್ದಾರೆ';

  @override
  String get teacherHomeNoticeArchived => 'ಆರ್ಕೈವ್ ಮಾಡಿದ್ದಾರೆ';

  @override
  String sessionPeopleJoined(String names) {
    return '$names ಸೇರಿದರು.';
  }

  @override
  String sessionPeopleLeft(String names) {
    return '$names ಹೊರಹೋದರು.';
  }

  @override
  String sessionNamesAnd(String first, String last) {
    return '$first ಮತ್ತು $last';
  }

  @override
  String sessionHereOf(int here, int total) {
    return '$total ರಲ್ಲಿ $here ಇಲ್ಲಿದ್ದಾರೆ.';
  }

  @override
  String sessionHereCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ವಿದ್ಯಾರ್ಥಿಗಳು ಇಲ್ಲಿದ್ದಾರೆ.',
      one: '1 ವಿದ್ಯಾರ್ಥಿ ಇಲ್ಲಿದ್ದಾರೆ.',
      zero: 'ಇಲ್ಲಿ ಯಾವುದೇ ವಿದ್ಯಾರ್ಥಿಗಳಿಲ್ಲ.',
    );
    return '$_temp0';
  }

  @override
  String sessionStartSummary(int here, int total) {
    return '$total ವಿದ್ಯಾರ್ಥಿಗಳಲ್ಲಿ $here ಇಲ್ಲಿದ್ದಾರೆ.';
  }

  @override
  String uiFocusedField(String field) {
    return 'ನೀವು $field ನಲ್ಲಿದ್ದೀರಿ.';
  }

  @override
  String get sessionStartButton => '5: ಪ್ರಾರಂಭಿಸಿ';

  @override
  String get sessionStartLabel =>
      'ತರಗತಿಗಾಗಿ ಕ್ವಿಜ್, ಪಯಣ ಅಥವಾ ರೆಕಾರ್ಡಿಂಗ್ ಪ್ರಾರಂಭಿಸಿ';

  @override
  String get sessionStartTitle => 'ತರಗತಿಗಾಗಿ ಪ್ರಾರಂಭಿಸಿ';

  @override
  String get sessionStartQuiz => 'ಕ್ವಿಜ್';

  @override
  String get sessionStartJourney => 'ಪಯಣ';

  @override
  String get sessionStartRecording => 'ರೆಕಾರ್ಡಿಂಗ್';

  @override
  String sessionStatusKeyButton(String title) {
    return '6: $title ಸ್ಥಿತಿ';
  }

  @override
  String sessionStatusKeyLabel(String title) {
    return '$title ಸ್ಥಿತಿ';
  }

  @override
  String get sessionKeyStart => 'ಕ್ವಿಜ್, ಪಯಣ ಅಥವಾ ರೆಕಾರ್ಡಿಂಗ್ ಪ್ರಾರಂಭಿಸಿ';

  @override
  String get sessionKeyStatus => 'ನಡೆಯುತ್ತಿರುವುದರ ಸ್ಥಿತಿ';

  @override
  String sessionActivityCounts(int present, int started, int finished) {
    return 'ತರಗತಿಯಲ್ಲಿ $present ವಿದ್ಯಾರ್ಥಿಗಳು. $started ಪ್ರಯತ್ನಿಸಿದ್ದಾರೆ, $finished ಮುಗಿಸಿದ್ದಾರೆ.';
  }

  @override
  String get sessionNowPlayingTitle => 'ರೆಕಾರ್ಡಿಂಗ್';
}
