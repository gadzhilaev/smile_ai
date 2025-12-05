import Flutter
import UIKit
import FirebaseCore
import FirebaseMessaging
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Инициализация Firebase
    FirebaseApp.configure()
    
    // Настройка Firebase Messaging
    // НЕ запрашиваем разрешение здесь - это делается в FCMService через Flutter
    // Это предотвращает двойной запрос разрешения
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
      // Убрали requestAuthorization отсюда - запрос происходит в FCMService
    }
    
    // Регистрация для remote notifications (требует платный Apple Developer аккаунт)
    // Раскомментируйте, если у вас есть платный аккаунт
    // application.registerForRemoteNotifications()
    
    // Устанавливаем делегат для Firebase Messaging
    Messaging.messaging().delegate = self
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // Регистрация токена APNS
  override func application(_ application: UIApplication,
                           didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
    print("📱 iOS: APNS токен получен в AppDelegate: \(tokenString)")
    
    // Устанавливаем APNS токен для Firebase Messaging
    Messaging.messaging().apnsToken = deviceToken
    
    // Пытаемся получить FCM токен сразу после установки APNS токена
    Messaging.messaging().token { token, error in
      if let error = error {
        print("❌ iOS: Ошибка получения FCM токена: \(error.localizedDescription)")
      } else if let token = token {
        print("🔑 iOS: FCM токен получен в AppDelegate: \(token)")
        // Отправляем уведомление в Flutter
        let dataDict: [String: String] = ["token": token]
        NotificationCenter.default.post(
          name: Notification.Name("FCMToken"),
          object: nil,
          userInfo: dataDict
        )
      }
    }
  }
  
  // Ошибка регистрации APNS
  override func application(_ application: UIApplication,
                           didFailToRegisterForRemoteNotificationsWithError error: Error) {
    print("❌ iOS: Ошибка регистрации APNS: \(error.localizedDescription)")
    print("   Детали ошибки: \(error)")
    
    // Проверяем, может ли быть проблема с capabilities
    if let nsError = error as NSError? {
      print("   Код ошибки: \(nsError.code)")
      print("   Домен ошибки: \(nsError.domain)")
      print("   Информация: \(nsError.userInfo)")
    }
  }
  
  // Получение push-уведомления в фоне
  override func application(_ application: UIApplication,
                           didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                           fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    print("📨 iOS: Получено фоновое уведомление: \(userInfo)")
    Messaging.messaging().appDidReceiveMessage(userInfo)
    completionHandler(.newData)
  }
}

// Расширение для Firebase Messaging Delegate
extension AppDelegate: MessagingDelegate {
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    print("🔑 iOS: FCM токен получен: \(fcmToken ?? "nil")")
    let dataDict: [String: String] = ["token": fcmToken ?? ""]
    NotificationCenter.default.post(
      name: Notification.Name("FCMToken"),
      object: nil,
      userInfo: dataDict
    )
  }
}
