import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import '../settings/style.dart';
import '../settings/colors.dart';
import '../l10n/app_localizations.dart';

import '../models/analytics_model.dart';
import '../services/analytics_service.dart';
import '../widgets/custom_refresh_indicator.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  static const double _designWidth = 428;
  static const double _designHeight = 926;

  WeeklyTrendsModel? _weeklyTrends;
  AiAnalyticsModel? _aiAnalytics;
  NichesMonthModel? _nichesMonth;
  bool _isLoading = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadAnalytics() async {
    try {
      final weeklyTrends = await AnalyticsService.getWeeklyTrends();
      final aiAnalytics = await AnalyticsService.getAiAnalytics();
      final nichesMonth = await AnalyticsService.getNichesMonth();
      
      if (mounted) {
        setState(() {
          _weeklyTrends = weeklyTrends;
          _aiAnalytics = aiAnalytics;
          _nichesMonth = nichesMonth;
          _isLoading = false;
        });
      }
    } catch (e) {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      }
    }
  }

  Future<void> _refreshAnalytics() async {
    // Сбрасываем состояние для полной перестройки страницы
    if (mounted) {
      setState(() {
        _isLoading = true;
        _weeklyTrends = null;
        _aiAnalytics = null;
        _nichesMonth = null;
      });
      // Сбрасываем позицию прокрутки
      _scrollController.jumpTo(0);
    }
    // Перезагружаем данные
    await _loadAnalytics();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final size = MediaQuery.of(context).size;
    final double widthFactor = size.width / _designWidth;
    final double heightFactor = size.height / _designHeight;

    double scaleWidth(double value) => value * widthFactor;
    double scaleHeight(double value) => heightFactor * value;

    final l = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackgroundMain : AppColors.backgroundMain,
      body: SafeArea(
        top: true,
        bottom: false,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _weeklyTrends == null && _aiAnalytics == null && _nichesMonth == null
                ? CustomRefreshIndicator(
                    onRefresh: _refreshAnalytics,
                    designWidth: _designWidth,
                    designHeight: _designHeight,
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.8,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Text(
                              'Ошибка загрузки данных',
                              style: AppTextStyle.bodyTextMedium(16),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                : CustomRefreshIndicator(
                    onRefresh: _refreshAnalytics,
                    designWidth: _designWidth,
                    designHeight: _designHeight,
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: scaleWidth(33)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                          SizedBox(height: scaleHeight(37)),
                            // Заголовок с иконкой
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  'assets/icons/icon_rocket_analitic.svg',
                                  width: scaleWidth(18.7186336517334),
                                  height: scaleHeight(22.103853225708008),
                                  fit: BoxFit.contain,
                                ),
                                SizedBox(width: scaleWidth(9)),
                          Text(
                            l.analyticsTitle,
                            style: AppTextStyle.screenTitle(
                              scaleHeight(20),
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                            ],
                            ),
                            SizedBox(height: scaleHeight(10)),
                            // Контейнеры
                          if (_weeklyTrends != null)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                // Левый контейнер (прижат слева)
                                _FirstPlaceContainer(
                                  weeklyTrends: _weeklyTrends!,
                                  designWidth: _designWidth,
                                  designHeight: _designHeight,
                                ),
                                SizedBox(width: scaleWidth(14)),
                                // Правый контейнер (прижат справа)
                                _SecondPlaceContainer(
                                  secondPlace: _weeklyTrends!.secondPlace,
                                  designWidth: _designWidth,
                                  designHeight: _designHeight,
                                ),
                              ],
                            ),
                            SizedBox(height: scaleHeight(16)),
                            // Блок "ИИ-аналитика"
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  'assets/icons/icon_stars_analitic.svg',
                                  width: scaleWidth(24),
                                  height: scaleHeight(24),
                                  fit: BoxFit.contain,
                                ),
                                SizedBox(width: scaleWidth(6)),
                                Text(
                                  l.analyticsAiAnalytics,
                                  style: AppTextStyle.screenTitle(
                                    scaleHeight(20),
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: scaleHeight(14)),
                            // Контейнер с аналитикой
                            if (_aiAnalytics != null)
                              _AiAnalyticsContainer(
                                aiAnalytics: _aiAnalytics!,
                                designWidth: _designWidth,
                                designHeight: _designHeight,
                          ),
                          SizedBox(height: scaleHeight(16)),
                          // Блок "Ниши месяца"
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                'assets/icons/icon_lamp.svg',
                                width: scaleWidth(24),
                                height: scaleHeight(24),
                                fit: BoxFit.contain,
                              ),
                              SizedBox(width: scaleWidth(6)),
                              Text(
                                l.analyticsMonthNiches,
                                style: AppTextStyle.screenTitle(
                                  scaleHeight(20),
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: scaleHeight(14)),
                          // Контейнер с нишами
                          if (_nichesMonth != null)
                            _MonthNichesContainer(
                              nichesMonth: _nichesMonth!,
                            designWidth: _designWidth,
                            designHeight: _designHeight,
                          ),
                          SizedBox(height: scaleHeight(20)),
                          ],
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }
}

