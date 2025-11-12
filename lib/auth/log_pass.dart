import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../screens/main_screen.dart';
import '../widgets/auth_input_field.dart';
import '../widgets/auth_submit_button.dart';

class RegistrationSuccessScreen extends StatefulWidget {
  const RegistrationSuccessScreen({super.key, required this.email});

  final String email;

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
  static const double _fieldLabelSpacing = 2;
  static const double _fieldButtonSpacing = 25;
  static const double _buttonBorderRadius = 9;
  static const double _errorTextOffset = 21;
  static const String _validPassword = '12345678';

  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode();
  bool _showError = false;
  String? _errorMessage;

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

  void _submitPassword() {
    final password = _passwordController.text.trim();

    if (password != _validPassword) {
      setState(() {
        _showError = true;
        _errorMessage = 'Неверный пароль';
      });
      return;
    }

    setState(() {
      _showError = false;
      _errorMessage = null;
    });

    FocusScope.of(context).unfocus();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const MainScreen()),
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
            _passwordFocusNode.hasFocus || _passwordController.text.isNotEmpty;
        final bool isButtonEnabled =
            _passwordController.text.isNotEmpty && !_showError;

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
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: scaleHeight(98)),
                Center(
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/avatar.png',
                      width: scaleWidth(130),
                      height: scaleHeight(130),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: scaleHeight(14)),
                Center(
                  child: Text(
                    widget.email,
                    style: GoogleFonts.montserrat(
                      fontSize: scaleHeight(15),
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                      height: 1,
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
                    textFontSize: scaleHeight(15),
                    hintText: 'Пароль',
                    labelText: 'Пароль',
                    isObscure: true,
                    keyboardType: TextInputType.visiblePassword,
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
                    onPressed: isButtonEnabled ? _submitPassword : null,
                    buttonHeight: buttonHeight,
                    borderRadius: buttonBorderRadius,
                    fontSize: scaleHeight(16),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        );
      },
    );
  }
}
