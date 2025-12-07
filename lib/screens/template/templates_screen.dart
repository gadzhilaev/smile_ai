import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../settings/style.dart';
import '../../settings/colors.dart';
import '../../l10n/app_localizations.dart';

import '../../models/template_model.dart';
import '../../services/template_service.dart';
import '../../widgets/custom_refresh_indicator.dart';
import '../../widgets/syllable_text.dart';
import 'category_templates_screen.dart';
import 'personal_templates_screen.dart';

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
  List<Map<String, dynamic>> _personalFolders = [];
  bool _isLoading = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadTemplates();
    _loadPersonalFolders();
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

  Future<void> _loadPersonalFolders() async {
    final folders = await TemplateService.getPersonalFolders();
    if (mounted) {
      setState(() {
        _personalFolders = folders;
      });
  }
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
                                    l,
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
    AppLocalizations l,
  ) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        // Текст "Популярные" с отступами 32 по бокам
        Padding(
          padding: EdgeInsets.symmetric(horizontal: scaleWidth(32)),
                child: Text(
            l.templatesSectionPopular,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w600,
              fontSize: scaleHeight(18),
              color: isDark ? AppColors.darkPrimaryText : const Color(0xFF201D2F),
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
              InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CategoryTemplatesScreen(
                        categoryName: l.templatesWeeklyReport,
                        categoryId: 'weekly_report',
                        onApplyTemplate: widget.onApplyTemplate,
                        onEditTemplate: widget.onEditTemplate,
                      ),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(scaleHeight(13)),
                child: Container(
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
                        color: Colors.black.withValues(alpha: 0.1),
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
                      _buildIcon(
                        _getIconPath(
                          'assets/icons_template/lights/icon_otchet.svg',
                          darkIconPath: 'assets/icons_template/dark/icon_otchet.svg',
                          isDark: isDark,
                        ),
                        scaleWidth(70),
                        scaleHeight(70),
                        isDark: isDark,
                      ),
                      // Отступ между иконкой и текстом
                      SizedBox(height: scaleHeight(8)),
                      // Текст
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: scaleWidth(5)),
                          child: SyllableText(
                            text: l.templatesWeeklyReport,
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w600,
                              fontSize: scaleHeight(14),
                              height: 22 / 14,
                              letterSpacing: 0,
                              color: isDark ? AppColors.darkPrimaryText : Colors.black,
                            ),
                            textAlign: TextAlign.left,
                            maxLines: 3,
                          ),
                        ),
          ),
        ],
      ),
                ),
              ),
              // Правый контейнер
              InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CategoryTemplatesScreen(
                        categoryName: l.templatesMarketAnalysis,
                        categoryId: 'market_analysis',
                        onApplyTemplate: widget.onApplyTemplate,
                        onEditTemplate: widget.onEditTemplate,
                      ),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(scaleHeight(13)),
                child: Container(
                  width: scaleWidth(173),
                  height: scaleHeight(158),
                  padding: EdgeInsets.only(
                    top: scaleHeight(10),
                    bottom: scaleHeight(10),
                    left: scaleWidth(5),
                    right: scaleWidth(5),
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
                        color: Colors.black.withValues(alpha: 0.1),
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
                      _buildIcon(
                        _getIconPath(
                          'assets/icons_template/lights/icon_rocket.svg',
                          darkIconPath: 'assets/icons_template/dark/icon_rocket.svg',
                          isDark: isDark,
                        ),
                        scaleWidth(70),
                        scaleHeight(70),
                        isDark: isDark,
                      ),
                      // Отступ между иконкой и текстом
                      SizedBox(height: scaleHeight(8)),
                      // Текст
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: scaleWidth(5)),
                          child: SyllableText(
                            text: l.templatesMarketAnalysis,
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w600,
                              fontSize: scaleHeight(14),
                              height: 22 / 14,
                              letterSpacing: 0,
                              color: isDark ? AppColors.darkPrimaryText : Colors.black,
                            ),
                            textAlign: TextAlign.left,
                            maxLines: 3,
                          ),
                        ),
                      ),
                    ],
                  ),
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
            l.templatesSectionBusinessGoals,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w600,
              fontSize: scaleHeight(18),
              color: isDark ? AppColors.darkPrimaryText : const Color(0xFF201D2F),
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
            children: _buildBusinessGoalsContainers(scaleWidth, scaleHeight, isDark, l),
          ),
        ),
        // Отступ снизу 18
        SizedBox(height: scaleHeight(18)),
        // Текст "Отраслевые"
        Padding(
          padding: EdgeInsets.symmetric(horizontal: scaleWidth(32)),
          child: Text(
            l.templatesSectionIndustry,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w600,
              fontSize: scaleHeight(18),
              color: isDark ? AppColors.darkPrimaryText : const Color(0xFF201D2F),
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
            children: _buildIndustryContainers(scaleWidth, scaleHeight, isDark, l),
          ),
        ),
        // Отступ снизу 18
        SizedBox(height: scaleHeight(18)),
        // Текст "Персональные"
        Padding(
          padding: EdgeInsets.symmetric(horizontal: scaleWidth(32)),
          child: Text(
            l.templatesSectionPersonal,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w600,
              fontSize: scaleHeight(18),
              color: isDark ? AppColors.darkPrimaryText : const Color(0xFF201D2F),
            ),
          ),
        ),
        // Отступ снизу 14
        SizedBox(height: scaleHeight(14)),
        // Контейнеры папок и кнопка "Добавить папку"
        Padding(
          padding: EdgeInsets.symmetric(horizontal: scaleWidth(32)),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Первый контейнер - Ваши шаблоны
                InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PersonalTemplatesScreen(
                          onApplyTemplate: widget.onApplyTemplate,
                          onEditTemplate: widget.onEditTemplate,
                        ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(scaleHeight(13)),
                  child: Container(
                    width: scaleWidth(110),
                    height: scaleHeight(176),
                    padding: EdgeInsets.symmetric(vertical: scaleHeight(28)),
                    margin: EdgeInsets.only(right: scaleWidth(17)),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        // 160.29deg
                        begin: const Alignment(-1.0, -1.0),
                        end: const Alignment(1.0, 1.0),
                          colors: const [
                                Color(0xFFEB91D4),
                                Color(0xFFDD41B6),
                              ],
                        stops: const [0.0886, 1.0],
                      ),
                      borderRadius: BorderRadius.circular(scaleHeight(13)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          offset: const Offset(0, 2),
                          blurRadius: 8,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: scaleWidth(5)),
                        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
                            Text(
                              l.templatesYourTemplatesLine1,
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w600,
                                fontSize: scaleHeight(14),
                                height: 22 / 14,
                                letterSpacing: 0,
                                color: isDark ? AppColors.white : Colors.black,
                              ),
                              textAlign: TextAlign.left,
                            ),
                            Text(
                              l.templatesYourTemplatesLine2,
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w600,
                                fontSize: scaleHeight(14),
                                height: 22 / 14,
                                letterSpacing: 0,
                                color: isDark ? AppColors.white : Colors.black,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Папки пользователя
                ..._personalFolders.map((folder) {
                  return InkWell(
                    onTap: () {
                      // Открыть экран с шаблонами папки
                    },
                    borderRadius: BorderRadius.circular(scaleHeight(13)),
                    child: Container(
                      width: scaleWidth(110),
                      height: scaleHeight(176),
                      padding: EdgeInsets.symmetric(
                        vertical: scaleHeight(28),
                        horizontal: scaleWidth(5),
                ),
                      margin: EdgeInsets.only(right: scaleWidth(17)),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          // 160.29deg
                          begin: const Alignment(-1.0, -1.0),
                          end: const Alignment(1.0, 1.0),
                          colors: const [
                                  Color(0xFFEB91D4),
                                  Color(0xFFDD41B6),
                                ],
                          stops: const [0.0886, 1.0],
                        ),
                        borderRadius: BorderRadius.circular(scaleHeight(13)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            offset: const Offset(0, 2),
                            blurRadius: 8,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: scaleWidth(5)),
                          child: SyllableText(
                            text: folder['name'] as String,
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w600,
                              fontSize: scaleHeight(14),
                              height: 22 / 14,
                              letterSpacing: 0,
                              color: isDark ? AppColors.darkPrimaryText : Colors.black,
                            ),
                            textAlign: TextAlign.left,
                            maxLines: 3,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
                // Последний контейнер - Добавить папку
                InkWell(
                  onTap: () => _showAddFolderDialog(context, scaleWidth, scaleHeight),
                  borderRadius: BorderRadius.circular(scaleHeight(13)),
                  child: Container(
                    width: scaleWidth(110),
                    height: scaleHeight(176),
                decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(scaleHeight(13)),
                    ),
                    child: Stack(
                      children: [
                        // Пунктирная обводка
                        CustomPaint(
                          size: Size(scaleWidth(110), scaleHeight(176)),
                          painter: _DashedBorderPainter(
                            color: const Color(0xFF9E9E9E),
                            strokeWidth: 1,
                            borderRadius: scaleHeight(13),
                          ),
                ),
                        // Контент по центру
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Иконка плюсик
                              Icon(
                                Icons.add,
                                size: scaleHeight(24),
                                color: const Color(0xFF9E9E9E),
                              ),
                              // Текст без отступа
                              Text(
                                l.templatesAddFolder,
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w600,
                                  fontSize: scaleHeight(8),
                                  height: 1.0,
                                  letterSpacing: 0,
                                  color: const Color(0xFF9E9E9E),
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildBusinessGoalsContainers(
    double Function(double) scaleWidth,
    double Function(double) scaleHeight,
    bool isDark,
    AppLocalizations l,
  ) {
    final List<Map<String, dynamic>> businessGoals = [
      {
        'title': l.templatesCategoryMarketing,
        'categoryId': 'marketing',
        'icon': 'assets/icons_template/lights/icon_marketing.svg',
        'darkIcon': 'assets/icons_template/dark/icon_marketing.svg',
        'gradient': [Color(0xFFCDC0EF), Color(0xFFBC9FF4)],
        'darkGradient': [Color(0xFF5A4B7F), Color(0xFF4A3A6F)],
        'stops': [0.0526, 0.9049],
      },
      {
        'title': l.templatesCategoryStrategy,
        'categoryId': 'strategy',
        'icon': 'assets/icons_template/lights/icon_strategy.svg',
        'darkIcon': 'assets/icons_template/dark/icon_strategy.svg',
        'gradient': [Color(0xFF62F8CB), Color(0xFF5EDCD3)],
        'darkGradient': [Color(0xFF2A8873), Color(0xFF277269)],
        'stops': [0.0, 1.0],
      },
      {
        'title': l.templatesCategorySales,
        'categoryId': 'sales',
        'icon': 'assets/icons_template/lights/icon_money.svg',
        'darkIcon': 'assets/icons_template/dark/icon_money.svg',
        'gradient': [Color(0xFFF9E080), Color(0xFFFCC881)],
        'darkGradient': [Color(0xFF897840), Color(0xFF8A7841)],
        'stops': [0.0535, 1.0],
      },
      {
        'title': l.templatesCategoryFinance,
        'categoryId': 'finance',
        'icon': 'assets/icons_template/lights/icon_chart.svg',
        'darkIcon': 'assets/icons_template/dark/icon_chart.svg',
        'gradient': [Color(0xFFFFB6C1), Color(0xFFFF69B4)],
        'darkGradient': [Color(0xFF8C6269), Color(0xFF8C3A64)],
        'stops': [0.0, 1.0],
      },
      {
        'title': l.templatesCategoryHR,
        'categoryId': 'hr',
        'icon': 'assets/icons_template/lights/icon_team.svg',
        'darkIcon': 'assets/icons_template/dark/icon_team.svg',
        'gradient': [Color(0xFF87CEEB), Color(0xFF4682B4)],
        'darkGradient': [Color(0xFF3F6E8B), Color(0xFF1E3A5A)],
        'stops': [0.0, 1.0],
      },
      {
        'title': l.templatesCategoryOperations,
        'categoryId': 'operations',
        'icon': 'assets/icons_template/lights/icon_gear.svg',
        'darkIcon': 'assets/icons_template/dark/icon_gear.svg',
        'gradient': [Color(0xFFDDA0DD), Color(0xFF9370DB)],
        'darkGradient': [Color(0xFF6D507D), Color(0xFF43306B)],
        'stops': [0.0, 1.0],
      },
      {
        'title': l.templatesCategorySupport,
        'categoryId': 'support',
        'icon': 'assets/icons_template/lights/icon_supp.svg',
        'darkIcon': 'assets/icons_template/dark/icon_supp.svg',
        'gradient': [Color(0xFFF0E68C), Color(0xFFFFD700)],
        'darkGradient': [Color(0xFF80764C), Color(0xFF8C6D00)],
        'stops': [0.0, 1.0],
      },
      {
        'title': l.templatesCategoryAnalytics,
        'categoryId': 'analytics',
        'icon': 'assets/icons_template/lights/icon_otchet.svg',
        'darkIcon': 'assets/icons_template/dark/icon_otchet.svg',
        'gradient': [Color(0xFF98D8C8), Color(0xFF17A2B8)],
        'darkGradient': [Color(0xFF387868), Color(0xFF0F4A58)],
        'stops': [0.0, 1.0],
      },
    ];

    return businessGoals.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final isLast = index == businessGoals.length - 1;
      
      // Безопасное получение градиента
      // В темной теме цвета градиента переворачиваются (верх ↔ низ)
      List<Color> gradientColors = (item['gradient'] as List<dynamic>)
          .map((c) => c as Color)
          .toList();
      if (isDark) {
        // В темной теме переворачиваем цвета градиента
        gradientColors = gradientColors.reversed.toList();
      }
      final gradientStops = (item['stops'] as List<dynamic>)
          .map((s) => s as double)
          .toList();

      return InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CategoryTemplatesScreen(
                categoryName: item['title'] as String,
                categoryId: item['categoryId'] as String?,
                onApplyTemplate: widget.onApplyTemplate,
                onEditTemplate: widget.onEditTemplate,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(scaleHeight(13)),
        child: Container(
          width: scaleWidth(110),
          height: scaleHeight(176),
          padding: EdgeInsets.symmetric(
            vertical: scaleHeight(28),
            horizontal: scaleWidth(5),
          ),
          margin: EdgeInsets.only(right: isLast ? 0 : scaleWidth(17)),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: const Alignment(-1.0, -1.0),
              end: const Alignment(1.0, 1.0),
              colors: gradientColors,
              stops: gradientStops,
            ),
            borderRadius: BorderRadius.circular(scaleHeight(13)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A000000),
                offset: Offset(0, 2),
                blurRadius: 8,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Иконка сверху
              _buildIcon(
                _getIconPath(
                  item['icon'] as String,
                  darkIconPath: item['darkIcon'] as String?,
                  isDark: isDark,
                ),
                scaleWidth(60),
                scaleHeight(60),
                isDark: isDark,
              ),
              // Текст снизу
              Flexible(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: scaleWidth(5)),
                  child: SyllableText(
                    text: item['title'] as String,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600,
                      fontSize: scaleHeight(14),
                      height: 22 / 14,
                      letterSpacing: 0,
                      color: isDark ? AppColors.darkPrimaryText : Colors.black,
                    ),
                  textAlign: TextAlign.center,
                    maxLines: 3,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _buildIndustryContainers(
    double Function(double) scaleWidth,
    double Function(double) scaleHeight,
    bool isDark,
    AppLocalizations l,
  ) {
    final List<Map<String, dynamic>> industries = [
      {
        'title': l.templatesCategoryRetail,
        'categoryId': 'retail',
        'icon': 'assets/icons_template/lights/icon_bag.svg',
        'darkIcon': 'assets/icons_template/dark/icon_bag.svg',
        'gradient': [Color(0xFF59DEEC), Color(0xFF61B3F9)],
        'darkGradient': [Color(0xFF1F5E6C), Color(0xFF214379)],
        'stops': [0.0, 0.9656],
      },
      {
        'title': l.templatesCategoryManufacturing,
        'categoryId': 'manufacturing',
        'icon': 'assets/icons_template/lights/icon_ruki.svg',
        'darkIcon': 'assets/icons_template/dark/icon_ruki.svg',
        'gradient': [Color(0xFFAFCDBF), Color(0xFF669484)],
        'darkGradient': [Color(0xFF3F5D4F), Color(0xFF22433A)],
        'stops': [0.0892, 0.9553],
      },
      {
        'title': l.templatesCategoryIT,
        'categoryId': 'it',
        'icon': 'assets/icons_template/lights/icon_computer.svg',
        'darkIcon': 'assets/icons_template/dark/icon_computer.svg',
        'gradient': [Color(0xFFA8E6CF), Color(0xFF3FC1C9)],
        'darkGradient': [Color(0xFF38766F), Color(0xFF0F5159)],
        'stops': [0.0, 1.0],
      },
      {
        'title': l.templatesCategoryHealthcare,
        'categoryId': 'healthcare',
        'icon': 'assets/icons_template/lights/icon_health.svg',
        'darkIcon': 'assets/icons_template/dark/icon_health.svg',
        'gradient': [Color(0xFFFFB3BA), Color(0xFFFF6B6B)],
        'darkGradient': [Color(0xFF8C6269), Color(0xFF8C3535)],
        'stops': [0.0, 1.0],
      },
      {
        'title': l.templatesCategoryEducation,
        'categoryId': 'education',
        'icon': 'assets/icons_template/lights/icon_education.svg',
        'darkIcon': 'assets/icons_template/dark/icon_education.svg',
        'gradient': [Color(0xFFC7CEEA), Color(0xFF6C5CE7)],
        'darkGradient': [Color(0xFF475E7A), Color(0xFF2A1C67)],
        'stops': [0.0, 1.0],
      },
      {
        'title': l.templatesCategoryRealEstate,
        'categoryId': 'realestate',
        'icon': 'assets/icons_template/lights/icon_home.svg',
        'darkIcon': 'assets/icons_template/dark/icon_home.svg',
        'gradient': [Color(0xFFFFD3A5), Color(0xFFFD9853)],
        'darkGradient': [Color(0xFF8C6355), Color(0xFF8B4823)],
        'stops': [0.0, 1.0],
      },
      {
        'title': l.templatesCategoryRestaurant,
        'categoryId': 'restaurant',
        'icon': 'assets/icons_template/lights/icon_restaurant.svg',
        'darkIcon': 'assets/icons_template/dark/icon_restaurant.svg',
        'gradient': [Color(0xFFFEC8D8), Color(0xFFFF9A9E)],
        'darkGradient': [Color(0xFF8E6068), Color(0xFF8C4A4E)],
        'stops': [0.0, 1.0],
      },
      {
        'title': l.templatesCategoryLogistics,
        'categoryId': 'logistics',
        'icon': 'assets/icons_template/lights/icon_sell.svg',
        'darkIcon': 'assets/icons_template/dark/icon_sell.svg',
        'gradient': [Color(0xFFDEC879), Color(0xFFD8AA74)],
        'darkGradient': [Color(0xFF6E6839), Color(0xFF685A3C)],
        'stops': [0.0303, 0.9488],
      },
    ];

    return industries.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final isLast = index == industries.length - 1;
      
      // Безопасное получение градиента
      // В темной теме цвета градиента переворачиваются (верх ↔ низ)
      List<Color> gradientColors = (item['gradient'] as List<dynamic>)
          .map((c) => c as Color)
          .toList();
      if (isDark) {
        // В темной теме переворачиваем цвета градиента
        gradientColors = gradientColors.reversed.toList();
      }
      final gradientStops = (item['stops'] as List<dynamic>)
          .map((s) => s as double)
          .toList();

      return InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CategoryTemplatesScreen(
                categoryName: item['title'] as String,
                categoryId: item['categoryId'] as String?,
                onApplyTemplate: widget.onApplyTemplate,
                onEditTemplate: widget.onEditTemplate,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(scaleHeight(13)),
        child: Container(
          width: scaleWidth(110),
          height: scaleHeight(176),
          padding: EdgeInsets.symmetric(
            vertical: scaleHeight(28),
            horizontal: scaleWidth(5),
          ),
          margin: EdgeInsets.only(right: isLast ? 0 : scaleWidth(17)),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: const Alignment(-1.0, -1.0),
              end: const Alignment(1.0, 1.0),
              colors: gradientColors,
              stops: gradientStops,
            ),
            borderRadius: BorderRadius.circular(scaleHeight(13)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A000000),
                offset: Offset(0, 2),
                blurRadius: 8,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Иконка сверху
              _buildIcon(
                _getIconPath(
                  item['icon'] as String,
                  darkIconPath: item['darkIcon'] as String?,
                  isDark: isDark,
                ),
                scaleWidth(60),
                scaleHeight(60),
                isDark: isDark,
              ),
              // Текст снизу
              Flexible(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: scaleWidth(5)),
                  child: SyllableText(
                    text: item['title'] as String,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600,
                      fontSize: scaleHeight(14),
                      height: 22 / 14,
                      letterSpacing: 0,
                      color: isDark ? AppColors.darkPrimaryText : Colors.black,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  void _showAddFolderDialog(BuildContext context, double Function(double) scaleWidth, double Function(double) scaleHeight) {
    final TextEditingController textController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (BuildContext context) {
        final l = AppLocalizations.of(context)!;
        final dialogTheme = Theme.of(context);
        final dialogIsDark = dialogTheme.brightness == Brightness.dark;
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: scaleWidth(24)),
                child: Container(
            width: scaleWidth(380),
            height: scaleHeight(260),
            padding: EdgeInsets.symmetric(
              horizontal: scaleWidth(15),
              vertical: scaleHeight(18),
            ),
                  decoration: BoxDecoration(
              color: dialogIsDark ? AppColors.darkBackgroundCard : Colors.white,
              borderRadius: BorderRadius.circular(scaleHeight(12)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1F18274B),
                  offset: Offset(0, 14),
                  blurRadius: 64,
                  spreadRadius: -4,
                ),
                BoxShadow(
                  color: Color(0x1F18274B),
                  offset: Offset(0, 8),
                  blurRadius: 22,
                  spreadRadius: -6,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Заголовок и крестик в одной строке
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        l.templatesAddNewFolder,
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w500,
                          fontSize: scaleHeight(20),
                          height: 1.0,
                            color: dialogIsDark ? AppColors.darkPrimaryText : const Color(0xFF5B5B5B),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(scaleHeight(12)),
                      child: Container(
                        width: scaleWidth(24),
                        height: scaleHeight(24),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.close,
                          size: scaleHeight(24),
                            color: dialogIsDark ? AppColors.darkPrimaryText : const Color(0xFF5B5B5B),
                        ),
                      ),
                    ),
                            ],
                ),
                SizedBox(height: scaleHeight(20)),
                // Текстовое поле - занимает все доступное пространство
                Expanded(
                  child: Builder(
                    builder: (context) {
                      return Container(
                        width: scaleWidth(352),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(scaleHeight(14)),
                          border: Border.all(
                            color: dialogIsDark 
                                ? AppColors.darkDivider 
                                : const Color(0x8CA3A3A3),
                            width: 1,
                          ),
                        ),
                        child: TextField(
                          controller: textController,
                          maxLines: null,
                          expands: true,
                          textAlignVertical: TextAlignVertical.top,
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                            fontSize: scaleHeight(14),
                            height: 22 / 14,
                            letterSpacing: 0,
                            color: dialogIsDark ? AppColors.darkPrimaryText : Colors.black,
                          ),
                          decoration: InputDecoration(
                            hintText: l.templatesEnterFolderName,
                            hintStyle: TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w500,
                              fontSize: scaleHeight(14),
                              height: 22 / 14,
                              letterSpacing: 0,
                              color: dialogIsDark 
                                  ? AppColors.darkSecondaryText 
                                  : const Color(0xFFA3A3A3),
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(scaleHeight(12)),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: scaleHeight(20)),
                // Кнопка
                Builder(
                  builder: (dialogContext) {
                    return InkWell(
                      onTap: () async {
                        final text = textController.text.trim();
                        if (text.isNotEmpty) {
                          await TemplateService.createPersonalFolder(text);
                          if (!mounted) return;
                          if (dialogContext.mounted) {
                            Navigator.of(dialogContext).pop();
                          }
                            await _loadPersonalFolders();
                  }
                },
                borderRadius: BorderRadius.circular(scaleHeight(16)),
                child: Container(
                        width: scaleWidth(352),
                  height: scaleHeight(41),
                  decoration: BoxDecoration(
                          color: dialogIsDark ? AppColors.darkPrimaryText : Colors.black,
                    borderRadius: BorderRadius.circular(scaleHeight(16)),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                          l.templatesAdd,
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                            fontSize: scaleHeight(14),
                            color: dialogIsDark ? AppColors.darkBackgroundMain : Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
              ),
          ),
        );
      },
    );
  }

  /// Получает путь к иконке в зависимости от темы
  /// Если указана иконка для темной темы, использует её, иначе использует иконку для светлой темы
  String _getIconPath(String lightIconPath, {String? darkIconPath, required bool isDark}) {
    if (isDark && darkIconPath != null && darkIconPath.isNotEmpty) {
      return darkIconPath;
    }
    return lightIconPath;
  }

  Widget _buildIcon(String iconPath, double width, double height, {bool isDark = false}) {
    return Builder(
      builder: (context) {
        try {
          return SvgPicture.asset(
            iconPath,
            width: width,
            height: height,
            fit: BoxFit.contain,
            allowDrawingOutsideViewBox: true,
            // Обработка ошибок загрузки
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.category,
                size: height,
                color: isDark 
                    ? Colors.white // Убираем затемнение для темной темы
                    : Colors.black.withValues(alpha: 0.5),
              );
            },
          );
        } catch (e) {
          return Icon(
            Icons.category,
            size: height,
            color: isDark 
                ? Colors.white // Убираем затемнение для темной темы
                : Colors.black.withValues(alpha: 0.5),
          );
        }
      },
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double borderRadius;

  _DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(borderRadius),
        ),
      );

    // Рисуем пунктирную линию (dashes: 16, 16)
    const dashWidth = 16.0;
    const dashSpace = 16.0;
    final pathMetrics = path.computeMetrics();

    for (final pathMetric in pathMetrics) {
      double start = 0.0;
      while (start < pathMetric.length) {
        final end = (start + dashWidth).clamp(0.0, pathMetric.length);
        final extractPath = pathMetric.extractPath(start, end);
        canvas.drawPath(extractPath, paint);
        start += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
