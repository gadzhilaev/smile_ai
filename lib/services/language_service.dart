import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Сервис для управления текущим языком приложения (с сохранением между запусками).
class LanguageService {
  LanguageService._();

  static final LanguageService instance = LanguageService._();

  static const String _prefKeyLanguageCode = 'app_language_code';

  /// Текущая локаль приложения.
  /// По умолчанию — русский.
  final ValueNotifier<Locale> localeNotifier =
      ValueNotifier<Locale>(const Locale('ru'));

  SharedPreferences? _prefs;

  /// Инициализация сервиса: читаем сохранённый язык из SharedPreferences.
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
    final savedCode = _prefs!.getString(_prefKeyLanguageCode);
    if (savedCode != null && savedCode.isNotEmpty) {
      localeNotifier.value = Locale(savedCode);
    }
  }

  void setLocale(Locale locale) {
    if (localeNotifier.value == locale) return;
    localeNotifier.value = locale;
    // Сохраняем выбранный язык, чтобы восстановить при следующем запуске
    _prefs?.setString(_prefKeyLanguageCode, locale.languageCode);
  }
}



