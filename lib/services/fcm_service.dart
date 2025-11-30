import 'dart:io';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'support_service.dart';
import 'notification_service.dart';

/// Обработчик фоновых сообщений Firebase
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('FCMService: фоновое сообщение получено: ${message.messageId}');
  debugPrint('FCMService: данные: ${message.data}');
  debugPrint('FCMService: уведомление: ${message.notification?.title} - ${message.notification?.body}');
  
  // Проверяем тип уведомления
  final isSupportMessage = message.data['type'] == 'support_reply' || 
                           message.data['type'] == 'support_message' ||
                           message.data['direction'] == 'support' ||
                           message.data['from_support'] == true;
  
  if (isSupportMessage) {
    final userId = message.data['user_id'];
    debugPrint('FCMService: получен ответ от поддержки для пользователя: $userId');
    // В фоне уведомление показывается автоматически через Firebase
  }
}

/// Сервис для работы с Firebase Cloud Messaging
class FCMService {
  FCMService._();
  
  static final FCMService instance = FCMService._();
  
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  String? _fcmToken;
  bool _isInitialized = false;
  Timer? _iosTokenRetryTimer; // Таймер для повторных попыток получения токена на iOS
  
  /// Callback для обновления истории при получении уведомления от поддержки
  static Function()? onSupportReplyReceived;
  
