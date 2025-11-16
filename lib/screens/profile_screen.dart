import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../settings/style.dart';
import '../settings/colors.dart';

import '../widgets/custom_refresh_indicator.dart';
import '../services/profile_service.dart';
import '../l10n/app_localizations.dart';
import 'account_screen.dart';
import 'notifications_screen.dart';
import 'language_screen.dart';
import 'theme_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const double _designWidth = 428;
  static const double _designHeight = 926;
  final ScrollController _scrollController = ScrollController();

  Future<void> _refreshProfile() async {
    // Сбрасываем позицию прокрутки для полной перестройки страницы
    if (mounted) {
      _scrollController.jumpTo(0);
      setState(() {}); // Обновляем UI с новыми данными из сервиса
    }
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

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

    final double topSectionHeight = scaleHeight(170);
    final double bottomPadding = MediaQuery.of(context).padding.bottom;
    final double navBarHeight = 72.0;

    final double topPadding = MediaQuery.of(context).padding.top;
    final double actualTopSectionHeight = topSectionHeight + topPadding;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackgroundMain : AppColors.backgroundMain,
      body: CustomRefreshIndicator(
        onRefresh: _refreshProfile,
        designWidth: _designWidth,
        designHeight: _designHeight,
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const ClampingScrollPhysics(),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Верхняя секция с фоном #F0EBEB (заливает полностью включая SafeArea)
                  Container(
                    height: actualTopSectionHeight,
                    width: double.infinity,
                    color: isDark
                        ? AppColors.darkBackgroundCard
                        : AppColors.backgroundSection,
                  ),
                  // Нижняя секция с фоном #F7F7F7
                  Container(
                    color:
                        isDark ? AppColors.darkBackgroundMain : AppColors.backgroundMain,
                    child: Column(
                      children: [
                        SizedBox(height: scaleHeight(11) + scaleHeight(130) / 2),
                        // Имя пользователя
                        Center(
                          child: Text(
                            ProfileService.instance.fullName,
                            style: AppTextStyle.interMedium(
                              scaleHeight(28),
                              color: isDark
                                  ? AppTextStyle
                                      .bodyText(scaleHeight(28), color: AppColors.darkPrimaryText)
                                      .color
                                  : null,
                            ),
                          ),
                        ),
                        SizedBox(height: scaleHeight(11)),
                        // Email и телефон
                        Center(
                          child: Text(
                            '${ProfileService.instance.email} | ${ProfileService.instance.phone}',
                            style: AppTextStyle.bodyText(
                              scaleHeight(15),
                              color: isDark
                                  ? AppColors.darkSecondaryText
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                        SizedBox(height: scaleHeight(24)),
                        // Контейнер 1: Учетная запись, Уведомления, Язык
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: scaleWidth(32)),
                        child: Container(
                          width: scaleWidth(364),
                          padding: EdgeInsets.symmetric(
                            horizontal: scaleWidth(23),
                            vertical: scaleHeight(18),
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkBackgroundCard
                                : Colors.white,
                            borderRadius: BorderRadius.circular(scaleHeight(10)),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x1F18274B),
                                offset: Offset(0, 14),
                                blurRadius: 64,
                                spreadRadius: -4,
                              ),
                              BoxShadow(
                                color: Color(0x1F18274B),
                                offset: Offset(0, 8),
                                blurRadius: 22,
                                spreadRadius: -6,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                                InkWell(
                                onTap: () async {
                                  final result = await Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => const AccountScreen(),
                                    ),
                                  );
                                  // Обновляем экран если данные были сохранены
                                  if (result == true && mounted) {
                                    setState(() {});
                                  }
                                },
                                child: _ProfileMenuItem(
                                  iconPath: isDark
                                      ? 'assets/profile_icons/dark/profile_person_dark.svg'
                                      : 'assets/profile_icons/light/profile_person.svg',
                                  title: l.profileMenuAccount,
                                  designWidth: _designWidth,
                                  designHeight: _designHeight,
                                ),
                              ),
                              SizedBox(height: scaleHeight(12)),
                              InkWell(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const NotificationsScreen(),
                                    ),
                                  );
                                },
                                child: _ProfileMenuItem(
                                  iconPath: isDark
                                      ? 'assets/profile_icons/dark/profile_notification_dark.svg'
                                      : 'assets/profile_icons/light/profile_notification.svg',
                                  title: l.profileMenuNotifications,
                                  designWidth: _designWidth,
                                  designHeight: _designHeight,
                                ),
                              ),
                              SizedBox(height: scaleHeight(12)),
                              InkWell(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const LanguageScreen(),
                                    ),
                                  );
                                },
                                child: _ProfileMenuItem(
                                  iconPath: isDark
                                      ? 'assets/profile_icons/dark/profile_language_dark.svg'
                                      : 'assets/profile_icons/light/profile_language.svg',
                                  title: l.profileMenuLanguage,
                                  designWidth: _designWidth,
                                  designHeight: _designHeight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: scaleHeight(20)),
                      // Контейнер 2: Данные и конфиденциальность, Тема
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: scaleWidth(32)),
                        child: Container(
                          width: scaleWidth(364),
                          height: scaleHeight(96),
                          padding: EdgeInsets.symmetric(
                            horizontal: scaleWidth(23),
                            vertical: scaleHeight(18),
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkBackgroundCard
                                : Colors.white,
                            borderRadius: BorderRadius.circular(scaleHeight(10)),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x1F18274B),
                                offset: Offset(0, 14),
                                blurRadius: 64,
                                spreadRadius: -4,
                              ),
                              BoxShadow(
                                color: Color(0x1F18274B),
                                offset: Offset(0, 8),
                                blurRadius: 22,
                                spreadRadius: -6,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _ProfileMenuItem(
                                iconPath: isDark
                                    ? 'assets/profile_icons/dark/profile_privacy_dark.svg'
                                    : 'assets/profile_icons/light/profile_privacy.svg',
                                title: l.profileMenuPrivacy,
                                designWidth: _designWidth,
                                designHeight: _designHeight,
                              ),
                              SizedBox(height: scaleHeight(12)),
                              InkWell(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const ThemeScreen(),
                                    ),
                                  );
                                },
                                child: _ProfileMenuItem(
                                  iconPath: isDark
                                      ? 'assets/profile_icons/dark/profile_theme_dark.svg'
                                      : 'assets/profile_icons/light/profile_theme.svg',
                                  title: l.profileMenuTheme,
                                  designWidth: _designWidth,
                                  designHeight: _designHeight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: scaleHeight(20)),
                      // Контейнер 3: Поддержка, Часто задаваемые вопросы, Политика конфиденциальности
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: scaleWidth(32)),
                        child: Container(
                          width: scaleWidth(364),
                          padding: EdgeInsets.symmetric(
                            horizontal: scaleWidth(23),
                            vertical: scaleHeight(18),
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkBackgroundCard
                                : Colors.white,
                            borderRadius: BorderRadius.circular(scaleHeight(10)),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x1F18274B),
                                offset: Offset(0, 14),
                                blurRadius: 64,
                                spreadRadius: -4,
                              ),
                              BoxShadow(
                                color: Color(0x1F18274B),
                                offset: Offset(0, 8),
                                blurRadius: 22,
                                spreadRadius: -6,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _ProfileMenuItem(
                                iconPath: isDark
                                    ? 'assets/profile_icons/dark/profile_supp_dark.svg'
                                    : 'assets/profile_icons/light/profile_supp.svg',
                                title: l.profileMenuSupport,
                                designWidth: _designWidth,
                                designHeight: _designHeight,
                              ),
                              SizedBox(height: scaleHeight(12)),
                              _ProfileMenuItem(
                                iconPath: isDark
                                    ? 'assets/profile_icons/dark/profile_faq_dark.svg'
                                    : 'assets/profile_icons/light/profile_faq.svg',
                                title: l.profileMenuFaq,
                                designWidth: _designWidth,
                                designHeight: _designHeight,
                              ),
                              SizedBox(height: scaleHeight(12)),
                              _ProfileMenuItem(
                                iconPath: isDark
                                    ? 'assets/profile_icons/dark/profile_lock_dark.svg'
                                    : 'assets/profile_icons/light/profile_lock.svg',
                                title: l.profileMenuPolicy,
                                designWidth: _designWidth,
                                designHeight: _designHeight,
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Отступ для нав бара (только если контент не помещается)
                      SizedBox(height: navBarHeight + bottomPadding),
                    ],
                  ),
                ),
                ],
              ),
              // Аватарка поверх границы секций
              Positioned(
                top: topPadding + scaleHeight(101),
                left: 0,
                right: 0,
                child: Center(
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: scaleWidth(130),
                        height: scaleHeight(130),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: const DecorationImage(
                            image: AssetImage('assets/images/avatar.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      // Круг для редактирования
                      Container(
                        width: scaleWidth(40),
                        height: scaleHeight(40),
                        decoration: BoxDecoration(
                          color: const Color(0xFF898989),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  const _ProfileMenuItem({
    required this.iconPath,
    required this.title,
    required this.designWidth,
    required this.designHeight,
  });

  final String iconPath;
  final String title;
  final double designWidth;
  final double designHeight;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double widthFactor = size.width / designWidth;
    final double heightFactor = size.height / designHeight;

    double scaleWidth(double value) => value * widthFactor;
    double scaleHeight(double value) => value * heightFactor;

    return Row(
      children: [
        SvgPicture.asset(
          iconPath,
          width: scaleWidth(24),
          height: scaleHeight(24),
          fit: BoxFit.contain,
        ),
        SizedBox(width: scaleWidth(12)),
        Expanded(
          child: Text(
            title,
            style: AppTextStyle.interRegular(scaleHeight(16)),
          ),
        ),
      ],
    );
  }
}

