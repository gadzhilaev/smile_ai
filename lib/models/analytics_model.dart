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

