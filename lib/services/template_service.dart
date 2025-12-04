import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/template_model.dart';
import '../utils/env_utils.dart';

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
    TemplateModel(
      id: 105,
      category: 'Маркетинг',
      categoryColor: const Color(0x80D300E6),
      title: 'Создай привлекательный заголовок для статьи',
    ),
    TemplateModel(
      id: 106,
      category: 'Маркетинг',
      categoryColor: const Color(0x80D300E6),
      title: 'Напиши описание для лендинга',
    ),
    TemplateModel(
      id: 107,
      category: 'Маркетинг',
      categoryColor: const Color(0x80D300E6),
      title: 'Составь план запуска продукта',
    ),
    TemplateModel(
      id: 108,
      category: 'Маркетинг',
      categoryColor: const Color(0x80D300E6),
      title: 'Создай текст для баннера',
    ),
    TemplateModel(
      id: 109,
      category: 'Маркетинг',
      categoryColor: const Color(0x80D300E6),
      title: 'Придумай слоган для бренда',
    ),
    TemplateModel(
      id: 110,
      category: 'Маркетинг',
      categoryColor: const Color(0x80D300E6),
      title: 'Составь план работы с инфлюенсерами',
    ),
    TemplateModel(
      id: 111,
      category: 'Маркетинг',
      categoryColor: const Color(0x80D300E6),
      title: 'Создай текст для push-уведомления',
    ),
    TemplateModel(
      id: 112,
      category: 'Маркетинг',
      categoryColor: const Color(0x80D300E6),
      title: 'Напиши описание для YouTube видео',
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
    TemplateModel(
      id: 113,
      category: 'Продажи',
      categoryColor: const Color(0x80007B0C),
      title: 'Составь план работы с воронкой продаж',
    ),
    TemplateModel(
      id: 114,
      category: 'Продажи',
      categoryColor: const Color(0x80007B0C),
      title: 'Создай презентацию для клиента',
    ),
    TemplateModel(
      id: 115,
      category: 'Продажи',
      categoryColor: const Color(0x80007B0C),
      title: 'Напиши текст для follow-up письма',
    ),
    TemplateModel(
      id: 116,
      category: 'Продажи',
      categoryColor: const Color(0x80007B0C),
      title: 'Составь план работы с отложенными сделками',
    ),
    TemplateModel(
      id: 117,
      category: 'Продажи',
      categoryColor: const Color(0x80007B0C),
      title: 'Создай систему мотивации для отдела продаж',
    ),
    TemplateModel(
      id: 118,
      category: 'Продажи',
      categoryColor: const Color(0x80007B0C),
      title: 'Напиши текст для предложения скидки',
    ),
    TemplateModel(
      id: 119,
      category: 'Продажи',
      categoryColor: const Color(0x80007B0C),
      title: 'Составь план работы с постоянными клиентами',
    ),
    TemplateModel(
      id: 120,
      category: 'Продажи',
      categoryColor: const Color(0x80007B0C),
      title: 'Создай скрипт для работы с возражениями',
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
    TemplateModel(
      id: 121,
      category: 'Стратегия',
      categoryColor: const Color(0x806F00E6),
      title: 'Составь долгосрочную стратегию развития',
    ),
    TemplateModel(
      id: 122,
      category: 'Стратегия',
      categoryColor: const Color(0x806F00E6),
      title: 'Создай план выхода на новый рынок',
    ),
    TemplateModel(
      id: 123,
      category: 'Стратегия',
      categoryColor: const Color(0x806F00E6),
      title: 'Составь план диверсификации бизнеса',
    ),
    TemplateModel(
      id: 124,
      category: 'Стратегия',
      categoryColor: const Color(0x806F00E6),
      title: 'Создай стратегию позиционирования бренда',
    ),
    TemplateModel(
      id: 125,
      category: 'Стратегия',
      categoryColor: const Color(0x806F00E6),
      title: 'Составь план партнерства с другими компаниями',
    ),
    TemplateModel(
      id: 126,
      category: 'Стратегия',
      categoryColor: const Color(0x806F00E6),
      title: 'Создай план масштабирования бизнеса',
    ),
    TemplateModel(
      id: 127,
      category: 'Стратегия',
      categoryColor: const Color(0x806F00E6),
      title: 'Составь план работы с кризисными ситуациями',
    ),
    TemplateModel(
      id: 128,
      category: 'Стратегия',
      categoryColor: const Color(0x806F00E6),
      title: 'Создай стратегию работы с сезонностью',
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
    TemplateModel(
      id: 129,
      category: 'Поддержка',
      categoryColor: const Color(0x809300E6),
      title: 'Создай шаблон ответа на частые вопросы',
    ),
    TemplateModel(
      id: 130,
      category: 'Поддержка',
      categoryColor: const Color(0x809300E6),
      title: 'Составь план работы с жалобами',
    ),
    TemplateModel(
      id: 131,
      category: 'Поддержка',
      categoryColor: const Color(0x809300E6),
      title: 'Напиши сообщение о решении проблемы',
    ),
    TemplateModel(
      id: 132,
      category: 'Поддержка',
      categoryColor: const Color(0x809300E6),
      title: 'Создай систему оценки качества поддержки',
    ),
    TemplateModel(
      id: 133,
      category: 'Поддержка',
      categoryColor: const Color(0x809300E6),
      title: 'Составь план обучения сотрудников поддержки',
    ),
    TemplateModel(
      id: 134,
      category: 'Поддержка',
      categoryColor: const Color(0x809300E6),
      title: 'Напиши текст для базы знаний',
    ),
    TemplateModel(
      id: 135,
      category: 'Поддержка',
      categoryColor: const Color(0x809300E6),
      title: 'Создай план работы с обратной связью клиентов',
    ),
    TemplateModel(
      id: 136,
      category: 'Поддержка',
      categoryColor: const Color(0x809300E6),
      title: 'Составь план работы в нерабочее время',
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
    TemplateModel(
      id: 137,
      category: 'Персонал',
      categoryColor: const Color(0x80E67F00),
      title: 'Составь план проведения собеседования',
    ),
    TemplateModel(
      id: 138,
      category: 'Персонал',
      categoryColor: const Color(0x80E67F00),
      title: 'Создай систему оценки сотрудников',
    ),
    TemplateModel(
      id: 139,
      category: 'Персонал',
      categoryColor: const Color(0x80E67F00),
      title: 'Составь план командообразования',
    ),
    TemplateModel(
      id: 140,
      category: 'Персонал',
      categoryColor: const Color(0x80E67F00),
      title: 'Напиши план развития карьеры сотрудника',
    ),
    TemplateModel(
      id: 141,
      category: 'Персонал',
      categoryColor: const Color(0x80E67F00),
      title: 'Создай план работы с конфликтами в коллективе',
    ),
    TemplateModel(
      id: 142,
      category: 'Персонал',
      categoryColor: const Color(0x80E67F00),
      title: 'Составь план удержания талантов',
    ),
    TemplateModel(
      id: 143,
      category: 'Персонал',
      categoryColor: const Color(0x80E67F00),
      title: 'Создай систему наставничества',
    ),
    TemplateModel(
      id: 144,
      category: 'Персонал',
      categoryColor: const Color(0x80E67F00),
      title: 'Составь план корпоративных мероприятий',
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
    TemplateModel(
      id: 145,
      category: 'Аналитика',
      categoryColor: const Color(0x8000AEEF),
      title: 'Создай дашборд ключевых метрик',
    ),
    TemplateModel(
      id: 146,
      category: 'Аналитика',
      categoryColor: const Color(0x8000AEEF),
      title: 'Проанализируй эффективность каналов привлечения',
    ),
    TemplateModel(
      id: 147,
      category: 'Аналитика',
      categoryColor: const Color(0x8000AEEF),
      title: 'Составь отчёт о ROI маркетинговых кампаний',
    ),
    TemplateModel(
      id: 148,
      category: 'Аналитика',
      categoryColor: const Color(0x8000AEEF),
      title: 'Создай анализ жизненного цикла клиента',
    ),
    TemplateModel(
      id: 149,
      category: 'Аналитика',
      categoryColor: const Color(0x8000AEEF),
      title: 'Проанализируй сезонные тренды',
    ),
    TemplateModel(
      id: 150,
      category: 'Аналитика',
      categoryColor: const Color(0x8000AEEF),
      title: 'Составь сравнительный анализ с конкурентами',
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
    TemplateModel(
      id: 151,
      category: 'Финансы',
      categoryColor: const Color(0x80FF69B4),
      title: 'Составь план инвестиций',
    ),
    TemplateModel(
      id: 152,
      category: 'Финансы',
      categoryColor: const Color(0x80FF69B4),
      title: 'Создай систему управления денежными потоками',
    ),
    TemplateModel(
      id: 153,
      category: 'Финансы',
      categoryColor: const Color(0x80FF69B4),
      title: 'Составь план работы с кредитами',
    ),
    TemplateModel(
      id: 154,
      category: 'Финансы',
      categoryColor: const Color(0x80FF69B4),
      title: 'Создай систему контроля расходов',
    ),
    TemplateModel(
      id: 155,
      category: 'Финансы',
      categoryColor: const Color(0x80FF69B4),
      title: 'Составь план налогового планирования',
    ),
    TemplateModel(
      id: 156,
      category: 'Финансы',
      categoryColor: const Color(0x80FF69B4),
      title: 'Создай прогноз финансовых показателей',
    ),
    TemplateModel(
      id: 157,
      category: 'Финансы',
      categoryColor: const Color(0x80FF69B4),
      title: 'Составь план работы с дебиторской задолженностью',
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
    TemplateModel(
      id: 158,
      category: 'HR',
      categoryColor: const Color(0x804682B4),
      title: 'Создай план адаптации новых сотрудников',
    ),
    TemplateModel(
      id: 159,
      category: 'HR',
      categoryColor: const Color(0x804682B4),
      title: 'Составь систему компенсаций и льгот',
    ),
    TemplateModel(
      id: 160,
      category: 'HR',
      categoryColor: const Color(0x804682B4),
      title: 'Создай план работы с увольнениями',
    ),
    TemplateModel(
      id: 161,
      category: 'HR',
      categoryColor: const Color(0x804682B4),
      title: 'Составь план развития лидерских качеств',
    ),
    TemplateModel(
      id: 162,
      category: 'HR',
      categoryColor: const Color(0x804682B4),
      title: 'Создай систему обратной связи от сотрудников',
    ),
    TemplateModel(
      id: 163,
      category: 'HR',
      categoryColor: const Color(0x804682B4),
      title: 'Составь план работы с удаленными сотрудниками',
    ),
    TemplateModel(
      id: 164,
      category: 'HR',
      categoryColor: const Color(0x804682B4),
      title: 'Создай план работы с внутренними коммуникациями',
    ),
    TemplateModel(
      id: 165,
      category: 'HR',
      categoryColor: const Color(0x804682B4),
      title: 'Составь план работы с производительностью',
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
    TemplateModel(
      id: 166,
      category: 'Операции',
      categoryColor: const Color(0x809370DB),
      title: 'Составь план автоматизации процессов',
    ),
    TemplateModel(
      id: 167,
      category: 'Операции',
      categoryColor: const Color(0x809370DB),
      title: 'Создай систему управления рисками',
    ),
    TemplateModel(
      id: 168,
      category: 'Операции',
      categoryColor: const Color(0x809370DB),
      title: 'Составь план работы с поставщиками',
    ),
    TemplateModel(
      id: 169,
      category: 'Операции',
      categoryColor: const Color(0x809370DB),
      title: 'Создай план работы с инвентаризацией',
    ),
    TemplateModel(
      id: 170,
      category: 'Операции',
      categoryColor: const Color(0x809370DB),
      title: 'Составь план работы с документацией',
    ),
    TemplateModel(
      id: 171,
      category: 'Операции',
      categoryColor: const Color(0x809370DB),
      title: 'Создай систему мониторинга процессов',
    ),
    TemplateModel(
      id: 172,
      category: 'Операции',
      categoryColor: const Color(0x809370DB),
      title: 'Составь план работы с инцидентами',
    ),
    TemplateModel(
      id: 173,
      category: 'Операции',
      categoryColor: const Color(0x809370DB),
      title: 'Создай план непрерывного улучшения',
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
    TemplateModel(
      id: 174,
      category: 'Розничная торговля',
      categoryColor: const Color(0x8061B3F9),
      title: 'Составь план работы с покупателями',
    ),
    TemplateModel(
      id: 175,
      category: 'Розничная торговля',
      categoryColor: const Color(0x8061B3F9),
      title: 'Создай план работы с возвратами',
    ),
    TemplateModel(
      id: 176,
      category: 'Розничная торговля',
      categoryColor: const Color(0x8061B3F9),
      title: 'Составь план работы с сезонными товарами',
    ),
    TemplateModel(
      id: 177,
      category: 'Розничная торговля',
      categoryColor: const Color(0x8061B3F9),
      title: 'Создай систему работы с промокодами',
    ),
    TemplateModel(
      id: 178,
      category: 'Розничная торговля',
      categoryColor: const Color(0x8061B3F9),
      title: 'Составь план работы с онлайн-продажами',
    ),
    TemplateModel(
      id: 179,
      category: 'Розничная торговля',
      categoryColor: const Color(0x8061B3F9),
      title: 'Создай план работы с программами лояльности',
    ),
    TemplateModel(
      id: 180,
      category: 'Розничная торговля',
      categoryColor: const Color(0x8061B3F9),
      title: 'Составь план работы с витриной',
    ),
    TemplateModel(
      id: 181,
      category: 'Розничная торговля',
      categoryColor: const Color(0x8061B3F9),
      title: 'Создай план работы с персоналом магазина',
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
    TemplateModel(
      id: 182,
      category: 'Производство',
      categoryColor: const Color(0x80669484),
      title: 'Составь план работы с оборудованием',
    ),
    TemplateModel(
      id: 183,
      category: 'Производство',
      categoryColor: const Color(0x80669484),
      title: 'Создай систему управления производственным планом',
    ),
    TemplateModel(
      id: 184,
      category: 'Производство',
      categoryColor: const Color(0x80669484),
      title: 'Составь план работы с браком',
    ),
    TemplateModel(
      id: 185,
      category: 'Производство',
      categoryColor: const Color(0x80669484),
      title: 'Создай план работы с энергоэффективностью',
    ),
    TemplateModel(
      id: 186,
      category: 'Производство',
      categoryColor: const Color(0x80669484),
      title: 'Составь план работы с экологией',
    ),
    TemplateModel(
      id: 187,
      category: 'Производство',
      categoryColor: const Color(0x80669484),
      title: 'Создай план работы с инновациями',
    ),
    TemplateModel(
      id: 188,
      category: 'Производство',
      categoryColor: const Color(0x80669484),
      title: 'Составь план работы с сертификацией',
    ),
    TemplateModel(
      id: 189,
      category: 'Производство',
      categoryColor: const Color(0x80669484),
      title: 'Создай план работы с упаковкой',
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
    TemplateModel(
      id: 190,
      category: 'IT/Технологии',
      categoryColor: const Color(0x803FC1C9),
      title: 'Составь план работы с безопасностью данных',
    ),
    TemplateModel(
      id: 191,
      category: 'IT/Технологии',
      categoryColor: const Color(0x803FC1C9),
      title: 'Создай план работы с облачными сервисами',
    ),
    TemplateModel(
      id: 192,
      category: 'IT/Технологии',
      categoryColor: const Color(0x803FC1C9),
      title: 'Составь план работы с API',
    ),
    TemplateModel(
      id: 193,
      category: 'IT/Технологии',
      categoryColor: const Color(0x803FC1C9),
      title: 'Создай план работы с DevOps',
    ),
    TemplateModel(
      id: 194,
      category: 'IT/Технологии',
      categoryColor: const Color(0x803FC1C9),
      title: 'Составь план работы с мобильными приложениями',
    ),
    TemplateModel(
      id: 195,
      category: 'IT/Технологии',
      categoryColor: const Color(0x803FC1C9),
      title: 'Создай план работы с искусственным интеллектом',
    ),
    TemplateModel(
      id: 196,
      category: 'IT/Технологии',
      categoryColor: const Color(0x803FC1C9),
      title: 'Составь план работы с кибербезопасностью',
    ),
    TemplateModel(
      id: 197,
      category: 'IT/Технологии',
      categoryColor: const Color(0x803FC1C9),
      title: 'Создай план работы с автоматизацией',
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
    TemplateModel(
      id: 198,
      category: 'Здравоохранение',
      categoryColor: const Color(0x80FF6B6B),
      title: 'Составь план работы с пациентами',
    ),
    TemplateModel(
      id: 199,
      category: 'Здравоохранение',
      categoryColor: const Color(0x80FF6B6B),
      title: 'Создай план работы с медицинским оборудованием',
    ),
    TemplateModel(
      id: 200,
      category: 'Здравоохранение',
      categoryColor: const Color(0x80FF6B6B),
      title: 'Составь план работы с лекарствами',
    ),
    TemplateModel(
      id: 201,
      category: 'Здравоохранение',
      categoryColor: const Color(0x80FF6B6B),
      title: 'Создай план работы с медицинским персоналом',
    ),
    TemplateModel(
      id: 202,
      category: 'Здравоохранение',
      categoryColor: const Color(0x80FF6B6B),
      title: 'Составь план работы с санитарными нормами',
    ),
    TemplateModel(
      id: 203,
      category: 'Здравоохранение',
      categoryColor: const Color(0x80FF6B6B),
      title: 'Создай план работы с экстренными ситуациями',
    ),
    TemplateModel(
      id: 204,
      category: 'Здравоохранение',
      categoryColor: const Color(0x80FF6B6B),
      title: 'Составь план работы с медицинской документацией',
    ),
    TemplateModel(
      id: 205,
      category: 'Здравоохранение',
      categoryColor: const Color(0x80FF6B6B),
      title: 'Создай план работы с профилактикой',
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
    TemplateModel(
      id: 206,
      category: 'Образование',
      categoryColor: const Color(0x806C5CE7),
      title: 'Составь план работы с учениками',
    ),
    TemplateModel(
      id: 207,
      category: 'Образование',
      categoryColor: const Color(0x806C5CE7),
      title: 'Создай план работы с родителями',
    ),
    TemplateModel(
      id: 208,
      category: 'Образование',
      categoryColor: const Color(0x806C5CE7),
      title: 'Составь план работы с учебными материалами',
    ),
    TemplateModel(
      id: 209,
      category: 'Образование',
      categoryColor: const Color(0x806C5CE7),
      title: 'Создай план работы с внеклассными мероприятиями',
    ),
    TemplateModel(
      id: 210,
      category: 'Образование',
      categoryColor: const Color(0x806C5CE7),
      title: 'Составь план работы с профессиональным развитием',
    ),
    TemplateModel(
      id: 211,
      category: 'Образование',
      categoryColor: const Color(0x806C5CE7),
      title: 'Создай план работы с инклюзивным образованием',
    ),
    TemplateModel(
      id: 212,
      category: 'Образование',
      categoryColor: const Color(0x806C5CE7),
      title: 'Составь план работы с цифровыми технологиями',
    ),
    TemplateModel(
      id: 213,
      category: 'Образование',
      categoryColor: const Color(0x806C5CE7),
      title: 'Создай план работы с оценкой качества образования',
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
    TemplateModel(
      id: 214,
      category: 'Недвижимость',
      categoryColor: const Color(0x80FD9853),
      title: 'Составь план работы с арендаторами',
    ),
    TemplateModel(
      id: 215,
      category: 'Недвижимость',
      categoryColor: const Color(0x80FD9853),
      title: 'Создай план работы с техническим обслуживанием',
    ),
    TemplateModel(
      id: 216,
      category: 'Недвижимость',
      categoryColor: const Color(0x80FD9853),
      title: 'Составь план работы с юридическими вопросами',
    ),
    TemplateModel(
      id: 217,
      category: 'Недвижимость',
      categoryColor: const Color(0x80FD9853),
      title: 'Создай план работы с инвестициями в недвижимость',
    ),
    TemplateModel(
      id: 218,
      category: 'Недвижимость',
      categoryColor: const Color(0x80FD9853),
      title: 'Составь план работы с ремонтом',
    ),
    TemplateModel(
      id: 219,
      category: 'Недвижимость',
      categoryColor: const Color(0x80FD9853),
      title: 'Создай план работы с коммунальными услугами',
    ),
    TemplateModel(
      id: 220,
      category: 'Недвижимость',
      categoryColor: const Color(0x80FD9853),
      title: 'Составь план работы с безопасностью',
    ),
    TemplateModel(
      id: 221,
      category: 'Недвижимость',
      categoryColor: const Color(0x80FD9853),
      title: 'Создай план работы с управлением объектами',
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
    TemplateModel(
      id: 222,
      category: 'Ресторанный бизнес',
      categoryColor: const Color(0x80FF9A9E),
      title: 'Составь план работы с персоналом ресторана',
    ),
    TemplateModel(
      id: 223,
      category: 'Ресторанный бизнес',
      categoryColor: const Color(0x80FF9A9E),
      title: 'Создай план работы с санитарными нормами',
    ),
    TemplateModel(
      id: 224,
      category: 'Ресторанный бизнес',
      categoryColor: const Color(0x80FF9A9E),
      title: 'Составь план работы с напитками',
    ),
    TemplateModel(
      id: 225,
      category: 'Ресторанный бизнес',
      categoryColor: const Color(0x80FF9A9E),
      title: 'Создай план работы с мероприятиями',
    ),
    TemplateModel(
      id: 226,
      category: 'Ресторанный бизнес',
      categoryColor: const Color(0x80FF9A9E),
      title: 'Составь план работы с доставкой',
    ),
    TemplateModel(
      id: 227,
      category: 'Ресторанный бизнес',
      categoryColor: const Color(0x80FF9A9E),
      title: 'Создай план работы с рекламой',
    ),
    TemplateModel(
      id: 228,
      category: 'Ресторанный бизнес',
      categoryColor: const Color(0x80FF9A9E),
      title: 'Составь план работы с отзывами',
    ),
    TemplateModel(
      id: 229,
      category: 'Ресторанный бизнес',
      categoryColor: const Color(0x80FF9A9E),
      title: 'Создай план работы с сезонным меню',
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
    TemplateModel(
      id: 230,
      category: 'Логистика',
      categoryColor: const Color(0x80D8AA74),
      title: 'Составь план работы с транспортом',
    ),
    TemplateModel(
      id: 231,
      category: 'Логистика',
      categoryColor: const Color(0x80D8AA74),
      title: 'Создай план работы с таможней',
    ),
    TemplateModel(
      id: 232,
      category: 'Логистика',
      categoryColor: const Color(0x80D8AA74),
      title: 'Составь план работы с упаковкой и маркировкой',
    ),
    TemplateModel(
      id: 233,
      category: 'Логистика',
      categoryColor: const Color(0x80D8AA74),
      title: 'Создай план работы с возвратами',
    ),
    TemplateModel(
      id: 234,
      category: 'Логистика',
      categoryColor: const Color(0x80D8AA74),
      title: 'Составь план работы с международной логистикой',
    ),
    TemplateModel(
      id: 235,
      category: 'Логистика',
      categoryColor: const Color(0x80D8AA74),
      title: 'Создай план работы с курьерскими службами',
    ),
    TemplateModel(
      id: 236,
      category: 'Логистика',
      categoryColor: const Color(0x80D8AA74),
      title: 'Составь план работы с отслеживанием грузов',
    ),
    TemplateModel(
      id: 237,
      category: 'Логистика',
      categoryColor: const Color(0x80D8AA74),
      title: 'Создай план работы с логистическими партнерами',
    ),

    // ------------------ ЕЖЕНЕДЕЛЬНЫЙ ОТЧЕТ ------------------
    TemplateModel(
      id: 238,
      category: 'Еженедельный отчет',
      categoryColor: const Color(0x8079BAEF),
      title: 'Создай еженедельный отчет о работе',
    ),
    TemplateModel(
      id: 253,
      category: 'Еженедельный отчет',
      categoryColor: const Color(0x8079BAEF),
      title: 'Составь отчет о выполненных задачах',
    ),
    TemplateModel(
      id: 254,
      category: 'Еженедельный отчет',
      categoryColor: const Color(0x8079BAEF),
      title: 'Создай отчет о продажах за неделю',
    ),
    TemplateModel(
      id: 255,
      category: 'Еженедельный отчет',
      categoryColor: const Color(0x8079BAEF),
      title: 'Составь отчет о работе команды',
    ),
    TemplateModel(
      id: 256,
      category: 'Еженедельный отчет',
      categoryColor: const Color(0x8079BAEF),
      title: 'Создай отчет о достижениях за неделю',
    ),
    TemplateModel(
      id: 257,
      category: 'Еженедельный отчет',
      categoryColor: const Color(0x8079BAEF),
      title: 'Составь отчет о маркетинговых активностях',
    ),
    TemplateModel(
      id: 258,
      category: 'Еженедельный отчет',
      categoryColor: const Color(0x8079BAEF),
      title: 'Создай отчет о финансовых показателях',
    ),
    TemplateModel(
      id: 259,
      category: 'Еженедельный отчет',
      categoryColor: const Color(0x8079BAEF),
      title: 'Составь отчет о работе с клиентами',
    ),
    TemplateModel(
      id: 260,
      category: 'Еженедельный отчет',
      categoryColor: const Color(0x8079BAEF),
      title: 'Создай отчет о проектах за неделю',
    ),
    TemplateModel(
      id: 261,
      category: 'Еженедельный отчет',
      categoryColor: const Color(0x8079BAEF),
      title: 'Составь отчет о производительности',
    ),
    TemplateModel(
      id: 262,
      category: 'Еженедельный отчет',
      categoryColor: const Color(0x8079BAEF),
      title: 'Создай отчет о проблемах и решениях',
    ),
    TemplateModel(
      id: 263,
      category: 'Еженедельный отчет',
      categoryColor: const Color(0x8079BAEF),
      title: 'Составь отчет о планах на следующую неделю',
    ),

    // ------------------ АНАЛИЗ РЫНКА ------------------
    TemplateModel(
      id: 239,
      category: 'Анализ рынка',
      categoryColor: const Color(0x80EE96A5),
      title: 'Проведи анализ рынка',
    ),
    TemplateModel(
      id: 264,
      category: 'Анализ рынка',
      categoryColor: const Color(0x80EE96A5),
      title: 'Создай анализ конкурентов',
    ),
    TemplateModel(
      id: 265,
      category: 'Анализ рынка',
      categoryColor: const Color(0x80EE96A5),
      title: 'Составь анализ целевой аудитории',
    ),
    TemplateModel(
      id: 266,
      category: 'Анализ рынка',
      categoryColor: const Color(0x80EE96A5),
      title: 'Проведи анализ трендов в отрасли',
    ),
    TemplateModel(
      id: 267,
      category: 'Анализ рынка',
      categoryColor: const Color(0x80EE96A5),
      title: 'Создай анализ ценовой политики',
    ),
    TemplateModel(
      id: 268,
      category: 'Анализ рынка',
      categoryColor: const Color(0x80EE96A5),
      title: 'Составь анализ маркетинговых каналов',
    ),
    TemplateModel(
      id: 269,
      category: 'Анализ рынка',
      categoryColor: const Color(0x80EE96A5),
      title: 'Проведи анализ сегментации рынка',
    ),
    TemplateModel(
      id: 270,
      category: 'Анализ рынка',
      categoryColor: const Color(0x80EE96A5),
      title: 'Создай анализ продуктового портфеля',
    ),
    TemplateModel(
      id: 271,
      category: 'Анализ рынка',
      categoryColor: const Color(0x80EE96A5),
      title: 'Составь анализ географического рынка',
    ),
    TemplateModel(
      id: 272,
      category: 'Анализ рынка',
      categoryColor: const Color(0x80EE96A5),
      title: 'Проведи анализ потребительского поведения',
    ),
    TemplateModel(
      id: 273,
      category: 'Анализ рынка',
      categoryColor: const Color(0x80EE96A5),
      title: 'Создай анализ рыночных возможностей',
    ),
    TemplateModel(
      id: 274,
      category: 'Анализ рынка',
      categoryColor: const Color(0x80EE96A5),
      title: 'Составь анализ барьеров входа на рынок',
    ),
    TemplateModel(
      id: 275,
      category: 'Анализ рынка',
      categoryColor: const Color(0x80EE96A5),
      title: 'Проведи анализ динамики рынка',
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

  // Метод для получения user_id
  static Future<String?> _getUserId() async {
    try {
      await dotenv.load(fileName: ".env");
      await EnvUtils.mergeRuntimeEnvIntoDotenv();
      final userId = dotenv.env['USER_ID'];
      if (userId != null && userId.isNotEmpty) {
        return userId;
      }
    } catch (e) {
      // Игнорируем ошибки
    }
    return null;
  }

  // Метод для получения ключа для хранения шаблонов пользователя
  static Future<String> _getPersonalTemplatesKey() async {
    final userId = await _getUserId();
    if (userId != null && userId.isNotEmpty) {
      return 'personal_templates_$userId';
    }
    return 'personal_templates_anonymous';
  }

  // Метод для получения пользовательских шаблонов
  static Future<List<TemplateModel>> getPersonalTemplates() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final prefs = await SharedPreferences.getInstance();
    final key = await _getPersonalTemplatesKey();
    final customTemplatesJson = prefs.getStringList(key) ?? [];
    
    final List<TemplateModel> personalTemplates = [];
    for (final jsonString in customTemplatesJson) {
      try {
        // Используем простой подход - храним как строку "id|title"
        final parts = jsonString.split('|');
        if (parts.length >= 2) {
          final id = int.tryParse(parts[0]) ?? 0;
          final title = parts[1];
          personalTemplates.add(TemplateModel(
            id: id,
            category: 'Персональные',
            categoryColor: const Color(0x80DD41B6),
            title: title,
            isCustom: true,
          ));
        }
      } catch (e) {
        // Игнорируем ошибки парсинга
      }
    }
    
    return personalTemplates;
  }

  // Метод для создания нового пользовательского шаблона
  static Future<TemplateModel> createPersonalTemplate(String title) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final prefs = await SharedPreferences.getInstance();
    final key = await _getPersonalTemplatesKey();
    final customTemplatesJson = prefs.getStringList(key) ?? [];
    
    // Генерируем новый ID (максимальный существующий + 1, или начинаем с 10000)
    int newId = 10000;
    for (final jsonString in customTemplatesJson) {
      final parts = jsonString.split('|');
      if (parts.length >= 1) {
        final id = int.tryParse(parts[0]) ?? 0;
        if (id >= newId) {
          newId = id + 1;
        }
      }
    }
    
    // Создаем новый шаблон
    final newTemplate = TemplateModel(
      id: newId,
      category: 'Персональные',
      categoryColor: const Color(0x80DD41B6),
      title: title,
      isCustom: true,
    );
    
    // Сохраняем в SharedPreferences с привязкой к user_id
    customTemplatesJson.add('$newId|$title');
    await prefs.setStringList(key, customTemplatesJson);
    
    return newTemplate;
  }

  // Метод для обновления пользовательского шаблона
  static Future<void> updatePersonalTemplate(int id, String newTitle) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final prefs = await SharedPreferences.getInstance();
    final key = await _getPersonalTemplatesKey();
    final customTemplatesJson = prefs.getStringList(key) ?? [];
    
    // Обновляем шаблон в списке
    for (int i = 0; i < customTemplatesJson.length; i++) {
      final parts = customTemplatesJson[i].split('|');
      if (parts.length >= 1) {
        final templateId = int.tryParse(parts[0]) ?? 0;
        if (templateId == id) {
          customTemplatesJson[i] = '$id|$newTitle';
          break;
        }
      }
    }
    
    await prefs.setStringList(key, customTemplatesJson);
  }

  // Метод для получения ключа для хранения папок пользователя
  static Future<String> _getPersonalFoldersKey() async {
    final userId = await _getUserId();
    if (userId != null && userId.isNotEmpty) {
      return 'personal_folders_$userId';
    }
    return 'personal_folders_anonymous';
  }

  // Метод для получения пользовательских папок
  static Future<List<Map<String, dynamic>>> getPersonalFolders() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final prefs = await SharedPreferences.getInstance();
    final key = await _getPersonalFoldersKey();
    final foldersJson = prefs.getStringList(key) ?? [];
    
    final List<Map<String, dynamic>> folders = [];
    for (final jsonString in foldersJson) {
      try {
        // Храним как строку "id|name"
        final parts = jsonString.split('|');
        if (parts.length >= 2) {
          final id = int.tryParse(parts[0]) ?? 0;
          final name = parts[1];
          folders.add({
            'id': id,
            'name': name,
          });
        }
      } catch (e) {
        // Игнорируем ошибки парсинга
      }
    }
    
    return folders;
  }

  // Метод для создания новой папки
  static Future<Map<String, dynamic>> createPersonalFolder(String name) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final prefs = await SharedPreferences.getInstance();
    final key = await _getPersonalFoldersKey();
    final foldersJson = prefs.getStringList(key) ?? [];
    
    // Генерируем новый ID (максимальный существующий + 1, или начинаем с 20000)
    int newId = 20000;
    for (final jsonString in foldersJson) {
      final parts = jsonString.split('|');
      if (parts.length >= 1) {
        final id = int.tryParse(parts[0]) ?? 0;
        if (id >= newId) {
          newId = id + 1;
        }
      }
    }
    
    // Сохраняем в SharedPreferences с привязкой к user_id
    foldersJson.add('$newId|$name');
    await prefs.setStringList(key, foldersJson);
    
    return {
      'id': newId,
      'name': name,
    };
  }
}
