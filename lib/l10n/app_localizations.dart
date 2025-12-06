import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Smile AI'**
  String get appTitle;

  /// No description provided for @navAi.
  ///
  /// In en, this message translates to:
  /// **'AI'**
  String get navAi;

  /// No description provided for @navTemplates.
  ///
  /// In en, this message translates to:
  /// **'Templates'**
  String get navTemplates;

  /// No description provided for @navAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get navAnalytics;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @templatesTitle.
  ///
  /// In en, this message translates to:
  /// **'Templates'**
  String get templatesTitle;

  /// No description provided for @templatesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No templates found'**
  String get templatesEmpty;

  /// No description provided for @analyticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Top trends of the week'**
  String get analyticsTitle;

  /// No description provided for @analyticsTrend1.
  ///
  /// In en, this message translates to:
  /// **'Top trend'**
  String get analyticsTrend1;

  /// No description provided for @analyticsTrendDeltaDescription.
  ///
  /// In en, this message translates to:
  /// **'Engagement has increased this much compared to last week'**
  String get analyticsTrendDeltaDescription;

  /// No description provided for @analytics7Days.
  ///
  /// In en, this message translates to:
  /// **'7 days'**
  String get analytics7Days;

  /// No description provided for @analyticsWhy.
  ///
  /// In en, this message translates to:
  /// **'Why?'**
  String get analyticsWhy;

  /// No description provided for @analyticsThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get analyticsThisWeek;

  /// No description provided for @analyticsCategoryTakes.
  ///
  /// In en, this message translates to:
  /// **'Category takes {percentage}% of all requests'**
  String analyticsCategoryTakes(Object percentage);

  /// No description provided for @analyticsCategoryTakesPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'percentage'**
  String get analyticsCategoryTakesPlaceholder;

  /// No description provided for @analyticsSecondPlace.
  ///
  /// In en, this message translates to:
  /// **'2nd place'**
  String get analyticsSecondPlace;

  /// No description provided for @analyticsAiAnalytics.
  ///
  /// In en, this message translates to:
  /// **'AI Analytics'**
  String get analyticsAiAnalytics;

  /// No description provided for @analyticsWasAdded.
  ///
  /// In en, this message translates to:
  /// **'{percentage}% was added'**
  String analyticsWasAdded(Object percentage);

  /// No description provided for @analyticsWasAddedPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'percentage'**
  String get analyticsWasAddedPlaceholder;

  /// No description provided for @analyticsCompetitivenessLevel.
  ///
  /// In en, this message translates to:
  /// **'Competitiveness Level'**
  String get analyticsCompetitivenessLevel;

  /// No description provided for @analyticsBasedOnAi.
  ///
  /// In en, this message translates to:
  /// **'Based on AI'**
  String get analyticsBasedOnAi;

  /// No description provided for @analyticsMonthNiches.
  ///
  /// In en, this message translates to:
  /// **'Month Niches'**
  String get analyticsMonthNiches;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileMenuAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get profileMenuAccount;

  /// No description provided for @profileMenuNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get profileMenuNotifications;

  /// No description provided for @profileMenuLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get profileMenuLanguage;

  /// No description provided for @profileMenuPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Data and privacy'**
  String get profileMenuPrivacy;

  /// No description provided for @profileMenuTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get profileMenuTheme;

  /// No description provided for @profileMenuSupport.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get profileMenuSupport;

  /// No description provided for @profileMenuFaq.
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get profileMenuFaq;

  /// No description provided for @profileMenuPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get profileMenuPolicy;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsSectionGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get notificationsSectionGeneral;

  /// No description provided for @notificationsSectionSystem.
  ///
  /// In en, this message translates to:
  /// **'System notifications'**
  String get notificationsSectionSystem;

  /// No description provided for @notificationsAll.
  ///
  /// In en, this message translates to:
  /// **'All notifications'**
  String get notificationsAll;

  /// No description provided for @notificationsSound.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get notificationsSound;

  /// No description provided for @notificationsVibration.
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get notificationsVibration;

  /// No description provided for @notificationsUpdates.
  ///
  /// In en, this message translates to:
  /// **'Updates'**
  String get notificationsUpdates;

  /// No description provided for @notificationsPromotions.
  ///
  /// In en, this message translates to:
  /// **'Promotions'**
  String get notificationsPromotions;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// No description provided for @languageSectionSuggested.
  ///
  /// In en, this message translates to:
  /// **'Suggested'**
  String get languageSectionSuggested;

  /// No description provided for @languageRussian.
  ///
  /// In en, this message translates to:
  /// **'Русский'**
  String get languageRussian;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @aiGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hi, you can ask me anything'**
  String get aiGreeting;

  /// No description provided for @aiSuggestionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Maybe these prompts will help you...'**
  String get aiSuggestionsTitle;

  /// No description provided for @aiSuggestion1.
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get aiSuggestion1;

  /// No description provided for @aiSuggestion2.
  ///
  /// In en, this message translates to:
  /// **'How are you?'**
  String get aiSuggestion2;

  /// No description provided for @aiSuggestion3.
  ///
  /// In en, this message translates to:
  /// **'What can you do?'**
  String get aiSuggestion3;

  /// No description provided for @aiSuggestion4.
  ///
  /// In en, this message translates to:
  /// **'Ask me something'**
  String get aiSuggestion4;

  /// No description provided for @aiSuggestion5.
  ///
  /// In en, this message translates to:
  /// **'Help me'**
  String get aiSuggestion5;

  /// No description provided for @aiSuggestion6.
  ///
  /// In en, this message translates to:
  /// **'Advice'**
  String get aiSuggestion6;

  /// No description provided for @aiStopGeneration.
  ///
  /// In en, this message translates to:
  /// **'Stop generation...'**
  String get aiStopGeneration;

  /// No description provided for @aiInputPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Enter your question...'**
  String get aiInputPlaceholder;

  /// No description provided for @aiRecognizingSpeech.
  ///
  /// In en, this message translates to:
  /// **'Recognizing speech...'**
  String get aiRecognizingSpeech;

  /// No description provided for @analyticsCategoryGrowing.
  ///
  /// In en, this message translates to:
  /// **'Rising'**
  String get analyticsCategoryGrowing;

  /// No description provided for @analyticsCategoryFalling.
  ///
  /// In en, this message translates to:
  /// **'Falling'**
  String get analyticsCategoryFalling;

  /// No description provided for @templateApply.
  ///
  /// In en, this message translates to:
  /// **'Apply template'**
  String get templateApply;

  /// No description provided for @templateEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get templateEdit;

  /// No description provided for @themeTitle.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeTitle;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'Use system'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light theme'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark theme'**
  String get themeDark;

  /// No description provided for @authEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get authEmailTitle;

  /// No description provided for @authEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmailHint;

  /// No description provided for @authEmailErrorInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get authEmailErrorInvalid;

  /// No description provided for @authEmailErrorNotRegistered.
  ///
  /// In en, this message translates to:
  /// **'This email is not registered'**
  String get authEmailErrorNotRegistered;

  /// No description provided for @authEmailErrorConnection.
  ///
  /// In en, this message translates to:
  /// **'Connection error. Check your internet and try again'**
  String get authEmailErrorConnection;

  /// No description provided for @authButtonLogin.
  ///
  /// In en, this message translates to:
  /// **'LOG IN'**
  String get authButtonLogin;

  /// No description provided for @authNoAccount.
  ///
  /// In en, this message translates to:
  /// **'Don’t have an account? '**
  String get authNoAccount;

  /// No description provided for @authRegister.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get authRegister;

  /// No description provided for @authPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPasswordHint;

  /// No description provided for @authPasswordErrorWrong.
  ///
  /// In en, this message translates to:
  /// **'Incorrect password'**
  String get authPasswordErrorWrong;

  /// No description provided for @authRegisterPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Registration screen will be here'**
  String get authRegisterPlaceholder;

  /// No description provided for @authRegisterTitle.
  ///
  /// In en, this message translates to:
  /// **'Registration'**
  String get authRegisterTitle;

  /// No description provided for @authHasAccount.
  ///
  /// In en, this message translates to:
  /// **'Have an account? '**
  String get authHasAccount;

  /// No description provided for @authLogin.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get authLogin;

  /// No description provided for @authButtonContinue.
  ///
  /// In en, this message translates to:
  /// **'CONTINUE'**
  String get authButtonContinue;

  /// No description provided for @authEmailAlreadyRegistered.
  ///
  /// In en, this message translates to:
  /// **'This email is already registered'**
  String get authEmailAlreadyRegistered;

  /// No description provided for @authCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get authCodeTitle;

  /// No description provided for @authCodeMessage.
  ///
  /// In en, this message translates to:
  /// **'A code has been sent to your email to\nconfirm registration 1111'**
  String get authCodeMessage;

  /// No description provided for @authCodeErrorWrong.
  ///
  /// In en, this message translates to:
  /// **'Incorrect code'**
  String get authCodeErrorWrong;

  /// No description provided for @authPasswordCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get authPasswordCreateTitle;

  /// No description provided for @authPasswordCreateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'password'**
  String get authPasswordCreateSubtitle;

  /// No description provided for @authPasswordConfirm.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPasswordConfirm;

  /// No description provided for @authPasswordErrorTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get authPasswordErrorTooShort;

  /// No description provided for @authPasswordErrorMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get authPasswordErrorMismatch;

  /// No description provided for @authFillDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Fill in data'**
  String get authFillDataTitle;

  /// No description provided for @authPasswordWeakTitle.
  ///
  /// In en, this message translates to:
  /// **'Your password is too weak'**
  String get authPasswordWeakTitle;

  /// No description provided for @authPasswordWeakMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to use it?'**
  String get authPasswordWeakMessage;

  /// No description provided for @authPasswordWeakChange.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get authPasswordWeakChange;

  /// No description provided for @authPasswordWeakContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get authPasswordWeakContinue;

  /// No description provided for @authSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get authSaveButton;

  /// No description provided for @authFieldFullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get authFieldFullName;

  /// No description provided for @authFieldNickname.
  ///
  /// In en, this message translates to:
  /// **'Nickname'**
  String get authFieldNickname;

  /// No description provided for @authFieldEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authFieldEmail;

  /// No description provided for @authFieldPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get authFieldPhone;

  /// No description provided for @authFieldCountry.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get authFieldCountry;

  /// No description provided for @authFieldGender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get authFieldGender;

  /// No description provided for @authCountryRussia.
  ///
  /// In en, this message translates to:
  /// **'Russia'**
  String get authCountryRussia;

  /// No description provided for @authCountryKazakhstan.
  ///
  /// In en, this message translates to:
  /// **'Kazakhstan'**
  String get authCountryKazakhstan;

  /// No description provided for @authCountryBelarus.
  ///
  /// In en, this message translates to:
  /// **'Belarus'**
  String get authCountryBelarus;

  /// No description provided for @authGenderMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get authGenderMale;

  /// No description provided for @authGenderFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get authGenderFemale;

  /// No description provided for @authNicknameError.
  ///
  /// In en, this message translates to:
  /// **'Only English letters, numbers and special characters'**
  String get authNicknameError;

  /// No description provided for @accountEditProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get accountEditProfileTitle;

  /// No description provided for @aiCopyToast.
  ///
  /// In en, this message translates to:
  /// **'Text copied'**
  String get aiCopyToast;

  /// No description provided for @templateCategoryMarketing.
  ///
  /// In en, this message translates to:
  /// **'Marketing'**
  String get templateCategoryMarketing;

  /// No description provided for @templateCategorySales.
  ///
  /// In en, this message translates to:
  /// **'Sales'**
  String get templateCategorySales;

  /// No description provided for @templateCategoryStrategy.
  ///
  /// In en, this message translates to:
  /// **'Strategy'**
  String get templateCategoryStrategy;

  /// No description provided for @templateCategorySupport.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get templateCategorySupport;

  /// No description provided for @templateCategoryStaff.
  ///
  /// In en, this message translates to:
  /// **'Team'**
  String get templateCategoryStaff;

  /// No description provided for @templateCategoryAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get templateCategoryAnalytics;

  /// No description provided for @templateTitle0.
  ///
  /// In en, this message translates to:
  /// **'Create a high-converting social media post'**
  String get templateTitle0;

  /// No description provided for @templateTitle1.
  ///
  /// In en, this message translates to:
  /// **'Write an attractive product description for a catalog'**
  String get templateTitle1;

  /// No description provided for @templateTitle2.
  ///
  /// In en, this message translates to:
  /// **'Create an ad text up to 150 characters'**
  String get templateTitle2;

  /// No description provided for @templateTitle3.
  ///
  /// In en, this message translates to:
  /// **'Come up with an idea for a viral Reels or TikTok'**
  String get templateTitle3;

  /// No description provided for @templateTitle4.
  ///
  /// In en, this message translates to:
  /// **'Create an email newsletter text for clients'**
  String get templateTitle4;

  /// No description provided for @templateTitle5.
  ///
  /// In en, this message translates to:
  /// **'Make a weekly content plan for a business'**
  String get templateTitle5;

  /// No description provided for @templateTitle6.
  ///
  /// In en, this message translates to:
  /// **'Create a call script for selling a service'**
  String get templateTitle6;

  /// No description provided for @templateTitle7.
  ///
  /// In en, this message translates to:
  /// **'Prepare answers to typical client objections'**
  String get templateTitle7;

  /// No description provided for @templateTitle8.
  ///
  /// In en, this message translates to:
  /// **'Write a short commercial proposal'**
  String get templateTitle8;

  /// No description provided for @templateTitle9.
  ///
  /// In en, this message translates to:
  /// **'Write effective chat message text for a client'**
  String get templateTitle9;

  /// No description provided for @templateTitle10.
  ///
  /// In en, this message translates to:
  /// **'Prepare a closing phrase to finalize a deal'**
  String get templateTitle10;

  /// No description provided for @templateTitle11.
  ///
  /// In en, this message translates to:
  /// **'Create a short cold message for first contact'**
  String get templateTitle11;

  /// No description provided for @templateTitle12.
  ///
  /// In en, this message translates to:
  /// **'Make a 3-month business growth plan'**
  String get templateTitle12;

  /// No description provided for @templateTitle13.
  ///
  /// In en, this message translates to:
  /// **'Make a brief analysis of main competitors'**
  String get templateTitle13;

  /// No description provided for @templateTitle14.
  ///
  /// In en, this message translates to:
  /// **'Suggest ideas to expand the service line'**
  String get templateTitle14;

  /// No description provided for @templateTitle15.
  ///
  /// In en, this message translates to:
  /// **'Create a SWOT analysis for the company'**
  String get templateTitle15;

  /// No description provided for @templateTitle16.
  ///
  /// In en, this message translates to:
  /// **'Suggest a strategy to increase profit'**
  String get templateTitle16;

  /// No description provided for @templateTitle17.
  ///
  /// In en, this message translates to:
  /// **'Formulate a unique selling proposition'**
  String get templateTitle17;

  /// No description provided for @templateTitle18.
  ///
  /// In en, this message translates to:
  /// **'Write a polite reply to an unhappy client'**
  String get templateTitle18;

  /// No description provided for @templateTitle19.
  ///
  /// In en, this message translates to:
  /// **'Write a correct message about a delay'**
  String get templateTitle19;

  /// No description provided for @templateTitle20.
  ///
  /// In en, this message translates to:
  /// **'Create an order confirmation message'**
  String get templateTitle20;

  /// No description provided for @templateTitle21.
  ///
  /// In en, this message translates to:
  /// **'Write usage instructions for a product'**
  String get templateTitle21;

  /// No description provided for @templateTitle22.
  ///
  /// In en, this message translates to:
  /// **'Create a proper apology message'**
  String get templateTitle22;

  /// No description provided for @templateTitle23.
  ///
  /// In en, this message translates to:
  /// **'Write a professional reply to a client question'**
  String get templateTitle23;

  /// No description provided for @templateTitle24.
  ///
  /// In en, this message translates to:
  /// **'Give constructive feedback to an employee'**
  String get templateTitle24;

  /// No description provided for @templateTitle25.
  ///
  /// In en, this message translates to:
  /// **'Create a short announcement for the team'**
  String get templateTitle25;

  /// No description provided for @templateTitle26.
  ///
  /// In en, this message translates to:
  /// **'Write a motivational message for employees'**
  String get templateTitle26;

  /// No description provided for @templateTitle27.
  ///
  /// In en, this message translates to:
  /// **'Make a daily task list for an employee'**
  String get templateTitle27;

  /// No description provided for @templateTitle28.
  ///
  /// In en, this message translates to:
  /// **'Create a set of corporate rules'**
  String get templateTitle28;

  /// No description provided for @templateTitle29.
  ///
  /// In en, this message translates to:
  /// **'Write an attractive job vacancy text'**
  String get templateTitle29;

  /// No description provided for @templateTitle30.
  ///
  /// In en, this message translates to:
  /// **'Make a brief sales analysis'**
  String get templateTitle30;

  /// No description provided for @templateTitle31.
  ///
  /// In en, this message translates to:
  /// **'Create a weekly performance report'**
  String get templateTitle31;

  /// No description provided for @templateTitle32.
  ///
  /// In en, this message translates to:
  /// **'Evaluate an ad campaign’s effectiveness'**
  String get templateTitle32;

  /// No description provided for @templateTitle33.
  ///
  /// In en, this message translates to:
  /// **'Make a demand forecast'**
  String get templateTitle33;

  /// No description provided for @templateTitle34.
  ///
  /// In en, this message translates to:
  /// **'Analyze the weak points of the business'**
  String get templateTitle34;

  /// No description provided for @templateTitle35.
  ///
  /// In en, this message translates to:
  /// **'Give recommendations to improve business performance'**
  String get templateTitle35;

  /// No description provided for @templateTitle36.
  ///
  /// In en, this message translates to:
  /// **'Create a conversion report'**
  String get templateTitle36;

  /// No description provided for @templateTitle37.
  ///
  /// In en, this message translates to:
  /// **'Analyze customer behavior'**
  String get templateTitle37;

  /// No description provided for @templateTitle38.
  ///
  /// In en, this message translates to:
  /// **'Create a quarterly financial plan'**
  String get templateTitle38;

  /// No description provided for @templateTitle39.
  ///
  /// In en, this message translates to:
  /// **'Calculate the break-even point'**
  String get templateTitle39;

  /// No description provided for @templateTitle40.
  ///
  /// In en, this message translates to:
  /// **'Create a monthly budget'**
  String get templateTitle40;

  /// No description provided for @templateTitle41.
  ///
  /// In en, this message translates to:
  /// **'Analyze company expenses'**
  String get templateTitle41;

  /// No description provided for @templateTitle42.
  ///
  /// In en, this message translates to:
  /// **'Create a cost optimization plan'**
  String get templateTitle42;

  /// No description provided for @templateTitle43.
  ///
  /// In en, this message translates to:
  /// **'Calculate project profitability'**
  String get templateTitle43;

  /// No description provided for @templateTitle44.
  ///
  /// In en, this message translates to:
  /// **'Create a financial report'**
  String get templateTitle44;

  /// No description provided for @templateTitle45.
  ///
  /// In en, this message translates to:
  /// **'Create a job description'**
  String get templateTitle45;

  /// No description provided for @templateTitle46.
  ///
  /// In en, this message translates to:
  /// **'Create a new employee onboarding plan'**
  String get templateTitle46;

  /// No description provided for @templateTitle47.
  ///
  /// In en, this message translates to:
  /// **'Create an employee training plan'**
  String get templateTitle47;

  /// No description provided for @templateTitle48.
  ///
  /// In en, this message translates to:
  /// **'Create a performance evaluation system'**
  String get templateTitle48;

  /// No description provided for @templateTitle49.
  ///
  /// In en, this message translates to:
  /// **'Write a team development plan'**
  String get templateTitle49;

  /// No description provided for @templateTitle50.
  ///
  /// In en, this message translates to:
  /// **'Create a staff motivation program'**
  String get templateTitle50;

  /// No description provided for @templateTitle51.
  ///
  /// In en, this message translates to:
  /// **'Optimize work processes'**
  String get templateTitle51;

  /// No description provided for @templateTitle52.
  ///
  /// In en, this message translates to:
  /// **'Create a quality improvement plan'**
  String get templateTitle52;

  /// No description provided for @templateTitle53.
  ///
  /// In en, this message translates to:
  /// **'Create a quality control system'**
  String get templateTitle53;

  /// No description provided for @templateTitle54.
  ///
  /// In en, this message translates to:
  /// **'Create a logistics plan'**
  String get templateTitle54;

  /// No description provided for @templateTitle55.
  ///
  /// In en, this message translates to:
  /// **'Optimize the supply chain'**
  String get templateTitle55;

  /// No description provided for @templateTitle56.
  ///
  /// In en, this message translates to:
  /// **'Create work standards'**
  String get templateTitle56;

  /// No description provided for @templateTitle57.
  ///
  /// In en, this message translates to:
  /// **'Create a merchandising plan'**
  String get templateTitle57;

  /// No description provided for @templateTitle58.
  ///
  /// In en, this message translates to:
  /// **'Create a pricing strategy'**
  String get templateTitle58;

  /// No description provided for @templateTitle59.
  ///
  /// In en, this message translates to:
  /// **'Create a promotions and discounts plan'**
  String get templateTitle59;

  /// No description provided for @templateTitle60.
  ///
  /// In en, this message translates to:
  /// **'Optimize product display'**
  String get templateTitle60;

  /// No description provided for @templateTitle61.
  ///
  /// In en, this message translates to:
  /// **'Create a supplier management plan'**
  String get templateTitle61;

  /// No description provided for @templateTitle62.
  ///
  /// In en, this message translates to:
  /// **'Create an inventory management system'**
  String get templateTitle62;

  /// No description provided for @templateTitle63.
  ///
  /// In en, this message translates to:
  /// **'Optimize the production process'**
  String get templateTitle63;

  /// No description provided for @templateTitle64.
  ///
  /// In en, this message translates to:
  /// **'Create a quality control plan'**
  String get templateTitle64;

  /// No description provided for @templateTitle65.
  ///
  /// In en, this message translates to:
  /// **'Create a production management system'**
  String get templateTitle65;

  /// No description provided for @templateTitle66.
  ///
  /// In en, this message translates to:
  /// **'Create a maintenance plan'**
  String get templateTitle66;

  /// No description provided for @templateTitle67.
  ///
  /// In en, this message translates to:
  /// **'Optimize resource usage'**
  String get templateTitle67;

  /// No description provided for @templateTitle68.
  ///
  /// In en, this message translates to:
  /// **'Create a production safety plan'**
  String get templateTitle68;

  /// No description provided for @templateTitle69.
  ///
  /// In en, this message translates to:
  /// **'Create technical specifications'**
  String get templateTitle69;

  /// No description provided for @templateTitle70.
  ///
  /// In en, this message translates to:
  /// **'Create a product development plan'**
  String get templateTitle70;

  /// No description provided for @templateTitle71.
  ///
  /// In en, this message translates to:
  /// **'Create a testing plan'**
  String get templateTitle71;

  /// No description provided for @templateTitle72.
  ///
  /// In en, this message translates to:
  /// **'Create project documentation'**
  String get templateTitle72;

  /// No description provided for @templateTitle73.
  ///
  /// In en, this message translates to:
  /// **'Create a system implementation plan'**
  String get templateTitle73;

  /// No description provided for @templateTitle74.
  ///
  /// In en, this message translates to:
  /// **'Create a technical support plan'**
  String get templateTitle74;

  /// No description provided for @templateTitle75.
  ///
  /// In en, this message translates to:
  /// **'Create a patient treatment plan'**
  String get templateTitle75;

  /// No description provided for @templateTitle76.
  ///
  /// In en, this message translates to:
  /// **'Create a medical procedure protocol'**
  String get templateTitle76;

  /// No description provided for @templateTitle77.
  ///
  /// In en, this message translates to:
  /// **'Create a preventive measures plan'**
  String get templateTitle77;

  /// No description provided for @templateTitle78.
  ///
  /// In en, this message translates to:
  /// **'Create a medical records management system'**
  String get templateTitle78;

  /// No description provided for @templateTitle79.
  ///
  /// In en, this message translates to:
  /// **'Create a patient management plan'**
  String get templateTitle79;

  /// No description provided for @templateTitle80.
  ///
  /// In en, this message translates to:
  /// **'Create a service quality improvement plan'**
  String get templateTitle80;

  /// No description provided for @templateTitle81.
  ///
  /// In en, this message translates to:
  /// **'Create a curriculum'**
  String get templateTitle81;

  /// No description provided for @templateTitle82.
  ///
  /// In en, this message translates to:
  /// **'Create a lesson plan'**
  String get templateTitle82;

  /// No description provided for @templateTitle83.
  ///
  /// In en, this message translates to:
  /// **'Create a training program'**
  String get templateTitle83;

  /// No description provided for @templateTitle84.
  ///
  /// In en, this message translates to:
  /// **'Create a knowledge assessment system'**
  String get templateTitle84;

  /// No description provided for @templateTitle85.
  ///
  /// In en, this message translates to:
  /// **'Create a parent engagement plan'**
  String get templateTitle85;

  /// No description provided for @templateTitle86.
  ///
  /// In en, this message translates to:
  /// **'Create an educational institution development plan'**
  String get templateTitle86;

  /// No description provided for @templateTitle87.
  ///
  /// In en, this message translates to:
  /// **'Create a real estate property description'**
  String get templateTitle87;

  /// No description provided for @templateTitle88.
  ///
  /// In en, this message translates to:
  /// **'Create a property presentation plan'**
  String get templateTitle88;

  /// No description provided for @templateTitle89.
  ///
  /// In en, this message translates to:
  /// **'Create a client management plan'**
  String get templateTitle89;

  /// No description provided for @templateTitle90.
  ///
  /// In en, this message translates to:
  /// **'Create a property management system'**
  String get templateTitle90;

  /// No description provided for @templateTitle91.
  ///
  /// In en, this message translates to:
  /// **'Create a real estate marketing plan'**
  String get templateTitle91;

  /// No description provided for @templateTitle92.
  ///
  /// In en, this message translates to:
  /// **'Create a real estate appraisal plan'**
  String get templateTitle92;

  /// No description provided for @templateTitle93.
  ///
  /// In en, this message translates to:
  /// **'Create a restaurant menu'**
  String get templateTitle93;

  /// No description provided for @templateTitle94.
  ///
  /// In en, this message translates to:
  /// **'Create a kitchen operations plan'**
  String get templateTitle94;

  /// No description provided for @templateTitle95.
  ///
  /// In en, this message translates to:
  /// **'Create a guest service plan'**
  String get templateTitle95;

  /// No description provided for @templateTitle96.
  ///
  /// In en, this message translates to:
  /// **'Create an order management system'**
  String get templateTitle96;

  /// No description provided for @templateTitle97.
  ///
  /// In en, this message translates to:
  /// **'Create a restaurant marketing plan'**
  String get templateTitle97;

  /// No description provided for @templateTitle98.
  ///
  /// In en, this message translates to:
  /// **'Create a supplier management plan'**
  String get templateTitle98;

  /// No description provided for @templateTitle99.
  ///
  /// In en, this message translates to:
  /// **'Optimize delivery routes'**
  String get templateTitle99;

  /// No description provided for @templateTitle100.
  ///
  /// In en, this message translates to:
  /// **'Create a warehouse logistics plan'**
  String get templateTitle100;

  /// No description provided for @templateTitle101.
  ///
  /// In en, this message translates to:
  /// **'Create a transport management system'**
  String get templateTitle101;

  /// No description provided for @templateTitle102.
  ///
  /// In en, this message translates to:
  /// **'Create a carrier management plan'**
  String get templateTitle102;

  /// No description provided for @templateTitle103.
  ///
  /// In en, this message translates to:
  /// **'Create an inventory management plan'**
  String get templateTitle103;

  /// No description provided for @templateTitle104.
  ///
  /// In en, this message translates to:
  /// **'Optimize the supply chain'**
  String get templateTitle104;

  /// No description provided for @templateTitle105.
  ///
  /// In en, this message translates to:
  /// **'Create an attractive article headline'**
  String get templateTitle105;

  /// No description provided for @templateTitle106.
  ///
  /// In en, this message translates to:
  /// **'Write a landing page description'**
  String get templateTitle106;

  /// No description provided for @templateTitle107.
  ///
  /// In en, this message translates to:
  /// **'Create a product launch plan'**
  String get templateTitle107;

  /// No description provided for @templateTitle108.
  ///
  /// In en, this message translates to:
  /// **'Create a banner text'**
  String get templateTitle108;

  /// No description provided for @templateTitle109.
  ///
  /// In en, this message translates to:
  /// **'Come up with a brand slogan'**
  String get templateTitle109;

  /// No description provided for @templateTitle110.
  ///
  /// In en, this message translates to:
  /// **'Create an influencer collaboration plan'**
  String get templateTitle110;

  /// No description provided for @templateTitle111.
  ///
  /// In en, this message translates to:
  /// **'Create a push notification text'**
  String get templateTitle111;

  /// No description provided for @templateTitle112.
  ///
  /// In en, this message translates to:
  /// **'Write a YouTube video description'**
  String get templateTitle112;

  /// No description provided for @templateTitle113.
  ///
  /// In en, this message translates to:
  /// **'Create a sales funnel plan'**
  String get templateTitle113;

  /// No description provided for @templateTitle114.
  ///
  /// In en, this message translates to:
  /// **'Create a client presentation'**
  String get templateTitle114;

  /// No description provided for @templateTitle115.
  ///
  /// In en, this message translates to:
  /// **'Write a follow-up email text'**
  String get templateTitle115;

  /// No description provided for @templateTitle116.
  ///
  /// In en, this message translates to:
  /// **'Create a deferred deals management plan'**
  String get templateTitle116;

  /// No description provided for @templateTitle117.
  ///
  /// In en, this message translates to:
  /// **'Create a sales team motivation system'**
  String get templateTitle117;

  /// No description provided for @templateTitle118.
  ///
  /// In en, this message translates to:
  /// **'Write a discount offer text'**
  String get templateTitle118;

  /// No description provided for @templateTitle119.
  ///
  /// In en, this message translates to:
  /// **'Create a loyal customer management plan'**
  String get templateTitle119;

  /// No description provided for @templateTitle120.
  ///
  /// In en, this message translates to:
  /// **'Create a script for handling objections'**
  String get templateTitle120;

  /// No description provided for @templateTitle121.
  ///
  /// In en, this message translates to:
  /// **'Create a long-term development strategy'**
  String get templateTitle121;

  /// No description provided for @templateTitle122.
  ///
  /// In en, this message translates to:
  /// **'Create a market entry plan'**
  String get templateTitle122;

  /// No description provided for @templateTitle123.
  ///
  /// In en, this message translates to:
  /// **'Create a business diversification plan'**
  String get templateTitle123;

  /// No description provided for @templateTitle124.
  ///
  /// In en, this message translates to:
  /// **'Create a brand positioning strategy'**
  String get templateTitle124;

  /// No description provided for @templateTitle125.
  ///
  /// In en, this message translates to:
  /// **'Create a partnership plan with other companies'**
  String get templateTitle125;

  /// No description provided for @templateTitle126.
  ///
  /// In en, this message translates to:
  /// **'Create a business scaling plan'**
  String get templateTitle126;

  /// No description provided for @templateTitle127.
  ///
  /// In en, this message translates to:
  /// **'Create a crisis management plan'**
  String get templateTitle127;

  /// No description provided for @templateTitle128.
  ///
  /// In en, this message translates to:
  /// **'Create a seasonality strategy'**
  String get templateTitle128;

  /// No description provided for @templateTitle129.
  ///
  /// In en, this message translates to:
  /// **'Create a FAQ response template'**
  String get templateTitle129;

  /// No description provided for @templateTitle130.
  ///
  /// In en, this message translates to:
  /// **'Create a complaint management plan'**
  String get templateTitle130;

  /// No description provided for @templateTitle131.
  ///
  /// In en, this message translates to:
  /// **'Write a problem resolution message'**
  String get templateTitle131;

  /// No description provided for @templateTitle132.
  ///
  /// In en, this message translates to:
  /// **'Create a support quality evaluation system'**
  String get templateTitle132;

  /// No description provided for @templateTitle133.
  ///
  /// In en, this message translates to:
  /// **'Create a support staff training plan'**
  String get templateTitle133;

  /// No description provided for @templateTitle134.
  ///
  /// In en, this message translates to:
  /// **'Write a knowledge base text'**
  String get templateTitle134;

  /// No description provided for @templateTitle135.
  ///
  /// In en, this message translates to:
  /// **'Create a customer feedback management plan'**
  String get templateTitle135;

  /// No description provided for @templateTitle136.
  ///
  /// In en, this message translates to:
  /// **'Create an after-hours work plan'**
  String get templateTitle136;

  /// No description provided for @templateTitle137.
  ///
  /// In en, this message translates to:
  /// **'Create an interview plan'**
  String get templateTitle137;

  /// No description provided for @templateTitle138.
  ///
  /// In en, this message translates to:
  /// **'Create an employee evaluation system'**
  String get templateTitle138;

  /// No description provided for @templateTitle139.
  ///
  /// In en, this message translates to:
  /// **'Create a team building plan'**
  String get templateTitle139;

  /// No description provided for @templateTitle140.
  ///
  /// In en, this message translates to:
  /// **'Write an employee career development plan'**
  String get templateTitle140;

  /// No description provided for @templateTitle141.
  ///
  /// In en, this message translates to:
  /// **'Create a team conflict management plan'**
  String get templateTitle141;

  /// No description provided for @templateTitle142.
  ///
  /// In en, this message translates to:
  /// **'Create a talent retention plan'**
  String get templateTitle142;

  /// No description provided for @templateTitle143.
  ///
  /// In en, this message translates to:
  /// **'Create a mentoring system'**
  String get templateTitle143;

  /// No description provided for @templateTitle144.
  ///
  /// In en, this message translates to:
  /// **'Create a corporate events plan'**
  String get templateTitle144;

  /// No description provided for @templateTitle145.
  ///
  /// In en, this message translates to:
  /// **'Create a key metrics dashboard'**
  String get templateTitle145;

  /// No description provided for @templateTitle146.
  ///
  /// In en, this message translates to:
  /// **'Analyze the effectiveness of acquisition channels'**
  String get templateTitle146;

  /// No description provided for @templateTitle147.
  ///
  /// In en, this message translates to:
  /// **'Create a marketing campaigns ROI report'**
  String get templateTitle147;

  /// No description provided for @templateTitle148.
  ///
  /// In en, this message translates to:
  /// **'Create a customer lifecycle analysis'**
  String get templateTitle148;

  /// No description provided for @templateTitle149.
  ///
  /// In en, this message translates to:
  /// **'Analyze seasonal trends'**
  String get templateTitle149;

  /// No description provided for @templateTitle150.
  ///
  /// In en, this message translates to:
  /// **'Create a competitive analysis'**
  String get templateTitle150;

  /// No description provided for @templateTitle151.
  ///
  /// In en, this message translates to:
  /// **'Create an investment plan'**
  String get templateTitle151;

  /// No description provided for @templateTitle152.
  ///
  /// In en, this message translates to:
  /// **'Create a cash flow management system'**
  String get templateTitle152;

  /// No description provided for @templateTitle153.
  ///
  /// In en, this message translates to:
  /// **'Create a credit management plan'**
  String get templateTitle153;

  /// No description provided for @templateTitle154.
  ///
  /// In en, this message translates to:
  /// **'Create an expense control system'**
  String get templateTitle154;

  /// No description provided for @templateTitle155.
  ///
  /// In en, this message translates to:
  /// **'Create a tax planning plan'**
  String get templateTitle155;

  /// No description provided for @templateTitle156.
  ///
  /// In en, this message translates to:
  /// **'Create a financial indicators forecast'**
  String get templateTitle156;

  /// No description provided for @templateTitle157.
  ///
  /// In en, this message translates to:
  /// **'Create an accounts receivable management plan'**
  String get templateTitle157;

  /// No description provided for @templateTitle158.
  ///
  /// In en, this message translates to:
  /// **'Create a new employee onboarding plan'**
  String get templateTitle158;

  /// No description provided for @templateTitle159.
  ///
  /// In en, this message translates to:
  /// **'Create a compensation and benefits system'**
  String get templateTitle159;

  /// No description provided for @templateTitle160.
  ///
  /// In en, this message translates to:
  /// **'Create an employee termination plan'**
  String get templateTitle160;

  /// No description provided for @templateTitle161.
  ///
  /// In en, this message translates to:
  /// **'Create a leadership development plan'**
  String get templateTitle161;

  /// No description provided for @templateTitle162.
  ///
  /// In en, this message translates to:
  /// **'Create an employee feedback system'**
  String get templateTitle162;

  /// No description provided for @templateTitle163.
  ///
  /// In en, this message translates to:
  /// **'Create a remote employee management plan'**
  String get templateTitle163;

  /// No description provided for @templateTitle164.
  ///
  /// In en, this message translates to:
  /// **'Create an internal communications plan'**
  String get templateTitle164;

  /// No description provided for @templateTitle165.
  ///
  /// In en, this message translates to:
  /// **'Create a productivity plan'**
  String get templateTitle165;

  /// No description provided for @templateTitle166.
  ///
  /// In en, this message translates to:
  /// **'Create a process automation plan'**
  String get templateTitle166;

  /// No description provided for @templateTitle167.
  ///
  /// In en, this message translates to:
  /// **'Create a risk management system'**
  String get templateTitle167;

  /// No description provided for @templateTitle168.
  ///
  /// In en, this message translates to:
  /// **'Create a supplier management plan'**
  String get templateTitle168;

  /// No description provided for @templateTitle169.
  ///
  /// In en, this message translates to:
  /// **'Create an inventory management plan'**
  String get templateTitle169;

  /// No description provided for @templateTitle170.
  ///
  /// In en, this message translates to:
  /// **'Create a documentation management plan'**
  String get templateTitle170;

  /// No description provided for @templateTitle171.
  ///
  /// In en, this message translates to:
  /// **'Create a process monitoring system'**
  String get templateTitle171;

  /// No description provided for @templateTitle172.
  ///
  /// In en, this message translates to:
  /// **'Create an incident management plan'**
  String get templateTitle172;

  /// No description provided for @templateTitle173.
  ///
  /// In en, this message translates to:
  /// **'Create a continuous improvement plan'**
  String get templateTitle173;

  /// No description provided for @templateTitle174.
  ///
  /// In en, this message translates to:
  /// **'Create a customer management plan'**
  String get templateTitle174;

  /// No description provided for @templateTitle175.
  ///
  /// In en, this message translates to:
  /// **'Create a returns management plan'**
  String get templateTitle175;

  /// No description provided for @templateTitle176.
  ///
  /// In en, this message translates to:
  /// **'Create a seasonal products management plan'**
  String get templateTitle176;

  /// No description provided for @templateTitle177.
  ///
  /// In en, this message translates to:
  /// **'Create a promo codes system'**
  String get templateTitle177;

  /// No description provided for @templateTitle178.
  ///
  /// In en, this message translates to:
  /// **'Create an online sales plan'**
  String get templateTitle178;

  /// No description provided for @templateTitle179.
  ///
  /// In en, this message translates to:
  /// **'Create a loyalty programs plan'**
  String get templateTitle179;

  /// No description provided for @templateTitle180.
  ///
  /// In en, this message translates to:
  /// **'Create a storefront management plan'**
  String get templateTitle180;

  /// No description provided for @templateTitle181.
  ///
  /// In en, this message translates to:
  /// **'Create a store staff management plan'**
  String get templateTitle181;

  /// No description provided for @templateTitle182.
  ///
  /// In en, this message translates to:
  /// **'Create an equipment management plan'**
  String get templateTitle182;

  /// No description provided for @templateTitle183.
  ///
  /// In en, this message translates to:
  /// **'Create a production plan management system'**
  String get templateTitle183;

  /// No description provided for @templateTitle184.
  ///
  /// In en, this message translates to:
  /// **'Create a defect management plan'**
  String get templateTitle184;

  /// No description provided for @templateTitle185.
  ///
  /// In en, this message translates to:
  /// **'Create an energy efficiency plan'**
  String get templateTitle185;

  /// No description provided for @templateTitle186.
  ///
  /// In en, this message translates to:
  /// **'Create an environmental management plan'**
  String get templateTitle186;

  /// No description provided for @templateTitle187.
  ///
  /// In en, this message translates to:
  /// **'Create an innovation plan'**
  String get templateTitle187;

  /// No description provided for @templateTitle188.
  ///
  /// In en, this message translates to:
  /// **'Create a certification plan'**
  String get templateTitle188;

  /// No description provided for @templateTitle189.
  ///
  /// In en, this message translates to:
  /// **'Create a packaging plan'**
  String get templateTitle189;

  /// No description provided for @templateTitle190.
  ///
  /// In en, this message translates to:
  /// **'Create a data security plan'**
  String get templateTitle190;

  /// No description provided for @templateTitle191.
  ///
  /// In en, this message translates to:
  /// **'Create a cloud services plan'**
  String get templateTitle191;

  /// No description provided for @templateTitle192.
  ///
  /// In en, this message translates to:
  /// **'Create an API management plan'**
  String get templateTitle192;

  /// No description provided for @templateTitle193.
  ///
  /// In en, this message translates to:
  /// **'Create a DevOps plan'**
  String get templateTitle193;

  /// No description provided for @templateTitle194.
  ///
  /// In en, this message translates to:
  /// **'Create a mobile applications plan'**
  String get templateTitle194;

  /// No description provided for @templateTitle195.
  ///
  /// In en, this message translates to:
  /// **'Create an artificial intelligence plan'**
  String get templateTitle195;

  /// No description provided for @templateTitle196.
  ///
  /// In en, this message translates to:
  /// **'Create a cybersecurity plan'**
  String get templateTitle196;

  /// No description provided for @templateTitle197.
  ///
  /// In en, this message translates to:
  /// **'Create an automation plan'**
  String get templateTitle197;

  /// No description provided for @templateTitle198.
  ///
  /// In en, this message translates to:
  /// **'Create a patient management plan'**
  String get templateTitle198;

  /// No description provided for @templateTitle199.
  ///
  /// In en, this message translates to:
  /// **'Create a medical equipment management plan'**
  String get templateTitle199;

  /// No description provided for @templateTitle200.
  ///
  /// In en, this message translates to:
  /// **'Create a medication management plan'**
  String get templateTitle200;

  /// No description provided for @templateTitle201.
  ///
  /// In en, this message translates to:
  /// **'Create a medical staff management plan'**
  String get templateTitle201;

  /// No description provided for @templateTitle202.
  ///
  /// In en, this message translates to:
  /// **'Create a sanitary standards plan'**
  String get templateTitle202;

  /// No description provided for @templateTitle203.
  ///
  /// In en, this message translates to:
  /// **'Create an emergency situations plan'**
  String get templateTitle203;

  /// No description provided for @templateTitle204.
  ///
  /// In en, this message translates to:
  /// **'Create a medical documentation plan'**
  String get templateTitle204;

  /// No description provided for @templateTitle205.
  ///
  /// In en, this message translates to:
  /// **'Create a prevention plan'**
  String get templateTitle205;

  /// No description provided for @templateTitle206.
  ///
  /// In en, this message translates to:
  /// **'Create a student management plan'**
  String get templateTitle206;

  /// No description provided for @templateTitle207.
  ///
  /// In en, this message translates to:
  /// **'Create a parent engagement plan'**
  String get templateTitle207;

  /// No description provided for @templateTitle208.
  ///
  /// In en, this message translates to:
  /// **'Create an educational materials plan'**
  String get templateTitle208;

  /// No description provided for @templateTitle209.
  ///
  /// In en, this message translates to:
  /// **'Create an extracurricular activities plan'**
  String get templateTitle209;

  /// No description provided for @templateTitle210.
  ///
  /// In en, this message translates to:
  /// **'Create a professional development plan'**
  String get templateTitle210;

  /// No description provided for @templateTitle211.
  ///
  /// In en, this message translates to:
  /// **'Create an inclusive education plan'**
  String get templateTitle211;

  /// No description provided for @templateTitle212.
  ///
  /// In en, this message translates to:
  /// **'Create a digital technologies plan'**
  String get templateTitle212;

  /// No description provided for @templateTitle213.
  ///
  /// In en, this message translates to:
  /// **'Create an education quality assessment plan'**
  String get templateTitle213;

  /// No description provided for @templateTitle214.
  ///
  /// In en, this message translates to:
  /// **'Create a tenant management plan'**
  String get templateTitle214;

  /// No description provided for @templateTitle215.
  ///
  /// In en, this message translates to:
  /// **'Create a maintenance management plan'**
  String get templateTitle215;

  /// No description provided for @templateTitle216.
  ///
  /// In en, this message translates to:
  /// **'Create a legal matters plan'**
  String get templateTitle216;

  /// No description provided for @templateTitle217.
  ///
  /// In en, this message translates to:
  /// **'Create a real estate investment plan'**
  String get templateTitle217;

  /// No description provided for @templateTitle218.
  ///
  /// In en, this message translates to:
  /// **'Create a renovation plan'**
  String get templateTitle218;

  /// No description provided for @templateTitle219.
  ///
  /// In en, this message translates to:
  /// **'Create a utilities management plan'**
  String get templateTitle219;

  /// No description provided for @templateTitle220.
  ///
  /// In en, this message translates to:
  /// **'Create a security plan'**
  String get templateTitle220;

  /// No description provided for @templateTitle221.
  ///
  /// In en, this message translates to:
  /// **'Create a property management plan'**
  String get templateTitle221;

  /// No description provided for @templateTitle222.
  ///
  /// In en, this message translates to:
  /// **'Create a restaurant staff management plan'**
  String get templateTitle222;

  /// No description provided for @templateTitle223.
  ///
  /// In en, this message translates to:
  /// **'Create a sanitary standards plan'**
  String get templateTitle223;

  /// No description provided for @templateTitle224.
  ///
  /// In en, this message translates to:
  /// **'Create a beverages management plan'**
  String get templateTitle224;

  /// No description provided for @templateTitle225.
  ///
  /// In en, this message translates to:
  /// **'Create an events management plan'**
  String get templateTitle225;

  /// No description provided for @templateTitle226.
  ///
  /// In en, this message translates to:
  /// **'Create a delivery plan'**
  String get templateTitle226;

  /// No description provided for @templateTitle227.
  ///
  /// In en, this message translates to:
  /// **'Create an advertising plan'**
  String get templateTitle227;

  /// No description provided for @templateTitle228.
  ///
  /// In en, this message translates to:
  /// **'Create a reviews management plan'**
  String get templateTitle228;

  /// No description provided for @templateTitle229.
  ///
  /// In en, this message translates to:
  /// **'Create a seasonal menu plan'**
  String get templateTitle229;

  /// No description provided for @templateTitle230.
  ///
  /// In en, this message translates to:
  /// **'Create a transport management plan'**
  String get templateTitle230;

  /// No description provided for @templateTitle231.
  ///
  /// In en, this message translates to:
  /// **'Create a customs management plan'**
  String get templateTitle231;

  /// No description provided for @templateTitle232.
  ///
  /// In en, this message translates to:
  /// **'Create a packaging and labeling plan'**
  String get templateTitle232;

  /// No description provided for @templateTitle233.
  ///
  /// In en, this message translates to:
  /// **'Create a returns management plan'**
  String get templateTitle233;

  /// No description provided for @templateTitle234.
  ///
  /// In en, this message translates to:
  /// **'Create an international logistics plan'**
  String get templateTitle234;

  /// No description provided for @templateTitle235.
  ///
  /// In en, this message translates to:
  /// **'Create a courier services plan'**
  String get templateTitle235;

  /// No description provided for @templateTitle236.
  ///
  /// In en, this message translates to:
  /// **'Create a cargo tracking plan'**
  String get templateTitle236;

  /// No description provided for @templateTitle237.
  ///
  /// In en, this message translates to:
  /// **'Create a logistics partners plan'**
  String get templateTitle237;

  /// No description provided for @templateTitle238.
  ///
  /// In en, this message translates to:
  /// **'Create a weekly work report'**
  String get templateTitle238;

  /// No description provided for @templateTitle239.
  ///
  /// In en, this message translates to:
  /// **'Conduct a market analysis'**
  String get templateTitle239;

  /// No description provided for @templateTitle253.
  ///
  /// In en, this message translates to:
  /// **'Create a completed tasks report'**
  String get templateTitle253;

  /// No description provided for @templateTitle254.
  ///
  /// In en, this message translates to:
  /// **'Create a weekly sales report'**
  String get templateTitle254;

  /// No description provided for @templateTitle255.
  ///
  /// In en, this message translates to:
  /// **'Create a team work report'**
  String get templateTitle255;

  /// No description provided for @templateTitle256.
  ///
  /// In en, this message translates to:
  /// **'Create a weekly achievements report'**
  String get templateTitle256;

  /// No description provided for @templateTitle257.
  ///
  /// In en, this message translates to:
  /// **'Create a marketing activities report'**
  String get templateTitle257;

  /// No description provided for @templateTitle258.
  ///
  /// In en, this message translates to:
  /// **'Create a financial indicators report'**
  String get templateTitle258;

  /// No description provided for @templateTitle259.
  ///
  /// In en, this message translates to:
  /// **'Create a client work report'**
  String get templateTitle259;

  /// No description provided for @templateTitle260.
  ///
  /// In en, this message translates to:
  /// **'Create a weekly projects report'**
  String get templateTitle260;

  /// No description provided for @templateTitle261.
  ///
  /// In en, this message translates to:
  /// **'Create a performance report'**
  String get templateTitle261;

  /// No description provided for @templateTitle262.
  ///
  /// In en, this message translates to:
  /// **'Create a problems and solutions report'**
  String get templateTitle262;

  /// No description provided for @templateTitle263.
  ///
  /// In en, this message translates to:
  /// **'Create a next week plans report'**
  String get templateTitle263;

  /// No description provided for @templateTitle264.
  ///
  /// In en, this message translates to:
  /// **'Create a competitor analysis'**
  String get templateTitle264;

  /// No description provided for @templateTitle265.
  ///
  /// In en, this message translates to:
  /// **'Create a target audience analysis'**
  String get templateTitle265;

  /// No description provided for @templateTitle266.
  ///
  /// In en, this message translates to:
  /// **'Conduct an industry trends analysis'**
  String get templateTitle266;

  /// No description provided for @templateTitle267.
  ///
  /// In en, this message translates to:
  /// **'Create a pricing policy analysis'**
  String get templateTitle267;

  /// No description provided for @templateTitle268.
  ///
  /// In en, this message translates to:
  /// **'Create a marketing channels analysis'**
  String get templateTitle268;

  /// No description provided for @templateTitle269.
  ///
  /// In en, this message translates to:
  /// **'Conduct a market segmentation analysis'**
  String get templateTitle269;

  /// No description provided for @templateTitle270.
  ///
  /// In en, this message translates to:
  /// **'Create a product portfolio analysis'**
  String get templateTitle270;

  /// No description provided for @templateTitle271.
  ///
  /// In en, this message translates to:
  /// **'Create a geographic market analysis'**
  String get templateTitle271;

  /// No description provided for @templateTitle272.
  ///
  /// In en, this message translates to:
  /// **'Conduct a consumer behavior analysis'**
  String get templateTitle272;

  /// No description provided for @templateTitle273.
  ///
  /// In en, this message translates to:
  /// **'Create a market opportunities analysis'**
  String get templateTitle273;

  /// No description provided for @templateTitle274.
  ///
  /// In en, this message translates to:
  /// **'Create a market entry barriers analysis'**
  String get templateTitle274;

  /// No description provided for @templateTitle275.
  ///
  /// In en, this message translates to:
  /// **'Conduct a market dynamics analysis'**
  String get templateTitle275;

  /// No description provided for @privacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacyTitle;

  /// No description provided for @privacyHeading.
  ///
  /// In en, this message translates to:
  /// **'Smile AI Privacy Policy'**
  String get privacyHeading;

  /// No description provided for @privacyIntro.
  ///
  /// In en, this message translates to:
  /// **'We respect your privacy and aim to ensure safe use of our application.'**
  String get privacyIntro;

  /// No description provided for @privacySection1Title.
  ///
  /// In en, this message translates to:
  /// **'1. What data we collect'**
  String get privacySection1Title;

  /// No description provided for @privacySection1Body.
  ///
  /// In en, this message translates to:
  /// **'We may receive:\n • messages you send to the chat;\n • profile data (name, business name, email — if provided);\n • technical device data (model, OS, language);\n • usage statistics (anonymous).\n\nWe do not collect data that is not related to the service operation.'**
  String get privacySection1Body;

  /// No description provided for @privacySection2Title.
  ///
  /// In en, this message translates to:
  /// **'2. How we use the data'**
  String get privacySection2Title;

  /// No description provided for @privacySection2Body.
  ///
  /// In en, this message translates to:
  /// **'Data is used only for:\n • generating AI responses,\n • operating app functions,\n • improving stability and quality of the service.\n\nWe do not use your messages to train models.'**
  String get privacySection2Body;

  /// No description provided for @privacySection3Title.
  ///
  /// In en, this message translates to:
  /// **'3. Data sharing with third parties'**
  String get privacySection3Title;

  /// No description provided for @privacySection3Body.
  ///
  /// In en, this message translates to:
  /// **'We do not share data with third-party companies.\nException — technical services (e.g., hosting) that keep the app running and receive only the minimum required information.'**
  String get privacySection3Body;

  /// No description provided for @privacySection4Title.
  ///
  /// In en, this message translates to:
  /// **'4. Storage and security'**
  String get privacySection4Title;

  /// No description provided for @privacySection4Body.
  ///
  /// In en, this message translates to:
  /// **' • Data is transmitted over a secure connection.\n • Modern encryption and protection methods are used.\n • Access to servers is restricted.'**
  String get privacySection4Body;

  /// No description provided for @privacySection5Title.
  ///
  /// In en, this message translates to:
  /// **'5. Data deletion'**
  String get privacySection5Title;

  /// No description provided for @privacySection5Body.
  ///
  /// In en, this message translates to:
  /// **'You can request deletion of all data. After deletion, it cannot be restored.'**
  String get privacySection5Body;

  /// No description provided for @privacySection6Title.
  ///
  /// In en, this message translates to:
  /// **'6. Changes to the policy'**
  String get privacySection6Title;

  /// No description provided for @privacySection6Body.
  ///
  /// In en, this message translates to:
  /// **'We may update the privacy policy. Updates are published in the app.'**
  String get privacySection6Body;

  /// No description provided for @privacySection7Title.
  ///
  /// In en, this message translates to:
  /// **'7. Contacts'**
  String get privacySection7Title;

  /// No description provided for @privacySection7Body.
  ///
  /// In en, this message translates to:
  /// **'For questions: support@smileai.app'**
  String get privacySection7Body;

  /// No description provided for @dataPrivacyIntroTitle.
  ///
  /// In en, this message translates to:
  /// **'Smile AI cares about your privacy.'**
  String get dataPrivacyIntroTitle;

  /// No description provided for @dataPrivacyIntroBody.
  ///
  /// In en, this message translates to:
  /// **'We collect only the minimum information required for the service to work. All data is transmitted over a secure connection and is not used to train global AI models.'**
  String get dataPrivacyIntroBody;

  /// No description provided for @dataPrivacyWhatTitle.
  ///
  /// In en, this message translates to:
  /// **'What we collect:'**
  String get dataPrivacyWhatTitle;

  /// No description provided for @dataPrivacyWhatBody.
  ///
  /// In en, this message translates to:
  /// **'• data you provide yourself — messages, business name, profile settings;\n• technical data — device model, OS version, app language;\n• anonymous usage statistics (optional).'**
  String get dataPrivacyWhatBody;

  /// No description provided for @dataPrivacyWhyTitle.
  ///
  /// In en, this message translates to:
  /// **'Why we need this:'**
  String get dataPrivacyWhyTitle;

  /// No description provided for @dataPrivacyWhyBody.
  ///
  /// In en, this message translates to:
  /// **'• correct operation of the AI chat;\n• improving answer quality in the current dialog;\n• increasing app stability.'**
  String get dataPrivacyWhyBody;

  /// No description provided for @dataPrivacyNoShare.
  ///
  /// In en, this message translates to:
  /// **'We do not share data with third parties, except for technical services required to process requests.'**
  String get dataPrivacyNoShare;

  /// No description provided for @dataPrivacyDelete.
  ///
  /// In en, this message translates to:
  /// **'You can request data deletion at any time.'**
  String get dataPrivacyDelete;

  /// No description provided for @supportTitle.
  ///
  /// In en, this message translates to:
  /// **'Smile Support'**
  String get supportTitle;

  /// No description provided for @supportOnlineStatus.
  ///
  /// In en, this message translates to:
  /// **'Online 24/7'**
  String get supportOnlineStatus;

  /// No description provided for @supportGreetingPrefix.
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get supportGreetingPrefix;

  /// No description provided for @supportDefaultName.
  ///
  /// In en, this message translates to:
  /// **'user'**
  String get supportDefaultName;

  /// No description provided for @supportLabel.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get supportLabel;

  /// No description provided for @faqQuestion1.
  ///
  /// In en, this message translates to:
  /// **'Does Smile AI use my messages for training?'**
  String get faqQuestion1;

  /// No description provided for @faqAnswer1.
  ///
  /// In en, this message translates to:
  /// **'No. Your messages are used only to respond within the current session. We do not store or use your chats to train AI models.'**
  String get faqAnswer1;

  /// No description provided for @faqQuestion2.
  ///
  /// In en, this message translates to:
  /// **'Who can see my chats?'**
  String get faqQuestion2;

  /// No description provided for @faqAnswer2.
  ///
  /// In en, this message translates to:
  /// **'Only you. The team does not have access to your content. Support can see small fragments of messages only if you send them yourself in a request.'**
  String get faqAnswer2;

  /// No description provided for @faqQuestion3.
  ///
  /// In en, this message translates to:
  /// **'What happens if I delete my account?'**
  String get faqQuestion3;

  /// No description provided for @faqAnswer3.
  ///
  /// In en, this message translates to:
  /// **'All data will be permanently deleted: chats, settings, request history. It will not be possible to restore them.'**
  String get faqAnswer3;

  /// No description provided for @faqQuestion4.
  ///
  /// In en, this message translates to:
  /// **'Do you share data with other companies?'**
  String get faqQuestion4;

  /// No description provided for @faqAnswer4.
  ///
  /// In en, this message translates to:
  /// **'No. The only exception is technical services (servers, cloud storage) that work only as infrastructure and do not have access to your content.'**
  String get faqAnswer4;

  /// No description provided for @faqQuestion5.
  ///
  /// In en, this message translates to:
  /// **'How secure is the app?'**
  String get faqQuestion5;

  /// No description provided for @faqAnswer5.
  ///
  /// In en, this message translates to:
  /// **'The connection is encrypted (HTTPS/SSL), data is stored on protected servers, and multi-level security and continuous monitoring are used.'**
  String get faqAnswer5;

  /// No description provided for @chatMenuNewChat.
  ///
  /// In en, this message translates to:
  /// **'New chat'**
  String get chatMenuNewChat;

  /// No description provided for @chatMenuChats.
  ///
  /// In en, this message translates to:
  /// **'Chats'**
  String get chatMenuChats;

  /// No description provided for @chatMenuShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get chatMenuShare;

  /// No description provided for @chatMenuRename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get chatMenuRename;

  /// No description provided for @chatMenuDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get chatMenuDelete;

  /// No description provided for @templatesSectionPopular.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get templatesSectionPopular;

  /// No description provided for @templatesSectionBusinessGoals.
  ///
  /// In en, this message translates to:
  /// **'Business Goals'**
  String get templatesSectionBusinessGoals;

  /// No description provided for @templatesSectionIndustry.
  ///
  /// In en, this message translates to:
  /// **'Industry'**
  String get templatesSectionIndustry;

  /// No description provided for @templatesSectionPersonal.
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get templatesSectionPersonal;

  /// No description provided for @templatesWeeklyReport.
  ///
  /// In en, this message translates to:
  /// **'Weekly Report'**
  String get templatesWeeklyReport;

  /// No description provided for @templatesMarketAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Market Analysis'**
  String get templatesMarketAnalysis;

  /// No description provided for @templatesYourTemplates.
  ///
  /// In en, this message translates to:
  /// **'Your Templates'**
  String get templatesYourTemplates;

  /// No description provided for @templatesYourTemplatesLine1.
  ///
  /// In en, this message translates to:
  /// **'your'**
  String get templatesYourTemplatesLine1;

  /// No description provided for @templatesYourTemplatesLine2.
  ///
  /// In en, this message translates to:
  /// **'templates'**
  String get templatesYourTemplatesLine2;

  /// No description provided for @templatesAddFolder.
  ///
  /// In en, this message translates to:
  /// **'Add Folder'**
  String get templatesAddFolder;

  /// No description provided for @templatesAddNewFolder.
  ///
  /// In en, this message translates to:
  /// **'Add New Folder'**
  String get templatesAddNewFolder;

  /// No description provided for @templatesEnterFolderName.
  ///
  /// In en, this message translates to:
  /// **'Enter folder name'**
  String get templatesEnterFolderName;

  /// No description provided for @templatesAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get templatesAdd;

  /// No description provided for @templatesCategoryMarketing.
  ///
  /// In en, this message translates to:
  /// **'Marketing'**
  String get templatesCategoryMarketing;

  /// No description provided for @templatesCategoryStrategy.
  ///
  /// In en, this message translates to:
  /// **'Strategy'**
  String get templatesCategoryStrategy;

  /// No description provided for @templatesCategorySales.
  ///
  /// In en, this message translates to:
  /// **'Sales'**
  String get templatesCategorySales;

  /// No description provided for @templatesCategoryFinance.
  ///
  /// In en, this message translates to:
  /// **'Finance'**
  String get templatesCategoryFinance;

  /// No description provided for @templatesCategoryHR.
  ///
  /// In en, this message translates to:
  /// **'HR'**
  String get templatesCategoryHR;

  /// No description provided for @templatesCategoryOperations.
  ///
  /// In en, this message translates to:
  /// **'Operations'**
  String get templatesCategoryOperations;

  /// No description provided for @templatesCategorySupport.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get templatesCategorySupport;

  /// No description provided for @templatesCategoryAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get templatesCategoryAnalytics;

  /// No description provided for @templatesCategoryRetail.
  ///
  /// In en, this message translates to:
  /// **'Retail'**
  String get templatesCategoryRetail;

  /// No description provided for @templatesCategoryManufacturing.
  ///
  /// In en, this message translates to:
  /// **'Manufacturing'**
  String get templatesCategoryManufacturing;

  /// No description provided for @templatesCategoryIT.
  ///
  /// In en, this message translates to:
  /// **'IT/Technology'**
  String get templatesCategoryIT;

  /// No description provided for @templatesCategoryHealthcare.
  ///
  /// In en, this message translates to:
  /// **'Healthcare'**
  String get templatesCategoryHealthcare;

  /// No description provided for @templatesCategoryEducation.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get templatesCategoryEducation;

  /// No description provided for @templatesCategoryRealEstate.
  ///
  /// In en, this message translates to:
  /// **'Real Estate'**
  String get templatesCategoryRealEstate;

  /// No description provided for @templatesCategoryRestaurant.
  ///
  /// In en, this message translates to:
  /// **'Restaurant Business'**
  String get templatesCategoryRestaurant;

  /// No description provided for @templatesCategoryLogistics.
  ///
  /// In en, this message translates to:
  /// **'Logistics'**
  String get templatesCategoryLogistics;

  /// Context settings dialog title
  ///
  /// In en, this message translates to:
  /// **'Conversation Context'**
  String get contextTitle;

  /// Context settings dialog description
  ///
  /// In en, this message translates to:
  /// **'Set the context for this conversation to get more relevant answers'**
  String get contextDescription;

  /// User role selection field
  ///
  /// In en, this message translates to:
  /// **'Your role'**
  String get contextUserRole;

  /// Placeholder for role selection
  ///
  /// In en, this message translates to:
  /// **'Select your role'**
  String get contextUserRolePlaceholder;

  /// Business stage selection field
  ///
  /// In en, this message translates to:
  /// **'Business stage'**
  String get contextBusinessStage;

  /// Placeholder for business stage selection
  ///
  /// In en, this message translates to:
  /// **'Select business stage'**
  String get contextBusinessStagePlaceholder;

  /// Goal selection field
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get contextGoal;

  /// Placeholder for goal selection
  ///
  /// In en, this message translates to:
  /// **'Select goal'**
  String get contextGoalPlaceholder;

  /// Urgency selection field
  ///
  /// In en, this message translates to:
  /// **'Urgency'**
  String get contextUrgency;

  /// Placeholder for urgency selection
  ///
  /// In en, this message translates to:
  /// **'Select urgency'**
  String get contextUrgencyPlaceholder;

  /// Region selection field
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get contextRegion;

  /// Placeholder for region selection
  ///
  /// In en, this message translates to:
  /// **'Select region'**
  String get contextRegionPlaceholder;

  /// Business niche selection field
  ///
  /// In en, this message translates to:
  /// **'Business niche'**
  String get contextBusinessNiche;

  /// Placeholder for business niche selection
  ///
  /// In en, this message translates to:
  /// **'Select business niche'**
  String get contextBusinessNichePlaceholder;

  /// Cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get contextCancel;

  /// Save button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get contextSave;

  /// No description provided for @contextUserRoleOwner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get contextUserRoleOwner;

  /// No description provided for @contextUserRoleMarketer.
  ///
  /// In en, this message translates to:
  /// **'Marketer'**
  String get contextUserRoleMarketer;

  /// No description provided for @contextUserRoleAccountant.
  ///
  /// In en, this message translates to:
  /// **'Accountant'**
  String get contextUserRoleAccountant;

  /// No description provided for @contextUserRoleBeginner.
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get contextUserRoleBeginner;

  /// No description provided for @contextBusinessStageStartup.
  ///
  /// In en, this message translates to:
  /// **'Startup'**
  String get contextBusinessStageStartup;

  /// No description provided for @contextBusinessStageStable.
  ///
  /// In en, this message translates to:
  /// **'Stable'**
  String get contextBusinessStageStable;

  /// No description provided for @contextBusinessStageScaling.
  ///
  /// In en, this message translates to:
  /// **'Scaling'**
  String get contextBusinessStageScaling;

  /// No description provided for @contextGoalIncreaseRevenue.
  ///
  /// In en, this message translates to:
  /// **'Increase revenue'**
  String get contextGoalIncreaseRevenue;

  /// No description provided for @contextGoalReduceCosts.
  ///
  /// In en, this message translates to:
  /// **'Reduce costs'**
  String get contextGoalReduceCosts;

  /// No description provided for @contextGoalHireStaff.
  ///
  /// In en, this message translates to:
  /// **'Hire staff'**
  String get contextGoalHireStaff;

  /// No description provided for @contextGoalLaunchAds.
  ///
  /// In en, this message translates to:
  /// **'Launch ads'**
  String get contextGoalLaunchAds;

  /// No description provided for @contextGoalLegalHelp.
  ///
  /// In en, this message translates to:
  /// **'Legal help'**
  String get contextGoalLegalHelp;

  /// No description provided for @contextUrgencyUrgent.
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get contextUrgencyUrgent;

  /// No description provided for @contextUrgencyNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get contextUrgencyNormal;

  /// No description provided for @contextUrgencyPlanning.
  ///
  /// In en, this message translates to:
  /// **'Planning'**
  String get contextUrgencyPlanning;

  /// No description provided for @contextBusinessNicheRetail.
  ///
  /// In en, this message translates to:
  /// **'Retail'**
  String get contextBusinessNicheRetail;

  /// No description provided for @contextBusinessNicheServices.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get contextBusinessNicheServices;

  /// No description provided for @contextBusinessNicheFoodService.
  ///
  /// In en, this message translates to:
  /// **'Food service'**
  String get contextBusinessNicheFoodService;

  /// No description provided for @contextBusinessNicheManufacturing.
  ///
  /// In en, this message translates to:
  /// **'Manufacturing'**
  String get contextBusinessNicheManufacturing;

  /// No description provided for @contextBusinessNicheOnlineServices.
  ///
  /// In en, this message translates to:
  /// **'Online services'**
  String get contextBusinessNicheOnlineServices;

  /// No description provided for @contextRegionRussia.
  ///
  /// In en, this message translates to:
  /// **'Russia'**
  String get contextRegionRussia;

  /// No description provided for @contextRegionAmerica.
  ///
  /// In en, this message translates to:
  /// **'America'**
  String get contextRegionAmerica;

  /// No description provided for @contextRegionBritain.
  ///
  /// In en, this message translates to:
  /// **'Britain'**
  String get contextRegionBritain;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'ru': return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
