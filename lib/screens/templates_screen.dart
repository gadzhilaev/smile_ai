import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TemplatesScreen extends StatelessWidget {
  const TemplatesScreen({super.key});

  static const double _designWidth = 428;
  static const double _designHeight = 926;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double widthFactor = size.width / _designWidth;
    final double heightFactor = size.height / _designHeight;

    double scaleWidth(double value) => value * widthFactor;
    double scaleHeight(double value) => value * heightFactor;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        top: true,
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: scaleHeight(16)),
            Center(
              child: Text(
                'Шаблоны',
                style: GoogleFonts.montserrat(
                  fontSize: scaleHeight(20),
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF201D2F),
                  height: 1,
                ),
              ),
            ),
            SizedBox(height: scaleHeight(34)),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: scaleWidth(24)),
                  child: Container(
                    width: double.infinity,
                    height: scaleHeight(251),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(scaleHeight(12)),
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
                    padding: EdgeInsets.symmetric(
                      horizontal: scaleWidth(14),
                      vertical: scaleHeight(11),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: scaleWidth(42),
                              height: scaleHeight(42),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD9D9D9),
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: scaleWidth(10)),
                            Container(
                              width: scaleWidth(89),
                              height: scaleHeight(21),
                              decoration: BoxDecoration(
                                color: const Color(0x80D300E6),
                                borderRadius:
                                    BorderRadius.circular(scaleHeight(64)),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Маркетинг',
                                style: GoogleFonts.montserrat(
                                  fontSize: scaleHeight(12),
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                  height: 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: scaleHeight(7.5)),
                        Text(
                          'Оптимизируйте время публикации в социальных сетях для максимального охвата',
                          style: GoogleFonts.montserrat(
                            fontSize: scaleHeight(16),
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                            height: 18 / 16,
                          ),
                        ),
                        SizedBox(height: scaleHeight(12.5)),
                        Expanded(
                          child: Text(
                            'Наши данные показывают, что ваша аудитория наиболее активна с 18:00 до 21:00 по будням.',
                            style: GoogleFonts.montserrat(
                              fontSize: scaleHeight(12),
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF98A7BD),
                              height: 18 / 12,
                            ),
                          ),
                        ),
                        SizedBox(height: scaleHeight(12.5)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () {},
                              borderRadius:
                                  BorderRadius.circular(scaleHeight(16)),
                              child: Container(
                                width: scaleWidth(187),
                                height: scaleHeight(41),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      Color(0xFFCBE5F8),
                                      Color(0xFFD6D7F8),
                                    ],
                                    stops: [0.0, 0.7816],
                                  ),
                                  borderRadius:
                                      BorderRadius.circular(scaleHeight(16)),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Применить шаблон',
                                  style: GoogleFonts.montserrat(
                                    fontSize: scaleHeight(14),
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                    height: 1,
                                  ),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {},
                              borderRadius:
                                  BorderRadius.circular(scaleHeight(16)),
                              child: Container(
                                width: scaleWidth(152),
                                height: scaleHeight(41),
                                decoration: BoxDecoration(
                                  color: const Color(0x801E293B),
                                  borderRadius:
                                      BorderRadius.circular(scaleHeight(16)),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Редактировать',
                                  style: GoogleFonts.montserrat(
                                    fontSize: scaleHeight(14),
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                    height: 1,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
