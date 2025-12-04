import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../settings/style.dart';
import '../settings/colors.dart';
import '../services/profile_service.dart';
import '../services/api_service.dart';
import '../utils/env_utils.dart';
import '../l10n/app_localizations.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  static const double _designWidth = 428;
  static const double _designHeight = 926;

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  final FocusNode _fullNameFocus = FocusNode();
  final FocusNode _usernameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();

  String? _selectedCountry = 'russia';
  String? _selectedGender = 'male';
  bool _isLoading = false;

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
      // Получаем токен из .env
      await dotenv.load(fileName: ".env");
      await EnvUtils.mergeRuntimeEnvIntoDotenv();
      final token = dotenv.env['AUTH_TOKEN'] ?? '';
      
      if (token.isEmpty) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ошибка: токен не найден'),
            backgroundColor: AppColors.textError,
          ),
        );
        return;
      }

      final fullName = _fullNameController.text.trim();
      final nickname = _usernameController.text.trim();
      final email = _emailController.text.trim();
      final phone = _phoneController.text.trim();
      final country = _getCountryName(_selectedCountry, context);
      final gender = _getGenderName(_selectedGender, context);

      // Отправляем PUT запрос на обновление профиля
      final result = await ApiService.instance.updateProfile(
        token: token,
        email: email,
        fullName: fullName,
        nickname: nickname,
        phone: phone,
        country: country,
        gender: gender,
      );

      if (!mounted) return;

      if (result.containsKey('error')) {
        // Ошибка обновления
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Ошибка обновления профиля'),
            backgroundColor: AppColors.textError,
          ),
        );
        return;
      }

      // Успешное обновление - сохраняем данные в .env
      try {
        await EnvUtils.updateUserDataInEnv(
          email: result['email'] as String? ?? email,
          fullName: result['full_name'] as String? ?? fullName,
          nickname: result['nickname'] as String? ?? nickname,
          phone: result['phone'] as String? ?? phone,
          country: result['country'] as String? ?? country,
          gender: result['gender'] as String? ?? gender,
        );
        debugPrint('AccountScreen: profile data saved to .env successfully');
      } catch (e) {
        debugPrint('AccountScreen: WARNING - could not save profile data to .env: $e');
        // Продолжаем выполнение
      }

      // Обновляем ProfileService
      ProfileService.instance.updateProfile(
        fullName: result['full_name'] as String? ?? fullName,
        username: result['nickname'] as String? ?? nickname,
        email: result['email'] as String? ?? email,
        phone: result['phone'] as String? ?? phone,
        country: _selectedCountry, // Сохраняем код страны
        gender: _selectedGender, // Сохраняем код пола
      );

      setState(() {
        _isLoading = false;
      });

      if (!mounted) return;

      // Возвращаемся назад и обновляем профиль
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка: $e'),
          backgroundColor: AppColors.textError,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    // Загружаем данные из сервиса
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    // Инициализируем ProfileService для загрузки данных из .env
    await ProfileService.instance.init();
    
    final profileService = ProfileService.instance;
    _fullNameController.text = profileService.fullName;
    _usernameController.text = profileService.username;
    _emailController.text = profileService.email;
    _phoneController.text = profileService.phone;
    _selectedCountry = profileService.country;
    _selectedGender = profileService.gender;
    setState(() {}); // Обновляем состояние для выпадающих списков
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _fullNameFocus.dispose();
    _usernameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
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
                            l.accountEditProfileTitle,
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
                    ],
                  ),
                ),
                SizedBox(height: scaleHeight(26)),
                // Кнопка Сохранить
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: scaleWidth(26)),
                  child: InkWell(
                    onTap: _isLoading ? null : () {
                      _saveProfileData();
                    },
                    child: Container(
                      width: scaleWidth(376),
                      height: scaleHeight(53),
                      decoration: BoxDecoration(
                        color: _isLoading 
                            ? AppColors.primaryBlue.withValues(alpha: 0.6)
                            : AppColors.primaryBlue,
                        borderRadius: BorderRadius.circular(scaleHeight(9)),
                      ),
                      alignment: Alignment.center,
                      child: _isLoading
                          ? SizedBox(
                              width: scaleWidth(24),
                              height: scaleHeight(24),
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              l.authSaveButton,
                              style: AppTextStyle.screenTitle(scaleHeight(16),
                                  color: Colors.white),
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

class _AccountInputField extends StatefulWidget {
  const _AccountInputField({
    required this.controller,
    required this.focusNode,
    required this.hintText,
    required this.designWidth,
    required this.designHeight,
    this.keyboardType = TextInputType.text,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final double designWidth;
  final double designHeight;
  final TextInputType keyboardType;

  @override
  State<_AccountInputField> createState() => _AccountInputFieldState();
}

class _AccountInputFieldState extends State<_AccountInputField> {
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
      padding: EdgeInsets.symmetric(horizontal: scaleWidth(18)),
      child: Column(
        mainAxisAlignment: showLabel
            ? MainAxisAlignment.start
            : MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showLabel) SizedBox(height: scaleHeight(8)),
          if (showLabel)
            Text(
              widget.hintText,
              style: AppTextStyle.fieldLabel(
                scaleHeight(10),
              ).copyWith(
                color: isDark ? AppColors.textSecondary : AppColors.textSecondary,
              ),
            ),
          if (showLabel) SizedBox(height: scaleHeight(4)),
          Expanded(
            child: Center(
              child: TextField(
                controller: widget.controller,
                focusNode: widget.focusNode,
                keyboardType: widget.keyboardType,
                style: AppTextStyle.fieldText(
                  scaleHeight(14),
                ).copyWith(
                  color: isDark ? AppColors.white : AppColors.textPrimary,
                ),
                cursorColor:
                    isDark ? AppColors.white : AppColors.textPrimary,
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
              ),
            ),
          ),
        ],
      ),
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
                if (showLabel) SizedBox(height: scaleHeight(8)),
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
                if (showLabel) SizedBox(height: scaleHeight(4)),
                Expanded(
                  child: Center(
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
            if (showLabel) SizedBox(height: scaleHeight(8)),
            if (showLabel)
              Text(
                widget.hintText,
                style: AppTextStyle.fieldLabel(
                  scaleHeight(10),
                ).copyWith(
                  color: isDark ? AppColors.white : AppColors.textSecondary,
                ),
              ),
            if (showLabel) SizedBox(height: scaleHeight(4)),
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
                                ? AppLocalizations.of(context)!.authCountryRussia
                                : widget.value == 'kazakhstan'
                                    ? AppLocalizations.of(context)!.authCountryKazakhstan
                                    : AppLocalizations.of(context)!.authCountryBelarus,
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
            if (showLabel) SizedBox(height: scaleHeight(8)),
            if (showLabel)
              Text(
                widget.hintText,
                style: AppTextStyle.fieldLabel(
                  scaleHeight(10),
                ).copyWith(
                  color: isDark ? AppColors.white : AppColors.textSecondary,
                ),
              ),
            if (showLabel) SizedBox(height: scaleHeight(4)),
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
                                ? AppLocalizations.of(context)!.authGenderMale 
                                : AppLocalizations.of(context)!.authGenderFemale,
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

