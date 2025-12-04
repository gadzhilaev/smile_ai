import 'package:flutter/material.dart';

import '../../settings/style.dart';
import '../../settings/colors.dart';
import '../../l10n/app_localizations.dart';
import '../../services/theme_service.dart';

class ThemeScreen extends StatefulWidget {
  const ThemeScreen({super.key});

  @override
  State<ThemeScreen> createState() => _ThemeScreenState();
}

class _ThemeScreenState extends State<ThemeScreen> {
  static const double _designWidth = 428;
  static const double _designHeight = 926;

  late ThemeMode _selectedMode;

  @override
  void initState() {
    super.initState();
    _selectedMode = ThemeService.instance.themeModeNotifier.value;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double widthFactor = size.width / _designWidth;
    final double heightFactor = size.height / _designHeight;

    double scaleWidth(double value) => value * widthFactor;
    double scaleHeight(double value) => value * heightFactor;

    final l = AppLocalizations.of(context)!;
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
                            l.themeTitle,
                            style: AppTextStyle.screenTitle(
                              scaleHeight(20),
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: scaleWidth(28)),
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
                      Text(
                        l.themeTitle,
                        style: AppTextStyle.screenTitle(
                          scaleHeight(16),
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: scaleHeight(14)),
                      _ThemeRadioRow(
                        title: l.themeSystem,
                        isSelected: _selectedMode == ThemeMode.system,
                        onTap: () {
                          setState(() {
                            _selectedMode = ThemeMode.system;
                          });
                          ThemeService.instance.setThemeMode(ThemeMode.system);
                        },
                        scaleWidth: scaleWidth,
                        scaleHeight: scaleHeight,
                      ),
                      SizedBox(height: scaleHeight(12)),
                      _ThemeRadioRow(
                        title: l.themeLight,
                        isSelected: _selectedMode == ThemeMode.light,
                        onTap: () {
                          setState(() {
                            _selectedMode = ThemeMode.light;
                          });
                          ThemeService.instance.setThemeMode(ThemeMode.light);
                        },
                        scaleWidth: scaleWidth,
                        scaleHeight: scaleHeight,
                      ),
                      SizedBox(height: scaleHeight(12)),
                      _ThemeRadioRow(
                        title: l.themeDark,
                        isSelected: _selectedMode == ThemeMode.dark,
                        onTap: () {
                          setState(() {
                            _selectedMode = ThemeMode.dark;
                          });
                          ThemeService.instance.setThemeMode(ThemeMode.dark);
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

class _ThemeRadioRow extends StatelessWidget {
  const _ThemeRadioRow({
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
            _ThemeRadio(
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

class _ThemeRadio extends StatelessWidget {
  const _ThemeRadio({
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


