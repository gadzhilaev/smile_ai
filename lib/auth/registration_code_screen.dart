import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../settings/style.dart';
import '../settings/colors.dart';
import '../l10n/app_localizations.dart';

import '../widgets/auth_submit_button.dart';
import 'registration_password_screen.dart';

class RegistrationCodeScreen extends StatefulWidget {
  const RegistrationCodeScreen({super.key, required this.email});

  final String email;

  @override
  State<RegistrationCodeScreen> createState() =>
      _RegistrationCodeScreenState();
}

// Кастомный formatter для обработки ввода кода
class _CodeInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Фильтруем только цифры
    final filtered = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    
    // Ограничиваем до 1 символа
    if (filtered.length > 1) {
      return TextEditingValue(
        text: filtered[0],
        selection: TextSelection.collapsed(offset: 1),
      );
    }

    if (filtered != newValue.text) {
      return TextEditingValue(
        text: filtered,
        selection: TextSelection.collapsed(offset: filtered.length),
      );
    }

    return newValue;
  }
}

class _RegistrationCodeScreenState extends State<RegistrationCodeScreen> {
  static const double _designWidth = 428;
  static const double _designHeight = 926;
  static const double _fieldHorizontalPadding = 30;
  static const double _codeFieldSpacing = 10;
  static const double _codeFieldHeight = 56;
  static const double _codeFieldBorderRadius = 7;
  static const double _buttonBorderRadius = 9;
  static const double _componentHeight = 53;
  static const double _fieldButtonSpacing = 20;
  static const double _errorTextOffset = 21;
  static const String _validCode = '1111';

