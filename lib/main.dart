import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';

import 'l10n/app_localizations.dart';
import 'services/notification_service.dart';
import 'services/fcm_service.dart' show FCMService, firebaseMessagingBackgroundHandler;
import 'services/language_service.dart';
import 'services/theme_service.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'services/profile_service.dart';
import 'utils/env_utils.dart';
import 'settings/colors.dart';
import 'auth/login.dart';
import 'screens/home_screen.dart';
import 'screens/support_screen.dart';

void main() async {
  final WidgetsBinding widgetsBinding =
      WidgetsFlutterBinding.ensureInitialized();

  // Фиксируем ориентацию экрана только портретная
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Держим нативный splash, пока идёт инициализация
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Инициализируем Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Ошибка инициализации Firebase
  }

  // Создаем .env файл с пустыми значениями, если его нет
  await EnvUtils.createEnvFileIfNotExists();

  // Загружаем .env файл и синхронизируем токен
  await AuthService.instance.init();
  try {
    await dotenv.load(fileName: ".env");
    await EnvUtils.mergeRuntimeEnvIntoDotenv();
    final envToken = dotenv.env['AUTH_TOKEN'];
    
    if (envToken != null && envToken.isNotEmpty && envToken.trim().isNotEmpty) {
      // Токен есть в .env - используем его
      await AuthService.instance.saveToken(envToken.trim());
    } else {
      // Токена нет в .env или он пустой - очищаем токен в AuthService
      await AuthService.instance.clearToken();
    }
  } catch (e) {
    // При ошибке загрузки .env тоже очищаем токен для безопасности
    await AuthService.instance.clearToken();
  }

  // Загружаем сохранённый язык и тему до запуска приложения
  await LanguageService.instance.init();
  await ThemeService.instance.init();
  
  // Инициализируем ProfileService для загрузки данных из .env
  await ProfileService.instance.init();

  // Проверяем health сервера
  final isHealthy = await ApiService.instance.checkHealth();
  
  if (!isHealthy) {
    // Закрываем приложение если health check не прошел
    FlutterNativeSplash.remove();
    if (Platform.isAndroid) {
      SystemNavigator.pop();
    } else {
      exit(0);
    }
    return;
  }

  // Проверяем токен до запуска приложения
  Widget? initialScreen;
  final token = AuthService.instance.getToken();
  
  if (token != null && token.isNotEmpty) {
    final result = await ApiService.instance.checkToken(token);
    
    // Проверяем валидность токена (может быть bool или строка)
    final isValid = result['valid'] == true || result['valid'] == 'true';
    
    if (isValid) {
      initialScreen = const HomeScreen();
    } else {
      await AuthService.instance.clearToken();
      initialScreen = const EmailScreen();
    }
  } else {
    initialScreen = const EmailScreen();
  }

  // Инициализируем уведомления
  try {
    await NotificationService.instance.initialize();
    await NotificationService.instance.requestPermissions();
  } catch (e) {
    // Ошибка инициализации уведомлений
  }

  // Инициализируем Firebase Cloud Messaging
  try {
    // Регистрируем фоновый обработчик
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    
    // Если пользователь уже авторизован, инициализируем FCM с userId
    final userId = dotenv.env['USER_ID'];
    if (userId != null && userId.isNotEmpty) {
      await FCMService.instance.initialize(userId);
    }
  } catch (e) {
    // Ошибка инициализации FCM
  }

  // Убираем нативный splash только после всех проверок
  FlutterNativeSplash.remove();

  runApp(MainApp(initialScreen: initialScreen));
}

class MainApp extends StatefulWidget {
  const MainApp({super.key, this.initialScreen});

  final Widget? initialScreen;

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    // Настраиваем callback для навигации при нажатии на уведомление
    FCMService.instance.setNotificationTapCallback((data) {
      _handleNotificationNavigation(data);
    });
    
