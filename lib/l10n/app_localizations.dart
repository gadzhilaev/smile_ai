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
  /// **'A code has been sent to your email to\nconfirm registration'**
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
