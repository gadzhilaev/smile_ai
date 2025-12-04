import 'package:flutter/foundation.dart';
import '../models/analytics_model.dart';
import 'api_service.dart';

class AnalyticsService {
  /// Загрузить тренды недели с API
  static Future<WeeklyTrendsModel?> getWeeklyTrends() async {
    try {
      final data = await ApiService.instance.getWeeklyTrends();
      
      if (data.isEmpty) {
        debugPrint('AnalyticsService: no weekly trends data available');
        return null;
      }

      final currentTopData = data['current_top'] as Map<String, dynamic>?;
      final secondPlaceData = data['second_place'] as Map<String, dynamic>?;
      final geoTrendsData = data['geo_trends'] as List<dynamic>?;
      final weekStart = data['week_start'] as String?;

      if (currentTopData == null || secondPlaceData == null) {
        debugPrint('AnalyticsService: incomplete weekly trends data');
        return null;
      }

      final currentTop = TopTrendItem(
        title: currentTopData['title'] as String? ?? '',
        increase: (currentTopData['increase'] as num?)?.toDouble() ?? 0.0,
        requestPercent: (currentTopData['request_percent'] as num?)?.toDouble(),
      );

      final secondPlace = TopTrendItem(
        title: secondPlaceData['title'] as String? ?? '',
        increase: (secondPlaceData['increase'] as num?)?.toDouble() ?? 0.0,
        requestPercent: (secondPlaceData['request_percent'] as num?)?.toDouble(),
      );

      final geoTrends = (geoTrendsData ?? []).map((item) {
        final geoData = item as Map<String, dynamic>;
        return GeoTrendItem(
          country: geoData['country'] as String? ?? '',
          increase: (geoData['increase'] as num?)?.toDouble() ?? 0.0,
        );
      }).toList();

      return WeeklyTrendsModel(
        currentTop: currentTop,
        secondPlace: secondPlace,
        geoTrends: geoTrends,
        weekStart: weekStart,
      );
    } catch (e) {
      debugPrint('AnalyticsService: error loading weekly trends: $e');
      return null;
    }
  }

  /// Загрузить AI аналитику с API
  static Future<AiAnalyticsModel?> getAiAnalytics() async {
    try {
      final data = await ApiService.instance.getAiAnalytics();
      
      if (data.isEmpty) {
        debugPrint('AnalyticsService: no AI analytics data available');
        return null;
      }

      final increase = (data['increase'] as num?)?.toDouble() ?? 0.0;
      final description = data['description'] as String? ?? '';
      final competitivenessData = data['level_of_competitiveness'] as List<dynamic>?;
      final createdAt = data['created_at'] as String?;

      if (competitivenessData == null || competitivenessData.length < 5) {
        debugPrint('AnalyticsService: insufficient competitiveness data points');
        return null;
      }

      final levelOfCompetitiveness = competitivenessData
          .map((item) => (item as num).toDouble())
          .toList();

      return AiAnalyticsModel(
        increase: increase,
        description: description,
        levelOfCompetitiveness: levelOfCompetitiveness,
        createdAt: createdAt,
      );
    } catch (e) {
      debugPrint('AnalyticsService: error loading AI analytics: $e');
      return null;
    }
  }

  /// Загрузить ниши месяца с API
  static Future<NichesMonthModel?> getNichesMonth() async {
    try {
      final data = await ApiService.instance.getNichesMonth();
      
      final nichesData = data['niches'] as List<dynamic>?;
      final monthStart = data['month_start'] as String?;

      if (nichesData == null) {
        debugPrint('AnalyticsService: no niches data available');
        return NichesMonthModel(niches: [], monthStart: monthStart);
      }

      final niches = nichesData.map((item) {
        final nicheData = item as Map<String, dynamic>;
        return NicheItem(
          title: nicheData['title'] as String? ?? '',
          change: (nicheData['change'] as num?)?.toDouble() ?? 0.0,
        );
      }).toList();

      return NichesMonthModel(
        niches: niches,
        monthStart: monthStart,
      );
    } catch (e) {
      debugPrint('AnalyticsService: error loading niches month: $e');
      return null;
    }
  }

  /// Загрузить данные аналитики с API (старый метод для обратной совместимости)
  static Future<AnalyticsModel> getAnalytics() async {
    try {
      // Загружаем топ тренд
      final topTrendData = await ApiService.instance.getTopTrend();
      
      if (topTrendData.containsKey('error')) {
        debugPrint('AnalyticsService: error loading top trend: ${topTrendData['error']}');
        throw Exception(topTrendData['error']);
      }

      final trendName = topTrendData['name'] as String? ?? '';
      final percentChange = topTrendData['percent_change'] as num? ?? 0.0;
      final trendDescription = topTrendData['why_popular'] as String? ?? '';

      // Форматируем процент изменения
      final trendPercentage = percentChange >= 0
          ? '+${percentChange.toStringAsFixed(1)}%'
          : '${percentChange.toStringAsFixed(1)}%';

      // Загружаем популярность трендов
      final popularityData = await ApiService.instance.getPopularity();

      // Разделяем на растущие и падающие
      final List<TrendItem> growingTrends = [];
      final List<TrendItem> fallingTrends = [];

      for (final item in popularityData) {
        final name = item['name'] as String? ?? '';
        final percentChangeValue = (item['percent_change'] as num?)?.toDouble() ?? 0.0;
        final direction = item['direction'] as String? ?? '';
        final notes = item['notes'] as String? ?? '';

        final trendItem = TrendItem(
          name: name,
          percentChange: percentChangeValue.abs(),
          notes: notes,
        );

        // Если percent_change отрицательный или direction = "decreasing" → падающие
        // Иначе → растущие
        if (percentChangeValue < 0 || direction == 'decreasing') {
          fallingTrends.add(trendItem);
        } else {
          growingTrends.add(trendItem);
        }
      }

      // Сортируем от большего к меньшему по percent_change
      growingTrends.sort((a, b) => b.percentChange.compareTo(a.percentChange));
      fallingTrends.sort((a, b) => b.percentChange.compareTo(a.percentChange));

      return AnalyticsModel(
        trendName: trendName,
        trendPercentage: trendPercentage,
        trendDescription: trendDescription,
        growingTrends: growingTrends,
        fallingTrends: fallingTrends,
      );
    } catch (e) {
      debugPrint('AnalyticsService: error loading analytics: $e');
      rethrow;
    }
  }
}

