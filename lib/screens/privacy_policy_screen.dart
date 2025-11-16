import 'package:flutter/material.dart';

import '../settings/style.dart';
import '../settings/colors.dart';
import '../l10n/app_localizations.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const double _designWidth = 428;
  static const double _designHeight = 926;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final size = MediaQuery.of(context).size;
    final double widthFactor = size.width / _designWidth;
    final double heightFactor = size.height / _designHeight;

    double scaleWidth(double value) => value * widthFactor;
    double scaleHeight(double value) => value * heightFactor;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackgroundMain : AppColors.white,
      body: SafeArea(
        top: true,
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    left: scaleWidth(20),
                    // right: scaleWidth(26),
                    top: scaleHeight(18),
                  ),
                  child: Row(
                    children: [
                      InkWell(
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
                      Expanded(
                        child: Center(
                          child: Text(
                            l.privacyTitle,
                            style: AppTextStyle.screenTitle(
                              scaleHeight(18),
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: scaleWidth(28)),
                    ],
                  ),
                ),
                SizedBox(height: scaleHeight(30)),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: scaleWidth(20),
                      vertical: 0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // "Политика конфиденциальности Smile AI"
                        Text(
                          l.privacyHeading,
                          style: AppTextStyle.screenTitle(
                            scaleHeight(16),
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: scaleHeight(16)),
                        Text(
                          l.privacyIntro,
                          style: AppTextStyle.bodyText(
                            scaleHeight(14),
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: scaleHeight(16)),

                        // 1.
                        Text(
                          l.privacySection1Title,
                          style: AppTextStyle.bodyTextBold(
                            scaleHeight(16),
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: scaleHeight(16)),
                        Text(
                          l.privacySection1Body,
                          style: AppTextStyle.bodyText(
                            scaleHeight(14),
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: scaleHeight(16)),

                        // 2.
                        Text(
                          l.privacySection2Title,
                          style: AppTextStyle.bodyTextBold(
                            scaleHeight(16),
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: scaleHeight(16)),
                        Text(
                          l.privacySection2Body,
                          style: AppTextStyle.bodyText(
                            scaleHeight(14),
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: scaleHeight(16)),

                        // 3.
                        Text(
                          l.privacySection3Title,
                          style: AppTextStyle.bodyTextBold(
                            scaleHeight(16),
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: scaleHeight(16)),
                        Text(
                          l.privacySection3Body,
                          style: AppTextStyle.bodyText(
                            scaleHeight(14),
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: scaleHeight(16)),

                        // 4.
                        Text(
                          l.privacySection4Title,
                          style: AppTextStyle.bodyTextBold(
                            scaleHeight(16),
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: scaleHeight(16)),
                        Text(
                          l.privacySection4Body,
                          style: AppTextStyle.bodyText(
                            scaleHeight(14),
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: scaleHeight(16)),

                        // 5.
                        Text(
                          l.privacySection5Title,
                          style: AppTextStyle.bodyTextBold(
                            scaleHeight(16),
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: scaleHeight(16)),
                        Text(
                          l.privacySection5Body,
                          style: AppTextStyle.bodyText(
                            scaleHeight(14),
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: scaleHeight(16)),

                        // 6.
                        Text(
                          l.privacySection6Title,
                          style: AppTextStyle.bodyTextBold(
                            scaleHeight(16),
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: scaleHeight(16)),
                        Text(
                          l.privacySection6Body,
                          style: AppTextStyle.bodyText(
                            scaleHeight(14),
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: scaleHeight(16)),

                        // 7.
                        Text(
                          l.privacySection7Title,
                          style: AppTextStyle.bodyTextBold(
                            scaleHeight(16),
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: scaleHeight(16)),
                        Text(
                          l.privacySection7Body,
                          style: AppTextStyle.bodyText(
                            scaleHeight(14),
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: scaleHeight(40)),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}


