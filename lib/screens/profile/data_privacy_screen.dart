import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../settings/colors.dart';
import '../../settings/style.dart';

class DataPrivacyScreen extends StatelessWidget {
  const DataPrivacyScreen({super.key});

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
                      SizedBox(width: scaleWidth(10)),
                      Expanded(
                        child: Text(
                          l.profileMenuPrivacy,
                          style: AppTextStyle.screenTitle(
                            scaleHeight(18),
                            color: theme.colorScheme.onSurface,
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
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // "Smile AI заботится о вашей конфиденциальности."
                        Text(
                          l.dataPrivacyIntroTitle,
                          style: AppTextStyle.bodyTextBold(
                            scaleHeight(16),
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: scaleHeight(16)),
                        // Описание
                        Text(
                          l.dataPrivacyIntroBody,
                          style: AppTextStyle.bodyText(
                            scaleHeight(14),
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: scaleHeight(16)),

                        // "Что мы собираем:"
                        Text(
                          l.dataPrivacyWhatTitle,
                          style: AppTextStyle.bodyTextBold(
                            scaleHeight(16),
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: scaleHeight(16)),
                        Text(
                          l.dataPrivacyWhatBody,
                          style: AppTextStyle.bodyText(
                            scaleHeight(14),
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: scaleHeight(16)),

                        // "Для чего это нужно:"
                        Text(
                          l.dataPrivacyWhyTitle,
                          style: AppTextStyle.bodyTextBold(
                            scaleHeight(16),
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: scaleHeight(16)),
                        Text(
                          l.dataPrivacyWhyBody,
                          style: AppTextStyle.bodyText(
                            scaleHeight(14),
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: scaleHeight(16)),

                        // "Мы не передаём данные..."
                        Text(
                          l.dataPrivacyNoShare,
                          style: AppTextStyle.bodyTextBold(
                            scaleHeight(14),
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: scaleHeight(16)),

                        // "Вы можете запросить удаление данных..."
                        Text(
                          l.dataPrivacyDelete,
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


