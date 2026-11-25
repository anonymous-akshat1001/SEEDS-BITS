// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Telugu (`te`).
class AppLocalizationsTe extends AppLocalizations {
  AppLocalizationsTe([String locale = 'te']) : super(locale);

  @override
  String get spokenDigitWords =>
      'సున్నా, ఒకటి, రెండు, మూడు, నాలుగు, ఐదు, ఆరు, ఏడు, ఎనిమిది, తొమ్మిది';

  @override
  String get spokenMonths =>
      'జనవరి, ఫిబ్రవరి, మార్చి, ఏప్రిల్, మే, జూన్, జులై, ఆగస్టు, సెప్టెంబర్, అక్టోబర్, నవంబర్, డిసెంబర్';

  @override
  String get spokenWeekdays =>
      'సోమవారం, మంగళవారం, బుధవారం, గురువారం, శుక్రవారం, శనివారం, ఆదివారం';

  @override
  String get spokenPlus => 'ప్లస్';

  @override
  String spokenSession(String number) {
    return 'సెషన్ $number';
  }

  @override
  String get spokenNoon => 'మధ్యాహ్నం 12';

  @override
  String get spokenMidnight => 'అర్ధరాత్రి';

  @override
  String spokenOClock(String hour) {
    return '$hour గంటలు';
  }

  @override
  String spokenMorning(String clock) {
    return 'ఉదయం $clock';
  }

  @override
  String spokenAfternoon(String clock) {
    return 'మధ్యాహ్నం $clock';
  }

  @override
  String spokenEvening(String clock) {
    return 'సాయంత్రం $clock';
  }

  @override
  String spokenNight(String clock) {
    return 'రాత్రి $clock';
  }

  @override
  String get spokenToday => 'ఈ రోజు';

  @override
  String get spokenTomorrow => 'రేపు';

  @override
  String get spokenYesterday => 'నిన్న';

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
    return '$date $timeకి';
  }

  @override
  String spokenHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count గంటలు',
      one: '1 గంట',
    );
    return '$_temp0';
  }

  @override
  String spokenMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count నిమిషాలు',
      one: '1 నిమిషం',
    );
    return '$_temp0';
  }

  @override
  String spokenSeconds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count సెకన్లు',
      one: '1 సెకను',
    );
    return '$_temp0';
  }

  @override
  String spokenPositionOf(String position, String total) {
    return '$totalలో $position';
  }

  @override
  String spokenPercent(String value) {
    return '$value శాతం';
  }

  @override
  String get spokenOn => 'ఆన్';

  @override
  String get spokenOff => 'ఆఫ్';

  @override
  String get keyBack10Seconds => '10 సెకన్లు వెనక్కి';

  @override
  String get keyPlayOrPause => 'ప్లే లేదా పాజ్';

  @override
  String get keyForward10Seconds => '10 సెకన్లు ముందుకు';

  @override
  String get keySlower => 'నెమ్మదిగా';

  @override
  String get keyFaster => 'వేగంగా';

  @override
  String get keySlowerPlaybackSpeed => 'ప్లేబ్యాక్ వేగం తగ్గించండి';

  @override
  String get keyFasterPlaybackSpeed => 'ప్లేబ్యాక్ వేగం పెంచండి';

  @override
  String get keyLogin => 'లాగిన్';

  @override
  String get keyRegister => 'నమోదు';

  @override
  String get keySettings => 'సెట్టింగ్‌లు';

  @override
  String get keySelectStudentAccount => 'విద్యార్థి ఖాతాను ఎంచుకోండి';

  @override
  String get keySelectTeacherAccount => 'ఉపాధ్యాయుల ఖాతాను ఎంచుకోండి';

  @override
  String get keySelectAdministratorAccount => 'నిర్వాహకుల ఖాతాను ఎంచుకోండి';

  @override
  String get keyGoToLogin => 'లాగిన్‌కు వెళ్ళండి';

  @override
  String get keyToggleTeacherRegistration => 'ఉపాధ్యాయుల నమోదు ఆన్ లేదా ఆఫ్';

  @override
  String get keyGoBack => 'వెనక్కి వెళ్ళండి';

  @override
  String get keyToggleTTS => 'T T S ఆన్ లేదా ఆఫ్';

  @override
  String get keyToggleVoiceCommands => 'వాయిస్ కమాండ్‌లు ఆన్ లేదా ఆఫ్';

  @override
  String get keyShowOrHideShortcuts => 'షార్ట్‌కట్‌లు చూపండి లేదా దాచండి';

  @override
  String get keyToggleHighContrast => 'హై కాంట్రాస్ట్ ఆన్ లేదా ఆఫ్';

  @override
  String get keyTestTTS => 'T T S పరీక్షించండి';

  @override
  String get keySaveSettings => 'సెట్టింగ్‌లు సేవ్ చేయండి';

  @override
  String get keyCheckVoice => 'స్వరాన్ని తనిఖీ చేయండి';

  @override
  String get keySoundCuesOnOrOff => 'సౌండ్ సూచనలు ఆన్ లేదా ఆఫ్';

  @override
  String get keyVibrationOnOrOff => 'వైబ్రేషన్ ఆన్ లేదా ఆఫ్';

  @override
  String get keyLogOutAsksToConfirm => 'లాగ్ అవుట్, నిర్ధారణ అడుగుతుంది';

  @override
  String get keyRefreshSessions => 'సెషన్‌లను రిఫ్రెష్ చేయండి';

  @override
  String get keySearchSessionsByNameOrID =>
      'పేరు లేదా ID ద్వారా సెషన్‌లను వెతకండి';

  @override
  String get keyRecordedAudioLibrary => 'రికార్డ్ చేసిన ఆడియో లైబ్రరీ';

  @override
  String get keyMyPrivatePlaylists => 'నా ప్రైవేట్ ప్లేలిస్ట్‌లు';

  @override
  String get keyQuizzes => 'క్విజ్‌లు';

  @override
  String get keyLearningJourneys => 'అభ్యాస ప్రయాణాలు';

  @override
  String get keyCreateSession => 'సెషన్ సృష్టించండి';

  @override
  String get keyClassPlaylists => 'తరగతి ప్లేలిస్ట్‌లు';

  @override
  String get keyChooseClassAndSubjectWorkspace =>
      'తరగతి మరియు సబ్జెక్టు వర్క్‌స్పేస్ ఎంచుకోండి';

  @override
  String get keyRefresh => 'రిఫ్రెష్';

  @override
  String get keySearchUsers => 'వినియోగదారులను వెతకండి';

  @override
  String get keyChangeAccountTypeFilter => 'ఖాతా రకం ఫిల్టర్ మార్చండి';

  @override
  String get keyChangeAssignmentFilter => 'కేటాయింపు ఫిల్టర్ మార్చండి';

  @override
  String get keyCreateSubject => 'సబ్జెక్టు సృష్టించండి';

  @override
  String get keyCreateClass => 'తరగతి సృష్టించండి';

  @override
  String get keyChooseAccountsClassesOrSubjectsSection =>
      'ఖాతాలు, తరగతులు లేదా సబ్జెక్టుల విభాగాన్ని ఎంచుకోండి';

  @override
  String get keyGoBackAlt => 'వెనక్కి వెళ్ళండి';

  @override
  String get keyCreateBankQuestion => 'బ్యాంక్ ప్రశ్న సృష్టించండి';

  @override
  String get keyCreateQuizDraft => 'క్విజ్ డ్రాఫ్ట్ సృష్టించండి';

  @override
  String get keyCreateUntimedUngradedPractice =>
      'సమయ పరిమితి, మార్కులు లేని అభ్యాసం సృష్టించండి';

  @override
  String get keyRefreshQuizzes => 'క్విజ్‌లను రిఫ్రెష్ చేయండి';

  @override
  String get keyChooseOption1 => 'ఎంపిక 1 ఎంచుకోండి';

  @override
  String get keyChooseOption2 => 'ఎంపిక 2 ఎంచుకోండి';

  @override
  String get keyChooseOption3 => 'ఎంపిక 3 ఎంచుకోండి';

  @override
  String get keyChooseOption4 => 'ఎంపిక 4 ఎంచుకోండి';

  @override
  String get keySubmitSelectedAnswer => 'ఎంచుకున్న సమాధానాన్ని సమర్పించండి';

  @override
  String get keyRepeatQuestionAndOptions =>
      'ప్రశ్న మరియు ఎంపికలను మళ్ళీ వినండి';

  @override
  String get keySlowerQuizSpeech => 'క్విజ్ స్వరం నెమ్మదిగా';

  @override
  String get keyWhereAmIIncludingTimeLeft =>
      'నేను ఎక్కడ ఉన్నాను, మిగిలిన సమయంతో సహా';

  @override
  String get keyFasterQuizSpeech => 'క్విజ్ స్వరం వేగంగా';

  @override
  String get keyMuteOrUnmute => 'మ్యూట్ లేదా అన్‌మ్యూట్';

  @override
  String get keyRaiseOrLowerHand => 'చేయి ఎత్తండి లేదా దించండి';

  @override
  String get keyHearClassStatus => 'తరగతి స్థితి వినండి';

  @override
  String get keyChat => 'చాట్';

  @override
  String get keyHearWhatTheTeacherIsPlaying =>
      'ఉపాధ్యాయులు ఏమి ప్లే చేస్తున్నారో వినండి';

  @override
  String get keyAnswerClassroomCheck => 'తరగతి తనిఖీకి సమాధానం ఇవ్వండి';

  @override
  String get keyWhoIsInTheClass => 'తరగతిలో ఎవరు ఉన్నారు';

  @override
  String get keyLeaveSessionAsksToConfirm =>
      'సెషన్ నుండి బయటకు వెళ్ళండి, నిర్ధారణ అడుగుతుంది';

  @override
  String get keyRaisedHandsAcknowledgeAndLowerThemInOrder =>
      'ఎత్తిన చేతులు: క్రమంలో గుర్తించి దించండి';

  @override
  String get keyClassRecordingPlayerPlayAndControlTheRecording =>
      'తరగతి రికార్డింగ్ ప్లేయర్: రికార్డింగ్‌ను ప్లే చేసి నియంత్రించండి';

  @override
  String get keyClassroomCheckStartCloseAndHearResponses =>
      'తరగతి తనిఖీ: ప్రారంభించండి, మూసివేయండి, సమాధానాలు వినండి';

  @override
  String get keyParticipantsMuteOrRemoveSomeone =>
      'పాల్గొనేవారు: ఎవరినైనా మ్యూట్ చేయండి లేదా తొలగించండి';

  @override
  String get keyTeacherToolsInviteStudentsEndClassForEveryone =>
      'ఉపాధ్యాయుల సాధనాలు: విద్యార్థులను ఆహ్వానించండి, అందరికీ తరగతిని ముగించండి';

  @override
  String get keyRefreshClasses => 'తరగతులను రిఫ్రెష్ చేయండి';

  @override
  String get keySearchClassByName => 'పేరుతో తరగతిని వెతకండి';

  @override
  String get keyAllAudioFiles => 'అన్ని ఆడియో ఫైల్‌లు';

  @override
  String get keyFocusFirstActiveClassUseDPadToBrowseClasses =>
      'మొదటి యాక్టివ్ తరగతికి వెళ్ళండి; తరగతులను చూడటానికి D-pad ఉపయోగించండి';

  @override
  String get keyRefreshFiles => 'ఫైల్‌లను రిఫ్రెష్ చేయండి';

  @override
  String get keyNextSubjectFilter => 'తదుపరి సబ్జెక్టు ఫిల్టర్';

  @override
  String get keyStopPlayback => 'ప్లేబ్యాక్ ఆపండి';

  @override
  String get keyAddAudioFile => 'ఆడియో ఫైల్ జోడించండి';

  @override
  String get keyUploadNewFile => 'కొత్త ఫైల్ అప్‌లోడ్ చేయండి';

  @override
  String get keySelectFromExistingLibrary => 'ఉన్న లైబ్రరీ నుండి ఎంచుకోండి';

  @override
  String get keyRefreshList => 'జాబితాను రిఫ్రెష్ చేయండి';

  @override
  String get appName => 'SEEDS';

  @override
  String get languageEnglish => 'ఇంగ్లీష్';

  @override
  String get languageHindi => 'హిందీ';

  @override
  String get languageKannada => 'కన్నడ';

  @override
  String get languageTelugu => 'తెలుగు';

  @override
  String get languageBengali => 'బెంగాలీ';

  @override
  String get commonPleaseWait => 'దయచేసి వేచి ఉండండి. ఇంకా పని జరుగుతోంది.';

  @override
  String get commonSignInFirst => 'దయచేసి ముందుగా సైన్ ఇన్ చేయండి.';

  @override
  String get commonAccountChanged =>
      'ఈ ఫోన్‌లో మీ ఖాతా మారింది. మళ్ళీ సైన్ ఇన్ చేయండి.';

  @override
  String get commonNoWorkspace =>
      'తరగతి మరియు సబ్జెక్టు ఎంచుకోలేదు. వర్క్‌స్పేస్ ఎంచుకోవడానికి 7 నొక్కండి.';

  @override
  String get commonNoConnection =>
      'పాఠశాల సర్వర్‌తో కనెక్షన్ లేదు. మీ ఇంటర్నెట్ తనిఖీ చేసి మళ్ళీ ప్రయత్నించండి.';

  @override
  String get commonNotAvailable => 'ఇది ఇప్పుడు అందుబాటులో లేదు.';

  @override
  String get commonNothingChanged => 'ఏమీ మారలేదు.';

  @override
  String get commonNoMessages => 'ఈ స్క్రీన్‌లో సందేశాలు ఏవీ లేవు.';

  @override
  String get commonEndOfList =>
      'జాబితా ముగిసింది. మొదటి అంశానికి తిరిగి వెళ్ళాము.';

  @override
  String get commonTopOfList => 'జాబితా ప్రారంభం. చివరి అంశానికి వెళ్ళాము.';

  @override
  String commonOpening(String what) {
    return '$what తెరుస్తోంది.';
  }

  @override
  String commonOpeningNeedsInternet(String what) {
    return '$what తెరుస్తోంది. ఇంటర్నెట్ అవసరం.';
  }

  @override
  String commonUnavailable(String what) {
    return '$what అందుబాటులో లేదు.';
  }

  @override
  String commonUnavailableBecause(String what, String reason) {
    return '$what అందుబాటులో లేదు. $reason';
  }

  @override
  String commonWhereScreen(String screen) {
    return '$screen.';
  }

  @override
  String commonWhereFocused(String item) {
    return 'ఎంచుకున్నది: $item.';
  }

  @override
  String get keypadStarForShortcuts =>
      'అన్ని షార్ట్‌కట్‌ల కోసం స్టార్ నొక్కండి.';

  @override
  String keypadScreenReaderIntro(String screen) {
    return '$screen. కీప్యాడ్ సహాయం కోసం స్టార్ నొక్కండి.';
  }

  @override
  String keypadMoveThroughSections(String sections) {
    return '$sections మధ్య కదలడానికి D-pad పైకి, కిందకు ఉపయోగించండి. ఎంచుకున్న నియంత్రణను యాక్టివేట్ చేయడానికి ఓకే నొక్కండి.';
  }

  @override
  String get keypadEssentialMove =>
      'కదలడానికి పైకి, కిందకు ఉపయోగించండి, ఎంచుకోవడానికి ఓకే నొక్కండి.';

  @override
  String get keypadHashAndStar =>
      'స్వరాన్ని ఆపడానికి హ్యాష్ నొక్కండి. ఈ సూచనలను మళ్ళీ వినడానికి స్టార్ నొక్కండి.';

  @override
  String get keypadDirectionKeysAndOk =>
      'కదలడానికి దిశ కీలను, ఎంచుకోవడానికి ఓకే ఉపయోగించండి.';

  @override
  String get keypadLeaveField =>
      'ఎడిట్ చేస్తున్నప్పుడు, ఫీల్డ్ నుండి బయటకు రావడానికి ఓకే నొక్కండి లేదా పైకి లేదా కిందకు ఉపయోగించండి.';

  @override
  String keypadPosition(String index, String total) {
    return ', $totalలో $index';
  }

  @override
  String keypadEditingPressOk(String label) {
    return '$label. ఎడిట్ చేస్తున్నారు. పూర్తయినప్పుడు ఓకే నొక్కండి.';
  }

  @override
  String keypadEditingUseUpDown(String label) {
    return '$label. ఎడిట్ చేస్తున్నారు. ఈ ఫీల్డ్ నుండి బయటకు రావడానికి పైకి లేదా కిందకు ఉపయోగించండి.';
  }

  @override
  String get keypadControlUnavailable => 'ఈ నియంత్రణ ఇప్పుడు అందుబాటులో లేదు.';

  @override
  String get keypadMainScreen =>
      'ఇది ప్రధాన స్క్రీన్. వెనక్కి వెళ్ళడానికి ఏమీ లేదు.';

  @override
  String messageLast(String text) {
    return 'చివరి సందేశం: $text';
  }

  @override
  String messageLastProblem(String text) {
    return 'చివరి సమస్య: $text';
  }

  @override
  String ttsSpeedDescription(String speed) {
    return 'సాధారణ వేగానికి $speed రెట్లు';
  }

  @override
  String get ttsUnavailable =>
      'స్వరం అందుబాటులో లేదు. Android లో ఇంగ్లీష్ టెక్స్ట్-టు-స్పీచ్ స్వరాన్ని ఆన్ చేయండి, తర్వాత సెట్టింగ్‌లలో \'స్వరాన్ని పరీక్షించండి\' బటన్ నొక్కండి.';

  @override
  String ttsLanguageFallback(String language) {
    return 'ఈ ఫోన్‌లో $language స్వరం లేదు, కాబట్టి SEEDS ఇంగ్లీష్‌లో మాట్లాడుతుంది. Android టెక్స్ట్-టు-స్పీచ్ సెట్టింగ్‌లలో $language స్వరాన్ని ఇన్‌స్టాల్ చేయండి, తర్వాత సెట్టింగ్‌లలో స్వరాన్ని తనిఖీ చేయండి.';
  }

  @override
  String get ttsScreenReaderDetected =>
      'స్క్రీన్ రీడర్ కనిపించింది. SEEDS తన ప్రకటనలను మీ స్క్రీన్ రీడర్‌కు పంపుతుంది.';

  @override
  String get ttsScreenReaderOff =>
      'స్క్రీన్ రీడర్ ఆఫ్ అయింది. SEEDS స్వయంగా మాట్లాడుతుంది.';

  @override
  String ttsVoiceInstalled(String language) {
    return '$language స్వర డేటా ఇన్‌స్టాల్ అయిందని Android చెబుతోంది. సెట్టింగ్‌లలో \'స్వరాన్ని పరీక్షించండి\' బటన్ నొక్కండి, తర్వాత ఆఫ్‌లైన్ స్వరంపై ఆధారపడే ముందు ఎయిర్‌ప్లేన్ మోడ్‌లో మళ్ళీ పరీక్షించండి. మీకు అది వినిపిస్తుందని ఈ తనిఖీ నిరూపించలేదు.';
  }

  @override
  String ttsVoiceNotOffline(String language) {
    return '$language అందుబాటులో ఉంది, కానీ ఆఫ్‌లైన్ స్వర డేటా ఇన్‌స్టాల్ అయిందని నిర్ధారించబడలేదు. స్వరానికి ఇంటర్నెట్ అవసరం కావచ్చు.';
  }

  @override
  String ttsVoiceMissing(String language) {
    return '$language స్వరం కనిపించలేదు.';
  }

  @override
  String ttsVoiceUnverified(String language) {
    return '$language స్వరం అందుబాటులో ఉందో లేదో నిర్ధారించలేకపోయాము.';
  }

  @override
  String ttsVoiceRecovery(String language) {
    return 'Android సెట్టింగ్‌లు తెరవండి, Text-to-speech output కనుగొనండి, $language స్వరాన్ని ఎంచుకుని దాని స్వర డేటాను ఇన్‌స్టాల్ చేయండి. ఇక్కడికి తిరిగి వచ్చి మళ్ళీ తనిఖీ చేయండి. యాప్ స్వరానికి బదులుగా మీ Android స్క్రీన్ రీడర్‌ను ఉపయోగించవచ్చు.';
  }

  @override
  String get ttsSpeedChangeFailed =>
      'స్వర వేగాన్ని మార్చలేకపోయాము. మళ్ళీ ప్రయత్నించండి.';

  @override
  String get ttsSettingsFailed =>
      'స్వర సెట్టింగ్‌లను వర్తింపజేయలేకపోయాము. \'స్వరాన్ని పరీక్షించండి\' బటన్ మళ్ళీ నొక్కండి.';

  @override
  String get ttsCouldNotStart =>
      'స్వరం ప్రారంభం కాలేదు. సెట్టింగ్‌లలో \'స్వరాన్ని పరీక్షించండి\' బటన్ నొక్కండి.';

  @override
  String get ttsNotAvailable =>
      'స్వరం అందుబాటులో లేదు. సెట్టింగ్‌లలో \'స్వరాన్ని పరీక్షించండి\' బటన్ నొక్కండి.';

  @override
  String get ttsFailed =>
      'స్వరం విఫలమైంది. సెట్టింగ్‌లలో \'స్వరాన్ని పరీక్షించండి\' బటన్ నొక్కండి.';

  @override
  String get ttsLessonResumeFailed =>
      'రికార్డ్ చేసిన పాఠం మళ్ళీ ప్రారంభం కాలేదు. మళ్ళీ ప్రయత్నించడానికి ప్లే ఎంచుకోండి.';

  @override
  String get ttsStopFailed =>
      'స్వరాన్ని ఆపలేకపోయాము. Android TTS ఇంజిన్‌ను తనిఖీ చేయండి.';

  @override
  String get ttsNoPendingUpdates => 'పెండింగ్ అప్‌డేట్‌లు ఏవీ లేవు.';

  @override
  String get ttsOtherUpdates => 'ఇతర అప్‌డేట్‌లు';

  @override
  String ttsUpdateGroup(String group) {
    return '$group.';
  }

  @override
  String ttsUpdateGroupCount(String group, int count) {
    return '$group, $count అప్‌డేట్‌లు.';
  }

  @override
  String ttsOtherUpdateGroups(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ఇతర అప్‌డేట్ సమూహాలు.',
      one: '1 ఇతర అప్‌డేట్ సమూహం.',
    );
    return '$_temp0';
  }

  @override
  String get settingsScreenName => 'సెట్టింగ్‌లు';

  @override
  String get settingsSections =>
      'నాలుగు విభాగాలు: స్వరం, డిస్‌ప్లే, కీలు మరియు సహాయం, తర్వాత సెట్టింగ్‌లు సేవ్ చేయండి';

  @override
  String get settingsLoaded => 'సెట్టింగ్‌లు లోడ్ అయ్యాయి';

  @override
  String get settingsSaved => 'సెట్టింగ్‌లు సేవ్ అయ్యాయి';

  @override
  String get settingsResetSaved =>
      'సెట్టింగ్‌లు డిఫాల్ట్‌లకు రీసెట్ చేసి సేవ్ చేయబడ్డాయి';

  @override
  String settingsTestSpeech(String volume, String speed) {
    return 'ఇది టెక్స్ట్-టు-స్పీచ్ సిస్టమ్ పరీక్ష. వాల్యూమ్ $volume శాతం. స్వర వేగం $speed.';
  }

  @override
  String settingsFastestSpeed(String speed) {
    return 'అత్యధిక స్వర వేగం, $speed';
  }

  @override
  String settingsSlowestSpeed(String speed) {
    return 'అత్యల్ప స్వర వేగం, $speed';
  }

  @override
  String settingsSpeechSpeed(String speed) {
    return 'స్వర వేగం $speed';
  }

  @override
  String get settingsVoiceCommandsEnabled => 'వాయిస్ కమాండ్‌లు ఆన్ అయ్యాయి';

  @override
  String get settingsVoiceCommandsDisabled => 'వాయిస్ కమాండ్‌లు ఆఫ్ అయ్యాయి';

  @override
  String get settingsHighContrastOn => 'హై కాంట్రాస్ట్ ఆన్';

  @override
  String get settingsHighContrastOff => 'హై కాంట్రాస్ట్ ఆఫ్';

  @override
  String get settingsShortcutsShown => 'కీప్యాడ్ షార్ట్‌కట్‌లు చూపబడుతున్నాయి';

  @override
  String get settingsShortcutsHidden => 'కీప్యాడ్ షార్ట్‌కట్‌లు దాచబడ్డాయి';

  @override
  String get settingsVoiceHelp =>
      'సెషన్‌లో, కమాండ్ కోసం వినండి యాక్టివేట్ చేసి, తర్వాత మ్యూట్, అన్‌మ్యూట్, చేయి ఎత్తండి, చేయి దించండి, బయటకు వెళ్ళండి, లేదా మళ్ళీ చెప్పండి అని చెప్పండి. వినడం దానంతట అదే మళ్ళీ ప్రారంభం కాదు. అన్‌మ్యూట్ కోసం కీ లేదా టచ్ ద్వారా నిర్ధారణ అడుగుతుంది.';

  @override
  String settingsModeAutomatic(String current) {
    return 'ఆటోమేటిక్: మీరు ఎంచుకోకపోతే TalkBack ను అనుసరిస్తుంది. ఇప్పుడు $current.';
  }

  @override
  String get settingsModeUsingScreenReader => 'స్క్రీన్ రీడర్ ఉపయోగిస్తోంది';

  @override
  String get settingsModeUsingSelfVoicing => 'యాప్ స్వయంగా మాట్లాడుతోంది';

  @override
  String get settingsModeScreenReader =>
      'స్క్రీన్ రీడర్: ప్రకటనలు TalkBack కు వెళ్తాయి. యాప్ వ్యాఖ్యానం ఆఫ్‌లో ఉంది.';

  @override
  String get settingsModeSelfVoicing => 'సొంత స్వరం: యాప్ తానే మాట్లాడుతుంది.';

  @override
  String settingsSoundCues(String state) {
    return 'సౌండ్ సూచనలు $state.';
  }

  @override
  String settingsSoundCuesOnSaved(String state) {
    return 'సౌండ్ సూచనలు $state. ఇది సేవ్ అయినప్పుడు వచ్చే శబ్దం.';
  }

  @override
  String settingsVibration(String state) {
    return 'వైబ్రేషన్ $state.';
  }

  @override
  String settingsVibrationOnBuzz(String state) {
    return 'వైబ్రేషన్ $state. ఒక చిన్న వైబ్రేషన్ అంటే సరే అని అర్థం.';
  }

  @override
  String settingsSoundCuesLabel(String state) {
    return 'సౌండ్ సూచనలు, $state. సరైనది, తప్పు, సేవ్ అయింది, లోపాలు మరియు మీరు మాట్లాడే వంతు కోసం చిన్న శబ్దాలు';
  }

  @override
  String settingsVibrationLabel(String state) {
    return 'వైబ్రేషన్, $state. సరే కోసం ఒక వైబ్రేషన్, లోపం కోసం రెండు, బయటకు వెళ్లడానికి ఒక పొడవైన వైబ్రేషన్';
  }

  @override
  String get settingsSoundCuesHelp =>
      'సరైనది, తప్పు, సేవ్ అయింది, లోపాలు, జాబితా ముగింపు మరియు మీరు మాట్లాడే వంతు కోసం చిన్న శబ్దాలు. వెంటనే సేవ్ అవుతుంది.';

  @override
  String get settingsVibrationHelp =>
      'సరే కోసం ఒక చిన్న వైబ్రేషన్, లోపం కోసం రెండు, బయటకు వెళ్లడానికి లేదా ముగించడానికి ఒక పొడవైన వైబ్రేషన్. వెంటనే సేవ్ అవుతుంది.';

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
    return 'యాప్ స్వరం $speech, వేగం $speed, వాల్యూమ్ $volume శాతం. అక్షరాల పరిమాణం $textSize శాతం. హై కాంట్రాస్ట్ $highContrast. సౌండ్ సూచనలు $soundCues. వైబ్రేషన్ $vibration. మాట్లాడే భాష $language.';
  }

  @override
  String settingsVolume(String percent) {
    return 'వాల్యూమ్ $percent శాతం';
  }

  @override
  String settingsTextSize(String percent) {
    return 'అక్షరాల పరిమాణం $percent శాతం';
  }

  @override
  String get settingsSpeechOff => 'యాప్ స్వరం ఆఫ్';

  @override
  String get settingsSpeechOn => 'యాప్ స్వరం ఆన్';

  @override
  String settingsSpeechMode(String description) {
    return 'స్వరం మోడ్. $description';
  }

  @override
  String settingsNarration(String level) {
    return 'వ్యాఖ్యాన స్థాయి $level.';
  }

  @override
  String get settingsNarrationEssential => 'అవసరమైనంత';

  @override
  String get settingsNarrationStandard => 'సాధారణం';

  @override
  String get settingsNarrationDetailed => 'వివరంగా';

  @override
  String settingsLanguage(String language) {
    return 'మాట్లాడే భాష $language.';
  }

  @override
  String settingsLanguageLabel(String language) {
    return 'మాట్లాడే భాష, $language. మార్చడానికి ఓకే నొక్కండి.';
  }

  @override
  String get settingsBack => 'వెనుకకు';

  @override
  String get settingsResetLabel =>
      'సెట్టింగ్‌లను డిఫాల్ట్‌కు రీసెట్ చేయండి, నిర్ధారణ అడుగుతుంది';

  @override
  String settingsSpeechSectionLabel(String state) {
    return 'స్వరం విభాగం. యాప్ స్వరం, $state';
  }

  @override
  String settingsVolumeLabel(String percent) {
    return 'వాల్యూమ్ $percent శాతం. మార్చడానికి ఎడమ లేదా కుడి';
  }

  @override
  String settingsSpeedLabel(String speed) {
    return 'మాట్లాడే వేగం $speed. మార్చడానికి ఎడమ లేదా కుడి';
  }

  @override
  String get settingsTestLabel => 'స్వరాన్ని పరీక్షించండి';

  @override
  String settingsModeLabel(String description) {
    return 'స్వరం మోడ్. $description మార్చడానికి ఓకే నొక్కండి.';
  }

  @override
  String settingsNarrationLabel(String level) {
    return 'వ్యాఖ్యాన స్థాయి $level. మార్చడానికి ఓకే నొక్కండి.';
  }

  @override
  String settingsCheckVoiceLabel(String language) {
    return '$language స్వరాన్ని తనిఖీ చేయండి';
  }

  @override
  String get settingsStopLabel => 'మాట్లాడటం ఆపండి';

  @override
  String settingsContrastLabel(String state) {
    return 'డిస్‌ప్లే విభాగం. హై కాంట్రాస్ట్, $state. డిఫాల్ట్‌గా ఆన్';
  }

  @override
  String settingsTextSizeLabel(String percent) {
    return 'అక్షరాల పరిమాణం $percent శాతం. మార్చడానికి ఎడమ లేదా కుడి';
  }

  @override
  String settingsShortcutsLabel(String state) {
    return 'కీలు మరియు సహాయం విభాగం. కీప్యాడ్ షార్ట్‌కట్‌లు చూపించు, $state';
  }

  @override
  String settingsVoiceCommandsLabel(String state) {
    return 'సెషన్‌లలో వాయిస్ కమాండ్‌లు, $state';
  }

  @override
  String get settingsVoiceHelpLabel => 'వాయిస్ కమాండ్ సహాయం';

  @override
  String get settingsRepeatHelpLabel => 'సెట్టింగ్‌ల సహాయాన్ని మళ్లీ వినండి';

  @override
  String get settingsSaveLabel => 'సెట్టింగ్‌లను సేవ్ చేయండి';

  @override
  String get settingsResetQuestion =>
      'అన్ని సెట్టింగ్‌లను డిఫాల్ట్‌కు రీసెట్ చేయాలా? స్వరం, డిస్‌ప్లే మరియు కీ సెట్టింగ్‌లు వాటి అసలు విలువలకు తిరిగి వస్తాయి.';

  @override
  String settingsResetScreen(String question) {
    return 'సెట్టింగ్‌లను రీసెట్ చేయండి. $question';
  }

  @override
  String get settingsResetCancel => 'రద్దు చేయండి';

  @override
  String get settingsResetConfirm => 'రీసెట్ చేయండి';

  @override
  String get settingsResetCancelLabel =>
      'రద్దు చేయండి, నా సెట్టింగ్‌లను ఉంచండి';

  @override
  String get settingsResetConfirmLabel =>
      'అన్ని సెట్టింగ్‌లను డిఫాల్ట్‌కు రీసెట్ చేయండి';

  @override
  String get quizNotSet => 'సెట్ చేయలేదు';

  @override
  String get quizNotAvailable => 'అందుబాటులో లేదు';

  @override
  String get quizNotAvailableCapital => 'అందుబాటులో లేదు';

  @override
  String quizQuestionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ప్రశ్నలు',
      one: '1 ప్రశ్న',
    );
    return '$_temp0';
  }

  @override
  String quizAttemptCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ప్రయత్నాలు',
      one: '1 ప్రయత్నం',
    );
    return '$_temp0';
  }

  @override
  String quizStudentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count విద్యార్థులు',
      one: '1 విద్యార్థి',
    );
    return '$_temp0';
  }

  @override
  String get quizAccountChanged =>
      'మీ ఖాతా మారింది. క్విజ్‌లకు తిరిగి వెళ్ళి మళ్ళీ సైన్ ఇన్ చేయండి.';

  @override
  String get quizUnlimitedPractice =>
      'అపరిమిత అభ్యాస ప్రయత్నాలు. మార్కులు ఇవ్వబడవు.';

  @override
  String quizAttemptsRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ప్రయత్నాలు మిగిలి ఉన్నాయి.',
      one: '1 ప్రయత్నం మిగిలి ఉంది.',
    );
    return '$_temp0';
  }

  @override
  String quizTimeLimit(String duration) {
    return 'సమయ పరిమితి $duration.';
  }

  @override
  String get quizNoTimeLimit => 'సమయ పరిమితి లేదు.';

  @override
  String get quizNoTimeLimitShort => 'సమయ పరిమితి లేదు';

  @override
  String get quizFeedbackAfterCompletion =>
      'మీరు క్విజ్ పూర్తి చేసిన తర్వాత జవాబుల ఫీడ్‌బ్యాక్ మరియు స్కోర్లు విడుదల అవుతాయి.';

  @override
  String quizFeedbackScheduled(String when) {
    return 'మీరు పూర్తి చేసిన తర్వాత మరియు $when తర్వాత ఫీడ్‌బ్యాక్ మరియు స్కోర్లు విడుదల అవుతాయి.';
  }

  @override
  String get quizFeedbackScoreOnly =>
      'మీరు పూర్తి చేసిన తర్వాత స్కోర్ మాత్రమే విడుదల అవుతుంది. జవాబులు మరియు వివరణలు విడుదల కావు.';

  @override
  String get quizFeedbackImmediate =>
      'ప్రతి జవాబు సబ్మిట్ చేసిన వెంటనే అది సరైనదో కాదో మీకు వినిపిస్తుంది.';

  @override
  String get quizPolicyAfterCompletion => 'క్విజ్ పూర్తయిన తర్వాత';

  @override
  String get quizPolicyScheduled => 'నిర్ణయించిన సమయంలో';

  @override
  String get quizPolicyScoreOnly => 'స్కోర్ మాత్రమే';

  @override
  String get quizPolicyLegacyImmediate => 'వెంటనే, పాత సెట్టింగ్';

  @override
  String get quizPolicyImmediate => 'ప్రతి జవాబు తర్వాత వెంటనే';

  @override
  String quizPracticeResult(String correct, String total) {
    return 'అభ్యాసం, ఇది అకడమిక్ గ్రేడ్ కాదు. ఈ అభ్యాసంలో $totalలో $correct సరైనవి.';
  }

  @override
  String quizScoreNotReleased(String message) {
    return 'స్కోర్ విడుదల కాలేదు. $message';
  }

  @override
  String get quizCheckReleasePolicy => 'విడుదల విధానాన్ని చెక్ చేయండి.';

  @override
  String quizScoreResult(String correct, String total, String percent) {
    return 'స్కోర్ $totalలో $correct, $percent.';
  }

  @override
  String get quizStatusInProgress => 'జరుగుతోంది';

  @override
  String get quizStatusTimedOut => 'సమయం అయిపోవడంతో ముగిసింది';

  @override
  String get quizStatusCompleted => 'పూర్తయింది';

  @override
  String get quizStatusPublished => 'ప్రచురించబడింది';

  @override
  String get quizStatusDraft => 'డ్రాఫ్ట్';

  @override
  String get quizStatusClosed => 'మూసివేయబడింది';

  @override
  String get quizStatusScheduled => 'షెడ్యూల్ చేయబడింది';

  @override
  String get quizStatusOpen => 'తెరిచి ఉంది';

  @override
  String quizQuestionHeading(String number, String total) {
    return '$totalలో ప్రశ్న $number';
  }

  @override
  String quizQuestionWithText(String number, String total, String text) {
    return '$totalలో ప్రశ్న $number. $text';
  }

  @override
  String quizOptionSpoken(String number, String text) {
    return 'ఎంపిక $number. $text.';
  }

  @override
  String quizOptionLabel(String number, String count, String text) {
    return '$countలో ఎంపిక $number, $text';
  }

  @override
  String quizOptionTargetSelected(String number, String text) {
    return 'ఎంపిక $number, $text, ఎంచుకోబడింది. ఎంచుకోవడానికి ఓకే లేదా $number నొక్కండి';
  }

  @override
  String quizOptionTargetNotSelected(String number, String text) {
    return 'ఎంపిక $number, $text, ఎంచుకోబడలేదు. ఎంచుకోవడానికి ఓకే లేదా $number నొక్కండి';
  }

  @override
  String quizAnswerKeysBrief(String count) {
    return '1 నుండి $count వరకు నొక్కండి, తర్వాత 5 నొక్కండి.';
  }

  @override
  String quizAnswerKeysDetailed(String count) {
    return 'సమాధానం ఎంచుకోవడానికి 1 నుండి $count వరకు నొక్కండి, తర్వాత దాన్ని సమర్పించడానికి 5 నొక్కండి. ప్రశ్నను మళ్ళీ వినడానికి 6, మీరు ఎక్కడ ఉన్నారో వినడానికి 8 నొక్కండి.';
  }

  @override
  String quizChosenBrief(String number, String text) {
    return 'ఎంపిక $number, $text, ఎంచుకోబడింది.';
  }

  @override
  String quizChosenDetailed(String number, String text) {
    return 'ఎంపిక $number, $text, ఎంచుకోబడింది. సమర్పించడానికి 5 నొక్కండి, లేదా వేరే నంబర్ ఎంచుకోండి.';
  }

  @override
  String quizChooseFirst(String count) {
    return 'ముందుగా ఒక సమాధానం ఎంచుకోండి. 1 నుండి $count వరకు నొక్కండి, తర్వాత సమర్పించడానికి 5 నొక్కండి.';
  }

  @override
  String quizNoSuchOption(String option, String count) {
    return 'ఎంపిక $option లేదు. 1 నుండి $count వరకు నొక్కండి.';
  }

  @override
  String get quizSubmitting => 'మీ సమాధానం సమర్పిస్తోంది.';

  @override
  String quizCorrectFeedback(String answer) {
    return 'సరైనది! $answer.';
  }

  @override
  String quizWrongFeedback(String answer) {
    return 'సరిగ్గా కాదు. సమాధానం $answer.';
  }

  @override
  String get quizAnswerSavedBrief => 'సమాధానం సేవ్ అయింది.';

  @override
  String get quizAnswerSavedLocked => 'సమాధానం సేవ్ అయింది, లాక్ చేయబడింది.';

  @override
  String get quizSavedHeading => 'సమాధానం సేవ్ అయింది, లాక్ చేయబడింది';

  @override
  String get quizCorrectHeading => 'సరైనది';

  @override
  String get quizWrongHeading => 'తప్పు';

  @override
  String quizYouSelected(String text) {
    return 'మీరు ఎంచుకున్నది: $text';
  }

  @override
  String quizCorrectAnswerIs(String text) {
    return 'సరైన సమాధానం: $text';
  }

  @override
  String get quizNoExplanation => 'వివరణ ఇవ్వలేదు.';

  @override
  String quizAnswerFailed(String reason) {
    return '$reason మీ ఎంపిక అలాగే ఉంచబడింది. మళ్ళీ ప్రయత్నించడానికి 5 నొక్కండి.';
  }

  @override
  String get quizAnswerUnreadable => 'సమాధానం నిర్ధారణను చదవలేకపోయాము.';

  @override
  String get quizNoOptionSelected => 'ఏ ఎంపికా ఎంచుకోలేదు.';

  @override
  String quizSelectionSaved(String number, String text) {
    return 'ఎంపిక $number, $text ఎంచుకున్నారు. సమాధానం సేవ్ అయింది.';
  }

  @override
  String quizSelectionNotSubmitted(String number, String text) {
    return 'ఎంపిక $number, $text ఎంచుకున్నారు. ఇంకా సమర్పించలేదు.';
  }

  @override
  String get quizRepeatQuestion => 'ప్రశ్న మరియు ఎంపికలను మళ్ళీ వినండి';

  @override
  String get quizAnswerConfirmed =>
      'సమాధానం సేవ్ అయి, లాక్ అయినట్టు నిర్ధారించబడింది.';

  @override
  String get quizFeedbackStaysAvailable =>
      'దాని ఫీడ్‌బ్యాక్ తర్వాతి ప్రశ్నలో ప్రైవేట్‌గా అందుబాటులో ఉంటుంది.';

  @override
  String get quizPreviousFeedback =>
      'మునుపటి సమాధానం ఫీడ్‌బ్యాక్‌ను ప్రైవేట్‌గా వినండి';

  @override
  String get quizAnswerLockNotice =>
      'మీరు 5 నొక్కినప్పుడు ప్రతి సమాధానం సేవ్ అయి, లాక్ అవుతుంది.';

  @override
  String quizTimeLeft(String duration) {
    return 'మిగిలిన సమయం: $duration.';
  }

  @override
  String quizClockLeft(String clock) {
    return '$clock మిగిలి ఉంది';
  }

  @override
  String quizClockRemaining(String clock) {
    return '$clock మిగిలి ఉంది';
  }

  @override
  String quizTimeWarning(String duration) {
    return 'ఈ క్విజ్‌లో $duration మిగిలి ఉంది.';
  }

  @override
  String quizTimeUp(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'సమయం అయిపోయింది. $count సమాధానాలు సేవ్ అయ్యాయి. క్విజ్ ముగిస్తోంది.',
      one: 'సమయం అయిపోయింది. 1 సమాధానం సేవ్ అయింది. క్విజ్ ముగిస్తోంది.',
    );
    return '$_temp0';
  }

  @override
  String quizWhereQuestion(String number, String total) {
    return '$totalలో ప్రశ్న $number.';
  }

  @override
  String quizAnsweredCount(String count) {
    return '$count సమాధానం ఇచ్చారు.';
  }

  @override
  String get quizAllSaved =>
      'అన్ని సమాధానాలు సేవ్ అయ్యాయి. ముగించి మీ ఫలితం వినడానికి 5 నొక్కండి.';

  @override
  String get quizFinishNow => 'క్విజ్‌ను ఇప్పుడే ముగించండి, నిర్ధారణతో';

  @override
  String get quizFinishNowButton => 'క్విజ్‌ను ఇప్పుడే ముగించండి';

  @override
  String get quizFinishTitle => 'క్విజ్‌ను ఇప్పుడే ముగించాలా?';

  @override
  String quizFinishMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'సర్వర్ ప్రకారం $count ప్రశ్నలకు సమాధానం ఇవ్వలేదు. సేవ్ అయిన సమాధానాలు మాత్రమే లెక్కలోకి వస్తాయి. మీరు ఎంచుకుని సమర్పించని సమాధానం చేర్చబడదు. ముగించిన తర్వాత సమాధానాలు మార్చలేరు.',
      one:
          'సర్వర్ ప్రకారం 1 ప్రశ్నకు సమాధానం ఇవ్వలేదు. సేవ్ అయిన సమాధానాలు మాత్రమే లెక్కలోకి వస్తాయి. మీరు ఎంచుకుని సమర్పించని సమాధానం చేర్చబడదు. ముగించిన తర్వాత సమాధానాలు మార్చలేరు.',
    );
    return '$_temp0';
  }

  @override
  String get quizFinishConfirm => 'క్విజ్ ముగించండి';

  @override
  String get quizFinishCancel => 'కొనసాగించండి';

  @override
  String get quizFinishUnchecked =>
      'మీ సేవ్ అయిన సమాధానాలను తనిఖీ చేయలేకపోయాము, లేదా ఈ ప్రయత్నం ముగిసింది. క్విజ్ ముగించబడలేదు. రిఫ్రెష్ చేయడానికి క్విజ్ జాబితాకు తిరిగి వెళ్ళండి.';

  @override
  String get quizFinishTimedOut =>
      'మీ సేవ్ అయిన సమాధానాలను తనిఖీ చేయడానికి చాలా సమయం పట్టింది. క్విజ్ ముగించబడలేదు. మీ కనెక్షన్ తనిఖీ చేసి మళ్ళీ ప్రయత్నించండి.';

  @override
  String get quizFinishing => 'క్విజ్ ముగిస్తోంది';

  @override
  String get quizFinishAndHear => 'ముగించి ఫలితం వినండి';

  @override
  String get quizRetryFinishing => 'ముగించడానికి మళ్ళీ ప్రయత్నించండి';

  @override
  String quizCompletionFailed(String reason) {
    return '$reason మీ సేవ్ అయిన సమాధానాలు అలాగే ఉన్నాయి. ముగించడానికి మళ్ళీ ప్రయత్నించాలంటే 5 నొక్కండి.';
  }

  @override
  String get quizCompletionNotConfirmed => 'ముగింపు నిర్ధారించబడలేదు.';

  @override
  String get quizCompleted =>
      'క్విజ్ ముగిసింది. మీ ఫలితం ప్రైవేట్. దాన్ని వినడానికి 8 నొక్కండి, లేదా క్విజ్‌లకు తిరిగి వెళ్ళడానికి 0 నొక్కండి.';

  @override
  String get quizCompletedTimedOut =>
      'సమయం అయిపోయింది. క్విజ్ ముగిసింది. మీ ఫలితం ప్రైవేట్. దాన్ని వినడానికి 8 నొక్కండి, లేదా క్విజ్‌లకు తిరిగి వెళ్ళడానికి 0 నొక్కండి.';

  @override
  String get quizResultPrivate =>
      'క్విజ్ ముగిసింది. ఫలితం ప్రైవేట్. \'ఫలితాన్ని ప్రైవేట్‌గా చదవండి\' ఉపయోగించండి.';

  @override
  String get quizResultHeading => 'ప్రయత్నం పూర్తయింది';

  @override
  String get quizReadResult => 'ఫలితాన్ని ప్రైవేట్‌గా చదవండి';

  @override
  String get quizReturnToQuizzes => 'క్విజ్‌లకు తిరిగి వెళ్ళండి';

  @override
  String get quizLeave => 'సమర్పించకుండా వెళ్ళండి, నిర్ధారణతో';

  @override
  String get quizLeaveTitle => 'వెళ్ళి, తర్వాత కొనసాగించాలా?';

  @override
  String get quizLeaveMessage =>
      'ఇది మీ ప్రయత్నాన్ని సమర్పించదు. సేవ్ అయిన సమాధానాలు మాత్రమే ఉంచబడతాయి; మీరు ఎంచుకుని సమర్పించని సమాధానం పోవచ్చు. సమయ పరిమితి ఏదైనా ఉంటే అది నడుస్తూనే ఉంటుంది. క్విజ్ అనుమతించినంత వరకు మీరు మళ్ళీ కొనసాగించవచ్చు.';

  @override
  String get quizLeaveConfirm => 'సమర్పించకుండా వెళ్ళండి';

  @override
  String get quizLeaveCancel => 'క్విజ్‌లోనే ఉండండి';

  @override
  String get quizWaitBeforeLeaving =>
      'దయచేసి వేచి ఉండండి. మీ సమాధానం ఇంకా సేవ్ అవుతోంది.';

  @override
  String quizAttemptScreen(String title) {
    return 'క్విజ్ ప్రయత్నం, $title';
  }

  @override
  String get quizAttemptNavigationCompleted =>
      'క్విజ్‌లకు తిరిగి వెళ్ళడం, ఫలితాన్ని ప్రైవేట్‌గా చదవడం మరియు క్విజ్ స్వర వేగం';

  @override
  String get quizAttemptNavigationTimed =>
      'ప్రశ్న, ప్రతి సమాధాన ఎంపిక, ఎంచుకున్న సమాధానం, క్విజ్ స్వర వేగం, మిగిలిన సమయం, సమర్పించు, క్విజ్‌ను ఇప్పుడే ముగించండి మరియు వెళ్ళండి. ఫోకస్ కదిలించడం వల్ల ఏదీ ఎంచుకోబడదు లేదా సమర్పించబడదు';

  @override
  String get quizAttemptNavigationUntimed =>
      'ప్రశ్న, ప్రతి సమాధాన ఎంపిక, ఎంచుకున్న సమాధానం, క్విజ్ స్వర వేగం, సమర్పించు, క్విజ్‌ను ఇప్పుడే ముగించండి మరియు వెళ్ళండి. ఫోకస్ కదిలించడం వల్ల ఏదీ ఎంచుకోబడదు లేదా సమర్పించబడదు';

  @override
  String get quizSpeedHelp =>
      'క్విజ్ స్వరాన్ని నెమ్మదిగా లేదా వేగంగా చేయడానికి 7 లేదా 9 నొక్కండి.';

  @override
  String get quizSpeedScreenReader =>
      'క్విజ్ స్వర వేగం యాప్ స్వరాన్ని మాత్రమే మారుస్తుంది. మీ స్క్రీన్ రీడర్ వేగాన్ని Android సెట్టింగ్‌లలో మార్చండి.';

  @override
  String get quizSpeedHeading => 'క్విజ్ స్వర వేగం';

  @override
  String quizSpeedTarget(String description) {
    return 'క్విజ్ స్వర వేగం, $description. మార్చడానికి ఎడమ లేదా కుడి, లేదా 7 లేదా 9 నొక్కండి';
  }

  @override
  String quizSpeedRead(String description) {
    return 'క్విజ్ స్వర వేగం, $description. నెమ్మదిగా చేయడానికి 7 లేదా వేగంగా చేయడానికి 9 నొక్కండి. ఈ వేగం క్విజ్‌లలో మాత్రమే ఉపయోగించబడుతుంది.';
  }

  @override
  String quizSpeedFaster(String description) {
    return 'వేగంగా. $description.';
  }

  @override
  String quizSpeedSlower(String description) {
    return 'నెమ్మదిగా. $description.';
  }

  @override
  String quizSpeedFastest(String description) {
    return 'అత్యంత వేగమైన క్విజ్ స్వరం, $description.';
  }

  @override
  String quizSpeedSlowest(String description) {
    return 'అత్యంత నెమ్మదైన క్విజ్ స్వరం, $description.';
  }

  @override
  String get quizStudentScreen => 'విద్యార్థి క్విజ్‌లు';

  @override
  String get quizStudentNavigation =>
      'రిఫ్రెష్, క్విజ్ స్థితి మరియు సబ్జెక్టు ఫిల్టర్‌లు, అందుబాటులో ఉన్న క్విజ్‌లు, మరియు ప్రయత్నాల చరిత్ర';

  @override
  String get quizStudentIntroBrief =>
      'ఫిల్టర్‌ను మార్చడానికి దానిపై ఎడమ లేదా కుడి ఉపయోగించండి.';

  @override
  String get quizStudentIntroDetailed =>
      'ఫిల్టర్‌ను మార్చడానికి దానిపై ఎడమ లేదా కుడి ఉపయోగించండి. క్విజ్ వివరాలు విని, ప్రారంభాన్ని నిర్ధారించడానికి దానిపై ఓకే నొక్కండి. ఫోకస్ కదిలించడం వల్ల క్విజ్ ఎప్పుడూ ప్రారంభం కాదు.';

  @override
  String quizAvailable(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count క్విజ్‌లు అందుబాటులో ఉన్నాయి.',
      one: '1 క్విజ్ అందుబాటులో ఉంది.',
      zero: 'క్విజ్‌లు ఏవీ అందుబాటులో లేవు.',
    );
    return '$_temp0';
  }

  @override
  String quizStudentState(int count, String open) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count క్విజ్‌లు చూపబడ్డాయి, $open తెరిచి ఉన్నాయి.',
      one: '1 క్విజ్ చూపబడింది, $open తెరిచి ఉన్నాయి.',
    );
    return '$_temp0';
  }

  @override
  String get quizStateAll => 'అన్ని స్థితులు';

  @override
  String get quizStateScheduled => 'షెడ్యూల్ చేయబడింది';

  @override
  String get quizStateOpen => 'తెరిచి ఉంది';

  @override
  String get quizStateClosed => 'మూసివేయబడింది';

  @override
  String quizStateFilter(String name, String position, String count) {
    return 'క్విజ్ స్థితి: $name, $countలో $position.';
  }

  @override
  String quizSubjectFilter(String name, String position, String count) {
    return 'సబ్జెక్టు: $name, $countలో $position.';
  }

  @override
  String get quizChangeWithArrows => 'మార్చడానికి ఎడమ లేదా కుడి';

  @override
  String get quizAllSubjects => 'అన్ని సబ్జెక్టులు';

  @override
  String quizRowHead(String subject, String title, String status) {
    return '$subject, $title, $status.';
  }

  @override
  String get quizStartQuiz => 'క్విజ్ ప్రారంభించండి';

  @override
  String get quizResumeQuiz => 'క్విజ్ కొనసాగించండి';

  @override
  String quizHistoryRow(String title, String score) {
    return '$title ప్రయత్నాల చరిత్రను సమీక్షించండి. అత్యధిక స్కోరు $score';
  }

  @override
  String quizLimitReached(String title) {
    return '$titleకి ప్రయత్నాలు ఇంకా మిగిలి లేవు. మీ స్కోర్‌లను సమీక్షించడానికి ప్రయత్నాల చరిత్ర తెరవండి.';
  }

  @override
  String get quizStartTitle => 'క్విజ్ ప్రారంభించాలా?';

  @override
  String get quizResumeTitle => 'క్విజ్ కొనసాగించాలా?';

  @override
  String quizTitleSentence(String title) {
    return '$title.';
  }

  @override
  String quizClosesSentence(String when) {
    return '$when మూసివేయబడుతుంది.';
  }

  @override
  String get quizStartAttempt => 'ప్రయత్నం ప్రారంభించండి';

  @override
  String get quizResumeAttempt => 'ప్రయత్నం కొనసాగించండి';

  @override
  String get quizStartFailed =>
      'క్విజ్‌ను ప్రారంభించలేకపోయాము. అది తెరిచి ఉందో లేదో తనిఖీ చేయండి.';

  @override
  String get quizHistoryFailed => 'ప్రయత్నాల చరిత్రను లోడ్ చేయలేకపోయాము.';

  @override
  String get quizHistoryScreen =>
      'ప్రయత్నాల చరిత్ర. స్కోర్‌లు ప్రైవేట్. సమీక్షించడానికి సారాంశానికి లేదా ఒక ప్రయత్నానికి వెళ్ళండి.';

  @override
  String get quizPracticeHistory =>
      'అభ్యాస చరిత్ర. ఇవి అకడమిక్ గ్రేడ్‌లు కావు.';

  @override
  String quizHighestScoreValue(String score) {
    return 'అత్యధిక స్కోరు: $score';
  }

  @override
  String get quizNoScoreReleasedYet =>
      'పూర్తయిన ప్రయత్నాలు ఉన్నాయి; ఇంకా స్కోరు విడుదల చేయలేదు.';

  @override
  String get quizNoCompletedAttempt => 'పూర్తయిన ప్రయత్నం లేదు';

  @override
  String quizHistoryAttempt(String number, String status, String result) {
    return 'ప్రయత్నం $number. $status. $result సమీక్షించడానికి ఓకే నొక్కండి.';
  }

  @override
  String get quizResumeFromList =>
      'ఈ ప్రయత్నం జరుగుతోంది. దాన్ని కొనసాగించడానికి క్విజ్ జాబితాకు తిరిగి వెళ్ళండి. వెళ్ళిపోవడం వల్ల సమర్పించబడదు.';

  @override
  String get quizReviewFailed =>
      'ప్రయత్నం సమీక్షను లోడ్ చేయలేకపోయాము. మీ కనెక్షన్ తనిఖీ చేసి మళ్ళీ ప్రయత్నించండి.';

  @override
  String get quizReviewTimedOut =>
      'ప్రయత్నం సమీక్షకు చాలా సమయం పట్టింది. మీ కనెక్షన్ తనిఖీ చేసి మళ్ళీ ప్రయత్నించండి.';

  @override
  String quizReviewScreenMessage(String message) {
    return 'ప్రయత్నం సమీక్ష. $message';
  }

  @override
  String quizReviewScreen(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'ప్రయత్నం సమీక్ష. $count ప్రశ్నలు. ప్రతి సమాధానాన్ని సమీక్షించడానికి పైకి, కిందికి ఉపయోగించండి.',
      one:
          'ప్రయత్నం సమీక్ష. 1 ప్రశ్న. ప్రతి సమాధానాన్ని సమీక్షించడానికి పైకి, కిందికి ఉపయోగించండి.',
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
    return 'ప్రశ్న $number. సరైనది. $question. మీరు ఎంచుకున్నది $chosen. సరైన సమాధానం $answer. $explanation';
  }

  @override
  String quizReviewQuestionIncorrect(
    String number,
    String question,
    String chosen,
    String answer,
    String explanation,
  ) {
    return 'ప్రశ్న $number. తప్పు. $question. మీరు ఎంచుకున్నది $chosen. సరైన సమాధానం $answer. $explanation';
  }

  @override
  String get quizNoAnswer => 'సమాధానం లేదు';

  @override
  String quizTeacherScreen(String className, String subjectName) {
    return '$className, $subjectName కోసం ఉపాధ్యాయుల క్విజ్‌లు';
  }

  @override
  String get quizTeacherNavigation =>
      'బ్యాంక్ శోధన మరియు సేవ్ అయిన ప్రశ్నలు, క్విజ్ డ్రాఫ్ట్‌లు, ప్రచురించిన క్విజ్‌లు, మరియు వాటి ఫలితాలు';

  @override
  String get quizTeacherIntroDetailed =>
      'బ్యాంక్ శోధన మరియు సేవ్ అయిన ప్రశ్నలు, క్విజ్ డ్రాఫ్ట్‌లు, ప్రచురించిన క్విజ్‌లు మరియు ఫలితాలను చూడటానికి D-pad ఉపయోగించండి.';

  @override
  String quizBankQuestionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count బ్యాంక్ ప్రశ్నలు',
      one: '1 బ్యాంక్ ప్రశ్న',
    );
    return '$_temp0';
  }

  @override
  String quizQuizCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count క్విజ్‌లు',
      one: '1 క్విజ్',
    );
    return '$_temp0';
  }

  @override
  String quizDraftCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count డ్రాఫ్ట్‌లు',
      one: '1 డ్రాఫ్ట్',
    );
    return '$_temp0';
  }

  @override
  String quizTeacherLoaded(String questions, String quizzes) {
    return '$questions మరియు $quizzes లోడ్ అయ్యాయి.';
  }

  @override
  String quizTeacherState(
    String drafts,
    String published,
    String closed,
    String bankQuestions,
  ) {
    return '$drafts, $published ప్రచురించబడ్డాయి, $closed మూసివేయబడ్డాయి. $bankQuestions.';
  }

  @override
  String get quizTeacherLoadFailed =>
      'ప్రశ్నల బ్యాంక్ లేదా క్విజ్ జాబితాను రిఫ్రెష్ చేయలేకపోయాము. మరో క్విజ్ సృష్టించే ముందు మళ్ళీ ప్రయత్నించడానికి 1 నొక్కండి.';

  @override
  String get quizRefreshQuizzes => 'క్విజ్ కంటెంట్‌ను రిఫ్రెష్ చేయండి';

  @override
  String get quizSearchBank => 'ప్రైవేట్ ప్రశ్నల బ్యాంక్‌లో శోధించండి';

  @override
  String get quizCreateQuestion => 'నాలుగు ఎంపికల ప్రశ్న సృష్టించండి';

  @override
  String get quizCreateQuiz => 'క్విజ్ డ్రాఫ్ట్ సృష్టించండి';

  @override
  String get quizCreatePractice =>
      'సమయ పరిమితి లేని, మార్కులు లేని వేరే అభ్యాసం సృష్టించండి. అపరిమిత ప్రయత్నాలు';

  @override
  String quizBankQuestionItem(String question, String revision) {
    return 'ప్రశ్నల బ్యాంక్ అంశం, $question. రివిజన్ $revision. ఎడిట్, రివిజన్ చరిత్ర, నకలు, ఆర్కైవ్ లేదా జోడించే చర్యల కోసం ఓకే నొక్కండి';
  }

  @override
  String get quizRevisionUnknownOlder => 'తెలియదు, పాత ప్రశ్న';

  @override
  String get quizRevisionUnknownLegacy => 'తెలియదు, పాతది';

  @override
  String quizContinueCreating(String title, String questions) {
    return '$title సృష్టించడం కొనసాగించండి. $questions';
  }

  @override
  String quizContinueCreatingRaw(String title, String count) {
    return '$title సృష్టించడం కొనసాగించండి. $count ప్రశ్నలు';
  }

  @override
  String quizCloseWithConfirmation(String title) {
    return '$title మూసివేయండి, నిర్ధారణతో';
  }

  @override
  String quizCloseNamed(String title) {
    return '$title మూసివేయండి';
  }

  @override
  String quizIsClosed(String title) {
    return '$title మూసివేయబడింది';
  }

  @override
  String quizDuplicateTarget(String title) {
    return '$titleను కొత్త, ఎడిట్ చేయగల డ్రాఫ్ట్‌గా నకలు చేయండి';
  }

  @override
  String quizResultsTarget(String title) {
    return '$title ఫలితాలు చూడండి';
  }

  @override
  String quizCard(String title, String status, String questions) {
    return '$title. స్థితి $status. $questions.';
  }

  @override
  String get quizAccountChangedBank =>
      'మీ ఖాతా మారింది. కొనసాగించే ముందు ప్రశ్నల బ్యాంక్‌ను మళ్ళీ తెరవండి.';

  @override
  String quizQuestionSaveUnconfirmed(String reason) {
    return '$reason ప్రశ్న సేవ్ అయినట్టు నిర్ధారించలేకపోయాము. మళ్ళీ ప్రయత్నించే ముందు బ్యాంక్‌ను తనిఖీ చేసి రిఫ్రెష్ చేయండి; నకలు సృష్టించవద్దు.';
  }

  @override
  String get quizMissingRevision =>
      'సర్వర్ రివిజన్ లేని ప్రశ్నను పంపింది. క్విజ్ బ్యాకెండ్‌ను అప్‌డేట్ చేయమని నిర్వాహకులను అడగండి.';

  @override
  String get quizSavedQuestionMismatch => 'సేవ్ అయిన ప్రశ్న సరిపోలలేదు.';

  @override
  String get quizQuestionSaved =>
      'ప్రశ్న సేవ్ అయింది. తర్వాత ఈ బ్యాంక్ ప్రశ్నను ఎడిట్ చేసినా ఇప్పటికే ఉన్న క్విజ్‌లు మారవు.';

  @override
  String get quizNoRevisionForEdit =>
      'ఈ సర్వర్ ప్రశ్న రివిజన్ ఇవ్వలేదు. ఎడిట్ చేసే ముందు క్విజ్ బ్యాకెండ్‌ను అప్‌డేట్ చేయమని నిర్వాహకులను అడగండి.';

  @override
  String quizQuestionUpdateUnconfirmed(String reason) {
    return '$reason బ్యాంక్ ప్రశ్న అప్‌డేట్ అయినట్టు నిర్ధారించలేకపోయాము. మళ్ళీ ప్రయత్నించే ముందు రిఫ్రెష్ చేసి దాని ప్రస్తుత రివిజన్‌ను సమీక్షించండి.';
  }

  @override
  String get quizSavedRevisionMismatch => 'సేవ్ అయిన రివిజన్ సరిపోలలేదు.';

  @override
  String get quizQuestionUpdated =>
      'బ్యాంక్ ప్రశ్న అప్‌డేట్ అయింది. ఇప్పటికే ఉన్న క్విజ్ స్నాప్‌షాట్‌లు మారలేదు.';

  @override
  String get quizArchiveTitle => 'బ్యాంక్ ప్రశ్నను ఆర్కైవ్ చేయాలా?';

  @override
  String get quizArchiveMessage =>
      'ఈ ప్రైవేట్ బ్యాంక్ ప్రశ్నను ఆర్కైవ్ చేయాలా? ఇప్పటికే ఉన్న క్విజ్ స్నాప్‌షాట్‌లు మరియు ప్రయత్నాలు మారవు.';

  @override
  String get quizArchiveConfirm => 'ప్రశ్నను ఆర్కైవ్ చేయండి';

  @override
  String get quizArchiveFailed => 'బ్యాంక్ ప్రశ్నను ఆర్కైవ్ చేయలేకపోయాము.';

  @override
  String get quizArchived => 'బ్యాంక్ ప్రశ్న ఆర్కైవ్ చేయబడింది.';

  @override
  String get quizDuplicateQuestionFailed =>
      'బ్యాంక్ ప్రశ్నను నకలు చేయలేకపోయాము.';

  @override
  String get quizQuestionDuplicated => 'బ్యాంక్ ప్రశ్న నకలు సృష్టించబడింది.';

  @override
  String quizQuestionActions(String question) {
    return '$question కోసం చర్యలు';
  }

  @override
  String get quizActionEdit => 'బ్యాంక్ ప్రశ్నను ఎడిట్ చేయండి';

  @override
  String get quizActionDuplicate => 'బ్యాంక్ ప్రశ్నను నకలు చేయండి';

  @override
  String get quizActionArchive => 'బ్యాంక్ ప్రశ్నను ఆర్కైవ్ చేయండి';

  @override
  String get quizActionRevisions => 'ప్రశ్న రివిజన్ చరిత్ర చదవండి';

  @override
  String quizActionAddTo(String title) {
    return '$titleకి జోడించండి';
  }

  @override
  String get quizRefreshBeforeDraft =>
      'మరో డ్రాఫ్ట్ సృష్టించే ముందు క్విజ్ జాబితాను రిఫ్రెష్ చేసి సమీక్షించండి.';

  @override
  String quizDraftUnconfirmed(String reason) {
    return '$reason డ్రాఫ్ట్ సేవ్ అయినట్టు నిర్ధారించలేకపోయాము. మరో డ్రాఫ్ట్ సృష్టించే ముందు క్విజ్ జాబితాను రిఫ్రెష్ చేయండి.';
  }

  @override
  String get quizSavedDraftMismatch => 'సేవ్ అయిన డ్రాఫ్ట్ సరిపోలలేదు.';

  @override
  String get quizDraftSaved => 'క్విజ్ డ్రాఫ్ట్ సేవ్ అయింది.';

  @override
  String get quizAddToQuizFailed => 'ప్రశ్నను ఈ క్విజ్‌కి జోడించలేకపోయాము.';

  @override
  String get quizAddedToQuiz => 'ప్రశ్న క్విజ్‌కి జోడించబడింది.';

  @override
  String get quizPublishTitle => 'క్విజ్ ప్రచురించాలా?';

  @override
  String quizPublishMessage(String title) {
    return '\"$title\"ను అర్హత ఉన్న విద్యార్థులకు ప్రచురించాలా? ఈ క్విజ్ కోసం ప్రశ్నలు స్థిరమవుతాయి.';
  }

  @override
  String quizPublishMessageSnapshots(String title) {
    return '\"$title\"ను అర్హత ఉన్న విద్యార్థులకు ప్రచురించాలా? ప్రశ్నలు అకడమిక్ స్నాప్‌షాట్‌లుగా మారతాయి.';
  }

  @override
  String get quizPublishConfirm => 'క్విజ్ ప్రచురించండి';

  @override
  String get quizPublishUnconfirmed =>
      'ప్రచురణను నిర్ధారించలేకపోయాము. మళ్ళీ ప్రయత్నించే ముందు రిఫ్రెష్ చేసి క్విజ్ స్థితిని సమీక్షించండి.';

  @override
  String get quizPublishedNoRecipients =>
      'క్విజ్ ప్రచురించబడింది. తెలియజేయడానికి అర్హత ఉన్న విద్యార్థులు ఎవరూ లేరు.';

  @override
  String get quizNoEligibleToNotify =>
      'తెలియజేయడానికి అర్హత ఉన్న విద్యార్థులు ఎవరూ లేరు.';

  @override
  String get quizPublishedNoneDelivered =>
      'క్విజ్ ప్రచురించబడింది, కానీ ఏ విద్యార్థి పరికరానికీ నోటిఫికేషన్‌లు అందలేదు. నోటిఫికేషన్ రిజిస్ట్రేషన్ మరియు సర్వర్ Firebase ఆధారాలను తనిఖీ చేయండి.';

  @override
  String quizPublishedWithFailures(String sent, String failures) {
    return 'క్విజ్ ప్రచురించబడింది. $sent పరికర నోటిఫికేషన్‌లు పంపబడ్డాయి, $failures విఫలమయ్యాయి.';
  }

  @override
  String quizPublishedSent(String sent) {
    return 'క్విజ్ ప్రచురించబడింది. $sent పరికర నోటిఫికేషన్‌లు పంపబడ్డాయి.';
  }

  @override
  String get quizCloseTitle => 'క్విజ్ మూసివేయాలా?';

  @override
  String quizCloseMessage(String title) {
    return '\"$title\" మూసివేయాలా? కొత్త ప్రయత్నాలు ప్రారంభం కావు, జరుగుతున్న ప్రయత్నాలు ముగించబడతాయి.';
  }

  @override
  String quizCloseMessageFinalized(String title) {
    return '\"$title\" మూసివేయాలా? కొత్త ప్రయత్నాలు ప్రారంభం కావు, జరుగుతున్న ప్రయత్నాలు ఖరారు చేయబడతాయి.';
  }

  @override
  String get quizCloseConfirm => 'క్విజ్ మూసివేయండి';

  @override
  String get quizCloseFailed => 'క్విజ్‌ను మూసివేయడం సాధ్యం కాలేదు.';

  @override
  String get quizClosed => 'క్విజ్ మూసివేయబడింది.';

  @override
  String get quizDuplicateQuizFailed =>
      'క్విజ్ కాపీని తయారు చేయడం సాధ్యం కాలేదు.';

  @override
  String get quizQuizDuplicated => 'మార్చగలిగే క్విజ్ డ్రాఫ్ట్ తయారైంది.';

  @override
  String get quizDraftAccountChanged =>
      'మీ ఖాతా మారింది. ఈ డ్రాఫ్ట్‌ను ఇక్కడ సమీక్షించలేరు.';

  @override
  String get quizDraftLoadFailed =>
      'డ్రాఫ్ట్ లేదా ప్రశ్నల బ్యాంక్ లోడ్ కాలేదు. కొనసాగే ముందు రిఫ్రెష్ చేయండి.';

  @override
  String quizBankRefreshFailed(String reason) {
    return '$reason ప్రశ్నల బ్యాంక్‌ను రిఫ్రెష్ చేయడం సాధ్యం కాలేదు. ఏ ప్రశ్నా జోడించబడలేదు. మళ్ళీ సేవ్ చేసిన ప్రశ్నను ఎంచుకోండి ను ప్రయత్నించండి.';
  }

  @override
  String get quizSavedListUnreadable =>
      'సేవ్ చేసిన ప్రశ్నల జాబితాను చదవడం సాధ్యం కాలేదు.';

  @override
  String get quizNoUnusedQuestions =>
      'ఈ వర్క్‌స్పేస్‌లో ఉపయోగించని ప్రశ్నలు ఏవీ లేవు. ప్రశ్న రాయండి ను ఎంచుకోండి.';

  @override
  String get quizAllSavedQuestionsUsed =>
      'సేవ్ చేసిన ప్రతి ప్రశ్న ఇప్పటికే ఈ క్విజ్‌లో ఉంది. ప్రశ్న రాయండి ను ఎంచుకోండి.';

  @override
  String get quizChooseSaved => 'సేవ్ చేసిన ప్రశ్నను ఎంచుకోండి';

  @override
  String quizSavedQuestionFrom(
    String question,
    String className,
    String subjectName,
  ) {
    return '$question. $className, $subjectName నుండి';
  }

  @override
  String get quizAnotherClass => 'మరొక తరగతి';

  @override
  String get quizAnotherSubject => 'మరొక సబ్జెక్టు';

  @override
  String quizAddUnconfirmed(String reason) {
    return '$reason ప్రశ్న జోడించబడిందని నిర్ధారించడం సాధ్యం కాలేదు. మళ్ళీ జోడించే ముందు రిఫ్రెష్ చేసి సేవ్ చేసిన ప్రశ్నలను సమీక్షించండి; అది ఇప్పటికే సేవ్ అయి ఉండవచ్చు.';
  }

  @override
  String get quizQuestionAddedSentence => 'ప్రశ్న జోడించబడింది.';

  @override
  String get quizAddAnotherOrReview =>
      'మరొకటి జోడించండి లేదా సమీక్షించండి ను ఎంచుకోండి.';

  @override
  String quizQuestionsSaved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ప్రశ్నలు సేవ్ అయ్యాయి.',
      one: '1 ప్రశ్న సేవ్ అయింది.',
    );
    return '$_temp0';
  }

  @override
  String quizQuestionsSavedRaw(String count) {
    return '$count ప్రశ్నలు సేవ్ అయ్యాయి.';
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
    return '$title. $description $count ప్రశ్నలు.';
  }

  @override
  String get quizUngradedPracticeSummary =>
      'మార్కులు లేని అభ్యాసం. ఎన్ని ప్రయత్నాలైనా చేయవచ్చు. టైమర్ లేదు.';

  @override
  String quizGradedSummary(String attempts) {
    return 'మార్కులతో క్విజ్. $attempts.';
  }

  @override
  String quizGradedSummaryRaw(String count) {
    return 'మార్కులతో క్విజ్. $count ప్రయత్నాలు.';
  }

  @override
  String get quizNoTimer => 'టైమర్ లేదు.';

  @override
  String quizPerAttempt(String duration) {
    return 'ఒక్కో ప్రయత్నానికి $duration.';
  }

  @override
  String quizMinutesPerAttemptRaw(String minutes) {
    return 'ఒక్కో ప్రయత్నానికి $minutes నిమిషాలు.';
  }

  @override
  String quizOpensSentence(String when) {
    return '$when తెరుచుకుంటుంది.';
  }

  @override
  String quizOpensColon(String value) {
    return 'తెరుచుకునే సమయం: $value.';
  }

  @override
  String quizClosesColon(String value) {
    return 'మూసివేసే సమయం: $value.';
  }

  @override
  String get quizWhenPublished => 'ప్రచురించినప్పుడు';

  @override
  String get quizNeverNotScheduled => 'ఎప్పుడూ కాదు, షెడ్యూల్ చేయలేదు';

  @override
  String get quizNotScheduled => 'షెడ్యూల్ చేయలేదు';

  @override
  String quizShuffleQuestionsState(String state) {
    return 'ప్రశ్నలను కలపడం $state.';
  }

  @override
  String quizShuffleOptionsState(String state) {
    return 'ఎంపికలను కలపడం $state.';
  }

  @override
  String quizShuffleQuestionsColon(String state) {
    return 'ప్రశ్నలను కలపడం: $state.';
  }

  @override
  String quizShuffleOptionsColon(String state) {
    return 'ఎంపికలను కలపడం: $state.';
  }

  @override
  String get quizRemoveChoose =>
      'ఈ డ్రాఫ్ట్ నుండి తొలగించడానికి ఒక ప్రశ్నను ఎంచుకోండి';

  @override
  String quizRemoveOption(String number, String text) {
    return 'ప్రశ్న $number: $text';
  }

  @override
  String get quizRemoveTitle => 'ఎంచుకున్న ప్రశ్నను తొలగించాలా?';

  @override
  String get quizRemoveMessage =>
      'ఈ ప్రశ్నను డ్రాఫ్ట్ నుండి తొలగించాలా? మళ్ళీ ఉపయోగించగల ప్రశ్నల బ్యాంక్ మారదు.';

  @override
  String get quizRemoveConfirm => 'ప్రశ్నను తొలగించండి';

  @override
  String get quizRemoveUnconfirmed =>
      'తొలగింపును నిర్ధారించడం సాధ్యం కాలేదు. మళ్ళీ ప్రయత్నించే ముందు రిఫ్రెష్ అయిన డ్రాఫ్ట్‌ను సమీక్షించండి.';

  @override
  String get quizQuestionRemovedSentence =>
      'ప్రశ్న డ్రాఫ్ట్ నుండి తొలగించబడింది.';

  @override
  String get quizSettingsUnconfirmed =>
      'సెట్టింగ్‌లు సేవ్ అయ్యాయని నిర్ధారించడం సాధ్యం కాలేదు. ప్రచురించే ముందు రిఫ్రెష్ చేసి సేవ్ అయిన సెట్టింగ్‌లను సమీక్షించండి.';

  @override
  String get quizSettingsSaved =>
      'క్విజ్ సెట్టింగ్‌లు సేవ్ అయ్యాయి. ప్రచురించే ముందు వాటిని సమీక్షించండి.';

  @override
  String quizSavedQuestion(String number, String text) {
    return 'సేవ్ చేసిన ప్రశ్న $number: $text. ఇప్పటికే ఈ డ్రాఫ్ట్‌లో ఉంది. దాని ఎంపికలను చదవడానికి ఓకే నొక్కండి';
  }

  @override
  String quizQuestionNumbered(String number, String text) {
    return 'ప్రశ్న $number. $text.';
  }

  @override
  String quizDraftOption(String number, String text) {
    return 'ఎంపిక $number: $text.';
  }

  @override
  String quizDraftOptionCorrect(String number, String text) {
    return 'ఎంపిక $number: $text, సరైన జవాబు.';
  }

  @override
  String get quizReviewingBeforePublishing =>
      'ప్రచురించే ముందు సమీక్షిస్తున్నారు.';

  @override
  String get quizAddingQuestions => 'ప్రశ్నలను జోడిస్తున్నారు.';

  @override
  String get quizRefreshSavedDraft => 'సేవ్ చేసిన డ్రాఫ్ట్‌ను రిఫ్రెష్ చేయండి';

  @override
  String get quizWriteQuestionTarget =>
      'ఒక ప్రశ్న రాసి దాన్ని ఈ క్విజ్‌లో మరియు మీ ప్రశ్నల బ్యాంక్‌లో సేవ్ చేయండి';

  @override
  String get quizReviewBeforePublishingTarget =>
      'ప్రచురించే ముందు ప్రశ్నలను మరియు క్విజ్ సెట్టింగ్‌లను సమీక్షించండి';

  @override
  String get quizRemoveQuestionTarget =>
      'నిర్ధారణతో, ఈ డ్రాఫ్ట్ నుండి ఒక ప్రశ్నను తొలగించండి';

  @override
  String get quizChangeSettingsTarget =>
      'శీర్షిక లేదా ఐచ్ఛిక క్విజ్ సెట్టింగ్‌లను మార్చండి';

  @override
  String get quizBackToAdding => 'ప్రశ్నలను జోడించడానికి తిరిగి వెళ్ళండి';

  @override
  String get quizPublishWithConfirmation =>
      'నిర్ధారణతో, క్విజ్‌ను ప్రచురించండి';

  @override
  String get quizSaveForLaterTarget =>
      'తర్వాత కోసం సేవ్ చేసి తిరిగి వెళ్ళండి. నిర్ధారించిన మార్పులు ఇప్పటికే డ్రాఫ్ట్‌గా సేవ్ అయ్యాయి';

  @override
  String get quizDraftNavigationReview =>
      'సేవ్ చేసిన ప్రశ్నలు, క్విజ్ సెట్టింగ్‌లు, మరియు నిర్ధారణతో ప్రచురించడం';

  @override
  String get quizDraftNavigationAdd =>
      'ప్రశ్నలు రాయడం లేదా సేవ్ చేసినవి ఎంచుకోవడం, ప్రశ్నలు తొలగించడం, మరియు డ్రాఫ్ట్‌ను సమీక్షించడం';

  @override
  String get quizPublishedScreen => 'క్విజ్ ప్రచురించబడింది';

  @override
  String get quizDraftStep3 =>
      'దశ 3 లో 3. ప్రచురించే ముందు సమీక్షించండి. మీరు నిర్ధారించే వరకు ఏదీ ప్రచురించబడదు.';

  @override
  String get quizDraftStep2 =>
      'దశ 2 లో 3. ప్రశ్నలను జోడించండి. రాయండి లేదా సేవ్ చేసిన ప్రశ్నను ఉపయోగించండి ను ఎంచుకోండి. తర్వాత సమీక్షించండి.';

  @override
  String get quizSaveForLater => 'తర్వాత కోసం సేవ్ చేసి తిరిగి వెళ్ళండి';

  @override
  String get quizWriteQuestion => 'ప్రశ్న రాయండి';

  @override
  String get quizUseSavedQuestion => 'సేవ్ చేసిన ప్రశ్నను ఉపయోగించండి';

  @override
  String get quizRemoveQuestion => 'ఒక ప్రశ్నను తొలగించండి';

  @override
  String get quizReview => 'సమీక్షించండి';

  @override
  String get quizPublishConfirmLabel => 'నిర్ధారణతో ప్రచురించండి';

  @override
  String get quizChangeSettingsLabel =>
      'శీర్షిక లేదా ఐచ్ఛిక సెట్టింగ్‌లను మార్చండి';

  @override
  String quizResultsScreen(String title) {
    return '$title ఫలితాలు';
  }

  @override
  String get quizResultsNavigation =>
      'క్విజ్ సారాంశం, విద్యార్థుల ఫలితాలు, మరియు అందుబాటులో ఉన్న ఫలిత చర్యలు';

  @override
  String get quizResultsFailed => 'క్విజ్ ఫలితాలు లోడ్ కాలేదు.';

  @override
  String quizStudentsCompleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count మంది విద్యార్థులు పూర్తి చేశారు.',
      one: '1 విద్యార్థి పూర్తి చేశారు.',
    );
    return '$_temp0';
  }

  @override
  String quizStudentsNotAttemptedYet(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count మంది విద్యార్థులు ఇంకా ప్రయత్నించలేదు.',
      one: '1 విద్యార్థి ఇంకా ప్రయత్నించలేదు.',
    );
    return '$_temp0';
  }

  @override
  String quizResultsLoadedRaw(String completed, String notAttempted) {
    return '$completed మంది విద్యార్థులు పూర్తి చేశారు. $notAttempted మంది విద్యార్థులు ప్రయత్నించలేదు.';
  }

  @override
  String quizStatEligible(String value) {
    return 'అర్హులు: $value';
  }

  @override
  String quizStatStarted(String value) {
    return 'ప్రారంభించినవారు: $value';
  }

  @override
  String quizStatCompleted(String value) {
    return 'పూర్తి చేసినవారు: $value';
  }

  @override
  String quizStatNotAttempted(String value) {
    return 'ప్రయత్నించనివారు: $value';
  }

  @override
  String quizStatCompletion(String value) {
    return 'పూర్తి: $value';
  }

  @override
  String quizStatCompletionPercent(String value) {
    return 'పూర్తి: $value శాతం';
  }

  @override
  String get quizPracticeParticipation =>
      'అభ్యాసంలో పాల్గొనడం, విద్యా మార్కులు కాదు.';

  @override
  String quizStatAverageHighest(String value) {
    return 'సగటు అత్యధిక స్కోరు: $value';
  }

  @override
  String quizStatLowest(String value) {
    return 'పూర్తి చేసినవారిలో అత్యల్ప స్కోరు: $value';
  }

  @override
  String quizStudentNotAttempted(String name) {
    return '$name ఈ క్విజ్‌ను ప్రయత్నించలేదు.';
  }

  @override
  String quizStudentPractice(int count, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$name. $count అభ్యాస ప్రయత్నాలు. విద్యా మార్కులు కాదు.',
      one: '$name. 1 అభ్యాస ప్రయత్నం. విద్యా మార్కులు కాదు.',
    );
    return '$_temp0';
  }

  @override
  String quizStudentPracticeRaw(String name, String count) {
    return '$name. $count అభ్యాస ప్రయత్నాలు. విద్యా మార్కులు కాదు.';
  }

  @override
  String quizStudentAttemptScore(String number, String score, String status) {
    return 'ప్రయత్నం $number, $score, $status';
  }

  @override
  String quizStudentAttemptRaw(String number, String score, String status) {
    return 'ప్రయత్నం $number, $score శాతం, $status';
  }

  @override
  String quizStudentScores(String name, String highest, String scores) {
    return '$name. అత్యధిక స్కోరు $highest. $scores.';
  }

  @override
  String quizStudentScoresRaw(String name, String highest, String scores) {
    return '$name. అత్యధిక స్కోరు $highest శాతం. $scores.';
  }

  @override
  String get quizExtraMismatch =>
      'అదనపు సమయం నిర్ధారణ సరిపోలలేదు. మళ్ళీ ప్రయత్నించే ముందు రిఫ్రెష్ చేయండి.';

  @override
  String get quizExtraSaved =>
      'అదనపు సమయం భవిష్యత్ ప్రయత్నాలకు మాత్రమే నిర్ధారించబడింది. ప్రస్తుత ప్రయత్నాల గడువులు మారవు, క్విజ్ మూసివేసే సమయం ఇప్పటికీ వర్తిస్తుంది.';

  @override
  String get quizEveryoneAttempted =>
      'అర్హులైన ప్రతి విద్యార్థి ఈ క్విజ్‌ను ప్రయత్నించారు.';

  @override
  String get quizRemindTitle => 'విద్యార్థులకు గుర్తు చేయాలా?';

  @override
  String quizRemindMessage(int count, String title) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$title ను ప్రయత్నించని మొత్తం $count మంది విద్యార్థులకు ఒక క్విజ్ రిమైండర్ పంపాలా?',
      one: '$title ను ప్రయత్నించని 1 విద్యార్థికి ఒక క్విజ్ రిమైండర్ పంపాలా?',
    );
    return '$_temp0';
  }

  @override
  String quizRemindMessageRaw(String count, String title) {
    return '$title ను ప్రయత్నించని మొత్తం $count మంది విద్యార్థులకు ఒక క్విజ్ రిమైండర్ పంపాలా?';
  }

  @override
  String get quizRemindConfirm => 'రిమైండర్ పంపండి';

  @override
  String get quizRemindFailed => 'క్విజ్ రిమైండర్‌లు పంపడం సాధ్యం కాలేదు.';

  @override
  String quizReminded(String notified, String queued) {
    return '$notified మంది విద్యార్థులకు రిమైండర్ పంపబడింది. $queued పరికర నోటిఫికేషన్‌లు వరుసలో ఉన్నాయి.';
  }

  @override
  String quizReminderProcessed(String notified, String queued) {
    return '$notified మంది విద్యార్థుల కోసం రిమైండర్ ప్రాసెస్ అయింది. $queued పరికర నోటిఫికేషన్‌లు వరుసలో ఉన్నాయి.';
  }

  @override
  String get quizRefreshResults => 'క్విజ్ ఫలితాలను రిఫ్రెష్ చేయండి';

  @override
  String get quizRefreshResultsLabel => 'ఫలితాలను రిఫ్రెష్ చేయండి';

  @override
  String get quizRemindAllLabel =>
      'ప్రయత్నించని విద్యార్థులందరికీ గుర్తు చేయండి';

  @override
  String get quizRemindUnavailable =>
      'విద్యార్థులందరూ ప్రయత్నించారు. రిమైండర్ అందుబాటులో లేదు';

  @override
  String quizRemindTarget(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ప్రయత్నించని మొత్తం $count మంది విద్యార్థులకు రిమైండర్ పంపండి',
      one: 'ప్రయత్నించని 1 విద్యార్థికి రిమైండర్ పంపండి',
    );
    return '$_temp0';
  }

  @override
  String quizRemindTargetRaw(String count) {
    return 'ప్రయత్నించని మొత్తం $count మంది విద్యార్థులకు రిమైండర్ పంపండి';
  }

  @override
  String quizExtraTarget(String name, String duration) {
    return '$name కోసం అదనపు సమయం సెట్ చేయండి. భవిష్యత్ ప్రయత్నాలకు మాత్రమే. ప్రస్తుత అదనపు సమయం $duration';
  }

  @override
  String quizExtraTargetRaw(String name, String minutes) {
    return '$name కోసం అదనపు నిమిషాలు సెట్ చేయండి. భవిష్యత్ ప్రయత్నాలకు మాత్రమే. ప్రస్తుత అదనపు సమయం $minutes నిమిషాలు';
  }

  @override
  String quizExtraButton(String minutes) {
    return 'భవిష్యత్ అదనపు సమయం: $minutes నిమిషాలు. సెట్ చేయండి';
  }

  @override
  String get quizResultsNotLoaded => 'ఫలితాలు లోడ్ కాలేదు.';

  @override
  String quizCompletionSentence(String percent) {
    return 'పూర్తి $percent.';
  }

  @override
  String quizExtraScreen(String name) {
    return '$name కోసం అదనపు సమయం. భవిష్యత్ ప్రయత్నాలకు మాత్రమే; జరుగుతున్న ప్రయత్నాల గడువులు మారవు. క్విజ్ మూసివేసే సమయం ఇప్పటికీ వర్తిస్తుంది. సున్నా నిమిషాలు నమోదు చేస్తే అదనపు సమయం తొలగిపోతుంది. రద్దు చేయడానికి ఫీల్డ్ బయట 0 నొక్కండి.';
  }

  @override
  String quizExtraField(String value) {
    return 'అదనపు నిమిషాలు, ప్రస్తుతం $value. మార్చడానికి ఓకే నొక్కండి';
  }

  @override
  String get quizEmpty => 'ఖాళీ';

  @override
  String get quizExtraSave =>
      'భవిష్యత్ ప్రయత్నాల కోసం అదనపు సమయాన్ని సేవ్ చేయండి';

  @override
  String get quizExtraCancel => 'అదనపు సమయం మార్చకుండా రద్దు చేయండి';

  @override
  String get quizExtraInvalid =>
      'నిమిషాలను పూర్ణ సంఖ్యగా, సున్నా లేదా అంతకంటే ఎక్కువగా, సర్వర్ అనుమతించే పరిధిలో నమోదు చేయండి.';

  @override
  String get quizExtraCorrect =>
      'సరిచేయడానికి పైకి అదనపు నిమిషాలు కి వెళ్ళండి.';

  @override
  String get quizEditorInvalid =>
      'ఒక ప్రశ్న, ఖాళీ కాని నాలుగు వేర్వేరు ఎంపికలు నమోదు చేసి, తర్వాత సరైన జవాబును ఎంచుకోండి.';

  @override
  String get quizEditorSpokenInvalid =>
      'ఒక్కొక్కటి 80 అక్షరాల వరకు, గరిష్టంగా 20 వేర్వేరు అంశాలను ఉపయోగించండి. వివరించిన నొటేషన్‌కు మాట్లాడే రూపంలో ప్రశ్న, నాలుగు ఎంపికలకూ మాట్లాడే రూపం, మరియు వివరణ ఇచ్చినట్లయితే దానికి మాట్లాడే రూపం అవసరం. సేవ్ చేసే ముందు ప్రతి మాట్లాడే రూపాన్ని సమీక్షించి నిర్ధారించండి.';

  @override
  String quizCorrectChosen(String number, String count) {
    return 'సరైన జవాబు: ఎంపిక $number, $count లో $number.';
  }

  @override
  String quizCorrectChosenWithText(String number, String text, String count) {
    return 'సరైన జవాబు: ఎంపిక $number, $text, $count లో $number.';
  }

  @override
  String get quizCorrectNotSelected =>
      'సరైన జవాబు ఎంచుకోలేదు. ఎంచుకోవడానికి ఎడమ లేదా కుడి ఉపయోగించండి';

  @override
  String quizCorrectTarget(String number, String text) {
    return 'సరైన జవాబు: ఎంపిక $number, $text. మార్చడానికి ఎడమ లేదా కుడి ఉపయోగించండి';
  }

  @override
  String quizToggled(String name, String state) {
    return '$name $state.';
  }

  @override
  String get quizContentDescribed =>
      'విషయం: ఉపాధ్యాయులు వివరించిన నొటేషన్ లేదా చిత్రం';

  @override
  String get quizContentPlain => 'విషయం: ఇంగ్లీష్ సాధారణ టెక్స్ట్';

  @override
  String get quizReviewedYes =>
      'మాట్లాడే రూపాలను ఉపాధ్యాయులు సమీక్షించారు: అవును';

  @override
  String get quizReviewedNo =>
      'మాట్లాడే రూపాలను ఉపాధ్యాయులు సమీక్షించారు: లేదు';

  @override
  String get quizSettingsInvalid =>
      'శీర్షిక, 1 నుండి 20 వరకు ప్రయత్నాల పరిమితి, సమయ పరిమితి, మరియు షెడ్యూల్‌ను తనిఖీ చేయండి. మూసివేసే సమయం తెరిచే సమయం తర్వాత ఉండాలి.';

  @override
  String get quizSetOpening =>
      'తేదీ మరియు సమయం సంఖ్య ఫీల్డ్‌లను ఉపయోగించి తెరిచే సమయాన్ని సెట్ చేయండి.';

  @override
  String get quizSetClosing =>
      'తేదీ మరియు సమయం సంఖ్య ఫీల్డ్‌లను ఉపయోగించి మూసివేసే సమయాన్ని సెట్ చేయండి.';

  @override
  String quizOpeningSet(String when) {
    return 'తెరిచే సమయం $when కి సెట్ అయింది.';
  }

  @override
  String quizClosingSet(String when) {
    return 'మూసివేసే సమయం $when కి సెట్ అయింది.';
  }

  @override
  String quizReleaseSet(String when) {
    return 'ఫీడ్‌బ్యాక్ విడుదల $when కి సెట్ అయింది.';
  }

  @override
  String get quizOpeningCleared => 'తెరిచే సమయం తీసివేయబడింది.';

  @override
  String get quizClosingCleared => 'మూసివేసే సమయం తీసివేయబడింది.';

  @override
  String get quizNoOpeningTime => 'తెరిచే సమయం సెట్ చేయలేదు';

  @override
  String get quizNoClosingTime => 'మూసివేసే సమయం సెట్ చేయలేదు';

  @override
  String quizOpensAt(String when) {
    return '$when తెరుచుకుంటుంది';
  }

  @override
  String quizClosesAt(String when) {
    return '$when మూసుకుంటుంది';
  }

  @override
  String quizPolicyChoice(String name, String position, String count) {
    return 'ఫీడ్‌బ్యాక్: $name, $count లో $position.';
  }

  @override
  String quizScheduledRelease(String when) {
    return 'షెడ్యూల్ చేసిన ఫీడ్‌బ్యాక్ విడుదల $when';
  }

  @override
  String quizAttemptLimitField(String value) {
    return 'ప్రయత్నాల పరిమితి, ప్రస్తుతం $value. మార్చడానికి ఓకే నొక్కండి';
  }

  @override
  String quizTimeLimitField(String value) {
    return 'నిమిషాలలో ఐచ్ఛిక సమయ పరిమితి, $value. మార్చడానికి ఓకే నొక్కండి';
  }

  @override
  String get quizRevisionsScreen =>
      'ప్రైవేట్, చదవడానికి మాత్రమే ఉన్న ప్రశ్న సవరణల చరిత్ర. పాత మరియు కొత్త సవరణ నియంత్రణలను ఉపయోగించి, ప్రతి విభాగాన్ని చదవండి.';

  @override
  String get quizRevisionsAccount =>
      'మీ ఖాతా మారింది. ప్రైవేట్ ప్రశ్న చరిత్రను చూసే ముందు తిరిగి వెళ్ళి మళ్ళీ సైన్ ఇన్ చేయండి.';

  @override
  String get quizRevisionsCleared =>
      'మీ ఖాతా మారింది. ప్రైవేట్ ప్రశ్న చరిత్ర తీసివేయబడింది.';

  @override
  String get quizRevisionsUnverified =>
      'ప్రశ్న సవరణల చరిత్రను ధృవీకరించడం సాధ్యం కాలేదు. మళ్ళీ లోడ్ చేయడానికి ప్రయత్నించండి.';

  @override
  String get quizRevisionsContentUnverified =>
      'ప్రశ్న సవరణ విషయాన్ని ధృవీకరించడం సాధ్యం కాలేదు. మళ్ళీ లోడ్ చేయడానికి ప్రయత్నించండి.';

  @override
  String get quizRevisionsTimedOut =>
      'ప్రశ్న చరిత్రకు చాలా సమయం పట్టింది. మీ కనెక్షన్‌ను తనిఖీ చేసి మళ్ళీ ప్రయత్నించండి.';

  @override
  String get quizNoRevisions =>
      'నమోదైన సవరణలు లేవు. పాత ప్రశ్న చరిత్ర తెలియదు, అది తిరిగి తయారు చేయబడలేదు.';

  @override
  String quizRevisionsLoaded(int count, String revision, String when) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count సవరణలు లోడ్ అయ్యాయి. చదవడానికి మాత్రమే ఉన్న ప్రశ్న సవరణ $revision, $when న సేవ్ అయింది. ఇప్పటికే ఉన్న క్విజ్ మరియు ప్రయత్నాల స్నాప్‌షాట్‌లు మారవు.',
      one:
          '1 సవరణ లోడ్ అయింది. చదవడానికి మాత్రమే ఉన్న ప్రశ్న సవరణ $revision, $when న సేవ్ అయింది. ఇప్పటికే ఉన్న క్విజ్ మరియు ప్రయత్నాల స్నాప్‌షాట్‌లు మారవు.',
    );
    return '$_temp0';
  }

  @override
  String get quizDateUnknown => 'తేదీ తెలియదు';

  @override
  String quizRevisionSelected(String revision) {
    return 'సవరణ $revision ఎంచుకోబడింది. చదవడానికి మాత్రమే.';
  }

  @override
  String quizRevisionSelectedOf(
    String revision,
    String position,
    String count,
  ) {
    return 'సవరణ $revision ఎంచుకోబడింది, $count లో $position. చదవడానికి మాత్రమే.';
  }

  @override
  String quizRevisionFailed(String message) {
    return '$message ఫోకస్ సవరణలను రిఫ్రెష్ చేయండి పై ఉంది.';
  }

  @override
  String get quizNoRevisionLoaded => 'ఏ సవరణా లోడ్ కాలేదు.';

  @override
  String quizShowingRevision(String revision) {
    return 'సవరణ $revision చూపిస్తోంది. చదవడానికి మాత్రమే.';
  }

  @override
  String quizRevisionVersion(String revision, String when) {
    return 'సవరణ $revision. $when న సేవ్ అయింది. చదవడానికి మాత్రమే.';
  }

  @override
  String quizRevisionQuestion(String text) {
    return 'ప్రశ్న: $text';
  }

  @override
  String quizRevisionTopics(String topics) {
    return 'అంశాలు: $topics';
  }

  @override
  String quizRevisionOption(String number, String text) {
    return 'ఎంపిక $number: $text.';
  }

  @override
  String get quizCorrectAnswerSentence => 'సరైన జవాబు.';

  @override
  String quizRevisionExplanation(String text) {
    return 'వివరణ: $text';
  }

  @override
  String get quizNotProvided => 'ఇవ్వలేదు';

  @override
  String get quizRevisionNotice =>
      'ట్రాకింగ్ ప్రారంభించిన తర్వాత సేవ్ అయిన సవరణలు మాత్రమే అందుబాటులో ఉన్నాయి. పాత చరిత్ర తెలియదు. ఇప్పటికే ఉన్న క్విజ్ మరియు ప్రయత్నాల స్నాప్‌షాట్‌లు ఎప్పుడూ మార్చబడవు.';

  @override
  String quizRevisionVersionTitle(String revision, String when) {
    return 'సవరణ $revision, $when';
  }

  @override
  String get quizQuestionTextTitle => 'ప్రశ్న టెక్స్ట్';

  @override
  String get quizTopicsTitle => 'అంశాలు';

  @override
  String quizOptionNumber(String number) {
    return 'ఎంపిక $number';
  }

  @override
  String quizOptionNumberCorrect(String number) {
    return 'ఎంపిక $number, సరైన జవాబు';
  }

  @override
  String get quizExplanationTitle => 'వివరణ';

  @override
  String get quizRevisionNoticeTitle => 'సవరణల చరిత్ర గురించి';

  @override
  String quizRevisionSectionTarget(String title) {
    return '$title. వినడానికి ఓకే నొక్కండి';
  }

  @override
  String get quizAccountChangedSignIn =>
      'ఖాతా మారింది. తిరిగి వెళ్ళి మళ్ళీ సైన్ ఇన్ చేయండి.';

  @override
  String get quizGoBack => 'వెనక్కి వెళ్ళండి';

  @override
  String get quizCancel => 'రద్దు చేయండి';

  @override
  String get quizCancelAndReturn => 'రద్దు చేసి తిరిగి వెళ్ళండి';

  @override
  String get quizActionNavigation => 'అందుబాటులో ఉన్న చర్యలు మరియు రద్దు';

  @override
  String get quizRefreshRevisions => 'సవరణలను రిఫ్రెష్ చేయండి';

  @override
  String get quizNewerRevision => 'కొత్త సవరణ';

  @override
  String get quizOlderRevision => 'పాత సవరణ';

  @override
  String get quizBankArchived => 'బ్యాంక్ ప్రశ్న ఆర్కైవ్ చేయబడింది';

  @override
  String get quizBankCopied => 'బ్యాంక్ ప్రశ్న కాపీ తయారైంది';

  @override
  String get quizSnapshotAdded => 'ప్రశ్న స్నాప్‌షాట్ క్విజ్‌కు జోడించబడింది';

  @override
  String get quizQuizClosed => 'క్విజ్ మూసివేయబడింది';

  @override
  String get quizDraftCreated => 'మార్చగలిగే క్విజ్ డ్రాఫ్ట్ తయారైంది';

  @override
  String get quizNoAnswerSelected => 'ఏ జవాబూ ఎంచుకోలేదు.';

  @override
  String get quizSelectBeforeSubmit => 'సమర్పించే ముందు ఒక ఎంపికను ఎంచుకోండి.';

  @override
  String get quizSubmitBeforeContinuing =>
      'కొనసాగే ముందు మీ జవాబును సమర్పించండి.';

  @override
  String get quizTeacherNavigationPrivate =>
      'ప్రైవేట్ బ్యాంక్ శోధన మరియు సేవ్ చేసిన ప్రశ్నలు, క్విజ్ డ్రాఫ్ట్‌లు, ప్రచురించిన క్విజ్‌లు, మరియు వాటి ఫలితాలు';

  @override
  String get quizStudentNavigationHelp =>
      'రిఫ్రెష్, క్విజ్ స్థితి ఫిల్టర్, సబ్జెక్టు ఫిల్టర్, అందుబాటులో ఉన్న ప్రతి క్విజ్ లేదా అభ్యాస కార్యకలాపం, మరియు దాని ప్రయత్నాల చరిత్రకు చేరడానికి డి-ప్యాడ్ పైకి, కిందకి ఉపయోగించండి. ఫిల్టర్‌ను మార్చడానికి ఎడమ లేదా కుడి ఉపయోగించండి. క్విజ్ వివరాలు వినడానికి, ప్రారంభించడం లేదా కొనసాగించడం నిర్ధారించడానికి క్విజ్‌పై ఓకే నొక్కండి. గత ప్రయత్నాలను సమీక్షించడానికి ప్రయత్నాల చరిత్రపై ఓకే నొక్కండి. ఫోకస్ కదిలించడం వల్ల ఎప్పుడూ ప్రయత్నం ప్రారంభం కాదు.';

  @override
  String get quizNoQuizzesAvailable => 'క్విజ్‌లు ఏవీ అందుబాటులో లేవు.';

  @override
  String quizQuizzesAvailableRaw(String count) {
    return '$count క్విజ్‌లు అందుబాటులో ఉన్నాయి.';
  }

  @override
  String get quizStudentNavigationSections =>
      'రిఫ్రెష్, క్విజ్ స్థితి మరియు సబ్జెక్టు ఫిల్టర్‌లు, అందుబాటులో ఉన్న క్విజ్‌లు మరియు అభ్యాస కార్యకలాపాలు, మరియు గత ప్రయత్నాలు';

  @override
  String quizAttemptLimitReached(String title) {
    return '$title కోసం ప్రయత్నాల పరిమితి ముగిసింది. మీ మార్కులను సమీక్షించడానికి ప్రయత్నాల చరిత్రను తెరవండి.';
  }

  @override
  String get quizNoPerAttemptLimit => 'ప్రతి ప్రయత్నానికి సమయ పరిమితి లేదు.';

  @override
  String quizTimeLimitRaw(String minutes) {
    return 'సమయ పరిమితి $minutes నిమిషాలు.';
  }

  @override
  String get quizCannotGoBack => 'దీన్ని మార్చడానికి మీరు వెనక్కి వెళ్లలేరు.';

  @override
  String get quizStartFailedAvailability =>
      'క్విజ్‌ను ప్రారంభించలేకపోయాము. అది అందుబాటులో ఉందో లేదో చూడండి.';

  @override
  String get quizStateFieldName => 'క్విజ్ స్థితి';

  @override
  String get quizSubjectFieldName => 'సబ్జెక్టు';

  @override
  String quizUseLeftRightToChange(String item) {
    return '$item. మార్చడానికి ఎడమ లేదా కుడి ఉపయోగించండి';
  }

  @override
  String get quizAttemptCompletePrivate =>
      'ప్రయత్నం పూర్తయింది. మీ ఫలితం ప్రైవేట్‌గానే ఉంటుంది.';

  @override
  String get quizHelpCompleted =>
      'క్విజ్‌లకు తిరిగి వెళ్లడం, ఫలితాన్ని ప్రైవేట్‌గా చదవడం మధ్య కదలడానికి డి-ప్యాడ్ పైకి, కిందకి ఉపయోగించండి. బటన్‌ను ఉపయోగించడానికి ఓకే నొక్కండి. మీ ఫలితాన్ని ప్రైవేట్‌గా చదవడానికి 8 నొక్కండి, తిరిగి వెళ్లడానికి 0 నొక్కండి.';

  @override
  String get quizHelpRetry =>
      'ముగించడానికి మళ్లీ ప్రయత్నించడానికి 5, మీరు ఎక్కడ ఉన్నారో వినడానికి 8, లేదా నిర్ధారణతో బయటకు వెళ్లడానికి 0 నొక్కండి. ఇతర నియంత్రణల కోసం డి-ప్యాడ్ పైకి, కిందకి ఉపయోగించండి.';

  @override
  String get quizHelpNext =>
      'తరువాతి ప్రశ్న ఆటోమేటిక్‌గా వస్తుంది. మళ్లీ వినడానికి 6, మీరు ఎక్కడ ఉన్నారో వినడానికి 8 నొక్కండి.';

  @override
  String quizHelpChoose(String count) {
    return 'ఎంచుకోవడానికి 1 నుండి $count వరకు నొక్కండి, తర్వాత సమర్పించడానికి 5 నొక్కండి. ప్రశ్న మరియు ఎంపికలను మళ్లీ వినడానికి 6, మీరు ఎక్కడ ఉన్నారో మరియు మిగిలిన సమయం వినడానికి 8 నొక్కండి.';
  }

  @override
  String get quizHelpFinishLeave =>
      'ఇప్పుడే క్విజ్ ముగించండి అనేది డి-ప్యాడ్ జాబితాలో ఉంది, అది నిర్ధారణ అడుగుతుంది. సమర్పించకుండా బయటకు వెళ్లడానికి 0 నొక్కండి.';

  @override
  String quizSelectedOptionNotSubmitted(String number, String text) {
    return 'ఎంపిక $number ఎంచుకున్నారు. $text. ఇంకా సమర్పించలేదు.';
  }

  @override
  String quizSelectedOptionConfirmed(String number, String text) {
    return 'ఎంపిక $number ఎంచుకున్నారు. $text. సమాధానం నిర్ధారించబడింది.';
  }

  @override
  String quizFeedbackCorrect(String answer, String explanation) {
    return 'సరైనది. సరైన సమాధానం: $answer. $explanation';
  }

  @override
  String quizFeedbackIncorrect(String answer, String explanation) {
    return 'తప్పు. సరైన సమాధానం: $answer. $explanation';
  }

  @override
  String quizOptionSelectedNotSubmitted(String number, String text) {
    return 'ఎంపిక $number. $text. ఎంచుకున్నారు, సమర్పించలేదు. మీ సమాధానాన్ని సేవ్ చేయడానికి 5 నొక్కండి.';
  }

  @override
  String get quizAttemptFinishedWhere =>
      'ప్రయత్నం ముగిసింది. మీ ఫలితాన్ని ప్రైవేట్‌గా వినడానికి 8 నొక్కండి.';

  @override
  String get quizNoOptionChosenYet => 'ఇంకా ఏ ఎంపికనూ ఎంచుకోలేదు.';

  @override
  String quizOptionChosen(String number) {
    return 'ఎంపిక $number ఎంచుకున్నారు.';
  }

  @override
  String quizCompletionFailedRetry(String reason) {
    return '$reason మీరు సేవ్ చేసిన సమాధానాలు భద్రంగా ఉన్నాయి. ఫలితాన్ని చూడడానికి పూర్తి చేయడం మళ్లీ ప్రయత్నించండి ఎంచుకోండి.';
  }

  @override
  String quizAttemptStatusPrivate(String status) {
    return 'ప్రయత్నం $status. మీ ఫలితం ప్రైవేట్.';
  }

  @override
  String get quizEarlyCountUnconfirmed =>
      'ప్రస్తుతం సేవ్ అయిన సమాధానాల సంఖ్యను నిర్ధారించలేకపోయాము, లేదా ఈ ప్రయత్నం ముగిసింది. ముందుగా సమర్పణ ఏదీ పంపలేదు. స్థితిని రిఫ్రెష్ చేయడానికి క్విజ్ జాబితాకు తిరిగి వెళ్లండి.';

  @override
  String get quizEarlyTitle => 'ఈ ప్రయత్నాన్ని ముందుగానే సమర్పించాలా?';

  @override
  String quizEarlyMessage(String count) {
    return '$count ప్రశ్నలకు సమాధానం ఇవ్వలేదని సర్వర్ తనిఖీ నిర్ధారిస్తోంది. ముగించే సమయానికి సర్వర్‌లో సేవ్ అయిన సమాధానాలు మాత్రమే లెక్కలోకి వస్తాయి. ఎంచుకున్నా సేవ్ కాని సమాధానం లెక్కలోకి రాదు. చివరి సమర్పణను రద్దు చేయలేరు, మార్చలేరు. వెనక్కి వెళ్తే ఎప్పుడూ సమర్పించబడదు.';
  }

  @override
  String get quizEarlyConfirm => 'సేవ్ అయిన సమాధానాలను ముగించండి';

  @override
  String get quizEarlyTimedOut =>
      'సేవ్ అయిన సమాధానాల తనిఖీకి సమయం ముగిసింది. ముందుగా సమర్పణ ఏదీ పంపలేదు. మీ కనెక్షన్ చూసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get quizWaitPending =>
      'బయటకు వెళ్లే ముందు పెండింగ్‌లో ఉన్న సమాధానం లేదా పూర్తి నిర్ధారణ కోసం వేచి ఉండండి.';

  @override
  String get quizLeaveMessageServer =>
      'దీనివల్ల మీ ప్రయత్నం సమర్పించబడదు. సర్వర్ నిర్ధారించిన సమాధానాలు మాత్రమే సేవ్ అవుతాయి; సేవ్ కాని ఎంపిక పోవచ్చు. టైమర్ ఉంటే అది నడుస్తూనే ఉంటుంది. సర్వర్ ఈ ప్రయత్నాన్ని అనుమతించినంత వరకు మాత్రమే కొనసాగించవచ్చు.';

  @override
  String get quizStayInAttempt => 'ప్రయత్నంలోనే ఉండండి';

  @override
  String get quizNextQuestionNow => 'ఇప్పుడే తరువాతి ప్రశ్న';

  @override
  String get quizReadAllOptions => 'అన్ని సమాధాన ఎంపికలను చదవండి';

  @override
  String quizOptionTargetSelectedSubmit(String number, String text) {
    return 'ఎంపిక $number, $text, ఎంచుకోబడింది. ఎంచుకోవడానికి ఓకే లేదా $number నొక్కండి. సిద్ధంగా ఉన్నప్పుడు మాత్రమే సమర్పించడానికి 5 నొక్కండి';
  }

  @override
  String quizOptionTargetNotSelectedSubmit(String number, String text) {
    return 'ఎంపిక $number, $text, ఎంచుకోలేదు. ఎంచుకోవడానికి ఓకే లేదా $number నొక్కండి. సిద్ధంగా ఉన్నప్పుడు మాత్రమే సమర్పించడానికి 5 నొక్కండి';
  }

  @override
  String get quizReadSelectionTarget =>
      'ఎంచుకున్న సమాధానం మరియు సేవ్ స్థితిని చదవండి';

  @override
  String get quizStopSpeech => 'మాటలు ఆపండి';

  @override
  String get quizAnswerFeedback => 'సమాధాన ఫీడ్‌బ్యాక్';

  @override
  String get quizAnswerConfirmedReadFeedback =>
      'సమాధానం సేవ్ అయి లాక్ అయినట్లు నిర్ధారించబడింది. ఫీడ్‌బ్యాక్‌ను ప్రైవేట్‌గా చదవడానికి ఓకే నొక్కండి.';

  @override
  String get quizRetryCompletion => 'పూర్తి చేయడం మళ్లీ ప్రయత్నించండి';

  @override
  String get quizViewResult => 'ఫలితం చూడండి';

  @override
  String get quizNextQuestion => 'తరువాతి ప్రశ్న';

  @override
  String get quizAttemptInProgressResume =>
      'ప్రయత్నం కొనసాగుతోంది. దాన్ని కొనసాగించడానికి క్విజ్ జాబితాకు తిరిగి వెళ్లండి. బయటకు వెళ్తే సమర్పించబడదు.';

  @override
  String get quizReviewTimedOutShort =>
      'ప్రయత్న సమీక్షకు సమయం ముగిసింది. మీ కనెక్షన్ చూసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get quizNoScoreCurrentlyReleased =>
      'పూర్తయిన ప్రయత్నాలు ఉన్నాయి; ప్రస్తుతం ఏ మార్కులూ విడుదల చేయలేదు.';

  @override
  String get quizHistoryScreenNavigate =>
      'ప్రయత్నాల చరిత్ర. మార్కులు ప్రైవేట్. సమీక్షించడానికి సారాంశం లేదా ఒక ప్రయత్నానికి వెళ్లండి.';

  @override
  String quizHistoryAttemptRaw(String number, String status, String result) {
    return 'ప్రయత్నం $number. $status. $result. సమీక్షించడానికి ఓకే నొక్కండి.';
  }

  @override
  String quizReviewAnswerCorrect(
    String number,
    String question,
    String selected,
    String answer,
    String explanation,
  ) {
    return 'ప్రశ్న $number. సరైనది. $question. ఎంచుకున్నది $selected. సరైన సమాధానం $answer. $explanation';
  }

  @override
  String quizReviewAnswerIncorrect(
    String number,
    String question,
    String selected,
    String answer,
    String explanation,
  ) {
    return 'ప్రశ్న $number. తప్పు. $question. ఎంచుకున్నది $selected. సరైన సమాధానం $answer. $explanation';
  }

  @override
  String get quizNoAnswerCapital => 'సమాధానం లేదు';

  @override
  String quizReviewScreenRaw(String count) {
    return 'ప్రయత్న సమీక్ష. $count ప్రశ్నలు. ప్రతి సమాధానాన్ని సమీక్షించడానికి పైకి, కిందకి ఉపయోగించండి.';
  }

  @override
  String get quizMetaTopics =>
      'అంశాలు లేదా భావనలు, ఒక్కో లైన్‌కు ఒకటి (ఐచ్ఛికం)';

  @override
  String get quizMetaSpokenQuestion => 'ఉపాధ్యాయులు రాసిన మాట్లాడే ప్రశ్న';

  @override
  String quizMetaSpokenOption(String number) {
    return 'మాట్లాడే ఎంపిక $number';
  }

  @override
  String get quizMetaSpokenExplanation => 'ఉపాధ్యాయులు రాసిన మాట్లాడే వివరణ';

  @override
  String quizCorrectSelected(String number) {
    return 'ఎంపిక $number సరైన సమాధానంగా ఎంచుకోబడింది';
  }

  @override
  String quizCorrectSelectedWithText(String number, String text) {
    return 'ఎంపిక $number సరైన సమాధానంగా ఎంచుకోబడింది, $text';
  }

  @override
  String get quizEditBankQuestion => 'బ్యాంక్ ప్రశ్నను మార్చండి';

  @override
  String get quizCreateBankQuestion => 'బ్యాంక్ ప్రశ్నను సృష్టించండి';

  @override
  String get quizEditorNavigation =>
      'ప్రశ్న పాఠ్యం, నాలుగు సమాధాన ఫీల్డ్‌లు, సరైన సమాధానం ఎంపిక, ఐచ్ఛిక మాట్లాడే వివరణలు, మరియు సేవ్ లేదా రద్దు';

  @override
  String get quizSaveQuestion => 'ప్రశ్నను సేవ్ చేయండి';

  @override
  String get quizCancelQuestion => 'ప్రశ్నను రద్దు చేయండి';

  @override
  String quizPressOkToEdit(String item) {
    return '$item. మార్చడానికి ఓకే నొక్కండి';
  }

  @override
  String quizPressOkToChange(String item) {
    return '$item. మార్చడానికి ఓకే నొక్కండి';
  }

  @override
  String quizCorrectIsOption(String number, String text) {
    return 'ఎంపిక $number, $text, సరైన సమాధానం. మార్చడానికి ఎడమ లేదా కుడి ఉపయోగించండి';
  }

  @override
  String get quizHideOptionalExplanation =>
      'ఐచ్ఛిక వివరణ, అంశాలు మరియు మాట్లాడే సంకేతాలను దాచండి';

  @override
  String get quizShowOptionalExplanation =>
      'ఐచ్ఛిక వివరణ, అంశాలు మరియు మాట్లాడే సంకేతాలను చూపండి';

  @override
  String get quizOptionalExplanation => 'ఐచ్ఛిక సమాధాన వివరణ';

  @override
  String quizNumericDateTime(
    String day,
    String month,
    String year,
    String hour,
    String minute,
  ) {
    return '$day/$month/$year న $hour:$minute కి';
  }

  @override
  String get quizCheckTitleLimits =>
      'శీర్షిక, పరిమితులు మరియు షెడ్యూల్‌ను తనిఖీ చేయండి.';

  @override
  String get quizSettingsNavigation =>
      'శీర్షిక, ఐచ్ఛిక వివరణ, సమయం మరియు ప్రయత్న సెట్టింగ్‌లు, ఫీడ్‌బ్యాక్ మరియు షఫుల్ ఎంపికలు, మరియు కొనసాగించండి లేదా రద్దు';

  @override
  String get quizChangeSettingsScreen =>
      'క్విజ్ శీర్షిక మరియు ఐచ్ఛిక సెట్టింగ్‌లను మార్చండి. సేవ్ చేస్తే ప్రచురించబడదు.';

  @override
  String get quizCreatePracticeScreen =>
      'సమయ పరిమితి, మార్కులు లేని అభ్యాసాన్ని సృష్టించండి. అపరిమిత ప్రయత్నాలు, వెంటనే ఫీడ్‌బ్యాక్.';

  @override
  String get quizContinueToQuestions => 'ప్రశ్నలకు కొనసాగండి';

  @override
  String get quizSaveSettingsReturn =>
      'సెట్టింగ్‌లు సేవ్ చేసి సమీక్షకు తిరిగి వెళ్లండి';

  @override
  String get quizQuizTitle => 'క్విజ్ శీర్షిక';

  @override
  String get quizHideOptionalSettings =>
      'ఐచ్ఛిక సెట్టింగ్‌లను దాచండి: వివరణ, ప్రయత్నాలు, సమయం, ఫీడ్‌బ్యాక్ మరియు షఫుల్';

  @override
  String get quizShowOptionalSettings =>
      'ఐచ్ఛిక సెట్టింగ్‌లను చూపండి: వివరణ, ప్రయత్నాలు, సమయం, ఫీడ్‌బ్యాక్ మరియు షఫుల్';

  @override
  String get quizOptionalDescription => 'ఐచ్ఛిక క్విజ్ వివరణ';

  @override
  String quizSetOrClear(String item) {
    return '$item. సెట్ చేయడానికి ఓకే నొక్కండి. తీసివేయడానికి ఎడమ ఉపయోగించండి';
  }

  @override
  String quizShuffleQuestionsToggle(String state) {
    return 'ప్రశ్నలను షఫుల్ చేయడం $state. మార్చడానికి ఓకే లేదా ఎడమ లేదా కుడి నొక్కండి';
  }

  @override
  String quizShuffleOptionsToggle(String state) {
    return 'సమాధాన ఎంపికలను షఫుల్ చేయడం $state. మార్చడానికి ఓకే లేదా ఎడమ లేదా కుడి నొక్కండి';
  }

  @override
  String get quizCancelQuizCreation => 'క్విజ్ సృష్టించడం రద్దు చేయండి';

  @override
  String quizFeedbackPolicyTarget(String policy) {
    return 'ఫీడ్‌బ్యాక్ విధానం $policy. ఎడమ లేదా కుడి దాన్ని మారుస్తుంది';
  }

  @override
  String get quizSaveDraftContinue => 'డ్రాఫ్ట్ సేవ్ చేసి ప్రశ్నలకు కొనసాగండి';

  @override
  String get sessionScreenTeacherClass => 'ఉపాధ్యాయుల తరగతి';

  @override
  String get sessionScreenClass => 'తరగతి';

  @override
  String get sessionDefaultTitle => 'సెషన్';

  @override
  String get sessionJoining => 'తరగతిలో చేరుతున్నాము. దయచేసి వేచి ఉండండి.';

  @override
  String get sessionConnecting => 'తరగతికి కనెక్ట్ అవుతోంది.';

  @override
  String get sessionJoinFailed =>
      'తరగతిలో చేరలేకపోయాము. బయటకు వెళ్లడానికి 0 నొక్కి, మళ్లీ ప్రయత్నించండి.';

  @override
  String get sessionLeaveKeyHint =>
      'తరగతి నుండి బయటకు వెళ్లడానికి 0 నొక్కండి. అది నిర్ధారణ అడుగుతుంది.';

  @override
  String get sessionKeyLine => '*: సహాయం మరియు చివరి సందేశం. #: మాటలు ఆపండి.';

  @override
  String sessionJoinedBrief(String status) {
    return 'తరగతిలో ఉన్నారు. $status సహాయం కోసం స్టార్ నొక్కండి.';
  }

  @override
  String sessionJoinedDetailed(String status, String keys) {
    return 'మీరు తరగతిలో ఉన్నారు. $status $keys నియంత్రణల మధ్య కదలడానికి పైకి, కిందకి ఉపయోగించండి, ఎంచుకోవడానికి ఓకే నొక్కండి. మీరు ఎక్కడ ఉన్నారో మరియు సహాయం కోసం స్టార్ నొక్కండి. మాటలు ఆపడానికి హ్యాష్ నొక్కండి.';
  }

  @override
  String get sessionMicWaitingLabel => 'మైక్రోఫోన్ నిర్ధారణ కోసం వేచి ఉంది';

  @override
  String get sessionUnmuteMicrophone => 'మైక్రోఫోన్ అన్‌మ్యూట్ చేయండి';

  @override
  String get sessionMuteMicrophone => 'మైక్రోఫోన్ మ్యూట్ చేయండి';

  @override
  String get sessionMuteButtonWaiting => '1: వేచి ఉంది';

  @override
  String get sessionMuteButtonUnmute => '1: అన్‌మ్యూట్';

  @override
  String get sessionMuteButtonMute => '1: మ్యూట్';

  @override
  String get sessionHandWaitingLabel => 'చేయి నిర్ధారణ కోసం వేచి ఉంది';

  @override
  String get sessionLowerHand => 'చేయి దించండి';

  @override
  String get sessionRaiseHand => 'చేయి ఎత్తండి';

  @override
  String get sessionHandButtonWaiting => '2: వేచి ఉంది';

  @override
  String get sessionHandButtonLower => '2: చేయి దించండి';

  @override
  String get sessionHandButtonRaise => '2: చేయి ఎత్తండి';

  @override
  String get sessionStatusLabel => 'తరగతి స్థితిని వినండి';

  @override
  String get sessionStatusButton => '3: తరగతి స్థితి';

  @override
  String sessionChatLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'చాట్. $count సందేశాలు',
      one: 'చాట్. 1 సందేశం',
      zero: 'చాట్. ఇంకా సందేశాలు లేవు',
    );
    return '$_temp0';
  }

  @override
  String get sessionChatButton => '4: చాట్';

  @override
  String get sessionRecordingPlayerNone =>
      'పాఠం రికార్డింగ్. ఇంకా ఏదీ ఎంచుకోలేదు';

  @override
  String sessionRecordingPlayerPlaying(String title) {
    return 'పాఠం రికార్డింగ్. $title, ప్లే అవుతోంది';
  }

  @override
  String sessionRecordingPlayerPaused(String title) {
    return 'పాఠం రికార్డింగ్. $title, ఆపివేయబడింది';
  }

  @override
  String get sessionRecordingStudentNone =>
      'తరగతి రికార్డింగ్. ఏదీ ప్లే కావడం లేదు. ఉపాధ్యాయులు మాత్రమే దీన్ని నియంత్రిస్తారు';

  @override
  String sessionRecordingStudentPlaying(String title) {
    return 'తరగతి రికార్డింగ్, $title, ఉపాధ్యాయులు ప్లే చేస్తున్నారు. అది ఎక్కడ ఉందో వినండి';
  }

  @override
  String sessionRecordingStudentPaused(String title) {
    return 'తరగతి రికార్డింగ్, $title, ఉపాధ్యాయులు ఆపారు. అది ఎక్కడ ఉందో వినండి';
  }

  @override
  String get sessionRecordingStatusButton => '5: రికార్డింగ్ స్థితి';

  @override
  String get sessionStudentRecordingNone =>
      'తరగతి రికార్డింగ్ ఏదీ ప్లే కావడం లేదు. ఉపాధ్యాయులు మాత్రమే దాన్ని ప్లే చేయగలరు.';

  @override
  String sessionStudentRecordingPlaying(String title, String position) {
    return '$title, ప్లే అవుతోంది, $position వద్ద ఉంది. తరగతి రికార్డింగ్‌ను ఉపాధ్యాయులు మాత్రమే ప్లే చేయగలరు, ఆపగలరు లేదా ముందుకు వెనక్కి కదిలించగలరు.';
  }

  @override
  String sessionStudentRecordingPaused(String title, String position) {
    return '$title, ఆపివేయబడింది, $position వద్ద ఉంది. తరగతి రికార్డింగ్‌ను ఉపాధ్యాయులు మాత్రమే ప్లే చేయగలరు, ఆపగలరు లేదా ముందుకు వెనక్కి కదిలించగలరు.';
  }

  @override
  String get sessionRecordingPlayerButton => '5: పాఠం రికార్డింగ్';

  @override
  String get sessionOpeningPlayerToChoose =>
      'ఇంకా ఏ రికార్డింగ్‌నూ ఎంచుకోలేదు. ఒకదాన్ని ఎంచుకోవడానికి 1 నొక్కండి.';

  @override
  String get sessionCheckLabel => 'ఉపాధ్యాయుల ప్రశ్నకు సమాధానం ఇవ్వండి';

  @override
  String get sessionCheckButton => '3: ప్రశ్నకు సమాధానం ఇవ్వండి';

  @override
  String sessionHandsLabel(String waiting) {
    return 'ఎత్తిన చేతులు. $waiting';
  }

  @override
  String get sessionHandsButton => '2: ఎత్తిన చేతులు';

  @override
  String sessionHandsButtonCount(int count) {
    return '2: ఎత్తిన చేతులు ($count)';
  }

  @override
  String get sessionTeacherCheckLabel =>
      'తరగతి తనిఖీ. ప్రైవేట్ తనిఖీని ప్రారంభించండి, ముగించండి మరియు సమాధానాలను వినండి';

  @override
  String sessionParticipantsLabel(String people) {
    return 'పాల్గొనేవారు. $people ఎవరినైనా మ్యూట్ చేయండి లేదా తీసివేయండి, లేదా సారాంశం వినండి';
  }

  @override
  String get sessionParticipantsButton => '7: పాల్గొనేవారు';

  @override
  String get sessionToolsLabel =>
      'ఉపాధ్యాయుల సాధనాలు. సమయం పెంచండి లేదా అందరికీ తరగతిని ముగించండి';

  @override
  String get sessionToolsButton => '9: ఉపాధ్యాయుల సాధనాలు';

  @override
  String get sessionVoiceStartLabel =>
      'ఒక వాయిస్ కమాండ్ కోసం 12 సెకన్ల వరకు వినండి. మీరు ఓకే నొక్కినప్పుడు మాత్రమే ప్రారంభమవుతుంది';

  @override
  String get sessionVoiceStopLabel => 'వాయిస్ కమాండ్ కోసం వినడం ఆపండి';

  @override
  String get sessionVoiceStartButton => 'కమాండ్ కోసం వినండి';

  @override
  String get sessionVoiceStopButton => 'వినడం ఆపండి';

  @override
  String get sessionUpdatesLabel => 'తరగతి అప్‌డేట్‌లను చదవండి';

  @override
  String get sessionUpdatesButton => 'తరగతి అప్‌డేట్‌లు';

  @override
  String get sessionRetryLabel => 'తరగతి కనెక్షన్ మళ్లీ ప్రయత్నించండి';

  @override
  String get sessionRetryButton => 'కనెక్షన్ మళ్లీ ప్రయత్నించండి';

  @override
  String get sessionLeaveLabel => 'తరగతి నుండి బయటకు వెళ్లండి';

  @override
  String get sessionLeaveButton => '0: తరగతి నుండి బయటకు వెళ్లండి';

  @override
  String get sessionMicWaiting => 'మైక్రోఫోన్ నిర్ధారణ కోసం వేచి ఉంది.';

  @override
  String get sessionMicMuted => 'మ్యూట్ చేయబడింది.';

  @override
  String get sessionMicUnmutedHeard =>
      'అన్‌మ్యూట్ చేయబడింది. ఇతరులు మీ మాట వినగలరు.';

  @override
  String get sessionHandWaiting => 'చేయి నిర్ధారణ కోసం వేచి ఉంది.';

  @override
  String get sessionHandRaisedState => 'చేయి ఎత్తారు.';

  @override
  String get sessionHandDown => 'చేయి దించారు.';

  @override
  String sessionHandsWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count చేతులు వేచి ఉన్నాయి.',
      one: '1 చేయి వేచి ఉంది.',
      zero: 'ఏ చేతులూ వేచి లేవు.',
    );
    return '$_temp0';
  }

  @override
  String sessionPeople(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'తరగతిలో $count మంది ఉన్నారు.',
      one: 'తరగతిలో 1 వ్యక్తి ఉన్నారు.',
    );
    return '$_temp0';
  }

  @override
  String get sessionNoRecordingSelected => 'ఏ రికార్డింగ్‌నూ ఎంచుకోలేదు.';

  @override
  String sessionRecordingStatePlaying(String title) {
    return 'రికార్డింగ్ ప్లే అవుతోంది: $title.';
  }

  @override
  String sessionRecordingStatePaused(String title) {
    return 'రికార్డింగ్ ఆపివేయబడింది: $title.';
  }

  @override
  String get sessionCheckOpen => 'తరగతి తనిఖీ తెరిచి ఉంది.';

  @override
  String sessionConnectionLabel(String label) {
    return '$label.';
  }

  @override
  String sessionChatMessages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count చాట్ సందేశాలు.',
      one: '1 చాట్ సందేశం.',
    );
    return '$_temp0';
  }

  @override
  String get sessionRecordingFallback => 'తరగతి రికార్డింగ్';

  @override
  String get sessionRecordingFallbackLower => 'తరగతి రికార్డింగ్';

  @override
  String sessionUserFallback(String id) {
    return 'వినియోగదారు $id';
  }

  @override
  String sessionConnectionRestored(String message) {
    return 'కనెక్షన్ తిరిగి వచ్చింది. $message';
  }

  @override
  String sessionConnectionLost(String message) {
    return 'కనెక్షన్ పోయింది. $message';
  }

  @override
  String sessionCouldNotConnect(String message) {
    return 'కనెక్ట్ కాలేకపోయింది. $message';
  }

  @override
  String get sessionMicDialogTitle => 'మైక్రోఫోన్ యాక్సెస్';

  @override
  String get sessionMicDialogMessage =>
      'ఈ తరగతిలో SEEDS లైవ్ ఆడియో కోసం మరియు మీరు స్పష్టంగా ఆన్ చేసిన వాయిస్ కమాండ్‌ల కోసం మైక్రోఫోన్‌ను ఉపయోగిస్తుంది. మైక్రోఫోన్ యాక్సెస్ లేకుండా కూడా మీరు ఉండవచ్చు, కానీ ఇతరులు మీ మాట వినలేరు. వేరుగా ప్రైవేట్ నోట్ రికార్డింగ్‌కు లైవ్ తరగతుల బయట దానికంటూ స్పష్టమైన ప్రారంభం అవసరం.';

  @override
  String get sessionMicDialogConfirm => 'తరగతికి కొనసాగండి';

  @override
  String get sessionMicSkipped =>
      'మైక్రోఫోన్ యాక్సెస్ దాటవేయబడింది. మీరు మ్యూట్‌లో తరగతిలో చేరారు.';

  @override
  String get sessionMicUnavailable =>
      'మైక్రోఫోన్ యాక్సెస్ అందుబాటులో లేదు. మీరు మ్యూట్‌లో తరగతిలో చేరారు.';

  @override
  String get sessionWaitingMic => 'మైక్రోఫోన్ నిర్ధారణ కోసం వేచి ఉంది.';

  @override
  String get sessionMuted => 'మ్యూట్ చేయబడింది';

  @override
  String get sessionUnmuted => 'అన్‌మ్యూట్ చేయబడింది';

  @override
  String get sessionMutedLocallyOnly =>
      'ఈ ఫోన్‌లో మైక్రోఫోన్ మ్యూట్ చేయబడింది. తరగతి నుండి నిర్ధారణ అందలేదు.';

  @override
  String get sessionMutedByTeacher =>
      'ఉపాధ్యాయులు మీ మైక్రోఫోన్‌ను మ్యూట్ చేశారు.';

  @override
  String get sessionMicClassClosed =>
      'తరగతి ముగిసింది. మైక్రోఫోన్ చర్య ఏదీ పంపలేదు.';

  @override
  String get sessionMicUnavailableRejoin =>
      'మైక్రోఫోన్ యాక్సెస్ అందుబాటులో లేదు. మాట్లాడే ముందు మైక్రోఫోన్ అనుమతిని చూసి, తరగతిలో మళ్లీ చేరండి.';

  @override
  String get sessionMicClosedBeforeConfirm =>
      'మైక్రోఫోన్ నిర్ధారణకు ముందే తరగతి ముగిసింది.';

  @override
  String get sessionMicNoLongerAvailable =>
      'మైక్రోఫోన్ యాక్సెస్ ఇక అందుబాటులో లేదు. మాట్లాడే ముందు తరగతిలో మళ్లీ చేరండి.';

  @override
  String get sessionMicStayedMuted =>
      'తరగతి మ్యూట్ స్థితి మారినందున మీ మైక్రోఫోన్ మ్యూట్‌లోనే ఉంది. మాట్లాడడానికి సిద్ధంగా ఉన్నప్పుడు అన్‌మ్యూట్ ఎంచుకోండి.';

  @override
  String get sessionWaitingHand => 'చేయి స్థితి నిర్ధారణ కోసం వేచి ఉంది.';

  @override
  String get sessionHandRaised => 'చేయి ఎత్తారు';

  @override
  String get sessionHandLowered => 'చేయి దించారు';

  @override
  String get sessionHandNotConfirmed =>
      'మీ చేయి మార్పు నిర్ధారించబడలేదు. మళ్లీ ప్రయత్నించడానికి 2 నొక్కండి.';

  @override
  String sessionRaisedHandBy(String name) {
    return '$name చేయి ఎత్తారు.';
  }

  @override
  String get sessionRaisedHandUnknown => 'ఒక విద్యార్థి చేయి ఎత్తారు.';

  @override
  String get sessionParticipantJoined => 'ఒక పాల్గొనేవారు చేరారు.';

  @override
  String get sessionParticipantsJoinedGroup => 'చేరిన పాల్గొనేవారు';

  @override
  String get sessionParticipantLeft => 'ఒక పాల్గొనేవారు వెళ్లిపోయారు.';

  @override
  String get sessionParticipantsLeftGroup => 'వెళ్లిపోయిన పాల్గొనేవారు';

  @override
  String get sessionParticipantFallback => 'పాల్గొనేవారు';

  @override
  String get sessionThisParticipant => 'ఈ పాల్గొనేవారు';

  @override
  String sessionParticipantSelf(String name) {
    return '$name, మీరు';
  }

  @override
  String get sessionRoleTeacher => 'ఉపాధ్యాయులు';

  @override
  String get sessionRoleStudent => 'విద్యార్థి';

  @override
  String get sessionStateHandRaised => 'చేయి ఎత్తారు';

  @override
  String get sessionStateMuted => 'మ్యూట్ చేయబడింది';

  @override
  String get sessionStateUnmuted => 'అన్‌మ్యూట్ చేయబడింది';

  @override
  String get sessionStateSpeaking => 'మాట్లాడుతున్నారు';

  @override
  String sessionAlreadyMuted(String name) {
    return '$name మ్యూట్‌లో ఉన్నారు. $name మాత్రమే అన్‌మ్యూట్ చేయగలరు.';
  }

  @override
  String sessionParticipantMuted(String name) {
    return '$name మ్యూట్ చేయబడ్డారు.';
  }

  @override
  String sessionRemoveTitle(String name) {
    return '$nameను తొలగించాలా?';
  }

  @override
  String sessionRemoveMessage(String name) {
    return '$nameను ఈ తరగతి నుండి తొలగించి, వారి డాష్‌బోర్డ్‌కు పంపుతాము. వారిని తర్వాత మళ్లీ ఆహ్వానించవచ్చు.';
  }

  @override
  String sessionKeep(String name) {
    return '$nameను ఉంచండి';
  }

  @override
  String sessionRemove(String name) {
    return '$nameను తొలగించండి';
  }

  @override
  String sessionRemoved(String name) {
    return '$nameను తరగతి నుండి తొలగించారు.';
  }

  @override
  String chatMessageFrom(String sender, String text) {
    return '$sender నుండి సందేశం: $text';
  }

  @override
  String get chatSenderUnknown => 'తెలియదు';

  @override
  String get chatSenderUnknownLower => 'తెలియదు';

  @override
  String get chatWaitingConfirmation => 'సందేశం నిర్ధారణ కోసం వేచి ఉంది.';

  @override
  String get chatEmptyMessage => 'పంపు ఎంచుకునే ముందు ఒక సందేశం రాయండి.';

  @override
  String get chatMessageSent => 'సందేశం పంపబడింది.';

  @override
  String get chatSending => 'పంపుతోంది';

  @override
  String get chatSent => 'పంపబడింది';

  @override
  String get chatNotConfirmed => 'నిర్ధారించబడలేదు';

  @override
  String get chatNoMessages => 'ఇంకా సందేశాలు లేవు.';

  @override
  String get chatTitle => 'చాట్';

  @override
  String get chatReadMessages => 'సందేశాలు చదవండి, కొత్తవి ముందు';

  @override
  String get chatWriteMessage => 'సందేశం రాయండి';

  @override
  String get chatMessageField => 'తరగతికి మీ సందేశం';

  @override
  String get chatMessagesTitle => 'చాట్ సందేశాలు';

  @override
  String get chatPhraseUnderstood => 'నాకు అర్థమైంది';

  @override
  String get chatPhraseRepeat => 'దయచేసి మళ్లీ చెప్పండి';

  @override
  String get chatPhraseQuestion => 'నాకు ఒక ప్రశ్న ఉంది';

  @override
  String chatSendPhrase(String phrase) {
    return 'పంపండి: $phrase';
  }

  @override
  String chatCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count సందేశాలు.',
      one: '1 సందేశం.',
    );
    return '$_temp0';
  }

  @override
  String get chatHelpBrief => 'చదవండి, రాయండి లేదా చిన్న వాక్యం పంపండి.';

  @override
  String get chatHelpDetailed =>
      'సందేశాలు చదవడానికి 1, ఒకటి రాయడానికి 2, లేదా చిన్న వాక్యం పంపడానికి 3 నుండి 5 నొక్కండి. కొత్త సందేశం వినడానికి 8 నొక్కండి.';

  @override
  String get chatYou => 'మీరు';

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
    return '$line. $timeకు పంపబడింది.';
  }

  @override
  String chatNewestMessage(String detail) {
    return 'కొత్త సందేశం. $detail';
  }

  @override
  String get chatReadLatest => 'తాజా సందేశం చదవండి';

  @override
  String get chatMessageLabel => 'చాట్ సందేశం';

  @override
  String get chatSendMessage => 'సందేశం పంపండి';

  @override
  String chatSaid(String sender, String text) {
    return '$sender చెప్పారు: $text';
  }

  @override
  String chatSaidDelivery(String sender, String text, String delivery) {
    return '$sender చెప్పారు: $text. $delivery';
  }

  @override
  String chatLatestLineDelivery(String sender, String text, String delivery) {
    return '$sender: $text\nపంపిన స్థితి: $delivery.';
  }

  @override
  String get sessionLeaveTitle => 'తరగతి నుండి వెళ్లాలా?';

  @override
  String get sessionLeaveMessage =>
      'మీరు ఈ తరగతి నుండి వెళ్లి మీ డాష్‌బోర్డ్‌కు తిరిగి వెళ్తారు. మీరు సైన్ ఇన్ అయ్యే ఉంటారు.';

  @override
  String get sessionTeacherLeaveMessage =>
      'మీరు వెళ్లి మీ డాష్‌బోర్డ్‌కు తిరిగి వెళ్తారు. విద్యార్థుల కోసం తరగతి కొనసాగుతుంది. అందరికీ ముగించడానికి, 9, ఉపాధ్యాయుల సాధనాలు ఉపయోగించండి.';

  @override
  String get sessionStay => 'తరగతిలో ఉండండి';

  @override
  String get sessionLeave => 'తరగతి నుండి వెళ్లండి';

  @override
  String get sessionLeaveLocallyTitle => 'సర్వర్ నిర్ధారణ లేకుండా వెళ్లాలా?';

  @override
  String get sessionLeaveLocallyMessage =>
      'ఈ ఫోన్ మ్యూట్‌లో ఉంది. మీ ఎత్తిన చేయి దించినట్లు సర్వర్ నిర్ధారించలేదు. ఇప్పుడు ఈ ఫోన్‌లో మాత్రమే వెళ్లాలా, లేదా ఉండి మళ్లీ ప్రయత్నించాలా? మళ్లీ కొత్తగా చేరితే మీ చేయి రీసెట్ అవుతుంది.';

  @override
  String get sessionStayAndRetry => 'ఉండి మళ్లీ ప్రయత్నించండి';

  @override
  String get sessionLeaveLocally => 'ఈ ఫోన్‌లో మాత్రమే వెళ్లండి';

  @override
  String get sessionEndTitle => 'అందరికీ తరగతి ముగించాలా?';

  @override
  String get sessionEndMessage =>
      'ఇది ప్రతి పాల్గొనేవారికి తరగతిని ఆపి, అందరినీ వారి డాష్‌బోర్డ్‌కు పంపుతుంది. ఎవరూ లాగ్ అవుట్ కారు.';

  @override
  String get sessionEndCancel => 'తరగతిని కొనసాగించండి';

  @override
  String get sessionEndConfirm => 'అందరికీ ముగించండి';

  @override
  String get sessionWaitingEnd => 'తరగతి ముగింపు నిర్ధారణ కోసం వేచి ఉంది.';

  @override
  String get sessionEndNotConfirmed =>
      'తరగతి ముగింపు నిర్ధారించబడలేదు. తరగతి ఇంకా కొనసాగుతోంది.';

  @override
  String get sessionEndingForEveryone => 'అందరికీ తరగతి ముగిస్తోంది.';

  @override
  String get sessionYouLeft => 'మీరు తరగతి నుండి వెళ్లిపోయారు.';

  @override
  String get sessionClassEnded => 'తరగతి ముగిసింది.';

  @override
  String get sessionYouWereRemoved => 'మిమ్మల్ని తరగతి నుండి తొలగించారు.';

  @override
  String get sessionSignInChanged =>
      'మీ సైన్ ఇన్ మారింది. మళ్లీ సైన్ ఇన్ చేయండి లేదా మీ పాఠశాల నిర్వాహకులను సంప్రదించండి.';

  @override
  String get sessionCleanupFailed =>
      'సైన్ ఇన్ ముగిసింది. ఫోన్ ఆడియో ఆపడం నిర్ధారించబడలేదు. ఆడియో ఇంకా వస్తుంటే SEEDS మూసివేయండి.';

  @override
  String get sessionCleanupTimedOut =>
      'సైన్ ఇన్ ముగిసింది. ఆడియో ఆపడానికి సమయం మించిపోయింది. ఆడియో ఇంకా వస్తుంటే SEEDS మూసివేయండి.';

  @override
  String get sessionRequestFailed =>
      'ఆ అభ్యర్థనను పూర్తి చేయలేకపోయాము. దయచేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get sessionVoiceStopped => 'స్వర ఆదేశాలు వినడం ఆగింది.';

  @override
  String get sessionVoiceUnmuteTitle => 'మీ మైక్రోఫోన్‌ను అన్‌మ్యూట్ చేయాలా?';

  @override
  String get sessionVoiceUnmuteMessage =>
      'ఒక స్వర ఆదేశం అన్‌మ్యూట్ కోరింది. కీ లేదా టచ్‌తో నిర్ధారించండి. తరగతిలోని ఇతరులు మీ మాట వినగలరు.';

  @override
  String get sessionVoiceUnmuteConfirm => 'అన్‌మ్యూట్';

  @override
  String get sessionVoiceUnmuteCancel => 'మ్యూట్‌లోనే ఉండండి';

  @override
  String get sessionAlreadyUnmuted => 'ఇప్పటికే అన్‌మ్యూట్‌లో ఉంది';

  @override
  String get sessionAlreadyMutedSelf => 'ఇప్పటికే మ్యూట్‌లో ఉంది';

  @override
  String get sessionHandAlreadyLowered => 'చేయి ఇప్పటికే దించబడింది';

  @override
  String get sessionHandAlreadyRaised => 'చేయి ఇప్పటికే ఎత్తబడింది';

  @override
  String get sessionCommandNotRecognized => 'ఆదేశం అర్థం కాలేదు';

  @override
  String get sessionVoiceStopUnconfirmed =>
      'స్వర ఆదేశాలు వినడం ఆగినట్లు నిర్ధారించబడలేదు. మళ్లీ ఆపడానికి ప్రయత్నించండి.';

  @override
  String get sessionVoiceStopping => 'స్వర ఆదేశాలు వినడం ఆపుతోంది.';

  @override
  String get sessionVoiceStarting => 'స్వర ఆదేశాలు ప్రారంభిస్తోంది.';

  @override
  String get sessionVoiceFinishing => 'స్వర గుర్తింపు పూర్తి చేస్తోంది.';

  @override
  String get sessionVoiceListening => 'ఒక ఆదేశం కోసం వింటోంది, 12 సెకన్ల వరకు.';

  @override
  String get sessionVoiceIdle =>
      'వినడం లేదు. ప్రారంభించడానికి ఆదేశం కోసం వినండి ఎంచుకోండి.';

  @override
  String get sessionVoiceSpeechNotStopped =>
      'యాప్ స్వరం ఆపలేకపోయాము. వినే ముందు స్వరం ఆపండి ప్రయత్నించండి.';

  @override
  String get sessionVoiceUnavailable =>
      'స్వర ఆదేశాలు అందుబాటులో లేవు. మైక్రోఫోన్ అనుమతి మరియు Android ఇంగ్లీష్ స్పీచ్ సేవలను తనిఖీ చేయండి.';

  @override
  String get sessionVoiceCouldNotStart =>
      'స్వర ఆదేశాలు ప్రారంభం కాలేదు. మైక్రోఫోన్ అనుమతి మరియు ఇంగ్లీష్ స్పీచ్ సేవలను తనిఖీ చేసి, మళ్లీ ప్రయత్నించండి.';

  @override
  String get sessionVoiceCouldNotFinish =>
      'స్వర గుర్తింపు పూర్తి కాలేదు. అనుమతి మరియు ఇంగ్లీష్ స్పీచ్ సేవలను తనిఖీ చేసి, మళ్లీ ప్రయత్నించడానికి వినండి ఎంచుకోండి.';

  @override
  String get sessionVoiceNoCommand =>
      'ఏ ఆదేశం వినిపించలేదు. మళ్లీ ప్రయత్నించడానికి ఆదేశం కోసం వినండి ఎంచుకోండి.';

  @override
  String get sessionVoiceCommandFailed =>
      'స్వర ఆదేశం పూర్తి కాలేదు. దాని కీప్యాడ్ కీ ఉపయోగించండి లేదా మళ్లీ ప్రయత్నించండి.';

  @override
  String get sessionVoiceCannotStop =>
      'స్వర ఆదేశాలు వినడం ఆపలేకపోయాము. వినడం ఆపండి మళ్లీ ప్రయత్నించండి, లేదా తరగతి నుండి వెళ్లి Android మైక్రోఫోన్ సూచికను తనిఖీ చేయండి.';

  @override
  String get sessionRecordingSelectionChanged =>
      'తరగతి రికార్డింగ్ ఎంపిక మారింది. వివరాల కోసం తరగతి అప్‌డేట్‌లు చదవండి ఉపయోగించండి.';

  @override
  String get sessionRecordingSelectionGroup => 'తరగతి రికార్డింగ్ ఎంపిక';

  @override
  String get sessionPlaybackFinished => 'రికార్డింగ్ పూర్తయింది.';

  @override
  String get sessionNoRecording => 'ఏ తరగతి రికార్డింగ్ ఎంచుకోబడలేదు.';

  @override
  String get sessionNoRecordingTeacher =>
      'ఏ తరగతి రికార్డింగ్ ఎంచుకోబడలేదు. రికార్డింగ్ ప్లేయర్‌లో, ఒకటి ఎంచుకోవడానికి 1 నొక్కండి.';

  @override
  String get sessionPreviewFailed =>
      'ప్రైవేట్ ప్రివ్యూ ప్రారంభం కాలేదు. కనెక్షన్ తనిఖీ చేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String sessionClassPauseUnconfirmed(String reason) {
    return 'మీ ఫోన్‌లో ఆడియో పాజ్ అయింది. తరగతి పాజ్ నిర్ధారించబడలేదు. $reason';
  }

  @override
  String sessionSpeed(String speed) {
    return '$speed రెట్లు వేగం';
  }

  @override
  String sessionPlaybackAccepted(String title) {
    return '$title కోసం తరగతి ప్లేబ్యాక్ అభ్యర్థన అంగీకరించబడింది.';
  }

  @override
  String sessionSelected(String title) {
    return '$title తరగతి కోసం ఎంచుకోబడింది. ప్లే చేయడానికి 5 నొక్కండి.';
  }

  @override
  String sessionPreviewing(String title) {
    return '$titleను ఈ ఫోన్‌లో మాత్రమే ప్రివ్యూ చేస్తోంది.';
  }

  @override
  String get sessionPreviewStopped => 'ప్రివ్యూ ఆగింది.';

  @override
  String get sessionRecordingsTitle => 'తరగతి రికార్డింగ్ ప్లేయర్';

  @override
  String get sessionChooseRecording => 'లైబ్రరీ నుండి ఒక రికార్డింగ్ ఎంచుకోండి';

  @override
  String get sessionUploadRecording => 'కొత్త రికార్డింగ్ అప్‌లోడ్ చేయండి';

  @override
  String get sessionHearRecording => 'రికార్డింగ్ స్థితి వినండి';

  @override
  String get sessionPlayPauseClass => 'తరగతి కోసం ప్లే లేదా పాజ్ చేయండి';

  @override
  String get sessionLibraryLoading =>
      'రికార్డింగ్ లైబ్రరీ ఇంకా లోడ్ అవుతోంది. కొద్దిసేపట్లో మళ్లీ ప్రయత్నించండి.';

  @override
  String get sessionLibraryEmpty =>
      'ఈ తరగతికి ఇంకా రికార్డింగ్‌లు లేవు. ఒకటి అప్‌లోడ్ చేయడానికి 2 నొక్కండి.';

  @override
  String get sessionPositionHint =>
      '10 సెకన్లు కదలడానికి ఎడమ మరియు కుడి ఉపయోగించండి';

  @override
  String sessionRecordingStatusPlaying(
    String title,
    String position,
    String speed,
  ) {
    return '$title. తరగతి కోసం ప్లే అవుతోంది. $position. $speed.';
  }

  @override
  String sessionRecordingStatusPaused(
    String title,
    String position,
    String speed,
  ) {
    return '$title. పాజ్ అయింది. $position. $speed.';
  }

  @override
  String sessionPositionLabel(String position) {
    return 'స్థానం $position. 10 సెకన్లు కదలడానికి ఎడమ మరియు కుడి ఉపయోగించండి';
  }

  @override
  String get sessionUntitled => 'పేరు లేదు';

  @override
  String get sessionFileSelectedForClass => 'తరగతి కోసం ఎంచుకోబడింది';

  @override
  String get sessionFilePreviewing => 'ప్రివ్యూ అవుతోంది';

  @override
  String get sessionPlayForClass => 'ఎంచుకుని ఇప్పుడే తరగతి కోసం ప్లే చేయండి';

  @override
  String get sessionSelectOnly => 'ఎంచుకోండి మాత్రమే, తర్వాత 5తో ప్లే చేయండి';

  @override
  String get sessionPreviewPrivately => 'ఈ ఫోన్‌లో ప్రైవేట్‌గా ప్రివ్యూ చేయండి';

  @override
  String get sessionStopPreview => 'ప్రైవేట్ ప్రివ్యూ ఆపండి';

  @override
  String get sessionUploadDetailsTitle => 'ఆడియో అప్‌లోడ్ వివరాలు';

  @override
  String get sessionUploadTitle => 'ఆడియో అప్‌లోడ్';

  @override
  String sessionUploadFile(String name) {
    return 'ఫైల్: $name';
  }

  @override
  String get sessionTitleField => 'ఆడియో శీర్షిక, తప్పనిసరి';

  @override
  String get sessionDescriptionField => 'ఆడియో వివరణ, ఐచ్ఛికం';

  @override
  String get sessionCancelUpload => 'అప్‌లోడ్ రద్దు చేయండి';

  @override
  String get sessionConfirmUpload => 'ఆడియో అప్‌లోడ్ చేయండి';

  @override
  String get sessionTitleRequired => 'శీర్షిక తప్పనిసరి';

  @override
  String get sessionChooseSessionsTitle => 'ఈ ఆడియో కోసం తరగతులు ఎంచుకోండి';

  @override
  String get sessionAddToSessions => 'తరగతులకు ఆడియో జోడించండి';

  @override
  String get sessionConfirmSessions => 'ఎంచుకున్న తరగతులను నిర్ధారించండి';

  @override
  String get sessionSelectAtLeastOne => 'కనీసం ఒక తరగతి ఎంచుకోండి';

  @override
  String get sessionSessionSelected => 'తరగతి ఎంచుకోబడింది';

  @override
  String get sessionSessionUnselected => 'తరగతి ఎంపిక తీసివేయబడింది';

  @override
  String sessionChoiceSelected(String title) {
    return 'ఎంచుకోబడింది, $title';
  }

  @override
  String sessionChoiceNotSelected(String title) {
    return 'ఎంచుకోబడలేదు, $title';
  }

  @override
  String sessionClassNumbered(String number) {
    return 'తరగతి $number';
  }

  @override
  String get sessionUploadContextMissing =>
      'ఈ తరగతి యొక్క తరగతి మరియు సబ్జెక్టు గుర్తించలేకపోయాము.';

  @override
  String get sessionUploadSuccess => 'అప్‌లోడ్ విజయవంతమైంది.';

  @override
  String get sessionUploadInProgress => 'ఆడియో అప్‌లోడ్ జరుగుతోంది';

  @override
  String get sessionPlayNowTitle => 'ఇప్పుడే అందరికీ ప్లే చేయాలా?';

  @override
  String sessionPlayNowMessage(String title) {
    return '$title ఎంచుకోబడింది. ఇప్పుడే పాల్గొనే అందరికీ ప్లే చేయాలా?';
  }

  @override
  String get sessionPlayNow => 'ఇప్పుడే ప్లే చేయండి';

  @override
  String get sessionNotYet => 'ఇప్పుడు కాదు';

  @override
  String get sessionUploadEditTitle => 'శీర్షిక మార్చండి';

  @override
  String get sessionUploadEditDescription => 'వివరణ మార్చండి';

  @override
  String get sessionUploadKey => 'అప్‌లోడ్';

  @override
  String get sessionCancel => 'రద్దు';

  @override
  String get classroomCheckUnreadable =>
      'తరగతి తనిఖీ స్థితిని చదవలేకపోయాము. జవాబిచ్చే ముందు రిఫ్రెష్ చేయండి.';

  @override
  String get classroomCheckUnconfirmed =>
      'తరగతి తనిఖీ చర్య నిర్ధారించబడలేదు. మళ్లీ ప్రయత్నించే ముందు రిఫ్రెష్ చేయండి.';

  @override
  String get classroomCheckConfirmationUnreadable =>
      'తరగతి తనిఖీ నిర్ధారణను చదవలేకపోయాము. మళ్లీ ప్రయత్నించే ముందు రిఫ్రెష్ చేయండి.';

  @override
  String get classroomCheckOpenedForYou =>
      'మీ ఉపాధ్యాయులు ఒక ప్రశ్న అడిగారు. జవాబివ్వడానికి 3 నొక్కండి.';

  @override
  String get classroomCheckHelp =>
      'ప్రైవేట్ తరగతి తనిఖీ. అర్థమైంది, దయచేసి మళ్లీ చెప్పండి లేదా సహాయం కావాలి. జవాబిచ్చిన విద్యార్థి మరియు సెషన్ ఉపాధ్యాయులు మాత్రమే జవాబును చదవగలరు. దీనికి మార్కులు ఉండవు. తదుపరి తనిఖీ, సెషన్ ముగింపు లేదా సర్వర్ రీస్టార్ట్ అయినప్పుడు జవాబులు తొలగిపోతాయి. నిర్ధారించబడిన స్థితి కోసం చదవండి లేదా రిఫ్రెష్ ఉపయోగించండి. స్వరం ఆపండి మరియు వెనుకకు అందుబాటులో ఉన్నాయి.';

  @override
  String get classroomCheckTitle => 'తరగతి తనిఖీ';

  @override
  String get classroomCheckNewTitle => 'కొత్త తరగతి తనిఖీ తెరవాలా?';

  @override
  String get classroomCheckNewMessage =>
      'ఇది మునుపటి తనిఖీ జవాబులన్నింటినీ తొలగిస్తుంది. విద్యార్థులు అర్థమైంది, దయచేసి మళ్లీ చెప్పండి లేదా సహాయం కావాలి ఎంచుకుంటారు. మీరు మరియు జవాబిచ్చిన ప్రతి విద్యార్థి మాత్రమే వారి జవాబును చదవగలరు. దీనికి మార్కులు ఉండవు, మరియు ఇది విద్యా రికార్డుగా ఉంచబడదు.';

  @override
  String get classroomCheckNewConfirm => 'మునుపటిది తొలగించి తెరవండి';

  @override
  String get classroomCheckNewCancel => 'ప్రస్తుత తనిఖీ ఉంచండి';

  @override
  String get classroomCheckSending => 'పంపుతోంది. నిర్ధారణ కోసం వేచి ఉంది.';

  @override
  String get classroomCheckWaiting =>
      'నిర్ధారణ కోసం వేచి ఉంది. మళ్లీ పంపవద్దు.';

  @override
  String get sessionBackToClass => 'తరగతికి తిరిగి వెళ్లండి';

  @override
  String get classroomBackToSession => 'సెషన్‌కు తిరిగి వెళ్లండి';

  @override
  String get classroomBack => 'వెనుకకు';

  @override
  String get classroomCheckRead =>
      'తనిఖీ స్థితి మరియు నిర్ధారించబడిన జవాబులు చదవండి';

  @override
  String get classroomCheckReadButton => 'స్థితి మరియు జవాబులు చదవండి';

  @override
  String get classroomCheckRefresh =>
      'ప్రైవేట్ తనిఖీ స్థితిని రిఫ్రెష్ చేయండి. తరగతి కనెక్షన్ అవసరం';

  @override
  String get classroomCheckRefreshButton => 'సర్వర్ నుండి రిఫ్రెష్ చేయండి';

  @override
  String get classroomCheckOpenLabel =>
      'కొత్త తనిఖీ తెరవండి. మునుపటి జవాబులు తొలగించడాన్ని నిర్ధారించండి';

  @override
  String get classroomCheckOpenButton => 'కొత్త తనిఖీ తెరవండి';

  @override
  String get classroomCheckCloseLabel =>
      'ఈ తనిఖీ మూసివేయండి. తదుపరి తనిఖీ లేదా సెషన్ ముగింపు వరకు ప్రస్తుత ఫలితాలు ఉంటాయి';

  @override
  String get classroomCheckCloseButton => 'తనిఖీ మూసివేయండి';

  @override
  String classroomCheckAnswer(String choice) {
    return '$choice. మీ ప్రైవేట్, మార్కులు లేని జవాబును పంపండి లేదా మార్చండి';
  }

  @override
  String get sessionStopSpeech => 'స్వరం ఆపండి';

  @override
  String get classroomChoiceUnderstood => 'అర్థమైంది';

  @override
  String get classroomChoiceRepeat => 'దయచేసి మళ్లీ చెప్పండి';

  @override
  String get classroomChoiceHelp => 'సహాయం కావాలి';

  @override
  String get classroomCheckNone =>
      'చివరగా అందిన తరగతి స్థితిలో ప్రస్తుత తనిఖీ లేదు. తనిఖీ చేయడానికి రిఫ్రెష్ చేయండి.';

  @override
  String get classroomCheckStatusOpen => 'తనిఖీ తెరిచి ఉంది.';

  @override
  String get classroomCheckStatusClosed =>
      'తనిఖీ మూసివేయబడింది. జవాబులు మార్చలేరు.';

  @override
  String get classroomCheckNoResponseYet => 'ఇంకా ఏ జవాబు నిర్ధారించబడలేదు.';

  @override
  String classroomCheckYourResponse(String choice) {
    return 'మీ నిర్ధారించబడిన జవాబు: $choice.';
  }

  @override
  String classroomCheckStudentSummary(String status, String response) {
    return '$status $response మీరు మరియు సెషన్ ఉపాధ్యాయులు మాత్రమే మీ జవాబును చదవగలరు. దీనికి మార్కులు ఉండవు.';
  }

  @override
  String classroomCheckLabelValue(String label, String value) {
    return '$label: $value';
  }

  @override
  String get classroomCheckNoResponses => 'ఇంకా జవాబులు లేవు.';

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
          '$status $count విద్యార్థులు జవాబిచ్చారు. $counts. $named జవాబులు మీకు మరియు జవాబిచ్చిన ప్రతి విద్యార్థికి మాత్రమే కనిపిస్తాయి, ఇవి మార్కులు కావు.',
    );
    return '$_temp0';
  }

  @override
  String get sessionToolsTitle => 'ఉపాధ్యాయుల సాధనాలు';

  @override
  String get sessionInvite => 'విద్యార్థులను ఆహ్వానించండి';

  @override
  String get sessionEndClass => 'అందరికీ తరగతి ముగించండి, నిర్ధారణ అడుగుతుంది';

  @override
  String get sessionPeopleTitle => 'పాల్గొనేవారు మరియు ఎత్తిన చేతులు';

  @override
  String sessionParticipantList(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'పాల్గొనేవారి జాబితా, $count మంది',
      one: 'పాల్గొనేవారి జాబితా, 1 వ్యక్తి',
    );
    return '$_temp0';
  }

  @override
  String get sessionSummaryChoice => 'తరగతి సారాంశం వినండి';

  @override
  String get sessionParticipantsTitle => 'పాల్గొనేవారు';

  @override
  String get sessionMembersTitle => 'తరగతిలోని వ్యక్తులు';

  @override
  String get sessionMembersButton => '7: తరగతిలో ఎవరు ఉన్నారు';

  @override
  String sessionMembersLabel(String people) {
    return 'తరగతిలో ఎవరు ఉన్నారు. $people వివరాలు వినడానికి ఒక వ్యక్తిని ఎంచుకోండి';
  }

  @override
  String get sessionHearDetails => 'వివరాలు వినండి';

  @override
  String sessionMuteParticipant(String name) {
    return '$nameను మ్యూట్ చేయండి';
  }

  @override
  String sessionRemoveParticipant(String name) {
    return '$nameను తరగతి నుండి తొలగించండి, నిర్ధారణ అడుగుతుంది';
  }

  @override
  String get sessionParticipantGone =>
      'ఆ పాల్గొనేవారు తరగతి నుండి వెళ్ళిపోయారు.';

  @override
  String get sessionNoOtherParticipants => 'ఇంకా తరగతిలో వేరే ఎవరూ లేరు.';

  @override
  String sessionTileRemoveMessage(String name) {
    return '$name ఈ తరగతి నుండి తొలగించబడి, వారి డాష్‌బోర్డ్‌కు తిరిగి పంపబడతారు.';
  }

  @override
  String sessionTileRemoveFromSessionMessage(String name) {
    return '$name ఈ సెషన్ నుండి తొలగించబడి, వారి డాష్‌బోర్డ్‌కు తిరిగి పంపబడతారు.';
  }

  @override
  String sessionUnmuteParticipant(String name) {
    return '$nameను అన్‌మ్యూట్ చేయండి';
  }

  @override
  String sessionRemoveFromClass(String name) {
    return '$nameను తరగతి నుండి తొలగించండి';
  }

  @override
  String get sessionConnStateConnecting => 'కనెక్ట్ అవుతోంది';

  @override
  String get sessionConnStateConnected => 'కనెక్ట్ అయింది';

  @override
  String get sessionConnStateInterrupted => 'కనెక్షన్‌కు అంతరాయం కలిగింది';

  @override
  String get sessionConnStateReconnecting => 'మళ్ళీ కనెక్ట్ అవుతోంది';

  @override
  String get sessionConnStateSignInRequired => 'సైన్ ఇన్ అవసరం';

  @override
  String get sessionConnStateUnavailable => 'తరగతి అందుబాటులో లేదు';

  @override
  String get sessionConnStateEnded => 'తరగతి ముగిసింది';

  @override
  String get sessionConnStateDisconnected => 'కనెక్షన్ తెగిపోయింది';

  @override
  String get sessionReconnectingToClass => 'తరగతికి మళ్ళీ కనెక్ట్ అవుతోంది.';

  @override
  String get sessionSignInRequiredLeave =>
      'సైన్ ఇన్ అవసరం. సెషన్ నుండి బయటకు వెళ్ళి మళ్ళీ సైన్ ఇన్ చేయండి.';

  @override
  String get sessionSignInExpiredLeave =>
      'సైన్ ఇన్ గడువు ముగిసింది. సెషన్ నుండి బయటకు వెళ్ళి మళ్ళీ సైన్ ఇన్ చేయండి.';

  @override
  String get sessionClassNoLongerAvailable =>
      'ఈ తరగతి ఇకపై మీ ఖాతాకు అందుబాటులో లేదు. మీరు వెనక్కి వెళ్ళవచ్చు.';

  @override
  String get sessionServiceUnavailable => 'తరగతి సేవ అందుబాటులో లేదు.';

  @override
  String get sessionConnectionUnreadable =>
      'తరగతి కనెక్షన్ స్పందనను చదవలేకపోయాము.';

  @override
  String get sessionConnectionNotConfirmed =>
      'తరగతి కనెక్షన్‌ను నిర్ధారించలేదు.';

  @override
  String get sessionConnectionInterrupted =>
      'తరగతి కనెక్షన్‌కు అంతరాయం కలిగింది.';

  @override
  String get sessionConnectionClosed => 'తరగతి కనెక్షన్ మూసివేయబడింది.';

  @override
  String get sessionConnectionCouldNotConfirm =>
      'తరగతి కనెక్షన్‌ను నిర్ధారించలేకపోయాము.';

  @override
  String get sessionNoUpdates => 'తరగతి నుండి ఎలాంటి అప్‌డేట్‌లు అందలేదు.';

  @override
  String get sessionUpdateUnreadable => 'ఒక తరగతి అప్‌డేట్‌ను చదవలేకపోయాము.';

  @override
  String get sessionUpdateUnexpectedFormat =>
      'ఒక తరగతి అప్‌డేట్ ఊహించని రూపంలో ఉంది.';

  @override
  String get sessionUpdateTypeUnreadable =>
      'ఒక తరగతి అప్‌డేట్ రకాన్ని చదవలేకపోయాము.';

  @override
  String get sessionParticipationNotConfirmed =>
      'తరగతిలో మీ పాల్గొనడం నిర్ధారించబడలేదు.';

  @override
  String get sessionConnectedToClass => 'తరగతికి కనెక్ట్ అయింది.';

  @override
  String get sessionSignInChangedShort =>
      'మీ సైన్ ఇన్ మారింది. మళ్ళీ సైన్ ఇన్ చేయండి.';

  @override
  String get sessionRemovedGoBack =>
      'మిమ్మల్ని తరగతి నుండి తొలగించారు. మీరు వెనక్కి వెళ్ళవచ్చు.';

  @override
  String sessionConnectionLostReconnecting(String reason) {
    return '$reason మళ్ళీ కనెక్ట్ అవుతోంది. మునుపటి చర్యలు ఆటోమేటిక్‌గా మళ్ళీ పంపబడవు.';
  }

  @override
  String get sessionActionClassUnavailable =>
      'తరగతి అందుబాటులో లేదు. ఈ చర్య పంపబడలేదు.';

  @override
  String get sessionActionSessionChanged => 'సెషన్ మారింది. ఈ చర్య పంపబడలేదు.';

  @override
  String get sessionActionSignInRequired => 'సైన్ ఇన్ అవసరం. ఈ చర్య పంపబడలేదు.';

  @override
  String get sessionActionConnectionChanged =>
      'నిర్ధారణకు ముందే కనెక్షన్ మారింది. చర్య అంది ఉండవచ్చు; మళ్ళీ ప్రయత్నించే ముందు దాని స్థితిని తనిఖీ చేయండి.';

  @override
  String get sessionAccountChangedLeave =>
      'మీ ఖాతా మారింది. సెషన్ నుండి బయటకు వెళ్ళి మళ్ళీ సైన్ ఇన్ చేయండి.';

  @override
  String get sessionActionAccountChanged =>
      'చర్య నిర్ధారించబడక ముందే మీ ఖాతా మారింది.';

  @override
  String get sessionActionNotConfirmedByClass =>
      'తరగతి చర్యను నిర్ధారించలేదు. మళ్ళీ ప్రయత్నించే ముందు దాని స్థితిని తనిఖీ చేయండి.';

  @override
  String get sessionActionMayHaveReached =>
      'చర్య నిర్ధారించబడలేదు. అది తరగతికి చేరి ఉండవచ్చు. మళ్ళీ ప్రయత్నించే ముందు దాని స్థితిని తనిఖీ చేయండి.';

  @override
  String get sessionRtcConnectionClosed => 'కనెక్షన్ మూసివేయబడింది.';

  @override
  String get sessionRtcNetworkError => 'నెట్‌వర్క్ లోపం';

  @override
  String sessionRtcConnected(String id) {
    return 'సెషన్ $idకు కనెక్ట్ అయింది';
  }

  @override
  String sessionRtcParticipantJoined(String id) {
    return 'పాల్గొనేవారు $id చేరారు.';
  }

  @override
  String sessionRtcParticipantLeft(String id) {
    return 'పాల్గొనేవారు $id వెళ్ళిపోయారు.';
  }

  @override
  String sessionRtcParticipantMuted(String id) {
    return 'పాల్గొనేవారు $id ఇప్పుడు మ్యూట్‌లో ఉన్నారు';
  }

  @override
  String sessionRtcParticipantUnmuted(String id) {
    return 'పాల్గొనేవారు $id ఇప్పుడు అన్‌మ్యూట్‌లో ఉన్నారు';
  }

  @override
  String sessionRtcMessage(String text) {
    return 'సందేశం: $text';
  }

  @override
  String sessionRtcTeacherPlaying(String id) {
    return 'ఉపాధ్యాయులు ఆడియో $id ప్లే చేయడం ప్రారంభించారు';
  }

  @override
  String sessionRtcAudioStarted(String id) {
    return 'పాల్గొనేవారు $id కోసం ఆడియో స్ట్రీమ్ ప్రారంభమైంది';
  }

  @override
  String librarySpeedTimes(String speed) {
    return '$speed రెట్లు';
  }

  @override
  String get libraryNoClassForSession => 'ఈ సెషన్ పేరుతో తరగతి ఏదీ కనబడలేదు.';

  @override
  String librarySubjectFilterLabel(String name) {
    return 'సబ్జెక్టు ఫిల్టర్: $name. మార్చడానికి కీ 2 లేదా ఎడమ, కుడి నొక్కండి';
  }

  @override
  String librarySubjectFilterLabelPosition(
    String name,
    String index,
    String total,
  ) {
    return 'సబ్జెక్టు ఫిల్టర్: $name, $totalలో $index. మార్చడానికి కీ 2 లేదా ఎడమ, కుడి నొక్కండి';
  }

  @override
  String get libraryAllSubjects => 'అన్ని సబ్జెక్టులు';

  @override
  String libraryRestoredToPlaylist(String title) {
    return '$title మళ్ళీ ప్లేలిస్ట్‌లో ఉంది.';
  }

  @override
  String get librarySizeZero => '0 మెగాబైట్‌లు';

  @override
  String get librarySizeTiny => '0.1 మెగాబైట్‌ల కంటే తక్కువ';

  @override
  String get librarySizeOne => '1 మెగాబైట్';

  @override
  String librarySizeMegabytes(String value) {
    return '$value మెగాబైట్‌లు';
  }

  @override
  String libraryStorageUsed(String size, String limit) {
    return '$limitలో $size వాడబడింది.';
  }

  @override
  String libraryRecordingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count రికార్డింగ్‌లు',
      one: '1 రికార్డింగ్',
    );
    return '$_temp0';
  }

  @override
  String libraryPlayingBrief(String title, String position) {
    return '$title, $position నుండి ప్లే అవుతోంది.';
  }

  @override
  String libraryPlayingDetailed(String title, String position, String speed) {
    return '$title, $position నుండి ప్లే అవుతోంది, వేగం $speed.';
  }

  @override
  String libraryPausedAt(String position) {
    return '$position వద్ద పాజ్ చేయబడింది.';
  }

  @override
  String get libraryPlayerStateNothing => 'ఏదీ ప్లే కావడం లేదు.';

  @override
  String libraryPlayerStatePlaying(
    String title,
    String position,
    String speed,
  ) {
    return '$title ప్లే అవుతోంది, $position, వేగం $speed.';
  }

  @override
  String libraryPlayerStatePaused(String title, String position, String speed) {
    return '$title పాజ్ చేయబడింది, $position, వేగం $speed.';
  }

  @override
  String librarySpeedChanged(String speed) {
    return 'వేగం $speed.';
  }

  @override
  String get librarySlowest => 'ఇప్పటికే అతి తక్కువ వేగంలో ఉంది.';

  @override
  String get libraryFastest => 'ఇప్పటికే అతి ఎక్కువ వేగంలో ఉంది.';

  @override
  String get libraryNoLessonLoaded =>
      'ఏ పాఠం లోడ్ కాలేదు. ముందుగా ప్లే చేయడానికి ఒక పాఠాన్ని ఎంచుకోండి.';

  @override
  String libraryNoLessonPlayingPress(String key) {
    return 'ఏ పాఠం ప్లే కావడం లేదు. మొదటి పాఠాన్ని ప్లే చేయడానికి $key నొక్కండి.';
  }

  @override
  String get libraryNothingIsPlaying => 'ఏదీ ప్లే కావడం లేదు.';

  @override
  String get libraryNothingPlayingHint =>
      'ఏదీ ప్లే కావడం లేదు. ఒక పాఠాన్ని ఎంచుకోండి లేదా 5 నొక్కండి.';

  @override
  String libraryStopped(String title) {
    return '$title ఆపివేయబడింది.';
  }

  @override
  String libraryFinished(String title) {
    return '$title పూర్తయింది.';
  }

  @override
  String get libraryWaitForPlayer => 'దయచేసి పాఠం ప్లేయర్ కోసం వేచి ఉండండి.';

  @override
  String get librarySeekFailed =>
      'పాఠంలో ఆ స్థానానికి వెళ్ళలేకపోయాము. మళ్ళీ ప్రయత్నించండి.';

  @override
  String get librarySpeedFailed =>
      'ప్లేబ్యాక్ వేగాన్ని మార్చలేకపోయాము. మళ్ళీ ప్రయత్నించండి.';

  @override
  String libraryPlayFailed(String title) {
    return '$title ప్లే చేయలేకపోయాము. మీ కనెక్షన్‌ను తనిఖీ చేసి, మళ్ళీ ఎంచుకోండి.';
  }

  @override
  String get libraryCheckingOfflineAccess =>
      'ఇంటర్నెట్ అందుబాటులో లేదు. మీరు సేవ్ చేసిన ఆఫ్‌లైన్ యాక్సెస్‌ను తనిఖీ చేస్తోంది.';

  @override
  String get libraryLessonGone =>
      'ఈ పాఠం ఇకపై అందుబాటులో లేదు. మీరు సేవ్ చేసిన పురోగతి మరియు బుక్‌మార్క్‌లు అలాగే ఉంటాయి.';

  @override
  String librarySeekLabel(String position) {
    return 'పాఠం స్థానం $position. 10 సెకన్లు కదలడానికి ఎడమ లేదా కుడి వాడండి.';
  }

  @override
  String libraryRewindLabel(String key) {
    return '10 సెకన్లు వెనక్కి, కీ $key';
  }

  @override
  String libraryForwardLabel(String key) {
    return '10 సెకన్లు ముందుకు, కీ $key';
  }

  @override
  String librarySlowerLabel(String key, String speed) {
    return 'నెమ్మదిగా, కీ $key. ఇప్పుడు $speed';
  }

  @override
  String libraryFasterLabel(String key, String speed) {
    return 'వేగంగా, కీ $key. ఇప్పుడు $speed';
  }

  @override
  String libraryPauseLabel(String title, String key) {
    return '$title పాజ్ చేయండి, కీ $key';
  }

  @override
  String libraryPlayLabel(String title, String key) {
    return '$title ప్లే చేయండి, కీ $key';
  }

  @override
  String libraryResumeLabel(String title, String key) {
    return '$title కొనసాగించండి, కీ $key';
  }

  @override
  String libraryStopLabel(String title, String key) {
    return '$title ఆపండి, కీ $key';
  }

  @override
  String libraryPlayerKeyHelp(
    String rewind,
    String playPause,
    String forward,
    String slower,
    String faster,
  ) {
    return '10 సెకన్లు వెనక్కి వెళ్ళడానికి $rewind, ప్లే లేదా పాజ్ చేయడానికి $playPause, 10 సెకన్లు ముందుకు వెళ్ళడానికి $forward, నెమ్మదిగా చేయడానికి $slower, వేగంగా చేయడానికి $faster నొక్కండి.';
  }

  @override
  String libraryBookmarkCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count బుక్‌మార్క్‌లు',
      one: '1 బుక్‌మార్క్',
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
    return '$title. స్థానం $position. వేగం $speed. $bookmarks. A-B రిపీట్ $repeat. పురోగతి సేవ్ చేయడం $saving.';
  }

  @override
  String libraryReadStatusLabel(String status) {
    return 'అభ్యాస స్థితిని చదవండి. $status';
  }

  @override
  String libraryAddBookmarkLabel(String time) {
    return '$time వద్ద బుక్‌మార్క్ జోడించండి';
  }

  @override
  String libraryBookmarksLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'బుక్‌మార్క్‌లు. $count సేవ్ చేసిన స్థానాలు',
      one: 'బుక్‌మార్క్‌లు. 1 సేవ్ చేసిన స్థానం',
    );
    return '$_temp0';
  }

  @override
  String libraryNotesLabel(String time) {
    return '$time వద్ద ప్రైవేట్ చదువు నోట్స్. తెరిచే ముందు పాఠాన్ని పాజ్ చేస్తుంది';
  }

  @override
  String get libraryRepeatStartLabel =>
      'ప్రస్తుత స్థానంలో రిపీట్ ప్రారంభం A సెట్ చేయండి';

  @override
  String get libraryRepeatEndLabel =>
      'ప్రారంభం A తర్వాత రిపీట్ ముగింపు B సెట్ చేయండి';

  @override
  String get libraryRepeatTurnOffLabel => 'A-B రిపీట్ ఆఫ్ చేయండి';

  @override
  String get libraryRepeatTurnOnLabel => 'A-B రిపీట్ ఆన్ చేయండి';

  @override
  String get libraryRepeatClearLabel =>
      'సేవ్ చేసిన A-B రిపీట్ స్థానాలను తొలగించండి';

  @override
  String libraryRetryLabel(String issue) {
    return 'అభ్యాస పురోగతిని సేవ్ చేయడానికి మళ్ళీ ప్రయత్నించండి. $issue';
  }

  @override
  String libraryBookmarkSaved(String time) {
    return '$time వద్ద బుక్‌మార్క్ సేవ్ చేయబడింది.';
  }

  @override
  String libraryRepeatStartSet(String time) {
    return 'రిపీట్ ప్రారంభం $time వద్ద సెట్ చేయబడింది.';
  }

  @override
  String libraryRepeatEndSetBrief(String time) {
    return 'రిపీట్ ముగింపు $time వద్ద సెట్ చేయబడింది.';
  }

  @override
  String libraryRepeatEndSetDetailed(String time) {
    return 'రిపీట్ ముగింపు $time వద్ద సెట్ చేయబడింది. మళ్ళీ మళ్ళీ ప్లే చేయడానికి రిపీట్ ఆన్ ఎంచుకోండి.';
  }

  @override
  String libraryRepeatState(String state) {
    return 'A-B రిపీట్ $state.';
  }

  @override
  String get libraryRepeatCleared => 'A-B రిపీట్ స్థానాలు తొలగించబడ్డాయి.';

  @override
  String get libraryProgressSaved => 'అభ్యాస పురోగతి సేవ్ చేయబడింది.';

  @override
  String get libraryActionFailed =>
      'ప్లేయర్ ఈ చర్యను పూర్తి చేయలేకపోయింది. ప్లేబ్యాక్‌ను తనిఖీ చేసి మళ్ళీ ప్రయత్నించండి.';

  @override
  String get libraryCheckPosition =>
      'పాఠం స్థానాన్ని తనిఖీ చేసి మళ్ళీ ప్రయత్నించండి.';

  @override
  String get libraryProgressUnavailableTitle =>
      'సేవ్ చేసిన పురోగతి అందుబాటులో లేదు';

  @override
  String libraryProgressUnavailable(String reason) {
    return '$reason సేవ్ చేసిన డేటాను మార్చకుండా మొదటి నుండి వినాలా? మీరు మళ్ళీ విజయవంతంగా ప్రయత్నించే వరకు సేవ్ చేయడం ఆఫ్‌లోనే ఉంటుంది.';
  }

  @override
  String get libraryListenFromBeginning => 'మొదటి నుండి వినండి';

  @override
  String get libraryBookmarkNameScreen =>
      'బుక్‌మార్క్‌కు పేరు పెట్టండి. మార్చడానికి ఓకే నొక్కండి. పైకి లేదా కిందికి నొక్కితే ఎడిటింగ్ నుండి బయటకు వస్తారు.';

  @override
  String get libraryEnterBookmarkName => 'బుక్‌మార్క్ పేరు నమోదు చేయండి.';

  @override
  String libraryBookmarkLabel(String label, String time) {
    return '$label. $time. బుక్‌మార్క్‌కు వెళ్ళండి';
  }

  @override
  String libraryBookmarkJumped(String label, String time) {
    return '$label. స్థానం $time.';
  }

  @override
  String libraryRemoveBookmarkLabel(String label) {
    return '$label తొలగించండి';
  }

  @override
  String libraryRemoveBookmarkQuestion(String label) {
    return '$label తొలగించాలా? ఇది పాఠాన్ని లేదా ఇతర బుక్‌మార్క్‌లను తొలగించదు.';
  }

  @override
  String libraryBookmarkRemoved(String label) {
    return '$label తొలగించబడింది.';
  }

  @override
  String get libraryBookmarksScreen =>
      'బుక్‌మార్క్‌లు. వెళ్ళడానికి ఒక స్థానాన్ని ఎంచుకోండి. ఇది పాజ్ చేసిన ప్లేబ్యాక్‌ను ప్రారంభించదు. తొలగించే ముందు నిర్ధారణ అడుగుతుంది.';

  @override
  String get libraryNoRecordingsUpload =>
      'ఇంకా రికార్డింగ్‌లు లేవు. ఆడియో అప్‌లోడ్ చేయడానికి 2 నొక్కండి.';

  @override
  String libraryRecordingsLoaded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count రికార్డింగ్‌లు లోడ్ అయ్యాయి.',
      one: '1 రికార్డింగ్ లోడ్ అయింది.',
    );
    return '$_temp0';
  }

  @override
  String get libraryLoadFailed =>
      'రికార్డింగ్‌లను లోడ్ చేయలేకపోయాము. మీ ఇంటర్నెట్ కనెక్షన్‌ను తనిఖీ చేసి, మళ్ళీ ప్రయత్నించడానికి 1 నొక్కండి.';

  @override
  String get libraryTitleRequired => 'శీర్షిక అవసరం.';

  @override
  String get libraryPickFailed =>
      'ఫైల్‌ను తెరవలేకపోయాము. దాన్ని మళ్ళీ ఎంచుకుని చూడండి.';

  @override
  String get libraryChooseWorkspaceFirst =>
      'ఆడియో అప్‌లోడ్ చేసే ముందు ఉపాధ్యాయుల డాష్‌బోర్డ్‌లో ఒక తరగతి మరియు సబ్జెక్టు వర్క్‌స్పేస్ ఎంచుకోండి.';

  @override
  String libraryUploadingBrief(String title) {
    return '$title అప్‌లోడ్ అవుతోంది.';
  }

  @override
  String libraryUploadingDetailed(String title) {
    return '$title అప్‌లోడ్ అవుతోంది. ప్రతి 25 శాతానికి మీకు పురోగతి వినిపిస్తుంది.';
  }

  @override
  String libraryUploadingOnceDetailed(String title) {
    return '$title అప్‌లోడ్ అవుతోంది. దయచేసి వేచి ఉండండి; పూర్తయినప్పుడు మీకు వినిపిస్తుంది.';
  }

  @override
  String libraryUploadProgress(String title, String percent) {
    return '$title: $percent అప్‌లోడ్ అయింది.';
  }

  @override
  String libraryUploaded(String title) {
    return '$title అప్‌లోడ్ అయింది.';
  }

  @override
  String libraryUploadFailed(String title) {
    return '$title అప్‌లోడ్ కాలేదు. మీ కనెక్షన్‌ను తనిఖీ చేసి, మళ్ళీ ప్రయత్నించడానికి 3 నొక్కండి.';
  }

  @override
  String get libraryUploadNoSession =>
      'అప్‌లోడ్ రద్దు చేయబడింది. కనీసం ఒక సెషన్ ఎంచుకుని, మళ్ళీ ఆడియో జోడించడానికి 3 నొక్కండి.';

  @override
  String get libraryUploadNoClass =>
      'సెషన్ తరగతి మరియు సబ్జెక్టును నిర్ణయించలేకపోయాము.';

  @override
  String get libraryFileUnreadable =>
      'ఫైల్‌ను చదవలేకపోయాము. దాన్ని మళ్ళీ ఎంచుకోండి.';

  @override
  String libraryPreviewStopped(String title) {
    return '$title ప్రివ్యూ ఆపివేయబడింది.';
  }

  @override
  String libraryPreviewing(String title) {
    return '$title ప్రైవేట్‌గా ప్రివ్యూ అవుతోంది.';
  }

  @override
  String get libraryPreviewFinished => 'ప్రివ్యూ పూర్తయింది.';

  @override
  String libraryPreviewFailed(String title) {
    return '$title ప్లే చేయలేకపోయాము. మీ కనెక్షన్‌ను తనిఖీ చేసి మళ్ళీ ప్రయత్నించండి.';
  }

  @override
  String get libraryNoActiveSession => 'యాక్టివ్ సెషన్ ఏదీ లేదు.';

  @override
  String librarySelectedForSession(String title) {
    return 'సెషన్ కోసం $title ఎంచుకోబడింది.';
  }

  @override
  String get librarySelectFailed =>
      'ఆడియోను ఎంచుకోలేకపోయాము. మళ్ళీ ప్రయత్నించండి.';

  @override
  String get libraryClassPlayAccepted =>
      'తరగతి ప్లేబ్యాక్ అభ్యర్థన అంగీకరించబడింది.';

  @override
  String get libraryClassPlayFailed =>
      'తరగతి ప్లేబ్యాక్ ప్రారంభించలేకపోయాము. మళ్ళీ ప్రయత్నించండి.';

  @override
  String get libraryClassPauseAccepted =>
      'తరగతి పాజ్ అభ్యర్థన అంగీకరించబడింది.';

  @override
  String get libraryClassPauseFailed =>
      'తరగతి ఆడియోను పాజ్ చేయలేకపోయాము. మళ్ళీ ప్రయత్నించండి.';

  @override
  String libraryStopPreviewLabel(String title) {
    return '$title ప్రైవేట్ ప్రివ్యూ ఆపండి. ఇది మీకు మాత్రమే వినిపిస్తుంది.';
  }

  @override
  String libraryPreviewLabel(String title) {
    return '$title ప్రైవేట్‌గా ప్రివ్యూ చేయండి. ఇది మీకు మాత్రమే వినిపిస్తుంది.';
  }

  @override
  String libraryBroadcastLabel(String title) {
    return 'సెషన్‌లోని అందరి కోసం $title ప్లే చేయండి';
  }

  @override
  String libraryRecordingsSentence(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count రికార్డింగ్‌లు.',
      one: '1 రికార్డింగ్.',
    );
    return '$_temp0';
  }

  @override
  String libraryPreviewingState(String title) {
    return '$title ప్రివ్యూ అవుతోంది.';
  }

  @override
  String get libraryUploadInProgress => 'అప్‌లోడ్ జరుగుతోంది.';

  @override
  String get libraryAccountChanged =>
      'మీ ఖాతా మారింది. లైబ్రరీని మళ్ళీ తెరవండి.';

  @override
  String get libraryNoUnfinished =>
      'ఈ ఖాతాకు పూర్తి కాని పాఠం ఏదీ సేవ్ కాలేదు. నేర్చుకోవడం ప్రారంభించడానికి ఒక రికార్డ్ చేసిన పాఠాన్ని ఎంచుకోండి.';

  @override
  String get libraryCannotCheckAccess =>
      'పాఠం యాక్సెస్‌ను తనిఖీ చేయలేకపోయాము. ఇంటర్నెట్‌కు కనెక్ట్ అయి మళ్ళీ ప్రయత్నించండి. మీరు సేవ్ చేసిన పురోగతి అలాగే ఉంటుంది.';

  @override
  String get libraryUnfinishedUnavailable =>
      'మీ పూర్తి కాని పాఠాలు ప్రస్తుతం ఈ లైబ్రరీలో అందుబాటులో లేవు. మీరు సేవ్ చేసిన పురోగతి మరియు బుక్‌మార్క్‌లు అలాగే ఉంటాయి.';

  @override
  String get libraryOpeningNextUnfinished =>
      'ఇటీవలి పాఠం ఇక్కడ అందుబాటులో లేదు. అందుబాటులో ఉన్న తదుపరి ఇటీవలి పూర్తి కాని పాఠాన్ని తెరుస్తోంది. సేవ్ చేసిన పురోగతి అలాగే ఉంటుంది.';

  @override
  String get libraryContinueFailed =>
      'సేవ్ చేసిన అభ్యాస పురోగతిని తెరవలేకపోయాము. స్టోరేజ్, మీ కనెక్షన్ మరియు సైన్ ఇన్‌ను తనిఖీ చేసి, మళ్ళీ ప్రయత్నించండి.';

  @override
  String get libraryNoActiveClassesNow =>
      'ప్రస్తుతం యాక్టివ్ తరగతులు లేవు. అన్ని ఆడియో ఫైల్‌ల కోసం 3 నొక్కండి.';

  @override
  String libraryClassesLoaded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count యాక్టివ్ తరగతులు లోడ్ అయ్యాయి.',
      one: '1 యాక్టివ్ తరగతి లోడ్ అయింది.',
    );
    return '$_temp0';
  }

  @override
  String libraryClassesFailed(String reason) {
    return '$reason యాక్టివ్ తరగతులను రిఫ్రెష్ చేయలేకపోయాము. మళ్ళీ ప్రయత్నించడానికి 1 నొక్కండి. సేవ్ చేసిన డౌన్‌లోడ్‌లు అందుబాటులోనే ఉంటాయి.';
  }

  @override
  String get libraryClassesLoading =>
      'తరగతులు ఇంకా లోడ్ అవుతున్నాయి. కొద్దిసేపటిలో మళ్ళీ కీ 5 నొక్కండి.';

  @override
  String get libraryNoActiveClassesStaying =>
      'యాక్టివ్ తరగతులు ఏవీ లేవు. ఆడియో లైబ్రరీలోనే ఉంటున్నాము.';

  @override
  String libraryFirstActiveClass(String title) {
    return '$title. మొదటి యాక్టివ్ తరగతి. యాక్టివ్ తరగతి సెషన్‌లను చూడటానికి D-pad పైకి, కిందికి ఉపయోగించండి. ఎంచుకున్న తరగతి రికార్డింగ్‌లను తెరవడానికి ఓకే నొక్కండి.';
  }

  @override
  String get libraryOpeningPlaylists =>
      'నా ప్లేలిస్ట్‌లు తెరుస్తోంది. ప్లేలిస్ట్‌లలోని విషయాలు ప్రైవేట్‌గా ఉంటాయి.';

  @override
  String libraryClassLabel(String title, String index, String count) {
    return '$title. $count లో తరగతి $index';
  }

  @override
  String get libraryLoadingActiveClasses =>
      'యాక్టివ్ తరగతులు లోడ్ అవుతున్నాయి.';

  @override
  String libraryActiveClassesSentence(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count యాక్టివ్ తరగతులు.',
      one: '1 యాక్టివ్ తరగతి.',
    );
    return '$_temp0';
  }

  @override
  String libraryNoRecordingsFor(String where) {
    return '$where కోసం ఇంకా రికార్డింగ్‌లు లేవు.';
  }

  @override
  String libraryRecordingsLoadedFor(int count, String where) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$where కోసం $count రికార్డింగ్‌లు లోడ్ అయ్యాయి.',
      one: '$where కోసం 1 రికార్డింగ్ లోడ్ అయింది.',
    );
    return '$_temp0';
  }

  @override
  String get libraryDownloadsReadFailed =>
      'డౌన్‌లోడ్ చేసిన పాఠాలను చదవలేకపోయాము. మళ్ళీ ప్రయత్నించడానికి 1 నొక్కండి.';

  @override
  String get libraryClassLoadFailed =>
      'రికార్డింగ్‌లను లోడ్ చేయలేకపోయాము. మీ ఇంటర్నెట్ కనెక్షన్, సైన్ ఇన్ చూసుకుని, మళ్ళీ ప్రయత్నించడానికి 1 నొక్కండి.';

  @override
  String libraryRetryAfter(String reason) {
    return '$reason మళ్ళీ ప్రయత్నించడానికి 1 నొక్కండి.';
  }

  @override
  String get libraryDownloadedDescription =>
      'డౌన్‌లోడ్ చేసిన రికార్డింగ్. 30 రోజుల తర్వాత యాక్సెస్‌ను రెన్యూ చేయాలి.';

  @override
  String get libraryDownloadedHelp =>
      'డౌన్‌లోడ్ చేసిన పాఠాలు. ప్లే చేసే ముందు ఉన్న ఆఫ్‌లైన్ యాక్సెస్ తనిఖీ చేయబడుతుంది.';

  @override
  String get libraryOnlineHelp =>
      'ఆడియో లైబ్రరీ. ఆన్‌లైన్ రికార్డింగ్‌లకు ఇంటర్నెట్ కావాలి. ఆఫ్‌లైన్‌లో వినడానికి పాఠాలను డౌన్‌లోడ్ చేయండి.';

  @override
  String librarySubjectChoice(String name, String index, String count) {
    return 'సబ్జెక్టు: $name, $count లో $index';
  }

  @override
  String librarySubjectLabel(String choice) {
    return '$choice. మార్చడానికి 2 నొక్కండి, లేదా ఎడమ, కుడి నొక్కండి';
  }

  @override
  String get librarySubjectFixed =>
      'ఈ లైబ్రరీ ఇప్పటికే ఒక సబ్జెక్టుకు మాత్రమే పరిమితం చేయబడింది.';

  @override
  String libraryLength(String time) {
    return 'నిడివి $time';
  }

  @override
  String libraryRecordingsInSubject(int count, String subject) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$subject లో $count రికార్డింగ్‌లు.',
      one: '$subject లో 1 రికార్డింగ్.',
    );
    return '$_temp0';
  }

  @override
  String libraryNoTeacherPlaylists(String className, String subject) {
    return '$className, $subject కోసం ఇంకా ప్లేలిస్ట్‌లు లేవు. ఒకటి సృష్టించడానికి 2 నొక్కండి.';
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
      other: '$className, $subject కోసం $count ప్లేలిస్ట్‌లు లోడ్ అయ్యాయి.',
      one: '$className, $subject కోసం 1 ప్లేలిస్ట్ లోడ్ అయింది.',
    );
    return '$_temp0';
  }

  @override
  String get libraryPlaylistCreateFailed => 'ప్లేలిస్ట్ సృష్టించలేకపోయాము.';

  @override
  String get libraryNoMyPlaylists =>
      'ఇంకా ప్లేలిస్ట్‌లు లేవు. ప్రైవేట్ ప్లేలిస్ట్ సృష్టించడానికి 2 నొక్కండి.';

  @override
  String libraryPrivatePlaylistCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ప్రైవేట్ ప్లేలిస్ట్‌లు',
      one: '1 ప్రైవేట్ ప్లేలిస్ట్',
    );
    return '$_temp0';
  }

  @override
  String libraryClassPlaylistCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count తరగతి ప్లేలిస్ట్‌లు',
      one: '1 తరగతి ప్లేలిస్ట్',
    );
    return '$_temp0';
  }

  @override
  String libraryMyPlaylistsLoaded(
    String privatePlaylists,
    String classPlaylists,
  ) {
    return '$privatePlaylists, $classPlaylists లోడ్ అయ్యాయి.';
  }

  @override
  String get libraryPrivatePlaylistCreateFailed =>
      'ప్రైవేట్ ప్లేలిస్ట్ సృష్టించలేకపోయాము.';

  @override
  String libraryPlaylistsSentence(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ప్లేలిస్ట్‌లు.',
      one: '1 ప్లేలిస్ట్.',
    );
    return '$_temp0';
  }

  @override
  String libraryItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count అంశాలు',
      one: '1 అంశం',
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
      'ఈ ప్లేలిస్ట్‌ను రిఫ్రెష్ చేయలేకపోయాము. మీ కనెక్షన్ చూసుకుని మళ్ళీ ప్రయత్నించండి. ప్రస్తుతం ప్లే అవుతున్నది, సేవ్ చేసిన ప్రోగ్రెస్ మార్చబడలేదు.';

  @override
  String get libraryPlaylistLessonGone =>
      'ప్రస్తుత పాఠం ఇప్పుడు ఈ ప్లేలిస్ట్‌లో అందుబాటులో లేదు. ప్లేబ్యాక్ ఆగిపోయింది. మీ సేవ్ చేసిన ప్రోగ్రెస్, బుక్‌మార్క్‌లు ఉంచబడ్డాయి.';

  @override
  String get libraryNothingToAdd =>
      'జోడించడానికి తగిన ఆడియో ఏదీ అందుబాటులో లేదు.';

  @override
  String libraryAddedToPlaylist(String title) {
    return '$title ప్లేలిస్ట్‌కు జోడించబడింది.';
  }

  @override
  String get libraryAddFailed =>
      'ఆడియోను జోడించలేకపోయాము. మీ కనెక్షన్ చూసుకుని మళ్ళీ ప్రయత్నించండి.';

  @override
  String libraryItemUnavailable(String title) {
    return '$title ఇప్పుడు మీ ప్రస్తుత తరగతిలో అందుబాటులో లేదు. మీరు దీన్ని ఈ ప్లేలిస్ట్ నుండి తీసివేయవచ్చు.';
  }

  @override
  String libraryItemCannotPlay(String title) {
    return '$title అందుబాటులో లేదు.';
  }

  @override
  String libraryPlayingItem(String announcement, String index, String count) {
    return '$announcement $count లో అంశం $index.';
  }

  @override
  String get libraryPlaylistPlayFailed =>
      'ఈ పాఠాన్ని ప్లే చేయలేకపోయాము. మీ కనెక్షన్ చూసుకుని మళ్ళీ ప్రయత్నించండి.';

  @override
  String get libraryPlaylistEmpty => 'ప్లేలిస్ట్ ఖాళీగా ఉంది.';

  @override
  String get libraryPlaylistEnded =>
      'ప్లేలిస్ట్ ముగిసింది. ప్లేబ్యాక్ ఆగిపోయింది.';

  @override
  String libraryRenamed(String title) {
    return 'ప్లేలిస్ట్ పేరు $title గా మార్చబడింది.';
  }

  @override
  String get libraryRenameFailed =>
      'ప్లేలిస్ట్ పేరు మార్చలేకపోయాము. మీ కనెక్షన్ చూసుకుని మళ్ళీ ప్రయత్నించండి.';

  @override
  String get libraryAlreadyFirst => 'ఎంచుకున్న అంశం ఇప్పటికే మొదటిది.';

  @override
  String get libraryAlreadyLast => 'ఎంచుకున్న అంశం ఇప్పటికే చివరిది.';

  @override
  String libraryMoved(String title, String position, String count) {
    return '$title ను $count లో $position స్థానానికి జరిపాము.';
  }

  @override
  String libraryMoveFailed(String title) {
    return '$title ను జరపలేకపోయాము. మీ కనెక్షన్ చూసుకుని మళ్ళీ ప్రయత్నించండి.';
  }

  @override
  String libraryRemovedFromPlaylist(String title, String playlist) {
    return '$playlist నుండి $title తీసివేయబడింది.';
  }

  @override
  String libraryRemoveFailed(String title) {
    return '$title ను తీసివేయలేకపోయాము. మీ కనెక్షన్ చూసుకుని మళ్ళీ ప్రయత్నించండి.';
  }

  @override
  String libraryRemoveItemQuestion(String title, String playlist) {
    return '$playlist నుండి $title ను తీసివేయాలా? రికార్డింగ్ మాత్రం లైబ్రరీలో ఉంచబడుతుంది.';
  }

  @override
  String libraryRemoveItemLabel(String title) {
    return '$title ను ప్లేలిస్ట్ నుండి తీసివేయండి, నిర్ధారణ అడుగుతుంది';
  }

  @override
  String libraryPublished(String title) {
    return '$title తరగతికి ప్రచురించబడింది.';
  }

  @override
  String libraryReturnedToDraft(String title) {
    return '$title మళ్ళీ డ్రాఫ్ట్‌గా మార్చబడింది.';
  }

  @override
  String libraryChangeFailed(String title) {
    return '$title ను మార్చలేకపోయాము. మీ కనెక్షన్ చూసుకుని మళ్ళీ ప్రయత్నించండి.';
  }

  @override
  String libraryDeleted(String title) {
    return '$title తొలగించబడింది.';
  }

  @override
  String libraryRestoredAsDraft(String title) {
    return '$title డ్రాఫ్ట్‌గా పునరుద్ధరించబడింది.';
  }

  @override
  String libraryArchived(String title) {
    return '$title ఆర్కైవ్ చేయబడింది.';
  }

  @override
  String get libraryPlaylistIsEmpty => 'ప్లేలిస్ట్ ఖాళీగా ఉంది.';

  @override
  String librarySelectedItem(String selected, String items) {
    return '$items లో ఎంచుకున్న అంశం $selected.';
  }

  @override
  String librarySelectedItemTitled(
    String selected,
    String items,
    String title,
  ) {
    return '$items లో ఎంచుకున్న అంశం $selected, $title.';
  }

  @override
  String get libraryAlreadyOneSubject =>
      'ఈ లైబ్రరీ ఇప్పటికే ఒక సబ్జెక్టుకు మాత్రమే పరిమితం చేయబడింది';

  @override
  String get libraryNoLessonIsPlaying => 'ఏ పాఠమూ ప్లే అవ్వడం లేదు.';

  @override
  String libraryAddedToSession(String title) {
    return '$title ఈ సెషన్‌కు జోడించబడింది.';
  }

  @override
  String get libraryPlaylistNotCreated => 'ప్లేలిస్ట్ సృష్టించలేకపోయాము';

  @override
  String get libraryPrivatePlaylistNotCreated =>
      'ప్రైవేట్ ప్లేలిస్ట్ సృష్టించలేకపోయాము';

  @override
  String get libraryNoEligibleAudio =>
      'జోడించడానికి తగిన ఆడియో ఏదీ అందుబాటులో లేదు';

  @override
  String get libraryAudioAddedToPlaylist => 'ఆడియో ప్లేలిస్ట్‌కు జోడించబడింది';

  @override
  String libraryUnavailable(String title) {
    return '$title అందుబాటులో లేదు';
  }

  @override
  String libraryPlaylistRenamed(String title) {
    return 'ప్లేలిస్ట్ పేరు $title గా మార్చబడింది';
  }

  @override
  String libraryMovedTo(String title, String position) {
    return '$title ను $position స్థానానికి జరిపాము';
  }

  @override
  String get libraryNoteRenamed => 'ప్రైవేట్ నోట్ పేరు మార్చబడింది.';

  @override
  String get downloadNoneYet =>
      'ఇంకా డౌన్‌లోడ్‌లు లేవు. ఆన్‌లైన్‌లో రికార్డింగ్‌లు వెతకడానికి 2 నొక్కండి.';

  @override
  String downloadLessonCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count డౌన్‌లోడ్ చేసిన పాఠాలు',
      one: '1 డౌన్‌లోడ్ చేసిన పాఠం',
    );
    return '$_temp0';
  }

  @override
  String downloadPartialCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count అసంపూర్ణ డౌన్‌లోడ్‌లు',
      one: '1 అసంపూర్ణ డౌన్‌లోడ్',
    );
    return '$_temp0';
  }

  @override
  String downloadReadyToPlay(String lessons) {
    return '$lessons ప్లే చేయడానికి సిద్ధంగా ఉన్నాయి.';
  }

  @override
  String downloadReadyToPlayWithPartial(String lessons, String partial) {
    return '$lessons ప్లే చేయడానికి సిద్ధంగా ఉన్నాయి, $partial.';
  }

  @override
  String get downloadActionFailed =>
      'ఈ డౌన్‌లోడ్ పనిని పూర్తి చేయలేకపోయాము. స్టోరేజ్, మీ కనెక్షన్, సైన్ ఇన్ చూసుకుని మళ్ళీ ప్రయత్నించండి.';

  @override
  String get downloadOnlineListFailed =>
      'అందుబాటులో ఉన్న రికార్డింగ్‌లను లోడ్ చేయలేకపోయాము. ఇప్పటికే ఉన్న డౌన్‌లోడ్‌లు వాటి యాక్సెస్ గడువు ముగిసే వరకు పనిచేస్తాయి.';

  @override
  String downloadAvailable(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'డౌన్‌లోడ్ చేయడానికి $count రికార్డింగ్‌లు అందుబాటులో ఉన్నాయి. మీకు కావలసిన రికార్డింగ్‌లను ఎంచుకోండి.',
      one:
          'డౌన్‌లోడ్ చేయడానికి 1 రికార్డింగ్ అందుబాటులో ఉంది. మీకు కావలసిన రికార్డింగ్‌లను ఎంచుకోండి.',
    );
    return '$_temp0';
  }

  @override
  String downloadStarting(String title) {
    return '$title డౌన్‌లోడ్ అవుతోంది. ప్రతి 25 శాతానికి ప్రోగ్రెస్ వినిపిస్తుంది.';
  }

  @override
  String downloadProgress(String title, String percent) {
    return '$title $percent డౌన్‌లోడ్ అయింది.';
  }

  @override
  String get downloadVerified =>
      'డౌన్‌లోడ్ ధృవీకరించబడింది, ఆఫ్‌లైన్‌లో వినడానికి సేవ్ చేయబడింది.';

  @override
  String downloadDone(String title) {
    return '$title డౌన్‌లోడ్ అయింది, ధృవీకరించబడింది, ఆఫ్‌లైన్‌లో వినడానికి సేవ్ చేయబడింది.';
  }

  @override
  String downloadPackQuestion(String recordings) {
    return '$recordings ఒక్కొక్కటిగా డౌన్‌లోడ్ చేయాలా? దీనికి ఇంటర్నెట్ డేటా, మీ ఖాతాకు ఉన్న 50 MB పరిమితి ఉపయోగించబడుతుంది. విఫలమైనా లేదా రద్దు చేసినా, ధృవీకరించిన డౌన్‌లోడ్‌లు, అసంపూర్ణ డేటా ఉంచబడతాయి. ఇప్పటికే ఉన్న ఏ పాఠమూ తొలగించబడదు.';
  }

  @override
  String downloadPackStarting(String recordings) {
    return '$recordings ఒక్కొక్కటిగా డౌన్‌లోడ్ అవుతున్నాయి.';
  }

  @override
  String downloadPackProgress(String done, String total) {
    return '$total లో $done రికార్డింగ్‌లు ధృవీకరించబడ్డాయి.';
  }

  @override
  String downloadPackDone(String done, String total) {
    return '$total లో $done రికార్డింగ్‌లు ధృవీకరించబడి సేవ్ చేయబడ్డాయి.';
  }

  @override
  String downloadRenewed(String title) {
    return '$title కోసం యాక్సెస్ రెన్యూ చేయబడింది. 30 రోజుల వరకు ఆఫ్‌లైన్‌లో వినవచ్చు.';
  }

  @override
  String downloadRemoveTitle(String title) {
    return '$title డౌన్‌లోడ్‌ను తీసివేయాలా?';
  }

  @override
  String downloadRemoveQuestion(String title) {
    return '$title కోసం డౌన్‌లోడ్ చేసిన లేదా అసంపూర్ణ ఆడియోను తీసివేయాలా? అభ్యాస ప్రోగ్రెస్, బుక్‌మార్క్‌లు ఉంచబడతాయి. ఇతర రికార్డింగ్‌లు, ఖాతాలపై ప్రభావం ఉండదు.';
  }

  @override
  String downloadRemoved(String title) {
    return '$title డౌన్‌లోడ్ తీసివేయబడింది. ప్రోగ్రెస్, బుక్‌మార్క్‌లు ఉంచబడ్డాయి.';
  }

  @override
  String downloadUnreadableTitle(String id) {
    return 'చదవలేని రికార్డింగ్ $id';
  }

  @override
  String get downloadRenewalRequired => 'యాక్సెస్ రెన్యూ చేయాలి.';

  @override
  String downloadAccessExpires(String date) {
    return 'యాక్సెస్ గడువు $date ముగుస్తుంది.';
  }

  @override
  String downloadPlayLabelComplete(String title, String size, String expiry) {
    return '$title ప్లే చేయండి. డౌన్‌లోడ్ అయింది. $size. $expiry';
  }

  @override
  String downloadPlayLabelPartial(String title, String size, String expiry) {
    return '$title ప్లే చేయండి. అసంపూర్ణ డౌన్‌లోడ్, ఇంకా ప్లే చేయలేరు. $size. $expiry';
  }

  @override
  String downloadRenewLabel(String title) {
    return '$title కోసం యాక్సెస్ రెన్యూ చేయండి. ఇంటర్నెట్ కావాలి';
  }

  @override
  String downloadRemoveLabel(String title) {
    return '$title డౌన్‌లోడ్‌ను తీసివేయండి, నిర్ధారణ అడుగుతుంది';
  }

  @override
  String downloadUnreadableLabel(String id) {
    return 'చదవలేని డౌన్‌లోడ్ రికార్డ్ $id. ఈ డౌన్‌లోడ్‌ను మాత్రమే తీసివేయండి, నిర్ధారణ అడుగుతుంది';
  }

  @override
  String downloadOrResumeLabel(String title) {
    return '$title డౌన్‌లోడ్ చేయండి లేదా కొనసాగించండి';
  }

  @override
  String downloadCancelLabel(String title) {
    return '$title డౌన్‌లోడ్‌ను రద్దు చేయండి, కీ 4. మళ్ళీ ప్రయత్నించడానికి అసంపూర్ణ డేటాను ఉంచుతుంది';
  }

  @override
  String downloadUnavailableWhileBusy(String label) {
    return 'డౌన్‌లోడ్‌లు జరుగుతున్నప్పుడు $label అందుబాటులో ఉండదు.';
  }

  @override
  String get downloadStorageUnknown =>
      'స్టోరేజ్ కేటాయింపు అందుబాటులో లేదు. డౌన్‌లోడ్ చేసే ముందు డౌన్‌లోడ్‌లను రిఫ్రెష్ చేయండి లేదా ఎంచుకున్న చదవలేని రికార్డ్‌లను తీసివేయండి.';

  @override
  String downloadCountComma(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count డౌన్‌లోడ్‌లు,',
      one: '1 డౌన్‌లోడ్,',
    );
    return '$_temp0';
  }

  @override
  String get downloadStorageUseUnknown => 'స్టోరేజ్ వినియోగం తెలియదు.';

  @override
  String downloadDownloadingStarting(String title) {
    return '$title డౌన్‌లోడ్ అవుతోంది, మొదలవుతోంది.';
  }

  @override
  String downloadDownloadingPercent(String title, String percent) {
    return '$title డౌన్‌లోడ్ అవుతోంది, $percent.';
  }

  @override
  String downloadScreenLoaded(String complete) {
    return '$complete డౌన్‌లోడ్ చేసిన పాఠాలు ప్లే చేయడానికి సిద్ధంగా ఉన్నాయి.';
  }

  @override
  String downloadScreenLoadedWithPartial(String complete, String partial) {
    return '$complete డౌన్‌లోడ్ చేసిన పాఠాలు ప్లే చేయడానికి సిద్ధంగా ఉన్నాయి, $partial అసంపూర్ణ డౌన్‌లోడ్‌లు.';
  }

  @override
  String downloadAvailableCount(String count) {
    return 'డౌన్‌లోడ్ చేయడానికి $count రికార్డింగ్‌లు అందుబాటులో ఉన్నాయి. మీకు కావలసిన రికార్డింగ్‌లను ఎంచుకోండి.';
  }

  @override
  String downloadRecordingFallback(String id) {
    return 'రికార్డింగ్ $id';
  }

  @override
  String get downloadPackDialogTitle =>
      'జాబితాలోని రికార్డింగ్‌లను డౌన్‌లోడ్ చేయాలా?';

  @override
  String downloadPackDialogMessage(String count) {
    return 'జాబితాలోని $count రికార్డింగ్‌లను ఒక్కొక్కటిగా డౌన్‌లోడ్ చేయాలా? దీనికి ఇంటర్నెట్ డేటా, మీ ఖాతాకు ఉన్న 50 MB పరిమితి ఉపయోగించబడుతుంది. విఫలమైనా లేదా రద్దు చేసినా, ధృవీకరించిన డౌన్‌లోడ్‌లు, అసంపూర్ణ డేటా ఉంచబడతాయి. ఇప్పటికే ఉన్న ఏ పాఠమూ తొలగించబడదు.';
  }

  @override
  String get downloadPackConfirm => 'జాబితాలోనివి డౌన్‌లోడ్ చేయండి';

  @override
  String get downloadPackCancel => 'ఒక్కొక్కటిగా ఎంచుకోండి';

  @override
  String get downloadRemoveConfirm => 'డౌన్‌లోడ్ తీసివేయండి';

  @override
  String get downloadKeep => 'డౌన్‌లోడ్ ఉంచండి';

  @override
  String get downloadScreenName => 'డౌన్‌లోడ్ చేసిన పాఠాలు';

  @override
  String get downloadCancelBackTitle =>
      'డౌన్‌లోడ్ రద్దు చేసి వెనక్కి వెళ్ళాలా?';

  @override
  String get downloadCancelBackMessage =>
      'ఈ డౌన్‌లోడ్‌ను ఆపాలా? మీరు మళ్ళీ ప్రయత్నించడానికి ధృవీకరించిన రికార్డింగ్‌లు, అసంపూర్ణ డేటా ఉంచబడతాయి.';

  @override
  String get downloadCancelBackConfirm => 'రద్దు చేసి వెనక్కి వెళ్ళండి';

  @override
  String get downloadKeepDownloading => 'డౌన్‌లోడ్ కొనసాగించండి';

  @override
  String downloadReserved(String megabytes) {
    return 'ఈ ఖాతా కోసం 50 MB లో $megabytes కేటాయించబడింది.';
  }

  @override
  String get downloadBack => 'వెనక్కి';

  @override
  String get downloadRefreshLabel =>
      'సేవ్ చేసిన డౌన్‌లోడ్‌లను రిఫ్రెష్ చేయండి, కీ 1';

  @override
  String get downloadFindOnlineLabel =>
      'డౌన్‌లోడ్ చేయడానికి రికార్డింగ్‌లు వెతకండి, కీ 2. ఇంటర్నెట్ కావాలి';

  @override
  String get downloadReadStatusLabel => 'డౌన్‌లోడ్ స్థితిని చదవండి, కీ 3';

  @override
  String downloadPlayDownloadedLabel(String title) {
    return '$title ప్లే చేయండి. డౌన్‌లోడ్ అయింది';
  }

  @override
  String downloadPlayPartialLabel(String title) {
    return '$title ప్లే చేయండి. అసంపూర్ణ డౌన్‌లోడ్, ఇంకా ప్లే చేయలేరు';
  }

  @override
  String get downloadPackLabel =>
      'జాబితాలోని అన్ని రికార్డింగ్‌లను డౌన్‌లోడ్ చేయండి, కీ 5, నిర్ధారణ అడుగుతుంది';

  @override
  String get downloadIntroduction =>
      'ప్రతి ఖాతాకు 50 MB. ఆన్‌లైన్‌లో యాక్సెస్ రెన్యూ చేసే ముందు 30 రోజుల వరకు ఆఫ్‌లైన్‌లో వినవచ్చు. ఫైళ్ళు, ప్రోగ్రెస్ వేర్వేరుగా ఉంటాయి.';

  @override
  String get downloadNavigationSections =>
      'ప్లే చేయడానికి, రెన్యూ చేయడానికి లేదా తీసివేయడానికి సేవ్ చేసిన ఫైళ్ళు, డౌన్‌లోడ్ చేయడానికి లేదా కొనసాగించడానికి ఆన్‌లైన్ రికార్డింగ్‌లు';

  @override
  String get downloadKeyRefresh => 'డౌన్‌లోడ్‌లను రిఫ్రెష్ చేయండి';

  @override
  String get downloadKeyFindOnline => 'ఆన్‌లైన్‌లో రికార్డింగ్‌లు వెతకండి';

  @override
  String get downloadKeyReadStatus => 'స్థితిని చదవండి';

  @override
  String get downloadKeyCancel => 'డౌన్‌లోడ్ రద్దు చేయండి';

  @override
  String get downloadKeyPack => 'జాబితాలోని రికార్డింగ్‌లను డౌన్‌లోడ్ చేయండి';

  @override
  String get downloadErrInvalidInfo =>
      'డౌన్‌లోడ్ సమాచారం చెల్లదు లేదా వేరే ఖాతాకు చెందినది. ఇప్పటికే ఉన్న ఫైళ్ళు ఉంచబడ్డాయి.';

  @override
  String get downloadErrSignInToOpen =>
      'డౌన్‌లోడ్ చేసిన పాఠాలను తెరిచే ముందు సైన్ ఇన్ చేయండి.';

  @override
  String get downloadErrAccountChanged =>
      'మీ ఖాతా మారింది. డౌన్‌లోడ్‌లను మళ్ళీ తెరవండి.';

  @override
  String get downloadErrNoStorage =>
      'ఈ పరికరంలో డౌన్‌లోడ్ స్టోరేజ్ అందుబాటులో లేదు.';

  @override
  String get downloadErrStorageUnavailable =>
      'డౌన్‌లోడ్ స్టోరేజ్ అందుబాటులో లేదు. ఖాళీ స్థలం చూసుకుని మళ్ళీ ప్రయత్నించండి. ఇప్పటికే ఉన్న ఫైళ్ళను కావాలని తీసివేయలేదు.';

  @override
  String get downloadErrRecordsUnreadable =>
      'డౌన్‌లోడ్ రికార్డ్‌లను చదవలేకపోయాము. ఇప్పటికే ఉన్న ఫైళ్ళు ఉంచబడ్డాయి.';

  @override
  String get downloadErrRecordUnreadable =>
      'ఒక డౌన్‌లోడ్ రికార్డ్‌ను చదవలేకపోయాము. ఇప్పటికే ఉన్న ఫైళ్ళు ఉంచబడ్డాయి.';

  @override
  String get downloadErrIdentityMismatch =>
      'డౌన్‌లోడ్ గుర్తింపు దాని రికార్డ్‌తో సరిపోలడం లేదు.';

  @override
  String get downloadErrSignInToRenew =>
      'డౌన్‌లోడ్ యాక్సెస్ రెన్యూ చేసే ముందు ఆన్‌లైన్‌లో సైన్ ఇన్ చేయండి.';

  @override
  String get downloadErrSignInChanged =>
      'మీ సైన్ ఇన్ మారింది. డౌన్‌లోడ్‌లను మళ్ళీ తెరవండి.';

  @override
  String get downloadErrAccessNotConfirmed =>
      'ఈ ఖాతాకు రికార్డింగ్ యాక్సెస్ ఇప్పుడు నిర్ధారించబడలేదు. రెన్యూ చేయడానికి మళ్ళీ కనెక్ట్ అయి సైన్ ఇన్ చేయండి. సేవ్ చేసిన ఫైల్ ఉంచబడింది.';

  @override
  String get downloadErrTooLarge =>
      'ఈ రికార్డింగ్ 50 MB డౌన్‌లోడ్ పరిమితి కంటే పెద్దది.';

  @override
  String get downloadErrRenewServer =>
      'సర్వర్ ఈ రికార్డింగ్‌ను రెన్యూ చేయలేకపోయింది. తర్వాత మళ్ళీ ప్రయత్నించండి.';

  @override
  String get downloadErrInvalidServerInfo =>
      'సర్వర్ చెల్లని డౌన్‌లోడ్ సమాచారం ఇచ్చింది.';

  @override
  String get downloadErrDifferentRecording =>
      'సర్వర్ వేరే రికార్డింగ్ ఇచ్చింది.';

  @override
  String get downloadErrTimedOut =>
      'కనెక్షన్ సమయం ముగిసింది. మళ్ళీ కనెక్ట్ అయి ప్రయత్నించండి.';

  @override
  String get downloadErrRenewConnect =>
      'ఈ రికార్డింగ్‌ను రెన్యూ చేయడానికి కనెక్ట్ కాలేకపోయాము. మీ ఇంటర్నెట్ కనెక్షన్ చూసుకోండి.';

  @override
  String get downloadErrClockUnreadable =>
      'ఆఫ్‌లైన్ సమయ రికార్డ్‌ను చదవలేకపోయాము. కనెక్ట్ అయి యాక్సెస్ రెన్యూ చేయండి.';

  @override
  String get downloadErrClockBackwards =>
      'ఫోన్ గడియారం వెనక్కి వెళ్ళింది. తేదీని సరిచేసి, యాక్సెస్ రెన్యూ చేయడానికి మళ్ళీ కనెక్ట్ అవ్వండి.';

  @override
  String get downloadErrExpired =>
      '30 రోజుల తర్వాత ఆఫ్‌లైన్ యాక్సెస్ గడువు ముగిసింది. ఇంటర్నెట్‌కు కనెక్ట్ అయి ఈ పాఠాన్ని రెన్యూ చేయండి. మీ ప్రోగ్రెస్, డౌన్‌లోడ్ చేసిన ఫైల్ ఉంచబడ్డాయి.';

  @override
  String get downloadErrIncompleteForPlayback =>
      'ఆఫ్‌లైన్‌లో వినే ముందు ఈ పాఠాన్ని పూర్తిగా డౌన్‌లోడ్ చేయండి.';

  @override
  String get downloadErrRenewalRequired =>
      'యాక్సెస్ రెన్యూ చేయాలి. ఈ డౌన్‌లోడ్‌ను ప్లే చేసే ముందు కనెక్ట్ అయి రెన్యూ చేయండి.';

  @override
  String get downloadErrDamaged =>
      'డౌన్‌లోడ్ చేసిన రికార్డింగ్ అసంపూర్ణంగా ఉంది లేదా పాడైంది. ఈ డౌన్‌లోడ్‌ను తీసివేసి మళ్ళీ డౌన్‌లోడ్ చేయండి. ప్రోగ్రెస్, బుక్‌మార్క్‌లు వేరుగా ఉంటాయి.';

  @override
  String get downloadErrDownloadFirst => 'ముందుగా ఈ పాఠాన్ని డౌన్‌లోడ్ చేయండి.';

  @override
  String get downloadErrRecordingChangedRenew =>
      'ఈ రికార్డింగ్ మారింది. దాని డౌన్‌లోడ్‌ను తీసివేసి, ప్రస్తుత రికార్డింగ్‌ను డౌన్‌లోడ్ చేయండి. ప్రోగ్రెస్, బుక్‌మార్క్‌లు ఉంచబడతాయి.';

  @override
  String get downloadErrCancelledAnyPartial =>
      'డౌన్‌లోడ్ రద్దు చేయబడింది. మీరు మళ్ళీ ప్రయత్నించడానికి అసంపూర్ణ ఫైల్ ఏదైనా ఉంటే ఉంచబడుతుంది.';

  @override
  String get downloadErrRecordingChanged =>
      'రికార్డింగ్ మారింది. ప్రస్తుత వెర్షన్‌ను డౌన్‌లోడ్ చేసే ముందు దాని పాత డౌన్‌లోడ్‌ను తీసివేయండి. ప్రోగ్రెస్ ఉంచబడుతుంది.';

  @override
  String get downloadErrSavedDamaged =>
      'సేవ్ చేసిన రికార్డింగ్ పాడైంది. మళ్ళీ ప్రయత్నించే ముందు దాని డౌన్‌లోడ్‌ను తీసివేయండి.';

  @override
  String get downloadErrQuota =>
      'మీ ఖాతా 50 MB డౌన్‌లోడ్ పరిమితిని చేరుకుంది. మీ డౌన్‌లోడ్‌లలో వేటిని తీసివేయాలో ఎంచుకుని, మళ్ళీ ప్రయత్నించండి. ఏదీ తొలగించబడలేదు.';

  @override
  String get downloadErrPartialInvalid =>
      'పాక్షిక డౌన్‌లోడ్ చెల్లదు. మళ్లీ ప్రయత్నించే ముందు దాన్ని తీసివేయండి.';

  @override
  String get downloadErrIntegrityPartial =>
      'డౌన్‌లోడ్ సమగ్రత తనిఖీ విఫలమైంది. మళ్లీ ప్రయత్నించే ముందు ఈ పాక్షిక డౌన్‌లోడ్‌ను తీసివేయండి.';

  @override
  String get downloadErrSignInToDownload =>
      'డౌన్‌లోడ్ చేసే ముందు సైన్ ఇన్ చేయండి.';

  @override
  String get downloadErrCancelledExplicit =>
      'డౌన్‌లోడ్ రద్దు చేయబడింది. మీరు స్వయంగా మళ్లీ ప్రయత్నించడం కోసం పాక్షిక డేటా ఉంచబడింది.';

  @override
  String get downloadErrAccessDenied =>
      'డౌన్‌లోడ్ యాక్సెస్ నిరాకరించబడింది. మళ్లీ కనెక్ట్ అయి యాక్సెస్‌ను పునరుద్ధరించండి.';

  @override
  String get downloadErrUnexpectedPartial =>
      'సర్వర్ ఊహించని పాక్షిక రికార్డింగ్‌ను పంపింది. ఉన్న డేటాను తొలగించకుండా మళ్లీ ప్రయత్నించండి.';

  @override
  String get downloadErrCouldNotDownload =>
      'రికార్డింగ్‌ను డౌన్‌లోడ్ చేయలేకపోయాము. మీ కనెక్షన్‌ను తనిఖీ చేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get downloadErrSizeChanged =>
      'రికార్డింగ్ పరిమాణం మారింది. మళ్లీ డౌన్‌లోడ్ చేయడానికి ప్రయత్నించండి.';

  @override
  String get downloadErrAccountChangedStopped =>
      'మీ ఖాతా మారింది. డౌన్‌లోడ్ ఆపివేయబడింది.';

  @override
  String get downloadErrExceededSize =>
      'రికార్డింగ్ తెలిపిన పరిమాణాన్ని మించిపోయింది. డౌన్‌లోడ్ ఆపివేయబడింది.';

  @override
  String get downloadErrIntegrity =>
      'డౌన్‌లోడ్ సమగ్రత తనిఖీ విఫలమైంది. అసంపూర్ణ డౌన్‌లోడ్‌ను మళ్లీ ప్రయత్నించండి, లేదా మళ్లీ ప్రయత్నించే ముందు పాడైన పాక్షిక డేటాను తీసివేయండి.';

  @override
  String get downloadErrSignInChangedStopped =>
      'మీ సైన్ ఇన్ మారింది. ఇన్‌స్టాల్ చేయడానికి ముందే డౌన్‌లోడ్ ఆపివేయబడింది.';

  @override
  String get downloadErrTimedOutPartial =>
      'డౌన్‌లోడ్ సమయం ముగిసింది. పాక్షిక డేటా ఉంచబడింది; మళ్లీ ప్రయత్నించడానికి డౌన్‌లోడ్‌ను ఎంచుకోండి.';

  @override
  String get downloadErrCancelledRetry =>
      'డౌన్‌లోడ్ రద్దు చేయబడింది. మళ్లీ ప్రయత్నించడం కోసం పాక్షిక డేటా ఉంచబడింది.';

  @override
  String get downloadErrInterrupted =>
      'డౌన్‌లోడ్ మధ్యలో ఆగిపోయింది. పాక్షిక డేటా ఉంచబడింది; మళ్లీ ప్రయత్నించడానికి డౌన్‌లోడ్‌ను ఎంచుకోండి.';

  @override
  String get libraryErrStorageUnavailable =>
      'ఈ పరికరంలో అభ్యాస నిల్వ అందుబాటులో లేదు. మీ ప్రస్తుత డేటా మార్చబడలేదు.';

  @override
  String get libraryErrStorageNotOpened =>
      'అభ్యాస నిల్వను తెరవలేకపోయాము. ఖాళీ స్థలాన్ని తనిఖీ చేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get libraryErrNoStorageLocation =>
      'ఈ పరికరం అభ్యాస నిల్వ స్థానాన్ని అందించలేదు. మీ ప్రస్తుత డేటా మార్చబడలేదు.';

  @override
  String get libraryErrStartLessonFirst =>
      'ప్రోగ్రెస్ సేవ్ చేయడాన్ని మళ్లీ ప్రయత్నించే ముందు ఒక పాఠాన్ని ప్రారంభించండి.';

  @override
  String get libraryErrProgressNotSaved =>
      'అభ్యాస ప్రోగ్రెస్ సేవ్ కాలేదు. నిల్వ అందుబాటులో ఉన్నప్పుడు మళ్లీ ప్రయత్నించండి.';

  @override
  String get libraryErrChoosePosition => 'పాఠంలోని ఒక స్థానాన్ని ఎంచుకోండి';

  @override
  String get libraryErrChooseSpeed =>
      '0.25 నుండి 3 వరకు ఒక ప్లేబ్యాక్ వేగాన్ని ఎంచుకోండి';

  @override
  String get libraryErrChooseBookmarkPosition =>
      'పాఠంలో బుక్‌మార్క్ స్థానాన్ని ఎంచుకోండి';

  @override
  String get libraryErrBookmarkNotSaved =>
      'ప్రోగ్రెస్ సేవ్ చేయడం అందుబాటులో లేదు. బుక్‌మార్క్ సేవ్ కాలేదు.';

  @override
  String get libraryErrBookmarkChangesUnavailable =>
      'ప్రోగ్రెస్ సేవ్ చేయడం మళ్లీ పని చేసే వరకు బుక్‌మార్క్ మార్పులు అందుబాటులో ఉండవు.';

  @override
  String get libraryErrRepeatNotSaved =>
      'ప్రోగ్రెస్ సేవ్ చేయడం అందుబాటులో లేదు. రిపీట్ పాయింట్‌లు సేవ్ కాలేదు.';

  @override
  String get libraryErrSetRepeatFirst =>
      'ముందుగా ఈ పాఠంలో ఒక ప్రారంభ పాయింట్‌ను, దాని తర్వాత ఒక ముగింపు పాయింట్‌ను సెట్ చేయండి';

  @override
  String get libraryErrRepeatFailed =>
      'రిపీట్ ప్లేబ్యాక్ విఫలమైంది. పాజ్ చేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get libraryScreenBack => 'వెనుకకు';

  @override
  String get libraryScreenRefreshTarget =>
      'ఆడియో ఫైల్‌లను రిఫ్రెష్ చేయండి, కీ 1';

  @override
  String get libraryScreenPauseSessionTarget =>
      'మొత్తం సెషన్‌కు ఆడియోను పాజ్ చేయండి, కీ 3';

  @override
  String get libraryScreenUploadTarget => 'ఆడియోను అప్‌లోడ్ చేయండి, కీ 2';

  @override
  String libraryScreenStopPreviewTarget(String title) {
    return '$title ప్రైవేట్ ప్రివ్యూను ఆపండి. ఇది మీకు మాత్రమే వినిపిస్తుంది.';
  }

  @override
  String libraryScreenPreviewTarget(String title) {
    return '$titleను ప్రైవేట్‌గా ప్రివ్యూ చేయండి. ఇది మీకు మాత్రమే వినిపిస్తుంది.';
  }

  @override
  String libraryScreenBroadcastTarget(String title) {
    return 'సెషన్‌లోని అందరి కోసం $title ప్లే చేయండి';
  }

  @override
  String get libraryScreenPreviewFinished => 'ప్రివ్యూ ముగిసింది';

  @override
  String get libraryScreenNoRecordings =>
      'ఇంకా రికార్డింగ్‌లు లేవు. ఆడియోను అప్‌లోడ్ చేయడానికి 2 నొక్కండి.';

  @override
  String libraryScreenRecordingsLoaded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count రికార్డింగ్‌లు లోడ్ అయ్యాయి.',
    );
    return '$_temp0';
  }

  @override
  String get libraryScreenLoadFailed =>
      'రికార్డింగ్‌లను లోడ్ చేయలేకపోయాము. మీ ఇంటర్నెట్ కనెక్షన్‌ను తనిఖీ చేసి, మళ్లీ ప్రయత్నించడానికి 1 నొక్కండి.';

  @override
  String get libraryScreenTitleRequired => 'శీర్షిక తప్పనిసరి';

  @override
  String get libraryScreenUploadDialogName => 'ఆడియోను అప్‌లోడ్ చేయండి';

  @override
  String get libraryScreenEditTitleKey => 'శీర్షికను మార్చండి';

  @override
  String get libraryScreenEditDescriptionKey => 'వివరణను మార్చండి';

  @override
  String get libraryScreenUploadKey => 'అప్‌లోడ్';

  @override
  String get libraryScreenCancelKey => 'రద్దు చేయండి';

  @override
  String get libraryScreenTitleField => 'ఆడియో శీర్షిక, తప్పనిసరి';

  @override
  String get libraryScreenDescriptionField => 'ఆడియో వివరణ, ఐచ్ఛికం';

  @override
  String get libraryScreenCancelUpload => 'అప్‌లోడ్‌ను రద్దు చేయండి';

  @override
  String get libraryScreenPickFailed => 'ఫైల్‌ను ఎంచుకోవడం విఫలమైంది';

  @override
  String get libraryScreenChooseWorkspace =>
      'ఆడియోను అప్‌లోడ్ చేసే ముందు ఉపాధ్యాయుల డాష్‌బోర్డ్‌లో ఒక తరగతి మరియు సబ్జెక్టు వర్క్‌స్పేస్‌ను ఎంచుకోండి.';

  @override
  String libraryScreenUploading(String title) {
    return '$title అప్‌లోడ్ అవుతోంది. ప్రతి 25 శాతానికి మీకు ప్రోగ్రెస్ వినిపిస్తుంది.';
  }

  @override
  String libraryScreenUploaded(String title) {
    return '$title అప్‌లోడ్ అయింది.';
  }

  @override
  String libraryScreenUploadProgress(String title, String percent) {
    return '$title: $percent శాతం అప్‌లోడ్ అయింది.';
  }

  @override
  String libraryScreenPreviewStopped(String title) {
    return '$title ప్రివ్యూ ఆపివేయబడింది';
  }

  @override
  String libraryScreenPreviewing(String title) {
    return '$titleను ప్రైవేట్‌గా ప్రివ్యూ చేస్తున్నాము';
  }

  @override
  String libraryScreenPlayFailed(String title) {
    return '$titleను ప్లే చేయలేకపోయాము. మీ కనెక్షన్‌ను తనిఖీ చేసి మళ్లీ ప్రయత్నించండి.';
  }

  @override
  String get libraryScreenNoActiveSession => 'యాక్టివ్ సెషన్ లేదు';

  @override
  String libraryScreenSelectedForSession(String title) {
    return 'సెషన్ కోసం $title ఎంచుకోబడింది';
  }

  @override
  String get libraryScreenAudioSelectedTitle => 'ఆడియో ఎంచుకోబడింది';

  @override
  String libraryScreenPlayForEveryoneNow(String title) {
    return '\"$title\"ను ఇప్పుడు సెషన్‌లోని అందరి కోసం ప్లే చేయాలా?';
  }

  @override
  String get libraryScreenNotYet => 'ఇప్పుడు కాదు';

  @override
  String get libraryScreenPlayNow => 'ఇప్పుడే ప్లే చేయండి';

  @override
  String get libraryScreenSelectFailed => 'ఆడియోను ఎంచుకోవడం విఫలమైంది';

  @override
  String get libraryScreenPlaybackAccepted =>
      'తరగతి ప్లేబ్యాక్ అభ్యర్థన అంగీకరించబడింది';

  @override
  String get libraryScreenPlaybackFailed =>
      'ప్లేబ్యాక్‌ను ప్రారంభించడం విఫలమైంది';

  @override
  String get libraryScreenPauseAccepted =>
      'తరగతి పాజ్ అభ్యర్థన అంగీకరించబడింది';

  @override
  String get libraryScreenPauseFailed => 'ఆడియోను పాజ్ చేయడం విఫలమైంది';

  @override
  String get libraryScreenAudioLibraryName => 'ఆడియో లైబ్రరీ';

  @override
  String get libraryScreenAudioLibrarySections =>
      'రికార్డింగ్‌లు, ప్లేబ్యాక్ మరియు స్వర నియంత్రణలు, రికార్డింగ్ షేరింగ్, మరియు అందుబాటులో ఉన్నప్పుడు అప్‌లోడ్ సాధనాలు';

  @override
  String get libraryScreenRefreshKey => 'ఆడియో ఫైల్‌లను రిఫ్రెష్ చేయండి';

  @override
  String get libraryScreenUploadAudioKey => 'ఆడియోను అప్‌లోడ్ చేయండి';

  @override
  String get libraryScreenPauseSessionKey => 'సెషన్ ఆడియోను పాజ్ చేయండి';

  @override
  String get libraryScreenBrowseTarget =>
      'మొదటి యాక్టివ్ తరగతికి వెళ్లండి. యాక్టివ్ సెషన్‌లను చూడటానికి D-pad ఉపయోగించండి';

  @override
  String get libraryScreenRefreshClassesTarget => 'తరగతులను రిఫ్రెష్ చేయండి';

  @override
  String get libraryScreenSearchClassField => 'పేరుతో తరగతిని వెతకండి';

  @override
  String get libraryScreenSearchTarget => 'వెతకండి';

  @override
  String get libraryScreenAllRecordedTarget =>
      'అన్ని రికార్డ్ చేసిన ఆడియో ఫైల్‌లు';

  @override
  String get libraryScreenContinueTarget =>
      'అభ్యాసాన్ని కొనసాగించండి. మీరు చివరిగా పూర్తి చేయని రికార్డ్ చేసిన పాఠాన్ని కనుగొనండి';

  @override
  String get libraryScreenDownloadsTarget =>
      'డౌన్‌లోడ్ చేసిన పాఠాలు. ఆన్‌లైన్ జాబితాలను లోడ్ చేయకుండా సేవ్ చేసిన రికార్డింగ్‌లను తెరవండి';

  @override
  String get libraryScreenNotesTarget =>
      'ప్రైవేట్ నోట్‌లు మరియు ఉపాధ్యాయుల రికార్డింగ్ డ్రాఫ్ట్‌లు. పరికరంలోని నిల్వ నుండి పనిచేస్తుంది';

  @override
  String get libraryScreenMyPlaylistsTarget => 'నా ప్రైవేట్ ప్లేలిస్ట్‌లు';

  @override
  String libraryScreenClassTarget(String title, String position, String total) {
    return '$title. $totalలో తరగతి $position';
  }

  @override
  String get libraryScreenAccountChanged =>
      'మీ ఖాతా మారింది. లైబ్రరీని మళ్లీ తెరవండి.';

  @override
  String get libraryScreenNoUnfinishedLesson =>
      'ఈ ఖాతాకు పూర్తి కాని పాఠం ఏదీ సేవ్ కాలేదు. నేర్చుకోవడం ప్రారంభించడానికి ఒక రికార్డ్ చేసిన పాఠాన్ని ఎంచుకోండి.';

  @override
  String get libraryScreenAccessCheckFailed =>
      'పాఠం యాక్సెస్‌ను తనిఖీ చేయలేకపోయాము. ఇంటర్నెట్‌కు కనెక్ట్ అయి మళ్లీ ప్రయత్నించండి. మీ సేవ్ చేసిన ప్రోగ్రెస్ ఉంచబడింది.';

  @override
  String get libraryScreenUnfinishedUnavailable =>
      'మీ పూర్తి కాని పాఠాలు ప్రస్తుతం ఈ లైబ్రరీలో అందుబాటులో లేవు. మీ సేవ్ చేసిన ప్రోగ్రెస్ మరియు బుక్‌మార్క్‌లు ఉంచబడ్డాయి.';

  @override
  String get libraryScreenOpeningNextUnfinished =>
      'అత్యంత ఇటీవలి పాఠం ఇక్కడ అందుబాటులో లేదు. అందుబాటులో ఉన్న తదుపరి ఇటీవలి పూర్తి కాని పాఠాన్ని తెరుస్తున్నాము. సేవ్ చేసిన ప్రోగ్రెస్ ఉంచబడింది.';

  @override
  String get libraryScreenProgressOpenFailed =>
      'సేవ్ చేసిన అభ్యాస ప్రోగ్రెస్‌ను తెరవలేకపోయాము. నిల్వ, మీ కనెక్షన్ మరియు సైన్ ఇన్‌ను తనిఖీ చేసి, మళ్లీ ప్రయత్నించండి.';

  @override
  String get libraryScreenContinueLearningTitle => 'అభ్యాసాన్ని కొనసాగించండి';

  @override
  String get libraryScreenNoActiveClasses =>
      'ప్రస్తుతం యాక్టివ్ తరగతులు లేవు. అన్ని ఆడియో ఫైల్‌ల కోసం 3 నొక్కండి.';

  @override
  String libraryScreenActiveClassesLoaded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count యాక్టివ్ తరగతులు లోడ్ అయ్యాయి.',
    );
    return '$_temp0';
  }

  @override
  String libraryScreenClassesRefreshFailed(String reason) {
    return '$reason యాక్టివ్ తరగతులను రిఫ్రెష్ చేయలేకపోయాము. మళ్లీ ప్రయత్నించడానికి 1 నొక్కండి. సేవ్ చేసిన డౌన్‌లోడ్‌లు అందుబాటులోనే ఉన్నాయి.';
  }

  @override
  String get libraryScreenClassListUnreadable => 'తరగతి జాబితాను చదవలేకపోయాము.';

  @override
  String get libraryScreenSessionFallback => 'సెషన్';

  @override
  String get libraryScreenMyAudioLibraryTitle => 'నా ఆడియో లైబ్రరీ';

  @override
  String get libraryScreenAllAudioFilesTitle => 'అన్ని ఆడియో ఫైల్‌లు';

  @override
  String get libraryScreenNoActiveClassesStaying =>
      'యాక్టివ్ తరగతులు లేవు. ఆడియో లైబ్రరీలోనే ఉంటున్నాము.';

  @override
  String libraryScreenFirstActiveClass(String title) {
    return '$title. మొదటి యాక్టివ్ తరగతి. యాక్టివ్ తరగతి సెషన్‌లను చూడటానికి D-pad పైకి, కిందికి ఉపయోగించండి. ఎంచుకున్న తరగతి రికార్డింగ్‌లను తెరవడానికి ఓకే నొక్కండి.';
  }

  @override
  String get libraryScreenRecordedLibraryName =>
      'రికార్డ్ చేసిన ఆడియో లైబ్రరీ. ఆన్‌లైన్ జాబితాలకు ఇంటర్నెట్ అవసరం. డౌన్‌లోడ్ చేసిన పాఠాలు ఆఫ్‌లైన్ ప్లేబ్యాక్ కోసం విడిగా తెరుచుకుంటాయి.';

  @override
  String get libraryScreenRecordedLibrarySections =>
      'అభ్యాసాన్ని కొనసాగించడం, సేవ్ చేసిన డౌన్‌లోడ్‌లు మరియు ప్రైవేట్ నోట్‌లు, తరగతి శోధన, మరియు యాక్టివ్ తరగతి సెషన్‌లు';

  @override
  String get libraryScreenMyPlaylistsKey => 'నా ప్రైవేట్ ప్లేలిస్ట్‌లు';

  @override
  String get libraryScreenWaitForPlayerNotes =>
      'స్టడీ నోట్‌లను తెరిచే ముందు రికార్డింగ్ ప్లేయర్ కోసం వేచి ఉండండి.';

  @override
  String get libraryScreenStatusPlaying => 'ప్లే అవుతోంది';

  @override
  String get libraryScreenStatusPaused => 'పాజ్ చేయబడింది';

  @override
  String get libraryScreenUntitled => 'శీర్షిక లేదు';

  @override
  String get libraryScreenSubjectFallback => 'సబ్జెక్టు';

  @override
  String get libraryScreenDownloadedLessonsName =>
      'డౌన్‌లోడ్ చేసిన పాఠాలు. ప్లే చేసే ముందు ఉన్న ఆఫ్‌లైన్ యాక్సెస్ తనిఖీ చేయబడుతుంది.';

  @override
  String get libraryScreenClassAudioName =>
      'ఆడియో లైబ్రరీ. ఆన్‌లైన్ రికార్డింగ్‌లకు ఇంటర్నెట్ అవసరం. ఆఫ్‌లైన్ ప్లేబ్యాక్ కోసం పాఠాలను డౌన్‌లోడ్ చేయండి.';

  @override
  String libraryScreenLessonPositionTarget(String position) {
    return 'పాఠం స్థానం $position. 10 సెకన్లు జరపడానికి ఎడమ లేదా కుడి ఉపయోగించండి.';
  }

  @override
  String libraryScreenBack10Target(String key) {
    return '10 సెకన్లు వెనుకకు, కీ $key';
  }

  @override
  String libraryScreenPauseTarget(String title, String key) {
    return '$title పాజ్ చేయండి, కీ $key';
  }

  @override
  String libraryScreenResumeTarget(String title, String key) {
    return '$title మళ్లీ ప్రారంభించండి, కీ $key';
  }

  @override
  String get libraryScreenLessonFallback => 'పాఠం';

  @override
  String libraryScreenForward10Target(String key) {
    return '10 సెకన్లు ముందుకు, కీ $key';
  }

  @override
  String libraryScreenSlowerTarget(String key, String speed) {
    return 'నెమ్మదిగా, కీ $key. ఇప్పుడు $speed రెట్లు';
  }

  @override
  String libraryScreenStopTarget(String title) {
    return '$title ఆపండి, కీ 8';
  }

  @override
  String libraryScreenFasterTarget(String key, String speed) {
    return 'వేగంగా, కీ $key. ఇప్పుడు $speed రెట్లు';
  }

  @override
  String get libraryScreenDownloadsManageTarget =>
      'పాఠాలను డౌన్‌లోడ్ చేయండి లేదా సేవ్ చేసిన రికార్డింగ్‌లను నిర్వహించండి';

  @override
  String get libraryScreenStopSpeechTarget => 'మాటలను ఆపండి';

  @override
  String get libraryScreenUploadFirstTarget => 'మొదటి ఆడియోను అప్‌లోడ్ చేయండి';

  @override
  String get libraryScreenRefreshEmptyTarget =>
      'ఖాళీ ఆడియో లైబ్రరీని రిఫ్రెష్ చేయండి';

  @override
  String get libraryScreenAddAudioTarget => 'ఆడియోను జోడించండి, కీ 3';

  @override
  String get libraryScreenLessonTitleFallback => 'పాఠం';

  @override
  String get libraryScreenDownloadedDescription =>
      'డౌన్‌లోడ్ చేసిన రికార్డింగ్. 30 రోజుల తర్వాత యాక్సెస్‌ను పునరుద్ధరించాలి.';

  @override
  String libraryScreenSavedSubject(String id) {
    return 'సేవ్ చేసిన సబ్జెక్టు $id';
  }

  @override
  String get libraryScreenDownloadsReadFailed =>
      'డౌన్‌లోడ్ చేసిన పాఠాలను చదవలేకపోయాము. మళ్లీ ప్రయత్నించడానికి 1 నొక్కండి.';

  @override
  String get libraryScreenLoadFailedSignIn =>
      'రికార్డింగ్‌లను లోడ్ చేయలేకపోయాము. మీ ఇంటర్నెట్ కనెక్షన్ మరియు సైన్ ఇన్‌ను తనిఖీ చేసి, మళ్లీ ప్రయత్నించడానికి 1 నొక్కండి.';

  @override
  String libraryScreenNoRecordingsFor(String name) {
    return '$name కోసం ఇంకా రికార్డింగ్‌లు లేవు.';
  }

  @override
  String libraryScreenRecordingsLoadedFor(int count, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$name కోసం $count రికార్డింగ్‌లు లోడ్ అయ్యాయి.',
    );
    return '$_temp0';
  }

  @override
  String get libraryScreenLessonNoLongerAvailable =>
      'ఈ పాఠం ఇకపై అందుబాటులో లేదు. మీ సేవ్ చేసిన ప్రోగ్రెస్ మరియు బుక్‌మార్క్‌లు ఉంచబడ్డాయి.';

  @override
  String libraryScreenFailurePressRetry(String reason) {
    return '$reason మళ్లీ ప్రయత్నించడానికి 1 నొక్కండి.';
  }

  @override
  String libraryScreenSubjectNumber(String id) {
    return 'సబ్జెక్టు $id';
  }

  @override
  String get libraryScreenShowingAllSubjects =>
      'అన్ని సబ్జెక్టుల ఆడియోను చూపిస్తున్నాము';

  @override
  String libraryScreenShowingSubject(String subject, String count) {
    return '$subject ఆడియోను చూపిస్తున్నాము. $count ఫైల్‌లు';
  }

  @override
  String libraryScreenPausedAt(String position) {
    return '$position వద్ద పాజ్ చేయబడింది.';
  }

  @override
  String get libraryScreenCheckingOfflineAccess =>
      'ఇంటర్నెట్ అందుబాటులో లేదు. మీ సేవ్ చేసిన ఆఫ్‌లైన్ యాక్సెస్‌ను తనిఖీ చేస్తున్నాము.';

  @override
  String libraryScreenPlayFailedSelectAgain(String title) {
    return '$titleను ప్లే చేయలేకపోయాము. మీ కనెక్షన్‌ను తనిఖీ చేసి, దాన్ని మళ్లీ ఎంచుకోండి.';
  }

  @override
  String get libraryScreenNothingPlaying => 'ఏదీ ప్లే కావడం లేదు.';

  @override
  String libraryScreenTitleStopped(String title) {
    return '$title ఆపివేయబడింది.';
  }

  @override
  String libraryScreenNoLessonPlayingPress(String key) {
    return 'ఏ పాఠమూ ప్లే కావడం లేదు. మొదటి పాఠాన్ని ప్లే చేయడానికి $key నొక్కండి.';
  }

  @override
  String get libraryScreenSeekFailed =>
      'పాఠంలోని ఆ స్థానానికి వెళ్లలేకపోయాము. మళ్లీ ప్రయత్నించండి.';

  @override
  String get libraryScreenSlowestSpeed =>
      'ఇప్పటికే అత్యంత నెమ్మదైన వేగంలో ఉంది.';

  @override
  String get libraryScreenFastestSpeed =>
      'ఇప్పటికే అత్యంత వేగవంతమైన వేగంలో ఉంది.';

  @override
  String get libraryScreenSpeedFailed =>
      'ప్లేబ్యాక్ వేగాన్ని మార్చలేకపోయాము. మళ్లీ ప్రయత్నించండి.';

  @override
  String get libraryScreenReadFileFailed => 'ఫైల్ డేటాను చదవడం విఫలమైంది.';

  @override
  String get libraryScreenTitleFieldPlain => 'ఆడియో శీర్షిక';

  @override
  String get libraryScreenChooseSessionsName =>
      'ఈ ఆడియో కోసం సెషన్‌లను ఎంచుకోండి';

  @override
  String get libraryScreenConfirmSessionsKey =>
      'ఎంచుకున్న సెషన్‌లను నిర్ధారించండి';

  @override
  String libraryScreenSessionNumber(String id) {
    return 'సెషన్ $id';
  }

  @override
  String libraryScreenSessionSelected(String name) {
    return '$name, ఎంచుకోబడింది';
  }

  @override
  String libraryScreenSessionNotSelected(String name) {
    return '$name, ఎంచుకోబడలేదు';
  }

  @override
  String libraryScreenConfirmSelectedSessions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ఎంచుకున్న $count సెషన్‌లను నిర్ధారించండి',
    );
    return '$_temp0';
  }

  @override
  String get libraryScreenUploadCancelledNoSession =>
      'అప్‌లోడ్ రద్దు చేయబడింది. కనీసం ఒక సెషన్‌ను ఎంచుకుని, ఆడియోను మళ్లీ జోడించడానికి 3 నొక్కండి.';

  @override
  String libraryScreenUploadingWait(String title) {
    return '$title అప్‌లోడ్ అవుతోంది. దయచేసి వేచి ఉండండి; ఇది పూర్తయినప్పుడు మీకు వినిపిస్తుంది.';
  }

  @override
  String get libraryScreenClassSubjectUnknown =>
      'సెషన్ తరగతి మరియు సబ్జెక్టును గుర్తించలేకపోయాము';

  @override
  String libraryScreenUploadFailedRetry(String title) {
    return '$titleను అప్‌లోడ్ చేయలేకపోయాము. మీ కనెక్షన్‌ను తనిఖీ చేసి, మళ్లీ ప్రయత్నించడానికి 3 నొక్కండి.';
  }

  @override
  String get libraryScreenAudioFallback => 'ఆడియో';

  @override
  String get libraryScreenClassLibraryName => 'తరగతి ఆడియో లైబ్రరీ';

  @override
  String get libraryScreenClassLibrarySections =>
      'ప్లేబ్యాక్ నియంత్రణలు, బుక్‌మార్క్‌లు మరియు అభ్యాస ప్రోగ్రెస్, సబ్జెక్టు ఫిల్టర్, డౌన్‌లోడ్‌లు, రికార్డింగ్‌లు, మరియు అందుబాటులో ఉన్నప్పుడు ఉపాధ్యాయుల అప్‌లోడ్ సాధనాలు';

  @override
  String get libraryScreenSubjectFilterField => 'సబ్జెక్టు ఫిల్టర్ (కీ 2)';

  @override
  String get libraryScreenAllSubjects => 'అన్ని సబ్జెక్టులు';

  @override
  String get libraryScreenAddAudioOptionsName => 'ఆడియోను జోడించే ఎంపికలు';

  @override
  String get libraryScreenCloseAddAudioTarget =>
      'ఆడియోను జోడించే ఎంపికలను మూసివేయండి';

  @override
  String get libraryScreenUploadNewTarget =>
      'కొత్త ఫైల్‌ను అప్‌లోడ్ చేయండి, కీ 1';

  @override
  String get libraryScreenSelectExistingTarget =>
      'ఇప్పటికే ఉన్న లైబ్రరీ నుండి ఎంచుకోండి, కీ 2';

  @override
  String libraryScreenRecordingsAvailable(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count రికార్డింగ్‌లు అందుబాటులో ఉన్నాయి.',
    );
    return '$_temp0';
  }

  @override
  String libraryScreenNoRecordingsMatch(String query) {
    return '$queryకు సరిపోయే రికార్డింగ్‌లు లేవు.';
  }

  @override
  String libraryScreenRecordingsMatch(int count, String query) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$queryకు $count రికార్డింగ్‌లు సరిపోతున్నాయి.',
    );
    return '$_temp0';
  }

  @override
  String get libraryScreenNoUnlinkedRecordings =>
      'ఈ తరగతికి లింక్ చేయని రికార్డింగ్‌లు ఏవీ అందుబాటులో లేవు.';

  @override
  String libraryScreenRecordingsAvailableChoose(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count రికార్డింగ్‌లు అందుబాటులో ఉన్నాయి. ఎంచుకోవడానికి పైకి, కిందికి ఉపయోగించండి, లేదా శీర్షికతో వెతకండి.',
    );
    return '$_temp0';
  }

  @override
  String libraryScreenAddFailed(String title) {
    return '$titleను జోడించలేకపోయాము. మీ కనెక్షన్‌ను తనిఖీ చేసి మళ్లీ ప్రయత్నించండి.';
  }

  @override
  String get libraryScreenSelectExistingName =>
      'ఇప్పటికే ఉన్న ఆడియోను ఎంచుకోండి';

  @override
  String get libraryScreenSelectExistingSections =>
      'శోధన మరియు అందుబాటులో ఉన్న ప్రతి రికార్డింగ్';

  @override
  String get libraryScreenRefreshAvailableTarget =>
      'అందుబాటులో ఉన్న ఆడియోను రిఫ్రెష్ చేయండి, కీ 1';

  @override
  String get libraryScreenSearchRecordingsField =>
      'శీర్షికతో రికార్డింగ్‌లను వెతకండి. టైప్ చేయడానికి ఓకే నొక్కండి';

  @override
  String libraryScreenSearchRecordingsWithQuery(String query, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'రికార్డింగ్‌లను వెతకండి, $query. $count సరిపోలికలు',
    );
    return '$_temp0';
  }

  @override
  String libraryScreenAddToSessionTarget(String title) {
    return '$titleను ఈ సెషన్‌కు జోడించండి';
  }

  @override
  String get libraryScreenRepeatHelpTarget =>
      'ఆడియో లైబ్రరీ సహాయాన్ని మళ్లీ వినండి';

  @override
  String get playlistBack => 'వెనుకకు';

  @override
  String get playlistCancel => 'రద్దు చేయండి';

  @override
  String get playlistCreate => 'సృష్టించండి';

  @override
  String get playlistRefresh => 'రిఫ్రెష్ చేయండి';

  @override
  String playlistTeacherNone(String className, String subject) {
    return '$className, $subject కోసం ఇంకా ప్లేలిస్ట్‌లు లేవు. ఒకటి సృష్టించడానికి 2 నొక్కండి.';
  }

  @override
  String playlistTeacherLoaded(int count, String className, String subject) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ప్లేలిస్ట్‌లు',
    );
    return '$className, $subject కోసం $_temp0 లోడ్ అయ్యాయి';
  }

  @override
  String get playlistCreateClassTitle => 'తరగతి ప్లేలిస్ట్‌ను సృష్టించండి';

  @override
  String get playlistTitleField => 'ప్లేలిస్ట్ శీర్షిక';

  @override
  String get playlistCancelCreation => 'ప్లేలిస్ట్ సృష్టించడాన్ని రద్దు చేయండి';

  @override
  String get playlistCreatePlaylist => 'ప్లేలిస్ట్‌ను సృష్టించండి';

  @override
  String get playlistCreatePlaylistKey => 'ప్లేలిస్ట్‌ను సృష్టించండి';

  @override
  String get playlistRefreshPlaylists => 'ప్లేలిస్ట్‌లను రిఫ్రెష్ చేయండి';

  @override
  String playlistTeacherItemLabel(String title, String status, String count) {
    return '$title. $status. $count అంశాలు';
  }

  @override
  String playlistTeacherScreen(String className, String subject) {
    return 'తరగతి ప్లేలిస్ట్‌లు, $className, $subject';
  }

  @override
  String get playlistStatusArchived => 'ఆర్కైవ్ చేయబడింది';

  @override
  String get playlistStatusPublished => 'ప్రచురించబడింది';

  @override
  String get playlistStatusDraft => 'డ్రాఫ్ట్';

  @override
  String get playlistStudentNone =>
      'ఇంకా ప్లేలిస్ట్‌లు లేవు. ప్రైవేట్ ప్లేలిస్ట్‌ను సృష్టించడానికి 2 నొక్కండి.';

  @override
  String playlistStudentLoaded(int privateCount, int classCount) {
    String _temp0 = intl.Intl.pluralLogic(
      privateCount,
      locale: localeName,
      other: '$privateCount ప్రైవేట్ ప్లేలిస్ట్‌లు',
    );
    String _temp1 = intl.Intl.pluralLogic(
      classCount,
      locale: localeName,
      other: '$classCount తరగతి ప్లేలిస్ట్‌లు',
    );
    return '$_temp0 మరియు $_temp1 లోడ్ అయ్యాయి';
  }

  @override
  String get playlistCreatePrivate => 'ప్రైవేట్ ప్లేలిస్ట్‌ను సృష్టించండి';

  @override
  String get playlistCreatePrivateKey => 'ప్రైవేట్ ప్లేలిస్ట్‌ను సృష్టించండి';

  @override
  String playlistPrivateItemLabel(String title, String count) {
    return '$title, ప్రైవేట్, $count అంశాలు';
  }

  @override
  String playlistClassItemLabel(String title, String subject, String count) {
    return '$title, తరగతి ప్లేలిస్ట్, $subject, $count అంశాలు';
  }

  @override
  String get playlistStudentScreen =>
      'నా ప్లేలిస్ట్‌లు. ప్రైవేట్ ప్లేలిస్ట్‌లు మీకు మాత్రమే కనిపిస్తాయి.';

  @override
  String get playlistWaitBeforeNotes =>
      'స్టడీ నోట్‌లను తెరిచే ముందు ప్లేలిస్ట్ ప్లేయర్ కోసం వేచి ఉండండి.';

  @override
  String get playlistRefreshFailed =>
      'ఈ ప్లేలిస్ట్‌ను రిఫ్రెష్ చేయలేకపోయాము. మీ కనెక్షన్‌ను తనిఖీ చేసి మళ్లీ ప్రయత్నించండి. ప్రస్తుత ప్లేబ్యాక్ మరియు సేవ్ చేసిన ప్రోగ్రెస్ మార్చబడలేదు.';

  @override
  String get playlistLessonGone =>
      'ప్రస్తుత పాఠం ఇకపై ఈ ప్లేలిస్ట్‌లో అందుబాటులో లేదు. ప్లేబ్యాక్ ఆపివేయబడింది. మీ సేవ్ చేసిన ప్రోగ్రెస్ మరియు బుక్‌మార్క్‌లు ఉంచబడ్డాయి.';

  @override
  String get playlistStateArchived => 'ఆర్కైవ్ చేయబడింది';

  @override
  String get playlistStatePublished => 'ప్రచురించబడింది';

  @override
  String get playlistStateDraft => 'డ్రాఫ్ట్';

  @override
  String get playlistStatePrivate => 'ప్రైవేట్';

  @override
  String get playlistStatePublishedClass => 'ప్రచురించబడిన తరగతి ప్లేలిస్ట్';

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
      other: '$count అంశాలు',
    );
    return '$title. $className $subject. $_temp0. $state.';
  }

  @override
  String get playlistAddAudioScreen => 'ప్లేలిస్ట్‌కు ఆడియోను జోడించండి';

  @override
  String playlistItemNoLongerAvailable(String title) {
    return '$title మీ ప్రస్తుత తరగతిలో ఇకపై అందుబాటులో లేదు. మీరు దీన్ని ఈ ప్లేలిస్ట్ నుండి తీసివేయవచ్చు.';
  }

  @override
  String playlistItemPosition(String index, String total) {
    return '$totalలో అంశం $index.';
  }

  @override
  String get playlistPlayFailed =>
      'ఈ పాఠాన్ని ప్లే చేయలేకపోయాము. మీ కనెక్షన్‌ను తనిఖీ చేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String playlistPausedAt(String position) {
    return '$position వద్ద పాజ్ చేయబడింది.';
  }

  @override
  String get playlistLessonDefault => 'పాఠం';

  @override
  String get playlistSave => 'సేవ్ చేయండి';

  @override
  String get playlistRenameScreen => 'ప్లేలిస్ట్ పేరు మార్చండి';

  @override
  String get playlistCancelRename => 'పేరు మార్చడాన్ని రద్దు చేయండి';

  @override
  String get playlistSaveTitle => 'ప్లేలిస్ట్ శీర్షికను సేవ్ చేయండి';

  @override
  String get playlistAlreadyFirst => 'ఎంచుకున్న అంశం ఇప్పటికే మొదటిది.';

  @override
  String get playlistAlreadyLast => 'ఎంచుకున్న అంశం ఇప్పటికే చివరిది.';

  @override
  String playlistMoveFailed(String title) {
    return '$titleను జరపలేకపోయాం. మీ కనెక్షన్‌ను తనిఖీ చేసి మళ్లీ ప్రయత్నించండి.';
  }

  @override
  String get playlistThisPlaylist => 'ఈ ప్లేలిస్ట్';

  @override
  String playlistRemoveItemTitle(String title) {
    return '$titleను తీసివేయాలా?';
  }

  @override
  String playlistRemoveItemMessage(String title, String playlist) {
    return '$playlist నుండి $titleను తీసివేయాలా? రికార్డింగ్ మాత్రం లైబ్రరీలోనే ఉంటుంది.';
  }

  @override
  String playlistKeepItem(String title) {
    return '$titleను ఉంచండి';
  }

  @override
  String playlistRemoveItem(String title) {
    return '$titleను తీసివేయండి';
  }

  @override
  String playlistRemoveFailed(String title) {
    return '$titleను తీసివేయలేకపోయాం. మీ కనెక్షన్‌ను తనిఖీ చేసి మళ్లీ ప్రయత్నించండి.';
  }

  @override
  String playlistPublishedToClass(String title) {
    return '$title తరగతికి ప్రచురించబడింది';
  }

  @override
  String playlistReturnedToDraft(String title) {
    return '$title డ్రాఫ్ట్‌కు తిరిగి మార్చబడింది';
  }

  @override
  String playlistChangeFailed(String title) {
    return '$titleను మార్చలేకపోయాం. మీ కనెక్షన్‌ను తనిఖీ చేసి మళ్లీ ప్రయత్నించండి.';
  }

  @override
  String playlistDeleteTitle(String title) {
    return '$titleను తొలగించాలా?';
  }

  @override
  String playlistRestoreTitle(String title) {
    return '$titleను పునరుద్ధరించాలా?';
  }

  @override
  String playlistArchiveTitle(String title) {
    return '$titleను ఆర్కైవ్ చేయాలా?';
  }

  @override
  String playlistDeleteMessage(String title) {
    return 'ఇది ప్రైవేట్ ప్లేలిస్ట్ $titleను, దానిలోని వరుస అంశాలను తీసివేస్తుంది. రికార్డింగ్‌లు లైబ్రరీలోనే ఉంటాయి.';
  }

  @override
  String playlistRestoreMessage(String title) {
    return 'ఇది $titleను డ్రాఫ్ట్‌కు తిరిగి మారుస్తుంది, కాబట్టి దాన్ని మళ్లీ సవరించి ప్రచురించవచ్చు.';
  }

  @override
  String playlistArchiveMessage(String title) {
    return 'విద్యార్థులకు ఇకపై $title కనిపించదు. ఉపాధ్యాయుల చరిత్ర అలాగే ఉంటుంది.';
  }

  @override
  String playlistDeleteConfirm(String title) {
    return '$titleను తొలగించండి';
  }

  @override
  String playlistRestoreConfirm(String title) {
    return '$titleను పునరుద్ధరించండి';
  }

  @override
  String playlistArchiveConfirm(String title) {
    return '$titleను ఆర్కైవ్ చేయండి';
  }

  @override
  String playlistDeleted(String title) {
    return '$title తొలగించబడింది';
  }

  @override
  String playlistRestoredDraft(String title) {
    return '$title డ్రాఫ్ట్‌గా పునరుద్ధరించబడింది';
  }

  @override
  String playlistArchived(String title) {
    return '$title ఆర్కైవ్ చేయబడింది';
  }

  @override
  String get playlistSelectedItem => 'ఎంచుకున్న అంశం';

  @override
  String get playlistSeekFailed =>
      'పాఠంలో ఆ స్థానానికి వెళ్లలేకపోయాం. మళ్లీ ప్రయత్నించండి.';

  @override
  String get playlistRefreshPlaylist => 'ప్లేలిస్ట్‌ను రిఫ్రెష్ చేయండి';

  @override
  String get playlistWordPlaylist => 'ప్లేలిస్ట్';

  @override
  String playlistRenameLabel(String title) {
    return '$title పేరు మార్చండి';
  }

  @override
  String get playlistAddAudioLabel => 'ఆడియో జోడించండి, కీ 2';

  @override
  String playlistPauseLabel(String title, String key) {
    return '$titleను పాజ్ చేయండి, కీ $key';
  }

  @override
  String playlistPlayLabel(String title, String key) {
    return '$titleను ప్లే చేయండి, కీ $key';
  }

  @override
  String get playlistPreviousLabel => 'మునుపటి అంశం, కీ 3';

  @override
  String get playlistNextLabel => 'తదుపరి అంశం, కీ 8';

  @override
  String playlistReturnToDraftLabel(String title) {
    return '$titleను డ్రాఫ్ట్‌కు తిరిగి మార్చండి';
  }

  @override
  String playlistPublishLabel(String title) {
    return '$titleను తరగతికి ప్రచురించండి';
  }

  @override
  String playlistRestoreLabel(String title) {
    return '$titleను పునరుద్ధరించండి';
  }

  @override
  String playlistArchiveLabel(String title) {
    return '$titleను ఆర్కైవ్ చేయండి, నిర్ధారణ అడుగుతుంది';
  }

  @override
  String playlistDeleteLabel(String title) {
    return '$titleను తొలగించండి, నిర్ధారణ అడుగుతుంది';
  }

  @override
  String playlistSeekLabel(String position) {
    return 'పాఠం స్థానం $position. 10 సెకన్లు జరపడానికి ఎడమ లేదా కుడి ఉపయోగించండి';
  }

  @override
  String get playlistDownloadsLabel =>
      'ప్లేలిస్ట్ రికార్డింగ్‌లను డౌన్‌లోడ్ చేయండి. ఒక్కొక్కటిగా ఎంచుకోండి లేదా జాబితాలోని అన్ని రికార్డింగ్‌లను నిర్ధారించండి';

  @override
  String playlistMoveUpLabel(String title) {
    return '$titleను పైకి జరపండి';
  }

  @override
  String playlistMoveDownLabel(String title) {
    return '$titleను కిందికి జరపండి';
  }

  @override
  String playlistRemoveItemLabel(String title) {
    return '$titleను ప్లేలిస్ట్ నుండి తీసివేయండి, నిర్ధారణ అడుగుతుంది';
  }

  @override
  String get playlistItemUnavailableInClass =>
      'మీ ప్రస్తుత తరగతిలో అందుబాటులో లేదు';

  @override
  String get playlistItemSelected => 'ఎంచుకోబడింది';

  @override
  String get playlistItemPlaying => 'ప్లే అవుతోంది';

  @override
  String get playlistItemSelectedPaused => 'ఎంచుకోబడింది, పాజ్ చేయబడింది';

  @override
  String get playlistAddAudioKey => 'ఆడియో జోడించు';

  @override
  String get playlistPreviousItem => 'మునుపటి అంశం';

  @override
  String get playlistNextItem => 'తదుపరి అంశం';

  @override
  String get playlistScreenDefault => 'ప్లేలిస్ట్';

  @override
  String playlistScreen(String title) {
    return '$title ప్లేలిస్ట్';
  }

  @override
  String playlistItemUnavailable(String title) {
    return '$title మీ ప్రస్తుత తరగతిలో అందుబాటులో లేదు';
  }

  @override
  String get notesNoRecordingActive => 'ఏ రికార్డింగ్ జరగడం లేదు.';

  @override
  String get notesMicCouldNotRecord =>
      'మైక్రోఫోన్ ఈ నోట్‌ను రికార్డ్ చేయలేకపోయింది.';

  @override
  String get notesRecordingNotConfirmed =>
      'రికార్డింగ్ నిర్ధారించబడలేదు. దాని అసంపూర్ణ ఫైల్‌లు ఉంచబడ్డాయి. మైక్రోఫోన్ అనుమతిని, స్టోరేజ్‌ను తనిఖీ చేయండి.';

  @override
  String get notesLeaveLiveSession =>
      'రికార్డ్ చేసే ముందు లైవ్ సెషన్ నుండి బయటకు వచ్చి ప్రైవేట్ నోట్‌లను తెరవండి.';

  @override
  String get notesMicPermissionDenied =>
      'మైక్రోఫోన్ అనుమతి ఇవ్వలేదు. రికార్డింగ్ ప్రారంభం కాలేదు. Android సెట్టింగ్‌లలో దాన్ని ఆన్ చేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get notesRecordingCancelledChanged =>
      'స్క్రీన్ లేదా యాప్ మారినందున రికార్డింగ్ రద్దు చేయబడింది. సిద్ధంగా ఉన్నప్పుడు మళ్లీ ప్రారంభించండి.';

  @override
  String get notesSpeechDidNotStop =>
      'యాప్ స్వరం ఆగలేదు. రికార్డ్ చేసే ముందు TTS ఇంజిన్‌ను తనిఖీ చేయండి.';

  @override
  String get notesRecordingDidNotStart =>
      'యాప్ మారినందున రికార్డింగ్ ప్రారంభం కాలేదు. దాని ఖాళీ డ్రాఫ్ట్ ఎంచుకుని తీసివేయడం కోసం ఉంచబడింది.';

  @override
  String get notesAnotherRecorderStopping =>
      'మరో ప్రైవేట్ రికార్డర్ ఇంకా ఆగుతోంది. రికార్డ్ చేసే ముందు దానికి తిరిగి వెళ్లండి లేదా యాప్‌ను బ్యాక్‌గ్రౌండ్‌కు పంపండి.';

  @override
  String get notesNativeStartNotConfirmed =>
      'ఫోన్ రికార్డర్ ప్రారంభమైనట్లు నిర్ధారించలేదు. డ్రాఫ్ట్ ఉంచబడింది.';

  @override
  String get notesNativeStopNotConfirmed =>
      'ఫోన్ రికార్డింగ్ ఆగినట్లు నిర్ధారించబడలేదు. మళ్లీ ప్రయత్నించే ముందు రికార్డింగ్ ఆపడానికి యాప్‌ను బ్యాక్‌గ్రౌండ్‌కు పంపండి.';

  @override
  String get notesDurationUnreadable =>
      'రికార్డర్ నిడివిని చదవలేకపోయాం. దాని అసంపూర్ణ ఫైల్ ఉంచబడింది.';

  @override
  String get notesRecordingInProgress =>
      'రికార్డ్ అవుతోంది. యాప్ నియంత్రణలకు మాట్లాడే ముందు ఆపండి. గరిష్టంగా ఐదు నిమిషాలు; యాప్ మాట్లాడినా లేదా అంతరాయం కలిగినా ఆగిపోతుంది.';

  @override
  String get notesNativeCaptureStopped =>
      'ఫోన్ రికార్డింగ్ ఆగిపోయింది. పూర్తికాని డ్రాఫ్ట్ ఏదైనా ఎంచుకుని తీసివేయడం కోసం ఉంచబడింది.';

  @override
  String get notesRecorderStopNotConfirmed =>
      'రికార్డర్ ఆగినట్లు నిర్ధారించబడలేదు. మళ్లీ ప్రయత్నించే ముందు ఫోన్ రికార్డింగ్ ఆపడానికి ఈ స్క్రీన్ నుండి బయటకు వెళ్లండి లేదా యాప్‌ను బ్యాక్‌గ్రౌండ్‌కు పంపండి.';

  @override
  String get notesRecorderFailed =>
      'రికార్డర్ విఫలమైంది. దాని అసంపూర్ణ ఫైల్ ఎంచుకుని తీసివేయడం కోసం ఉంచబడింది.';

  @override
  String get notesNotFinalized =>
      'రికార్డింగ్ ఆగింది, కానీ నోట్‌ను పూర్తి చేయలేకపోయాం. ఫైల్‌లు ఎంచుకుని తీసివేయడం కోసం ఉంచబడ్డాయి.';

  @override
  String get notesRecordingLimitReached => 'రికార్డింగ్ పరిమితి చేరుకుంది.';

  @override
  String get notesRecordingInterrupted => 'రికార్డింగ్‌కు అంతరాయం కలిగింది.';

  @override
  String get notesRecordingStopped => 'రికార్డింగ్ ఆగింది.';

  @override
  String get notesSavedOnPhone =>
      'ప్రైవేట్ నోట్ ఈ ఫోన్‌లో సేవ్ చేయబడింది. ప్రచురించే లేదా షేర్ చేసే ముందు సమీక్షించండి.';

  @override
  String get notesSignInFirst =>
      'ప్రైవేట్ నోట్‌లను తెరవడానికి ముందు సైన్ ఇన్ చేయండి.';

  @override
  String get notesInvalidIdentity => 'నోట్ గుర్తింపు చెల్లదు.';

  @override
  String get notesAccountChanged =>
      'మీ ఖాతా మారింది. ప్రైవేట్ నోట్‌లను మళ్లీ తెరవండి.';

  @override
  String get notesStorageUnavailable =>
      'ప్రైవేట్ నోట్ స్టోరేజ్ అందుబాటులో లేదు. ఖాళీ స్థలాన్ని తనిఖీ చేసి మళ్లీ ప్రయత్నించండి. ఇప్పటికే ఉన్న ఫైల్‌లు ఉంచబడ్డాయి.';

  @override
  String get notesInvalidNameOrPosition =>
      '160 అక్షరాల వరకు ఉండే నోట్ పేరును, సరైన పాఠం స్థానాన్ని నమోదు చేయండి.';

  @override
  String get notesAllowanceFull =>
      'మీ ప్రైవేట్ నోట్ పరిమితి నిండిపోయింది. రికార్డ్ చేసే ముందు మీరు ఎంచుకున్న ఒక నోట్‌ను తీసివేయండి. ఏ నోట్ తొలగించబడలేదు.';

  @override
  String get notesInterruptedOrInvalid =>
      'నోట్‌కు అంతరాయం కలిగింది లేదా దాని నిడివి చెల్లదు. దాని ఫైల్‌లు ఎంచుకుని తీసివేయడం కోసం ఉంచబడ్డాయి.';

  @override
  String get notesEmptyOrTooLarge =>
      'ఈ రికార్డింగ్ ఖాళీగా ఉంది లేదా ప్రైవేట్ నోట్ పరిమితిని మించిపోయింది. దాని అసంపూర్ణ ఫైల్ ఉంచబడింది; స్టోరేజ్‌ను సమీక్షించి ఎంచుకున్న రికార్డింగ్‌ను తీసివేయండి.';

  @override
  String get notesIncompleteUnavailable =>
      'ఈ నోట్ అసంపూర్ణంగా ఉంది లేదా అందుబాటులో లేదు. ఇది తొలగించబడలేదు.';

  @override
  String get notesInvalidName =>
      '160 అక్షరాల వరకు ఉండే నోట్ పేరును నమోదు చేయండి.';

  @override
  String notesUnreadableTitle(String id) {
    return 'చదవలేని నోట్ $id';
  }

  @override
  String get notesRecordUnreadable =>
      'ఈ నోట్ రికార్డ్‌ను చదవలేము. దాని ఫైల్‌లు ఉంచబడ్డాయి; మీరు స్పష్టంగా ఎంచుకుని తీసివేస్తేనే అవి మారుతాయి.';

  @override
  String notesInterruptedTitle(String id) {
    return 'అంతరాయం కలిగిన రికార్డింగ్ $id';
  }

  @override
  String get notesMetadataMissing =>
      'రికార్డింగ్ వివరాలు లేవు. ఫైల్ ఎంచుకుని తీసివేయడం కోసం ఉంచబడింది.';

  @override
  String get learningSavedLessonInvalid =>
      'సేవ్ చేసిన పాఠం సమాచారం చెల్లదు. మీ సేవ్ చేసిన డేటా మార్చబడలేదు.';

  @override
  String get learningSavedBookmarkUnreadable =>
      'సేవ్ చేసిన ఒక బుక్‌మార్క్‌ను చదవలేకపోయాం. మీ సేవ్ చేసిన డేటా మార్చబడలేదు.';

  @override
  String get learningSavedBookmarkIdsInvalid =>
      'సేవ్ చేసిన బుక్‌మార్క్ గుర్తింపులు చెల్లవు. మీ సేవ్ చేసిన డేటా మార్చబడలేదు.';

  @override
  String get learningSavedRepeatInvalid =>
      'సేవ్ చేసిన రిపీట్ హద్దులు చెల్లవు. మీ సేవ్ చేసిన డేటా మార్చబడలేదు.';

  @override
  String get learningSignInFirst =>
      'సేవ్ చేసిన అభ్యాస పురోగతిని ఉపయోగించే ముందు సైన్ ఇన్ చేయండి.';

  @override
  String get learningAccountChanged =>
      'మీ ఖాతా మారింది. అభ్యాస లైబ్రరీని మళ్లీ తెరవండి.';

  @override
  String get learningUnsupportedFormat =>
      'సేవ్ చేసిన అభ్యాస డేటా మద్దతు లేని ఫార్మాట్ లేదా ఖాతాకు చెందినది. మీ సేవ్ చేసిన డేటా మార్చబడలేదు.';

  @override
  String get learningIdentityMismatch =>
      'సేవ్ చేసిన పాఠం గుర్తింపు సరిపోలడం లేదు. మీ సేవ్ చేసిన డేటా మార్చబడలేదు.';

  @override
  String get learningDataUnreadable =>
      'సేవ్ చేసిన అభ్యాస డేటాను చదవలేకపోయాం. మీ సేవ్ చేసిన డేటా మార్చబడలేదు.';

  @override
  String get learningStorageUnavailableFreeSpace =>
      'అభ్యాస స్టోరేజ్ అందుబాటులో లేదు. ఖాళీ స్థలాన్ని తనిఖీ చేసి మళ్లీ ప్రయత్నించండి. మీ సేవ్ చేసిన డేటా ఉద్దేశపూర్వకంగా తీసివేయబడలేదు.';

  @override
  String get learningStorageUnavailable =>
      'అభ్యాస స్టోరేజ్ అందుబాటులో లేదు. స్టోరేజ్‌ను తనిఖీ చేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get learningSaveFailed =>
      'అభ్యాస పురోగతిని సేవ్ చేయలేకపోయాం. ఖాళీ స్థలాన్ని తనిఖీ చేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get learningProgressUnavailable =>
      'సేవ్ చేసిన అభ్యాస పురోగతి అందుబాటులో లేదు. స్టోరేజ్‌ను తనిఖీ చేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get learningStartLessonFirst =>
      'బుక్‌మార్క్‌లు లేదా రిపీట్ పాయింట్‌లు జోడించే ముందు ఈ పాఠాన్ని ప్రారంభించండి.';

  @override
  String learningSavedFieldUnreadable(String field) {
    return 'సేవ్ చేసిన $fieldను చదవలేకపోయాం. మీ సేవ్ చేసిన డేటా మార్చబడలేదు.';
  }

  @override
  String get learningFieldBookmarkId => 'బుక్‌మార్క్ ఐడి';

  @override
  String get learningFieldBookmarkLabel => 'బుక్‌మార్క్ పేరు';

  @override
  String get learningFieldBookmarkPosition => 'బుక్‌మార్క్ స్థానం';

  @override
  String get learningFieldUpdateTime => 'అప్‌డేట్ సమయం';

  @override
  String get learningFieldNextBookmarkId => 'తదుపరి బుక్‌మార్క్ ఐడి';

  @override
  String get learningFieldLessonId => 'పాఠం ఐడి';

  @override
  String get learningFieldLessonTitle => 'పాఠం పేరు';

  @override
  String get learningFieldPosition => 'స్థానం';

  @override
  String get learningInvalidProgress => 'పాఠం పురోగతి చెల్లదు';

  @override
  String get learningBookmarkNeedsPositionLabel =>
      'బుక్‌మార్క్‌కు సరైన స్థానం, పేరు అవసరం';

  @override
  String get learningBookmarkExceedsDuration =>
      'బుక్‌మార్క్ స్థానం పాఠం నిడివిని మించిపోయింది';

  @override
  String learningDefaultBookmarkLabel(String number) {
    return 'బుక్‌మార్క్ $number';
  }

  @override
  String get learningBookmarkNotFound => 'బుక్‌మార్క్ కనుగొనబడలేదు';

  @override
  String get learningRepeatEndAfterStart =>
      'ముగింపు పాయింట్‌ను ప్రారంభ పాయింట్ తర్వాత సెట్ చేయండి';

  @override
  String get learningRepeatExceedsDuration =>
      'రిపీట్ పాయింట్‌లు పాఠం నిడివిని మించిపోయాయి';

  @override
  String get learningSavedProgressUnavailableTitle =>
      'సేవ్ చేసిన పురోగతి అందుబాటులో లేదు';

  @override
  String get learningListenWithoutSavedPrompt =>
      'సేవ్ చేసిన డేటాను మార్చకుండా మొదటి నుండి వినాలా? మీరు మళ్లీ ప్రయత్నించి విజయవంతమయ్యే వరకు సేవ్ చేయడం ఆఫ్‌లో ఉంటుంది.';

  @override
  String get learningListenFromBeginning => 'మొదటి నుండి వినండి';

  @override
  String get learningRecordedLesson => 'రికార్డ్ చేసిన పాఠం';

  @override
  String learningStatusPosition(String position) {
    return 'స్థానం $position.';
  }

  @override
  String learningSpeedTimes(String speed) {
    return 'వేగం $speed రెట్లు.';
  }

  @override
  String learningStatusBookmarks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count బుక్‌మార్క్‌లు',
    );
    return '$_temp0';
  }

  @override
  String learningStatusRepeat(String state) {
    return 'A-B రిపీట్ $state.';
  }

  @override
  String learningStatusSaving(String state) {
    return 'పురోగతి సేవ్ చేయడం $state.';
  }

  @override
  String get learningNoLessonLoaded =>
      'ఏ పాఠం లోడ్ కాలేదు. ముందుగా ప్లే చేయడానికి ఒక పాఠాన్ని ఎంచుకోండి.';

  @override
  String get learningSlowestSpeed => 'ఇప్పటికే అత్యంత నెమ్మది వేగంలో ఉంది.';

  @override
  String get learningFastestSpeed => 'ఇప్పటికే అత్యంత వేగంలో ఉంది.';

  @override
  String get learningCheckPosition =>
      'పాఠం స్థానాన్ని తనిఖీ చేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get learningPlayerActionFailed =>
      'ప్లేయర్ ఈ చర్యను పూర్తి చేయలేకపోయింది. ప్లేబ్యాక్‌ను తనిఖీ చేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String learningBookmarkSavedAt(String time) {
    return 'బుక్‌మార్క్ $time వద్ద సేవ్ చేయబడింది.';
  }

  @override
  String learningReadStatusLabel(String status) {
    return 'అభ్యాస స్థితిని చదవండి. $status';
  }

  @override
  String learningAddBookmarkAt(String time) {
    return '$time వద్ద బుక్‌మార్క్ జోడించండి';
  }

  @override
  String learningBookmarksSavedPoints(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'బుక్‌మార్క్‌లు. $count సేవ్ చేసిన పాయింట్‌లు',
    );
    return '$_temp0';
  }

  @override
  String learningPrivateNotesAt(String time) {
    return '$time వద్ద ప్రైవేట్ స్టడీ నోట్‌లు. తెరిచే ముందు పాఠాన్ని పాజ్ చేయండి';
  }

  @override
  String get learningSetRepeatStartLabel =>
      'ప్రస్తుత స్థానంలో రిపీట్ ప్రారంభం A సెట్ చేయండి';

  @override
  String learningRepeatStartSet(String time) {
    return 'రిపీట్ ప్రారంభం $time వద్ద సెట్ చేయబడింది.';
  }

  @override
  String get learningSetRepeatEndLabel =>
      'ప్రారంభం A తర్వాత రిపీట్ ముగింపు B సెట్ చేయండి';

  @override
  String learningRepeatEndSet(String time) {
    return 'రిపీట్ ముగింపు $time వద్ద సెట్ చేయబడింది. మళ్లీ మళ్లీ ప్లే చేయడానికి రిపీట్ ఆన్ ఎంచుకోండి.';
  }

  @override
  String get learningTurnRepeatOff => 'A-B రిపీట్ ఆఫ్ చేయండి';

  @override
  String get learningTurnRepeatOn => 'A-B రిపీట్ ఆన్ చేయండి';

  @override
  String get learningClearRepeatLabel =>
      'సేవ్ చేసిన A-B రిపీట్ పాయింట్‌లను తీసివేయండి';

  @override
  String get learningRepeatCleared => 'A-B రిపీట్ పాయింట్‌లు తీసివేయబడ్డాయి.';

  @override
  String learningBackTenLabel(String key) {
    return '10 సెకన్లు వెనక్కి, కీ $key';
  }

  @override
  String learningForwardTenLabel(String key) {
    return '10 సెకన్లు ముందుకు, కీ $key';
  }

  @override
  String learningSlowerLabel(String key, String speed) {
    return 'నెమ్మదిగా, కీ $key. ఇప్పుడు $speed రెట్లు';
  }

  @override
  String learningFasterLabel(String key, String speed) {
    return 'వేగంగా, కీ $key. ఇప్పుడు $speed రెట్లు';
  }

  @override
  String learningRetrySavingLabel(String issue) {
    return 'అభ్యాస పురోగతిని సేవ్ చేయడానికి మళ్లీ ప్రయత్నించండి. $issue';
  }

  @override
  String get learningProgressSaved => 'అభ్యాస పురోగతి సేవ్ చేయబడింది.';

  @override
  String get learningEnterBookmarkName => 'బుక్‌మార్క్ పేరును నమోదు చేయండి.';

  @override
  String get learningNameBookmarkScreen =>
      'బుక్‌మార్క్‌కు పేరు పెట్టండి. సవరించడానికి ఓకే నొక్కండి. పైకి లేదా కిందికి నొక్కితే సవరణ నుండి బయటకు వస్తారు.';

  @override
  String get learningEditName => 'పేరు సవరించండి';

  @override
  String get learningSaveBookmark => 'బుక్‌మార్క్ సేవ్ చేయండి';

  @override
  String get learningBookmarkNameField => 'బుక్‌మార్క్ పేరు';

  @override
  String learningBookmarkJumped(String label, String position) {
    return '$label. స్థానం $position.';
  }

  @override
  String get learningRemoveBookmarkTitle => 'బుక్‌మార్క్‌ను తీసివేయాలా?';

  @override
  String learningRemoveBookmarkMessage(String label) {
    return '$labelను తీసివేయాలా? దీనివల్ల పాఠం గానీ ఇతర బుక్‌మార్క్‌లు గానీ తీసివేయబడవు.';
  }

  @override
  String get learningKeepBookmark => 'బుక్‌మార్క్ ఉంచండి';

  @override
  String get learningRemoveBookmark => 'బుక్‌మార్క్ తీసివేయండి';

  @override
  String learningBookmarkRemoved(String label) {
    return '$label తీసివేయబడింది.';
  }

  @override
  String get learningBookmarksScreen =>
      'బుక్‌మార్క్‌లు. వెళ్లడానికి ఒక పాయింట్‌ను ఎంచుకోండి. ఇది పాజ్ చేసిన ప్లేబ్యాక్‌ను ప్రారంభించదు. తీసివేయడానికి నిర్ధారణ అడుగుతుంది.';

  @override
  String get learningCloseBookmarks => 'బుక్‌మార్క్‌లను మూసివేయండి';

  @override
  String learningJumpToBookmarkLabel(String label, String time) {
    return '$label. $time. బుక్‌మార్క్‌కు వెళ్లండి';
  }

  @override
  String learningRemoveBookmarkLabel(String label) {
    return '$labelను తీసివేయండి';
  }

  @override
  String get dashboardRefreshing => 'సెషన్‌లను రిఫ్రెష్ చేస్తోంది.';

  @override
  String get dashboardShowMatching => 'సరిపోలే సెషన్‌లను చూపించండి';

  @override
  String get dashboardLogout => 'లాగ్ అవుట్, నిర్ధారణ అడుగుతుంది';

  @override
  String get dashboardRefresh => 'సెషన్‌లను రిఫ్రెష్ చేయండి';

  @override
  String get dashboardLibraryWhat => 'రికార్డ్ చేసిన ఆడియో లైబ్రరీ';

  @override
  String get dashboardQuizzesWhat => 'క్విజ్‌లు';

  @override
  String dashboardSessions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count సెషన్‌లు',
      one: '1 సెషన్',
    );
    return '$_temp0';
  }

  @override
  String dashboardPosition(String index, String total) {
    return '$total లో $index';
  }

  @override
  String get dashboardStudentScreen => 'విద్యార్థి డ్యాష్‌బోర్డ్';

  @override
  String get dashboardStudentLoading =>
      'విద్యార్థి డ్యాష్‌బోర్డ్ లోడ్ అవుతోంది';

  @override
  String get dashboardStudentSections =>
      'రిఫ్రెష్, సెషన్ వెతుకులాట, లైవ్ సెషన్‌లు, రికార్డ్ చేసిన పాఠాలు, ప్లేలిస్ట్‌లు, క్విజ్‌లు, అభ్యాస ప్రయాణాలు, మరియు లాగ్ అవుట్';

  @override
  String get dashboardNoLiveSessions =>
      'ఇప్పుడు లైవ్ సెషన్‌లు ఏవీ లేవు. రిఫ్రెష్ చేయడానికి 1 నొక్కండి.';

  @override
  String get dashboardNoFilterMatch =>
      'మీ ఫిల్టర్‌కు సరిపోయే సెషన్‌లు ఏవీ లేవు.';

  @override
  String get dashboardNoMatchVisible =>
      'సరిపోయే సెషన్‌లు లేవు. వెతుకులాటను క్లియర్ చేయండి లేదా సబ్జెక్టు ఫిల్టర్‌ను మార్చండి.';

  @override
  String dashboardAvailable(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count సెషన్‌లు అందుబాటులో ఉన్నాయి.',
      one: '1 సెషన్ అందుబాటులో ఉంది.',
    );
    return '$_temp0';
  }

  @override
  String dashboardAvailableDetailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count సెషన్‌లు అందుబాటులో ఉన్నాయి. చూడటానికి కిందికి వెళ్ళండి.',
      one: '1 సెషన్ అందుబాటులో ఉంది. చూడటానికి కిందికి వెళ్ళండి.',
    );
    return '$_temp0';
  }

  @override
  String dashboardRefreshFailed(String reason) {
    return '$reason మళ్ళీ ప్రయత్నించడానికి 1 నొక్కండి.';
  }

  @override
  String get dashboardJoining => 'సెషన్‌లో చేరుతోంది.';

  @override
  String dashboardJoined(String session) {
    return '$sessionలో చేరారు.';
  }

  @override
  String get dashboardOpeningPlaylists =>
      'నా ప్లేలిస్ట్‌లు తెరుస్తోంది. ఈ ప్లేలిస్ట్‌లు ప్రైవేట్.';

  @override
  String get dashboardSessionSearchHelp =>
      'సెషన్ వెతుకులాట. సెషన్ నంబర్ టైప్ చేయడానికి ఓకే నొక్కండి, తర్వాత కిందికి వెళ్ళి సరిపోయే సెషన్‌లను చూపించు వద్ద ఓకే నొక్కండి. మీరు పేరుతో కూడా వెతకవచ్చు.';

  @override
  String get dashboardSessionNumberFieldEmpty =>
      'సెషన్ నంబర్ ఫీల్డ్. ఒక నంబర్ టైప్ చేసి, తర్వాత సరిపోయే సెషన్‌లను చూపించు ఎంచుకోండి';

  @override
  String dashboardSessionNumberField(String digits) {
    return 'సెషన్ నంబర్ ఫీల్డ్, $digits';
  }

  @override
  String get dashboardNameField => 'పేరుతో సెషన్‌లను వెతకండి';

  @override
  String dashboardNoSessionNumber(String digits) {
    return '$digits నంబర్ గల లైవ్ సెషన్ లేదు.';
  }

  @override
  String dashboardFound(String label) {
    return 'దొరికింది: $label. చేరడానికి ఓకే నొక్కండి.';
  }

  @override
  String dashboardNoNameMatch(String query) {
    return '$queryకు సరిపోయే సెషన్‌లు ఏవీ లేవు.';
  }

  @override
  String dashboardShowingAll(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'మొత్తం $count సెషన్‌లు చూపిస్తోంది.',
      one: 'మొత్తం 1 సెషన్ చూపిస్తోంది.',
    );
    return '$_temp0';
  }

  @override
  String dashboardShowingAllDetailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'మొత్తం $count సెషన్‌లు చూపిస్తోంది. చూడటానికి కిందికి వెళ్ళండి.',
      one: 'మొత్తం 1 సెషన్ చూపిస్తోంది. చూడటానికి కిందికి వెళ్ళండి.',
    );
    return '$_temp0';
  }

  @override
  String dashboardNameMatches(int count, String query) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$queryకు $count సెషన్‌లు సరిపోతున్నాయి. చూడటానికి కిందికి వెళ్ళండి.',
      one: '$queryకు 1 సెషన్ సరిపోతుంది. చూడటానికి కిందికి వెళ్ళండి.',
    );
    return '$_temp0';
  }

  @override
  String get dashboardAllSubjects => 'అన్ని సబ్జెక్టులు';

  @override
  String dashboardSubjectFilterLabel(String subject, String position) {
    return 'సబ్జెక్టు ఫిల్టర్: $subject, $position. మార్చడానికి ఎడమ లేదా కుడి నొక్కండి';
  }

  @override
  String dashboardSubjectFilterChanged(
    String subject,
    String position,
    String summary,
  ) {
    return 'సబ్జెక్టు ఫిల్టర్: $subject, $position. $summary';
  }

  @override
  String get dashboardLibrary => 'రికార్డ్ చేసిన ఆడియో లైబ్రరీ';

  @override
  String get dashboardPlaylists => 'నా ప్రైవేట్ ప్లేలిస్ట్‌లు';

  @override
  String get dashboardQuizzes => 'క్విజ్‌లు';

  @override
  String get dashboardStudentJourneys =>
      'అభ్యాస ప్రయాణాలు: వినండి, జవాబు ఇవ్వండి, మళ్ళీ చేయండి, ఆఫ్‌లైన్‌లో కూడా పనిచేస్తుంది';

  @override
  String dashboardTeacherName(String name) {
    return 'ఉపాధ్యాయులు $name';
  }

  @override
  String get dashboardLiveNow => 'ఇప్పుడు లైవ్‌లో ఉంది';

  @override
  String get dashboardStateRefreshing => 'రిఫ్రెష్ చేస్తోంది.';

  @override
  String dashboardStateLiveSessions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count లైవ్ సెషన్‌లు.',
      one: '1 లైవ్ సెషన్.',
    );
    return '$_temp0';
  }

  @override
  String dashboardStateSubjectFilter(String subject) {
    return 'సబ్జెక్టు ఫిల్టర్: $subject.';
  }

  @override
  String dashboardStateSessionNumber(String digits) {
    return 'టైప్ చేసిన సెషన్ నంబర్: $digits.';
  }

  @override
  String dashboardStateNameSearch(String query) {
    return 'పేరు వెతుకులాట: $query.';
  }

  @override
  String dashboardStateShown(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count సెషన్‌లు చూపబడ్డాయి.',
      one: '1 సెషన్ చూపబడింది.',
    );
    return '$_temp0';
  }

  @override
  String get dashboardTeacherScreen => 'ఉపాధ్యాయుల డాష్‌బోర్డ్';

  @override
  String get dashboardTeacherLoading => 'ఉపాధ్యాయుల డాష్‌బోర్డ్ లోడ్ అవుతోంది';

  @override
  String get dashboardTeacherSections =>
      'తరగతి మరియు సబ్జెక్టు ఎంపిక, బోధన సాధనాలు, సెషన్ వెతుకులాట, మరియు యాక్టివ్ లేదా ముగిసిన సెషన్‌లు';

  @override
  String get dashboardNoSessionsYet =>
      'ఇంకా సెషన్‌లు లేవు. ఒకటి సృష్టించడానికి 2 నొక్కండి.';

  @override
  String get dashboardNoTeacherMatch =>
      'సరిపోయే సెషన్‌లు లేవు. అన్ని సెషన్‌లను చూడటానికి వెతుకులాటను క్లియర్ చేయండి.';

  @override
  String dashboardTeacherCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count సెషన్‌లు.',
      one: '1 సెషన్.',
    );
    return '$_temp0';
  }

  @override
  String dashboardTeacherCountLive(int count, String live) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count సెషన్‌లు, $live ఇప్పుడు లైవ్‌లో ఉన్నాయి.',
      one: '1 సెషన్, $live ఇప్పుడు లైవ్‌లో ఉంది.',
    );
    return '$_temp0';
  }

  @override
  String dashboardNotRefreshed(String reason) {
    return '$reason సెషన్‌లు రిఫ్రెష్ కాలేదు. మళ్ళీ ప్రయత్నించడానికి 1 నొక్కండి.';
  }

  @override
  String get dashboardNoAssignment =>
      'మీకు ఏ తరగతి, సబ్జెక్టు కేటాయించబడలేదు. ఒకటి కేటాయించమని నిర్వాహకులను అడగండి.';

  @override
  String get dashboardCreatingSession => 'సెషన్ సృష్టిస్తోంది';

  @override
  String dashboardCreated(String title) {
    return '$title సెషన్ సృష్టించబడింది.';
  }

  @override
  String get dashboardCreatedTitle => 'సెషన్ సృష్టించబడింది';

  @override
  String dashboardStartNow(String title) {
    return '\"$title\"ను ఇప్పుడే ప్రారంభించాలా?';
  }

  @override
  String get dashboardRequestFailed =>
      'ఆ అభ్యర్థనను పూర్తి చేయలేకపోయాము. మీ కనెక్షన్ చెక్ చేసి మళ్ళీ ప్రయత్నించండి.';

  @override
  String get dashboardOpeningSession => 'సెషన్ తెరుస్తోంది.';

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
    return 'వర్క్‌స్పేస్: $name, $position. $status';
  }

  @override
  String dashboardWorkspaceChosen(String name, String status) {
    return '$name ఎంచుకోబడింది. $status వేరే వర్క్‌స్పేస్ ఎంచుకోవడానికి 7 నొక్కండి.';
  }

  @override
  String get dashboardChooseWorkspaceTitle => 'తరగతి మరియు సబ్జెక్టు ఎంచుకోండి';

  @override
  String get dashboardNoWorkspace =>
      'తరగతి మరియు సబ్జెక్టు వర్క్‌స్పేస్ ఏదీ కేటాయించబడలేదు';

  @override
  String dashboardWorkspaceLabel(String name, String position) {
    return 'వర్క్‌స్పేస్: $name, $position. మార్చడానికి ఎడమ లేదా కుడి, నంబర్ల జాబితా కోసం ఓకే లేదా 7';
  }

  @override
  String get dashboardCreate => 'కొత్త సెషన్ సృష్టించండి';

  @override
  String get dashboardClassPlaylists => 'తరగతి ప్లేలిస్ట్‌లు';

  @override
  String get dashboardTeacherJourneys =>
      'అభ్యాస ప్రయాణాలు: రికార్డింగ్‌లు, ప్రశ్నలు మరియు పోల్‌లు ఒకే వరుసలో';

  @override
  String get dashboardTeacherQuizzes =>
      'క్విజ్‌లు మరియు ప్రైవేట్ ప్రశ్నల బ్యాంక్';

  @override
  String get dashboardOfflineLibrary => 'ఆఫ్‌లైన్ ఆడియో లైబ్రరీ';

  @override
  String get dashboardSearchField =>
      'సెషన్‌లను వెతకండి. ఓకే నొక్కి, తర్వాత పేరు లేదా సెషన్ నంబర్ టైప్ చేయండి';

  @override
  String get dashboardTeacherSearchHelp =>
      'సెషన్ వెతుకులాట. మార్చడానికి ఓకే నొక్కండి, తర్వాత సెషన్ పేరు టైప్ చేయండి, లేదా నంబర్ కీలతో సెషన్ నంబర్ టైప్ చేయండి. ఫీల్డ్ నుండి బయటకు వచ్చి ఫలితాలు చూడటానికి పైకి లేదా కిందికి వెళ్ళండి.';

  @override
  String dashboardTeacherNoMatch(String query) {
    return '$queryకు సరిపోయే సెషన్‌లు ఏవీ లేవు. అన్ని సెషన్‌లను చూడటానికి వెతుకులాటను క్లియర్ చేయండి.';
  }

  @override
  String get dashboardEnded => 'ముగిసింది';

  @override
  String dashboardJoinedCount(String count) {
    return '$count మంది చేరారు';
  }

  @override
  String get dashboardPressOkToOpen => 'తెరవడానికి ఓకే నొక్కండి';

  @override
  String get dashboardPressOkToReactivate =>
      'మళ్ళీ యాక్టివ్ చేయడానికి ఓకే నొక్కండి';

  @override
  String dashboardEndLabel(String title) {
    return 'అందరికీ $titleను ముగించండి, నిర్ధారణ అడుగుతుంది';
  }

  @override
  String dashboardDeleteLabel(String title) {
    return 'ముగిసిన సెషన్ $titleను శాశ్వతంగా తొలగించండి, నిర్ధారణ అడుగుతుంది';
  }

  @override
  String get dashboardEndTitle => 'అందరికీ సెషన్ ముగించాలా?';

  @override
  String dashboardEndMessage(String title) {
    return '\"$title\"ను ముగించి, పాల్గొనే అందరికీ మూసివేయాలా? సెషన్ మీ డాష్‌బోర్డ్ చరిత్రలో ఉంటుంది.';
  }

  @override
  String get dashboardEndedForEveryone =>
      'సెషన్ అందరికీ ముగిసింది మరియు సెషన్ చరిత్రలో ఉంచబడింది.';

  @override
  String get dashboardEndFailed =>
      'సెషన్‌ను ముగించలేకపోయాము. దయచేసి మళ్ళీ ప్రయత్నించండి.';

  @override
  String get dashboardReactivateTitle => 'సెషన్‌ను మళ్ళీ యాక్టివ్ చేయాలా?';

  @override
  String dashboardReactivateMessage(String title) {
    return 'పాల్గొనేవారు మళ్ళీ చేరేలా \"$title\"ను మళ్ళీ యాక్టివ్ చేయాలా?';
  }

  @override
  String get dashboardReactivated => 'సెషన్ మళ్ళీ యాక్టివ్ చేయబడింది.';

  @override
  String get dashboardReactivateFailed =>
      'సెషన్‌ను మళ్ళీ యాక్టివ్ చేయలేకపోయాము. దయచేసి మళ్ళీ ప్రయత్నించండి.';

  @override
  String get dashboardOpenNowTitle => 'సెషన్‌ను ఇప్పుడే తెరవాలా?';

  @override
  String dashboardOpenNowMessage(String title) {
    return '\"$title\" మళ్ళీ యాక్టివ్‌గా ఉంది. ఇప్పుడే తెరవండి, లేదా తర్వాత డాష్‌బోర్డ్ నుండి దానికి తిరిగి రండి.';
  }

  @override
  String get dashboardDeleteTitle => 'సెషన్‌ను శాశ్వతంగా తొలగించాలా?';

  @override
  String dashboardDeleteMessage(String title) {
    return '\"$title\"ను, దాని పాల్గొనేవారు, చాట్ మరియు లాగ్‌లతో సహా శాశ్వతంగా తొలగించాలా? దీన్ని తిరిగి తీసుకురాలేము.';
  }

  @override
  String get dashboardDeleted => 'సెషన్ శాశ్వతంగా తొలగించబడింది.';

  @override
  String get dashboardDeleteFailed =>
      'సెషన్‌ను తొలగించలేకపోయాము. దయచేసి మళ్ళీ ప్రయత్నించండి.';

  @override
  String get dashboardStateNoWorkspace => 'వర్క్‌స్పేస్ ఏదీ ఎంచుకోలేదు.';

  @override
  String dashboardStateWorkspace(String name) {
    return 'వర్క్‌స్పేస్: $name.';
  }

  @override
  String dashboardActiveSessions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count యాక్టివ్ సెషన్‌లు',
      one: '1 యాక్టివ్ సెషన్',
    );
    return '$_temp0';
  }

  @override
  String dashboardStateTotals(String active, String total) {
    return '$active, మొత్తం $total.';
  }

  @override
  String dashboardStateSearch(String query) {
    return 'వెతుకులాట: $query.';
  }

  @override
  String get adminSaveFailed =>
      'మార్పును సేవ్ చేయలేకపోయాం. రిఫ్రెష్ చేయడానికి 1 నొక్కండి, తర్వాత మళ్లీ ప్రయత్నించండి.';

  @override
  String adminChoiceLabel(String what, String name, String position) {
    return '$what: $name, $position. మార్చడానికి ఎడమ లేదా కుడి ఉపయోగించండి';
  }

  @override
  String adminChoiceLabelSingle(String what, String name) {
    return '$what: $name. మార్చడానికి ఎడమ లేదా కుడి ఉపయోగించండి';
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
    return '$className ఎంచుకోబడింది. $subject సబ్జెక్టు ఎంచుకోబడింది.';
  }

  @override
  String get adminNoSubjects => 'ఎంచుకున్న తరగతిలో యాక్టివ్ సబ్జెక్టులు లేవు.';

  @override
  String adminStateSection(String section) {
    return 'విభాగం: $section.';
  }

  @override
  String adminStateShown(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count అంశాలు చూపబడ్డాయి.',
      one: '1 అంశం చూపబడింది.',
    );
    return '$_temp0';
  }

  @override
  String adminStateFilter(String filter) {
    return 'ఫిల్టర్: $filter.';
  }

  @override
  String adminStateSearch(String query) {
    return 'శోధన: $query.';
  }

  @override
  String get adminNoSubjectName =>
      'సబ్జెక్టు పేరు నమోదు చేయలేదు. ఏదీ సృష్టించబడలేదు.';

  @override
  String get adminNoClassName =>
      'తరగతి పేరు నమోదు చేయలేదు. ఏదీ సృష్టించబడలేదు.';

  @override
  String get adminNoActiveSubjects => 'ఈ తరగతిలో యాక్టివ్ సబ్జెక్టులు లేవు.';

  @override
  String get adminListReadFailed => 'నిర్వహణ జాబితాను చదవలేకపోయాం.';

  @override
  String adminNotRefreshed(String reason) {
    return '$reason నిర్వహణ డేటా రిఫ్రెష్ కాలేదు. మళ్లీ ప్రయత్నించడానికి 1 నొక్కండి.';
  }

  @override
  String adminExploreIntro(String sections) {
    return '$sectionsను చూడటానికి D-pad పైకి, కిందికి ఉపయోగించండి. ఎంచుకోవడానికి ఓకే నొక్కండి.';
  }

  @override
  String adminSectionTitle(String section) {
    return 'నిర్వహణ. $section విభాగం';
  }

  @override
  String get adminSectionNameAccounts => 'ఖాతాలు';

  @override
  String get adminSectionNameClasses => 'తరగతులు';

  @override
  String get adminSectionNameSubjects => 'సబ్జెక్టులు';

  @override
  String get adminNoMatchingAccounts =>
      'సరిపోలే ఖాతాలు లేవు. శోధన లేదా ఫిల్టర్‌లను మార్చండి.';

  @override
  String adminNoMatchingAccountsFor(String search) {
    return '$searchకు సరిపోలే ఖాతాలు లేవు. శోధన లేదా ఫిల్టర్‌లను మార్చండి.';
  }

  @override
  String adminClasses(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count తరగతులు',
      one: '1 తరగతి',
    );
    return '$_temp0';
  }

  @override
  String adminSubjects(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count సబ్జెక్టులు',
      one: '1 సబ్జెక్టు',
    );
    return '$_temp0';
  }

  @override
  String adminAccountsSummary(int count, String classes, String subjects) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ఖాతాలు. $classes, $subjects.',
      one: '1 ఖాతా. $classes, $subjects.',
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
      other: '$count ఖాతాలు $searchకు సరిపోలాయి. $classes, $subjects.',
      one: '1 ఖాతా $searchకు సరిపోలింది. $classes, $subjects.',
    );
    return '$_temp0';
  }

  @override
  String adminClassesSentence(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count తరగతులు.',
      one: '1 తరగతి.',
    );
    return '$_temp0';
  }

  @override
  String adminSubjectsSentence(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count సబ్జెక్టులు.',
      one: '1 సబ్జెక్టు.',
    );
    return '$_temp0';
  }

  @override
  String get adminNavigationAccounts =>
      'ఖాతా శోధన, ఖాతా రకం మరియు నమోదు ఫిల్టర్‌లు, ఖాతా నిర్వహణ. ఫిల్టర్‌ను మార్చడానికి దానిపై ఎడమ లేదా కుడి ఉపయోగించండి';

  @override
  String get adminNavigationClasses =>
      'తరగతి సృష్టించడం, యాక్టివ్ లేదా ఆర్కైవ్ చేసిన తరగతుల జాబితా. ఒక తరగతి సబ్జెక్టు కేటాయింపులు, ఆర్కైవ్ లేదా పునరుద్ధరణ చర్యల కోసం దానిపై ఓకే నొక్కండి';

  @override
  String get adminNavigationSubjects =>
      'సబ్జెక్టు సృష్టించడం, యాక్టివ్ లేదా ఆర్కైవ్ చేసిన సబ్జెక్టుల జాబితా. ఒక సబ్జెక్టును ఆర్కైవ్ లేదా పునరుద్ధరించడానికి దానిపై ఓకే నొక్కండి';

  @override
  String get adminSectionsTitle => 'నిర్వహణ విభాగాలు';

  @override
  String get adminSectionAccounts => 'ఖాతాలు మరియు నమోదు';

  @override
  String get adminSectionClasses => 'తరగతులు మరియు వాటి సబ్జెక్టులు';

  @override
  String get adminSectionSubjects => 'సబ్జెక్టులు';

  @override
  String adminSectionChosen(String section) {
    return '$section విభాగం.';
  }

  @override
  String adminSectionExplore(String what) {
    return '$whatను చూడటానికి D-pad ఉపయోగించండి. విభాగం మార్చడానికి 7 నొక్కండి.';
  }

  @override
  String get adminExploreAccounts => 'ఖాతా ఫిల్టర్‌లు, శోధన మరియు ఖాతా నిర్వహణ';

  @override
  String get adminExploreClasses =>
      'తరగతి సృష్టించడం, సబ్జెక్టు కేటాయింపులు, ఆర్కైవ్ లేదా పునరుద్ధరణ చర్యలు';

  @override
  String get adminExploreSubjects =>
      'సబ్జెక్టు సృష్టించడం, ఆర్కైవ్ లేదా పునరుద్ధరణ చర్యలు';

  @override
  String adminRoleFilterSelected(String label) {
    return 'ఖాతా రకం ఫిల్టర్: $label, ఎంచుకోబడింది.';
  }

  @override
  String adminAssignmentFilterSelected(String label) {
    return 'కేటాయింపు ఫిల్టర్: $label, ఎంచుకోబడింది.';
  }

  @override
  String get adminRoleFilterStudents => 'విద్యార్థులు మాత్రమే';

  @override
  String get adminRoleFilterTeachers => 'ఉపాధ్యాయులు మాత్రమే';

  @override
  String get adminRoleFilterAll => 'నమోదైన అన్ని ఖాతాలు';

  @override
  String get adminAssignmentEnrolled => 'నమోదు చేయబడింది';

  @override
  String get adminAssignmentAssigned => 'కేటాయించబడింది';

  @override
  String get adminAssignmentEnrolledOrAssigned =>
      'నమోదు చేయబడింది లేదా కేటాయించబడింది';

  @override
  String get adminAssignmentUnassigned => 'కేటాయించబడలేదు';

  @override
  String get adminAssignmentAll => 'అన్ని కేటాయింపు స్థితులు';

  @override
  String get adminRoleStudent => 'విద్యార్థి';

  @override
  String get adminRoleTeacher => 'ఉపాధ్యాయులు';

  @override
  String get adminNoClassAssigned => 'ఏ తరగతి కేటాయించబడలేదు';

  @override
  String adminAssignmentCount(String count) {
    return '$count కేటాయింపులు';
  }

  @override
  String adminAccountLabel(String name, String role, String access) {
    return '$name, $role. $access. నిర్వహించడానికి ఓకే నొక్కండి';
  }

  @override
  String get adminCancel => 'రద్దు చేయండి';

  @override
  String get adminSave => 'సేవ్ చేయండి';

  @override
  String get adminCreateSubjectTitle => 'సబ్జెక్టు సృష్టించండి';

  @override
  String get adminSubjectNameField => 'సబ్జెక్టు పేరు';

  @override
  String adminSubjectCreated(String name) {
    return '$name సబ్జెక్టు సృష్టించబడింది';
  }

  @override
  String get adminCreateClassTitle => 'తరగతి సృష్టించండి';

  @override
  String get adminClassNameField => 'తరగతి పేరు';

  @override
  String adminClassCreated(String name) {
    return '$name తరగతి సృష్టించబడింది';
  }

  @override
  String get adminArchiveClassTitle => 'తరగతిని ఆర్కైవ్ చేయాలా?';

  @override
  String get adminRestoreClassTitle => 'తరగతిని తిరిగి తీసుకురావాలా?';

  @override
  String adminArchiveItemMessage(String name) {
    return '$name ఆర్కైవ్‌లో ఉన్నంత వరకు కొత్త సెషన్లు, ఆడియో మరియు కేటాయింపులు దాన్ని ఉపయోగించలేవు.';
  }

  @override
  String adminRestoreItemMessage(String name) {
    return '$name మళ్ళీ కేటాయింపులకు అందుబాటులోకి వస్తుంది.';
  }

  @override
  String get adminArchive => 'ఆర్కైవ్ చేయండి';

  @override
  String get adminRestore => 'తిరిగి తీసుకురండి';

  @override
  String get adminClassArchived => 'తరగతి ఆర్కైవ్ చేయబడింది';

  @override
  String get adminClassRestored => 'తరగతి తిరిగి తీసుకురాబడింది';

  @override
  String adminManageTitle(String name) {
    return '$name ను నిర్వహించండి';
  }

  @override
  String get adminManageClassSubjects => 'తరగతి సబ్జెక్టులను నిర్వహించండి';

  @override
  String get adminArchiveClassChoice => 'నిర్ధారణతో తరగతిని ఆర్కైవ్ చేయండి';

  @override
  String get adminRestoreClassChoice => 'నిర్ధారణతో తరగతిని తిరిగి తీసుకురండి';

  @override
  String adminSubjectsForClass(String name) {
    return '$name కోసం సబ్జెక్టులు';
  }

  @override
  String adminSubjectRemovedFrom(String name) {
    return '$name నుండి సబ్జెక్టు తొలగించబడింది';
  }

  @override
  String adminSubjectAddedTo(String name) {
    return '$name కు సబ్జెక్టు జోడించబడింది';
  }

  @override
  String get adminArchiveSubjectTitle => 'సబ్జెక్టును ఆర్కైవ్ చేయాలా?';

  @override
  String get adminRestoreSubjectTitle => 'సబ్జెక్టును తిరిగి తీసుకురావాలా?';

  @override
  String get adminSubjectArchived => 'సబ్జెక్టు ఆర్కైవ్ చేయబడింది';

  @override
  String get adminSubjectRestored => 'సబ్జెక్టు తిరిగి తీసుకురాబడింది';

  @override
  String get adminManageAssignments => 'కేటాయింపులను నిర్వహించండి';

  @override
  String get adminPasswordRecovery => 'పాస్‌వర్డ్ పునరుద్ధరణ';

  @override
  String adminManageUserScreen(String name) {
    return '$name ను నిర్వహించండి. కేటాయింపులు, పాస్‌వర్డ్ పునరుద్ధరణ లేదా రద్దు ఎంచుకోండి.';
  }

  @override
  String get adminRecoveryNeedsVersion =>
      'ఖాతా పునరుద్ధరణకు ప్రస్తుత సర్వర్ వెర్షన్ అవసరం. ఖాతాను రిఫ్రెష్ చేయండి.';

  @override
  String get adminNoActiveClasses =>
      'యాక్టివ్ తరగతులు లేవు. ముందుగా తరగతుల విభాగంలో ఒక తరగతిని సృష్టించండి లేదా తిరిగి తీసుకురండి.';

  @override
  String get adminTheCurrentClass => 'ప్రస్తుత తరగతి';

  @override
  String adminAssignClassTo(String name) {
    return '$name కు తరగతిని కేటాయించండి';
  }

  @override
  String get adminAssign => 'కేటాయించండి';

  @override
  String get adminRemoveClass => 'తరగతిని తొలగించండి';

  @override
  String get adminClassField => 'తరగతి';

  @override
  String adminRemoveStudentLabel(String name, String className) {
    return '$className నుండి $name ను తొలగించండి, నిర్ధారణ అడుగుతుంది';
  }

  @override
  String adminAssignStudentLabel(String name) {
    return 'ఎంచుకున్న తరగతికి $name ను కేటాయించండి';
  }

  @override
  String get adminRemoveFromClassTitle => 'తరగతి నుండి తొలగించాలా?';

  @override
  String adminRemoveFromClassMessage(String name, String className) {
    return '$className నుండి $name ను తొలగించాలా? మళ్ళీ కేటాయించే వరకు వారికి ఆ తరగతి కనిపించదు.';
  }

  @override
  String get adminKeepInClass => 'తరగతిలో ఉంచండి';

  @override
  String get adminRemoveFromClass => 'తరగతి నుండి తొలగించండి';

  @override
  String adminStudentRemovedFromClass(String name) {
    return '$name తరగతి నుండి తొలగించబడ్డారు';
  }

  @override
  String adminStudentAssignedTo(String name, String className) {
    return '$name $className కు కేటాయించబడ్డారు';
  }

  @override
  String adminAssignTeacherScreen(String name) {
    return '$name ను ఒక తరగతికి మరియు సబ్జెక్టుకు కేటాయించండి';
  }

  @override
  String adminRemoveAssignmentLabel(
    String name,
    String className,
    String subject,
  ) {
    return '$className, $subject నుండి $name ను తొలగించండి, నిర్ధారణ అడుగుతుంది';
  }

  @override
  String get adminSubjectField => 'సబ్జెక్టు';

  @override
  String get adminSaveAssignment => 'కేటాయింపును సేవ్ చేయండి';

  @override
  String get adminTeacherAssignmentSaved =>
      'ఉపాధ్యాయుల కేటాయింపు సేవ్ చేయబడింది';

  @override
  String get adminRemoveAssignmentTitle => 'కేటాయింపును తొలగించాలా?';

  @override
  String adminRemoveAssignmentMessage(
    String name,
    String className,
    String subject,
  ) {
    return '$className, $subject నుండి $name ను తొలగించాలా?';
  }

  @override
  String get adminKeep => 'ఉంచండి';

  @override
  String get adminRemove => 'తొలగించండి';

  @override
  String get adminTeacherAssignmentRemoved =>
      'ఉపాధ్యాయుల కేటాయింపు తొలగించబడింది';

  @override
  String get adminRefreshData => 'నిర్వాహకుల డేటాను రిఫ్రెష్ చేయండి';

  @override
  String get adminLogout => 'లాగ్ అవుట్, నిర్ధారణ అడుగుతుంది';

  @override
  String adminSectionButton(String section) {
    return '$section విభాగం. నిర్వహణ విభాగాన్ని మార్చండి';
  }

  @override
  String get adminSearchAccounts =>
      'పేరు లేదా ఫోన్ నంబర్‌తో ఖాతాలను వెతకండి. టైప్ చేయడానికి ఓకే నొక్కండి';

  @override
  String adminRoleFilterLabel(String label) {
    return 'ఖాతా రకం ఫిల్టర్: $label, ఎంచుకోబడింది. మార్చడానికి ఎడమ లేదా కుడి ఉపయోగించండి';
  }

  @override
  String adminAssignmentFilterLabel(String label) {
    return 'కేటాయింపు ఫిల్టర్: $label, ఎంచుకోబడింది. మార్చడానికి ఎడమ లేదా కుడి ఉపయోగించండి';
  }

  @override
  String adminClassActiveLabel(String name) {
    return '$name, యాక్టివ్. తరగతి సబ్జెక్టులు మరియు ఆర్కైవ్ లేదా తిరిగి తీసుకురావడం కోసం ఓకే నొక్కండి';
  }

  @override
  String adminClassArchivedLabel(String name) {
    return '$name, ఆర్కైవ్ చేయబడింది. తరగతి సబ్జెక్టులు మరియు ఆర్కైవ్ లేదా తిరిగి తీసుకురావడం కోసం ఓకే నొక్కండి';
  }

  @override
  String adminSubjectActiveLabel(String name) {
    return '$name, యాక్టివ్. ఆర్కైవ్ చేయడానికి ఓకే నొక్కండి';
  }

  @override
  String adminSubjectArchivedLabel(String name) {
    return '$name, ఆర్కైవ్ చేయబడింది. తిరిగి తీసుకురావడానికి ఓకే నొక్కండి';
  }

  @override
  String adminSubjectInClass(String name) {
    return '$name. ఈ తరగతిలో అందుబాటులో ఉంది. తొలగించడానికి ఎంచుకోండి';
  }

  @override
  String adminSubjectNotInClass(String name) {
    return '$name. ఈ తరగతిలో అందుబాటులో లేదు. జోడించడానికి ఎంచుకోండి';
  }

  @override
  String get teacherHomeLater => 'తర్వాత';

  @override
  String get teacherHomeStartNow => 'ఇప్పుడే ప్రారంభించండి';

  @override
  String get teacherHomeChooseWorkspaceTitle =>
      'తరగతి మరియు సబ్జెక్టు ఎంచుకోండి';

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
    return '$className, $subjectName ఎంచుకోబడింది. $status. వేరే వర్క్‌స్పేస్ ఎంచుకోవడానికి 7 నొక్కండి.';
  }

  @override
  String get teacherHomeUntitledSession => 'పేరు లేని సెషన్';

  @override
  String get teacherHomeUntitledSessionTitle => 'పేరు లేని సెషన్';

  @override
  String get teacherHomeSessionFallback => 'సెషన్';

  @override
  String get teacherHomeSearchLabel =>
      'సెషన్‌లను వెతకండి. ఓకే నొక్కి, తర్వాత పేరు లేదా సెషన్ నంబర్ టైప్ చేయండి';

  @override
  String get teacherHomeKeepSessionOpen => 'సెషన్‌ను తెరిచే ఉంచండి';

  @override
  String get teacherHomeEndForEveryone => 'అందరికీ ముగించండి';

  @override
  String get teacherHomeKeepEnded => 'ముగిసినట్లే ఉంచండి';

  @override
  String get teacherHomeReactivate => 'మళ్ళీ యాక్టివ్ చేయండి';

  @override
  String get teacherHomeOpenLater => 'తర్వాత తెరవండి';

  @override
  String get teacherHomeOpenNow => 'ఇప్పుడే తెరవండి';

  @override
  String get teacherHomeKeepSession => 'సెషన్‌ను ఉంచండి';

  @override
  String get teacherHomeDeletePermanently => 'శాశ్వతంగా తొలగించండి';

  @override
  String get teacherHomeNewSessionTitle => 'కొత్త సెషన్';

  @override
  String get teacherHomeCreateScreen => 'కొత్త సెషన్ సృష్టించండి';

  @override
  String get teacherHomeCreateSessionKey => 'సెషన్ సృష్టించండి';

  @override
  String get teacherHomeTitleField => 'సెషన్ శీర్షిక ఫీల్డ్';

  @override
  String get teacherHomeCancelCreate => 'సెషన్ సృష్టించడం రద్దు చేయండి';

  @override
  String get studentHomeSearchHelp =>
      'సెషన్ వెతుకులాట. కీప్యాడ్‌తో సెషన్ నంబర్ టైప్ చేయండి, లేదా పేరుతో వెతకడానికి కిందికి వెళ్ళండి. మార్చడానికి ఓకే నొక్కండి. ఫలితాలు చూడటానికి కిందికి వెళ్ళండి.';

  @override
  String studentHomeSubjectFallback(String id) {
    return 'సబ్జెక్టు $id';
  }

  @override
  String get studentHomeUntitledSession => 'పేరు లేని సెషన్';

  @override
  String studentHomeSessionJoinLabel(String session) {
    return '$session. చేరడానికి ఓకే నొక్కండి';
  }

  @override
  String get inviteNoStudentsEnrolled =>
      'ఈ తరగతిలో విద్యార్థులు ఎవరూ నమోదు కాలేదు. రిఫ్రెష్ చేయడానికి 1 నొక్కండి.';

  @override
  String inviteLoadedSummary(int count, String invited) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count మంది విద్యార్థులు, $invited మందిని ఆహ్వానించారు.',
      one: '1 విద్యార్థి, $invited మందిని ఆహ్వానించారు.',
    );
    return '$_temp0';
  }

  @override
  String get inviteUseSearch =>
      'పేరు కనుగొనడానికి వెతుకు ఫీల్డ్‌ను ఉపయోగించండి.';

  @override
  String get inviteLoadFailed =>
      'విద్యార్థులను లోడ్ చేయలేకపోయాము. మీ కనెక్షన్‌ను తనిఖీ చేసి, మళ్ళీ ప్రయత్నించడానికి 1 నొక్కండి.';

  @override
  String inviteAlreadyInvited(String name) {
    return '$name ను ఇప్పటికే ఆహ్వానించారు.';
  }

  @override
  String inviteInvitedOne(String name) {
    return '$name ను ఆహ్వానించారు.';
  }

  @override
  String inviteOneFailed(String name) {
    return '$name ను ఆహ్వానించలేకపోయాము. మీ కనెక్షన్‌ను తనిఖీ చేసి, మళ్ళీ ప్రయత్నించడానికి ఓకే నొక్కండి.';
  }

  @override
  String get inviteNoStudentsToInvite =>
      'ఆహ్వానించడానికి విద్యార్థులు ఎవరూ లేరు.';

  @override
  String get inviteAllAlreadyInvited =>
      'విద్యార్థులందరినీ ఇప్పటికే ఆహ్వానించారు.';

  @override
  String inviteInvitingAll(String count) {
    return '$count మంది విద్యార్థులను ఆహ్వానిస్తున్నాము. దయచేసి వేచి ఉండండి.';
  }

  @override
  String inviteProgress(String done, String total) {
    return 'విద్యార్థులను ఆహ్వానిస్తున్నాము: $total లో $done పూర్తయ్యాయి.';
  }

  @override
  String inviteAllDone(String count) {
    return 'మొత్తం $count మంది విద్యార్థులను ఆహ్వానించారు.';
  }

  @override
  String invitePartialFailed(String invited, String total, String names) {
    return '$total మంది విద్యార్థులలో $invited మందిని ఆహ్వానించారు. $names ను ఆహ్వానించలేకపోయాము. మళ్ళీ ప్రయత్నించడానికి 2 నొక్కండి.';
  }

  @override
  String inviteShowingAll(String count) {
    return 'మొత్తం $count మంది విద్యార్థులను చూపిస్తున్నాము.';
  }

  @override
  String inviteNoMatch(String query) {
    return '$query కు సరిపోయే విద్యార్థులు ఎవరూ లేరు. అందరినీ చూడటానికి వెతుకును క్లియర్ చేయండి.';
  }

  @override
  String inviteMatches(int count, String query) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$query కు $count మంది విద్యార్థులు సరిపోతున్నారు. చూడటానికి కిందికి ఉపయోగించండి.',
      one:
          '$query కు 1 విద్యార్థి సరిపోతున్నారు. చూడటానికి కిందికి ఉపయోగించండి.',
    );
    return '$_temp0';
  }

  @override
  String inviteStudentInvited(String name) {
    return '$name, ఆహ్వానించారు';
  }

  @override
  String inviteStudentNotInvited(String name) {
    return '$name, ఆహ్వానించలేదు. ఆహ్వానించడానికి ఓకే నొక్కండి';
  }

  @override
  String get inviteBackToSession => 'సెషన్‌కు తిరిగి వెళ్ళండి';

  @override
  String get inviteRefreshList => 'విద్యార్థుల జాబితాను రిఫ్రెష్ చేయండి';

  @override
  String get inviteAllStudents => 'విద్యార్థులందరినీ ఆహ్వానించండి';

  @override
  String get inviteSearchLabel =>
      'పేరు లేదా ఫోన్ నంబర్‌తో విద్యార్థులను వెతకండి. టైప్ చేయడానికి ఓకే నొక్కండి';

  @override
  String inviteScreenName(String title) {
    return '$title కు విద్యార్థులను ఆహ్వానించండి';
  }

  @override
  String get inviteKeyBack => 'సెషన్‌కు తిరిగి';

  @override
  String get inviteKeyRefresh => 'విద్యార్థులను రిఫ్రెష్ చేయండి';

  @override
  String get inviteKeyInviteAll => 'అందరినీ ఆహ్వానించండి';

  @override
  String get notificationTitleSessionInvitation => 'లైవ్ తరగతి';

  @override
  String get notificationTitleJourneyPublished => 'కొత్త అభ్యాస ప్రయాణం';

  @override
  String get notificationTitleQuizPublished => 'కొత్త క్విజ్';

  @override
  String get notificationTitleQuizReminder => 'క్విజ్ రిమైండర్';

  @override
  String get notificationTitleDefault => 'SEEDS అప్‌డేట్';

  @override
  String get notificationArrivedSessionInvitation =>
      'మీ ఉపాధ్యాయులు తరగతి ప్రారంభించారు. చేరడానికి 1 నొక్కండి, లేదా ఇప్పుడు వద్దు అంటే 0 నొక్కండి.';

  @override
  String get notificationArrivedJourneyPublished =>
      'మీ ఉపాధ్యాయులు కొత్త అభ్యాస ప్రయాణాన్ని పంచుకున్నారు. తెరవడానికి 1 నొక్కండి, లేదా ఇప్పుడు వద్దు అంటే 0 నొక్కండి.';

  @override
  String get notificationArrivedQuizPublished =>
      'మీ ఉపాధ్యాయులు కొత్త క్విజ్ ప్రచురించారు. మీ క్విజ్‌లు తెరవడానికి 1 నొక్కండి, లేదా ఇప్పుడు వద్దు అంటే 0 నొక్కండి.';

  @override
  String get notificationArrivedQuizReminder =>
      'రిమైండర్: మీరు రాయాల్సిన క్విజ్ ఒకటి ఉంది. మీ క్విజ్‌లు తెరవడానికి 1 నొక్కండి, లేదా ఇప్పుడు వద్దు అంటే 0 నొక్కండి.';

  @override
  String get notificationArrivedDefault =>
      'మీకు కొత్త అప్‌డేట్ ఉంది. వెనక్కి వెళ్ళడానికి 0 నొక్కండి.';

  @override
  String get notificationForegroundSessionInvitation =>
      'మీ ఉపాధ్యాయులు తరగతి ప్రారంభించారు. మీ డాష్‌బోర్డ్‌లోని లైవ్ సెషన్‌ల నుండి చేరండి.';

  @override
  String get notificationForegroundJourneyPublished =>
      'మీ ఉపాధ్యాయులు కొత్త అభ్యాస ప్రయాణాన్ని పంచుకున్నారు. అభ్యాస ప్రయాణాలలో చూడండి.';

  @override
  String get notificationForegroundQuizPublished =>
      'మీ ఉపాధ్యాయులు కొత్త క్విజ్ ప్రచురించారు.';

  @override
  String get notificationForegroundQuizReminder =>
      'రిమైండర్: మీరు రాయాల్సిన క్విజ్ ఒకటి ఉంది.';

  @override
  String get notificationForegroundDefault => 'మీకు కొత్త అప్‌డేట్ ఉంది.';

  @override
  String get notificationOpenJoinClass => 'తరగతిలో చేరండి';

  @override
  String get notificationOpenJourney => 'ప్రయాణం తెరవండి';

  @override
  String get notificationOpenQuizzes => 'క్విజ్‌లు తెరవండి';

  @override
  String get notificationOpenBack => 'వెనక్కి';

  @override
  String get notificationCannotOpen =>
      'దీన్ని తెరవలేకపోయాము. మళ్ళీ సైన్ ఇన్ చేసి, తర్వాత మీ డాష్‌బోర్డ్ నుండి తెరవండి.';

  @override
  String get authLoginSuccessful => 'లాగిన్ విజయవంతమైంది';

  @override
  String authRoleAlreadySelected(String role) {
    return '$role ఖాతా ఇప్పటికే ఎంచుకోబడింది';
  }

  @override
  String authRoleSelected(String role) {
    return '$role ఖాతా ఎంచుకోబడింది';
  }

  @override
  String authRecoveryStep(String number, String step) {
    return 'దశ $number. $step';
  }

  @override
  String get authEnterPhone => 'ఫోన్ నంబర్ నమోదు చేయండి';

  @override
  String get authEnterPassword => 'పాస్‌వర్డ్ నమోదు చేయండి';

  @override
  String get authEnterName => 'పేరు నమోదు చేయండి';

  @override
  String get authRegistering => 'నమోదు చేస్తోంది, దయచేసి వేచి ఉండండి.';

  @override
  String get authPasswordChanged => 'పాస్‌వర్డ్ మార్చబడింది. సైన్ ఇన్ అయ్యారు.';

  @override
  String journeyWhereFinished(String title) {
    return 'ప్రయాణం పూర్తయింది. $title.';
  }

  @override
  String journeyWhere(String number, String total, String kind, String title) {
    return '$total లో దశ $number. $kind. $title.';
  }

  @override
  String journeyWhereReplaying(
    String number,
    String total,
    String kind,
    String title,
  ) {
    return '$total లో దశ $number. $kind. $title. ప్రశ్నకు ముందు మళ్ళీ వింటున్నాము.';
  }

  @override
  String get journeyKindRecording => 'రికార్డింగ్';

  @override
  String get journeyKindNarration => 'వివరణ';

  @override
  String get journeyKindQuestion => 'ప్రశ్న';

  @override
  String get journeyKindPoll => 'పోల్';

  @override
  String journeyOption(String number, String text) {
    return 'ఎంపిక $number: $text.';
  }

  @override
  String journeyChooseKeys(String count) {
    return 'ఎంచుకోవడానికి 1 నుండి $count వరకు నొక్కండి, తర్వాత సమర్పించడానికి 5 నొక్కండి.';
  }

  @override
  String journeyPollQuestion(String question, String options, String keys) {
    return 'పోల్. ఇందులో తప్పు జవాబు లేదు. $question $options $keys';
  }

  @override
  String journeyQuestion(String question, String options, String keys) {
    return 'ప్రశ్న. $question $options $keys';
  }

  @override
  String journeyQuestionTryAgain(
    String triesLeft,
    String question,
    String options,
    String keys,
  ) {
    return 'ప్రశ్న. మళ్ళీ ప్రయత్నించండి. $triesLeft $question $options $keys';
  }

  @override
  String journeyTriesLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ప్రయత్నాలు మిగిలి ఉన్నాయి.',
      one: '1 ప్రయత్నం మిగిలి ఉంది.',
    );
    return '$_temp0';
  }

  @override
  String journeyChosen(String number, String option) {
    return 'ఎంపిక $number, $option, ఎంచుకోబడింది. సమర్పించడానికి 5 నొక్కండి, లేదా మరో నంబర్ ఎంచుకోండి.';
  }

  @override
  String journeyRecordingContent(String title) {
    return 'రికార్డింగ్: $title. ఆపడానికి లేదా ప్లే చేయడానికి 5 నొక్కండి. ముందుకు వెళ్ళడానికి సిద్ధంగా ఉన్నప్పుడు 2 నొక్కండి.';
  }

  @override
  String get journeyUntitled => 'పేరు లేదు';

  @override
  String get journeyContentKeys =>
      'తర్వాతి దశకు 2, ఈ దశను మళ్ళీ వినడానికి 3, మీరు ఎక్కడ ఉన్నారో వినడానికి 1, మునుపటి రికార్డింగ్ లేదా వివరణకు తిరిగి వెళ్ళడానికి 8 నొక్కండి.';

  @override
  String journeyCorrect(String answer) {
    return 'సరైనది! $answer.';
  }

  @override
  String get journeyPollSaved => 'ధన్యవాదాలు. మీ జవాబు సేవ్ చేయబడింది.';

  @override
  String get journeyReplayOutcome =>
      'సరిగ్గా కాదు. ఆ భాగాన్ని మళ్ళీ విని, ఇంకోసారి ప్రయత్నిద్దాం.';

  @override
  String get journeyTryAgainOutcome =>
      'సరిగ్గా కాదు. మళ్ళీ ఆలోచించి మరో జవాబు ఎంచుకోండి.';

  @override
  String journeyRevealed(String number, String answer, String explanation) {
    return 'సరిగ్గా కాదు. సరైన జవాబు ఎంపిక $number, $answer. $explanation';
  }

  @override
  String journeyWellDone(String title) {
    return 'చాలా బాగుంది! మీరు $title పూర్తి చేశారు.';
  }

  @override
  String journeyFirstTryScore(int questions, String correct) {
    String _temp0 = intl.Intl.pluralLogic(
      questions,
      locale: localeName,
      other:
          'మొదటి ప్రయత్నంలో $questions ప్రశ్నలలో $correct కు సరిగ్గా జవాబు ఇచ్చారు.',
      one: 'మొదటి ప్రయత్నంలో 1 ప్రశ్నలో $correct కు సరిగ్గా జవాబు ఇచ్చారు.',
    );
    return '$_temp0';
  }

  @override
  String get journeyPlayAgainHelp =>
      'మళ్ళీ ప్లే చేయడానికి 1 నొక్కండి, లేదా మీ ప్రయాణాలకు తిరిగి వెళ్ళడానికి 0 నొక్కండి.';

  @override
  String get journeyStatusCompleted => 'పూర్తయింది';

  @override
  String get journeyStatusInProgress => 'జరుగుతోంది';

  @override
  String get journeyStatusNew => 'కొత్తది';

  @override
  String journeyRowScore(String percent) {
    return 'స్కోరు $percent శాతం.';
  }

  @override
  String get journeyRowDownloaded => 'డౌన్‌లోడ్ చేయబడింది.';

  @override
  String journeyStudentRow(
    String title,
    String subject,
    String steps,
    String questions,
    String status,
  ) {
    return '$title. $subject. $steps దశలు, $questions ప్రశ్నలు. $status.';
  }

  @override
  String journeyTeacherRow(
    String title,
    String status,
    String steps,
    String questions,
  ) {
    return '$title. $status. $steps దశలు, $questions ప్రశ్నలు.';
  }

  @override
  String get journeyRowGraded => 'మార్కులతో.';

  @override
  String journeyStepRow(String number, String total, String name) {
    return '$total లో దశ $number. $name.';
  }

  @override
  String get journeyReplaysAutomatically => 'ఆటోమేటిక్‌గా మళ్ళీ ప్లే అవుతుంది.';

  @override
  String journeyReplaysFrom(String number) {
    return 'దశ $number నుండి మళ్ళీ ప్లే అవుతుంది.';
  }

  @override
  String get journeyFinishedStatus => 'ప్రయాణం పూర్తయింది.';

  @override
  String get journeyRecordingPlaying => 'రికార్డింగ్ ప్లే అవుతోంది.';

  @override
  String get journeyRecordingPaused => 'రికార్డింగ్ ఆపబడింది.';

  @override
  String get journeyNoOptionChosen => 'ఇంకా ఏ ఎంపికనూ ఎంచుకోలేదు.';

  @override
  String journeyOptionSelected(String number, String option) {
    return 'ఎంపిక $number, $option, ఎంచుకోబడింది.';
  }

  @override
  String journeyPreviewStart(String title) {
    return '$title ప్రివ్యూ. ఏదీ సేవ్ చేయబడదు.';
  }

  @override
  String journeyWelcomeBack(String title) {
    return '$title కు తిరిగి స్వాగతం. మీరు ఆపిన చోటు నుండి కొనసాగిస్తున్నాము.';
  }

  @override
  String journeyStartingBrief(String title) {
    return '$title ప్రారంభిస్తున్నాము.';
  }

  @override
  String journeyStartingDetailed(String title, String steps) {
    return '$title ప్రారంభిస్తున్నాము. $steps దశలు. సహాయం కోసం ఎప్పుడైనా స్టార్ నొక్కండి.';
  }

  @override
  String journeyNotSaved(String reason) {
    return 'మీరు ఉన్న చోటును సేవ్ చేయలేకపోయాము. $reason';
  }

  @override
  String get journeyListeningAgain => 'మళ్ళీ వింటున్నాము.';

  @override
  String journeyNarration(String text) {
    return '$text కొనసాగించడానికి 2 నొక్కండి.';
  }

  @override
  String journeyRecordingStatus(String title) {
    return 'రికార్డింగ్: $title';
  }

  @override
  String get journeyRecordingFailed =>
      'ఈ రికార్డింగ్‌ను ప్లే చేయలేకపోయాము. మీ ఇంటర్నెట్‌ను తనిఖీ చేయండి.';

  @override
  String get journeyRecordingRetry =>
      'మళ్ళీ ప్రయత్నించడానికి 3 నొక్కండి, లేదా తర్వాతి దశకు వెళ్ళడానికి 2 నొక్కండి.';

  @override
  String get journeyNotDownloaded =>
      'ఈ రికార్డింగ్ ఈ ఫోన్‌లో డౌన్‌లోడ్ కాలేదు.';

  @override
  String get journeyRecordingFinished => 'రికార్డింగ్ పూర్తయింది.';

  @override
  String journeyAnswerFirst(String count) {
    return 'ముందు జవాబు ఇవ్వండి. ఎంచుకోవడానికి 1 నుండి $count వరకు నొక్కండి, తర్వాత 5 నొక్కండి.';
  }

  @override
  String get journeyNoEarlierContent =>
      'ఇంతకు ముందు రికార్డింగ్ లేదా వివరణ లేదు.';

  @override
  String get journeyGoingBack => 'వెనక్కి వెళ్తున్నాము.';

  @override
  String journeyNoSuchOption(String option, String count) {
    return 'ఎంపిక $option లేదు. 1 నుండి $count వరకు ఎంచుకోండి.';
  }

  @override
  String journeyChooseFirst(String count) {
    return 'ముందు 1 నుండి $count వరకు ఒక జవాబు ఎంచుకోండి.';
  }

  @override
  String get journeySendLater =>
      'ప్రయాణం పూర్తయింది. మీరు ఆన్‌లైన్‌లో ఉన్నప్పుడు మీ జవాబులు పంపబడతాయి.';

  @override
  String get journeyStartingAgain => 'మళ్ళీ ప్రారంభిస్తున్నాము.';

  @override
  String get journeyPaused => 'ఆపబడింది.';

  @override
  String get journeySeekRecordingsOnly =>
      'ముందుకు వెనక్కి జరపడం రికార్డింగ్‌లలో మాత్రమే పనిచేస్తుంది.';

  @override
  String get journeySpeedRecordingsOnly =>
      'రికార్డింగ్ వేగం రికార్డింగ్‌లలో మాత్రమే మారుతుంది.';

  @override
  String get journeyFastest => 'అత్యధిక వేగం.';

  @override
  String get journeySlowest => 'అత్యల్ప వేగం.';

  @override
  String journeySpeed(String rate) {
    return 'రికార్డింగ్ వేగం $rate రెట్లు.';
  }

  @override
  String get journeyLeaveTitle => 'ఈ ప్రయాణం నుండి బయటకు వెళ్ళాలా?';

  @override
  String journeyLeaveMessage(String step) {
    return 'మీరు ఉన్న చోటు ఈ ఫోన్‌లో సేవ్ చేయబడింది. తర్వాతిసారి మీరు దశ $step నుండి కొనసాగించవచ్చు.';
  }

  @override
  String get journeyAnswerHelp =>
      'ఎంచుకోవడానికి ఒక నంబర్, సమర్పించడానికి 5, ప్రశ్నను మళ్ళీ వినడానికి 6 నొక్కండి.';

  @override
  String journeyStepRemoved(String remaining) {
    return 'దశ తొలగించబడింది. ఇప్పుడు ప్రయాణంలో $remaining దశలు ఉన్నాయి.';
  }

  @override
  String journeyStepRemovedUndo(String name) {
    return '$name తొలగించబడింది.';
  }

  @override
  String get journeyStepRestored => 'దశ తిరిగి తీసుకురాబడింది.';

  @override
  String journeyCreated(String title) {
    return '$title సృష్టించబడింది. ఇప్పుడు దాని మొదటి దశను జోడించండి.';
  }

  @override
  String get journeyNoStepAdded => 'ఏ దశా జోడించబడలేదు.';

  @override
  String journeyPreviewSkips(String issues) {
    return 'ఈ ప్రివ్యూలో కొన్ని దశలు వదిలివేయబడ్డాయి. $issues';
  }

  @override
  String journeyDuplicated(String title) {
    return '$title ను కొత్త డ్రాఫ్ట్‌గా సృష్టించాము. దాన్ని డ్రాఫ్ట్‌లలో కనుగొనండి.';
  }

  @override
  String journeyArchiveMessage(String title) {
    return 'విద్యార్థులకు ఇకపై $title కనిపించదు. ఫలితాలు ఉంచబడతాయి. మీరు దాన్ని తర్వాత తిరిగి తీసుకురావచ్చు.';
  }

  @override
  String journeyRestoreMessage(String title) {
    return 'విద్యార్థులకు $title మళ్ళీ కనిపిస్తుంది.';
  }

  @override
  String get journeyArchived =>
      'ఆర్కైవ్ చేయబడింది. విద్యార్థులకు ఇకపై కనిపించదు.';

  @override
  String get journeyRestored => 'విద్యార్థుల కోసం తిరిగి తీసుకురాబడింది.';

  @override
  String journeyDeleteDraftMessage(String title) {
    return '$title ను శాశ్వతంగా తొలగించాలా? రికార్డింగ్‌లు మీ లైబ్రరీలోనే ఉంటాయి.';
  }

  @override
  String get journeyDraftDeleted => 'డ్రాఫ్ట్ తొలగించబడింది.';

  @override
  String get journeyNoRetriesLeft => 'ఇప్పటికే మళ్ళీ ప్రయత్నాలు లేవు.';

  @override
  String get journeyMaxRetries => 'గరిష్ఠంగా ఐదు సార్లు మళ్ళీ ప్రయత్నించవచ్చు.';

  @override
  String journeyPublished(String count) {
    return 'ప్రచురించబడింది. విద్యార్థులు ఇప్పుడు దీన్ని ప్లే చేయవచ్చు. నోటిఫికేషన్లు $count ఫోన్లకు చేరాయి.';
  }

  @override
  String get journeyOptionUsed =>
      'ఆ ఎంపిక ఇప్పటికే ఉపయోగించబడింది. వేరే ఎంపికను టైప్ చేయండి.';

  @override
  String get journeyNothingToReplay =>
      'ఈ ప్రశ్నకు ముందు ఇంకా రికార్డింగ్ లేదా వివరణ లేదు, కాబట్టి తప్పు జవాబు ఇస్తే ప్రశ్న మళ్ళీ అడగబడుతుంది. మీరు ముందు కంటెంట్ జోడించి, దీన్ని తర్వాత సవరించవచ్చు.';

  @override
  String get journeyBankEmpty =>
      'ఈ తరగతి మరియు సబ్జెక్టు కోసం మీ ప్రశ్నల బ్యాంక్ ఖాళీగా ఉంది. బదులుగా కొత్త ప్రశ్న రాయండి ఎంచుకోండి.';

  @override
  String get journeyRecordViaNotes =>
      'ప్రైవేట్ నోట్స్ తెరుస్తున్నాము. రికార్డ్ చేసి, సమీక్షించి, తర్వాత ఈ తరగతి మరియు సబ్జెక్టుకు ప్రచురించండి ఎంచుకోండి. 0 తో తిరిగి వచ్చి, మీ కొత్త రికార్డింగ్‌ను ఎంచుకోండి.';

  @override
  String get journeyNoRecordings =>
      'ఈ తరగతి మరియు సబ్జెక్టులో ఇంకా ఆడియో ఫైళ్ళు లేవు, కాబట్టి ఏదీ జోడించబడలేదు. మీరు మునుపటి స్క్రీన్‌కు తిరిగి వచ్చారు. ఒకటి జోడించడానికి, మళ్ళీ రికార్డింగ్ ఎంచుకుని, రికార్డింగ్ ఫైల్ అప్‌లోడ్ చేయడానికి 2 లేదా కొత్తది రికార్డ్ చేయడానికి 3 నొక్కండి.';

  @override
  String get journeyOpeningFiles =>
      'ఆడియో ఫైల్ కోసం ఫైల్ ఎంపికను తెరుస్తున్నాము.';

  @override
  String get journeyNoFile => 'ఏ ఫైల్‌నూ ఎంచుకోలేదు.';

  @override
  String get journeyUploading => 'అప్‌లోడ్ అవుతోంది. దయచేసి వేచి ఉండండి.';

  @override
  String get journeyUploadUnconfirmed =>
      'అప్‌లోడ్ నిర్ధారించబడలేదు. రెండుసార్లు రాకుండా ఉండటానికి, మళ్ళీ ప్రయత్నించే ముందు నా రికార్డింగ్‌లను తనిఖీ చేయండి.';

  @override
  String journeyUploaded(String title) {
    return '$title అప్‌లోడ్ చేయబడింది.';
  }

  @override
  String get journeyStorageUnavailable => 'ప్రయాణం నిల్వ అందుబాటులో లేదు.';

  @override
  String get journeyNothingInProgress =>
      'జరుగుతున్న ప్రయాణం ఏదీ లేదు. కొత్త ప్రయాణాల కోసం 2 నొక్కండి.';

  @override
  String get journeyTeacherUpdated =>
      'మీ ఉపాధ్యాయులు ఈ ప్రయాణాన్ని అప్‌డేట్ చేశారు. కొత్త వెర్షన్‌ను ఆఫ్‌లైన్‌లో ప్లే చేయడానికి దీన్ని మళ్ళీ డౌన్‌లోడ్ చేయండి.';

  @override
  String journeyStartOverMessage(String title) {
    return '$title ను దశ 1 నుండి మళ్ళీ ప్రారంభించాలా? మీరు ఇప్పటికే ఇచ్చిన జవాబులు మీ ఉపాధ్యాయులకు పంపబడతాయి.';
  }

  @override
  String journeyRemoveDownloadMessage(String title) {
    return 'ఈ ఫోన్ నుండి $title ను తొలగించాలా? ప్రయాణంలో మీరు ఉన్న చోటు ఉంచబడుతుంది. ఇంటర్నెట్‌తో దీన్ని మళ్ళీ డౌన్‌లోడ్ చేయవచ్చు.';
  }

  @override
  String journeyDownloadRemoved(String title) {
    return '$title డౌన్‌లోడ్ తొలగించబడింది.';
  }

  @override
  String journeyDownloading(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count రికార్డింగ్‌లు డౌన్‌లోడ్ అవుతున్నాయి. రద్దు చేయడానికి 0 నొక్కండి.',
      one: '1 రికార్డింగ్ డౌన్‌లోడ్ అవుతోంది. రద్దు చేయడానికి 0 నొక్కండి.',
    );
    return '$_temp0';
  }

  @override
  String journeyDownloaded(String title) {
    return 'డౌన్‌లోడ్ అయింది. మీరు ఇంటర్నెట్ లేకుండా $title ప్లే చేయవచ్చు.';
  }

  @override
  String get journeyCancellingDownload =>
      'డౌన్‌లోడ్ రద్దు చేస్తున్నాము. సేవ్ అయిన రికార్డింగ్‌లు ఉంచబడతాయి.';

  @override
  String journeyStepDetailsQuestion(
    String name,
    String options,
    String number,
    String explanation,
  ) {
    return '$name $options సరైన జవాబు: ఎంపిక $number. $explanation';
  }

  @override
  String get journeyNoExplanation => 'వివరణ లేదు.';

  @override
  String journeyExplanation(String text) {
    return 'వివరణ: $text';
  }

  @override
  String journeyStepNameRecording(String title) {
    return 'రికార్డింగ్. $title';
  }

  @override
  String get journeyUntitledRecording => 'పేరు లేని రికార్డింగ్';

  @override
  String journeyStepNameNarration(String text) {
    return 'వివరణ. $text';
  }

  @override
  String journeyStepNameQuestion(String text) {
    return 'ప్రశ్న. $text';
  }

  @override
  String journeyStepNamePoll(String text) {
    return 'పోల్. $text';
  }

  @override
  String get journeyStatusPublished => 'ప్రచురించబడింది';

  @override
  String get journeyStatusArchived => 'ఆర్కైవ్ చేయబడింది';

  @override
  String get journeyStatusDraft => 'డ్రాఫ్ట్, ఇంకా ప్రచురించబడలేదు';

  @override
  String journeyStatusWithChanges(String status) {
    return '$status, ప్రచురించని మార్పులతో';
  }

  @override
  String get journeyErrorChanged =>
      'ఈ ప్రయాణం మారింది. రిఫ్రెష్ చేసి మళ్ళీ ప్రయత్నించండి.';

  @override
  String get journeyErrorSignInExpired =>
      'మీ సైన్ ఇన్ గడువు ముగిసింది. మళ్ళీ సైన్ ఇన్ చేయండి.';

  @override
  String get journeyErrorPermission => 'దీన్ని చేయడానికి మీకు అనుమతి లేదు.';

  @override
  String get journeyErrorNotAvailable => 'ఈ ప్రయాణం ఇకపై అందుబాటులో లేదు.';

  @override
  String get journeyErrorInvalid =>
      'కొంత సమాచారాన్ని అంగీకరించలేకపోయాము. దాన్ని తనిఖీ చేసి మళ్ళీ ప్రయత్నించండి.';

  @override
  String get journeyErrorServer =>
      'పాఠశాల సర్వర్‌లో సమస్య వచ్చింది. తర్వాత మళ్ళీ ప్రయత్నించండి.';

  @override
  String get journeyErrorRequestFailed =>
      'అభ్యర్థన విజయవంతం కాలేదు. మళ్ళీ ప్రయత్నించండి.';

  @override
  String get journeyErrorResponseUnreadable =>
      'సర్వర్ జవాబును చదవలేకపోయాము. మళ్ళీ ప్రయత్నించే ముందు రిఫ్రెష్ చేయండి.';

  @override
  String get journeyErrorSavedUnreadable =>
      'సేవ్ అయిన ప్రయాణాన్ని చదవలేకపోయాము. మళ్ళీ ప్రయత్నించే ముందు రిఫ్రెష్ చేయండి.';

  @override
  String get journeyErrorListUnreadable => 'ప్రయాణాల జాబితాను చదవలేకపోయాము.';

  @override
  String get journeyErrorMismatch =>
      'సేవ్ అయిన ప్రయాణం సరిపోలలేదు. మళ్ళీ ప్రయత్నించే ముందు రిఫ్రెష్ చేయండి.';

  @override
  String get journeyErrorPreviewUnreadable =>
      'ప్రయాణం ప్రివ్యూను చదవలేకపోయాము.';

  @override
  String get journeyErrorRecordingsUnreadable =>
      'రికార్డింగ్‌ల జాబితాను చదవలేకపోయాము.';

  @override
  String get journeyErrorBankUnreadable => 'ప్రశ్నల బ్యాంక్‌ను చదవలేకపోయాము.';

  @override
  String get journeyErrorJourneyUnreadable => 'ఈ ప్రయాణాన్ని చదవలేకపోయాము.';

  @override
  String get journeyDownloadNeedsApp =>
      'ఆఫ్‌లైన్ ఉపయోగం కోసం డౌన్‌లోడ్ చేయడానికి SEEDS Android యాప్ అవసరం. బ్రౌజర్‌లో, మీరు ఆన్‌లైన్‌లో ఉన్నప్పుడు ప్రయాణాలు ప్లే అవుతాయి.';

  @override
  String get journeySignInFirst =>
      'అభ్యాస ప్రయాణాలను తెరిచే ముందు సైన్ ఇన్ చేయండి.';

  @override
  String get journeyStorageUnavailableDevice =>
      'ఈ పరికరంలో ప్రయాణం స్టోరేజ్ అందుబాటులో లేదు.';

  @override
  String get journeyStorageFull =>
      'ప్రయాణం స్టోరేజ్ అందుబాటులో లేదు. ఖాళీ స్థలం చూసి మళ్ళీ ప్రయత్నించండి. ఏదీ తొలగించబడలేదు.';

  @override
  String get journeyDownloadCancelled =>
      'డౌన్‌లోడ్ రద్దు చేయబడింది. ఇప్పటికే సేవ్ చేసిన రికార్డింగ్‌లు ఉంచబడ్డాయి.';

  @override
  String journeyRecordingsSaved(String done, String total) {
    return '$total రికార్డింగ్‌లలో $done సేవ్ అయ్యాయి.';
  }

  @override
  String get journeyLeaveJourney => 'ప్రయాణం నుండి బయటకు వెళ్ళండి';

  @override
  String get journeyLeaveSaved =>
      'ప్రయాణం నుండి బయటకు వెళ్ళండి. మీ స్థానం సేవ్ చేయబడింది';

  @override
  String get journeyKeyPlayAgain => 'మళ్ళీ ప్లే చేయండి';

  @override
  String get journeyKeySubmitAnswer => 'సమాధానం సమర్పించండి';

  @override
  String get journeyKeyRepeatQuestion => 'ప్రశ్నను మళ్ళీ వినండి';

  @override
  String get journeyKeySlowerSpeech => 'నెమ్మదిగా మాట్లాడు';

  @override
  String get journeyKeyWhereAmI => 'నేను ఎక్కడ ఉన్నాను';

  @override
  String get journeyKeyFasterSpeech => 'వేగంగా మాట్లాడు';

  @override
  String get journeyKeyNextStep => 'తదుపరి దశ';

  @override
  String get journeyKeyRepeatStep => 'ఈ దశను మళ్ళీ వినండి';

  @override
  String get journeyKeyReadAgain => 'మళ్ళీ చదవండి';

  @override
  String get journeyKeyPreviousContent => 'మునుపటి రికార్డింగ్ లేదా వివరణ';

  @override
  String journeyPreviewTitle(String title) {
    return 'ప్రివ్యూ: $title';
  }

  @override
  String get journeyPositionFinished => 'పూర్తయింది';

  @override
  String journeyStepPosition(String number, String total) {
    return '$total లో దశ $number';
  }

  @override
  String journeySelectedLabel(String label) {
    return '$label, ఎంచుకోబడింది';
  }

  @override
  String get journeyResultsLoading => 'ఫలితాలు లోడ్ అవుతున్నాయి.';

  @override
  String journeyResultsSummary(
    String completed,
    String eligible,
    String inProgress,
    String notStarted,
  ) {
    return '$eligible విద్యార్థులలో $completed మంది పూర్తి చేశారు. $inProgress మంది కొనసాగిస్తున్నారు, $notStarted మంది ప్రారంభించలేదు.';
  }

  @override
  String journeyResultsAverage(String percent) {
    return 'మొదటి ప్రయత్నంలో సగటు స్కోరు $percent శాతం.';
  }

  @override
  String get journeyResultFinished => 'పూర్తయింది';

  @override
  String get journeyResultNotStarted => 'ప్రారంభించలేదు';

  @override
  String journeyResultStudent(String name, String status) {
    return '$name. $status.';
  }

  @override
  String journeyResultFirstTime(String correct, String total) {
    return '$total లో $correct మొదటిసారే సరైనవి.';
  }

  @override
  String journeyResultWrongAnswers(String count) {
    return '$count తప్పు సమాధానాలు.';
  }

  @override
  String journeyResultQuestion(String number, String text, String answered) {
    return 'దశ $number. $text. $answered మంది సమాధానం ఇచ్చారు.';
  }

  @override
  String journeyResultRate(String percent) {
    return '$percent శాతం మొదటిసారే సరైనవి.';
  }

  @override
  String get journeyResultNoAnswers => 'ఇంకా సమాధానాలు లేవు.';

  @override
  String journeyResultAverageTries(String attempts) {
    return 'సగటున $attempts ప్రయత్నాలు.';
  }

  @override
  String journeyResultPoll(
    String number,
    String text,
    String answered,
    String options,
  ) {
    return 'దశ $number. $text. $answered మంది సమాధానం ఇచ్చారు. $options.';
  }

  @override
  String get journeyResultsStudentsTitle => 'విద్యార్థులు';

  @override
  String get journeyResultsQuestionsTitle => 'ప్రశ్నలు';

  @override
  String get journeyResultsPollsTitle => 'పోల్ సమాధానాలు';

  @override
  String journeyResultsTitle(String title) {
    return 'ఫలితాలు: $title';
  }

  @override
  String get journeyResultsHearSummary => 'తరగతి సారాంశం వినండి';

  @override
  String journeyResultsStudents(String count) {
    return 'విద్యార్థులు, $count';
  }

  @override
  String journeyResultsQuestions(String count) {
    return 'ప్రశ్నలు, $count. ఏ భాగాలు మళ్ళీ బోధించాలో చూపిస్తుంది';
  }

  @override
  String journeyResultsPolls(String count) {
    return 'పోల్ సమాధానాలు, $count';
  }

  @override
  String get journeyResultsRefresh => 'ఫలితాలను రిఫ్రెష్ చేయండి';

  @override
  String get journeyResultsNoStudents => 'ఈ తరగతిలో విద్యార్థులు ఎవరూ లేరు.';

  @override
  String get journeyResultsNoQuestions => 'ఈ ప్రయాణంలో ప్రశ్నలు లేవు.';

  @override
  String get journeyResultsNoPolls => 'ఈ ప్రయాణంలో పోల్స్ లేవు.';

  @override
  String get journeyNarrationLabel =>
      'ఫోన్ బిగ్గరగా చదివే మాటలు, ఉదాహరణకు: ఈ రోజు కొన్ని ఆహారాల గురించి విందాం';

  @override
  String journeyAddOptionTitle(String number) {
    return 'ఎంపిక $number జోడించాలా?';
  }

  @override
  String journeyQuestionOptionsSoFar(String count) {
    return 'ఇప్పటివరకు ప్రశ్నకు $count ఎంపికలు ఉన్నాయి.';
  }

  @override
  String journeyPollOptionsSoFar(String count) {
    return 'ఇప్పటివరకు పోల్‌కు $count ఎంపికలు ఉన్నాయి.';
  }

  @override
  String journeyAddOption(String number) {
    return 'ఎంపిక $number జోడించండి';
  }

  @override
  String get journeyNoMoreOptions => 'ఇంకా ఎంపికలు లేవు, కొనసాగించండి';

  @override
  String journeyOptionTitle(String number) {
    return 'ఎంపిక $number';
  }

  @override
  String journeyTypeOption(String number) {
    return 'ఎంపిక $number టైప్ చేయండి';
  }

  @override
  String get journeyReplayAutoNone =>
      'ఆటోమేటిక్: మళ్ళీ ప్లే చేయకుండా మళ్ళీ అడగండి';

  @override
  String journeyReplayAutoFrom(String number, String name) {
    return 'ఆటోమేటిక్: దశ $number, $name నుండి మళ్ళీ ప్లే చేయండి';
  }

  @override
  String get journeyAfterWrongTitle => 'తప్పు సమాధానం తర్వాత';

  @override
  String get journeyAfterWrongIntro =>
      'విద్యార్థి తప్పు సమాధానం ఇచ్చినప్పుడు, వారు మళ్ళీ ప్రయత్నించే ముందు ఏ భాగం మళ్ళీ ప్లే కావాలి?';

  @override
  String get journeyReplayChooseStep =>
      'మళ్ళీ ప్లే చేయడానికి వేరే దశను ఎంచుకోండి';

  @override
  String get journeyReplayWhichStep => 'ఏ దశ నుండి మళ్ళీ ప్లే చేయాలి?';

  @override
  String journeyStepLabel(String number, String name) {
    return 'దశ $number. $name';
  }

  @override
  String journeyReviewReplayFrom(String number) {
    return 'తప్పు సమాధానం తర్వాత, దశ $number మళ్ళీ ప్లే అవుతుంది.';
  }

  @override
  String get journeyReviewReplayAuto =>
      'తప్పు సమాధానం తర్వాత, ఆటోమేటిక్‌గా మళ్ళీ ప్లే అవుతుంది.';

  @override
  String get journeyCheckBeforeSaving => 'సేవ్ చేసే ముందు తనిఖీ చేయండి';

  @override
  String get journeySaveStep => 'ఈ దశను సేవ్ చేయండి';

  @override
  String get journeyRestartStep => 'ఈ దశను మళ్ళీ ప్రారంభించండి';

  @override
  String get journeyQuestionLabel => 'విద్యార్థులు వినే ప్రశ్నను టైప్ చేయండి';

  @override
  String get journeyWhichCorrect => 'ఏ ఎంపిక సరైనది?';

  @override
  String journeyCurrentlyCorrect(String number) {
    return 'ప్రస్తుతం ఎంపిక $number సరైనది.';
  }

  @override
  String journeyOptionChoice(String number, String text) {
    return 'ఎంపిక $number: $text';
  }

  @override
  String get journeyExplanationTitle => 'వివరణ';

  @override
  String get journeyExplanationLabel =>
      'సరైన సమాధానం చెప్పిన తర్వాత విద్యార్థులు వినేది';

  @override
  String get journeyPollQuestionTitle => 'పోల్ ప్రశ్న';

  @override
  String get journeyPollQuestionLabel =>
      'తప్పు సమాధానం లేని ప్రశ్న, ఉదాహరణకు: ఈ వారం మీరు అన్నం తిన్నారా?';

  @override
  String get journeyQuestionBank => 'ప్రశ్నల బ్యాంక్';

  @override
  String journeyBankQuestionLabel(String text, String count) {
    return '$text. $count ఎంపికలు.';
  }

  @override
  String get journeyAddRecording => 'రికార్డింగ్ జోడించండి';

  @override
  String get journeyChooseMyRecordings => 'నా రికార్డింగ్‌ల నుండి ఎంచుకోండి';

  @override
  String get journeyUploadRecordingFile => 'రికార్డింగ్ ఫైల్ అప్‌లోడ్ చేయండి';

  @override
  String get journeyRecordNew => 'కొత్త రికార్డింగ్ చేయండి';

  @override
  String get journeyMyRecordings => 'నా రికార్డింగ్‌లు';

  @override
  String get journeyRecordingName => 'రికార్డింగ్ పేరు';

  @override
  String get journeyRecordingNameLabel => 'ఈ రికార్డింగ్‌కు పేరు';

  @override
  String journeyOptionalLabel(String label) {
    return '$label. ఐచ్ఛికం, వదిలేయడానికి ఖాళీగా ఉంచండి';
  }

  @override
  String get journeyNothingEntered =>
      'ఏమీ నమోదు చేయలేదు. ఫీల్డ్‌పై ఓకే నొక్కి టైప్ చేయండి, లేదా వెనక్కి వెళ్ళడానికి 0 నొక్కండి.';

  @override
  String journeyTooLong(String max) {
    return 'చాలా పొడవుగా ఉంది. గరిష్టంగా $max అక్షరాలు వాడండి.';
  }

  @override
  String get journeySkipped => 'వదిలేయబడింది.';

  @override
  String journeyYouEntered(String text) {
    return 'మీరు నమోదు చేసినది: $text';
  }

  @override
  String get journeyMenuReady => 'సిద్ధంగా ఉంది.';

  @override
  String journeyMenuNothingAssigned(String number) {
    return '$number కు ఏదీ కేటాయించబడలేదు.';
  }

  @override
  String get journeyMenuPleaseWait =>
      'దయచేసి వేచి ఉండండి. ఇంకా పని జరుగుతోంది. వెనక్కి వెళ్ళడానికి 0 నొక్కండి.';

  @override
  String get journeyMenuWorking => 'పని జరుగుతోంది, దయచేసి వేచి ఉండండి.';

  @override
  String get journeyMenuReadDetails => 'వివరాలు మళ్ళీ చదవండి';

  @override
  String get journeyNoInternetDownloaded =>
      'ఇంటర్నెట్ లేదు. డౌన్‌లోడ్ చేసిన ప్రయాణాలు ఇంకా పనిచేస్తాయి. డౌన్‌లోడ్ చేసిన ప్రయాణాల కోసం 5 నొక్కండి.';

  @override
  String journeyWaitingToSend(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'పూర్తయిన $count ప్రయాణాలు పంపడానికి వేచి ఉన్నాయి.',
      one: 'పూర్తయిన 1 ప్రయాణం పంపడానికి వేచి ఉంది.',
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
    return '$newCount కొత్తవి, $inProgress కొనసాగుతున్నవి, $completed పూర్తయినవి, $downloaded డౌన్‌లోడ్ చేసినవి.';
  }

  @override
  String get journeyDownloadedJourneys => 'డౌన్‌లోడ్ చేసిన ప్రయాణాలు';

  @override
  String journeyDownloadedRow(String title, String steps) {
    return '$title. $steps దశలు. డౌన్‌లోడ్ చేయబడింది.';
  }

  @override
  String get journeyOfflineReason =>
      'దీనికి ఇంటర్నెట్ అవసరం. డౌన్‌లోడ్ చేసిన ప్రయాణాల కోసం 5 నొక్కండి.';

  @override
  String get journeyLearningJourneys => 'అభ్యాస ప్రయాణాలు';

  @override
  String get journeyStudentIntro =>
      'కథలు, పాఠాలు వినండి, మధ్యలో ప్రశ్నలకు సమాధానం ఇవ్వండి, అవసరమైన భాగాలను మళ్ళీ వినండి.';

  @override
  String get journeyContinueLast => 'నా చివరి ప్రయాణాన్ని కొనసాగించు';

  @override
  String journeyNewJourneys(String count) {
    return 'కొత్త ప్రయాణాలు, $count';
  }

  @override
  String get journeyNewJourneysTitle => 'కొత్త ప్రయాణాలు';

  @override
  String get journeyNoNewJourneys => 'కొత్త ప్రయాణాలు లేవు.';

  @override
  String journeyInProgressCount(String count) {
    return 'కొనసాగుతున్నవి, $count';
  }

  @override
  String get journeyInProgressTitle => 'కొనసాగుతున్న ప్రయాణాలు';

  @override
  String get journeyNothingInProgressShort => 'ఏదీ కొనసాగడం లేదు.';

  @override
  String journeyCompletedCount(String count) {
    return 'పూర్తయినవి, $count';
  }

  @override
  String get journeyCompletedTitle => 'పూర్తయిన ప్రయాణాలు';

  @override
  String get journeyNoneCompleted => 'ఇంకా ఏ ప్రయాణమూ పూర్తి కాలేదు.';

  @override
  String journeyDownloadedCount(String count) {
    return 'డౌన్‌లోడ్ చేసినవి, $count';
  }

  @override
  String get journeyNothingDownloaded =>
      'ఏదీ డౌన్‌లోడ్ చేయలేదు. ఒక ప్రయాణాన్ని తెరిచి డౌన్‌లోడ్ ఎంచుకోండి.';

  @override
  String get journeyNoInternetNotDownloaded =>
      'ఇంటర్నెట్ లేదు, ఈ ప్రయాణం డౌన్‌లోడ్ కూడా చేయలేదు.';

  @override
  String get journeyStartOverTitle => 'మొదటి నుండి ప్రారంభించాలా?';

  @override
  String get journeyStartOver => 'మొదటి నుండి ప్రారంభించండి';

  @override
  String get journeyRemoveDownloadTitle => 'డౌన్‌లోడ్ తొలగించాలా?';

  @override
  String get journeyRemoveDownload => 'డౌన్‌లోడ్ తొలగించండి';

  @override
  String journeySavedRecordings(String done, String total) {
    return '$total రికార్డింగ్‌లలో $done సేవ్ చేయబడ్డాయి.';
  }

  @override
  String get journeyDownloadedOnPhone => 'ఈ ఫోన్‌లో డౌన్‌లోడ్ చేయబడింది.';

  @override
  String get journeyNotDownloadedShort => 'డౌన్‌లోడ్ చేయలేదు.';

  @override
  String get journeyStartedThis => 'మీరు ఈ ప్రయాణం ప్రారంభించారు.';

  @override
  String get journeyWorksOffline =>
      'డౌన్‌లోడ్ చేయబడింది. ఇంటర్నెట్ లేకుండా పనిచేస్తుంది.';

  @override
  String get journeyContinueJourney => 'ప్రయాణం కొనసాగించండి';

  @override
  String get journeyStartJourney => 'ప్రయాణం ప్రారంభించండి';

  @override
  String get journeyHearAbout => 'ఈ ప్రయాణం గురించి వినండి';

  @override
  String get journeyDownloadOffline =>
      'ఇంటర్నెట్ లేకుండా ప్లే చేయడానికి డౌన్‌లోడ్ చేయండి';

  @override
  String get journeyDownloadInProgress =>
      'డౌన్‌లోడ్ జరుగుతోంది. దాన్ని రద్దు చేయడానికి 0 నొక్కండి.';

  @override
  String get journeyStartFromBeginning => 'మళ్ళీ మొదటి నుండి ప్రారంభించండి';

  @override
  String get journeyNotStartedYet => 'మీరు ఇంకా ఈ ప్రయాణం ప్రారంభించలేదు.';

  @override
  String journeyLatestLoaded(String message) {
    return '$message తాజా వెర్షన్ ఇప్పుడు లోడ్ చేయబడింది.';
  }

  @override
  String journeyTeacherSummary(
    String drafts,
    String published,
    String archived,
  ) {
    return '$drafts డ్రాఫ్ట్‌లు, $published ప్రచురించబడినవి, $archived ఆర్కైవ్ చేయబడినవి.';
  }

  @override
  String get journeyNewJourneyTitle => 'కొత్త అభ్యాస ప్రయాణం';

  @override
  String get journeyNameExample =>
      'ప్రయాణం పేరు, ఉదాహరణకు: మన చుట్టూ ఉన్న ఆహారం';

  @override
  String get journeyRefreshFirst =>
      'ముందుగా జాబితాను రిఫ్రెష్ చేయడానికి 5 నొక్కండి.';

  @override
  String journeyTeacherIntro(String workspace) {
    return '$workspace. విద్యార్థుల కోసం రికార్డింగ్‌లు, వివరణ, ప్రశ్నలు మరియు పోల్స్‌తో ఒక క్రమాన్ని తయారు చేయండి.';
  }

  @override
  String get journeyCreateNew => 'కొత్త ప్రయాణం సృష్టించండి';

  @override
  String journeyDraftsCount(String count) {
    return 'డ్రాఫ్ట్‌లు, $count';
  }

  @override
  String get journeyDraftJourneys => 'డ్రాఫ్ట్ ప్రయాణాలు';

  @override
  String get journeyNoDrafts => 'డ్రాఫ్ట్‌లు లేవు.';

  @override
  String journeyPublishedCount(String count) {
    return 'ప్రచురించబడినవి, $count';
  }

  @override
  String get journeyPublishedJourneys => 'ప్రచురించబడిన ప్రయాణాలు';

  @override
  String get journeyNothingPublished => 'ఇంకా ఏదీ ప్రచురించబడలేదు.';

  @override
  String journeyArchivedCount(String count) {
    return 'ఆర్కైవ్ చేయబడినవి, $count';
  }

  @override
  String get journeyArchivedJourneys => 'ఆర్కైవ్ చేయబడిన ప్రయాణాలు';

  @override
  String get journeyNothingArchived => 'ఏదీ ఆర్కైవ్ చేయబడలేదు.';

  @override
  String get journeyRefreshList => 'జాబితాను రిఫ్రెష్ చేయండి';

  @override
  String journeyOverviewSummary(
    String status,
    String steps,
    String questions,
    String graded,
    String retries,
  ) {
    return '$status. $steps దశలు, $questions ప్రశ్నలు. $graded. $retries';
  }

  @override
  String get journeyGraded => 'మార్కులతో';

  @override
  String get journeyNotGraded => 'మార్కులు లేవు';

  @override
  String journeyRetriesPerQuestion(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ప్రతి ప్రశ్నకు $count మళ్ళీ ప్రయత్నాలు.',
      one: 'ప్రతి ప్రశ్నకు 1 మళ్ళీ ప్రయత్నం.',
    );
    return '$_temp0';
  }

  @override
  String get journeySteps => 'దశలు';

  @override
  String journeyAddStepTitle(String number) {
    return 'దశ $number జోడించండి';
  }

  @override
  String get journeyAddStepIntro =>
      'కొత్త దశ చివరలో చేరుతుంది. తర్వాత దాన్ని జరపవచ్చు.';

  @override
  String get journeyChoiceRecording => 'రికార్డింగ్';

  @override
  String get journeyChoiceNarration => 'ఫోన్ చదివే వివరణ';

  @override
  String get journeyChoiceQuestion => 'ప్రశ్న';

  @override
  String get journeyChoicePoll => 'పోల్, తప్పు సమాధానం లేదు';

  @override
  String journeySavedAsStep(String number, String name) {
    return 'దశ $number గా సేవ్ చేయబడింది. $name';
  }

  @override
  String get journeyAddQuestion => 'ప్రశ్న జోడించండి';

  @override
  String get journeyWriteNewQuestion => 'కొత్త ప్రశ్న రాయండి';

  @override
  String get journeyChooseFromBank => 'నా ప్రశ్నల బ్యాంక్ నుండి ఎంచుకోండి';

  @override
  String get journeyHearAndEdit => 'దశలను విని సవరించండి';

  @override
  String get journeyNoStepsYet =>
      'ఇంకా దశలు లేవు. ఒకటి జోడించడానికి 2 నొక్కండి.';

  @override
  String get journeyAddStep => 'దశ జోడించండి';

  @override
  String get journeyPreviewAsStudent => 'విద్యార్థిగా ప్రివ్యూ చూడండి';

  @override
  String get journeyAddStepFirst => 'ముందుగా ఒక దశ జోడించండి.';

  @override
  String get journeyPublishToStudents => 'విద్యార్థులకు ప్రచురించండి';

  @override
  String get journeyPublishChanges => 'మార్పులను ప్రచురించండి';

  @override
  String get journeyStudentResults => 'విద్యార్థుల ఫలితాలు';

  @override
  String get journeyMoreOptions => 'మరిన్ని ఎంపికలు';

  @override
  String journeyStepSaved(String number) {
    return 'దశ $number సేవ్ చేయబడింది.';
  }

  @override
  String journeyMoved(String number, String total) {
    return 'జరపబడింది. ఇది ఇప్పుడు $total లో దశ $number.';
  }

  @override
  String journeyRemoveStepTitle(String number) {
    return 'దశ $number తొలగించాలా?';
  }

  @override
  String journeyRemoveStepMessage(String name) {
    return '$name తొలగించాలా? రికార్డింగ్‌లు మీ లైబ్రరీలోనే ఉంటాయి. ఈ దశను మళ్ళీ ప్లే చేసే ప్రశ్నలు బదులుగా ఆటోమేటిక్‌గా మళ్ళీ ప్లే చేస్తాయి.';
  }

  @override
  String get journeyRemoveStep => 'దశ తొలగించండి';

  @override
  String get journeyStepNotFound => 'దశ కనబడలేదు';

  @override
  String get journeyStepWasRemoved =>
      'ఈ దశ తొలగించబడింది. వెనక్కి వెళ్ళడానికి 0 నొక్కండి.';

  @override
  String get journeyHearStepInFull => 'ఈ దశను పూర్తిగా వినండి';

  @override
  String get journeyEditStep => 'ఈ దశను సవరించండి';

  @override
  String get journeyMoveEarlier => 'ముందుకు జరపండి';

  @override
  String get journeyAlreadyFirst => 'ఇది ఇప్పటికే మొదటి దశ.';

  @override
  String get journeyMoveLater => 'వెనక్కి జరపండి';

  @override
  String get journeyAlreadyLast => 'ఇది ఇప్పటికే చివరి దశ.';

  @override
  String get journeyRemoveThisStep => 'ఈ దశను తొలగించండి';

  @override
  String get journeyRenameTitle => 'ప్రయాణం పేరు మార్చండి';

  @override
  String get journeyNameLabel => 'ప్రయాణం పేరు';

  @override
  String journeyRenamed(String title) {
    return 'పేరు $title గా మార్చబడింది.';
  }

  @override
  String get journeyArchiveTitle => 'ఈ ప్రయాణాన్ని ఆర్కైవ్ చేయాలా?';

  @override
  String get journeyRestoreTitle => 'ఈ ప్రయాణాన్ని పునరుద్ధరించాలా?';

  @override
  String get journeyArchive => 'ఆర్కైవ్ చేయండి';

  @override
  String get journeyRestore => 'పునరుద్ధరించండి';

  @override
  String get journeyDeleteDraftTitle => 'ఈ డ్రాఫ్ట్ తొలగించాలా?';

  @override
  String get journeyDeleteDraft => 'డ్రాఫ్ట్ తొలగించండి';

  @override
  String get journeyPublishFirst => 'ముందుగా ప్రయాణాన్ని ప్రచురించండి.';

  @override
  String get journeyRename => 'పేరు మార్చండి';

  @override
  String get journeyGradingNowGraded =>
      'మార్కులు మరియు ప్రయత్నాలు, ఇప్పుడు మార్కులతో';

  @override
  String get journeyGradingNowNotGraded =>
      'మార్కులు మరియు ప్రయత్నాలు, ఇప్పుడు మార్కులు లేవు';

  @override
  String get journeyDuplicate => 'కొత్త డ్రాఫ్ట్‌గా కాపీ చేయండి';

  @override
  String get journeyArchiveHide => 'ఆర్కైవ్ చేయండి, విద్యార్థుల నుండి దాచండి';

  @override
  String get journeyRestoreForStudents => 'విద్యార్థుల కోసం పునరుద్ధరించండి';

  @override
  String get journeyDeleteThisDraft => 'ఈ డ్రాఫ్ట్ తొలగించండి';

  @override
  String get journeyGradedSummary =>
      'మార్కులతో: ప్రతి ప్రశ్నకు మొదటి ప్రయత్నం స్కోరులో లెక్కించబడుతుంది.';

  @override
  String get journeyNotGradedSummary =>
      'మార్కులు లేవు: ప్రశ్నలు అభ్యాసం కోసం మాత్రమే.';

  @override
  String journeyMoreTriesSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'తప్పు సమాధానం తర్వాత, విద్యార్థికి మరో $count ప్రయత్నాలు లభిస్తాయి, ముందుగా విషయం మళ్ళీ ప్లే అవుతుంది.',
      one:
          'తప్పు సమాధానం తర్వాత, విద్యార్థికి మరో 1 ప్రయత్నం లభిస్తుంది, ముందుగా విషయం మళ్ళీ ప్లే అవుతుంది.',
    );
    return '$_temp0';
  }

  @override
  String get journeyGradingTitle => 'మార్కులు మరియు ప్రయత్నాలు';

  @override
  String get journeyTurnGradingOff => 'మార్కులు ఆపివేయండి';

  @override
  String get journeyTurnGradingOn => 'మార్కులు ఆన్ చేయండి';

  @override
  String get journeyGradingIsOff => 'మార్కులు ఆఫ్‌లో ఉన్నాయి.';

  @override
  String get journeyGradingIsOn => 'మార్కులు ఆన్‌లో ఉన్నాయి.';

  @override
  String get journeyFewerTries => 'తక్కువ ప్రయత్నాలు';

  @override
  String get journeyMoreTries => 'ఎక్కువ ప్రయత్నాలు';

  @override
  String get journeyLoadingSummary => 'సారాంశం లోడ్ అవుతోంది.';

  @override
  String get journeyNoProblems => 'సమస్యలు లేవు.';

  @override
  String journeyProblems(String issues) {
    return 'ప్రచురించే ముందు సరిచేయాల్సిన సమస్యలు: $issues';
  }

  @override
  String journeyThingsToCheck(String warnings) {
    return 'తనిఖీ చేయాల్సినవి: $warnings';
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
    return '$title. $steps దశలు: $recordings రికార్డింగ్‌లు, $narrations వివరణలు, $questions ప్రశ్నలు, $polls పోల్స్. $graded.';
  }

  @override
  String journeyPublishTitle(String title) {
    return '$title ప్రచురించాలా?';
  }

  @override
  String get journeyPublishMessage =>
      'ఈ తరగతిలోని విద్యార్థులందరూ దీన్ని ప్లే చేయగలరు, డౌన్‌లోడ్ చేయగలరు, వారికి నోటిఫికేషన్ వస్తుంది.';

  @override
  String get journeyPublishNow => 'ఇప్పుడే ప్రచురించండి';

  @override
  String get journeyPublishedShort => 'ప్రచురించబడింది.';

  @override
  String get journeyReviewBeforePublishing => 'ప్రచురించే ముందు సమీక్షించండి';

  @override
  String get journeyFixProblemsFirst =>
      'ముందుగా సమస్యలను సరిచేయండి. వాటిని వినడానికి 8 నొక్కండి.';

  @override
  String get journeyPreviewFirst => 'ముందుగా విద్యార్థిగా ప్రివ్యూ చూడండి';

  @override
  String undoOffer(String seconds) {
    return 'రద్దు చేయడానికి $seconds సెకన్లలోపు 1 నొక్కండి.';
  }

  @override
  String undoDone(String action) {
    return 'రద్దు చేయబడింది. $action వెనక్కి తీసుకోబడింది.';
  }

  @override
  String get undoFailed =>
      'రద్దు చేయడం పని చేయలేదు. అంశాన్ని చెక్ చేసి, అవసరమైతే మళ్ళీ జోడించండి.';

  @override
  String get uiBack => 'వెనక్కి';

  @override
  String get uiCancel => 'రద్దు చేయండి';

  @override
  String get uiContinue => 'కొనసాగించండి';

  @override
  String get uiNotNow => 'ఇప్పుడు కాదు';

  @override
  String uiPressFor(String key, String action) {
    return '$action కోసం $key నొక్కండి.';
  }

  @override
  String uiLabelUnavailable(String label) {
    return '$label, అందుబాటులో లేదు';
  }

  @override
  String get uiAlreadyHome => 'మీరు ఇప్పటికే హోమ్‌లో ఉన్నారు.';

  @override
  String uiNotAvailableNow(String label) {
    return '$label ఇప్పుడు అందుబాటులో లేదు.';
  }

  @override
  String uiListLoading(String title) {
    return '$title లోడ్ అవుతోంది. వెనక్కి వెళ్ళడానికి 0 నొక్కండి.';
  }

  @override
  String uiListPage(String title, String number) {
    return '$title. పేజీ $number.';
  }

  @override
  String uiListScreenName(String title, String number) {
    return '$title. పేజీ $number';
  }

  @override
  String get uiListNoMatches => 'సరిపోయే అంశాలు ఏవీ లేవు.';

  @override
  String get uiListHelp =>
      'రిఫ్రెష్‌తో సహా జాబితా ఎంపికల కోసం 6 నొక్కండి. మునుపటి పేజీ కోసం 7 నొక్కండి. అన్ని అంశాలను వెతకడానికి 8 నొక్కండి. తదుపరి పేజీ కోసం 9 నొక్కండి. వెనక్కి వెళ్ళడానికి 0 నొక్కండి. అంశాలు మరియు పేజీ నియంత్రణల మధ్య కదలడానికి D-pad పైకి, కిందకు ఉపయోగించండి, ఎంచుకోవడానికి ఓకే నొక్కండి. సహాయాన్ని మళ్ళీ వినడానికి స్టార్ నొక్కండి. స్వరాన్ని ఆపడానికి హ్యాష్ నొక్కండి.';

  @override
  String get uiListLoadFailed =>
      'ఈ పేజీ లోడ్ కాలేదు. మళ్ళీ ప్రయత్నించే ఎంపికల కోసం 6 నొక్కండి. మీ మునుపటి పేజీ అలాగే ఉంది.';

  @override
  String get uiListLoadingWait =>
      'లోడ్ అవుతోంది. దయచేసి వేచి ఉండండి, లేదా వెనక్కి వెళ్ళడానికి 0 నొక్కండి.';

  @override
  String uiListNoItem(String number) {
    return 'ఈ పేజీలో $numberకు ఏ అంశమూ కేటాయించబడలేదు.';
  }

  @override
  String get uiListFirstPage => 'ఇది మొదటి పేజీ.';

  @override
  String get uiListLastPage => 'ఇది చివరి పేజీ.';

  @override
  String uiListSearchTitle(String title) {
    return '$title వెతకండి';
  }

  @override
  String get uiListSearchLabel => 'అందుబాటులో ఉన్న అన్ని అంశాలను వెతకండి';

  @override
  String get uiListSearchTooLong =>
      'వెతకడానికి గరిష్ఠంగా 200 అక్షరాలు ఉపయోగించండి.';

  @override
  String get uiListOptions => 'జాబితా ఎంపికలు';

  @override
  String get uiListSearch => 'వెతకండి';

  @override
  String get uiListClearSearch => 'వెతుకులాట తొలగించండి';

  @override
  String get uiListRefreshPage => 'ఈ పేజీని రిఫ్రెష్ చేయండి';

  @override
  String get uiListRetry => 'మళ్ళీ ప్రయత్నించండి';

  @override
  String get uiListFilters => 'ఫిల్టర్‌లు';

  @override
  String get uiListPreviousPage => 'మునుపటి పేజీ';

  @override
  String get uiListSearchAll => 'అన్ని అంశాలను వెతకండి';

  @override
  String get uiListNextPage => 'తదుపరి పేజీ';

  @override
  String get uiListSections =>
      'అంశాలు, జాబితా ఎంపికలు, మునుపటి పేజీ, వెతకండి, తదుపరి పేజీ మరియు వెనక్కి';

  @override
  String get uiWaitingConfirmation =>
      'నిర్ధారణ కోసం వేచి ఉంది. దయచేసి వేచి ఉండండి.';

  @override
  String get uiFinishWord =>
      'ప్రస్తుత పదాన్ని టైప్ చేయడం పూర్తి చేసి, తర్వాత ఓకే నొక్కండి.';

  @override
  String get uiStepFailed =>
      'ఈ దశ పూర్తి కాలేదు. మీరు నమోదు చేసినది అలాగే ఉంది. మళ్ళీ ప్రయత్నించండి.';

  @override
  String get uiPasswordVisible => 'పాస్‌వర్డ్ కనిపిస్తోంది.';

  @override
  String get uiPasswordHidden => 'పాస్‌వర్డ్ దాచబడింది.';

  @override
  String uiTextStepScreen(String title, String label) {
    return '$title. $label. ఎడిట్ చేస్తున్నారు. ముగించడానికి ఓకే నొక్కండి, లేదా ఫీల్డ్ నుండి బయటకు రావడానికి పైకి లేదా కిందకు ఉపయోగించండి.';
  }

  @override
  String get uiShowOrHidePassword => 'పాస్‌వర్డ్ చూపండి లేదా దాచండి';

  @override
  String get uiDateEnterNumbers =>
      'ప్రతి తేదీ మరియు సమయ ఫీల్డ్‌లో ఒక సంఖ్యను నమోదు చేయండి.';

  @override
  String uiDateChooseValid(String from, String to) {
    return '$from నుండి $to వరకు సరైన తేదీని ఎంచుకోండి.';
  }

  @override
  String get uiDateInvalid =>
      'సరైన తేదీ, 0 నుండి 23 వరకు గంట, మరియు 0 నుండి 59 వరకు నిమిషం నమోదు చేయండి.';

  @override
  String uiDateChoose(String from, String to) {
    return '$from నుండి $to వరకు ఒక తేదీని ఎంచుకోండి.';
  }

  @override
  String uiRange(String from, String to) {
    return '$from నుండి $to';
  }

  @override
  String get uiYear => 'సంవత్సరం';

  @override
  String get uiMonth => 'నెల';

  @override
  String get uiDay => 'రోజు';

  @override
  String get uiHour => 'గంట';

  @override
  String get uiMinute => 'నిమిషం';

  @override
  String uiDateFieldEmpty(String name, String range) {
    return '$name, $range, ప్రస్తుతం ఖాళీగా ఉంది';
  }

  @override
  String uiDateFieldValue(String name, String range, String value) {
    return '$name, $range, ప్రస్తుతం $value';
  }

  @override
  String uiDateScreen(String from, String to) {
    return 'ఫోన్ యొక్క స్థానిక సమయంలో తేదీ మరియు సమయం సెట్ చేయండి. $from నుండి $to వరకు ఒక తేదీని ఎంచుకోండి.';
  }

  @override
  String get uiSaveDateTime => 'తేదీ మరియు సమయం సేవ్ చేయండి';

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
    return '$label: $value, $totalలో $position';
  }

  @override
  String uiChoiceChange(String description) {
    return '$description. మార్చడానికి ఎడమ లేదా కుడి ఉపయోగించండి';
  }

  @override
  String get startupPreferencesFailed =>
      'కొన్ని ప్రాధాన్యతలు లోడ్ కాలేదు. డిఫాల్ట్‌లు ఉపయోగించబడుతున్నాయి.';

  @override
  String get startupNotificationsTitle => 'సెషన్ నోటిఫికేషన్‌లు';

  @override
  String get startupNotificationsMessage =>
      'సెషన్ ఆహ్వానాలు మరియు అప్‌డేట్‌ల గురించి చెప్పడానికి SEEDS నోటిఫికేషన్‌లను ఉపయోగిస్తుంది. మీరు ఇప్పుడు కాదు ఎంచుకున్నా యాప్‌ను ఉపయోగించడం కొనసాగించవచ్చు.';

  @override
  String get startupEnableNotifications => 'నోటిఫికేషన్‌లు ఆన్ చేయండి';

  @override
  String get startupLoading => 'SEEDS లోడ్ అవుతోంది';

  @override
  String get startupWelcomeScreenName => 'SEEDS కు స్వాగతం';

  @override
  String get startupLoginButton => 'లాగిన్, బటన్';

  @override
  String get startupRegisterButton => 'నమోదు, బటన్';

  @override
  String get startupSettingsButton => 'సెట్టింగ్‌లు, బటన్';

  @override
  String get startupRepeatInstructionsButton => 'సూచనలు మళ్ళీ వినండి, బటన్';

  @override
  String get authSimAutofillOptional => 'SIM నుండి ఫోన్ నంబర్ ఆటోఫిల్ ఐచ్ఛికం';

  @override
  String get authRegisteredNowLogIn =>
      'నమోదు అయింది. ఇప్పుడు లాగిన్ చేయండి. ఫోన్ నంబర్ ఫీల్డ్. సహాయం కోసం స్టార్ నొక్కండి.';

  @override
  String get authSimUnavailableOnDevice =>
      'ఈ ఫోన్‌లో SIM సూచనలు అందుబాటులో లేవు. ఫోన్ నంబర్‌ను మీరే నమోదు చేయండి.';

  @override
  String get authSimDialogTitle => 'ఐచ్ఛిక SIM ఆటోఫిల్';

  @override
  String get authSimDialogMessage =>
      'ఈ ఫోన్ నుండి ఐచ్ఛిక ఫోన్ నంబర్ సూచనలను చదవాలా? ఫోన్ ఫీల్డ్‌లో పెట్టే ముందు మీరు ఒక సూచనను ఎంచుకుంటారు. ఇది ఖాతా ఎవరిదో ధృవీకరించదు. లాగిన్, నమోదు, Wi-Fi లేదా సెషన్‌లో చేరడానికి SIM యాక్సెస్ ఎప్పుడూ అవసరం లేదు.';

  @override
  String get authSimDialogConfirm => 'SIM సూచనలను చదవండి';

  @override
  String get authSimAutofillSkipped =>
      'SIM ఆటోఫిల్ దాటవేయబడింది. ఫోన్ నంబర్‌ను మీరే నమోదు చేయండి.';

  @override
  String get authSimDetecting => 'SIM కార్డ్‌ను గుర్తిస్తోంది...';

  @override
  String get authSimAutofillUnavailable =>
      'SIM ఆటోఫిల్ అందుబాటులో లేదు. ఫోన్ నంబర్‌ను మీరే నమోదు చేయండి.';

  @override
  String get authSimNoneFound =>
      'SIM కార్డ్ కనబడలేదు. ఫోన్ నంబర్‌ను మీరే నమోదు చేయండి.';

  @override
  String authSimCardsDetected(String count) {
    return '$count SIM కార్డ్‌లు కనబడ్డాయి. దయచేసి ఒకటి ఎంచుకోండి.';
  }

  @override
  String get authSimSuggestionUnavailable =>
      'SIM సూచన అందుబాటులో లేదు. ఫోన్ నంబర్‌ను మీరే నమోదు చేయండి.';

  @override
  String authSimOptionLabel(String number, String carrier) {
    return 'SIM $number, $carrier';
  }

  @override
  String get authSimUnknownCarrier => 'తెలియని నెట్‌వర్క్';

  @override
  String get authSimSelectedFilled =>
      'ఎంచుకున్న సూచన నింపబడింది. ఇది ఖాతా మీదే అని రుజువు కాదు.';

  @override
  String get authSimSuggestionFilledSpoken =>
      'ఫోన్ నంబర్ సూచన నింపబడింది. సైన్ ఇన్ చేయడానికి మీ పాస్‌వర్డ్ నమోదు చేయండి. సైన్ ఇన్ పంపబడలేదు.';

  @override
  String get authErrorEnterPhone => 'మీ ఫోన్ నంబర్ నమోదు చేయండి.';

  @override
  String get authErrorInvalidPhone => 'సరైన 10 అంకెల ఫోన్ నంబర్ నమోదు చేయండి.';

  @override
  String get authErrorEnterPassword => 'మీ పాస్‌వర్డ్ నమోదు చేయండి.';

  @override
  String get authErrorPasswordTooShort =>
      'పాస్‌వర్డ్‌లో కనీసం 6 అక్షరాలు ఉండాలి.';

  @override
  String get authErrorInvalidServerResponse => 'సర్వర్ నుండి సరికాని స్పందన';

  @override
  String get authErrorNotRegisteredAdmin =>
      'ఈ ఫోన్ నంబర్ నిర్వాహకుల ఖాతాగా నమోదు కాలేదు. ఖాతా రకాన్ని ఎంచుకోవడానికి 1, 2 లేదా 3 నొక్కండి.';

  @override
  String get authErrorNotRegisteredTeacher =>
      'ఈ ఫోన్ నంబర్ ఉపాధ్యాయుల ఖాతాగా నమోదు కాలేదు. ఖాతా రకాన్ని ఎంచుకోవడానికి 1, 2 లేదా 3 నొక్కండి.';

  @override
  String get authErrorNotRegisteredStudent =>
      'ఈ ఫోన్ నంబర్ విద్యార్థి ఖాతాగా నమోదు కాలేదు. ఖాతా రకాన్ని ఎంచుకోవడానికి 1, 2 లేదా 3 నొక్కండి.';

  @override
  String get authErrorResponseNotVerified =>
      'సైన్ ఇన్ స్పందనను ధృవీకరించలేకపోయాము. దయచేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String authErrorMovedToPhone(String message) {
    return '$message ఫోన్ నంబర్ ఫీల్డ్‌కు వెళ్లింది.';
  }

  @override
  String authErrorMovedToAccountType(String message) {
    return '$message ఖాతా రకానికి వెళ్లింది.';
  }

  @override
  String authErrorMovedToPassword(String message) {
    return '$message పాస్‌వర్డ్ ఫీల్డ్‌కు వెళ్లింది.';
  }

  @override
  String get authRoleAdministrator => 'నిర్వాహకులు';

  @override
  String get authRoleTeacher => 'ఉపాధ్యాయులు';

  @override
  String get authRoleStudent => 'విద్యార్థి';

  @override
  String get authRecoveryStep1 =>
      'మీ పాస్‌వర్డ్‌ను రీసెట్ చేయమని మీ పాఠశాల నిర్వాహకులను అడగండి. వారు మీరు ఎవరో నేరుగా కలిసి తనిఖీ చేయాలి. ఫోన్ నంబర్ లేదా SIM మాత్రమే దానిని రుజువు చేయదు. మీ శాశ్వత పాస్‌వర్డ్‌ను ఎవరికీ ఎప్పుడూ పంపకండి.';

  @override
  String get authRecoveryStep2 =>
      'నిర్వాహకులు మీకు 12 అంకెల ప్రైవేట్ తాత్కాలిక పాస్‌వర్డ్ ఇస్తారు. ఇది 24 గంటలు పనిచేస్తుంది. గడువు ముగిస్తే కొత్తది అడగండి.';

  @override
  String get authRecoveryStep3 =>
      'మీ ఫోన్ నంబర్ మరియు తాత్కాలిక పాస్‌వర్డ్‌తో సైన్ ఇన్ చేసి, తర్వాత కొత్త పాస్‌వర్డ్ ఎంచుకోండి.';

  @override
  String get authRecoveryStep4 =>
      '10 తప్పు ప్రయత్నాల తర్వాత, సైన్ ఇన్ 15 నిమిషాలు ఆగిపోతుంది. రికవరీకి ఇంటర్నెట్ అవసరం. ఇతర ఫోన్‌లలో ఇప్పటికే ఉన్న ఫైల్‌లు వెంటనే తొలగించబడవు.';

  @override
  String get authRecoveryHelpTitle => 'పాస్‌వర్డ్ రికవరీ సహాయం';

  @override
  String authRecoveryHelpIntro(String count) {
    return '$count చిన్న దశలు. ప్రతి దశను వినడానికి కిందికి నొక్కండి.';
  }

  @override
  String get authBackToLogin => 'లాగిన్‌కు తిరిగి వెళ్లండి';

  @override
  String get authBackToLoginButton => 'లాగిన్‌కు తిరిగి వెళ్లండి, బటన్';

  @override
  String get notesRecordingStarted =>
      'రికార్డింగ్ ప్రారంభమైంది. పూర్తయినప్పుడు రికార్డింగ్ ఆపండి ఎంచుకోండి.';

  @override
  String get notesActionNotConfirmed =>
      'ఈ నోట్ చర్య నిర్ధారించబడలేదు. స్టోరేజ్, మైక్రోఫోన్ అనుమతి లేదా కనెక్షన్ తనిఖీ చేయండి. మీ డ్రాఫ్ట్‌లు ఉంచబడ్డాయి.';

  @override
  String get notesNoneYet => 'ఇంకా ప్రైవేట్ నోట్స్ లేవు.';

  @override
  String notesLoaded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ప్రైవేట్ నోట్స్ లోడ్ అయ్యాయి.',
      one: '1 ప్రైవేట్ నోట్ లోడ్ అయింది.',
    );
    return '$_temp0';
  }

  @override
  String get notesNameDialogTitle => 'ప్రైవేట్ నోట్‌కు పేరు పెట్టండి';

  @override
  String get notesDefaultTitle => 'ప్రైవేట్ నోట్';

  @override
  String notesDefaultLessonTitle(String lesson) {
    return '$lesson కోసం నోట్';
  }

  @override
  String get notesRecordConfirmTitle => 'ప్రైవేట్ నోట్ రికార్డ్ చేయాలా?';

  @override
  String notesRecordConfirmMessage(String lessonPoint) {
    return 'మైక్రోఫోన్ ఆడియోను ఈ ఫోన్‌లో మాత్రమే రికార్డ్ చేయండి, గరిష్టంగా ఐదు నిమిషాలు లేదా నోట్స్ కోసం ప్రత్యేకంగా మిగిలిన 10 MB వరకు. మాట ఆదేశాలు వాడే ముందు రికార్డింగ్ ఆపండి. యాప్ స్వరం, ఈ స్క్రీన్ నుండి వెళ్ళడం లేదా యాప్‌కు అంతరాయం రికార్డింగ్‌ను ఆపుతాయి. లైవ్ సెషన్ రికార్డింగ్ నిరోధించబడింది. $lessonPoint ఆటోమేటిక్ అప్‌లోడ్ లేదా షేరింగ్ ఉండదు. మైక్రోఫోన్ అనుమతి అడగవచ్చు.';
  }

  @override
  String notesLessonPointSeconds(String seconds) {
    return 'పాఠం స్థానం: $seconds సెకన్లు.';
  }

  @override
  String get notesStartRecording => 'రికార్డింగ్ ప్రారంభించండి';

  @override
  String get notesDoNotRecord => 'రికార్డ్ చేయవద్దు';

  @override
  String get notesReviewStoppedChanged =>
      'స్క్రీన్ లేదా యాప్ మారినందున సమీక్ష ఆగింది. సమీక్షించడానికి ఈ నోట్‌ను మళ్ళీ తెరవండి.';

  @override
  String get notesReviewStoppedAccount =>
      'మీ ఖాతా మారినందున సమీక్ష ఆగింది. ప్రైవేట్ నోట్స్ మళ్ళీ తెరవండి.';

  @override
  String get notesRenameDialogTitle => 'ప్రైవేట్ నోట్ పేరు మార్చండి';

  @override
  String notesRemoveTitle(String title) {
    return '$title తొలగించాలా?';
  }

  @override
  String notesRemoveMessage(String title) {
    return 'ఈ ఫోన్‌లో ఈ ఖాతా నుండి $title మాత్రమే తొలగించాలా? ఇతర నోట్స్, అభ్యాస పురోగతి మరియు బుక్‌మార్క్‌లు ఉంచబడతాయి. ఇంతకు ముందు ప్రచురించి ఉంటే, ఆన్‌లైన్ రికార్డింగ్ మరియు డౌన్‌లోడ్ చేసిన కాపీలు తొలగించబడవు.';
  }

  @override
  String get notesRemoveSelected => 'ఎంచుకున్న నోట్ తొలగించండి';

  @override
  String get notesKeepNote => 'నోట్ ఉంచండి';

  @override
  String notesRemoved(String title) {
    return '$title తొలగించబడింది. ఇతర నోట్స్ మరియు అభ్యాస పురోగతి ఉంచబడ్డాయి.';
  }

  @override
  String get notesReviewBeforePublish =>
      'ప్రచురించే ముందు ఈ నోట్‌ను ప్రైవేట్‌గా ప్లే చేసి సమీక్షించండి.';

  @override
  String get notesSignInAsTeacher =>
      'ప్రచురించే ముందు ఉపాధ్యాయులుగా సైన్ ఇన్ చేయండి.';

  @override
  String get notesNoWorkspace =>
      'అనుమతి ఉన్న తరగతి/సబ్జెక్టు వర్క్‌స్పేస్ ఏదీ నిర్ధారించబడలేదు. మీ డ్రాఫ్ట్ ఉంచబడింది.';

  @override
  String get notesPublishTitle => 'సమీక్షించిన నోట్‌ను తరగతికి ప్రచురించాలా?';

  @override
  String notesPublishMessage(
    String title,
    String className,
    String subjectName,
  ) {
    return 'మీరు $title సమీక్షించారని, దాన్ని $className, $subjectName కు ప్రచురించాలనుకుంటున్నారని నిర్ధారించండి. అనుమతి ఉన్న తరగతి సభ్యులు దీన్ని స్ట్రీమ్ చేయవచ్చు లేదా గరిష్టంగా 30 రోజులు ఆఫ్‌లైన్ కోసం డౌన్‌లోడ్ చేయవచ్చు. కనెక్షన్ లేని కాపీలను వెంటనే వెనక్కి తీసుకోలేము. మీ స్థానిక డ్రాఫ్ట్ ఉంటుంది. నిర్ధారించని అప్‌లోడ్ ఇప్పటికే ప్రచురించబడి ఉండవచ్చు; నకిలీలు రాకుండా మళ్ళీ ప్రయత్నించే ముందు లైబ్రరీ తనిఖీ చేయండి.';
  }

  @override
  String get notesPublishConfirm => 'ఎంచుకున్న తరగతికి ప్రచురించండి';

  @override
  String get notesKeepDraftPrivate => 'డ్రాఫ్ట్‌ను ప్రైవేట్‌గా ఉంచండి';

  @override
  String get notesSignInChanged => 'సైన్ ఇన్ మారింది. డ్రాఫ్ట్ పంపబడలేదు.';

  @override
  String get notesAccountChangedBeforePublish =>
      'ప్రచురణ నిర్ధారించబడక ముందే మీ ఖాతా మారింది. మళ్ళీ ప్రయత్నించే ముందు అసలు ఉపాధ్యాయుల లైబ్రరీ తనిఖీ చేయండి.';

  @override
  String get notesPublishNotConfirmed =>
      'ప్రచురణ నిర్ధారించబడలేదు. మళ్ళీ ప్రయత్నించే ముందు తరగతి లైబ్రరీ తనిఖీ చేయండి; మీ ప్రైవేట్ డ్రాఫ్ట్ ఉంచబడింది.';

  @override
  String get notesPublishUnreadable =>
      'ప్రచురణ నిర్ధారణ చదవలేకపోయాము. మళ్ళీ ప్రయత్నించే ముందు లైబ్రరీ తనిఖీ చేయండి; మీ డ్రాఫ్ట్ ఉంచబడింది.';

  @override
  String get notesPublishIdentityMismatch =>
      'ప్రచురణ గుర్తింపు సరిపోలలేదు. మళ్ళీ ప్రయత్నించే ముందు లైబ్రరీ తనిఖీ చేయండి; మీ డ్రాఫ్ట్ ఉంచబడింది.';

  @override
  String notesPublished(String audioId) {
    return 'రికార్డింగ్ $audioId గా ప్రచురించబడింది. మీ స్థానిక డ్రాఫ్ట్ ఉంచబడింది. మరో రికార్డింగ్ కావాలనుకుంటే తప్ప మళ్ళీ ప్రచురించవద్దు.';
  }

  @override
  String get notesStopBeforeLeaving =>
      'రికార్డింగ్ ఆగినట్లు నిర్ధారించబడలేదు. బయటకు వెళ్ళే ముందు మళ్ళీ ఆపండి లేదా యాప్‌ను బ్యాక్‌గ్రౌండ్‌కు పంపండి.';

  @override
  String get notesRules =>
      'ప్రైవేట్ నోట్ నియమాలు. ప్రతి నోట్ గరిష్టంగా ఐదు నిమిషాలు ఉండవచ్చు. నోట్‌లకు ప్రతి ఖాతాకు వేరుగా 10 మెగాబైట్ల స్థలం ఉంటుంది. మీరు నిర్ధారించినప్పుడు మాత్రమే రికార్డింగ్ మొదలవుతుంది, లైవ్ సెషన్ లోపల ఎప్పుడూ మొదలవదు. యాప్ స్వరం, ఈ స్క్రీన్ నుండి బయటకు వెళ్లడం లేదా అంతరాయం రికార్డింగ్‌ను ఆపుతుంది, కాబట్టి మాట్లాడే నియంత్రణలు ఉపయోగించే ముందు రికార్డింగ్ ఆపండి. విద్యార్థి నోట్‌లు ఈ ఫోన్‌లోనే ప్రైవేట్‌గా ఉంటాయి. ఉపాధ్యాయుల డ్రాఫ్ట్‌లను ప్రచురించే ముందు సమీక్షించి నిర్ధారించాలి. మీరు లాగ్ అవుట్ చేసిన తర్వాత కూడా నోట్‌లు ఉంటాయి.';

  @override
  String notesRecordingFor(String duration) {
    return '$duration నుండి రికార్డింగ్ జరుగుతోంది.';
  }

  @override
  String notesUsage(String megabytes) {
    return '10 MB ప్రైవేట్ నోట్‌లలో $megabytes ఉపయోగించబడింది.';
  }

  @override
  String authRecoveryStepListItem(String number, String step) {
    return '$number. $step';
  }

  @override
  String get authBackToLoginKey => '0: లాగిన్‌కు తిరిగి వెళ్లండి';

  @override
  String get authRoleRowSelected => 'ఎంచుకోబడింది';

  @override
  String get authLoginScreenName => 'లాగిన్ స్క్రీన్';

  @override
  String get authLoginNavigationSections =>
      'ఫోన్ నంబర్, పాస్‌వర్డ్, ఖాతా రకం, లాగిన్, నమోదు, SIM సూచనలు మరియు రికవరీ సహాయం';

  @override
  String get authLoginKeySimLabel => 'ఐచ్ఛిక SIM ఫోన్ నంబర్ సూచనలను చదవండి';

  @override
  String get authLoginKeyRecoveryLabel =>
      'పాఠశాల నిర్వాహకుల ద్వారా పాస్‌వర్డ్ రికవరీ సహాయం';

  @override
  String get authPhoneNumberField => 'ఫోన్ నంబర్ ఫీల్డ్';

  @override
  String get authPasswordField => 'పాస్‌వర్డ్ ఫీల్డ్';

  @override
  String get authHidePassword => 'పాస్‌వర్డ్ దాచండి';

  @override
  String get authShowPassword => 'పాస్‌వర్డ్ చూపించండి';

  @override
  String authRoleFieldNavLabel(String role) {
    return 'ఖాతా రకం: $role, ఎంచుకోబడింది. మార్చడానికి 1, 2 లేదా 3 నొక్కండి, లేదా ఎడమ మరియు కుడి ఉపయోగించండి';
  }

  @override
  String authLoginAsButton(String role) {
    return '$role గా లాగిన్ చేయండి, బటన్';
  }

  @override
  String get authRegisterNewAccountButton => 'కొత్త ఖాతాను నమోదు చేయండి, బటన్';

  @override
  String get authSimSuggestionsTargetLabel =>
      'ఐచ్ఛిక SIM ఫోన్ నంబర్ సూచనలను చదవండి. మీరే నమోదు చేయడం ఎప్పుడూ పనిచేస్తుంది.';

  @override
  String get authForgotPasswordTargetLabel =>
      'పాస్‌వర్డ్ మర్చిపోయారా? పాఠశాల నిర్వాహకుల రికవరీ సహాయం';

  @override
  String get authWelcomeBack => 'మళ్లీ స్వాగతం';

  @override
  String get authRegisteredBanner => 'నమోదు అయింది. ఇప్పుడు లాగిన్ చేయండి.';

  @override
  String get authPhoneNumber => 'ఫోన్ నంబర్';

  @override
  String get authPassword => 'పాస్‌వర్డ్';

  @override
  String get authAccountType => 'ఖాతా రకం';

  @override
  String authRoleFieldValue(String role) {
    return '$role, ఎంచుకోబడింది. మార్చడానికి 1, 2 లేదా 3 నొక్కండి';
  }

  @override
  String get authRoleOptionStudent => '1 విద్యార్థి';

  @override
  String get authRoleOptionTeacher => '2 ఉపాధ్యాయులు';

  @override
  String get authRoleOptionAdmin => '3 నిర్వాహకులు';

  @override
  String get authSigningIn => 'సైన్ ఇన్ చేస్తోంది, దయచేసి వేచి ఉండండి';

  @override
  String authLoginAsKey(String role) {
    return '4: $role గా లాగిన్ చేయండి';
  }

  @override
  String get authNoAccountRegisterKey => '5: ఖాతా లేదా? నమోదు చేయండి';

  @override
  String get authReadSimSuggestionsKey => '6: ఐచ్ఛిక SIM సూచనలను చదవండి';

  @override
  String get authForgotPasswordKey => '7: పాస్‌వర్డ్ మర్చిపోయారా? రికవరీ సహాయం';

  @override
  String authErrorMovedToName(String message) {
    return '$message పేరు ఫీల్డ్‌కు వెళ్లింది.';
  }

  @override
  String get authErrorEnterName => 'మీ పేరు నమోదు చేయండి.';

  @override
  String get authErrorEnterAPassword => 'ఒక పాస్‌వర్డ్ నమోదు చేయండి.';

  @override
  String get authRegisteringAsTeacher => 'ఉపాధ్యాయులుగా నమోదు చేస్తోంది';

  @override
  String get authRegisteringAsStudent => 'విద్యార్థిగా నమోదు చేస్తోంది';

  @override
  String get authRegistrationScreenName => 'నమోదు స్క్రీన్';

  @override
  String get authRegisterNavigationSections =>
      'పేరు, ఫోన్ నంబర్, పాస్‌వర్డ్, విద్యార్థి లేదా ఉపాధ్యాయుల ఖాతా రకం, నమోదు మరియు లాగిన్';

  @override
  String get authNameField => 'పేరు ఫీల్డ్';

  @override
  String get authRegisterRoleTeacherLabel =>
      'ఖాతా రకం: ఉపాధ్యాయులు. విద్యార్థికి మార్చడానికి ఓకే లేదా 3 నొక్కండి';

  @override
  String get authRegisterRoleStudentLabel =>
      'ఖాతా రకం: విద్యార్థి. ఉపాధ్యాయులకు మార్చడానికి ఓకే లేదా 3 నొక్కండి';

  @override
  String get authRegisterAsTeacherButton => 'ఉపాధ్యాయులుగా నమోదు చేయండి, బటన్';

  @override
  String get authRegisterAsStudentButton => 'విద్యార్థిగా నమోదు చేయండి, బటన్';

  @override
  String get authGoToLoginLabel => 'ఇప్పటికే ఖాతా ఉందా? లాగిన్‌కు వెళ్లండి';

  @override
  String get authRegisterTitle => 'నమోదు';

  @override
  String get authName => 'పేరు';

  @override
  String get authRegisterAsTeacherKey =>
      '3: ఉపాధ్యాయులుగా నమోదు చేయండి. ఖాతా రకాన్ని మార్చండి';

  @override
  String get authRegisterAsStudentKey =>
      '3: విద్యార్థిగా నమోదు చేయండి. ఖాతా రకాన్ని మార్చండి';

  @override
  String get authRegisteringPleaseWait => 'నమోదు చేస్తోంది, దయచేసి వేచి ఉండండి';

  @override
  String get authRegisterKey => '1: నమోదు చేయండి';

  @override
  String get authHaveAccountLoginKey => '2: ఇప్పటికే ఖాతా ఉందా? లాగిన్ చేయండి';

  @override
  String get authChangePasswordBusy =>
      'సేవ్ చేస్తోంది. పాస్‌వర్డ్ మార్పు నిర్ధారణ కోసం వేచి ఉంది.';

  @override
  String get authChangePasswordErrorEnterTemporary =>
      'మీ తాత్కాలిక కోడ్ నమోదు చేయండి. ఆ ఫీల్డ్‌కు వెళ్లింది.';

  @override
  String get authChangePasswordErrorTooShort =>
      'కనీసం 6 అక్షరాల కొత్త పాస్‌వర్డ్ నమోదు చేయండి. కొత్త పాస్‌వర్డ్‌కు వెళ్లింది.';

  @override
  String get authChangePasswordErrorMismatch =>
      'కొత్త పాస్‌వర్డ్‌లు సరిపోలడం లేదు. కొత్త పాస్‌వర్డ్ మళ్లీ నమోదు చేసే ఫీల్డ్‌కు వెళ్లింది.';

  @override
  String get authChangePasswordErrorSameAsTemporary =>
      'తాత్కాలిక కోడ్ కంటే వేరే పాస్‌వర్డ్ ఎంచుకోండి. కొత్త పాస్‌వర్డ్‌కు వెళ్లింది.';

  @override
  String get authChangePasswordSessionInactive =>
      'ఈ రికవరీ సెషన్ ఇప్పుడు సక్రియంగా లేదు. మళ్లీ సైన్ ఇన్ చేయండి.';

  @override
  String get authChangePasswordAccountChanged =>
      'మీ ఖాతా మారింది. బదులుగా ఎలాంటి సైన్ ఇన్ సేవ్ చేయబడలేదు.';

  @override
  String authChangePasswordNotConfirmed(String message) {
    return '$message పాస్‌వర్డ్ మార్పు నిర్ధారించబడలేదు. కనెక్షన్ విఫలమైతే, మరో రీసెట్ అడిగే ముందు మీ కొత్త పాస్‌వర్డ్‌తో సైన్ ఇన్ చేసి చూడండి.';
  }

  @override
  String get authChangePasswordResponseNotVerified =>
      'పాస్‌వర్డ్ మార్పు స్పందనను ధృవీకరించలేకపోయాము. మీ కొత్త పాస్‌వర్డ్‌తో మళ్లీ సైన్ ఇన్ చేసి చూడండి.';

  @override
  String get authChangePasswordReplacementNotVerified =>
      'కొత్త సైన్ ఇన్‌ను ధృవీకరించలేకపోయాము. మీ కొత్త పాస్‌వర్డ్‌తో మళ్లీ సైన్ ఇన్ చేయండి.';

  @override
  String get authChangePasswordSignInNotSaved =>
      'మీ సైన్ ఇన్‌ను సేవ్ చేయలేకపోయాము. మీ కొత్త పాస్‌వర్డ్‌తో మళ్లీ సైన్ ఇన్ చేయండి.';

  @override
  String get authChangePasswordSignInNotSavedOnPhone =>
      'మీ సైన్ ఇన్‌ను ఈ ఫోన్‌లో సేవ్ చేయలేకపోయాము. మీ కొత్త పాస్‌వర్డ్‌తో మళ్లీ సైన్ ఇన్ చేయండి.';

  @override
  String get authTemporaryCredential => 'తాత్కాలిక కోడ్';

  @override
  String get authNewPassword => 'కొత్త పాస్‌వర్డ్';

  @override
  String get authRepeatNewPassword => 'కొత్త పాస్‌వర్డ్ మళ్లీ నమోదు చేయండి';

  @override
  String get authChangePasswordScreenName => 'తాత్కాలిక పాస్‌వర్డ్‌ను మార్చండి';

  @override
  String get authChangePasswordIntro =>
      'మీ నిర్వాహకులు ఇచ్చిన తాత్కాలిక కోడ్ నమోదు చేయండి, తర్వాత కనీసం 6 అక్షరాల కొత్త పాస్‌వర్డ్‌ను రెండుసార్లు నమోదు చేయండి. ఇంటర్నెట్ అవసరం. కొత్త పాస్‌వర్డ్ నిర్ధారించబడిన తర్వాత డ్యాష్‌బోర్డ్ తెరుచుకుంటుంది.';

  @override
  String get authSaveNewPassword => 'కొత్త పాస్‌వర్డ్ సేవ్ చేయండి';

  @override
  String get authSignOut => 'సైన్ అవుట్';

  @override
  String get authTemporaryCredentialField => 'తాత్కాలిక కోడ్. దాచిన ఇన్‌పుట్.';

  @override
  String get authNewPasswordField =>
      'కొత్త పాస్‌వర్డ్. కనీసం 6 అక్షరాలు. దాచిన ఇన్‌పుట్.';

  @override
  String get authRepeatNewPasswordField =>
      'కొత్త పాస్‌వర్డ్ మళ్లీ నమోదు చేయండి. దాచిన ఇన్‌పుట్.';

  @override
  String get authSaveNewPasswordButton => 'కొత్త పాస్‌వర్డ్ సేవ్ చేయండి, బటన్';

  @override
  String get authSignOutConfirmButton => 'సైన్ అవుట్, నిర్ధారణ అడుగుతుంది';

  @override
  String get authChangePasswordTitle => 'పాస్‌వర్డ్ మార్చండి';

  @override
  String get authChangePasswordInfo =>
      'మీ పాఠశాల నిర్వాహకులు తాత్కాలిక కోడ్ ఇచ్చారు. ఇది 24 గంటలు ఉంటుంది. 10 తప్పు ప్రయత్నాల తర్వాత, సైన్ ఇన్ 15 నిమిషాలు ఆగిపోతుంది. కనీసం 6 అక్షరాల వేరే పాస్‌వర్డ్ ఎంచుకోండి. దీనికి ఇంటర్నెట్ అవసరం.';

  @override
  String get authSignOutKey => '0: సైన్ అవుట్';

  @override
  String authSimOptionValid(String label, String digits) {
    return '$label. ఫోన్ నంబర్ $digits. ఫోన్ ఫీల్డ్ నింపడానికి ఓకే నొక్కండి.';
  }

  @override
  String authSimOptionInvalid(String label) {
    return '$label. నంబర్ అందుబాటులో లేదు. ఫోన్ నంబర్‌ను మీరే నమోదు చేయండి.';
  }

  @override
  String get authSimInvalidSuggestion =>
      'ఈ SIM సరైన ఫోన్ నంబర్ సూచనను ఇవ్వడం లేదు. మీరే నమోదు చేయడం ఇప్పటికీ పనిచేస్తుంది.';

  @override
  String get authSimChooseScreenName =>
      'ఒక ఐచ్ఛిక SIM సూచనను ఎంచుకోండి. ప్రతి SIM ను వినడానికి పైకి మరియు కిందికి ఉపయోగించండి, తర్వాత ఎంచుకోవడానికి ఓకే నొక్కండి. ఇది ఖాతా ధృవీకరణ కాదు.';

  @override
  String get authSimCancelLabel => 'ఫోన్ నంబర్ మార్చకుండా రద్దు చేయండి';

  @override
  String get authSimChooseTitle => 'SIM సూచనను ఎంచుకోండి';

  @override
  String get authSimChooseInfo =>
      'ఎంచుకుంటే ఫోన్ ఫీల్డ్ మాత్రమే నిండుతుంది. మీ పాస్‌వర్డ్ ఇంకా అవసరం. రద్దు చేస్తే మీరు నమోదు చేసినది మారదు.';

  @override
  String get authSimCancelKey => '0: రద్దు చేయండి';

  @override
  String get inviteStatusInvited => 'ఆహ్వానించబడింది';

  @override
  String get inviteStatusNotInvited => 'ఆహ్వానించలేదు. ఆహ్వానించడానికి ఓకే';

  @override
  String get inviteTitle => 'విద్యార్థులను ఆహ్వానించండి';

  @override
  String get inviteTooltipBack => '0: సెషన్‌కు తిరిగి వెళ్లండి';

  @override
  String get inviteTooltipRefresh => '1: విద్యార్థుల జాబితాను రిఫ్రెష్ చేయండి';

  @override
  String get inviteInvitingTo => 'విద్యార్థులను దీనికి ఆహ్వానిస్తోంది:';

  @override
  String inviteInvitedCount(String invited, String total) {
    return '$total లో $invited మంది ఆహ్వానించబడ్డారు';
  }

  @override
  String get inviteAllButton => '2: విద్యార్థులందరినీ ఆహ్వానించండి';

  @override
  String get inviteSearchField => 'పేరు లేదా ఫోన్ నంబర్‌తో వెతకండి';

  @override
  String get inviteSearchHelper => 'ప్రతి విద్యార్థిని చూపడానికి ఖాళీగా వదలండి';

  @override
  String get inviteLoadingStudents => 'విద్యార్థులను లోడ్ చేస్తోంది';

  @override
  String get inviteNoMatchShort =>
      'ఏ విద్యార్థులూ సరిపోలలేదు. అందరినీ చూపడానికి వెతుకుడును క్లియర్ చేయండి.';

  @override
  String get libraryUploadTitleField => 'శీర్షిక *';

  @override
  String get libraryUploadDescriptionField => 'వివరణ';

  @override
  String get libraryCancelKey0Button => 'రద్దు చేయండి (0)';

  @override
  String get libraryUploadKey3Button => 'అప్‌లోడ్ చేయండి (3)';

  @override
  String get libraryConfirmKey1Button => 'నిర్ధారించండి (1)';

  @override
  String librarySessionNumber(String id) {
    return 'సెషన్ #$id';
  }

  @override
  String get libraryKey5PauseForClass => '5: తరగతి కోసం పాజ్ చేయండి';

  @override
  String get libraryKey5PlayForClass => '5: తరగతి కోసం ప్లే చేయండి';

  @override
  String get libraryRecordingsSeekKeysHint =>
      '4: 10 సెకన్లు వెనక్కి. 6: 10 సెకన్లు ముందుకు.';

  @override
  String get libraryKey1ChooseRecording => '1: రికార్డింగ్ ఎంచుకోండి';

  @override
  String get libraryUploadingButton => 'అప్‌లోడ్ చేస్తోంది';

  @override
  String get libraryKey2Upload => '2: అప్‌లోడ్ చేయండి';

  @override
  String get libraryRecordingsFooterKeysHint =>
      '3: స్థితి. *: సహాయం. #: మాటలు ఆపండి.';

  @override
  String get notesBackStopsRecording =>
      'వెనక్కి. ముందుగా ఏదైనా రికార్డింగ్‌ను ఆపుతుంది';

  @override
  String get notesReadRules => 'నోట్ నియమాలు చదవండి';

  @override
  String get notesRefreshPrivate => 'ప్రైవేట్ నోట్‌లను రిఫ్రెష్ చేయండి';

  @override
  String get notesRecordAsksFirst =>
      'ప్రైవేట్ నోట్ రికార్డ్ చేయండి. ముందుగా పేరు మరియు నిర్ధారణ అడుగుతుంది';

  @override
  String get notesStopRecordingNow => 'ఇప్పుడే రికార్డింగ్ ఆపండి';

  @override
  String get notesReadRecordingTimeStops =>
      'రికార్డింగ్ సమయం చదవండి. గట్టిగా చదవడం రికార్డింగ్‌ను ఆపుతుంది';

  @override
  String get notesReadPrivateStatus => 'ప్రైవేట్ నోట్ స్థితి చదవండి';

  @override
  String get notesStopPrivateReview => 'ప్రైవేట్ సమీక్ష ఆపండి';

  @override
  String notesStopReviewingTitle(String title) {
    return '$title సమీక్షించడం ఆపండి';
  }

  @override
  String get notesStopReviewingNote => 'నోట్ సమీక్షించడం ఆపండి';

  @override
  String notesReviewTitlePrivately(String title, String duration) {
    return '$title ను ప్రైవేట్‌గా సమీక్షించండి. $duration.';
  }

  @override
  String notesReviewTitleIncomplete(String title) {
    return '$title ను ప్రైవేట్‌గా సమీక్షించండి. అసంపూర్ణ రికార్డింగ్; ప్లే చేయలేము.';
  }

  @override
  String notesRenameTitle(String title) {
    return '$title పేరు మార్చండి';
  }

  @override
  String notesPublishTitleAsks(String title) {
    return 'సమీక్షించిన $title ను ఒక తరగతి మరియు సబ్జెక్టుకు ప్రచురించండి, నిర్ధారణ అడుగుతుంది';
  }

  @override
  String notesRemoveTitleAsks(String title) {
    return '$title ను తీసివేయండి, నిర్ధారణ అడుగుతుంది';
  }

  @override
  String get notesScreenName => 'ప్రైవేట్ నోట్‌లు';

  @override
  String get notesIntroduction =>
      'నోట్‌లు ఎలా ఉంచబడతాయో వినడానికి నోట్ నియమాలు చదవండి ఉపయోగించండి.';

  @override
  String get notesBack => 'వెనక్కి';

  @override
  String notesStorageSummary(String megabytes) {
    return '$megabytes / 10 MB ప్రైవేట్ నోట్‌లు. పాఠం డౌన్‌లోడ్‌ల నుండి వేరు. ఆటోమేటిక్‌గా తొలగించబడవు.';
  }

  @override
  String notesLessonContext(String title, String seconds) {
    return '$title. పాఠంలో నమోదు చేసిన స్థానం: $seconds సెకన్లు.';
  }

  @override
  String notesRecordingTime(String time) {
    return 'రికార్డింగ్ సమయం $time';
  }

  @override
  String get notesRefreshNotes => 'నోట్‌లను రిఫ్రెష్ చేయండి';

  @override
  String get notesRecordPrivateNote => 'ప్రైవేట్ నోట్ రికార్డ్ చేయండి';

  @override
  String get notesStopRecording => 'రికార్డింగ్ ఆపండి';

  @override
  String get notesReadRecordingTime => 'రికార్డింగ్ సమయం చదవండి';

  @override
  String get notesReadNoteStatus => 'నోట్ స్థితి చదవండి';

  @override
  String get notesStatusNeedsAttention => 'శ్రద్ధ అవసరం';

  @override
  String get notesStatusIncomplete => 'అసంపూర్ణం';

  @override
  String get notesStatusPlaying => 'ప్లే అవుతోంది';

  @override
  String get notesStatusReviewed => 'సమీక్షించబడింది';

  @override
  String get notesStatusSaved => 'సేవ్ చేయబడింది';

  @override
  String notesNoteSeconds(String seconds) {
    return '$seconds సెకన్లు. ఈ ఫోన్‌లోని ప్రైవేట్ నోట్.';
  }

  @override
  String get notesNoteIncomplete =>
      'అంతరాయం కలిగిన లేదా అసంపూర్ణ నోట్. ప్లే చేయలేము లేదా ప్రచురించలేము.';

  @override
  String notesNoteLessonPoint(String lesson, String seconds) {
    return 'పాఠం $lesson, స్థానం $seconds సెకన్లు.';
  }

  @override
  String get notesReviewPlaying => 'సమీక్ష ప్లే అవుతోంది';

  @override
  String get notesReviewPrivately => 'ప్రైవేట్‌గా సమీక్షించండి';

  @override
  String get notesRename => 'పేరు మార్చండి';

  @override
  String get notesPublishReviewedNote => 'సమీక్షించిన నోట్‌ను ప్రచురించండి';

  @override
  String get notesEnterNameBeforeSaving => 'సేవ్ చేసే ముందు పేరు నమోదు చేయండి.';

  @override
  String notesNameDialogInstructions(String title) {
    return '$title. ఓకే ఎడిటింగ్‌లోకి వెళ్తుంది. పైకి లేదా కిందికి ఎడిటింగ్ నుండి బయటకు వస్తుంది, ఆపై సేవ్ లేదా రద్దు ఎంచుకోండి.';
  }

  @override
  String get notesNoteName => 'నోట్ పేరు';

  @override
  String get notesSaveNoteName => 'నోట్ పేరు సేవ్ చేయండి';

  @override
  String get notesCancel => 'రద్దు చేయండి';

  @override
  String get notesSaveName => 'పేరు సేవ్ చేయండి';

  @override
  String notesWorkspaceLabel(String className, String subjectName) {
    return '$className, $subjectName';
  }

  @override
  String get notesChooseWorkspaceInstructions =>
      'ప్రచురించే ముందు అనుమతి ఉన్న తరగతి మరియు సబ్జెక్టు ఎంచుకోండి. తదుపరి నిర్ధారణ వరకు ఏదీ అప్‌లోడ్ చేయబడదు.';

  @override
  String get notesCancelPublication => 'ప్రచురణ రద్దు చేయండి';

  @override
  String get notesPublishWhichWorkspace => 'ఏ వర్క్‌స్పేస్‌కు ప్రచురించాలి?';

  @override
  String settingsDecrease(String setting) {
    return '$setting తగ్గించండి';
  }

  @override
  String settingsIncrease(String setting) {
    return '$setting పెంచండి';
  }

  @override
  String get settingsResetTooltip => 'డిఫాల్ట్‌కు రీసెట్ చేయండి';

  @override
  String get settingsSectionSpeech => 'స్వరం';

  @override
  String get settingsAppSpeechTitle => 'యాప్ స్వరం';

  @override
  String get settingsAppSpeechSubtitle =>
      'యాప్ స్క్రీన్‌లను మరియు సందేశాలను చదివి వినిపిస్తుంది';

  @override
  String settingsLanguageButton(String language) {
    return 'మాట్లాడే భాష: $language';
  }

  @override
  String get settingsVolumeTitle => 'వాల్యూమ్';

  @override
  String get settingsVolumeSubtitle => 'యాప్ స్వరం ఎంత గట్టిగా ఉండాలి';

  @override
  String settingsPercentValue(String percent) {
    return '$percent శాతం';
  }

  @override
  String get settingsSpeedTitle => 'మాట్లాడే వేగం';

  @override
  String get settingsSpeedSubtitle =>
      'యాప్ స్వరం ఎంత వేగంగా ఉండాలి. క్విజ్‌లు వాటి సొంత వేగాన్ని ఉపయోగించవచ్చు';

  @override
  String settingsTimesNormal(String speed) {
    return 'సాధారణం కంటే $speed రెట్లు';
  }

  @override
  String get settingsTestButton => '5: స్వరాన్ని పరీక్షించండి';

  @override
  String settingsNarrationButton(String level) {
    return 'వ్యాఖ్యాన స్థాయి: $level';
  }

  @override
  String settingsCheckingVoice(String language) {
    return '$language స్వరాన్ని తనిఖీ చేస్తోంది...';
  }

  @override
  String settingsCheckVoiceButton(String language) {
    return '7: $language స్వరాన్ని తనిఖీ చేయండి';
  }

  @override
  String get settingsStopButton => '#: మాట్లాడటం ఆపండి';

  @override
  String get settingsSectionDisplay => 'డిస్‌ప్లే';

  @override
  String get settingsHighContrastTitle => 'హై కాంట్రాస్ట్';

  @override
  String get settingsHighContrastSubtitle =>
      'డిఫాల్ట్‌గా ఆన్: తక్కువ చూపు ఉన్నవారి కోసం నలుపుపై తెలుపు మరియు పసుపు';

  @override
  String get settingsTextSizeTitle => 'అక్షరాల పరిమాణం';

  @override
  String get settingsTextSizeSubtitle =>
      'యాప్ అక్షరాల పరిమాణం; ఫోన్ ఫాంట్ పరిమాణాన్ని కూడా పాటిస్తుంది';

  @override
  String get settingsSectionKeys => 'కీలు మరియు సహాయం';

  @override
  String get settingsShortcutsTitle => 'కీప్యాడ్ షార్ట్‌కట్‌లు చూపించు';

  @override
  String get settingsShortcutsSubtitle => 'బటన్‌లపై కీ నంబర్‌లను చూపించు';

  @override
  String get settingsGlobalKeysHint =>
      'ప్రతి స్క్రీన్‌లో: 0 వెనుకకు, స్టార్ సహాయం, హ్యాష్ మాట్లాడటం ఆపుతుంది.';

  @override
  String get settingsVoiceCommandsTitle => 'వాయిస్ కమాండ్‌లు';

  @override
  String get settingsVoiceCommandsSubtitle =>
      'సెషన్‌లలో కమాండ్ కోసం వినండి ఆన్ చేయండి. ఆటోమేటిక్‌గా వినడం ఉండదు.';

  @override
  String get settingsSoundCuesTitle => '8: సౌండ్ సూచనలు';

  @override
  String get settingsVibrationTitle => '9: వైబ్రేషన్';

  @override
  String get settingsVoiceHelpButton =>
      'వాయిస్ కమాండ్ సహాయం: మ్యూట్, అన్‌మ్యూట్, చేయి ఎత్తండి, చేయి దించండి, బయటకు వెళ్లండి లేదా మళ్లీ చెప్పండి అని చెప్పండి.';

  @override
  String get uiSave => 'సేవ్ చేయండి';

  @override
  String get uiClose => 'మూసివేయండి';

  @override
  String get learningLessonPositionLabel => 'పాఠంలో స్థానం';

  @override
  String get learningReadStatusButton => 'అభ్యాస స్థితి చదవండి';

  @override
  String get learningAddBookmarkButton => 'బుక్‌మార్క్ జోడించండి';

  @override
  String learningBookmarksButton(String count) {
    return 'బుక్‌మార్క్‌లు ($count)';
  }

  @override
  String get learningPrivateNotesButton => 'ప్రైవేట్ అధ్యయన నోట్‌లు';

  @override
  String get learningSetAButton => 'A సెట్ చేయండి';

  @override
  String learningSetAAtButton(String time) {
    return 'A సెట్ చేయండి $time';
  }

  @override
  String get learningSetBButton => 'B సెట్ చేయండి';

  @override
  String learningSetBAtButton(String time) {
    return 'B సెట్ చేయండి $time';
  }

  @override
  String get learningRepeatOffButton => 'రిపీట్ ఆఫ్';

  @override
  String get learningRepeatOnButton => 'రిపీట్ ఆన్';

  @override
  String get learningClearABButton => 'A-B క్లియర్ చేయండి';

  @override
  String learningBackTenButton(String key) {
    return '$key: 10 సెకన్లు వెనక్కి';
  }

  @override
  String learningForwardTenButton(String key) {
    return '$key: 10 సెకన్లు ముందుకు';
  }

  @override
  String learningSlowerButton(String key) {
    return '$key: నెమ్మదిగా';
  }

  @override
  String learningFasterButton(String key) {
    return '$key: వేగంగా';
  }

  @override
  String get learningRetrySavingButton => 'మళ్లీ సేవ్ చేయడానికి ప్రయత్నించండి';

  @override
  String get learningNameBookmarkTitle => 'బుక్‌మార్క్‌కు పేరు పెట్టండి';

  @override
  String get learningBookmarkNameFieldLabel => 'పేరు';

  @override
  String get learningBookmarksTitle => 'బుక్‌మార్క్‌లు';

  @override
  String get learningBookmarksLessonChanged =>
      'పాఠం మారింది. ఈ జాబితాను మూసివేసి, ప్రస్తుత పాఠం యొక్క బుక్‌మార్క్‌లను తెరవండి.';

  @override
  String get learningBookmarksEmpty =>
      'ఇంకా బుక్‌మార్క్‌లు లేవు. మీరు గుర్తుంచుకోవాలనుకునే స్థానంలో బుక్‌మార్క్ జోడించండి ఉపయోగించండి.';

  @override
  String get learningBookmarksUnavailable =>
      'సేవ్ చేసిన బుక్‌మార్క్‌లు అందుబాటులో లేవు. సేవ్ చేసిన పురోగతిని మళ్లీ పొందడానికి మళ్లీ సేవ్ చేయడానికి ప్రయత్నించండి.';

  @override
  String learningBookmarkAtButton(String label, String time) {
    return '$time వద్ద $label';
  }

  @override
  String learningRemoveBookmarkSemantics(String label) {
    return 'బుక్‌మార్క్ $label తీసివేయండి';
  }

  @override
  String uiKeyedLabel(String key, String label) {
    return '$key: $label';
  }

  @override
  String get uiKeypadFooter => '*: సహాయం. #: యాప్ స్వరం ఆపండి.';

  @override
  String uiListSearchValue(String query) {
    return 'వెతుకులాట: $query';
  }

  @override
  String get uiListLoadingShort =>
      'లోడ్ అవుతోంది. వెనక్కి వెళ్ళడానికి 0 నొక్కండి.';

  @override
  String get keypadTextEditingHint =>
      'ఎడిట్ చేస్తున్నప్పుడు, కీలు టెక్స్ట్ టైప్ చేస్తాయి. ముగించడానికి ఓకే నొక్కండి. ఓకేతో ఎడిటింగ్ ముగియకపోతే పైకి లేదా కిందకు ఉపయోగించండి.';

  @override
  String get keypadWaitingConfirmation => 'నిర్ధారణ కోసం వేచి ఉంది.';

  @override
  String get keypadContinueKey1 => '1: కొనసాగించండి';

  @override
  String get keypadHidePasswordKey2 => '2: పాస్‌వర్డ్ దాచండి';

  @override
  String get keypadShowPasswordKey2 => '2: పాస్‌వర్డ్ చూపండి';

  @override
  String get keypadBackKey0 => '0: వెనక్కి';

  @override
  String uiKeyedLabelUnavailable(String number, String label) {
    return '$number: $label (అందుబాటులో లేదు)';
  }

  @override
  String get journeyMenuReadDetailsKey8 => '8: వివరాలను మళ్లీ చదవండి';

  @override
  String get sessionTileHandRaised => 'చేయి ఎత్తారు';

  @override
  String get sessionTileSpeaking => 'మాట్లాడుతున్నారు';

  @override
  String sessionRemoveFromSession(String name) {
    return '$name ను సెషన్ నుండి తీసివేయండి';
  }

  @override
  String get uiHourRange => 'గంట (0 నుండి 23)';

  @override
  String get uiSetDateTimeTitle => 'తేదీ మరియు సమయం సెట్ చేయండి';

  @override
  String get uiSetDateTimeHint =>
      'స్థానిక సమయం ఉపయోగించండి. ప్రతి సంఖ్యను ఎడిట్ చేయడానికి ఓకే నొక్కండి.';

  @override
  String quizExtraTitle(String name) {
    return 'అదనపు సమయం: $name';
  }

  @override
  String get quizExtraInfo =>
      'భవిష్యత్ ప్రయత్నాలకు మాత్రమే. ఇప్పటికే ఉన్న గడువులు మారవు. క్విజ్ ముగింపు సమయం ఇప్పటికీ వర్తిస్తుంది; అవసరమైతే అందుబాటు సమయాన్ని వేరుగా పొడిగించండి. సున్నా అదనపు నిమిషాలను తీసివేస్తుంది.';

  @override
  String get quizExtraMinutesField => 'అదనపు నిమిషాలు';

  @override
  String get quizExtraSaveButton => 'భవిష్యత్ అదనపు సమయాన్ని సేవ్ చేయండి';

  @override
  String quizSpeedValue(String speed) {
    return 'క్విజ్ మాటల వేగం: $speed×';
  }

  @override
  String get uiCancelKey0 => '0: రద్దు చేయండి';

  @override
  String get uiSaveKey1 => '1: సేవ్ చేయండి';

  @override
  String get uiNone => 'ఏదీ లేదు';

  @override
  String uiPreviousOf(String label) {
    return 'మునుపటి $label';
  }

  @override
  String uiNextOf(String label) {
    return 'తదుపరి $label';
  }

  @override
  String get journeyOpening => 'ప్రయాణం తెరుస్తోంది';

  @override
  String journeyStepHeading(String position, String kind) {
    return '$position. $kind';
  }

  @override
  String journeyStepHeadingReplay(String position, String kind) {
    return '$position. $kind. మళ్లీ వింటున్నారు';
  }

  @override
  String journeyFirstTryShort(String correct, String total) {
    return 'మొదటి ప్రయత్నంలో $total లో $correct సరైనవి.';
  }

  @override
  String get journeyLeaveKey0 => '0: ప్రయాణం నుండి బయటకు వెళ్లండి';

  @override
  String get quizRevisionsTitle => 'ప్రశ్న సవరణలు';

  @override
  String get quizRevisionsBackTooltip => 'ప్రశ్న సవరణల నుండి వెనక్కి వెళ్లండి';

  @override
  String quizRevisionSectionHear(String section) {
    return '$section. వినడానికి రెండుసార్లు నొక్కండి';
  }

  @override
  String get adminResetAttested => 'గుర్తింపు ధృవీకరణ నిర్ధారించబడింది.';

  @override
  String get adminResetNotAttested => 'గుర్తింపు ధృవీకరణ నిర్ధారించబడలేదు.';

  @override
  String get adminResetConfirmTitle => 'ఈ పాస్‌వర్డ్‌ను రీసెట్ చేయాలా?';

  @override
  String adminResetConfirmMessage(String name, String phone) {
    return '$name, ఫోన్ $phone ను రీసెట్ చేయాలా? ఇది పాత పాస్‌వర్డ్‌ను మారుస్తుంది మరియు ఆన్‌లైన్ సెషన్‌లను ముగిస్తుంది. ఇంటర్నెట్ లేని ఫోన్‌లోని డౌన్‌లోడ్ చేసిన పాఠాలను వెంటనే రద్దు చేయలేము. ఇప్పటికే ఉన్న పాఠాలు, నోట్‌లు మరియు అభ్యాస రికార్డులు ఉంచబడతాయి. 12 అంకెల తాత్కాలిక కోడ్ 24 గంటలు పనిచేస్తుంది మరియు పాస్‌వర్డ్ మార్చడం తప్పనిసరి. 10 తప్పు ప్రయత్నాల తర్వాత, తాత్కాలిక కోడ్‌తో సైన్ ఇన్ 15 నిమిషాలు ఆగిపోతుంది.';
  }

  @override
  String get adminResetKeepPassword => 'పాస్‌వర్డ్ ఉంచండి';

  @override
  String get adminResetResetPassword => 'పాస్‌వర్డ్ రీసెట్ చేయండి';

  @override
  String get adminResetSignInChanged =>
      'నిర్వాహకుల సైన్ ఇన్ మారింది. ఏ రీసెట్ పంపబడలేదు.';

  @override
  String get adminResetSending =>
      'రీసెట్ పంపుతోంది. సర్వర్ నిర్ధారణ కోసం వేచి ఉంది.';

  @override
  String adminResetNotConfirmed(String reason) {
    return 'రీసెట్ నిర్ధారించబడలేదు. $reason ఇది ఇప్పటికే అమలులోకి వచ్చి ఉండవచ్చు. మరో రీసెట్ గురించి ఆలోచించే ముందు ఈ ఖాతాను మూసివేసి రిఫ్రెష్ చేయండి.';
  }

  @override
  String get adminResetResponseNotVerified =>
      'రీసెట్ ప్రతిస్పందనను ధృవీకరించలేకపోయాము. పాస్‌వర్డ్ ఇప్పటికే మారి ఉండవచ్చు. మరో రీసెట్ గురించి ఆలోచించే ముందు మూసివేసి రిఫ్రెష్ చేయండి.';

  @override
  String get adminResetConfirmedSpoken =>
      'పాస్‌వర్డ్ రీసెట్ నిర్ధారించబడింది. కోడ్ దాచబడింది. మీరు ఒంటరిగా ఉన్నప్పుడు మాత్రమే కోడ్ చదవండి ఉపయోగించండి. మూసివేస్తే ఈ కాపీ తొలగిపోతుంది.';

  @override
  String get adminResetPhoneNotConfirmed =>
      'ఈ ఫోన్‌లో రీసెట్‌ను నిర్ధారించలేకపోయాము. మరో రీసెట్ గురించి ఆలోచించే ముందు ఖాతాను మూసివేసి రిఫ్రెష్ చేయండి.';

  @override
  String get adminResetStorageUnavailable =>
      'ఖాతా స్టోరేజ్ అందుబాటులో లేదు. రీసెట్ గురించి ఆలోచించే ముందు రికవరీని మూసివేసి SEEDS ను మళ్లీ ప్రారంభించండి.';

  @override
  String adminResetCredentialSpoken(String digits, String expires) {
    return 'తాత్కాలిక కోడ్: $digits. గడువు $expires, UTC. ధృవీకరించిన వ్యక్తికి మాత్రమే ప్రైవేట్‌గా అందించండి. సైన్ ఇన్ సమయంలో దీన్ని తప్పనిసరిగా మార్చాలి.';
  }

  @override
  String get adminResetDiscardTitle => 'ఈ కోడ్ కాపీని తొలగించాలా?';

  @override
  String get adminResetDiscardMessage =>
      'మీరు తాత్కాలిక కోడ్‌ను ప్రైవేట్‌గా అందించారని నిర్ధారించండి, లేదా నిర్వాహకులు మళ్లీ ధృవీకరించి రీసెట్ చేయాల్సి ఉంటుందని అంగీకరించండి. SEEDS ఈ కాపీని మళ్లీ చూపదు. ఇది పూర్తయిన రీసెట్‌ను రద్దు చేయదు.';

  @override
  String get adminResetKeepReviewing => 'సమీక్షించడం కొనసాగించండి';

  @override
  String get adminResetCloseDiscard => 'మూసివేసి తొలగించండి';

  @override
  String get adminResetScreenName =>
      'నిర్వాహకుల పాస్‌వర్డ్ రికవరీ. రీసెట్ చేసే ముందు SEEDS బయట గుర్తింపును ధృవీకరించండి. స్పష్టంగా అడిగే వరకు కోడ్‌లు దాచబడి ఉంటాయి.';

  @override
  String get adminResetCloseRecovery => 'రికవరీ మూసివేయండి';

  @override
  String get adminResetReadAccount => 'ఎంచుకున్న ఖాతా వివరాలు చదవండి';

  @override
  String adminResetAccountDetails(String name, String phone) {
    return '$name. ఫోన్ $phone.';
  }

  @override
  String get adminResetIdentityChecked =>
      'SEEDS బయట గుర్తింపు ధృవీకరించబడింది. ఎంచుకోబడింది. మార్చడానికి ఓకే నొక్కండి.';

  @override
  String get adminResetIdentityNotChecked =>
      'SEEDS బయట గుర్తింపు ధృవీకరించబడింది. ఎంచుకోలేదు. మార్చడానికి ఓకే నొక్కండి.';

  @override
  String get adminResetResetAndEnd =>
      'పాస్‌వర్డ్ రీసెట్ చేసి ఆన్‌లైన్ సెషన్‌లను ముగించండి';

  @override
  String get adminResetReadCredentialLabel =>
      'తాత్కాలిక కోడ్‌ను చదివి చూపించండి. ప్రైవేట్‌గా మాత్రమే ఉపయోగించండి.';

  @override
  String get adminResetCloseRefresh => 'మూసివేసి ఖాతాను రిఫ్రెష్ చేయండి';

  @override
  String get adminResetTitle => 'పాస్‌వర్డ్ రికవరీ';

  @override
  String get adminResetVerifyInfo =>
      'SEEDS బయట వ్యక్తిని ధృవీకరించండి. ఫోన్ నంబర్ లేదా SIM సూచన గుర్తింపు ధృవీకరణ కాదు. కేవలం ఒక సందేశం లేదా చెప్పిన పేరు ఆధారంగా ఎప్పుడూ రీసెట్ చేయవద్దు.';

  @override
  String get adminResetVerifiedCheckbox =>
      'నేను ఈ వ్యక్తిని SEEDS బయట ధృవీకరించాను';

  @override
  String get adminResetWaiting => 'రీసెట్ నిర్ధారణ కోసం వేచి ఉంది.';

  @override
  String get adminResetConfirmedInfo =>
      'రీసెట్ నిర్ధారించబడింది. అడిగే వరకు కోడ్ దాచబడి ఉంటుంది. ఇది 24 గంటలు చెల్లుతుంది. మూసివేస్తే ఈ కాపీ తొలగిపోతుంది. ప్రైవేట్‌గా అందించండి; తరగతిలో ఎప్పుడూ పోస్ట్ చేయవద్దు.';

  @override
  String get adminResetRevealButton => 'కోడ్‌ను ప్రైవేట్‌గా చదివి చూపించండి';

  @override
  String adminResetCredentialShown(String digits, String expires) {
    return 'తాత్కాలిక కోడ్: $digits\nగడువు: $expires UTC';
  }

  @override
  String get adminResetCloseRefreshKey0 => '0: మూసివేసి ఖాతాను రిఫ్రెష్ చేయండి';

  @override
  String get apiTemporarySignInPaused =>
      'తాత్కాలిక కోడ్‌తో సైన్ ఇన్ 15 నిమిషాలు ఆపబడింది. తర్వాత ప్రయత్నించండి లేదా మీ పాఠశాల నిర్వాహకులను సంప్రదించండి.';

  @override
  String get apiTemporaryCredentialExpired =>
      'మీ తాత్కాలిక కోడ్ గడువు ముగిసింది. కొత్తది కోసం మీ పాఠశాల నిర్వాహకులను సంప్రదించండి.';

  @override
  String get apiPasswordMustDiffer =>
      'తాత్కాలిక కోడ్‌కు భిన్నమైన పాస్‌వర్డ్‌ను ఎంచుకోండి.';

  @override
  String get apiTemporaryCredentialRejected =>
      'తాత్కాలిక కోడ్ అంగీకరించబడలేదు. దాన్ని తనిఖీ చేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get apiRecoverySignInExpired =>
      'మీ రికవరీ సైన్ ఇన్ గడువు ముగిసింది లేదా మారింది. మళ్లీ సైన్ ఇన్ చేయండి.';

  @override
  String get apiCheckInformation =>
      'దయచేసి సమాచారాన్ని తనిఖీ చేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get apiInvalidLogin => 'ఫోన్ నంబర్ లేదా పాస్‌వర్డ్ తప్పు.';

  @override
  String get apiNoPermission => 'దీన్ని చేయడానికి మీకు అనుమతి లేదు.';

  @override
  String get apiSessionNotFound =>
      'సెషన్ కనుగొనబడలేదు. సెషన్ ID ని తనిఖీ చేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get apiItemNotFound => 'అడిగిన అంశం కనుగొనబడలేదు.';

  @override
  String get apiServiceUnavailable =>
      'సేవ తాత్కాలికంగా అందుబాటులో లేదు. దయచేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get apiNetworkFailure =>
      'ఆ అభ్యర్థనను పూర్తి చేయలేకపోయాము. మీ కనెక్షన్‌ను తనిఖీ చేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get apiUnknownFailure =>
      'ఆ అభ్యర్థనను పూర్తి చేయలేకపోయాము. దయచేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get apiAccountChangedRequestNotSent =>
      'మీ ఖాతా మారింది. ఈ అభ్యర్థన పంపబడలేదు.';

  @override
  String get apiAccountOrSessionChanged =>
      'మీ ఖాతా లేదా సెషన్ మారింది. ఈ చర్య పంపబడలేదు.';

  @override
  String get apiResponseUnreadable =>
      'సేవ ప్రతిస్పందనను చదవలేకపోయాము. చర్య అందుకోబడి ఉండవచ్చు; మళ్లీ ప్రయత్నించే ముందు దాని స్థితిని తనిఖీ చేయండి.';

  @override
  String get apiSignInBeforeAction =>
      'ఈ చర్యను పంపే ముందు మళ్లీ సైన్ ఇన్ చేయండి.';

  @override
  String get apiAccountChangedNotConfirmed =>
      'మీ ఖాతా మారింది. ఈ చర్యను నిర్ధారించలేకపోయాము.';

  @override
  String get apiActionNotConfirmed =>
      'చర్య నిర్ధారించబడలేదు. ఇది తరగతికి చేరి ఉండవచ్చు. మళ్లీ ప్రయత్నించే ముందు దాని స్థితిని తనిఖీ చేయండి.';

  @override
  String get apiAccountChangedActionNotSent =>
      'మీ ఖాతా మారింది. ఈ చర్య పంపబడలేదు.';

  @override
  String get apiRequestFailed => 'అభ్యర్థన విఫలమైంది';

  @override
  String get notificationPrivateTitle => 'SEEDS అప్‌డేట్';

  @override
  String get notificationPrivateBody =>
      'మీ అప్‌డేట్‌లు చూడటానికి SEEDS తెరవండి.';

  @override
  String get notificationRegistrationFailed =>
      'నోటిఫికేషన్‌లు నమోదు కాలేదు. తరగతి ఆహ్వానాలు చూడటానికి SEEDS రిఫ్రెష్ చేయండి.';

  @override
  String get notificationChannelName => 'సెషన్ నోటిఫికేషన్‌లు';

  @override
  String get notificationChannelDescription =>
      'సెషన్ ఆహ్వానాలు మరియు అప్‌డేట్‌ల కోసం నోటిఫికేషన్‌లు';

  @override
  String get notificationDisplayFailed =>
      'ఒక అప్‌డేట్ వచ్చింది, కానీ ఫోన్ నోటిఫికేషన్ చూపించలేకపోయాము. అప్‌డేట్‌లు చూడటానికి SEEDS తెరవండి.';

  @override
  String get activityCleanupFailed =>
      'గడువు ముగిసిన కార్యకలాపాన్ని తొలగించలేకపోయాము. పరికరం స్టోరేజ్‌ను తనిఖీ చేయండి.';

  @override
  String get activitySyncUnavailable =>
      'కార్యకలాపం సింక్ అందుబాటులో లేదు. అభ్యాసం ఇప్పటికీ అందుబాటులో ఉంది.';

  @override
  String get activitySignInToSync =>
      'కార్యకలాపాన్ని సింక్ చేయడానికి సైన్ ఇన్ చేయండి.';

  @override
  String get activityQueueFull =>
      'కార్యకలాపాల వరుస నిండిపోయింది. కొన్ని పాత చర్యలను నివేదించలేము.';

  @override
  String get activityWaitingToSync => 'కొంత కార్యకలాపం సింక్ కోసం వేచి ఉంది.';

  @override
  String get activityRejected =>
      'కొంత కార్యకలాపం గడువు ముగిసింది లేదా ఇకపై అనుమతి లేదు, కాబట్టి సింక్ చేయబడలేదు.';

  @override
  String get authLogoutTitle => 'SEEDS నుండి లాగ్ అవుట్ చేయాలా?';

  @override
  String get authLogoutMessage =>
      'మీరు మళ్లీ మీ ఫోన్ నంబర్ మరియు పాస్‌వర్డ్ నమోదు చేయాల్సి ఉంటుంది.';

  @override
  String get authLogoutCancel => 'రద్దు చేయండి';

  @override
  String get authLogoutConfirm => 'లాగ్ అవుట్';

  @override
  String get authLoggedOut => 'లాగ్ అవుట్ అయ్యారు.';

  @override
  String get startupLoadingTools =>
      'అందరికీ అందుబాటులో ఉండే అభ్యాస సాధనాలు లోడ్ అవుతున్నాయి…';

  @override
  String get startupTagline => 'అందరినీ, అన్ని చోట్లా కలుపుతోంది';

  @override
  String get startupLoginKey1 => '1. లాగిన్';

  @override
  String get startupLogin => 'లాగిన్';

  @override
  String get startupRegisterKey2 => '2. నమోదు';

  @override
  String get startupRegister => 'నమోదు';

  @override
  String get startupSettings => 'సెట్టింగ్‌లు';

  @override
  String get startupRepeatInstructions => 'సూచనలు మళ్ళీ వినండి';

  @override
  String get startupFeatureAudioTitle => 'రియల్-టైమ్ ఆడియో';

  @override
  String get startupFeatureAudioText => 'చాలా స్పష్టమైన స్వర సంభాషణ';

  @override
  String get startupFeatureAccessibleTitle => 'పూర్తిగా అందుబాటులో';

  @override
  String get startupFeatureAccessibleText =>
      'స్వరం, పెద్ద బటన్‌లు మరియు కీప్యాడ్ నియంత్రణ';

  @override
  String get startupFeatureCollaborationTitle => 'సహకారం';

  @override
  String get startupFeatureCollaborationText => 'చేయి ఎత్తి పాల్గొనండి';

  @override
  String get settingsResetTitle => 'సెట్టింగ్‌లను రీసెట్ చేయండి';

  @override
  String get settingsResetCancelButton => '1: రద్దు చేయండి';

  @override
  String get settingsResetConfirmButton => '2: రీసెట్ చేయండి';

  @override
  String teacherHomeFallbackName(String id) {
    return 'ఉపాధ్యాయులు $id';
  }

  @override
  String dashboardSignedInAs(String name) {
    return '$nameగా సైన్ ఇన్ అయ్యారు';
  }

  @override
  String get dashboardRefreshSessionsKey1 => '1: సెషన్‌లను రిఫ్రెష్ చేయండి';

  @override
  String get dashboardLogOutKey0 => '0: లాగ్ అవుట్';

  @override
  String get dashboardRefreshingSessions => 'సెషన్‌లను రిఫ్రెష్ చేస్తోంది';

  @override
  String teacherHomeWelcome(String name) {
    return 'స్వాగతం, $name!';
  }

  @override
  String get teacherHomeTagline =>
      'మీ సెషన్‌లను నిర్వహించండి, విద్యార్థులతో కనెక్ట్ అవ్వండి';

  @override
  String get teacherHomeChooseWorkspaceKey7 =>
      '7: తరగతి మరియు సబ్జెక్టు వర్క్‌స్పేస్ ఎంచుకోండి';

  @override
  String teacherHomeChangeWorkspaceKey7(String className, String subjectName) {
    return '7: $className, $subjectName. వర్క్‌స్పేస్ మార్చండి';
  }

  @override
  String get teacherHomePlaylistsKey5 => '5: తరగతి ప్లేలిస్ట్‌లు';

  @override
  String get teacherHomeJourneysKey8 => '8: అభ్యాస ప్రయాణాలు';

  @override
  String get teacherHomeQuizzesKey6 => '6: క్విజ్‌లు & ప్రశ్నల బ్యాంక్';

  @override
  String get teacherHomeCreateSessionKey2 => '2: కొత్త సెషన్ సృష్టించండి';

  @override
  String get dashboardAudioLibraryKey3 => '3: రికార్డ్ చేసిన ఆడియో లైబ్రరీ';

  @override
  String get teacherHomeSearchKey4 => '4: పేరు లేదా నంబర్‌తో వెతకండి';

  @override
  String get teacherHomeSearchHint =>
      'సెషన్ పేరు టైప్ చేయండి, లేదా నంబర్ కీలతో సెషన్ నంబర్ టైప్ చేయండి. అన్నీ చూడటానికి ఖాళీగా ఉంచండి.';

  @override
  String get teacherHomeYourSessions => 'మీ సెషన్‌లు';

  @override
  String teacherHomeYourSessionsCount(String count) {
    return 'మీ సెషన్‌లు, $count';
  }

  @override
  String get teacherHomeYourSessionsHeading => 'మీ సెషన్‌లు';

  @override
  String get teacherHomeNoSessions =>
      'ఇంకా సెషన్‌లు లేవు. ఒకటి సృష్టించడానికి 2 నొక్కండి.';

  @override
  String get teacherHomeNoMatches =>
      'సరిపోయే సెషన్‌లు లేవు. అన్ని సెషన్‌లను చూడటానికి వెతుకులాటను క్లియర్ చేయండి.';

  @override
  String teacherHomeEndTitleForEveryone(String title) {
    return 'అందరికీ $titleను ముగించండి';
  }

  @override
  String teacherHomeDeleteTitlePermanently(String title) {
    return '$titleను శాశ్వతంగా తొలగించండి';
  }

  @override
  String teacherHomeLiveJoined(String count) {
    return 'ఇప్పుడు లైవ్‌లో ఉంది, $count మంది చేరారు';
  }

  @override
  String teacherHomeSessionNumber(String number) {
    return 'సెషన్ నంబర్ $number';
  }

  @override
  String teacherHomePlaceSessionNumber(String place, String number) {
    return '$place. సెషన్ నంబర్ $number';
  }

  @override
  String get teacherHomeDelete => 'తొలగించండి';

  @override
  String get teacherHomeSessionTitleField => 'సెషన్ శీర్షిక';

  @override
  String get teacherHomeSessionTitleHint => 'ఉదా., ఇంగ్లీష్ తరగతి - యూనిట్ 5';

  @override
  String get teacherHomeCreateKey1 => 'సృష్టించండి (1)';

  @override
  String studentHomeFallbackName(String id) {
    return 'విద్యార్థి $id';
  }

  @override
  String get studentHomeLoading => 'విద్యార్థి డాష్‌బోర్డ్ లోడ్ అవుతోంది';

  @override
  String studentHomeWelcome(String name) {
    return 'స్వాగతం, $name';
  }

  @override
  String studentHomeClass(String name) {
    return 'తరగతి: $name';
  }

  @override
  String get studentHomeAssignmentPending => 'కేటాయింపు పెండింగ్‌లో ఉంది';

  @override
  String get studentHomeLiveSessionsNone => 'లైవ్ సెషన్‌లు: ఏవీ లేవు';

  @override
  String studentHomeLiveSessionsCount(String count) {
    return 'లైవ్ సెషన్‌లు: $count';
  }

  @override
  String get studentHomeSessionNumberKey2 => '2: సెషన్ నంబర్';

  @override
  String get studentHomeSessionName => 'సెషన్ పేరు';

  @override
  String get studentHomeSubjectFilter => 'సబ్జెక్టు ఫిల్టర్';

  @override
  String get studentHomePlaylistsKey4 => '4: నా ప్లేలిస్ట్‌లు · ప్రైవేట్';

  @override
  String get studentHomeQuizzesKey5 => '5: క్విజ్‌లు';

  @override
  String get studentHomeJourneysKey6 => '6: అభ్యాస ప్రయాణాలు';

  @override
  String studentHomeTeacher(String name) {
    return 'ఉపాధ్యాయులు: $name';
  }

  @override
  String studentHomeSessionOkToJoin(String number) {
    return 'సెషన్ $number. చేరడానికి ఓకే';
  }

  @override
  String studentHomeJoinSessionLabel(String session) {
    return '$session. సెషన్‌లో చేరండి';
  }

  @override
  String adminActiveAssignmentCount(String count) {
    return '$count క్రియాశీల కేటాయింపులు';
  }

  @override
  String adminHeadingCount(String heading, String count) {
    return '$heading ($count)';
  }

  @override
  String get adminTextDialogHelper =>
      'టైప్ చేయడానికి ఓకే నొక్కండి, ఆపై సేవ్ చేయడానికి 1 లేదా రద్దు చేయడానికి 0 నొక్కండి';

  @override
  String get adminSaveKey1 => 'సేవ్ చేయండి (1)';

  @override
  String adminManageUser(String name) {
    return '$name ను నిర్వహించండి';
  }

  @override
  String get adminManageAssignmentsKey1 => '1: కేటాయింపులను నిర్వహించండి';

  @override
  String get adminPasswordRecoveryKey2 => '2: పాస్‌వర్డ్ రికవరీ';

  @override
  String adminRemoveStudentFromClass(String name, String className) {
    return '$name ను $className నుండి తీసివేయండి (2)';
  }

  @override
  String get adminRemoveClassKey2 => 'తరగతిని తీసివేయండి (2)';

  @override
  String get adminAssignKey1 => 'కేటాయించండి (1)';

  @override
  String adminAssignTeacher(String name) {
    return '$name ను కేటాయించండి';
  }

  @override
  String get adminCurrentAssignments => 'ప్రస్తుత కేటాయింపులు';

  @override
  String adminRemoveTeacherAssignment(
    String name,
    String className,
    String subjectName,
  ) {
    return '$name ను $className, $subjectName నుండి తీసివేయండి';
  }

  @override
  String get adminAddAssignment => 'కేటాయింపు జోడించండి';

  @override
  String get adminAppBarTitle => 'SEEDS నిర్వహణ';

  @override
  String get adminRefreshKey1 => '1: నిర్వహణ డేటాను రిఫ్రెష్ చేయండి';

  @override
  String get adminLoading => 'నిర్వహణ డేటాను లోడ్ చేస్తోంది';

  @override
  String adminChangeSectionKey7(String section) {
    return '7: విభాగం మార్చండి. ఇప్పుడు: $section';
  }

  @override
  String get adminSearchKey2 => '2: పేరు లేదా ఫోన్ నంబర్‌తో వెతకండి';

  @override
  String get adminSearchHelper =>
      'సరిపోలినవి చూపడానికి పూర్తయ్యాక ఓకే నొక్కండి';

  @override
  String adminRoleFilterChipsLabel(String label) {
    return 'ఖాతా రకం ఫిల్టర్: $label, ఎంచుకోబడింది. మార్చడానికి ఎడమ మరియు కుడి బాణాలను ఉపయోగించండి.';
  }

  @override
  String get adminAccountTypeKey3 => '3: ఖాతా రకం';

  @override
  String get adminChipAllAccounts => 'అన్ని ఖాతాలు';

  @override
  String get adminChipStudents => 'విద్యార్థులు';

  @override
  String get adminChipTeachers => 'ఉపాధ్యాయులు';

  @override
  String adminAssignmentFilterChipsLabel(String label) {
    return 'కేటాయింపు ఫిల్టర్: $label, ఎంచుకోబడింది. మార్చడానికి ఎడమ మరియు కుడి బాణాలను ఉపయోగించండి.';
  }

  @override
  String get adminAssignmentKey4 => '4: కేటాయింపు';

  @override
  String get adminChipAll => 'అన్నీ';

  @override
  String get adminCreateSubjectKey5 => '5: సబ్జెక్టు సృష్టించండి';

  @override
  String get adminCreateClassKey6 => '6: తరగతి సృష్టించండి';

  @override
  String get adminStatusActive => 'క్రియాశీలం';

  @override
  String get adminClassTileHint =>
      'సబ్జెక్టుల కోసం లేదా ఆర్కైవ్ చేయడానికి ఓకే నొక్కండి';

  @override
  String get adminPressOkRestore => 'పునరుద్ధరించడానికి ఓకే నొక్కండి';

  @override
  String get adminPressOkArchive => 'ఆర్కైవ్ చేయడానికి ఓకే నొక్కండి';

  @override
  String sessionTitleTeacher(String title) {
    return '$title (ఉపాధ్యాయులు)';
  }

  @override
  String get libraryStatusStopped => 'ఆపబడింది';

  @override
  String libraryUploadFileName(String name) {
    return 'ఫైల్: $name';
  }

  @override
  String libraryAudioSessionTitle(String number) {
    return 'ఆడియో - సెషన్ $number';
  }

  @override
  String libraryRecordingsCount(String count) {
    return '$count రికార్డింగ్‌లు';
  }

  @override
  String libraryUploadedAt(String date) {
    return 'అప్‌లోడ్ చేసినది: $date';
  }

  @override
  String libraryStopPreviewOf(String title) {
    return '$title ప్రివ్యూ ఆపండి';
  }

  @override
  String libraryPreviewPrivately(String title) {
    return '$title ను ప్రైవేట్‌గా ప్రివ్యూ చేయండి';
  }

  @override
  String libraryPlayForEveryone(String title) {
    return 'సెషన్‌లోని అందరికీ $title ప్లే చేయండి';
  }

  @override
  String get librarySelectClassHint =>
      'రికార్డ్ చేసిన పాఠాలను ప్లే చేయడానికి తరగతిని ఎంచుకోండి. ఆన్‌లైన్ పాఠాలకు ఇంటర్నెట్ అవసరం. సేవ్ చేసిన ఆడియో కోసం డౌన్‌లోడ్ చేసిన పాఠాలు ఉపయోగించండి.';

  @override
  String libraryFoundCount(String count) {
    return '$count దొరికాయి';
  }

  @override
  String get librarySearchSessionHint =>
      'తరగతిని త్వరగా తెరవడానికి పైన ఉన్న \"సెషన్ పేరుతో వెతకండి\" ఉపయోగించండి.';

  @override
  String librarySessionHash(String number) {
    return 'సెషన్ #$number';
  }

  @override
  String libraryStatusFinished(String title) {
    return '$title పూర్తయింది';
  }

  @override
  String libraryStatusPaused(String title) {
    return '$title పాజ్ చేయబడింది';
  }

  @override
  String libraryStatusPlaying(String title) {
    return '$title ప్లే అవుతోంది';
  }

  @override
  String get libraryTitleField => 'శీర్షిక';

  @override
  String get libraryDescriptionOptional => 'వివరణ (ఐచ్ఛికం)';

  @override
  String libraryAudioLibrarySession(String number) {
    return 'ఆడియో లైబ్రరీ, సెషన్ $number';
  }

  @override
  String get libraryUploadingAudio => 'ఆడియో అప్‌లోడ్ చేస్తోంది';

  @override
  String get libraryAddAudioKey3Tooltip => 'ఆడియో జోడించండి, కీ 3';

  @override
  String get libraryAddAudioKey3 => '3: ఆడియో జోడించండి';

  @override
  String get libraryNoRecordingsForClass =>
      'ఈ తరగతికి ఇంకా రికార్డింగ్‌లు లేవు.';

  @override
  String get libraryNoRecordingsAskTeacher =>
      'ఇంకా రికార్డింగ్‌లు అందుబాటులో లేవు. కొన్ని అప్‌లోడ్ చేయమని మీ ఉపాధ్యాయులను అడగండి.';

  @override
  String libraryPositionSpeed(String position, String total, String speed) {
    return '$total లో $position. వేగం ${speed}x';
  }

  @override
  String libraryNowPlaying(String title) {
    return 'ఇప్పుడు ప్లే అవుతోంది: $title';
  }

  @override
  String libraryRecordingsMatch(String count, String total) {
    return '$total లో $count రికార్డింగ్‌లు సరిపోలాయి';
  }

  @override
  String get libraryNoUnlinkedAudio => 'లింక్ చేయని ఆడియో ఏదీ అందుబాటులో లేదు.';

  @override
  String get libraryNoSearchMatches =>
      'మీ శోధనకు సరిపోయే రికార్డింగ్‌లు ఏవీ లేవు.';

  @override
  String get libraryFindingLesson => 'మీ పాఠం కోసం వెతుకుతోంది';

  @override
  String get libraryTitleRequiredField => 'శీర్షిక *';

  @override
  String get libraryUploadNewAudio => 'కొత్త ఆడియో అప్‌లోడ్ చేయండి';

  @override
  String get libraryStopPreview => 'ప్రివ్యూ ఆపండి';

  @override
  String get libraryPreviewOnlyMe => 'ప్రివ్యూ (నాకు మాత్రమే)';

  @override
  String get libraryPreview => 'ప్రివ్యూ';

  @override
  String get libraryStop => 'ఆపండి';

  @override
  String get libraryPlayInSession => 'సెషన్‌లో ప్లే చేయండి';

  @override
  String get librarySessionShort => 'సెషన్';

  @override
  String get libraryNotesTooltip =>
      'ప్రైవేట్ నోట్‌లు మరియు రికార్డింగ్ డ్రాఫ్ట్‌లు';

  @override
  String get libraryBrowseClassesKey5 => '5: యాక్టివ్ తరగతులను చూడండి';

  @override
  String get librarySearchClassByName => 'పేరుతో తరగతిని వెతకండి';

  @override
  String get librarySearchClassHint => 'సెషన్/తరగతి పేరు నమోదు చేయండి';

  @override
  String get libraryMyAudioLibrary => 'నా ఆడియో లైబ్రరీ';

  @override
  String get libraryAllAudioFiles => 'అన్ని ఆడియో ఫైల్‌లు';

  @override
  String get libraryManageAudioFiles =>
      'మీ ఆడియో ఫైల్‌లను నిర్వహించండి మరియు అప్‌లోడ్ చేయండి';

  @override
  String get libraryBrowseAudioFiles =>
      'అప్‌లోడ్ చేసిన అన్ని ఆడియో ఫైల్‌లను చూడండి';

  @override
  String get libraryActiveClasses => 'యాక్టివ్ తరగతులు';

  @override
  String get libraryNoActiveClasses => 'యాక్టివ్ తరగతులు ఏవీ కనబడలేదు.';

  @override
  String get libraryAddAudioToSessions => 'సెషన్‌లకు ఆడియో జోడించండి';

  @override
  String get libraryConfirmKey1 => '1: నిర్ధారించండి';

  @override
  String get libraryDownloadLessons => 'పాఠాలను డౌన్‌లోడ్ చేయండి';

  @override
  String get libraryRepeatHelp => 'సహాయం మళ్ళీ వినండి';

  @override
  String get libraryBack10s => '10 సెకన్లు వెనక్కి';

  @override
  String get libraryPause => 'పాజ్';

  @override
  String get libraryPlay => 'ప్లే';

  @override
  String get libraryForward10s => '10 సెకన్లు ముందుకు';

  @override
  String get libraryCloseAddAudio => 'ఆడియో జోడించే ఎంపికలను మూసివేయండి';

  @override
  String get libraryUploadNewFileKey1 => '1: కొత్త ఫైల్ అప్‌లోడ్ చేయండి';

  @override
  String get librarySelectExistingKey2 => '2: ఉన్న లైబ్రరీ నుండి ఎంచుకోండి';

  @override
  String get librarySelectAudio => 'ఆడియో ఎంచుకోండి';

  @override
  String get libraryRefreshAvailable =>
      'అందుబాటులో ఉన్న ఆడియోను రిఫ్రెష్ చేయండి';

  @override
  String get librarySearchByTitle => 'శీర్షికతో వెతకండి';

  @override
  String get libraryNothingPlaying =>
      'ఏదీ ప్లే కావడం లేదు. ఒక పాఠాన్ని ఎంచుకోండి లేదా 5 నొక్కండి.';

  @override
  String spokenDayMonthYear(String day, String month, String year) {
    return '$day $month $year';
  }

  @override
  String get downloadPartialReserve =>
      'సగం డౌన్‌లోడ్ అయిన ఫైల్‌లు వాటి పూర్తి సైజు స్థలాన్ని తీసుకుంటాయి.';

  @override
  String downloadProgressStarting(String title) {
    return '$title: డౌన్‌లోడ్ ప్రారంభమవుతోంది';
  }

  @override
  String downloadPercentDone(String title, String percent) {
    return '$title: $percent శాతం డౌన్‌లోడ్ అయింది';
  }

  @override
  String downloadRecordUnreadable(String id) {
    return 'డౌన్‌లోడ్ రికార్డ్ $id చదవలేకపోయాము. ఫైల్‌లు అలాగే ఉంచబడ్డాయి. సరిచేయడానికి ఈ డౌన్‌లోడ్‌ను మాత్రమే తీసివేయండి; పురోగతి మరియు బుక్‌మార్క్‌లు అలాగే ఉంటాయి.';
  }

  @override
  String downloadRemoveUnreadable(String id) {
    return 'చదవలేని డౌన్‌లోడ్ $id తీసివేయండి';
  }

  @override
  String get downloadStatusDownloaded => 'డౌన్‌లోడ్ అయింది';

  @override
  String get downloadStatusPartial => 'పాక్షిక డౌన్‌లోడ్';

  @override
  String downloadSizeRenewal(String megabytes) {
    return '$megabytes MB. యాక్సెస్‌ను పునరుద్ధరించాలి.';
  }

  @override
  String downloadSizeExpires(String megabytes, String date) {
    return '$megabytes MB. యాక్సెస్ $date న ముగుస్తుంది.';
  }

  @override
  String get downloadTitle => 'డౌన్‌లోడ్‌లు';

  @override
  String get downloadAccessInfo =>
      '30 రోజుల ఆఫ్‌లైన్ యాక్సెస్. ఇతర ఖాతాలకు వేరే పరిమితులు ఉంటాయి. ఏదీ ఆటోమేటిక్‌గా తొలగించబడదు.';

  @override
  String get downloadRefreshKey1 => '1: డౌన్‌లోడ్‌లను రిఫ్రెష్ చేయండి';

  @override
  String get downloadFindOnlineKey2 => '2: ఆన్‌లైన్‌లో రికార్డింగ్‌లను వెతకండి';

  @override
  String get downloadReadStatusKey3 => '3: స్థితి వినండి';

  @override
  String get downloadCancelKey4 => '4: డౌన్‌లోడ్ రద్దు చేయండి';

  @override
  String get downloadNoneYetFindOnline =>
      'ఇంకా డౌన్‌లోడ్‌లు లేవు. ఆన్‌లైన్‌లో రికార్డింగ్‌లను వెతకండి లేదా తరగతి లేదా ప్లేలిస్ట్ నుండి డౌన్‌లోడ్‌లను తెరవండి.';

  @override
  String get downloadPlayLesson => 'డౌన్‌లోడ్ చేసిన పాఠాన్ని ప్లే చేయండి';

  @override
  String get downloadRenewOnline => 'ఆన్‌లైన్‌లో యాక్సెస్ పునరుద్ధరించండి';

  @override
  String get downloadRemove => 'డౌన్‌లోడ్ తీసివేయండి';

  @override
  String get downloadListedKey5 =>
      '5: జాబితాలోని రికార్డింగ్‌లను డౌన్‌లోడ్ చేయండి';

  @override
  String get downloadAvailableInfo =>
      'అందుబాటులో ఉన్న రికార్డింగ్‌లు. డౌన్‌లోడ్‌లు ఇంటర్నెట్ డేటాను వాడతాయి.';

  @override
  String playlistClassSubjectTitle(String className, String subjectName) {
    return '$className · $subjectName ప్లేలిస్ట్‌లు';
  }

  @override
  String get playlistStatusPrivate => 'ప్రైవేట్';

  @override
  String get playlistClassPlaylist => 'తరగతి ప్లేలిస్ట్';

  @override
  String playlistItemCount(String count) {
    return '$count అంశాలు';
  }

  @override
  String playlistClassItemCount(
    String className,
    String subjectName,
    String count,
  ) {
    return '$className, $subjectName, $count అంశాలు';
  }

  @override
  String get playlistFinished => 'పూర్తయింది. ప్లేలిస్ట్ ముగిసింది';

  @override
  String get playlistAddKey2 => '2 జోడించండి';

  @override
  String get playlistAddAudioKey2Label => 'ఆడియో జోడించండి, కీ 2';

  @override
  String get playlistPauseKey5 => '5 పాజ్';

  @override
  String get playlistPlayKey5 => '5 ప్లే';

  @override
  String playlistPauseTitleKey5(String title) {
    return '$title పాజ్ చేయండి, కీ 5';
  }

  @override
  String playlistPlayTitleKey5(String title) {
    return '$title ప్లే చేయండి, కీ 5';
  }

  @override
  String get playlistPreviousKey3 => '3 మునుపటిది';

  @override
  String get playlistPreviousItemKey3 => 'మునుపటి అంశం, కీ 3';

  @override
  String get playlistNextKey8 => '8 తర్వాతిది';

  @override
  String get playlistNextItemKey8 => 'తర్వాతి అంశం, కీ 8';

  @override
  String get playlistRestore => 'పునరుద్ధరించండి';

  @override
  String get playlistArchive => 'ఆర్కైవ్ చేయండి';

  @override
  String get playlistDeletePlaylist => 'ప్లేలిస్ట్ తొలగించండి';

  @override
  String playlistRestoreNamedButton(String title) {
    return '$title పునరుద్ధరించండి';
  }

  @override
  String playlistArchiveNamedButton(String title) {
    return '$title ఆర్కైవ్ చేయండి';
  }

  @override
  String playlistDeleteNamedButton(String title) {
    return '$title తొలగించండి';
  }

  @override
  String playlistMoveUp(String title) {
    return '$title ను పైకి జరపండి';
  }

  @override
  String playlistMoveDown(String title) {
    return '$title ను కిందికి జరపండి';
  }

  @override
  String get playlistCreateKey2 => '2: ప్లేలిస్ట్ సృష్టించండి';

  @override
  String get playlistNoneInClass =>
      'ఈ తరగతి మరియు సబ్జెక్టులో ప్లేలిస్ట్‌లు లేవు. ఒకటి సృష్టించడానికి 2 నొక్కండి.';

  @override
  String get playlistMyPlaylists => 'నా ప్లేలిస్ట్‌లు';

  @override
  String get playlistPrivateNoticeTitle => 'మీ ప్లేలిస్ట్‌లు ప్రైవేట్';

  @override
  String get playlistPrivateNoticeText =>
      'ఉపాధ్యాయులు, నిర్వాహకులు మరియు ఇతర విద్యార్థులు వాటిని చూడలేరు.';

  @override
  String get playlistCreatePrivateKey2 => '2: ప్రైవేట్ ప్లేలిస్ట్ సృష్టించండి';

  @override
  String get playlistMyPrivateHeading => 'నా ప్రైవేట్ ప్లేలిస్ట్‌లు';

  @override
  String get playlistNoPrivate => 'ఇంకా ప్రైవేట్ ప్లేలిస్ట్‌లు లేవు.';

  @override
  String get playlistClassHeading => 'తరగతి ప్లేలిస్ట్‌లు';

  @override
  String get playlistNoClassPublished =>
      'ఇంకా తరగతి ప్లేలిస్ట్‌లు ఏవీ ప్రచురించబడలేదు.';

  @override
  String get playlistAddAudioTitle => 'ఆడియో జోడించండి';

  @override
  String get playlistUnavailableRetry =>
      'ప్లేలిస్ట్ అందుబాటులో లేదు. మళ్ళీ ప్రయత్నించడానికి 1 నొక్కండి.';

  @override
  String get playlistDownloadRecordings =>
      'ప్లేలిస్ట్ రికార్డింగ్‌లను డౌన్‌లోడ్ చేయండి';

  @override
  String get playlistMoveHint =>
      'ఒక అంశాన్ని ప్లే చేయండి లేదా ఎంచుకోండి, తర్వాత దాన్ని పైకి లేదా కిందికి జరపండి.';

  @override
  String get playlistNoAudio => 'ఈ ప్లేలిస్ట్‌లో ఇంకా ఆడియో లేదు.';

  @override
  String quizClassSubjectHeading(String className, String subjectName) {
    return '$className · $subjectName';
  }

  @override
  String get quizBankEditNote =>
      'బ్యాంక్‌లోని ప్రశ్నను మార్చినా, ఇప్పటికే ఉన్న క్విజ్ కాపీ ఎప్పుడూ మారదు.';

  @override
  String get quizNoBankQuestions => 'బ్యాంక్‌లో ఇంకా ప్రశ్నలు లేవు';

  @override
  String quizOptionsCount(String count) {
    return '$count ఎంపికలు';
  }

  @override
  String get quizNoQuizzesYet => 'ఇంకా క్విజ్‌లు లేవు';

  @override
  String get quizStepReviewPublish => 'దశ 3: సమీక్షించి ప్రచురించండి';

  @override
  String get quizStepAddQuestions => 'దశ 2: ప్రశ్నలు జోడించండి';

  @override
  String quizResultsTitle(String title) {
    return '$title ఫలితాలు';
  }

  @override
  String get quizAllAttempted => 'విద్యార్థులందరూ ప్రయత్నించారు';

  @override
  String get quizRemindAllKey2 => '2: ప్రయత్నించని అందరికీ గుర్తు చేయండి';

  @override
  String get uiNoneCapital => 'ఏదీ లేదు';

  @override
  String get quizPracticeParticipationHeading =>
      'అభ్యాసంలో పాల్గొనడం, విద్యా మార్కులు కాదు';

  @override
  String get quizIndividualScores => 'ఒక్కో విద్యార్థి స్కోర్‌లు';

  @override
  String get quizNotAttempted => 'ప్రయత్నించలేదు';

  @override
  String get quizPracticeNotGraded => 'అభ్యాసం, మార్కులు లేవు';

  @override
  String quizHighestScore(String score) {
    return 'అత్యధిక స్కోర్: $score';
  }

  @override
  String get quizAttemptInProgress => 'ప్రయత్నం జరుగుతోంది';

  @override
  String get quizQuizzesTitle => 'క్విజ్‌లు';

  @override
  String get quizRefreshQuizzesTooltip => 'క్విజ్‌లను రిఫ్రెష్ చేయండి';

  @override
  String get quizLoadingQuizzes => 'క్విజ్‌లు లోడ్ అవుతున్నాయి';

  @override
  String get quizNewBankQuestionKey2 => '2: కొత్త బ్యాంక్ ప్రశ్న';

  @override
  String get quizNewDraftKey3 => '3: కొత్త క్విజ్ డ్రాఫ్ట్';

  @override
  String get quizCreatePracticeKey4 =>
      '4: సమయ పరిమితి లేని అభ్యాసం సృష్టించండి';

  @override
  String get quizPrivateBankHeading => 'ప్రైవేట్ ప్రశ్నల బ్యాంక్';

  @override
  String get quizOptionsButton => 'ఎంపికలు';

  @override
  String get quizManagementHeading => 'క్విజ్ నిర్వహణ';

  @override
  String get quizContinueCreation => 'సృష్టించడం కొనసాగించండి';

  @override
  String get quizCloseButton => 'మూసివేయండి';

  @override
  String get quizDuplicateButton => 'నకలు చేయండి';

  @override
  String get quizResultsButton => 'ఫలితాలు';

  @override
  String get quizRefreshResultsTooltip => 'ఫలితాలను రిఫ్రెష్ చేయండి';

  @override
  String get quizClassStatistics => 'తరగతి గణాంకాలు';

  @override
  String get quizStudentsYetToAttempt => 'ఇంకా ప్రయత్నించని విద్యార్థులు';

  @override
  String get quizNoQuizzesAvailableLabel => 'క్విజ్‌లు ఏవీ అందుబాటులో లేవు';

  @override
  String get quizAttemptLimitReachedLabel => 'ప్రయత్నాల పరిమితి ముగిసింది';

  @override
  String get quizAnswerSavedLockedTitle =>
      'జవాబు సేవ్ చేయబడింది మరియు లాక్ చేయబడింది';

  @override
  String get quizAllSavedViewResult =>
      'అన్ని జవాబులు సేవ్ అయ్యాయి. పూర్తి చేసినట్టు నిర్ధారించడానికి ఫలితం చూడండి ఎంచుకోండి.';

  @override
  String quizAsksToConfirm(String label) {
    return '$label, నిర్ధారించమని అడుగుతుంది';
  }

  @override
  String get quizConfirmingCompletion => 'పూర్తి చేసినట్టు నిర్ధారిస్తోంది';

  @override
  String get quizRetryCompletionKey5 => '5: పూర్తి చేయడం మళ్ళీ ప్రయత్నించండి';

  @override
  String get quizViewResultKey5 => '5: ఫలితం చూడండి';

  @override
  String quizHistoryTitle(String title) {
    return '$title చరిత్ర';
  }

  @override
  String get quizNoAttemptsYet => 'ఇంకా ప్రయత్నాలు లేవు';

  @override
  String get quizHistoryTooltip => 'ప్రయత్నాల చరిత్ర మరియు సమీక్ష';

  @override
  String get quizLeaveWithoutSubmitting => 'సమర్పించకుండా వెళ్ళండి';

  @override
  String get quizAttemptCompletePrivateLabel =>
      'ప్రయత్నం పూర్తయింది. ఫలితం ప్రైవేట్. ఫలితాన్ని ప్రైవేట్‌గా వినండి ఉపయోగించండి.';

  @override
  String get quizReadResultKey8 => '8: ఫలితాన్ని ప్రైవేట్‌గా వినండి';

  @override
  String get quizReturnKey0 => '0: క్విజ్‌లకు తిరిగి వెళ్ళండి';

  @override
  String get quizReadAllOptionsLabel => 'అన్ని ఎంపికలు వినండి';

  @override
  String get quizSubmitAnswerKey5 => '5: జవాబు సమర్పించండి';

  @override
  String get quizAnswerLockedActivate =>
      'జవాబు సేవ్ చేయబడింది మరియు లాక్ చేయబడింది. ఫీడ్‌బ్యాక్‌ను ప్రైవేట్‌గా వినడానికి దీన్ని ఎంచుకోండి.';

  @override
  String get quizReadSelectedAnswer => 'ఎంచుకున్న జవాబు వినండి';

  @override
  String get quizReadRemainingTime => 'మిగిలిన సమయం వినండి';

  @override
  String get quizAttemptReviewTitle => 'ప్రయత్నం సమీక్ష';

  @override
  String get quizEditorIntro =>
      'ప్రశ్నను మరియు నాలుగు ఎంపికలను పూర్తి చేసి, సరైన జవాబును ఎంచుకోండి. సమీకరణాలు లేదా చిత్రాల కోసం, ఐచ్ఛిక మాట్లాడే రూపాన్ని తెరిచి, ప్రత్యామ్నాయాలను సమీక్షించండి.';

  @override
  String get quizWhichCorrect => 'ఏ జవాబు సరైనది?';

  @override
  String get quizChooseCorrectOption => 'సరైన ఎంపికను ఎంచుకోండి';

  @override
  String quizOptionWithText(String number, String text) {
    return 'ఎంపిక $number: $text';
  }

  @override
  String get quizCorrectChoiceHint =>
      'మార్చడానికి ఎడమ లేదా కుడి ఉపయోగించండి. ఓకే లేదా ట్యాప్ తర్వాతి ఎంపికను ఎంచుకుంటుంది.';

  @override
  String get quizExplanationOptional => 'వివరణ (ఐచ్ఛికం)';

  @override
  String get quizContentDescribedText =>
      'విషయం: ఉపాధ్యాయులు వివరించిన గుర్తులు లేదా చిత్రం';

  @override
  String get quizNotationNote =>
      'సమీకరణాలు లేదా చిత్రాలను ఆటోమేటిక్‌గా అర్థం చేసుకోవడం అందుబాటులో లేదు. ఉపాధ్యాయులు ఇంగ్లీష్ మాట్లాడే ప్రత్యామ్నాయాలను రాసి సమీక్షించాలి. వివరించిన గుర్తుల కోసం, ప్రశ్న, అన్ని ఎంపికలు మరియు ఏదైనా వివరణను చేర్చండి.';

  @override
  String get quizReviewedAlternatives =>
      'మాట్లాడే ప్రత్యామ్నాయాలు సరైనవో కాదో నేను సమీక్షించాను';

  @override
  String get quizChangeSettings => 'క్విజ్ సెట్టింగ్‌లను మార్చండి';

  @override
  String get quizCreatePracticeText => 'సమయ పరిమితి లేని అభ్యాసం సృష్టించండి';

  @override
  String get quizStepName => 'దశ 1: మీ క్విజ్‌కు పేరు పెట్టండి';

  @override
  String get quizPracticeInfo =>
      'అభ్యాసంలో ఒక్కో ప్రయత్నానికి టైమర్ లేదా ప్రయత్నాల పరిమితి ఉండదు. ఐచ్ఛిక ముగింపు సమయం ఉంటే, అప్పుడు అది అందుబాటులో ఉండదు.';

  @override
  String get quizSettingsNavLabel =>
      'క్విజ్ సెట్టింగ్‌లలో కదలడానికి పైకి మరియు కిందికి ఉపయోగించండి. టెక్స్ట్ ఫీల్డ్‌లను మార్చడానికి ఓకే నొక్కండి. ప్రారంభ మరియు ముగింపు సమయాలు ఐచ్ఛికం.';

  @override
  String get quizSettingsNavText =>
      'సెట్టింగ్‌లలో కదలడానికి పైకి మరియు కిందికి, మార్చడానికి ఓకే ఉపయోగించండి. డ్రాఫ్ట్‌ను లేదా దాని సెట్టింగ్‌లను సేవ్ చేస్తే క్విజ్ ప్రచురించబడదు.';

  @override
  String get quizSettingsReviewInfo =>
      'కింద సేవ్ చేసిన సెట్టింగ్‌లను సమీక్షించి మార్చండి. సేవ్ చేస్తే క్విజ్ ప్రచురించబడదు.';

  @override
  String get quizPracticeDefaults =>
      'మార్కులు లేని అభ్యాసం. అపరిమిత ప్రయత్నాలు, టైమర్ లేదు, వెంటనే ఫీడ్‌బ్యాక్.';

  @override
  String get quizGradedDefaults =>
      'మార్కులతో క్విజ్ డిఫాల్ట్ సెట్టింగ్‌లు: ఒక ప్రయత్నం, టైమర్ లేదు, చివరి సమర్పణ తర్వాత ఫీడ్‌బ్యాక్.';

  @override
  String get quizHideOptionalSettingsText => 'ఐచ్ఛిక సెట్టింగ్‌లను దాచండి';

  @override
  String get quizShowOptionalSettingsText => 'ఐచ్ఛిక సెట్టింగ్‌లను చూపండి';

  @override
  String get quizAttemptLimitFieldText => 'ప్రయత్నాల పరిమితి, 1 నుండి 20';

  @override
  String get quizTimeLimitFieldText => 'సమయ పరిమితి నిమిషాల్లో (ఐచ్ఛికం)';

  @override
  String get quizUntimedInfo =>
      'సమయ పరిమితి లేదు, మార్కులు లేవు, అపరిమిత ప్రయత్నాలు. అందుబాటు సమయాలు సెట్ చేస్తే అవి ఇంకా వర్తిస్తాయి.';

  @override
  String quizFeedbackValue(String policy) {
    return 'ఫీడ్‌బ్యాక్: $policy';
  }

  @override
  String quizReleaseValue(String time) {
    return 'విడుదల: $time';
  }

  @override
  String quizOpeningTimeLabel(String time) {
    return '$time. ప్రారంభ సమయం సెట్ చేయడానికి ఓకే నొక్కండి. ఎడమ దాన్ని తీసివేస్తుంది.';
  }

  @override
  String get quizNoOpeningTimeSet => 'ప్రారంభ సమయం సెట్ చేయలేదు';

  @override
  String get quizNoOpeningTimeShort => 'ప్రారంభ సమయం లేదు';

  @override
  String get quizOpeningTimeHint =>
      'ఐచ్ఛికం · సంవత్సరం, నెల, రోజు, గంట మరియు నిమిషం నమోదు చేయండి';

  @override
  String quizClosingTimeLabel(String time) {
    return '$time. ముగింపు సమయం సెట్ చేయడానికి ఓకే నొక్కండి. ఎడమ దాన్ని తీసివేస్తుంది.';
  }

  @override
  String get quizNoClosingTimeSet => 'ముగింపు సమయం సెట్ చేయలేదు';

  @override
  String get quizNoClosingTimeShort => 'ముగింపు సమయం లేదు';

  @override
  String get quizClosingTimeHint => 'ఐచ్ఛికం · ప్రారంభ సమయం తర్వాత ఉండాలి';

  @override
  String get quizShuffleQuestions =>
      'ప్రతి ప్రయత్నానికి ఒకసారి ప్రశ్నల క్రమం మార్చండి';

  @override
  String get quizShuffleOptions =>
      'ప్రతి ప్రయత్నానికి ఒకసారి ఎంపికల క్రమం మార్చండి';

  @override
  String messageProblem(String text) {
    return 'సమస్య: $text';
  }

  @override
  String messageMessage(String text) {
    return 'సందేశం: $text';
  }

  @override
  String get adminSetupSectionAccounts => 'ఖాతాలు';

  @override
  String get adminSetupSectionCatalog => 'తరగతులు మరియు సబ్జెక్టులు';

  @override
  String get adminSetupSectionTimetable => 'టైమ్‌టేబుల్';

  @override
  String get adminSetupSectionSchedule => 'ఈరోజు టైమ్‌టేబుల్';

  @override
  String get adminSetupSectionSharedPhones => 'పంచుకునే ఫోన్‌లు';

  @override
  String get adminSetupSectionHolidays => 'సెలవులు';

  @override
  String get adminSetupSectionIssues => 'సమస్యలు';

  @override
  String get adminSetupSectionRecords => 'తరగతి రికార్డులు';

  @override
  String get adminSetupSectionPicker => 'విభాగం';

  @override
  String adminSetupRefresh(String section) {
    return '$section రిఫ్రెష్ చేయండి';
  }

  @override
  String get adminSetupLogOut => 'లాగ్ అవుట్';

  @override
  String get adminSetupLoading => 'లోడ్ అవుతోంది';

  @override
  String get adminSetupSaving => 'సేవ్ అవుతోంది';

  @override
  String get adminSetupRetry => 'మళ్ళీ ప్రయత్నించండి';

  @override
  String adminSetupLoadFailed(String reason) {
    return 'ఈ జాబితాను లోడ్ చేయలేకపోయాము. $reason';
  }

  @override
  String get adminSetupUnknownError =>
      'ఏదో తప్పు జరిగింది. దయచేసి మళ్ళీ ప్రయత్నించండి.';

  @override
  String get adminSetupNotSaved =>
      'మార్పును సేవ్ చేయలేకపోయాము. రిఫ్రెష్ చేసి మళ్ళీ ప్రయత్నించండి.';

  @override
  String get adminSetupCancel => 'రద్దు చేయండి';

  @override
  String get adminSetupSave => 'సేవ్ చేయండి';

  @override
  String get adminSetupClose => 'మూసివేయండి';

  @override
  String get adminSetupDelete => 'తొలగించండి';

  @override
  String get adminSetupRemove => 'తీసివేయండి';

  @override
  String get adminSetupEdit => 'మార్చండి';

  @override
  String adminSetupEditNamed(String name) {
    return '$name మార్చండి';
  }

  @override
  String adminSetupRequiredField(String field) {
    return '$field తప్పనిసరి.';
  }

  @override
  String get adminSetupNoDate => 'సెట్ చేయలేదు';

  @override
  String adminSetupDateValue(String field, String date) {
    return '$field: $date';
  }

  @override
  String adminSetupClearDate(String field) {
    return '$field తీసివేయండి';
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
  String get adminSetupDateField => 'తేదీ';

  @override
  String get adminSetupInactive => 'నిష్క్రియం చేయబడింది';

  @override
  String get adminSetupFilterAll => 'అన్నీ';

  @override
  String get adminSetupShowFilter => 'చూపించు';

  @override
  String get adminSetupRoleStudent => 'విద్యార్థి';

  @override
  String get adminSetupRoleTeacher => 'ఉపాధ్యాయులు';

  @override
  String get adminSetupAddPerson => 'వ్యక్తిని జోడించండి';

  @override
  String get adminSetupSearchLabel => 'పేరు లేదా ఫోన్ నంబర్‌తో వెతకండి';

  @override
  String get adminSetupSearchButton => 'వెతకండి';

  @override
  String get adminSetupAccountTypeHeading => 'ఖాతా రకం';

  @override
  String get adminSetupAssignmentHeading => 'తరగతి లేదా సబ్జెక్టు కేటాయింపు';

  @override
  String adminSetupAccountsShown(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ఖాతాలు చూపబడ్డాయి.',
      one: '1 ఖాతా చూపబడింది.',
      zero: 'సరిపోయే ఖాతాలు లేవు.',
    );
    return '$_temp0';
  }

  @override
  String adminSetupTeachersHeading(int count) {
    return 'ఉపాధ్యాయులు ($count)';
  }

  @override
  String adminSetupStudentsHeading(int count) {
    return 'విద్యార్థులు ($count)';
  }

  @override
  String get adminSetupNameField => 'పేరు';

  @override
  String get adminSetupPhoneField => 'ఫోన్ నంబర్';

  @override
  String get adminSetupRoleField => 'పాత్ర';

  @override
  String get adminSetupTeacherPairsHeading =>
      'ఈ ఉపాధ్యాయులు బోధించే తరగతులు మరియు సబ్జెక్టులు';

  @override
  String get adminSetupNoPairs =>
      'ఇంకా ఏవీ లేవు. మీరు వాటిని తర్వాత జోడించవచ్చు.';

  @override
  String get adminSetupClassField => 'తరగతి';

  @override
  String get adminSetupSubjectField => 'సబ్జెక్టు';

  @override
  String get adminSetupAddPair => 'తరగతి మరియు సబ్జెక్టు జోడించండి';

  @override
  String adminSetupPairLabel(String className, String subject) {
    return '$className, $subject';
  }

  @override
  String adminSetupRemovePair(String className, String subject) {
    return '$className, $subject తీసివేయండి';
  }

  @override
  String get adminSetupNoSubjectsInClass =>
      'ఈ తరగతికి ఇంకా సబ్జెక్టులు లేవు. తరగతులు మరియు సబ్జెక్టులు విభాగంలో సబ్జెక్టులను జోడించండి.';

  @override
  String get adminSetupNoActiveClasses =>
      'ఇంకా యాక్టివ్ తరగతులు లేవు. తరగతులు మరియు సబ్జెక్టులు విభాగంలో ఒకటి జోడించండి.';

  @override
  String adminSetupPersonAdded(String name) {
    return '$name జోడించబడ్డారు.';
  }

  @override
  String adminSetupEditPerson(String name) {
    return '$name మార్చండి';
  }

  @override
  String get adminSetupPhoneChangeNote =>
      'ఫోన్ నంబర్ మార్చితే, ఈ వ్యక్తి అన్ని ఫోన్‌లలో సైన్ అవుట్ అవుతారు.';

  @override
  String adminSetupPersonSaved(String name) {
    return '$name కు చేసిన మార్పులు సేవ్ అయ్యాయి.';
  }

  @override
  String get adminSetupDeactivate => 'నిష్క్రియం చేయండి';

  @override
  String get adminSetupActivate => 'యాక్టివేట్ చేయండి';

  @override
  String adminSetupDeactivateNamed(String name) {
    return '$name ను నిష్క్రియం చేయండి';
  }

  @override
  String adminSetupActivateNamed(String name) {
    return '$name ను యాక్టివేట్ చేయండి';
  }

  @override
  String adminSetupDeactivateTitle(String name) {
    return '$name ను నిష్క్రియం చేయాలా?';
  }

  @override
  String adminSetupDeactivateMessage(String name) {
    return '$name సైన్ అవుట్ అవుతారు, ఖాతాను మళ్ళీ యాక్టివేట్ చేసే వరకు సైన్ ఇన్ చేయలేరు.';
  }

  @override
  String adminSetupActivated(String name) {
    return '$name మళ్ళీ సైన్ ఇన్ చేయవచ్చు.';
  }

  @override
  String adminSetupDeactivated(String name) {
    return '$name నిష్క్రియం చేయబడ్డారు.';
  }

  @override
  String get adminSetupSignOutEverywhere => 'అన్ని చోట్లా సైన్ అవుట్ చేయండి';

  @override
  String adminSetupSignOutNamed(String name) {
    return '$name ను అన్ని చోట్లా సైన్ అవుట్ చేయండి';
  }

  @override
  String adminSetupSignOutTitle(String name) {
    return '$name ను అన్ని చోట్లా సైన్ అవుట్ చేయాలా?';
  }

  @override
  String adminSetupSignOutMessage(String name) {
    return 'ఇది అన్ని ఫోన్‌లలో $name సైన్ ఇన్‌ను ముగిస్తుంది, ఉదాహరణకు వేరొకరు వారి నంబర్‌ను వాడితే. వారు తమ ఫోన్ నంబర్‌తో మళ్ళీ సైన్ ఇన్ చేయవచ్చు.';
  }

  @override
  String adminSetupSignedOut(String name) {
    return '$name అన్ని చోట్లా సైన్ అవుట్ చేయబడ్డారు.';
  }

  @override
  String get adminSetupStudentClassAction => 'తరగతి మార్చండి';

  @override
  String get adminSetupTeacherAssignmentsAction => 'తరగతులు మరియు సబ్జెక్టులు';

  @override
  String adminSetupStudentDetail(String className) {
    return 'విద్యార్థి. తరగతి: $className';
  }

  @override
  String get adminSetupStudentNoClass => 'విద్యార్థి. ఇంకా తరగతి లేదు.';

  @override
  String adminSetupTeacherDetail(String pairs) {
    return 'ఉపాధ్యాయులు. బోధించేవి: $pairs';
  }

  @override
  String get adminSetupTeacherNoPairs =>
      'ఉపాధ్యాయులు. ఇంకా తరగతులు లేదా సబ్జెక్టులు లేవు.';

  @override
  String adminSetupPhoneDetail(String phone) {
    return 'ఫోన్: $phone';
  }

  @override
  String adminSetupClassDialogTitle(String name) {
    return '$name కోసం తరగతి';
  }

  @override
  String adminSetupRemoveFromClass(String className) {
    return '$className నుండి తీసివేయండి';
  }

  @override
  String adminSetupStudentEnrolled(String name, String className) {
    return '$name ఇప్పుడు $className లో ఉన్నారు.';
  }

  @override
  String adminSetupStudentRemoved(String name) {
    return '$name వారి తరగతి నుండి తీసివేయబడ్డారు.';
  }

  @override
  String adminSetupAssignmentsTitle(String name) {
    return '$name కోసం తరగతులు మరియు సబ్జెక్టులు';
  }

  @override
  String get adminSetupCurrentPairs => 'ప్రస్తుతం బోధిస్తున్నవి';

  @override
  String adminSetupPairAdded(String name, String className, String subject) {
    return '$name ఇప్పుడు $className, $subject బోధిస్తారు.';
  }

  @override
  String adminSetupPairRemoved(String name, String className, String subject) {
    return '$name ఇకపై $className, $subject బోధించరు.';
  }

  @override
  String get adminSetupClassesHeading => 'తరగతులు';

  @override
  String get adminSetupSubjectsHeading => 'సబ్జెక్టులు';

  @override
  String get adminSetupAddClass => 'తరగతి జోడించండి';

  @override
  String get adminSetupAddSubject => 'సబ్జెక్టు జోడించండి';

  @override
  String get adminSetupNoClasses => 'ఇంకా తరగతులు లేవు.';

  @override
  String get adminSetupNoSubjects => 'ఇంకా సబ్జెక్టులు లేవు.';

  @override
  String get adminSetupSubjectsButton => 'సబ్జెక్టులు';

  @override
  String adminSetupClassSubjects(String className) {
    return '$className లోని సబ్జెక్టులు';
  }

  @override
  String adminSetupArchiveNamed(String name) {
    return '$name ఆర్కైవ్ చేయండి';
  }

  @override
  String adminSetupRestoreNamed(String name) {
    return '$name పునరుద్ధరించండి';
  }

  @override
  String get adminSetupNoSubjectsToChoose =>
      'ఇంకా యాక్టివ్ సబ్జెక్టులు లేవు. ముందుగా ఒక సబ్జెక్టు జోడించండి.';

  @override
  String get adminSetupAddLesson => 'టైమ్‌టేబుల్‌కు పాఠం జోడించండి';

  @override
  String get adminSetupEditLesson => 'టైమ్‌టేబుల్ పాఠాన్ని మార్చండి';

  @override
  String get adminSetupAllTeachers => 'అందరు ఉపాధ్యాయులు';

  @override
  String get adminSetupAllClasses => 'అన్ని తరగతులు';

  @override
  String get adminSetupTeacherField => 'ఉపాధ్యాయులు';

  @override
  String get adminSetupWeekdayField => 'వారంలో రోజు';

  @override
  String get adminSetupStartField => 'ప్రారంభ సమయం';

  @override
  String get adminSetupEndField => 'ముగింపు సమయం';

  @override
  String get adminSetupTimeHelper => '24 గంటల భారత సమయం (IST), ఉదాహరణకు 09:30';

  @override
  String adminSetupTimeInvalid(String field) {
    return '$field ను 24 గంటల సమయంగా నమోదు చేయండి, ఉదాహరణకు 09:30.';
  }

  @override
  String get adminSetupEndBeforeStart => 'పాఠం ప్రారంభమైన తర్వాతే ముగియాలి.';

  @override
  String get adminSetupUntilBeforeFrom =>
      'చివరి తేదీ మొదటి తేదీ రోజు లేదా ఆ తర్వాత ఉండాలి.';

  @override
  String get adminSetupValidFrom => 'మొదటి తేదీ';

  @override
  String get adminSetupValidUntil => 'చివరి తేదీ';

  @override
  String get adminSetupLessonField => 'పాఠం ప్లేలిస్ట్ (ఐచ్ఛికం)';

  @override
  String get adminSetupNoLesson => 'పాఠం ప్లేలిస్ట్ లేదు';

  @override
  String get adminSetupNoLessonsFound =>
      'ఈ ఉపాధ్యాయులకు ఈ తరగతి మరియు సబ్జెక్టుకు ఇంకా పాఠం ప్లేలిస్ట్‌లు లేవు.';

  @override
  String get adminSetupShowInactive => 'నిష్క్రియం చేసిన పాఠాలను చూపండి';

  @override
  String get adminSetupNoTimetable => 'సరిపోయే టైమ్‌టేబుల్ పాఠాలు లేవు.';

  @override
  String adminSetupEntryTitle(
    String start,
    String end,
    String subject,
    String className,
  ) {
    return '$start నుండి $end: $subject, $className';
  }

  @override
  String adminSetupEntryTeacher(String name) {
    return 'ఉపాధ్యాయులు: $name';
  }

  @override
  String adminSetupEntryLesson(String title) {
    return 'పాఠం ప్లేలిస్ట్: $title';
  }

  @override
  String get adminSetupEntryNoLesson => 'పాఠం ప్లేలిస్ట్ ఎంచుకోలేదు.';

  @override
  String adminSetupEntryFrom(String date) {
    return '$date నుండి';
  }

  @override
  String adminSetupEntryUntil(String date) {
    return '$date వరకు';
  }

  @override
  String get adminSetupDateChanges => 'తేదీ మార్పులు';

  @override
  String adminSetupDateChangesNamed(String title) {
    return '$title కోసం తేదీ మార్పులు';
  }

  @override
  String get adminSetupDeactivateLesson => 'నిష్క్రియం చేయండి';

  @override
  String get adminSetupReactivateLesson => 'మళ్ళీ యాక్టివేట్ చేయండి';

  @override
  String get adminSetupDeactivateLessonTitle => 'ఈ పాఠాన్ని నిష్క్రియం చేయాలా?';

  @override
  String adminSetupDeactivateLessonMessage(
    String subject,
    String className,
    String weekday,
    String start,
  ) {
    return '$weekday న $start కు $className కోసం $subject ఇకపై టైమ్‌టేబుల్‌లో ఉండదు.';
  }

  @override
  String get adminSetupLessonSaved => 'టైమ్‌టేబుల్ సేవ్ అయింది.';

  @override
  String get adminSetupLessonDeactivated => 'పాఠం నిష్క్రియం చేయబడింది.';

  @override
  String get adminSetupLessonReactivated => 'పాఠం మళ్ళీ యాక్టివేట్ చేయబడింది.';

  @override
  String adminSetupClassSubjectFixed(String className, String subject) {
    return '$className, $subject. తరగతి లేదా సబ్జెక్టు మార్చడానికి, ఈ పాఠాన్ని నిష్క్రియం చేసి కొత్తది జోడించండి.';
  }

  @override
  String adminSetupDateChangesTitle(String lesson, String weekday) {
    return 'తేదీ మార్పులు: $lesson, ప్రతి $weekday';
  }

  @override
  String get adminSetupNoDateChanges => 'తేదీ మార్పులు లేవు.';

  @override
  String get adminSetupAddDateChange => 'ఒక తేదీని మార్చండి';

  @override
  String get adminSetupCancelledLabel => 'ఈ తేదీన రద్దు చేయబడింది.';

  @override
  String adminSetupSubstituteLabel(String name) {
    return 'బదులు ఉపాధ్యాయులు: $name';
  }

  @override
  String get adminSetupDifferentLesson =>
      'ఈ తేదీన వేరే పాఠం ప్లేలిస్ట్ వాడబడుతుంది.';

  @override
  String adminSetupNoteLabel(String note) {
    return 'నోట్: $note';
  }

  @override
  String get adminSetupClearChange => 'మార్పును తీసివేయండి';

  @override
  String adminSetupClearChangeNamed(String date) {
    return '$date కోసం మార్పును తీసివేయండి';
  }

  @override
  String adminSetupEditDateChangeNamed(String date) {
    return '$date కోసం మార్పును సవరించండి';
  }

  @override
  String adminSetupChangeCleared(String date) {
    return '$date కోసం మార్పు తీసివేయబడింది.';
  }

  @override
  String adminSetupDateChangeTitle(String lesson) {
    return 'ఒక తేదీని మార్చండి: $lesson';
  }

  @override
  String get adminSetupCancelOnDate => 'ఈ తేదీన పాఠాన్ని రద్దు చేయండి';

  @override
  String get adminSetupSubstituteField => 'బదులు ఉపాధ్యాయులు (ఐచ్ఛికం)';

  @override
  String adminSetupRegularTeacher(String name) {
    return 'బదులు ఎవరూ లేరు ($name బోధిస్తారు)';
  }

  @override
  String get adminSetupDateLessonField => 'ఈ తేదీన పాఠం ప్లేలిస్ట్';

  @override
  String get adminSetupUsualLesson => 'ఎప్పటిలాగే';

  @override
  String get adminSetupNoteField => 'నోట్ (ఐచ్ఛికం)';

  @override
  String adminSetupDateChangeSaved(String date) {
    return '$date కోసం మార్పు సేవ్ అయింది.';
  }

  @override
  String get adminSetupChooseDateFirst => 'ఒక తేదీని ఎంచుకోండి.';

  @override
  String get adminSetupPreviousDay => 'మునుపటి రోజు';

  @override
  String get adminSetupNextDay => 'తర్వాతి రోజు';

  @override
  String get adminSetupToday => 'ఈరోజు';

  @override
  String adminSetupScheduleFor(String date) {
    return '$date న పాఠాలు';
  }

  @override
  String get adminSetupNoLessonsOnDay => 'ఈ తేదీన పాఠాలు లేవు.';

  @override
  String adminSetupScheduleSubstitute(String name) {
    return 'ఉపాధ్యాయులు: $name (బదులు)';
  }

  @override
  String adminSetupStateLabel(String state) {
    return 'స్థితి: $state';
  }

  @override
  String get adminSetupStateUpcoming => 'రాబోతోంది';

  @override
  String get adminSetupStateLive => 'ఇప్పుడు లైవ్‌లో ఉంది';

  @override
  String get adminSetupStateHeld => 'జరిగింది';

  @override
  String get adminSetupStateCancelled => 'రద్దు చేయబడింది';

  @override
  String get adminSetupStateNotStarted => 'ప్రారంభం కాలేదు';

  @override
  String get adminSetupLessonReady => 'పాఠం ప్లేలిస్ట్ సిద్ధంగా ఉంది.';

  @override
  String get adminSetupSharedPhoneNote =>
      'షేర్ చేసిన ఫోన్‌లో, ప్రతి వ్యక్తి షేర్ చేసిన ఫోన్ నంబర్‌ను, తర్వాత తమ చిన్న ప్రొఫైల్ నంబర్‌ను నమోదు చేస్తారు. ప్రొఫైల్ నంబర్ ఎవరి ఖాతా తెరవాలో మాత్రమే ఎంచుకుంటుంది. ఇది పాస్‌వర్డ్ కాదు.';

  @override
  String get adminSetupAddSharedPhone => 'షేర్ చేసిన ఫోన్‌ను జోడించండి';

  @override
  String get adminSetupEditSharedPhone => 'షేర్ చేసిన ఫోన్‌ను మార్చండి';

  @override
  String get adminSetupSharedPhoneName => 'పేరు, ఉదాహరణకు తరగతి 5 ఫోన్';

  @override
  String get adminSetupSharedPhoneNumber => 'షేర్ చేసిన ఫోన్ నంబర్';

  @override
  String get adminSetupSharedPhoneActiveSwitch =>
      'షేర్ చేసిన ఫోన్‌ను ఉపయోగించవచ్చు';

  @override
  String get adminSetupSharedPhoneSaved => 'షేర్ చేసిన ఫోన్ సేవ్ చేయబడింది.';

  @override
  String get adminSetupNoSharedPhones => 'ఇంకా షేర్ చేసిన ఫోన్‌లు లేవు.';

  @override
  String adminSetupGroupNumber(String phone) {
    return 'నంబర్: $phone';
  }

  @override
  String adminSetupMemberLine(String name, String role, String code) {
    return '$name, $role. ప్రొఫైల్ నంబర్ $code';
  }

  @override
  String get adminSetupNoMembers => 'ఈ ఫోన్‌లో ఇంకా ఎవరూ లేరు.';

  @override
  String get adminSetupAddMember => 'వ్యక్తిని జోడించండి';

  @override
  String adminSetupAddMemberTitle(String group) {
    return '$groupకు ఒక వ్యక్తిని జోడించండి';
  }

  @override
  String get adminSetupSearchPeople =>
      'పేరు లేదా ఫోన్ నంబర్‌తో వ్యక్తులను వెతకండి';

  @override
  String get adminSetupNoPeopleFound => 'సరిపోయే వ్యక్తులు ఎవరూ లేరు.';

  @override
  String get adminSetupPersonField => 'వ్యక్తి';

  @override
  String adminSetupPersonOption(String name, String role, String phone) {
    return '$name, $role, $phone';
  }

  @override
  String get adminSetupChoosePerson => 'ఒక వ్యక్తిని ఎంచుకోండి.';

  @override
  String get adminSetupProfileCodeField => 'ప్రొఫైల్ నంబర్';

  @override
  String get adminSetupProfileCodeHelper =>
      '1 నుండి 4 అంకెలు, ఈ ఫోన్‌లో ప్రతి వ్యక్తికి వేరుగా ఉండాలి.';

  @override
  String get adminSetupProfileCodeInvalid =>
      '1 నుండి 4 అంకెల ప్రొఫైల్ నంబర్‌ను నమోదు చేయండి.';

  @override
  String adminSetupMemberAdded(String name, String group) {
    return '$nameను $groupకు జోడించారు.';
  }

  @override
  String adminSetupRemoveMemberNamed(String name, String group) {
    return '$group నుండి $nameను తీసివేయండి';
  }

  @override
  String adminSetupRemoveMemberTitle(String name, String group) {
    return '$group నుండి $nameను తీసివేయాలా?';
  }

  @override
  String adminSetupRemoveMemberMessage(String name) {
    return '$name ఇకపై ఈ షేర్ చేసిన ఫోన్‌లో తమ ప్రొఫైల్‌ను ఎంచుకోలేరు.';
  }

  @override
  String adminSetupMemberRemoved(String name, String group) {
    return '$group నుండి $nameను తీసివేశారు.';
  }

  @override
  String get adminSetupHolidayNote => 'సెలవు రోజుల్లో పాఠాలు షెడ్యూల్ చేయబడవు.';

  @override
  String get adminSetupAddHoliday => 'సెలవును జోడించండి';

  @override
  String get adminSetupHolidayName => 'సెలవు పేరు';

  @override
  String get adminSetupNoHolidays => 'ఇంకా సెలవులు లేవు.';

  @override
  String adminSetupHolidayAdded(String name, String date) {
    return '$dateన $name జోడించబడింది.';
  }

  @override
  String adminSetupDeleteHolidayNamed(String name, String date) {
    return '$dateన ఉన్న $nameను తొలగించండి';
  }

  @override
  String get adminSetupDeleteHolidayTitle => 'ఈ సెలవును తొలగించాలా?';

  @override
  String adminSetupDeleteHolidayMessage(String name, String date) {
    return '$dateన ఉన్న $name తీసివేయబడుతుంది, ఆ తేదీన మళ్ళీ పాఠాలు షెడ్యూల్ చేయబడతాయి.';
  }

  @override
  String get adminSetupHolidayDeleted => 'సెలవు తొలగించబడింది.';

  @override
  String get adminSetupIssuesOpen => 'పరిష్కరించనివి';

  @override
  String get adminSetupIssuesResolved => 'పరిష్కరించబడినవి';

  @override
  String get adminSetupNoIssues => 'చూపించడానికి సమస్యలు లేవు.';

  @override
  String adminSetupIssueSeen(int count, String when) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count సార్లు కనిపించింది.',
      one: 'ఒకసారి కనిపించింది.',
    );
    return '$_temp0 చివరిగా $when కనిపించింది.';
  }

  @override
  String get adminSetupMarkResolved => 'పరిష్కరించబడినట్లు గుర్తించండి';

  @override
  String adminSetupMarkResolvedNamed(String message) {
    return 'పరిష్కరించబడినట్లు గుర్తించండి: $message';
  }

  @override
  String get adminSetupIssueResolved =>
      'సమస్య పరిష్కరించబడినట్లు గుర్తించబడింది.';

  @override
  String get adminSetupRecordsLive => 'లైవ్';

  @override
  String get adminSetupRecordsEnded => 'ముగిసినవి';

  @override
  String get adminSetupNoRecords => 'చూపించడానికి తరగతులు లేవు.';

  @override
  String adminSetupRecordTitle(String subject, String className) {
    return '$subject, $className';
  }

  @override
  String get adminSetupRecordLive => 'ఇప్పుడు లైవ్‌లో ఉంది';

  @override
  String adminSetupRecordLiveUntil(String clock) {
    return 'ఇప్పుడు లైవ్‌లో ఉంది. $clockకు ముగుస్తుంది';
  }

  @override
  String adminSetupRecordStarted(String when) {
    return '$when ప్రారంభమైంది';
  }

  @override
  String adminSetupRecordEnded(String when) {
    return '$when ముగిసింది';
  }

  @override
  String get adminSetupEndedByTeacher => 'ఉపాధ్యాయులు తరగతిని ముగించారు.';

  @override
  String get adminSetupEndedByAdmin => 'నిర్వాహకులు తరగతిని ముగించారు.';

  @override
  String get adminSetupEndedAutomatically =>
      'ముగింపు సమయానికి తరగతి ఆటోమేటిక్‌గా ముగిసింది.';

  @override
  String adminSetupEndedOther(String reason) {
    return 'ముగింపు కారణం: $reason';
  }

  @override
  String adminSetupStudentsJoined(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count మంది విద్యార్థులు చేరారు.',
      one: '1 విద్యార్థి చేరారు.',
      zero: 'విద్యార్థులు ఎవరూ చేరలేదు.',
    );
    return '$_temp0';
  }

  @override
  String adminSetupExtensionMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count అదనపు నిమిషాలు జోడించబడ్డాయి.',
      one: '1 అదనపు నిమిషం జోడించబడింది.',
      zero: 'అదనపు సమయం జోడించలేదు.',
    );
    return '$_temp0';
  }

  @override
  String get adminSetupAddFifteen => '15 నిమిషాలు జోడించండి';

  @override
  String adminSetupAddFifteenNamed(String title) {
    return '$titleకు 15 నిమిషాలు జోడించండి';
  }

  @override
  String get adminSetupEndForEveryone => 'అందరికీ తరగతిని ముగించండి';

  @override
  String adminSetupEndForEveryoneNamed(String title) {
    return 'అందరికీ $titleను ముగించండి';
  }

  @override
  String get adminSetupEndTitle => 'అందరికీ ఈ తరగతిని ముగించాలా?';

  @override
  String adminSetupEndMessage(String title) {
    return 'ఉపాధ్యాయులకు మరియు ప్రతి విద్యార్థికి $title ఇప్పుడే ముగుస్తుంది.';
  }

  @override
  String get adminSetupKeepClass => 'తరగతిని కొనసాగించండి';

  @override
  String get adminSetupEndClass => 'తరగతిని ముగించండి';

  @override
  String get adminSetupEnded => 'తరగతి ముగించబడింది.';

  @override
  String adminSetupExtended(String clock) {
    return 'తరగతి ఇప్పుడు $clockకు ముగుస్తుంది.';
  }

  @override
  String get loginScreenName => 'సైన్ ఇన్';

  @override
  String get loginIntro =>
      'మీ ఫోన్ నంబర్ టైప్ చేసి, ఓకే నొక్కండి, తర్వాత సైన్ ఇన్ చేయడానికి 1 నొక్కండి.';

  @override
  String get loginPhoneField => 'ఫోన్ నంబర్. నంబర్ కీలతో టైప్ చేయండి.';

  @override
  String get loginPhoneLabel => 'ఫోన్ నంబర్';

  @override
  String get loginProfileField => 'ఈ షేర్ చేసిన ఫోన్‌లో మీ ప్రొఫైల్ నంబర్';

  @override
  String get loginProfileLabel => 'ప్రొఫైల్ నంబర్';

  @override
  String get loginEnterProfileCode =>
      'ఈ ఫోన్ షేర్ చేయబడింది. మీ ప్రొఫైల్ నంబర్ టైప్ చేసి, ఓకే నొక్కండి, తర్వాత 1 నొక్కండి.';

  @override
  String get loginKeySignIn => 'సైన్ ఇన్';

  @override
  String get loginKeyContinue => 'కొనసాగించండి';

  @override
  String get loginKeySim => 'SIM కార్డ్ నుండి నా నంబర్‌ను నింపండి';

  @override
  String get loginKeyAdmin => 'నిర్వాహకుల సైన్ ఇన్';

  @override
  String get loginKeyChangeNumber => 'వేరే నంబర్ ఉపయోగించండి';

  @override
  String get loginErrorEnterPhone => 'ముందుగా మీ ఫోన్ నంబర్ టైప్ చేయండి.';

  @override
  String get loginErrorEnterProfile => 'ముందుగా మీ ప్రొఫైల్ నంబర్ టైప్ చేయండి.';

  @override
  String get loginNumberNotRegistered =>
      'ఈ నంబర్ నమోదు కాలేదు. మిమ్మల్ని జోడించమని మీ పాఠశాల నిర్వాహకులను అడగండి.';

  @override
  String get loginProfileNotRecognised =>
      'ఆ ప్రొఫైల్ నంబర్ ఈ ఫోన్‌లో లేదు. మళ్ళీ ప్రయత్నించండి.';

  @override
  String get loginAdminUsesPassword =>
      'నిర్వాహకులు పాస్‌వర్డ్‌తో సైన్ ఇన్ చేస్తారు. 3 నొక్కండి.';

  @override
  String get loginSigningIn => 'సైన్ ఇన్ అవుతోంది.';

  @override
  String get adminLoginScreenName => 'నిర్వాహకుల సైన్ ఇన్';

  @override
  String get adminLoginIntro =>
      'మీ ఫోన్ నంబర్ మరియు పాస్‌వర్డ్ టైప్ చేసి, ప్రతి దాని తర్వాత ఓకే నొక్కండి, తర్వాత 1 నొక్కండి.';

  @override
  String get classNoLongerLive => 'ఆ తరగతి ఇప్పుడు లైవ్‌లో లేదు.';

  @override
  String get classAlertTitle => 'తరగతి ప్రారంభమైంది';

  @override
  String get classAlertBody => 'మీ తరగతి ప్రారంభమైంది. చేరడానికి తెరవండి.';

  @override
  String get classAlertWaitingBody =>
      'మీ తరగతి లైవ్‌లో ఉంది. చేరడానికి తెరవండి.';

  @override
  String get classAlertChannelName => 'తరగతి ప్రారంభమవుతోంది';

  @override
  String get classAlertChannelDescription =>
      'మీ తరగతి ప్రారంభమైనప్పుడు ఒక నిమిషం వరకు మోగుతుంది.';

  @override
  String get classAlertWaitingChannelName => 'తరగతి లైవ్';

  @override
  String get classAlertWaitingChannelDescription =>
      'మీరు చేరగలిగేలా మీ తరగతి లైవ్‌లో ఉన్నంత వరకు ఉంటుంది.';

  @override
  String get classAlertStarted => 'మీ తరగతి ప్రారంభమైంది.';

  @override
  String classAlertSubjectStarted(String subject) {
    return '$subject తరగతి ప్రారంభమైంది.';
  }

  @override
  String get classAlertKeys =>
      'చేరడానికి ఓకే లేదా 1 నొక్కండి. మోగడం ఆపడానికి 0 నొక్కండి.';

  @override
  String get classAlertJoin => 'తరగతిలో చేరండి';

  @override
  String get classAlertNotNow => 'ఇప్పుడు కాదు';

  @override
  String get homeTitle => 'హోమ్';

  @override
  String get homeChecking => 'మీ తరగతి కోసం చూస్తోంది.';

  @override
  String get homeOffline =>
      'ఇంటర్నెట్ లేదు. మీరు మళ్ళీ ఆన్‌లైన్‌కి వచ్చినప్పుడు మీ తరగతి కనిపిస్తుంది.';

  @override
  String get homeSignInAgain => 'దయచేసి మళ్ళీ సైన్ ఇన్ చేయండి.';

  @override
  String get homeStarForAll => 'అన్ని ఎంపికల కోసం స్టార్ నొక్కండి.';

  @override
  String homeBriefLive(String subject) {
    return '$subject తరగతి లైవ్‌లో ఉంది. చేరడానికి 1 నొక్కండి.';
  }

  @override
  String homeBriefNext(String subject, String time) {
    return 'తర్వాతి తరగతి: $timeకు $subject. వేచి ఉన్నప్పుడు మీరు ఇతర ఎంపికలను ఉపయోగించవచ్చు.';
  }

  @override
  String get homeBriefNoClass =>
      'ఇప్పుడు తరగతి లేదు. నేర్చుకోవడం కొనసాగించడానికి 2 నొక్కండి.';

  @override
  String homeJoinClass(String subject) {
    return '$subject తరగతిలో చేరండి';
  }

  @override
  String get homeNoClassNow => 'ఇప్పుడు తరగతి లేదు';

  @override
  String get homeNoClassReason =>
      'మీ ఉపాధ్యాయులు తరగతి ప్రారంభించినప్పుడు అది ఇక్కడ దానంతట అదే కనిపిస్తుంది.';

  @override
  String homeJoinWhenStarts(String subject, String time) {
    return '$timeకు $subject ప్రారంభమైనప్పుడు ఆటోమేటిక్‌గా చేరండి';
  }

  @override
  String get homeCancelAutoJoin => 'ఆటోమేటిక్‌గా చేరడం ఆపండి';

  @override
  String homeAutoJoinArmed(String subject) {
    return 'మీరు ఈ స్క్రీన్‌లోనే ఉంటే, మీ ఉపాధ్యాయులు $subject ప్రారంభించినప్పుడు నేను దాన్ని తెరుస్తాను. మీరు మ్యూట్‌లో చేరతారు. రద్దు చేయడానికి 1 నొక్కండి.';
  }

  @override
  String get homeAutoJoinCancelled => 'ఆటోమేటిక్‌గా చేరడం రద్దు చేయబడింది.';

  @override
  String get homeAutoJoinLeft =>
      'మీరు హోమ్ స్క్రీన్ నుండి వెళ్ళినందున ఆటోమేటిక్‌గా చేరడం ఆగిపోయింది.';

  @override
  String homeAutoJoined(String subject) {
    return '$subject ప్రారంభమైంది. మిమ్మల్ని ఇప్పుడు మ్యూట్‌లో చేరుస్తోంది.';
  }

  @override
  String get homeReturningToClass => 'మీ తరగతికి తిరిగి వెళ్తోంది.';

  @override
  String get homeContinueLearning => 'నేర్చుకోవడం కొనసాగించండి';

  @override
  String get homeNothingToContinue =>
      'కొనసాగించడానికి ఇంకా ఏమీ లేదు. అభ్యాస ప్రయాణాల కోసం 3 నొక్కండి.';

  @override
  String homeContinuing(String title) {
    return '$title కొనసాగుతోంది.';
  }

  @override
  String get homeJourneys => 'అభ్యాస ప్రయాణాలు';

  @override
  String get homeQuizzes => 'క్విజ్‌లు';

  @override
  String get homeMore => 'మరిన్ని';

  @override
  String get homeMoreBrief => 'తక్కువగా ఉపయోగించే ఎంపికలు.';

  @override
  String homeYourClass(String className) {
    return 'మీ తరగతి: $className.';
  }

  @override
  String homeSubjectInClass(String subject, String className) {
    return '$subject, $className';
  }

  @override
  String teacherHomeBriefLive(String subject) {
    return 'మీ $subject తరగతి లైవ్‌లో ఉంది. దానికి తిరిగి వెళ్ళడానికి 1 నొక్కండి.';
  }

  @override
  String teacherHomeBriefReady(String place) {
    return '$place సిద్ధంగా ఉంది. దాన్ని ప్రారంభించడానికి 1 నొక్కండి.';
  }

  @override
  String teacherHomeBriefNext(String place, String time) {
    return 'తదుపరి తరగతి: $timeకి $place.';
  }

  @override
  String get teacherHomeBriefNoClass =>
      'ఇప్పుడు మీ టైమ్‌టేబుల్‌లో తరగతి ఏదీ లేదు.';

  @override
  String teacherHomeReturn(String subject) {
    return '$subject తరగతికి తిరిగి వెళ్ళండి';
  }

  @override
  String teacherHomeStart(String place) {
    return '$place ప్రారంభించండి';
  }

  @override
  String teacherHomeNext(String place, String time) {
    return 'తదుపరి: $timeకి $place';
  }

  @override
  String teacherHomeOpensAt(String time) {
    return 'మీరు దీన్ని $time నుండి ప్రారంభించవచ్చు.';
  }

  @override
  String get teacherHomeNoClassReason =>
      'ఇప్పుడు ఏదీ షెడ్యూల్ చేయబడలేదు. అయినా బోధించడానికి, మరిన్ని కోసం 5 నొక్కండి, తర్వాత 3.';

  @override
  String get teacherHomeStarting => 'మీ తరగతి ప్రారంభిస్తోంది.';

  @override
  String teacherHomeStarted(String subject) {
    return '$subject తరగతి ప్రారంభమైంది. మీ విద్యార్థులను పిలుస్తున్నాము.';
  }

  @override
  String get teacherHomeUnscheduled => 'షెడ్యూల్ చేయని తరగతి ప్రారంభించండి';

  @override
  String get teacherHomeUnscheduledTitle =>
      'మీరు ఇప్పుడు ఏ తరగతికి బోధించాలనుకుంటున్నారు?';

  @override
  String get teacherHomeAlreadyLive =>
      'మీకు ఇప్పటికే ఒక లైవ్ తరగతి ఉంది. దానికి తిరిగి వెళ్ళడానికి హోమ్‌లో 1 నొక్కండి.';

  @override
  String get teacherHomeChangeWorkspace =>
      'పాఠాల కోసం తరగతి మరియు సబ్జెక్టు మార్చండి';

  @override
  String get teacherHomeOneWorkspace =>
      'మీరు ఒకే తరగతి మరియు సబ్జెక్టుకు బోధిస్తున్నారు.';

  @override
  String teacherHomeContentFor(String place) {
    return 'పాఠాలు, క్విజ్‌లు మరియు ప్లేలిస్ట్‌లు $place కోసం.';
  }

  @override
  String teacherHomeLaterItem(String place, String time) {
    return 'తర్వాత: $timeకి $place.';
  }

  @override
  String get keyClassListWhoJoined =>
      'తరగతి జాబితా: ఎవరు ఉన్నారు, ఎవరు వెళ్ళిపోయారు, ఎవరు చేరలేదు';

  @override
  String get keyMuteAllStudents => 'విద్యార్థులందరినీ మ్యూట్ చేయండి';

  @override
  String get keyTeacherToolsAddTimeOrEnd =>
      'ఉపాధ్యాయుల సాధనాలు: సమయం పెంచండి లేదా అందరికీ తరగతిని ముగించండి';

  @override
  String get sessionMicAskOnce =>
      'మీరు మ్యూట్‌లో చేరుతారు. మీకు కావలసినప్పుడు మాట్లాడగలిగేలా, SEEDS ఇప్పుడు మైక్రోఫోన్ ఉపయోగించడానికి అనుమతి అడుగుతుంది.';

  @override
  String get sessionMicAskAgain => 'మాట్లాడటానికి, మైక్రోఫోన్‌ను అనుమతించండి.';

  @override
  String get sessionMicStillOff =>
      'మైక్రోఫోన్ ఇంకా ఆఫ్‌లో ఉంది. మీరు వింటూ ఉండవచ్చు.';

  @override
  String get sessionMicSettingsTitle => 'మైక్రోఫోన్ బ్లాక్ చేయబడింది';

  @override
  String get sessionMicSettingsMessage =>
      'Android మళ్ళీ అడగదు. మాట్లాడటానికి, సెట్టింగ్‌లు తెరిచి, అనుమతులు ఎంచుకుని, మైక్రోఫోన్‌ను అనుమతించండి. మీరు వింటూ ఉండవచ్చు.';

  @override
  String get sessionMicSettingsOpen => 'సెట్టింగ్‌లు తెరవండి';

  @override
  String get sessionMicSettingsCancel => 'వింటూ ఉండండి';

  @override
  String get sessionMuteAllButton => '2: విద్యార్థులందరినీ మ్యూట్ చేయండి';

  @override
  String get sessionMuteAllLabel => 'విద్యార్థులందరినీ మ్యూట్ చేయండి';

  @override
  String get sessionMuteAllWaiting =>
      'ఇంకా అందరినీ మ్యూట్ చేస్తోంది. దయచేసి వేచి ఉండండి.';

  @override
  String sessionMuteAllDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count మంది విద్యార్థులు మ్యూట్ చేయబడ్డారు.',
      one: '1 విద్యార్థి మ్యూట్ చేయబడ్డారు.',
    );
    return '$_temp0';
  }

  @override
  String get sessionMuteAllNone =>
      'ప్రతి విద్యార్థి ఇప్పటికే మ్యూట్‌లో ఉన్నారు.';

  @override
  String sessionMuteAllNotConfirmed(String reason) {
    return 'అందరినీ మ్యూట్ చేయడం నిర్ధారించబడలేదు. $reason మళ్ళీ ప్రయత్నించడానికి 2 నొక్కండి.';
  }

  @override
  String get sessionClassListButton => '3: తరగతి జాబితా';

  @override
  String sessionClassListLabel(String people) {
    return 'తరగతి జాబితా. $people';
  }

  @override
  String get sessionClassListTitle => 'తరగతి జాబితా';

  @override
  String sessionRosterCounts(int here, int left, int notJoined) {
    return '$here మంది ఇక్కడ ఉన్నారు, $left మంది వెళ్ళిపోయారు, $notJoined మంది ఇంకా చేరలేదు.';
  }

  @override
  String sessionHereNow(int count) {
    return 'ఇప్పుడు ఇక్కడ ఉన్నవారు: $count';
  }

  @override
  String sessionLeftClass(int count) {
    return 'చేరి, తర్వాత వెళ్ళిపోయినవారు: $count';
  }

  @override
  String sessionNotJoined(int count) {
    return 'ఇంకా చేరనివారు: $count';
  }

  @override
  String get sessionHereNowTitle => 'ఇప్పుడు ఇక్కడ ఉన్నవారు';

  @override
  String get sessionLeftClassTitle => 'చేరి, తర్వాత వెళ్ళిపోయినవారు';

  @override
  String get sessionNotJoinedTitle => 'ఇంకా చేరనివారు';

  @override
  String sessionRemovedName(String name) {
    return '$name, మీరు తీసివేశారు';
  }

  @override
  String get sessionNobody => 'ఎవరూ లేరు.';

  @override
  String get sessionRemindNotJoined => 'చేరని విద్యార్థులకు రింగ్ చేయండి';

  @override
  String get sessionEveryoneJoined => 'అందరూ చేరారు.';

  @override
  String sessionReminderSent(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count మంది విద్యార్థులకు రింగ్ చేస్తోంది.',
      one: '1 విద్యార్థికి రింగ్ చేస్తోంది.',
      zero: 'ఇప్పుడు రింగ్ చేయడానికి ఎవరూ లేరు.',
    );
    return '$_temp0';
  }

  @override
  String sessionReminderSentSomeWaiting(int queued, int cooling) {
    return '$queued మందికి రింగ్ చేస్తోంది. $cooling మందికి గత 5 నిమిషాల్లో రింగ్ చేశారు, వారికి ఇప్పుడే మళ్ళీ రింగ్ చేయదు.';
  }

  @override
  String get sessionRosterUnavailable =>
      'తరగతి జాబితాను చదవలేకపోయింది. మళ్ళీ ప్రయత్నించండి.';

  @override
  String get sessionAddTime => '15 నిమిషాలు జోడించండి';

  @override
  String get sessionCannotAddTime =>
      'తర్వాతి తరగతికి ముందు ఇంకా సమయం జోడించలేరు.';

  @override
  String sessionEndsBy(String clock) {
    return 'తరగతి $clockకల్లా ముగుస్తుంది.';
  }

  @override
  String sessionExtendedUntil(String clock) {
    return 'పూర్తయింది. తరగతి ఇప్పుడు $clockకల్లా ముగుస్తుంది.';
  }

  @override
  String sessionEndingSoonTeacher(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: 'తరగతి $minutes నిమిషాల్లో ఆటోమేటిక్‌గా ముగుస్తుంది.',
      one: 'తరగతి 1 నిమిషంలో ఆటోమేటిక్‌గా ముగుస్తుంది.',
    );
    return '$_temp0';
  }

  @override
  String sessionEndingSoonTeacherExtend(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other:
          'తరగతి $minutes నిమిషాల్లో ఆటోమేటిక్‌గా ముగుస్తుంది. 15 నిమిషాలు జోడించడానికి, 5 తర్వాత 1 నొక్కండి.',
      one:
          'తరగతి 1 నిమిషంలో ఆటోమేటిక్‌గా ముగుస్తుంది. 15 నిమిషాలు జోడించడానికి, 5 తర్వాత 1 నొక్కండి.',
    );
    return '$_temp0';
  }

  @override
  String sessionEndingSoonStudent(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: 'తరగతి $minutes నిమిషాల్లో ముగుస్తుంది.',
      one: 'తరగతి 1 నిమిషంలో ముగుస్తుంది.',
    );
    return '$_temp0';
  }

  @override
  String get sessionLessonReady =>
      'ఈ రోజు పాఠం సిద్ధంగా ఉంది. తరగతికి ప్లే చేయడానికి 4, తర్వాత 3 నొక్కండి.';

  @override
  String get sessionLessonNextReady =>
      'ఈ రోజు పాఠంలోని తర్వాతి భాగం సిద్ధంగా ఉంది. ప్లే చేయడానికి 7 నొక్కండి.';

  @override
  String get sessionJoinedStudentBrief =>
      'మీరు తరగతిలో ఉన్నారు, మ్యూట్‌లో ఉన్నారు. మాట్లాడటానికి 1, చేయి ఎత్తడానికి 2 నొక్కండి.';

  @override
  String get sessionJoinedTeacherBrief =>
      'మీ తరగతి లైవ్‌లో ఉంది. మీరు మ్యూట్‌లో ఉన్నారు. మాట్లాడటానికి 1, విద్యార్థులందరినీ మ్యూట్ చేయడానికి 2 నొక్కండి.';

  @override
  String get sessionStarForKeys => 'అన్ని కీల కోసం స్టార్ నొక్కండి.';

  @override
  String settingsAutoDownload(String state) {
    return 'Wi-Fi లో కొత్త ప్రయాణాలను ఆఫ్‌లైన్ వాడకం కోసం సిద్ధం చేయండి: $state';
  }

  @override
  String get settingsAutoDownloadOn => 'ప్రయాణాలు Wi-Fi లో సిద్ధం చేయబడతాయి.';

  @override
  String get settingsAutoDownloadOff =>
      'ప్రయాణాలు ఆటోమేటిక్‌గా సిద్ధం చేయబడవు.';

  @override
  String get adminSetupTeacherNeedsPair =>
      'ఉపాధ్యాయులకు కనీసం ఒక తరగతి మరియు సబ్జెక్టును జోడించండి.';

  @override
  String get adminSetupTeacherHasNoPairs =>
      'ఇంకా ఏ ఉపాధ్యాయులకూ తరగతి మరియు సబ్జెక్టు లేదు. ముందుగా వ్యక్తులు విభాగంలో ఒక ఉపాధ్యాయులకు వాటిని జోడించండి.';

  @override
  String get adminSetupDaysField => 'రోజులు';

  @override
  String get adminSetupChooseDays => 'కనీసం ఒక రోజును ఎంచుకోండి.';

  @override
  String adminSetupLessonsAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count పాఠాలు జోడించబడ్డాయి, ప్రతి రోజుకు ఒకటి.',
      one: 'పాఠం జోడించబడింది.',
    );
    return '$_temp0';
  }

  @override
  String get adminSetupArrangeBy => 'దీని ప్రకారం అమర్చండి';

  @override
  String get adminSetupArrangeDay => 'రోజు';

  @override
  String get adminSetupArrangeTeacher => 'ఉపాధ్యాయులు';

  @override
  String get adminSetupArrangeClass => 'తరగతి';

  @override
  String adminSetupGroupHeading(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count పాఠాలు',
      one: '1 పాఠం',
    );
    return '$name · $_temp0';
  }

  @override
  String adminSetupEntryDayTitle(String day, String title) {
    return '$day, $title';
  }

  @override
  String get adminSetupTimetableSearch => 'పాఠాలను వెతకండి';

  @override
  String get adminSetupNoMatchingLessons => 'సరిపోయే పాఠాలు లేవు.';

  @override
  String sessionMoreButton(String key) {
    return '$key: మరిన్ని';
  }

  @override
  String get sessionMoreLabel => 'మరిన్ని ఎంపికలు';

  @override
  String get sessionMoreTitle => 'మరిన్ని ఎంపికలు';

  @override
  String get sessionMoreClassroomCheck => 'తరగతి తనిఖీ';

  @override
  String get sessionMoreWhatIsPlaying => 'ఏమి ప్లే అవుతోంది';

  @override
  String get sessionMoreWhoIsHere => 'తరగతిలో ఎవరు ఉన్నారు';

  @override
  String get sessionKeyClassList => 'తరగతి జాబితా';

  @override
  String get sessionKeyLessonRecording => 'పాఠం రికార్డింగ్';

  @override
  String get sessionKeyAnswerQuestion => 'ప్రశ్నకు సమాధానం ఇవ్వండి';

  @override
  String get sessionKeyMore => 'మరిన్ని ఎంపికలు';

  @override
  String get sessionKeyLeave => 'తరగతి నుండి వెళ్ళండి';

  @override
  String get sessionEndClassButton => '6: అందరికీ తరగతిని ముగించండి';

  @override
  String get sessionEndClassLabel =>
      'అందరికీ తరగతిని ముగించండి. నిర్ధారించమని అడుగుతుంది';

  @override
  String sessionActivityQuizItem(String title, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ప్రశ్నలు',
      one: '1 ప్రశ్న',
    );
    return 'క్విజ్: $title, $_temp0';
  }

  @override
  String sessionActivityJourneyItem(String title) {
    return 'ప్రయాణం: $title';
  }

  @override
  String sessionActivityStopItem(String title) {
    return '$title అందించడం ఆపండి';
  }

  @override
  String sessionActivityStartedTeacher(String title) {
    return '$title తరగతి కోసం తెరిచి ఉంది. దాని స్థితి కోసం 7 నొక్కండి.';
  }

  @override
  String sessionActivityStoppedTeacher(String title) {
    return '$title ఇకపై తరగతిలో అందించబడదు. విద్యార్థులు దాన్ని ఇప్పటికీ హోమ్‌లో కనుగొనవచ్చు.';
  }

  @override
  String sessionActivityQuizStarted(String title) {
    return 'మీ ఉపాధ్యాయులు ఒక క్విజ్ ఇచ్చారు: $title. మొదలుపెట్టడానికి 5 నొక్కండి.';
  }

  @override
  String sessionActivityJourneyStarted(String title) {
    return 'మీ ఉపాధ్యాయులు ఒక అభ్యాస ప్రయాణం ఇచ్చారు: $title. మొదలుపెట్టడానికి 5 నొక్కండి.';
  }

  @override
  String sessionActivityStoppedStudent(String title) {
    return '$title తరగతిలో మూసివేయబడింది. మీరు దాన్ని ఇప్పటికీ హోమ్‌లో కనుగొనవచ్చు.';
  }

  @override
  String sessionActivityStartQuizLabel(String title) {
    return '$title క్విజ్ ప్రారంభించండి';
  }

  @override
  String sessionActivityStartJourneyLabel(String title) {
    return '$title ప్రయాణం ప్రారంభించండి';
  }

  @override
  String sessionActivityStateStudent(String title) {
    return '$title తెరిచి ఉంది.';
  }

  @override
  String sessionActivityStateTeacher(String title) {
    return '$title తరగతి కోసం తెరిచి ఉంది.';
  }

  @override
  String sessionActivityOpening(String title) {
    return '$title తెరుస్తోంది.';
  }

  @override
  String sessionActivityCouldNotOpen(String title) {
    return '$title తెరవలేకపోయింది. మీ కనెక్షన్ తనిఖీ చేసి మళ్ళీ ప్రయత్నించండి.';
  }

  @override
  String get sessionBackInClass => 'మళ్ళీ తరగతిలో ఉన్నారు.';

  @override
  String sessionActivityProgress(String title, int started, int finished) {
    return '$title: $started మంది ప్రారంభించారు, $finished మంది పూర్తి చేశారు.';
  }

  @override
  String get sessionWhatIsPlayingButton => '3: ఏమి ప్లే అవుతోంది';

  @override
  String get sessionKeyEndClass => 'అందరికీ తరగతిని ముగించండి';

  @override
  String get sessionKeyWhatIsPlaying => 'ఏమి ప్లే అవుతోంది';

  @override
  String get sessionQuizButton => '6: క్విజ్';

  @override
  String get sessionJourneyButton => '7: ప్రయాణం';

  @override
  String get sessionQuizLabel => 'తరగతి కోసం ఒక క్విజ్ ప్రారంభించండి';

  @override
  String get sessionJourneyLabel => 'తరగతి కోసం ఒక ప్రయాణం ప్రారంభించండి';

  @override
  String sessionOpenLabel(String title) {
    return '$title తెరిచి ఉంది. ఎవరు మిగిలి ఉన్నారో వినండి, వారికి గుర్తు చేయండి, లేదా దాన్ని ఆపండి';
  }

  @override
  String get sessionKeyQuiz => 'తరగతి కోసం క్విజ్';

  @override
  String get sessionKeyJourney => 'తరగతి కోసం ప్రయాణం';

  @override
  String sessionStartQuizButton(String title) {
    return '5: క్విజ్ ప్రారంభించండి: $title';
  }

  @override
  String sessionStartJourneyButton(String title) {
    return '5: ప్రయాణం ప్రారంభించండి: $title';
  }

  @override
  String get sessionPickQuizTitle => 'తరగతి కోసం ఒక క్విజ్ ప్రారంభించండి';

  @override
  String get sessionPickJourneyTitle => 'తరగతి కోసం ఒక ప్రయాణం ప్రారంభించండి';

  @override
  String get sessionNoQuizToStart =>
      'ఈ తరగతి మరియు సబ్జెక్టు కోసం ప్రచురించబడిన క్విజ్ ఏదీ తెరిచి లేదు. ముందుగా హోమ్‌లోని క్విజ్‌లు నుండి ఒకటి ప్రచురించండి.';

  @override
  String get sessionNoJourneyToStart =>
      'ఈ తరగతి మరియు సబ్జెక్టు కోసం ప్రచురించబడిన ప్రయాణం లేదు. ముందుగా హోమ్‌లోని ప్రయాణాలు నుండి ఒకటి ప్రచురించండి.';

  @override
  String sessionFinishedOf(int finished, int enrolled) {
    return '$enrolled మందిలో $finished మంది పూర్తి చేశారు.';
  }

  @override
  String sessionLeftInClass(int count) {
    return 'తరగతిలో ఉన్నవారు, పూర్తి చేయనివారు ($count)';
  }

  @override
  String sessionLeftWholeClass(int count) {
    return 'మొత్తం తరగతి, పూర్తి చేయనివారు ($count)';
  }

  @override
  String get sessionLeftInClassTitle => 'తరగతిలో ఉన్నవారు, పూర్తి చేయనివారు';

  @override
  String get sessionLeftWholeClassTitle => 'మొత్తం తరగతి, పూర్తి చేయనివారు';

  @override
  String get sessionRemindLeft =>
      'తరగతిలో ఉండి పూర్తి చేయనివారికి గుర్తు చేయండి';

  @override
  String get sessionStartDifferentQuiz => 'వేరే క్విజ్ ప్రారంభించండి';

  @override
  String get sessionStartDifferentJourney => 'వేరే ప్రయాణం ప్రారంభించండి';

  @override
  String sessionLeftNotStarted(String name) {
    return '$name, ప్రారంభించలేదు';
  }

  @override
  String sessionLeftStarted(String name) {
    return '$name, ప్రారంభించారు, పూర్తి చేయలేదు';
  }

  @override
  String get sessionLeftHere => 'తరగతిలో ఉన్నారు';

  @override
  String get sessionLeftAway => 'తరగతిలో లేరు';

  @override
  String get sessionLeftNobodyInClass => 'తరగతిలో ఉన్న అందరూ పూర్తి చేశారు.';

  @override
  String get sessionLeftNobody => 'తరగతిలోని అందరూ పూర్తి చేశారు.';

  @override
  String sessionRemindedLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count మంది విద్యార్థులకు గుర్తు చేశారు.',
      one: '1 విద్యార్థికి గుర్తు చేశారు.',
      zero: 'తరగతిలో ఎవరికీ గుర్తు చేయాల్సిన అవసరం లేదు.',
    );
    return '$_temp0';
  }

  @override
  String sessionActivityReminderQuiz(String title) {
    return '$title క్విజ్ చేయమని మీ ఉపాధ్యాయులు గుర్తు చేస్తున్నారు. మొదలుపెట్టడానికి 5 నొక్కండి.';
  }

  @override
  String sessionActivityReminderJourney(String title) {
    return '$title అభ్యాస ప్రయాణం చేయమని మీ ఉపాధ్యాయులు గుర్తు చేస్తున్నారు. మొదలుపెట్టడానికి 5 నొక్కండి.';
  }

  @override
  String get sessionKeyStartActivity => 'క్విజ్ లేదా ప్రయాణం ప్రారంభించండి';

  @override
  String get startupSettingsKey2 => '2. సెట్టింగ్‌లు';

  @override
  String get libraryPauseSessionKey3 =>
      'మొత్తం సెషన్ కోసం ఆడియోను పాజ్ చేయండి, కీ 3';

  @override
  String get authSaveNewPasswordKey1 => '1: కొత్త పాస్‌వర్డ్ సేవ్ చేయండి';

  @override
  String get quizSaveSettingsKey1 => '1: సెట్టింగ్‌లు సేవ్ చేయండి';

  @override
  String get quizSaveQuestionKey1 => '1: ప్రశ్నను సేవ్ చేయండి';

  @override
  String get quizContinueToQuestionsKey1 => '1: ప్రశ్నలకు కొనసాగండి';

  @override
  String get adminAuthorSection => 'క్విజ్‌లు మరియు ప్రయాణాలు';

  @override
  String get adminAuthorNote =>
      'ఒక ఉపాధ్యాయుల కోసం క్విజ్‌లు మరియు అభ్యాస ప్రయాణాలను తయారు చేసి ప్రచురించండి. మీరు తయారు చేసే ప్రతిదీ ఆ ఉపాధ్యాయులకే చెందుతుంది, వారి ప్రశ్నల బ్యాంక్ మరియు వారి స్వంత రికార్డింగ్‌లను మాత్రమే ఉపయోగిస్తుంది, మరియు దాని గురించి ఉపాధ్యాయులకు వారి హోమ్‌లో తెలియజేయబడుతుంది.';

  @override
  String get adminAuthorTeacher => 'ఉపాధ్యాయులు';

  @override
  String get adminAuthorWorkspace => 'తరగతి మరియు సబ్జెక్టు';

  @override
  String adminAuthorWorkspaceName(String className, String subjectName) {
    return '$className, $subjectName';
  }

  @override
  String get adminAuthorNoTeachers =>
      'ఇంకా ఏ ఉపాధ్యాయులకూ తరగతి మరియు సబ్జెక్టు లేదు. ముందుగా ఖాతాలు విభాగంలో ఒకటి కేటాయించండి.';

  @override
  String get adminAuthorKind => 'చూపించు';

  @override
  String get adminAuthorKindQuizzes => 'క్విజ్‌లు';

  @override
  String get adminAuthorKindJourneys => 'ప్రయాణాలు';

  @override
  String get adminAuthorNewQuiz => 'కొత్త క్విజ్';

  @override
  String get adminAuthorNewJourney => 'కొత్త ప్రయాణం';

  @override
  String adminAuthorNewQuizFor(String teacher) {
    return '$teacher కోసం కొత్త క్విజ్';
  }

  @override
  String adminAuthorNewJourneyFor(String teacher) {
    return '$teacher కోసం కొత్త ప్రయాణం';
  }

  @override
  String get adminAuthorNoQuizzes =>
      'ఈ తరగతి మరియు సబ్జెక్టు కోసం ఈ ఉపాధ్యాయులకు క్విజ్‌లు లేవు.';

  @override
  String get adminAuthorNoJourneys =>
      'ఈ తరగతి మరియు సబ్జెక్టు కోసం ఈ ఉపాధ్యాయులకు ప్రయాణాలు లేవు.';

  @override
  String get adminAuthorStatusDraft => 'డ్రాఫ్ట్';

  @override
  String get adminAuthorStatusPublished => 'ప్రచురించబడింది';

  @override
  String get adminAuthorStatusScheduled =>
      'ప్రచురించబడింది, తర్వాత తెరుచుకుంటుంది';

  @override
  String get adminAuthorStatusClosed => 'మూసివేయబడింది';

  @override
  String get adminAuthorStatusArchived => 'ఆర్కైవ్ చేయబడింది';

  @override
  String adminAuthorStatusChanged(String status) {
    return '$status, ప్రచురించని మార్పులతో';
  }

  @override
  String adminAuthorQuestionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ప్రశ్నలు',
      one: '1 ప్రశ్న',
    );
    return '$_temp0';
  }

  @override
  String adminAuthorStepCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count దశలు',
      one: '1 దశ',
    );
    return '$_temp0';
  }

  @override
  String get adminAuthorMode => 'క్విజ్ రకం';

  @override
  String get adminAuthorModeGraded => 'మార్కులతో';

  @override
  String get adminAuthorModePractice => 'అభ్యాసం';

  @override
  String get adminAuthorEdit => 'మార్చండి';

  @override
  String adminAuthorEditNamed(String title) {
    return '$title ను సవరించండి';
  }

  @override
  String get adminAuthorPublish => 'ప్రచురించండి';

  @override
  String adminAuthorPublishNamed(String title) {
    return '$title ను ప్రచురించండి';
  }

  @override
  String get adminAuthorClose => 'క్విజ్ ముగించండి';

  @override
  String adminAuthorCloseNamed(String title) {
    return '$title ను ముగించండి';
  }

  @override
  String get adminAuthorArchive => 'ఆర్కైవ్ చేయండి';

  @override
  String adminAuthorArchiveNamed(String title) {
    return '$title ను ఆర్కైవ్ చేయండి';
  }

  @override
  String get adminAuthorPublishQuizTitle => 'ఈ క్విజ్‌ను ప్రచురించాలా?';

  @override
  String adminAuthorPublishQuizMessage(String title, String teacher) {
    return '$title తరగతికి $teacher గారి క్విజ్‌గా తెరవబడుతుంది, విద్యార్థులకు నోటిఫికేషన్ వెళ్తుంది.';
  }

  @override
  String get adminAuthorPublishJourneyTitle =>
      'ఈ అభ్యాస ప్రయాణాన్ని ప్రచురించాలా?';

  @override
  String adminAuthorPublishJourneyMessage(String title, String teacher) {
    return '$title తరగతికి $teacher గారి అభ్యాస ప్రయాణంగా అందుబాటులో ఉంటుంది, విద్యార్థులకు నోటిఫికేషన్ వెళ్తుంది.';
  }

  @override
  String get adminAuthorCloseQuizTitle => 'ఈ క్విజ్‌ను ముగించాలా?';

  @override
  String adminAuthorCloseQuizMessage(String title) {
    return 'విద్యార్థులు ఇకపై $title కు జవాబు ఇవ్వలేరు. పూర్తి కాని ప్రయత్నాలు ఉన్నవి ఉన్నట్లుగా సమర్పించబడతాయి.';
  }

  @override
  String get adminAuthorArchiveTitle => 'ఈ అభ్యాస ప్రయాణాన్ని ఆర్కైవ్ చేయాలా?';

  @override
  String adminAuthorArchiveMessage(String title) {
    return 'విద్యార్థులకు ఇకపై $title కనిపించదు.';
  }

  @override
  String adminAuthorPublished(String title) {
    return '$title ప్రచురించబడింది.';
  }

  @override
  String adminAuthorClosed(String title) {
    return '$title ముగించబడింది.';
  }

  @override
  String adminAuthorArchived(String title) {
    return '$title ఆర్కైవ్ చేయబడింది.';
  }

  @override
  String adminAuthorCreated(String title) {
    return '$title డ్రాఫ్ట్‌గా సృష్టించబడింది.';
  }

  @override
  String get adminAuthorSaved => 'అభ్యాస ప్రయాణం సేవ్ చేయబడింది.';

  @override
  String adminAuthorNotReady(String problems) {
    return 'ఈ క్విజ్ ప్రచురించడానికి సిద్ధంగా లేదు. $problems';
  }

  @override
  String get adminAuthorTitle => 'శీర్షిక';

  @override
  String get adminAuthorDescription => 'వివరణ (ఐచ్ఛికం)';

  @override
  String get adminAuthorQuizSettings => 'క్విజ్ సెట్టింగ్‌లు';

  @override
  String adminAuthorEditQuiz(String title) {
    return 'క్విజ్ సవరించండి: $title';
  }

  @override
  String adminAuthorEditJourney(String title) {
    return 'అభ్యాస ప్రయాణం సవరించండి: $title';
  }

  @override
  String get adminAuthorQuestions => 'ప్రశ్నలు';

  @override
  String get adminAuthorNoQuestions => 'ఇంకా ప్రశ్నలు లేవు.';

  @override
  String adminAuthorQuestionLine(int number, String text) {
    return '$number. $text';
  }

  @override
  String adminAuthorCorrectAnswer(String answer) {
    return 'సరైన జవాబు: $answer';
  }

  @override
  String get adminAuthorRemove => 'తీసివేయండి';

  @override
  String adminAuthorRemoveNamed(String item) {
    return '$item ను తీసివేయండి';
  }

  @override
  String get adminAuthorAddNewQuestion => 'కొత్త ప్రశ్న టైప్ చేయండి';

  @override
  String get adminAuthorAddBankQuestion => 'ప్రశ్నల బ్యాంక్ నుండి జోడించండి';

  @override
  String get adminAuthorQuestionText => 'ప్రశ్న';

  @override
  String adminAuthorOption(int number) {
    return 'ఎంపిక $number';
  }

  @override
  String adminAuthorOptionalOption(int number) {
    return 'ఎంపిక $number (ఐచ్ఛికం)';
  }

  @override
  String get adminAuthorCorrectOption => 'సరైన జవాబు';

  @override
  String get adminAuthorCorrectIsBlank =>
      'సరైన జవాబు ఖాళీగా ఉంది. దాన్ని నింపండి లేదా వేరే ఎంపికను ఎంచుకోండి.';

  @override
  String get adminAuthorExplanation => 'వివరణ (ఐచ్ఛికం)';

  @override
  String get adminAuthorSaveToBank =>
      'ఉపాధ్యాయుల ప్రశ్నల బ్యాంక్‌లో కూడా సేవ్ చేయండి';

  @override
  String get adminAuthorNeedFourOptions => 'నాలుగు ఎంపికలనూ నింపండి.';

  @override
  String get adminAuthorNeedTwoOptions => 'కనీసం రెండు ఎంపికలు నింపండి.';

  @override
  String get adminAuthorDuplicateOptions => 'ప్రతి ఎంపిక వేరుగా ఉండాలి.';

  @override
  String adminAuthorRequired(String field) {
    return '$field తప్పనిసరి.';
  }

  @override
  String get adminAuthorAdd => 'జోడించండి';

  @override
  String adminAuthorAddNamed(String item) {
    return '$item ను జోడించండి';
  }

  @override
  String get adminAuthorBankTitle => 'ఉపాధ్యాయుల ప్రశ్నల బ్యాంక్';

  @override
  String get adminAuthorBankEmpty =>
      'ఈ తరగతి మరియు సబ్జెక్టుకు ఈ ఉపాధ్యాయులు సేవ్ చేసిన ప్రశ్నలు లేవు.';

  @override
  String get adminAuthorDone => 'పూర్తయింది';

  @override
  String get adminAuthorGraded => 'మార్కులతో: ప్రశ్నలకు మార్కులు ఇవ్వండి';

  @override
  String get adminAuthorRetries => 'తప్పు జవాబు తర్వాత మళ్లీ ప్రయత్నాలు';

  @override
  String get adminAuthorSteps => 'దశలు';

  @override
  String get adminAuthorNoSteps => 'ఇంకా దశలు లేవు.';

  @override
  String adminAuthorStepRecording(String title) {
    return 'రికార్డింగ్: $title';
  }

  @override
  String adminAuthorStepNarration(String text) {
    return 'వివరణ పాఠం: $text';
  }

  @override
  String adminAuthorStepQuestion(String text) {
    return 'ప్రశ్న: $text';
  }

  @override
  String adminAuthorStepPoll(String text) {
    return 'పోల్: $text';
  }

  @override
  String get adminAuthorMoveUp => 'పైకి జరపండి';

  @override
  String adminAuthorMoveUpNamed(String item) {
    return '$item ను పైకి జరపండి';
  }

  @override
  String get adminAuthorMoveDown => 'కిందికి జరపండి';

  @override
  String adminAuthorMoveDownNamed(String item) {
    return '$item ను కిందికి జరపండి';
  }

  @override
  String get adminAuthorAddRecording => 'రికార్డింగ్ జోడించండి';

  @override
  String get adminAuthorAddNarration => 'వివరణ పాఠం జోడించండి';

  @override
  String get adminAuthorAddQuestion => 'ప్రశ్న జోడించండి';

  @override
  String get adminAuthorAddPoll => 'పోల్ జోడించండి';

  @override
  String get adminAuthorRecordingsTitle => 'ఉపాధ్యాయుల రికార్డింగ్‌లు';

  @override
  String get adminAuthorRecordingsNote =>
      'ఈ తరగతి మరియు సబ్జెక్టుకు ఈ ఉపాధ్యాయులు అప్‌లోడ్ చేసిన రికార్డింగ్‌లను మాత్రమే ఉపయోగించవచ్చు.';

  @override
  String get adminAuthorNoRecordings =>
      'ఈ తరగతి మరియు సబ్జెక్టుకు ఈ ఉపాధ్యాయులు ఏ రికార్డింగ్ అప్‌లోడ్ చేయలేదు.';

  @override
  String get adminAuthorNarrationText => 'వివరణ పాఠం టెక్స్ట్';

  @override
  String get adminAuthorPollText => 'పోల్ ప్రశ్న';

  @override
  String get adminAuthorSaveJourney => 'అభ్యాస ప్రయాణం సేవ్ చేయండి';

  @override
  String sessionPeopleJoined(String names) {
    return '$names చేరారు.';
  }

  @override
  String sessionPeopleLeft(String names) {
    return '$names వెళ్లిపోయారు.';
  }

  @override
  String sessionNamesAnd(String first, String last) {
    return '$first మరియు $last';
  }

  @override
  String sessionHereOf(int here, int total) {
    return '$total లో $here మంది ఉన్నారు.';
  }

  @override
  String sessionHereCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count మంది విద్యార్థులు ఉన్నారు.',
      one: '1 విద్యార్థి ఉన్నారు.',
      zero: 'విద్యార్థులు ఎవరూ లేరు.',
    );
    return '$_temp0';
  }

  @override
  String sessionStartSummary(int here, int total) {
    return '$total మంది విద్యార్థులలో $here మంది ఉన్నారు.';
  }

  @override
  String uiFocusedField(String field) {
    return 'మీరు $fieldలో ఉన్నారు.';
  }

  @override
  String get sessionStartButton => '4: ప్రారంభించండి';

  @override
  String get sessionStartLabel =>
      'తరగతి కోసం క్విజ్, అభ్యాస ప్రయాణం లేదా రికార్డింగ్ ప్రారంభించండి';

  @override
  String get sessionStartTitle => 'తరగతి కోసం ప్రారంభించండి';

  @override
  String get sessionStartQuiz => 'క్విజ్';

  @override
  String get sessionStartJourney => 'అభ్యాస ప్రయాణం';

  @override
  String get sessionStartRecording => 'రికార్డింగ్';

  @override
  String sessionStatusKeyButton(String title) {
    return '7: $title స్థితి';
  }

  @override
  String sessionStatusKeyLabel(String title) {
    return '$title స్థితి';
  }

  @override
  String get sessionKeyStart =>
      'క్విజ్, అభ్యాస ప్రయాణం లేదా రికార్డింగ్ ప్రారంభించండి';

  @override
  String get sessionKeyStatus => 'జరుగుతున్న దాని స్థితి';

  @override
  String sessionActivityCounts(int present, int started, int finished) {
    return 'తరగతిలో $present మంది విద్యార్థులు ఉన్నారు. $started మంది ప్రయత్నించారు, $finished మంది పూర్తి చేశారు.';
  }

  @override
  String get sessionNowPlayingTitle => 'రికార్డింగ్';

  @override
  String get noticeActorAdmin => 'మీ నిర్వాహకులు';

  @override
  String noticeQuizCreated(String actor, String title) {
    return '$actor $title క్విజ్ జోడించారు.';
  }

  @override
  String noticeQuizPublished(String actor, String title) {
    return '$actor $title క్విజ్ ప్రచురించారు.';
  }

  @override
  String noticeQuizClosed(String actor, String title) {
    return '$actor $title క్విజ్ మూసివేశారు.';
  }

  @override
  String noticeJourneyCreated(String actor, String title) {
    return '$actor $title అభ్యాస ప్రయాణం జోడించారు.';
  }

  @override
  String noticeJourneyPublished(String actor, String title) {
    return '$actor $title అభ్యాస ప్రయాణం ప్రచురించారు.';
  }

  @override
  String noticeJourneyArchived(String actor, String title) {
    return '$actor $title అభ్యాస ప్రయాణాన్ని ఆర్కైవ్ చేశారు.';
  }

  @override
  String noticePlaylistPublished(String actor, String title) {
    return '$actor $title ప్లేలిస్ట్ ప్రచురించారు.';
  }

  @override
  String noticeLessonCreated(String actor, String title) {
    return '$actor $title పాఠం జోడించారు.';
  }

  @override
  String noticeLessonUpdated(String actor, String title) {
    return '$actor $title పాఠం మార్చారు.';
  }

  @override
  String noticeLessonRemoved(String actor, String title) {
    return '$actor $title పాఠం తీసివేశారు.';
  }

  @override
  String noticeLessonRemovedOn(String actor, String title, String date) {
    return '$actor $date న $title పాఠం నుండి మిమ్మల్ని తీసివేశారు.';
  }

  @override
  String noticeLessonCancelled(String actor, String title, String date) {
    return '$actor $date న $title పాఠం రద్దు చేశారు.';
  }

  @override
  String noticeLessonSubstitute(String actor, String title, String date) {
    return '$actor $date న $title పాఠం చెప్పమని మిమ్మల్ని అడిగారు.';
  }

  @override
  String noticeLessonCovered(String actor, String title, String date) {
    return '$actor $date న మీ $title పాఠాన్ని వేరే ఉపాధ్యాయులకు ఇచ్చారు.';
  }

  @override
  String keypadKeyFor(String key, String action) {
    return '$action కోసం $key';
  }

  @override
  String keypadPressKeys(String keys) {
    return '$keys నొక్కండి.';
  }

  @override
  String get keypadKeySeparator => ', ';

  @override
  String get keypadStarHelp => 'సహాయం కోసం స్టార్ నొక్కండి.';

  @override
  String get sessionCloseRecording => 'తరగతి కోసం రికార్డింగ్ మూసివేయండి';

  @override
  String sessionRecordingClosedTeacher(String title) {
    return '$title తరగతి కోసం మూసివేయబడింది.';
  }

  @override
  String sessionRecordingClosedStudent(String title) {
    return 'మీ ఉపాధ్యాయులు $title రికార్డింగ్‌ను మూసివేశారు.';
  }
}
