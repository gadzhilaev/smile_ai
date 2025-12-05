// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Smile AI';

  @override
  String get navAi => 'AI';

  @override
  String get navTemplates => 'Templates';

  @override
  String get navAnalytics => 'Analytics';

  @override
  String get navProfile => 'Profile';

  @override
  String get templatesTitle => 'Templates';

  @override
  String get templatesEmpty => 'No templates found';

  @override
  String get analyticsTitle => 'Top trends of the week';

  @override
  String get analyticsTrend1 => 'Top trend';

  @override
  String get analyticsTrendDeltaDescription => 'Engagement has increased this much compared to last week';

  @override
  String get analytics7Days => '7 days';

  @override
  String get analyticsWhy => 'Why?';

  @override
  String get analyticsThisWeek => 'This week';

  @override
  String analyticsCategoryTakes(Object percentage) {
    return 'Category takes $percentage% of all requests';
  }

  @override
  String get analyticsCategoryTakesPlaceholder => 'percentage';

  @override
  String get analyticsSecondPlace => '2nd place';

  @override
  String get analyticsAiAnalytics => 'AI Analytics';

  @override
  String analyticsWasAdded(Object percentage) {
    return '$percentage% was added';
  }

  @override
  String get analyticsWasAddedPlaceholder => 'percentage';

  @override
  String get analyticsCompetitivenessLevel => 'Competitiveness Level';

  @override
  String get analyticsBasedOnAi => 'Based on AI';

  @override
  String get analyticsMonthNiches => 'Month Niches';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileMenuAccount => 'Account';

  @override
  String get profileMenuNotifications => 'Notifications';

  @override
  String get profileMenuLanguage => 'Language';

  @override
  String get profileMenuPrivacy => 'Data and privacy';

  @override
  String get profileMenuTheme => 'Theme';

  @override
  String get profileMenuSupport => 'Support';

  @override
  String get profileMenuFaq => 'FAQ';

  @override
  String get profileMenuPolicy => 'Privacy policy';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsSectionGeneral => 'General';

  @override
  String get notificationsSectionSystem => 'System notifications';

  @override
  String get notificationsAll => 'All notifications';

  @override
  String get notificationsSound => 'Sound';

  @override
  String get notificationsVibration => 'Vibration';

  @override
  String get notificationsUpdates => 'Updates';

  @override
  String get notificationsPromotions => 'Promotions';

  @override
  String get languageTitle => 'Language';

  @override
  String get languageSectionSuggested => 'Suggested';

  @override
  String get languageRussian => 'Русский';

  @override
  String get languageEnglish => 'English';

  @override
  String get aiGreeting => 'Hi, you can ask me anything';

  @override
  String get aiSuggestionsTitle => 'Maybe these prompts will help you...';

  @override
  String get aiSuggestion1 => 'Hello';

  @override
  String get aiSuggestion2 => 'How are you?';

  @override
  String get aiSuggestion3 => 'What can you do?';

  @override
  String get aiSuggestion4 => 'Ask me something';

  @override
  String get aiSuggestion5 => 'Help me';

  @override
  String get aiSuggestion6 => 'Advice';

  @override
  String get aiStopGeneration => 'Stop generation...';

  @override
  String get aiInputPlaceholder => 'Enter your question...';

  @override
  String get aiRecognizingSpeech => 'Recognizing speech...';

  @override
  String get analyticsCategoryGrowing => 'Rising';

  @override
  String get analyticsCategoryFalling => 'Falling';

  @override
  String get templateApply => 'Apply template';

  @override
  String get templateEdit => 'Edit';

  @override
  String get themeTitle => 'Theme';

  @override
  String get themeSystem => 'Use system';

  @override
  String get themeLight => 'Light theme';

  @override
  String get themeDark => 'Dark theme';

  @override
  String get authEmailTitle => 'Enter your email';

  @override
  String get authEmailHint => 'Email';

  @override
  String get authEmailErrorInvalid => 'Enter a valid email';

  @override
  String get authEmailErrorNotRegistered => 'This email is not registered';

  @override
  String get authButtonLogin => 'LOG IN';

  @override
  String get authNoAccount => 'Don’t have an account? ';

  @override
  String get authRegister => 'Sign up';

  @override
  String get authPasswordHint => 'Password';

  @override
  String get authPasswordErrorWrong => 'Incorrect password';

  @override
  String get authRegisterPlaceholder => 'Registration screen will be here';

  @override
  String get authRegisterTitle => 'Registration';

  @override
  String get authHasAccount => 'Have an account? ';

  @override
  String get authLogin => 'Log in';

  @override
  String get authButtonContinue => 'CONTINUE';

  @override
  String get authEmailAlreadyRegistered => 'This email is already registered';

  @override
  String get authCodeTitle => 'Code';

  @override
  String get authCodeMessage => 'A code has been sent to your email to\nconfirm registration 1111';

  @override
  String get authCodeErrorWrong => 'Incorrect code';

  @override
  String get authPasswordCreateTitle => 'Create';

  @override
  String get authPasswordCreateSubtitle => 'password';

  @override
  String get authPasswordConfirm => 'Password';

  @override
  String get authPasswordErrorTooShort => 'Password must be at least 8 characters';

  @override
  String get authPasswordErrorMismatch => 'Passwords do not match';

  @override
  String get authFillDataTitle => 'Fill in data';

  @override
  String get authPasswordWeakTitle => 'Your password is too weak';

  @override
  String get authPasswordWeakMessage => 'Are you sure you want to use it?';

  @override
  String get authPasswordWeakChange => 'Change';

  @override
  String get authPasswordWeakContinue => 'Continue';

  @override
  String get authSaveButton => 'Save';

  @override
  String get authFieldFullName => 'Full name';

  @override
  String get authFieldNickname => 'Nickname';

  @override
  String get authFieldEmail => 'Email';

  @override
  String get authFieldPhone => 'Phone number';

  @override
  String get authFieldCountry => 'Country';

  @override
  String get authFieldGender => 'Gender';

  @override
  String get authCountryRussia => 'Russia';

  @override
  String get authCountryKazakhstan => 'Kazakhstan';

  @override
  String get authCountryBelarus => 'Belarus';

  @override
  String get authGenderMale => 'Male';

  @override
  String get authGenderFemale => 'Female';

  @override
  String get authNicknameError => 'Only English letters, numbers and special characters';

  @override
  String get accountEditProfileTitle => 'Edit Profile';

  @override
  String get aiCopyToast => 'Text copied';

  @override
  String get templateCategoryMarketing => 'Marketing';

  @override
  String get templateCategorySales => 'Sales';

  @override
  String get templateCategoryStrategy => 'Strategy';

  @override
  String get templateCategorySupport => 'Support';

  @override
  String get templateCategoryStaff => 'Team';

  @override
  String get templateCategoryAnalytics => 'Analytics';

  @override
  String get templateTitle0 => 'Create a high-converting social media post';

  @override
  String get templateTitle1 => 'Write an attractive product description for a catalog';

  @override
  String get templateTitle2 => 'Create an ad text up to 150 characters';

  @override
  String get templateTitle3 => 'Come up with an idea for a viral Reels or TikTok';

  @override
  String get templateTitle4 => 'Create an email newsletter text for clients';

  @override
  String get templateTitle5 => 'Make a weekly content plan for a business';

  @override
  String get templateTitle6 => 'Create a call script for selling a service';

  @override
  String get templateTitle7 => 'Prepare answers to typical client objections';

  @override
  String get templateTitle8 => 'Write a short commercial proposal';

  @override
  String get templateTitle9 => 'Write effective chat message text for a client';

  @override
  String get templateTitle10 => 'Prepare a closing phrase to finalize a deal';

  @override
  String get templateTitle11 => 'Create a short cold message for first contact';

  @override
  String get templateTitle12 => 'Make a 3-month business growth plan';

  @override
  String get templateTitle13 => 'Make a brief analysis of main competitors';

  @override
  String get templateTitle14 => 'Suggest ideas to expand the service line';

  @override
  String get templateTitle15 => 'Create a SWOT analysis for the company';

  @override
  String get templateTitle16 => 'Suggest a strategy to increase profit';

  @override
  String get templateTitle17 => 'Formulate a unique selling proposition';

  @override
  String get templateTitle18 => 'Write a polite reply to an unhappy client';

  @override
  String get templateTitle19 => 'Write a correct message about a delay';

  @override
  String get templateTitle20 => 'Create an order confirmation message';

  @override
  String get templateTitle21 => 'Write usage instructions for a product';

  @override
  String get templateTitle22 => 'Create a proper apology message';

  @override
  String get templateTitle23 => 'Write a professional reply to a client question';

  @override
  String get templateTitle24 => 'Give constructive feedback to an employee';

  @override
  String get templateTitle25 => 'Create a short announcement for the team';

  @override
  String get templateTitle26 => 'Write a motivational message for employees';

  @override
  String get templateTitle27 => 'Make a daily task list for an employee';

  @override
  String get templateTitle28 => 'Create a set of corporate rules';

  @override
  String get templateTitle29 => 'Write an attractive job vacancy text';

  @override
  String get templateTitle30 => 'Make a brief sales analysis';

  @override
  String get templateTitle31 => 'Create a weekly performance report';

  @override
  String get templateTitle32 => 'Evaluate an ad campaign’s effectiveness';

  @override
  String get templateTitle33 => 'Make a demand forecast';

  @override
  String get templateTitle34 => 'Analyze the weak points of the business';

  @override
  String get templateTitle35 => 'Give recommendations to improve business performance';

  @override
  String get templateTitle36 => 'Create a conversion report';

  @override
  String get templateTitle37 => 'Analyze customer behavior';

  @override
  String get templateTitle38 => 'Create a quarterly financial plan';

  @override
  String get templateTitle39 => 'Calculate the break-even point';

  @override
  String get templateTitle40 => 'Create a monthly budget';

  @override
  String get templateTitle41 => 'Analyze company expenses';

  @override
  String get templateTitle42 => 'Create a cost optimization plan';

  @override
  String get templateTitle43 => 'Calculate project profitability';

  @override
  String get templateTitle44 => 'Create a financial report';

  @override
  String get templateTitle45 => 'Create a job description';

  @override
  String get templateTitle46 => 'Create a new employee onboarding plan';

  @override
  String get templateTitle47 => 'Create an employee training plan';

  @override
  String get templateTitle48 => 'Create a performance evaluation system';

  @override
  String get templateTitle49 => 'Write a team development plan';

  @override
  String get templateTitle50 => 'Create a staff motivation program';

  @override
  String get templateTitle51 => 'Optimize work processes';

  @override
  String get templateTitle52 => 'Create a quality improvement plan';

  @override
  String get templateTitle53 => 'Create a quality control system';

  @override
  String get templateTitle54 => 'Create a logistics plan';

  @override
  String get templateTitle55 => 'Optimize the supply chain';

  @override
  String get templateTitle56 => 'Create work standards';

  @override
  String get templateTitle57 => 'Create a merchandising plan';

  @override
  String get templateTitle58 => 'Create a pricing strategy';

  @override
  String get templateTitle59 => 'Create a promotions and discounts plan';

  @override
  String get templateTitle60 => 'Optimize product display';

  @override
  String get templateTitle61 => 'Create a supplier management plan';

  @override
  String get templateTitle62 => 'Create an inventory management system';

  @override
  String get templateTitle63 => 'Optimize the production process';

  @override
  String get templateTitle64 => 'Create a quality control plan';

  @override
  String get templateTitle65 => 'Create a production management system';

  @override
  String get templateTitle66 => 'Create a maintenance plan';

  @override
  String get templateTitle67 => 'Optimize resource usage';

  @override
  String get templateTitle68 => 'Create a production safety plan';

  @override
  String get templateTitle69 => 'Create technical specifications';

  @override
  String get templateTitle70 => 'Create a product development plan';

  @override
  String get templateTitle71 => 'Create a testing plan';

  @override
  String get templateTitle72 => 'Create project documentation';

  @override
  String get templateTitle73 => 'Create a system implementation plan';

  @override
  String get templateTitle74 => 'Create a technical support plan';

  @override
  String get templateTitle75 => 'Create a patient treatment plan';

  @override
  String get templateTitle76 => 'Create a medical procedure protocol';

  @override
  String get templateTitle77 => 'Create a preventive measures plan';

  @override
  String get templateTitle78 => 'Create a medical records management system';

  @override
  String get templateTitle79 => 'Create a patient management plan';

  @override
  String get templateTitle80 => 'Create a service quality improvement plan';

  @override
  String get templateTitle81 => 'Create a curriculum';

  @override
  String get templateTitle82 => 'Create a lesson plan';

  @override
  String get templateTitle83 => 'Create a training program';

  @override
  String get templateTitle84 => 'Create a knowledge assessment system';

  @override
  String get templateTitle85 => 'Create a parent engagement plan';

  @override
  String get templateTitle86 => 'Create an educational institution development plan';

  @override
  String get templateTitle87 => 'Create a real estate property description';

  @override
  String get templateTitle88 => 'Create a property presentation plan';

  @override
  String get templateTitle89 => 'Create a client management plan';

  @override
  String get templateTitle90 => 'Create a property management system';

  @override
  String get templateTitle91 => 'Create a real estate marketing plan';

  @override
  String get templateTitle92 => 'Create a real estate appraisal plan';

  @override
  String get templateTitle93 => 'Create a restaurant menu';

  @override
  String get templateTitle94 => 'Create a kitchen operations plan';

  @override
  String get templateTitle95 => 'Create a guest service plan';

  @override
  String get templateTitle96 => 'Create an order management system';

  @override
  String get templateTitle97 => 'Create a restaurant marketing plan';

  @override
  String get templateTitle98 => 'Create a supplier management plan';

  @override
  String get templateTitle99 => 'Optimize delivery routes';

  @override
  String get templateTitle100 => 'Create a warehouse logistics plan';

  @override
  String get templateTitle101 => 'Create a transport management system';

  @override
  String get templateTitle102 => 'Create a carrier management plan';

  @override
  String get templateTitle103 => 'Create an inventory management plan';

  @override
  String get templateTitle104 => 'Optimize the supply chain';

  @override
  String get templateTitle105 => 'Create an attractive article headline';

  @override
  String get templateTitle106 => 'Write a landing page description';

  @override
  String get templateTitle107 => 'Create a product launch plan';

  @override
  String get templateTitle108 => 'Create a banner text';

  @override
  String get templateTitle109 => 'Come up with a brand slogan';

  @override
  String get templateTitle110 => 'Create an influencer collaboration plan';

  @override
  String get templateTitle111 => 'Create a push notification text';

  @override
  String get templateTitle112 => 'Write a YouTube video description';

  @override
  String get templateTitle113 => 'Create a sales funnel plan';

  @override
  String get templateTitle114 => 'Create a client presentation';

  @override
  String get templateTitle115 => 'Write a follow-up email text';

  @override
  String get templateTitle116 => 'Create a deferred deals management plan';

  @override
  String get templateTitle117 => 'Create a sales team motivation system';

  @override
  String get templateTitle118 => 'Write a discount offer text';

  @override
  String get templateTitle119 => 'Create a loyal customer management plan';

  @override
  String get templateTitle120 => 'Create a script for handling objections';

  @override
  String get templateTitle121 => 'Create a long-term development strategy';

  @override
  String get templateTitle122 => 'Create a market entry plan';

  @override
  String get templateTitle123 => 'Create a business diversification plan';

  @override
  String get templateTitle124 => 'Create a brand positioning strategy';

  @override
  String get templateTitle125 => 'Create a partnership plan with other companies';

  @override
  String get templateTitle126 => 'Create a business scaling plan';

  @override
  String get templateTitle127 => 'Create a crisis management plan';

  @override
  String get templateTitle128 => 'Create a seasonality strategy';

  @override
  String get templateTitle129 => 'Create a FAQ response template';

  @override
  String get templateTitle130 => 'Create a complaint management plan';

  @override
  String get templateTitle131 => 'Write a problem resolution message';

  @override
  String get templateTitle132 => 'Create a support quality evaluation system';

  @override
  String get templateTitle133 => 'Create a support staff training plan';

  @override
  String get templateTitle134 => 'Write a knowledge base text';

  @override
  String get templateTitle135 => 'Create a customer feedback management plan';

  @override
  String get templateTitle136 => 'Create an after-hours work plan';

  @override
  String get templateTitle137 => 'Create an interview plan';

  @override
  String get templateTitle138 => 'Create an employee evaluation system';

  @override
  String get templateTitle139 => 'Create a team building plan';

  @override
  String get templateTitle140 => 'Write an employee career development plan';

  @override
  String get templateTitle141 => 'Create a team conflict management plan';

  @override
  String get templateTitle142 => 'Create a talent retention plan';

  @override
  String get templateTitle143 => 'Create a mentoring system';

  @override
  String get templateTitle144 => 'Create a corporate events plan';

  @override
  String get templateTitle145 => 'Create a key metrics dashboard';

  @override
  String get templateTitle146 => 'Analyze the effectiveness of acquisition channels';

  @override
  String get templateTitle147 => 'Create a marketing campaigns ROI report';

  @override
  String get templateTitle148 => 'Create a customer lifecycle analysis';

  @override
  String get templateTitle149 => 'Analyze seasonal trends';

  @override
  String get templateTitle150 => 'Create a competitive analysis';

  @override
  String get templateTitle151 => 'Create an investment plan';

  @override
  String get templateTitle152 => 'Create a cash flow management system';

  @override
  String get templateTitle153 => 'Create a credit management plan';

  @override
  String get templateTitle154 => 'Create an expense control system';

  @override
  String get templateTitle155 => 'Create a tax planning plan';

  @override
  String get templateTitle156 => 'Create a financial indicators forecast';

  @override
  String get templateTitle157 => 'Create an accounts receivable management plan';

  @override
  String get templateTitle158 => 'Create a new employee onboarding plan';

  @override
  String get templateTitle159 => 'Create a compensation and benefits system';

  @override
  String get templateTitle160 => 'Create an employee termination plan';

  @override
  String get templateTitle161 => 'Create a leadership development plan';

  @override
  String get templateTitle162 => 'Create an employee feedback system';

  @override
  String get templateTitle163 => 'Create a remote employee management plan';

  @override
  String get templateTitle164 => 'Create an internal communications plan';

  @override
  String get templateTitle165 => 'Create a productivity plan';

  @override
  String get templateTitle166 => 'Create a process automation plan';

  @override
  String get templateTitle167 => 'Create a risk management system';

  @override
  String get templateTitle168 => 'Create a supplier management plan';

  @override
  String get templateTitle169 => 'Create an inventory management plan';

  @override
  String get templateTitle170 => 'Create a documentation management plan';

  @override
  String get templateTitle171 => 'Create a process monitoring system';

  @override
  String get templateTitle172 => 'Create an incident management plan';

  @override
  String get templateTitle173 => 'Create a continuous improvement plan';

  @override
  String get templateTitle174 => 'Create a customer management plan';

  @override
  String get templateTitle175 => 'Create a returns management plan';

  @override
  String get templateTitle176 => 'Create a seasonal products management plan';

  @override
  String get templateTitle177 => 'Create a promo codes system';

  @override
  String get templateTitle178 => 'Create an online sales plan';

  @override
  String get templateTitle179 => 'Create a loyalty programs plan';

  @override
  String get templateTitle180 => 'Create a storefront management plan';

  @override
  String get templateTitle181 => 'Create a store staff management plan';

  @override
  String get templateTitle182 => 'Create an equipment management plan';

  @override
  String get templateTitle183 => 'Create a production plan management system';

  @override
  String get templateTitle184 => 'Create a defect management plan';

  @override
  String get templateTitle185 => 'Create an energy efficiency plan';

  @override
  String get templateTitle186 => 'Create an environmental management plan';

  @override
  String get templateTitle187 => 'Create an innovation plan';

  @override
  String get templateTitle188 => 'Create a certification plan';

  @override
  String get templateTitle189 => 'Create a packaging plan';

  @override
  String get templateTitle190 => 'Create a data security plan';

  @override
  String get templateTitle191 => 'Create a cloud services plan';

  @override
  String get templateTitle192 => 'Create an API management plan';

  @override
  String get templateTitle193 => 'Create a DevOps plan';

  @override
  String get templateTitle194 => 'Create a mobile applications plan';

  @override
  String get templateTitle195 => 'Create an artificial intelligence plan';

  @override
  String get templateTitle196 => 'Create a cybersecurity plan';

  @override
  String get templateTitle197 => 'Create an automation plan';

  @override
  String get templateTitle198 => 'Create a patient management plan';

  @override
  String get templateTitle199 => 'Create a medical equipment management plan';

  @override
  String get templateTitle200 => 'Create a medication management plan';

  @override
  String get templateTitle201 => 'Create a medical staff management plan';

  @override
  String get templateTitle202 => 'Create a sanitary standards plan';

  @override
  String get templateTitle203 => 'Create an emergency situations plan';

  @override
  String get templateTitle204 => 'Create a medical documentation plan';

  @override
  String get templateTitle205 => 'Create a prevention plan';

  @override
  String get templateTitle206 => 'Create a student management plan';

  @override
  String get templateTitle207 => 'Create a parent engagement plan';

  @override
  String get templateTitle208 => 'Create an educational materials plan';

  @override
  String get templateTitle209 => 'Create an extracurricular activities plan';

  @override
  String get templateTitle210 => 'Create a professional development plan';

  @override
  String get templateTitle211 => 'Create an inclusive education plan';

  @override
  String get templateTitle212 => 'Create a digital technologies plan';

  @override
  String get templateTitle213 => 'Create an education quality assessment plan';

  @override
  String get templateTitle214 => 'Create a tenant management plan';

  @override
  String get templateTitle215 => 'Create a maintenance management plan';

  @override
  String get templateTitle216 => 'Create a legal matters plan';

  @override
  String get templateTitle217 => 'Create a real estate investment plan';

  @override
  String get templateTitle218 => 'Create a renovation plan';

  @override
  String get templateTitle219 => 'Create a utilities management plan';

  @override
  String get templateTitle220 => 'Create a security plan';

  @override
  String get templateTitle221 => 'Create a property management plan';

  @override
  String get templateTitle222 => 'Create a restaurant staff management plan';

  @override
  String get templateTitle223 => 'Create a sanitary standards plan';

  @override
  String get templateTitle224 => 'Create a beverages management plan';

  @override
  String get templateTitle225 => 'Create an events management plan';

  @override
  String get templateTitle226 => 'Create a delivery plan';

  @override
  String get templateTitle227 => 'Create an advertising plan';

  @override
  String get templateTitle228 => 'Create a reviews management plan';

  @override
  String get templateTitle229 => 'Create a seasonal menu plan';

  @override
  String get templateTitle230 => 'Create a transport management plan';

  @override
  String get templateTitle231 => 'Create a customs management plan';

  @override
  String get templateTitle232 => 'Create a packaging and labeling plan';

  @override
  String get templateTitle233 => 'Create a returns management plan';

  @override
  String get templateTitle234 => 'Create an international logistics plan';

  @override
  String get templateTitle235 => 'Create a courier services plan';

  @override
  String get templateTitle236 => 'Create a cargo tracking plan';

  @override
  String get templateTitle237 => 'Create a logistics partners plan';

  @override
  String get templateTitle238 => 'Create a weekly work report';

  @override
  String get templateTitle239 => 'Conduct a market analysis';

  @override
  String get templateTitle253 => 'Create a completed tasks report';

  @override
  String get templateTitle254 => 'Create a weekly sales report';

  @override
  String get templateTitle255 => 'Create a team work report';

  @override
  String get templateTitle256 => 'Create a weekly achievements report';

  @override
  String get templateTitle257 => 'Create a marketing activities report';

  @override
  String get templateTitle258 => 'Create a financial indicators report';

  @override
  String get templateTitle259 => 'Create a client work report';

  @override
  String get templateTitle260 => 'Create a weekly projects report';

  @override
  String get templateTitle261 => 'Create a performance report';

  @override
  String get templateTitle262 => 'Create a problems and solutions report';

  @override
  String get templateTitle263 => 'Create a next week plans report';

  @override
  String get templateTitle264 => 'Create a competitor analysis';

  @override
  String get templateTitle265 => 'Create a target audience analysis';

  @override
  String get templateTitle266 => 'Conduct an industry trends analysis';

  @override
  String get templateTitle267 => 'Create a pricing policy analysis';

  @override
  String get templateTitle268 => 'Create a marketing channels analysis';

  @override
  String get templateTitle269 => 'Conduct a market segmentation analysis';

  @override
  String get templateTitle270 => 'Create a product portfolio analysis';

  @override
  String get templateTitle271 => 'Create a geographic market analysis';

  @override
  String get templateTitle272 => 'Conduct a consumer behavior analysis';

  @override
  String get templateTitle273 => 'Create a market opportunities analysis';

  @override
  String get templateTitle274 => 'Create a market entry barriers analysis';

  @override
  String get templateTitle275 => 'Conduct a market dynamics analysis';

  @override
  String get privacyTitle => 'Privacy policy';

  @override
  String get privacyHeading => 'Smile AI Privacy Policy';

  @override
  String get privacyIntro => 'We respect your privacy and aim to ensure safe use of our application.';

  @override
  String get privacySection1Title => '1. What data we collect';

  @override
  String get privacySection1Body => 'We may receive:\n • messages you send to the chat;\n • profile data (name, business name, email — if provided);\n • technical device data (model, OS, language);\n • usage statistics (anonymous).\n\nWe do not collect data that is not related to the service operation.';

  @override
  String get privacySection2Title => '2. How we use the data';

  @override
  String get privacySection2Body => 'Data is used only for:\n • generating AI responses,\n • operating app functions,\n • improving stability and quality of the service.\n\nWe do not use your messages to train models.';

  @override
  String get privacySection3Title => '3. Data sharing with third parties';

  @override
  String get privacySection3Body => 'We do not share data with third-party companies.\nException — technical services (e.g., hosting) that keep the app running and receive only the minimum required information.';

  @override
  String get privacySection4Title => '4. Storage and security';

  @override
  String get privacySection4Body => ' • Data is transmitted over a secure connection.\n • Modern encryption and protection methods are used.\n • Access to servers is restricted.';

  @override
  String get privacySection5Title => '5. Data deletion';

  @override
  String get privacySection5Body => 'You can request deletion of all data. After deletion, it cannot be restored.';

  @override
  String get privacySection6Title => '6. Changes to the policy';

  @override
  String get privacySection6Body => 'We may update the privacy policy. Updates are published in the app.';

  @override
  String get privacySection7Title => '7. Contacts';

  @override
  String get privacySection7Body => 'For questions: support@smileai.app';

  @override
  String get dataPrivacyIntroTitle => 'Smile AI cares about your privacy.';

  @override
  String get dataPrivacyIntroBody => 'We collect only the minimum information required for the service to work. All data is transmitted over a secure connection and is not used to train global AI models.';

  @override
  String get dataPrivacyWhatTitle => 'What we collect:';

  @override
  String get dataPrivacyWhatBody => '• data you provide yourself — messages, business name, profile settings;\n• technical data — device model, OS version, app language;\n• anonymous usage statistics (optional).';

  @override
  String get dataPrivacyWhyTitle => 'Why we need this:';

  @override
  String get dataPrivacyWhyBody => '• correct operation of the AI chat;\n• improving answer quality in the current dialog;\n• increasing app stability.';

  @override
  String get dataPrivacyNoShare => 'We do not share data with third parties, except for technical services required to process requests.';

  @override
  String get dataPrivacyDelete => 'You can request data deletion at any time.';

  @override
  String get supportTitle => 'Smile Support';

  @override
  String get supportOnlineStatus => 'Online 24/7';

  @override
  String get supportGreetingPrefix => 'Hello';

  @override
  String get supportDefaultName => 'user';

  @override
  String get supportLabel => 'Support';

  @override
  String get faqQuestion1 => 'Does Smile AI use my messages for training?';

  @override
  String get faqAnswer1 => 'No. Your messages are used only to respond within the current session. We do not store or use your chats to train AI models.';

  @override
  String get faqQuestion2 => 'Who can see my chats?';

  @override
  String get faqAnswer2 => 'Only you. The team does not have access to your content. Support can see small fragments of messages only if you send them yourself in a request.';

  @override
  String get faqQuestion3 => 'What happens if I delete my account?';

  @override
  String get faqAnswer3 => 'All data will be permanently deleted: chats, settings, request history. It will not be possible to restore them.';

  @override
  String get faqQuestion4 => 'Do you share data with other companies?';

  @override
  String get faqAnswer4 => 'No. The only exception is technical services (servers, cloud storage) that work only as infrastructure and do not have access to your content.';

  @override
  String get faqQuestion5 => 'How secure is the app?';

  @override
  String get faqAnswer5 => 'The connection is encrypted (HTTPS/SSL), data is stored on protected servers, and multi-level security and continuous monitoring are used.';

  @override
  String get chatMenuNewChat => 'New chat';

  @override
  String get chatMenuChats => 'Chats';

  @override
  String get chatMenuShare => 'Share';

  @override
  String get chatMenuRename => 'Rename';

  @override
  String get chatMenuDelete => 'Delete';

  @override
  String get templatesSectionPopular => 'Popular';

  @override
  String get templatesSectionBusinessGoals => 'Business Goals';

  @override
  String get templatesSectionIndustry => 'Industry';

  @override
  String get templatesSectionPersonal => 'Personal';

  @override
  String get templatesWeeklyReport => 'Weekly Report';

  @override
  String get templatesMarketAnalysis => 'Market Analysis';

  @override
  String get templatesYourTemplates => 'Your Templates';

  @override
  String get templatesYourTemplatesLine1 => 'your';

  @override
  String get templatesYourTemplatesLine2 => 'templates';

  @override
  String get templatesAddFolder => 'Add Folder';

  @override
  String get templatesAddNewFolder => 'Add New Folder';

  @override
  String get templatesEnterFolderName => 'Enter folder name';

  @override
  String get templatesAdd => 'Add';

  @override
  String get templatesCategoryMarketing => 'Marketing';

  @override
  String get templatesCategoryStrategy => 'Strategy';

  @override
  String get templatesCategorySales => 'Sales';

  @override
  String get templatesCategoryFinance => 'Finance';

  @override
  String get templatesCategoryHR => 'HR';

  @override
  String get templatesCategoryOperations => 'Operations';

  @override
  String get templatesCategorySupport => 'Support';

  @override
  String get templatesCategoryAnalytics => 'Analytics';

  @override
  String get templatesCategoryRetail => 'Retail';

  @override
  String get templatesCategoryManufacturing => 'Manufacturing';

  @override
  String get templatesCategoryIT => 'IT/Technology';

  @override
  String get templatesCategoryHealthcare => 'Healthcare';

  @override
  String get templatesCategoryEducation => 'Education';

  @override
  String get templatesCategoryRealEstate => 'Real Estate';

  @override
  String get templatesCategoryRestaurant => 'Restaurant Business';

  @override
  String get templatesCategoryLogistics => 'Logistics';
}
