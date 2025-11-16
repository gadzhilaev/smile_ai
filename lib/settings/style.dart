import 'package:flutter/material.dart';
import 'colors.dart';

class AppTextStyle {
  // Базовый метод для создания стиля (Montserrat)
  static TextStyle _base({
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
    // double? height,
    String? fontFamily,
  }) {
    return TextStyle(
      fontFamily: fontFamily ?? 'Montserrat',
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      // height: height ?? 1,
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
      color: color ?? AppColors.primaryText,
    );
  }

  // Основной текст
  static TextStyle bodyText(double fontSize, {Color? color, double? height}) {
    return _base(
      fontSize: fontSize,
      fontWeight: FontWeight.w400,
      color: color ?? Colors.black,
      // height: height,
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
      color: AppColors.textSecondary,
    );
  }

  static TextStyle fieldText(double fontSize) {
    return _base(
      fontSize: fontSize,
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimary,
    );
  }

  static TextStyle fieldHint(double fontSize) {
    return _base(
      fontSize: fontSize,
      fontWeight: FontWeight.w400,
      color: AppColors.textSecondary,
    );
  }

  static TextStyle fieldLabelAuth(double fontSize) {
    return _base(
      fontSize: fontSize,
      fontWeight: FontWeight.w400,
      color: AppColors.textGrey,
    );
  }

  static TextStyle fieldHintAuth(double fontSize) {
    return _base(
      fontSize: fontSize,
      fontWeight: FontWeight.w400,
      color: AppColors.textGrey,
    );
  }

  // Выпадающие списки
  static TextStyle dropdownMenuItem(double fontSize) {
    return _base(
      fontSize: fontSize,
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimary,
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
      color: AppColors.textMuted,
      // height: 18 / 12,
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
      color: color ?? AppColors.textPrimary,
      // height: height,
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

