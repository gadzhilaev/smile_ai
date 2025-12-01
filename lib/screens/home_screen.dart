import 'package:flutter/material.dart';

import 'ai_screen.dart';
import 'templates_screen.dart';
import 'analytics_screen.dart';
import 'profile_screen.dart';
import '../widgets/bottom_nav_bar.dart';
import '../settings/colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.conversationId});

  final String? conversationId;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// Вспомогательный класс для передачи conversationId
class HomeScreenWithConversationId extends HomeScreen {
  const HomeScreenWithConversationId({super.key, required super.conversationId});
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
  String? _category;
  int _aiScreenKey = 0;
  int _templatesScreenKey = 0;
  String? _conversationId;
  
  @override
  void initState() {
    super.initState();
    // Если передан conversationId из конструктора, сохраняем его
    if (widget.conversationId != null && widget.conversationId!.isNotEmpty) {
      _conversationId = widget.conversationId;
      // Сразу устанавливаем индекс на AI экран
      _currentIndex = 0;
    }
  }

  void navigateToAiScreen({
    String? autoGenerateText,
    String? editText,
    ValueChanged<String>? onTextSaved,
    String? category,
  }) {
    setState(() {
      _currentIndex = 0;
      // Только если переданы новые параметры, обновляем их и пересоздаем экран
      if (autoGenerateText != null || editText != null || category != null) {
      _autoGenerateText = autoGenerateText;
      _editText = editText;
      _onTextSaved = onTextSaved;
      _category = category;
      _aiScreenKey++; // Изменяем ключ для пересоздания экрана
      _aiScreen = null; // Сбрасываем кеш для пересоздания с новыми параметрами
      }
      // Иначе просто переключаемся на AI экран, сохраняя текущее состояние
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
        // Если передан conversationId и экран уже создан, обновляем его через новый ключ
        // чтобы conversationId был обработан в initState
        if (_conversationId != null && _conversationId!.isNotEmpty && _aiScreen != null) {
          // Пересоздаем экран с новым conversationId, но только один раз
          // чтобы избежать видимого переключения
          _aiScreen = AiScreen(
            key: ValueKey('ai_$_conversationId'),
            autoGenerateText: _autoGenerateText,
            editText: _editText,
            onTextSaved: _onTextSaved,
            category: _category,
            conversationId: _conversationId,
          );
          return _aiScreen!;
        }
        _aiScreen ??= AiScreen(
          key: ValueKey(_aiScreenKey),
          autoGenerateText: _autoGenerateText,
          editText: _editText,
          onTextSaved: _onTextSaved,
          category: _category,
          conversationId: _conversationId,
        );
        return _aiScreen!;
      case 1:
        _templatesScreen ??= TemplatesScreen(
          key: ValueKey(_templatesScreenKey),
          onApplyTemplate: (text, category) {
            navigateToAiScreen(autoGenerateText: text, category: category);
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
          setState(() {
            _currentIndex = index;
            // Сбрасываем параметры только при ручном переключении на другую страницу
            // НО сохраняем состояние AI экрана
            if (index != 0) {
              _autoGenerateText = null;
              _editText = null;
              _onTextSaved = null;
              // НЕ сбрасываем _aiScreen и _aiScreenKey, чтобы сохранить состояние
            }
          });
        },
      ),
    );
  }
}
