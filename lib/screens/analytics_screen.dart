import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../settings/style.dart';

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
    final size = MediaQuery.of(context).size;
    final double widthFactor = size.width / _designWidth;
    final double heightFactor = size.height / _designHeight;

    double scaleWidth(double value) => value * widthFactor;
    double scaleHeight(double value) => value * heightFactor;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
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
                            'Топ направлений недели',
                            style: AppTextStyle.screenTitle(scaleHeight(20),
                                color: const Color(0xFF201D2F)),
                          ),
                          SizedBox(height: scaleHeight(16)),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Тренд №1',
                                style: AppTextStyle.trendTitle(
                                    scaleHeight(18), const Color(0xFF178751)),
                              ),
                              SizedBox(width: scaleWidth(11)),
                              Expanded(
                                child: Text(
                                  _analytics!.trendName,
                                  style: AppTextStyle.trendTitle(
                                      scaleHeight(18), Colors.black),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: scaleHeight(16)),
                          Text(
                            _analytics!.trendPercentage,
                            style: AppTextStyle.trendPercentage(
                                scaleHeight(64), const Color(0xFF178751)),
                          ),
                          SizedBox(height: scaleHeight(3)),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  'на столько  увеличилась вовлеченность\nпо сравнению с прошлой неделей',
                                  style: AppTextStyle.bodyTextLight(
                                      scaleHeight(10)),
                                ),
                              ),
                              SizedBox(width: scaleWidth(8)),
                              Text(
                                '7 дн',
                                style: AppTextStyle.bodyTextMedium(
                                    scaleHeight(12),
                                    color: const Color(0xFF9E9E9E)),
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
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFFCBE5F8),
                                  Color(0xFFD6D7F8),
                                ],
                                stops: [0.0, 0.7816],
                              ),
                              borderRadius: BorderRadius.circular(scaleHeight(15)),
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
                                    SvgPicture.asset(
                                      'assets/icons/icon_brain.svg',
                                      width: scaleWidth(24),
                                      height: scaleHeight(24),
                                      fit: BoxFit.contain,
                                    ),
                                    SizedBox(width: scaleWidth(8)),
                                    Text(
                                      'Почему?',
                                      style: AppTextStyle.trendTitle(
                                          scaleHeight(18), Colors.black),
                                    ),
                                  ],
                                ),
                                SizedBox(height: scaleHeight(19)),
                                Text(
                                  _analytics!.trendDescription,
                                  style: AppTextStyle.trendDescription(
                                          scaleHeight(15))
                                      .copyWith(height: 1.2),
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
                                title: 'Растущие',
                                items: _analytics!.growingTrends,
                                itemColor: const Color(0xFF178751),
                                iconPath: 'assets/icons/icon_tr_up.svg',
                                designWidth: _designWidth,
                                designHeight: _designHeight,
                              ),
                              SizedBox(width: scaleWidth(14)),
                              _TrendContainer(
                                title: 'Падающие',
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
    final size = MediaQuery.of(context).size;
    final double widthFactor = size.width / designWidth;
    final double heightFactor = size.height / designHeight;

    double scaleWidth(double value) => value * widthFactor;
    double scaleHeight(double value) => value * heightFactor;

    return Container(
      width: scaleWidth(171),
      height: scaleHeight(236),
      decoration: BoxDecoration(
        color: Colors.white,
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
            style: AppTextStyle.screenTitle(scaleHeight(16)),
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
