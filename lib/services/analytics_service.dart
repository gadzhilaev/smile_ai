import 'package:flutter/foundation.dart';
import '../models/analytics_model.dart';
import 'api_service.dart';

class AnalyticsService {
  /// Загрузить данные аналитики с API
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

