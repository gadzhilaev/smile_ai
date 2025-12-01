import 'dart:io';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../firebase_options.dart';
import 'support_service.dart';
import 'notification_service.dart';

/// Обработчик фоновых сообщений Firebase
/// ВАЖНО: Этот обработчик должен быть top-level функцией
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Инициализируем Firebase с правильными опциями
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  debugPrint('═══════════════════════════════════════════════════════');
  debugPrint('🌙 FCMService: ФОНОВОЕ СООБЩЕНИЕ ПОЛУЧЕНО');
  debugPrint('═══════════════════════════════════════════════════════');
  debugPrint('   Message ID: ${message.messageId}');
  debugPrint('   From: ${message.from}');
  debugPrint('   Sent Time: ${message.sentTime}');
  debugPrint('   Data: ${message.data}');
  debugPrint('   Notification Title: ${message.notification?.title}');
  debugPrint('   Notification Body: ${message.notification?.body}');
  debugPrint('   Notification Android: ${message.notification?.android}');
  debugPrint('   Notification Apple: ${message.notification?.apple}');
  debugPrint('═══════════════════════════════════════════════════════');
  
  // Проверяем тип уведомления
  final isSupportMessage = message.data['type'] == 'support_reply' || 
                           message.data['type'] == 'support_message' ||
                           message.data['direction'] == 'support' ||
                           message.data['from_support'] == true;
  
  if (isSupportMessage) {
    final userId = message.data['user_id'];
    debugPrint('✅ FCMService: Получен ответ от поддержки для пользователя: $userId');
    debugPrint('   Уведомление будет показано автоматически через Firebase');
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
  
  /// Callback для обновления истории при получении уведомления от поддержки
  static Function()? onSupportReplyReceived;
  
  /// Инициализация FCM с userId
  /// ВАЖНО: Вызывается ОДИН РАЗ при запуске приложения или входе пользователя
  Future<void> initialize(String userId) async {
    if (_isInitialized) {
      // Если уже инициализирован, но userId изменился, перерегистрируем токен
      if (_currentUserId != userId) {
        debugPrint('🔄 FCMService: userId изменился, перерегистрируем токен');
        debugPrint('   Старый userId: ${_currentUserId?.substring(0, 8) ?? "null"}...');
        debugPrint('   Новый userId: ${userId.substring(0, 8)}...');
        _currentUserId = userId;
        await registerTokenForUser(userId);
      }
      return;
    }
    
    _currentUserId = userId;
    
    try {
      debugPrint('═══════════════════════════════════════════════════════');
      debugPrint('🔔 FCMService: НАЧАЛО ИНИЦИАЛИЗАЦИИ FCM');
      debugPrint('═══════════════════════════════════════════════════════');
      debugPrint('📱 Платформа: ${Platform.isAndroid ? "Android" : "iOS"}');
      debugPrint('👤 UserId: ${userId.substring(0, 8)}...');
      debugPrint('═══════════════════════════════════════════════════════');
      
      // Запрашиваем разрешение на уведомления
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      
      debugPrint('📱 FCMService: Запрос разрешения на уведомления...');
      debugPrint('   Статус разрешения: ${settings.authorizationStatus}');
      debugPrint('   Alert: ${settings.alert}');
      debugPrint('   Badge: ${settings.badge}');
      debugPrint('   Sound: ${settings.sound}');
      
      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        debugPrint('✅ FCMService: Разрешение на уведомления ПРЕДОСТАВЛЕНО');
        // Настраиваем обработчики сообщений
        _setupMessageHandlers();
        
        // Слушаем обновления токена
        _messaging.onTokenRefresh.listen((newToken) {
          debugPrint('═══════════════════════════════════════════════════════');
          debugPrint('🔄 FCMService: FCM ТОКЕН ОБНОВЛЕН');
          debugPrint('═══════════════════════════════════════════════════════');
          debugPrint('   Старый токен: ${_fcmToken?.substring(0, 20) ?? "null"}...');
          debugPrint('   Новый токен: ${newToken.substring(0, 20)}...');
          debugPrint('   Полный новый токен: $newToken');
          debugPrint('   Регистрация нового токена на сервере...');
          debugPrint('═══════════════════════════════════════════════════════');
          _fcmToken = newToken;
          if (_currentUserId != null) {
            registerTokenForUser(_currentUserId!);
          }
        });
        
        debugPrint('✅ FCMService: Обработчики сообщений настроены');
        debugPrint('   - onMessage (приложение активно)');
        debugPrint('   - onMessageOpenedApp (открыто из уведомления)');
        debugPrint('   - getInitialMessage (открыто при запуске)');
        debugPrint('   - onTokenRefresh (обновление токена)');
        
        // Для Android просто получаем токен
        // Для iOS получаем токен только если есть платный аккаунт (иначе будет ошибка)
        if (Platform.isAndroid) {
          await _getFCMTokenAndRegister(userId);
        } else if (Platform.isIOS) {
          // Для iOS пытаемся получить токен, но не делаем сложных проверок APNS
          // Если нет платного аккаунта, токен не получится - это нормально
          try {
            _fcmToken = await _messaging.getToken();
            if (_fcmToken != null) {
              debugPrint('✅ FCMService: FCM Token получен для iOS!');
              await registerTokenForUser(userId);
            } else {
              debugPrint('⚠️ FCMService: FCM токен для iOS вернул null (возможно, нет платного аккаунта)');
            }
          } catch (e) {
            debugPrint('⚠️ FCMService: Не удалось получить FCM токен для iOS: $e');
            debugPrint('   Это нормально, если нет платного Apple Developer аккаунта');
          }
        }
        
        _isInitialized = true;
        debugPrint('═══════════════════════════════════════════════════════');
        debugPrint('✅ FCMService: FCM ИНИЦИАЛИЗИРОВАН УСПЕШНО');
        debugPrint('═══════════════════════════════════════════════════════');
      } else {
        debugPrint('═══════════════════════════════════════════════════════');
        debugPrint('❌ FCMService: РАЗРЕШЕНИЕ НА УВЕДОМЛЕНИЯ НЕ ПРЕДОСТАВЛЕНО');
        debugPrint('   Статус: ${settings.authorizationStatus}');
        debugPrint('═══════════════════════════════════════════════════════');
      }
    } catch (e, stackTrace) {
      debugPrint('═══════════════════════════════════════════════════════');
      debugPrint('❌ FCMService: ОШИБКА ИНИЦИАЛИЗАЦИИ');
      debugPrint('═══════════════════════════════════════════════════════');
      debugPrint('Ошибка: $e');
      debugPrint('Stack trace: $stackTrace');
      debugPrint('═══════════════════════════════════════════════════════');
    }
  }
  
  String? _currentUserId;
  
  /// Получение FCM токена и регистрация на сервере
  Future<void> _getFCMTokenAndRegister(String userId) async {
    debugPrint('═══════════════════════════════════════════════════════');
    debugPrint('🔑 FCMService: ПОЛУЧЕНИЕ FCM ТОКЕНА');
    debugPrint('═══════════════════════════════════════════════════════');
    
    try {
      // Получаем токен устройства
      debugPrint('   Запрос FCM токена у Firebase...');
      _fcmToken = await _messaging.getToken();
      if (_fcmToken != null) {
        debugPrint('✅ FCMService: FCM Token получен!');
        debugPrint('   Токен (первые 20 символов): ${_fcmToken!.substring(0, 20)}...');
        debugPrint('   Полный токен: $_fcmToken');
        debugPrint('   Длина токена: ${_fcmToken!.length} символов');
        
        // Регистрируем токен на сервере
        debugPrint('   Регистрация токена на сервере...');
        await registerTokenForUser(userId);
      } else {
        debugPrint('⚠️ FCMService: FCM токен вернул null');
        debugPrint('   Это может быть нормально для iOS симулятора');
      }
    } catch (e, stackTrace) {
      debugPrint('═══════════════════════════════════════════════════════');
      debugPrint('❌ FCMService: ОШИБКА ПОЛУЧЕНИЯ FCM ТОКЕНА');
      debugPrint('═══════════════════════════════════════════════════════');
      debugPrint('Ошибка: $e');
      debugPrint('Stack trace: $stackTrace');
      debugPrint('═══════════════════════════════════════════════════════');
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
      debugPrint('═══════════════════════════════════════════════════════');
      debugPrint('📤 FCMService: РЕГИСТРАЦИЯ УСТРОЙСТВА НА СЕРВЕРЕ');
      debugPrint('═══════════════════════════════════════════════════════');
      debugPrint('   UserId: ${userId.substring(0, 8)}...');
      debugPrint('   Platform: $platform');
      debugPrint('   FCM Token: ${_fcmToken!.substring(0, 20)}...');
      debugPrint('   Полный FCM Token: $_fcmToken');
      debugPrint('   URL сервера: ${SupportService.baseUrl}/register_device');
      debugPrint('═══════════════════════════════════════════════════════');
      
      await SupportService.registerDevice(
        userId: userId,
        fcmToken: _fcmToken!,
        platform: platform,
      );
      
      debugPrint('═══════════════════════════════════════════════════════');
      debugPrint('✅ FCMService: УСТРОЙСТВО УСПЕШНО ЗАРЕГИСТРИРОВАНО!');
      debugPrint('═══════════════════════════════════════════════════════');
      debugPrint('   UserId: ${userId.substring(0, 8)}...');
      debugPrint('   Platform: $platform');
      debugPrint('   Теперь push-уведомления будут приходить на это устройство');
      debugPrint('═══════════════════════════════════════════════════════');
    } catch (e, stackTrace) {
      debugPrint('═══════════════════════════════════════════════════════');
      debugPrint('❌ FCMService: ОШИБКА РЕГИСТРАЦИИ ТОКЕНА НА СЕРВЕРЕ');
      debugPrint('═══════════════════════════════════════════════════════');
      debugPrint('Ошибка: $e');
      debugPrint('Stack trace: $stackTrace');
      debugPrint('   UserId: ${userId.substring(0, 8)}...');
      debugPrint('   Platform: ${Platform.isAndroid ? 'android' : 'ios'}');
      debugPrint('   FCM Token: ${_fcmToken?.substring(0, 20) ?? "null"}...');
      debugPrint('═══════════════════════════════════════════════════════');
    }
  }
  
  /// Настройка обработчиков сообщений
  void _setupMessageHandlers() {
    debugPrint('═══════════════════════════════════════════════════════');
    debugPrint('🔧 FCMService: НАСТРОЙКА ОБРАБОТЧИКОВ СООБЩЕНИЙ');
    debugPrint('═══════════════════════════════════════════════════════');
    
    // Обработка сообщений, когда приложение на переднем плане
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('═══════════════════════════════════════════════════════');
      debugPrint('📨 FCMService: СООБЩЕНИЕ ПОЛУЧЕНО (ПРИЛОЖЕНИЕ АКТИВНО)');
      debugPrint('═══════════════════════════════════════════════════════');
      debugPrint('   Message ID: ${message.messageId}');
      debugPrint('   From: ${message.from}');
      debugPrint('   Sent Time: ${message.sentTime}');
      debugPrint('   Data: ${message.data}');
      debugPrint('   Notification Title: ${message.notification?.title}');
      debugPrint('   Notification Body: ${message.notification?.body}');
      debugPrint('   Notification Android: ${message.notification?.android}');
      debugPrint('   Notification Apple: ${message.notification?.apple}');
      debugPrint('═══════════════════════════════════════════════════════');
      
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
      debugPrint('═══════════════════════════════════════════════════════');
      debugPrint('👆 FCMService: ПРИЛОЖЕНИЕ ОТКРЫТО ИЗ УВЕДОМЛЕНИЯ');
      debugPrint('═══════════════════════════════════════════════════════');
      debugPrint('   Message ID: ${message.messageId}');
      debugPrint('   From: ${message.from}');
      debugPrint('   Data: ${message.data}');
      debugPrint('   Notification Title: ${message.notification?.title}');
      debugPrint('   Notification Body: ${message.notification?.body}');
      debugPrint('   Route: ${message.data['route']}');
      debugPrint('═══════════════════════════════════════════════════════');
      
      // Проверяем тип уведомления для обновления UI
      final isSupportMessage = message.data['type'] == 'support_reply' || 
                               message.data['type'] == 'support_message' ||
                               message.data['direction'] == 'support' ||
                               message.data['from_support'] == true ||
                               message.data['route'] == 'support_chat';
      
      if (isSupportMessage) {
        // Вызываем callback для обновления истории
        if (onSupportReplyReceived != null) {
          onSupportReplyReceived!();
        }
      }
      
      // Навигация будет обработана через глобальный ключ навигатора
      // Логика навигации (AI или Support) обрабатывается в main.dart
      _handleNotificationNavigation(message.data);
    });
    
    // Проверяем, было ли приложение открыто из уведомления при запуске
    _messaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        debugPrint('═══════════════════════════════════════════════════════');
        debugPrint('🚀 FCMService: ПРИЛОЖЕНИЕ ОТКРЫТО ИЗ УВЕДОМЛЕНИЯ ПРИ ЗАПУСКЕ');
        debugPrint('═══════════════════════════════════════════════════════');
        debugPrint('   Message ID: ${message.messageId}');
        debugPrint('   From: ${message.from}');
        debugPrint('   Data: ${message.data}');
        debugPrint('   Notification Title: ${message.notification?.title}');
        debugPrint('   Notification Body: ${message.notification?.body}');
        debugPrint('   Route: ${message.data['route']}');
        debugPrint('═══════════════════════════════════════════════════════');
        
        // Проверяем тип уведомления для обновления UI
        final isSupportMessage = message.data['type'] == 'support_reply' || 
                                 message.data['type'] == 'support_message' ||
                                 message.data['direction'] == 'support' ||
                                 message.data['from_support'] == true ||
                                 message.data['route'] == 'support_chat';
        
        if (isSupportMessage) {
          // Вызываем callback для обновления истории
          if (onSupportReplyReceived != null) {
            onSupportReplyReceived!();
          }
        }
        
        // Навигация будет обработана через глобальный ключ навигатора
        // Логика навигации (AI или Support) обрабатывается в main.dart
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
  
  /// Очистка ресурсов
  void cleanup() {
    // Очистка ресурсов при необходимости
  }
}