  final List<TextEditingController> _controllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  bool _showError = false;
  String? _errorMessage;
  bool _isLoading = false;
  late final TapGestureRecognizer _loginRecognizer;

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < 4; i++) {
      _controllers[i].addListener(_onFieldStateChange);
      _focusNodes[i].addListener(() => _onFieldStateChange());
    }
    _loginRecognizer = TapGestureRecognizer()
      ..onTap = _openLoginScreen;

    // Устанавливаем фокус на первое поле после построения экрана
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_focusNodes.isNotEmpty && _focusNodes.first.canRequestFocus) {
        _focusNodes.first.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    for (var i = 0; i < 4; i++) {
      _controllers[i]
        ..removeListener(_onFieldStateChange)
        ..dispose();
      _focusNodes[i].dispose();
    }
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

  void _onCodeChanged(int index, String value) {
    _onFieldStateChange();
    
    // Если введена одна цифра и справа есть поле, переходим на следующее
    if (value.length == 1 && index < 3) {
      // Используем addPostFrameCallback для гарантированного перехода после обновления UI
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _focusNodes[index + 1].canRequestFocus) {
          _focusNodes[index + 1].requestFocus();
        }
      });
    }
    // Если поле очищено и слева есть поле, переходим на предыдущее
    else if (value.isEmpty && index > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _focusNodes[index - 1].canRequestFocus) {
          _focusNodes[index - 1].requestFocus();
        }
      });
    }
  }

  String _getCode() {
    return _controllers.map((c) => c.text).join();
  }

  bool _isCodeComplete() {
    return _getCode().length == 4;
  }

  Future<void> _submitCode() async {
    final code = _getCode();

    if (!_isCodeComplete()) {
      return;
    }

    if (code != _validCode) {
      setState(() {
        final l = AppLocalizations.of(context)!;
        _showError = true;
        _errorMessage = l.authCodeErrorWrong;
      });
      return;
    }

    // Устанавливаем состояние загрузки
    setState(() {
      _isLoading = true;
      _showError = false;
      _errorMessage = null;
    });

    // Здесь будет запрос к API для проверки кода
    // Пока симулируем задержку
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    FocusScope.of(context).unfocus();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RegistrationPasswordScreen(email: widget.email),
      ),
    );
  }

  void _openLoginScreen() {
    Navigator.of(context).popUntil((route) => route.isFirst);
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

        final double buttonHeight = scaleHeight(_componentHeight);
        final double buttonBorderRadius = scaleHeight(_buttonBorderRadius);
        final double codeFieldHeight = scaleHeight(_codeFieldHeight);
        final double codeFieldBorderRadius = scaleHeight(_codeFieldBorderRadius);
        final double codeFieldSpacing = scaleWidth(_codeFieldSpacing);
        final double sidePadding = scaleWidth(_fieldHorizontalPadding);
        final double availableWidth =
            size.width - (sidePadding * 2) - (codeFieldSpacing * 3);
        final double codeFieldWidth = availableWidth / 4;

        final bool isButtonEnabled = _isCodeComplete() && !_showError;

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
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: scaleWidth(28),
                    ),
                    child: Text(
                      l.authCodeTitle,
                      style: AppTextStyle.bodyTextBold(
                        scaleWidth(40),
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  SizedBox(height: scaleHeight(10)),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: scaleWidth(28),
                    ),
                    child: Text(
                      l.authCodeMessage,
                      style: AppTextStyle.bodyText(
                        scaleHeight(14),
                        color: const Color(0xFF5B5B5B),
                      ),
                    ),
                  ),
                  SizedBox(height: scaleHeight(39)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: sidePadding),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(4, (index) {
                        final isActive = _focusNodes[index].hasFocus ||
                            _controllers[index].text.isNotEmpty;
                        final bool isActiveState = isActive && !_showError;
                        final Color borderColor = _showError
                            ? AppColors.textError
                            : isActiveState
                                ? AppColors.primaryBlue
                                : (isDark
                                    ? AppColors.white
                                    : AppColors.borderDefault);
                        final Color backgroundColor = _showError
                            ? Colors.transparent
                            : isDark
                                ? AppColors.black
                                : (isActiveState
                                    ? AppColors.inputActiveBg
                                    : AppColors.white);

                        return SizedBox(
                          width: codeFieldWidth,
                          height: codeFieldHeight,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: backgroundColor,
                              borderRadius:
                                  BorderRadius.circular(codeFieldBorderRadius),
                              border: Border.all(color: borderColor, width: 2),
                            ),
                            child: Align(
                              alignment: Alignment.center,
                              child: TextField(
                                controller: _controllers[index],
                                focusNode: _focusNodes[index],
                                textAlign: TextAlign.center,
                                style: AppTextStyle.bodyText(
                                  scaleHeight(18),
                                  color: isDark
                                      ? AppColors.white
                                      : AppColors.textPrimary,
                                ),
                                cursorColor: AppColors.primaryBlue,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  _CodeInputFormatter(),
                                ],
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                onChanged: (value) {
                                  _onCodeChanged(index, value);
                                },
                                onTap: () {
                                  // При клике на поле, если оно уже заполнено, выделяем весь текст
                                  if (_controllers[index].text.isNotEmpty) {
                                    _controllers[index].selection = TextSelection(
                                      baseOffset: 0,
                                      extentOffset: _controllers[index].text.length,
                                    );
                                  }
                                },
                                onSubmitted: (_) {
                                  // При нажатии Enter, если справа есть поле, переходим на него
                                  if (index < 3) {
                                    _focusNodes[index + 1].requestFocus();
                                  }
                                },
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  if (_showError && _errorMessage != null)
                    Padding(
                      padding: EdgeInsets.only(
                        left: sidePadding + scaleWidth(_errorTextOffset),
                        right: sidePadding,
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
                  SizedBox(height: scaleHeight(_fieldButtonSpacing)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: sidePadding),
                    child: AuthSubmitButton(
                      label: l.authButtonContinue,
                      isEnabled: isButtonEnabled,
                      isLoading: _isLoading,
                      onPressed: isButtonEnabled && !_isLoading ? _submitCode : null,
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
                  SizedBox(height: scaleHeight(62)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

