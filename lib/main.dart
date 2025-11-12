import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'auth/login.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        textTheme: GoogleFonts.montserratTextTheme(),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const double _designWidth = 428;
  static const double _designHeight = 926;
  static const Duration _splashDuration = Duration(seconds: 2);

  @override
  void initState() {
    super.initState();
    _navigateToEmail();
  }

  void _navigateToEmail() {
    Future.delayed(_splashDuration, () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const EmailScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, _) {
        final size = MediaQuery.of(context).size;
        final widthFactor = size.width / _designWidth;
        final heightFactor = size.height / _designHeight;

        double scaleWidth(double value) => value * widthFactor;
        double scaleHeight(double value) => value * heightFactor;

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Stack(
              children: [
                Center(
                  child: Image.asset(
                    'assets/images/bot.png',
                    width: scaleWidth(309),
                    height: scaleHeight(464),
                    fit: BoxFit.contain,
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: scaleHeight(35),
                  child: Text(
                    'Smile AI',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      fontSize: scaleWidth(40),
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      height: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
