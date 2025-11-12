import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/bottom_nav_bar.dart';

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
                const Spacer(),
                SizedBox(height: scaleHeight(20)),
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
                SizedBox(height: scaleHeight(20)),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: MainBottomNavBar(
        designWidth: _designWidth,
        designHeight: _designHeight,
        primaryColor: _primaryTextColor,
        accentColor: _accentColor,
      ),
    );
  }
}
