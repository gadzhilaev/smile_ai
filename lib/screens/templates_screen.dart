import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
                    padding: EdgeInsets.symmetric(horizontal: scaleWidth(32)),
                    child: Center(
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
                              child: Column(
                                children: [
                                  _buildPopularSection(
                                    scaleWidth,
                                    scaleHeight,
                                    theme,
                                    isDark,
                                  ),
                                  // Отступ после последнего контейнера для нав бара
                                  SizedBox(height: scaleHeight(20)),
                                ],
                              ),
                            ),
                          ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildPopularSection(
    double Function(double) scaleWidth,
    double Function(double) scaleHeight,
    ThemeData theme,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Текст "Популярные" с отступами 32 по бокам
        Padding(
          padding: EdgeInsets.symmetric(horizontal: scaleWidth(32)),
          child: Text(
            'Популярные',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w600,
              fontSize: scaleHeight(18),
              color: const Color(0xFF201D2F),
            ),
          ),
        ),
        // Отступ снизу 14
        SizedBox(height: scaleHeight(14)),
        // Два контейнера в ряд
        Padding(
          padding: EdgeInsets.symmetric(horizontal: scaleWidth(32)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Левый контейнер
              Container(
                width: scaleWidth(173),
                height: scaleHeight(158),
                padding: EdgeInsets.only(
                  top: scaleHeight(10),
                  bottom: scaleHeight(10),
                  left: scaleWidth(18),
                  right: scaleWidth(18),
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    // 131.34deg от левого верхнего к правому нижнему
                    begin: const Alignment(-1.0, -1.0),
                    end: const Alignment(1.0, 1.0),
                    colors: const [
                      Color(0xFF73F1BF),
                      Color(0xFF79BAEF),
                    ],
                    stops: const [0.1107, 1.0],
                  ),
                  borderRadius: BorderRadius.circular(scaleHeight(13)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      offset: const Offset(0, 2),
                      blurRadius: 8,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Иконка
                    SvgPicture.asset(
                      'assets/icons/templates/lights/icon_otchet.svg',
                      width: scaleWidth(70),
                      height: scaleHeight(70),
                      fit: BoxFit.contain,
                      allowDrawingOutsideViewBox: true,
                    ),
                    // Отступ между иконкой и текстом
                    SizedBox(height: scaleHeight(8)),
                    // Текст
                    Text(
                      'Еженедельный отчет',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                        fontSize: scaleHeight(14),
                        height: 22 / 14,
                        letterSpacing: 0,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              // Правый контейнер
              Container(
                width: scaleWidth(173),
                height: scaleHeight(158),
                padding: EdgeInsets.only(
                  top: scaleHeight(10),
                  bottom: scaleHeight(10),
                  left: scaleWidth(18),
                  right: scaleWidth(18),
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    // 129.51deg от левого верхнего к правому нижнему
                    begin: const Alignment(-1.0, -1.0),
                    end: const Alignment(1.0, 1.0),
                    colors: const [
                      Color(0xFFF9CD84),
                      Color(0xFFEE96A5),
                    ],
                    stops: const [0.0, 0.9489],
                  ),
                  borderRadius: BorderRadius.circular(scaleHeight(13)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      offset: const Offset(0, 2),
                      blurRadius: 8,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Иконка
                    SvgPicture.asset(
                      'assets/icons/templates/lights/icon_rocket.svg',
                      width: scaleWidth(70),
                      height: scaleHeight(70),
                      fit: BoxFit.contain,
                      allowDrawingOutsideViewBox: true,
                    ),
                    // Отступ между иконкой и текстом
                    SizedBox(height: scaleHeight(8)),
                    // Текст
                    Text(
                      'Анализ рынка',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                        fontSize: scaleHeight(14),
                        height: 22 / 14,
                        letterSpacing: 0,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Отступ снизу 18
        SizedBox(height: scaleHeight(18)),
        // Текст "Бизнес-цели"
        Padding(
          padding: EdgeInsets.symmetric(horizontal: scaleWidth(32)),
          child: Text(
            'Бизнес-цели',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w600,
              fontSize: scaleHeight(18),
              color: const Color(0xFF201D2F),
            ),
          ),
        ),
        // Отступ снизу 14
        SizedBox(height: scaleHeight(14)),
        // Горизонтальный скролл с контейнерами
        SizedBox(
          height: scaleHeight(176),
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: scaleWidth(32)),
            children: [
              // Первый контейнер - Маркетинг
              Container(
                width: scaleWidth(110),
                height: scaleHeight(176),
                padding: EdgeInsets.symmetric(vertical: scaleHeight(28)),
                margin: EdgeInsets.only(right: scaleWidth(17)),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    // 161.45deg
                    begin: const Alignment(-1.0, -1.0),
                    end: const Alignment(1.0, 1.0),
                    colors: const [
                      Color(0xFFCDC0EF),
                      Color(0xFFBC9FF4),
                    ],
                    stops: const [0.0526, 0.9049],
                  ),
                  borderRadius: BorderRadius.circular(scaleHeight(13)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      offset: const Offset(0, 2),
                      blurRadius: 8,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Иконка сверху
                    SvgPicture.asset(
                      'assets/icons/templates/lights/icon_marketing.svg',
                      width: scaleWidth(60),
                      height: scaleHeight(60),
                      fit: BoxFit.contain,
                      allowDrawingOutsideViewBox: true,
                    ),
                    // Текст снизу
                    Text(
                      'Маркетинг',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                        fontSize: scaleHeight(14),
                        height: 22 / 14,
                        letterSpacing: 0,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              // Второй контейнер - Стратегия
              Container(
                width: scaleWidth(110),
                height: scaleHeight(176),
                padding: EdgeInsets.symmetric(vertical: scaleHeight(28)),
                margin: EdgeInsets.only(right: scaleWidth(17)),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    // 158.66deg
                    begin: const Alignment(-1.0, -1.0),
                    end: const Alignment(1.0, 1.0),
                    colors: const [
                      Color(0xFF62F8CB),
                      Color(0xFF5EDCD3),
                    ],
                    stops: const [0.0, 1.0],
                  ),
                  borderRadius: BorderRadius.circular(scaleHeight(13)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      offset: const Offset(0, 2),
                      blurRadius: 8,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Иконка сверху
                    SvgPicture.asset(
                      'assets/icons/templates/lights/icon_strategy.svg',
                      width: scaleWidth(60),
                      height: scaleHeight(60),
                      fit: BoxFit.contain,
                      allowDrawingOutsideViewBox: true,
                    ),
                    // Текст снизу
                    Text(
                      'Стратегия',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                        fontSize: scaleHeight(14),
                        height: 22 / 14,
                        letterSpacing: 0,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              // Третий контейнер - Продажи
              Container(
                width: scaleWidth(110),
                height: scaleHeight(176),
                padding: EdgeInsets.symmetric(vertical: scaleHeight(28)),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    // 163.3deg
                    begin: const Alignment(-1.0, -1.0),
                    end: const Alignment(1.0, 1.0),
                    colors: const [
                      Color(0xFFF9E080),
                      Color(0xFFFCC881),
                    ],
                    stops: const [0.0535, 1.0],
                  ),
                  borderRadius: BorderRadius.circular(scaleHeight(13)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      offset: const Offset(0, 2),
                      blurRadius: 8,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Иконка сверху
                    SvgPicture.asset(
                      'assets/icons/templates/lights/icon_money.svg',
                      width: scaleWidth(60),
                      height: scaleHeight(60),
                      fit: BoxFit.contain,
                      allowDrawingOutsideViewBox: true,
                    ),
                    // Текст снизу
                    Text(
                      'Продажи',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                        fontSize: scaleHeight(14),
                        height: 22 / 14,
                        letterSpacing: 0,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Отступ снизу 18
        SizedBox(height: scaleHeight(18)),
        // Текст "Отраслевые"
        Padding(
          padding: EdgeInsets.symmetric(horizontal: scaleWidth(32)),
          child: Text(
            'Отраслевые',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w600,
              fontSize: scaleHeight(18),
              color: const Color(0xFF201D2F),
            ),
          ),
        ),
        // Отступ снизу 14
        SizedBox(height: scaleHeight(14)),
        // Горизонтальный скролл с контейнерами
        SizedBox(
          height: scaleHeight(176),
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: scaleWidth(32)),
            children: [
              // Первый контейнер - Маркетинг
              Container(
                width: scaleWidth(110),
                height: scaleHeight(176),
                padding: EdgeInsets.symmetric(vertical: scaleHeight(28)),
                margin: EdgeInsets.only(right: scaleWidth(17)),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    // 161.36deg
                    begin: const Alignment(-1.0, -1.0),
                    end: const Alignment(1.0, 1.0),
                    colors: const [
                      Color(0xFF59DEEC),
                      Color(0xFF61B3F9),
                    ],
                    stops: const [0.0, 0.9656],
                  ),
                  borderRadius: BorderRadius.circular(scaleHeight(13)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      offset: const Offset(0, 2),
                      blurRadius: 8,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Иконка сверху
                    SvgPicture.asset(
                      'assets/icons/templates/lights/icon_bag.svg',
                      width: scaleWidth(60),
                      height: scaleHeight(60),
                      fit: BoxFit.contain,
                      allowDrawingOutsideViewBox: true,
                    ),
                    // Текст снизу
                    Text(
                      'Маркетинг',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                        fontSize: scaleHeight(14),
                        height: 22 / 14,
                        letterSpacing: 0,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              // Второй контейнер - Стратегия
              Container(
                width: scaleWidth(110),
                height: scaleHeight(176),
                padding: EdgeInsets.symmetric(vertical: scaleHeight(28)),
                margin: EdgeInsets.only(right: scaleWidth(17)),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    // 163.96deg
                    begin: const Alignment(-1.0, -1.0),
                    end: const Alignment(1.0, 1.0),
                    colors: const [
                      Color(0xFFAFCDBF),
                      Color(0xFF669484),
                    ],
                    stops: const [0.0892, 0.9553],
                  ),
                  borderRadius: BorderRadius.circular(scaleHeight(13)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      offset: const Offset(0, 2),
                      blurRadius: 8,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Иконка сверху
                    SvgPicture.asset(
                      'assets/icons/templates/lights/icon_ruki.svg',
                      width: scaleWidth(60),
                      height: scaleHeight(60),
                      fit: BoxFit.contain,
                      allowDrawingOutsideViewBox: true,
                    ),
                    // Текст снизу
                    Text(
                      'Стратегия',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                        fontSize: scaleHeight(14),
                        height: 22 / 14,
                        letterSpacing: 0,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              // Третий контейнер - Продажи
              Container(
                width: scaleWidth(110),
                height: scaleHeight(176),
                padding: EdgeInsets.symmetric(vertical: scaleHeight(28)),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    // 170.82deg
                    begin: const Alignment(-1.0, -1.0),
                    end: const Alignment(1.0, 1.0),
                    colors: const [
                      Color(0xFFDEC879),
                      Color(0xFFD8AA74),
                    ],
                    stops: const [0.0303, 0.9488],
                  ),
                  borderRadius: BorderRadius.circular(scaleHeight(13)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      offset: const Offset(0, 2),
                      blurRadius: 8,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Иконка сверху
                    SvgPicture.asset(
                      'assets/icons/templates/lights/icon_sell.svg',
                      width: scaleWidth(60),
                      height: scaleHeight(60),
                      fit: BoxFit.contain,
                      allowDrawingOutsideViewBox: true,
                    ),
                    // Текст снизу
                    Text(
                      'Продажи',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                        fontSize: scaleHeight(14),
                        height: 22 / 14,
                        letterSpacing: 0,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
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
