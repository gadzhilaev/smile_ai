import 'package:flutter/material.dart';
import '../settings/style.dart';
import '../settings/colors.dart';

class AuthInputField extends StatefulWidget {
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
  State<AuthInputField> createState() => _AuthInputFieldState();
}

class _AuthInputFieldState extends State<AuthInputField> {
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isObscure;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bool isActiveState = widget.isActive && !widget.showError;
    final Color borderColor = widget.showError
        ? AppColors.textError
        : isActiveState
            ? AppColors.primaryBlue
            : (isDark ? AppColors.white : AppColors.borderDefault);
    final Color backgroundColor = widget.showError
        ? Colors.transparent
        : isDark
            ? AppColors.black
            : (isActiveState
                ? AppColors.inputActiveBg
                : AppColors.white);

    final size = MediaQuery.of(context).size;
    final double widthFactor = size.width / 428;
    final double heightFactor = size.height / 926;
    double scaleWidth(double value) => value * widthFactor;
    double scaleHeight(double value) => value * heightFactor;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: widget.fieldHeight,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(color: borderColor, width: 2),
      ),
      padding: EdgeInsets.symmetric(horizontal: widget.innerPadding),
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: widget.isActive
                ? MainAxisAlignment.start
                : MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.isActive) SizedBox(height: widget.labelTopPadding),
              if (widget.isActive)
                Text(
                  widget.labelText,
                  style: AppTextStyle.fieldLabelAuth(widget.floatingLabelFontSize),
                ),
              if (widget.isActive) SizedBox(height: widget.labelSpacing),
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: widget.isObscure
                        ? EdgeInsets.only(right: scaleWidth(32))
                        : EdgeInsets.zero,
                    child: TextField(
                      controller: widget.controller,
                      focusNode: widget.focusNode,
                      obscureText: widget.isObscure ? _obscureText : false,
                      style: AppTextStyle.bodyText(
                        widget.textFontSize,
                        color: isDark ? AppColors.white : AppColors.textPrimary,
                      ),
                      cursorColor: AppColors.primaryBlue,
                      decoration: InputDecoration(
                        hintText: widget.isActive ? null : widget.hintText,
                        hintStyle: AppTextStyle.fieldHintAuth(
                          widget.hintFontSize,
                        ).copyWith(
                          color: isDark
                              ? AppColors.textSecondary
                              : AppColors.textGrey,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      keyboardType: widget.keyboardType,
                      textInputAction: widget.textInputAction,
                      onSubmitted: widget.onSubmitted,
                      enableInteractiveSelection: true,
                      enableSuggestions: !(widget.isObscure ? _obscureText : false),
                      autocorrect: !(widget.isObscure ? _obscureText : false),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (widget.isObscure)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                  child: Container(
                    width: scaleWidth(24),
                    height: scaleHeight(24),
                    alignment: Alignment.center,
                    child: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off,
                      size: scaleHeight(24),
                      color: isDark
                          ? AppColors.white
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
