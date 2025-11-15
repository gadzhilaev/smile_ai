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
  final List<String> growingTrends;
  final List<String> fallingTrends;
}

