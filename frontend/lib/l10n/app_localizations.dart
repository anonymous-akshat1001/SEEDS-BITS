import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_kn.dart';
import 'app_localizations_te.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bn'),
    Locale('en'),
    Locale('hi'),
    Locale('kn'),
    Locale('te'),
  ];

  /// Ten words for the digits 0 to 9, comma separated, in order.
  ///
  /// In en, this message translates to:
  /// **'zero, one, two, three, four, five, six, seven, eight, nine'**
  String get spokenDigitWords;

  /// Twelve month names, comma separated, January first.
  ///
  /// In en, this message translates to:
  /// **'January, February, March, April, May, June, July, August, September, October, November, December'**
  String get spokenMonths;

  /// Seven weekday names, comma separated, Monday first.
  ///
  /// In en, this message translates to:
  /// **'Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday'**
  String get spokenWeekdays;

  /// Spoken for a leading + in a phone number.
  ///
  /// In en, this message translates to:
  /// **'plus'**
  String get spokenPlus;

  /// No description provided for @spokenSession.
  ///
  /// In en, this message translates to:
  /// **'session {number}'**
  String spokenSession(String number);

  /// No description provided for @spokenNoon.
  ///
  /// In en, this message translates to:
  /// **'12 noon'**
  String get spokenNoon;

  /// No description provided for @spokenMidnight.
  ///
  /// In en, this message translates to:
  /// **'midnight'**
  String get spokenMidnight;

  /// No description provided for @spokenOClock.
  ///
  /// In en, this message translates to:
  /// **'{hour} o\'clock'**
  String spokenOClock(String hour);

  /// No description provided for @spokenMorning.
  ///
  /// In en, this message translates to:
  /// **'{clock} in the morning'**
  String spokenMorning(String clock);

  /// No description provided for @spokenAfternoon.
  ///
  /// In en, this message translates to:
  /// **'{clock} in the afternoon'**
  String spokenAfternoon(String clock);

  /// No description provided for @spokenEvening.
  ///
  /// In en, this message translates to:
  /// **'{clock} in the evening'**
  String spokenEvening(String clock);

  /// No description provided for @spokenNight.
  ///
  /// In en, this message translates to:
  /// **'{clock} at night'**
  String spokenNight(String clock);

  /// No description provided for @spokenToday.
  ///
  /// In en, this message translates to:
  /// **'today'**
  String get spokenToday;

  /// No description provided for @spokenTomorrow.
  ///
  /// In en, this message translates to:
  /// **'tomorrow'**
  String get spokenTomorrow;

  /// No description provided for @spokenYesterday.
  ///
  /// In en, this message translates to:
  /// **'yesterday'**
  String get spokenYesterday;

  /// No description provided for @spokenDate.
  ///
  /// In en, this message translates to:
  /// **'{weekday} {day} {month}'**
  String spokenDate(String weekday, String day, String month);

  /// No description provided for @spokenDateWithYear.
  ///
  /// In en, this message translates to:
  /// **'{weekday} {day} {month} {year}'**
  String spokenDateWithYear(
    String weekday,
    String day,
    String month,
    String year,
  );

  /// No description provided for @spokenDateAtTime.
  ///
  /// In en, this message translates to:
  /// **'{date} at {time}'**
  String spokenDateAtTime(String date, String time);

  /// No description provided for @spokenHours.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 hour} other{{count} hours}}'**
  String spokenHours(int count);

  /// No description provided for @spokenMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 minute} other{{count} minutes}}'**
  String spokenMinutes(int count);

  /// No description provided for @spokenSeconds.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 second} other{{count} seconds}}'**
  String spokenSeconds(int count);

  /// No description provided for @spokenPositionOf.
  ///
  /// In en, this message translates to:
  /// **'{position} of {total}'**
  String spokenPositionOf(String position, String total);

  /// No description provided for @spokenPercent.
  ///
  /// In en, this message translates to:
  /// **'{value} percent'**
  String spokenPercent(String value);

  /// No description provided for @spokenOn.
  ///
  /// In en, this message translates to:
  /// **'on'**
  String get spokenOn;

  /// No description provided for @spokenOff.
  ///
  /// In en, this message translates to:
  /// **'off'**
  String get spokenOff;

  /// No description provided for @keyBack10Seconds.
  ///
  /// In en, this message translates to:
  /// **'Back 10 seconds'**
  String get keyBack10Seconds;

  /// No description provided for @keyPlayOrPause.
  ///
  /// In en, this message translates to:
  /// **'Play or pause'**
  String get keyPlayOrPause;

  /// No description provided for @keyForward10Seconds.
  ///
  /// In en, this message translates to:
  /// **'Forward 10 seconds'**
  String get keyForward10Seconds;

  /// No description provided for @keySlower.
  ///
  /// In en, this message translates to:
  /// **'Slower'**
  String get keySlower;

  /// No description provided for @keyFaster.
  ///
  /// In en, this message translates to:
  /// **'Faster'**
  String get keyFaster;

  /// No description provided for @keySlowerPlaybackSpeed.
  ///
  /// In en, this message translates to:
  /// **'Slower playback speed'**
  String get keySlowerPlaybackSpeed;

  /// No description provided for @keyFasterPlaybackSpeed.
  ///
  /// In en, this message translates to:
  /// **'Faster playback speed'**
  String get keyFasterPlaybackSpeed;

  /// No description provided for @keyLogin.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get keyLogin;

  /// No description provided for @keyRegister.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get keyRegister;

  /// No description provided for @keySettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get keySettings;

  /// No description provided for @keySelectStudentAccount.
  ///
  /// In en, this message translates to:
  /// **'Select Student Account'**
  String get keySelectStudentAccount;

  /// No description provided for @keySelectTeacherAccount.
  ///
  /// In en, this message translates to:
  /// **'Select Teacher Account'**
  String get keySelectTeacherAccount;

  /// No description provided for @keySelectAdministratorAccount.
  ///
  /// In en, this message translates to:
  /// **'Select Administrator Account'**
  String get keySelectAdministratorAccount;

  /// No description provided for @keyGoToLogin.
  ///
  /// In en, this message translates to:
  /// **'Go to Login'**
  String get keyGoToLogin;

  /// No description provided for @keyToggleTeacherRegistration.
  ///
  /// In en, this message translates to:
  /// **'Toggle Teacher Registration'**
  String get keyToggleTeacherRegistration;

  /// No description provided for @keyGoBack.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get keyGoBack;

  /// No description provided for @keyToggleTTS.
  ///
  /// In en, this message translates to:
  /// **'Toggle T T S'**
  String get keyToggleTTS;

  /// No description provided for @keyToggleVoiceCommands.
  ///
  /// In en, this message translates to:
  /// **'Toggle Voice Commands'**
  String get keyToggleVoiceCommands;

  /// No description provided for @keyShowOrHideShortcuts.
  ///
  /// In en, this message translates to:
  /// **'Show or Hide Shortcuts'**
  String get keyShowOrHideShortcuts;

  /// No description provided for @keyToggleHighContrast.
  ///
  /// In en, this message translates to:
  /// **'Toggle High Contrast'**
  String get keyToggleHighContrast;

  /// No description provided for @keyTestTTS.
  ///
  /// In en, this message translates to:
  /// **'Test T T S'**
  String get keyTestTTS;

  /// No description provided for @keySaveSettings.
  ///
  /// In en, this message translates to:
  /// **'Save Settings'**
  String get keySaveSettings;

  /// No description provided for @keyCheckVoice.
  ///
  /// In en, this message translates to:
  /// **'Check voice'**
  String get keyCheckVoice;

  /// No description provided for @keySoundCuesOnOrOff.
  ///
  /// In en, this message translates to:
  /// **'Sound cues on or off'**
  String get keySoundCuesOnOrOff;

  /// No description provided for @keyVibrationOnOrOff.
  ///
  /// In en, this message translates to:
  /// **'Vibration on or off'**
  String get keyVibrationOnOrOff;

  /// No description provided for @keyLogOutAsksToConfirm.
  ///
  /// In en, this message translates to:
  /// **'Log out, asks to confirm'**
  String get keyLogOutAsksToConfirm;

  /// No description provided for @keyRefreshSessions.
  ///
  /// In en, this message translates to:
  /// **'Refresh Sessions'**
  String get keyRefreshSessions;

  /// No description provided for @keySearchSessionsByNameOrID.
  ///
  /// In en, this message translates to:
  /// **'Search Sessions by Name or ID'**
  String get keySearchSessionsByNameOrID;

  /// No description provided for @keyRecordedAudioLibrary.
  ///
  /// In en, this message translates to:
  /// **'Recorded Audio Library'**
  String get keyRecordedAudioLibrary;

  /// No description provided for @keyMyPrivatePlaylists.
  ///
  /// In en, this message translates to:
  /// **'My Private Playlists'**
  String get keyMyPrivatePlaylists;

  /// No description provided for @keyQuizzes.
  ///
  /// In en, this message translates to:
  /// **'Quizzes'**
  String get keyQuizzes;

  /// No description provided for @keyLearningJourneys.
  ///
  /// In en, this message translates to:
  /// **'Learning journeys'**
  String get keyLearningJourneys;

  /// No description provided for @keyCreateSession.
  ///
  /// In en, this message translates to:
  /// **'Create Session'**
  String get keyCreateSession;

  /// No description provided for @keyClassPlaylists.
  ///
  /// In en, this message translates to:
  /// **'Class Playlists'**
  String get keyClassPlaylists;

  /// No description provided for @keyChooseClassAndSubjectWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Choose class and subject workspace'**
  String get keyChooseClassAndSubjectWorkspace;

  /// No description provided for @keyRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get keyRefresh;

  /// No description provided for @keySearchUsers.
  ///
  /// In en, this message translates to:
  /// **'Search Users'**
  String get keySearchUsers;

  /// No description provided for @keyChangeAccountTypeFilter.
  ///
  /// In en, this message translates to:
  /// **'Change Account Type Filter'**
  String get keyChangeAccountTypeFilter;

  /// No description provided for @keyChangeAssignmentFilter.
  ///
  /// In en, this message translates to:
  /// **'Change Assignment Filter'**
  String get keyChangeAssignmentFilter;

  /// No description provided for @keyCreateSubject.
  ///
  /// In en, this message translates to:
  /// **'Create Subject'**
  String get keyCreateSubject;

  /// No description provided for @keyCreateClass.
  ///
  /// In en, this message translates to:
  /// **'Create Class'**
  String get keyCreateClass;

  /// No description provided for @keyChooseAccountsClassesOrSubjectsSection.
  ///
  /// In en, this message translates to:
  /// **'Choose Accounts, Classes, or Subjects section'**
  String get keyChooseAccountsClassesOrSubjectsSection;

  /// No description provided for @keyGoBackAlt.
  ///
  /// In en, this message translates to:
  /// **'Go back'**
  String get keyGoBackAlt;

  /// No description provided for @keyCreateBankQuestion.
  ///
  /// In en, this message translates to:
  /// **'Create bank question'**
  String get keyCreateBankQuestion;

  /// No description provided for @keyCreateQuizDraft.
  ///
  /// In en, this message translates to:
  /// **'Create quiz draft'**
  String get keyCreateQuizDraft;

  /// No description provided for @keyCreateUntimedUngradedPractice.
  ///
  /// In en, this message translates to:
  /// **'Create untimed ungraded practice'**
  String get keyCreateUntimedUngradedPractice;

  /// No description provided for @keyRefreshQuizzes.
  ///
  /// In en, this message translates to:
  /// **'Refresh quizzes'**
  String get keyRefreshQuizzes;

  /// No description provided for @keyChooseOption1.
  ///
  /// In en, this message translates to:
  /// **'Choose option 1'**
  String get keyChooseOption1;

  /// No description provided for @keyChooseOption2.
  ///
  /// In en, this message translates to:
  /// **'Choose option 2'**
  String get keyChooseOption2;

  /// No description provided for @keyChooseOption3.
  ///
  /// In en, this message translates to:
  /// **'Choose option 3'**
  String get keyChooseOption3;

  /// No description provided for @keyChooseOption4.
  ///
  /// In en, this message translates to:
  /// **'Choose option 4'**
  String get keyChooseOption4;

  /// No description provided for @keySubmitSelectedAnswer.
  ///
  /// In en, this message translates to:
  /// **'Submit selected answer'**
  String get keySubmitSelectedAnswer;

  /// No description provided for @keyRepeatQuestionAndOptions.
  ///
  /// In en, this message translates to:
  /// **'Repeat question and options'**
  String get keyRepeatQuestionAndOptions;

  /// No description provided for @keySlowerQuizSpeech.
  ///
  /// In en, this message translates to:
  /// **'Slower quiz speech'**
  String get keySlowerQuizSpeech;

  /// No description provided for @keyWhereAmIIncludingTimeLeft.
  ///
  /// In en, this message translates to:
  /// **'Where am I, including time left'**
  String get keyWhereAmIIncludingTimeLeft;

  /// No description provided for @keyFasterQuizSpeech.
  ///
  /// In en, this message translates to:
  /// **'Faster quiz speech'**
  String get keyFasterQuizSpeech;

  /// No description provided for @keyMuteOrUnmute.
  ///
  /// In en, this message translates to:
  /// **'Mute or unmute'**
  String get keyMuteOrUnmute;

  /// No description provided for @keyRaiseOrLowerHand.
  ///
  /// In en, this message translates to:
  /// **'Raise or lower hand'**
  String get keyRaiseOrLowerHand;

  /// No description provided for @keyHearClassStatus.
  ///
  /// In en, this message translates to:
  /// **'Hear class status'**
  String get keyHearClassStatus;

  /// No description provided for @keyChat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get keyChat;

  /// No description provided for @keyHearWhatTheTeacherIsPlaying.
  ///
  /// In en, this message translates to:
  /// **'Hear what the teacher is playing'**
  String get keyHearWhatTheTeacherIsPlaying;

  /// No description provided for @keyAnswerClassroomCheck.
  ///
  /// In en, this message translates to:
  /// **'Answer classroom check'**
  String get keyAnswerClassroomCheck;

  /// No description provided for @keyWhoIsInTheClass.
  ///
  /// In en, this message translates to:
  /// **'Who is in the class'**
  String get keyWhoIsInTheClass;

  /// No description provided for @keyLeaveSessionAsksToConfirm.
  ///
  /// In en, this message translates to:
  /// **'Leave session, asks to confirm'**
  String get keyLeaveSessionAsksToConfirm;

  /// No description provided for @keyRaisedHandsAcknowledgeAndLowerThemInOrder.
  ///
  /// In en, this message translates to:
  /// **'Raised hands: acknowledge and lower them in order'**
  String get keyRaisedHandsAcknowledgeAndLowerThemInOrder;

  /// No description provided for @keyClassRecordingPlayerPlayAndControlTheRecording.
  ///
  /// In en, this message translates to:
  /// **'Class recording player: play and control the recording'**
  String get keyClassRecordingPlayerPlayAndControlTheRecording;

  /// No description provided for @keyClassroomCheckStartCloseAndHearResponses.
  ///
  /// In en, this message translates to:
  /// **'Classroom check: start, close and hear responses'**
  String get keyClassroomCheckStartCloseAndHearResponses;

  /// No description provided for @keyParticipantsMuteOrRemoveSomeone.
  ///
  /// In en, this message translates to:
  /// **'Participants: mute or remove someone'**
  String get keyParticipantsMuteOrRemoveSomeone;

  /// No description provided for @keyTeacherToolsInviteStudentsEndClassForEveryone.
  ///
  /// In en, this message translates to:
  /// **'Teacher tools: invite students, end class for everyone'**
  String get keyTeacherToolsInviteStudentsEndClassForEveryone;

  /// No description provided for @keyRefreshClasses.
  ///
  /// In en, this message translates to:
  /// **'Refresh Classes'**
  String get keyRefreshClasses;

  /// No description provided for @keySearchClassByName.
  ///
  /// In en, this message translates to:
  /// **'Search Class by Name'**
  String get keySearchClassByName;

  /// No description provided for @keyAllAudioFiles.
  ///
  /// In en, this message translates to:
  /// **'All Audio Files'**
  String get keyAllAudioFiles;

  /// No description provided for @keyFocusFirstActiveClassUseDPadToBrowseClasses.
  ///
  /// In en, this message translates to:
  /// **'Focus first active class; use D-pad to browse classes'**
  String get keyFocusFirstActiveClassUseDPadToBrowseClasses;

  /// No description provided for @keyRefreshFiles.
  ///
  /// In en, this message translates to:
  /// **'Refresh files'**
  String get keyRefreshFiles;

  /// No description provided for @keyNextSubjectFilter.
  ///
  /// In en, this message translates to:
  /// **'Next subject filter'**
  String get keyNextSubjectFilter;

  /// No description provided for @keyStopPlayback.
  ///
  /// In en, this message translates to:
  /// **'Stop playback'**
  String get keyStopPlayback;

  /// No description provided for @keyAddAudioFile.
  ///
  /// In en, this message translates to:
  /// **'Add audio file'**
  String get keyAddAudioFile;

  /// No description provided for @keyUploadNewFile.
  ///
  /// In en, this message translates to:
  /// **'Upload New File'**
  String get keyUploadNewFile;

  /// No description provided for @keySelectFromExistingLibrary.
  ///
  /// In en, this message translates to:
  /// **'Select from Existing Library'**
  String get keySelectFromExistingLibrary;

  /// No description provided for @keyRefreshList.
  ///
  /// In en, this message translates to:
  /// **'Refresh List'**
  String get keyRefreshList;

  /// App name, spoken when a screen has no name.
  ///
  /// In en, this message translates to:
  /// **'SEEDS'**
  String get appName;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageHindi.
  ///
  /// In en, this message translates to:
  /// **'Hindi'**
  String get languageHindi;

  /// No description provided for @languageKannada.
  ///
  /// In en, this message translates to:
  /// **'Kannada'**
  String get languageKannada;

  /// No description provided for @languageTelugu.
  ///
  /// In en, this message translates to:
  /// **'Telugu'**
  String get languageTelugu;

  /// No description provided for @languageBengali.
  ///
  /// In en, this message translates to:
  /// **'Bengali'**
  String get languageBengali;

  /// No description provided for @commonPleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Please wait. Still working.'**
  String get commonPleaseWait;

  /// No description provided for @commonSignInFirst.
  ///
  /// In en, this message translates to:
  /// **'Please sign in first.'**
  String get commonSignInFirst;

  /// No description provided for @commonAccountChanged.
  ///
  /// In en, this message translates to:
  /// **'Your account changed on this phone. Sign in again.'**
  String get commonAccountChanged;

  /// No description provided for @commonNoWorkspace.
  ///
  /// In en, this message translates to:
  /// **'No class and subject is chosen. Press 7 to choose a workspace.'**
  String get commonNoWorkspace;

  /// No description provided for @commonNoConnection.
  ///
  /// In en, this message translates to:
  /// **'No connection to the school server. Check your internet and try again.'**
  String get commonNoConnection;

  /// No description provided for @commonNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'This is not available right now.'**
  String get commonNotAvailable;

  /// No description provided for @commonNothingChanged.
  ///
  /// In en, this message translates to:
  /// **'Nothing was changed.'**
  String get commonNothingChanged;

  /// No description provided for @commonNoMessages.
  ///
  /// In en, this message translates to:
  /// **'There are no messages on this screen.'**
  String get commonNoMessages;

  /// No description provided for @commonEndOfList.
  ///
  /// In en, this message translates to:
  /// **'End of list. Back to the first item.'**
  String get commonEndOfList;

  /// No description provided for @commonTopOfList.
  ///
  /// In en, this message translates to:
  /// **'Top of list. Moved to the last item.'**
  String get commonTopOfList;

  /// No description provided for @commonOpening.
  ///
  /// In en, this message translates to:
  /// **'Opening {what}.'**
  String commonOpening(String what);

  /// No description provided for @commonOpeningNeedsInternet.
  ///
  /// In en, this message translates to:
  /// **'Opening {what}. Internet is required.'**
  String commonOpeningNeedsInternet(String what);

  /// No description provided for @commonUnavailable.
  ///
  /// In en, this message translates to:
  /// **'{what} is not available.'**
  String commonUnavailable(String what);

  /// No description provided for @commonUnavailableBecause.
  ///
  /// In en, this message translates to:
  /// **'{what} is not available. {reason}'**
  String commonUnavailableBecause(String what, String reason);

  /// No description provided for @commonWhereScreen.
  ///
  /// In en, this message translates to:
  /// **'{screen}.'**
  String commonWhereScreen(String screen);

  /// No description provided for @commonWhereFocused.
  ///
  /// In en, this message translates to:
  /// **'Focused: {item}.'**
  String commonWhereFocused(String item);

  /// No description provided for @keypadStarForShortcuts.
  ///
  /// In en, this message translates to:
  /// **'Press star for all shortcuts.'**
  String get keypadStarForShortcuts;

  /// No description provided for @keypadScreenReaderIntro.
  ///
  /// In en, this message translates to:
  /// **'{screen}. Press star for keypad help.'**
  String keypadScreenReaderIntro(String screen);

  /// No description provided for @keypadMoveThroughSections.
  ///
  /// In en, this message translates to:
  /// **'Use D-pad up and down to move through {sections}. Press OK to activate the focused control.'**
  String keypadMoveThroughSections(String sections);

  /// No description provided for @keypadEssentialMove.
  ///
  /// In en, this message translates to:
  /// **'Use up and down to move, and OK to select.'**
  String get keypadEssentialMove;

  /// No description provided for @keypadHashAndStar.
  ///
  /// In en, this message translates to:
  /// **'Press hash to stop speech. Press star to repeat these instructions.'**
  String get keypadHashAndStar;

  /// No description provided for @keypadDirectionKeysAndOk.
  ///
  /// In en, this message translates to:
  /// **'Use the direction keys to move and OK to select.'**
  String get keypadDirectionKeysAndOk;

  /// No description provided for @keypadLeaveField.
  ///
  /// In en, this message translates to:
  /// **'While editing, press OK or use up or down to leave the field.'**
  String get keypadLeaveField;

  /// Added after a focused item, e.g. 'Save, 3 of 7'.
  ///
  /// In en, this message translates to:
  /// **', {index} of {total}'**
  String keypadPosition(String index, String total);

  /// No description provided for @keypadEditingPressOk.
  ///
  /// In en, this message translates to:
  /// **'{label}. Editing. Press OK when finished.'**
  String keypadEditingPressOk(String label);

  /// No description provided for @keypadEditingUseUpDown.
  ///
  /// In en, this message translates to:
  /// **'{label}. Editing. Use up or down to leave this field.'**
  String keypadEditingUseUpDown(String label);

  /// No description provided for @keypadControlUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This control is not available right now.'**
  String get keypadControlUnavailable;

  /// No description provided for @keypadMainScreen.
  ///
  /// In en, this message translates to:
  /// **'This is the main screen. There is nothing to go back to.'**
  String get keypadMainScreen;

  /// No description provided for @messageLast.
  ///
  /// In en, this message translates to:
  /// **'Last message: {text}'**
  String messageLast(String text);

  /// No description provided for @messageLastProblem.
  ///
  /// In en, this message translates to:
  /// **'Last problem: {text}'**
  String messageLastProblem(String text);

  /// No description provided for @ttsSpeedDescription.
  ///
  /// In en, this message translates to:
  /// **'{speed} times normal speed'**
  String ttsSpeedDescription(String speed);

  /// No description provided for @ttsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Speech is unavailable. Enable an English Android text-to-speech voice, then use Test speech in Settings.'**
  String get ttsUnavailable;

  /// No description provided for @ttsLanguageFallback.
  ///
  /// In en, this message translates to:
  /// **'No {language} voice is available on this phone, so SEEDS will speak English. Install the {language} voice in Android text-to-speech settings, then check the voice in Settings.'**
  String ttsLanguageFallback(String language);

  /// No description provided for @ttsScreenReaderDetected.
  ///
  /// In en, this message translates to:
  /// **'Screen reader detected. SEEDS will send its announcements to your screen reader.'**
  String get ttsScreenReaderDetected;

  /// No description provided for @ttsScreenReaderOff.
  ///
  /// In en, this message translates to:
  /// **'Screen reader turned off. SEEDS will speak for itself.'**
  String get ttsScreenReaderOff;

  /// No description provided for @ttsVoiceInstalled.
  ///
  /// In en, this message translates to:
  /// **'Android reports installed {language} voice data. Use Test speech in Settings, then test it again in airplane mode before relying on offline speech. This check cannot prove that you can hear it.'**
  String ttsVoiceInstalled(String language);

  /// No description provided for @ttsVoiceNotOffline.
  ///
  /// In en, this message translates to:
  /// **'{language} is available, but installed offline voice data was not confirmed. Speech may need internet.'**
  String ttsVoiceNotOffline(String language);

  /// No description provided for @ttsVoiceMissing.
  ///
  /// In en, this message translates to:
  /// **'No {language} voice was detected.'**
  String ttsVoiceMissing(String language);

  /// No description provided for @ttsVoiceUnverified.
  ///
  /// In en, this message translates to:
  /// **'{language} voice availability could not be verified.'**
  String ttsVoiceUnverified(String language);

  /// No description provided for @ttsVoiceRecovery.
  ///
  /// In en, this message translates to:
  /// **'Open Android Settings, find Text-to-speech output, select the {language} voice and install its voice data. Return here and check again. You can use your Android screen reader instead of app speech.'**
  String ttsVoiceRecovery(String language);

  /// No description provided for @ttsSpeedChangeFailed.
  ///
  /// In en, this message translates to:
  /// **'Speech speed could not be changed. Try again.'**
  String get ttsSpeedChangeFailed;

  /// No description provided for @ttsSettingsFailed.
  ///
  /// In en, this message translates to:
  /// **'Speech settings could not be applied. Try Test speech again.'**
  String get ttsSettingsFailed;

  /// No description provided for @ttsCouldNotStart.
  ///
  /// In en, this message translates to:
  /// **'Speech could not start. Try Test speech in Settings.'**
  String get ttsCouldNotStart;

  /// No description provided for @ttsNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Speech was not available. Try Test speech in Settings.'**
  String get ttsNotAvailable;

  /// No description provided for @ttsFailed.
  ///
  /// In en, this message translates to:
  /// **'Speech failed. Try Test speech in Settings.'**
  String get ttsFailed;

  /// No description provided for @ttsLessonResumeFailed.
  ///
  /// In en, this message translates to:
  /// **'The recorded lesson could not resume. Select Play to retry.'**
  String get ttsLessonResumeFailed;

  /// No description provided for @ttsStopFailed.
  ///
  /// In en, this message translates to:
  /// **'Speech could not be stopped. Check the Android TTS engine.'**
  String get ttsStopFailed;

  /// No description provided for @ttsNoPendingUpdates.
  ///
  /// In en, this message translates to:
  /// **'No pending updates.'**
  String get ttsNoPendingUpdates;

  /// No description provided for @ttsOtherUpdates.
  ///
  /// In en, this message translates to:
  /// **'Other updates'**
  String get ttsOtherUpdates;

  /// No description provided for @ttsUpdateGroup.
  ///
  /// In en, this message translates to:
  /// **'{group}.'**
  String ttsUpdateGroup(String group);

  /// No description provided for @ttsUpdateGroupCount.
  ///
  /// In en, this message translates to:
  /// **'{group}, {count} updates.'**
  String ttsUpdateGroupCount(String group, int count);

  /// No description provided for @ttsOtherUpdateGroups.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 other update group.} other{{count} other update groups.}}'**
  String ttsOtherUpdateGroups(int count);

  /// No description provided for @settingsScreenName.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsScreenName;

  /// No description provided for @settingsSections.
  ///
  /// In en, this message translates to:
  /// **'four sections: Speech, Display, Keys and help, then Save settings'**
  String get settingsSections;

  /// No description provided for @settingsLoaded.
  ///
  /// In en, this message translates to:
  /// **'Settings loaded'**
  String get settingsLoaded;

  /// No description provided for @settingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Settings saved'**
  String get settingsSaved;

  /// No description provided for @settingsResetSaved.
  ///
  /// In en, this message translates to:
  /// **'Settings reset to defaults and saved'**
  String get settingsResetSaved;

  /// No description provided for @settingsTestSpeech.
  ///
  /// In en, this message translates to:
  /// **'This is a test of the text to speech system. Volume is {volume} percent. Speech speed is {speed}.'**
  String settingsTestSpeech(String volume, String speed);

  /// No description provided for @settingsFastestSpeed.
  ///
  /// In en, this message translates to:
  /// **'Fastest speech speed, {speed}'**
  String settingsFastestSpeed(String speed);

  /// No description provided for @settingsSlowestSpeed.
  ///
  /// In en, this message translates to:
  /// **'Slowest speech speed, {speed}'**
  String settingsSlowestSpeed(String speed);

  /// No description provided for @settingsSpeechSpeed.
  ///
  /// In en, this message translates to:
  /// **'Speech speed {speed}'**
  String settingsSpeechSpeed(String speed);

  /// No description provided for @settingsVoiceCommandsEnabled.
  ///
  /// In en, this message translates to:
  /// **'Voice commands enabled'**
  String get settingsVoiceCommandsEnabled;

  /// No description provided for @settingsVoiceCommandsDisabled.
  ///
  /// In en, this message translates to:
  /// **'Voice commands disabled'**
  String get settingsVoiceCommandsDisabled;

  /// No description provided for @settingsHighContrastOn.
  ///
  /// In en, this message translates to:
  /// **'High contrast on'**
  String get settingsHighContrastOn;

  /// No description provided for @settingsHighContrastOff.
  ///
  /// In en, this message translates to:
  /// **'High contrast off'**
  String get settingsHighContrastOff;

  /// No description provided for @settingsShortcutsShown.
  ///
  /// In en, this message translates to:
  /// **'Keypad shortcuts shown'**
  String get settingsShortcutsShown;

  /// No description provided for @settingsShortcutsHidden.
  ///
  /// In en, this message translates to:
  /// **'Keypad shortcuts hidden'**
  String get settingsShortcutsHidden;

  /// No description provided for @settingsVoiceHelp.
  ///
  /// In en, this message translates to:
  /// **'In a session, activate Listen for command, then say mute, unmute, raise hand, lower hand, leave, or repeat. Listening does not restart automatically. Unmute asks for a key or touch confirmation.'**
  String get settingsVoiceHelp;

  /// No description provided for @settingsModeAutomatic.
  ///
  /// In en, this message translates to:
  /// **'Automatic: follows TalkBack unless you choose. Now {current}.'**
  String settingsModeAutomatic(String current);

  /// No description provided for @settingsModeUsingScreenReader.
  ///
  /// In en, this message translates to:
  /// **'using the screen reader'**
  String get settingsModeUsingScreenReader;

  /// No description provided for @settingsModeUsingSelfVoicing.
  ///
  /// In en, this message translates to:
  /// **'self-voicing'**
  String get settingsModeUsingSelfVoicing;

  /// No description provided for @settingsModeScreenReader.
  ///
  /// In en, this message translates to:
  /// **'Screen reader: announcements go to TalkBack. App narration is off.'**
  String get settingsModeScreenReader;

  /// No description provided for @settingsModeSelfVoicing.
  ///
  /// In en, this message translates to:
  /// **'Self-voicing: the app speaks for itself.'**
  String get settingsModeSelfVoicing;

  /// No description provided for @settingsSoundCues.
  ///
  /// In en, this message translates to:
  /// **'Sound cues {state}.'**
  String settingsSoundCues(String state);

  /// No description provided for @settingsSoundCuesOnSaved.
  ///
  /// In en, this message translates to:
  /// **'Sound cues {state}. This is the saved sound.'**
  String settingsSoundCuesOnSaved(String state);

  /// No description provided for @settingsVibration.
  ///
  /// In en, this message translates to:
  /// **'Vibration {state}.'**
  String settingsVibration(String state);

  /// No description provided for @settingsVibrationOnBuzz.
  ///
  /// In en, this message translates to:
  /// **'Vibration {state}. One short buzz means OK.'**
  String settingsVibrationOnBuzz(String state);

  /// No description provided for @settingsSoundCuesLabel.
  ///
  /// In en, this message translates to:
  /// **'Sound cues, {state}. Short sounds for correct, wrong, saved, errors and your turn to speak'**
  String settingsSoundCuesLabel(String state);

  /// No description provided for @settingsVibrationLabel.
  ///
  /// In en, this message translates to:
  /// **'Vibration, {state}. One buzz for OK, two for an error, a long buzz for leaving'**
  String settingsVibrationLabel(String state);

  /// No description provided for @settingsSoundCuesHelp.
  ///
  /// In en, this message translates to:
  /// **'Short sounds for correct, wrong, saved, errors, end of list and your turn to speak. Saved immediately.'**
  String get settingsSoundCuesHelp;

  /// No description provided for @settingsVibrationHelp.
  ///
  /// In en, this message translates to:
  /// **'One short buzz for OK, two for an error, one long buzz for leaving or ending. Saved immediately.'**
  String get settingsVibrationHelp;

  /// No description provided for @settingsState.
  ///
  /// In en, this message translates to:
  /// **'App speech {speech}, speed {speed}, volume {volume} percent. Text size {textSize} percent. High contrast {highContrast}. Sound cues {soundCues}. Vibration {vibration}. Speech language {language}.'**
  String settingsState(
    String speech,
    String speed,
    String volume,
    String textSize,
    String highContrast,
    String soundCues,
    String vibration,
    String language,
  );

  /// No description provided for @settingsVolume.
  ///
  /// In en, this message translates to:
  /// **'Volume {percent} percent'**
  String settingsVolume(String percent);

  /// No description provided for @settingsTextSize.
  ///
  /// In en, this message translates to:
  /// **'Text size {percent} percent'**
  String settingsTextSize(String percent);

  /// No description provided for @settingsSpeechOff.
  ///
  /// In en, this message translates to:
  /// **'App speech off'**
  String get settingsSpeechOff;

  /// No description provided for @settingsSpeechOn.
  ///
  /// In en, this message translates to:
  /// **'App speech on'**
  String get settingsSpeechOn;

  /// No description provided for @settingsSpeechMode.
  ///
  /// In en, this message translates to:
  /// **'Speech mode. {description}'**
  String settingsSpeechMode(String description);

  /// No description provided for @settingsNarration.
  ///
  /// In en, this message translates to:
  /// **'Narration level {level}.'**
  String settingsNarration(String level);

  /// No description provided for @settingsNarrationEssential.
  ///
  /// In en, this message translates to:
  /// **'essential'**
  String get settingsNarrationEssential;

  /// No description provided for @settingsNarrationStandard.
  ///
  /// In en, this message translates to:
  /// **'standard'**
  String get settingsNarrationStandard;

  /// No description provided for @settingsNarrationDetailed.
  ///
  /// In en, this message translates to:
  /// **'detailed'**
  String get settingsNarrationDetailed;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Speech language {language}.'**
  String settingsLanguage(String language);

  /// No description provided for @settingsLanguageLabel.
  ///
  /// In en, this message translates to:
  /// **'Speech language, {language}. Press OK to change.'**
  String settingsLanguageLabel(String language);

  /// No description provided for @settingsBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get settingsBack;

  /// No description provided for @settingsResetLabel.
  ///
  /// In en, this message translates to:
  /// **'Reset settings to defaults, asks to confirm'**
  String get settingsResetLabel;

  /// No description provided for @settingsSpeechSectionLabel.
  ///
  /// In en, this message translates to:
  /// **'Speech section. App speech, {state}'**
  String settingsSpeechSectionLabel(String state);

  /// No description provided for @settingsVolumeLabel.
  ///
  /// In en, this message translates to:
  /// **'Volume {percent} percent. Left or right to change'**
  String settingsVolumeLabel(String percent);

  /// No description provided for @settingsSpeedLabel.
  ///
  /// In en, this message translates to:
  /// **'Speech speed {speed}. Left or right to change'**
  String settingsSpeedLabel(String speed);

  /// No description provided for @settingsTestLabel.
  ///
  /// In en, this message translates to:
  /// **'Test speech'**
  String get settingsTestLabel;

  /// No description provided for @settingsModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Speech mode. {description} Press OK to change.'**
  String settingsModeLabel(String description);

  /// No description provided for @settingsNarrationLabel.
  ///
  /// In en, this message translates to:
  /// **'Narration level {level}. Press OK to change.'**
  String settingsNarrationLabel(String level);

  /// No description provided for @settingsCheckVoiceLabel.
  ///
  /// In en, this message translates to:
  /// **'Check {language} voice'**
  String settingsCheckVoiceLabel(String language);

  /// No description provided for @settingsStopLabel.
  ///
  /// In en, this message translates to:
  /// **'Stop speech'**
  String get settingsStopLabel;

  /// No description provided for @settingsContrastLabel.
  ///
  /// In en, this message translates to:
  /// **'Display section. High contrast, {state}. On by default'**
  String settingsContrastLabel(String state);

  /// No description provided for @settingsTextSizeLabel.
  ///
  /// In en, this message translates to:
  /// **'Text size {percent} percent. Left or right to change'**
  String settingsTextSizeLabel(String percent);

  /// No description provided for @settingsShortcutsLabel.
  ///
  /// In en, this message translates to:
  /// **'Keys and help section. Show keypad shortcuts, {state}'**
  String settingsShortcutsLabel(String state);

  /// No description provided for @settingsVoiceCommandsLabel.
  ///
  /// In en, this message translates to:
  /// **'Voice commands in sessions, {state}'**
  String settingsVoiceCommandsLabel(String state);

  /// No description provided for @settingsVoiceHelpLabel.
  ///
  /// In en, this message translates to:
  /// **'Voice command help'**
  String get settingsVoiceHelpLabel;

  /// No description provided for @settingsRepeatHelpLabel.
  ///
  /// In en, this message translates to:
  /// **'Repeat Settings help'**
  String get settingsRepeatHelpLabel;

  /// No description provided for @settingsSaveLabel.
  ///
  /// In en, this message translates to:
  /// **'Save settings'**
  String get settingsSaveLabel;

  /// No description provided for @settingsResetQuestion.
  ///
  /// In en, this message translates to:
  /// **'Reset all settings to defaults? Speech, display and key settings return to their original values.'**
  String get settingsResetQuestion;

  /// No description provided for @settingsResetScreen.
  ///
  /// In en, this message translates to:
  /// **'Reset settings. {question}'**
  String settingsResetScreen(String question);

  /// No description provided for @settingsResetCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get settingsResetCancel;

  /// No description provided for @settingsResetConfirm.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get settingsResetConfirm;

  /// No description provided for @settingsResetCancelLabel.
  ///
  /// In en, this message translates to:
  /// **'Cancel, keep my settings'**
  String get settingsResetCancelLabel;

  /// No description provided for @settingsResetConfirmLabel.
  ///
  /// In en, this message translates to:
  /// **'Reset all settings to defaults'**
  String get settingsResetConfirmLabel;

  /// No description provided for @quizNotSet.
  ///
  /// In en, this message translates to:
  /// **'not set'**
  String get quizNotSet;

  /// No description provided for @quizNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'not available'**
  String get quizNotAvailable;

  /// No description provided for @quizNotAvailableCapital.
  ///
  /// In en, this message translates to:
  /// **'Not available'**
  String get quizNotAvailableCapital;

  /// Counted noun phrase used inside other sentences.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 question} other{{count} questions}}'**
  String quizQuestionCount(int count);

  /// No description provided for @quizAttemptCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 attempt} other{{count} attempts}}'**
  String quizAttemptCount(int count);

  /// No description provided for @quizStudentCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 student} other{{count} students}}'**
  String quizStudentCount(int count);

  /// No description provided for @quizAccountChanged.
  ///
  /// In en, this message translates to:
  /// **'Your account changed. Return to quizzes and sign in again.'**
  String get quizAccountChanged;

  /// No description provided for @quizUnlimitedPractice.
  ///
  /// In en, this message translates to:
  /// **'Unlimited practice attempts. Not graded.'**
  String get quizUnlimitedPractice;

  /// Quiz attempts the student has left.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 attempt remaining.} other{{count} attempts remaining.}}'**
  String quizAttemptsRemaining(int count);

  /// duration is a spoken duration such as "30 minutes".
  ///
  /// In en, this message translates to:
  /// **'Time limit {duration}.'**
  String quizTimeLimit(String duration);

  /// No description provided for @quizNoTimeLimit.
  ///
  /// In en, this message translates to:
  /// **'No time limit.'**
  String get quizNoTimeLimit;

  /// No description provided for @quizNoTimeLimitShort.
  ///
  /// In en, this message translates to:
  /// **'No time limit'**
  String get quizNoTimeLimitShort;

  /// No description provided for @quizFeedbackAfterCompletion.
  ///
  /// In en, this message translates to:
  /// **'Answer feedback and scores are released after you finish the quiz.'**
  String get quizFeedbackAfterCompletion;

  /// when is a spoken date and time such as "today at 10:30 in the morning".
  ///
  /// In en, this message translates to:
  /// **'Feedback and scores are released after you finish and after {when}.'**
  String quizFeedbackScheduled(String when);

  /// No description provided for @quizFeedbackScoreOnly.
  ///
  /// In en, this message translates to:
  /// **'Only the score is released after you finish. Answers and explanations are not released.'**
  String get quizFeedbackScoreOnly;

  /// No description provided for @quizFeedbackImmediate.
  ///
  /// In en, this message translates to:
  /// **'You hear whether each answer is right as soon as you submit it.'**
  String get quizFeedbackImmediate;

  /// No description provided for @quizPolicyAfterCompletion.
  ///
  /// In en, this message translates to:
  /// **'after the quiz is finished'**
  String get quizPolicyAfterCompletion;

  /// No description provided for @quizPolicyScheduled.
  ///
  /// In en, this message translates to:
  /// **'at a scheduled time'**
  String get quizPolicyScheduled;

  /// No description provided for @quizPolicyScoreOnly.
  ///
  /// In en, this message translates to:
  /// **'score only'**
  String get quizPolicyScoreOnly;

  /// No description provided for @quizPolicyLegacyImmediate.
  ///
  /// In en, this message translates to:
  /// **'immediately, older setting'**
  String get quizPolicyLegacyImmediate;

  /// No description provided for @quizPolicyImmediate.
  ///
  /// In en, this message translates to:
  /// **'immediately after each answer'**
  String get quizPolicyImmediate;

  /// No description provided for @quizPracticeResult.
  ///
  /// In en, this message translates to:
  /// **'Practice, not an academic grade. {correct} of {total} correct in this practice.'**
  String quizPracticeResult(String correct, String total);

  /// message comes from the server.
  ///
  /// In en, this message translates to:
  /// **'Score not released. {message}'**
  String quizScoreNotReleased(String message);

  /// No description provided for @quizCheckReleasePolicy.
  ///
  /// In en, this message translates to:
  /// **'Check the release policy.'**
  String get quizCheckReleasePolicy;

  /// percent is a spoken percentage such as "80 percent".
  ///
  /// In en, this message translates to:
  /// **'Score {correct} of {total}, {percent}.'**
  String quizScoreResult(String correct, String total, String percent);

  /// Quiz or attempt status, spoken in a sentence.
  ///
  /// In en, this message translates to:
  /// **'in progress'**
  String get quizStatusInProgress;

  /// No description provided for @quizStatusTimedOut.
  ///
  /// In en, this message translates to:
  /// **'finished when time ran out'**
  String get quizStatusTimedOut;

  /// No description provided for @quizStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'finished'**
  String get quizStatusCompleted;

  /// No description provided for @quizStatusPublished.
  ///
  /// In en, this message translates to:
  /// **'published'**
  String get quizStatusPublished;

  /// No description provided for @quizStatusDraft.
  ///
  /// In en, this message translates to:
  /// **'draft'**
  String get quizStatusDraft;

  /// No description provided for @quizStatusClosed.
  ///
  /// In en, this message translates to:
  /// **'closed'**
  String get quizStatusClosed;

  /// No description provided for @quizStatusScheduled.
  ///
  /// In en, this message translates to:
  /// **'scheduled'**
  String get quizStatusScheduled;

  /// No description provided for @quizStatusOpen.
  ///
  /// In en, this message translates to:
  /// **'open'**
  String get quizStatusOpen;

  /// No description provided for @quizQuestionHeading.
  ///
  /// In en, this message translates to:
  /// **'Question {number} of {total}'**
  String quizQuestionHeading(String number, String total);

  /// text is the question text written by the teacher.
  ///
  /// In en, this message translates to:
  /// **'Question {number} of {total}. {text}'**
  String quizQuestionWithText(String number, String total, String text);

  /// No description provided for @quizOptionSpoken.
  ///
  /// In en, this message translates to:
  /// **'Option {number}. {text}.'**
  String quizOptionSpoken(String number, String text);

  /// No description provided for @quizOptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Option {number} of {count}, {text}'**
  String quizOptionLabel(String number, String count, String text);

  /// No description provided for @quizOptionTargetSelected.
  ///
  /// In en, this message translates to:
  /// **'Option {number}, {text}, selected. Press OK or {number} to choose'**
  String quizOptionTargetSelected(String number, String text);

  /// No description provided for @quizOptionTargetNotSelected.
  ///
  /// In en, this message translates to:
  /// **'Option {number}, {text}, not selected. Press OK or {number} to choose'**
  String quizOptionTargetNotSelected(String number, String text);

  /// No description provided for @quizAnswerKeysBrief.
  ///
  /// In en, this message translates to:
  /// **'Press 1 to {count}, then 5.'**
  String quizAnswerKeysBrief(String count);

  /// No description provided for @quizAnswerKeysDetailed.
  ///
  /// In en, this message translates to:
  /// **'Press 1 to {count} to choose an answer, then 5 to submit it. Press 6 to repeat the question, 8 to hear where you are.'**
  String quizAnswerKeysDetailed(String count);

  /// No description provided for @quizChosenBrief.
  ///
  /// In en, this message translates to:
  /// **'Option {number}, {text}, selected.'**
  String quizChosenBrief(String number, String text);

  /// No description provided for @quizChosenDetailed.
  ///
  /// In en, this message translates to:
  /// **'Option {number}, {text}, selected. Press 5 to submit, or choose another number.'**
  String quizChosenDetailed(String number, String text);

  /// No description provided for @quizChooseFirst.
  ///
  /// In en, this message translates to:
  /// **'Choose an answer first. Press 1 to {count}, then 5 to submit.'**
  String quizChooseFirst(String count);

  /// No description provided for @quizNoSuchOption.
  ///
  /// In en, this message translates to:
  /// **'There is no option {option}. Press 1 to {count}.'**
  String quizNoSuchOption(String option, String count);

  /// No description provided for @quizSubmitting.
  ///
  /// In en, this message translates to:
  /// **'Submitting your answer.'**
  String get quizSubmitting;

  /// No description provided for @quizCorrectFeedback.
  ///
  /// In en, this message translates to:
  /// **'Correct! {answer}.'**
  String quizCorrectFeedback(String answer);

  /// No description provided for @quizWrongFeedback.
  ///
  /// In en, this message translates to:
  /// **'Not quite. The answer is {answer}.'**
  String quizWrongFeedback(String answer);

  /// No description provided for @quizAnswerSavedBrief.
  ///
  /// In en, this message translates to:
  /// **'Answer saved.'**
  String get quizAnswerSavedBrief;

  /// No description provided for @quizAnswerSavedLocked.
  ///
  /// In en, this message translates to:
  /// **'Answer saved and locked.'**
  String get quizAnswerSavedLocked;

  /// No description provided for @quizSavedHeading.
  ///
  /// In en, this message translates to:
  /// **'Answer saved and locked'**
  String get quizSavedHeading;

  /// No description provided for @quizCorrectHeading.
  ///
  /// In en, this message translates to:
  /// **'Correct'**
  String get quizCorrectHeading;

  /// No description provided for @quizWrongHeading.
  ///
  /// In en, this message translates to:
  /// **'Incorrect'**
  String get quizWrongHeading;

  /// No description provided for @quizYouSelected.
  ///
  /// In en, this message translates to:
  /// **'You selected: {text}'**
  String quizYouSelected(String text);

  /// No description provided for @quizCorrectAnswerIs.
  ///
  /// In en, this message translates to:
  /// **'Correct answer: {text}'**
  String quizCorrectAnswerIs(String text);

  /// No description provided for @quizNoExplanation.
  ///
  /// In en, this message translates to:
  /// **'No explanation provided.'**
  String get quizNoExplanation;

  /// reason is an error sentence, possibly from the server.
  ///
  /// In en, this message translates to:
  /// **'{reason} Your selection is preserved. Press 5 to try again.'**
  String quizAnswerFailed(String reason);

  /// No description provided for @quizAnswerUnreadable.
  ///
  /// In en, this message translates to:
  /// **'The answer confirmation could not be read.'**
  String get quizAnswerUnreadable;

  /// No description provided for @quizNoOptionSelected.
  ///
  /// In en, this message translates to:
  /// **'No option selected.'**
  String get quizNoOptionSelected;

  /// No description provided for @quizSelectionSaved.
  ///
  /// In en, this message translates to:
  /// **'Selected option {number}, {text}. Answer saved.'**
  String quizSelectionSaved(String number, String text);

  /// No description provided for @quizSelectionNotSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Selected option {number}, {text}. Not submitted yet.'**
  String quizSelectionNotSubmitted(String number, String text);

  /// No description provided for @quizRepeatQuestion.
  ///
  /// In en, this message translates to:
  /// **'Repeat question and options'**
  String get quizRepeatQuestion;

  /// No description provided for @quizAnswerConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Answer confirmed saved and locked.'**
  String get quizAnswerConfirmed;

  /// No description provided for @quizFeedbackStaysAvailable.
  ///
  /// In en, this message translates to:
  /// **'Feedback for it stays available privately on the next question.'**
  String get quizFeedbackStaysAvailable;

  /// No description provided for @quizPreviousFeedback.
  ///
  /// In en, this message translates to:
  /// **'Hear feedback for the previous answer, privately'**
  String get quizPreviousFeedback;

  /// No description provided for @quizAnswerLockNotice.
  ///
  /// In en, this message translates to:
  /// **'Each answer is saved and locked when you press 5.'**
  String get quizAnswerLockNotice;

  /// No description provided for @quizTimeLeft.
  ///
  /// In en, this message translates to:
  /// **'Time left: {duration}.'**
  String quizTimeLeft(String duration);

  /// clock is a visual countdown such as "4:05".
  ///
  /// In en, this message translates to:
  /// **'{clock} left'**
  String quizClockLeft(String clock);

  /// clock is a visual countdown such as "4:05".
  ///
  /// In en, this message translates to:
  /// **'{clock} remaining'**
  String quizClockRemaining(String clock);

  /// No description provided for @quizTimeWarning.
  ///
  /// In en, this message translates to:
  /// **'{duration} left in this quiz.'**
  String quizTimeWarning(String duration);

  /// No description provided for @quizTimeUp.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Time is up. 1 answer saved. Finishing the quiz.} other{Time is up. {count} answers saved. Finishing the quiz.}}'**
  String quizTimeUp(int count);

  /// No description provided for @quizWhereQuestion.
  ///
  /// In en, this message translates to:
  /// **'Question {number} of {total}.'**
  String quizWhereQuestion(String number, String total);

  /// Number of questions answered so far.
  ///
  /// In en, this message translates to:
  /// **'{count} answered.'**
  String quizAnsweredCount(String count);

  /// No description provided for @quizAllSaved.
  ///
  /// In en, this message translates to:
  /// **'All answers are saved. Press 5 to finish and hear your result.'**
  String get quizAllSaved;

  /// No description provided for @quizFinishNow.
  ///
  /// In en, this message translates to:
  /// **'Finish quiz now, with confirmation'**
  String get quizFinishNow;

  /// No description provided for @quizFinishNowButton.
  ///
  /// In en, this message translates to:
  /// **'Finish quiz now'**
  String get quizFinishNowButton;

  /// No description provided for @quizFinishTitle.
  ///
  /// In en, this message translates to:
  /// **'Finish quiz now?'**
  String get quizFinishTitle;

  /// No description provided for @quizFinishMessage.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{The server shows 1 question not answered. Only saved answers count. A selected answer that you did not submit is not included. You cannot change answers after finishing.} other{The server shows {count} questions not answered. Only saved answers count. A selected answer that you did not submit is not included. You cannot change answers after finishing.}}'**
  String quizFinishMessage(int count);

  /// No description provided for @quizFinishConfirm.
  ///
  /// In en, this message translates to:
  /// **'Finish quiz'**
  String get quizFinishConfirm;

  /// No description provided for @quizFinishCancel.
  ///
  /// In en, this message translates to:
  /// **'Keep working'**
  String get quizFinishCancel;

  /// No description provided for @quizFinishUnchecked.
  ///
  /// In en, this message translates to:
  /// **'Your saved answers could not be checked, or this attempt has ended. The quiz was not finished. Return to the quiz list to refresh it.'**
  String get quizFinishUnchecked;

  /// No description provided for @quizFinishTimedOut.
  ///
  /// In en, this message translates to:
  /// **'Checking your saved answers took too long. The quiz was not finished. Check your connection and try again.'**
  String get quizFinishTimedOut;

  /// No description provided for @quizFinishing.
  ///
  /// In en, this message translates to:
  /// **'Finishing the quiz'**
  String get quizFinishing;

  /// No description provided for @quizFinishAndHear.
  ///
  /// In en, this message translates to:
  /// **'Finish and hear result'**
  String get quizFinishAndHear;

  /// No description provided for @quizRetryFinishing.
  ///
  /// In en, this message translates to:
  /// **'Retry finishing'**
  String get quizRetryFinishing;

  /// No description provided for @quizCompletionFailed.
  ///
  /// In en, this message translates to:
  /// **'{reason} Your saved answers are preserved. Press 5 to retry finishing.'**
  String quizCompletionFailed(String reason);

  /// No description provided for @quizCompletionNotConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Completion was not confirmed.'**
  String get quizCompletionNotConfirmed;

  /// No description provided for @quizCompleted.
  ///
  /// In en, this message translates to:
  /// **'Quiz finished. Your result is private. Press 8 to hear it, or 0 to return to quizzes.'**
  String get quizCompleted;

  /// No description provided for @quizCompletedTimedOut.
  ///
  /// In en, this message translates to:
  /// **'Time ran out. Quiz finished. Your result is private. Press 8 to hear it, or 0 to return to quizzes.'**
  String get quizCompletedTimedOut;

  /// No description provided for @quizResultPrivate.
  ///
  /// In en, this message translates to:
  /// **'Quiz finished. Result private. Use Read result privately.'**
  String get quizResultPrivate;

  /// No description provided for @quizResultHeading.
  ///
  /// In en, this message translates to:
  /// **'Attempt complete'**
  String get quizResultHeading;

  /// No description provided for @quizReadResult.
  ///
  /// In en, this message translates to:
  /// **'Read result privately'**
  String get quizReadResult;

  /// No description provided for @quizReturnToQuizzes.
  ///
  /// In en, this message translates to:
  /// **'Return to quizzes'**
  String get quizReturnToQuizzes;

  /// No description provided for @quizLeave.
  ///
  /// In en, this message translates to:
  /// **'Leave without submitting, with confirmation'**
  String get quizLeave;

  /// No description provided for @quizLeaveTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave and resume later?'**
  String get quizLeaveTitle;

  /// No description provided for @quizLeaveMessage.
  ///
  /// In en, this message translates to:
  /// **'This does not submit your attempt. Only saved answers are kept; a selected answer that you did not submit may be lost. Any time limit keeps running. You can resume while the quiz allows it.'**
  String get quizLeaveMessage;

  /// No description provided for @quizLeaveConfirm.
  ///
  /// In en, this message translates to:
  /// **'Leave without submitting'**
  String get quizLeaveConfirm;

  /// No description provided for @quizLeaveCancel.
  ///
  /// In en, this message translates to:
  /// **'Stay in quiz'**
  String get quizLeaveCancel;

  /// No description provided for @quizWaitBeforeLeaving.
  ///
  /// In en, this message translates to:
  /// **'Please wait. Your answer is still being saved.'**
  String get quizWaitBeforeLeaving;

  /// No description provided for @quizAttemptScreen.
  ///
  /// In en, this message translates to:
  /// **'Quiz attempt, {title}'**
  String quizAttemptScreen(String title);

  /// No description provided for @quizAttemptNavigationCompleted.
  ///
  /// In en, this message translates to:
  /// **'return to quizzes, read result privately and quiz speech speed'**
  String get quizAttemptNavigationCompleted;

  /// No description provided for @quizAttemptNavigationTimed.
  ///
  /// In en, this message translates to:
  /// **'the question, each answer option, the selected answer, quiz speech speed, time left, submit, Finish quiz now and Leave. Moving focus never selects or submits'**
  String get quizAttemptNavigationTimed;

  /// No description provided for @quizAttemptNavigationUntimed.
  ///
  /// In en, this message translates to:
  /// **'the question, each answer option, the selected answer, quiz speech speed, submit, Finish quiz now and Leave. Moving focus never selects or submits'**
  String get quizAttemptNavigationUntimed;

  /// No description provided for @quizSpeedHelp.
  ///
  /// In en, this message translates to:
  /// **'Press 7 or 9 to make quiz speech slower or faster.'**
  String get quizSpeedHelp;

  /// No description provided for @quizSpeedScreenReader.
  ///
  /// In en, this message translates to:
  /// **'Quiz speech speed changes app speech only. Change your screen reader speed in Android settings.'**
  String get quizSpeedScreenReader;

  /// No description provided for @quizSpeedHeading.
  ///
  /// In en, this message translates to:
  /// **'Quiz speech speed'**
  String get quizSpeedHeading;

  /// No description provided for @quizSpeedTarget.
  ///
  /// In en, this message translates to:
  /// **'Quiz speech speed, {description}. Left or right to change, or press 7 or 9'**
  String quizSpeedTarget(String description);

  /// No description provided for @quizSpeedRead.
  ///
  /// In en, this message translates to:
  /// **'Quiz speech speed, {description}. Press 7 for slower or 9 for faster. This speed is used only in quizzes.'**
  String quizSpeedRead(String description);

  /// No description provided for @quizSpeedFaster.
  ///
  /// In en, this message translates to:
  /// **'Faster. {description}.'**
  String quizSpeedFaster(String description);

  /// No description provided for @quizSpeedSlower.
  ///
  /// In en, this message translates to:
  /// **'Slower. {description}.'**
  String quizSpeedSlower(String description);

  /// No description provided for @quizSpeedFastest.
  ///
  /// In en, this message translates to:
  /// **'Fastest quiz speech, {description}.'**
  String quizSpeedFastest(String description);

  /// No description provided for @quizSpeedSlowest.
  ///
  /// In en, this message translates to:
  /// **'Slowest quiz speech, {description}.'**
  String quizSpeedSlowest(String description);

  /// No description provided for @quizStudentScreen.
  ///
  /// In en, this message translates to:
  /// **'Student quizzes'**
  String get quizStudentScreen;

  /// No description provided for @quizStudentNavigation.
  ///
  /// In en, this message translates to:
  /// **'refresh, quiz state and subject filters, available quizzes, and attempt history'**
  String get quizStudentNavigation;

  /// No description provided for @quizStudentIntroBrief.
  ///
  /// In en, this message translates to:
  /// **'Use left or right on a filter to change it.'**
  String get quizStudentIntroBrief;

  /// No description provided for @quizStudentIntroDetailed.
  ///
  /// In en, this message translates to:
  /// **'Use left or right on a filter to change it. Press OK on a quiz to hear its details and confirm starting. Moving focus never starts a quiz.'**
  String get quizStudentIntroDetailed;

  /// No description provided for @quizAvailable.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No quizzes available.} =1{1 quiz available.} other{{count} quizzes available.}}'**
  String quizAvailable(int count);

  /// No description provided for @quizStudentState.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 quiz shown, {open} open.} other{{count} quizzes shown, {open} open.}}'**
  String quizStudentState(int count, String open);

  /// No description provided for @quizStateAll.
  ///
  /// In en, this message translates to:
  /// **'All states'**
  String get quizStateAll;

  /// No description provided for @quizStateScheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get quizStateScheduled;

  /// No description provided for @quizStateOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get quizStateOpen;

  /// No description provided for @quizStateClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get quizStateClosed;

  /// No description provided for @quizStateFilter.
  ///
  /// In en, this message translates to:
  /// **'Quiz state: {name}, {position} of {count}.'**
  String quizStateFilter(String name, String position, String count);

  /// No description provided for @quizSubjectFilter.
  ///
  /// In en, this message translates to:
  /// **'Subject: {name}, {position} of {count}.'**
  String quizSubjectFilter(String name, String position, String count);

  /// No description provided for @quizChangeWithArrows.
  ///
  /// In en, this message translates to:
  /// **'Left or right to change'**
  String get quizChangeWithArrows;

  /// No description provided for @quizAllSubjects.
  ///
  /// In en, this message translates to:
  /// **'All subjects'**
  String get quizAllSubjects;

  /// status is a quiz status, from the server or translated.
  ///
  /// In en, this message translates to:
  /// **'{subject}, {title}, {status}.'**
  String quizRowHead(String subject, String title, String status);

  /// Button label.
  ///
  /// In en, this message translates to:
  /// **'Start quiz'**
  String get quizStartQuiz;

  /// No description provided for @quizResumeQuiz.
  ///
  /// In en, this message translates to:
  /// **'Resume quiz'**
  String get quizResumeQuiz;

  /// No description provided for @quizHistoryRow.
  ///
  /// In en, this message translates to:
  /// **'Review {title} attempt history. Highest score {score}'**
  String quizHistoryRow(String title, String score);

  /// No description provided for @quizLimitReached.
  ///
  /// In en, this message translates to:
  /// **'No attempts left for {title}. Open attempt history to review your scores.'**
  String quizLimitReached(String title);

  /// No description provided for @quizStartTitle.
  ///
  /// In en, this message translates to:
  /// **'Start quiz?'**
  String get quizStartTitle;

  /// No description provided for @quizResumeTitle.
  ///
  /// In en, this message translates to:
  /// **'Resume quiz?'**
  String get quizResumeTitle;

  /// No description provided for @quizTitleSentence.
  ///
  /// In en, this message translates to:
  /// **'{title}.'**
  String quizTitleSentence(String title);

  /// No description provided for @quizClosesSentence.
  ///
  /// In en, this message translates to:
  /// **'Closes {when}.'**
  String quizClosesSentence(String when);

  /// No description provided for @quizStartAttempt.
  ///
  /// In en, this message translates to:
  /// **'Start attempt'**
  String get quizStartAttempt;

  /// No description provided for @quizResumeAttempt.
  ///
  /// In en, this message translates to:
  /// **'Resume attempt'**
  String get quizResumeAttempt;

  /// No description provided for @quizStartFailed.
  ///
  /// In en, this message translates to:
  /// **'The quiz could not be started. Check that it is open.'**
  String get quizStartFailed;

  /// No description provided for @quizHistoryFailed.
  ///
  /// In en, this message translates to:
  /// **'Attempt history could not be loaded.'**
  String get quizHistoryFailed;

  /// No description provided for @quizHistoryScreen.
  ///
  /// In en, this message translates to:
  /// **'Attempt history. Scores are private. Move to the summary or an attempt to review it.'**
  String get quizHistoryScreen;

  /// No description provided for @quizPracticeHistory.
  ///
  /// In en, this message translates to:
  /// **'Practice history. Not academic grades.'**
  String get quizPracticeHistory;

  /// No description provided for @quizHighestScoreValue.
  ///
  /// In en, this message translates to:
  /// **'Highest score: {score}'**
  String quizHighestScoreValue(String score);

  /// No description provided for @quizNoScoreReleasedYet.
  ///
  /// In en, this message translates to:
  /// **'Completed attempts exist; no score is released yet.'**
  String get quizNoScoreReleasedYet;

  /// No description provided for @quizNoCompletedAttempt.
  ///
  /// In en, this message translates to:
  /// **'No completed attempt'**
  String get quizNoCompletedAttempt;

  /// No description provided for @quizHistoryAttempt.
  ///
  /// In en, this message translates to:
  /// **'Attempt {number}. {status}. {result} Press OK to review.'**
  String quizHistoryAttempt(String number, String status, String result);

  /// No description provided for @quizResumeFromList.
  ///
  /// In en, this message translates to:
  /// **'This attempt is in progress. Return to the quiz list to resume it. Leaving does not submit.'**
  String get quizResumeFromList;

  /// No description provided for @quizReviewFailed.
  ///
  /// In en, this message translates to:
  /// **'Attempt review could not be loaded. Check your connection and try again.'**
  String get quizReviewFailed;

  /// No description provided for @quizReviewTimedOut.
  ///
  /// In en, this message translates to:
  /// **'Attempt review took too long. Check your connection and try again.'**
  String get quizReviewTimedOut;

  /// No description provided for @quizReviewScreenMessage.
  ///
  /// In en, this message translates to:
  /// **'Attempt review. {message}'**
  String quizReviewScreenMessage(String message);

  /// No description provided for @quizReviewScreen.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Attempt review. 1 question. Use up and down to review each answer.} other{Attempt review. {count} questions. Use up and down to review each answer.}}'**
  String quizReviewScreen(int count);

  /// No description provided for @quizReviewQuestionCorrect.
  ///
  /// In en, this message translates to:
  /// **'Question {number}. Correct. {question}. You chose {chosen}. Correct answer {answer}. {explanation}'**
  String quizReviewQuestionCorrect(
    String number,
    String question,
    String chosen,
    String answer,
    String explanation,
  );

  /// No description provided for @quizReviewQuestionIncorrect.
  ///
  /// In en, this message translates to:
  /// **'Question {number}. Incorrect. {question}. You chose {chosen}. Correct answer {answer}. {explanation}'**
  String quizReviewQuestionIncorrect(
    String number,
    String question,
    String chosen,
    String answer,
    String explanation,
  );

  /// No description provided for @quizNoAnswer.
  ///
  /// In en, this message translates to:
  /// **'no answer'**
  String get quizNoAnswer;

  /// No description provided for @quizTeacherScreen.
  ///
  /// In en, this message translates to:
  /// **'Teacher quizzes for {className}, {subjectName}'**
  String quizTeacherScreen(String className, String subjectName);

  /// No description provided for @quizTeacherNavigation.
  ///
  /// In en, this message translates to:
  /// **'bank search and saved questions, quiz drafts, published quizzes, and their results'**
  String get quizTeacherNavigation;

  /// No description provided for @quizTeacherIntroDetailed.
  ///
  /// In en, this message translates to:
  /// **'Use the D-pad to explore bank search and saved questions, quiz drafts, published quizzes and results.'**
  String get quizTeacherIntroDetailed;

  /// No description provided for @quizBankQuestionCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 bank question} other{{count} bank questions}}'**
  String quizBankQuestionCount(int count);

  /// No description provided for @quizQuizCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 quiz} other{{count} quizzes}}'**
  String quizQuizCount(int count);

  /// No description provided for @quizDraftCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 draft} other{{count} drafts}}'**
  String quizDraftCount(int count);

  /// questions is a phrase such as "3 bank questions"; quizzes such as "2 quizzes".
  ///
  /// In en, this message translates to:
  /// **'{questions} and {quizzes} loaded.'**
  String quizTeacherLoaded(String questions, String quizzes);

  /// drafts and bankQuestions are counted phrases such as "2 drafts" and "5 bank questions"; published and closed are numbers.
  ///
  /// In en, this message translates to:
  /// **'{drafts}, {published} published, {closed} closed. {bankQuestions}.'**
  String quizTeacherState(
    String drafts,
    String published,
    String closed,
    String bankQuestions,
  );

  /// No description provided for @quizTeacherLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'The question bank or quiz list could not be refreshed. Press 1 to try again before creating another quiz.'**
  String get quizTeacherLoadFailed;

  /// No description provided for @quizRefreshQuizzes.
  ///
  /// In en, this message translates to:
  /// **'Refresh quiz content'**
  String get quizRefreshQuizzes;

  /// No description provided for @quizSearchBank.
  ///
  /// In en, this message translates to:
  /// **'Search private question bank'**
  String get quizSearchBank;

  /// No description provided for @quizCreateQuestion.
  ///
  /// In en, this message translates to:
  /// **'Create four option question'**
  String get quizCreateQuestion;

  /// No description provided for @quizCreateQuiz.
  ///
  /// In en, this message translates to:
  /// **'Create quiz draft'**
  String get quizCreateQuiz;

  /// No description provided for @quizCreatePractice.
  ///
  /// In en, this message translates to:
  /// **'Create separate untimed ungraded practice. Unlimited retries'**
  String get quizCreatePractice;

  /// No description provided for @quizBankQuestionItem.
  ///
  /// In en, this message translates to:
  /// **'Question bank item, {question}. Revision {revision}. Press OK for edit, revision history, duplicate, archive, or add actions'**
  String quizBankQuestionItem(String question, String revision);

  /// No description provided for @quizRevisionUnknownOlder.
  ///
  /// In en, this message translates to:
  /// **'unknown, older question'**
  String get quizRevisionUnknownOlder;

  /// No description provided for @quizRevisionUnknownLegacy.
  ///
  /// In en, this message translates to:
  /// **'unknown legacy'**
  String get quizRevisionUnknownLegacy;

  /// No description provided for @quizContinueCreating.
  ///
  /// In en, this message translates to:
  /// **'Continue creating {title}. {questions}'**
  String quizContinueCreating(String title, String questions);

  /// count is the number of questions, spoken with the plural noun even for 1.
  ///
  /// In en, this message translates to:
  /// **'Continue creating {title}. {count} questions'**
  String quizContinueCreatingRaw(String title, String count);

  /// No description provided for @quizCloseWithConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Close {title}, with confirmation'**
  String quizCloseWithConfirmation(String title);

  /// No description provided for @quizCloseNamed.
  ///
  /// In en, this message translates to:
  /// **'Close {title}'**
  String quizCloseNamed(String title);

  /// No description provided for @quizIsClosed.
  ///
  /// In en, this message translates to:
  /// **'{title} is closed'**
  String quizIsClosed(String title);

  /// No description provided for @quizDuplicateTarget.
  ///
  /// In en, this message translates to:
  /// **'Duplicate {title} into a new editable draft'**
  String quizDuplicateTarget(String title);

  /// No description provided for @quizResultsTarget.
  ///
  /// In en, this message translates to:
  /// **'View results for {title}'**
  String quizResultsTarget(String title);

  /// No description provided for @quizCard.
  ///
  /// In en, this message translates to:
  /// **'{title}. Status {status}. {questions}.'**
  String quizCard(String title, String status, String questions);

  /// No description provided for @quizAccountChangedBank.
  ///
  /// In en, this message translates to:
  /// **'Your account changed. Reopen the question bank before continuing.'**
  String get quizAccountChangedBank;

  /// No description provided for @quizQuestionSaveUnconfirmed.
  ///
  /// In en, this message translates to:
  /// **'{reason} Question save could not be confirmed. Check the bank and refresh before retrying; do not create a duplicate.'**
  String quizQuestionSaveUnconfirmed(String reason);

  /// No description provided for @quizMissingRevision.
  ///
  /// In en, this message translates to:
  /// **'The server returned a question without a revision. Ask the administrator to update the quiz backend.'**
  String get quizMissingRevision;

  /// No description provided for @quizSavedQuestionMismatch.
  ///
  /// In en, this message translates to:
  /// **'The saved question did not match.'**
  String get quizSavedQuestionMismatch;

  /// No description provided for @quizQuestionSaved.
  ///
  /// In en, this message translates to:
  /// **'Question saved. Editing this bank question later will not change existing quizzes.'**
  String get quizQuestionSaved;

  /// No description provided for @quizNoRevisionForEdit.
  ///
  /// In en, this message translates to:
  /// **'This server did not supply a question revision. Ask the administrator to update the quiz backend before editing.'**
  String get quizNoRevisionForEdit;

  /// No description provided for @quizQuestionUpdateUnconfirmed.
  ///
  /// In en, this message translates to:
  /// **'{reason} The bank question could not be confirmed updated. Refresh and review its current revision before retrying.'**
  String quizQuestionUpdateUnconfirmed(String reason);

  /// No description provided for @quizSavedRevisionMismatch.
  ///
  /// In en, this message translates to:
  /// **'The saved revision did not match.'**
  String get quizSavedRevisionMismatch;

  /// No description provided for @quizQuestionUpdated.
  ///
  /// In en, this message translates to:
  /// **'Bank question updated. Existing quiz snapshots were not changed.'**
  String get quizQuestionUpdated;

  /// No description provided for @quizArchiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Archive bank question?'**
  String get quizArchiveTitle;

  /// No description provided for @quizArchiveMessage.
  ///
  /// In en, this message translates to:
  /// **'Archive this private bank question? Existing quiz snapshots and attempts are not changed.'**
  String get quizArchiveMessage;

  /// No description provided for @quizArchiveConfirm.
  ///
  /// In en, this message translates to:
  /// **'Archive question'**
  String get quizArchiveConfirm;

  /// No description provided for @quizArchiveFailed.
  ///
  /// In en, this message translates to:
  /// **'The bank question could not be archived.'**
  String get quizArchiveFailed;

  /// No description provided for @quizArchived.
  ///
  /// In en, this message translates to:
  /// **'Bank question archived.'**
  String get quizArchived;

  /// No description provided for @quizDuplicateQuestionFailed.
  ///
  /// In en, this message translates to:
  /// **'The bank question could not be duplicated.'**
  String get quizDuplicateQuestionFailed;

  /// No description provided for @quizQuestionDuplicated.
  ///
  /// In en, this message translates to:
  /// **'Bank question copy created.'**
  String get quizQuestionDuplicated;

  /// No description provided for @quizQuestionActions.
  ///
  /// In en, this message translates to:
  /// **'Actions for {question}'**
  String quizQuestionActions(String question);

  /// No description provided for @quizActionEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit bank question'**
  String get quizActionEdit;

  /// No description provided for @quizActionDuplicate.
  ///
  /// In en, this message translates to:
  /// **'Duplicate bank question'**
  String get quizActionDuplicate;

  /// No description provided for @quizActionArchive.
  ///
  /// In en, this message translates to:
  /// **'Archive bank question'**
  String get quizActionArchive;

  /// No description provided for @quizActionRevisions.
  ///
  /// In en, this message translates to:
  /// **'Read question revision history'**
  String get quizActionRevisions;

  /// No description provided for @quizActionAddTo.
  ///
  /// In en, this message translates to:
  /// **'Add to {title}'**
  String quizActionAddTo(String title);

  /// No description provided for @quizRefreshBeforeDraft.
  ///
  /// In en, this message translates to:
  /// **'Refresh and review the quiz list before creating another draft.'**
  String get quizRefreshBeforeDraft;

  /// No description provided for @quizDraftUnconfirmed.
  ///
  /// In en, this message translates to:
  /// **'{reason} Draft save could not be confirmed. Refresh the quiz list before creating another draft.'**
  String quizDraftUnconfirmed(String reason);

  /// No description provided for @quizSavedDraftMismatch.
  ///
  /// In en, this message translates to:
  /// **'The saved draft did not match.'**
  String get quizSavedDraftMismatch;

  /// No description provided for @quizDraftSaved.
  ///
  /// In en, this message translates to:
  /// **'Quiz draft saved.'**
  String get quizDraftSaved;

  /// No description provided for @quizAddToQuizFailed.
  ///
  /// In en, this message translates to:
  /// **'The question could not be added to this quiz.'**
  String get quizAddToQuizFailed;

  /// No description provided for @quizAddedToQuiz.
  ///
  /// In en, this message translates to:
  /// **'Question added to the quiz.'**
  String get quizAddedToQuiz;

  /// No description provided for @quizPublishTitle.
  ///
  /// In en, this message translates to:
  /// **'Publish quiz?'**
  String get quizPublishTitle;

  /// No description provided for @quizPublishMessage.
  ///
  /// In en, this message translates to:
  /// **'Publish \"{title}\" to eligible students? Questions become fixed for this quiz.'**
  String quizPublishMessage(String title);

  /// No description provided for @quizPublishMessageSnapshots.
  ///
  /// In en, this message translates to:
  /// **'Publish \"{title}\" to eligible students? Questions become academic snapshots.'**
  String quizPublishMessageSnapshots(String title);

  /// No description provided for @quizPublishConfirm.
  ///
  /// In en, this message translates to:
  /// **'Publish quiz'**
  String get quizPublishConfirm;

  /// No description provided for @quizPublishUnconfirmed.
  ///
  /// In en, this message translates to:
  /// **'Publishing could not be confirmed. Refresh and review the quiz status before trying again.'**
  String get quizPublishUnconfirmed;

  /// No description provided for @quizPublishedNoRecipients.
  ///
  /// In en, this message translates to:
  /// **'Quiz published. There are no eligible students to notify.'**
  String get quizPublishedNoRecipients;

  /// No description provided for @quizNoEligibleToNotify.
  ///
  /// In en, this message translates to:
  /// **'There are no eligible students to notify.'**
  String get quizNoEligibleToNotify;

  /// No description provided for @quizPublishedNoneDelivered.
  ///
  /// In en, this message translates to:
  /// **'Quiz published, but no student device notifications were delivered. Check notification registration and server Firebase credentials.'**
  String get quizPublishedNoneDelivered;

  /// No description provided for @quizPublishedWithFailures.
  ///
  /// In en, this message translates to:
  /// **'Quiz published. {sent} device notifications sent and {failures} failed.'**
  String quizPublishedWithFailures(String sent, String failures);

  /// No description provided for @quizPublishedSent.
  ///
  /// In en, this message translates to:
  /// **'Quiz published. {sent} device notifications sent.'**
  String quizPublishedSent(String sent);

  /// No description provided for @quizCloseTitle.
  ///
  /// In en, this message translates to:
  /// **'Close quiz?'**
  String get quizCloseTitle;

  /// No description provided for @quizCloseMessage.
  ///
  /// In en, this message translates to:
  /// **'Close \"{title}\"? No new attempts can start and active attempts will be finished.'**
  String quizCloseMessage(String title);

  /// No description provided for @quizCloseMessageFinalized.
  ///
  /// In en, this message translates to:
  /// **'Close \"{title}\"? No new attempts can start and active attempts will be finalized.'**
  String quizCloseMessageFinalized(String title);

  /// No description provided for @quizCloseConfirm.
  ///
  /// In en, this message translates to:
  /// **'Close quiz'**
  String get quizCloseConfirm;

  /// No description provided for @quizCloseFailed.
  ///
  /// In en, this message translates to:
  /// **'The quiz could not be closed.'**
  String get quizCloseFailed;

  /// No description provided for @quizClosed.
  ///
  /// In en, this message translates to:
  /// **'Quiz closed.'**
  String get quizClosed;

  /// No description provided for @quizDuplicateQuizFailed.
  ///
  /// In en, this message translates to:
  /// **'The quiz could not be duplicated.'**
  String get quizDuplicateQuizFailed;

  /// No description provided for @quizQuizDuplicated.
  ///
  /// In en, this message translates to:
  /// **'Editable quiz draft created.'**
  String get quizQuizDuplicated;

  /// No description provided for @quizDraftAccountChanged.
  ///
  /// In en, this message translates to:
  /// **'Your account changed. This draft cannot be reviewed here.'**
  String get quizDraftAccountChanged;

  /// No description provided for @quizDraftLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'The draft or question bank could not be loaded. Refresh before continuing.'**
  String get quizDraftLoadFailed;

  /// No description provided for @quizBankRefreshFailed.
  ///
  /// In en, this message translates to:
  /// **'{reason} The question bank could not be refreshed. No question was added. Try Choose a saved question again.'**
  String quizBankRefreshFailed(String reason);

  /// No description provided for @quizSavedListUnreadable.
  ///
  /// In en, this message translates to:
  /// **'The saved question list could not be read.'**
  String get quizSavedListUnreadable;

  /// No description provided for @quizNoUnusedQuestions.
  ///
  /// In en, this message translates to:
  /// **'No unused questions are available in this workspace. Choose Write a question.'**
  String get quizNoUnusedQuestions;

  /// No description provided for @quizAllSavedQuestionsUsed.
  ///
  /// In en, this message translates to:
  /// **'Every saved question is already in this quiz. Choose Write a question.'**
  String get quizAllSavedQuestionsUsed;

  /// No description provided for @quizChooseSaved.
  ///
  /// In en, this message translates to:
  /// **'Choose a saved question'**
  String get quizChooseSaved;

  /// question is the question text; className and subjectName name where it was saved.
  ///
  /// In en, this message translates to:
  /// **'{question}. From {className}, {subjectName}'**
  String quizSavedQuestionFrom(
    String question,
    String className,
    String subjectName,
  );

  /// No description provided for @quizAnotherClass.
  ///
  /// In en, this message translates to:
  /// **'another class'**
  String get quizAnotherClass;

  /// No description provided for @quizAnotherSubject.
  ///
  /// In en, this message translates to:
  /// **'another subject'**
  String get quizAnotherSubject;

  /// No description provided for @quizAddUnconfirmed.
  ///
  /// In en, this message translates to:
  /// **'{reason} Adding the question could not be confirmed. Refresh and review saved questions before adding again; it may already be saved.'**
  String quizAddUnconfirmed(String reason);

  /// No description provided for @quizQuestionAddedSentence.
  ///
  /// In en, this message translates to:
  /// **'Question added.'**
  String get quizQuestionAddedSentence;

  /// No description provided for @quizAddAnotherOrReview.
  ///
  /// In en, this message translates to:
  /// **'Add another or choose Review.'**
  String get quizAddAnotherOrReview;

  /// No description provided for @quizQuestionsSaved.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 question saved.} other{{count} questions saved.}}'**
  String quizQuestionsSaved(int count);

  /// count is the number of questions, spoken with the plural noun even for 1.
  ///
  /// In en, this message translates to:
  /// **'{count} questions saved.'**
  String quizQuestionsSavedRaw(String count);

  /// description is the quiz description, possibly empty; questions is a counted phrase.
  ///
  /// In en, this message translates to:
  /// **'{title}. {description} {questions}.'**
  String quizDraftSummaryHead(
    String title,
    String description,
    String questions,
  );

  /// description is the quiz description, possibly empty.
  ///
  /// In en, this message translates to:
  /// **'{title}. {description} {count} questions.'**
  String quizDraftSummaryHeadRaw(
    String title,
    String description,
    String count,
  );

  /// No description provided for @quizUngradedPracticeSummary.
  ///
  /// In en, this message translates to:
  /// **'Ungraded practice. Unlimited attempts. No timer.'**
  String get quizUngradedPracticeSummary;

  /// No description provided for @quizGradedSummary.
  ///
  /// In en, this message translates to:
  /// **'Graded quiz. {attempts}.'**
  String quizGradedSummary(String attempts);

  /// No description provided for @quizGradedSummaryRaw.
  ///
  /// In en, this message translates to:
  /// **'Graded quiz. {count} attempts.'**
  String quizGradedSummaryRaw(String count);

  /// No description provided for @quizNoTimer.
  ///
  /// In en, this message translates to:
  /// **'No timer.'**
  String get quizNoTimer;

  /// No description provided for @quizPerAttempt.
  ///
  /// In en, this message translates to:
  /// **'{duration} per attempt.'**
  String quizPerAttempt(String duration);

  /// No description provided for @quizMinutesPerAttemptRaw.
  ///
  /// In en, this message translates to:
  /// **'{minutes} minutes per attempt.'**
  String quizMinutesPerAttemptRaw(String minutes);

  /// No description provided for @quizOpensSentence.
  ///
  /// In en, this message translates to:
  /// **'Opens {when}.'**
  String quizOpensSentence(String when);

  /// value is the opening time as sent by the server, or "when published".
  ///
  /// In en, this message translates to:
  /// **'Opens: {value}.'**
  String quizOpensColon(String value);

  /// value is the closing time as sent by the server, or "not scheduled".
  ///
  /// In en, this message translates to:
  /// **'Closes: {value}.'**
  String quizClosesColon(String value);

  /// No description provided for @quizWhenPublished.
  ///
  /// In en, this message translates to:
  /// **'when published'**
  String get quizWhenPublished;

  /// No description provided for @quizNeverNotScheduled.
  ///
  /// In en, this message translates to:
  /// **'never, not scheduled'**
  String get quizNeverNotScheduled;

  /// No description provided for @quizNotScheduled.
  ///
  /// In en, this message translates to:
  /// **'not scheduled'**
  String get quizNotScheduled;

  /// state is "on" or "off".
  ///
  /// In en, this message translates to:
  /// **'Shuffle questions {state}.'**
  String quizShuffleQuestionsState(String state);

  /// No description provided for @quizShuffleOptionsState.
  ///
  /// In en, this message translates to:
  /// **'Shuffle options {state}.'**
  String quizShuffleOptionsState(String state);

  /// No description provided for @quizShuffleQuestionsColon.
  ///
  /// In en, this message translates to:
  /// **'Shuffle questions: {state}.'**
  String quizShuffleQuestionsColon(String state);

  /// No description provided for @quizShuffleOptionsColon.
  ///
  /// In en, this message translates to:
  /// **'Shuffle options: {state}.'**
  String quizShuffleOptionsColon(String state);

  /// No description provided for @quizRemoveChoose.
  ///
  /// In en, this message translates to:
  /// **'Choose a question to remove from this draft'**
  String get quizRemoveChoose;

  /// No description provided for @quizRemoveOption.
  ///
  /// In en, this message translates to:
  /// **'Question {number}: {text}'**
  String quizRemoveOption(String number, String text);

  /// No description provided for @quizRemoveTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove selected question?'**
  String get quizRemoveTitle;

  /// No description provided for @quizRemoveMessage.
  ///
  /// In en, this message translates to:
  /// **'Remove this question from the draft? The reusable question bank is not changed.'**
  String get quizRemoveMessage;

  /// No description provided for @quizRemoveConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove question'**
  String get quizRemoveConfirm;

  /// No description provided for @quizRemoveUnconfirmed.
  ///
  /// In en, this message translates to:
  /// **'Removal could not be confirmed. Review the refreshed draft before trying again.'**
  String get quizRemoveUnconfirmed;

  /// No description provided for @quizQuestionRemovedSentence.
  ///
  /// In en, this message translates to:
  /// **'Question removed from the draft.'**
  String get quizQuestionRemovedSentence;

  /// No description provided for @quizSettingsUnconfirmed.
  ///
  /// In en, this message translates to:
  /// **'Settings save could not be confirmed. Refresh and review the saved settings before publishing.'**
  String get quizSettingsUnconfirmed;

  /// No description provided for @quizSettingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Quiz settings saved. Review them before publishing.'**
  String get quizSettingsSaved;

  /// No description provided for @quizSavedQuestion.
  ///
  /// In en, this message translates to:
  /// **'Saved question {number}: {text}. Already in this draft. Press OK to read its options'**
  String quizSavedQuestion(String number, String text);

  /// No description provided for @quizQuestionNumbered.
  ///
  /// In en, this message translates to:
  /// **'Question {number}. {text}.'**
  String quizQuestionNumbered(String number, String text);

  /// No description provided for @quizDraftOption.
  ///
  /// In en, this message translates to:
  /// **'Option {number}: {text}.'**
  String quizDraftOption(String number, String text);

  /// No description provided for @quizDraftOptionCorrect.
  ///
  /// In en, this message translates to:
  /// **'Option {number}: {text}, correct answer.'**
  String quizDraftOptionCorrect(String number, String text);

  /// No description provided for @quizReviewingBeforePublishing.
  ///
  /// In en, this message translates to:
  /// **'Reviewing before publishing.'**
  String get quizReviewingBeforePublishing;

  /// No description provided for @quizAddingQuestions.
  ///
  /// In en, this message translates to:
  /// **'Adding questions.'**
  String get quizAddingQuestions;

  /// No description provided for @quizRefreshSavedDraft.
  ///
  /// In en, this message translates to:
  /// **'Refresh saved draft'**
  String get quizRefreshSavedDraft;

  /// No description provided for @quizWriteQuestionTarget.
  ///
  /// In en, this message translates to:
  /// **'Write a question and save it to this quiz and your question bank'**
  String get quizWriteQuestionTarget;

  /// No description provided for @quizReviewBeforePublishingTarget.
  ///
  /// In en, this message translates to:
  /// **'Review questions and quiz settings before publishing'**
  String get quizReviewBeforePublishingTarget;

  /// No description provided for @quizRemoveQuestionTarget.
  ///
  /// In en, this message translates to:
  /// **'Remove a question from this draft, with confirmation'**
  String get quizRemoveQuestionTarget;

  /// No description provided for @quizChangeSettingsTarget.
  ///
  /// In en, this message translates to:
  /// **'Change title or optional quiz settings'**
  String get quizChangeSettingsTarget;

  /// No description provided for @quizBackToAdding.
  ///
  /// In en, this message translates to:
  /// **'Back to adding questions'**
  String get quizBackToAdding;

  /// No description provided for @quizPublishWithConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Publish quiz, with confirmation'**
  String get quizPublishWithConfirmation;

  /// No description provided for @quizSaveForLaterTarget.
  ///
  /// In en, this message translates to:
  /// **'Save for later and return. Confirmed changes are already saved as a draft'**
  String get quizSaveForLaterTarget;

  /// No description provided for @quizDraftNavigationReview.
  ///
  /// In en, this message translates to:
  /// **'saved questions, quiz settings, and publishing with confirmation'**
  String get quizDraftNavigationReview;

  /// No description provided for @quizDraftNavigationAdd.
  ///
  /// In en, this message translates to:
  /// **'write or choose saved questions, remove questions, and review the draft'**
  String get quizDraftNavigationAdd;

  /// No description provided for @quizPublishedScreen.
  ///
  /// In en, this message translates to:
  /// **'Quiz published'**
  String get quizPublishedScreen;

  /// No description provided for @quizDraftStep3.
  ///
  /// In en, this message translates to:
  /// **'Step 3 of 3. Review before publishing. Nothing is published until you confirm.'**
  String get quizDraftStep3;

  /// No description provided for @quizDraftStep2.
  ///
  /// In en, this message translates to:
  /// **'Step 2 of 3. Add questions. Choose Write or Use saved question. Then Review.'**
  String get quizDraftStep2;

  /// No description provided for @quizSaveForLater.
  ///
  /// In en, this message translates to:
  /// **'Save for later and return'**
  String get quizSaveForLater;

  /// No description provided for @quizWriteQuestion.
  ///
  /// In en, this message translates to:
  /// **'Write a question'**
  String get quizWriteQuestion;

  /// No description provided for @quizUseSavedQuestion.
  ///
  /// In en, this message translates to:
  /// **'Use saved question'**
  String get quizUseSavedQuestion;

  /// No description provided for @quizRemoveQuestion.
  ///
  /// In en, this message translates to:
  /// **'Remove a question'**
  String get quizRemoveQuestion;

  /// No description provided for @quizReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get quizReview;

  /// No description provided for @quizPublishConfirmLabel.
  ///
  /// In en, this message translates to:
  /// **'Publish with confirmation'**
  String get quizPublishConfirmLabel;

  /// No description provided for @quizChangeSettingsLabel.
  ///
  /// In en, this message translates to:
  /// **'Change title or optional settings'**
  String get quizChangeSettingsLabel;

  /// No description provided for @quizResultsScreen.
  ///
  /// In en, this message translates to:
  /// **'Results for {title}'**
  String quizResultsScreen(String title);

  /// No description provided for @quizResultsNavigation.
  ///
  /// In en, this message translates to:
  /// **'quiz summary, student results, and available result actions'**
  String get quizResultsNavigation;

  /// No description provided for @quizResultsFailed.
  ///
  /// In en, this message translates to:
  /// **'Quiz results could not be loaded.'**
  String get quizResultsFailed;

  /// No description provided for @quizStudentsCompleted.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 student completed.} other{{count} students completed.}}'**
  String quizStudentsCompleted(int count);

  /// No description provided for @quizStudentsNotAttemptedYet.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 student not attempted yet.} other{{count} students not attempted yet.}}'**
  String quizStudentsNotAttemptedYet(int count);

  /// No description provided for @quizResultsLoadedRaw.
  ///
  /// In en, this message translates to:
  /// **'{completed} students completed. {notAttempted} students have not attempted.'**
  String quizResultsLoadedRaw(String completed, String notAttempted);

  /// No description provided for @quizStatEligible.
  ///
  /// In en, this message translates to:
  /// **'Eligible: {value}'**
  String quizStatEligible(String value);

  /// No description provided for @quizStatStarted.
  ///
  /// In en, this message translates to:
  /// **'Started: {value}'**
  String quizStatStarted(String value);

  /// No description provided for @quizStatCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed: {value}'**
  String quizStatCompleted(String value);

  /// No description provided for @quizStatNotAttempted.
  ///
  /// In en, this message translates to:
  /// **'Not attempted: {value}'**
  String quizStatNotAttempted(String value);

  /// No description provided for @quizStatCompletion.
  ///
  /// In en, this message translates to:
  /// **'Completion: {value}'**
  String quizStatCompletion(String value);

  /// No description provided for @quizStatCompletionPercent.
  ///
  /// In en, this message translates to:
  /// **'Completion: {value} percent'**
  String quizStatCompletionPercent(String value);

  /// No description provided for @quizPracticeParticipation.
  ///
  /// In en, this message translates to:
  /// **'Practice participation, not academic grades.'**
  String get quizPracticeParticipation;

  /// No description provided for @quizStatAverageHighest.
  ///
  /// In en, this message translates to:
  /// **'Average highest score: {value}'**
  String quizStatAverageHighest(String value);

  /// No description provided for @quizStatLowest.
  ///
  /// In en, this message translates to:
  /// **'Lowest completed score: {value}'**
  String quizStatLowest(String value);

  /// No description provided for @quizStudentNotAttempted.
  ///
  /// In en, this message translates to:
  /// **'{name} has not attempted this quiz.'**
  String quizStudentNotAttempted(String name);

  /// No description provided for @quizStudentPractice.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{name}. 1 practice attempt. Not academic grades.} other{{name}. {count} practice attempts. Not academic grades.}}'**
  String quizStudentPractice(int count, String name);

  /// No description provided for @quizStudentPracticeRaw.
  ///
  /// In en, this message translates to:
  /// **'{name}. {count} practice attempts. Not academic grades.'**
  String quizStudentPracticeRaw(String name, String count);

  /// No description provided for @quizStudentAttemptScore.
  ///
  /// In en, this message translates to:
  /// **'attempt {number}, {score}, {status}'**
  String quizStudentAttemptScore(String number, String score, String status);

  /// No description provided for @quizStudentAttemptRaw.
  ///
  /// In en, this message translates to:
  /// **'attempt {number}, {score} percent, {status}'**
  String quizStudentAttemptRaw(String number, String score, String status);

  /// No description provided for @quizStudentScores.
  ///
  /// In en, this message translates to:
  /// **'{name}. Highest score {highest}. {scores}.'**
  String quizStudentScores(String name, String highest, String scores);

  /// No description provided for @quizStudentScoresRaw.
  ///
  /// In en, this message translates to:
  /// **'{name}. Highest score {highest} percent. {scores}.'**
  String quizStudentScoresRaw(String name, String highest, String scores);

  /// No description provided for @quizExtraMismatch.
  ///
  /// In en, this message translates to:
  /// **'The extra-time confirmation did not match. Refresh before retrying.'**
  String get quizExtraMismatch;

  /// No description provided for @quizExtraSaved.
  ///
  /// In en, this message translates to:
  /// **'Extra time confirmed for future attempts only. Existing attempt deadlines are unchanged and quiz closing time still applies.'**
  String get quizExtraSaved;

  /// No description provided for @quizEveryoneAttempted.
  ///
  /// In en, this message translates to:
  /// **'Every eligible student has attempted this quiz.'**
  String get quizEveryoneAttempted;

  /// No description provided for @quizRemindTitle.
  ///
  /// In en, this message translates to:
  /// **'Remind students?'**
  String get quizRemindTitle;

  /// title is the quiz title.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Send one quiz reminder to all 1 student who have not attempted {title}?} other{Send one quiz reminder to all {count} students who have not attempted {title}?}}'**
  String quizRemindMessage(int count, String title);

  /// No description provided for @quizRemindMessageRaw.
  ///
  /// In en, this message translates to:
  /// **'Send one quiz reminder to all {count} students who have not attempted {title}?'**
  String quizRemindMessageRaw(String count, String title);

  /// No description provided for @quizRemindConfirm.
  ///
  /// In en, this message translates to:
  /// **'Send reminder'**
  String get quizRemindConfirm;

  /// No description provided for @quizRemindFailed.
  ///
  /// In en, this message translates to:
  /// **'Quiz reminders could not be sent.'**
  String get quizRemindFailed;

  /// No description provided for @quizReminded.
  ///
  /// In en, this message translates to:
  /// **'Reminder sent to {notified} students. {queued} device notifications queued.'**
  String quizReminded(String notified, String queued);

  /// No description provided for @quizReminderProcessed.
  ///
  /// In en, this message translates to:
  /// **'Reminder processed for {notified} students. {queued} device notifications queued.'**
  String quizReminderProcessed(String notified, String queued);

  /// No description provided for @quizRefreshResults.
  ///
  /// In en, this message translates to:
  /// **'Refresh quiz results'**
  String get quizRefreshResults;

  /// No description provided for @quizRefreshResultsLabel.
  ///
  /// In en, this message translates to:
  /// **'Refresh results'**
  String get quizRefreshResultsLabel;

  /// No description provided for @quizRemindAllLabel.
  ///
  /// In en, this message translates to:
  /// **'Remind all students who have not attempted'**
  String get quizRemindAllLabel;

  /// No description provided for @quizRemindUnavailable.
  ///
  /// In en, this message translates to:
  /// **'All students have attempted. Reminder unavailable'**
  String get quizRemindUnavailable;

  /// No description provided for @quizRemindTarget.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Send a reminder to all 1 student who have not attempted} other{Send a reminder to all {count} students who have not attempted}}'**
  String quizRemindTarget(int count);

  /// No description provided for @quizRemindTargetRaw.
  ///
  /// In en, this message translates to:
  /// **'Send a reminder to all {count} students who have not attempted'**
  String quizRemindTargetRaw(String count);

  /// No description provided for @quizExtraTarget.
  ///
  /// In en, this message translates to:
  /// **'Set extra time for {name}. Future attempts only. Current extra time {duration}'**
  String quizExtraTarget(String name, String duration);

  /// No description provided for @quizExtraTargetRaw.
  ///
  /// In en, this message translates to:
  /// **'Set extra minutes for {name}. Future attempts only. Current extra {minutes} minutes'**
  String quizExtraTargetRaw(String name, String minutes);

  /// No description provided for @quizExtraButton.
  ///
  /// In en, this message translates to:
  /// **'Future extra time: {minutes} minutes. Set'**
  String quizExtraButton(String minutes);

  /// No description provided for @quizResultsNotLoaded.
  ///
  /// In en, this message translates to:
  /// **'Results not loaded.'**
  String get quizResultsNotLoaded;

  /// No description provided for @quizCompletionSentence.
  ///
  /// In en, this message translates to:
  /// **'Completion {percent}.'**
  String quizCompletionSentence(String percent);

  /// No description provided for @quizExtraScreen.
  ///
  /// In en, this message translates to:
  /// **'Extra time for {name}. Future attempts only; active attempt deadlines stay fixed. Quiz closing time still applies. Entering zero minutes removes extra time. Press 0 outside the field to cancel.'**
  String quizExtraScreen(String name);

  /// No description provided for @quizExtraField.
  ///
  /// In en, this message translates to:
  /// **'Extra minutes, currently {value}. Press OK to edit'**
  String quizExtraField(String value);

  /// No description provided for @quizEmpty.
  ///
  /// In en, this message translates to:
  /// **'empty'**
  String get quizEmpty;

  /// No description provided for @quizExtraSave.
  ///
  /// In en, this message translates to:
  /// **'Save extra time for future attempts'**
  String get quizExtraSave;

  /// No description provided for @quizExtraCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel without changing extra time'**
  String get quizExtraCancel;

  /// No description provided for @quizExtraInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a whole number of minutes, zero or more, within the server integer range.'**
  String get quizExtraInvalid;

  /// No description provided for @quizExtraCorrect.
  ///
  /// In en, this message translates to:
  /// **'Move up to Extra minutes to correct it.'**
  String get quizExtraCorrect;

  /// No description provided for @quizEditorInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a question, four different non-empty options, and then choose the correct answer.'**
  String get quizEditorInvalid;

  /// No description provided for @quizEditorSpokenInvalid.
  ///
  /// In en, this message translates to:
  /// **'Use up to 20 different topics of 80 characters each. Described notation needs a spoken question, all four spoken options, and a spoken explanation if an explanation is provided. Review and confirm every spoken alternative before saving.'**
  String get quizEditorSpokenInvalid;

  /// No description provided for @quizCorrectChosen.
  ///
  /// In en, this message translates to:
  /// **'Correct answer: option {number}, {number} of {count}.'**
  String quizCorrectChosen(String number, String count);

  /// No description provided for @quizCorrectChosenWithText.
  ///
  /// In en, this message translates to:
  /// **'Correct answer: option {number}, {text}, {number} of {count}.'**
  String quizCorrectChosenWithText(String number, String text, String count);

  /// No description provided for @quizCorrectNotSelected.
  ///
  /// In en, this message translates to:
  /// **'Correct answer not selected. Use left or right to choose'**
  String get quizCorrectNotSelected;

  /// No description provided for @quizCorrectTarget.
  ///
  /// In en, this message translates to:
  /// **'Correct answer: option {number}, {text}. Use left or right to change'**
  String quizCorrectTarget(String number, String text);

  /// state is "on" or "off".
  ///
  /// In en, this message translates to:
  /// **'{name} {state}.'**
  String quizToggled(String name, String state);

  /// No description provided for @quizContentDescribed.
  ///
  /// In en, this message translates to:
  /// **'Content: teacher-described notation or diagram'**
  String get quizContentDescribed;

  /// No description provided for @quizContentPlain.
  ///
  /// In en, this message translates to:
  /// **'Content: English plain text'**
  String get quizContentPlain;

  /// No description provided for @quizReviewedYes.
  ///
  /// In en, this message translates to:
  /// **'Spoken alternatives reviewed by teacher: yes'**
  String get quizReviewedYes;

  /// No description provided for @quizReviewedNo.
  ///
  /// In en, this message translates to:
  /// **'Spoken alternatives reviewed by teacher: no'**
  String get quizReviewedNo;

  /// No description provided for @quizSettingsInvalid.
  ///
  /// In en, this message translates to:
  /// **'Check the title, attempt limit from 1 to 20, time limit, and schedule. The closing time must be after the opening time.'**
  String get quizSettingsInvalid;

  /// No description provided for @quizSetOpening.
  ///
  /// In en, this message translates to:
  /// **'Set opening time using the date and time number fields.'**
  String get quizSetOpening;

  /// No description provided for @quizSetClosing.
  ///
  /// In en, this message translates to:
  /// **'Set closing time using the date and time number fields.'**
  String get quizSetClosing;

  /// No description provided for @quizOpeningSet.
  ///
  /// In en, this message translates to:
  /// **'Opening time set to {when}.'**
  String quizOpeningSet(String when);

  /// No description provided for @quizClosingSet.
  ///
  /// In en, this message translates to:
  /// **'Closing time set to {when}.'**
  String quizClosingSet(String when);

  /// No description provided for @quizReleaseSet.
  ///
  /// In en, this message translates to:
  /// **'Feedback release set to {when}.'**
  String quizReleaseSet(String when);

  /// No description provided for @quizOpeningCleared.
  ///
  /// In en, this message translates to:
  /// **'Opening time cleared.'**
  String get quizOpeningCleared;

  /// No description provided for @quizClosingCleared.
  ///
  /// In en, this message translates to:
  /// **'Closing time cleared.'**
  String get quizClosingCleared;

  /// No description provided for @quizNoOpeningTime.
  ///
  /// In en, this message translates to:
  /// **'No opening time set'**
  String get quizNoOpeningTime;

  /// No description provided for @quizNoClosingTime.
  ///
  /// In en, this message translates to:
  /// **'No closing time set'**
  String get quizNoClosingTime;

  /// No description provided for @quizOpensAt.
  ///
  /// In en, this message translates to:
  /// **'Opens {when}'**
  String quizOpensAt(String when);

  /// No description provided for @quizClosesAt.
  ///
  /// In en, this message translates to:
  /// **'Closes {when}'**
  String quizClosesAt(String when);

  /// No description provided for @quizPolicyChoice.
  ///
  /// In en, this message translates to:
  /// **'Feedback: {name}, {position} of {count}.'**
  String quizPolicyChoice(String name, String position, String count);

  /// No description provided for @quizScheduledRelease.
  ///
  /// In en, this message translates to:
  /// **'Scheduled feedback release {when}'**
  String quizScheduledRelease(String when);

  /// No description provided for @quizAttemptLimitField.
  ///
  /// In en, this message translates to:
  /// **'Attempt limit, currently {value}. Press OK to edit'**
  String quizAttemptLimitField(String value);

  /// No description provided for @quizTimeLimitField.
  ///
  /// In en, this message translates to:
  /// **'Optional time limit in minutes, {value}. Press OK to edit'**
  String quizTimeLimitField(String value);

  /// No description provided for @quizRevisionsScreen.
  ///
  /// In en, this message translates to:
  /// **'Private read-only question revision history. Use older and newer revision controls, then read each section.'**
  String get quizRevisionsScreen;

  /// No description provided for @quizRevisionsAccount.
  ///
  /// In en, this message translates to:
  /// **'Your account changed. Return and sign in again before viewing private question history.'**
  String get quizRevisionsAccount;

  /// No description provided for @quizRevisionsCleared.
  ///
  /// In en, this message translates to:
  /// **'Your account changed. Private question history was cleared.'**
  String get quizRevisionsCleared;

  /// No description provided for @quizRevisionsUnverified.
  ///
  /// In en, this message translates to:
  /// **'Question revision history could not be verified. Retry loading.'**
  String get quizRevisionsUnverified;

  /// No description provided for @quizRevisionsContentUnverified.
  ///
  /// In en, this message translates to:
  /// **'Question revision content could not be verified. Retry loading.'**
  String get quizRevisionsContentUnverified;

  /// No description provided for @quizRevisionsTimedOut.
  ///
  /// In en, this message translates to:
  /// **'Question history took too long. Check your connection and retry.'**
  String get quizRevisionsTimedOut;

  /// No description provided for @quizNoRevisions.
  ///
  /// In en, this message translates to:
  /// **'No tracked revisions. Older question history is unknown, not reconstructed.'**
  String get quizNoRevisions;

  /// No description provided for @quizRevisionsLoaded.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 revision loaded. Read-only question revision {revision}, saved {when}. Existing quiz and attempt snapshots are not changed.} other{{count} revisions loaded. Read-only question revision {revision}, saved {when}. Existing quiz and attempt snapshots are not changed.}}'**
  String quizRevisionsLoaded(int count, String revision, String when);

  /// No description provided for @quizDateUnknown.
  ///
  /// In en, this message translates to:
  /// **'date unknown'**
  String get quizDateUnknown;

  /// No description provided for @quizRevisionSelected.
  ///
  /// In en, this message translates to:
  /// **'Revision {revision} selected. Read-only.'**
  String quizRevisionSelected(String revision);

  /// No description provided for @quizRevisionSelectedOf.
  ///
  /// In en, this message translates to:
  /// **'Revision {revision} selected, {position} of {count}. Read-only.'**
  String quizRevisionSelectedOf(String revision, String position, String count);

  /// No description provided for @quizRevisionFailed.
  ///
  /// In en, this message translates to:
  /// **'{message} Focus is on Refresh revisions.'**
  String quizRevisionFailed(String message);

  /// No description provided for @quizNoRevisionLoaded.
  ///
  /// In en, this message translates to:
  /// **'No revision loaded.'**
  String get quizNoRevisionLoaded;

  /// No description provided for @quizShowingRevision.
  ///
  /// In en, this message translates to:
  /// **'Showing revision {revision}. Read-only.'**
  String quizShowingRevision(String revision);

  /// No description provided for @quizRevisionVersion.
  ///
  /// In en, this message translates to:
  /// **'Revision {revision}. Saved {when}. Read-only.'**
  String quizRevisionVersion(String revision, String when);

  /// No description provided for @quizRevisionQuestion.
  ///
  /// In en, this message translates to:
  /// **'Question: {text}'**
  String quizRevisionQuestion(String text);

  /// No description provided for @quizRevisionTopics.
  ///
  /// In en, this message translates to:
  /// **'Topics: {topics}'**
  String quizRevisionTopics(String topics);

  /// No description provided for @quizRevisionOption.
  ///
  /// In en, this message translates to:
  /// **'Option {number}: {text}.'**
  String quizRevisionOption(String number, String text);

  /// No description provided for @quizCorrectAnswerSentence.
  ///
  /// In en, this message translates to:
  /// **'Correct answer.'**
  String get quizCorrectAnswerSentence;

  /// No description provided for @quizRevisionExplanation.
  ///
  /// In en, this message translates to:
  /// **'Explanation: {text}'**
  String quizRevisionExplanation(String text);

  /// No description provided for @quizNotProvided.
  ///
  /// In en, this message translates to:
  /// **'Not provided'**
  String get quizNotProvided;

  /// No description provided for @quizRevisionNotice.
  ///
  /// In en, this message translates to:
  /// **'Only revisions saved after tracking was introduced are available. Older history is unknown. Existing quiz and attempt snapshots are never rewritten.'**
  String get quizRevisionNotice;

  /// No description provided for @quizRevisionVersionTitle.
  ///
  /// In en, this message translates to:
  /// **'Revision {revision}, {when}'**
  String quizRevisionVersionTitle(String revision, String when);

  /// No description provided for @quizQuestionTextTitle.
  ///
  /// In en, this message translates to:
  /// **'Question text'**
  String get quizQuestionTextTitle;

  /// No description provided for @quizTopicsTitle.
  ///
  /// In en, this message translates to:
  /// **'Topics'**
  String get quizTopicsTitle;

  /// No description provided for @quizOptionNumber.
  ///
  /// In en, this message translates to:
  /// **'Option {number}'**
  String quizOptionNumber(String number);

  /// No description provided for @quizOptionNumberCorrect.
  ///
  /// In en, this message translates to:
  /// **'Option {number}, correct answer'**
  String quizOptionNumberCorrect(String number);

  /// No description provided for @quizExplanationTitle.
  ///
  /// In en, this message translates to:
  /// **'Explanation'**
  String get quizExplanationTitle;

  /// No description provided for @quizRevisionNoticeTitle.
  ///
  /// In en, this message translates to:
  /// **'About revision history'**
  String get quizRevisionNoticeTitle;

  /// No description provided for @quizRevisionSectionTarget.
  ///
  /// In en, this message translates to:
  /// **'{title}. Press OK to hear it'**
  String quizRevisionSectionTarget(String title);

  /// No description provided for @quizAccountChangedSignIn.
  ///
  /// In en, this message translates to:
  /// **'Account changed. Return and sign in again.'**
  String get quizAccountChangedSignIn;

  /// No description provided for @quizGoBack.
  ///
  /// In en, this message translates to:
  /// **'Go back'**
  String get quizGoBack;

  /// No description provided for @quizCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get quizCancel;

  /// No description provided for @quizCancelAndReturn.
  ///
  /// In en, this message translates to:
  /// **'Cancel and return'**
  String get quizCancelAndReturn;

  /// No description provided for @quizActionNavigation.
  ///
  /// In en, this message translates to:
  /// **'the available actions and cancel'**
  String get quizActionNavigation;

  /// No description provided for @quizRefreshRevisions.
  ///
  /// In en, this message translates to:
  /// **'Refresh revisions'**
  String get quizRefreshRevisions;

  /// No description provided for @quizNewerRevision.
  ///
  /// In en, this message translates to:
  /// **'Newer revision'**
  String get quizNewerRevision;

  /// No description provided for @quizOlderRevision.
  ///
  /// In en, this message translates to:
  /// **'Older revision'**
  String get quizOlderRevision;

  /// No description provided for @quizBankArchived.
  ///
  /// In en, this message translates to:
  /// **'Bank question archived'**
  String get quizBankArchived;

  /// No description provided for @quizBankCopied.
  ///
  /// In en, this message translates to:
  /// **'Bank question copy created'**
  String get quizBankCopied;

  /// No description provided for @quizSnapshotAdded.
  ///
  /// In en, this message translates to:
  /// **'Question snapshot added to quiz'**
  String get quizSnapshotAdded;

  /// No description provided for @quizQuizClosed.
  ///
  /// In en, this message translates to:
  /// **'Quiz closed'**
  String get quizQuizClosed;

  /// No description provided for @quizDraftCreated.
  ///
  /// In en, this message translates to:
  /// **'Editable quiz draft created'**
  String get quizDraftCreated;

  /// No description provided for @quizNoAnswerSelected.
  ///
  /// In en, this message translates to:
  /// **'No answer selected.'**
  String get quizNoAnswerSelected;

  /// No description provided for @quizSelectBeforeSubmit.
  ///
  /// In en, this message translates to:
  /// **'Select one option before submitting.'**
  String get quizSelectBeforeSubmit;

  /// No description provided for @quizSubmitBeforeContinuing.
  ///
  /// In en, this message translates to:
  /// **'Submit your answer before continuing.'**
  String get quizSubmitBeforeContinuing;

  /// No description provided for @quizTeacherNavigationPrivate.
  ///
  /// In en, this message translates to:
  /// **'private bank search and saved questions, quiz drafts, published quizzes, and their results'**
  String get quizTeacherNavigationPrivate;

  /// No description provided for @quizStudentNavigationHelp.
  ///
  /// In en, this message translates to:
  /// **'Use D-pad up and down to reach refresh, quiz state filter, subject filter, each available quiz or practice activity, and its attempt history. Use left or right on a filter to change it. Press OK on a quiz to hear its details and confirm starting or resuming; press OK on attempt history to review past attempts. Moving focus never starts an attempt.'**
  String get quizStudentNavigationHelp;

  /// No description provided for @quizNoQuizzesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No quizzes available.'**
  String get quizNoQuizzesAvailable;

  /// No description provided for @quizQuizzesAvailableRaw.
  ///
  /// In en, this message translates to:
  /// **'{count} quizzes available.'**
  String quizQuizzesAvailableRaw(String count);

  /// No description provided for @quizStudentNavigationSections.
  ///
  /// In en, this message translates to:
  /// **'refresh, quiz state and subject filters, available quizzes and practice activities, and previous attempts'**
  String get quizStudentNavigationSections;

  /// No description provided for @quizAttemptLimitReached.
  ///
  /// In en, this message translates to:
  /// **'Attempt limit reached for {title}. Open attempt history to review your scores.'**
  String quizAttemptLimitReached(String title);

  /// No description provided for @quizNoPerAttemptLimit.
  ///
  /// In en, this message translates to:
  /// **'No per-attempt time limit.'**
  String get quizNoPerAttemptLimit;

  /// No description provided for @quizTimeLimitRaw.
  ///
  /// In en, this message translates to:
  /// **'Time limit {minutes} minutes.'**
  String quizTimeLimitRaw(String minutes);

  /// No description provided for @quizCannotGoBack.
  ///
  /// In en, this message translates to:
  /// **'You cannot go back to change it.'**
  String get quizCannotGoBack;

  /// No description provided for @quizStartFailedAvailability.
  ///
  /// In en, this message translates to:
  /// **'The quiz could not be started. Check its availability.'**
  String get quizStartFailedAvailability;

  /// No description provided for @quizStateFieldName.
  ///
  /// In en, this message translates to:
  /// **'Quiz state'**
  String get quizStateFieldName;

  /// No description provided for @quizSubjectFieldName.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get quizSubjectFieldName;

  /// item is a description of a filter and its value.
  ///
  /// In en, this message translates to:
  /// **'{item}. Use left or right to change'**
  String quizUseLeftRightToChange(String item);

  /// No description provided for @quizAttemptCompletePrivate.
  ///
  /// In en, this message translates to:
  /// **'Attempt complete. Your result remains private.'**
  String get quizAttemptCompletePrivate;

  /// No description provided for @quizHelpCompleted.
  ///
  /// In en, this message translates to:
  /// **'Use D-pad up and down to move between return to quizzes and read result privately. Press OK to activate a button. Press 8 to read your result privately or 0 to return.'**
  String get quizHelpCompleted;

  /// No description provided for @quizHelpRetry.
  ///
  /// In en, this message translates to:
  /// **'Press 5 to retry finishing, 8 to hear where you are, or 0 to leave with confirmation. Use D-pad up and down for the other controls.'**
  String get quizHelpRetry;

  /// No description provided for @quizHelpNext.
  ///
  /// In en, this message translates to:
  /// **'The next question follows automatically. Press 6 to repeat, 8 to hear where you are.'**
  String get quizHelpNext;

  /// No description provided for @quizHelpChoose.
  ///
  /// In en, this message translates to:
  /// **'Press 1 to {count} to choose, then 5 to submit. Press 6 to repeat the question and options, 8 to hear where you are and the time left.'**
  String quizHelpChoose(String count);

  /// No description provided for @quizHelpFinishLeave.
  ///
  /// In en, this message translates to:
  /// **'Finish quiz now is in the D-pad list and asks to confirm. Press 0 to leave without submitting.'**
  String get quizHelpFinishLeave;

  /// No description provided for @quizSelectedOptionNotSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Selected option {number}. {text}. Not submitted yet.'**
  String quizSelectedOptionNotSubmitted(String number, String text);

  /// No description provided for @quizSelectedOptionConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Selected option {number}. {text}. Answer confirmed.'**
  String quizSelectedOptionConfirmed(String number, String text);

  /// No description provided for @quizFeedbackCorrect.
  ///
  /// In en, this message translates to:
  /// **'Correct. Correct answer: {answer}. {explanation}'**
  String quizFeedbackCorrect(String answer, String explanation);

  /// No description provided for @quizFeedbackIncorrect.
  ///
  /// In en, this message translates to:
  /// **'Incorrect. Correct answer: {answer}. {explanation}'**
  String quizFeedbackIncorrect(String answer, String explanation);

  /// No description provided for @quizOptionSelectedNotSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Option {number}. {text}. Selected, not submitted. Press 5 to save your answer.'**
  String quizOptionSelectedNotSubmitted(String number, String text);

  /// No description provided for @quizAttemptFinishedWhere.
  ///
  /// In en, this message translates to:
  /// **'Attempt finished. Press 8 to hear your result privately.'**
  String get quizAttemptFinishedWhere;

  /// No description provided for @quizNoOptionChosenYet.
  ///
  /// In en, this message translates to:
  /// **'No option chosen yet.'**
  String get quizNoOptionChosenYet;

  /// No description provided for @quizOptionChosen.
  ///
  /// In en, this message translates to:
  /// **'Option {number} chosen.'**
  String quizOptionChosen(String number);

  /// No description provided for @quizCompletionFailedRetry.
  ///
  /// In en, this message translates to:
  /// **'{reason} Your saved answers are preserved. Select Retry completion to check the result.'**
  String quizCompletionFailedRetry(String reason);

  /// status is the attempt status code from the server, such as completed.
  ///
  /// In en, this message translates to:
  /// **'Attempt {status}. Your result is private.'**
  String quizAttemptStatusPrivate(String status);

  /// No description provided for @quizEarlyCountUnconfirmed.
  ///
  /// In en, this message translates to:
  /// **'The current saved-answer count could not be confirmed, or this attempt has ended. No early submission was sent. Return to the quiz list to refresh its status.'**
  String get quizEarlyCountUnconfirmed;

  /// No description provided for @quizEarlyTitle.
  ///
  /// In en, this message translates to:
  /// **'Submit this attempt early?'**
  String get quizEarlyTitle;

  /// No description provided for @quizEarlyMessage.
  ///
  /// In en, this message translates to:
  /// **'The server check confirms {count} unanswered questions. Only answers saved on the server when finalized are included. A selected but unsaved answer is not included. Final submission cannot be undone or edited. Back never submits.'**
  String quizEarlyMessage(String count);

  /// No description provided for @quizEarlyConfirm.
  ///
  /// In en, this message translates to:
  /// **'Finalize saved answers'**
  String get quizEarlyConfirm;

  /// No description provided for @quizEarlyTimedOut.
  ///
  /// In en, this message translates to:
  /// **'Checking saved answers timed out. No early submission was sent. Check your connection and retry.'**
  String get quizEarlyTimedOut;

  /// No description provided for @quizWaitPending.
  ///
  /// In en, this message translates to:
  /// **'Wait for the pending answer or completion confirmation before leaving.'**
  String get quizWaitPending;

  /// No description provided for @quizLeaveMessageServer.
  ///
  /// In en, this message translates to:
  /// **'This does not submit your attempt. Only server-confirmed answers are saved; an unsaved selection may be lost. Any timer keeps running. Resume is allowed only while the server permits this attempt.'**
  String get quizLeaveMessageServer;

  /// No description provided for @quizStayInAttempt.
  ///
  /// In en, this message translates to:
  /// **'Stay in attempt'**
  String get quizStayInAttempt;

  /// No description provided for @quizNextQuestionNow.
  ///
  /// In en, this message translates to:
  /// **'Next question now'**
  String get quizNextQuestionNow;

  /// No description provided for @quizReadAllOptions.
  ///
  /// In en, this message translates to:
  /// **'Read all answer options'**
  String get quizReadAllOptions;

  /// No description provided for @quizOptionTargetSelectedSubmit.
  ///
  /// In en, this message translates to:
  /// **'Option {number}, {text}, selected. Press OK or {number} to select. Press 5 to submit only when ready'**
  String quizOptionTargetSelectedSubmit(String number, String text);

  /// No description provided for @quizOptionTargetNotSelectedSubmit.
  ///
  /// In en, this message translates to:
  /// **'Option {number}, {text}, not selected. Press OK or {number} to select. Press 5 to submit only when ready'**
  String quizOptionTargetNotSelectedSubmit(String number, String text);

  /// No description provided for @quizReadSelectionTarget.
  ///
  /// In en, this message translates to:
  /// **'Read selected answer and saved status'**
  String get quizReadSelectionTarget;

  /// No description provided for @quizStopSpeech.
  ///
  /// In en, this message translates to:
  /// **'Stop speech'**
  String get quizStopSpeech;

  /// No description provided for @quizAnswerFeedback.
  ///
  /// In en, this message translates to:
  /// **'Answer feedback'**
  String get quizAnswerFeedback;

  /// No description provided for @quizAnswerConfirmedReadFeedback.
  ///
  /// In en, this message translates to:
  /// **'Answer confirmed saved and locked. Press OK to read feedback privately.'**
  String get quizAnswerConfirmedReadFeedback;

  /// No description provided for @quizRetryCompletion.
  ///
  /// In en, this message translates to:
  /// **'Retry completion'**
  String get quizRetryCompletion;

  /// No description provided for @quizViewResult.
  ///
  /// In en, this message translates to:
  /// **'View result'**
  String get quizViewResult;

  /// No description provided for @quizNextQuestion.
  ///
  /// In en, this message translates to:
  /// **'Next question'**
  String get quizNextQuestion;

  /// No description provided for @quizAttemptInProgressResume.
  ///
  /// In en, this message translates to:
  /// **'Attempt in progress. Return to the quiz list to resume it. Leaving does not submit.'**
  String get quizAttemptInProgressResume;

  /// No description provided for @quizReviewTimedOutShort.
  ///
  /// In en, this message translates to:
  /// **'Attempt review timed out. Check your connection and try again.'**
  String get quizReviewTimedOutShort;

  /// No description provided for @quizNoScoreCurrentlyReleased.
  ///
  /// In en, this message translates to:
  /// **'Completed attempts exist; no score is currently released.'**
  String get quizNoScoreCurrentlyReleased;

  /// No description provided for @quizHistoryScreenNavigate.
  ///
  /// In en, this message translates to:
  /// **'Attempt history. Scores are private. Navigate to the summary or an attempt to review.'**
  String get quizHistoryScreenNavigate;

  /// status is the attempt status code from the server.
  ///
  /// In en, this message translates to:
  /// **'Attempt {number}. {status}. {result}. Press OK to review.'**
  String quizHistoryAttemptRaw(String number, String status, String result);

  /// No description provided for @quizReviewAnswerCorrect.
  ///
  /// In en, this message translates to:
  /// **'Question {number}. Correct. {question}. Selected {selected}. Correct answer {answer}. {explanation}'**
  String quizReviewAnswerCorrect(
    String number,
    String question,
    String selected,
    String answer,
    String explanation,
  );

  /// No description provided for @quizReviewAnswerIncorrect.
  ///
  /// In en, this message translates to:
  /// **'Question {number}. Incorrect. {question}. Selected {selected}. Correct answer {answer}. {explanation}'**
  String quizReviewAnswerIncorrect(
    String number,
    String question,
    String selected,
    String answer,
    String explanation,
  );

  /// No description provided for @quizNoAnswerCapital.
  ///
  /// In en, this message translates to:
  /// **'No answer'**
  String get quizNoAnswerCapital;

  /// No description provided for @quizReviewScreenRaw.
  ///
  /// In en, this message translates to:
  /// **'Attempt review. {count} questions. Use up and down to review each answer.'**
  String quizReviewScreenRaw(String count);

  /// No description provided for @quizMetaTopics.
  ///
  /// In en, this message translates to:
  /// **'Topics or concepts, one per line (optional)'**
  String get quizMetaTopics;

  /// No description provided for @quizMetaSpokenQuestion.
  ///
  /// In en, this message translates to:
  /// **'Teacher-written spoken question'**
  String get quizMetaSpokenQuestion;

  /// No description provided for @quizMetaSpokenOption.
  ///
  /// In en, this message translates to:
  /// **'Spoken option {number}'**
  String quizMetaSpokenOption(String number);

  /// No description provided for @quizMetaSpokenExplanation.
  ///
  /// In en, this message translates to:
  /// **'Teacher-written spoken explanation'**
  String get quizMetaSpokenExplanation;

  /// No description provided for @quizCorrectSelected.
  ///
  /// In en, this message translates to:
  /// **'Option {number} selected as correct answer'**
  String quizCorrectSelected(String number);

  /// No description provided for @quizCorrectSelectedWithText.
  ///
  /// In en, this message translates to:
  /// **'Option {number} selected as correct answer, {text}'**
  String quizCorrectSelectedWithText(String number, String text);

  /// No description provided for @quizEditBankQuestion.
  ///
  /// In en, this message translates to:
  /// **'Edit bank question'**
  String get quizEditBankQuestion;

  /// No description provided for @quizCreateBankQuestion.
  ///
  /// In en, this message translates to:
  /// **'Create bank question'**
  String get quizCreateBankQuestion;

  /// No description provided for @quizEditorNavigation.
  ///
  /// In en, this message translates to:
  /// **'question text, four answer fields, correct-answer selection, optional spoken descriptions, and save or cancel'**
  String get quizEditorNavigation;

  /// No description provided for @quizSaveQuestion.
  ///
  /// In en, this message translates to:
  /// **'Save question'**
  String get quizSaveQuestion;

  /// No description provided for @quizCancelQuestion.
  ///
  /// In en, this message translates to:
  /// **'Cancel question'**
  String get quizCancelQuestion;

  /// item is the name of a text field.
  ///
  /// In en, this message translates to:
  /// **'{item}. Press OK to edit'**
  String quizPressOkToEdit(String item);

  /// item is a setting and its value.
  ///
  /// In en, this message translates to:
  /// **'{item}. Press OK to change'**
  String quizPressOkToChange(String item);

  /// No description provided for @quizCorrectIsOption.
  ///
  /// In en, this message translates to:
  /// **'Option {number}, {text}, is the correct answer. Use left or right to change'**
  String quizCorrectIsOption(String number, String text);

  /// No description provided for @quizHideOptionalExplanation.
  ///
  /// In en, this message translates to:
  /// **'Hide optional explanation, topics and spoken notation'**
  String get quizHideOptionalExplanation;

  /// No description provided for @quizShowOptionalExplanation.
  ///
  /// In en, this message translates to:
  /// **'Show optional explanation, topics and spoken notation'**
  String get quizShowOptionalExplanation;

  /// No description provided for @quizOptionalExplanation.
  ///
  /// In en, this message translates to:
  /// **'Optional answer explanation'**
  String get quizOptionalExplanation;

  /// Numeric date and time, for example 12/11/2026 at 10:05.
  ///
  /// In en, this message translates to:
  /// **'{day}/{month}/{year} at {hour}:{minute}'**
  String quizNumericDateTime(
    String day,
    String month,
    String year,
    String hour,
    String minute,
  );

  /// No description provided for @quizCheckTitleLimits.
  ///
  /// In en, this message translates to:
  /// **'Check the title, limits, and schedule.'**
  String get quizCheckTitleLimits;

  /// No description provided for @quizSettingsNavigation.
  ///
  /// In en, this message translates to:
  /// **'title, optional description, timing and attempt settings, feedback and shuffle choices, and continue or cancel'**
  String get quizSettingsNavigation;

  /// No description provided for @quizChangeSettingsScreen.
  ///
  /// In en, this message translates to:
  /// **'Change quiz title and optional settings. Saving does not publish.'**
  String get quizChangeSettingsScreen;

  /// No description provided for @quizCreatePracticeScreen.
  ///
  /// In en, this message translates to:
  /// **'Create untimed ungraded practice. Unlimited retries and immediate feedback.'**
  String get quizCreatePracticeScreen;

  /// No description provided for @quizContinueToQuestions.
  ///
  /// In en, this message translates to:
  /// **'Continue to questions'**
  String get quizContinueToQuestions;

  /// No description provided for @quizSaveSettingsReturn.
  ///
  /// In en, this message translates to:
  /// **'Save settings and return to review'**
  String get quizSaveSettingsReturn;

  /// No description provided for @quizQuizTitle.
  ///
  /// In en, this message translates to:
  /// **'Quiz title'**
  String get quizQuizTitle;

  /// No description provided for @quizHideOptionalSettings.
  ///
  /// In en, this message translates to:
  /// **'Hide optional settings: description, attempts, timing, feedback and shuffle'**
  String get quizHideOptionalSettings;

  /// No description provided for @quizShowOptionalSettings.
  ///
  /// In en, this message translates to:
  /// **'Show optional settings: description, attempts, timing, feedback and shuffle'**
  String get quizShowOptionalSettings;

  /// No description provided for @quizOptionalDescription.
  ///
  /// In en, this message translates to:
  /// **'Optional quiz description'**
  String get quizOptionalDescription;

  /// item is a date and time or "No opening time set".
  ///
  /// In en, this message translates to:
  /// **'{item}. Press OK to set it. Use left to clear it'**
  String quizSetOrClear(String item);

  /// No description provided for @quizShuffleQuestionsToggle.
  ///
  /// In en, this message translates to:
  /// **'Shuffle questions {state}. Press OK or left or right to toggle'**
  String quizShuffleQuestionsToggle(String state);

  /// No description provided for @quizShuffleOptionsToggle.
  ///
  /// In en, this message translates to:
  /// **'Shuffle answer options {state}. Press OK or left or right to toggle'**
  String quizShuffleOptionsToggle(String state);

  /// No description provided for @quizCancelQuizCreation.
  ///
  /// In en, this message translates to:
  /// **'Cancel quiz creation'**
  String get quizCancelQuizCreation;

  /// policy is the internal feedback policy code, such as after_completion.
  ///
  /// In en, this message translates to:
  /// **'Feedback policy {policy}. Left or right changes it'**
  String quizFeedbackPolicyTarget(String policy);

  /// No description provided for @quizSaveDraftContinue.
  ///
  /// In en, this message translates to:
  /// **'Save draft and continue to questions'**
  String get quizSaveDraftContinue;

  /// Screen name prefix, followed by the class title.
  ///
  /// In en, this message translates to:
  /// **'Teacher class'**
  String get sessionScreenTeacherClass;

  /// Screen name prefix, followed by the class title.
  ///
  /// In en, this message translates to:
  /// **'Class'**
  String get sessionScreenClass;

  /// Title used when a class has no title.
  ///
  /// In en, this message translates to:
  /// **'Session'**
  String get sessionDefaultTitle;

  /// No description provided for @sessionJoining.
  ///
  /// In en, this message translates to:
  /// **'Joining the class. Please wait.'**
  String get sessionJoining;

  /// No description provided for @sessionConnecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting to the class.'**
  String get sessionConnecting;

  /// No description provided for @sessionJoinFailed.
  ///
  /// In en, this message translates to:
  /// **'The class could not be joined. Press 0 to leave, then try again.'**
  String get sessionJoinFailed;

  /// No description provided for @sessionLeaveKeyHint.
  ///
  /// In en, this message translates to:
  /// **'Press 0 to leave the class. It asks to confirm.'**
  String get sessionLeaveKeyHint;

  /// No description provided for @sessionKeyLine.
  ///
  /// In en, this message translates to:
  /// **'*: Help and last message. #: Stop speech.'**
  String get sessionKeyLine;

  /// status: sentences describing microphone, hand and connection state.
  ///
  /// In en, this message translates to:
  /// **'In class. {status} Press star for help.'**
  String sessionJoinedBrief(String status);

  /// status: state sentences; keys: list of "Press N for X." sentences.
  ///
  /// In en, this message translates to:
  /// **'You are in the class. {status} {keys} Use up and down to move between controls and OK to select. Press star for where you are and help. Press hash to stop speech.'**
  String sessionJoinedDetailed(String status, String keys);

  /// No description provided for @sessionMicWaitingLabel.
  ///
  /// In en, this message translates to:
  /// **'Microphone waiting for confirmation'**
  String get sessionMicWaitingLabel;

  /// No description provided for @sessionUnmuteMicrophone.
  ///
  /// In en, this message translates to:
  /// **'Unmute microphone'**
  String get sessionUnmuteMicrophone;

  /// No description provided for @sessionMuteMicrophone.
  ///
  /// In en, this message translates to:
  /// **'Mute microphone'**
  String get sessionMuteMicrophone;

  /// Button text; 1 is the keypad key.
  ///
  /// In en, this message translates to:
  /// **'1: Waiting'**
  String get sessionMuteButtonWaiting;

  /// Button text; 1 is the keypad key.
  ///
  /// In en, this message translates to:
  /// **'1: Unmute'**
  String get sessionMuteButtonUnmute;

  /// Button text; 1 is the keypad key.
  ///
  /// In en, this message translates to:
  /// **'1: Mute'**
  String get sessionMuteButtonMute;

  /// No description provided for @sessionHandWaitingLabel.
  ///
  /// In en, this message translates to:
  /// **'Hand waiting for confirmation'**
  String get sessionHandWaitingLabel;

  /// No description provided for @sessionLowerHand.
  ///
  /// In en, this message translates to:
  /// **'Lower hand'**
  String get sessionLowerHand;

  /// No description provided for @sessionRaiseHand.
  ///
  /// In en, this message translates to:
  /// **'Raise hand'**
  String get sessionRaiseHand;

  /// Button text; 2 is the keypad key.
  ///
  /// In en, this message translates to:
  /// **'2: Waiting'**
  String get sessionHandButtonWaiting;

  /// Button text; 2 is the keypad key.
  ///
  /// In en, this message translates to:
  /// **'2: Lower hand'**
  String get sessionHandButtonLower;

  /// Button text; 2 is the keypad key.
  ///
  /// In en, this message translates to:
  /// **'2: Raise hand'**
  String get sessionHandButtonRaise;

  /// No description provided for @sessionStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Hear class status'**
  String get sessionStatusLabel;

  /// Button text; 3 is the keypad key.
  ///
  /// In en, this message translates to:
  /// **'3: Class status'**
  String get sessionStatusButton;

  /// No description provided for @sessionChatLabel.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Chat. No messages yet} =1{Chat. 1 message} other{Chat. {count} messages}}'**
  String sessionChatLabel(int count);

  /// Button text; 4 is the keypad key.
  ///
  /// In en, this message translates to:
  /// **'4: Chat'**
  String get sessionChatButton;

  /// No description provided for @sessionRecordingPlayerNone.
  ///
  /// In en, this message translates to:
  /// **'Lesson recording. None chosen yet'**
  String get sessionRecordingPlayerNone;

  /// title: recording title.
  ///
  /// In en, this message translates to:
  /// **'Lesson recording. {title}, playing'**
  String sessionRecordingPlayerPlaying(String title);

  /// title: recording title.
  ///
  /// In en, this message translates to:
  /// **'Lesson recording. {title}, paused'**
  String sessionRecordingPlayerPaused(String title);

  /// No description provided for @sessionRecordingStudentNone.
  ///
  /// In en, this message translates to:
  /// **'Class recording. Nothing playing. Only the teacher controls it'**
  String get sessionRecordingStudentNone;

  /// title: recording title.
  ///
  /// In en, this message translates to:
  /// **'Class recording, {title}, playing by the teacher. Hear where it is'**
  String sessionRecordingStudentPlaying(String title);

  /// title: recording title.
  ///
  /// In en, this message translates to:
  /// **'Class recording, {title}, paused by the teacher. Hear where it is'**
  String sessionRecordingStudentPaused(String title);

  /// Button text; 5 is the keypad key.
  ///
  /// In en, this message translates to:
  /// **'5: Recording status'**
  String get sessionRecordingStatusButton;

  /// No description provided for @sessionStudentRecordingNone.
  ///
  /// In en, this message translates to:
  /// **'No class recording is playing. Only the teacher can play one.'**
  String get sessionStudentRecordingNone;

  /// position: spoken position such as "1 minute of 5 minutes".
  ///
  /// In en, this message translates to:
  /// **'{title}, playing, at {position}. Only the teacher can play, pause or move the class recording.'**
  String sessionStudentRecordingPlaying(String title, String position);

  /// position: spoken position such as "1 minute of 5 minutes".
  ///
  /// In en, this message translates to:
  /// **'{title}, paused, at {position}. Only the teacher can play, pause or move the class recording.'**
  String sessionStudentRecordingPaused(String title, String position);

  /// Button text; 5 is the keypad key.
  ///
  /// In en, this message translates to:
  /// **'5: Lesson recording'**
  String get sessionRecordingPlayerButton;

  /// No description provided for @sessionOpeningPlayerToChoose.
  ///
  /// In en, this message translates to:
  /// **'No recording is selected yet. Press 1 to choose one.'**
  String get sessionOpeningPlayerToChoose;

  /// No description provided for @sessionCheckLabel.
  ///
  /// In en, this message translates to:
  /// **'Answer the teacher\'s question'**
  String get sessionCheckLabel;

  /// Button text; 6 is the keypad key.
  ///
  /// In en, this message translates to:
  /// **'3: Answer the question'**
  String get sessionCheckButton;

  /// waiting: sentence such as "2 hands waiting."
  ///
  /// In en, this message translates to:
  /// **'Raised hands. {waiting}'**
  String sessionHandsLabel(String waiting);

  /// Button text; 2 is the keypad key.
  ///
  /// In en, this message translates to:
  /// **'2: Raised hands'**
  String get sessionHandsButton;

  /// Button text; 2 is the keypad key, count is the number of raised hands.
  ///
  /// In en, this message translates to:
  /// **'2: Raised hands ({count})'**
  String sessionHandsButtonCount(int count);

  /// No description provided for @sessionTeacherCheckLabel.
  ///
  /// In en, this message translates to:
  /// **'Classroom check. Start a private check, close it and hear responses'**
  String get sessionTeacherCheckLabel;

  /// people: sentence such as "3 people in the class."
  ///
  /// In en, this message translates to:
  /// **'Participants. {people} Mute or remove someone, or hear a summary'**
  String sessionParticipantsLabel(String people);

  /// Button text; 7 is the keypad key.
  ///
  /// In en, this message translates to:
  /// **'7: Participants'**
  String get sessionParticipantsButton;

  /// No description provided for @sessionToolsLabel.
  ///
  /// In en, this message translates to:
  /// **'Teacher tools. Add time or end the class for everyone'**
  String get sessionToolsLabel;

  /// Button text; 9 is the keypad key.
  ///
  /// In en, this message translates to:
  /// **'9: Teacher tools'**
  String get sessionToolsButton;

  /// No description provided for @sessionVoiceStartLabel.
  ///
  /// In en, this message translates to:
  /// **'Listen for one voice command, up to 12 seconds. Starts only when you press OK'**
  String get sessionVoiceStartLabel;

  /// No description provided for @sessionVoiceStopLabel.
  ///
  /// In en, this message translates to:
  /// **'Stop listening for a voice command'**
  String get sessionVoiceStopLabel;

  /// No description provided for @sessionVoiceStartButton.
  ///
  /// In en, this message translates to:
  /// **'Listen for command'**
  String get sessionVoiceStartButton;

  /// No description provided for @sessionVoiceStopButton.
  ///
  /// In en, this message translates to:
  /// **'Stop listening'**
  String get sessionVoiceStopButton;

  /// No description provided for @sessionUpdatesLabel.
  ///
  /// In en, this message translates to:
  /// **'Read class updates'**
  String get sessionUpdatesLabel;

  /// No description provided for @sessionUpdatesButton.
  ///
  /// In en, this message translates to:
  /// **'Class updates'**
  String get sessionUpdatesButton;

  /// No description provided for @sessionRetryLabel.
  ///
  /// In en, this message translates to:
  /// **'Retry class connection'**
  String get sessionRetryLabel;

  /// No description provided for @sessionRetryButton.
  ///
  /// In en, this message translates to:
  /// **'Retry connection'**
  String get sessionRetryButton;

  /// No description provided for @sessionLeaveLabel.
  ///
  /// In en, this message translates to:
  /// **'Leave class'**
  String get sessionLeaveLabel;

  /// Button text; 0 is the keypad key.
  ///
  /// In en, this message translates to:
  /// **'0: Leave class'**
  String get sessionLeaveButton;

  /// No description provided for @sessionMicWaiting.
  ///
  /// In en, this message translates to:
  /// **'Microphone waiting for confirmation.'**
  String get sessionMicWaiting;

  /// No description provided for @sessionMicMuted.
  ///
  /// In en, this message translates to:
  /// **'Muted.'**
  String get sessionMicMuted;

  /// No description provided for @sessionMicUnmutedHeard.
  ///
  /// In en, this message translates to:
  /// **'Unmuted. Others can hear you.'**
  String get sessionMicUnmutedHeard;

  /// No description provided for @sessionHandWaiting.
  ///
  /// In en, this message translates to:
  /// **'Hand waiting for confirmation.'**
  String get sessionHandWaiting;

  /// No description provided for @sessionHandRaisedState.
  ///
  /// In en, this message translates to:
  /// **'Hand raised.'**
  String get sessionHandRaisedState;

  /// No description provided for @sessionHandDown.
  ///
  /// In en, this message translates to:
  /// **'Hand down.'**
  String get sessionHandDown;

  /// No description provided for @sessionHandsWaiting.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No hands waiting.} =1{1 hand waiting.} other{{count} hands waiting.}}'**
  String sessionHandsWaiting(int count);

  /// No description provided for @sessionPeople.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 person in the class.} other{{count} people in the class.}}'**
  String sessionPeople(int count);

  /// No description provided for @sessionNoRecordingSelected.
  ///
  /// In en, this message translates to:
  /// **'No recording selected.'**
  String get sessionNoRecordingSelected;

  /// No description provided for @sessionRecordingStatePlaying.
  ///
  /// In en, this message translates to:
  /// **'Recording playing: {title}.'**
  String sessionRecordingStatePlaying(String title);

  /// No description provided for @sessionRecordingStatePaused.
  ///
  /// In en, this message translates to:
  /// **'Recording paused: {title}.'**
  String sessionRecordingStatePaused(String title);

  /// No description provided for @sessionCheckOpen.
  ///
  /// In en, this message translates to:
  /// **'Classroom check open.'**
  String get sessionCheckOpen;

  /// label: connection state such as "Connected".
  ///
  /// In en, this message translates to:
  /// **'{label}.'**
  String sessionConnectionLabel(String label);

  /// No description provided for @sessionChatMessages.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 chat message.} other{{count} chat messages.}}'**
  String sessionChatMessages(int count);

  /// Name used for a recording without a title.
  ///
  /// In en, this message translates to:
  /// **'Class recording'**
  String get sessionRecordingFallback;

  /// Name used for a recording without a title, inside a sentence.
  ///
  /// In en, this message translates to:
  /// **'class recording'**
  String get sessionRecordingFallbackLower;

  /// Name used for a participant without a name; id is a number.
  ///
  /// In en, this message translates to:
  /// **'User {id}'**
  String sessionUserFallback(String id);

  /// message: connection status sentence.
  ///
  /// In en, this message translates to:
  /// **'Connection restored. {message}'**
  String sessionConnectionRestored(String message);

  /// message: connection status sentence.
  ///
  /// In en, this message translates to:
  /// **'Connection lost. {message}'**
  String sessionConnectionLost(String message);

  /// message: connection status sentence.
  ///
  /// In en, this message translates to:
  /// **'Could not connect. {message}'**
  String sessionCouldNotConnect(String message);

  /// No description provided for @sessionMicDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Microphone access'**
  String get sessionMicDialogTitle;

  /// No description provided for @sessionMicDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'In this class SEEDS uses the microphone for live audio and explicitly activated voice commands. You can stay without microphone access, but others will not hear you. Separate private-note recording requires its own explicit start outside live classes.'**
  String get sessionMicDialogMessage;

  /// No description provided for @sessionMicDialogConfirm.
  ///
  /// In en, this message translates to:
  /// **'Continue to class'**
  String get sessionMicDialogConfirm;

  /// No description provided for @sessionMicSkipped.
  ///
  /// In en, this message translates to:
  /// **'Microphone access was skipped. You joined the class muted.'**
  String get sessionMicSkipped;

  /// No description provided for @sessionMicUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Microphone access is unavailable. You joined the class muted.'**
  String get sessionMicUnavailable;

  /// No description provided for @sessionWaitingMic.
  ///
  /// In en, this message translates to:
  /// **'Waiting for microphone confirmation.'**
  String get sessionWaitingMic;

  /// No description provided for @sessionMuted.
  ///
  /// In en, this message translates to:
  /// **'Muted'**
  String get sessionMuted;

  /// No description provided for @sessionUnmuted.
  ///
  /// In en, this message translates to:
  /// **'Unmuted'**
  String get sessionUnmuted;

  /// No description provided for @sessionMutedLocallyOnly.
  ///
  /// In en, this message translates to:
  /// **'Microphone muted on this phone. The class confirmation was not received.'**
  String get sessionMutedLocallyOnly;

  /// No description provided for @sessionMutedByTeacher.
  ///
  /// In en, this message translates to:
  /// **'The teacher muted your microphone.'**
  String get sessionMutedByTeacher;

  /// No description provided for @sessionMicClassClosed.
  ///
  /// In en, this message translates to:
  /// **'The class has closed. No microphone action was sent.'**
  String get sessionMicClassClosed;

  /// No description provided for @sessionMicUnavailableRejoin.
  ///
  /// In en, this message translates to:
  /// **'Microphone access is unavailable. Check microphone permission and rejoin the class before trying to speak.'**
  String get sessionMicUnavailableRejoin;

  /// No description provided for @sessionMicClosedBeforeConfirm.
  ///
  /// In en, this message translates to:
  /// **'The class closed before microphone confirmation.'**
  String get sessionMicClosedBeforeConfirm;

  /// No description provided for @sessionMicNoLongerAvailable.
  ///
  /// In en, this message translates to:
  /// **'Microphone access is no longer available. Rejoin the class before trying to speak.'**
  String get sessionMicNoLongerAvailable;

  /// No description provided for @sessionMicStayedMuted.
  ///
  /// In en, this message translates to:
  /// **'Your microphone stayed muted because the class mute state changed. Select Unmute when you are ready to speak.'**
  String get sessionMicStayedMuted;

  /// No description provided for @sessionWaitingHand.
  ///
  /// In en, this message translates to:
  /// **'Waiting for hand status confirmation.'**
  String get sessionWaitingHand;

  /// No description provided for @sessionHandRaised.
  ///
  /// In en, this message translates to:
  /// **'Hand raised'**
  String get sessionHandRaised;

  /// No description provided for @sessionHandLowered.
  ///
  /// In en, this message translates to:
  /// **'Hand lowered'**
  String get sessionHandLowered;

  /// No description provided for @sessionHandNotConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Your hand change was not confirmed. Press 2 to try again.'**
  String get sessionHandNotConfirmed;

  /// No description provided for @sessionRaisedHandBy.
  ///
  /// In en, this message translates to:
  /// **'{name} raised a hand.'**
  String sessionRaisedHandBy(String name);

  /// No description provided for @sessionRaisedHandUnknown.
  ///
  /// In en, this message translates to:
  /// **'A student raised a hand.'**
  String get sessionRaisedHandUnknown;

  /// No description provided for @sessionParticipantJoined.
  ///
  /// In en, this message translates to:
  /// **'A participant joined.'**
  String get sessionParticipantJoined;

  /// Name of a group of batched updates.
  ///
  /// In en, this message translates to:
  /// **'Participants joined'**
  String get sessionParticipantsJoinedGroup;

  /// No description provided for @sessionParticipantLeft.
  ///
  /// In en, this message translates to:
  /// **'A participant left.'**
  String get sessionParticipantLeft;

  /// Name of a group of batched updates.
  ///
  /// In en, this message translates to:
  /// **'Participants left'**
  String get sessionParticipantsLeftGroup;

  /// Name used for a participant without a name.
  ///
  /// In en, this message translates to:
  /// **'Participant'**
  String get sessionParticipantFallback;

  /// Name used for a participant without a name.
  ///
  /// In en, this message translates to:
  /// **'This participant'**
  String get sessionThisParticipant;

  /// Your own entry in the participant list.
  ///
  /// In en, this message translates to:
  /// **'{name}, you'**
  String sessionParticipantSelf(String name);

  /// Part of a comma separated participant summary.
  ///
  /// In en, this message translates to:
  /// **'teacher'**
  String get sessionRoleTeacher;

  /// Part of a comma separated participant summary.
  ///
  /// In en, this message translates to:
  /// **'student'**
  String get sessionRoleStudent;

  /// Part of a comma separated participant summary.
  ///
  /// In en, this message translates to:
  /// **'hand raised'**
  String get sessionStateHandRaised;

  /// Part of a comma separated participant summary.
  ///
  /// In en, this message translates to:
  /// **'muted'**
  String get sessionStateMuted;

  /// Part of a comma separated participant summary.
  ///
  /// In en, this message translates to:
  /// **'unmuted'**
  String get sessionStateUnmuted;

  /// Part of a comma separated participant summary.
  ///
  /// In en, this message translates to:
  /// **'speaking'**
  String get sessionStateSpeaking;

  /// No description provided for @sessionAlreadyMuted.
  ///
  /// In en, this message translates to:
  /// **'{name} is muted. Only {name} can unmute.'**
  String sessionAlreadyMuted(String name);

  /// No description provided for @sessionParticipantMuted.
  ///
  /// In en, this message translates to:
  /// **'{name} muted.'**
  String sessionParticipantMuted(String name);

  /// No description provided for @sessionRemoveTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove {name}?'**
  String sessionRemoveTitle(String name);

  /// No description provided for @sessionRemoveMessage.
  ///
  /// In en, this message translates to:
  /// **'{name} will be removed from this class and returned to their dashboard. They can be invited again later.'**
  String sessionRemoveMessage(String name);

  /// Button label.
  ///
  /// In en, this message translates to:
  /// **'Keep {name}'**
  String sessionKeep(String name);

  /// Button label.
  ///
  /// In en, this message translates to:
  /// **'Remove {name}'**
  String sessionRemove(String name);

  /// No description provided for @sessionRemoved.
  ///
  /// In en, this message translates to:
  /// **'{name} removed from the class.'**
  String sessionRemoved(String name);

  /// No description provided for @chatMessageFrom.
  ///
  /// In en, this message translates to:
  /// **'Message from {sender}: {text}'**
  String chatMessageFrom(String sender, String text);

  /// Sender name when unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get chatSenderUnknown;

  /// Sender name when unknown.
  ///
  /// In en, this message translates to:
  /// **'unknown'**
  String get chatSenderUnknownLower;

  /// No description provided for @chatWaitingConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Waiting for message confirmation.'**
  String get chatWaitingConfirmation;

  /// No description provided for @chatEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Enter a message before selecting Send.'**
  String get chatEmptyMessage;

  /// No description provided for @chatMessageSent.
  ///
  /// In en, this message translates to:
  /// **'Message sent.'**
  String get chatMessageSent;

  /// Delivery status of a chat message.
  ///
  /// In en, this message translates to:
  /// **'Sending'**
  String get chatSending;

  /// Delivery status of a chat message.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get chatSent;

  /// Delivery status of a chat message.
  ///
  /// In en, this message translates to:
  /// **'Not confirmed'**
  String get chatNotConfirmed;

  /// No description provided for @chatNoMessages.
  ///
  /// In en, this message translates to:
  /// **'No messages yet.'**
  String get chatNoMessages;

  /// No description provided for @chatTitle.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chatTitle;

  /// No description provided for @chatReadMessages.
  ///
  /// In en, this message translates to:
  /// **'Read messages, newest first'**
  String get chatReadMessages;

  /// No description provided for @chatWriteMessage.
  ///
  /// In en, this message translates to:
  /// **'Write a message'**
  String get chatWriteMessage;

  /// No description provided for @chatMessageField.
  ///
  /// In en, this message translates to:
  /// **'Your message to the class'**
  String get chatMessageField;

  /// No description provided for @chatMessagesTitle.
  ///
  /// In en, this message translates to:
  /// **'Chat messages'**
  String get chatMessagesTitle;

  /// Quick phrase sent as a chat message.
  ///
  /// In en, this message translates to:
  /// **'I understood'**
  String get chatPhraseUnderstood;

  /// Quick phrase sent as a chat message.
  ///
  /// In en, this message translates to:
  /// **'Please repeat'**
  String get chatPhraseRepeat;

  /// Quick phrase sent as a chat message.
  ///
  /// In en, this message translates to:
  /// **'I have a question'**
  String get chatPhraseQuestion;

  /// No description provided for @chatSendPhrase.
  ///
  /// In en, this message translates to:
  /// **'Send: {phrase}'**
  String chatSendPhrase(String phrase);

  /// No description provided for @chatCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 message.} other{{count} messages.}}'**
  String chatCount(int count);

  /// No description provided for @chatHelpBrief.
  ///
  /// In en, this message translates to:
  /// **'Read, write or send a quick phrase.'**
  String get chatHelpBrief;

  /// No description provided for @chatHelpDetailed.
  ///
  /// In en, this message translates to:
  /// **'Press 1 to read messages, 2 to write one, or 3 to 5 to send a quick phrase. Press 8 to hear the newest message.'**
  String get chatHelpDetailed;

  /// Sender name for your own messages.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get chatYou;

  /// No description provided for @chatMessageLine.
  ///
  /// In en, this message translates to:
  /// **'{sender}: {text}'**
  String chatMessageLine(String sender, String text);

  /// delivery: delivery status such as "Sent".
  ///
  /// In en, this message translates to:
  /// **'{sender}: {text}. {delivery}'**
  String chatMessageLineDelivery(String sender, String text, String delivery);

  /// line: "sender: text" of a chat message.
  ///
  /// In en, this message translates to:
  /// **'{line}.'**
  String chatMessageDetail(String line);

  /// line: "sender: text" of a chat message; time: spoken time of day.
  ///
  /// In en, this message translates to:
  /// **'{line}. Sent {time}.'**
  String chatMessageDetailSent(String line, String time);

  /// No description provided for @chatNewestMessage.
  ///
  /// In en, this message translates to:
  /// **'Newest message. {detail}'**
  String chatNewestMessage(String detail);

  /// No description provided for @chatReadLatest.
  ///
  /// In en, this message translates to:
  /// **'Read latest message'**
  String get chatReadLatest;

  /// No description provided for @chatMessageLabel.
  ///
  /// In en, this message translates to:
  /// **'Chat message'**
  String get chatMessageLabel;

  /// No description provided for @chatSendMessage.
  ///
  /// In en, this message translates to:
  /// **'Send message'**
  String get chatSendMessage;

  /// No description provided for @chatSaid.
  ///
  /// In en, this message translates to:
  /// **'{sender} said: {text}'**
  String chatSaid(String sender, String text);

  /// delivery: delivery status such as "Sent".
  ///
  /// In en, this message translates to:
  /// **'{sender} said: {text}. {delivery}'**
  String chatSaidDelivery(String sender, String text, String delivery);

  /// delivery: delivery status such as "Sent".
  ///
  /// In en, this message translates to:
  /// **'{sender}: {text}\nDelivery status: {delivery}.'**
  String chatLatestLineDelivery(String sender, String text, String delivery);

  /// No description provided for @sessionLeaveTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave class?'**
  String get sessionLeaveTitle;

  /// No description provided for @sessionLeaveMessage.
  ///
  /// In en, this message translates to:
  /// **'You will leave this class and return to your dashboard. You will remain logged in.'**
  String get sessionLeaveMessage;

  /// No description provided for @sessionTeacherLeaveMessage.
  ///
  /// In en, this message translates to:
  /// **'You will leave and return to your dashboard. The class keeps running for students. To end it for everyone, use 9, Teacher tools.'**
  String get sessionTeacherLeaveMessage;

  /// No description provided for @sessionStay.
  ///
  /// In en, this message translates to:
  /// **'Stay in class'**
  String get sessionStay;

  /// No description provided for @sessionLeave.
  ///
  /// In en, this message translates to:
  /// **'Leave class'**
  String get sessionLeave;

  /// No description provided for @sessionLeaveLocallyTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave without server confirmation?'**
  String get sessionLeaveLocallyTitle;

  /// No description provided for @sessionLeaveLocallyMessage.
  ///
  /// In en, this message translates to:
  /// **'This phone is muted. The server did not confirm clearing your raised hand. Leave locally now, or stay and retry? A fresh join resets your hand.'**
  String get sessionLeaveLocallyMessage;

  /// No description provided for @sessionStayAndRetry.
  ///
  /// In en, this message translates to:
  /// **'Stay and retry'**
  String get sessionStayAndRetry;

  /// No description provided for @sessionLeaveLocally.
  ///
  /// In en, this message translates to:
  /// **'Leave locally'**
  String get sessionLeaveLocally;

  /// No description provided for @sessionEndTitle.
  ///
  /// In en, this message translates to:
  /// **'End class for everyone?'**
  String get sessionEndTitle;

  /// No description provided for @sessionEndMessage.
  ///
  /// In en, this message translates to:
  /// **'This stops the class for every participant and returns everyone to their dashboard. Nobody will be logged out.'**
  String get sessionEndMessage;

  /// No description provided for @sessionEndCancel.
  ///
  /// In en, this message translates to:
  /// **'Keep the class going'**
  String get sessionEndCancel;

  /// No description provided for @sessionEndConfirm.
  ///
  /// In en, this message translates to:
  /// **'End for everyone'**
  String get sessionEndConfirm;

  /// No description provided for @sessionWaitingEnd.
  ///
  /// In en, this message translates to:
  /// **'Waiting for end-class confirmation.'**
  String get sessionWaitingEnd;

  /// No description provided for @sessionEndNotConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Ending the class was not confirmed. The class is still running.'**
  String get sessionEndNotConfirmed;

  /// No description provided for @sessionEndingForEveryone.
  ///
  /// In en, this message translates to:
  /// **'Ending the class for everyone.'**
  String get sessionEndingForEveryone;

  /// No description provided for @sessionYouLeft.
  ///
  /// In en, this message translates to:
  /// **'You left the class.'**
  String get sessionYouLeft;

  /// No description provided for @sessionClassEnded.
  ///
  /// In en, this message translates to:
  /// **'The class has ended.'**
  String get sessionClassEnded;

  /// No description provided for @sessionYouWereRemoved.
  ///
  /// In en, this message translates to:
  /// **'You were removed from the class.'**
  String get sessionYouWereRemoved;

  /// No description provided for @sessionSignInChanged.
  ///
  /// In en, this message translates to:
  /// **'Your sign-in changed. Sign in again or contact your school administrator.'**
  String get sessionSignInChanged;

  /// No description provided for @sessionCleanupFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign-in ended. Native audio cleanup could not be confirmed. Close SEEDS if audio continues.'**
  String get sessionCleanupFailed;

  /// No description provided for @sessionCleanupTimedOut.
  ///
  /// In en, this message translates to:
  /// **'Sign-in ended. Audio cleanup timed out. Close SEEDS if audio continues.'**
  String get sessionCleanupTimedOut;

  /// No description provided for @sessionRequestFailed.
  ///
  /// In en, this message translates to:
  /// **'We could not complete that request. Please try again.'**
  String get sessionRequestFailed;

  /// No description provided for @sessionVoiceStopped.
  ///
  /// In en, this message translates to:
  /// **'Voice listening stopped.'**
  String get sessionVoiceStopped;

  /// No description provided for @sessionVoiceUnmuteTitle.
  ///
  /// In en, this message translates to:
  /// **'Unmute your microphone?'**
  String get sessionVoiceUnmuteTitle;

  /// No description provided for @sessionVoiceUnmuteMessage.
  ///
  /// In en, this message translates to:
  /// **'A voice command requested unmute. Confirm with a key or touch. Other class members will be able to hear you.'**
  String get sessionVoiceUnmuteMessage;

  /// Button label.
  ///
  /// In en, this message translates to:
  /// **'Unmute'**
  String get sessionVoiceUnmuteConfirm;

  /// Button label.
  ///
  /// In en, this message translates to:
  /// **'Stay muted'**
  String get sessionVoiceUnmuteCancel;

  /// No description provided for @sessionAlreadyUnmuted.
  ///
  /// In en, this message translates to:
  /// **'Already unmuted'**
  String get sessionAlreadyUnmuted;

  /// No description provided for @sessionAlreadyMutedSelf.
  ///
  /// In en, this message translates to:
  /// **'Already muted'**
  String get sessionAlreadyMutedSelf;

  /// No description provided for @sessionHandAlreadyLowered.
  ///
  /// In en, this message translates to:
  /// **'Hand is already lowered'**
  String get sessionHandAlreadyLowered;

  /// No description provided for @sessionHandAlreadyRaised.
  ///
  /// In en, this message translates to:
  /// **'Hand is already raised'**
  String get sessionHandAlreadyRaised;

  /// No description provided for @sessionCommandNotRecognized.
  ///
  /// In en, this message translates to:
  /// **'Command not recognized'**
  String get sessionCommandNotRecognized;

  /// No description provided for @sessionVoiceStopUnconfirmed.
  ///
  /// In en, this message translates to:
  /// **'Voice listening stop not confirmed. Retry stopping.'**
  String get sessionVoiceStopUnconfirmed;

  /// No description provided for @sessionVoiceStopping.
  ///
  /// In en, this message translates to:
  /// **'Stopping voice listening.'**
  String get sessionVoiceStopping;

  /// No description provided for @sessionVoiceStarting.
  ///
  /// In en, this message translates to:
  /// **'Starting voice commands.'**
  String get sessionVoiceStarting;

  /// No description provided for @sessionVoiceFinishing.
  ///
  /// In en, this message translates to:
  /// **'Finishing voice recognition.'**
  String get sessionVoiceFinishing;

  /// No description provided for @sessionVoiceListening.
  ///
  /// In en, this message translates to:
  /// **'Listening for one command, up to 12 seconds.'**
  String get sessionVoiceListening;

  /// No description provided for @sessionVoiceIdle.
  ///
  /// In en, this message translates to:
  /// **'Not listening. Activate Listen for command to start.'**
  String get sessionVoiceIdle;

  /// No description provided for @sessionVoiceSpeechNotStopped.
  ///
  /// In en, this message translates to:
  /// **'App speech could not be stopped. Try Stop speech before listening.'**
  String get sessionVoiceSpeechNotStopped;

  /// No description provided for @sessionVoiceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Voice commands are unavailable. Check microphone permission and Android English speech services.'**
  String get sessionVoiceUnavailable;

  /// No description provided for @sessionVoiceCouldNotStart.
  ///
  /// In en, this message translates to:
  /// **'Voice commands could not start. Check microphone permission and English speech services, then try again.'**
  String get sessionVoiceCouldNotStart;

  /// No description provided for @sessionVoiceCouldNotFinish.
  ///
  /// In en, this message translates to:
  /// **'Voice recognition could not finish. Check permission and English speech services, then activate Listen to retry.'**
  String get sessionVoiceCouldNotFinish;

  /// No description provided for @sessionVoiceNoCommand.
  ///
  /// In en, this message translates to:
  /// **'No command heard. Activate Listen for command to try again.'**
  String get sessionVoiceNoCommand;

  /// No description provided for @sessionVoiceCommandFailed.
  ///
  /// In en, this message translates to:
  /// **'The voice command could not be completed. Use its keypad control or try again.'**
  String get sessionVoiceCommandFailed;

  /// No description provided for @sessionVoiceCannotStop.
  ///
  /// In en, this message translates to:
  /// **'Voice listening could not be stopped. Retry Stop listening or leave the class and check the Android microphone indicator.'**
  String get sessionVoiceCannotStop;

  /// No description provided for @sessionRecordingSelectionChanged.
  ///
  /// In en, this message translates to:
  /// **'The class recording selection changed. Use Read class updates for details.'**
  String get sessionRecordingSelectionChanged;

  /// Name of a group of batched updates.
  ///
  /// In en, this message translates to:
  /// **'Class recording selection'**
  String get sessionRecordingSelectionGroup;

  /// No description provided for @sessionPlaybackFinished.
  ///
  /// In en, this message translates to:
  /// **'Recording finished.'**
  String get sessionPlaybackFinished;

  /// No description provided for @sessionNoRecording.
  ///
  /// In en, this message translates to:
  /// **'No class recording is selected.'**
  String get sessionNoRecording;

  /// No description provided for @sessionNoRecordingTeacher.
  ///
  /// In en, this message translates to:
  /// **'No class recording is selected. In the recording player, press 1 to choose one.'**
  String get sessionNoRecordingTeacher;

  /// No description provided for @sessionPreviewFailed.
  ///
  /// In en, this message translates to:
  /// **'The private preview could not start. Check the connection and try again.'**
  String get sessionPreviewFailed;

  /// No description provided for @sessionClassPauseUnconfirmed.
  ///
  /// In en, this message translates to:
  /// **'Your local audio is paused. The class pause was not confirmed. {reason}'**
  String sessionClassPauseUnconfirmed(String reason);

  /// speed: number such as 1.25.
  ///
  /// In en, this message translates to:
  /// **'{speed} times speed'**
  String sessionSpeed(String speed);

  /// No description provided for @sessionPlaybackAccepted.
  ///
  /// In en, this message translates to:
  /// **'Class playback request accepted for {title}.'**
  String sessionPlaybackAccepted(String title);

  /// No description provided for @sessionSelected.
  ///
  /// In en, this message translates to:
  /// **'{title} selected for the class. Press 5 to play it.'**
  String sessionSelected(String title);

  /// No description provided for @sessionPreviewing.
  ///
  /// In en, this message translates to:
  /// **'Previewing {title} on this phone only.'**
  String sessionPreviewing(String title);

  /// No description provided for @sessionPreviewStopped.
  ///
  /// In en, this message translates to:
  /// **'Preview stopped.'**
  String get sessionPreviewStopped;

  /// No description provided for @sessionRecordingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Class recording player'**
  String get sessionRecordingsTitle;

  /// No description provided for @sessionChooseRecording.
  ///
  /// In en, this message translates to:
  /// **'Choose a recording from the library'**
  String get sessionChooseRecording;

  /// No description provided for @sessionUploadRecording.
  ///
  /// In en, this message translates to:
  /// **'Upload a new recording'**
  String get sessionUploadRecording;

  /// No description provided for @sessionHearRecording.
  ///
  /// In en, this message translates to:
  /// **'Hear recording status'**
  String get sessionHearRecording;

  /// No description provided for @sessionPlayPauseClass.
  ///
  /// In en, this message translates to:
  /// **'Play or pause for the class'**
  String get sessionPlayPauseClass;

  /// No description provided for @sessionLibraryLoading.
  ///
  /// In en, this message translates to:
  /// **'The recording library is still loading. Try again shortly.'**
  String get sessionLibraryLoading;

  /// No description provided for @sessionLibraryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No recordings for this class yet. Press 2 to upload one.'**
  String get sessionLibraryEmpty;

  /// No description provided for @sessionPositionHint.
  ///
  /// In en, this message translates to:
  /// **'Use left and right to move 10 seconds'**
  String get sessionPositionHint;

  /// position: spoken position; speed: such as "1.25 times speed".
  ///
  /// In en, this message translates to:
  /// **'{title}. Playing for the class. {position}. {speed}.'**
  String sessionRecordingStatusPlaying(
    String title,
    String position,
    String speed,
  );

  /// position: spoken position; speed: such as "1.25 times speed".
  ///
  /// In en, this message translates to:
  /// **'{title}. Paused. {position}. {speed}.'**
  String sessionRecordingStatusPaused(
    String title,
    String position,
    String speed,
  );

  /// position: spoken position.
  ///
  /// In en, this message translates to:
  /// **'Position {position}. Use left and right to move 10 seconds'**
  String sessionPositionLabel(String position);

  /// Name used for a recording without a title.
  ///
  /// In en, this message translates to:
  /// **'Untitled'**
  String get sessionUntitled;

  /// Part of a comma separated recording label.
  ///
  /// In en, this message translates to:
  /// **'selected for the class'**
  String get sessionFileSelectedForClass;

  /// Part of a comma separated recording label.
  ///
  /// In en, this message translates to:
  /// **'previewing'**
  String get sessionFilePreviewing;

  /// No description provided for @sessionPlayForClass.
  ///
  /// In en, this message translates to:
  /// **'Select and play for the class now'**
  String get sessionPlayForClass;

  /// No description provided for @sessionSelectOnly.
  ///
  /// In en, this message translates to:
  /// **'Select only, play later with 5'**
  String get sessionSelectOnly;

  /// No description provided for @sessionPreviewPrivately.
  ///
  /// In en, this message translates to:
  /// **'Preview privately on this phone'**
  String get sessionPreviewPrivately;

  /// No description provided for @sessionStopPreview.
  ///
  /// In en, this message translates to:
  /// **'Stop the private preview'**
  String get sessionStopPreview;

  /// No description provided for @sessionUploadDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Upload audio details'**
  String get sessionUploadDetailsTitle;

  /// No description provided for @sessionUploadTitle.
  ///
  /// In en, this message translates to:
  /// **'Upload Audio'**
  String get sessionUploadTitle;

  /// name: file name.
  ///
  /// In en, this message translates to:
  /// **'File: {name}'**
  String sessionUploadFile(String name);

  /// No description provided for @sessionTitleField.
  ///
  /// In en, this message translates to:
  /// **'Audio title, required'**
  String get sessionTitleField;

  /// No description provided for @sessionDescriptionField.
  ///
  /// In en, this message translates to:
  /// **'Audio description, optional'**
  String get sessionDescriptionField;

  /// No description provided for @sessionCancelUpload.
  ///
  /// In en, this message translates to:
  /// **'Cancel upload'**
  String get sessionCancelUpload;

  /// No description provided for @sessionConfirmUpload.
  ///
  /// In en, this message translates to:
  /// **'Upload audio'**
  String get sessionConfirmUpload;

  /// No description provided for @sessionTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Title is required'**
  String get sessionTitleRequired;

  /// No description provided for @sessionChooseSessionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose classes for this audio'**
  String get sessionChooseSessionsTitle;

  /// No description provided for @sessionAddToSessions.
  ///
  /// In en, this message translates to:
  /// **'Add audio to classes'**
  String get sessionAddToSessions;

  /// No description provided for @sessionConfirmSessions.
  ///
  /// In en, this message translates to:
  /// **'Confirm selected classes'**
  String get sessionConfirmSessions;

  /// No description provided for @sessionSelectAtLeastOne.
  ///
  /// In en, this message translates to:
  /// **'Select at least one class'**
  String get sessionSelectAtLeastOne;

  /// No description provided for @sessionSessionSelected.
  ///
  /// In en, this message translates to:
  /// **'Class selected'**
  String get sessionSessionSelected;

  /// No description provided for @sessionSessionUnselected.
  ///
  /// In en, this message translates to:
  /// **'Class unselected'**
  String get sessionSessionUnselected;

  /// No description provided for @sessionChoiceSelected.
  ///
  /// In en, this message translates to:
  /// **'Selected, {title}'**
  String sessionChoiceSelected(String title);

  /// No description provided for @sessionChoiceNotSelected.
  ///
  /// In en, this message translates to:
  /// **'Not selected, {title}'**
  String sessionChoiceNotSelected(String title);

  /// number: spoken class identifier.
  ///
  /// In en, this message translates to:
  /// **'Class {number}'**
  String sessionClassNumbered(String number);

  /// No description provided for @sessionUploadContextMissing.
  ///
  /// In en, this message translates to:
  /// **'The class and subject of this class could not be determined.'**
  String get sessionUploadContextMissing;

  /// No description provided for @sessionUploadSuccess.
  ///
  /// In en, this message translates to:
  /// **'Upload successful.'**
  String get sessionUploadSuccess;

  /// No description provided for @sessionUploadInProgress.
  ///
  /// In en, this message translates to:
  /// **'Audio upload in progress'**
  String get sessionUploadInProgress;

  /// No description provided for @sessionPlayNowTitle.
  ///
  /// In en, this message translates to:
  /// **'Play for everyone now?'**
  String get sessionPlayNowTitle;

  /// No description provided for @sessionPlayNowMessage.
  ///
  /// In en, this message translates to:
  /// **'{title} is selected. Play it for all participants now?'**
  String sessionPlayNowMessage(String title);

  /// No description provided for @sessionPlayNow.
  ///
  /// In en, this message translates to:
  /// **'Play now'**
  String get sessionPlayNow;

  /// No description provided for @sessionNotYet.
  ///
  /// In en, this message translates to:
  /// **'Not yet'**
  String get sessionNotYet;

  /// Keypad key label.
  ///
  /// In en, this message translates to:
  /// **'Edit Title'**
  String get sessionUploadEditTitle;

  /// Keypad key label.
  ///
  /// In en, this message translates to:
  /// **'Edit Description'**
  String get sessionUploadEditDescription;

  /// Keypad key label.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get sessionUploadKey;

  /// Keypad key label.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get sessionCancel;

  /// No description provided for @classroomCheckUnreadable.
  ///
  /// In en, this message translates to:
  /// **'Classroom check state could not be read. Refresh before responding.'**
  String get classroomCheckUnreadable;

  /// No description provided for @classroomCheckUnconfirmed.
  ///
  /// In en, this message translates to:
  /// **'The classroom check action was not confirmed. Refresh before trying again.'**
  String get classroomCheckUnconfirmed;

  /// No description provided for @classroomCheckConfirmationUnreadable.
  ///
  /// In en, this message translates to:
  /// **'The classroom check confirmation was unreadable. Refresh before trying again.'**
  String get classroomCheckConfirmationUnreadable;

  /// No description provided for @classroomCheckOpenedForYou.
  ///
  /// In en, this message translates to:
  /// **'Your teacher asked a question. Press 3 to answer.'**
  String get classroomCheckOpenedForYou;

  /// No description provided for @classroomCheckHelp.
  ///
  /// In en, this message translates to:
  /// **'Private classroom check. Understood, Please repeat or Need help. Only the responding student and session teacher can read a response. It is not graded. Responses clear on the next check, session end or server restart. Use Read or Refresh for confirmed state. Stop speech and Back are available.'**
  String get classroomCheckHelp;

  /// No description provided for @classroomCheckTitle.
  ///
  /// In en, this message translates to:
  /// **'Classroom check'**
  String get classroomCheckTitle;

  /// No description provided for @classroomCheckNewTitle.
  ///
  /// In en, this message translates to:
  /// **'Open a new classroom check?'**
  String get classroomCheckNewTitle;

  /// No description provided for @classroomCheckNewMessage.
  ///
  /// In en, this message translates to:
  /// **'This clears all responses from the previous check. Students choose Understood, Please repeat or Need help. Only you and each responding student can read their response. It is not graded or retained as an academic record.'**
  String get classroomCheckNewMessage;

  /// No description provided for @classroomCheckNewConfirm.
  ///
  /// In en, this message translates to:
  /// **'Clear previous and open'**
  String get classroomCheckNewConfirm;

  /// No description provided for @classroomCheckNewCancel.
  ///
  /// In en, this message translates to:
  /// **'Keep current check'**
  String get classroomCheckNewCancel;

  /// No description provided for @classroomCheckSending.
  ///
  /// In en, this message translates to:
  /// **'Sending. Waiting for confirmation.'**
  String get classroomCheckSending;

  /// No description provided for @classroomCheckWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting for confirmation. Do not resend.'**
  String get classroomCheckWaiting;

  /// No description provided for @sessionBackToClass.
  ///
  /// In en, this message translates to:
  /// **'Back to class'**
  String get sessionBackToClass;

  /// No description provided for @classroomBackToSession.
  ///
  /// In en, this message translates to:
  /// **'Back to session'**
  String get classroomBackToSession;

  /// Keypad key label.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get classroomBack;

  /// No description provided for @classroomCheckRead.
  ///
  /// In en, this message translates to:
  /// **'Read check status and confirmed responses'**
  String get classroomCheckRead;

  /// No description provided for @classroomCheckReadButton.
  ///
  /// In en, this message translates to:
  /// **'Read status and responses'**
  String get classroomCheckReadButton;

  /// No description provided for @classroomCheckRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh private check state. Requires class connection'**
  String get classroomCheckRefresh;

  /// No description provided for @classroomCheckRefreshButton.
  ///
  /// In en, this message translates to:
  /// **'Refresh from server'**
  String get classroomCheckRefreshButton;

  /// No description provided for @classroomCheckOpenLabel.
  ///
  /// In en, this message translates to:
  /// **'Open a new check. Confirm clearing previous responses'**
  String get classroomCheckOpenLabel;

  /// No description provided for @classroomCheckOpenButton.
  ///
  /// In en, this message translates to:
  /// **'Open new check'**
  String get classroomCheckOpenButton;

  /// No description provided for @classroomCheckCloseLabel.
  ///
  /// In en, this message translates to:
  /// **'Close this check. Keep current results until next check or session end'**
  String get classroomCheckCloseLabel;

  /// No description provided for @classroomCheckCloseButton.
  ///
  /// In en, this message translates to:
  /// **'Close check'**
  String get classroomCheckCloseButton;

  /// choice: Understood, Please repeat or Need help.
  ///
  /// In en, this message translates to:
  /// **'{choice}. Send or change your private, ungraded response'**
  String classroomCheckAnswer(String choice);

  /// No description provided for @sessionStopSpeech.
  ///
  /// In en, this message translates to:
  /// **'Stop speech'**
  String get sessionStopSpeech;

  /// Classroom check answer.
  ///
  /// In en, this message translates to:
  /// **'Understood'**
  String get classroomChoiceUnderstood;

  /// Classroom check answer.
  ///
  /// In en, this message translates to:
  /// **'Please repeat'**
  String get classroomChoiceRepeat;

  /// Classroom check answer.
  ///
  /// In en, this message translates to:
  /// **'Need help'**
  String get classroomChoiceHelp;

  /// No description provided for @classroomCheckNone.
  ///
  /// In en, this message translates to:
  /// **'No current check in the last received classroom state. Refresh to check.'**
  String get classroomCheckNone;

  /// No description provided for @classroomCheckStatusOpen.
  ///
  /// In en, this message translates to:
  /// **'Check open.'**
  String get classroomCheckStatusOpen;

  /// No description provided for @classroomCheckStatusClosed.
  ///
  /// In en, this message translates to:
  /// **'Check closed. Responses cannot be changed.'**
  String get classroomCheckStatusClosed;

  /// No description provided for @classroomCheckNoResponseYet.
  ///
  /// In en, this message translates to:
  /// **'No response confirmed yet.'**
  String get classroomCheckNoResponseYet;

  /// No description provided for @classroomCheckYourResponse.
  ///
  /// In en, this message translates to:
  /// **'Your confirmed response: {choice}.'**
  String classroomCheckYourResponse(String choice);

  /// status: check open or closed sentence; response: your response sentence.
  ///
  /// In en, this message translates to:
  /// **'{status} {response} Only you and the session teacher can read your response. This is not graded.'**
  String classroomCheckStudentSummary(String status, String response);

  /// Either an answer and its count, or a student name and their answer.
  ///
  /// In en, this message translates to:
  /// **'{label}: {value}'**
  String classroomCheckLabelValue(String label, String value);

  /// No description provided for @classroomCheckNoResponses.
  ///
  /// In en, this message translates to:
  /// **'No responses yet.'**
  String get classroomCheckNoResponses;

  /// status: check open or closed sentence; counts: answer counts; named: each student and answer, or "No responses yet."
  ///
  /// In en, this message translates to:
  /// **'{count, plural, other{{status} {count} students responded. {counts}. {named} Responses are private to you and each responding student, and are not grades.}}'**
  String classroomCheckTeacherSummary(
    int count,
    String status,
    String counts,
    String named,
  );

  /// No description provided for @sessionToolsTitle.
  ///
  /// In en, this message translates to:
  /// **'Teacher tools'**
  String get sessionToolsTitle;

  /// No description provided for @sessionInvite.
  ///
  /// In en, this message translates to:
  /// **'Invite students'**
  String get sessionInvite;

  /// No description provided for @sessionEndClass.
  ///
  /// In en, this message translates to:
  /// **'End class for everyone, asks to confirm'**
  String get sessionEndClass;

  /// No description provided for @sessionPeopleTitle.
  ///
  /// In en, this message translates to:
  /// **'Participants and raised hands'**
  String get sessionPeopleTitle;

  /// No description provided for @sessionParticipantList.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Participants list, 1 person} other{Participants list, {count} people}}'**
  String sessionParticipantList(int count);

  /// No description provided for @sessionSummaryChoice.
  ///
  /// In en, this message translates to:
  /// **'Hear classroom summary'**
  String get sessionSummaryChoice;

  /// No description provided for @sessionParticipantsTitle.
  ///
  /// In en, this message translates to:
  /// **'Participants'**
  String get sessionParticipantsTitle;

  /// No description provided for @sessionMembersTitle.
  ///
  /// In en, this message translates to:
  /// **'People in the class'**
  String get sessionMembersTitle;

  /// Button text; 7 is the keypad key.
  ///
  /// In en, this message translates to:
  /// **'7: Who is in class'**
  String get sessionMembersButton;

  /// people: sentence such as "3 people in the class."
  ///
  /// In en, this message translates to:
  /// **'Who is in the class. {people} Select a person to hear details'**
  String sessionMembersLabel(String people);

  /// No description provided for @sessionHearDetails.
  ///
  /// In en, this message translates to:
  /// **'Hear details'**
  String get sessionHearDetails;

  /// No description provided for @sessionMuteParticipant.
  ///
  /// In en, this message translates to:
  /// **'Mute {name}'**
  String sessionMuteParticipant(String name);

  /// No description provided for @sessionRemoveParticipant.
  ///
  /// In en, this message translates to:
  /// **'Remove {name} from the class, asks to confirm'**
  String sessionRemoveParticipant(String name);

  /// No description provided for @sessionParticipantGone.
  ///
  /// In en, this message translates to:
  /// **'That participant has left the class.'**
  String get sessionParticipantGone;

  /// No description provided for @sessionNoOtherParticipants.
  ///
  /// In en, this message translates to:
  /// **'Nobody else is in the class yet.'**
  String get sessionNoOtherParticipants;

  /// No description provided for @sessionTileRemoveMessage.
  ///
  /// In en, this message translates to:
  /// **'{name} will be removed from this class and returned to their dashboard.'**
  String sessionTileRemoveMessage(String name);

  /// No description provided for @sessionTileRemoveFromSessionMessage.
  ///
  /// In en, this message translates to:
  /// **'{name} will be removed from this session and returned to their dashboard.'**
  String sessionTileRemoveFromSessionMessage(String name);

  /// No description provided for @sessionUnmuteParticipant.
  ///
  /// In en, this message translates to:
  /// **'Unmute {name}'**
  String sessionUnmuteParticipant(String name);

  /// No description provided for @sessionRemoveFromClass.
  ///
  /// In en, this message translates to:
  /// **'Remove {name} from class'**
  String sessionRemoveFromClass(String name);

  /// Connection state.
  ///
  /// In en, this message translates to:
  /// **'Connecting'**
  String get sessionConnStateConnecting;

  /// Connection state.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get sessionConnStateConnected;

  /// Connection state.
  ///
  /// In en, this message translates to:
  /// **'Connection interrupted'**
  String get sessionConnStateInterrupted;

  /// Connection state.
  ///
  /// In en, this message translates to:
  /// **'Reconnecting'**
  String get sessionConnStateReconnecting;

  /// Connection state.
  ///
  /// In en, this message translates to:
  /// **'Sign-in required'**
  String get sessionConnStateSignInRequired;

  /// Connection state.
  ///
  /// In en, this message translates to:
  /// **'Class unavailable'**
  String get sessionConnStateUnavailable;

  /// Connection state.
  ///
  /// In en, this message translates to:
  /// **'Class ended'**
  String get sessionConnStateEnded;

  /// Connection state.
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get sessionConnStateDisconnected;

  /// No description provided for @sessionReconnectingToClass.
  ///
  /// In en, this message translates to:
  /// **'Reconnecting to the class.'**
  String get sessionReconnectingToClass;

  /// No description provided for @sessionSignInRequiredLeave.
  ///
  /// In en, this message translates to:
  /// **'Sign-in is required. Leave the session and sign in again.'**
  String get sessionSignInRequiredLeave;

  /// No description provided for @sessionSignInExpiredLeave.
  ///
  /// In en, this message translates to:
  /// **'Sign-in expired. Leave the session and sign in again.'**
  String get sessionSignInExpiredLeave;

  /// No description provided for @sessionClassNoLongerAvailable.
  ///
  /// In en, this message translates to:
  /// **'This class is no longer available to your account. You can go back.'**
  String get sessionClassNoLongerAvailable;

  /// No description provided for @sessionServiceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The class service is unavailable.'**
  String get sessionServiceUnavailable;

  /// No description provided for @sessionConnectionUnreadable.
  ///
  /// In en, this message translates to:
  /// **'The class connection response could not be read.'**
  String get sessionConnectionUnreadable;

  /// No description provided for @sessionConnectionNotConfirmed.
  ///
  /// In en, this message translates to:
  /// **'The class did not confirm the connection.'**
  String get sessionConnectionNotConfirmed;

  /// No description provided for @sessionConnectionInterrupted.
  ///
  /// In en, this message translates to:
  /// **'The class connection was interrupted.'**
  String get sessionConnectionInterrupted;

  /// No description provided for @sessionConnectionClosed.
  ///
  /// In en, this message translates to:
  /// **'The class connection closed.'**
  String get sessionConnectionClosed;

  /// No description provided for @sessionConnectionCouldNotConfirm.
  ///
  /// In en, this message translates to:
  /// **'The class connection could not be confirmed.'**
  String get sessionConnectionCouldNotConfirm;

  /// No description provided for @sessionNoUpdates.
  ///
  /// In en, this message translates to:
  /// **'No updates were received from the class.'**
  String get sessionNoUpdates;

  /// No description provided for @sessionUpdateUnreadable.
  ///
  /// In en, this message translates to:
  /// **'A class update could not be read.'**
  String get sessionUpdateUnreadable;

  /// No description provided for @sessionUpdateUnexpectedFormat.
  ///
  /// In en, this message translates to:
  /// **'A class update had an unexpected format.'**
  String get sessionUpdateUnexpectedFormat;

  /// No description provided for @sessionUpdateTypeUnreadable.
  ///
  /// In en, this message translates to:
  /// **'A class update type could not be read.'**
  String get sessionUpdateTypeUnreadable;

  /// No description provided for @sessionParticipationNotConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Your class participation was not confirmed.'**
  String get sessionParticipationNotConfirmed;

  /// No description provided for @sessionConnectedToClass.
  ///
  /// In en, this message translates to:
  /// **'Connected to the class.'**
  String get sessionConnectedToClass;

  /// No description provided for @sessionSignInChangedShort.
  ///
  /// In en, this message translates to:
  /// **'Your sign-in changed. Sign in again.'**
  String get sessionSignInChangedShort;

  /// No description provided for @sessionRemovedGoBack.
  ///
  /// In en, this message translates to:
  /// **'You have been removed from the class. You can go back.'**
  String get sessionRemovedGoBack;

  /// reason: sentence saying why the connection was lost.
  ///
  /// In en, this message translates to:
  /// **'{reason} Reconnecting. Previous actions will not be sent again automatically.'**
  String sessionConnectionLostReconnecting(String reason);

  /// No description provided for @sessionActionClassUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The class is not available. This action was not sent.'**
  String get sessionActionClassUnavailable;

  /// No description provided for @sessionActionSessionChanged.
  ///
  /// In en, this message translates to:
  /// **'The session changed. This action was not sent.'**
  String get sessionActionSessionChanged;

  /// No description provided for @sessionActionSignInRequired.
  ///
  /// In en, this message translates to:
  /// **'Sign-in is required. This action was not sent.'**
  String get sessionActionSignInRequired;

  /// No description provided for @sessionActionConnectionChanged.
  ///
  /// In en, this message translates to:
  /// **'The connection changed before confirmation. The action may have been received; check its status before retrying.'**
  String get sessionActionConnectionChanged;

  /// No description provided for @sessionAccountChangedLeave.
  ///
  /// In en, this message translates to:
  /// **'Your account changed. Leave the session and sign in again.'**
  String get sessionAccountChangedLeave;

  /// No description provided for @sessionActionAccountChanged.
  ///
  /// In en, this message translates to:
  /// **'Your account changed before the action could be confirmed.'**
  String get sessionActionAccountChanged;

  /// No description provided for @sessionActionNotConfirmedByClass.
  ///
  /// In en, this message translates to:
  /// **'The class did not confirm the action. Check its status before trying again.'**
  String get sessionActionNotConfirmedByClass;

  /// No description provided for @sessionActionMayHaveReached.
  ///
  /// In en, this message translates to:
  /// **'The action was not confirmed. It may have reached the class. Check its status before trying again.'**
  String get sessionActionMayHaveReached;

  /// No description provided for @sessionRtcConnectionClosed.
  ///
  /// In en, this message translates to:
  /// **'Connection closed.'**
  String get sessionRtcConnectionClosed;

  /// No description provided for @sessionRtcNetworkError.
  ///
  /// In en, this message translates to:
  /// **'Network error'**
  String get sessionRtcNetworkError;

  /// No description provided for @sessionRtcConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected to session {id}'**
  String sessionRtcConnected(String id);

  /// No description provided for @sessionRtcParticipantJoined.
  ///
  /// In en, this message translates to:
  /// **'Participant {id} joined.'**
  String sessionRtcParticipantJoined(String id);

  /// No description provided for @sessionRtcParticipantLeft.
  ///
  /// In en, this message translates to:
  /// **'Participant {id} left.'**
  String sessionRtcParticipantLeft(String id);

  /// No description provided for @sessionRtcParticipantMuted.
  ///
  /// In en, this message translates to:
  /// **'Participant {id} is now muted'**
  String sessionRtcParticipantMuted(String id);

  /// No description provided for @sessionRtcParticipantUnmuted.
  ///
  /// In en, this message translates to:
  /// **'Participant {id} is now unmuted'**
  String sessionRtcParticipantUnmuted(String id);

  /// No description provided for @sessionRtcMessage.
  ///
  /// In en, this message translates to:
  /// **'Message: {text}'**
  String sessionRtcMessage(String text);

  /// No description provided for @sessionRtcTeacherPlaying.
  ///
  /// In en, this message translates to:
  /// **'Teacher started playing audio {id}'**
  String sessionRtcTeacherPlaying(String id);

  /// No description provided for @sessionRtcAudioStarted.
  ///
  /// In en, this message translates to:
  /// **'Audio stream started for participant {id}'**
  String sessionRtcAudioStarted(String id);

  /// Playback speed, e.g. "1.25 times".
  ///
  /// In en, this message translates to:
  /// **'{speed} times'**
  String librarySpeedTimes(String speed);

  /// No description provided for @libraryNoClassForSession.
  ///
  /// In en, this message translates to:
  /// **'No class found with this session name.'**
  String get libraryNoClassForSession;

  /// No description provided for @librarySubjectFilterLabel.
  ///
  /// In en, this message translates to:
  /// **'Subject filter: {name}. Key 2, or left or right to change'**
  String librarySubjectFilterLabel(String name);

  /// No description provided for @librarySubjectFilterLabelPosition.
  ///
  /// In en, this message translates to:
  /// **'Subject filter: {name}, {index} of {total}. Key 2, or left or right to change'**
  String librarySubjectFilterLabelPosition(
    String name,
    String index,
    String total,
  );

  /// No description provided for @libraryAllSubjects.
  ///
  /// In en, this message translates to:
  /// **'All subjects'**
  String get libraryAllSubjects;

  /// No description provided for @libraryRestoredToPlaylist.
  ///
  /// In en, this message translates to:
  /// **'{title} is back in the playlist.'**
  String libraryRestoredToPlaylist(String title);

  /// No description provided for @librarySizeZero.
  ///
  /// In en, this message translates to:
  /// **'0 megabytes'**
  String get librarySizeZero;

  /// No description provided for @librarySizeTiny.
  ///
  /// In en, this message translates to:
  /// **'less than 0.1 megabytes'**
  String get librarySizeTiny;

  /// No description provided for @librarySizeOne.
  ///
  /// In en, this message translates to:
  /// **'1 megabyte'**
  String get librarySizeOne;

  /// value is a decimal number such as 1.5 or 12.
  ///
  /// In en, this message translates to:
  /// **'{value} megabytes'**
  String librarySizeMegabytes(String value);

  /// size e.g. "12 megabytes"; limit is a number of megabytes.
  ///
  /// In en, this message translates to:
  /// **'{size} used of {limit}.'**
  String libraryStorageUsed(String size, String limit);

  /// No description provided for @libraryRecordingCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 recording} other{{count} recordings}}'**
  String libraryRecordingCount(int count);

  /// No description provided for @libraryPlayingBrief.
  ///
  /// In en, this message translates to:
  /// **'{title}, playing from {position}.'**
  String libraryPlayingBrief(String title, String position);

  /// speed e.g. "1.25 times".
  ///
  /// In en, this message translates to:
  /// **'{title}, playing from {position}, speed {speed}.'**
  String libraryPlayingDetailed(String title, String position, String speed);

  /// No description provided for @libraryPausedAt.
  ///
  /// In en, this message translates to:
  /// **'Paused at {position}.'**
  String libraryPausedAt(String position);

  /// No description provided for @libraryPlayerStateNothing.
  ///
  /// In en, this message translates to:
  /// **'Nothing playing.'**
  String get libraryPlayerStateNothing;

  /// No description provided for @libraryPlayerStatePlaying.
  ///
  /// In en, this message translates to:
  /// **'Playing {title}, {position}, speed {speed}.'**
  String libraryPlayerStatePlaying(String title, String position, String speed);

  /// No description provided for @libraryPlayerStatePaused.
  ///
  /// In en, this message translates to:
  /// **'Paused {title}, {position}, speed {speed}.'**
  String libraryPlayerStatePaused(String title, String position, String speed);

  /// No description provided for @librarySpeedChanged.
  ///
  /// In en, this message translates to:
  /// **'Speed {speed}.'**
  String librarySpeedChanged(String speed);

  /// No description provided for @librarySlowest.
  ///
  /// In en, this message translates to:
  /// **'Already at the slowest speed.'**
  String get librarySlowest;

  /// No description provided for @libraryFastest.
  ///
  /// In en, this message translates to:
  /// **'Already at the fastest speed.'**
  String get libraryFastest;

  /// No description provided for @libraryNoLessonLoaded.
  ///
  /// In en, this message translates to:
  /// **'No lesson is loaded. Choose a lesson to play first.'**
  String get libraryNoLessonLoaded;

  /// No description provided for @libraryNoLessonPlayingPress.
  ///
  /// In en, this message translates to:
  /// **'No lesson is playing. Press {key} to play the first lesson.'**
  String libraryNoLessonPlayingPress(String key);

  /// No description provided for @libraryNothingIsPlaying.
  ///
  /// In en, this message translates to:
  /// **'Nothing is playing.'**
  String get libraryNothingIsPlaying;

  /// No description provided for @libraryNothingPlayingHint.
  ///
  /// In en, this message translates to:
  /// **'Nothing playing. Select a lesson or press 5.'**
  String get libraryNothingPlayingHint;

  /// No description provided for @libraryStopped.
  ///
  /// In en, this message translates to:
  /// **'{title} stopped.'**
  String libraryStopped(String title);

  /// No description provided for @libraryFinished.
  ///
  /// In en, this message translates to:
  /// **'{title} finished.'**
  String libraryFinished(String title);

  /// No description provided for @libraryWaitForPlayer.
  ///
  /// In en, this message translates to:
  /// **'Please wait for the lesson player.'**
  String get libraryWaitForPlayer;

  /// No description provided for @librarySeekFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not move to that lesson position. Try again.'**
  String get librarySeekFailed;

  /// No description provided for @librarySpeedFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not change playback speed. Try again.'**
  String get librarySpeedFailed;

  /// No description provided for @libraryPlayFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not play {title}. Check your connection, then select it again.'**
  String libraryPlayFailed(String title);

  /// No description provided for @libraryCheckingOfflineAccess.
  ///
  /// In en, this message translates to:
  /// **'Internet unavailable. Checking your saved offline access.'**
  String get libraryCheckingOfflineAccess;

  /// No description provided for @libraryLessonGone.
  ///
  /// In en, this message translates to:
  /// **'This lesson is no longer available. Your saved progress and bookmarks are kept.'**
  String get libraryLessonGone;

  /// No description provided for @librarySeekLabel.
  ///
  /// In en, this message translates to:
  /// **'Lesson position {position}. Use left or right to move 10 seconds.'**
  String librarySeekLabel(String position);

  /// No description provided for @libraryRewindLabel.
  ///
  /// In en, this message translates to:
  /// **'Back 10 seconds, key {key}'**
  String libraryRewindLabel(String key);

  /// No description provided for @libraryForwardLabel.
  ///
  /// In en, this message translates to:
  /// **'Forward 10 seconds, key {key}'**
  String libraryForwardLabel(String key);

  /// No description provided for @librarySlowerLabel.
  ///
  /// In en, this message translates to:
  /// **'Slower, key {key}. Now {speed}'**
  String librarySlowerLabel(String key, String speed);

  /// No description provided for @libraryFasterLabel.
  ///
  /// In en, this message translates to:
  /// **'Faster, key {key}. Now {speed}'**
  String libraryFasterLabel(String key, String speed);

  /// No description provided for @libraryPauseLabel.
  ///
  /// In en, this message translates to:
  /// **'Pause {title}, key {key}'**
  String libraryPauseLabel(String title, String key);

  /// No description provided for @libraryPlayLabel.
  ///
  /// In en, this message translates to:
  /// **'Play {title}, key {key}'**
  String libraryPlayLabel(String title, String key);

  /// No description provided for @libraryResumeLabel.
  ///
  /// In en, this message translates to:
  /// **'Resume {title}, key {key}'**
  String libraryResumeLabel(String title, String key);

  /// No description provided for @libraryStopLabel.
  ///
  /// In en, this message translates to:
  /// **'Stop {title}, key {key}'**
  String libraryStopLabel(String title, String key);

  /// Placeholders are keypad digits.
  ///
  /// In en, this message translates to:
  /// **'Press {rewind} to go back 10 seconds, {playPause} to play or pause, {forward} to go forward 10 seconds, {slower} for slower and {faster} for faster.'**
  String libraryPlayerKeyHelp(
    String rewind,
    String playPause,
    String forward,
    String slower,
    String faster,
  );

  /// No description provided for @libraryBookmarkCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 bookmark} other{{count} bookmarks}}'**
  String libraryBookmarkCount(int count);

  /// bookmarks e.g. "2 bookmarks"; repeat and saving are "on" or "off".
  ///
  /// In en, this message translates to:
  /// **'{title}. Position {position}. Speed {speed}. {bookmarks}. A-B repeat {repeat}. Progress saving {saving}.'**
  String libraryLearningStatus(
    String title,
    String position,
    String speed,
    String bookmarks,
    String repeat,
    String saving,
  );

  /// No description provided for @libraryReadStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Read learning status. {status}'**
  String libraryReadStatusLabel(String status);

  /// No description provided for @libraryAddBookmarkLabel.
  ///
  /// In en, this message translates to:
  /// **'Add bookmark at {time}'**
  String libraryAddBookmarkLabel(String time);

  /// No description provided for @libraryBookmarksLabel.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Bookmarks. 1 saved point} other{Bookmarks. {count} saved points}}'**
  String libraryBookmarksLabel(int count);

  /// No description provided for @libraryNotesLabel.
  ///
  /// In en, this message translates to:
  /// **'Private study notes at {time}. Pauses the lesson before opening'**
  String libraryNotesLabel(String time);

  /// No description provided for @libraryRepeatStartLabel.
  ///
  /// In en, this message translates to:
  /// **'Set repeat start A at the current position'**
  String get libraryRepeatStartLabel;

  /// No description provided for @libraryRepeatEndLabel.
  ///
  /// In en, this message translates to:
  /// **'Set repeat end B after start A'**
  String get libraryRepeatEndLabel;

  /// No description provided for @libraryRepeatTurnOffLabel.
  ///
  /// In en, this message translates to:
  /// **'Turn A-B repeat off'**
  String get libraryRepeatTurnOffLabel;

  /// No description provided for @libraryRepeatTurnOnLabel.
  ///
  /// In en, this message translates to:
  /// **'Turn A-B repeat on'**
  String get libraryRepeatTurnOnLabel;

  /// No description provided for @libraryRepeatClearLabel.
  ///
  /// In en, this message translates to:
  /// **'Clear saved A-B repeat points'**
  String get libraryRepeatClearLabel;

  /// No description provided for @libraryRetryLabel.
  ///
  /// In en, this message translates to:
  /// **'Retry saving learning progress. {issue}'**
  String libraryRetryLabel(String issue);

  /// No description provided for @libraryBookmarkSaved.
  ///
  /// In en, this message translates to:
  /// **'Bookmark saved at {time}.'**
  String libraryBookmarkSaved(String time);

  /// No description provided for @libraryRepeatStartSet.
  ///
  /// In en, this message translates to:
  /// **'Repeat start set at {time}.'**
  String libraryRepeatStartSet(String time);

  /// No description provided for @libraryRepeatEndSetBrief.
  ///
  /// In en, this message translates to:
  /// **'Repeat end set at {time}.'**
  String libraryRepeatEndSetBrief(String time);

  /// No description provided for @libraryRepeatEndSetDetailed.
  ///
  /// In en, this message translates to:
  /// **'Repeat end set at {time}. Select Repeat on to start looping.'**
  String libraryRepeatEndSetDetailed(String time);

  /// state is "on" or "off".
  ///
  /// In en, this message translates to:
  /// **'A-B repeat {state}.'**
  String libraryRepeatState(String state);

  /// No description provided for @libraryRepeatCleared.
  ///
  /// In en, this message translates to:
  /// **'A-B repeat points cleared.'**
  String get libraryRepeatCleared;

  /// No description provided for @libraryProgressSaved.
  ///
  /// In en, this message translates to:
  /// **'Learning progress saved.'**
  String get libraryProgressSaved;

  /// No description provided for @libraryActionFailed.
  ///
  /// In en, this message translates to:
  /// **'The player could not complete this action. Check playback and try again.'**
  String get libraryActionFailed;

  /// No description provided for @libraryCheckPosition.
  ///
  /// In en, this message translates to:
  /// **'Check the lesson position and try again.'**
  String get libraryCheckPosition;

  /// No description provided for @libraryProgressUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved progress unavailable'**
  String get libraryProgressUnavailableTitle;

  /// No description provided for @libraryProgressUnavailable.
  ///
  /// In en, this message translates to:
  /// **'{reason} Listen from the beginning without changing saved data? Saving stays off until you retry successfully.'**
  String libraryProgressUnavailable(String reason);

  /// Button label.
  ///
  /// In en, this message translates to:
  /// **'Listen from beginning'**
  String get libraryListenFromBeginning;

  /// No description provided for @libraryBookmarkNameScreen.
  ///
  /// In en, this message translates to:
  /// **'Name bookmark. Press OK to edit. Up or down leaves editing.'**
  String get libraryBookmarkNameScreen;

  /// No description provided for @libraryEnterBookmarkName.
  ///
  /// In en, this message translates to:
  /// **'Enter a bookmark name.'**
  String get libraryEnterBookmarkName;

  /// No description provided for @libraryBookmarkLabel.
  ///
  /// In en, this message translates to:
  /// **'{label}. {time}. Jump to bookmark'**
  String libraryBookmarkLabel(String label, String time);

  /// No description provided for @libraryBookmarkJumped.
  ///
  /// In en, this message translates to:
  /// **'{label}. Position {time}.'**
  String libraryBookmarkJumped(String label, String time);

  /// No description provided for @libraryRemoveBookmarkLabel.
  ///
  /// In en, this message translates to:
  /// **'Remove {label}'**
  String libraryRemoveBookmarkLabel(String label);

  /// No description provided for @libraryRemoveBookmarkQuestion.
  ///
  /// In en, this message translates to:
  /// **'Remove {label}? This does not remove the lesson or any other bookmarks.'**
  String libraryRemoveBookmarkQuestion(String label);

  /// No description provided for @libraryBookmarkRemoved.
  ///
  /// In en, this message translates to:
  /// **'{label} removed.'**
  String libraryBookmarkRemoved(String label);

  /// No description provided for @libraryBookmarksScreen.
  ///
  /// In en, this message translates to:
  /// **'Bookmarks. Select a point to jump. This does not start paused playback. Remove asks for confirmation.'**
  String get libraryBookmarksScreen;

  /// No description provided for @libraryNoRecordingsUpload.
  ///
  /// In en, this message translates to:
  /// **'No recordings yet. Press 2 to upload audio.'**
  String get libraryNoRecordingsUpload;

  /// No description provided for @libraryRecordingsLoaded.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 recording loaded.} other{{count} recordings loaded.}}'**
  String libraryRecordingsLoaded(int count);

  /// No description provided for @libraryLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load recordings. Check your internet connection, then press 1 to retry.'**
  String get libraryLoadFailed;

  /// No description provided for @libraryTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Title is required.'**
  String get libraryTitleRequired;

  /// No description provided for @libraryPickFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open the file. Try choosing it again.'**
  String get libraryPickFailed;

  /// No description provided for @libraryChooseWorkspaceFirst.
  ///
  /// In en, this message translates to:
  /// **'Choose a class and subject workspace on the Teacher Dashboard before uploading audio.'**
  String get libraryChooseWorkspaceFirst;

  /// No description provided for @libraryUploadingBrief.
  ///
  /// In en, this message translates to:
  /// **'Uploading {title}.'**
  String libraryUploadingBrief(String title);

  /// No description provided for @libraryUploadingDetailed.
  ///
  /// In en, this message translates to:
  /// **'Uploading {title}. You will hear progress every 25 percent.'**
  String libraryUploadingDetailed(String title);

  /// No description provided for @libraryUploadingOnceDetailed.
  ///
  /// In en, this message translates to:
  /// **'Uploading {title}. Please wait; you will hear when it finishes.'**
  String libraryUploadingOnceDetailed(String title);

  /// percent e.g. "50 percent".
  ///
  /// In en, this message translates to:
  /// **'{title}: {percent} uploaded.'**
  String libraryUploadProgress(String title, String percent);

  /// No description provided for @libraryUploaded.
  ///
  /// In en, this message translates to:
  /// **'{title} uploaded.'**
  String libraryUploaded(String title);

  /// No description provided for @libraryUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'{title} could not be uploaded. Check your connection, then press 3 to try again.'**
  String libraryUploadFailed(String title);

  /// No description provided for @libraryUploadNoSession.
  ///
  /// In en, this message translates to:
  /// **'Upload cancelled. Select at least one session, then press 3 to add audio again.'**
  String get libraryUploadNoSession;

  /// No description provided for @libraryUploadNoClass.
  ///
  /// In en, this message translates to:
  /// **'The session class and subject could not be determined.'**
  String get libraryUploadNoClass;

  /// No description provided for @libraryFileUnreadable.
  ///
  /// In en, this message translates to:
  /// **'Could not read the file. Choose it again.'**
  String get libraryFileUnreadable;

  /// No description provided for @libraryPreviewStopped.
  ///
  /// In en, this message translates to:
  /// **'Preview of {title} stopped.'**
  String libraryPreviewStopped(String title);

  /// No description provided for @libraryPreviewing.
  ///
  /// In en, this message translates to:
  /// **'Previewing {title} privately.'**
  String libraryPreviewing(String title);

  /// No description provided for @libraryPreviewFinished.
  ///
  /// In en, this message translates to:
  /// **'Preview finished.'**
  String get libraryPreviewFinished;

  /// No description provided for @libraryPreviewFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not play {title}. Check your connection and try again.'**
  String libraryPreviewFailed(String title);

  /// No description provided for @libraryNoActiveSession.
  ///
  /// In en, this message translates to:
  /// **'No active session.'**
  String get libraryNoActiveSession;

  /// No description provided for @librarySelectedForSession.
  ///
  /// In en, this message translates to:
  /// **'Selected {title} for the session.'**
  String librarySelectedForSession(String title);

  /// No description provided for @librarySelectFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not select the audio. Try again.'**
  String get librarySelectFailed;

  /// No description provided for @libraryClassPlayAccepted.
  ///
  /// In en, this message translates to:
  /// **'Class playback request accepted.'**
  String get libraryClassPlayAccepted;

  /// No description provided for @libraryClassPlayFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not start class playback. Try again.'**
  String get libraryClassPlayFailed;

  /// No description provided for @libraryClassPauseAccepted.
  ///
  /// In en, this message translates to:
  /// **'Class pause request accepted.'**
  String get libraryClassPauseAccepted;

  /// No description provided for @libraryClassPauseFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not pause class audio. Try again.'**
  String get libraryClassPauseFailed;

  /// No description provided for @libraryStopPreviewLabel.
  ///
  /// In en, this message translates to:
  /// **'Stop preview of {title} privately. Only you can hear this.'**
  String libraryStopPreviewLabel(String title);

  /// No description provided for @libraryPreviewLabel.
  ///
  /// In en, this message translates to:
  /// **'Preview {title} privately. Only you can hear this.'**
  String libraryPreviewLabel(String title);

  /// No description provided for @libraryBroadcastLabel.
  ///
  /// In en, this message translates to:
  /// **'Play {title} for everyone in the session'**
  String libraryBroadcastLabel(String title);

  /// No description provided for @libraryRecordingsSentence.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 recording.} other{{count} recordings.}}'**
  String libraryRecordingsSentence(int count);

  /// No description provided for @libraryPreviewingState.
  ///
  /// In en, this message translates to:
  /// **'Previewing {title}.'**
  String libraryPreviewingState(String title);

  /// No description provided for @libraryUploadInProgress.
  ///
  /// In en, this message translates to:
  /// **'Upload in progress.'**
  String get libraryUploadInProgress;

  /// No description provided for @libraryAccountChanged.
  ///
  /// In en, this message translates to:
  /// **'Your account changed. Open the library again.'**
  String get libraryAccountChanged;

  /// No description provided for @libraryNoUnfinished.
  ///
  /// In en, this message translates to:
  /// **'No unfinished lesson is saved for this account. Choose a recorded lesson to start learning.'**
  String get libraryNoUnfinished;

  /// No description provided for @libraryCannotCheckAccess.
  ///
  /// In en, this message translates to:
  /// **'Could not check lesson access. Connect to the internet and retry. Your saved progress is kept.'**
  String get libraryCannotCheckAccess;

  /// No description provided for @libraryUnfinishedUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Your unfinished lessons are not currently available in this library. Your saved progress and bookmarks are kept.'**
  String get libraryUnfinishedUnavailable;

  /// No description provided for @libraryOpeningNextUnfinished.
  ///
  /// In en, this message translates to:
  /// **'The most recent lesson is unavailable here. Opening your next most recent available unfinished lesson. Saved progress is kept.'**
  String get libraryOpeningNextUnfinished;

  /// No description provided for @libraryContinueFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open saved learning progress. Check storage, your connection, and sign-in, then retry.'**
  String get libraryContinueFailed;

  /// No description provided for @libraryNoActiveClassesNow.
  ///
  /// In en, this message translates to:
  /// **'No active classes right now. Press 3 for all audio files.'**
  String get libraryNoActiveClassesNow;

  /// No description provided for @libraryClassesLoaded.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 active class loaded.} other{{count} active classes loaded.}}'**
  String libraryClassesLoaded(int count);

  /// No description provided for @libraryClassesFailed.
  ///
  /// In en, this message translates to:
  /// **'{reason} Active classes could not be refreshed. Press 1 to retry. Saved downloads remain available.'**
  String libraryClassesFailed(String reason);

  /// No description provided for @libraryClassesLoading.
  ///
  /// In en, this message translates to:
  /// **'Classes are still loading. Try key 5 again shortly.'**
  String get libraryClassesLoading;

  /// No description provided for @libraryNoActiveClassesStaying.
  ///
  /// In en, this message translates to:
  /// **'There are no active classes. Staying in the audio library.'**
  String get libraryNoActiveClassesStaying;

  /// No description provided for @libraryFirstActiveClass.
  ///
  /// In en, this message translates to:
  /// **'{title}. First active class. Use D-pad up and down to browse active class sessions. Press OK to open the selected class recordings.'**
  String libraryFirstActiveClass(String title);

  /// No description provided for @libraryOpeningPlaylists.
  ///
  /// In en, this message translates to:
  /// **'Opening My Playlists. Playlist contents are private.'**
  String get libraryOpeningPlaylists;

  /// No description provided for @libraryClassLabel.
  ///
  /// In en, this message translates to:
  /// **'{title}. Class {index} of {count}'**
  String libraryClassLabel(String title, String index, String count);

  /// No description provided for @libraryLoadingActiveClasses.
  ///
  /// In en, this message translates to:
  /// **'Loading active classes.'**
  String get libraryLoadingActiveClasses;

  /// No description provided for @libraryActiveClassesSentence.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 active class.} other{{count} active classes.}}'**
  String libraryActiveClassesSentence(int count);

  /// No description provided for @libraryNoRecordingsFor.
  ///
  /// In en, this message translates to:
  /// **'No recordings yet for {where}.'**
  String libraryNoRecordingsFor(String where);

  /// No description provided for @libraryRecordingsLoadedFor.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 recording loaded for {where}.} other{{count} recordings loaded for {where}.}}'**
  String libraryRecordingsLoadedFor(int count, String where);

  /// No description provided for @libraryDownloadsReadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not read downloaded lessons. Press 1 to retry.'**
  String get libraryDownloadsReadFailed;

  /// No description provided for @libraryClassLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load recordings. Check your internet connection and sign-in, then press 1 to retry.'**
  String get libraryClassLoadFailed;

  /// No description provided for @libraryRetryAfter.
  ///
  /// In en, this message translates to:
  /// **'{reason} Press 1 to retry.'**
  String libraryRetryAfter(String reason);

  /// No description provided for @libraryDownloadedDescription.
  ///
  /// In en, this message translates to:
  /// **'Downloaded recording. Access renewal required after 30 days.'**
  String get libraryDownloadedDescription;

  /// No description provided for @libraryDownloadedHelp.
  ///
  /// In en, this message translates to:
  /// **'Downloaded lessons. Existing offline access is checked before playing.'**
  String get libraryDownloadedHelp;

  /// No description provided for @libraryOnlineHelp.
  ///
  /// In en, this message translates to:
  /// **'Audio Library. Online recordings require internet. Download lessons for offline playback.'**
  String get libraryOnlineHelp;

  /// No description provided for @librarySubjectChoice.
  ///
  /// In en, this message translates to:
  /// **'Subject: {name}, {index} of {count}'**
  String librarySubjectChoice(String name, String index, String count);

  /// choice e.g. "Subject: Science, 2 of 4".
  ///
  /// In en, this message translates to:
  /// **'{choice}. Press 2, or left and right, to change'**
  String librarySubjectLabel(String choice);

  /// No description provided for @librarySubjectFixed.
  ///
  /// In en, this message translates to:
  /// **'This library is already limited to one subject.'**
  String get librarySubjectFixed;

  /// No description provided for @libraryLength.
  ///
  /// In en, this message translates to:
  /// **'Length {time}'**
  String libraryLength(String time);

  /// No description provided for @libraryRecordingsInSubject.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 recording in {subject}.} other{{count} recordings in {subject}.}}'**
  String libraryRecordingsInSubject(int count, String subject);

  /// No description provided for @libraryNoTeacherPlaylists.
  ///
  /// In en, this message translates to:
  /// **'No playlists yet for {className}, {subject}. Press 2 to create one.'**
  String libraryNoTeacherPlaylists(String className, String subject);

  /// No description provided for @libraryTeacherPlaylistsLoaded.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 playlist loaded for {className}, {subject}.} other{{count} playlists loaded for {className}, {subject}.}}'**
  String libraryTeacherPlaylistsLoaded(
    int count,
    String className,
    String subject,
  );

  /// No description provided for @libraryPlaylistCreateFailed.
  ///
  /// In en, this message translates to:
  /// **'Playlist could not be created.'**
  String get libraryPlaylistCreateFailed;

  /// No description provided for @libraryNoMyPlaylists.
  ///
  /// In en, this message translates to:
  /// **'No playlists yet. Press 2 to create a private playlist.'**
  String get libraryNoMyPlaylists;

  /// No description provided for @libraryPrivatePlaylistCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 private playlist} other{{count} private playlists}}'**
  String libraryPrivatePlaylistCount(int count);

  /// No description provided for @libraryClassPlaylistCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 class playlist} other{{count} class playlists}}'**
  String libraryClassPlaylistCount(int count);

  /// e.g. "2 private playlists and 1 class playlist loaded."
  ///
  /// In en, this message translates to:
  /// **'{privatePlaylists} and {classPlaylists} loaded.'**
  String libraryMyPlaylistsLoaded(
    String privatePlaylists,
    String classPlaylists,
  );

  /// No description provided for @libraryPrivatePlaylistCreateFailed.
  ///
  /// In en, this message translates to:
  /// **'Private playlist could not be created.'**
  String get libraryPrivatePlaylistCreateFailed;

  /// No description provided for @libraryPlaylistsSentence.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 playlist.} other{{count} playlists.}}'**
  String libraryPlaylistsSentence(int count);

  /// No description provided for @libraryItemCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item} other{{count} items}}'**
  String libraryItemCount(int count);

  /// items e.g. "3 items"; state is the player state.
  ///
  /// In en, this message translates to:
  /// **'{title}. {items}. {state}.'**
  String libraryPlaylistLoaded(String title, String items, String state);

  /// place is the class and subject; items e.g. "3 items".
  ///
  /// In en, this message translates to:
  /// **'{title}. {place}. {items}. {state}.'**
  String libraryPlaylistLoadedWithPlace(
    String title,
    String place,
    String items,
    String state,
  );

  /// No description provided for @libraryPlaylistRefreshFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not refresh this playlist. Check your connection and try again. Existing playback and saved progress have not been changed.'**
  String get libraryPlaylistRefreshFailed;

  /// No description provided for @libraryPlaylistLessonGone.
  ///
  /// In en, this message translates to:
  /// **'The current lesson is no longer available in this playlist. Playback stopped. Your saved progress and bookmarks are kept.'**
  String get libraryPlaylistLessonGone;

  /// No description provided for @libraryNothingToAdd.
  ///
  /// In en, this message translates to:
  /// **'No eligible audio is available to add.'**
  String get libraryNothingToAdd;

  /// No description provided for @libraryAddedToPlaylist.
  ///
  /// In en, this message translates to:
  /// **'{title} added to the playlist.'**
  String libraryAddedToPlaylist(String title);

  /// No description provided for @libraryAddFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not add the audio. Check your connection and try again.'**
  String get libraryAddFailed;

  /// No description provided for @libraryItemUnavailable.
  ///
  /// In en, this message translates to:
  /// **'{title} is no longer available in your current class. You can remove it from this playlist.'**
  String libraryItemUnavailable(String title);

  /// No description provided for @libraryItemCannotPlay.
  ///
  /// In en, this message translates to:
  /// **'{title} is unavailable.'**
  String libraryItemCannotPlay(String title);

  /// announcement is a full sentence about the playing lesson.
  ///
  /// In en, this message translates to:
  /// **'{announcement} Item {index} of {count}.'**
  String libraryPlayingItem(String announcement, String index, String count);

  /// No description provided for @libraryPlaylistPlayFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not play this lesson. Check your connection and try again.'**
  String get libraryPlaylistPlayFailed;

  /// No description provided for @libraryPlaylistEmpty.
  ///
  /// In en, this message translates to:
  /// **'Playlist is empty.'**
  String get libraryPlaylistEmpty;

  /// No description provided for @libraryPlaylistEnded.
  ///
  /// In en, this message translates to:
  /// **'End of playlist. Playback stopped.'**
  String get libraryPlaylistEnded;

  /// No description provided for @libraryRenamed.
  ///
  /// In en, this message translates to:
  /// **'Playlist renamed to {title}.'**
  String libraryRenamed(String title);

  /// No description provided for @libraryRenameFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not rename the playlist. Check your connection and try again.'**
  String get libraryRenameFailed;

  /// No description provided for @libraryAlreadyFirst.
  ///
  /// In en, this message translates to:
  /// **'The selected item is already first.'**
  String get libraryAlreadyFirst;

  /// No description provided for @libraryAlreadyLast.
  ///
  /// In en, this message translates to:
  /// **'The selected item is already last.'**
  String get libraryAlreadyLast;

  /// No description provided for @libraryMoved.
  ///
  /// In en, this message translates to:
  /// **'{title} moved to position {position} of {count}.'**
  String libraryMoved(String title, String position, String count);

  /// No description provided for @libraryMoveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not move {title}. Check your connection and try again.'**
  String libraryMoveFailed(String title);

  /// No description provided for @libraryRemovedFromPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Removed {title} from {playlist}.'**
  String libraryRemovedFromPlaylist(String title, String playlist);

  /// No description provided for @libraryRemoveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not remove {title}. Check your connection and try again.'**
  String libraryRemoveFailed(String title);

  /// No description provided for @libraryRemoveItemQuestion.
  ///
  /// In en, this message translates to:
  /// **'Remove {title} from {playlist}? The recording itself is kept in the library.'**
  String libraryRemoveItemQuestion(String title, String playlist);

  /// No description provided for @libraryRemoveItemLabel.
  ///
  /// In en, this message translates to:
  /// **'Remove {title} from playlist, asks to confirm'**
  String libraryRemoveItemLabel(String title);

  /// No description provided for @libraryPublished.
  ///
  /// In en, this message translates to:
  /// **'{title} published to the class.'**
  String libraryPublished(String title);

  /// No description provided for @libraryReturnedToDraft.
  ///
  /// In en, this message translates to:
  /// **'{title} returned to draft.'**
  String libraryReturnedToDraft(String title);

  /// No description provided for @libraryChangeFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not change {title}. Check your connection and try again.'**
  String libraryChangeFailed(String title);

  /// No description provided for @libraryDeleted.
  ///
  /// In en, this message translates to:
  /// **'{title} deleted.'**
  String libraryDeleted(String title);

  /// No description provided for @libraryRestoredAsDraft.
  ///
  /// In en, this message translates to:
  /// **'{title} restored as a draft.'**
  String libraryRestoredAsDraft(String title);

  /// No description provided for @libraryArchived.
  ///
  /// In en, this message translates to:
  /// **'{title} archived.'**
  String libraryArchived(String title);

  /// No description provided for @libraryPlaylistIsEmpty.
  ///
  /// In en, this message translates to:
  /// **'The playlist is empty.'**
  String get libraryPlaylistIsEmpty;

  /// No description provided for @librarySelectedItem.
  ///
  /// In en, this message translates to:
  /// **'Selected item {selected} of {items}.'**
  String librarySelectedItem(String selected, String items);

  /// No description provided for @librarySelectedItemTitled.
  ///
  /// In en, this message translates to:
  /// **'Selected item {selected} of {items}, {title}.'**
  String librarySelectedItemTitled(String selected, String items, String title);

  /// No description provided for @libraryAlreadyOneSubject.
  ///
  /// In en, this message translates to:
  /// **'This library is already limited to one subject'**
  String get libraryAlreadyOneSubject;

  /// No description provided for @libraryNoLessonIsPlaying.
  ///
  /// In en, this message translates to:
  /// **'No lesson is playing.'**
  String get libraryNoLessonIsPlaying;

  /// No description provided for @libraryAddedToSession.
  ///
  /// In en, this message translates to:
  /// **'{title} added to this session.'**
  String libraryAddedToSession(String title);

  /// No description provided for @libraryPlaylistNotCreated.
  ///
  /// In en, this message translates to:
  /// **'Playlist could not be created'**
  String get libraryPlaylistNotCreated;

  /// No description provided for @libraryPrivatePlaylistNotCreated.
  ///
  /// In en, this message translates to:
  /// **'Private playlist could not be created'**
  String get libraryPrivatePlaylistNotCreated;

  /// No description provided for @libraryNoEligibleAudio.
  ///
  /// In en, this message translates to:
  /// **'No eligible audio is available to add'**
  String get libraryNoEligibleAudio;

  /// No description provided for @libraryAudioAddedToPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Audio added to playlist'**
  String get libraryAudioAddedToPlaylist;

  /// No description provided for @libraryUnavailable.
  ///
  /// In en, this message translates to:
  /// **'{title} is unavailable'**
  String libraryUnavailable(String title);

  /// No description provided for @libraryPlaylistRenamed.
  ///
  /// In en, this message translates to:
  /// **'Playlist renamed to {title}'**
  String libraryPlaylistRenamed(String title);

  /// No description provided for @libraryMovedTo.
  ///
  /// In en, this message translates to:
  /// **'{title} moved to position {position}'**
  String libraryMovedTo(String title, String position);

  /// No description provided for @libraryNoteRenamed.
  ///
  /// In en, this message translates to:
  /// **'Private note renamed.'**
  String get libraryNoteRenamed;

  /// No description provided for @downloadNoneYet.
  ///
  /// In en, this message translates to:
  /// **'No downloads yet. Press 2 to find recordings online.'**
  String get downloadNoneYet;

  /// No description provided for @downloadLessonCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 downloaded lesson} other{{count} downloaded lessons}}'**
  String downloadLessonCount(int count);

  /// No description provided for @downloadPartialCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 partial download} other{{count} partial downloads}}'**
  String downloadPartialCount(int count);

  /// lessons e.g. "2 downloaded lessons".
  ///
  /// In en, this message translates to:
  /// **'{lessons} ready to play.'**
  String downloadReadyToPlay(String lessons);

  /// lessons e.g. "2 downloaded lessons"; partial e.g. "1 partial download".
  ///
  /// In en, this message translates to:
  /// **'{lessons} ready to play, {partial}.'**
  String downloadReadyToPlayWithPartial(String lessons, String partial);

  /// No description provided for @downloadActionFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not complete this download action. Check storage, your connection and sign-in, then retry.'**
  String get downloadActionFailed;

  /// No description provided for @downloadOnlineListFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load available recordings. Existing downloads still work until their access expires.'**
  String get downloadOnlineListFailed;

  /// No description provided for @downloadAvailable.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 recording is available to download. Select the recordings you want.} other{{count} recordings are available to download. Select the recordings you want.}}'**
  String downloadAvailable(int count);

  /// No description provided for @downloadStarting.
  ///
  /// In en, this message translates to:
  /// **'Downloading {title}. You will hear progress every 25 percent.'**
  String downloadStarting(String title);

  /// percent e.g. "50 percent".
  ///
  /// In en, this message translates to:
  /// **'{title} {percent} downloaded.'**
  String downloadProgress(String title, String percent);

  /// No description provided for @downloadVerified.
  ///
  /// In en, this message translates to:
  /// **'Download verified and saved for offline playback.'**
  String get downloadVerified;

  /// No description provided for @downloadDone.
  ///
  /// In en, this message translates to:
  /// **'{title} downloaded, verified and saved for offline playback.'**
  String downloadDone(String title);

  /// recordings e.g. "3 recordings".
  ///
  /// In en, this message translates to:
  /// **'Download {recordings} one at a time? This uses internet data and your account’s 50 MB allowance. On failure or cancellation, verified downloads and partial data are kept. No existing lesson is deleted.'**
  String downloadPackQuestion(String recordings);

  /// recordings e.g. "3 recordings".
  ///
  /// In en, this message translates to:
  /// **'Downloading {recordings}, one at a time.'**
  String downloadPackStarting(String recordings);

  /// No description provided for @downloadPackProgress.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} recordings verified.'**
  String downloadPackProgress(String done, String total);

  /// No description provided for @downloadPackDone.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} recordings verified and saved.'**
  String downloadPackDone(String done, String total);

  /// No description provided for @downloadRenewed.
  ///
  /// In en, this message translates to:
  /// **'Access renewed for {title}. Up to 30 days of offline playback.'**
  String downloadRenewed(String title);

  /// No description provided for @downloadRemoveTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove download of {title}?'**
  String downloadRemoveTitle(String title);

  /// No description provided for @downloadRemoveQuestion.
  ///
  /// In en, this message translates to:
  /// **'Remove the downloaded or partial audio for {title}? Learning progress and bookmarks are kept. Other recordings and accounts are not affected.'**
  String downloadRemoveQuestion(String title);

  /// No description provided for @downloadRemoved.
  ///
  /// In en, this message translates to:
  /// **'Removed the download of {title}. Progress and bookmarks kept.'**
  String downloadRemoved(String title);

  /// No description provided for @downloadUnreadableTitle.
  ///
  /// In en, this message translates to:
  /// **'unreadable recording {id}'**
  String downloadUnreadableTitle(String id);

  /// No description provided for @downloadRenewalRequired.
  ///
  /// In en, this message translates to:
  /// **'Access renewal required.'**
  String get downloadRenewalRequired;

  /// date e.g. "tomorrow at 10:30 in the morning".
  ///
  /// In en, this message translates to:
  /// **'Access expires {date}.'**
  String downloadAccessExpires(String date);

  /// size e.g. "12 megabytes"; expiry is a full sentence.
  ///
  /// In en, this message translates to:
  /// **'Play {title}. Downloaded. {size}. {expiry}'**
  String downloadPlayLabelComplete(String title, String size, String expiry);

  /// No description provided for @downloadPlayLabelPartial.
  ///
  /// In en, this message translates to:
  /// **'Play {title}. Partial download, cannot play yet. {size}. {expiry}'**
  String downloadPlayLabelPartial(String title, String size, String expiry);

  /// No description provided for @downloadRenewLabel.
  ///
  /// In en, this message translates to:
  /// **'Renew access for {title}. Requires internet'**
  String downloadRenewLabel(String title);

  /// No description provided for @downloadRemoveLabel.
  ///
  /// In en, this message translates to:
  /// **'Remove download of {title}, asks to confirm'**
  String downloadRemoveLabel(String title);

  /// No description provided for @downloadUnreadableLabel.
  ///
  /// In en, this message translates to:
  /// **'Unreadable download record {id}. Remove only this download, asks to confirm'**
  String downloadUnreadableLabel(String id);

  /// No description provided for @downloadOrResumeLabel.
  ///
  /// In en, this message translates to:
  /// **'Download or resume {title}'**
  String downloadOrResumeLabel(String title);

  /// No description provided for @downloadCancelLabel.
  ///
  /// In en, this message translates to:
  /// **'Cancel download of {title}, key 4. Keep partial data for retry'**
  String downloadCancelLabel(String title);

  /// No description provided for @downloadUnavailableWhileBusy.
  ///
  /// In en, this message translates to:
  /// **'{label} is unavailable while downloads are busy.'**
  String downloadUnavailableWhileBusy(String label);

  /// No description provided for @downloadStorageUnknown.
  ///
  /// In en, this message translates to:
  /// **'Storage reservation unavailable. Refresh downloads or remove the selected unreadable records before downloading.'**
  String get downloadStorageUnknown;

  /// No description provided for @downloadCountComma.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 download,} other{{count} downloads,}}'**
  String downloadCountComma(int count);

  /// No description provided for @downloadStorageUseUnknown.
  ///
  /// In en, this message translates to:
  /// **'storage use unknown.'**
  String get downloadStorageUseUnknown;

  /// No description provided for @downloadDownloadingStarting.
  ///
  /// In en, this message translates to:
  /// **'Downloading {title}, starting.'**
  String downloadDownloadingStarting(String title);

  /// No description provided for @downloadDownloadingPercent.
  ///
  /// In en, this message translates to:
  /// **'Downloading {title}, {percent}.'**
  String downloadDownloadingPercent(String title, String percent);

  /// No description provided for @downloadScreenLoaded.
  ///
  /// In en, this message translates to:
  /// **'{complete} downloaded lessons ready to play.'**
  String downloadScreenLoaded(String complete);

  /// No description provided for @downloadScreenLoadedWithPartial.
  ///
  /// In en, this message translates to:
  /// **'{complete} downloaded lessons ready to play, {partial} partial downloads.'**
  String downloadScreenLoadedWithPartial(String complete, String partial);

  /// No description provided for @downloadAvailableCount.
  ///
  /// In en, this message translates to:
  /// **'{count} recordings are available to download. Select the recordings you want.'**
  String downloadAvailableCount(String count);

  /// Name used when a recording title is unknown.
  ///
  /// In en, this message translates to:
  /// **'Recording {id}'**
  String downloadRecordingFallback(String id);

  /// No description provided for @downloadPackDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Download listed recordings?'**
  String get downloadPackDialogTitle;

  /// No description provided for @downloadPackDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'Download {count} listed recordings one at a time? This uses internet data and your account’s 50 MB allowance. On failure or cancellation, verified downloads and partial data are kept. No existing lesson is deleted.'**
  String downloadPackDialogMessage(String count);

  /// Button label.
  ///
  /// In en, this message translates to:
  /// **'Download listed'**
  String get downloadPackConfirm;

  /// Button label.
  ///
  /// In en, this message translates to:
  /// **'Choose individually'**
  String get downloadPackCancel;

  /// Button label.
  ///
  /// In en, this message translates to:
  /// **'Remove download'**
  String get downloadRemoveConfirm;

  /// Button label.
  ///
  /// In en, this message translates to:
  /// **'Keep download'**
  String get downloadKeep;

  /// No description provided for @downloadScreenName.
  ///
  /// In en, this message translates to:
  /// **'Downloaded Lessons'**
  String get downloadScreenName;

  /// No description provided for @downloadCancelBackTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel download and go back?'**
  String get downloadCancelBackTitle;

  /// No description provided for @downloadCancelBackMessage.
  ///
  /// In en, this message translates to:
  /// **'Stop this download? Verified recordings and partial data are kept for an explicit retry.'**
  String get downloadCancelBackMessage;

  /// Button label.
  ///
  /// In en, this message translates to:
  /// **'Cancel and go back'**
  String get downloadCancelBackConfirm;

  /// Button label.
  ///
  /// In en, this message translates to:
  /// **'Keep downloading'**
  String get downloadKeepDownloading;

  /// megabytes is a decimal number such as 12.50.
  ///
  /// In en, this message translates to:
  /// **'{megabytes} of 50 MB reserved for this account.'**
  String downloadReserved(String megabytes);

  /// No description provided for @downloadBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get downloadBack;

  /// No description provided for @downloadRefreshLabel.
  ///
  /// In en, this message translates to:
  /// **'Refresh saved downloads, key 1'**
  String get downloadRefreshLabel;

  /// No description provided for @downloadFindOnlineLabel.
  ///
  /// In en, this message translates to:
  /// **'Find recordings to download, key 2. Requires internet'**
  String get downloadFindOnlineLabel;

  /// No description provided for @downloadReadStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Read download status, key 3'**
  String get downloadReadStatusLabel;

  /// No description provided for @downloadPlayDownloadedLabel.
  ///
  /// In en, this message translates to:
  /// **'Play {title}. Downloaded'**
  String downloadPlayDownloadedLabel(String title);

  /// No description provided for @downloadPlayPartialLabel.
  ///
  /// In en, this message translates to:
  /// **'Play {title}. Partial download, cannot play yet'**
  String downloadPlayPartialLabel(String title);

  /// No description provided for @downloadPackLabel.
  ///
  /// In en, this message translates to:
  /// **'Download all listed recordings, key 5, asks to confirm'**
  String get downloadPackLabel;

  /// No description provided for @downloadIntroduction.
  ///
  /// In en, this message translates to:
  /// **'50 MB per account. Up to 30 days offline before online access renewal. Files and progress stay separate.'**
  String get downloadIntroduction;

  /// No description provided for @downloadNavigationSections.
  ///
  /// In en, this message translates to:
  /// **'saved files to play, renew or remove, and online recordings to download or resume'**
  String get downloadNavigationSections;

  /// No description provided for @downloadKeyRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh downloads'**
  String get downloadKeyRefresh;

  /// No description provided for @downloadKeyFindOnline.
  ///
  /// In en, this message translates to:
  /// **'Find recordings online'**
  String get downloadKeyFindOnline;

  /// No description provided for @downloadKeyReadStatus.
  ///
  /// In en, this message translates to:
  /// **'Read status'**
  String get downloadKeyReadStatus;

  /// No description provided for @downloadKeyCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel download'**
  String get downloadKeyCancel;

  /// No description provided for @downloadKeyPack.
  ///
  /// In en, this message translates to:
  /// **'Download listed recordings'**
  String get downloadKeyPack;

  /// No description provided for @downloadErrInvalidInfo.
  ///
  /// In en, this message translates to:
  /// **'Download information is invalid or belongs to a different account. Existing files are kept.'**
  String get downloadErrInvalidInfo;

  /// No description provided for @downloadErrSignInToOpen.
  ///
  /// In en, this message translates to:
  /// **'Sign in before opening downloaded lessons.'**
  String get downloadErrSignInToOpen;

  /// No description provided for @downloadErrAccountChanged.
  ///
  /// In en, this message translates to:
  /// **'Your account changed. Open Downloads again.'**
  String get downloadErrAccountChanged;

  /// No description provided for @downloadErrNoStorage.
  ///
  /// In en, this message translates to:
  /// **'Download storage is unavailable on this device.'**
  String get downloadErrNoStorage;

  /// No description provided for @downloadErrStorageUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Download storage is unavailable. Check free space and retry. Existing files have not been intentionally removed.'**
  String get downloadErrStorageUnavailable;

  /// No description provided for @downloadErrRecordsUnreadable.
  ///
  /// In en, this message translates to:
  /// **'Download records could not be read. Existing files are kept.'**
  String get downloadErrRecordsUnreadable;

  /// No description provided for @downloadErrRecordUnreadable.
  ///
  /// In en, this message translates to:
  /// **'A download record could not be read. Existing files are kept.'**
  String get downloadErrRecordUnreadable;

  /// No description provided for @downloadErrIdentityMismatch.
  ///
  /// In en, this message translates to:
  /// **'Download identity does not match its record.'**
  String get downloadErrIdentityMismatch;

  /// No description provided for @downloadErrSignInToRenew.
  ///
  /// In en, this message translates to:
  /// **'Sign in online before renewing download access.'**
  String get downloadErrSignInToRenew;

  /// No description provided for @downloadErrSignInChanged.
  ///
  /// In en, this message translates to:
  /// **'Your sign-in changed. Open Downloads again.'**
  String get downloadErrSignInChanged;

  /// No description provided for @downloadErrAccessNotConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Recording access is no longer confirmed for this account. Reconnect and sign in to renew. The saved file is kept.'**
  String get downloadErrAccessNotConfirmed;

  /// No description provided for @downloadErrTooLarge.
  ///
  /// In en, this message translates to:
  /// **'This recording is larger than the 50 MB download limit.'**
  String get downloadErrTooLarge;

  /// No description provided for @downloadErrRenewServer.
  ///
  /// In en, this message translates to:
  /// **'The server could not renew this recording. Try again later.'**
  String get downloadErrRenewServer;

  /// No description provided for @downloadErrInvalidServerInfo.
  ///
  /// In en, this message translates to:
  /// **'The server returned invalid download information.'**
  String get downloadErrInvalidServerInfo;

  /// No description provided for @downloadErrDifferentRecording.
  ///
  /// In en, this message translates to:
  /// **'The server returned a different recording.'**
  String get downloadErrDifferentRecording;

  /// No description provided for @downloadErrTimedOut.
  ///
  /// In en, this message translates to:
  /// **'The connection timed out. Reconnect and retry.'**
  String get downloadErrTimedOut;

  /// No description provided for @downloadErrRenewConnect.
  ///
  /// In en, this message translates to:
  /// **'Could not connect to renew this recording. Check your internet connection.'**
  String get downloadErrRenewConnect;

  /// No description provided for @downloadErrClockUnreadable.
  ///
  /// In en, this message translates to:
  /// **'The offline time record could not be read. Connect and renew access.'**
  String get downloadErrClockUnreadable;

  /// No description provided for @downloadErrClockBackwards.
  ///
  /// In en, this message translates to:
  /// **'The phone clock moved backwards. Correct its date and reconnect to renew access.'**
  String get downloadErrClockBackwards;

  /// No description provided for @downloadErrExpired.
  ///
  /// In en, this message translates to:
  /// **'Offline access expired after 30 days. Connect to the internet and renew this lesson. Your progress and downloaded file are kept.'**
  String get downloadErrExpired;

  /// No description provided for @downloadErrIncompleteForPlayback.
  ///
  /// In en, this message translates to:
  /// **'Download this lesson completely before offline playback.'**
  String get downloadErrIncompleteForPlayback;

  /// No description provided for @downloadErrRenewalRequired.
  ///
  /// In en, this message translates to:
  /// **'Access renewal is required. Connect and renew before playing this download.'**
  String get downloadErrRenewalRequired;

  /// No description provided for @downloadErrDamaged.
  ///
  /// In en, this message translates to:
  /// **'The downloaded recording is incomplete or damaged. Remove this download and download it again. Progress and bookmarks are separate.'**
  String get downloadErrDamaged;

  /// No description provided for @downloadErrDownloadFirst.
  ///
  /// In en, this message translates to:
  /// **'Download this lesson first.'**
  String get downloadErrDownloadFirst;

  /// No description provided for @downloadErrRecordingChangedRenew.
  ///
  /// In en, this message translates to:
  /// **'This recording has changed. Remove its download and download the current recording. Progress and bookmarks are kept.'**
  String get downloadErrRecordingChangedRenew;

  /// No description provided for @downloadErrCancelledAnyPartial.
  ///
  /// In en, this message translates to:
  /// **'Download cancelled. Any partial file is kept for an explicit retry.'**
  String get downloadErrCancelledAnyPartial;

  /// No description provided for @downloadErrRecordingChanged.
  ///
  /// In en, this message translates to:
  /// **'The recording changed. Remove its old download before downloading the current version. Progress is kept.'**
  String get downloadErrRecordingChanged;

  /// No description provided for @downloadErrSavedDamaged.
  ///
  /// In en, this message translates to:
  /// **'The saved recording is damaged. Remove its download before retrying.'**
  String get downloadErrSavedDamaged;

  /// No description provided for @downloadErrQuota.
  ///
  /// In en, this message translates to:
  /// **'Your account has reached its 50 MB download limit. Choose which of your downloads to remove, then retry. Nothing was deleted.'**
  String get downloadErrQuota;

  /// No description provided for @downloadErrPartialInvalid.
  ///
  /// In en, this message translates to:
  /// **'The partial download is invalid. Remove it before retrying.'**
  String get downloadErrPartialInvalid;

  /// No description provided for @downloadErrIntegrityPartial.
  ///
  /// In en, this message translates to:
  /// **'Download integrity check failed. Remove this partial download before retrying.'**
  String get downloadErrIntegrityPartial;

  /// No description provided for @downloadErrSignInToDownload.
  ///
  /// In en, this message translates to:
  /// **'Sign in before downloading.'**
  String get downloadErrSignInToDownload;

  /// No description provided for @downloadErrCancelledExplicit.
  ///
  /// In en, this message translates to:
  /// **'Download cancelled. Partial data is kept for an explicit retry.'**
  String get downloadErrCancelledExplicit;

  /// No description provided for @downloadErrAccessDenied.
  ///
  /// In en, this message translates to:
  /// **'Download access was denied. Reconnect and renew access.'**
  String get downloadErrAccessDenied;

  /// No description provided for @downloadErrUnexpectedPartial.
  ///
  /// In en, this message translates to:
  /// **'The server returned an unexpected partial recording. Retry without deleting existing data.'**
  String get downloadErrUnexpectedPartial;

  /// No description provided for @downloadErrCouldNotDownload.
  ///
  /// In en, this message translates to:
  /// **'The recording could not be downloaded. Check your connection and retry.'**
  String get downloadErrCouldNotDownload;

  /// No description provided for @downloadErrSizeChanged.
  ///
  /// In en, this message translates to:
  /// **'The recording size changed. Retry downloading.'**
  String get downloadErrSizeChanged;

  /// No description provided for @downloadErrAccountChangedStopped.
  ///
  /// In en, this message translates to:
  /// **'Your account changed. The download was stopped.'**
  String get downloadErrAccountChangedStopped;

  /// No description provided for @downloadErrExceededSize.
  ///
  /// In en, this message translates to:
  /// **'The recording exceeded its declared size. Download stopped.'**
  String get downloadErrExceededSize;

  /// No description provided for @downloadErrIntegrity.
  ///
  /// In en, this message translates to:
  /// **'Download integrity check failed. Retry an incomplete download, or remove damaged partial data before retrying.'**
  String get downloadErrIntegrity;

  /// No description provided for @downloadErrSignInChangedStopped.
  ///
  /// In en, this message translates to:
  /// **'Your sign-in changed. Download stopped before installation.'**
  String get downloadErrSignInChangedStopped;

  /// No description provided for @downloadErrTimedOutPartial.
  ///
  /// In en, this message translates to:
  /// **'Download timed out. Partial data is kept; activate Download to retry.'**
  String get downloadErrTimedOutPartial;

  /// No description provided for @downloadErrCancelledRetry.
  ///
  /// In en, this message translates to:
  /// **'Download cancelled. Partial data is kept for retry.'**
  String get downloadErrCancelledRetry;

  /// No description provided for @downloadErrInterrupted.
  ///
  /// In en, this message translates to:
  /// **'Download interrupted. Partial data is kept; activate Download to retry.'**
  String get downloadErrInterrupted;

  /// No description provided for @libraryErrStorageUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Learning storage is unavailable on this device. Your existing data has not been changed.'**
  String get libraryErrStorageUnavailable;

  /// No description provided for @libraryErrStorageNotOpened.
  ///
  /// In en, this message translates to:
  /// **'Learning storage could not be opened. Check free space and retry.'**
  String get libraryErrStorageNotOpened;

  /// No description provided for @libraryErrNoStorageLocation.
  ///
  /// In en, this message translates to:
  /// **'This device did not provide a learning storage location. Your existing data has not been changed.'**
  String get libraryErrNoStorageLocation;

  /// No description provided for @libraryErrStartLessonFirst.
  ///
  /// In en, this message translates to:
  /// **'Start a lesson before retrying progress saving.'**
  String get libraryErrStartLessonFirst;

  /// No description provided for @libraryErrProgressNotSaved.
  ///
  /// In en, this message translates to:
  /// **'Learning progress was not saved. Retry when storage is available.'**
  String get libraryErrProgressNotSaved;

  /// No description provided for @libraryErrChoosePosition.
  ///
  /// In en, this message translates to:
  /// **'Choose a position within the lesson'**
  String get libraryErrChoosePosition;

  /// No description provided for @libraryErrChooseSpeed.
  ///
  /// In en, this message translates to:
  /// **'Choose a playback speed from 0.25 to 3'**
  String get libraryErrChooseSpeed;

  /// No description provided for @libraryErrChooseBookmarkPosition.
  ///
  /// In en, this message translates to:
  /// **'Choose a bookmark position within the lesson'**
  String get libraryErrChooseBookmarkPosition;

  /// No description provided for @libraryErrBookmarkNotSaved.
  ///
  /// In en, this message translates to:
  /// **'Progress saving is unavailable. The bookmark was not saved.'**
  String get libraryErrBookmarkNotSaved;

  /// No description provided for @libraryErrBookmarkChangesUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Bookmark changes are unavailable until progress saving is restored.'**
  String get libraryErrBookmarkChangesUnavailable;

  /// No description provided for @libraryErrRepeatNotSaved.
  ///
  /// In en, this message translates to:
  /// **'Progress saving is unavailable. Repeat points were not saved.'**
  String get libraryErrRepeatNotSaved;

  /// No description provided for @libraryErrSetRepeatFirst.
  ///
  /// In en, this message translates to:
  /// **'Set a start point and a later end point within this lesson first'**
  String get libraryErrSetRepeatFirst;

  /// No description provided for @libraryErrRepeatFailed.
  ///
  /// In en, this message translates to:
  /// **'Repeat playback failed. Pause and try again.'**
  String get libraryErrRepeatFailed;

  /// No description provided for @libraryScreenBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get libraryScreenBack;

  /// No description provided for @libraryScreenRefreshTarget.
  ///
  /// In en, this message translates to:
  /// **'Refresh audio files, key 1'**
  String get libraryScreenRefreshTarget;

  /// No description provided for @libraryScreenPauseSessionTarget.
  ///
  /// In en, this message translates to:
  /// **'Pause audio for the whole session, key 3'**
  String get libraryScreenPauseSessionTarget;

  /// No description provided for @libraryScreenUploadTarget.
  ///
  /// In en, this message translates to:
  /// **'Upload audio, key 2'**
  String get libraryScreenUploadTarget;

  /// Focus label for a recording that is previewing; title is the recording title.
  ///
  /// In en, this message translates to:
  /// **'Stop preview of {title} privately. Only you can hear this.'**
  String libraryScreenStopPreviewTarget(String title);

  /// Focus label to preview a recording; title is the recording title.
  ///
  /// In en, this message translates to:
  /// **'Preview {title} privately. Only you can hear this.'**
  String libraryScreenPreviewTarget(String title);

  /// No description provided for @libraryScreenBroadcastTarget.
  ///
  /// In en, this message translates to:
  /// **'Play {title} for everyone in the session'**
  String libraryScreenBroadcastTarget(String title);

  /// No description provided for @libraryScreenPreviewFinished.
  ///
  /// In en, this message translates to:
  /// **'Preview finished'**
  String get libraryScreenPreviewFinished;

  /// No description provided for @libraryScreenNoRecordings.
  ///
  /// In en, this message translates to:
  /// **'No recordings yet. Press 2 to upload audio.'**
  String get libraryScreenNoRecordings;

  /// No description provided for @libraryScreenRecordingsLoaded.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, other{{count} recordings loaded.}}'**
  String libraryScreenRecordingsLoaded(int count);

  /// No description provided for @libraryScreenLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load recordings. Check your internet connection, then press 1 to retry.'**
  String get libraryScreenLoadFailed;

  /// No description provided for @libraryScreenTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Title is required'**
  String get libraryScreenTitleRequired;

  /// No description provided for @libraryScreenUploadDialogName.
  ///
  /// In en, this message translates to:
  /// **'Upload audio'**
  String get libraryScreenUploadDialogName;

  /// No description provided for @libraryScreenEditTitleKey.
  ///
  /// In en, this message translates to:
  /// **'Edit Title'**
  String get libraryScreenEditTitleKey;

  /// No description provided for @libraryScreenEditDescriptionKey.
  ///
  /// In en, this message translates to:
  /// **'Edit Description'**
  String get libraryScreenEditDescriptionKey;

  /// No description provided for @libraryScreenUploadKey.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get libraryScreenUploadKey;

  /// No description provided for @libraryScreenCancelKey.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get libraryScreenCancelKey;

  /// No description provided for @libraryScreenTitleField.
  ///
  /// In en, this message translates to:
  /// **'Audio title, required'**
  String get libraryScreenTitleField;

  /// No description provided for @libraryScreenDescriptionField.
  ///
  /// In en, this message translates to:
  /// **'Audio description, optional'**
  String get libraryScreenDescriptionField;

  /// No description provided for @libraryScreenCancelUpload.
  ///
  /// In en, this message translates to:
  /// **'Cancel upload'**
  String get libraryScreenCancelUpload;

  /// No description provided for @libraryScreenPickFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to pick file'**
  String get libraryScreenPickFailed;

  /// No description provided for @libraryScreenChooseWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Choose a class and subject workspace on the Teacher Dashboard before uploading audio.'**
  String get libraryScreenChooseWorkspace;

  /// No description provided for @libraryScreenUploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading {title}. You will hear progress every 25 percent.'**
  String libraryScreenUploading(String title);

  /// No description provided for @libraryScreenUploaded.
  ///
  /// In en, this message translates to:
  /// **'{title} uploaded.'**
  String libraryScreenUploaded(String title);

  /// No description provided for @libraryScreenUploadProgress.
  ///
  /// In en, this message translates to:
  /// **'{title}: {percent} percent uploaded.'**
  String libraryScreenUploadProgress(String title, String percent);

  /// No description provided for @libraryScreenPreviewStopped.
  ///
  /// In en, this message translates to:
  /// **'Preview of {title} stopped'**
  String libraryScreenPreviewStopped(String title);

  /// No description provided for @libraryScreenPreviewing.
  ///
  /// In en, this message translates to:
  /// **'Previewing {title} privately'**
  String libraryScreenPreviewing(String title);

  /// No description provided for @libraryScreenPlayFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not play {title}. Check your connection and try again.'**
  String libraryScreenPlayFailed(String title);

  /// No description provided for @libraryScreenNoActiveSession.
  ///
  /// In en, this message translates to:
  /// **'No active session'**
  String get libraryScreenNoActiveSession;

  /// No description provided for @libraryScreenSelectedForSession.
  ///
  /// In en, this message translates to:
  /// **'Selected {title} for session'**
  String libraryScreenSelectedForSession(String title);

  /// No description provided for @libraryScreenAudioSelectedTitle.
  ///
  /// In en, this message translates to:
  /// **'Audio Selected'**
  String get libraryScreenAudioSelectedTitle;

  /// No description provided for @libraryScreenPlayForEveryoneNow.
  ///
  /// In en, this message translates to:
  /// **'Play \"{title}\" for everyone in the session now?'**
  String libraryScreenPlayForEveryoneNow(String title);

  /// No description provided for @libraryScreenNotYet.
  ///
  /// In en, this message translates to:
  /// **'Not Yet'**
  String get libraryScreenNotYet;

  /// No description provided for @libraryScreenPlayNow.
  ///
  /// In en, this message translates to:
  /// **'Play Now'**
  String get libraryScreenPlayNow;

  /// No description provided for @libraryScreenSelectFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to select audio'**
  String get libraryScreenSelectFailed;

  /// No description provided for @libraryScreenPlaybackAccepted.
  ///
  /// In en, this message translates to:
  /// **'Class playback request accepted'**
  String get libraryScreenPlaybackAccepted;

  /// No description provided for @libraryScreenPlaybackFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to start playback'**
  String get libraryScreenPlaybackFailed;

  /// No description provided for @libraryScreenPauseAccepted.
  ///
  /// In en, this message translates to:
  /// **'Class pause request accepted'**
  String get libraryScreenPauseAccepted;

  /// No description provided for @libraryScreenPauseFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to pause audio'**
  String get libraryScreenPauseFailed;

  /// No description provided for @libraryScreenAudioLibraryName.
  ///
  /// In en, this message translates to:
  /// **'Audio library'**
  String get libraryScreenAudioLibraryName;

  /// No description provided for @libraryScreenAudioLibrarySections.
  ///
  /// In en, this message translates to:
  /// **'recordings, playback and speech controls, recording sharing, and upload tools when available'**
  String get libraryScreenAudioLibrarySections;

  /// No description provided for @libraryScreenRefreshKey.
  ///
  /// In en, this message translates to:
  /// **'Refresh Audio Files'**
  String get libraryScreenRefreshKey;

  /// No description provided for @libraryScreenUploadAudioKey.
  ///
  /// In en, this message translates to:
  /// **'Upload Audio'**
  String get libraryScreenUploadAudioKey;

  /// No description provided for @libraryScreenPauseSessionKey.
  ///
  /// In en, this message translates to:
  /// **'Pause Session Audio'**
  String get libraryScreenPauseSessionKey;

  /// No description provided for @libraryScreenBrowseTarget.
  ///
  /// In en, this message translates to:
  /// **'Focus first active class. Use D-pad to browse active sessions'**
  String get libraryScreenBrowseTarget;

  /// No description provided for @libraryScreenRefreshClassesTarget.
  ///
  /// In en, this message translates to:
  /// **'Refresh classes'**
  String get libraryScreenRefreshClassesTarget;

  /// No description provided for @libraryScreenSearchClassField.
  ///
  /// In en, this message translates to:
  /// **'Search class by name'**
  String get libraryScreenSearchClassField;

  /// No description provided for @libraryScreenSearchTarget.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get libraryScreenSearchTarget;

  /// No description provided for @libraryScreenAllRecordedTarget.
  ///
  /// In en, this message translates to:
  /// **'All recorded audio files'**
  String get libraryScreenAllRecordedTarget;

  /// No description provided for @libraryScreenContinueTarget.
  ///
  /// In en, this message translates to:
  /// **'Continue learning. Find your last unfinished recorded lesson'**
  String get libraryScreenContinueTarget;

  /// No description provided for @libraryScreenDownloadsTarget.
  ///
  /// In en, this message translates to:
  /// **'Downloaded lessons. Open saved recordings without loading online lists'**
  String get libraryScreenDownloadsTarget;

  /// No description provided for @libraryScreenNotesTarget.
  ///
  /// In en, this message translates to:
  /// **'Private notes and teacher recording drafts. Works from local storage'**
  String get libraryScreenNotesTarget;

  /// No description provided for @libraryScreenMyPlaylistsTarget.
  ///
  /// In en, this message translates to:
  /// **'My private playlists'**
  String get libraryScreenMyPlaylistsTarget;

  /// Focus label for an active class; title is the class/session name.
  ///
  /// In en, this message translates to:
  /// **'{title}. Class {position} of {total}'**
  String libraryScreenClassTarget(String title, String position, String total);

  /// No description provided for @libraryScreenAccountChanged.
  ///
  /// In en, this message translates to:
  /// **'Your account changed. Open the library again.'**
  String get libraryScreenAccountChanged;

  /// No description provided for @libraryScreenNoUnfinishedLesson.
  ///
  /// In en, this message translates to:
  /// **'No unfinished lesson is saved for this account. Choose a recorded lesson to start learning.'**
  String get libraryScreenNoUnfinishedLesson;

  /// No description provided for @libraryScreenAccessCheckFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not check lesson access. Connect to the internet and retry. Your saved progress is kept.'**
  String get libraryScreenAccessCheckFailed;

  /// No description provided for @libraryScreenUnfinishedUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Your unfinished lessons are not currently available in this library. Your saved progress and bookmarks are kept.'**
  String get libraryScreenUnfinishedUnavailable;

  /// No description provided for @libraryScreenOpeningNextUnfinished.
  ///
  /// In en, this message translates to:
  /// **'The most recent lesson is unavailable here. Opening your next most recent available unfinished lesson. Saved progress is kept.'**
  String get libraryScreenOpeningNextUnfinished;

  /// No description provided for @libraryScreenProgressOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open saved learning progress. Check storage, your connection, and sign-in, then retry.'**
  String get libraryScreenProgressOpenFailed;

  /// No description provided for @libraryScreenContinueLearningTitle.
  ///
  /// In en, this message translates to:
  /// **'Continue Learning'**
  String get libraryScreenContinueLearningTitle;

  /// No description provided for @libraryScreenNoActiveClasses.
  ///
  /// In en, this message translates to:
  /// **'No active classes right now. Press 3 for all audio files.'**
  String get libraryScreenNoActiveClasses;

  /// No description provided for @libraryScreenActiveClassesLoaded.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, other{{count} active classes loaded.}}'**
  String libraryScreenActiveClassesLoaded(int count);

  /// reason is a server/network failure sentence.
  ///
  /// In en, this message translates to:
  /// **'{reason} Active classes could not be refreshed. Press 1 to retry. Saved downloads remain available.'**
  String libraryScreenClassesRefreshFailed(String reason);

  /// No description provided for @libraryScreenClassListUnreadable.
  ///
  /// In en, this message translates to:
  /// **'The class list could not be read.'**
  String get libraryScreenClassListUnreadable;

  /// Name used for a class session that has no title.
  ///
  /// In en, this message translates to:
  /// **'Session'**
  String get libraryScreenSessionFallback;

  /// No description provided for @libraryScreenMyAudioLibraryTitle.
  ///
  /// In en, this message translates to:
  /// **'My Audio Library'**
  String get libraryScreenMyAudioLibraryTitle;

  /// No description provided for @libraryScreenAllAudioFilesTitle.
  ///
  /// In en, this message translates to:
  /// **'All Audio Files'**
  String get libraryScreenAllAudioFilesTitle;

  /// No description provided for @libraryScreenNoActiveClassesStaying.
  ///
  /// In en, this message translates to:
  /// **'There are no active classes. Staying in the audio library.'**
  String get libraryScreenNoActiveClassesStaying;

  /// No description provided for @libraryScreenFirstActiveClass.
  ///
  /// In en, this message translates to:
  /// **'{title}. First active class. Use D-pad up and down to browse active class sessions. Press OK to open the selected class recordings.'**
  String libraryScreenFirstActiveClass(String title);

  /// No description provided for @libraryScreenRecordedLibraryName.
  ///
  /// In en, this message translates to:
  /// **'Recorded Audio Library. Online lists require internet. Downloaded lessons open separately for offline playback.'**
  String get libraryScreenRecordedLibraryName;

  /// No description provided for @libraryScreenRecordedLibrarySections.
  ///
  /// In en, this message translates to:
  /// **'continue learning, saved downloads and private notes, class search, and active class sessions'**
  String get libraryScreenRecordedLibrarySections;

  /// No description provided for @libraryScreenMyPlaylistsKey.
  ///
  /// In en, this message translates to:
  /// **'My Private Playlists'**
  String get libraryScreenMyPlaylistsKey;

  /// No description provided for @libraryScreenWaitForPlayerNotes.
  ///
  /// In en, this message translates to:
  /// **'Wait for the recording player before opening study notes.'**
  String get libraryScreenWaitForPlayerNotes;

  /// No description provided for @libraryScreenStatusPlaying.
  ///
  /// In en, this message translates to:
  /// **'Playing'**
  String get libraryScreenStatusPlaying;

  /// No description provided for @libraryScreenStatusPaused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get libraryScreenStatusPaused;

  /// No description provided for @libraryScreenUntitled.
  ///
  /// In en, this message translates to:
  /// **'Untitled'**
  String get libraryScreenUntitled;

  /// Spoken when a recording has no subject name.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get libraryScreenSubjectFallback;

  /// No description provided for @libraryScreenDownloadedLessonsName.
  ///
  /// In en, this message translates to:
  /// **'Downloaded lessons. Existing offline access is checked before playing.'**
  String get libraryScreenDownloadedLessonsName;

  /// No description provided for @libraryScreenClassAudioName.
  ///
  /// In en, this message translates to:
  /// **'Audio Library. Online recordings require internet. Download lessons for offline playback.'**
  String get libraryScreenClassAudioName;

  /// No description provided for @libraryScreenLessonPositionTarget.
  ///
  /// In en, this message translates to:
  /// **'Lesson position {position}. Use left or right to move 10 seconds.'**
  String libraryScreenLessonPositionTarget(String position);

  /// No description provided for @libraryScreenBack10Target.
  ///
  /// In en, this message translates to:
  /// **'Back 10 seconds, key {key}'**
  String libraryScreenBack10Target(String key);

  /// No description provided for @libraryScreenPauseTarget.
  ///
  /// In en, this message translates to:
  /// **'Pause {title}, key {key}'**
  String libraryScreenPauseTarget(String title, String key);

  /// No description provided for @libraryScreenResumeTarget.
  ///
  /// In en, this message translates to:
  /// **'Resume {title}, key {key}'**
  String libraryScreenResumeTarget(String title, String key);

  /// Used in place of a lesson title when none is known, e.g. 'Pause lesson'.
  ///
  /// In en, this message translates to:
  /// **'lesson'**
  String get libraryScreenLessonFallback;

  /// No description provided for @libraryScreenForward10Target.
  ///
  /// In en, this message translates to:
  /// **'Forward 10 seconds, key {key}'**
  String libraryScreenForward10Target(String key);

  /// No description provided for @libraryScreenSlowerTarget.
  ///
  /// In en, this message translates to:
  /// **'Slower, key {key}. Now {speed} times'**
  String libraryScreenSlowerTarget(String key, String speed);

  /// No description provided for @libraryScreenStopTarget.
  ///
  /// In en, this message translates to:
  /// **'Stop {title}, key 8'**
  String libraryScreenStopTarget(String title);

  /// No description provided for @libraryScreenFasterTarget.
  ///
  /// In en, this message translates to:
  /// **'Faster, key {key}. Now {speed} times'**
  String libraryScreenFasterTarget(String key, String speed);

  /// No description provided for @libraryScreenDownloadsManageTarget.
  ///
  /// In en, this message translates to:
  /// **'Download lessons or manage saved recordings'**
  String get libraryScreenDownloadsManageTarget;

  /// No description provided for @libraryScreenStopSpeechTarget.
  ///
  /// In en, this message translates to:
  /// **'Stop speech'**
  String get libraryScreenStopSpeechTarget;

  /// No description provided for @libraryScreenUploadFirstTarget.
  ///
  /// In en, this message translates to:
  /// **'Upload first audio'**
  String get libraryScreenUploadFirstTarget;

  /// No description provided for @libraryScreenRefreshEmptyTarget.
  ///
  /// In en, this message translates to:
  /// **'Refresh empty audio library'**
  String get libraryScreenRefreshEmptyTarget;

  /// No description provided for @libraryScreenAddAudioTarget.
  ///
  /// In en, this message translates to:
  /// **'Add audio, key 3'**
  String get libraryScreenAddAudioTarget;

  /// Used as the lesson title when none is known.
  ///
  /// In en, this message translates to:
  /// **'Lesson'**
  String get libraryScreenLessonTitleFallback;

  /// No description provided for @libraryScreenDownloadedDescription.
  ///
  /// In en, this message translates to:
  /// **'Downloaded recording. Access renewal required after 30 days.'**
  String get libraryScreenDownloadedDescription;

  /// Name for a downloaded lesson's subject; id is a number.
  ///
  /// In en, this message translates to:
  /// **'Saved subject {id}'**
  String libraryScreenSavedSubject(String id);

  /// No description provided for @libraryScreenDownloadsReadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not read downloaded lessons. Press 1 to retry.'**
  String get libraryScreenDownloadsReadFailed;

  /// No description provided for @libraryScreenLoadFailedSignIn.
  ///
  /// In en, this message translates to:
  /// **'Could not load recordings. Check your internet connection and sign-in, then press 1 to retry.'**
  String get libraryScreenLoadFailedSignIn;

  /// name is a class/session name or library name.
  ///
  /// In en, this message translates to:
  /// **'No recordings yet for {name}.'**
  String libraryScreenNoRecordingsFor(String name);

  /// No description provided for @libraryScreenRecordingsLoadedFor.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, other{{count} recordings loaded for {name}.}}'**
  String libraryScreenRecordingsLoadedFor(int count, String name);

  /// No description provided for @libraryScreenLessonNoLongerAvailable.
  ///
  /// In en, this message translates to:
  /// **'This lesson is no longer available. Your saved progress and bookmarks are kept.'**
  String get libraryScreenLessonNoLongerAvailable;

  /// reason is an error sentence.
  ///
  /// In en, this message translates to:
  /// **'{reason} Press 1 to retry.'**
  String libraryScreenFailurePressRetry(String reason);

  /// No description provided for @libraryScreenSubjectNumber.
  ///
  /// In en, this message translates to:
  /// **'Subject {id}'**
  String libraryScreenSubjectNumber(String id);

  /// No description provided for @libraryScreenShowingAllSubjects.
  ///
  /// In en, this message translates to:
  /// **'Showing audio from all subjects'**
  String get libraryScreenShowingAllSubjects;

  /// No description provided for @libraryScreenShowingSubject.
  ///
  /// In en, this message translates to:
  /// **'Showing {subject} audio. {count} files'**
  String libraryScreenShowingSubject(String subject, String count);

  /// No description provided for @libraryScreenPausedAt.
  ///
  /// In en, this message translates to:
  /// **'Paused at {position}.'**
  String libraryScreenPausedAt(String position);

  /// No description provided for @libraryScreenCheckingOfflineAccess.
  ///
  /// In en, this message translates to:
  /// **'Internet unavailable. Checking your saved offline access.'**
  String get libraryScreenCheckingOfflineAccess;

  /// No description provided for @libraryScreenPlayFailedSelectAgain.
  ///
  /// In en, this message translates to:
  /// **'Could not play {title}. Check your connection, then select it again.'**
  String libraryScreenPlayFailedSelectAgain(String title);

  /// No description provided for @libraryScreenNothingPlaying.
  ///
  /// In en, this message translates to:
  /// **'Nothing is playing.'**
  String get libraryScreenNothingPlaying;

  /// No description provided for @libraryScreenTitleStopped.
  ///
  /// In en, this message translates to:
  /// **'{title} stopped.'**
  String libraryScreenTitleStopped(String title);

  /// No description provided for @libraryScreenNoLessonPlayingPress.
  ///
  /// In en, this message translates to:
  /// **'No lesson is playing. Press {key} to play the first lesson.'**
  String libraryScreenNoLessonPlayingPress(String key);

  /// No description provided for @libraryScreenSeekFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not move to that lesson position. Try again.'**
  String get libraryScreenSeekFailed;

  /// No description provided for @libraryScreenSlowestSpeed.
  ///
  /// In en, this message translates to:
  /// **'Already at the slowest speed.'**
  String get libraryScreenSlowestSpeed;

  /// No description provided for @libraryScreenFastestSpeed.
  ///
  /// In en, this message translates to:
  /// **'Already at the fastest speed.'**
  String get libraryScreenFastestSpeed;

  /// No description provided for @libraryScreenSpeedFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not change playback speed. Try again.'**
  String get libraryScreenSpeedFailed;

  /// No description provided for @libraryScreenReadFileFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to read file data.'**
  String get libraryScreenReadFileFailed;

  /// No description provided for @libraryScreenTitleFieldPlain.
  ///
  /// In en, this message translates to:
  /// **'Audio title'**
  String get libraryScreenTitleFieldPlain;

  /// No description provided for @libraryScreenChooseSessionsName.
  ///
  /// In en, this message translates to:
  /// **'Choose sessions for this audio'**
  String get libraryScreenChooseSessionsName;

  /// No description provided for @libraryScreenConfirmSessionsKey.
  ///
  /// In en, this message translates to:
  /// **'Confirm Selected Sessions'**
  String get libraryScreenConfirmSessionsKey;

  /// No description provided for @libraryScreenSessionNumber.
  ///
  /// In en, this message translates to:
  /// **'Session {id}'**
  String libraryScreenSessionNumber(String id);

  /// No description provided for @libraryScreenSessionSelected.
  ///
  /// In en, this message translates to:
  /// **'{name}, selected'**
  String libraryScreenSessionSelected(String name);

  /// No description provided for @libraryScreenSessionNotSelected.
  ///
  /// In en, this message translates to:
  /// **'{name}, not selected'**
  String libraryScreenSessionNotSelected(String name);

  /// No description provided for @libraryScreenConfirmSelectedSessions.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, other{Confirm {count} selected sessions}}'**
  String libraryScreenConfirmSelectedSessions(int count);

  /// No description provided for @libraryScreenUploadCancelledNoSession.
  ///
  /// In en, this message translates to:
  /// **'Upload cancelled. Select at least one session, then press 3 to add audio again.'**
  String get libraryScreenUploadCancelledNoSession;

  /// No description provided for @libraryScreenUploadingWait.
  ///
  /// In en, this message translates to:
  /// **'Uploading {title}. Please wait; you will hear when it finishes.'**
  String libraryScreenUploadingWait(String title);

  /// No description provided for @libraryScreenClassSubjectUnknown.
  ///
  /// In en, this message translates to:
  /// **'The session class and subject could not be determined'**
  String get libraryScreenClassSubjectUnknown;

  /// No description provided for @libraryScreenUploadFailedRetry.
  ///
  /// In en, this message translates to:
  /// **'{title} could not be uploaded. Check your connection, then press 3 to try again.'**
  String libraryScreenUploadFailedRetry(String title);

  /// Used as a recording title when none is known.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get libraryScreenAudioFallback;

  /// No description provided for @libraryScreenClassLibraryName.
  ///
  /// In en, this message translates to:
  /// **'Class Audio Library'**
  String get libraryScreenClassLibraryName;

  /// No description provided for @libraryScreenClassLibrarySections.
  ///
  /// In en, this message translates to:
  /// **'playback controls, bookmarks and learning progress, subject filter, downloads, recordings, and teacher upload tools when available'**
  String get libraryScreenClassLibrarySections;

  /// No description provided for @libraryScreenSubjectFilterField.
  ///
  /// In en, this message translates to:
  /// **'Subject filter (key 2)'**
  String get libraryScreenSubjectFilterField;

  /// No description provided for @libraryScreenAllSubjects.
  ///
  /// In en, this message translates to:
  /// **'All subjects'**
  String get libraryScreenAllSubjects;

  /// No description provided for @libraryScreenAddAudioOptionsName.
  ///
  /// In en, this message translates to:
  /// **'Add Audio Options'**
  String get libraryScreenAddAudioOptionsName;

  /// No description provided for @libraryScreenCloseAddAudioTarget.
  ///
  /// In en, this message translates to:
  /// **'Close add audio options'**
  String get libraryScreenCloseAddAudioTarget;

  /// No description provided for @libraryScreenUploadNewTarget.
  ///
  /// In en, this message translates to:
  /// **'Upload new file, key 1'**
  String get libraryScreenUploadNewTarget;

  /// No description provided for @libraryScreenSelectExistingTarget.
  ///
  /// In en, this message translates to:
  /// **'Select from existing library, key 2'**
  String get libraryScreenSelectExistingTarget;

  /// No description provided for @libraryScreenRecordingsAvailable.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, other{{count} recordings available.}}'**
  String libraryScreenRecordingsAvailable(int count);

  /// query is the user's search text.
  ///
  /// In en, this message translates to:
  /// **'No recordings match {query}.'**
  String libraryScreenNoRecordingsMatch(String query);

  /// No description provided for @libraryScreenRecordingsMatch.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, other{{count} recordings match {query}.}}'**
  String libraryScreenRecordingsMatch(int count, String query);

  /// No description provided for @libraryScreenNoUnlinkedRecordings.
  ///
  /// In en, this message translates to:
  /// **'No unlinked recordings available for this class.'**
  String get libraryScreenNoUnlinkedRecordings;

  /// No description provided for @libraryScreenRecordingsAvailableChoose.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, other{{count} recordings available. Use up and down to choose, or search by title.}}'**
  String libraryScreenRecordingsAvailableChoose(int count);

  /// No description provided for @libraryScreenAddFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not add {title}. Check your connection and try again.'**
  String libraryScreenAddFailed(String title);

  /// No description provided for @libraryScreenSelectExistingName.
  ///
  /// In en, this message translates to:
  /// **'Select Existing Audio'**
  String get libraryScreenSelectExistingName;

  /// No description provided for @libraryScreenSelectExistingSections.
  ///
  /// In en, this message translates to:
  /// **'search and every available recording'**
  String get libraryScreenSelectExistingSections;

  /// No description provided for @libraryScreenRefreshAvailableTarget.
  ///
  /// In en, this message translates to:
  /// **'Refresh available audio, key 1'**
  String get libraryScreenRefreshAvailableTarget;

  /// No description provided for @libraryScreenSearchRecordingsField.
  ///
  /// In en, this message translates to:
  /// **'Search recordings by title. Press OK to type'**
  String get libraryScreenSearchRecordingsField;

  /// No description provided for @libraryScreenSearchRecordingsWithQuery.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, other{Search recordings, {query}. {count} matches}}'**
  String libraryScreenSearchRecordingsWithQuery(String query, int count);

  /// No description provided for @libraryScreenAddToSessionTarget.
  ///
  /// In en, this message translates to:
  /// **'Add {title} to this session'**
  String libraryScreenAddToSessionTarget(String title);

  /// No description provided for @libraryScreenRepeatHelpTarget.
  ///
  /// In en, this message translates to:
  /// **'Repeat audio library help'**
  String get libraryScreenRepeatHelpTarget;

  /// No description provided for @playlistBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get playlistBack;

  /// No description provided for @playlistCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get playlistCancel;

  /// No description provided for @playlistCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get playlistCreate;

  /// No description provided for @playlistRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get playlistRefresh;

  /// No description provided for @playlistTeacherNone.
  ///
  /// In en, this message translates to:
  /// **'No playlists yet for {className}, {subject}. Press 2 to create one.'**
  String playlistTeacherNone(String className, String subject);

  /// No description provided for @playlistTeacherLoaded.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, other{{count} playlists}} loaded for {className}, {subject}'**
  String playlistTeacherLoaded(int count, String className, String subject);

  /// No description provided for @playlistCreateClassTitle.
  ///
  /// In en, this message translates to:
  /// **'Create class playlist'**
  String get playlistCreateClassTitle;

  /// No description provided for @playlistTitleField.
  ///
  /// In en, this message translates to:
  /// **'Playlist title'**
  String get playlistTitleField;

  /// No description provided for @playlistCancelCreation.
  ///
  /// In en, this message translates to:
  /// **'Cancel playlist creation'**
  String get playlistCancelCreation;

  /// No description provided for @playlistCreatePlaylist.
  ///
  /// In en, this message translates to:
  /// **'Create playlist'**
  String get playlistCreatePlaylist;

  /// Keypad key label for creating a playlist.
  ///
  /// In en, this message translates to:
  /// **'Create Playlist'**
  String get playlistCreatePlaylistKey;

  /// No description provided for @playlistRefreshPlaylists.
  ///
  /// In en, this message translates to:
  /// **'Refresh playlists'**
  String get playlistRefreshPlaylists;

  /// Spoken playlist entry: title, status (Published/Draft/Archived), number of items.
  ///
  /// In en, this message translates to:
  /// **'{title}. {status}. {count} items'**
  String playlistTeacherItemLabel(String title, String status, String count);

  /// No description provided for @playlistTeacherScreen.
  ///
  /// In en, this message translates to:
  /// **'Class Playlists, {className}, {subject}'**
  String playlistTeacherScreen(String className, String subject);

  /// No description provided for @playlistStatusArchived.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get playlistStatusArchived;

  /// No description provided for @playlistStatusPublished.
  ///
  /// In en, this message translates to:
  /// **'Published'**
  String get playlistStatusPublished;

  /// No description provided for @playlistStatusDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get playlistStatusDraft;

  /// No description provided for @playlistStudentNone.
  ///
  /// In en, this message translates to:
  /// **'No playlists yet. Press 2 to create a private playlist.'**
  String get playlistStudentNone;

  /// No description provided for @playlistStudentLoaded.
  ///
  /// In en, this message translates to:
  /// **'{privateCount, plural, other{{privateCount} private playlists}} and {classCount, plural, other{{classCount} class playlists}} loaded'**
  String playlistStudentLoaded(int privateCount, int classCount);

  /// No description provided for @playlistCreatePrivate.
  ///
  /// In en, this message translates to:
  /// **'Create private playlist'**
  String get playlistCreatePrivate;

  /// Keypad key label for creating a private playlist.
  ///
  /// In en, this message translates to:
  /// **'Create Private Playlist'**
  String get playlistCreatePrivateKey;

  /// No description provided for @playlistPrivateItemLabel.
  ///
  /// In en, this message translates to:
  /// **'{title}, private, {count} items'**
  String playlistPrivateItemLabel(String title, String count);

  /// No description provided for @playlistClassItemLabel.
  ///
  /// In en, this message translates to:
  /// **'{title}, class playlist, {subject}, {count} items'**
  String playlistClassItemLabel(String title, String subject, String count);

  /// No description provided for @playlistStudentScreen.
  ///
  /// In en, this message translates to:
  /// **'My Playlists. Private playlists are visible only to you.'**
  String get playlistStudentScreen;

  /// No description provided for @playlistWaitBeforeNotes.
  ///
  /// In en, this message translates to:
  /// **'Wait for the playlist player before opening study notes.'**
  String get playlistWaitBeforeNotes;

  /// No description provided for @playlistRefreshFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not refresh this playlist. Check your connection and try again. Existing playback and saved progress have not been changed.'**
  String get playlistRefreshFailed;

  /// No description provided for @playlistLessonGone.
  ///
  /// In en, this message translates to:
  /// **'The current lesson is no longer available in this playlist. Playback stopped. Your saved progress and bookmarks are kept.'**
  String get playlistLessonGone;

  /// No description provided for @playlistStateArchived.
  ///
  /// In en, this message translates to:
  /// **'archived'**
  String get playlistStateArchived;

  /// No description provided for @playlistStatePublished.
  ///
  /// In en, this message translates to:
  /// **'published'**
  String get playlistStatePublished;

  /// No description provided for @playlistStateDraft.
  ///
  /// In en, this message translates to:
  /// **'draft'**
  String get playlistStateDraft;

  /// No description provided for @playlistStatePrivate.
  ///
  /// In en, this message translates to:
  /// **'private'**
  String get playlistStatePrivate;

  /// No description provided for @playlistStatePublishedClass.
  ///
  /// In en, this message translates to:
  /// **'published class playlist'**
  String get playlistStatePublishedClass;

  /// Spoken when a playlist opens. state is one of the playlistState* messages.
  ///
  /// In en, this message translates to:
  /// **'{title}. {className} {subject}. {count, plural, other{{count} items}}. {state}.'**
  String playlistLoaded(
    String title,
    String className,
    String subject,
    int count,
    String state,
  );

  /// No description provided for @playlistAddAudioScreen.
  ///
  /// In en, this message translates to:
  /// **'Add audio to playlist'**
  String get playlistAddAudioScreen;

  /// No description provided for @playlistItemNoLongerAvailable.
  ///
  /// In en, this message translates to:
  /// **'{title} is no longer available in your current class. You can remove it from this playlist.'**
  String playlistItemNoLongerAvailable(String title);

  /// No description provided for @playlistItemPosition.
  ///
  /// In en, this message translates to:
  /// **'Item {index} of {total}.'**
  String playlistItemPosition(String index, String total);

  /// No description provided for @playlistPlayFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not play this lesson. Check your connection and try again.'**
  String get playlistPlayFailed;

  /// position is a spoken lesson position such as "2 minutes 5 seconds of 10 minutes".
  ///
  /// In en, this message translates to:
  /// **'Paused at {position}.'**
  String playlistPausedAt(String position);

  /// Fallback title for a lesson without a title.
  ///
  /// In en, this message translates to:
  /// **'Lesson'**
  String get playlistLessonDefault;

  /// No description provided for @playlistSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get playlistSave;

  /// No description provided for @playlistRenameScreen.
  ///
  /// In en, this message translates to:
  /// **'Rename playlist'**
  String get playlistRenameScreen;

  /// No description provided for @playlistCancelRename.
  ///
  /// In en, this message translates to:
  /// **'Cancel rename'**
  String get playlistCancelRename;

  /// No description provided for @playlistSaveTitle.
  ///
  /// In en, this message translates to:
  /// **'Save playlist title'**
  String get playlistSaveTitle;

  /// No description provided for @playlistAlreadyFirst.
  ///
  /// In en, this message translates to:
  /// **'The selected item is already first.'**
  String get playlistAlreadyFirst;

  /// No description provided for @playlistAlreadyLast.
  ///
  /// In en, this message translates to:
  /// **'The selected item is already last.'**
  String get playlistAlreadyLast;

  /// No description provided for @playlistMoveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not move {title}. Check your connection and try again.'**
  String playlistMoveFailed(String title);

  /// Fallback name used in place of a playlist title, e.g. "Remove X from this playlist?".
  ///
  /// In en, this message translates to:
  /// **'this playlist'**
  String get playlistThisPlaylist;

  /// No description provided for @playlistRemoveItemTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove {title}?'**
  String playlistRemoveItemTitle(String title);

  /// No description provided for @playlistRemoveItemMessage.
  ///
  /// In en, this message translates to:
  /// **'Remove {title} from {playlist}? The recording itself is kept in the library.'**
  String playlistRemoveItemMessage(String title, String playlist);

  /// Button label that cancels removing a recording.
  ///
  /// In en, this message translates to:
  /// **'Keep {title}'**
  String playlistKeepItem(String title);

  /// Button label that confirms removing a recording.
  ///
  /// In en, this message translates to:
  /// **'Remove {title}'**
  String playlistRemoveItem(String title);

  /// No description provided for @playlistRemoveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not remove {title}. Check your connection and try again.'**
  String playlistRemoveFailed(String title);

  /// No description provided for @playlistPublishedToClass.
  ///
  /// In en, this message translates to:
  /// **'{title} published to the class'**
  String playlistPublishedToClass(String title);

  /// No description provided for @playlistReturnedToDraft.
  ///
  /// In en, this message translates to:
  /// **'{title} returned to draft'**
  String playlistReturnedToDraft(String title);

  /// No description provided for @playlistChangeFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not change {title}. Check your connection and try again.'**
  String playlistChangeFailed(String title);

  /// No description provided for @playlistDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete {title}?'**
  String playlistDeleteTitle(String title);

  /// No description provided for @playlistRestoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore {title}?'**
  String playlistRestoreTitle(String title);

  /// No description provided for @playlistArchiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Archive {title}?'**
  String playlistArchiveTitle(String title);

  /// No description provided for @playlistDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'This removes the private playlist {title} and its ordered items. Recordings stay in the library.'**
  String playlistDeleteMessage(String title);

  /// No description provided for @playlistRestoreMessage.
  ///
  /// In en, this message translates to:
  /// **'This returns {title} to draft so it can be edited and published again.'**
  String playlistRestoreMessage(String title);

  /// No description provided for @playlistArchiveMessage.
  ///
  /// In en, this message translates to:
  /// **'Students will no longer see {title}. Teacher history is retained.'**
  String playlistArchiveMessage(String title);

  /// Button label.
  ///
  /// In en, this message translates to:
  /// **'Delete {title}'**
  String playlistDeleteConfirm(String title);

  /// Button label.
  ///
  /// In en, this message translates to:
  /// **'Restore {title}'**
  String playlistRestoreConfirm(String title);

  /// Button label.
  ///
  /// In en, this message translates to:
  /// **'Archive {title}'**
  String playlistArchiveConfirm(String title);

  /// No description provided for @playlistDeleted.
  ///
  /// In en, this message translates to:
  /// **'{title} deleted'**
  String playlistDeleted(String title);

  /// No description provided for @playlistRestoredDraft.
  ///
  /// In en, this message translates to:
  /// **'{title} restored as a draft'**
  String playlistRestoredDraft(String title);

  /// No description provided for @playlistArchived.
  ///
  /// In en, this message translates to:
  /// **'{title} archived'**
  String playlistArchived(String title);

  /// Used in place of a lesson title, e.g. "Play selected item, key 5".
  ///
  /// In en, this message translates to:
  /// **'selected item'**
  String get playlistSelectedItem;

  /// No description provided for @playlistSeekFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not move to that lesson position. Try again.'**
  String get playlistSeekFailed;

  /// No description provided for @playlistRefreshPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Refresh playlist'**
  String get playlistRefreshPlaylist;

  /// Used in place of a missing title in "Rename playlist".
  ///
  /// In en, this message translates to:
  /// **'playlist'**
  String get playlistWordPlaylist;

  /// No description provided for @playlistRenameLabel.
  ///
  /// In en, this message translates to:
  /// **'Rename {title}'**
  String playlistRenameLabel(String title);

  /// No description provided for @playlistAddAudioLabel.
  ///
  /// In en, this message translates to:
  /// **'Add audio, key 2'**
  String get playlistAddAudioLabel;

  /// No description provided for @playlistPauseLabel.
  ///
  /// In en, this message translates to:
  /// **'Pause {title}, key {key}'**
  String playlistPauseLabel(String title, String key);

  /// No description provided for @playlistPlayLabel.
  ///
  /// In en, this message translates to:
  /// **'Play {title}, key {key}'**
  String playlistPlayLabel(String title, String key);

  /// No description provided for @playlistPreviousLabel.
  ///
  /// In en, this message translates to:
  /// **'Previous item, key 3'**
  String get playlistPreviousLabel;

  /// No description provided for @playlistNextLabel.
  ///
  /// In en, this message translates to:
  /// **'Next item, key 8'**
  String get playlistNextLabel;

  /// No description provided for @playlistReturnToDraftLabel.
  ///
  /// In en, this message translates to:
  /// **'Return {title} to draft'**
  String playlistReturnToDraftLabel(String title);

  /// No description provided for @playlistPublishLabel.
  ///
  /// In en, this message translates to:
  /// **'Publish {title} to the class'**
  String playlistPublishLabel(String title);

  /// No description provided for @playlistRestoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Restore {title}'**
  String playlistRestoreLabel(String title);

  /// No description provided for @playlistArchiveLabel.
  ///
  /// In en, this message translates to:
  /// **'Archive {title}, asks to confirm'**
  String playlistArchiveLabel(String title);

  /// No description provided for @playlistDeleteLabel.
  ///
  /// In en, this message translates to:
  /// **'Delete {title}, asks to confirm'**
  String playlistDeleteLabel(String title);

  /// No description provided for @playlistSeekLabel.
  ///
  /// In en, this message translates to:
  /// **'Lesson position {position}. Use left or right to move 10 seconds'**
  String playlistSeekLabel(String position);

  /// No description provided for @playlistDownloadsLabel.
  ///
  /// In en, this message translates to:
  /// **'Download playlist recordings. Select individually or confirm all listed recordings'**
  String get playlistDownloadsLabel;

  /// No description provided for @playlistMoveUpLabel.
  ///
  /// In en, this message translates to:
  /// **'Move {title} up'**
  String playlistMoveUpLabel(String title);

  /// No description provided for @playlistMoveDownLabel.
  ///
  /// In en, this message translates to:
  /// **'Move {title} down'**
  String playlistMoveDownLabel(String title);

  /// No description provided for @playlistRemoveItemLabel.
  ///
  /// In en, this message translates to:
  /// **'Remove {title} from playlist, asks to confirm'**
  String playlistRemoveItemLabel(String title);

  /// No description provided for @playlistItemUnavailableInClass.
  ///
  /// In en, this message translates to:
  /// **'Unavailable in your current class'**
  String get playlistItemUnavailableInClass;

  /// No description provided for @playlistItemSelected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get playlistItemSelected;

  /// No description provided for @playlistItemPlaying.
  ///
  /// In en, this message translates to:
  /// **'Playing'**
  String get playlistItemPlaying;

  /// No description provided for @playlistItemSelectedPaused.
  ///
  /// In en, this message translates to:
  /// **'Selected, paused'**
  String get playlistItemSelectedPaused;

  /// Keypad key label.
  ///
  /// In en, this message translates to:
  /// **'Add Audio'**
  String get playlistAddAudioKey;

  /// No description provided for @playlistPreviousItem.
  ///
  /// In en, this message translates to:
  /// **'Previous item'**
  String get playlistPreviousItem;

  /// No description provided for @playlistNextItem.
  ///
  /// In en, this message translates to:
  /// **'Next item'**
  String get playlistNextItem;

  /// No description provided for @playlistScreenDefault.
  ///
  /// In en, this message translates to:
  /// **'Playlist'**
  String get playlistScreenDefault;

  /// Screen name; title is the playlist title.
  ///
  /// In en, this message translates to:
  /// **'{title} playlist'**
  String playlistScreen(String title);

  /// No description provided for @playlistItemUnavailable.
  ///
  /// In en, this message translates to:
  /// **'{title} is unavailable in your current class'**
  String playlistItemUnavailable(String title);

  /// No description provided for @notesNoRecordingActive.
  ///
  /// In en, this message translates to:
  /// **'No recording active.'**
  String get notesNoRecordingActive;

  /// No description provided for @notesMicCouldNotRecord.
  ///
  /// In en, this message translates to:
  /// **'The microphone could not record this note.'**
  String get notesMicCouldNotRecord;

  /// No description provided for @notesRecordingNotConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Recording could not be confirmed. Its partial files are kept. Check microphone permission and storage.'**
  String get notesRecordingNotConfirmed;

  /// No description provided for @notesLeaveLiveSession.
  ///
  /// In en, this message translates to:
  /// **'Leave the live session and open private notes before recording.'**
  String get notesLeaveLiveSession;

  /// No description provided for @notesMicPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Microphone permission was not granted. No recording started. Enable it in Android settings and retry.'**
  String get notesMicPermissionDenied;

  /// No description provided for @notesRecordingCancelledChanged.
  ///
  /// In en, this message translates to:
  /// **'Recording was cancelled because the screen or app changed. Start again when ready.'**
  String get notesRecordingCancelledChanged;

  /// No description provided for @notesSpeechDidNotStop.
  ///
  /// In en, this message translates to:
  /// **'App speech did not stop. Check the TTS engine before recording.'**
  String get notesSpeechDidNotStop;

  /// No description provided for @notesRecordingDidNotStart.
  ///
  /// In en, this message translates to:
  /// **'Recording did not start because the app changed. Its empty draft is kept for selected removal.'**
  String get notesRecordingDidNotStart;

  /// No description provided for @notesAnotherRecorderStopping.
  ///
  /// In en, this message translates to:
  /// **'Another private recorder is still stopping. Return to it or background the app before recording.'**
  String get notesAnotherRecorderStopping;

  /// No description provided for @notesNativeStartNotConfirmed.
  ///
  /// In en, this message translates to:
  /// **'The native recorder did not confirm starting. The draft is kept.'**
  String get notesNativeStartNotConfirmed;

  /// No description provided for @notesNativeStopNotConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Native recording stop was not confirmed. Background the app to stop capture before retrying.'**
  String get notesNativeStopNotConfirmed;

  /// No description provided for @notesDurationUnreadable.
  ///
  /// In en, this message translates to:
  /// **'The recorder duration was unreadable. Its incomplete file is kept.'**
  String get notesDurationUnreadable;

  /// No description provided for @notesRecordingInProgress.
  ///
  /// In en, this message translates to:
  /// **'Recording. Stop before speaking to app controls. Maximum five minutes; stops on app narration or interruption.'**
  String get notesRecordingInProgress;

  /// No description provided for @notesNativeCaptureStopped.
  ///
  /// In en, this message translates to:
  /// **'Native capture is stopped. Any unfinished draft is kept for selected removal.'**
  String get notesNativeCaptureStopped;

  /// No description provided for @notesRecorderStopNotConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Recorder stop was not confirmed. Leave this screen or background the app to stop native capture before retrying.'**
  String get notesRecorderStopNotConfirmed;

  /// No description provided for @notesRecorderFailed.
  ///
  /// In en, this message translates to:
  /// **'The recorder failed. Its incomplete file is retained for selected removal.'**
  String get notesRecorderFailed;

  /// No description provided for @notesNotFinalized.
  ///
  /// In en, this message translates to:
  /// **'Recording stopped, but the note could not be finalized. Files are kept for selected removal.'**
  String get notesNotFinalized;

  /// No description provided for @notesRecordingLimitReached.
  ///
  /// In en, this message translates to:
  /// **'Recording limit reached.'**
  String get notesRecordingLimitReached;

  /// No description provided for @notesRecordingInterrupted.
  ///
  /// In en, this message translates to:
  /// **'Recording interrupted.'**
  String get notesRecordingInterrupted;

  /// No description provided for @notesRecordingStopped.
  ///
  /// In en, this message translates to:
  /// **'Recording stopped.'**
  String get notesRecordingStopped;

  /// No description provided for @notesSavedOnPhone.
  ///
  /// In en, this message translates to:
  /// **'Private note saved on this phone. Review before publishing or sharing.'**
  String get notesSavedOnPhone;

  /// No description provided for @notesSignInFirst.
  ///
  /// In en, this message translates to:
  /// **'Sign in before opening private notes.'**
  String get notesSignInFirst;

  /// No description provided for @notesInvalidIdentity.
  ///
  /// In en, this message translates to:
  /// **'Invalid note identity.'**
  String get notesInvalidIdentity;

  /// No description provided for @notesAccountChanged.
  ///
  /// In en, this message translates to:
  /// **'Your account changed. Open private notes again.'**
  String get notesAccountChanged;

  /// No description provided for @notesStorageUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Private note storage is unavailable. Check free space and retry. Existing files are kept.'**
  String get notesStorageUnavailable;

  /// No description provided for @notesInvalidNameOrPosition.
  ///
  /// In en, this message translates to:
  /// **'Enter a note name of up to 160 characters and a valid lesson position.'**
  String get notesInvalidNameOrPosition;

  /// No description provided for @notesAllowanceFull.
  ///
  /// In en, this message translates to:
  /// **'Your private note allowance is full. Remove a chosen note before recording. No note was deleted.'**
  String get notesAllowanceFull;

  /// No description provided for @notesInterruptedOrInvalid.
  ///
  /// In en, this message translates to:
  /// **'The note was interrupted or its duration is invalid. Its files are retained for selected removal.'**
  String get notesInterruptedOrInvalid;

  /// No description provided for @notesEmptyOrTooLarge.
  ///
  /// In en, this message translates to:
  /// **'This recording is empty or exceeds the private-note allowance. Its partial file is kept; review storage and remove the selected recording.'**
  String get notesEmptyOrTooLarge;

  /// No description provided for @notesIncompleteUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This note is incomplete or unavailable. It has not been deleted.'**
  String get notesIncompleteUnavailable;

  /// No description provided for @notesInvalidName.
  ///
  /// In en, this message translates to:
  /// **'Enter a note name of up to 160 characters.'**
  String get notesInvalidName;

  /// Fallback title of a private note whose record cannot be read.
  ///
  /// In en, this message translates to:
  /// **'Unreadable note {id}'**
  String notesUnreadableTitle(String id);

  /// No description provided for @notesRecordUnreadable.
  ///
  /// In en, this message translates to:
  /// **'This note record cannot be read. Its files are kept; only explicit selected removal changes them.'**
  String get notesRecordUnreadable;

  /// Fallback title of a private note recording without metadata.
  ///
  /// In en, this message translates to:
  /// **'Interrupted recording {id}'**
  String notesInterruptedTitle(String id);

  /// No description provided for @notesMetadataMissing.
  ///
  /// In en, this message translates to:
  /// **'Recording metadata is missing. The file is retained for selected removal.'**
  String get notesMetadataMissing;

  /// No description provided for @learningSavedLessonInvalid.
  ///
  /// In en, this message translates to:
  /// **'Saved lesson information is invalid. Your saved data has not been changed.'**
  String get learningSavedLessonInvalid;

  /// No description provided for @learningSavedBookmarkUnreadable.
  ///
  /// In en, this message translates to:
  /// **'A saved bookmark could not be read. Your saved data has not been changed.'**
  String get learningSavedBookmarkUnreadable;

  /// No description provided for @learningSavedBookmarkIdsInvalid.
  ///
  /// In en, this message translates to:
  /// **'Saved bookmark identifiers are invalid. Your saved data has not been changed.'**
  String get learningSavedBookmarkIdsInvalid;

  /// No description provided for @learningSavedRepeatInvalid.
  ///
  /// In en, this message translates to:
  /// **'Saved repeat bounds are invalid. Your saved data has not been changed.'**
  String get learningSavedRepeatInvalid;

  /// No description provided for @learningSignInFirst.
  ///
  /// In en, this message translates to:
  /// **'Sign in before using saved learning progress.'**
  String get learningSignInFirst;

  /// No description provided for @learningAccountChanged.
  ///
  /// In en, this message translates to:
  /// **'Your account changed. Open the learning library again.'**
  String get learningAccountChanged;

  /// No description provided for @learningUnsupportedFormat.
  ///
  /// In en, this message translates to:
  /// **'Saved learning data has an unsupported format or account. Your saved data has not been changed.'**
  String get learningUnsupportedFormat;

  /// No description provided for @learningIdentityMismatch.
  ///
  /// In en, this message translates to:
  /// **'Saved lesson identity does not match. Your saved data has not been changed.'**
  String get learningIdentityMismatch;

  /// No description provided for @learningDataUnreadable.
  ///
  /// In en, this message translates to:
  /// **'Saved learning data could not be read. Your saved data has not been changed.'**
  String get learningDataUnreadable;

  /// No description provided for @learningStorageUnavailableFreeSpace.
  ///
  /// In en, this message translates to:
  /// **'Learning storage is unavailable. Check free space and retry. Your saved data has not been intentionally removed.'**
  String get learningStorageUnavailableFreeSpace;

  /// No description provided for @learningStorageUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Learning storage is unavailable. Check storage and retry.'**
  String get learningStorageUnavailable;

  /// No description provided for @learningSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Learning progress could not be saved. Check free space and retry.'**
  String get learningSaveFailed;

  /// No description provided for @learningProgressUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Saved learning progress is unavailable. Check storage and retry.'**
  String get learningProgressUnavailable;

  /// No description provided for @learningStartLessonFirst.
  ///
  /// In en, this message translates to:
  /// **'Start this lesson before adding bookmarks or repeat points.'**
  String get learningStartLessonFirst;

  /// No description provided for @learningSavedFieldUnreadable.
  ///
  /// In en, this message translates to:
  /// **'The saved {field} could not be read. Your saved data has not been changed.'**
  String learningSavedFieldUnreadable(String field);

  /// Data field name inserted into learningSavedFieldUnreadable.
  ///
  /// In en, this message translates to:
  /// **'bookmark id'**
  String get learningFieldBookmarkId;

  /// Data field name inserted into learningSavedFieldUnreadable.
  ///
  /// In en, this message translates to:
  /// **'bookmark label'**
  String get learningFieldBookmarkLabel;

  /// Data field name inserted into learningSavedFieldUnreadable.
  ///
  /// In en, this message translates to:
  /// **'bookmark position'**
  String get learningFieldBookmarkPosition;

  /// Data field name inserted into learningSavedFieldUnreadable.
  ///
  /// In en, this message translates to:
  /// **'update time'**
  String get learningFieldUpdateTime;

  /// Data field name inserted into learningSavedFieldUnreadable.
  ///
  /// In en, this message translates to:
  /// **'next bookmark id'**
  String get learningFieldNextBookmarkId;

  /// Data field name inserted into learningSavedFieldUnreadable.
  ///
  /// In en, this message translates to:
  /// **'lesson id'**
  String get learningFieldLessonId;

  /// Data field name inserted into learningSavedFieldUnreadable.
  ///
  /// In en, this message translates to:
  /// **'lesson title'**
  String get learningFieldLessonTitle;

  /// Data field name inserted into learningSavedFieldUnreadable.
  ///
  /// In en, this message translates to:
  /// **'position'**
  String get learningFieldPosition;

  /// No description provided for @learningInvalidProgress.
  ///
  /// In en, this message translates to:
  /// **'Invalid lesson progress'**
  String get learningInvalidProgress;

  /// No description provided for @learningBookmarkNeedsPositionLabel.
  ///
  /// In en, this message translates to:
  /// **'A bookmark needs a valid position and label'**
  String get learningBookmarkNeedsPositionLabel;

  /// No description provided for @learningBookmarkExceedsDuration.
  ///
  /// In en, this message translates to:
  /// **'Bookmark position exceeds lesson duration'**
  String get learningBookmarkExceedsDuration;

  /// Default name of a new lesson bookmark.
  ///
  /// In en, this message translates to:
  /// **'Bookmark {number}'**
  String learningDefaultBookmarkLabel(String number);

  /// No description provided for @learningBookmarkNotFound.
  ///
  /// In en, this message translates to:
  /// **'Bookmark not found'**
  String get learningBookmarkNotFound;

  /// No description provided for @learningRepeatEndAfterStart.
  ///
  /// In en, this message translates to:
  /// **'Set the end point after the start point'**
  String get learningRepeatEndAfterStart;

  /// No description provided for @learningRepeatExceedsDuration.
  ///
  /// In en, this message translates to:
  /// **'Repeat points exceed lesson duration'**
  String get learningRepeatExceedsDuration;

  /// No description provided for @learningSavedProgressUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved progress unavailable'**
  String get learningSavedProgressUnavailableTitle;

  /// No description provided for @learningListenWithoutSavedPrompt.
  ///
  /// In en, this message translates to:
  /// **'Listen from the beginning without changing saved data? Saving stays off until you retry successfully.'**
  String get learningListenWithoutSavedPrompt;

  /// Dialog button label.
  ///
  /// In en, this message translates to:
  /// **'Listen from beginning'**
  String get learningListenFromBeginning;

  /// Fallback lesson title.
  ///
  /// In en, this message translates to:
  /// **'Recorded lesson'**
  String get learningRecordedLesson;

  /// No description provided for @learningStatusPosition.
  ///
  /// In en, this message translates to:
  /// **'Position {position}.'**
  String learningStatusPosition(String position);

  /// No description provided for @learningSpeedTimes.
  ///
  /// In en, this message translates to:
  /// **'Speed {speed} times.'**
  String learningSpeedTimes(String speed);

  /// Sentence in the learning status; English intentionally says '1 bookmarks' (unchanged legacy output).
  ///
  /// In en, this message translates to:
  /// **'{count, plural, other{{count} bookmarks}}'**
  String learningStatusBookmarks(int count);

  /// No description provided for @learningStatusRepeat.
  ///
  /// In en, this message translates to:
  /// **'A-B repeat {state}.'**
  String learningStatusRepeat(String state);

  /// No description provided for @learningStatusSaving.
  ///
  /// In en, this message translates to:
  /// **'Progress saving {state}.'**
  String learningStatusSaving(String state);

  /// No description provided for @learningNoLessonLoaded.
  ///
  /// In en, this message translates to:
  /// **'No lesson is loaded. Choose a lesson to play first.'**
  String get learningNoLessonLoaded;

  /// No description provided for @learningSlowestSpeed.
  ///
  /// In en, this message translates to:
  /// **'Already at the slowest speed.'**
  String get learningSlowestSpeed;

  /// No description provided for @learningFastestSpeed.
  ///
  /// In en, this message translates to:
  /// **'Already at the fastest speed.'**
  String get learningFastestSpeed;

  /// No description provided for @learningCheckPosition.
  ///
  /// In en, this message translates to:
  /// **'Check the lesson position and try again.'**
  String get learningCheckPosition;

  /// No description provided for @learningPlayerActionFailed.
  ///
  /// In en, this message translates to:
  /// **'The player could not complete this action. Check playback and try again.'**
  String get learningPlayerActionFailed;

  /// No description provided for @learningBookmarkSavedAt.
  ///
  /// In en, this message translates to:
  /// **'Bookmark saved at {time}.'**
  String learningBookmarkSavedAt(String time);

  /// Spoken label of the status control.
  ///
  /// In en, this message translates to:
  /// **'Read learning status. {status}'**
  String learningReadStatusLabel(String status);

  /// Spoken control label.
  ///
  /// In en, this message translates to:
  /// **'Add bookmark at {time}'**
  String learningAddBookmarkAt(String time);

  /// Spoken control label; English intentionally says '1 saved points' (unchanged legacy output).
  ///
  /// In en, this message translates to:
  /// **'{count, plural, other{Bookmarks. {count} saved points}}'**
  String learningBookmarksSavedPoints(int count);

  /// Spoken control label.
  ///
  /// In en, this message translates to:
  /// **'Private study notes at {time}. Pause lesson before opening'**
  String learningPrivateNotesAt(String time);

  /// No description provided for @learningSetRepeatStartLabel.
  ///
  /// In en, this message translates to:
  /// **'Set repeat start A at the current position'**
  String get learningSetRepeatStartLabel;

  /// No description provided for @learningRepeatStartSet.
  ///
  /// In en, this message translates to:
  /// **'Repeat start set at {time}.'**
  String learningRepeatStartSet(String time);

  /// No description provided for @learningSetRepeatEndLabel.
  ///
  /// In en, this message translates to:
  /// **'Set repeat end B after start A'**
  String get learningSetRepeatEndLabel;

  /// No description provided for @learningRepeatEndSet.
  ///
  /// In en, this message translates to:
  /// **'Repeat end set at {time}. Select Repeat on to start looping.'**
  String learningRepeatEndSet(String time);

  /// No description provided for @learningTurnRepeatOff.
  ///
  /// In en, this message translates to:
  /// **'Turn A-B repeat off'**
  String get learningTurnRepeatOff;

  /// No description provided for @learningTurnRepeatOn.
  ///
  /// In en, this message translates to:
  /// **'Turn A-B repeat on'**
  String get learningTurnRepeatOn;

  /// No description provided for @learningClearRepeatLabel.
  ///
  /// In en, this message translates to:
  /// **'Clear saved A-B repeat points'**
  String get learningClearRepeatLabel;

  /// No description provided for @learningRepeatCleared.
  ///
  /// In en, this message translates to:
  /// **'A-B repeat points cleared.'**
  String get learningRepeatCleared;

  /// No description provided for @learningBackTenLabel.
  ///
  /// In en, this message translates to:
  /// **'Back 10 seconds, key {key}'**
  String learningBackTenLabel(String key);

  /// No description provided for @learningForwardTenLabel.
  ///
  /// In en, this message translates to:
  /// **'Forward 10 seconds, key {key}'**
  String learningForwardTenLabel(String key);

  /// No description provided for @learningSlowerLabel.
  ///
  /// In en, this message translates to:
  /// **'Slower, key {key}. Now {speed} times'**
  String learningSlowerLabel(String key, String speed);

  /// No description provided for @learningFasterLabel.
  ///
  /// In en, this message translates to:
  /// **'Faster, key {key}. Now {speed} times'**
  String learningFasterLabel(String key, String speed);

  /// No description provided for @learningRetrySavingLabel.
  ///
  /// In en, this message translates to:
  /// **'Retry saving learning progress. {issue}'**
  String learningRetrySavingLabel(String issue);

  /// No description provided for @learningProgressSaved.
  ///
  /// In en, this message translates to:
  /// **'Learning progress saved.'**
  String get learningProgressSaved;

  /// No description provided for @learningEnterBookmarkName.
  ///
  /// In en, this message translates to:
  /// **'Enter a bookmark name.'**
  String get learningEnterBookmarkName;

  /// No description provided for @learningNameBookmarkScreen.
  ///
  /// In en, this message translates to:
  /// **'Name bookmark. Press OK to edit. Up or down leaves editing.'**
  String get learningNameBookmarkScreen;

  /// Key action label.
  ///
  /// In en, this message translates to:
  /// **'Edit name'**
  String get learningEditName;

  /// Key action / button label.
  ///
  /// In en, this message translates to:
  /// **'Save bookmark'**
  String get learningSaveBookmark;

  /// Spoken label of the bookmark name text field.
  ///
  /// In en, this message translates to:
  /// **'Bookmark name'**
  String get learningBookmarkNameField;

  /// No description provided for @learningBookmarkJumped.
  ///
  /// In en, this message translates to:
  /// **'{label}. Position {position}.'**
  String learningBookmarkJumped(String label, String position);

  /// No description provided for @learningRemoveBookmarkTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove bookmark?'**
  String get learningRemoveBookmarkTitle;

  /// No description provided for @learningRemoveBookmarkMessage.
  ///
  /// In en, this message translates to:
  /// **'Remove {label}? This does not remove the lesson or any other bookmarks.'**
  String learningRemoveBookmarkMessage(String label);

  /// Dialog button label.
  ///
  /// In en, this message translates to:
  /// **'Keep bookmark'**
  String get learningKeepBookmark;

  /// Dialog button label.
  ///
  /// In en, this message translates to:
  /// **'Remove bookmark'**
  String get learningRemoveBookmark;

  /// No description provided for @learningBookmarkRemoved.
  ///
  /// In en, this message translates to:
  /// **'{label} removed.'**
  String learningBookmarkRemoved(String label);

  /// No description provided for @learningBookmarksScreen.
  ///
  /// In en, this message translates to:
  /// **'Bookmarks. Select a point to jump. This does not start paused playback. Remove asks for confirmation.'**
  String get learningBookmarksScreen;

  /// Key action label.
  ///
  /// In en, this message translates to:
  /// **'Close bookmarks'**
  String get learningCloseBookmarks;

  /// No description provided for @learningJumpToBookmarkLabel.
  ///
  /// In en, this message translates to:
  /// **'{label}. {time}. Jump to bookmark'**
  String learningJumpToBookmarkLabel(String label, String time);

  /// Spoken control label.
  ///
  /// In en, this message translates to:
  /// **'Remove {label}'**
  String learningRemoveBookmarkLabel(String label);

  /// No description provided for @dashboardRefreshing.
  ///
  /// In en, this message translates to:
  /// **'Refreshing sessions.'**
  String get dashboardRefreshing;

  /// Button label, spoken.
  ///
  /// In en, this message translates to:
  /// **'Show matching sessions'**
  String get dashboardShowMatching;

  /// Button label, spoken.
  ///
  /// In en, this message translates to:
  /// **'Log out, asks to confirm'**
  String get dashboardLogout;

  /// Button label, spoken.
  ///
  /// In en, this message translates to:
  /// **'Refresh sessions'**
  String get dashboardRefresh;

  /// Inserted into 'Opening {what}.'
  ///
  /// In en, this message translates to:
  /// **'recorded audio library'**
  String get dashboardLibraryWhat;

  /// Inserted into 'Opening {what}.'
  ///
  /// In en, this message translates to:
  /// **'quizzes'**
  String get dashboardQuizzesWhat;

  /// No description provided for @dashboardSessions.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 session} other{{count} sessions}}'**
  String dashboardSessions(int count);

  /// Position in a list of choices, e.g. 3 of 6.
  ///
  /// In en, this message translates to:
  /// **'{index} of {total}'**
  String dashboardPosition(String index, String total);

  /// No description provided for @dashboardStudentScreen.
  ///
  /// In en, this message translates to:
  /// **'Student Dashboard'**
  String get dashboardStudentScreen;

  /// No description provided for @dashboardStudentLoading.
  ///
  /// In en, this message translates to:
  /// **'Student dashboard is loading'**
  String get dashboardStudentLoading;

  /// List of screen sections, spoken in the keypad help.
  ///
  /// In en, this message translates to:
  /// **'refresh, session search, live sessions, recorded lessons, playlists, quizzes, learning journeys, and log out'**
  String get dashboardStudentSections;

  /// No description provided for @dashboardNoLiveSessions.
  ///
  /// In en, this message translates to:
  /// **'No live sessions right now. Press 1 to refresh.'**
  String get dashboardNoLiveSessions;

  /// No description provided for @dashboardNoFilterMatch.
  ///
  /// In en, this message translates to:
  /// **'No sessions match your filter.'**
  String get dashboardNoFilterMatch;

  /// No description provided for @dashboardNoMatchVisible.
  ///
  /// In en, this message translates to:
  /// **'No matching sessions. Clear the search or change the subject filter.'**
  String get dashboardNoMatchVisible;

  /// No description provided for @dashboardAvailable.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 session available.} other{{count} sessions available.}}'**
  String dashboardAvailable(int count);

  /// No description provided for @dashboardAvailableDetailed.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 session available. Use down to browse.} other{{count} sessions available. Use down to browse.}}'**
  String dashboardAvailableDetailed(int count);

  /// No description provided for @dashboardRefreshFailed.
  ///
  /// In en, this message translates to:
  /// **'{reason} Press 1 to try again.'**
  String dashboardRefreshFailed(String reason);

  /// No description provided for @dashboardJoining.
  ///
  /// In en, this message translates to:
  /// **'Joining session.'**
  String get dashboardJoining;

  /// No description provided for @dashboardJoined.
  ///
  /// In en, this message translates to:
  /// **'Joined {session}.'**
  String dashboardJoined(String session);

  /// No description provided for @dashboardOpeningPlaylists.
  ///
  /// In en, this message translates to:
  /// **'Opening My Playlists. These playlists are private.'**
  String get dashboardOpeningPlaylists;

  /// No description provided for @dashboardSessionSearchHelp.
  ///
  /// In en, this message translates to:
  /// **'Session search. Press OK to type a session number, then go down to Show matching sessions and press OK. You can also search by name.'**
  String get dashboardSessionSearchHelp;

  /// No description provided for @dashboardSessionNumberFieldEmpty.
  ///
  /// In en, this message translates to:
  /// **'Session number field. Type a number, then choose Show matching sessions'**
  String get dashboardSessionNumberFieldEmpty;

  /// No description provided for @dashboardSessionNumberField.
  ///
  /// In en, this message translates to:
  /// **'Session number field, {digits}'**
  String dashboardSessionNumberField(String digits);

  /// No description provided for @dashboardNameField.
  ///
  /// In en, this message translates to:
  /// **'Search sessions by name'**
  String get dashboardNameField;

  /// No description provided for @dashboardNoSessionNumber.
  ///
  /// In en, this message translates to:
  /// **'No live session number {digits}.'**
  String dashboardNoSessionNumber(String digits);

  /// No description provided for @dashboardFound.
  ///
  /// In en, this message translates to:
  /// **'Found: {label}. Press OK to join.'**
  String dashboardFound(String label);

  /// No description provided for @dashboardNoNameMatch.
  ///
  /// In en, this message translates to:
  /// **'No sessions match {query}.'**
  String dashboardNoNameMatch(String query);

  /// No description provided for @dashboardShowingAll.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Showing all 1 session.} other{Showing all {count} sessions.}}'**
  String dashboardShowingAll(int count);

  /// No description provided for @dashboardShowingAllDetailed.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Showing all 1 session. Use down to browse.} other{Showing all {count} sessions. Use down to browse.}}'**
  String dashboardShowingAllDetailed(int count);

  /// No description provided for @dashboardNameMatches.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 session match {query}. Use down to browse.} other{{count} sessions match {query}. Use down to browse.}}'**
  String dashboardNameMatches(int count, String query);

  /// Subject filter value meaning no filter.
  ///
  /// In en, this message translates to:
  /// **'all subjects'**
  String get dashboardAllSubjects;

  /// No description provided for @dashboardSubjectFilterLabel.
  ///
  /// In en, this message translates to:
  /// **'Subject filter: {subject}, {position}. Use left or right to change'**
  String dashboardSubjectFilterLabel(String subject, String position);

  /// No description provided for @dashboardSubjectFilterChanged.
  ///
  /// In en, this message translates to:
  /// **'Subject filter: {subject}, {position}. {summary}'**
  String dashboardSubjectFilterChanged(
    String subject,
    String position,
    String summary,
  );

  /// No description provided for @dashboardLibrary.
  ///
  /// In en, this message translates to:
  /// **'Recorded audio library'**
  String get dashboardLibrary;

  /// No description provided for @dashboardPlaylists.
  ///
  /// In en, this message translates to:
  /// **'My private playlists'**
  String get dashboardPlaylists;

  /// No description provided for @dashboardQuizzes.
  ///
  /// In en, this message translates to:
  /// **'Quizzes'**
  String get dashboardQuizzes;

  /// No description provided for @dashboardStudentJourneys.
  ///
  /// In en, this message translates to:
  /// **'Learning journeys: listen, answer and repeat, works offline'**
  String get dashboardStudentJourneys;

  /// Part of a comma separated session description.
  ///
  /// In en, this message translates to:
  /// **'Teacher {name}'**
  String dashboardTeacherName(String name);

  /// Part of a comma separated session description.
  ///
  /// In en, this message translates to:
  /// **'live now'**
  String get dashboardLiveNow;

  /// No description provided for @dashboardStateRefreshing.
  ///
  /// In en, this message translates to:
  /// **'Refreshing.'**
  String get dashboardStateRefreshing;

  /// No description provided for @dashboardStateLiveSessions.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 live session.} other{{count} live sessions.}}'**
  String dashboardStateLiveSessions(int count);

  /// No description provided for @dashboardStateSubjectFilter.
  ///
  /// In en, this message translates to:
  /// **'Subject filter: {subject}.'**
  String dashboardStateSubjectFilter(String subject);

  /// No description provided for @dashboardStateSessionNumber.
  ///
  /// In en, this message translates to:
  /// **'Session number typed: {digits}.'**
  String dashboardStateSessionNumber(String digits);

  /// No description provided for @dashboardStateNameSearch.
  ///
  /// In en, this message translates to:
  /// **'Name search: {query}.'**
  String dashboardStateNameSearch(String query);

  /// No description provided for @dashboardStateShown.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 session shown.} other{{count} sessions shown.}}'**
  String dashboardStateShown(int count);

  /// No description provided for @dashboardTeacherScreen.
  ///
  /// In en, this message translates to:
  /// **'Teacher Dashboard'**
  String get dashboardTeacherScreen;

  /// No description provided for @dashboardTeacherLoading.
  ///
  /// In en, this message translates to:
  /// **'Teacher dashboard is loading'**
  String get dashboardTeacherLoading;

  /// List of screen sections, spoken in the keypad help.
  ///
  /// In en, this message translates to:
  /// **'class and subject selection, teaching tools, session search, and active or ended sessions'**
  String get dashboardTeacherSections;

  /// No description provided for @dashboardNoSessionsYet.
  ///
  /// In en, this message translates to:
  /// **'No sessions yet. Press 2 to create one.'**
  String get dashboardNoSessionsYet;

  /// No description provided for @dashboardNoTeacherMatch.
  ///
  /// In en, this message translates to:
  /// **'No matching sessions. Clear the search to list all sessions.'**
  String get dashboardNoTeacherMatch;

  /// No description provided for @dashboardTeacherCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 session.} other{{count} sessions.}}'**
  String dashboardTeacherCount(int count);

  /// No description provided for @dashboardTeacherCountLive.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 session, {live} live now.} other{{count} sessions, {live} live now.}}'**
  String dashboardTeacherCountLive(int count, String live);

  /// No description provided for @dashboardNotRefreshed.
  ///
  /// In en, this message translates to:
  /// **'{reason} Sessions were not refreshed. Press 1 to try again.'**
  String dashboardNotRefreshed(String reason);

  /// No description provided for @dashboardNoAssignment.
  ///
  /// In en, this message translates to:
  /// **'No class and subject is assigned to you. Ask an administrator to assign one.'**
  String get dashboardNoAssignment;

  /// No description provided for @dashboardCreatingSession.
  ///
  /// In en, this message translates to:
  /// **'Creating session'**
  String get dashboardCreatingSession;

  /// No description provided for @dashboardCreated.
  ///
  /// In en, this message translates to:
  /// **'Session {title} created.'**
  String dashboardCreated(String title);

  /// No description provided for @dashboardCreatedTitle.
  ///
  /// In en, this message translates to:
  /// **'Session created'**
  String get dashboardCreatedTitle;

  /// No description provided for @dashboardStartNow.
  ///
  /// In en, this message translates to:
  /// **'Do you want to start \"{title}\" now?'**
  String dashboardStartNow(String title);

  /// No description provided for @dashboardRequestFailed.
  ///
  /// In en, this message translates to:
  /// **'We could not complete that request. Check your connection and try again.'**
  String get dashboardRequestFailed;

  /// No description provided for @dashboardOpeningSession.
  ///
  /// In en, this message translates to:
  /// **'Opening session.'**
  String get dashboardOpeningSession;

  /// Name of a teacher workspace: class and subject.
  ///
  /// In en, this message translates to:
  /// **'{className}, {subject}'**
  String dashboardWorkspace(String className, String subject);

  /// No description provided for @dashboardWorkspaceSelected.
  ///
  /// In en, this message translates to:
  /// **'Workspace: {name}, {position}. {status}'**
  String dashboardWorkspaceSelected(
    String name,
    String position,
    String status,
  );

  /// No description provided for @dashboardWorkspaceChosen.
  ///
  /// In en, this message translates to:
  /// **'{name} selected. {status} Press 7 to choose another workspace.'**
  String dashboardWorkspaceChosen(String name, String status);

  /// No description provided for @dashboardChooseWorkspaceTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose class and subject'**
  String get dashboardChooseWorkspaceTitle;

  /// No description provided for @dashboardNoWorkspace.
  ///
  /// In en, this message translates to:
  /// **'No class and subject workspace assigned'**
  String get dashboardNoWorkspace;

  /// No description provided for @dashboardWorkspaceLabel.
  ///
  /// In en, this message translates to:
  /// **'Workspace: {name}, {position}. Left or right to change, OK or 7 for a numbered list'**
  String dashboardWorkspaceLabel(String name, String position);

  /// No description provided for @dashboardCreate.
  ///
  /// In en, this message translates to:
  /// **'Create new session'**
  String get dashboardCreate;

  /// No description provided for @dashboardClassPlaylists.
  ///
  /// In en, this message translates to:
  /// **'Class playlists'**
  String get dashboardClassPlaylists;

  /// No description provided for @dashboardTeacherJourneys.
  ///
  /// In en, this message translates to:
  /// **'Learning journeys: recordings, questions and polls in one flow'**
  String get dashboardTeacherJourneys;

  /// No description provided for @dashboardTeacherQuizzes.
  ///
  /// In en, this message translates to:
  /// **'Quizzes and private question bank'**
  String get dashboardTeacherQuizzes;

  /// No description provided for @dashboardOfflineLibrary.
  ///
  /// In en, this message translates to:
  /// **'Offline audio library'**
  String get dashboardOfflineLibrary;

  /// No description provided for @dashboardSearchField.
  ///
  /// In en, this message translates to:
  /// **'Search sessions. Press OK, then type a name or the session number'**
  String get dashboardSearchField;

  /// No description provided for @dashboardTeacherSearchHelp.
  ///
  /// In en, this message translates to:
  /// **'Session search. Press OK to edit, then type a session name, or the session number using the number keys. Use up or down to leave the field and browse results.'**
  String get dashboardTeacherSearchHelp;

  /// No description provided for @dashboardTeacherNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No sessions match {query}. Clear the search to list all sessions.'**
  String dashboardTeacherNoMatch(String query);

  /// Session status, part of a comma separated session description.
  ///
  /// In en, this message translates to:
  /// **'ended'**
  String get dashboardEnded;

  /// Number of participants, part of a comma separated session description.
  ///
  /// In en, this message translates to:
  /// **'{count} joined'**
  String dashboardJoinedCount(String count);

  /// No description provided for @dashboardPressOkToOpen.
  ///
  /// In en, this message translates to:
  /// **'Press OK to open'**
  String get dashboardPressOkToOpen;

  /// No description provided for @dashboardPressOkToReactivate.
  ///
  /// In en, this message translates to:
  /// **'Press OK to reactivate'**
  String get dashboardPressOkToReactivate;

  /// No description provided for @dashboardEndLabel.
  ///
  /// In en, this message translates to:
  /// **'End {title} for everyone, asks to confirm'**
  String dashboardEndLabel(String title);

  /// No description provided for @dashboardDeleteLabel.
  ///
  /// In en, this message translates to:
  /// **'Delete ended session {title} permanently, asks to confirm'**
  String dashboardDeleteLabel(String title);

  /// No description provided for @dashboardEndTitle.
  ///
  /// In en, this message translates to:
  /// **'End session for everyone?'**
  String get dashboardEndTitle;

  /// No description provided for @dashboardEndMessage.
  ///
  /// In en, this message translates to:
  /// **'End \"{title}\" and close it for every participant? The session will remain in your dashboard history.'**
  String dashboardEndMessage(String title);

  /// No description provided for @dashboardEndedForEveryone.
  ///
  /// In en, this message translates to:
  /// **'Session ended for everyone and kept in session history.'**
  String get dashboardEndedForEveryone;

  /// No description provided for @dashboardEndFailed.
  ///
  /// In en, this message translates to:
  /// **'The session could not be ended. Please try again.'**
  String get dashboardEndFailed;

  /// No description provided for @dashboardReactivateTitle.
  ///
  /// In en, this message translates to:
  /// **'Reactivate session?'**
  String get dashboardReactivateTitle;

  /// No description provided for @dashboardReactivateMessage.
  ///
  /// In en, this message translates to:
  /// **'Reactivate \"{title}\" so participants can join it again?'**
  String dashboardReactivateMessage(String title);

  /// No description provided for @dashboardReactivated.
  ///
  /// In en, this message translates to:
  /// **'Session reactivated.'**
  String get dashboardReactivated;

  /// No description provided for @dashboardReactivateFailed.
  ///
  /// In en, this message translates to:
  /// **'The session could not be reactivated. Please try again.'**
  String get dashboardReactivateFailed;

  /// No description provided for @dashboardOpenNowTitle.
  ///
  /// In en, this message translates to:
  /// **'Open session now?'**
  String get dashboardOpenNowTitle;

  /// No description provided for @dashboardOpenNowMessage.
  ///
  /// In en, this message translates to:
  /// **'\"{title}\" is active again. Open it now, or return to it later from the dashboard.'**
  String dashboardOpenNowMessage(String title);

  /// No description provided for @dashboardDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete session?'**
  String get dashboardDeleteTitle;

  /// No description provided for @dashboardDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete \"{title}\", including its participants, chat, and logs? This cannot be undone.'**
  String dashboardDeleteMessage(String title);

  /// No description provided for @dashboardDeleted.
  ///
  /// In en, this message translates to:
  /// **'Session permanently deleted.'**
  String get dashboardDeleted;

  /// No description provided for @dashboardDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'The session could not be deleted. Please try again.'**
  String get dashboardDeleteFailed;

  /// No description provided for @dashboardStateNoWorkspace.
  ///
  /// In en, this message translates to:
  /// **'No workspace chosen.'**
  String get dashboardStateNoWorkspace;

  /// No description provided for @dashboardStateWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Workspace: {name}.'**
  String dashboardStateWorkspace(String name);

  /// No description provided for @dashboardActiveSessions.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 active session} other{{count} active sessions}}'**
  String dashboardActiveSessions(int count);

  /// No description provided for @dashboardStateTotals.
  ///
  /// In en, this message translates to:
  /// **'{active}, {total} in total.'**
  String dashboardStateTotals(String active, String total);

  /// No description provided for @dashboardStateSearch.
  ///
  /// In en, this message translates to:
  /// **'Search: {query}.'**
  String dashboardStateSearch(String query);

  /// No description provided for @adminSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'The change could not be saved. Press 1 to refresh, then try again.'**
  String get adminSaveFailed;

  /// Left/right choice control.
  ///
  /// In en, this message translates to:
  /// **'{what}: {name}, {position}. Use left or right to change'**
  String adminChoiceLabel(String what, String name, String position);

  /// No description provided for @adminChoiceLabelSingle.
  ///
  /// In en, this message translates to:
  /// **'{what}: {name}. Use left or right to change'**
  String adminChoiceLabelSingle(String what, String name);

  /// No description provided for @adminChoiceChanged.
  ///
  /// In en, this message translates to:
  /// **'{name}, {position}.'**
  String adminChoiceChanged(String name, String position);

  /// No description provided for @adminChoiceChangedSingle.
  ///
  /// In en, this message translates to:
  /// **'{name}.'**
  String adminChoiceChangedSingle(String name);

  /// No description provided for @adminClassAndSubject.
  ///
  /// In en, this message translates to:
  /// **'{className} selected. {subject} subject selected.'**
  String adminClassAndSubject(String className, String subject);

  /// No description provided for @adminNoSubjects.
  ///
  /// In en, this message translates to:
  /// **'The selected class has no active subjects.'**
  String get adminNoSubjects;

  /// No description provided for @adminStateSection.
  ///
  /// In en, this message translates to:
  /// **'Section: {section}.'**
  String adminStateSection(String section);

  /// No description provided for @adminStateShown.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item shown.} other{{count} items shown.}}'**
  String adminStateShown(int count);

  /// No description provided for @adminStateFilter.
  ///
  /// In en, this message translates to:
  /// **'Filter: {filter}.'**
  String adminStateFilter(String filter);

  /// No description provided for @adminStateSearch.
  ///
  /// In en, this message translates to:
  /// **'Search: {query}.'**
  String adminStateSearch(String query);

  /// No description provided for @adminNoSubjectName.
  ///
  /// In en, this message translates to:
  /// **'No subject name entered. Nothing was created.'**
  String get adminNoSubjectName;

  /// No description provided for @adminNoClassName.
  ///
  /// In en, this message translates to:
  /// **'No class name entered. Nothing was created.'**
  String get adminNoClassName;

  /// No description provided for @adminNoActiveSubjects.
  ///
  /// In en, this message translates to:
  /// **'This class has no active subjects.'**
  String get adminNoActiveSubjects;

  /// No description provided for @adminListReadFailed.
  ///
  /// In en, this message translates to:
  /// **'The administration list could not be read.'**
  String get adminListReadFailed;

  /// No description provided for @adminNotRefreshed.
  ///
  /// In en, this message translates to:
  /// **'{reason} Administration data was not refreshed. Press 1 to retry.'**
  String adminNotRefreshed(String reason);

  /// No description provided for @adminExploreIntro.
  ///
  /// In en, this message translates to:
  /// **'Use D-pad up and down to explore {sections}. Press OK to select.'**
  String adminExploreIntro(String sections);

  /// No description provided for @adminSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Administration. {section} section'**
  String adminSectionTitle(String section);

  /// Section name, used in 'Administration. {section} section'.
  ///
  /// In en, this message translates to:
  /// **'accounts'**
  String get adminSectionNameAccounts;

  /// Section name, used in 'Administration. {section} section'.
  ///
  /// In en, this message translates to:
  /// **'classes'**
  String get adminSectionNameClasses;

  /// Section name, used in 'Administration. {section} section'.
  ///
  /// In en, this message translates to:
  /// **'subjects'**
  String get adminSectionNameSubjects;

  /// No description provided for @adminNoMatchingAccounts.
  ///
  /// In en, this message translates to:
  /// **'No matching accounts. Change the search or filters.'**
  String get adminNoMatchingAccounts;

  /// No description provided for @adminNoMatchingAccountsFor.
  ///
  /// In en, this message translates to:
  /// **'No matching accounts for {search}. Change the search or filters.'**
  String adminNoMatchingAccountsFor(String search);

  /// No description provided for @adminClasses.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 class} other{{count} classes}}'**
  String adminClasses(int count);

  /// No description provided for @adminSubjects.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 subject} other{{count} subjects}}'**
  String adminSubjects(int count);

  /// No description provided for @adminAccountsSummary.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 account. {classes} and {subjects}.} other{{count} accounts. {classes} and {subjects}.}}'**
  String adminAccountsSummary(int count, String classes, String subjects);

  /// No description provided for @adminAccountsSummarySearch.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 account match {search}. {classes} and {subjects}.} other{{count} accounts match {search}. {classes} and {subjects}.}}'**
  String adminAccountsSummarySearch(
    int count,
    String search,
    String classes,
    String subjects,
  );

  /// No description provided for @adminClassesSentence.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 class.} other{{count} classes.}}'**
  String adminClassesSentence(int count);

  /// No description provided for @adminSubjectsSentence.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 subject.} other{{count} subjects.}}'**
  String adminSubjectsSentence(int count);

  /// Inserted into 'Use D-pad up and down to explore {sections}. Press OK to select.'
  ///
  /// In en, this message translates to:
  /// **'account search, account type and enrollment filters, and account management. Use left or right on a filter to change it'**
  String get adminNavigationAccounts;

  /// Inserted into 'Use D-pad up and down to explore {sections}. Press OK to select.'
  ///
  /// In en, this message translates to:
  /// **'create class and the list of active or archived classes. Press OK on a class for its subject assignments and archive or restore actions'**
  String get adminNavigationClasses;

  /// Inserted into 'Use D-pad up and down to explore {sections}. Press OK to select.'
  ///
  /// In en, this message translates to:
  /// **'create subject and the list of active or archived subjects. Press OK on a subject to archive or restore it'**
  String get adminNavigationSubjects;

  /// No description provided for @adminSectionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Administration sections'**
  String get adminSectionsTitle;

  /// No description provided for @adminSectionAccounts.
  ///
  /// In en, this message translates to:
  /// **'Accounts and enrollment'**
  String get adminSectionAccounts;

  /// No description provided for @adminSectionClasses.
  ///
  /// In en, this message translates to:
  /// **'Classes and their subjects'**
  String get adminSectionClasses;

  /// No description provided for @adminSectionSubjects.
  ///
  /// In en, this message translates to:
  /// **'Subjects'**
  String get adminSectionSubjects;

  /// No description provided for @adminSectionChosen.
  ///
  /// In en, this message translates to:
  /// **'{section} section.'**
  String adminSectionChosen(String section);

  /// No description provided for @adminSectionExplore.
  ///
  /// In en, this message translates to:
  /// **'Use the D-pad to explore {what}. Press 7 to change section.'**
  String adminSectionExplore(String what);

  /// Inserted into 'Use the D-pad to explore {what}.'
  ///
  /// In en, this message translates to:
  /// **'account filters, search and account management'**
  String get adminExploreAccounts;

  /// Inserted into 'Use the D-pad to explore {what}.'
  ///
  /// In en, this message translates to:
  /// **'class creation, subject assignments, and archive or restore actions'**
  String get adminExploreClasses;

  /// Inserted into 'Use the D-pad to explore {what}.'
  ///
  /// In en, this message translates to:
  /// **'subject creation and archive or restore actions'**
  String get adminExploreSubjects;

  /// No description provided for @adminRoleFilterSelected.
  ///
  /// In en, this message translates to:
  /// **'Account type filter: {label}, selected.'**
  String adminRoleFilterSelected(String label);

  /// No description provided for @adminAssignmentFilterSelected.
  ///
  /// In en, this message translates to:
  /// **'Assignment filter: {label}, selected.'**
  String adminAssignmentFilterSelected(String label);

  /// No description provided for @adminRoleFilterStudents.
  ///
  /// In en, this message translates to:
  /// **'Students only'**
  String get adminRoleFilterStudents;

  /// No description provided for @adminRoleFilterTeachers.
  ///
  /// In en, this message translates to:
  /// **'Teachers only'**
  String get adminRoleFilterTeachers;

  /// No description provided for @adminRoleFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All registered accounts'**
  String get adminRoleFilterAll;

  /// No description provided for @adminAssignmentEnrolled.
  ///
  /// In en, this message translates to:
  /// **'Enrolled'**
  String get adminAssignmentEnrolled;

  /// No description provided for @adminAssignmentAssigned.
  ///
  /// In en, this message translates to:
  /// **'Assigned'**
  String get adminAssignmentAssigned;

  /// No description provided for @adminAssignmentEnrolledOrAssigned.
  ///
  /// In en, this message translates to:
  /// **'Enrolled or assigned'**
  String get adminAssignmentEnrolledOrAssigned;

  /// No description provided for @adminAssignmentUnassigned.
  ///
  /// In en, this message translates to:
  /// **'Unassigned'**
  String get adminAssignmentUnassigned;

  /// No description provided for @adminAssignmentAll.
  ///
  /// In en, this message translates to:
  /// **'All assignment states'**
  String get adminAssignmentAll;

  /// Account role, lower case, inside a sentence.
  ///
  /// In en, this message translates to:
  /// **'student'**
  String get adminRoleStudent;

  /// Account role, lower case, inside a sentence.
  ///
  /// In en, this message translates to:
  /// **'teacher'**
  String get adminRoleTeacher;

  /// No description provided for @adminNoClassAssigned.
  ///
  /// In en, this message translates to:
  /// **'No class assigned'**
  String get adminNoClassAssigned;

  /// No description provided for @adminAssignmentCount.
  ///
  /// In en, this message translates to:
  /// **'{count} assignments'**
  String adminAssignmentCount(String count);

  /// No description provided for @adminAccountLabel.
  ///
  /// In en, this message translates to:
  /// **'{name}, {role}. {access}. Press OK to manage'**
  String adminAccountLabel(String name, String role, String access);

  /// No description provided for @adminCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get adminCancel;

  /// No description provided for @adminSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get adminSave;

  /// No description provided for @adminCreateSubjectTitle.
  ///
  /// In en, this message translates to:
  /// **'Create subject'**
  String get adminCreateSubjectTitle;

  /// No description provided for @adminSubjectNameField.
  ///
  /// In en, this message translates to:
  /// **'Subject name'**
  String get adminSubjectNameField;

  /// No description provided for @adminSubjectCreated.
  ///
  /// In en, this message translates to:
  /// **'Subject {name} created'**
  String adminSubjectCreated(String name);

  /// No description provided for @adminCreateClassTitle.
  ///
  /// In en, this message translates to:
  /// **'Create class'**
  String get adminCreateClassTitle;

  /// No description provided for @adminClassNameField.
  ///
  /// In en, this message translates to:
  /// **'Class name'**
  String get adminClassNameField;

  /// No description provided for @adminClassCreated.
  ///
  /// In en, this message translates to:
  /// **'Class {name} created'**
  String adminClassCreated(String name);

  /// No description provided for @adminArchiveClassTitle.
  ///
  /// In en, this message translates to:
  /// **'Archive class?'**
  String get adminArchiveClassTitle;

  /// No description provided for @adminRestoreClassTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore class?'**
  String get adminRestoreClassTitle;

  /// No description provided for @adminArchiveItemMessage.
  ///
  /// In en, this message translates to:
  /// **'New sessions, audio, and assignments cannot use {name} while it is archived.'**
  String adminArchiveItemMessage(String name);

  /// No description provided for @adminRestoreItemMessage.
  ///
  /// In en, this message translates to:
  /// **'{name} will become available for assignments again.'**
  String adminRestoreItemMessage(String name);

  /// No description provided for @adminArchive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get adminArchive;

  /// No description provided for @adminRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get adminRestore;

  /// No description provided for @adminClassArchived.
  ///
  /// In en, this message translates to:
  /// **'Class archived'**
  String get adminClassArchived;

  /// No description provided for @adminClassRestored.
  ///
  /// In en, this message translates to:
  /// **'Class restored'**
  String get adminClassRestored;

  /// No description provided for @adminManageTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage {name}'**
  String adminManageTitle(String name);

  /// No description provided for @adminManageClassSubjects.
  ///
  /// In en, this message translates to:
  /// **'Manage class subjects'**
  String get adminManageClassSubjects;

  /// No description provided for @adminArchiveClassChoice.
  ///
  /// In en, this message translates to:
  /// **'Archive class with confirmation'**
  String get adminArchiveClassChoice;

  /// No description provided for @adminRestoreClassChoice.
  ///
  /// In en, this message translates to:
  /// **'Restore class with confirmation'**
  String get adminRestoreClassChoice;

  /// No description provided for @adminSubjectsForClass.
  ///
  /// In en, this message translates to:
  /// **'Subjects for {name}'**
  String adminSubjectsForClass(String name);

  /// No description provided for @adminSubjectRemovedFrom.
  ///
  /// In en, this message translates to:
  /// **'Subject removed from {name}'**
  String adminSubjectRemovedFrom(String name);

  /// No description provided for @adminSubjectAddedTo.
  ///
  /// In en, this message translates to:
  /// **'Subject added to {name}'**
  String adminSubjectAddedTo(String name);

  /// No description provided for @adminArchiveSubjectTitle.
  ///
  /// In en, this message translates to:
  /// **'Archive subject?'**
  String get adminArchiveSubjectTitle;

  /// No description provided for @adminRestoreSubjectTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore subject?'**
  String get adminRestoreSubjectTitle;

  /// No description provided for @adminSubjectArchived.
  ///
  /// In en, this message translates to:
  /// **'Subject archived'**
  String get adminSubjectArchived;

  /// No description provided for @adminSubjectRestored.
  ///
  /// In en, this message translates to:
  /// **'Subject restored'**
  String get adminSubjectRestored;

  /// No description provided for @adminManageAssignments.
  ///
  /// In en, this message translates to:
  /// **'Manage assignments'**
  String get adminManageAssignments;

  /// No description provided for @adminPasswordRecovery.
  ///
  /// In en, this message translates to:
  /// **'Password recovery'**
  String get adminPasswordRecovery;

  /// No description provided for @adminManageUserScreen.
  ///
  /// In en, this message translates to:
  /// **'Manage {name}. Choose assignments, password recovery, or Cancel.'**
  String adminManageUserScreen(String name);

  /// No description provided for @adminRecoveryNeedsVersion.
  ///
  /// In en, this message translates to:
  /// **'Account recovery requires a current server version. Refresh the account.'**
  String get adminRecoveryNeedsVersion;

  /// No description provided for @adminNoActiveClasses.
  ///
  /// In en, this message translates to:
  /// **'No active classes. Create or restore a class in the classes section first.'**
  String get adminNoActiveClasses;

  /// Used in place of a class name when it is unknown.
  ///
  /// In en, this message translates to:
  /// **'the current class'**
  String get adminTheCurrentClass;

  /// No description provided for @adminAssignClassTo.
  ///
  /// In en, this message translates to:
  /// **'Assign class to {name}'**
  String adminAssignClassTo(String name);

  /// No description provided for @adminAssign.
  ///
  /// In en, this message translates to:
  /// **'Assign'**
  String get adminAssign;

  /// No description provided for @adminRemoveClass.
  ///
  /// In en, this message translates to:
  /// **'Remove class'**
  String get adminRemoveClass;

  /// Name of the class choice field.
  ///
  /// In en, this message translates to:
  /// **'Class'**
  String get adminClassField;

  /// No description provided for @adminRemoveStudentLabel.
  ///
  /// In en, this message translates to:
  /// **'Remove {name} from {className}, asks to confirm'**
  String adminRemoveStudentLabel(String name, String className);

  /// No description provided for @adminAssignStudentLabel.
  ///
  /// In en, this message translates to:
  /// **'Assign {name} to the selected class'**
  String adminAssignStudentLabel(String name);

  /// No description provided for @adminRemoveFromClassTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove from class?'**
  String get adminRemoveFromClassTitle;

  /// No description provided for @adminRemoveFromClassMessage.
  ///
  /// In en, this message translates to:
  /// **'Remove {name} from {className}? They will no longer see that class until assigned again.'**
  String adminRemoveFromClassMessage(String name, String className);

  /// No description provided for @adminKeepInClass.
  ///
  /// In en, this message translates to:
  /// **'Keep in class'**
  String get adminKeepInClass;

  /// No description provided for @adminRemoveFromClass.
  ///
  /// In en, this message translates to:
  /// **'Remove from class'**
  String get adminRemoveFromClass;

  /// No description provided for @adminStudentRemovedFromClass.
  ///
  /// In en, this message translates to:
  /// **'{name} removed from class'**
  String adminStudentRemovedFromClass(String name);

  /// No description provided for @adminStudentAssignedTo.
  ///
  /// In en, this message translates to:
  /// **'{name} assigned to {className}'**
  String adminStudentAssignedTo(String name, String className);

  /// No description provided for @adminAssignTeacherScreen.
  ///
  /// In en, this message translates to:
  /// **'Assign {name} to a class and subject'**
  String adminAssignTeacherScreen(String name);

  /// No description provided for @adminRemoveAssignmentLabel.
  ///
  /// In en, this message translates to:
  /// **'Remove {name} from {className}, {subject}, asks to confirm'**
  String adminRemoveAssignmentLabel(
    String name,
    String className,
    String subject,
  );

  /// Name of the subject choice field.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get adminSubjectField;

  /// No description provided for @adminSaveAssignment.
  ///
  /// In en, this message translates to:
  /// **'Save assignment'**
  String get adminSaveAssignment;

  /// No description provided for @adminTeacherAssignmentSaved.
  ///
  /// In en, this message translates to:
  /// **'Teacher assignment saved'**
  String get adminTeacherAssignmentSaved;

  /// No description provided for @adminRemoveAssignmentTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove assignment?'**
  String get adminRemoveAssignmentTitle;

  /// No description provided for @adminRemoveAssignmentMessage.
  ///
  /// In en, this message translates to:
  /// **'Remove {name} from {className}, {subject}?'**
  String adminRemoveAssignmentMessage(
    String name,
    String className,
    String subject,
  );

  /// No description provided for @adminKeep.
  ///
  /// In en, this message translates to:
  /// **'Keep'**
  String get adminKeep;

  /// No description provided for @adminRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get adminRemove;

  /// No description provided for @adminTeacherAssignmentRemoved.
  ///
  /// In en, this message translates to:
  /// **'Teacher assignment removed'**
  String get adminTeacherAssignmentRemoved;

  /// No description provided for @adminRefreshData.
  ///
  /// In en, this message translates to:
  /// **'Refresh admin data'**
  String get adminRefreshData;

  /// No description provided for @adminLogout.
  ///
  /// In en, this message translates to:
  /// **'Log out, asks to confirm'**
  String get adminLogout;

  /// No description provided for @adminSectionButton.
  ///
  /// In en, this message translates to:
  /// **'{section} section. Change administration section'**
  String adminSectionButton(String section);

  /// No description provided for @adminSearchAccounts.
  ///
  /// In en, this message translates to:
  /// **'Search accounts by name or phone number. Press OK to type'**
  String get adminSearchAccounts;

  /// No description provided for @adminRoleFilterLabel.
  ///
  /// In en, this message translates to:
  /// **'Account type filter: {label}, selected. Use left or right to change'**
  String adminRoleFilterLabel(String label);

  /// No description provided for @adminAssignmentFilterLabel.
  ///
  /// In en, this message translates to:
  /// **'Assignment filter: {label}, selected. Use left or right to change'**
  String adminAssignmentFilterLabel(String label);

  /// No description provided for @adminClassActiveLabel.
  ///
  /// In en, this message translates to:
  /// **'{name}, active. Press OK for class subjects and archive or restore actions'**
  String adminClassActiveLabel(String name);

  /// No description provided for @adminClassArchivedLabel.
  ///
  /// In en, this message translates to:
  /// **'{name}, archived. Press OK for class subjects and archive or restore actions'**
  String adminClassArchivedLabel(String name);

  /// No description provided for @adminSubjectActiveLabel.
  ///
  /// In en, this message translates to:
  /// **'{name}, active. Press OK to archive'**
  String adminSubjectActiveLabel(String name);

  /// No description provided for @adminSubjectArchivedLabel.
  ///
  /// In en, this message translates to:
  /// **'{name}, archived. Press OK to restore'**
  String adminSubjectArchivedLabel(String name);

  /// No description provided for @adminSubjectInClass.
  ///
  /// In en, this message translates to:
  /// **'{name}. Available in this class. Select to remove'**
  String adminSubjectInClass(String name);

  /// No description provided for @adminSubjectNotInClass.
  ///
  /// In en, this message translates to:
  /// **'{name}. Not available in this class. Select to add'**
  String adminSubjectNotInClass(String name);

  /// Button label: start the new session later
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get teacherHomeLater;

  /// Button label: start the new session now
  ///
  /// In en, this message translates to:
  /// **'Start now'**
  String get teacherHomeStartNow;

  /// Title of the list for choosing a class and subject workspace
  ///
  /// In en, this message translates to:
  /// **'Choose class and subject'**
  String get teacherHomeChooseWorkspaceTitle;

  /// A workspace list entry: class name and subject name
  ///
  /// In en, this message translates to:
  /// **'{className}, {subjectName}'**
  String teacherHomeWorkspaceItem(String className, String subjectName);

  /// Spoken after choosing a workspace; status is the session count summary sentence without final period
  ///
  /// In en, this message translates to:
  /// **'{className}, {subjectName} selected. {status}. Press 7 to choose another workspace.'**
  String teacherHomeWorkspaceChosen(
    String className,
    String subjectName,
    String status,
  );

  /// No description provided for @teacherHomeUntitledSession.
  ///
  /// In en, this message translates to:
  /// **'Untitled session'**
  String get teacherHomeUntitledSession;

  /// No description provided for @teacherHomeUntitledSessionTitle.
  ///
  /// In en, this message translates to:
  /// **'Untitled Session'**
  String get teacherHomeUntitledSessionTitle;

  /// Lowercase fallback name for a session without a title
  ///
  /// In en, this message translates to:
  /// **'session'**
  String get teacherHomeSessionFallback;

  /// No description provided for @teacherHomeSearchLabel.
  ///
  /// In en, this message translates to:
  /// **'Search sessions. Press OK, then type a name or the session number'**
  String get teacherHomeSearchLabel;

  /// No description provided for @teacherHomeKeepSessionOpen.
  ///
  /// In en, this message translates to:
  /// **'Keep session open'**
  String get teacherHomeKeepSessionOpen;

  /// No description provided for @teacherHomeEndForEveryone.
  ///
  /// In en, this message translates to:
  /// **'End for everyone'**
  String get teacherHomeEndForEveryone;

  /// No description provided for @teacherHomeKeepEnded.
  ///
  /// In en, this message translates to:
  /// **'Keep ended'**
  String get teacherHomeKeepEnded;

  /// No description provided for @teacherHomeReactivate.
  ///
  /// In en, this message translates to:
  /// **'Reactivate'**
  String get teacherHomeReactivate;

  /// No description provided for @teacherHomeOpenLater.
  ///
  /// In en, this message translates to:
  /// **'Open later'**
  String get teacherHomeOpenLater;

  /// No description provided for @teacherHomeOpenNow.
  ///
  /// In en, this message translates to:
  /// **'Open now'**
  String get teacherHomeOpenNow;

  /// No description provided for @teacherHomeKeepSession.
  ///
  /// In en, this message translates to:
  /// **'Keep session'**
  String get teacherHomeKeepSession;

  /// No description provided for @teacherHomeDeletePermanently.
  ///
  /// In en, this message translates to:
  /// **'Delete permanently'**
  String get teacherHomeDeletePermanently;

  /// Default title for a new session when the teacher leaves the title empty
  ///
  /// In en, this message translates to:
  /// **'New Session'**
  String get teacherHomeNewSessionTitle;

  /// No description provided for @teacherHomeCreateScreen.
  ///
  /// In en, this message translates to:
  /// **'Create new session'**
  String get teacherHomeCreateScreen;

  /// No description provided for @teacherHomeCreateSessionKey.
  ///
  /// In en, this message translates to:
  /// **'Create session'**
  String get teacherHomeCreateSessionKey;

  /// No description provided for @teacherHomeTitleField.
  ///
  /// In en, this message translates to:
  /// **'Session title field'**
  String get teacherHomeTitleField;

  /// No description provided for @teacherHomeCancelCreate.
  ///
  /// In en, this message translates to:
  /// **'Cancel session creation'**
  String get teacherHomeCancelCreate;

  /// No description provided for @studentHomeSearchHelp.
  ///
  /// In en, this message translates to:
  /// **'Session search. Type a session number with the keypad, or move down to search by name. Press OK to edit. Use down to browse results.'**
  String get studentHomeSearchHelp;

  /// Name for a subject without a name; id is the subject number
  ///
  /// In en, this message translates to:
  /// **'Subject {id}'**
  String studentHomeSubjectFallback(String id);

  /// No description provided for @studentHomeUntitledSession.
  ///
  /// In en, this message translates to:
  /// **'Untitled session'**
  String get studentHomeUntitledSession;

  /// Focus label of a session in the list; session is the spoken session description
  ///
  /// In en, this message translates to:
  /// **'{session}. Press OK to join'**
  String studentHomeSessionJoinLabel(String session);

  /// No description provided for @inviteNoStudentsEnrolled.
  ///
  /// In en, this message translates to:
  /// **'No students are enrolled in this class. Press 1 to refresh.'**
  String get inviteNoStudentsEnrolled;

  /// Students in the class and how many are invited
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 student, {invited} invited.} other{{count} students, {invited} invited.}}'**
  String inviteLoadedSummary(int count, String invited);

  /// No description provided for @inviteUseSearch.
  ///
  /// In en, this message translates to:
  /// **'Use the search field to find a name.'**
  String get inviteUseSearch;

  /// No description provided for @inviteLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load students. Check your connection and press 1 to try again.'**
  String get inviteLoadFailed;

  /// No description provided for @inviteAlreadyInvited.
  ///
  /// In en, this message translates to:
  /// **'{name} is already invited.'**
  String inviteAlreadyInvited(String name);

  /// No description provided for @inviteInvitedOne.
  ///
  /// In en, this message translates to:
  /// **'Invited {name}.'**
  String inviteInvitedOne(String name);

  /// No description provided for @inviteOneFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not invite {name}. Check your connection and press OK to try again.'**
  String inviteOneFailed(String name);

  /// No description provided for @inviteNoStudentsToInvite.
  ///
  /// In en, this message translates to:
  /// **'There are no students to invite.'**
  String get inviteNoStudentsToInvite;

  /// No description provided for @inviteAllAlreadyInvited.
  ///
  /// In en, this message translates to:
  /// **'All students are already invited.'**
  String get inviteAllAlreadyInvited;

  /// No description provided for @inviteInvitingAll.
  ///
  /// In en, this message translates to:
  /// **'Inviting {count} students. Please wait.'**
  String inviteInvitingAll(String count);

  /// No description provided for @inviteProgress.
  ///
  /// In en, this message translates to:
  /// **'Inviting students: {done} of {total} done.'**
  String inviteProgress(String done, String total);

  /// No description provided for @inviteAllDone.
  ///
  /// In en, this message translates to:
  /// **'Invited all {count} students.'**
  String inviteAllDone(String count);

  /// names is a comma-separated list of student names
  ///
  /// In en, this message translates to:
  /// **'Invited {invited} of {total} students. Could not invite {names}. Press 2 to try again.'**
  String invitePartialFailed(String invited, String total, String names);

  /// No description provided for @inviteShowingAll.
  ///
  /// In en, this message translates to:
  /// **'Showing all {count} students.'**
  String inviteShowingAll(String count);

  /// No description provided for @inviteNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No students match {query}. Clear the search to list everyone.'**
  String inviteNoMatch(String query);

  /// No description provided for @inviteMatches.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 student matches {query}. Use down to browse.} other{{count} students match {query}. Use down to browse.}}'**
  String inviteMatches(int count, String query);

  /// No description provided for @inviteStudentInvited.
  ///
  /// In en, this message translates to:
  /// **'{name}, invited'**
  String inviteStudentInvited(String name);

  /// No description provided for @inviteStudentNotInvited.
  ///
  /// In en, this message translates to:
  /// **'{name}, not invited. Press OK to invite'**
  String inviteStudentNotInvited(String name);

  /// No description provided for @inviteBackToSession.
  ///
  /// In en, this message translates to:
  /// **'Back to session'**
  String get inviteBackToSession;

  /// No description provided for @inviteRefreshList.
  ///
  /// In en, this message translates to:
  /// **'Refresh student list'**
  String get inviteRefreshList;

  /// No description provided for @inviteAllStudents.
  ///
  /// In en, this message translates to:
  /// **'Invite all students'**
  String get inviteAllStudents;

  /// No description provided for @inviteSearchLabel.
  ///
  /// In en, this message translates to:
  /// **'Search students by name or phone number. Press OK to type'**
  String get inviteSearchLabel;

  /// No description provided for @inviteScreenName.
  ///
  /// In en, this message translates to:
  /// **'Invite students to {title}'**
  String inviteScreenName(String title);

  /// No description provided for @inviteKeyBack.
  ///
  /// In en, this message translates to:
  /// **'Back to Session'**
  String get inviteKeyBack;

  /// No description provided for @inviteKeyRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh Students'**
  String get inviteKeyRefresh;

  /// No description provided for @inviteKeyInviteAll.
  ///
  /// In en, this message translates to:
  /// **'Invite All'**
  String get inviteKeyInviteAll;

  /// No description provided for @notificationTitleSessionInvitation.
  ///
  /// In en, this message translates to:
  /// **'Live class'**
  String get notificationTitleSessionInvitation;

  /// No description provided for @notificationTitleJourneyPublished.
  ///
  /// In en, this message translates to:
  /// **'New learning journey'**
  String get notificationTitleJourneyPublished;

  /// No description provided for @notificationTitleQuizPublished.
  ///
  /// In en, this message translates to:
  /// **'New quiz'**
  String get notificationTitleQuizPublished;

  /// No description provided for @notificationTitleQuizReminder.
  ///
  /// In en, this message translates to:
  /// **'Quiz reminder'**
  String get notificationTitleQuizReminder;

  /// No description provided for @notificationTitleDefault.
  ///
  /// In en, this message translates to:
  /// **'SEEDS update'**
  String get notificationTitleDefault;

  /// No description provided for @notificationArrivedSessionInvitation.
  ///
  /// In en, this message translates to:
  /// **'Your teacher started a class. Press 1 to join, or 0 for not now.'**
  String get notificationArrivedSessionInvitation;

  /// No description provided for @notificationArrivedJourneyPublished.
  ///
  /// In en, this message translates to:
  /// **'Your teacher shared a new learning journey. Press 1 to open it, or 0 for not now.'**
  String get notificationArrivedJourneyPublished;

  /// No description provided for @notificationArrivedQuizPublished.
  ///
  /// In en, this message translates to:
  /// **'Your teacher published a new quiz. Press 1 to open your quizzes, or 0 for not now.'**
  String get notificationArrivedQuizPublished;

  /// No description provided for @notificationArrivedQuizReminder.
  ///
  /// In en, this message translates to:
  /// **'Reminder: you have a quiz to take. Press 1 to open your quizzes, or 0 for not now.'**
  String get notificationArrivedQuizReminder;

  /// No description provided for @notificationArrivedDefault.
  ///
  /// In en, this message translates to:
  /// **'You have a new update. Press 0 to go back.'**
  String get notificationArrivedDefault;

  /// No description provided for @notificationForegroundSessionInvitation.
  ///
  /// In en, this message translates to:
  /// **'Your teacher started a class. Join it from Live sessions on your dashboard.'**
  String get notificationForegroundSessionInvitation;

  /// No description provided for @notificationForegroundJourneyPublished.
  ///
  /// In en, this message translates to:
  /// **'Your teacher shared a new learning journey. Find it under Learning journeys.'**
  String get notificationForegroundJourneyPublished;

  /// No description provided for @notificationForegroundQuizPublished.
  ///
  /// In en, this message translates to:
  /// **'Your teacher published a new quiz.'**
  String get notificationForegroundQuizPublished;

  /// No description provided for @notificationForegroundQuizReminder.
  ///
  /// In en, this message translates to:
  /// **'Reminder: you have a quiz to take.'**
  String get notificationForegroundQuizReminder;

  /// No description provided for @notificationForegroundDefault.
  ///
  /// In en, this message translates to:
  /// **'You have a new update.'**
  String get notificationForegroundDefault;

  /// Key label for opening a class notification.
  ///
  /// In en, this message translates to:
  /// **'Join class'**
  String get notificationOpenJoinClass;

  /// No description provided for @notificationOpenJourney.
  ///
  /// In en, this message translates to:
  /// **'Open journey'**
  String get notificationOpenJourney;

  /// No description provided for @notificationOpenQuizzes.
  ///
  /// In en, this message translates to:
  /// **'Open quizzes'**
  String get notificationOpenQuizzes;

  /// Key label: go back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get notificationOpenBack;

  /// No description provided for @notificationCannotOpen.
  ///
  /// In en, this message translates to:
  /// **'This could not be opened. Sign in again, then open it from your dashboard.'**
  String get notificationCannotOpen;

  /// No description provided for @authLoginSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Login successful'**
  String get authLoginSuccessful;

  /// role is an account type such as Student.
  ///
  /// In en, this message translates to:
  /// **'{role} account already selected'**
  String authRoleAlreadySelected(String role);

  /// role is an account type such as Student.
  ///
  /// In en, this message translates to:
  /// **'{role} account selected'**
  String authRoleSelected(String role);

  /// step is a full instruction sentence.
  ///
  /// In en, this message translates to:
  /// **'Step {number}. {step}'**
  String authRecoveryStep(String number, String step);

  /// No description provided for @authEnterPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter phone number'**
  String get authEnterPhone;

  /// No description provided for @authEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter password'**
  String get authEnterPassword;

  /// No description provided for @authEnterName.
  ///
  /// In en, this message translates to:
  /// **'Enter name'**
  String get authEnterName;

  /// No description provided for @authRegistering.
  ///
  /// In en, this message translates to:
  /// **'Registering, please wait.'**
  String get authRegistering;

  /// No description provided for @authPasswordChanged.
  ///
  /// In en, this message translates to:
  /// **'Password changed. Signed in.'**
  String get authPasswordChanged;

  /// No description provided for @journeyWhereFinished.
  ///
  /// In en, this message translates to:
  /// **'Journey finished. {title}.'**
  String journeyWhereFinished(String title);

  /// kind is a step type such as Recording or Question; title is the journey name.
  ///
  /// In en, this message translates to:
  /// **'Step {number} of {total}. {kind}. {title}.'**
  String journeyWhere(String number, String total, String kind, String title);

  /// kind is a step type such as Recording or Question; title is the journey name.
  ///
  /// In en, this message translates to:
  /// **'Step {number} of {total}. {kind}. {title}. Listening again before the question.'**
  String journeyWhereReplaying(
    String number,
    String total,
    String kind,
    String title,
  );

  /// No description provided for @journeyKindRecording.
  ///
  /// In en, this message translates to:
  /// **'Recording'**
  String get journeyKindRecording;

  /// No description provided for @journeyKindNarration.
  ///
  /// In en, this message translates to:
  /// **'Narration'**
  String get journeyKindNarration;

  /// No description provided for @journeyKindQuestion.
  ///
  /// In en, this message translates to:
  /// **'Question'**
  String get journeyKindQuestion;

  /// No description provided for @journeyKindPoll.
  ///
  /// In en, this message translates to:
  /// **'Poll'**
  String get journeyKindPoll;

  /// One answer option read in a list of options.
  ///
  /// In en, this message translates to:
  /// **'Option {number}: {text}.'**
  String journeyOption(String number, String text);

  /// No description provided for @journeyChooseKeys.
  ///
  /// In en, this message translates to:
  /// **'Press 1 to {count} to choose, then 5 to submit.'**
  String journeyChooseKeys(String count);

  /// options is the list of spoken options; keys is the 'Press 1 to 4 to choose' help.
  ///
  /// In en, this message translates to:
  /// **'Poll. There is no wrong answer. {question} {options} {keys}'**
  String journeyPollQuestion(String question, String options, String keys);

  /// options is the list of spoken options; keys is the 'Press 1 to 4 to choose' help.
  ///
  /// In en, this message translates to:
  /// **'Question. {question} {options} {keys}'**
  String journeyQuestion(String question, String options, String keys);

  /// triesLeft is a sentence such as '1 try left.'
  ///
  /// In en, this message translates to:
  /// **'Question. Try again. {triesLeft} {question} {options} {keys}'**
  String journeyQuestionTryAgain(
    String triesLeft,
    String question,
    String options,
    String keys,
  );

  /// No description provided for @journeyTriesLeft.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 try left.} other{{count} tries left.}}'**
  String journeyTriesLeft(int count);

  /// No description provided for @journeyChosen.
  ///
  /// In en, this message translates to:
  /// **'Option {number}, {option}, selected. Press 5 to submit, or choose another number.'**
  String journeyChosen(String number, String option);

  /// No description provided for @journeyRecordingContent.
  ///
  /// In en, this message translates to:
  /// **'Recording: {title}. Press 5 to pause or play. Press 2 when you are ready to move on.'**
  String journeyRecordingContent(String title);

  /// No description provided for @journeyUntitled.
  ///
  /// In en, this message translates to:
  /// **'Untitled'**
  String get journeyUntitled;

  /// No description provided for @journeyContentKeys.
  ///
  /// In en, this message translates to:
  /// **'Press 2 for the next step, 3 to repeat this step, 1 to hear where you are, 8 to go back to the previous recording or narration.'**
  String get journeyContentKeys;

  /// answer is the text of the right option.
  ///
  /// In en, this message translates to:
  /// **'Correct! {answer}.'**
  String journeyCorrect(String answer);

  /// No description provided for @journeyPollSaved.
  ///
  /// In en, this message translates to:
  /// **'Thank you. Your answer is saved.'**
  String get journeyPollSaved;

  /// No description provided for @journeyReplayOutcome.
  ///
  /// In en, this message translates to:
  /// **'Not quite. Let us listen to that part again, then try once more.'**
  String get journeyReplayOutcome;

  /// No description provided for @journeyTryAgainOutcome.
  ///
  /// In en, this message translates to:
  /// **'Not quite. Think again and choose another answer.'**
  String get journeyTryAgainOutcome;

  /// explanation is the teacher's explanation, or empty.
  ///
  /// In en, this message translates to:
  /// **'Not quite. The answer is option {number}, {answer}. {explanation}'**
  String journeyRevealed(String number, String answer, String explanation);

  /// No description provided for @journeyWellDone.
  ///
  /// In en, this message translates to:
  /// **'Well done! You finished {title}.'**
  String journeyWellDone(String title);

  /// No description provided for @journeyFirstTryScore.
  ///
  /// In en, this message translates to:
  /// **'{questions, plural, =1{You answered {correct} of 1 question correctly on the first try.} other{You answered {correct} of {questions} questions correctly on the first try.}}'**
  String journeyFirstTryScore(int questions, String correct);

  /// No description provided for @journeyPlayAgainHelp.
  ///
  /// In en, this message translates to:
  /// **'Press 1 to play again, or 0 to go back to your journeys.'**
  String get journeyPlayAgainHelp;

  /// No description provided for @journeyStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get journeyStatusCompleted;

  /// No description provided for @journeyStatusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get journeyStatusInProgress;

  /// No description provided for @journeyStatusNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get journeyStatusNew;

  /// No description provided for @journeyRowScore.
  ///
  /// In en, this message translates to:
  /// **'Score {percent} percent.'**
  String journeyRowScore(String percent);

  /// No description provided for @journeyRowDownloaded.
  ///
  /// In en, this message translates to:
  /// **'Downloaded.'**
  String get journeyRowDownloaded;

  /// subject may be empty; status is Completed, In progress or New.
  ///
  /// In en, this message translates to:
  /// **'{title}. {subject}. {steps} steps, {questions} questions. {status}.'**
  String journeyStudentRow(
    String title,
    String subject,
    String steps,
    String questions,
    String status,
  );

  /// status describes the publishing state, e.g. 'Published'.
  ///
  /// In en, this message translates to:
  /// **'{title}. {status}. {steps} steps, {questions} questions.'**
  String journeyTeacherRow(
    String title,
    String status,
    String steps,
    String questions,
  );

  /// No description provided for @journeyRowGraded.
  ///
  /// In en, this message translates to:
  /// **'Graded.'**
  String get journeyRowGraded;

  /// name is the step's spoken name, e.g. 'Question. What is dal made from?'
  ///
  /// In en, this message translates to:
  /// **'Step {number} of {total}. {name}.'**
  String journeyStepRow(String number, String total, String name);

  /// No description provided for @journeyReplaysAutomatically.
  ///
  /// In en, this message translates to:
  /// **'Replays automatically.'**
  String get journeyReplaysAutomatically;

  /// No description provided for @journeyReplaysFrom.
  ///
  /// In en, this message translates to:
  /// **'Replays from step {number}.'**
  String journeyReplaysFrom(String number);

  /// No description provided for @journeyFinishedStatus.
  ///
  /// In en, this message translates to:
  /// **'Journey finished.'**
  String get journeyFinishedStatus;

  /// No description provided for @journeyRecordingPlaying.
  ///
  /// In en, this message translates to:
  /// **'Recording playing.'**
  String get journeyRecordingPlaying;

  /// No description provided for @journeyRecordingPaused.
  ///
  /// In en, this message translates to:
  /// **'Recording paused.'**
  String get journeyRecordingPaused;

  /// No description provided for @journeyNoOptionChosen.
  ///
  /// In en, this message translates to:
  /// **'No option chosen yet.'**
  String get journeyNoOptionChosen;

  /// No description provided for @journeyOptionSelected.
  ///
  /// In en, this message translates to:
  /// **'Option {number}, {option}, selected.'**
  String journeyOptionSelected(String number, String option);

  /// No description provided for @journeyPreviewStart.
  ///
  /// In en, this message translates to:
  /// **'Preview of {title}. Nothing is saved.'**
  String journeyPreviewStart(String title);

  /// No description provided for @journeyWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back to {title}. Continuing where you left off.'**
  String journeyWelcomeBack(String title);

  /// No description provided for @journeyStartingBrief.
  ///
  /// In en, this message translates to:
  /// **'Starting {title}.'**
  String journeyStartingBrief(String title);

  /// No description provided for @journeyStartingDetailed.
  ///
  /// In en, this message translates to:
  /// **'Starting {title}. {steps} steps. Press star at any time for help.'**
  String journeyStartingDetailed(String title, String steps);

  /// No description provided for @journeyNotSaved.
  ///
  /// In en, this message translates to:
  /// **'Your place could not be saved. {reason}'**
  String journeyNotSaved(String reason);

  /// No description provided for @journeyListeningAgain.
  ///
  /// In en, this message translates to:
  /// **'Listening again.'**
  String get journeyListeningAgain;

  /// text is the narration written by the teacher.
  ///
  /// In en, this message translates to:
  /// **'{text} Press 2 to continue.'**
  String journeyNarration(String text);

  /// No description provided for @journeyRecordingStatus.
  ///
  /// In en, this message translates to:
  /// **'Recording: {title}'**
  String journeyRecordingStatus(String title);

  /// No description provided for @journeyRecordingFailed.
  ///
  /// In en, this message translates to:
  /// **'This recording could not be played. Check your internet.'**
  String get journeyRecordingFailed;

  /// No description provided for @journeyRecordingRetry.
  ///
  /// In en, this message translates to:
  /// **'Press 3 to try again, or 2 to skip to the next step.'**
  String get journeyRecordingRetry;

  /// No description provided for @journeyNotDownloaded.
  ///
  /// In en, this message translates to:
  /// **'This recording is not downloaded on this phone.'**
  String get journeyNotDownloaded;

  /// No description provided for @journeyRecordingFinished.
  ///
  /// In en, this message translates to:
  /// **'Recording finished.'**
  String get journeyRecordingFinished;

  /// No description provided for @journeyAnswerFirst.
  ///
  /// In en, this message translates to:
  /// **'Answer first. Press 1 to {count} to choose, then 5.'**
  String journeyAnswerFirst(String count);

  /// No description provided for @journeyNoEarlierContent.
  ///
  /// In en, this message translates to:
  /// **'There is no earlier recording or narration.'**
  String get journeyNoEarlierContent;

  /// No description provided for @journeyGoingBack.
  ///
  /// In en, this message translates to:
  /// **'Going back.'**
  String get journeyGoingBack;

  /// No description provided for @journeyNoSuchOption.
  ///
  /// In en, this message translates to:
  /// **'There is no option {option}. Choose 1 to {count}.'**
  String journeyNoSuchOption(String option, String count);

  /// No description provided for @journeyChooseFirst.
  ///
  /// In en, this message translates to:
  /// **'Choose an answer first with 1 to {count}.'**
  String journeyChooseFirst(String count);

  /// No description provided for @journeySendLater.
  ///
  /// In en, this message translates to:
  /// **'Journey finished. Your answers will be sent when you are online.'**
  String get journeySendLater;

  /// No description provided for @journeyStartingAgain.
  ///
  /// In en, this message translates to:
  /// **'Starting again.'**
  String get journeyStartingAgain;

  /// No description provided for @journeyPaused.
  ///
  /// In en, this message translates to:
  /// **'Paused.'**
  String get journeyPaused;

  /// No description provided for @journeySeekRecordingsOnly.
  ///
  /// In en, this message translates to:
  /// **'Seeking works on recordings only.'**
  String get journeySeekRecordingsOnly;

  /// No description provided for @journeySpeedRecordingsOnly.
  ///
  /// In en, this message translates to:
  /// **'Recording speed changes on recordings only.'**
  String get journeySpeedRecordingsOnly;

  /// No description provided for @journeyFastest.
  ///
  /// In en, this message translates to:
  /// **'Fastest speed.'**
  String get journeyFastest;

  /// No description provided for @journeySlowest.
  ///
  /// In en, this message translates to:
  /// **'Slowest speed.'**
  String get journeySlowest;

  /// rate is a number such as 1.25
  ///
  /// In en, this message translates to:
  /// **'Recording speed {rate} times.'**
  String journeySpeed(String rate);

  /// No description provided for @journeyLeaveTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave this journey?'**
  String get journeyLeaveTitle;

  /// No description provided for @journeyLeaveMessage.
  ///
  /// In en, this message translates to:
  /// **'Your place is saved on this phone. Next time you can continue from step {step}.'**
  String journeyLeaveMessage(String step);

  /// No description provided for @journeyAnswerHelp.
  ///
  /// In en, this message translates to:
  /// **'Press a number to choose, 5 to submit, 6 to repeat the question.'**
  String get journeyAnswerHelp;

  /// No description provided for @journeyStepRemoved.
  ///
  /// In en, this message translates to:
  /// **'Step removed. The journey now has {remaining} steps.'**
  String journeyStepRemoved(String remaining);

  /// No description provided for @journeyStepRemovedUndo.
  ///
  /// In en, this message translates to:
  /// **'Removed {name}.'**
  String journeyStepRemovedUndo(String name);

  /// No description provided for @journeyStepRestored.
  ///
  /// In en, this message translates to:
  /// **'Step restored.'**
  String get journeyStepRestored;

  /// No description provided for @journeyCreated.
  ///
  /// In en, this message translates to:
  /// **'Created {title}. Now add its first step.'**
  String journeyCreated(String title);

  /// No description provided for @journeyNoStepAdded.
  ///
  /// In en, this message translates to:
  /// **'No step was added.'**
  String get journeyNoStepAdded;

  /// No description provided for @journeyPreviewSkips.
  ///
  /// In en, this message translates to:
  /// **'Some steps are skipped in this preview. {issues}'**
  String journeyPreviewSkips(String issues);

  /// No description provided for @journeyDuplicated.
  ///
  /// In en, this message translates to:
  /// **'Created {title} as a new draft. Find it under Drafts.'**
  String journeyDuplicated(String title);

  /// No description provided for @journeyArchiveMessage.
  ///
  /// In en, this message translates to:
  /// **'Students will no longer see {title}. Results are kept. You can restore it later.'**
  String journeyArchiveMessage(String title);

  /// No description provided for @journeyRestoreMessage.
  ///
  /// In en, this message translates to:
  /// **'Students will see {title} again.'**
  String journeyRestoreMessage(String title);

  /// No description provided for @journeyArchived.
  ///
  /// In en, this message translates to:
  /// **'Archived. Students no longer see it.'**
  String get journeyArchived;

  /// No description provided for @journeyRestored.
  ///
  /// In en, this message translates to:
  /// **'Restored for students.'**
  String get journeyRestored;

  /// No description provided for @journeyDeleteDraftMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete {title} permanently? Recordings stay in your library.'**
  String journeyDeleteDraftMessage(String title);

  /// No description provided for @journeyDraftDeleted.
  ///
  /// In en, this message translates to:
  /// **'Draft deleted.'**
  String get journeyDraftDeleted;

  /// No description provided for @journeyNoRetriesLeft.
  ///
  /// In en, this message translates to:
  /// **'Already no retries.'**
  String get journeyNoRetriesLeft;

  /// No description provided for @journeyMaxRetries.
  ///
  /// In en, this message translates to:
  /// **'Five retries is the most.'**
  String get journeyMaxRetries;

  /// No description provided for @journeyPublished.
  ///
  /// In en, this message translates to:
  /// **'Published. Students can play it now. Notifications reached {count} phones.'**
  String journeyPublished(String count);

  /// No description provided for @journeyOptionUsed.
  ///
  /// In en, this message translates to:
  /// **'That option is already used. Type a different option.'**
  String get journeyOptionUsed;

  /// No description provided for @journeyNothingToReplay.
  ///
  /// In en, this message translates to:
  /// **'There is no recording or narration before this question yet, so a wrong answer asks again. You can add content earlier and edit this later.'**
  String get journeyNothingToReplay;

  /// No description provided for @journeyBankEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your question bank for this class and subject is empty. Choose Write a new question instead.'**
  String get journeyBankEmpty;

  /// No description provided for @journeyRecordViaNotes.
  ///
  /// In en, this message translates to:
  /// **'Opening private notes. Record, review, then choose Publish to this class and subject. Come back with 0, and choose your new recording.'**
  String get journeyRecordViaNotes;

  /// No description provided for @journeyNoRecordings.
  ///
  /// In en, this message translates to:
  /// **'There are no audio files in this class and subject yet, so nothing was added. You are back on the previous screen. To add one, choose Recording again, then 2 to upload a recording file or 3 to record a new one.'**
  String get journeyNoRecordings;

  /// No description provided for @journeyOpeningFiles.
  ///
  /// In en, this message translates to:
  /// **'Opening the file chooser for an audio file.'**
  String get journeyOpeningFiles;

  /// No description provided for @journeyNoFile.
  ///
  /// In en, this message translates to:
  /// **'No file chosen.'**
  String get journeyNoFile;

  /// No description provided for @journeyUploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading. Please wait.'**
  String get journeyUploading;

  /// No description provided for @journeyUploadUnconfirmed.
  ///
  /// In en, this message translates to:
  /// **'The upload was not confirmed. Check My recordings before trying again, to avoid a duplicate.'**
  String get journeyUploadUnconfirmed;

  /// No description provided for @journeyUploaded.
  ///
  /// In en, this message translates to:
  /// **'Uploaded {title}.'**
  String journeyUploaded(String title);

  /// No description provided for @journeyStorageUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Journey storage is unavailable.'**
  String get journeyStorageUnavailable;

  /// No description provided for @journeyNothingInProgress.
  ///
  /// In en, this message translates to:
  /// **'There is no journey in progress. Press 2 for new journeys.'**
  String get journeyNothingInProgress;

  /// No description provided for @journeyTeacherUpdated.
  ///
  /// In en, this message translates to:
  /// **'Your teacher updated this journey. Download it again to play the new version offline.'**
  String get journeyTeacherUpdated;

  /// No description provided for @journeyStartOverMessage.
  ///
  /// In en, this message translates to:
  /// **'Start {title} again from step 1? Answers you already gave are still sent to your teacher.'**
  String journeyStartOverMessage(String title);

  /// No description provided for @journeyRemoveDownloadMessage.
  ///
  /// In en, this message translates to:
  /// **'Remove {title} from this phone? Your place in the journey is kept. You can download it again with internet.'**
  String journeyRemoveDownloadMessage(String title);

  /// No description provided for @journeyDownloadRemoved.
  ///
  /// In en, this message translates to:
  /// **'Removed the download of {title}.'**
  String journeyDownloadRemoved(String title);

  /// No description provided for @journeyDownloading.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Downloading 1 recording. Press 0 to cancel.} other{Downloading {count} recordings. Press 0 to cancel.}}'**
  String journeyDownloading(int count);

  /// No description provided for @journeyDownloaded.
  ///
  /// In en, this message translates to:
  /// **'Downloaded. You can play {title} without internet.'**
  String journeyDownloaded(String title);

  /// No description provided for @journeyCancellingDownload.
  ///
  /// In en, this message translates to:
  /// **'Cancelling download. Saved recordings are kept.'**
  String get journeyCancellingDownload;

  /// explanation is 'No explanation.' or 'Explanation: ...'.
  ///
  /// In en, this message translates to:
  /// **'{name} {options} Correct answer: option {number}. {explanation}'**
  String journeyStepDetailsQuestion(
    String name,
    String options,
    String number,
    String explanation,
  );

  /// No description provided for @journeyNoExplanation.
  ///
  /// In en, this message translates to:
  /// **'No explanation.'**
  String get journeyNoExplanation;

  /// No description provided for @journeyExplanation.
  ///
  /// In en, this message translates to:
  /// **'Explanation: {text}'**
  String journeyExplanation(String text);

  /// No description provided for @journeyStepNameRecording.
  ///
  /// In en, this message translates to:
  /// **'Recording. {title}'**
  String journeyStepNameRecording(String title);

  /// No description provided for @journeyUntitledRecording.
  ///
  /// In en, this message translates to:
  /// **'Untitled recording'**
  String get journeyUntitledRecording;

  /// No description provided for @journeyStepNameNarration.
  ///
  /// In en, this message translates to:
  /// **'Narration. {text}'**
  String journeyStepNameNarration(String text);

  /// No description provided for @journeyStepNameQuestion.
  ///
  /// In en, this message translates to:
  /// **'Question. {text}'**
  String journeyStepNameQuestion(String text);

  /// No description provided for @journeyStepNamePoll.
  ///
  /// In en, this message translates to:
  /// **'Poll. {text}'**
  String journeyStepNamePoll(String text);

  /// No description provided for @journeyStatusPublished.
  ///
  /// In en, this message translates to:
  /// **'Published'**
  String get journeyStatusPublished;

  /// No description provided for @journeyStatusArchived.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get journeyStatusArchived;

  /// No description provided for @journeyStatusDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft, not yet published'**
  String get journeyStatusDraft;

  /// No description provided for @journeyStatusWithChanges.
  ///
  /// In en, this message translates to:
  /// **'{status}, with unpublished changes'**
  String journeyStatusWithChanges(String status);

  /// No description provided for @journeyErrorChanged.
  ///
  /// In en, this message translates to:
  /// **'This journey changed. Refresh and try again.'**
  String get journeyErrorChanged;

  /// No description provided for @journeyErrorSignInExpired.
  ///
  /// In en, this message translates to:
  /// **'Your sign-in expired. Sign in again.'**
  String get journeyErrorSignInExpired;

  /// No description provided for @journeyErrorPermission.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to do that.'**
  String get journeyErrorPermission;

  /// No description provided for @journeyErrorNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'This journey is no longer available.'**
  String get journeyErrorNotAvailable;

  /// No description provided for @journeyErrorInvalid.
  ///
  /// In en, this message translates to:
  /// **'Some of the information could not be accepted. Check it and try again.'**
  String get journeyErrorInvalid;

  /// No description provided for @journeyErrorServer.
  ///
  /// In en, this message translates to:
  /// **'The school server had a problem. Try again later.'**
  String get journeyErrorServer;

  /// No description provided for @journeyErrorRequestFailed.
  ///
  /// In en, this message translates to:
  /// **'The request did not succeed. Try again.'**
  String get journeyErrorRequestFailed;

  /// No description provided for @journeyErrorResponseUnreadable.
  ///
  /// In en, this message translates to:
  /// **'The server response could not be read. Refresh before trying again.'**
  String get journeyErrorResponseUnreadable;

  /// No description provided for @journeyErrorSavedUnreadable.
  ///
  /// In en, this message translates to:
  /// **'The saved journey could not be read. Refresh before trying again.'**
  String get journeyErrorSavedUnreadable;

  /// No description provided for @journeyErrorListUnreadable.
  ///
  /// In en, this message translates to:
  /// **'The journey list could not be read.'**
  String get journeyErrorListUnreadable;

  /// No description provided for @journeyErrorMismatch.
  ///
  /// In en, this message translates to:
  /// **'The saved journey did not match. Refresh before trying again.'**
  String get journeyErrorMismatch;

  /// No description provided for @journeyErrorPreviewUnreadable.
  ///
  /// In en, this message translates to:
  /// **'The journey preview could not be read.'**
  String get journeyErrorPreviewUnreadable;

  /// No description provided for @journeyErrorRecordingsUnreadable.
  ///
  /// In en, this message translates to:
  /// **'The recording list could not be read.'**
  String get journeyErrorRecordingsUnreadable;

  /// No description provided for @journeyErrorBankUnreadable.
  ///
  /// In en, this message translates to:
  /// **'The question bank could not be read.'**
  String get journeyErrorBankUnreadable;

  /// No description provided for @journeyErrorJourneyUnreadable.
  ///
  /// In en, this message translates to:
  /// **'This journey could not be read.'**
  String get journeyErrorJourneyUnreadable;

  /// No description provided for @journeyDownloadNeedsApp.
  ///
  /// In en, this message translates to:
  /// **'Downloading for offline use needs the SEEDS Android app. In the browser, journeys play while you are online.'**
  String get journeyDownloadNeedsApp;

  /// No description provided for @journeySignInFirst.
  ///
  /// In en, this message translates to:
  /// **'Sign in before opening learning journeys.'**
  String get journeySignInFirst;

  /// No description provided for @journeyStorageUnavailableDevice.
  ///
  /// In en, this message translates to:
  /// **'Journey storage is unavailable on this device.'**
  String get journeyStorageUnavailableDevice;

  /// No description provided for @journeyStorageFull.
  ///
  /// In en, this message translates to:
  /// **'Journey storage is unavailable. Check free space and try again. Nothing was deleted.'**
  String get journeyStorageFull;

  /// No description provided for @journeyDownloadCancelled.
  ///
  /// In en, this message translates to:
  /// **'Download cancelled. Recordings already saved are kept.'**
  String get journeyDownloadCancelled;

  /// No description provided for @journeyRecordingsSaved.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} recordings are saved.'**
  String journeyRecordingsSaved(String done, String total);

  /// Button label.
  ///
  /// In en, this message translates to:
  /// **'Leave journey'**
  String get journeyLeaveJourney;

  /// Button label.
  ///
  /// In en, this message translates to:
  /// **'Leave journey. Your place is saved'**
  String get journeyLeaveSaved;

  /// Button label.
  ///
  /// In en, this message translates to:
  /// **'Play again'**
  String get journeyKeyPlayAgain;

  /// Button label.
  ///
  /// In en, this message translates to:
  /// **'Submit answer'**
  String get journeyKeySubmitAnswer;

  /// Button label.
  ///
  /// In en, this message translates to:
  /// **'Repeat question'**
  String get journeyKeyRepeatQuestion;

  /// Button label.
  ///
  /// In en, this message translates to:
  /// **'Slower speech'**
  String get journeyKeySlowerSpeech;

  /// Button label.
  ///
  /// In en, this message translates to:
  /// **'Where am I'**
  String get journeyKeyWhereAmI;

  /// Button label.
  ///
  /// In en, this message translates to:
  /// **'Faster speech'**
  String get journeyKeyFasterSpeech;

  /// Button label.
  ///
  /// In en, this message translates to:
  /// **'Next step'**
  String get journeyKeyNextStep;

  /// Button label.
  ///
  /// In en, this message translates to:
  /// **'Repeat this step'**
  String get journeyKeyRepeatStep;

  /// Button label.
  ///
  /// In en, this message translates to:
  /// **'Read again'**
  String get journeyKeyReadAgain;

  /// Button label.
  ///
  /// In en, this message translates to:
  /// **'Previous recording or narration'**
  String get journeyKeyPreviousContent;

  /// No description provided for @journeyPreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Preview: {title}'**
  String journeyPreviewTitle(String title);

  /// No description provided for @journeyPositionFinished.
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get journeyPositionFinished;

  /// No description provided for @journeyStepPosition.
  ///
  /// In en, this message translates to:
  /// **'Step {number} of {total}'**
  String journeyStepPosition(String number, String total);

  /// No description provided for @journeySelectedLabel.
  ///
  /// In en, this message translates to:
  /// **'{label}, selected'**
  String journeySelectedLabel(String label);

  /// No description provided for @journeyResultsLoading.
  ///
  /// In en, this message translates to:
  /// **'Results are loading.'**
  String get journeyResultsLoading;

  /// No description provided for @journeyResultsSummary.
  ///
  /// In en, this message translates to:
  /// **'{completed} of {eligible} students finished. {inProgress} in progress, {notStarted} not started.'**
  String journeyResultsSummary(
    String completed,
    String eligible,
    String inProgress,
    String notStarted,
  );

  /// No description provided for @journeyResultsAverage.
  ///
  /// In en, this message translates to:
  /// **'Average first-try score {percent} percent.'**
  String journeyResultsAverage(String percent);

  /// No description provided for @journeyResultFinished.
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get journeyResultFinished;

  /// No description provided for @journeyResultNotStarted.
  ///
  /// In en, this message translates to:
  /// **'Not started'**
  String get journeyResultNotStarted;

  /// name is a student's name; status is Finished, In progress or Not started.
  ///
  /// In en, this message translates to:
  /// **'{name}. {status}.'**
  String journeyResultStudent(String name, String status);

  /// No description provided for @journeyResultFirstTime.
  ///
  /// In en, this message translates to:
  /// **'{correct} of {total} right first time.'**
  String journeyResultFirstTime(String correct, String total);

  /// No description provided for @journeyResultWrongAnswers.
  ///
  /// In en, this message translates to:
  /// **'{count} wrong answers.'**
  String journeyResultWrongAnswers(String count);

  /// text is the question; answered is how many students answered.
  ///
  /// In en, this message translates to:
  /// **'Step {number}. {text}. {answered} answered.'**
  String journeyResultQuestion(String number, String text, String answered);

  /// No description provided for @journeyResultRate.
  ///
  /// In en, this message translates to:
  /// **'{percent} percent right first time.'**
  String journeyResultRate(String percent);

  /// No description provided for @journeyResultNoAnswers.
  ///
  /// In en, this message translates to:
  /// **'No answers yet.'**
  String get journeyResultNoAnswers;

  /// No description provided for @journeyResultAverageTries.
  ///
  /// In en, this message translates to:
  /// **'Average {attempts} tries.'**
  String journeyResultAverageTries(String attempts);

  /// options lists each option with its count, e.g. 'Yes: 4, No: 2'.
  ///
  /// In en, this message translates to:
  /// **'Step {number}. {text}. {answered} answered. {options}.'**
  String journeyResultPoll(
    String number,
    String text,
    String answered,
    String options,
  );

  /// No description provided for @journeyResultsStudentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Students'**
  String get journeyResultsStudentsTitle;

  /// No description provided for @journeyResultsQuestionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Questions'**
  String get journeyResultsQuestionsTitle;

  /// No description provided for @journeyResultsPollsTitle.
  ///
  /// In en, this message translates to:
  /// **'Poll answers'**
  String get journeyResultsPollsTitle;

  /// No description provided for @journeyResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'Results: {title}'**
  String journeyResultsTitle(String title);

  /// No description provided for @journeyResultsHearSummary.
  ///
  /// In en, this message translates to:
  /// **'Hear class summary'**
  String get journeyResultsHearSummary;

  /// No description provided for @journeyResultsStudents.
  ///
  /// In en, this message translates to:
  /// **'Students, {count}'**
  String journeyResultsStudents(String count);

  /// No description provided for @journeyResultsQuestions.
  ///
  /// In en, this message translates to:
  /// **'Questions, {count}. Shows which parts need teaching again'**
  String journeyResultsQuestions(String count);

  /// No description provided for @journeyResultsPolls.
  ///
  /// In en, this message translates to:
  /// **'Poll answers, {count}'**
  String journeyResultsPolls(String count);

  /// No description provided for @journeyResultsRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh results'**
  String get journeyResultsRefresh;

  /// No description provided for @journeyResultsNoStudents.
  ///
  /// In en, this message translates to:
  /// **'No students are in this class.'**
  String get journeyResultsNoStudents;

  /// No description provided for @journeyResultsNoQuestions.
  ///
  /// In en, this message translates to:
  /// **'This journey has no questions.'**
  String get journeyResultsNoQuestions;

  /// No description provided for @journeyResultsNoPolls.
  ///
  /// In en, this message translates to:
  /// **'This journey has no polls.'**
  String get journeyResultsNoPolls;

  /// No description provided for @journeyNarrationLabel.
  ///
  /// In en, this message translates to:
  /// **'Words the phone reads aloud, for example: Let us hear about some food today'**
  String get journeyNarrationLabel;

  /// No description provided for @journeyAddOptionTitle.
  ///
  /// In en, this message translates to:
  /// **'Add option {number}?'**
  String journeyAddOptionTitle(String number);

  /// No description provided for @journeyQuestionOptionsSoFar.
  ///
  /// In en, this message translates to:
  /// **'The question has {count} options so far.'**
  String journeyQuestionOptionsSoFar(String count);

  /// No description provided for @journeyPollOptionsSoFar.
  ///
  /// In en, this message translates to:
  /// **'The poll has {count} options so far.'**
  String journeyPollOptionsSoFar(String count);

  /// No description provided for @journeyAddOption.
  ///
  /// In en, this message translates to:
  /// **'Add option {number}'**
  String journeyAddOption(String number);

  /// No description provided for @journeyNoMoreOptions.
  ///
  /// In en, this message translates to:
  /// **'No more options, continue'**
  String get journeyNoMoreOptions;

  /// No description provided for @journeyOptionTitle.
  ///
  /// In en, this message translates to:
  /// **'Option {number}'**
  String journeyOptionTitle(String number);

  /// No description provided for @journeyTypeOption.
  ///
  /// In en, this message translates to:
  /// **'Type option {number}'**
  String journeyTypeOption(String number);

  /// No description provided for @journeyReplayAutoNone.
  ///
  /// In en, this message translates to:
  /// **'Automatic: ask again without replaying'**
  String get journeyReplayAutoNone;

  /// No description provided for @journeyReplayAutoFrom.
  ///
  /// In en, this message translates to:
  /// **'Automatic: replay from step {number}, {name}'**
  String journeyReplayAutoFrom(String number, String name);

  /// No description provided for @journeyAfterWrongTitle.
  ///
  /// In en, this message translates to:
  /// **'After a wrong answer'**
  String get journeyAfterWrongTitle;

  /// No description provided for @journeyAfterWrongIntro.
  ///
  /// In en, this message translates to:
  /// **'When a student answers wrongly, which part should play again before they try once more?'**
  String get journeyAfterWrongIntro;

  /// No description provided for @journeyReplayChooseStep.
  ///
  /// In en, this message translates to:
  /// **'Choose a different step to replay'**
  String get journeyReplayChooseStep;

  /// No description provided for @journeyReplayWhichStep.
  ///
  /// In en, this message translates to:
  /// **'Replay from which step?'**
  String get journeyReplayWhichStep;

  /// No description provided for @journeyStepLabel.
  ///
  /// In en, this message translates to:
  /// **'Step {number}. {name}'**
  String journeyStepLabel(String number, String name);

  /// No description provided for @journeyReviewReplayFrom.
  ///
  /// In en, this message translates to:
  /// **'After a wrong answer, step {number} plays again.'**
  String journeyReviewReplayFrom(String number);

  /// No description provided for @journeyReviewReplayAuto.
  ///
  /// In en, this message translates to:
  /// **'After a wrong answer, it replays automatically.'**
  String get journeyReviewReplayAuto;

  /// No description provided for @journeyCheckBeforeSaving.
  ///
  /// In en, this message translates to:
  /// **'Check before saving'**
  String get journeyCheckBeforeSaving;

  /// No description provided for @journeySaveStep.
  ///
  /// In en, this message translates to:
  /// **'Save this step'**
  String get journeySaveStep;

  /// No description provided for @journeyRestartStep.
  ///
  /// In en, this message translates to:
  /// **'Start this step again'**
  String get journeyRestartStep;

  /// No description provided for @journeyQuestionLabel.
  ///
  /// In en, this message translates to:
  /// **'Type the question students will hear'**
  String get journeyQuestionLabel;

  /// No description provided for @journeyWhichCorrect.
  ///
  /// In en, this message translates to:
  /// **'Which option is correct?'**
  String get journeyWhichCorrect;

  /// No description provided for @journeyCurrentlyCorrect.
  ///
  /// In en, this message translates to:
  /// **'Currently option {number} is correct.'**
  String journeyCurrentlyCorrect(String number);

  /// No description provided for @journeyOptionChoice.
  ///
  /// In en, this message translates to:
  /// **'Option {number}: {text}'**
  String journeyOptionChoice(String number, String text);

  /// No description provided for @journeyExplanationTitle.
  ///
  /// In en, this message translates to:
  /// **'Explanation'**
  String get journeyExplanationTitle;

  /// No description provided for @journeyExplanationLabel.
  ///
  /// In en, this message translates to:
  /// **'What students hear after the right answer is revealed'**
  String get journeyExplanationLabel;

  /// No description provided for @journeyPollQuestionTitle.
  ///
  /// In en, this message translates to:
  /// **'Poll question'**
  String get journeyPollQuestionTitle;

  /// No description provided for @journeyPollQuestionLabel.
  ///
  /// In en, this message translates to:
  /// **'A question with no wrong answer, for example: Have you eaten rice this week?'**
  String get journeyPollQuestionLabel;

  /// No description provided for @journeyQuestionBank.
  ///
  /// In en, this message translates to:
  /// **'Question bank'**
  String get journeyQuestionBank;

  /// No description provided for @journeyBankQuestionLabel.
  ///
  /// In en, this message translates to:
  /// **'{text}. {count} options.'**
  String journeyBankQuestionLabel(String text, String count);

  /// No description provided for @journeyAddRecording.
  ///
  /// In en, this message translates to:
  /// **'Add a recording'**
  String get journeyAddRecording;

  /// No description provided for @journeyChooseMyRecordings.
  ///
  /// In en, this message translates to:
  /// **'Choose from my recordings'**
  String get journeyChooseMyRecordings;

  /// No description provided for @journeyUploadRecordingFile.
  ///
  /// In en, this message translates to:
  /// **'Upload a recording file'**
  String get journeyUploadRecordingFile;

  /// No description provided for @journeyRecordNew.
  ///
  /// In en, this message translates to:
  /// **'Record a new recording'**
  String get journeyRecordNew;

  /// No description provided for @journeyMyRecordings.
  ///
  /// In en, this message translates to:
  /// **'My recordings'**
  String get journeyMyRecordings;

  /// No description provided for @journeyRecordingName.
  ///
  /// In en, this message translates to:
  /// **'Recording name'**
  String get journeyRecordingName;

  /// No description provided for @journeyRecordingNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name for this recording'**
  String get journeyRecordingNameLabel;

  /// No description provided for @journeyOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'{label}. Optional, leave empty to skip'**
  String journeyOptionalLabel(String label);

  /// No description provided for @journeyNothingEntered.
  ///
  /// In en, this message translates to:
  /// **'Nothing entered. Press OK on the field and type, or press 0 to go back.'**
  String get journeyNothingEntered;

  /// No description provided for @journeyTooLong.
  ///
  /// In en, this message translates to:
  /// **'Too long. Use at most {max} characters.'**
  String journeyTooLong(String max);

  /// No description provided for @journeySkipped.
  ///
  /// In en, this message translates to:
  /// **'Skipped.'**
  String get journeySkipped;

  /// No description provided for @journeyYouEntered.
  ///
  /// In en, this message translates to:
  /// **'You entered: {text}'**
  String journeyYouEntered(String text);

  /// No description provided for @journeyMenuReady.
  ///
  /// In en, this message translates to:
  /// **'Ready.'**
  String get journeyMenuReady;

  /// No description provided for @journeyMenuNothingAssigned.
  ///
  /// In en, this message translates to:
  /// **'Nothing is assigned to {number}.'**
  String journeyMenuNothingAssigned(String number);

  /// No description provided for @journeyMenuPleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Please wait. Still working. Press 0 to go back.'**
  String get journeyMenuPleaseWait;

  /// No description provided for @journeyMenuWorking.
  ///
  /// In en, this message translates to:
  /// **'Working, please wait.'**
  String get journeyMenuWorking;

  /// Button label.
  ///
  /// In en, this message translates to:
  /// **'Read details again'**
  String get journeyMenuReadDetails;

  /// No description provided for @journeyNoInternetDownloaded.
  ///
  /// In en, this message translates to:
  /// **'No internet. Downloaded journeys still work. Press 5 for downloaded journeys.'**
  String get journeyNoInternetDownloaded;

  /// No description provided for @journeyWaitingToSend.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 finished journey is waiting to be sent.} other{{count} finished journeys are waiting to be sent.}}'**
  String journeyWaitingToSend(int count);

  /// No description provided for @journeyStudentSummary.
  ///
  /// In en, this message translates to:
  /// **'{newCount} new, {inProgress} in progress, {completed} completed, {downloaded} downloaded.'**
  String journeyStudentSummary(
    String newCount,
    String inProgress,
    String completed,
    String downloaded,
  );

  /// No description provided for @journeyDownloadedJourneys.
  ///
  /// In en, this message translates to:
  /// **'Downloaded journeys'**
  String get journeyDownloadedJourneys;

  /// No description provided for @journeyDownloadedRow.
  ///
  /// In en, this message translates to:
  /// **'{title}. {steps} steps. Downloaded.'**
  String journeyDownloadedRow(String title, String steps);

  /// No description provided for @journeyOfflineReason.
  ///
  /// In en, this message translates to:
  /// **'This needs internet. Press 5 for downloaded journeys.'**
  String get journeyOfflineReason;

  /// No description provided for @journeyLearningJourneys.
  ///
  /// In en, this message translates to:
  /// **'Learning journeys'**
  String get journeyLearningJourneys;

  /// No description provided for @journeyStudentIntro.
  ///
  /// In en, this message translates to:
  /// **'Listen to stories and lessons, answer questions as you go, and repeat parts you need.'**
  String get journeyStudentIntro;

  /// No description provided for @journeyContinueLast.
  ///
  /// In en, this message translates to:
  /// **'Continue my last journey'**
  String get journeyContinueLast;

  /// No description provided for @journeyNewJourneys.
  ///
  /// In en, this message translates to:
  /// **'New journeys, {count}'**
  String journeyNewJourneys(String count);

  /// No description provided for @journeyNewJourneysTitle.
  ///
  /// In en, this message translates to:
  /// **'New journeys'**
  String get journeyNewJourneysTitle;

  /// No description provided for @journeyNoNewJourneys.
  ///
  /// In en, this message translates to:
  /// **'There are no new journeys.'**
  String get journeyNoNewJourneys;

  /// No description provided for @journeyInProgressCount.
  ///
  /// In en, this message translates to:
  /// **'In progress, {count}'**
  String journeyInProgressCount(String count);

  /// No description provided for @journeyInProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Journeys in progress'**
  String get journeyInProgressTitle;

  /// No description provided for @journeyNothingInProgressShort.
  ///
  /// In en, this message translates to:
  /// **'Nothing is in progress.'**
  String get journeyNothingInProgressShort;

  /// No description provided for @journeyCompletedCount.
  ///
  /// In en, this message translates to:
  /// **'Completed, {count}'**
  String journeyCompletedCount(String count);

  /// No description provided for @journeyCompletedTitle.
  ///
  /// In en, this message translates to:
  /// **'Completed journeys'**
  String get journeyCompletedTitle;

  /// No description provided for @journeyNoneCompleted.
  ///
  /// In en, this message translates to:
  /// **'No journeys completed yet.'**
  String get journeyNoneCompleted;

  /// No description provided for @journeyDownloadedCount.
  ///
  /// In en, this message translates to:
  /// **'Downloaded, {count}'**
  String journeyDownloadedCount(String count);

  /// No description provided for @journeyNothingDownloaded.
  ///
  /// In en, this message translates to:
  /// **'Nothing is downloaded. Open a journey and choose Download.'**
  String get journeyNothingDownloaded;

  /// No description provided for @journeyNoInternetNotDownloaded.
  ///
  /// In en, this message translates to:
  /// **'No internet, and this journey is not downloaded.'**
  String get journeyNoInternetNotDownloaded;

  /// No description provided for @journeyStartOverTitle.
  ///
  /// In en, this message translates to:
  /// **'Start over?'**
  String get journeyStartOverTitle;

  /// Button label.
  ///
  /// In en, this message translates to:
  /// **'Start over'**
  String get journeyStartOver;

  /// No description provided for @journeyRemoveDownloadTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove download?'**
  String get journeyRemoveDownloadTitle;

  /// Button label.
  ///
  /// In en, this message translates to:
  /// **'Remove download'**
  String get journeyRemoveDownload;

  /// No description provided for @journeySavedRecordings.
  ///
  /// In en, this message translates to:
  /// **'Saved {done} of {total} recordings.'**
  String journeySavedRecordings(String done, String total);

  /// No description provided for @journeyDownloadedOnPhone.
  ///
  /// In en, this message translates to:
  /// **'Downloaded on this phone.'**
  String get journeyDownloadedOnPhone;

  /// No description provided for @journeyNotDownloadedShort.
  ///
  /// In en, this message translates to:
  /// **'Not downloaded.'**
  String get journeyNotDownloadedShort;

  /// No description provided for @journeyStartedThis.
  ///
  /// In en, this message translates to:
  /// **'You have started this journey.'**
  String get journeyStartedThis;

  /// No description provided for @journeyWorksOffline.
  ///
  /// In en, this message translates to:
  /// **'Downloaded. Works without internet.'**
  String get journeyWorksOffline;

  /// No description provided for @journeyContinueJourney.
  ///
  /// In en, this message translates to:
  /// **'Continue journey'**
  String get journeyContinueJourney;

  /// No description provided for @journeyStartJourney.
  ///
  /// In en, this message translates to:
  /// **'Start journey'**
  String get journeyStartJourney;

  /// No description provided for @journeyHearAbout.
  ///
  /// In en, this message translates to:
  /// **'Hear about this journey'**
  String get journeyHearAbout;

  /// No description provided for @journeyDownloadOffline.
  ///
  /// In en, this message translates to:
  /// **'Download to play without internet'**
  String get journeyDownloadOffline;

  /// No description provided for @journeyDownloadInProgress.
  ///
  /// In en, this message translates to:
  /// **'A download is in progress. Press 0 to cancel it.'**
  String get journeyDownloadInProgress;

  /// No description provided for @journeyStartFromBeginning.
  ///
  /// In en, this message translates to:
  /// **'Start over from the beginning'**
  String get journeyStartFromBeginning;

  /// No description provided for @journeyNotStartedYet.
  ///
  /// In en, this message translates to:
  /// **'You have not started this journey yet.'**
  String get journeyNotStartedYet;

  /// message is an error from the server.
  ///
  /// In en, this message translates to:
  /// **'{message} The latest version is now loaded.'**
  String journeyLatestLoaded(String message);

  /// No description provided for @journeyTeacherSummary.
  ///
  /// In en, this message translates to:
  /// **'{drafts} drafts, {published} published, {archived} archived.'**
  String journeyTeacherSummary(
    String drafts,
    String published,
    String archived,
  );

  /// No description provided for @journeyNewJourneyTitle.
  ///
  /// In en, this message translates to:
  /// **'New learning journey'**
  String get journeyNewJourneyTitle;

  /// No description provided for @journeyNameExample.
  ///
  /// In en, this message translates to:
  /// **'Journey name, for example: Food around us'**
  String get journeyNameExample;

  /// No description provided for @journeyRefreshFirst.
  ///
  /// In en, this message translates to:
  /// **'Press 5 to refresh the list first.'**
  String get journeyRefreshFirst;

  /// workspace is the class and subject name.
  ///
  /// In en, this message translates to:
  /// **'{workspace}. Build one flow of recordings, narration, questions and polls for students.'**
  String journeyTeacherIntro(String workspace);

  /// No description provided for @journeyCreateNew.
  ///
  /// In en, this message translates to:
  /// **'Create a new journey'**
  String get journeyCreateNew;

  /// No description provided for @journeyDraftsCount.
  ///
  /// In en, this message translates to:
  /// **'Drafts, {count}'**
  String journeyDraftsCount(String count);

  /// No description provided for @journeyDraftJourneys.
  ///
  /// In en, this message translates to:
  /// **'Draft journeys'**
  String get journeyDraftJourneys;

  /// No description provided for @journeyNoDrafts.
  ///
  /// In en, this message translates to:
  /// **'There are no drafts.'**
  String get journeyNoDrafts;

  /// No description provided for @journeyPublishedCount.
  ///
  /// In en, this message translates to:
  /// **'Published, {count}'**
  String journeyPublishedCount(String count);

  /// No description provided for @journeyPublishedJourneys.
  ///
  /// In en, this message translates to:
  /// **'Published journeys'**
  String get journeyPublishedJourneys;

  /// No description provided for @journeyNothingPublished.
  ///
  /// In en, this message translates to:
  /// **'Nothing is published yet.'**
  String get journeyNothingPublished;

  /// No description provided for @journeyArchivedCount.
  ///
  /// In en, this message translates to:
  /// **'Archived, {count}'**
  String journeyArchivedCount(String count);

  /// No description provided for @journeyArchivedJourneys.
  ///
  /// In en, this message translates to:
  /// **'Archived journeys'**
  String get journeyArchivedJourneys;

  /// No description provided for @journeyNothingArchived.
  ///
  /// In en, this message translates to:
  /// **'Nothing is archived.'**
  String get journeyNothingArchived;

  /// No description provided for @journeyRefreshList.
  ///
  /// In en, this message translates to:
  /// **'Refresh list'**
  String get journeyRefreshList;

  /// graded is 'Graded' or 'Not graded'; retries is e.g. '1 retry per question.'
  ///
  /// In en, this message translates to:
  /// **'{status}. {steps} steps, {questions} questions. {graded}. {retries}'**
  String journeyOverviewSummary(
    String status,
    String steps,
    String questions,
    String graded,
    String retries,
  );

  /// No description provided for @journeyGraded.
  ///
  /// In en, this message translates to:
  /// **'Graded'**
  String get journeyGraded;

  /// No description provided for @journeyNotGraded.
  ///
  /// In en, this message translates to:
  /// **'Not graded'**
  String get journeyNotGraded;

  /// No description provided for @journeyRetriesPerQuestion.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 retry per question.} other{{count} retries per question.}}'**
  String journeyRetriesPerQuestion(int count);

  /// No description provided for @journeySteps.
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get journeySteps;

  /// No description provided for @journeyAddStepTitle.
  ///
  /// In en, this message translates to:
  /// **'Add step {number}'**
  String journeyAddStepTitle(String number);

  /// No description provided for @journeyAddStepIntro.
  ///
  /// In en, this message translates to:
  /// **'The new step goes at the end. You can move it later.'**
  String get journeyAddStepIntro;

  /// No description provided for @journeyChoiceRecording.
  ///
  /// In en, this message translates to:
  /// **'Recording'**
  String get journeyChoiceRecording;

  /// No description provided for @journeyChoiceNarration.
  ///
  /// In en, this message translates to:
  /// **'Narration read by the phone'**
  String get journeyChoiceNarration;

  /// No description provided for @journeyChoiceQuestion.
  ///
  /// In en, this message translates to:
  /// **'Question'**
  String get journeyChoiceQuestion;

  /// No description provided for @journeyChoicePoll.
  ///
  /// In en, this message translates to:
  /// **'Poll, no wrong answer'**
  String get journeyChoicePoll;

  /// No description provided for @journeySavedAsStep.
  ///
  /// In en, this message translates to:
  /// **'Saved as step {number}. {name}'**
  String journeySavedAsStep(String number, String name);

  /// No description provided for @journeyAddQuestion.
  ///
  /// In en, this message translates to:
  /// **'Add a question'**
  String get journeyAddQuestion;

  /// No description provided for @journeyWriteNewQuestion.
  ///
  /// In en, this message translates to:
  /// **'Write a new question'**
  String get journeyWriteNewQuestion;

  /// No description provided for @journeyChooseFromBank.
  ///
  /// In en, this message translates to:
  /// **'Choose from my question bank'**
  String get journeyChooseFromBank;

  /// No description provided for @journeyHearAndEdit.
  ///
  /// In en, this message translates to:
  /// **'Hear and edit steps'**
  String get journeyHearAndEdit;

  /// No description provided for @journeyNoStepsYet.
  ///
  /// In en, this message translates to:
  /// **'There are no steps yet. Press 2 to add one.'**
  String get journeyNoStepsYet;

  /// No description provided for @journeyAddStep.
  ///
  /// In en, this message translates to:
  /// **'Add a step'**
  String get journeyAddStep;

  /// No description provided for @journeyPreviewAsStudent.
  ///
  /// In en, this message translates to:
  /// **'Preview as a student'**
  String get journeyPreviewAsStudent;

  /// No description provided for @journeyAddStepFirst.
  ///
  /// In en, this message translates to:
  /// **'Add a step first.'**
  String get journeyAddStepFirst;

  /// No description provided for @journeyPublishToStudents.
  ///
  /// In en, this message translates to:
  /// **'Publish to students'**
  String get journeyPublishToStudents;

  /// No description provided for @journeyPublishChanges.
  ///
  /// In en, this message translates to:
  /// **'Publish changes'**
  String get journeyPublishChanges;

  /// No description provided for @journeyStudentResults.
  ///
  /// In en, this message translates to:
  /// **'Student results'**
  String get journeyStudentResults;

  /// No description provided for @journeyMoreOptions.
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get journeyMoreOptions;

  /// No description provided for @journeyStepSaved.
  ///
  /// In en, this message translates to:
  /// **'Step {number} saved.'**
  String journeyStepSaved(String number);

  /// No description provided for @journeyMoved.
  ///
  /// In en, this message translates to:
  /// **'Moved. This is now step {number} of {total}.'**
  String journeyMoved(String number, String total);

  /// No description provided for @journeyRemoveStepTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove step {number}?'**
  String journeyRemoveStepTitle(String number);

  /// No description provided for @journeyRemoveStepMessage.
  ///
  /// In en, this message translates to:
  /// **'Remove {name}? Recordings stay in your library. Questions that replayed this step will replay automatically instead.'**
  String journeyRemoveStepMessage(String name);

  /// Button label.
  ///
  /// In en, this message translates to:
  /// **'Remove step'**
  String get journeyRemoveStep;

  /// No description provided for @journeyStepNotFound.
  ///
  /// In en, this message translates to:
  /// **'Step not found'**
  String get journeyStepNotFound;

  /// No description provided for @journeyStepWasRemoved.
  ///
  /// In en, this message translates to:
  /// **'This step was removed. Press 0 to go back.'**
  String get journeyStepWasRemoved;

  /// No description provided for @journeyHearStepInFull.
  ///
  /// In en, this message translates to:
  /// **'Hear this step in full'**
  String get journeyHearStepInFull;

  /// No description provided for @journeyEditStep.
  ///
  /// In en, this message translates to:
  /// **'Edit this step'**
  String get journeyEditStep;

  /// No description provided for @journeyMoveEarlier.
  ///
  /// In en, this message translates to:
  /// **'Move earlier'**
  String get journeyMoveEarlier;

  /// No description provided for @journeyAlreadyFirst.
  ///
  /// In en, this message translates to:
  /// **'This is already the first step.'**
  String get journeyAlreadyFirst;

  /// No description provided for @journeyMoveLater.
  ///
  /// In en, this message translates to:
  /// **'Move later'**
  String get journeyMoveLater;

  /// No description provided for @journeyAlreadyLast.
  ///
  /// In en, this message translates to:
  /// **'This is already the last step.'**
  String get journeyAlreadyLast;

  /// No description provided for @journeyRemoveThisStep.
  ///
  /// In en, this message translates to:
  /// **'Remove this step'**
  String get journeyRemoveThisStep;

  /// No description provided for @journeyRenameTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename journey'**
  String get journeyRenameTitle;

  /// No description provided for @journeyNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Journey name'**
  String get journeyNameLabel;

  /// No description provided for @journeyRenamed.
  ///
  /// In en, this message translates to:
  /// **'Renamed to {title}.'**
  String journeyRenamed(String title);

  /// No description provided for @journeyArchiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Archive this journey?'**
  String get journeyArchiveTitle;

  /// No description provided for @journeyRestoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore this journey?'**
  String get journeyRestoreTitle;

  /// Button label.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get journeyArchive;

  /// Button label.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get journeyRestore;

  /// No description provided for @journeyDeleteDraftTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this draft?'**
  String get journeyDeleteDraftTitle;

  /// Button label.
  ///
  /// In en, this message translates to:
  /// **'Delete draft'**
  String get journeyDeleteDraft;

  /// No description provided for @journeyPublishFirst.
  ///
  /// In en, this message translates to:
  /// **'Publish the journey first.'**
  String get journeyPublishFirst;

  /// No description provided for @journeyRename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get journeyRename;

  /// No description provided for @journeyGradingNowGraded.
  ///
  /// In en, this message translates to:
  /// **'Grading and tries, now graded'**
  String get journeyGradingNowGraded;

  /// No description provided for @journeyGradingNowNotGraded.
  ///
  /// In en, this message translates to:
  /// **'Grading and tries, now not graded'**
  String get journeyGradingNowNotGraded;

  /// No description provided for @journeyDuplicate.
  ///
  /// In en, this message translates to:
  /// **'Duplicate as a new draft'**
  String get journeyDuplicate;

  /// No description provided for @journeyArchiveHide.
  ///
  /// In en, this message translates to:
  /// **'Archive, hide from students'**
  String get journeyArchiveHide;

  /// No description provided for @journeyRestoreForStudents.
  ///
  /// In en, this message translates to:
  /// **'Restore for students'**
  String get journeyRestoreForStudents;

  /// No description provided for @journeyDeleteThisDraft.
  ///
  /// In en, this message translates to:
  /// **'Delete this draft'**
  String get journeyDeleteThisDraft;

  /// No description provided for @journeyGradedSummary.
  ///
  /// In en, this message translates to:
  /// **'Graded: the first try at each question counts towards a score.'**
  String get journeyGradedSummary;

  /// No description provided for @journeyNotGradedSummary.
  ///
  /// In en, this message translates to:
  /// **'Not graded: questions are for practice only.'**
  String get journeyNotGradedSummary;

  /// No description provided for @journeyMoreTriesSummary.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{After a wrong answer, a student gets 1 more try, with the content replayed first.} other{After a wrong answer, a student gets {count} more tries, with the content replayed first.}}'**
  String journeyMoreTriesSummary(int count);

  /// No description provided for @journeyGradingTitle.
  ///
  /// In en, this message translates to:
  /// **'Grading and tries'**
  String get journeyGradingTitle;

  /// No description provided for @journeyTurnGradingOff.
  ///
  /// In en, this message translates to:
  /// **'Turn grading off'**
  String get journeyTurnGradingOff;

  /// No description provided for @journeyTurnGradingOn.
  ///
  /// In en, this message translates to:
  /// **'Turn grading on'**
  String get journeyTurnGradingOn;

  /// No description provided for @journeyGradingIsOff.
  ///
  /// In en, this message translates to:
  /// **'Grading is off.'**
  String get journeyGradingIsOff;

  /// No description provided for @journeyGradingIsOn.
  ///
  /// In en, this message translates to:
  /// **'Grading is on.'**
  String get journeyGradingIsOn;

  /// No description provided for @journeyFewerTries.
  ///
  /// In en, this message translates to:
  /// **'Fewer tries'**
  String get journeyFewerTries;

  /// No description provided for @journeyMoreTries.
  ///
  /// In en, this message translates to:
  /// **'More tries'**
  String get journeyMoreTries;

  /// No description provided for @journeyLoadingSummary.
  ///
  /// In en, this message translates to:
  /// **'Loading the summary.'**
  String get journeyLoadingSummary;

  /// No description provided for @journeyNoProblems.
  ///
  /// In en, this message translates to:
  /// **'No problems.'**
  String get journeyNoProblems;

  /// No description provided for @journeyProblems.
  ///
  /// In en, this message translates to:
  /// **'Problems to fix before publishing: {issues}'**
  String journeyProblems(String issues);

  /// No description provided for @journeyThingsToCheck.
  ///
  /// In en, this message translates to:
  /// **'Things to check: {warnings}'**
  String journeyThingsToCheck(String warnings);

  /// graded is 'Graded' or 'Not graded'.
  ///
  /// In en, this message translates to:
  /// **'{title}. {steps} steps: {recordings} recordings, {narrations} narrations, {questions} questions, {polls} polls. {graded}.'**
  String journeyPublishSummary(
    String title,
    String steps,
    String recordings,
    String narrations,
    String questions,
    String polls,
    String graded,
  );

  /// No description provided for @journeyPublishTitle.
  ///
  /// In en, this message translates to:
  /// **'Publish {title}?'**
  String journeyPublishTitle(String title);

  /// No description provided for @journeyPublishMessage.
  ///
  /// In en, this message translates to:
  /// **'All students in this class will be able to play and download it, and they will get a notification.'**
  String get journeyPublishMessage;

  /// No description provided for @journeyPublishNow.
  ///
  /// In en, this message translates to:
  /// **'Publish now'**
  String get journeyPublishNow;

  /// No description provided for @journeyPublishedShort.
  ///
  /// In en, this message translates to:
  /// **'Published.'**
  String get journeyPublishedShort;

  /// No description provided for @journeyReviewBeforePublishing.
  ///
  /// In en, this message translates to:
  /// **'Review before publishing'**
  String get journeyReviewBeforePublishing;

  /// No description provided for @journeyFixProblemsFirst.
  ///
  /// In en, this message translates to:
  /// **'Fix the problems first. Press 8 to hear them.'**
  String get journeyFixProblemsFirst;

  /// No description provided for @journeyPreviewFirst.
  ///
  /// In en, this message translates to:
  /// **'Preview as a student first'**
  String get journeyPreviewFirst;

  /// No description provided for @undoOffer.
  ///
  /// In en, this message translates to:
  /// **'Press 1 within {seconds} seconds to undo.'**
  String undoOffer(String seconds);

  /// action is the earlier message without its full stop, e.g. 'Removed the download of Food'.
  ///
  /// In en, this message translates to:
  /// **'Undone. {action} was reversed.'**
  String undoDone(String action);

  /// No description provided for @undoFailed.
  ///
  /// In en, this message translates to:
  /// **'Undo did not work. Check the item and add it again if needed.'**
  String get undoFailed;

  /// Button label.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get uiBack;

  /// Button label.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get uiCancel;

  /// Button label.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get uiContinue;

  /// Default cancel button label in confirmation dialogs.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get uiNotNow;

  /// One numbered choice, e.g. 'Press 1 for Search.'
  ///
  /// In en, this message translates to:
  /// **'Press {key} for {action}.'**
  String uiPressFor(String key, String action);

  /// No description provided for @uiLabelUnavailable.
  ///
  /// In en, this message translates to:
  /// **'{label}, unavailable'**
  String uiLabelUnavailable(String label);

  /// No description provided for @uiAlreadyHome.
  ///
  /// In en, this message translates to:
  /// **'You are already home.'**
  String get uiAlreadyHome;

  /// No description provided for @uiNotAvailableNow.
  ///
  /// In en, this message translates to:
  /// **'{label} is not available right now.'**
  String uiNotAvailableNow(String label);

  /// No description provided for @uiListLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading {title}. Press 0 to go back.'**
  String uiListLoading(String title);

  /// No description provided for @uiListPage.
  ///
  /// In en, this message translates to:
  /// **'{title}. Page {number}.'**
  String uiListPage(String title, String number);

  /// No description provided for @uiListScreenName.
  ///
  /// In en, this message translates to:
  /// **'{title}. Page {number}'**
  String uiListScreenName(String title, String number);

  /// No description provided for @uiListNoMatches.
  ///
  /// In en, this message translates to:
  /// **'No matching items.'**
  String get uiListNoMatches;

  /// No description provided for @uiListHelp.
  ///
  /// In en, this message translates to:
  /// **'Press 6 for list options, including refresh. Press 7 for the previous page. Press 8 to search all items. Press 9 for the next page. Press 0 to go back. Use D-pad up and down to move between items and page controls, and OK to select. Press star to repeat help. Press hash to stop speech.'**
  String get uiListHelp;

  /// No description provided for @uiListLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'This page could not be loaded. Press 6 for retry options. Your previous page is kept.'**
  String get uiListLoadFailed;

  /// No description provided for @uiListLoadingWait.
  ///
  /// In en, this message translates to:
  /// **'Loading. Please wait, or press 0 to go back.'**
  String get uiListLoadingWait;

  /// No description provided for @uiListNoItem.
  ///
  /// In en, this message translates to:
  /// **'No item is assigned to {number} on this page.'**
  String uiListNoItem(String number);

  /// No description provided for @uiListFirstPage.
  ///
  /// In en, this message translates to:
  /// **'This is the first page.'**
  String get uiListFirstPage;

  /// No description provided for @uiListLastPage.
  ///
  /// In en, this message translates to:
  /// **'This is the last page.'**
  String get uiListLastPage;

  /// No description provided for @uiListSearchTitle.
  ///
  /// In en, this message translates to:
  /// **'Search {title}'**
  String uiListSearchTitle(String title);

  /// No description provided for @uiListSearchLabel.
  ///
  /// In en, this message translates to:
  /// **'Search all available items'**
  String get uiListSearchLabel;

  /// No description provided for @uiListSearchTooLong.
  ///
  /// In en, this message translates to:
  /// **'Use at most 200 characters for search.'**
  String get uiListSearchTooLong;

  /// No description provided for @uiListOptions.
  ///
  /// In en, this message translates to:
  /// **'List options'**
  String get uiListOptions;

  /// No description provided for @uiListSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get uiListSearch;

  /// No description provided for @uiListClearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get uiListClearSearch;

  /// No description provided for @uiListRefreshPage.
  ///
  /// In en, this message translates to:
  /// **'Refresh this page'**
  String get uiListRefreshPage;

  /// No description provided for @uiListRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get uiListRetry;

  /// No description provided for @uiListFilters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get uiListFilters;

  /// No description provided for @uiListPreviousPage.
  ///
  /// In en, this message translates to:
  /// **'Previous page'**
  String get uiListPreviousPage;

  /// No description provided for @uiListSearchAll.
  ///
  /// In en, this message translates to:
  /// **'Search all items'**
  String get uiListSearchAll;

  /// No description provided for @uiListNextPage.
  ///
  /// In en, this message translates to:
  /// **'Next page'**
  String get uiListNextPage;

  /// Completes 'Use D-pad up and down to move through ...'.
  ///
  /// In en, this message translates to:
  /// **'items, list options, previous page, search, next page and back'**
  String get uiListSections;

  /// No description provided for @uiWaitingConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Waiting for confirmation. Please wait.'**
  String get uiWaitingConfirmation;

  /// No description provided for @uiFinishWord.
  ///
  /// In en, this message translates to:
  /// **'Finish entering the current word, then press OK.'**
  String get uiFinishWord;

  /// No description provided for @uiStepFailed.
  ///
  /// In en, this message translates to:
  /// **'This step could not be completed. Your entry is kept. Try again.'**
  String get uiStepFailed;

  /// No description provided for @uiPasswordVisible.
  ///
  /// In en, this message translates to:
  /// **'Password is visible.'**
  String get uiPasswordVisible;

  /// No description provided for @uiPasswordHidden.
  ///
  /// In en, this message translates to:
  /// **'Password is hidden.'**
  String get uiPasswordHidden;

  /// No description provided for @uiTextStepScreen.
  ///
  /// In en, this message translates to:
  /// **'{title}. {label}. Editing. Press OK to finish, or use up or down to leave the field.'**
  String uiTextStepScreen(String title, String label);

  /// No description provided for @uiShowOrHidePassword.
  ///
  /// In en, this message translates to:
  /// **'Show or hide password'**
  String get uiShowOrHidePassword;

  /// No description provided for @uiDateEnterNumbers.
  ///
  /// In en, this message translates to:
  /// **'Enter a number in every date and time field.'**
  String get uiDateEnterNumbers;

  /// No description provided for @uiDateChooseValid.
  ///
  /// In en, this message translates to:
  /// **'Choose a valid date from {from} to {to}.'**
  String uiDateChooseValid(String from, String to);

  /// No description provided for @uiDateInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid date, an hour from 0 to 23, and a minute from 0 to 59.'**
  String get uiDateInvalid;

  /// No description provided for @uiDateChoose.
  ///
  /// In en, this message translates to:
  /// **'Choose a date from {from} to {to}.'**
  String uiDateChoose(String from, String to);

  /// A number range, e.g. '1 to 12'.
  ///
  /// In en, this message translates to:
  /// **'{from} to {to}'**
  String uiRange(String from, String to);

  /// No description provided for @uiYear.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get uiYear;

  /// No description provided for @uiMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get uiMonth;

  /// No description provided for @uiDay.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get uiDay;

  /// No description provided for @uiHour.
  ///
  /// In en, this message translates to:
  /// **'Hour'**
  String get uiHour;

  /// No description provided for @uiMinute.
  ///
  /// In en, this message translates to:
  /// **'Minute'**
  String get uiMinute;

  /// No description provided for @uiDateFieldEmpty.
  ///
  /// In en, this message translates to:
  /// **'{name}, {range}, currently empty'**
  String uiDateFieldEmpty(String name, String range);

  /// No description provided for @uiDateFieldValue.
  ///
  /// In en, this message translates to:
  /// **'{name}, {range}, currently {value}'**
  String uiDateFieldValue(String name, String range, String value);

  /// No description provided for @uiDateScreen.
  ///
  /// In en, this message translates to:
  /// **'Set date and time in the phone\'s local time. Choose a date from {from} to {to}.'**
  String uiDateScreen(String from, String to);

  /// No description provided for @uiSaveDateTime.
  ///
  /// In en, this message translates to:
  /// **'Save date and time'**
  String get uiSaveDateTime;

  /// No description provided for @uiChoiceValue.
  ///
  /// In en, this message translates to:
  /// **'{label}: {value}'**
  String uiChoiceValue(String label, String value);

  /// e.g. 'Subject: Science, 2 of 4'.
  ///
  /// In en, this message translates to:
  /// **'{label}: {value}, {position} of {total}'**
  String uiChoiceValuePosition(
    String label,
    String value,
    String position,
    String total,
  );

  /// No description provided for @uiChoiceChange.
  ///
  /// In en, this message translates to:
  /// **'{description}. Use left or right to change'**
  String uiChoiceChange(String description);

  /// No description provided for @startupPreferencesFailed.
  ///
  /// In en, this message translates to:
  /// **'Some preferences could not be loaded. Defaults are being used.'**
  String get startupPreferencesFailed;

  /// No description provided for @startupNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Session notifications'**
  String get startupNotificationsTitle;

  /// No description provided for @startupNotificationsMessage.
  ///
  /// In en, this message translates to:
  /// **'SEEDS uses notifications to tell you about session invitations and updates. You can continue using the app if you choose Not now.'**
  String get startupNotificationsMessage;

  /// No description provided for @startupEnableNotifications.
  ///
  /// In en, this message translates to:
  /// **'Enable notifications'**
  String get startupEnableNotifications;

  /// No description provided for @startupLoading.
  ///
  /// In en, this message translates to:
  /// **'SEEDS is loading'**
  String get startupLoading;

  /// No description provided for @startupWelcomeScreenName.
  ///
  /// In en, this message translates to:
  /// **'Welcome to SEEDS'**
  String get startupWelcomeScreenName;

  /// No description provided for @startupLoginButton.
  ///
  /// In en, this message translates to:
  /// **'Login, button'**
  String get startupLoginButton;

  /// No description provided for @startupRegisterButton.
  ///
  /// In en, this message translates to:
  /// **'Register, button'**
  String get startupRegisterButton;

  /// No description provided for @startupSettingsButton.
  ///
  /// In en, this message translates to:
  /// **'Settings, button'**
  String get startupSettingsButton;

  /// No description provided for @startupRepeatInstructionsButton.
  ///
  /// In en, this message translates to:
  /// **'Repeat instructions, button'**
  String get startupRepeatInstructionsButton;

  /// No description provided for @authSimAutofillOptional.
  ///
  /// In en, this message translates to:
  /// **'SIM phone-number autofill is optional'**
  String get authSimAutofillOptional;

  /// No description provided for @authRegisteredNowLogIn.
  ///
  /// In en, this message translates to:
  /// **'Registered. Now log in. Phone number field. Press star for help.'**
  String get authRegisteredNowLogIn;

  /// No description provided for @authSimUnavailableOnDevice.
  ///
  /// In en, this message translates to:
  /// **'SIM suggestions are unavailable on this device. Enter the phone number manually.'**
  String get authSimUnavailableOnDevice;

  /// No description provided for @authSimDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Optional SIM autofill'**
  String get authSimDialogTitle;

  /// No description provided for @authSimDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'Read optional phone-number suggestions from this device? You will choose a suggestion before it replaces the phone field. This does not verify who owns an account. SIM access is never required for login, registration, Wi-Fi, or joining a session.'**
  String get authSimDialogMessage;

  /// No description provided for @authSimDialogConfirm.
  ///
  /// In en, this message translates to:
  /// **'Read SIM suggestions'**
  String get authSimDialogConfirm;

  /// No description provided for @authSimAutofillSkipped.
  ///
  /// In en, this message translates to:
  /// **'SIM autofill skipped. Enter the phone number manually.'**
  String get authSimAutofillSkipped;

  /// No description provided for @authSimDetecting.
  ///
  /// In en, this message translates to:
  /// **'Detecting SIM card...'**
  String get authSimDetecting;

  /// No description provided for @authSimAutofillUnavailable.
  ///
  /// In en, this message translates to:
  /// **'SIM autofill unavailable. Enter the phone number manually.'**
  String get authSimAutofillUnavailable;

  /// No description provided for @authSimNoneFound.
  ///
  /// In en, this message translates to:
  /// **'No SIM card found. Enter the phone number manually.'**
  String get authSimNoneFound;

  /// No description provided for @authSimCardsDetected.
  ///
  /// In en, this message translates to:
  /// **'{count} SIM cards detected. Please choose one.'**
  String authSimCardsDetected(String count);

  /// No description provided for @authSimSuggestionUnavailable.
  ///
  /// In en, this message translates to:
  /// **'SIM suggestion unavailable. Enter the phone number manually.'**
  String get authSimSuggestionUnavailable;

  /// No description provided for @authSimOptionLabel.
  ///
  /// In en, this message translates to:
  /// **'SIM {number}, {carrier}'**
  String authSimOptionLabel(String number, String carrier);

  /// No description provided for @authSimUnknownCarrier.
  ///
  /// In en, this message translates to:
  /// **'Unknown carrier'**
  String get authSimUnknownCarrier;

  /// No description provided for @authSimSelectedFilled.
  ///
  /// In en, this message translates to:
  /// **'Selected suggestion filled. This is not proof of account ownership.'**
  String get authSimSelectedFilled;

  /// No description provided for @authSimSuggestionFilledSpoken.
  ///
  /// In en, this message translates to:
  /// **'Phone-number suggestion filled. Enter your password to sign in. No sign-in was sent.'**
  String get authSimSuggestionFilledSpoken;

  /// No description provided for @authErrorEnterPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number.'**
  String get authErrorEnterPhone;

  /// No description provided for @authErrorInvalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid 10-digit phone number.'**
  String get authErrorInvalidPhone;

  /// No description provided for @authErrorEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password.'**
  String get authErrorEnterPassword;

  /// No description provided for @authErrorPasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters.'**
  String get authErrorPasswordTooShort;

  /// No description provided for @authErrorInvalidServerResponse.
  ///
  /// In en, this message translates to:
  /// **'Invalid response from server'**
  String get authErrorInvalidServerResponse;

  /// No description provided for @authErrorNotRegisteredAdmin.
  ///
  /// In en, this message translates to:
  /// **'This phone number is not registered as an admin account. Press 1, 2 or 3 to choose the account type.'**
  String get authErrorNotRegisteredAdmin;

  /// No description provided for @authErrorNotRegisteredTeacher.
  ///
  /// In en, this message translates to:
  /// **'This phone number is not registered as a teacher account. Press 1, 2 or 3 to choose the account type.'**
  String get authErrorNotRegisteredTeacher;

  /// No description provided for @authErrorNotRegisteredStudent.
  ///
  /// In en, this message translates to:
  /// **'This phone number is not registered as a student account. Press 1, 2 or 3 to choose the account type.'**
  String get authErrorNotRegisteredStudent;

  /// No description provided for @authErrorResponseNotVerified.
  ///
  /// In en, this message translates to:
  /// **'The sign-in response could not be verified. Please try again.'**
  String get authErrorResponseNotVerified;

  /// No description provided for @authErrorMovedToPhone.
  ///
  /// In en, this message translates to:
  /// **'{message} Moved to phone number field.'**
  String authErrorMovedToPhone(String message);

  /// No description provided for @authErrorMovedToAccountType.
  ///
  /// In en, this message translates to:
  /// **'{message} Moved to account type.'**
  String authErrorMovedToAccountType(String message);

  /// No description provided for @authErrorMovedToPassword.
  ///
  /// In en, this message translates to:
  /// **'{message} Moved to password field.'**
  String authErrorMovedToPassword(String message);

  /// No description provided for @authRoleAdministrator.
  ///
  /// In en, this message translates to:
  /// **'Administrator'**
  String get authRoleAdministrator;

  /// No description provided for @authRoleTeacher.
  ///
  /// In en, this message translates to:
  /// **'Teacher'**
  String get authRoleTeacher;

  /// No description provided for @authRoleStudent.
  ///
  /// In en, this message translates to:
  /// **'Student'**
  String get authRoleStudent;

  /// No description provided for @authRecoveryStep1.
  ///
  /// In en, this message translates to:
  /// **'Ask your school administrator to reset your password. They must check who you are in person. A phone number or SIM alone does not prove it. Never send anyone your permanent password.'**
  String get authRecoveryStep1;

  /// No description provided for @authRecoveryStep2.
  ///
  /// In en, this message translates to:
  /// **'The administrator gives you a private 12-digit temporary password. It works for 24 hours. Ask for a new one if it expires.'**
  String get authRecoveryStep2;

  /// No description provided for @authRecoveryStep3.
  ///
  /// In en, this message translates to:
  /// **'Sign in with your phone number and the temporary password, then choose a new password.'**
  String get authRecoveryStep3;

  /// No description provided for @authRecoveryStep4.
  ///
  /// In en, this message translates to:
  /// **'After 10 wrong tries, sign-in pauses for 15 minutes. Recovery needs internet. Files already on other phones are not removed instantly.'**
  String get authRecoveryStep4;

  /// No description provided for @authRecoveryHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Password recovery help'**
  String get authRecoveryHelpTitle;

  /// No description provided for @authRecoveryHelpIntro.
  ///
  /// In en, this message translates to:
  /// **'{count} short steps. Press down to hear each step.'**
  String authRecoveryHelpIntro(String count);

  /// No description provided for @authBackToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to login'**
  String get authBackToLogin;

  /// No description provided for @authBackToLoginButton.
  ///
  /// In en, this message translates to:
  /// **'Back to login, button'**
  String get authBackToLoginButton;

  /// No description provided for @notesRecordingStarted.
  ///
  /// In en, this message translates to:
  /// **'Recording started. Select Stop recording when finished.'**
  String get notesRecordingStarted;

  /// No description provided for @notesActionNotConfirmed.
  ///
  /// In en, this message translates to:
  /// **'This note action could not be confirmed. Check storage, microphone permission or connection. Your drafts are kept.'**
  String get notesActionNotConfirmed;

  /// No description provided for @notesNoneYet.
  ///
  /// In en, this message translates to:
  /// **'No private notes yet.'**
  String get notesNoneYet;

  /// No description provided for @notesLoaded.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 private note loaded.} other{{count} private notes loaded.}}'**
  String notesLoaded(int count);

  /// No description provided for @notesNameDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Name private note'**
  String get notesNameDialogTitle;

  /// No description provided for @notesDefaultTitle.
  ///
  /// In en, this message translates to:
  /// **'Private note'**
  String get notesDefaultTitle;

  /// No description provided for @notesDefaultLessonTitle.
  ///
  /// In en, this message translates to:
  /// **'Note for {lesson}'**
  String notesDefaultLessonTitle(String lesson);

  /// No description provided for @notesRecordConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Record private note?'**
  String get notesRecordConfirmTitle;

  /// lessonPoint is empty or the notesLessonPointSeconds sentence.
  ///
  /// In en, this message translates to:
  /// **'Record microphone audio on this phone only, for up to five minutes or the remaining separate 10 MB note allowance. Stop recording before using spoken controls. App speech, leaving this screen or app interruption stops recording. Live-session recording is blocked. {lessonPoint} No automatic upload or sharing. Microphone permission may be requested.'**
  String notesRecordConfirmMessage(String lessonPoint);

  /// No description provided for @notesLessonPointSeconds.
  ///
  /// In en, this message translates to:
  /// **'Lesson point: {seconds} seconds.'**
  String notesLessonPointSeconds(String seconds);

  /// No description provided for @notesStartRecording.
  ///
  /// In en, this message translates to:
  /// **'Start recording'**
  String get notesStartRecording;

  /// No description provided for @notesDoNotRecord.
  ///
  /// In en, this message translates to:
  /// **'Do not record'**
  String get notesDoNotRecord;

  /// No description provided for @notesReviewStoppedChanged.
  ///
  /// In en, this message translates to:
  /// **'Review stopped because the screen or app changed. Open this note again to review.'**
  String get notesReviewStoppedChanged;

  /// No description provided for @notesReviewStoppedAccount.
  ///
  /// In en, this message translates to:
  /// **'Review stopped because your account changed. Open private notes again.'**
  String get notesReviewStoppedAccount;

  /// No description provided for @notesRenameDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename private note'**
  String get notesRenameDialogTitle;

  /// No description provided for @notesRemoveTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove {title}?'**
  String notesRemoveTitle(String title);

  /// No description provided for @notesRemoveMessage.
  ///
  /// In en, this message translates to:
  /// **'Remove only {title} from this account on this phone? Other notes, learning progress and bookmarks are kept. If previously published, the online recording and downloaded copies are not removed.'**
  String notesRemoveMessage(String title);

  /// No description provided for @notesRemoveSelected.
  ///
  /// In en, this message translates to:
  /// **'Remove selected note'**
  String get notesRemoveSelected;

  /// No description provided for @notesKeepNote.
  ///
  /// In en, this message translates to:
  /// **'Keep note'**
  String get notesKeepNote;

  /// No description provided for @notesRemoved.
  ///
  /// In en, this message translates to:
  /// **'{title} removed. Other notes and learning progress kept.'**
  String notesRemoved(String title);

  /// No description provided for @notesReviewBeforePublish.
  ///
  /// In en, this message translates to:
  /// **'Play and review this note privately before publishing.'**
  String get notesReviewBeforePublish;

  /// No description provided for @notesSignInAsTeacher.
  ///
  /// In en, this message translates to:
  /// **'Sign in as the teacher before publishing.'**
  String get notesSignInAsTeacher;

  /// No description provided for @notesNoWorkspace.
  ///
  /// In en, this message translates to:
  /// **'No authorized class/subject workspace was confirmed. Your draft is kept.'**
  String get notesNoWorkspace;

  /// No description provided for @notesPublishTitle.
  ///
  /// In en, this message translates to:
  /// **'Publish reviewed note to class?'**
  String get notesPublishTitle;

  /// No description provided for @notesPublishMessage.
  ///
  /// In en, this message translates to:
  /// **'Confirm you reviewed {title} and want to publish it to {className}, {subjectName}. Authorized class members can stream or download it for up to 30 days offline. Disconnected copies cannot be instantly revoked. Your local draft stays. An unconfirmed upload may already have published; check the library before retrying to avoid duplicates.'**
  String notesPublishMessage(
    String title,
    String className,
    String subjectName,
  );

  /// No description provided for @notesPublishConfirm.
  ///
  /// In en, this message translates to:
  /// **'Publish to selected class'**
  String get notesPublishConfirm;

  /// No description provided for @notesKeepDraftPrivate.
  ///
  /// In en, this message translates to:
  /// **'Keep draft private'**
  String get notesKeepDraftPrivate;

  /// No description provided for @notesSignInChanged.
  ///
  /// In en, this message translates to:
  /// **'Sign-in changed. The draft was not sent.'**
  String get notesSignInChanged;

  /// No description provided for @notesAccountChangedBeforePublish.
  ///
  /// In en, this message translates to:
  /// **'Your account changed before publication was confirmed. Check the original teacher library before retrying.'**
  String get notesAccountChangedBeforePublish;

  /// No description provided for @notesPublishNotConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Publication was not confirmed. Check the class library before retrying; your private draft is kept.'**
  String get notesPublishNotConfirmed;

  /// No description provided for @notesPublishUnreadable.
  ///
  /// In en, this message translates to:
  /// **'Publication confirmation was unreadable. Check the library before retrying; your draft is kept.'**
  String get notesPublishUnreadable;

  /// No description provided for @notesPublishIdentityMismatch.
  ///
  /// In en, this message translates to:
  /// **'Publication identity did not match. Check the library before retrying; your draft is kept.'**
  String get notesPublishIdentityMismatch;

  /// No description provided for @notesPublished.
  ///
  /// In en, this message translates to:
  /// **'Published as recording {audioId}. Your local draft is kept. Do not publish again unless you intend another recording.'**
  String notesPublished(String audioId);

  /// No description provided for @notesStopBeforeLeaving.
  ///
  /// In en, this message translates to:
  /// **'Recording stop was not confirmed. Stop again or background the app before leaving.'**
  String get notesStopBeforeLeaving;

  /// No description provided for @notesRules.
  ///
  /// In en, this message translates to:
  /// **'Private note rules. Each note can be up to five minutes. Notes use a separate 10 megabyte allowance for each account. Recording only starts when you confirm it, and never inside a live session. App speech, leaving this screen or an interruption stops recording, so stop recording before using spoken controls. Student notes stay private on this phone. Teacher drafts must be reviewed and confirmed before publishing. Notes are kept after you log out.'**
  String get notesRules;

  /// No description provided for @notesRecordingFor.
  ///
  /// In en, this message translates to:
  /// **'Recording for {duration}.'**
  String notesRecordingFor(String duration);

  /// No description provided for @notesUsage.
  ///
  /// In en, this message translates to:
  /// **'{megabytes} of 10 MB private notes used.'**
  String notesUsage(String megabytes);

  /// Numbered step shown in the password recovery help dialog.
  ///
  /// In en, this message translates to:
  /// **'{number}. {step}'**
  String authRecoveryStepListItem(String number, String step);

  /// Button text; 0 is the keypad key.
  ///
  /// In en, this message translates to:
  /// **'0: Back to login'**
  String get authBackToLoginKey;

  /// Shown under the chosen account type.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get authRoleRowSelected;

  /// No description provided for @authLoginScreenName.
  ///
  /// In en, this message translates to:
  /// **'Login Screen'**
  String get authLoginScreenName;

  /// No description provided for @authLoginNavigationSections.
  ///
  /// In en, this message translates to:
  /// **'phone number, password, account type, login, registration, SIM suggestions and recovery help'**
  String get authLoginNavigationSections;

  /// No description provided for @authLoginKeySimLabel.
  ///
  /// In en, this message translates to:
  /// **'Read optional SIM phone-number suggestions'**
  String get authLoginKeySimLabel;

  /// No description provided for @authLoginKeyRecoveryLabel.
  ///
  /// In en, this message translates to:
  /// **'School-admin password recovery help'**
  String get authLoginKeyRecoveryLabel;

  /// No description provided for @authPhoneNumberField.
  ///
  /// In en, this message translates to:
  /// **'Phone number field'**
  String get authPhoneNumberField;

  /// No description provided for @authPasswordField.
  ///
  /// In en, this message translates to:
  /// **'Password field'**
  String get authPasswordField;

  /// No description provided for @authHidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get authHidePassword;

  /// No description provided for @authShowPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get authShowPassword;

  /// No description provided for @authRoleFieldNavLabel.
  ///
  /// In en, this message translates to:
  /// **'Account type: {role}, selected. Press 1, 2 or 3 to change, or use left and right'**
  String authRoleFieldNavLabel(String role);

  /// No description provided for @authLoginAsButton.
  ///
  /// In en, this message translates to:
  /// **'Login as {role}, button'**
  String authLoginAsButton(String role);

  /// No description provided for @authRegisterNewAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Register a new account, button'**
  String get authRegisterNewAccountButton;

  /// No description provided for @authSimSuggestionsTargetLabel.
  ///
  /// In en, this message translates to:
  /// **'Read optional SIM phone-number suggestions. Manual entry always works.'**
  String get authSimSuggestionsTargetLabel;

  /// No description provided for @authForgotPasswordTargetLabel.
  ///
  /// In en, this message translates to:
  /// **'Forgot password? School-admin recovery help'**
  String get authForgotPasswordTargetLabel;

  /// No description provided for @authWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get authWelcomeBack;

  /// No description provided for @authRegisteredBanner.
  ///
  /// In en, this message translates to:
  /// **'Registered. Now log in.'**
  String get authRegisteredBanner;

  /// No description provided for @authPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get authPhoneNumber;

  /// No description provided for @authPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPassword;

  /// No description provided for @authAccountType.
  ///
  /// In en, this message translates to:
  /// **'Account type'**
  String get authAccountType;

  /// No description provided for @authRoleFieldValue.
  ///
  /// In en, this message translates to:
  /// **'{role}, selected. Press 1, 2 or 3 to change'**
  String authRoleFieldValue(String role);

  /// 1 is the keypad key.
  ///
  /// In en, this message translates to:
  /// **'1 Student'**
  String get authRoleOptionStudent;

  /// 2 is the keypad key.
  ///
  /// In en, this message translates to:
  /// **'2 Teacher'**
  String get authRoleOptionTeacher;

  /// 3 is the keypad key.
  ///
  /// In en, this message translates to:
  /// **'3 Admin'**
  String get authRoleOptionAdmin;

  /// No description provided for @authSigningIn.
  ///
  /// In en, this message translates to:
  /// **'Signing in, please wait'**
  String get authSigningIn;

  /// Button text; 4 is the keypad key.
  ///
  /// In en, this message translates to:
  /// **'4: Login as {role}'**
  String authLoginAsKey(String role);

  /// 5 is the keypad key.
  ///
  /// In en, this message translates to:
  /// **'5: Don\'t have an account? Register'**
  String get authNoAccountRegisterKey;

  /// 6 is the keypad key.
  ///
  /// In en, this message translates to:
  /// **'6: Read optional SIM suggestions'**
  String get authReadSimSuggestionsKey;

  /// 7 is the keypad key.
  ///
  /// In en, this message translates to:
  /// **'7: Forgot password? Recovery help'**
  String get authForgotPasswordKey;

  /// No description provided for @authErrorMovedToName.
  ///
  /// In en, this message translates to:
  /// **'{message} Moved to name field.'**
  String authErrorMovedToName(String message);

  /// No description provided for @authErrorEnterName.
  ///
  /// In en, this message translates to:
  /// **'Enter your name.'**
  String get authErrorEnterName;

  /// No description provided for @authErrorEnterAPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter a password.'**
  String get authErrorEnterAPassword;

  /// No description provided for @authRegisteringAsTeacher.
  ///
  /// In en, this message translates to:
  /// **'Registering as teacher'**
  String get authRegisteringAsTeacher;

  /// No description provided for @authRegisteringAsStudent.
  ///
  /// In en, this message translates to:
  /// **'Registering as student'**
  String get authRegisteringAsStudent;

  /// No description provided for @authRegistrationScreenName.
  ///
  /// In en, this message translates to:
  /// **'Registration Screen'**
  String get authRegistrationScreenName;

  /// No description provided for @authRegisterNavigationSections.
  ///
  /// In en, this message translates to:
  /// **'name, phone number, password, student or teacher account type, register, and login'**
  String get authRegisterNavigationSections;

  /// No description provided for @authNameField.
  ///
  /// In en, this message translates to:
  /// **'Name field'**
  String get authNameField;

  /// No description provided for @authRegisterRoleTeacherLabel.
  ///
  /// In en, this message translates to:
  /// **'Account type: Teacher. Press OK or 3 to switch to student'**
  String get authRegisterRoleTeacherLabel;

  /// No description provided for @authRegisterRoleStudentLabel.
  ///
  /// In en, this message translates to:
  /// **'Account type: Student. Press OK or 3 to switch to teacher'**
  String get authRegisterRoleStudentLabel;

  /// No description provided for @authRegisterAsTeacherButton.
  ///
  /// In en, this message translates to:
  /// **'Register as teacher, button'**
  String get authRegisterAsTeacherButton;

  /// No description provided for @authRegisterAsStudentButton.
  ///
  /// In en, this message translates to:
  /// **'Register as student, button'**
  String get authRegisterAsStudentButton;

  /// No description provided for @authGoToLoginLabel.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Go to login'**
  String get authGoToLoginLabel;

  /// Registration screen heading.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get authRegisterTitle;

  /// No description provided for @authName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get authName;

  /// 3 is the keypad key.
  ///
  /// In en, this message translates to:
  /// **'3: Register as Teacher. Change account type'**
  String get authRegisterAsTeacherKey;

  /// 3 is the keypad key.
  ///
  /// In en, this message translates to:
  /// **'3: Register as Student. Change account type'**
  String get authRegisterAsStudentKey;

  /// No description provided for @authRegisteringPleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Registering, please wait'**
  String get authRegisteringPleaseWait;

  /// 1 is the keypad key.
  ///
  /// In en, this message translates to:
  /// **'1: Register'**
  String get authRegisterKey;

  /// 2 is the keypad key.
  ///
  /// In en, this message translates to:
  /// **'2: Already have an account? Login'**
  String get authHaveAccountLoginKey;

  /// No description provided for @authChangePasswordBusy.
  ///
  /// In en, this message translates to:
  /// **'Saving. Waiting for password-change confirmation.'**
  String get authChangePasswordBusy;

  /// No description provided for @authChangePasswordErrorEnterTemporary.
  ///
  /// In en, this message translates to:
  /// **'Enter your temporary credential. Moved to that field.'**
  String get authChangePasswordErrorEnterTemporary;

  /// No description provided for @authChangePasswordErrorTooShort.
  ///
  /// In en, this message translates to:
  /// **'Enter a new password of at least 6 characters. Moved to new password.'**
  String get authChangePasswordErrorTooShort;

  /// No description provided for @authChangePasswordErrorMismatch.
  ///
  /// In en, this message translates to:
  /// **'The new passwords do not match. Moved to repeat new password.'**
  String get authChangePasswordErrorMismatch;

  /// No description provided for @authChangePasswordErrorSameAsTemporary.
  ///
  /// In en, this message translates to:
  /// **'Choose a password different from the temporary credential. Moved to new password.'**
  String get authChangePasswordErrorSameAsTemporary;

  /// No description provided for @authChangePasswordSessionInactive.
  ///
  /// In en, this message translates to:
  /// **'This recovery session is no longer active. Sign in again.'**
  String get authChangePasswordSessionInactive;

  /// No description provided for @authChangePasswordAccountChanged.
  ///
  /// In en, this message translates to:
  /// **'Your account changed. No replacement sign-in was saved.'**
  String get authChangePasswordAccountChanged;

  /// message is the server or network error.
  ///
  /// In en, this message translates to:
  /// **'{message} Password change is not confirmed. If the connection failed, try signing in with your new password before requesting another reset.'**
  String authChangePasswordNotConfirmed(String message);

  /// No description provided for @authChangePasswordResponseNotVerified.
  ///
  /// In en, this message translates to:
  /// **'The password-change response could not be verified. Try signing in again with your new password.'**
  String get authChangePasswordResponseNotVerified;

  /// No description provided for @authChangePasswordReplacementNotVerified.
  ///
  /// In en, this message translates to:
  /// **'The replacement sign-in could not be verified. Sign in again with your new password.'**
  String get authChangePasswordReplacementNotVerified;

  /// No description provided for @authChangePasswordSignInNotSaved.
  ///
  /// In en, this message translates to:
  /// **'Your sign-in could not be saved. Sign in again with your new password.'**
  String get authChangePasswordSignInNotSaved;

  /// No description provided for @authChangePasswordSignInNotSavedOnPhone.
  ///
  /// In en, this message translates to:
  /// **'Your sign-in could not be saved on this phone. Sign in again with your new password.'**
  String get authChangePasswordSignInNotSavedOnPhone;

  /// No description provided for @authTemporaryCredential.
  ///
  /// In en, this message translates to:
  /// **'Temporary credential'**
  String get authTemporaryCredential;

  /// No description provided for @authNewPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get authNewPassword;

  /// No description provided for @authRepeatNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Repeat new password'**
  String get authRepeatNewPassword;

  /// No description provided for @authChangePasswordScreenName.
  ///
  /// In en, this message translates to:
  /// **'Change temporary password'**
  String get authChangePasswordScreenName;

  /// No description provided for @authChangePasswordIntro.
  ///
  /// In en, this message translates to:
  /// **'Enter the temporary credential from your administrator, then a new password of at least 6 characters, twice. Internet is required. The dashboard opens after the new password is confirmed.'**
  String get authChangePasswordIntro;

  /// No description provided for @authSaveNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Save new password'**
  String get authSaveNewPassword;

  /// No description provided for @authSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get authSignOut;

  /// No description provided for @authTemporaryCredentialField.
  ///
  /// In en, this message translates to:
  /// **'Temporary credential. Hidden input.'**
  String get authTemporaryCredentialField;

  /// No description provided for @authNewPasswordField.
  ///
  /// In en, this message translates to:
  /// **'New password. At least 6 characters. Hidden input.'**
  String get authNewPasswordField;

  /// No description provided for @authRepeatNewPasswordField.
  ///
  /// In en, this message translates to:
  /// **'Repeat new password. Hidden input.'**
  String get authRepeatNewPasswordField;

  /// No description provided for @authSaveNewPasswordButton.
  ///
  /// In en, this message translates to:
  /// **'Save new password, button'**
  String get authSaveNewPasswordButton;

  /// No description provided for @authSignOutConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Sign out, asks to confirm'**
  String get authSignOutConfirmButton;

  /// No description provided for @authChangePasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get authChangePasswordTitle;

  /// No description provided for @authChangePasswordInfo.
  ///
  /// In en, this message translates to:
  /// **'Your school administrator issued a temporary credential. It lasts 24 hours. After 10 wrong attempts, sign-in pauses for 15 minutes. Choose a different password of at least 6 characters. This requires internet.'**
  String get authChangePasswordInfo;

  /// 0 is the keypad key.
  ///
  /// In en, this message translates to:
  /// **'0: Sign out'**
  String get authSignOutKey;

  /// label is the SIM name; digits is the phone number spelled digit by digit.
  ///
  /// In en, this message translates to:
  /// **'{label}. Phone number {digits}. Press OK to fill the phone field.'**
  String authSimOptionValid(String label, String digits);

  /// No description provided for @authSimOptionInvalid.
  ///
  /// In en, this message translates to:
  /// **'{label}. Number unavailable. Enter the phone number manually.'**
  String authSimOptionInvalid(String label);

  /// No description provided for @authSimInvalidSuggestion.
  ///
  /// In en, this message translates to:
  /// **'This SIM does not provide a valid phone-number suggestion. Manual entry still works.'**
  String get authSimInvalidSuggestion;

  /// No description provided for @authSimChooseScreenName.
  ///
  /// In en, this message translates to:
  /// **'Choose an optional SIM suggestion. Use up and down to review each SIM, then OK to select. This is not account verification.'**
  String get authSimChooseScreenName;

  /// No description provided for @authSimCancelLabel.
  ///
  /// In en, this message translates to:
  /// **'Cancel without changing the phone number'**
  String get authSimCancelLabel;

  /// No description provided for @authSimChooseTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose SIM suggestion'**
  String get authSimChooseTitle;

  /// No description provided for @authSimChooseInfo.
  ///
  /// In en, this message translates to:
  /// **'Selecting fills the phone field only. Your password is still required. Cancel keeps manual entry unchanged.'**
  String get authSimChooseInfo;

  /// 0 is the keypad key.
  ///
  /// In en, this message translates to:
  /// **'0: Cancel'**
  String get authSimCancelKey;

  /// No description provided for @inviteStatusInvited.
  ///
  /// In en, this message translates to:
  /// **'Invited'**
  String get inviteStatusInvited;

  /// No description provided for @inviteStatusNotInvited.
  ///
  /// In en, this message translates to:
  /// **'Not invited. OK to invite'**
  String get inviteStatusNotInvited;

  /// No description provided for @inviteTitle.
  ///
  /// In en, this message translates to:
  /// **'Invite Students'**
  String get inviteTitle;

  /// No description provided for @inviteTooltipBack.
  ///
  /// In en, this message translates to:
  /// **'0: Back to session'**
  String get inviteTooltipBack;

  /// No description provided for @inviteTooltipRefresh.
  ///
  /// In en, this message translates to:
  /// **'1: Refresh student list'**
  String get inviteTooltipRefresh;

  /// No description provided for @inviteInvitingTo.
  ///
  /// In en, this message translates to:
  /// **'Inviting students to:'**
  String get inviteInvitingTo;

  /// No description provided for @inviteInvitedCount.
  ///
  /// In en, this message translates to:
  /// **'{invited} of {total} invited'**
  String inviteInvitedCount(String invited, String total);

  /// No description provided for @inviteAllButton.
  ///
  /// In en, this message translates to:
  /// **'2: Invite All Students'**
  String get inviteAllButton;

  /// No description provided for @inviteSearchField.
  ///
  /// In en, this message translates to:
  /// **'Search by name or phone number'**
  String get inviteSearchField;

  /// No description provided for @inviteSearchHelper.
  ///
  /// In en, this message translates to:
  /// **'Leave empty to list every student'**
  String get inviteSearchHelper;

  /// No description provided for @inviteLoadingStudents.
  ///
  /// In en, this message translates to:
  /// **'Loading students'**
  String get inviteLoadingStudents;

  /// No description provided for @inviteNoMatchShort.
  ///
  /// In en, this message translates to:
  /// **'No students match. Clear the search to list everyone.'**
  String get inviteNoMatchShort;

  /// No description provided for @libraryUploadTitleField.
  ///
  /// In en, this message translates to:
  /// **'Title *'**
  String get libraryUploadTitleField;

  /// No description provided for @libraryUploadDescriptionField.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get libraryUploadDescriptionField;

  /// No description provided for @libraryCancelKey0Button.
  ///
  /// In en, this message translates to:
  /// **'Cancel (0)'**
  String get libraryCancelKey0Button;

  /// No description provided for @libraryUploadKey3Button.
  ///
  /// In en, this message translates to:
  /// **'Upload (3)'**
  String get libraryUploadKey3Button;

  /// No description provided for @libraryConfirmKey1Button.
  ///
  /// In en, this message translates to:
  /// **'Confirm (1)'**
  String get libraryConfirmKey1Button;

  /// No description provided for @librarySessionNumber.
  ///
  /// In en, this message translates to:
  /// **'Session #{id}'**
  String librarySessionNumber(String id);

  /// No description provided for @libraryKey5PauseForClass.
  ///
  /// In en, this message translates to:
  /// **'5: Pause for class'**
  String get libraryKey5PauseForClass;

  /// No description provided for @libraryKey5PlayForClass.
  ///
  /// In en, this message translates to:
  /// **'5: Play for class'**
  String get libraryKey5PlayForClass;

  /// No description provided for @libraryRecordingsSeekKeysHint.
  ///
  /// In en, this message translates to:
  /// **'4: Back 10 s. 6: Forward 10 s.'**
  String get libraryRecordingsSeekKeysHint;

  /// No description provided for @libraryKey1ChooseRecording.
  ///
  /// In en, this message translates to:
  /// **'1: Choose recording'**
  String get libraryKey1ChooseRecording;

  /// No description provided for @libraryUploadingButton.
  ///
  /// In en, this message translates to:
  /// **'Uploading'**
  String get libraryUploadingButton;

  /// No description provided for @libraryKey2Upload.
  ///
  /// In en, this message translates to:
  /// **'2: Upload'**
  String get libraryKey2Upload;

  /// No description provided for @libraryRecordingsFooterKeysHint.
  ///
  /// In en, this message translates to:
  /// **'3: Status. *: Help. #: Stop speech.'**
  String get libraryRecordingsFooterKeysHint;

  /// No description provided for @notesBackStopsRecording.
  ///
  /// In en, this message translates to:
  /// **'Back. Stops any recording first'**
  String get notesBackStopsRecording;

  /// No description provided for @notesReadRules.
  ///
  /// In en, this message translates to:
  /// **'Read note rules'**
  String get notesReadRules;

  /// No description provided for @notesRefreshPrivate.
  ///
  /// In en, this message translates to:
  /// **'Refresh private notes'**
  String get notesRefreshPrivate;

  /// No description provided for @notesRecordAsksFirst.
  ///
  /// In en, this message translates to:
  /// **'Record a private note. Asks for a name and confirmation first'**
  String get notesRecordAsksFirst;

  /// No description provided for @notesStopRecordingNow.
  ///
  /// In en, this message translates to:
  /// **'Stop recording now'**
  String get notesStopRecordingNow;

  /// No description provided for @notesReadRecordingTimeStops.
  ///
  /// In en, this message translates to:
  /// **'Read recording time. Reading aloud stops recording'**
  String get notesReadRecordingTimeStops;

  /// No description provided for @notesReadPrivateStatus.
  ///
  /// In en, this message translates to:
  /// **'Read private note status'**
  String get notesReadPrivateStatus;

  /// No description provided for @notesStopPrivateReview.
  ///
  /// In en, this message translates to:
  /// **'Stop private review'**
  String get notesStopPrivateReview;

  /// No description provided for @notesStopReviewingTitle.
  ///
  /// In en, this message translates to:
  /// **'Stop reviewing {title}'**
  String notesStopReviewingTitle(String title);

  /// No description provided for @notesStopReviewingNote.
  ///
  /// In en, this message translates to:
  /// **'Stop reviewing note'**
  String get notesStopReviewingNote;

  /// No description provided for @notesReviewTitlePrivately.
  ///
  /// In en, this message translates to:
  /// **'Review {title} privately. {duration}.'**
  String notesReviewTitlePrivately(String title, String duration);

  /// No description provided for @notesReviewTitleIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Review {title} privately. Incomplete recording; cannot play.'**
  String notesReviewTitleIncomplete(String title);

  /// No description provided for @notesRenameTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename {title}'**
  String notesRenameTitle(String title);

  /// No description provided for @notesPublishTitleAsks.
  ///
  /// In en, this message translates to:
  /// **'Publish reviewed {title} to a class and subject, asks to confirm'**
  String notesPublishTitleAsks(String title);

  /// No description provided for @notesRemoveTitleAsks.
  ///
  /// In en, this message translates to:
  /// **'Remove {title}, asks to confirm'**
  String notesRemoveTitleAsks(String title);

  /// No description provided for @notesScreenName.
  ///
  /// In en, this message translates to:
  /// **'Private notes'**
  String get notesScreenName;

  /// No description provided for @notesIntroduction.
  ///
  /// In en, this message translates to:
  /// **'Use Read note rules to hear how notes are kept.'**
  String get notesIntroduction;

  /// No description provided for @notesBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get notesBack;

  /// No description provided for @notesStorageSummary.
  ///
  /// In en, this message translates to:
  /// **'{megabytes} / 10 MB private notes. Separate from lesson downloads. No automatic deletion.'**
  String notesStorageSummary(String megabytes);

  /// No description provided for @notesLessonContext.
  ///
  /// In en, this message translates to:
  /// **'{title}. Captured lesson point: {seconds} seconds.'**
  String notesLessonContext(String title, String seconds);

  /// Visual timer; time is minutes:seconds, e.g. 1:05.
  ///
  /// In en, this message translates to:
  /// **'Recording time {time}'**
  String notesRecordingTime(String time);

  /// No description provided for @notesRefreshNotes.
  ///
  /// In en, this message translates to:
  /// **'Refresh notes'**
  String get notesRefreshNotes;

  /// No description provided for @notesRecordPrivateNote.
  ///
  /// In en, this message translates to:
  /// **'Record a private note'**
  String get notesRecordPrivateNote;

  /// No description provided for @notesStopRecording.
  ///
  /// In en, this message translates to:
  /// **'Stop recording'**
  String get notesStopRecording;

  /// No description provided for @notesReadRecordingTime.
  ///
  /// In en, this message translates to:
  /// **'Read recording time'**
  String get notesReadRecordingTime;

  /// No description provided for @notesReadNoteStatus.
  ///
  /// In en, this message translates to:
  /// **'Read note status'**
  String get notesReadNoteStatus;

  /// No description provided for @notesStatusNeedsAttention.
  ///
  /// In en, this message translates to:
  /// **'Needs attention'**
  String get notesStatusNeedsAttention;

  /// No description provided for @notesStatusIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Incomplete'**
  String get notesStatusIncomplete;

  /// No description provided for @notesStatusPlaying.
  ///
  /// In en, this message translates to:
  /// **'Playing'**
  String get notesStatusPlaying;

  /// No description provided for @notesStatusReviewed.
  ///
  /// In en, this message translates to:
  /// **'Reviewed'**
  String get notesStatusReviewed;

  /// No description provided for @notesStatusSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get notesStatusSaved;

  /// No description provided for @notesNoteSeconds.
  ///
  /// In en, this message translates to:
  /// **'{seconds} seconds. Private local note.'**
  String notesNoteSeconds(String seconds);

  /// No description provided for @notesNoteIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Interrupted or incomplete note. Cannot play or publish.'**
  String get notesNoteIncomplete;

  /// No description provided for @notesNoteLessonPoint.
  ///
  /// In en, this message translates to:
  /// **'Lesson {lesson}, point {seconds} seconds.'**
  String notesNoteLessonPoint(String lesson, String seconds);

  /// No description provided for @notesReviewPlaying.
  ///
  /// In en, this message translates to:
  /// **'Review playing'**
  String get notesReviewPlaying;

  /// No description provided for @notesReviewPrivately.
  ///
  /// In en, this message translates to:
  /// **'Review privately'**
  String get notesReviewPrivately;

  /// No description provided for @notesRename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get notesRename;

  /// No description provided for @notesPublishReviewedNote.
  ///
  /// In en, this message translates to:
  /// **'Publish reviewed note'**
  String get notesPublishReviewedNote;

  /// No description provided for @notesEnterNameBeforeSaving.
  ///
  /// In en, this message translates to:
  /// **'Enter a name before saving.'**
  String get notesEnterNameBeforeSaving;

  /// No description provided for @notesNameDialogInstructions.
  ///
  /// In en, this message translates to:
  /// **'{title}. OK enters editing. Up or Down leaves editing, then choose Save or Cancel.'**
  String notesNameDialogInstructions(String title);

  /// No description provided for @notesNoteName.
  ///
  /// In en, this message translates to:
  /// **'Note name'**
  String get notesNoteName;

  /// No description provided for @notesSaveNoteName.
  ///
  /// In en, this message translates to:
  /// **'Save note name'**
  String get notesSaveNoteName;

  /// No description provided for @notesCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get notesCancel;

  /// No description provided for @notesSaveName.
  ///
  /// In en, this message translates to:
  /// **'Save name'**
  String get notesSaveName;

  /// No description provided for @notesWorkspaceLabel.
  ///
  /// In en, this message translates to:
  /// **'{className}, {subjectName}'**
  String notesWorkspaceLabel(String className, String subjectName);

  /// No description provided for @notesChooseWorkspaceInstructions.
  ///
  /// In en, this message translates to:
  /// **'Choose an authorized class and subject before publishing. Nothing is uploaded until the next confirmation.'**
  String get notesChooseWorkspaceInstructions;

  /// No description provided for @notesCancelPublication.
  ///
  /// In en, this message translates to:
  /// **'Cancel publication'**
  String get notesCancelPublication;

  /// No description provided for @notesPublishWhichWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Publish to which workspace?'**
  String get notesPublishWhichWorkspace;

  /// No description provided for @settingsDecrease.
  ///
  /// In en, this message translates to:
  /// **'Decrease {setting}'**
  String settingsDecrease(String setting);

  /// No description provided for @settingsIncrease.
  ///
  /// In en, this message translates to:
  /// **'Increase {setting}'**
  String settingsIncrease(String setting);

  /// No description provided for @settingsResetTooltip.
  ///
  /// In en, this message translates to:
  /// **'Reset to Defaults'**
  String get settingsResetTooltip;

  /// No description provided for @settingsSectionSpeech.
  ///
  /// In en, this message translates to:
  /// **'Speech'**
  String get settingsSectionSpeech;

  /// No description provided for @settingsAppSpeechTitle.
  ///
  /// In en, this message translates to:
  /// **'App speech'**
  String get settingsAppSpeechTitle;

  /// No description provided for @settingsAppSpeechSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The app reads out screens and messages'**
  String get settingsAppSpeechSubtitle;

  /// No description provided for @settingsLanguageButton.
  ///
  /// In en, this message translates to:
  /// **'Speech language: {language}'**
  String settingsLanguageButton(String language);

  /// No description provided for @settingsVolumeTitle.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get settingsVolumeTitle;

  /// No description provided for @settingsVolumeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'How loud app speech is'**
  String get settingsVolumeSubtitle;

  /// No description provided for @settingsPercentValue.
  ///
  /// In en, this message translates to:
  /// **'{percent} percent'**
  String settingsPercentValue(String percent);

  /// No description provided for @settingsSpeedTitle.
  ///
  /// In en, this message translates to:
  /// **'Speech speed'**
  String get settingsSpeedTitle;

  /// No description provided for @settingsSpeedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'How fast app speech is. Quizzes can use their own speed'**
  String get settingsSpeedSubtitle;

  /// No description provided for @settingsTimesNormal.
  ///
  /// In en, this message translates to:
  /// **'{speed} times normal'**
  String settingsTimesNormal(String speed);

  /// No description provided for @settingsTestButton.
  ///
  /// In en, this message translates to:
  /// **'5: Test speech'**
  String get settingsTestButton;

  /// No description provided for @settingsNarrationButton.
  ///
  /// In en, this message translates to:
  /// **'Narration level: {level}'**
  String settingsNarrationButton(String level);

  /// No description provided for @settingsCheckingVoice.
  ///
  /// In en, this message translates to:
  /// **'Checking {language} voice...'**
  String settingsCheckingVoice(String language);

  /// No description provided for @settingsCheckVoiceButton.
  ///
  /// In en, this message translates to:
  /// **'7: Check {language} voice'**
  String settingsCheckVoiceButton(String language);

  /// No description provided for @settingsStopButton.
  ///
  /// In en, this message translates to:
  /// **'#: Stop speech'**
  String get settingsStopButton;

  /// No description provided for @settingsSectionDisplay.
  ///
  /// In en, this message translates to:
  /// **'Display'**
  String get settingsSectionDisplay;

  /// No description provided for @settingsHighContrastTitle.
  ///
  /// In en, this message translates to:
  /// **'High Contrast'**
  String get settingsHighContrastTitle;

  /// No description provided for @settingsHighContrastSubtitle.
  ///
  /// In en, this message translates to:
  /// **'On by default: white and yellow on black for low vision'**
  String get settingsHighContrastSubtitle;

  /// No description provided for @settingsTextSizeTitle.
  ///
  /// In en, this message translates to:
  /// **'Text size'**
  String get settingsTextSizeTitle;

  /// No description provided for @settingsTextSizeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'App text size; system font scaling is also respected'**
  String get settingsTextSizeSubtitle;

  /// No description provided for @settingsSectionKeys.
  ///
  /// In en, this message translates to:
  /// **'Keys and help'**
  String get settingsSectionKeys;

  /// No description provided for @settingsShortcutsTitle.
  ///
  /// In en, this message translates to:
  /// **'Show keypad shortcuts'**
  String get settingsShortcutsTitle;

  /// No description provided for @settingsShortcutsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Show key numbers on buttons'**
  String get settingsShortcutsSubtitle;

  /// No description provided for @settingsGlobalKeysHint.
  ///
  /// In en, this message translates to:
  /// **'On every screen: 0 back, star help, hash stop speech.'**
  String get settingsGlobalKeysHint;

  /// No description provided for @settingsVoiceCommandsTitle.
  ///
  /// In en, this message translates to:
  /// **'Voice commands'**
  String get settingsVoiceCommandsTitle;

  /// No description provided for @settingsVoiceCommandsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enable Listen for command in sessions. No automatic listening.'**
  String get settingsVoiceCommandsSubtitle;

  /// No description provided for @settingsSoundCuesTitle.
  ///
  /// In en, this message translates to:
  /// **'8: Sound cues'**
  String get settingsSoundCuesTitle;

  /// No description provided for @settingsVibrationTitle.
  ///
  /// In en, this message translates to:
  /// **'9: Vibration'**
  String get settingsVibrationTitle;

  /// No description provided for @settingsVoiceHelpButton.
  ///
  /// In en, this message translates to:
  /// **'Voice command help: say mute, unmute, raise hand, lower hand, leave or repeat.'**
  String get settingsVoiceHelpButton;

  /// No description provided for @uiSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get uiSave;

  /// No description provided for @uiClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get uiClose;

  /// No description provided for @learningLessonPositionLabel.
  ///
  /// In en, this message translates to:
  /// **'Lesson position'**
  String get learningLessonPositionLabel;

  /// No description provided for @learningReadStatusButton.
  ///
  /// In en, this message translates to:
  /// **'Read learning status'**
  String get learningReadStatusButton;

  /// No description provided for @learningAddBookmarkButton.
  ///
  /// In en, this message translates to:
  /// **'Add bookmark'**
  String get learningAddBookmarkButton;

  /// No description provided for @learningBookmarksButton.
  ///
  /// In en, this message translates to:
  /// **'Bookmarks ({count})'**
  String learningBookmarksButton(String count);

  /// No description provided for @learningPrivateNotesButton.
  ///
  /// In en, this message translates to:
  /// **'Private study notes'**
  String get learningPrivateNotesButton;

  /// No description provided for @learningSetAButton.
  ///
  /// In en, this message translates to:
  /// **'Set A'**
  String get learningSetAButton;

  /// Button that marks the start (point A) of an A-B repeat; time is the current mark.
  ///
  /// In en, this message translates to:
  /// **'Set A {time}'**
  String learningSetAAtButton(String time);

  /// No description provided for @learningSetBButton.
  ///
  /// In en, this message translates to:
  /// **'Set B'**
  String get learningSetBButton;

  /// Button that marks the end (point B) of an A-B repeat; time is the current mark.
  ///
  /// In en, this message translates to:
  /// **'Set B {time}'**
  String learningSetBAtButton(String time);

  /// No description provided for @learningRepeatOffButton.
  ///
  /// In en, this message translates to:
  /// **'Repeat off'**
  String get learningRepeatOffButton;

  /// No description provided for @learningRepeatOnButton.
  ///
  /// In en, this message translates to:
  /// **'Repeat on'**
  String get learningRepeatOnButton;

  /// No description provided for @learningClearABButton.
  ///
  /// In en, this message translates to:
  /// **'Clear A-B'**
  String get learningClearABButton;

  /// No description provided for @learningBackTenButton.
  ///
  /// In en, this message translates to:
  /// **'{key}: Back 10 seconds'**
  String learningBackTenButton(String key);

  /// No description provided for @learningForwardTenButton.
  ///
  /// In en, this message translates to:
  /// **'{key}: Forward 10 seconds'**
  String learningForwardTenButton(String key);

  /// No description provided for @learningSlowerButton.
  ///
  /// In en, this message translates to:
  /// **'{key}: Slower'**
  String learningSlowerButton(String key);

  /// No description provided for @learningFasterButton.
  ///
  /// In en, this message translates to:
  /// **'{key}: Faster'**
  String learningFasterButton(String key);

  /// No description provided for @learningRetrySavingButton.
  ///
  /// In en, this message translates to:
  /// **'Retry saving'**
  String get learningRetrySavingButton;

  /// No description provided for @learningNameBookmarkTitle.
  ///
  /// In en, this message translates to:
  /// **'Name bookmark'**
  String get learningNameBookmarkTitle;

  /// No description provided for @learningBookmarkNameFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get learningBookmarkNameFieldLabel;

  /// No description provided for @learningBookmarksTitle.
  ///
  /// In en, this message translates to:
  /// **'Bookmarks'**
  String get learningBookmarksTitle;

  /// No description provided for @learningBookmarksLessonChanged.
  ///
  /// In en, this message translates to:
  /// **'The lesson changed. Close this list and open bookmarks for the current lesson.'**
  String get learningBookmarksLessonChanged;

  /// No description provided for @learningBookmarksEmpty.
  ///
  /// In en, this message translates to:
  /// **'No bookmarks yet. Use Add bookmark at a position you want to remember.'**
  String get learningBookmarksEmpty;

  /// No description provided for @learningBookmarksUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Saved bookmarks are unavailable. Retry saving to restore access to saved progress.'**
  String get learningBookmarksUnavailable;

  /// No description provided for @learningBookmarkAtButton.
  ///
  /// In en, this message translates to:
  /// **'{label} at {time}'**
  String learningBookmarkAtButton(String label, String time);

  /// No description provided for @learningRemoveBookmarkSemantics.
  ///
  /// In en, this message translates to:
  /// **'Remove bookmark {label}'**
  String learningRemoveBookmarkSemantics(String label);

  /// On-screen button text showing the keypad key that activates it, e.g. '1: Continue'.
  ///
  /// In en, this message translates to:
  /// **'{key}: {label}'**
  String uiKeyedLabel(String key, String label);

  /// No description provided for @uiKeypadFooter.
  ///
  /// In en, this message translates to:
  /// **'*: Help. #: Stop app speech.'**
  String get uiKeypadFooter;

  /// No description provided for @uiListSearchValue.
  ///
  /// In en, this message translates to:
  /// **'Search: {query}'**
  String uiListSearchValue(String query);

  /// No description provided for @uiListLoadingShort.
  ///
  /// In en, this message translates to:
  /// **'Loading. Press 0 to go back.'**
  String get uiListLoadingShort;

  /// No description provided for @keypadTextEditingHint.
  ///
  /// In en, this message translates to:
  /// **'While editing, keys enter text. Press OK to finish. Use up or down if OK does not finish editing.'**
  String get keypadTextEditingHint;

  /// No description provided for @keypadWaitingConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Waiting for confirmation.'**
  String get keypadWaitingConfirmation;

  /// No description provided for @keypadContinueKey1.
  ///
  /// In en, this message translates to:
  /// **'1: Continue'**
  String get keypadContinueKey1;

  /// No description provided for @keypadHidePasswordKey2.
  ///
  /// In en, this message translates to:
  /// **'2: Hide password'**
  String get keypadHidePasswordKey2;

  /// No description provided for @keypadShowPasswordKey2.
  ///
  /// In en, this message translates to:
  /// **'2: Show password'**
  String get keypadShowPasswordKey2;

  /// No description provided for @keypadBackKey0.
  ///
  /// In en, this message translates to:
  /// **'0: Back'**
  String get keypadBackKey0;

  /// No description provided for @uiKeyedLabelUnavailable.
  ///
  /// In en, this message translates to:
  /// **'{number}: {label} (unavailable)'**
  String uiKeyedLabelUnavailable(String number, String label);

  /// No description provided for @journeyMenuReadDetailsKey8.
  ///
  /// In en, this message translates to:
  /// **'8: Read details again'**
  String get journeyMenuReadDetailsKey8;

  /// No description provided for @sessionTileHandRaised.
  ///
  /// In en, this message translates to:
  /// **'Hand raised'**
  String get sessionTileHandRaised;

  /// No description provided for @sessionTileSpeaking.
  ///
  /// In en, this message translates to:
  /// **'Speaking'**
  String get sessionTileSpeaking;

  /// No description provided for @sessionRemoveFromSession.
  ///
  /// In en, this message translates to:
  /// **'Remove {name} from session'**
  String sessionRemoveFromSession(String name);

  /// No description provided for @uiHourRange.
  ///
  /// In en, this message translates to:
  /// **'Hour (0 to 23)'**
  String get uiHourRange;

  /// No description provided for @uiSetDateTimeTitle.
  ///
  /// In en, this message translates to:
  /// **'Set date and time'**
  String get uiSetDateTimeTitle;

  /// No description provided for @uiSetDateTimeHint.
  ///
  /// In en, this message translates to:
  /// **'Use local time. Press OK to edit each number.'**
  String get uiSetDateTimeHint;

  /// No description provided for @quizExtraTitle.
  ///
  /// In en, this message translates to:
  /// **'Extra time: {name}'**
  String quizExtraTitle(String name);

  /// No description provided for @quizExtraInfo.
  ///
  /// In en, this message translates to:
  /// **'Future attempts only. Existing deadlines do not change. Quiz closing time still applies; extend availability separately if needed. Zero removes extra minutes.'**
  String get quizExtraInfo;

  /// No description provided for @quizExtraMinutesField.
  ///
  /// In en, this message translates to:
  /// **'Extra minutes'**
  String get quizExtraMinutesField;

  /// No description provided for @quizExtraSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save future extra time'**
  String get quizExtraSaveButton;

  /// No description provided for @quizSpeedValue.
  ///
  /// In en, this message translates to:
  /// **'Quiz speech speed: {speed}×'**
  String quizSpeedValue(String speed);

  /// No description provided for @uiCancelKey0.
  ///
  /// In en, this message translates to:
  /// **'0: Cancel'**
  String get uiCancelKey0;

  /// No description provided for @uiSaveKey1.
  ///
  /// In en, this message translates to:
  /// **'1: Save'**
  String get uiSaveKey1;

  /// No description provided for @uiNone.
  ///
  /// In en, this message translates to:
  /// **'none'**
  String get uiNone;

  /// No description provided for @uiPreviousOf.
  ///
  /// In en, this message translates to:
  /// **'Previous {label}'**
  String uiPreviousOf(String label);

  /// No description provided for @uiNextOf.
  ///
  /// In en, this message translates to:
  /// **'Next {label}'**
  String uiNextOf(String label);

  /// No description provided for @journeyOpening.
  ///
  /// In en, this message translates to:
  /// **'Opening journey'**
  String get journeyOpening;

  /// No description provided for @journeyStepHeading.
  ///
  /// In en, this message translates to:
  /// **'{position}. {kind}'**
  String journeyStepHeading(String position, String kind);

  /// No description provided for @journeyStepHeadingReplay.
  ///
  /// In en, this message translates to:
  /// **'{position}. {kind}. Listening again'**
  String journeyStepHeadingReplay(String position, String kind);

  /// No description provided for @journeyFirstTryShort.
  ///
  /// In en, this message translates to:
  /// **'{correct} of {total} correct on the first try.'**
  String journeyFirstTryShort(String correct, String total);

  /// No description provided for @journeyLeaveKey0.
  ///
  /// In en, this message translates to:
  /// **'0: Leave journey'**
  String get journeyLeaveKey0;

  /// No description provided for @quizRevisionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Question revisions'**
  String get quizRevisionsTitle;

  /// No description provided for @quizRevisionsBackTooltip.
  ///
  /// In en, this message translates to:
  /// **'Go back from question revisions'**
  String get quizRevisionsBackTooltip;

  /// No description provided for @quizRevisionSectionHear.
  ///
  /// In en, this message translates to:
  /// **'{section}. Double tap to hear it'**
  String quizRevisionSectionHear(String section);

  /// No description provided for @adminResetAttested.
  ///
  /// In en, this message translates to:
  /// **'Identity verification attested.'**
  String get adminResetAttested;

  /// No description provided for @adminResetNotAttested.
  ///
  /// In en, this message translates to:
  /// **'Identity verification not attested.'**
  String get adminResetNotAttested;

  /// No description provided for @adminResetConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset this password?'**
  String get adminResetConfirmTitle;

  /// No description provided for @adminResetConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Reset {name}, phone {phone}? This replaces the old password and ends online sessions. Disconnected downloaded lessons cannot be instantly revoked. Existing lessons, notes and learning records are retained. A 12-digit temporary credential lasts 24 hours and requires password change. After 10 wrong attempts, temporary-credential sign-in pauses for 15 minutes.'**
  String adminResetConfirmMessage(String name, String phone);

  /// No description provided for @adminResetKeepPassword.
  ///
  /// In en, this message translates to:
  /// **'Keep password'**
  String get adminResetKeepPassword;

  /// No description provided for @adminResetResetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get adminResetResetPassword;

  /// No description provided for @adminResetSignInChanged.
  ///
  /// In en, this message translates to:
  /// **'Administrator sign-in changed. No reset was sent.'**
  String get adminResetSignInChanged;

  /// No description provided for @adminResetSending.
  ///
  /// In en, this message translates to:
  /// **'Sending reset. Waiting for server confirmation.'**
  String get adminResetSending;

  /// No description provided for @adminResetNotConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Reset not confirmed. {reason} It may already have taken effect. Close and refresh this account before considering another reset.'**
  String adminResetNotConfirmed(String reason);

  /// No description provided for @adminResetResponseNotVerified.
  ///
  /// In en, this message translates to:
  /// **'The reset response could not be verified. The password may already have changed. Close and refresh before considering another reset.'**
  String get adminResetResponseNotVerified;

  /// No description provided for @adminResetConfirmedSpoken.
  ///
  /// In en, this message translates to:
  /// **'Password reset confirmed. The credential is hidden. Use Read credential only when it is private. Closing discards this copy.'**
  String get adminResetConfirmedSpoken;

  /// No description provided for @adminResetPhoneNotConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Reset could not be confirmed on this phone. Close and refresh the account before considering another reset.'**
  String get adminResetPhoneNotConfirmed;

  /// No description provided for @adminResetStorageUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Account storage is unavailable. Close recovery and restart SEEDS before considering a reset.'**
  String get adminResetStorageUnavailable;

  /// No description provided for @adminResetCredentialSpoken.
  ///
  /// In en, this message translates to:
  /// **'Temporary credential: {digits}. Expires at {expires}, UTC. Deliver privately to the verified person. It must be replaced at sign-in.'**
  String adminResetCredentialSpoken(String digits, String expires);

  /// No description provided for @adminResetDiscardTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard this credential copy?'**
  String get adminResetDiscardTitle;

  /// No description provided for @adminResetDiscardMessage.
  ///
  /// In en, this message translates to:
  /// **'Confirm that you delivered the temporary credential privately, or accept that another verified administrator reset will be needed. SEEDS will not show this copy again. This does not cancel the completed reset.'**
  String get adminResetDiscardMessage;

  /// No description provided for @adminResetKeepReviewing.
  ///
  /// In en, this message translates to:
  /// **'Keep reviewing'**
  String get adminResetKeepReviewing;

  /// No description provided for @adminResetCloseDiscard.
  ///
  /// In en, this message translates to:
  /// **'Close and discard'**
  String get adminResetCloseDiscard;

  /// No description provided for @adminResetScreenName.
  ///
  /// In en, this message translates to:
  /// **'Administrator password recovery. Verify identity outside SEEDS before resetting. Credentials are hidden until explicitly requested.'**
  String get adminResetScreenName;

  /// No description provided for @adminResetCloseRecovery.
  ///
  /// In en, this message translates to:
  /// **'Close recovery'**
  String get adminResetCloseRecovery;

  /// No description provided for @adminResetReadAccount.
  ///
  /// In en, this message translates to:
  /// **'Read selected account details'**
  String get adminResetReadAccount;

  /// No description provided for @adminResetAccountDetails.
  ///
  /// In en, this message translates to:
  /// **'{name}. Phone {phone}.'**
  String adminResetAccountDetails(String name, String phone);

  /// No description provided for @adminResetIdentityChecked.
  ///
  /// In en, this message translates to:
  /// **'Identity verified outside SEEDS. Checked. Press OK to change.'**
  String get adminResetIdentityChecked;

  /// No description provided for @adminResetIdentityNotChecked.
  ///
  /// In en, this message translates to:
  /// **'Identity verified outside SEEDS. Not checked. Press OK to change.'**
  String get adminResetIdentityNotChecked;

  /// No description provided for @adminResetResetAndEnd.
  ///
  /// In en, this message translates to:
  /// **'Reset password and end online sessions'**
  String get adminResetResetAndEnd;

  /// No description provided for @adminResetReadCredentialLabel.
  ///
  /// In en, this message translates to:
  /// **'Read and reveal temporary credential. Only use privately.'**
  String get adminResetReadCredentialLabel;

  /// No description provided for @adminResetCloseRefresh.
  ///
  /// In en, this message translates to:
  /// **'Close and refresh account'**
  String get adminResetCloseRefresh;

  /// No description provided for @adminResetTitle.
  ///
  /// In en, this message translates to:
  /// **'Password recovery'**
  String get adminResetTitle;

  /// No description provided for @adminResetVerifyInfo.
  ///
  /// In en, this message translates to:
  /// **'Verify the person outside SEEDS. A phone number or SIM suggestion is not identity verification. Never reset based only on a message or a claimed name.'**
  String get adminResetVerifyInfo;

  /// No description provided for @adminResetVerifiedCheckbox.
  ///
  /// In en, this message translates to:
  /// **'I verified this person outside SEEDS'**
  String get adminResetVerifiedCheckbox;

  /// No description provided for @adminResetWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting for reset confirmation.'**
  String get adminResetWaiting;

  /// No description provided for @adminResetConfirmedInfo.
  ///
  /// In en, this message translates to:
  /// **'Reset confirmed. Credential hidden until requested. It is valid for 24 hours. Closing discards this copy. Deliver privately; never post it in a class.'**
  String get adminResetConfirmedInfo;

  /// No description provided for @adminResetRevealButton.
  ///
  /// In en, this message translates to:
  /// **'Read and reveal credential privately'**
  String get adminResetRevealButton;

  /// No description provided for @adminResetCredentialShown.
  ///
  /// In en, this message translates to:
  /// **'Temporary credential: {digits}\nExpires: {expires} UTC'**
  String adminResetCredentialShown(String digits, String expires);

  /// No description provided for @adminResetCloseRefreshKey0.
  ///
  /// In en, this message translates to:
  /// **'0: Close and refresh account'**
  String get adminResetCloseRefreshKey0;

  /// No description provided for @apiTemporarySignInPaused.
  ///
  /// In en, this message translates to:
  /// **'Temporary-credential sign-in is paused for 15 minutes. Try later or contact your school administrator.'**
  String get apiTemporarySignInPaused;

  /// No description provided for @apiTemporaryCredentialExpired.
  ///
  /// In en, this message translates to:
  /// **'Your temporary credential expired. Contact your school administrator for a replacement.'**
  String get apiTemporaryCredentialExpired;

  /// No description provided for @apiPasswordMustDiffer.
  ///
  /// In en, this message translates to:
  /// **'Choose a password different from the temporary credential.'**
  String get apiPasswordMustDiffer;

  /// No description provided for @apiTemporaryCredentialRejected.
  ///
  /// In en, this message translates to:
  /// **'The temporary credential was not accepted. Check it and try again.'**
  String get apiTemporaryCredentialRejected;

  /// No description provided for @apiRecoverySignInExpired.
  ///
  /// In en, this message translates to:
  /// **'Your recovery sign-in expired or changed. Sign in again.'**
  String get apiRecoverySignInExpired;

  /// No description provided for @apiCheckInformation.
  ///
  /// In en, this message translates to:
  /// **'Please check the information and try again.'**
  String get apiCheckInformation;

  /// No description provided for @apiInvalidLogin.
  ///
  /// In en, this message translates to:
  /// **'Invalid phone number or password.'**
  String get apiInvalidLogin;

  /// No description provided for @apiNoPermission.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to do that.'**
  String get apiNoPermission;

  /// No description provided for @apiSessionNotFound.
  ///
  /// In en, this message translates to:
  /// **'Session not found. Check the session ID and try again.'**
  String get apiSessionNotFound;

  /// No description provided for @apiItemNotFound.
  ///
  /// In en, this message translates to:
  /// **'The requested item was not found.'**
  String get apiItemNotFound;

  /// No description provided for @apiServiceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The service is temporarily unavailable. Please try again.'**
  String get apiServiceUnavailable;

  /// No description provided for @apiNetworkFailure.
  ///
  /// In en, this message translates to:
  /// **'We could not complete that request. Check your connection and try again.'**
  String get apiNetworkFailure;

  /// No description provided for @apiUnknownFailure.
  ///
  /// In en, this message translates to:
  /// **'We could not complete that request. Please try again.'**
  String get apiUnknownFailure;

  /// No description provided for @apiAccountChangedRequestNotSent.
  ///
  /// In en, this message translates to:
  /// **'Your account changed. This request was not sent.'**
  String get apiAccountChangedRequestNotSent;

  /// No description provided for @apiAccountOrSessionChanged.
  ///
  /// In en, this message translates to:
  /// **'Your account or session changed. This action was not sent.'**
  String get apiAccountOrSessionChanged;

  /// No description provided for @apiResponseUnreadable.
  ///
  /// In en, this message translates to:
  /// **'The service response could not be read. The action may have been received; check its status before trying again.'**
  String get apiResponseUnreadable;

  /// No description provided for @apiSignInBeforeAction.
  ///
  /// In en, this message translates to:
  /// **'Sign in again before sending this action.'**
  String get apiSignInBeforeAction;

  /// No description provided for @apiAccountChangedNotConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Your account changed. This action could not be confirmed.'**
  String get apiAccountChangedNotConfirmed;

  /// No description provided for @apiActionNotConfirmed.
  ///
  /// In en, this message translates to:
  /// **'The action was not confirmed. It may have reached the class. Check its status before trying again.'**
  String get apiActionNotConfirmed;

  /// No description provided for @apiAccountChangedActionNotSent.
  ///
  /// In en, this message translates to:
  /// **'Your account changed. This action was not sent.'**
  String get apiAccountChangedActionNotSent;

  /// No description provided for @apiRequestFailed.
  ///
  /// In en, this message translates to:
  /// **'Request failed'**
  String get apiRequestFailed;

  /// No description provided for @notificationPrivateTitle.
  ///
  /// In en, this message translates to:
  /// **'SEEDS update'**
  String get notificationPrivateTitle;

  /// No description provided for @notificationPrivateBody.
  ///
  /// In en, this message translates to:
  /// **'Open SEEDS to review your updates.'**
  String get notificationPrivateBody;

  /// No description provided for @notificationRegistrationFailed.
  ///
  /// In en, this message translates to:
  /// **'Notifications could not be registered. Refresh SEEDS to check class invitations.'**
  String get notificationRegistrationFailed;

  /// No description provided for @notificationChannelName.
  ///
  /// In en, this message translates to:
  /// **'Session Notifications'**
  String get notificationChannelName;

  /// No description provided for @notificationChannelDescription.
  ///
  /// In en, this message translates to:
  /// **'Notifications for session invitations and updates'**
  String get notificationChannelDescription;

  /// No description provided for @notificationDisplayFailed.
  ///
  /// In en, this message translates to:
  /// **'An update arrived, but the phone notification could not be displayed. Open SEEDS to check updates.'**
  String get notificationDisplayFailed;

  /// No description provided for @activityCleanupFailed.
  ///
  /// In en, this message translates to:
  /// **'Expired activity could not be cleaned. Check device storage.'**
  String get activityCleanupFailed;

  /// No description provided for @activitySyncUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Activity sync is unavailable. Learning is still available.'**
  String get activitySyncUnavailable;

  /// No description provided for @activitySignInToSync.
  ///
  /// In en, this message translates to:
  /// **'Sign in to sync activity.'**
  String get activitySignInToSync;

  /// No description provided for @activityQueueFull.
  ///
  /// In en, this message translates to:
  /// **'Activity queue is full. Some older actions cannot be reported.'**
  String get activityQueueFull;

  /// No description provided for @activityWaitingToSync.
  ///
  /// In en, this message translates to:
  /// **'Some activity is waiting to sync.'**
  String get activityWaitingToSync;

  /// No description provided for @activityRejected.
  ///
  /// In en, this message translates to:
  /// **'Some activity was expired or no longer permitted and was not synced.'**
  String get activityRejected;

  /// No description provided for @authLogoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Log out of SEEDS?'**
  String get authLogoutTitle;

  /// No description provided for @authLogoutMessage.
  ///
  /// In en, this message translates to:
  /// **'You will need to enter your phone number and password again.'**
  String get authLogoutMessage;

  /// No description provided for @authLogoutCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get authLogoutCancel;

  /// No description provided for @authLogoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get authLogoutConfirm;

  /// No description provided for @authLoggedOut.
  ///
  /// In en, this message translates to:
  /// **'Logged out.'**
  String get authLoggedOut;

  /// No description provided for @startupLoadingTools.
  ///
  /// In en, this message translates to:
  /// **'Loading accessible learning tools…'**
  String get startupLoadingTools;

  /// No description provided for @startupTagline.
  ///
  /// In en, this message translates to:
  /// **'Connecting everyone, everywhere'**
  String get startupTagline;

  /// No description provided for @startupLoginKey1.
  ///
  /// In en, this message translates to:
  /// **'1. Login'**
  String get startupLoginKey1;

  /// No description provided for @startupLogin.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get startupLogin;

  /// No description provided for @startupRegisterKey2.
  ///
  /// In en, this message translates to:
  /// **'2. Register'**
  String get startupRegisterKey2;

  /// No description provided for @startupRegister.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get startupRegister;

  /// No description provided for @startupSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get startupSettings;

  /// No description provided for @startupRepeatInstructions.
  ///
  /// In en, this message translates to:
  /// **'Repeat instructions'**
  String get startupRepeatInstructions;

  /// No description provided for @startupFeatureAudioTitle.
  ///
  /// In en, this message translates to:
  /// **'Real-time Audio'**
  String get startupFeatureAudioTitle;

  /// No description provided for @startupFeatureAudioText.
  ///
  /// In en, this message translates to:
  /// **'Crystal clear voice communication'**
  String get startupFeatureAudioText;

  /// No description provided for @startupFeatureAccessibleTitle.
  ///
  /// In en, this message translates to:
  /// **'Fully Accessible'**
  String get startupFeatureAccessibleTitle;

  /// No description provided for @startupFeatureAccessibleText.
  ///
  /// In en, this message translates to:
  /// **'Speech, large buttons and keypad control'**
  String get startupFeatureAccessibleText;

  /// No description provided for @startupFeatureCollaborationTitle.
  ///
  /// In en, this message translates to:
  /// **'Collaboration'**
  String get startupFeatureCollaborationTitle;

  /// No description provided for @startupFeatureCollaborationText.
  ///
  /// In en, this message translates to:
  /// **'Raise hands and interact'**
  String get startupFeatureCollaborationText;

  /// No description provided for @settingsResetTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Settings'**
  String get settingsResetTitle;

  /// No description provided for @settingsResetCancelButton.
  ///
  /// In en, this message translates to:
  /// **'1: Cancel'**
  String get settingsResetCancelButton;

  /// No description provided for @settingsResetConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'2: Reset'**
  String get settingsResetConfirmButton;

  /// No description provided for @teacherHomeFallbackName.
  ///
  /// In en, this message translates to:
  /// **'Teacher {id}'**
  String teacherHomeFallbackName(String id);

  /// No description provided for @dashboardSignedInAs.
  ///
  /// In en, this message translates to:
  /// **'Signed in as {name}'**
  String dashboardSignedInAs(String name);

  /// No description provided for @dashboardRefreshSessionsKey1.
  ///
  /// In en, this message translates to:
  /// **'1: Refresh sessions'**
  String get dashboardRefreshSessionsKey1;

  /// No description provided for @dashboardLogOutKey0.
  ///
  /// In en, this message translates to:
  /// **'0: Log out'**
  String get dashboardLogOutKey0;

  /// No description provided for @dashboardRefreshingSessions.
  ///
  /// In en, this message translates to:
  /// **'Refreshing sessions'**
  String get dashboardRefreshingSessions;

  /// No description provided for @teacherHomeWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome, {name}!'**
  String teacherHomeWelcome(String name);

  /// No description provided for @teacherHomeTagline.
  ///
  /// In en, this message translates to:
  /// **'Manage your sessions and connect with students'**
  String get teacherHomeTagline;

  /// No description provided for @teacherHomeChooseWorkspaceKey7.
  ///
  /// In en, this message translates to:
  /// **'7: Choose class and subject workspace'**
  String get teacherHomeChooseWorkspaceKey7;

  /// No description provided for @teacherHomeChangeWorkspaceKey7.
  ///
  /// In en, this message translates to:
  /// **'7: {className}, {subjectName}. Change workspace'**
  String teacherHomeChangeWorkspaceKey7(String className, String subjectName);

  /// No description provided for @teacherHomePlaylistsKey5.
  ///
  /// In en, this message translates to:
  /// **'5: Class Playlists'**
  String get teacherHomePlaylistsKey5;

  /// No description provided for @teacherHomeJourneysKey8.
  ///
  /// In en, this message translates to:
  /// **'8: Learning Journeys'**
  String get teacherHomeJourneysKey8;

  /// No description provided for @teacherHomeQuizzesKey6.
  ///
  /// In en, this message translates to:
  /// **'6: Quizzes & Question Bank'**
  String get teacherHomeQuizzesKey6;

  /// No description provided for @teacherHomeCreateSessionKey2.
  ///
  /// In en, this message translates to:
  /// **'2: Create New Session'**
  String get teacherHomeCreateSessionKey2;

  /// No description provided for @dashboardAudioLibraryKey3.
  ///
  /// In en, this message translates to:
  /// **'3: Recorded Audio Library'**
  String get dashboardAudioLibraryKey3;

  /// No description provided for @teacherHomeSearchKey4.
  ///
  /// In en, this message translates to:
  /// **'4: Search by name or number'**
  String get teacherHomeSearchKey4;

  /// No description provided for @teacherHomeSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Type a session name, or the session number with the number keys. Leave empty to list all.'**
  String get teacherHomeSearchHint;

  /// No description provided for @teacherHomeYourSessions.
  ///
  /// In en, this message translates to:
  /// **'Your sessions'**
  String get teacherHomeYourSessions;

  /// No description provided for @teacherHomeYourSessionsCount.
  ///
  /// In en, this message translates to:
  /// **'Your sessions, {count}'**
  String teacherHomeYourSessionsCount(String count);

  /// No description provided for @teacherHomeYourSessionsHeading.
  ///
  /// In en, this message translates to:
  /// **'Your Sessions'**
  String get teacherHomeYourSessionsHeading;

  /// No description provided for @teacherHomeNoSessions.
  ///
  /// In en, this message translates to:
  /// **'No sessions yet. Press 2 to create one.'**
  String get teacherHomeNoSessions;

  /// No description provided for @teacherHomeNoMatches.
  ///
  /// In en, this message translates to:
  /// **'No matching sessions. Clear the search to list all sessions.'**
  String get teacherHomeNoMatches;

  /// No description provided for @teacherHomeEndTitleForEveryone.
  ///
  /// In en, this message translates to:
  /// **'End {title} for everyone'**
  String teacherHomeEndTitleForEveryone(String title);

  /// No description provided for @teacherHomeDeleteTitlePermanently.
  ///
  /// In en, this message translates to:
  /// **'Delete {title} permanently'**
  String teacherHomeDeleteTitlePermanently(String title);

  /// No description provided for @teacherHomeLiveJoined.
  ///
  /// In en, this message translates to:
  /// **'Live now, {count} joined'**
  String teacherHomeLiveJoined(String count);

  /// No description provided for @teacherHomeSessionNumber.
  ///
  /// In en, this message translates to:
  /// **'Session number {number}'**
  String teacherHomeSessionNumber(String number);

  /// No description provided for @teacherHomePlaceSessionNumber.
  ///
  /// In en, this message translates to:
  /// **'{place}. Session number {number}'**
  String teacherHomePlaceSessionNumber(String place, String number);

  /// No description provided for @teacherHomeDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get teacherHomeDelete;

  /// No description provided for @teacherHomeSessionTitleField.
  ///
  /// In en, this message translates to:
  /// **'Session Title'**
  String get teacherHomeSessionTitleField;

  /// No description provided for @teacherHomeSessionTitleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., English Class - Unit 5'**
  String get teacherHomeSessionTitleHint;

  /// No description provided for @teacherHomeCreateKey1.
  ///
  /// In en, this message translates to:
  /// **'Create (1)'**
  String get teacherHomeCreateKey1;

  /// No description provided for @studentHomeFallbackName.
  ///
  /// In en, this message translates to:
  /// **'Student {id}'**
  String studentHomeFallbackName(String id);

  /// No description provided for @studentHomeLoading.
  ///
  /// In en, this message translates to:
  /// **'Student dashboard is loading'**
  String get studentHomeLoading;

  /// No description provided for @studentHomeWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome, {name}'**
  String studentHomeWelcome(String name);

  /// No description provided for @studentHomeClass.
  ///
  /// In en, this message translates to:
  /// **'Class: {name}'**
  String studentHomeClass(String name);

  /// No description provided for @studentHomeAssignmentPending.
  ///
  /// In en, this message translates to:
  /// **'assignment pending'**
  String get studentHomeAssignmentPending;

  /// No description provided for @studentHomeLiveSessionsNone.
  ///
  /// In en, this message translates to:
  /// **'Live sessions: none'**
  String get studentHomeLiveSessionsNone;

  /// No description provided for @studentHomeLiveSessionsCount.
  ///
  /// In en, this message translates to:
  /// **'Live sessions: {count}'**
  String studentHomeLiveSessionsCount(String count);

  /// No description provided for @studentHomeSessionNumberKey2.
  ///
  /// In en, this message translates to:
  /// **'2: Session number'**
  String get studentHomeSessionNumberKey2;

  /// No description provided for @studentHomeSessionName.
  ///
  /// In en, this message translates to:
  /// **'Session name'**
  String get studentHomeSessionName;

  /// No description provided for @studentHomeSubjectFilter.
  ///
  /// In en, this message translates to:
  /// **'Subject filter'**
  String get studentHomeSubjectFilter;

  /// No description provided for @studentHomePlaylistsKey4.
  ///
  /// In en, this message translates to:
  /// **'4: My Playlists · Private'**
  String get studentHomePlaylistsKey4;

  /// No description provided for @studentHomeQuizzesKey5.
  ///
  /// In en, this message translates to:
  /// **'5: Quizzes'**
  String get studentHomeQuizzesKey5;

  /// No description provided for @studentHomeJourneysKey6.
  ///
  /// In en, this message translates to:
  /// **'6: Learning Journeys'**
  String get studentHomeJourneysKey6;

  /// No description provided for @studentHomeTeacher.
  ///
  /// In en, this message translates to:
  /// **'Teacher: {name}'**
  String studentHomeTeacher(String name);

  /// No description provided for @studentHomeSessionOkToJoin.
  ///
  /// In en, this message translates to:
  /// **'Session {number}. OK to join'**
  String studentHomeSessionOkToJoin(String number);

  /// No description provided for @studentHomeJoinSessionLabel.
  ///
  /// In en, this message translates to:
  /// **'{session}. Join session'**
  String studentHomeJoinSessionLabel(String session);

  /// No description provided for @adminActiveAssignmentCount.
  ///
  /// In en, this message translates to:
  /// **'{count} active assignments'**
  String adminActiveAssignmentCount(String count);

  /// No description provided for @adminHeadingCount.
  ///
  /// In en, this message translates to:
  /// **'{heading} ({count})'**
  String adminHeadingCount(String heading, String count);

  /// No description provided for @adminTextDialogHelper.
  ///
  /// In en, this message translates to:
  /// **'Press OK to type, then 1 to save or 0 to cancel'**
  String get adminTextDialogHelper;

  /// No description provided for @adminSaveKey1.
  ///
  /// In en, this message translates to:
  /// **'Save (1)'**
  String get adminSaveKey1;

  /// No description provided for @adminManageUser.
  ///
  /// In en, this message translates to:
  /// **'Manage {name}'**
  String adminManageUser(String name);

  /// No description provided for @adminManageAssignmentsKey1.
  ///
  /// In en, this message translates to:
  /// **'1: Manage assignments'**
  String get adminManageAssignmentsKey1;

  /// No description provided for @adminPasswordRecoveryKey2.
  ///
  /// In en, this message translates to:
  /// **'2: Password recovery'**
  String get adminPasswordRecoveryKey2;

  /// No description provided for @adminRemoveStudentFromClass.
  ///
  /// In en, this message translates to:
  /// **'Remove {name} from {className} (2)'**
  String adminRemoveStudentFromClass(String name, String className);

  /// No description provided for @adminRemoveClassKey2.
  ///
  /// In en, this message translates to:
  /// **'Remove class (2)'**
  String get adminRemoveClassKey2;

  /// No description provided for @adminAssignKey1.
  ///
  /// In en, this message translates to:
  /// **'Assign (1)'**
  String get adminAssignKey1;

  /// No description provided for @adminAssignTeacher.
  ///
  /// In en, this message translates to:
  /// **'Assign {name}'**
  String adminAssignTeacher(String name);

  /// No description provided for @adminCurrentAssignments.
  ///
  /// In en, this message translates to:
  /// **'Current assignments'**
  String get adminCurrentAssignments;

  /// No description provided for @adminRemoveTeacherAssignment.
  ///
  /// In en, this message translates to:
  /// **'Remove {name} from {className}, {subjectName}'**
  String adminRemoveTeacherAssignment(
    String name,
    String className,
    String subjectName,
  );

  /// No description provided for @adminAddAssignment.
  ///
  /// In en, this message translates to:
  /// **'Add an assignment'**
  String get adminAddAssignment;

  /// No description provided for @adminAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'SEEDS Administration'**
  String get adminAppBarTitle;

  /// No description provided for @adminRefreshKey1.
  ///
  /// In en, this message translates to:
  /// **'1: Refresh administration data'**
  String get adminRefreshKey1;

  /// No description provided for @adminLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading administration data'**
  String get adminLoading;

  /// No description provided for @adminChangeSectionKey7.
  ///
  /// In en, this message translates to:
  /// **'7: Change section. Now: {section}'**
  String adminChangeSectionKey7(String section);

  /// No description provided for @adminSearchKey2.
  ///
  /// In en, this message translates to:
  /// **'2: Search by name or phone number'**
  String get adminSearchKey2;

  /// No description provided for @adminSearchHelper.
  ///
  /// In en, this message translates to:
  /// **'Press OK when done to show matches'**
  String get adminSearchHelper;

  /// No description provided for @adminRoleFilterChipsLabel.
  ///
  /// In en, this message translates to:
  /// **'Account type filter: {label}, selected. Use left and right arrows to change.'**
  String adminRoleFilterChipsLabel(String label);

  /// No description provided for @adminAccountTypeKey3.
  ///
  /// In en, this message translates to:
  /// **'3: Account type'**
  String get adminAccountTypeKey3;

  /// No description provided for @adminChipAllAccounts.
  ///
  /// In en, this message translates to:
  /// **'All accounts'**
  String get adminChipAllAccounts;

  /// No description provided for @adminChipStudents.
  ///
  /// In en, this message translates to:
  /// **'Students'**
  String get adminChipStudents;

  /// No description provided for @adminChipTeachers.
  ///
  /// In en, this message translates to:
  /// **'Teachers'**
  String get adminChipTeachers;

  /// No description provided for @adminAssignmentFilterChipsLabel.
  ///
  /// In en, this message translates to:
  /// **'Assignment filter: {label}, selected. Use left and right arrows to change.'**
  String adminAssignmentFilterChipsLabel(String label);

  /// No description provided for @adminAssignmentKey4.
  ///
  /// In en, this message translates to:
  /// **'4: Assignment'**
  String get adminAssignmentKey4;

  /// No description provided for @adminChipAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get adminChipAll;

  /// No description provided for @adminCreateSubjectKey5.
  ///
  /// In en, this message translates to:
  /// **'5: Create subject'**
  String get adminCreateSubjectKey5;

  /// No description provided for @adminCreateClassKey6.
  ///
  /// In en, this message translates to:
  /// **'6: Create class'**
  String get adminCreateClassKey6;

  /// No description provided for @adminStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get adminStatusActive;

  /// No description provided for @adminClassTileHint.
  ///
  /// In en, this message translates to:
  /// **'Press OK for subjects, or to archive'**
  String get adminClassTileHint;

  /// No description provided for @adminPressOkRestore.
  ///
  /// In en, this message translates to:
  /// **'Press OK to restore'**
  String get adminPressOkRestore;

  /// No description provided for @adminPressOkArchive.
  ///
  /// In en, this message translates to:
  /// **'Press OK to archive'**
  String get adminPressOkArchive;

  /// No description provided for @sessionTitleTeacher.
  ///
  /// In en, this message translates to:
  /// **'{title} (Teacher)'**
  String sessionTitleTeacher(String title);

  /// No description provided for @libraryStatusStopped.
  ///
  /// In en, this message translates to:
  /// **'Stopped'**
  String get libraryStatusStopped;

  /// No description provided for @libraryUploadFileName.
  ///
  /// In en, this message translates to:
  /// **'File: {name}'**
  String libraryUploadFileName(String name);

  /// No description provided for @libraryAudioSessionTitle.
  ///
  /// In en, this message translates to:
  /// **'Audio - Session {number}'**
  String libraryAudioSessionTitle(String number);

  /// No description provided for @libraryRecordingsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} recordings'**
  String libraryRecordingsCount(String count);

  /// No description provided for @libraryUploadedAt.
  ///
  /// In en, this message translates to:
  /// **'Uploaded: {date}'**
  String libraryUploadedAt(String date);

  /// No description provided for @libraryStopPreviewOf.
  ///
  /// In en, this message translates to:
  /// **'Stop preview of {title}'**
  String libraryStopPreviewOf(String title);

  /// No description provided for @libraryPreviewPrivately.
  ///
  /// In en, this message translates to:
  /// **'Preview {title} privately'**
  String libraryPreviewPrivately(String title);

  /// No description provided for @libraryPlayForEveryone.
  ///
  /// In en, this message translates to:
  /// **'Play {title} for everyone in the session'**
  String libraryPlayForEveryone(String title);

  /// No description provided for @librarySelectClassHint.
  ///
  /// In en, this message translates to:
  /// **'Select a class to play recorded lessons. Online lessons require internet. Use Downloaded lessons for saved audio.'**
  String get librarySelectClassHint;

  /// No description provided for @libraryFoundCount.
  ///
  /// In en, this message translates to:
  /// **'{count} found'**
  String libraryFoundCount(String count);

  /// No description provided for @librarySearchSessionHint.
  ///
  /// In en, this message translates to:
  /// **'Use \"Search by Session Name\" above to access a class quickly.'**
  String get librarySearchSessionHint;

  /// No description provided for @librarySessionHash.
  ///
  /// In en, this message translates to:
  /// **'Session #{number}'**
  String librarySessionHash(String number);

  /// No description provided for @libraryStatusFinished.
  ///
  /// In en, this message translates to:
  /// **'Finished {title}'**
  String libraryStatusFinished(String title);

  /// No description provided for @libraryStatusPaused.
  ///
  /// In en, this message translates to:
  /// **'Paused {title}'**
  String libraryStatusPaused(String title);

  /// No description provided for @libraryStatusPlaying.
  ///
  /// In en, this message translates to:
  /// **'Playing {title}'**
  String libraryStatusPlaying(String title);

  /// No description provided for @libraryTitleField.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get libraryTitleField;

  /// No description provided for @libraryDescriptionOptional.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get libraryDescriptionOptional;

  /// No description provided for @libraryAudioLibrarySession.
  ///
  /// In en, this message translates to:
  /// **'Audio Library, session {number}'**
  String libraryAudioLibrarySession(String number);

  /// No description provided for @libraryUploadingAudio.
  ///
  /// In en, this message translates to:
  /// **'Uploading audio'**
  String get libraryUploadingAudio;

  /// No description provided for @libraryAddAudioKey3Tooltip.
  ///
  /// In en, this message translates to:
  /// **'Add audio, key 3'**
  String get libraryAddAudioKey3Tooltip;

  /// No description provided for @libraryAddAudioKey3.
  ///
  /// In en, this message translates to:
  /// **'3: Add audio'**
  String get libraryAddAudioKey3;

  /// No description provided for @libraryNoRecordingsForClass.
  ///
  /// In en, this message translates to:
  /// **'No recordings for this class yet.'**
  String get libraryNoRecordingsForClass;

  /// No description provided for @libraryNoRecordingsAskTeacher.
  ///
  /// In en, this message translates to:
  /// **'No recordings available yet. Ask your teacher to upload some.'**
  String get libraryNoRecordingsAskTeacher;

  /// No description provided for @libraryPositionSpeed.
  ///
  /// In en, this message translates to:
  /// **'{position} of {total}. Speed {speed}x'**
  String libraryPositionSpeed(String position, String total, String speed);

  /// No description provided for @libraryNowPlaying.
  ///
  /// In en, this message translates to:
  /// **'Now playing: {title}'**
  String libraryNowPlaying(String title);

  /// No description provided for @libraryRecordingsMatch.
  ///
  /// In en, this message translates to:
  /// **'{count} of {total} recordings match'**
  String libraryRecordingsMatch(String count, String total);

  /// No description provided for @libraryNoUnlinkedAudio.
  ///
  /// In en, this message translates to:
  /// **'No unlinked audio available.'**
  String get libraryNoUnlinkedAudio;

  /// No description provided for @libraryNoSearchMatches.
  ///
  /// In en, this message translates to:
  /// **'No recordings match your search.'**
  String get libraryNoSearchMatches;

  /// No description provided for @libraryFindingLesson.
  ///
  /// In en, this message translates to:
  /// **'Finding your lesson'**
  String get libraryFindingLesson;

  /// No description provided for @libraryTitleRequiredField.
  ///
  /// In en, this message translates to:
  /// **'Title *'**
  String get libraryTitleRequiredField;

  /// No description provided for @libraryUploadNewAudio.
  ///
  /// In en, this message translates to:
  /// **'Upload New Audio'**
  String get libraryUploadNewAudio;

  /// No description provided for @libraryStopPreview.
  ///
  /// In en, this message translates to:
  /// **'Stop Preview'**
  String get libraryStopPreview;

  /// No description provided for @libraryPreviewOnlyMe.
  ///
  /// In en, this message translates to:
  /// **'Preview (Only Me)'**
  String get libraryPreviewOnlyMe;

  /// No description provided for @libraryPreview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get libraryPreview;

  /// No description provided for @libraryStop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get libraryStop;

  /// No description provided for @libraryPlayInSession.
  ///
  /// In en, this message translates to:
  /// **'Play in Session'**
  String get libraryPlayInSession;

  /// No description provided for @librarySessionShort.
  ///
  /// In en, this message translates to:
  /// **'Session'**
  String get librarySessionShort;

  /// No description provided for @libraryNotesTooltip.
  ///
  /// In en, this message translates to:
  /// **'Private notes and recording drafts'**
  String get libraryNotesTooltip;

  /// No description provided for @libraryBrowseClassesKey5.
  ///
  /// In en, this message translates to:
  /// **'5: Browse active classes'**
  String get libraryBrowseClassesKey5;

  /// No description provided for @librarySearchClassByName.
  ///
  /// In en, this message translates to:
  /// **'Search Class by Name'**
  String get librarySearchClassByName;

  /// No description provided for @librarySearchClassHint.
  ///
  /// In en, this message translates to:
  /// **'Enter Session/Class Name'**
  String get librarySearchClassHint;

  /// No description provided for @libraryMyAudioLibrary.
  ///
  /// In en, this message translates to:
  /// **'My Audio Library'**
  String get libraryMyAudioLibrary;

  /// No description provided for @libraryAllAudioFiles.
  ///
  /// In en, this message translates to:
  /// **'All Audio Files'**
  String get libraryAllAudioFiles;

  /// No description provided for @libraryManageAudioFiles.
  ///
  /// In en, this message translates to:
  /// **'Manage and upload your audio files'**
  String get libraryManageAudioFiles;

  /// No description provided for @libraryBrowseAudioFiles.
  ///
  /// In en, this message translates to:
  /// **'Browse all uploaded audio files'**
  String get libraryBrowseAudioFiles;

  /// No description provided for @libraryActiveClasses.
  ///
  /// In en, this message translates to:
  /// **'Active Classes'**
  String get libraryActiveClasses;

  /// No description provided for @libraryNoActiveClasses.
  ///
  /// In en, this message translates to:
  /// **'No active classes found.'**
  String get libraryNoActiveClasses;

  /// No description provided for @libraryAddAudioToSessions.
  ///
  /// In en, this message translates to:
  /// **'Add audio to sessions'**
  String get libraryAddAudioToSessions;

  /// No description provided for @libraryConfirmKey1.
  ///
  /// In en, this message translates to:
  /// **'1: Confirm'**
  String get libraryConfirmKey1;

  /// No description provided for @libraryDownloadLessons.
  ///
  /// In en, this message translates to:
  /// **'Download lessons'**
  String get libraryDownloadLessons;

  /// No description provided for @libraryRepeatHelp.
  ///
  /// In en, this message translates to:
  /// **'Repeat help'**
  String get libraryRepeatHelp;

  /// No description provided for @libraryBack10s.
  ///
  /// In en, this message translates to:
  /// **'Back 10 s'**
  String get libraryBack10s;

  /// No description provided for @libraryPause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get libraryPause;

  /// No description provided for @libraryPlay.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get libraryPlay;

  /// No description provided for @libraryForward10s.
  ///
  /// In en, this message translates to:
  /// **'Forward 10 s'**
  String get libraryForward10s;

  /// No description provided for @libraryCloseAddAudio.
  ///
  /// In en, this message translates to:
  /// **'Close add audio options'**
  String get libraryCloseAddAudio;

  /// No description provided for @libraryUploadNewFileKey1.
  ///
  /// In en, this message translates to:
  /// **'1: Upload New File'**
  String get libraryUploadNewFileKey1;

  /// No description provided for @librarySelectExistingKey2.
  ///
  /// In en, this message translates to:
  /// **'2: Select from Existing Library'**
  String get librarySelectExistingKey2;

  /// No description provided for @librarySelectAudio.
  ///
  /// In en, this message translates to:
  /// **'Select Audio'**
  String get librarySelectAudio;

  /// No description provided for @libraryRefreshAvailable.
  ///
  /// In en, this message translates to:
  /// **'Refresh available audio'**
  String get libraryRefreshAvailable;

  /// No description provided for @librarySearchByTitle.
  ///
  /// In en, this message translates to:
  /// **'Search by title'**
  String get librarySearchByTitle;

  /// No description provided for @libraryNothingPlaying.
  ///
  /// In en, this message translates to:
  /// **'Nothing playing. Select a lesson or press 5.'**
  String get libraryNothingPlaying;

  /// No description provided for @spokenDayMonthYear.
  ///
  /// In en, this message translates to:
  /// **'{day} {month} {year}'**
  String spokenDayMonthYear(String day, String month, String year);

  /// No description provided for @downloadPartialReserve.
  ///
  /// In en, this message translates to:
  /// **'Partial files reserve their complete size.'**
  String get downloadPartialReserve;

  /// No description provided for @downloadProgressStarting.
  ///
  /// In en, this message translates to:
  /// **'{title}: starting downloaded'**
  String downloadProgressStarting(String title);

  /// No description provided for @downloadPercentDone.
  ///
  /// In en, this message translates to:
  /// **'{title}: {percent} percent downloaded'**
  String downloadPercentDone(String title, String percent);

  /// No description provided for @downloadRecordUnreadable.
  ///
  /// In en, this message translates to:
  /// **'Download record {id} could not be read. Files are kept. Remove only this download to recover; progress and bookmarks are kept.'**
  String downloadRecordUnreadable(String id);

  /// No description provided for @downloadRemoveUnreadable.
  ///
  /// In en, this message translates to:
  /// **'Remove unreadable download {id}'**
  String downloadRemoveUnreadable(String id);

  /// No description provided for @downloadStatusDownloaded.
  ///
  /// In en, this message translates to:
  /// **'Downloaded'**
  String get downloadStatusDownloaded;

  /// No description provided for @downloadStatusPartial.
  ///
  /// In en, this message translates to:
  /// **'Partial download'**
  String get downloadStatusPartial;

  /// No description provided for @downloadSizeRenewal.
  ///
  /// In en, this message translates to:
  /// **'{megabytes} MB. Access renewal required.'**
  String downloadSizeRenewal(String megabytes);

  /// No description provided for @downloadSizeExpires.
  ///
  /// In en, this message translates to:
  /// **'{megabytes} MB. Access expires on {date}.'**
  String downloadSizeExpires(String megabytes, String date);

  /// No description provided for @downloadTitle.
  ///
  /// In en, this message translates to:
  /// **'Downloads'**
  String get downloadTitle;

  /// No description provided for @downloadAccessInfo.
  ///
  /// In en, this message translates to:
  /// **'30-day offline access. Other accounts have separate allowances. No automatic deletion.'**
  String get downloadAccessInfo;

  /// No description provided for @downloadRefreshKey1.
  ///
  /// In en, this message translates to:
  /// **'1: Refresh downloads'**
  String get downloadRefreshKey1;

  /// No description provided for @downloadFindOnlineKey2.
  ///
  /// In en, this message translates to:
  /// **'2: Find recordings online'**
  String get downloadFindOnlineKey2;

  /// No description provided for @downloadReadStatusKey3.
  ///
  /// In en, this message translates to:
  /// **'3: Read status'**
  String get downloadReadStatusKey3;

  /// No description provided for @downloadCancelKey4.
  ///
  /// In en, this message translates to:
  /// **'4: Cancel download'**
  String get downloadCancelKey4;

  /// No description provided for @downloadNoneYetFindOnline.
  ///
  /// In en, this message translates to:
  /// **'No downloads yet. Find recordings online or open Downloads from a class or playlist.'**
  String get downloadNoneYetFindOnline;

  /// No description provided for @downloadPlayLesson.
  ///
  /// In en, this message translates to:
  /// **'Play downloaded lesson'**
  String get downloadPlayLesson;

  /// No description provided for @downloadRenewOnline.
  ///
  /// In en, this message translates to:
  /// **'Renew access online'**
  String get downloadRenewOnline;

  /// No description provided for @downloadRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove download'**
  String get downloadRemove;

  /// No description provided for @downloadListedKey5.
  ///
  /// In en, this message translates to:
  /// **'5: Download listed recordings'**
  String get downloadListedKey5;

  /// No description provided for @downloadAvailableInfo.
  ///
  /// In en, this message translates to:
  /// **'Available recordings. Downloads use internet data.'**
  String get downloadAvailableInfo;

  /// No description provided for @playlistClassSubjectTitle.
  ///
  /// In en, this message translates to:
  /// **'{className} · {subjectName} Playlists'**
  String playlistClassSubjectTitle(String className, String subjectName);

  /// No description provided for @playlistStatusPrivate.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get playlistStatusPrivate;

  /// No description provided for @playlistClassPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Class playlist'**
  String get playlistClassPlaylist;

  /// No description provided for @playlistItemCount.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String playlistItemCount(String count);

  /// No description provided for @playlistClassItemCount.
  ///
  /// In en, this message translates to:
  /// **'{className}, {subjectName}, {count} items'**
  String playlistClassItemCount(
    String className,
    String subjectName,
    String count,
  );

  /// No description provided for @playlistFinished.
  ///
  /// In en, this message translates to:
  /// **'Finished. End of playlist'**
  String get playlistFinished;

  /// No description provided for @playlistAddKey2.
  ///
  /// In en, this message translates to:
  /// **'2 Add'**
  String get playlistAddKey2;

  /// No description provided for @playlistAddAudioKey2Label.
  ///
  /// In en, this message translates to:
  /// **'Add audio, key 2'**
  String get playlistAddAudioKey2Label;

  /// No description provided for @playlistPauseKey5.
  ///
  /// In en, this message translates to:
  /// **'5 Pause'**
  String get playlistPauseKey5;

  /// No description provided for @playlistPlayKey5.
  ///
  /// In en, this message translates to:
  /// **'5 Play'**
  String get playlistPlayKey5;

  /// No description provided for @playlistPauseTitleKey5.
  ///
  /// In en, this message translates to:
  /// **'Pause {title}, key 5'**
  String playlistPauseTitleKey5(String title);

  /// No description provided for @playlistPlayTitleKey5.
  ///
  /// In en, this message translates to:
  /// **'Play {title}, key 5'**
  String playlistPlayTitleKey5(String title);

  /// No description provided for @playlistPreviousKey3.
  ///
  /// In en, this message translates to:
  /// **'3 Previous'**
  String get playlistPreviousKey3;

  /// No description provided for @playlistPreviousItemKey3.
  ///
  /// In en, this message translates to:
  /// **'Previous item, key 3'**
  String get playlistPreviousItemKey3;

  /// No description provided for @playlistNextKey8.
  ///
  /// In en, this message translates to:
  /// **'8 Next'**
  String get playlistNextKey8;

  /// No description provided for @playlistNextItemKey8.
  ///
  /// In en, this message translates to:
  /// **'Next item, key 8'**
  String get playlistNextItemKey8;

  /// No description provided for @playlistRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get playlistRestore;

  /// No description provided for @playlistArchive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get playlistArchive;

  /// No description provided for @playlistDeletePlaylist.
  ///
  /// In en, this message translates to:
  /// **'Delete playlist'**
  String get playlistDeletePlaylist;

  /// No description provided for @playlistRestoreNamedButton.
  ///
  /// In en, this message translates to:
  /// **'Restore {title}'**
  String playlistRestoreNamedButton(String title);

  /// No description provided for @playlistArchiveNamedButton.
  ///
  /// In en, this message translates to:
  /// **'Archive {title}'**
  String playlistArchiveNamedButton(String title);

  /// No description provided for @playlistDeleteNamedButton.
  ///
  /// In en, this message translates to:
  /// **'Delete {title}'**
  String playlistDeleteNamedButton(String title);

  /// No description provided for @playlistMoveUp.
  ///
  /// In en, this message translates to:
  /// **'Move {title} up'**
  String playlistMoveUp(String title);

  /// No description provided for @playlistMoveDown.
  ///
  /// In en, this message translates to:
  /// **'Move {title} down'**
  String playlistMoveDown(String title);

  /// No description provided for @playlistCreateKey2.
  ///
  /// In en, this message translates to:
  /// **'2: Create playlist'**
  String get playlistCreateKey2;

  /// No description provided for @playlistNoneInClass.
  ///
  /// In en, this message translates to:
  /// **'No playlists in this class and subject. Press 2 to create one.'**
  String get playlistNoneInClass;

  /// No description provided for @playlistMyPlaylists.
  ///
  /// In en, this message translates to:
  /// **'My Playlists'**
  String get playlistMyPlaylists;

  /// No description provided for @playlistPrivateNoticeTitle.
  ///
  /// In en, this message translates to:
  /// **'Your playlists are private'**
  String get playlistPrivateNoticeTitle;

  /// No description provided for @playlistPrivateNoticeText.
  ///
  /// In en, this message translates to:
  /// **'Teachers, administrators, and other students cannot view them.'**
  String get playlistPrivateNoticeText;

  /// No description provided for @playlistCreatePrivateKey2.
  ///
  /// In en, this message translates to:
  /// **'2: Create private playlist'**
  String get playlistCreatePrivateKey2;

  /// No description provided for @playlistMyPrivateHeading.
  ///
  /// In en, this message translates to:
  /// **'My private playlists'**
  String get playlistMyPrivateHeading;

  /// No description provided for @playlistNoPrivate.
  ///
  /// In en, this message translates to:
  /// **'No private playlists yet.'**
  String get playlistNoPrivate;

  /// No description provided for @playlistClassHeading.
  ///
  /// In en, this message translates to:
  /// **'Class playlists'**
  String get playlistClassHeading;

  /// No description provided for @playlistNoClassPublished.
  ///
  /// In en, this message translates to:
  /// **'No class playlists published yet.'**
  String get playlistNoClassPublished;

  /// No description provided for @playlistAddAudioTitle.
  ///
  /// In en, this message translates to:
  /// **'Add audio'**
  String get playlistAddAudioTitle;

  /// No description provided for @playlistUnavailableRetry.
  ///
  /// In en, this message translates to:
  /// **'Playlist is unavailable. Press 1 to try again.'**
  String get playlistUnavailableRetry;

  /// No description provided for @playlistDownloadRecordings.
  ///
  /// In en, this message translates to:
  /// **'Download playlist recordings'**
  String get playlistDownloadRecordings;

  /// No description provided for @playlistMoveHint.
  ///
  /// In en, this message translates to:
  /// **'Play or select an item, then move it up or down.'**
  String get playlistMoveHint;

  /// No description provided for @playlistNoAudio.
  ///
  /// In en, this message translates to:
  /// **'This playlist has no audio yet.'**
  String get playlistNoAudio;

  /// No description provided for @quizClassSubjectHeading.
  ///
  /// In en, this message translates to:
  /// **'{className} · {subjectName}'**
  String quizClassSubjectHeading(String className, String subjectName);

  /// No description provided for @quizBankEditNote.
  ///
  /// In en, this message translates to:
  /// **'Editing a bank question never changes an existing quiz snapshot.'**
  String get quizBankEditNote;

  /// No description provided for @quizNoBankQuestions.
  ///
  /// In en, this message translates to:
  /// **'No bank questions yet'**
  String get quizNoBankQuestions;

  /// No description provided for @quizOptionsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} options'**
  String quizOptionsCount(String count);

  /// No description provided for @quizNoQuizzesYet.
  ///
  /// In en, this message translates to:
  /// **'No quizzes yet'**
  String get quizNoQuizzesYet;

  /// No description provided for @quizStepReviewPublish.
  ///
  /// In en, this message translates to:
  /// **'Step 3: Review and publish'**
  String get quizStepReviewPublish;

  /// No description provided for @quizStepAddQuestions.
  ///
  /// In en, this message translates to:
  /// **'Step 2: Add questions'**
  String get quizStepAddQuestions;

  /// No description provided for @quizResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'{title} results'**
  String quizResultsTitle(String title);

  /// No description provided for @quizAllAttempted.
  ///
  /// In en, this message translates to:
  /// **'All students have attempted'**
  String get quizAllAttempted;

  /// No description provided for @quizRemindAllKey2.
  ///
  /// In en, this message translates to:
  /// **'2: Remind all not attempted'**
  String get quizRemindAllKey2;

  /// No description provided for @uiNoneCapital.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get uiNoneCapital;

  /// No description provided for @quizPracticeParticipationHeading.
  ///
  /// In en, this message translates to:
  /// **'Practice participation, not academic grades'**
  String get quizPracticeParticipationHeading;

  /// No description provided for @quizIndividualScores.
  ///
  /// In en, this message translates to:
  /// **'Individual student scores'**
  String get quizIndividualScores;

  /// No description provided for @quizNotAttempted.
  ///
  /// In en, this message translates to:
  /// **'Not attempted'**
  String get quizNotAttempted;

  /// No description provided for @quizPracticeNotGraded.
  ///
  /// In en, this message translates to:
  /// **'Practice, not graded'**
  String get quizPracticeNotGraded;

  /// No description provided for @quizHighestScore.
  ///
  /// In en, this message translates to:
  /// **'Highest score: {score}'**
  String quizHighestScore(String score);

  /// No description provided for @quizAttemptInProgress.
  ///
  /// In en, this message translates to:
  /// **'Attempt in progress'**
  String get quizAttemptInProgress;

  /// No description provided for @quizQuizzesTitle.
  ///
  /// In en, this message translates to:
  /// **'Quizzes'**
  String get quizQuizzesTitle;

  /// No description provided for @quizRefreshQuizzesTooltip.
  ///
  /// In en, this message translates to:
  /// **'Refresh quizzes'**
  String get quizRefreshQuizzesTooltip;

  /// No description provided for @quizLoadingQuizzes.
  ///
  /// In en, this message translates to:
  /// **'Loading quizzes'**
  String get quizLoadingQuizzes;

  /// No description provided for @quizNewBankQuestionKey2.
  ///
  /// In en, this message translates to:
  /// **'2: New bank question'**
  String get quizNewBankQuestionKey2;

  /// No description provided for @quizNewDraftKey3.
  ///
  /// In en, this message translates to:
  /// **'3: New quiz draft'**
  String get quizNewDraftKey3;

  /// No description provided for @quizCreatePracticeKey4.
  ///
  /// In en, this message translates to:
  /// **'4: Create untimed practice'**
  String get quizCreatePracticeKey4;

  /// No description provided for @quizPrivateBankHeading.
  ///
  /// In en, this message translates to:
  /// **'Private question bank'**
  String get quizPrivateBankHeading;

  /// No description provided for @quizOptionsButton.
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get quizOptionsButton;

  /// No description provided for @quizManagementHeading.
  ///
  /// In en, this message translates to:
  /// **'Quiz management'**
  String get quizManagementHeading;

  /// No description provided for @quizContinueCreation.
  ///
  /// In en, this message translates to:
  /// **'Continue creation'**
  String get quizContinueCreation;

  /// No description provided for @quizCloseButton.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get quizCloseButton;

  /// No description provided for @quizDuplicateButton.
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get quizDuplicateButton;

  /// No description provided for @quizResultsButton.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get quizResultsButton;

  /// No description provided for @quizRefreshResultsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Refresh results'**
  String get quizRefreshResultsTooltip;

  /// No description provided for @quizClassStatistics.
  ///
  /// In en, this message translates to:
  /// **'Class statistics'**
  String get quizClassStatistics;

  /// No description provided for @quizStudentsYetToAttempt.
  ///
  /// In en, this message translates to:
  /// **'Students yet to attempt'**
  String get quizStudentsYetToAttempt;

  /// No description provided for @quizNoQuizzesAvailableLabel.
  ///
  /// In en, this message translates to:
  /// **'No quizzes available'**
  String get quizNoQuizzesAvailableLabel;

  /// No description provided for @quizAttemptLimitReachedLabel.
  ///
  /// In en, this message translates to:
  /// **'Attempt limit reached'**
  String get quizAttemptLimitReachedLabel;

  /// No description provided for @quizAnswerSavedLockedTitle.
  ///
  /// In en, this message translates to:
  /// **'Answer saved and locked'**
  String get quizAnswerSavedLockedTitle;

  /// No description provided for @quizAllSavedViewResult.
  ///
  /// In en, this message translates to:
  /// **'All answers are saved. Select View result to confirm completion.'**
  String get quizAllSavedViewResult;

  /// No description provided for @quizAsksToConfirm.
  ///
  /// In en, this message translates to:
  /// **'{label}, asks to confirm'**
  String quizAsksToConfirm(String label);

  /// No description provided for @quizConfirmingCompletion.
  ///
  /// In en, this message translates to:
  /// **'Confirming completion'**
  String get quizConfirmingCompletion;

  /// No description provided for @quizRetryCompletionKey5.
  ///
  /// In en, this message translates to:
  /// **'5: Retry completion'**
  String get quizRetryCompletionKey5;

  /// No description provided for @quizViewResultKey5.
  ///
  /// In en, this message translates to:
  /// **'5: View result'**
  String get quizViewResultKey5;

  /// No description provided for @quizHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'{title} history'**
  String quizHistoryTitle(String title);

  /// No description provided for @quizNoAttemptsYet.
  ///
  /// In en, this message translates to:
  /// **'No attempts yet'**
  String get quizNoAttemptsYet;

  /// No description provided for @quizHistoryTooltip.
  ///
  /// In en, this message translates to:
  /// **'Attempt history and review'**
  String get quizHistoryTooltip;

  /// No description provided for @quizLeaveWithoutSubmitting.
  ///
  /// In en, this message translates to:
  /// **'Leave without submitting'**
  String get quizLeaveWithoutSubmitting;

  /// No description provided for @quizAttemptCompletePrivateLabel.
  ///
  /// In en, this message translates to:
  /// **'Attempt complete. Result private. Use Read result privately.'**
  String get quizAttemptCompletePrivateLabel;

  /// No description provided for @quizReadResultKey8.
  ///
  /// In en, this message translates to:
  /// **'8: Read result privately'**
  String get quizReadResultKey8;

  /// No description provided for @quizReturnKey0.
  ///
  /// In en, this message translates to:
  /// **'0: Return to quizzes'**
  String get quizReturnKey0;

  /// No description provided for @quizReadAllOptionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Read all options'**
  String get quizReadAllOptionsLabel;

  /// No description provided for @quizSubmitAnswerKey5.
  ///
  /// In en, this message translates to:
  /// **'5: Submit answer'**
  String get quizSubmitAnswerKey5;

  /// No description provided for @quizAnswerLockedActivate.
  ///
  /// In en, this message translates to:
  /// **'Answer saved and locked. Activate to read feedback privately.'**
  String get quizAnswerLockedActivate;

  /// No description provided for @quizReadSelectedAnswer.
  ///
  /// In en, this message translates to:
  /// **'Read selected answer'**
  String get quizReadSelectedAnswer;

  /// No description provided for @quizReadRemainingTime.
  ///
  /// In en, this message translates to:
  /// **'Read remaining time'**
  String get quizReadRemainingTime;

  /// No description provided for @quizAttemptReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Attempt review'**
  String get quizAttemptReviewTitle;

  /// No description provided for @quizEditorIntro.
  ///
  /// In en, this message translates to:
  /// **'Complete the question and all four options, then choose the correct answer. For equations or diagrams, expand optional spoken notation and review the alternatives.'**
  String get quizEditorIntro;

  /// No description provided for @quizWhichCorrect.
  ///
  /// In en, this message translates to:
  /// **'Which answer is correct?'**
  String get quizWhichCorrect;

  /// No description provided for @quizChooseCorrectOption.
  ///
  /// In en, this message translates to:
  /// **'Choose the correct option'**
  String get quizChooseCorrectOption;

  /// No description provided for @quizOptionWithText.
  ///
  /// In en, this message translates to:
  /// **'Option {number}: {text}'**
  String quizOptionWithText(String number, String text);

  /// No description provided for @quizCorrectChoiceHint.
  ///
  /// In en, this message translates to:
  /// **'Use Left or Right to change. OK or tap selects the next option.'**
  String get quizCorrectChoiceHint;

  /// No description provided for @quizExplanationOptional.
  ///
  /// In en, this message translates to:
  /// **'Explanation (optional)'**
  String get quizExplanationOptional;

  /// No description provided for @quizContentDescribedText.
  ///
  /// In en, this message translates to:
  /// **'Content: Teacher-described notation or diagram'**
  String get quizContentDescribedText;

  /// No description provided for @quizNotationNote.
  ///
  /// In en, this message translates to:
  /// **'No automatic equation or diagram interpretation is provided. Teachers must write and review English spoken alternatives. For described notation, include the question, all options, and any explanation.'**
  String get quizNotationNote;

  /// No description provided for @quizReviewedAlternatives.
  ///
  /// In en, this message translates to:
  /// **'I have reviewed the spoken alternatives for accuracy'**
  String get quizReviewedAlternatives;

  /// No description provided for @quizChangeSettings.
  ///
  /// In en, this message translates to:
  /// **'Change quiz settings'**
  String get quizChangeSettings;

  /// No description provided for @quizCreatePracticeText.
  ///
  /// In en, this message translates to:
  /// **'Create untimed practice'**
  String get quizCreatePracticeText;

  /// No description provided for @quizStepName.
  ///
  /// In en, this message translates to:
  /// **'Step 1: Name your quiz'**
  String get quizStepName;

  /// No description provided for @quizPracticeInfo.
  ///
  /// In en, this message translates to:
  /// **'Practice has no per-attempt timer or retry cap. An optional closing time still ends availability.'**
  String get quizPracticeInfo;

  /// No description provided for @quizSettingsNavLabel.
  ///
  /// In en, this message translates to:
  /// **'Use up and down to move through quiz settings. Press OK to edit text fields. Opening and closing times are optional.'**
  String get quizSettingsNavLabel;

  /// No description provided for @quizSettingsNavText.
  ///
  /// In en, this message translates to:
  /// **'Use Up and Down to move through settings, and OK to edit. Saving a draft or its settings does not publish the quiz.'**
  String get quizSettingsNavText;

  /// No description provided for @quizSettingsReviewInfo.
  ///
  /// In en, this message translates to:
  /// **'Review and change the saved settings below. Saving does not publish the quiz.'**
  String get quizSettingsReviewInfo;

  /// No description provided for @quizPracticeDefaults.
  ///
  /// In en, this message translates to:
  /// **'Ungraded practice. Unlimited attempts, no timer, immediate feedback.'**
  String get quizPracticeDefaults;

  /// No description provided for @quizGradedDefaults.
  ///
  /// In en, this message translates to:
  /// **'Default graded settings: one attempt, no timer, feedback after final submission.'**
  String get quizGradedDefaults;

  /// No description provided for @quizHideOptionalSettingsText.
  ///
  /// In en, this message translates to:
  /// **'Hide optional settings'**
  String get quizHideOptionalSettingsText;

  /// No description provided for @quizShowOptionalSettingsText.
  ///
  /// In en, this message translates to:
  /// **'Show optional settings'**
  String get quizShowOptionalSettingsText;

  /// No description provided for @quizAttemptLimitFieldText.
  ///
  /// In en, this message translates to:
  /// **'Attempt limit, 1 to 20'**
  String get quizAttemptLimitFieldText;

  /// No description provided for @quizTimeLimitFieldText.
  ///
  /// In en, this message translates to:
  /// **'Time limit in minutes (optional)'**
  String get quizTimeLimitFieldText;

  /// No description provided for @quizUntimedInfo.
  ///
  /// In en, this message translates to:
  /// **'Untimed and ungraded, unlimited retries. Availability times still apply if set.'**
  String get quizUntimedInfo;

  /// No description provided for @quizFeedbackValue.
  ///
  /// In en, this message translates to:
  /// **'Feedback: {policy}'**
  String quizFeedbackValue(String policy);

  /// No description provided for @quizReleaseValue.
  ///
  /// In en, this message translates to:
  /// **'Release: {time}'**
  String quizReleaseValue(String time);

  /// No description provided for @quizOpeningTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'{time}. Press OK to set opening time. Left clears it.'**
  String quizOpeningTimeLabel(String time);

  /// No description provided for @quizNoOpeningTimeSet.
  ///
  /// In en, this message translates to:
  /// **'No opening time set'**
  String get quizNoOpeningTimeSet;

  /// No description provided for @quizNoOpeningTimeShort.
  ///
  /// In en, this message translates to:
  /// **'No opening time'**
  String get quizNoOpeningTimeShort;

  /// No description provided for @quizOpeningTimeHint.
  ///
  /// In en, this message translates to:
  /// **'Optional · enter year, month, day, hour and minute'**
  String get quizOpeningTimeHint;

  /// No description provided for @quizClosingTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'{time}. Press OK to set closing time. Left clears it.'**
  String quizClosingTimeLabel(String time);

  /// No description provided for @quizNoClosingTimeSet.
  ///
  /// In en, this message translates to:
  /// **'No closing time set'**
  String get quizNoClosingTimeSet;

  /// No description provided for @quizNoClosingTimeShort.
  ///
  /// In en, this message translates to:
  /// **'No closing time'**
  String get quizNoClosingTimeShort;

  /// No description provided for @quizClosingTimeHint.
  ///
  /// In en, this message translates to:
  /// **'Optional · must be after opening time'**
  String get quizClosingTimeHint;

  /// No description provided for @quizShuffleQuestions.
  ///
  /// In en, this message translates to:
  /// **'Shuffle questions once per attempt'**
  String get quizShuffleQuestions;

  /// No description provided for @quizShuffleOptions.
  ///
  /// In en, this message translates to:
  /// **'Shuffle options once per attempt'**
  String get quizShuffleOptions;

  /// No description provided for @messageProblem.
  ///
  /// In en, this message translates to:
  /// **'Problem: {text}'**
  String messageProblem(String text);

  /// No description provided for @messageMessage.
  ///
  /// In en, this message translates to:
  /// **'Message: {text}'**
  String messageMessage(String text);

  /// Administrator dashboard section: student and teacher accounts.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get adminSetupSectionAccounts;

  /// Administrator dashboard section: class and subject catalog.
  ///
  /// In en, this message translates to:
  /// **'Classes and subjects'**
  String get adminSetupSectionCatalog;

  /// Administrator dashboard section: weekly timetable.
  ///
  /// In en, this message translates to:
  /// **'Timetable'**
  String get adminSetupSectionTimetable;

  /// Administrator dashboard section: lessons on one date.
  ///
  /// In en, this message translates to:
  /// **'Today\'s schedule'**
  String get adminSetupSectionSchedule;

  /// Administrator dashboard section: phones shared by several people.
  ///
  /// In en, this message translates to:
  /// **'Shared phones'**
  String get adminSetupSectionSharedPhones;

  /// Administrator dashboard section: school holidays.
  ///
  /// In en, this message translates to:
  /// **'Holidays'**
  String get adminSetupSectionHolidays;

  /// Administrator dashboard section: problems the server noticed.
  ///
  /// In en, this message translates to:
  /// **'Issues'**
  String get adminSetupSectionIssues;

  /// Administrator dashboard section: live and ended classes.
  ///
  /// In en, this message translates to:
  /// **'Class records'**
  String get adminSetupSectionRecords;

  /// Label of the menu that chooses an administrator dashboard section.
  ///
  /// In en, this message translates to:
  /// **'Section'**
  String get adminSetupSectionPicker;

  /// Tooltip of the administrator refresh button.
  ///
  /// In en, this message translates to:
  /// **'Refresh {section}'**
  String adminSetupRefresh(String section);

  /// Tooltip of the administrator log out button.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get adminSetupLogOut;

  /// Spoken label of a loading indicator in the administrator dashboard.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get adminSetupLoading;

  /// Spoken label of the progress indicator while a form is saved.
  ///
  /// In en, this message translates to:
  /// **'Saving'**
  String get adminSetupSaving;

  /// Button that reloads a list that failed to load.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get adminSetupRetry;

  /// Shown when an administrator list fails to load; reason is a full sentence.
  ///
  /// In en, this message translates to:
  /// **'This list could not be loaded. {reason}'**
  String adminSetupLoadFailed(String reason);

  /// Fallback error message in the administrator dashboard.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get adminSetupUnknownError;

  /// Shown when an administrator change fails without a reason from the server.
  ///
  /// In en, this message translates to:
  /// **'The change could not be saved. Refresh and try again.'**
  String get adminSetupNotSaved;

  /// Button that closes an administrator dialog without saving.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get adminSetupCancel;

  /// Button that saves an administrator form.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get adminSetupSave;

  /// Button that closes an administrator dialog.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get adminSetupClose;

  /// Button that deletes an item.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get adminSetupDelete;

  /// Button that removes an item.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get adminSetupRemove;

  /// Short visible label of an edit button.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get adminSetupEdit;

  /// Spoken label of an edit button, naming the item.
  ///
  /// In en, this message translates to:
  /// **'Edit {name}'**
  String adminSetupEditNamed(String name);

  /// Form error when a required field is empty.
  ///
  /// In en, this message translates to:
  /// **'{field} is required.'**
  String adminSetupRequiredField(String field);

  /// Shown for an optional date that has not been chosen.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get adminSetupNoDate;

  /// A date field with its label and value, e.g. "First date: Monday 3 November 2026".
  ///
  /// In en, this message translates to:
  /// **'{field}: {date}'**
  String adminSetupDateValue(String field, String date);

  /// Button that removes the chosen date from a date field.
  ///
  /// In en, this message translates to:
  /// **'Clear {field}'**
  String adminSetupClearDate(String field);

  /// How a date is shown, e.g. "Monday 3 November 2026".
  ///
  /// In en, this message translates to:
  /// **'{weekday} {day} {month} {year}'**
  String adminSetupDateFormat(
    String weekday,
    String day,
    String month,
    String year,
  );

  /// A date followed by a 24-hour time.
  ///
  /// In en, this message translates to:
  /// **'{date}, {time}'**
  String adminSetupDateTime(String date, String time);

  /// Label of a date field.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get adminSetupDateField;

  /// Status shown for a deactivated account, lesson or shared phone.
  ///
  /// In en, this message translates to:
  /// **'Deactivated'**
  String get adminSetupInactive;

  /// Filter choice that shows every item.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get adminSetupFilterAll;

  /// Heading of a filter that chooses which items are listed.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get adminSetupShowFilter;

  /// Account role: student.
  ///
  /// In en, this message translates to:
  /// **'Student'**
  String get adminSetupRoleStudent;

  /// Account role: teacher.
  ///
  /// In en, this message translates to:
  /// **'Teacher'**
  String get adminSetupRoleTeacher;

  /// Button and dialog title for adding a student or teacher.
  ///
  /// In en, this message translates to:
  /// **'Add person'**
  String get adminSetupAddPerson;

  /// Label of the account search field.
  ///
  /// In en, this message translates to:
  /// **'Search by name or phone number'**
  String get adminSetupSearchLabel;

  /// Tooltip of a search button.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get adminSetupSearchButton;

  /// Heading of the student or teacher filter.
  ///
  /// In en, this message translates to:
  /// **'Account type'**
  String get adminSetupAccountTypeHeading;

  /// Heading of the assigned or unassigned filter.
  ///
  /// In en, this message translates to:
  /// **'Class or subject assignment'**
  String get adminSetupAssignmentHeading;

  /// Number of accounts listed.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No matching accounts.} =1{1 account shown.} other{{count} accounts shown.}}'**
  String adminSetupAccountsShown(int count);

  /// Heading above the teacher accounts with their number.
  ///
  /// In en, this message translates to:
  /// **'Teachers ({count})'**
  String adminSetupTeachersHeading(int count);

  /// Heading above the student accounts with their number.
  ///
  /// In en, this message translates to:
  /// **'Students ({count})'**
  String adminSetupStudentsHeading(int count);

  /// Label of a person's name field.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get adminSetupNameField;

  /// Label of a person's phone number field.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get adminSetupPhoneField;

  /// Heading of the student or teacher choice when adding a person.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get adminSetupRoleField;

  /// Heading of a new teacher's class and subject list.
  ///
  /// In en, this message translates to:
  /// **'Classes and subjects this teacher teaches'**
  String get adminSetupTeacherPairsHeading;

  /// Shown when a teacher has no classes and subjects.
  ///
  /// In en, this message translates to:
  /// **'None yet. You can add them later.'**
  String get adminSetupNoPairs;

  /// Label of a class choice.
  ///
  /// In en, this message translates to:
  /// **'Class'**
  String get adminSetupClassField;

  /// Label of a subject choice.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get adminSetupSubjectField;

  /// Button that adds the chosen class and subject to a teacher.
  ///
  /// In en, this message translates to:
  /// **'Add class and subject'**
  String get adminSetupAddPair;

  /// A class and subject pair.
  ///
  /// In en, this message translates to:
  /// **'{className}, {subject}'**
  String adminSetupPairLabel(String className, String subject);

  /// Tooltip of the button removing a class and subject pair from a new teacher.
  ///
  /// In en, this message translates to:
  /// **'Remove {className}, {subject}'**
  String adminSetupRemovePair(String className, String subject);

  /// Shown when a chosen class has no subjects.
  ///
  /// In en, this message translates to:
  /// **'This class has no subjects yet. Add subjects under Classes and subjects.'**
  String get adminSetupNoSubjectsInClass;

  /// Shown when no classes can be chosen.
  ///
  /// In en, this message translates to:
  /// **'There are no active classes yet. Add one under Classes and subjects.'**
  String get adminSetupNoActiveClasses;

  /// Confirmation after adding a person.
  ///
  /// In en, this message translates to:
  /// **'{name} was added.'**
  String adminSetupPersonAdded(String name);

  /// Title of the dialog editing a person's name and phone number.
  ///
  /// In en, this message translates to:
  /// **'Edit {name}'**
  String adminSetupEditPerson(String name);

  /// Helper text under the phone number field when editing a person.
  ///
  /// In en, this message translates to:
  /// **'Changing the phone number signs this person out on every phone.'**
  String get adminSetupPhoneChangeNote;

  /// Confirmation after editing a person.
  ///
  /// In en, this message translates to:
  /// **'Changes to {name} were saved.'**
  String adminSetupPersonSaved(String name);

  /// Button that deactivates an account.
  ///
  /// In en, this message translates to:
  /// **'Deactivate'**
  String get adminSetupDeactivate;

  /// Button that activates an account again.
  ///
  /// In en, this message translates to:
  /// **'Activate'**
  String get adminSetupActivate;

  /// Spoken label of the deactivate button, naming the item.
  ///
  /// In en, this message translates to:
  /// **'Deactivate {name}'**
  String adminSetupDeactivateNamed(String name);

  /// Spoken label of the activate button, naming the item.
  ///
  /// In en, this message translates to:
  /// **'Activate {name}'**
  String adminSetupActivateNamed(String name);

  /// Title of the confirmation before deactivating an account.
  ///
  /// In en, this message translates to:
  /// **'Deactivate {name}?'**
  String adminSetupDeactivateTitle(String name);

  /// Explains what deactivating an account does.
  ///
  /// In en, this message translates to:
  /// **'{name} will be signed out and cannot sign in until the account is activated again.'**
  String adminSetupDeactivateMessage(String name);

  /// Confirmation after activating an account.
  ///
  /// In en, this message translates to:
  /// **'{name} can sign in again.'**
  String adminSetupActivated(String name);

  /// Confirmation after deactivating an account.
  ///
  /// In en, this message translates to:
  /// **'{name} was deactivated.'**
  String adminSetupDeactivated(String name);

  /// Button that ends every sign-in of an account.
  ///
  /// In en, this message translates to:
  /// **'Sign out everywhere'**
  String get adminSetupSignOutEverywhere;

  /// Spoken label of the sign out everywhere button.
  ///
  /// In en, this message translates to:
  /// **'Sign {name} out everywhere'**
  String adminSetupSignOutNamed(String name);

  /// Title of the confirmation before signing a person out everywhere.
  ///
  /// In en, this message translates to:
  /// **'Sign {name} out everywhere?'**
  String adminSetupSignOutTitle(String name);

  /// Explains sign out everywhere.
  ///
  /// In en, this message translates to:
  /// **'This ends {name}\'s sign-in on every phone, for example if someone else used their number. They can sign in again with their phone number.'**
  String adminSetupSignOutMessage(String name);

  /// Confirmation after signing a person out everywhere.
  ///
  /// In en, this message translates to:
  /// **'{name} was signed out everywhere.'**
  String adminSetupSignedOut(String name);

  /// Button that changes a student's class.
  ///
  /// In en, this message translates to:
  /// **'Change class'**
  String get adminSetupStudentClassAction;

  /// Button that manages a teacher's classes and subjects.
  ///
  /// In en, this message translates to:
  /// **'Classes and subjects'**
  String get adminSetupTeacherAssignmentsAction;

  /// Account card detail for a student in a class.
  ///
  /// In en, this message translates to:
  /// **'Student. Class: {className}'**
  String adminSetupStudentDetail(String className);

  /// Account card detail for a student without a class.
  ///
  /// In en, this message translates to:
  /// **'Student. No class yet.'**
  String get adminSetupStudentNoClass;

  /// Account card detail for a teacher; pairs is a list of class and subject pairs.
  ///
  /// In en, this message translates to:
  /// **'Teacher. Teaches: {pairs}'**
  String adminSetupTeacherDetail(String pairs);

  /// Account card detail for a teacher without classes.
  ///
  /// In en, this message translates to:
  /// **'Teacher. No classes or subjects yet.'**
  String get adminSetupTeacherNoPairs;

  /// A person's phone number.
  ///
  /// In en, this message translates to:
  /// **'Phone: {phone}'**
  String adminSetupPhoneDetail(String phone);

  /// Title of the dialog choosing a student's class.
  ///
  /// In en, this message translates to:
  /// **'Class for {name}'**
  String adminSetupClassDialogTitle(String name);

  /// Button that removes a student from their class.
  ///
  /// In en, this message translates to:
  /// **'Remove from {className}'**
  String adminSetupRemoveFromClass(String className);

  /// Confirmation after putting a student in a class.
  ///
  /// In en, this message translates to:
  /// **'{name} is now in {className}.'**
  String adminSetupStudentEnrolled(String name, String className);

  /// Confirmation after removing a student from a class.
  ///
  /// In en, this message translates to:
  /// **'{name} was removed from their class.'**
  String adminSetupStudentRemoved(String name);

  /// Title of the dialog managing a teacher's classes and subjects.
  ///
  /// In en, this message translates to:
  /// **'Classes and subjects for {name}'**
  String adminSetupAssignmentsTitle(String name);

  /// Heading of a teacher's current classes and subjects.
  ///
  /// In en, this message translates to:
  /// **'Currently teaches'**
  String get adminSetupCurrentPairs;

  /// Confirmation after assigning a teacher.
  ///
  /// In en, this message translates to:
  /// **'{name} now teaches {className}, {subject}.'**
  String adminSetupPairAdded(String name, String className, String subject);

  /// Confirmation after removing a teacher assignment.
  ///
  /// In en, this message translates to:
  /// **'{name} no longer teaches {className}, {subject}.'**
  String adminSetupPairRemoved(String name, String className, String subject);

  /// Heading of the class list.
  ///
  /// In en, this message translates to:
  /// **'Classes'**
  String get adminSetupClassesHeading;

  /// Heading of the subject list.
  ///
  /// In en, this message translates to:
  /// **'Subjects'**
  String get adminSetupSubjectsHeading;

  /// Button that creates a class.
  ///
  /// In en, this message translates to:
  /// **'Add class'**
  String get adminSetupAddClass;

  /// Button that creates a subject.
  ///
  /// In en, this message translates to:
  /// **'Add subject'**
  String get adminSetupAddSubject;

  /// Shown when there are no classes.
  ///
  /// In en, this message translates to:
  /// **'No classes yet.'**
  String get adminSetupNoClasses;

  /// Shown when there are no subjects.
  ///
  /// In en, this message translates to:
  /// **'No subjects yet.'**
  String get adminSetupNoSubjects;

  /// Short label of the button choosing a class's subjects.
  ///
  /// In en, this message translates to:
  /// **'Subjects'**
  String get adminSetupSubjectsButton;

  /// Title and spoken label for choosing a class's subjects.
  ///
  /// In en, this message translates to:
  /// **'Subjects in {className}'**
  String adminSetupClassSubjects(String className);

  /// Spoken label of an archive button.
  ///
  /// In en, this message translates to:
  /// **'Archive {name}'**
  String adminSetupArchiveNamed(String name);

  /// Spoken label of a restore button.
  ///
  /// In en, this message translates to:
  /// **'Restore {name}'**
  String adminSetupRestoreNamed(String name);

  /// Shown when no subjects can be added to a class.
  ///
  /// In en, this message translates to:
  /// **'There are no active subjects yet. Add a subject first.'**
  String get adminSetupNoSubjectsToChoose;

  /// Button and dialog title for a new weekly lesson.
  ///
  /// In en, this message translates to:
  /// **'Add lesson to timetable'**
  String get adminSetupAddLesson;

  /// Title of the dialog editing a weekly lesson.
  ///
  /// In en, this message translates to:
  /// **'Edit timetable lesson'**
  String get adminSetupEditLesson;

  /// Timetable filter choice showing every teacher.
  ///
  /// In en, this message translates to:
  /// **'All teachers'**
  String get adminSetupAllTeachers;

  /// Timetable filter choice showing every class.
  ///
  /// In en, this message translates to:
  /// **'All classes'**
  String get adminSetupAllClasses;

  /// Label of a teacher choice.
  ///
  /// In en, this message translates to:
  /// **'Teacher'**
  String get adminSetupTeacherField;

  /// Label of the weekday choice of a lesson.
  ///
  /// In en, this message translates to:
  /// **'Day of the week'**
  String get adminSetupWeekdayField;

  /// Label of a lesson start time field.
  ///
  /// In en, this message translates to:
  /// **'Start time'**
  String get adminSetupStartField;

  /// Label of a lesson end time field.
  ///
  /// In en, this message translates to:
  /// **'End time'**
  String get adminSetupEndField;

  /// Helper text under a time field.
  ///
  /// In en, this message translates to:
  /// **'24-hour India time (IST), for example 09:30'**
  String get adminSetupTimeHelper;

  /// Error when a time field is not a valid time.
  ///
  /// In en, this message translates to:
  /// **'Enter the {field} as 24-hour time, for example 09:30.'**
  String adminSetupTimeInvalid(String field);

  /// Error when a lesson ends before it starts.
  ///
  /// In en, this message translates to:
  /// **'The lesson must end after it starts.'**
  String get adminSetupEndBeforeStart;

  /// Error when the date range of a lesson is reversed.
  ///
  /// In en, this message translates to:
  /// **'The last date must be on or after the first date.'**
  String get adminSetupUntilBeforeFrom;

  /// Optional first date a weekly lesson happens.
  ///
  /// In en, this message translates to:
  /// **'First date'**
  String get adminSetupValidFrom;

  /// Optional last date a weekly lesson happens.
  ///
  /// In en, this message translates to:
  /// **'Last date'**
  String get adminSetupValidUntil;

  /// Label of the choice of a teacher's lesson playlist.
  ///
  /// In en, this message translates to:
  /// **'Lesson playlist (optional)'**
  String get adminSetupLessonField;

  /// Lesson playlist choice meaning none.
  ///
  /// In en, this message translates to:
  /// **'No lesson playlist'**
  String get adminSetupNoLesson;

  /// Shown when a teacher has no lesson playlists to choose.
  ///
  /// In en, this message translates to:
  /// **'This teacher has no lesson playlists for this class and subject yet.'**
  String get adminSetupNoLessonsFound;

  /// Checkbox that also lists deactivated timetable lessons.
  ///
  /// In en, this message translates to:
  /// **'Show deactivated lessons'**
  String get adminSetupShowInactive;

  /// Shown when the timetable list is empty.
  ///
  /// In en, this message translates to:
  /// **'No timetable lessons match.'**
  String get adminSetupNoTimetable;

  /// A lesson with its time, e.g. "09:00 to 09:45: Science, Class 5".
  ///
  /// In en, this message translates to:
  /// **'{start} to {end}: {subject}, {className}'**
  String adminSetupEntryTitle(
    String start,
    String end,
    String subject,
    String className,
  );

  /// The teacher of a lesson or class.
  ///
  /// In en, this message translates to:
  /// **'Teacher: {name}'**
  String adminSetupEntryTeacher(String name);

  /// The lesson playlist chosen for a lesson.
  ///
  /// In en, this message translates to:
  /// **'Lesson playlist: {title}'**
  String adminSetupEntryLesson(String title);

  /// Shown when a lesson has no lesson playlist.
  ///
  /// In en, this message translates to:
  /// **'No lesson playlist chosen.'**
  String get adminSetupEntryNoLesson;

  /// First date of a weekly lesson.
  ///
  /// In en, this message translates to:
  /// **'From {date}'**
  String adminSetupEntryFrom(String date);

  /// Last date of a weekly lesson.
  ///
  /// In en, this message translates to:
  /// **'Until {date}'**
  String adminSetupEntryUntil(String date);

  /// Button that opens the changes to single dates of a lesson.
  ///
  /// In en, this message translates to:
  /// **'Date changes'**
  String get adminSetupDateChanges;

  /// Spoken label of the date changes button.
  ///
  /// In en, this message translates to:
  /// **'Date changes for {title}'**
  String adminSetupDateChangesNamed(String title);

  /// Button that deactivates a timetable lesson.
  ///
  /// In en, this message translates to:
  /// **'Deactivate'**
  String get adminSetupDeactivateLesson;

  /// Button that reactivates a timetable lesson.
  ///
  /// In en, this message translates to:
  /// **'Reactivate'**
  String get adminSetupReactivateLesson;

  /// Title of the confirmation before deactivating a timetable lesson.
  ///
  /// In en, this message translates to:
  /// **'Deactivate this lesson?'**
  String get adminSetupDeactivateLessonTitle;

  /// Explains deactivating a timetable lesson.
  ///
  /// In en, this message translates to:
  /// **'{subject} for {className} on {weekday} at {start} will no longer be scheduled.'**
  String adminSetupDeactivateLessonMessage(
    String subject,
    String className,
    String weekday,
    String start,
  );

  /// Confirmation after saving a timetable lesson.
  ///
  /// In en, this message translates to:
  /// **'Timetable saved.'**
  String get adminSetupLessonSaved;

  /// Confirmation after deactivating a timetable lesson.
  ///
  /// In en, this message translates to:
  /// **'Lesson deactivated.'**
  String get adminSetupLessonDeactivated;

  /// Confirmation after reactivating a timetable lesson.
  ///
  /// In en, this message translates to:
  /// **'Lesson reactivated.'**
  String get adminSetupLessonReactivated;

  /// Shown when editing a lesson, whose class and subject cannot change.
  ///
  /// In en, this message translates to:
  /// **'{className}, {subject}. To change the class or subject, deactivate this lesson and add a new one.'**
  String adminSetupClassSubjectFixed(String className, String subject);

  /// Title of the list of single-date changes of a weekly lesson.
  ///
  /// In en, this message translates to:
  /// **'Date changes: {lesson}, every {weekday}'**
  String adminSetupDateChangesTitle(String lesson, String weekday);

  /// Shown when a lesson has no single-date changes.
  ///
  /// In en, this message translates to:
  /// **'No date changes.'**
  String get adminSetupNoDateChanges;

  /// Button that adds a change for one date of a lesson.
  ///
  /// In en, this message translates to:
  /// **'Change one date'**
  String get adminSetupAddDateChange;

  /// A lesson is cancelled on one date.
  ///
  /// In en, this message translates to:
  /// **'Cancelled on this date.'**
  String get adminSetupCancelledLabel;

  /// A substitute teacher on one date.
  ///
  /// In en, this message translates to:
  /// **'Substitute teacher: {name}'**
  String adminSetupSubstituteLabel(String name);

  /// A different lesson playlist on one date.
  ///
  /// In en, this message translates to:
  /// **'A different lesson playlist is used on this date.'**
  String get adminSetupDifferentLesson;

  /// A note about a date change.
  ///
  /// In en, this message translates to:
  /// **'Note: {note}'**
  String adminSetupNoteLabel(String note);

  /// Button that removes a single-date change.
  ///
  /// In en, this message translates to:
  /// **'Clear change'**
  String get adminSetupClearChange;

  /// Spoken label of the clear change button.
  ///
  /// In en, this message translates to:
  /// **'Clear the change for {date}'**
  String adminSetupClearChangeNamed(String date);

  /// Spoken label of the edit date change button.
  ///
  /// In en, this message translates to:
  /// **'Edit the change for {date}'**
  String adminSetupEditDateChangeNamed(String date);

  /// Confirmation after clearing a date change.
  ///
  /// In en, this message translates to:
  /// **'The change for {date} was cleared.'**
  String adminSetupChangeCleared(String date);

  /// Title of the dialog changing one date of a lesson.
  ///
  /// In en, this message translates to:
  /// **'Change one date: {lesson}'**
  String adminSetupDateChangeTitle(String lesson);

  /// Checkbox that cancels a lesson on one date.
  ///
  /// In en, this message translates to:
  /// **'Cancel the lesson on this date'**
  String get adminSetupCancelOnDate;

  /// Label of the substitute teacher choice.
  ///
  /// In en, this message translates to:
  /// **'Substitute teacher (optional)'**
  String get adminSetupSubstituteField;

  /// Substitute choice meaning the usual teacher teaches.
  ///
  /// In en, this message translates to:
  /// **'No substitute ({name} teaches)'**
  String adminSetupRegularTeacher(String name);

  /// Label of the lesson playlist choice for one date.
  ///
  /// In en, this message translates to:
  /// **'Lesson playlist on this date'**
  String get adminSetupDateLessonField;

  /// Lesson playlist choice meaning no change.
  ///
  /// In en, this message translates to:
  /// **'Same as usual'**
  String get adminSetupUsualLesson;

  /// Label of the note field of a date change.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get adminSetupNoteField;

  /// Confirmation after saving a date change.
  ///
  /// In en, this message translates to:
  /// **'The change for {date} was saved.'**
  String adminSetupDateChangeSaved(String date);

  /// Form error when no date was chosen.
  ///
  /// In en, this message translates to:
  /// **'Choose a date.'**
  String get adminSetupChooseDateFirst;

  /// Button showing the previous day of the schedule.
  ///
  /// In en, this message translates to:
  /// **'Previous day'**
  String get adminSetupPreviousDay;

  /// Button showing the next day of the schedule.
  ///
  /// In en, this message translates to:
  /// **'Next day'**
  String get adminSetupNextDay;

  /// Button showing today's schedule.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get adminSetupToday;

  /// Heading of the schedule for one date.
  ///
  /// In en, this message translates to:
  /// **'Lessons on {date}'**
  String adminSetupScheduleFor(String date);

  /// Shown when a date has no lessons.
  ///
  /// In en, this message translates to:
  /// **'No lessons on this date.'**
  String get adminSetupNoLessonsOnDay;

  /// The substitute teacher of a lesson.
  ///
  /// In en, this message translates to:
  /// **'Teacher: {name} (substitute)'**
  String adminSetupScheduleSubstitute(String name);

  /// State of a scheduled lesson.
  ///
  /// In en, this message translates to:
  /// **'Status: {state}'**
  String adminSetupStateLabel(String state);

  /// Lesson state: not yet started and still to come.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get adminSetupStateUpcoming;

  /// Lesson state: the class is live.
  ///
  /// In en, this message translates to:
  /// **'Live now'**
  String get adminSetupStateLive;

  /// Lesson state: the class took place.
  ///
  /// In en, this message translates to:
  /// **'Held'**
  String get adminSetupStateHeld;

  /// Lesson state: cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get adminSetupStateCancelled;

  /// Lesson state: its time passed and the class never started.
  ///
  /// In en, this message translates to:
  /// **'Not started'**
  String get adminSetupStateNotStarted;

  /// Shown when a lesson has a lesson playlist.
  ///
  /// In en, this message translates to:
  /// **'Lesson playlist ready.'**
  String get adminSetupLessonReady;

  /// Explains shared phones and profile numbers.
  ///
  /// In en, this message translates to:
  /// **'On a shared phone, each person enters the shared phone number, then their short profile number. The profile number only chooses whose account opens. It is not a password.'**
  String get adminSetupSharedPhoneNote;

  /// Button and dialog title for a new shared phone.
  ///
  /// In en, this message translates to:
  /// **'Add shared phone'**
  String get adminSetupAddSharedPhone;

  /// Title of the dialog editing a shared phone.
  ///
  /// In en, this message translates to:
  /// **'Edit shared phone'**
  String get adminSetupEditSharedPhone;

  /// Label of the shared phone name field.
  ///
  /// In en, this message translates to:
  /// **'Name, for example Class 5 phone'**
  String get adminSetupSharedPhoneName;

  /// Label of the shared phone number field.
  ///
  /// In en, this message translates to:
  /// **'Shared phone number'**
  String get adminSetupSharedPhoneNumber;

  /// Switch that activates or deactivates a shared phone.
  ///
  /// In en, this message translates to:
  /// **'Shared phone can be used'**
  String get adminSetupSharedPhoneActiveSwitch;

  /// Confirmation after saving a shared phone.
  ///
  /// In en, this message translates to:
  /// **'Shared phone saved.'**
  String get adminSetupSharedPhoneSaved;

  /// Shown when there are no shared phones.
  ///
  /// In en, this message translates to:
  /// **'No shared phones yet.'**
  String get adminSetupNoSharedPhones;

  /// The number of a shared phone.
  ///
  /// In en, this message translates to:
  /// **'Number: {phone}'**
  String adminSetupGroupNumber(String phone);

  /// A person on a shared phone.
  ///
  /// In en, this message translates to:
  /// **'{name}, {role}. Profile number {code}'**
  String adminSetupMemberLine(String name, String role, String code);

  /// Shown when a shared phone has no people.
  ///
  /// In en, this message translates to:
  /// **'No people on this phone yet.'**
  String get adminSetupNoMembers;

  /// Short label of the button adding a person to a shared phone.
  ///
  /// In en, this message translates to:
  /// **'Add person'**
  String get adminSetupAddMember;

  /// Title and spoken label for adding a person to a shared phone.
  ///
  /// In en, this message translates to:
  /// **'Add a person to {group}'**
  String adminSetupAddMemberTitle(String group);

  /// Label of the person search field.
  ///
  /// In en, this message translates to:
  /// **'Search people by name or phone number'**
  String get adminSetupSearchPeople;

  /// Shown when the person search finds nobody.
  ///
  /// In en, this message translates to:
  /// **'No matching people.'**
  String get adminSetupNoPeopleFound;

  /// Label of the person choice.
  ///
  /// In en, this message translates to:
  /// **'Person'**
  String get adminSetupPersonField;

  /// A person in the person choice.
  ///
  /// In en, this message translates to:
  /// **'{name}, {role}, {phone}'**
  String adminSetupPersonOption(String name, String role, String phone);

  /// Form error when no person was chosen.
  ///
  /// In en, this message translates to:
  /// **'Choose a person.'**
  String get adminSetupChoosePerson;

  /// Label of the profile number field of a shared phone.
  ///
  /// In en, this message translates to:
  /// **'Profile number'**
  String get adminSetupProfileCodeField;

  /// Helper text under the profile number field.
  ///
  /// In en, this message translates to:
  /// **'1 to 4 digits, different for each person on this phone.'**
  String get adminSetupProfileCodeHelper;

  /// Form error for an invalid profile number.
  ///
  /// In en, this message translates to:
  /// **'Enter a profile number of 1 to 4 digits.'**
  String get adminSetupProfileCodeInvalid;

  /// Confirmation after adding a person to a shared phone.
  ///
  /// In en, this message translates to:
  /// **'{name} was added to {group}.'**
  String adminSetupMemberAdded(String name, String group);

  /// Tooltip of the button removing a person from a shared phone.
  ///
  /// In en, this message translates to:
  /// **'Remove {name} from {group}'**
  String adminSetupRemoveMemberNamed(String name, String group);

  /// Title of the confirmation before removing a person from a shared phone.
  ///
  /// In en, this message translates to:
  /// **'Remove {name} from {group}?'**
  String adminSetupRemoveMemberTitle(String name, String group);

  /// Explains removing a person from a shared phone.
  ///
  /// In en, this message translates to:
  /// **'{name} will no longer be able to choose their profile on this shared phone.'**
  String adminSetupRemoveMemberMessage(String name);

  /// Confirmation after removing a person from a shared phone.
  ///
  /// In en, this message translates to:
  /// **'{name} was removed from {group}.'**
  String adminSetupMemberRemoved(String name, String group);

  /// Explains holidays.
  ///
  /// In en, this message translates to:
  /// **'No lessons are scheduled on holidays.'**
  String get adminSetupHolidayNote;

  /// Button and dialog title for a new holiday.
  ///
  /// In en, this message translates to:
  /// **'Add holiday'**
  String get adminSetupAddHoliday;

  /// Label of the holiday name field.
  ///
  /// In en, this message translates to:
  /// **'Holiday name'**
  String get adminSetupHolidayName;

  /// Shown when there are no holidays.
  ///
  /// In en, this message translates to:
  /// **'No holidays yet.'**
  String get adminSetupNoHolidays;

  /// Confirmation after adding a holiday.
  ///
  /// In en, this message translates to:
  /// **'{name} on {date} was added.'**
  String adminSetupHolidayAdded(String name, String date);

  /// Spoken label of the delete holiday button.
  ///
  /// In en, this message translates to:
  /// **'Delete {name} on {date}'**
  String adminSetupDeleteHolidayNamed(String name, String date);

  /// Title of the confirmation before deleting a holiday.
  ///
  /// In en, this message translates to:
  /// **'Delete this holiday?'**
  String get adminSetupDeleteHolidayTitle;

  /// Explains deleting a holiday.
  ///
  /// In en, this message translates to:
  /// **'{name} on {date} will be removed, and lessons will be scheduled on that date again.'**
  String adminSetupDeleteHolidayMessage(String name, String date);

  /// Confirmation after deleting a holiday.
  ///
  /// In en, this message translates to:
  /// **'The holiday was deleted.'**
  String get adminSetupHolidayDeleted;

  /// Issue filter and status: not yet resolved.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get adminSetupIssuesOpen;

  /// Issue filter and status: resolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get adminSetupIssuesResolved;

  /// Shown when there are no issues.
  ///
  /// In en, this message translates to:
  /// **'No issues to show.'**
  String get adminSetupNoIssues;

  /// How often an issue happened and when it was last seen.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Seen once.} other{Seen {count} times.}} Last seen {when}.'**
  String adminSetupIssueSeen(int count, String when);

  /// Button that marks an issue resolved.
  ///
  /// In en, this message translates to:
  /// **'Mark resolved'**
  String get adminSetupMarkResolved;

  /// Spoken label of the mark resolved button.
  ///
  /// In en, this message translates to:
  /// **'Mark resolved: {message}'**
  String adminSetupMarkResolvedNamed(String message);

  /// Confirmation after resolving an issue.
  ///
  /// In en, this message translates to:
  /// **'Issue marked resolved.'**
  String get adminSetupIssueResolved;

  /// Class records filter: live classes.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get adminSetupRecordsLive;

  /// Class records filter and status: ended classes.
  ///
  /// In en, this message translates to:
  /// **'Ended'**
  String get adminSetupRecordsEnded;

  /// Shown when there are no class records.
  ///
  /// In en, this message translates to:
  /// **'No classes to show.'**
  String get adminSetupNoRecords;

  /// Title of a class record.
  ///
  /// In en, this message translates to:
  /// **'{subject}, {className}'**
  String adminSetupRecordTitle(String subject, String className);

  /// Status of a live class.
  ///
  /// In en, this message translates to:
  /// **'Live now'**
  String get adminSetupRecordLive;

  /// Status of a live class with its end time.
  ///
  /// In en, this message translates to:
  /// **'Live now. Ends at {clock}'**
  String adminSetupRecordLiveUntil(String clock);

  /// When a class started.
  ///
  /// In en, this message translates to:
  /// **'Started {when}'**
  String adminSetupRecordStarted(String when);

  /// When a class ended.
  ///
  /// In en, this message translates to:
  /// **'Ended {when}'**
  String adminSetupRecordEnded(String when);

  /// End reason: the teacher.
  ///
  /// In en, this message translates to:
  /// **'The teacher ended the class.'**
  String get adminSetupEndedByTeacher;

  /// End reason: an administrator.
  ///
  /// In en, this message translates to:
  /// **'An administrator ended the class.'**
  String get adminSetupEndedByAdmin;

  /// End reason: automatic.
  ///
  /// In en, this message translates to:
  /// **'The class ended automatically at its end time.'**
  String get adminSetupEndedAutomatically;

  /// Any other end reason, as recorded by the server.
  ///
  /// In en, this message translates to:
  /// **'End reason: {reason}'**
  String adminSetupEndedOther(String reason);

  /// How many students joined a class.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No students joined.} =1{1 student joined.} other{{count} students joined.}}'**
  String adminSetupStudentsJoined(int count);

  /// Extra minutes added to a class.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No extra time added.} =1{1 extra minute added.} other{{count} extra minutes added.}}'**
  String adminSetupExtensionMinutes(int count);

  /// Button that extends a live class.
  ///
  /// In en, this message translates to:
  /// **'Add 15 minutes'**
  String get adminSetupAddFifteen;

  /// Spoken label of the extend button.
  ///
  /// In en, this message translates to:
  /// **'Add 15 minutes to {title}'**
  String adminSetupAddFifteenNamed(String title);

  /// Button that ends a live class.
  ///
  /// In en, this message translates to:
  /// **'End class for everyone'**
  String get adminSetupEndForEveryone;

  /// Spoken label of the end class button.
  ///
  /// In en, this message translates to:
  /// **'End {title} for everyone'**
  String adminSetupEndForEveryoneNamed(String title);

  /// Title of the confirmation before ending a live class.
  ///
  /// In en, this message translates to:
  /// **'End this class for everyone?'**
  String get adminSetupEndTitle;

  /// Explains ending a live class.
  ///
  /// In en, this message translates to:
  /// **'{title} will end now for the teacher and every student.'**
  String adminSetupEndMessage(String title);

  /// Button that cancels ending a class.
  ///
  /// In en, this message translates to:
  /// **'Keep class going'**
  String get adminSetupKeepClass;

  /// Button that confirms ending a class.
  ///
  /// In en, this message translates to:
  /// **'End class'**
  String get adminSetupEndClass;

  /// Confirmation after ending a class.
  ///
  /// In en, this message translates to:
  /// **'The class was ended.'**
  String get adminSetupEnded;

  /// Confirmation after extending a class.
  ///
  /// In en, this message translates to:
  /// **'The class now ends at {clock}.'**
  String adminSetupExtended(String clock);

  /// Title of the sign-in screen for students and teachers.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginScreenName;

  /// Short arrival speech on the sign-in screen.
  ///
  /// In en, this message translates to:
  /// **'Type your phone number, press OK, then press 1 to sign in.'**
  String get loginIntro;

  /// Focus label of the phone number field.
  ///
  /// In en, this message translates to:
  /// **'Phone number. Type it with the number keys.'**
  String get loginPhoneField;

  /// Visible label of the phone number field.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get loginPhoneLabel;

  /// Focus label of the shared-phone profile number field.
  ///
  /// In en, this message translates to:
  /// **'Your profile number on this shared phone'**
  String get loginProfileField;

  /// Visible label of the shared-phone profile number field.
  ///
  /// In en, this message translates to:
  /// **'Profile number'**
  String get loginProfileLabel;

  /// Spoken when the number belongs to a shared phone.
  ///
  /// In en, this message translates to:
  /// **'This phone is shared. Type your profile number, press OK, then press 1.'**
  String get loginEnterProfileCode;

  /// Key 1 on the sign-in screens.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginKeySignIn;

  /// Key 1 after entering a shared-phone profile number.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get loginKeyContinue;

  /// Optional SIM suggestion on the sign-in screen.
  ///
  /// In en, this message translates to:
  /// **'Fill in my number from the SIM card'**
  String get loginKeySim;

  /// Opens the administrator password sign-in.
  ///
  /// In en, this message translates to:
  /// **'Administrator sign in'**
  String get loginKeyAdmin;

  /// Key 0 on the profile number step.
  ///
  /// In en, this message translates to:
  /// **'Use a different number'**
  String get loginKeyChangeNumber;

  /// Sign-in error when the number is missing.
  ///
  /// In en, this message translates to:
  /// **'Type your phone number first.'**
  String get loginErrorEnterPhone;

  /// Sign-in error when the profile number is missing.
  ///
  /// In en, this message translates to:
  /// **'Type your profile number first.'**
  String get loginErrorEnterProfile;

  /// Sign-in error for an unknown number.
  ///
  /// In en, this message translates to:
  /// **'This number is not registered. Ask your school administrator to add you.'**
  String get loginNumberNotRegistered;

  /// Sign-in error for a wrong shared-phone profile number.
  ///
  /// In en, this message translates to:
  /// **'That profile number is not on this phone. Try again.'**
  String get loginProfileNotRecognised;

  /// Sign-in error when an administrator number is typed.
  ///
  /// In en, this message translates to:
  /// **'Administrators sign in with a password. Press 3.'**
  String get loginAdminUsesPassword;

  /// Spoken while sign-in is in progress.
  ///
  /// In en, this message translates to:
  /// **'Signing in.'**
  String get loginSigningIn;

  /// Title of the administrator password screen.
  ///
  /// In en, this message translates to:
  /// **'Administrator sign in'**
  String get adminLoginScreenName;

  /// Short arrival speech on the administrator sign-in screen.
  ///
  /// In en, this message translates to:
  /// **'Type your phone number and password, pressing OK after each, then press 1.'**
  String get adminLoginIntro;

  /// Spoken when a class to open has ended or has not started.
  ///
  /// In en, this message translates to:
  /// **'That class is not live now.'**
  String get classNoLongerLive;

  /// Title of the ringing class alert.
  ///
  /// In en, this message translates to:
  /// **'Class has started'**
  String get classAlertTitle;

  /// Private body text of the ringing class notification.
  ///
  /// In en, this message translates to:
  /// **'Your class has started. Open to join.'**
  String get classAlertBody;

  /// Silent notification left after the ringing stops.
  ///
  /// In en, this message translates to:
  /// **'Your class is live. Open to join.'**
  String get classAlertWaitingBody;

  /// Android notification channel for ringing class alerts.
  ///
  /// In en, this message translates to:
  /// **'Class starting'**
  String get classAlertChannelName;

  /// Android channel description.
  ///
  /// In en, this message translates to:
  /// **'Rings for up to one minute when your class starts.'**
  String get classAlertChannelDescription;

  /// Android channel for the silent class notification.
  ///
  /// In en, this message translates to:
  /// **'Class live'**
  String get classAlertWaitingChannelName;

  /// Android channel description.
  ///
  /// In en, this message translates to:
  /// **'Stays while your class is live so you can join.'**
  String get classAlertWaitingChannelDescription;

  /// Class alert speech without a subject.
  ///
  /// In en, this message translates to:
  /// **'Your class has started.'**
  String get classAlertStarted;

  /// Class alert speech.
  ///
  /// In en, this message translates to:
  /// **'{subject} class has started.'**
  String classAlertSubjectStarted(String subject);

  /// Keys on the in-app class alert.
  ///
  /// In en, this message translates to:
  /// **'Press OK or 1 to join. Press 0 to stop the ringing.'**
  String get classAlertKeys;

  /// Join button on the class alert.
  ///
  /// In en, this message translates to:
  /// **'Join class'**
  String get classAlertJoin;

  /// Dismiss button on the class alert.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get classAlertNotNow;

  /// Title of the student and teacher home screens.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTitle;

  /// Home status while loading.
  ///
  /// In en, this message translates to:
  /// **'Checking for your class.'**
  String get homeChecking;

  /// Home status when offline.
  ///
  /// In en, this message translates to:
  /// **'No internet. Your class will appear when you are back online.'**
  String get homeOffline;

  /// Spoken after the sign-in expired.
  ///
  /// In en, this message translates to:
  /// **'Please sign in again.'**
  String get homeSignInAgain;

  /// Ends the short home arrival speech.
  ///
  /// In en, this message translates to:
  /// **'Press star for all options.'**
  String get homeStarForAll;

  /// Student home when a class is live.
  ///
  /// In en, this message translates to:
  /// **'{subject} class is live. Press 1 to join.'**
  String homeBriefLive(String subject);

  /// Student home before a class.
  ///
  /// In en, this message translates to:
  /// **'Next class: {subject} at {time}. You can use other options while you wait.'**
  String homeBriefNext(String subject, String time);

  /// Student home with no class.
  ///
  /// In en, this message translates to:
  /// **'No class right now. Press 2 to continue learning.'**
  String get homeBriefNoClass;

  /// Key 1 when a class is live.
  ///
  /// In en, this message translates to:
  /// **'Join {subject} class'**
  String homeJoinClass(String subject);

  /// Key 1 when there is no class.
  ///
  /// In en, this message translates to:
  /// **'No class now'**
  String get homeNoClassNow;

  /// Spoken when key 1 has no class.
  ///
  /// In en, this message translates to:
  /// **'Your class will appear here by itself when your teacher starts it.'**
  String get homeNoClassReason;

  /// Key 1 before a class: consent to automatic joining.
  ///
  /// In en, this message translates to:
  /// **'Join {subject} automatically when it starts at {time}'**
  String homeJoinWhenStarts(String subject, String time);

  /// Key 1 after choosing automatic joining.
  ///
  /// In en, this message translates to:
  /// **'Stop joining automatically'**
  String get homeCancelAutoJoin;

  /// Spoken after consenting to automatic joining.
  ///
  /// In en, this message translates to:
  /// **'I will open {subject} when your teacher starts it, if you stay on this screen. You will join muted. Press 1 to cancel.'**
  String homeAutoJoinArmed(String subject);

  /// Spoken after cancelling automatic joining.
  ///
  /// In en, this message translates to:
  /// **'Automatic joining cancelled.'**
  String get homeAutoJoinCancelled;

  /// Spoken when automatic joining ends because another screen opened.
  ///
  /// In en, this message translates to:
  /// **'Automatic joining stopped because you left the home screen.'**
  String get homeAutoJoinLeft;

  /// Spoken when automatic joining opens the class.
  ///
  /// In en, this message translates to:
  /// **'{subject} has started. Joining you now, muted.'**
  String homeAutoJoined(String subject);

  /// Spoken when the app reopens an interrupted class.
  ///
  /// In en, this message translates to:
  /// **'Returning to your class.'**
  String get homeReturningToClass;

  /// Home key 2.
  ///
  /// In en, this message translates to:
  /// **'Continue learning'**
  String get homeContinueLearning;

  /// Spoken when nothing is in progress.
  ///
  /// In en, this message translates to:
  /// **'Nothing to continue yet. Press 3 for learning journeys.'**
  String get homeNothingToContinue;

  /// Spoken when continuing a journey.
  ///
  /// In en, this message translates to:
  /// **'Continuing {title}.'**
  String homeContinuing(String title);

  /// Home key 3.
  ///
  /// In en, this message translates to:
  /// **'Learning journeys'**
  String get homeJourneys;

  /// Home quizzes choice.
  ///
  /// In en, this message translates to:
  /// **'Quizzes'**
  String get homeQuizzes;

  /// Home key 5.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get homeMore;

  /// Arrival speech on the More menu.
  ///
  /// In en, this message translates to:
  /// **'Less used options.'**
  String get homeMoreBrief;

  /// Home details.
  ///
  /// In en, this message translates to:
  /// **'Your class: {className}.'**
  String homeYourClass(String className);

  /// A subject taught in a class.
  ///
  /// In en, this message translates to:
  /// **'{subject}, {className}'**
  String homeSubjectInClass(String subject, String className);

  /// Teacher home with a live class.
  ///
  /// In en, this message translates to:
  /// **'Your {subject} class is live. Press 1 to return to it.'**
  String teacherHomeBriefLive(String subject);

  /// Teacher home when a class can start.
  ///
  /// In en, this message translates to:
  /// **'{place} is ready. Press 1 to start it.'**
  String teacherHomeBriefReady(String place);

  /// Teacher home before a class.
  ///
  /// In en, this message translates to:
  /// **'Next class: {place} at {time}.'**
  String teacherHomeBriefNext(String place, String time);

  /// Teacher home with no class.
  ///
  /// In en, this message translates to:
  /// **'No class on your timetable now.'**
  String get teacherHomeBriefNoClass;

  /// Teacher key 1 with a live class.
  ///
  /// In en, this message translates to:
  /// **'Return to {subject} class'**
  String teacherHomeReturn(String subject);

  /// Teacher key 1 when a class can start.
  ///
  /// In en, this message translates to:
  /// **'Start {place}'**
  String teacherHomeStart(String place);

  /// Teacher key 1 before a class can start.
  ///
  /// In en, this message translates to:
  /// **'Next: {place} at {time}'**
  String teacherHomeNext(String place, String time);

  /// Spoken when a class cannot start yet.
  ///
  /// In en, this message translates to:
  /// **'You can start it from {time}.'**
  String teacherHomeOpensAt(String time);

  /// Spoken when key 1 has no class.
  ///
  /// In en, this message translates to:
  /// **'Nothing is scheduled now. To teach anyway, press 5 for More, then 3.'**
  String get teacherHomeNoClassReason;

  /// Spoken while starting.
  ///
  /// In en, this message translates to:
  /// **'Starting your class.'**
  String get teacherHomeStarting;

  /// Spoken on entering a newly started class.
  ///
  /// In en, this message translates to:
  /// **'{subject} class started. Your students are being called.'**
  String teacherHomeStarted(String subject);

  /// More menu choice for teachers.
  ///
  /// In en, this message translates to:
  /// **'Start an unscheduled class'**
  String get teacherHomeUnscheduled;

  /// Picker title for an unscheduled class.
  ///
  /// In en, this message translates to:
  /// **'Which class do you want to teach now?'**
  String get teacherHomeUnscheduledTitle;

  /// Why an unscheduled class cannot start.
  ///
  /// In en, this message translates to:
  /// **'You already have a live class. Press 1 on Home to return to it.'**
  String get teacherHomeAlreadyLive;

  /// More menu choice for teachers.
  ///
  /// In en, this message translates to:
  /// **'Change class and subject for lessons'**
  String get teacherHomeChangeWorkspace;

  /// Why the class cannot be changed.
  ///
  /// In en, this message translates to:
  /// **'You teach one class and subject.'**
  String get teacherHomeOneWorkspace;

  /// Teacher home details.
  ///
  /// In en, this message translates to:
  /// **'Lessons, quizzes and playlists are for {place}.'**
  String teacherHomeContentFor(String place);

  /// Teacher home details for later classes.
  ///
  /// In en, this message translates to:
  /// **'Later: {place} at {time}.'**
  String teacherHomeLaterItem(String place, String time);

  /// Teacher key 7 in class.
  ///
  /// In en, this message translates to:
  /// **'Class list: who is here, who left, who has not joined'**
  String get keyClassListWhoJoined;

  /// Teacher key 8 in class.
  ///
  /// In en, this message translates to:
  /// **'Mute all students'**
  String get keyMuteAllStudents;

  /// Teacher key 9 in class.
  ///
  /// In en, this message translates to:
  /// **'Teacher tools: add time or end the class for everyone'**
  String get keyTeacherToolsAddTimeOrEnd;

  /// Spoken before the first microphone request.
  ///
  /// In en, this message translates to:
  /// **'You join muted. SEEDS will now ask to use the microphone, so you can speak when you choose.'**
  String get sessionMicAskOnce;

  /// Spoken before asking again on Unmute.
  ///
  /// In en, this message translates to:
  /// **'To speak, allow the microphone.'**
  String get sessionMicAskAgain;

  /// Spoken when microphone access was refused.
  ///
  /// In en, this message translates to:
  /// **'The microphone is still off. You can keep listening.'**
  String get sessionMicStillOff;

  /// Dialog title when Android will not ask again.
  ///
  /// In en, this message translates to:
  /// **'Microphone is blocked'**
  String get sessionMicSettingsTitle;

  /// Dialog message.
  ///
  /// In en, this message translates to:
  /// **'Android will not ask again. To speak, open Settings, choose Permissions, and allow the microphone. You can keep listening.'**
  String get sessionMicSettingsMessage;

  /// Dialog confirm.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get sessionMicSettingsOpen;

  /// Dialog cancel.
  ///
  /// In en, this message translates to:
  /// **'Keep listening'**
  String get sessionMicSettingsCancel;

  /// Teacher key 8 button.
  ///
  /// In en, this message translates to:
  /// **'2: Mute all students'**
  String get sessionMuteAllButton;

  /// Teacher key 8 focus label.
  ///
  /// In en, this message translates to:
  /// **'Mute all students'**
  String get sessionMuteAllLabel;

  /// Spoken while mute all is pending.
  ///
  /// In en, this message translates to:
  /// **'Still muting everyone. Please wait.'**
  String get sessionMuteAllWaiting;

  /// Spoken after mute all.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 student muted.} other{{count} students muted.}}'**
  String sessionMuteAllDone(int count);

  /// Spoken when nobody needed muting.
  ///
  /// In en, this message translates to:
  /// **'Every student was already muted.'**
  String get sessionMuteAllNone;

  /// Spoken when mute all failed.
  ///
  /// In en, this message translates to:
  /// **'Muting everyone was not confirmed. {reason} Press 2 to try again.'**
  String sessionMuteAllNotConfirmed(String reason);

  /// Teacher key 7 button.
  ///
  /// In en, this message translates to:
  /// **'3: Class list'**
  String get sessionClassListButton;

  /// Teacher key 7 focus label.
  ///
  /// In en, this message translates to:
  /// **'Class list. {people}'**
  String sessionClassListLabel(String people);

  /// Class list screen title.
  ///
  /// In en, this message translates to:
  /// **'Class list'**
  String get sessionClassListTitle;

  /// Class list counts.
  ///
  /// In en, this message translates to:
  /// **'{here} here, {left} left, {notJoined} not joined yet.'**
  String sessionRosterCounts(int here, int left, int notJoined);

  /// Class list key 1.
  ///
  /// In en, this message translates to:
  /// **'Here now: {count}'**
  String sessionHereNow(int count);

  /// Class list key 2.
  ///
  /// In en, this message translates to:
  /// **'Joined, then left: {count}'**
  String sessionLeftClass(int count);

  /// Class list key 3.
  ///
  /// In en, this message translates to:
  /// **'Not joined yet: {count}'**
  String sessionNotJoined(int count);

  /// List title.
  ///
  /// In en, this message translates to:
  /// **'Here now'**
  String get sessionHereNowTitle;

  /// List title.
  ///
  /// In en, this message translates to:
  /// **'Joined, then left'**
  String get sessionLeftClassTitle;

  /// List title.
  ///
  /// In en, this message translates to:
  /// **'Not joined yet'**
  String get sessionNotJoinedTitle;

  /// A removed student in the class list.
  ///
  /// In en, this message translates to:
  /// **'{name}, removed by you'**
  String sessionRemovedName(String name);

  /// Spoken for an empty list.
  ///
  /// In en, this message translates to:
  /// **'Nobody.'**
  String get sessionNobody;

  /// Class list key 4.
  ///
  /// In en, this message translates to:
  /// **'Ring students who have not joined'**
  String get sessionRemindNotJoined;

  /// Why there is nobody to remind.
  ///
  /// In en, this message translates to:
  /// **'Everyone has joined.'**
  String get sessionEveryoneJoined;

  /// Spoken after a reminder.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Nobody to ring now.} =1{Ringing 1 student.} other{Ringing {count} students.}}'**
  String sessionReminderSent(int count);

  /// Spoken when some students are in the 5-minute pause.
  ///
  /// In en, this message translates to:
  /// **'Ringing {queued}. {cooling} were rung in the last 5 minutes and will not be rung again yet.'**
  String sessionReminderSentSomeWaiting(int queued, int cooling);

  /// Spoken when the roster failed.
  ///
  /// In en, this message translates to:
  /// **'The class list could not be read. Try again.'**
  String get sessionRosterUnavailable;

  /// Teacher tools key 1.
  ///
  /// In en, this message translates to:
  /// **'Add 15 minutes'**
  String get sessionAddTime;

  /// Why time cannot be added.
  ///
  /// In en, this message translates to:
  /// **'No more time can be added before the next class.'**
  String get sessionCannotAddTime;

  /// Class end time.
  ///
  /// In en, this message translates to:
  /// **'Class ends by {clock}.'**
  String sessionEndsBy(String clock);

  /// Spoken after adding time.
  ///
  /// In en, this message translates to:
  /// **'Done. The class now ends by {clock}.'**
  String sessionExtendedUntil(String clock);

  /// Warning for teachers when no time can be added.
  ///
  /// In en, this message translates to:
  /// **'{minutes, plural, =1{The class ends automatically in 1 minute.} other{The class ends automatically in {minutes} minutes.}}'**
  String sessionEndingSoonTeacher(int minutes);

  /// Warning for teachers.
  ///
  /// In en, this message translates to:
  /// **'{minutes, plural, =1{The class ends automatically in 1 minute. To add 15 minutes, press 5 then 1.} other{The class ends automatically in {minutes} minutes. To add 15 minutes, press 5 then 1.}}'**
  String sessionEndingSoonTeacherExtend(int minutes);

  /// Warning for students.
  ///
  /// In en, this message translates to:
  /// **'{minutes, plural, =1{The class ends in 1 minute.} other{The class ends in {minutes} minutes.}}'**
  String sessionEndingSoonStudent(int minutes);

  /// Spoken when a prepared lesson is selected.
  ///
  /// In en, this message translates to:
  /// **'Today\'s lesson is ready. Press 4, then 3, to play it for the class.'**
  String get sessionLessonReady;

  /// Spoken when the next lesson part is selected.
  ///
  /// In en, this message translates to:
  /// **'The next part of today\'s lesson is ready. Press 7 to play it.'**
  String get sessionLessonNextReady;

  /// Short speech on joining a class as a student.
  ///
  /// In en, this message translates to:
  /// **'You are in class and muted. Press 1 to speak, 2 to raise your hand.'**
  String get sessionJoinedStudentBrief;

  /// Short speech on entering a class as a teacher.
  ///
  /// In en, this message translates to:
  /// **'Your class is live. You are muted. Press 1 to speak, 2 to mute all students.'**
  String get sessionJoinedTeacherBrief;

  /// Ends short class speech.
  ///
  /// In en, this message translates to:
  /// **'Press star for all keys.'**
  String get sessionStarForKeys;

  /// Settings toggle for automatic offline preparation.
  ///
  /// In en, this message translates to:
  /// **'Prepare new journeys for offline use on Wi-Fi: {state}'**
  String settingsAutoDownload(String state);

  /// Spoken when the setting is turned on.
  ///
  /// In en, this message translates to:
  /// **'Journeys will be prepared on Wi-Fi.'**
  String get settingsAutoDownloadOn;

  /// Spoken when the setting is turned off.
  ///
  /// In en, this message translates to:
  /// **'Journeys will not be prepared automatically.'**
  String get settingsAutoDownloadOff;

  /// Admin add person: teacher saved without a class and subject
  ///
  /// In en, this message translates to:
  /// **'Add at least one class and subject for the teacher.'**
  String get adminSetupTeacherNeedsPair;

  /// Admin timetable: no teacher can be scheduled yet
  ///
  /// In en, this message translates to:
  /// **'No teacher has a class and subject yet. Add them to a teacher in People first.'**
  String get adminSetupTeacherHasNoPairs;

  /// Admin timetable: heading above the weekday choices
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get adminSetupDaysField;

  /// Admin timetable: no weekday chosen
  ///
  /// In en, this message translates to:
  /// **'Choose at least one day.'**
  String get adminSetupChooseDays;

  /// Admin timetable: lessons created
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Lesson added.} other{{count} lessons added, one for each day.}}'**
  String adminSetupLessonsAdded(int count);

  /// Admin timetable: heading of the grouping choice
  ///
  /// In en, this message translates to:
  /// **'Arrange by'**
  String get adminSetupArrangeBy;

  /// Admin timetable: group lessons by weekday
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get adminSetupArrangeDay;

  /// Admin timetable: group lessons by teacher
  ///
  /// In en, this message translates to:
  /// **'Teacher'**
  String get adminSetupArrangeTeacher;

  /// Admin timetable: group lessons by class
  ///
  /// In en, this message translates to:
  /// **'Class'**
  String get adminSetupArrangeClass;

  /// Admin timetable: group heading with lesson count
  ///
  /// In en, this message translates to:
  /// **'{name} · {count, plural, =1{1 lesson} other{{count} lessons}}'**
  String adminSetupGroupHeading(String name, int count);

  /// Admin timetable: lesson title with its weekday
  ///
  /// In en, this message translates to:
  /// **'{day}, {title}'**
  String adminSetupEntryDayTitle(String day, String title);

  /// Admin timetable: text filter over teacher, class and subject
  ///
  /// In en, this message translates to:
  /// **'Search lessons'**
  String get adminSetupTimetableSearch;

  /// Admin timetable: search found nothing
  ///
  /// In en, this message translates to:
  /// **'No lessons match.'**
  String get adminSetupNoMatchingLessons;

  /// No description provided for @sessionMoreButton.
  ///
  /// In en, this message translates to:
  /// **'{key}: More'**
  String sessionMoreButton(String key);

  /// Live class: spoken name of the More button
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get sessionMoreLabel;

  /// Live class: title of the More screen
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get sessionMoreTitle;

  /// Live class More: teacher starts or closes a classroom check
  ///
  /// In en, this message translates to:
  /// **'Classroom check'**
  String get sessionMoreClassroomCheck;

  /// Live class More: student hears the lesson recording status
  ///
  /// In en, this message translates to:
  /// **'What is playing'**
  String get sessionMoreWhatIsPlaying;

  /// Live class More: student hears who is in class
  ///
  /// In en, this message translates to:
  /// **'Who is in class'**
  String get sessionMoreWhoIsHere;

  /// Live class key help, teacher key 4
  ///
  /// In en, this message translates to:
  /// **'Class list'**
  String get sessionKeyClassList;

  /// Live class key help, teacher key 5
  ///
  /// In en, this message translates to:
  /// **'Lesson recording'**
  String get sessionKeyLessonRecording;

  /// Live class key help, student key 3 while a check is open
  ///
  /// In en, this message translates to:
  /// **'Answer the question'**
  String get sessionKeyAnswerQuestion;

  /// Live class key help, key 9
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get sessionKeyMore;

  /// Live class key help, key 0
  ///
  /// In en, this message translates to:
  /// **'Leave class'**
  String get sessionKeyLeave;

  /// Teacher class screen key 6
  ///
  /// In en, this message translates to:
  /// **'6: End class for everyone'**
  String get sessionEndClassButton;

  /// Teacher class screen key 6, spoken
  ///
  /// In en, this message translates to:
  /// **'End class for everyone. Asks to confirm'**
  String get sessionEndClassLabel;

  /// Teacher list item
  ///
  /// In en, this message translates to:
  /// **'Quiz: {title}, {count, plural, =1{1 question} other{{count} questions}}'**
  String sessionActivityQuizItem(String title, int count);

  /// Teacher list item
  ///
  /// In en, this message translates to:
  /// **'Journey: {title}'**
  String sessionActivityJourneyItem(String title);

  /// Teacher list item that stops the running one
  ///
  /// In en, this message translates to:
  /// **'Stop offering {title}'**
  String sessionActivityStopItem(String title);

  /// Teacher confirmation
  ///
  /// In en, this message translates to:
  /// **'{title} is open for the class. Press 7 for its status.'**
  String sessionActivityStartedTeacher(String title);

  /// Teacher confirmation
  ///
  /// In en, this message translates to:
  /// **'{title} is no longer offered in class. Students can still find it on Home.'**
  String sessionActivityStoppedTeacher(String title);

  /// Student announcement
  ///
  /// In en, this message translates to:
  /// **'Your teacher assigned a quiz: {title}. Press 5 to start it.'**
  String sessionActivityQuizStarted(String title);

  /// Student announcement
  ///
  /// In en, this message translates to:
  /// **'Your teacher assigned a learning journey: {title}. Press 5 to start it.'**
  String sessionActivityJourneyStarted(String title);

  /// Student announcement
  ///
  /// In en, this message translates to:
  /// **'{title} is closed in class. You can still find it on Home.'**
  String sessionActivityStoppedStudent(String title);

  /// Student key 3 spoken
  ///
  /// In en, this message translates to:
  /// **'Start the quiz {title}'**
  String sessionActivityStartQuizLabel(String title);

  /// Student key 3 spoken
  ///
  /// In en, this message translates to:
  /// **'Start the journey {title}'**
  String sessionActivityStartJourneyLabel(String title);

  /// Student class status
  ///
  /// In en, this message translates to:
  /// **'{title} is open.'**
  String sessionActivityStateStudent(String title);

  /// Teacher class status
  ///
  /// In en, this message translates to:
  /// **'{title} is open for the class.'**
  String sessionActivityStateTeacher(String title);

  /// Student opening the activity
  ///
  /// In en, this message translates to:
  /// **'Opening {title}.'**
  String sessionActivityOpening(String title);

  /// Student activity failed to open
  ///
  /// In en, this message translates to:
  /// **'{title} could not be opened. Check your connection and try again.'**
  String sessionActivityCouldNotOpen(String title);

  /// Student returns to the class screen
  ///
  /// In en, this message translates to:
  /// **'Back in class.'**
  String get sessionBackInClass;

  /// Teacher class list progress
  ///
  /// In en, this message translates to:
  /// **'{title}: {started} started, {finished} finished.'**
  String sessionActivityProgress(String title, int started, int finished);

  /// Student class screen key 4
  ///
  /// In en, this message translates to:
  /// **'3: What is playing'**
  String get sessionWhatIsPlayingButton;

  /// Key help, teacher key 6
  ///
  /// In en, this message translates to:
  /// **'End class for everyone'**
  String get sessionKeyEndClass;

  /// Key help, student key 4
  ///
  /// In en, this message translates to:
  /// **'What is playing'**
  String get sessionKeyWhatIsPlaying;

  /// Teacher class screen key 6
  ///
  /// In en, this message translates to:
  /// **'6: Quiz'**
  String get sessionQuizButton;

  /// Teacher class screen key 7
  ///
  /// In en, this message translates to:
  /// **'7: Journey'**
  String get sessionJourneyButton;

  /// Teacher key 6 spoken, no quiz open
  ///
  /// In en, this message translates to:
  /// **'Start a quiz for the class'**
  String get sessionQuizLabel;

  /// Teacher key 7 spoken, no journey open
  ///
  /// In en, this message translates to:
  /// **'Start a journey for the class'**
  String get sessionJourneyLabel;

  /// Teacher key 6 or 7 spoken while it is open
  ///
  /// In en, this message translates to:
  /// **'{title} is open. Hear who is left, remind them, or stop it'**
  String sessionOpenLabel(String title);

  /// Key help, teacher key 6
  ///
  /// In en, this message translates to:
  /// **'Quiz for the class'**
  String get sessionKeyQuiz;

  /// Key help, teacher key 7
  ///
  /// In en, this message translates to:
  /// **'Journey for the class'**
  String get sessionKeyJourney;

  /// Student key 6 while a quiz is open
  ///
  /// In en, this message translates to:
  /// **'5: Start quiz: {title}'**
  String sessionStartQuizButton(String title);

  /// Student key 7 while a journey is open
  ///
  /// In en, this message translates to:
  /// **'5: Start journey: {title}'**
  String sessionStartJourneyButton(String title);

  /// Teacher list of quizzes
  ///
  /// In en, this message translates to:
  /// **'Start a quiz for the class'**
  String get sessionPickQuizTitle;

  /// Teacher list of journeys
  ///
  /// In en, this message translates to:
  /// **'Start a journey for the class'**
  String get sessionPickJourneyTitle;

  /// Teacher key 6, nothing to start
  ///
  /// In en, this message translates to:
  /// **'No published quiz is open for this class and subject. Publish one from Quizzes on Home first.'**
  String get sessionNoQuizToStart;

  /// Teacher key 7, nothing to start
  ///
  /// In en, this message translates to:
  /// **'No published journey for this class and subject. Publish one from Journeys on Home first.'**
  String get sessionNoJourneyToStart;

  /// Teacher quiz or journey menu status
  ///
  /// In en, this message translates to:
  /// **'{finished} of {enrolled} finished.'**
  String sessionFinishedOf(int finished, int enrolled);

  /// Teacher menu choice
  ///
  /// In en, this message translates to:
  /// **'In class, not done ({count})'**
  String sessionLeftInClass(int count);

  /// Teacher menu choice
  ///
  /// In en, this message translates to:
  /// **'Whole class, not done ({count})'**
  String sessionLeftWholeClass(int count);

  /// List title
  ///
  /// In en, this message translates to:
  /// **'In class, not done'**
  String get sessionLeftInClassTitle;

  /// List title
  ///
  /// In en, this message translates to:
  /// **'Whole class, not done'**
  String get sessionLeftWholeClassTitle;

  /// Teacher menu choice
  ///
  /// In en, this message translates to:
  /// **'Remind those in class who are not done'**
  String get sessionRemindLeft;

  /// Teacher menu choice
  ///
  /// In en, this message translates to:
  /// **'Start a different quiz'**
  String get sessionStartDifferentQuiz;

  /// Teacher menu choice
  ///
  /// In en, this message translates to:
  /// **'Start a different journey'**
  String get sessionStartDifferentJourney;

  /// Who is left: one student
  ///
  /// In en, this message translates to:
  /// **'{name}, not started'**
  String sessionLeftNotStarted(String name);

  /// Who is left: one student
  ///
  /// In en, this message translates to:
  /// **'{name}, started, not finished'**
  String sessionLeftStarted(String name);

  /// Who is left, whole class: present
  ///
  /// In en, this message translates to:
  /// **'in class'**
  String get sessionLeftHere;

  /// Who is left, whole class: absent
  ///
  /// In en, this message translates to:
  /// **'not in class'**
  String get sessionLeftAway;

  /// Who is left: nobody in class
  ///
  /// In en, this message translates to:
  /// **'Everyone in class has finished.'**
  String get sessionLeftNobodyInClass;

  /// Who is left: nobody
  ///
  /// In en, this message translates to:
  /// **'Everyone in the class has finished.'**
  String get sessionLeftNobody;

  /// Teacher reminder result
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Nobody in class needs a reminder.} =1{Reminded 1 student.} other{Reminded {count} students.}}'**
  String sessionRemindedLeft(int count);

  /// Student reminder
  ///
  /// In en, this message translates to:
  /// **'Your teacher reminds you to do the quiz {title}. Press 5 to start it.'**
  String sessionActivityReminderQuiz(String title);

  /// Student reminder
  ///
  /// In en, this message translates to:
  /// **'Your teacher reminds you to do the learning journey {title}. Press 5 to start it.'**
  String sessionActivityReminderJourney(String title);

  /// Key help, student key 4 while a quiz or journey is open
  ///
  /// In en, this message translates to:
  /// **'Start the quiz or journey'**
  String get sessionKeyStartActivity;

  /// Key label
  ///
  /// In en, this message translates to:
  /// **'2. Settings'**
  String get startupSettingsKey2;

  /// Key label
  ///
  /// In en, this message translates to:
  /// **'Pause audio for the whole session, key 3'**
  String get libraryPauseSessionKey3;

  /// 4 is the keypad key.
  ///
  /// In en, this message translates to:
  /// **'1: Save new password'**
  String get authSaveNewPasswordKey1;

  /// Visible button with its key
  ///
  /// In en, this message translates to:
  /// **'1: Save settings'**
  String get quizSaveSettingsKey1;

  /// Visible button with its key
  ///
  /// In en, this message translates to:
  /// **'1: Save question'**
  String get quizSaveQuestionKey1;

  /// Visible button with its key
  ///
  /// In en, this message translates to:
  /// **'1: Continue to questions'**
  String get quizContinueToQuestionsKey1;

  /// Administrator dashboard section where quizzes and learning journeys are made on a teacher's behalf.
  ///
  /// In en, this message translates to:
  /// **'Quizzes and journeys'**
  String get adminAuthorSection;

  /// Explanation at the top of the quizzes and journeys section.
  ///
  /// In en, this message translates to:
  /// **'Create and publish quizzes and learning journeys for a teacher. Everything you make belongs to that teacher, uses only their question bank and their own recordings, and the teacher is told about it on their Home.'**
  String get adminAuthorNote;

  /// Label of the dropdown choosing the teacher to work for.
  ///
  /// In en, this message translates to:
  /// **'Teacher'**
  String get adminAuthorTeacher;

  /// Label of the dropdown choosing one of the teacher's assigned class and subject pairs.
  ///
  /// In en, this message translates to:
  /// **'Class and subject'**
  String get adminAuthorWorkspace;

  /// One class and subject pair in the dropdown, e.g. 'Class 5, Science'.
  ///
  /// In en, this message translates to:
  /// **'{className}, {subjectName}'**
  String adminAuthorWorkspaceName(String className, String subjectName);

  /// Shown when no active teacher has an assigned class and subject.
  ///
  /// In en, this message translates to:
  /// **'No teacher has a class and subject yet. Assign one in Accounts first.'**
  String get adminAuthorNoTeachers;

  /// Heading of the choice between quizzes and journeys.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get adminAuthorKind;

  /// Choice that lists the teacher's quizzes.
  ///
  /// In en, this message translates to:
  /// **'Quizzes'**
  String get adminAuthorKindQuizzes;

  /// Choice that lists the teacher's learning journeys.
  ///
  /// In en, this message translates to:
  /// **'Journeys'**
  String get adminAuthorKindJourneys;

  /// Button that starts a new quiz for the chosen teacher.
  ///
  /// In en, this message translates to:
  /// **'New quiz'**
  String get adminAuthorNewQuiz;

  /// Button that starts a new learning journey for the chosen teacher.
  ///
  /// In en, this message translates to:
  /// **'New journey'**
  String get adminAuthorNewJourney;

  /// Title of the dialog creating a quiz for a teacher.
  ///
  /// In en, this message translates to:
  /// **'New quiz for {teacher}'**
  String adminAuthorNewQuizFor(String teacher);

  /// Title of the dialog creating a journey for a teacher.
  ///
  /// In en, this message translates to:
  /// **'New journey for {teacher}'**
  String adminAuthorNewJourneyFor(String teacher);

  /// Empty quiz list.
  ///
  /// In en, this message translates to:
  /// **'This teacher has no quizzes for this class and subject.'**
  String get adminAuthorNoQuizzes;

  /// Empty journey list.
  ///
  /// In en, this message translates to:
  /// **'This teacher has no journeys for this class and subject.'**
  String get adminAuthorNoJourneys;

  /// Status of an unpublished quiz or journey.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get adminAuthorStatusDraft;

  /// Status of a published quiz or journey.
  ///
  /// In en, this message translates to:
  /// **'Published'**
  String get adminAuthorStatusPublished;

  /// Status of a published quiz whose opening time is in the future.
  ///
  /// In en, this message translates to:
  /// **'Published, opens later'**
  String get adminAuthorStatusScheduled;

  /// Status of a closed quiz.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get adminAuthorStatusClosed;

  /// Status of an archived journey.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get adminAuthorStatusArchived;

  /// Status of a journey edited since it was published.
  ///
  /// In en, this message translates to:
  /// **'{status}, with unpublished changes'**
  String adminAuthorStatusChanged(String status);

  /// Number of questions in a quiz or journey.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 question} other{{count} questions}}'**
  String adminAuthorQuestionCount(int count);

  /// Number of steps in a journey.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 step} other{{count} steps}}'**
  String adminAuthorStepCount(int count);

  /// Heading of the graded or practice choice.
  ///
  /// In en, this message translates to:
  /// **'Quiz type'**
  String get adminAuthorMode;

  /// A quiz that is scored.
  ///
  /// In en, this message translates to:
  /// **'Graded'**
  String get adminAuthorModeGraded;

  /// A practice quiz with immediate feedback.
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get adminAuthorModePractice;

  /// Short button text to edit a quiz or journey.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get adminAuthorEdit;

  /// Spoken label of the Edit button.
  ///
  /// In en, this message translates to:
  /// **'Edit {title}'**
  String adminAuthorEditNamed(String title);

  /// Short button text to publish a quiz or journey.
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get adminAuthorPublish;

  /// Spoken label of the Publish button.
  ///
  /// In en, this message translates to:
  /// **'Publish {title}'**
  String adminAuthorPublishNamed(String title);

  /// Button that closes a published quiz.
  ///
  /// In en, this message translates to:
  /// **'Close quiz'**
  String get adminAuthorClose;

  /// Spoken label of the Close quiz button.
  ///
  /// In en, this message translates to:
  /// **'Close {title}'**
  String adminAuthorCloseNamed(String title);

  /// Button that archives a published journey.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get adminAuthorArchive;

  /// Spoken label of the Archive button.
  ///
  /// In en, this message translates to:
  /// **'Archive {title}'**
  String adminAuthorArchiveNamed(String title);

  /// Confirmation title before publishing a quiz.
  ///
  /// In en, this message translates to:
  /// **'Publish this quiz?'**
  String get adminAuthorPublishQuizTitle;

  /// Confirmation message before publishing a quiz for a teacher.
  ///
  /// In en, this message translates to:
  /// **'{title} will open to the class as {teacher}\'s quiz, and the students will be notified.'**
  String adminAuthorPublishQuizMessage(String title, String teacher);

  /// Confirmation title before publishing a journey.
  ///
  /// In en, this message translates to:
  /// **'Publish this journey?'**
  String get adminAuthorPublishJourneyTitle;

  /// Confirmation message before publishing a journey for a teacher.
  ///
  /// In en, this message translates to:
  /// **'{title} will be available to the class as {teacher}\'s journey, and the students will be notified.'**
  String adminAuthorPublishJourneyMessage(String title, String teacher);

  /// Confirmation title before closing a quiz.
  ///
  /// In en, this message translates to:
  /// **'Close this quiz?'**
  String get adminAuthorCloseQuizTitle;

  /// Confirmation message before closing a quiz.
  ///
  /// In en, this message translates to:
  /// **'Students can no longer answer {title}. Unfinished attempts are submitted as they are.'**
  String adminAuthorCloseQuizMessage(String title);

  /// Confirmation title before archiving a journey.
  ///
  /// In en, this message translates to:
  /// **'Archive this journey?'**
  String get adminAuthorArchiveTitle;

  /// Confirmation message before archiving a journey.
  ///
  /// In en, this message translates to:
  /// **'Students will no longer see {title}.'**
  String adminAuthorArchiveMessage(String title);

  /// Shown after publishing.
  ///
  /// In en, this message translates to:
  /// **'{title} published.'**
  String adminAuthorPublished(String title);

  /// Shown after closing a quiz.
  ///
  /// In en, this message translates to:
  /// **'{title} closed.'**
  String adminAuthorClosed(String title);

  /// Shown after archiving a journey.
  ///
  /// In en, this message translates to:
  /// **'{title} archived.'**
  String adminAuthorArchived(String title);

  /// Shown after creating a quiz or journey.
  ///
  /// In en, this message translates to:
  /// **'{title} created as a draft.'**
  String adminAuthorCreated(String title);

  /// Shown after saving a journey.
  ///
  /// In en, this message translates to:
  /// **'Journey saved.'**
  String get adminAuthorSaved;

  /// Shown instead of publishing when the quiz has problems; problems are the server's sentences.
  ///
  /// In en, this message translates to:
  /// **'This quiz is not ready to publish. {problems}'**
  String adminAuthorNotReady(String problems);

  /// Title field of a quiz or journey.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get adminAuthorTitle;

  /// Description field of a quiz.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get adminAuthorDescription;

  /// Button and dialog title for a quiz's title, description and type.
  ///
  /// In en, this message translates to:
  /// **'Quiz settings'**
  String get adminAuthorQuizSettings;

  /// Title of the quiz editor.
  ///
  /// In en, this message translates to:
  /// **'Edit quiz: {title}'**
  String adminAuthorEditQuiz(String title);

  /// Title of the journey editor.
  ///
  /// In en, this message translates to:
  /// **'Edit journey: {title}'**
  String adminAuthorEditJourney(String title);

  /// Heading of a quiz's question list.
  ///
  /// In en, this message translates to:
  /// **'Questions'**
  String get adminAuthorQuestions;

  /// Empty question list of a quiz.
  ///
  /// In en, this message translates to:
  /// **'No questions yet.'**
  String get adminAuthorNoQuestions;

  /// A numbered question or journey step.
  ///
  /// In en, this message translates to:
  /// **'{number}. {text}'**
  String adminAuthorQuestionLine(int number, String text);

  /// The correct option of a question.
  ///
  /// In en, this message translates to:
  /// **'Correct answer: {answer}'**
  String adminAuthorCorrectAnswer(String answer);

  /// Short button text to remove a question or step.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get adminAuthorRemove;

  /// Spoken label of the Remove button.
  ///
  /// In en, this message translates to:
  /// **'Remove {item}'**
  String adminAuthorRemoveNamed(String item);

  /// Button and dialog title for writing a new question.
  ///
  /// In en, this message translates to:
  /// **'Type a new question'**
  String get adminAuthorAddNewQuestion;

  /// Button that adds a question from the teacher's question bank.
  ///
  /// In en, this message translates to:
  /// **'Add from question bank'**
  String get adminAuthorAddBankQuestion;

  /// Field for the question text.
  ///
  /// In en, this message translates to:
  /// **'Question'**
  String get adminAuthorQuestionText;

  /// Field for an answer option, and the choice of which option is correct.
  ///
  /// In en, this message translates to:
  /// **'Option {number}'**
  String adminAuthorOption(int number);

  /// Field for an optional answer option.
  ///
  /// In en, this message translates to:
  /// **'Option {number} (optional)'**
  String adminAuthorOptionalOption(int number);

  /// Heading of the choice of the correct option.
  ///
  /// In en, this message translates to:
  /// **'Correct answer'**
  String get adminAuthorCorrectOption;

  /// Shown when the option marked correct has no text.
  ///
  /// In en, this message translates to:
  /// **'The correct answer is blank. Fill it in or choose another option.'**
  String get adminAuthorCorrectIsBlank;

  /// Field for the explanation shown after answering.
  ///
  /// In en, this message translates to:
  /// **'Explanation (optional)'**
  String get adminAuthorExplanation;

  /// Checkbox that keeps a new quiz question in the teacher's question bank.
  ///
  /// In en, this message translates to:
  /// **'Also save to the teacher\'s question bank'**
  String get adminAuthorSaveToBank;

  /// Shown when a quiz question has a blank option.
  ///
  /// In en, this message translates to:
  /// **'Fill in all four options.'**
  String get adminAuthorNeedFourOptions;

  /// Shown when a journey question or poll has fewer than two options.
  ///
  /// In en, this message translates to:
  /// **'Fill in at least two options.'**
  String get adminAuthorNeedTwoOptions;

  /// Shown when two options have the same text.
  ///
  /// In en, this message translates to:
  /// **'Each option must be different.'**
  String get adminAuthorDuplicateOptions;

  /// Shown when a required field is empty.
  ///
  /// In en, this message translates to:
  /// **'{field} is required.'**
  String adminAuthorRequired(String field);

  /// Short button text to add a question or recording.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get adminAuthorAdd;

  /// Spoken label of the Add button.
  ///
  /// In en, this message translates to:
  /// **'Add {item}'**
  String adminAuthorAddNamed(String item);

  /// Title of the dialog listing the teacher's saved questions.
  ///
  /// In en, this message translates to:
  /// **'Teacher\'s question bank'**
  String get adminAuthorBankTitle;

  /// Empty question bank.
  ///
  /// In en, this message translates to:
  /// **'This teacher has no saved questions for this class and subject.'**
  String get adminAuthorBankEmpty;

  /// Closes the quiz editor.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get adminAuthorDone;

  /// Switch that makes a journey graded.
  ///
  /// In en, this message translates to:
  /// **'Graded: score the questions'**
  String get adminAuthorGraded;

  /// Dropdown of how many retries a journey question allows.
  ///
  /// In en, this message translates to:
  /// **'Retries after a wrong answer'**
  String get adminAuthorRetries;

  /// Heading of a journey's step list.
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get adminAuthorSteps;

  /// Empty step list of a journey.
  ///
  /// In en, this message translates to:
  /// **'No steps yet.'**
  String get adminAuthorNoSteps;

  /// A recording step in a journey.
  ///
  /// In en, this message translates to:
  /// **'Recording: {title}'**
  String adminAuthorStepRecording(String title);

  /// A narration step in a journey.
  ///
  /// In en, this message translates to:
  /// **'Narration: {text}'**
  String adminAuthorStepNarration(String text);

  /// A question step in a journey.
  ///
  /// In en, this message translates to:
  /// **'Question: {text}'**
  String adminAuthorStepQuestion(String text);

  /// A poll step in a journey.
  ///
  /// In en, this message translates to:
  /// **'Poll: {text}'**
  String adminAuthorStepPoll(String text);

  /// Short button text to move a step earlier.
  ///
  /// In en, this message translates to:
  /// **'Move up'**
  String get adminAuthorMoveUp;

  /// Spoken label of the Move up button.
  ///
  /// In en, this message translates to:
  /// **'Move {item} up'**
  String adminAuthorMoveUpNamed(String item);

  /// Short button text to move a step later.
  ///
  /// In en, this message translates to:
  /// **'Move down'**
  String get adminAuthorMoveDown;

  /// Spoken label of the Move down button.
  ///
  /// In en, this message translates to:
  /// **'Move {item} down'**
  String adminAuthorMoveDownNamed(String item);

  /// Button that adds one of the teacher's recordings as a journey step.
  ///
  /// In en, this message translates to:
  /// **'Add recording'**
  String get adminAuthorAddRecording;

  /// Button and dialog title for adding narration text to a journey.
  ///
  /// In en, this message translates to:
  /// **'Add narration'**
  String get adminAuthorAddNarration;

  /// Button and dialog title for adding a question to a journey.
  ///
  /// In en, this message translates to:
  /// **'Add question'**
  String get adminAuthorAddQuestion;

  /// Button and dialog title for adding a poll to a journey.
  ///
  /// In en, this message translates to:
  /// **'Add poll'**
  String get adminAuthorAddPoll;

  /// Title of the dialog listing the teacher's recordings.
  ///
  /// In en, this message translates to:
  /// **'Teacher\'s recordings'**
  String get adminAuthorRecordingsTitle;

  /// Explanation in the recordings dialog.
  ///
  /// In en, this message translates to:
  /// **'Only recordings this teacher uploaded for this class and subject can be used.'**
  String get adminAuthorRecordingsNote;

  /// Empty recordings list.
  ///
  /// In en, this message translates to:
  /// **'This teacher has not uploaded a recording for this class and subject.'**
  String get adminAuthorNoRecordings;

  /// Field for narration text.
  ///
  /// In en, this message translates to:
  /// **'Narration text'**
  String get adminAuthorNarrationText;

  /// Field for the poll question.
  ///
  /// In en, this message translates to:
  /// **'Poll question'**
  String get adminAuthorPollText;

  /// Saves the journey editor.
  ///
  /// In en, this message translates to:
  /// **'Save journey'**
  String get adminAuthorSaveJourney;

  /// Teacher: students who joined
  ///
  /// In en, this message translates to:
  /// **'{names} joined.'**
  String sessionPeopleJoined(String names);

  /// Teacher: students who left
  ///
  /// In en, this message translates to:
  /// **'{names} left.'**
  String sessionPeopleLeft(String names);

  /// Joins a list of names
  ///
  /// In en, this message translates to:
  /// **'{first} and {last}'**
  String sessionNamesAnd(String first, String last);

  /// Teacher: students present of enrolled
  ///
  /// In en, this message translates to:
  /// **'{here} of {total} here.'**
  String sessionHereOf(int here, int total);

  /// Teacher: students present, enrolled count unknown
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No students here.} =1{1 student here.} other{{count} students here.}}'**
  String sessionHereCount(int count);

  /// Teacher: one summary a minute after the class starts
  ///
  /// In en, this message translates to:
  /// **'{here} of {total} students here.'**
  String sessionStartSummary(int here, int total);

  /// Opening speech: the text field that has focus
  ///
  /// In en, this message translates to:
  /// **'You are in {field}.'**
  String uiFocusedField(String field);

  /// Teacher class screen key 5
  ///
  /// In en, this message translates to:
  /// **'4: Start'**
  String get sessionStartButton;

  /// Teacher key 5 spoken
  ///
  /// In en, this message translates to:
  /// **'Start a quiz, journey or recording for the class'**
  String get sessionStartLabel;

  /// Teacher: choose what to start
  ///
  /// In en, this message translates to:
  /// **'Start for the class'**
  String get sessionStartTitle;

  /// Start menu choice
  ///
  /// In en, this message translates to:
  /// **'Quiz'**
  String get sessionStartQuiz;

  /// Start menu choice
  ///
  /// In en, this message translates to:
  /// **'Journey'**
  String get sessionStartJourney;

  /// Start menu choice
  ///
  /// In en, this message translates to:
  /// **'Recording'**
  String get sessionStartRecording;

  /// Teacher key 6 while something runs
  ///
  /// In en, this message translates to:
  /// **'7: Status of {title}'**
  String sessionStatusKeyButton(String title);

  /// Teacher key 6 spoken
  ///
  /// In en, this message translates to:
  /// **'Status of {title}'**
  String sessionStatusKeyLabel(String title);

  /// Key help, teacher key 5
  ///
  /// In en, this message translates to:
  /// **'Start a quiz, journey or recording'**
  String get sessionKeyStart;

  /// Key help, teacher key 6
  ///
  /// In en, this message translates to:
  /// **'Status of what is running'**
  String get sessionKeyStatus;

  /// Teacher activity status
  ///
  /// In en, this message translates to:
  /// **'{present} students in class. {started} have attempted it, {finished} finished.'**
  String sessionActivityCounts(int present, int started, int finished);

  /// Status title when the recording has no title
  ///
  /// In en, this message translates to:
  /// **'the recording'**
  String get sessionNowPlayingTitle;

  /// No description provided for @noticeActorAdmin.
  ///
  /// In en, this message translates to:
  /// **'Your administrator'**
  String get noticeActorAdmin;

  /// No description provided for @noticeQuizCreated.
  ///
  /// In en, this message translates to:
  /// **'{actor} added quiz {title}.'**
  String noticeQuizCreated(String actor, String title);

  /// No description provided for @noticeQuizPublished.
  ///
  /// In en, this message translates to:
  /// **'{actor} published quiz {title}.'**
  String noticeQuizPublished(String actor, String title);

  /// No description provided for @noticeQuizClosed.
  ///
  /// In en, this message translates to:
  /// **'{actor} closed quiz {title}.'**
  String noticeQuizClosed(String actor, String title);

  /// No description provided for @noticeJourneyCreated.
  ///
  /// In en, this message translates to:
  /// **'{actor} added learning journey {title}.'**
  String noticeJourneyCreated(String actor, String title);

  /// No description provided for @noticeJourneyPublished.
  ///
  /// In en, this message translates to:
  /// **'{actor} published learning journey {title}.'**
  String noticeJourneyPublished(String actor, String title);

  /// No description provided for @noticeJourneyArchived.
  ///
  /// In en, this message translates to:
  /// **'{actor} archived learning journey {title}.'**
  String noticeJourneyArchived(String actor, String title);

  /// No description provided for @noticePlaylistPublished.
  ///
  /// In en, this message translates to:
  /// **'{actor} published playlist {title}.'**
  String noticePlaylistPublished(String actor, String title);

  /// No description provided for @noticeLessonCreated.
  ///
  /// In en, this message translates to:
  /// **'{actor} added lesson {title}.'**
  String noticeLessonCreated(String actor, String title);

  /// No description provided for @noticeLessonUpdated.
  ///
  /// In en, this message translates to:
  /// **'{actor} changed lesson {title}.'**
  String noticeLessonUpdated(String actor, String title);

  /// No description provided for @noticeLessonRemoved.
  ///
  /// In en, this message translates to:
  /// **'{actor} removed lesson {title}.'**
  String noticeLessonRemoved(String actor, String title);

  /// No description provided for @noticeLessonRemovedOn.
  ///
  /// In en, this message translates to:
  /// **'{actor} removed you from lesson {title} on {date}.'**
  String noticeLessonRemovedOn(String actor, String title, String date);

  /// No description provided for @noticeLessonCancelled.
  ///
  /// In en, this message translates to:
  /// **'{actor} cancelled lesson {title} on {date}.'**
  String noticeLessonCancelled(String actor, String title, String date);

  /// No description provided for @noticeLessonSubstitute.
  ///
  /// In en, this message translates to:
  /// **'{actor} asked you to teach lesson {title} on {date}.'**
  String noticeLessonSubstitute(String actor, String title, String date);

  /// No description provided for @noticeLessonCovered.
  ///
  /// In en, this message translates to:
  /// **'{actor} gave your lesson {title} on {date} to another teacher.'**
  String noticeLessonCovered(String actor, String title, String date);

  /// One item of a key list, e.g. '1 for Quizzes'. Items are joined by keypadKeySeparator and placed in keypadPressKeys.
  ///
  /// In en, this message translates to:
  /// **'{key} for {action}'**
  String keypadKeyFor(String key, String action);

  /// keys: items like '1 for Quizzes, 2 for Playlists, 0 for Back'.
  ///
  /// In en, this message translates to:
  /// **'Press {keys}.'**
  String keypadPressKeys(String keys);

  /// Joins key list items; normally a comma and a space.
  ///
  /// In en, this message translates to:
  /// **', '**
  String get keypadKeySeparator;

  /// No description provided for @keypadStarHelp.
  ///
  /// In en, this message translates to:
  /// **'Press star for help.'**
  String get keypadStarHelp;

  /// No description provided for @sessionCloseRecording.
  ///
  /// In en, this message translates to:
  /// **'Close recording for the class'**
  String get sessionCloseRecording;

  /// No description provided for @sessionRecordingClosedTeacher.
  ///
  /// In en, this message translates to:
  /// **'{title} is closed for the class.'**
  String sessionRecordingClosedTeacher(String title);

  /// No description provided for @sessionRecordingClosedStudent.
  ///
  /// In en, this message translates to:
  /// **'Your teacher closed the recording {title}.'**
  String sessionRecordingClosedStudent(String title);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['bn', 'en', 'hi', 'kn', 'te'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'kn':
      return AppLocalizationsKn();
    case 'te':
      return AppLocalizationsTe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
