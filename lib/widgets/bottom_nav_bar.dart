import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MainBottomNavBar extends StatelessWidget {
  const MainBottomNavBar({
    super.key,
    required this.designWidth,
    required this.designHeight,
    required this.primaryColor,
    required this.accentColor,
  });

  final double designWidth;
  final double designHeight;
  final Color primaryColor;
  final Color accentColor;

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
                child: _NavItem(
                  iconPath: 'assets/nav_bar/select/ai.png',
                  label: 'AI',
                  labelColor: accentColor,
                  designWidth: designWidth,
                  designHeight: designHeight,
                ),
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.center,
                child: _NavItem(
                  iconPath: 'assets/nav_bar/unselect/bookmark.png',
                  label: 'Шаблоны',
                  labelColor: primaryColor,
                  designWidth: designWidth,
                  designHeight: designHeight,
                ),
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.center,
                child: _NavItem(
                  iconPath: 'assets/nav_bar/unselect/analytics.png',
                  label: 'Аналитика',
                  labelColor: primaryColor,
                  designWidth: designWidth,
                  designHeight: designHeight,
                ),
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.center,
                child: _NavItem(
                  iconPath: 'assets/nav_bar/unselect/person.png',
                  label: 'Профиль',
                  labelColor: primaryColor,
                  designWidth: designWidth,
                  designHeight: designHeight,
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
  });

  final String iconPath;
  final String label;
  final Color labelColor;
  final double designWidth;
  final double designHeight;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double widthFactor = size.width / designWidth;
    final double heightFactor = size.height / designHeight;

    double scaleWidth(double value) => value * widthFactor;
    double scaleHeight(double value) => value * heightFactor;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          iconPath,
          width: scaleWidth(24),
          height: scaleHeight(24),
          fit: BoxFit.contain,
        ),
        SizedBox(height: scaleHeight(4)),
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: scaleHeight(10),
            fontWeight: FontWeight.w500,
            color: labelColor,
            height: 1,
          ),
        ),
      ],
    );
  }
}
