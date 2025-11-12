import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthSubmitButton extends StatelessWidget {
  const AuthSubmitButton({
    super.key,
    required this.label,
    required this.isEnabled,
    required this.buttonHeight,
    required this.borderRadius,
    required this.fontSize,
    this.onPressed,
  });

  final String label;
  final bool isEnabled;
  final double buttonHeight;
  final double borderRadius;
  final double fontSize;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = isEnabled
        ? const Color(0xFF1573FE)
        : const Color(0xFFD9D9D9);
    final Color textColor = isEnabled
        ? const Color(0xFFFFFFFF)
        : const Color(0xFF757575);

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
            label,
            style: GoogleFonts.montserrat(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: textColor,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}
