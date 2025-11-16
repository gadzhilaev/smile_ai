import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'services/notification_service.dart';
import 'auth/login.dart';

void main() async {
  final WidgetsBinding widgetsBinding =
      WidgetsFlutterBinding.ensureInitialized();

  // Держим нативный splash, пока идёт инициализация
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

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

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      ),
      // Сразу открываем экран ввода e-mail, без Flutter-сплэша
      home: const EmailScreen(),
    );
  }
}
