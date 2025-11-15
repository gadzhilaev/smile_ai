import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TemplatesScreen extends StatelessWidget {
  const TemplatesScreen({super.key});

  static const double _designWidth = 428;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double widthFactor = size.width / _designWidth;

    double scaleWidth(double value) => value * widthFactor;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: Center(
          child: Text(
            'Шаблоны',
            style: GoogleFonts.montserrat(
              fontSize: scaleWidth(20),
              fontWeight: FontWeight.w500,
              color: const Color(0xFF201D2F),
              height: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}

