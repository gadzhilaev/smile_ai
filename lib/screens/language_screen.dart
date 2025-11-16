import 'package:flutter/material.dart';

import '../settings/style.dart';
import '../settings/colors.dart';
import '../l10n/app_localizations.dart';
import '../services/language_service.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  static const double _designWidth = 428;
  static const double _designHeight = 926;

  String _selectedLanguage = 'ru'; // 'ru' или 'en'

  @override
  void initState() {
    super.initState();
    final current = LanguageService.instance.localeNotifier.value;
    _selectedLanguage = current.languageCode == 'en' ? 'en' : 'ru';
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double widthFactor = size.width / _designWidth;
    final double heightFactor = size.height / _designHeight;

    double scaleWidth(double value) => value * widthFactor;
    double scaleHeight(double value) => value * heightFactor;

    final localization = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackgroundMain : AppColors.backgroundMain,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          top: true,
          bottom: false,
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Стрелка назад и заголовок
                Padding(
                  padding: EdgeInsets.only(
                    left: scaleWidth(18),
                    top: scaleHeight(18),
                    right: scaleWidth(26),
                  ),
                  child: Row(
                    children: [
                      // Стрелка назад
                      InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        borderRadius: BorderRadius.circular(scaleWidth(16)),
                        child: Padding(
                          padding: EdgeInsets.all(scaleWidth(4)),
                          child: Icon(
                            Icons.arrow_back,
                            size: scaleWidth(28),
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            localization.languageTitle,
                            style: AppTextStyle.screenTitle(
                              scaleHeight(20),
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: scaleWidth(28)), // Для выравнивания
                    ],
                  ),
                ),
                SizedBox(height: scaleHeight(44)),
                // Контент
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: scaleWidth(26)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Заголовок "Предложенные" / "Suggested"
                      Text(
                        localization.languageSectionSuggested,
                        style: AppTextStyle.screenTitle(
                          scaleHeight(16),
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: scaleHeight(14)),
                      _LanguageRadioRow(
                        title: localization.languageRussian,
                        isSelected: _selectedLanguage == 'ru',
                        onTap: () {
                          setState(() {
                            _selectedLanguage = 'ru';
                            LanguageService.instance
                                .setLocale(const Locale('ru'));
                          });
                        },
                        scaleWidth: scaleWidth,
                        scaleHeight: scaleHeight,
                      ),
                      SizedBox(height: scaleHeight(12)),
                      _LanguageRadioRow(
                        title: localization.languageEnglish,
                        isSelected: _selectedLanguage == 'en',
                        onTap: () {
                          setState(() {
                            _selectedLanguage = 'en';
                            LanguageService.instance
                                .setLocale(const Locale('en'));
                          });
                        },
                        scaleWidth: scaleWidth,
                        scaleHeight: scaleHeight,
                      ),
                      SizedBox(height: scaleHeight(40)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageRadioRow extends StatelessWidget {
  const _LanguageRadioRow({
    required this.title,
    required this.isSelected,
    required this.onTap,
    required this.scaleWidth,
    required this.scaleHeight,
  });

  final String title;
  final bool isSelected;
  final VoidCallback onTap;
  final double Function(double) scaleWidth;
  final double Function(double) scaleHeight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(scaleHeight(8)),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: scaleHeight(4)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: AppTextStyle.bodyText(
                  scaleHeight(16),
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            SizedBox(width: scaleWidth(12)),
            _LanguageRadio(
              isSelected: isSelected,
              scaleWidth: scaleWidth,
              scaleHeight: scaleHeight,
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageRadio extends StatelessWidget {
  const _LanguageRadio({
    required this.isSelected,
    required this.scaleWidth,
    required this.scaleHeight,
  });

  final bool isSelected;
  final double Function(double) scaleWidth;
  final double Function(double) scaleHeight;

  @override
  Widget build(BuildContext context) {
    final double outerSize = scaleWidth(24);
    final double innerSize = scaleWidth(12);

    if (isSelected) {
      // Активное состояние: синий круг + белый круг внутри
      return Container(
        width: outerSize,
        height: outerSize,
        decoration: BoxDecoration(
          color: AppColors.primaryBlue,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Container(
          width: innerSize,
          height: innerSize,
          decoration: const BoxDecoration(
            color: AppColors.white,
            shape: BoxShape.circle,
          ),
        ),
      );
    } else {
      // Неактивное состояние
      return Container(
        width: outerSize,
        height: outerSize,
        decoration: BoxDecoration(
          color: AppColors.radioInactiveBg,
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.radioInactiveBorder,
            width: 2,
          ),
        ),
      );
    }
  }
}


