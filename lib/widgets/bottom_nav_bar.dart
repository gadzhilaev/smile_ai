import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../settings/style.dart';
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

    return Container(
      color: Colors.white,
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
                          : 'assets/nav_bar/unselect/ai.svg',
                      label: l.navAi,
                      labelColor:
                          currentIndex == 0 ? accentColor : primaryColor,
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
                          : 'assets/nav_bar/unselect/bookmark.svg',
                      label: l.navTemplates,
                      labelColor:
                          currentIndex == 1 ? accentColor : primaryColor,
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
                          : 'assets/nav_bar/unselect/analytics.svg',
                      label: l.navAnalytics,
                      labelColor:
                          currentIndex == 2 ? accentColor : primaryColor,
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
                          : 'assets/nav_bar/unselect/person.svg',
                      label: l.navProfile,
                      labelColor:
                          currentIndex == 3 ? accentColor : primaryColor,
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

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(scaleWidth(8)),
      child: Padding(
        padding: EdgeInsets.all(scaleWidth(8)),
        child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
            SvgPicture.asset(
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