// Контейнер первого места
class _FirstPlaceContainer extends StatelessWidget {
  const _FirstPlaceContainer({
    required this.weeklyTrends,
    required this.designWidth,
    required this.designHeight,
  });

  final WeeklyTrendsModel weeklyTrends;
  final double designWidth;
  final double designHeight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l = AppLocalizations.of(context)!;

    final size = MediaQuery.of(context).size;
    final double widthFactor = size.width / designWidth;
    final double heightFactor = size.height / designHeight;

    double scaleWidth(double value) => value * widthFactor;
    double scaleHeight(double value) => value * heightFactor;

    final currentTop = weeklyTrends.currentTop;
    final percentText = '+${currentTop.increase.toStringAsFixed(0)}%';
    final percentValue = currentTop.increase.toStringAsFixed(0);
    final categoryPercentage = currentTop.requestPercent ?? 18.0;

    return Container(
      width: scaleWidth(255),
      height: scaleHeight(133),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackgroundCard : Colors.white,
        borderRadius: BorderRadius.circular(scaleHeight(11)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: scaleWidth(11)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Круг с процентом
          Container(
            width: scaleWidth(95),
            height: scaleHeight(95),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFAD2023),
                width: scaleWidth(5),
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              percentText,
              style: AppTextStyle.screenTitle(
                scaleHeight(22),
                color: const Color(0xFFAD2023),
              ),
            ),
          ),
          SizedBox(width: scaleWidth(14)),
          // Текстовый контент справа
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Название категории
                Text(
                  currentTop.title,
                  style: AppTextStyle.screenTitle(
                    scaleHeight(12),
                    color: isDark ? AppColors.darkPrimaryText : const Color(0xFF201D2F),
                  ),
                ),
                SizedBox(height: scaleHeight(10)),
                // Процент по левому краю
                Text(
                  '$percentValue%',
                  style: AppTextStyle.screenTitle(
                    scaleHeight(20),
                    color: AppColors.accentRed,
                  ),
                  textAlign: TextAlign.left,
                ),
                // "Эта неделя" сразу под процентом
                Text(
                  l.analyticsThisWeek,
                  style: AppTextStyle.screenTitleMedium(
                    scaleHeight(6),
                    color: isDark ? AppColors.darkSecondaryText : const Color(0xFFB3B2B2),
                  ),
                ),
                SizedBox(height: scaleHeight(11)),
                // Описание
                Text(
                  l.analyticsCategoryTakes(categoryPercentage.toStringAsFixed(0)),
                  style: AppTextStyle.screenTitleMedium(
                    scaleHeight(10),
                    color: isDark ? AppColors.darkSecondaryText : const Color(0xFFB3B2B2),
                  ).copyWith(
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Контейнер второго места
class _SecondPlaceContainer extends StatelessWidget {
  const _SecondPlaceContainer({
    required this.secondPlace,
    required this.designWidth,
    required this.designHeight,
  });

  final TopTrendItem secondPlace;
  final double designWidth;
  final double designHeight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l = AppLocalizations.of(context)!;

    final size = MediaQuery.of(context).size;
    final double widthFactor = size.width / designWidth;
    final double heightFactor = size.height / designHeight;

    double scaleWidth(double value) => value * widthFactor;
    double scaleHeight(double value) => value * heightFactor;

    final percentText = '+${secondPlace.increase.toStringAsFixed(0)}%';

    // Разбиваем название на две строки, если есть дефис
    final nameParts = secondPlace.title.split('-');
    final nameLine1 = nameParts[0];
    final nameLine2 = nameParts.length > 1 ? nameParts[1] : '';

    return Container(
      width: scaleWidth(92),
      height: scaleHeight(133),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackgroundCard : Colors.white,
        borderRadius: BorderRadius.circular(scaleHeight(11)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(vertical: scaleHeight(20)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // "2-е место"
          Text(
            l.analyticsSecondPlace,
            style: AppTextStyle.screenTitle(
              scaleHeight(12),
              color: isDark ? AppColors.darkPrimaryText : const Color(0xFF201D2F),
            ),
            textAlign: TextAlign.center,
          ),
          // Процент по центру
          Text(
            percentText,
            style: AppTextStyle.screenTitle(
              scaleHeight(22),
              color: AppColors.accentRed,
            ),
            textAlign: TextAlign.center,
          ),
          // Название снизу
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                nameLine1,
                style: AppTextStyle.screenTitle(
                  scaleHeight(12),
                  color: AppColors.accentRed,
                ),
                textAlign: TextAlign.center,
              ),
              if (nameLine2.isNotEmpty)
                Text(
                  nameLine2,
                  style: AppTextStyle.screenTitle(
                    scaleHeight(12),
                    color: AppColors.accentRed,
                  ),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// Контейнер с ИИ-аналитикой
class _AiAnalyticsContainer extends StatelessWidget {
  const _AiAnalyticsContainer({
    required this.aiAnalytics,
    required this.designWidth,
    required this.designHeight,
  });

  final AiAnalyticsModel aiAnalytics;
  final double designWidth;
  final double designHeight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l = AppLocalizations.of(context)!;

    final size = MediaQuery.of(context).size;
    final double widthFactor = size.width / designWidth;
    final double heightFactor = size.height / designHeight;

    double scaleWidth(double value) => value * widthFactor;
    double scaleHeight(double value) => value * heightFactor;

    // Извлекаем процент из increase (округляем до целого)
    final percentValue = aiAnalytics.increase.toStringAsFixed(0);
    
    // Используем description из AI аналитики
    final description = aiAnalytics.description;

    return Container(
      width: scaleWidth(361),
      height: scaleHeight(162),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackgroundCard : const Color(0xFFF1F3F2),
        borderRadius: BorderRadius.circular(scaleHeight(11)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Белый контейнер слева
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: scaleWidth(231),
              height: scaleHeight(162),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBackgroundCard : Colors.white,
                borderRadius: BorderRadius.circular(scaleHeight(11)),
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  top: scaleHeight(32),
                  left: scaleWidth(10),
                  right: scaleWidth(11),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Картинка
                    Image.asset(
                      'assets/images/bot_analitic.png',
                      width: scaleWidth(65),
                      height: scaleHeight(63),
                      fit: BoxFit.contain,
                    ),
                    SizedBox(width: scaleWidth(15)),
                    // Текстовый контент справа
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // "Было прибавлено" на одной строке, процент на следующей
                          RichText(
                            text: TextSpan(
                        style: AppTextStyle.bodyTextMedium(
                          scaleHeight(14),
                                color: isDark ? AppColors.darkPrimaryText : const Color(0xFF201D2F),
                              ).copyWith(
                                height: 1.0,
                              ),
                              children: [
                                TextSpan(text: l.analyticsWasAdded(percentValue)),
                              ],
                            ),
                          ),
                          SizedBox(height: scaleHeight(10)),
                          // Описание
                          Text(
                            description,
                            style: AppTextStyle.bodyTextLight(
                              scaleHeight(12),
                              color: isDark ? AppColors.darkPrimaryText : const Color(0xFF201D2F),
                            ).copyWith(
                              height: 1.0,
                            ),
                            maxLines: 6,
                        overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Серый контейнер справа (оставшееся место)
          Positioned(
            left: scaleWidth(231),
            top: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBackgroundCard : const Color(0xFFF1F3F2),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(scaleHeight(11)),
                  bottomRight: Radius.circular(scaleHeight(11)),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: scaleHeight(9)),
                  // "Уровень конкурентности"
                  Text(
                    l.analyticsCompetitivenessLevel,
                    style: AppTextStyle.bodyText(
                      scaleHeight(8),
                      color: isDark ? AppColors.darkSecondaryText : const Color(0xFF9E9E9E),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(),
                  // Диаграмма метрики с отступами по бокам
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: scaleWidth(11)),
                    child: Padding(
                      padding: EdgeInsets.only(bottom: scaleHeight(10)),
                      child: _MetricsChart(
                        competitivenessData: aiAnalytics.levelOfCompetitiveness,
            designWidth: designWidth,
            designHeight: designHeight,
                      ),
                    ),
                  ),
                  // "Основано на ИИ" справа снизу
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: scaleWidth(6),
                        bottom: scaleHeight(9),
                      ),
                      child: Text(
                        l.analyticsBasedOnAi,
                        style: AppTextStyle.bodyText(
                          scaleHeight(4),
                          color: isDark ? AppColors.darkSecondaryText : const Color(0xFF9E9E9E),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Диаграмма метрики за последние 6 месяцев
class _MetricsChart extends StatelessWidget {
  const _MetricsChart({
    required this.competitivenessData,
    required this.designWidth,
    required this.designHeight,
  });

  final List<double> competitivenessData;
  final double designWidth;
  final double designHeight;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final size = MediaQuery.of(context).size;
    final double widthFactor = size.width / designWidth;
    final double heightFactor = size.height / designHeight;

    double scaleWidth(double value) => value * widthFactor;
    double scaleHeight(double value) => value * heightFactor;

    // Получаем доступную ширину для диаграммы
    // Серый контейнер занимает оставшееся место после белого (231px) и отступов
    final chartAvailableWidth = size.width - scaleWidth(231) - scaleWidth(33) - scaleWidth(11) - scaleWidth(11);
    final chartAvailableHeight = size.height * 0.15; // Примерно 15% от высоты экрана

    // Используем данные из level_of_competitiveness
    // Берем последние 5-6 значений для отображения
    final dataPoints = competitivenessData.length >= 5 
        ? competitivenessData.sublist(competitivenessData.length - 5)
        : competitivenessData;
    
    // Получаем текущий месяц и вычисляем месяцы назад
    final now = DateTime.now();
    final months = List.generate(dataPoints.length, (index) {
      final monthsBack = dataPoints.length - 1 - index;
      return DateTime(now.year, now.month - monthsBack, 1);
    });

    // Получаем сокращенные названия месяцев
    final monthNames = months.map((date) {
      if (locale.languageCode == 'ru') {
        // Русские сокращения месяцев (3-4 символа)
        final monthNamesRu = [
          'Янв', 'Фев', 'Мар', 'Апр', 'Май', 'Июн',
          'Июл', 'Авг', 'Сен', 'Окт', 'Ноя', 'Дек'
        ];
        return monthNamesRu[date.month - 1];
      } else {
        // Английские сокращения месяцев (3-4 символа)
        return DateFormat('MMM', locale.toString()).format(date);
      }
    }).toList();

    // Используем значения из competitivenessData
    final metricsValues = dataPoints.map((value) => value.toInt()).toList();

    // Находим минимальное и максимальное значение для масштабирования
    final minValue = metricsValues.isEmpty ? 0 : metricsValues.reduce((a, b) => a < b ? a : b);
    final maxValue = metricsValues.isEmpty ? 0 : metricsValues.reduce((a, b) => a > b ? a : b);
    final valueRange = maxValue - minValue;

    // Высота и ширина диаграммы адаптивные, зависят от размеров экрана
    final chartWidth = chartAvailableWidth.clamp(scaleWidth(80), scaleWidth(105)); // Ограничиваем минимальной и максимальной шириной
    final chartHeight = chartAvailableHeight.clamp(scaleHeight(30), scaleHeight(70)); // Ограничиваем минимальной и максимальной высотой
    final chartAreaHeight = chartHeight - scaleHeight(16); // Высота минус место для текста

    // Вычисляем позиции всех точек
    // Добавляем отступы по краям, чтобы точки не обрезались
    final horizontalPadding = scaleWidth(4);
    final availableWidthForPoints = chartWidth - (horizontalPadding * 2);
    final pointCount = metricsValues.length;
    final pointPositions = List.generate(pointCount, (index) {
      final xPosition = pointCount > 1 
          ? horizontalPadding + (index / (pointCount - 1)) * availableWidthForPoints
          : horizontalPadding + availableWidthForPoints / 2;
      final value = metricsValues[index];
      
      // Вычисляем позицию точки по вертикали (чем больше значение, тем выше точка)
      // Инвертируем: большее значение = выше на графике
      // Оставляем небольшой отступ сверху и снизу для визуализации
      final padding = scaleHeight(4);
      final availableHeight = chartAreaHeight - (padding * 2);
      final normalizedValue = valueRange > 0 
          ? (value - minValue) / valueRange 
          : 0.5;
      final yPosition = padding + (availableHeight - (normalizedValue * availableHeight));
      
      return {'x': xPosition, 'y': yPosition, 'value': value};
    });

    return SizedBox(
      width: chartWidth,
      height: chartHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Линия волны (проходит через все точки)
          CustomPaint(
            size: Size(chartWidth, chartHeight),
            painter: _WaveLinePainter(
              points: pointPositions,
              lineColor: const Color(0xFFAD2023),
              lineWidth: scaleHeight(1),
            ),
          ),
          // Точки и вертикальные линии
          ...List.generate(pointCount, (index) {
            final position = pointPositions[index];
            final xPosition = position['x'] as double;
            final yPosition = position['y'] as double;
            
            return Positioned(
              left: xPosition - scaleWidth(4), // Центрируем точку
              top: yPosition - scaleHeight(4), // Центрируем точку на линии
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Точка на линии
                  Container(
                    width: scaleWidth(8),
                    height: scaleHeight(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? AppColors.accentRed : const Color(0xFF3B0B0C),
                        width: scaleWidth(4),
                      ),
                    ),
                  ),
                  // Вертикальная линия к названию месяца
                  if (chartHeight - yPosition - scaleHeight(8) - scaleHeight(16) > 0)
                    Container(
                      width: scaleWidth(0.5),
                      height: chartHeight - yPosition - scaleHeight(8) - scaleHeight(16), // Высота от точки до текста
                      decoration: const BoxDecoration(
                        color: Color(0xFFB899EB),
                      ),
                    ),
                  // Название месяца
                  Builder(
                    builder: (context) {
                      final theme = Theme.of(context);
                      final isDark = theme.brightness == Brightness.dark;
                      return Text(
                        monthNames[index],
                        style: AppTextStyle.bodyText(
                          scaleHeight(6),
                          color: isDark ? AppColors.darkSecondaryText : const Color(0xFF9E9E9E),
                        ).copyWith(
                          height: 16 / 6, // line-height: 16px / font-size: 6px
                        ),
                        textAlign: TextAlign.center,
                      );
                    },
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// CustomPainter для рисования линии волны
class _WaveLinePainter extends CustomPainter {
  _WaveLinePainter({
    required this.points,
    required this.lineColor,
    required this.lineWidth,
  });

  final List<Map<String, dynamic>> points;
  final Color lineColor;
  final double lineWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = lineWidth
      ..style = PaintingStyle.stroke;

    if (points.length < 2) return;

    final path = Path();
    path.moveTo(points[0]['x'] as double, points[0]['y'] as double);
    
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i]['x'] as double, points[i]['y'] as double);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_WaveLinePainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.lineWidth != lineWidth;
  }
}

// Контейнер с нишами месяца
class _MonthNichesContainer extends StatelessWidget {
  const _MonthNichesContainer({
    required this.nichesMonth,
    required this.designWidth,
    required this.designHeight,
  });

  final NichesMonthModel nichesMonth;
  final double designWidth;
  final double designHeight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final size = MediaQuery.of(context).size;
    final double widthFactor = size.width / designWidth;
    final double heightFactor = size.height / designHeight;

    double scaleWidth(double value) => value * widthFactor;
    double scaleHeight(double value) => value * heightFactor;

    // Используем данные ниш из модели
    final niches = nichesMonth.niches;

    // Ширина контейнера зависит от экрана
    final containerWidth = size.width - scaleWidth(33) - scaleWidth(33); // Минус боковые отступы

    return Container(
      width: containerWidth,
      constraints: BoxConstraints(
        maxWidth: scaleWidth(361),
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackgroundCard : Colors.white,
        borderRadius: BorderRadius.circular(scaleHeight(11)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(
        horizontal: scaleWidth(9),
        vertical: scaleHeight(13),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...List.generate(niches.length, (index) {
            final niche = niches[index];
            final isLast = index == niches.length - 1;
            final isUp = niche.change >= 0;
            final changeValue = niche.change.abs();
            
            return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
                Row(
                  children: [
                    // Иконка слева
                    SvgPicture.asset(
                      'assets/icons/icon_fire.svg',
                      width: scaleWidth(24),
                      height: scaleHeight(24),
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.category,
                          size: scaleWidth(24),
                          color: isDark ? AppColors.darkSecondaryText : Colors.grey,
                        );
                      },
                    ),
                    SizedBox(width: scaleWidth(15)),
                    // Название ниши
                    Expanded(
                      child: Text(
                        niche.title,
                        style: AppTextStyle.bodyTextMedium(
                          scaleHeight(14),
                          color: isDark ? AppColors.darkPrimaryText : const Color(0xFF000000),
                        ).copyWith(
                          height: 1.0,
                        ),
                      ),
                    ),
                    // Процент слева от треугольника
                    Padding(
                      padding: EdgeInsets.only(right: scaleWidth(4)),
                      child: Text(
                        '${isUp ? '+' : '-'}${changeValue.toStringAsFixed(0)}%',
                        style: AppTextStyle.bodyTextMedium(
                          scaleHeight(13),
                          color: isDark ? AppColors.darkPrimaryText : const Color(0xFF000000),
                        ).copyWith(
                          height: 1.0,
                        ),
                      ),
                    ),
                    // Иконка треугольника справа
                    SvgPicture.asset(
                      isUp
                          ? 'assets/icons/icon_tr_up.svg'
                          : 'assets/icons/icon_tr_down.svg',
                      width: scaleWidth(28),
                      height: scaleHeight(28),
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
                if (!isLast) SizedBox(height: scaleHeight(19)),
              ],
            );
          }),
        ],
      ),
    );
  }
}
