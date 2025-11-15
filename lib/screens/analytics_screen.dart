import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

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
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: scaleWidth(33)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: scaleHeight(37)),
                Text(
                  'Топ направлений недели',
                  style: GoogleFonts.montserrat(
                    fontSize: scaleHeight(20),
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF201D2F),
                    height: 1,
                  ),
                ),
                SizedBox(height: scaleHeight(16)),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Тренд №1',
                      style: GoogleFonts.montserrat(
                        fontSize: scaleHeight(18),
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF178751),
                        height: 1,
                      ),
                    ),
                    SizedBox(width: scaleWidth(11)),
                    Expanded(
                      child: Text(
                        'Онлайн-образование',
                        style: GoogleFonts.montserrat(
                          fontSize: scaleHeight(18),
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          height: 1,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: scaleHeight(16)),
                Text(
                  '+190%',
                  style: GoogleFonts.montserrat(
                    fontSize: scaleHeight(64),
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF178751),
                    height: 1,
                  ),
                ),
                SizedBox(height: scaleHeight(3)),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        'на столько  увеличилась вовлеченность\nпо сравнению с прошлой неделей',
                        style: GoogleFonts.montserrat(
                          fontSize: scaleHeight(10),
                          fontWeight: FontWeight.w300,
                          color: Colors.black,
                          height: 1,
                        ),
                      ),
                    ),
                    SizedBox(width: scaleWidth(8)),
                    Text(
                      '7 дн',
                      style: GoogleFonts.montserrat(
                        fontSize: scaleHeight(12),
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF9E9E9E),
                        height: 1,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: scaleHeight(19)),
                Container(
                  width: double.infinity,
                  constraints: BoxConstraints(
                    maxWidth: scaleWidth(361),
                    minHeight: scaleHeight(239),
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFCBE5F8),
                        Color(0xFFD6D7F8),
                      ],
                      stops: [0.0, 0.7816],
                    ),
                    borderRadius: BorderRadius.circular(scaleHeight(15)),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: scaleWidth(19),
                    vertical: scaleHeight(23),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            'assets/icons/icon_brain.png',
                            width: scaleWidth(24),
                            height: scaleHeight(24),
                            fit: BoxFit.contain,
                          ),
                          SizedBox(width: scaleWidth(8)),
                          Text(
                            'Почему?',
                            style: GoogleFonts.montserrat(
                              fontSize: scaleHeight(18),
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                              height: 1,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: scaleHeight(19)),
                      Text(
                        'Тренд "Онлайн-образование" можно использовать, чтобы укрепить бренд как источник пользы.  Добавьте обучающие Reels или короткие карусели с экспертными инсайтами, а также соберите рассылку с полезными материалами — вовлечённость возрастёт на 20–30%.',
                        style: GoogleFonts.montserrat(
                          fontSize: scaleHeight(15),
                          fontWeight: FontWeight.w300,
                          color: Colors.black,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: scaleHeight(38)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TrendContainer(
                      title: 'Растущие',
                      items: const [
                        'Сфера красоты',
                        'Доставка продуктов',
                        'Маркетплейсы',
                      ],
                      itemColor: const Color(0xFF178751),
                      iconPath: 'assets/icons/icon_tr_up.png',
                      designWidth: _designWidth,
                      designHeight: _designHeight,
                    ),
                    SizedBox(width: scaleWidth(14)),
                    _TrendContainer(
                      title: 'Падающие',
                      items: const [
                        'Автосервис',
                        'Продажа цветов',
                        'Кофейни',
                      ],
                      itemColor: const Color(0xFF76090B),
                      iconPath: 'assets/icons/icon_tr_down.png',
                      designWidth: _designWidth,
                      designHeight: _designHeight,
                    ),
                  ],
                ),
                SizedBox(height: scaleHeight(20)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TrendContainer extends StatelessWidget {
  const _TrendContainer({
    required this.title,
    required this.items,
    required this.itemColor,
    required this.iconPath,
    required this.designWidth,
    required this.designHeight,
  });

  final String title;
  final List<String> items;
  final Color itemColor;
  final String iconPath;
  final double designWidth;
  final double designHeight;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double widthFactor = size.width / designWidth;
    final double heightFactor = size.height / designHeight;

    double scaleWidth(double value) => value * widthFactor;
    double scaleHeight(double value) => value * heightFactor;

    return Container(
      width: scaleWidth(171),
      height: scaleHeight(236),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(scaleHeight(15)),
      ),
      padding: EdgeInsets.only(
        left: scaleWidth(15),
        top: scaleHeight(18),
        right: scaleWidth(9),
        bottom: scaleHeight(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.montserrat(
              fontSize: scaleHeight(16),
              fontWeight: FontWeight.w600,
              color: Colors.black,
              height: 1,
            ),
          ),
          SizedBox(height: scaleHeight(30)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < items.length; i++) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          items[i],
                          style: GoogleFonts.montserrat(
                            fontSize: scaleHeight(14),
                            fontWeight: FontWeight.w500,
                            color: itemColor,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: scaleWidth(9)),
                      Image.asset(
                        iconPath,
                        width: scaleWidth(20),
                        height: scaleHeight(20),
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                  if (i < items.length - 1) SizedBox(height: scaleHeight(28)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
