import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  static const double _designWidth = 428;
  static const double _designHeight = 926;
  static const Color _backgroundColor = Color(0xFFF7F7F7);
  static const Color _primaryTextColor = Color(0xFF201D2F);
  static const Color _accentColor = Color(0xFFAD2023);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        top: true,
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = MediaQuery.of(context).size;
            final widthFactor = size.width / _designWidth;
            final heightFactor = size.height / _designHeight;

            double scaleWidth(double value) => value * widthFactor;
            double scaleHeight(double value) => value * heightFactor;

            final List<String> chips = <String>[
              'Привет',
              'Как дела?',
              'Что умеешь?',
              'Спроси меня',
              'Помоги',
              'Совет',
            ];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: scaleHeight(13)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: scaleWidth(24)),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Smile AI',
                          style: GoogleFonts.montserrat(
                            fontSize: scaleHeight(20),
                            fontWeight: FontWeight.w500,
                            color: _primaryTextColor,
                            height: 1,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: EdgeInsets.only(right: scaleWidth(29)),
                          child: Image.asset(
                            'assets/icons/icon_mes.png',
                            width: scaleWidth(24),
                            height: scaleHeight(24),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: scaleHeight(24)),
                Container(
                  width: double.infinity,
                  height: 1,
                  color: const Color(0xFF9E9E9E),
                ),
                SizedBox(height: scaleHeight(23)),
                Center(
                  child: Image.asset(
                    'assets/images/bot.png',
                    width: scaleWidth(105),
                    height: scaleHeight(157),
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: scaleHeight(14)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: scaleWidth(25)),
                  child: Container(
                    width: double.infinity,
                    height: scaleHeight(48),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(scaleHeight(16)),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: scaleWidth(16)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Image.asset(
                          'assets/icons/icon_stars.png',
                          width: scaleWidth(16),
                          height: scaleHeight(16),
                          fit: BoxFit.contain,
                        ),
                        SizedBox(width: scaleWidth(8)),
                        Expanded(
                          child: Text(
                            'Привет, ты можешь спросить меня',
                            style: GoogleFonts.montserrat(
                              fontSize: scaleHeight(15),
                              fontWeight: FontWeight.w500,
                              color: _primaryTextColor,
                              height: 24 / 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: scaleHeight(24)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: scaleWidth(25)),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(scaleHeight(12)),
                    ),
                    padding: EdgeInsets.fromLTRB(
                      scaleWidth(16),
                      scaleHeight(24),
                      scaleWidth(16),
                      scaleHeight(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.asset(
                              'assets/icons/icon_stars.png',
                              width: scaleWidth(16),
                              height: scaleHeight(16),
                              fit: BoxFit.contain,
                            ),
                            SizedBox(width: scaleWidth(8)),
                            Expanded(
                              child: Text(
                                'Может эти слова тебе помогут...',
                                style: GoogleFonts.montserrat(
                                  fontSize: scaleHeight(16),
                                  fontWeight: FontWeight.w500,
                                  color: _primaryTextColor,
                                  height: 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: scaleHeight(24)),
                        Wrap(
                          spacing: scaleWidth(12),
                          runSpacing: scaleHeight(12),
                          children: chips
                              .map(
                                (chip) => Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: scaleWidth(10),
                                    vertical: scaleHeight(10),
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(
                                      scaleHeight(20),
                                    ),
                                    border: Border.all(
                                      color: _accentColor,
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    chip,
                                    style: GoogleFonts.montserrat(
                                      fontSize: scaleHeight(14),
                                      fontWeight: FontWeight.w500,
                                      color: _primaryTextColor,
                                      height: 1,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: scaleHeight(24)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: scaleWidth(25)),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: scaleHeight(54),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(
                              scaleHeight(12),
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x1F18274B),
                                offset: Offset(0, 14),
                                blurRadius: 64,
                                spreadRadius: -4,
                              ),
                              BoxShadow(
                                color: Color(0x1F18274B),
                                offset: Offset(0, 8),
                                blurRadius: 22,
                                spreadRadius: -6,
                              ),
                            ],
                          ),
                          padding: EdgeInsets.only(
                            left: scaleWidth(16),
                            right: scaleWidth(15),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  style: GoogleFonts.montserrat(
                                    fontSize: scaleHeight(16),
                                    fontWeight: FontWeight.w500,
                                    color: _primaryTextColor,
                                    height: 1,
                                  ),
                                  cursorColor: _accentColor,
                                  decoration: InputDecoration(
                                    hintText: 'Введите вопрос...',
                                    hintStyle: GoogleFonts.montserrat(
                                      fontSize: scaleHeight(16),
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF9E9E9E),
                                      height: 1,
                                    ),
                                    border: InputBorder.none,
                                    isDense: true,
                                  ),
                                ),
                              ),
                              Image.asset(
                                'assets/icons/icon_mic.png',
                                width: scaleWidth(24),
                                height: scaleHeight(24),
                                fit: BoxFit.contain,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: scaleWidth(20)),
                      Container(
                        width: scaleWidth(54),
                        height: scaleHeight(54),
                        decoration: BoxDecoration(
                          color: _accentColor,
                          borderRadius: BorderRadius.circular(scaleHeight(50)),
                        ),
                        child: Center(
                          child: Image.asset(
                            'assets/icons/icon_teleg.png',
                            width: scaleWidth(24),
                            height: scaleHeight(24),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: scaleHeight(24)),
                const Spacer(),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: _BottomNavBar(),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double widthFactor = size.width / MainScreen._designWidth;
    final double heightFactor = size.height / MainScreen._designHeight;

    double scaleWidth(double value) => value * widthFactor;
    double scaleHeight(double value) => value * heightFactor;

    const double designNavHeight = 72;
    final double navHeight = scaleHeight(designNavHeight);

    return Container(
      color: Colors.white,
      child: SafeArea(
        top: false,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFF0F0F0), width: 1)),
          ),
          child: SizedBox(
            height: navHeight,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: scaleWidth(24)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  Expanded(
                    child: Align(
                      alignment: Alignment.center,
                      child: _NavItem(
                        iconPath: 'assets/nav_bar/select/ai.png',
                        label: 'AI',
                        isSelected: true,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.center,
                      child: _NavItem(
                        iconPath: 'assets/nav_bar/unselect/bookmark.png',
                        label: 'Шаблоны',
                      ),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.center,
                      child: _NavItem(
                        iconPath: 'assets/nav_bar/unselect/analytics.png',
                        label: 'Аналитика',
                      ),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.center,
                      child: _NavItem(
                        iconPath: 'assets/nav_bar/unselect/person.png',
                        label: 'Профиль',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.iconPath,
    required this.label,
    this.isSelected = false,
  });

  final String iconPath;
  final String label;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double widthFactor = size.width / MainScreen._designWidth;
    final double heightFactor = size.height / MainScreen._designHeight;

    double scaleWidth(double value) => value * widthFactor;
    double scaleHeight(double value) => value * heightFactor;

    final Color textColor = isSelected
        ? MainScreen._accentColor
        : MainScreen._primaryTextColor;

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
            color: textColor,
            height: 1,
          ),
        ),
      ],
    );
  }
}
