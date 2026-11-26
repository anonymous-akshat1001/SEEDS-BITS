// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get spokenDigitWords =>
      'শূন্য, এক, দুই, তিন, চার, পাঁচ, ছয়, সাত, আট, নয়';

  @override
  String get spokenMonths =>
      'জানুয়ারি, ফেব্রুয়ারি, মার্চ, এপ্রিল, মে, জুন, জুলাই, আগস্ট, সেপ্টেম্বর, অক্টোবর, নভেম্বর, ডিসেম্বর';

  @override
  String get spokenWeekdays =>
      'সোমবার, মঙ্গলবার, বুধবার, বৃহস্পতিবার, শুক্রবার, শনিবার, রবিবার';

  @override
  String get spokenPlus => 'প্লাস';

  @override
  String spokenSession(String number) {
    return 'সেশন $number';
  }

  @override
  String get spokenNoon => 'দুপুর 12টা';

  @override
  String get spokenMidnight => 'মাঝরাত';

  @override
  String spokenOClock(String hour) {
    return '$hourটা';
  }

  @override
  String spokenMorning(String clock) {
    return 'সকাল $clock';
  }

  @override
  String spokenAfternoon(String clock) {
    return 'দুপুর $clock';
  }

  @override
  String spokenEvening(String clock) {
    return 'সন্ধ্যা $clock';
  }

  @override
  String spokenNight(String clock) {
    return 'রাত $clock';
  }

  @override
  String get spokenToday => 'আজ';

  @override
  String get spokenTomorrow => 'আগামীকাল';

  @override
  String get spokenYesterday => 'গতকাল';

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
      other: '$count ঘণ্টা',
      one: '1 ঘণ্টা',
    );
    return '$_temp0';
  }

  @override
  String spokenMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count মিনিট',
      one: '1 মিনিট',
    );
    return '$_temp0';
  }

  @override
  String spokenSeconds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count সেকেন্ড',
      one: '1 সেকেন্ড',
    );
    return '$_temp0';
  }

  @override
  String spokenPositionOf(String position, String total) {
    return '$total-এর মধ্যে $position';
  }

  @override
  String spokenPercent(String value) {
    return '$value শতাংশ';
  }

  @override
  String get spokenOn => 'চালু';

  @override
  String get spokenOff => 'বন্ধ';

  @override
  String get keyBack10Seconds => '10 সেকেন্ড পিছনে';

  @override
  String get keyPlayOrPause => 'চালান বা থামান';

  @override
  String get keyForward10Seconds => '10 সেকেন্ড সামনে';

  @override
  String get keySlower => 'ধীরে';

  @override
  String get keyFaster => 'দ্রুত';

  @override
  String get keySlowerPlaybackSpeed => 'চালানোর গতি কমান';

  @override
  String get keyFasterPlaybackSpeed => 'চালানোর গতি বাড়ান';

  @override
  String get keyLogin => 'লগইন';

  @override
  String get keyRegister => 'নিবন্ধন';

  @override
  String get keySettings => 'সেটিংস';

  @override
  String get keySelectStudentAccount => 'শিক্ষার্থী অ্যাকাউন্ট বেছে নিন';

  @override
  String get keySelectTeacherAccount => 'শিক্ষক অ্যাকাউন্ট বেছে নিন';

  @override
  String get keySelectAdministratorAccount => 'প্রশাসক অ্যাকাউন্ট বেছে নিন';

  @override
  String get keyGoToLogin => 'লগইনে যান';

  @override
  String get keyToggleTeacherRegistration => 'শিক্ষক নিবন্ধন চালু বা বন্ধ করুন';

  @override
  String get keyGoBack => 'ফিরে যান';

  @override
  String get keyToggleTTS => 'টি টি এস চালু বা বন্ধ করুন';

  @override
  String get keyToggleVoiceCommands => 'ভয়েস কমান্ড চালু বা বন্ধ করুন';

  @override
  String get keyShowOrHideShortcuts => 'শর্টকাট দেখান বা লুকান';

  @override
  String get keyToggleHighContrast => 'হাই কনট্রাস্ট চালু বা বন্ধ করুন';

  @override
  String get keyTestTTS => 'টি টি এস পরীক্ষা করুন';

  @override
  String get keySaveSettings => 'সেটিংস সেভ করুন';

  @override
  String get keyCheckVoice => 'কণ্ঠস্বর যাচাই করুন';

  @override
  String get keySoundCuesOnOrOff => 'সাউন্ড সংকেত চালু বা বন্ধ';

  @override
  String get keyVibrationOnOrOff => 'ভাইব্রেশন চালু বা বন্ধ';

  @override
  String get keyLogOutAsksToConfirm => 'লগ আউট, নিশ্চিত করতে বলবে';

  @override
  String get keyRefreshSessions => 'সেশন রিফ্রেশ করুন';

  @override
  String get keySearchSessionsByNameOrID => 'নাম বা ID দিয়ে সেশন খুঁজুন';

  @override
  String get keyRecordedAudioLibrary => 'রেকর্ড করা অডিও লাইব্রেরি';

  @override
  String get keyMyPrivatePlaylists => 'আমার ব্যক্তিগত প্লেলিস্ট';

  @override
  String get keyQuizzes => 'কুইজ';

  @override
  String get keyLearningJourneys => 'শেখার যাত্রা';

  @override
  String get keyCreateSession => 'সেশন তৈরি করুন';

  @override
  String get keyClassPlaylists => 'ক্লাস প্লেলিস্ট';

  @override
  String get keyChooseClassAndSubjectWorkspace =>
      'ক্লাস ও বিষয়ের ওয়ার্কস্পেস বেছে নিন';

  @override
  String get keyRefresh => 'রিফ্রেশ করুন';

  @override
  String get keySearchUsers => 'ব্যবহারকারী খুঁজুন';

  @override
  String get keyChangeAccountTypeFilter => 'অ্যাকাউন্টের ধরন ফিল্টার বদলান';

  @override
  String get keyChangeAssignmentFilter => 'বরাদ্দ ফিল্টার বদলান';

  @override
  String get keyCreateSubject => 'বিষয় তৈরি করুন';

  @override
  String get keyCreateClass => 'ক্লাস তৈরি করুন';

  @override
  String get keyChooseAccountsClassesOrSubjectsSection =>
      'অ্যাকাউন্ট, ক্লাস বা বিষয় বিভাগ বেছে নিন';

  @override
  String get keyGoBackAlt => 'ফিরে যান';

  @override
  String get keyCreateBankQuestion => 'প্রশ্ন ব্যাংকের প্রশ্ন তৈরি করুন';

  @override
  String get keyCreateQuizDraft => 'কুইজের খসড়া তৈরি করুন';

  @override
  String get keyCreateUntimedUngradedPractice =>
      'সময়সীমা ও নম্বর ছাড়া অনুশীলন তৈরি করুন';

  @override
  String get keyRefreshQuizzes => 'কুইজ রিফ্রেশ করুন';

  @override
  String get keyChooseOption1 => 'বিকল্প 1 বেছে নিন';

  @override
  String get keyChooseOption2 => 'বিকল্প 2 বেছে নিন';

  @override
  String get keyChooseOption3 => 'বিকল্প 3 বেছে নিন';

  @override
  String get keyChooseOption4 => 'বিকল্প 4 বেছে নিন';

  @override
  String get keySubmitSelectedAnswer => 'বেছে নেওয়া উত্তর জমা দিন';

  @override
  String get keyRepeatQuestionAndOptions => 'প্রশ্ন ও বিকল্পগুলি আবার শুনুন';

  @override
  String get keySlowerQuizSpeech => 'কুইজের কণ্ঠস্বর ধীরে';

  @override
  String get keyWhereAmIIncludingTimeLeft => 'আমি কোথায় আছি, বাকি সময় সহ';

  @override
  String get keyFasterQuizSpeech => 'কুইজের কণ্ঠস্বর দ্রুত';

  @override
  String get keyMuteOrUnmute => 'মিউট বা আনমিউট';

  @override
  String get keyRaiseOrLowerHand => 'হাত তুলুন বা হাত নামান';

  @override
  String get keyHearClassStatus => 'ক্লাসের অবস্থা শুনুন';

  @override
  String get keyChat => 'চ্যাট';

  @override
  String get keyHearWhatTheTeacherIsPlaying => 'শিক্ষক কী চালাচ্ছেন তা শুনুন';

  @override
  String get keyAnswerClassroomCheck => 'ক্লাস যাচাইয়ের উত্তর দিন';

  @override
  String get keyWhoIsInTheClass => 'ক্লাসে কে কে আছে';

  @override
  String get keyLeaveSessionAsksToConfirm =>
      'সেশন ছেড়ে যান, নিশ্চিত করতে বলবে';

  @override
  String get keyRaisedHandsAcknowledgeAndLowerThemInOrder =>
      'তোলা হাত: ক্রম অনুযায়ী সাড়া দিন এবং নামান';

  @override
  String get keyClassRecordingPlayerPlayAndControlTheRecording =>
      'ক্লাস রেকর্ডিং প্লেয়ার: রেকর্ডিং চালান ও নিয়ন্ত্রণ করুন';

  @override
  String get keyClassroomCheckStartCloseAndHearResponses =>
      'ক্লাস যাচাই: শুরু করুন, বন্ধ করুন এবং উত্তর শুনুন';

  @override
  String get keyParticipantsMuteOrRemoveSomeone =>
      'অংশগ্রহণকারী: কাউকে মিউট করুন বা সরিয়ে দিন';

  @override
  String get keyTeacherToolsInviteStudentsEndClassForEveryone =>
      'শিক্ষকের টুল: শিক্ষার্থীদের আমন্ত্রণ জানান, সবার জন্য ক্লাস শেষ করুন';

  @override
  String get keyRefreshClasses => 'ক্লাস রিফ্রেশ করুন';

  @override
  String get keySearchClassByName => 'নাম দিয়ে ক্লাস খুঁজুন';

  @override
  String get keyAllAudioFiles => 'সব অডিও ফাইল';

  @override
  String get keyFocusFirstActiveClassUseDPadToBrowseClasses =>
      'প্রথম চালু ক্লাসে যান; ক্লাসগুলি দেখতে D-pad ব্যবহার করুন';

  @override
  String get keyRefreshFiles => 'ফাইল রিফ্রেশ করুন';

  @override
  String get keyNextSubjectFilter => 'পরের বিষয় ফিল্টার';

  @override
  String get keyStopPlayback => 'চালানো বন্ধ করুন';

  @override
  String get keyAddAudioFile => 'অডিও ফাইল যোগ করুন';

  @override
  String get keyUploadNewFile => 'নতুন ফাইল আপলোড করুন';

  @override
  String get keySelectFromExistingLibrary => 'আগের লাইব্রেরি থেকে বেছে নিন';

  @override
  String get keyRefreshList => 'তালিকা রিফ্রেশ করুন';

  @override
  String get appName => 'SEEDS';

  @override
  String get languageEnglish => 'ইংরেজি';

  @override
  String get languageHindi => 'হিন্দি';

  @override
  String get languageKannada => 'কন্নড়';

  @override
  String get languageTelugu => 'তেলুগু';

  @override
  String get languageBengali => 'বাংলা';

  @override
  String get commonPleaseWait => 'দয়া করে অপেক্ষা করুন। কাজ চলছে।';

  @override
  String get commonSignInFirst => 'দয়া করে আগে সাইন ইন করুন।';

  @override
  String get commonAccountChanged =>
      'এই ফোনে আপনার অ্যাকাউন্ট বদলে গেছে। আবার সাইন ইন করুন।';

  @override
  String get commonNoWorkspace =>
      'কোনো ক্লাস ও বিষয় বেছে নেওয়া হয়নি। ওয়ার্কস্পেস বেছে নিতে 7 টিপুন।';

  @override
  String get commonNoConnection =>
      'স্কুলের সার্ভারের সাথে সংযোগ নেই। আপনার ইন্টারনেট যাচাই করে আবার চেষ্টা করুন।';

  @override
  String get commonNotAvailable => 'এটি এখন পাওয়া যাচ্ছে না।';

  @override
  String get commonNothingChanged => 'কিছুই বদলানো হয়নি।';

  @override
  String get commonNoMessages => 'এই স্ক্রিনে কোনো বার্তা নেই।';

  @override
  String get commonEndOfList => 'তালিকা শেষ। প্রথম আইটেমে ফিরে যাওয়া হল।';

  @override
  String get commonTopOfList => 'তালিকার শুরু। শেষ আইটেমে যাওয়া হল।';

  @override
  String commonOpening(String what) {
    return '$what খোলা হচ্ছে।';
  }

  @override
  String commonOpeningNeedsInternet(String what) {
    return '$what খোলা হচ্ছে। ইন্টারনেট লাগবে।';
  }

  @override
  String commonUnavailable(String what) {
    return '$what পাওয়া যাচ্ছে না।';
  }

  @override
  String commonUnavailableBecause(String what, String reason) {
    return '$what পাওয়া যাচ্ছে না। $reason';
  }

  @override
  String commonWhereScreen(String screen) {
    return '$screen।';
  }

  @override
  String commonWhereFocused(String item) {
    return 'এখন আছেন: $item।';
  }

  @override
  String get keypadStarForShortcuts => 'সব শর্টকাটের জন্য স্টার টিপুন।';

  @override
  String keypadScreenReaderIntro(String screen) {
    return '$screen। কীপ্যাড সাহায্যের জন্য স্টার টিপুন।';
  }

  @override
  String keypadMoveThroughSections(String sections) {
    return '$sections-এর মধ্যে যেতে D-pad উপর ও নিচ ব্যবহার করুন। বেছে নেওয়া কন্ট্রোল চালু করতে ওকে টিপুন।';
  }

  @override
  String get keypadEssentialMove =>
      'যেতে উপর ও নিচ ব্যবহার করুন, এবং বেছে নিতে ওকে টিপুন।';

  @override
  String get keypadHashAndStar =>
      'কণ্ঠস্বর থামাতে হ্যাশ টিপুন। এই নির্দেশগুলি আবার শুনতে স্টার টিপুন।';

  @override
  String get keypadDirectionKeysAndOk =>
      'যেতে দিক-নির্দেশক কী ব্যবহার করুন এবং বেছে নিতে ওকে টিপুন।';

  @override
  String get keypadLeaveField =>
      'লেখার সময় ঘর ছাড়তে ওকে টিপুন অথবা উপর বা নিচ ব্যবহার করুন।';

  @override
  String keypadPosition(String index, String total) {
    return ', $total-এর মধ্যে $index';
  }

  @override
  String keypadEditingPressOk(String label) {
    return '$label। লেখা চলছে। শেষ হলে ওকে টিপুন।';
  }

  @override
  String keypadEditingUseUpDown(String label) {
    return '$label। লেখা চলছে। এই ঘর ছাড়তে উপর বা নিচ ব্যবহার করুন।';
  }

  @override
  String get keypadControlUnavailable => 'এই কন্ট্রোলটি এখন পাওয়া যাচ্ছে না।';

  @override
  String get keypadMainScreen =>
      'এটি মূল স্ক্রিন। এখান থেকে ফিরে যাওয়ার কিছু নেই।';

  @override
  String messageLast(String text) {
    return 'শেষ বার্তা: $text';
  }

  @override
  String messageLastProblem(String text) {
    return 'শেষ সমস্যা: $text';
  }

  @override
  String ttsSpeedDescription(String speed) {
    return 'স্বাভাবিক গতির $speed গুণ';
  }

  @override
  String get ttsUnavailable =>
      'কণ্ঠস্বর পাওয়া যাচ্ছে না। একটি ইংরেজি Android টেক্সট-টু-স্পিচ কণ্ঠস্বর চালু করুন, তারপর সেটিংসে \'কণ্ঠস্বর পরীক্ষা করুন\' বোতাম টিপুন।';

  @override
  String ttsLanguageFallback(String language) {
    return 'এই ফোনে কোনো $language কণ্ঠস্বর নেই, তাই SEEDS ইংরেজিতে বলবে। Android টেক্সট-টু-স্পিচ সেটিংসে $language কণ্ঠস্বর ইনস্টল করুন, তারপর সেটিংসে কণ্ঠস্বরটি যাচাই করুন।';
  }

  @override
  String get ttsScreenReaderDetected =>
      'স্ক্রিন রিডার পাওয়া গেছে। SEEDS তার ঘোষণাগুলি আপনার স্ক্রিন রিডারে পাঠাবে।';

  @override
  String get ttsScreenReaderOff =>
      'স্ক্রিন রিডার বন্ধ হয়েছে। SEEDS নিজেই কথা বলবে।';

  @override
  String ttsVoiceInstalled(String language) {
    return 'Android জানাচ্ছে যে $language কণ্ঠস্বরের ডেটা ইনস্টল করা আছে। সেটিংসে \'কণ্ঠস্বর পরীক্ষা করুন\' বোতাম টিপুন, তারপর অফলাইন কণ্ঠস্বরের উপর ভরসা করার আগে এয়ারপ্লেন মোডে আবার পরীক্ষা করুন। এই যাচাই প্রমাণ করতে পারে না যে আপনি তা শুনতে পাচ্ছেন।';
  }

  @override
  String ttsVoiceNotOffline(String language) {
    return '$language পাওয়া যাচ্ছে, কিন্তু অফলাইন কণ্ঠস্বরের ডেটা ইনস্টল করা আছে কিনা নিশ্চিত হয়নি। কণ্ঠস্বরের জন্য ইন্টারনেট লাগতে পারে।';
  }

  @override
  String ttsVoiceMissing(String language) {
    return 'কোনো $language কণ্ঠস্বর পাওয়া যায়নি।';
  }

  @override
  String ttsVoiceUnverified(String language) {
    return '$language কণ্ঠস্বর আছে কিনা যাচাই করা যায়নি।';
  }

  @override
  String ttsVoiceRecovery(String language) {
    return 'Android সেটিংস খুলুন, টেক্সট-টু-স্পিচ আউটপুট খুঁজুন, $language কণ্ঠস্বর বেছে নিন এবং তার ডেটা ইনস্টল করুন। এখানে ফিরে এসে আবার যাচাই করুন। অ্যাপের কণ্ঠস্বরের বদলে আপনি Android স্ক্রিন রিডার ব্যবহার করতে পারেন।';
  }

  @override
  String get ttsSpeedChangeFailed =>
      'কথার গতি বদলানো যায়নি। আবার চেষ্টা করুন।';

  @override
  String get ttsSettingsFailed =>
      'কণ্ঠস্বরের সেটিংস প্রয়োগ করা যায়নি। আবার \'কণ্ঠস্বর পরীক্ষা করুন\' বোতাম টিপুন।';

  @override
  String get ttsCouldNotStart =>
      'কণ্ঠস্বর শুরু হতে পারেনি। সেটিংসে \'কণ্ঠস্বর পরীক্ষা করুন\' বোতাম টিপুন।';

  @override
  String get ttsNotAvailable =>
      'কণ্ঠস্বর পাওয়া যায়নি। সেটিংসে \'কণ্ঠস্বর পরীক্ষা করুন\' বোতাম টিপুন।';

  @override
  String get ttsFailed =>
      'কণ্ঠস্বর ব্যর্থ হয়েছে। সেটিংসে \'কণ্ঠস্বর পরীক্ষা করুন\' বোতাম টিপুন।';

  @override
  String get ttsLessonResumeFailed =>
      'রেকর্ড করা পাঠ আবার চালু করা যায়নি। আবার চেষ্টা করতে Play বেছে নিন।';

  @override
  String get ttsStopFailed =>
      'কণ্ঠস্বর থামানো যায়নি। Android TTS ইঞ্জিন যাচাই করুন।';

  @override
  String get ttsNoPendingUpdates => 'কোনো বাকি আপডেট নেই।';

  @override
  String get ttsOtherUpdates => 'অন্যান্য আপডেট';

  @override
  String ttsUpdateGroup(String group) {
    return '$group।';
  }

  @override
  String ttsUpdateGroupCount(String group, int count) {
    return '$group, $countটি আপডেট।';
  }

  @override
  String ttsOtherUpdateGroups(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'আরও $countটি আপডেট গ্রুপ।',
      one: 'আরও 1টি আপডেট গ্রুপ।',
    );
    return '$_temp0';
  }

  @override
  String get settingsScreenName => 'সেটিংস';

  @override
  String get settingsSections =>
      'চারটি বিভাগ: কণ্ঠস্বর, ডিসপ্লে, কী ও সাহায্য, তারপর সেটিংস সেভ করুন';

  @override
  String get settingsLoaded => 'সেটিংস লোড হয়েছে';

  @override
  String get settingsSaved => 'সেটিংস সেভ হয়েছে';

  @override
  String get settingsResetSaved => 'সেটিংস ডিফল্টে ফিরিয়ে সেভ করা হয়েছে';

  @override
  String settingsTestSpeech(String volume, String speed) {
    return 'এটি টেক্সট-টু-স্পিচ ব্যবস্থার একটি পরীক্ষা। ভলিউম $volume শতাংশ। কথার গতি $speed।';
  }

  @override
  String settingsFastestSpeed(String speed) {
    return 'সবচেয়ে দ্রুত কথার গতি, $speed';
  }

  @override
  String settingsSlowestSpeed(String speed) {
    return 'সবচেয়ে ধীর কথার গতি, $speed';
  }

  @override
  String settingsSpeechSpeed(String speed) {
    return 'কথার গতি $speed';
  }

  @override
  String get settingsVoiceCommandsEnabled => 'ভয়েস কমান্ড চালু হয়েছে';

  @override
  String get settingsVoiceCommandsDisabled => 'ভয়েস কমান্ড বন্ধ হয়েছে';

  @override
  String get settingsHighContrastOn => 'হাই কনট্রাস্ট চালু';

  @override
  String get settingsHighContrastOff => 'হাই কনট্রাস্ট বন্ধ';

  @override
  String get settingsShortcutsShown => 'কীপ্যাড শর্টকাট দেখানো হচ্ছে';

  @override
  String get settingsShortcutsHidden => 'কীপ্যাড শর্টকাট লুকানো হয়েছে';

  @override
  String get settingsVoiceHelp =>
      'সেশনে থাকার সময় কমান্ড শুনুন চালু করুন, তারপর বলুন মিউট, আনমিউট, হাত তুলুন, হাত নামান, ছেড়ে যান, বা আবার বলুন। শোনা নিজে থেকে আবার শুরু হয় না। আনমিউট করার জন্য কী টিপে বা ছুঁয়ে নিশ্চিত করতে বলা হয়।';

  @override
  String settingsModeAutomatic(String current) {
    return 'স্বয়ংক্রিয়: আপনি না বেছে নিলে TalkBack অনুসরণ করে। এখন $current।';
  }

  @override
  String get settingsModeUsingScreenReader => 'স্ক্রিন রিডার ব্যবহার করছে';

  @override
  String get settingsModeUsingSelfVoicing => 'নিজের কণ্ঠস্বরে বলছে';

  @override
  String get settingsModeScreenReader =>
      'স্ক্রিন রিডার: ঘোষণাগুলি TalkBack-এ যায়। অ্যাপের বর্ণনা বন্ধ আছে।';

  @override
  String get settingsModeSelfVoicing => 'নিজস্ব কণ্ঠস্বর: অ্যাপ নিজেই কথা বলে।';

  @override
  String settingsSoundCues(String state) {
    return 'শব্দ সংকেত $state।';
  }

  @override
  String settingsSoundCuesOnSaved(String state) {
    return 'শব্দ সংকেত $state। এটি সংরক্ষণের শব্দ।';
  }

  @override
  String settingsVibration(String state) {
    return 'ভাইব্রেশন $state।';
  }

  @override
  String settingsVibrationOnBuzz(String state) {
    return 'ভাইব্রেশন $state। একটি ছোট কম্পন মানে ওকে।';
  }

  @override
  String settingsSoundCuesLabel(String state) {
    return 'শব্দ সংকেত, $state। সঠিক, ভুল, সংরক্ষিত, ত্রুটি এবং আপনার বলার পালার জন্য ছোট শব্দ';
  }

  @override
  String settingsVibrationLabel(String state) {
    return 'ভাইব্রেশন, $state। ওকে-র জন্য একটি কম্পন, ত্রুটির জন্য দুটি, বেরিয়ে যাওয়ার জন্য একটি লম্বা কম্পন';
  }

  @override
  String get settingsSoundCuesHelp =>
      'সঠিক, ভুল, সংরক্ষিত, ত্রুটি, তালিকার শেষ এবং আপনার বলার পালার জন্য ছোট শব্দ। সঙ্গে সঙ্গে সংরক্ষিত হয়।';

  @override
  String get settingsVibrationHelp =>
      'ওকে-র জন্য একটি ছোট কম্পন, ত্রুটির জন্য দুটি, বেরিয়ে যাওয়া বা শেষ করার জন্য একটি লম্বা কম্পন। সঙ্গে সঙ্গে সংরক্ষিত হয়।';

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
    return 'অ্যাপের কণ্ঠস্বর $speech, গতি $speed, ভলিউম $volume শতাংশ। লেখার আকার $textSize শতাংশ। হাই কনট্রাস্ট $highContrast। শব্দ সংকেত $soundCues। ভাইব্রেশন $vibration। কথার ভাষা $language।';
  }

  @override
  String settingsVolume(String percent) {
    return 'ভলিউম $percent শতাংশ';
  }

  @override
  String settingsTextSize(String percent) {
    return 'লেখার আকার $percent শতাংশ';
  }

  @override
  String get settingsSpeechOff => 'অ্যাপের কণ্ঠস্বর বন্ধ';

  @override
  String get settingsSpeechOn => 'অ্যাপের কণ্ঠস্বর চালু';

  @override
  String settingsSpeechMode(String description) {
    return 'কথার মোড। $description';
  }

  @override
  String settingsNarration(String level) {
    return 'বর্ণনার স্তর $level।';
  }

  @override
  String get settingsNarrationEssential => 'প্রয়োজনীয়';

  @override
  String get settingsNarrationStandard => 'সাধারণ';

  @override
  String get settingsNarrationDetailed => 'বিস্তারিত';

  @override
  String settingsLanguage(String language) {
    return 'কথার ভাষা $language।';
  }

  @override
  String settingsLanguageLabel(String language) {
    return 'কথার ভাষা, $language। বদলাতে ওকে টিপুন।';
  }

  @override
  String get settingsBack => 'ফিরে যান';

  @override
  String get settingsResetLabel =>
      'সেটিংস আগের অবস্থায় ফেরান, নিশ্চিত করতে বলবে';

  @override
  String settingsSpeechSectionLabel(String state) {
    return 'কথার অংশ। অ্যাপের কণ্ঠস্বর, $state';
  }

  @override
  String settingsVolumeLabel(String percent) {
    return 'ভলিউম $percent শতাংশ। বদলাতে বাঁ বা ডান টিপুন';
  }

  @override
  String settingsSpeedLabel(String speed) {
    return 'কথার গতি $speed। বদলাতে বাঁ বা ডান টিপুন';
  }

  @override
  String get settingsTestLabel => 'কণ্ঠস্বর পরীক্ষা করুন';

  @override
  String settingsModeLabel(String description) {
    return 'কথার মোড। $description বদলাতে ওকে টিপুন।';
  }

  @override
  String settingsNarrationLabel(String level) {
    return 'বর্ণনার স্তর $level। বদলাতে ওকে টিপুন।';
  }

  @override
  String settingsCheckVoiceLabel(String language) {
    return '$language কণ্ঠস্বর যাচাই করুন';
  }

  @override
  String get settingsStopLabel => 'কথা থামান';

  @override
  String settingsContrastLabel(String state) {
    return 'ডিসপ্লে অংশ। হাই কনট্রাস্ট, $state। আগে থেকেই চালু থাকে';
  }

  @override
  String settingsTextSizeLabel(String percent) {
    return 'লেখার আকার $percent শতাংশ। বদলাতে বাঁ বা ডান টিপুন';
  }

  @override
  String settingsShortcutsLabel(String state) {
    return 'কী এবং সাহায্য অংশ। কীপ্যাড শর্টকাট দেখান, $state';
  }

  @override
  String settingsVoiceCommandsLabel(String state) {
    return 'সেশনে ভয়েস কমান্ড, $state';
  }

  @override
  String get settingsVoiceHelpLabel => 'ভয়েস কমান্ড সাহায্য';

  @override
  String get settingsRepeatHelpLabel => 'সেটিংস সাহায্য আবার শুনুন';

  @override
  String get settingsSaveLabel => 'সেটিংস সংরক্ষণ করুন';

  @override
  String get settingsResetQuestion =>
      'সব সেটিংস আগের অবস্থায় ফেরাবেন? কথা, ডিসপ্লে এবং কী-এর সেটিংস তাদের আসল মানে ফিরে যাবে।';

  @override
  String settingsResetScreen(String question) {
    return 'সেটিংস রিসেট। $question';
  }

  @override
  String get settingsResetCancel => 'বাতিল';

  @override
  String get settingsResetConfirm => 'রিসেট';

  @override
  String get settingsResetCancelLabel => 'বাতিল করুন, আমার সেটিংস রাখুন';

  @override
  String get settingsResetConfirmLabel => 'সব সেটিংস আগের অবস্থায় ফেরান';

  @override
  String get quizNotSet => 'ঠিক করা নেই';

  @override
  String get quizNotAvailable => 'পাওয়া যাচ্ছে না';

  @override
  String get quizNotAvailableCapital => 'পাওয়া যাচ্ছে না';

  @override
  String quizQuestionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি প্রশ্ন',
      one: '1টি প্রশ্ন',
    );
    return '$_temp0';
  }

  @override
  String quizAttemptCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি চেষ্টা',
      one: '1টি চেষ্টা',
    );
    return '$_temp0';
  }

  @override
  String quizStudentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count জন শিক্ষার্থী',
      one: '1 জন শিক্ষার্থী',
    );
    return '$_temp0';
  }

  @override
  String get quizAccountChanged =>
      'আপনার অ্যাকাউন্ট বদলে গেছে। কুইজে ফিরে গিয়ে আবার সাইন ইন করুন।';

  @override
  String get quizUnlimitedPractice =>
      'অনুশীলনের জন্য যত খুশি চেষ্টা। নম্বর দেওয়া হয় না।';

  @override
  String quizAttemptsRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'আর $countটি চেষ্টা বাকি।',
      one: 'আর 1টি চেষ্টা বাকি।',
    );
    return '$_temp0';
  }

  @override
  String quizTimeLimit(String duration) {
    return 'সময়সীমা $duration।';
  }

  @override
  String get quizNoTimeLimit => 'কোনো সময়সীমা নেই।';

  @override
  String get quizNoTimeLimitShort => 'কোনো সময়সীমা নেই';

  @override
  String get quizFeedbackAfterCompletion =>
      'কুইজ শেষ করার পরে উত্তরের ফিডব্যাক ও নম্বর জানানো হবে।';

  @override
  String quizFeedbackScheduled(String when) {
    return 'আপনি শেষ করার পরে এবং $when-এর পরে ফিডব্যাক ও নম্বর জানানো হবে।';
  }

  @override
  String get quizFeedbackScoreOnly =>
      'শেষ করার পরে শুধু নম্বর জানানো হবে। উত্তর ও ব্যাখ্যা জানানো হবে না।';

  @override
  String get quizFeedbackImmediate =>
      'প্রতিটি উত্তর জমা দেওয়ার সাথে সাথেই শুনবেন সেটি ঠিক কি না।';

  @override
  String get quizPolicyAfterCompletion => 'কুইজ শেষ হওয়ার পরে';

  @override
  String get quizPolicyScheduled => 'নির্ধারিত সময়ে';

  @override
  String get quizPolicyScoreOnly => 'শুধু নম্বর';

  @override
  String get quizPolicyLegacyImmediate => 'সাথে সাথে, পুরোনো সেটিং';

  @override
  String get quizPolicyImmediate => 'প্রতিটি উত্তরের সাথে সাথে';

  @override
  String quizPracticeResult(String correct, String total) {
    return 'অনুশীলন, পড়াশোনার নম্বর নয়। এই অনুশীলনে $totalটির মধ্যে $correctটি ঠিক।';
  }

  @override
  String quizScoreNotReleased(String message) {
    return 'নম্বর জানানো হয়নি। $message';
  }

  @override
  String get quizCheckReleasePolicy => 'নম্বর জানানোর নিয়ম দেখুন।';

  @override
  String quizScoreResult(String correct, String total, String percent) {
    return 'নম্বর $total-এর মধ্যে $correct, $percent।';
  }

  @override
  String get quizStatusInProgress => 'চলছে';

  @override
  String get quizStatusTimedOut => 'সময় শেষ হওয়ায় শেষ হয়েছে';

  @override
  String get quizStatusCompleted => 'শেষ হয়েছে';

  @override
  String get quizStatusPublished => 'প্রকাশিত';

  @override
  String get quizStatusDraft => 'খসড়া';

  @override
  String get quizStatusClosed => 'বন্ধ';

  @override
  String get quizStatusScheduled => 'নির্ধারিত';

  @override
  String get quizStatusOpen => 'খোলা';

  @override
  String quizQuestionHeading(String number, String total) {
    return '$totalটির মধ্যে প্রশ্ন $number';
  }

  @override
  String quizQuestionWithText(String number, String total, String text) {
    return '$totalটির মধ্যে প্রশ্ন $number। $text';
  }

  @override
  String quizOptionSpoken(String number, String text) {
    return 'বিকল্প $number। $text।';
  }

  @override
  String quizOptionLabel(String number, String count, String text) {
    return '$countটির মধ্যে বিকল্প $number, $text';
  }

  @override
  String quizOptionTargetSelected(String number, String text) {
    return 'বিকল্প $number, $text, বেছে নেওয়া হয়েছে। বেছে নিতে ওকে বা $number টিপুন';
  }

  @override
  String quizOptionTargetNotSelected(String number, String text) {
    return 'বিকল্প $number, $text, বেছে নেওয়া হয়নি। বেছে নিতে ওকে বা $number টিপুন';
  }

  @override
  String quizAnswerKeysBrief(String count) {
    return '1 থেকে $count টিপুন, তারপর 5।';
  }

  @override
  String quizAnswerKeysDetailed(String count) {
    return 'উত্তর বেছে নিতে 1 থেকে $count টিপুন, তারপর জমা দিতে 5 টিপুন। প্রশ্নটি আবার শুনতে 6 টিপুন, আপনি কোথায় আছেন শুনতে 8 টিপুন।';
  }

  @override
  String quizChosenBrief(String number, String text) {
    return 'বিকল্প $number, $text, বেছে নেওয়া হয়েছে।';
  }

  @override
  String quizChosenDetailed(String number, String text) {
    return 'বিকল্প $number, $text, বেছে নেওয়া হয়েছে। জমা দিতে 5 টিপুন, বা অন্য একটি নম্বর বেছে নিন।';
  }

  @override
  String quizChooseFirst(String count) {
    return 'আগে একটি উত্তর বেছে নিন। 1 থেকে $count টিপুন, তারপর জমা দিতে 5 টিপুন।';
  }

  @override
  String quizNoSuchOption(String option, String count) {
    return 'বিকল্প $option নেই। 1 থেকে $count টিপুন।';
  }

  @override
  String get quizSubmitting => 'আপনার উত্তর জমা দেওয়া হচ্ছে।';

  @override
  String quizCorrectFeedback(String answer) {
    return 'সঠিক! $answer।';
  }

  @override
  String quizWrongFeedback(String answer) {
    return 'ঠিক হয়নি। উত্তর হল $answer।';
  }

  @override
  String get quizAnswerSavedBrief => 'উত্তর সেভ হয়েছে।';

  @override
  String get quizAnswerSavedLocked => 'উত্তর সেভ ও লক হয়েছে।';

  @override
  String get quizSavedHeading => 'উত্তর সেভ ও লক হয়েছে';

  @override
  String get quizCorrectHeading => 'সঠিক';

  @override
  String get quizWrongHeading => 'ভুল';

  @override
  String quizYouSelected(String text) {
    return 'আপনি বেছে নিয়েছেন: $text';
  }

  @override
  String quizCorrectAnswerIs(String text) {
    return 'সঠিক উত্তর: $text';
  }

  @override
  String get quizNoExplanation => 'কোনো ব্যাখ্যা দেওয়া হয়নি।';

  @override
  String quizAnswerFailed(String reason) {
    return '$reason আপনার বেছে নেওয়া উত্তর রাখা আছে। আবার চেষ্টা করতে 5 টিপুন।';
  }

  @override
  String get quizAnswerUnreadable => 'উত্তরের নিশ্চিতকরণ পড়া যায়নি।';

  @override
  String get quizNoOptionSelected => 'কোনো বিকল্প বেছে নেওয়া হয়নি।';

  @override
  String quizSelectionSaved(String number, String text) {
    return 'বেছে নেওয়া বিকল্প $number, $text। উত্তর সেভ হয়েছে।';
  }

  @override
  String quizSelectionNotSubmitted(String number, String text) {
    return 'বেছে নেওয়া বিকল্প $number, $text। এখনও জমা দেওয়া হয়নি।';
  }

  @override
  String get quizRepeatQuestion => 'প্রশ্ন ও বিকল্পগুলি আবার শুনুন';

  @override
  String get quizAnswerConfirmed => 'উত্তর সেভ ও লক হয়েছে বলে নিশ্চিত।';

  @override
  String get quizFeedbackStaysAvailable =>
      'এর ফিডব্যাক পরের প্রশ্নে ব্যক্তিগতভাবে শোনা যাবে।';

  @override
  String get quizPreviousFeedback =>
      'আগের উত্তরের ফিডব্যাক ব্যক্তিগতভাবে শুনুন';

  @override
  String get quizAnswerLockNotice =>
      '5 টিপলে প্রতিটি উত্তর সেভ ও লক হয়ে যায়।';

  @override
  String quizTimeLeft(String duration) {
    return 'বাকি সময়: $duration।';
  }

  @override
  String quizClockLeft(String clock) {
    return '$clock বাকি';
  }

  @override
  String quizClockRemaining(String clock) {
    return '$clock বাকি আছে';
  }

  @override
  String quizTimeWarning(String duration) {
    return 'এই কুইজে $duration বাকি।';
  }

  @override
  String quizTimeUp(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'সময় শেষ। $countটি উত্তর সেভ হয়েছে। কুইজ শেষ করা হচ্ছে।',
      one: 'সময় শেষ। 1টি উত্তর সেভ হয়েছে। কুইজ শেষ করা হচ্ছে।',
    );
    return '$_temp0';
  }

  @override
  String quizWhereQuestion(String number, String total) {
    return 'প্রশ্ন $number, মোট $totalটির মধ্যে।';
  }

  @override
  String quizAnsweredCount(String count) {
    return '$countটির উত্তর দেওয়া হয়েছে।';
  }

  @override
  String get quizAllSaved =>
      'সব উত্তর সেভ হয়েছে। শেষ করে ফলাফল শুনতে 5 টিপুন।';

  @override
  String get quizFinishNow => 'এখনই কুইজ শেষ করুন, নিশ্চিত করার পরে';

  @override
  String get quizFinishNowButton => 'এখনই কুইজ শেষ করুন';

  @override
  String get quizFinishTitle => 'এখনই কুইজ শেষ করবেন?';

  @override
  String quizFinishMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'সার্ভার দেখাচ্ছে $countটি প্রশ্নের উত্তর দেওয়া হয়নি। শুধু সেভ করা উত্তরগুলিই গণনা হবে। যে উত্তর বেছে নিয়েছেন কিন্তু জমা দেননি, তা ধরা হবে না। শেষ করার পরে আর উত্তর বদলাতে পারবেন না।',
      one:
          'সার্ভার দেখাচ্ছে 1টি প্রশ্নের উত্তর দেওয়া হয়নি। শুধু সেভ করা উত্তরগুলিই গণনা হবে। যে উত্তর বেছে নিয়েছেন কিন্তু জমা দেননি, তা ধরা হবে না। শেষ করার পরে আর উত্তর বদলাতে পারবেন না।',
    );
    return '$_temp0';
  }

  @override
  String get quizFinishConfirm => 'কুইজ শেষ করুন';

  @override
  String get quizFinishCancel => 'কাজ চালিয়ে যান';

  @override
  String get quizFinishUnchecked =>
      'আপনার সেভ করা উত্তরগুলি যাচাই করা যায়নি, বা এই চেষ্টা শেষ হয়ে গেছে। কুইজ শেষ করা হয়নি। রিফ্রেশ করতে কুইজের তালিকায় ফিরে যান।';

  @override
  String get quizFinishTimedOut =>
      'আপনার সেভ করা উত্তরগুলি যাচাই করতে অনেক সময় লেগেছে। কুইজ শেষ করা হয়নি। আপনার সংযোগ দেখে আবার চেষ্টা করুন।';

  @override
  String get quizFinishing => 'কুইজ শেষ করা হচ্ছে';

  @override
  String get quizFinishAndHear => 'শেষ করে ফলাফল শুনুন';

  @override
  String get quizRetryFinishing => 'আবার শেষ করার চেষ্টা করুন';

  @override
  String quizCompletionFailed(String reason) {
    return '$reason আপনার সেভ করা উত্তরগুলি রাখা আছে। আবার শেষ করার চেষ্টা করতে 5 টিপুন।';
  }

  @override
  String get quizCompletionNotConfirmed => 'শেষ হওয়া নিশ্চিত হয়নি।';

  @override
  String get quizCompleted =>
      'কুইজ শেষ। আপনার ফলাফল ব্যক্তিগত। শুনতে 8 টিপুন, বা কুইজে ফিরে যেতে 0 টিপুন।';

  @override
  String get quizCompletedTimedOut =>
      'সময় শেষ। কুইজ শেষ। আপনার ফলাফল ব্যক্তিগত। শুনতে 8 টিপুন, বা কুইজে ফিরে যেতে 0 টিপুন।';

  @override
  String get quizResultPrivate =>
      'কুইজ শেষ। ফলাফল ব্যক্তিগত। ফলাফল ব্যক্তিগতভাবে পড়ুন ব্যবহার করুন।';

  @override
  String get quizResultHeading => 'চেষ্টা সম্পূর্ণ';

  @override
  String get quizReadResult => 'ফলাফল ব্যক্তিগতভাবে পড়ুন';

  @override
  String get quizReturnToQuizzes => 'কুইজে ফিরে যান';

  @override
  String get quizLeave => 'জমা না দিয়ে বেরিয়ে যান, নিশ্চিত করার পরে';

  @override
  String get quizLeaveTitle => 'বেরিয়ে গিয়ে পরে আবার শুরু করবেন?';

  @override
  String get quizLeaveMessage =>
      'এতে আপনার চেষ্টা জমা হয় না। শুধু সেভ করা উত্তরগুলি রাখা থাকে; যে উত্তর বেছে নিয়েছেন কিন্তু জমা দেননি, তা হারিয়ে যেতে পারে। সময়সীমা থাকলে তা চলতে থাকবে। কুইজ অনুমতি দিলে আপনি আবার শুরু করতে পারবেন।';

  @override
  String get quizLeaveConfirm => 'জমা না দিয়ে বেরিয়ে যান';

  @override
  String get quizLeaveCancel => 'কুইজে থাকুন';

  @override
  String get quizWaitBeforeLeaving =>
      'অনুগ্রহ করে অপেক্ষা করুন। আপনার উত্তর এখনও সেভ হচ্ছে।';

  @override
  String quizAttemptScreen(String title) {
    return 'কুইজের চেষ্টা, $title';
  }

  @override
  String get quizAttemptNavigationCompleted =>
      'কুইজে ফিরে যাওয়া, ফলাফল ব্যক্তিগতভাবে পড়া এবং কুইজের কণ্ঠস্বরের গতি';

  @override
  String get quizAttemptNavigationTimed =>
      'প্রশ্ন, প্রতিটি উত্তরের বিকল্প, বেছে নেওয়া উত্তর, কুইজের কণ্ঠস্বরের গতি, বাকি সময়, জমা দিন, এখনই কুইজ শেষ করুন এবং বেরিয়ে যান। ফোকাস সরালে কখনও কিছু বেছে নেওয়া বা জমা দেওয়া হয় না';

  @override
  String get quizAttemptNavigationUntimed =>
      'প্রশ্ন, প্রতিটি উত্তরের বিকল্প, বেছে নেওয়া উত্তর, কুইজের কণ্ঠস্বরের গতি, জমা দিন, এখনই কুইজ শেষ করুন এবং বেরিয়ে যান। ফোকাস সরালে কখনও কিছু বেছে নেওয়া বা জমা দেওয়া হয় না';

  @override
  String get quizSpeedHelp => 'কুইজের কণ্ঠস্বর ধীর বা দ্রুত করতে 7 বা 9 টিপুন।';

  @override
  String get quizSpeedScreenReader =>
      'কুইজের কণ্ঠস্বরের গতি শুধু অ্যাপের কণ্ঠস্বর বদলায়। স্ক্রিন রিডারের গতি Android সেটিংসে বদলান।';

  @override
  String get quizSpeedHeading => 'কুইজের কণ্ঠস্বরের গতি';

  @override
  String quizSpeedTarget(String description) {
    return 'কুইজের কণ্ঠস্বরের গতি, $description। বদলাতে বাঁ বা ডান দিকে যান, বা 7 বা 9 টিপুন';
  }

  @override
  String quizSpeedRead(String description) {
    return 'কুইজের কণ্ঠস্বরের গতি, $description। ধীর করতে 7 বা দ্রুত করতে 9 টিপুন। এই গতি শুধু কুইজে ব্যবহার হয়।';
  }

  @override
  String quizSpeedFaster(String description) {
    return 'দ্রুত। $description।';
  }

  @override
  String quizSpeedSlower(String description) {
    return 'ধীর। $description।';
  }

  @override
  String quizSpeedFastest(String description) {
    return 'কুইজের সবচেয়ে দ্রুত কণ্ঠস্বর, $description।';
  }

  @override
  String quizSpeedSlowest(String description) {
    return 'কুইজের সবচেয়ে ধীর কণ্ঠস্বর, $description।';
  }

  @override
  String get quizStudentScreen => 'শিক্ষার্থীর কুইজ';

  @override
  String get quizStudentNavigation =>
      'রিফ্রেশ, কুইজের অবস্থা ও বিষয়ের ফিল্টার, উপলব্ধ কুইজ এবং চেষ্টার ইতিহাস';

  @override
  String get quizStudentIntroBrief =>
      'ফিল্টার বদলাতে তার উপর বাঁ বা ডান দিকে যান।';

  @override
  String get quizStudentIntroDetailed =>
      'ফিল্টার বদলাতে তার উপর বাঁ বা ডান দিকে যান। কুইজের বিবরণ শুনতে ও শুরু করা নিশ্চিত করতে কুইজের উপর ওকে টিপুন। ফোকাস সরালে কখনও কুইজ শুরু হয় না।';

  @override
  String quizAvailable(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি কুইজ উপলব্ধ।',
      one: '1টি কুইজ উপলব্ধ।',
      zero: 'কোনো কুইজ উপলব্ধ নেই।',
    );
    return '$_temp0';
  }

  @override
  String quizStudentState(int count, String open) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি কুইজ দেখানো হচ্ছে, $openটি খোলা।',
      one: '1টি কুইজ দেখানো হচ্ছে, $openটি খোলা।',
    );
    return '$_temp0';
  }

  @override
  String get quizStateAll => 'সব অবস্থা';

  @override
  String get quizStateScheduled => 'নির্ধারিত';

  @override
  String get quizStateOpen => 'খোলা';

  @override
  String get quizStateClosed => 'বন্ধ';

  @override
  String quizStateFilter(String name, String position, String count) {
    return 'কুইজের অবস্থা: $name, $countটির মধ্যে $position।';
  }

  @override
  String quizSubjectFilter(String name, String position, String count) {
    return 'বিষয়: $name, $countটির মধ্যে $position।';
  }

  @override
  String get quizChangeWithArrows => 'বদলাতে বাঁ বা ডান দিকে যান';

  @override
  String get quizAllSubjects => 'সব বিষয়';

  @override
  String quizRowHead(String subject, String title, String status) {
    return '$subject, $title, $status।';
  }

  @override
  String get quizStartQuiz => 'কুইজ শুরু করুন';

  @override
  String get quizResumeQuiz => 'কুইজ আবার শুরু করুন';

  @override
  String quizHistoryRow(String title, String score) {
    return '$title-এর চেষ্টার ইতিহাস দেখুন। সর্বোচ্চ স্কোর $score';
  }

  @override
  String quizLimitReached(String title) {
    return '$title-এর জন্য আর কোনো চেষ্টা বাকি নেই। আপনার স্কোর দেখতে চেষ্টার ইতিহাস খুলুন।';
  }

  @override
  String get quizStartTitle => 'কুইজ শুরু করবেন?';

  @override
  String get quizResumeTitle => 'কুইজ আবার শুরু করবেন?';

  @override
  String quizTitleSentence(String title) {
    return '$title।';
  }

  @override
  String quizClosesSentence(String when) {
    return 'বন্ধ হবে $when।';
  }

  @override
  String get quizStartAttempt => 'চেষ্টা শুরু করুন';

  @override
  String get quizResumeAttempt => 'চেষ্টা আবার শুরু করুন';

  @override
  String get quizStartFailed =>
      'কুইজ শুরু করা যায়নি। কুইজটি খোলা আছে কিনা দেখুন।';

  @override
  String get quizHistoryFailed => 'চেষ্টার ইতিহাস লোড করা যায়নি।';

  @override
  String get quizHistoryScreen =>
      'চেষ্টার ইতিহাস। স্কোর ব্যক্তিগত। দেখতে সারাংশ বা কোনো চেষ্টায় যান।';

  @override
  String get quizPracticeHistory =>
      'অনুশীলনের ইতিহাস। এটি পড়াশোনার গ্রেড নয়।';

  @override
  String quizHighestScoreValue(String score) {
    return 'সর্বোচ্চ স্কোর: $score';
  }

  @override
  String get quizNoScoreReleasedYet =>
      'সম্পূর্ণ চেষ্টা আছে; এখনও কোনো স্কোর প্রকাশ করা হয়নি।';

  @override
  String get quizNoCompletedAttempt => 'কোনো সম্পূর্ণ চেষ্টা নেই';

  @override
  String quizHistoryAttempt(String number, String status, String result) {
    return 'চেষ্টা $number। $status। $result দেখতে ওকে টিপুন।';
  }

  @override
  String get quizResumeFromList =>
      'এই চেষ্টা চলছে। আবার শুরু করতে কুইজের তালিকায় ফিরে যান। বেরিয়ে গেলে জমা হয় না।';

  @override
  String get quizReviewFailed =>
      'চেষ্টার পর্যালোচনা লোড করা যায়নি। আপনার সংযোগ দেখে আবার চেষ্টা করুন।';

  @override
  String get quizReviewTimedOut =>
      'চেষ্টার পর্যালোচনায় অনেক সময় লেগেছে। আপনার সংযোগ দেখে আবার চেষ্টা করুন।';

  @override
  String quizReviewScreenMessage(String message) {
    return 'চেষ্টার পর্যালোচনা। $message';
  }

  @override
  String quizReviewScreen(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'চেষ্টার পর্যালোচনা। $countটি প্রশ্ন। প্রতিটি উত্তর দেখতে উপরে ও নিচে যান।',
      one:
          'চেষ্টার পর্যালোচনা। 1টি প্রশ্ন। প্রতিটি উত্তর দেখতে উপরে ও নিচে যান।',
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
    return 'প্রশ্ন $number। সঠিক। $question। আপনি বেছে নিয়েছেন $chosen। সঠিক উত্তর $answer। $explanation';
  }

  @override
  String quizReviewQuestionIncorrect(
    String number,
    String question,
    String chosen,
    String answer,
    String explanation,
  ) {
    return 'প্রশ্ন $number। ভুল। $question। আপনি বেছে নিয়েছেন $chosen। সঠিক উত্তর $answer। $explanation';
  }

  @override
  String get quizNoAnswer => 'কোনো উত্তর নেই';

  @override
  String quizTeacherScreen(String className, String subjectName) {
    return '$className, $subjectName-এর জন্য শিক্ষকের কুইজ';
  }

  @override
  String get quizTeacherNavigation =>
      'ব্যাংক অনুসন্ধান ও সেভ করা প্রশ্ন, কুইজের খসড়া, প্রকাশিত কুইজ এবং তাদের ফলাফল';

  @override
  String get quizTeacherIntroDetailed =>
      'ব্যাংক অনুসন্ধান ও সেভ করা প্রশ্ন, কুইজের খসড়া, প্রকাশিত কুইজ ও ফলাফল দেখতে D-pad ব্যবহার করুন।';

  @override
  String quizBankQuestionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ব্যাংকে $countটি প্রশ্ন',
      one: 'ব্যাংকে 1টি প্রশ্ন',
    );
    return '$_temp0';
  }

  @override
  String quizQuizCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি কুইজ',
      one: '1টি কুইজ',
    );
    return '$_temp0';
  }

  @override
  String quizDraftCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি খসড়া',
      one: '1টি খসড়া',
    );
    return '$_temp0';
  }

  @override
  String quizTeacherLoaded(String questions, String quizzes) {
    return '$questions এবং $quizzes লোড হয়েছে।';
  }

  @override
  String quizTeacherState(
    String drafts,
    String published,
    String closed,
    String bankQuestions,
  ) {
    return '$drafts, $publishedটি প্রকাশিত, $closedটি বন্ধ। $bankQuestions।';
  }

  @override
  String get quizTeacherLoadFailed =>
      'প্রশ্ন ব্যাংক বা কুইজের তালিকা রিফ্রেশ করা যায়নি। আরেকটি কুইজ তৈরি করার আগে আবার চেষ্টা করতে 1 টিপুন।';

  @override
  String get quizRefreshQuizzes => 'কুইজের বিষয়বস্তু রিফ্রেশ করুন';

  @override
  String get quizSearchBank => 'ব্যক্তিগত প্রশ্ন ব্যাংকে খুঁজুন';

  @override
  String get quizCreateQuestion => 'চার বিকল্পের প্রশ্ন তৈরি করুন';

  @override
  String get quizCreateQuiz => 'কুইজের খসড়া তৈরি করুন';

  @override
  String get quizCreatePractice =>
      'আলাদা সময়হীন, নম্বরবিহীন অনুশীলন তৈরি করুন। যতবার খুশি আবার চেষ্টা করা যাবে';

  @override
  String quizBankQuestionItem(String question, String revision) {
    return 'প্রশ্ন ব্যাংকের আইটেম, $question। সংস্করণ $revision। সম্পাদনা, সংস্করণের ইতিহাস, কপি, আর্কাইভ বা যোগ করার কাজের জন্য ওকে টিপুন';
  }

  @override
  String get quizRevisionUnknownOlder => 'অজানা, পুরোনো প্রশ্ন';

  @override
  String get quizRevisionUnknownLegacy => 'অজানা পুরোনো';

  @override
  String quizContinueCreating(String title, String questions) {
    return '$title তৈরি করা চালিয়ে যান। $questions';
  }

  @override
  String quizContinueCreatingRaw(String title, String count) {
    return '$title তৈরি করা চালিয়ে যান। $countটি প্রশ্ন';
  }

  @override
  String quizCloseWithConfirmation(String title) {
    return '$title বন্ধ করুন, নিশ্চিত করার পরে';
  }

  @override
  String quizCloseNamed(String title) {
    return '$title বন্ধ করুন';
  }

  @override
  String quizIsClosed(String title) {
    return '$title বন্ধ আছে';
  }

  @override
  String quizDuplicateTarget(String title) {
    return '$title কপি করে একটি নতুন সম্পাদনাযোগ্য খসড়া তৈরি করুন';
  }

  @override
  String quizResultsTarget(String title) {
    return '$title-এর ফলাফল দেখুন';
  }

  @override
  String quizCard(String title, String status, String questions) {
    return '$title। অবস্থা $status। $questions।';
  }

  @override
  String get quizAccountChangedBank =>
      'আপনার অ্যাকাউন্ট বদলে গেছে। চালিয়ে যাওয়ার আগে প্রশ্ন ব্যাংক আবার খুলুন।';

  @override
  String quizQuestionSaveUnconfirmed(String reason) {
    return '$reason প্রশ্ন সেভ হওয়া নিশ্চিত করা যায়নি। আবার চেষ্টা করার আগে ব্যাংক দেখে রিফ্রেশ করুন; একই প্রশ্ন দুবার তৈরি করবেন না।';
  }

  @override
  String get quizMissingRevision =>
      'সার্ভার সংস্করণ ছাড়া একটি প্রশ্ন পাঠিয়েছে। কুইজের ব্যাকএন্ড আপডেট করতে প্রশাসককে বলুন।';

  @override
  String get quizSavedQuestionMismatch => 'সেভ করা প্রশ্ন মেলেনি।';

  @override
  String get quizQuestionSaved =>
      'প্রশ্ন সেভ হয়েছে। পরে ব্যাংকের এই প্রশ্ন সম্পাদনা করলে আগের কুইজগুলি বদলাবে না।';

  @override
  String get quizNoRevisionForEdit =>
      'এই সার্ভার প্রশ্নের সংস্করণ দেয়নি। সম্পাদনা করার আগে কুইজের ব্যাকএন্ড আপডেট করতে প্রশাসককে বলুন।';

  @override
  String quizQuestionUpdateUnconfirmed(String reason) {
    return '$reason ব্যাংকের প্রশ্ন আপডেট হয়েছে কিনা নিশ্চিত করা যায়নি। আবার চেষ্টা করার আগে রিফ্রেশ করে এর বর্তমান সংস্করণ দেখুন।';
  }

  @override
  String get quizSavedRevisionMismatch => 'সেভ করা সংস্করণ মেলেনি।';

  @override
  String get quizQuestionUpdated =>
      'ব্যাংকের প্রশ্ন আপডেট হয়েছে। আগের কুইজের স্ন্যাপশট বদলানো হয়নি।';

  @override
  String get quizArchiveTitle => 'ব্যাংকের প্রশ্ন আর্কাইভ করবেন?';

  @override
  String get quizArchiveMessage =>
      'ব্যাংকের এই ব্যক্তিগত প্রশ্নটি আর্কাইভ করবেন? আগের কুইজের স্ন্যাপশট ও চেষ্টাগুলি বদলাবে না।';

  @override
  String get quizArchiveConfirm => 'প্রশ্ন আর্কাইভ করুন';

  @override
  String get quizArchiveFailed => 'ব্যাংকের প্রশ্ন আর্কাইভ করা যায়নি।';

  @override
  String get quizArchived => 'ব্যাংকের প্রশ্ন আর্কাইভ করা হয়েছে।';

  @override
  String get quizDuplicateQuestionFailed => 'ব্যাংকের প্রশ্ন কপি করা যায়নি।';

  @override
  String get quizQuestionDuplicated => 'ব্যাংকের প্রশ্নের কপি তৈরি হয়েছে।';

  @override
  String quizQuestionActions(String question) {
    return '$question-এর জন্য কাজগুলি';
  }

  @override
  String get quizActionEdit => 'ব্যাংকের প্রশ্ন সম্পাদনা করুন';

  @override
  String get quizActionDuplicate => 'ব্যাংকের প্রশ্ন কপি করুন';

  @override
  String get quizActionArchive => 'ব্যাংকের প্রশ্ন আর্কাইভ করুন';

  @override
  String get quizActionRevisions => 'প্রশ্নের সংস্করণের ইতিহাস পড়ুন';

  @override
  String quizActionAddTo(String title) {
    return '$title-এ যোগ করুন';
  }

  @override
  String get quizRefreshBeforeDraft =>
      'আরেকটি খসড়া তৈরি করার আগে কুইজের তালিকা রিফ্রেশ করে দেখে নিন।';

  @override
  String quizDraftUnconfirmed(String reason) {
    return '$reason খসড়া সেভ হওয়া নিশ্চিত করা যায়নি। আরেকটি খসড়া তৈরি করার আগে কুইজের তালিকা রিফ্রেশ করুন।';
  }

  @override
  String get quizSavedDraftMismatch => 'সেভ করা খসড়া মেলেনি।';

  @override
  String get quizDraftSaved => 'কুইজের খসড়া সেভ হয়েছে।';

  @override
  String get quizAddToQuizFailed => 'প্রশ্নটি এই কুইজে যোগ করা যায়নি।';

  @override
  String get quizAddedToQuiz => 'প্রশ্নটি কুইজে যোগ করা হয়েছে।';

  @override
  String get quizPublishTitle => 'কুইজ প্রকাশ করবেন?';

  @override
  String quizPublishMessage(String title) {
    return 'যোগ্য শিক্ষার্থীদের জন্য \"$title\" প্রকাশ করবেন? এই কুইজের প্রশ্নগুলি আর বদলানো যাবে না।';
  }

  @override
  String quizPublishMessageSnapshots(String title) {
    return 'যোগ্য শিক্ষার্থীদের জন্য \"$title\" প্রকাশ করবেন? প্রশ্নগুলি পড়াশোনার স্থায়ী স্ন্যাপশট হয়ে যাবে।';
  }

  @override
  String get quizPublishConfirm => 'কুইজ প্রকাশ করুন';

  @override
  String get quizPublishUnconfirmed =>
      'প্রকাশ হওয়া নিশ্চিত করা যায়নি। আবার চেষ্টা করার আগে রিফ্রেশ করে কুইজের অবস্থা দেখুন।';

  @override
  String get quizPublishedNoRecipients =>
      'কুইজ প্রকাশিত হয়েছে। জানানোর মতো কোনো যোগ্য শিক্ষার্থী নেই।';

  @override
  String get quizNoEligibleToNotify => 'জানানোর মতো কোনো যোগ্য শিক্ষার্থী নেই।';

  @override
  String get quizPublishedNoneDelivered =>
      'কুইজ প্রকাশিত হয়েছে, কিন্তু কোনো শিক্ষার্থীর ডিভাইসে বিজ্ঞপ্তি পৌঁছায়নি। বিজ্ঞপ্তি রেজিস্ট্রেশন ও সার্ভারের Firebase ক্রেডেনশিয়াল দেখুন।';

  @override
  String quizPublishedWithFailures(String sent, String failures) {
    return 'কুইজ প্রকাশিত হয়েছে। $sentটি ডিভাইসে বিজ্ঞপ্তি পাঠানো হয়েছে এবং $failuresটি ব্যর্থ হয়েছে।';
  }

  @override
  String quizPublishedSent(String sent) {
    return 'কুইজ প্রকাশিত হয়েছে। $sentটি ডিভাইসে বিজ্ঞপ্তি পাঠানো হয়েছে।';
  }

  @override
  String get quizCloseTitle => 'কুইজ বন্ধ করবেন?';

  @override
  String quizCloseMessage(String title) {
    return '\"$title\" বন্ধ করবেন? কোনো নতুন চেষ্টা শুরু করা যাবে না এবং চলতি চেষ্টাগুলি শেষ করে দেওয়া হবে।';
  }

  @override
  String quizCloseMessageFinalized(String title) {
    return '\"$title\" বন্ধ করবেন? কোনো নতুন চেষ্টা শুরু করা যাবে না এবং চলতি চেষ্টাগুলি চূড়ান্ত করা হবে।';
  }

  @override
  String get quizCloseConfirm => 'কুইজ বন্ধ করুন';

  @override
  String get quizCloseFailed => 'কুইজটি বন্ধ করা যায়নি।';

  @override
  String get quizClosed => 'কুইজ বন্ধ হয়েছে।';

  @override
  String get quizDuplicateQuizFailed => 'কুইজটির কপি তৈরি করা যায়নি।';

  @override
  String get quizQuizDuplicated => 'সম্পাদনাযোগ্য কুইজের খসড়া তৈরি হয়েছে।';

  @override
  String get quizDraftAccountChanged =>
      'আপনার অ্যাকাউন্ট বদলে গেছে। এই খসড়াটি এখানে পর্যালোচনা করা যাবে না।';

  @override
  String get quizDraftLoadFailed =>
      'খসড়া বা প্রশ্ন ব্যাংক লোড করা যায়নি। এগিয়ে যাওয়ার আগে রিফ্রেশ করুন।';

  @override
  String quizBankRefreshFailed(String reason) {
    return '$reason প্রশ্ন ব্যাংক রিফ্রেশ করা যায়নি। কোনো প্রশ্ন যোগ হয়নি। আবার \'সংরক্ষিত প্রশ্ন বেছে নিন\' বেছে নিন।';
  }

  @override
  String get quizSavedListUnreadable => 'সংরক্ষিত প্রশ্নের তালিকা পড়া যায়নি।';

  @override
  String get quizNoUnusedQuestions =>
      'এই ওয়ার্কস্পেসে কোনো অব্যবহৃত প্রশ্ন নেই। \'একটি প্রশ্ন লিখুন\' বেছে নিন।';

  @override
  String get quizAllSavedQuestionsUsed =>
      'সব সংরক্ষিত প্রশ্ন আগে থেকেই এই কুইজে আছে। \'একটি প্রশ্ন লিখুন\' বেছে নিন।';

  @override
  String get quizChooseSaved => 'সংরক্ষিত প্রশ্ন বেছে নিন';

  @override
  String quizSavedQuestionFrom(
    String question,
    String className,
    String subjectName,
  ) {
    return '$question। $className, $subjectName থেকে';
  }

  @override
  String get quizAnotherClass => 'অন্য একটি ক্লাস';

  @override
  String get quizAnotherSubject => 'অন্য একটি বিষয়';

  @override
  String quizAddUnconfirmed(String reason) {
    return '$reason প্রশ্নটি যোগ হয়েছে কিনা নিশ্চিত করা যায়নি। আবার যোগ করার আগে রিফ্রেশ করে সংরক্ষিত প্রশ্নগুলি দেখে নিন; এটি হয়তো আগেই সংরক্ষিত হয়েছে।';
  }

  @override
  String get quizQuestionAddedSentence => 'প্রশ্ন যোগ হয়েছে।';

  @override
  String get quizAddAnotherOrReview =>
      'আরেকটি যোগ করুন বা \'পর্যালোচনা\' বেছে নিন।';

  @override
  String quizQuestionsSaved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি প্রশ্ন সংরক্ষিত হয়েছে।',
      one: '1টি প্রশ্ন সংরক্ষিত হয়েছে।',
    );
    return '$_temp0';
  }

  @override
  String quizQuestionsSavedRaw(String count) {
    return '$countটি প্রশ্ন সংরক্ষিত হয়েছে।';
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
    return '$title। $description $countটি প্রশ্ন।';
  }

  @override
  String get quizUngradedPracticeSummary =>
      'নম্বর ছাড়া অনুশীলন। যতবার খুশি চেষ্টা। কোনো টাইমার নেই।';

  @override
  String quizGradedSummary(String attempts) {
    return 'নম্বরযুক্ত কুইজ। $attempts।';
  }

  @override
  String quizGradedSummaryRaw(String count) {
    return 'নম্বরযুক্ত কুইজ। $countটি চেষ্টা।';
  }

  @override
  String get quizNoTimer => 'কোনো টাইমার নেই।';

  @override
  String quizPerAttempt(String duration) {
    return 'প্রতি চেষ্টায় $duration।';
  }

  @override
  String quizMinutesPerAttemptRaw(String minutes) {
    return 'প্রতি চেষ্টায় $minutes মিনিট।';
  }

  @override
  String quizOpensSentence(String when) {
    return 'খুলবে $when।';
  }

  @override
  String quizOpensColon(String value) {
    return 'খুলবে: $value।';
  }

  @override
  String quizClosesColon(String value) {
    return 'বন্ধ হবে: $value।';
  }

  @override
  String get quizWhenPublished => 'প্রকাশ করার সময়';

  @override
  String get quizNeverNotScheduled => 'কখনো না, সময় ঠিক করা নেই';

  @override
  String get quizNotScheduled => 'সময় ঠিক করা নেই';

  @override
  String quizShuffleQuestionsState(String state) {
    return 'প্রশ্ন এলোমেলো করা $state।';
  }

  @override
  String quizShuffleOptionsState(String state) {
    return 'বিকল্প এলোমেলো করা $state।';
  }

  @override
  String quizShuffleQuestionsColon(String state) {
    return 'প্রশ্ন এলোমেলো করা: $state।';
  }

  @override
  String quizShuffleOptionsColon(String state) {
    return 'বিকল্প এলোমেলো করা: $state।';
  }

  @override
  String get quizRemoveChoose =>
      'এই খসড়া থেকে সরানোর জন্য একটি প্রশ্ন বেছে নিন';

  @override
  String quizRemoveOption(String number, String text) {
    return 'প্রশ্ন $number: $text';
  }

  @override
  String get quizRemoveTitle => 'বেছে নেওয়া প্রশ্নটি সরাবেন?';

  @override
  String get quizRemoveMessage =>
      'এই প্রশ্নটি খসড়া থেকে সরাবেন? পুনরায় ব্যবহারযোগ্য প্রশ্ন ব্যাংক বদলাবে না।';

  @override
  String get quizRemoveConfirm => 'প্রশ্ন সরান';

  @override
  String get quizRemoveUnconfirmed =>
      'সরানো হয়েছে কিনা নিশ্চিত করা যায়নি। আবার চেষ্টা করার আগে রিফ্রেশ করা খসড়াটি দেখে নিন।';

  @override
  String get quizQuestionRemovedSentence => 'প্রশ্নটি খসড়া থেকে সরানো হয়েছে।';

  @override
  String get quizSettingsUnconfirmed =>
      'সেটিংস সংরক্ষিত হয়েছে কিনা নিশ্চিত করা যায়নি। প্রকাশ করার আগে রিফ্রেশ করে সংরক্ষিত সেটিংস দেখে নিন।';

  @override
  String get quizSettingsSaved =>
      'কুইজের সেটিংস সংরক্ষিত হয়েছে। প্রকাশ করার আগে সেগুলি দেখে নিন।';

  @override
  String quizSavedQuestion(String number, String text) {
    return 'সংরক্ষিত প্রশ্ন $number: $text। আগে থেকেই এই খসড়ায় আছে। বিকল্পগুলি শুনতে ওকে টিপুন';
  }

  @override
  String quizQuestionNumbered(String number, String text) {
    return 'প্রশ্ন $number। $text।';
  }

  @override
  String quizDraftOption(String number, String text) {
    return 'বিকল্প $number: $text।';
  }

  @override
  String quizDraftOptionCorrect(String number, String text) {
    return 'বিকল্প $number: $text, সঠিক উত্তর।';
  }

  @override
  String get quizReviewingBeforePublishing =>
      'প্রকাশ করার আগে পর্যালোচনা চলছে।';

  @override
  String get quizAddingQuestions => 'প্রশ্ন যোগ করা হচ্ছে।';

  @override
  String get quizRefreshSavedDraft => 'সংরক্ষিত খসড়া রিফ্রেশ করুন';

  @override
  String get quizWriteQuestionTarget =>
      'একটি প্রশ্ন লিখুন এবং এই কুইজে ও আপনার প্রশ্ন ব্যাংকে সংরক্ষণ করুন';

  @override
  String get quizReviewBeforePublishingTarget =>
      'প্রকাশ করার আগে প্রশ্ন ও কুইজের সেটিংস পর্যালোচনা করুন';

  @override
  String get quizRemoveQuestionTarget =>
      'নিশ্চিত করে এই খসড়া থেকে একটি প্রশ্ন সরান';

  @override
  String get quizChangeSettingsTarget => 'শিরোনাম বা ঐচ্ছিক কুইজ সেটিংস বদলান';

  @override
  String get quizBackToAdding => 'প্রশ্ন যোগ করায় ফিরে যান';

  @override
  String get quizPublishWithConfirmation => 'নিশ্চিত করে কুইজ প্রকাশ করুন';

  @override
  String get quizSaveForLaterTarget =>
      'পরের জন্য সংরক্ষণ করে ফিরে যান। নিশ্চিত হওয়া পরিবর্তনগুলি আগেই খসড়া হিসেবে সংরক্ষিত আছে';

  @override
  String get quizDraftNavigationReview =>
      'সংরক্ষিত প্রশ্ন, কুইজের সেটিংস, এবং নিশ্চিত করে প্রকাশ';

  @override
  String get quizDraftNavigationAdd =>
      'প্রশ্ন লিখুন বা সংরক্ষিত প্রশ্ন বেছে নিন, প্রশ্ন সরান, এবং খসড়া পর্যালোচনা করুন';

  @override
  String get quizPublishedScreen => 'কুইজ প্রকাশিত হয়েছে';

  @override
  String get quizDraftStep3 =>
      'ধাপ 3 এর 3। প্রকাশ করার আগে পর্যালোচনা করুন। আপনি নিশ্চিত না করা পর্যন্ত কিছুই প্রকাশ হবে না।';

  @override
  String get quizDraftStep2 =>
      'ধাপ 2 এর 3। প্রশ্ন যোগ করুন। \'লিখুন\' বা \'সংরক্ষিত প্রশ্ন ব্যবহার করুন\' বেছে নিন। তারপর \'পর্যালোচনা\'।';

  @override
  String get quizSaveForLater => 'পরের জন্য সংরক্ষণ করে ফিরে যান';

  @override
  String get quizWriteQuestion => 'একটি প্রশ্ন লিখুন';

  @override
  String get quizUseSavedQuestion => 'সংরক্ষিত প্রশ্ন ব্যবহার করুন';

  @override
  String get quizRemoveQuestion => 'একটি প্রশ্ন সরান';

  @override
  String get quizReview => 'পর্যালোচনা';

  @override
  String get quizPublishConfirmLabel => 'নিশ্চিত করে প্রকাশ করুন';

  @override
  String get quizChangeSettingsLabel => 'শিরোনাম বা ঐচ্ছিক সেটিংস বদলান';

  @override
  String quizResultsScreen(String title) {
    return '$title-এর ফলাফল';
  }

  @override
  String get quizResultsNavigation =>
      'কুইজের সারাংশ, শিক্ষার্থীদের ফলাফল, এবং ফলাফলের উপলব্ধ কাজগুলি';

  @override
  String get quizResultsFailed => 'কুইজের ফলাফল লোড করা যায়নি।';

  @override
  String quizStudentsCompleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count জন শিক্ষার্থী সম্পূর্ণ করেছে।',
      one: '1 জন শিক্ষার্থী সম্পূর্ণ করেছে।',
    );
    return '$_temp0';
  }

  @override
  String quizStudentsNotAttemptedYet(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count জন শিক্ষার্থী এখনও চেষ্টা করেনি।',
      one: '1 জন শিক্ষার্থী এখনও চেষ্টা করেনি।',
    );
    return '$_temp0';
  }

  @override
  String quizResultsLoadedRaw(String completed, String notAttempted) {
    return '$completed জন শিক্ষার্থী সম্পূর্ণ করেছে। $notAttempted জন শিক্ষার্থী চেষ্টা করেনি।';
  }

  @override
  String quizStatEligible(String value) {
    return 'যোগ্য: $value';
  }

  @override
  String quizStatStarted(String value) {
    return 'শুরু করেছে: $value';
  }

  @override
  String quizStatCompleted(String value) {
    return 'সম্পূর্ণ করেছে: $value';
  }

  @override
  String quizStatNotAttempted(String value) {
    return 'চেষ্টা করেনি: $value';
  }

  @override
  String quizStatCompletion(String value) {
    return 'সম্পূর্ণতা: $value';
  }

  @override
  String quizStatCompletionPercent(String value) {
    return 'সম্পূর্ণতা: $value শতাংশ';
  }

  @override
  String get quizPracticeParticipation =>
      'অনুশীলনে অংশগ্রহণ, পড়াশোনার নম্বর নয়।';

  @override
  String quizStatAverageHighest(String value) {
    return 'সর্বোচ্চ স্কোরের গড়: $value';
  }

  @override
  String quizStatLowest(String value) {
    return 'সম্পূর্ণ চেষ্টার সর্বনিম্ন স্কোর: $value';
  }

  @override
  String quizStudentNotAttempted(String name) {
    return '$name এই কুইজটি চেষ্টা করেনি।';
  }

  @override
  String quizStudentPractice(int count, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$name। $countটি অনুশীলন চেষ্টা। পড়াশোনার নম্বর নয়।',
      one: '$name। 1টি অনুশীলন চেষ্টা। পড়াশোনার নম্বর নয়।',
    );
    return '$_temp0';
  }

  @override
  String quizStudentPracticeRaw(String name, String count) {
    return '$name। $countটি অনুশীলন চেষ্টা। পড়াশোনার নম্বর নয়।';
  }

  @override
  String quizStudentAttemptScore(String number, String score, String status) {
    return 'চেষ্টা $number, $score, $status';
  }

  @override
  String quizStudentAttemptRaw(String number, String score, String status) {
    return 'চেষ্টা $number, $score শতাংশ, $status';
  }

  @override
  String quizStudentScores(String name, String highest, String scores) {
    return '$name। সর্বোচ্চ স্কোর $highest। $scores।';
  }

  @override
  String quizStudentScoresRaw(String name, String highest, String scores) {
    return '$name। সর্বোচ্চ স্কোর $highest শতাংশ। $scores।';
  }

  @override
  String get quizExtraMismatch =>
      'অতিরিক্ত সময়ের নিশ্চিতকরণ মেলেনি। আবার চেষ্টা করার আগে রিফ্রেশ করুন।';

  @override
  String get quizExtraSaved =>
      'অতিরিক্ত সময় শুধু ভবিষ্যতের চেষ্টাগুলির জন্য নিশ্চিত হয়েছে। চলতি চেষ্টাগুলির শেষ সময় বদলায়নি এবং কুইজ বন্ধের সময় এখনও প্রযোজ্য।';

  @override
  String get quizEveryoneAttempted =>
      'সব যোগ্য শিক্ষার্থী এই কুইজটি চেষ্টা করেছে।';

  @override
  String get quizRemindTitle => 'শিক্ষার্থীদের মনে করিয়ে দেবেন?';

  @override
  String quizRemindMessage(int count, String title) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$title যে $count জন শিক্ষার্থী চেষ্টা করেনি, তাদের সবাইকে একটি কুইজ রিমাইন্ডার পাঠাবেন?',
      one:
          '$title যে 1 জন শিক্ষার্থী চেষ্টা করেনি, তাকে একটি কুইজ রিমাইন্ডার পাঠাবেন?',
    );
    return '$_temp0';
  }

  @override
  String quizRemindMessageRaw(String count, String title) {
    return '$title যে $count জন শিক্ষার্থী চেষ্টা করেনি, তাদের সবাইকে একটি কুইজ রিমাইন্ডার পাঠাবেন?';
  }

  @override
  String get quizRemindConfirm => 'রিমাইন্ডার পাঠান';

  @override
  String get quizRemindFailed => 'কুইজ রিমাইন্ডার পাঠানো যায়নি।';

  @override
  String quizReminded(String notified, String queued) {
    return '$notified জন শিক্ষার্থীকে রিমাইন্ডার পাঠানো হয়েছে। $queuedটি ডিভাইস বিজ্ঞপ্তি সারিতে আছে।';
  }

  @override
  String quizReminderProcessed(String notified, String queued) {
    return '$notified জন শিক্ষার্থীর জন্য রিমাইন্ডার প্রক্রিয়া হয়েছে। $queuedটি ডিভাইস বিজ্ঞপ্তি সারিতে আছে।';
  }

  @override
  String get quizRefreshResults => 'কুইজের ফলাফল রিফ্রেশ করুন';

  @override
  String get quizRefreshResultsLabel => 'ফলাফল রিফ্রেশ করুন';

  @override
  String get quizRemindAllLabel =>
      'যারা চেষ্টা করেনি সেই সব শিক্ষার্থীকে মনে করিয়ে দিন';

  @override
  String get quizRemindUnavailable =>
      'সব শিক্ষার্থী চেষ্টা করেছে। রিমাইন্ডার পাওয়া যাবে না';

  @override
  String quizRemindTarget(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'যে $count জন শিক্ষার্থী চেষ্টা করেনি, তাদের সবাইকে রিমাইন্ডার পাঠান',
      one: 'যে 1 জন শিক্ষার্থী চেষ্টা করেনি, তাকে রিমাইন্ডার পাঠান',
    );
    return '$_temp0';
  }

  @override
  String quizRemindTargetRaw(String count) {
    return 'যে $count জন শিক্ষার্থী চেষ্টা করেনি, তাদের সবাইকে রিমাইন্ডার পাঠান';
  }

  @override
  String quizExtraTarget(String name, String duration) {
    return '$name-এর জন্য অতিরিক্ত সময় ঠিক করুন। শুধু ভবিষ্যতের চেষ্টার জন্য। এখনকার অতিরিক্ত সময় $duration';
  }

  @override
  String quizExtraTargetRaw(String name, String minutes) {
    return '$name-এর জন্য অতিরিক্ত মিনিট ঠিক করুন। শুধু ভবিষ্যতের চেষ্টার জন্য। এখনকার অতিরিক্ত $minutes মিনিট';
  }

  @override
  String quizExtraButton(String minutes) {
    return 'ভবিষ্যতের অতিরিক্ত সময়: $minutes মিনিট। ঠিক করুন';
  }

  @override
  String get quizResultsNotLoaded => 'ফলাফল লোড হয়নি।';

  @override
  String quizCompletionSentence(String percent) {
    return 'সম্পূর্ণতা $percent।';
  }

  @override
  String quizExtraScreen(String name) {
    return '$name-এর জন্য অতিরিক্ত সময়। শুধু ভবিষ্যতের চেষ্টার জন্য; চলতি চেষ্টার শেষ সময় একই থাকবে। কুইজ বন্ধের সময় এখনও প্রযোজ্য। শূন্য মিনিট লিখলে অতিরিক্ত সময় সরে যাবে। বাতিল করতে ঘরের বাইরে 0 টিপুন।';
  }

  @override
  String quizExtraField(String value) {
    return 'অতিরিক্ত মিনিট, এখন $value। সম্পাদনা করতে ওকে টিপুন';
  }

  @override
  String get quizEmpty => 'খালি';

  @override
  String get quizExtraSave =>
      'ভবিষ্যতের চেষ্টার জন্য অতিরিক্ত সময় সংরক্ষণ করুন';

  @override
  String get quizExtraCancel => 'অতিরিক্ত সময় না বদলে বাতিল করুন';

  @override
  String get quizExtraInvalid =>
      'মিনিটের একটি পূর্ণ সংখ্যা লিখুন, শূন্য বা তার বেশি, সার্ভারের পূর্ণসংখ্যার সীমার মধ্যে।';

  @override
  String get quizExtraCorrect => 'ঠিক করতে উপরে \'অতিরিক্ত মিনিট\'-এ যান।';

  @override
  String get quizEditorInvalid =>
      'একটি প্রশ্ন, চারটি আলাদা খালি নয় এমন বিকল্প লিখুন, তারপর সঠিক উত্তর বেছে নিন।';

  @override
  String get quizEditorSpokenInvalid =>
      'সর্বোচ্চ 20টি আলাদা বিষয়বস্তু ব্যবহার করুন, প্রতিটি 80 অক্ষরের মধ্যে। বর্ণনা করা চিহ্নের জন্য একটি কথ্য প্রশ্ন, চারটি কথ্য বিকল্প, এবং ব্যাখ্যা দিলে একটি কথ্য ব্যাখ্যা লাগবে। সংরক্ষণের আগে প্রতিটি কথ্য বিকল্প রূপ পর্যালোচনা করে নিশ্চিত করুন।';

  @override
  String quizCorrectChosen(String number, String count) {
    return 'সঠিক উত্তর: বিকল্প $number, $count এর $number।';
  }

  @override
  String quizCorrectChosenWithText(String number, String text, String count) {
    return 'সঠিক উত্তর: বিকল্প $number, $text, $count এর $number।';
  }

  @override
  String get quizCorrectNotSelected =>
      'সঠিক উত্তর বেছে নেওয়া হয়নি। বেছে নিতে বাঁ বা ডান ব্যবহার করুন';

  @override
  String quizCorrectTarget(String number, String text) {
    return 'সঠিক উত্তর: বিকল্প $number, $text। বদলাতে বাঁ বা ডান ব্যবহার করুন';
  }

  @override
  String quizToggled(String name, String state) {
    return '$name $state।';
  }

  @override
  String get quizContentDescribed =>
      'বিষয়বস্তু: শিক্ষকের বর্ণনা করা চিহ্ন বা চিত্র';

  @override
  String get quizContentPlain => 'বিষয়বস্তু: সাধারণ ইংরেজি লেখা';

  @override
  String get quizReviewedYes =>
      'কথ্য বিকল্প রূপগুলি শিক্ষক পর্যালোচনা করেছেন: হ্যাঁ';

  @override
  String get quizReviewedNo =>
      'কথ্য বিকল্প রূপগুলি শিক্ষক পর্যালোচনা করেছেন: না';

  @override
  String get quizSettingsInvalid =>
      'শিরোনাম, 1 থেকে 20 পর্যন্ত চেষ্টার সীমা, সময়সীমা, এবং সময়সূচি দেখে নিন। বন্ধের সময় খোলার সময়ের পরে হতে হবে।';

  @override
  String get quizSetOpening =>
      'তারিখ ও সময়ের সংখ্যার ঘর ব্যবহার করে খোলার সময় ঠিক করুন।';

  @override
  String get quizSetClosing =>
      'তারিখ ও সময়ের সংখ্যার ঘর ব্যবহার করে বন্ধের সময় ঠিক করুন।';

  @override
  String quizOpeningSet(String when) {
    return 'খোলার সময় $when ঠিক করা হয়েছে।';
  }

  @override
  String quizClosingSet(String when) {
    return 'বন্ধের সময় $when ঠিক করা হয়েছে।';
  }

  @override
  String quizReleaseSet(String when) {
    return 'ফিডব্যাক প্রকাশের সময় $when ঠিক করা হয়েছে।';
  }

  @override
  String get quizOpeningCleared => 'খোলার সময় মুছে ফেলা হয়েছে।';

  @override
  String get quizClosingCleared => 'বন্ধের সময় মুছে ফেলা হয়েছে।';

  @override
  String get quizNoOpeningTime => 'কোনো খোলার সময় ঠিক করা নেই';

  @override
  String get quizNoClosingTime => 'কোনো বন্ধের সময় ঠিক করা নেই';

  @override
  String quizOpensAt(String when) {
    return 'খুলবে $when';
  }

  @override
  String quizClosesAt(String when) {
    return 'বন্ধ হবে $when';
  }

  @override
  String quizPolicyChoice(String name, String position, String count) {
    return 'ফিডব্যাক: $name, $count এর $position।';
  }

  @override
  String quizScheduledRelease(String when) {
    return 'ফিডব্যাক প্রকাশের নির্ধারিত সময় $when';
  }

  @override
  String quizAttemptLimitField(String value) {
    return 'চেষ্টার সীমা, এখন $value। সম্পাদনা করতে ওকে টিপুন';
  }

  @override
  String quizTimeLimitField(String value) {
    return 'মিনিটে ঐচ্ছিক সময়সীমা, $value। সম্পাদনা করতে ওকে টিপুন';
  }

  @override
  String get quizRevisionsScreen =>
      'প্রশ্ন সংশোধনের ব্যক্তিগত ইতিহাস, শুধু পড়ার জন্য। পুরনো ও নতুন সংশোধনের বোতাম ব্যবহার করুন, তারপর প্রতিটি অংশ পড়ুন।';

  @override
  String get quizRevisionsAccount =>
      'আপনার অ্যাকাউন্ট বদলে গেছে। প্রশ্নের ব্যক্তিগত ইতিহাস দেখার আগে ফিরে গিয়ে আবার সাইন ইন করুন।';

  @override
  String get quizRevisionsCleared =>
      'আপনার অ্যাকাউন্ট বদলে গেছে। প্রশ্নের ব্যক্তিগত ইতিহাস মুছে ফেলা হয়েছে।';

  @override
  String get quizRevisionsUnverified =>
      'প্রশ্ন সংশোধনের ইতিহাস যাচাই করা যায়নি। আবার লোড করার চেষ্টা করুন।';

  @override
  String get quizRevisionsContentUnverified =>
      'প্রশ্ন সংশোধনের বিষয়বস্তু যাচাই করা যায়নি। আবার লোড করার চেষ্টা করুন।';

  @override
  String get quizRevisionsTimedOut =>
      'প্রশ্নের ইতিহাস আনতে অনেক সময় লেগেছে। আপনার সংযোগ দেখে আবার চেষ্টা করুন।';

  @override
  String get quizNoRevisions =>
      'কোনো রেকর্ড করা সংশোধন নেই। প্রশ্নের পুরনো ইতিহাস জানা নেই, তা আবার তৈরি করা হয়নি।';

  @override
  String quizRevisionsLoaded(int count, String revision, String when) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$countটি সংশোধন লোড হয়েছে। শুধু পড়ার জন্য প্রশ্ন সংশোধন $revision, সংরক্ষিত $when। আগের কুইজ ও চেষ্টার স্ন্যাপশট বদলানো হয়নি।',
      one:
          '1টি সংশোধন লোড হয়েছে। শুধু পড়ার জন্য প্রশ্ন সংশোধন $revision, সংরক্ষিত $when। আগের কুইজ ও চেষ্টার স্ন্যাপশট বদলানো হয়নি।',
    );
    return '$_temp0';
  }

  @override
  String get quizDateUnknown => 'তারিখ জানা নেই';

  @override
  String quizRevisionSelected(String revision) {
    return 'সংশোধন $revision বেছে নেওয়া হয়েছে। শুধু পড়ার জন্য।';
  }

  @override
  String quizRevisionSelectedOf(
    String revision,
    String position,
    String count,
  ) {
    return 'সংশোধন $revision বেছে নেওয়া হয়েছে, $count এর $position। শুধু পড়ার জন্য।';
  }

  @override
  String quizRevisionFailed(String message) {
    return '$message ফোকাস \'সংশোধন রিফ্রেশ করুন\'-এ আছে।';
  }

  @override
  String get quizNoRevisionLoaded => 'কোনো সংশোধন লোড হয়নি।';

  @override
  String quizShowingRevision(String revision) {
    return 'সংশোধন $revision দেখানো হচ্ছে। শুধু পড়ার জন্য।';
  }

  @override
  String quizRevisionVersion(String revision, String when) {
    return 'সংশোধন $revision। সংরক্ষিত $when। শুধু পড়ার জন্য।';
  }

  @override
  String quizRevisionQuestion(String text) {
    return 'প্রশ্ন: $text';
  }

  @override
  String quizRevisionTopics(String topics) {
    return 'বিষয়বস্তু: $topics';
  }

  @override
  String quizRevisionOption(String number, String text) {
    return 'বিকল্প $number: $text।';
  }

  @override
  String get quizCorrectAnswerSentence => 'সঠিক উত্তর।';

  @override
  String quizRevisionExplanation(String text) {
    return 'ব্যাখ্যা: $text';
  }

  @override
  String get quizNotProvided => 'দেওয়া হয়নি';

  @override
  String get quizRevisionNotice =>
      'শুধু রেকর্ড রাখা শুরু হওয়ার পরে সংরক্ষিত সংশোধনগুলি পাওয়া যায়। পুরনো ইতিহাস জানা নেই। আগের কুইজ ও চেষ্টার স্ন্যাপশট কখনো বদলানো হয় না।';

  @override
  String quizRevisionVersionTitle(String revision, String when) {
    return 'সংশোধন $revision, $when';
  }

  @override
  String get quizQuestionTextTitle => 'প্রশ্নের লেখা';

  @override
  String get quizTopicsTitle => 'বিষয়বস্তু';

  @override
  String quizOptionNumber(String number) {
    return 'বিকল্প $number';
  }

  @override
  String quizOptionNumberCorrect(String number) {
    return 'বিকল্প $number, সঠিক উত্তর';
  }

  @override
  String get quizExplanationTitle => 'ব্যাখ্যা';

  @override
  String get quizRevisionNoticeTitle => 'সংশোধনের ইতিহাস সম্পর্কে';

  @override
  String quizRevisionSectionTarget(String title) {
    return '$title। শুনতে ওকে টিপুন';
  }

  @override
  String get quizAccountChangedSignIn =>
      'অ্যাকাউন্ট বদলে গেছে। ফিরে গিয়ে আবার সাইন ইন করুন।';

  @override
  String get quizGoBack => 'ফিরে যান';

  @override
  String get quizCancel => 'বাতিল করুন';

  @override
  String get quizCancelAndReturn => 'বাতিল করে ফিরে যান';

  @override
  String get quizActionNavigation => 'উপলব্ধ কাজগুলি এবং বাতিল';

  @override
  String get quizRefreshRevisions => 'সংশোধন রিফ্রেশ করুন';

  @override
  String get quizNewerRevision => 'নতুন সংশোধন';

  @override
  String get quizOlderRevision => 'পুরনো সংশোধন';

  @override
  String get quizBankArchived => 'ব্যাংকের প্রশ্ন আর্কাইভ করা হয়েছে';

  @override
  String get quizBankCopied => 'ব্যাংকের প্রশ্নের কপি তৈরি হয়েছে';

  @override
  String get quizSnapshotAdded => 'প্রশ্নের স্ন্যাপশট কুইজে যোগ হয়েছে';

  @override
  String get quizQuizClosed => 'কুইজ বন্ধ হয়েছে';

  @override
  String get quizDraftCreated => 'সম্পাদনাযোগ্য কুইজের খসড়া তৈরি হয়েছে';

  @override
  String get quizNoAnswerSelected => 'কোনো উত্তর বেছে নেওয়া হয়নি।';

  @override
  String get quizSelectBeforeSubmit => 'জমা দেওয়ার আগে একটি বিকল্প বেছে নিন।';

  @override
  String get quizSubmitBeforeContinuing =>
      'এগিয়ে যাওয়ার আগে আপনার উত্তর জমা দিন।';

  @override
  String get quizTeacherNavigationPrivate =>
      'ব্যক্তিগত ব্যাংক খোঁজা ও সংরক্ষিত প্রশ্ন, কুইজের খসড়া, প্রকাশিত কুইজ, এবং সেগুলির ফলাফল';

  @override
  String get quizStudentNavigationHelp =>
      'ডি-প্যাডের উপর ও নিচ ব্যবহার করে রিফ্রেশ, কুইজের অবস্থার ফিল্টার, বিষয়ের ফিল্টার, প্রতিটি উপলব্ধ কুইজ বা অনুশীলন এবং তার চেষ্টার ইতিহাসে যান। ফিল্টার বদলাতে তার উপর বাম বা ডান ব্যবহার করুন। কুইজের বিবরণ শুনতে এবং শুরু বা আবার চালু করা নিশ্চিত করতে কুইজে ওকে টিপুন; আগের চেষ্টাগুলো দেখতে চেষ্টার ইতিহাসে ওকে টিপুন। শুধু ফোকাস সরালে কোনো চেষ্টা শুরু হয় না।';

  @override
  String get quizNoQuizzesAvailable => 'কোনো কুইজ উপলব্ধ নেই।';

  @override
  String quizQuizzesAvailableRaw(String count) {
    return '$countটি কুইজ উপলব্ধ।';
  }

  @override
  String get quizStudentNavigationSections =>
      'রিফ্রেশ, কুইজের অবস্থা ও বিষয়ের ফিল্টার, উপলব্ধ কুইজ ও অনুশীলন, এবং আগের চেষ্টাগুলো';

  @override
  String quizAttemptLimitReached(String title) {
    return '$title-এর চেষ্টার সীমা শেষ হয়েছে। আপনার নম্বর দেখতে চেষ্টার ইতিহাস খুলুন।';
  }

  @override
  String get quizNoPerAttemptLimit => 'প্রতি চেষ্টায় কোনো সময়সীমা নেই।';

  @override
  String quizTimeLimitRaw(String minutes) {
    return 'সময়সীমা $minutes মিনিট।';
  }

  @override
  String get quizCannotGoBack => 'আপনি পিছনে গিয়ে এটি বদলাতে পারবেন না।';

  @override
  String get quizStartFailedAvailability =>
      'কুইজটি শুরু করা যায়নি। এটি উপলব্ধ কিনা দেখুন।';

  @override
  String get quizStateFieldName => 'কুইজের অবস্থা';

  @override
  String get quizSubjectFieldName => 'বিষয়';

  @override
  String quizUseLeftRightToChange(String item) {
    return '$item। বদলাতে বাম বা ডান ব্যবহার করুন';
  }

  @override
  String get quizAttemptCompletePrivate =>
      'চেষ্টা শেষ। আপনার ফলাফল ব্যক্তিগত থাকবে।';

  @override
  String get quizHelpCompleted =>
      'ডি-প্যাডের উপর ও নিচ ব্যবহার করে কুইজে ফিরে যাওয়া এবং ফলাফল ব্যক্তিগতভাবে শোনার মধ্যে যান। বোতাম চালু করতে ওকে টিপুন। ফলাফল ব্যক্তিগতভাবে শুনতে 8 টিপুন বা ফিরে যেতে 0 টিপুন।';

  @override
  String get quizHelpRetry =>
      'আবার শেষ করার চেষ্টা করতে 5 টিপুন, আপনি কোথায় আছেন শুনতে 8 টিপুন, বা নিশ্চিত করে বেরিয়ে যেতে 0 টিপুন। অন্য নিয়ন্ত্রণের জন্য ডি-প্যাডের উপর ও নিচ ব্যবহার করুন।';

  @override
  String get quizHelpNext =>
      'পরের প্রশ্ন নিজে থেকেই আসবে। আবার শুনতে 6 টিপুন, আপনি কোথায় আছেন শুনতে 8 টিপুন।';

  @override
  String quizHelpChoose(String count) {
    return 'বেছে নিতে 1 থেকে $count টিপুন, তারপর জমা দিতে 5 টিপুন। প্রশ্ন ও বিকল্পগুলো আবার শুনতে 6 টিপুন, আপনি কোথায় আছেন ও কত সময় বাকি শুনতে 8 টিপুন।';
  }

  @override
  String get quizHelpFinishLeave =>
      'এখনই কুইজ শেষ করুন বিকল্পটি ডি-প্যাডের তালিকায় আছে এবং নিশ্চিত করতে বলে। জমা না দিয়ে বেরিয়ে যেতে 0 টিপুন।';

  @override
  String quizSelectedOptionNotSubmitted(String number, String text) {
    return 'বিকল্প $number বেছে নেওয়া হয়েছে। $text। এখনও জমা দেওয়া হয়নি।';
  }

  @override
  String quizSelectedOptionConfirmed(String number, String text) {
    return 'বিকল্প $number বেছে নেওয়া হয়েছে। $text। উত্তর নিশ্চিত হয়েছে।';
  }

  @override
  String quizFeedbackCorrect(String answer, String explanation) {
    return 'সঠিক। সঠিক উত্তর: $answer। $explanation';
  }

  @override
  String quizFeedbackIncorrect(String answer, String explanation) {
    return 'ভুল। সঠিক উত্তর: $answer। $explanation';
  }

  @override
  String quizOptionSelectedNotSubmitted(String number, String text) {
    return 'বিকল্প $number। $text। বেছে নেওয়া হয়েছে, জমা দেওয়া হয়নি। উত্তর সেভ করতে 5 টিপুন।';
  }

  @override
  String get quizAttemptFinishedWhere =>
      'চেষ্টা শেষ। আপনার ফলাফল ব্যক্তিগতভাবে শুনতে 8 টিপুন।';

  @override
  String get quizNoOptionChosenYet => 'এখনও কোনো বিকল্প বেছে নেওয়া হয়নি।';

  @override
  String quizOptionChosen(String number) {
    return 'বিকল্প $number বেছে নেওয়া হয়েছে।';
  }

  @override
  String quizCompletionFailedRetry(String reason) {
    return '$reason আপনার সেভ করা উত্তরগুলো রাখা আছে। ফলাফল দেখতে আবার শেষ করার চেষ্টা করুন বেছে নিন।';
  }

  @override
  String quizAttemptStatusPrivate(String status) {
    return 'চেষ্টা $status। আপনার ফলাফল ব্যক্তিগত।';
  }

  @override
  String get quizEarlyCountUnconfirmed =>
      'সেভ করা উত্তরের বর্তমান সংখ্যা নিশ্চিত করা যায়নি, অথবা এই চেষ্টা শেষ হয়ে গেছে। আগে জমা দেওয়ার কোনো অনুরোধ পাঠানো হয়নি। অবস্থা রিফ্রেশ করতে কুইজের তালিকায় ফিরে যান।';

  @override
  String get quizEarlyTitle => 'এই চেষ্টা আগেই জমা দেবেন?';

  @override
  String quizEarlyMessage(String count) {
    return 'সার্ভারের যাচাই অনুযায়ী $countটি প্রশ্নের উত্তর দেওয়া হয়নি। চূড়ান্ত করার সময় শুধু সার্ভারে সেভ করা উত্তরগুলোই ধরা হবে। বেছে নেওয়া কিন্তু সেভ না করা উত্তর ধরা হবে না। চূড়ান্ত জমা আর ফেরানো বা বদলানো যায় না। পিছনে গেলে কখনও জমা হয় না।';
  }

  @override
  String get quizEarlyConfirm => 'সেভ করা উত্তরগুলো চূড়ান্ত করুন';

  @override
  String get quizEarlyTimedOut =>
      'সেভ করা উত্তর যাচাই করতে সময় শেষ হয়ে গেছে। আগে জমা দেওয়ার কোনো অনুরোধ পাঠানো হয়নি। আপনার সংযোগ দেখে আবার চেষ্টা করুন।';

  @override
  String get quizWaitPending =>
      'বেরোনোর আগে বাকি থাকা উত্তর বা শেষ করার নিশ্চয়তার জন্য অপেক্ষা করুন।';

  @override
  String get quizLeaveMessageServer =>
      'এতে আপনার চেষ্টা জমা হয় না। শুধু সার্ভারে নিশ্চিত হওয়া উত্তরগুলোই সেভ থাকে; সেভ না করা বাছাই হারিয়ে যেতে পারে। কোনো টাইমার থাকলে তা চলতে থাকবে। সার্ভার যতক্ষণ এই চেষ্টার অনুমতি দেয়, শুধু ততক্ষণই আবার চালু করা যাবে।';

  @override
  String get quizStayInAttempt => 'চেষ্টায় থাকুন';

  @override
  String get quizNextQuestionNow => 'এখনই পরের প্রশ্ন';

  @override
  String get quizReadAllOptions => 'সব উত্তরের বিকল্প পড়ুন';

  @override
  String quizOptionTargetSelectedSubmit(String number, String text) {
    return 'বিকল্প $number, $text, বেছে নেওয়া হয়েছে। বেছে নিতে ওকে বা $number টিপুন। প্রস্তুত হলে তবেই জমা দিতে 5 টিপুন';
  }

  @override
  String quizOptionTargetNotSelectedSubmit(String number, String text) {
    return 'বিকল্প $number, $text, বেছে নেওয়া হয়নি। বেছে নিতে ওকে বা $number টিপুন। প্রস্তুত হলে তবেই জমা দিতে 5 টিপুন';
  }

  @override
  String get quizReadSelectionTarget =>
      'বেছে নেওয়া উত্তর ও সেভের অবস্থা পড়ুন';

  @override
  String get quizStopSpeech => 'কথা বলা থামান';

  @override
  String get quizAnswerFeedback => 'উত্তরের ফিডব্যাক';

  @override
  String get quizAnswerConfirmedReadFeedback =>
      'উত্তর সেভ ও লক হয়েছে বলে নিশ্চিত। ফিডব্যাক ব্যক্তিগতভাবে পড়তে ওকে টিপুন।';

  @override
  String get quizRetryCompletion => 'আবার শেষ করার চেষ্টা করুন';

  @override
  String get quizViewResult => 'ফলাফল দেখুন';

  @override
  String get quizNextQuestion => 'পরের প্রশ্ন';

  @override
  String get quizAttemptInProgressResume =>
      'চেষ্টা চলছে। আবার চালু করতে কুইজের তালিকায় ফিরে যান। বেরিয়ে গেলে জমা হয় না।';

  @override
  String get quizReviewTimedOutShort =>
      'চেষ্টা পর্যালোচনার সময় শেষ হয়ে গেছে। আপনার সংযোগ দেখে আবার চেষ্টা করুন।';

  @override
  String get quizNoScoreCurrentlyReleased =>
      'শেষ করা চেষ্টা আছে; এখনও কোনো নম্বর প্রকাশ করা হয়নি।';

  @override
  String get quizHistoryScreenNavigate =>
      'চেষ্টার ইতিহাস। নম্বর ব্যক্তিগত। পর্যালোচনা করতে সারাংশ বা কোনো চেষ্টায় যান।';

  @override
  String quizHistoryAttemptRaw(String number, String status, String result) {
    return 'চেষ্টা $number। $status। $result। পর্যালোচনা করতে ওকে টিপুন।';
  }

  @override
  String quizReviewAnswerCorrect(
    String number,
    String question,
    String selected,
    String answer,
    String explanation,
  ) {
    return 'প্রশ্ন $number। সঠিক। $question। বেছে নেওয়া হয়েছে $selected। সঠিক উত্তর $answer। $explanation';
  }

  @override
  String quizReviewAnswerIncorrect(
    String number,
    String question,
    String selected,
    String answer,
    String explanation,
  ) {
    return 'প্রশ্ন $number। ভুল। $question। বেছে নেওয়া হয়েছে $selected। সঠিক উত্তর $answer। $explanation';
  }

  @override
  String get quizNoAnswerCapital => 'কোনো উত্তর নেই';

  @override
  String quizReviewScreenRaw(String count) {
    return 'চেষ্টা পর্যালোচনা। $countটি প্রশ্ন। প্রতিটি উত্তর দেখতে উপর ও নিচ ব্যবহার করুন।';
  }

  @override
  String get quizMetaTopics => 'বিষয়বস্তু বা ধারণা, প্রতি লাইনে একটি (ঐচ্ছিক)';

  @override
  String get quizMetaSpokenQuestion => 'শিক্ষকের লেখা বলা প্রশ্ন';

  @override
  String quizMetaSpokenOption(String number) {
    return 'বলা বিকল্প $number';
  }

  @override
  String get quizMetaSpokenExplanation => 'শিক্ষকের লেখা বলা ব্যাখ্যা';

  @override
  String quizCorrectSelected(String number) {
    return 'বিকল্প $number সঠিক উত্তর হিসেবে বেছে নেওয়া হয়েছে';
  }

  @override
  String quizCorrectSelectedWithText(String number, String text) {
    return 'বিকল্প $number সঠিক উত্তর হিসেবে বেছে নেওয়া হয়েছে, $text';
  }

  @override
  String get quizEditBankQuestion => 'ব্যাংকের প্রশ্ন সম্পাদনা করুন';

  @override
  String get quizCreateBankQuestion => 'ব্যাংকের প্রশ্ন তৈরি করুন';

  @override
  String get quizEditorNavigation =>
      'প্রশ্নের লেখা, চারটি উত্তরের ঘর, সঠিক উত্তর বাছাই, ঐচ্ছিক বলা বিবরণ, এবং সেভ বা বাতিল';

  @override
  String get quizSaveQuestion => 'প্রশ্ন সেভ করুন';

  @override
  String get quizCancelQuestion => 'প্রশ্ন বাতিল করুন';

  @override
  String quizPressOkToEdit(String item) {
    return '$item। সম্পাদনা করতে ওকে টিপুন';
  }

  @override
  String quizPressOkToChange(String item) {
    return '$item। বদলাতে ওকে টিপুন';
  }

  @override
  String quizCorrectIsOption(String number, String text) {
    return 'বিকল্প $number, $text, সঠিক উত্তর। বদলাতে বাম বা ডান ব্যবহার করুন';
  }

  @override
  String get quizHideOptionalExplanation =>
      'ঐচ্ছিক ব্যাখ্যা, বিষয়বস্তু ও বলা চিহ্ন লুকান';

  @override
  String get quizShowOptionalExplanation =>
      'ঐচ্ছিক ব্যাখ্যা, বিষয়বস্তু ও বলা চিহ্ন দেখান';

  @override
  String get quizOptionalExplanation => 'ঐচ্ছিক উত্তরের ব্যাখ্যা';

  @override
  String quizNumericDateTime(
    String day,
    String month,
    String year,
    String hour,
    String minute,
  ) {
    return '$day/$month/$year, $hour:$minute-এ';
  }

  @override
  String get quizCheckTitleLimits => 'শিরোনাম, সীমা ও সময়সূচি দেখে নিন।';

  @override
  String get quizSettingsNavigation =>
      'শিরোনাম, ঐচ্ছিক বিবরণ, সময় ও চেষ্টার সেটিংস, ফিডব্যাক ও এলোমেলো করার বিকল্প, এবং এগিয়ে যান বা বাতিল';

  @override
  String get quizChangeSettingsScreen =>
      'কুইজের শিরোনাম ও ঐচ্ছিক সেটিংস বদলান। সেভ করলে প্রকাশিত হয় না।';

  @override
  String get quizCreatePracticeScreen =>
      'সময়সীমা ও নম্বর ছাড়া অনুশীলন তৈরি করুন। যতবার খুশি আবার চেষ্টা এবং সঙ্গে সঙ্গে ফিডব্যাক।';

  @override
  String get quizContinueToQuestions => 'প্রশ্নে এগিয়ে যান';

  @override
  String get quizSaveSettingsReturn => 'সেটিংস সেভ করে পর্যালোচনায় ফিরে যান';

  @override
  String get quizQuizTitle => 'কুইজের শিরোনাম';

  @override
  String get quizHideOptionalSettings =>
      'ঐচ্ছিক সেটিংস লুকান: বিবরণ, চেষ্টা, সময়, ফিডব্যাক ও এলোমেলো করা';

  @override
  String get quizShowOptionalSettings =>
      'ঐচ্ছিক সেটিংস দেখান: বিবরণ, চেষ্টা, সময়, ফিডব্যাক ও এলোমেলো করা';

  @override
  String get quizOptionalDescription => 'ঐচ্ছিক কুইজের বিবরণ';

  @override
  String quizSetOrClear(String item) {
    return '$item। সেট করতে ওকে টিপুন। মুছতে বাম ব্যবহার করুন';
  }

  @override
  String quizShuffleQuestionsToggle(String state) {
    return 'প্রশ্ন এলোমেলো করা $state। বদলাতে ওকে বা বাম বা ডান টিপুন';
  }

  @override
  String quizShuffleOptionsToggle(String state) {
    return 'উত্তরের বিকল্প এলোমেলো করা $state। বদলাতে ওকে বা বাম বা ডান টিপুন';
  }

  @override
  String get quizCancelQuizCreation => 'কুইজ তৈরি বাতিল করুন';

  @override
  String quizFeedbackPolicyTarget(String policy) {
    return 'ফিডব্যাক নীতি $policy। বাম বা ডান দিয়ে বদলান';
  }

  @override
  String get quizSaveDraftContinue => 'খসড়া সেভ করে প্রশ্নে এগিয়ে যান';

  @override
  String get sessionScreenTeacherClass => 'শিক্ষকের ক্লাস';

  @override
  String get sessionScreenClass => 'ক্লাস';

  @override
  String get sessionDefaultTitle => 'সেশন';

  @override
  String get sessionJoining =>
      'ক্লাসে যোগ দেওয়া হচ্ছে। অনুগ্রহ করে অপেক্ষা করুন।';

  @override
  String get sessionConnecting => 'ক্লাসের সঙ্গে সংযোগ করা হচ্ছে।';

  @override
  String get sessionJoinFailed =>
      'ক্লাসে যোগ দেওয়া যায়নি। বেরোতে 0 টিপুন, তারপর আবার চেষ্টা করুন।';

  @override
  String get sessionLeaveKeyHint =>
      'ক্লাস ছাড়তে 0 টিপুন। এটি নিশ্চিত করতে বলবে।';

  @override
  String get sessionKeyLine => '*: সাহায্য ও শেষ বার্তা। #: কথা বলা থামান।';

  @override
  String sessionJoinedBrief(String status) {
    return 'ক্লাসে আছেন। $status সাহায্যের জন্য স্টার টিপুন।';
  }

  @override
  String sessionJoinedDetailed(String status, String keys) {
    return 'আপনি ক্লাসে আছেন। $status $keys নিয়ন্ত্রণগুলোর মধ্যে যেতে উপর ও নিচ এবং বেছে নিতে ওকে ব্যবহার করুন। আপনি কোথায় আছেন ও সাহায্যের জন্য স্টার টিপুন। কথা বলা থামাতে হ্যাশ টিপুন।';
  }

  @override
  String get sessionMicWaitingLabel =>
      'মাইক্রোফোন নিশ্চয়তার জন্য অপেক্ষা করছে';

  @override
  String get sessionUnmuteMicrophone => 'মাইক্রোফোন আনমিউট করুন';

  @override
  String get sessionMuteMicrophone => 'মাইক্রোফোন মিউট করুন';

  @override
  String get sessionMuteButtonWaiting => '1: অপেক্ষা করছে';

  @override
  String get sessionMuteButtonUnmute => '1: আনমিউট';

  @override
  String get sessionMuteButtonMute => '1: মিউট';

  @override
  String get sessionHandWaitingLabel => 'হাত নিশ্চয়তার জন্য অপেক্ষা করছে';

  @override
  String get sessionLowerHand => 'হাত নামান';

  @override
  String get sessionRaiseHand => 'হাত তুলুন';

  @override
  String get sessionHandButtonWaiting => '2: অপেক্ষা করছে';

  @override
  String get sessionHandButtonLower => '2: হাত নামান';

  @override
  String get sessionHandButtonRaise => '2: হাত তুলুন';

  @override
  String get sessionStatusLabel => 'ক্লাসের অবস্থা শুনুন';

  @override
  String get sessionStatusButton => '3: ক্লাসের অবস্থা';

  @override
  String sessionChatLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'চ্যাট। $countটি বার্তা',
      one: 'চ্যাট। 1টি বার্তা',
      zero: 'চ্যাট। এখনও কোনো বার্তা নেই',
    );
    return '$_temp0';
  }

  @override
  String get sessionChatButton => '4: চ্যাট';

  @override
  String get sessionRecordingPlayerNone =>
      'পাঠের রেকর্ডিং। এখনও কিছু বেছে নেওয়া হয়নি';

  @override
  String sessionRecordingPlayerPlaying(String title) {
    return 'পাঠের রেকর্ডিং। $title, চলছে';
  }

  @override
  String sessionRecordingPlayerPaused(String title) {
    return 'পাঠের রেকর্ডিং। $title, থামানো আছে';
  }

  @override
  String get sessionRecordingStudentNone =>
      'ক্লাসের রেকর্ডিং। কিছু চলছে না। শুধু শিক্ষক এটি নিয়ন্ত্রণ করেন';

  @override
  String sessionRecordingStudentPlaying(String title) {
    return 'ক্লাসের রেকর্ডিং, $title, শিক্ষক চালাচ্ছেন। এটি কোথায় আছে শুনুন';
  }

  @override
  String sessionRecordingStudentPaused(String title) {
    return 'ক্লাসের রেকর্ডিং, $title, শিক্ষক থামিয়েছেন। এটি কোথায় আছে শুনুন';
  }

  @override
  String get sessionRecordingStatusButton => '5: রেকর্ডিংয়ের অবস্থা';

  @override
  String get sessionStudentRecordingNone =>
      'কোনো ক্লাসের রেকর্ডিং চলছে না। শুধু শিক্ষক রেকর্ডিং চালাতে পারেন।';

  @override
  String sessionStudentRecordingPlaying(String title, String position) {
    return '$title, চলছে, $position-এ। শুধু শিক্ষক ক্লাসের রেকর্ডিং চালাতে, থামাতে বা সরাতে পারেন।';
  }

  @override
  String sessionStudentRecordingPaused(String title, String position) {
    return '$title, থামানো আছে, $position-এ। শুধু শিক্ষক ক্লাসের রেকর্ডিং চালাতে, থামাতে বা সরাতে পারেন।';
  }

  @override
  String get sessionRecordingPlayerButton => '5: পাঠের রেকর্ডিং';

  @override
  String get sessionOpeningPlayerToChoose =>
      'এখনও কোনো রেকর্ডিং বেছে নেওয়া হয়নি। একটি বেছে নিতে 1 টিপুন।';

  @override
  String get sessionCheckLabel => 'শিক্ষকের প্রশ্নের উত্তর দিন';

  @override
  String get sessionCheckButton => '3: প্রশ্নের উত্তর দিন';

  @override
  String sessionHandsLabel(String waiting) {
    return 'তোলা হাত। $waiting';
  }

  @override
  String get sessionHandsButton => '2: তোলা হাত';

  @override
  String sessionHandsButtonCount(int count) {
    return '2: তোলা হাত ($count)';
  }

  @override
  String get sessionTeacherCheckLabel =>
      'ক্লাস যাচাই। একটি ব্যক্তিগত যাচাই শুরু করুন, বন্ধ করুন এবং উত্তরগুলো শুনুন';

  @override
  String sessionParticipantsLabel(String people) {
    return 'অংশগ্রহণকারীরা। $people কাউকে মিউট বা সরিয়ে দিন, অথবা সারাংশ শুনুন';
  }

  @override
  String get sessionParticipantsButton => '7: অংশগ্রহণকারীরা';

  @override
  String get sessionToolsLabel =>
      'শিক্ষকের টুল। সময় বাড়ান বা সবার জন্য ক্লাস শেষ করুন';

  @override
  String get sessionToolsButton => '9: শিক্ষকের টুল';

  @override
  String get sessionVoiceStartLabel =>
      'একটি ভয়েস কমান্ড শুনুন, 12 সেকেন্ড পর্যন্ত। শুধু ওকে টিপলেই শুরু হয়';

  @override
  String get sessionVoiceStopLabel => 'ভয়েস কমান্ড শোনা বন্ধ করুন';

  @override
  String get sessionVoiceStartButton => 'কমান্ড শুনুন';

  @override
  String get sessionVoiceStopButton => 'শোনা বন্ধ করুন';

  @override
  String get sessionUpdatesLabel => 'ক্লাসের আপডেট পড়ুন';

  @override
  String get sessionUpdatesButton => 'ক্লাসের আপডেট';

  @override
  String get sessionRetryLabel => 'ক্লাসের সংযোগ আবার চেষ্টা করুন';

  @override
  String get sessionRetryButton => 'সংযোগ আবার চেষ্টা করুন';

  @override
  String get sessionLeaveLabel => 'ক্লাস ছাড়ুন';

  @override
  String get sessionLeaveButton => '0: ক্লাস ছাড়ুন';

  @override
  String get sessionMicWaiting => 'মাইক্রোফোন নিশ্চয়তার জন্য অপেক্ষা করছে।';

  @override
  String get sessionMicMuted => 'মিউট করা আছে।';

  @override
  String get sessionMicUnmutedHeard =>
      'আনমিউট করা আছে। অন্যরা আপনার কথা শুনতে পাচ্ছেন।';

  @override
  String get sessionHandWaiting => 'হাত নিশ্চয়তার জন্য অপেক্ষা করছে।';

  @override
  String get sessionHandRaisedState => 'হাত তোলা আছে।';

  @override
  String get sessionHandDown => 'হাত নামানো আছে।';

  @override
  String sessionHandsWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি হাত অপেক্ষায় আছে।',
      one: '1টি হাত অপেক্ষায় আছে।',
      zero: 'কোনো হাত অপেক্ষায় নেই।',
    );
    return '$_temp0';
  }

  @override
  String sessionPeople(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ক্লাসে $count জন আছেন।',
      one: 'ক্লাসে 1 জন আছেন।',
    );
    return '$_temp0';
  }

  @override
  String get sessionNoRecordingSelected => 'কোনো রেকর্ডিং বেছে নেওয়া হয়নি।';

  @override
  String sessionRecordingStatePlaying(String title) {
    return 'রেকর্ডিং চলছে: $title।';
  }

  @override
  String sessionRecordingStatePaused(String title) {
    return 'রেকর্ডিং থামানো আছে: $title।';
  }

  @override
  String get sessionCheckOpen => 'ক্লাস যাচাই খোলা আছে।';

  @override
  String sessionConnectionLabel(String label) {
    return '$label।';
  }

  @override
  String sessionChatMessages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি চ্যাট বার্তা।',
      one: '1টি চ্যাট বার্তা।',
    );
    return '$_temp0';
  }

  @override
  String get sessionRecordingFallback => 'ক্লাসের রেকর্ডিং';

  @override
  String get sessionRecordingFallbackLower => 'ক্লাসের রেকর্ডিং';

  @override
  String sessionUserFallback(String id) {
    return 'ব্যবহারকারী $id';
  }

  @override
  String sessionConnectionRestored(String message) {
    return 'সংযোগ ফিরে এসেছে। $message';
  }

  @override
  String sessionConnectionLost(String message) {
    return 'সংযোগ বিচ্ছিন্ন হয়েছে। $message';
  }

  @override
  String sessionCouldNotConnect(String message) {
    return 'সংযোগ করা যায়নি। $message';
  }

  @override
  String get sessionMicDialogTitle => 'মাইক্রোফোনের অনুমতি';

  @override
  String get sessionMicDialogMessage =>
      'এই ক্লাসে SEEDS লাইভ অডিও এবং আপনি নিজে চালু করা ভয়েস কমান্ডের জন্য মাইক্রোফোন ব্যবহার করে। মাইক্রোফোনের অনুমতি ছাড়াও আপনি থাকতে পারেন, কিন্তু অন্যরা আপনার কথা শুনতে পাবেন না। আলাদা ব্যক্তিগত নোট রেকর্ডিং লাইভ ক্লাসের বাইরে আলাদাভাবে নিজে শুরু করতে হয়।';

  @override
  String get sessionMicDialogConfirm => 'ক্লাসে এগিয়ে যান';

  @override
  String get sessionMicSkipped =>
      'মাইক্রোফোনের অনুমতি এড়িয়ে যাওয়া হয়েছে। আপনি মিউট অবস্থায় ক্লাসে যোগ দিয়েছেন।';

  @override
  String get sessionMicUnavailable =>
      'মাইক্রোফোনের অনুমতি পাওয়া যাচ্ছে না। আপনি মিউট অবস্থায় ক্লাসে যোগ দিয়েছেন।';

  @override
  String get sessionWaitingMic =>
      'মাইক্রোফোনের নিশ্চয়তার জন্য অপেক্ষা করা হচ্ছে।';

  @override
  String get sessionMuted => 'মিউট করা আছে';

  @override
  String get sessionUnmuted => 'আনমিউট করা আছে';

  @override
  String get sessionMutedLocallyOnly =>
      'এই ফোনে মাইক্রোফোন মিউট করা হয়েছে। ক্লাস থেকে নিশ্চয়তা পাওয়া যায়নি।';

  @override
  String get sessionMutedByTeacher => 'শিক্ষক আপনার মাইক্রোফোন মিউট করেছেন।';

  @override
  String get sessionMicClassClosed =>
      'ক্লাস বন্ধ হয়ে গেছে। মাইক্রোফোনের কোনো অনুরোধ পাঠানো হয়নি।';

  @override
  String get sessionMicUnavailableRejoin =>
      'মাইক্রোফোনের অনুমতি পাওয়া যাচ্ছে না। কথা বলার আগে মাইক্রোফোনের অনুমতি দেখুন এবং আবার ক্লাসে যোগ দিন।';

  @override
  String get sessionMicClosedBeforeConfirm =>
      'মাইক্রোফোনের নিশ্চয়তার আগেই ক্লাস বন্ধ হয়ে গেছে।';

  @override
  String get sessionMicNoLongerAvailable =>
      'মাইক্রোফোনের অনুমতি আর পাওয়া যাচ্ছে না। কথা বলার আগে আবার ক্লাসে যোগ দিন।';

  @override
  String get sessionMicStayedMuted =>
      'ক্লাসের মিউট অবস্থা বদলে যাওয়ায় আপনার মাইক্রোফোন মিউট রয়ে গেছে। কথা বলতে প্রস্তুত হলে আনমিউট বেছে নিন।';

  @override
  String get sessionWaitingHand =>
      'হাতের অবস্থার নিশ্চয়তার জন্য অপেক্ষা করা হচ্ছে।';

  @override
  String get sessionHandRaised => 'হাত তোলা হয়েছে';

  @override
  String get sessionHandLowered => 'হাত নামানো হয়েছে';

  @override
  String get sessionHandNotConfirmed =>
      'আপনার হাতের পরিবর্তন নিশ্চিত হয়নি। আবার চেষ্টা করতে 2 টিপুন।';

  @override
  String sessionRaisedHandBy(String name) {
    return '$name হাত তুলেছেন।';
  }

  @override
  String get sessionRaisedHandUnknown => 'একজন শিক্ষার্থী হাত তুলেছেন।';

  @override
  String get sessionParticipantJoined => 'একজন অংশগ্রহণকারী যোগ দিয়েছেন।';

  @override
  String get sessionParticipantsJoinedGroup => 'অংশগ্রহণকারীরা যোগ দিয়েছেন';

  @override
  String get sessionParticipantLeft => 'একজন অংশগ্রহণকারী চলে গেছেন।';

  @override
  String get sessionParticipantsLeftGroup => 'অংশগ্রহণকারীরা চলে গেছেন';

  @override
  String get sessionParticipantFallback => 'অংশগ্রহণকারী';

  @override
  String get sessionThisParticipant => 'এই অংশগ্রহণকারী';

  @override
  String sessionParticipantSelf(String name) {
    return '$name, আপনি';
  }

  @override
  String get sessionRoleTeacher => 'শিক্ষক';

  @override
  String get sessionRoleStudent => 'শিক্ষার্থী';

  @override
  String get sessionStateHandRaised => 'হাত তোলা';

  @override
  String get sessionStateMuted => 'মিউট করা';

  @override
  String get sessionStateUnmuted => 'আনমিউট করা';

  @override
  String get sessionStateSpeaking => 'কথা বলছেন';

  @override
  String sessionAlreadyMuted(String name) {
    return '$name মিউট আছেন। শুধু $name নিজে আনমিউট করতে পারবেন।';
  }

  @override
  String sessionParticipantMuted(String name) {
    return '$name মিউট হয়েছেন।';
  }

  @override
  String sessionRemoveTitle(String name) {
    return '$name-কে সরাবেন?';
  }

  @override
  String sessionRemoveMessage(String name) {
    return '$name-কে এই ক্লাস থেকে সরিয়ে তাঁর ড্যাশবোর্ডে ফেরত পাঠানো হবে। পরে আবার তাঁকে আমন্ত্রণ করা যাবে।';
  }

  @override
  String sessionKeep(String name) {
    return '$name-কে রাখুন';
  }

  @override
  String sessionRemove(String name) {
    return '$name-কে সরান';
  }

  @override
  String sessionRemoved(String name) {
    return '$name-কে ক্লাস থেকে সরানো হয়েছে।';
  }

  @override
  String chatMessageFrom(String sender, String text) {
    return '$sender-এর মেসেজ: $text';
  }

  @override
  String get chatSenderUnknown => 'অজানা';

  @override
  String get chatSenderUnknownLower => 'অজানা';

  @override
  String get chatWaitingConfirmation =>
      'মেসেজের নিশ্চিতকরণের অপেক্ষা করা হচ্ছে।';

  @override
  String get chatEmptyMessage => 'পাঠান বেছে নেওয়ার আগে একটি মেসেজ লিখুন।';

  @override
  String get chatMessageSent => 'মেসেজ পাঠানো হয়েছে।';

  @override
  String get chatSending => 'পাঠানো হচ্ছে';

  @override
  String get chatSent => 'পাঠানো হয়েছে';

  @override
  String get chatNotConfirmed => 'নিশ্চিত হয়নি';

  @override
  String get chatNoMessages => 'এখনও কোনো মেসেজ নেই।';

  @override
  String get chatTitle => 'চ্যাট';

  @override
  String get chatReadMessages => 'মেসেজ পড়ুন, নতুনগুলো আগে';

  @override
  String get chatWriteMessage => 'একটি মেসেজ লিখুন';

  @override
  String get chatMessageField => 'ক্লাসের জন্য আপনার মেসেজ';

  @override
  String get chatMessagesTitle => 'চ্যাট মেসেজ';

  @override
  String get chatPhraseUnderstood => 'আমি বুঝেছি';

  @override
  String get chatPhraseRepeat => 'দয়া করে আবার বলুন';

  @override
  String get chatPhraseQuestion => 'আমার একটি প্রশ্ন আছে';

  @override
  String chatSendPhrase(String phrase) {
    return 'পাঠান: $phrase';
  }

  @override
  String chatCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি মেসেজ।',
      one: '1টি মেসেজ।',
    );
    return '$_temp0';
  }

  @override
  String get chatHelpBrief => 'পড়ুন, লিখুন বা একটি ছোট বাক্য পাঠান।';

  @override
  String get chatHelpDetailed =>
      'মেসেজ পড়তে 1 টিপুন, লিখতে 2 টিপুন, অথবা ছোট বাক্য পাঠাতে 3 থেকে 5 টিপুন। সবচেয়ে নতুন মেসেজ শুনতে 8 টিপুন।';

  @override
  String get chatYou => 'আপনি';

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
    return '$line। পাঠানো হয়েছে $time-এ।';
  }

  @override
  String chatNewestMessage(String detail) {
    return 'সবচেয়ে নতুন মেসেজ। $detail';
  }

  @override
  String get chatReadLatest => 'সর্বশেষ মেসেজ পড়ুন';

  @override
  String get chatMessageLabel => 'চ্যাট মেসেজ';

  @override
  String get chatSendMessage => 'মেসেজ পাঠান';

  @override
  String chatSaid(String sender, String text) {
    return '$sender বলেছেন: $text';
  }

  @override
  String chatSaidDelivery(String sender, String text, String delivery) {
    return '$sender বলেছেন: $text। $delivery';
  }

  @override
  String chatLatestLineDelivery(String sender, String text, String delivery) {
    return '$sender: $text\nপাঠানোর অবস্থা: $delivery।';
  }

  @override
  String get sessionLeaveTitle => 'ক্লাস ছেড়ে যাবেন?';

  @override
  String get sessionLeaveMessage =>
      'আপনি এই ক্লাস ছেড়ে আপনার ড্যাশবোর্ডে ফিরে যাবেন। আপনি সাইন ইন করা অবস্থাতেই থাকবেন।';

  @override
  String get sessionTeacherLeaveMessage =>
      'আপনি ক্লাস ছেড়ে আপনার ড্যাশবোর্ডে ফিরে যাবেন। শিক্ষার্থীদের জন্য ক্লাস চলতে থাকবে। সবার জন্য শেষ করতে 9, শিক্ষকের টুলস ব্যবহার করুন।';

  @override
  String get sessionStay => 'ক্লাসে থাকুন';

  @override
  String get sessionLeave => 'ক্লাস ছেড়ে যান';

  @override
  String get sessionLeaveLocallyTitle =>
      'সার্ভারের নিশ্চিতকরণ ছাড়াই ছেড়ে যাবেন?';

  @override
  String get sessionLeaveLocallyMessage =>
      'এই ফোন মিউট আছে। আপনার তোলা হাত নামানো হয়েছে কিনা সার্ভার নিশ্চিত করেনি। এখন শুধু এই ফোন থেকে ছেড়ে যাবেন, নাকি থেকে আবার চেষ্টা করবেন? নতুন করে যোগ দিলে আপনার হাত আবার নামানো অবস্থায় থাকবে।';

  @override
  String get sessionStayAndRetry => 'থাকুন ও আবার চেষ্টা করুন';

  @override
  String get sessionLeaveLocally => 'এই ফোন থেকে ছেড়ে যান';

  @override
  String get sessionEndTitle => 'সবার জন্য ক্লাস শেষ করবেন?';

  @override
  String get sessionEndMessage =>
      'এতে প্রত্যেক অংশগ্রহণকারীর জন্য ক্লাস বন্ধ হবে এবং সবাই তাদের ড্যাশবোর্ডে ফিরে যাবে। কাউকে লগ আউট করা হবে না।';

  @override
  String get sessionEndCancel => 'ক্লাস চালু রাখুন';

  @override
  String get sessionEndConfirm => 'সবার জন্য শেষ করুন';

  @override
  String get sessionWaitingEnd =>
      'ক্লাস শেষ করার নিশ্চিতকরণের অপেক্ষা করা হচ্ছে।';

  @override
  String get sessionEndNotConfirmed =>
      'ক্লাস শেষ করা নিশ্চিত হয়নি। ক্লাস এখনও চলছে।';

  @override
  String get sessionEndingForEveryone => 'সবার জন্য ক্লাস শেষ করা হচ্ছে।';

  @override
  String get sessionYouLeft => 'আপনি ক্লাস ছেড়ে গেছেন।';

  @override
  String get sessionClassEnded => 'ক্লাস শেষ হয়েছে।';

  @override
  String get sessionYouWereRemoved => 'আপনাকে ক্লাস থেকে সরানো হয়েছে।';

  @override
  String get sessionSignInChanged =>
      'আপনার সাইন ইন বদলে গেছে। আবার সাইন ইন করুন অথবা আপনার স্কুলের প্রশাসকের সাথে যোগাযোগ করুন।';

  @override
  String get sessionCleanupFailed =>
      'সাইন ইন শেষ হয়েছে। ফোনের অডিও বন্ধ হয়েছে কিনা নিশ্চিত করা যায়নি। অডিও চলতে থাকলে SEEDS বন্ধ করুন।';

  @override
  String get sessionCleanupTimedOut =>
      'সাইন ইন শেষ হয়েছে। অডিও বন্ধ করতে বেশি সময় লেগে গেছে। অডিও চলতে থাকলে SEEDS বন্ধ করুন।';

  @override
  String get sessionRequestFailed =>
      'আমরা এই অনুরোধটি সম্পূর্ণ করতে পারিনি। দয়া করে আবার চেষ্টা করুন।';

  @override
  String get sessionVoiceStopped => 'ভয়েস শোনা বন্ধ হয়েছে।';

  @override
  String get sessionVoiceUnmuteTitle => 'আপনার মাইক্রোফোন আনমিউট করবেন?';

  @override
  String get sessionVoiceUnmuteMessage =>
      'একটি ভয়েস কমান্ড আনমিউট করতে বলেছে। একটি কী টিপে বা স্ক্রিন ছুঁয়ে নিশ্চিত করুন। ক্লাসের অন্যরা আপনার কথা শুনতে পাবে।';

  @override
  String get sessionVoiceUnmuteConfirm => 'আনমিউট';

  @override
  String get sessionVoiceUnmuteCancel => 'মিউট থাকুন';

  @override
  String get sessionAlreadyUnmuted => 'আগে থেকেই আনমিউট আছে';

  @override
  String get sessionAlreadyMutedSelf => 'আগে থেকেই মিউট আছে';

  @override
  String get sessionHandAlreadyLowered => 'হাত আগে থেকেই নামানো আছে';

  @override
  String get sessionHandAlreadyRaised => 'হাত আগে থেকেই তোলা আছে';

  @override
  String get sessionCommandNotRecognized => 'কমান্ড বোঝা যায়নি';

  @override
  String get sessionVoiceStopUnconfirmed =>
      'ভয়েস শোনা বন্ধ হওয়া নিশ্চিত হয়নি। আবার বন্ধ করার চেষ্টা করুন।';

  @override
  String get sessionVoiceStopping => 'ভয়েস শোনা বন্ধ করা হচ্ছে।';

  @override
  String get sessionVoiceStarting => 'ভয়েস কমান্ড চালু করা হচ্ছে।';

  @override
  String get sessionVoiceFinishing => 'ভয়েস চেনা শেষ করা হচ্ছে।';

  @override
  String get sessionVoiceListening =>
      'একটি কমান্ডের জন্য শুনছি, সর্বোচ্চ 12 সেকেন্ড।';

  @override
  String get sessionVoiceIdle =>
      'শোনা হচ্ছে না। শুরু করতে কমান্ডের জন্য শুনুন চালু করুন।';

  @override
  String get sessionVoiceSpeechNotStopped =>
      'অ্যাপের কণ্ঠস্বর বন্ধ করা যায়নি। শোনার আগে কথা বলা থামান চেষ্টা করুন।';

  @override
  String get sessionVoiceUnavailable =>
      'ভয়েস কমান্ড পাওয়া যাচ্ছে না। মাইক্রোফোনের অনুমতি এবং Android-এর ইংরেজি স্পিচ পরিষেবা দেখুন।';

  @override
  String get sessionVoiceCouldNotStart =>
      'ভয়েস কমান্ড চালু করা যায়নি। মাইক্রোফোনের অনুমতি এবং ইংরেজি স্পিচ পরিষেবা দেখে আবার চেষ্টা করুন।';

  @override
  String get sessionVoiceCouldNotFinish =>
      'ভয়েস চেনা শেষ করা যায়নি। অনুমতি এবং ইংরেজি স্পিচ পরিষেবা দেখুন, তারপর আবার চেষ্টা করতে শুনুন চালু করুন।';

  @override
  String get sessionVoiceNoCommand =>
      'কোনো কমান্ড শোনা যায়নি। আবার চেষ্টা করতে কমান্ডের জন্য শুনুন চালু করুন।';

  @override
  String get sessionVoiceCommandFailed =>
      'ভয়েস কমান্ডটি সম্পূর্ণ করা যায়নি। এর কীপ্যাড কন্ট্রোল ব্যবহার করুন অথবা আবার চেষ্টা করুন।';

  @override
  String get sessionVoiceCannotStop =>
      'ভয়েস শোনা বন্ধ করা যায়নি। আবার শোনা বন্ধ করুন চেষ্টা করুন, অথবা ক্লাস ছেড়ে Android-এর মাইক্রোফোন চিহ্নটি দেখুন।';

  @override
  String get sessionRecordingSelectionChanged =>
      'ক্লাসের রেকর্ডিং বাছাই বদলেছে। বিস্তারিত জানতে ক্লাসের আপডেট পড়ুন ব্যবহার করুন।';

  @override
  String get sessionRecordingSelectionGroup => 'ক্লাসের রেকর্ডিং বাছাই';

  @override
  String get sessionPlaybackFinished => 'রেকর্ডিং শেষ হয়েছে।';

  @override
  String get sessionNoRecording => 'কোনো ক্লাস রেকর্ডিং বাছাই করা নেই।';

  @override
  String get sessionNoRecordingTeacher =>
      'কোনো ক্লাস রেকর্ডিং বাছাই করা নেই। রেকর্ডিং প্লেয়ারে একটি বেছে নিতে 1 টিপুন।';

  @override
  String get sessionPreviewFailed =>
      'ব্যক্তিগত প্রিভিউ চালু করা যায়নি। সংযোগ দেখে আবার চেষ্টা করুন।';

  @override
  String sessionClassPauseUnconfirmed(String reason) {
    return 'আপনার ফোনের অডিও থামানো হয়েছে। ক্লাসের জন্য থামানো নিশ্চিত হয়নি। $reason';
  }

  @override
  String sessionSpeed(String speed) {
    return '$speed গুণ গতি';
  }

  @override
  String sessionPlaybackAccepted(String title) {
    return '$title ক্লাসে চালানোর অনুরোধ গ্রহণ করা হয়েছে।';
  }

  @override
  String sessionSelected(String title) {
    return '$title ক্লাসের জন্য বাছাই করা হয়েছে। চালাতে 5 টিপুন।';
  }

  @override
  String sessionPreviewing(String title) {
    return 'শুধু এই ফোনে $title প্রিভিউ চলছে।';
  }

  @override
  String get sessionPreviewStopped => 'প্রিভিউ বন্ধ হয়েছে।';

  @override
  String get sessionRecordingsTitle => 'ক্লাস রেকর্ডিং প্লেয়ার';

  @override
  String get sessionChooseRecording => 'লাইব্রেরি থেকে একটি রেকর্ডিং বেছে নিন';

  @override
  String get sessionUploadRecording => 'নতুন রেকর্ডিং আপলোড করুন';

  @override
  String get sessionHearRecording => 'রেকর্ডিংয়ের অবস্থা শুনুন';

  @override
  String get sessionPlayPauseClass => 'ক্লাসের জন্য চালান বা থামান';

  @override
  String get sessionLibraryLoading =>
      'রেকর্ডিং লাইব্রেরি এখনও লোড হচ্ছে। একটু পরে আবার চেষ্টা করুন।';

  @override
  String get sessionLibraryEmpty =>
      'এই ক্লাসের জন্য এখনও কোনো রেকর্ডিং নেই। একটি আপলোড করতে 2 টিপুন।';

  @override
  String get sessionPositionHint => '10 সেকেন্ড সরাতে বাম ও ডান ব্যবহার করুন';

  @override
  String sessionRecordingStatusPlaying(
    String title,
    String position,
    String speed,
  ) {
    return '$title। ক্লাসের জন্য চলছে। $position। $speed।';
  }

  @override
  String sessionRecordingStatusPaused(
    String title,
    String position,
    String speed,
  ) {
    return '$title। থামানো আছে। $position। $speed।';
  }

  @override
  String sessionPositionLabel(String position) {
    return 'অবস্থান $position। 10 সেকেন্ড সরাতে বাম ও ডান ব্যবহার করুন';
  }

  @override
  String get sessionUntitled => 'নামহীন';

  @override
  String get sessionFileSelectedForClass => 'ক্লাসের জন্য বাছাই করা';

  @override
  String get sessionFilePreviewing => 'প্রিভিউ চলছে';

  @override
  String get sessionPlayForClass => 'বাছাই করে এখনই ক্লাসের জন্য চালান';

  @override
  String get sessionSelectOnly => 'শুধু বাছাই করুন, পরে 5 দিয়ে চালান';

  @override
  String get sessionPreviewPrivately => 'এই ফোনে ব্যক্তিগতভাবে প্রিভিউ করুন';

  @override
  String get sessionStopPreview => 'ব্যক্তিগত প্রিভিউ বন্ধ করুন';

  @override
  String get sessionUploadDetailsTitle => 'অডিও আপলোডের বিবরণ';

  @override
  String get sessionUploadTitle => 'অডিও আপলোড';

  @override
  String sessionUploadFile(String name) {
    return 'ফাইল: $name';
  }

  @override
  String get sessionTitleField => 'অডিওর শিরোনাম, আবশ্যক';

  @override
  String get sessionDescriptionField => 'অডিওর বিবরণ, ঐচ্ছিক';

  @override
  String get sessionCancelUpload => 'আপলোড বাতিল করুন';

  @override
  String get sessionConfirmUpload => 'অডিও আপলোড করুন';

  @override
  String get sessionTitleRequired => 'শিরোনাম আবশ্যক';

  @override
  String get sessionChooseSessionsTitle => 'এই অডিওর জন্য ক্লাস বেছে নিন';

  @override
  String get sessionAddToSessions => 'ক্লাসে অডিও যোগ করুন';

  @override
  String get sessionConfirmSessions => 'বাছাই করা ক্লাস নিশ্চিত করুন';

  @override
  String get sessionSelectAtLeastOne => 'অন্তত একটি ক্লাস বাছাই করুন';

  @override
  String get sessionSessionSelected => 'ক্লাস বাছাই করা হয়েছে';

  @override
  String get sessionSessionUnselected => 'ক্লাস বাছাই বাতিল হয়েছে';

  @override
  String sessionChoiceSelected(String title) {
    return 'বাছাই করা, $title';
  }

  @override
  String sessionChoiceNotSelected(String title) {
    return 'বাছাই করা নয়, $title';
  }

  @override
  String sessionClassNumbered(String number) {
    return 'ক্লাস $number';
  }

  @override
  String get sessionUploadContextMissing =>
      'এই ক্লাসের ক্লাস ও বিষয় বোঝা যায়নি।';

  @override
  String get sessionUploadSuccess => 'আপলোড সফল হয়েছে।';

  @override
  String get sessionUploadInProgress => 'অডিও আপলোড চলছে';

  @override
  String get sessionPlayNowTitle => 'এখনই সবার জন্য চালাবেন?';

  @override
  String sessionPlayNowMessage(String title) {
    return '$title বাছাই করা হয়েছে। এখনই সব অংশগ্রহণকারীর জন্য চালাবেন?';
  }

  @override
  String get sessionPlayNow => 'এখনই চালান';

  @override
  String get sessionNotYet => 'এখন নয়';

  @override
  String get sessionUploadEditTitle => 'শিরোনাম বদলান';

  @override
  String get sessionUploadEditDescription => 'বিবরণ বদলান';

  @override
  String get sessionUploadKey => 'আপলোড';

  @override
  String get sessionCancel => 'বাতিল';

  @override
  String get classroomCheckUnreadable =>
      'ক্লাস যাচাইয়ের অবস্থা পড়া যায়নি। উত্তর দেওয়ার আগে রিফ্রেশ করুন।';

  @override
  String get classroomCheckUnconfirmed =>
      'ক্লাস যাচাইয়ের কাজটি নিশ্চিত হয়নি। আবার চেষ্টা করার আগে রিফ্রেশ করুন।';

  @override
  String get classroomCheckConfirmationUnreadable =>
      'ক্লাস যাচাইয়ের নিশ্চিতকরণ পড়া যায়নি। আবার চেষ্টা করার আগে রিফ্রেশ করুন।';

  @override
  String get classroomCheckOpenedForYou =>
      'আপনার শিক্ষক একটি প্রশ্ন করেছেন। উত্তর দিতে 3 টিপুন।';

  @override
  String get classroomCheckHelp =>
      'ব্যক্তিগত ক্লাস যাচাই। বুঝেছি, দয়া করে আবার বলুন অথবা সাহায্য দরকার। একটি উত্তর শুধু উত্তরদাতা শিক্ষার্থী এবং সেশনের শিক্ষক পড়তে পারেন। এতে নম্বর দেওয়া হয় না। পরের যাচাই, সেশন শেষ হলে বা সার্ভার রিস্টার্ট হলে উত্তরগুলো মুছে যায়। নিশ্চিত অবস্থা জানতে পড়ুন বা রিফ্রেশ ব্যবহার করুন। কথা বলা থামান এবং পিছনে যান পাওয়া যায়।';

  @override
  String get classroomCheckTitle => 'ক্লাস যাচাই';

  @override
  String get classroomCheckNewTitle => 'নতুন ক্লাস যাচাই খুলবেন?';

  @override
  String get classroomCheckNewMessage =>
      'এতে আগের যাচাইয়ের সব উত্তর মুছে যাবে। শিক্ষার্থীরা বুঝেছি, দয়া করে আবার বলুন অথবা সাহায্য দরকার বেছে নেবে। প্রত্যেকের উত্তর শুধু আপনি এবং সেই উত্তরদাতা শিক্ষার্থী পড়তে পারবেন। এতে নম্বর দেওয়া হয় না এবং পড়াশোনার রেকর্ড হিসেবে রাখা হয় না।';

  @override
  String get classroomCheckNewConfirm => 'আগেরটি মুছে নতুন খুলুন';

  @override
  String get classroomCheckNewCancel => 'বর্তমান যাচাই রাখুন';

  @override
  String get classroomCheckSending =>
      'পাঠানো হচ্ছে। নিশ্চিতকরণের অপেক্ষা করা হচ্ছে।';

  @override
  String get classroomCheckWaiting =>
      'নিশ্চিতকরণের অপেক্ষা করা হচ্ছে। আবার পাঠাবেন না।';

  @override
  String get sessionBackToClass => 'ক্লাসে ফিরে যান';

  @override
  String get classroomBackToSession => 'সেশনে ফিরে যান';

  @override
  String get classroomBack => 'পিছনে';

  @override
  String get classroomCheckRead => 'যাচাইয়ের অবস্থা ও নিশ্চিত উত্তরগুলো পড়ুন';

  @override
  String get classroomCheckReadButton => 'অবস্থা ও উত্তর পড়ুন';

  @override
  String get classroomCheckRefresh =>
      'ব্যক্তিগত যাচাইয়ের অবস্থা রিফ্রেশ করুন। ক্লাসের সংযোগ দরকার';

  @override
  String get classroomCheckRefreshButton => 'সার্ভার থেকে রিফ্রেশ করুন';

  @override
  String get classroomCheckOpenLabel =>
      'নতুন যাচাই খুলুন। আগের উত্তর মুছে ফেলা নিশ্চিত করুন';

  @override
  String get classroomCheckOpenButton => 'নতুন যাচাই খুলুন';

  @override
  String get classroomCheckCloseLabel =>
      'এই যাচাই বন্ধ করুন। পরের যাচাই বা সেশন শেষ হওয়া পর্যন্ত বর্তমান ফলাফল থাকবে';

  @override
  String get classroomCheckCloseButton => 'যাচাই বন্ধ করুন';

  @override
  String classroomCheckAnswer(String choice) {
    return '$choice। আপনার ব্যক্তিগত, নম্বরবিহীন উত্তর পাঠান বা বদলান';
  }

  @override
  String get sessionStopSpeech => 'কথা বলা থামান';

  @override
  String get classroomChoiceUnderstood => 'বুঝেছি';

  @override
  String get classroomChoiceRepeat => 'দয়া করে আবার বলুন';

  @override
  String get classroomChoiceHelp => 'সাহায্য দরকার';

  @override
  String get classroomCheckNone =>
      'সর্বশেষ পাওয়া ক্লাসের অবস্থায় কোনো চলতি যাচাই নেই। দেখতে রিফ্রেশ করুন।';

  @override
  String get classroomCheckStatusOpen => 'যাচাই খোলা আছে।';

  @override
  String get classroomCheckStatusClosed =>
      'যাচাই বন্ধ। উত্তর আর বদলানো যাবে না।';

  @override
  String get classroomCheckNoResponseYet => 'এখনও কোনো উত্তর নিশ্চিত হয়নি।';

  @override
  String classroomCheckYourResponse(String choice) {
    return 'আপনার নিশ্চিত উত্তর: $choice।';
  }

  @override
  String classroomCheckStudentSummary(String status, String response) {
    return '$status $response আপনার উত্তর শুধু আপনি এবং সেশনের শিক্ষক পড়তে পারবেন। এতে নম্বর দেওয়া হয় না।';
  }

  @override
  String classroomCheckLabelValue(String label, String value) {
    return '$label: $value';
  }

  @override
  String get classroomCheckNoResponses => 'এখনও কোনো উত্তর নেই।';

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
          '$status $count জন শিক্ষার্থী উত্তর দিয়েছে। $counts। $named উত্তরগুলো শুধু আপনি এবং প্রত্যেক উত্তরদাতা শিক্ষার্থী দেখতে পারবেন, এবং এগুলো নম্বর নয়।',
    );
    return '$_temp0';
  }

  @override
  String get sessionToolsTitle => 'শিক্ষকের টুল';

  @override
  String get sessionInvite => 'শিক্ষার্থীদের আমন্ত্রণ জানান';

  @override
  String get sessionEndClass =>
      'সবার জন্য ক্লাস শেষ করুন, নিশ্চিত করতে বলা হবে';

  @override
  String get sessionPeopleTitle => 'অংশগ্রহণকারী এবং তোলা হাত';

  @override
  String sessionParticipantList(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'অংশগ্রহণকারীদের তালিকা, $count জন',
      one: 'অংশগ্রহণকারীদের তালিকা, 1 জন',
    );
    return '$_temp0';
  }

  @override
  String get sessionSummaryChoice => 'ক্লাসের সারাংশ শুনুন';

  @override
  String get sessionParticipantsTitle => 'অংশগ্রহণকারী';

  @override
  String get sessionMembersTitle => 'ক্লাসে যাঁরা আছেন';

  @override
  String get sessionMembersButton => '7: ক্লাসে কে আছেন';

  @override
  String sessionMembersLabel(String people) {
    return 'ক্লাসে কে আছেন। $people বিস্তারিত শুনতে একজনকে বেছে নিন';
  }

  @override
  String get sessionHearDetails => 'বিস্তারিত শুনুন';

  @override
  String sessionMuteParticipant(String name) {
    return '$name-কে মিউট করুন';
  }

  @override
  String sessionRemoveParticipant(String name) {
    return '$name-কে ক্লাস থেকে সরান, নিশ্চিত করতে বলা হবে';
  }

  @override
  String get sessionParticipantGone => 'ওই অংশগ্রহণকারী ক্লাস ছেড়ে চলে গেছেন।';

  @override
  String get sessionNoOtherParticipants => 'এখনো ক্লাসে আর কেউ নেই।';

  @override
  String sessionTileRemoveMessage(String name) {
    return '$name-কে এই ক্লাস থেকে সরিয়ে তাঁর ড্যাশবোর্ডে ফেরত পাঠানো হবে।';
  }

  @override
  String sessionTileRemoveFromSessionMessage(String name) {
    return '$name-কে এই সেশন থেকে সরিয়ে তাঁর ড্যাশবোর্ডে ফেরত পাঠানো হবে।';
  }

  @override
  String sessionUnmuteParticipant(String name) {
    return '$name-কে আনমিউট করুন';
  }

  @override
  String sessionRemoveFromClass(String name) {
    return '$name-কে ক্লাস থেকে সরান';
  }

  @override
  String get sessionConnStateConnecting => 'সংযোগ হচ্ছে';

  @override
  String get sessionConnStateConnected => 'সংযুক্ত';

  @override
  String get sessionConnStateInterrupted => 'সংযোগ বিঘ্নিত';

  @override
  String get sessionConnStateReconnecting => 'আবার সংযোগ হচ্ছে';

  @override
  String get sessionConnStateSignInRequired => 'সাইন ইন প্রয়োজন';

  @override
  String get sessionConnStateUnavailable => 'ক্লাস পাওয়া যাচ্ছে না';

  @override
  String get sessionConnStateEnded => 'ক্লাস শেষ';

  @override
  String get sessionConnStateDisconnected => 'সংযোগ বিচ্ছিন্ন';

  @override
  String get sessionReconnectingToClass => 'ক্লাসে আবার সংযোগ করা হচ্ছে।';

  @override
  String get sessionSignInRequiredLeave =>
      'সাইন ইন প্রয়োজন। সেশন ছেড়ে আবার সাইন ইন করুন।';

  @override
  String get sessionSignInExpiredLeave =>
      'সাইন ইনের মেয়াদ শেষ। সেশন ছেড়ে আবার সাইন ইন করুন।';

  @override
  String get sessionClassNoLongerAvailable =>
      'এই ক্লাস আর আপনার অ্যাকাউন্টের জন্য উপলব্ধ নয়। আপনি ফিরে যেতে পারেন।';

  @override
  String get sessionServiceUnavailable => 'ক্লাসের পরিষেবা পাওয়া যাচ্ছে না।';

  @override
  String get sessionConnectionUnreadable =>
      'ক্লাসের সংযোগের উত্তর পড়া যায়নি।';

  @override
  String get sessionConnectionNotConfirmed => 'ক্লাস সংযোগ নিশ্চিত করেনি।';

  @override
  String get sessionConnectionInterrupted => 'ক্লাসের সংযোগ বিঘ্নিত হয়েছে।';

  @override
  String get sessionConnectionClosed => 'ক্লাসের সংযোগ বন্ধ হয়েছে।';

  @override
  String get sessionConnectionCouldNotConfirm =>
      'ক্লাসের সংযোগ নিশ্চিত করা যায়নি।';

  @override
  String get sessionNoUpdates => 'ক্লাস থেকে কোনো আপডেট পাওয়া যায়নি।';

  @override
  String get sessionUpdateUnreadable => 'ক্লাসের একটি আপডেট পড়া যায়নি।';

  @override
  String get sessionUpdateUnexpectedFormat =>
      'ক্লাসের একটি আপডেটের ফরম্যাট অপ্রত্যাশিত ছিল।';

  @override
  String get sessionUpdateTypeUnreadable =>
      'ক্লাসের একটি আপডেটের ধরন পড়া যায়নি।';

  @override
  String get sessionParticipationNotConfirmed =>
      'ক্লাসে আপনার অংশগ্রহণ নিশ্চিত হয়নি।';

  @override
  String get sessionConnectedToClass => 'ক্লাসে সংযুক্ত হয়েছেন।';

  @override
  String get sessionSignInChangedShort =>
      'আপনার সাইন ইন বদলে গেছে। আবার সাইন ইন করুন।';

  @override
  String get sessionRemovedGoBack =>
      'আপনাকে ক্লাস থেকে সরিয়ে দেওয়া হয়েছে। আপনি ফিরে যেতে পারেন।';

  @override
  String sessionConnectionLostReconnecting(String reason) {
    return '$reason আবার সংযোগ করা হচ্ছে। আগের কাজগুলি নিজে থেকে আবার পাঠানো হবে না।';
  }

  @override
  String get sessionActionClassUnavailable =>
      'ক্লাস পাওয়া যাচ্ছে না। এই কাজটি পাঠানো হয়নি।';

  @override
  String get sessionActionSessionChanged =>
      'সেশন বদলে গেছে। এই কাজটি পাঠানো হয়নি।';

  @override
  String get sessionActionSignInRequired =>
      'সাইন ইন প্রয়োজন। এই কাজটি পাঠানো হয়নি।';

  @override
  String get sessionActionConnectionChanged =>
      'নিশ্চিত হওয়ার আগেই সংযোগ বদলে গেছে। কাজটি হয়তো পৌঁছেছে; আবার চেষ্টা করার আগে এর অবস্থা দেখে নিন।';

  @override
  String get sessionAccountChangedLeave =>
      'আপনার অ্যাকাউন্ট বদলে গেছে। সেশন ছেড়ে আবার সাইন ইন করুন।';

  @override
  String get sessionActionAccountChanged =>
      'কাজটি নিশ্চিত হওয়ার আগেই আপনার অ্যাকাউন্ট বদলে গেছে।';

  @override
  String get sessionActionNotConfirmedByClass =>
      'ক্লাস কাজটি নিশ্চিত করেনি। আবার চেষ্টা করার আগে এর অবস্থা দেখে নিন।';

  @override
  String get sessionActionMayHaveReached =>
      'কাজটি নিশ্চিত হয়নি। এটি হয়তো ক্লাসে পৌঁছেছে। আবার চেষ্টা করার আগে এর অবস্থা দেখে নিন।';

  @override
  String get sessionRtcConnectionClosed => 'সংযোগ বন্ধ হয়েছে।';

  @override
  String get sessionRtcNetworkError => 'নেটওয়ার্ক ত্রুটি';

  @override
  String sessionRtcConnected(String id) {
    return 'সেশন $id-এ সংযুক্ত';
  }

  @override
  String sessionRtcParticipantJoined(String id) {
    return 'অংশগ্রহণকারী $id যোগ দিয়েছেন।';
  }

  @override
  String sessionRtcParticipantLeft(String id) {
    return 'অংশগ্রহণকারী $id চলে গেছেন।';
  }

  @override
  String sessionRtcParticipantMuted(String id) {
    return 'অংশগ্রহণকারী $id এখন মিউট';
  }

  @override
  String sessionRtcParticipantUnmuted(String id) {
    return 'অংশগ্রহণকারী $id এখন আনমিউট';
  }

  @override
  String sessionRtcMessage(String text) {
    return 'বার্তা: $text';
  }

  @override
  String sessionRtcTeacherPlaying(String id) {
    return 'শিক্ষক অডিও $id চালানো শুরু করেছেন';
  }

  @override
  String sessionRtcAudioStarted(String id) {
    return 'অংশগ্রহণকারী $id-এর অডিও শুরু হয়েছে';
  }

  @override
  String librarySpeedTimes(String speed) {
    return '$speed গুণ';
  }

  @override
  String get libraryNoClassForSession =>
      'এই সেশনের নামে কোনো ক্লাস পাওয়া যায়নি।';

  @override
  String librarySubjectFilterLabel(String name) {
    return 'বিষয় ফিল্টার: $name। বদলাতে কী 2, বা বাঁ বা ডান টিপুন';
  }

  @override
  String librarySubjectFilterLabelPosition(
    String name,
    String index,
    String total,
  ) {
    return 'বিষয় ফিল্টার: $name, $total-এর মধ্যে $index। বদলাতে কী 2, বা বাঁ বা ডান টিপুন';
  }

  @override
  String get libraryAllSubjects => 'সব বিষয়';

  @override
  String libraryRestoredToPlaylist(String title) {
    return '$title আবার প্লেলিস্টে ফিরে এসেছে।';
  }

  @override
  String get librarySizeZero => '0 মেগাবাইট';

  @override
  String get librarySizeTiny => '0.1 মেগাবাইটের কম';

  @override
  String get librarySizeOne => '1 মেগাবাইট';

  @override
  String librarySizeMegabytes(String value) {
    return '$value মেগাবাইট';
  }

  @override
  String libraryStorageUsed(String size, String limit) {
    return '$limit-এর মধ্যে $size ব্যবহার হয়েছে।';
  }

  @override
  String libraryRecordingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি রেকর্ডিং',
      one: '1টি রেকর্ডিং',
    );
    return '$_temp0';
  }

  @override
  String libraryPlayingBrief(String title, String position) {
    return '$title, $position থেকে চলছে।';
  }

  @override
  String libraryPlayingDetailed(String title, String position, String speed) {
    return '$title, $position থেকে চলছে, গতি $speed।';
  }

  @override
  String libraryPausedAt(String position) {
    return '$position-এ থামানো হয়েছে।';
  }

  @override
  String get libraryPlayerStateNothing => 'কিছু চলছে না।';

  @override
  String libraryPlayerStatePlaying(
    String title,
    String position,
    String speed,
  ) {
    return '$title চলছে, $position, গতি $speed।';
  }

  @override
  String libraryPlayerStatePaused(String title, String position, String speed) {
    return '$title থামানো, $position, গতি $speed।';
  }

  @override
  String librarySpeedChanged(String speed) {
    return 'গতি $speed।';
  }

  @override
  String get librarySlowest => 'ইতিমধ্যে সবচেয়ে কম গতিতে আছে।';

  @override
  String get libraryFastest => 'ইতিমধ্যে সবচেয়ে বেশি গতিতে আছে।';

  @override
  String get libraryNoLessonLoaded =>
      'কোনো পাঠ লোড করা নেই। আগে চালানোর জন্য একটি পাঠ বেছে নিন।';

  @override
  String libraryNoLessonPlayingPress(String key) {
    return 'কোনো পাঠ চলছে না। প্রথম পাঠ চালাতে $key টিপুন।';
  }

  @override
  String get libraryNothingIsPlaying => 'কিছুই চলছে না।';

  @override
  String get libraryNothingPlayingHint =>
      'কিছু চলছে না। একটি পাঠ বেছে নিন বা 5 টিপুন।';

  @override
  String libraryStopped(String title) {
    return '$title বন্ধ হয়েছে।';
  }

  @override
  String libraryFinished(String title) {
    return '$title শেষ হয়েছে।';
  }

  @override
  String get libraryWaitForPlayer => 'পাঠ প্লেয়ারের জন্য অপেক্ষা করুন।';

  @override
  String get librarySeekFailed =>
      'পাঠের ওই জায়গায় যাওয়া যায়নি। আবার চেষ্টা করুন।';

  @override
  String get librarySpeedFailed =>
      'চালানোর গতি বদলানো যায়নি। আবার চেষ্টা করুন।';

  @override
  String libraryPlayFailed(String title) {
    return '$title চালানো যায়নি। আপনার সংযোগ দেখে নিন, তারপর আবার বেছে নিন।';
  }

  @override
  String get libraryCheckingOfflineAccess =>
      'ইন্টারনেট নেই। আপনার সংরক্ষিত অফলাইন অ্যাক্সেস দেখা হচ্ছে।';

  @override
  String get libraryLessonGone =>
      'এই পাঠ আর পাওয়া যাচ্ছে না। আপনার সংরক্ষিত অগ্রগতি এবং বুকমার্ক রাখা আছে।';

  @override
  String librarySeekLabel(String position) {
    return 'পাঠের অবস্থান $position। 10 সেকেন্ড সরাতে বাঁ বা ডান ব্যবহার করুন।';
  }

  @override
  String libraryRewindLabel(String key) {
    return '10 সেকেন্ড পিছনে, কী $key';
  }

  @override
  String libraryForwardLabel(String key) {
    return '10 সেকেন্ড সামনে, কী $key';
  }

  @override
  String librarySlowerLabel(String key, String speed) {
    return 'ধীরে, কী $key। এখন $speed';
  }

  @override
  String libraryFasterLabel(String key, String speed) {
    return 'দ্রুত, কী $key। এখন $speed';
  }

  @override
  String libraryPauseLabel(String title, String key) {
    return '$title থামান, কী $key';
  }

  @override
  String libraryPlayLabel(String title, String key) {
    return '$title চালান, কী $key';
  }

  @override
  String libraryResumeLabel(String title, String key) {
    return '$title আবার চালু করুন, কী $key';
  }

  @override
  String libraryStopLabel(String title, String key) {
    return '$title বন্ধ করুন, কী $key';
  }

  @override
  String libraryPlayerKeyHelp(
    String rewind,
    String playPause,
    String forward,
    String slower,
    String faster,
  ) {
    return '10 সেকেন্ড পিছনে যেতে $rewind, চালাতে বা থামাতে $playPause, 10 সেকেন্ড সামনে যেতে $forward, ধীরে করতে $slower এবং দ্রুত করতে $faster টিপুন।';
  }

  @override
  String libraryBookmarkCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি বুকমার্ক',
      one: '1টি বুকমার্ক',
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
    return '$title। অবস্থান $position। গতি $speed। $bookmarks। A-B পুনরাবৃত্তি $repeat। অগ্রগতি সংরক্ষণ $saving।';
  }

  @override
  String libraryReadStatusLabel(String status) {
    return 'শেখার অবস্থা শুনুন। $status';
  }

  @override
  String libraryAddBookmarkLabel(String time) {
    return '$time-এ বুকমার্ক যোগ করুন';
  }

  @override
  String libraryBookmarksLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'বুকমার্ক। $countটি সংরক্ষিত জায়গা',
      one: 'বুকমার্ক। 1টি সংরক্ষিত জায়গা',
    );
    return '$_temp0';
  }

  @override
  String libraryNotesLabel(String time) {
    return '$time-এ ব্যক্তিগত পড়ার নোট। খোলার আগে পাঠ থামানো হবে';
  }

  @override
  String get libraryRepeatStartLabel =>
      'বর্তমান অবস্থানে পুনরাবৃত্তির শুরু A ঠিক করুন';

  @override
  String get libraryRepeatEndLabel =>
      'শুরু A-এর পরে পুনরাবৃত্তির শেষ B ঠিক করুন';

  @override
  String get libraryRepeatTurnOffLabel => 'A-B পুনরাবৃত্তি বন্ধ করুন';

  @override
  String get libraryRepeatTurnOnLabel => 'A-B পুনরাবৃত্তি চালু করুন';

  @override
  String get libraryRepeatClearLabel =>
      'সংরক্ষিত A-B পুনরাবৃত্তির জায়গা মুছুন';

  @override
  String libraryRetryLabel(String issue) {
    return 'শেখার অগ্রগতি আবার সংরক্ষণের চেষ্টা করুন। $issue';
  }

  @override
  String libraryBookmarkSaved(String time) {
    return '$time-এ বুকমার্ক সংরক্ষিত হয়েছে।';
  }

  @override
  String libraryRepeatStartSet(String time) {
    return 'পুনরাবৃত্তির শুরু $time-এ ঠিক হয়েছে।';
  }

  @override
  String libraryRepeatEndSetBrief(String time) {
    return 'পুনরাবৃত্তির শেষ $time-এ ঠিক হয়েছে।';
  }

  @override
  String libraryRepeatEndSetDetailed(String time) {
    return 'পুনরাবৃত্তির শেষ $time-এ ঠিক হয়েছে। বারবার চালাতে পুনরাবৃত্তি চালু বেছে নিন।';
  }

  @override
  String libraryRepeatState(String state) {
    return 'A-B পুনরাবৃত্তি $state।';
  }

  @override
  String get libraryRepeatCleared =>
      'A-B পুনরাবৃত্তির জায়গা মুছে ফেলা হয়েছে।';

  @override
  String get libraryProgressSaved => 'শেখার অগ্রগতি সংরক্ষিত হয়েছে।';

  @override
  String get libraryActionFailed =>
      'প্লেয়ার এই কাজটি করতে পারেনি। চালানো দেখে নিয়ে আবার চেষ্টা করুন।';

  @override
  String get libraryCheckPosition =>
      'পাঠের অবস্থান দেখে নিয়ে আবার চেষ্টা করুন।';

  @override
  String get libraryProgressUnavailableTitle =>
      'সংরক্ষিত অগ্রগতি পাওয়া যাচ্ছে না';

  @override
  String libraryProgressUnavailable(String reason) {
    return '$reason সংরক্ষিত তথ্য না বদলে শুরু থেকে শুনবেন? আবার সফলভাবে চেষ্টা না করা পর্যন্ত সংরক্ষণ বন্ধ থাকবে।';
  }

  @override
  String get libraryListenFromBeginning => 'শুরু থেকে শুনুন';

  @override
  String get libraryBookmarkNameScreen =>
      'বুকমার্কের নাম দিন। লিখতে ওকে টিপুন। উপরে বা নিচে টিপলে লেখা থেকে বেরিয়ে যাবেন।';

  @override
  String get libraryEnterBookmarkName => 'বুকমার্কের একটি নাম লিখুন।';

  @override
  String libraryBookmarkLabel(String label, String time) {
    return '$label। $time। বুকমার্কে যান';
  }

  @override
  String libraryBookmarkJumped(String label, String time) {
    return '$label। অবস্থান $time।';
  }

  @override
  String libraryRemoveBookmarkLabel(String label) {
    return '$label সরান';
  }

  @override
  String libraryRemoveBookmarkQuestion(String label) {
    return '$label সরাবেন? এতে পাঠ বা অন্য কোনো বুকমার্ক সরবে না।';
  }

  @override
  String libraryBookmarkRemoved(String label) {
    return '$label সরানো হয়েছে।';
  }

  @override
  String get libraryBookmarksScreen =>
      'বুকমার্ক। যেতে একটি জায়গা বেছে নিন। এতে থামানো প্লেব্যাক চালু হয় না। সরানোর আগে নিশ্চিত করতে বলা হবে।';

  @override
  String get libraryNoRecordingsUpload =>
      'এখনো কোনো রেকর্ডিং নেই। অডিও আপলোড করতে 2 টিপুন।';

  @override
  String libraryRecordingsLoaded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি রেকর্ডিং লোড হয়েছে।',
      one: '1টি রেকর্ডিং লোড হয়েছে।',
    );
    return '$_temp0';
  }

  @override
  String get libraryLoadFailed =>
      'রেকর্ডিং লোড করা যায়নি। আপনার ইন্টারনেট সংযোগ দেখে নিন, তারপর আবার চেষ্টা করতে 1 টিপুন।';

  @override
  String get libraryTitleRequired => 'শিরোনাম দিতে হবে।';

  @override
  String get libraryPickFailed =>
      'ফাইলটি খোলা যায়নি। আবার বেছে নেওয়ার চেষ্টা করুন।';

  @override
  String get libraryChooseWorkspaceFirst =>
      'অডিও আপলোড করার আগে শিক্ষক ড্যাশবোর্ডে একটি ক্লাস ও বিষয়ের ওয়ার্কস্পেস বেছে নিন।';

  @override
  String libraryUploadingBrief(String title) {
    return '$title আপলোড হচ্ছে।';
  }

  @override
  String libraryUploadingDetailed(String title) {
    return '$title আপলোড হচ্ছে। প্রতি 25 শতাংশে অগ্রগতি শুনতে পাবেন।';
  }

  @override
  String libraryUploadingOnceDetailed(String title) {
    return '$title আপলোড হচ্ছে। অপেক্ষা করুন; শেষ হলে শুনতে পাবেন।';
  }

  @override
  String libraryUploadProgress(String title, String percent) {
    return '$title: $percent আপলোড হয়েছে।';
  }

  @override
  String libraryUploaded(String title) {
    return '$title আপলোড হয়েছে।';
  }

  @override
  String libraryUploadFailed(String title) {
    return '$title আপলোড করা যায়নি। আপনার সংযোগ দেখে নিন, তারপর আবার চেষ্টা করতে 3 টিপুন।';
  }

  @override
  String get libraryUploadNoSession =>
      'আপলোড বাতিল হয়েছে। অন্তত একটি সেশন বেছে নিন, তারপর আবার অডিও যোগ করতে 3 টিপুন।';

  @override
  String get libraryUploadNoClass => 'সেশনের ক্লাস ও বিষয় ঠিক করা যায়নি।';

  @override
  String get libraryFileUnreadable => 'ফাইলটি পড়া যায়নি। আবার বেছে নিন।';

  @override
  String libraryPreviewStopped(String title) {
    return '$title-এর প্রিভিউ বন্ধ হয়েছে।';
  }

  @override
  String libraryPreviewing(String title) {
    return '$title ব্যক্তিগতভাবে প্রিভিউ হচ্ছে।';
  }

  @override
  String get libraryPreviewFinished => 'প্রিভিউ শেষ হয়েছে।';

  @override
  String libraryPreviewFailed(String title) {
    return '$title চালানো যায়নি। আপনার সংযোগ দেখে নিয়ে আবার চেষ্টা করুন।';
  }

  @override
  String get libraryNoActiveSession => 'কোনো চালু সেশন নেই।';

  @override
  String librarySelectedForSession(String title) {
    return 'সেশনের জন্য $title বেছে নেওয়া হয়েছে।';
  }

  @override
  String get librarySelectFailed =>
      'অডিও বেছে নেওয়া যায়নি। আবার চেষ্টা করুন।';

  @override
  String get libraryClassPlayAccepted => 'ক্লাসে চালানোর অনুরোধ গৃহীত হয়েছে।';

  @override
  String get libraryClassPlayFailed =>
      'ক্লাসে চালানো শুরু করা যায়নি। আবার চেষ্টা করুন।';

  @override
  String get libraryClassPauseAccepted => 'ক্লাসে থামানোর অনুরোধ গৃহীত হয়েছে।';

  @override
  String get libraryClassPauseFailed =>
      'ক্লাসের অডিও থামানো যায়নি। আবার চেষ্টা করুন।';

  @override
  String libraryStopPreviewLabel(String title) {
    return '$title-এর ব্যক্তিগত প্রিভিউ বন্ধ করুন। শুধু আপনি এটি শুনতে পাবেন।';
  }

  @override
  String libraryPreviewLabel(String title) {
    return '$title ব্যক্তিগতভাবে প্রিভিউ করুন। শুধু আপনি এটি শুনতে পাবেন।';
  }

  @override
  String libraryBroadcastLabel(String title) {
    return 'সেশনের সবার জন্য $title চালান';
  }

  @override
  String libraryRecordingsSentence(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি রেকর্ডিং।',
      one: '1টি রেকর্ডিং।',
    );
    return '$_temp0';
  }

  @override
  String libraryPreviewingState(String title) {
    return '$title প্রিভিউ হচ্ছে।';
  }

  @override
  String get libraryUploadInProgress => 'আপলোড চলছে।';

  @override
  String get libraryAccountChanged =>
      'আপনার অ্যাকাউন্ট বদলে গেছে। লাইব্রেরি আবার খুলুন।';

  @override
  String get libraryNoUnfinished =>
      'এই অ্যাকাউন্টে কোনো অসম্পূর্ণ পাঠ সংরক্ষিত নেই। শেখা শুরু করতে একটি রেকর্ড করা পাঠ বেছে নিন।';

  @override
  String get libraryCannotCheckAccess =>
      'পাঠের অ্যাক্সেস দেখা যায়নি। ইন্টারনেটে সংযোগ করে আবার চেষ্টা করুন। আপনার সংরক্ষিত অগ্রগতি রাখা আছে।';

  @override
  String get libraryUnfinishedUnavailable =>
      'আপনার অসম্পূর্ণ পাঠগুলি এখন এই লাইব্রেরিতে পাওয়া যাচ্ছে না। আপনার সংরক্ষিত অগ্রগতি এবং বুকমার্ক রাখা আছে।';

  @override
  String get libraryOpeningNextUnfinished =>
      'সবচেয়ে সাম্প্রতিক পাঠটি এখানে পাওয়া যাচ্ছে না। এর পরের সাম্প্রতিক উপলব্ধ অসম্পূর্ণ পাঠটি খোলা হচ্ছে। সংরক্ষিত অগ্রগতি রাখা আছে।';

  @override
  String get libraryContinueFailed =>
      'সংরক্ষিত শেখার অগ্রগতি খোলা যায়নি। স্টোরেজ, আপনার সংযোগ এবং সাইন ইন দেখে নিয়ে আবার চেষ্টা করুন।';

  @override
  String get libraryNoActiveClassesNow =>
      'এখন কোনো চালু ক্লাস নেই। সব অডিও ফাইলের জন্য 3 টিপুন।';

  @override
  String libraryClassesLoaded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি চালু ক্লাস লোড হয়েছে।',
      one: '1টি চালু ক্লাস লোড হয়েছে।',
    );
    return '$_temp0';
  }

  @override
  String libraryClassesFailed(String reason) {
    return '$reason চালু ক্লাসগুলি রিফ্রেশ করা যায়নি। আবার চেষ্টা করতে 1 টিপুন। সংরক্ষিত ডাউনলোডগুলি পাওয়া যাবে।';
  }

  @override
  String get libraryClassesLoading =>
      'ক্লাসগুলি এখনো লোড হচ্ছে। একটু পরে আবার কী 5 টিপুন।';

  @override
  String get libraryNoActiveClassesStaying =>
      'কোনো চালু ক্লাস নেই। অডিও লাইব্রেরিতেই থাকছেন।';

  @override
  String libraryFirstActiveClass(String title) {
    return '$title। প্রথম সক্রিয় ক্লাস। সক্রিয় ক্লাসের সেশনগুলো দেখতে ডি-প্যাডের উপর ও নিচ ব্যবহার করুন। বেছে নেওয়া ক্লাসের রেকর্ডিং খুলতে ওকে টিপুন।';
  }

  @override
  String get libraryOpeningPlaylists =>
      'আমার প্লেলিস্ট খোলা হচ্ছে। প্লেলিস্টের বিষয়বস্তু ব্যক্তিগত।';

  @override
  String libraryClassLabel(String title, String index, String count) {
    return '$title। $countটির মধ্যে $index নম্বর ক্লাস';
  }

  @override
  String get libraryLoadingActiveClasses => 'সক্রিয় ক্লাসগুলো লোড হচ্ছে।';

  @override
  String libraryActiveClassesSentence(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি সক্রিয় ক্লাস।',
      one: '1টি সক্রিয় ক্লাস।',
    );
    return '$_temp0';
  }

  @override
  String libraryNoRecordingsFor(String where) {
    return '$where-এর জন্য এখনও কোনো রেকর্ডিং নেই।';
  }

  @override
  String libraryRecordingsLoadedFor(int count, String where) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$where-এর জন্য $countটি রেকর্ডিং লোড হয়েছে।',
      one: '$where-এর জন্য 1টি রেকর্ডিং লোড হয়েছে।',
    );
    return '$_temp0';
  }

  @override
  String get libraryDownloadsReadFailed =>
      'ডাউনলোড করা পাঠগুলো পড়া যায়নি। আবার চেষ্টা করতে 1 টিপুন।';

  @override
  String get libraryClassLoadFailed =>
      'রেকর্ডিং লোড করা যায়নি। আপনার ইন্টারনেট সংযোগ ও সাইন ইন দেখে নিন, তারপর আবার চেষ্টা করতে 1 টিপুন।';

  @override
  String libraryRetryAfter(String reason) {
    return '$reason আবার চেষ্টা করতে 1 টিপুন।';
  }

  @override
  String get libraryDownloadedDescription =>
      'ডাউনলোড করা রেকর্ডিং। 30 দিন পরে অ্যাক্সেস নবীকরণ করতে হবে।';

  @override
  String get libraryDownloadedHelp =>
      'ডাউনলোড করা পাঠ। চালানোর আগে বর্তমান অফলাইন অ্যাক্সেস যাচাই করা হয়।';

  @override
  String get libraryOnlineHelp =>
      'অডিও লাইব্রেরি। অনলাইন রেকর্ডিং চালাতে ইন্টারনেট লাগে। অফলাইনে শোনার জন্য পাঠ ডাউনলোড করুন।';

  @override
  String librarySubjectChoice(String name, String index, String count) {
    return 'বিষয়: $name, $countটির মধ্যে $index';
  }

  @override
  String librarySubjectLabel(String choice) {
    return '$choice। বদলাতে 2 টিপুন, অথবা বাঁ ও ডান কী ব্যবহার করুন';
  }

  @override
  String get librarySubjectFixed => 'এই লাইব্রেরি আগে থেকেই একটি বিষয়ে সীমিত।';

  @override
  String libraryLength(String time) {
    return 'দৈর্ঘ্য $time';
  }

  @override
  String libraryRecordingsInSubject(int count, String subject) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$subject-এ $countটি রেকর্ডিং।',
      one: '$subject-এ 1টি রেকর্ডিং।',
    );
    return '$_temp0';
  }

  @override
  String libraryNoTeacherPlaylists(String className, String subject) {
    return '$className, $subject-এর জন্য এখনও কোনো প্লেলিস্ট নেই। একটি তৈরি করতে 2 টিপুন।';
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
      other: '$className, $subject-এর জন্য $countটি প্লেলিস্ট লোড হয়েছে।',
      one: '$className, $subject-এর জন্য 1টি প্লেলিস্ট লোড হয়েছে।',
    );
    return '$_temp0';
  }

  @override
  String get libraryPlaylistCreateFailed => 'প্লেলিস্ট তৈরি করা যায়নি।';

  @override
  String get libraryNoMyPlaylists =>
      'এখনও কোনো প্লেলিস্ট নেই। একটি ব্যক্তিগত প্লেলিস্ট তৈরি করতে 2 টিপুন।';

  @override
  String libraryPrivatePlaylistCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি ব্যক্তিগত প্লেলিস্ট',
      one: '1টি ব্যক্তিগত প্লেলিস্ট',
    );
    return '$_temp0';
  }

  @override
  String libraryClassPlaylistCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি ক্লাস প্লেলিস্ট',
      one: '1টি ক্লাস প্লেলিস্ট',
    );
    return '$_temp0';
  }

  @override
  String libraryMyPlaylistsLoaded(
    String privatePlaylists,
    String classPlaylists,
  ) {
    return '$privatePlaylists এবং $classPlaylists লোড হয়েছে।';
  }

  @override
  String get libraryPrivatePlaylistCreateFailed =>
      'ব্যক্তিগত প্লেলিস্ট তৈরি করা যায়নি।';

  @override
  String libraryPlaylistsSentence(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি প্লেলিস্ট।',
      one: '1টি প্লেলিস্ট।',
    );
    return '$_temp0';
  }

  @override
  String libraryItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি আইটেম',
      one: '1টি আইটেম',
    );
    return '$_temp0';
  }

  @override
  String libraryPlaylistLoaded(String title, String items, String state) {
    return '$title। $items। $state।';
  }

  @override
  String libraryPlaylistLoadedWithPlace(
    String title,
    String place,
    String items,
    String state,
  ) {
    return '$title। $place। $items। $state।';
  }

  @override
  String get libraryPlaylistRefreshFailed =>
      'এই প্লেলিস্ট রিফ্রেশ করা যায়নি। আপনার সংযোগ দেখে আবার চেষ্টা করুন। চলমান প্লেব্যাক ও সেভ করা অগ্রগতি বদলানো হয়নি।';

  @override
  String get libraryPlaylistLessonGone =>
      'বর্তমান পাঠটি এই প্লেলিস্টে আর নেই। প্লেব্যাক বন্ধ হয়েছে। আপনার সেভ করা অগ্রগতি ও বুকমার্ক রাখা আছে।';

  @override
  String get libraryNothingToAdd => 'যোগ করার মতো কোনো উপযুক্ত অডিও নেই।';

  @override
  String libraryAddedToPlaylist(String title) {
    return '$title প্লেলিস্টে যোগ করা হয়েছে।';
  }

  @override
  String get libraryAddFailed =>
      'অডিও যোগ করা যায়নি। আপনার সংযোগ দেখে আবার চেষ্টা করুন।';

  @override
  String libraryItemUnavailable(String title) {
    return '$title আপনার বর্তমান ক্লাসে আর পাওয়া যাচ্ছে না। আপনি এটি এই প্লেলিস্ট থেকে সরাতে পারেন।';
  }

  @override
  String libraryItemCannotPlay(String title) {
    return '$title পাওয়া যাচ্ছে না।';
  }

  @override
  String libraryPlayingItem(String announcement, String index, String count) {
    return '$announcement $countটির মধ্যে $index নম্বর আইটেম।';
  }

  @override
  String get libraryPlaylistPlayFailed =>
      'এই পাঠটি চালানো যায়নি। আপনার সংযোগ দেখে আবার চেষ্টা করুন।';

  @override
  String get libraryPlaylistEmpty => 'প্লেলিস্ট খালি।';

  @override
  String get libraryPlaylistEnded => 'প্লেলিস্ট শেষ। প্লেব্যাক বন্ধ হয়েছে।';

  @override
  String libraryRenamed(String title) {
    return 'প্লেলিস্টের নাম বদলে $title রাখা হয়েছে।';
  }

  @override
  String get libraryRenameFailed =>
      'প্লেলিস্টের নাম বদলানো যায়নি। আপনার সংযোগ দেখে আবার চেষ্টা করুন।';

  @override
  String get libraryAlreadyFirst => 'বেছে নেওয়া আইটেমটি আগে থেকেই প্রথমে আছে।';

  @override
  String get libraryAlreadyLast => 'বেছে নেওয়া আইটেমটি আগে থেকেই শেষে আছে।';

  @override
  String libraryMoved(String title, String position, String count) {
    return '$title $countটির মধ্যে $position নম্বর জায়গায় সরানো হয়েছে।';
  }

  @override
  String libraryMoveFailed(String title) {
    return '$title সরানো যায়নি। আপনার সংযোগ দেখে আবার চেষ্টা করুন।';
  }

  @override
  String libraryRemovedFromPlaylist(String title, String playlist) {
    return '$playlist থেকে $title সরানো হয়েছে।';
  }

  @override
  String libraryRemoveFailed(String title) {
    return '$title সরানো যায়নি। আপনার সংযোগ দেখে আবার চেষ্টা করুন।';
  }

  @override
  String libraryRemoveItemQuestion(String title, String playlist) {
    return '$playlist থেকে $title সরাবেন? রেকর্ডিংটি নিজে লাইব্রেরিতে রাখা থাকবে।';
  }

  @override
  String libraryRemoveItemLabel(String title) {
    return 'প্লেলিস্ট থেকে $title সরান, নিশ্চিত করতে বলা হবে';
  }

  @override
  String libraryPublished(String title) {
    return '$title ক্লাসে প্রকাশ করা হয়েছে।';
  }

  @override
  String libraryReturnedToDraft(String title) {
    return '$title আবার খসড়ায় ফেরানো হয়েছে।';
  }

  @override
  String libraryChangeFailed(String title) {
    return '$title বদলানো যায়নি। আপনার সংযোগ দেখে আবার চেষ্টা করুন।';
  }

  @override
  String libraryDeleted(String title) {
    return '$title মুছে ফেলা হয়েছে।';
  }

  @override
  String libraryRestoredAsDraft(String title) {
    return '$title খসড়া হিসেবে ফিরিয়ে আনা হয়েছে।';
  }

  @override
  String libraryArchived(String title) {
    return '$title আর্কাইভ করা হয়েছে।';
  }

  @override
  String get libraryPlaylistIsEmpty => 'প্লেলিস্টটি খালি।';

  @override
  String librarySelectedItem(String selected, String items) {
    return '$itemsটির মধ্যে $selected নম্বর আইটেম বেছে নেওয়া হয়েছে।';
  }

  @override
  String librarySelectedItemTitled(
    String selected,
    String items,
    String title,
  ) {
    return '$itemsটির মধ্যে $selected নম্বর আইটেম বেছে নেওয়া হয়েছে, $title।';
  }

  @override
  String get libraryAlreadyOneSubject =>
      'এই লাইব্রেরি আগে থেকেই একটি বিষয়ে সীমিত';

  @override
  String get libraryNoLessonIsPlaying => 'কোনো পাঠ চলছে না।';

  @override
  String libraryAddedToSession(String title) {
    return '$title এই সেশনে যোগ করা হয়েছে।';
  }

  @override
  String get libraryPlaylistNotCreated => 'প্লেলিস্ট তৈরি করা যায়নি';

  @override
  String get libraryPrivatePlaylistNotCreated =>
      'ব্যক্তিগত প্লেলিস্ট তৈরি করা যায়নি';

  @override
  String get libraryNoEligibleAudio => 'যোগ করার মতো কোনো উপযুক্ত অডিও নেই';

  @override
  String get libraryAudioAddedToPlaylist => 'অডিও প্লেলিস্টে যোগ করা হয়েছে';

  @override
  String libraryUnavailable(String title) {
    return '$title পাওয়া যাচ্ছে না';
  }

  @override
  String libraryPlaylistRenamed(String title) {
    return 'প্লেলিস্টের নাম বদলে $title রাখা হয়েছে';
  }

  @override
  String libraryMovedTo(String title, String position) {
    return '$title $position নম্বর জায়গায় সরানো হয়েছে';
  }

  @override
  String get libraryNoteRenamed => 'ব্যক্তিগত নোটের নাম বদলানো হয়েছে।';

  @override
  String get downloadNoneYet =>
      'এখনও কোনো ডাউনলোড নেই। অনলাইনে রেকর্ডিং খুঁজতে 2 টিপুন।';

  @override
  String downloadLessonCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি ডাউনলোড করা পাঠ',
      one: '1টি ডাউনলোড করা পাঠ',
    );
    return '$_temp0';
  }

  @override
  String downloadPartialCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি আংশিক ডাউনলোড',
      one: '1টি আংশিক ডাউনলোড',
    );
    return '$_temp0';
  }

  @override
  String downloadReadyToPlay(String lessons) {
    return '$lessons চালানোর জন্য তৈরি।';
  }

  @override
  String downloadReadyToPlayWithPartial(String lessons, String partial) {
    return '$lessons চালানোর জন্য তৈরি, $partial।';
  }

  @override
  String get downloadActionFailed =>
      'এই ডাউনলোডের কাজটি শেষ করা যায়নি। স্টোরেজ, আপনার সংযোগ ও সাইন ইন দেখে নিন, তারপর আবার চেষ্টা করুন।';

  @override
  String get downloadOnlineListFailed =>
      'পাওয়া যায় এমন রেকর্ডিং লোড করা যায়নি। আগের ডাউনলোডগুলো তাদের অ্যাক্সেসের মেয়াদ শেষ না হওয়া পর্যন্ত চলবে।';

  @override
  String downloadAvailable(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$countটি রেকর্ডিং ডাউনলোডের জন্য আছে। আপনি যে রেকর্ডিংগুলো চান তা বেছে নিন।',
      one:
          '1টি রেকর্ডিং ডাউনলোডের জন্য আছে। আপনি যে রেকর্ডিংগুলো চান তা বেছে নিন।',
    );
    return '$_temp0';
  }

  @override
  String downloadStarting(String title) {
    return '$title ডাউনলোড হচ্ছে। প্রতি 25 শতাংশে আপনি অগ্রগতি শুনতে পাবেন।';
  }

  @override
  String downloadProgress(String title, String percent) {
    return '$title $percent ডাউনলোড হয়েছে।';
  }

  @override
  String get downloadVerified =>
      'ডাউনলোড যাচাই করা হয়েছে এবং অফলাইনে শোনার জন্য সেভ করা হয়েছে।';

  @override
  String downloadDone(String title) {
    return '$title ডাউনলোড, যাচাই এবং অফলাইনে শোনার জন্য সেভ করা হয়েছে।';
  }

  @override
  String downloadPackQuestion(String recordings) {
    return '$recordings একটি একটি করে ডাউনলোড করবেন? এতে ইন্টারনেট ডেটা এবং আপনার অ্যাকাউন্টের 50 MB সীমা ব্যবহার হবে। ব্যর্থ হলে বা বাতিল করলে, যাচাই করা ডাউনলোড ও আংশিক ডেটা রাখা থাকবে। আগের কোনো পাঠ মুছে ফেলা হবে না।';
  }

  @override
  String downloadPackStarting(String recordings) {
    return '$recordings একটি একটি করে ডাউনলোড হচ্ছে।';
  }

  @override
  String downloadPackProgress(String done, String total) {
    return '$totalটির মধ্যে $doneটি রেকর্ডিং যাচাই করা হয়েছে।';
  }

  @override
  String downloadPackDone(String done, String total) {
    return '$totalটির মধ্যে $doneটি রেকর্ডিং যাচাই ও সেভ করা হয়েছে।';
  }

  @override
  String downloadRenewed(String title) {
    return '$title-এর অ্যাক্সেস নবীকরণ করা হয়েছে। 30 দিন পর্যন্ত অফলাইনে শোনা যাবে।';
  }

  @override
  String downloadRemoveTitle(String title) {
    return '$title-এর ডাউনলোড সরাবেন?';
  }

  @override
  String downloadRemoveQuestion(String title) {
    return '$title-এর ডাউনলোড করা বা আংশিক অডিও সরাবেন? শেখার অগ্রগতি ও বুকমার্ক রাখা থাকবে। অন্য রেকর্ডিং ও অ্যাকাউন্টের উপর কোনো প্রভাব পড়বে না।';
  }

  @override
  String downloadRemoved(String title) {
    return '$title-এর ডাউনলোড সরানো হয়েছে। অগ্রগতি ও বুকমার্ক রাখা আছে।';
  }

  @override
  String downloadUnreadableTitle(String id) {
    return 'পড়া যায় না এমন রেকর্ডিং $id';
  }

  @override
  String get downloadRenewalRequired => 'অ্যাক্সেস নবীকরণ করতে হবে।';

  @override
  String downloadAccessExpires(String date) {
    return 'অ্যাক্সেসের মেয়াদ শেষ হবে $date।';
  }

  @override
  String downloadPlayLabelComplete(String title, String size, String expiry) {
    return '$title চালান। ডাউনলোড করা। $size। $expiry';
  }

  @override
  String downloadPlayLabelPartial(String title, String size, String expiry) {
    return '$title চালান। আংশিক ডাউনলোড, এখনও চালানো যাবে না। $size। $expiry';
  }

  @override
  String downloadRenewLabel(String title) {
    return '$title-এর অ্যাক্সেস নবীকরণ করুন। ইন্টারনেট লাগবে';
  }

  @override
  String downloadRemoveLabel(String title) {
    return '$title-এর ডাউনলোড সরান, নিশ্চিত করতে বলা হবে';
  }

  @override
  String downloadUnreadableLabel(String id) {
    return 'পড়া যায় না এমন ডাউনলোড রেকর্ড $id। শুধু এই ডাউনলোডটি সরান, নিশ্চিত করতে বলা হবে';
  }

  @override
  String downloadOrResumeLabel(String title) {
    return '$title ডাউনলোড করুন বা আবার শুরু করুন';
  }

  @override
  String downloadCancelLabel(String title) {
    return '$title-এর ডাউনলোড বাতিল করুন, কী 4। আবার চেষ্টার জন্য আংশিক ডেটা রাখা হবে';
  }

  @override
  String downloadUnavailableWhileBusy(String label) {
    return 'ডাউনলোড চলার সময় $label ব্যবহার করা যাবে না।';
  }

  @override
  String get downloadStorageUnknown =>
      'স্টোরেজ সংরক্ষণের তথ্য পাওয়া যাচ্ছে না। ডাউনলোড করার আগে ডাউনলোডগুলো রিফ্রেশ করুন অথবা বেছে নেওয়া পড়া যায় না এমন রেকর্ডগুলো সরান।';

  @override
  String downloadCountComma(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি ডাউনলোড,',
      one: '1টি ডাউনলোড,',
    );
    return '$_temp0';
  }

  @override
  String get downloadStorageUseUnknown => 'স্টোরেজের ব্যবহার অজানা।';

  @override
  String downloadDownloadingStarting(String title) {
    return '$title ডাউনলোড হচ্ছে, শুরু হচ্ছে।';
  }

  @override
  String downloadDownloadingPercent(String title, String percent) {
    return '$title ডাউনলোড হচ্ছে, $percent।';
  }

  @override
  String downloadScreenLoaded(String complete) {
    return '$completeটি ডাউনলোড করা পাঠ চালানোর জন্য তৈরি।';
  }

  @override
  String downloadScreenLoadedWithPartial(String complete, String partial) {
    return '$completeটি ডাউনলোড করা পাঠ চালানোর জন্য তৈরি, $partialটি আংশিক ডাউনলোড।';
  }

  @override
  String downloadAvailableCount(String count) {
    return '$countটি রেকর্ডিং ডাউনলোডের জন্য আছে। আপনি যে রেকর্ডিংগুলো চান তা বেছে নিন।';
  }

  @override
  String downloadRecordingFallback(String id) {
    return 'রেকর্ডিং $id';
  }

  @override
  String get downloadPackDialogTitle => 'তালিকার রেকর্ডিংগুলো ডাউনলোড করবেন?';

  @override
  String downloadPackDialogMessage(String count) {
    return 'তালিকার $countটি রেকর্ডিং একটি একটি করে ডাউনলোড করবেন? এতে ইন্টারনেট ডেটা এবং আপনার অ্যাকাউন্টের 50 MB সীমা ব্যবহার হবে। ব্যর্থ হলে বা বাতিল করলে, যাচাই করা ডাউনলোড ও আংশিক ডেটা রাখা থাকবে। আগের কোনো পাঠ মুছে ফেলা হবে না।';
  }

  @override
  String get downloadPackConfirm => 'তালিকার সব ডাউনলোড করুন';

  @override
  String get downloadPackCancel => 'একটি একটি করে বেছে নিন';

  @override
  String get downloadRemoveConfirm => 'ডাউনলোড সরান';

  @override
  String get downloadKeep => 'ডাউনলোড রাখুন';

  @override
  String get downloadScreenName => 'ডাউনলোড করা পাঠ';

  @override
  String get downloadCancelBackTitle => 'ডাউনলোড বাতিল করে ফিরে যাবেন?';

  @override
  String get downloadCancelBackMessage =>
      'এই ডাউনলোড বন্ধ করবেন? যাচাই করা রেকর্ডিং ও আংশিক ডেটা পরে নিজে আবার চেষ্টা করার জন্য রাখা থাকবে।';

  @override
  String get downloadCancelBackConfirm => 'বাতিল করে ফিরে যান';

  @override
  String get downloadKeepDownloading => 'ডাউনলোড চালিয়ে যান';

  @override
  String downloadReserved(String megabytes) {
    return 'এই অ্যাকাউন্টের জন্য 50 MB-এর মধ্যে $megabytes সংরক্ষিত।';
  }

  @override
  String get downloadBack => 'ফিরে যান';

  @override
  String get downloadRefreshLabel => 'সেভ করা ডাউনলোড রিফ্রেশ করুন, কী 1';

  @override
  String get downloadFindOnlineLabel =>
      'ডাউনলোডের জন্য রেকর্ডিং খুঁজুন, কী 2। ইন্টারনেট লাগবে';

  @override
  String get downloadReadStatusLabel => 'ডাউনলোডের অবস্থা শুনুন, কী 3';

  @override
  String downloadPlayDownloadedLabel(String title) {
    return '$title চালান। ডাউনলোড করা';
  }

  @override
  String downloadPlayPartialLabel(String title) {
    return '$title চালান। আংশিক ডাউনলোড, এখনও চালানো যাবে না';
  }

  @override
  String get downloadPackLabel =>
      'তালিকার সব রেকর্ডিং ডাউনলোড করুন, কী 5, নিশ্চিত করতে বলা হবে';

  @override
  String get downloadIntroduction =>
      'প্রতি অ্যাকাউন্টে 50 MB। অনলাইনে অ্যাক্সেস নবীকরণের আগে 30 দিন পর্যন্ত অফলাইনে চলবে। ফাইল ও অগ্রগতি আলাদা থাকে।';

  @override
  String get downloadNavigationSections =>
      'চালানো, নবীকরণ বা সরানোর জন্য সেভ করা ফাইল, এবং ডাউনলোড বা আবার শুরু করার জন্য অনলাইন রেকর্ডিং';

  @override
  String get downloadKeyRefresh => 'ডাউনলোড রিফ্রেশ করুন';

  @override
  String get downloadKeyFindOnline => 'অনলাইনে রেকর্ডিং খুঁজুন';

  @override
  String get downloadKeyReadStatus => 'অবস্থা শুনুন';

  @override
  String get downloadKeyCancel => 'ডাউনলোড বাতিল করুন';

  @override
  String get downloadKeyPack => 'তালিকার রেকর্ডিং ডাউনলোড করুন';

  @override
  String get downloadErrInvalidInfo =>
      'ডাউনলোডের তথ্য সঠিক নয় অথবা অন্য অ্যাকাউন্টের। আগের ফাইলগুলো রাখা আছে।';

  @override
  String get downloadErrSignInToOpen =>
      'ডাউনলোড করা পাঠ খোলার আগে সাইন ইন করুন।';

  @override
  String get downloadErrAccountChanged =>
      'আপনার অ্যাকাউন্ট বদলে গেছে। আবার ডাউনলোড খুলুন।';

  @override
  String get downloadErrNoStorage =>
      'এই ডিভাইসে ডাউনলোডের স্টোরেজ পাওয়া যাচ্ছে না।';

  @override
  String get downloadErrStorageUnavailable =>
      'ডাউনলোডের স্টোরেজ পাওয়া যাচ্ছে না। খালি জায়গা দেখে আবার চেষ্টা করুন। আগের ফাইলগুলো ইচ্ছাকৃতভাবে সরানো হয়নি।';

  @override
  String get downloadErrRecordsUnreadable =>
      'ডাউনলোডের রেকর্ডগুলো পড়া যায়নি। আগের ফাইলগুলো রাখা আছে।';

  @override
  String get downloadErrRecordUnreadable =>
      'একটি ডাউনলোড রেকর্ড পড়া যায়নি। আগের ফাইলগুলো রাখা আছে।';

  @override
  String get downloadErrIdentityMismatch =>
      'ডাউনলোডের পরিচয় তার রেকর্ডের সঙ্গে মিলছে না।';

  @override
  String get downloadErrSignInToRenew =>
      'ডাউনলোডের অ্যাক্সেস নবীকরণের আগে অনলাইনে সাইন ইন করুন।';

  @override
  String get downloadErrSignInChanged =>
      'আপনার সাইন ইন বদলে গেছে। আবার ডাউনলোড খুলুন।';

  @override
  String get downloadErrAccessNotConfirmed =>
      'এই অ্যাকাউন্টের জন্য রেকর্ডিংয়ের অ্যাক্সেস আর নিশ্চিত নয়। নবীকরণ করতে আবার সংযোগ করে সাইন ইন করুন। সেভ করা ফাইলটি রাখা আছে।';

  @override
  String get downloadErrTooLarge =>
      'এই রেকর্ডিংটি 50 MB ডাউনলোড সীমার চেয়ে বড়।';

  @override
  String get downloadErrRenewServer =>
      'সার্ভার এই রেকর্ডিংটি নবীকরণ করতে পারেনি। পরে আবার চেষ্টা করুন।';

  @override
  String get downloadErrInvalidServerInfo =>
      'সার্ভার ভুল ডাউনলোডের তথ্য পাঠিয়েছে।';

  @override
  String get downloadErrDifferentRecording =>
      'সার্ভার অন্য একটি রেকর্ডিং পাঠিয়েছে।';

  @override
  String get downloadErrTimedOut =>
      'সংযোগের সময় শেষ হয়ে গেছে। আবার সংযোগ করে চেষ্টা করুন।';

  @override
  String get downloadErrRenewConnect =>
      'এই রেকর্ডিং নবীকরণের জন্য সংযোগ করা যায়নি। আপনার ইন্টারনেট সংযোগ দেখে নিন।';

  @override
  String get downloadErrClockUnreadable =>
      'অফলাইন সময়ের রেকর্ড পড়া যায়নি। সংযোগ করে অ্যাক্সেস নবীকরণ করুন।';

  @override
  String get downloadErrClockBackwards =>
      'ফোনের ঘড়ি পিছিয়ে গেছে। তারিখ ঠিক করে আবার সংযোগ করে অ্যাক্সেস নবীকরণ করুন।';

  @override
  String get downloadErrExpired =>
      '30 দিন পরে অফলাইন অ্যাক্সেসের মেয়াদ শেষ হয়েছে। ইন্টারনেটে সংযোগ করে এই পাঠটি নবীকরণ করুন। আপনার অগ্রগতি ও ডাউনলোড করা ফাইল রাখা আছে।';

  @override
  String get downloadErrIncompleteForPlayback =>
      'অফলাইনে শোনার আগে এই পাঠটি পুরোপুরি ডাউনলোড করুন।';

  @override
  String get downloadErrRenewalRequired =>
      'অ্যাক্সেস নবীকরণ করতে হবে। এই ডাউনলোড চালানোর আগে সংযোগ করে নবীকরণ করুন।';

  @override
  String get downloadErrDamaged =>
      'ডাউনলোড করা রেকর্ডিংটি অসম্পূর্ণ বা নষ্ট। এই ডাউনলোডটি সরিয়ে আবার ডাউনলোড করুন। অগ্রগতি ও বুকমার্ক আলাদা থাকে।';

  @override
  String get downloadErrDownloadFirst => 'আগে এই পাঠটি ডাউনলোড করুন।';

  @override
  String get downloadErrRecordingChangedRenew =>
      'এই রেকর্ডিংটি বদলে গেছে। এর ডাউনলোড সরিয়ে বর্তমান রেকর্ডিংটি ডাউনলোড করুন। অগ্রগতি ও বুকমার্ক রাখা আছে।';

  @override
  String get downloadErrCancelledAnyPartial =>
      'ডাউনলোড বাতিল হয়েছে। কোনো আংশিক ফাইল থাকলে তা পরে নিজে আবার চেষ্টা করার জন্য রাখা আছে।';

  @override
  String get downloadErrRecordingChanged =>
      'রেকর্ডিংটি বদলে গেছে। বর্তমান সংস্করণ ডাউনলোড করার আগে এর পুরোনো ডাউনলোড সরান। অগ্রগতি রাখা আছে।';

  @override
  String get downloadErrSavedDamaged =>
      'সেভ করা রেকর্ডিংটি নষ্ট। আবার চেষ্টা করার আগে এর ডাউনলোড সরান।';

  @override
  String get downloadErrQuota =>
      'আপনার অ্যাকাউন্ট 50 MB ডাউনলোড সীমায় পৌঁছে গেছে। আপনার কোন ডাউনলোডগুলো সরাবেন তা বেছে নিন, তারপর আবার চেষ্টা করুন। কিছুই মোছা হয়নি।';

  @override
  String get downloadErrPartialInvalid =>
      'আংশিক ডাউনলোডটি সঠিক নয়। আবার চেষ্টা করার আগে এটি মুছে ফেলুন।';

  @override
  String get downloadErrIntegrityPartial =>
      'ডাউনলোড যাচাই ব্যর্থ হয়েছে। আবার চেষ্টা করার আগে এই আংশিক ডাউনলোডটি মুছে ফেলুন।';

  @override
  String get downloadErrSignInToDownload => 'ডাউনলোড করার আগে সাইন ইন করুন।';

  @override
  String get downloadErrCancelledExplicit =>
      'ডাউনলোড বাতিল হয়েছে। আপনি নিজে আবার চেষ্টা করার জন্য আংশিক ডেটা রাখা হয়েছে।';

  @override
  String get downloadErrAccessDenied =>
      'ডাউনলোডের অনুমতি দেওয়া হয়নি। আবার সংযোগ করুন এবং অনুমতি নবীকরণ করুন।';

  @override
  String get downloadErrUnexpectedPartial =>
      'সার্ভার অপ্রত্যাশিতভাবে আংশিক রেকর্ডিং পাঠিয়েছে। আগের ডেটা না মুছে আবার চেষ্টা করুন।';

  @override
  String get downloadErrCouldNotDownload =>
      'রেকর্ডিংটি ডাউনলোড করা যায়নি। আপনার সংযোগ দেখে আবার চেষ্টা করুন।';

  @override
  String get downloadErrSizeChanged =>
      'রেকর্ডিংয়ের আকার বদলে গেছে। আবার ডাউনলোড করার চেষ্টা করুন।';

  @override
  String get downloadErrAccountChangedStopped =>
      'আপনার অ্যাকাউন্ট বদলে গেছে। ডাউনলোড বন্ধ করা হয়েছে।';

  @override
  String get downloadErrExceededSize =>
      'রেকর্ডিংটি তার ঘোষিত আকারের চেয়ে বড় হয়ে গেছে। ডাউনলোড বন্ধ হয়েছে।';

  @override
  String get downloadErrIntegrity =>
      'ডাউনলোড যাচাই ব্যর্থ হয়েছে। অসম্পূর্ণ ডাউনলোড আবার চেষ্টা করুন, অথবা আবার চেষ্টা করার আগে নষ্ট হওয়া আংশিক ডেটা মুছে ফেলুন।';

  @override
  String get downloadErrSignInChangedStopped =>
      'আপনার সাইন ইন বদলে গেছে। ইনস্টল হওয়ার আগেই ডাউনলোড বন্ধ হয়েছে।';

  @override
  String get downloadErrTimedOutPartial =>
      'ডাউনলোডের সময় শেষ হয়ে গেছে। আংশিক ডেটা রাখা হয়েছে; আবার চেষ্টা করতে ডাউনলোড চালু করুন।';

  @override
  String get downloadErrCancelledRetry =>
      'ডাউনলোড বাতিল হয়েছে। আবার চেষ্টা করার জন্য আংশিক ডেটা রাখা হয়েছে।';

  @override
  String get downloadErrInterrupted =>
      'ডাউনলোড মাঝপথে থেমে গেছে। আংশিক ডেটা রাখা হয়েছে; আবার চেষ্টা করতে ডাউনলোড চালু করুন।';

  @override
  String get libraryErrStorageUnavailable =>
      'এই ডিভাইসে শেখার স্টোরেজ পাওয়া যাচ্ছে না। আপনার আগের ডেটা বদলানো হয়নি।';

  @override
  String get libraryErrStorageNotOpened =>
      'শেখার স্টোরেজ খোলা যায়নি। খালি জায়গা দেখে আবার চেষ্টা করুন।';

  @override
  String get libraryErrNoStorageLocation =>
      'এই ডিভাইস শেখার স্টোরেজের জায়গা দেয়নি। আপনার আগের ডেটা বদলানো হয়নি।';

  @override
  String get libraryErrStartLessonFirst =>
      'অগ্রগতি সেভ করার আবার চেষ্টা করার আগে একটি পাঠ শুরু করুন।';

  @override
  String get libraryErrProgressNotSaved =>
      'শেখার অগ্রগতি সেভ হয়নি। স্টোরেজ পাওয়া গেলে আবার চেষ্টা করুন।';

  @override
  String get libraryErrChoosePosition => 'পাঠের ভেতরে একটি অবস্থান বেছে নিন';

  @override
  String get libraryErrChooseSpeed =>
      '0.25 থেকে 3 এর মধ্যে একটি চালানোর গতি বেছে নিন';

  @override
  String get libraryErrChooseBookmarkPosition =>
      'পাঠের ভেতরে একটি বুকমার্কের অবস্থান বেছে নিন';

  @override
  String get libraryErrBookmarkNotSaved =>
      'অগ্রগতি সেভ করা যাচ্ছে না। বুকমার্কটি সেভ হয়নি।';

  @override
  String get libraryErrBookmarkChangesUnavailable =>
      'অগ্রগতি সেভ করা আবার চালু না হওয়া পর্যন্ত বুকমার্ক বদলানো যাবে না।';

  @override
  String get libraryErrRepeatNotSaved =>
      'অগ্রগতি সেভ করা যাচ্ছে না। পুনরাবৃত্তির অংশ সেভ হয়নি।';

  @override
  String get libraryErrSetRepeatFirst =>
      'আগে এই পাঠের ভেতরে একটি শুরুর বিন্দু এবং তার পরের একটি শেষের বিন্দু ঠিক করুন';

  @override
  String get libraryErrRepeatFailed =>
      'পুনরাবৃত্তি চালানো ব্যর্থ হয়েছে। থামিয়ে আবার চেষ্টা করুন।';

  @override
  String get libraryScreenBack => 'পেছনে';

  @override
  String get libraryScreenRefreshTarget => 'অডিও ফাইল রিফ্রেশ করুন, কী 1';

  @override
  String get libraryScreenPauseSessionTarget => 'পুরো সেশনের অডিও থামান, কী 3';

  @override
  String get libraryScreenUploadTarget => 'অডিও আপলোড করুন, কী 2';

  @override
  String libraryScreenStopPreviewTarget(String title) {
    return '$title এর ব্যক্তিগত প্রিভিউ বন্ধ করুন। শুধু আপনি এটি শুনতে পাবেন।';
  }

  @override
  String libraryScreenPreviewTarget(String title) {
    return '$title ব্যক্তিগতভাবে প্রিভিউ করুন। শুধু আপনি এটি শুনতে পাবেন।';
  }

  @override
  String libraryScreenBroadcastTarget(String title) {
    return 'সেশনের সবার জন্য $title চালান';
  }

  @override
  String get libraryScreenPreviewFinished => 'প্রিভিউ শেষ হয়েছে';

  @override
  String get libraryScreenNoRecordings =>
      'এখনও কোনো রেকর্ডিং নেই। অডিও আপলোড করতে 2 টিপুন।';

  @override
  String libraryScreenRecordingsLoaded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি রেকর্ডিং লোড হয়েছে।',
    );
    return '$_temp0';
  }

  @override
  String get libraryScreenLoadFailed =>
      'রেকর্ডিং লোড করা যায়নি। আপনার ইন্টারনেট সংযোগ দেখুন, তারপর আবার চেষ্টা করতে 1 টিপুন।';

  @override
  String get libraryScreenTitleRequired => 'শিরোনাম দেওয়া আবশ্যক';

  @override
  String get libraryScreenUploadDialogName => 'অডিও আপলোড করুন';

  @override
  String get libraryScreenEditTitleKey => 'শিরোনাম সম্পাদনা';

  @override
  String get libraryScreenEditDescriptionKey => 'বিবরণ সম্পাদনা';

  @override
  String get libraryScreenUploadKey => 'আপলোড';

  @override
  String get libraryScreenCancelKey => 'বাতিল';

  @override
  String get libraryScreenTitleField => 'অডিওর শিরোনাম, আবশ্যক';

  @override
  String get libraryScreenDescriptionField => 'অডিওর বিবরণ, ঐচ্ছিক';

  @override
  String get libraryScreenCancelUpload => 'আপলোড বাতিল করুন';

  @override
  String get libraryScreenPickFailed => 'ফাইল বেছে নেওয়া যায়নি';

  @override
  String get libraryScreenChooseWorkspace =>
      'অডিও আপলোড করার আগে শিক্ষক ড্যাশবোর্ডে একটি ক্লাস ও বিষয়ের ওয়ার্কস্পেস বেছে নিন।';

  @override
  String libraryScreenUploading(String title) {
    return '$title আপলোড হচ্ছে। প্রতি 25 শতাংশে আপনি অগ্রগতি শুনতে পাবেন।';
  }

  @override
  String libraryScreenUploaded(String title) {
    return '$title আপলোড হয়েছে।';
  }

  @override
  String libraryScreenUploadProgress(String title, String percent) {
    return '$title: $percent শতাংশ আপলোড হয়েছে।';
  }

  @override
  String libraryScreenPreviewStopped(String title) {
    return '$title এর প্রিভিউ বন্ধ হয়েছে';
  }

  @override
  String libraryScreenPreviewing(String title) {
    return '$title ব্যক্তিগতভাবে প্রিভিউ হচ্ছে';
  }

  @override
  String libraryScreenPlayFailed(String title) {
    return '$title চালানো যায়নি। আপনার সংযোগ দেখে আবার চেষ্টা করুন।';
  }

  @override
  String get libraryScreenNoActiveSession => 'কোনো চালু সেশন নেই';

  @override
  String libraryScreenSelectedForSession(String title) {
    return 'সেশনের জন্য $title বেছে নেওয়া হয়েছে';
  }

  @override
  String get libraryScreenAudioSelectedTitle => 'অডিও বেছে নেওয়া হয়েছে';

  @override
  String libraryScreenPlayForEveryoneNow(String title) {
    return 'সেশনের সবার জন্য এখনই \"$title\" চালাবেন?';
  }

  @override
  String get libraryScreenNotYet => 'এখন নয়';

  @override
  String get libraryScreenPlayNow => 'এখনই চালান';

  @override
  String get libraryScreenSelectFailed => 'অডিও বেছে নেওয়া যায়নি';

  @override
  String get libraryScreenPlaybackAccepted =>
      'ক্লাসে চালানোর অনুরোধ গ্রহণ করা হয়েছে';

  @override
  String get libraryScreenPlaybackFailed => 'চালানো শুরু করা যায়নি';

  @override
  String get libraryScreenPauseAccepted =>
      'ক্লাসে থামানোর অনুরোধ গ্রহণ করা হয়েছে';

  @override
  String get libraryScreenPauseFailed => 'অডিও থামানো যায়নি';

  @override
  String get libraryScreenAudioLibraryName => 'অডিও লাইব্রেরি';

  @override
  String get libraryScreenAudioLibrarySections =>
      'রেকর্ডিং, চালানো ও কণ্ঠস্বরের নিয়ন্ত্রণ, রেকর্ডিং শেয়ার করা, এবং থাকলে আপলোডের সরঞ্জাম';

  @override
  String get libraryScreenRefreshKey => 'অডিও ফাইল রিফ্রেশ';

  @override
  String get libraryScreenUploadAudioKey => 'অডিও আপলোড';

  @override
  String get libraryScreenPauseSessionKey => 'সেশনের অডিও থামান';

  @override
  String get libraryScreenBrowseTarget =>
      'প্রথম চালু ক্লাসে যান। চালু সেশনগুলো দেখতে D-pad ব্যবহার করুন';

  @override
  String get libraryScreenRefreshClassesTarget => 'ক্লাসগুলো রিফ্রেশ করুন';

  @override
  String get libraryScreenSearchClassField => 'নাম দিয়ে ক্লাস খুঁজুন';

  @override
  String get libraryScreenSearchTarget => 'খুঁজুন';

  @override
  String get libraryScreenAllRecordedTarget => 'সব রেকর্ড করা অডিও ফাইল';

  @override
  String get libraryScreenContinueTarget =>
      'শেখা চালিয়ে যান। আপনার শেষ অসম্পূর্ণ রেকর্ড করা পাঠ খুঁজুন';

  @override
  String get libraryScreenDownloadsTarget =>
      'ডাউনলোড করা পাঠ। অনলাইন তালিকা লোড না করেই সেভ করা রেকর্ডিং খুলুন';

  @override
  String get libraryScreenNotesTarget =>
      'ব্যক্তিগত নোট এবং শিক্ষকের রেকর্ডিংয়ের খসড়া। ডিভাইসের স্টোরেজ থেকে কাজ করে';

  @override
  String get libraryScreenMyPlaylistsTarget => 'আমার ব্যক্তিগত প্লেলিস্ট';

  @override
  String libraryScreenClassTarget(String title, String position, String total) {
    return '$title। $totalটির মধ্যে $position নম্বর ক্লাস';
  }

  @override
  String get libraryScreenAccountChanged =>
      'আপনার অ্যাকাউন্ট বদলে গেছে। লাইব্রেরিটি আবার খুলুন।';

  @override
  String get libraryScreenNoUnfinishedLesson =>
      'এই অ্যাকাউন্টে কোনো অসম্পূর্ণ পাঠ সেভ করা নেই। শেখা শুরু করতে একটি রেকর্ড করা পাঠ বেছে নিন।';

  @override
  String get libraryScreenAccessCheckFailed =>
      'পাঠের অনুমতি যাচাই করা যায়নি। ইন্টারনেটে সংযোগ করে আবার চেষ্টা করুন। আপনার সেভ করা অগ্রগতি রাখা আছে।';

  @override
  String get libraryScreenUnfinishedUnavailable =>
      'আপনার অসম্পূর্ণ পাঠগুলো এখন এই লাইব্রেরিতে পাওয়া যাচ্ছে না। আপনার সেভ করা অগ্রগতি ও বুকমার্ক রাখা আছে।';

  @override
  String get libraryScreenOpeningNextUnfinished =>
      'সবচেয়ে সাম্প্রতিক পাঠটি এখানে পাওয়া যাচ্ছে না। এর পরের সাম্প্রতিক পাওয়া যায় এমন অসম্পূর্ণ পাঠটি খোলা হচ্ছে। সেভ করা অগ্রগতি রাখা আছে।';

  @override
  String get libraryScreenProgressOpenFailed =>
      'সেভ করা শেখার অগ্রগতি খোলা যায়নি। স্টোরেজ, আপনার সংযোগ এবং সাইন ইন দেখে আবার চেষ্টা করুন।';

  @override
  String get libraryScreenContinueLearningTitle => 'শেখা চালিয়ে যান';

  @override
  String get libraryScreenNoActiveClasses =>
      'এখন কোনো চালু ক্লাস নেই। সব অডিও ফাইলের জন্য 3 টিপুন।';

  @override
  String libraryScreenActiveClassesLoaded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি চালু ক্লাস লোড হয়েছে।',
    );
    return '$_temp0';
  }

  @override
  String libraryScreenClassesRefreshFailed(String reason) {
    return '$reason চালু ক্লাসগুলো রিফ্রেশ করা যায়নি। আবার চেষ্টা করতে 1 টিপুন। সেভ করা ডাউনলোড পাওয়া যাবে।';
  }

  @override
  String get libraryScreenClassListUnreadable => 'ক্লাসের তালিকা পড়া যায়নি।';

  @override
  String get libraryScreenSessionFallback => 'সেশন';

  @override
  String get libraryScreenMyAudioLibraryTitle => 'আমার অডিও লাইব্রেরি';

  @override
  String get libraryScreenAllAudioFilesTitle => 'সব অডিও ফাইল';

  @override
  String get libraryScreenNoActiveClassesStaying =>
      'কোনো চালু ক্লাস নেই। অডিও লাইব্রেরিতেই থাকা হচ্ছে।';

  @override
  String libraryScreenFirstActiveClass(String title) {
    return '$title। প্রথম চালু ক্লাস। চালু ক্লাস সেশনগুলো দেখতে D-pad উপরে ও নিচে ব্যবহার করুন। বেছে নেওয়া ক্লাসের রেকর্ডিং খুলতে ওকে টিপুন।';
  }

  @override
  String get libraryScreenRecordedLibraryName =>
      'রেকর্ড করা অডিও লাইব্রেরি। অনলাইন তালিকার জন্য ইন্টারনেট লাগবে। অফলাইনে চালানোর জন্য ডাউনলোড করা পাঠ আলাদাভাবে খোলে।';

  @override
  String get libraryScreenRecordedLibrarySections =>
      'শেখা চালিয়ে যাওয়া, সেভ করা ডাউনলোড ও ব্যক্তিগত নোট, ক্লাস খোঁজা, এবং চালু ক্লাস সেশন';

  @override
  String get libraryScreenMyPlaylistsKey => 'আমার ব্যক্তিগত প্লেলিস্ট';

  @override
  String get libraryScreenWaitForPlayerNotes =>
      'পড়ার নোট খোলার আগে রেকর্ডিং প্লেয়ারের জন্য অপেক্ষা করুন।';

  @override
  String get libraryScreenStatusPlaying => 'চলছে';

  @override
  String get libraryScreenStatusPaused => 'থেমে আছে';

  @override
  String get libraryScreenUntitled => 'শিরোনামহীন';

  @override
  String get libraryScreenSubjectFallback => 'বিষয়';

  @override
  String get libraryScreenDownloadedLessonsName =>
      'ডাউনলোড করা পাঠ। চালানোর আগে বর্তমান অফলাইন অনুমতি যাচাই করা হয়।';

  @override
  String get libraryScreenClassAudioName =>
      'অডিও লাইব্রেরি। অনলাইন রেকর্ডিংয়ের জন্য ইন্টারনেট লাগবে। অফলাইনে চালাতে পাঠ ডাউনলোড করুন।';

  @override
  String libraryScreenLessonPositionTarget(String position) {
    return 'পাঠের অবস্থান $position। 10 সেকেন্ড সরাতে বাঁ বা ডান ব্যবহার করুন।';
  }

  @override
  String libraryScreenBack10Target(String key) {
    return '10 সেকেন্ড পেছনে, কী $key';
  }

  @override
  String libraryScreenPauseTarget(String title, String key) {
    return '$title থামান, কী $key';
  }

  @override
  String libraryScreenResumeTarget(String title, String key) {
    return '$title আবার চালান, কী $key';
  }

  @override
  String get libraryScreenLessonFallback => 'পাঠ';

  @override
  String libraryScreenForward10Target(String key) {
    return '10 সেকেন্ড সামনে, কী $key';
  }

  @override
  String libraryScreenSlowerTarget(String key, String speed) {
    return 'ধীরে, কী $key। এখন $speed গুণ';
  }

  @override
  String libraryScreenStopTarget(String title) {
    return '$title বন্ধ করুন, কী 8';
  }

  @override
  String libraryScreenFasterTarget(String key, String speed) {
    return 'দ্রুত, কী $key। এখন $speed গুণ';
  }

  @override
  String get libraryScreenDownloadsManageTarget =>
      'পাঠ ডাউনলোড করুন বা সেভ করা রেকর্ডিং পরিচালনা করুন';

  @override
  String get libraryScreenStopSpeechTarget => 'কণ্ঠস্বর বন্ধ করুন';

  @override
  String get libraryScreenUploadFirstTarget => 'প্রথম অডিও আপলোড করুন';

  @override
  String get libraryScreenRefreshEmptyTarget =>
      'খালি অডিও লাইব্রেরি রিফ্রেশ করুন';

  @override
  String get libraryScreenAddAudioTarget => 'অডিও যোগ করুন, কী 3';

  @override
  String get libraryScreenLessonTitleFallback => 'পাঠ';

  @override
  String get libraryScreenDownloadedDescription =>
      'ডাউনলোড করা রেকর্ডিং। 30 দিন পরে অনুমতি নবীকরণ করতে হবে।';

  @override
  String libraryScreenSavedSubject(String id) {
    return 'সেভ করা বিষয় $id';
  }

  @override
  String get libraryScreenDownloadsReadFailed =>
      'ডাউনলোড করা পাঠ পড়া যায়নি। আবার চেষ্টা করতে 1 টিপুন।';

  @override
  String get libraryScreenLoadFailedSignIn =>
      'রেকর্ডিং লোড করা যায়নি। আপনার ইন্টারনেট সংযোগ ও সাইন ইন দেখুন, তারপর আবার চেষ্টা করতে 1 টিপুন।';

  @override
  String libraryScreenNoRecordingsFor(String name) {
    return '$name এর জন্য এখনও কোনো রেকর্ডিং নেই।';
  }

  @override
  String libraryScreenRecordingsLoadedFor(int count, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$name এর জন্য $countটি রেকর্ডিং লোড হয়েছে।',
    );
    return '$_temp0';
  }

  @override
  String get libraryScreenLessonNoLongerAvailable =>
      'এই পাঠটি আর পাওয়া যাচ্ছে না। আপনার সেভ করা অগ্রগতি ও বুকমার্ক রাখা আছে।';

  @override
  String libraryScreenFailurePressRetry(String reason) {
    return '$reason আবার চেষ্টা করতে 1 টিপুন।';
  }

  @override
  String libraryScreenSubjectNumber(String id) {
    return 'বিষয় $id';
  }

  @override
  String get libraryScreenShowingAllSubjects => 'সব বিষয়ের অডিও দেখানো হচ্ছে';

  @override
  String libraryScreenShowingSubject(String subject, String count) {
    return '$subject এর অডিও দেখানো হচ্ছে। $countটি ফাইল';
  }

  @override
  String libraryScreenPausedAt(String position) {
    return '$position এ থামানো হয়েছে।';
  }

  @override
  String get libraryScreenCheckingOfflineAccess =>
      'ইন্টারনেট পাওয়া যাচ্ছে না। আপনার সেভ করা অফলাইন অনুমতি যাচাই করা হচ্ছে।';

  @override
  String libraryScreenPlayFailedSelectAgain(String title) {
    return '$title চালানো যায়নি। আপনার সংযোগ দেখুন, তারপর এটি আবার বেছে নিন।';
  }

  @override
  String get libraryScreenNothingPlaying => 'কিছুই চলছে না।';

  @override
  String libraryScreenTitleStopped(String title) {
    return '$title বন্ধ হয়েছে।';
  }

  @override
  String libraryScreenNoLessonPlayingPress(String key) {
    return 'কোনো পাঠ চলছে না। প্রথম পাঠ চালাতে $key টিপুন।';
  }

  @override
  String get libraryScreenSeekFailed =>
      'পাঠের ওই অবস্থানে যাওয়া যায়নি। আবার চেষ্টা করুন।';

  @override
  String get libraryScreenSlowestSpeed => 'ইতিমধ্যে সবচেয়ে ধীর গতিতে আছে।';

  @override
  String get libraryScreenFastestSpeed => 'ইতিমধ্যে সবচেয়ে দ্রুত গতিতে আছে।';

  @override
  String get libraryScreenSpeedFailed =>
      'চালানোর গতি বদলানো যায়নি। আবার চেষ্টা করুন।';

  @override
  String get libraryScreenReadFileFailed => 'ফাইলের ডেটা পড়া যায়নি।';

  @override
  String get libraryScreenTitleFieldPlain => 'অডিওর শিরোনাম';

  @override
  String get libraryScreenChooseSessionsName => 'এই অডিওর জন্য সেশন বেছে নিন';

  @override
  String get libraryScreenConfirmSessionsKey => 'বেছে নেওয়া সেশন নিশ্চিত করুন';

  @override
  String libraryScreenSessionNumber(String id) {
    return 'সেশন $id';
  }

  @override
  String libraryScreenSessionSelected(String name) {
    return '$name, বেছে নেওয়া হয়েছে';
  }

  @override
  String libraryScreenSessionNotSelected(String name) {
    return '$name, বেছে নেওয়া হয়নি';
  }

  @override
  String libraryScreenConfirmSelectedSessions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'বেছে নেওয়া $countটি সেশন নিশ্চিত করুন',
    );
    return '$_temp0';
  }

  @override
  String get libraryScreenUploadCancelledNoSession =>
      'আপলোড বাতিল হয়েছে। অন্তত একটি সেশন বেছে নিন, তারপর আবার অডিও যোগ করতে 3 টিপুন।';

  @override
  String libraryScreenUploadingWait(String title) {
    return '$title আপলোড হচ্ছে। অনুগ্রহ করে অপেক্ষা করুন; শেষ হলে আপনি শুনতে পাবেন।';
  }

  @override
  String get libraryScreenClassSubjectUnknown =>
      'সেশনের ক্লাস ও বিষয় নির্ধারণ করা যায়নি';

  @override
  String libraryScreenUploadFailedRetry(String title) {
    return '$title আপলোড করা যায়নি। আপনার সংযোগ দেখুন, তারপর আবার চেষ্টা করতে 3 টিপুন।';
  }

  @override
  String get libraryScreenAudioFallback => 'অডিও';

  @override
  String get libraryScreenClassLibraryName => 'ক্লাসের অডিও লাইব্রেরি';

  @override
  String get libraryScreenClassLibrarySections =>
      'চালানোর নিয়ন্ত্রণ, বুকমার্ক ও শেখার অগ্রগতি, বিষয় ফিল্টার, ডাউনলোড, রেকর্ডিং, এবং থাকলে শিক্ষকের আপলোডের সরঞ্জাম';

  @override
  String get libraryScreenSubjectFilterField => 'বিষয় ফিল্টার (কী 2)';

  @override
  String get libraryScreenAllSubjects => 'সব বিষয়';

  @override
  String get libraryScreenAddAudioOptionsName => 'অডিও যোগ করার বিকল্প';

  @override
  String get libraryScreenCloseAddAudioTarget =>
      'অডিও যোগ করার বিকল্প বন্ধ করুন';

  @override
  String get libraryScreenUploadNewTarget => 'নতুন ফাইল আপলোড করুন, কী 1';

  @override
  String get libraryScreenSelectExistingTarget =>
      'আগের লাইব্রেরি থেকে বেছে নিন, কী 2';

  @override
  String libraryScreenRecordingsAvailable(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি রেকর্ডিং পাওয়া যাচ্ছে।',
    );
    return '$_temp0';
  }

  @override
  String libraryScreenNoRecordingsMatch(String query) {
    return '$query এর সাথে কোনো রেকর্ডিং মেলেনি।';
  }

  @override
  String libraryScreenRecordingsMatch(int count, String query) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$query এর সাথে $countটি রেকর্ডিং মিলেছে।',
    );
    return '$_temp0';
  }

  @override
  String get libraryScreenNoUnlinkedRecordings =>
      'এই ক্লাসের জন্য যুক্ত না করা কোনো রেকর্ডিং নেই।';

  @override
  String libraryScreenRecordingsAvailableChoose(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$countটি রেকর্ডিং পাওয়া যাচ্ছে। বেছে নিতে উপরে ও নিচে ব্যবহার করুন, অথবা শিরোনাম দিয়ে খুঁজুন।',
    );
    return '$_temp0';
  }

  @override
  String libraryScreenAddFailed(String title) {
    return '$title যোগ করা যায়নি। আপনার সংযোগ দেখে আবার চেষ্টা করুন।';
  }

  @override
  String get libraryScreenSelectExistingName => 'আগের অডিও বেছে নিন';

  @override
  String get libraryScreenSelectExistingSections =>
      'খোঁজা এবং পাওয়া যায় এমন প্রতিটি রেকর্ডিং';

  @override
  String get libraryScreenRefreshAvailableTarget =>
      'পাওয়া যায় এমন অডিও রিফ্রেশ করুন, কী 1';

  @override
  String get libraryScreenSearchRecordingsField =>
      'শিরোনাম দিয়ে রেকর্ডিং খুঁজুন। লিখতে ওকে টিপুন';

  @override
  String libraryScreenSearchRecordingsWithQuery(String query, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'রেকর্ডিং খুঁজুন, $query। $countটি মিলেছে',
    );
    return '$_temp0';
  }

  @override
  String libraryScreenAddToSessionTarget(String title) {
    return 'এই সেশনে $title যোগ করুন';
  }

  @override
  String get libraryScreenRepeatHelpTarget =>
      'অডিও লাইব্রেরির সাহায্য আবার শুনুন';

  @override
  String get playlistBack => 'পেছনে';

  @override
  String get playlistCancel => 'বাতিল';

  @override
  String get playlistCreate => 'তৈরি করুন';

  @override
  String get playlistRefresh => 'রিফ্রেশ';

  @override
  String playlistTeacherNone(String className, String subject) {
    return '$className, $subject এর জন্য এখনও কোনো প্লেলিস্ট নেই। একটি তৈরি করতে 2 টিপুন।';
  }

  @override
  String playlistTeacherLoaded(int count, String className, String subject) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি প্লেলিস্ট',
    );
    return '$className, $subject এর জন্য $_temp0 লোড হয়েছে';
  }

  @override
  String get playlistCreateClassTitle => 'ক্লাসের প্লেলিস্ট তৈরি করুন';

  @override
  String get playlistTitleField => 'প্লেলিস্টের শিরোনাম';

  @override
  String get playlistCancelCreation => 'প্লেলিস্ট তৈরি বাতিল করুন';

  @override
  String get playlistCreatePlaylist => 'প্লেলিস্ট তৈরি করুন';

  @override
  String get playlistCreatePlaylistKey => 'প্লেলিস্ট তৈরি';

  @override
  String get playlistRefreshPlaylists => 'প্লেলিস্ট রিফ্রেশ করুন';

  @override
  String playlistTeacherItemLabel(String title, String status, String count) {
    return '$title। $status। $countটি আইটেম';
  }

  @override
  String playlistTeacherScreen(String className, String subject) {
    return 'ক্লাসের প্লেলিস্ট, $className, $subject';
  }

  @override
  String get playlistStatusArchived => 'আর্কাইভ করা';

  @override
  String get playlistStatusPublished => 'প্রকাশিত';

  @override
  String get playlistStatusDraft => 'খসড়া';

  @override
  String get playlistStudentNone =>
      'এখনও কোনো প্লেলিস্ট নেই। একটি ব্যক্তিগত প্লেলিস্ট তৈরি করতে 2 টিপুন।';

  @override
  String playlistStudentLoaded(int privateCount, int classCount) {
    String _temp0 = intl.Intl.pluralLogic(
      privateCount,
      locale: localeName,
      other: '$privateCountটি ব্যক্তিগত প্লেলিস্ট',
    );
    String _temp1 = intl.Intl.pluralLogic(
      classCount,
      locale: localeName,
      other: '$classCountটি ক্লাসের প্লেলিস্ট',
    );
    return '$_temp0 এবং $_temp1 লোড হয়েছে';
  }

  @override
  String get playlistCreatePrivate => 'ব্যক্তিগত প্লেলিস্ট তৈরি করুন';

  @override
  String get playlistCreatePrivateKey => 'ব্যক্তিগত প্লেলিস্ট তৈরি';

  @override
  String playlistPrivateItemLabel(String title, String count) {
    return '$title, ব্যক্তিগত, $countটি আইটেম';
  }

  @override
  String playlistClassItemLabel(String title, String subject, String count) {
    return '$title, ক্লাসের প্লেলিস্ট, $subject, $countটি আইটেম';
  }

  @override
  String get playlistStudentScreen =>
      'আমার প্লেলিস্ট। ব্যক্তিগত প্লেলিস্ট শুধু আপনিই দেখতে পান।';

  @override
  String get playlistWaitBeforeNotes =>
      'পড়ার নোট খোলার আগে প্লেলিস্ট প্লেয়ারের জন্য অপেক্ষা করুন।';

  @override
  String get playlistRefreshFailed =>
      'এই প্লেলিস্টটি রিফ্রেশ করা যায়নি। আপনার সংযোগ দেখে আবার চেষ্টা করুন। চলমান প্লেব্যাক ও সেভ করা অগ্রগতি বদলানো হয়নি।';

  @override
  String get playlistLessonGone =>
      'বর্তমান পাঠটি এই প্লেলিস্টে আর পাওয়া যাচ্ছে না। চালানো বন্ধ হয়েছে। আপনার সেভ করা অগ্রগতি ও বুকমার্ক রাখা আছে।';

  @override
  String get playlistStateArchived => 'আর্কাইভ করা';

  @override
  String get playlistStatePublished => 'প্রকাশিত';

  @override
  String get playlistStateDraft => 'খসড়া';

  @override
  String get playlistStatePrivate => 'ব্যক্তিগত';

  @override
  String get playlistStatePublishedClass => 'প্রকাশিত ক্লাসের প্লেলিস্ট';

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
      other: '$countটি আইটেম',
    );
    return '$title। $className $subject। $_temp0। $state।';
  }

  @override
  String get playlistAddAudioScreen => 'প্লেলিস্টে অডিও যোগ করুন';

  @override
  String playlistItemNoLongerAvailable(String title) {
    return '$title আপনার বর্তমান ক্লাসে আর পাওয়া যাচ্ছে না। আপনি এটি এই প্লেলিস্ট থেকে সরিয়ে দিতে পারেন।';
  }

  @override
  String playlistItemPosition(String index, String total) {
    return '$totalটির মধ্যে $index নম্বর আইটেম।';
  }

  @override
  String get playlistPlayFailed =>
      'এই পাঠটি চালানো যায়নি। আপনার সংযোগ দেখে আবার চেষ্টা করুন।';

  @override
  String playlistPausedAt(String position) {
    return '$position এ থামানো হয়েছে।';
  }

  @override
  String get playlistLessonDefault => 'পাঠ';

  @override
  String get playlistSave => 'সেভ করুন';

  @override
  String get playlistRenameScreen => 'প্লেলিস্টের নাম বদলান';

  @override
  String get playlistCancelRename => 'নাম বদলানো বাতিল করুন';

  @override
  String get playlistSaveTitle => 'প্লেলিস্টের শিরোনাম সেভ করুন';

  @override
  String get playlistAlreadyFirst =>
      'বেছে নেওয়া আইটেমটি আগে থেকেই প্রথমে আছে।';

  @override
  String get playlistAlreadyLast => 'বেছে নেওয়া আইটেমটি আগে থেকেই শেষে আছে।';

  @override
  String playlistMoveFailed(String title) {
    return '$title সরানো গেল না। আপনার সংযোগ দেখে আবার চেষ্টা করুন।';
  }

  @override
  String get playlistThisPlaylist => 'এই প্লেলিস্ট';

  @override
  String playlistRemoveItemTitle(String title) {
    return '$title সরাবেন?';
  }

  @override
  String playlistRemoveItemMessage(String title, String playlist) {
    return '$playlist থেকে $title সরাবেন? রেকর্ডিংটি লাইব্রেরিতে রাখা থাকবে।';
  }

  @override
  String playlistKeepItem(String title) {
    return '$title রাখুন';
  }

  @override
  String playlistRemoveItem(String title) {
    return '$title সরান';
  }

  @override
  String playlistRemoveFailed(String title) {
    return '$title সরানো গেল না। আপনার সংযোগ দেখে আবার চেষ্টা করুন।';
  }

  @override
  String playlistPublishedToClass(String title) {
    return '$title ক্লাসে প্রকাশিত হয়েছে';
  }

  @override
  String playlistReturnedToDraft(String title) {
    return '$title খসড়ায় ফেরানো হয়েছে';
  }

  @override
  String playlistChangeFailed(String title) {
    return '$title বদলানো গেল না। আপনার সংযোগ দেখে আবার চেষ্টা করুন।';
  }

  @override
  String playlistDeleteTitle(String title) {
    return '$title মুছবেন?';
  }

  @override
  String playlistRestoreTitle(String title) {
    return '$title ফিরিয়ে আনবেন?';
  }

  @override
  String playlistArchiveTitle(String title) {
    return '$title আর্কাইভ করবেন?';
  }

  @override
  String playlistDeleteMessage(String title) {
    return 'এটি ব্যক্তিগত প্লেলিস্ট $title এবং তার সাজানো আইটেমগুলি সরিয়ে দেবে। রেকর্ডিংগুলি লাইব্রেরিতে থেকে যাবে।';
  }

  @override
  String playlistRestoreMessage(String title) {
    return 'এটি $title-কে খসড়ায় ফিরিয়ে দেবে, যাতে আবার সম্পাদনা ও প্রকাশ করা যায়।';
  }

  @override
  String playlistArchiveMessage(String title) {
    return 'শিক্ষার্থীরা আর $title দেখতে পাবে না। শিক্ষকের ইতিহাস রাখা থাকবে।';
  }

  @override
  String playlistDeleteConfirm(String title) {
    return '$title মুছুন';
  }

  @override
  String playlistRestoreConfirm(String title) {
    return '$title ফিরিয়ে আনুন';
  }

  @override
  String playlistArchiveConfirm(String title) {
    return '$title আর্কাইভ করুন';
  }

  @override
  String playlistDeleted(String title) {
    return '$title মোছা হয়েছে';
  }

  @override
  String playlistRestoredDraft(String title) {
    return '$title খসড়া হিসেবে ফিরিয়ে আনা হয়েছে';
  }

  @override
  String playlistArchived(String title) {
    return '$title আর্কাইভ করা হয়েছে';
  }

  @override
  String get playlistSelectedItem => 'বেছে নেওয়া আইটেম';

  @override
  String get playlistSeekFailed =>
      'পাঠের ওই অবস্থানে যাওয়া গেল না। আবার চেষ্টা করুন।';

  @override
  String get playlistRefreshPlaylist => 'প্লেলিস্ট রিফ্রেশ করুন';

  @override
  String get playlistWordPlaylist => 'প্লেলিস্ট';

  @override
  String playlistRenameLabel(String title) {
    return '$title-এর নাম বদলান';
  }

  @override
  String get playlistAddAudioLabel => 'অডিও যোগ করুন, কী 2';

  @override
  String playlistPauseLabel(String title, String key) {
    return '$title থামান, কী $key';
  }

  @override
  String playlistPlayLabel(String title, String key) {
    return '$title চালান, কী $key';
  }

  @override
  String get playlistPreviousLabel => 'আগের আইটেম, কী 3';

  @override
  String get playlistNextLabel => 'পরের আইটেম, কী 8';

  @override
  String playlistReturnToDraftLabel(String title) {
    return '$title খসড়ায় ফেরান';
  }

  @override
  String playlistPublishLabel(String title) {
    return '$title ক্লাসে প্রকাশ করুন';
  }

  @override
  String playlistRestoreLabel(String title) {
    return '$title ফিরিয়ে আনুন';
  }

  @override
  String playlistArchiveLabel(String title) {
    return '$title আর্কাইভ করুন, নিশ্চিত করতে বলবে';
  }

  @override
  String playlistDeleteLabel(String title) {
    return '$title মুছুন, নিশ্চিত করতে বলবে';
  }

  @override
  String playlistSeekLabel(String position) {
    return 'পাঠের অবস্থান $position। 10 সেকেন্ড সরাতে বাঁ বা ডান ব্যবহার করুন';
  }

  @override
  String get playlistDownloadsLabel =>
      'প্লেলিস্টের রেকর্ডিং ডাউনলোড করুন। আলাদা করে বেছে নিন বা তালিকার সব রেকর্ডিং নিশ্চিত করুন';

  @override
  String playlistMoveUpLabel(String title) {
    return '$title উপরে সরান';
  }

  @override
  String playlistMoveDownLabel(String title) {
    return '$title নিচে সরান';
  }

  @override
  String playlistRemoveItemLabel(String title) {
    return 'প্লেলিস্ট থেকে $title সরান, নিশ্চিত করতে বলবে';
  }

  @override
  String get playlistItemUnavailableInClass =>
      'আপনার বর্তমান ক্লাসে পাওয়া যাচ্ছে না';

  @override
  String get playlistItemSelected => 'বেছে নেওয়া হয়েছে';

  @override
  String get playlistItemPlaying => 'চলছে';

  @override
  String get playlistItemSelectedPaused => 'বেছে নেওয়া হয়েছে, থামানো আছে';

  @override
  String get playlistAddAudioKey => 'অডিও যোগ';

  @override
  String get playlistPreviousItem => 'আগের আইটেম';

  @override
  String get playlistNextItem => 'পরের আইটেম';

  @override
  String get playlistScreenDefault => 'প্লেলিস্ট';

  @override
  String playlistScreen(String title) {
    return '$title প্লেলিস্ট';
  }

  @override
  String playlistItemUnavailable(String title) {
    return '$title আপনার বর্তমান ক্লাসে পাওয়া যাচ্ছে না';
  }

  @override
  String get notesNoRecordingActive => 'কোনো রেকর্ডিং চালু নেই।';

  @override
  String get notesMicCouldNotRecord =>
      'মাইক্রোফোন এই নোটটি রেকর্ড করতে পারেনি।';

  @override
  String get notesRecordingNotConfirmed =>
      'রেকর্ডিং নিশ্চিত করা যায়নি। এর আংশিক ফাইলগুলি রাখা আছে। মাইক্রোফোনের অনুমতি আর স্টোরেজ দেখুন।';

  @override
  String get notesLeaveLiveSession =>
      'রেকর্ড করার আগে লাইভ সেশন ছেড়ে ব্যক্তিগত নোট খুলুন।';

  @override
  String get notesMicPermissionDenied =>
      'মাইক্রোফোনের অনুমতি দেওয়া হয়নি। কোনো রেকর্ডিং শুরু হয়নি। Android সেটিংসে এটি চালু করে আবার চেষ্টা করুন।';

  @override
  String get notesRecordingCancelledChanged =>
      'স্ক্রিন বা অ্যাপ বদলে যাওয়ায় রেকর্ডিং বাতিল হয়েছে। তৈরি হলে আবার শুরু করুন।';

  @override
  String get notesSpeechDidNotStop =>
      'অ্যাপের কণ্ঠস্বর থামেনি। রেকর্ড করার আগে TTS ইঞ্জিন দেখুন।';

  @override
  String get notesRecordingDidNotStart =>
      'অ্যাপ বদলে যাওয়ায় রেকর্ডিং শুরু হয়নি। এর খালি খসড়াটি বেছে সরানোর জন্য রাখা আছে।';

  @override
  String get notesAnotherRecorderStopping =>
      'আরেকটি ব্যক্তিগত রেকর্ডার এখনও থামছে। রেকর্ড করার আগে সেখানে ফিরে যান বা অ্যাপটি ব্যাকগ্রাউন্ডে পাঠান।';

  @override
  String get notesNativeStartNotConfirmed =>
      'ফোনের রেকর্ডার শুরু হওয়া নিশ্চিত করেনি। খসড়াটি রাখা আছে।';

  @override
  String get notesNativeStopNotConfirmed =>
      'ফোনের রেকর্ডিং থামা নিশ্চিত হয়নি। আবার চেষ্টা করার আগে রেকর্ডিং থামাতে অ্যাপটি ব্যাকগ্রাউন্ডে পাঠান।';

  @override
  String get notesDurationUnreadable =>
      'রেকর্ডারের সময়দৈর্ঘ্য পড়া যায়নি। এর অসম্পূর্ণ ফাইলটি রাখা আছে।';

  @override
  String get notesRecordingInProgress =>
      'রেকর্ডিং চলছে। অ্যাপের নিয়ন্ত্রণে কথা বলার আগে থামান। সর্বোচ্চ পাঁচ মিনিট; অ্যাপ কথা বললে বা বাধা পেলে থেমে যাবে।';

  @override
  String get notesNativeCaptureStopped =>
      'ফোনের রেকর্ডিং থেমে গেছে। কোনো অসম্পূর্ণ খসড়া বেছে সরানোর জন্য রাখা আছে।';

  @override
  String get notesRecorderStopNotConfirmed =>
      'রেকর্ডার থামা নিশ্চিত হয়নি। আবার চেষ্টা করার আগে রেকর্ডিং থামাতে এই স্ক্রিন ছেড়ে যান বা অ্যাপটি ব্যাকগ্রাউন্ডে পাঠান।';

  @override
  String get notesRecorderFailed =>
      'রেকর্ডার ব্যর্থ হয়েছে। এর অসম্পূর্ণ ফাইলটি বেছে সরানোর জন্য রাখা আছে।';

  @override
  String get notesNotFinalized =>
      'রেকর্ডিং থেমেছে, কিন্তু নোটটি সম্পূর্ণ করা যায়নি। ফাইলগুলি বেছে সরানোর জন্য রাখা আছে।';

  @override
  String get notesRecordingLimitReached => 'রেকর্ডিংয়ের সীমা পূর্ণ হয়েছে।';

  @override
  String get notesRecordingInterrupted => 'রেকর্ডিং বাধা পেয়েছে।';

  @override
  String get notesRecordingStopped => 'রেকর্ডিং থেমেছে।';

  @override
  String get notesSavedOnPhone =>
      'ব্যক্তিগত নোট এই ফোনে সেভ হয়েছে। প্রকাশ বা শেয়ার করার আগে দেখে নিন।';

  @override
  String get notesSignInFirst => 'ব্যক্তিগত নোট খোলার আগে সাইন ইন করুন।';

  @override
  String get notesInvalidIdentity => 'নোটের পরিচয় সঠিক নয়।';

  @override
  String get notesAccountChanged =>
      'আপনার অ্যাকাউন্ট বদলেছে। ব্যক্তিগত নোট আবার খুলুন।';

  @override
  String get notesStorageUnavailable =>
      'ব্যক্তিগত নোটের স্টোরেজ পাওয়া যাচ্ছে না। খালি জায়গা দেখে আবার চেষ্টা করুন। আগের ফাইলগুলি রাখা আছে।';

  @override
  String get notesInvalidNameOrPosition =>
      'সর্বোচ্চ 160 অক্ষরের একটি নোটের নাম এবং পাঠের একটি সঠিক অবস্থান দিন।';

  @override
  String get notesAllowanceFull =>
      'আপনার ব্যক্তিগত নোটের জায়গা ভরে গেছে। রেকর্ড করার আগে একটি বেছে নেওয়া নোট সরান। কোনো নোট মোছা হয়নি।';

  @override
  String get notesInterruptedOrInvalid =>
      'নোটটি বাধা পেয়েছে বা এর সময়দৈর্ঘ্য সঠিক নয়। এর ফাইলগুলি বেছে সরানোর জন্য রাখা আছে।';

  @override
  String get notesEmptyOrTooLarge =>
      'এই রেকর্ডিংটি খালি বা ব্যক্তিগত নোটের সীমার চেয়ে বড়। এর আংশিক ফাইলটি রাখা আছে; স্টোরেজ দেখে বেছে নেওয়া রেকর্ডিংটি সরান।';

  @override
  String get notesIncompleteUnavailable =>
      'এই নোটটি অসম্পূর্ণ বা পাওয়া যাচ্ছে না। এটি মোছা হয়নি।';

  @override
  String get notesInvalidName => 'সর্বোচ্চ 160 অক্ষরের একটি নোটের নাম দিন।';

  @override
  String notesUnreadableTitle(String id) {
    return 'পড়া যায় না এমন নোট $id';
  }

  @override
  String get notesRecordUnreadable =>
      'এই নোটের রেকর্ড পড়া যাচ্ছে না। এর ফাইলগুলি রাখা আছে; শুধু আপনি নিজে বেছে সরালে এগুলি বদলাবে।';

  @override
  String notesInterruptedTitle(String id) {
    return 'বাধা পাওয়া রেকর্ডিং $id';
  }

  @override
  String get notesMetadataMissing =>
      'রেকর্ডিংয়ের তথ্য পাওয়া যাচ্ছে না। ফাইলটি বেছে সরানোর জন্য রাখা আছে।';

  @override
  String get learningSavedLessonInvalid =>
      'সেভ করা পাঠের তথ্য সঠিক নয়। আপনার সেভ করা ডেটা বদলানো হয়নি।';

  @override
  String get learningSavedBookmarkUnreadable =>
      'একটি সেভ করা বুকমার্ক পড়া যায়নি। আপনার সেভ করা ডেটা বদলানো হয়নি।';

  @override
  String get learningSavedBookmarkIdsInvalid =>
      'সেভ করা বুকমার্কের পরিচয় সঠিক নয়। আপনার সেভ করা ডেটা বদলানো হয়নি।';

  @override
  String get learningSavedRepeatInvalid =>
      'সেভ করা রিপিটের সীমা সঠিক নয়। আপনার সেভ করা ডেটা বদলানো হয়নি।';

  @override
  String get learningSignInFirst =>
      'সেভ করা শেখার অগ্রগতি ব্যবহারের আগে সাইন ইন করুন।';

  @override
  String get learningAccountChanged =>
      'আপনার অ্যাকাউন্ট বদলেছে। শেখার লাইব্রেরি আবার খুলুন।';

  @override
  String get learningUnsupportedFormat =>
      'সেভ করা শেখার ডেটার ফরম্যাট বা অ্যাকাউন্ট সমর্থিত নয়। আপনার সেভ করা ডেটা বদলানো হয়নি।';

  @override
  String get learningIdentityMismatch =>
      'সেভ করা পাঠের পরিচয় মিলছে না। আপনার সেভ করা ডেটা বদলানো হয়নি।';

  @override
  String get learningDataUnreadable =>
      'সেভ করা শেখার ডেটা পড়া যায়নি। আপনার সেভ করা ডেটা বদলানো হয়নি।';

  @override
  String get learningStorageUnavailableFreeSpace =>
      'শেখার স্টোরেজ পাওয়া যাচ্ছে না। খালি জায়গা দেখে আবার চেষ্টা করুন। আপনার সেভ করা ডেটা ইচ্ছাকৃতভাবে সরানো হয়নি।';

  @override
  String get learningStorageUnavailable =>
      'শেখার স্টোরেজ পাওয়া যাচ্ছে না। স্টোরেজ দেখে আবার চেষ্টা করুন।';

  @override
  String get learningSaveFailed =>
      'শেখার অগ্রগতি সেভ করা যায়নি। খালি জায়গা দেখে আবার চেষ্টা করুন।';

  @override
  String get learningProgressUnavailable =>
      'সেভ করা শেখার অগ্রগতি পাওয়া যাচ্ছে না। স্টোরেজ দেখে আবার চেষ্টা করুন।';

  @override
  String get learningStartLessonFirst =>
      'বুকমার্ক বা রিপিট পয়েন্ট যোগ করার আগে এই পাঠটি শুরু করুন।';

  @override
  String learningSavedFieldUnreadable(String field) {
    return 'সেভ করা $field পড়া যায়নি। আপনার সেভ করা ডেটা বদলানো হয়নি।';
  }

  @override
  String get learningFieldBookmarkId => 'বুকমার্কের আইডি';

  @override
  String get learningFieldBookmarkLabel => 'বুকমার্কের নাম';

  @override
  String get learningFieldBookmarkPosition => 'বুকমার্কের অবস্থান';

  @override
  String get learningFieldUpdateTime => 'আপডেটের সময়';

  @override
  String get learningFieldNextBookmarkId => 'পরের বুকমার্কের আইডি';

  @override
  String get learningFieldLessonId => 'পাঠের আইডি';

  @override
  String get learningFieldLessonTitle => 'পাঠের শিরোনাম';

  @override
  String get learningFieldPosition => 'অবস্থান';

  @override
  String get learningInvalidProgress => 'পাঠের অগ্রগতি সঠিক নয়';

  @override
  String get learningBookmarkNeedsPositionLabel =>
      'বুকমার্কের জন্য একটি সঠিক অবস্থান ও নাম দরকার';

  @override
  String get learningBookmarkExceedsDuration =>
      'বুকমার্কের অবস্থান পাঠের সময়দৈর্ঘ্যের বেশি';

  @override
  String learningDefaultBookmarkLabel(String number) {
    return 'বুকমার্ক $number';
  }

  @override
  String get learningBookmarkNotFound => 'বুকমার্ক পাওয়া যায়নি';

  @override
  String get learningRepeatEndAfterStart =>
      'শেষ পয়েন্টটি শুরুর পয়েন্টের পরে রাখুন';

  @override
  String get learningRepeatExceedsDuration =>
      'রিপিট পয়েন্টগুলি পাঠের সময়দৈর্ঘ্যের বেশি';

  @override
  String get learningSavedProgressUnavailableTitle =>
      'সেভ করা অগ্রগতি পাওয়া যাচ্ছে না';

  @override
  String get learningListenWithoutSavedPrompt =>
      'সেভ করা ডেটা না বদলে শুরু থেকে শুনবেন? সফলভাবে আবার চেষ্টা না করা পর্যন্ত সেভ করা বন্ধ থাকবে।';

  @override
  String get learningListenFromBeginning => 'শুরু থেকে শুনুন';

  @override
  String get learningRecordedLesson => 'রেকর্ড করা পাঠ';

  @override
  String learningStatusPosition(String position) {
    return 'অবস্থান $position।';
  }

  @override
  String learningSpeedTimes(String speed) {
    return 'গতি $speed গুণ।';
  }

  @override
  String learningStatusBookmarks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি বুকমার্ক',
    );
    return '$_temp0';
  }

  @override
  String learningStatusRepeat(String state) {
    return 'A-B রিপিট $state।';
  }

  @override
  String learningStatusSaving(String state) {
    return 'অগ্রগতি সেভ করা $state।';
  }

  @override
  String get learningNoLessonLoaded =>
      'কোনো পাঠ লোড করা নেই। আগে চালানোর জন্য একটি পাঠ বেছে নিন।';

  @override
  String get learningSlowestSpeed => 'আগে থেকেই সবচেয়ে ধীর গতিতে আছে।';

  @override
  String get learningFastestSpeed => 'আগে থেকেই সবচেয়ে দ্রুত গতিতে আছে।';

  @override
  String get learningCheckPosition => 'পাঠের অবস্থান দেখে আবার চেষ্টা করুন।';

  @override
  String get learningPlayerActionFailed =>
      'প্লেয়ার এই কাজটি শেষ করতে পারেনি। প্লেব্যাক দেখে আবার চেষ্টা করুন।';

  @override
  String learningBookmarkSavedAt(String time) {
    return '$time-এ বুকমার্ক সেভ হয়েছে।';
  }

  @override
  String learningReadStatusLabel(String status) {
    return 'শেখার অবস্থা শুনুন। $status';
  }

  @override
  String learningAddBookmarkAt(String time) {
    return '$time-এ বুকমার্ক যোগ করুন';
  }

  @override
  String learningBookmarksSavedPoints(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'বুকমার্ক। $countটি সেভ করা পয়েন্ট',
    );
    return '$_temp0';
  }

  @override
  String learningPrivateNotesAt(String time) {
    return '$time-এ ব্যক্তিগত পড়ার নোট। খোলার আগে পাঠ থামান';
  }

  @override
  String get learningSetRepeatStartLabel =>
      'বর্তমান অবস্থানে রিপিটের শুরু A ঠিক করুন';

  @override
  String learningRepeatStartSet(String time) {
    return '$time-এ রিপিটের শুরু ঠিক করা হয়েছে।';
  }

  @override
  String get learningSetRepeatEndLabel =>
      'শুরু A-এর পরে রিপিটের শেষ B ঠিক করুন';

  @override
  String learningRepeatEndSet(String time) {
    return '$time-এ রিপিটের শেষ ঠিক করা হয়েছে। বারবার চালাতে রিপিট চালু বেছে নিন।';
  }

  @override
  String get learningTurnRepeatOff => 'A-B রিপিট বন্ধ করুন';

  @override
  String get learningTurnRepeatOn => 'A-B রিপিট চালু করুন';

  @override
  String get learningClearRepeatLabel => 'সেভ করা A-B রিপিট পয়েন্ট মুছুন';

  @override
  String get learningRepeatCleared => 'A-B রিপিট পয়েন্ট মোছা হয়েছে।';

  @override
  String learningBackTenLabel(String key) {
    return '10 সেকেন্ড পিছনে, কী $key';
  }

  @override
  String learningForwardTenLabel(String key) {
    return '10 সেকেন্ড সামনে, কী $key';
  }

  @override
  String learningSlowerLabel(String key, String speed) {
    return 'ধীরে, কী $key। এখন $speed গুণ';
  }

  @override
  String learningFasterLabel(String key, String speed) {
    return 'দ্রুত, কী $key। এখন $speed গুণ';
  }

  @override
  String learningRetrySavingLabel(String issue) {
    return 'শেখার অগ্রগতি আবার সেভ করার চেষ্টা করুন। $issue';
  }

  @override
  String get learningProgressSaved => 'শেখার অগ্রগতি সেভ হয়েছে।';

  @override
  String get learningEnterBookmarkName => 'একটি বুকমার্কের নাম লিখুন।';

  @override
  String get learningNameBookmarkScreen =>
      'বুকমার্কের নাম দিন। সম্পাদনা করতে ওকে টিপুন। উপর বা নিচ টিপলে সম্পাদনা থেকে বেরিয়ে আসবেন।';

  @override
  String get learningEditName => 'নাম সম্পাদনা';

  @override
  String get learningSaveBookmark => 'বুকমার্ক সেভ করুন';

  @override
  String get learningBookmarkNameField => 'বুকমার্কের নাম';

  @override
  String learningBookmarkJumped(String label, String position) {
    return '$label। অবস্থান $position।';
  }

  @override
  String get learningRemoveBookmarkTitle => 'বুকমার্ক সরাবেন?';

  @override
  String learningRemoveBookmarkMessage(String label) {
    return '$label সরাবেন? এতে পাঠ বা অন্য কোনো বুকমার্ক সরবে না।';
  }

  @override
  String get learningKeepBookmark => 'বুকমার্ক রাখুন';

  @override
  String get learningRemoveBookmark => 'বুকমার্ক সরান';

  @override
  String learningBookmarkRemoved(String label) {
    return '$label সরানো হয়েছে।';
  }

  @override
  String get learningBookmarksScreen =>
      'বুকমার্ক। যেতে একটি পয়েন্ট বেছে নিন। এতে থামানো প্লেব্যাক শুরু হবে না। সরানোর আগে নিশ্চিত করতে বলা হবে।';

  @override
  String get learningCloseBookmarks => 'বুকমার্ক বন্ধ করুন';

  @override
  String learningJumpToBookmarkLabel(String label, String time) {
    return '$label। $time। বুকমার্কে যান';
  }

  @override
  String learningRemoveBookmarkLabel(String label) {
    return '$label সরান';
  }

  @override
  String get dashboardRefreshing => 'সেশনগুলি রিফ্রেশ হচ্ছে।';

  @override
  String get dashboardShowMatching => 'মিলে যাওয়া সেশন দেখান';

  @override
  String get dashboardLogout => 'লগ আউট, নিশ্চিত করতে বলবে';

  @override
  String get dashboardRefresh => 'সেশনগুলি রিফ্রেশ করুন';

  @override
  String get dashboardLibraryWhat => 'রেকর্ড করা অডিও লাইব্রেরি';

  @override
  String get dashboardQuizzesWhat => 'কুইজ';

  @override
  String dashboardSessions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি সেশন',
      one: '1টি সেশন',
    );
    return '$_temp0';
  }

  @override
  String dashboardPosition(String index, String total) {
    return '$total-এর মধ্যে $index';
  }

  @override
  String get dashboardStudentScreen => 'শিক্ষার্থী ড্যাশবোর্ড';

  @override
  String get dashboardStudentLoading => 'শিক্ষার্থী ড্যাশবোর্ড লোড হচ্ছে';

  @override
  String get dashboardStudentSections =>
      'রিফ্রেশ, সেশন খোঁজা, লাইভ সেশন, রেকর্ড করা পাঠ, প্লেলিস্ট, কুইজ, শেখার যাত্রা, এবং লগ আউট';

  @override
  String get dashboardNoLiveSessions =>
      'এখন কোনো লাইভ সেশন নেই। রিফ্রেশ করতে 1 টিপুন।';

  @override
  String get dashboardNoFilterMatch => 'আপনার ফিল্টারের সাথে কোনো সেশন মেলেনি।';

  @override
  String get dashboardNoMatchVisible =>
      'মেলে এমন কোনো সেশন নেই। খোঁজা মুছে দিন বা বিষয় ফিল্টার বদলান।';

  @override
  String dashboardAvailable(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি সেশন আছে।',
      one: '1টি সেশন আছে।',
    );
    return '$_temp0';
  }

  @override
  String dashboardAvailableDetailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি সেশন আছে। দেখতে নিচে যান।',
      one: '1টি সেশন আছে। দেখতে নিচে যান।',
    );
    return '$_temp0';
  }

  @override
  String dashboardRefreshFailed(String reason) {
    return '$reason আবার চেষ্টা করতে 1 টিপুন।';
  }

  @override
  String get dashboardJoining => 'সেশনে যোগ দেওয়া হচ্ছে।';

  @override
  String dashboardJoined(String session) {
    return '$session-এ যোগ দিয়েছেন।';
  }

  @override
  String get dashboardOpeningPlaylists =>
      'আমার প্লেলিস্ট খোলা হচ্ছে। এই প্লেলিস্টগুলি ব্যক্তিগত।';

  @override
  String get dashboardSessionSearchHelp =>
      'সেশন খোঁজা। সেশন নম্বর লিখতে ওকে টিপুন, তারপর নিচে গিয়ে মেলে এমন সেশন দেখান-এ ওকে টিপুন। আপনি নাম দিয়েও খুঁজতে পারেন।';

  @override
  String get dashboardSessionNumberFieldEmpty =>
      'সেশন নম্বরের ঘর। একটি নম্বর লিখুন, তারপর মেলে এমন সেশন দেখান বেছে নিন';

  @override
  String dashboardSessionNumberField(String digits) {
    return 'সেশন নম্বরের ঘর, $digits';
  }

  @override
  String get dashboardNameField => 'নাম দিয়ে সেশন খুঁজুন';

  @override
  String dashboardNoSessionNumber(String digits) {
    return '$digits নম্বরের কোনো লাইভ সেশন নেই।';
  }

  @override
  String dashboardFound(String label) {
    return 'পাওয়া গেছে: $label। যোগ দিতে ওকে টিপুন।';
  }

  @override
  String dashboardNoNameMatch(String query) {
    return '$query-এর সাথে কোনো সেশন মেলেনি।';
  }

  @override
  String dashboardShowingAll(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'সব $countটি সেশন দেখানো হচ্ছে।',
      one: 'সব মিলিয়ে 1টি সেশন দেখানো হচ্ছে।',
    );
    return '$_temp0';
  }

  @override
  String dashboardShowingAllDetailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'সব $countটি সেশন দেখানো হচ্ছে। দেখতে নিচে যান।',
      one: 'সব মিলিয়ে 1টি সেশন দেখানো হচ্ছে। দেখতে নিচে যান।',
    );
    return '$_temp0';
  }

  @override
  String dashboardNameMatches(int count, String query) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$query-এর সাথে $countটি সেশন মিলেছে। দেখতে নিচে যান।',
      one: '$query-এর সাথে 1টি সেশন মিলেছে। দেখতে নিচে যান।',
    );
    return '$_temp0';
  }

  @override
  String get dashboardAllSubjects => 'সব বিষয়';

  @override
  String dashboardSubjectFilterLabel(String subject, String position) {
    return 'বিষয় ফিল্টার: $subject, $position। বদলাতে বাঁয়ে বা ডানে যান';
  }

  @override
  String dashboardSubjectFilterChanged(
    String subject,
    String position,
    String summary,
  ) {
    return 'বিষয় ফিল্টার: $subject, $position। $summary';
  }

  @override
  String get dashboardLibrary => 'রেকর্ড করা অডিও লাইব্রেরি';

  @override
  String get dashboardPlaylists => 'আমার ব্যক্তিগত প্লেলিস্ট';

  @override
  String get dashboardQuizzes => 'কুইজ';

  @override
  String get dashboardStudentJourneys =>
      'শেখার যাত্রা: শুনুন, উত্তর দিন ও আবার শুনুন, অফলাইনেও চলে';

  @override
  String dashboardTeacherName(String name) {
    return 'শিক্ষক $name';
  }

  @override
  String get dashboardLiveNow => 'এখন লাইভ';

  @override
  String get dashboardStateRefreshing => 'রিফ্রেশ হচ্ছে।';

  @override
  String dashboardStateLiveSessions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি লাইভ সেশন।',
      one: '1টি লাইভ সেশন।',
    );
    return '$_temp0';
  }

  @override
  String dashboardStateSubjectFilter(String subject) {
    return 'বিষয় ফিল্টার: $subject।';
  }

  @override
  String dashboardStateSessionNumber(String digits) {
    return 'লেখা সেশন নম্বর: $digits।';
  }

  @override
  String dashboardStateNameSearch(String query) {
    return 'নাম দিয়ে খোঁজা: $query।';
  }

  @override
  String dashboardStateShown(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি সেশন দেখানো হচ্ছে।',
      one: '1টি সেশন দেখানো হচ্ছে।',
    );
    return '$_temp0';
  }

  @override
  String get dashboardTeacherScreen => 'শিক্ষকের ড্যাশবোর্ড';

  @override
  String get dashboardTeacherLoading => 'শিক্ষকের ড্যাশবোর্ড লোড হচ্ছে';

  @override
  String get dashboardTeacherSections =>
      'ক্লাস ও বিষয় বাছাই, পড়ানোর সরঞ্জাম, সেশন খোঁজা, এবং চালু বা শেষ হওয়া সেশন';

  @override
  String get dashboardNoSessionsYet =>
      'এখনও কোনো সেশন নেই। একটি তৈরি করতে 2 টিপুন।';

  @override
  String get dashboardNoTeacherMatch =>
      'মেলে এমন কোনো সেশন নেই। সব সেশন দেখতে খোঁজা মুছে দিন।';

  @override
  String dashboardTeacherCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি সেশন।',
      one: '1টি সেশন।',
    );
    return '$_temp0';
  }

  @override
  String dashboardTeacherCountLive(int count, String live) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি সেশন, এখন $liveটি লাইভ।',
      one: '1টি সেশন, এখন $liveটি লাইভ।',
    );
    return '$_temp0';
  }

  @override
  String dashboardNotRefreshed(String reason) {
    return '$reason সেশনগুলি রিফ্রেশ হয়নি। আবার চেষ্টা করতে 1 টিপুন।';
  }

  @override
  String get dashboardNoAssignment =>
      'আপনাকে কোনো ক্লাস ও বিষয় দেওয়া হয়নি। একটি দিতে প্রশাসককে বলুন।';

  @override
  String get dashboardCreatingSession => 'সেশন তৈরি হচ্ছে';

  @override
  String dashboardCreated(String title) {
    return '$title সেশন তৈরি হয়েছে।';
  }

  @override
  String get dashboardCreatedTitle => 'সেশন তৈরি হয়েছে';

  @override
  String dashboardStartNow(String title) {
    return 'আপনি কি \"$title\" এখনই শুরু করতে চান?';
  }

  @override
  String get dashboardRequestFailed =>
      'অনুরোধটি পূরণ করা গেল না। আপনার সংযোগ দেখে আবার চেষ্টা করুন।';

  @override
  String get dashboardOpeningSession => 'সেশন খোলা হচ্ছে।';

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
    return 'ওয়ার্কস্পেস: $name, $position। $status';
  }

  @override
  String dashboardWorkspaceChosen(String name, String status) {
    return '$name বাছাই করা হয়েছে। $status অন্য ওয়ার্কস্পেস বাছতে 7 টিপুন।';
  }

  @override
  String get dashboardChooseWorkspaceTitle => 'ক্লাস ও বিষয় বাছুন';

  @override
  String get dashboardNoWorkspace =>
      'কোনো ক্লাস ও বিষয়ের ওয়ার্কস্পেস দেওয়া হয়নি';

  @override
  String dashboardWorkspaceLabel(String name, String position) {
    return 'ওয়ার্কস্পেস: $name, $position। বদলাতে বাঁয়ে বা ডানে যান, নম্বরসহ তালিকার জন্য ওকে বা 7 টিপুন';
  }

  @override
  String get dashboardCreate => 'নতুন সেশন তৈরি করুন';

  @override
  String get dashboardClassPlaylists => 'ক্লাসের প্লেলিস্ট';

  @override
  String get dashboardTeacherJourneys =>
      'শেখার যাত্রা: রেকর্ডিং, প্রশ্ন ও পোল একসাথে';

  @override
  String get dashboardTeacherQuizzes => 'কুইজ ও ব্যক্তিগত প্রশ্ন ব্যাংক';

  @override
  String get dashboardOfflineLibrary => 'অফলাইন অডিও লাইব্রেরি';

  @override
  String get dashboardSearchField =>
      'সেশন খুঁজুন। ওকে টিপুন, তারপর একটি নাম বা সেশন নম্বর লিখুন';

  @override
  String get dashboardTeacherSearchHelp =>
      'সেশন খোঁজা। লিখতে ওকে টিপুন, তারপর সেশনের নাম লিখুন, বা নম্বর কী দিয়ে সেশন নম্বর লিখুন। ঘর থেকে বেরিয়ে ফলাফল দেখতে উপরে বা নিচে যান।';

  @override
  String dashboardTeacherNoMatch(String query) {
    return '$query-এর সাথে কোনো সেশন মেলেনি। সব সেশন দেখতে খোঁজা মুছে দিন।';
  }

  @override
  String get dashboardEnded => 'শেষ হয়েছে';

  @override
  String dashboardJoinedCount(String count) {
    return '$count জন যোগ দিয়েছে';
  }

  @override
  String get dashboardPressOkToOpen => 'খুলতে ওকে টিপুন';

  @override
  String get dashboardPressOkToReactivate => 'আবার চালু করতে ওকে টিপুন';

  @override
  String dashboardEndLabel(String title) {
    return 'সবার জন্য $title শেষ করুন, নিশ্চিত করতে বলবে';
  }

  @override
  String dashboardDeleteLabel(String title) {
    return 'শেষ হওয়া সেশন $title চিরতরে মুছুন, নিশ্চিত করতে বলবে';
  }

  @override
  String get dashboardEndTitle => 'সবার জন্য সেশন শেষ করবেন?';

  @override
  String dashboardEndMessage(String title) {
    return '\"$title\" শেষ করে সব অংশগ্রহণকারীর জন্য বন্ধ করবেন? সেশনটি আপনার ড্যাশবোর্ডের ইতিহাসে থেকে যাবে।';
  }

  @override
  String get dashboardEndedForEveryone =>
      'সবার জন্য সেশন শেষ হয়েছে এবং সেশনের ইতিহাসে রাখা হয়েছে।';

  @override
  String get dashboardEndFailed => 'সেশনটি শেষ করা গেল না। আবার চেষ্টা করুন।';

  @override
  String get dashboardReactivateTitle => 'সেশন আবার চালু করবেন?';

  @override
  String dashboardReactivateMessage(String title) {
    return '\"$title\" আবার চালু করবেন, যাতে অংশগ্রহণকারীরা আবার যোগ দিতে পারে?';
  }

  @override
  String get dashboardReactivated => 'সেশন আবার চালু হয়েছে।';

  @override
  String get dashboardReactivateFailed =>
      'সেশনটি আবার চালু করা গেল না। আবার চেষ্টা করুন।';

  @override
  String get dashboardOpenNowTitle => 'এখনই সেশন খুলবেন?';

  @override
  String dashboardOpenNowMessage(String title) {
    return '\"$title\" আবার চালু হয়েছে। এখনই খুলুন, বা পরে ড্যাশবোর্ড থেকে ফিরে আসুন।';
  }

  @override
  String get dashboardDeleteTitle => 'সেশন চিরতরে মুছবেন?';

  @override
  String dashboardDeleteMessage(String title) {
    return '\"$title\" এবং এর অংশগ্রহণকারী, চ্যাট ও লগ সহ চিরতরে মুছবেন? এটি আর ফেরানো যাবে না।';
  }

  @override
  String get dashboardDeleted => 'সেশন চিরতরে মুছে ফেলা হয়েছে।';

  @override
  String get dashboardDeleteFailed => 'সেশনটি মোছা গেল না। আবার চেষ্টা করুন।';

  @override
  String get dashboardStateNoWorkspace => 'কোনো ওয়ার্কস্পেস বাছা হয়নি।';

  @override
  String dashboardStateWorkspace(String name) {
    return 'ওয়ার্কস্পেস: $name।';
  }

  @override
  String dashboardActiveSessions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি চালু সেশন',
      one: '1টি চালু সেশন',
    );
    return '$_temp0';
  }

  @override
  String dashboardStateTotals(String active, String total) {
    return '$active, মোট $totalটি।';
  }

  @override
  String dashboardStateSearch(String query) {
    return 'খোঁজা: $query।';
  }

  @override
  String get adminSaveFailed =>
      'পরিবর্তনটি সেভ করা যায়নি। রিফ্রেশ করতে 1 টিপুন, তারপর আবার চেষ্টা করুন।';

  @override
  String adminChoiceLabel(String what, String name, String position) {
    return '$what: $name, $position। বদলাতে বাঁ বা ডান ব্যবহার করুন';
  }

  @override
  String adminChoiceLabelSingle(String what, String name) {
    return '$what: $name। বদলাতে বাঁ বা ডান ব্যবহার করুন';
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
    return '$className বেছে নেওয়া হয়েছে। $subject বিষয় বেছে নেওয়া হয়েছে।';
  }

  @override
  String get adminNoSubjects => 'বেছে নেওয়া ক্লাসে কোনো সক্রিয় বিষয় নেই।';

  @override
  String adminStateSection(String section) {
    return 'বিভাগ: $section।';
  }

  @override
  String adminStateShown(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি আইটেম দেখানো হচ্ছে।',
      one: '1টি আইটেম দেখানো হচ্ছে।',
    );
    return '$_temp0';
  }

  @override
  String adminStateFilter(String filter) {
    return 'ফিল্টার: $filter।';
  }

  @override
  String adminStateSearch(String query) {
    return 'খোঁজ: $query।';
  }

  @override
  String get adminNoSubjectName =>
      'কোনো বিষয়ের নাম লেখা হয়নি। কিছুই তৈরি হয়নি।';

  @override
  String get adminNoClassName =>
      'কোনো ক্লাসের নাম লেখা হয়নি। কিছুই তৈরি হয়নি।';

  @override
  String get adminNoActiveSubjects => 'এই ক্লাসে কোনো সক্রিয় বিষয় নেই।';

  @override
  String get adminListReadFailed => 'প্রশাসনের তালিকা পড়া যায়নি।';

  @override
  String adminNotRefreshed(String reason) {
    return '$reason প্রশাসনের ডেটা রিফ্রেশ হয়নি। আবার চেষ্টা করতে 1 টিপুন।';
  }

  @override
  String adminExploreIntro(String sections) {
    return '$sections ঘুরে দেখতে D-pad-এর উপর ও নিচ ব্যবহার করুন। বেছে নিতে ওকে টিপুন।';
  }

  @override
  String adminSectionTitle(String section) {
    return 'প্রশাসন। $section বিভাগ';
  }

  @override
  String get adminSectionNameAccounts => 'অ্যাকাউন্ট';

  @override
  String get adminSectionNameClasses => 'ক্লাস';

  @override
  String get adminSectionNameSubjects => 'বিষয়';

  @override
  String get adminNoMatchingAccounts =>
      'মিলে যাওয়া কোনো অ্যাকাউন্ট নেই। খোঁজ বা ফিল্টার বদলান।';

  @override
  String adminNoMatchingAccountsFor(String search) {
    return '$search-এর সঙ্গে মিলে যাওয়া কোনো অ্যাকাউন্ট নেই। খোঁজ বা ফিল্টার বদলান।';
  }

  @override
  String adminClasses(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি ক্লাস',
      one: '1টি ক্লাস',
    );
    return '$_temp0';
  }

  @override
  String adminSubjects(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি বিষয়',
      one: '1টি বিষয়',
    );
    return '$_temp0';
  }

  @override
  String adminAccountsSummary(int count, String classes, String subjects) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি অ্যাকাউন্ট। $classes এবং $subjects।',
      one: '1টি অ্যাকাউন্ট। $classes এবং $subjects।',
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
          '$countটি অ্যাকাউন্ট $search-এর সঙ্গে মেলে। $classes এবং $subjects।',
      one: '1টি অ্যাকাউন্ট $search-এর সঙ্গে মেলে। $classes এবং $subjects।',
    );
    return '$_temp0';
  }

  @override
  String adminClassesSentence(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি ক্লাস।',
      one: '1টি ক্লাস।',
    );
    return '$_temp0';
  }

  @override
  String adminSubjectsSentence(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি বিষয়।',
      one: '1টি বিষয়।',
    );
    return '$_temp0';
  }

  @override
  String get adminNavigationAccounts =>
      'অ্যাকাউন্ট খোঁজা, অ্যাকাউন্টের ধরন ও ভর্তির ফিল্টার, এবং অ্যাকাউন্ট পরিচালনা। কোনো ফিল্টার বদলাতে তার উপর বাঁ বা ডান ব্যবহার করুন';

  @override
  String get adminNavigationClasses =>
      'ক্লাস তৈরি এবং সক্রিয় বা আর্কাইভ করা ক্লাসের তালিকা। বিষয় বরাদ্দ এবং আর্কাইভ বা ফিরিয়ে আনার কাজের জন্য কোনো ক্লাসে ওকে টিপুন';

  @override
  String get adminNavigationSubjects =>
      'বিষয় তৈরি এবং সক্রিয় বা আর্কাইভ করা বিষয়ের তালিকা। কোনো বিষয় আর্কাইভ করতে বা ফিরিয়ে আনতে তার উপর ওকে টিপুন';

  @override
  String get adminSectionsTitle => 'প্রশাসনের বিভাগগুলি';

  @override
  String get adminSectionAccounts => 'অ্যাকাউন্ট ও ভর্তি';

  @override
  String get adminSectionClasses => 'ক্লাস ও তাদের বিষয়';

  @override
  String get adminSectionSubjects => 'বিষয়';

  @override
  String adminSectionChosen(String section) {
    return '$section বিভাগ।';
  }

  @override
  String adminSectionExplore(String what) {
    return '$what ঘুরে দেখতে D-pad ব্যবহার করুন। বিভাগ বদলাতে 7 টিপুন।';
  }

  @override
  String get adminExploreAccounts =>
      'অ্যাকাউন্টের ফিল্টার, খোঁজা ও অ্যাকাউন্ট পরিচালনা';

  @override
  String get adminExploreClasses =>
      'ক্লাস তৈরি, বিষয় বরাদ্দ, এবং আর্কাইভ বা ফিরিয়ে আনার কাজ';

  @override
  String get adminExploreSubjects =>
      'বিষয় তৈরি এবং আর্কাইভ বা ফিরিয়ে আনার কাজ';

  @override
  String adminRoleFilterSelected(String label) {
    return 'অ্যাকাউন্টের ধরন ফিল্টার: $label, বেছে নেওয়া হয়েছে।';
  }

  @override
  String adminAssignmentFilterSelected(String label) {
    return 'বরাদ্দ ফিল্টার: $label, বেছে নেওয়া হয়েছে।';
  }

  @override
  String get adminRoleFilterStudents => 'শুধু শিক্ষার্থী';

  @override
  String get adminRoleFilterTeachers => 'শুধু শিক্ষক';

  @override
  String get adminRoleFilterAll => 'সব নিবন্ধিত অ্যাকাউন্ট';

  @override
  String get adminAssignmentEnrolled => 'ভর্তি হয়েছে';

  @override
  String get adminAssignmentAssigned => 'নির্ধারিত';

  @override
  String get adminAssignmentEnrolledOrAssigned => 'ভর্তি বা নির্ধারিত';

  @override
  String get adminAssignmentUnassigned => 'নির্ধারিত নয়';

  @override
  String get adminAssignmentAll => 'সব নির্ধারণের অবস্থা';

  @override
  String get adminRoleStudent => 'শিক্ষার্থী';

  @override
  String get adminRoleTeacher => 'শিক্ষক';

  @override
  String get adminNoClassAssigned => 'কোনো ক্লাস নির্ধারিত নেই';

  @override
  String adminAssignmentCount(String count) {
    return '$countটি নির্ধারণ';
  }

  @override
  String adminAccountLabel(String name, String role, String access) {
    return '$name, $role। $access। পরিচালনা করতে ওকে টিপুন';
  }

  @override
  String get adminCancel => 'বাতিল';

  @override
  String get adminSave => 'সংরক্ষণ করুন';

  @override
  String get adminCreateSubjectTitle => 'বিষয় তৈরি করুন';

  @override
  String get adminSubjectNameField => 'বিষয়ের নাম';

  @override
  String adminSubjectCreated(String name) {
    return '$name বিষয় তৈরি হয়েছে';
  }

  @override
  String get adminCreateClassTitle => 'ক্লাস তৈরি করুন';

  @override
  String get adminClassNameField => 'ক্লাসের নাম';

  @override
  String adminClassCreated(String name) {
    return '$name ক্লাস তৈরি হয়েছে';
  }

  @override
  String get adminArchiveClassTitle => 'ক্লাস আর্কাইভ করবেন?';

  @override
  String get adminRestoreClassTitle => 'ক্লাস ফিরিয়ে আনবেন?';

  @override
  String adminArchiveItemMessage(String name) {
    return '$name আর্কাইভ করা থাকলে নতুন সেশন, অডিও এবং নির্ধারণে এটি ব্যবহার করা যাবে না।';
  }

  @override
  String adminRestoreItemMessage(String name) {
    return '$name আবার নির্ধারণের জন্য পাওয়া যাবে।';
  }

  @override
  String get adminArchive => 'আর্কাইভ করুন';

  @override
  String get adminRestore => 'ফিরিয়ে আনুন';

  @override
  String get adminClassArchived => 'ক্লাস আর্কাইভ করা হয়েছে';

  @override
  String get adminClassRestored => 'ক্লাস ফিরিয়ে আনা হয়েছে';

  @override
  String adminManageTitle(String name) {
    return '$name পরিচালনা করুন';
  }

  @override
  String get adminManageClassSubjects => 'ক্লাসের বিষয় পরিচালনা করুন';

  @override
  String get adminArchiveClassChoice => 'নিশ্চিত করে ক্লাস আর্কাইভ করুন';

  @override
  String get adminRestoreClassChoice => 'নিশ্চিত করে ক্লাস ফিরিয়ে আনুন';

  @override
  String adminSubjectsForClass(String name) {
    return '$name-এর বিষয়';
  }

  @override
  String adminSubjectRemovedFrom(String name) {
    return '$name থেকে বিষয় সরানো হয়েছে';
  }

  @override
  String adminSubjectAddedTo(String name) {
    return '$name-এ বিষয় যোগ করা হয়েছে';
  }

  @override
  String get adminArchiveSubjectTitle => 'বিষয় আর্কাইভ করবেন?';

  @override
  String get adminRestoreSubjectTitle => 'বিষয় ফিরিয়ে আনবেন?';

  @override
  String get adminSubjectArchived => 'বিষয় আর্কাইভ করা হয়েছে';

  @override
  String get adminSubjectRestored => 'বিষয় ফিরিয়ে আনা হয়েছে';

  @override
  String get adminManageAssignments => 'নির্ধারণ পরিচালনা করুন';

  @override
  String get adminPasswordRecovery => 'পাসওয়ার্ড পুনরুদ্ধার';

  @override
  String adminManageUserScreen(String name) {
    return '$name পরিচালনা করুন। নির্ধারণ, পাসওয়ার্ড পুনরুদ্ধার, বা বাতিল বেছে নিন।';
  }

  @override
  String get adminRecoveryNeedsVersion =>
      'অ্যাকাউন্ট পুনরুদ্ধারের জন্য সার্ভারের বর্তমান সংস্করণ দরকার। অ্যাকাউন্টটি রিফ্রেশ করুন।';

  @override
  String get adminNoActiveClasses =>
      'কোনো সক্রিয় ক্লাস নেই। আগে ক্লাস বিভাগে একটি ক্লাস তৈরি করুন বা ফিরিয়ে আনুন।';

  @override
  String get adminTheCurrentClass => 'বর্তমান ক্লাস';

  @override
  String adminAssignClassTo(String name) {
    return '$name-কে ক্লাস নির্ধারণ করুন';
  }

  @override
  String get adminAssign => 'নির্ধারণ করুন';

  @override
  String get adminRemoveClass => 'ক্লাস সরান';

  @override
  String get adminClassField => 'ক্লাস';

  @override
  String adminRemoveStudentLabel(String name, String className) {
    return '$className থেকে $name-কে সরান, নিশ্চিত করতে বলবে';
  }

  @override
  String adminAssignStudentLabel(String name) {
    return 'বেছে নেওয়া ক্লাসে $name-কে নির্ধারণ করুন';
  }

  @override
  String get adminRemoveFromClassTitle => 'ক্লাস থেকে সরাবেন?';

  @override
  String adminRemoveFromClassMessage(String name, String className) {
    return '$className থেকে $name-কে সরাবেন? আবার নির্ধারণ না করা পর্যন্ত তিনি ওই ক্লাস আর দেখতে পাবেন না।';
  }

  @override
  String get adminKeepInClass => 'ক্লাসে রাখুন';

  @override
  String get adminRemoveFromClass => 'ক্লাস থেকে সরান';

  @override
  String adminStudentRemovedFromClass(String name) {
    return '$name-কে ক্লাস থেকে সরানো হয়েছে';
  }

  @override
  String adminStudentAssignedTo(String name, String className) {
    return '$name-কে $className-এ নির্ধারণ করা হয়েছে';
  }

  @override
  String adminAssignTeacherScreen(String name) {
    return '$name-কে একটি ক্লাস ও বিষয়ে নির্ধারণ করুন';
  }

  @override
  String adminRemoveAssignmentLabel(
    String name,
    String className,
    String subject,
  ) {
    return '$className, $subject থেকে $name-কে সরান, নিশ্চিত করতে বলবে';
  }

  @override
  String get adminSubjectField => 'বিষয়';

  @override
  String get adminSaveAssignment => 'নির্ধারণ সংরক্ষণ করুন';

  @override
  String get adminTeacherAssignmentSaved => 'শিক্ষকের নির্ধারণ সংরক্ষিত হয়েছে';

  @override
  String get adminRemoveAssignmentTitle => 'নির্ধারণ সরাবেন?';

  @override
  String adminRemoveAssignmentMessage(
    String name,
    String className,
    String subject,
  ) {
    return '$className, $subject থেকে $name-কে সরাবেন?';
  }

  @override
  String get adminKeep => 'রাখুন';

  @override
  String get adminRemove => 'সরান';

  @override
  String get adminTeacherAssignmentRemoved => 'শিক্ষকের নির্ধারণ সরানো হয়েছে';

  @override
  String get adminRefreshData => 'প্রশাসকের তথ্য রিফ্রেশ করুন';

  @override
  String get adminLogout => 'লগ আউট, নিশ্চিত করতে বলবে';

  @override
  String adminSectionButton(String section) {
    return '$section বিভাগ। প্রশাসনের বিভাগ বদলান';
  }

  @override
  String get adminSearchAccounts =>
      'নাম বা ফোন নম্বর দিয়ে অ্যাকাউন্ট খুঁজুন। লিখতে ওকে টিপুন';

  @override
  String adminRoleFilterLabel(String label) {
    return 'অ্যাকাউন্টের ধরন ফিল্টার: $label, বেছে নেওয়া হয়েছে। বদলাতে বাঁ বা ডান ব্যবহার করুন';
  }

  @override
  String adminAssignmentFilterLabel(String label) {
    return 'নির্ধারণ ফিল্টার: $label, বেছে নেওয়া হয়েছে। বদলাতে বাঁ বা ডান ব্যবহার করুন';
  }

  @override
  String adminClassActiveLabel(String name) {
    return '$name, সক্রিয়। ক্লাসের বিষয় এবং আর্কাইভ বা ফিরিয়ে আনার জন্য ওকে টিপুন';
  }

  @override
  String adminClassArchivedLabel(String name) {
    return '$name, আর্কাইভ করা। ক্লাসের বিষয় এবং আর্কাইভ বা ফিরিয়ে আনার জন্য ওকে টিপুন';
  }

  @override
  String adminSubjectActiveLabel(String name) {
    return '$name, সক্রিয়। আর্কাইভ করতে ওকে টিপুন';
  }

  @override
  String adminSubjectArchivedLabel(String name) {
    return '$name, আর্কাইভ করা। ফিরিয়ে আনতে ওকে টিপুন';
  }

  @override
  String adminSubjectInClass(String name) {
    return '$name। এই ক্লাসে আছে। সরাতে বেছে নিন';
  }

  @override
  String adminSubjectNotInClass(String name) {
    return '$name। এই ক্লাসে নেই। যোগ করতে বেছে নিন';
  }

  @override
  String get teacherHomeLater => 'পরে';

  @override
  String get teacherHomeStartNow => 'এখনই শুরু করুন';

  @override
  String get teacherHomeChooseWorkspaceTitle => 'ক্লাস ও বিষয় বাছুন';

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
    return '$className, $subjectName বাছাই করা হয়েছে। $status। অন্য ওয়ার্কস্পেস বাছতে 7 টিপুন।';
  }

  @override
  String get teacherHomeUntitledSession => 'নামহীন সেশন';

  @override
  String get teacherHomeUntitledSessionTitle => 'নামহীন সেশন';

  @override
  String get teacherHomeSessionFallback => 'সেশন';

  @override
  String get teacherHomeSearchLabel =>
      'সেশন খুঁজুন। ওকে টিপুন, তারপর একটি নাম বা সেশন নম্বর লিখুন';

  @override
  String get teacherHomeKeepSessionOpen => 'সেশন খোলা রাখুন';

  @override
  String get teacherHomeEndForEveryone => 'সবার জন্য শেষ করুন';

  @override
  String get teacherHomeKeepEnded => 'শেষই রাখুন';

  @override
  String get teacherHomeReactivate => 'আবার চালু করুন';

  @override
  String get teacherHomeOpenLater => 'পরে খুলুন';

  @override
  String get teacherHomeOpenNow => 'এখনই খুলুন';

  @override
  String get teacherHomeKeepSession => 'সেশন রাখুন';

  @override
  String get teacherHomeDeletePermanently => 'চিরতরে মুছুন';

  @override
  String get teacherHomeNewSessionTitle => 'নতুন সেশন';

  @override
  String get teacherHomeCreateScreen => 'নতুন সেশন তৈরি করুন';

  @override
  String get teacherHomeCreateSessionKey => 'সেশন তৈরি করুন';

  @override
  String get teacherHomeTitleField => 'সেশনের শিরোনামের ঘর';

  @override
  String get teacherHomeCancelCreate => 'সেশন তৈরি বাতিল করুন';

  @override
  String get studentHomeSearchHelp =>
      'সেশন খোঁজা। কীপ্যাড দিয়ে সেশন নম্বর লিখুন, বা নাম দিয়ে খুঁজতে নিচে যান। লিখতে ওকে টিপুন। ফলাফল দেখতে নিচে যান।';

  @override
  String studentHomeSubjectFallback(String id) {
    return 'বিষয় $id';
  }

  @override
  String get studentHomeUntitledSession => 'নামহীন সেশন';

  @override
  String studentHomeSessionJoinLabel(String session) {
    return '$session। যোগ দিতে ওকে টিপুন';
  }

  @override
  String get inviteNoStudentsEnrolled =>
      'এই ক্লাসে কোনো শিক্ষার্থী ভর্তি নেই। রিফ্রেশ করতে 1 টিপুন।';

  @override
  String inviteLoadedSummary(int count, String invited) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count জন শিক্ষার্থী, $invited জন আমন্ত্রিত।',
      one: '1 জন শিক্ষার্থী, $invited জন আমন্ত্রিত।',
    );
    return '$_temp0';
  }

  @override
  String get inviteUseSearch => 'নাম খুঁজতে সার্চ ঘর ব্যবহার করুন।';

  @override
  String get inviteLoadFailed =>
      'শিক্ষার্থীদের লোড করা যায়নি। আপনার সংযোগ দেখুন এবং আবার চেষ্টা করতে 1 টিপুন।';

  @override
  String inviteAlreadyInvited(String name) {
    return '$name আগেই আমন্ত্রিত।';
  }

  @override
  String inviteInvitedOne(String name) {
    return '$name-কে আমন্ত্রণ জানানো হয়েছে।';
  }

  @override
  String inviteOneFailed(String name) {
    return '$name-কে আমন্ত্রণ জানানো যায়নি। আপনার সংযোগ দেখুন এবং আবার চেষ্টা করতে ওকে টিপুন।';
  }

  @override
  String get inviteNoStudentsToInvite =>
      'আমন্ত্রণ জানানোর মতো কোনো শিক্ষার্থী নেই।';

  @override
  String get inviteAllAlreadyInvited => 'সব শিক্ষার্থী আগেই আমন্ত্রিত।';

  @override
  String inviteInvitingAll(String count) {
    return '$count জন শিক্ষার্থীকে আমন্ত্রণ জানানো হচ্ছে। অনুগ্রহ করে অপেক্ষা করুন।';
  }

  @override
  String inviteProgress(String done, String total) {
    return 'শিক্ষার্থীদের আমন্ত্রণ জানানো হচ্ছে: $total-এর মধ্যে $done হয়েছে।';
  }

  @override
  String inviteAllDone(String count) {
    return 'সব $count জন শিক্ষার্থীকে আমন্ত্রণ জানানো হয়েছে।';
  }

  @override
  String invitePartialFailed(String invited, String total, String names) {
    return '$total জনের মধ্যে $invited জন শিক্ষার্থীকে আমন্ত্রণ জানানো হয়েছে। $names-কে আমন্ত্রণ জানানো যায়নি। আবার চেষ্টা করতে 2 টিপুন।';
  }

  @override
  String inviteShowingAll(String count) {
    return 'সব $count জন শিক্ষার্থী দেখানো হচ্ছে।';
  }

  @override
  String inviteNoMatch(String query) {
    return '$query-এর সঙ্গে কোনো শিক্ষার্থী মেলেনি। সবাইকে দেখতে সার্চ মুছে দিন।';
  }

  @override
  String inviteMatches(int count, String query) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count জন শিক্ষার্থী $query-এর সঙ্গে মিলেছে। দেখতে নিচে যান।',
      one: '1 জন শিক্ষার্থী $query-এর সঙ্গে মিলেছে। দেখতে নিচে যান।',
    );
    return '$_temp0';
  }

  @override
  String inviteStudentInvited(String name) {
    return '$name, আমন্ত্রিত';
  }

  @override
  String inviteStudentNotInvited(String name) {
    return '$name, আমন্ত্রিত নয়। আমন্ত্রণ জানাতে ওকে টিপুন';
  }

  @override
  String get inviteBackToSession => 'সেশনে ফিরে যান';

  @override
  String get inviteRefreshList => 'শিক্ষার্থীদের তালিকা রিফ্রেশ করুন';

  @override
  String get inviteAllStudents => 'সব শিক্ষার্থীকে আমন্ত্রণ জানান';

  @override
  String get inviteSearchLabel =>
      'নাম বা ফোন নম্বর দিয়ে শিক্ষার্থী খুঁজুন। লিখতে ওকে টিপুন';

  @override
  String inviteScreenName(String title) {
    return '$title-এ শিক্ষার্থীদের আমন্ত্রণ জানান';
  }

  @override
  String get inviteKeyBack => 'সেশনে ফিরে যান';

  @override
  String get inviteKeyRefresh => 'শিক্ষার্থী রিফ্রেশ করুন';

  @override
  String get inviteKeyInviteAll => 'সবাইকে আমন্ত্রণ';

  @override
  String get notificationTitleSessionInvitation => 'লাইভ ক্লাস';

  @override
  String get notificationTitleJourneyPublished => 'নতুন শেখার যাত্রা';

  @override
  String get notificationTitleQuizPublished => 'নতুন কুইজ';

  @override
  String get notificationTitleQuizReminder => 'কুইজের রিমাইন্ডার';

  @override
  String get notificationTitleDefault => 'SEEDS আপডেট';

  @override
  String get notificationArrivedSessionInvitation =>
      'আপনার শিক্ষক একটি ক্লাস শুরু করেছেন। যোগ দিতে 1 টিপুন, বা এখন না চাইলে 0 টিপুন।';

  @override
  String get notificationArrivedJourneyPublished =>
      'আপনার শিক্ষক একটি নতুন শেখার যাত্রা শেয়ার করেছেন। খুলতে 1 টিপুন, বা এখন না চাইলে 0 টিপুন।';

  @override
  String get notificationArrivedQuizPublished =>
      'আপনার শিক্ষক একটি নতুন কুইজ প্রকাশ করেছেন। আপনার কুইজ খুলতে 1 টিপুন, বা এখন না চাইলে 0 টিপুন।';

  @override
  String get notificationArrivedQuizReminder =>
      'রিমাইন্ডার: আপনার একটি কুইজ দেওয়া বাকি। আপনার কুইজ খুলতে 1 টিপুন, বা এখন না চাইলে 0 টিপুন।';

  @override
  String get notificationArrivedDefault =>
      'আপনার একটি নতুন আপডেট আছে। ফিরে যেতে 0 টিপুন।';

  @override
  String get notificationForegroundSessionInvitation =>
      'আপনার শিক্ষক একটি ক্লাস শুরু করেছেন। আপনার ড্যাশবোর্ডের লাইভ সেশন থেকে যোগ দিন।';

  @override
  String get notificationForegroundJourneyPublished =>
      'আপনার শিক্ষক একটি নতুন শেখার যাত্রা শেয়ার করেছেন। শেখার যাত্রা-তে খুঁজে পাবেন।';

  @override
  String get notificationForegroundQuizPublished =>
      'আপনার শিক্ষক একটি নতুন কুইজ প্রকাশ করেছেন।';

  @override
  String get notificationForegroundQuizReminder =>
      'রিমাইন্ডার: আপনার একটি কুইজ দেওয়া বাকি।';

  @override
  String get notificationForegroundDefault => 'আপনার একটি নতুন আপডেট আছে।';

  @override
  String get notificationOpenJoinClass => 'ক্লাসে যোগ দিন';

  @override
  String get notificationOpenJourney => 'যাত্রা খুলুন';

  @override
  String get notificationOpenQuizzes => 'কুইজ খুলুন';

  @override
  String get notificationOpenBack => 'ফিরে যান';

  @override
  String get notificationCannotOpen =>
      'এটি খোলা গেল না। আবার সাইন ইন করুন, তারপর আপনার ড্যাশবোর্ড থেকে খুলুন।';

  @override
  String get authLoginSuccessful => 'সাইন ইন সফল হয়েছে';

  @override
  String authRoleAlreadySelected(String role) {
    return '$role অ্যাকাউন্ট আগেই বেছে নেওয়া আছে';
  }

  @override
  String authRoleSelected(String role) {
    return '$role অ্যাকাউন্ট বেছে নেওয়া হয়েছে';
  }

  @override
  String authRecoveryStep(String number, String step) {
    return 'ধাপ $number। $step';
  }

  @override
  String get authEnterPhone => 'ফোন নম্বর লিখুন';

  @override
  String get authEnterPassword => 'পাসওয়ার্ড লিখুন';

  @override
  String get authEnterName => 'নাম লিখুন';

  @override
  String get authRegistering => 'নিবন্ধন হচ্ছে, অনুগ্রহ করে অপেক্ষা করুন।';

  @override
  String get authPasswordChanged => 'পাসওয়ার্ড বদলানো হয়েছে। সাইন ইন হয়েছে।';

  @override
  String journeyWhereFinished(String title) {
    return 'যাত্রা শেষ। $title।';
  }

  @override
  String journeyWhere(String number, String total, String kind, String title) {
    return '$total-এর মধ্যে ধাপ $number। $kind। $title।';
  }

  @override
  String journeyWhereReplaying(
    String number,
    String total,
    String kind,
    String title,
  ) {
    return '$total-এর মধ্যে ধাপ $number। $kind। $title। প্রশ্নের আগে আবার শোনা হচ্ছে।';
  }

  @override
  String get journeyKindRecording => 'রেকর্ডিং';

  @override
  String get journeyKindNarration => 'বর্ণনা';

  @override
  String get journeyKindQuestion => 'প্রশ্ন';

  @override
  String get journeyKindPoll => 'পোল';

  @override
  String journeyOption(String number, String text) {
    return 'বিকল্প $number: $text।';
  }

  @override
  String journeyChooseKeys(String count) {
    return 'বেছে নিতে 1 থেকে $count টিপুন, তারপর জমা দিতে 5 টিপুন।';
  }

  @override
  String journeyPollQuestion(String question, String options, String keys) {
    return 'পোল। এখানে কোনো ভুল উত্তর নেই। $question $options $keys';
  }

  @override
  String journeyQuestion(String question, String options, String keys) {
    return 'প্রশ্ন। $question $options $keys';
  }

  @override
  String journeyQuestionTryAgain(
    String triesLeft,
    String question,
    String options,
    String keys,
  ) {
    return 'প্রশ্ন। আবার চেষ্টা করুন। $triesLeft $question $options $keys';
  }

  @override
  String journeyTriesLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'আর $count বার চেষ্টা বাকি।',
      one: 'আর 1 বার চেষ্টা বাকি।',
    );
    return '$_temp0';
  }

  @override
  String journeyChosen(String number, String option) {
    return 'বিকল্প $number, $option, বেছে নেওয়া হয়েছে। জমা দিতে 5 টিপুন, বা অন্য নম্বর বেছে নিন।';
  }

  @override
  String journeyRecordingContent(String title) {
    return 'রেকর্ডিং: $title। থামাতে বা চালাতে 5 টিপুন। এগিয়ে যেতে প্রস্তুত হলে 2 টিপুন।';
  }

  @override
  String get journeyUntitled => 'শিরোনামহীন';

  @override
  String get journeyContentKeys =>
      'পরের ধাপের জন্য 2, এই ধাপ আবার শুনতে 3, আপনি কোথায় আছেন শুনতে 1, আগের রেকর্ডিং বা বর্ণনায় ফিরতে 8 টিপুন।';

  @override
  String journeyCorrect(String answer) {
    return 'সঠিক! $answer।';
  }

  @override
  String get journeyPollSaved => 'ধন্যবাদ। আপনার উত্তর সংরক্ষিত হয়েছে।';

  @override
  String get journeyReplayOutcome =>
      'ঠিক হয়নি। চলুন ওই অংশটা আবার শুনি, তারপর আরেকবার চেষ্টা করি।';

  @override
  String get journeyTryAgainOutcome =>
      'ঠিক হয়নি। আবার ভাবুন এবং অন্য উত্তর বেছে নিন।';

  @override
  String journeyRevealed(String number, String answer, String explanation) {
    return 'ঠিক হয়নি। উত্তর হল বিকল্প $number, $answer। $explanation';
  }

  @override
  String journeyWellDone(String title) {
    return 'খুব ভালো! আপনি $title শেষ করেছেন।';
  }

  @override
  String journeyFirstTryScore(int questions, String correct) {
    String _temp0 = intl.Intl.pluralLogic(
      questions,
      locale: localeName,
      other:
          'প্রথম চেষ্টায় আপনি $questionsটি প্রশ্নের মধ্যে $correctটির সঠিক উত্তর দিয়েছেন।',
      one:
          'প্রথম চেষ্টায় আপনি 1টি প্রশ্নের মধ্যে $correctটির সঠিক উত্তর দিয়েছেন।',
    );
    return '$_temp0';
  }

  @override
  String get journeyPlayAgainHelp =>
      'আবার চালাতে 1 টিপুন, বা আপনার যাত্রাগুলিতে ফিরে যেতে 0 টিপুন।';

  @override
  String get journeyStatusCompleted => 'সম্পূর্ণ';

  @override
  String get journeyStatusInProgress => 'চলছে';

  @override
  String get journeyStatusNew => 'নতুন';

  @override
  String journeyRowScore(String percent) {
    return 'স্কোর $percent শতাংশ।';
  }

  @override
  String get journeyRowDownloaded => 'ডাউনলোড করা হয়েছে।';

  @override
  String journeyStudentRow(
    String title,
    String subject,
    String steps,
    String questions,
    String status,
  ) {
    return '$title। $subject। $stepsটি ধাপ, $questionsটি প্রশ্ন। $status।';
  }

  @override
  String journeyTeacherRow(
    String title,
    String status,
    String steps,
    String questions,
  ) {
    return '$title। $status। $stepsটি ধাপ, $questionsটি প্রশ্ন।';
  }

  @override
  String get journeyRowGraded => 'নম্বরযুক্ত।';

  @override
  String journeyStepRow(String number, String total, String name) {
    return '$total-এর মধ্যে ধাপ $number। $name।';
  }

  @override
  String get journeyReplaysAutomatically => 'নিজে থেকে আবার চলে।';

  @override
  String journeyReplaysFrom(String number) {
    return 'ধাপ $number থেকে আবার চলে।';
  }

  @override
  String get journeyFinishedStatus => 'যাত্রা শেষ।';

  @override
  String get journeyRecordingPlaying => 'রেকর্ডিং চলছে।';

  @override
  String get journeyRecordingPaused => 'রেকর্ডিং থামানো আছে।';

  @override
  String get journeyNoOptionChosen => 'এখনও কোনো বিকল্প বেছে নেওয়া হয়নি।';

  @override
  String journeyOptionSelected(String number, String option) {
    return 'বিকল্প $number, $option, বেছে নেওয়া হয়েছে।';
  }

  @override
  String journeyPreviewStart(String title) {
    return '$title-এর প্রিভিউ। কিছুই সংরক্ষণ করা হবে না।';
  }

  @override
  String journeyWelcomeBack(String title) {
    return '$title-এ আবার স্বাগতম। যেখানে থেমেছিলেন সেখান থেকে চলছে।';
  }

  @override
  String journeyStartingBrief(String title) {
    return '$title শুরু হচ্ছে।';
  }

  @override
  String journeyStartingDetailed(String title, String steps) {
    return '$title শুরু হচ্ছে। $stepsটি ধাপ। সাহায্যের জন্য যেকোনো সময় স্টার টিপুন।';
  }

  @override
  String journeyNotSaved(String reason) {
    return 'আপনি কোথায় ছিলেন তা সংরক্ষণ করা যায়নি। $reason';
  }

  @override
  String get journeyListeningAgain => 'আবার শোনা হচ্ছে।';

  @override
  String journeyNarration(String text) {
    return '$text এগিয়ে যেতে 2 টিপুন।';
  }

  @override
  String journeyRecordingStatus(String title) {
    return 'রেকর্ডিং: $title';
  }

  @override
  String get journeyRecordingFailed =>
      'এই রেকর্ডিং চালানো যায়নি। আপনার ইন্টারনেট দেখুন।';

  @override
  String get journeyRecordingRetry =>
      'আবার চেষ্টা করতে 3 টিপুন, বা পরের ধাপে যেতে 2 টিপুন।';

  @override
  String get journeyNotDownloaded => 'এই রেকর্ডিং এই ফোনে ডাউনলোড করা নেই।';

  @override
  String get journeyRecordingFinished => 'রেকর্ডিং শেষ।';

  @override
  String journeyAnswerFirst(String count) {
    return 'আগে উত্তর দিন। বেছে নিতে 1 থেকে $count টিপুন, তারপর 5 টিপুন।';
  }

  @override
  String get journeyNoEarlierContent => 'আগে কোনো রেকর্ডিং বা বর্ণনা নেই।';

  @override
  String get journeyGoingBack => 'পিছনে যাওয়া হচ্ছে।';

  @override
  String journeyNoSuchOption(String option, String count) {
    return 'বিকল্প $option নেই। 1 থেকে $count বেছে নিন।';
  }

  @override
  String journeyChooseFirst(String count) {
    return 'আগে 1 থেকে $count দিয়ে একটি উত্তর বেছে নিন।';
  }

  @override
  String get journeySendLater =>
      'যাত্রা শেষ। আপনি অনলাইন হলে আপনার উত্তর পাঠানো হবে।';

  @override
  String get journeyStartingAgain => 'আবার শুরু হচ্ছে।';

  @override
  String get journeyPaused => 'থামানো হয়েছে।';

  @override
  String get journeySeekRecordingsOnly =>
      'সামনে-পিছনে যাওয়া শুধু রেকর্ডিংয়ে কাজ করে।';

  @override
  String get journeySpeedRecordingsOnly =>
      'রেকর্ডিংয়ের গতি শুধু রেকর্ডিংয়েই বদলায়।';

  @override
  String get journeyFastest => 'সবচেয়ে দ্রুত গতি।';

  @override
  String get journeySlowest => 'সবচেয়ে ধীর গতি।';

  @override
  String journeySpeed(String rate) {
    return 'রেকর্ডিংয়ের গতি $rate গুণ।';
  }

  @override
  String get journeyLeaveTitle => 'এই যাত্রা ছেড়ে যাবেন?';

  @override
  String journeyLeaveMessage(String step) {
    return 'আপনি কোথায় ছিলেন তা এই ফোনে সংরক্ষিত আছে। পরের বার আপনি ধাপ $step থেকে চালিয়ে যেতে পারবেন।';
  }

  @override
  String get journeyAnswerHelp =>
      'বেছে নিতে একটি নম্বর, জমা দিতে 5, প্রশ্ন আবার শুনতে 6 টিপুন।';

  @override
  String journeyStepRemoved(String remaining) {
    return 'ধাপ সরানো হয়েছে। যাত্রায় এখন $remainingটি ধাপ আছে।';
  }

  @override
  String journeyStepRemovedUndo(String name) {
    return '$name সরানো হয়েছে।';
  }

  @override
  String get journeyStepRestored => 'ধাপ ফিরিয়ে আনা হয়েছে।';

  @override
  String journeyCreated(String title) {
    return '$title তৈরি হয়েছে। এখন এর প্রথম ধাপ যোগ করুন।';
  }

  @override
  String get journeyNoStepAdded => 'কোনো ধাপ যোগ করা হয়নি।';

  @override
  String journeyPreviewSkips(String issues) {
    return 'এই প্রিভিউতে কিছু ধাপ বাদ দেওয়া হয়েছে। $issues';
  }

  @override
  String journeyDuplicated(String title) {
    return '$title নতুন খসড়া হিসেবে তৈরি হয়েছে। খসড়া অংশে এটি পাবেন।';
  }

  @override
  String journeyArchiveMessage(String title) {
    return 'শিক্ষার্থীরা আর $title দেখতে পাবে না। ফলাফল রাখা থাকবে। পরে আপনি এটি ফিরিয়ে আনতে পারবেন।';
  }

  @override
  String journeyRestoreMessage(String title) {
    return 'শিক্ষার্থীরা আবার $title দেখতে পাবে।';
  }

  @override
  String get journeyArchived =>
      'আর্কাইভ করা হয়েছে। শিক্ষার্থীরা আর এটি দেখতে পায় না।';

  @override
  String get journeyRestored => 'শিক্ষার্থীদের জন্য ফিরিয়ে আনা হয়েছে।';

  @override
  String journeyDeleteDraftMessage(String title) {
    return '$title চিরতরে মুছে ফেলবেন? রেকর্ডিংগুলি আপনার লাইব্রেরিতে থেকে যাবে।';
  }

  @override
  String get journeyDraftDeleted => 'খসড়া মুছে ফেলা হয়েছে।';

  @override
  String get journeyNoRetriesLeft => 'আগে থেকেই আর কোনো পুনরায় চেষ্টা নেই।';

  @override
  String get journeyMaxRetries => 'সর্বোচ্চ পাঁচ বার পুনরায় চেষ্টা করা যায়।';

  @override
  String journeyPublished(String count) {
    return 'প্রকাশিত হয়েছে। শিক্ষার্থীরা এখন এটি চালাতে পারবে। $countটি ফোনে বিজ্ঞপ্তি পৌঁছেছে।';
  }

  @override
  String get journeyOptionUsed =>
      'এই বিকল্পটি আগেই ব্যবহার করা হয়েছে। অন্য একটি বিকল্প লিখুন।';

  @override
  String get journeyNothingToReplay =>
      'এই প্রশ্নের আগে এখনও কোনো রেকর্ডিং বা বর্ণনা নেই, তাই ভুল উত্তর দিলে আবার প্রশ্ন করা হবে। আপনি আগে বিষয়বস্তু যোগ করে পরে এটি সম্পাদনা করতে পারেন।';

  @override
  String get journeyBankEmpty =>
      'এই ক্লাস ও বিষয়ের জন্য আপনার প্রশ্ন ব্যাংক খালি। এর বদলে নতুন প্রশ্ন লিখুন বেছে নিন।';

  @override
  String get journeyRecordViaNotes =>
      'ব্যক্তিগত নোট খোলা হচ্ছে। রেকর্ড করুন, শুনে দেখুন, তারপর এই ক্লাস ও বিষয়ে প্রকাশ করুন বেছে নিন। 0 দিয়ে ফিরে আসুন, এবং আপনার নতুন রেকর্ডিং বেছে নিন।';

  @override
  String get journeyNoRecordings =>
      'এই ক্লাস ও বিষয়ে এখনও কোনো অডিও ফাইল নেই, তাই কিছু যোগ করা হয়নি। আপনি আগের স্ক্রিনে ফিরে এসেছেন। একটি যোগ করতে, আবার রেকর্ডিং বেছে নিন, তারপর রেকর্ডিং ফাইল আপলোড করতে 2 বা নতুন রেকর্ড করতে 3 টিপুন।';

  @override
  String get journeyOpeningFiles => 'অডিও ফাইলের জন্য ফাইল বাছাই খোলা হচ্ছে।';

  @override
  String get journeyNoFile => 'কোনো ফাইল বেছে নেওয়া হয়নি।';

  @override
  String get journeyUploading => 'আপলোড হচ্ছে। অনুগ্রহ করে অপেক্ষা করুন।';

  @override
  String get journeyUploadUnconfirmed =>
      'আপলোড নিশ্চিত হয়নি। একই জিনিস দুবার এড়াতে, আবার চেষ্টা করার আগে আমার রেকর্ডিং দেখে নিন।';

  @override
  String journeyUploaded(String title) {
    return '$title আপলোড হয়েছে।';
  }

  @override
  String get journeyStorageUnavailable => 'যাত্রার স্টোরেজ পাওয়া যাচ্ছে না।';

  @override
  String get journeyNothingInProgress =>
      'কোনো যাত্রা চলছে না। নতুন যাত্রার জন্য 2 টিপুন।';

  @override
  String get journeyTeacherUpdated =>
      'আপনার শিক্ষক এই যাত্রা আপডেট করেছেন। অফলাইনে নতুন সংস্করণ চালাতে এটি আবার ডাউনলোড করুন।';

  @override
  String journeyStartOverMessage(String title) {
    return '$title আবার ধাপ 1 থেকে শুরু করবেন? আপনি আগে যে উত্তরগুলি দিয়েছেন সেগুলি তবুও আপনার শিক্ষকের কাছে পাঠানো হবে।';
  }

  @override
  String journeyRemoveDownloadMessage(String title) {
    return 'এই ফোন থেকে $title সরাবেন? যাত্রায় আপনি কোথায় ছিলেন তা রাখা থাকবে। ইন্টারনেট থাকলে আপনি এটি আবার ডাউনলোড করতে পারবেন।';
  }

  @override
  String journeyDownloadRemoved(String title) {
    return '$title-এর ডাউনলোড সরানো হয়েছে।';
  }

  @override
  String journeyDownloading(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি রেকর্ডিং ডাউনলোড হচ্ছে। বাতিল করতে 0 টিপুন।',
      one: '1টি রেকর্ডিং ডাউনলোড হচ্ছে। বাতিল করতে 0 টিপুন।',
    );
    return '$_temp0';
  }

  @override
  String journeyDownloaded(String title) {
    return 'ডাউনলোড হয়েছে। আপনি ইন্টারনেট ছাড়াই $title চালাতে পারবেন।';
  }

  @override
  String get journeyCancellingDownload =>
      'ডাউনলোড বাতিল হচ্ছে। সংরক্ষিত রেকর্ডিংগুলি রাখা থাকবে।';

  @override
  String journeyStepDetailsQuestion(
    String name,
    String options,
    String number,
    String explanation,
  ) {
    return '$name $options সঠিক উত্তর: বিকল্প $number। $explanation';
  }

  @override
  String get journeyNoExplanation => 'কোনো ব্যাখ্যা নেই।';

  @override
  String journeyExplanation(String text) {
    return 'ব্যাখ্যা: $text';
  }

  @override
  String journeyStepNameRecording(String title) {
    return 'রেকর্ডিং। $title';
  }

  @override
  String get journeyUntitledRecording => 'শিরোনামহীন রেকর্ডিং';

  @override
  String journeyStepNameNarration(String text) {
    return 'বর্ণনা। $text';
  }

  @override
  String journeyStepNameQuestion(String text) {
    return 'প্রশ্ন। $text';
  }

  @override
  String journeyStepNamePoll(String text) {
    return 'পোল। $text';
  }

  @override
  String get journeyStatusPublished => 'প্রকাশিত';

  @override
  String get journeyStatusArchived => 'আর্কাইভ করা';

  @override
  String get journeyStatusDraft => 'খসড়া, এখনও প্রকাশিত হয়নি';

  @override
  String journeyStatusWithChanges(String status) {
    return '$status, অপ্রকাশিত পরিবর্তন সহ';
  }

  @override
  String get journeyErrorChanged =>
      'এই যাত্রা বদলে গেছে। রিফ্রেশ করে আবার চেষ্টা করুন।';

  @override
  String get journeyErrorSignInExpired =>
      'আপনার সাইন ইনের মেয়াদ শেষ হয়েছে। আবার সাইন ইন করুন।';

  @override
  String get journeyErrorPermission => 'এটি করার অনুমতি আপনার নেই।';

  @override
  String get journeyErrorNotAvailable => 'এই যাত্রা আর পাওয়া যাচ্ছে না।';

  @override
  String get journeyErrorInvalid =>
      'কিছু তথ্য গ্রহণ করা যায়নি। দেখে নিয়ে আবার চেষ্টা করুন।';

  @override
  String get journeyErrorServer =>
      'স্কুলের সার্ভারে সমস্যা হয়েছে। পরে আবার চেষ্টা করুন।';

  @override
  String get journeyErrorRequestFailed =>
      'অনুরোধটি সফল হয়নি। আবার চেষ্টা করুন।';

  @override
  String get journeyErrorResponseUnreadable =>
      'সার্ভারের উত্তর পড়া যায়নি। আবার চেষ্টা করার আগে রিফ্রেশ করুন।';

  @override
  String get journeyErrorSavedUnreadable =>
      'সংরক্ষিত যাত্রা পড়া যায়নি। আবার চেষ্টা করার আগে রিফ্রেশ করুন।';

  @override
  String get journeyErrorListUnreadable => 'যাত্রার তালিকা পড়া যায়নি।';

  @override
  String get journeyErrorMismatch =>
      'সংরক্ষিত যাত্রা মেলেনি। আবার চেষ্টা করার আগে রিফ্রেশ করুন।';

  @override
  String get journeyErrorPreviewUnreadable => 'যাত্রার প্রিভিউ পড়া যায়নি।';

  @override
  String get journeyErrorRecordingsUnreadable =>
      'রেকর্ডিংয়ের তালিকা পড়া যায়নি।';

  @override
  String get journeyErrorBankUnreadable => 'প্রশ্ন ব্যাংক পড়া যায়নি।';

  @override
  String get journeyErrorJourneyUnreadable => 'এই যাত্রা পড়া যায়নি।';

  @override
  String get journeyDownloadNeedsApp =>
      'অফলাইনে ব্যবহারের জন্য ডাউনলোড করতে SEEDS Android অ্যাপ দরকার। ব্রাউজারে, আপনি অনলাইনে থাকলে যাত্রা চলে।';

  @override
  String get journeySignInFirst => 'শেখার যাত্রা খোলার আগে সাইন ইন করুন।';

  @override
  String get journeyStorageUnavailableDevice =>
      'এই ডিভাইসে যাত্রার স্টোরেজ পাওয়া যাচ্ছে না।';

  @override
  String get journeyStorageFull =>
      'যাত্রার স্টোরেজ পাওয়া যাচ্ছে না। খালি জায়গা দেখে আবার চেষ্টা করুন। কিছুই মোছা হয়নি।';

  @override
  String get journeyDownloadCancelled =>
      'ডাউনলোড বাতিল হয়েছে। আগে সেভ হওয়া রেকর্ডিং রাখা আছে।';

  @override
  String journeyRecordingsSaved(String done, String total) {
    return '$totalটির মধ্যে $doneটি রেকর্ডিং সেভ হয়েছে।';
  }

  @override
  String get journeyLeaveJourney => 'যাত্রা ছেড়ে যান';

  @override
  String get journeyLeaveSaved => 'যাত্রা ছেড়ে যান। আপনার জায়গা সেভ করা আছে';

  @override
  String get journeyKeyPlayAgain => 'আবার চালান';

  @override
  String get journeyKeySubmitAnswer => 'উত্তর জমা দিন';

  @override
  String get journeyKeyRepeatQuestion => 'প্রশ্ন আবার শুনুন';

  @override
  String get journeyKeySlowerSpeech => 'ধীরে বলুক';

  @override
  String get journeyKeyWhereAmI => 'আমি কোথায় আছি';

  @override
  String get journeyKeyFasterSpeech => 'দ্রুত বলুক';

  @override
  String get journeyKeyNextStep => 'পরের ধাপ';

  @override
  String get journeyKeyRepeatStep => 'এই ধাপ আবার করুন';

  @override
  String get journeyKeyReadAgain => 'আবার পড়ুন';

  @override
  String get journeyKeyPreviousContent => 'আগের রেকর্ডিং বা বর্ণনা';

  @override
  String journeyPreviewTitle(String title) {
    return 'প্রিভিউ: $title';
  }

  @override
  String get journeyPositionFinished => 'শেষ হয়েছে';

  @override
  String journeyStepPosition(String number, String total) {
    return '$totalটির মধ্যে ধাপ $number';
  }

  @override
  String journeySelectedLabel(String label) {
    return '$label, বেছে নেওয়া হয়েছে';
  }

  @override
  String get journeyResultsLoading => 'ফলাফল লোড হচ্ছে।';

  @override
  String journeyResultsSummary(
    String completed,
    String eligible,
    String inProgress,
    String notStarted,
  ) {
    return '$eligible জন শিক্ষার্থীর মধ্যে $completed জন শেষ করেছে। $inProgress জন চলছে, $notStarted জন শুরু করেনি।';
  }

  @override
  String journeyResultsAverage(String percent) {
    return 'প্রথম চেষ্টায় গড় স্কোর $percent শতাংশ।';
  }

  @override
  String get journeyResultFinished => 'শেষ হয়েছে';

  @override
  String get journeyResultNotStarted => 'শুরু হয়নি';

  @override
  String journeyResultStudent(String name, String status) {
    return '$name। $status।';
  }

  @override
  String journeyResultFirstTime(String correct, String total) {
    return '$totalটির মধ্যে $correctটি প্রথমবারেই সঠিক।';
  }

  @override
  String journeyResultWrongAnswers(String count) {
    return '$countটি ভুল উত্তর।';
  }

  @override
  String journeyResultQuestion(String number, String text, String answered) {
    return 'ধাপ $number। $text। $answered জন উত্তর দিয়েছে।';
  }

  @override
  String journeyResultRate(String percent) {
    return '$percent শতাংশ প্রথমবারেই সঠিক।';
  }

  @override
  String get journeyResultNoAnswers => 'এখনও কোনো উত্তর নেই।';

  @override
  String journeyResultAverageTries(String attempts) {
    return 'গড়ে $attemptsটি চেষ্টা।';
  }

  @override
  String journeyResultPoll(
    String number,
    String text,
    String answered,
    String options,
  ) {
    return 'ধাপ $number। $text। $answered জন উত্তর দিয়েছে। $options।';
  }

  @override
  String get journeyResultsStudentsTitle => 'শিক্ষার্থী';

  @override
  String get journeyResultsQuestionsTitle => 'প্রশ্ন';

  @override
  String get journeyResultsPollsTitle => 'পোলের উত্তর';

  @override
  String journeyResultsTitle(String title) {
    return 'ফলাফল: $title';
  }

  @override
  String get journeyResultsHearSummary => 'ক্লাসের সারাংশ শুনুন';

  @override
  String journeyResultsStudents(String count) {
    return 'শিক্ষার্থী, $count';
  }

  @override
  String journeyResultsQuestions(String count) {
    return 'প্রশ্ন, $count। কোন অংশ আবার পড়ানো দরকার তা দেখায়';
  }

  @override
  String journeyResultsPolls(String count) {
    return 'পোলের উত্তর, $count';
  }

  @override
  String get journeyResultsRefresh => 'ফলাফল রিফ্রেশ করুন';

  @override
  String get journeyResultsNoStudents => 'এই ক্লাসে কোনো শিক্ষার্থী নেই।';

  @override
  String get journeyResultsNoQuestions => 'এই যাত্রায় কোনো প্রশ্ন নেই।';

  @override
  String get journeyResultsNoPolls => 'এই যাত্রায় কোনো পোল নেই।';

  @override
  String get journeyNarrationLabel =>
      'যে কথাগুলো ফোন জোরে পড়বে, যেমন: আজ চলো কিছু খাবারের কথা শুনি';

  @override
  String journeyAddOptionTitle(String number) {
    return 'বিকল্প $number যোগ করবেন?';
  }

  @override
  String journeyQuestionOptionsSoFar(String count) {
    return 'প্রশ্নটিতে এখন পর্যন্ত $countটি বিকল্প আছে।';
  }

  @override
  String journeyPollOptionsSoFar(String count) {
    return 'পোলটিতে এখন পর্যন্ত $countটি বিকল্প আছে।';
  }

  @override
  String journeyAddOption(String number) {
    return 'বিকল্প $number যোগ করুন';
  }

  @override
  String get journeyNoMoreOptions => 'আর বিকল্প নেই, এগিয়ে যান';

  @override
  String journeyOptionTitle(String number) {
    return 'বিকল্প $number';
  }

  @override
  String journeyTypeOption(String number) {
    return 'বিকল্প $number টাইপ করুন';
  }

  @override
  String get journeyReplayAutoNone =>
      'স্বয়ংক্রিয়: আবার না চালিয়েই আবার জিজ্ঞাসা করুন';

  @override
  String journeyReplayAutoFrom(String number, String name) {
    return 'স্বয়ংক্রিয়: ধাপ $number, $name থেকে আবার চালান';
  }

  @override
  String get journeyAfterWrongTitle => 'ভুল উত্তরের পরে';

  @override
  String get journeyAfterWrongIntro =>
      'শিক্ষার্থী ভুল উত্তর দিলে, আবার চেষ্টা করার আগে কোন অংশটি আবার চলবে?';

  @override
  String get journeyReplayChooseStep => 'আবার চালানোর জন্য অন্য ধাপ বেছে নিন';

  @override
  String get journeyReplayWhichStep => 'কোন ধাপ থেকে আবার চালাবেন?';

  @override
  String journeyStepLabel(String number, String name) {
    return 'ধাপ $number। $name';
  }

  @override
  String journeyReviewReplayFrom(String number) {
    return 'ভুল উত্তরের পরে ধাপ $number আবার চলবে।';
  }

  @override
  String get journeyReviewReplayAuto =>
      'ভুল উত্তরের পরে এটি স্বয়ংক্রিয়ভাবে আবার চলবে।';

  @override
  String get journeyCheckBeforeSaving => 'সেভ করার আগে দেখে নিন';

  @override
  String get journeySaveStep => 'এই ধাপ সেভ করুন';

  @override
  String get journeyRestartStep => 'এই ধাপ আবার শুরু করুন';

  @override
  String get journeyQuestionLabel =>
      'শিক্ষার্থীরা যে প্রশ্ন শুনবে তা টাইপ করুন';

  @override
  String get journeyWhichCorrect => 'কোন বিকল্পটি সঠিক?';

  @override
  String journeyCurrentlyCorrect(String number) {
    return 'এখন বিকল্প $number সঠিক।';
  }

  @override
  String journeyOptionChoice(String number, String text) {
    return 'বিকল্প $number: $text';
  }

  @override
  String get journeyExplanationTitle => 'ব্যাখ্যা';

  @override
  String get journeyExplanationLabel =>
      'সঠিক উত্তর জানানোর পরে শিক্ষার্থীরা যা শুনবে';

  @override
  String get journeyPollQuestionTitle => 'পোলের প্রশ্ন';

  @override
  String get journeyPollQuestionLabel =>
      'যে প্রশ্নের কোনো ভুল উত্তর নেই, যেমন: এই সপ্তাহে আপনি কি ভাত খেয়েছেন?';

  @override
  String get journeyQuestionBank => 'প্রশ্ন ব্যাংক';

  @override
  String journeyBankQuestionLabel(String text, String count) {
    return '$text। $countটি বিকল্প।';
  }

  @override
  String get journeyAddRecording => 'একটি রেকর্ডিং যোগ করুন';

  @override
  String get journeyChooseMyRecordings => 'আমার রেকর্ডিং থেকে বেছে নিন';

  @override
  String get journeyUploadRecordingFile => 'একটি রেকর্ডিং ফাইল আপলোড করুন';

  @override
  String get journeyRecordNew => 'নতুন রেকর্ডিং করুন';

  @override
  String get journeyMyRecordings => 'আমার রেকর্ডিং';

  @override
  String get journeyRecordingName => 'রেকর্ডিংয়ের নাম';

  @override
  String get journeyRecordingNameLabel => 'এই রেকর্ডিংয়ের নাম';

  @override
  String journeyOptionalLabel(String label) {
    return '$label। ঐচ্ছিক, বাদ দিতে খালি রাখুন';
  }

  @override
  String get journeyNothingEntered =>
      'কিছু লেখা হয়নি। ঘরে ওকে টিপে টাইপ করুন, অথবা ফিরে যেতে 0 টিপুন।';

  @override
  String journeyTooLong(String max) {
    return 'খুব লম্বা। সর্বোচ্চ $maxটি অক্ষর ব্যবহার করুন।';
  }

  @override
  String get journeySkipped => 'বাদ দেওয়া হয়েছে।';

  @override
  String journeyYouEntered(String text) {
    return 'আপনি লিখেছেন: $text';
  }

  @override
  String get journeyMenuReady => 'প্রস্তুত।';

  @override
  String journeyMenuNothingAssigned(String number) {
    return '$number-এ কিছু দেওয়া নেই।';
  }

  @override
  String get journeyMenuPleaseWait =>
      'অনুগ্রহ করে অপেক্ষা করুন। কাজ চলছে। ফিরে যেতে 0 টিপুন।';

  @override
  String get journeyMenuWorking => 'কাজ চলছে, অনুগ্রহ করে অপেক্ষা করুন।';

  @override
  String get journeyMenuReadDetails => 'বিবরণ আবার পড়ুন';

  @override
  String get journeyNoInternetDownloaded =>
      'ইন্টারনেট নেই। ডাউনলোড করা যাত্রা এখনও চলবে। ডাউনলোড করা যাত্রার জন্য 5 টিপুন।';

  @override
  String journeyWaitingToSend(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি শেষ করা যাত্রা পাঠানোর অপেক্ষায় আছে।',
      one: '1টি শেষ করা যাত্রা পাঠানোর অপেক্ষায় আছে।',
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
    return '$newCountটি নতুন, $inProgressটি চলছে, $completedটি শেষ, $downloadedটি ডাউনলোড করা।';
  }

  @override
  String get journeyDownloadedJourneys => 'ডাউনলোড করা যাত্রা';

  @override
  String journeyDownloadedRow(String title, String steps) {
    return '$title। $stepsটি ধাপ। ডাউনলোড করা।';
  }

  @override
  String get journeyOfflineReason =>
      'এর জন্য ইন্টারনেট লাগবে। ডাউনলোড করা যাত্রার জন্য 5 টিপুন।';

  @override
  String get journeyLearningJourneys => 'শেখার যাত্রা';

  @override
  String get journeyStudentIntro =>
      'গল্প ও পাঠ শুনুন, চলার পথে প্রশ্নের উত্তর দিন, আর দরকার হলে অংশগুলো আবার শুনুন।';

  @override
  String get journeyContinueLast => 'আমার শেষ যাত্রা চালিয়ে যান';

  @override
  String journeyNewJourneys(String count) {
    return 'নতুন যাত্রা, $count';
  }

  @override
  String get journeyNewJourneysTitle => 'নতুন যাত্রা';

  @override
  String get journeyNoNewJourneys => 'কোনো নতুন যাত্রা নেই।';

  @override
  String journeyInProgressCount(String count) {
    return 'চলছে, $count';
  }

  @override
  String get journeyInProgressTitle => 'চলমান যাত্রা';

  @override
  String get journeyNothingInProgressShort => 'কিছুই চলছে না।';

  @override
  String journeyCompletedCount(String count) {
    return 'শেষ হয়েছে, $count';
  }

  @override
  String get journeyCompletedTitle => 'শেষ করা যাত্রা';

  @override
  String get journeyNoneCompleted => 'এখনও কোনো যাত্রা শেষ হয়নি।';

  @override
  String journeyDownloadedCount(String count) {
    return 'ডাউনলোড করা, $count';
  }

  @override
  String get journeyNothingDownloaded =>
      'কিছুই ডাউনলোড করা নেই। একটি যাত্রা খুলে ডাউনলোড বেছে নিন।';

  @override
  String get journeyNoInternetNotDownloaded =>
      'ইন্টারনেট নেই, আর এই যাত্রা ডাউনলোড করা নেই।';

  @override
  String get journeyStartOverTitle => 'আবার শুরু করবেন?';

  @override
  String get journeyStartOver => 'আবার শুরু করুন';

  @override
  String get journeyRemoveDownloadTitle => 'ডাউনলোড সরাবেন?';

  @override
  String get journeyRemoveDownload => 'ডাউনলোড সরান';

  @override
  String journeySavedRecordings(String done, String total) {
    return '$totalটির মধ্যে $doneটি রেকর্ডিং সেভ হয়েছে।';
  }

  @override
  String get journeyDownloadedOnPhone => 'এই ফোনে ডাউনলোড করা আছে।';

  @override
  String get journeyNotDownloadedShort => 'ডাউনলোড করা নেই।';

  @override
  String get journeyStartedThis => 'আপনি এই যাত্রা শুরু করেছেন।';

  @override
  String get journeyWorksOffline => 'ডাউনলোড করা। ইন্টারনেট ছাড়াই চলে।';

  @override
  String get journeyContinueJourney => 'যাত্রা চালিয়ে যান';

  @override
  String get journeyStartJourney => 'যাত্রা শুরু করুন';

  @override
  String get journeyHearAbout => 'এই যাত্রা সম্পর্কে শুনুন';

  @override
  String get journeyDownloadOffline => 'ইন্টারনেট ছাড়া চালাতে ডাউনলোড করুন';

  @override
  String get journeyDownloadInProgress =>
      'একটি ডাউনলোড চলছে। বাতিল করতে 0 টিপুন।';

  @override
  String get journeyStartFromBeginning => 'একেবারে শুরু থেকে আবার শুরু করুন';

  @override
  String get journeyNotStartedYet => 'আপনি এখনও এই যাত্রা শুরু করেননি।';

  @override
  String journeyLatestLoaded(String message) {
    return '$message সর্বশেষ সংস্করণ এখন লোড হয়েছে।';
  }

  @override
  String journeyTeacherSummary(
    String drafts,
    String published,
    String archived,
  ) {
    return '$draftsটি খসড়া, $publishedটি প্রকাশিত, $archivedটি আর্কাইভ করা।';
  }

  @override
  String get journeyNewJourneyTitle => 'নতুন শেখার যাত্রা';

  @override
  String get journeyNameExample => 'যাত্রার নাম, যেমন: আমাদের চারপাশের খাবার';

  @override
  String get journeyRefreshFirst => 'আগে তালিকা রিফ্রেশ করতে 5 টিপুন।';

  @override
  String journeyTeacherIntro(String workspace) {
    return '$workspace। শিক্ষার্থীদের জন্য রেকর্ডিং, বর্ণনা, প্রশ্ন ও পোল দিয়ে একটি ধারা তৈরি করুন।';
  }

  @override
  String get journeyCreateNew => 'নতুন যাত্রা তৈরি করুন';

  @override
  String journeyDraftsCount(String count) {
    return 'খসড়া, $count';
  }

  @override
  String get journeyDraftJourneys => 'খসড়া যাত্রা';

  @override
  String get journeyNoDrafts => 'কোনো খসড়া নেই।';

  @override
  String journeyPublishedCount(String count) {
    return 'প্রকাশিত, $count';
  }

  @override
  String get journeyPublishedJourneys => 'প্রকাশিত যাত্রা';

  @override
  String get journeyNothingPublished => 'এখনও কিছু প্রকাশিত হয়নি।';

  @override
  String journeyArchivedCount(String count) {
    return 'আর্কাইভ করা, $count';
  }

  @override
  String get journeyArchivedJourneys => 'আর্কাইভ করা যাত্রা';

  @override
  String get journeyNothingArchived => 'কিছুই আর্কাইভ করা নেই।';

  @override
  String get journeyRefreshList => 'তালিকা রিফ্রেশ করুন';

  @override
  String journeyOverviewSummary(
    String status,
    String steps,
    String questions,
    String graded,
    String retries,
  ) {
    return '$status। $stepsটি ধাপ, $questionsটি প্রশ্ন। $graded। $retries';
  }

  @override
  String get journeyGraded => 'নম্বরযুক্ত';

  @override
  String get journeyNotGraded => 'নম্বরযুক্ত নয়';

  @override
  String journeyRetriesPerQuestion(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'প্রতি প্রশ্নে $countটি পুনরায় চেষ্টা।',
      one: 'প্রতি প্রশ্নে 1টি পুনরায় চেষ্টা।',
    );
    return '$_temp0';
  }

  @override
  String get journeySteps => 'ধাপ';

  @override
  String journeyAddStepTitle(String number) {
    return 'ধাপ $number যোগ করুন';
  }

  @override
  String get journeyAddStepIntro =>
      'নতুন ধাপটি শেষে যাবে। পরে আপনি এটি সরাতে পারবেন।';

  @override
  String get journeyChoiceRecording => 'রেকর্ডিং';

  @override
  String get journeyChoiceNarration => 'ফোনে পড়া বর্ণনা';

  @override
  String get journeyChoiceQuestion => 'প্রশ্ন';

  @override
  String get journeyChoicePoll => 'পোল, কোনো ভুল উত্তর নেই';

  @override
  String journeySavedAsStep(String number, String name) {
    return 'ধাপ $number হিসেবে সেভ হয়েছে। $name';
  }

  @override
  String get journeyAddQuestion => 'একটি প্রশ্ন যোগ করুন';

  @override
  String get journeyWriteNewQuestion => 'নতুন প্রশ্ন লিখুন';

  @override
  String get journeyChooseFromBank => 'আমার প্রশ্ন ব্যাংক থেকে বেছে নিন';

  @override
  String get journeyHearAndEdit => 'ধাপগুলো শুনুন ও সম্পাদনা করুন';

  @override
  String get journeyNoStepsYet => 'এখনও কোনো ধাপ নেই। একটি যোগ করতে 2 টিপুন।';

  @override
  String get journeyAddStep => 'একটি ধাপ যোগ করুন';

  @override
  String get journeyPreviewAsStudent => 'শিক্ষার্থী হিসেবে প্রিভিউ দেখুন';

  @override
  String get journeyAddStepFirst => 'আগে একটি ধাপ যোগ করুন।';

  @override
  String get journeyPublishToStudents => 'শিক্ষার্থীদের জন্য প্রকাশ করুন';

  @override
  String get journeyPublishChanges => 'পরিবর্তন প্রকাশ করুন';

  @override
  String get journeyStudentResults => 'শিক্ষার্থীদের ফলাফল';

  @override
  String get journeyMoreOptions => 'আরও বিকল্প';

  @override
  String journeyStepSaved(String number) {
    return 'ধাপ $number সেভ হয়েছে।';
  }

  @override
  String journeyMoved(String number, String total) {
    return 'সরানো হয়েছে। এটি এখন $totalটির মধ্যে ধাপ $number।';
  }

  @override
  String journeyRemoveStepTitle(String number) {
    return 'ধাপ $number সরাবেন?';
  }

  @override
  String journeyRemoveStepMessage(String name) {
    return '$name সরাবেন? রেকর্ডিংগুলো আপনার লাইব্রেরিতে থেকে যাবে। যে প্রশ্নগুলো এই ধাপ আবার চালাত, সেগুলো এর বদলে স্বয়ংক্রিয়ভাবে আবার চালাবে।';
  }

  @override
  String get journeyRemoveStep => 'ধাপ সরান';

  @override
  String get journeyStepNotFound => 'ধাপ পাওয়া যায়নি';

  @override
  String get journeyStepWasRemoved =>
      'এই ধাপটি সরানো হয়েছে। ফিরে যেতে 0 টিপুন।';

  @override
  String get journeyHearStepInFull => 'এই ধাপটি পুরোটা শুনুন';

  @override
  String get journeyEditStep => 'এই ধাপ সম্পাদনা করুন';

  @override
  String get journeyMoveEarlier => 'আগে সরান';

  @override
  String get journeyAlreadyFirst => 'এটি ইতিমধ্যে প্রথম ধাপ।';

  @override
  String get journeyMoveLater => 'পরে সরান';

  @override
  String get journeyAlreadyLast => 'এটি ইতিমধ্যে শেষ ধাপ।';

  @override
  String get journeyRemoveThisStep => 'এই ধাপ সরান';

  @override
  String get journeyRenameTitle => 'যাত্রার নাম বদলান';

  @override
  String get journeyNameLabel => 'যাত্রার নাম';

  @override
  String journeyRenamed(String title) {
    return 'নাম বদলে $title করা হয়েছে।';
  }

  @override
  String get journeyArchiveTitle => 'এই যাত্রা আর্কাইভ করবেন?';

  @override
  String get journeyRestoreTitle => 'এই যাত্রা ফিরিয়ে আনবেন?';

  @override
  String get journeyArchive => 'আর্কাইভ করুন';

  @override
  String get journeyRestore => 'ফিরিয়ে আনুন';

  @override
  String get journeyDeleteDraftTitle => 'এই খসড়া মুছবেন?';

  @override
  String get journeyDeleteDraft => 'খসড়া মুছুন';

  @override
  String get journeyPublishFirst => 'আগে যাত্রাটি প্রকাশ করুন।';

  @override
  String get journeyRename => 'নাম বদলান';

  @override
  String get journeyGradingNowGraded => 'নম্বর ও চেষ্টা, এখন নম্বরযুক্ত';

  @override
  String get journeyGradingNowNotGraded => 'নম্বর ও চেষ্টা, এখন নম্বরযুক্ত নয়';

  @override
  String get journeyDuplicate => 'নতুন খসড়া হিসেবে কপি করুন';

  @override
  String get journeyArchiveHide => 'আর্কাইভ করুন, শিক্ষার্থীদের থেকে লুকান';

  @override
  String get journeyRestoreForStudents => 'শিক্ষার্থীদের জন্য ফিরিয়ে আনুন';

  @override
  String get journeyDeleteThisDraft => 'এই খসড়া মুছুন';

  @override
  String get journeyGradedSummary =>
      'নম্বরযুক্ত: প্রতিটি প্রশ্নে প্রথম চেষ্টা স্কোরে গোনা হয়।';

  @override
  String get journeyNotGradedSummary =>
      'নম্বরযুক্ত নয়: প্রশ্নগুলো শুধু অনুশীলনের জন্য।';

  @override
  String journeyMoreTriesSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'ভুল উত্তরের পরে শিক্ষার্থী আরও $count বার চেষ্টা করতে পারে, তার আগে বিষয়বস্তু আবার চালানো হয়।',
      one:
          'ভুল উত্তরের পরে শিক্ষার্থী আরও 1 বার চেষ্টা করতে পারে, তার আগে বিষয়বস্তু আবার চালানো হয়।',
    );
    return '$_temp0';
  }

  @override
  String get journeyGradingTitle => 'নম্বর ও চেষ্টা';

  @override
  String get journeyTurnGradingOff => 'নম্বর দেওয়া বন্ধ করুন';

  @override
  String get journeyTurnGradingOn => 'নম্বর দেওয়া চালু করুন';

  @override
  String get journeyGradingIsOff => 'নম্বর দেওয়া বন্ধ আছে।';

  @override
  String get journeyGradingIsOn => 'নম্বর দেওয়া চালু আছে।';

  @override
  String get journeyFewerTries => 'কম চেষ্টা';

  @override
  String get journeyMoreTries => 'বেশি চেষ্টা';

  @override
  String get journeyLoadingSummary => 'সারাংশ লোড হচ্ছে।';

  @override
  String get journeyNoProblems => 'কোনো সমস্যা নেই।';

  @override
  String journeyProblems(String issues) {
    return 'প্রকাশের আগে যে সমস্যাগুলো ঠিক করতে হবে: $issues';
  }

  @override
  String journeyThingsToCheck(String warnings) {
    return 'যা দেখে নিতে হবে: $warnings';
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
    return '$title। $stepsটি ধাপ: $recordingsটি রেকর্ডিং, $narrationsটি বর্ণনা, $questionsটি প্রশ্ন, $pollsটি পোল। $graded।';
  }

  @override
  String journeyPublishTitle(String title) {
    return '$title প্রকাশ করবেন?';
  }

  @override
  String get journeyPublishMessage =>
      'এই ক্লাসের সব শিক্ষার্থী এটি চালাতে ও ডাউনলোড করতে পারবে, এবং তারা একটি বিজ্ঞপ্তি পাবে।';

  @override
  String get journeyPublishNow => 'এখনই প্রকাশ করুন';

  @override
  String get journeyPublishedShort => 'প্রকাশিত।';

  @override
  String get journeyReviewBeforePublishing => 'প্রকাশের আগে দেখে নিন';

  @override
  String get journeyFixProblemsFirst =>
      'আগে সমস্যাগুলো ঠিক করুন। সেগুলো শুনতে 8 টিপুন।';

  @override
  String get journeyPreviewFirst => 'আগে শিক্ষার্থী হিসেবে প্রিভিউ দেখুন';

  @override
  String undoOffer(String seconds) {
    return 'ফেরাতে $seconds সেকেন্ডের মধ্যে 1 টিপুন।';
  }

  @override
  String undoDone(String action) {
    return 'ফেরানো হয়েছে। $action বাতিল করা হয়েছে।';
  }

  @override
  String get undoFailed =>
      'ফেরানো গেল না। জিনিসটি দেখুন এবং দরকার হলে আবার যোগ করুন।';

  @override
  String get uiBack => 'ফিরে যান';

  @override
  String get uiCancel => 'বাতিল';

  @override
  String get uiContinue => 'এগিয়ে যান';

  @override
  String get uiNotNow => 'এখন নয়';

  @override
  String uiPressFor(String key, String action) {
    return '$action-এর জন্য $key টিপুন।';
  }

  @override
  String uiLabelUnavailable(String label) {
    return '$label, পাওয়া যাচ্ছে না';
  }

  @override
  String get uiAlreadyHome => 'আপনি ইতিমধ্যে হোম স্ক্রিনে আছেন।';

  @override
  String uiNotAvailableNow(String label) {
    return '$label এখন পাওয়া যাচ্ছে না।';
  }

  @override
  String uiListLoading(String title) {
    return '$title লোড হচ্ছে। ফিরে যেতে 0 টিপুন।';
  }

  @override
  String uiListPage(String title, String number) {
    return '$title। পৃষ্ঠা $number।';
  }

  @override
  String uiListScreenName(String title, String number) {
    return '$title। পৃষ্ঠা $number';
  }

  @override
  String get uiListNoMatches => 'মেলে এমন কিছু নেই।';

  @override
  String get uiListHelp =>
      'রিফ্রেশ সহ তালিকার বিকল্পের জন্য 6 টিপুন। আগের পৃষ্ঠার জন্য 7 টিপুন। সব আইটেম খুঁজতে 8 টিপুন। পরের পৃষ্ঠার জন্য 9 টিপুন। ফিরে যেতে 0 টিপুন। আইটেম ও পৃষ্ঠার কন্ট্রোলের মধ্যে যেতে D-pad উপর ও নিচ ব্যবহার করুন, এবং বেছে নিতে ওকে টিপুন। সাহায্য আবার শুনতে স্টার টিপুন। কণ্ঠস্বর থামাতে হ্যাশ টিপুন।';

  @override
  String get uiListLoadFailed =>
      'এই পৃষ্ঠাটি লোড করা যায়নি। আবার চেষ্টার বিকল্পের জন্য 6 টিপুন। আপনার আগের পৃষ্ঠা রাখা আছে।';

  @override
  String get uiListLoadingWait =>
      'লোড হচ্ছে। অপেক্ষা করুন, অথবা ফিরে যেতে 0 টিপুন।';

  @override
  String uiListNoItem(String number) {
    return 'এই পৃষ্ঠায় $number-এ কোনো আইটেম নেই।';
  }

  @override
  String get uiListFirstPage => 'এটি প্রথম পৃষ্ঠা।';

  @override
  String get uiListLastPage => 'এটি শেষ পৃষ্ঠা।';

  @override
  String uiListSearchTitle(String title) {
    return '$title খুঁজুন';
  }

  @override
  String get uiListSearchLabel => 'সব আইটেম খুঁজুন';

  @override
  String get uiListSearchTooLong =>
      'খোঁজার জন্য সর্বোচ্চ 200টি অক্ষর ব্যবহার করুন।';

  @override
  String get uiListOptions => 'তালিকার বিকল্প';

  @override
  String get uiListSearch => 'খুঁজুন';

  @override
  String get uiListClearSearch => 'খোঁজা মুছুন';

  @override
  String get uiListRefreshPage => 'এই পৃষ্ঠা রিফ্রেশ করুন';

  @override
  String get uiListRetry => 'আবার চেষ্টা করুন';

  @override
  String get uiListFilters => 'ফিল্টার';

  @override
  String get uiListPreviousPage => 'আগের পৃষ্ঠা';

  @override
  String get uiListSearchAll => 'সব আইটেম খুঁজুন';

  @override
  String get uiListNextPage => 'পরের পৃষ্ঠা';

  @override
  String get uiListSections =>
      'আইটেম, তালিকার বিকল্প, আগের পৃষ্ঠা, খোঁজা, পরের পৃষ্ঠা এবং ফিরে যাওয়া';

  @override
  String get uiWaitingConfirmation =>
      'নিশ্চিতকরণের অপেক্ষা চলছে। দয়া করে অপেক্ষা করুন।';

  @override
  String get uiFinishWord => 'এখনকার শব্দটি লেখা শেষ করুন, তারপর ওকে টিপুন।';

  @override
  String get uiStepFailed =>
      'এই ধাপটি সম্পূর্ণ করা যায়নি। আপনার লেখা রাখা আছে। আবার চেষ্টা করুন।';

  @override
  String get uiPasswordVisible => 'পাসওয়ার্ড দেখা যাচ্ছে।';

  @override
  String get uiPasswordHidden => 'পাসওয়ার্ড লুকানো আছে।';

  @override
  String uiTextStepScreen(String title, String label) {
    return '$title। $label। লেখা চলছে। শেষ করতে ওকে টিপুন, অথবা ঘর ছাড়তে উপর বা নিচ ব্যবহার করুন।';
  }

  @override
  String get uiShowOrHidePassword => 'পাসওয়ার্ড দেখান বা লুকান';

  @override
  String get uiDateEnterNumbers =>
      'তারিখ ও সময়ের প্রতিটি ঘরে একটি সংখ্যা লিখুন।';

  @override
  String uiDateChooseValid(String from, String to) {
    return '$from থেকে $to-এর মধ্যে একটি সঠিক তারিখ বেছে নিন।';
  }

  @override
  String get uiDateInvalid =>
      'একটি সঠিক তারিখ, 0 থেকে 23-এর মধ্যে ঘণ্টা এবং 0 থেকে 59-এর মধ্যে মিনিট লিখুন।';

  @override
  String uiDateChoose(String from, String to) {
    return '$from থেকে $to-এর মধ্যে একটি তারিখ বেছে নিন।';
  }

  @override
  String uiRange(String from, String to) {
    return '$from থেকে $to';
  }

  @override
  String get uiYear => 'বছর';

  @override
  String get uiMonth => 'মাস';

  @override
  String get uiDay => 'দিন';

  @override
  String get uiHour => 'ঘণ্টা';

  @override
  String get uiMinute => 'মিনিট';

  @override
  String uiDateFieldEmpty(String name, String range) {
    return '$name, $range, এখন খালি';
  }

  @override
  String uiDateFieldValue(String name, String range, String value) {
    return '$name, $range, এখন $value';
  }

  @override
  String uiDateScreen(String from, String to) {
    return 'ফোনের স্থানীয় সময়ে তারিখ ও সময় সেট করুন। $from থেকে $to-এর মধ্যে একটি তারিখ বেছে নিন।';
  }

  @override
  String get uiSaveDateTime => 'তারিখ ও সময় সেভ করুন';

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
    return '$label: $value, $total-এর মধ্যে $position';
  }

  @override
  String uiChoiceChange(String description) {
    return '$description। বদলাতে বাম বা ডান ব্যবহার করুন';
  }

  @override
  String get startupPreferencesFailed =>
      'কিছু পছন্দের সেটিং লোড করা যায়নি। ডিফল্ট সেটিং ব্যবহার করা হচ্ছে।';

  @override
  String get startupNotificationsTitle => 'সেশন বিজ্ঞপ্তি';

  @override
  String get startupNotificationsMessage =>
      'সেশনের আমন্ত্রণ ও আপডেট জানাতে SEEDS বিজ্ঞপ্তি ব্যবহার করে। আপনি এখন নয় বেছে নিলেও অ্যাপটি ব্যবহার করতে পারবেন।';

  @override
  String get startupEnableNotifications => 'বিজ্ঞপ্তি চালু করুন';

  @override
  String get startupLoading => 'SEEDS লোড হচ্ছে';

  @override
  String get startupWelcomeScreenName => 'SEEDS-এ স্বাগতম';

  @override
  String get startupLoginButton => 'লগইন, বোতাম';

  @override
  String get startupRegisterButton => 'নিবন্ধন, বোতাম';

  @override
  String get startupSettingsButton => 'সেটিংস, বোতাম';

  @override
  String get startupRepeatInstructionsButton => 'নির্দেশ আবার শুনুন, বোতাম';

  @override
  String get authSimAutofillOptional => 'SIM থেকে ফোন নম্বর নিজে ভরানো ঐচ্ছিক';

  @override
  String get authRegisteredNowLogIn =>
      'নিবন্ধন হয়েছে। এখন সাইন ইন করুন। ফোন নম্বরের ঘর। সাহায্যের জন্য স্টার টিপুন।';

  @override
  String get authSimUnavailableOnDevice =>
      'এই ফোনে SIM থেকে পরামর্শ পাওয়া যায় না। ফোন নম্বর নিজে লিখুন।';

  @override
  String get authSimDialogTitle => 'ঐচ্ছিক SIM অটোফিল';

  @override
  String get authSimDialogMessage =>
      'এই ফোন থেকে ঐচ্ছিক ফোন নম্বরের পরামর্শ পড়বেন? ফোনের ঘরে বসানোর আগে আপনি একটি পরামর্শ বেছে নেবেন। এটি যাচাই করে না অ্যাকাউন্টটি কার। সাইন ইন, নিবন্ধন, Wi-Fi বা সেশনে যোগ দিতে কখনোই SIM-এর অনুমতি লাগে না।';

  @override
  String get authSimDialogConfirm => 'SIM পরামর্শ পড়ুন';

  @override
  String get authSimAutofillSkipped =>
      'SIM অটোফিল বাদ দেওয়া হয়েছে। ফোন নম্বর নিজে লিখুন।';

  @override
  String get authSimDetecting => 'SIM কার্ড খোঁজা হচ্ছে...';

  @override
  String get authSimAutofillUnavailable =>
      'SIM অটোফিল পাওয়া যাচ্ছে না। ফোন নম্বর নিজে লিখুন।';

  @override
  String get authSimNoneFound =>
      'কোনো SIM কার্ড পাওয়া যায়নি। ফোন নম্বর নিজে লিখুন।';

  @override
  String authSimCardsDetected(String count) {
    return '$countটি SIM কার্ড পাওয়া গেছে। অনুগ্রহ করে একটি বেছে নিন।';
  }

  @override
  String get authSimSuggestionUnavailable =>
      'SIM পরামর্শ পাওয়া যাচ্ছে না। ফোন নম্বর নিজে লিখুন।';

  @override
  String authSimOptionLabel(String number, String carrier) {
    return 'SIM $number, $carrier';
  }

  @override
  String get authSimUnknownCarrier => 'অজানা নেটওয়ার্ক';

  @override
  String get authSimSelectedFilled =>
      'বেছে নেওয়া পরামর্শ বসানো হয়েছে। এটি অ্যাকাউন্টের মালিকানার প্রমাণ নয়।';

  @override
  String get authSimSuggestionFilledSpoken =>
      'ফোন নম্বরের পরামর্শ বসানো হয়েছে। সাইন ইন করতে আপনার পাসওয়ার্ড লিখুন। কোনো সাইন ইন পাঠানো হয়নি।';

  @override
  String get authErrorEnterPhone => 'আপনার ফোন নম্বর লিখুন।';

  @override
  String get authErrorInvalidPhone => 'একটি সঠিক 10 অঙ্কের ফোন নম্বর লিখুন।';

  @override
  String get authErrorEnterPassword => 'আপনার পাসওয়ার্ড লিখুন।';

  @override
  String get authErrorPasswordTooShort =>
      'পাসওয়ার্ড কমপক্ষে 6 অক্ষরের হতে হবে।';

  @override
  String get authErrorInvalidServerResponse => 'সার্ভার থেকে ভুল উত্তর এসেছে';

  @override
  String get authErrorNotRegisteredAdmin =>
      'এই ফোন নম্বরটি প্রশাসক অ্যাকাউন্ট হিসেবে নিবন্ধিত নয়। অ্যাকাউন্টের ধরন বেছে নিতে 1, 2 বা 3 টিপুন।';

  @override
  String get authErrorNotRegisteredTeacher =>
      'এই ফোন নম্বরটি শিক্ষক অ্যাকাউন্ট হিসেবে নিবন্ধিত নয়। অ্যাকাউন্টের ধরন বেছে নিতে 1, 2 বা 3 টিপুন।';

  @override
  String get authErrorNotRegisteredStudent =>
      'এই ফোন নম্বরটি শিক্ষার্থী অ্যাকাউন্ট হিসেবে নিবন্ধিত নয়। অ্যাকাউন্টের ধরন বেছে নিতে 1, 2 বা 3 টিপুন।';

  @override
  String get authErrorResponseNotVerified =>
      'সাইন ইনের উত্তর যাচাই করা যায়নি। অনুগ্রহ করে আবার চেষ্টা করুন।';

  @override
  String authErrorMovedToPhone(String message) {
    return '$message ফোন নম্বরের ঘরে যাওয়া হয়েছে।';
  }

  @override
  String authErrorMovedToAccountType(String message) {
    return '$message অ্যাকাউন্টের ধরনে যাওয়া হয়েছে।';
  }

  @override
  String authErrorMovedToPassword(String message) {
    return '$message পাসওয়ার্ডের ঘরে যাওয়া হয়েছে।';
  }

  @override
  String get authRoleAdministrator => 'প্রশাসক';

  @override
  String get authRoleTeacher => 'শিক্ষক';

  @override
  String get authRoleStudent => 'শিক্ষার্থী';

  @override
  String get authRecoveryStep1 =>
      'আপনার পাসওয়ার্ড রিসেট করতে স্কুলের প্রশাসককে বলুন। তাঁকে সামনাসামনি দেখে নিশ্চিত হতে হবে আপনি কে। শুধু ফোন নম্বর বা SIM দিয়ে তা প্রমাণ হয় না। আপনার স্থায়ী পাসওয়ার্ড কখনো কাউকে পাঠাবেন না।';

  @override
  String get authRecoveryStep2 =>
      'প্রশাসক আপনাকে একটি গোপন 12 অঙ্কের অস্থায়ী পাসওয়ার্ড দেবেন। এটি 24 ঘণ্টা কাজ করে। মেয়াদ শেষ হলে নতুন একটি চেয়ে নিন।';

  @override
  String get authRecoveryStep3 =>
      'আপনার ফোন নম্বর এবং অস্থায়ী পাসওয়ার্ড দিয়ে সাইন ইন করুন, তারপর একটি নতুন পাসওয়ার্ড বেছে নিন।';

  @override
  String get authRecoveryStep4 =>
      '10 বার ভুল চেষ্টার পর, সাইন ইন 15 মিনিটের জন্য বন্ধ থাকে। পুনরুদ্ধারের জন্য ইন্টারনেট লাগে। অন্য ফোনে আগে থেকে থাকা ফাইল সঙ্গে সঙ্গে মুছে যায় না।';

  @override
  String get authRecoveryHelpTitle => 'পাসওয়ার্ড পুনরুদ্ধারের সাহায্য';

  @override
  String authRecoveryHelpIntro(String count) {
    return '$countটি ছোট ধাপ। প্রতিটি ধাপ শুনতে নিচে টিপুন।';
  }

  @override
  String get authBackToLogin => 'সাইন ইনে ফিরে যান';

  @override
  String get authBackToLoginButton => 'সাইন ইনে ফিরে যান, বোতাম';

  @override
  String get notesRecordingStarted =>
      'রেকর্ডিং শুরু হয়েছে। শেষ হলে রেকর্ডিং থামান বেছে নিন।';

  @override
  String get notesActionNotConfirmed =>
      'নোটের এই কাজটি নিশ্চিত করা যায়নি। স্টোরেজ, মাইক্রোফোনের অনুমতি বা সংযোগ দেখুন। আপনার খসড়া রাখা আছে।';

  @override
  String get notesNoneYet => 'এখনও কোনো ব্যক্তিগত নোট নেই।';

  @override
  String notesLoaded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি ব্যক্তিগত নোট লোড হয়েছে।',
      one: '1টি ব্যক্তিগত নোট লোড হয়েছে।',
    );
    return '$_temp0';
  }

  @override
  String get notesNameDialogTitle => 'ব্যক্তিগত নোটের নাম দিন';

  @override
  String get notesDefaultTitle => 'ব্যক্তিগত নোট';

  @override
  String notesDefaultLessonTitle(String lesson) {
    return '$lesson-এর জন্য নোট';
  }

  @override
  String get notesRecordConfirmTitle => 'ব্যক্তিগত নোট রেকর্ড করবেন?';

  @override
  String notesRecordConfirmMessage(String lessonPoint) {
    return 'শুধু এই ফোনে মাইক্রোফোনের অডিও রেকর্ড হবে, সর্বোচ্চ পাঁচ মিনিট বা নোটের আলাদা 10 MB সীমার বাকি অংশ পর্যন্ত। কথা বলে নিয়ন্ত্রণ ব্যবহারের আগে রেকর্ডিং থামান। অ্যাপের কণ্ঠস্বর, এই স্ক্রিন ছেড়ে যাওয়া বা অ্যাপে বাধা এলে রেকর্ডিং থেমে যাবে। লাইভ সেশনের সময় রেকর্ডিং করা যাবে না। $lessonPoint স্বয়ংক্রিয়ভাবে আপলোড বা শেয়ার হবে না। মাইক্রোফোনের অনুমতি চাওয়া হতে পারে।';
  }

  @override
  String notesLessonPointSeconds(String seconds) {
    return 'পাঠের জায়গা: $seconds সেকেন্ড।';
  }

  @override
  String get notesStartRecording => 'রেকর্ডিং শুরু করুন';

  @override
  String get notesDoNotRecord => 'রেকর্ড করবেন না';

  @override
  String get notesReviewStoppedChanged =>
      'স্ক্রিন বা অ্যাপ বদলে যাওয়ায় দেখা থেমে গেছে। দেখতে এই নোটটি আবার খুলুন।';

  @override
  String get notesReviewStoppedAccount =>
      'আপনার অ্যাকাউন্ট বদলে যাওয়ায় দেখা থেমে গেছে। ব্যক্তিগত নোট আবার খুলুন।';

  @override
  String get notesRenameDialogTitle => 'ব্যক্তিগত নোটের নাম বদলান';

  @override
  String notesRemoveTitle(String title) {
    return '$title সরাবেন?';
  }

  @override
  String notesRemoveMessage(String title) {
    return 'এই ফোনে এই অ্যাকাউন্ট থেকে শুধু $title সরাবেন? অন্য নোট, শেখার অগ্রগতি ও বুকমার্ক রাখা থাকবে। আগে প্রকাশ করা হয়ে থাকলে, অনলাইন রেকর্ডিং ও ডাউনলোড করা কপি সরানো হবে না।';
  }

  @override
  String get notesRemoveSelected => 'বেছে নেওয়া নোট সরান';

  @override
  String get notesKeepNote => 'নোট রাখুন';

  @override
  String notesRemoved(String title) {
    return '$title সরানো হয়েছে। অন্য নোট ও শেখার অগ্রগতি রাখা আছে।';
  }

  @override
  String get notesReviewBeforePublish =>
      'প্রকাশের আগে এই নোটটি ব্যক্তিগতভাবে চালিয়ে দেখে নিন।';

  @override
  String get notesSignInAsTeacher => 'প্রকাশের আগে শিক্ষক হিসেবে সাইন ইন করুন।';

  @override
  String get notesNoWorkspace =>
      'কোনো অনুমোদিত ক্লাস/বিষয় ওয়ার্কস্পেস নিশ্চিত হয়নি। আপনার খসড়া রাখা আছে।';

  @override
  String get notesPublishTitle => 'দেখে নেওয়া নোটটি ক্লাসে প্রকাশ করবেন?';

  @override
  String notesPublishMessage(
    String title,
    String className,
    String subjectName,
  ) {
    return 'নিশ্চিত করুন যে আপনি $title দেখে নিয়েছেন এবং এটি $className, $subjectName-এ প্রকাশ করতে চান। অনুমোদিত ক্লাস সদস্যরা এটি স্ট্রিম বা ডাউনলোড করে সর্বোচ্চ 30 দিন অফলাইনে রাখতে পারবে। সংযোগহীন কপি সঙ্গে সঙ্গে ফিরিয়ে নেওয়া যায় না। আপনার ফোনের খসড়া থেকে যাবে। নিশ্চিত না হওয়া আপলোড হয়তো আগেই প্রকাশিত হয়ে গেছে; একই জিনিস দুবার এড়াতে আবার চেষ্টার আগে লাইব্রেরি দেখে নিন।';
  }

  @override
  String get notesPublishConfirm => 'বেছে নেওয়া ক্লাসে প্রকাশ করুন';

  @override
  String get notesKeepDraftPrivate => 'খসড়া ব্যক্তিগত রাখুন';

  @override
  String get notesSignInChanged => 'সাইন ইন বদলে গেছে। খসড়া পাঠানো হয়নি।';

  @override
  String get notesAccountChangedBeforePublish =>
      'প্রকাশ নিশ্চিত হওয়ার আগেই আপনার অ্যাকাউন্ট বদলে গেছে। আবার চেষ্টার আগে আগের শিক্ষকের লাইব্রেরি দেখে নিন।';

  @override
  String get notesPublishNotConfirmed =>
      'প্রকাশ নিশ্চিত হয়নি। আবার চেষ্টার আগে ক্লাসের লাইব্রেরি দেখে নিন; আপনার ব্যক্তিগত খসড়া রাখা আছে।';

  @override
  String get notesPublishUnreadable =>
      'প্রকাশের নিশ্চিতকরণ পড়া যায়নি। আবার চেষ্টার আগে লাইব্রেরি দেখে নিন; আপনার খসড়া রাখা আছে।';

  @override
  String get notesPublishIdentityMismatch =>
      'প্রকাশের পরিচয় মেলেনি। আবার চেষ্টার আগে লাইব্রেরি দেখে নিন; আপনার খসড়া রাখা আছে।';

  @override
  String notesPublished(String audioId) {
    return 'রেকর্ডিং $audioId হিসেবে প্রকাশিত হয়েছে। আপনার ফোনের খসড়া রাখা আছে। আরেকটি রেকর্ডিং না চাইলে আবার প্রকাশ করবেন না।';
  }

  @override
  String get notesStopBeforeLeaving =>
      'রেকর্ডিং থামানো নিশ্চিত হয়নি। ছেড়ে যাওয়ার আগে আবার থামান বা অ্যাপটি ব্যাকগ্রাউন্ডে পাঠান।';

  @override
  String get notesRules =>
      'ব্যক্তিগত নোটের নিয়ম। প্রতিটি নোট সর্বোচ্চ পাঁচ মিনিটের হতে পারে। প্রতিটি অ্যাকাউন্টের নোটের জন্য আলাদা 10 মেগাবাইট জায়গা আছে। আপনি নিশ্চিত করলে তবেই রেকর্ডিং শুরু হয়, আর লাইভ সেশনের ভিতরে কখনও হয় না। অ্যাপের কণ্ঠস্বর, এই স্ক্রিন ছেড়ে যাওয়া বা কোনো বাধা এলে রেকর্ডিং থেমে যায়, তাই কথা বলা নিয়ন্ত্রণ ব্যবহারের আগে রেকর্ডিং বন্ধ করুন। শিক্ষার্থীর নোট এই ফোনেই ব্যক্তিগত থাকে। শিক্ষকের খসড়া প্রকাশের আগে শুনে দেখে নিশ্চিত করতে হবে। লগ আউট করার পরেও নোট রাখা থাকে।';

  @override
  String notesRecordingFor(String duration) {
    return '$duration ধরে রেকর্ডিং চলছে।';
  }

  @override
  String notesUsage(String megabytes) {
    return '10 MB ব্যক্তিগত নোটের মধ্যে $megabytes ব্যবহার হয়েছে।';
  }

  @override
  String authRecoveryStepListItem(String number, String step) {
    return '$number. $step';
  }

  @override
  String get authBackToLoginKey => '0: সাইন ইনে ফিরে যান';

  @override
  String get authRoleRowSelected => 'বেছে নেওয়া হয়েছে';

  @override
  String get authLoginScreenName => 'সাইন ইন স্ক্রিন';

  @override
  String get authLoginNavigationSections =>
      'ফোন নম্বর, পাসওয়ার্ড, অ্যাকাউন্টের ধরন, সাইন ইন, নিবন্ধন, SIM পরামর্শ এবং পুনরুদ্ধারের সাহায্য';

  @override
  String get authLoginKeySimLabel => 'ঐচ্ছিক SIM ফোন নম্বরের পরামর্শ পড়ুন';

  @override
  String get authLoginKeyRecoveryLabel =>
      'স্কুল প্রশাসকের মাধ্যমে পাসওয়ার্ড পুনরুদ্ধারের সাহায্য';

  @override
  String get authPhoneNumberField => 'ফোন নম্বরের ঘর';

  @override
  String get authPasswordField => 'পাসওয়ার্ডের ঘর';

  @override
  String get authHidePassword => 'পাসওয়ার্ড লুকান';

  @override
  String get authShowPassword => 'পাসওয়ার্ড দেখান';

  @override
  String authRoleFieldNavLabel(String role) {
    return 'অ্যাকাউন্টের ধরন: $role, বেছে নেওয়া হয়েছে। বদলাতে 1, 2 বা 3 টিপুন, অথবা বাঁ ও ডান ব্যবহার করুন';
  }

  @override
  String authLoginAsButton(String role) {
    return '$role হিসেবে সাইন ইন করুন, বোতাম';
  }

  @override
  String get authRegisterNewAccountButton =>
      'নতুন অ্যাকাউন্ট নিবন্ধন করুন, বোতাম';

  @override
  String get authSimSuggestionsTargetLabel =>
      'ঐচ্ছিক SIM ফোন নম্বরের পরামর্শ পড়ুন। নিজে লেখা সবসময় কাজ করে।';

  @override
  String get authForgotPasswordTargetLabel =>
      'পাসওয়ার্ড ভুলে গেছেন? স্কুল প্রশাসকের মাধ্যমে পুনরুদ্ধারের সাহায্য';

  @override
  String get authWelcomeBack => 'আবার স্বাগতম';

  @override
  String get authRegisteredBanner => 'নিবন্ধন হয়েছে। এখন সাইন ইন করুন।';

  @override
  String get authPhoneNumber => 'ফোন নম্বর';

  @override
  String get authPassword => 'পাসওয়ার্ড';

  @override
  String get authAccountType => 'অ্যাকাউন্টের ধরন';

  @override
  String authRoleFieldValue(String role) {
    return '$role, বেছে নেওয়া হয়েছে। বদলাতে 1, 2 বা 3 টিপুন';
  }

  @override
  String get authRoleOptionStudent => '1 শিক্ষার্থী';

  @override
  String get authRoleOptionTeacher => '2 শিক্ষক';

  @override
  String get authRoleOptionAdmin => '3 প্রশাসক';

  @override
  String get authSigningIn => 'সাইন ইন হচ্ছে, অনুগ্রহ করে অপেক্ষা করুন';

  @override
  String authLoginAsKey(String role) {
    return '4: $role হিসেবে সাইন ইন করুন';
  }

  @override
  String get authNoAccountRegisterKey => '5: অ্যাকাউন্ট নেই? নিবন্ধন করুন';

  @override
  String get authReadSimSuggestionsKey => '6: ঐচ্ছিক SIM পরামর্শ পড়ুন';

  @override
  String get authForgotPasswordKey =>
      '7: পাসওয়ার্ড ভুলে গেছেন? পুনরুদ্ধারের সাহায্য';

  @override
  String authErrorMovedToName(String message) {
    return '$message নামের ঘরে যাওয়া হয়েছে।';
  }

  @override
  String get authErrorEnterName => 'আপনার নাম লিখুন।';

  @override
  String get authErrorEnterAPassword => 'একটি পাসওয়ার্ড লিখুন।';

  @override
  String get authRegisteringAsTeacher => 'শিক্ষক হিসেবে নিবন্ধন হচ্ছে';

  @override
  String get authRegisteringAsStudent => 'শিক্ষার্থী হিসেবে নিবন্ধন হচ্ছে';

  @override
  String get authRegistrationScreenName => 'নিবন্ধন স্ক্রিন';

  @override
  String get authRegisterNavigationSections =>
      'নাম, ফোন নম্বর, পাসওয়ার্ড, শিক্ষার্থী বা শিক্ষক অ্যাকাউন্টের ধরন, নিবন্ধন এবং সাইন ইন';

  @override
  String get authNameField => 'নামের ঘর';

  @override
  String get authRegisterRoleTeacherLabel =>
      'অ্যাকাউন্টের ধরন: শিক্ষক। শিক্ষার্থীতে বদলাতে ওকে বা 3 টিপুন';

  @override
  String get authRegisterRoleStudentLabel =>
      'অ্যাকাউন্টের ধরন: শিক্ষার্থী। শিক্ষকে বদলাতে ওকে বা 3 টিপুন';

  @override
  String get authRegisterAsTeacherButton => 'শিক্ষক হিসেবে নিবন্ধন করুন, বোতাম';

  @override
  String get authRegisterAsStudentButton =>
      'শিক্ষার্থী হিসেবে নিবন্ধন করুন, বোতাম';

  @override
  String get authGoToLoginLabel => 'আগে থেকেই অ্যাকাউন্ট আছে? সাইন ইনে যান';

  @override
  String get authRegisterTitle => 'নিবন্ধন';

  @override
  String get authName => 'নাম';

  @override
  String get authRegisterAsTeacherKey =>
      '3: শিক্ষক হিসেবে নিবন্ধন। অ্যাকাউন্টের ধরন বদলান';

  @override
  String get authRegisterAsStudentKey =>
      '3: শিক্ষার্থী হিসেবে নিবন্ধন। অ্যাকাউন্টের ধরন বদলান';

  @override
  String get authRegisteringPleaseWait =>
      'নিবন্ধন হচ্ছে, অনুগ্রহ করে অপেক্ষা করুন';

  @override
  String get authRegisterKey => '1: নিবন্ধন করুন';

  @override
  String get authHaveAccountLoginKey =>
      '2: আগে থেকেই অ্যাকাউন্ট আছে? সাইন ইন করুন';

  @override
  String get authChangePasswordBusy =>
      'সংরক্ষণ হচ্ছে। পাসওয়ার্ড বদলের নিশ্চিতকরণের অপেক্ষা চলছে।';

  @override
  String get authChangePasswordErrorEnterTemporary =>
      'আপনার অস্থায়ী কোড লিখুন। সেই ঘরে যাওয়া হয়েছে।';

  @override
  String get authChangePasswordErrorTooShort =>
      'কমপক্ষে 6 অক্ষরের একটি নতুন পাসওয়ার্ড লিখুন। নতুন পাসওয়ার্ডের ঘরে যাওয়া হয়েছে।';

  @override
  String get authChangePasswordErrorMismatch =>
      'নতুন পাসওয়ার্ড দুটি মিলছে না। নতুন পাসওয়ার্ড আবার লেখার ঘরে যাওয়া হয়েছে।';

  @override
  String get authChangePasswordErrorSameAsTemporary =>
      'অস্থায়ী কোড থেকে আলাদা একটি পাসওয়ার্ড বেছে নিন। নতুন পাসওয়ার্ডের ঘরে যাওয়া হয়েছে।';

  @override
  String get authChangePasswordSessionInactive =>
      'এই পুনরুদ্ধার সেশন আর চালু নেই। আবার সাইন ইন করুন।';

  @override
  String get authChangePasswordAccountChanged =>
      'আপনার অ্যাকাউন্ট বদলে গেছে। কোনো নতুন সাইন ইন সংরক্ষণ করা হয়নি।';

  @override
  String authChangePasswordNotConfirmed(String message) {
    return '$message পাসওয়ার্ড বদল নিশ্চিত হয়নি। সংযোগ ব্যর্থ হলে, আবার রিসেট চাওয়ার আগে নতুন পাসওয়ার্ড দিয়ে সাইন ইন করে দেখুন।';
  }

  @override
  String get authChangePasswordResponseNotVerified =>
      'পাসওয়ার্ড বদলের উত্তর যাচাই করা যায়নি। নতুন পাসওয়ার্ড দিয়ে আবার সাইন ইন করে দেখুন।';

  @override
  String get authChangePasswordReplacementNotVerified =>
      'নতুন সাইন ইন যাচাই করা যায়নি। নতুন পাসওয়ার্ড দিয়ে আবার সাইন ইন করুন।';

  @override
  String get authChangePasswordSignInNotSaved =>
      'আপনার সাইন ইন সংরক্ষণ করা যায়নি। নতুন পাসওয়ার্ড দিয়ে আবার সাইন ইন করুন।';

  @override
  String get authChangePasswordSignInNotSavedOnPhone =>
      'আপনার সাইন ইন এই ফোনে সংরক্ষণ করা যায়নি। নতুন পাসওয়ার্ড দিয়ে আবার সাইন ইন করুন।';

  @override
  String get authTemporaryCredential => 'অস্থায়ী কোড';

  @override
  String get authNewPassword => 'নতুন পাসওয়ার্ড';

  @override
  String get authRepeatNewPassword => 'নতুন পাসওয়ার্ড আবার লিখুন';

  @override
  String get authChangePasswordScreenName => 'অস্থায়ী পাসওয়ার্ড বদলান';

  @override
  String get authChangePasswordIntro =>
      'আপনার প্রশাসকের দেওয়া অস্থায়ী কোড লিখুন, তারপর কমপক্ষে 6 অক্ষরের একটি নতুন পাসওয়ার্ড দুবার লিখুন। ইন্টারনেট লাগবে। নতুন পাসওয়ার্ড নিশ্চিত হওয়ার পর ড্যাশবোর্ড খুলবে।';

  @override
  String get authSaveNewPassword => 'নতুন পাসওয়ার্ড সংরক্ষণ করুন';

  @override
  String get authSignOut => 'লগ আউট';

  @override
  String get authTemporaryCredentialField => 'অস্থায়ী কোড। লুকানো লেখা।';

  @override
  String get authNewPasswordField =>
      'নতুন পাসওয়ার্ড। কমপক্ষে 6 অক্ষর। লুকানো লেখা।';

  @override
  String get authRepeatNewPasswordField =>
      'নতুন পাসওয়ার্ড আবার লিখুন। লুকানো লেখা।';

  @override
  String get authSaveNewPasswordButton => 'নতুন পাসওয়ার্ড সংরক্ষণ করুন, বোতাম';

  @override
  String get authSignOutConfirmButton => 'লগ আউট, নিশ্চিত করতে বলবে';

  @override
  String get authChangePasswordTitle => 'পাসওয়ার্ড বদলান';

  @override
  String get authChangePasswordInfo =>
      'আপনার স্কুলের প্রশাসক একটি অস্থায়ী কোড দিয়েছেন। এটি 24 ঘণ্টা থাকে। 10 বার ভুল চেষ্টার পর, সাইন ইন 15 মিনিটের জন্য বন্ধ থাকে। কমপক্ষে 6 অক্ষরের একটি আলাদা পাসওয়ার্ড বেছে নিন। এর জন্য ইন্টারনেট লাগে।';

  @override
  String get authSignOutKey => '0: লগ আউট';

  @override
  String authSimOptionValid(String label, String digits) {
    return '$label। ফোন নম্বর $digits। ফোনের ঘরে বসাতে ওকে টিপুন।';
  }

  @override
  String authSimOptionInvalid(String label) {
    return '$label। নম্বর পাওয়া যাচ্ছে না। ফোন নম্বর নিজে লিখুন।';
  }

  @override
  String get authSimInvalidSuggestion =>
      'এই SIM থেকে কোনো সঠিক ফোন নম্বরের পরামর্শ পাওয়া যায় না। নিজে লেখা এখনও কাজ করে।';

  @override
  String get authSimChooseScreenName =>
      'একটি ঐচ্ছিক SIM পরামর্শ বেছে নিন। প্রতিটি SIM শুনতে উপর ও নিচে ব্যবহার করুন, তারপর বেছে নিতে ওকে টিপুন। এটি অ্যাকাউন্ট যাচাই নয়।';

  @override
  String get authSimCancelLabel => 'ফোন নম্বর না বদলে বাতিল করুন';

  @override
  String get authSimChooseTitle => 'SIM পরামর্শ বেছে নিন';

  @override
  String get authSimChooseInfo =>
      'বেছে নিলে শুধু ফোনের ঘর ভরে যায়। আপনার পাসওয়ার্ড তবুও লাগবে। বাতিল করলে নিজে লেখা অংশ একই থাকে।';

  @override
  String get authSimCancelKey => '0: বাতিল';

  @override
  String get inviteStatusInvited => 'আমন্ত্রিত';

  @override
  String get inviteStatusNotInvited => 'আমন্ত্রণ করা হয়নি। আমন্ত্রণ করতে ওকে';

  @override
  String get inviteTitle => 'শিক্ষার্থীদের আমন্ত্রণ করুন';

  @override
  String get inviteTooltipBack => '0: সেশনে ফিরে যান';

  @override
  String get inviteTooltipRefresh => '1: শিক্ষার্থী তালিকা রিফ্রেশ করুন';

  @override
  String get inviteInvitingTo => 'শিক্ষার্থীদের এখানে আমন্ত্রণ করা হচ্ছে:';

  @override
  String inviteInvitedCount(String invited, String total) {
    return '$total জনের মধ্যে $invited জন আমন্ত্রিত';
  }

  @override
  String get inviteAllButton => '2: সব শিক্ষার্থীকে আমন্ত্রণ করুন';

  @override
  String get inviteSearchField => 'নাম বা ফোন নম্বর দিয়ে খুঁজুন';

  @override
  String get inviteSearchHelper => 'সব শিক্ষার্থীর তালিকা দেখতে খালি রাখুন';

  @override
  String get inviteLoadingStudents => 'শিক্ষার্থীদের লোড করা হচ্ছে';

  @override
  String get inviteNoMatchShort =>
      'কোনো শিক্ষার্থী মেলেনি। সবার তালিকা দেখতে খোঁজা মুছে দিন।';

  @override
  String get libraryUploadTitleField => 'শিরোনাম *';

  @override
  String get libraryUploadDescriptionField => 'বিবরণ';

  @override
  String get libraryCancelKey0Button => 'বাতিল (0)';

  @override
  String get libraryUploadKey3Button => 'আপলোড (3)';

  @override
  String get libraryConfirmKey1Button => 'নিশ্চিত করুন (1)';

  @override
  String librarySessionNumber(String id) {
    return 'সেশন #$id';
  }

  @override
  String get libraryKey5PauseForClass => '5: ক্লাসের জন্য থামান';

  @override
  String get libraryKey5PlayForClass => '5: ক্লাসের জন্য চালান';

  @override
  String get libraryRecordingsSeekKeysHint =>
      '4: 10 সেকেন্ড পিছনে। 6: 10 সেকেন্ড সামনে।';

  @override
  String get libraryKey1ChooseRecording => '1: রেকর্ডিং বেছে নিন';

  @override
  String get libraryUploadingButton => 'আপলোড হচ্ছে';

  @override
  String get libraryKey2Upload => '2: আপলোড';

  @override
  String get libraryRecordingsFooterKeysHint =>
      '3: অবস্থা। *: সাহায্য। #: কথা বন্ধ করুন।';

  @override
  String get notesBackStopsRecording =>
      'ফিরে যান। আগে যেকোনো রেকর্ডিং বন্ধ করে';

  @override
  String get notesReadRules => 'নোটের নিয়ম শুনুন';

  @override
  String get notesRefreshPrivate => 'ব্যক্তিগত নোট রিফ্রেশ করুন';

  @override
  String get notesRecordAsksFirst =>
      'একটি ব্যক্তিগত নোট রেকর্ড করুন। আগে একটি নাম ও নিশ্চিতকরণ চাইবে';

  @override
  String get notesStopRecordingNow => 'এখনই রেকর্ডিং বন্ধ করুন';

  @override
  String get notesReadRecordingTimeStops =>
      'রেকর্ডিংয়ের সময় শুনুন। জোরে পড়লে রেকর্ডিং বন্ধ হয়ে যায়';

  @override
  String get notesReadPrivateStatus => 'ব্যক্তিগত নোটের অবস্থা শুনুন';

  @override
  String get notesStopPrivateReview => 'ব্যক্তিগতভাবে শোনা বন্ধ করুন';

  @override
  String notesStopReviewingTitle(String title) {
    return '$title শোনা বন্ধ করুন';
  }

  @override
  String get notesStopReviewingNote => 'নোট শোনা বন্ধ করুন';

  @override
  String notesReviewTitlePrivately(String title, String duration) {
    return '$title ব্যক্তিগতভাবে শুনে দেখুন। $duration।';
  }

  @override
  String notesReviewTitleIncomplete(String title) {
    return '$title ব্যক্তিগতভাবে শুনে দেখুন। অসম্পূর্ণ রেকর্ডিং; চালানো যাবে না।';
  }

  @override
  String notesRenameTitle(String title) {
    return '$title-এর নাম বদলান';
  }

  @override
  String notesPublishTitleAsks(String title) {
    return 'শুনে দেখা $title একটি ক্লাস ও বিষয়ে প্রকাশ করুন, নিশ্চিত করতে বলবে';
  }

  @override
  String notesRemoveTitleAsks(String title) {
    return '$title সরান, নিশ্চিত করতে বলবে';
  }

  @override
  String get notesScreenName => 'ব্যক্তিগত নোট';

  @override
  String get notesIntroduction =>
      'নোট কীভাবে রাখা হয় শুনতে \'নোটের নিয়ম শুনুন\' ব্যবহার করুন।';

  @override
  String get notesBack => 'ফিরে যান';

  @override
  String notesStorageSummary(String megabytes) {
    return '$megabytes / 10 MB ব্যক্তিগত নোট। পাঠের ডাউনলোড থেকে আলাদা। নিজে থেকে কিছু মোছা হয় না।';
  }

  @override
  String notesLessonContext(String title, String seconds) {
    return '$title। পাঠের যে জায়গা ধরা হয়েছে: $seconds সেকেন্ড।';
  }

  @override
  String notesRecordingTime(String time) {
    return 'রেকর্ডিংয়ের সময় $time';
  }

  @override
  String get notesRefreshNotes => 'নোট রিফ্রেশ করুন';

  @override
  String get notesRecordPrivateNote => 'একটি ব্যক্তিগত নোট রেকর্ড করুন';

  @override
  String get notesStopRecording => 'রেকর্ডিং বন্ধ করুন';

  @override
  String get notesReadRecordingTime => 'রেকর্ডিংয়ের সময় শুনুন';

  @override
  String get notesReadNoteStatus => 'নোটের অবস্থা শুনুন';

  @override
  String get notesStatusNeedsAttention => 'মনোযোগ দরকার';

  @override
  String get notesStatusIncomplete => 'অসম্পূর্ণ';

  @override
  String get notesStatusPlaying => 'চলছে';

  @override
  String get notesStatusReviewed => 'শুনে দেখা হয়েছে';

  @override
  String get notesStatusSaved => 'সেভ করা হয়েছে';

  @override
  String notesNoteSeconds(String seconds) {
    return '$seconds সেকেন্ড। এই ফোনের ব্যক্তিগত নোট।';
  }

  @override
  String get notesNoteIncomplete =>
      'বাধাপ্রাপ্ত বা অসম্পূর্ণ নোট। চালানো বা প্রকাশ করা যাবে না।';

  @override
  String notesNoteLessonPoint(String lesson, String seconds) {
    return 'পাঠ $lesson, জায়গা $seconds সেকেন্ড।';
  }

  @override
  String get notesReviewPlaying => 'শুনে দেখা চলছে';

  @override
  String get notesReviewPrivately => 'ব্যক্তিগতভাবে শুনে দেখুন';

  @override
  String get notesRename => 'নাম বদলান';

  @override
  String get notesPublishReviewedNote => 'শুনে দেখা নোট প্রকাশ করুন';

  @override
  String get notesEnterNameBeforeSaving => 'সেভ করার আগে একটি নাম লিখুন।';

  @override
  String notesNameDialogInstructions(String title) {
    return '$title। ওকে টিপলে লেখা শুরু হয়। উপর বা নিচ টিপলে লেখা থেকে বেরিয়ে আসবেন, তারপর সেভ বা বাতিল বেছে নিন।';
  }

  @override
  String get notesNoteName => 'নোটের নাম';

  @override
  String get notesSaveNoteName => 'নোটের নাম সেভ করুন';

  @override
  String get notesCancel => 'বাতিল';

  @override
  String get notesSaveName => 'নাম সেভ করুন';

  @override
  String notesWorkspaceLabel(String className, String subjectName) {
    return '$className, $subjectName';
  }

  @override
  String get notesChooseWorkspaceInstructions =>
      'প্রকাশের আগে একটি অনুমোদিত ক্লাস ও বিষয় বেছে নিন। পরের নিশ্চিতকরণের আগে কিছুই আপলোড হবে না।';

  @override
  String get notesCancelPublication => 'প্রকাশ বাতিল করুন';

  @override
  String get notesPublishWhichWorkspace => 'কোন ক্লাস ও বিষয়ে প্রকাশ করবেন?';

  @override
  String settingsDecrease(String setting) {
    return '$setting কমান';
  }

  @override
  String settingsIncrease(String setting) {
    return '$setting বাড়ান';
  }

  @override
  String get settingsResetTooltip => 'আগের অবস্থায় ফেরান';

  @override
  String get settingsSectionSpeech => 'কথা';

  @override
  String get settingsAppSpeechTitle => 'অ্যাপের কণ্ঠস্বর';

  @override
  String get settingsAppSpeechSubtitle =>
      'অ্যাপ স্ক্রিন এবং বার্তা পড়ে শোনায়';

  @override
  String settingsLanguageButton(String language) {
    return 'কথার ভাষা: $language';
  }

  @override
  String get settingsVolumeTitle => 'ভলিউম';

  @override
  String get settingsVolumeSubtitle => 'অ্যাপের কণ্ঠস্বর কত জোরে';

  @override
  String settingsPercentValue(String percent) {
    return '$percent শতাংশ';
  }

  @override
  String get settingsSpeedTitle => 'কথার গতি';

  @override
  String get settingsSpeedSubtitle =>
      'অ্যাপের কণ্ঠস্বর কত দ্রুত। কুইজ নিজের গতি ব্যবহার করতে পারে';

  @override
  String settingsTimesNormal(String speed) {
    return 'সাধারণের $speed গুণ';
  }

  @override
  String get settingsTestButton => '5: কণ্ঠস্বর পরীক্ষা করুন';

  @override
  String settingsNarrationButton(String level) {
    return 'বর্ণনার স্তর: $level';
  }

  @override
  String settingsCheckingVoice(String language) {
    return '$language কণ্ঠস্বর যাচাই হচ্ছে...';
  }

  @override
  String settingsCheckVoiceButton(String language) {
    return '7: $language কণ্ঠস্বর যাচাই করুন';
  }

  @override
  String get settingsStopButton => '#: কথা থামান';

  @override
  String get settingsSectionDisplay => 'ডিসপ্লে';

  @override
  String get settingsHighContrastTitle => 'হাই কনট্রাস্ট';

  @override
  String get settingsHighContrastSubtitle =>
      'আগে থেকেই চালু: কম দৃষ্টির জন্য কালোর উপর সাদা ও হলুদ';

  @override
  String get settingsTextSizeTitle => 'লেখার আকার';

  @override
  String get settingsTextSizeSubtitle =>
      'অ্যাপের লেখার আকার; ফোনের ফন্টের আকারও মানা হয়';

  @override
  String get settingsSectionKeys => 'কী এবং সাহায্য';

  @override
  String get settingsShortcutsTitle => 'কীপ্যাড শর্টকাট দেখান';

  @override
  String get settingsShortcutsSubtitle => 'বোতামে কী-এর নম্বর দেখান';

  @override
  String get settingsGlobalKeysHint =>
      'প্রতিটি স্ক্রিনে: 0 ফিরে যান, স্টার সাহায্য, হ্যাশ কথা থামান।';

  @override
  String get settingsVoiceCommandsTitle => 'ভয়েস কমান্ড';

  @override
  String get settingsVoiceCommandsSubtitle =>
      'সেশনে \'কমান্ড শুনুন\' চালু করুন। নিজে থেকে শোনা হয় না।';

  @override
  String get settingsSoundCuesTitle => '8: শব্দ সংকেত';

  @override
  String get settingsVibrationTitle => '9: ভাইব্রেশন';

  @override
  String get settingsVoiceHelpButton =>
      'ভয়েস কমান্ড সাহায্য: বলুন মিউট, আনমিউট, হাত তুলুন, হাত নামান, বেরিয়ে যান বা আবার বলুন।';

  @override
  String get uiSave => 'সেভ করুন';

  @override
  String get uiClose => 'বন্ধ করুন';

  @override
  String get learningLessonPositionLabel => 'পাঠের অবস্থান';

  @override
  String get learningReadStatusButton => 'শেখার অবস্থা শুনুন';

  @override
  String get learningAddBookmarkButton => 'বুকমার্ক যোগ করুন';

  @override
  String learningBookmarksButton(String count) {
    return 'বুকমার্ক ($count)';
  }

  @override
  String get learningPrivateNotesButton => 'পড়াশোনার ব্যক্তিগত নোট';

  @override
  String get learningSetAButton => 'A ঠিক করুন';

  @override
  String learningSetAAtButton(String time) {
    return 'A ঠিক করুন $time';
  }

  @override
  String get learningSetBButton => 'B ঠিক করুন';

  @override
  String learningSetBAtButton(String time) {
    return 'B ঠিক করুন $time';
  }

  @override
  String get learningRepeatOffButton => 'পুনরাবৃত্তি বন্ধ';

  @override
  String get learningRepeatOnButton => 'পুনরাবৃত্তি চালু';

  @override
  String get learningClearABButton => 'A-B মুছুন';

  @override
  String learningBackTenButton(String key) {
    return '$key: 10 সেকেন্ড পিছনে';
  }

  @override
  String learningForwardTenButton(String key) {
    return '$key: 10 সেকেন্ড সামনে';
  }

  @override
  String learningSlowerButton(String key) {
    return '$key: আরও ধীরে';
  }

  @override
  String learningFasterButton(String key) {
    return '$key: আরও দ্রুত';
  }

  @override
  String get learningRetrySavingButton => 'আবার সেভ করার চেষ্টা করুন';

  @override
  String get learningNameBookmarkTitle => 'বুকমার্কের নাম দিন';

  @override
  String get learningBookmarkNameFieldLabel => 'নাম';

  @override
  String get learningBookmarksTitle => 'বুকমার্ক';

  @override
  String get learningBookmarksLessonChanged =>
      'পাঠ বদলে গেছে। এই তালিকা বন্ধ করে বর্তমান পাঠের বুকমার্ক খুলুন।';

  @override
  String get learningBookmarksEmpty =>
      'এখনও কোনো বুকমার্ক নেই। যে জায়গা মনে রাখতে চান সেখানে \'বুকমার্ক যোগ করুন\' ব্যবহার করুন।';

  @override
  String get learningBookmarksUnavailable =>
      'সেভ করা বুকমার্ক পাওয়া যাচ্ছে না। সেভ করা অগ্রগতি ফিরে পেতে আবার সেভ করার চেষ্টা করুন।';

  @override
  String learningBookmarkAtButton(String label, String time) {
    return '$time-এ $label';
  }

  @override
  String learningRemoveBookmarkSemantics(String label) {
    return 'বুকমার্ক $label সরান';
  }

  @override
  String uiKeyedLabel(String key, String label) {
    return '$key: $label';
  }

  @override
  String get uiKeypadFooter => '*: সাহায্য। #: অ্যাপের কণ্ঠস্বর থামান।';

  @override
  String uiListSearchValue(String query) {
    return 'খোঁজা: $query';
  }

  @override
  String get uiListLoadingShort => 'লোড হচ্ছে। ফিরে যেতে 0 টিপুন।';

  @override
  String get keypadTextEditingHint =>
      'লেখার সময় কী টিপলে লেখা হয়। শেষ করতে ওকে টিপুন। ওকে টিপে লেখা শেষ না হলে উপর বা নিচ ব্যবহার করুন।';

  @override
  String get keypadWaitingConfirmation => 'নিশ্চিতকরণের অপেক্ষা চলছে।';

  @override
  String get keypadContinueKey1 => '1: এগিয়ে যান';

  @override
  String get keypadHidePasswordKey2 => '2: পাসওয়ার্ড লুকান';

  @override
  String get keypadShowPasswordKey2 => '2: পাসওয়ার্ড দেখান';

  @override
  String get keypadBackKey0 => '0: ফিরে যান';

  @override
  String uiKeyedLabelUnavailable(String number, String label) {
    return '$number: $label (পাওয়া যাচ্ছে না)';
  }

  @override
  String get journeyMenuReadDetailsKey8 => '8: বিবরণ আবার শুনুন';

  @override
  String get sessionTileHandRaised => 'হাত তোলা';

  @override
  String get sessionTileSpeaking => 'কথা বলছেন';

  @override
  String sessionRemoveFromSession(String name) {
    return '$name-কে সেশন থেকে সরান';
  }

  @override
  String get uiHourRange => 'ঘণ্টা (0 থেকে 23)';

  @override
  String get uiSetDateTimeTitle => 'তারিখ ও সময় সেট করুন';

  @override
  String get uiSetDateTimeHint =>
      'স্থানীয় সময় ব্যবহার করুন। প্রতিটি সংখ্যা বদলাতে ওকে টিপুন।';

  @override
  String quizExtraTitle(String name) {
    return 'অতিরিক্ত সময়: $name';
  }

  @override
  String get quizExtraInfo =>
      'শুধু ভবিষ্যতের চেষ্টার জন্য। আগের সময়সীমা বদলাবে না। কুইজ বন্ধের সময় তবুও প্রযোজ্য; দরকার হলে আলাদাভাবে সময় বাড়ান। শূন্য দিলে অতিরিক্ত মিনিট সরে যায়।';

  @override
  String get quizExtraMinutesField => 'অতিরিক্ত মিনিট';

  @override
  String get quizExtraSaveButton => 'ভবিষ্যতের অতিরিক্ত সময় সেভ করুন';

  @override
  String quizSpeedValue(String speed) {
    return 'কুইজের কথা বলার গতি: $speed×';
  }

  @override
  String get uiCancelKey0 => '0: বাতিল';

  @override
  String get uiSaveKey1 => '1: সেভ করুন';

  @override
  String get uiNone => 'কিছু নেই';

  @override
  String uiPreviousOf(String label) {
    return 'আগের $label';
  }

  @override
  String uiNextOf(String label) {
    return 'পরের $label';
  }

  @override
  String get journeyOpening => 'যাত্রা খোলা হচ্ছে';

  @override
  String journeyStepHeading(String position, String kind) {
    return '$position। $kind';
  }

  @override
  String journeyStepHeadingReplay(String position, String kind) {
    return '$position। $kind। আবার শুনছেন';
  }

  @override
  String journeyFirstTryShort(String correct, String total) {
    return 'প্রথম চেষ্টায় $totalটির মধ্যে $correctটি সঠিক।';
  }

  @override
  String get journeyLeaveKey0 => '0: যাত্রা ছেড়ে যান';

  @override
  String get quizRevisionsTitle => 'প্রশ্নের সংশোধন';

  @override
  String get quizRevisionsBackTooltip => 'প্রশ্নের সংশোধন থেকে ফিরে যান';

  @override
  String quizRevisionSectionHear(String section) {
    return '$section। শুনতে দুবার ট্যাপ করুন';
  }

  @override
  String get adminResetAttested => 'পরিচয় যাচাই নিশ্চিত করা হয়েছে।';

  @override
  String get adminResetNotAttested => 'পরিচয় যাচাই নিশ্চিত করা হয়নি।';

  @override
  String get adminResetConfirmTitle => 'এই পাসওয়ার্ড রিসেট করবেন?';

  @override
  String adminResetConfirmMessage(String name, String phone) {
    return '$name, ফোন $phone রিসেট করবেন? এতে পুরোনো পাসওয়ার্ড বদলে যাবে এবং অনলাইন সেশনগুলো শেষ হবে। ইন্টারনেট ছাড়া থাকা ডাউনলোড করা পাঠ সঙ্গে সঙ্গে বাতিল করা যায় না। আগের পাঠ, নোট ও শেখার রেকর্ড রাখা থাকবে। 12 অঙ্কের অস্থায়ী কোড 24 ঘণ্টা চলবে এবং পাসওয়ার্ড বদলাতে হবে। 10টি ভুল চেষ্টার পরে অস্থায়ী কোড দিয়ে সাইন ইন 15 মিনিটের জন্য থেমে যায়।';
  }

  @override
  String get adminResetKeepPassword => 'পাসওয়ার্ড রাখুন';

  @override
  String get adminResetResetPassword => 'পাসওয়ার্ড রিসেট করুন';

  @override
  String get adminResetSignInChanged =>
      'প্রশাসকের সাইন ইন বদলে গেছে। কোনো রিসেট পাঠানো হয়নি।';

  @override
  String get adminResetSending =>
      'রিসেট পাঠানো হচ্ছে। সার্ভারের নিশ্চিতকরণের অপেক্ষা।';

  @override
  String adminResetNotConfirmed(String reason) {
    return 'রিসেট নিশ্চিত হয়নি। $reason হয়তো এটি ইতিমধ্যে কার্যকর হয়ে গেছে। আবার রিসেট করার কথা ভাবার আগে বন্ধ করে এই অ্যাকাউন্ট রিফ্রেশ করুন।';
  }

  @override
  String get adminResetResponseNotVerified =>
      'রিসেটের উত্তর যাচাই করা যায়নি। পাসওয়ার্ড হয়তো ইতিমধ্যে বদলে গেছে। আবার রিসেট করার কথা ভাবার আগে বন্ধ করে রিফ্রেশ করুন।';

  @override
  String get adminResetConfirmedSpoken =>
      'পাসওয়ার্ড রিসেট নিশ্চিত হয়েছে। কোডটি লুকানো আছে। শুধু ব্যক্তিগত জায়গায় থাকলে \'কোড শুনুন\' ব্যবহার করুন। বন্ধ করলে এই কপি মুছে যাবে।';

  @override
  String get adminResetPhoneNotConfirmed =>
      'এই ফোনে রিসেট নিশ্চিত করা যায়নি। আবার রিসেট করার কথা ভাবার আগে বন্ধ করে অ্যাকাউন্ট রিফ্রেশ করুন।';

  @override
  String get adminResetStorageUnavailable =>
      'অ্যাকাউন্টের স্টোরেজ পাওয়া যাচ্ছে না। রিসেট করার কথা ভাবার আগে পুনরুদ্ধার বন্ধ করে SEEDS আবার চালু করুন।';

  @override
  String adminResetCredentialSpoken(String digits, String expires) {
    return 'অস্থায়ী কোড: $digits। মেয়াদ শেষ হবে $expires, UTC। যাচাই করা ব্যক্তিকে ব্যক্তিগতভাবে দিন। সাইন ইনের সময় এটি বদলাতে হবে।';
  }

  @override
  String get adminResetDiscardTitle => 'কোডের এই কপি মুছে ফেলবেন?';

  @override
  String get adminResetDiscardMessage =>
      'নিশ্চিত করুন যে আপনি অস্থায়ী কোডটি ব্যক্তিগতভাবে দিয়েছেন, অথবা মেনে নিন যে যাচাই করা প্রশাসককে আবার রিসেট করতে হবে। SEEDS এই কপি আর দেখাবে না। এতে সম্পন্ন রিসেট বাতিল হয় না।';

  @override
  String get adminResetKeepReviewing => 'দেখা চালিয়ে যান';

  @override
  String get adminResetCloseDiscard => 'বন্ধ করুন ও মুছে ফেলুন';

  @override
  String get adminResetScreenName =>
      'প্রশাসকের পাসওয়ার্ড পুনরুদ্ধার। রিসেট করার আগে SEEDS-এর বাইরে পরিচয় যাচাই করুন। স্পষ্টভাবে না চাওয়া পর্যন্ত কোড লুকানো থাকে।';

  @override
  String get adminResetCloseRecovery => 'পুনরুদ্ধার বন্ধ করুন';

  @override
  String get adminResetReadAccount => 'বেছে নেওয়া অ্যাকাউন্টের বিবরণ শুনুন';

  @override
  String adminResetAccountDetails(String name, String phone) {
    return '$name। ফোন $phone।';
  }

  @override
  String get adminResetIdentityChecked =>
      'SEEDS-এর বাইরে পরিচয় যাচাই হয়েছে। টিক দেওয়া। বদলাতে ওকে টিপুন।';

  @override
  String get adminResetIdentityNotChecked =>
      'SEEDS-এর বাইরে পরিচয় যাচাই হয়েছে। টিক দেওয়া নেই। বদলাতে ওকে টিপুন।';

  @override
  String get adminResetResetAndEnd =>
      'পাসওয়ার্ড রিসেট করুন এবং অনলাইন সেশন শেষ করুন';

  @override
  String get adminResetReadCredentialLabel =>
      'অস্থায়ী কোড শুনুন ও দেখান। শুধু ব্যক্তিগতভাবে ব্যবহার করুন।';

  @override
  String get adminResetCloseRefresh => 'বন্ধ করুন ও অ্যাকাউন্ট রিফ্রেশ করুন';

  @override
  String get adminResetTitle => 'পাসওয়ার্ড পুনরুদ্ধার';

  @override
  String get adminResetVerifyInfo =>
      'SEEDS-এর বাইরে ব্যক্তিটিকে যাচাই করুন। ফোন নম্বর বা SIM-এর পরামর্শ পরিচয় যাচাই নয়। শুধু একটি মেসেজ বা দাবি করা নামের ভিত্তিতে কখনও রিসেট করবেন না।';

  @override
  String get adminResetVerifiedCheckbox =>
      'আমি SEEDS-এর বাইরে এই ব্যক্তিকে যাচাই করেছি';

  @override
  String get adminResetWaiting => 'রিসেট নিশ্চিতকরণের অপেক্ষা।';

  @override
  String get adminResetConfirmedInfo =>
      'রিসেট নিশ্চিত হয়েছে। না চাওয়া পর্যন্ত কোড লুকানো থাকবে। এটি 24 ঘণ্টা চলবে। বন্ধ করলে এই কপি মুছে যাবে। ব্যক্তিগতভাবে দিন; কখনও ক্লাসে পোস্ট করবেন না।';

  @override
  String get adminResetRevealButton => 'ব্যক্তিগতভাবে কোড শুনুন ও দেখান';

  @override
  String adminResetCredentialShown(String digits, String expires) {
    return 'অস্থায়ী কোড: $digits\nমেয়াদ শেষ: $expires UTC';
  }

  @override
  String get adminResetCloseRefreshKey0 =>
      '0: বন্ধ করুন ও অ্যাকাউন্ট রিফ্রেশ করুন';

  @override
  String get apiTemporarySignInPaused =>
      'অস্থায়ী কোড দিয়ে সাইন ইন 15 মিনিটের জন্য থেমে আছে। পরে চেষ্টা করুন বা আপনার স্কুলের প্রশাসকের সঙ্গে যোগাযোগ করুন।';

  @override
  String get apiTemporaryCredentialExpired =>
      'আপনার অস্থায়ী কোডের মেয়াদ শেষ হয়ে গেছে। নতুন কোডের জন্য আপনার স্কুলের প্রশাসকের সঙ্গে যোগাযোগ করুন।';

  @override
  String get apiPasswordMustDiffer =>
      'অস্থায়ী কোড থেকে আলাদা একটি পাসওয়ার্ড বেছে নিন।';

  @override
  String get apiTemporaryCredentialRejected =>
      'অস্থায়ী কোডটি গ্রহণ করা হয়নি। দেখে নিয়ে আবার চেষ্টা করুন।';

  @override
  String get apiRecoverySignInExpired =>
      'আপনার পুনরুদ্ধার সাইন ইনের মেয়াদ শেষ হয়েছে বা বদলে গেছে। আবার সাইন ইন করুন।';

  @override
  String get apiCheckInformation => 'তথ্যগুলো দেখে নিয়ে আবার চেষ্টা করুন।';

  @override
  String get apiInvalidLogin => 'ফোন নম্বর বা পাসওয়ার্ড ভুল।';

  @override
  String get apiNoPermission => 'এটি করার অনুমতি আপনার নেই।';

  @override
  String get apiSessionNotFound =>
      'সেশন পাওয়া যায়নি। সেশন আইডি দেখে নিয়ে আবার চেষ্টা করুন।';

  @override
  String get apiItemNotFound => 'যেটি চেয়েছেন সেটি পাওয়া যায়নি।';

  @override
  String get apiServiceUnavailable => 'পরিষেবা এখন সাড়া দিচ্ছে না।';

  @override
  String get apiNetworkFailure => 'সংযোগ নেই, তাই এটি হয়নি।';

  @override
  String get apiUnknownFailure =>
      'অনুরোধটি সম্পূর্ণ করা যায়নি। আবার চেষ্টা করুন।';

  @override
  String get apiAccountChangedRequestNotSent =>
      'আপনার অ্যাকাউন্ট বদলে গেছে। এই অনুরোধ পাঠানো হয়নি।';

  @override
  String get apiAccountOrSessionChanged =>
      'আপনার অ্যাকাউন্ট বা সেশন বদলে গেছে। এই কাজটি পাঠানো হয়নি।';

  @override
  String get apiResponseUnreadable =>
      'পরিষেবার উত্তর পড়া যায়নি। কাজটি হয়তো পৌঁছে গেছে; আবার চেষ্টা করার আগে এর অবস্থা দেখে নিন।';

  @override
  String get apiSignInBeforeAction => 'এই কাজটি পাঠানোর আগে আবার সাইন ইন করুন।';

  @override
  String get apiAccountChangedNotConfirmed =>
      'আপনার অ্যাকাউন্ট বদলে গেছে। এই কাজটি নিশ্চিত করা যায়নি।';

  @override
  String get apiActionNotConfirmed =>
      'কাজটি নিশ্চিত হয়নি। হয়তো এটি ক্লাসে পৌঁছে গেছে। আবার চেষ্টা করার আগে এর অবস্থা দেখে নিন।';

  @override
  String get apiAccountChangedActionNotSent =>
      'আপনার অ্যাকাউন্ট বদলে গেছে। এই কাজটি পাঠানো হয়নি।';

  @override
  String get apiRequestFailed => 'অনুরোধ ব্যর্থ হয়েছে';

  @override
  String get notificationPrivateTitle => 'SEEDS আপডেট';

  @override
  String get notificationPrivateBody => 'আপনার আপডেট দেখতে SEEDS খুলুন।';

  @override
  String get notificationRegistrationFailed =>
      'বিজ্ঞপ্তি চালু করা গেল না। ক্লাসের আমন্ত্রণ দেখতে SEEDS রিফ্রেশ করুন।';

  @override
  String get notificationChannelName => 'সেশনের বিজ্ঞপ্তি';

  @override
  String get notificationChannelDescription =>
      'সেশনের আমন্ত্রণ ও আপডেটের বিজ্ঞপ্তি';

  @override
  String get notificationDisplayFailed =>
      'একটি আপডেট এসেছে, কিন্তু ফোনে বিজ্ঞপ্তি দেখানো গেল না। আপডেট দেখতে SEEDS খুলুন।';

  @override
  String get activityCleanupFailed =>
      'মেয়াদ শেষ হওয়া কার্যকলাপ মোছা যায়নি। ডিভাইসের স্টোরেজ দেখে নিন।';

  @override
  String get activitySyncUnavailable =>
      'কার্যকলাপ সিঙ্ক পাওয়া যাচ্ছে না। শেখা এখনও চালু আছে।';

  @override
  String get activitySignInToSync => 'কার্যকলাপ সিঙ্ক করতে সাইন ইন করুন।';

  @override
  String get activityQueueFull =>
      'কার্যকলাপের তালিকা ভরে গেছে। কিছু পুরোনো কাজের খবর পাঠানো যাবে না।';

  @override
  String get activityWaitingToSync =>
      'কিছু কার্যকলাপ সিঙ্ক হওয়ার অপেক্ষায় আছে।';

  @override
  String get activityRejected =>
      'কিছু কার্যকলাপের মেয়াদ শেষ হয়েছিল বা আর অনুমতি ছিল না, তাই সিঙ্ক হয়নি।';

  @override
  String get authLogoutTitle => 'SEEDS থেকে লগ আউট করবেন?';

  @override
  String get authLogoutMessage =>
      'আপনাকে আবার আপনার ফোন নম্বর ও পাসওয়ার্ড লিখতে হবে।';

  @override
  String get authLogoutCancel => 'বাতিল';

  @override
  String get authLogoutConfirm => 'লগ আউট';

  @override
  String get authLoggedOut => 'লগ আউট হয়েছে।';

  @override
  String get startupLoadingTools => 'সহজে ব্যবহারযোগ্য শেখার টুল লোড হচ্ছে…';

  @override
  String get startupTagline => 'সবাইকে, সব জায়গায় যুক্ত করছি';

  @override
  String get startupLoginKey1 => '1. লগইন';

  @override
  String get startupLogin => 'লগইন';

  @override
  String get startupRegisterKey2 => '2. নিবন্ধন';

  @override
  String get startupRegister => 'নিবন্ধন';

  @override
  String get startupSettings => 'সেটিংস';

  @override
  String get startupRepeatInstructions => 'নির্দেশ আবার শুনুন';

  @override
  String get startupFeatureAudioTitle => 'রিয়েল-টাইম অডিও';

  @override
  String get startupFeatureAudioText => 'একদম পরিষ্কার কণ্ঠে কথা বলা';

  @override
  String get startupFeatureAccessibleTitle => 'সবার জন্য সহজ';

  @override
  String get startupFeatureAccessibleText =>
      'কণ্ঠস্বর, বড় বোতাম এবং কীপ্যাড নিয়ন্ত্রণ';

  @override
  String get startupFeatureCollaborationTitle => 'একসাথে কাজ';

  @override
  String get startupFeatureCollaborationText => 'হাত তুলুন এবং অংশ নিন';

  @override
  String get settingsResetTitle => 'সেটিংস রিসেট';

  @override
  String get settingsResetCancelButton => '1: বাতিল';

  @override
  String get settingsResetConfirmButton => '2: রিসেট';

  @override
  String teacherHomeFallbackName(String id) {
    return 'শিক্ষক $id';
  }

  @override
  String dashboardSignedInAs(String name) {
    return '$name হিসেবে সাইন ইন করা আছে';
  }

  @override
  String get dashboardRefreshSessionsKey1 => '1: সেশন রিফ্রেশ করুন';

  @override
  String get dashboardLogOutKey0 => '0: লগ আউট';

  @override
  String get dashboardRefreshingSessions => 'সেশন রিফ্রেশ হচ্ছে';

  @override
  String teacherHomeWelcome(String name) {
    return 'স্বাগতম, $name!';
  }

  @override
  String get teacherHomeTagline =>
      'আপনার সেশনগুলি পরিচালনা করুন এবং শিক্ষার্থীদের সাথে যুক্ত হন';

  @override
  String get teacherHomeChooseWorkspaceKey7 =>
      '7: ক্লাস ও বিষয়ের ওয়ার্কস্পেস বাছুন';

  @override
  String teacherHomeChangeWorkspaceKey7(String className, String subjectName) {
    return '7: $className, $subjectName। ওয়ার্কস্পেস বদলান';
  }

  @override
  String get teacherHomePlaylistsKey5 => '5: ক্লাসের প্লেলিস্ট';

  @override
  String get teacherHomeJourneysKey8 => '8: শেখার যাত্রা';

  @override
  String get teacherHomeQuizzesKey6 => '6: কুইজ ও প্রশ্ন ব্যাংক';

  @override
  String get teacherHomeCreateSessionKey2 => '2: নতুন সেশন তৈরি করুন';

  @override
  String get dashboardAudioLibraryKey3 => '3: রেকর্ড করা অডিও লাইব্রেরি';

  @override
  String get teacherHomeSearchKey4 => '4: নাম বা নম্বর দিয়ে খুঁজুন';

  @override
  String get teacherHomeSearchHint =>
      'সেশনের নাম লিখুন, বা নম্বর কী দিয়ে সেশন নম্বর লিখুন। সব দেখতে খালি রাখুন।';

  @override
  String get teacherHomeYourSessions => 'আপনার সেশন';

  @override
  String teacherHomeYourSessionsCount(String count) {
    return 'আপনার সেশন, $count';
  }

  @override
  String get teacherHomeYourSessionsHeading => 'আপনার সেশন';

  @override
  String get teacherHomeNoSessions =>
      'এখনও কোনো সেশন নেই। একটি তৈরি করতে 2 টিপুন।';

  @override
  String get teacherHomeNoMatches =>
      'মেলে এমন কোনো সেশন নেই। সব সেশন দেখতে খোঁজা মুছে দিন।';

  @override
  String teacherHomeEndTitleForEveryone(String title) {
    return 'সবার জন্য $title শেষ করুন';
  }

  @override
  String teacherHomeDeleteTitlePermanently(String title) {
    return '$title চিরতরে মুছুন';
  }

  @override
  String teacherHomeLiveJoined(String count) {
    return 'এখন লাইভ, $count জন যোগ দিয়েছে';
  }

  @override
  String teacherHomeSessionNumber(String number) {
    return 'সেশন নম্বর $number';
  }

  @override
  String teacherHomePlaceSessionNumber(String place, String number) {
    return '$place। সেশন নম্বর $number';
  }

  @override
  String get teacherHomeDelete => 'মুছুন';

  @override
  String get teacherHomeSessionTitleField => 'সেশনের শিরোনাম';

  @override
  String get teacherHomeSessionTitleHint => 'যেমন, ইংরেজি ক্লাস - ইউনিট 5';

  @override
  String get teacherHomeCreateKey1 => 'তৈরি করুন (1)';

  @override
  String studentHomeFallbackName(String id) {
    return 'শিক্ষার্থী $id';
  }

  @override
  String get studentHomeLoading => 'শিক্ষার্থীর ড্যাশবোর্ড লোড হচ্ছে';

  @override
  String studentHomeWelcome(String name) {
    return 'স্বাগতম, $name';
  }

  @override
  String studentHomeClass(String name) {
    return 'ক্লাস: $name';
  }

  @override
  String get studentHomeAssignmentPending => 'ক্লাস দেওয়া বাকি';

  @override
  String get studentHomeLiveSessionsNone => 'লাইভ সেশন: নেই';

  @override
  String studentHomeLiveSessionsCount(String count) {
    return 'লাইভ সেশন: $count';
  }

  @override
  String get studentHomeSessionNumberKey2 => '2: সেশন নম্বর';

  @override
  String get studentHomeSessionName => 'সেশনের নাম';

  @override
  String get studentHomeSubjectFilter => 'বিষয় ফিল্টার';

  @override
  String get studentHomePlaylistsKey4 => '4: আমার প্লেলিস্ট · ব্যক্তিগত';

  @override
  String get studentHomeQuizzesKey5 => '5: কুইজ';

  @override
  String get studentHomeJourneysKey6 => '6: শেখার যাত্রা';

  @override
  String studentHomeTeacher(String name) {
    return 'শিক্ষক: $name';
  }

  @override
  String studentHomeSessionOkToJoin(String number) {
    return 'সেশন $number। যোগ দিতে ওকে';
  }

  @override
  String studentHomeJoinSessionLabel(String session) {
    return '$session। সেশনে যোগ দিন';
  }

  @override
  String adminActiveAssignmentCount(String count) {
    return '$countটি সক্রিয় দায়িত্ব';
  }

  @override
  String adminHeadingCount(String heading, String count) {
    return '$heading ($count)';
  }

  @override
  String get adminTextDialogHelper =>
      'লিখতে ওকে টিপুন, তারপর সেভ করতে 1 বা বাতিল করতে 0 টিপুন';

  @override
  String get adminSaveKey1 => 'সেভ (1)';

  @override
  String adminManageUser(String name) {
    return '$name পরিচালনা করুন';
  }

  @override
  String get adminManageAssignmentsKey1 => '1: দায়িত্ব পরিচালনা করুন';

  @override
  String get adminPasswordRecoveryKey2 => '2: পাসওয়ার্ড পুনরুদ্ধার';

  @override
  String adminRemoveStudentFromClass(String name, String className) {
    return '$name-কে $className থেকে সরান (2)';
  }

  @override
  String get adminRemoveClassKey2 => 'ক্লাস সরান (2)';

  @override
  String get adminAssignKey1 => 'দায়িত্ব দিন (1)';

  @override
  String adminAssignTeacher(String name) {
    return '$name-কে দায়িত্ব দিন';
  }

  @override
  String get adminCurrentAssignments => 'বর্তমান দায়িত্ব';

  @override
  String adminRemoveTeacherAssignment(
    String name,
    String className,
    String subjectName,
  ) {
    return '$name-কে $className, $subjectName থেকে সরান';
  }

  @override
  String get adminAddAssignment => 'একটি দায়িত্ব যোগ করুন';

  @override
  String get adminAppBarTitle => 'SEEDS প্রশাসন';

  @override
  String get adminRefreshKey1 => '1: প্রশাসনের তথ্য রিফ্রেশ করুন';

  @override
  String get adminLoading => 'প্রশাসনের তথ্য লোড হচ্ছে';

  @override
  String adminChangeSectionKey7(String section) {
    return '7: বিভাগ বদলান। এখন: $section';
  }

  @override
  String get adminSearchKey2 => '2: নাম বা ফোন নম্বর দিয়ে খুঁজুন';

  @override
  String get adminSearchHelper => 'মিল দেখতে শেষ হলে ওকে টিপুন';

  @override
  String adminRoleFilterChipsLabel(String label) {
    return 'অ্যাকাউন্টের ধরন ফিল্টার: $label, বেছে নেওয়া। বদলাতে বাম ও ডান তীর ব্যবহার করুন।';
  }

  @override
  String get adminAccountTypeKey3 => '3: অ্যাকাউন্টের ধরন';

  @override
  String get adminChipAllAccounts => 'সব অ্যাকাউন্ট';

  @override
  String get adminChipStudents => 'শিক্ষার্থী';

  @override
  String get adminChipTeachers => 'শিক্ষক';

  @override
  String adminAssignmentFilterChipsLabel(String label) {
    return 'দায়িত্ব ফিল্টার: $label, বেছে নেওয়া। বদলাতে বাম ও ডান তীর ব্যবহার করুন।';
  }

  @override
  String get adminAssignmentKey4 => '4: দায়িত্ব';

  @override
  String get adminChipAll => 'সব';

  @override
  String get adminCreateSubjectKey5 => '5: বিষয় তৈরি করুন';

  @override
  String get adminCreateClassKey6 => '6: ক্লাস তৈরি করুন';

  @override
  String get adminStatusActive => 'সক্রিয়';

  @override
  String get adminClassTileHint => 'বিষয়ের জন্য বা আর্কাইভ করতে ওকে টিপুন';

  @override
  String get adminPressOkRestore => 'ফিরিয়ে আনতে ওকে টিপুন';

  @override
  String get adminPressOkArchive => 'আর্কাইভ করতে ওকে টিপুন';

  @override
  String sessionTitleTeacher(String title) {
    return '$title (শিক্ষক)';
  }

  @override
  String get libraryStatusStopped => 'থেমে আছে';

  @override
  String libraryUploadFileName(String name) {
    return 'ফাইল: $name';
  }

  @override
  String libraryAudioSessionTitle(String number) {
    return 'অডিও - সেশন $number';
  }

  @override
  String libraryRecordingsCount(String count) {
    return '$countটি রেকর্ডিং';
  }

  @override
  String libraryUploadedAt(String date) {
    return 'আপলোড হয়েছে: $date';
  }

  @override
  String libraryStopPreviewOf(String title) {
    return '$title-এর প্রিভিউ বন্ধ করুন';
  }

  @override
  String libraryPreviewPrivately(String title) {
    return '$title ব্যক্তিগতভাবে প্রিভিউ করুন';
  }

  @override
  String libraryPlayForEveryone(String title) {
    return 'সেশনের সবার জন্য $title চালান';
  }

  @override
  String get librarySelectClassHint =>
      'রেকর্ড করা পাঠ চালাতে একটি ক্লাস বেছে নিন। অনলাইন পাঠের জন্য ইন্টারনেট লাগে। সেভ করা অডিওর জন্য \'ডাউনলোড করা পাঠ\' ব্যবহার করুন।';

  @override
  String libraryFoundCount(String count) {
    return '$countটি পাওয়া গেছে';
  }

  @override
  String get librarySearchSessionHint =>
      'দ্রুত একটি ক্লাসে যেতে উপরের \"সেশনের নাম দিয়ে খুঁজুন\" ব্যবহার করুন।';

  @override
  String librarySessionHash(String number) {
    return 'সেশন #$number';
  }

  @override
  String libraryStatusFinished(String title) {
    return '$title শেষ হয়েছে';
  }

  @override
  String libraryStatusPaused(String title) {
    return '$title থামানো আছে';
  }

  @override
  String libraryStatusPlaying(String title) {
    return '$title চলছে';
  }

  @override
  String get libraryTitleField => 'শিরোনাম';

  @override
  String get libraryDescriptionOptional => 'বিবরণ (ঐচ্ছিক)';

  @override
  String libraryAudioLibrarySession(String number) {
    return 'অডিও লাইব্রেরি, সেশন $number';
  }

  @override
  String get libraryUploadingAudio => 'অডিও আপলোড হচ্ছে';

  @override
  String get libraryAddAudioKey3Tooltip => 'অডিও যোগ করুন, কী 3';

  @override
  String get libraryAddAudioKey3 => '3: অডিও যোগ করুন';

  @override
  String get libraryNoRecordingsForClass =>
      'এই ক্লাসের জন্য এখনও কোনো রেকর্ডিং নেই।';

  @override
  String get libraryNoRecordingsAskTeacher =>
      'এখনও কোনো রেকর্ডিং নেই। আপনার শিক্ষককে কিছু আপলোড করতে বলুন।';

  @override
  String libraryPositionSpeed(String position, String total, String speed) {
    return '$totalটির মধ্যে $position। গতি ${speed}x';
  }

  @override
  String libraryNowPlaying(String title) {
    return 'এখন চলছে: $title';
  }

  @override
  String libraryRecordingsMatch(String count, String total) {
    return '$totalটির মধ্যে $countটি রেকর্ডিং মিলেছে';
  }

  @override
  String get libraryNoUnlinkedAudio => 'যুক্ত না করা কোনো অডিও নেই।';

  @override
  String get libraryNoSearchMatches =>
      'আপনার খোঁজের সঙ্গে কোনো রেকর্ডিং মেলেনি।';

  @override
  String get libraryFindingLesson => 'আপনার পাঠ খোঁজা হচ্ছে';

  @override
  String get libraryTitleRequiredField => 'শিরোনাম *';

  @override
  String get libraryUploadNewAudio => 'নতুন অডিও আপলোড করুন';

  @override
  String get libraryStopPreview => 'প্রিভিউ বন্ধ করুন';

  @override
  String get libraryPreviewOnlyMe => 'প্রিভিউ (শুধু আমি)';

  @override
  String get libraryPreview => 'প্রিভিউ';

  @override
  String get libraryStop => 'বন্ধ করুন';

  @override
  String get libraryPlayInSession => 'সেশনে চালান';

  @override
  String get librarySessionShort => 'সেশন';

  @override
  String get libraryNotesTooltip => 'ব্যক্তিগত নোট আর রেকর্ডিংয়ের খসড়া';

  @override
  String get libraryBrowseClassesKey5 => '5: চালু ক্লাসগুলো দেখুন';

  @override
  String get librarySearchClassByName => 'নাম দিয়ে ক্লাস খুঁজুন';

  @override
  String get librarySearchClassHint => 'সেশন/ক্লাসের নাম লিখুন';

  @override
  String get libraryMyAudioLibrary => 'আমার অডিও লাইব্রেরি';

  @override
  String get libraryAllAudioFiles => 'সব অডিও ফাইল';

  @override
  String get libraryManageAudioFiles => 'আপনার অডিও ফাইল সামলান আর আপলোড করুন';

  @override
  String get libraryBrowseAudioFiles => 'আপলোড করা সব অডিও ফাইল দেখুন';

  @override
  String get libraryActiveClasses => 'চালু ক্লাস';

  @override
  String get libraryNoActiveClasses => 'কোনো চালু ক্লাস পাওয়া যায়নি।';

  @override
  String get libraryAddAudioToSessions => 'সেশনে অডিও যোগ করুন';

  @override
  String get libraryConfirmKey1 => '1: নিশ্চিত করুন';

  @override
  String get libraryDownloadLessons => 'পাঠ ডাউনলোড করুন';

  @override
  String get libraryRepeatHelp => 'সাহায্য আবার শুনুন';

  @override
  String get libraryBack10s => '10 সেকেন্ড পিছনে';

  @override
  String get libraryPause => 'থামান';

  @override
  String get libraryPlay => 'চালান';

  @override
  String get libraryForward10s => '10 সেকেন্ড সামনে';

  @override
  String get libraryCloseAddAudio => 'অডিও যোগ করার বিকল্পগুলো বন্ধ করুন';

  @override
  String get libraryUploadNewFileKey1 => '1: নতুন ফাইল আপলোড করুন';

  @override
  String get librarySelectExistingKey2 => '2: আগের লাইব্রেরি থেকে বেছে নিন';

  @override
  String get librarySelectAudio => 'অডিও বেছে নিন';

  @override
  String get libraryRefreshAvailable => 'পাওয়া যায় এমন অডিও রিফ্রেশ করুন';

  @override
  String get librarySearchByTitle => 'শিরোনাম দিয়ে খুঁজুন';

  @override
  String get libraryNothingPlaying =>
      'কিছুই চলছে না। একটি পাঠ বেছে নিন বা 5 টিপুন।';

  @override
  String spokenDayMonthYear(String day, String month, String year) {
    return '$day $month $year';
  }

  @override
  String get downloadPartialReserve =>
      'আংশিক ফাইল তার পুরো মাপের জায়গা আগে থেকে রেখে দেয়।';

  @override
  String downloadProgressStarting(String title) {
    return '$title: ডাউনলোড শুরু হচ্ছে';
  }

  @override
  String downloadPercentDone(String title, String percent) {
    return '$title: $percent শতাংশ ডাউনলোড হয়েছে';
  }

  @override
  String downloadRecordUnreadable(String id) {
    return 'ডাউনলোড রেকর্ড $id পড়া যায়নি। ফাইলগুলো রাখা আছে। ঠিক করতে শুধু এই ডাউনলোডটি সরান; অগ্রগতি আর বুকমার্ক রাখা থাকবে।';
  }

  @override
  String downloadRemoveUnreadable(String id) {
    return 'পড়া যায় না এমন ডাউনলোড $id সরান';
  }

  @override
  String get downloadStatusDownloaded => 'ডাউনলোড হয়েছে';

  @override
  String get downloadStatusPartial => 'আংশিক ডাউনলোড';

  @override
  String downloadSizeRenewal(String megabytes) {
    return '$megabytes MB। অ্যাক্সেস নবীকরণ করতে হবে।';
  }

  @override
  String downloadSizeExpires(String megabytes, String date) {
    return '$megabytes MB। অ্যাক্সেস $date তারিখে শেষ হবে।';
  }

  @override
  String get downloadTitle => 'ডাউনলোড';

  @override
  String get downloadAccessInfo =>
      '30 দিনের অফলাইন অ্যাক্সেস। অন্য অ্যাকাউন্টের আলাদা সীমা আছে। নিজে থেকে কিছু মুছে যায় না।';

  @override
  String get downloadRefreshKey1 => '1: ডাউনলোড রিফ্রেশ করুন';

  @override
  String get downloadFindOnlineKey2 => '2: অনলাইনে রেকর্ডিং খুঁজুন';

  @override
  String get downloadReadStatusKey3 => '3: অবস্থা শুনুন';

  @override
  String get downloadCancelKey4 => '4: ডাউনলোড বাতিল করুন';

  @override
  String get downloadNoneYetFindOnline =>
      'এখনও কোনো ডাউনলোড নেই। অনলাইনে রেকর্ডিং খুঁজুন, অথবা কোনো ক্লাস বা প্লেলিস্ট থেকে ডাউনলোড খুলুন।';

  @override
  String get downloadPlayLesson => 'ডাউনলোড করা পাঠ চালান';

  @override
  String get downloadRenewOnline => 'অনলাইনে অ্যাক্সেস নবীকরণ করুন';

  @override
  String get downloadRemove => 'ডাউনলোড সরান';

  @override
  String get downloadListedKey5 => '5: তালিকার রেকর্ডিং ডাউনলোড করুন';

  @override
  String get downloadAvailableInfo =>
      'পাওয়া যায় এমন রেকর্ডিং। ডাউনলোডে ইন্টারনেট ডেটা খরচ হয়।';

  @override
  String playlistClassSubjectTitle(String className, String subjectName) {
    return '$className · $subjectName প্লেলিস্ট';
  }

  @override
  String get playlistStatusPrivate => 'ব্যক্তিগত';

  @override
  String get playlistClassPlaylist => 'ক্লাসের প্লেলিস্ট';

  @override
  String playlistItemCount(String count) {
    return '$countটি আইটেম';
  }

  @override
  String playlistClassItemCount(
    String className,
    String subjectName,
    String count,
  ) {
    return '$className, $subjectName, $countটি আইটেম';
  }

  @override
  String get playlistFinished => 'শেষ হয়েছে। প্লেলিস্টের শেষ';

  @override
  String get playlistAddKey2 => '2 যোগ করুন';

  @override
  String get playlistAddAudioKey2Label => 'অডিও যোগ করুন, কী 2';

  @override
  String get playlistPauseKey5 => '5 থামান';

  @override
  String get playlistPlayKey5 => '5 চালান';

  @override
  String playlistPauseTitleKey5(String title) {
    return '$title থামান, কী 5';
  }

  @override
  String playlistPlayTitleKey5(String title) {
    return '$title চালান, কী 5';
  }

  @override
  String get playlistPreviousKey3 => '3 আগেরটি';

  @override
  String get playlistPreviousItemKey3 => 'আগের আইটেম, কী 3';

  @override
  String get playlistNextKey8 => '8 পরেরটি';

  @override
  String get playlistNextItemKey8 => 'পরের আইটেম, কী 8';

  @override
  String get playlistRestore => 'ফিরিয়ে আনুন';

  @override
  String get playlistArchive => 'আর্কাইভ করুন';

  @override
  String get playlistDeletePlaylist => 'প্লেলিস্ট মুছুন';

  @override
  String playlistRestoreNamedButton(String title) {
    return '$title ফিরিয়ে আনুন';
  }

  @override
  String playlistArchiveNamedButton(String title) {
    return '$title আর্কাইভ করুন';
  }

  @override
  String playlistDeleteNamedButton(String title) {
    return '$title মুছুন';
  }

  @override
  String playlistMoveUp(String title) {
    return '$title উপরে সরান';
  }

  @override
  String playlistMoveDown(String title) {
    return '$title নিচে সরান';
  }

  @override
  String get playlistCreateKey2 => '2: প্লেলিস্ট তৈরি করুন';

  @override
  String get playlistNoneInClass =>
      'এই ক্লাস আর বিষয়ে কোনো প্লেলিস্ট নেই। একটি তৈরি করতে 2 টিপুন।';

  @override
  String get playlistMyPlaylists => 'আমার প্লেলিস্ট';

  @override
  String get playlistPrivateNoticeTitle => 'আপনার প্লেলিস্ট ব্যক্তিগত';

  @override
  String get playlistPrivateNoticeText =>
      'শিক্ষক, প্রশাসক এবং অন্য শিক্ষার্থীরা এগুলো দেখতে পারবেন না।';

  @override
  String get playlistCreatePrivateKey2 => '2: ব্যক্তিগত প্লেলিস্ট তৈরি করুন';

  @override
  String get playlistMyPrivateHeading => 'আমার ব্যক্তিগত প্লেলিস্ট';

  @override
  String get playlistNoPrivate => 'এখনও কোনো ব্যক্তিগত প্লেলিস্ট নেই।';

  @override
  String get playlistClassHeading => 'ক্লাসের প্লেলিস্ট';

  @override
  String get playlistNoClassPublished =>
      'এখনও কোনো ক্লাসের প্লেলিস্ট প্রকাশিত হয়নি।';

  @override
  String get playlistAddAudioTitle => 'অডিও যোগ করুন';

  @override
  String get playlistUnavailableRetry =>
      'প্লেলিস্টটি পাওয়া যাচ্ছে না। আবার চেষ্টা করতে 1 টিপুন।';

  @override
  String get playlistDownloadRecordings => 'প্লেলিস্টের রেকর্ডিং ডাউনলোড করুন';

  @override
  String get playlistMoveHint =>
      'একটি আইটেম চালান বা বেছে নিন, তারপর সেটি উপরে বা নিচে সরান।';

  @override
  String get playlistNoAudio => 'এই প্লেলিস্টে এখনও কোনো অডিও নেই।';

  @override
  String quizClassSubjectHeading(String className, String subjectName) {
    return '$className · $subjectName';
  }

  @override
  String get quizBankEditNote =>
      'ব্যাংকের কোনো প্রশ্ন সম্পাদনা করলে আগে থেকে থাকা কুইজের সংরক্ষিত কপি কখনও বদলায় না।';

  @override
  String get quizNoBankQuestions => 'ব্যাংকে এখনও কোনো প্রশ্ন নেই';

  @override
  String quizOptionsCount(String count) {
    return '$countটি বিকল্প';
  }

  @override
  String get quizNoQuizzesYet => 'এখনও কোনো কুইজ নেই';

  @override
  String get quizStepReviewPublish => 'ধাপ 3: দেখে নিন এবং প্রকাশ করুন';

  @override
  String get quizStepAddQuestions => 'ধাপ 2: প্রশ্ন যোগ করুন';

  @override
  String quizResultsTitle(String title) {
    return '$title ফলাফল';
  }

  @override
  String get quizAllAttempted => 'সব শিক্ষার্থী চেষ্টা করেছে';

  @override
  String get quizRemindAllKey2 =>
      '2: যারা চেষ্টা করেনি তাদের সবাইকে মনে করিয়ে দিন';

  @override
  String get uiNoneCapital => 'কিছু নেই';

  @override
  String get quizPracticeParticipationHeading =>
      'অনুশীলনে অংশগ্রহণ, পড়াশোনার নম্বর নয়';

  @override
  String get quizIndividualScores => 'প্রত্যেক শিক্ষার্থীর স্কোর';

  @override
  String get quizNotAttempted => 'চেষ্টা করেনি';

  @override
  String get quizPracticeNotGraded => 'অনুশীলন, নম্বরযুক্ত নয়';

  @override
  String quizHighestScore(String score) {
    return 'সর্বোচ্চ স্কোর: $score';
  }

  @override
  String get quizAttemptInProgress => 'চেষ্টা চলছে';

  @override
  String get quizQuizzesTitle => 'কুইজ';

  @override
  String get quizRefreshQuizzesTooltip => 'কুইজ রিফ্রেশ করুন';

  @override
  String get quizLoadingQuizzes => 'কুইজ লোড হচ্ছে';

  @override
  String get quizNewBankQuestionKey2 => '2: ব্যাংকে নতুন প্রশ্ন';

  @override
  String get quizNewDraftKey3 => '3: নতুন কুইজের খসড়া';

  @override
  String get quizCreatePracticeKey4 => '4: সময়সীমা ছাড়া অনুশীলন তৈরি করুন';

  @override
  String get quizPrivateBankHeading => 'ব্যক্তিগত প্রশ্ন ব্যাংক';

  @override
  String get quizOptionsButton => 'বিকল্প';

  @override
  String get quizManagementHeading => 'কুইজ পরিচালনা';

  @override
  String get quizContinueCreation => 'তৈরি করা চালিয়ে যান';

  @override
  String get quizCloseButton => 'বন্ধ করুন';

  @override
  String get quizDuplicateButton => 'কপি তৈরি করুন';

  @override
  String get quizResultsButton => 'ফলাফল';

  @override
  String get quizRefreshResultsTooltip => 'ফলাফল রিফ্রেশ করুন';

  @override
  String get quizClassStatistics => 'ক্লাসের পরিসংখ্যান';

  @override
  String get quizStudentsYetToAttempt => 'যেসব শিক্ষার্থী এখনও চেষ্টা করেনি';

  @override
  String get quizNoQuizzesAvailableLabel => 'কোনো কুইজ পাওয়া যাচ্ছে না';

  @override
  String get quizAttemptLimitReachedLabel => 'চেষ্টার সীমা পূর্ণ হয়েছে';

  @override
  String get quizAnswerSavedLockedTitle => 'উত্তর সংরক্ষিত এবং লক করা হয়েছে';

  @override
  String get quizAllSavedViewResult =>
      'সব উত্তর সংরক্ষিত হয়েছে। শেষ হওয়া নিশ্চিত করতে ফলাফল দেখুন বেছে নিন।';

  @override
  String quizAsksToConfirm(String label) {
    return '$label, নিশ্চিত করতে বলবে';
  }

  @override
  String get quizConfirmingCompletion => 'শেষ হওয়া নিশ্চিত করা হচ্ছে';

  @override
  String get quizRetryCompletionKey5 => '5: আবার শেষ করার চেষ্টা করুন';

  @override
  String get quizViewResultKey5 => '5: ফলাফল দেখুন';

  @override
  String quizHistoryTitle(String title) {
    return '$title ইতিহাস';
  }

  @override
  String get quizNoAttemptsYet => 'এখনও কোনো চেষ্টা নেই';

  @override
  String get quizHistoryTooltip => 'চেষ্টার ইতিহাস এবং পর্যালোচনা';

  @override
  String get quizLeaveWithoutSubmitting => 'জমা না দিয়ে বেরিয়ে যান';

  @override
  String get quizAttemptCompletePrivateLabel =>
      'চেষ্টা শেষ। ফলাফল ব্যক্তিগত। গোপনে ফলাফল শুনুন ব্যবহার করুন।';

  @override
  String get quizReadResultKey8 => '8: গোপনে ফলাফল শুনুন';

  @override
  String get quizReturnKey0 => '0: কুইজে ফিরে যান';

  @override
  String get quizReadAllOptionsLabel => 'সব বিকল্প শুনুন';

  @override
  String get quizSubmitAnswerKey5 => '5: উত্তর জমা দিন';

  @override
  String get quizAnswerLockedActivate =>
      'উত্তর সংরক্ষিত এবং লক করা হয়েছে। গোপনে ফিডব্যাক শুনতে চালু করুন।';

  @override
  String get quizReadSelectedAnswer => 'বেছে নেওয়া উত্তর শুনুন';

  @override
  String get quizReadRemainingTime => 'বাকি সময় শুনুন';

  @override
  String get quizAttemptReviewTitle => 'চেষ্টার পর্যালোচনা';

  @override
  String get quizEditorIntro =>
      'প্রশ্ন আর চারটি বিকল্পই পূরণ করুন, তারপর সঠিক উত্তর বেছে নিন। সমীকরণ বা চিত্রের জন্য, ঐচ্ছিক বলা চিহ্ন খুলুন এবং বিকল্প লেখাগুলো দেখে নিন।';

  @override
  String get quizWhichCorrect => 'কোন উত্তরটি সঠিক?';

  @override
  String get quizChooseCorrectOption => 'সঠিক বিকল্প বেছে নিন';

  @override
  String quizOptionWithText(String number, String text) {
    return 'বিকল্প $number: $text';
  }

  @override
  String get quizCorrectChoiceHint =>
      'বদলাতে বাঁ বা ডান ব্যবহার করুন। ওকে টিপলে বা ছুঁলে পরের বিকল্প বেছে নেওয়া হয়।';

  @override
  String get quizExplanationOptional => 'ব্যাখ্যা (ঐচ্ছিক)';

  @override
  String get quizContentDescribedText =>
      'বিষয়বস্তু: শিক্ষকের বর্ণনা করা চিহ্ন বা চিত্র';

  @override
  String get quizNotationNote =>
      'সমীকরণ বা চিত্র নিজে থেকে বোঝানো হয় না। শিক্ষকদের ইংরেজিতে বলার মতো বিকল্প লেখা লিখতে ও দেখে নিতে হবে। বর্ণনা করা চিহ্নের জন্য প্রশ্ন, সব বিকল্প এবং যেকোনো ব্যাখ্যা যোগ করুন।';

  @override
  String get quizReviewedAlternatives =>
      'আমি বলা বিকল্প লেখাগুলো সঠিক কিনা দেখে নিয়েছি';

  @override
  String get quizChangeSettings => 'কুইজের সেটিংস বদলান';

  @override
  String get quizCreatePracticeText => 'সময়সীমা ছাড়া অনুশীলন তৈরি করুন';

  @override
  String get quizStepName => 'ধাপ 1: আপনার কুইজের নাম দিন';

  @override
  String get quizPracticeInfo =>
      'অনুশীলনে প্রতি চেষ্টার কোনো টাইমার বা চেষ্টার সীমা নেই। ঐচ্ছিক বন্ধের সময় দিলে তখনও পাওয়া বন্ধ হয়ে যাবে।';

  @override
  String get quizSettingsNavLabel =>
      'কুইজের সেটিংসে ঘুরতে উপর আর নিচ ব্যবহার করুন। লেখার ঘর সম্পাদনা করতে ওকে টিপুন। খোলার ও বন্ধের সময় ঐচ্ছিক।';

  @override
  String get quizSettingsNavText =>
      'সেটিংসে ঘুরতে উপর আর নিচ, এবং সম্পাদনা করতে ওকে ব্যবহার করুন। খসড়া বা তার সেটিংস সংরক্ষণ করলে কুইজ প্রকাশিত হয় না।';

  @override
  String get quizSettingsReviewInfo =>
      'নিচে সংরক্ষিত সেটিংস দেখুন এবং বদলান। সংরক্ষণ করলে কুইজ প্রকাশিত হয় না।';

  @override
  String get quizPracticeDefaults =>
      'নম্বর ছাড়া অনুশীলন। যত খুশি চেষ্টা, কোনো টাইমার নেই, সঙ্গে সঙ্গে ফিডব্যাক।';

  @override
  String get quizGradedDefaults =>
      'নম্বরযুক্ত কুইজের সাধারণ সেটিংস: একবার চেষ্টা, কোনো টাইমার নেই, শেষ জমার পরে ফিডব্যাক।';

  @override
  String get quizHideOptionalSettingsText => 'ঐচ্ছিক সেটিংস লুকান';

  @override
  String get quizShowOptionalSettingsText => 'ঐচ্ছিক সেটিংস দেখান';

  @override
  String get quizAttemptLimitFieldText => 'চেষ্টার সীমা, 1 থেকে 20';

  @override
  String get quizTimeLimitFieldText => 'মিনিটে সময়সীমা (ঐচ্ছিক)';

  @override
  String get quizUntimedInfo =>
      'সময়সীমা ছাড়া এবং নম্বর ছাড়া, যত খুশি আবার চেষ্টা। সময় ঠিক করা থাকলে পাওয়ার সময় তখনও মানা হবে।';

  @override
  String quizFeedbackValue(String policy) {
    return 'ফিডব্যাক: $policy';
  }

  @override
  String quizReleaseValue(String time) {
    return 'প্রকাশ: $time';
  }

  @override
  String quizOpeningTimeLabel(String time) {
    return '$time। খোলার সময় ঠিক করতে ওকে টিপুন। বাঁ টিপলে মুছে যাবে।';
  }

  @override
  String get quizNoOpeningTimeSet => 'খোলার সময় ঠিক করা নেই';

  @override
  String get quizNoOpeningTimeShort => 'খোলার সময় নেই';

  @override
  String get quizOpeningTimeHint =>
      'ঐচ্ছিক · বছর, মাস, দিন, ঘণ্টা আর মিনিট লিখুন';

  @override
  String quizClosingTimeLabel(String time) {
    return '$time। বন্ধের সময় ঠিক করতে ওকে টিপুন। বাঁ টিপলে মুছে যাবে।';
  }

  @override
  String get quizNoClosingTimeSet => 'বন্ধের সময় ঠিক করা নেই';

  @override
  String get quizNoClosingTimeShort => 'বন্ধের সময় নেই';

  @override
  String get quizClosingTimeHint => 'ঐচ্ছিক · খোলার সময়ের পরে হতে হবে';

  @override
  String get quizShuffleQuestions =>
      'প্রতি চেষ্টায় একবার প্রশ্নগুলো এলোমেলো করুন';

  @override
  String get quizShuffleOptions =>
      'প্রতি চেষ্টায় একবার বিকল্পগুলো এলোমেলো করুন';

  @override
  String messageProblem(String text) {
    return 'সমস্যা: $text';
  }

  @override
  String messageMessage(String text) {
    return 'বার্তা: $text';
  }

  @override
  String get adminSetupSectionAccounts => 'অ্যাকাউন্ট';

  @override
  String get adminSetupSectionCatalog => 'ক্লাস ও বিষয়';

  @override
  String get adminSetupSectionTimetable => 'সময়সূচি';

  @override
  String get adminSetupSectionSchedule => 'আজকের সময়সূচি';

  @override
  String get adminSetupSectionSharedPhones => 'ভাগ করা ফোন';

  @override
  String get adminSetupSectionHolidays => 'ছুটি';

  @override
  String get adminSetupSectionIssues => 'সমস্যা';

  @override
  String get adminSetupSectionRecords => 'ক্লাসের রেকর্ড';

  @override
  String get adminSetupSectionPicker => 'বিভাগ';

  @override
  String adminSetupRefresh(String section) {
    return '$section রিফ্রেশ করুন';
  }

  @override
  String get adminSetupLogOut => 'লগ আউট';

  @override
  String get adminSetupLoading => 'লোড হচ্ছে';

  @override
  String get adminSetupSaving => 'সংরক্ষণ হচ্ছে';

  @override
  String get adminSetupRetry => 'আবার চেষ্টা করুন';

  @override
  String adminSetupLoadFailed(String reason) {
    return 'এই তালিকা লোড করা যায়নি। $reason';
  }

  @override
  String get adminSetupUnknownError =>
      'কিছু একটা ভুল হয়েছে। দয়া করে আবার চেষ্টা করুন।';

  @override
  String get adminSetupNotSaved =>
      'পরিবর্তনটি সংরক্ষণ করা যায়নি। রিফ্রেশ করে আবার চেষ্টা করুন।';

  @override
  String get adminSetupCancel => 'বাতিল করুন';

  @override
  String get adminSetupSave => 'সংরক্ষণ করুন';

  @override
  String get adminSetupClose => 'বন্ধ করুন';

  @override
  String get adminSetupDelete => 'মুছুন';

  @override
  String get adminSetupRemove => 'সরান';

  @override
  String get adminSetupEdit => 'সম্পাদনা';

  @override
  String adminSetupEditNamed(String name) {
    return '$name সম্পাদনা করুন';
  }

  @override
  String adminSetupRequiredField(String field) {
    return '$field দিতেই হবে।';
  }

  @override
  String get adminSetupNoDate => 'ঠিক করা নেই';

  @override
  String adminSetupDateValue(String field, String date) {
    return '$field: $date';
  }

  @override
  String adminSetupClearDate(String field) {
    return '$field মুছুন';
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
  String get adminSetupDateField => 'তারিখ';

  @override
  String get adminSetupInactive => 'নিষ্ক্রিয় করা হয়েছে';

  @override
  String get adminSetupFilterAll => 'সব';

  @override
  String get adminSetupShowFilter => 'দেখান';

  @override
  String get adminSetupRoleStudent => 'শিক্ষার্থী';

  @override
  String get adminSetupRoleTeacher => 'শিক্ষক';

  @override
  String get adminSetupAddPerson => 'ব্যক্তি যোগ করুন';

  @override
  String get adminSetupSearchLabel => 'নাম বা ফোন নম্বর দিয়ে খুঁজুন';

  @override
  String get adminSetupSearchButton => 'খুঁজুন';

  @override
  String get adminSetupAccountTypeHeading => 'অ্যাকাউন্টের ধরন';

  @override
  String get adminSetupAssignmentHeading => 'ক্লাস বা বিষয়ের দায়িত্ব';

  @override
  String adminSetupAccountsShown(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি অ্যাকাউন্ট দেখানো হচ্ছে।',
      one: '1টি অ্যাকাউন্ট দেখানো হচ্ছে।',
      zero: 'কোনো মিলে যাওয়া অ্যাকাউন্ট নেই।',
    );
    return '$_temp0';
  }

  @override
  String adminSetupTeachersHeading(int count) {
    return 'শিক্ষক ($count)';
  }

  @override
  String adminSetupStudentsHeading(int count) {
    return 'শিক্ষার্থী ($count)';
  }

  @override
  String get adminSetupNameField => 'নাম';

  @override
  String get adminSetupPhoneField => 'ফোন নম্বর';

  @override
  String get adminSetupRoleField => 'ভূমিকা';

  @override
  String get adminSetupTeacherPairsHeading =>
      'এই শিক্ষক যেসব ক্লাস ও বিষয় পড়ান';

  @override
  String get adminSetupNoPairs => 'এখনও কিছু নেই। পরে যোগ করতে পারবেন।';

  @override
  String get adminSetupClassField => 'ক্লাস';

  @override
  String get adminSetupSubjectField => 'বিষয়';

  @override
  String get adminSetupAddPair => 'ক্লাস ও বিষয় যোগ করুন';

  @override
  String adminSetupPairLabel(String className, String subject) {
    return '$className, $subject';
  }

  @override
  String adminSetupRemovePair(String className, String subject) {
    return '$className, $subject সরান';
  }

  @override
  String get adminSetupNoSubjectsInClass =>
      'এই ক্লাসে এখনও কোনো বিষয় নেই। ক্লাস ও বিষয় অংশে বিষয় যোগ করুন।';

  @override
  String get adminSetupNoActiveClasses =>
      'এখনও কোনো চালু ক্লাস নেই। ক্লাস ও বিষয় অংশে একটি যোগ করুন।';

  @override
  String adminSetupPersonAdded(String name) {
    return '$name যোগ করা হয়েছে।';
  }

  @override
  String adminSetupEditPerson(String name) {
    return '$name সম্পাদনা করুন';
  }

  @override
  String get adminSetupPhoneChangeNote =>
      'ফোন নম্বর বদলালে এই ব্যক্তি সব ফোন থেকে সাইন আউট হয়ে যাবেন।';

  @override
  String adminSetupPersonSaved(String name) {
    return '$name-এর পরিবর্তন সংরক্ষিত হয়েছে।';
  }

  @override
  String get adminSetupDeactivate => 'নিষ্ক্রিয় করুন';

  @override
  String get adminSetupActivate => 'সক্রিয় করুন';

  @override
  String adminSetupDeactivateNamed(String name) {
    return '$name নিষ্ক্রিয় করুন';
  }

  @override
  String adminSetupActivateNamed(String name) {
    return '$name সক্রিয় করুন';
  }

  @override
  String adminSetupDeactivateTitle(String name) {
    return '$name নিষ্ক্রিয় করবেন?';
  }

  @override
  String adminSetupDeactivateMessage(String name) {
    return '$name সাইন আউট হয়ে যাবেন এবং অ্যাকাউন্টটি আবার সক্রিয় না হওয়া পর্যন্ত সাইন ইন করতে পারবেন না।';
  }

  @override
  String adminSetupActivated(String name) {
    return '$name আবার সাইন ইন করতে পারবেন।';
  }

  @override
  String adminSetupDeactivated(String name) {
    return '$name নিষ্ক্রিয় করা হয়েছে।';
  }

  @override
  String get adminSetupSignOutEverywhere => 'সব জায়গা থেকে সাইন আউট করুন';

  @override
  String adminSetupSignOutNamed(String name) {
    return '$name-কে সব জায়গা থেকে সাইন আউট করুন';
  }

  @override
  String adminSetupSignOutTitle(String name) {
    return '$name-কে সব জায়গা থেকে সাইন আউট করবেন?';
  }

  @override
  String adminSetupSignOutMessage(String name) {
    return 'এতে প্রতিটি ফোনে $name-এর সাইন ইন শেষ হয়ে যাবে, যেমন অন্য কেউ তাঁর নম্বর ব্যবহার করে থাকলে। তিনি তাঁর ফোন নম্বর দিয়ে আবার সাইন ইন করতে পারবেন।';
  }

  @override
  String adminSetupSignedOut(String name) {
    return '$name-কে সব জায়গা থেকে সাইন আউট করা হয়েছে।';
  }

  @override
  String get adminSetupStudentClassAction => 'ক্লাস বদলান';

  @override
  String get adminSetupTeacherAssignmentsAction => 'ক্লাস ও বিষয়';

  @override
  String adminSetupStudentDetail(String className) {
    return 'শিক্ষার্থী। ক্লাস: $className';
  }

  @override
  String get adminSetupStudentNoClass => 'শিক্ষার্থী। এখনও কোনো ক্লাস নেই।';

  @override
  String adminSetupTeacherDetail(String pairs) {
    return 'শিক্ষক। পড়ান: $pairs';
  }

  @override
  String get adminSetupTeacherNoPairs =>
      'শিক্ষক। এখনও কোনো ক্লাস বা বিষয় নেই।';

  @override
  String adminSetupPhoneDetail(String phone) {
    return 'ফোন: $phone';
  }

  @override
  String adminSetupClassDialogTitle(String name) {
    return '$name-এর ক্লাস';
  }

  @override
  String adminSetupRemoveFromClass(String className) {
    return '$className থেকে সরান';
  }

  @override
  String adminSetupStudentEnrolled(String name, String className) {
    return '$name এখন $className-এ আছে।';
  }

  @override
  String adminSetupStudentRemoved(String name) {
    return '$name-কে তার ক্লাস থেকে সরানো হয়েছে।';
  }

  @override
  String adminSetupAssignmentsTitle(String name) {
    return '$name-এর ক্লাস ও বিষয়';
  }

  @override
  String get adminSetupCurrentPairs => 'এখন পড়ান';

  @override
  String adminSetupPairAdded(String name, String className, String subject) {
    return '$name এখন $className, $subject পড়ান।';
  }

  @override
  String adminSetupPairRemoved(String name, String className, String subject) {
    return '$name আর $className, $subject পড়ান না।';
  }

  @override
  String get adminSetupClassesHeading => 'ক্লাস';

  @override
  String get adminSetupSubjectsHeading => 'বিষয়';

  @override
  String get adminSetupAddClass => 'ক্লাস যোগ করুন';

  @override
  String get adminSetupAddSubject => 'বিষয় যোগ করুন';

  @override
  String get adminSetupNoClasses => 'এখনও কোনো ক্লাস নেই।';

  @override
  String get adminSetupNoSubjects => 'এখনও কোনো বিষয় নেই।';

  @override
  String get adminSetupSubjectsButton => 'বিষয়';

  @override
  String adminSetupClassSubjects(String className) {
    return '$className-এর বিষয়';
  }

  @override
  String adminSetupArchiveNamed(String name) {
    return '$name আর্কাইভ করুন';
  }

  @override
  String adminSetupRestoreNamed(String name) {
    return '$name ফিরিয়ে আনুন';
  }

  @override
  String get adminSetupNoSubjectsToChoose =>
      'এখনও কোনো চালু বিষয় নেই। আগে একটি বিষয় যোগ করুন।';

  @override
  String get adminSetupAddLesson => 'সময়সূচিতে পাঠ যোগ করুন';

  @override
  String get adminSetupEditLesson => 'সময়সূচির পাঠ সম্পাদনা করুন';

  @override
  String get adminSetupAllTeachers => 'সব শিক্ষক';

  @override
  String get adminSetupAllClasses => 'সব ক্লাস';

  @override
  String get adminSetupTeacherField => 'শিক্ষক';

  @override
  String get adminSetupWeekdayField => 'সপ্তাহের দিন';

  @override
  String get adminSetupStartField => 'শুরুর সময়';

  @override
  String get adminSetupEndField => 'শেষের সময়';

  @override
  String get adminSetupTimeHelper => '24 ঘণ্টার ভারতীয় সময় (IST), যেমন 09:30';

  @override
  String adminSetupTimeInvalid(String field) {
    return '$field 24 ঘণ্টার সময় হিসেবে লিখুন, যেমন 09:30।';
  }

  @override
  String get adminSetupEndBeforeStart => 'পাঠ শুরু হওয়ার পরে শেষ হতে হবে।';

  @override
  String get adminSetupUntilBeforeFrom =>
      'শেষ তারিখ প্রথম তারিখের দিন বা তার পরে হতে হবে।';

  @override
  String get adminSetupValidFrom => 'প্রথম তারিখ';

  @override
  String get adminSetupValidUntil => 'শেষ তারিখ';

  @override
  String get adminSetupLessonField => 'পাঠের প্লেলিস্ট (ঐচ্ছিক)';

  @override
  String get adminSetupNoLesson => 'কোনো পাঠের প্লেলিস্ট নেই';

  @override
  String get adminSetupNoLessonsFound =>
      'এই ক্লাস ও বিষয়ের জন্য এই শিক্ষকের এখনও কোনো পাঠের প্লেলিস্ট নেই।';

  @override
  String get adminSetupShowInactive => 'নিষ্ক্রিয় করা পাঠও দেখান';

  @override
  String get adminSetupNoTimetable => 'কোনো সময়সূচির পাঠ মেলেনি।';

  @override
  String adminSetupEntryTitle(
    String start,
    String end,
    String subject,
    String className,
  ) {
    return '$start থেকে $end: $subject, $className';
  }

  @override
  String adminSetupEntryTeacher(String name) {
    return 'শিক্ষক: $name';
  }

  @override
  String adminSetupEntryLesson(String title) {
    return 'পাঠের প্লেলিস্ট: $title';
  }

  @override
  String get adminSetupEntryNoLesson =>
      'কোনো পাঠের প্লেলিস্ট বেছে নেওয়া হয়নি।';

  @override
  String adminSetupEntryFrom(String date) {
    return '$date থেকে';
  }

  @override
  String adminSetupEntryUntil(String date) {
    return '$date পর্যন্ত';
  }

  @override
  String get adminSetupDateChanges => 'তারিখের পরিবর্তন';

  @override
  String adminSetupDateChangesNamed(String title) {
    return '$title-এর তারিখের পরিবর্তন';
  }

  @override
  String get adminSetupDeactivateLesson => 'নিষ্ক্রিয় করুন';

  @override
  String get adminSetupReactivateLesson => 'আবার সক্রিয় করুন';

  @override
  String get adminSetupDeactivateLessonTitle => 'এই পাঠ নিষ্ক্রিয় করবেন?';

  @override
  String adminSetupDeactivateLessonMessage(
    String subject,
    String className,
    String weekday,
    String start,
  ) {
    return '$weekday $start-এ $className-এর $subject আর সময়সূচিতে থাকবে না।';
  }

  @override
  String get adminSetupLessonSaved => 'সময়সূচি সংরক্ষিত হয়েছে।';

  @override
  String get adminSetupLessonDeactivated => 'পাঠ নিষ্ক্রিয় করা হয়েছে।';

  @override
  String get adminSetupLessonReactivated => 'পাঠ আবার সক্রিয় করা হয়েছে।';

  @override
  String adminSetupClassSubjectFixed(String className, String subject) {
    return '$className, $subject। ক্লাস বা বিষয় বদলাতে এই পাঠ নিষ্ক্রিয় করে একটি নতুন পাঠ যোগ করুন।';
  }

  @override
  String adminSetupDateChangesTitle(String lesson, String weekday) {
    return 'তারিখের পরিবর্তন: $lesson, প্রতি $weekday';
  }

  @override
  String get adminSetupNoDateChanges => 'তারিখের কোনো পরিবর্তন নেই।';

  @override
  String get adminSetupAddDateChange => 'একটি তারিখ বদলান';

  @override
  String get adminSetupCancelledLabel => 'এই তারিখে বাতিল।';

  @override
  String adminSetupSubstituteLabel(String name) {
    return 'বদলি শিক্ষক: $name';
  }

  @override
  String get adminSetupDifferentLesson =>
      'এই তারিখে অন্য একটি পাঠের প্লেলিস্ট ব্যবহার হবে।';

  @override
  String adminSetupNoteLabel(String note) {
    return 'নোট: $note';
  }

  @override
  String get adminSetupClearChange => 'পরিবর্তন মুছুন';

  @override
  String adminSetupClearChangeNamed(String date) {
    return '$date-এর পরিবর্তন মুছুন';
  }

  @override
  String adminSetupEditDateChangeNamed(String date) {
    return '$date-এর পরিবর্তন সম্পাদনা করুন';
  }

  @override
  String adminSetupChangeCleared(String date) {
    return '$date-এর পরিবর্তন মুছে ফেলা হয়েছে।';
  }

  @override
  String adminSetupDateChangeTitle(String lesson) {
    return 'একটি তারিখ বদলান: $lesson';
  }

  @override
  String get adminSetupCancelOnDate => 'এই তারিখে পাঠ বাতিল করুন';

  @override
  String get adminSetupSubstituteField => 'বদলি শিক্ষক (ঐচ্ছিক)';

  @override
  String adminSetupRegularTeacher(String name) {
    return 'কোনো বদলি নেই ($name পড়াবেন)';
  }

  @override
  String get adminSetupDateLessonField => 'এই তারিখের পাঠের প্লেলিস্ট';

  @override
  String get adminSetupUsualLesson => 'সাধারণত যেমন থাকে';

  @override
  String get adminSetupNoteField => 'নোট (ঐচ্ছিক)';

  @override
  String adminSetupDateChangeSaved(String date) {
    return '$date-এর পরিবর্তন সংরক্ষিত হয়েছে।';
  }

  @override
  String get adminSetupChooseDateFirst => 'একটি তারিখ বেছে নিন।';

  @override
  String get adminSetupPreviousDay => 'আগের দিন';

  @override
  String get adminSetupNextDay => 'পরের দিন';

  @override
  String get adminSetupToday => 'আজ';

  @override
  String adminSetupScheduleFor(String date) {
    return '$date-এর পাঠ';
  }

  @override
  String get adminSetupNoLessonsOnDay => 'এই তারিখে কোনো পাঠ নেই।';

  @override
  String adminSetupScheduleSubstitute(String name) {
    return 'শিক্ষক: $name (বদলি)';
  }

  @override
  String adminSetupStateLabel(String state) {
    return 'অবস্থা: $state';
  }

  @override
  String get adminSetupStateUpcoming => 'আসছে';

  @override
  String get adminSetupStateLive => 'এখন চলছে';

  @override
  String get adminSetupStateHeld => 'হয়েছে';

  @override
  String get adminSetupStateCancelled => 'বাতিল';

  @override
  String get adminSetupStateNotStarted => 'শুরু হয়নি';

  @override
  String get adminSetupLessonReady => 'পাঠের প্লেলিস্ট তৈরি।';

  @override
  String get adminSetupSharedPhoneNote =>
      'শেয়ার করা ফোনে প্রত্যেকে প্রথমে শেয়ার করা ফোন নম্বর দেবেন, তারপর নিজের ছোট প্রোফাইল নম্বর দেবেন। প্রোফাইল নম্বর শুধু ঠিক করে কার অ্যাকাউন্ট খুলবে। এটি পাসওয়ার্ড নয়।';

  @override
  String get adminSetupAddSharedPhone => 'শেয়ার করা ফোন যোগ করুন';

  @override
  String get adminSetupEditSharedPhone => 'শেয়ার করা ফোন সম্পাদনা করুন';

  @override
  String get adminSetupSharedPhoneName => 'নাম, যেমন ক্লাস 5-এর ফোন';

  @override
  String get adminSetupSharedPhoneNumber => 'শেয়ার করা ফোন নম্বর';

  @override
  String get adminSetupSharedPhoneActiveSwitch =>
      'শেয়ার করা ফোন ব্যবহার করা যাবে';

  @override
  String get adminSetupSharedPhoneSaved => 'শেয়ার করা ফোন সেভ হয়েছে।';

  @override
  String get adminSetupNoSharedPhones => 'এখনও কোনো শেয়ার করা ফোন নেই।';

  @override
  String adminSetupGroupNumber(String phone) {
    return 'নম্বর: $phone';
  }

  @override
  String adminSetupMemberLine(String name, String role, String code) {
    return '$name, $role। প্রোফাইল নম্বর $code';
  }

  @override
  String get adminSetupNoMembers => 'এই ফোনে এখনও কেউ নেই।';

  @override
  String get adminSetupAddMember => 'ব্যক্তি যোগ করুন';

  @override
  String adminSetupAddMemberTitle(String group) {
    return '$group-এ একজন ব্যক্তি যোগ করুন';
  }

  @override
  String get adminSetupSearchPeople => 'নাম বা ফোন নম্বর দিয়ে লোক খুঁজুন';

  @override
  String get adminSetupNoPeopleFound => 'মেলে এমন কেউ নেই।';

  @override
  String get adminSetupPersonField => 'ব্যক্তি';

  @override
  String adminSetupPersonOption(String name, String role, String phone) {
    return '$name, $role, $phone';
  }

  @override
  String get adminSetupChoosePerson => 'একজন ব্যক্তি বেছে নিন।';

  @override
  String get adminSetupProfileCodeField => 'প্রোফাইল নম্বর';

  @override
  String get adminSetupProfileCodeHelper =>
      '1 থেকে 4 অঙ্ক, এই ফোনের প্রত্যেক ব্যক্তির জন্য আলাদা।';

  @override
  String get adminSetupProfileCodeInvalid =>
      '1 থেকে 4 অঙ্কের একটি প্রোফাইল নম্বর দিন।';

  @override
  String adminSetupMemberAdded(String name, String group) {
    return '$name-কে $group-এ যোগ করা হয়েছে।';
  }

  @override
  String adminSetupRemoveMemberNamed(String name, String group) {
    return '$group থেকে $name-কে সরান';
  }

  @override
  String adminSetupRemoveMemberTitle(String name, String group) {
    return '$group থেকে $name-কে সরাবেন?';
  }

  @override
  String adminSetupRemoveMemberMessage(String name) {
    return '$name আর এই শেয়ার করা ফোনে নিজের প্রোফাইল বেছে নিতে পারবেন না।';
  }

  @override
  String adminSetupMemberRemoved(String name, String group) {
    return '$name-কে $group থেকে সরানো হয়েছে।';
  }

  @override
  String get adminSetupHolidayNote => 'ছুটির দিনে কোনো পাঠ রাখা হয় না।';

  @override
  String get adminSetupAddHoliday => 'ছুটি যোগ করুন';

  @override
  String get adminSetupHolidayName => 'ছুটির নাম';

  @override
  String get adminSetupNoHolidays => 'এখনও কোনো ছুটি নেই।';

  @override
  String adminSetupHolidayAdded(String name, String date) {
    return '$date তারিখে $name যোগ করা হয়েছে।';
  }

  @override
  String adminSetupDeleteHolidayNamed(String name, String date) {
    return '$date তারিখের $name মুছুন';
  }

  @override
  String get adminSetupDeleteHolidayTitle => 'এই ছুটি মুছবেন?';

  @override
  String adminSetupDeleteHolidayMessage(String name, String date) {
    return '$date তারিখের $name সরানো হবে, এবং ওই তারিখে আবার পাঠ রাখা হবে।';
  }

  @override
  String get adminSetupHolidayDeleted => 'ছুটি মুছে ফেলা হয়েছে।';

  @override
  String get adminSetupIssuesOpen => 'খোলা';

  @override
  String get adminSetupIssuesResolved => 'সমাধান হয়েছে';

  @override
  String get adminSetupNoIssues => 'দেখানোর মতো কোনো সমস্যা নেই।';

  @override
  String adminSetupIssueSeen(int count, String when) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count বার দেখা গেছে।',
      one: 'একবার দেখা গেছে।',
    );
    return '$_temp0 শেষ দেখা গেছে $when।';
  }

  @override
  String get adminSetupMarkResolved => 'সমাধান হয়েছে বলে চিহ্নিত করুন';

  @override
  String adminSetupMarkResolvedNamed(String message) {
    return 'সমাধান হয়েছে বলে চিহ্নিত করুন: $message';
  }

  @override
  String get adminSetupIssueResolved =>
      'সমস্যাটি সমাধান হয়েছে বলে চিহ্নিত করা হয়েছে।';

  @override
  String get adminSetupRecordsLive => 'লাইভ';

  @override
  String get adminSetupRecordsEnded => 'শেষ হয়েছে';

  @override
  String get adminSetupNoRecords => 'দেখানোর মতো কোনো ক্লাস নেই।';

  @override
  String adminSetupRecordTitle(String subject, String className) {
    return '$subject, $className';
  }

  @override
  String get adminSetupRecordLive => 'এখন লাইভ';

  @override
  String adminSetupRecordLiveUntil(String clock) {
    return 'এখন লাইভ। শেষ হবে $clock-এ';
  }

  @override
  String adminSetupRecordStarted(String when) {
    return 'শুরু হয়েছে $when';
  }

  @override
  String adminSetupRecordEnded(String when) {
    return 'শেষ হয়েছে $when';
  }

  @override
  String get adminSetupEndedByTeacher => 'শিক্ষক ক্লাস শেষ করেছেন।';

  @override
  String get adminSetupEndedByAdmin => 'একজন প্রশাসক ক্লাস শেষ করেছেন।';

  @override
  String get adminSetupEndedAutomatically =>
      'নির্ধারিত সময়ে ক্লাস নিজে থেকেই শেষ হয়েছে।';

  @override
  String adminSetupEndedOther(String reason) {
    return 'শেষ হওয়ার কারণ: $reason';
  }

  @override
  String adminSetupStudentsJoined(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count জন শিক্ষার্থী যোগ দিয়েছে।',
      one: '1 জন শিক্ষার্থী যোগ দিয়েছে।',
      zero: 'কোনো শিক্ষার্থী যোগ দেয়নি।',
    );
    return '$_temp0';
  }

  @override
  String adminSetupExtensionMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count মিনিট অতিরিক্ত যোগ করা হয়েছে।',
      one: '1 মিনিট অতিরিক্ত যোগ করা হয়েছে।',
      zero: 'কোনো অতিরিক্ত সময় যোগ করা হয়নি।',
    );
    return '$_temp0';
  }

  @override
  String get adminSetupAddFifteen => '15 মিনিট যোগ করুন';

  @override
  String adminSetupAddFifteenNamed(String title) {
    return '$title-এ 15 মিনিট যোগ করুন';
  }

  @override
  String get adminSetupEndForEveryone => 'সবার জন্য ক্লাস শেষ করুন';

  @override
  String adminSetupEndForEveryoneNamed(String title) {
    return 'সবার জন্য $title শেষ করুন';
  }

  @override
  String get adminSetupEndTitle => 'সবার জন্য এই ক্লাস শেষ করবেন?';

  @override
  String adminSetupEndMessage(String title) {
    return 'শিক্ষক এবং সব শিক্ষার্থীর জন্য $title এখনই শেষ হবে।';
  }

  @override
  String get adminSetupKeepClass => 'ক্লাস চালু রাখুন';

  @override
  String get adminSetupEndClass => 'ক্লাস শেষ করুন';

  @override
  String get adminSetupEnded => 'ক্লাস শেষ করা হয়েছে।';

  @override
  String adminSetupExtended(String clock) {
    return 'ক্লাস এখন $clock-এ শেষ হবে।';
  }

  @override
  String get loginScreenName => 'সাইন ইন';

  @override
  String get loginIntro =>
      'আপনার ফোন নম্বর টাইপ করুন। নম্বর পুরো হলেই সাইন ইন নিজে থেকে শুরু হবে।';

  @override
  String get loginPhoneField => 'ফোন নম্বর। নম্বর কী দিয়ে টাইপ করুন।';

  @override
  String get loginPhoneLabel => 'ফোন নম্বর';

  @override
  String get loginProfileField => 'এই শেয়ার করা ফোনে আপনার প্রোফাইল নম্বর';

  @override
  String get loginProfileLabel => 'প্রোফাইল নম্বর';

  @override
  String get loginEnterProfileCode =>
      'এই ফোনটি শেয়ার করা। আপনার প্রোফাইল নম্বর টাইপ করুন।';

  @override
  String get loginKeySignIn => 'সাইন ইন';

  @override
  String get loginKeyContinue => 'এগিয়ে যান';

  @override
  String get loginKeySim => 'SIM কার্ড থেকে আমার নম্বর ভরে দিন';

  @override
  String get loginKeyAdmin => 'প্রশাসক সাইন ইন';

  @override
  String get loginKeyChangeNumber => 'অন্য নম্বর ব্যবহার করুন';

  @override
  String get loginErrorEnterPhone => 'আগে আপনার ফোন নম্বর টাইপ করুন।';

  @override
  String get loginErrorEnterProfile => 'আগে আপনার প্রোফাইল নম্বর টাইপ করুন।';

  @override
  String get loginNumberNotRegistered =>
      'এই নম্বরটি নিবন্ধিত নয়। আপনাকে যোগ করতে আপনার স্কুলের প্রশাসককে বলুন।';

  @override
  String get loginProfileNotRecognised =>
      'ওই প্রোফাইল নম্বরটি এই ফোনে নেই। আবার চেষ্টা করুন।';

  @override
  String get loginAdminUsesPassword =>
      'প্রশাসকেরা পাসওয়ার্ড দিয়ে সাইন ইন করেন। 3 টিপুন।';

  @override
  String get loginSigningIn => 'সাইন ইন হচ্ছে।';

  @override
  String get adminLoginScreenName => 'প্রশাসক সাইন ইন';

  @override
  String get adminLoginIntro =>
      'আপনার ফোন নম্বর ও পাসওয়ার্ড টাইপ করুন, প্রতিটির পরে ওকে টিপুন, তারপর 1 টিপুন।';

  @override
  String get classNoLongerLive => 'ওই ক্লাসটি এখন লাইভ নেই।';

  @override
  String get classAlertTitle => 'ক্লাস শুরু হয়েছে';

  @override
  String get classAlertBody => 'আপনার ক্লাস শুরু হয়েছে। যোগ দিতে খুলুন।';

  @override
  String get classAlertWaitingBody => 'আপনার ক্লাস লাইভ চলছে। যোগ দিতে খুলুন।';

  @override
  String get classAlertChannelName => 'ক্লাস শুরু হচ্ছে';

  @override
  String get classAlertChannelDescription =>
      'আপনার ক্লাস শুরু হলে সর্বোচ্চ এক মিনিট রিং বাজে।';

  @override
  String get classAlertWaitingChannelName => 'ক্লাস লাইভ';

  @override
  String get classAlertWaitingChannelDescription =>
      'আপনার ক্লাস লাইভ থাকা পর্যন্ত থাকে, যাতে আপনি যোগ দিতে পারেন।';

  @override
  String get classAlertStarted => 'আপনার ক্লাস শুরু হয়েছে।';

  @override
  String classAlertSubjectStarted(String subject) {
    return '$subject ক্লাস শুরু হয়েছে।';
  }

  @override
  String get classAlertKeys => 'যোগ দিতে ওকে বা 1 টিপুন। রিং থামাতে 0 টিপুন।';

  @override
  String get classAlertJoin => 'ক্লাসে যোগ দিন';

  @override
  String get classAlertNotNow => 'এখন নয়';

  @override
  String get homeTitle => 'হোম';

  @override
  String get homeChecking => 'আপনার ক্লাস খোঁজা হচ্ছে।';

  @override
  String get homeOffline =>
      'ইন্টারনেট নেই। আবার অনলাইন হলে আপনার ক্লাস দেখা যাবে।';

  @override
  String get homeSignInAgain => 'অনুগ্রহ করে আবার সাইন ইন করুন।';

  @override
  String get homeStarForAll => 'সব বিকল্পের জন্য স্টার টিপুন।';

  @override
  String homeBriefLive(String subject) {
    return '$subject ক্লাস লাইভ চলছে। যোগ দিতে 1 টিপুন।';
  }

  @override
  String homeBriefNext(String subject, String time) {
    return 'পরের ক্লাস: $time-এ $subject। অপেক্ষার সময় আপনি অন্য বিকল্প ব্যবহার করতে পারেন।';
  }

  @override
  String get homeBriefNoClass =>
      'এখন কোনো ক্লাস নেই। শেখা চালিয়ে যেতে 2 টিপুন।';

  @override
  String homeJoinClass(String subject) {
    return '$subject ক্লাসে যোগ দিন';
  }

  @override
  String get homeNoClassNow => 'এখন কোনো ক্লাস নেই';

  @override
  String get homeNoClassReason =>
      'আপনার শিক্ষক ক্লাস শুরু করলে সেটি নিজে থেকেই এখানে দেখা যাবে।';

  @override
  String homeJoinWhenStarts(String subject, String time) {
    return '$time-এ $subject শুরু হলে নিজে থেকে যোগ দিন';
  }

  @override
  String get homeCancelAutoJoin => 'নিজে থেকে যোগ দেওয়া বন্ধ করুন';

  @override
  String homeAutoJoinArmed(String subject) {
    return 'আপনি এই স্ক্রিনে থাকলে, আপনার শিক্ষক $subject শুরু করলেই আমি সেটি খুলব। আপনি মিউট অবস্থায় যোগ দেবেন। বাতিল করতে 1 টিপুন।';
  }

  @override
  String get homeAutoJoinCancelled => 'নিজে থেকে যোগ দেওয়া বাতিল হয়েছে।';

  @override
  String get homeAutoJoinLeft =>
      'আপনি হোম স্ক্রিন ছেড়ে যাওয়ায় নিজে থেকে যোগ দেওয়া বন্ধ হয়েছে।';

  @override
  String homeAutoJoined(String subject) {
    return '$subject শুরু হয়েছে। এখন আপনাকে মিউট অবস্থায় যোগ করা হচ্ছে।';
  }

  @override
  String get homeReturningToClass => 'আপনার ক্লাসে ফিরে যাওয়া হচ্ছে।';

  @override
  String get homeContinueLearning => 'শেখা চালিয়ে যান';

  @override
  String get homeNothingToContinue =>
      'চালিয়ে যাওয়ার মতো এখনও কিছু নেই। শেখার যাত্রার জন্য 3 টিপুন।';

  @override
  String homeContinuing(String title) {
    return '$title চালিয়ে যাওয়া হচ্ছে।';
  }

  @override
  String get homeJourneys => 'শেখার যাত্রা';

  @override
  String get homeQuizzes => 'কুইজ';

  @override
  String get homeMore => 'আরও';

  @override
  String get homeMoreBrief => 'কম ব্যবহৃত বিকল্প।';

  @override
  String homeYourClass(String className) {
    return 'আপনার ক্লাস: $className।';
  }

  @override
  String homeSubjectInClass(String subject, String className) {
    return '$subject, $className';
  }

  @override
  String teacherHomeBriefLive(String subject) {
    return 'আপনার $subject ক্লাস লাইভ চলছে। ফিরে যেতে 1 টিপুন।';
  }

  @override
  String teacherHomeBriefReady(String place) {
    return '$place তৈরি। শুরু করতে 1 টিপুন।';
  }

  @override
  String teacherHomeBriefNext(String place, String time) {
    return 'পরের ক্লাস: $place, $time-এ।';
  }

  @override
  String get teacherHomeBriefNoClass => 'এখন আপনার সময়সূচিতে কোনো ক্লাস নেই।';

  @override
  String teacherHomeReturn(String subject) {
    return '$subject ক্লাসে ফিরে যান';
  }

  @override
  String teacherHomeStart(String place) {
    return '$place শুরু করুন';
  }

  @override
  String teacherHomeNext(String place, String time) {
    return 'পরের: $place, $time-এ';
  }

  @override
  String teacherHomeOpensAt(String time) {
    return 'আপনি $time থেকে এটি শুরু করতে পারবেন।';
  }

  @override
  String get teacherHomeNoClassReason =>
      'এখন কিছু নির্ধারিত নেই। তবুও পড়াতে চাইলে আরও-র জন্য 5 টিপুন, তারপর 3।';

  @override
  String get teacherHomeStarting => 'আপনার ক্লাস শুরু হচ্ছে।';

  @override
  String teacherHomeStarted(String subject) {
    return '$subject ক্লাস শুরু হয়েছে। আপনার শিক্ষার্থীদের ডাকা হচ্ছে।';
  }

  @override
  String get teacherHomeUnscheduled => 'সময়সূচির বাইরে একটি ক্লাস শুরু করুন';

  @override
  String get teacherHomeUnscheduledTitle => 'আপনি এখন কোন ক্লাস পড়াতে চান?';

  @override
  String get teacherHomeAlreadyLive =>
      'আপনার একটি ক্লাস আগে থেকেই লাইভ চলছে। ফিরে যেতে হোমে 1 টিপুন।';

  @override
  String get teacherHomeChangeWorkspace => 'পাঠের জন্য ক্লাস ও বিষয় বদলান';

  @override
  String get teacherHomeOneWorkspace => 'আপনি একটি ক্লাস ও বিষয় পড়ান।';

  @override
  String teacherHomeContentFor(String place) {
    return 'পাঠ, কুইজ ও প্লেলিস্ট $place-এর জন্য।';
  }

  @override
  String teacherHomeLaterItem(String place, String time) {
    return 'পরে: $place, $time-এ।';
  }

  @override
  String get keyClassListWhoJoined =>
      'ক্লাসের তালিকা: কে আছে, কে চলে গেছে, কে যোগ দেয়নি';

  @override
  String get keyMuteAllStudents => 'সব শিক্ষার্থীকে মিউট করুন';

  @override
  String get keyTeacherToolsAddTimeOrEnd =>
      'শিক্ষকের টুল: সময় বাড়ান বা সবার জন্য ক্লাস শেষ করুন';

  @override
  String get sessionMicAskOnce =>
      'আপনি মিউট অবস্থায় যোগ দেন। SEEDS এখন মাইক্রোফোন ব্যবহারের অনুমতি চাইবে, যাতে আপনি যখন চান তখন কথা বলতে পারেন।';

  @override
  String get sessionMicAskAgain => 'কথা বলতে মাইক্রোফোনের অনুমতি দিন।';

  @override
  String get sessionMicStillOff =>
      'মাইক্রোফোন এখনও বন্ধ। আপনি শুনতে থাকতে পারেন।';

  @override
  String get sessionMicSettingsTitle => 'মাইক্রোফোন আটকানো আছে';

  @override
  String get sessionMicSettingsMessage =>
      'Android আর জিজ্ঞাসা করবে না। কথা বলতে সেটিংস খুলুন, Permissions বেছে নিন, এবং মাইক্রোফোনের অনুমতি দিন। আপনি শুনতে থাকতে পারেন।';

  @override
  String get sessionMicSettingsOpen => 'সেটিংস খুলুন';

  @override
  String get sessionMicSettingsCancel => 'শুনতে থাকুন';

  @override
  String get sessionMuteAllButton => '2: সব শিক্ষার্থীকে মিউট করুন';

  @override
  String get sessionMuteAllLabel => 'সব শিক্ষার্থীকে মিউট করুন';

  @override
  String get sessionMuteAllWaiting =>
      'এখনও সবাইকে মিউট করা হচ্ছে। অনুগ্রহ করে অপেক্ষা করুন।';

  @override
  String sessionMuteAllDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count জন শিক্ষার্থীকে মিউট করা হয়েছে।',
      one: '1 জন শিক্ষার্থীকে মিউট করা হয়েছে।',
    );
    return '$_temp0';
  }

  @override
  String get sessionMuteAllNone => 'সব শিক্ষার্থী আগে থেকেই মিউট ছিল।';

  @override
  String sessionMuteAllNotConfirmed(String reason) {
    return 'সবাইকে মিউট করা নিশ্চিত হয়নি। $reason আবার চেষ্টা করতে 2 টিপুন।';
  }

  @override
  String get sessionClassListButton => '3: ক্লাসের তালিকা';

  @override
  String sessionClassListLabel(String people) {
    return 'ক্লাসের তালিকা। $people';
  }

  @override
  String get sessionClassListTitle => 'ক্লাসের তালিকা';

  @override
  String sessionRosterCounts(int here, int left, int notJoined) {
    return '$here জন আছে, $left জন চলে গেছে, $notJoined জন এখনও যোগ দেয়নি।';
  }

  @override
  String sessionHereNow(int count) {
    return 'এখন আছে: $count';
  }

  @override
  String sessionLeftClass(int count) {
    return 'যোগ দিয়ে চলে গেছে: $count';
  }

  @override
  String sessionNotJoined(int count) {
    return 'এখনও যোগ দেয়নি: $count';
  }

  @override
  String get sessionHereNowTitle => 'এখন আছে';

  @override
  String get sessionLeftClassTitle => 'যোগ দিয়ে চলে গেছে';

  @override
  String get sessionNotJoinedTitle => 'এখনও যোগ দেয়নি';

  @override
  String sessionRemovedName(String name) {
    return '$name, আপনি সরিয়ে দিয়েছেন';
  }

  @override
  String get sessionNobody => 'কেউ নেই।';

  @override
  String get sessionRemindNotJoined =>
      'যারা যোগ দেয়নি সেই শিক্ষার্থীদের রিং করুন';

  @override
  String get sessionEveryoneJoined => 'সবাই যোগ দিয়েছে।';

  @override
  String sessionReminderSent(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count জন শিক্ষার্থীকে রিং করা হচ্ছে।',
      one: '1 জন শিক্ষার্থীকে রিং করা হচ্ছে।',
      zero: 'এখন রিং করার মতো কেউ নেই।',
    );
    return '$_temp0';
  }

  @override
  String sessionReminderSentSomeWaiting(int queued, int cooling) {
    return '$queued জনকে রিং করা হচ্ছে। $cooling জনকে গত 5 মিনিটে রিং করা হয়েছে, তাই এখনই আবার রিং করা হবে না।';
  }

  @override
  String get sessionRosterUnavailable =>
      'ক্লাসের তালিকা পড়া যায়নি। আবার চেষ্টা করুন।';

  @override
  String get sessionAddTime => '15 মিনিট যোগ করুন';

  @override
  String get sessionCannotAddTime =>
      'পরের ক্লাসের আগে আর সময় যোগ করা যাবে না।';

  @override
  String sessionEndsBy(String clock) {
    return 'ক্লাস $clock-এর মধ্যে শেষ হবে।';
  }

  @override
  String sessionExtendedUntil(String clock) {
    return 'হয়ে গেছে। ক্লাস এখন $clock-এর মধ্যে শেষ হবে।';
  }

  @override
  String sessionEndingSoonTeacher(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: 'ক্লাস $minutes মিনিটের মধ্যে নিজে থেকেই শেষ হবে।',
      one: 'ক্লাস 1 মিনিটের মধ্যে নিজে থেকেই শেষ হবে।',
    );
    return '$_temp0';
  }

  @override
  String sessionEndingSoonTeacherExtend(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other:
          'ক্লাস $minutes মিনিটের মধ্যে নিজে থেকেই শেষ হবে। 15 মিনিট যোগ করতে 5 টিপুন, তারপর 1 টিপুন।',
      one:
          'ক্লাস 1 মিনিটের মধ্যে নিজে থেকেই শেষ হবে। 15 মিনিট যোগ করতে 5 টিপুন, তারপর 1 টিপুন।',
    );
    return '$_temp0';
  }

  @override
  String sessionEndingSoonStudent(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: 'ক্লাস $minutes মিনিটের মধ্যে শেষ হবে।',
      one: 'ক্লাস 1 মিনিটের মধ্যে শেষ হবে।',
    );
    return '$_temp0';
  }

  @override
  String get sessionLessonReady =>
      'আজকের পাঠ তৈরি। ক্লাসের জন্য চালাতে 4 টিপুন, তারপর 3 টিপুন।';

  @override
  String get sessionLessonNextReady =>
      'আজকের পাঠের পরের অংশ তৈরি। চালাতে 7 টিপুন।';

  @override
  String get sessionJoinedStudentBrief =>
      'আপনি ক্লাসে আছেন এবং মিউট আছেন। কথা বলতে 1 টিপুন, হাত তুলতে 2 টিপুন।';

  @override
  String get sessionJoinedTeacherBrief =>
      'আপনার ক্লাস লাইভ চলছে। আপনি মিউট আছেন। কথা বলতে 1 টিপুন, সব শিক্ষার্থীকে মিউট করতে 2 টিপুন।';

  @override
  String get sessionStarForKeys => 'সব কী জানতে স্টার টিপুন।';

  @override
  String settingsAutoDownload(String state) {
    return 'Wi-Fi-তে নতুন যাত্রা অফলাইন ব্যবহারের জন্য তৈরি করুন: $state';
  }

  @override
  String get settingsAutoDownloadOn => 'Wi-Fi-তে যাত্রাগুলি তৈরি করা হবে।';

  @override
  String get settingsAutoDownloadOff => 'যাত্রাগুলি নিজে থেকে তৈরি করা হবে না।';

  @override
  String get adminSetupTeacherNeedsPair =>
      'শিক্ষকের জন্য অন্তত একটি ক্লাস ও বিষয় যোগ করুন।';

  @override
  String get adminSetupTeacherHasNoPairs =>
      'এখনও কোনো শিক্ষকের ক্লাস ও বিষয় নেই। আগে অ্যাকাউন্ট-এ গিয়ে কোনো শিক্ষককে সেগুলি দিন।';

  @override
  String get adminSetupDaysField => 'দিন';

  @override
  String get adminSetupChooseDays => 'অন্তত একটি দিন বেছে নিন।';

  @override
  String adminSetupLessonsAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি পাঠ যোগ করা হয়েছে, প্রতিটি দিনের জন্য একটি।',
      one: 'পাঠ যোগ করা হয়েছে।',
    );
    return '$_temp0';
  }

  @override
  String get adminSetupArrangeBy => 'যেভাবে সাজাবেন';

  @override
  String get adminSetupArrangeDay => 'দিন';

  @override
  String get adminSetupArrangeTeacher => 'শিক্ষক';

  @override
  String get adminSetupArrangeClass => 'ক্লাস';

  @override
  String adminSetupGroupHeading(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি পাঠ',
      one: '1টি পাঠ',
    );
    return '$name · $_temp0';
  }

  @override
  String adminSetupEntryDayTitle(String day, String title) {
    return '$day, $title';
  }

  @override
  String get adminSetupTimetableSearch => 'পাঠ খুঁজুন';

  @override
  String get adminSetupNoMatchingLessons => 'কোনো পাঠ মেলেনি।';

  @override
  String sessionMoreButton(String key) {
    return '$key: আরও';
  }

  @override
  String get sessionMoreLabel => 'আরও বিকল্প';

  @override
  String get sessionMoreTitle => 'আরও বিকল্প';

  @override
  String get sessionMoreClassroomCheck => 'ক্লাস যাচাই';

  @override
  String get sessionMoreWhatIsPlaying => 'কী চলছে';

  @override
  String get sessionMoreWhoIsHere => 'ক্লাসে কে কে আছে';

  @override
  String get sessionKeyClassList => 'ক্লাসের তালিকা';

  @override
  String get sessionKeyLessonRecording => 'পাঠের রেকর্ডিং';

  @override
  String get sessionKeyAnswerQuestion => 'প্রশ্নের উত্তর দিন';

  @override
  String get sessionKeyMore => 'আরও বিকল্প';

  @override
  String get sessionKeyLeave => 'ক্লাস ছেড়ে যান';

  @override
  String get sessionEndClassButton => '6: সবার জন্য ক্লাস শেষ করুন';

  @override
  String get sessionEndClassLabel =>
      'সবার জন্য ক্লাস শেষ করুন। নিশ্চিত করতে বলবে';

  @override
  String sessionActivityQuizItem(String title, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি প্রশ্ন',
      one: '1টি প্রশ্ন',
    );
    return 'কুইজ: $title, $_temp0';
  }

  @override
  String sessionActivityJourneyItem(String title) {
    return 'যাত্রা: $title';
  }

  @override
  String sessionActivityStopItem(String title) {
    return '$title দেওয়া বন্ধ করুন';
  }

  @override
  String sessionActivityStartedTeacher(String title) {
    return '$title ক্লাসের জন্য খোলা হয়েছে। এর অবস্থা জানতে 7 টিপুন।';
  }

  @override
  String sessionActivityStoppedTeacher(String title) {
    return '$title আর ক্লাসে দেওয়া হচ্ছে না। শিক্ষার্থীরা এখনও হোম-এ এটি খুঁজে পাবে।';
  }

  @override
  String sessionActivityQuizStarted(String title) {
    return 'আপনার শিক্ষক একটি কুইজ দিয়েছেন: $title। শুরু করতে 5 টিপুন।';
  }

  @override
  String sessionActivityJourneyStarted(String title) {
    return 'আপনার শিক্ষক একটি শেখার যাত্রা দিয়েছেন: $title। শুরু করতে 5 টিপুন।';
  }

  @override
  String sessionActivityStoppedStudent(String title) {
    return '$title ক্লাসে বন্ধ হয়েছে। আপনি এখনও হোম-এ এটি খুঁজে পাবেন।';
  }

  @override
  String sessionActivityStartQuizLabel(String title) {
    return 'কুইজ $title শুরু করুন';
  }

  @override
  String sessionActivityStartJourneyLabel(String title) {
    return 'যাত্রা $title শুরু করুন';
  }

  @override
  String sessionActivityStateStudent(String title) {
    return '$title খোলা আছে।';
  }

  @override
  String sessionActivityStateTeacher(String title) {
    return '$title ক্লাসের জন্য খোলা আছে।';
  }

  @override
  String sessionActivityOpening(String title) {
    return '$title খোলা হচ্ছে।';
  }

  @override
  String sessionActivityCouldNotOpen(String title) {
    return '$title খোলা যায়নি। আপনার সংযোগ দেখে আবার চেষ্টা করুন।';
  }

  @override
  String get sessionBackInClass => 'আবার ক্লাসে।';

  @override
  String sessionActivityProgress(String title, int started, int finished) {
    return '$title: $started জন শুরু করেছে, $finished জন শেষ করেছে।';
  }

  @override
  String get sessionWhatIsPlayingButton => '3: কী চলছে';

  @override
  String get sessionKeyEndClass => 'সবার জন্য ক্লাস শেষ করুন';

  @override
  String get sessionKeyWhatIsPlaying => 'কী চলছে';

  @override
  String get sessionQuizButton => '6: কুইজ';

  @override
  String get sessionJourneyButton => '7: যাত্রা';

  @override
  String get sessionQuizLabel => 'ক্লাসের জন্য একটি কুইজ শুরু করুন';

  @override
  String get sessionJourneyLabel => 'ক্লাসের জন্য একটি যাত্রা শুরু করুন';

  @override
  String sessionOpenLabel(String title) {
    return '$title খোলা আছে। কারা বাকি আছে শুনুন, তাদের মনে করিয়ে দিন, অথবা এটি বন্ধ করুন';
  }

  @override
  String get sessionKeyQuiz => 'ক্লাসের জন্য কুইজ';

  @override
  String get sessionKeyJourney => 'ক্লাসের জন্য যাত্রা';

  @override
  String sessionStartQuizButton(String title) {
    return '5: কুইজ শুরু করুন: $title';
  }

  @override
  String sessionStartJourneyButton(String title) {
    return '5: যাত্রা শুরু করুন: $title';
  }

  @override
  String get sessionPickQuizTitle => 'ক্লাসের জন্য একটি কুইজ শুরু করুন';

  @override
  String get sessionPickJourneyTitle => 'ক্লাসের জন্য একটি যাত্রা শুরু করুন';

  @override
  String get sessionNoQuizToStart =>
      'এই ক্লাস ও বিষয়ের জন্য কোনো প্রকাশিত কুইজ খোলা নেই। আগে হোম-এর কুইজ থেকে একটি প্রকাশ করুন।';

  @override
  String get sessionNoJourneyToStart =>
      'এই ক্লাস ও বিষয়ের জন্য কোনো প্রকাশিত যাত্রা নেই। আগে হোম-এর যাত্রা থেকে একটি প্রকাশ করুন।';

  @override
  String sessionFinishedOf(int finished, int enrolled) {
    return '$enrolled জনের মধ্যে $finished জন শেষ করেছে।';
  }

  @override
  String sessionLeftInClass(int count) {
    return 'ক্লাসে আছে, শেষ করেনি ($count)';
  }

  @override
  String sessionLeftWholeClass(int count) {
    return 'পুরো ক্লাস, শেষ করেনি ($count)';
  }

  @override
  String get sessionLeftInClassTitle => 'ক্লাসে আছে, শেষ করেনি';

  @override
  String get sessionLeftWholeClassTitle => 'পুরো ক্লাস, শেষ করেনি';

  @override
  String get sessionRemindLeft => 'ক্লাসে যারা শেষ করেনি তাদের মনে করিয়ে দিন';

  @override
  String get sessionStartDifferentQuiz => 'অন্য একটি কুইজ শুরু করুন';

  @override
  String get sessionStartDifferentJourney => 'অন্য একটি যাত্রা শুরু করুন';

  @override
  String sessionLeftNotStarted(String name) {
    return '$name, শুরু করেনি';
  }

  @override
  String sessionLeftStarted(String name) {
    return '$name, শুরু করেছে, শেষ করেনি';
  }

  @override
  String get sessionLeftHere => 'ক্লাসে আছে';

  @override
  String get sessionLeftAway => 'ক্লাসে নেই';

  @override
  String get sessionLeftNobodyInClass => 'ক্লাসে উপস্থিত সবাই শেষ করেছে।';

  @override
  String get sessionLeftNobody => 'ক্লাসের সবাই শেষ করেছে।';

  @override
  String sessionRemindedLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count জন শিক্ষার্থীকে মনে করানো হয়েছে।',
      one: '1 জন শিক্ষার্থীকে মনে করানো হয়েছে।',
      zero: 'ক্লাসে কাউকে মনে করানোর দরকার নেই।',
    );
    return '$_temp0';
  }

  @override
  String sessionActivityReminderQuiz(String title) {
    return 'আপনার শিক্ষক আপনাকে কুইজ $title করার কথা মনে করিয়ে দিচ্ছেন। শুরু করতে 5 টিপুন।';
  }

  @override
  String sessionActivityReminderJourney(String title) {
    return 'আপনার শিক্ষক আপনাকে শেখার যাত্রা $title করার কথা মনে করিয়ে দিচ্ছেন। শুরু করতে 5 টিপুন।';
  }

  @override
  String get sessionKeyStartActivity => 'কুইজ বা যাত্রা শুরু করুন';

  @override
  String get startupSettingsKey2 => '2. সেটিংস';

  @override
  String get libraryPauseSessionKey3 => 'পুরো সেশনের জন্য অডিও থামান, কী 3';

  @override
  String get authSaveNewPasswordKey1 => '1: নতুন পাসওয়ার্ড সংরক্ষণ করুন';

  @override
  String get quizSaveSettingsKey1 => '1: সেটিংস সেভ করুন';

  @override
  String get quizSaveQuestionKey1 => '1: প্রশ্ন সেভ করুন';

  @override
  String get quizContinueToQuestionsKey1 => '1: প্রশ্নে এগিয়ে যান';

  @override
  String get adminAuthorSection => 'কুইজ ও শেখার যাত্রা';

  @override
  String get adminAuthorNote =>
      'একজন শিক্ষকের হয়ে কুইজ ও শেখার যাত্রা তৈরি ও প্রকাশ করুন। আপনি যা তৈরি করবেন তা ওই শিক্ষকেরই হবে, শুধু তাঁর প্রশ্ন ব্যাংক ও তাঁর নিজের রেকর্ডিং ব্যবহার করবে, এবং শিক্ষককে তাঁর হোম-এ এ বিষয়ে জানানো হবে।';

  @override
  String get adminAuthorTeacher => 'শিক্ষক';

  @override
  String get adminAuthorWorkspace => 'ক্লাস ও বিষয়';

  @override
  String adminAuthorWorkspaceName(String className, String subjectName) {
    return '$className, $subjectName';
  }

  @override
  String get adminAuthorNoTeachers =>
      'এখনও কোনো শিক্ষকের ক্লাস ও বিষয় নেই। আগে অ্যাকাউন্ট-এ গিয়ে একটি দিন।';

  @override
  String get adminAuthorKind => 'দেখান';

  @override
  String get adminAuthorKindQuizzes => 'কুইজ';

  @override
  String get adminAuthorKindJourneys => 'যাত্রা';

  @override
  String get adminAuthorNewQuiz => 'নতুন কুইজ';

  @override
  String get adminAuthorNewJourney => 'নতুন যাত্রা';

  @override
  String adminAuthorNewQuizFor(String teacher) {
    return '$teacher-এর জন্য নতুন কুইজ';
  }

  @override
  String adminAuthorNewJourneyFor(String teacher) {
    return '$teacher-এর জন্য নতুন যাত্রা';
  }

  @override
  String get adminAuthorNoQuizzes =>
      'এই ক্লাস ও বিষয়ের জন্য এই শিক্ষকের কোনো কুইজ নেই।';

  @override
  String get adminAuthorNoJourneys =>
      'এই ক্লাস ও বিষয়ের জন্য এই শিক্ষকের কোনো যাত্রা নেই।';

  @override
  String get adminAuthorStatusDraft => 'খসড়া';

  @override
  String get adminAuthorStatusPublished => 'প্রকাশিত';

  @override
  String get adminAuthorStatusScheduled => 'প্রকাশিত, পরে খুলবে';

  @override
  String get adminAuthorStatusClosed => 'বন্ধ';

  @override
  String get adminAuthorStatusArchived => 'আর্কাইভ করা';

  @override
  String adminAuthorStatusChanged(String status) {
    return '$status, অপ্রকাশিত পরিবর্তন সহ';
  }

  @override
  String adminAuthorQuestionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি প্রশ্ন',
      one: '1টি প্রশ্ন',
    );
    return '$_temp0';
  }

  @override
  String adminAuthorStepCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি ধাপ',
      one: '1টি ধাপ',
    );
    return '$_temp0';
  }

  @override
  String get adminAuthorMode => 'কুইজের ধরন';

  @override
  String get adminAuthorModeGraded => 'নম্বরযুক্ত';

  @override
  String get adminAuthorModePractice => 'অনুশীলন';

  @override
  String get adminAuthorEdit => 'সম্পাদনা';

  @override
  String adminAuthorEditNamed(String title) {
    return '$title সম্পাদনা করুন';
  }

  @override
  String get adminAuthorPublish => 'প্রকাশ করুন';

  @override
  String adminAuthorPublishNamed(String title) {
    return '$title প্রকাশ করুন';
  }

  @override
  String get adminAuthorClose => 'কুইজ বন্ধ করুন';

  @override
  String adminAuthorCloseNamed(String title) {
    return '$title বন্ধ করুন';
  }

  @override
  String get adminAuthorArchive => 'আর্কাইভ করুন';

  @override
  String adminAuthorArchiveNamed(String title) {
    return '$title আর্কাইভ করুন';
  }

  @override
  String get adminAuthorPublishQuizTitle => 'এই কুইজটি প্রকাশ করবেন?';

  @override
  String adminAuthorPublishQuizMessage(String title, String teacher) {
    return '$title ক্লাসের জন্য $teacher-এর কুইজ হিসেবে খুলবে, এবং শিক্ষার্থীদের বিজ্ঞপ্তি পাঠানো হবে।';
  }

  @override
  String get adminAuthorPublishJourneyTitle => 'এই যাত্রাটি প্রকাশ করবেন?';

  @override
  String adminAuthorPublishJourneyMessage(String title, String teacher) {
    return '$title ক্লাসের জন্য $teacher-এর যাত্রা হিসেবে পাওয়া যাবে, এবং শিক্ষার্থীদের বিজ্ঞপ্তি পাঠানো হবে।';
  }

  @override
  String get adminAuthorCloseQuizTitle => 'এই কুইজটি বন্ধ করবেন?';

  @override
  String adminAuthorCloseQuizMessage(String title) {
    return 'শিক্ষার্থীরা আর $title-এর উত্তর দিতে পারবে না। অসমাপ্ত চেষ্টাগুলি যেমন আছে তেমনই জমা হয়ে যাবে।';
  }

  @override
  String get adminAuthorArchiveTitle => 'এই যাত্রাটি আর্কাইভ করবেন?';

  @override
  String adminAuthorArchiveMessage(String title) {
    return 'শিক্ষার্থীরা আর $title দেখতে পাবে না।';
  }

  @override
  String adminAuthorPublished(String title) {
    return '$title প্রকাশিত হয়েছে।';
  }

  @override
  String adminAuthorClosed(String title) {
    return '$title বন্ধ হয়েছে।';
  }

  @override
  String adminAuthorArchived(String title) {
    return '$title আর্কাইভ করা হয়েছে।';
  }

  @override
  String adminAuthorCreated(String title) {
    return '$title খসড়া হিসেবে তৈরি হয়েছে।';
  }

  @override
  String get adminAuthorSaved => 'যাত্রা সেভ হয়েছে।';

  @override
  String adminAuthorNotReady(String problems) {
    return 'এই কুইজটি এখনও প্রকাশের জন্য তৈরি নয়। $problems';
  }

  @override
  String get adminAuthorTitle => 'শিরোনাম';

  @override
  String get adminAuthorDescription => 'বিবরণ (ঐচ্ছিক)';

  @override
  String get adminAuthorQuizSettings => 'কুইজ সেটিংস';

  @override
  String adminAuthorEditQuiz(String title) {
    return 'কুইজ সম্পাদনা: $title';
  }

  @override
  String adminAuthorEditJourney(String title) {
    return 'যাত্রা সম্পাদনা: $title';
  }

  @override
  String get adminAuthorQuestions => 'প্রশ্ন';

  @override
  String get adminAuthorNoQuestions => 'এখনও কোনো প্রশ্ন নেই।';

  @override
  String adminAuthorQuestionLine(int number, String text) {
    return '$number. $text';
  }

  @override
  String adminAuthorCorrectAnswer(String answer) {
    return 'সঠিক উত্তর: $answer';
  }

  @override
  String get adminAuthorRemove => 'সরান';

  @override
  String adminAuthorRemoveNamed(String item) {
    return '$item সরান';
  }

  @override
  String get adminAuthorAddNewQuestion => 'নতুন প্রশ্ন লিখুন';

  @override
  String get adminAuthorAddBankQuestion => 'প্রশ্ন ব্যাংক থেকে যোগ করুন';

  @override
  String get adminAuthorQuestionText => 'প্রশ্ন';

  @override
  String adminAuthorOption(int number) {
    return 'বিকল্প $number';
  }

  @override
  String adminAuthorOptionalOption(int number) {
    return 'বিকল্প $number (ঐচ্ছিক)';
  }

  @override
  String get adminAuthorCorrectOption => 'সঠিক উত্তর';

  @override
  String get adminAuthorCorrectIsBlank =>
      'সঠিক উত্তরটি খালি। এটি পূরণ করুন অথবা অন্য বিকল্প বেছে নিন।';

  @override
  String get adminAuthorExplanation => 'ব্যাখ্যা (ঐচ্ছিক)';

  @override
  String get adminAuthorSaveToBank => 'শিক্ষকের প্রশ্ন ব্যাংকেও সেভ করুন';

  @override
  String get adminAuthorNeedFourOptions => 'চারটি বিকল্পই পূরণ করুন।';

  @override
  String get adminAuthorNeedTwoOptions => 'অন্তত দুটি বিকল্প পূরণ করুন।';

  @override
  String get adminAuthorDuplicateOptions => 'প্রতিটি বিকল্প আলাদা হতে হবে।';

  @override
  String adminAuthorRequired(String field) {
    return '$field দেওয়া আবশ্যক।';
  }

  @override
  String get adminAuthorAdd => 'যোগ করুন';

  @override
  String adminAuthorAddNamed(String item) {
    return '$item যোগ করুন';
  }

  @override
  String get adminAuthorBankTitle => 'শিক্ষকের প্রশ্ন ব্যাংক';

  @override
  String get adminAuthorBankEmpty =>
      'এই ক্লাস ও বিষয়ের জন্য এই শিক্ষকের কোনো সেভ করা প্রশ্ন নেই।';

  @override
  String get adminAuthorDone => 'হয়ে গেছে';

  @override
  String get adminAuthorGraded => 'নম্বরযুক্ত: প্রশ্নগুলিতে নম্বর দিন';

  @override
  String get adminAuthorRetries => 'ভুল উত্তরের পর আবার চেষ্টার সংখ্যা';

  @override
  String get adminAuthorSteps => 'ধাপ';

  @override
  String get adminAuthorNoSteps => 'এখনও কোনো ধাপ নেই।';

  @override
  String adminAuthorStepRecording(String title) {
    return 'রেকর্ডিং: $title';
  }

  @override
  String adminAuthorStepNarration(String text) {
    return 'বর্ণনা: $text';
  }

  @override
  String adminAuthorStepQuestion(String text) {
    return 'প্রশ্ন: $text';
  }

  @override
  String adminAuthorStepPoll(String text) {
    return 'পোল: $text';
  }

  @override
  String get adminAuthorMoveUp => 'উপরে সরান';

  @override
  String adminAuthorMoveUpNamed(String item) {
    return '$item উপরে সরান';
  }

  @override
  String get adminAuthorMoveDown => 'নিচে সরান';

  @override
  String adminAuthorMoveDownNamed(String item) {
    return '$item নিচে সরান';
  }

  @override
  String get adminAuthorAddRecording => 'রেকর্ডিং যোগ করুন';

  @override
  String get adminAuthorAddNarration => 'বর্ণনা যোগ করুন';

  @override
  String get adminAuthorAddQuestion => 'প্রশ্ন যোগ করুন';

  @override
  String get adminAuthorAddPoll => 'পোল যোগ করুন';

  @override
  String get adminAuthorRecordingsTitle => 'শিক্ষকের রেকর্ডিং';

  @override
  String get adminAuthorRecordingsNote =>
      'শুধু এই শিক্ষক এই ক্লাস ও বিষয়ের জন্য যে রেকর্ডিংগুলি আপলোড করেছেন, সেগুলিই ব্যবহার করা যাবে।';

  @override
  String get adminAuthorNoRecordings =>
      'এই শিক্ষক এই ক্লাস ও বিষয়ের জন্য কোনো রেকর্ডিং আপলোড করেননি।';

  @override
  String get adminAuthorNarrationText => 'বর্ণনার লেখা';

  @override
  String get adminAuthorPollText => 'পোলের প্রশ্ন';

  @override
  String get adminAuthorSaveJourney => 'যাত্রা সেভ করুন';

  @override
  String sessionPeopleJoined(String names) {
    return '$names যোগ দিয়েছে।';
  }

  @override
  String sessionPeopleLeft(String names) {
    return '$names চলে গেছে।';
  }

  @override
  String sessionNamesAnd(String first, String last) {
    return '$first এবং $last';
  }

  @override
  String sessionHereOf(int here, int total) {
    return '$total জনের মধ্যে $here জন আছে।';
  }

  @override
  String sessionHereCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'এখানে $count জন শিক্ষার্থী আছে।',
      one: 'এখানে 1 জন শিক্ষার্থী আছে।',
      zero: 'এখানে কোনো শিক্ষার্থী নেই।',
    );
    return '$_temp0';
  }

  @override
  String sessionStartSummary(int here, int total) {
    return '$total জন শিক্ষার্থীর মধ্যে $here জন আছে।';
  }

  @override
  String uiFocusedField(String field) {
    return 'আপনি $field-এ আছেন।';
  }

  @override
  String get sessionStartButton => '4: শুরু করুন';

  @override
  String get sessionStartLabel =>
      'ক্লাসের জন্য কুইজ, যাত্রা বা রেকর্ডিং শুরু করুন';

  @override
  String get sessionStartTitle => 'ক্লাসের জন্য শুরু করুন';

  @override
  String get sessionStartQuiz => 'কুইজ';

  @override
  String get sessionStartJourney => 'যাত্রা';

  @override
  String get sessionStartRecording => 'রেকর্ডিং';

  @override
  String sessionStatusKeyButton(String title) {
    return '7: $title-এর অবস্থা';
  }

  @override
  String sessionStatusKeyLabel(String title) {
    return '$title-এর অবস্থা';
  }

  @override
  String get sessionKeyStart => 'কুইজ, যাত্রা বা রেকর্ডিং শুরু করুন';

  @override
  String get sessionKeyStatus => 'যা চলছে তার অবস্থা';

  @override
  String sessionActivityCounts(int present, int started, int finished) {
    return 'ক্লাসে $present জন শিক্ষার্থী আছে। $started জন চেষ্টা করেছে, $finished জন শেষ করেছে।';
  }

  @override
  String get sessionNowPlayingTitle => 'রেকর্ডিংটি';

  @override
  String get noticeActorAdmin => 'আপনার প্রশাসক';

  @override
  String noticeQuizCreated(String actor, String title) {
    return '$actor কুইজ $title যোগ করেছেন।';
  }

  @override
  String noticeQuizPublished(String actor, String title) {
    return '$actor কুইজ $title প্রকাশ করেছেন।';
  }

  @override
  String noticeQuizClosed(String actor, String title) {
    return '$actor কুইজ $title বন্ধ করেছেন।';
  }

  @override
  String noticeJourneyCreated(String actor, String title) {
    return '$actor শেখার যাত্রা $title যোগ করেছেন।';
  }

  @override
  String noticeJourneyPublished(String actor, String title) {
    return '$actor শেখার যাত্রা $title প্রকাশ করেছেন।';
  }

  @override
  String noticeJourneyArchived(String actor, String title) {
    return '$actor শেখার যাত্রা $title আর্কাইভ করেছেন।';
  }

  @override
  String noticePlaylistPublished(String actor, String title) {
    return '$actor প্লেলিস্ট $title প্রকাশ করেছেন।';
  }

  @override
  String noticeLessonCreated(String actor, String title) {
    return '$actor পাঠ $title যোগ করেছেন।';
  }

  @override
  String noticeLessonUpdated(String actor, String title) {
    return '$actor পাঠ $title বদলেছেন।';
  }

  @override
  String noticeLessonRemoved(String actor, String title) {
    return '$actor পাঠ $title সরিয়ে দিয়েছেন।';
  }

  @override
  String noticeLessonRemovedOn(String actor, String title, String date) {
    return '$actor $date তারিখের পাঠ $title থেকে আপনাকে সরিয়ে দিয়েছেন।';
  }

  @override
  String noticeLessonCancelled(String actor, String title, String date) {
    return '$actor $date তারিখের পাঠ $title বাতিল করেছেন।';
  }

  @override
  String noticeLessonSubstitute(String actor, String title, String date) {
    return '$actor আপনাকে $date তারিখে পাঠ $title পড়াতে বলেছেন।';
  }

  @override
  String noticeLessonCovered(String actor, String title, String date) {
    return '$actor $date তারিখের আপনার পাঠ $title অন্য একজন শিক্ষককে দিয়েছেন।';
  }

  @override
  String keypadKeyFor(String key, String action) {
    return '$action-এর জন্য $key';
  }

  @override
  String keypadPressKeys(String keys) {
    return '$keys টিপুন।';
  }

  @override
  String get keypadKeySeparator => ', ';

  @override
  String get keypadStarHelp => 'সাহায্যের জন্য স্টার টিপুন।';

  @override
  String get sessionCloseRecording => 'ক্লাসের জন্য রেকর্ডিং বন্ধ করুন';

  @override
  String sessionRecordingClosedTeacher(String title) {
    return '$title ক্লাসের জন্য বন্ধ করা হয়েছে।';
  }

  @override
  String sessionRecordingClosedStudent(String title) {
    return 'আপনার শিক্ষক রেকর্ডিং $title বন্ধ করেছেন।';
  }

  @override
  String get adminSetupSpeechLanguageField => 'বলার ভাষা';

  @override
  String get adminSetupSpeechRateField => 'বলার গতি';

  @override
  String get adminSetupSpeechNotSet => 'ঠিক করা নেই (ব্যক্তি নিজে বেছে নেবেন)';

  @override
  String get adminSetupSpeechHelp =>
      'ব্যক্তির ফোনে সেটিংস না খুলেই ব্যবহার হয়। তিনি সেখানে এটি বদলাতেও পারেন।';

  @override
  String get loginSimNumberUsed => 'এই ফোনের নম্বর ব্যবহার করা হয়েছে।';

  @override
  String get loginSimNumberFilled =>
      'এই ফোনের নম্বর ভরা হয়েছে। সাইন ইন করতে 1 টিপুন, অথবা অন্য নম্বর টাইপ করুন।';

  @override
  String messagePressToRetry(String key) {
    return 'আবার চেষ্টা করতে $key টিপুন।';
  }

  @override
  String get sessionHandQueuedRaise =>
      'সংযোগ নেই। সংযোগ ফিরলেই আপনার হাত উঠবে। বাতিল করতে 2 টিপুন।';

  @override
  String get sessionHandQueuedLower =>
      'সংযোগ নেই। সংযোগ ফিরলেই আপনার হাত নামবে। বাতিল করতে 2 টিপুন।';

  @override
  String get sessionHandQueueCancelled => 'হাত তোলার অনুরোধ বাতিল হয়েছে।';

  @override
  String get quizAnswerQueued =>
      'সংযোগ নেই। আপনার উত্তর রাখা আছে, সংযোগ ফিরলেই পাঠানো হবে।';
}
