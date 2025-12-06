// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Smile AI';

  @override
  String get navAi => 'AI';

  @override
  String get navTemplates => 'Шаблоны';

  @override
  String get navAnalytics => 'Аналитика';

  @override
  String get navProfile => 'Профиль';

  @override
  String get templatesTitle => 'Шаблоны';

  @override
  String get templatesEmpty => 'Шаблоны не найдены';

  @override
  String get analyticsTitle => 'Топ направлений недели';

  @override
  String get analyticsTrend1 => 'Тренд №1';

  @override
  String get analyticsTrendDeltaDescription => 'на столько  увеличилась вовлеченность\nпо сравнению с прошлой неделей';

  @override
  String get analytics7Days => '7 дн';

  @override
  String get analyticsWhy => 'Почему?';

  @override
  String get analyticsThisWeek => 'Эта неделя';

  @override
  String analyticsCategoryTakes(Object percentage) {
    return 'Категория занимает $percentage% всех запросов';
  }

  @override
  String get analyticsCategoryTakesPlaceholder => 'percentage';

  @override
  String get analyticsSecondPlace => '2-е место';

  @override
  String get analyticsAiAnalytics => 'ИИ-аналитика';

  @override
  String analyticsWasAdded(Object percentage) {
    return 'Было прибавлено $percentage%';
  }

  @override
  String get analyticsWasAddedPlaceholder => 'percentage';

  @override
  String get analyticsCompetitivenessLevel => 'Уровень конкурентности';

  @override
  String get analyticsBasedOnAi => 'Основано на ИИ';

  @override
  String get analyticsMonthNiches => 'Ниши месяца';

  @override
  String get profileTitle => 'Профиль';

  @override
  String get profileMenuAccount => 'Учетная запись';

  @override
  String get profileMenuNotifications => 'Уведомления';

  @override
  String get profileMenuLanguage => 'Язык';

  @override
  String get profileMenuPrivacy => 'Данные и конфиденциальность';

  @override
  String get profileMenuTheme => 'Тема';

  @override
  String get profileMenuSupport => 'Поддержка';

  @override
  String get profileMenuFaq => 'Часто задаваемые вопросы';

  @override
  String get profileMenuPolicy => 'Политика конфиденциальности';

  @override
  String get notificationsTitle => 'Уведомления';

  @override
  String get notificationsSectionGeneral => 'Общие';

  @override
  String get notificationsSectionSystem => 'Системные уведомления';

  @override
  String get notificationsAll => 'Все уведомления';

  @override
  String get notificationsSound => 'Звук';

  @override
  String get notificationsVibration => 'Вибрация';

  @override
  String get notificationsUpdates => 'Обновления';

  @override
  String get notificationsPromotions => 'Продвижение';

  @override
  String get languageTitle => 'Язык';

  @override
  String get languageSectionSuggested => 'Предложенные';

  @override
  String get languageRussian => 'Русский';

  @override
  String get languageEnglish => 'English';

  @override
  String get aiGreeting => 'Привет, ты можешь спросить меня';

  @override
  String get aiSuggestionsTitle => 'Может эти слова тебе помогут...';

  @override
  String get aiSuggestion1 => 'Составить договор';

  @override
  String get aiSuggestion2 => 'Предложить улучшения';

  @override
  String get aiSuggestion3 => 'Провести анализ рынка';

  @override
  String get aiStopGeneration => 'Остановить генерацию...';

  @override
  String get aiInputPlaceholder => 'Введите вопрос...';

  @override
  String get aiRecognizingSpeech => 'Распознаю речь...';

  @override
  String get analyticsCategoryGrowing => 'Растущие';

  @override
  String get analyticsCategoryFalling => 'Падающие';

  @override
  String get templateApply => 'Применить шаблон';

  @override
  String get templateEdit => 'Редактировать';

  @override
  String get themeTitle => 'Тема';

  @override
  String get themeSystem => 'Как в системе';

  @override
  String get themeLight => 'Светлая тема';

  @override
  String get themeDark => 'Тёмная тема';

  @override
  String get authEmailTitle => 'Введите почту';

  @override
  String get authEmailHint => 'Email';

  @override
  String get authEmailErrorInvalid => 'Введите корректную почту';

  @override
  String get authEmailErrorNotRegistered => 'Эта почта не зарегистрирована';

  @override
  String get authEmailErrorConnection => 'Ошибка соединения. Проверьте интернет и попробуйте снова';

  @override
  String get authButtonLogin => 'ВОЙТИ';

  @override
  String get authNoAccount => 'Нет аккаунта? ';

  @override
  String get authRegister => 'Зарегистрируйтесь';

  @override
  String get authPasswordHint => 'Пароль';

  @override
  String get authPasswordErrorWrong => 'Неверный пароль';

  @override
  String get authRegisterPlaceholder => 'Здесь будет экран регистрации';

  @override
  String get authRegisterTitle => 'Регистрация';

  @override
  String get authHasAccount => 'Есть аккаунт? ';

  @override
  String get authLogin => 'Войдите';

  @override
  String get authButtonContinue => 'ПРОДОЛЖИТЬ';

  @override
  String get authEmailAlreadyRegistered => 'Эта почта уже зарегистрирована';

  @override
  String get authCodeTitle => 'Код';

  @override
  String get authCodeMessage => 'На вашу почту был отправлен код для\nподтверждения регистрации 1111';

  @override
  String get authCodeErrorWrong => 'Неверный код';

  @override
  String get authPasswordCreateTitle => 'Создайте';

  @override
  String get authPasswordCreateSubtitle => 'пароль';

  @override
  String get authPasswordConfirm => 'Пароль';

  @override
  String get authPasswordErrorTooShort => 'Пароль должен быть не менее 8 символов';

  @override
  String get authPasswordErrorMismatch => 'Пароли не совпадают';

  @override
  String get authFillDataTitle => 'Заполнить данные';

  @override
  String get authPasswordWeakTitle => 'Ваш пароль слишком легкий';

  @override
  String get authPasswordWeakMessage => 'Вы уверены, что хотите его использовать?';

  @override
  String get authPasswordWeakChange => 'Изменить';

  @override
  String get authPasswordWeakContinue => 'Продолжить';

  @override
  String get authSaveButton => 'Сохранить';

  @override
  String get authFieldFullName => 'Полное имя';

  @override
  String get authFieldNickname => 'Ник';

  @override
  String get authFieldEmail => 'Электронная почта';

  @override
  String get authFieldPhone => 'Номер телефона';

  @override
  String get authFieldCountry => 'Страна';

  @override
  String get authFieldGender => 'Пол';

  @override
  String get authCountryRussia => 'Россия';

  @override
  String get authCountryKazakhstan => 'Казахстан';

  @override
  String get authCountryBelarus => 'Беларусь';

  @override
  String get authGenderMale => 'Мужской';

  @override
  String get authGenderFemale => 'Женский';

  @override
  String get authNicknameError => 'Только английские буквы, цифры и спецсимволы';

  @override
  String get accountEditProfileTitle => 'Редактировать профиль';

  @override
  String get aiCopyToast => 'Текст скопирован';

  @override
  String get templateCategoryMarketing => 'Маркетинг';

  @override
  String get templateCategorySales => 'Продажи';

  @override
  String get templateCategoryStrategy => 'Стратегия';

  @override
  String get templateCategorySupport => 'Поддержка';

  @override
  String get templateCategoryStaff => 'Персонал';

  @override
  String get templateCategoryAnalytics => 'Аналитика';

  @override
  String get templateTitle0 => 'Создай продающий пост для соцсетей';

  @override
  String get templateTitle1 => 'Напиши привлекательное описание товара для каталога';

  @override
  String get templateTitle2 => 'Создай рекламный текст до 150 символов';

  @override
  String get templateTitle3 => 'Придумай идею для вирусного Reels или TikTok';

  @override
  String get templateTitle4 => 'Создай текст email-рассылки для клиентов';

  @override
  String get templateTitle5 => 'Составь контент-план на неделю для бизнеса';

  @override
  String get templateTitle6 => 'Создай скрипт звонка для продажи услуги';

  @override
  String get templateTitle7 => 'Составь ответы на типичные возражения клиентов';

  @override
  String get templateTitle8 => 'Создай короткое коммерческое предложение';

  @override
  String get templateTitle9 => 'Напиши эффективный текст для общения с клиентом в чате';

  @override
  String get templateTitle10 => 'Подготовь финальную фразу для закрытия сделки';

  @override
  String get templateTitle11 => 'Создай короткое холодное сообщение для первого контакта';

  @override
  String get templateTitle12 => 'Составь план развития бизнеса на 3 месяца';

  @override
  String get templateTitle13 => 'Сделай краткий анализ основных конкурентов';

  @override
  String get templateTitle14 => 'Придумай идеи для расширения линейки услуг';

  @override
  String get templateTitle15 => 'Составь SWOT-анализ компании';

  @override
  String get templateTitle16 => 'Предложи стратегию увеличения прибыли';

  @override
  String get templateTitle17 => 'Сформулируй уникальное торговое предложение';

  @override
  String get templateTitle18 => 'Составь вежливый ответ недовольному клиенту';

  @override
  String get templateTitle19 => 'Напиши корректное сообщение о задержке выполнения';

  @override
  String get templateTitle20 => 'Создай сообщение о подтверждении заказа';

  @override
  String get templateTitle21 => 'Составь инструкцию по использованию продукта';

  @override
  String get templateTitle22 => 'Создай корректное сообщение с извинением';

  @override
  String get templateTitle23 => 'Напиши профессиональный ответ на вопрос клиента';

  @override
  String get templateTitle24 => 'Составь корректную обратную связь сотруднику';

  @override
  String get templateTitle25 => 'Создай короткое объявление для коллектива';

  @override
  String get templateTitle26 => 'Напиши мотивационное сообщение для сотрудников';

  @override
  String get templateTitle27 => 'Составь список задач для сотрудника на день';

  @override
  String get templateTitle28 => 'Составь набор корпоративных правил';

  @override
  String get templateTitle29 => 'Создай текст привлекательной вакансии';

  @override
  String get templateTitle30 => 'Сделай краткий анализ продаж';

  @override
  String get templateTitle31 => 'Создай отчёт о результатах работы за неделю';

  @override
  String get templateTitle32 => 'Оцени эффективность рекламной кампании';

  @override
  String get templateTitle33 => 'Сделай прогноз спроса';

  @override
  String get templateTitle34 => 'Проанализируй слабые места бизнеса';

  @override
  String get templateTitle35 => 'Дай рекомендации по улучшению работы бизнеса';

  @override
  String get templateTitle36 => 'Создай отчёт о конверсии';

  @override
  String get templateTitle37 => 'Проанализируй поведение клиентов';

  @override
  String get templateTitle38 => 'Составь финансовый план на квартал';

  @override
  String get templateTitle39 => 'Рассчитай точку безубыточности';

  @override
  String get templateTitle40 => 'Создай бюджет на месяц';

  @override
  String get templateTitle41 => 'Проанализируй расходы компании';

  @override
  String get templateTitle42 => 'Составь план оптимизации затрат';

  @override
  String get templateTitle43 => 'Рассчитай рентабельность проекта';

  @override
  String get templateTitle44 => 'Создай финансовый отчёт';

  @override
  String get templateTitle45 => 'Составь описание должности';

  @override
  String get templateTitle46 => 'Создай план адаптации нового сотрудника';

  @override
  String get templateTitle47 => 'Составь план обучения сотрудников';

  @override
  String get templateTitle48 => 'Создай систему оценки эффективности';

  @override
  String get templateTitle49 => 'Напиши план развития команды';

  @override
  String get templateTitle50 => 'Составь программу мотивации персонала';

  @override
  String get templateTitle51 => 'Оптимизируй рабочие процессы';

  @override
  String get templateTitle52 => 'Составь план улучшения качества';

  @override
  String get templateTitle53 => 'Создай систему контроля качества';

  @override
  String get templateTitle54 => 'Составь план логистики';

  @override
  String get templateTitle55 => 'Оптимизируй цепочку поставок';

  @override
  String get templateTitle56 => 'Создай стандарты работы';

  @override
  String get templateTitle57 => 'Создай план мерчандайзинга';

  @override
  String get templateTitle58 => 'Составь стратегию ценообразования';

  @override
  String get templateTitle59 => 'Создай план акций и скидок';

  @override
  String get templateTitle60 => 'Оптимизируй выкладку товаров';

  @override
  String get templateTitle61 => 'Составь план работы с поставщиками';

  @override
  String get templateTitle62 => 'Создай систему управления запасами';

  @override
  String get templateTitle63 => 'Оптимизируй производственный процесс';

  @override
  String get templateTitle64 => 'Составь план контроля качества';

  @override
  String get templateTitle65 => 'Создай систему управления производством';

  @override
  String get templateTitle66 => 'Составь план технического обслуживания';

  @override
  String get templateTitle67 => 'Оптимизируй использование ресурсов';

  @override
  String get templateTitle68 => 'Создай план безопасности на производстве';

  @override
  String get templateTitle69 => 'Составь техническое задание';

  @override
  String get templateTitle70 => 'Создай план разработки продукта';

  @override
  String get templateTitle71 => 'Составь план тестирования';

  @override
  String get templateTitle72 => 'Создай документацию проекта';

  @override
  String get templateTitle73 => 'Составь план внедрения системы';

  @override
  String get templateTitle74 => 'Создай план технической поддержки';

  @override
  String get templateTitle75 => 'Составь план лечения пациента';

  @override
  String get templateTitle76 => 'Создай протокол медицинской процедуры';

  @override
  String get templateTitle77 => 'Составь план профилактических мероприятий';

  @override
  String get templateTitle78 => 'Создай систему управления медицинскими записями';

  @override
  String get templateTitle79 => 'Составь план работы с пациентами';

  @override
  String get templateTitle80 => 'Создай план повышения качества услуг';

  @override
  String get templateTitle81 => 'Составь учебный план';

  @override
  String get templateTitle82 => 'Создай план урока';

  @override
  String get templateTitle83 => 'Составь программу обучения';

  @override
  String get templateTitle84 => 'Создай систему оценки знаний';

  @override
  String get templateTitle85 => 'Составь план работы с родителями';

  @override
  String get templateTitle86 => 'Создай план развития образовательного учреждения';

  @override
  String get templateTitle87 => 'Составь описание объекта недвижимости';

  @override
  String get templateTitle88 => 'Создай план презентации объекта';

  @override
  String get templateTitle89 => 'Составь план работы с клиентами';

  @override
  String get templateTitle90 => 'Создай систему управления объектами';

  @override
  String get templateTitle91 => 'Составь план маркетинга недвижимости';

  @override
  String get templateTitle92 => 'Создай план оценки недвижимости';

  @override
  String get templateTitle93 => 'Составь меню ресторана';

  @override
  String get templateTitle94 => 'Создай план работы кухни';

  @override
  String get templateTitle95 => 'Составь план обслуживания гостей';

  @override
  String get templateTitle96 => 'Создай систему управления заказами';

  @override
  String get templateTitle97 => 'Составь план маркетинга ресторана';

  @override
  String get templateTitle98 => 'Создай план работы с поставщиками';

  @override
  String get templateTitle99 => 'Оптимизируй маршруты доставки';

  @override
  String get templateTitle100 => 'Составь план складской логистики';

  @override
  String get templateTitle101 => 'Создай систему управления транспортом';

  @override
  String get templateTitle102 => 'Составь план работы с перевозчиками';

  @override
  String get templateTitle103 => 'Создай план управления запасами';

  @override
  String get templateTitle104 => 'Оптимизируй цепочку поставок';

  @override
  String get templateTitle105 => 'Создай привлекательный заголовок для статьи';

  @override
  String get templateTitle106 => 'Напиши описание для лендинга';

  @override
  String get templateTitle107 => 'Составь план запуска продукта';

  @override
  String get templateTitle108 => 'Создай текст для баннера';

  @override
  String get templateTitle109 => 'Придумай слоган для бренда';

  @override
  String get templateTitle110 => 'Составь план работы с инфлюенсерами';

  @override
  String get templateTitle111 => 'Создай текст для push-уведомления';

  @override
  String get templateTitle112 => 'Напиши описание для YouTube видео';

  @override
  String get templateTitle113 => 'Составь план работы с воронкой продаж';

  @override
  String get templateTitle114 => 'Создай презентацию для клиента';

  @override
  String get templateTitle115 => 'Напиши текст для follow-up письма';

  @override
  String get templateTitle116 => 'Составь план работы с отложенными сделками';

  @override
  String get templateTitle117 => 'Создай систему мотивации для отдела продаж';

  @override
  String get templateTitle118 => 'Напиши текст для предложения скидки';

  @override
  String get templateTitle119 => 'Составь план работы с постоянными клиентами';

  @override
  String get templateTitle120 => 'Создай скрипт для работы с возражениями';

  @override
  String get templateTitle121 => 'Составь долгосрочную стратегию развития';

  @override
  String get templateTitle122 => 'Создай план выхода на новый рынок';

  @override
  String get templateTitle123 => 'Составь план диверсификации бизнеса';

  @override
  String get templateTitle124 => 'Создай стратегию позиционирования бренда';

  @override
  String get templateTitle125 => 'Составь план партнерства с другими компаниями';

  @override
  String get templateTitle126 => 'Создай план масштабирования бизнеса';

  @override
  String get templateTitle127 => 'Составь план работы с кризисными ситуациями';

  @override
  String get templateTitle128 => 'Создай стратегию работы с сезонностью';

  @override
  String get templateTitle129 => 'Создай шаблон ответа на частые вопросы';

  @override
  String get templateTitle130 => 'Составь план работы с жалобами';

  @override
  String get templateTitle131 => 'Напиши сообщение о решении проблемы';

  @override
  String get templateTitle132 => 'Создай систему оценки качества поддержки';

  @override
  String get templateTitle133 => 'Составь план обучения сотрудников поддержки';

  @override
  String get templateTitle134 => 'Напиши текст для базы знаний';

  @override
  String get templateTitle135 => 'Создай план работы с обратной связью клиентов';

  @override
  String get templateTitle136 => 'Составь план работы в нерабочее время';

  @override
  String get templateTitle137 => 'Составь план проведения собеседования';

  @override
  String get templateTitle138 => 'Создай систему оценки сотрудников';

  @override
  String get templateTitle139 => 'Составь план командообразования';

  @override
  String get templateTitle140 => 'Напиши план развития карьеры сотрудника';

  @override
  String get templateTitle141 => 'Создай план работы с конфликтами в коллективе';

  @override
  String get templateTitle142 => 'Составь план удержания талантов';

  @override
  String get templateTitle143 => 'Создай систему наставничества';

  @override
  String get templateTitle144 => 'Составь план корпоративных мероприятий';

  @override
  String get templateTitle145 => 'Создай дашборд ключевых метрик';

  @override
  String get templateTitle146 => 'Проанализируй эффективность каналов привлечения';

  @override
  String get templateTitle147 => 'Составь отчёт о ROI маркетинговых кампаний';

  @override
  String get templateTitle148 => 'Создай анализ жизненного цикла клиента';

  @override
  String get templateTitle149 => 'Проанализируй сезонные тренды';

  @override
  String get templateTitle150 => 'Составь сравнительный анализ с конкурентами';

  @override
  String get templateTitle151 => 'Составь план инвестиций';

  @override
  String get templateTitle152 => 'Создай систему управления денежными потоками';

  @override
  String get templateTitle153 => 'Составь план работы с кредитами';

  @override
  String get templateTitle154 => 'Создай систему контроля расходов';

  @override
  String get templateTitle155 => 'Составь план налогового планирования';

  @override
  String get templateTitle156 => 'Создай прогноз финансовых показателей';

  @override
  String get templateTitle157 => 'Составь план работы с дебиторской задолженностью';

  @override
  String get templateTitle158 => 'Создай план адаптации новых сотрудников';

  @override
  String get templateTitle159 => 'Составь систему компенсаций и льгот';

  @override
  String get templateTitle160 => 'Создай план работы с увольнениями';

  @override
  String get templateTitle161 => 'Составь план развития лидерских качеств';

  @override
  String get templateTitle162 => 'Создай систему обратной связи от сотрудников';

  @override
  String get templateTitle163 => 'Составь план работы с удаленными сотрудниками';

  @override
  String get templateTitle164 => 'Создай план работы с внутренними коммуникациями';

  @override
  String get templateTitle165 => 'Составь план работы с производительностью';

  @override
  String get templateTitle166 => 'Составь план автоматизации процессов';

  @override
  String get templateTitle167 => 'Создай систему управления рисками';

  @override
  String get templateTitle168 => 'Составь план работы с поставщиками';

  @override
  String get templateTitle169 => 'Создай план работы с инвентаризацией';

  @override
  String get templateTitle170 => 'Составь план работы с документацией';

  @override
  String get templateTitle171 => 'Создай систему мониторинга процессов';

  @override
  String get templateTitle172 => 'Составь план работы с инцидентами';

  @override
  String get templateTitle173 => 'Создай план непрерывного улучшения';

  @override
  String get templateTitle174 => 'Составь план работы с покупателями';

  @override
  String get templateTitle175 => 'Создай план работы с возвратами';

  @override
  String get templateTitle176 => 'Составь план работы с сезонными товарами';

  @override
  String get templateTitle177 => 'Создай систему работы с промокодами';

  @override
  String get templateTitle178 => 'Составь план работы с онлайн-продажами';

  @override
  String get templateTitle179 => 'Создай план работы с программами лояльности';

  @override
  String get templateTitle180 => 'Составь план работы с витриной';

  @override
  String get templateTitle181 => 'Создай план работы с персоналом магазина';

  @override
  String get templateTitle182 => 'Составь план работы с оборудованием';

  @override
  String get templateTitle183 => 'Создай систему управления производственным планом';

  @override
  String get templateTitle184 => 'Составь план работы с браком';

  @override
  String get templateTitle185 => 'Создай план работы с энергоэффективностью';

  @override
  String get templateTitle186 => 'Составь план работы с экологией';

  @override
  String get templateTitle187 => 'Создай план работы с инновациями';

  @override
  String get templateTitle188 => 'Составь план работы с сертификацией';

  @override
  String get templateTitle189 => 'Создай план работы с упаковкой';

  @override
  String get templateTitle190 => 'Составь план работы с безопасностью данных';

  @override
  String get templateTitle191 => 'Создай план работы с облачными сервисами';

  @override
  String get templateTitle192 => 'Составь план работы с API';

  @override
  String get templateTitle193 => 'Создай план работы с DevOps';

  @override
  String get templateTitle194 => 'Составь план работы с мобильными приложениями';

  @override
  String get templateTitle195 => 'Создай план работы с искусственным интеллектом';

  @override
  String get templateTitle196 => 'Составь план работы с кибербезопасностью';

  @override
  String get templateTitle197 => 'Создай план работы с автоматизацией';

  @override
  String get templateTitle198 => 'Составь план работы с пациентами';

  @override
  String get templateTitle199 => 'Создай план работы с медицинским оборудованием';

  @override
  String get templateTitle200 => 'Составь план работы с лекарствами';

  @override
  String get templateTitle201 => 'Создай план работы с медицинским персоналом';

  @override
  String get templateTitle202 => 'Составь план работы с санитарными нормами';

  @override
  String get templateTitle203 => 'Создай план работы с экстренными ситуациями';

  @override
  String get templateTitle204 => 'Составь план работы с медицинской документацией';

  @override
  String get templateTitle205 => 'Создай план работы с профилактикой';

  @override
  String get templateTitle206 => 'Составь план работы с учениками';

  @override
  String get templateTitle207 => 'Создай план работы с родителями';

  @override
  String get templateTitle208 => 'Составь план работы с учебными материалами';

  @override
  String get templateTitle209 => 'Создай план работы с внеклассными мероприятиями';

  @override
  String get templateTitle210 => 'Составь план работы с профессиональным развитием';

  @override
  String get templateTitle211 => 'Создай план работы с инклюзивным образованием';

  @override
  String get templateTitle212 => 'Составь план работы с цифровыми технологиями';

  @override
  String get templateTitle213 => 'Создай план работы с оценкой качества образования';

  @override
  String get templateTitle214 => 'Составь план работы с арендаторами';

  @override
  String get templateTitle215 => 'Создай план работы с техническим обслуживанием';

  @override
  String get templateTitle216 => 'Составь план работы с юридическими вопросами';

  @override
  String get templateTitle217 => 'Создай план работы с инвестициями в недвижимость';

  @override
  String get templateTitle218 => 'Составь план работы с ремонтом';

  @override
  String get templateTitle219 => 'Создай план работы с коммунальными услугами';

  @override
  String get templateTitle220 => 'Составь план работы с безопасностью';

  @override
  String get templateTitle221 => 'Создай план работы с управлением объектами';

  @override
  String get templateTitle222 => 'Составь план работы с персоналом ресторана';

  @override
  String get templateTitle223 => 'Создай план работы с санитарными нормами';

  @override
  String get templateTitle224 => 'Составь план работы с напитками';

  @override
  String get templateTitle225 => 'Создай план работы с мероприятиями';

  @override
  String get templateTitle226 => 'Составь план работы с доставкой';

  @override
  String get templateTitle227 => 'Создай план работы с рекламой';

  @override
  String get templateTitle228 => 'Составь план работы с отзывами';

  @override
  String get templateTitle229 => 'Создай план работы с сезонным меню';

  @override
  String get templateTitle230 => 'Составь план работы с транспортом';

  @override
  String get templateTitle231 => 'Создай план работы с таможней';

  @override
  String get templateTitle232 => 'Составь план работы с упаковкой и маркировкой';

  @override
  String get templateTitle233 => 'Создай план работы с возвратами';

  @override
  String get templateTitle234 => 'Составь план работы с международной логистикой';

  @override
  String get templateTitle235 => 'Создай план работы с курьерскими службами';

  @override
  String get templateTitle236 => 'Составь план работы с отслеживанием грузов';

  @override
  String get templateTitle237 => 'Создай план работы с логистическими партнерами';

  @override
  String get templateTitle238 => 'Создай еженедельный отчет о работе';

  @override
  String get templateTitle239 => 'Проведи анализ рынка';

  @override
  String get templateTitle253 => 'Составь отчет о выполненных задачах';

  @override
  String get templateTitle254 => 'Создай отчет о продажах за неделю';

  @override
  String get templateTitle255 => 'Составь отчет о работе команды';

  @override
  String get templateTitle256 => 'Создай отчет о достижениях за неделю';

  @override
  String get templateTitle257 => 'Составь отчет о маркетинговых активностях';

  @override
  String get templateTitle258 => 'Создай отчет о финансовых показателях';

  @override
  String get templateTitle259 => 'Составь отчет о работе с клиентами';

  @override
  String get templateTitle260 => 'Создай отчет о проектах за неделю';

  @override
  String get templateTitle261 => 'Составь отчет о производительности';

  @override
  String get templateTitle262 => 'Создай отчет о проблемах и решениях';

  @override
  String get templateTitle263 => 'Составь отчет о планах на следующую неделю';

  @override
  String get templateTitle264 => 'Создай анализ конкурентов';

  @override
  String get templateTitle265 => 'Составь анализ целевой аудитории';

  @override
  String get templateTitle266 => 'Проведи анализ трендов в отрасли';

  @override
  String get templateTitle267 => 'Создай анализ ценовой политики';

  @override
  String get templateTitle268 => 'Составь анализ маркетинговых каналов';

  @override
  String get templateTitle269 => 'Проведи анализ сегментации рынка';

  @override
  String get templateTitle270 => 'Создай анализ продуктового портфеля';

  @override
  String get templateTitle271 => 'Составь анализ географического рынка';

  @override
  String get templateTitle272 => 'Проведи анализ потребительского поведения';

  @override
  String get templateTitle273 => 'Создай анализ рыночных возможностей';

  @override
  String get templateTitle274 => 'Составь анализ барьеров входа на рынок';

  @override
  String get templateTitle275 => 'Проведи анализ динамики рынка';

  @override
  String get privacyTitle => 'Политика конфиденциальности';

  @override
  String get privacyHeading => 'Политика конфиденциальности Smile AI';

  @override
  String get privacyIntro => 'Мы уважаем вашу конфиденциальность и стремимся обеспечить безопасное использование нашего приложения.';

  @override
  String get privacySection1Title => '1. Какие данные мы собираем';

  @override
  String get privacySection1Body => 'Мы можем получать:\n • сообщения, которые вы отправляете в чат;\n • данные профиля (имя, название бизнеса, email — если указан);\n • технические данные устройства (модель, OS, язык);\n • статистику использования (анонимную).\n\nМы не собираем данные, не связанные с работой сервиса.';

  @override
  String get privacySection2Title => '2. Как мы используем данные';

  @override
  String get privacySection2Body => 'Данные используются только для:\n • генерации ответов нейросети,\n • работы функций приложения,\n • улучшения стабильности и качества обслуживания.\n\nМы не используем ваши сообщения для обучения моделей.';

  @override
  String get privacySection3Title => '3. Передача данных третьим лицам';

  @override
  String get privacySection3Body => 'Мы не передаём данные сторонним компаниям.\nИсключение — технические сервисы (например, хостинг), которые обеспечивают работу приложения и получают только минимально необходимую информацию.';

  @override
  String get privacySection4Title => '4. Хранение и безопасность';

  @override
  String get privacySection4Body => ' • Данные передаются по защищённому соединению.\n • Используются современные методы шифрования и защиты.\n • Доступ к серверам ограничён.';

  @override
  String get privacySection5Title => '5. Удаление данных';

  @override
  String get privacySection5Body => 'Вы можете запросить удаление всех данных. После удаления восстановить их невозможно.';

  @override
  String get privacySection6Title => '6. Изменения политики';

  @override
  String get privacySection6Body => 'Мы можем обновлять политику конфиденциальности. Обновления публикуются в приложении.';

  @override
  String get privacySection7Title => '7. Контакты';

  @override
  String get privacySection7Body => 'По вопросам: support@smileai.app';

  @override
  String get dataPrivacyIntroTitle => 'Smile AI заботится о вашей конфиденциальности.';

  @override
  String get dataPrivacyIntroBody => 'Мы собираем минимум информации, необходимой для работы сервиса. Все данные передаются по защищённому соединению и не используются для обучения глобальных моделей ИИ.';

  @override
  String get dataPrivacyWhatTitle => 'Что мы собираем:';

  @override
  String get dataPrivacyWhatBody => '• данные, которые вы указываете сами — сообщения, название бизнеса, настройки профиля;\n• технические данные — модель устройства, версия ОС, язык приложения;\n• анонимная статистика использования (опционально).';

  @override
  String get dataPrivacyWhyTitle => 'Для чего это нужно:';

  @override
  String get dataPrivacyWhyBody => '• корректная работа ИИ-чата;\n• улучшение качества ответа в текущем диалоге;\n• повышение стабильности приложения.';

  @override
  String get dataPrivacyNoShare => 'Мы не передаём данные третьим лицам, кроме технических сервисов, необходимых для обработки запросов.';

  @override
  String get dataPrivacyDelete => 'Вы можете запросить удаление данных в любой момент.';

  @override
  String get supportTitle => 'Поддержка Smile';

  @override
  String get supportOnlineStatus => 'Онлайн 24 часа';

  @override
  String get supportGreetingPrefix => 'Здравствуйте';

  @override
  String get supportDefaultName => 'пользователь';

  @override
  String get supportLabel => 'Поддержка';

  @override
  String get faqQuestion1 => 'Использует ли Smile AI мои сообщения для обучения?';

  @override
  String get faqAnswer1 => 'Нет. Ваши сообщения используются только для ответа внутри текущей сессии. Мы не храним и не используем переписку для обучения моделей.';

  @override
  String get faqQuestion2 => 'Кто может видеть мои чаты?';

  @override
  String get faqAnswer2 => 'Только вы. Администрация не имеет доступа к вашему контенту. Техподдержка может видеть фрагменты сообщений только если вы сами отправите их в запросе.';

  @override
  String get faqQuestion3 => 'Что произойдёт, если удалить аккаунт?';

  @override
  String get faqAnswer3 => 'Все данные будут полностью удалены: чаты, настройки, история запросов. Восстановить их будет невозможно.';

  @override
  String get faqQuestion4 => 'Передаёте ли вы данные другим компаниям?';

  @override
  String get faqAnswer4 => 'Нет. Единственное исключение — технические сервисы (серверы, облачное хранилище), которые работают только как инфраструктура и не имеют доступа к вашему контенту.';

  @override
  String get faqQuestion5 => 'Насколько безопасно приложение?';

  @override
  String get faqAnswer5 => 'Соединение зашифровано (HTTPS/SSL), данные хранятся на защищённых серверах, используется многоуровневая защита и постоянный мониторинг.';

  @override
  String get chatMenuNewChat => 'Новый чат';

  @override
  String get chatMenuChats => 'Чаты';

  @override
  String get chatMenuShare => 'Поделиться';

  @override
  String get chatMenuRename => 'Переименовать';

  @override
  String get chatMenuDelete => 'Удалить';

  @override
  String get templatesSectionPopular => 'Популярные';

  @override
  String get templatesSectionBusinessGoals => 'Бизнес-цели';

  @override
  String get templatesSectionIndustry => 'Отраслевые';

  @override
  String get templatesSectionPersonal => 'Персональные';

  @override
  String get templatesWeeklyReport => 'Еженедельный отчет';

  @override
  String get templatesMarketAnalysis => 'Анализ рынка';

  @override
  String get templatesYourTemplates => 'Ваши шаблоны';

  @override
  String get templatesYourTemplatesLine1 => 'ваши';

  @override
  String get templatesYourTemplatesLine2 => 'шаблоны';

  @override
  String get templatesAddFolder => 'Добавить папку';

  @override
  String get templatesAddNewFolder => 'Добавить новую папку';

  @override
  String get templatesEnterFolderName => 'Введите название папки';

  @override
  String get templatesAdd => 'Добавить';

  @override
  String get templatesCategoryMarketing => 'Маркетинг';

  @override
  String get templatesCategoryStrategy => 'Стратегия';

  @override
  String get templatesCategorySales => 'Продажи';

  @override
  String get templatesCategoryFinance => 'Финансы';

  @override
  String get templatesCategoryHR => 'HR';

  @override
  String get templatesCategoryOperations => 'Операции';

  @override
  String get templatesCategorySupport => 'Поддержка';

  @override
  String get templatesCategoryAnalytics => 'Аналитика';

  @override
  String get templatesCategoryRetail => 'Розничная торговля';

  @override
  String get templatesCategoryManufacturing => 'Производство';

  @override
  String get templatesCategoryIT => 'IT/Технологии';

  @override
  String get templatesCategoryHealthcare => 'Здравоохранение';

  @override
  String get templatesCategoryEducation => 'Образование';

  @override
  String get templatesCategoryRealEstate => 'Недвижимость';

  @override
  String get templatesCategoryRestaurant => 'Ресторанный бизнес';

  @override
  String get templatesCategoryLogistics => 'Логистика';

  @override
  String get contextTitle => 'Контекст разговора';

  @override
  String get contextDescription => 'Установите контекст для этого разговора, чтобы получать более релевантные ответы';

  @override
  String get contextUserRole => 'Ваша роль';

  @override
  String get contextUserRolePlaceholder => 'Выберите вашу роль';

  @override
  String get contextBusinessStage => 'Стадия бизнеса';

  @override
  String get contextBusinessStagePlaceholder => 'Выберите стадию бизнеса';

  @override
  String get contextGoal => 'Цель';

  @override
  String get contextGoalPlaceholder => 'Выберите цель';

  @override
  String get contextUrgency => 'Срочность';

  @override
  String get contextUrgencyPlaceholder => 'Выберите срочность';

  @override
  String get contextRegion => 'Регион';

  @override
  String get contextRegionPlaceholder => 'Выберите регион';

  @override
  String get contextBusinessNiche => 'Ниша бизнеса';

  @override
  String get contextBusinessNichePlaceholder => 'Выберите нишу бизнеса';

  @override
  String get contextCancel => 'Отмена';

  @override
  String get contextSave => 'Сохранить';

  @override
  String get contextUserRoleOwner => 'Владелец';

  @override
  String get contextUserRoleMarketer => 'Маркетолог';

  @override
  String get contextUserRoleAccountant => 'Бухгалтер';

  @override
  String get contextUserRoleBeginner => 'Новичок';

  @override
  String get contextBusinessStageStartup => 'Стартап';

  @override
  String get contextBusinessStageStable => 'Стабильный';

  @override
  String get contextBusinessStageScaling => 'Масштабирование';

  @override
  String get contextGoalIncreaseRevenue => 'Увеличить доход';

  @override
  String get contextGoalReduceCosts => 'Снизить затраты';

  @override
  String get contextGoalHireStaff => 'Нанять сотрудников';

  @override
  String get contextGoalLaunchAds => 'Запустить рекламу';

  @override
  String get contextGoalLegalHelp => 'Юридическая помощь';

  @override
  String get contextUrgencyUrgent => 'Срочно';

  @override
  String get contextUrgencyNormal => 'Обычно';

  @override
  String get contextUrgencyPlanning => 'Планирование';

  @override
  String get contextBusinessNicheRetail => 'Розница';

  @override
  String get contextBusinessNicheServices => 'Услуги';

  @override
  String get contextBusinessNicheFoodService => 'Общественное питание';

  @override
  String get contextBusinessNicheManufacturing => 'Производство';

  @override
  String get contextBusinessNicheOnlineServices => 'Онлайн-услуги';

  @override
  String get contextRegionRussia => 'Россия';

  @override
  String get contextRegionAmerica => 'Америка';

  @override
  String get contextRegionBritain => 'Британия';

  @override
  String get aiStaffMessage => 'Переключаем ваш диалог на сотрудника. Мы уже занимаемся вашим вопросом, ответим в ближайшее время';

  @override
  String get profileLogout => 'Выход';
}
