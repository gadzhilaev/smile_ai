import 'package:flutter/material.dart';
import '../settings/style.dart';
import '../settings/colors.dart';
import '../l10n/app_localizations.dart';

import '../models/template_model.dart';
import '../services/template_service.dart';
import '../widgets/custom_refresh_indicator.dart';
import 'templates_screen_localized_title_helper.dart';

class TemplatesScreen extends StatefulWidget {
  const TemplatesScreen({
    super.key,
    this.onApplyTemplate,
    this.onEditTemplate,
  });

  final void Function(String, String)? onApplyTemplate;
  final void Function(String, ValueChanged<String>)? onEditTemplate;

  @override
  State<TemplatesScreen> createState() => _TemplatesScreenState();
}

class _TemplatesScreenState extends State<TemplatesScreen> {
  static const double _designWidth = 428;
  static const double _designHeight = 926;

  List<TemplateModel> _templates = [];
  bool _isLoading = true;
  final ScrollController _scrollController = ScrollController();
  final Set<String> _expandedCategories = <String>{};

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  Future<void> _loadTemplates() async {
    // Загружаем данные из сервиса
    final templates = await TemplateService.getAllTemplates();
    
    if (mounted) {
      setState(() {
        // Всегда обновляем список новыми данными
        _templates = List<TemplateModel>.from(templates);
        _isLoading = false;
        // По умолчанию все группы закрыты (свернуты)
        // _expandedCategories остается пустым
      });
    }
  }

  void _toggleCategory(String category) {
    setState(() {
      if (_expandedCategories.contains(category)) {
        _expandedCategories.remove(category);
      } else {
        _expandedCategories.add(category);
      }
    });
  }

  Map<String, List<TemplateModel>> _groupTemplatesByCategory() {
    final Map<String, List<TemplateModel>> grouped = {};
    for (final template in _templates) {
      if (!grouped.containsKey(template.category)) {
        grouped[template.category] = [];
      }
      grouped[template.category]!.add(template);
    }
    return grouped;
  }

  Future<void> _updateTemplate(int id, String newTitle) async {
    await TemplateService.updateTemplateTitle(id, newTitle);
    await _loadTemplates();
  }

