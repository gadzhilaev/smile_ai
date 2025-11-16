import 'package:flutter/material.dart';
import '../settings/style.dart';
import '../settings/colors.dart';

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color backgroundColor = isEnabled
        ? AppColors.primaryBlue
        : (isDark ? AppColors.black : const Color(0xFFD9D9D9));
    final Color textColor = isEnabled
        ? AppColors.white
        : (isDark ? AppColors.white : AppColors.textSecondary);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: buttonHeight,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: !isEnabled && isDark
            ? Border.all(
                color: AppColors.white,
                width: 1,
              )
            : null,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(borderRadius),
        onTap: isEnabled ? onPressed : null,
        child: Center(
          child: Text(
            label,
            style: AppTextStyle.screenTitle(fontSize, color: textColor),
          ),
        ),
      ),
    );
  }
}
