import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../settings/style.dart';
import '../settings/colors.dart';
import '../l10n/app_localizations.dart';
import '../services/api_service.dart';

import '../widgets/auth_input_field.dart';
import '../widgets/auth_submit_button.dart';
import 'registration_code_screen.dart';

class RegistrationPlaceholderScreen extends StatefulWidget {
  const RegistrationPlaceholderScreen({super.key});

  @override
  State<RegistrationPlaceholderScreen> createState() =>
      _RegistrationPlaceholderScreenState();
}

class _RegistrationPlaceholderScreenState
    extends State<RegistrationPlaceholderScreen> {
  static const double _designWidth = 428;
  static const double _designHeight = 926;
  static const double _topOffset = 127;
  static const double _leftOffset = 28;
  static const double _titleFieldSpacing = 83;
  static const double _fieldButtonSpacing = 25;
  static const double _fieldHorizontalPadding = 26;
  static const double _componentHeight = 53;
  static const double _fieldBorderRadius = 7;
  static const double _fieldInnerPadding = 18;
  static const double _fieldLabelSpacing = 1;
  static const double _buttonBorderRadius = 9;
  static const double _errorTextOffset = 21;

  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _showError = false;
  String? _errorMessage;
  bool _isLoading = false;
  late final TapGestureRecognizer _loginRecognizer;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFieldStateChange);
    _controller.addListener(_onFieldStateChange);
    _loginRecognizer = TapGestureRecognizer()
      ..onTap = _openLoginScreen;
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_onFieldStateChange)
      ..dispose();
    _controller
      ..removeListener(_onFieldStateChange)
      ..dispose();
    _loginRecognizer.dispose();
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

  bool _isValidEmail(String value) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    return emailRegex.hasMatch(value.trim());
  }

  Future<void> _submitEmail() async {
    final email = _controller.text.trim();
    final isEmailValid = _isValidEmail(email);

    setState(() {
      final l = AppLocalizations.of(context)!;

      if (email.isEmpty) {
        _showError = true;
        _errorMessage = l.authEmailErrorInvalid;
        return;
      }

      if (!isEmailValid) {
        _showError = true;
        _errorMessage = l.authEmailErrorInvalid;
        return;
      }
    });

    if (_showError) return;

    // Устанавливаем состояние загрузки
    setState(() {
      _isLoading = true;
      _showError = false;
      _errorMessage = null;
    });

    // Проверяем существование пользователя через API
    try {
      final result = await ApiService.instance.checkUser(email);
      final hasNetworkError = result['error'] == 'network_error';
      final exists = result['exists'] == true;

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (hasNetworkError) {
        // Ошибка соединения / нет интернета
        setState(() {
          final l = AppLocalizations.of(context)!;
          _showError = true;
          _errorMessage = l.authEmailErrorConnection;
        });
      } else if (exists) {
        // Пользователь уже зарегистрирован
        setState(() {
          final l = AppLocalizations.of(context)!;
          _showError = true;
          _errorMessage = l.authEmailAlreadyRegistered;
        });
      } else {
        // Пользователь не существует - можно регистрировать
        setState(() {
          _showError = false;
          _errorMessage = null;
        });

        FocusScope.of(context).unfocus();
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => RegistrationCodeScreen(email: email),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        final l = AppLocalizations.of(context)!;
        _showError = true;
        _errorMessage = l.authEmailErrorConnection;
      });
    }
  }

  void _openLoginScreen() {
    Navigator.of(context).pop();
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
            _focusNode.hasFocus || _controller.text.isNotEmpty;
        final bool isButtonEnabled = _controller.text.isNotEmpty && !_showError;

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
              child: Padding(
                padding: EdgeInsets.only(
                  top: scaleHeight(_topOffset),
                  bottom: scaleHeight(62),
                ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: scaleWidth(_leftOffset),
                      ),
                      child: Text(
                        l.authRegisterTitle,
                        style: AppTextStyle.bodyTextBold(
                          scaleWidth(40),
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    SizedBox(height: scaleHeight(_titleFieldSpacing)),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: scaleWidth(_fieldHorizontalPadding),
                      ),
                      child: AuthInputField(
                        controller: _controller,
                        focusNode: _focusNode,
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
                        hintText: l.authEmailHint,
                        labelText: l.authEmailHint,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _submitEmail(),
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
                            scaleHeight(10),
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
                        label: l.authButtonContinue,
                        isEnabled: isButtonEnabled,
                        isLoading: _isLoading,
                        onPressed: isButtonEnabled && !_isLoading ? _submitEmail : null,
                        buttonHeight: buttonHeight,
                        borderRadius: buttonBorderRadius,
                        fontSize: scaleHeight(16),
                      ),
                    ),
                    const Spacer(),
                    Center(
                      child: RichText(
                  textAlign: TextAlign.center,
                        text: TextSpan(
                          text: l.authHasAccount,
                          style: AppTextStyle.bodyText(
                            scaleHeight(16),
                            color: theme.colorScheme.onSurface,
                          ),
                          children: [
                            TextSpan(
                              text: l.authLogin,
                              style: AppTextStyle.bodyText(
                                scaleHeight(16),
                                color: AppColors.primaryBlue,
                              ),
                              recognizer: _loginRecognizer,
                            ),
                          ],
                        ),
                      ),
                  ),
                  ],
                ),
              ),
            ),
        ),
        );
      },
    );
  }
}
