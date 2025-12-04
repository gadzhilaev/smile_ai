import '../l10n/app_localizations.dart';
import '../models/template_model.dart';
import '../screens/template/templates_screen_localized_title_helper.dart';

/// Helper функция для получения локализованного названия шаблона
/// Для персональных шаблонов (isCustom == true) возвращает оригинальное название
String getLocalizedTemplateTitle(AppLocalizations l, TemplateModel template) {
  // Если шаблон персональный, возвращаем оригинальное название
  if (template.isCustom) {
    return template.title;
  }
  
  // Используем helper функцию для получения локализованного названия по ID
  final localizedTitle = localizedTemplateTitle(l, template.id);
  
  // Если локализация не найдена, возвращаем оригинальное название
  // Это временное решение - когда будут добавлены все ключи локализации,
  // все шаблоны будут локализованы
  return localizedTitle.isNotEmpty ? localizedTitle : template.title;
}

