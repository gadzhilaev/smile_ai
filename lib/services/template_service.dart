import 'package:flutter/material.dart';

import '../models/template_model.dart';

class TemplateService {
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

    // Загружаем сохраненные шаблоны или используем дефолтные
    // Всегда возвращаем новый список с новыми объектами для правильного обновления UI
    return _templates
        .map(
          (template) => TemplateModel(
            id: template.id,
            category: template.category,
            categoryColor: template.categoryColor,
            title: template.title,
          ),
        )
        .toList();
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
  ];

  // Метод для обновления названия шаблона
  static Future<void> updateTemplateTitle(int id, String newTitle) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _templates.indexWhere((t) => t.id == id);
    if (index != -1) {
      final template = _templates[index];
      _templates[index] = TemplateModel(
        id: template.id,
        category: template.category,
        categoryColor: template.categoryColor,
        title: newTitle,
      );
    }
  }
}
