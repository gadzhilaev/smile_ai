import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthInputField extends StatelessWidget {
  const AuthInputField({
    super.key,
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
    required this.hintText,
    required this.labelText,
    this.showError = false,
    this.isObscure = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.done,
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
  final String hintText;
  final String labelText;
  final bool showError;
  final bool isObscure;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;

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
              labelText,
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
                obscureText: isObscure,
                style: GoogleFonts.montserrat(
                  fontSize: textFontSize,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                  height: 1,
                ),
                cursorColor: const Color(0xFF1573FE),
                decoration: InputDecoration(
                  hintText: isActive ? null : hintText,
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
                keyboardType: keyboardType,
                textInputAction: textInputAction,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
