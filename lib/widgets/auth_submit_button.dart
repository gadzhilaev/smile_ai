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
    this.isLoading = false,
  });

  final String label;
  final bool isEnabled;
  final double buttonHeight;
  final double borderRadius;
  final double fontSize;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bool isButtonActive = isEnabled && !isLoading;
    
    final Color backgroundColor = isButtonActive
        ? AppColors.primaryBlue
        : (isLoading
            ? AppColors.primaryBlue.withValues(alpha: 0.6)
            : (isDark ? AppColors.black : const Color(0xFFD9D9D9)));
    final Color textColor = isButtonActive
        ? AppColors.white
        : (isDark ? AppColors.white : AppColors.textSecondary);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: buttonHeight,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: !isButtonActive && isDark && !isLoading
            ? Border.all(
                color: AppColors.white,
                width: 1,
              )
            : null,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(borderRadius),
        onTap: isButtonActive ? onPressed : null,
        child: Center(
          child: isLoading
              ? SizedBox(
                  width: fontSize * 1.2,
                  height: fontSize * 1.2,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                  ),
                )
              : Text(
            label,
            style: AppTextStyle.screenTitle(fontSize, color: textColor),
          ),
        ),
      ),
    );
  }
}
