import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Сервис управления темой приложения (сохранение между запусками).
class ThemeService {
  ThemeService._();

  static final ThemeService instance = ThemeService._();

  static const String _prefKeyThemeMode = 'app_theme_mode';

  /// Текущий режим темы приложения.
  /// По умолчанию — как в системе.
  final ValueNotifier<ThemeMode> themeModeNotifier =
      ValueNotifier<ThemeMode>(ThemeMode.system);

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
    final saved = _prefs!.getString(_prefKeyThemeMode);
    switch (saved) {
      case 'light':
        themeModeNotifier.value = ThemeMode.light;
        break;
      case 'dark':
        themeModeNotifier.value = ThemeMode.dark;
        break;
      case 'system':
      default:
        themeModeNotifier.value = ThemeMode.system;
        break;
    }
  }

  void setThemeMode(ThemeMode mode) {
    if (themeModeNotifier.value == mode) return;
    themeModeNotifier.value = mode;

    final value = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };

    _prefs?.setString(_prefKeyThemeMode, value);
  }
}


