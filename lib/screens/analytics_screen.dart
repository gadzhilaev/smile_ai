import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

  AnalyticsModel? _analytics;
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
    final analytics = await AnalyticsService.getAnalytics();
    if (mounted) {
      setState(() {
        _analytics = analytics;
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshAnalytics() async {
    // Сбрасываем состояние для полной перестройки страницы
    if (mounted) {
      setState(() {
        _isLoading = true;
        _analytics = null;
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
            : _analytics == null
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
                          Text(
                            l.analyticsTitle,
                            style: AppTextStyle.screenTitle(
                              scaleHeight(20),
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          SizedBox(height: scaleHeight(16)),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l.analyticsTrend1,
                                style: AppTextStyle.trendTitle(
                                  scaleHeight(18),
                                  AppColors.textSuccess,
                                ),
                              ),
                              SizedBox(width: scaleWidth(11)),
                              Expanded(
                                child: Text(
                                  _analytics!.trendName,
                                  style: AppTextStyle.trendTitle(
                                    scaleHeight(18),
                                    theme.colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: scaleHeight(16)),
                          Text(
                            _analytics!.trendPercentage,
                            style: AppTextStyle.trendPercentage(
                              scaleHeight(64),
                              AppColors.textSuccess,
                            ),
                          ),
                          SizedBox(height: scaleHeight(3)),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  l.analyticsTrendDeltaDescription,
                                  style: AppTextStyle.bodyTextLight(
                                    scaleHeight(10),
                                    color: isDark
                                        ? AppColors.white
                                        : theme.colorScheme.onSurface
                                            .withValues(alpha: 0.7),
                                  ),
                                ),
                              ),
                              SizedBox(width: scaleWidth(8)),
                              Text(
                                l.analytics7Days,
                                style: AppTextStyle.bodyTextMedium(
                                  scaleHeight(12),
                                  color: isDark
                                      ? AppColors.white
                                      : AppColors.textDarkGrey,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: scaleHeight(19)),
                          Container(
                            width: double.infinity,
                            constraints: BoxConstraints(
                              maxWidth: scaleWidth(361),
                              minHeight: scaleHeight(239),
                            ),
                            decoration: BoxDecoration(
                              gradient: isDark
                                  ? const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xFF1F2937), // чуть светлее фона
                                        Color(0xFF111827),
                                      ],
                                    )
                                  : const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xFFCFE8FF),
                                        Color(0xFFDDE0FF),
                                      ],
                                      stops: [0.0, 0.7816],
                                    ),
                              borderRadius:
                                  BorderRadius.circular(scaleHeight(15)),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: scaleWidth(19),
                              vertical: scaleHeight(23),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      l.analyticsWhy,
                                      style: AppTextStyle.trendTitle(
                                        scaleHeight(18),
                                        theme.colorScheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: scaleHeight(19)),
                                Text(
                                  _analytics!.trendDescription,
                                  style: AppTextStyle.trendDescription(
                                    scaleHeight(15),
                                  ).copyWith(
                                    height: 1.2,
                                    color: isDark
                                        ? AppColors.white
                                        : theme.colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: scaleHeight(38)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _TrendContainer(
                                title: l.analyticsCategoryGrowing,
                                items: _analytics!.growingTrends,
                                itemColor: const Color(0xFF178751),
                                iconPath: 'assets/icons/icon_tr_up.svg',
                                designWidth: _designWidth,
                                designHeight: _designHeight,
                              ),
                              SizedBox(width: scaleWidth(14)),
                              _TrendContainer(
                                title: l.analyticsCategoryFalling,
                                items: _analytics!.fallingTrends,
                                itemColor: const Color(0xFF76090B),
                                iconPath: 'assets/icons/icon_tr_down.svg',
                                designWidth: _designWidth,
                                designHeight: _designHeight,
                              ),
                            ],
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

class _TrendContainer extends StatelessWidget {
  const _TrendContainer({
    required this.title,
    required this.items,
    required this.itemColor,
    required this.iconPath,
    required this.designWidth,
    required this.designHeight,
  });

  final String title;
  final List<String> items;
  final Color itemColor;
  final String iconPath;
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

    return Container(
      width: scaleWidth(171),
      height: scaleHeight(236),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackgroundCard : AppColors.white,
        borderRadius: BorderRadius.circular(scaleHeight(15)),
      ),
      padding: EdgeInsets.only(
        left: scaleWidth(15),
        top: scaleHeight(18),
        right: scaleWidth(9),
        bottom: scaleHeight(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyle.screenTitle(
              scaleHeight(16),
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: scaleHeight(30)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < items.length; i++) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          items[i],
                          style: AppTextStyle.bodyTextMedium(scaleHeight(14),
                                  color: itemColor)
                              .copyWith(height: 1.2),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: scaleWidth(9)),
                      SvgPicture.asset(
                        iconPath,
                        width: scaleWidth(20),
                        height: scaleHeight(20),
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                  if (i < items.length - 1) SizedBox(height: scaleHeight(28)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
