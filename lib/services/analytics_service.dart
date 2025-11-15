import '../models/analytics_model.dart';

class AnalyticsService {
  // Имитация загрузки данных с API
  static Future<AnalyticsModel> getAnalytics() async {
    // Имитация задержки сети
    await Future.delayed(const Duration(milliseconds: 500));

    // Пока что возвращаем моковые данные
    // В будущем здесь будет реальный запрос к API
    return AnalyticsModel(
      trendName: 'Онлайн-образование',
      trendPercentage: '+190%',
      trendDescription:
          'Тренд "Онлайн-образование" можно использовать, чтобы укрепить бренд как источник пользы.  Добавьте обучающие Reels или короткие карусели с экспертными инсайтами, а также соберите рассылку с полезными материалами — вовлечённость возрастёт на 20–30%.',
      growingTrends: const [
        'Сфера красоты',
        'Доставка продуктов',
        'Маркетплейсы',
      ],
      fallingTrends: const [
        'Автосервис',
        'Продажа цветов',
        'Кофейни',
      ],
    );
  }
}

