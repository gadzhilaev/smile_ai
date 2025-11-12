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

  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFieldStateChange);
    _controller.addListener(_onFieldStateChange);
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_onFieldStateChange)
      ..dispose();
    _controller
      ..removeListener(_onFieldStateChange)
      ..dispose();
    super.dispose();
  }

  void _onFieldStateChange() {
    if (mounted) {
      setState(() {});
    }
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
        final bool isButtonEnabled = _controller.text.isNotEmpty;

        final double fieldHeight = scaleHeight(_componentHeight);
        final double fieldBorderRadius = scaleHeight(_fieldBorderRadius);
        final double fieldLabelSpacing = scaleHeight(_fieldLabelSpacing);
        final double fieldInnerPadding = scaleWidth(_fieldInnerPadding);
        final double buttonBorderRadius = scaleHeight(_buttonBorderRadius);
        final double buttonHeight = scaleHeight(_componentHeight);
        final double labelTopPadding = fieldHeight * 0.12;

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
                    ),
                  ),
                  SizedBox(height: scaleHeight(_fieldButtonSpacing)),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: scaleWidth(_fieldHorizontalPadding),
                    ),
                    child: _EmailSubmitButton(
                      isEnabled: isButtonEnabled,
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

  @override
  Widget build(BuildContext context) {
    final Color borderColor = isActive
        ? const Color(0xFF1573FE)
        : const Color(0xFFE4E4E4);
    final Color backgroundColor = isActive
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
    required this.buttonHeight,
    required this.borderRadius,
    required this.fontSize,
  });

  final bool isEnabled;
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
        onTap: isEnabled ? () {} : null,
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
