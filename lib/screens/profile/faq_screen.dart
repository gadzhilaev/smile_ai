import 'package:flutter/material.dart';

import '../../settings/style.dart';
import '../../settings/colors.dart';
import '../../l10n/app_localizations.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  static const double _designWidth = 428;
  static const double _designHeight = 926;

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  // Индекс открытого вопроса, -1 — все закрыты
  int _expandedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final size = MediaQuery.of(context).size;
    final double widthFactor = size.width / FaqScreen._designWidth;
    final double heightFactor = size.height / FaqScreen._designHeight;

    double scaleWidth(double value) => value * widthFactor;
    double scaleHeight(double value) => value * heightFactor;

    final questions = <String>[
      l.faqQuestion1,
      l.faqQuestion2,
      l.faqQuestion3,
      l.faqQuestion4,
      l.faqQuestion5,
    ];

    final answers = <String>[
      l.faqAnswer1,
      l.faqAnswer2,
      l.faqAnswer3,
      l.faqAnswer4,
      l.faqAnswer5,
    ];

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
                        child: Center(
                          child: Text(
                            l.profileMenuFaq,
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
                      horizontal: scaleWidth(25),
                    ),
                    child: Column(
                      children: List.generate(questions.length, (index) {
                        final bool isExpanded = _expandedIndex == index;

                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: index == questions.length - 1
                                ? scaleHeight(0)
                                : scaleHeight(12),
                          ),
                          child: _FaqItem(
                            question: questions[index],
                            answer: answers[index],
                            isExpanded: isExpanded,
                            onTap: () {
                              setState(() {
                                if (_expandedIndex == index) {
                                  _expandedIndex = -1;
                                } else {
                                  _expandedIndex = index;
                                }
                              });
                            },
                            designWidth: FaqScreen._designWidth,
                            designHeight: FaqScreen._designHeight,
                          ),
                        );
                      }),
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

class _FaqItem extends StatelessWidget {
  const _FaqItem({
    required this.question,
    required this.answer,
    required this.isExpanded,
    required this.onTap,
    required this.designWidth,
    required this.designHeight,
  });

  final String question;
  final String answer;
  final bool isExpanded;
  final VoidCallback onTap;
  final double designWidth;
  final double designHeight;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double widthFactor = size.width / designWidth;
    final double heightFactor = size.height / designHeight;

    double scaleWidth(double value) => value * widthFactor;
    double scaleHeight(double value) => value * heightFactor;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final borderColor = isDark ? AppColors.white : const Color(0xFF5B5B5B);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(scaleHeight(12)),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      child: Container(
        width: scaleWidth(377),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(scaleHeight(12)),
          border: Border.all(
            color: borderColor,
            width: 1,
          ),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: scaleWidth(21),
          vertical: scaleHeight(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    question,
                    style: AppTextStyle.screenTitle(
                      scaleHeight(16),
                      color: isDark ? AppColors.white : AppColors.black,
                    ),
                  ),
                ),
                SizedBox(width: scaleWidth(12)),
                Icon(
                  isExpanded ? Icons.remove : Icons.add,
                  size: scaleWidth(24),
                  color: isDark ? AppColors.white : AppColors.black,
                ),
              ],
            ),
            if (isExpanded) ...[
              SizedBox(height: scaleHeight(11)),
              Text(
                answer,
                style: AppTextStyle.bodyText(
                  scaleHeight(16),
                  color: isDark
                      ? AppColors.darkSecondaryText
                      : const Color(0xFF474747),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}