    // Настраиваем обработчик для локальных уведомлений
    NotificationService.instance.setNotificationTapCallback((payload) {
      try {
        // Пытаемся распарсить payload как JSON
        final Map<String, dynamic>? data = jsonDecode(payload) as Map<String, dynamic>?;
        if (data != null) {
          final type = data['type']?.toString().toLowerCase() ?? '';
          final route = data['route']?.toString().toLowerCase() ?? '';
          final conversationId = data['conversation_id']?.toString();
          
          // Проверяем, является ли это уведомлением о завершении генерации AI
          if (type == 'ai_generation' || route == 'ai_chat' || route.contains('ai')) {
            _navigateToAI(conversationId: conversationId);
          } else {
            _navigateToSupport();
          }
        } else {
          // Fallback: если payload не JSON, проверяем как строку
          if (payload.contains('ai') || payload.contains('generation')) {
            _navigateToAI();
          } else {
            _navigateToSupport();
          }
        }
      } catch (e) {
        // Если не удалось распарсить, используем fallback
        if (payload.contains('ai') || payload.contains('generation')) {
          _navigateToAI();
        } else {
          _navigateToSupport();
        }
      }
    });
  }

  void _handleNotificationNavigation(Map<String, dynamic> data) {
    final navigator = navigatorKey.currentState;
    if (navigator == null) return;

    // Проверяем тип уведомления
    final type = data['type']?.toString().toLowerCase() ?? '';
    final route = data['route']?.toString().toLowerCase() ?? '';
    
    // Проверяем, является ли это уведомлением о завершении генерации AI
    final isAIGeneration = type.contains('ai') || 
                          type.contains('generation') ||
                          route.contains('ai') ||
                          route.contains('ai_chat') ||
                          data['ai_generation'] == true ||
                          data['ai_complete'] == true;

    if (isAIGeneration) {
      final conversationId = data['conversation_id']?.toString();
      _navigateToAI(conversationId: conversationId);
    } else {
      // По умолчанию открываем поддержку
      _navigateToSupport();
    }
  }

  void _navigateToSupport() {
    final navigator = navigatorKey.currentState;
    if (navigator != null) {
      navigator.push(
        MaterialPageRoute(
          builder: (_) => const SupportScreen(),
        ),
      );
    }
  }

  void _navigateToAI({String? conversationId}) {
    final navigator = navigatorKey.currentState;
    if (navigator != null) {
      // Открываем HomeScreen с conversationId, если он передан
      // HomeScreen уже содержит AiScreen с навбаром
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => conversationId != null && conversationId.isNotEmpty
              ? HomeScreenWithConversationId(conversationId: conversationId)
              : const HomeScreen(),
        ),
        (route) => false, // Удаляем все предыдущие маршруты
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.instance.themeModeNotifier,
      builder: (context, themeMode, _) {
        return ValueListenableBuilder<Locale>(
          valueListenable: LanguageService.instance.localeNotifier,
          builder: (context, locale, __) {
            return MaterialApp(
              navigatorKey: navigatorKey,
              debugShowCheckedModeBanner: false,
              themeMode: themeMode,
              theme: ThemeData(
                brightness: Brightness.light,
                scaffoldBackgroundColor: AppColors.backgroundMain,
                useMaterial3: true,
                colorScheme: ColorScheme.fromSeed(
                  seedColor: const Color(0xFF1573FE),
                  brightness: Brightness.light,
                ),
              ),
              darkTheme: ThemeData(
                brightness: Brightness.dark,
                scaffoldBackgroundColor: AppColors.darkBackgroundMain,
                useMaterial3: true,
                colorScheme: ColorScheme.fromSeed(
                  seedColor: const Color(0xFF1573FE),
                  brightness: Brightness.dark,
                ),
              ),
              locale: locale,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              home: widget.initialScreen ?? const EmailScreen(),
            );
          },
        );
      },
    );
  }
}
