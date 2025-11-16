import 'package:flutter/material.dart';

import 'ai_screen.dart';
import 'templates_screen.dart';
import 'analytics_screen.dart';
import 'profile_screen.dart';
import '../widgets/bottom_nav_bar.dart';
import '../settings/colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const double _designWidth = 428;
  static const double _designHeight = 926;

  static const Color _primaryTextColor = AppColors.primaryText;
  static const Color _accentColor = AppColors.accentRed;

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
      _aiScreen = null; // Сбрасываем кеш для пересоздания с новыми параметрами
    });
  }

  void _refreshTemplates() {
    setState(() {
      _templatesScreenKey++; // Обновляем ключ для пересоздания TemplatesScreen
    });
  }


  // Ленивая загрузка экранов - создаем только при первом обращении
  Widget? _aiScreen;
  Widget? _templatesScreen;
  Widget? _analyticsScreen;
  Widget? _profileScreen;

  Widget _buildScreen(int index) {
    switch (index) {
      case 0:
        _aiScreen ??= AiScreen(
          key: ValueKey(_aiScreenKey),
          autoGenerateText: _autoGenerateText,
          editText: _editText,
          onTextSaved: _onTextSaved,
        );
        return _aiScreen!;
      case 1:
        _templatesScreen ??= TemplatesScreen(
          key: ValueKey(_templatesScreenKey),
          onApplyTemplate: (text) {
            navigateToAiScreen(autoGenerateText: text);
          },
          onEditTemplate: (text, onSaved) {
            navigateToAiScreen(
              editText: text,
              onTextSaved: (editedText) {
                onSaved(editedText);
                _refreshTemplates();
              },
            );
          },
        );
        return _templatesScreen!;
      case 2:
        _analyticsScreen ??= const AnalyticsScreen();
        return _analyticsScreen!;
      case 3:
        _profileScreen ??= const ProfileScreen();
        return _profileScreen!;
      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildScreen(0),
          _buildScreen(1),
          _buildScreen(2),
          _buildScreen(3),
        ],
      ),
      bottomNavigationBar: MainBottomNavBar(
        designWidth: _designWidth,
        designHeight: _designHeight,
        primaryColor: _primaryTextColor,
        accentColor: _accentColor,
        currentIndex: _currentIndex,
        onTap: (index) {
          // Обновляем AI экран при переключении, если нужно
          if (index == 0 && _aiScreen != null) {
            _aiScreen = null; // Пересоздадим при следующем обращении
          }
          setState(() {
            _currentIndex = index;
            // Сбрасываем параметры при ручном переключении
            if (index != 0) {
              _autoGenerateText = null;
              _editText = null;
              _onTextSaved = null;
              _aiScreenKey++;
              _aiScreen = null; // Сбрасываем кеш для пересоздания
            }
          });
        },
      ),
    );
  }
}
