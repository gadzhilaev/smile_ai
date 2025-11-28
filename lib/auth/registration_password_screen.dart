import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../settings/style.dart';
import '../settings/colors.dart';
import '../l10n/app_localizations.dart';

import '../widgets/auth_input_field.dart';
import '../widgets/auth_submit_button.dart';
import 'registration_data_screen.dart';

class RegistrationPasswordScreen extends StatefulWidget {
  const RegistrationPasswordScreen({super.key, required this.email});

  final String email;

  @override
  State<RegistrationPasswordScreen> createState() =>
      _RegistrationPasswordScreenState();
}

class _RegistrationPasswordScreenState
    extends State<RegistrationPasswordScreen> {
  static const double _designWidth = 428;
  static const double _designHeight = 926;
  static const double _topOffset = 127;
  static const double _leftOffset = 28;
  static const double _titleFieldSpacing = 49;
  static const double _fieldSpacing = 26;
  static const double _fieldButtonSpacing = 25;
  static const double _fieldHorizontalPadding = 26;
  static const double _componentHeight = 53;
  static const double _fieldBorderRadius = 7;
  static const double _fieldInnerPadding = 18;
  static const double _fieldLabelSpacing = 1;
  static const double _buttonBorderRadius = 9;
  static const double _errorTextOffset = 21;

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();
  bool _showError = false;
  String? _errorMessage;
  late final TapGestureRecognizer _loginRecognizer;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_onFieldStateChange);
    _confirmPasswordController.addListener(_onFieldStateChange);
    _passwordFocusNode.addListener(_onFieldStateChange);
    _confirmPasswordFocusNode.addListener(_onFieldStateChange);
    _loginRecognizer = TapGestureRecognizer()
      ..onTap = _openLoginScreen;
  }

  @override
  void dispose() {
    _passwordController
      ..removeListener(_onFieldStateChange)
      ..dispose();
    _confirmPasswordController
      ..removeListener(_onFieldStateChange)
      ..dispose();
    _passwordFocusNode
      ..removeListener(_onFieldStateChange)
      ..dispose();
    _confirmPasswordFocusNode
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

  void _submitPassword() {
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    setState(() {
      final l = AppLocalizations.of(context)!;

      if (password.isEmpty || confirmPassword.isEmpty) {
        _showError = true;
        _errorMessage = l.authPasswordErrorTooShort;
        return;
      }

      if (password.length < 8) {
        _showError = true;
        _errorMessage = l.authPasswordErrorTooShort;
        return;
      }

      if (password != confirmPassword) {
        _showError = true;
        _errorMessage = l.authPasswordErrorMismatch;
        return;
      }

      _showError = false;
      _errorMessage = null;
    });

    if (!_showError) {
      FocusScope.of(context).unfocus();
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => RegistrationDataScreen(
            email: widget.email,
            password: password,
          ),
        ),
      );
    }
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

        final bool isPasswordActive =
            _passwordFocusNode.hasFocus || _passwordController.text.isNotEmpty;
        final bool isConfirmPasswordActive = _confirmPasswordFocusNode.hasFocus ||
            _confirmPasswordController.text.isNotEmpty;
        final bool isButtonEnabled = _passwordController.text.isNotEmpty &&
            _confirmPasswordController.text.isNotEmpty &&
            !_showError;

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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l.authPasswordCreateTitle,
                            style: AppTextStyle.bodyTextBold(
                              scaleWidth(40),
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            l.authPasswordCreateSubtitle,
                            style: AppTextStyle.bodyTextBold(
                              scaleWidth(40),
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: scaleHeight(_titleFieldSpacing)),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: scaleWidth(_fieldHorizontalPadding),
                      ),
                      child: AuthInputField(
                        controller: _passwordController,
                        focusNode: _passwordFocusNode,
                        isActive: isPasswordActive,
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
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) {
                          _confirmPasswordFocusNode.requestFocus();
                        },
                      ),
                    ),
                    SizedBox(height: scaleHeight(_fieldSpacing)),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: scaleWidth(_fieldHorizontalPadding),
                      ),
                      child: AuthInputField(
                        controller: _confirmPasswordController,
                        focusNode: _confirmPasswordFocusNode,
                        isActive: isConfirmPasswordActive,
                        showError: _showError,
                        fieldHeight: fieldHeight,
                        borderRadius: fieldBorderRadius,
                        innerPadding: fieldInnerPadding,
                        labelSpacing: fieldLabelSpacing,
                        labelTopPadding: labelTopPadding,
                        hintFontSize: scaleHeight(16),
                        floatingLabelFontSize: scaleHeight(11),
                        textFontSize: scaleHeight(14),
                        hintText: l.authPasswordConfirm,
                        labelText: l.authPasswordConfirm,
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
                        onPressed: isButtonEnabled ? _submitPassword : null,
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