  Future<void> _refreshTemplates() async {
    // Сбрасываем состояние для полной перестройки страницы
    if (mounted) {
      setState(() {
        _isLoading = true;
        _templates = [];
      });
      // Сбрасываем позицию прокрутки
      _scrollController.jumpTo(0);
    }
    
    // Небольшая задержка для отображения состояния загрузки
    await Future.delayed(const Duration(milliseconds: 100));
    
    // Перезагружаем данные - принудительно обновляем с forceRefresh
    final templates = await TemplateService.getAllTemplates(forceRefresh: true);
    
    if (mounted) {
      // Всегда обновляем список, даже если кажется, что данные не изменились
      setState(() {
        // Создаем новый список для принудительного обновления UI
        _templates = List<TemplateModel>.from(templates);
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final size = MediaQuery.of(context).size;
    final double widthFactor = size.width / _designWidth;
    final double heightFactor = size.height / _designHeight;

    double scaleWidth(double value) => value * widthFactor;
    double scaleHeight(double value) => value * heightFactor;

    final l = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackgroundMain : AppColors.backgroundMain,
      body: SafeArea(
        top: true,
        bottom: false,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Фиксированный заголовок
                  SizedBox(height: scaleHeight(16)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: scaleWidth(24)),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                  Center(
                    child: Text(
                      l.templatesTitle,
                      style: AppTextStyle.screenTitleMedium(
                        scaleHeight(20),
                        color: isDark
                            ? AppColors.white
                            : theme.colorScheme.onSurface,
                      ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          child: Icon(
                            Icons.edit,
                            size: scaleHeight(24),
                            color: isDark
                                ? AppColors.white
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: scaleHeight(34)),
                  // Прокручиваемый контент
                  Expanded(
                    child: _templates.isEmpty
                        ? CustomRefreshIndicator(
                            onRefresh: _refreshTemplates,
                            designWidth: _designWidth,
                            designHeight: _designHeight,
                            child: SingleChildScrollView(
                              controller: _scrollController,
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: SizedBox(
                                height: MediaQuery.of(context).size.height * 0.6,
                                child: Center(
                                  child: Text(
                                    l.templatesEmpty,
                                    style: AppTextStyle.bodyTextMedium(
                                      16,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        : CustomRefreshIndicator(
                            onRefresh: _refreshTemplates,
                            designWidth: _designWidth,
                            designHeight: _designHeight,
                            child: SingleChildScrollView(
                              controller: _scrollController,
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: scaleWidth(24),
                                ),
                                child: Column(
                                  children: [
                                    ..._buildTemplateGroups(
                                      scaleWidth,
                                      scaleHeight,
                                      theme,
                                      isDark,
                                      l,
                                      ),
                                    // Отступ после последнего контейнера для нав бара
                                    SizedBox(height: scaleHeight(20)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                  ),
                ],
              ),
      ),
    );
  }

  List<Widget> _buildTemplateGroups(
    double Function(double) scaleWidth,
    double Function(double) scaleHeight,
    ThemeData theme,
    bool isDark,
    AppLocalizations l,
  ) {
    final grouped = _groupTemplatesByCategory();
    final List<Widget> widgets = [];
    final categories = grouped.keys.toList();
    
    // Сортируем категории в определенном порядке
    final categoryOrder = [
      'Маркетинг',
      'Продажи',
      'Стратегия',
      'Поддержка',
      'Персонал',
      'Аналитика',
    ];
    categories.sort((a, b) {
      final indexA = categoryOrder.indexOf(a);
      final indexB = categoryOrder.indexOf(b);
      if (indexA == -1 && indexB == -1) return a.compareTo(b);
      if (indexA == -1) return 1;
      if (indexB == -1) return -1;
      return indexA.compareTo(indexB);
    });

    for (int i = 0; i < categories.length; i++) {
      final category = categories[i];
      final templates = grouped[category]!;
      final isExpanded = _expandedCategories.contains(category);
      
      widgets.add(
        _TemplateGroup(
          category: category,
          templates: templates,
          isExpanded: isExpanded,
          onToggle: () => _toggleCategory(category),
          designWidth: _designWidth,
          designHeight: _designHeight,
          onApplyTemplate: widget.onApplyTemplate,
          onEditTemplate: (templateText, onSaved) {
            if (widget.onEditTemplate != null) {
              // Находим шаблон по тексту
              TemplateModel? templateModel;
              for (final t in templates) {
                final title = t.isCustom
                    ? t.title
                    : localizedTemplateTitle(l, t.id);
                if (title == templateText) {
                  templateModel = t;
                  break;
                }
              }
              
              if (templateModel != null) {
                widget.onEditTemplate!(
                  templateText,
                  (editedText) {
                    _updateTemplate(templateModel!.id, editedText);
                    onSaved(editedText);
                  },
                );
              }
            }
          },
          scaleWidth: scaleWidth,
          scaleHeight: scaleHeight,
          theme: theme,
          isDark: isDark,
          l: l,
        ),
      );
      
      if (i < categories.length - 1) {
        widgets.add(SizedBox(height: scaleHeight(20)));
      }
    }
    
    return widgets;
  }
}

class _TemplateGroup extends StatelessWidget {
  const _TemplateGroup({
    required this.category,
    required this.templates,
    required this.isExpanded,
    required this.onToggle,
    required this.designWidth,
    required this.designHeight,
    required this.onApplyTemplate,
    required this.onEditTemplate,
    required this.scaleWidth,
    required this.scaleHeight,
    required this.theme,
    required this.isDark,
    required this.l,
  });

  final String category;
  final List<TemplateModel> templates;
  final bool isExpanded;
  final VoidCallback onToggle;
  final double designWidth;
  final double designHeight;
  final void Function(String, String)? onApplyTemplate;
  final void Function(String, ValueChanged<String>)? onEditTemplate;
  final double Function(double) scaleWidth;
  final double Function(double) scaleHeight;
  final ThemeData theme;
  final bool isDark;
  final AppLocalizations l;

  String _getLocalizedCategoryName() {
    switch (category) {
      case 'Маркетинг':
        return l.templateCategoryMarketing;
      case 'Продажи':
        return l.templateCategorySales;
      case 'Стратегия':
        return l.templateCategoryStrategy;
      case 'Поддержка':
        return l.templateCategorySupport;
      case 'Персонал':
        return l.templateCategoryStaff;
      case 'Аналитика':
        return l.templateCategoryAnalytics;
      default:
        return category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Заголовок группы
        InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(scaleHeight(12)),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: scaleWidth(14),
              vertical: scaleHeight(12),
            ),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkBackgroundCard : AppColors.white,
              borderRadius: BorderRadius.circular(scaleHeight(12)),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.overlayShadow,
                  offset: Offset(0, 14),
                  blurRadius: 64,
                  spreadRadius: -4,
                ),
                BoxShadow(
                  color: AppColors.overlayShadow,
                  offset: Offset(0, 8),
                  blurRadius: 22,
                  spreadRadius: -6,
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  size: scaleHeight(24),
                  color: isDark
                      ? AppColors.white
                      : theme.colorScheme.onSurface,
                ),
                SizedBox(width: scaleWidth(12)),
                Expanded(
                  child: Text(
                    _getLocalizedCategoryName(),
                    style: AppTextStyle.screenTitleMedium(
                      scaleHeight(18),
                      color: isDark
                          ? AppColors.white
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Шаблоны группы (показываются только если развернуто)
        if (isExpanded) ...[
          SizedBox(height: scaleHeight(12)),
          ...templates.asMap().entries.map((entry) {
            final index = entry.key;
            final template = entry.value;
            return Padding(
              padding: EdgeInsets.only(
                bottom: index < templates.length - 1
                    ? scaleHeight(20)
                    : 0,
              ),
              child: _TemplateCard(
                template: template,
                designWidth: designWidth,
                designHeight: designHeight,
                onApplyTemplate: onApplyTemplate,
                onEditTemplate: onEditTemplate,
              ),
            );
          }),
        ],
      ],
    );
  }
}

class _TemplateCard extends StatelessWidget {
  const _TemplateCard({
    required this.template,
    required this.designWidth,
    required this.designHeight,
    this.onApplyTemplate,
    this.onEditTemplate,
  });

  final TemplateModel template;
  final double designWidth;
  final double designHeight;
  final void Function(String, String)? onApplyTemplate;
  final void Function(String, ValueChanged<String>)? onEditTemplate;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final size = MediaQuery.of(context).size;
    final double widthFactor = size.width / designWidth;
    final double heightFactor = size.height / designHeight;

    double scaleWidth(double value) => value * widthFactor;
    double scaleHeight(double value) => value * heightFactor;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackgroundCard : AppColors.white,
        borderRadius: BorderRadius.circular(scaleHeight(12)),
        boxShadow: const [
          BoxShadow(
            color: AppColors.overlayShadow,
            offset: Offset(0, 14),
            blurRadius: 64,
            spreadRadius: -4,
          ),
          BoxShadow(
            color: AppColors.overlayShadow,
            offset: Offset(0, 8),
            blurRadius: 22,
            spreadRadius: -6,
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(
        horizontal: scaleWidth(14),
        vertical: scaleHeight(11),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: scaleWidth(14),
                  vertical: scaleHeight(4.5),
                ),
                constraints: BoxConstraints(
                  minHeight: scaleHeight(21),
                ),
                decoration: BoxDecoration(
                  color: template.categoryColor,
                  borderRadius: BorderRadius.circular(scaleHeight(64)),
                ),
                alignment: Alignment.center,
                child: Text(
                  () {
                    switch (template.category) {
                      case 'Маркетинг':
                        return l.templateCategoryMarketing;
                      case 'Продажи':
                        return l.templateCategorySales;
                      case 'Стратегия':
                        return l.templateCategoryStrategy;
                      case 'Поддержка':
                        return l.templateCategorySupport;
                      case 'Персонал':
                        return l.templateCategoryStaff;
                      case 'Аналитика':
                        return l.templateCategoryAnalytics;
                      default:
                        return template.category;
                    }
                  }(),
                  style: AppTextStyle.templateCategory(scaleHeight(12)),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          SizedBox(height: scaleHeight(7.5)),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              template.isCustom
                  ? template.title
                  : localizedTemplateTitle(l, template.id),
              textAlign: TextAlign.left,
              style: AppTextStyle.templateTitle(
                scaleHeight(16),
              ).copyWith(
                height: 18 / 16,
                color: isDark ? AppColors.white : AppColors.textPrimary,
              ),
            ),
          ),
          SizedBox(height: scaleHeight(24)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () {
                  if (onApplyTemplate != null) {
                    // Используем локализованный title шаблона
                    final templateText = template.isCustom
                        ? template.title
                        : localizedTemplateTitle(l, template.id);
                    onApplyTemplate!(templateText, template.category);
                  }
                },
                borderRadius: BorderRadius.circular(scaleHeight(16)),
                child: Container(
                  width: scaleWidth(187),
                  height: scaleHeight(41),
                  decoration: BoxDecoration(
                    gradient: isDark
                        ? const LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Color(0xFF1F2937),
                              Color(0xFF374151),
                            ],
                          )
                        : const LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Color(0xFFCBE5F8),
                              Color(0xFFD6D7F8),
                            ],
                            stops: [0.0, 0.7816],
                          ),
                    borderRadius: BorderRadius.circular(scaleHeight(16)),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    l.templateApply,
                    style: AppTextStyle.templateButton(
                      scaleHeight(14),
                    ).copyWith(
                      color:
                          isDark ? AppColors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  if (onEditTemplate != null) {
                    // Используем локализованный title шаблона
                    final templateText = template.isCustom
                        ? template.title
                        : localizedTemplateTitle(l, template.id);
                    onEditTemplate!(templateText, (editedText) {
                      // Callback будет вызван из AiScreen после сохранения
                    });
                  }
                },
                borderRadius: BorderRadius.circular(scaleHeight(16)),
                child: Container(
                  width: scaleWidth(152),
                  height: scaleHeight(41),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E293B)
                        : const Color(0x801E293B),
                    borderRadius: BorderRadius.circular(scaleHeight(16)),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    l.templateEdit,
                    style: AppTextStyle.templateButtonWhite(
                      scaleHeight(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
