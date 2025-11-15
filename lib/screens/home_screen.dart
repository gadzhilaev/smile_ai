import 'package:flutter/material.dart';

import 'ai_screen.dart';
import 'templates_screen.dart';
import 'analytics_screen.dart';
import 'profile_screen.dart';
import '../widgets/bottom_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const double _designWidth = 428;
  static const double _designHeight = 926;

  static const Color _primaryTextColor = Color(0xFF201D2F);
  static const Color _accentColor = Color(0xFFAD2023);

  int _currentIndex = 0;

  final List<Widget> _screens = const [
    AiScreen(),
    TemplatesScreen(),
    AnalyticsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: MainBottomNavBar(
        designWidth: _designWidth,
        designHeight: _designHeight,
        primaryColor: _primaryTextColor,
        accentColor: _accentColor,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

