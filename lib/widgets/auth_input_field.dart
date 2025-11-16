import 'package:flutter/material.dart';
import '../settings/style.dart';
import '../settings/colors.dart';

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
    this.onSubmitted,
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
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final bool isActiveState = isActive && !showError;
    final Color borderColor = showError
        ? AppColors.textError
        : isActiveState
            ? AppColors.primaryBlue
            : AppColors.borderDefault;
    final Color backgroundColor = showError
        ? AppColors.inputErrorBg
        : isActiveState
            ? AppColors.inputActiveBg
            : AppColors.white;

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
              style: AppTextStyle.fieldLabelAuth(floatingLabelFontSize),
            ),
          if (isActive) SizedBox(height: labelSpacing),
          Expanded(
            child: Center(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                obscureText: isObscure,
                style: AppTextStyle.bodyText(textFontSize),
                cursorColor: AppColors.primaryBlue,
                decoration: InputDecoration(
                  hintText: isActive ? null : hintText,
                  hintStyle: AppTextStyle.fieldHintAuth(hintFontSize),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                keyboardType: keyboardType,
                textInputAction: textInputAction,
                onSubmitted: onSubmitted,
                enableInteractiveSelection: true,
                enableSuggestions: !isObscure,
                autocorrect: !isObscure,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
