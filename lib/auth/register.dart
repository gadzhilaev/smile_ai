import 'package:flutter/material.dart';
import '../settings/style.dart';
import '../settings/colors.dart';
import '../l10n/app_localizations.dart';

class RegistrationPlaceholderScreen extends StatelessWidget {
  const RegistrationPlaceholderScreen({super.key});

  static const double _designWidth = 428;
  static const double _designHeight = 926;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l = AppLocalizations.of(context)!;
    final widthFactor = size.width / _designWidth;
    final heightFactor = size.height / _designHeight;

    double scaleWidth(double value) => value * widthFactor;
    double scaleHeight(double value) => value * heightFactor;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackgroundMain : AppColors.white,
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
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ),
            SizedBox(height: scaleHeight(98)),
            Expanded(
              child: Center(
                child: Text(
                  l.authRegisterPlaceholder,
                  textAlign: TextAlign.center,
                  style: AppTextStyle.bodyTextMedium(
                    scaleWidth(20),
                    color: theme.colorScheme.onSurface,
                  ).copyWith(height: 1.2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
