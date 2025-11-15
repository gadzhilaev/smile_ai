import 'package:flutter/material.dart';

class AppTextStyle {
  // Базовый метод для создания стиля (Montserrat)
  static TextStyle _base({
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
    double? height,
    String? fontFamily,
  }) {
    return TextStyle(
      fontFamily: fontFamily ?? 'Montserrat',
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height ?? 1,
    );
  }

  // Заголовки экранов
  static TextStyle screenTitle(double fontSize, {Color? color}) {
    return _base(
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      color: color ?? Colors.black,
    );
  }

  static TextStyle screenTitleMedium(double fontSize, {Color? color}) {
    return _base(
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
      color: color ?? const Color(0xFF201D2F),
    );
  }

  // Основной текст
  static TextStyle bodyText(double fontSize, {Color? color, double? height}) {
    return _base(
      fontSize: fontSize,
      fontWeight: FontWeight.w400,
      color: color ?? Colors.black,
      height: height,
    );
  }

  static TextStyle bodyTextLight(double fontSize, {Color? color}) {
    return _base(
      fontSize: fontSize,
      fontWeight: FontWeight.w300,
      color: color ?? Colors.black,
    );
  }

  static TextStyle bodyTextMedium(double fontSize, {Color? color}) {
    return _base(
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
      color: color ?? Colors.black,
    );
  }

  static TextStyle bodyTextBold(double fontSize, {Color? color}) {
    return _base(
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      color: color ?? Colors.black,
    );
  }

  // Поля ввода
  static TextStyle fieldLabel(double fontSize) {
    return _base(
      fontSize: fontSize,
      fontWeight: FontWeight.w400,
      color: const Color(0xFF757575),
    );
  }

  static TextStyle fieldText(double fontSize) {
    return _base(
      fontSize: fontSize,
      fontWeight: FontWeight.w400,
      color: const Color(0xFF212121),
    );
  }

  static TextStyle fieldHint(double fontSize) {
    return _base(
      fontSize: fontSize,
      fontWeight: FontWeight.w400,
      color: const Color(0xFF757575),
    );
  }

  static TextStyle fieldLabelAuth(double fontSize) {
    return _base(
      fontSize: fontSize,
      fontWeight: FontWeight.w400,
      color: const Color(0xFFA3A3A3),
    );
  }

  static TextStyle fieldHintAuth(double fontSize) {
    return _base(
      fontSize: fontSize,
      fontWeight: FontWeight.w400,
      color: const Color(0xFFA3A3A3),
    );
  }

  // Выпадающие списки
  static TextStyle dropdownMenuItem(double fontSize) {
    return _base(
      fontSize: fontSize,
      fontWeight: FontWeight.w400,
      color: const Color(0xFF212121),
    );
  }

  // Навигация
  static TextStyle navBarLabel(double fontSize, Color color) {
    return _base(
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
      color: color,
    );
  }

  // Кнопки
  static TextStyle buttonText(double fontSize, {Color? color}) {
    return _base(
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
      color: color ?? Colors.black,
    );
  }

  // Специальные стили
  static TextStyle trendTitle(double fontSize, Color color) {
    return _base(
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      color: color,
    );
  }

  static TextStyle trendPercentage(double fontSize, Color color) {
    return _base(
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      color: color,
    );
  }

  static TextStyle trendDescription(double fontSize) {
    return _base(
      fontSize: fontSize,
      fontWeight: FontWeight.w300,
      color: Colors.black,
    );
  }

  static TextStyle templateCategory(double fontSize) {
    return _base(
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
      color: Colors.white,
    );
  }

  static TextStyle templateTitle(double fontSize) {
    return _base(
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
      color: Colors.black,
    );
  }

  static TextStyle templateDescription(double fontSize) {
    return _base(
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
      color: const Color(0xFF98A7BD),
      height: 18 / 12,
    );
  }

  static TextStyle templateButton(double fontSize) {
    return _base(
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
      color: Colors.black,
    );
  }

  static TextStyle templateButtonWhite(double fontSize) {
    return _base(
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
      color: Colors.white,
    );
  }

  // Сообщения чата
  static TextStyle chatMessage(double fontSize, {Color? color, double? height}) {
    return _base(
      fontSize: fontSize,
      fontWeight: FontWeight.w400,
      color: color ?? const Color(0xFF212121),
      height: height,
    );
  }

  // Inter шрифт (для профиля)
  static TextStyle interMedium(double fontSize, {Color? color}) {
    return _base(
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
      color: color ?? Colors.black,
      fontFamily: 'Inter',
    );
  }

  static TextStyle interRegular(double fontSize, {Color? color}) {
    return _base(
      fontSize: fontSize,
      fontWeight: FontWeight.w400,
      color: color ?? Colors.black,
      fontFamily: 'Inter',
    );
  }
}

