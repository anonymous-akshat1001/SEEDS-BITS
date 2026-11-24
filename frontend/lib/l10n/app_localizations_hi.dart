// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get spokenDigitWords =>
      'शून्य, एक, दो, तीन, चार, पाँच, छह, सात, आठ, नौ';

  @override
  String get spokenMonths =>
      'जनवरी, फ़रवरी, मार्च, अप्रैल, मई, जून, जुलाई, अगस्त, सितंबर, अक्टूबर, नवंबर, दिसंबर';

  @override
  String get spokenWeekdays =>
      'सोमवार, मंगलवार, बुधवार, गुरुवार, शुक्रवार, शनिवार, रविवार';

  @override
  String get spokenPlus => 'प्लस';

  @override
  String spokenSession(String number) {
    return 'सत्र $number';
  }

  @override
  String get spokenNoon => 'दोपहर 12 बजे';

  @override
  String get spokenMidnight => 'आधी रात';

  @override
  String spokenOClock(String hour) {
    return '$hour बजे';
  }

  @override
  String spokenMorning(String clock) {
    return 'सुबह $clock';
  }

  @override
  String spokenAfternoon(String clock) {
    return 'दोपहर $clock';
  }

  @override
  String spokenEvening(String clock) {
    return 'शाम $clock';
  }

  @override
  String spokenNight(String clock) {
    return 'रात $clock';
  }

  @override
  String get spokenToday => 'आज';

  @override
  String get spokenTomorrow => 'कल';

  @override
  String get spokenYesterday => 'बीता कल';

  @override
  String spokenDate(String weekday, String day, String month) {
    return '$weekday, $day $month';
  }

  @override
  String spokenDateWithYear(
    String weekday,
    String day,
    String month,
    String year,
  ) {
    return '$weekday, $day $month $year';
  }

  @override
  String spokenDateAtTime(String date, String time) {
    return '$date, $time';
  }

  @override
  String spokenHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count घंटे',
      one: '1 घंटा',
    );
    return '$_temp0';
  }

  @override
  String spokenMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count मिनट',
      one: '1 मिनट',
    );
    return '$_temp0';
  }

  @override
  String spokenSeconds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count सेकंड',
      one: '1 सेकंड',
    );
    return '$_temp0';
  }

  @override
  String spokenPositionOf(String position, String total) {
    return '$total में से $position';
  }

  @override
  String spokenPercent(String value) {
    return '$value प्रतिशत';
  }

  @override
  String get spokenOn => 'चालू';

  @override
  String get spokenOff => 'बंद';

  @override
  String get keyBack10Seconds => '10 सेकंड पीछे';

  @override
  String get keyPlayOrPause => 'चलाएँ या रोकें';

  @override
  String get keyForward10Seconds => '10 सेकंड आगे';

  @override
  String get keySlower => 'धीमा';

  @override
  String get keyFaster => 'तेज़';

  @override
  String get keySlowerPlaybackSpeed => 'धीमी चलाने की गति';

  @override
  String get keyFasterPlaybackSpeed => 'तेज़ चलाने की गति';

  @override
  String get keyLogin => 'लॉगिन';

  @override
  String get keyRegister => 'रजिस्टर करें';

  @override
  String get keySettings => 'सेटिंग्स';

  @override
  String get keySelectStudentAccount => 'छात्र खाता चुनें';

  @override
  String get keySelectTeacherAccount => 'शिक्षक खाता चुनें';

  @override
  String get keySelectAdministratorAccount => 'प्रशासक खाता चुनें';

  @override
  String get keyGoToLogin => 'लॉगिन पर जाएँ';

  @override
  String get keyToggleTeacherRegistration =>
      'शिक्षक रजिस्ट्रेशन चालू या बंद करें';

  @override
  String get keyGoBack => 'वापस जाएँ';

  @override
  String get keyToggleTTS => 'टी टी एस चालू या बंद करें';

  @override
  String get keyToggleVoiceCommands => 'आवाज़ से आदेश चालू या बंद करें';

  @override
  String get keyShowOrHideShortcuts => 'शॉर्टकट दिखाएँ या छिपाएँ';

  @override
  String get keyToggleHighContrast => 'हाई कंट्रास्ट चालू या बंद करें';

  @override
  String get keyTestTTS => 'टी टी एस जाँचें';

  @override
  String get keySaveSettings => 'सेटिंग्स सेव करें';

  @override
  String get keyCheckVoice => 'आवाज़ जाँचें';

  @override
  String get keySoundCuesOnOrOff => 'ध्वनि संकेत चालू या बंद';

  @override
  String get keyVibrationOnOrOff => 'वाइब्रेशन चालू या बंद';

  @override
  String get keyLogOutAsksToConfirm => 'लॉग आउट, पुष्टि पूछेगा';

  @override
  String get keyRefreshSessions => 'सत्र रिफ़्रेश करें';

  @override
  String get keySearchSessionsByNameOrID => 'नाम या ID से सत्र खोजें';

  @override
  String get keyRecordedAudioLibrary => 'रिकॉर्ड किए गए ऑडियो की लाइब्रेरी';

  @override
  String get keyMyPrivatePlaylists => 'मेरी निजी प्लेलिस्ट';

  @override
  String get keyQuizzes => 'क्विज़';

  @override
  String get keyLearningJourneys => 'सीखने की यात्राएँ';

  @override
  String get keyCreateSession => 'सत्र बनाएँ';

  @override
  String get keyClassPlaylists => 'कक्षा प्लेलिस्ट';

  @override
  String get keyChooseClassAndSubjectWorkspace =>
      'कक्षा और विषय का वर्कस्पेस चुनें';

  @override
  String get keyRefresh => 'रिफ़्रेश करें';

  @override
  String get keySearchUsers => 'उपयोगकर्ता खोजें';

  @override
  String get keyChangeAccountTypeFilter => 'खाते के प्रकार का फ़िल्टर बदलें';

  @override
  String get keyChangeAssignmentFilter => 'असाइनमेंट फ़िल्टर बदलें';

  @override
  String get keyCreateSubject => 'विषय बनाएँ';

  @override
  String get keyCreateClass => 'कक्षा बनाएँ';

  @override
  String get keyChooseAccountsClassesOrSubjectsSection =>
      'खाते, कक्षाएँ या विषय वाला भाग चुनें';

  @override
  String get keyGoBackAlt => 'वापस जाएँ';

  @override
  String get keyCreateBankQuestion => 'प्रश्न बैंक का प्रश्न बनाएँ';

  @override
  String get keyCreateQuizDraft => 'क्विज़ ड्राफ़्ट बनाएँ';

  @override
  String get keyCreateUntimedUngradedPractice =>
      'बिना समय सीमा और बिना अंक वाला अभ्यास बनाएँ';

  @override
  String get keyRefreshQuizzes => 'क्विज़ रिफ़्रेश करें';

  @override
  String get keyChooseOption1 => 'विकल्प 1 चुनें';

  @override
  String get keyChooseOption2 => 'विकल्प 2 चुनें';

  @override
  String get keyChooseOption3 => 'विकल्प 3 चुनें';

  @override
  String get keyChooseOption4 => 'विकल्प 4 चुनें';

  @override
  String get keySubmitSelectedAnswer => 'चुना हुआ उत्तर जमा करें';

  @override
  String get keyRepeatQuestionAndOptions => 'प्रश्न और विकल्प दोहराएँ';

  @override
  String get keySlowerQuizSpeech => 'क्विज़ की आवाज़ धीमी करें';

  @override
  String get keyWhereAmIIncludingTimeLeft => 'मैं कहाँ हूँ, बचा हुआ समय भी';

  @override
  String get keyFasterQuizSpeech => 'क्विज़ की आवाज़ तेज़ करें';

  @override
  String get keyMuteOrUnmute => 'म्यूट या अनम्यूट';

  @override
  String get keyRaiseOrLowerHand => 'हाथ उठाएँ या हाथ नीचे करें';

  @override
  String get keyHearClassStatus => 'कक्षा की स्थिति सुनें';

  @override
  String get keyChat => 'चैट';

  @override
  String get keyHearWhatTheTeacherIsPlaying =>
      'सुनें कि शिक्षक क्या चला रहे हैं';

  @override
  String get keyAnswerClassroomCheck => 'कक्षा जाँच का उत्तर दें';

  @override
  String get keyWhoIsInTheClass => 'कक्षा में कौन है';

  @override
  String get keyLeaveSessionAsksToConfirm => 'सत्र छोड़ें, पुष्टि पूछेगा';

  @override
  String get keyRaisedHandsAcknowledgeAndLowerThemInOrder =>
      'उठे हुए हाथ: क्रम से स्वीकार करें और नीचे करें';

  @override
  String get keyClassRecordingPlayerPlayAndControlTheRecording =>
      'कक्षा रिकॉर्डिंग प्लेयर: रिकॉर्डिंग चलाएँ और नियंत्रित करें';

  @override
  String get keyClassroomCheckStartCloseAndHearResponses =>
      'कक्षा जाँच: शुरू करें, बंद करें और जवाब सुनें';

  @override
  String get keyParticipantsMuteOrRemoveSomeone =>
      'प्रतिभागी: किसी को म्यूट करें या हटाएँ';

  @override
  String get keyTeacherToolsInviteStudentsEndClassForEveryone =>
      'शिक्षक टूल: छात्रों को आमंत्रित करें, सबके लिए कक्षा खत्म करें';

  @override
  String get keyRefreshClasses => 'कक्षाएँ रिफ़्रेश करें';

  @override
  String get keySearchClassByName => 'नाम से कक्षा खोजें';

  @override
  String get keyAllAudioFiles => 'सभी ऑडियो फ़ाइलें';

  @override
  String get keyFocusFirstActiveClassUseDPadToBrowseClasses =>
      'पहली चालू कक्षा पर जाएँ; कक्षाएँ देखने के लिए D-pad इस्तेमाल करें';

  @override
  String get keyRefreshFiles => 'फ़ाइलें रिफ़्रेश करें';

  @override
  String get keyNextSubjectFilter => 'अगला विषय फ़िल्टर';

  @override
  String get keyStopPlayback => 'चलाना रोकें';

  @override
  String get keyAddAudioFile => 'ऑडियो फ़ाइल जोड़ें';

  @override
  String get keyUploadNewFile => 'नई फ़ाइल अपलोड करें';

  @override
  String get keySelectFromExistingLibrary => 'मौजूदा लाइब्रेरी से चुनें';

  @override
  String get keyRefreshList => 'सूची रिफ़्रेश करें';

  @override
  String get appName => 'SEEDS';

  @override
  String get languageEnglish => 'अंग्रेज़ी';

  @override
  String get languageHindi => 'हिंदी';

  @override
  String get languageKannada => 'कन्नड़';

  @override
  String get languageTelugu => 'तेलुगु';

  @override
  String get languageBengali => 'बांग्ला';

  @override
  String get commonPleaseWait => 'कृपया इंतज़ार करें। काम अभी चल रहा है।';

  @override
  String get commonSignInFirst => 'कृपया पहले साइन इन करें।';

  @override
  String get commonAccountChanged =>
      'इस फ़ोन पर आपका खाता बदल गया है। फिर से साइन इन करें।';

  @override
  String get commonNoWorkspace =>
      'कोई कक्षा और विषय नहीं चुना गया है। वर्कस्पेस चुनने के लिए 7 दबाएँ।';

  @override
  String get commonNoConnection =>
      'स्कूल सर्वर से कनेक्शन नहीं है। अपना इंटरनेट जाँचें और फिर से कोशिश करें।';

  @override
  String get commonNotAvailable => 'यह अभी उपलब्ध नहीं है।';

  @override
  String get commonNothingChanged => 'कुछ भी नहीं बदला गया।';

  @override
  String get commonNoMessages => 'इस स्क्रीन पर कोई संदेश नहीं है।';

  @override
  String get commonEndOfList => 'सूची खत्म। पहले आइटम पर वापस।';

  @override
  String get commonTopOfList => 'सूची की शुरुआत। आखिरी आइटम पर पहुँचे।';

  @override
  String commonOpening(String what) {
    return '$what खुल रहा है।';
  }

  @override
  String commonOpeningNeedsInternet(String what) {
    return '$what खुल रहा है। इंटरनेट ज़रूरी है।';
  }

  @override
  String commonUnavailable(String what) {
    return '$what उपलब्ध नहीं है।';
  }

  @override
  String commonUnavailableBecause(String what, String reason) {
    return '$what उपलब्ध नहीं है। $reason';
  }

  @override
  String commonWhereScreen(String screen) {
    return '$screen।';
  }

  @override
  String commonWhereFocused(String item) {
    return 'चुना हुआ: $item।';
  }

  @override
  String keypadPressFor(String key, String action) {
    return '$action के लिए $key दबाएँ';
  }

  @override
  String get keypadListSeparator => '। ';

  @override
  String get keypadRepeatInstructions =>
      'ये निर्देश दोहराने के लिए स्टार दबाएँ।';

  @override
  String get keypadRepeatFullHelp => 'पूरी मदद दोहराने के लिए स्टार दबाएँ।';

  @override
  String get keypadStarForShortcuts => 'सभी शॉर्टकट के लिए स्टार दबाएँ।';

  @override
  String keypadScreenReaderIntro(String screen) {
    return '$screen। कीपैड मदद के लिए स्टार दबाएँ।';
  }

  @override
  String keypadMoveThroughSections(String sections) {
    return '$sections में जाने के लिए D-pad का ऊपर और नीचे इस्तेमाल करें। चुने हुए कंट्रोल को चलाने के लिए ओके दबाएँ।';
  }

  @override
  String get keypadNumberedBackAndStop =>
      'वापस जाने या रद्द करने के लिए 0 दबाएँ। ऐप की आवाज़ रोकने के लिए हैश दबाएँ।';

  @override
  String get keypadNumberedEditing =>
      'लिखते समय बटन से टेक्स्ट लिखा जाता है। खत्म करने के लिए ओके दबाएँ, या फ़ील्ड से बाहर जाने के लिए ऊपर या नीचे इस्तेमाल करें।';

  @override
  String get keypadNumberedMove =>
      'विकल्पों के बीच जाने के लिए D-pad का ऊपर और नीचे, और चुनने के लिए ओके इस्तेमाल करें।';

  @override
  String get keypadEssentialMove =>
      'जाने के लिए ऊपर और नीचे, और चुनने के लिए ओके इस्तेमाल करें।';

  @override
  String get keypadPressZeroBack => 'वापस जाने के लिए 0 दबाएँ।';

  @override
  String get keypadHashAndStar =>
      'आवाज़ रोकने के लिए हैश दबाएँ। ये निर्देश दोहराने के लिए स्टार दबाएँ।';

  @override
  String get keypadDirectionKeys => 'जाने के लिए दिशा वाले बटन इस्तेमाल करें।';

  @override
  String get keypadDirectionKeysAndOk =>
      'जाने के लिए दिशा वाले बटन और चुनने के लिए ओके इस्तेमाल करें।';

  @override
  String get keypadActivateOrEdit =>
      'कंट्रोल चलाने या फ़ील्ड में लिखने के लिए ओके दबाएँ।';

  @override
  String get keypadLeaveField =>
      'लिखते समय, फ़ील्ड से बाहर जाने के लिए ओके दबाएँ या ऊपर या नीचे इस्तेमाल करें।';

  @override
  String keypadPosition(String index, String total) {
    return ', $total में से $index';
  }

  @override
  String keypadEditingPressOk(String label) {
    return '$label। लिख रहे हैं। खत्म होने पर ओके दबाएँ।';
  }

  @override
  String keypadEditingUseUpDown(String label) {
    return '$label। लिख रहे हैं। इस फ़ील्ड से बाहर जाने के लिए ऊपर या नीचे इस्तेमाल करें।';
  }

  @override
  String get keypadControlUnavailable => 'यह कंट्रोल अभी उपलब्ध नहीं है।';

  @override
  String get keypadMainScreen =>
      'यह मुख्य स्क्रीन है। यहाँ से पीछे जाने के लिए कुछ नहीं है।';

  @override
  String messageLast(String text) {
    return 'पिछला संदेश: $text';
  }

  @override
  String messageLastProblem(String text) {
    return 'पिछली समस्या: $text';
  }

  @override
  String ttsSpeedDescription(String speed) {
    return 'सामान्य गति का $speed गुना';
  }

  @override
  String get ttsUnavailable =>
      'आवाज़ उपलब्ध नहीं है। Android में अंग्रेज़ी टेक्स्ट-टू-स्पीच आवाज़ चालू करें, फिर सेटिंग्स में \'आवाज़ जाँचें\' बटन दबाएँ।';

  @override
  String ttsLanguageFallback(String language) {
    return 'इस फ़ोन पर $language आवाज़ उपलब्ध नहीं है, इसलिए SEEDS अंग्रेज़ी में बोलेगा। Android की टेक्स्ट-टू-स्पीच सेटिंग्स में $language आवाज़ इंस्टॉल करें, फिर सेटिंग्स में आवाज़ जाँचें।';
  }

  @override
  String get ttsScreenReaderDetected =>
      'स्क्रीन रीडर मिला। SEEDS अपनी घोषणाएँ आपके स्क्रीन रीडर को भेजेगा।';

  @override
  String get ttsScreenReaderOff =>
      'स्क्रीन रीडर बंद हो गया। SEEDS अब खुद बोलेगा।';

  @override
  String ttsVoiceInstalled(String language) {
    return 'Android के अनुसार $language आवाज़ का डेटा इंस्टॉल है। सेटिंग्स में \'आवाज़ जाँचें\' बटन दबाएँ, फिर ऑफ़लाइन आवाज़ पर भरोसा करने से पहले एयरप्लेन मोड में दोबारा जाँचें। यह जाँच यह साबित नहीं कर सकती कि आप इसे सुन पा रहे हैं।';
  }

  @override
  String ttsVoiceNotOffline(String language) {
    return '$language उपलब्ध है, पर ऑफ़लाइन आवाज़ डेटा इंस्टॉल होने की पुष्टि नहीं हुई। आवाज़ के लिए इंटरनेट चाहिए हो सकता है।';
  }

  @override
  String ttsVoiceMissing(String language) {
    return 'कोई $language आवाज़ नहीं मिली।';
  }

  @override
  String ttsVoiceUnverified(String language) {
    return '$language आवाज़ उपलब्ध है या नहीं, यह जाँचा नहीं जा सका।';
  }

  @override
  String ttsVoiceRecovery(String language) {
    return 'Android सेटिंग्स खोलें, टेक्स्ट-टू-स्पीच आउटपुट ढूँढें, $language आवाज़ चुनें और उसका आवाज़ डेटा इंस्टॉल करें। यहाँ लौटकर फिर से जाँचें। आप ऐप की आवाज़ की जगह Android स्क्रीन रीडर भी इस्तेमाल कर सकते हैं।';
  }

  @override
  String get ttsSpeedChangeFailed =>
      'आवाज़ की गति नहीं बदली जा सकी। फिर से कोशिश करें।';

  @override
  String get ttsSettingsFailed =>
      'आवाज़ की सेटिंग्स लागू नहीं हो सकीं। \'आवाज़ जाँचें\' बटन फिर से दबाएँ।';

  @override
  String get ttsCouldNotStart =>
      'आवाज़ शुरू नहीं हो सकी। सेटिंग्स में \'आवाज़ जाँचें\' बटन दबाएँ।';

  @override
  String get ttsNotAvailable =>
      'आवाज़ उपलब्ध नहीं थी। सेटिंग्स में \'आवाज़ जाँचें\' बटन दबाएँ।';

  @override
  String get ttsFailed =>
      'आवाज़ विफल रही। सेटिंग्स में \'आवाज़ जाँचें\' बटन दबाएँ।';

  @override
  String get ttsLessonResumeFailed =>
      'रिकॉर्ड किया गया पाठ फिर से शुरू नहीं हो सका। दोबारा कोशिश के लिए Play चुनें।';

  @override
  String get ttsStopFailed =>
      'आवाज़ रोकी नहीं जा सकी। Android TTS इंजन जाँचें।';

  @override
  String get ttsNoPendingUpdates => 'कोई बाकी अपडेट नहीं है।';

  @override
  String get ttsOtherUpdates => 'अन्य अपडेट';

  @override
  String ttsUpdateGroup(String group) {
    return '$group।';
  }

  @override
  String ttsUpdateGroupCount(String group, int count) {
    return '$group, $count अपडेट।';
  }

  @override
  String ttsOtherUpdateGroups(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count अन्य अपडेट समूह।',
      one: '1 अन्य अपडेट समूह।',
    );
    return '$_temp0';
  }

  @override
  String get settingsScreenName => 'सेटिंग्स';

  @override
  String get settingsSections =>
      'चार भाग: आवाज़, डिस्प्ले, बटन और मदद, फिर सेटिंग्स सेव करें';

  @override
  String get settingsLoaded => 'सेटिंग्स लोड हो गईं';

  @override
  String get settingsSaved => 'सेटिंग्स सेव हो गईं';

  @override
  String get settingsResetSaved =>
      'सेटिंग्स डिफ़ॉल्ट पर वापस करके सेव कर दी गईं';

  @override
  String settingsTestSpeech(String volume, String speed) {
    return 'यह टेक्स्ट-टू-स्पीच सिस्टम की जाँच है। आवाज़ का स्तर $volume प्रतिशत है। बोलने की गति $speed है।';
  }

  @override
  String settingsFastestSpeed(String speed) {
    return 'सबसे तेज़ बोलने की गति, $speed';
  }

  @override
  String settingsSlowestSpeed(String speed) {
    return 'सबसे धीमी बोलने की गति, $speed';
  }

  @override
  String settingsSpeechSpeed(String speed) {
    return 'बोलने की गति $speed';
  }

  @override
  String get settingsVoiceCommandsEnabled => 'आवाज़ से आदेश चालू';

  @override
  String get settingsVoiceCommandsDisabled => 'आवाज़ से आदेश बंद';

  @override
  String get settingsHighContrastOn => 'हाई कंट्रास्ट चालू';

  @override
  String get settingsHighContrastOff => 'हाई कंट्रास्ट बंद';

  @override
  String get settingsShortcutsShown => 'कीपैड शॉर्टकट दिख रहे हैं';

  @override
  String get settingsShortcutsHidden => 'कीपैड शॉर्टकट छिपे हैं';

  @override
  String get settingsVoiceHelp =>
      'सत्र में, आदेश के लिए सुनें चालू करें, फिर म्यूट, अनम्यूट, हाथ उठाएँ, हाथ नीचे करें, छोड़ें या दोहराएँ बोलें। सुनना अपने आप फिर से शुरू नहीं होता। अनम्यूट के लिए बटन या टच से पुष्टि माँगी जाती है।';

  @override
  String settingsModeAutomatic(String current) {
    return 'अपने आप: जब तक आप न चुनें, TalkBack के अनुसार चलता है। अभी $current।';
  }

  @override
  String get settingsModeUsingScreenReader => 'स्क्रीन रीडर इस्तेमाल हो रहा है';

  @override
  String get settingsModeUsingSelfVoicing => 'ऐप खुद बोल रहा है';

  @override
  String get settingsModeScreenReader =>
      'स्क्रीन रीडर: घोषणाएँ TalkBack पर जाती हैं। ऐप का बोलना बंद है।';

  @override
  String get settingsModeSelfVoicing => 'ऐप की अपनी आवाज़: ऐप खुद बोलता है।';

  @override
  String settingsSoundCues(String state) {
    return 'ध्वनि संकेत $state।';
  }

  @override
  String settingsSoundCuesOnSaved(String state) {
    return 'ध्वनि संकेत $state। यह सेव होने की ध्वनि है।';
  }

  @override
  String settingsVibration(String state) {
    return 'कंपन $state।';
  }

  @override
  String settingsVibrationOnBuzz(String state) {
    return 'कंपन $state। एक छोटे कंपन का मतलब है ठीक है।';
  }

  @override
  String settingsSoundCuesLabel(String state) {
    return 'ध्वनि संकेत, $state। सही, गलत, सेव, त्रुटि और आपकी बोलने की बारी के लिए छोटी ध्वनियाँ';
  }

  @override
  String settingsVibrationLabel(String state) {
    return 'कंपन, $state। ठीक के लिए एक कंपन, त्रुटि के लिए दो, बाहर निकलने के लिए एक लंबा कंपन';
  }

  @override
  String get settingsSoundCuesHelp =>
      'सही, गलत, सेव, त्रुटि, सूची का अंत और आपकी बोलने की बारी के लिए छोटी ध्वनियाँ। तुरंत सेव हो जाता है।';

  @override
  String get settingsVibrationHelp =>
      'ठीक के लिए एक छोटा कंपन, त्रुटि के लिए दो, बाहर निकलने या खत्म करने के लिए एक लंबा कंपन। तुरंत सेव हो जाता है।';

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
    return 'ऐप की आवाज़ $speech, गति $speed, वॉल्यूम $volume प्रतिशत। टेक्स्ट का आकार $textSize प्रतिशत। हाई कंट्रास्ट $highContrast। ध्वनि संकेत $soundCues। कंपन $vibration। बोलने की भाषा $language।';
  }

  @override
  String settingsVolume(String percent) {
    return 'वॉल्यूम $percent प्रतिशत';
  }

  @override
  String settingsTextSize(String percent) {
    return 'टेक्स्ट का आकार $percent प्रतिशत';
  }

  @override
  String get settingsSpeechOff => 'ऐप की आवाज़ बंद';

  @override
  String get settingsSpeechOn => 'ऐप की आवाज़ चालू';

  @override
  String settingsSpeechMode(String description) {
    return 'आवाज़ मोड। $description';
  }

  @override
  String settingsNarration(String level) {
    return 'बोलने का स्तर $level।';
  }

  @override
  String get settingsNarrationEssential => 'ज़रूरी';

  @override
  String get settingsNarrationStandard => 'सामान्य';

  @override
  String get settingsNarrationDetailed => 'विस्तृत';

  @override
  String settingsLanguage(String language) {
    return 'बोलने की भाषा $language।';
  }

  @override
  String settingsLanguageLabel(String language) {
    return 'बोलने की भाषा, $language। बदलने के लिए ओके दबाएँ।';
  }

  @override
  String get settingsBack => 'वापस';

  @override
  String get settingsResetLabel =>
      'सेटिंग्स को डिफ़ॉल्ट पर रीसेट करें, पुष्टि पूछेगा';

  @override
  String settingsSpeechSectionLabel(String state) {
    return 'आवाज़ भाग। ऐप की आवाज़, $state';
  }

  @override
  String settingsVolumeLabel(String percent) {
    return 'वॉल्यूम $percent प्रतिशत। बदलने के लिए बाएँ या दाएँ';
  }

  @override
  String settingsSpeedLabel(String speed) {
    return 'बोलने की गति $speed। बदलने के लिए बाएँ या दाएँ';
  }

  @override
  String get settingsTestLabel => 'आवाज़ जाँचें';

  @override
  String settingsModeLabel(String description) {
    return 'आवाज़ मोड। $description बदलने के लिए ओके दबाएँ।';
  }

  @override
  String settingsNarrationLabel(String level) {
    return 'बोलने का स्तर $level। बदलने के लिए ओके दबाएँ।';
  }

  @override
  String settingsCheckVoiceLabel(String language) {
    return '$language आवाज़ जाँचें';
  }

  @override
  String get settingsStopLabel => 'आवाज़ रोकें';

  @override
  String settingsContrastLabel(String state) {
    return 'डिस्प्ले भाग। हाई कंट्रास्ट, $state। शुरू से चालू';
  }

  @override
  String settingsTextSizeLabel(String percent) {
    return 'टेक्स्ट का आकार $percent प्रतिशत। बदलने के लिए बाएँ या दाएँ';
  }

  @override
  String settingsShortcutsLabel(String state) {
    return 'बटन और मदद भाग। कीपैड शॉर्टकट दिखाएँ, $state';
  }

  @override
  String settingsVoiceCommandsLabel(String state) {
    return 'सत्रों में आवाज़ से आदेश, $state';
  }

  @override
  String get settingsVoiceHelpLabel => 'आवाज़ आदेश की मदद';

  @override
  String get settingsRepeatHelpLabel => 'सेटिंग्स की मदद दोबारा सुनें';

  @override
  String get settingsSaveLabel => 'सेटिंग्स सेव करें';

  @override
  String get settingsResetQuestion =>
      'सभी सेटिंग्स डिफ़ॉल्ट पर रीसेट करें? आवाज़, डिस्प्ले और बटन की सेटिंग्स अपने मूल मान पर लौट आएँगी।';

  @override
  String settingsResetScreen(String question) {
    return 'सेटिंग्स रीसेट करें। $question';
  }

  @override
  String get settingsResetCancel => 'रद्द करें';

  @override
  String get settingsResetConfirm => 'रीसेट करें';

  @override
  String get settingsResetCancelLabel => 'रद्द करें, मेरी सेटिंग्स रखें';

  @override
  String get settingsResetConfirmLabel => 'सभी सेटिंग्स डिफ़ॉल्ट पर रीसेट करें';

  @override
  String get quizNotSet => 'तय नहीं';

  @override
  String get quizNotAvailable => 'उपलब्ध नहीं';

  @override
  String get quizNotAvailableCapital => 'उपलब्ध नहीं';

  @override
  String quizQuestionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count प्रश्न',
      one: '1 प्रश्न',
    );
    return '$_temp0';
  }

  @override
  String quizAttemptCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count प्रयास',
      one: '1 प्रयास',
    );
    return '$_temp0';
  }

  @override
  String quizStudentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count छात्र',
      one: '1 छात्र',
    );
    return '$_temp0';
  }

  @override
  String get quizAccountChanged =>
      'आपका खाता बदल गया है। क्विज़ पर लौटें और फिर से साइन इन करें।';

  @override
  String get quizUnlimitedPractice =>
      'अभ्यास के असीमित प्रयास। अंक नहीं दिए जाते।';

  @override
  String quizAttemptsRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count प्रयास बाकी हैं।',
      one: '1 प्रयास बाकी है।',
    );
    return '$_temp0';
  }

  @override
  String quizTimeLimit(String duration) {
    return 'समय सीमा $duration।';
  }

  @override
  String get quizNoTimeLimit => 'कोई समय सीमा नहीं।';

  @override
  String get quizNoTimeLimitShort => 'कोई समय सीमा नहीं';

  @override
  String get quizFeedbackAfterCompletion =>
      'जवाबों पर फ़ीडबैक और अंक क्विज़ पूरा करने के बाद दिए जाते हैं।';

  @override
  String quizFeedbackScheduled(String when) {
    return 'फ़ीडबैक और अंक आपके पूरा करने के बाद और $when के बाद दिए जाते हैं।';
  }

  @override
  String get quizFeedbackScoreOnly =>
      'पूरा करने के बाद केवल अंक दिए जाते हैं। जवाब और व्याख्याएँ नहीं दी जातीं।';

  @override
  String get quizFeedbackImmediate =>
      'हर जवाब जमा करते ही आप सुनेंगे कि वह सही है या नहीं।';

  @override
  String get quizPolicyAfterCompletion => 'क्विज़ पूरा होने के बाद';

  @override
  String get quizPolicyScheduled => 'तय समय पर';

  @override
  String get quizPolicyScoreOnly => 'केवल अंक';

  @override
  String get quizPolicyLegacyImmediate => 'तुरंत, पुरानी सेटिंग';

  @override
  String get quizPolicyImmediate => 'हर जवाब के तुरंत बाद';

  @override
  String quizPracticeResult(String correct, String total) {
    return 'अभ्यास, यह पढ़ाई का ग्रेड नहीं है। इस अभ्यास में $total में से $correct सही।';
  }

  @override
  String quizScoreNotReleased(String message) {
    return 'अंक अभी नहीं दिए गए। $message';
  }

  @override
  String get quizCheckReleasePolicy => 'अंक देने का नियम जाँचें।';

  @override
  String quizScoreResult(String correct, String total, String percent) {
    return 'अंक $total में से $correct, $percent।';
  }

  @override
  String get quizStatusInProgress => 'चल रहा है';

  @override
  String get quizStatusTimedOut => 'समय खत्म होने पर पूरा हुआ';

  @override
  String get quizStatusCompleted => 'पूरा हुआ';

  @override
  String get quizStatusPublished => 'प्रकाशित';

  @override
  String get quizStatusDraft => 'ड्राफ़्ट';

  @override
  String get quizStatusClosed => 'बंद';

  @override
  String get quizStatusScheduled => 'तय समय पर';

  @override
  String get quizStatusOpen => 'खुला';

  @override
  String quizQuestionHeading(String number, String total) {
    return 'प्रश्न $number, कुल $total';
  }

  @override
  String quizQuestionWithText(String number, String total, String text) {
    return 'प्रश्न $number, कुल $total। $text';
  }

  @override
  String quizOptionSpoken(String number, String text) {
    return 'विकल्प $number। $text।';
  }

  @override
  String quizOptionLabel(String number, String count, String text) {
    return 'विकल्प $number, कुल $count, $text';
  }

  @override
  String quizOptionTargetSelected(String number, String text) {
    return 'विकल्प $number, $text, चुना गया। चुनने के लिए ओके या $number दबाएँ';
  }

  @override
  String quizOptionTargetNotSelected(String number, String text) {
    return 'विकल्प $number, $text, नहीं चुना गया। चुनने के लिए ओके या $number दबाएँ';
  }

  @override
  String quizAnswerKeysBrief(String count) {
    return '1 से $count दबाएँ, फिर 5।';
  }

  @override
  String quizAnswerKeysDetailed(String count) {
    return 'उत्तर चुनने के लिए 1 से $count दबाएँ, फिर भेजने के लिए 5 दबाएँ। प्रश्न दोबारा सुनने के लिए 6 दबाएँ, आप कहाँ हैं यह सुनने के लिए 8 दबाएँ।';
  }

  @override
  String quizChosenBrief(String number, String text) {
    return 'विकल्प $number, $text, चुना गया।';
  }

  @override
  String quizChosenDetailed(String number, String text) {
    return 'विकल्प $number, $text, चुना गया। भेजने के लिए 5 दबाएँ, या कोई दूसरा नंबर चुनें।';
  }

  @override
  String quizChooseFirst(String count) {
    return 'पहले एक उत्तर चुनें। 1 से $count दबाएँ, फिर भेजने के लिए 5 दबाएँ।';
  }

  @override
  String quizNoSuchOption(String option, String count) {
    return 'विकल्प $option नहीं है। 1 से $count दबाएँ।';
  }

  @override
  String get quizSubmitting => 'आपका उत्तर भेजा जा रहा है।';

  @override
  String quizCorrectFeedback(String answer) {
    return 'सही! $answer।';
  }

  @override
  String quizWrongFeedback(String answer) {
    return 'सही नहीं। उत्तर है $answer।';
  }

  @override
  String get quizAnswerSavedBrief => 'उत्तर सेव हो गया।';

  @override
  String get quizAnswerSavedLocked => 'उत्तर सेव और लॉक हो गया।';

  @override
  String get quizSavedHeading => 'उत्तर सेव और लॉक हो गया';

  @override
  String get quizCorrectHeading => 'सही';

  @override
  String get quizWrongHeading => 'गलत';

  @override
  String quizYouSelected(String text) {
    return 'आपने चुना: $text';
  }

  @override
  String quizCorrectAnswerIs(String text) {
    return 'सही उत्तर: $text';
  }

  @override
  String get quizNoExplanation => 'कोई व्याख्या नहीं दी गई।';

  @override
  String quizAnswerFailed(String reason) {
    return '$reason आपका चुना हुआ उत्तर सुरक्षित है। फिर से कोशिश करने के लिए 5 दबाएँ।';
  }

  @override
  String get quizAnswerUnreadable => 'उत्तर की पुष्टि पढ़ी नहीं जा सकी।';

  @override
  String get quizNoOptionSelected => 'कोई विकल्प नहीं चुना गया।';

  @override
  String quizSelectionSaved(String number, String text) {
    return 'विकल्प $number, $text चुना गया। उत्तर सेव हो गया।';
  }

  @override
  String quizSelectionNotSubmitted(String number, String text) {
    return 'विकल्प $number, $text चुना गया। अभी भेजा नहीं गया।';
  }

  @override
  String get quizRepeatQuestion => 'प्रश्न और विकल्प दोबारा सुनें';

  @override
  String get quizAnswerConfirmed => 'पुष्टि हुई: उत्तर सेव और लॉक हो गया।';

  @override
  String get quizFeedbackStaysAvailable =>
      'इसका फ़ीडबैक अगले प्रश्न पर निजी रूप से सुना जा सकता है।';

  @override
  String get quizPreviousFeedback => 'पिछले उत्तर का फ़ीडबैक निजी रूप से सुनें';

  @override
  String get quizAnswerLockNotice =>
      '5 दबाने पर हर उत्तर सेव और लॉक हो जाता है।';

  @override
  String quizTimeLeft(String duration) {
    return 'बचा हुआ समय: $duration।';
  }

  @override
  String quizClockLeft(String clock) {
    return '$clock बचा है';
  }

  @override
  String quizClockRemaining(String clock) {
    return '$clock शेष';
  }

  @override
  String quizTimeWarning(String duration) {
    return 'इस क्विज़ में $duration बचा है।';
  }

  @override
  String quizTimeUp(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'समय समाप्त। $count उत्तर सेव हुए। क्विज़ पूरा किया जा रहा है।',
      one: 'समय समाप्त। 1 उत्तर सेव हुआ। क्विज़ पूरा किया जा रहा है।',
    );
    return '$_temp0';
  }

  @override
  String quizWhereQuestion(String number, String total) {
    return 'प्रश्न $number, कुल $total में से।';
  }

  @override
  String quizAnsweredCount(String count) {
    return '$count के उत्तर दिए।';
  }

  @override
  String get quizAllSaved =>
      'सभी उत्तर सेव हो गए हैं। क्विज़ पूरा करने और अपना परिणाम सुनने के लिए 5 दबाएँ।';

  @override
  String get quizFinishNow => 'क्विज़ अभी पूरा करें, पुष्टि के साथ';

  @override
  String get quizFinishNowButton => 'क्विज़ अभी पूरा करें';

  @override
  String get quizFinishTitle => 'क्विज़ अभी पूरा करें?';

  @override
  String quizFinishMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'सर्वर के अनुसार $count प्रश्नों के उत्तर नहीं दिए गए हैं। केवल सेव किए गए उत्तर गिने जाते हैं। जो उत्तर आपने चुना पर भेजा नहीं, वह शामिल नहीं है। पूरा करने के बाद आप उत्तर नहीं बदल सकते।',
      one:
          'सर्वर के अनुसार 1 प्रश्न का उत्तर नहीं दिया गया है। केवल सेव किए गए उत्तर गिने जाते हैं। जो उत्तर आपने चुना पर भेजा नहीं, वह शामिल नहीं है। पूरा करने के बाद आप उत्तर नहीं बदल सकते।',
    );
    return '$_temp0';
  }

  @override
  String get quizFinishConfirm => 'क्विज़ पूरा करें';

  @override
  String get quizFinishCancel => 'जारी रखें';

  @override
  String get quizFinishUnchecked =>
      'आपके सेव किए गए उत्तर जाँचे नहीं जा सके, या यह प्रयास समाप्त हो गया है। क्विज़ पूरा नहीं हुआ। इसे रीफ़्रेश करने के लिए क्विज़ सूची पर वापस जाएँ।';

  @override
  String get quizFinishTimedOut =>
      'आपके सेव किए गए उत्तर जाँचने में बहुत समय लगा। क्विज़ पूरा नहीं हुआ। अपना कनेक्शन जाँचें और फिर से कोशिश करें।';

  @override
  String get quizFinishing => 'क्विज़ पूरा किया जा रहा है';

  @override
  String get quizFinishAndHear => 'पूरा करें और परिणाम सुनें';

  @override
  String get quizRetryFinishing => 'फिर से पूरा करने की कोशिश करें';

  @override
  String quizCompletionFailed(String reason) {
    return '$reason आपके सेव किए गए उत्तर सुरक्षित हैं। फिर से पूरा करने की कोशिश के लिए 5 दबाएँ।';
  }

  @override
  String get quizCompletionNotConfirmed => 'पूरा होने की पुष्टि नहीं हुई।';

  @override
  String get quizCompleted =>
      'क्विज़ पूरा हुआ। आपका परिणाम निजी है। उसे सुनने के लिए 8 दबाएँ, या क्विज़ पर लौटने के लिए 0 दबाएँ।';

  @override
  String get quizCompletedTimedOut =>
      'समय समाप्त हो गया। क्विज़ पूरा हुआ। आपका परिणाम निजी है। उसे सुनने के लिए 8 दबाएँ, या क्विज़ पर लौटने के लिए 0 दबाएँ।';

  @override
  String get quizResultPrivate =>
      'क्विज़ पूरा हुआ। परिणाम निजी है। परिणाम निजी रूप से पढ़ें का उपयोग करें।';

  @override
  String get quizResultHeading => 'प्रयास पूरा हुआ';

  @override
  String get quizReadResult => 'परिणाम निजी रूप से पढ़ें';

  @override
  String get quizReturnToQuizzes => 'क्विज़ पर लौटें';

  @override
  String get quizLeave => 'बिना भेजे बाहर जाएँ, पुष्टि के साथ';

  @override
  String get quizLeaveTitle => 'बाहर जाएँ और बाद में जारी रखें?';

  @override
  String get quizLeaveMessage =>
      'इससे आपका प्रयास जमा नहीं होता। केवल सेव किए गए उत्तर रखे जाते हैं; जो उत्तर आपने चुना पर भेजा नहीं, वह खो सकता है। कोई भी समय-सीमा चलती रहती है। जब तक क्विज़ अनुमति देता है, आप इसे फिर से जारी रख सकते हैं।';

  @override
  String get quizLeaveConfirm => 'बिना भेजे बाहर जाएँ';

  @override
  String get quizLeaveCancel => 'क्विज़ में रहें';

  @override
  String get quizWaitBeforeLeaving =>
      'कृपया प्रतीक्षा करें। आपका उत्तर अभी सेव हो रहा है।';

  @override
  String quizAttemptScreen(String title) {
    return 'क्विज़ प्रयास, $title';
  }

  @override
  String get quizAttemptNavigationCompleted =>
      'क्विज़ पर लौटें, परिणाम निजी रूप से पढ़ें और क्विज़ की बोलने की गति';

  @override
  String get quizAttemptNavigationTimed =>
      'प्रश्न, हर उत्तर विकल्प, चुना हुआ उत्तर, क्विज़ की बोलने की गति, बचा हुआ समय, भेजें, क्विज़ अभी पूरा करें और बाहर जाएँ। फ़ोकस बदलने से कभी कुछ चुना या भेजा नहीं जाता';

  @override
  String get quizAttemptNavigationUntimed =>
      'प्रश्न, हर उत्तर विकल्प, चुना हुआ उत्तर, क्विज़ की बोलने की गति, भेजें, क्विज़ अभी पूरा करें और बाहर जाएँ। फ़ोकस बदलने से कभी कुछ चुना या भेजा नहीं जाता';

  @override
  String get quizSpeedHelp =>
      'क्विज़ की आवाज़ धीमी या तेज़ करने के लिए 7 या 9 दबाएँ।';

  @override
  String get quizSpeedScreenReader =>
      'क्विज़ की बोलने की गति केवल ऐप की आवाज़ बदलती है। अपने स्क्रीन रीडर की गति Android सेटिंग्स में बदलें।';

  @override
  String get quizSpeedHeading => 'क्विज़ की बोलने की गति';

  @override
  String quizSpeedTarget(String description) {
    return 'क्विज़ की बोलने की गति, $description। बदलने के लिए बाएँ या दाएँ, या 7 या 9 दबाएँ';
  }

  @override
  String quizSpeedRead(String description) {
    return 'क्विज़ की बोलने की गति, $description। धीमा करने के लिए 7 या तेज़ करने के लिए 9 दबाएँ। यह गति केवल क्विज़ में उपयोग होती है।';
  }

  @override
  String quizSpeedFaster(String description) {
    return 'तेज़। $description।';
  }

  @override
  String quizSpeedSlower(String description) {
    return 'धीमा। $description।';
  }

  @override
  String quizSpeedFastest(String description) {
    return 'क्विज़ की सबसे तेज़ आवाज़, $description।';
  }

  @override
  String quizSpeedSlowest(String description) {
    return 'क्विज़ की सबसे धीमी आवाज़, $description।';
  }

  @override
  String get quizStudentScreen => 'छात्र क्विज़';

  @override
  String get quizStudentNavigation =>
      'रीफ़्रेश, क्विज़ स्थिति और विषय फ़िल्टर, उपलब्ध क्विज़, और प्रयासों का इतिहास';

  @override
  String get quizStudentIntroBrief =>
      'फ़िल्टर बदलने के लिए उस पर बाएँ या दाएँ दबाएँ।';

  @override
  String get quizStudentIntroDetailed =>
      'फ़िल्टर बदलने के लिए उस पर बाएँ या दाएँ दबाएँ। किसी क्विज़ का विवरण सुनने और शुरू करने की पुष्टि के लिए उस पर ओके दबाएँ। फ़ोकस बदलने से कभी क्विज़ शुरू नहीं होता।';

  @override
  String quizAvailable(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count क्विज़ उपलब्ध हैं।',
      one: '1 क्विज़ उपलब्ध है।',
      zero: 'कोई क्विज़ उपलब्ध नहीं है।',
    );
    return '$_temp0';
  }

  @override
  String quizStudentState(int count, String open) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count क्विज़ दिखाए गए, $open खुले।',
      one: '1 क्विज़ दिखाया गया, $open खुला।',
    );
    return '$_temp0';
  }

  @override
  String get quizStateAll => 'सभी स्थितियाँ';

  @override
  String get quizStateScheduled => 'निर्धारित';

  @override
  String get quizStateOpen => 'खुला';

  @override
  String get quizStateClosed => 'बंद';

  @override
  String quizStateFilter(String name, String position, String count) {
    return 'क्विज़ स्थिति: $name, $count में से $position।';
  }

  @override
  String quizSubjectFilter(String name, String position, String count) {
    return 'विषय: $name, $count में से $position।';
  }

  @override
  String get quizChangeWithArrows => 'बदलने के लिए बाएँ या दाएँ';

  @override
  String get quizAllSubjects => 'सभी विषय';

  @override
  String quizRowHead(String subject, String title, String status) {
    return '$subject, $title, $status।';
  }

  @override
  String get quizStartQuiz => 'क्विज़ शुरू करें';

  @override
  String get quizResumeQuiz => 'क्विज़ जारी रखें';

  @override
  String quizHistoryRow(String title, String score) {
    return '$title के प्रयासों का इतिहास देखें। सबसे अधिक अंक $score';
  }

  @override
  String quizLimitReached(String title) {
    return '$title के लिए कोई प्रयास नहीं बचा। अपने अंक देखने के लिए प्रयासों का इतिहास खोलें।';
  }

  @override
  String get quizStartTitle => 'क्विज़ शुरू करें?';

  @override
  String get quizResumeTitle => 'क्विज़ जारी रखें?';

  @override
  String quizTitleSentence(String title) {
    return '$title।';
  }

  @override
  String quizClosesSentence(String when) {
    return '$when बंद होगा।';
  }

  @override
  String get quizStartAttempt => 'प्रयास शुरू करें';

  @override
  String get quizResumeAttempt => 'प्रयास जारी रखें';

  @override
  String get quizStartFailed =>
      'क्विज़ शुरू नहीं हो सका। जाँचें कि वह खुला है।';

  @override
  String get quizHistoryFailed => 'प्रयासों का इतिहास लोड नहीं हो सका।';

  @override
  String get quizHistoryScreen =>
      'प्रयासों का इतिहास। अंक निजी हैं। सारांश या किसी प्रयास पर जाकर उसे देखें।';

  @override
  String get quizPracticeHistory =>
      'अभ्यास का इतिहास। ये पढ़ाई के ग्रेड नहीं हैं।';

  @override
  String quizHighestScoreValue(String score) {
    return 'सबसे अधिक अंक: $score';
  }

  @override
  String get quizNoScoreReleasedYet =>
      'पूरे किए गए प्रयास हैं; अभी कोई अंक जारी नहीं किए गए।';

  @override
  String get quizNoCompletedAttempt => 'कोई पूरा प्रयास नहीं';

  @override
  String quizHistoryAttempt(String number, String status, String result) {
    return 'प्रयास $number। $status। $result देखने के लिए ओके दबाएँ।';
  }

  @override
  String get quizResumeFromList =>
      'यह प्रयास चल रहा है। इसे जारी रखने के लिए क्विज़ सूची पर लौटें। बाहर जाने से प्रयास जमा नहीं होता।';

  @override
  String get quizReviewFailed =>
      'प्रयास की समीक्षा लोड नहीं हो सकी। अपना कनेक्शन जाँचें और फिर से कोशिश करें।';

  @override
  String get quizReviewTimedOut =>
      'प्रयास की समीक्षा में बहुत समय लगा। अपना कनेक्शन जाँचें और फिर से कोशिश करें।';

  @override
  String quizReviewScreenMessage(String message) {
    return 'प्रयास की समीक्षा। $message';
  }

  @override
  String quizReviewScreen(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'प्रयास की समीक्षा। $count प्रश्न। हर उत्तर देखने के लिए ऊपर और नीचे का उपयोग करें।',
      one:
          'प्रयास की समीक्षा। 1 प्रश्न। हर उत्तर देखने के लिए ऊपर और नीचे का उपयोग करें।',
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
    return 'प्रश्न $number। सही। $question। आपने चुना $chosen। सही उत्तर $answer। $explanation';
  }

  @override
  String quizReviewQuestionIncorrect(
    String number,
    String question,
    String chosen,
    String answer,
    String explanation,
  ) {
    return 'प्रश्न $number। गलत। $question। आपने चुना $chosen। सही उत्तर $answer। $explanation';
  }

  @override
  String get quizNoAnswer => 'कोई उत्तर नहीं';

  @override
  String quizTeacherScreen(String className, String subjectName) {
    return '$className, $subjectName के लिए शिक्षक क्विज़';
  }

  @override
  String get quizTeacherNavigation =>
      'बैंक खोज और सेव किए गए प्रश्न, क्विज़ ड्राफ़्ट, प्रकाशित क्विज़, और उनके परिणाम';

  @override
  String get quizTeacherIntroDetailed =>
      'बैंक खोज और सेव किए गए प्रश्न, क्विज़ ड्राफ़्ट, प्रकाशित क्विज़ और परिणाम देखने के लिए डी-पैड का उपयोग करें।';

  @override
  String quizBankQuestionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count बैंक प्रश्न',
      one: '1 बैंक प्रश्न',
    );
    return '$_temp0';
  }

  @override
  String quizQuizCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count क्विज़',
      one: '1 क्विज़',
    );
    return '$_temp0';
  }

  @override
  String quizDraftCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ड्राफ़्ट',
      one: '1 ड्राफ़्ट',
    );
    return '$_temp0';
  }

  @override
  String quizTeacherLoaded(String questions, String quizzes) {
    return '$questions और $quizzes लोड हुए।';
  }

  @override
  String quizTeacherState(
    String drafts,
    String published,
    String closed,
    String bankQuestions,
  ) {
    return '$drafts, $published प्रकाशित, $closed बंद। $bankQuestions।';
  }

  @override
  String get quizTeacherLoadFailed =>
      'प्रश्न बैंक या क्विज़ सूची रीफ़्रेश नहीं हो सकी। दूसरा क्विज़ बनाने से पहले फिर से कोशिश करने के लिए 1 दबाएँ।';

  @override
  String get quizRefreshQuizzes => 'क्विज़ सामग्री रीफ़्रेश करें';

  @override
  String get quizSearchBank => 'निजी प्रश्न बैंक में खोजें';

  @override
  String get quizCreateQuestion => 'चार विकल्प वाला प्रश्न बनाएँ';

  @override
  String get quizCreateQuiz => 'क्विज़ ड्राफ़्ट बनाएँ';

  @override
  String get quizCreatePractice =>
      'अलग अभ्यास बनाएँ, बिना समय-सीमा और बिना अंक वाला। असीमित बार दोबारा कर सकते हैं';

  @override
  String quizBankQuestionItem(String question, String revision) {
    return 'प्रश्न बैंक आइटम, $question। संशोधन $revision। बदलने, संशोधन इतिहास, कॉपी बनाने, संग्रहित करने या जोड़ने के लिए ओके दबाएँ';
  }

  @override
  String get quizRevisionUnknownOlder => 'अज्ञात, पुराना प्रश्न';

  @override
  String get quizRevisionUnknownLegacy => 'अज्ञात पुराना';

  @override
  String quizContinueCreating(String title, String questions) {
    return '$title बनाना जारी रखें। $questions';
  }

  @override
  String quizContinueCreatingRaw(String title, String count) {
    return '$title बनाना जारी रखें। $count प्रश्न';
  }

  @override
  String quizCloseWithConfirmation(String title) {
    return '$title बंद करें, पुष्टि के साथ';
  }

  @override
  String quizCloseNamed(String title) {
    return '$title बंद करें';
  }

  @override
  String quizIsClosed(String title) {
    return '$title बंद है';
  }

  @override
  String quizDuplicateTarget(String title) {
    return '$title की कॉपी नए बदलने योग्य ड्राफ़्ट में बनाएँ';
  }

  @override
  String quizResultsTarget(String title) {
    return '$title के परिणाम देखें';
  }

  @override
  String quizCard(String title, String status, String questions) {
    return '$title। स्थिति $status। $questions।';
  }

  @override
  String get quizAccountChangedBank =>
      'आपका खाता बदल गया है। जारी रखने से पहले प्रश्न बैंक फिर से खोलें।';

  @override
  String quizQuestionSaveUnconfirmed(String reason) {
    return '$reason प्रश्न सेव होने की पुष्टि नहीं हो सकी। फिर से कोशिश करने से पहले बैंक जाँचें और रीफ़्रेश करें; दोहरा प्रश्न न बनाएँ।';
  }

  @override
  String get quizMissingRevision =>
      'सर्वर ने बिना संशोधन के प्रश्न भेजा। प्रशासक से क्विज़ बैकएंड अपडेट करने को कहें।';

  @override
  String get quizSavedQuestionMismatch => 'सेव किया गया प्रश्न मेल नहीं खाया।';

  @override
  String get quizQuestionSaved =>
      'प्रश्न सेव हो गया। बाद में इस बैंक प्रश्न को बदलने से मौजूदा क्विज़ नहीं बदलेंगे।';

  @override
  String get quizNoRevisionForEdit =>
      'इस सर्वर ने प्रश्न का संशोधन नहीं दिया। बदलने से पहले प्रशासक से क्विज़ बैकएंड अपडेट करने को कहें।';

  @override
  String quizQuestionUpdateUnconfirmed(String reason) {
    return '$reason बैंक प्रश्न अपडेट होने की पुष्टि नहीं हो सकी। फिर से कोशिश करने से पहले रीफ़्रेश करें और उसका मौजूदा संशोधन देखें।';
  }

  @override
  String get quizSavedRevisionMismatch => 'सेव किया गया संशोधन मेल नहीं खाया।';

  @override
  String get quizQuestionUpdated =>
      'बैंक प्रश्न अपडेट हो गया। मौजूदा क्विज़ की प्रतियाँ नहीं बदलीं।';

  @override
  String get quizArchiveTitle => 'बैंक प्रश्न संग्रहित करें?';

  @override
  String get quizArchiveMessage =>
      'यह निजी बैंक प्रश्न संग्रहित करें? मौजूदा क्विज़ की प्रतियाँ और प्रयास नहीं बदलेंगे।';

  @override
  String get quizArchiveConfirm => 'प्रश्न संग्रहित करें';

  @override
  String get quizArchiveFailed => 'बैंक प्रश्न संग्रहित नहीं हो सका।';

  @override
  String get quizArchived => 'बैंक प्रश्न संग्रहित हो गया।';

  @override
  String get quizDuplicateQuestionFailed => 'बैंक प्रश्न की कॉपी नहीं बन सकी।';

  @override
  String get quizQuestionDuplicated => 'बैंक प्रश्न की कॉपी बन गई।';

  @override
  String quizQuestionActions(String question) {
    return '$question के लिए विकल्प';
  }

  @override
  String get quizActionEdit => 'बैंक प्रश्न बदलें';

  @override
  String get quizActionDuplicate => 'बैंक प्रश्न की कॉपी बनाएँ';

  @override
  String get quizActionArchive => 'बैंक प्रश्न संग्रहित करें';

  @override
  String get quizActionRevisions => 'प्रश्न का संशोधन इतिहास पढ़ें';

  @override
  String quizActionAddTo(String title) {
    return '$title में जोड़ें';
  }

  @override
  String get quizRefreshBeforeDraft =>
      'दूसरा ड्राफ़्ट बनाने से पहले क्विज़ सूची रीफ़्रेश करके देखें।';

  @override
  String quizDraftUnconfirmed(String reason) {
    return '$reason ड्राफ़्ट सेव होने की पुष्टि नहीं हो सकी। दूसरा ड्राफ़्ट बनाने से पहले क्विज़ सूची रीफ़्रेश करें।';
  }

  @override
  String get quizSavedDraftMismatch => 'सेव किया गया ड्राफ़्ट मेल नहीं खाया।';

  @override
  String get quizDraftSaved => 'क्विज़ ड्राफ़्ट सेव हो गया।';

  @override
  String get quizAddToQuizFailed => 'प्रश्न इस क्विज़ में नहीं जोड़ा जा सका।';

  @override
  String get quizAddedToQuiz => 'प्रश्न क्विज़ में जोड़ दिया गया।';

  @override
  String get quizPublishTitle => 'क्विज़ प्रकाशित करें?';

  @override
  String quizPublishMessage(String title) {
    return '\"$title\" योग्य छात्रों के लिए प्रकाशित करें? इस क्विज़ के प्रश्न तय हो जाएँगे।';
  }

  @override
  String quizPublishMessageSnapshots(String title) {
    return '\"$title\" योग्य छात्रों के लिए प्रकाशित करें? प्रश्नों की शैक्षणिक प्रतियाँ बन जाएँगी।';
  }

  @override
  String get quizPublishConfirm => 'क्विज़ प्रकाशित करें';

  @override
  String get quizPublishUnconfirmed =>
      'प्रकाशित होने की पुष्टि नहीं हो सकी। फिर से कोशिश करने से पहले रीफ़्रेश करें और क्विज़ की स्थिति देखें।';

  @override
  String get quizPublishedNoRecipients =>
      'क्विज़ प्रकाशित हो गया। सूचना भेजने के लिए कोई योग्य छात्र नहीं है।';

  @override
  String get quizNoEligibleToNotify =>
      'सूचना भेजने के लिए कोई योग्य छात्र नहीं है।';

  @override
  String get quizPublishedNoneDelivered =>
      'क्विज़ प्रकाशित हो गया, लेकिन किसी भी छात्र के डिवाइस पर सूचना नहीं पहुँची। सूचना पंजीकरण और सर्वर के Firebase क्रेडेंशियल जाँचें।';

  @override
  String quizPublishedWithFailures(String sent, String failures) {
    return 'क्विज़ प्रकाशित हो गया। $sent डिवाइस सूचनाएँ भेजी गईं और $failures विफल रहीं।';
  }

  @override
  String quizPublishedSent(String sent) {
    return 'क्विज़ प्रकाशित हो गया। $sent डिवाइस सूचनाएँ भेजी गईं।';
  }

  @override
  String get quizCloseTitle => 'क्विज़ बंद करें?';

  @override
  String quizCloseMessage(String title) {
    return '\"$title\" बंद करें? कोई नया प्रयास शुरू नहीं हो सकेगा और चल रहे प्रयास पूरे कर दिए जाएँगे।';
  }

  @override
  String quizCloseMessageFinalized(String title) {
    return '\"$title\" बंद करें? कोई नया प्रयास शुरू नहीं हो सकेगा और चल रहे प्रयास अंतिम कर दिए जाएँगे।';
  }

  @override
  String get quizCloseConfirm => 'क्विज़ बंद करें';

  @override
  String get quizCloseFailed => 'क्विज़ बंद नहीं हो सका।';

  @override
  String get quizClosed => 'क्विज़ बंद हो गया।';

  @override
  String get quizDuplicateQuizFailed => 'क्विज़ की कॉपी नहीं बन सकी।';

  @override
  String get quizQuizDuplicated => 'बदलने लायक क्विज़ ड्राफ़्ट बन गया।';

  @override
  String get quizDraftAccountChanged =>
      'आपका खाता बदल गया है। यह ड्राफ़्ट यहाँ नहीं देखा जा सकता।';

  @override
  String get quizDraftLoadFailed =>
      'ड्राफ़्ट या प्रश्न बैंक लोड नहीं हो सका। आगे बढ़ने से पहले रीफ़्रेश करें।';

  @override
  String quizBankRefreshFailed(String reason) {
    return '$reason प्रश्न बैंक रीफ़्रेश नहीं हो सका। कोई प्रश्न नहीं जोड़ा गया। फिर से सहेजा हुआ प्रश्न चुनें।';
  }

  @override
  String get quizSavedListUnreadable =>
      'सहेजे गए प्रश्नों की सूची पढ़ी नहीं जा सकी।';

  @override
  String get quizNoUnusedQuestions =>
      'इस वर्कस्पेस में कोई बिना इस्तेमाल किया प्रश्न नहीं है। प्रश्न लिखें चुनें।';

  @override
  String get quizAllSavedQuestionsUsed =>
      'हर सहेजा हुआ प्रश्न पहले से इस क्विज़ में है। प्रश्न लिखें चुनें।';

  @override
  String get quizChooseSaved => 'सहेजा हुआ प्रश्न चुनें';

  @override
  String quizSavedQuestionFrom(
    String question,
    String className,
    String subjectName,
  ) {
    return '$question। $className, $subjectName से';
  }

  @override
  String get quizAnotherClass => 'दूसरी कक्षा';

  @override
  String get quizAnotherSubject => 'दूसरा विषय';

  @override
  String quizAddUnconfirmed(String reason) {
    return '$reason प्रश्न जोड़ने की पुष्टि नहीं हो सकी। फिर से जोड़ने से पहले रीफ़्रेश करें और सहेजे गए प्रश्न देखें; हो सकता है यह पहले से सहेजा गया हो।';
  }

  @override
  String get quizQuestionAddedSentence => 'प्रश्न जोड़ा गया।';

  @override
  String get quizAddAnotherOrReview => 'एक और जोड़ें या समीक्षा चुनें।';

  @override
  String quizQuestionsSaved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count प्रश्न सहेजे गए।',
      one: '1 प्रश्न सहेजा गया।',
    );
    return '$_temp0';
  }

  @override
  String quizQuestionsSavedRaw(String count) {
    return '$count प्रश्न सहेजे गए।';
  }

  @override
  String quizDraftSummaryHead(
    String title,
    String description,
    String questions,
  ) {
    return '$title। $description $questions।';
  }

  @override
  String quizDraftSummaryHeadRaw(
    String title,
    String description,
    String count,
  ) {
    return '$title। $description $count प्रश्न।';
  }

  @override
  String get quizUngradedPracticeSummary =>
      'बिना अंक वाला अभ्यास। असीमित प्रयास। कोई टाइमर नहीं।';

  @override
  String quizGradedSummary(String attempts) {
    return 'अंक वाला क्विज़। $attempts।';
  }

  @override
  String quizGradedSummaryRaw(String count) {
    return 'अंक वाला क्विज़। $count प्रयास।';
  }

  @override
  String get quizNoTimer => 'कोई टाइमर नहीं।';

  @override
  String quizPerAttempt(String duration) {
    return 'हर प्रयास के लिए $duration।';
  }

  @override
  String quizMinutesPerAttemptRaw(String minutes) {
    return 'हर प्रयास के लिए $minutes मिनट।';
  }

  @override
  String quizOpensSentence(String when) {
    return '$when खुलेगा।';
  }

  @override
  String quizOpensColon(String value) {
    return 'खुलने का समय: $value।';
  }

  @override
  String quizClosesColon(String value) {
    return 'बंद होने का समय: $value।';
  }

  @override
  String get quizWhenPublished => 'प्रकाशित होने पर';

  @override
  String get quizNeverNotScheduled => 'कभी नहीं, तय नहीं है';

  @override
  String get quizNotScheduled => 'तय नहीं है';

  @override
  String quizShuffleQuestionsState(String state) {
    return 'प्रश्नों का क्रम बदलना $state।';
  }

  @override
  String quizShuffleOptionsState(String state) {
    return 'विकल्पों का क्रम बदलना $state।';
  }

  @override
  String quizShuffleQuestionsColon(String state) {
    return 'प्रश्नों का क्रम बदलना: $state।';
  }

  @override
  String quizShuffleOptionsColon(String state) {
    return 'विकल्पों का क्रम बदलना: $state।';
  }

  @override
  String get quizRemoveChoose => 'इस ड्राफ़्ट से हटाने के लिए प्रश्न चुनें';

  @override
  String quizRemoveOption(String number, String text) {
    return 'प्रश्न $number: $text';
  }

  @override
  String get quizRemoveTitle => 'चुना गया प्रश्न हटाएँ?';

  @override
  String get quizRemoveMessage =>
      'इस प्रश्न को ड्राफ़्ट से हटाएँ? दोबारा इस्तेमाल होने वाला प्रश्न बैंक नहीं बदलेगा।';

  @override
  String get quizRemoveConfirm => 'प्रश्न हटाएँ';

  @override
  String get quizRemoveUnconfirmed =>
      'हटाने की पुष्टि नहीं हो सकी। फिर से कोशिश करने से पहले रीफ़्रेश हुआ ड्राफ़्ट देखें।';

  @override
  String get quizQuestionRemovedSentence => 'प्रश्न ड्राफ़्ट से हटा दिया गया।';

  @override
  String get quizSettingsUnconfirmed =>
      'सेटिंग्स सहेजने की पुष्टि नहीं हो सकी। प्रकाशित करने से पहले रीफ़्रेश करें और सहेजी गई सेटिंग्स देखें।';

  @override
  String get quizSettingsSaved =>
      'क्विज़ सेटिंग्स सहेजी गईं। प्रकाशित करने से पहले इन्हें देखें।';

  @override
  String quizSavedQuestion(String number, String text) {
    return 'सहेजा गया प्रश्न $number: $text। पहले से इस ड्राफ़्ट में है। इसके विकल्प सुनने के लिए ओके दबाएँ';
  }

  @override
  String quizQuestionNumbered(String number, String text) {
    return 'प्रश्न $number। $text।';
  }

  @override
  String quizDraftOption(String number, String text) {
    return 'विकल्प $number: $text।';
  }

  @override
  String quizDraftOptionCorrect(String number, String text) {
    return 'विकल्प $number: $text, सही उत्तर।';
  }

  @override
  String get quizReviewingBeforePublishing =>
      'प्रकाशित करने से पहले समीक्षा हो रही है।';

  @override
  String get quizAddingQuestions => 'प्रश्न जोड़े जा रहे हैं।';

  @override
  String get quizRefreshSavedDraft => 'सहेजा गया ड्राफ़्ट रीफ़्रेश करें';

  @override
  String get quizWriteQuestionTarget =>
      'प्रश्न लिखें और इसे इस क्विज़ और अपने प्रश्न बैंक में सहेजें';

  @override
  String get quizReviewBeforePublishingTarget =>
      'प्रकाशित करने से पहले प्रश्न और क्विज़ सेटिंग्स देखें';

  @override
  String get quizRemoveQuestionTarget =>
      'पुष्टि के साथ इस ड्राफ़्ट से प्रश्न हटाएँ';

  @override
  String get quizChangeSettingsTarget =>
      'शीर्षक या वैकल्पिक क्विज़ सेटिंग्स बदलें';

  @override
  String get quizBackToAdding => 'प्रश्न जोड़ने पर वापस जाएँ';

  @override
  String get quizPublishWithConfirmation =>
      'पुष्टि के साथ क्विज़ प्रकाशित करें';

  @override
  String get quizSaveForLaterTarget =>
      'बाद के लिए सहेजें और वापस जाएँ। पुष्टि हुए बदलाव पहले से ड्राफ़्ट में सहेजे गए हैं';

  @override
  String get quizDraftNavigationReview =>
      'सहेजे गए प्रश्न, क्विज़ सेटिंग्स, और पुष्टि के साथ प्रकाशन';

  @override
  String get quizDraftNavigationAdd =>
      'प्रश्न लिखें या सहेजे गए प्रश्न चुनें, प्रश्न हटाएँ, और ड्राफ़्ट की समीक्षा करें';

  @override
  String get quizPublishedScreen => 'क्विज़ प्रकाशित हुआ';

  @override
  String get quizDraftStep3 =>
      'चरण 3, कुल 3 में से। प्रकाशित करने से पहले समीक्षा करें। आपकी पुष्टि के बिना कुछ भी प्रकाशित नहीं होगा।';

  @override
  String get quizDraftStep2 =>
      'चरण 2, कुल 3 में से। प्रश्न जोड़ें। लिखें या सहेजा हुआ प्रश्न इस्तेमाल करें चुनें। फिर समीक्षा करें।';

  @override
  String get quizSaveForLater => 'बाद के लिए सहेजें और वापस जाएँ';

  @override
  String get quizWriteQuestion => 'प्रश्न लिखें';

  @override
  String get quizUseSavedQuestion => 'सहेजा हुआ प्रश्न इस्तेमाल करें';

  @override
  String get quizRemoveQuestion => 'प्रश्न हटाएँ';

  @override
  String get quizReview => 'समीक्षा';

  @override
  String get quizPublishConfirmLabel => 'पुष्टि के साथ प्रकाशित करें';

  @override
  String get quizChangeSettingsLabel => 'शीर्षक या वैकल्पिक सेटिंग्स बदलें';

  @override
  String quizResultsScreen(String title) {
    return '$title के नतीजे';
  }

  @override
  String get quizResultsNavigation =>
      'क्विज़ सारांश, छात्रों के नतीजे, और उपलब्ध नतीजा विकल्प';

  @override
  String get quizResultsFailed => 'क्विज़ के नतीजे लोड नहीं हो सके।';

  @override
  String quizStudentsCompleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count छात्रों ने पूरा किया।',
      one: '1 छात्र ने पूरा किया।',
    );
    return '$_temp0';
  }

  @override
  String quizStudentsNotAttemptedYet(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count छात्रों ने अभी तक प्रयास नहीं किया।',
      one: '1 छात्र ने अभी तक प्रयास नहीं किया।',
    );
    return '$_temp0';
  }

  @override
  String quizResultsLoadedRaw(String completed, String notAttempted) {
    return '$completed छात्रों ने पूरा किया। $notAttempted छात्रों ने प्रयास नहीं किया है।';
  }

  @override
  String quizStatEligible(String value) {
    return 'योग्य: $value';
  }

  @override
  String quizStatStarted(String value) {
    return 'शुरू किया: $value';
  }

  @override
  String quizStatCompleted(String value) {
    return 'पूरा किया: $value';
  }

  @override
  String quizStatNotAttempted(String value) {
    return 'प्रयास नहीं किया: $value';
  }

  @override
  String quizStatCompletion(String value) {
    return 'पूरा होना: $value';
  }

  @override
  String quizStatCompletionPercent(String value) {
    return 'पूरा होना: $value प्रतिशत';
  }

  @override
  String get quizPracticeParticipation =>
      'अभ्यास में भागीदारी, शैक्षणिक अंक नहीं।';

  @override
  String quizStatAverageHighest(String value) {
    return 'औसत सबसे ज़्यादा स्कोर: $value';
  }

  @override
  String quizStatLowest(String value) {
    return 'पूरे हुए प्रयासों में सबसे कम स्कोर: $value';
  }

  @override
  String quizStudentNotAttempted(String name) {
    return '$name ने यह क्विज़ अभी तक नहीं दिया है।';
  }

  @override
  String quizStudentPractice(int count, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$name। $count अभ्यास प्रयास। शैक्षणिक अंक नहीं।',
      one: '$name। 1 अभ्यास प्रयास। शैक्षणिक अंक नहीं।',
    );
    return '$_temp0';
  }

  @override
  String quizStudentPracticeRaw(String name, String count) {
    return '$name। $count अभ्यास प्रयास। शैक्षणिक अंक नहीं।';
  }

  @override
  String quizStudentAttemptScore(String number, String score, String status) {
    return 'प्रयास $number, $score, $status';
  }

  @override
  String quizStudentAttemptRaw(String number, String score, String status) {
    return 'प्रयास $number, $score प्रतिशत, $status';
  }

  @override
  String quizStudentScores(String name, String highest, String scores) {
    return '$name। सबसे ज़्यादा स्कोर $highest। $scores।';
  }

  @override
  String quizStudentScoresRaw(String name, String highest, String scores) {
    return '$name। सबसे ज़्यादा स्कोर $highest प्रतिशत। $scores।';
  }

  @override
  String get quizExtraMismatch =>
      'अतिरिक्त समय की पुष्टि मेल नहीं खाई। फिर से कोशिश करने से पहले रीफ़्रेश करें।';

  @override
  String get quizExtraSaved =>
      'अतिरिक्त समय की पुष्टि सिर्फ़ आगे के प्रयासों के लिए हुई। मौजूदा प्रयासों की समय-सीमा नहीं बदली है और क्विज़ बंद होने का समय अब भी लागू है।';

  @override
  String get quizEveryoneAttempted => 'हर योग्य छात्र ने यह क्विज़ दे दिया है।';

  @override
  String get quizRemindTitle => 'छात्रों को याद दिलाएँ?';

  @override
  String quizRemindMessage(int count, String title) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$title का प्रयास न करने वाले सभी $count छात्रों को एक क्विज़ रिमाइंडर भेजें?',
      one: '$title का प्रयास न करने वाले 1 छात्र को एक क्विज़ रिमाइंडर भेजें?',
    );
    return '$_temp0';
  }

  @override
  String quizRemindMessageRaw(String count, String title) {
    return '$title का प्रयास न करने वाले सभी $count छात्रों को एक क्विज़ रिमाइंडर भेजें?';
  }

  @override
  String get quizRemindConfirm => 'रिमाइंडर भेजें';

  @override
  String get quizRemindFailed => 'क्विज़ रिमाइंडर नहीं भेजे जा सके।';

  @override
  String quizReminded(String notified, String queued) {
    return '$notified छात्रों को रिमाइंडर भेजा गया। $queued डिवाइस सूचनाएँ कतार में हैं।';
  }

  @override
  String quizReminderProcessed(String notified, String queued) {
    return '$notified छात्रों के लिए रिमाइंडर प्रोसेस हुआ। $queued डिवाइस सूचनाएँ कतार में हैं।';
  }

  @override
  String get quizRefreshResults => 'क्विज़ के नतीजे रीफ़्रेश करें';

  @override
  String get quizRefreshResultsLabel => 'नतीजे रीफ़्रेश करें';

  @override
  String get quizRemindAllLabel =>
      'प्रयास न करने वाले सभी छात्रों को याद दिलाएँ';

  @override
  String get quizRemindUnavailable =>
      'सभी छात्रों ने प्रयास कर लिया है। रिमाइंडर उपलब्ध नहीं';

  @override
  String quizRemindTarget(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'प्रयास न करने वाले सभी $count छात्रों को रिमाइंडर भेजें',
      one: 'प्रयास न करने वाले 1 छात्र को रिमाइंडर भेजें',
    );
    return '$_temp0';
  }

  @override
  String quizRemindTargetRaw(String count) {
    return 'प्रयास न करने वाले सभी $count छात्रों को रिमाइंडर भेजें';
  }

  @override
  String quizExtraTarget(String name, String duration) {
    return '$name के लिए अतिरिक्त समय तय करें। सिर्फ़ आगे के प्रयासों के लिए। अभी का अतिरिक्त समय $duration';
  }

  @override
  String quizExtraTargetRaw(String name, String minutes) {
    return '$name के लिए अतिरिक्त मिनट तय करें। सिर्फ़ आगे के प्रयासों के लिए। अभी अतिरिक्त $minutes मिनट';
  }

  @override
  String quizExtraButton(String minutes) {
    return 'आगे के लिए अतिरिक्त समय: $minutes मिनट। तय करें';
  }

  @override
  String get quizResultsNotLoaded => 'नतीजे लोड नहीं हुए।';

  @override
  String quizCompletionSentence(String percent) {
    return 'पूरा होना $percent।';
  }

  @override
  String quizExtraScreen(String name) {
    return '$name के लिए अतिरिक्त समय। सिर्फ़ आगे के प्रयासों के लिए; चल रहे प्रयासों की समय-सीमा नहीं बदलेगी। क्विज़ बंद होने का समय अब भी लागू है। शून्य मिनट डालने पर अतिरिक्त समय हट जाएगा। रद्द करने के लिए फ़ील्ड के बाहर 0 दबाएँ।';
  }

  @override
  String quizExtraField(String value) {
    return 'अतिरिक्त मिनट, अभी $value। बदलने के लिए ओके दबाएँ';
  }

  @override
  String get quizEmpty => 'खाली';

  @override
  String get quizExtraSave => 'आगे के प्रयासों के लिए अतिरिक्त समय सहेजें';

  @override
  String get quizExtraCancel => 'अतिरिक्त समय बदले बिना रद्द करें';

  @override
  String get quizExtraInvalid =>
      'मिनट की पूरी संख्या डालें, शून्य या उससे ज़्यादा, जो सर्वर की संख्या सीमा के अंदर हो।';

  @override
  String get quizExtraCorrect =>
      'इसे ठीक करने के लिए ऊपर अतिरिक्त मिनट पर जाएँ।';

  @override
  String get quizEditorInvalid =>
      'एक प्रश्न, चार अलग-अलग भरे हुए विकल्प डालें, और फिर सही उत्तर चुनें।';

  @override
  String get quizEditorSpokenInvalid =>
      'ज़्यादा से ज़्यादा 20 अलग-अलग टॉपिक इस्तेमाल करें, हर एक में 80 अक्षर तक। बताए गए संकेतन के लिए बोला जाने वाला प्रश्न, चारों बोले जाने वाले विकल्प, और अगर व्याख्या दी गई है तो बोली जाने वाली व्याख्या चाहिए। सहेजने से पहले हर बोले जाने वाले विकल्प को देखें और पुष्टि करें।';

  @override
  String quizCorrectChosen(String number, String count) {
    return 'सही उत्तर: विकल्प $number, $count में से $number।';
  }

  @override
  String quizCorrectChosenWithText(String number, String text, String count) {
    return 'सही उत्तर: विकल्प $number, $text, $count में से $number।';
  }

  @override
  String get quizCorrectNotSelected =>
      'सही उत्तर नहीं चुना गया। चुनने के लिए बाएँ या दाएँ का इस्तेमाल करें';

  @override
  String quizCorrectTarget(String number, String text) {
    return 'सही उत्तर: विकल्प $number, $text। बदलने के लिए बाएँ या दाएँ का इस्तेमाल करें';
  }

  @override
  String quizToggled(String name, String state) {
    return '$name $state।';
  }

  @override
  String get quizContentDescribed =>
      'सामग्री: शिक्षक द्वारा बताया गया संकेतन या चित्र';

  @override
  String get quizContentPlain => 'सामग्री: अंग्रेज़ी सादा टेक्स्ट';

  @override
  String get quizReviewedYes => 'बोले जाने वाले विकल्प शिक्षक ने देखे: हाँ';

  @override
  String get quizReviewedNo => 'बोले जाने वाले विकल्प शिक्षक ने देखे: नहीं';

  @override
  String get quizSettingsInvalid =>
      'शीर्षक, 1 से 20 तक प्रयास सीमा, समय सीमा, और समय-सारणी जाँचें। बंद होने का समय खुलने के समय के बाद होना चाहिए।';

  @override
  String get quizSetOpening =>
      'तारीख और समय के संख्या फ़ील्ड से खुलने का समय तय करें।';

  @override
  String get quizSetClosing =>
      'तारीख और समय के संख्या फ़ील्ड से बंद होने का समय तय करें।';

  @override
  String quizOpeningSet(String when) {
    return 'खुलने का समय $when तय किया गया।';
  }

  @override
  String quizClosingSet(String when) {
    return 'बंद होने का समय $when तय किया गया।';
  }

  @override
  String quizReleaseSet(String when) {
    return 'फ़ीडबैक जारी होने का समय $when तय किया गया।';
  }

  @override
  String get quizOpeningCleared => 'खुलने का समय हटा दिया गया।';

  @override
  String get quizClosingCleared => 'बंद होने का समय हटा दिया गया।';

  @override
  String get quizNoOpeningTime => 'खुलने का कोई समय तय नहीं है';

  @override
  String get quizNoClosingTime => 'बंद होने का कोई समय तय नहीं है';

  @override
  String quizOpensAt(String when) {
    return '$when खुलेगा';
  }

  @override
  String quizClosesAt(String when) {
    return '$when बंद होगा';
  }

  @override
  String quizPolicyChoice(String name, String position, String count) {
    return 'फ़ीडबैक: $name, $count में से $position।';
  }

  @override
  String quizScheduledRelease(String when) {
    return 'फ़ीडबैक $when जारी होगा';
  }

  @override
  String quizAttemptLimitField(String value) {
    return 'प्रयास सीमा, अभी $value। बदलने के लिए ओके दबाएँ';
  }

  @override
  String quizTimeLimitField(String value) {
    return 'वैकल्पिक समय सीमा मिनटों में, $value। बदलने के लिए ओके दबाएँ';
  }

  @override
  String get quizRevisionsScreen =>
      'प्रश्न में हुए बदलावों का निजी इतिहास, सिर्फ़ पढ़ने के लिए। पुराने और नए बदलाव वाले बटन इस्तेमाल करें, फिर हर भाग पढ़ें।';

  @override
  String get quizRevisionsAccount =>
      'आपका खाता बदल गया है। प्रश्न का निजी इतिहास देखने से पहले वापस जाएँ और फिर से साइन इन करें।';

  @override
  String get quizRevisionsCleared =>
      'आपका खाता बदल गया है। प्रश्न का निजी इतिहास हटा दिया गया।';

  @override
  String get quizRevisionsUnverified =>
      'प्रश्न के बदलावों के इतिहास की जाँच नहीं हो सकी। फिर से लोड करें।';

  @override
  String get quizRevisionsContentUnverified =>
      'प्रश्न के बदलाव की सामग्री की जाँच नहीं हो सकी। फिर से लोड करें।';

  @override
  String get quizRevisionsTimedOut =>
      'प्रश्न का इतिहास लाने में बहुत समय लगा। अपना कनेक्शन जाँचें और फिर से कोशिश करें।';

  @override
  String get quizNoRevisions =>
      'कोई दर्ज बदलाव नहीं। प्रश्न का पुराना इतिहास पता नहीं है, उसे दोबारा नहीं बनाया गया।';

  @override
  String quizRevisionsLoaded(int count, String revision, String when) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count बदलाव लोड हुए। प्रश्न का बदलाव $revision, सिर्फ़ पढ़ने के लिए, $when सहेजा गया। मौजूदा क्विज़ और प्रयासों की कॉपी नहीं बदली गई।',
      one:
          '1 बदलाव लोड हुआ। प्रश्न का बदलाव $revision, सिर्फ़ पढ़ने के लिए, $when सहेजा गया। मौजूदा क्विज़ और प्रयासों की कॉपी नहीं बदली गई।',
    );
    return '$_temp0';
  }

  @override
  String get quizDateUnknown => 'तारीख पता नहीं';

  @override
  String quizRevisionSelected(String revision) {
    return 'बदलाव $revision चुना गया। सिर्फ़ पढ़ने के लिए।';
  }

  @override
  String quizRevisionSelectedOf(
    String revision,
    String position,
    String count,
  ) {
    return 'बदलाव $revision चुना गया, $count में से $position। सिर्फ़ पढ़ने के लिए।';
  }

  @override
  String quizRevisionFailed(String message) {
    return '$message फ़ोकस बदलाव रीफ़्रेश करें पर है।';
  }

  @override
  String get quizNoRevisionLoaded => 'कोई बदलाव लोड नहीं हुआ।';

  @override
  String quizShowingRevision(String revision) {
    return 'बदलाव $revision दिखाया जा रहा है। सिर्फ़ पढ़ने के लिए।';
  }

  @override
  String quizRevisionVersion(String revision, String when) {
    return 'बदलाव $revision। $when सहेजा गया। सिर्फ़ पढ़ने के लिए।';
  }

  @override
  String quizRevisionQuestion(String text) {
    return 'प्रश्न: $text';
  }

  @override
  String quizRevisionTopics(String topics) {
    return 'टॉपिक: $topics';
  }

  @override
  String quizRevisionOption(String number, String text) {
    return 'विकल्प $number: $text।';
  }

  @override
  String get quizCorrectAnswerSentence => 'सही उत्तर।';

  @override
  String quizRevisionExplanation(String text) {
    return 'व्याख्या: $text';
  }

  @override
  String get quizNotProvided => 'नहीं दिया गया';

  @override
  String get quizRevisionNotice =>
      'सिर्फ़ वही बदलाव उपलब्ध हैं जो ट्रैकिंग शुरू होने के बाद सहेजे गए। पुराना इतिहास पता नहीं है। मौजूदा क्विज़ और प्रयासों की कॉपी कभी नहीं बदली जाती।';

  @override
  String quizRevisionVersionTitle(String revision, String when) {
    return 'बदलाव $revision, $when';
  }

  @override
  String get quizQuestionTextTitle => 'प्रश्न का टेक्स्ट';

  @override
  String get quizTopicsTitle => 'टॉपिक';

  @override
  String quizOptionNumber(String number) {
    return 'विकल्प $number';
  }

  @override
  String quizOptionNumberCorrect(String number) {
    return 'विकल्प $number, सही उत्तर';
  }

  @override
  String get quizExplanationTitle => 'व्याख्या';

  @override
  String get quizRevisionNoticeTitle => 'बदलावों के इतिहास के बारे में';

  @override
  String quizRevisionSectionTarget(String title) {
    return '$title। सुनने के लिए ओके दबाएँ';
  }

  @override
  String get quizAccountChangedSignIn =>
      'खाता बदल गया है। वापस जाएँ और फिर से साइन इन करें।';

  @override
  String get quizGoBack => 'वापस जाएँ';

  @override
  String get quizCancel => 'रद्द करें';

  @override
  String get quizCancelAndReturn => 'रद्द करें और वापस जाएँ';

  @override
  String get quizActionNavigation => 'उपलब्ध विकल्प और रद्द करें';

  @override
  String get quizRefreshRevisions => 'बदलाव रीफ़्रेश करें';

  @override
  String get quizNewerRevision => 'नया बदलाव';

  @override
  String get quizOlderRevision => 'पुराना बदलाव';

  @override
  String get quizBankArchived => 'बैंक का प्रश्न संग्रहित किया गया';

  @override
  String get quizBankCopied => 'बैंक के प्रश्न की कॉपी बनाई गई';

  @override
  String get quizSnapshotAdded => 'प्रश्न की कॉपी क्विज़ में जोड़ी गई';

  @override
  String get quizQuizClosed => 'क्विज़ बंद हुआ';

  @override
  String get quizDraftCreated => 'बदलने लायक क्विज़ ड्राफ़्ट बनाया गया';

  @override
  String get quizNoAnswerSelected => 'कोई उत्तर नहीं चुना गया।';

  @override
  String get quizSelectBeforeSubmit => 'जमा करने से पहले एक विकल्प चुनें।';

  @override
  String get quizSubmitBeforeContinuing =>
      'आगे बढ़ने से पहले अपना उत्तर जमा करें।';

  @override
  String get quizTeacherNavigationPrivate =>
      'निजी बैंक खोज और सहेजे गए प्रश्न, क्विज़ ड्राफ़्ट, प्रकाशित क्विज़, और उनके नतीजे';

  @override
  String get quizStudentNavigationHelp =>
      'रिफ़्रेश, क्विज़ स्थिति फ़िल्टर, विषय फ़िल्टर, हर उपलब्ध क्विज़ या अभ्यास गतिविधि, और उसके प्रयासों के इतिहास तक पहुँचने के लिए D-pad के ऊपर और नीचे बटन का उपयोग करें। फ़िल्टर बदलने के लिए उस पर बाएँ या दाएँ दबाएँ। क्विज़ का विवरण सुनने और उसे शुरू करने या फिर से जारी करने की पुष्टि के लिए क्विज़ पर ओके दबाएँ; पिछले प्रयास देखने के लिए प्रयासों के इतिहास पर ओके दबाएँ। फ़ोकस बदलने से कभी कोई प्रयास शुरू नहीं होता।';

  @override
  String get quizNoQuizzesAvailable => 'कोई क्विज़ उपलब्ध नहीं है।';

  @override
  String quizQuizzesAvailableRaw(String count) {
    return '$count क्विज़ उपलब्ध हैं।';
  }

  @override
  String get quizStudentNavigationSections =>
      'रिफ़्रेश, क्विज़ स्थिति और विषय फ़िल्टर, उपलब्ध क्विज़ और अभ्यास गतिविधियाँ, और पिछले प्रयास';

  @override
  String quizAttemptLimitReached(String title) {
    return '$title के प्रयासों की सीमा पूरी हो गई है। अपने अंक देखने के लिए प्रयासों का इतिहास खोलें।';
  }

  @override
  String get quizNoPerAttemptLimit => 'हर प्रयास के लिए कोई समय सीमा नहीं है।';

  @override
  String quizTimeLimitRaw(String minutes) {
    return 'समय सीमा $minutes मिनट।';
  }

  @override
  String get quizCannotGoBack => 'आप इसे बदलने के लिए वापस नहीं जा सकते।';

  @override
  String get quizStartFailedAvailability =>
      'क्विज़ शुरू नहीं हो सका। देखें कि यह उपलब्ध है या नहीं।';

  @override
  String get quizStateFieldName => 'क्विज़ की स्थिति';

  @override
  String get quizSubjectFieldName => 'विषय';

  @override
  String quizUseLeftRightToChange(String item) {
    return '$item। बदलने के लिए बाएँ या दाएँ दबाएँ';
  }

  @override
  String get quizAttemptCompletePrivate =>
      'प्रयास पूरा हुआ। आपका परिणाम निजी रहेगा।';

  @override
  String get quizHelpCompleted =>
      'क्विज़ पर वापस जाएँ और परिणाम निजी रूप से सुनें, इन दोनों के बीच जाने के लिए D-pad के ऊपर और नीचे बटन का उपयोग करें। बटन चलाने के लिए ओके दबाएँ। अपना परिणाम निजी रूप से सुनने के लिए 8 दबाएँ या वापस जाने के लिए 0 दबाएँ।';

  @override
  String get quizHelpRetry =>
      'पूरा करने की फिर से कोशिश के लिए 5 दबाएँ, आप कहाँ हैं यह सुनने के लिए 8 दबाएँ, या पुष्टि के साथ बाहर निकलने के लिए 0 दबाएँ। बाकी नियंत्रणों के लिए D-pad के ऊपर और नीचे बटन का उपयोग करें।';

  @override
  String get quizHelpNext =>
      'अगला प्रश्न अपने आप आएगा। दोहराने के लिए 6 दबाएँ, आप कहाँ हैं यह सुनने के लिए 8 दबाएँ।';

  @override
  String quizHelpChoose(String count) {
    return 'चुनने के लिए 1 से $count तक दबाएँ, फिर जमा करने के लिए 5 दबाएँ। प्रश्न और विकल्प दोहराने के लिए 6 दबाएँ, आप कहाँ हैं और कितना समय बचा है यह सुनने के लिए 8 दबाएँ।';
  }

  @override
  String get quizHelpFinishLeave =>
      'अभी क्विज़ पूरा करें, यह D-pad सूची में है और पुष्टि माँगता है। बिना जमा किए बाहर निकलने के लिए 0 दबाएँ।';

  @override
  String quizSelectedOptionNotSubmitted(String number, String text) {
    return 'विकल्प $number चुना गया। $text। अभी जमा नहीं हुआ।';
  }

  @override
  String quizSelectedOptionConfirmed(String number, String text) {
    return 'विकल्प $number चुना गया। $text। उत्तर की पुष्टि हो गई।';
  }

  @override
  String quizFeedbackCorrect(String answer, String explanation) {
    return 'सही। सही उत्तर: $answer। $explanation';
  }

  @override
  String quizFeedbackIncorrect(String answer, String explanation) {
    return 'गलत। सही उत्तर: $answer। $explanation';
  }

  @override
  String quizOptionSelectedNotSubmitted(String number, String text) {
    return 'विकल्प $number। $text। चुना गया, जमा नहीं हुआ। अपना उत्तर सहेजने के लिए 5 दबाएँ।';
  }

  @override
  String get quizAttemptFinishedWhere =>
      'प्रयास पूरा हुआ। अपना परिणाम निजी रूप से सुनने के लिए 8 दबाएँ।';

  @override
  String get quizNoOptionChosenYet => 'अभी कोई विकल्प नहीं चुना गया।';

  @override
  String quizOptionChosen(String number) {
    return 'विकल्प $number चुना गया।';
  }

  @override
  String quizCompletionFailedRetry(String reason) {
    return '$reason आपके सहेजे गए उत्तर सुरक्षित हैं। परिणाम देखने के लिए पूरा करने की फिर से कोशिश करें चुनें।';
  }

  @override
  String quizAttemptStatusPrivate(String status) {
    return 'प्रयास $status। आपका परिणाम निजी है।';
  }

  @override
  String get quizEarlyCountUnconfirmed =>
      'सहेजे गए उत्तरों की मौजूदा गिनती की पुष्टि नहीं हो सकी, या यह प्रयास खत्म हो चुका है। समय से पहले कुछ भी जमा नहीं किया गया। स्थिति रिफ़्रेश करने के लिए क्विज़ सूची पर वापस जाएँ।';

  @override
  String get quizEarlyTitle => 'क्या यह प्रयास समय से पहले जमा करें?';

  @override
  String quizEarlyMessage(String count) {
    return 'सर्वर जाँच से पुष्टि हुई है कि $count प्रश्नों के उत्तर नहीं दिए गए हैं। अंतिम रूप देते समय केवल सर्वर पर सहेजे गए उत्तर ही शामिल होंगे। चुना गया पर सहेजा न गया उत्तर शामिल नहीं होगा। अंतिम रूप से जमा करने के बाद इसे न तो वापस लिया जा सकता है और न ही बदला जा सकता है। वापस जाने से कभी कुछ जमा नहीं होता।';
  }

  @override
  String get quizEarlyConfirm => 'सहेजे गए उत्तर अंतिम रूप से जमा करें';

  @override
  String get quizEarlyTimedOut =>
      'सहेजे गए उत्तरों की जाँच में समय खत्म हो गया। समय से पहले कुछ भी जमा नहीं किया गया। अपना कनेक्शन जाँचें और फिर से कोशिश करें।';

  @override
  String get quizWaitPending =>
      'बाहर निकलने से पहले बाकी उत्तर या पूरा होने की पुष्टि का इंतज़ार करें।';

  @override
  String get quizLeaveMessageServer =>
      'इससे आपका प्रयास जमा नहीं होता। केवल वही उत्तर सहेजे जाते हैं जिनकी सर्वर ने पुष्टि की है; बिना सहेजा चुनाव खो सकता है। टाइमर चलता रहेगा। फिर से जारी करना तभी हो सकता है जब तक सर्वर इस प्रयास की अनुमति देता है।';

  @override
  String get quizStayInAttempt => 'प्रयास में बने रहें';

  @override
  String get quizNextQuestionNow => 'अभी अगला प्रश्न';

  @override
  String get quizReadAllOptions => 'सभी उत्तर विकल्प पढ़ें';

  @override
  String quizOptionTargetSelectedSubmit(String number, String text) {
    return 'विकल्प $number, $text, चुना गया। चुनने के लिए ओके या $number दबाएँ। तैयार होने पर ही जमा करने के लिए 5 दबाएँ';
  }

  @override
  String quizOptionTargetNotSelectedSubmit(String number, String text) {
    return 'विकल्प $number, $text, नहीं चुना गया। चुनने के लिए ओके या $number दबाएँ। तैयार होने पर ही जमा करने के लिए 5 दबाएँ';
  }

  @override
  String get quizReadSelectionTarget =>
      'चुना गया उत्तर और सहेजने की स्थिति पढ़ें';

  @override
  String get quizStopSpeech => 'आवाज़ रोकें';

  @override
  String get quizAnswerFeedback => 'उत्तर पर फ़ीडबैक';

  @override
  String get quizAnswerConfirmedReadFeedback =>
      'उत्तर सहेजे जाने और लॉक होने की पुष्टि हो गई। फ़ीडबैक निजी रूप से सुनने के लिए ओके दबाएँ।';

  @override
  String get quizRetryCompletion => 'पूरा करने की फिर से कोशिश करें';

  @override
  String get quizViewResult => 'परिणाम देखें';

  @override
  String get quizNextQuestion => 'अगला प्रश्न';

  @override
  String get quizAttemptInProgressResume =>
      'प्रयास चल रहा है। इसे फिर से जारी करने के लिए क्विज़ सूची पर वापस जाएँ। बाहर निकलने से कुछ जमा नहीं होता।';

  @override
  String get quizReviewTimedOutShort =>
      'प्रयास की समीक्षा में समय खत्म हो गया। अपना कनेक्शन जाँचें और फिर से कोशिश करें।';

  @override
  String get quizNoScoreCurrentlyReleased =>
      'पूरे किए गए प्रयास मौजूद हैं; अभी कोई अंक जारी नहीं किया गया है।';

  @override
  String get quizHistoryScreenNavigate =>
      'प्रयासों का इतिहास। अंक निजी हैं। सारांश या किसी प्रयास पर जाकर उसकी समीक्षा करें।';

  @override
  String quizHistoryAttemptRaw(String number, String status, String result) {
    return 'प्रयास $number। $status। $result। समीक्षा के लिए ओके दबाएँ।';
  }

  @override
  String quizReviewAnswerCorrect(
    String number,
    String question,
    String selected,
    String answer,
    String explanation,
  ) {
    return 'प्रश्न $number। सही। $question। चुना गया $selected। सही उत्तर $answer। $explanation';
  }

  @override
  String quizReviewAnswerIncorrect(
    String number,
    String question,
    String selected,
    String answer,
    String explanation,
  ) {
    return 'प्रश्न $number। गलत। $question। चुना गया $selected। सही उत्तर $answer। $explanation';
  }

  @override
  String get quizNoAnswerCapital => 'कोई उत्तर नहीं';

  @override
  String quizReviewScreenRaw(String count) {
    return 'प्रयास की समीक्षा। $count प्रश्न। हर उत्तर की समीक्षा के लिए ऊपर और नीचे बटन का उपयोग करें।';
  }

  @override
  String get quizMetaTopics =>
      'टॉपिक या अवधारणाएँ, हर पंक्ति में एक (वैकल्पिक)';

  @override
  String get quizMetaSpokenQuestion =>
      'शिक्षक द्वारा लिखा गया बोला जाने वाला प्रश्न';

  @override
  String quizMetaSpokenOption(String number) {
    return 'बोला जाने वाला विकल्प $number';
  }

  @override
  String get quizMetaSpokenExplanation =>
      'शिक्षक द्वारा लिखी गई बोली जाने वाली व्याख्या';

  @override
  String quizCorrectSelected(String number) {
    return 'विकल्प $number सही उत्तर के रूप में चुना गया';
  }

  @override
  String quizCorrectSelectedWithText(String number, String text) {
    return 'विकल्प $number सही उत्तर के रूप में चुना गया, $text';
  }

  @override
  String get quizEditBankQuestion => 'बैंक प्रश्न बदलें';

  @override
  String get quizCreateBankQuestion => 'बैंक प्रश्न बनाएँ';

  @override
  String get quizEditorNavigation =>
      'प्रश्न का टेक्स्ट, चार उत्तर फ़ील्ड, सही उत्तर का चुनाव, वैकल्पिक बोले जाने वाले विवरण, और सहेजें या रद्द करें';

  @override
  String get quizSaveQuestion => 'प्रश्न सहेजें';

  @override
  String get quizCancelQuestion => 'प्रश्न रद्द करें';

  @override
  String quizPressOkToEdit(String item) {
    return '$item। बदलने के लिए ओके दबाएँ';
  }

  @override
  String quizPressOkToChange(String item) {
    return '$item। बदलने के लिए ओके दबाएँ';
  }

  @override
  String quizCorrectIsOption(String number, String text) {
    return 'विकल्प $number, $text, सही उत्तर है। बदलने के लिए बाएँ या दाएँ दबाएँ';
  }

  @override
  String get quizHideOptionalExplanation =>
      'वैकल्पिक व्याख्या, टॉपिक और बोला जाने वाला नोटेशन छिपाएँ';

  @override
  String get quizShowOptionalExplanation =>
      'वैकल्पिक व्याख्या, टॉपिक और बोला जाने वाला नोटेशन दिखाएँ';

  @override
  String get quizOptionalExplanation => 'उत्तर की वैकल्पिक व्याख्या';

  @override
  String quizNumericDateTime(
    String day,
    String month,
    String year,
    String hour,
    String minute,
  ) {
    return '$day/$month/$year को $hour:$minute बजे';
  }

  @override
  String get quizCheckTitleLimits => 'शीर्षक, सीमाएँ और समय-सारणी जाँचें।';

  @override
  String get quizSettingsNavigation =>
      'शीर्षक, वैकल्पिक विवरण, समय और प्रयास की सेटिंग्स, फ़ीडबैक और क्रम बदलने के विकल्प, और आगे बढ़ें या रद्द करें';

  @override
  String get quizChangeSettingsScreen =>
      'क्विज़ का शीर्षक और वैकल्पिक सेटिंग्स बदलें। सहेजने से क्विज़ प्रकाशित नहीं होता।';

  @override
  String get quizCreatePracticeScreen =>
      'बिना समय सीमा और बिना अंक वाला अभ्यास बनाएँ। असीमित बार फिर से कोशिश और तुरंत फ़ीडबैक।';

  @override
  String get quizContinueToQuestions => 'प्रश्नों पर आगे बढ़ें';

  @override
  String get quizSaveSettingsReturn =>
      'सेटिंग्स सहेजें और समीक्षा पर वापस जाएँ';

  @override
  String get quizQuizTitle => 'क्विज़ का शीर्षक';

  @override
  String get quizHideOptionalSettings =>
      'वैकल्पिक सेटिंग्स छिपाएँ: विवरण, प्रयास, समय, फ़ीडबैक और क्रम बदलना';

  @override
  String get quizShowOptionalSettings =>
      'वैकल्पिक सेटिंग्स दिखाएँ: विवरण, प्रयास, समय, फ़ीडबैक और क्रम बदलना';

  @override
  String get quizOptionalDescription => 'क्विज़ का वैकल्पिक विवरण';

  @override
  String quizSetOrClear(String item) {
    return '$item। सेट करने के लिए ओके दबाएँ। हटाने के लिए बाएँ दबाएँ';
  }

  @override
  String quizShuffleQuestionsToggle(String state) {
    return 'प्रश्नों का क्रम बदलना $state। बदलने के लिए ओके या बाएँ या दाएँ दबाएँ';
  }

  @override
  String quizShuffleOptionsToggle(String state) {
    return 'उत्तर विकल्पों का क्रम बदलना $state। बदलने के लिए ओके या बाएँ या दाएँ दबाएँ';
  }

  @override
  String get quizCancelQuizCreation => 'क्विज़ बनाना रद्द करें';

  @override
  String quizFeedbackPolicyTarget(String policy) {
    return 'फ़ीडबैक नीति $policy। बाएँ या दाएँ से इसे बदलें';
  }

  @override
  String get quizSaveDraftContinue =>
      'ड्राफ़्ट सहेजें और प्रश्नों पर आगे बढ़ें';

  @override
  String get sessionScreenTeacherClass => 'शिक्षक की कक्षा';

  @override
  String get sessionScreenClass => 'कक्षा';

  @override
  String get sessionDefaultTitle => 'सत्र';

  @override
  String get sessionJoining => 'कक्षा से जुड़ रहे हैं। कृपया इंतज़ार करें।';

  @override
  String get sessionConnecting => 'कक्षा से कनेक्ट हो रहे हैं।';

  @override
  String get sessionJoinFailed =>
      'कक्षा से नहीं जुड़ सके। बाहर निकलने के लिए 0 दबाएँ, फिर से कोशिश करें।';

  @override
  String get sessionLeaveKeyHint =>
      'कक्षा छोड़ने के लिए 0 दबाएँ। यह पुष्टि माँगेगा।';

  @override
  String get sessionKeyLine => '*: मदद और पिछला संदेश। #: आवाज़ रोकें।';

  @override
  String sessionJoinedBrief(String status) {
    return 'कक्षा में हैं। $status मदद के लिए स्टार दबाएँ।';
  }

  @override
  String sessionJoinedDetailed(String status, String keys) {
    return 'आप कक्षा में हैं। $status $keys नियंत्रणों के बीच जाने के लिए ऊपर और नीचे, और चुनने के लिए ओके दबाएँ। आप कहाँ हैं और मदद के लिए स्टार दबाएँ। आवाज़ रोकने के लिए हैश दबाएँ।';
  }

  @override
  String sessionPressKeyFor(String key, String action) {
    return '$action के लिए $key दबाएँ।';
  }

  @override
  String get sessionMicWaitingLabel =>
      'माइक्रोफ़ोन पुष्टि का इंतज़ार कर रहा है';

  @override
  String get sessionUnmuteMicrophone => 'माइक्रोफ़ोन अनम्यूट करें';

  @override
  String get sessionMuteMicrophone => 'माइक्रोफ़ोन म्यूट करें';

  @override
  String get sessionMuteButtonWaiting => '1: इंतज़ार';

  @override
  String get sessionMuteButtonUnmute => '1: अनम्यूट';

  @override
  String get sessionMuteButtonMute => '1: म्यूट';

  @override
  String get sessionHandWaitingLabel =>
      'हाथ की स्थिति पुष्टि का इंतज़ार कर रही है';

  @override
  String get sessionLowerHand => 'हाथ नीचे करें';

  @override
  String get sessionRaiseHand => 'हाथ उठाएँ';

  @override
  String get sessionHandButtonWaiting => '2: इंतज़ार';

  @override
  String get sessionHandButtonLower => '2: हाथ नीचे करें';

  @override
  String get sessionHandButtonRaise => '2: हाथ उठाएँ';

  @override
  String get sessionStatusLabel => 'कक्षा की स्थिति सुनें';

  @override
  String get sessionStatusButton => '3: कक्षा की स्थिति';

  @override
  String sessionChatLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'चैट। $count संदेश',
      one: 'चैट। 1 संदेश',
      zero: 'चैट। अभी कोई संदेश नहीं',
    );
    return '$_temp0';
  }

  @override
  String get sessionChatButton => '4: चैट';

  @override
  String get sessionRecordingPlayerNone =>
      'पाठ की रिकॉर्डिंग। अभी कोई नहीं चुनी गई';

  @override
  String sessionRecordingPlayerPlaying(String title) {
    return 'पाठ की रिकॉर्डिंग। $title, चल रही है';
  }

  @override
  String sessionRecordingPlayerPaused(String title) {
    return 'पाठ की रिकॉर्डिंग। $title, रुकी हुई है';
  }

  @override
  String get sessionRecordingStudentNone =>
      'कक्षा की रिकॉर्डिंग। कुछ नहीं चल रहा। इसे केवल शिक्षक चलाते हैं';

  @override
  String sessionRecordingStudentPlaying(String title) {
    return 'कक्षा की रिकॉर्डिंग, $title, शिक्षक चला रहे हैं। सुनें कि यह कहाँ तक पहुँची है';
  }

  @override
  String sessionRecordingStudentPaused(String title) {
    return 'कक्षा की रिकॉर्डिंग, $title, शिक्षक ने रोकी है। सुनें कि यह कहाँ तक पहुँची है';
  }

  @override
  String get sessionRecordingStatusButton => '5: रिकॉर्डिंग की स्थिति';

  @override
  String get sessionStudentRecordingNone =>
      'कक्षा की कोई रिकॉर्डिंग नहीं चल रही है। केवल शिक्षक ही रिकॉर्डिंग चला सकते हैं।';

  @override
  String sessionStudentRecordingPlaying(String title, String position) {
    return '$title, चल रही है, $position पर। कक्षा की रिकॉर्डिंग को केवल शिक्षक ही चला, रोक या आगे-पीछे कर सकते हैं।';
  }

  @override
  String sessionStudentRecordingPaused(String title, String position) {
    return '$title, रुकी हुई है, $position पर। कक्षा की रिकॉर्डिंग को केवल शिक्षक ही चला, रोक या आगे-पीछे कर सकते हैं।';
  }

  @override
  String get sessionRecordingPlayerButton => '5: पाठ की रिकॉर्डिंग';

  @override
  String get sessionOpeningPlayerToChoose =>
      'अभी कोई रिकॉर्डिंग नहीं चुनी गई है। एक चुनने के लिए 1 दबाएँ।';

  @override
  String get sessionCheckLabel => 'शिक्षक के प्रश्न का उत्तर दें';

  @override
  String get sessionCheckButton => '3: प्रश्न का उत्तर दें';

  @override
  String sessionHandsLabel(String waiting) {
    return 'उठे हुए हाथ। $waiting';
  }

  @override
  String get sessionHandsButton => '2: उठे हुए हाथ';

  @override
  String sessionHandsButtonCount(int count) {
    return '2: उठे हुए हाथ ($count)';
  }

  @override
  String get sessionTeacherCheckLabel =>
      'कक्षा जाँच। निजी जाँच शुरू करें, उसे बंद करें और जवाब सुनें';

  @override
  String sessionParticipantsLabel(String people) {
    return 'प्रतिभागी। $people किसी को म्यूट करें या हटाएँ, या सारांश सुनें';
  }

  @override
  String get sessionParticipantsButton => '7: प्रतिभागी';

  @override
  String get sessionToolsLabel =>
      'शिक्षक टूल। समय बढ़ाएँ या सभी के लिए कक्षा खत्म करें';

  @override
  String get sessionToolsButton => '9: शिक्षक टूल';

  @override
  String get sessionVoiceStartLabel =>
      'एक आवाज़ कमांड सुनें, 12 सेकंड तक। यह तभी शुरू होता है जब आप ओके दबाते हैं';

  @override
  String get sessionVoiceStopLabel => 'आवाज़ कमांड सुनना बंद करें';

  @override
  String get sessionVoiceStartButton => 'कमांड सुनें';

  @override
  String get sessionVoiceStopButton => 'सुनना बंद करें';

  @override
  String get sessionUpdatesLabel => 'कक्षा के अपडेट पढ़ें';

  @override
  String get sessionUpdatesButton => 'कक्षा के अपडेट';

  @override
  String get sessionRetryLabel => 'कक्षा से फिर से कनेक्ट करने की कोशिश करें';

  @override
  String get sessionRetryButton => 'फिर से कनेक्ट करें';

  @override
  String get sessionLeaveLabel => 'कक्षा छोड़ें';

  @override
  String get sessionLeaveButton => '0: कक्षा छोड़ें';

  @override
  String get sessionMicWaiting => 'माइक्रोफ़ोन पुष्टि का इंतज़ार कर रहा है।';

  @override
  String get sessionMicMuted => 'म्यूट है।';

  @override
  String get sessionMicUnmutedHeard =>
      'अनम्यूट है। दूसरे लोग आपको सुन सकते हैं।';

  @override
  String get sessionHandWaiting => 'हाथ की स्थिति पुष्टि का इंतज़ार कर रही है।';

  @override
  String get sessionHandRaisedState => 'हाथ उठा हुआ है।';

  @override
  String get sessionHandDown => 'हाथ नीचे है।';

  @override
  String sessionHandsWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count हाथ इंतज़ार में हैं।',
      one: '1 हाथ इंतज़ार में है।',
      zero: 'कोई हाथ इंतज़ार में नहीं है।',
    );
    return '$_temp0';
  }

  @override
  String sessionPeople(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'कक्षा में $count लोग हैं।',
      one: 'कक्षा में 1 व्यक्ति है।',
    );
    return '$_temp0';
  }

  @override
  String get sessionNoRecordingSelected => 'कोई रिकॉर्डिंग नहीं चुनी गई।';

  @override
  String sessionRecordingStatePlaying(String title) {
    return 'रिकॉर्डिंग चल रही है: $title।';
  }

  @override
  String sessionRecordingStatePaused(String title) {
    return 'रिकॉर्डिंग रुकी हुई है: $title।';
  }

  @override
  String get sessionCheckOpen => 'कक्षा जाँच खुली है।';

  @override
  String sessionConnectionLabel(String label) {
    return '$label।';
  }

  @override
  String sessionChatMessages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count चैट संदेश।',
      one: '1 चैट संदेश।',
    );
    return '$_temp0';
  }

  @override
  String get sessionRecordingFallback => 'कक्षा की रिकॉर्डिंग';

  @override
  String get sessionRecordingFallbackLower => 'कक्षा की रिकॉर्डिंग';

  @override
  String sessionUserFallback(String id) {
    return 'उपयोगकर्ता $id';
  }

  @override
  String sessionConnectionRestored(String message) {
    return 'कनेक्शन वापस आ गया। $message';
  }

  @override
  String sessionConnectionLost(String message) {
    return 'कनेक्शन टूट गया। $message';
  }

  @override
  String sessionCouldNotConnect(String message) {
    return 'कनेक्ट नहीं हो सका। $message';
  }

  @override
  String get sessionMicDialogTitle => 'माइक्रोफ़ोन की अनुमति';

  @override
  String get sessionMicDialogMessage =>
      'इस कक्षा में SEEDS माइक्रोफ़ोन का उपयोग लाइव आवाज़ के लिए और उन आवाज़ कमांड के लिए करता है जिन्हें आप खुद चालू करते हैं। आप माइक्रोफ़ोन की अनुमति के बिना भी कक्षा में रह सकते हैं, लेकिन दूसरे लोग आपको नहीं सुन पाएँगे। निजी नोट की अलग रिकॉर्डिंग लाइव कक्षा के बाहर ही होती है और उसे आपको अलग से खुद शुरू करना होता है।';

  @override
  String get sessionMicDialogConfirm => 'कक्षा में जाएँ';

  @override
  String get sessionMicSkipped =>
      'माइक्रोफ़ोन की अनुमति छोड़ दी गई। आप म्यूट होकर कक्षा से जुड़े हैं।';

  @override
  String get sessionMicUnavailable =>
      'माइक्रोफ़ोन की अनुमति उपलब्ध नहीं है। आप म्यूट होकर कक्षा से जुड़े हैं।';

  @override
  String get sessionWaitingMic => 'माइक्रोफ़ोन की पुष्टि का इंतज़ार है।';

  @override
  String get sessionMuted => 'म्यूट';

  @override
  String get sessionUnmuted => 'अनम्यूट';

  @override
  String get sessionMutedLocallyOnly =>
      'इस फ़ोन पर माइक्रोफ़ोन म्यूट है। कक्षा से पुष्टि नहीं मिली।';

  @override
  String get sessionMutedByTeacher =>
      'शिक्षक ने आपका माइक्रोफ़ोन म्यूट कर दिया।';

  @override
  String get sessionMicClassClosed =>
      'कक्षा बंद हो गई है। माइक्रोफ़ोन से जुड़ा कोई काम नहीं भेजा गया।';

  @override
  String get sessionMicUnavailableRejoin =>
      'माइक्रोफ़ोन की अनुमति उपलब्ध नहीं है। बोलने से पहले माइक्रोफ़ोन की अनुमति जाँचें और कक्षा से फिर से जुड़ें।';

  @override
  String get sessionMicClosedBeforeConfirm =>
      'माइक्रोफ़ोन की पुष्टि से पहले ही कक्षा बंद हो गई।';

  @override
  String get sessionMicNoLongerAvailable =>
      'माइक्रोफ़ोन की अनुमति अब उपलब्ध नहीं है। बोलने से पहले कक्षा से फिर से जुड़ें।';

  @override
  String get sessionMicStayedMuted =>
      'कक्षा की म्यूट स्थिति बदलने के कारण आपका माइक्रोफ़ोन म्यूट ही रहा। जब आप बोलने के लिए तैयार हों तो अनम्यूट चुनें।';

  @override
  String get sessionWaitingHand => 'हाथ की स्थिति की पुष्टि का इंतज़ार है।';

  @override
  String get sessionHandRaised => 'हाथ उठाया गया';

  @override
  String get sessionHandLowered => 'हाथ नीचे किया गया';

  @override
  String get sessionHandNotConfirmed =>
      'आपके हाथ के बदलाव की पुष्टि नहीं हुई। फिर से कोशिश करने के लिए 2 दबाएँ।';

  @override
  String sessionRaisedHandBy(String name) {
    return '$name ने हाथ उठाया। उठे हुए हाथों के लिए 2 दबाएँ।';
  }

  @override
  String get sessionRaisedHandUnknown =>
      'एक प्रतिभागी ने हाथ उठाया। उठे हुए हाथ देखने के लिए 2 दबाएँ।';

  @override
  String get sessionParticipantJoined => 'एक प्रतिभागी जुड़े।';

  @override
  String get sessionParticipantsJoinedGroup => 'जुड़ने वाले प्रतिभागी';

  @override
  String get sessionParticipantLeft => 'एक प्रतिभागी चले गए।';

  @override
  String get sessionParticipantsLeftGroup => 'जाने वाले प्रतिभागी';

  @override
  String get sessionParticipantFallback => 'प्रतिभागी';

  @override
  String get sessionThisParticipant => 'यह प्रतिभागी';

  @override
  String sessionParticipantSelf(String name) {
    return '$name, आप';
  }

  @override
  String get sessionRoleTeacher => 'शिक्षक';

  @override
  String get sessionRoleStudent => 'छात्र';

  @override
  String get sessionStateHandRaised => 'हाथ उठा है';

  @override
  String get sessionStateMuted => 'म्यूट';

  @override
  String get sessionStateUnmuted => 'अनम्यूट';

  @override
  String get sessionStateSpeaking => 'बोल रहे हैं';

  @override
  String sessionAlreadyMuted(String name) {
    return '$name म्यूट हैं। केवल $name ही अनम्यूट कर सकते हैं।';
  }

  @override
  String sessionParticipantMuted(String name) {
    return '$name म्यूट किए गए।';
  }

  @override
  String sessionRemoveTitle(String name) {
    return '$name को हटाएँ?';
  }

  @override
  String sessionRemoveMessage(String name) {
    return '$name को इस कक्षा से हटाकर उनके डैशबोर्ड पर भेज दिया जाएगा। उन्हें बाद में फिर से बुलाया जा सकता है।';
  }

  @override
  String sessionKeep(String name) {
    return '$name को रहने दें';
  }

  @override
  String sessionRemove(String name) {
    return '$name को हटाएँ';
  }

  @override
  String sessionRemoved(String name) {
    return '$name को कक्षा से हटा दिया गया।';
  }

  @override
  String chatMessageFrom(String sender, String text) {
    return '$sender का संदेश: $text';
  }

  @override
  String get chatSenderUnknown => 'अज्ञात';

  @override
  String get chatSenderUnknownLower => 'अज्ञात';

  @override
  String get chatWaitingConfirmation => 'संदेश की पुष्टि का इंतज़ार है।';

  @override
  String get chatEmptyMessage => 'भेजें चुनने से पहले संदेश लिखें।';

  @override
  String get chatMessageSent => 'संदेश भेज दिया गया।';

  @override
  String get chatSending => 'भेजा जा रहा है';

  @override
  String get chatSent => 'भेजा गया';

  @override
  String get chatNotConfirmed => 'पुष्टि नहीं हुई';

  @override
  String get chatNoMessages => 'अभी कोई संदेश नहीं है।';

  @override
  String get chatTitle => 'चैट';

  @override
  String get chatReadMessages => 'संदेश पढ़ें, सबसे नया पहले';

  @override
  String get chatWriteMessage => 'संदेश लिखें';

  @override
  String get chatMessageField => 'कक्षा के लिए आपका संदेश';

  @override
  String get chatMessagesTitle => 'चैट संदेश';

  @override
  String get chatPhraseUnderstood => 'मैं समझ गया';

  @override
  String get chatPhraseRepeat => 'कृपया दोबारा बताइए';

  @override
  String get chatPhraseQuestion => 'मेरा एक प्रश्न है';

  @override
  String chatSendPhrase(String phrase) {
    return 'भेजें: $phrase';
  }

  @override
  String chatCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count संदेश।',
      one: '1 संदेश।',
    );
    return '$_temp0';
  }

  @override
  String get chatHelpBrief => 'संदेश पढ़ें, लिखें या कोई छोटा वाक्य भेजें।';

  @override
  String get chatHelpDetailed =>
      'संदेश पढ़ने के लिए 1 दबाएँ, लिखने के लिए 2, या कोई छोटा वाक्य भेजने के लिए 3 से 5 दबाएँ। सबसे नया संदेश सुनने के लिए 8 दबाएँ।';

  @override
  String get chatYou => 'आप';

  @override
  String chatMessageLine(String sender, String text) {
    return '$sender: $text';
  }

  @override
  String chatMessageLineDelivery(String sender, String text, String delivery) {
    return '$sender: $text। $delivery';
  }

  @override
  String chatMessageDetail(String line) {
    return '$line।';
  }

  @override
  String chatMessageDetailSent(String line, String time) {
    return '$line। $time बजे भेजा गया।';
  }

  @override
  String chatNewestMessage(String detail) {
    return 'सबसे नया संदेश। $detail';
  }

  @override
  String get chatReadLatest => 'सबसे नया संदेश पढ़ें';

  @override
  String get chatMessageLabel => 'चैट संदेश';

  @override
  String get chatSendMessage => 'संदेश भेजें';

  @override
  String chatSaid(String sender, String text) {
    return '$sender ने कहा: $text';
  }

  @override
  String chatSaidDelivery(String sender, String text, String delivery) {
    return '$sender ने कहा: $text। $delivery';
  }

  @override
  String chatLatestLineDelivery(String sender, String text, String delivery) {
    return '$sender: $text\nभेजने की स्थिति: $delivery।';
  }

  @override
  String get sessionLeaveTitle => 'कक्षा छोड़ें?';

  @override
  String get sessionLeaveMessage =>
      'आप इस कक्षा से निकलकर अपने डैशबोर्ड पर लौट जाएँगे। आप साइन इन रहेंगे।';

  @override
  String get sessionTeacherLeaveMessage =>
      'आप निकलकर अपने डैशबोर्ड पर लौट जाएँगे। छात्रों के लिए कक्षा चलती रहेगी। सबके लिए कक्षा खत्म करने के लिए 9, शिक्षक टूल्स का उपयोग करें।';

  @override
  String get sessionStay => 'कक्षा में रहें';

  @override
  String get sessionLeave => 'कक्षा छोड़ें';

  @override
  String get sessionLeaveLocallyTitle => 'सर्वर की पुष्टि के बिना निकलें?';

  @override
  String get sessionLeaveLocallyMessage =>
      'यह फ़ोन म्यूट है। सर्वर ने आपका उठा हुआ हाथ हटाने की पुष्टि नहीं की। क्या अभी इसी फ़ोन से निकलें, या रुककर फिर से कोशिश करें? दोबारा जुड़ने पर आपका हाथ अपने आप नीचे हो जाता है।';

  @override
  String get sessionStayAndRetry => 'रुकें और फिर से कोशिश करें';

  @override
  String get sessionLeaveLocally => 'इसी फ़ोन से निकलें';

  @override
  String get sessionEndTitle => 'सबके लिए कक्षा खत्म करें?';

  @override
  String get sessionEndMessage =>
      'इससे हर प्रतिभागी के लिए कक्षा बंद हो जाएगी और सभी अपने डैशबोर्ड पर लौट जाएँगे। कोई भी लॉग आउट नहीं होगा।';

  @override
  String get sessionEndCancel => 'कक्षा जारी रखें';

  @override
  String get sessionEndConfirm => 'सबके लिए खत्म करें';

  @override
  String get sessionWaitingEnd => 'कक्षा खत्म होने की पुष्टि का इंतज़ार है।';

  @override
  String get sessionEndNotConfirmed =>
      'कक्षा खत्म होने की पुष्टि नहीं हुई। कक्षा अभी चल रही है।';

  @override
  String get sessionEndingForEveryone => 'सबके लिए कक्षा खत्म की जा रही है।';

  @override
  String get sessionYouLeft => 'आपने कक्षा छोड़ दी।';

  @override
  String get sessionClassEnded => 'कक्षा खत्म हो गई है।';

  @override
  String get sessionYouWereRemoved => 'आपको कक्षा से हटा दिया गया।';

  @override
  String get sessionSignInChanged =>
      'आपका साइन इन बदल गया है। फिर से साइन इन करें या अपने स्कूल के प्रशासक से संपर्क करें।';

  @override
  String get sessionCleanupFailed =>
      'साइन इन खत्म हो गया। फ़ोन की ऑडियो सफ़ाई की पुष्टि नहीं हो सकी। अगर आवाज़ आती रहे तो SEEDS बंद करें।';

  @override
  String get sessionCleanupTimedOut =>
      'साइन इन खत्म हो गया। ऑडियो सफ़ाई का समय खत्म हो गया। अगर आवाज़ आती रहे तो SEEDS बंद करें।';

  @override
  String get sessionRequestFailed =>
      'हम यह अनुरोध पूरा नहीं कर सके। कृपया फिर से कोशिश करें।';

  @override
  String get sessionVoiceStopped => 'आवाज़ सुनना बंद हो गया।';

  @override
  String get sessionVoiceUnmuteTitle => 'अपना माइक्रोफ़ोन अनम्यूट करें?';

  @override
  String get sessionVoiceUnmuteMessage =>
      'एक आवाज़ कमांड ने अनम्यूट करने को कहा। किसी बटन या स्क्रीन छूकर पुष्टि करें। कक्षा के दूसरे सदस्य आपको सुन सकेंगे।';

  @override
  String get sessionVoiceUnmuteConfirm => 'अनम्यूट करें';

  @override
  String get sessionVoiceUnmuteCancel => 'म्यूट ही रहें';

  @override
  String get sessionAlreadyUnmuted => 'पहले से अनम्यूट है';

  @override
  String get sessionAlreadyMutedSelf => 'पहले से म्यूट है';

  @override
  String get sessionHandAlreadyLowered => 'हाथ पहले से नीचे है';

  @override
  String get sessionHandAlreadyRaised => 'हाथ पहले से उठा है';

  @override
  String get sessionCommandNotRecognized => 'कमांड समझ में नहीं आई';

  @override
  String get sessionVoiceStopUnconfirmed =>
      'आवाज़ सुनना बंद होने की पुष्टि नहीं हुई। फिर से बंद करने की कोशिश करें।';

  @override
  String get sessionVoiceStopping => 'आवाज़ सुनना बंद किया जा रहा है।';

  @override
  String get sessionVoiceStarting => 'आवाज़ कमांड शुरू हो रहे हैं।';

  @override
  String get sessionVoiceFinishing => 'आवाज़ पहचान पूरी हो रही है।';

  @override
  String get sessionVoiceListening => 'एक कमांड सुन रहे हैं, 12 सेकंड तक।';

  @override
  String get sessionVoiceIdle =>
      'अभी नहीं सुन रहे। शुरू करने के लिए कमांड सुनें चुनें।';

  @override
  String get sessionVoiceSpeechNotStopped =>
      'ऐप की आवाज़ बंद नहीं हो सकी। सुनने से पहले आवाज़ रोकें चुनें।';

  @override
  String get sessionVoiceUnavailable =>
      'आवाज़ कमांड उपलब्ध नहीं हैं। माइक्रोफ़ोन की अनुमति और Android की अंग्रेज़ी स्पीच सेवाएँ जाँचें।';

  @override
  String get sessionVoiceCouldNotStart =>
      'आवाज़ कमांड शुरू नहीं हो सके। माइक्रोफ़ोन की अनुमति और अंग्रेज़ी स्पीच सेवाएँ जाँचें, फिर से कोशिश करें।';

  @override
  String get sessionVoiceCouldNotFinish =>
      'आवाज़ पहचान पूरी नहीं हो सकी। अनुमति और अंग्रेज़ी स्पीच सेवाएँ जाँचें, फिर दोबारा कोशिश के लिए सुनें चुनें।';

  @override
  String get sessionVoiceNoCommand =>
      'कोई कमांड सुनाई नहीं दी। फिर से कोशिश करने के लिए कमांड सुनें चुनें।';

  @override
  String get sessionVoiceCommandFailed =>
      'आवाज़ कमांड पूरी नहीं हो सकी। उसका कीपैड बटन इस्तेमाल करें या फिर से कोशिश करें।';

  @override
  String get sessionVoiceCannotStop =>
      'आवाज़ सुनना बंद नहीं हो सका। सुनना बंद करें फिर से चुनें, या कक्षा छोड़कर Android का माइक्रोफ़ोन संकेत जाँचें।';

  @override
  String get sessionRecordingSelectionChanged =>
      'कक्षा की रिकॉर्डिंग का चुनाव बदल गया। जानकारी के लिए कक्षा की खबरें पढ़ें चुनें।';

  @override
  String get sessionRecordingSelectionGroup => 'कक्षा की रिकॉर्डिंग का चुनाव';

  @override
  String get sessionPlaybackFinished => 'रिकॉर्डिंग पूरी हो गई।';

  @override
  String get sessionNoRecording => 'कक्षा की कोई रिकॉर्डिंग नहीं चुनी गई है।';

  @override
  String get sessionNoRecordingTeacher =>
      'कक्षा की कोई रिकॉर्डिंग नहीं चुनी गई है। रिकॉर्डिंग प्लेयर में एक चुनने के लिए 1 दबाएँ।';

  @override
  String get sessionPreviewFailed =>
      'निजी प्रीव्यू शुरू नहीं हो सका। कनेक्शन जाँचें और फिर से कोशिश करें।';

  @override
  String sessionClassPauseUnconfirmed(String reason) {
    return 'आपके फ़ोन का ऑडियो रुका हुआ है। कक्षा के लिए रोकने की पुष्टि नहीं हुई। $reason';
  }

  @override
  String sessionSpeed(String speed) {
    return '$speed गुना गति';
  }

  @override
  String sessionPlaybackAccepted(String title) {
    return '$title को कक्षा में चलाने का अनुरोध स्वीकार हुआ।';
  }

  @override
  String sessionSelected(String title) {
    return '$title कक्षा के लिए चुनी गई। चलाने के लिए 5 दबाएँ।';
  }

  @override
  String sessionPreviewing(String title) {
    return '$title का प्रीव्यू सिर्फ़ इस फ़ोन पर चल रहा है।';
  }

  @override
  String get sessionPreviewStopped => 'प्रीव्यू बंद हो गया।';

  @override
  String get sessionRecordingsTitle => 'कक्षा रिकॉर्डिंग प्लेयर';

  @override
  String get sessionChooseRecording => 'लाइब्रेरी से एक रिकॉर्डिंग चुनें';

  @override
  String get sessionUploadRecording => 'नई रिकॉर्डिंग अपलोड करें';

  @override
  String get sessionHearRecording => 'रिकॉर्डिंग की स्थिति सुनें';

  @override
  String get sessionPlayPauseClass => 'कक्षा के लिए चलाएँ या रोकें';

  @override
  String get sessionLibraryLoading =>
      'रिकॉर्डिंग लाइब्रेरी अभी लोड हो रही है। थोड़ी देर में फिर से कोशिश करें।';

  @override
  String get sessionLibraryEmpty =>
      'इस कक्षा की अभी कोई रिकॉर्डिंग नहीं है। एक अपलोड करने के लिए 2 दबाएँ।';

  @override
  String get sessionPositionHint =>
      '10 सेकंड आगे-पीछे जाने के लिए बाएँ और दाएँ का उपयोग करें';

  @override
  String sessionRecordingStatusPlaying(
    String title,
    String position,
    String speed,
  ) {
    return '$title। कक्षा के लिए चल रही है। $position। $speed।';
  }

  @override
  String sessionRecordingStatusPaused(
    String title,
    String position,
    String speed,
  ) {
    return '$title। रुकी हुई है। $position। $speed।';
  }

  @override
  String sessionPositionLabel(String position) {
    return 'स्थिति $position। 10 सेकंड आगे-पीछे जाने के लिए बाएँ और दाएँ का उपयोग करें';
  }

  @override
  String get sessionUntitled => 'बिना शीर्षक';

  @override
  String get sessionFileSelectedForClass => 'कक्षा के लिए चुनी गई';

  @override
  String get sessionFilePreviewing => 'प्रीव्यू चल रहा है';

  @override
  String get sessionPlayForClass => 'चुनें और अभी कक्षा के लिए चलाएँ';

  @override
  String get sessionSelectOnly => 'सिर्फ़ चुनें, बाद में 5 से चलाएँ';

  @override
  String get sessionPreviewPrivately => 'इस फ़ोन पर निजी रूप से प्रीव्यू करें';

  @override
  String get sessionStopPreview => 'निजी प्रीव्यू बंद करें';

  @override
  String get sessionUploadDetailsTitle => 'ऑडियो अपलोड की जानकारी';

  @override
  String get sessionUploadTitle => 'ऑडियो अपलोड करें';

  @override
  String sessionUploadFile(String name) {
    return 'फ़ाइल: $name';
  }

  @override
  String get sessionTitleField => 'ऑडियो का शीर्षक, ज़रूरी';

  @override
  String get sessionDescriptionField => 'ऑडियो का विवरण, वैकल्पिक';

  @override
  String get sessionCancelUpload => 'अपलोड रद्द करें';

  @override
  String get sessionConfirmUpload => 'ऑडियो अपलोड करें';

  @override
  String get sessionTitleRequired => 'शीर्षक ज़रूरी है';

  @override
  String get sessionChooseSessionsTitle => 'इस ऑडियो के लिए कक्षाएँ चुनें';

  @override
  String get sessionAddToSessions => 'ऑडियो को कक्षाओं में जोड़ें';

  @override
  String get sessionConfirmSessions => 'चुनी गई कक्षाओं की पुष्टि करें';

  @override
  String get sessionSelectAtLeastOne => 'कम से कम एक कक्षा चुनें';

  @override
  String get sessionSessionSelected => 'कक्षा चुनी गई';

  @override
  String get sessionSessionUnselected => 'कक्षा का चुनाव हटाया गया';

  @override
  String sessionChoiceSelected(String title) {
    return 'चुनी गई, $title';
  }

  @override
  String sessionChoiceNotSelected(String title) {
    return 'नहीं चुनी गई, $title';
  }

  @override
  String sessionClassNumbered(String number) {
    return 'कक्षा $number';
  }

  @override
  String get sessionUploadContextMissing =>
      'इस कक्षा की कक्षा और विषय का पता नहीं चल सका।';

  @override
  String get sessionUploadSuccess => 'अपलोड सफल रहा।';

  @override
  String get sessionUploadInProgress => 'ऑडियो अपलोड हो रहा है';

  @override
  String get sessionPlayNowTitle => 'अभी सबके लिए चलाएँ?';

  @override
  String sessionPlayNowMessage(String title) {
    return '$title चुनी गई है। क्या इसे अभी सभी प्रतिभागियों के लिए चलाएँ?';
  }

  @override
  String get sessionPlayNow => 'अभी चलाएँ';

  @override
  String get sessionNotYet => 'अभी नहीं';

  @override
  String get sessionUploadEditTitle => 'शीर्षक बदलें';

  @override
  String get sessionUploadEditDescription => 'विवरण बदलें';

  @override
  String get sessionUploadKey => 'अपलोड';

  @override
  String get sessionCancel => 'रद्द करें';

  @override
  String get classroomCheckUnreadable =>
      'कक्षा जाँच की स्थिति पढ़ी नहीं जा सकी। जवाब देने से पहले रीफ़्रेश करें।';

  @override
  String get classroomCheckUnconfirmed =>
      'कक्षा जाँच की कार्रवाई की पुष्टि नहीं हुई। फिर से कोशिश करने से पहले रीफ़्रेश करें।';

  @override
  String get classroomCheckConfirmationUnreadable =>
      'कक्षा जाँच की पुष्टि पढ़ी नहीं जा सकी। फिर से कोशिश करने से पहले रीफ़्रेश करें।';

  @override
  String get classroomCheckOpenedForYou =>
      'आपके शिक्षक ने एक प्रश्न पूछा है। जवाब देने के लिए 3 दबाएँ।';

  @override
  String get classroomCheckHelp =>
      'निजी कक्षा जाँच। समझ गया, कृपया दोबारा बताइए या मदद चाहिए। जवाब केवल जवाब देने वाला छात्र और सत्र के शिक्षक ही पढ़ सकते हैं। इसके अंक नहीं मिलते। अगली जाँच, सत्र खत्म होने या सर्वर फिर से शुरू होने पर जवाब मिट जाते हैं। पुष्टि हुई स्थिति के लिए पढ़ें या रीफ़्रेश चुनें। आवाज़ रोकें और वापस भी उपलब्ध हैं।';

  @override
  String get classroomCheckTitle => 'कक्षा जाँच';

  @override
  String get classroomCheckNewTitle => 'नई कक्षा जाँच खोलें?';

  @override
  String get classroomCheckNewMessage =>
      'इससे पिछली जाँच के सभी जवाब मिट जाएँगे। छात्र समझ गया, कृपया दोबारा बताइए या मदद चाहिए में से चुनते हैं। हर जवाब केवल आप और जवाब देने वाला छात्र ही पढ़ सकते हैं। इसके अंक नहीं मिलते और इसे पढ़ाई के रिकॉर्ड के रूप में नहीं रखा जाता।';

  @override
  String get classroomCheckNewConfirm => 'पिछले मिटाएँ और खोलें';

  @override
  String get classroomCheckNewCancel => 'मौजूदा जाँच रखें';

  @override
  String get classroomCheckSending => 'भेजा जा रहा है। पुष्टि का इंतज़ार है।';

  @override
  String get classroomCheckWaiting => 'पुष्टि का इंतज़ार है। दोबारा न भेजें।';

  @override
  String get sessionBackToClass => 'कक्षा में वापस जाएँ';

  @override
  String get classroomBackToSession => 'सत्र में वापस जाएँ';

  @override
  String get classroomBack => 'वापस';

  @override
  String get classroomCheckRead => 'जाँच की स्थिति और पुष्टि हुए जवाब पढ़ें';

  @override
  String get classroomCheckReadButton => 'स्थिति और जवाब पढ़ें';

  @override
  String get classroomCheckRefresh =>
      'निजी जाँच की स्थिति रीफ़्रेश करें। कक्षा से कनेक्शन ज़रूरी है';

  @override
  String get classroomCheckRefreshButton => 'सर्वर से रीफ़्रेश करें';

  @override
  String get classroomCheckOpenLabel =>
      'नई जाँच खोलें। पिछले जवाब मिटाने की पुष्टि करें';

  @override
  String get classroomCheckOpenButton => 'नई जाँच खोलें';

  @override
  String get classroomCheckCloseLabel =>
      'यह जाँच बंद करें। मौजूदा नतीजे अगली जाँच या सत्र खत्म होने तक रहेंगे';

  @override
  String get classroomCheckCloseButton => 'जाँच बंद करें';

  @override
  String classroomCheckAnswer(String choice) {
    return '$choice। अपना निजी, बिना अंक वाला जवाब भेजें या बदलें';
  }

  @override
  String get sessionStopSpeech => 'आवाज़ रोकें';

  @override
  String get classroomChoiceUnderstood => 'समझ गया';

  @override
  String get classroomChoiceRepeat => 'कृपया दोबारा बताइए';

  @override
  String get classroomChoiceHelp => 'मदद चाहिए';

  @override
  String get classroomCheckNone =>
      'पिछली मिली कक्षा स्थिति में कोई मौजूदा जाँच नहीं है। जाँचने के लिए रीफ़्रेश करें।';

  @override
  String get classroomCheckStatusOpen => 'जाँच खुली है।';

  @override
  String get classroomCheckStatusClosed =>
      'जाँच बंद है। जवाब बदले नहीं जा सकते।';

  @override
  String get classroomCheckNoResponseYet => 'अभी किसी जवाब की पुष्टि नहीं हुई।';

  @override
  String classroomCheckYourResponse(String choice) {
    return 'आपका पुष्टि हुआ जवाब: $choice।';
  }

  @override
  String classroomCheckStudentSummary(String status, String response) {
    return '$status $response आपका जवाब केवल आप और सत्र के शिक्षक ही पढ़ सकते हैं। इसके अंक नहीं मिलते।';
  }

  @override
  String classroomCheckLabelValue(String label, String value) {
    return '$label: $value';
  }

  @override
  String get classroomCheckNoResponses => 'अभी कोई जवाब नहीं।';

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
          '$status $count छात्रों ने जवाब दिया। $counts। $named जवाब केवल आपके और जवाब देने वाले हर छात्र के लिए निजी हैं, और ये अंक नहीं हैं।',
    );
    return '$_temp0';
  }

  @override
  String get classroomOnlyTeacherAcknowledges =>
      'केवल सत्र के शिक्षक ही किसी हाथ को स्वीकार कर सकते हैं।';

  @override
  String get classroomHandChanged =>
      'चुना हुआ हाथ बदल गया है। कतार फिर से पढ़ें।';

  @override
  String get classroomAckUnconfirmed =>
      'हाथ स्वीकार करने की पुष्टि नहीं हुई। फिर से कोशिश करने से पहले कतार पढ़ें।';

  @override
  String get classroomAckUnreadable =>
      'हाथ स्वीकार करने की जानकारी पढ़ी नहीं जा सकी। फिर से कोशिश करने से पहले कतार जाँचें।';

  @override
  String classroomAcknowledgedChanged(String name) {
    return '$name को पहले स्वीकार किया गया था। उसके बाद उनका हाथ बदल गया है; कतार फिर से पढ़ें। उनका माइक्रोफ़ोन नहीं बदला गया।';
  }

  @override
  String classroomAcknowledged(String name) {
    return '$name को स्वीकार किया गया। चुना हुआ हाथ नीचे कर दिया गया। उनका माइक्रोफ़ोन नहीं बदला गया।';
  }

  @override
  String get classroomHandsHelp =>
      'उठे हुए हाथ। पिछली मिली कक्षा स्थिति के लिए सारांश पढ़ें। पिछला और अगला किसी उठे हाथ को बिना बदले चुनते हैं। स्वीकार करें सर्वर की पुष्टि के बाद केवल चुने हुए हाथ को नीचे करता है। यह कभी किसी को अनम्यूट नहीं करता। जिन पुराने हाथों का क्रम पता नहीं है, उन्हें अलग से बताया जाता है।';

  @override
  String get classroomConsoleHelp =>
      'कक्षा कंसोल। पिछली मिली कक्षा स्थिति के लिए सारांश पढ़ें। पिछला और अगला किसी उठे हाथ को बिना बदले चुनते हैं। स्वीकार करें सर्वर की पुष्टि के बाद केवल चुने हुए हाथ को नीचे करता है। यह कभी किसी को अनम्यूट नहीं करता। जिन पुराने हाथों का क्रम पता नहीं है, उन्हें अलग से बताया जाता है।';

  @override
  String get classroomHandsTitle => 'उठे हुए हाथ';

  @override
  String get classroomNoHands =>
      'पिछली मिली कक्षा स्थिति में कोई हाथ उठा नहीं है।';

  @override
  String classroomSelectedGone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'चुना हुआ हाथ अब कतार में नहीं है। $count उठे हुए हाथ बाकी हैं। हाथ चुनने के लिए अगला या पिछला का उपयोग करें।',
      one:
          'चुना हुआ हाथ अब कतार में नहीं है। 1 उठा हुआ हाथ बाकी है। हाथ चुनने के लिए अगला या पिछला का उपयोग करें।',
    );
    return '$_temp0';
  }

  @override
  String classroomConsoleSelectedGone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'चुना हुआ हाथ अब कतार में नहीं है। $count उठे हुए हाथ बाकी हैं। हाथ चुनने के लिए अगला या पिछला का उपयोग करें।',
    );
    return '$_temp0';
  }

  @override
  String classroomHandTitle(String position, String total, String name) {
    return '$total में से हाथ $position, $name, इंतज़ार में';
  }

  @override
  String classroomParticipantNumbered(String id) {
    return 'प्रतिभागी $id';
  }

  @override
  String get classroomKnownOrder => 'सर्वर में दर्ज कतार का क्रम।';

  @override
  String get classroomUnknownOrder =>
      'हाथ उठाने का असली क्रम पता नहीं; पता क्रम वाले हाथों से पहले दिखाया गया है।';

  @override
  String get classroomReportedMuted => 'माइक्रोफ़ोन म्यूट बताया गया है।';

  @override
  String get classroomReportedUnmuted =>
      'माइक्रोफ़ोन अनम्यूट बताया गया है; इसका मतलब यह नहीं कि वे बोल रहे हैं।';

  @override
  String get classroomNoHandsShort => 'कोई हाथ उठा नहीं है';

  @override
  String get classroomNoHandSelected => 'कोई हाथ नहीं चुना गया';

  @override
  String classroomLowering(String name) {
    return '$name का हाथ नीचे किया जा रहा है। सर्वर का इंतज़ार है।';
  }

  @override
  String classroomLoweredLast(String name) {
    return '$name का हाथ नीचे किया गया। हाथों की कतार अब खाली है।';
  }

  @override
  String classroomLoweredNext(String name, String next) {
    return '$name का हाथ नीचे किया गया। अगला: $next।';
  }

  @override
  String get classroomNoSummary => 'अभी कोई कक्षा सारांश उपलब्ध नहीं है।';

  @override
  String get classroomReadSummary => 'कक्षा सारांश पढ़ें';

  @override
  String get classroomPreviousHand => 'पिछला उठा हुआ हाथ';

  @override
  String get classroomReadHand => 'चुना हुआ हाथ पढ़ें';

  @override
  String classroomReadHandLabel(String hand) {
    return 'चुना हुआ हाथ पढ़ें। $hand';
  }

  @override
  String get classroomNextHand => 'अगला उठा हुआ हाथ';

  @override
  String get classroomWaitingAck => 'हाथ स्वीकार करने की पुष्टि का इंतज़ार है';

  @override
  String get classroomAckNoneSelected =>
      'चुने हुए हाथ को स्वीकार करें और नीचे करें। कोई हाथ नहीं चुना गया';

  @override
  String classroomAckLabel(String name) {
    return '$name का हाथ नीचे करें। माइक्रोफ़ोन कभी अनम्यूट नहीं होता';
  }

  @override
  String get classroomAckSelectedLabel =>
      'चुना हुआ हाथ नीचे करें। माइक्रोफ़ोन कभी अनम्यूट नहीं होता';

  @override
  String get classroomAckButton => 'स्वीकार करें और हाथ नीचे करें';

  @override
  String get classroomRepeatConsoleHelp => 'कंसोल की मदद फिर से सुनें';

  @override
  String get classroomConsoleSections =>
      'कक्षा का सारांश सुनें, पिछला हाथ, चुना हुआ हाथ सुनें, अगला हाथ, हाथ स्वीकार करें, आवाज़ रोकें, मदद और वापस। अगर कोई हाथ या सारांश उपलब्ध नहीं है, तो उनके बटन चुनने पर वह स्थिति पढ़ी जाती है';

  @override
  String get classroomSnapshotNote =>
      'गिनती आखिरी मिली जानकारी पर आधारित है, इससे यह पक्का नहीं होता कि आवाज़ पहुँची। अभी कौन बोल रहा है, यह पहचानना उपलब्ध नहीं है।';

  @override
  String get classroomWaitingAckNote =>
      'सर्वर की पुष्टि का इंतज़ार है। कोई माइक्रोफ़ोन नहीं बदला गया है।';

  @override
  String classroomSummaryParticipants(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count प्रतिभागी',
      one: '1 प्रतिभागी',
    );
    return '$_temp0';
  }

  @override
  String classroomSummaryHands(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count उठे हुए हाथ',
      one: '1 उठा हुआ हाथ',
    );
    return '$_temp0';
  }

  @override
  String classroomSummaryMicrophones(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count माइक्रोफ़ोन',
      one: '1 माइक्रोफ़ोन',
    );
    return '$_temp0';
  }

  @override
  String get classroomSummaryNobodySpeaking => 'कोई बोलता हुआ नहीं मिला।';

  @override
  String classroomSummarySpeaking(String names) {
    return 'बोलते हुए मिले: $names।';
  }

  @override
  String get classroomSummaryNoRecording =>
      'कक्षा की कोई रिकॉर्डिंग नहीं चुनी गई है।';

  @override
  String classroomSummaryRecordingPlaying(String title) {
    return 'कक्षा की रिकॉर्डिंग $title। चलाने का अनुरोध भेजा गया।';
  }

  @override
  String classroomSummaryRecordingPaused(String title) {
    return 'कक्षा की रिकॉर्डिंग $title। रुकी हुई है।';
  }

  @override
  String get classroomSummaryPreviewActive =>
      'निजी प्रीव्यू केवल इस फ़ोन पर चालू है।';

  @override
  String get classroomSummaryPreviewStopped => 'निजी प्रीव्यू बंद हो गया।';

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
    return 'आपका कनेक्शन: $connection। कक्षा की आखिरी मिली स्थिति: $people, $hands, $muted म्यूट बताए गए। दूसरों के दोबारा जुड़ने की गिनती उपलब्ध नहीं है। $speaking $recording $preview माइक्रोफ़ोन की स्थिति और स्वीकार किए गए चलाने के अनुरोध से यह साबित नहीं होता कि किसी ने बोला या आवाज़ सुनी।';
  }

  @override
  String get sessionToolsTitle => 'शिक्षक के टूल';

  @override
  String get sessionInvite => 'छात्रों को आमंत्रित करें';

  @override
  String get sessionEndClass =>
      'सभी के लिए कक्षा समाप्त करें, पुष्टि माँगी जाएगी';

  @override
  String get sessionPeopleTitle => 'प्रतिभागी और उठे हुए हाथ';

  @override
  String sessionHandQueue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'उठे हुए हाथों की कतार, $count हाथ इंतज़ार में',
      one: 'उठे हुए हाथों की कतार, 1 हाथ इंतज़ार में',
      zero: 'उठे हुए हाथों की कतार, कोई हाथ इंतज़ार में नहीं',
    );
    return '$_temp0';
  }

  @override
  String sessionParticipantList(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'प्रतिभागियों की सूची, $count लोग',
      one: 'प्रतिभागियों की सूची, 1 व्यक्ति',
    );
    return '$_temp0';
  }

  @override
  String get sessionSummaryChoice => 'कक्षा का सारांश सुनें';

  @override
  String get sessionParticipantsTitle => 'प्रतिभागी';

  @override
  String get sessionMembersTitle => 'कक्षा में लोग';

  @override
  String get sessionMembersButton => '7: कक्षा में कौन है';

  @override
  String sessionMembersLabel(String people) {
    return 'कक्षा में कौन है। $people विवरण सुनने के लिए किसी व्यक्ति को चुनें';
  }

  @override
  String get sessionHearDetails => 'विवरण सुनें';

  @override
  String sessionMuteParticipant(String name) {
    return '$name को म्यूट करें';
  }

  @override
  String sessionRemoveParticipant(String name) {
    return '$name को कक्षा से हटाएँ, पुष्टि माँगी जाएगी';
  }

  @override
  String get sessionParticipantGone => 'वह प्रतिभागी कक्षा छोड़ चुका है।';

  @override
  String get sessionNoOtherParticipants => 'अभी कक्षा में और कोई नहीं है।';

  @override
  String sessionTileRemoveMessage(String name) {
    return '$name को इस कक्षा से हटाया जाएगा और उनके डैशबोर्ड पर वापस भेजा जाएगा।';
  }

  @override
  String sessionTileRemoveFromSessionMessage(String name) {
    return '$name को इस सत्र से हटाया जाएगा और उनके डैशबोर्ड पर वापस भेजा जाएगा।';
  }

  @override
  String sessionUnmuteParticipant(String name) {
    return '$name को अनम्यूट करें';
  }

  @override
  String sessionRemoveFromClass(String name) {
    return '$name को कक्षा से हटाएँ';
  }

  @override
  String get sessionConnStateConnecting => 'जुड़ रहा है';

  @override
  String get sessionConnStateConnected => 'जुड़ गया';

  @override
  String get sessionConnStateInterrupted => 'कनेक्शन टूट गया';

  @override
  String get sessionConnStateReconnecting => 'फिर से जुड़ रहा है';

  @override
  String get sessionConnStateSignInRequired => 'साइन इन ज़रूरी है';

  @override
  String get sessionConnStateUnavailable => 'कक्षा उपलब्ध नहीं है';

  @override
  String get sessionConnStateEnded => 'कक्षा समाप्त हो गई';

  @override
  String get sessionConnStateDisconnected => 'कनेक्शन बंद है';

  @override
  String get sessionReconnectingToClass => 'कक्षा से फिर से जुड़ रहे हैं।';

  @override
  String get sessionSignInRequiredLeave =>
      'साइन इन ज़रूरी है। सत्र छोड़ें और फिर से साइन इन करें।';

  @override
  String get sessionSignInExpiredLeave =>
      'साइन इन की अवधि खत्म हो गई। सत्र छोड़ें और फिर से साइन इन करें।';

  @override
  String get sessionClassNoLongerAvailable =>
      'यह कक्षा अब आपके खाते के लिए उपलब्ध नहीं है। आप वापस जा सकते हैं।';

  @override
  String get sessionServiceUnavailable => 'कक्षा की सेवा उपलब्ध नहीं है।';

  @override
  String get sessionConnectionUnreadable =>
      'कक्षा के कनेक्शन का जवाब पढ़ा नहीं जा सका।';

  @override
  String get sessionConnectionNotConfirmed =>
      'कक्षा ने कनेक्शन की पुष्टि नहीं की।';

  @override
  String get sessionConnectionInterrupted => 'कक्षा का कनेक्शन टूट गया।';

  @override
  String get sessionConnectionClosed => 'कक्षा का कनेक्शन बंद हो गया।';

  @override
  String get sessionConnectionCouldNotConfirm =>
      'कक्षा के कनेक्शन की पुष्टि नहीं हो सकी।';

  @override
  String get sessionNoUpdates => 'कक्षा से कोई अपडेट नहीं मिला।';

  @override
  String get sessionUpdateUnreadable => 'कक्षा का एक अपडेट पढ़ा नहीं जा सका।';

  @override
  String get sessionUpdateUnexpectedFormat =>
      'कक्षा के एक अपडेट का फ़ॉर्मेट अनपेक्षित था।';

  @override
  String get sessionUpdateTypeUnreadable =>
      'कक्षा के एक अपडेट का प्रकार पढ़ा नहीं जा सका।';

  @override
  String get sessionParticipationNotConfirmed =>
      'कक्षा में आपकी भागीदारी की पुष्टि नहीं हुई।';

  @override
  String get sessionConnectedToClass => 'कक्षा से जुड़ गए।';

  @override
  String get sessionSignInChangedShort =>
      'आपका साइन इन बदल गया है। फिर से साइन इन करें।';

  @override
  String get sessionRemovedGoBack =>
      'आपको कक्षा से हटा दिया गया है। आप वापस जा सकते हैं।';

  @override
  String sessionConnectionLostReconnecting(String reason) {
    return '$reason फिर से जुड़ रहे हैं। पिछली कार्रवाइयाँ अपने आप दोबारा नहीं भेजी जाएँगी।';
  }

  @override
  String get sessionActionClassUnavailable =>
      'कक्षा उपलब्ध नहीं है। यह कार्रवाई नहीं भेजी गई।';

  @override
  String get sessionActionSessionChanged =>
      'सत्र बदल गया। यह कार्रवाई नहीं भेजी गई।';

  @override
  String get sessionActionSignInRequired =>
      'साइन इन ज़रूरी है। यह कार्रवाई नहीं भेजी गई।';

  @override
  String get sessionActionConnectionChanged =>
      'पुष्टि से पहले कनेक्शन बदल गया। हो सकता है कार्रवाई पहुँच गई हो; दोबारा कोशिश करने से पहले उसकी स्थिति जाँचें।';

  @override
  String get sessionAccountChangedLeave =>
      'आपका खाता बदल गया है। सत्र छोड़ें और फिर से साइन इन करें।';

  @override
  String get sessionActionAccountChanged =>
      'कार्रवाई की पुष्टि होने से पहले आपका खाता बदल गया।';

  @override
  String get sessionActionNotConfirmedByClass =>
      'कक्षा ने कार्रवाई की पुष्टि नहीं की। दोबारा कोशिश करने से पहले उसकी स्थिति जाँचें।';

  @override
  String get sessionActionMayHaveReached =>
      'कार्रवाई की पुष्टि नहीं हुई। हो सकता है वह कक्षा तक पहुँच गई हो। दोबारा कोशिश करने से पहले उसकी स्थिति जाँचें।';

  @override
  String get sessionRtcConnectionClosed => 'कनेक्शन बंद हो गया।';

  @override
  String get sessionRtcNetworkError => 'नेटवर्क में गड़बड़ी';

  @override
  String sessionRtcConnected(String id) {
    return 'सत्र $id से जुड़ गए';
  }

  @override
  String sessionRtcParticipantJoined(String id) {
    return 'प्रतिभागी $id जुड़ गए।';
  }

  @override
  String sessionRtcParticipantLeft(String id) {
    return 'प्रतिभागी $id चले गए।';
  }

  @override
  String sessionRtcParticipantMuted(String id) {
    return 'प्रतिभागी $id अब म्यूट हैं';
  }

  @override
  String sessionRtcParticipantUnmuted(String id) {
    return 'प्रतिभागी $id अब अनम्यूट हैं';
  }

  @override
  String sessionRtcMessage(String text) {
    return 'संदेश: $text';
  }

  @override
  String sessionRtcTeacherPlaying(String id) {
    return 'शिक्षक ने ऑडियो $id चलाना शुरू किया';
  }

  @override
  String sessionRtcAudioStarted(String id) {
    return 'प्रतिभागी $id के लिए ऑडियो शुरू हुआ';
  }

  @override
  String librarySpeedTimes(String speed) {
    return '$speed गुना';
  }

  @override
  String get libraryNoClassForSession =>
      'इस सत्र के नाम से कोई कक्षा नहीं मिली।';

  @override
  String librarySubjectFilterLabel(String name) {
    return 'विषय फ़िल्टर: $name। बदलने के लिए बटन 2, या बाएँ या दाएँ';
  }

  @override
  String librarySubjectFilterLabelPosition(
    String name,
    String index,
    String total,
  ) {
    return 'विषय फ़िल्टर: $name, $total में से $index। बदलने के लिए बटन 2, या बाएँ या दाएँ';
  }

  @override
  String get libraryAllSubjects => 'सभी विषय';

  @override
  String libraryRestoredToPlaylist(String title) {
    return '$title प्लेलिस्ट में वापस आ गया है।';
  }

  @override
  String get librarySizeZero => '0 मेगाबाइट';

  @override
  String get librarySizeTiny => '0.1 मेगाबाइट से कम';

  @override
  String get librarySizeOne => '1 मेगाबाइट';

  @override
  String librarySizeMegabytes(String value) {
    return '$value मेगाबाइट';
  }

  @override
  String libraryStorageUsed(String size, String limit) {
    return '$limit में से $size इस्तेमाल हुआ।';
  }

  @override
  String libraryRecordingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count रिकॉर्डिंग',
      one: '1 रिकॉर्डिंग',
    );
    return '$_temp0';
  }

  @override
  String libraryPlayingBrief(String title, String position) {
    return '$title, $position से चल रहा है।';
  }

  @override
  String libraryPlayingDetailed(String title, String position, String speed) {
    return '$title, $position से चल रहा है, स्पीड $speed।';
  }

  @override
  String libraryPausedAt(String position) {
    return '$position पर रुका है।';
  }

  @override
  String get libraryPlayerStateNothing => 'कुछ नहीं चल रहा है।';

  @override
  String libraryPlayerStatePlaying(
    String title,
    String position,
    String speed,
  ) {
    return '$title चल रहा है, $position, स्पीड $speed।';
  }

  @override
  String libraryPlayerStatePaused(String title, String position, String speed) {
    return '$title रुका है, $position, स्पीड $speed।';
  }

  @override
  String librarySpeedChanged(String speed) {
    return 'स्पीड $speed।';
  }

  @override
  String get librarySlowest => 'पहले से सबसे धीमी स्पीड पर है।';

  @override
  String get libraryFastest => 'पहले से सबसे तेज़ स्पीड पर है।';

  @override
  String get libraryNoLessonLoaded =>
      'कोई पाठ लोड नहीं है। पहले चलाने के लिए एक पाठ चुनें।';

  @override
  String libraryNoLessonPlayingPress(String key) {
    return 'कोई पाठ नहीं चल रहा है। पहला पाठ चलाने के लिए $key दबाएँ।';
  }

  @override
  String get libraryNothingIsPlaying => 'कुछ नहीं चल रहा है।';

  @override
  String get libraryNothingPlayingHint =>
      'कुछ नहीं चल रहा है। कोई पाठ चुनें या 5 दबाएँ।';

  @override
  String libraryStopped(String title) {
    return '$title रोक दिया गया।';
  }

  @override
  String libraryFinished(String title) {
    return '$title समाप्त हुआ।';
  }

  @override
  String get libraryWaitForPlayer => 'कृपया पाठ प्लेयर का इंतज़ार करें।';

  @override
  String get librarySeekFailed =>
      'पाठ में उस जगह पर नहीं जा सके। फिर से कोशिश करें।';

  @override
  String get librarySpeedFailed =>
      'चलाने की स्पीड नहीं बदल सकी। फिर से कोशिश करें।';

  @override
  String libraryPlayFailed(String title) {
    return '$title नहीं चल सका। अपना कनेक्शन जाँचें, फिर उसे दोबारा चुनें।';
  }

  @override
  String get libraryCheckingOfflineAccess =>
      'इंटरनेट उपलब्ध नहीं है। आपकी सेव की गई ऑफ़लाइन पहुँच जाँची जा रही है।';

  @override
  String get libraryLessonGone =>
      'यह पाठ अब उपलब्ध नहीं है। आपकी सेव की गई प्रगति और बुकमार्क रखे गए हैं।';

  @override
  String librarySeekLabel(String position) {
    return 'पाठ की जगह $position। 10 सेकंड आगे-पीछे जाने के लिए बाएँ या दाएँ का इस्तेमाल करें।';
  }

  @override
  String libraryRewindLabel(String key) {
    return '10 सेकंड पीछे, बटन $key';
  }

  @override
  String libraryForwardLabel(String key) {
    return '10 सेकंड आगे, बटन $key';
  }

  @override
  String librarySlowerLabel(String key, String speed) {
    return 'धीमा, बटन $key। अभी $speed';
  }

  @override
  String libraryFasterLabel(String key, String speed) {
    return 'तेज़, बटन $key। अभी $speed';
  }

  @override
  String libraryPauseLabel(String title, String key) {
    return '$title रोकें, बटन $key';
  }

  @override
  String libraryPlayLabel(String title, String key) {
    return '$title चलाएँ, बटन $key';
  }

  @override
  String libraryResumeLabel(String title, String key) {
    return '$title फिर से चलाएँ, बटन $key';
  }

  @override
  String libraryStopLabel(String title, String key) {
    return '$title बंद करें, बटन $key';
  }

  @override
  String libraryPlayerKeyHelp(
    String rewind,
    String playPause,
    String forward,
    String slower,
    String faster,
  ) {
    return '10 सेकंड पीछे जाने के लिए $rewind, चलाने या रोकने के लिए $playPause, 10 सेकंड आगे जाने के लिए $forward, धीमा करने के लिए $slower और तेज़ करने के लिए $faster दबाएँ।';
  }

  @override
  String libraryBookmarkCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count बुकमार्क',
      one: '1 बुकमार्क',
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
    return '$title। जगह $position। स्पीड $speed। $bookmarks। A-B दोहराना $repeat। प्रगति सेव करना $saving।';
  }

  @override
  String libraryReadStatusLabel(String status) {
    return 'सीखने की स्थिति सुनें। $status';
  }

  @override
  String libraryAddBookmarkLabel(String time) {
    return '$time पर बुकमार्क जोड़ें';
  }

  @override
  String libraryBookmarksLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'बुकमार्क। $count सेव की गई जगहें',
      one: 'बुकमार्क। 1 सेव की गई जगह',
    );
    return '$_temp0';
  }

  @override
  String libraryNotesLabel(String time) {
    return '$time पर निजी पढ़ाई के नोट। खोलने से पहले पाठ रुक जाता है';
  }

  @override
  String get libraryRepeatStartLabel =>
      'अभी की जगह पर दोहराने की शुरुआत A सेट करें';

  @override
  String get libraryRepeatEndLabel =>
      'शुरुआत A के बाद दोहराने का अंत B सेट करें';

  @override
  String get libraryRepeatTurnOffLabel => 'A-B दोहराना बंद करें';

  @override
  String get libraryRepeatTurnOnLabel => 'A-B दोहराना चालू करें';

  @override
  String get libraryRepeatClearLabel => 'सेव की गई A-B दोहराने की जगहें मिटाएँ';

  @override
  String libraryRetryLabel(String issue) {
    return 'सीखने की प्रगति फिर से सेव करने की कोशिश करें। $issue';
  }

  @override
  String libraryBookmarkSaved(String time) {
    return '$time पर बुकमार्क सेव हुआ।';
  }

  @override
  String libraryRepeatStartSet(String time) {
    return 'दोहराने की शुरुआत $time पर सेट हुई।';
  }

  @override
  String libraryRepeatEndSetBrief(String time) {
    return 'दोहराने का अंत $time पर सेट हुआ।';
  }

  @override
  String libraryRepeatEndSetDetailed(String time) {
    return 'दोहराने का अंत $time पर सेट हुआ। बार-बार चलाना शुरू करने के लिए दोहराना चालू करें चुनें।';
  }

  @override
  String libraryRepeatState(String state) {
    return 'A-B दोहराना $state।';
  }

  @override
  String get libraryRepeatCleared => 'A-B दोहराने की जगहें मिटा दी गईं।';

  @override
  String get libraryProgressSaved => 'सीखने की प्रगति सेव हो गई।';

  @override
  String get libraryActionFailed =>
      'प्लेयर यह काम पूरा नहीं कर सका। चलना जाँचें और फिर से कोशिश करें।';

  @override
  String get libraryCheckPosition => 'पाठ की जगह जाँचें और फिर से कोशिश करें।';

  @override
  String get libraryProgressUnavailableTitle =>
      'सेव की गई प्रगति उपलब्ध नहीं है';

  @override
  String libraryProgressUnavailable(String reason) {
    return '$reason क्या सेव किया गया डेटा बदले बिना शुरुआत से सुनें? जब तक दोबारा कोशिश सफल नहीं होती, सेव करना बंद रहेगा।';
  }

  @override
  String get libraryListenFromBeginning => 'शुरुआत से सुनें';

  @override
  String get libraryBookmarkNameScreen =>
      'बुकमार्क का नाम। बदलने के लिए ओके दबाएँ। ऊपर या नीचे दबाने पर बदलना बंद होता है।';

  @override
  String get libraryEnterBookmarkName => 'बुकमार्क का नाम लिखें।';

  @override
  String libraryBookmarkLabel(String label, String time) {
    return '$label। $time। बुकमार्क पर जाएँ';
  }

  @override
  String libraryBookmarkJumped(String label, String time) {
    return '$label। जगह $time।';
  }

  @override
  String libraryRemoveBookmarkLabel(String label) {
    return '$label हटाएँ';
  }

  @override
  String libraryRemoveBookmarkQuestion(String label) {
    return '$label हटाएँ? इससे पाठ या कोई दूसरा बुकमार्क नहीं हटेगा।';
  }

  @override
  String libraryBookmarkRemoved(String label) {
    return '$label हटा दिया गया।';
  }

  @override
  String get libraryBookmarksScreen =>
      'बुकमार्क। जाने के लिए कोई जगह चुनें। इससे रुका हुआ पाठ चलना शुरू नहीं होता। हटाने से पहले पुष्टि माँगी जाती है।';

  @override
  String get libraryNoRecordingsUpload =>
      'अभी कोई रिकॉर्डिंग नहीं है। ऑडियो अपलोड करने के लिए 2 दबाएँ।';

  @override
  String libraryRecordingsLoaded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count रिकॉर्डिंग लोड हुईं।',
      one: '1 रिकॉर्डिंग लोड हुई।',
    );
    return '$_temp0';
  }

  @override
  String get libraryLoadFailed =>
      'रिकॉर्डिंग लोड नहीं हो सकीं। अपना इंटरनेट कनेक्शन जाँचें, फिर दोबारा कोशिश करने के लिए 1 दबाएँ।';

  @override
  String get libraryTitleRequired => 'शीर्षक ज़रूरी है।';

  @override
  String get libraryPickFailed => 'फ़ाइल नहीं खुल सकी। उसे फिर से चुनकर देखें।';

  @override
  String get libraryChooseWorkspaceFirst =>
      'ऑडियो अपलोड करने से पहले शिक्षक डैशबोर्ड पर कक्षा और विषय का वर्कस्पेस चुनें।';

  @override
  String libraryUploadingBrief(String title) {
    return '$title अपलोड हो रहा है।';
  }

  @override
  String libraryUploadingDetailed(String title) {
    return '$title अपलोड हो रहा है। हर 25 प्रतिशत पर आपको प्रगति सुनाई देगी।';
  }

  @override
  String libraryUploadingOnceDetailed(String title) {
    return '$title अपलोड हो रहा है। कृपया इंतज़ार करें; पूरा होने पर आपको सुनाई देगा।';
  }

  @override
  String libraryUploadProgress(String title, String percent) {
    return '$title: $percent अपलोड हुआ।';
  }

  @override
  String libraryUploaded(String title) {
    return '$title अपलोड हो गया।';
  }

  @override
  String libraryUploadFailed(String title) {
    return '$title अपलोड नहीं हो सका। अपना कनेक्शन जाँचें, फिर दोबारा कोशिश करने के लिए 3 दबाएँ।';
  }

  @override
  String get libraryUploadNoSession =>
      'अपलोड रद्द हुआ। कम से कम एक सत्र चुनें, फिर ऑडियो दोबारा जोड़ने के लिए 3 दबाएँ।';

  @override
  String get libraryUploadNoClass => 'सत्र की कक्षा और विषय पता नहीं चल सके।';

  @override
  String get libraryFileUnreadable =>
      'फ़ाइल पढ़ी नहीं जा सकी। उसे फिर से चुनें।';

  @override
  String libraryPreviewStopped(String title) {
    return '$title का प्रीव्यू बंद हुआ।';
  }

  @override
  String libraryPreviewing(String title) {
    return '$title का निजी प्रीव्यू चल रहा है।';
  }

  @override
  String get libraryPreviewFinished => 'प्रीव्यू समाप्त हुआ।';

  @override
  String libraryPreviewFailed(String title) {
    return '$title नहीं चल सका। अपना कनेक्शन जाँचें और फिर से कोशिश करें।';
  }

  @override
  String get libraryNoActiveSession => 'कोई सत्र चालू नहीं है।';

  @override
  String librarySelectedForSession(String title) {
    return 'सत्र के लिए $title चुना गया।';
  }

  @override
  String get librarySelectFailed =>
      'ऑडियो नहीं चुना जा सका। फिर से कोशिश करें।';

  @override
  String get libraryClassPlayAccepted =>
      'कक्षा में चलाने का अनुरोध स्वीकार हुआ।';

  @override
  String get libraryClassPlayFailed =>
      'कक्षा में चलाना शुरू नहीं हो सका। फिर से कोशिश करें।';

  @override
  String get libraryClassPauseAccepted =>
      'कक्षा में रोकने का अनुरोध स्वीकार हुआ।';

  @override
  String get libraryClassPauseFailed =>
      'कक्षा का ऑडियो रोका नहीं जा सका। फिर से कोशिश करें।';

  @override
  String libraryStopPreviewLabel(String title) {
    return '$title का निजी प्रीव्यू बंद करें। इसे केवल आप सुन सकते हैं।';
  }

  @override
  String libraryPreviewLabel(String title) {
    return '$title का निजी प्रीव्यू सुनें। इसे केवल आप सुन सकते हैं।';
  }

  @override
  String libraryBroadcastLabel(String title) {
    return 'सत्र में सभी के लिए $title चलाएँ';
  }

  @override
  String libraryRecordingsSentence(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count रिकॉर्डिंग।',
      one: '1 रिकॉर्डिंग।',
    );
    return '$_temp0';
  }

  @override
  String libraryPreviewingState(String title) {
    return '$title का प्रीव्यू चल रहा है।';
  }

  @override
  String get libraryUploadInProgress => 'अपलोड चल रहा है।';

  @override
  String get libraryAccountChanged =>
      'आपका खाता बदल गया है। लाइब्रेरी फिर से खोलें।';

  @override
  String get libraryNoUnfinished =>
      'इस खाते के लिए कोई अधूरा पाठ सेव नहीं है। सीखना शुरू करने के लिए कोई रिकॉर्ड किया हुआ पाठ चुनें।';

  @override
  String get libraryCannotCheckAccess =>
      'पाठ की पहुँच जाँची नहीं जा सकी। इंटरनेट से जुड़ें और फिर से कोशिश करें। आपकी सेव की गई प्रगति रखी गई है।';

  @override
  String get libraryUnfinishedUnavailable =>
      'आपके अधूरे पाठ अभी इस लाइब्रेरी में उपलब्ध नहीं हैं। आपकी सेव की गई प्रगति और बुकमार्क रखे गए हैं।';

  @override
  String get libraryOpeningNextUnfinished =>
      'सबसे हाल का पाठ यहाँ उपलब्ध नहीं है। आपका उसके बाद का सबसे हाल का उपलब्ध अधूरा पाठ खोला जा रहा है। सेव की गई प्रगति रखी गई है।';

  @override
  String get libraryContinueFailed =>
      'सेव की गई सीखने की प्रगति नहीं खुल सकी। स्टोरेज, अपना कनेक्शन और साइन इन जाँचें, फिर दोबारा कोशिश करें।';

  @override
  String get libraryNoActiveClassesNow =>
      'अभी कोई कक्षा चालू नहीं है। सभी ऑडियो फ़ाइलों के लिए 3 दबाएँ।';

  @override
  String libraryClassesLoaded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count चालू कक्षाएँ लोड हुईं।',
      one: '1 चालू कक्षा लोड हुई।',
    );
    return '$_temp0';
  }

  @override
  String libraryClassesFailed(String reason) {
    return '$reason चालू कक्षाएँ रीफ़्रेश नहीं हो सकीं। दोबारा कोशिश करने के लिए 1 दबाएँ। सेव किए गए डाउनलोड उपलब्ध रहेंगे।';
  }

  @override
  String get libraryClassesLoading =>
      'कक्षाएँ अभी लोड हो रही हैं। थोड़ी देर में फिर से बटन 5 दबाएँ।';

  @override
  String get libraryNoActiveClassesStaying =>
      'कोई कक्षा चालू नहीं है। ऑडियो लाइब्रेरी में ही रह रहे हैं।';

  @override
  String libraryFirstActiveClass(String title) {
    return '$title. पहली सक्रिय कक्षा. सक्रिय कक्षा सत्र देखने के लिए D-pad ऊपर और नीचे का उपयोग करें. चुनी गई कक्षा की रिकॉर्डिंग खोलने के लिए ओके दबाएँ.';
  }

  @override
  String get libraryOpeningPlaylists =>
      'मेरी प्लेलिस्ट खुल रही हैं. प्लेलिस्ट की सामग्री निजी है.';

  @override
  String libraryClassLabel(String title, String index, String count) {
    return '$title. कक्षा $index, कुल $count में से';
  }

  @override
  String get libraryLoadingActiveClasses => 'सक्रिय कक्षाएँ लोड हो रही हैं.';

  @override
  String libraryActiveClassesSentence(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count सक्रिय कक्षाएँ.',
      one: '1 सक्रिय कक्षा.',
    );
    return '$_temp0';
  }

  @override
  String libraryNoRecordingsFor(String where) {
    return '$where के लिए अभी कोई रिकॉर्डिंग नहीं है.';
  }

  @override
  String libraryRecordingsLoadedFor(int count, String where) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$where के लिए $count रिकॉर्डिंग लोड हुईं.',
      one: '$where के लिए 1 रिकॉर्डिंग लोड हुई.',
    );
    return '$_temp0';
  }

  @override
  String get libraryDownloadsReadFailed =>
      'डाउनलोड किए गए पाठ पढ़े नहीं जा सके. फिर से कोशिश करने के लिए 1 दबाएँ.';

  @override
  String get libraryClassLoadFailed =>
      'रिकॉर्डिंग लोड नहीं हो सकीं. अपना इंटरनेट कनेक्शन और साइन इन जाँचें, फिर से कोशिश करने के लिए 1 दबाएँ.';

  @override
  String libraryRetryAfter(String reason) {
    return '$reason फिर से कोशिश करने के लिए 1 दबाएँ.';
  }

  @override
  String get libraryDownloadedDescription =>
      'डाउनलोड की गई रिकॉर्डिंग. 30 दिन के बाद एक्सेस फिर से चालू करना ज़रूरी है.';

  @override
  String get libraryDownloadedHelp =>
      'डाउनलोड किए गए पाठ. चलाने से पहले मौजूदा ऑफ़लाइन एक्सेस जाँचा जाता है.';

  @override
  String get libraryOnlineHelp =>
      'ऑडियो लाइब्रेरी. ऑनलाइन रिकॉर्डिंग के लिए इंटरनेट चाहिए. ऑफ़लाइन सुनने के लिए पाठ डाउनलोड करें.';

  @override
  String librarySubjectChoice(String name, String index, String count) {
    return 'विषय: $name, $index, कुल $count में से';
  }

  @override
  String librarySubjectLabel(String choice) {
    return '$choice. बदलने के लिए 2 दबाएँ, या बाएँ और दाएँ दबाएँ';
  }

  @override
  String get librarySubjectFixed =>
      'यह लाइब्रेरी पहले से एक ही विषय तक सीमित है.';

  @override
  String libraryLength(String time) {
    return 'अवधि $time';
  }

  @override
  String libraryRecordingsInSubject(int count, String subject) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$subject में $count रिकॉर्डिंग.',
      one: '$subject में 1 रिकॉर्डिंग.',
    );
    return '$_temp0';
  }

  @override
  String libraryNoTeacherPlaylists(String className, String subject) {
    return '$className, $subject के लिए अभी कोई प्लेलिस्ट नहीं है. नई बनाने के लिए 2 दबाएँ.';
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
      other: '$className, $subject के लिए $count प्लेलिस्ट लोड हुईं.',
      one: '$className, $subject के लिए 1 प्लेलिस्ट लोड हुई.',
    );
    return '$_temp0';
  }

  @override
  String get libraryPlaylistCreateFailed => 'प्लेलिस्ट नहीं बन सकी.';

  @override
  String get libraryNoMyPlaylists =>
      'अभी कोई प्लेलिस्ट नहीं है. निजी प्लेलिस्ट बनाने के लिए 2 दबाएँ.';

  @override
  String libraryPrivatePlaylistCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count निजी प्लेलिस्ट',
      one: '1 निजी प्लेलिस्ट',
    );
    return '$_temp0';
  }

  @override
  String libraryClassPlaylistCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count कक्षा प्लेलिस्ट',
      one: '1 कक्षा प्लेलिस्ट',
    );
    return '$_temp0';
  }

  @override
  String libraryMyPlaylistsLoaded(
    String privatePlaylists,
    String classPlaylists,
  ) {
    return '$privatePlaylists और $classPlaylists लोड हुईं.';
  }

  @override
  String get libraryPrivatePlaylistCreateFailed =>
      'निजी प्लेलिस्ट नहीं बन सकी.';

  @override
  String libraryPlaylistsSentence(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count प्लेलिस्ट.',
      one: '1 प्लेलिस्ट.',
    );
    return '$_temp0';
  }

  @override
  String libraryItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count आइटम',
      one: '1 आइटम',
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
      'यह प्लेलिस्ट रिफ़्रेश नहीं हो सकी. अपना कनेक्शन जाँचें और फिर से कोशिश करें. चल रहा प्लेबैक और सहेजी गई प्रगति नहीं बदली गई है.';

  @override
  String get libraryPlaylistLessonGone =>
      'मौजूदा पाठ अब इस प्लेलिस्ट में उपलब्ध नहीं है. प्लेबैक रुक गया. आपकी सहेजी गई प्रगति और बुकमार्क रखे गए हैं.';

  @override
  String get libraryNothingToAdd =>
      'जोड़ने के लिए कोई योग्य ऑडियो उपलब्ध नहीं है.';

  @override
  String libraryAddedToPlaylist(String title) {
    return '$title प्लेलिस्ट में जोड़ा गया.';
  }

  @override
  String get libraryAddFailed =>
      'ऑडियो नहीं जोड़ा जा सका. अपना कनेक्शन जाँचें और फिर से कोशिश करें.';

  @override
  String libraryItemUnavailable(String title) {
    return '$title अब आपकी मौजूदा कक्षा में उपलब्ध नहीं है. आप इसे इस प्लेलिस्ट से हटा सकते हैं.';
  }

  @override
  String libraryItemCannotPlay(String title) {
    return '$title उपलब्ध नहीं है.';
  }

  @override
  String libraryPlayingItem(String announcement, String index, String count) {
    return '$announcement आइटम $index, कुल $count में से.';
  }

  @override
  String get libraryPlaylistPlayFailed =>
      'यह पाठ नहीं चल सका. अपना कनेक्शन जाँचें और फिर से कोशिश करें.';

  @override
  String get libraryPlaylistEmpty => 'प्लेलिस्ट खाली है.';

  @override
  String get libraryPlaylistEnded => 'प्लेलिस्ट खत्म. प्लेबैक रुक गया.';

  @override
  String libraryRenamed(String title) {
    return 'प्लेलिस्ट का नाम बदलकर $title किया गया.';
  }

  @override
  String get libraryRenameFailed =>
      'प्लेलिस्ट का नाम नहीं बदला जा सका. अपना कनेक्शन जाँचें और फिर से कोशिश करें.';

  @override
  String get libraryAlreadyFirst => 'चुना गया आइटम पहले से सबसे पहले है.';

  @override
  String get libraryAlreadyLast => 'चुना गया आइटम पहले से सबसे आखिर में है.';

  @override
  String libraryMoved(String title, String position, String count) {
    return '$title को स्थान $position पर ले जाया गया, कुल $count में से.';
  }

  @override
  String libraryMoveFailed(String title) {
    return '$title की जगह नहीं बदली जा सकी. अपना कनेक्शन जाँचें और फिर से कोशिश करें.';
  }

  @override
  String libraryRemovedFromPlaylist(String title, String playlist) {
    return '$title को $playlist से हटाया गया.';
  }

  @override
  String libraryRemoveFailed(String title) {
    return '$title को नहीं हटाया जा सका. अपना कनेक्शन जाँचें और फिर से कोशिश करें.';
  }

  @override
  String libraryRemoveItemQuestion(String title, String playlist) {
    return '$title को $playlist से हटाएँ? रिकॉर्डिंग खुद लाइब्रेरी में रहेगी.';
  }

  @override
  String libraryRemoveItemLabel(String title) {
    return '$title को प्लेलिस्ट से हटाएँ, पुष्टि पूछी जाएगी';
  }

  @override
  String libraryPublished(String title) {
    return '$title कक्षा के लिए प्रकाशित किया गया.';
  }

  @override
  String libraryReturnedToDraft(String title) {
    return '$title फिर से ड्राफ़्ट में लाया गया.';
  }

  @override
  String libraryChangeFailed(String title) {
    return '$title को नहीं बदला जा सका. अपना कनेक्शन जाँचें और फिर से कोशिश करें.';
  }

  @override
  String libraryDeleted(String title) {
    return '$title मिटाया गया.';
  }

  @override
  String libraryRestoredAsDraft(String title) {
    return '$title ड्राफ़्ट के रूप में वापस लाया गया.';
  }

  @override
  String libraryArchived(String title) {
    return '$title संग्रहित किया गया.';
  }

  @override
  String get libraryPlaylistIsEmpty => 'प्लेलिस्ट खाली है.';

  @override
  String librarySelectedItem(String selected, String items) {
    return 'चुना गया आइटम $selected, कुल $items में से.';
  }

  @override
  String librarySelectedItemTitled(
    String selected,
    String items,
    String title,
  ) {
    return 'चुना गया आइटम $selected, कुल $items में से, $title.';
  }

  @override
  String get libraryAlreadyOneSubject =>
      'यह लाइब्रेरी पहले से एक ही विषय तक सीमित है';

  @override
  String get libraryNoLessonIsPlaying => 'कोई पाठ नहीं चल रहा है.';

  @override
  String libraryAddedToSession(String title) {
    return '$title इस सत्र में जोड़ा गया.';
  }

  @override
  String get libraryPlaylistNotCreated => 'प्लेलिस्ट नहीं बन सकी';

  @override
  String get libraryPrivatePlaylistNotCreated => 'निजी प्लेलिस्ट नहीं बन सकी';

  @override
  String get libraryNoEligibleAudio =>
      'जोड़ने के लिए कोई योग्य ऑडियो उपलब्ध नहीं है';

  @override
  String get libraryAudioAddedToPlaylist => 'ऑडियो प्लेलिस्ट में जोड़ा गया';

  @override
  String libraryUnavailable(String title) {
    return '$title उपलब्ध नहीं है';
  }

  @override
  String libraryPlaylistRenamed(String title) {
    return 'प्लेलिस्ट का नाम बदलकर $title किया गया';
  }

  @override
  String libraryMovedTo(String title, String position) {
    return '$title को स्थान $position पर ले जाया गया';
  }

  @override
  String get libraryNoteRenamed => 'निजी नोट का नाम बदला गया.';

  @override
  String get downloadNoneYet =>
      'अभी कोई डाउनलोड नहीं है. ऑनलाइन रिकॉर्डिंग खोजने के लिए 2 दबाएँ.';

  @override
  String downloadLessonCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count डाउनलोड किए गए पाठ',
      one: '1 डाउनलोड किया गया पाठ',
    );
    return '$_temp0';
  }

  @override
  String downloadPartialCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count अधूरे डाउनलोड',
      one: '1 अधूरा डाउनलोड',
    );
    return '$_temp0';
  }

  @override
  String downloadReadyToPlay(String lessons) {
    return '$lessons चलाने के लिए तैयार.';
  }

  @override
  String downloadReadyToPlayWithPartial(String lessons, String partial) {
    return '$lessons चलाने के लिए तैयार, $partial.';
  }

  @override
  String get downloadActionFailed =>
      'यह डाउनलोड काम पूरा नहीं हो सका. स्टोरेज, अपना कनेक्शन और साइन इन जाँचें, फिर से कोशिश करें.';

  @override
  String get downloadOnlineListFailed =>
      'उपलब्ध रिकॉर्डिंग लोड नहीं हो सकीं. मौजूदा डाउनलोड उनका एक्सेस खत्म होने तक काम करते रहेंगे.';

  @override
  String downloadAvailable(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count रिकॉर्डिंग डाउनलोड के लिए उपलब्ध हैं. अपनी चाही गई रिकॉर्डिंग चुनें.',
      one:
          '1 रिकॉर्डिंग डाउनलोड के लिए उपलब्ध है. अपनी चाही गई रिकॉर्डिंग चुनें.',
    );
    return '$_temp0';
  }

  @override
  String downloadStarting(String title) {
    return '$title डाउनलोड हो रहा है. आपको हर 25 प्रतिशत पर प्रगति सुनाई देगी.';
  }

  @override
  String downloadProgress(String title, String percent) {
    return '$title $percent डाउनलोड हुआ.';
  }

  @override
  String get downloadVerified =>
      'डाउनलोड जाँचा गया और ऑफ़लाइन सुनने के लिए सहेजा गया.';

  @override
  String downloadDone(String title) {
    return '$title डाउनलोड हुआ, जाँचा गया और ऑफ़लाइन सुनने के लिए सहेजा गया.';
  }

  @override
  String downloadPackQuestion(String recordings) {
    return '$recordings एक-एक करके डाउनलोड करें? इसमें इंटरनेट डेटा और आपके खाते की 50 MB सीमा का उपयोग होगा. विफल होने या रद्द करने पर, जाँचे गए डाउनलोड और अधूरा डेटा रखा जाएगा. कोई मौजूदा पाठ नहीं मिटाया जाएगा.';
  }

  @override
  String downloadPackStarting(String recordings) {
    return '$recordings एक-एक करके डाउनलोड हो रही हैं.';
  }

  @override
  String downloadPackProgress(String done, String total) {
    return '$total में से $done रिकॉर्डिंग जाँची गईं.';
  }

  @override
  String downloadPackDone(String done, String total) {
    return '$total में से $done रिकॉर्डिंग जाँची और सहेजी गईं.';
  }

  @override
  String downloadRenewed(String title) {
    return '$title का एक्सेस फिर से चालू हुआ. 30 दिन तक ऑफ़लाइन सुन सकते हैं.';
  }

  @override
  String downloadRemoveTitle(String title) {
    return '$title का डाउनलोड हटाएँ?';
  }

  @override
  String downloadRemoveQuestion(String title) {
    return '$title का डाउनलोड किया गया या अधूरा ऑडियो हटाएँ? सीखने की प्रगति और बुकमार्क रखे जाएँगे. दूसरी रिकॉर्डिंग और खातों पर कोई असर नहीं होगा.';
  }

  @override
  String downloadRemoved(String title) {
    return '$title का डाउनलोड हटाया गया. प्रगति और बुकमार्क रखे गए.';
  }

  @override
  String downloadUnreadableTitle(String id) {
    return 'न पढ़ी जा सकने वाली रिकॉर्डिंग $id';
  }

  @override
  String get downloadRenewalRequired => 'एक्सेस फिर से चालू करना ज़रूरी है.';

  @override
  String downloadAccessExpires(String date) {
    return 'एक्सेस $date खत्म होगा.';
  }

  @override
  String downloadPlayLabelComplete(String title, String size, String expiry) {
    return '$title चलाएँ. डाउनलोड हो चुका है. $size. $expiry';
  }

  @override
  String downloadPlayLabelPartial(String title, String size, String expiry) {
    return '$title चलाएँ. अधूरा डाउनलोड, अभी नहीं चल सकता. $size. $expiry';
  }

  @override
  String downloadRenewLabel(String title) {
    return '$title का एक्सेस फिर से चालू करें. इंटरनेट चाहिए';
  }

  @override
  String downloadRemoveLabel(String title) {
    return '$title का डाउनलोड हटाएँ, पुष्टि पूछी जाएगी';
  }

  @override
  String downloadUnreadableLabel(String id) {
    return 'न पढ़ा जा सकने वाला डाउनलोड रिकॉर्ड $id. सिर्फ़ यह डाउनलोड हटाएँ, पुष्टि पूछी जाएगी';
  }

  @override
  String downloadOrResumeLabel(String title) {
    return '$title डाउनलोड करें या फिर से शुरू करें';
  }

  @override
  String downloadCancelLabel(String title) {
    return '$title का डाउनलोड रद्द करें, बटन 4. अधूरा डेटा फिर से कोशिश के लिए रखें';
  }

  @override
  String downloadUnavailableWhileBusy(String label) {
    return 'डाउनलोड चलते समय $label उपलब्ध नहीं है.';
  }

  @override
  String get downloadStorageUnknown =>
      'स्टोरेज आरक्षण उपलब्ध नहीं है. डाउनलोड करने से पहले डाउनलोड रिफ़्रेश करें या चुने गए न पढ़े जा सकने वाले रिकॉर्ड हटाएँ.';

  @override
  String downloadCountComma(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count डाउनलोड,',
      one: '1 डाउनलोड,',
    );
    return '$_temp0';
  }

  @override
  String get downloadStorageUseUnknown => 'स्टोरेज उपयोग पता नहीं.';

  @override
  String downloadDownloadingStarting(String title) {
    return '$title डाउनलोड हो रहा है, शुरू हो रहा है.';
  }

  @override
  String downloadDownloadingPercent(String title, String percent) {
    return '$title डाउनलोड हो रहा है, $percent.';
  }

  @override
  String downloadScreenLoaded(String complete) {
    return '$complete डाउनलोड किए गए पाठ चलाने के लिए तैयार.';
  }

  @override
  String downloadScreenLoadedWithPartial(String complete, String partial) {
    return '$complete डाउनलोड किए गए पाठ चलाने के लिए तैयार, $partial अधूरे डाउनलोड.';
  }

  @override
  String downloadAvailableCount(String count) {
    return '$count रिकॉर्डिंग डाउनलोड के लिए उपलब्ध हैं. अपनी चाही गई रिकॉर्डिंग चुनें.';
  }

  @override
  String downloadRecordingFallback(String id) {
    return 'रिकॉर्डिंग $id';
  }

  @override
  String get downloadPackDialogTitle => 'सूची की रिकॉर्डिंग डाउनलोड करें?';

  @override
  String downloadPackDialogMessage(String count) {
    return 'सूची की $count रिकॉर्डिंग एक-एक करके डाउनलोड करें? इसमें इंटरनेट डेटा और आपके खाते की 50 MB सीमा का उपयोग होगा. विफल होने या रद्द करने पर, जाँचे गए डाउनलोड और अधूरा डेटा रखा जाएगा. कोई मौजूदा पाठ नहीं मिटाया जाएगा.';
  }

  @override
  String get downloadPackConfirm => 'सूची वाली डाउनलोड करें';

  @override
  String get downloadPackCancel => 'एक-एक करके चुनें';

  @override
  String get downloadRemoveConfirm => 'डाउनलोड हटाएँ';

  @override
  String get downloadKeep => 'डाउनलोड रखें';

  @override
  String get downloadScreenName => 'डाउनलोड किए गए पाठ';

  @override
  String get downloadCancelBackTitle => 'डाउनलोड रद्द करके वापस जाएँ?';

  @override
  String get downloadCancelBackMessage =>
      'यह डाउनलोड रोकें? जाँची गई रिकॉर्डिंग और अधूरा डेटा, आपके दोबारा कोशिश करने के लिए रखे जाएँगे.';

  @override
  String get downloadCancelBackConfirm => 'रद्द करें और वापस जाएँ';

  @override
  String get downloadKeepDownloading => 'डाउनलोड जारी रखें';

  @override
  String downloadReserved(String megabytes) {
    return 'इस खाते के लिए 50 MB में से $megabytes आरक्षित.';
  }

  @override
  String get downloadBack => 'वापस';

  @override
  String get downloadRefreshLabel => 'सहेजे गए डाउनलोड रिफ़्रेश करें, बटन 1';

  @override
  String get downloadFindOnlineLabel =>
      'डाउनलोड के लिए रिकॉर्डिंग खोजें, बटन 2. इंटरनेट चाहिए';

  @override
  String get downloadReadStatusLabel => 'डाउनलोड की स्थिति सुनें, बटन 3';

  @override
  String downloadPlayDownloadedLabel(String title) {
    return '$title चलाएँ. डाउनलोड हो चुका है';
  }

  @override
  String downloadPlayPartialLabel(String title) {
    return '$title चलाएँ. अधूरा डाउनलोड, अभी नहीं चल सकता';
  }

  @override
  String get downloadPackLabel =>
      'सूची की सभी रिकॉर्डिंग डाउनलोड करें, बटन 5, पुष्टि पूछी जाएगी';

  @override
  String get downloadIntroduction =>
      'हर खाते के लिए 50 MB. ऑनलाइन एक्सेस फिर से चालू करने से पहले 30 दिन तक ऑफ़लाइन. फ़ाइलें और प्रगति अलग-अलग रहती हैं.';

  @override
  String get downloadNavigationSections =>
      'चलाने, फिर से चालू करने या हटाने के लिए सहेजी गई फ़ाइलें, और डाउनलोड करने या फिर से शुरू करने के लिए ऑनलाइन रिकॉर्डिंग';

  @override
  String get downloadKeyRefresh => 'डाउनलोड रिफ़्रेश करें';

  @override
  String get downloadKeyFindOnline => 'ऑनलाइन रिकॉर्डिंग खोजें';

  @override
  String get downloadKeyReadStatus => 'स्थिति सुनें';

  @override
  String get downloadKeyCancel => 'डाउनलोड रद्द करें';

  @override
  String get downloadKeyPack => 'सूची की रिकॉर्डिंग डाउनलोड करें';

  @override
  String get downloadErrInvalidInfo =>
      'डाउनलोड की जानकारी गलत है या किसी दूसरे खाते की है. मौजूदा फ़ाइलें रखी गई हैं.';

  @override
  String get downloadErrSignInToOpen =>
      'डाउनलोड किए गए पाठ खोलने से पहले साइन इन करें.';

  @override
  String get downloadErrAccountChanged =>
      'आपका खाता बदल गया है. डाउनलोड फिर से खोलें.';

  @override
  String get downloadErrNoStorage =>
      'इस डिवाइस पर डाउनलोड स्टोरेज उपलब्ध नहीं है.';

  @override
  String get downloadErrStorageUnavailable =>
      'डाउनलोड स्टोरेज उपलब्ध नहीं है. खाली जगह जाँचें और फिर से कोशिश करें. मौजूदा फ़ाइलें जानबूझकर नहीं हटाई गई हैं.';

  @override
  String get downloadErrRecordsUnreadable =>
      'डाउनलोड रिकॉर्ड पढ़े नहीं जा सके. मौजूदा फ़ाइलें रखी गई हैं.';

  @override
  String get downloadErrRecordUnreadable =>
      'एक डाउनलोड रिकॉर्ड पढ़ा नहीं जा सका. मौजूदा फ़ाइलें रखी गई हैं.';

  @override
  String get downloadErrIdentityMismatch =>
      'डाउनलोड की पहचान उसके रिकॉर्ड से मेल नहीं खाती.';

  @override
  String get downloadErrSignInToRenew =>
      'डाउनलोड एक्सेस फिर से चालू करने से पहले ऑनलाइन साइन इन करें.';

  @override
  String get downloadErrSignInChanged =>
      'आपका साइन इन बदल गया है. डाउनलोड फिर से खोलें.';

  @override
  String get downloadErrAccessNotConfirmed =>
      'इस खाते के लिए रिकॉर्डिंग का एक्सेस अब पक्का नहीं है. फिर से चालू करने के लिए दोबारा कनेक्ट करें और साइन इन करें. सहेजी गई फ़ाइल रखी गई है.';

  @override
  String get downloadErrTooLarge =>
      'यह रिकॉर्डिंग 50 MB की डाउनलोड सीमा से बड़ी है.';

  @override
  String get downloadErrRenewServer =>
      'सर्वर इस रिकॉर्डिंग को फिर से चालू नहीं कर सका. बाद में फिर से कोशिश करें.';

  @override
  String get downloadErrInvalidServerInfo =>
      'सर्वर ने गलत डाउनलोड जानकारी भेजी.';

  @override
  String get downloadErrDifferentRecording =>
      'सर्वर ने कोई दूसरी रिकॉर्डिंग भेजी.';

  @override
  String get downloadErrTimedOut =>
      'कनेक्शन का समय खत्म हो गया. दोबारा कनेक्ट करें और फिर से कोशिश करें.';

  @override
  String get downloadErrRenewConnect =>
      'इस रिकॉर्डिंग को फिर से चालू करने के लिए कनेक्ट नहीं हो सका. अपना इंटरनेट कनेक्शन जाँचें.';

  @override
  String get downloadErrClockUnreadable =>
      'ऑफ़लाइन समय का रिकॉर्ड पढ़ा नहीं जा सका. कनेक्ट करें और एक्सेस फिर से चालू करें.';

  @override
  String get downloadErrClockBackwards =>
      'फ़ोन की घड़ी पीछे चली गई है. उसकी तारीख ठीक करें और एक्सेस फिर से चालू करने के लिए दोबारा कनेक्ट करें.';

  @override
  String get downloadErrExpired =>
      '30 दिन के बाद ऑफ़लाइन एक्सेस खत्म हो गया. इंटरनेट से कनेक्ट करें और इस पाठ को फिर से चालू करें. आपकी प्रगति और डाउनलोड की गई फ़ाइल रखी गई हैं.';

  @override
  String get downloadErrIncompleteForPlayback =>
      'ऑफ़लाइन सुनने से पहले इस पाठ को पूरा डाउनलोड करें.';

  @override
  String get downloadErrRenewalRequired =>
      'एक्सेस फिर से चालू करना ज़रूरी है. यह डाउनलोड चलाने से पहले कनेक्ट करें और फिर से चालू करें.';

  @override
  String get downloadErrDamaged =>
      'डाउनलोड की गई रिकॉर्डिंग अधूरी है या खराब है. यह डाउनलोड हटाएँ और फिर से डाउनलोड करें. प्रगति और बुकमार्क अलग रहते हैं.';

  @override
  String get downloadErrDownloadFirst => 'पहले यह पाठ डाउनलोड करें.';

  @override
  String get downloadErrRecordingChangedRenew =>
      'यह रिकॉर्डिंग बदल गई है. इसका डाउनलोड हटाएँ और मौजूदा रिकॉर्डिंग डाउनलोड करें. प्रगति और बुकमार्क रखे गए हैं.';

  @override
  String get downloadErrCancelledAnyPartial =>
      'डाउनलोड रद्द हुआ. कोई भी अधूरी फ़ाइल, आपके दोबारा कोशिश करने के लिए रखी गई है.';

  @override
  String get downloadErrRecordingChanged =>
      'रिकॉर्डिंग बदल गई है. मौजूदा संस्करण डाउनलोड करने से पहले उसका पुराना डाउनलोड हटाएँ. प्रगति रखी गई है.';

  @override
  String get downloadErrSavedDamaged =>
      'सहेजी गई रिकॉर्डिंग खराब है. फिर से कोशिश करने से पहले उसका डाउनलोड हटाएँ.';

  @override
  String get downloadErrQuota =>
      'आपका खाता 50 MB की डाउनलोड सीमा तक पहुँच गया है. चुनें कि अपने कौन-से डाउनलोड हटाने हैं, फिर से कोशिश करें. कुछ भी नहीं मिटाया गया.';

  @override
  String get downloadErrPartialInvalid =>
      'अधूरा डाउनलोड सही नहीं है। फिर से कोशिश करने से पहले इसे हटाएँ।';

  @override
  String get downloadErrIntegrityPartial =>
      'डाउनलोड की जाँच विफल रही। फिर से कोशिश करने से पहले यह अधूरा डाउनलोड हटाएँ।';

  @override
  String get downloadErrSignInToDownload =>
      'डाउनलोड करने से पहले साइन इन करें।';

  @override
  String get downloadErrCancelledExplicit =>
      'डाउनलोड रद्द किया गया। अधूरा डेटा रखा गया है, ताकि आप खुद फिर से कोशिश कर सकें।';

  @override
  String get downloadErrAccessDenied =>
      'डाउनलोड की अनुमति नहीं मिली। फिर से कनेक्ट करें और अनुमति नवीनीकृत करें।';

  @override
  String get downloadErrUnexpectedPartial =>
      'सर्वर ने अनपेक्षित अधूरी रिकॉर्डिंग भेजी। मौजूदा डेटा हटाए बिना फिर से कोशिश करें।';

  @override
  String get downloadErrCouldNotDownload =>
      'रिकॉर्डिंग डाउनलोड नहीं हो सकी। अपना कनेक्शन जाँचें और फिर से कोशिश करें।';

  @override
  String get downloadErrSizeChanged =>
      'रिकॉर्डिंग का आकार बदल गया। फिर से डाउनलोड करें।';

  @override
  String get downloadErrAccountChangedStopped =>
      'आपका खाता बदल गया। डाउनलोड रोक दिया गया।';

  @override
  String get downloadErrExceededSize =>
      'रिकॉर्डिंग बताए गए आकार से बड़ी हो गई। डाउनलोड रोक दिया गया।';

  @override
  String get downloadErrIntegrity =>
      'डाउनलोड की जाँच विफल रही। अधूरा डाउनलोड फिर से करें, या फिर से कोशिश करने से पहले खराब अधूरा डेटा हटाएँ।';

  @override
  String get downloadErrSignInChangedStopped =>
      'आपका साइन इन बदल गया। इंस्टॉल होने से पहले डाउनलोड रोक दिया गया।';

  @override
  String get downloadErrTimedOutPartial =>
      'डाउनलोड का समय समाप्त हो गया। अधूरा डेटा रखा गया है; फिर से कोशिश करने के लिए डाउनलोड चुनें।';

  @override
  String get downloadErrCancelledRetry =>
      'डाउनलोड रद्द किया गया। फिर से कोशिश करने के लिए अधूरा डेटा रखा गया है।';

  @override
  String get downloadErrInterrupted =>
      'डाउनलोड बीच में रुक गया। अधूरा डेटा रखा गया है; फिर से कोशिश करने के लिए डाउनलोड चुनें।';

  @override
  String get libraryErrStorageUnavailable =>
      'इस डिवाइस पर सीखने का स्टोरेज उपलब्ध नहीं है। आपका मौजूदा डेटा नहीं बदला गया है।';

  @override
  String get libraryErrStorageNotOpened =>
      'सीखने का स्टोरेज खुल नहीं सका। खाली जगह जाँचें और फिर से कोशिश करें।';

  @override
  String get libraryErrNoStorageLocation =>
      'इस डिवाइस ने सीखने के स्टोरेज की जगह नहीं दी। आपका मौजूदा डेटा नहीं बदला गया है।';

  @override
  String get libraryErrStartLessonFirst =>
      'प्रगति सहेजने की फिर से कोशिश करने से पहले कोई पाठ शुरू करें।';

  @override
  String get libraryErrProgressNotSaved =>
      'सीखने की प्रगति सहेजी नहीं गई। स्टोरेज उपलब्ध होने पर फिर से कोशिश करें।';

  @override
  String get libraryErrChoosePosition => 'पाठ के अंदर कोई जगह चुनें';

  @override
  String get libraryErrChooseSpeed => '0.25 से 3 तक चलाने की गति चुनें';

  @override
  String get libraryErrChooseBookmarkPosition =>
      'पाठ के अंदर बुकमार्क की जगह चुनें';

  @override
  String get libraryErrBookmarkNotSaved =>
      'प्रगति सहेजना उपलब्ध नहीं है। बुकमार्क सहेजा नहीं गया।';

  @override
  String get libraryErrBookmarkChangesUnavailable =>
      'प्रगति सहेजना ठीक होने तक बुकमार्क में बदलाव नहीं किए जा सकते।';

  @override
  String get libraryErrRepeatNotSaved =>
      'प्रगति सहेजना उपलब्ध नहीं है। दोहराने के बिंदु सहेजे नहीं गए।';

  @override
  String get libraryErrSetRepeatFirst =>
      'पहले इस पाठ में एक शुरुआती बिंदु और उसके बाद का एक अंतिम बिंदु तय करें';

  @override
  String get libraryErrRepeatFailed =>
      'दोहराकर चलाना विफल रहा। रोकें और फिर से कोशिश करें।';

  @override
  String get libraryScreenBack => 'वापस';

  @override
  String get libraryScreenRefreshTarget => 'ऑडियो फ़ाइलें रीफ़्रेश करें, बटन 1';

  @override
  String get libraryScreenPauseSessionTarget =>
      'पूरे सत्र के लिए ऑडियो रोकें, बटन 3';

  @override
  String get libraryScreenUploadTarget => 'ऑडियो अपलोड करें, बटन 2';

  @override
  String libraryScreenStopPreviewTarget(String title) {
    return '$title का निजी प्रीव्यू रोकें। इसे सिर्फ़ आप सुन सकते हैं।';
  }

  @override
  String libraryScreenPreviewTarget(String title) {
    return '$title का निजी प्रीव्यू सुनें। इसे सिर्फ़ आप सुन सकते हैं।';
  }

  @override
  String libraryScreenBroadcastTarget(String title) {
    return 'सत्र में सभी के लिए $title चलाएँ';
  }

  @override
  String get libraryScreenPreviewFinished => 'प्रीव्यू पूरा हुआ';

  @override
  String get libraryScreenNoRecordings =>
      'अभी कोई रिकॉर्डिंग नहीं है। ऑडियो अपलोड करने के लिए 2 दबाएँ।';

  @override
  String libraryScreenRecordingsLoaded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count रिकॉर्डिंग लोड हुईं।',
    );
    return '$_temp0';
  }

  @override
  String get libraryScreenLoadFailed =>
      'रिकॉर्डिंग लोड नहीं हो सकीं। अपना इंटरनेट कनेक्शन जाँचें, फिर दोबारा कोशिश करने के लिए 1 दबाएँ।';

  @override
  String get libraryScreenTitleRequired => 'शीर्षक ज़रूरी है';

  @override
  String get libraryScreenUploadDialogName => 'ऑडियो अपलोड करें';

  @override
  String get libraryScreenEditTitleKey => 'शीर्षक बदलें';

  @override
  String get libraryScreenEditDescriptionKey => 'विवरण बदलें';

  @override
  String get libraryScreenUploadKey => 'अपलोड करें';

  @override
  String get libraryScreenCancelKey => 'रद्द करें';

  @override
  String get libraryScreenTitleField => 'ऑडियो का शीर्षक, ज़रूरी';

  @override
  String get libraryScreenDescriptionField => 'ऑडियो का विवरण, वैकल्पिक';

  @override
  String get libraryScreenCancelUpload => 'अपलोड रद्द करें';

  @override
  String get libraryScreenPickFailed => 'फ़ाइल नहीं चुनी जा सकी';

  @override
  String get libraryScreenChooseWorkspace =>
      'ऑडियो अपलोड करने से पहले शिक्षक डैशबोर्ड पर कक्षा और विषय का वर्कस्पेस चुनें।';

  @override
  String libraryScreenUploading(String title) {
    return '$title अपलोड हो रहा है। हर 25 प्रतिशत पर आपको प्रगति सुनाई देगी।';
  }

  @override
  String libraryScreenUploaded(String title) {
    return '$title अपलोड हो गया।';
  }

  @override
  String libraryScreenUploadProgress(String title, String percent) {
    return '$title: $percent प्रतिशत अपलोड हुआ।';
  }

  @override
  String libraryScreenPreviewStopped(String title) {
    return '$title का प्रीव्यू रोका गया';
  }

  @override
  String libraryScreenPreviewing(String title) {
    return '$title का निजी प्रीव्यू चल रहा है';
  }

  @override
  String libraryScreenPlayFailed(String title) {
    return '$title नहीं चल सका। अपना कनेक्शन जाँचें और फिर से कोशिश करें।';
  }

  @override
  String get libraryScreenNoActiveSession => 'कोई सक्रिय सत्र नहीं है';

  @override
  String libraryScreenSelectedForSession(String title) {
    return 'सत्र के लिए $title चुना गया';
  }

  @override
  String get libraryScreenAudioSelectedTitle => 'ऑडियो चुना गया';

  @override
  String libraryScreenPlayForEveryoneNow(String title) {
    return 'क्या सत्र में सभी के लिए अभी \"$title\" चलाएँ?';
  }

  @override
  String get libraryScreenNotYet => 'अभी नहीं';

  @override
  String get libraryScreenPlayNow => 'अभी चलाएँ';

  @override
  String get libraryScreenSelectFailed => 'ऑडियो नहीं चुना जा सका';

  @override
  String get libraryScreenPlaybackAccepted =>
      'कक्षा में चलाने का अनुरोध स्वीकार हुआ';

  @override
  String get libraryScreenPlaybackFailed => 'चलाना शुरू नहीं हो सका';

  @override
  String get libraryScreenPauseAccepted =>
      'कक्षा में रोकने का अनुरोध स्वीकार हुआ';

  @override
  String get libraryScreenPauseFailed => 'ऑडियो रोका नहीं जा सका';

  @override
  String get libraryScreenAudioLibraryName => 'ऑडियो लाइब्रेरी';

  @override
  String get libraryScreenAudioLibrarySections =>
      'रिकॉर्डिंग, चलाने और आवाज़ के नियंत्रण, रिकॉर्डिंग साझा करना, और उपलब्ध होने पर अपलोड टूल';

  @override
  String get libraryScreenRefreshKey => 'ऑडियो फ़ाइलें रीफ़्रेश करें';

  @override
  String get libraryScreenUploadAudioKey => 'ऑडियो अपलोड करें';

  @override
  String get libraryScreenPauseSessionKey => 'सत्र का ऑडियो रोकें';

  @override
  String get libraryScreenBrowseTarget =>
      'पहली सक्रिय कक्षा पर जाएँ। सक्रिय सत्र देखने के लिए D-pad का उपयोग करें';

  @override
  String get libraryScreenRefreshClassesTarget => 'कक्षाएँ रीफ़्रेश करें';

  @override
  String get libraryScreenSearchClassField => 'नाम से कक्षा खोजें';

  @override
  String get libraryScreenSearchTarget => 'खोजें';

  @override
  String get libraryScreenAllRecordedTarget =>
      'सभी रिकॉर्ड की गई ऑडियो फ़ाइलें';

  @override
  String get libraryScreenContinueTarget =>
      'सीखना जारी रखें। अपना पिछला अधूरा रिकॉर्ड किया गया पाठ खोजें';

  @override
  String get libraryScreenDownloadsTarget =>
      'डाउनलोड किए गए पाठ। ऑनलाइन सूचियाँ लोड किए बिना सहेजी गई रिकॉर्डिंग खोलें';

  @override
  String get libraryScreenNotesTarget =>
      'निजी नोट और शिक्षक की रिकॉर्डिंग के ड्राफ़्ट। फ़ोन के स्टोरेज से चलता है';

  @override
  String get libraryScreenMyPlaylistsTarget => 'मेरी निजी प्लेलिस्ट';

  @override
  String libraryScreenClassTarget(String title, String position, String total) {
    return '$title। $total में से कक्षा $position';
  }

  @override
  String get libraryScreenAccountChanged =>
      'आपका खाता बदल गया। लाइब्रेरी फिर से खोलें।';

  @override
  String get libraryScreenNoUnfinishedLesson =>
      'इस खाते के लिए कोई अधूरा पाठ सहेजा नहीं गया है। सीखना शुरू करने के लिए कोई रिकॉर्ड किया गया पाठ चुनें।';

  @override
  String get libraryScreenAccessCheckFailed =>
      'पाठ की अनुमति जाँची नहीं जा सकी। इंटरनेट से जुड़ें और फिर से कोशिश करें। आपकी सहेजी गई प्रगति रखी गई है।';

  @override
  String get libraryScreenUnfinishedUnavailable =>
      'आपके अधूरे पाठ अभी इस लाइब्रेरी में उपलब्ध नहीं हैं। आपकी सहेजी गई प्रगति और बुकमार्क रखे गए हैं।';

  @override
  String get libraryScreenOpeningNextUnfinished =>
      'सबसे हाल का पाठ यहाँ उपलब्ध नहीं है। आपका अगला सबसे हाल का उपलब्ध अधूरा पाठ खुल रहा है। सहेजी गई प्रगति रखी गई है।';

  @override
  String get libraryScreenProgressOpenFailed =>
      'सहेजी गई सीखने की प्रगति खुल नहीं सकी। स्टोरेज, अपना कनेक्शन और साइन इन जाँचें, फिर से कोशिश करें।';

  @override
  String get libraryScreenContinueLearningTitle => 'सीखना जारी रखें';

  @override
  String get libraryScreenNoActiveClasses =>
      'अभी कोई सक्रिय कक्षा नहीं है। सभी ऑडियो फ़ाइलों के लिए 3 दबाएँ।';

  @override
  String libraryScreenActiveClassesLoaded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count सक्रिय कक्षाएँ लोड हुईं।',
    );
    return '$_temp0';
  }

  @override
  String libraryScreenClassesRefreshFailed(String reason) {
    return '$reason सक्रिय कक्षाएँ रीफ़्रेश नहीं हो सकीं। फिर से कोशिश करने के लिए 1 दबाएँ। सहेजे गए डाउनलोड उपलब्ध रहेंगे।';
  }

  @override
  String get libraryScreenClassListUnreadable =>
      'कक्षा की सूची पढ़ी नहीं जा सकी।';

  @override
  String get libraryScreenSessionFallback => 'सत्र';

  @override
  String get libraryScreenMyAudioLibraryTitle => 'मेरी ऑडियो लाइब्रेरी';

  @override
  String get libraryScreenAllAudioFilesTitle => 'सभी ऑडियो फ़ाइलें';

  @override
  String get libraryScreenNoActiveClassesStaying =>
      'कोई सक्रिय कक्षा नहीं है। ऑडियो लाइब्रेरी में ही रह रहे हैं।';

  @override
  String libraryScreenFirstActiveClass(String title) {
    return '$title। पहली सक्रिय कक्षा। सक्रिय कक्षा सत्र देखने के लिए D-pad ऊपर और नीचे का उपयोग करें। चुनी गई कक्षा की रिकॉर्डिंग खोलने के लिए ओके दबाएँ।';
  }

  @override
  String get libraryScreenRecordedLibraryName =>
      'रिकॉर्ड की गई ऑडियो लाइब्रेरी। ऑनलाइन सूचियों के लिए इंटरनेट ज़रूरी है। डाउनलोड किए गए पाठ ऑफ़लाइन चलाने के लिए अलग से खुलते हैं।';

  @override
  String get libraryScreenRecordedLibrarySections =>
      'सीखना जारी रखें, सहेजे गए डाउनलोड और निजी नोट, कक्षा खोज, और सक्रिय कक्षा सत्र';

  @override
  String get libraryScreenMyPlaylistsKey => 'मेरी निजी प्लेलिस्ट';

  @override
  String get libraryScreenWaitForPlayerNotes =>
      'पढ़ाई के नोट खोलने से पहले रिकॉर्डिंग प्लेयर का इंतज़ार करें।';

  @override
  String get libraryScreenStatusPlaying => 'चल रहा है';

  @override
  String get libraryScreenStatusPaused => 'रुका हुआ';

  @override
  String get libraryScreenUntitled => 'बिना शीर्षक';

  @override
  String get libraryScreenSubjectFallback => 'विषय';

  @override
  String get libraryScreenDownloadedLessonsName =>
      'डाउनलोड किए गए पाठ। चलाने से पहले मौजूदा ऑफ़लाइन अनुमति जाँची जाती है।';

  @override
  String get libraryScreenClassAudioName =>
      'ऑडियो लाइब्रेरी। ऑनलाइन रिकॉर्डिंग के लिए इंटरनेट ज़रूरी है। ऑफ़लाइन चलाने के लिए पाठ डाउनलोड करें।';

  @override
  String libraryScreenLessonPositionTarget(String position) {
    return 'पाठ की जगह $position। 10 सेकंड आगे-पीछे जाने के लिए बाएँ या दाएँ का उपयोग करें।';
  }

  @override
  String libraryScreenBack10Target(String key) {
    return '10 सेकंड पीछे, बटन $key';
  }

  @override
  String libraryScreenPauseTarget(String title, String key) {
    return '$title रोकें, बटन $key';
  }

  @override
  String libraryScreenResumeTarget(String title, String key) {
    return '$title फिर से चलाएँ, बटन $key';
  }

  @override
  String get libraryScreenLessonFallback => 'पाठ';

  @override
  String libraryScreenForward10Target(String key) {
    return '10 सेकंड आगे, बटन $key';
  }

  @override
  String libraryScreenSlowerTarget(String key, String speed) {
    return 'धीमा, बटन $key। अभी $speed गुना';
  }

  @override
  String libraryScreenStopTarget(String title) {
    return '$title बंद करें, बटन 8';
  }

  @override
  String libraryScreenFasterTarget(String key, String speed) {
    return 'तेज़, बटन $key। अभी $speed गुना';
  }

  @override
  String get libraryScreenDownloadsManageTarget =>
      'पाठ डाउनलोड करें या सहेजी गई रिकॉर्डिंग प्रबंधित करें';

  @override
  String get libraryScreenStopSpeechTarget => 'आवाज़ बंद करें';

  @override
  String get libraryScreenUploadFirstTarget => 'पहला ऑडियो अपलोड करें';

  @override
  String get libraryScreenRefreshEmptyTarget =>
      'खाली ऑडियो लाइब्रेरी रीफ़्रेश करें';

  @override
  String get libraryScreenAddAudioTarget => 'ऑडियो जोड़ें, बटन 3';

  @override
  String get libraryScreenLessonTitleFallback => 'पाठ';

  @override
  String get libraryScreenDownloadedDescription =>
      'डाउनलोड की गई रिकॉर्डिंग। 30 दिनों के बाद अनुमति नवीनीकृत करनी होगी।';

  @override
  String libraryScreenSavedSubject(String id) {
    return 'सहेजा गया विषय $id';
  }

  @override
  String get libraryScreenDownloadsReadFailed =>
      'डाउनलोड किए गए पाठ पढ़े नहीं जा सके। फिर से कोशिश करने के लिए 1 दबाएँ।';

  @override
  String get libraryScreenLoadFailedSignIn =>
      'रिकॉर्डिंग लोड नहीं हो सकीं। अपना इंटरनेट कनेक्शन और साइन इन जाँचें, फिर दोबारा कोशिश करने के लिए 1 दबाएँ।';

  @override
  String libraryScreenNoRecordingsFor(String name) {
    return '$name के लिए अभी कोई रिकॉर्डिंग नहीं है।';
  }

  @override
  String libraryScreenRecordingsLoadedFor(int count, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$name के लिए $count रिकॉर्डिंग लोड हुईं।',
    );
    return '$_temp0';
  }

  @override
  String get libraryScreenLessonNoLongerAvailable =>
      'यह पाठ अब उपलब्ध नहीं है। आपकी सहेजी गई प्रगति और बुकमार्क रखे गए हैं।';

  @override
  String libraryScreenFailurePressRetry(String reason) {
    return '$reason फिर से कोशिश करने के लिए 1 दबाएँ।';
  }

  @override
  String libraryScreenSubjectNumber(String id) {
    return 'विषय $id';
  }

  @override
  String get libraryScreenShowingAllSubjects =>
      'सभी विषयों का ऑडियो दिखाया जा रहा है';

  @override
  String libraryScreenShowingSubject(String subject, String count) {
    return '$subject का ऑडियो दिखाया जा रहा है। $count फ़ाइलें';
  }

  @override
  String libraryScreenPausedAt(String position) {
    return '$position पर रुका।';
  }

  @override
  String get libraryScreenCheckingOfflineAccess =>
      'इंटरनेट उपलब्ध नहीं है। आपकी सहेजी गई ऑफ़लाइन अनुमति जाँची जा रही है।';

  @override
  String libraryScreenPlayFailedSelectAgain(String title) {
    return '$title नहीं चल सका। अपना कनेक्शन जाँचें, फिर इसे दोबारा चुनें।';
  }

  @override
  String get libraryScreenNothingPlaying => 'कुछ भी नहीं चल रहा है।';

  @override
  String libraryScreenTitleStopped(String title) {
    return '$title बंद हुआ।';
  }

  @override
  String libraryScreenNoLessonPlayingPress(String key) {
    return 'कोई पाठ नहीं चल रहा है। पहला पाठ चलाने के लिए $key दबाएँ।';
  }

  @override
  String get libraryScreenSeekFailed =>
      'पाठ की उस जगह पर नहीं जा सके। फिर से कोशिश करें।';

  @override
  String get libraryScreenSlowestSpeed => 'पहले से ही सबसे धीमी गति है।';

  @override
  String get libraryScreenFastestSpeed => 'पहले से ही सबसे तेज़ गति है।';

  @override
  String get libraryScreenSpeedFailed =>
      'चलाने की गति नहीं बदल सकी। फिर से कोशिश करें।';

  @override
  String get libraryScreenReadFileFailed => 'फ़ाइल का डेटा पढ़ा नहीं जा सका।';

  @override
  String get libraryScreenTitleFieldPlain => 'ऑडियो का शीर्षक';

  @override
  String get libraryScreenChooseSessionsName => 'इस ऑडियो के लिए सत्र चुनें';

  @override
  String get libraryScreenConfirmSessionsKey => 'चुने गए सत्र पक्का करें';

  @override
  String libraryScreenSessionNumber(String id) {
    return 'सत्र $id';
  }

  @override
  String libraryScreenSessionSelected(String name) {
    return '$name, चुना गया';
  }

  @override
  String libraryScreenSessionNotSelected(String name) {
    return '$name, नहीं चुना गया';
  }

  @override
  String libraryScreenConfirmSelectedSessions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'चुने गए $count सत्र पक्का करें',
    );
    return '$_temp0';
  }

  @override
  String get libraryScreenUploadCancelledNoSession =>
      'अपलोड रद्द किया गया। कम से कम एक सत्र चुनें, फिर ऑडियो फिर से जोड़ने के लिए 3 दबाएँ।';

  @override
  String libraryScreenUploadingWait(String title) {
    return '$title अपलोड हो रहा है। कृपया इंतज़ार करें; पूरा होने पर आपको सुनाई देगा।';
  }

  @override
  String get libraryScreenClassSubjectUnknown =>
      'सत्र की कक्षा और विषय पता नहीं चल सके';

  @override
  String libraryScreenUploadFailedRetry(String title) {
    return '$title अपलोड नहीं हो सका। अपना कनेक्शन जाँचें, फिर से कोशिश करने के लिए 3 दबाएँ।';
  }

  @override
  String get libraryScreenAudioFallback => 'ऑडियो';

  @override
  String get libraryScreenClassLibraryName => 'कक्षा ऑडियो लाइब्रेरी';

  @override
  String get libraryScreenClassLibrarySections =>
      'चलाने के नियंत्रण, बुकमार्क और सीखने की प्रगति, विषय फ़िल्टर, डाउनलोड, रिकॉर्डिंग, और उपलब्ध होने पर शिक्षक के अपलोड टूल';

  @override
  String get libraryScreenSubjectFilterField => 'विषय फ़िल्टर (बटन 2)';

  @override
  String get libraryScreenAllSubjects => 'सभी विषय';

  @override
  String get libraryScreenAddAudioOptionsName => 'ऑडियो जोड़ने के विकल्प';

  @override
  String get libraryScreenCloseAddAudioTarget =>
      'ऑडियो जोड़ने के विकल्प बंद करें';

  @override
  String get libraryScreenUploadNewTarget => 'नई फ़ाइल अपलोड करें, बटन 1';

  @override
  String get libraryScreenSelectExistingTarget =>
      'मौजूदा लाइब्रेरी से चुनें, बटन 2';

  @override
  String libraryScreenRecordingsAvailable(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count रिकॉर्डिंग उपलब्ध हैं।',
    );
    return '$_temp0';
  }

  @override
  String libraryScreenNoRecordingsMatch(String query) {
    return '$query से कोई रिकॉर्डिंग नहीं मिली।';
  }

  @override
  String libraryScreenRecordingsMatch(int count, String query) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$query से $count रिकॉर्डिंग मिलीं।',
    );
    return '$_temp0';
  }

  @override
  String get libraryScreenNoUnlinkedRecordings =>
      'इस कक्षा के लिए कोई बिना जुड़ी रिकॉर्डिंग उपलब्ध नहीं है।';

  @override
  String libraryScreenRecordingsAvailableChoose(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count रिकॉर्डिंग उपलब्ध हैं। चुनने के लिए ऊपर और नीचे का उपयोग करें, या शीर्षक से खोजें।',
    );
    return '$_temp0';
  }

  @override
  String libraryScreenAddFailed(String title) {
    return '$title जोड़ा नहीं जा सका। अपना कनेक्शन जाँचें और फिर से कोशिश करें।';
  }

  @override
  String get libraryScreenSelectExistingName => 'मौजूदा ऑडियो चुनें';

  @override
  String get libraryScreenSelectExistingSections =>
      'खोज और हर उपलब्ध रिकॉर्डिंग';

  @override
  String get libraryScreenRefreshAvailableTarget =>
      'उपलब्ध ऑडियो रीफ़्रेश करें, बटन 1';

  @override
  String get libraryScreenSearchRecordingsField =>
      'शीर्षक से रिकॉर्डिंग खोजें। टाइप करने के लिए ओके दबाएँ';

  @override
  String libraryScreenSearchRecordingsWithQuery(String query, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'रिकॉर्डिंग खोजें, $query। $count मिलीं',
    );
    return '$_temp0';
  }

  @override
  String libraryScreenAddToSessionTarget(String title) {
    return '$title को इस सत्र में जोड़ें';
  }

  @override
  String get libraryScreenRepeatHelpTarget =>
      'ऑडियो लाइब्रेरी की मदद दोबारा सुनें';

  @override
  String get playlistBack => 'वापस';

  @override
  String get playlistCancel => 'रद्द करें';

  @override
  String get playlistCreate => 'बनाएँ';

  @override
  String get playlistRefresh => 'रीफ़्रेश करें';

  @override
  String playlistTeacherNone(String className, String subject) {
    return '$className, $subject के लिए अभी कोई प्लेलिस्ट नहीं है। एक बनाने के लिए 2 दबाएँ।';
  }

  @override
  String playlistTeacherLoaded(int count, String className, String subject) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count प्लेलिस्ट',
    );
    return '$className, $subject के लिए $_temp0 लोड हुईं';
  }

  @override
  String get playlistCreateClassTitle => 'कक्षा प्लेलिस्ट बनाएँ';

  @override
  String get playlistTitleField => 'प्लेलिस्ट का शीर्षक';

  @override
  String get playlistCancelCreation => 'प्लेलिस्ट बनाना रद्द करें';

  @override
  String get playlistCreatePlaylist => 'प्लेलिस्ट बनाएँ';

  @override
  String get playlistCreatePlaylistKey => 'प्लेलिस्ट बनाएँ';

  @override
  String get playlistRefreshPlaylists => 'प्लेलिस्ट रीफ़्रेश करें';

  @override
  String playlistTeacherItemLabel(String title, String status, String count) {
    return '$title। $status। $count आइटम';
  }

  @override
  String playlistTeacherScreen(String className, String subject) {
    return 'कक्षा प्लेलिस्ट, $className, $subject';
  }

  @override
  String get playlistStatusArchived => 'संग्रहित';

  @override
  String get playlistStatusPublished => 'प्रकाशित';

  @override
  String get playlistStatusDraft => 'ड्राफ़्ट';

  @override
  String get playlistStudentNone =>
      'अभी कोई प्लेलिस्ट नहीं है। निजी प्लेलिस्ट बनाने के लिए 2 दबाएँ।';

  @override
  String playlistStudentLoaded(int privateCount, int classCount) {
    String _temp0 = intl.Intl.pluralLogic(
      privateCount,
      locale: localeName,
      other: '$privateCount निजी प्लेलिस्ट',
    );
    String _temp1 = intl.Intl.pluralLogic(
      classCount,
      locale: localeName,
      other: '$classCount कक्षा प्लेलिस्ट',
    );
    return '$_temp0 और $_temp1 लोड हुईं';
  }

  @override
  String get playlistCreatePrivate => 'निजी प्लेलिस्ट बनाएँ';

  @override
  String get playlistCreatePrivateKey => 'निजी प्लेलिस्ट बनाएँ';

  @override
  String playlistPrivateItemLabel(String title, String count) {
    return '$title, निजी, $count आइटम';
  }

  @override
  String playlistClassItemLabel(String title, String subject, String count) {
    return '$title, कक्षा प्लेलिस्ट, $subject, $count आइटम';
  }

  @override
  String get playlistStudentScreen =>
      'मेरी प्लेलिस्ट। निजी प्लेलिस्ट सिर्फ़ आपको दिखती हैं।';

  @override
  String get playlistWaitBeforeNotes =>
      'पढ़ाई के नोट खोलने से पहले प्लेलिस्ट प्लेयर का इंतज़ार करें।';

  @override
  String get playlistRefreshFailed =>
      'यह प्लेलिस्ट रीफ़्रेश नहीं हो सकी। अपना कनेक्शन जाँचें और फिर से कोशिश करें। चल रहा ऑडियो और सहेजी गई प्रगति नहीं बदली गई है।';

  @override
  String get playlistLessonGone =>
      'मौजूदा पाठ अब इस प्लेलिस्ट में उपलब्ध नहीं है। चलाना बंद हो गया। आपकी सहेजी गई प्रगति और बुकमार्क रखे गए हैं।';

  @override
  String get playlistStateArchived => 'संग्रहित';

  @override
  String get playlistStatePublished => 'प्रकाशित';

  @override
  String get playlistStateDraft => 'ड्राफ़्ट';

  @override
  String get playlistStatePrivate => 'निजी';

  @override
  String get playlistStatePublishedClass => 'प्रकाशित कक्षा प्लेलिस्ट';

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
      other: '$count आइटम',
    );
    return '$title। $className $subject। $_temp0। $state।';
  }

  @override
  String get playlistAddAudioScreen => 'प्लेलिस्ट में ऑडियो जोड़ें';

  @override
  String playlistItemNoLongerAvailable(String title) {
    return '$title अब आपकी मौजूदा कक्षा में उपलब्ध नहीं है। आप इसे इस प्लेलिस्ट से हटा सकते हैं।';
  }

  @override
  String playlistItemPosition(String index, String total) {
    return '$total में से आइटम $index।';
  }

  @override
  String get playlistPlayFailed =>
      'यह पाठ नहीं चल सका। अपना कनेक्शन जाँचें और फिर से कोशिश करें।';

  @override
  String playlistPausedAt(String position) {
    return '$position पर रुका।';
  }

  @override
  String get playlistLessonDefault => 'पाठ';

  @override
  String get playlistSave => 'सहेजें';

  @override
  String get playlistRenameScreen => 'प्लेलिस्ट का नाम बदलें';

  @override
  String get playlistCancelRename => 'नाम बदलना रद्द करें';

  @override
  String get playlistSaveTitle => 'प्लेलिस्ट का शीर्षक सहेजें';

  @override
  String get playlistAlreadyFirst => 'चुना गया आइटम पहले से सबसे ऊपर है।';

  @override
  String get playlistAlreadyLast => 'चुना गया आइटम पहले से सबसे नीचे है।';

  @override
  String playlistMoveFailed(String title) {
    return '$title को खिसकाया नहीं जा सका। अपना कनेक्शन जाँचें और फिर से कोशिश करें।';
  }

  @override
  String get playlistThisPlaylist => 'यह प्लेलिस्ट';

  @override
  String playlistRemoveItemTitle(String title) {
    return '$title हटाएँ?';
  }

  @override
  String playlistRemoveItemMessage(String title, String playlist) {
    return '$playlist से $title हटाएँ? रिकॉर्डिंग लाइब्रेरी में बनी रहेगी।';
  }

  @override
  String playlistKeepItem(String title) {
    return '$title रखें';
  }

  @override
  String playlistRemoveItem(String title) {
    return '$title हटाएँ';
  }

  @override
  String playlistRemoveFailed(String title) {
    return '$title हटाया नहीं जा सका। अपना कनेक्शन जाँचें और फिर से कोशिश करें।';
  }

  @override
  String playlistPublishedToClass(String title) {
    return '$title कक्षा के लिए प्रकाशित हुआ';
  }

  @override
  String playlistReturnedToDraft(String title) {
    return '$title वापस ड्राफ़्ट में भेजा गया';
  }

  @override
  String playlistChangeFailed(String title) {
    return '$title बदला नहीं जा सका। अपना कनेक्शन जाँचें और फिर से कोशिश करें।';
  }

  @override
  String playlistDeleteTitle(String title) {
    return '$title मिटाएँ?';
  }

  @override
  String playlistRestoreTitle(String title) {
    return '$title वापस लाएँ?';
  }

  @override
  String playlistArchiveTitle(String title) {
    return '$title संग्रहित करें?';
  }

  @override
  String playlistDeleteMessage(String title) {
    return 'इससे निजी प्लेलिस्ट $title और उसके क्रम वाले आइटम हट जाएँगे। रिकॉर्डिंग लाइब्रेरी में बनी रहेंगी।';
  }

  @override
  String playlistRestoreMessage(String title) {
    return 'इससे $title वापस ड्राफ़्ट में चला जाएगा, ताकि उसे फिर से बदला और प्रकाशित किया जा सके।';
  }

  @override
  String playlistArchiveMessage(String title) {
    return 'छात्र अब $title नहीं देख पाएँगे। शिक्षक का इतिहास बना रहेगा।';
  }

  @override
  String playlistDeleteConfirm(String title) {
    return '$title मिटाएँ';
  }

  @override
  String playlistRestoreConfirm(String title) {
    return '$title वापस लाएँ';
  }

  @override
  String playlistArchiveConfirm(String title) {
    return '$title संग्रहित करें';
  }

  @override
  String playlistDeleted(String title) {
    return '$title मिटा दिया गया';
  }

  @override
  String playlistRestoredDraft(String title) {
    return '$title ड्राफ़्ट के रूप में वापस लाया गया';
  }

  @override
  String playlistArchived(String title) {
    return '$title संग्रहित किया गया';
  }

  @override
  String get playlistSelectedItem => 'चुना गया आइटम';

  @override
  String get playlistSeekFailed =>
      'पाठ की उस जगह पर नहीं जा सके। फिर से कोशिश करें।';

  @override
  String get playlistRefreshPlaylist => 'प्लेलिस्ट रीफ़्रेश करें';

  @override
  String get playlistWordPlaylist => 'प्लेलिस्ट';

  @override
  String playlistRenameLabel(String title) {
    return '$title का नाम बदलें';
  }

  @override
  String get playlistAddAudioLabel => 'ऑडियो जोड़ें, बटन 2';

  @override
  String playlistPauseLabel(String title, String key) {
    return '$title रोकें, बटन $key';
  }

  @override
  String playlistPlayLabel(String title, String key) {
    return '$title चलाएँ, बटन $key';
  }

  @override
  String get playlistPreviousLabel => 'पिछला आइटम, बटन 3';

  @override
  String get playlistNextLabel => 'अगला आइटम, बटन 8';

  @override
  String playlistReturnToDraftLabel(String title) {
    return '$title को वापस ड्राफ़्ट में भेजें';
  }

  @override
  String playlistPublishLabel(String title) {
    return '$title को कक्षा के लिए प्रकाशित करें';
  }

  @override
  String playlistRestoreLabel(String title) {
    return '$title वापस लाएँ';
  }

  @override
  String playlistArchiveLabel(String title) {
    return '$title संग्रहित करें, पुष्टि पूछी जाएगी';
  }

  @override
  String playlistDeleteLabel(String title) {
    return '$title मिटाएँ, पुष्टि पूछी जाएगी';
  }

  @override
  String playlistSeekLabel(String position) {
    return 'पाठ की जगह $position। 10 सेकंड आगे या पीछे जाने के लिए बाएँ या दाएँ दबाएँ';
  }

  @override
  String get playlistDownloadsLabel =>
      'प्लेलिस्ट की रिकॉर्डिंग डाउनलोड करें। एक-एक करके चुनें या सूची की सभी रिकॉर्डिंग की पुष्टि करें';

  @override
  String playlistMoveUpLabel(String title) {
    return '$title को ऊपर ले जाएँ';
  }

  @override
  String playlistMoveDownLabel(String title) {
    return '$title को नीचे ले जाएँ';
  }

  @override
  String playlistRemoveItemLabel(String title) {
    return '$title को प्लेलिस्ट से हटाएँ, पुष्टि पूछी जाएगी';
  }

  @override
  String get playlistItemUnavailableInClass =>
      'आपकी अभी की कक्षा में उपलब्ध नहीं है';

  @override
  String get playlistItemSelected => 'चुना गया';

  @override
  String get playlistItemPlaying => 'चल रहा है';

  @override
  String get playlistItemSelectedPaused => 'चुना गया, रुका हुआ';

  @override
  String get playlistAddAudioKey => 'ऑडियो जोड़ें';

  @override
  String get playlistPreviousItem => 'पिछला आइटम';

  @override
  String get playlistNextItem => 'अगला आइटम';

  @override
  String get playlistScreenDefault => 'प्लेलिस्ट';

  @override
  String playlistScreen(String title) {
    return '$title प्लेलिस्ट';
  }

  @override
  String playlistItemUnavailable(String title) {
    return '$title आपकी अभी की कक्षा में उपलब्ध नहीं है';
  }

  @override
  String get notesNoRecordingActive => 'कोई रिकॉर्डिंग नहीं चल रही है।';

  @override
  String get notesMicCouldNotRecord =>
      'माइक्रोफ़ोन यह नोट रिकॉर्ड नहीं कर सका।';

  @override
  String get notesRecordingNotConfirmed =>
      'रिकॉर्डिंग की पुष्टि नहीं हो सकी। उसकी अधूरी फ़ाइलें रखी गई हैं। माइक्रोफ़ोन की अनुमति और स्टोरेज जाँचें।';

  @override
  String get notesLeaveLiveSession =>
      'रिकॉर्ड करने से पहले लाइव सत्र छोड़ें और निजी नोट खोलें।';

  @override
  String get notesMicPermissionDenied =>
      'माइक्रोफ़ोन की अनुमति नहीं मिली। कोई रिकॉर्डिंग शुरू नहीं हुई। Android सेटिंग्स में इसे चालू करें और फिर से कोशिश करें।';

  @override
  String get notesRecordingCancelledChanged =>
      'स्क्रीन या ऐप बदलने के कारण रिकॉर्डिंग रद्द हो गई। तैयार होने पर फिर से शुरू करें।';

  @override
  String get notesSpeechDidNotStop =>
      'ऐप की आवाज़ बंद नहीं हुई। रिकॉर्ड करने से पहले TTS इंजन जाँचें।';

  @override
  String get notesRecordingDidNotStart =>
      'ऐप बदलने के कारण रिकॉर्डिंग शुरू नहीं हुई। उसका खाली ड्राफ़्ट चुनकर हटाने के लिए रखा गया है।';

  @override
  String get notesAnotherRecorderStopping =>
      'एक और निजी रिकॉर्डर अभी बंद हो रहा है। रिकॉर्ड करने से पहले उस पर वापस जाएँ या ऐप को बैकग्राउंड में भेजें।';

  @override
  String get notesNativeStartNotConfirmed =>
      'फ़ोन के रिकॉर्डर ने शुरू होने की पुष्टि नहीं की। ड्राफ़्ट रखा गया है।';

  @override
  String get notesNativeStopNotConfirmed =>
      'फ़ोन की रिकॉर्डिंग बंद होने की पुष्टि नहीं हुई। फिर से कोशिश करने से पहले रिकॉर्डिंग रोकने के लिए ऐप को बैकग्राउंड में भेजें।';

  @override
  String get notesDurationUnreadable =>
      'रिकॉर्डर की अवधि पढ़ी नहीं जा सकी। उसकी अधूरी फ़ाइल रखी गई है।';

  @override
  String get notesRecordingInProgress =>
      'रिकॉर्डिंग चल रही है। ऐप के बटन बोलने से पहले रोकें। अधिकतम पाँच मिनट; ऐप के बोलने या रुकावट पर बंद हो जाती है।';

  @override
  String get notesNativeCaptureStopped =>
      'फ़ोन की रिकॉर्डिंग बंद है। कोई भी अधूरा ड्राफ़्ट चुनकर हटाने के लिए रखा गया है।';

  @override
  String get notesRecorderStopNotConfirmed =>
      'रिकॉर्डर बंद होने की पुष्टि नहीं हुई। फिर से कोशिश करने से पहले रिकॉर्डिंग रोकने के लिए यह स्क्रीन छोड़ें या ऐप को बैकग्राउंड में भेजें।';

  @override
  String get notesRecorderFailed =>
      'रिकॉर्डर विफल हो गया। उसकी अधूरी फ़ाइल चुनकर हटाने के लिए रखी गई है।';

  @override
  String get notesNotFinalized =>
      'रिकॉर्डिंग रुक गई, लेकिन नोट पूरा नहीं हो सका। फ़ाइलें चुनकर हटाने के लिए रखी गई हैं।';

  @override
  String get notesRecordingLimitReached => 'रिकॉर्डिंग की सीमा पूरी हो गई।';

  @override
  String get notesRecordingInterrupted => 'रिकॉर्डिंग में रुकावट आई।';

  @override
  String get notesRecordingStopped => 'रिकॉर्डिंग रुक गई।';

  @override
  String get notesSavedOnPhone =>
      'निजी नोट इस फ़ोन पर सेव हो गया। प्रकाशित करने या शेयर करने से पहले इसे जाँच लें।';

  @override
  String get notesSignInFirst => 'निजी नोट खोलने से पहले साइन इन करें।';

  @override
  String get notesInvalidIdentity => 'नोट की पहचान अमान्य है।';

  @override
  String get notesAccountChanged =>
      'आपका खाता बदल गया है। निजी नोट फिर से खोलें।';

  @override
  String get notesStorageUnavailable =>
      'निजी नोट का स्टोरेज उपलब्ध नहीं है। खाली जगह जाँचें और फिर से कोशिश करें। मौजूदा फ़ाइलें रखी गई हैं।';

  @override
  String get notesInvalidNameOrPosition =>
      '160 अक्षरों तक का नोट का नाम और पाठ की सही जगह डालें।';

  @override
  String get notesAllowanceFull =>
      'आपके निजी नोट की सीमा भर गई है। रिकॉर्ड करने से पहले कोई चुना हुआ नोट हटाएँ। कोई नोट मिटाया नहीं गया।';

  @override
  String get notesInterruptedOrInvalid =>
      'नोट में रुकावट आई या उसकी अवधि अमान्य है। उसकी फ़ाइलें चुनकर हटाने के लिए रखी गई हैं।';

  @override
  String get notesEmptyOrTooLarge =>
      'यह रिकॉर्डिंग खाली है या निजी नोट की सीमा से बड़ी है। उसकी अधूरी फ़ाइल रखी गई है; स्टोरेज जाँचें और चुनी गई रिकॉर्डिंग हटाएँ।';

  @override
  String get notesIncompleteUnavailable =>
      'यह नोट अधूरा है या उपलब्ध नहीं है। इसे मिटाया नहीं गया है।';

  @override
  String get notesInvalidName => '160 अक्षरों तक का नोट का नाम डालें।';

  @override
  String notesUnreadableTitle(String id) {
    return 'न पढ़ा जा सकने वाला नोट $id';
  }

  @override
  String get notesRecordUnreadable =>
      'इस नोट का रिकॉर्ड पढ़ा नहीं जा सकता। उसकी फ़ाइलें रखी गई हैं; केवल आपके चुनकर हटाने से ही वे बदलेंगी।';

  @override
  String notesInterruptedTitle(String id) {
    return 'रुकी हुई रिकॉर्डिंग $id';
  }

  @override
  String get notesMetadataMissing =>
      'रिकॉर्डिंग की जानकारी नहीं मिली। फ़ाइल चुनकर हटाने के लिए रखी गई है।';

  @override
  String get learningSavedLessonInvalid =>
      'सेव की गई पाठ की जानकारी अमान्य है। आपका सेव किया गया डेटा नहीं बदला गया है।';

  @override
  String get learningSavedBookmarkUnreadable =>
      'एक सेव किया गया बुकमार्क पढ़ा नहीं जा सका। आपका सेव किया गया डेटा नहीं बदला गया है।';

  @override
  String get learningSavedBookmarkIdsInvalid =>
      'सेव किए गए बुकमार्क की पहचान अमान्य है। आपका सेव किया गया डेटा नहीं बदला गया है।';

  @override
  String get learningSavedRepeatInvalid =>
      'सेव की गई दोहराने की सीमाएँ अमान्य हैं। आपका सेव किया गया डेटा नहीं बदला गया है।';

  @override
  String get learningSignInFirst =>
      'सेव की गई सीखने की प्रगति इस्तेमाल करने से पहले साइन इन करें।';

  @override
  String get learningAccountChanged =>
      'आपका खाता बदल गया है। सीखने की लाइब्रेरी फिर से खोलें।';

  @override
  String get learningUnsupportedFormat =>
      'सेव किए गए सीखने के डेटा का फ़ॉर्मेट या खाता समर्थित नहीं है। आपका सेव किया गया डेटा नहीं बदला गया है।';

  @override
  String get learningIdentityMismatch =>
      'सेव किए गए पाठ की पहचान मेल नहीं खाती। आपका सेव किया गया डेटा नहीं बदला गया है।';

  @override
  String get learningDataUnreadable =>
      'सेव किया गया सीखने का डेटा पढ़ा नहीं जा सका। आपका सेव किया गया डेटा नहीं बदला गया है।';

  @override
  String get learningStorageUnavailableFreeSpace =>
      'सीखने का स्टोरेज उपलब्ध नहीं है। खाली जगह जाँचें और फिर से कोशिश करें। आपका सेव किया गया डेटा जान-बूझकर हटाया नहीं गया है।';

  @override
  String get learningStorageUnavailable =>
      'सीखने का स्टोरेज उपलब्ध नहीं है। स्टोरेज जाँचें और फिर से कोशिश करें।';

  @override
  String get learningSaveFailed =>
      'सीखने की प्रगति सेव नहीं हो सकी। खाली जगह जाँचें और फिर से कोशिश करें।';

  @override
  String get learningProgressUnavailable =>
      'सेव की गई सीखने की प्रगति उपलब्ध नहीं है। स्टोरेज जाँचें और फिर से कोशिश करें।';

  @override
  String get learningStartLessonFirst =>
      'बुकमार्क या दोहराने के बिंदु जोड़ने से पहले यह पाठ शुरू करें।';

  @override
  String learningSavedFieldUnreadable(String field) {
    return 'सेव किया गया $field पढ़ा नहीं जा सका। आपका सेव किया गया डेटा नहीं बदला गया है।';
  }

  @override
  String get learningFieldBookmarkId => 'बुकमार्क आईडी';

  @override
  String get learningFieldBookmarkLabel => 'बुकमार्क का नाम';

  @override
  String get learningFieldBookmarkPosition => 'बुकमार्क की जगह';

  @override
  String get learningFieldUpdateTime => 'अपडेट का समय';

  @override
  String get learningFieldNextBookmarkId => 'अगली बुकमार्क आईडी';

  @override
  String get learningFieldLessonId => 'पाठ आईडी';

  @override
  String get learningFieldLessonTitle => 'पाठ का शीर्षक';

  @override
  String get learningFieldPosition => 'जगह';

  @override
  String get learningInvalidProgress => 'पाठ की प्रगति अमान्य है';

  @override
  String get learningBookmarkNeedsPositionLabel =>
      'बुकमार्क के लिए सही जगह और नाम ज़रूरी है';

  @override
  String get learningBookmarkExceedsDuration =>
      'बुकमार्क की जगह पाठ की अवधि से आगे है';

  @override
  String learningDefaultBookmarkLabel(String number) {
    return 'बुकमार्क $number';
  }

  @override
  String get learningBookmarkNotFound => 'बुकमार्क नहीं मिला';

  @override
  String get learningRepeatEndAfterStart =>
      'अंत का बिंदु शुरुआत के बिंदु के बाद रखें';

  @override
  String get learningRepeatExceedsDuration =>
      'दोहराने के बिंदु पाठ की अवधि से आगे हैं';

  @override
  String get learningSavedProgressUnavailableTitle =>
      'सेव की गई प्रगति उपलब्ध नहीं है';

  @override
  String get learningListenWithoutSavedPrompt =>
      'सेव किया गया डेटा बदले बिना शुरू से सुनें? जब तक दोबारा कोशिश सफल न हो, सेव करना बंद रहेगा।';

  @override
  String get learningListenFromBeginning => 'शुरू से सुनें';

  @override
  String get learningRecordedLesson => 'रिकॉर्ड किया गया पाठ';

  @override
  String learningStatusPosition(String position) {
    return 'जगह $position।';
  }

  @override
  String learningSpeedTimes(String speed) {
    return 'गति $speed गुना।';
  }

  @override
  String learningStatusBookmarks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count बुकमार्क',
    );
    return '$_temp0';
  }

  @override
  String learningStatusRepeat(String state) {
    return 'A-B दोहराना $state।';
  }

  @override
  String learningStatusSaving(String state) {
    return 'प्रगति सेव करना $state।';
  }

  @override
  String get learningNoLessonLoaded =>
      'कोई पाठ लोड नहीं है। पहले चलाने के लिए कोई पाठ चुनें।';

  @override
  String get learningSlowestSpeed => 'पहले से सबसे धीमी गति है।';

  @override
  String get learningFastestSpeed => 'पहले से सबसे तेज़ गति है।';

  @override
  String get learningCheckPosition => 'पाठ की जगह जाँचें और फिर से कोशिश करें।';

  @override
  String get learningPlayerActionFailed =>
      'प्लेयर यह काम पूरा नहीं कर सका। प्लेबैक जाँचें और फिर से कोशिश करें।';

  @override
  String learningBookmarkSavedAt(String time) {
    return 'बुकमार्क $time पर सेव हुआ।';
  }

  @override
  String learningReadStatusLabel(String status) {
    return 'सीखने की स्थिति सुनें। $status';
  }

  @override
  String learningAddBookmarkAt(String time) {
    return '$time पर बुकमार्क जोड़ें';
  }

  @override
  String learningBookmarksSavedPoints(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'बुकमार्क। $count सेव किए गए बिंदु',
    );
    return '$_temp0';
  }

  @override
  String learningPrivateNotesAt(String time) {
    return '$time पर निजी पढ़ाई के नोट। खोलने से पहले पाठ रोकें';
  }

  @override
  String get learningSetRepeatStartLabel =>
      'अभी की जगह पर दोहराने की शुरुआत A सेट करें';

  @override
  String learningRepeatStartSet(String time) {
    return 'दोहराने की शुरुआत $time पर सेट हुई।';
  }

  @override
  String get learningSetRepeatEndLabel =>
      'शुरुआत A के बाद दोहराने का अंत B सेट करें';

  @override
  String learningRepeatEndSet(String time) {
    return 'दोहराने का अंत $time पर सेट हुआ। बार-बार चलाने के लिए दोहराना चालू करें चुनें।';
  }

  @override
  String get learningTurnRepeatOff => 'A-B दोहराना बंद करें';

  @override
  String get learningTurnRepeatOn => 'A-B दोहराना चालू करें';

  @override
  String get learningClearRepeatLabel =>
      'सेव किए गए A-B दोहराने के बिंदु हटाएँ';

  @override
  String get learningRepeatCleared => 'A-B दोहराने के बिंदु हटा दिए गए।';

  @override
  String learningBackTenLabel(String key) {
    return '10 सेकंड पीछे, बटन $key';
  }

  @override
  String learningForwardTenLabel(String key) {
    return '10 सेकंड आगे, बटन $key';
  }

  @override
  String learningSlowerLabel(String key, String speed) {
    return 'धीमा, बटन $key। अभी $speed गुना';
  }

  @override
  String learningFasterLabel(String key, String speed) {
    return 'तेज़, बटन $key। अभी $speed गुना';
  }

  @override
  String learningRetrySavingLabel(String issue) {
    return 'सीखने की प्रगति फिर से सेव करें। $issue';
  }

  @override
  String get learningProgressSaved => 'सीखने की प्रगति सेव हो गई।';

  @override
  String get learningEnterBookmarkName => 'बुकमार्क का नाम डालें।';

  @override
  String get learningNameBookmarkScreen =>
      'बुकमार्क का नाम रखें। बदलने के लिए ओके दबाएँ। ऊपर या नीचे दबाने से बदलना बंद हो जाता है।';

  @override
  String get learningEditName => 'नाम बदलें';

  @override
  String get learningSaveBookmark => 'बुकमार्क सेव करें';

  @override
  String get learningBookmarkNameField => 'बुकमार्क का नाम';

  @override
  String learningBookmarkJumped(String label, String position) {
    return '$label। जगह $position।';
  }

  @override
  String get learningRemoveBookmarkTitle => 'बुकमार्क हटाएँ?';

  @override
  String learningRemoveBookmarkMessage(String label) {
    return '$label हटाएँ? इससे पाठ या कोई दूसरा बुकमार्क नहीं हटेगा।';
  }

  @override
  String get learningKeepBookmark => 'बुकमार्क रखें';

  @override
  String get learningRemoveBookmark => 'बुकमार्क हटाएँ';

  @override
  String learningBookmarkRemoved(String label) {
    return '$label हटा दिया गया।';
  }

  @override
  String get learningBookmarksScreen =>
      'बुकमार्क। किसी बिंदु पर जाने के लिए उसे चुनें। इससे रुका हुआ प्लेबैक शुरू नहीं होता। हटाने से पहले पुष्टि पूछी जाती है।';

  @override
  String get learningCloseBookmarks => 'बुकमार्क बंद करें';

  @override
  String learningJumpToBookmarkLabel(String label, String time) {
    return '$label। $time। बुकमार्क पर जाएँ';
  }

  @override
  String learningRemoveBookmarkLabel(String label) {
    return '$label हटाएँ';
  }

  @override
  String get dashboardRefreshing => 'सत्र रीफ़्रेश हो रहे हैं।';

  @override
  String get dashboardShowMatching => 'मिलते-जुलते सत्र दिखाएँ';

  @override
  String get dashboardLogout => 'लॉग आउट करें, पुष्टि पूछेगा';

  @override
  String get dashboardRefresh => 'सत्र रीफ़्रेश करें';

  @override
  String get dashboardLibraryWhat => 'रिकॉर्ड की गई ऑडियो लाइब्रेरी';

  @override
  String get dashboardQuizzesWhat => 'क्विज़';

  @override
  String dashboardSessions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count सत्र',
      one: '1 सत्र',
    );
    return '$_temp0';
  }

  @override
  String dashboardPosition(String index, String total) {
    return '$total में से $index';
  }

  @override
  String get dashboardStudentScreen => 'छात्र डैशबोर्ड';

  @override
  String get dashboardStudentLoading => 'छात्र डैशबोर्ड लोड हो रहा है';

  @override
  String get dashboardStudentSections =>
      'रीफ़्रेश, सत्र खोज, लाइव सत्र, रिकॉर्ड किए गए पाठ, प्लेलिस्ट, क्विज़, सीखने की यात्राएँ, और लॉग आउट';

  @override
  String get dashboardNoLiveSessions =>
      'अभी कोई लाइव सत्र नहीं है। रीफ़्रेश करने के लिए 1 दबाएँ।';

  @override
  String get dashboardNoFilterMatch =>
      'आपके फ़िल्टर से कोई सत्र मेल नहीं खाता।';

  @override
  String get dashboardNoMatchVisible =>
      'कोई मेल खाता सत्र नहीं है। खोज साफ़ करें या विषय फ़िल्टर बदलें।';

  @override
  String dashboardAvailable(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count सत्र उपलब्ध हैं।',
      one: '1 सत्र उपलब्ध है।',
    );
    return '$_temp0';
  }

  @override
  String dashboardAvailableDetailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count सत्र उपलब्ध हैं। देखने के लिए नीचे जाएँ।',
      one: '1 सत्र उपलब्ध है। देखने के लिए नीचे जाएँ।',
    );
    return '$_temp0';
  }

  @override
  String dashboardRefreshFailed(String reason) {
    return '$reason फिर से कोशिश करने के लिए 1 दबाएँ।';
  }

  @override
  String get dashboardJoining => 'सत्र में जुड़ रहे हैं।';

  @override
  String dashboardJoined(String session) {
    return '$session में जुड़ गए।';
  }

  @override
  String get dashboardOpeningPlaylists =>
      'मेरी प्लेलिस्ट खुल रही हैं। ये प्लेलिस्ट निजी हैं।';

  @override
  String get dashboardSessionSearchHelp =>
      'सत्र खोज। सत्र नंबर टाइप करने के लिए ओके दबाएँ, फिर नीचे जाकर मेल खाते सत्र दिखाएँ पर ओके दबाएँ। आप नाम से भी खोज सकते हैं।';

  @override
  String get dashboardSessionNumberFieldEmpty =>
      'सत्र नंबर फ़ील्ड। नंबर टाइप करें, फिर मेल खाते सत्र दिखाएँ चुनें';

  @override
  String dashboardSessionNumberField(String digits) {
    return 'सत्र नंबर फ़ील्ड, $digits';
  }

  @override
  String get dashboardNameField => 'नाम से सत्र खोजें';

  @override
  String dashboardNoSessionNumber(String digits) {
    return 'सत्र नंबर $digits का कोई लाइव सत्र नहीं है।';
  }

  @override
  String dashboardFound(String label) {
    return 'मिला: $label। जुड़ने के लिए ओके दबाएँ।';
  }

  @override
  String dashboardNoNameMatch(String query) {
    return '$query से कोई सत्र मेल नहीं खाता।';
  }

  @override
  String dashboardShowingAll(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'सभी $count सत्र दिखा रहे हैं।',
      one: 'सभी 1 सत्र दिखा रहे हैं।',
    );
    return '$_temp0';
  }

  @override
  String dashboardShowingAllDetailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'सभी $count सत्र दिखा रहे हैं। देखने के लिए नीचे जाएँ।',
      one: 'सभी 1 सत्र दिखा रहे हैं। देखने के लिए नीचे जाएँ।',
    );
    return '$_temp0';
  }

  @override
  String dashboardNameMatches(int count, String query) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count सत्र $query से मेल खाते हैं। देखने के लिए नीचे जाएँ।',
      one: '1 सत्र $query से मेल खाता है। देखने के लिए नीचे जाएँ।',
    );
    return '$_temp0';
  }

  @override
  String get dashboardAllSubjects => 'सभी विषय';

  @override
  String dashboardSubjectFilterLabel(String subject, String position) {
    return 'विषय फ़िल्टर: $subject, $position। बदलने के लिए बाएँ या दाएँ जाएँ';
  }

  @override
  String dashboardSubjectFilterChanged(
    String subject,
    String position,
    String summary,
  ) {
    return 'विषय फ़िल्टर: $subject, $position। $summary';
  }

  @override
  String get dashboardLibrary => 'रिकॉर्ड की गई ऑडियो लाइब्रेरी';

  @override
  String get dashboardPlaylists => 'मेरी निजी प्लेलिस्ट';

  @override
  String get dashboardQuizzes => 'क्विज़';

  @override
  String get dashboardStudentJourneys =>
      'सीखने की यात्राएँ: सुनें, जवाब दें और दोहराएँ, ऑफ़लाइन भी चलती हैं';

  @override
  String dashboardTeacherName(String name) {
    return 'शिक्षक $name';
  }

  @override
  String get dashboardLiveNow => 'अभी लाइव';

  @override
  String get dashboardStateRefreshing => 'रीफ़्रेश हो रहा है।';

  @override
  String dashboardStateLiveSessions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count लाइव सत्र।',
      one: '1 लाइव सत्र।',
    );
    return '$_temp0';
  }

  @override
  String dashboardStateSubjectFilter(String subject) {
    return 'विषय फ़िल्टर: $subject।';
  }

  @override
  String dashboardStateSessionNumber(String digits) {
    return 'टाइप किया गया सत्र नंबर: $digits।';
  }

  @override
  String dashboardStateNameSearch(String query) {
    return 'नाम खोज: $query।';
  }

  @override
  String dashboardStateShown(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count सत्र दिखाए गए।',
      one: '1 सत्र दिखाया गया।',
    );
    return '$_temp0';
  }

  @override
  String get dashboardTeacherScreen => 'शिक्षक डैशबोर्ड';

  @override
  String get dashboardTeacherLoading => 'शिक्षक डैशबोर्ड लोड हो रहा है';

  @override
  String get dashboardTeacherSections =>
      'कक्षा और विषय चुनना, पढ़ाने के टूल, सत्र खोज, और चालू या समाप्त सत्र';

  @override
  String get dashboardNoSessionsYet =>
      'अभी तक कोई सत्र नहीं है। नया बनाने के लिए 2 दबाएँ।';

  @override
  String get dashboardNoTeacherMatch =>
      'कोई मेल खाता सत्र नहीं है। सभी सत्र देखने के लिए खोज साफ़ करें।';

  @override
  String dashboardTeacherCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count सत्र।',
      one: '1 सत्र।',
    );
    return '$_temp0';
  }

  @override
  String dashboardTeacherCountLive(int count, String live) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count सत्र, $live अभी लाइव।',
      one: '1 सत्र, $live अभी लाइव।',
    );
    return '$_temp0';
  }

  @override
  String dashboardNotRefreshed(String reason) {
    return '$reason सत्र रीफ़्रेश नहीं हुए। फिर से कोशिश करने के लिए 1 दबाएँ।';
  }

  @override
  String get dashboardNoAssignment =>
      'आपको कोई कक्षा और विषय नहीं दिया गया है। किसी प्रशासक से कहें कि वे एक दें।';

  @override
  String get dashboardCreatingSession => 'सत्र बनाया जा रहा है';

  @override
  String dashboardCreated(String title) {
    return 'सत्र $title बन गया।';
  }

  @override
  String get dashboardCreatedTitle => 'सत्र बन गया';

  @override
  String dashboardStartNow(String title) {
    return 'क्या आप \"$title\" अभी शुरू करना चाहते हैं?';
  }

  @override
  String get dashboardRequestFailed =>
      'हम यह अनुरोध पूरा नहीं कर सके। अपना कनेक्शन जाँचें और फिर से कोशिश करें।';

  @override
  String get dashboardOpeningSession => 'सत्र खुल रहा है।';

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
    return 'वर्कस्पेस: $name, $position। $status';
  }

  @override
  String dashboardWorkspaceChosen(String name, String status) {
    return '$name चुना गया। $status दूसरा वर्कस्पेस चुनने के लिए 7 दबाएँ।';
  }

  @override
  String get dashboardChooseWorkspaceTitle => 'कक्षा और विषय चुनें';

  @override
  String get dashboardNoWorkspace =>
      'कोई कक्षा और विषय वर्कस्पेस नहीं दिया गया';

  @override
  String dashboardWorkspaceLabel(String name, String position) {
    return 'वर्कस्पेस: $name, $position। बदलने के लिए बाएँ या दाएँ, नंबर वाली सूची के लिए ओके या 7';
  }

  @override
  String get dashboardCreate => 'नया सत्र बनाएँ';

  @override
  String get dashboardClassPlaylists => 'कक्षा की प्लेलिस्ट';

  @override
  String get dashboardTeacherJourneys =>
      'सीखने की यात्राएँ: रिकॉर्डिंग, प्रश्न और पोल एक ही क्रम में';

  @override
  String get dashboardTeacherQuizzes => 'क्विज़ और निजी प्रश्न बैंक';

  @override
  String get dashboardOfflineLibrary => 'ऑफ़लाइन ऑडियो लाइब्रेरी';

  @override
  String get dashboardSearchField =>
      'सत्र खोजें। ओके दबाएँ, फिर नाम या सत्र नंबर टाइप करें';

  @override
  String get dashboardTeacherSearchHelp =>
      'सत्र खोज। बदलने के लिए ओके दबाएँ, फिर सत्र का नाम टाइप करें, या नंबर बटनों से सत्र नंबर टाइप करें। फ़ील्ड से निकलकर नतीजे देखने के लिए ऊपर या नीचे जाएँ।';

  @override
  String dashboardTeacherNoMatch(String query) {
    return '$query से कोई सत्र मेल नहीं खाता। सभी सत्र देखने के लिए खोज साफ़ करें।';
  }

  @override
  String get dashboardEnded => 'समाप्त';

  @override
  String dashboardJoinedCount(String count) {
    return '$count जुड़े';
  }

  @override
  String get dashboardPressOkToOpen => 'खोलने के लिए ओके दबाएँ';

  @override
  String get dashboardPressOkToReactivate =>
      'फिर से चालू करने के लिए ओके दबाएँ';

  @override
  String dashboardEndLabel(String title) {
    return '$title सबके लिए समाप्त करें, पुष्टि माँगी जाएगी';
  }

  @override
  String dashboardDeleteLabel(String title) {
    return 'समाप्त सत्र $title हमेशा के लिए हटाएँ, पुष्टि माँगी जाएगी';
  }

  @override
  String get dashboardEndTitle => 'सत्र सबके लिए समाप्त करें?';

  @override
  String dashboardEndMessage(String title) {
    return '\"$title\" समाप्त करके हर प्रतिभागी के लिए बंद करें? सत्र आपके डैशबोर्ड के इतिहास में रहेगा।';
  }

  @override
  String get dashboardEndedForEveryone =>
      'सत्र सबके लिए समाप्त हो गया और सत्र इतिहास में रखा गया।';

  @override
  String get dashboardEndFailed =>
      'सत्र समाप्त नहीं हो सका। कृपया फिर से कोशिश करें।';

  @override
  String get dashboardReactivateTitle => 'सत्र फिर से चालू करें?';

  @override
  String dashboardReactivateMessage(String title) {
    return '\"$title\" फिर से चालू करें ताकि प्रतिभागी इसमें फिर से जुड़ सकें?';
  }

  @override
  String get dashboardReactivated => 'सत्र फिर से चालू हो गया।';

  @override
  String get dashboardReactivateFailed =>
      'सत्र फिर से चालू नहीं हो सका। कृपया फिर से कोशिश करें।';

  @override
  String get dashboardOpenNowTitle => 'सत्र अभी खोलें?';

  @override
  String dashboardOpenNowMessage(String title) {
    return '\"$title\" फिर से चालू है। इसे अभी खोलें, या बाद में डैशबोर्ड से इस पर लौटें।';
  }

  @override
  String get dashboardDeleteTitle => 'सत्र हमेशा के लिए हटाएँ?';

  @override
  String dashboardDeleteMessage(String title) {
    return '\"$title\" को उसके प्रतिभागियों, चैट और लॉग समेत हमेशा के लिए हटाएँ? इसे वापस नहीं लाया जा सकता।';
  }

  @override
  String get dashboardDeleted => 'सत्र हमेशा के लिए हटा दिया गया।';

  @override
  String get dashboardDeleteFailed =>
      'सत्र हटाया नहीं जा सका। कृपया फिर से कोशिश करें।';

  @override
  String get dashboardStateNoWorkspace => 'कोई वर्कस्पेस नहीं चुना गया।';

  @override
  String dashboardStateWorkspace(String name) {
    return 'वर्कस्पेस: $name।';
  }

  @override
  String dashboardActiveSessions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count चालू सत्र',
      one: '1 चालू सत्र',
    );
    return '$_temp0';
  }

  @override
  String dashboardStateTotals(String active, String total) {
    return '$active, कुल $total।';
  }

  @override
  String dashboardStateSearch(String query) {
    return 'खोज: $query।';
  }

  @override
  String get adminSaveFailed =>
      'बदलाव सेव नहीं हो सका। रीफ़्रेश करने के लिए 1 दबाएँ, फिर से कोशिश करें।';

  @override
  String adminChoiceLabel(String what, String name, String position) {
    return '$what: $name, $position। बदलने के लिए बाएँ या दाएँ दबाएँ';
  }

  @override
  String adminChoiceLabelSingle(String what, String name) {
    return '$what: $name। बदलने के लिए बाएँ या दाएँ दबाएँ';
  }

  @override
  String adminChoiceChanged(String name, String position) {
    return '$name, $position।';
  }

  @override
  String adminChoiceChangedSingle(String name) {
    return '$name।';
  }

  @override
  String adminClassAndSubject(String className, String subject) {
    return '$className चुनी गई। $subject विषय चुना गया।';
  }

  @override
  String get adminNoSubjects => 'चुनी गई कक्षा में कोई सक्रिय विषय नहीं है।';

  @override
  String adminStateSection(String section) {
    return 'भाग: $section।';
  }

  @override
  String adminStateShown(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count आइटम दिख रहे हैं।',
      one: '1 आइटम दिख रहा है।',
    );
    return '$_temp0';
  }

  @override
  String adminStateFilter(String filter) {
    return 'फ़िल्टर: $filter।';
  }

  @override
  String adminStateSearch(String query) {
    return 'खोज: $query।';
  }

  @override
  String get adminNoSubjectName =>
      'कोई विषय का नाम नहीं डाला गया। कुछ भी नहीं बनाया गया।';

  @override
  String get adminNoClassName =>
      'कोई कक्षा का नाम नहीं डाला गया। कुछ भी नहीं बनाया गया।';

  @override
  String get adminNoActiveSubjects => 'इस कक्षा में कोई सक्रिय विषय नहीं है।';

  @override
  String get adminListReadFailed => 'प्रशासन की सूची पढ़ी नहीं जा सकी।';

  @override
  String adminNotRefreshed(String reason) {
    return '$reason प्रशासन का डेटा रीफ़्रेश नहीं हुआ। फिर से कोशिश करने के लिए 1 दबाएँ।';
  }

  @override
  String adminExploreIntro(String sections) {
    return '$sections देखने के लिए डी-पैड का ऊपर और नीचे बटन इस्तेमाल करें। चुनने के लिए ओके दबाएँ।';
  }

  @override
  String adminSectionTitle(String section) {
    return 'प्रशासन। $section भाग';
  }

  @override
  String get adminSectionNameAccounts => 'खाते';

  @override
  String get adminSectionNameClasses => 'कक्षाएँ';

  @override
  String get adminSectionNameSubjects => 'विषय';

  @override
  String get adminNoMatchingAccounts =>
      'कोई मिलता-जुलता खाता नहीं है। खोज या फ़िल्टर बदलें।';

  @override
  String adminNoMatchingAccountsFor(String search) {
    return '$search के लिए कोई मिलता-जुलता खाता नहीं है। खोज या फ़िल्टर बदलें।';
  }

  @override
  String adminClasses(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count कक्षाएँ',
      one: '1 कक्षा',
    );
    return '$_temp0';
  }

  @override
  String adminSubjects(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count विषय',
      one: '1 विषय',
    );
    return '$_temp0';
  }

  @override
  String adminAccountsSummary(int count, String classes, String subjects) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count खाते। $classes और $subjects।',
      one: '1 खाता। $classes और $subjects।',
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
      other: '$count खाते $search से मेल खाते हैं। $classes और $subjects।',
      one: '1 खाता $search से मेल खाता है। $classes और $subjects।',
    );
    return '$_temp0';
  }

  @override
  String adminClassesSentence(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count कक्षाएँ।',
      one: '1 कक्षा।',
    );
    return '$_temp0';
  }

  @override
  String adminSubjectsSentence(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count विषय।',
      one: '1 विषय।',
    );
    return '$_temp0';
  }

  @override
  String get adminNavigationAccounts =>
      'खाता खोज, खाते के प्रकार और नामांकन के फ़िल्टर, और खाता प्रबंधन। किसी फ़िल्टर को बदलने के लिए उस पर बाएँ या दाएँ दबाएँ';

  @override
  String get adminNavigationClasses =>
      'कक्षा बनाना और सक्रिय या संग्रहित कक्षाओं की सूची। किसी कक्षा के विषय और उसे संग्रहित करने या वापस लाने के लिए उस पर ओके दबाएँ';

  @override
  String get adminNavigationSubjects =>
      'विषय बनाना और सक्रिय या संग्रहित विषयों की सूची। किसी विषय को संग्रहित करने या वापस लाने के लिए उस पर ओके दबाएँ';

  @override
  String get adminSectionsTitle => 'प्रशासन के भाग';

  @override
  String get adminSectionAccounts => 'खाते और नामांकन';

  @override
  String get adminSectionClasses => 'कक्षाएँ और उनके विषय';

  @override
  String get adminSectionSubjects => 'विषय';

  @override
  String adminSectionChosen(String section) {
    return '$section भाग।';
  }

  @override
  String adminSectionExplore(String what) {
    return '$what देखने के लिए डी-पैड इस्तेमाल करें। भाग बदलने के लिए 7 दबाएँ।';
  }

  @override
  String get adminExploreAccounts => 'खाते के फ़िल्टर, खोज और खाता प्रबंधन';

  @override
  String get adminExploreClasses =>
      'कक्षा बनाना, विषय जोड़ना, और संग्रहित करना या वापस लाना';

  @override
  String get adminExploreSubjects => 'विषय बनाना और संग्रहित करना या वापस लाना';

  @override
  String adminRoleFilterSelected(String label) {
    return 'खाते के प्रकार का फ़िल्टर: $label, चुना गया।';
  }

  @override
  String adminAssignmentFilterSelected(String label) {
    return 'असाइनमेंट फ़िल्टर: $label, चुना गया।';
  }

  @override
  String get adminRoleFilterStudents => 'केवल छात्र';

  @override
  String get adminRoleFilterTeachers => 'केवल शिक्षक';

  @override
  String get adminRoleFilterAll => 'सभी पंजीकृत खाते';

  @override
  String get adminAssignmentEnrolled => 'नामांकित';

  @override
  String get adminAssignmentAssigned => 'सौंपा गया';

  @override
  String get adminAssignmentEnrolledOrAssigned => 'नामांकित या सौंपा गया';

  @override
  String get adminAssignmentUnassigned => 'नहीं सौंपा गया';

  @override
  String get adminAssignmentAll => 'सभी असाइनमेंट स्थितियाँ';

  @override
  String get adminRoleStudent => 'छात्र';

  @override
  String get adminRoleTeacher => 'शिक्षक';

  @override
  String get adminNoClassAssigned => 'कोई कक्षा नहीं सौंपी गई';

  @override
  String adminAssignmentCount(String count) {
    return '$count असाइनमेंट';
  }

  @override
  String adminAccountLabel(String name, String role, String access) {
    return '$name, $role. $access. प्रबंधित करने के लिए ओके दबाएँ';
  }

  @override
  String get adminCancel => 'रद्द करें';

  @override
  String get adminSave => 'सेव करें';

  @override
  String get adminCreateSubjectTitle => 'विषय बनाएँ';

  @override
  String get adminSubjectNameField => 'विषय का नाम';

  @override
  String adminSubjectCreated(String name) {
    return 'विषय $name बनाया गया';
  }

  @override
  String get adminCreateClassTitle => 'कक्षा बनाएँ';

  @override
  String get adminClassNameField => 'कक्षा का नाम';

  @override
  String adminClassCreated(String name) {
    return 'कक्षा $name बनाई गई';
  }

  @override
  String get adminArchiveClassTitle => 'कक्षा संग्रहित करें?';

  @override
  String get adminRestoreClassTitle => 'कक्षा वापस लाएँ?';

  @override
  String adminArchiveItemMessage(String name) {
    return 'जब तक $name संग्रहित है, नए सत्र, ऑडियो और असाइनमेंट इसका उपयोग नहीं कर सकते।';
  }

  @override
  String adminRestoreItemMessage(String name) {
    return '$name फिर से असाइनमेंट के लिए उपलब्ध हो जाएगा।';
  }

  @override
  String get adminArchive => 'संग्रहित करें';

  @override
  String get adminRestore => 'वापस लाएँ';

  @override
  String get adminClassArchived => 'कक्षा संग्रहित की गई';

  @override
  String get adminClassRestored => 'कक्षा वापस लाई गई';

  @override
  String adminManageTitle(String name) {
    return '$name प्रबंधित करें';
  }

  @override
  String get adminManageClassSubjects => 'कक्षा के विषय प्रबंधित करें';

  @override
  String get adminArchiveClassChoice => 'पुष्टि के साथ कक्षा संग्रहित करें';

  @override
  String get adminRestoreClassChoice => 'पुष्टि के साथ कक्षा वापस लाएँ';

  @override
  String adminSubjectsForClass(String name) {
    return '$name के विषय';
  }

  @override
  String adminSubjectRemovedFrom(String name) {
    return '$name से विषय हटाया गया';
  }

  @override
  String adminSubjectAddedTo(String name) {
    return '$name में विषय जोड़ा गया';
  }

  @override
  String get adminArchiveSubjectTitle => 'विषय संग्रहित करें?';

  @override
  String get adminRestoreSubjectTitle => 'विषय वापस लाएँ?';

  @override
  String get adminSubjectArchived => 'विषय संग्रहित किया गया';

  @override
  String get adminSubjectRestored => 'विषय वापस लाया गया';

  @override
  String get adminManageAssignments => 'असाइनमेंट प्रबंधित करें';

  @override
  String get adminPasswordRecovery => 'पासवर्ड रिकवरी';

  @override
  String adminManageUserScreen(String name) {
    return '$name प्रबंधित करें। असाइनमेंट, पासवर्ड रिकवरी या रद्द करें चुनें।';
  }

  @override
  String get adminRecoveryNeedsVersion =>
      'खाता रिकवरी के लिए सर्वर का मौजूदा संस्करण चाहिए। खाता रीफ़्रेश करें।';

  @override
  String get adminNoActiveClasses =>
      'कोई सक्रिय कक्षा नहीं है। पहले कक्षाएँ सेक्शन में कोई कक्षा बनाएँ या वापस लाएँ।';

  @override
  String get adminTheCurrentClass => 'मौजूदा कक्षा';

  @override
  String adminAssignClassTo(String name) {
    return '$name को कक्षा सौंपें';
  }

  @override
  String get adminAssign => 'सौंपें';

  @override
  String get adminRemoveClass => 'कक्षा हटाएँ';

  @override
  String get adminClassField => 'कक्षा';

  @override
  String adminRemoveStudentLabel(String name, String className) {
    return '$name को $className से हटाएँ, पुष्टि माँगेगा';
  }

  @override
  String adminAssignStudentLabel(String name) {
    return '$name को चुनी गई कक्षा में सौंपें';
  }

  @override
  String get adminRemoveFromClassTitle => 'कक्षा से हटाएँ?';

  @override
  String adminRemoveFromClassMessage(String name, String className) {
    return '$name को $className से हटाएँ? दोबारा सौंपे जाने तक वे वह कक्षा नहीं देख पाएँगे।';
  }

  @override
  String get adminKeepInClass => 'कक्षा में रखें';

  @override
  String get adminRemoveFromClass => 'कक्षा से हटाएँ';

  @override
  String adminStudentRemovedFromClass(String name) {
    return '$name को कक्षा से हटाया गया';
  }

  @override
  String adminStudentAssignedTo(String name, String className) {
    return '$name को $className में सौंपा गया';
  }

  @override
  String adminAssignTeacherScreen(String name) {
    return '$name को कोई कक्षा और विषय सौंपें';
  }

  @override
  String adminRemoveAssignmentLabel(
    String name,
    String className,
    String subject,
  ) {
    return '$name को $className, $subject से हटाएँ, पुष्टि माँगेगा';
  }

  @override
  String get adminSubjectField => 'विषय';

  @override
  String get adminSaveAssignment => 'असाइनमेंट सेव करें';

  @override
  String get adminTeacherAssignmentSaved => 'शिक्षक असाइनमेंट सेव किया गया';

  @override
  String get adminRemoveAssignmentTitle => 'असाइनमेंट हटाएँ?';

  @override
  String adminRemoveAssignmentMessage(
    String name,
    String className,
    String subject,
  ) {
    return '$name को $className, $subject से हटाएँ?';
  }

  @override
  String get adminKeep => 'रखें';

  @override
  String get adminRemove => 'हटाएँ';

  @override
  String get adminTeacherAssignmentRemoved => 'शिक्षक असाइनमेंट हटाया गया';

  @override
  String get adminRefreshData => 'प्रशासक डेटा रीफ़्रेश करें';

  @override
  String get adminLogout => 'लॉग आउट करें, पुष्टि माँगेगा';

  @override
  String adminSectionButton(String section) {
    return '$section सेक्शन। प्रशासन सेक्शन बदलें';
  }

  @override
  String get adminSearchAccounts =>
      'नाम या फ़ोन नंबर से खाते खोजें। टाइप करने के लिए ओके दबाएँ';

  @override
  String adminRoleFilterLabel(String label) {
    return 'खाता प्रकार फ़िल्टर: $label, चुना गया। बदलने के लिए बाएँ या दाएँ का उपयोग करें';
  }

  @override
  String adminAssignmentFilterLabel(String label) {
    return 'असाइनमेंट फ़िल्टर: $label, चुना गया। बदलने के लिए बाएँ या दाएँ का उपयोग करें';
  }

  @override
  String adminClassActiveLabel(String name) {
    return '$name, सक्रिय। कक्षा के विषयों और संग्रहित करने या वापस लाने के लिए ओके दबाएँ';
  }

  @override
  String adminClassArchivedLabel(String name) {
    return '$name, संग्रहित। कक्षा के विषयों और संग्रहित करने या वापस लाने के लिए ओके दबाएँ';
  }

  @override
  String adminSubjectActiveLabel(String name) {
    return '$name, सक्रिय। संग्रहित करने के लिए ओके दबाएँ';
  }

  @override
  String adminSubjectArchivedLabel(String name) {
    return '$name, संग्रहित। वापस लाने के लिए ओके दबाएँ';
  }

  @override
  String adminSubjectInClass(String name) {
    return '$name. इस कक्षा में उपलब्ध है। हटाने के लिए चुनें';
  }

  @override
  String adminSubjectNotInClass(String name) {
    return '$name. इस कक्षा में उपलब्ध नहीं है। जोड़ने के लिए चुनें';
  }

  @override
  String get teacherHomeLater => 'बाद में';

  @override
  String get teacherHomeStartNow => 'अभी शुरू करें';

  @override
  String get teacherHomeChooseWorkspaceTitle => 'कक्षा और विषय चुनें';

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
    return '$className, $subjectName चुना गया। $status। दूसरा वर्कस्पेस चुनने के लिए 7 दबाएँ।';
  }

  @override
  String get teacherHomeUntitledSession => 'बिना नाम का सत्र';

  @override
  String get teacherHomeUntitledSessionTitle => 'बिना नाम का सत्र';

  @override
  String get teacherHomeSessionFallback => 'सत्र';

  @override
  String get teacherHomeSearchLabel =>
      'सत्र खोजें। ओके दबाएँ, फिर नाम या सत्र नंबर टाइप करें';

  @override
  String get teacherHomeKeepSessionOpen => 'सत्र खुला रखें';

  @override
  String get teacherHomeEndForEveryone => 'सबके लिए समाप्त करें';

  @override
  String get teacherHomeKeepEnded => 'समाप्त ही रहने दें';

  @override
  String get teacherHomeReactivate => 'फिर से चालू करें';

  @override
  String get teacherHomeOpenLater => 'बाद में खोलें';

  @override
  String get teacherHomeOpenNow => 'अभी खोलें';

  @override
  String get teacherHomeKeepSession => 'सत्र रखें';

  @override
  String get teacherHomeDeletePermanently => 'हमेशा के लिए हटाएँ';

  @override
  String get teacherHomeNewSessionTitle => 'नया सत्र';

  @override
  String get teacherHomeCreateScreen => 'नया सत्र बनाएँ';

  @override
  String get teacherHomeCreateSessionKey => 'सत्र बनाएँ';

  @override
  String get teacherHomeTitleField => 'सत्र शीर्षक फ़ील्ड';

  @override
  String get teacherHomeCancelCreate => 'सत्र बनाना रद्द करें';

  @override
  String get studentHomeSearchHelp =>
      'सत्र खोज। कीपैड से सत्र नंबर टाइप करें, या नाम से खोजने के लिए नीचे जाएँ। बदलने के लिए ओके दबाएँ। नतीजे देखने के लिए नीचे जाएँ।';

  @override
  String studentHomeSubjectFallback(String id) {
    return 'विषय $id';
  }

  @override
  String get studentHomeUntitledSession => 'बिना नाम का सत्र';

  @override
  String studentHomeSessionJoinLabel(String session) {
    return '$session। जुड़ने के लिए ओके दबाएँ';
  }

  @override
  String get inviteNoStudentsEnrolled =>
      'इस कक्षा में कोई छात्र नामांकित नहीं है। रीफ़्रेश करने के लिए 1 दबाएँ।';

  @override
  String inviteLoadedSummary(int count, String invited) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count छात्र, $invited आमंत्रित।',
      one: '1 छात्र, $invited आमंत्रित।',
    );
    return '$_temp0';
  }

  @override
  String get inviteUseSearch =>
      'कोई नाम ढूँढने के लिए खोज फ़ील्ड का उपयोग करें।';

  @override
  String get inviteLoadFailed =>
      'छात्रों को लोड नहीं किया जा सका। अपना कनेक्शन जाँचें और फिर से कोशिश करने के लिए 1 दबाएँ।';

  @override
  String inviteAlreadyInvited(String name) {
    return '$name पहले से आमंत्रित है।';
  }

  @override
  String inviteInvitedOne(String name) {
    return '$name को आमंत्रित किया।';
  }

  @override
  String inviteOneFailed(String name) {
    return '$name को आमंत्रित नहीं किया जा सका। अपना कनेक्शन जाँचें और फिर से कोशिश करने के लिए ओके दबाएँ।';
  }

  @override
  String get inviteNoStudentsToInvite =>
      'आमंत्रित करने के लिए कोई छात्र नहीं है।';

  @override
  String get inviteAllAlreadyInvited => 'सभी छात्र पहले से आमंत्रित हैं।';

  @override
  String inviteInvitingAll(String count) {
    return '$count छात्रों को आमंत्रित किया जा रहा है। कृपया प्रतीक्षा करें।';
  }

  @override
  String inviteProgress(String done, String total) {
    return 'छात्रों को आमंत्रित किया जा रहा है: $total में से $done पूरे।';
  }

  @override
  String inviteAllDone(String count) {
    return 'सभी $count छात्रों को आमंत्रित किया।';
  }

  @override
  String invitePartialFailed(String invited, String total, String names) {
    return '$total में से $invited छात्रों को आमंत्रित किया। $names को आमंत्रित नहीं किया जा सका। फिर से कोशिश करने के लिए 2 दबाएँ।';
  }

  @override
  String inviteShowingAll(String count) {
    return 'सभी $count छात्र दिखाए जा रहे हैं।';
  }

  @override
  String inviteNoMatch(String query) {
    return '$query से कोई छात्र मेल नहीं खाता। सभी को देखने के लिए खोज साफ़ करें।';
  }

  @override
  String inviteMatches(int count, String query) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count छात्र $query से मेल खाते हैं। देखने के लिए नीचे का उपयोग करें।',
      one: '1 छात्र $query से मेल खाता है। देखने के लिए नीचे का उपयोग करें।',
    );
    return '$_temp0';
  }

  @override
  String inviteStudentInvited(String name) {
    return '$name, आमंत्रित';
  }

  @override
  String inviteStudentNotInvited(String name) {
    return '$name, आमंत्रित नहीं। आमंत्रित करने के लिए ओके दबाएँ';
  }

  @override
  String get inviteBackToSession => 'सत्र पर वापस जाएँ';

  @override
  String get inviteRefreshList => 'छात्र सूची रीफ़्रेश करें';

  @override
  String get inviteAllStudents => 'सभी छात्रों को आमंत्रित करें';

  @override
  String get inviteSearchLabel =>
      'नाम या फ़ोन नंबर से छात्र खोजें। टाइप करने के लिए ओके दबाएँ';

  @override
  String inviteScreenName(String title) {
    return '$title में छात्रों को आमंत्रित करें';
  }

  @override
  String get inviteKeyBack => 'सत्र पर वापस';

  @override
  String get inviteKeyRefresh => 'छात्र रीफ़्रेश करें';

  @override
  String get inviteKeyInviteAll => 'सभी को आमंत्रित करें';

  @override
  String get notificationTitleSessionInvitation => 'लाइव कक्षा';

  @override
  String get notificationTitleJourneyPublished => 'नई सीखने की यात्रा';

  @override
  String get notificationTitleQuizPublished => 'नया क्विज़';

  @override
  String get notificationTitleQuizReminder => 'क्विज़ की याद';

  @override
  String get notificationTitleDefault => 'SEEDS अपडेट';

  @override
  String get notificationArrivedSessionInvitation =>
      'आपके शिक्षक ने कक्षा शुरू की है। जुड़ने के लिए 1 दबाएँ, या अभी नहीं के लिए 0।';

  @override
  String get notificationArrivedJourneyPublished =>
      'आपके शिक्षक ने एक नई सीखने की यात्रा साझा की है। खोलने के लिए 1 दबाएँ, या अभी नहीं के लिए 0।';

  @override
  String get notificationArrivedQuizPublished =>
      'आपके शिक्षक ने एक नया क्विज़ प्रकाशित किया है। अपने क्विज़ खोलने के लिए 1 दबाएँ, या अभी नहीं के लिए 0।';

  @override
  String get notificationArrivedQuizReminder =>
      'याद दिलाना: आपको एक क्विज़ देना है। अपने क्विज़ खोलने के लिए 1 दबाएँ, या अभी नहीं के लिए 0।';

  @override
  String get notificationArrivedDefault =>
      'आपके लिए एक नया अपडेट है। वापस जाने के लिए 0 दबाएँ।';

  @override
  String get notificationForegroundSessionInvitation =>
      'आपके शिक्षक ने कक्षा शुरू की है। अपने डैशबोर्ड पर लाइव सत्र से इसमें जुड़ें।';

  @override
  String get notificationForegroundJourneyPublished =>
      'आपके शिक्षक ने एक नई सीखने की यात्रा साझा की है। इसे सीखने की यात्राएँ में देखें।';

  @override
  String get notificationForegroundQuizPublished =>
      'आपके शिक्षक ने एक नया क्विज़ प्रकाशित किया है।';

  @override
  String get notificationForegroundQuizReminder =>
      'याद दिलाना: आपको एक क्विज़ देना है।';

  @override
  String get notificationForegroundDefault => 'आपके लिए एक नया अपडेट है।';

  @override
  String get notificationOpenJoinClass => 'कक्षा में जुड़ें';

  @override
  String get notificationOpenJourney => 'यात्रा खोलें';

  @override
  String get notificationOpenQuizzes => 'क्विज़ खोलें';

  @override
  String get notificationOpenBack => 'वापस';

  @override
  String get notificationCannotOpen =>
      'इसे खोला नहीं जा सका। फिर से साइन इन करें, फिर इसे अपने डैशबोर्ड से खोलें।';

  @override
  String get authLoginSuccessful => 'साइन इन सफल रहा';

  @override
  String authRoleAlreadySelected(String role) {
    return '$role खाता पहले से चुना हुआ है';
  }

  @override
  String authRoleSelected(String role) {
    return '$role खाता चुना गया';
  }

  @override
  String authRecoveryStep(String number, String step) {
    return 'चरण $number। $step';
  }

  @override
  String get authEnterPhone => 'फ़ोन नंबर डालें';

  @override
  String get authEnterPassword => 'पासवर्ड डालें';

  @override
  String get authEnterName => 'नाम डालें';

  @override
  String get authRegistering => 'रजिस्टर हो रहा है, कृपया प्रतीक्षा करें।';

  @override
  String get authPasswordChanged => 'पासवर्ड बदल गया। साइन इन हो गया।';

  @override
  String journeyWhereFinished(String title) {
    return 'यात्रा पूरी हुई। $title.';
  }

  @override
  String journeyWhere(String number, String total, String kind, String title) {
    return 'चरण $number / $total। $kind। $title।';
  }

  @override
  String journeyWhereReplaying(
    String number,
    String total,
    String kind,
    String title,
  ) {
    return 'चरण $number / $total। $kind। $title। प्रश्न से पहले फिर से सुन रहे हैं।';
  }

  @override
  String get journeyKindRecording => 'रिकॉर्डिंग';

  @override
  String get journeyKindNarration => 'वर्णन';

  @override
  String get journeyKindQuestion => 'प्रश्न';

  @override
  String get journeyKindPoll => 'पोल';

  @override
  String journeyOption(String number, String text) {
    return 'विकल्प $number: $text।';
  }

  @override
  String journeyChooseKeys(String count) {
    return 'चुनने के लिए 1 से $count दबाएँ, फिर जमा करने के लिए 5 दबाएँ।';
  }

  @override
  String journeyPollQuestion(String question, String options, String keys) {
    return 'पोल। इसमें कोई उत्तर गलत नहीं है। $question $options $keys';
  }

  @override
  String journeyQuestion(String question, String options, String keys) {
    return 'प्रश्न। $question $options $keys';
  }

  @override
  String journeyQuestionTryAgain(
    String triesLeft,
    String question,
    String options,
    String keys,
  ) {
    return 'प्रश्न। फिर से कोशिश करें। $triesLeft $question $options $keys';
  }

  @override
  String journeyTriesLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count कोशिशें बाकी हैं।',
      one: '1 कोशिश बाकी है।',
    );
    return '$_temp0';
  }

  @override
  String journeyChosen(String number, String option) {
    return 'विकल्प $number, $option, चुना गया। जमा करने के लिए 5 दबाएँ, या कोई दूसरा नंबर चुनें।';
  }

  @override
  String journeyRecordingContent(String title) {
    return 'रिकॉर्डिंग: $title। रोकने या चलाने के लिए 5 दबाएँ। आगे बढ़ने के लिए तैयार हों तो 2 दबाएँ।';
  }

  @override
  String get journeyUntitled => 'बिना शीर्षक';

  @override
  String get journeyContentKeys =>
      'अगले चरण के लिए 2 दबाएँ, यह चरण दोहराने के लिए 3, आप कहाँ हैं यह सुनने के लिए 1, पिछली रिकॉर्डिंग या वर्णन पर वापस जाने के लिए 8 दबाएँ।';

  @override
  String journeyCorrect(String answer) {
    return 'सही! $answer।';
  }

  @override
  String get journeyPollSaved => 'धन्यवाद। आपका उत्तर सेव हो गया है।';

  @override
  String get journeyReplayOutcome =>
      'पूरी तरह सही नहीं। चलिए वह हिस्सा फिर से सुनते हैं, फिर एक बार और कोशिश करें।';

  @override
  String get journeyTryAgainOutcome =>
      'पूरी तरह सही नहीं। फिर से सोचें और कोई दूसरा उत्तर चुनें।';

  @override
  String journeyRevealed(String number, String answer, String explanation) {
    return 'पूरी तरह सही नहीं। सही उत्तर विकल्प $number है, $answer। $explanation';
  }

  @override
  String journeyWellDone(String title) {
    return 'बहुत बढ़िया! आपने $title पूरा कर लिया।';
  }

  @override
  String journeyFirstTryScore(int questions, String correct) {
    String _temp0 = intl.Intl.pluralLogic(
      questions,
      locale: localeName,
      other:
          'आपने पहली कोशिश में $questions में से $correct प्रश्नों के सही उत्तर दिए।',
      one: 'आपने पहली कोशिश में 1 में से $correct प्रश्न का सही उत्तर दिया।',
    );
    return '$_temp0';
  }

  @override
  String get journeyPlayAgainHelp =>
      'फिर से चलाने के लिए 1 दबाएँ, या अपनी यात्राओं पर वापस जाने के लिए 0 दबाएँ।';

  @override
  String get journeyStatusCompleted => 'पूरा हुआ';

  @override
  String get journeyStatusInProgress => 'जारी है';

  @override
  String get journeyStatusNew => 'नया';

  @override
  String journeyRowScore(String percent) {
    return 'स्कोर $percent प्रतिशत।';
  }

  @override
  String get journeyRowDownloaded => 'डाउनलोड हो चुका है।';

  @override
  String journeyStudentRow(
    String title,
    String subject,
    String steps,
    String questions,
    String status,
  ) {
    return '$title। $subject। $steps चरण, $questions प्रश्न। $status।';
  }

  @override
  String journeyTeacherRow(
    String title,
    String status,
    String steps,
    String questions,
  ) {
    return '$title। $status। $steps चरण, $questions प्रश्न।';
  }

  @override
  String get journeyRowGraded => 'अंक वाला।';

  @override
  String journeyStepRow(String number, String total, String name) {
    return 'चरण $number / $total। $name।';
  }

  @override
  String get journeyReplaysAutomatically => 'अपने आप फिर से चलता है।';

  @override
  String journeyReplaysFrom(String number) {
    return 'चरण $number से फिर से चलता है।';
  }

  @override
  String get journeyFinishedStatus => 'यात्रा पूरी हुई।';

  @override
  String get journeyRecordingPlaying => 'रिकॉर्डिंग चल रही है।';

  @override
  String get journeyRecordingPaused => 'रिकॉर्डिंग रुकी हुई है।';

  @override
  String get journeyNoOptionChosen => 'अभी तक कोई विकल्प नहीं चुना गया।';

  @override
  String journeyOptionSelected(String number, String option) {
    return 'विकल्प $number, $option, चुना गया।';
  }

  @override
  String journeyPreviewStart(String title) {
    return '$title का पूर्वावलोकन। कुछ भी सेव नहीं होगा।';
  }

  @override
  String journeyWelcomeBack(String title) {
    return '$title में आपका फिर से स्वागत है। जहाँ आपने छोड़ा था, वहीं से जारी है।';
  }

  @override
  String journeyStartingBrief(String title) {
    return '$title शुरू हो रहा है।';
  }

  @override
  String journeyStartingDetailed(String title, String steps) {
    return '$title शुरू हो रहा है। $steps चरण। मदद के लिए कभी भी स्टार दबाएँ।';
  }

  @override
  String journeyNotSaved(String reason) {
    return 'आपकी जगह सेव नहीं हो सकी। $reason';
  }

  @override
  String get journeyListeningAgain => 'फिर से सुन रहे हैं।';

  @override
  String journeyNarration(String text) {
    return '$text जारी रखने के लिए 2 दबाएँ।';
  }

  @override
  String journeyRecordingStatus(String title) {
    return 'रिकॉर्डिंग: $title';
  }

  @override
  String get journeyRecordingFailed =>
      'यह रिकॉर्डिंग नहीं चल सकी। अपना इंटरनेट जाँचें।';

  @override
  String get journeyRecordingRetry =>
      'फिर से कोशिश करने के लिए 3 दबाएँ, या अगले चरण पर जाने के लिए 2 दबाएँ।';

  @override
  String get journeyNotDownloaded =>
      'यह रिकॉर्डिंग इस फ़ोन पर डाउनलोड नहीं है।';

  @override
  String get journeyRecordingFinished => 'रिकॉर्डिंग पूरी हुई।';

  @override
  String journeyAnswerFirst(String count) {
    return 'पहले उत्तर दें। चुनने के लिए 1 से $count दबाएँ, फिर 5 दबाएँ।';
  }

  @override
  String get journeyNoEarlierContent =>
      'इससे पहले कोई रिकॉर्डिंग या वर्णन नहीं है।';

  @override
  String get journeyGoingBack => 'वापस जा रहे हैं।';

  @override
  String journeyNoSuchOption(String option, String count) {
    return 'विकल्प $option नहीं है। 1 से $count में से चुनें।';
  }

  @override
  String journeyChooseFirst(String count) {
    return 'पहले 1 से $count से कोई उत्तर चुनें।';
  }

  @override
  String get journeySendLater =>
      'यात्रा पूरी हुई। आपके ऑनलाइन होने पर आपके उत्तर भेज दिए जाएँगे।';

  @override
  String get journeyStartingAgain => 'फिर से शुरू हो रहा है।';

  @override
  String get journeyPaused => 'रुका हुआ है।';

  @override
  String get journeySeekRecordingsOnly =>
      'आगे-पीछे करना सिर्फ़ रिकॉर्डिंग पर काम करता है।';

  @override
  String get journeySpeedRecordingsOnly =>
      'रिकॉर्डिंग की गति सिर्फ़ रिकॉर्डिंग पर बदलती है।';

  @override
  String get journeyFastest => 'सबसे तेज़ गति।';

  @override
  String get journeySlowest => 'सबसे धीमी गति।';

  @override
  String journeySpeed(String rate) {
    return 'रिकॉर्डिंग की गति $rate गुना।';
  }

  @override
  String get journeyLeaveTitle => 'यह यात्रा छोड़ें?';

  @override
  String journeyLeaveMessage(String step) {
    return 'आपकी जगह इस फ़ोन पर सेव है। अगली बार आप चरण $step से जारी रख सकते हैं।';
  }

  @override
  String get journeyAnswerHelp =>
      'चुनने के लिए कोई नंबर दबाएँ, जमा करने के लिए 5, प्रश्न दोहराने के लिए 6 दबाएँ।';

  @override
  String journeyStepRemoved(String remaining) {
    return 'चरण हटाया गया। अब यात्रा में $remaining चरण हैं।';
  }

  @override
  String journeyStepRemovedUndo(String name) {
    return '$name हटाया गया।';
  }

  @override
  String get journeyStepRestored => 'चरण वापस लाया गया।';

  @override
  String journeyCreated(String title) {
    return '$title बनाया गया। अब इसका पहला चरण जोड़ें।';
  }

  @override
  String get journeyNoStepAdded => 'कोई चरण नहीं जोड़ा गया।';

  @override
  String journeyPreviewSkips(String issues) {
    return 'इस पूर्वावलोकन में कुछ चरण छोड़े गए हैं। $issues';
  }

  @override
  String journeyDuplicated(String title) {
    return '$title नए ड्राफ़्ट के रूप में बनाया गया। इसे ड्राफ़्ट में ढूँढें।';
  }

  @override
  String journeyArchiveMessage(String title) {
    return 'छात्र अब $title नहीं देख पाएँगे। परिणाम रखे जाएँगे। आप इसे बाद में वापस ला सकते हैं।';
  }

  @override
  String journeyRestoreMessage(String title) {
    return 'छात्र $title फिर से देख पाएँगे।';
  }

  @override
  String get journeyArchived => 'संग्रहित किया गया। छात्र अब इसे नहीं देखते।';

  @override
  String get journeyRestored => 'छात्रों के लिए वापस लाया गया।';

  @override
  String journeyDeleteDraftMessage(String title) {
    return '$title को हमेशा के लिए हटाएँ? रिकॉर्डिंग आपकी लाइब्रेरी में रहेंगी।';
  }

  @override
  String get journeyDraftDeleted => 'ड्राफ़्ट हटाया गया।';

  @override
  String get journeyNoRetriesLeft => 'पहले से कोई दोबारा कोशिश नहीं है।';

  @override
  String get journeyMaxRetries =>
      'ज़्यादा से ज़्यादा पाँच बार दोबारा कोशिश हो सकती है।';

  @override
  String journeyPublished(String count) {
    return 'प्रकाशित हुआ। छात्र अब इसे चला सकते हैं। सूचनाएँ $count फ़ोन तक पहुँचीं।';
  }

  @override
  String get journeyOptionUsed =>
      'यह विकल्प पहले से इस्तेमाल हो चुका है। कोई दूसरा विकल्प टाइप करें।';

  @override
  String get journeyNothingToReplay =>
      'इस प्रश्न से पहले अभी कोई रिकॉर्डिंग या वर्णन नहीं है, इसलिए गलत उत्तर पर प्रश्न फिर से पूछा जाएगा। आप पहले सामग्री जोड़कर इसे बाद में बदल सकते हैं।';

  @override
  String get journeyBankEmpty =>
      'इस कक्षा और विषय के लिए आपका प्रश्न बैंक खाली है। इसकी जगह नया प्रश्न लिखें चुनें।';

  @override
  String get journeyRecordViaNotes =>
      'निजी नोट खुल रहे हैं। रिकॉर्ड करें, सुनकर जाँचें, फिर इस कक्षा और विषय में प्रकाशित करें चुनें। 0 से वापस आएँ, और अपनी नई रिकॉर्डिंग चुनें।';

  @override
  String get journeyNoRecordings =>
      'इस कक्षा और विषय में अभी कोई ऑडियो फ़ाइल नहीं है, इसलिए कुछ नहीं जोड़ा गया। आप पिछली स्क्रीन पर वापस हैं। जोड़ने के लिए, फिर से रिकॉर्डिंग चुनें, फिर रिकॉर्डिंग फ़ाइल अपलोड करने के लिए 2 या नई रिकॉर्डिंग करने के लिए 3 दबाएँ।';

  @override
  String get journeyOpeningFiles =>
      'ऑडियो फ़ाइल चुनने के लिए फ़ाइल चुनने वाला खुल रहा है।';

  @override
  String get journeyNoFile => 'कोई फ़ाइल नहीं चुनी गई।';

  @override
  String get journeyUploading => 'अपलोड हो रहा है। कृपया प्रतीक्षा करें।';

  @override
  String get journeyUploadUnconfirmed =>
      'अपलोड की पुष्टि नहीं हुई। दोहराव से बचने के लिए, फिर से कोशिश करने से पहले मेरी रिकॉर्डिंग जाँचें।';

  @override
  String journeyUploaded(String title) {
    return '$title अपलोड किया गया।';
  }

  @override
  String get journeyStorageUnavailable => 'यात्रा स्टोरेज उपलब्ध नहीं है।';

  @override
  String get journeyNothingInProgress =>
      'कोई यात्रा जारी नहीं है। नई यात्राओं के लिए 2 दबाएँ।';

  @override
  String get journeyTeacherUpdated =>
      'आपके शिक्षक ने यह यात्रा अपडेट की है। नया संस्करण ऑफ़लाइन चलाने के लिए इसे फिर से डाउनलोड करें।';

  @override
  String journeyStartOverMessage(String title) {
    return '$title को चरण 1 से फिर से शुरू करें? आपके पहले दिए गए उत्तर फिर भी आपके शिक्षक को भेजे जाते हैं।';
  }

  @override
  String journeyRemoveDownloadMessage(String title) {
    return '$title को इस फ़ोन से हटाएँ? यात्रा में आपकी जगह रखी जाएगी। आप इंटरनेट से इसे फिर से डाउनलोड कर सकते हैं।';
  }

  @override
  String journeyDownloadRemoved(String title) {
    return '$title का डाउनलोड हटाया गया।';
  }

  @override
  String journeyDownloading(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count रिकॉर्डिंग डाउनलोड हो रही हैं। रद्द करने के लिए 0 दबाएँ।',
      one: '1 रिकॉर्डिंग डाउनलोड हो रही है। रद्द करने के लिए 0 दबाएँ।',
    );
    return '$_temp0';
  }

  @override
  String journeyDownloaded(String title) {
    return 'डाउनलोड हो गया। आप बिना इंटरनेट के $title चला सकते हैं।';
  }

  @override
  String get journeyCancellingDownload =>
      'डाउनलोड रद्द हो रहा है। सेव की गई रिकॉर्डिंग रखी जाएँगी।';

  @override
  String journeyStepDetailsQuestion(
    String name,
    String options,
    String number,
    String explanation,
  ) {
    return '$name $options सही उत्तर: विकल्प $number। $explanation';
  }

  @override
  String get journeyNoExplanation => 'कोई व्याख्या नहीं।';

  @override
  String journeyExplanation(String text) {
    return 'व्याख्या: $text';
  }

  @override
  String journeyStepNameRecording(String title) {
    return 'रिकॉर्डिंग। $title';
  }

  @override
  String get journeyUntitledRecording => 'बिना शीर्षक की रिकॉर्डिंग';

  @override
  String journeyStepNameNarration(String text) {
    return 'वर्णन। $text';
  }

  @override
  String journeyStepNameQuestion(String text) {
    return 'प्रश्न। $text';
  }

  @override
  String journeyStepNamePoll(String text) {
    return 'पोल। $text';
  }

  @override
  String get journeyStatusPublished => 'प्रकाशित';

  @override
  String get journeyStatusArchived => 'संग्रहित';

  @override
  String get journeyStatusDraft => 'ड्राफ़्ट, अभी प्रकाशित नहीं';

  @override
  String journeyStatusWithChanges(String status) {
    return '$status, अप्रकाशित बदलावों के साथ';
  }

  @override
  String get journeyErrorChanged =>
      'यह यात्रा बदल गई है। रीफ़्रेश करें और फिर से कोशिश करें।';

  @override
  String get journeyErrorSignInExpired =>
      'आपका साइन इन समाप्त हो गया है। फिर से साइन इन करें।';

  @override
  String get journeyErrorPermission => 'आपको ऐसा करने की अनुमति नहीं है।';

  @override
  String get journeyErrorNotAvailable => 'यह यात्रा अब उपलब्ध नहीं है।';

  @override
  String get journeyErrorInvalid =>
      'कुछ जानकारी स्वीकार नहीं की जा सकी। इसे जाँचें और फिर से कोशिश करें।';

  @override
  String get journeyErrorServer =>
      'स्कूल सर्वर में कोई समस्या हुई। बाद में फिर से कोशिश करें।';

  @override
  String get journeyErrorRequestFailed =>
      'अनुरोध सफल नहीं हुआ। फिर से कोशिश करें।';

  @override
  String get journeyErrorResponseUnreadable =>
      'सर्वर का जवाब पढ़ा नहीं जा सका। फिर से कोशिश करने से पहले रीफ़्रेश करें।';

  @override
  String get journeyErrorSavedUnreadable =>
      'सेव की गई यात्रा पढ़ी नहीं जा सकी। फिर से कोशिश करने से पहले रीफ़्रेश करें।';

  @override
  String get journeyErrorListUnreadable => 'यात्रा सूची पढ़ी नहीं जा सकी।';

  @override
  String get journeyErrorMismatch =>
      'सेव की गई यात्रा मेल नहीं खाई। फिर से कोशिश करने से पहले रीफ़्रेश करें।';

  @override
  String get journeyErrorPreviewUnreadable =>
      'यात्रा का पूर्वावलोकन पढ़ा नहीं जा सका।';

  @override
  String get journeyErrorRecordingsUnreadable =>
      'रिकॉर्डिंग सूची पढ़ी नहीं जा सकी।';

  @override
  String get journeyErrorBankUnreadable => 'प्रश्न बैंक पढ़ा नहीं जा सका।';

  @override
  String get journeyErrorJourneyUnreadable => 'यह यात्रा पढ़ी नहीं जा सकी।';

  @override
  String get journeyDownloadNeedsApp =>
      'ऑफ़लाइन उपयोग के लिए डाउनलोड करने हेतु SEEDS Android ऐप चाहिए। ब्राउज़र में, यात्राएँ तभी चलती हैं जब आप ऑनलाइन हों।';

  @override
  String get journeySignInFirst =>
      'सीखने की यात्राएँ खोलने से पहले साइन इन करें।';

  @override
  String get journeyStorageUnavailableDevice =>
      'इस डिवाइस पर यात्रा का स्टोरेज उपलब्ध नहीं है।';

  @override
  String get journeyStorageFull =>
      'यात्रा का स्टोरेज उपलब्ध नहीं है। खाली जगह जाँचें और फिर से कोशिश करें। कुछ भी डिलीट नहीं हुआ।';

  @override
  String get journeyDownloadCancelled =>
      'डाउनलोड रद्द हो गया। जो रिकॉर्डिंग पहले से सेव हैं, वे रखी गई हैं।';

  @override
  String journeyRecordingsSaved(String done, String total) {
    return '$total में से $done रिकॉर्डिंग सेव हैं।';
  }

  @override
  String get journeyLeaveJourney => 'यात्रा छोड़ें';

  @override
  String get journeyLeaveSaved => 'यात्रा छोड़ें। आपकी जगह सेव है';

  @override
  String get journeyKeyPlayAgain => 'फिर से चलाएँ';

  @override
  String get journeyKeySubmitAnswer => 'उत्तर भेजें';

  @override
  String get journeyKeyRepeatQuestion => 'प्रश्न दोहराएँ';

  @override
  String get journeyKeySlowerSpeech => 'धीमी आवाज़';

  @override
  String get journeyKeyWhereAmI => 'मैं कहाँ हूँ';

  @override
  String get journeyKeyFasterSpeech => 'तेज़ आवाज़';

  @override
  String get journeyKeyNextStep => 'अगला चरण';

  @override
  String get journeyKeyRepeatStep => 'यह चरण दोहराएँ';

  @override
  String get journeyKeyReadAgain => 'फिर से पढ़ें';

  @override
  String get journeyKeyPreviousContent => 'पिछली रिकॉर्डिंग या वर्णन';

  @override
  String journeyPreviewTitle(String title) {
    return 'पूर्वावलोकन: $title';
  }

  @override
  String get journeyPositionFinished => 'पूरा हुआ';

  @override
  String journeyStepPosition(String number, String total) {
    return '$total में से चरण $number';
  }

  @override
  String journeySelectedLabel(String label) {
    return '$label, चुना गया';
  }

  @override
  String get journeyResultsLoading => 'परिणाम लोड हो रहे हैं।';

  @override
  String journeyResultsSummary(
    String completed,
    String eligible,
    String inProgress,
    String notStarted,
  ) {
    return '$eligible में से $completed छात्रों ने पूरा किया। $inProgress चल रहे हैं, $notStarted ने शुरू नहीं किया।';
  }

  @override
  String journeyResultsAverage(String percent) {
    return 'पहली कोशिश का औसत स्कोर $percent प्रतिशत।';
  }

  @override
  String get journeyResultFinished => 'पूरा हुआ';

  @override
  String get journeyResultNotStarted => 'शुरू नहीं हुआ';

  @override
  String journeyResultStudent(String name, String status) {
    return '$name. $status.';
  }

  @override
  String journeyResultFirstTime(String correct, String total) {
    return '$total में से $correct पहली बार में सही।';
  }

  @override
  String journeyResultWrongAnswers(String count) {
    return '$count गलत उत्तर।';
  }

  @override
  String journeyResultQuestion(String number, String text, String answered) {
    return 'चरण $number. $text. $answered ने उत्तर दिया।';
  }

  @override
  String journeyResultRate(String percent) {
    return '$percent प्रतिशत पहली बार में सही।';
  }

  @override
  String get journeyResultNoAnswers => 'अभी तक कोई उत्तर नहीं।';

  @override
  String journeyResultAverageTries(String attempts) {
    return 'औसत $attempts कोशिशें।';
  }

  @override
  String journeyResultPoll(
    String number,
    String text,
    String answered,
    String options,
  ) {
    return 'चरण $number. $text. $answered ने उत्तर दिया। $options.';
  }

  @override
  String get journeyResultsStudentsTitle => 'छात्र';

  @override
  String get journeyResultsQuestionsTitle => 'प्रश्न';

  @override
  String get journeyResultsPollsTitle => 'पोल के उत्तर';

  @override
  String journeyResultsTitle(String title) {
    return 'परिणाम: $title';
  }

  @override
  String get journeyResultsHearSummary => 'कक्षा का सारांश सुनें';

  @override
  String journeyResultsStudents(String count) {
    return 'छात्र, $count';
  }

  @override
  String journeyResultsQuestions(String count) {
    return 'प्रश्न, $count. दिखाता है कि कौन से हिस्से फिर से पढ़ाने हैं';
  }

  @override
  String journeyResultsPolls(String count) {
    return 'पोल के उत्तर, $count';
  }

  @override
  String get journeyResultsRefresh => 'परिणाम रीफ़्रेश करें';

  @override
  String get journeyResultsNoStudents => 'इस कक्षा में कोई छात्र नहीं है।';

  @override
  String get journeyResultsNoQuestions => 'इस यात्रा में कोई प्रश्न नहीं है।';

  @override
  String get journeyResultsNoPolls => 'इस यात्रा में कोई पोल नहीं है।';

  @override
  String get journeyNarrationLabel =>
      'वे शब्द जो फ़ोन ज़ोर से पढ़ेगा, जैसे: आज कुछ खाने के बारे में सुनते हैं';

  @override
  String journeyAddOptionTitle(String number) {
    return 'विकल्प $number जोड़ें?';
  }

  @override
  String journeyQuestionOptionsSoFar(String count) {
    return 'प्रश्न में अभी तक $count विकल्प हैं।';
  }

  @override
  String journeyPollOptionsSoFar(String count) {
    return 'पोल में अभी तक $count विकल्प हैं।';
  }

  @override
  String journeyAddOption(String number) {
    return 'विकल्प $number जोड़ें';
  }

  @override
  String get journeyNoMoreOptions => 'और विकल्प नहीं, आगे बढ़ें';

  @override
  String journeyOptionTitle(String number) {
    return 'विकल्प $number';
  }

  @override
  String journeyTypeOption(String number) {
    return 'विकल्प $number टाइप करें';
  }

  @override
  String get journeyReplayAutoNone => 'अपने आप: बिना दोबारा चलाए फिर से पूछें';

  @override
  String journeyReplayAutoFrom(String number, String name) {
    return 'अपने आप: चरण $number, $name से दोबारा चलाएँ';
  }

  @override
  String get journeyAfterWrongTitle => 'गलत उत्तर के बाद';

  @override
  String get journeyAfterWrongIntro =>
      'जब छात्र गलत उत्तर दे, तो फिर से कोशिश करने से पहले कौन सा हिस्सा दोबारा चलना चाहिए?';

  @override
  String get journeyReplayChooseStep =>
      'दोबारा चलाने के लिए कोई दूसरा चरण चुनें';

  @override
  String get journeyReplayWhichStep => 'किस चरण से दोबारा चलाएँ?';

  @override
  String journeyStepLabel(String number, String name) {
    return 'चरण $number. $name';
  }

  @override
  String journeyReviewReplayFrom(String number) {
    return 'गलत उत्तर के बाद, चरण $number फिर से चलेगा।';
  }

  @override
  String get journeyReviewReplayAuto =>
      'गलत उत्तर के बाद, यह अपने आप दोबारा चलेगा।';

  @override
  String get journeyCheckBeforeSaving => 'सेव करने से पहले जाँचें';

  @override
  String get journeySaveStep => 'यह चरण सेव करें';

  @override
  String get journeyRestartStep => 'यह चरण फिर से शुरू करें';

  @override
  String get journeyQuestionLabel => 'वह प्रश्न टाइप करें जो छात्र सुनेंगे';

  @override
  String get journeyWhichCorrect => 'कौन सा विकल्प सही है?';

  @override
  String journeyCurrentlyCorrect(String number) {
    return 'अभी विकल्प $number सही है।';
  }

  @override
  String journeyOptionChoice(String number, String text) {
    return 'विकल्प $number: $text';
  }

  @override
  String get journeyExplanationTitle => 'व्याख्या';

  @override
  String get journeyExplanationLabel =>
      'सही उत्तर बताने के बाद छात्र क्या सुनेंगे';

  @override
  String get journeyPollQuestionTitle => 'पोल प्रश्न';

  @override
  String get journeyPollQuestionLabel =>
      'ऐसा प्रश्न जिसका कोई गलत उत्तर नहीं, जैसे: क्या आपने इस हफ़्ते चावल खाया?';

  @override
  String get journeyQuestionBank => 'प्रश्न बैंक';

  @override
  String journeyBankQuestionLabel(String text, String count) {
    return '$text. $count विकल्प।';
  }

  @override
  String get journeyAddRecording => 'रिकॉर्डिंग जोड़ें';

  @override
  String get journeyChooseMyRecordings => 'मेरी रिकॉर्डिंग में से चुनें';

  @override
  String get journeyUploadRecordingFile => 'रिकॉर्डिंग फ़ाइल अपलोड करें';

  @override
  String get journeyRecordNew => 'नई रिकॉर्डिंग करें';

  @override
  String get journeyMyRecordings => 'मेरी रिकॉर्डिंग';

  @override
  String get journeyRecordingName => 'रिकॉर्डिंग का नाम';

  @override
  String get journeyRecordingNameLabel => 'इस रिकॉर्डिंग का नाम';

  @override
  String journeyOptionalLabel(String label) {
    return '$label. वैकल्पिक, छोड़ने के लिए खाली रखें';
  }

  @override
  String get journeyNothingEntered =>
      'कुछ नहीं लिखा गया। फ़ील्ड पर ओके दबाएँ और टाइप करें, या वापस जाने के लिए 0 दबाएँ।';

  @override
  String journeyTooLong(String max) {
    return 'बहुत लंबा है। ज़्यादा से ज़्यादा $max अक्षर लिखें।';
  }

  @override
  String get journeySkipped => 'छोड़ दिया गया।';

  @override
  String journeyYouEntered(String text) {
    return 'आपने लिखा: $text';
  }

  @override
  String get journeyMenuReady => 'तैयार।';

  @override
  String get journeyMenuReadDetailsHelp => 'विवरण फिर से सुनने के लिए 8 दबाएँ।';

  @override
  String journeyMenuBackHelp(String back) {
    return '$back के लिए 0 दबाएँ। मदद के लिए स्टार दबाएँ।';
  }

  @override
  String journeyMenuNothingAssigned(String number) {
    return '$number पर कुछ भी नहीं है।';
  }

  @override
  String get journeyMenuPleaseWait =>
      'कृपया रुकें। काम चल रहा है। वापस जाने के लिए 0 दबाएँ।';

  @override
  String get journeyMenuWorking => 'काम चल रहा है, कृपया रुकें।';

  @override
  String get journeyMenuReadDetails => 'विवरण फिर से पढ़ें';

  @override
  String get journeyNoInternetDownloaded =>
      'इंटरनेट नहीं है। डाउनलोड की गई यात्राएँ अब भी चलेंगी। डाउनलोड की गई यात्राओं के लिए 5 दबाएँ।';

  @override
  String journeyWaitingToSend(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count पूरी हुई यात्राएँ भेजी जानी बाकी हैं।',
      one: '1 पूरी हुई यात्रा भेजी जानी बाकी है।',
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
    return '$newCount नई, $inProgress चल रही, $completed पूरी, $downloaded डाउनलोड की गई।';
  }

  @override
  String get journeyDownloadedJourneys => 'डाउनलोड की गई यात्राएँ';

  @override
  String journeyDownloadedRow(String title, String steps) {
    return '$title. $steps चरण। डाउनलोड की गई।';
  }

  @override
  String get journeyOfflineReason =>
      'इसके लिए इंटरनेट चाहिए। डाउनलोड की गई यात्राओं के लिए 5 दबाएँ।';

  @override
  String get journeyLearningJourneys => 'सीखने की यात्राएँ';

  @override
  String get journeyStudentIntro =>
      'कहानियाँ और पाठ सुनें, साथ-साथ प्रश्नों के उत्तर दें, और ज़रूरी हिस्से दोहराएँ।';

  @override
  String get journeyContinueLast => 'मेरी पिछली यात्रा जारी रखें';

  @override
  String journeyNewJourneys(String count) {
    return 'नई यात्राएँ, $count';
  }

  @override
  String get journeyNewJourneysTitle => 'नई यात्राएँ';

  @override
  String get journeyNoNewJourneys => 'कोई नई यात्रा नहीं है।';

  @override
  String journeyInProgressCount(String count) {
    return 'चल रही हैं, $count';
  }

  @override
  String get journeyInProgressTitle => 'चल रही यात्राएँ';

  @override
  String get journeyNothingInProgressShort => 'कुछ भी चल नहीं रहा है।';

  @override
  String journeyCompletedCount(String count) {
    return 'पूरी हुईं, $count';
  }

  @override
  String get journeyCompletedTitle => 'पूरी हुई यात्राएँ';

  @override
  String get journeyNoneCompleted => 'अभी तक कोई यात्रा पूरी नहीं हुई।';

  @override
  String journeyDownloadedCount(String count) {
    return 'डाउनलोड की गईं, $count';
  }

  @override
  String get journeyNothingDownloaded =>
      'कुछ भी डाउनलोड नहीं है। कोई यात्रा खोलें और डाउनलोड चुनें।';

  @override
  String get journeyNoInternetNotDownloaded =>
      'इंटरनेट नहीं है, और यह यात्रा डाउनलोड नहीं है।';

  @override
  String get journeyStartOverTitle => 'फिर से शुरू करें?';

  @override
  String get journeyStartOver => 'फिर से शुरू करें';

  @override
  String get journeyRemoveDownloadTitle => 'डाउनलोड हटाएँ?';

  @override
  String get journeyRemoveDownload => 'डाउनलोड हटाएँ';

  @override
  String journeySavedRecordings(String done, String total) {
    return '$total में से $done रिकॉर्डिंग सेव हुईं।';
  }

  @override
  String get journeyDownloadedOnPhone => 'इस फ़ोन पर डाउनलोड है।';

  @override
  String get journeyNotDownloadedShort => 'डाउनलोड नहीं है।';

  @override
  String get journeyStartedThis => 'आपने यह यात्रा शुरू कर दी है।';

  @override
  String get journeyWorksOffline => 'डाउनलोड है। बिना इंटरनेट के चलती है।';

  @override
  String get journeyContinueJourney => 'यात्रा जारी रखें';

  @override
  String get journeyStartJourney => 'यात्रा शुरू करें';

  @override
  String get journeyHearAbout => 'इस यात्रा के बारे में सुनें';

  @override
  String get journeyDownloadOffline =>
      'बिना इंटरनेट के चलाने के लिए डाउनलोड करें';

  @override
  String get journeyDownloadInProgress =>
      'डाउनलोड चल रहा है। इसे रद्द करने के लिए 0 दबाएँ।';

  @override
  String get journeyStartFromBeginning => 'शुरुआत से फिर से शुरू करें';

  @override
  String get journeyNotStartedYet => 'आपने अभी तक यह यात्रा शुरू नहीं की है।';

  @override
  String journeyLatestLoaded(String message) {
    return '$message अब नया संस्करण लोड हो गया है।';
  }

  @override
  String journeyTeacherSummary(
    String drafts,
    String published,
    String archived,
  ) {
    return '$drafts ड्राफ़्ट, $published प्रकाशित, $archived संग्रहित।';
  }

  @override
  String get journeyNewJourneyTitle => 'नई सीखने की यात्रा';

  @override
  String get journeyNameExample => 'यात्रा का नाम, जैसे: हमारे आस-पास का खाना';

  @override
  String get journeyRefreshFirst => 'पहले सूची रीफ़्रेश करने के लिए 5 दबाएँ।';

  @override
  String journeyTeacherIntro(String workspace) {
    return '$workspace. छात्रों के लिए रिकॉर्डिंग, वर्णन, प्रश्न और पोल का एक क्रम बनाएँ।';
  }

  @override
  String get journeyCreateNew => 'नई यात्रा बनाएँ';

  @override
  String journeyDraftsCount(String count) {
    return 'ड्राफ़्ट, $count';
  }

  @override
  String get journeyDraftJourneys => 'ड्राफ़्ट यात्राएँ';

  @override
  String get journeyNoDrafts => 'कोई ड्राफ़्ट नहीं है।';

  @override
  String journeyPublishedCount(String count) {
    return 'प्रकाशित, $count';
  }

  @override
  String get journeyPublishedJourneys => 'प्रकाशित यात्राएँ';

  @override
  String get journeyNothingPublished => 'अभी तक कुछ भी प्रकाशित नहीं है।';

  @override
  String journeyArchivedCount(String count) {
    return 'संग्रहित, $count';
  }

  @override
  String get journeyArchivedJourneys => 'संग्रहित यात्राएँ';

  @override
  String get journeyNothingArchived => 'कुछ भी संग्रहित नहीं है।';

  @override
  String get journeyRefreshList => 'सूची रीफ़्रेश करें';

  @override
  String journeyOverviewSummary(
    String status,
    String steps,
    String questions,
    String graded,
    String retries,
  ) {
    return '$status. $steps चरण, $questions प्रश्न। $graded. $retries';
  }

  @override
  String get journeyGraded => 'अंक वाला';

  @override
  String get journeyNotGraded => 'बिना अंक वाला';

  @override
  String journeyRetriesPerQuestion(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'हर प्रश्न पर $count और कोशिशें।',
      one: 'हर प्रश्न पर 1 और कोशिश।',
    );
    return '$_temp0';
  }

  @override
  String get journeySteps => 'चरण';

  @override
  String journeyAddStepTitle(String number) {
    return 'चरण $number जोड़ें';
  }

  @override
  String get journeyAddStepIntro =>
      'नया चरण अंत में जुड़ेगा। आप इसे बाद में खिसका सकते हैं।';

  @override
  String get journeyChoiceRecording => 'रिकॉर्डिंग';

  @override
  String get journeyChoiceNarration => 'फ़ोन द्वारा पढ़ा जाने वाला वर्णन';

  @override
  String get journeyChoiceQuestion => 'प्रश्न';

  @override
  String get journeyChoicePoll => 'पोल, कोई गलत उत्तर नहीं';

  @override
  String journeySavedAsStep(String number, String name) {
    return 'चरण $number के रूप में सेव हुआ। $name';
  }

  @override
  String get journeyAddQuestion => 'प्रश्न जोड़ें';

  @override
  String get journeyWriteNewQuestion => 'नया प्रश्न लिखें';

  @override
  String get journeyChooseFromBank => 'मेरे प्रश्न बैंक से चुनें';

  @override
  String get journeyHearAndEdit => 'चरण सुनें और बदलें';

  @override
  String get journeyNoStepsYet =>
      'अभी कोई चरण नहीं है। एक जोड़ने के लिए 2 दबाएँ।';

  @override
  String get journeyAddStep => 'चरण जोड़ें';

  @override
  String get journeyPreviewAsStudent => 'छात्र की तरह पूर्वावलोकन करें';

  @override
  String get journeyAddStepFirst => 'पहले एक चरण जोड़ें।';

  @override
  String get journeyPublishToStudents => 'छात्रों के लिए प्रकाशित करें';

  @override
  String get journeyPublishChanges => 'बदलाव प्रकाशित करें';

  @override
  String get journeyStudentResults => 'छात्रों के परिणाम';

  @override
  String get journeyMoreOptions => 'और विकल्प';

  @override
  String journeyStepSaved(String number) {
    return 'चरण $number सेव हुआ।';
  }

  @override
  String journeyMoved(String number, String total) {
    return 'खिसका दिया गया। अब यह $total में से चरण $number है।';
  }

  @override
  String journeyRemoveStepTitle(String number) {
    return 'चरण $number हटाएँ?';
  }

  @override
  String journeyRemoveStepMessage(String name) {
    return '$name हटाएँ? रिकॉर्डिंग आपकी लाइब्रेरी में रहेंगी। जो प्रश्न इस चरण को दोबारा चलाते थे, वे अब अपने आप दोबारा चलाएँगे।';
  }

  @override
  String get journeyRemoveStep => 'चरण हटाएँ';

  @override
  String get journeyStepNotFound => 'चरण नहीं मिला';

  @override
  String get journeyStepWasRemoved =>
      'यह चरण हटा दिया गया था। वापस जाने के लिए 0 दबाएँ।';

  @override
  String get journeyHearStepInFull => 'यह चरण पूरा सुनें';

  @override
  String get journeyEditStep => 'यह चरण बदलें';

  @override
  String get journeyMoveEarlier => 'पहले खिसकाएँ';

  @override
  String get journeyAlreadyFirst => 'यह पहले से ही पहला चरण है।';

  @override
  String get journeyMoveLater => 'बाद में खिसकाएँ';

  @override
  String get journeyAlreadyLast => 'यह पहले से ही आखिरी चरण है।';

  @override
  String get journeyRemoveThisStep => 'यह चरण हटाएँ';

  @override
  String get journeyRenameTitle => 'यात्रा का नाम बदलें';

  @override
  String get journeyNameLabel => 'यात्रा का नाम';

  @override
  String journeyRenamed(String title) {
    return 'नाम बदलकर $title किया गया।';
  }

  @override
  String get journeyArchiveTitle => 'यह यात्रा संग्रहित करें?';

  @override
  String get journeyRestoreTitle => 'यह यात्रा वापस लाएँ?';

  @override
  String get journeyArchive => 'संग्रहित करें';

  @override
  String get journeyRestore => 'वापस लाएँ';

  @override
  String get journeyDeleteDraftTitle => 'यह ड्राफ़्ट डिलीट करें?';

  @override
  String get journeyDeleteDraft => 'ड्राफ़्ट डिलीट करें';

  @override
  String get journeyPublishFirst => 'पहले यात्रा प्रकाशित करें।';

  @override
  String get journeyRename => 'नाम बदलें';

  @override
  String get journeyGradingNowGraded => 'अंक और कोशिशें, अभी अंक वाला';

  @override
  String get journeyGradingNowNotGraded => 'अंक और कोशिशें, अभी बिना अंक वाला';

  @override
  String get journeyDuplicate => 'नए ड्राफ़्ट के रूप में कॉपी बनाएँ';

  @override
  String get journeyArchiveHide => 'संग्रहित करें, छात्रों से छिपाएँ';

  @override
  String get journeyRestoreForStudents => 'छात्रों के लिए वापस लाएँ';

  @override
  String get journeyDeleteThisDraft => 'यह ड्राफ़्ट डिलीट करें';

  @override
  String get journeyGradedSummary =>
      'अंक वाला: हर प्रश्न की पहली कोशिश स्कोर में गिनी जाती है।';

  @override
  String get journeyNotGradedSummary =>
      'बिना अंक वाला: प्रश्न केवल अभ्यास के लिए हैं।';

  @override
  String journeyMoreTriesSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'गलत उत्तर के बाद, छात्र को $count और कोशिशें मिलती हैं, पहले सामग्री दोबारा चलती है।',
      one:
          'गलत उत्तर के बाद, छात्र को 1 और कोशिश मिलती है, पहले सामग्री दोबारा चलती है।',
    );
    return '$_temp0';
  }

  @override
  String get journeyGradingTitle => 'अंक और कोशिशें';

  @override
  String get journeyTurnGradingOff => 'अंक देना बंद करें';

  @override
  String get journeyTurnGradingOn => 'अंक देना चालू करें';

  @override
  String get journeyGradingIsOff => 'अंक देना बंद है।';

  @override
  String get journeyGradingIsOn => 'अंक देना चालू है।';

  @override
  String get journeyFewerTries => 'कम कोशिशें';

  @override
  String get journeyMoreTries => 'ज़्यादा कोशिशें';

  @override
  String get journeyLoadingSummary => 'सारांश लोड हो रहा है।';

  @override
  String get journeyNoProblems => 'कोई समस्या नहीं।';

  @override
  String journeyProblems(String issues) {
    return 'प्रकाशित करने से पहले ठीक करने वाली समस्याएँ: $issues';
  }

  @override
  String journeyThingsToCheck(String warnings) {
    return 'जाँचने वाली बातें: $warnings';
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
    return '$title. $steps चरण: $recordings रिकॉर्डिंग, $narrations वर्णन, $questions प्रश्न, $polls पोल। $graded.';
  }

  @override
  String journeyPublishTitle(String title) {
    return '$title प्रकाशित करें?';
  }

  @override
  String get journeyPublishMessage =>
      'इस कक्षा के सभी छात्र इसे चला और डाउनलोड कर सकेंगे, और उन्हें एक सूचना मिलेगी।';

  @override
  String get journeyPublishNow => 'अभी प्रकाशित करें';

  @override
  String get journeyPublishedShort => 'प्रकाशित हो गया।';

  @override
  String get journeyReviewBeforePublishing => 'प्रकाशित करने से पहले जाँचें';

  @override
  String get journeyFixProblemsFirst =>
      'पहले समस्याएँ ठीक करें। उन्हें सुनने के लिए 8 दबाएँ।';

  @override
  String get journeyPreviewFirst => 'पहले छात्र की तरह पूर्वावलोकन करें';

  @override
  String undoOffer(String seconds) {
    return 'पहले जैसा करने के लिए $seconds सेकंड के अंदर 1 दबाएँ।';
  }

  @override
  String undoDone(String action) {
    return 'पहले जैसा कर दिया। $action को वापस ले लिया गया।';
  }

  @override
  String get undoFailed =>
      'पहले जैसा नहीं हो सका। चीज़ को जाँचें और ज़रूरत हो तो फिर से जोड़ें।';

  @override
  String get uiBack => 'वापस';

  @override
  String get uiCancel => 'रद्द करें';

  @override
  String get uiContinue => 'आगे बढ़ें';

  @override
  String get uiNotNow => 'अभी नहीं';

  @override
  String uiPressFor(String key, String action) {
    return '$action के लिए $key दबाएँ।';
  }

  @override
  String uiLabelUnavailable(String label) {
    return '$label, उपलब्ध नहीं';
  }

  @override
  String get uiAlreadyHome => 'आप पहले से होम स्क्रीन पर हैं।';

  @override
  String uiNotAvailableNow(String label) {
    return '$label अभी उपलब्ध नहीं है।';
  }

  @override
  String uiListLoading(String title) {
    return '$title लोड हो रहा है। वापस जाने के लिए 0 दबाएँ।';
  }

  @override
  String uiListPage(String title, String number) {
    return '$title। पेज $number।';
  }

  @override
  String uiListScreenName(String title, String number) {
    return '$title। पेज $number';
  }

  @override
  String get uiListNoMatches => 'कोई मिलता-जुलता आइटम नहीं है।';

  @override
  String get uiListHelp =>
      'रिफ़्रेश सहित सूची के विकल्पों के लिए 6 दबाएँ। पिछले पेज के लिए 7 दबाएँ। सभी आइटम खोजने के लिए 8 दबाएँ। अगले पेज के लिए 9 दबाएँ। वापस जाने के लिए 0 दबाएँ। आइटम और पेज कंट्रोल के बीच जाने के लिए D-pad का ऊपर और नीचे, और चुनने के लिए ओके इस्तेमाल करें। मदद दोहराने के लिए स्टार दबाएँ। आवाज़ रोकने के लिए हैश दबाएँ।';

  @override
  String get uiListLoadFailed =>
      'यह पेज लोड नहीं हो सका। दोबारा कोशिश के विकल्पों के लिए 6 दबाएँ। आपका पिछला पेज रखा गया है।';

  @override
  String get uiListLoadingWait =>
      'लोड हो रहा है। कृपया इंतज़ार करें, या वापस जाने के लिए 0 दबाएँ।';

  @override
  String uiListNoItem(String number) {
    return 'इस पेज पर $number के लिए कोई आइटम नहीं है।';
  }

  @override
  String get uiListFirstPage => 'यह पहला पेज है।';

  @override
  String get uiListLastPage => 'यह आखिरी पेज है।';

  @override
  String uiListSearchTitle(String title) {
    return '$title खोजें';
  }

  @override
  String get uiListSearchLabel => 'सभी उपलब्ध आइटम खोजें';

  @override
  String get uiListSearchTooLong =>
      'खोज के लिए ज़्यादा से ज़्यादा 200 अक्षर इस्तेमाल करें।';

  @override
  String get uiListOptions => 'सूची के विकल्प';

  @override
  String get uiListSearch => 'खोजें';

  @override
  String get uiListClearSearch => 'खोज हटाएँ';

  @override
  String get uiListRefreshPage => 'यह पेज रिफ़्रेश करें';

  @override
  String get uiListRetry => 'फिर से कोशिश करें';

  @override
  String get uiListFilters => 'फ़िल्टर';

  @override
  String get uiListPreviousPage => 'पिछला पेज';

  @override
  String get uiListSearchAll => 'सभी आइटम खोजें';

  @override
  String get uiListNextPage => 'अगला पेज';

  @override
  String get uiListSections =>
      'आइटम, सूची के विकल्प, पिछला पेज, खोज, अगला पेज और वापस';

  @override
  String get uiWaitingConfirmation =>
      'पुष्टि का इंतज़ार है। कृपया इंतज़ार करें।';

  @override
  String get uiFinishWord => 'अभी का शब्द पूरा लिखें, फिर ओके दबाएँ।';

  @override
  String get uiStepFailed =>
      'यह चरण पूरा नहीं हो सका। आपकी लिखी जानकारी रखी गई है। फिर से कोशिश करें।';

  @override
  String get uiPasswordVisible => 'पासवर्ड दिख रहा है।';

  @override
  String get uiPasswordHidden => 'पासवर्ड छिपा है।';

  @override
  String uiTextStepScreen(String title, String label) {
    return '$title। $label। लिख रहे हैं। खत्म करने के लिए ओके दबाएँ, या फ़ील्ड से बाहर जाने के लिए ऊपर या नीचे इस्तेमाल करें।';
  }

  @override
  String get uiShowOrHidePassword => 'पासवर्ड दिखाएँ या छिपाएँ';

  @override
  String get uiDateEnterNumbers =>
      'तारीख और समय के हर फ़ील्ड में एक संख्या लिखें।';

  @override
  String uiDateChooseValid(String from, String to) {
    return '$from से $to तक की कोई सही तारीख चुनें।';
  }

  @override
  String get uiDateInvalid =>
      'सही तारीख, 0 से 23 तक का घंटा और 0 से 59 तक का मिनट लिखें।';

  @override
  String uiDateChoose(String from, String to) {
    return '$from से $to तक की कोई तारीख चुनें।';
  }

  @override
  String uiRange(String from, String to) {
    return '$from से $to';
  }

  @override
  String get uiYear => 'साल';

  @override
  String get uiMonth => 'महीना';

  @override
  String get uiDay => 'दिन';

  @override
  String get uiHour => 'घंटा';

  @override
  String get uiMinute => 'मिनट';

  @override
  String uiDateFieldEmpty(String name, String range) {
    return '$name, $range, अभी खाली';
  }

  @override
  String uiDateFieldValue(String name, String range, String value) {
    return '$name, $range, अभी $value';
  }

  @override
  String uiDateScreen(String from, String to) {
    return 'फ़ोन के स्थानीय समय में तारीख और समय सेट करें। $from से $to तक की कोई तारीख चुनें।';
  }

  @override
  String get uiSaveDateTime => 'तारीख और समय सेव करें';

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
    return '$label: $value, $total में से $position';
  }

  @override
  String uiChoiceChange(String description) {
    return '$description। बदलने के लिए बाएँ या दाएँ इस्तेमाल करें';
  }

  @override
  String get startupPreferencesFailed =>
      'कुछ पसंद की सेटिंग्स लोड नहीं हो सकीं। डिफ़ॉल्ट सेटिंग्स इस्तेमाल हो रही हैं।';

  @override
  String get startupNotificationsTitle => 'सत्र की सूचनाएँ';

  @override
  String get startupNotificationsMessage =>
      'SEEDS सत्र के आमंत्रण और अपडेट बताने के लिए सूचनाओं का इस्तेमाल करता है। अगर आप अभी नहीं चुनते हैं, तब भी आप ऐप इस्तेमाल कर सकते हैं।';

  @override
  String get startupEnableNotifications => 'सूचनाएँ चालू करें';

  @override
  String get startupLoading => 'SEEDS लोड हो रहा है';

  @override
  String get startupWelcomeScreenName => 'SEEDS में आपका स्वागत है';

  @override
  String get startupLoginButton => 'लॉगिन, बटन';

  @override
  String get startupRegisterButton => 'रजिस्टर करें, बटन';

  @override
  String get startupSettingsButton => 'सेटिंग्स, बटन';

  @override
  String get startupRepeatInstructionsButton => 'निर्देश दोहराएँ, बटन';

  @override
  String get authSimAutofillOptional =>
      'SIM से फ़ोन नंबर अपने आप भरना ज़रूरी नहीं है';

  @override
  String get authRegisteredNowLogIn =>
      'रजिस्टर हो गया। अब साइन इन करें। फ़ोन नंबर फ़ील्ड। मदद के लिए स्टार दबाएँ।';

  @override
  String get authSimUnavailableOnDevice =>
      'इस फ़ोन पर SIM सुझाव उपलब्ध नहीं हैं। फ़ोन नंबर खुद डालें।';

  @override
  String get authSimDialogTitle => 'वैकल्पिक SIM ऑटोफ़िल';

  @override
  String get authSimDialogMessage =>
      'क्या इस फ़ोन से वैकल्पिक फ़ोन नंबर सुझाव पढ़ें? फ़ोन फ़ील्ड बदलने से पहले आप एक सुझाव चुनेंगे। इससे यह पक्का नहीं होता कि खाता किसका है। साइन इन, रजिस्ट्रेशन, Wi-Fi या सत्र में जुड़ने के लिए SIM की अनुमति कभी ज़रूरी नहीं है।';

  @override
  String get authSimDialogConfirm => 'SIM सुझाव पढ़ें';

  @override
  String get authSimAutofillSkipped =>
      'SIM ऑटोफ़िल छोड़ दिया गया। फ़ोन नंबर खुद डालें।';

  @override
  String get authSimDetecting => 'SIM कार्ड खोजा जा रहा है...';

  @override
  String get authSimAutofillUnavailable =>
      'SIM ऑटोफ़िल उपलब्ध नहीं है। फ़ोन नंबर खुद डालें।';

  @override
  String get authSimNoneFound =>
      'कोई SIM कार्ड नहीं मिला। फ़ोन नंबर खुद डालें।';

  @override
  String authSimCardsDetected(String count) {
    return '$count SIM कार्ड मिले। कृपया एक चुनें।';
  }

  @override
  String get authSimSuggestionUnavailable =>
      'SIM सुझाव उपलब्ध नहीं है। फ़ोन नंबर खुद डालें।';

  @override
  String authSimOptionLabel(String number, String carrier) {
    return 'SIM $number, $carrier';
  }

  @override
  String get authSimUnknownCarrier => 'अज्ञात नेटवर्क कंपनी';

  @override
  String get authSimSelectedFilled =>
      'चुना गया सुझाव भर दिया गया। यह खाते के मालिक होने का सबूत नहीं है।';

  @override
  String get authSimSuggestionFilledSpoken =>
      'फ़ोन नंबर सुझाव भर दिया गया। साइन इन के लिए अपना पासवर्ड डालें। साइन इन नहीं भेजा गया।';

  @override
  String get authErrorEnterPhone => 'अपना फ़ोन नंबर डालें।';

  @override
  String get authErrorInvalidPhone => 'सही 10 अंकों का फ़ोन नंबर डालें।';

  @override
  String get authErrorEnterPassword => 'अपना पासवर्ड डालें।';

  @override
  String get authErrorPasswordTooShort =>
      'पासवर्ड कम से कम 6 अक्षरों का होना चाहिए।';

  @override
  String get authErrorInvalidServerResponse => 'सर्वर से गलत जवाब मिला';

  @override
  String get authErrorNotRegisteredAdmin =>
      'यह फ़ोन नंबर प्रशासक खाते के रूप में रजिस्टर नहीं है। खाते का प्रकार चुनने के लिए 1, 2 या 3 दबाएँ।';

  @override
  String get authErrorNotRegisteredTeacher =>
      'यह फ़ोन नंबर शिक्षक खाते के रूप में रजिस्टर नहीं है। खाते का प्रकार चुनने के लिए 1, 2 या 3 दबाएँ।';

  @override
  String get authErrorNotRegisteredStudent =>
      'यह फ़ोन नंबर छात्र खाते के रूप में रजिस्टर नहीं है। खाते का प्रकार चुनने के लिए 1, 2 या 3 दबाएँ।';

  @override
  String get authErrorResponseNotVerified =>
      'साइन इन के जवाब की जाँच नहीं हो सकी। कृपया फिर से कोशिश करें।';

  @override
  String authErrorMovedToPhone(String message) {
    return '$message फ़ोन नंबर फ़ील्ड पर पहुँचे।';
  }

  @override
  String authErrorMovedToAccountType(String message) {
    return '$message खाते के प्रकार पर पहुँचे।';
  }

  @override
  String authErrorMovedToPassword(String message) {
    return '$message पासवर्ड फ़ील्ड पर पहुँचे।';
  }

  @override
  String get authRoleAdministrator => 'प्रशासक';

  @override
  String get authRoleTeacher => 'शिक्षक';

  @override
  String get authRoleStudent => 'छात्र';

  @override
  String get authRecoveryStep1 =>
      'अपने स्कूल के प्रशासक से अपना पासवर्ड रीसेट करने को कहें। उन्हें आपसे मिलकर पक्का करना होगा कि आप कौन हैं। सिर्फ़ फ़ोन नंबर या SIM से यह साबित नहीं होता। अपना स्थायी पासवर्ड कभी किसी को न भेजें।';

  @override
  String get authRecoveryStep2 =>
      'प्रशासक आपको 12 अंकों का एक निजी अस्थायी पासवर्ड देंगे। यह 24 घंटे तक काम करता है। इसकी समय-सीमा खत्म हो जाए तो नया माँगें।';

  @override
  String get authRecoveryStep3 =>
      'अपने फ़ोन नंबर और अस्थायी पासवर्ड से साइन इन करें, फिर नया पासवर्ड चुनें।';

  @override
  String get authRecoveryStep4 =>
      '10 बार गलत कोशिश के बाद, साइन इन 15 मिनट के लिए रुक जाता है। पासवर्ड वापस पाने के लिए इंटरनेट चाहिए। दूसरे फ़ोनों पर पहले से मौजूद फ़ाइलें तुरंत नहीं हटतीं।';

  @override
  String get authRecoveryHelpTitle => 'पासवर्ड वापस पाने में मदद';

  @override
  String authRecoveryHelpIntro(String count) {
    return '$count छोटे चरण। हर चरण सुनने के लिए नीचे दबाएँ।';
  }

  @override
  String get authBackToLogin => 'साइन इन पर वापस जाएँ';

  @override
  String get authBackToLoginButton => 'साइन इन पर वापस जाएँ, बटन';

  @override
  String get notesRecordingStarted =>
      'रिकॉर्डिंग शुरू हो गई। पूरा होने पर रिकॉर्डिंग रोकें चुनें।';

  @override
  String get notesActionNotConfirmed =>
      'नोट का यह काम पक्का नहीं हो सका। स्टोरेज, माइक्रोफ़ोन की अनुमति या कनेक्शन जाँचें। आपके ड्राफ़्ट रखे गए हैं।';

  @override
  String get notesNoneYet => 'अभी तक कोई निजी नोट नहीं।';

  @override
  String notesLoaded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count निजी नोट लोड हुए।',
      one: '1 निजी नोट लोड हुआ।',
    );
    return '$_temp0';
  }

  @override
  String get notesNameDialogTitle => 'निजी नोट का नाम दें';

  @override
  String get notesDefaultTitle => 'निजी नोट';

  @override
  String notesDefaultLessonTitle(String lesson) {
    return '$lesson के लिए नोट';
  }

  @override
  String get notesRecordConfirmTitle => 'निजी नोट रिकॉर्ड करें?';

  @override
  String notesRecordConfirmMessage(String lessonPoint) {
    return 'माइक्रोफ़ोन की आवाज़ केवल इसी फ़ोन पर रिकॉर्ड करें, ज़्यादा से ज़्यादा पाँच मिनट या नोट के लिए अलग से बची 10 MB जगह तक। बोलकर चलाने वाले कंट्रोल इस्तेमाल करने से पहले रिकॉर्डिंग रोकें। ऐप की आवाज़, यह स्क्रीन छोड़ने या ऐप में रुकावट आने से रिकॉर्डिंग रुक जाती है। लाइव सत्र की रिकॉर्डिंग पर रोक है। $lessonPoint अपने आप कोई अपलोड या शेयर नहीं होगा। माइक्रोफ़ोन की अनुमति माँगी जा सकती है।';
  }

  @override
  String notesLessonPointSeconds(String seconds) {
    return 'पाठ में जगह: $seconds सेकंड।';
  }

  @override
  String get notesStartRecording => 'रिकॉर्डिंग शुरू करें';

  @override
  String get notesDoNotRecord => 'रिकॉर्ड न करें';

  @override
  String get notesReviewStoppedChanged =>
      'स्क्रीन या ऐप बदलने के कारण सुनना रुक गया। सुनने के लिए यह नोट फिर से खोलें।';

  @override
  String get notesReviewStoppedAccount =>
      'आपका खाता बदलने के कारण सुनना रुक गया। निजी नोट फिर से खोलें।';

  @override
  String get notesRenameDialogTitle => 'निजी नोट का नाम बदलें';

  @override
  String notesRemoveTitle(String title) {
    return '$title हटाएँ?';
  }

  @override
  String notesRemoveMessage(String title) {
    return 'इस फ़ोन पर इस खाते से केवल $title हटाएँ? दूसरे नोट, सीखने की प्रगति और बुकमार्क रखे जाएँगे। अगर यह पहले प्रकाशित हुआ था, तो ऑनलाइन रिकॉर्डिंग और डाउनलोड की गई कॉपियाँ नहीं हटेंगी।';
  }

  @override
  String get notesRemoveSelected => 'चुना गया नोट हटाएँ';

  @override
  String get notesKeepNote => 'नोट रखें';

  @override
  String notesRemoved(String title) {
    return '$title हटा दिया गया। दूसरे नोट और सीखने की प्रगति रखी गई है।';
  }

  @override
  String get notesReviewBeforePublish =>
      'प्रकाशित करने से पहले यह नोट अकेले में चलाकर जाँचें।';

  @override
  String get notesSignInAsTeacher =>
      'प्रकाशित करने से पहले शिक्षक के रूप में साइन इन करें।';

  @override
  String get notesNoWorkspace =>
      'किसी अनुमति वाली कक्षा/विषय की पुष्टि नहीं हुई। आपका ड्राफ़्ट रखा गया है।';

  @override
  String get notesPublishTitle => 'जाँचा हुआ नोट कक्षा में प्रकाशित करें?';

  @override
  String notesPublishMessage(
    String title,
    String className,
    String subjectName,
  ) {
    return 'पक्का करें कि आपने $title जाँच लिया है और इसे $className, $subjectName में प्रकाशित करना चाहते हैं। अनुमति वाले कक्षा सदस्य इसे सुन सकते हैं या 30 दिनों तक ऑफ़लाइन के लिए डाउनलोड कर सकते हैं। इंटरनेट से कटी हुई कॉपियाँ तुरंत वापस नहीं ली जा सकतीं। आपका फ़ोन पर रखा ड्राफ़्ट रहेगा। जिस अपलोड की पुष्टि नहीं हुई, वह शायद पहले ही प्रकाशित हो चुका हो; दोहराव से बचने के लिए फिर से कोशिश करने से पहले लाइब्रेरी जाँचें।';
  }

  @override
  String get notesPublishConfirm => 'चुनी गई कक्षा में प्रकाशित करें';

  @override
  String get notesKeepDraftPrivate => 'ड्राफ़्ट निजी रखें';

  @override
  String get notesSignInChanged => 'साइन इन बदल गया। ड्राफ़्ट नहीं भेजा गया।';

  @override
  String get notesAccountChangedBeforePublish =>
      'प्रकाशन की पुष्टि से पहले आपका खाता बदल गया। फिर से कोशिश करने से पहले पहले वाले शिक्षक की लाइब्रेरी जाँचें।';

  @override
  String get notesPublishNotConfirmed =>
      'प्रकाशन की पुष्टि नहीं हुई। फिर से कोशिश करने से पहले कक्षा की लाइब्रेरी जाँचें; आपका निजी ड्राफ़्ट रखा गया है।';

  @override
  String get notesPublishUnreadable =>
      'प्रकाशन की पुष्टि पढ़ी नहीं जा सकी। फिर से कोशिश करने से पहले लाइब्रेरी जाँचें; आपका ड्राफ़्ट रखा गया है।';

  @override
  String get notesPublishIdentityMismatch =>
      'प्रकाशन की पहचान मेल नहीं खाई। फिर से कोशिश करने से पहले लाइब्रेरी जाँचें; आपका ड्राफ़्ट रखा गया है।';

  @override
  String notesPublished(String audioId) {
    return 'रिकॉर्डिंग $audioId के रूप में प्रकाशित हुआ। आपका फ़ोन पर रखा ड्राफ़्ट रखा गया है। जब तक आप दूसरी रिकॉर्डिंग नहीं चाहते, फिर से प्रकाशित न करें।';
  }

  @override
  String get notesStopBeforeLeaving =>
      'रिकॉर्डिंग रुकने की पुष्टि नहीं हुई। जाने से पहले फिर से रोकें या ऐप को बैकग्राउंड में भेजें।';

  @override
  String get notesRules =>
      'निजी नोट के नियम। हर नोट पाँच मिनट तक का हो सकता है। नोट के लिए हर खाते में अलग से 10 मेगाबाइट जगह मिलती है। रिकॉर्डिंग तभी शुरू होती है जब आप पुष्टि करते हैं, और लाइव सत्र के अंदर कभी नहीं। ऐप की आवाज़, यह स्क्रीन छोड़ने या किसी रुकावट से रिकॉर्डिंग रुक जाती है, इसलिए बोलकर चलने वाले नियंत्रण इस्तेमाल करने से पहले रिकॉर्डिंग रोकें। छात्र के नोट इसी फ़ोन पर निजी रहते हैं। शिक्षक के ड्राफ़्ट प्रकाशित करने से पहले जाँचने और पुष्टि करने होते हैं। लॉग आउट करने के बाद भी नोट रखे रहते हैं।';

  @override
  String notesRecordingFor(String duration) {
    return '$duration से रिकॉर्डिंग हो रही है।';
  }

  @override
  String notesUsage(String megabytes) {
    return '10 MB निजी नोट में से $megabytes इस्तेमाल हुए।';
  }

  @override
  String authRecoveryStepListItem(String number, String step) {
    return '$number. $step';
  }

  @override
  String get authBackToLoginKey => '0: साइन इन पर वापस जाएँ';

  @override
  String get authRoleRowSelected => 'चुना गया';

  @override
  String get authLoginScreenName => 'साइन इन स्क्रीन';

  @override
  String get authLoginNavigationSections =>
      'फ़ोन नंबर, पासवर्ड, खाते का प्रकार, साइन इन, रजिस्ट्रेशन, SIM सुझाव और पासवर्ड वापस पाने में मदद';

  @override
  String get authLoginKeySimLabel => 'वैकल्पिक SIM फ़ोन नंबर सुझाव पढ़ें';

  @override
  String get authLoginKeyRecoveryLabel =>
      'स्कूल प्रशासक से पासवर्ड वापस पाने में मदद';

  @override
  String get authPhoneNumberField => 'फ़ोन नंबर फ़ील्ड';

  @override
  String get authPasswordField => 'पासवर्ड फ़ील्ड';

  @override
  String get authHidePassword => 'पासवर्ड छिपाएँ';

  @override
  String get authShowPassword => 'पासवर्ड दिखाएँ';

  @override
  String authRoleFieldNavLabel(String role) {
    return 'खाते का प्रकार: $role, चुना गया। बदलने के लिए 1, 2 या 3 दबाएँ, या बाएँ और दाएँ का उपयोग करें';
  }

  @override
  String authLoginAsButton(String role) {
    return '$role के रूप में साइन इन करें, बटन';
  }

  @override
  String get authRegisterNewAccountButton => 'नया खाता रजिस्टर करें, बटन';

  @override
  String get authSimSuggestionsTargetLabel =>
      'वैकल्पिक SIM फ़ोन नंबर सुझाव पढ़ें। नंबर खुद डालना हमेशा काम करता है।';

  @override
  String get authForgotPasswordTargetLabel =>
      'पासवर्ड भूल गए? स्कूल प्रशासक से पासवर्ड वापस पाने में मदद';

  @override
  String get authWelcomeBack => 'फिर से स्वागत है';

  @override
  String get authRegisteredBanner => 'रजिस्टर हो गया। अब साइन इन करें।';

  @override
  String get authPhoneNumber => 'फ़ोन नंबर';

  @override
  String get authPassword => 'पासवर्ड';

  @override
  String get authAccountType => 'खाते का प्रकार';

  @override
  String authRoleFieldValue(String role) {
    return '$role, चुना गया। बदलने के लिए 1, 2 या 3 दबाएँ';
  }

  @override
  String get authRoleOptionStudent => '1 छात्र';

  @override
  String get authRoleOptionTeacher => '2 शिक्षक';

  @override
  String get authRoleOptionAdmin => '3 प्रशासक';

  @override
  String get authSigningIn => 'साइन इन हो रहा है, कृपया प्रतीक्षा करें';

  @override
  String authLoginAsKey(String role) {
    return '4: $role के रूप में साइन इन करें';
  }

  @override
  String get authNoAccountRegisterKey => '5: खाता नहीं है? रजिस्टर करें';

  @override
  String get authReadSimSuggestionsKey => '6: वैकल्पिक SIM सुझाव पढ़ें';

  @override
  String get authForgotPasswordKey => '7: पासवर्ड भूल गए? वापस पाने में मदद';

  @override
  String authErrorMovedToName(String message) {
    return '$message नाम फ़ील्ड पर पहुँचे।';
  }

  @override
  String get authErrorEnterName => 'अपना नाम डालें।';

  @override
  String get authErrorEnterAPassword => 'एक पासवर्ड डालें।';

  @override
  String get authRegisteringAsTeacher => 'शिक्षक के रूप में रजिस्टर कर रहे हैं';

  @override
  String get authRegisteringAsStudent => 'छात्र के रूप में रजिस्टर कर रहे हैं';

  @override
  String get authRegistrationScreenName => 'रजिस्ट्रेशन स्क्रीन';

  @override
  String get authRegisterNavigationSections =>
      'नाम, फ़ोन नंबर, पासवर्ड, छात्र या शिक्षक खाते का प्रकार, रजिस्टर, और साइन इन';

  @override
  String get authNameField => 'नाम फ़ील्ड';

  @override
  String get authRegisterRoleTeacherLabel =>
      'खाते का प्रकार: शिक्षक। छात्र में बदलने के लिए ओके या 3 दबाएँ';

  @override
  String get authRegisterRoleStudentLabel =>
      'खाते का प्रकार: छात्र। शिक्षक में बदलने के लिए ओके या 3 दबाएँ';

  @override
  String get authRegisterAsTeacherButton =>
      'शिक्षक के रूप में रजिस्टर करें, बटन';

  @override
  String get authRegisterAsStudentButton =>
      'छात्र के रूप में रजिस्टर करें, बटन';

  @override
  String get authGoToLoginLabel => 'पहले से खाता है? साइन इन पर जाएँ';

  @override
  String get authRegisterTitle => 'रजिस्टर करें';

  @override
  String get authName => 'नाम';

  @override
  String get authRegisterAsTeacherKey =>
      '3: शिक्षक के रूप में रजिस्टर करें। खाते का प्रकार बदलें';

  @override
  String get authRegisterAsStudentKey =>
      '3: छात्र के रूप में रजिस्टर करें। खाते का प्रकार बदलें';

  @override
  String get authRegisteringPleaseWait =>
      'रजिस्टर हो रहा है, कृपया प्रतीक्षा करें';

  @override
  String get authRegisterKey => '1: रजिस्टर करें';

  @override
  String get authHaveAccountLoginKey => '2: पहले से खाता है? साइन इन करें';

  @override
  String get authChangePasswordBusy =>
      'सेव हो रहा है। पासवर्ड बदलने की पुष्टि का इंतज़ार है।';

  @override
  String get authChangePasswordErrorEnterTemporary =>
      'अपना अस्थायी कोड डालें। उस फ़ील्ड पर पहुँचे।';

  @override
  String get authChangePasswordErrorTooShort =>
      'कम से कम 6 अक्षरों का नया पासवर्ड डालें। नया पासवर्ड फ़ील्ड पर पहुँचे।';

  @override
  String get authChangePasswordErrorMismatch =>
      'दोनों नए पासवर्ड एक जैसे नहीं हैं। नया पासवर्ड दोबारा डालें फ़ील्ड पर पहुँचे।';

  @override
  String get authChangePasswordErrorSameAsTemporary =>
      'अस्थायी कोड से अलग पासवर्ड चुनें। नया पासवर्ड फ़ील्ड पर पहुँचे।';

  @override
  String get authChangePasswordSessionInactive =>
      'पासवर्ड वापस पाने का यह सत्र अब चालू नहीं है। फिर से साइन इन करें।';

  @override
  String get authChangePasswordAccountChanged =>
      'आपका खाता बदल गया। कोई नया साइन इन सेव नहीं हुआ।';

  @override
  String authChangePasswordNotConfirmed(String message) {
    return '$message पासवर्ड बदलने की पुष्टि नहीं हुई। अगर कनेक्शन टूट गया था, तो दोबारा रीसेट माँगने से पहले अपने नए पासवर्ड से साइन इन करके देखें।';
  }

  @override
  String get authChangePasswordResponseNotVerified =>
      'पासवर्ड बदलने के जवाब की जाँच नहीं हो सकी। अपने नए पासवर्ड से फिर से साइन इन करके देखें।';

  @override
  String get authChangePasswordReplacementNotVerified =>
      'नए साइन इन की जाँच नहीं हो सकी। अपने नए पासवर्ड से फिर से साइन इन करें।';

  @override
  String get authChangePasswordSignInNotSaved =>
      'आपका साइन इन सेव नहीं हो सका। अपने नए पासवर्ड से फिर से साइन इन करें।';

  @override
  String get authChangePasswordSignInNotSavedOnPhone =>
      'आपका साइन इन इस फ़ोन पर सेव नहीं हो सका। अपने नए पासवर्ड से फिर से साइन इन करें।';

  @override
  String get authTemporaryCredential => 'अस्थायी कोड';

  @override
  String get authNewPassword => 'नया पासवर्ड';

  @override
  String get authRepeatNewPassword => 'नया पासवर्ड दोबारा डालें';

  @override
  String get authChangePasswordScreenName => 'अस्थायी पासवर्ड बदलें';

  @override
  String get authChangePasswordIntro =>
      'अपने प्रशासक से मिला अस्थायी कोड डालें, फिर कम से कम 6 अक्षरों का नया पासवर्ड दो बार डालें। इंटरनेट ज़रूरी है। नए पासवर्ड की पुष्टि होने के बाद डैशबोर्ड खुलेगा।';

  @override
  String get authSaveNewPassword => 'नया पासवर्ड सेव करें';

  @override
  String get authSignOut => 'साइन आउट करें';

  @override
  String get authTemporaryCredentialField => 'अस्थायी कोड। छिपा हुआ इनपुट।';

  @override
  String get authNewPasswordField =>
      'नया पासवर्ड। कम से कम 6 अक्षर। छिपा हुआ इनपुट।';

  @override
  String get authRepeatNewPasswordField =>
      'नया पासवर्ड दोबारा डालें। छिपा हुआ इनपुट।';

  @override
  String get authSaveNewPasswordButton => 'नया पासवर्ड सेव करें, बटन';

  @override
  String get authSignOutConfirmButton => 'साइन आउट करें, पुष्टि पूछेगा';

  @override
  String get authChangePasswordTitle => 'पासवर्ड बदलें';

  @override
  String get authChangePasswordInfo =>
      'आपके स्कूल प्रशासक ने एक अस्थायी कोड दिया है। यह 24 घंटे चलता है। 10 गलत प्रयासों के बाद, साइन इन 15 मिनट के लिए रुक जाता है। कम से कम 6 अक्षरों का एक अलग पासवर्ड चुनें। इसके लिए इंटरनेट ज़रूरी है।';

  @override
  String get authSignOutKey => '0: साइन आउट करें';

  @override
  String authSimOptionValid(String label, String digits) {
    return '$label। फ़ोन नंबर $digits। फ़ोन फ़ील्ड भरने के लिए ओके दबाएँ।';
  }

  @override
  String authSimOptionInvalid(String label) {
    return '$label। नंबर उपलब्ध नहीं है। फ़ोन नंबर खुद डालें।';
  }

  @override
  String get authSimInvalidSuggestion =>
      'यह SIM सही फ़ोन नंबर सुझाव नहीं देता। नंबर खुद डालना अब भी काम करता है।';

  @override
  String get authSimChooseScreenName =>
      'एक वैकल्पिक SIM सुझाव चुनें। हर SIM सुनने के लिए ऊपर और नीचे का उपयोग करें, फिर चुनने के लिए ओके दबाएँ। यह खाते की जाँच नहीं है।';

  @override
  String get authSimCancelLabel => 'फ़ोन नंबर बदले बिना रद्द करें';

  @override
  String get authSimChooseTitle => 'SIM सुझाव चुनें';

  @override
  String get authSimChooseInfo =>
      'चुनने से सिर्फ़ फ़ोन फ़ील्ड भरता है। आपका पासवर्ड फिर भी ज़रूरी है। रद्द करने पर खुद डाला गया नंबर नहीं बदलता।';

  @override
  String get authSimCancelKey => '0: रद्द करें';

  @override
  String get inviteStatusInvited => 'आमंत्रित';

  @override
  String get inviteStatusNotInvited =>
      'आमंत्रित नहीं। आमंत्रित करने के लिए ओके';

  @override
  String get inviteTitle => 'छात्रों को आमंत्रित करें';

  @override
  String get inviteTooltipBack => '0: सत्र पर वापस जाएँ';

  @override
  String get inviteTooltipRefresh => '1: छात्र सूची रीफ़्रेश करें';

  @override
  String get inviteInvitingTo => 'इसमें छात्रों को आमंत्रित कर रहे हैं:';

  @override
  String inviteInvitedCount(String invited, String total) {
    return '$total में से $invited आमंत्रित';
  }

  @override
  String get inviteAllButton => '2: सभी छात्रों को आमंत्रित करें';

  @override
  String get inviteSearchField => 'नाम या फ़ोन नंबर से खोजें';

  @override
  String get inviteSearchHelper => 'हर छात्र की सूची देखने के लिए खाली छोड़ें';

  @override
  String get inviteLoadingStudents => 'छात्र लोड हो रहे हैं';

  @override
  String get inviteNoMatchShort =>
      'कोई छात्र नहीं मिला। सबकी सूची देखने के लिए खोज मिटाएँ।';

  @override
  String get libraryUploadTitleField => 'शीर्षक *';

  @override
  String get libraryUploadDescriptionField => 'विवरण';

  @override
  String get libraryCancelKey0Button => 'रद्द करें (0)';

  @override
  String get libraryUploadKey3Button => 'अपलोड करें (3)';

  @override
  String get libraryConfirmKey1Button => 'पुष्टि करें (1)';

  @override
  String librarySessionNumber(String id) {
    return 'सत्र #$id';
  }

  @override
  String get libraryKey5PauseForClass => '5: कक्षा के लिए रोकें';

  @override
  String get libraryKey5PlayForClass => '5: कक्षा के लिए चलाएँ';

  @override
  String get libraryRecordingsSeekKeysHint =>
      '4: 10 सेकंड पीछे। 6: 10 सेकंड आगे।';

  @override
  String get libraryKey1ChooseRecording => '1: रिकॉर्डिंग चुनें';

  @override
  String get libraryUploadingButton => 'अपलोड हो रहा है';

  @override
  String get libraryKey2Upload => '2: अपलोड करें';

  @override
  String get libraryRecordingsFooterKeysHint =>
      '3: स्थिति। *: मदद। #: आवाज़ रोकें।';

  @override
  String get notesBackStopsRecording => 'वापस। पहले कोई भी रिकॉर्डिंग रोकता है';

  @override
  String get notesReadRules => 'नोट के नियम सुनें';

  @override
  String get notesRefreshPrivate => 'निजी नोट रीफ़्रेश करें';

  @override
  String get notesRecordAsksFirst =>
      'निजी नोट रिकॉर्ड करें। पहले नाम और पुष्टि पूछी जाती है';

  @override
  String get notesStopRecordingNow => 'अभी रिकॉर्डिंग रोकें';

  @override
  String get notesReadRecordingTimeStops =>
      'रिकॉर्डिंग का समय सुनें। बोलकर पढ़ने से रिकॉर्डिंग रुक जाती है';

  @override
  String get notesReadPrivateStatus => 'निजी नोट की स्थिति सुनें';

  @override
  String get notesStopPrivateReview => 'निजी रूप से सुनना बंद करें';

  @override
  String notesStopReviewingTitle(String title) {
    return '$title सुनना बंद करें';
  }

  @override
  String get notesStopReviewingNote => 'नोट सुनना बंद करें';

  @override
  String notesReviewTitlePrivately(String title, String duration) {
    return '$title को निजी रूप से सुनें। $duration।';
  }

  @override
  String notesReviewTitleIncomplete(String title) {
    return '$title को निजी रूप से सुनें। अधूरी रिकॉर्डिंग; चल नहीं सकती।';
  }

  @override
  String notesRenameTitle(String title) {
    return '$title का नाम बदलें';
  }

  @override
  String notesPublishTitleAsks(String title) {
    return 'जाँचा गया $title किसी कक्षा और विषय में प्रकाशित करें, पुष्टि पूछी जाती है';
  }

  @override
  String notesRemoveTitleAsks(String title) {
    return '$title हटाएँ, पुष्टि पूछी जाती है';
  }

  @override
  String get notesScreenName => 'निजी नोट';

  @override
  String get notesIntroduction =>
      'नोट कैसे रखे जाते हैं, यह सुनने के लिए नोट के नियम सुनें इस्तेमाल करें।';

  @override
  String get notesBack => 'वापस';

  @override
  String notesStorageSummary(String megabytes) {
    return '$megabytes / 10 MB निजी नोट। पाठ के डाउनलोड से अलग। अपने आप कुछ नहीं मिटता।';
  }

  @override
  String notesLessonContext(String title, String seconds) {
    return '$title। पाठ में सहेजी गई जगह: $seconds सेकंड।';
  }

  @override
  String notesRecordingTime(String time) {
    return 'रिकॉर्डिंग का समय $time';
  }

  @override
  String get notesRefreshNotes => 'नोट रीफ़्रेश करें';

  @override
  String get notesRecordPrivateNote => 'निजी नोट रिकॉर्ड करें';

  @override
  String get notesStopRecording => 'रिकॉर्डिंग रोकें';

  @override
  String get notesReadRecordingTime => 'रिकॉर्डिंग का समय सुनें';

  @override
  String get notesReadNoteStatus => 'नोट की स्थिति सुनें';

  @override
  String get notesStatusNeedsAttention => 'ध्यान देने की ज़रूरत';

  @override
  String get notesStatusIncomplete => 'अधूरा';

  @override
  String get notesStatusPlaying => 'चल रहा है';

  @override
  String get notesStatusReviewed => 'जाँचा गया';

  @override
  String get notesStatusSaved => 'सहेजा गया';

  @override
  String notesNoteSeconds(String seconds) {
    return '$seconds सेकंड। फ़ोन पर रखा निजी नोट।';
  }

  @override
  String get notesNoteIncomplete =>
      'रुका हुआ या अधूरा नोट। चल या प्रकाशित नहीं हो सकता।';

  @override
  String notesNoteLessonPoint(String lesson, String seconds) {
    return 'पाठ $lesson, जगह $seconds सेकंड।';
  }

  @override
  String get notesReviewPlaying => 'सुनना जारी है';

  @override
  String get notesReviewPrivately => 'निजी रूप से सुनें';

  @override
  String get notesRename => 'नाम बदलें';

  @override
  String get notesPublishReviewedNote => 'जाँचा गया नोट प्रकाशित करें';

  @override
  String get notesEnterNameBeforeSaving => 'सहेजने से पहले नाम लिखें।';

  @override
  String notesNameDialogInstructions(String title) {
    return '$title। ओके से लिखना शुरू होता है। ऊपर या नीचे से लिखना बंद होता है, फिर सहेजें या रद्द करें चुनें।';
  }

  @override
  String get notesNoteName => 'नोट का नाम';

  @override
  String get notesSaveNoteName => 'नोट का नाम सहेजें';

  @override
  String get notesCancel => 'रद्द करें';

  @override
  String get notesSaveName => 'नाम सहेजें';

  @override
  String notesWorkspaceLabel(String className, String subjectName) {
    return '$className, $subjectName';
  }

  @override
  String get notesChooseWorkspaceInstructions =>
      'प्रकाशित करने से पहले अनुमति वाली कक्षा और विषय चुनें। अगली पुष्टि तक कुछ भी अपलोड नहीं होगा।';

  @override
  String get notesCancelPublication => 'प्रकाशन रद्द करें';

  @override
  String get notesPublishWhichWorkspace =>
      'किस कक्षा और विषय में प्रकाशित करें?';

  @override
  String settingsDecrease(String setting) {
    return '$setting घटाएँ';
  }

  @override
  String settingsIncrease(String setting) {
    return '$setting बढ़ाएँ';
  }

  @override
  String get settingsResetTooltip => 'डिफ़ॉल्ट पर रीसेट करें';

  @override
  String get settingsSectionSpeech => 'आवाज़';

  @override
  String get settingsAppSpeechTitle => 'ऐप की आवाज़';

  @override
  String get settingsAppSpeechSubtitle => 'ऐप स्क्रीन और संदेश पढ़कर सुनाता है';

  @override
  String settingsLanguageButton(String language) {
    return 'बोलने की भाषा: $language';
  }

  @override
  String get settingsVolumeTitle => 'वॉल्यूम';

  @override
  String get settingsVolumeSubtitle => 'ऐप की आवाज़ कितनी तेज़ है';

  @override
  String settingsPercentValue(String percent) {
    return '$percent प्रतिशत';
  }

  @override
  String get settingsSpeedTitle => 'बोलने की गति';

  @override
  String get settingsSpeedSubtitle =>
      'ऐप कितनी तेज़ी से बोलता है। क्विज़ अपनी अलग गति रख सकते हैं';

  @override
  String settingsTimesNormal(String speed) {
    return 'सामान्य से $speed गुना';
  }

  @override
  String get settingsTestButton => '5: आवाज़ जाँचें';

  @override
  String settingsNarrationButton(String level) {
    return 'बोलने का स्तर: $level';
  }

  @override
  String settingsCheckingVoice(String language) {
    return '$language आवाज़ जाँची जा रही है...';
  }

  @override
  String settingsCheckVoiceButton(String language) {
    return '7: $language आवाज़ जाँचें';
  }

  @override
  String get settingsStopButton => '#: आवाज़ रोकें';

  @override
  String get settingsSectionDisplay => 'डिस्प्ले';

  @override
  String get settingsHighContrastTitle => 'हाई कंट्रास्ट';

  @override
  String get settingsHighContrastSubtitle =>
      'शुरू से चालू: कम दृष्टि के लिए काले पर सफ़ेद और पीला';

  @override
  String get settingsTextSizeTitle => 'टेक्स्ट का आकार';

  @override
  String get settingsTextSizeSubtitle =>
      'ऐप के टेक्स्ट का आकार; फ़ोन की फ़ॉन्ट सेटिंग भी मानी जाती है';

  @override
  String get settingsSectionKeys => 'बटन और मदद';

  @override
  String get settingsShortcutsTitle => 'कीपैड शॉर्टकट दिखाएँ';

  @override
  String get settingsShortcutsSubtitle => 'बटनों पर कीपैड के नंबर दिखाएँ';

  @override
  String get settingsGlobalKeysHint =>
      'हर स्क्रीन पर: 0 वापस, स्टार मदद, हैश आवाज़ रोकें।';

  @override
  String get settingsVoiceCommandsTitle => 'आवाज़ से आदेश';

  @override
  String get settingsVoiceCommandsSubtitle =>
      'सत्रों में आदेश सुनने का विकल्प चालू करें। अपने आप नहीं सुनता।';

  @override
  String get settingsSoundCuesTitle => '8: ध्वनि संकेत';

  @override
  String get settingsVibrationTitle => '9: कंपन';

  @override
  String get settingsVoiceHelpButton =>
      'आवाज़ आदेश की मदद: म्यूट, अनम्यूट, हाथ उठाएँ, हाथ नीचे करें, बाहर निकलें या दोहराएँ बोलें।';

  @override
  String get uiSave => 'सेव करें';

  @override
  String get uiClose => 'बंद करें';

  @override
  String get learningLessonPositionLabel => 'पाठ में जगह';

  @override
  String get learningReadStatusButton => 'सीखने की स्थिति सुनें';

  @override
  String get learningAddBookmarkButton => 'बुकमार्क जोड़ें';

  @override
  String learningBookmarksButton(String count) {
    return 'बुकमार्क ($count)';
  }

  @override
  String get learningPrivateNotesButton => 'पढ़ाई के निजी नोट';

  @override
  String get learningSetAButton => 'A तय करें';

  @override
  String learningSetAAtButton(String time) {
    return 'A तय करें $time';
  }

  @override
  String get learningSetBButton => 'B तय करें';

  @override
  String learningSetBAtButton(String time) {
    return 'B तय करें $time';
  }

  @override
  String get learningRepeatOffButton => 'दोहराना बंद';

  @override
  String get learningRepeatOnButton => 'दोहराना चालू';

  @override
  String get learningClearABButton => 'A-B हटाएँ';

  @override
  String learningBackTenButton(String key) {
    return '$key: 10 सेकंड पीछे';
  }

  @override
  String learningForwardTenButton(String key) {
    return '$key: 10 सेकंड आगे';
  }

  @override
  String learningSlowerButton(String key) {
    return '$key: धीमा';
  }

  @override
  String learningFasterButton(String key) {
    return '$key: तेज़';
  }

  @override
  String get learningRetrySavingButton => 'फिर से सहेजें';

  @override
  String get learningNameBookmarkTitle => 'बुकमार्क का नाम';

  @override
  String get learningBookmarkNameFieldLabel => 'नाम';

  @override
  String get learningBookmarksTitle => 'बुकमार्क';

  @override
  String get learningBookmarksLessonChanged =>
      'पाठ बदल गया है। यह सूची बंद करें और मौजूदा पाठ के बुकमार्क खोलें।';

  @override
  String get learningBookmarksEmpty =>
      'अभी कोई बुकमार्क नहीं है। जो जगह याद रखनी हो, वहाँ बुकमार्क जोड़ें इस्तेमाल करें।';

  @override
  String get learningBookmarksUnavailable =>
      'सहेजे गए बुकमार्क उपलब्ध नहीं हैं। सहेजी गई प्रगति वापस पाने के लिए फिर से सहेजें।';

  @override
  String learningBookmarkAtButton(String label, String time) {
    return '$time पर $label';
  }

  @override
  String learningRemoveBookmarkSemantics(String label) {
    return 'बुकमार्क $label हटाएँ';
  }

  @override
  String uiKeyedLabel(String key, String label) {
    return '$key: $label';
  }

  @override
  String get uiKeypadFooter => '*: मदद। #: ऐप की आवाज़ रोकें।';

  @override
  String uiListSearchValue(String query) {
    return 'खोज: $query';
  }

  @override
  String get uiListLoadingShort => 'लोड हो रहा है। वापस जाने के लिए 0 दबाएँ।';

  @override
  String get keypadTextEditingHint =>
      'लिखते समय बटन से टेक्स्ट लिखा जाता है। खत्म करने के लिए ओके दबाएँ। अगर ओके से लिखना खत्म न हो, तो ऊपर या नीचे इस्तेमाल करें।';

  @override
  String get keypadWaitingConfirmation => 'पुष्टि का इंतज़ार है।';

  @override
  String get keypadContinueKey1 => '1: आगे बढ़ें';

  @override
  String get keypadHidePasswordKey2 => '2: पासवर्ड छिपाएँ';

  @override
  String get keypadShowPasswordKey2 => '2: पासवर्ड दिखाएँ';

  @override
  String get keypadBackKey0 => '0: वापस';

  @override
  String uiKeyedLabelUnavailable(String number, String label) {
    return '$number: $label (उपलब्ध नहीं)';
  }

  @override
  String get journeyMenuReadDetailsKey8 => '8: विवरण फिर से सुनें';

  @override
  String get sessionTileHandRaised => 'हाथ उठाया है';

  @override
  String get sessionTileSpeaking => 'बोल रहे हैं';

  @override
  String sessionRemoveFromSession(String name) {
    return '$name को सत्र से हटाएँ';
  }

  @override
  String get classroomConsoleTitle => 'कक्षा कंसोल';

  @override
  String get uiHourRange => 'घंटा (0 से 23)';

  @override
  String get uiSetDateTimeTitle => 'तारीख और समय सेट करें';

  @override
  String get uiSetDateTimeHint =>
      'स्थानीय समय इस्तेमाल करें। हर संख्या बदलने के लिए ओके दबाएँ।';

  @override
  String quizExtraTitle(String name) {
    return 'अतिरिक्त समय: $name';
  }

  @override
  String get quizExtraInfo =>
      'सिर्फ़ आगे के प्रयासों के लिए। मौजूदा समय-सीमाएँ नहीं बदलतीं। क्विज़ बंद होने का समय फिर भी लागू रहेगा; ज़रूरत हो तो उपलब्धता अलग से बढ़ाएँ। शून्य डालने से अतिरिक्त मिनट हट जाते हैं।';

  @override
  String get quizExtraMinutesField => 'अतिरिक्त मिनट';

  @override
  String get quizExtraSaveButton => 'आगे के लिए अतिरिक्त समय सहेजें';

  @override
  String quizSpeedValue(String speed) {
    return 'क्विज़ की आवाज़ की गति: $speed×';
  }

  @override
  String get uiCancelKey0 => '0: रद्द करें';

  @override
  String get uiSaveKey1 => '1: सेव करें';

  @override
  String get uiNone => 'कोई नहीं';

  @override
  String uiPreviousOf(String label) {
    return 'पिछला $label';
  }

  @override
  String uiNextOf(String label) {
    return 'अगला $label';
  }

  @override
  String get journeyOpening => 'यात्रा खुल रही है';

  @override
  String journeyStepHeading(String position, String kind) {
    return '$position। $kind';
  }

  @override
  String journeyStepHeadingReplay(String position, String kind) {
    return '$position। $kind। फिर से सुन रहे हैं';
  }

  @override
  String journeyFirstTryShort(String correct, String total) {
    return 'पहली कोशिश में $total में से $correct सही।';
  }

  @override
  String get journeyLeaveKey0 => '0: यात्रा छोड़ें';

  @override
  String get quizRevisionsTitle => 'प्रश्न के संशोधन';

  @override
  String get quizRevisionsBackTooltip => 'प्रश्न के संशोधन से वापस जाएँ';

  @override
  String quizRevisionSectionHear(String section) {
    return '$section। सुनने के लिए दो बार टैप करें';
  }

  @override
  String get adminResetAttested => 'पहचान की जाँच की पुष्टि की गई।';

  @override
  String get adminResetNotAttested => 'पहचान की जाँच की पुष्टि नहीं की गई।';

  @override
  String get adminResetConfirmTitle => 'यह पासवर्ड रीसेट करें?';

  @override
  String adminResetConfirmMessage(String name, String phone) {
    return '$name, फ़ोन $phone को रीसेट करें? इससे पुराना पासवर्ड बदल जाएगा और ऑनलाइन सत्र खत्म हो जाएँगे। इंटरनेट से कटे फ़ोन पर डाउनलोड किए गए पाठ तुरंत वापस नहीं लिए जा सकते। मौजूदा पाठ, नोट और सीखने के रिकॉर्ड रखे रहेंगे। 12 अंकों का अस्थायी कोड 24 घंटे चलता है और इसके बाद पासवर्ड बदलना ज़रूरी है। 10 गलत प्रयासों के बाद, अस्थायी कोड से साइन इन 15 मिनट के लिए रुक जाता है।';
  }

  @override
  String get adminResetKeepPassword => 'पासवर्ड रहने दें';

  @override
  String get adminResetResetPassword => 'पासवर्ड रीसेट करें';

  @override
  String get adminResetSignInChanged =>
      'प्रशासक का साइन इन बदल गया। कोई रीसेट नहीं भेजा गया।';

  @override
  String get adminResetSending =>
      'रीसेट भेजा जा रहा है। सर्वर की पुष्टि का इंतज़ार है।';

  @override
  String adminResetNotConfirmed(String reason) {
    return 'रीसेट की पुष्टि नहीं हुई। $reason हो सकता है यह पहले ही लागू हो गया हो। दूसरा रीसेट सोचने से पहले बंद करें और यह खाता रीफ़्रेश करें।';
  }

  @override
  String get adminResetResponseNotVerified =>
      'रीसेट के जवाब की जाँच नहीं हो सकी। हो सकता है पासवर्ड पहले ही बदल गया हो। दूसरा रीसेट सोचने से पहले बंद करें और रीफ़्रेश करें।';

  @override
  String get adminResetConfirmedSpoken =>
      'पासवर्ड रीसेट की पुष्टि हो गई। कोड छिपा हुआ है। कोड सुनें तभी इस्तेमाल करें जब कोई और न सुन रहा हो। बंद करने पर यह कॉपी मिट जाएगी।';

  @override
  String get adminResetPhoneNotConfirmed =>
      'इस फ़ोन पर रीसेट की पुष्टि नहीं हो सकी। दूसरा रीसेट सोचने से पहले बंद करें और खाता रीफ़्रेश करें।';

  @override
  String get adminResetStorageUnavailable =>
      'खाते का स्टोरेज उपलब्ध नहीं है। रीसेट सोचने से पहले रिकवरी बंद करें और SEEDS फिर से शुरू करें।';

  @override
  String adminResetCredentialSpoken(String digits, String expires) {
    return 'अस्थायी कोड: $digits। समाप्ति $expires, UTC। इसे जाँचे गए व्यक्ति को निजी रूप से दें। साइन इन पर इसे बदलना ज़रूरी है।';
  }

  @override
  String get adminResetDiscardTitle => 'कोड की यह कॉपी मिटाएँ?';

  @override
  String get adminResetDiscardMessage =>
      'पुष्टि करें कि आपने अस्थायी कोड निजी रूप से दे दिया है, या मान लें कि किसी जाँचे गए प्रशासक को फिर से रीसेट करना होगा। SEEDS यह कॉपी दोबारा नहीं दिखाएगा। इससे पूरा हो चुका रीसेट रद्द नहीं होता।';

  @override
  String get adminResetKeepReviewing => 'देखना जारी रखें';

  @override
  String get adminResetCloseDiscard => 'बंद करें और मिटाएँ';

  @override
  String get adminResetScreenName =>
      'प्रशासक पासवर्ड रिकवरी। रीसेट करने से पहले SEEDS के बाहर पहचान की जाँच करें। साफ़ तौर पर माँगे जाने तक कोड छिपे रहते हैं।';

  @override
  String get adminResetCloseRecovery => 'रिकवरी बंद करें';

  @override
  String get adminResetReadAccount => 'चुने गए खाते का विवरण सुनें';

  @override
  String adminResetAccountDetails(String name, String phone) {
    return '$name। फ़ोन $phone।';
  }

  @override
  String get adminResetIdentityChecked =>
      'SEEDS के बाहर पहचान की जाँच हुई। चुना गया। बदलने के लिए ओके दबाएँ।';

  @override
  String get adminResetIdentityNotChecked =>
      'SEEDS के बाहर पहचान की जाँच हुई। नहीं चुना गया। बदलने के लिए ओके दबाएँ।';

  @override
  String get adminResetResetAndEnd =>
      'पासवर्ड रीसेट करें और ऑनलाइन सत्र खत्म करें';

  @override
  String get adminResetReadCredentialLabel =>
      'अस्थायी कोड सुनें और दिखाएँ। सिर्फ़ निजी रूप से इस्तेमाल करें।';

  @override
  String get adminResetCloseRefresh => 'बंद करें और खाता रीफ़्रेश करें';

  @override
  String get adminResetTitle => 'पासवर्ड रिकवरी';

  @override
  String get adminResetVerifyInfo =>
      'SEEDS के बाहर व्यक्ति की जाँच करें। फ़ोन नंबर या SIM का सुझाव पहचान की जाँच नहीं है। सिर्फ़ किसी संदेश या बताए गए नाम के आधार पर कभी रीसेट न करें।';

  @override
  String get adminResetVerifiedCheckbox =>
      'मैंने SEEDS के बाहर इस व्यक्ति की जाँच की है';

  @override
  String get adminResetWaiting => 'रीसेट की पुष्टि का इंतज़ार है।';

  @override
  String get adminResetConfirmedInfo =>
      'रीसेट की पुष्टि हो गई। माँगे जाने तक कोड छिपा है। यह 24 घंटे तक मान्य है। बंद करने पर यह कॉपी मिट जाएगी। निजी रूप से दें; इसे कभी किसी कक्षा में न डालें।';

  @override
  String get adminResetRevealButton => 'कोड निजी रूप से सुनें और दिखाएँ';

  @override
  String adminResetCredentialShown(String digits, String expires) {
    return 'अस्थायी कोड: $digits\nसमाप्ति: $expires UTC';
  }

  @override
  String get adminResetCloseRefreshKey0 => '0: बंद करें और खाता रीफ़्रेश करें';

  @override
  String get apiTemporarySignInPaused =>
      'अस्थायी कोड से साइन इन 15 मिनट के लिए रुका हुआ है। बाद में कोशिश करें या अपने स्कूल के प्रशासक से संपर्क करें।';

  @override
  String get apiTemporaryCredentialExpired =>
      'आपका अस्थायी कोड समाप्त हो गया। नए कोड के लिए अपने स्कूल के प्रशासक से संपर्क करें।';

  @override
  String get apiPasswordMustDiffer => 'अस्थायी कोड से अलग पासवर्ड चुनें।';

  @override
  String get apiTemporaryCredentialRejected =>
      'अस्थायी कोड स्वीकार नहीं हुआ। इसे जाँचें और फिर से कोशिश करें।';

  @override
  String get apiRecoverySignInExpired =>
      'आपका रिकवरी साइन इन समाप्त हो गया या बदल गया। फिर से साइन इन करें।';

  @override
  String get apiCheckInformation =>
      'कृपया जानकारी जाँचें और फिर से कोशिश करें।';

  @override
  String get apiInvalidLogin => 'फ़ोन नंबर या पासवर्ड गलत है।';

  @override
  String get apiNoPermission => 'आपको यह करने की अनुमति नहीं है।';

  @override
  String get apiSessionNotFound =>
      'सत्र नहीं मिला। सत्र ID जाँचें और फिर से कोशिश करें।';

  @override
  String get apiItemNotFound => 'माँगी गई चीज़ नहीं मिली।';

  @override
  String get apiServiceUnavailable =>
      'सेवा अभी उपलब्ध नहीं है। कृपया फिर से कोशिश करें।';

  @override
  String get apiNetworkFailure =>
      'हम यह अनुरोध पूरा नहीं कर सके। अपना कनेक्शन जाँचें और फिर से कोशिश करें।';

  @override
  String get apiUnknownFailure =>
      'हम यह अनुरोध पूरा नहीं कर सके। कृपया फिर से कोशिश करें।';

  @override
  String get apiAccountChangedRequestNotSent =>
      'आपका खाता बदल गया। यह अनुरोध नहीं भेजा गया।';

  @override
  String get apiAccountOrSessionChanged =>
      'आपका खाता या सत्र बदल गया। यह काम नहीं भेजा गया।';

  @override
  String get apiResponseUnreadable =>
      'सेवा का जवाब पढ़ा नहीं जा सका। हो सकता है काम पहुँच गया हो; फिर से कोशिश करने से पहले उसकी स्थिति जाँचें।';

  @override
  String get apiSignInBeforeAction =>
      'यह काम भेजने से पहले फिर से साइन इन करें।';

  @override
  String get apiAccountChangedNotConfirmed =>
      'आपका खाता बदल गया। इस काम की पुष्टि नहीं हो सकी।';

  @override
  String get apiActionNotConfirmed =>
      'इस काम की पुष्टि नहीं हुई। हो सकता है यह कक्षा तक पहुँच गया हो। फिर से कोशिश करने से पहले इसकी स्थिति जाँचें।';

  @override
  String get apiAccountChangedActionNotSent =>
      'आपका खाता बदल गया। यह काम नहीं भेजा गया।';

  @override
  String get apiRequestFailed => 'अनुरोध विफल रहा';

  @override
  String get notificationPrivateTitle => 'SEEDS अपडेट';

  @override
  String get notificationPrivateBody => 'अपने अपडेट देखने के लिए SEEDS खोलें।';

  @override
  String get notificationRegistrationFailed =>
      'सूचनाएँ रजिस्टर नहीं हो सकीं। कक्षा के निमंत्रण देखने के लिए SEEDS रीफ़्रेश करें।';

  @override
  String get notificationChannelName => 'सत्र सूचनाएँ';

  @override
  String get notificationChannelDescription =>
      'सत्र निमंत्रण और अपडेट की सूचनाएँ';

  @override
  String get notificationDisplayFailed =>
      'एक अपडेट आया, पर फ़ोन पर सूचना नहीं दिखाई जा सकी। अपडेट देखने के लिए SEEDS खोलें।';

  @override
  String get activityCleanupFailed =>
      'समाप्त हो चुकी गतिविधि साफ़ नहीं हो सकी। फ़ोन का स्टोरेज जाँचें।';

  @override
  String get activitySyncUnavailable =>
      'गतिविधि सिंक उपलब्ध नहीं है। सीखना अब भी उपलब्ध है।';

  @override
  String get activitySignInToSync => 'गतिविधि सिंक करने के लिए साइन इन करें।';

  @override
  String get activityQueueFull =>
      'गतिविधि की कतार भरी हुई है। कुछ पुराने काम रिपोर्ट नहीं हो सकते।';

  @override
  String get activityWaitingToSync =>
      'कुछ गतिविधि सिंक होने का इंतज़ार कर रही है।';

  @override
  String get activityRejected =>
      'कुछ गतिविधि समाप्त हो गई थी या अब उसकी अनुमति नहीं थी, इसलिए सिंक नहीं हुई।';

  @override
  String get authLogoutTitle => 'SEEDS से लॉग आउट करें?';

  @override
  String get authLogoutMessage =>
      'आपको अपना फ़ोन नंबर और पासवर्ड फिर से डालना होगा।';

  @override
  String get authLogoutCancel => 'रद्द करें';

  @override
  String get authLogoutConfirm => 'लॉग आउट करें';

  @override
  String get authLoggedOut => 'लॉग आउट हो गया।';

  @override
  String get startupLoadingTools => 'सुलभ सीखने के टूल लोड हो रहे हैं…';

  @override
  String get startupTagline => 'सबको, हर जगह जोड़ते हुए';

  @override
  String get startupLoginKey1 => '1. लॉगिन';

  @override
  String get startupLogin => 'लॉगिन';

  @override
  String get startupRegisterKey2 => '2. रजिस्टर करें';

  @override
  String get startupRegister => 'रजिस्टर करें';

  @override
  String get startupSettings => 'सेटिंग्स';

  @override
  String get startupRepeatInstructions => 'निर्देश दोहराएँ';

  @override
  String get startupFeatureAudioTitle => 'लाइव ऑडियो';

  @override
  String get startupFeatureAudioText => 'एकदम साफ़ आवाज़ में बातचीत';

  @override
  String get startupFeatureAccessibleTitle => 'पूरी तरह सुलभ';

  @override
  String get startupFeatureAccessibleText =>
      'आवाज़, बड़े बटन और कीपैड से नियंत्रण';

  @override
  String get startupFeatureCollaborationTitle => 'मिलकर काम';

  @override
  String get startupFeatureCollaborationText => 'हाथ उठाएँ और बातचीत करें';

  @override
  String get settingsResetTitle => 'सेटिंग्स रीसेट करें';

  @override
  String get settingsResetCancelButton => '1: रद्द करें';

  @override
  String get settingsResetConfirmButton => '2: रीसेट करें';

  @override
  String teacherHomeFallbackName(String id) {
    return 'शिक्षक $id';
  }

  @override
  String dashboardSignedInAs(String name) {
    return '$name के रूप में साइन इन है';
  }

  @override
  String get dashboardRefreshSessionsKey1 => '1: सत्र रीफ़्रेश करें';

  @override
  String get dashboardLogOutKey0 => '0: लॉग आउट';

  @override
  String get dashboardRefreshingSessions => 'सत्र रीफ़्रेश हो रहे हैं';

  @override
  String teacherHomeWelcome(String name) {
    return 'स्वागत है, $name!';
  }

  @override
  String get teacherHomeTagline => 'अपने सत्र संभालें और छात्रों से जुड़ें';

  @override
  String get teacherHomeChooseWorkspaceKey7 =>
      '7: कक्षा और विषय वर्कस्पेस चुनें';

  @override
  String teacherHomeChangeWorkspaceKey7(String className, String subjectName) {
    return '7: $className, $subjectName। वर्कस्पेस बदलें';
  }

  @override
  String get teacherHomePlaylistsKey5 => '5: कक्षा की प्लेलिस्ट';

  @override
  String get teacherHomeJourneysKey8 => '8: सीखने की यात्राएँ';

  @override
  String get teacherHomeQuizzesKey6 => '6: क्विज़ और प्रश्न बैंक';

  @override
  String get teacherHomeCreateSessionKey2 => '2: नया सत्र बनाएँ';

  @override
  String get dashboardAudioLibraryKey3 => '3: रिकॉर्ड की गई ऑडियो लाइब्रेरी';

  @override
  String get teacherHomeSearchKey4 => '4: नाम या नंबर से खोजें';

  @override
  String get teacherHomeSearchHint =>
      'सत्र का नाम टाइप करें, या नंबर बटनों से सत्र नंबर टाइप करें। सब देखने के लिए खाली छोड़ें।';

  @override
  String get teacherHomeYourSessions => 'आपके सत्र';

  @override
  String teacherHomeYourSessionsCount(String count) {
    return 'आपके सत्र, $count';
  }

  @override
  String get teacherHomeYourSessionsHeading => 'आपके सत्र';

  @override
  String get teacherHomeNoSessions =>
      'अभी तक कोई सत्र नहीं है। नया बनाने के लिए 2 दबाएँ।';

  @override
  String get teacherHomeNoMatches =>
      'कोई मेल खाता सत्र नहीं है। सभी सत्र देखने के लिए खोज साफ़ करें।';

  @override
  String teacherHomeEndTitleForEveryone(String title) {
    return '$title सबके लिए समाप्त करें';
  }

  @override
  String teacherHomeDeleteTitlePermanently(String title) {
    return '$title हमेशा के लिए हटाएँ';
  }

  @override
  String teacherHomeLiveJoined(String count) {
    return 'अभी लाइव, $count जुड़े';
  }

  @override
  String teacherHomeSessionNumber(String number) {
    return 'सत्र नंबर $number';
  }

  @override
  String teacherHomePlaceSessionNumber(String place, String number) {
    return '$place। सत्र नंबर $number';
  }

  @override
  String get teacherHomeDelete => 'हटाएँ';

  @override
  String get teacherHomeSessionTitleField => 'सत्र शीर्षक';

  @override
  String get teacherHomeSessionTitleHint => 'जैसे, अंग्रेज़ी कक्षा - इकाई 5';

  @override
  String get teacherHomeCreateKey1 => 'बनाएँ (1)';

  @override
  String studentHomeFallbackName(String id) {
    return 'छात्र $id';
  }

  @override
  String get studentHomeLoading => 'छात्र डैशबोर्ड लोड हो रहा है';

  @override
  String studentHomeWelcome(String name) {
    return 'स्वागत है, $name';
  }

  @override
  String studentHomeClass(String name) {
    return 'कक्षा: $name';
  }

  @override
  String get studentHomeAssignmentPending => 'कक्षा मिलना बाकी है';

  @override
  String get studentHomeLiveSessionsNone => 'लाइव सत्र: कोई नहीं';

  @override
  String studentHomeLiveSessionsCount(String count) {
    return 'लाइव सत्र: $count';
  }

  @override
  String get studentHomeSessionNumberKey2 => '2: सत्र नंबर';

  @override
  String get studentHomeSessionName => 'सत्र का नाम';

  @override
  String get studentHomeSubjectFilter => 'विषय फ़िल्टर';

  @override
  String get studentHomePlaylistsKey4 => '4: मेरी प्लेलिस्ट · निजी';

  @override
  String get studentHomeQuizzesKey5 => '5: क्विज़';

  @override
  String get studentHomeJourneysKey6 => '6: सीखने की यात्राएँ';

  @override
  String studentHomeTeacher(String name) {
    return 'शिक्षक: $name';
  }

  @override
  String studentHomeSessionOkToJoin(String number) {
    return 'सत्र $number। जुड़ने के लिए ओके';
  }

  @override
  String studentHomeJoinSessionLabel(String session) {
    return '$session। सत्र में जुड़ें';
  }

  @override
  String adminActiveAssignmentCount(String count) {
    return '$count सक्रिय असाइनमेंट';
  }

  @override
  String adminHeadingCount(String heading, String count) {
    return '$heading ($count)';
  }

  @override
  String get adminTextDialogHelper =>
      'लिखने के लिए ओके दबाएँ, फिर सहेजने के लिए 1 या रद्द करने के लिए 0 दबाएँ';

  @override
  String get adminSaveKey1 => 'सहेजें (1)';

  @override
  String adminManageUser(String name) {
    return '$name को प्रबंधित करें';
  }

  @override
  String get adminManageAssignmentsKey1 => '1: असाइनमेंट प्रबंधित करें';

  @override
  String get adminPasswordRecoveryKey2 => '2: पासवर्ड रिकवरी';

  @override
  String adminRemoveStudentFromClass(String name, String className) {
    return '$name को $className से हटाएँ (2)';
  }

  @override
  String get adminRemoveClassKey2 => 'कक्षा हटाएँ (2)';

  @override
  String get adminAssignKey1 => 'असाइन करें (1)';

  @override
  String adminAssignTeacher(String name) {
    return '$name को असाइन करें';
  }

  @override
  String get adminCurrentAssignments => 'मौजूदा असाइनमेंट';

  @override
  String adminRemoveTeacherAssignment(
    String name,
    String className,
    String subjectName,
  ) {
    return '$name को $className, $subjectName से हटाएँ';
  }

  @override
  String get adminAddAssignment => 'असाइनमेंट जोड़ें';

  @override
  String get adminAppBarTitle => 'SEEDS प्रशासन';

  @override
  String get adminRefreshKey1 => '1: प्रशासन का डेटा रीफ़्रेश करें';

  @override
  String get adminLoading => 'प्रशासन का डेटा लोड हो रहा है';

  @override
  String adminChangeSectionKey7(String section) {
    return '7: भाग बदलें। अभी: $section';
  }

  @override
  String get adminSearchKey2 => '2: नाम या फ़ोन नंबर से खोजें';

  @override
  String get adminSearchHelper => 'मिलान देखने के लिए पूरा होने पर ओके दबाएँ';

  @override
  String adminRoleFilterChipsLabel(String label) {
    return 'खाते के प्रकार का फ़िल्टर: $label, चुना गया। बदलने के लिए बाएँ और दाएँ तीर इस्तेमाल करें।';
  }

  @override
  String get adminAccountTypeKey3 => '3: खाते का प्रकार';

  @override
  String get adminChipAllAccounts => 'सभी खाते';

  @override
  String get adminChipStudents => 'छात्र';

  @override
  String get adminChipTeachers => 'शिक्षक';

  @override
  String adminAssignmentFilterChipsLabel(String label) {
    return 'असाइनमेंट फ़िल्टर: $label, चुना गया। बदलने के लिए बाएँ और दाएँ तीर इस्तेमाल करें।';
  }

  @override
  String get adminAssignmentKey4 => '4: असाइनमेंट';

  @override
  String get adminChipAll => 'सभी';

  @override
  String get adminCreateSubjectKey5 => '5: विषय बनाएँ';

  @override
  String get adminCreateClassKey6 => '6: कक्षा बनाएँ';

  @override
  String get adminStatusActive => 'सक्रिय';

  @override
  String get adminClassTileHint =>
      'विषयों के लिए या संग्रहित करने के लिए ओके दबाएँ';

  @override
  String get adminPressOkRestore => 'वापस लाने के लिए ओके दबाएँ';

  @override
  String get adminPressOkArchive => 'संग्रहित करने के लिए ओके दबाएँ';

  @override
  String sessionTitleTeacher(String title) {
    return '$title (शिक्षक)';
  }

  @override
  String get libraryStatusStopped => 'रुका हुआ';

  @override
  String libraryUploadFileName(String name) {
    return 'फ़ाइल: $name';
  }

  @override
  String libraryAudioSessionTitle(String number) {
    return 'ऑडियो - सत्र $number';
  }

  @override
  String libraryRecordingsCount(String count) {
    return '$count रिकॉर्डिंग';
  }

  @override
  String libraryUploadedAt(String date) {
    return 'अपलोड हुआ: $date';
  }

  @override
  String libraryStopPreviewOf(String title) {
    return '$title का प्रीव्यू रोकें';
  }

  @override
  String libraryPreviewPrivately(String title) {
    return '$title को निजी रूप से सुनें';
  }

  @override
  String libraryPlayForEveryone(String title) {
    return '$title को सत्र में सबके लिए चलाएँ';
  }

  @override
  String get librarySelectClassHint =>
      'रिकॉर्ड किए गए पाठ चलाने के लिए एक कक्षा चुनें। ऑनलाइन पाठ के लिए इंटरनेट चाहिए। सहेजे गए ऑडियो के लिए डाउनलोड किए गए पाठ इस्तेमाल करें।';

  @override
  String libraryFoundCount(String count) {
    return '$count मिले';
  }

  @override
  String get librarySearchSessionHint =>
      'किसी कक्षा तक जल्दी पहुँचने के लिए ऊपर \"सत्र के नाम से खोजें\" इस्तेमाल करें।';

  @override
  String librarySessionHash(String number) {
    return 'सत्र #$number';
  }

  @override
  String libraryStatusFinished(String title) {
    return '$title पूरा हुआ';
  }

  @override
  String libraryStatusPaused(String title) {
    return '$title रुका हुआ है';
  }

  @override
  String libraryStatusPlaying(String title) {
    return '$title चल रहा है';
  }

  @override
  String get libraryTitleField => 'शीर्षक';

  @override
  String get libraryDescriptionOptional => 'विवरण (वैकल्पिक)';

  @override
  String libraryAudioLibrarySession(String number) {
    return 'ऑडियो लाइब्रेरी, सत्र $number';
  }

  @override
  String get libraryUploadingAudio => 'ऑडियो अपलोड हो रहा है';

  @override
  String get libraryAddAudioKey3Tooltip => 'ऑडियो जोड़ें, बटन 3';

  @override
  String get libraryAddAudioKey3 => '3: ऑडियो जोड़ें';

  @override
  String get libraryNoRecordingsForClass =>
      'इस कक्षा के लिए अभी कोई रिकॉर्डिंग नहीं है।';

  @override
  String get libraryNoRecordingsAskTeacher =>
      'अभी कोई रिकॉर्डिंग उपलब्ध नहीं है। अपने शिक्षक से कुछ अपलोड करने को कहें।';

  @override
  String libraryPositionSpeed(String position, String total, String speed) {
    return '$total में से $position। गति ${speed}x';
  }

  @override
  String libraryNowPlaying(String title) {
    return 'अभी चल रहा है: $title';
  }

  @override
  String libraryRecordingsMatch(String count, String total) {
    return '$total में से $count रिकॉर्डिंग मिलीं';
  }

  @override
  String get libraryNoUnlinkedAudio => 'बिना जुड़ा कोई ऑडियो उपलब्ध नहीं है।';

  @override
  String get libraryNoSearchMatches => 'आपकी खोज से कोई रिकॉर्डिंग नहीं मिली।';

  @override
  String get libraryFindingLesson => 'आपका पाठ ढूँढा जा रहा है';

  @override
  String get libraryTitleRequiredField => 'शीर्षक *';

  @override
  String get libraryUploadNewAudio => 'नया ऑडियो अपलोड करें';

  @override
  String get libraryStopPreview => 'प्रीव्यू रोकें';

  @override
  String get libraryPreviewOnlyMe => 'प्रीव्यू (केवल मेरे लिए)';

  @override
  String get libraryPreview => 'प्रीव्यू';

  @override
  String get libraryStop => 'रोकें';

  @override
  String get libraryPlayInSession => 'सत्र में चलाएँ';

  @override
  String get librarySessionShort => 'सत्र';

  @override
  String get libraryNotesTooltip => 'निजी नोट और रिकॉर्डिंग के ड्राफ़्ट';

  @override
  String get libraryBrowseClassesKey5 => '5: चालू कक्षाएँ देखें';

  @override
  String get librarySearchClassByName => 'नाम से कक्षा खोजें';

  @override
  String get librarySearchClassHint => 'सत्र/कक्षा का नाम लिखें';

  @override
  String get libraryMyAudioLibrary => 'मेरी ऑडियो लाइब्रेरी';

  @override
  String get libraryAllAudioFiles => 'सभी ऑडियो फ़ाइलें';

  @override
  String get libraryManageAudioFiles =>
      'अपनी ऑडियो फ़ाइलें संभालें और अपलोड करें';

  @override
  String get libraryBrowseAudioFiles => 'अपलोड की गई सभी ऑडियो फ़ाइलें देखें';

  @override
  String get libraryActiveClasses => 'चालू कक्षाएँ';

  @override
  String get libraryNoActiveClasses => 'कोई चालू कक्षा नहीं मिली।';

  @override
  String get libraryAddAudioToSessions => 'सत्रों में ऑडियो जोड़ें';

  @override
  String get libraryConfirmKey1 => '1: पक्का करें';

  @override
  String get libraryDownloadLessons => 'पाठ डाउनलोड करें';

  @override
  String get libraryRepeatHelp => 'मदद फिर से सुनें';

  @override
  String get libraryBack10s => '10 सेकंड पीछे';

  @override
  String get libraryPause => 'रोकें';

  @override
  String get libraryPlay => 'चलाएँ';

  @override
  String get libraryForward10s => '10 सेकंड आगे';

  @override
  String get libraryCloseAddAudio => 'ऑडियो जोड़ने के विकल्प बंद करें';

  @override
  String get libraryUploadNewFileKey1 => '1: नई फ़ाइल अपलोड करें';

  @override
  String get librarySelectExistingKey2 => '2: मौजूदा लाइब्रेरी से चुनें';

  @override
  String get librarySelectAudio => 'ऑडियो चुनें';

  @override
  String get libraryRefreshAvailable => 'उपलब्ध ऑडियो रीफ़्रेश करें';

  @override
  String get librarySearchByTitle => 'शीर्षक से खोजें';

  @override
  String get libraryNothingPlaying =>
      'कुछ नहीं चल रहा है। कोई पाठ चुनें या 5 दबाएँ।';

  @override
  String spokenDayMonthYear(String day, String month, String year) {
    return '$day $month $year';
  }

  @override
  String get downloadPartialReserve =>
      'अधूरी फ़ाइलें अपने पूरे आकार जितनी जगह रखती हैं।';

  @override
  String downloadProgressStarting(String title) {
    return '$title: डाउनलोड शुरू हो रहा है';
  }

  @override
  String downloadPercentDone(String title, String percent) {
    return '$title: $percent प्रतिशत डाउनलोड हुआ';
  }

  @override
  String downloadRecordUnreadable(String id) {
    return 'डाउनलोड रिकॉर्ड $id पढ़ा नहीं जा सका। फ़ाइलें रखी गई हैं। ठीक करने के लिए केवल यह डाउनलोड हटाएँ; प्रगति और बुकमार्क रखे रहेंगे।';
  }

  @override
  String downloadRemoveUnreadable(String id) {
    return 'न पढ़ा जा सकने वाला डाउनलोड $id हटाएँ';
  }

  @override
  String get downloadStatusDownloaded => 'डाउनलोड हो गया';

  @override
  String get downloadStatusPartial => 'अधूरा डाउनलोड';

  @override
  String downloadSizeRenewal(String megabytes) {
    return '$megabytes MB. एक्सेस फिर से चालू करना ज़रूरी है।';
  }

  @override
  String downloadSizeExpires(String megabytes, String date) {
    return '$megabytes MB. एक्सेस $date को खत्म होगा।';
  }

  @override
  String get downloadTitle => 'डाउनलोड';

  @override
  String get downloadAccessInfo =>
      '30 दिन का ऑफ़लाइन एक्सेस। दूसरे खातों की अलग सीमा है। अपने आप कुछ नहीं हटाया जाता।';

  @override
  String get downloadRefreshKey1 => '1: डाउनलोड रीफ़्रेश करें';

  @override
  String get downloadFindOnlineKey2 => '2: ऑनलाइन रिकॉर्डिंग खोजें';

  @override
  String get downloadReadStatusKey3 => '3: स्थिति सुनें';

  @override
  String get downloadCancelKey4 => '4: डाउनलोड रद्द करें';

  @override
  String get downloadNoneYetFindOnline =>
      'अभी कोई डाउनलोड नहीं है। ऑनलाइन रिकॉर्डिंग खोजें या किसी कक्षा या प्लेलिस्ट से डाउनलोड खोलें।';

  @override
  String get downloadPlayLesson => 'डाउनलोड किया गया पाठ चलाएँ';

  @override
  String get downloadRenewOnline => 'ऑनलाइन एक्सेस फिर से चालू करें';

  @override
  String get downloadRemove => 'डाउनलोड हटाएँ';

  @override
  String get downloadListedKey5 => '5: सूची की रिकॉर्डिंग डाउनलोड करें';

  @override
  String get downloadAvailableInfo =>
      'उपलब्ध रिकॉर्डिंग। डाउनलोड में इंटरनेट डेटा लगता है।';

  @override
  String playlistClassSubjectTitle(String className, String subjectName) {
    return '$className · $subjectName प्लेलिस्ट';
  }

  @override
  String get playlistStatusPrivate => 'निजी';

  @override
  String get playlistClassPlaylist => 'कक्षा की प्लेलिस्ट';

  @override
  String playlistItemCount(String count) {
    return '$count आइटम';
  }

  @override
  String playlistClassItemCount(
    String className,
    String subjectName,
    String count,
  ) {
    return '$className, $subjectName, $count आइटम';
  }

  @override
  String get playlistFinished => 'पूरा हुआ। प्लेलिस्ट खत्म';

  @override
  String get playlistAddKey2 => '2 जोड़ें';

  @override
  String get playlistAddAudioKey2Label => 'ऑडियो जोड़ें, बटन 2';

  @override
  String get playlistPauseKey5 => '5 रोकें';

  @override
  String get playlistPlayKey5 => '5 चलाएँ';

  @override
  String playlistPauseTitleKey5(String title) {
    return '$title रोकें, बटन 5';
  }

  @override
  String playlistPlayTitleKey5(String title) {
    return '$title चलाएँ, बटन 5';
  }

  @override
  String get playlistPreviousKey3 => '3 पिछला';

  @override
  String get playlistPreviousItemKey3 => 'पिछला आइटम, बटन 3';

  @override
  String get playlistNextKey8 => '8 अगला';

  @override
  String get playlistNextItemKey8 => 'अगला आइटम, बटन 8';

  @override
  String get playlistRestore => 'वापस लाएँ';

  @override
  String get playlistArchive => 'संग्रहित करें';

  @override
  String get playlistDeletePlaylist => 'प्लेलिस्ट मिटाएँ';

  @override
  String playlistRestoreNamedButton(String title) {
    return '$title वापस लाएँ';
  }

  @override
  String playlistArchiveNamedButton(String title) {
    return '$title संग्रहित करें';
  }

  @override
  String playlistDeleteNamedButton(String title) {
    return '$title मिटाएँ';
  }

  @override
  String playlistMoveUp(String title) {
    return '$title को ऊपर ले जाएँ';
  }

  @override
  String playlistMoveDown(String title) {
    return '$title को नीचे ले जाएँ';
  }

  @override
  String get playlistCreateKey2 => '2: प्लेलिस्ट बनाएँ';

  @override
  String get playlistNoneInClass =>
      'इस कक्षा और विषय में कोई प्लेलिस्ट नहीं है। नई बनाने के लिए 2 दबाएँ।';

  @override
  String get playlistMyPlaylists => 'मेरी प्लेलिस्ट';

  @override
  String get playlistPrivateNoticeTitle => 'आपकी प्लेलिस्ट निजी हैं';

  @override
  String get playlistPrivateNoticeText =>
      'शिक्षक, प्रशासक और दूसरे छात्र इन्हें नहीं देख सकते।';

  @override
  String get playlistCreatePrivateKey2 => '2: निजी प्लेलिस्ट बनाएँ';

  @override
  String get playlistMyPrivateHeading => 'मेरी निजी प्लेलिस्ट';

  @override
  String get playlistNoPrivate => 'अभी कोई निजी प्लेलिस्ट नहीं है।';

  @override
  String get playlistClassHeading => 'कक्षा की प्लेलिस्ट';

  @override
  String get playlistNoClassPublished =>
      'अभी कक्षा की कोई प्लेलिस्ट प्रकाशित नहीं हुई है।';

  @override
  String get playlistAddAudioTitle => 'ऑडियो जोड़ें';

  @override
  String get playlistUnavailableRetry =>
      'प्लेलिस्ट उपलब्ध नहीं है। फिर से कोशिश करने के लिए 1 दबाएँ।';

  @override
  String get playlistDownloadRecordings =>
      'प्लेलिस्ट की रिकॉर्डिंग डाउनलोड करें';

  @override
  String get playlistMoveHint =>
      'कोई आइटम चलाएँ या चुनें, फिर उसे ऊपर या नीचे ले जाएँ।';

  @override
  String get playlistNoAudio => 'इस प्लेलिस्ट में अभी कोई ऑडियो नहीं है।';

  @override
  String quizClassSubjectHeading(String className, String subjectName) {
    return '$className · $subjectName';
  }

  @override
  String get quizBankEditNote =>
      'बैंक का प्रश्न बदलने से किसी मौजूदा क्विज़ की सेव की गई कॉपी कभी नहीं बदलती।';

  @override
  String get quizNoBankQuestions => 'बैंक में अभी कोई प्रश्न नहीं है';

  @override
  String quizOptionsCount(String count) {
    return '$count विकल्प';
  }

  @override
  String get quizNoQuizzesYet => 'अभी कोई क्विज़ नहीं है';

  @override
  String get quizStepReviewPublish => 'चरण 3: जाँचें और प्रकाशित करें';

  @override
  String get quizStepAddQuestions => 'चरण 2: प्रश्न जोड़ें';

  @override
  String quizResultsTitle(String title) {
    return '$title के परिणाम';
  }

  @override
  String get quizAllAttempted => 'सभी छात्रों ने प्रयास कर लिया है';

  @override
  String get quizRemindAllKey2 =>
      '2: जिन्होंने प्रयास नहीं किया, उन सबको याद दिलाएँ';

  @override
  String get uiNoneCapital => 'कोई नहीं';

  @override
  String get quizPracticeParticipationHeading =>
      'अभ्यास में भागीदारी, पढ़ाई के अंक नहीं';

  @override
  String get quizIndividualScores => 'हर छात्र के अंक';

  @override
  String get quizNotAttempted => 'प्रयास नहीं किया';

  @override
  String get quizPracticeNotGraded => 'अभ्यास, अंक वाला नहीं';

  @override
  String quizHighestScore(String score) {
    return 'सबसे ज़्यादा अंक: $score';
  }

  @override
  String get quizAttemptInProgress => 'प्रयास चल रहा है';

  @override
  String get quizQuizzesTitle => 'क्विज़';

  @override
  String get quizRefreshQuizzesTooltip => 'क्विज़ रीफ़्रेश करें';

  @override
  String get quizLoadingQuizzes => 'क्विज़ लोड हो रहे हैं';

  @override
  String get quizNewBankQuestionKey2 => '2: बैंक में नया प्रश्न';

  @override
  String get quizNewDraftKey3 => '3: नया क्विज़ ड्राफ़्ट';

  @override
  String get quizCreatePracticeKey4 => '4: बिना समय सीमा का अभ्यास बनाएँ';

  @override
  String get quizPrivateBankHeading => 'निजी प्रश्न बैंक';

  @override
  String get quizOptionsButton => 'विकल्प';

  @override
  String get quizManagementHeading => 'क्विज़ प्रबंधन';

  @override
  String get quizContinueCreation => 'बनाना जारी रखें';

  @override
  String get quizCloseButton => 'बंद करें';

  @override
  String get quizDuplicateButton => 'कॉपी बनाएँ';

  @override
  String get quizResultsButton => 'परिणाम';

  @override
  String get quizRefreshResultsTooltip => 'परिणाम रीफ़्रेश करें';

  @override
  String get quizClassStatistics => 'कक्षा के आँकड़े';

  @override
  String get quizStudentsYetToAttempt => 'जिन छात्रों ने अभी प्रयास नहीं किया';

  @override
  String get quizNoQuizzesAvailableLabel => 'कोई क्विज़ उपलब्ध नहीं है';

  @override
  String get quizAttemptLimitReachedLabel => 'प्रयास की सीमा पूरी हो गई';

  @override
  String get quizAnswerSavedLockedTitle => 'उत्तर सेव और लॉक हो गया';

  @override
  String get quizAllSavedViewResult =>
      'सभी उत्तर सेव हो गए हैं। पूरा होना पक्का करने के लिए परिणाम देखें चुनें।';

  @override
  String quizAsksToConfirm(String label) {
    return '$label, पुष्टि माँगेगा';
  }

  @override
  String get quizConfirmingCompletion => 'पूरा होना पक्का किया जा रहा है';

  @override
  String get quizRetryCompletionKey5 => '5: फिर से पूरा करने की कोशिश करें';

  @override
  String get quizViewResultKey5 => '5: परिणाम देखें';

  @override
  String quizHistoryTitle(String title) {
    return '$title का इतिहास';
  }

  @override
  String get quizNoAttemptsYet => 'अभी कोई प्रयास नहीं';

  @override
  String get quizHistoryTooltip => 'प्रयासों का इतिहास और समीक्षा';

  @override
  String get quizLeaveWithoutSubmitting => 'जमा किए बिना बाहर जाएँ';

  @override
  String get quizAttemptCompletePrivateLabel =>
      'प्रयास पूरा हुआ। परिणाम निजी है। परिणाम निजी तौर पर सुनें चुनें।';

  @override
  String get quizReadResultKey8 => '8: परिणाम निजी तौर पर सुनें';

  @override
  String get quizReturnKey0 => '0: क्विज़ पर वापस जाएँ';

  @override
  String get quizReadAllOptionsLabel => 'सभी विकल्प सुनें';

  @override
  String get quizSubmitAnswerKey5 => '5: उत्तर जमा करें';

  @override
  String get quizAnswerLockedActivate =>
      'उत्तर सेव और लॉक हो गया। फ़ीडबैक निजी तौर पर सुनने के लिए चुनें।';

  @override
  String get quizReadSelectedAnswer => 'चुना गया उत्तर सुनें';

  @override
  String get quizReadRemainingTime => 'बचा हुआ समय सुनें';

  @override
  String get quizAttemptReviewTitle => 'प्रयास की समीक्षा';

  @override
  String get quizEditorIntro =>
      'प्रश्न और चारों विकल्प पूरे लिखें, फिर सही उत्तर चुनें। समीकरण या चित्र के लिए, बोलकर पढ़ने का वैकल्पिक तरीका खोलें और विकल्पों को जाँचें।';

  @override
  String get quizWhichCorrect => 'कौन सा उत्तर सही है?';

  @override
  String get quizChooseCorrectOption => 'सही विकल्प चुनें';

  @override
  String quizOptionWithText(String number, String text) {
    return 'विकल्प $number: $text';
  }

  @override
  String get quizCorrectChoiceHint =>
      'बदलने के लिए बाएँ या दाएँ दबाएँ। ओके दबाने या टैप करने से अगला विकल्प चुना जाता है।';

  @override
  String get quizExplanationOptional => 'व्याख्या (वैकल्पिक)';

  @override
  String get quizContentDescribedText =>
      'सामग्री: शिक्षक द्वारा बताया गया चिह्न या चित्र';

  @override
  String get quizNotationNote =>
      'समीकरण या चित्र अपने आप नहीं समझाए जाते। शिक्षक को अंग्रेज़ी में बोलकर पढ़ने वाला रूप लिखना और जाँचना होगा। बताए गए चिह्नों के लिए प्रश्न, सभी विकल्प और कोई भी व्याख्या शामिल करें।';

  @override
  String get quizReviewedAlternatives =>
      'मैंने बोलकर पढ़ने वाले रूप को सही होने के लिए जाँच लिया है';

  @override
  String get quizChangeSettings => 'क्विज़ की सेटिंग्स बदलें';

  @override
  String get quizCreatePracticeText => 'बिना समय सीमा का अभ्यास बनाएँ';

  @override
  String get quizStepName => 'चरण 1: अपने क्विज़ का नाम रखें';

  @override
  String get quizPracticeInfo =>
      'अभ्यास में हर प्रयास का टाइमर या दोबारा कोशिश की सीमा नहीं होती। फिर भी, अगर बंद होने का समय दिया है तो उस समय यह उपलब्ध नहीं रहेगा।';

  @override
  String get quizSettingsNavLabel =>
      'क्विज़ की सेटिंग्स में जाने के लिए ऊपर और नीचे दबाएँ। टेक्स्ट बदलने के लिए ओके दबाएँ। खुलने और बंद होने का समय वैकल्पिक है।';

  @override
  String get quizSettingsNavText =>
      'सेटिंग्स में जाने के लिए ऊपर और नीचे दबाएँ, और बदलने के लिए ओके दबाएँ। ड्राफ़्ट या उसकी सेटिंग्स सेव करने से क्विज़ प्रकाशित नहीं होता।';

  @override
  String get quizSettingsReviewInfo =>
      'नीचे सेव की गई सेटिंग्स जाँचें और बदलें। सेव करने से क्विज़ प्रकाशित नहीं होता।';

  @override
  String get quizPracticeDefaults =>
      'बिना अंक वाला अभ्यास। असीमित प्रयास, कोई टाइमर नहीं, तुरंत फ़ीडबैक।';

  @override
  String get quizGradedDefaults =>
      'अंक वाली डिफ़ॉल्ट सेटिंग्स: एक प्रयास, कोई टाइमर नहीं, आख़िरी बार जमा करने के बाद फ़ीडबैक।';

  @override
  String get quizHideOptionalSettingsText => 'वैकल्पिक सेटिंग्स छिपाएँ';

  @override
  String get quizShowOptionalSettingsText => 'वैकल्पिक सेटिंग्स दिखाएँ';

  @override
  String get quizAttemptLimitFieldText => 'प्रयास की सीमा, 1 से 20';

  @override
  String get quizTimeLimitFieldText => 'समय सीमा मिनटों में (वैकल्पिक)';

  @override
  String get quizUntimedInfo =>
      'बिना समय सीमा और बिना अंक, असीमित बार कोशिश। अगर उपलब्धता का समय दिया है तो वह लागू रहेगा।';

  @override
  String quizFeedbackValue(String policy) {
    return 'फ़ीडबैक: $policy';
  }

  @override
  String quizReleaseValue(String time) {
    return 'जारी होने का समय: $time';
  }

  @override
  String quizOpeningTimeLabel(String time) {
    return '$time. खुलने का समय तय करने के लिए ओके दबाएँ। बायाँ दबाने से यह हट जाएगा।';
  }

  @override
  String get quizNoOpeningTimeSet => 'खुलने का समय तय नहीं है';

  @override
  String get quizNoOpeningTimeShort => 'खुलने का समय नहीं';

  @override
  String get quizOpeningTimeHint =>
      'वैकल्पिक · साल, महीना, दिन, घंटा और मिनट लिखें';

  @override
  String quizClosingTimeLabel(String time) {
    return '$time. बंद होने का समय तय करने के लिए ओके दबाएँ। बायाँ दबाने से यह हट जाएगा।';
  }

  @override
  String get quizNoClosingTimeSet => 'बंद होने का समय तय नहीं है';

  @override
  String get quizNoClosingTimeShort => 'बंद होने का समय नहीं';

  @override
  String get quizClosingTimeHint => 'वैकल्पिक · खुलने के समय के बाद होना चाहिए';

  @override
  String get quizShuffleQuestions =>
      'हर प्रयास में एक बार प्रश्नों का क्रम बदलें';

  @override
  String get quizShuffleOptions =>
      'हर प्रयास में एक बार विकल्पों का क्रम बदलें';

  @override
  String messageProblem(String text) {
    return 'समस्या: $text';
  }

  @override
  String messageMessage(String text) {
    return 'संदेश: $text';
  }

  @override
  String get adminSetupSectionAccounts => 'खाते';

  @override
  String get adminSetupSectionCatalog => 'कक्षाएँ और विषय';

  @override
  String get adminSetupSectionTimetable => 'समय-सारणी';

  @override
  String get adminSetupSectionSchedule => 'आज की समय-सारणी';

  @override
  String get adminSetupSectionSharedPhones => 'साझा फ़ोन';

  @override
  String get adminSetupSectionHolidays => 'छुट्टियाँ';

  @override
  String get adminSetupSectionIssues => 'समस्याएँ';

  @override
  String get adminSetupSectionRecords => 'कक्षा के रिकॉर्ड';

  @override
  String get adminSetupSectionPicker => 'भाग';

  @override
  String adminSetupRefresh(String section) {
    return '$section रीफ़्रेश करें';
  }

  @override
  String get adminSetupLogOut => 'लॉग आउट';

  @override
  String get adminSetupLoading => 'लोड हो रहा है';

  @override
  String get adminSetupSaving => 'सेव हो रहा है';

  @override
  String get adminSetupRetry => 'फिर से कोशिश करें';

  @override
  String adminSetupLoadFailed(String reason) {
    return 'यह सूची लोड नहीं हो सकी। $reason';
  }

  @override
  String get adminSetupUnknownError =>
      'कुछ गड़बड़ हो गई। कृपया फिर से कोशिश करें।';

  @override
  String get adminSetupNotSaved =>
      'बदलाव सेव नहीं हो सका। रीफ़्रेश करके फिर से कोशिश करें।';

  @override
  String get adminSetupCancel => 'रद्द करें';

  @override
  String get adminSetupSave => 'सेव करें';

  @override
  String get adminSetupClose => 'बंद करें';

  @override
  String get adminSetupDelete => 'मिटाएँ';

  @override
  String get adminSetupRemove => 'हटाएँ';

  @override
  String get adminSetupEdit => 'बदलें';

  @override
  String adminSetupEditNamed(String name) {
    return '$name बदलें';
  }

  @override
  String adminSetupRequiredField(String field) {
    return '$field ज़रूरी है।';
  }

  @override
  String get adminSetupNoDate => 'तय नहीं';

  @override
  String adminSetupDateValue(String field, String date) {
    return '$field: $date';
  }

  @override
  String adminSetupClearDate(String field) {
    return '$field हटाएँ';
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
  String get adminSetupDateField => 'तारीख';

  @override
  String get adminSetupInactive => 'बंद किया गया';

  @override
  String get adminSetupFilterAll => 'सभी';

  @override
  String get adminSetupShowFilter => 'दिखाएँ';

  @override
  String get adminSetupRoleStudent => 'छात्र';

  @override
  String get adminSetupRoleTeacher => 'शिक्षक';

  @override
  String get adminSetupAddPerson => 'व्यक्ति जोड़ें';

  @override
  String get adminSetupSearchLabel => 'नाम या फ़ोन नंबर से खोजें';

  @override
  String get adminSetupSearchButton => 'खोजें';

  @override
  String get adminSetupAccountTypeHeading => 'खाते का प्रकार';

  @override
  String get adminSetupAssignmentHeading => 'कक्षा या विषय दिया गया';

  @override
  String adminSetupAccountsShown(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count खाते दिखाए गए।',
      one: '1 खाता दिखाया गया।',
      zero: 'कोई मिलता-जुलता खाता नहीं।',
    );
    return '$_temp0';
  }

  @override
  String adminSetupTeachersHeading(int count) {
    return 'शिक्षक ($count)';
  }

  @override
  String adminSetupStudentsHeading(int count) {
    return 'छात्र ($count)';
  }

  @override
  String get adminSetupNameField => 'नाम';

  @override
  String get adminSetupPhoneField => 'फ़ोन नंबर';

  @override
  String get adminSetupRoleField => 'भूमिका';

  @override
  String get adminSetupTeacherPairsHeading =>
      'यह शिक्षक कौन सी कक्षाएँ और विषय पढ़ाते हैं';

  @override
  String get adminSetupNoPairs =>
      'अभी कोई नहीं। आप इन्हें बाद में जोड़ सकते हैं।';

  @override
  String get adminSetupClassField => 'कक्षा';

  @override
  String get adminSetupSubjectField => 'विषय';

  @override
  String get adminSetupAddPair => 'कक्षा और विषय जोड़ें';

  @override
  String adminSetupPairLabel(String className, String subject) {
    return '$className, $subject';
  }

  @override
  String adminSetupRemovePair(String className, String subject) {
    return '$className, $subject हटाएँ';
  }

  @override
  String get adminSetupNoSubjectsInClass =>
      'इस कक्षा में अभी कोई विषय नहीं है। कक्षाएँ और विषय में जाकर विषय जोड़ें।';

  @override
  String get adminSetupNoActiveClasses =>
      'अभी कोई चालू कक्षा नहीं है। कक्षाएँ और विषय में जाकर एक जोड़ें।';

  @override
  String adminSetupPersonAdded(String name) {
    return '$name को जोड़ दिया गया।';
  }

  @override
  String adminSetupEditPerson(String name) {
    return '$name बदलें';
  }

  @override
  String get adminSetupPhoneChangeNote =>
      'फ़ोन नंबर बदलने से यह व्यक्ति हर फ़ोन से साइन आउट हो जाएगा।';

  @override
  String adminSetupPersonSaved(String name) {
    return '$name में किए गए बदलाव सेव हो गए।';
  }

  @override
  String get adminSetupDeactivate => 'बंद करें';

  @override
  String get adminSetupActivate => 'चालू करें';

  @override
  String adminSetupDeactivateNamed(String name) {
    return '$name को बंद करें';
  }

  @override
  String adminSetupActivateNamed(String name) {
    return '$name को चालू करें';
  }

  @override
  String adminSetupDeactivateTitle(String name) {
    return '$name को बंद करें?';
  }

  @override
  String adminSetupDeactivateMessage(String name) {
    return '$name साइन आउट हो जाएँगे और खाता फिर से चालू होने तक साइन इन नहीं कर पाएँगे।';
  }

  @override
  String adminSetupActivated(String name) {
    return '$name फिर से साइन इन कर सकते हैं।';
  }

  @override
  String adminSetupDeactivated(String name) {
    return '$name को बंद कर दिया गया।';
  }

  @override
  String get adminSetupSignOutEverywhere => 'हर जगह से साइन आउट करें';

  @override
  String adminSetupSignOutNamed(String name) {
    return '$name को हर जगह से साइन आउट करें';
  }

  @override
  String adminSetupSignOutTitle(String name) {
    return '$name को हर जगह से साइन आउट करें?';
  }

  @override
  String adminSetupSignOutMessage(String name) {
    return 'इससे $name का साइन इन हर फ़ोन पर खत्म हो जाएगा, जैसे अगर किसी और ने उनका नंबर इस्तेमाल किया हो। वे अपने फ़ोन नंबर से फिर से साइन इन कर सकते हैं।';
  }

  @override
  String adminSetupSignedOut(String name) {
    return '$name को हर जगह से साइन आउट कर दिया गया।';
  }

  @override
  String get adminSetupStudentClassAction => 'कक्षा बदलें';

  @override
  String get adminSetupTeacherAssignmentsAction => 'कक्षाएँ और विषय';

  @override
  String adminSetupStudentDetail(String className) {
    return 'छात्र। कक्षा: $className';
  }

  @override
  String get adminSetupStudentNoClass => 'छात्र। अभी कोई कक्षा नहीं।';

  @override
  String adminSetupTeacherDetail(String pairs) {
    return 'शिक्षक। पढ़ाते हैं: $pairs';
  }

  @override
  String get adminSetupTeacherNoPairs => 'शिक्षक। अभी कोई कक्षा या विषय नहीं।';

  @override
  String adminSetupPhoneDetail(String phone) {
    return 'फ़ोन: $phone';
  }

  @override
  String adminSetupClassDialogTitle(String name) {
    return '$name की कक्षा';
  }

  @override
  String adminSetupRemoveFromClass(String className) {
    return '$className से हटाएँ';
  }

  @override
  String adminSetupStudentEnrolled(String name, String className) {
    return '$name अब $className में है।';
  }

  @override
  String adminSetupStudentRemoved(String name) {
    return '$name को उनकी कक्षा से हटा दिया गया।';
  }

  @override
  String adminSetupAssignmentsTitle(String name) {
    return '$name की कक्षाएँ और विषय';
  }

  @override
  String get adminSetupCurrentPairs => 'अभी पढ़ाते हैं';

  @override
  String adminSetupPairAdded(String name, String className, String subject) {
    return '$name अब $className, $subject पढ़ाते हैं।';
  }

  @override
  String adminSetupPairRemoved(String name, String className, String subject) {
    return '$name अब $className, $subject नहीं पढ़ाते।';
  }

  @override
  String get adminSetupClassesHeading => 'कक्षाएँ';

  @override
  String get adminSetupSubjectsHeading => 'विषय';

  @override
  String get adminSetupAddClass => 'कक्षा जोड़ें';

  @override
  String get adminSetupAddSubject => 'विषय जोड़ें';

  @override
  String get adminSetupNoClasses => 'अभी कोई कक्षा नहीं है।';

  @override
  String get adminSetupNoSubjects => 'अभी कोई विषय नहीं है।';

  @override
  String get adminSetupSubjectsButton => 'विषय';

  @override
  String adminSetupClassSubjects(String className) {
    return '$className के विषय';
  }

  @override
  String adminSetupArchiveNamed(String name) {
    return '$name संग्रहित करें';
  }

  @override
  String adminSetupRestoreNamed(String name) {
    return '$name वापस लाएँ';
  }

  @override
  String get adminSetupNoSubjectsToChoose =>
      'अभी कोई चालू विषय नहीं है। पहले एक विषय जोड़ें।';

  @override
  String get adminSetupAddLesson => 'समय-सारणी में पाठ जोड़ें';

  @override
  String get adminSetupEditLesson => 'समय-सारणी का पाठ बदलें';

  @override
  String get adminSetupAllTeachers => 'सभी शिक्षक';

  @override
  String get adminSetupAllClasses => 'सभी कक्षाएँ';

  @override
  String get adminSetupTeacherField => 'शिक्षक';

  @override
  String get adminSetupWeekdayField => 'हफ़्ते का दिन';

  @override
  String get adminSetupStartField => 'शुरू होने का समय';

  @override
  String get adminSetupEndField => 'खत्म होने का समय';

  @override
  String get adminSetupTimeHelper =>
      '24 घंटे वाला भारतीय समय (IST), जैसे 09:30';

  @override
  String adminSetupTimeInvalid(String field) {
    return '$field को 24 घंटे वाले समय में लिखें, जैसे 09:30।';
  }

  @override
  String get adminSetupEndBeforeStart =>
      'पाठ शुरू होने के बाद ही खत्म होना चाहिए।';

  @override
  String get adminSetupUntilBeforeFrom =>
      'आख़िरी तारीख पहली तारीख के दिन या उसके बाद होनी चाहिए।';

  @override
  String get adminSetupValidFrom => 'पहली तारीख';

  @override
  String get adminSetupValidUntil => 'आख़िरी तारीख';

  @override
  String get adminSetupLessonField => 'पाठ प्लेलिस्ट (वैकल्पिक)';

  @override
  String get adminSetupNoLesson => 'कोई पाठ प्लेलिस्ट नहीं';

  @override
  String get adminSetupNoLessonsFound =>
      'इस शिक्षक के पास इस कक्षा और विषय के लिए अभी कोई पाठ प्लेलिस्ट नहीं है।';

  @override
  String get adminSetupShowInactive => 'बंद किए गए पाठ दिखाएँ';

  @override
  String get adminSetupNoTimetable =>
      'समय-सारणी में कोई मिलता-जुलता पाठ नहीं है।';

  @override
  String adminSetupEntryTitle(
    String start,
    String end,
    String subject,
    String className,
  ) {
    return '$start से $end: $subject, $className';
  }

  @override
  String adminSetupEntryTeacher(String name) {
    return 'शिक्षक: $name';
  }

  @override
  String adminSetupEntryLesson(String title) {
    return 'पाठ प्लेलिस्ट: $title';
  }

  @override
  String get adminSetupEntryNoLesson => 'कोई पाठ प्लेलिस्ट नहीं चुनी गई।';

  @override
  String adminSetupEntryFrom(String date) {
    return '$date से';
  }

  @override
  String adminSetupEntryUntil(String date) {
    return '$date तक';
  }

  @override
  String get adminSetupDateChanges => 'तारीख के बदलाव';

  @override
  String adminSetupDateChangesNamed(String title) {
    return '$title के लिए तारीख के बदलाव';
  }

  @override
  String get adminSetupDeactivateLesson => 'बंद करें';

  @override
  String get adminSetupReactivateLesson => 'फिर से चालू करें';

  @override
  String get adminSetupDeactivateLessonTitle => 'यह पाठ बंद करें?';

  @override
  String adminSetupDeactivateLessonMessage(
    String subject,
    String className,
    String weekday,
    String start,
  ) {
    return '$className के लिए $weekday को $start बजे का $subject अब समय-सारणी में नहीं रहेगा।';
  }

  @override
  String get adminSetupLessonSaved => 'समय-सारणी सेव हो गई।';

  @override
  String get adminSetupLessonDeactivated => 'पाठ बंद कर दिया गया।';

  @override
  String get adminSetupLessonReactivated => 'पाठ फिर से चालू कर दिया गया।';

  @override
  String adminSetupClassSubjectFixed(String className, String subject) {
    return '$className, $subject. कक्षा या विषय बदलने के लिए, यह पाठ बंद करें और नया पाठ जोड़ें।';
  }

  @override
  String adminSetupDateChangesTitle(String lesson, String weekday) {
    return 'तारीख के बदलाव: $lesson, हर $weekday';
  }

  @override
  String get adminSetupNoDateChanges => 'तारीख में कोई बदलाव नहीं।';

  @override
  String get adminSetupAddDateChange => 'एक तारीख बदलें';

  @override
  String get adminSetupCancelledLabel => 'इस तारीख को रद्द है।';

  @override
  String adminSetupSubstituteLabel(String name) {
    return 'बदले में शिक्षक: $name';
  }

  @override
  String get adminSetupDifferentLesson =>
      'इस तारीख को दूसरी पाठ प्लेलिस्ट इस्तेमाल होगी।';

  @override
  String adminSetupNoteLabel(String note) {
    return 'नोट: $note';
  }

  @override
  String get adminSetupClearChange => 'बदलाव हटाएँ';

  @override
  String adminSetupClearChangeNamed(String date) {
    return '$date का बदलाव हटाएँ';
  }

  @override
  String adminSetupEditDateChangeNamed(String date) {
    return '$date का बदलाव बदलें';
  }

  @override
  String adminSetupChangeCleared(String date) {
    return '$date का बदलाव हटा दिया गया।';
  }

  @override
  String adminSetupDateChangeTitle(String lesson) {
    return 'एक तारीख बदलें: $lesson';
  }

  @override
  String get adminSetupCancelOnDate => 'इस तारीख को पाठ रद्द करें';

  @override
  String get adminSetupSubstituteField => 'बदले में शिक्षक (वैकल्पिक)';

  @override
  String adminSetupRegularTeacher(String name) {
    return 'कोई बदले में शिक्षक नहीं ($name पढ़ाएँगे)';
  }

  @override
  String get adminSetupDateLessonField => 'इस तारीख की पाठ प्लेलिस्ट';

  @override
  String get adminSetupUsualLesson => 'हमेशा की तरह';

  @override
  String get adminSetupNoteField => 'नोट (वैकल्पिक)';

  @override
  String adminSetupDateChangeSaved(String date) {
    return '$date का बदलाव सेव हो गया।';
  }

  @override
  String get adminSetupChooseDateFirst => 'एक तारीख चुनें।';

  @override
  String get adminSetupPreviousDay => 'पिछला दिन';

  @override
  String get adminSetupNextDay => 'अगला दिन';

  @override
  String get adminSetupToday => 'आज';

  @override
  String adminSetupScheduleFor(String date) {
    return '$date के पाठ';
  }

  @override
  String get adminSetupNoLessonsOnDay => 'इस तारीख को कोई पाठ नहीं है।';

  @override
  String adminSetupScheduleSubstitute(String name) {
    return 'शिक्षक: $name (बदले में)';
  }

  @override
  String adminSetupStateLabel(String state) {
    return 'स्थिति: $state';
  }

  @override
  String get adminSetupStateUpcoming => 'आने वाला';

  @override
  String get adminSetupStateLive => 'अभी लाइव';

  @override
  String get adminSetupStateHeld => 'हो गया';

  @override
  String get adminSetupStateCancelled => 'रद्द';

  @override
  String get adminSetupStateNotStarted => 'शुरू नहीं हुआ';

  @override
  String get adminSetupLessonReady => 'पाठ प्लेलिस्ट तैयार है।';

  @override
  String get adminSetupSharedPhoneNote =>
      'साझा फ़ोन पर, हर व्यक्ति पहले साझा फ़ोन नंबर डालता है, फिर अपना छोटा प्रोफ़ाइल नंबर। प्रोफ़ाइल नंबर से सिर्फ़ यह तय होता है कि किसका खाता खुलेगा। यह पासवर्ड नहीं है।';

  @override
  String get adminSetupAddSharedPhone => 'साझा फ़ोन जोड़ें';

  @override
  String get adminSetupEditSharedPhone => 'साझा फ़ोन बदलें';

  @override
  String get adminSetupSharedPhoneName => 'नाम, जैसे कक्षा 5 का फ़ोन';

  @override
  String get adminSetupSharedPhoneNumber => 'साझा फ़ोन नंबर';

  @override
  String get adminSetupSharedPhoneActiveSwitch =>
      'साझा फ़ोन इस्तेमाल किया जा सकता है';

  @override
  String get adminSetupSharedPhoneSaved => 'साझा फ़ोन सेव हो गया।';

  @override
  String get adminSetupNoSharedPhones => 'अभी कोई साझा फ़ोन नहीं है।';

  @override
  String adminSetupGroupNumber(String phone) {
    return 'नंबर: $phone';
  }

  @override
  String adminSetupMemberLine(String name, String role, String code) {
    return '$name, $role। प्रोफ़ाइल नंबर $code';
  }

  @override
  String get adminSetupNoMembers => 'इस फ़ोन पर अभी कोई व्यक्ति नहीं है।';

  @override
  String get adminSetupAddMember => 'व्यक्ति जोड़ें';

  @override
  String adminSetupAddMemberTitle(String group) {
    return '$group में एक व्यक्ति जोड़ें';
  }

  @override
  String get adminSetupSearchPeople => 'नाम या फ़ोन नंबर से लोगों को खोजें';

  @override
  String get adminSetupNoPeopleFound => 'कोई मिलता-जुलता व्यक्ति नहीं मिला।';

  @override
  String get adminSetupPersonField => 'व्यक्ति';

  @override
  String adminSetupPersonOption(String name, String role, String phone) {
    return '$name, $role, $phone';
  }

  @override
  String get adminSetupChoosePerson => 'एक व्यक्ति चुनें।';

  @override
  String get adminSetupProfileCodeField => 'प्रोफ़ाइल नंबर';

  @override
  String get adminSetupProfileCodeHelper =>
      '1 से 4 अंक, इस फ़ोन पर हर व्यक्ति के लिए अलग।';

  @override
  String get adminSetupProfileCodeInvalid =>
      '1 से 4 अंकों का प्रोफ़ाइल नंबर डालें।';

  @override
  String adminSetupMemberAdded(String name, String group) {
    return '$name को $group में जोड़ दिया गया।';
  }

  @override
  String adminSetupRemoveMemberNamed(String name, String group) {
    return '$name को $group से हटाएँ';
  }

  @override
  String adminSetupRemoveMemberTitle(String name, String group) {
    return '$name को $group से हटाएँ?';
  }

  @override
  String adminSetupRemoveMemberMessage(String name) {
    return '$name अब इस साझा फ़ोन पर अपनी प्रोफ़ाइल नहीं चुन पाएँगे।';
  }

  @override
  String adminSetupMemberRemoved(String name, String group) {
    return '$name को $group से हटा दिया गया।';
  }

  @override
  String get adminSetupHolidayNote => 'छुट्टी के दिन कोई पाठ नहीं रखा जाता।';

  @override
  String get adminSetupAddHoliday => 'छुट्टी जोड़ें';

  @override
  String get adminSetupHolidayName => 'छुट्टी का नाम';

  @override
  String get adminSetupNoHolidays => 'अभी कोई छुट्टी नहीं है।';

  @override
  String adminSetupHolidayAdded(String name, String date) {
    return '$date को $name जोड़ दी गई।';
  }

  @override
  String adminSetupDeleteHolidayNamed(String name, String date) {
    return '$date की $name हटाएँ';
  }

  @override
  String get adminSetupDeleteHolidayTitle => 'यह छुट्टी हटाएँ?';

  @override
  String adminSetupDeleteHolidayMessage(String name, String date) {
    return '$date की $name हटा दी जाएगी, और उस दिन फिर से पाठ रखे जाएँगे।';
  }

  @override
  String get adminSetupHolidayDeleted => 'छुट्टी हटा दी गई।';

  @override
  String get adminSetupIssuesOpen => 'खुली';

  @override
  String get adminSetupIssuesResolved => 'हल हो गई';

  @override
  String get adminSetupNoIssues => 'दिखाने के लिए कोई समस्या नहीं है।';

  @override
  String adminSetupIssueSeen(int count, String when) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count बार दिखी।',
      one: 'एक बार दिखी।',
    );
    return '$_temp0 आख़िरी बार $when दिखी।';
  }

  @override
  String get adminSetupMarkResolved => 'हल हुई मानें';

  @override
  String adminSetupMarkResolvedNamed(String message) {
    return 'हल हुई मानें: $message';
  }

  @override
  String get adminSetupIssueResolved => 'समस्या को हल हुई माना गया।';

  @override
  String get adminSetupRecordsLive => 'लाइव';

  @override
  String get adminSetupRecordsEnded => 'ख़त्म';

  @override
  String get adminSetupNoRecords => 'दिखाने के लिए कोई कक्षा नहीं है।';

  @override
  String adminSetupRecordTitle(String subject, String className) {
    return '$subject, $className';
  }

  @override
  String get adminSetupRecordLive => 'अभी लाइव';

  @override
  String adminSetupRecordLiveUntil(String clock) {
    return 'अभी लाइव। $clock पर ख़त्म होगी';
  }

  @override
  String adminSetupRecordStarted(String when) {
    return '$when शुरू हुई';
  }

  @override
  String adminSetupRecordEnded(String when) {
    return '$when ख़त्म हुई';
  }

  @override
  String get adminSetupEndedByTeacher => 'शिक्षक ने कक्षा ख़त्म की।';

  @override
  String get adminSetupEndedByAdmin => 'एक प्रशासक ने कक्षा ख़त्म की।';

  @override
  String get adminSetupEndedAutomatically =>
      'कक्षा अपने तय समय पर अपने आप ख़त्म हो गई।';

  @override
  String adminSetupEndedOther(String reason) {
    return 'ख़त्म होने का कारण: $reason';
  }

  @override
  String adminSetupStudentsJoined(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count छात्र जुड़े।',
      one: '1 छात्र जुड़ा।',
      zero: 'कोई छात्र नहीं जुड़ा।',
    );
    return '$_temp0';
  }

  @override
  String adminSetupExtensionMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count अतिरिक्त मिनट जोड़े गए।',
      one: '1 अतिरिक्त मिनट जोड़ा गया।',
      zero: 'कोई अतिरिक्त समय नहीं जोड़ा गया।',
    );
    return '$_temp0';
  }

  @override
  String get adminSetupAddFifteen => '15 मिनट जोड़ें';

  @override
  String adminSetupAddFifteenNamed(String title) {
    return '$title में 15 मिनट जोड़ें';
  }

  @override
  String get adminSetupEndForEveryone => 'सभी के लिए कक्षा ख़त्म करें';

  @override
  String adminSetupEndForEveryoneNamed(String title) {
    return 'सभी के लिए $title ख़त्म करें';
  }

  @override
  String get adminSetupEndTitle => 'सभी के लिए यह कक्षा ख़त्म करें?';

  @override
  String adminSetupEndMessage(String title) {
    return '$title अभी शिक्षक और हर छात्र के लिए ख़त्म हो जाएगी।';
  }

  @override
  String get adminSetupKeepClass => 'कक्षा चलने दें';

  @override
  String get adminSetupEndClass => 'कक्षा ख़त्म करें';

  @override
  String get adminSetupEnded => 'कक्षा ख़त्म कर दी गई।';

  @override
  String adminSetupExtended(String clock) {
    return 'कक्षा अब $clock पर ख़त्म होगी।';
  }

  @override
  String get loginScreenName => 'साइन इन';

  @override
  String get loginIntro =>
      'अपना फ़ोन नंबर टाइप करें, फिर साइन इन के लिए 1 दबाएँ।';

  @override
  String get loginPhoneField => 'फ़ोन नंबर। इसे नंबर वाले बटनों से टाइप करें।';

  @override
  String get loginPhoneLabel => 'फ़ोन नंबर';

  @override
  String get loginProfileField => 'इस साझा फ़ोन पर आपका प्रोफ़ाइल नंबर';

  @override
  String get loginProfileLabel => 'प्रोफ़ाइल नंबर';

  @override
  String get loginEnterProfileCode =>
      'यह फ़ोन साझा है। अपना प्रोफ़ाइल नंबर टाइप करें, फिर 1 दबाएँ।';

  @override
  String get loginKeySignIn => 'साइन इन';

  @override
  String get loginKeyContinue => 'आगे बढ़ें';

  @override
  String get loginKeySim => 'SIM कार्ड से मेरा नंबर भरें';

  @override
  String get loginKeyAdmin => 'प्रशासक साइन इन';

  @override
  String get loginKeyChangeNumber => 'दूसरा नंबर इस्तेमाल करें';

  @override
  String get loginErrorEnterPhone => 'पहले अपना फ़ोन नंबर टाइप करें।';

  @override
  String get loginErrorEnterProfile => 'पहले अपना प्रोफ़ाइल नंबर टाइप करें।';

  @override
  String get loginNumberNotRegistered =>
      'यह नंबर रजिस्टर नहीं है। अपने स्कूल के प्रशासक से आपको जोड़ने के लिए कहें।';

  @override
  String get loginProfileNotRecognised =>
      'वह प्रोफ़ाइल नंबर इस फ़ोन पर नहीं है। फिर से कोशिश करें।';

  @override
  String get loginAdminUsesPassword =>
      'प्रशासक पासवर्ड से साइन इन करते हैं। 3 दबाएँ।';

  @override
  String get loginSigningIn => 'साइन इन हो रहा है।';

  @override
  String get adminLoginScreenName => 'प्रशासक साइन इन';

  @override
  String get adminLoginIntro =>
      'अपना फ़ोन नंबर और पासवर्ड टाइप करें, फिर 1 दबाएँ।';

  @override
  String get classNoLongerLive => 'वह कक्षा अभी लाइव नहीं है।';

  @override
  String get classAlertTitle => 'कक्षा शुरू हो गई है';

  @override
  String get classAlertBody => 'आपकी कक्षा शुरू हो गई है। जुड़ने के लिए खोलें।';

  @override
  String get classAlertWaitingBody =>
      'आपकी कक्षा लाइव है। जुड़ने के लिए खोलें।';

  @override
  String get classAlertChannelName => 'कक्षा शुरू हो रही है';

  @override
  String get classAlertChannelDescription =>
      'आपकी कक्षा शुरू होने पर एक मिनट तक घंटी बजती है।';

  @override
  String get classAlertWaitingChannelName => 'कक्षा लाइव';

  @override
  String get classAlertWaitingChannelDescription =>
      'जब तक आपकी कक्षा लाइव है, यह दिखती रहती है ताकि आप जुड़ सकें।';

  @override
  String get classAlertStarted => 'आपकी कक्षा शुरू हो गई है।';

  @override
  String classAlertSubjectStarted(String subject) {
    return '$subject की कक्षा शुरू हो गई है।';
  }

  @override
  String get classAlertKeys =>
      'जुड़ने के लिए ओके या 1 दबाएँ। घंटी बंद करने के लिए 0 दबाएँ।';

  @override
  String get classAlertJoin => 'कक्षा में जुड़ें';

  @override
  String get classAlertNotNow => 'अभी नहीं';

  @override
  String get homeTitle => 'होम';

  @override
  String get homeChecking => 'आपकी कक्षा देखी जा रही है।';

  @override
  String get homeOffline =>
      'इंटरनेट नहीं है। इंटरनेट वापस आने पर आपकी कक्षा दिखेगी।';

  @override
  String get homeSignInAgain => 'कृपया फिर से साइन इन करें।';

  @override
  String get homeStarForAll => 'सभी विकल्पों के लिए स्टार दबाएँ।';

  @override
  String homeBriefLive(String subject) {
    return '$subject की कक्षा लाइव है। जुड़ने के लिए 1 दबाएँ।';
  }

  @override
  String homeBriefNext(String subject, String time) {
    return 'अगली कक्षा: $subject, $time बजे। इंतज़ार करते हुए आप दूसरे विकल्प इस्तेमाल कर सकते हैं।';
  }

  @override
  String get homeBriefNoClass =>
      'अभी कोई कक्षा नहीं है। सीखना जारी रखने के लिए 2 दबाएँ।';

  @override
  String homeJoinClass(String subject) {
    return '$subject की कक्षा में जुड़ें';
  }

  @override
  String get homeNoClassNow => 'अभी कोई कक्षा नहीं';

  @override
  String get homeNoClassReason =>
      'जब आपके शिक्षक कक्षा शुरू करेंगे, तो वह यहाँ अपने आप दिखेगी।';

  @override
  String homeJoinWhenStarts(String subject, String time) {
    return '$time बजे शुरू होने पर $subject में अपने आप जुड़ें';
  }

  @override
  String get homeCancelAutoJoin => 'अपने आप जुड़ना बंद करें';

  @override
  String homeAutoJoinArmed(String subject) {
    return 'जब आपके शिक्षक $subject शुरू करेंगे, मैं उसे खोल दूँगा, अगर आप इसी स्क्रीन पर रहें। आप म्यूट होकर जुड़ेंगे। रद्द करने के लिए 1 दबाएँ।';
  }

  @override
  String get homeAutoJoinCancelled => 'अपने आप जुड़ना रद्द हो गया।';

  @override
  String get homeAutoJoinLeft =>
      'अपने आप जुड़ना बंद हो गया क्योंकि आप होम स्क्रीन से चले गए।';

  @override
  String homeAutoJoined(String subject) {
    return '$subject शुरू हो गया है। आपको अभी म्यूट करके जोड़ा जा रहा है।';
  }

  @override
  String get homeReturningToClass => 'आपकी कक्षा में वापस ले जा रहे हैं।';

  @override
  String get homeContinueLearning => 'सीखना जारी रखें';

  @override
  String get homeNothingToContinue =>
      'अभी जारी रखने के लिए कुछ नहीं है। सीखने की यात्राओं के लिए 3 दबाएँ।';

  @override
  String homeContinuing(String title) {
    return '$title जारी है।';
  }

  @override
  String get homeJourneys => 'सीखने की यात्राएँ';

  @override
  String get homeQuizzes => 'क्विज़';

  @override
  String get homeMore => 'और';

  @override
  String get homeMoreBrief => 'कम इस्तेमाल होने वाले विकल्प।';

  @override
  String homeYourClass(String className) {
    return 'आपकी कक्षा: $className।';
  }

  @override
  String homeSubjectInClass(String subject, String className) {
    return '$subject, $className';
  }

  @override
  String teacherHomeBriefLive(String subject) {
    return 'आपकी $subject कक्षा लाइव है। उस पर लौटने के लिए 1 दबाएँ।';
  }

  @override
  String teacherHomeBriefReady(String place) {
    return '$place तैयार है। शुरू करने के लिए 1 दबाएँ।';
  }

  @override
  String teacherHomeBriefNext(String place, String time) {
    return 'अगली कक्षा: $place, $time पर।';
  }

  @override
  String get teacherHomeBriefNoClass =>
      'अभी आपकी समय-सारणी में कोई कक्षा नहीं है।';

  @override
  String teacherHomeReturn(String subject) {
    return '$subject कक्षा पर लौटें';
  }

  @override
  String teacherHomeStart(String place) {
    return '$place शुरू करें';
  }

  @override
  String teacherHomeNext(String place, String time) {
    return 'अगली: $place, $time पर';
  }

  @override
  String teacherHomeOpensAt(String time) {
    return 'आप इसे $time से शुरू कर सकते हैं।';
  }

  @override
  String get teacherHomeNoClassReason =>
      'अभी कुछ तय नहीं है। फिर भी पढ़ाने के लिए, और विकल्पों के लिए 5 दबाएँ, फिर 3।';

  @override
  String get teacherHomeStarting => 'आपकी कक्षा शुरू हो रही है।';

  @override
  String teacherHomeStarted(String subject) {
    return '$subject कक्षा शुरू हो गई। आपके छात्रों को बुलाया जा रहा है।';
  }

  @override
  String get teacherHomeUnscheduled => 'बिना तय समय की कक्षा शुरू करें';

  @override
  String get teacherHomeUnscheduledTitle =>
      'आप अभी कौन सी कक्षा पढ़ाना चाहते हैं?';

  @override
  String get teacherHomeAlreadyLive =>
      'आपकी एक कक्षा पहले से लाइव है। उस पर लौटने के लिए होम पर 1 दबाएँ।';

  @override
  String get teacherHomeChangeWorkspace => 'पाठों के लिए कक्षा और विषय बदलें';

  @override
  String get teacherHomeOneWorkspace => 'आप एक ही कक्षा और विषय पढ़ाते हैं।';

  @override
  String teacherHomeContentFor(String place) {
    return 'पाठ, क्विज़ और प्लेलिस्ट $place के लिए हैं।';
  }

  @override
  String teacherHomeLaterItem(String place, String time) {
    return 'बाद में: $place, $time पर।';
  }

  @override
  String get keyClassListWhoJoined =>
      'कक्षा सूची: कौन यहाँ है, कौन चला गया, कौन नहीं जुड़ा';

  @override
  String get keyMuteAllStudents => 'सभी छात्रों को म्यूट करें';

  @override
  String get keyTeacherToolsAddTimeOrEnd =>
      'शिक्षक टूल: समय बढ़ाएँ या सबके लिए कक्षा खत्म करें';

  @override
  String get sessionMicAskOnce =>
      'आप म्यूट होकर जुड़ते हैं। अब SEEDS माइक्रोफ़ोन इस्तेमाल करने की अनुमति माँगेगा, ताकि आप जब चाहें बोल सकें।';

  @override
  String get sessionMicAskAgain => 'बोलने के लिए माइक्रोफ़ोन की अनुमति दें।';

  @override
  String get sessionMicStillOff =>
      'माइक्रोफ़ोन अभी भी बंद है। आप सुनते रह सकते हैं।';

  @override
  String get sessionMicSettingsTitle => 'माइक्रोफ़ोन रुका हुआ है';

  @override
  String get sessionMicSettingsMessage =>
      'Android फिर से नहीं पूछेगा। बोलने के लिए सेटिंग्स खोलें, अनुमतियाँ चुनें, और माइक्रोफ़ोन की अनुमति दें। आप सुनते रह सकते हैं।';

  @override
  String get sessionMicSettingsOpen => 'सेटिंग्स खोलें';

  @override
  String get sessionMicSettingsCancel => 'सुनते रहें';

  @override
  String get sessionMuteAllButton => '3: सभी छात्रों को म्यूट करें';

  @override
  String get sessionMuteAllLabel => 'सभी छात्रों को म्यूट करें';

  @override
  String get sessionMuteAllWaiting =>
      'अभी सभी को म्यूट किया जा रहा है। कृपया रुकें।';

  @override
  String sessionMuteAllDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count छात्र म्यूट हुए।',
      one: '1 छात्र म्यूट हुआ।',
    );
    return '$_temp0';
  }

  @override
  String get sessionMuteAllNone => 'हर छात्र पहले से म्यूट था।';

  @override
  String sessionMuteAllNotConfirmed(String reason) {
    return 'सभी के म्यूट होने की पुष्टि नहीं हुई। $reason फिर से कोशिश करने के लिए 3 दबाएँ।';
  }

  @override
  String get sessionClassListButton => '4: कक्षा सूची';

  @override
  String sessionClassListLabel(String people) {
    return 'कक्षा सूची। $people';
  }

  @override
  String get sessionClassListTitle => 'कक्षा सूची';

  @override
  String sessionRosterCounts(int here, int left, int notJoined) {
    return '$here यहाँ हैं, $left चले गए, $notJoined अभी नहीं जुड़े।';
  }

  @override
  String sessionHereNow(int count) {
    return 'अभी यहाँ: $count';
  }

  @override
  String sessionLeftClass(int count) {
    return 'जुड़े, फिर चले गए: $count';
  }

  @override
  String sessionNotJoined(int count) {
    return 'अभी नहीं जुड़े: $count';
  }

  @override
  String get sessionHereNowTitle => 'अभी यहाँ';

  @override
  String get sessionLeftClassTitle => 'जुड़े, फिर चले गए';

  @override
  String get sessionNotJoinedTitle => 'अभी नहीं जुड़े';

  @override
  String sessionRemovedName(String name) {
    return '$name, आपने हटाया';
  }

  @override
  String get sessionNobody => 'कोई नहीं।';

  @override
  String get sessionRemindNotJoined => 'जो छात्र नहीं जुड़े, उन्हें घंटी भेजें';

  @override
  String get sessionEveryoneJoined => 'सभी जुड़ गए हैं।';

  @override
  String sessionReminderSent(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count छात्रों को घंटी भेजी जा रही है।',
      one: '1 छात्र को घंटी भेजी जा रही है।',
      zero: 'अभी घंटी भेजने के लिए कोई नहीं है।',
    );
    return '$_temp0';
  }

  @override
  String sessionReminderSentSomeWaiting(int queued, int cooling) {
    return '$queued को घंटी भेजी जा रही है। $cooling को पिछले 5 मिनट में घंटी भेजी गई थी, उन्हें अभी फिर से नहीं भेजी जाएगी।';
  }

  @override
  String get sessionRosterUnavailable =>
      'कक्षा सूची पढ़ी नहीं जा सकी। फिर से कोशिश करें।';

  @override
  String get sessionAddTime => '15 मिनट जोड़ें';

  @override
  String get sessionCannotAddTime =>
      'अगली कक्षा से पहले और समय नहीं जोड़ा जा सकता।';

  @override
  String sessionEndsBy(String clock) {
    return 'कक्षा $clock तक ख़त्म होगी।';
  }

  @override
  String sessionExtendedUntil(String clock) {
    return 'हो गया। कक्षा अब $clock तक ख़त्म होगी।';
  }

  @override
  String sessionEndingSoonTeacher(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: 'कक्षा $minutes मिनट में अपने आप ख़त्म हो जाएगी।',
      one: 'कक्षा 1 मिनट में अपने आप ख़त्म हो जाएगी।',
    );
    return '$_temp0';
  }

  @override
  String sessionEndingSoonTeacherExtend(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other:
          'कक्षा $minutes मिनट में अपने आप ख़त्म हो जाएगी। 15 मिनट जोड़ने के लिए 7 दबाएँ, फिर 1 दबाएँ।',
      one:
          'कक्षा 1 मिनट में अपने आप ख़त्म हो जाएगी। 15 मिनट जोड़ने के लिए 7 दबाएँ, फिर 1 दबाएँ।',
    );
    return '$_temp0';
  }

  @override
  String sessionEndingSoonStudent(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: 'कक्षा $minutes मिनट में ख़त्म हो जाएगी।',
      one: 'कक्षा 1 मिनट में ख़त्म हो जाएगी।',
    );
    return '$_temp0';
  }

  @override
  String get sessionLessonReady =>
      'आज का पाठ तैयार है। कक्षा के लिए चलाने हेतु 5 दबाएँ, फिर 3 दबाएँ।';

  @override
  String get sessionLessonNextReady =>
      'आज के पाठ का अगला हिस्सा तैयार है। इसे चलाने के लिए 6 दबाएँ।';

  @override
  String get sessionJoinedStudentBrief =>
      'आप कक्षा में हैं और म्यूट हैं। बोलने के लिए 1 दबाएँ, हाथ उठाने के लिए 2 दबाएँ।';

  @override
  String get sessionJoinedTeacherBrief =>
      'आपकी कक्षा लाइव है। आप म्यूट हैं। बोलने के लिए 1 दबाएँ, सभी छात्रों को म्यूट करने के लिए 3 दबाएँ।';

  @override
  String get sessionStarForKeys => 'सभी बटनों के लिए स्टार दबाएँ।';

  @override
  String settingsAutoDownload(String state) {
    return 'नई यात्राओं को Wi-Fi पर ऑफ़लाइन उपयोग के लिए तैयार करें: $state';
  }

  @override
  String get settingsAutoDownloadOn => 'यात्राएँ Wi-Fi पर तैयार की जाएँगी।';

  @override
  String get settingsAutoDownloadOff =>
      'यात्राएँ अपने आप तैयार नहीं की जाएँगी।';

  @override
  String get adminSetupTeacherNeedsPair =>
      'शिक्षक के लिए कम से कम एक कक्षा और विषय जोड़ें।';

  @override
  String get adminSetupTeacherHasNoPairs =>
      'अभी किसी शिक्षक के पास कक्षा और विषय नहीं है। पहले लोग में जाकर किसी शिक्षक को कक्षा और विषय दें।';

  @override
  String get adminSetupDaysField => 'दिन';

  @override
  String get adminSetupChooseDays => 'कम से कम एक दिन चुनें।';

  @override
  String adminSetupLessonsAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count पाठ जोड़े गए, हर दिन के लिए एक।',
      one: 'पाठ जोड़ दिया गया।',
    );
    return '$_temp0';
  }

  @override
  String get adminSetupArrangeBy => 'इस हिसाब से लगाएँ';

  @override
  String get adminSetupArrangeDay => 'दिन';

  @override
  String get adminSetupArrangeTeacher => 'शिक्षक';

  @override
  String get adminSetupArrangeClass => 'कक्षा';

  @override
  String adminSetupGroupHeading(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count पाठ',
      one: '1 पाठ',
    );
    return '$name · $_temp0';
  }

  @override
  String adminSetupEntryDayTitle(String day, String title) {
    return '$day, $title';
  }

  @override
  String get adminSetupTimetableSearch => 'पाठ खोजें';

  @override
  String get adminSetupNoMatchingLessons => 'कोई पाठ मेल नहीं खाता।';

  @override
  String get sessionMoreButton => '7: और';

  @override
  String get sessionMoreLabel => 'और विकल्प';

  @override
  String get sessionMoreTitle => 'और विकल्प';

  @override
  String get sessionMoreClassroomCheck => 'कक्षा जाँच';

  @override
  String get sessionMoreStatus => 'कक्षा की स्थिति';

  @override
  String get sessionMoreWhatIsPlaying => 'क्या चल रहा है';

  @override
  String get sessionMoreWhoIsHere => 'कक्षा में कौन है';

  @override
  String get sessionKeyRaisedHands => 'उठे हुए हाथ';

  @override
  String get sessionKeyClassList => 'कक्षा सूची';

  @override
  String get sessionKeyLessonRecording => 'पाठ की रिकॉर्डिंग';

  @override
  String get sessionKeyAnswerQuestion => 'प्रश्न का उत्तर दें';

  @override
  String get sessionKeyMore => 'और विकल्प';

  @override
  String get sessionKeyLeave => 'कक्षा छोड़ें';

  @override
  String get sessionEndClassButton => '8: सभी के लिए कक्षा ख़त्म करें';

  @override
  String get sessionEndClassLabel =>
      'सभी के लिए कक्षा ख़त्म करें। पुष्टि माँगी जाएगी';

  @override
  String sessionActivityQuizItem(String title, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count प्रश्न',
      one: '1 प्रश्न',
    );
    return 'क्विज़: $title, $_temp0';
  }

  @override
  String sessionActivityJourneyItem(String title) {
    return 'यात्रा: $title';
  }

  @override
  String sessionActivityStopItem(String title) {
    return '$title देना बंद करें';
  }

  @override
  String sessionActivityStartedTeacher(String title) {
    return '$title कक्षा के लिए खुला है। इसकी स्थिति के लिए 6 दबाएँ।';
  }

  @override
  String sessionActivityStoppedTeacher(String title) {
    return '$title अब कक्षा में नहीं दिया जा रहा। छात्र इसे अब भी होम पर पा सकते हैं।';
  }

  @override
  String sessionActivityQuizStarted(String title) {
    return 'आपके शिक्षक ने एक क्विज़ शुरू किया: $title। शुरू करने के लिए 4 दबाएँ।';
  }

  @override
  String sessionActivityJourneyStarted(String title) {
    return 'आपके शिक्षक ने एक यात्रा शुरू की: $title। शुरू करने के लिए 4 दबाएँ।';
  }

  @override
  String sessionActivityStoppedStudent(String title) {
    return '$title कक्षा में बंद हो गया है। आप इसे अब भी होम पर पा सकते हैं।';
  }

  @override
  String sessionActivityStartQuizLabel(String title) {
    return 'क्विज़ $title शुरू करें';
  }

  @override
  String sessionActivityStartJourneyLabel(String title) {
    return 'यात्रा $title शुरू करें';
  }

  @override
  String sessionActivityStateStudent(String title) {
    return '$title खुला है।';
  }

  @override
  String sessionActivityStateTeacher(String title) {
    return '$title कक्षा के लिए खुला है।';
  }

  @override
  String sessionActivityOpening(String title) {
    return '$title खुल रहा है।';
  }

  @override
  String sessionActivityCouldNotOpen(String title) {
    return '$title खुल नहीं सका। अपना कनेक्शन जाँचें और फिर से कोशिश करें।';
  }

  @override
  String get sessionBackInClass => 'कक्षा में वापस।';

  @override
  String sessionActivityProgress(String title, int started, int finished) {
    return '$title: $started ने शुरू किया, $finished ने पूरा किया।';
  }

  @override
  String get sessionWhatIsPlayingButton => '3: क्या चल रहा है';

  @override
  String get sessionKeyEndClass => 'सभी के लिए कक्षा ख़त्म करें';

  @override
  String get sessionKeyWhatIsPlaying => 'क्या चल रहा है';

  @override
  String get sessionQuizButton => '6: क्विज़';

  @override
  String get sessionJourneyButton => '7: यात्रा';

  @override
  String get sessionQuizLabel => 'कक्षा के लिए क्विज़ शुरू करें';

  @override
  String get sessionJourneyLabel => 'कक्षा के लिए यात्रा शुरू करें';

  @override
  String sessionOpenLabel(String title) {
    return '$title खुला है। सुनें कि कौन बाकी है, उन्हें याद दिलाएँ, या इसे बंद करें';
  }

  @override
  String get sessionKeyQuiz => 'कक्षा के लिए क्विज़';

  @override
  String get sessionKeyJourney => 'कक्षा के लिए यात्रा';

  @override
  String sessionStartQuizButton(String title) {
    return '4: क्विज़ शुरू करें: $title';
  }

  @override
  String sessionStartJourneyButton(String title) {
    return '4: यात्रा शुरू करें: $title';
  }

  @override
  String get sessionPickQuizTitle => 'कक्षा के लिए क्विज़ शुरू करें';

  @override
  String get sessionPickJourneyTitle => 'कक्षा के लिए यात्रा शुरू करें';

  @override
  String get sessionNoQuizToStart =>
      'इस कक्षा और विषय के लिए कोई प्रकाशित क्विज़ खुला नहीं है। पहले होम पर क्विज़ में जाकर एक प्रकाशित करें।';

  @override
  String get sessionNoJourneyToStart =>
      'इस कक्षा और विषय के लिए कोई प्रकाशित यात्रा नहीं है। पहले होम पर यात्राएँ में जाकर एक प्रकाशित करें।';

  @override
  String sessionFinishedOf(int finished, int enrolled) {
    return '$enrolled में से $finished ने पूरा किया।';
  }

  @override
  String sessionLeftInClass(int count) {
    return 'कक्षा में, पूरा नहीं किया ($count)';
  }

  @override
  String sessionLeftWholeClass(int count) {
    return 'पूरी कक्षा, पूरा नहीं किया ($count)';
  }

  @override
  String get sessionLeftInClassTitle => 'कक्षा में, पूरा नहीं किया';

  @override
  String get sessionLeftWholeClassTitle => 'पूरी कक्षा, पूरा नहीं किया';

  @override
  String get sessionRemindLeft =>
      'कक्षा में जिन्होंने पूरा नहीं किया, उन्हें याद दिलाएँ';

  @override
  String get sessionStartDifferentQuiz => 'दूसरा क्विज़ शुरू करें';

  @override
  String get sessionStartDifferentJourney => 'दूसरी यात्रा शुरू करें';

  @override
  String sessionLeftNotStarted(String name) {
    return '$name, शुरू नहीं किया';
  }

  @override
  String sessionLeftStarted(String name) {
    return '$name, शुरू किया, पूरा नहीं किया';
  }

  @override
  String get sessionLeftHere => 'कक्षा में';

  @override
  String get sessionLeftAway => 'कक्षा में नहीं';

  @override
  String get sessionLeftNobodyInClass =>
      'कक्षा में मौजूद सभी ने पूरा कर लिया है।';

  @override
  String get sessionLeftNobody => 'कक्षा के सभी छात्रों ने पूरा कर लिया है।';

  @override
  String sessionRemindedLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count छात्रों को याद दिलाया।',
      one: '1 छात्र को याद दिलाया।',
      zero: 'कक्षा में किसी को याद दिलाने की ज़रूरत नहीं है।',
    );
    return '$_temp0';
  }

  @override
  String sessionActivityReminderQuiz(String title) {
    return 'आपके शिक्षक आपको क्विज़ $title करने की याद दिला रहे हैं। शुरू करने के लिए 4 दबाएँ।';
  }

  @override
  String sessionActivityReminderJourney(String title) {
    return 'आपके शिक्षक आपको यात्रा $title करने की याद दिला रहे हैं। शुरू करने के लिए 4 दबाएँ।';
  }

  @override
  String get sessionKeyStartActivity => 'क्विज़ या यात्रा शुरू करें';

  @override
  String get startupSettingsKey2 => '2. सेटिंग्स';

  @override
  String get libraryPauseSessionKey3 => 'पूरे सत्र के लिए ऑडियो रोकें, बटन 3';

  @override
  String get authSaveNewPasswordKey1 => '1: नया पासवर्ड सेव करें';

  @override
  String get quizSaveSettingsKey1 => '1: सेटिंग्स सेव करें';

  @override
  String get quizSaveQuestionKey1 => '1: प्रश्न सेव करें';

  @override
  String get quizContinueToQuestionsKey1 => '1: प्रश्नों पर आगे बढ़ें';

  @override
  String get adminAuthorSection => 'क्विज़ और यात्राएँ';

  @override
  String get adminAuthorNote =>
      'किसी शिक्षक के लिए क्विज़ और सीखने की यात्राएँ बनाएँ और प्रकाशित करें। आप जो भी बनाते हैं वह उसी शिक्षक का होता है, उसमें सिर्फ़ उनका प्रश्न बैंक और उनकी अपनी रिकॉर्डिंग इस्तेमाल होती हैं, और शिक्षक को उनके होम पर इसकी जानकारी दी जाती है।';

  @override
  String get adminAuthorTeacher => 'शिक्षक';

  @override
  String get adminAuthorWorkspace => 'कक्षा और विषय';

  @override
  String adminAuthorWorkspaceName(String className, String subjectName) {
    return '$className, $subjectName';
  }

  @override
  String get adminAuthorNoTeachers =>
      'अभी किसी शिक्षक के पास कक्षा और विषय नहीं है। पहले खाते में जाकर एक दें।';

  @override
  String get adminAuthorKind => 'दिखाएँ';

  @override
  String get adminAuthorKindQuizzes => 'क्विज़';

  @override
  String get adminAuthorKindJourneys => 'यात्राएँ';

  @override
  String get adminAuthorNewQuiz => 'नया क्विज़';

  @override
  String get adminAuthorNewJourney => 'नई यात्रा';

  @override
  String adminAuthorNewQuizFor(String teacher) {
    return '$teacher के लिए नया क्विज़';
  }

  @override
  String adminAuthorNewJourneyFor(String teacher) {
    return '$teacher के लिए नई यात्रा';
  }

  @override
  String get adminAuthorNoQuizzes =>
      'इस शिक्षक के पास इस कक्षा और विषय के लिए कोई क्विज़ नहीं है।';

  @override
  String get adminAuthorNoJourneys =>
      'इस शिक्षक के पास इस कक्षा और विषय के लिए कोई यात्रा नहीं है।';

  @override
  String get adminAuthorStatusDraft => 'ड्राफ़्ट';

  @override
  String get adminAuthorStatusPublished => 'प्रकाशित';

  @override
  String get adminAuthorStatusScheduled => 'प्रकाशित, बाद में खुलेगा';

  @override
  String get adminAuthorStatusClosed => 'बंद';

  @override
  String get adminAuthorStatusArchived => 'संग्रहित';

  @override
  String adminAuthorStatusChanged(String status) {
    return '$status, कुछ बदलाव अभी प्रकाशित नहीं हुए';
  }

  @override
  String adminAuthorQuestionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count प्रश्न',
      one: '1 प्रश्न',
    );
    return '$_temp0';
  }

  @override
  String adminAuthorStepCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count चरण',
      one: '1 चरण',
    );
    return '$_temp0';
  }

  @override
  String get adminAuthorMode => 'क्विज़ का प्रकार';

  @override
  String get adminAuthorModeGraded => 'अंक वाला';

  @override
  String get adminAuthorModePractice => 'अभ्यास';

  @override
  String get adminAuthorEdit => 'बदलें';

  @override
  String adminAuthorEditNamed(String title) {
    return '$title बदलें';
  }

  @override
  String get adminAuthorPublish => 'प्रकाशित करें';

  @override
  String adminAuthorPublishNamed(String title) {
    return '$title प्रकाशित करें';
  }

  @override
  String get adminAuthorClose => 'क्विज़ बंद करें';

  @override
  String adminAuthorCloseNamed(String title) {
    return '$title बंद करें';
  }

  @override
  String get adminAuthorArchive => 'संग्रहित करें';

  @override
  String adminAuthorArchiveNamed(String title) {
    return '$title संग्रहित करें';
  }

  @override
  String get adminAuthorPublishQuizTitle => 'यह क्विज़ प्रकाशित करें?';

  @override
  String adminAuthorPublishQuizMessage(String title, String teacher) {
    return '$title कक्षा के लिए $teacher की क्विज़ के रूप में खुल जाएगी, और छात्रों को सूचना भेजी जाएगी।';
  }

  @override
  String get adminAuthorPublishJourneyTitle => 'यह यात्रा प्रकाशित करें?';

  @override
  String adminAuthorPublishJourneyMessage(String title, String teacher) {
    return '$title कक्षा के लिए $teacher की यात्रा के रूप में उपलब्ध होगी, और छात्रों को सूचना भेजी जाएगी।';
  }

  @override
  String get adminAuthorCloseQuizTitle => 'यह क्विज़ बंद करें?';

  @override
  String adminAuthorCloseQuizMessage(String title) {
    return 'छात्र अब $title के उत्तर नहीं दे पाएँगे। अधूरे प्रयास जैसे हैं वैसे ही जमा हो जाएँगे।';
  }

  @override
  String get adminAuthorArchiveTitle => 'यह यात्रा संग्रहित करें?';

  @override
  String adminAuthorArchiveMessage(String title) {
    return 'छात्रों को अब $title नहीं दिखेगी।';
  }

  @override
  String adminAuthorPublished(String title) {
    return '$title प्रकाशित हो गई।';
  }

  @override
  String adminAuthorClosed(String title) {
    return '$title बंद हो गई।';
  }

  @override
  String adminAuthorArchived(String title) {
    return '$title संग्रहित हो गई।';
  }

  @override
  String adminAuthorCreated(String title) {
    return '$title ड्राफ़्ट के रूप में बन गई।';
  }

  @override
  String get adminAuthorSaved => 'यात्रा सेव हो गई।';

  @override
  String adminAuthorNotReady(String problems) {
    return 'यह क्विज़ अभी प्रकाशित करने के लिए तैयार नहीं है। $problems';
  }

  @override
  String get adminAuthorTitle => 'शीर्षक';

  @override
  String get adminAuthorDescription => 'विवरण (वैकल्पिक)';

  @override
  String get adminAuthorQuizSettings => 'क्विज़ सेटिंग्स';

  @override
  String adminAuthorEditQuiz(String title) {
    return 'क्विज़ बदलें: $title';
  }

  @override
  String adminAuthorEditJourney(String title) {
    return 'यात्रा बदलें: $title';
  }

  @override
  String get adminAuthorQuestions => 'प्रश्न';

  @override
  String get adminAuthorNoQuestions => 'अभी कोई प्रश्न नहीं है।';

  @override
  String adminAuthorQuestionLine(int number, String text) {
    return '$number. $text';
  }

  @override
  String adminAuthorCorrectAnswer(String answer) {
    return 'सही उत्तर: $answer';
  }

  @override
  String get adminAuthorRemove => 'हटाएँ';

  @override
  String adminAuthorRemoveNamed(String item) {
    return '$item हटाएँ';
  }

  @override
  String get adminAuthorAddNewQuestion => 'नया प्रश्न लिखें';

  @override
  String get adminAuthorAddBankQuestion => 'प्रश्न बैंक से जोड़ें';

  @override
  String get adminAuthorQuestionText => 'प्रश्न';

  @override
  String adminAuthorOption(int number) {
    return 'विकल्प $number';
  }

  @override
  String adminAuthorOptionalOption(int number) {
    return 'विकल्प $number (वैकल्पिक)';
  }

  @override
  String get adminAuthorCorrectOption => 'सही उत्तर';

  @override
  String get adminAuthorCorrectIsBlank =>
      'सही उत्तर खाली है। उसे भरें या कोई दूसरा विकल्प चुनें।';

  @override
  String get adminAuthorExplanation => 'व्याख्या (वैकल्पिक)';

  @override
  String get adminAuthorSaveToBank => 'शिक्षक के प्रश्न बैंक में भी सेव करें';

  @override
  String get adminAuthorNeedFourOptions => 'चारों विकल्प भरें।';

  @override
  String get adminAuthorNeedTwoOptions => 'कम से कम दो विकल्प भरें।';

  @override
  String get adminAuthorDuplicateOptions => 'हर विकल्प अलग होना चाहिए।';

  @override
  String adminAuthorRequired(String field) {
    return '$field ज़रूरी है।';
  }

  @override
  String get adminAuthorAdd => 'जोड़ें';

  @override
  String adminAuthorAddNamed(String item) {
    return '$item जोड़ें';
  }

  @override
  String get adminAuthorBankTitle => 'शिक्षक का प्रश्न बैंक';

  @override
  String get adminAuthorBankEmpty =>
      'इस शिक्षक के पास इस कक्षा और विषय के लिए कोई सेव किया हुआ प्रश्न नहीं है।';

  @override
  String get adminAuthorDone => 'हो गया';

  @override
  String get adminAuthorGraded => 'अंक वाला: प्रश्नों के अंक दें';

  @override
  String get adminAuthorRetries => 'गलत उत्तर के बाद दोबारा प्रयास';

  @override
  String get adminAuthorSteps => 'चरण';

  @override
  String get adminAuthorNoSteps => 'अभी कोई चरण नहीं है।';

  @override
  String adminAuthorStepRecording(String title) {
    return 'रिकॉर्डिंग: $title';
  }

  @override
  String adminAuthorStepNarration(String text) {
    return 'वर्णन: $text';
  }

  @override
  String adminAuthorStepQuestion(String text) {
    return 'प्रश्न: $text';
  }

  @override
  String adminAuthorStepPoll(String text) {
    return 'पोल: $text';
  }

  @override
  String get adminAuthorMoveUp => 'ऊपर ले जाएँ';

  @override
  String adminAuthorMoveUpNamed(String item) {
    return '$item को ऊपर ले जाएँ';
  }

  @override
  String get adminAuthorMoveDown => 'नीचे ले जाएँ';

  @override
  String adminAuthorMoveDownNamed(String item) {
    return '$item को नीचे ले जाएँ';
  }

  @override
  String get adminAuthorAddRecording => 'रिकॉर्डिंग जोड़ें';

  @override
  String get adminAuthorAddNarration => 'वर्णन जोड़ें';

  @override
  String get adminAuthorAddQuestion => 'प्रश्न जोड़ें';

  @override
  String get adminAuthorAddPoll => 'पोल जोड़ें';

  @override
  String get adminAuthorRecordingsTitle => 'शिक्षक की रिकॉर्डिंग';

  @override
  String get adminAuthorRecordingsNote =>
      'केवल वही रिकॉर्डिंग इस्तेमाल हो सकती हैं जो इस शिक्षक ने इस कक्षा और विषय के लिए अपलोड की हैं।';

  @override
  String get adminAuthorNoRecordings =>
      'इस शिक्षक ने इस कक्षा और विषय के लिए कोई रिकॉर्डिंग अपलोड नहीं की है।';

  @override
  String get adminAuthorNarrationText => 'वर्णन का टेक्स्ट';

  @override
  String get adminAuthorPollText => 'पोल का प्रश्न';

  @override
  String get adminAuthorSaveJourney => 'यात्रा सेव करें';

  @override
  String teacherHomeNotice(String kind, String title, String action) {
    return '$kind $title: आपके प्रशासक ने आपके लिए $action।';
  }

  @override
  String get teacherHomeNoticeQuiz => 'क्विज़';

  @override
  String get teacherHomeNoticeJourney => 'यात्रा';

  @override
  String get teacherHomeNoticeCreated => 'जोड़ा';

  @override
  String get teacherHomeNoticePublished => 'प्रकाशित किया';

  @override
  String get teacherHomeNoticeClosed => 'बंद किया';

  @override
  String get teacherHomeNoticeArchived => 'संग्रहित किया';

  @override
  String sessionPeopleJoined(String names) {
    return '$names जुड़ गए।';
  }

  @override
  String sessionPeopleLeft(String names) {
    return '$names चले गए।';
  }

  @override
  String sessionNamesAnd(String first, String last) {
    return '$first और $last';
  }

  @override
  String sessionHereOf(int here, int total) {
    return '$total में से $here यहाँ हैं।';
  }

  @override
  String sessionHereCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count छात्र यहाँ हैं।',
      one: '1 छात्र यहाँ है।',
      zero: 'यहाँ कोई छात्र नहीं है।',
    );
    return '$_temp0';
  }

  @override
  String sessionStartSummary(int here, int total) {
    return '$total में से $here छात्र यहाँ हैं।';
  }

  @override
  String uiFocusedField(String field) {
    return 'आप $field में हैं।';
  }

  @override
  String get sessionStartButton => '5: शुरू करें';

  @override
  String get sessionStartLabel =>
      'कक्षा के लिए क्विज़, यात्रा या रिकॉर्डिंग शुरू करें';

  @override
  String get sessionStartTitle => 'कक्षा के लिए शुरू करें';

  @override
  String get sessionStartQuiz => 'क्विज़';

  @override
  String get sessionStartJourney => 'यात्रा';

  @override
  String get sessionStartRecording => 'रिकॉर्डिंग';

  @override
  String sessionStatusKeyButton(String title) {
    return '6: $title की स्थिति';
  }

  @override
  String sessionStatusKeyLabel(String title) {
    return '$title की स्थिति';
  }

  @override
  String get sessionKeyStart => 'क्विज़, यात्रा या रिकॉर्डिंग शुरू करें';

  @override
  String get sessionKeyStatus => 'जो चल रहा है उसकी स्थिति';

  @override
  String sessionActivityCounts(int present, int started, int finished) {
    return 'कक्षा में $present छात्र हैं। $started ने प्रयास किया है, $finished ने पूरा किया।';
  }

  @override
  String get sessionNowPlayingTitle => 'रिकॉर्डिंग';
}
