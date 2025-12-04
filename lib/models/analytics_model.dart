class TrendItem {
  const TrendItem({
    required this.name,
    required this.percentChange,
    required this.notes,
  });

  final String name;
  final double percentChange;
  final String notes;
}

class AnalyticsModel {
  const AnalyticsModel({
    required this.trendName,
    required this.trendPercentage,
    required this.trendDescription,
    required this.growingTrends,
    required this.fallingTrends,
  });

  final String trendName;
  final String trendPercentage;
  final String trendDescription;
  final List<TrendItem> growingTrends;
  final List<TrendItem> fallingTrends;
}

// Модель для Weekly Trends
class WeeklyTrendsModel {
  const WeeklyTrendsModel({
    required this.currentTop,
    required this.secondPlace,
    required this.geoTrends,
    this.weekStart,
  });

  final TopTrendItem currentTop;
  final TopTrendItem secondPlace;
  final List<GeoTrendItem> geoTrends;
  final String? weekStart;
}

class TopTrendItem {
  const TopTrendItem({
    required this.title,
    required this.increase,
    this.requestPercent,
  });

  final String title;
  final double increase;
  final double? requestPercent;
}

class GeoTrendItem {
  const GeoTrendItem({
    required this.country,
    required this.increase,
  });

  final String country;
  final double increase;
}

// Модель для AI Analytics
class AiAnalyticsModel {
  const AiAnalyticsModel({
    required this.increase,
    required this.description,
    required this.levelOfCompetitiveness,
    this.createdAt,
  });

  final double increase;
  final String description;
  final List<double> levelOfCompetitiveness;
  final String? createdAt;
}

// Модель для Niches Month
class NichesMonthModel {
  const NichesMonthModel({
    required this.niches,
    this.monthStart,
  });

  final List<NicheItem> niches;
  final String? monthStart;
}

class NicheItem {
  const NicheItem({
    required this.title,
    required this.change,
  });

  final String title;
  final double change; // Positive = growth, negative = decline
}

