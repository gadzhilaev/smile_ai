import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'l10n/app_localizations.dart';
import 'services/notification_service.dart';
import 'services/language_service.dart';
import 'services/theme_service.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'services/profile_service.dart';
import 'utils/env_utils.dart';
import 'settings/colors.dart';
import 'auth/login.dart';
import 'screens/home_screen.dart';

void main() async {
  final WidgetsBinding widgetsBinding =
      WidgetsFlutterBinding.ensureInitialized();

  // Держим нативный splash, пока идёт инициализация
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Создаем .env файл с пустыми значениями, если его нет
  await EnvUtils.createEnvFileIfNotExists();
  debugPrint('Startup: .env file check completed');

  // Загружаем .env файл и синхронизируем токен
  await AuthService.instance.init();
  try {
    await dotenv.load(fileName: ".env");
    debugPrint('Startup: .env file loaded successfully');
    final envToken = dotenv.env['AUTH_TOKEN'];
    
    if (envToken != null && envToken.isNotEmpty && envToken.trim().isNotEmpty) {
      // Токен есть в .env - используем его
      debugPrint('Startup: AUTH_TOKEN found in .env: ${envToken.substring(0, 8)}...');
      await AuthService.instance.saveToken(envToken.trim());
      debugPrint('Startup: token from .env saved to AuthService');
    } else {
      // Токена нет в .env или он пустой - очищаем токен в AuthService
      debugPrint('Startup: AUTH_TOKEN not found in .env or is empty, clearing AuthService token');
      await AuthService.instance.clearToken();
    }
  } catch (e) {
    debugPrint('Startup: error loading .env file: $e');
    // При ошибке загрузки .env тоже очищаем токен для безопасности
    await AuthService.instance.clearToken();
  }

  // Загружаем сохранённый язык и тему до запуска приложения
  await LanguageService.instance.init();
  await ThemeService.instance.init();
  
  // Инициализируем ProfileService для загрузки данных из .env
  await ProfileService.instance.init();

  // Проверяем health сервера
  debugPrint('Startup: checking server health...');
  final isHealthy = await ApiService.instance.checkHealth();
  
  if (!isHealthy) {
    debugPrint('Startup: server health check failed, closing app...');
    // Закрываем приложение если health check не прошел
    FlutterNativeSplash.remove();
    if (Platform.isAndroid) {
      SystemNavigator.pop();
    } else {
      exit(0);
    }
    return;
  }

  debugPrint('Startup: server health check passed');

  // Проверяем токен до запуска приложения
  Widget? initialScreen;
  final token = AuthService.instance.getToken();
  debugPrint('Startup: checking token - token exists: ${token != null && token.isNotEmpty}');
  debugPrint('Startup: token value: ${token ?? "null"}');
  
  if (token != null && token.isNotEmpty) {
    debugPrint('Startup: checking token validity with API...');
    final result = await ApiService.instance.checkToken(token);
    debugPrint('Startup: API response: $result');
    debugPrint('Startup: result[valid] type: ${result['valid'].runtimeType}');
    debugPrint('Startup: result[valid] value: ${result['valid']}');
    
    // Проверяем валидность токена (может быть bool или строка)
    final isValid = result['valid'] == true || result['valid'] == 'true';
    debugPrint('Startup: token is valid: $isValid');
    
    if (isValid) {
      debugPrint('Startup: token is valid, will show home screen');
      initialScreen = const HomeScreen();
    } else {
      debugPrint('Startup: token is invalid, clearing token and showing login screen');
      await AuthService.instance.clearToken();
      initialScreen = const EmailScreen();
    }
  } else {
    debugPrint('Startup: no token found, showing login screen');
    initialScreen = const EmailScreen();
  }

  // Инициализируем уведомления
  try {
    debugPrint('Startup: initializing notifications...');
    await NotificationService.instance.initialize();
    await NotificationService.instance.requestPermissions();
  } catch (e) {
    debugPrint('Startup initialization error: $e');
  }

  // Убираем нативный splash только после всех проверок
  FlutterNativeSplash.remove();

  runApp(MainApp(initialScreen: initialScreen));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key, this.initialScreen});

  final Widget? initialScreen;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.instance.themeModeNotifier,
      builder: (context, themeMode, _) {
        return ValueListenableBuilder<Locale>(
          valueListenable: LanguageService.instance.localeNotifier,
          builder: (context, locale, __) {
            return MaterialApp(
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
              home: initialScreen ?? const EmailScreen(),
            );
          },
        );
      },
    );
  }
}
