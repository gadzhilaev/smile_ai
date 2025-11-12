import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        textTheme: GoogleFonts.montserratTextTheme(),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const double _designWidth = 428;
  static const double _designHeight = 926;
  static const Duration _splashDuration = Duration(seconds: 2);

  @override
  void initState() {
    super.initState();
    _navigateToEmail();
  }

  void _navigateToEmail() {
    Future.delayed(_splashDuration, () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const EmailScreen()),
      );
    });
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

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Stack(
              children: [
                Center(
                  child: Image.asset(
                    'assets/images/bot.png',
                    width: scaleWidth(309),
                    height: scaleHeight(464),
                    fit: BoxFit.contain,
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: scaleHeight(35),
                  child: Text(
                    'Smile AI',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      fontSize: scaleWidth(40),
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      height: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

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
          builder: (_) => const RegistrationSuccessPlaceholderScreen(),
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
                    child: _EmailInputField(
                      controller: _controller,
                      focusNode: _focusNode,
                      isActive: isActive,
                      fieldHeight: fieldHeight,
                      borderRadius: fieldBorderRadius,
                      innerPadding: fieldInnerPadding,
                      labelSpacing: fieldLabelSpacing,
                      labelTopPadding: labelTopPadding,
                      hintFontSize: scaleHeight(16),
                      floatingLabelFontSize: scaleHeight(11),
                      textFontSize: scaleHeight(15),
                      showError: _showError,
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
                    child: _EmailSubmitButton(
                      isEnabled: isButtonEnabled,
                      onPressed: _submitEmail,
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

class _EmailInputField extends StatelessWidget {
  const _EmailInputField({
    required this.controller,
    required this.focusNode,
    required this.isActive,
    required this.fieldHeight,
    required this.borderRadius,
    required this.innerPadding,
    required this.labelSpacing,
    required this.labelTopPadding,
    required this.hintFontSize,
    required this.floatingLabelFontSize,
    required this.textFontSize,
    required this.showError,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isActive;
  final double fieldHeight;
  final double borderRadius;
  final double innerPadding;
  final double labelSpacing;
  final double labelTopPadding;
  final double hintFontSize;
  final double floatingLabelFontSize;
  final double textFontSize;
  final bool showError;

  @override
  Widget build(BuildContext context) {
    final bool isActiveState = isActive && !showError;
    final Color borderColor = showError
        ? const Color(0xFFDF1525)
        : isActiveState
        ? const Color(0xFF1573FE)
        : const Color(0xFFE4E4E4);
    final Color backgroundColor = showError
        ? const Color(0xFFFFECEF)
        : isActiveState
        ? const Color(0xFFF3F8FF)
        : Colors.white;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: fieldHeight,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor, width: 2),
      ),
      padding: EdgeInsets.symmetric(horizontal: innerPadding),
      child: Column(
        mainAxisAlignment: isActive
            ? MainAxisAlignment.start
            : MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isActive) SizedBox(height: labelTopPadding),
          if (isActive)
            Text(
              'Email',
              style: GoogleFonts.montserrat(
                fontSize: floatingLabelFontSize,
                fontWeight: FontWeight.w400,
                color: const Color(0xFFA3A3A3),
                height: 1,
              ),
            ),
          if (isActive) SizedBox(height: labelSpacing),
          Expanded(
            child: Center(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                style: GoogleFonts.montserrat(
                  fontSize: textFontSize,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                  height: 1,
                ),
                cursorColor: const Color(0xFF1573FE),
                decoration: InputDecoration(
                  hintText: isActive ? null : 'Email',
                  hintStyle: GoogleFonts.montserrat(
                    fontSize: hintFontSize,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFFA3A3A3),
                    height: 1,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmailSubmitButton extends StatelessWidget {
  const _EmailSubmitButton({
    required this.isEnabled,
    required this.onPressed,
    required this.buttonHeight,
    required this.borderRadius,
    required this.fontSize,
  });

  final bool isEnabled;
  final VoidCallback onPressed;
  final double buttonHeight;
  final double borderRadius;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = isEnabled
        ? const Color(0xFF1573FE)
        : const Color(0xFFD9D9D9);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: buttonHeight,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(borderRadius),
        onTap: isEnabled ? onPressed : null,
        child: Center(
          child: Text(
            'ВОЙТИ',
            style: GoogleFonts.montserrat(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: isEnabled
                  ? const Color(0xFFFFFFFF)
                  : const Color(0xFF757575),
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}

class RegistrationPlaceholderScreen extends StatelessWidget {
  const RegistrationPlaceholderScreen({super.key});

  static const double _designWidth = 428;
  static const double _designHeight = 926;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final widthFactor = size.width / _designWidth;
    final heightFactor = size.height / _designHeight;

    double scaleWidth(double value) => value * widthFactor;
    double scaleHeight(double value) => value * heightFactor;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: scaleWidth(24),
            top: scaleHeight(24),
            right: scaleWidth(24),
            bottom: scaleHeight(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
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
              SizedBox(height: scaleHeight(48)),
              Expanded(
                child: Center(
                  child: Text(
                    'Здесь будет экран регистрации',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      fontSize: scaleWidth(20),
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                      height: 1.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RegistrationSuccessPlaceholderScreen extends StatelessWidget {
  const RegistrationSuccessPlaceholderScreen({super.key});

  static const double _designWidth = 428;
  static const double _designHeight = 926;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final widthFactor = size.width / _designWidth;
    final heightFactor = size.height / _designHeight;

    double scaleWidth(double value) => value * widthFactor;
    double scaleHeight(double value) => value * heightFactor;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: scaleWidth(24),
            top: scaleHeight(24),
            right: scaleWidth(24),
            bottom: scaleHeight(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
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
              SizedBox(height: scaleHeight(48)),
              Expanded(
                child: Center(
                  child: Text(
                    'Почта подтверждена.\nПродолжение следует.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      fontSize: scaleWidth(20),
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                      height: 1.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
