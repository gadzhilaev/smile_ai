import 'package:flutter/material.dart';
import '../settings/style.dart';
import '../settings/colors.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../services/fcm_service.dart';
import '../utils/env_utils.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../screens/home_screen.dart';
import '../widgets/auth_input_field.dart';
import '../widgets/auth_submit_button.dart';

class RegistrationSuccessScreen extends StatefulWidget {
  const RegistrationSuccessScreen({
    super.key,
    required this.email,
    this.profilePictureId,
  });

  final String email;
  final String? profilePictureId;

  @override
  State<RegistrationSuccessScreen> createState() =>
      _RegistrationSuccessScreenState();
}

class _RegistrationSuccessScreenState extends State<RegistrationSuccessScreen> {
  static const double _designWidth = 428;
  static const double _designHeight = 926;
  static const double _fieldHorizontalPadding = 26;
  static const double _componentHeight = 53;
  static const double _fieldBorderRadius = 7;
  static const double _fieldInnerPadding = 18;
  static const double _fieldLabelSpacing = 1;
  static const double _fieldButtonSpacing = 25;
  static const double _buttonBorderRadius = 9;
  static const double _errorTextOffset = 21;

  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode();
  bool _showError = false;
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_onFieldStateChange);
    _passwordFocusNode.addListener(_onFieldStateChange);
  }

  @override
  void dispose() {
    _passwordController
      ..removeListener(_onFieldStateChange)
      ..dispose();
    _passwordFocusNode
      ..removeListener(_onFieldStateChange)
      ..dispose();
    super.dispose();
  }

  void _onFieldStateChange() {
    if (!mounted) return;
    setState(() {
      if (_showError || _errorMessage != null) {
        _showError = false;
        _errorMessage = null;
      }
    });
  }

  Future<void> _submitPassword() async {
    final password = _passwordController.text.trim();

    if (password.isEmpty) {
      setState(() {
        final l = AppLocalizations.of(context)!;
        _showError = true;
        _errorMessage = l.authPasswordErrorWrong;
      });
      return;
    }

    // Устанавливаем состояние загрузки
    setState(() {
      _isLoading = true;
      _showError = false;
      _errorMessage = null;
    });

    // Выполняем вход через API
    try {
      final result = await ApiService.instance.login(widget.email, password);
      
      if (!mounted) return;

      if (result.containsKey('error')) {
        // Ошибка входа
        setState(() {
          _isLoading = false;
          final l = AppLocalizations.of(context)!;
          _showError = true;
          _errorMessage = l.authPasswordErrorWrong;
        });
        return;
      }

      // Успешный вход
      final token = result['token'] as String?;
      if (token == null || token.isEmpty) {
        setState(() {
          _isLoading = false;
          final l = AppLocalizations.of(context)!;
          _showError = true;
          _errorMessage = l.authPasswordErrorWrong;
        });
        return;
      }

      // Получаем user_id из ответа
      final user = result['user'] as Map<String, dynamic>?;
      final userId = user?['id'] as String?;

      // Сохраняем токен в AuthService
      await AuthService.instance.init();
      await AuthService.instance.saveToken(token);
      debugPrint('LogPass: token saved to AuthService: ${token.substring(0, 8)}...');

      // Сохраняем токен в .env файл
      // На мобильных устройствах это может не работать из-за sandbox,
      // но токен уже сохранен в AuthService, что достаточно для работы приложения
      try {
        await EnvUtils.updateTokenInEnv(token);
        debugPrint('LogPass: token saved to .env file successfully');
      } catch (e) {
        debugPrint('LogPass: WARNING - could not save token to .env file: $e');
        debugPrint('LogPass: token is still saved in AuthService (SharedPreferences)');
        // Продолжаем - токен уже сохранен в AuthService, что достаточно
      }

      // Сохраняем user_id в .env файл
      if (userId != null && userId.isNotEmpty) {
        try {
          await EnvUtils.updateUserIdInEnv(userId);
          debugPrint('LogPass: user_id saved to .env file successfully: ${userId.substring(0, 8)}...');
          
          // Перезагружаем .env чтобы обновить USER_ID
          await dotenv.load(fileName: ".env");
          
          // Инициализируем FCM с userId (это зарегистрирует токен на сервере)
          try {
            await FCMService.instance.initialize(userId);
            debugPrint('LogPass: FCM инициализирован и токен зарегистрирован на сервере');
          } catch (e) {
            debugPrint('LogPass: WARNING - не удалось инициализировать FCM: $e');
          }
        } catch (e) {
          debugPrint('LogPass: WARNING - could not save user_id to .env file: $e');
          // Продолжаем - это не критично
        }
      } else {
        debugPrint('LogPass: WARNING - user_id not found in API response');
      }

      setState(() {
        _isLoading = false;
        _showError = false;
        _errorMessage = null;
      });

      if (!mounted) return;
      
      FocusScope.of(context).unfocus();
      if (!mounted) return;
      
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        final l = AppLocalizations.of(context)!;
        _showError = true;
        _errorMessage = l.authPasswordErrorWrong;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l = AppLocalizations.of(context)!;
    return LayoutBuilder(
      builder: (context, _) {
        final size = MediaQuery.of(context).size;
        final widthFactor = size.width / _designWidth;
        final heightFactor = size.height / _designHeight;

        double scaleWidth(double value) => value * widthFactor;
        double scaleHeight(double value) => value * heightFactor;

        final bool isActive =
            _passwordFocusNode.hasFocus || _passwordController.text.isNotEmpty;
        final bool isButtonEnabled =
            _passwordController.text.isNotEmpty && !_showError;

        final double fieldHeight = scaleHeight(_componentHeight);
        final double fieldBorderRadius = scaleHeight(_fieldBorderRadius);
        final double fieldLabelSpacing = scaleHeight(_fieldLabelSpacing);
        final double fieldInnerPadding = scaleWidth(_fieldInnerPadding);
        final double buttonBorderRadius = scaleHeight(_buttonBorderRadius);
        final double buttonHeight = scaleHeight(_componentHeight);
        final double labelTopPadding = 0;
        final double buttonSpacing = _showError
            ? scaleHeight(14)
            : scaleHeight(_fieldButtonSpacing);

        return Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor:
              isDark ? AppColors.darkBackgroundMain : AppColors.white,
          body: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => FocusScope.of(context).unfocus(),
            child: SafeArea(
              top: true,
              bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    left: scaleWidth(24),
                    top: scaleHeight(24),
                    right: scaleWidth(24),
                  ),
                  child: InkWell(
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
                ),
                SizedBox(height: scaleHeight(98)),
                Center(
                  child: ClipOval(
                    child: widget.profilePictureId != null
                        ? Image.network(
                            '${ApiService.baseUrl}/api/files/${widget.profilePictureId}',
                            width: scaleWidth(130),
                            height: scaleHeight(130),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              // Если ошибка загрузки, показываем дефолтную аватарку
                              return Container(
                                width: scaleWidth(130),
                                height: scaleHeight(130),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.darkBackgroundCard
                                      : AppColors.textSecondary.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.person,
                                  size: scaleWidth(65),
                                  color: isDark
                                      ? AppColors.darkSecondaryText
                                      : AppColors.textSecondary,
                                ),
                              );
                            },
                          )
                        : Container(
                            width: scaleWidth(130),
                            height: scaleHeight(130),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.darkBackgroundCard
                                  : AppColors.textSecondary.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.person,
                              size: scaleWidth(65),
                              color: isDark
                                  ? AppColors.darkSecondaryText
                                  : AppColors.textSecondary,
                            ),
                          ),
                  ),
                ),
                SizedBox(height: scaleHeight(14)),
                Center(
                  child: Text(
                    widget.email,
                    style: AppTextStyle.bodyText(
                      scaleHeight(15),
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                SizedBox(height: scaleHeight(42)),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: scaleWidth(_fieldHorizontalPadding),
                  ),
                  child: AuthInputField(
                    controller: _passwordController,
                    focusNode: _passwordFocusNode,
                    isActive: isActive,
                    showError: _showError,
                    fieldHeight: fieldHeight,
                    borderRadius: fieldBorderRadius,
                    innerPadding: fieldInnerPadding,
                    labelSpacing: fieldLabelSpacing,
                    labelTopPadding: labelTopPadding,
                    hintFontSize: scaleHeight(16),
                    floatingLabelFontSize: scaleHeight(11),
                    textFontSize: scaleHeight(14),
                    hintText: l.authPasswordHint,
                    labelText: l.authPasswordHint,
                    isObscure: true,
                    keyboardType: TextInputType.visiblePassword,
                    textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _submitPassword(),
                  ),
                ),
                if (_showError && _errorMessage != null)
                  Padding(
                    padding: EdgeInsets.only(
                      left: scaleWidth(
                        _fieldHorizontalPadding + _errorTextOffset,
                      ),
                      right: scaleWidth(_fieldHorizontalPadding),
                      top: scaleHeight(5),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: AppTextStyle.bodyText(
                        10,
                        color: AppColors.textError,
                      ),
                    ),
                  ),
                SizedBox(height: buttonSpacing),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: scaleWidth(_fieldHorizontalPadding),
                  ),
                  child: AuthSubmitButton(
                    label: l.authButtonLogin,
                    isEnabled: isButtonEnabled,
                    isLoading: _isLoading,
                    onPressed: isButtonEnabled && !_isLoading ? _submitPassword : null,
                    buttonHeight: buttonHeight,
                    borderRadius: buttonBorderRadius,
                    fontSize: scaleHeight(16),
                  ),
                ),
                const Spacer(),
              ],
              ),
            ),
          ),
        );
      },
    );
  }
}
