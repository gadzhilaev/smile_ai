import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'dart:io' show Platform;
import 'dart:convert';
import 'notification_settings_service.dart';

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
  static const String _channelId = 'ai_messages';
  static const String _channelName = 'AI Messages';
  static const String _channelDescription = 'Уведомления о новых сообщениях от AI';

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
      // Создаем канал уведомлений с начальными настройками
      await _updateNotificationChannel();
    }

    return initialized ?? false;
  }

  /// Обновление канала уведомлений на Android в соответствии с настройками
  Future<void> _updateNotificationChannel() async {
    if (!Platform.isAndroid) return;

    final settingsService = NotificationSettingsService.instance;
    final bool enableSound = settingsService.sound;
    final bool enableVibration = settingsService.vibration;

    final AndroidNotificationChannel channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
      playSound: enableSound,
      enableVibration: enableVibration,
      showBadge: true,
    );

    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidImplementation?.createNotificationChannel(channel);
  }

  /// Callback для навигации при нажатии на уведомление
  Function(String)? _onNotificationTappedCallback;

  /// Установить callback для навигации
  void setNotificationTapCallback(Function(String) callback) {
    _onNotificationTappedCallback = callback;
  }

  /// Обработка нажатия на уведомление
  void _onNotificationTapped(NotificationResponse response) {
    // Здесь можно обработать нажатие на уведомление
    if (kDebugMode) {
      print('Notification tapped: ${response.payload}');
    }
    
    // Вызываем callback для навигации
    if (_onNotificationTappedCallback != null && response.payload != null) {
      _onNotificationTappedCallback!(response.payload!);
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

  /// Обновить настройки канала уведомлений (вызывается при изменении настроек)
  Future<void> updateNotificationSettings() async {
    if (!_isInitialized) {
      await initialize();
    }
    await _updateNotificationChannel();
  }

  /// Показать уведомление о завершении генерации AI
  Future<void> showAiMessageNotification(
    String message, {
    String? conversationId,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    // Проверяем, находится ли приложение в foreground
    // Уведомление отправляется всегда, даже если приложение активно,
    // потому что пользователь может быть на другой странице (не на AI экране)
    // Если пользователь на AI экране, он увидит сообщение в чате,
    // а уведомление будет дополнительным напоминанием
    final appLifecycleState = WidgetsBinding.instance.lifecycleState;
    if (kDebugMode) {
      print('📱 [NotificationService] Состояние приложения: $appLifecycleState');
      if (appLifecycleState == AppLifecycleState.resumed) {
        print('📱 [NotificationService] Приложение активно, но отправляем уведомление (пользователь может быть на другой странице)');
      } else {
        print('📱 [NotificationService] Приложение не активно, отправляем уведомление');
      }
    }

    // Проверяем настройки уведомлений
    final settingsService = NotificationSettingsService.instance;
    if (!settingsService.shouldShowNotifications()) {
      if (kDebugMode) {
        print('Notifications disabled in settings');
      }
      return;
    }

    // Проверяем разрешение перед отправкой
    final bool hasPermission = await isPermissionGranted();
    if (!hasPermission) {
      if (kDebugMode) {
        print('Notification permission not granted');
      }
      return;
    }

    // Проверяем настройки звука и вибрации
    final bool enableSound = settingsService.sound;
    final bool enableVibration = settingsService.vibration;

    // Обновляем канал перед отправкой уведомления
    if (Platform.isAndroid) {
      await _updateNotificationChannel();
    }

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
      playSound: enableSound,
      enableVibration: enableVibration,
    );

    final DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: enableSound,
    );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Обрезаем сообщение для уведомления (первые 100 символов)
    final String notificationBody = message.length > 100
        ? '${message.substring(0, 100)}...'
        : message;

    // Формируем payload с данными для навигации
    final Map<String, dynamic> payloadData = {
      'type': 'ai_generation',
      'route': 'ai_chat',
      'conversation_id': conversationId ?? '',
    };
    final String payload = jsonEncode(payloadData);

    await _notificationsPlugin.show(
      0,
      'AI завершил генерацию',
      notificationBody,
      details,
      payload: payload,
    );
  }

  /// Показать уведомление от поддержки
  Future<void> showSupportNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    // Проверяем настройки уведомлений
    final settingsService = NotificationSettingsService.instance;
    if (!settingsService.shouldShowNotifications()) {
      if (kDebugMode) {
        print('Notifications disabled in settings');
      }
      return;
    }

    // Проверяем разрешение перед отправкой
    final bool hasPermission = await isPermissionGranted();
    if (!hasPermission) {
      if (kDebugMode) {
        print('Notification permission not granted');
      }
      return;
    }

    // Проверяем настройки звука и вибрации
    final bool enableSound = settingsService.sound;
    final bool enableVibration = settingsService.vibration;

    // Обновляем канал перед отправкой уведомления
    if (Platform.isAndroid) {
      await _updateNotificationChannel();
    }

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
      playSound: enableSound,
      enableVibration: enableVibration,
    );

    final DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: enableSound,
    );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Обрезаем сообщение для уведомления (первые 100 символов)
    final String notificationBody = body.length > 100
        ? '${body.substring(0, 100)}...'
        : body;

    // Используем payload для передачи данных о навигации
    final String payload = data != null ? jsonEncode(data) : 'support';

    await _notificationsPlugin.show(
      1, // Другой ID для уведомлений поддержки
      title,
      notificationBody,
      details,
      payload: payload,
    );
  }

  /// Отменить все уведомления
  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }
}

