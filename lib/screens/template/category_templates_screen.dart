import 'package:flutter/material.dart';
import '../../settings/style.dart';
import '../../settings/colors.dart';
import '../../l10n/app_localizations.dart';
import '../../models/template_model.dart';
import '../../services/template_service.dart';
import '../../widgets/custom_refresh_indicator.dart';
import '../../utils/template_localization_helper.dart';

class CategoryTemplatesScreen extends StatefulWidget {
  const CategoryTemplatesScreen({
    super.key,
    required this.categoryName,
    this.categoryId,
    this.onApplyTemplate,
    this.onEditTemplate,
  });

  final String categoryName;
  final String? categoryId; // ID категории для поиска шаблонов независимо от языка
  final void Function(String, String)? onApplyTemplate;
  final void Function(String, ValueChanged<String>)? onEditTemplate;

  @override
  State<CategoryTemplatesScreen> createState() => _CategoryTemplatesScreenState();
}

class _CategoryTemplatesScreenState extends State<CategoryTemplatesScreen> {
  static const double _designWidth = 428;
  static const double _designHeight = 926;

  List<TemplateModel> _templates = [];
  bool _isLoading = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  Future<void> _loadTemplates() async {
    // Используем categoryId, если он передан, иначе используем локализованное название
    final categoryKey = widget.categoryId ?? widget.categoryName;
    final templates = await TemplateService.getTemplatesByCategory(categoryKey);
    
    if (mounted) {
      setState(() {
        _templates = templates;
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshTemplates() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _templates = [];
      });
      _scrollController.jumpTo(0);
    }
    
    await Future.delayed(const Duration(milliseconds: 100));
    
    // Используем categoryId, если он передан, иначе используем локализованное название
    final categoryKey = widget.categoryId ?? widget.categoryName;
    final templates = await TemplateService.getTemplatesByCategory(categoryKey);
    
    if (mounted) {
      setState(() {
        _templates = templates;
        _isLoading = false;
      });
    }
  }

  Future<void> _updateTemplate(int id, String newTitle) async {
    await TemplateService.updateTemplateTitle(id, newTitle);
    await _loadTemplates();
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок с кнопкой назад
            SizedBox(height: scaleHeight(16)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: scaleWidth(24)),
              child: Row(
                children: [
                  // Кнопка назад
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      size: scaleHeight(24),
                      color: isDark
                          ? AppColors.white
                          : theme.colorScheme.onSurface,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  // Название категории
                  Expanded(
                    child: Text(
                      widget.categoryName,
                      style: AppTextStyle.screenTitleMedium(
                        scaleHeight(20),
                        color: isDark
                            ? AppColors.white
                            : theme.colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // Пустое место для центрирования
                  SizedBox(width: scaleWidth(48)),
                ],
              ),
            ),
            SizedBox(height: scaleHeight(10)),
            // Прокручиваемый контент
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _templates.isEmpty
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
                                  ..._templates.asMap().entries.map((entry) {
                                    final index = entry.key;
                                    final template = entry.value;
                                    return Padding(
                                      padding: EdgeInsets.only(
                                        bottom: index < _templates.length - 1
                                            ? scaleHeight(20)
                                            : 0,
                                      ),
                                      child: _TemplateCard(
                                        template: template,
                                        designWidth: _designWidth,
                                        designHeight: _designHeight,
                                        onApplyTemplate: widget.onApplyTemplate,
                                        onEditTemplate: (templateText, onSaved) {
                                          if (widget.onEditTemplate != null) {
                                            widget.onEditTemplate!(
                                              templateText,
                                              (editedText) {
                                                _updateTemplate(template.id, editedText);
                                                onSaved(editedText);
                                              },
                                            );
                                          }
                                        },
                                      ),
                                    );
                                  }),
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
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              getLocalizedTemplateTitle(l, template),
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
                    // Закрываем экран категории
                    Navigator.of(context).pop();
                    // Вызываем callback для переключения на AI экран
                    onApplyTemplate!(getLocalizedTemplateTitle(l, template), template.category);
                  }
                },
                borderRadius: BorderRadius.circular(scaleHeight(16)),
                child: Container(
                  width: scaleWidth(187),
                  height: scaleHeight(41),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
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
                    // Закрываем экран категории
                    Navigator.of(context).pop();
                    // Вызываем callback для переключения на AI экран
                    onEditTemplate!(getLocalizedTemplateTitle(l, template), (editedText) {
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

