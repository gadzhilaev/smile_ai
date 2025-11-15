import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/custom_refresh_indicator.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const double _designWidth = 428;
  static const double _designHeight = 926;
  final ScrollController _scrollController = ScrollController();

  Future<void> _refreshProfile() async {
    // Здесь будет логика обновления данных профиля
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double widthFactor = size.width / _designWidth;

    double scaleWidth(double value) => value * widthFactor;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        top: true,
        bottom: false,
        child: CustomRefreshIndicator(
          onRefresh: _refreshProfile,
          designWidth: _designWidth,
          designHeight: _designHeight,
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.8,
              child: Center(
                child: Text(
                  'Профиль',
                  style: GoogleFonts.montserrat(
                    fontSize: scaleWidth(20),
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF201D2F),
                    height: 1.2,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