  /// Инициализация FCM с userId
  /// ВАЖНО: Вызывается ОДИН РАЗ при запуске приложения или входе пользователя
  Future<void> initialize(String userId) async {
    if (_isInitialized) {
      // Если уже инициализирован, но userId изменился, перерегистрируем токен
      if (_currentUserId != userId) {
        debugPrint('FCMService: userId изменился, перерегистрируем токен');
        _currentUserId = userId;
        await registerTokenForUser(userId);
      }
      return;
    }
    
    _currentUserId = userId;
    
    try {
      debugPrint('🔔 FCMService: Инициализация FCM для userId: ${userId.substring(0, 8)}...');
      
      // Запрашиваем разрешение на уведомления
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      
      debugPrint('📱 FCMService: Разрешение на уведомления: ${settings.authorizationStatus}');
      
      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        // Настраиваем обработчики сообщений
        _setupMessageHandlers();
        
        // Слушаем обновления токена
        _messaging.onTokenRefresh.listen((newToken) {
          debugPrint('FCMService: токен обновлен: ${newToken.substring(0, 20)}...');
          _fcmToken = newToken;
          if (_currentUserId != null) {
            registerTokenForUser(_currentUserId!);
          }
        });
        
        // Для iOS нужно сначала получить APNS токен
        if (Platform.isIOS) {
          await _initializeIOS(userId);
        } else {
          // Для Android сразу получаем FCM токен
          await _getFCMTokenAndRegister(userId);
        }
        
        _isInitialized = true;
        debugPrint('✅ FCMService: FCM инициализирован успешно');
      } else {
        debugPrint('❌ FCMService: разрешение на уведомления не предоставлено');
      }
    } catch (e) {
      debugPrint('❌ FCMService: ошибка инициализации: $e');
    }
  }
  
  String? _currentUserId;
  
  /// Инициализация для iOS с обработкой APNS токена
  Future<void> _initializeIOS(String userId) async {
    // Пытаемся получить APNS токен
    try {
      final apnsToken = await _messaging.getAPNSToken();
      if (apnsToken != null) {
        debugPrint('📱 FCMService: APNS токен получен: ${apnsToken.substring(0, 20)}...');
        // Если APNS токен есть, получаем FCM токен
        await _getFCMTokenAndRegister(userId);
      } else {
        debugPrint('⚠️ FCMService: APNS токен еще не доступен, начнем периодические попытки');
        // Начинаем периодические попытки получить токен
        _startIOSTokenRetry(userId);
      }
    } catch (e) {
      debugPrint('⚠️ FCMService: ошибка получения APNS токена: $e');
      // Начинаем периодические попытки
      _startIOSTokenRetry(userId);
    }
  }
  
  /// Периодические попытки получить FCM токен на iOS
  void _startIOSTokenRetry(String userId) {
    _iosTokenRetryTimer?.cancel();
    int attempts = 0;
    const maxAttempts = 10; // Максимум 10 попыток (50 секунд)
    
    _iosTokenRetryTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      attempts++;
      debugPrint('🔄 FCMService: Попытка $attempts получить FCM токен для iOS...');
      
      try {
        // Проверяем APNS токен
        final apnsToken = await _messaging.getAPNSToken();
        if (apnsToken != null) {
          debugPrint('📱 FCMService: APNS токен получен: ${apnsToken.substring(0, 20)}...');
          timer.cancel();
          await _getFCMTokenAndRegister(userId);
        } else if (attempts >= maxAttempts) {
          debugPrint('⚠️ FCMService: Достигнуто максимальное количество попыток, останавливаем');
          timer.cancel();
        }
      } catch (e) {
        debugPrint('⚠️ FCMService: Ошибка при попытке $attempts: $e');
        if (attempts >= maxAttempts) {
          timer.cancel();
        }
      }
    });
  }
  
  /// Получение FCM токена и регистрация на сервере
  Future<void> _getFCMTokenAndRegister(String userId) async {
    // Останавливаем таймер повторных попыток, если он запущен
    _iosTokenRetryTimer?.cancel();
    _iosTokenRetryTimer = null;
    
    try {
      // Получаем токен устройства
      _fcmToken = await _messaging.getToken();
      if (_fcmToken != null) {
        debugPrint('🔑 FCMService: FCM Token получен: ${_fcmToken!.substring(0, 20)}...');
        
        // Регистрируем токен на сервере
        await registerTokenForUser(userId);
      } else {
        debugPrint('⚠️ FCMService: FCM токен еще не доступен');
      }
    } catch (e) {
      debugPrint('❌ FCMService: ошибка получения FCM токена: $e');
      // Для iOS это нормально, если APNS токен еще не получен
      if (!Platform.isIOS) {
        rethrow;
      }
    }
  }
  
  /// Публичный метод для регистрации токена для конкретного пользователя
  /// Вызывается после логина/регистрации, когда USER_ID становится доступен
  Future<void> registerTokenForUser(String userId) async {
    if (_fcmToken == null) {
      debugPrint('FCMService: FCM токен еще не получен, пытаемся получить...');
      try {
        _fcmToken = await _messaging.getToken();
        if (_fcmToken == null) {
          debugPrint('FCMService: не удалось получить FCM токен');
          return;
        }
      } catch (e) {
        debugPrint('FCMService: ошибка получения FCM токена: $e');
        return;
      }
    }
    
    if (userId.isEmpty) {
      debugPrint('FCMService: userId пустой, пропускаем регистрацию токена');
      return;
    }
    
    try {
      final platform = Platform.isAndroid ? 'android' : 'ios';
      debugPrint('📤 FCMService: Регистрация устройства: userId=${userId.substring(0, 8)}..., platform=$platform');
      await SupportService.registerDevice(
        userId: userId,
        fcmToken: _fcmToken!,
        platform: platform,
      );
      debugPrint('✅ FCMService: Устройство успешно зарегистрировано на сервере для пользователя: ${userId.substring(0, 8)}...');
    } catch (e) {
      debugPrint('❌ FCMService: ошибка регистрации токена: $e');
    }
  }
  
  /// Настройка обработчиков сообщений
  void _setupMessageHandlers() {
    // Обработка сообщений, когда приложение на переднем плане
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('FCMService: сообщение получено (приложение активно): ${message.messageId}');
      debugPrint('FCMService: данные: ${message.data}');
      debugPrint('FCMService: уведомление: ${message.notification?.title} - ${message.notification?.body}');
      
      // Проверяем тип уведомления или наличие данных от поддержки
      final isSupportMessage = message.data['type'] == 'support_reply' || 
                                message.data['type'] == 'support_message' ||
                                message.data['direction'] == 'support' ||
                                message.data['from_support'] == true;
      
      if (isSupportMessage || message.notification != null) {
        // Показываем уведомление всегда, когда приходит сообщение от поддержки
        String title = message.notification?.title ?? 'Новое сообщение от поддержки';
        String body = message.notification?.body ?? 
                     message.data['message']?.toString() ?? 
                     'У вас новое сообщение';
        
        // Обрезаем длинное сообщение
        if (body.length > 100) {
          body = '${body.substring(0, 100)}...';
        }
        
        NotificationService.instance.showSupportNotification(
          title: title,
          body: body,
          data: message.data,
        );
        
        // Вызываем callback для обновления истории в UI
        if (onSupportReplyReceived != null) {
          onSupportReplyReceived!();
        }
        debugPrint('FCMService: получен ответ от поддержки: $body');
      }
    });
    
    // Обработка нажатия на уведомление (когда приложение открыто из уведомления)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('FCMService: приложение открыто из уведомления: ${message.messageId}');
      debugPrint('FCMService: данные: ${message.data}');
      
      // Проверяем тип уведомления
      if (message.data['type'] == 'support_reply') {
        // Вызываем callback для обновления истории
        if (onSupportReplyReceived != null) {
          onSupportReplyReceived!();
        }
      }
      
      // Навигация будет обработана через глобальный ключ навигатора
      _handleNotificationNavigation(message.data);
    });
    
    // Проверяем, было ли приложение открыто из уведомления при запуске
    _messaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        debugPrint('FCMService: приложение открыто из уведомления при запуске: ${message.messageId}');
        debugPrint('FCMService: данные: ${message.data}');
        
        // Проверяем тип уведомления
        if (message.data['type'] == 'support_reply') {
          // Вызываем callback для обновления истории
          if (onSupportReplyReceived != null) {
            onSupportReplyReceived!();
          }
        }
        
        _handleNotificationNavigation(message.data);
      }
    });
  }
  
  /// Обработка навигации при нажатии на уведомление
  void _handleNotificationNavigation(Map<String, dynamic> data) {
    // Сохраняем данные для навигации
    // Навигация будет выполнена через глобальный ключ навигатора в main.dart
    // Это будет обработано через callback
    if (_onNotificationTapped != null) {
      _onNotificationTapped!(data);
    }
  }
  
  /// Callback для навигации при нажатии на уведомление
  Function(Map<String, dynamic>)? _onNotificationTapped;
  
  /// Установить callback для навигации
  void setNotificationTapCallback(Function(Map<String, dynamic>) callback) {
    _onNotificationTapped = callback;
  }
  
  /// Получить текущий FCM токен
  String? get fcmToken => _fcmToken;
  
  /// Проверить, инициализирован ли сервис
  bool get isInitialized => _isInitialized;
  
  /// Очистка ресурсов (остановка таймеров)
  void cleanup() {
    _iosTokenRetryTimer?.cancel();
    _iosTokenRetryTimer = null;
  }
}


