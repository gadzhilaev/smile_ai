import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../settings/style.dart';
import '../settings/colors.dart';
import '../services/profile_service.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/fcm_service.dart';
import '../utils/env_utils.dart';
import '../l10n/app_localizations.dart';
import '../screens/home_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class RegistrationDataScreen extends StatefulWidget {
  const RegistrationDataScreen({
    super.key,
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  @override
  State<RegistrationDataScreen> createState() =>
      _RegistrationDataScreenState();
}

class _RegistrationDataScreenState extends State<RegistrationDataScreen> {
  static const double _designWidth = 428;
  static const double _designHeight = 926;

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _telegramController = TextEditingController();

  final FocusNode _fullNameFocus = FocusNode();
  final FocusNode _usernameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _telegramFocus = FocusNode();

  String? _selectedCountry = 'russia';
  String? _selectedGender = 'male';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Предзаполняем email из параметра
    _emailController.text = widget.email;
    
    // Добавляем слушатели для обновления состояния кнопки
    _fullNameController.addListener(_updateButtonState);
    _usernameController.addListener(_updateButtonState);
    _emailController.addListener(_updateButtonState);
    _phoneController.addListener(_updateButtonState);
  }

  void _updateButtonState() {
    if (mounted) {
      setState(() {});
    }
  }

  bool _isAllFieldsFilled() {
    // Проверяем, что номер телефона полностью введен (10 цифр после +7)
    final phoneText = _phoneController.text.trim();
    final phoneDigits = phoneText.replaceAll(RegExp(r'[^\d]'), '');
    // Убираем первую 7, если есть
    final phoneDigitsWithout7 = phoneDigits.isNotEmpty && phoneDigits[0] == '7'
        ? phoneDigits.substring(1)
        : phoneDigits;
    final isPhoneComplete = phoneDigitsWithout7.length == 10;
    
    return _fullNameController.text.trim().isNotEmpty &&
        _usernameController.text.trim().isNotEmpty &&
        _emailController.text.trim().isNotEmpty &&
        isPhoneComplete &&
        _selectedCountry != null &&
        _selectedGender != null;
  }

  String _getCountryName(String? countryCode, BuildContext context) {
    final l = AppLocalizations.of(context)!;
    switch (countryCode) {
      case 'russia':
        return l.authCountryRussia;
      case 'kazakhstan':
        return l.authCountryKazakhstan;
      case 'belarus':
        return l.authCountryBelarus;
      default:
        return l.authCountryRussia;
    }
  }

  String _getGenderName(String? genderCode, BuildContext context) {
    final l = AppLocalizations.of(context)!;
    switch (genderCode) {
      case 'male':
        return l.authGenderMale;
      case 'female':
        return l.authGenderFemale;
      default:
        return l.authGenderMale;
    }
  }

  Future<void> _saveProfileData() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final fullName = _fullNameController.text.trim();
      final nickname = _usernameController.text.trim();
      final email = _emailController.text.trim();
      final phone = _phoneController.text.trim();
      final country = _getCountryName(_selectedCountry, context);
      final gender = _getGenderName(_selectedGender, context);
      final telegramUsername = _telegramController.text.trim();

      // Отправляем POST запрос на регистрацию
      final result = await ApiService.instance.register(
        email: email,
        password: widget.password,
        fullName: fullName,
        nickname: nickname,
        phone: phone,
        country: country,
        gender: gender,
        telegramUsername: telegramUsername.isNotEmpty ? telegramUsername : null,
      );

      if (!mounted) return;

      // Проверяем результат
      if (result.containsKey('error')) {
        // Ошибка регистрации
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Ошибка регистрации'),
            backgroundColor: AppColors.textError,
          ),
        );
        return;
      }

      // Успешная регистрация
      final token = result['token'] as String?;
      if (token == null || token.isEmpty) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ошибка: токен не получен'),
            backgroundColor: AppColors.textError,
          ),
        );
        return;
      }

      // Получаем user_id из ответа
      final user = result['user'] as Map<String, dynamic>?;
      final userId = user?['id'] as String?;

      // Сохраняем токен в AuthService
      await AuthService.instance.init();
      await AuthService.instance.saveToken(token);

      // Сохраняем токен в .env
      try {
        await EnvUtils.updateTokenInEnv(token);
      } catch (e) {
        debugPrint('RegistrationDataScreen: could not save token to .env: $e');
        // Продолжаем выполнение, так как токен уже сохранен в AuthService
      }

      // Сохраняем user_id в .env
      if (userId != null && userId.isNotEmpty) {
        try {
          await EnvUtils.updateUserIdInEnv(userId);
          debugPrint('RegistrationDataScreen: user_id saved to .env file successfully: ${userId.substring(0, 8)}...');
          
          // Перезагружаем .env чтобы обновить USER_ID
          await dotenv.load(fileName: ".env");
          
          // Инициализируем FCM с userId (это зарегистрирует токен на сервере)
          try {
            await FCMService.instance.initialize(userId);
            debugPrint('RegistrationDataScreen: FCM инициализирован и токен зарегистрирован на сервере');
          } catch (e) {
            debugPrint('RegistrationDataScreen: WARNING - не удалось инициализировать FCM: $e');
          }
        } catch (e) {
          debugPrint('RegistrationDataScreen: WARNING - could not save user_id to .env file: $e');
          // Продолжаем выполнение
        }
      } else {
        debugPrint('RegistrationDataScreen: WARNING - user_id not found in API response');
      }

      // Сохраняем данные пользователя в .env (кроме пароля)
      try {
        await EnvUtils.updateUserDataInEnv(
          email: email,
          fullName: fullName,
          nickname: nickname,
          phone: phone,
          country: country,
          gender: gender,
          telegramUsername: telegramUsername.isNotEmpty ? telegramUsername : null,
        );
      } catch (e) {
        debugPrint('RegistrationDataScreen: could not save user data to .env: $e');
        // Продолжаем выполнение
      }

      // Сохраняем данные в ProfileService
      ProfileService.instance.updateProfile(
        fullName: fullName,
        username: nickname,
        email: email,
        phone: phone,
        country: _selectedCountry,
        gender: _selectedGender,
      );

      if (!mounted) return;

      // Переходим на главный экран
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка регистрации: $e'),
          backgroundColor: AppColors.textError,
        ),
      );
    }
  }

  @override
  void dispose() {
    _fullNameController.removeListener(_updateButtonState);
    _usernameController.removeListener(_updateButtonState);
    _emailController.removeListener(_updateButtonState);
    _phoneController.removeListener(_updateButtonState);
    _fullNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _telegramController.dispose();
    _fullNameFocus.dispose();
    _usernameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _telegramFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double widthFactor = size.width / _designWidth;
    final double heightFactor = size.height / _designHeight;

    double scaleWidth(double value) => value * widthFactor;
    double scaleHeight(double value) => value * heightFactor;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackgroundMain : AppColors.backgroundMain,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          top: true,
          bottom: false,
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Стрелка назад и заголовок
                Padding(
                  padding: EdgeInsets.only(
                    left: scaleWidth(18),
                    top: scaleHeight(18),
                    right: scaleWidth(26),
                  ),
                  child: Row(
                    children: [
                      // Стрелка назад
                      InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        borderRadius: BorderRadius.circular(scaleWidth(16)),
                        child: Padding(
                          padding: EdgeInsets.all(scaleWidth(4)),
                          child: Icon(
                            Icons.arrow_back,
                            size: scaleWidth(28),
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            l.authFillDataTitle,
                            style: AppTextStyle.screenTitle(
                              scaleHeight(20),
                              color: isDark
                                  ? AppColors.white
                                  : theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                      // Невидимый виджет для балансировки
                      SizedBox(width: scaleWidth(28) + scaleWidth(8)),
                    ],
                  ),
                ),
                SizedBox(height: scaleHeight(44)),
                // Текстовые поля
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: scaleWidth(26)),
                  child: Column(
                    children: [
                      _AccountInputField(
                        controller: _fullNameController,
                        focusNode: _fullNameFocus,
                        hintText: l.authFieldFullName,
                        designWidth: _designWidth,
                        designHeight: _designHeight,
                      ),
                      SizedBox(height: scaleHeight(26)),
                      _AccountInputField(
                        controller: _usernameController,
                        focusNode: _usernameFocus,
                        hintText: l.authFieldNickname,
                        designWidth: _designWidth,
                        designHeight: _designHeight,
                        validator: (value) {
                          if (value == null || value.isEmpty) return null;
                          // Разрешаем только английские буквы, цифры и спецсимволы
                          final validPattern = RegExp(r'^[a-zA-Z0-9_\-\.]+$');
                          if (!validPattern.hasMatch(value)) {
                            return l.authNicknameError;
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: scaleHeight(26)),
                      _AccountInputField(
                        controller: _emailController,
                        focusNode: _emailFocus,
                        hintText: l.authFieldEmail,
                        keyboardType: TextInputType.emailAddress,
                        designWidth: _designWidth,
                        designHeight: _designHeight,
                      ),
                      SizedBox(height: scaleHeight(26)),
                      // Поле телефона с флагом
                      _PhoneInputField(
                        controller: _phoneController,
                        focusNode: _phoneFocus,
                        hintText: l.authFieldPhone,
                        designWidth: _designWidth,
                        designHeight: _designHeight,
                      ),
                      SizedBox(height: scaleHeight(26)),
                      // Выпадающий список и поле пола
                      Row(
                        children: [
                          // Выпадающий список
                          _DropdownField(
                            value: _selectedCountry,
                            onChanged: (String? value) {
                              setState(() {
                                _selectedCountry = value;
                              });
                            },
                            hintText: l.authFieldCountry,
                            designWidth: _designWidth,
                            designHeight: _designHeight,
                          ),
                          SizedBox(width: scaleWidth(16)),
                          // Поле пола (такого же размера)
                          _GenderDropdownField(
                            value: _selectedGender,
                            onChanged: (String? value) {
                              setState(() {
                                _selectedGender = value;
                              });
                            },
                            hintText: l.authFieldGender,
                            designWidth: _designWidth,
                            designHeight: _designHeight,
                          ),
                        ],
                      ),
                      SizedBox(height: scaleHeight(26)),
                      // Поле Telegram никнейма
                      _TelegramInputField(
                        controller: _telegramController,
                        focusNode: _telegramFocus,
                        hintText: l.authFieldTelegram,
                        designWidth: _designWidth,
                        designHeight: _designHeight,
                      ),
                      SizedBox(height: scaleHeight(8)),
                      // Подсказка под полем Telegram
                      Padding(
                        padding: EdgeInsets.only(left: scaleWidth(18)),
                        child: Text(
                          l.authTelegramHint,
                          style: AppTextStyle.bodyText(
                            scaleHeight(12),
                          ).copyWith(
                            color: isDark
                                ? AppColors.textSecondary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: scaleHeight(26)),
                // Кнопка Сохранить
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: scaleWidth(26)),
                  child: InkWell(
                    onTap: (_isLoading || !_isAllFieldsFilled()) ? null : _saveProfileData,
                    child: Container(
                      width: scaleWidth(376),
                      height: scaleHeight(53),
                      decoration: BoxDecoration(
                        color: (_isLoading || !_isAllFieldsFilled())
                            ? AppColors.primaryBlue.withValues(alpha: 0.6)
                            : AppColors.primaryBlue,
                        borderRadius: BorderRadius.circular(scaleHeight(9)),
                      ),
                      alignment: Alignment.center,
                      child: _isLoading
                          ? SizedBox(
                              width: scaleHeight(20),
                              height: scaleHeight(20),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Text(
                              l.authSaveButton,
                              style: AppTextStyle.screenTitle(
                                scaleHeight(16),
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),
                SizedBox(height: scaleHeight(40)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Копируем все вспомогательные виджеты из account_screen.dart
class _AccountInputField extends StatefulWidget {
  const _AccountInputField({
    required this.controller,
    required this.focusNode,
    required this.hintText,
    required this.designWidth,
    required this.designHeight,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final double designWidth;
  final double designHeight;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  @override
  State<_AccountInputField> createState() => _AccountInputFieldState();
}

class _AccountInputFieldState extends State<_AccountInputField> {
  bool _isFocused = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChange);
    widget.controller.addListener(_onTextChange);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    widget.controller.removeListener(_onTextChange);
    super.dispose();
  }

  void _onFocusChange() {
    if (mounted) {
      setState(() {
        _isFocused = widget.focusNode.hasFocus;
      });
      _validate();
    }
  }

  void _onTextChange() {
    if (mounted) {
      setState(() {});
      _validate();
    }
  }

  void _validate() {
    if (widget.validator != null) {
      final error = widget.validator!(widget.controller.text);
      if (mounted) {
        setState(() {
          _errorMessage = error;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double widthFactor = size.width / widget.designWidth;
    final double heightFactor = size.height / widget.designHeight;

    double scaleWidth(double value) => value * widthFactor;
    double scaleHeight(double value) => value * heightFactor;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bool hasText = widget.controller.text.isNotEmpty;
    final bool showLabel = _isFocused || hasText;
    final bool hasError = _errorMessage != null && _errorMessage!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
      width: scaleWidth(376),
      height: scaleHeight(52),
      decoration: BoxDecoration(
        color: isDark ? AppColors.black : AppColors.white,
        borderRadius: BorderRadius.circular(scaleHeight(8)),
        border: Border.all(
              color: hasError
                  ? AppColors.accentRed
                  : (isDark ? AppColors.white : AppColors.black),
          width: 1,
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: scaleWidth(18)),
      child: Column(
        mainAxisAlignment: showLabel
            ? MainAxisAlignment.start
            : MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
              if (showLabel) SizedBox(height: scaleHeight(2)),
          if (showLabel)
            Text(
              widget.hintText,
              style: AppTextStyle.fieldLabel(
                scaleHeight(10),
              ).copyWith(
                    color: hasError
                        ? AppColors.accentRed
                        : (isDark ? AppColors.textSecondary : AppColors.textSecondary),
              ),
            ),
              if (showLabel) SizedBox(height: scaleHeight(1)),
          Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
              child: TextField(
                controller: widget.controller,
                focusNode: widget.focusNode,
                keyboardType: widget.keyboardType,
                style: AppTextStyle.fieldText(
                      scaleHeight(13),
                ).copyWith(
                      color: hasError
                          ? AppColors.accentRed
                          : (isDark ? AppColors.white : AppColors.textPrimary),
                ),
                    cursorColor: hasError
                        ? AppColors.accentRed
                        : (isDark ? AppColors.white : AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: showLabel ? null : widget.hintText,
                  hintStyle: AppTextStyle.fieldHint(
                    scaleHeight(10),
                  ).copyWith(
                        color: hasError
                            ? AppColors.accentRed
                            : (isDark
                        ? AppColors.textSecondary
                                : AppColors.textSecondary),
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                textInputAction: TextInputAction.next,
              ),
            ),
          ),
        ],
      ),
        ),
        if (hasError) ...[
          SizedBox(height: scaleHeight(4)),
          Padding(
            padding: EdgeInsets.only(left: scaleWidth(18)),
            child: Text(
              _errorMessage!,
              style: AppTextStyle.bodyText(
                scaleHeight(12),
              ).copyWith(
                color: AppColors.accentRed,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _PhoneInputField extends StatefulWidget {
  const _PhoneInputField({
    required this.controller,
    required this.focusNode,
    required this.hintText,
    required this.designWidth,
    required this.designHeight,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final double designWidth;
  final double designHeight;

  @override
  State<_PhoneInputField> createState() => _PhoneInputFieldState();
}

class _PhoneInputFieldState extends State<_PhoneInputField> {
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChange);
    widget.controller.addListener(_onTextChange);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    widget.controller.removeListener(_onTextChange);
    super.dispose();
  }

  void _onFocusChange() {
    if (mounted) {
      setState(() {
        _isFocused = widget.focusNode.hasFocus;
      });
    }
  }

  void _onTextChange() {
    if (mounted) {
      setState(() {});
    }
  }

  String _formatPhoneNumber(String text) {
    // Убираем все символы кроме цифр
    String digits = text.replaceAll(RegExp(r'[^\d]'), '');
    
    // Если начинается с 7, убираем её
    if (digits.isNotEmpty && digits[0] == '7') {
      digits = digits.substring(1);
    }
    
    // Форматируем: +7 989 470-00-00
    if (digits.isEmpty) return '+7';
    if (digits.length <= 3) return '+7 $digits';
    if (digits.length <= 6) {
      return '+7 ${digits.substring(0, 3)} ${digits.substring(3)}';
    }
    if (digits.length <= 8) {
      return '+7 ${digits.substring(0, 3)} ${digits.substring(3, 6)}-${digits.substring(6)}';
    }
    if (digits.length <= 10) {
      return '+7 ${digits.substring(0, 3)} ${digits.substring(3, 6)}-${digits.substring(6, 8)}-${digits.substring(8)}';
    }
    // Ограничиваем до 10 цифр
    digits = digits.substring(0, 10);
    return '+7 ${digits.substring(0, 3)} ${digits.substring(3, 6)}-${digits.substring(6, 8)}-${digits.substring(8)}';
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double widthFactor = size.width / widget.designWidth;
    final double heightFactor = size.height / widget.designHeight;

    double scaleWidth(double value) => value * widthFactor;
    double scaleHeight(double value) => value * heightFactor;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bool hasText = widget.controller.text.isNotEmpty;
    final bool showLabel = _isFocused || hasText;

    return Container(
      width: scaleWidth(376),
      height: scaleHeight(52),
      decoration: BoxDecoration(
        color: isDark ? AppColors.black : AppColors.white,
        borderRadius: BorderRadius.circular(scaleHeight(8)),
        border: Border.all(
          color: isDark ? AppColors.white : AppColors.black,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          SizedBox(width: scaleWidth(18)),
          // Флаг России
          Container(
            width: scaleWidth(42),
            height: scaleHeight(24),
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.borderLight,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: Image.asset(
                'assets/images/russia.png',
                width: scaleWidth(42),
                height: scaleHeight(24),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: scaleWidth(10)),
          Expanded(
            child: Column(
              mainAxisAlignment: showLabel
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showLabel) SizedBox(height: scaleHeight(2)),
                if (showLabel)
                  Text(
                    widget.hintText,
                    style: AppTextStyle.fieldLabel(
                      scaleHeight(10),
                    ).copyWith(
                      color: isDark
                          ? AppColors.textSecondary
                          : AppColors.textSecondary,
                    ),
                  ),
                if (showLabel) SizedBox(height: scaleHeight(1)),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: TextField(
                      controller: widget.controller,
                      focusNode: widget.focusNode,
                      keyboardType: TextInputType.phone,
                      style: AppTextStyle.fieldText(
                        scaleHeight(14),
                      ).copyWith(
                        color: isDark
                            ? AppColors.white
                            : AppColors.textPrimary,
                      ),
                      cursorColor: isDark
                          ? AppColors.white
                          : AppColors.textPrimary,
                      decoration: InputDecoration(
                        hintText: showLabel ? null : widget.hintText,
                        hintStyle: AppTextStyle.fieldHint(
                          scaleHeight(10),
                        ).copyWith(
                          color: isDark
                              ? AppColors.textSecondary
                              : AppColors.textSecondary,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      textInputAction: TextInputAction.next,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[\d]')),
                      ],
                      onChanged: (value) {
                        // Форматирование номера телефона
                        final formatted = _formatPhoneNumber(value);
                        if (formatted != widget.controller.text) {
                          widget.controller.value = TextEditingValue(
                            text: formatted,
                            selection: TextSelection.collapsed(
                              offset: formatted.length,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: scaleWidth(18)),
        ],
      ),
    );
  }
}

class _DropdownField extends StatefulWidget {
  const _DropdownField({
    required this.value,
    required this.onChanged,
    required this.hintText,
    required this.designWidth,
    required this.designHeight,
  });

  final String? value;
  final ValueChanged<String?> onChanged;
  final String hintText;
  final double designWidth;
  final double designHeight;

  @override
  State<_DropdownField> createState() => _DropdownFieldState();
}

class _DropdownFieldState extends State<_DropdownField> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double widthFactor = size.width / widget.designWidth;
    final double heightFactor = size.height / widget.designHeight;

    double scaleWidth(double value) => value * widthFactor;
    double scaleHeight(double value) => value * heightFactor;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l = AppLocalizations.of(context)!;

    final bool hasValue = widget.value != null;
    final bool showLabel = _isFocused || hasValue;

    return InkWell(
      onTap: () async {
        setState(() {
          _isFocused = true;
        });
        final RenderBox renderBox = context.findRenderObject() as RenderBox;
        final Offset offset = renderBox.localToGlobal(Offset.zero);
        
        final String? selectedValue = await showMenu<String>(
          context: context,
          position: RelativeRect.fromLTRB(
            offset.dx,
            offset.dy + renderBox.size.height,
            offset.dx + renderBox.size.width,
            offset.dy + renderBox.size.height,
          ),
          constraints: BoxConstraints.tightFor(
            width: renderBox.size.width,
          ),
          elevation: isDark ? 0 : 8,
          items: [
            PopupMenuItem(
              value: 'russia',
              child: Text(
                l.authCountryRussia,
                style: AppTextStyle.dropdownMenuItem(
                  scaleHeight(14),
                ).copyWith(
                  color: isDark ? AppColors.white : AppColors.textPrimary,
                ),
              ),
            ),
            PopupMenuItem(
              value: 'kazakhstan',
              child: Text(
                l.authCountryKazakhstan,
                style: AppTextStyle.dropdownMenuItem(
                  scaleHeight(14),
                ).copyWith(
                  color: isDark ? AppColors.white : AppColors.textPrimary,
                ),
              ),
            ),
            PopupMenuItem(
              value: 'belarus',
              child: Text(
                l.authCountryBelarus,
                style: AppTextStyle.dropdownMenuItem(
                  scaleHeight(14),
                ).copyWith(
                  color: isDark ? AppColors.white : AppColors.textPrimary,
                ),
              ),
            ),
          ],
          color: isDark ? AppColors.black : AppColors.white,
        );
        
        if (selectedValue != null) {
          setState(() {
            _isFocused = false;
          });
          widget.onChanged(selectedValue);
        } else {
          setState(() {
            _isFocused = false;
          });
        }
      },
      child: Container(
        width: scaleWidth(180),
        height: scaleHeight(54),
        decoration: BoxDecoration(
          color: isDark ? AppColors.black : AppColors.white,
          borderRadius: BorderRadius.circular(scaleHeight(8)),
          border: Border.all(
            color: isDark ? AppColors.white : AppColors.black,
            width: 1,
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: scaleWidth(18)),
        child: Column(
          mainAxisAlignment: showLabel
              ? MainAxisAlignment.start
              : MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showLabel) SizedBox(height: scaleHeight(2)),
            if (showLabel)
              Text(
                widget.hintText,
                style: AppTextStyle.fieldLabel(
                  scaleHeight(10),
                ).copyWith(
                  color: isDark ? AppColors.white : AppColors.textSecondary,
                ),
              ),
            if (showLabel) SizedBox(height: scaleHeight(1)),
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Отображаем выбранное значение или подсказку
                  Align(
                    alignment: Alignment.centerLeft,
                    child: widget.value != null
                        ? Text(
                            widget.value == 'russia'
                                ? l.authCountryRussia
                                : widget.value == 'kazakhstan'
                                    ? l.authCountryKazakhstan
                                    : l.authCountryBelarus,
                            style: AppTextStyle.fieldText(
                              scaleHeight(14),
                            ).copyWith(
                              color: isDark
                                  ? AppColors.white
                                  : AppColors.textPrimary,
                            ),
                          )
                        : (showLabel
                            ? null
                            : Text(
                                widget.hintText,
                                style: AppTextStyle.fieldHint(
                                  scaleHeight(10),
                                ).copyWith(
                                  color: isDark
                                      ? AppColors.white
                                      : AppColors.textSecondary,
                                ),
                              )),
                  ),
                  // Стрелка по центру справа
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: Icon(
                        Icons.arrow_drop_down,
                        size: scaleHeight(24),
                        color:
                            isDark ? AppColors.white : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GenderDropdownField extends StatefulWidget {
  const _GenderDropdownField({
    required this.value,
    required this.onChanged,
    required this.hintText,
    required this.designWidth,
    required this.designHeight,
  });

  final String? value;
  final ValueChanged<String?> onChanged;
  final String hintText;
  final double designWidth;
  final double designHeight;

  @override
  State<_GenderDropdownField> createState() => _GenderDropdownFieldState();
}

class _GenderDropdownFieldState extends State<_GenderDropdownField> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double widthFactor = size.width / widget.designWidth;
    final double heightFactor = size.height / widget.designHeight;

    double scaleWidth(double value) => value * widthFactor;
    double scaleHeight(double value) => value * heightFactor;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l = AppLocalizations.of(context)!;

    final bool hasValue = widget.value != null;
    final bool showLabel = _isFocused || hasValue;

    return InkWell(
      onTap: () async {
        setState(() {
          _isFocused = true;
        });
        final RenderBox renderBox = context.findRenderObject() as RenderBox;
        final Offset offset = renderBox.localToGlobal(Offset.zero);
        
        final String? selectedValue = await showMenu<String>(
          context: context,
          position: RelativeRect.fromLTRB(
            offset.dx,
            offset.dy + renderBox.size.height,
            offset.dx + renderBox.size.width,
            offset.dy + renderBox.size.height,
          ),
          constraints: BoxConstraints.tightFor(
            width: renderBox.size.width,
          ),
          elevation: isDark ? 0 : 8,
          items: [
            PopupMenuItem(
              value: 'male',
              child: Text(
                l.authGenderMale,
                style: AppTextStyle.dropdownMenuItem(
                  scaleHeight(14),
                ).copyWith(
                  color: isDark ? AppColors.white : AppColors.textPrimary,
                ),
              ),
            ),
            PopupMenuItem(
              value: 'female',
              child: Text(
                l.authGenderFemale,
                style: AppTextStyle.dropdownMenuItem(
                  scaleHeight(14),
                ).copyWith(
                  color: isDark ? AppColors.white : AppColors.textPrimary,
                ),
              ),
            ),
          ],
          color: isDark ? AppColors.black : AppColors.white,
        );
        
        if (selectedValue != null) {
          setState(() {
            _isFocused = false;
          });
          widget.onChanged(selectedValue);
        } else {
          setState(() {
            _isFocused = false;
          });
        }
      },
      child: Container(
        width: scaleWidth(180),
        height: scaleHeight(54),
        decoration: BoxDecoration(
          color: isDark ? AppColors.black : AppColors.white,
          borderRadius: BorderRadius.circular(scaleHeight(8)),
          border: Border.all(
            color: isDark ? AppColors.white : AppColors.black,
            width: 1,
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: scaleWidth(18)),
        child: Column(
          mainAxisAlignment: showLabel
              ? MainAxisAlignment.start
              : MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showLabel) SizedBox(height: scaleHeight(2)),
            if (showLabel)
              Text(
                widget.hintText,
                style: AppTextStyle.fieldLabel(
                  scaleHeight(10),
                ).copyWith(
                  color: isDark ? AppColors.white : AppColors.textSecondary,
                ),
              ),
            if (showLabel) SizedBox(height: scaleHeight(1)),
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Отображаем выбранное значение или подсказку
                  Align(
                    alignment: Alignment.centerLeft,
                    child: widget.value != null
                        ? Text(
                            widget.value == 'male' 
                                ? l.authGenderMale 
                                : l.authGenderFemale,
                            style: AppTextStyle.fieldText(
                              scaleHeight(14),
                            ).copyWith(
                              color: isDark
                                  ? AppColors.white
                                  : AppColors.textPrimary,
                            ),
                          )
                        : (showLabel
                            ? null
                            : Text(
                                widget.hintText,
                                style: AppTextStyle.fieldHint(
                                  scaleHeight(10),
                                ).copyWith(
                                  color: isDark
                                      ? AppColors.white
                                      : AppColors.textSecondary,
                                ),
                              )),
                  ),
                  // Стрелка по центру справа
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: Icon(
                        Icons.arrow_drop_down,
                        size: scaleHeight(24),
                        color:
                            isDark ? AppColors.white : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TelegramInputField extends StatefulWidget {
  const _TelegramInputField({
    required this.controller,
    required this.focusNode,
    required this.hintText,
    required this.designWidth,
    required this.designHeight,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final double designWidth;
  final double designHeight;

  @override
  State<_TelegramInputField> createState() => _TelegramInputFieldState();
}

class _TelegramInputFieldState extends State<_TelegramInputField> {
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChange);
    widget.controller.addListener(_onTextChange);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    widget.controller.removeListener(_onTextChange);
    super.dispose();
  }

  void _onFocusChange() {
    if (mounted) {
      setState(() {
        _isFocused = widget.focusNode.hasFocus;
      });
    }
  }

  void _onTextChange() {
    if (mounted) {
      setState(() {});
    }
  }

  String _formatTelegramUsername(String text) {
    // Убираем все @ из текста
    String cleaned = text.replaceAll('@', '');
    
    // Если текст не пустой, добавляем @ в начало
    if (cleaned.isNotEmpty) {
      return '@$cleaned';
    }
    
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double widthFactor = size.width / widget.designWidth;
    final double heightFactor = size.height / widget.designHeight;

    double scaleWidth(double value) => value * widthFactor;
    double scaleHeight(double value) => value * heightFactor;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bool hasText = widget.controller.text.isNotEmpty;
    final bool showLabel = _isFocused || hasText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: scaleWidth(376),
          height: scaleHeight(52),
          decoration: BoxDecoration(
            color: isDark ? AppColors.black : AppColors.white,
            borderRadius: BorderRadius.circular(scaleHeight(8)),
            border: Border.all(
              color: isDark ? AppColors.white : AppColors.black,
              width: 1,
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: scaleWidth(18)),
          child: Column(
            mainAxisAlignment: showLabel
                ? MainAxisAlignment.start
                : MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showLabel) SizedBox(height: scaleHeight(2)),
              if (showLabel)
                Text(
                  widget.hintText,
                  style: AppTextStyle.fieldLabel(
                    scaleHeight(10),
                  ).copyWith(
                    color: isDark
                        ? AppColors.textSecondary
                        : AppColors.textSecondary,
                  ),
                ),
              if (showLabel) SizedBox(height: scaleHeight(1)),
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TextField(
                    controller: widget.controller,
                    focusNode: widget.focusNode,
                    style: AppTextStyle.fieldText(
                      scaleHeight(13),
                    ).copyWith(
                      color: isDark
                          ? AppColors.white
                          : AppColors.textPrimary,
                    ),
                    cursorColor: isDark
                        ? AppColors.white
                        : AppColors.textPrimary,
                    decoration: InputDecoration(
                      hintText: showLabel ? null : widget.hintText,
                      hintStyle: AppTextStyle.fieldHint(
                        scaleHeight(10),
                      ).copyWith(
                        color: isDark
                            ? AppColors.textSecondary
                            : AppColors.textSecondary,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    textInputAction: TextInputAction.next,
                    onChanged: (value) {
                      // Форматирование Telegram никнейма
                      final formatted = _formatTelegramUsername(value);
                      if (formatted != widget.controller.text) {
                        final newOffset = formatted.length;
                        widget.controller.value = TextEditingValue(
                          text: formatted,
                          selection: TextSelection.collapsed(
                            offset: newOffset,
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
