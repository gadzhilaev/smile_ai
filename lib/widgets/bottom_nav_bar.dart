import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../settings/style.dart';
import '../settings/colors.dart';
import '../l10n/app_localizations.dart';

class MainBottomNavBar extends StatelessWidget {
  const MainBottomNavBar({
    super.key,
    required this.designWidth,
    required this.designHeight,
    required this.primaryColor,
    required this.accentColor,
    required this.currentIndex,
    required this.onTap,
  });

  final double designWidth;
  final double designHeight;
  final Color primaryColor;
  final Color accentColor;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double widthFactor = size.width / designWidth;
    final double bottomInset = MediaQuery.of(context).padding.bottom;

    double scaleWidth(double value) => value * widthFactor;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color effectivePrimaryColor =
        isDark ? AppColors.darkSecondaryText : primaryColor;
    final Color effectiveAccentColor = accentColor;

    return Container(
      color: isDark ? AppColors.darkBackgroundCard : AppColors.white,
      padding: EdgeInsets.only(
        left: scaleWidth(24),
        right: scaleWidth(24),
        bottom: bottomInset,
      ),
      child: SizedBox(
        height: 72,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.center,
                child: Builder(
                  builder: (context) {
                    final l = AppLocalizations.of(context)!;
                    return _NavItem(
                      iconPath: currentIndex == 0
                          ? 'assets/nav_bar/select/ai.svg'
                          : (isDark
                              ? 'assets/nav_bar/unselect/dark/ai.svg'
                              : 'assets/nav_bar/unselect/light/ai.svg'),
                      label: l.navAi,
                      labelColor: currentIndex == 0
                          ? effectiveAccentColor
                          : effectivePrimaryColor,
                      designWidth: designWidth,
                      designHeight: designHeight,
                      onTap: () => onTap(0),
                    );
                  },
                ),
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.center,
                child: Builder(
                  builder: (context) {
                    final l = AppLocalizations.of(context)!;
                    return _NavItem(
                      iconPath: currentIndex == 1
                          ? 'assets/nav_bar/select/bookmark.svg'
                          : (isDark
                              ? 'assets/nav_bar/unselect/dark/bookmark.svg'
                              : 'assets/nav_bar/unselect/light/bookmark.svg'),
                      label: l.navTemplates,
                      labelColor: currentIndex == 1
                          ? effectiveAccentColor
                          : effectivePrimaryColor,
                      designWidth: designWidth,
                      designHeight: designHeight,
                      onTap: () => onTap(1),
                    );
                  },
                ),
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.center,
                child: Builder(
                  builder: (context) {
                    final l = AppLocalizations.of(context)!;
                    return _NavItem(
                      iconPath: currentIndex == 2
                          ? 'assets/nav_bar/select/analytics.svg'
                          : (isDark
                              ? 'assets/nav_bar/unselect/dark/analytics.svg'
                              : 'assets/nav_bar/unselect/light/analytics.svg'),
                      label: l.navAnalytics,
                      labelColor: currentIndex == 2
                          ? effectiveAccentColor
                          : effectivePrimaryColor,
                      designWidth: designWidth,
                      designHeight: designHeight,
                      onTap: () => onTap(2),
                    );
                  },
                ),
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.center,
                child: Builder(
                  builder: (context) {
                    final l = AppLocalizations.of(context)!;
                    return _NavItem(
                      iconPath: currentIndex == 3
                          ? 'assets/nav_bar/select/person.svg'
                          : (isDark
                              ? 'assets/nav_bar/unselect/dark/person.png'
                              : 'assets/nav_bar/unselect/light/person.svg'),
                      label: l.navProfile,
                      labelColor: currentIndex == 3
                          ? effectiveAccentColor
                          : effectivePrimaryColor,
                      designWidth: designWidth,
                      designHeight: designHeight,
                      onTap: () => onTap(3),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.iconPath,
    required this.label,
    required this.labelColor,
    required this.designWidth,
    required this.designHeight,
    required this.onTap,
  });

  final String iconPath;
  final String label;
  final Color labelColor;
  final double designWidth;
  final double designHeight;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double widthFactor = size.width / designWidth;
    final double heightFactor = size.height / designHeight;

    double scaleWidth(double value) => value * widthFactor;
    double scaleHeight(double value) => value * heightFactor;

    final bool isSvg = iconPath.toLowerCase().endsWith('.svg');
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    // Специальный случай: неактивная иконка AI в тёмной теме
    final bool isAiDarkUnselected =
        isSvg && iconPath.endsWith('nav_bar/unselect/dark/ai.svg');

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(scaleWidth(8)),
      child: Padding(
        padding: EdgeInsets.all(scaleWidth(8)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSvg)
              SvgPicture.asset(
                iconPath,
                width: scaleWidth(24),
                height: scaleHeight(24),
                fit: BoxFit.contain,
                colorFilter: isAiDarkUnselected && isDark
                    ? const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      )
                    : null,
              )
            else
              Image.asset(
                iconPath,
                width: scaleWidth(24),
                height: scaleHeight(24),
                fit: BoxFit.contain,
              ),
            SizedBox(height: scaleHeight(4)),
            Text(
              label,
              style: AppTextStyle.navBarLabel(scaleHeight(10), labelColor),
            ),
          ],
        ),
      ),
    );
  }
}
