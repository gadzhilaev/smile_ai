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

  /// No description provided for @aiCopyToast.
  ///
  /// In en, this message translates to:
  /// **'Text copied'**
  String get aiCopyToast;
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
