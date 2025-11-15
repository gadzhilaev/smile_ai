import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

class NotificationService {
  static NotificationService? _instance;
  static NotificationService get instance {
    _instance ??= NotificationService._();
    return _instance!;
  }

  NotificationService._();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Инициализация уведомлений
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    // Настройки для Android
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Настройки для iOS
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    final bool? initialized = await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    if (initialized == true) {
      _isInitialized = true;
    }

    return initialized ?? false;
  }

  /// Обработка нажатия на уведомление
  void _onNotificationTapped(NotificationResponse response) {
    // Здесь можно обработать нажатие на уведомление
    if (kDebugMode) {
      print('Notification tapped: ${response.payload}');
    }
  }

  /// Запрос разрешений на уведомления
  Future<bool> requestPermissions() async {
    if (!_isInitialized) {
      await initialize();
    }

    if (Platform.isAndroid) {
      // Для Android 13+ нужно запросить разрешение
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      final bool? granted = await androidImplementation?.requestNotificationsPermission();
      return granted ?? false;
    } else if (Platform.isIOS) {
      // Для iOS разрешения запрашиваются при инициализации
      // Дополнительный запрос разрешений через плагин
      // Для iOS разрешения уже запрашиваются при инициализации через DarwinInitializationSettings
      // Дополнительный запрос не требуется, возвращаем true
      return true;
    }

    return true;
  }

  /// Проверка, есть ли разрешение на уведомления
  Future<bool> isPermissionGranted() async {
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      final bool? granted = await androidImplementation?.areNotificationsEnabled();
      return granted ?? false;
    } else if (Platform.isIOS) {
      // Для iOS проверка разрешений через плагин
      // В реальном приложении можно использовать permission_handler
      return true;
    }

    return false;
  }

  /// Показать уведомление о завершении генерации AI
  Future<void> showAiMessageNotification(String message) async {
    if (!_isInitialized) {
      await initialize();
    }

    // Проверяем разрешение перед отправкой
    final bool hasPermission = await isPermissionGranted();
    if (!hasPermission) {
      if (kDebugMode) {
        print('Notification permission not granted');
      }
      return;
    }

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'ai_messages',
      'AI Messages',
      channelDescription: 'Уведомления о новых сообщениях от AI',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Обрезаем сообщение для уведомления (первые 100 символов)
    final String notificationBody = message.length > 100
        ? '${message.substring(0, 100)}...'
        : message;

    await _notificationsPlugin.show(
      0,
      'AI завершил генерацию',
      notificationBody,
      details,
      payload: message,
    );
  }

  /// Отменить все уведомления
  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }
}

