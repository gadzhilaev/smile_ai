import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/template_model.dart';

class TemplateService {
  static const String _titlePrefKeyPrefix = 'template_title_';

  // Имитация загрузки данных с API
  static Future<TemplateModel> getTemplateById(int id) async {
    // Имитация задержки сети
    await Future.delayed(const Duration(milliseconds: 500));

    // Пока что возвращаем моковые данные
    // В будущем здесь будет реальный запрос к API
    final templates = await getAllTemplates();
    if (id >= 0 && id < templates.length) {
      return templates[id];
    }
    return templates[0]; // Возвращаем первый шаблон по умолчанию
  }

  // Метод для получения списка всех шаблонов
  static Future<List<TemplateModel>> getAllTemplates({
    bool forceRefresh = false,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final prefs = await SharedPreferences.getInstance();
    final random = Random();

    // Загружаем сохраненные шаблоны или используем дефолтные.
    // Всегда возвращаем новый список с новыми объектами для правильного обновления UI.
    final list = _templates
        .map((template) {
          final overrideTitle =
              prefs.getString('$_titlePrefKeyPrefix${template.id}');
          return TemplateModel(
            id: template.id,
            category: template.category,
            categoryColor: template.categoryColor,
            title: overrideTitle ?? template.title,
            isCustom: overrideTitle != null,
          );
        }).toList();

    // Перемешиваем порядок шаблонов
    list.shuffle(random);

    // Подправляем порядок, чтобы не было более 2 подряд из одной категории
    for (int i = 0; i <= list.length - 3; i++) {
      final cat = list[i].category;
      if (list[i + 1].category == cat && list[i + 2].category == cat) {
        int swapIndex = -1;
        for (int j = i + 3; j < list.length; j++) {
          if (list[j].category != cat) {
            swapIndex = j;
            break;
          }
        }
        if (swapIndex != -1) {
          final tmp = list[i + 2];
          list[i + 2] = list[swapIndex];
          list[swapIndex] = tmp;
        }
      }
    }

    return list;
  }

  // Временное хранилище шаблонов (в будущем будет API)
  static final List<TemplateModel> _templates = [
    // ------------------ МАРКЕТИНГ ------------------
    TemplateModel(
      id: 0,
      category: 'Маркетинг',
      categoryColor: const Color(0x80D300E6),
      title: 'Создай продающий пост для соцсетей',
    ),
    TemplateModel(
      id: 1,
      category: 'Маркетинг',
      categoryColor: const Color(0x80D300E6),
      title: 'Напиши привлекательное описание товара для каталога',
    ),
    TemplateModel(
      id: 2,
      category: 'Маркетинг',
      categoryColor: const Color(0x80D300E6),
      title: 'Создай рекламный текст до 150 символов',
    ),
    TemplateModel(
      id: 3,
      category: 'Маркетинг',
      categoryColor: const Color(0x80D300E6),
      title: 'Придумай идею для вирусного Reels или TikTok',
    ),
    TemplateModel(
      id: 4,
      category: 'Маркетинг',
      categoryColor: const Color(0x80D300E6),
      title: 'Создай текст email-рассылки для клиентов',
    ),
    TemplateModel(
      id: 5,
      category: 'Маркетинг',
      categoryColor: const Color(0x80D300E6),
      title: 'Составь контент-план на неделю для бизнеса',
    ),

    // ------------------ ПРОДАЖИ ------------------
    TemplateModel(
      id: 6,
      category: 'Продажи',
      categoryColor: const Color(0x80007B0C),
      title: 'Создай скрипт звонка для продажи услуги',
    ),
    TemplateModel(
      id: 7,
      category: 'Продажи',
      categoryColor: const Color(0x80007B0C),
      title: 'Составь ответы на типичные возражения клиентов',
    ),
    TemplateModel(
      id: 8,
      category: 'Продажи',
      categoryColor: const Color(0x80007B0C),
      title: 'Создай короткое коммерческое предложение',
    ),
    TemplateModel(
      id: 9,
      category: 'Продажи',
      categoryColor: const Color(0x80007B0C),
      title: 'Напиши эффективный текст для общения с клиентом в чате',
    ),
    TemplateModel(
      id: 10,
      category: 'Продажи',
      categoryColor: const Color(0x80007B0C),
      title: 'Подготовь финальную фразу для закрытия сделки',
    ),
    TemplateModel(
      id: 11,
      category: 'Продажи',
      categoryColor: const Color(0x80007B0C),
      title: 'Создай короткое холодное сообщение для первого контакта',
    ),

    // ------------------ СТРАТЕГИЯ ------------------
    TemplateModel(
      id: 12,
      category: 'Стратегия',
      categoryColor: const Color(0x806F00E6),
      title: 'Составь план развития бизнеса на 3 месяца',
    ),
    TemplateModel(
      id: 13,
      category: 'Стратегия',
      categoryColor: const Color(0x806F00E6),
      title: 'Сделай краткий анализ основных конкурентов',
    ),
    TemplateModel(
      id: 14,
      category: 'Стратегия',
      categoryColor: const Color(0x806F00E6),
      title: 'Придумай идеи для расширения линейки услуг',
    ),
    TemplateModel(
      id: 15,
      category: 'Стратегия',
      categoryColor: const Color(0x806F00E6),
      title: 'Составь SWOT-анализ компании',
    ),
    TemplateModel(
      id: 16,
      category: 'Стратегия',
      categoryColor: const Color(0x806F00E6),
      title: 'Предложи стратегию увеличения прибыли',
    ),
    TemplateModel(
      id: 17,
      category: 'Стратегия',
      categoryColor: const Color(0x806F00E6),
      title: 'Сформулируй уникальное торговое предложение',
    ),

    // ------------------ КЛИЕНТСКАЯ ПОДДЕРЖКА ------------------
    TemplateModel(
      id: 18,
      category: 'Поддержка',
      categoryColor: const Color(0x809300E6),
      title: 'Составь вежливый ответ недовольному клиенту',
    ),
    TemplateModel(
      id: 19,
      category: 'Поддержка',
      categoryColor: const Color(0x809300E6),
      title: 'Напиши корректное сообщение о задержке выполнения',
    ),
    TemplateModel(
      id: 20,
      category: 'Поддержка',
      categoryColor: const Color(0x809300E6),
      title: 'Создай сообщение о подтверждении заказа',
    ),
    TemplateModel(
      id: 21,
      category: 'Поддержка',
      categoryColor: const Color(0x809300E6),
      title: 'Составь инструкцию по использованию продукта',
    ),
    TemplateModel(
      id: 22,
      category: 'Поддержка',
      categoryColor: const Color(0x809300E6),
      title: 'Создай корректное сообщение с извинением',
    ),
    TemplateModel(
      id: 23,
      category: 'Поддержка',
      categoryColor: const Color(0x809300E6),
      title: 'Напиши профессиональный ответ на вопрос клиента',
    ),

    // ------------------ УПРАВЛЕНИЕ ПЕРСОНАЛОМ ------------------
    TemplateModel(
      id: 24,
      category: 'Персонал',
      categoryColor: const Color(0x80E67F00),
      title: 'Составь корректную обратную связь сотруднику',
    ),
    TemplateModel(
      id: 25,
      category: 'Персонал',
      categoryColor: const Color(0x80E67F00),
      title: 'Создай короткое объявление для коллектива',
    ),
    TemplateModel(
      id: 26,
      category: 'Персонал',
      categoryColor: const Color(0x80E67F00),
      title: 'Напиши мотивационное сообщение для сотрудников',
    ),
    TemplateModel(
      id: 27,
      category: 'Персонал',
      categoryColor: const Color(0x80E67F00),
      title: 'Составь список задач для сотрудника на день',
    ),
    TemplateModel(
      id: 28,
      category: 'Персонал',
      categoryColor: const Color(0x80E67F00),
      title: 'Составь набор корпоративных правил',
    ),
    TemplateModel(
      id: 29,
      category: 'Персонал',
      categoryColor: const Color(0x80E67F00),
      title: 'Создай текст привлекательной вакансии',
    ),

    // ------------------ АНАЛИТИКА ------------------
    TemplateModel(
      id: 30,
      category: 'Аналитика',
      categoryColor: const Color(0x8000AEEF),
      title: 'Сделай краткий анализ продаж',
    ),
    TemplateModel(
      id: 31,
      category: 'Аналитика',
      categoryColor: const Color(0x8000AEEF),
      title: 'Создай отчёт о результатах работы за неделю',
    ),
    TemplateModel(
      id: 32,
      category: 'Аналитика',
      categoryColor: const Color(0x8000AEEF),
      title: 'Оцени эффективность рекламной кампании',
    ),
    TemplateModel(
      id: 33,
      category: 'Аналитика',
      categoryColor: const Color(0x8000AEEF),
      title: 'Сделай прогноз спроса',
    ),
    TemplateModel(
      id: 34,
      category: 'Аналитика',
      categoryColor: const Color(0x8000AEEF),
      title: 'Проанализируй слабые места бизнеса',
    ),
    TemplateModel(
      id: 35,
      category: 'Аналитика',
      categoryColor: const Color(0x8000AEEF),
      title: 'Дай рекомендации по улучшению работы бизнеса',
    ),
    TemplateModel(
      id: 36,
      category: 'Аналитика',
      categoryColor: const Color(0x8000AEEF),
      title: 'Создай отчёт о конверсии',
    ),
    TemplateModel(
      id: 37,
      category: 'Аналитика',
      categoryColor: const Color(0x8000AEEF),
      title: 'Проанализируй поведение клиентов',
    ),

    // ------------------ ФИНАНСЫ ------------------
    TemplateModel(
      id: 38,
      category: 'Финансы',
      categoryColor: const Color(0x80FF69B4),
      title: 'Составь финансовый план на квартал',
    ),
    TemplateModel(
      id: 39,
      category: 'Финансы',
      categoryColor: const Color(0x80FF69B4),
      title: 'Рассчитай точку безубыточности',
    ),
    TemplateModel(
      id: 40,
      category: 'Финансы',
      categoryColor: const Color(0x80FF69B4),
      title: 'Создай бюджет на месяц',
    ),
    TemplateModel(
      id: 41,
      category: 'Финансы',
      categoryColor: const Color(0x80FF69B4),
      title: 'Проанализируй расходы компании',
    ),
    TemplateModel(
      id: 42,
      category: 'Финансы',
      categoryColor: const Color(0x80FF69B4),
      title: 'Составь план оптимизации затрат',
    ),
    TemplateModel(
      id: 43,
      category: 'Финансы',
      categoryColor: const Color(0x80FF69B4),
      title: 'Рассчитай рентабельность проекта',
    ),
    TemplateModel(
      id: 44,
      category: 'Финансы',
      categoryColor: const Color(0x80FF69B4),
      title: 'Создай финансовый отчёт',
    ),

    // ------------------ HR ------------------
    TemplateModel(
      id: 45,
      category: 'HR',
      categoryColor: const Color(0x804682B4),
      title: 'Составь описание должности',
    ),
    TemplateModel(
      id: 46,
      category: 'HR',
      categoryColor: const Color(0x804682B4),
      title: 'Создай план адаптации нового сотрудника',
    ),
    TemplateModel(
      id: 47,
      category: 'HR',
      categoryColor: const Color(0x804682B4),
      title: 'Составь план обучения сотрудников',
    ),
    TemplateModel(
      id: 48,
      category: 'HR',
      categoryColor: const Color(0x804682B4),
      title: 'Создай систему оценки эффективности',
    ),
    TemplateModel(
      id: 49,
      category: 'HR',
      categoryColor: const Color(0x804682B4),
      title: 'Напиши план развития команды',
    ),
    TemplateModel(
      id: 50,
      category: 'HR',
      categoryColor: const Color(0x804682B4),
      title: 'Составь программу мотивации персонала',
    ),

    // ------------------ ОПЕРАЦИИ ------------------
    TemplateModel(
      id: 51,
      category: 'Операции',
      categoryColor: const Color(0x809370DB),
      title: 'Оптимизируй рабочие процессы',
    ),
    TemplateModel(
      id: 52,
      category: 'Операции',
      categoryColor: const Color(0x809370DB),
      title: 'Составь план улучшения качества',
    ),
    TemplateModel(
      id: 53,
      category: 'Операции',
      categoryColor: const Color(0x809370DB),
      title: 'Создай систему контроля качества',
    ),
    TemplateModel(
      id: 54,
      category: 'Операции',
      categoryColor: const Color(0x809370DB),
      title: 'Составь план логистики',
    ),
    TemplateModel(
      id: 55,
      category: 'Операции',
      categoryColor: const Color(0x809370DB),
      title: 'Оптимизируй цепочку поставок',
    ),
    TemplateModel(
      id: 56,
      category: 'Операции',
      categoryColor: const Color(0x809370DB),
      title: 'Создай стандарты работы',
    ),

    // ------------------ РОЗНИЧНАЯ ТОРГОВЛЯ ------------------
    TemplateModel(
      id: 57,
      category: 'Розничная торговля',
      categoryColor: const Color(0x8061B3F9),
      title: 'Создай план мерчандайзинга',
    ),
    TemplateModel(
      id: 58,
      category: 'Розничная торговля',
      categoryColor: const Color(0x8061B3F9),
      title: 'Составь стратегию ценообразования',
    ),
    TemplateModel(
      id: 59,
      category: 'Розничная торговля',
      categoryColor: const Color(0x8061B3F9),
      title: 'Создай план акций и скидок',
    ),
    TemplateModel(
      id: 60,
      category: 'Розничная торговля',
      categoryColor: const Color(0x8061B3F9),
      title: 'Оптимизируй выкладку товаров',
    ),
    TemplateModel(
      id: 61,
      category: 'Розничная торговля',
      categoryColor: const Color(0x8061B3F9),
      title: 'Составь план работы с поставщиками',
    ),
    TemplateModel(
      id: 62,
      category: 'Розничная торговля',
      categoryColor: const Color(0x8061B3F9),
      title: 'Создай систему управления запасами',
    ),

    // ------------------ ПРОИЗВОДСТВО ------------------
    TemplateModel(
      id: 63,
      category: 'Производство',
      categoryColor: const Color(0x80669484),
      title: 'Оптимизируй производственный процесс',
    ),
    TemplateModel(
      id: 64,
      category: 'Производство',
      categoryColor: const Color(0x80669484),
      title: 'Составь план контроля качества',
    ),
    TemplateModel(
      id: 65,
      category: 'Производство',
      categoryColor: const Color(0x80669484),
      title: 'Создай систему управления производством',
    ),
    TemplateModel(
      id: 66,
      category: 'Производство',
      categoryColor: const Color(0x80669484),
      title: 'Составь план технического обслуживания',
    ),
    TemplateModel(
      id: 67,
      category: 'Производство',
      categoryColor: const Color(0x80669484),
      title: 'Оптимизируй использование ресурсов',
    ),
    TemplateModel(
      id: 68,
      category: 'Производство',
      categoryColor: const Color(0x80669484),
      title: 'Создай план безопасности на производстве',
    ),

    // ------------------ IT/ТЕХНОЛОГИИ ------------------
    TemplateModel(
      id: 69,
      category: 'IT/Технологии',
      categoryColor: const Color(0x803FC1C9),
      title: 'Составь техническое задание',
    ),
    TemplateModel(
      id: 70,
      category: 'IT/Технологии',
      categoryColor: const Color(0x803FC1C9),
      title: 'Создай план разработки продукта',
    ),
    TemplateModel(
      id: 71,
      category: 'IT/Технологии',
      categoryColor: const Color(0x803FC1C9),
      title: 'Составь план тестирования',
    ),
    TemplateModel(
      id: 72,
      category: 'IT/Технологии',
      categoryColor: const Color(0x803FC1C9),
      title: 'Создай документацию проекта',
    ),
    TemplateModel(
      id: 73,
      category: 'IT/Технологии',
      categoryColor: const Color(0x803FC1C9),
      title: 'Составь план внедрения системы',
    ),
    TemplateModel(
      id: 74,
      category: 'IT/Технологии',
      categoryColor: const Color(0x803FC1C9),
      title: 'Создай план технической поддержки',
    ),

    // ------------------ ЗДРАВООХРАНЕНИЕ ------------------
    TemplateModel(
      id: 75,
      category: 'Здравоохранение',
      categoryColor: const Color(0x80FF6B6B),
      title: 'Составь план лечения пациента',
    ),
    TemplateModel(
      id: 76,
      category: 'Здравоохранение',
      categoryColor: const Color(0x80FF6B6B),
      title: 'Создай протокол медицинской процедуры',
    ),
    TemplateModel(
      id: 77,
      category: 'Здравоохранение',
      categoryColor: const Color(0x80FF6B6B),
      title: 'Составь план профилактических мероприятий',
    ),
    TemplateModel(
      id: 78,
      category: 'Здравоохранение',
      categoryColor: const Color(0x80FF6B6B),
      title: 'Создай систему управления медицинскими записями',
    ),
    TemplateModel(
      id: 79,
      category: 'Здравоохранение',
      categoryColor: const Color(0x80FF6B6B),
      title: 'Составь план работы с пациентами',
    ),
    TemplateModel(
      id: 80,
      category: 'Здравоохранение',
      categoryColor: const Color(0x80FF6B6B),
      title: 'Создай план повышения качества услуг',
    ),

    // ------------------ ОБРАЗОВАНИЕ ------------------
    TemplateModel(
      id: 81,
      category: 'Образование',
      categoryColor: const Color(0x806C5CE7),
      title: 'Составь учебный план',
    ),
    TemplateModel(
      id: 82,
      category: 'Образование',
      categoryColor: const Color(0x806C5CE7),
      title: 'Создай план урока',
    ),
    TemplateModel(
      id: 83,
      category: 'Образование',
      categoryColor: const Color(0x806C5CE7),
      title: 'Составь программу обучения',
    ),
    TemplateModel(
      id: 84,
      category: 'Образование',
      categoryColor: const Color(0x806C5CE7),
      title: 'Создай систему оценки знаний',
    ),
    TemplateModel(
      id: 85,
      category: 'Образование',
      categoryColor: const Color(0x806C5CE7),
      title: 'Составь план работы с родителями',
    ),
    TemplateModel(
      id: 86,
      category: 'Образование',
      categoryColor: const Color(0x806C5CE7),
      title: 'Создай план развития образовательного учреждения',
    ),

    // ------------------ НЕДВИЖИМОСТЬ ------------------
    TemplateModel(
      id: 87,
      category: 'Недвижимость',
      categoryColor: const Color(0x80FD9853),
      title: 'Составь описание объекта недвижимости',
    ),
    TemplateModel(
      id: 88,
      category: 'Недвижимость',
      categoryColor: const Color(0x80FD9853),
      title: 'Создай план презентации объекта',
    ),
    TemplateModel(
      id: 89,
      category: 'Недвижимость',
      categoryColor: const Color(0x80FD9853),
      title: 'Составь план работы с клиентами',
    ),
    TemplateModel(
      id: 90,
      category: 'Недвижимость',
      categoryColor: const Color(0x80FD9853),
      title: 'Создай систему управления объектами',
    ),
    TemplateModel(
      id: 91,
      category: 'Недвижимость',
      categoryColor: const Color(0x80FD9853),
      title: 'Составь план маркетинга недвижимости',
    ),
    TemplateModel(
      id: 92,
      category: 'Недвижимость',
      categoryColor: const Color(0x80FD9853),
      title: 'Создай план оценки недвижимости',
    ),

    // ------------------ РЕСТОРАННЫЙ БИЗНЕС ------------------
    TemplateModel(
      id: 93,
      category: 'Ресторанный бизнес',
      categoryColor: const Color(0x80FF9A9E),
      title: 'Составь меню ресторана',
    ),
    TemplateModel(
      id: 94,
      category: 'Ресторанный бизнес',
      categoryColor: const Color(0x80FF9A9E),
      title: 'Создай план работы кухни',
    ),
    TemplateModel(
      id: 95,
      category: 'Ресторанный бизнес',
      categoryColor: const Color(0x80FF9A9E),
      title: 'Составь план обслуживания гостей',
    ),
    TemplateModel(
      id: 96,
      category: 'Ресторанный бизнес',
      categoryColor: const Color(0x80FF9A9E),
      title: 'Создай систему управления заказами',
    ),
    TemplateModel(
      id: 97,
      category: 'Ресторанный бизнес',
      categoryColor: const Color(0x80FF9A9E),
      title: 'Составь план маркетинга ресторана',
    ),
    TemplateModel(
      id: 98,
      category: 'Ресторанный бизнес',
      categoryColor: const Color(0x80FF9A9E),
      title: 'Создай план работы с поставщиками',
    ),

    // ------------------ ЛОГИСТИКА ------------------
    TemplateModel(
      id: 99,
      category: 'Логистика',
      categoryColor: const Color(0x80D8AA74),
      title: 'Оптимизируй маршруты доставки',
    ),
    TemplateModel(
      id: 100,
      category: 'Логистика',
      categoryColor: const Color(0x80D8AA74),
      title: 'Составь план складской логистики',
    ),
    TemplateModel(
      id: 101,
      category: 'Логистика',
      categoryColor: const Color(0x80D8AA74),
      title: 'Создай систему управления транспортом',
    ),
    TemplateModel(
      id: 102,
      category: 'Логистика',
      categoryColor: const Color(0x80D8AA74),
      title: 'Составь план работы с перевозчиками',
    ),
    TemplateModel(
      id: 103,
      category: 'Логистика',
      categoryColor: const Color(0x80D8AA74),
      title: 'Создай план управления запасами',
    ),
    TemplateModel(
      id: 104,
      category: 'Логистика',
      categoryColor: const Color(0x80D8AA74),
      title: 'Оптимизируй цепочку поставок',
    ),
  ];

  // Метод для получения шаблонов по категории
  static Future<List<TemplateModel>> getTemplatesByCategory(String category) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final prefs = await SharedPreferences.getInstance();
    
    return _templates
        .where((template) => template.category == category)
        .map((template) {
          final overrideTitle =
              prefs.getString('$_titlePrefKeyPrefix${template.id}');
          return TemplateModel(
            id: template.id,
            category: template.category,
            categoryColor: template.categoryColor,
            title: overrideTitle ?? template.title,
            isCustom: overrideTitle != null,
          );
        })
        .toList();
  }

  // Метод для обновления названия шаблона
  static Future<void> updateTemplateTitle(int id, String newTitle) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // Обновляем in‑memory список
    final index = _templates.indexWhere((t) => t.id == id);
    if (index != -1) {
      final template = _templates[index];
      _templates[index] = TemplateModel(
        id: template.id,
        category: template.category,
        categoryColor: template.categoryColor,
        title: newTitle,
        isCustom: true,
      );
    }

    // Сохраняем изменение в SharedPreferences, чтобы оно переживало перезапуск приложения
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_titlePrefKeyPrefix$id', newTitle);
  }
}
