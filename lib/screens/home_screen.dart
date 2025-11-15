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
  String? _autoGenerateText;
  String? _editText;
  ValueChanged<String>? _onTextSaved;
  int _aiScreenKey = 0;
  int _templatesScreenKey = 0;

  void navigateToAiScreen({
    String? autoGenerateText,
    String? editText,
    ValueChanged<String>? onTextSaved,
  }) {
    setState(() {
      _currentIndex = 0;
      _autoGenerateText = autoGenerateText;
      _editText = editText;
      _onTextSaved = onTextSaved;
      _aiScreenKey++; // Изменяем ключ для пересоздания экрана
    });
  }

  void _refreshTemplates() {
    setState(() {
      _templatesScreenKey++; // Обновляем ключ для пересоздания TemplatesScreen
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          AiScreen(
            key: ValueKey(_aiScreenKey),
            autoGenerateText: _autoGenerateText,
            editText: _editText,
            onTextSaved: _onTextSaved,
          ),
          TemplatesScreen(
            key: ValueKey(_templatesScreenKey),
            onApplyTemplate: (text) {
              navigateToAiScreen(autoGenerateText: text);
            },
            onEditTemplate: (text, onSaved) {
              navigateToAiScreen(
                editText: text,
                onTextSaved: (editedText) {
                  onSaved(editedText);
                  // Обновляем список шаблонов после сохранения
                  _refreshTemplates();
                },
              );
            },
          ),
          const AnalyticsScreen(),
          const ProfileScreen(),
        ],
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
            // Сбрасываем параметры при ручном переключении
            if (index != 0) {
              _autoGenerateText = null;
              _editText = null;
              _onTextSaved = null;
              _aiScreenKey++;
            }
          });
        },
      ),
    );
  }
}
