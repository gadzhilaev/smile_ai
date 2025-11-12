import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'register.dart';
import 'log_pass.dart';
import '../widgets/auth_input_field.dart';
import '../widgets/auth_submit_button.dart';

class EmailScreen extends StatefulWidget {
  const EmailScreen({super.key});

  @override
  State<EmailScreen> createState() => _EmailScreenState();
}

class _EmailScreenState extends State<EmailScreen> {
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
  static const double _fieldLabelSpacing = 2;
  static const double _buttonBorderRadius = 9;
  static const double _errorTextOffset = 21;

  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _showError = false;
  String? _errorMessage;
  late final TapGestureRecognizer _registerRecognizer;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFieldStateChange);
    _controller.addListener(_onFieldStateChange);
    _registerRecognizer = TapGestureRecognizer()
      ..onTap = _openRegistrationPlaceholder;
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_onFieldStateChange)
      ..dispose();
    _controller
      ..removeListener(_onFieldStateChange)
      ..dispose();
    _registerRecognizer.dispose();
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

  void _submitEmail() {
    final email = _controller.text.trim();
    final isEmailValid = _isValidEmail(email);
    final isRegistered = email.toLowerCase() == 'test@test.ru';

    setState(() {
      if (email.isEmpty) {
        _showError = true;
        _errorMessage = 'Введите корректную почту';
        return;
      }

      if (!isEmailValid) {
        _showError = true;
        _errorMessage = 'Введите корректную почту';
        return;
      }

      if (!isRegistered) {
        _showError = true;
        _errorMessage = 'Эта почта не зарегистрирована';
        return;
      }

      _showError = false;
      _errorMessage = null;

      FocusScope.of(context).unfocus();
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => RegistrationSuccessScreen(email: email),
        ),
      );
    });
  }

  void _openRegistrationPlaceholder() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const RegistrationPlaceholderScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
        final double labelTopPadding = fieldHeight * 0.12;
        final double buttonSpacing = _showError
            ? scaleHeight(14)
            : scaleHeight(_fieldButtonSpacing);

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
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
                      'Введите почту',
                      style: GoogleFonts.montserrat(
                        fontSize: scaleWidth(40),
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                        height: 1,
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
                      textFontSize: scaleHeight(15),
                      hintText: 'Email',
                      labelText: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
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
                        style: GoogleFonts.montserrat(
                          fontSize: scaleHeight(10),
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFFDF1525),
                          height: 1,
                        ),
                      ),
                    ),
                  SizedBox(height: buttonSpacing),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: scaleWidth(_fieldHorizontalPadding),
                    ),
                    child: AuthSubmitButton(
                      label: 'ВОЙТИ',
                      isEnabled: isButtonEnabled,
                      onPressed: isButtonEnabled ? _submitEmail : null,
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
                        text: 'Нет аккаунта? ',
                        style: GoogleFonts.montserrat(
                          fontSize: scaleHeight(16),
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                          height: 1,
                        ),
                        children: [
                          TextSpan(
                            text: 'Зарегистрируйтесь',
                            style: GoogleFonts.montserrat(
                              fontSize: scaleHeight(16),
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF1774FE),
                              height: 1,
                            ),
                            recognizer: _registerRecognizer,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
