import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MainPlaceholderScreen extends StatelessWidget {
  const MainPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Text(
            'Главный экран',
            style: GoogleFonts.montserrat(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
