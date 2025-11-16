import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'l10n/app_localizations.dart';
import 'services/notification_service.dart';
import 'services/language_service.dart';
import 'services/theme_service.dart';
import 'settings/colors.dart';
import 'auth/login.dart';

void main() async {
  final WidgetsBinding widgetsBinding =
      WidgetsFlutterBinding.ensureInitialized();

  // Держим нативный splash, пока идёт инициализация
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Загружаем сохранённый язык и тему до запуска приложения
  await LanguageService.instance.init();
  await ThemeService.instance.init();

  runApp(const MainApp());

  // Параллельно инициализируем уведомления и "загрузку данных"
  _initializeAppAsync();
}

Future<void> _initializeAppAsync() async {
  try {
    debugPrint('Startup: initializing notifications...');
    await NotificationService.instance.initialize();
    await NotificationService.instance.requestPermissions();

    debugPrint('Startup: loading initial API data...');
    // Имитируем запрос к API и ожидание данных (3 секунды)
    await Future.delayed(const Duration(seconds: 3));
    debugPrint('Startup: API data loaded successfully');
  } catch (e) {
    debugPrint('Startup initialization error: $e');
  } finally {
    // Убираем нативный splash только после инициализации/ожидания
    FlutterNativeSplash.remove();
  }
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
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
              // Сразу открываем экран ввода e-mail, без Flutter-сплэша
              home: const EmailScreen(),
            );
          },
        );
      },
    );
  }
}
