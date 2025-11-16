import 'package:flutter/material.dart';

/// Единое хранилище всех цветов приложения
class AppColors {
  AppColors._();

  // Базовые цвета
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  // Основная палитра бренда
  static const Color primaryText = Color(0xFF201D2F);
  static const Color accentRed = Color(0xFFAD2023);
  static const Color primaryBlue = Color(0xFF1573FE);

  // Фоны
  static const Color backgroundMain = Color(0xFFF7F7F7);
  static const Color backgroundSection = Color(0xFFF0EBEB);
  static const Color backgroundWhite = Color(0xFFFFFFFF);

  // Текст
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textMuted = Color(0xFF98A7BD);
  static const Color textGrey = Color(0xFFA3A3A3);
  static const Color textDarkGrey = Color(0xFF9E9E9E);
  static const Color textError = Color(0xFFDF1525);
  static const Color textSuccess = Color(0xFF178751);
  static const Color textWarning = Color(0xFF76090B);
  static const Color textProfileSecondary = Color(0xFF898989);

  // Бордеры и разделители
  static const Color borderDefault = Color(0xFFE4E4E4);
  static const Color borderLight = Color(0xFFDBDBDB);
  static const Color borderMuted = Color(0x8CA3A3A3);
  static const Color dividerLight = Color(0xFFEEEEEE);

  // Фоны инпутов/ошибок
  static const Color inputErrorBg = Color(0xFFFFECEF);
  static const Color inputActiveBg = Color(0xFFF3F8FF);

  // Чипы/бейджи
  static const Color chipMarketing = Color(0x80D300E6);
  static const Color chipSales = Color(0x80007B0C);
  static const Color chipAlt = Color(0x806F00E6);
  static const Color chipDarkOverlay = Color(0x801E293B);

  // Прочее
  static const Color overlayShadow = Color(0x1F18274B);

  // Радио-кнопки для выбора языка/темы
  static const Color radioInactiveBg = Color(0xFFE3EEFF);
  static const Color radioInactiveBorder = Color(0xFFC7DDFF);

  // Темная тема (палитра)
  static const Color darkBackgroundMain = Color(0xFF090A0F);
  static const Color darkBackgroundCard = Color(0xFF111827);
  static const Color darkPrimaryText = Color(0xFFF9FAFB);
  static const Color darkSecondaryText = Color(0xFF9CA3AF);
  static const Color darkDivider = Color(0xFF374151);
}


