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
  static Future<List<TemplateModel>> getAllTemplates({bool forceRefresh = false}) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // Загружаем сохраненные шаблоны или используем дефолтные
    // Всегда возвращаем новый список с новыми объектами для правильного обновления UI
    return _templates.map((template) => TemplateModel(
      id: template.id,
      category: template.category,
      categoryColor: template.categoryColor,
      title: template.title,
      description: template.description,
    )).toList();
  }

  // Временное хранилище шаблонов (в будущем будет API)
  static final List<TemplateModel> _templates = [
    TemplateModel(
      id: 0,
      category: 'Маркетинг',
      categoryColor: const Color(0x80D300E6), // Фиолетовый цвет с прозрачностью
      title: 'Оптимизируйте время публикации в социальных сетях для максимального охвата',
      description: 'Наши данные показывают, что ваша аудитория наиболее активна с 18:00 до 21:00 по будням.',
    ),
    TemplateModel(
      id: 1,
      category: 'Продажи',
      categoryColor: const Color(0x80007B0C), // Зеленый цвет с прозрачностью
      title: 'Оптимизируйте время публикации в социальных сетях для максимального охвата',
      description: 'Наши данные показывают, что ваша аудитория наиболее активна с 18:00 до 21:00 по будням.',
    ),
    TemplateModel(
      id: 2,
      category: 'Стратеги',
      categoryColor: const Color(0x806F00E6), // Зеленый цвет с прозрачностью
      title: 'Оптимизируйте время публикации в социальных сетях для максимального охвата',
      description: 'Наши данные показывают, что ваша аудитория наиболее активна с 18:00 до 21:00 по будням.',
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
        description: template.description,
      );
    }
  }
}

