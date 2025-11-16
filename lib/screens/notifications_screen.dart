import 'package:flutter/material.dart';
import '../settings/style.dart';
import '../settings/colors.dart';
import '../services/notification_settings_service.dart';
import '../services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  static const double _designWidth = 428;
  static const double _designHeight = 926;

  final NotificationSettingsService _settingsService =
      NotificationSettingsService.instance;

  bool _allNotifications = true;
  bool _sound = true;
  bool _vibration = true;
  bool _updates = true;
  bool _promotions = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    setState(() {
      _allNotifications = _settingsService.allNotifications;
      _sound = _settingsService.sound;
      _vibration = _settingsService.vibration;
      _updates = _settingsService.updates;
      _promotions = _settingsService.promotions;
    });
  }

  void _updateAllNotifications(bool value) async {
    setState(() {
      _allNotifications = value;
      _settingsService.setAllNotifications(value);
      _sound = _settingsService.sound;
      _vibration = _settingsService.vibration;
    });
    // Обновляем канал уведомлений с новыми настройками
    await NotificationService.instance.updateNotificationSettings();
  }

  void _updateSound(bool value) async {
    setState(() {
      _sound = value;
      _settingsService.setSound(value);
      _allNotifications = _settingsService.allNotifications;
    });
    // Обновляем канал уведомлений с новыми настройками
    await NotificationService.instance.updateNotificationSettings();
  }

  void _updateVibration(bool value) async {
    setState(() {
      _vibration = value;
      _settingsService.setVibration(value);
      _allNotifications = _settingsService.allNotifications;
    });
    // Обновляем канал уведомлений с новыми настройками
    await NotificationService.instance.updateNotificationSettings();
  }

  void _updateUpdates(bool value) {
    setState(() {
      _updates = value;
      _settingsService.setUpdates(value);
    });
  }

  void _updatePromotions(bool value) {
    setState(() {
      _promotions = value;
      _settingsService.setPromotions(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double widthFactor = size.width / _designWidth;
    final double heightFactor = size.height / _designHeight;

    double scaleWidth(double value) => value * widthFactor;
    double scaleHeight(double value) => value * heightFactor;

    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          top: true,
          bottom: false,
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Стрелка назад и заголовок
                Padding(
                  padding: EdgeInsets.only(
                    left: scaleWidth(18),
                    top: scaleHeight(18),
                    right: scaleWidth(26),
                  ),
                  child: Row(
                    children: [
                      // Стрелка назад
                      InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        borderRadius: BorderRadius.circular(scaleWidth(16)),
                        child: Padding(
                          padding: EdgeInsets.all(scaleWidth(4)),
                          child: Icon(
                            Icons.arrow_back,
                            size: scaleWidth(28),
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            'Уведомления',
                            style: AppTextStyle.screenTitle(scaleHeight(20)),
                          ),
                        ),
                      ),
                      SizedBox(width: scaleWidth(28)), // Для выравнивания
                    ],
                  ),
                ),
                SizedBox(height: scaleHeight(44)),
                // Контент
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: scaleWidth(26)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Заголовок "Общие"
                      Text(
                        'Общие',
                        style: AppTextStyle.screenTitle(scaleHeight(16)),
                      ),
                      SizedBox(height: scaleHeight(14)),
                      // Все уведомления
                      _NotificationSwitchRow(
                        title: 'Все уведомления',
                        value: _allNotifications,
                        onChanged: _updateAllNotifications,
                        scaleWidth: scaleWidth,
                        scaleHeight: scaleHeight,
                      ),
                      SizedBox(height: scaleHeight(12)),
                      // Звук
                      _NotificationSwitchRow(
                        title: 'Звук',
                        value: _sound,
                        onChanged: _updateSound,
                        scaleWidth: scaleWidth,
                        scaleHeight: scaleHeight,
                      ),
                      SizedBox(height: scaleHeight(12)),
                      // Вибрация
                      _NotificationSwitchRow(
                        title: 'Вибрация',
                        value: _vibration,
                        onChanged: _updateVibration,
                        scaleWidth: scaleWidth,
                        scaleHeight: scaleHeight,
                      ),
                      SizedBox(height: scaleHeight(26)),
                      // Разделительная линия
                      Container(
                        height: 1,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: AppColors.dividerLight,
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: scaleHeight(18)),
                      // Заголовок "Системные уведомления"
                      Text(
                        'Системные уведомления',
                        style: AppTextStyle.screenTitle(scaleHeight(16)),
                      ),
                      SizedBox(height: scaleHeight(16)),
                      // Обновления
                      _NotificationSwitchRow(
                        title: 'Обновления',
                        value: _updates,
                        onChanged: _updateUpdates,
                        scaleWidth: scaleWidth,
                        scaleHeight: scaleHeight,
                      ),
                      SizedBox(height: scaleHeight(12)),
                      // Продвижение
                      _NotificationSwitchRow(
                        title: 'Продвижение',
                        value: _promotions,
                        onChanged: _updatePromotions,
                        scaleWidth: scaleWidth,
                        scaleHeight: scaleHeight,
                      ),
                      SizedBox(height: scaleHeight(40)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Виджет строки с переключателем
class _NotificationSwitchRow extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  final double Function(double) scaleWidth;
  final double Function(double) scaleHeight;

  const _NotificationSwitchRow({
    required this.title,
    required this.value,
    required this.onChanged,
    required this.scaleWidth,
    required this.scaleHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTextStyle.bodyText(scaleHeight(16)),
        ),
        _CustomSwitch(
          value: value,
          onChanged: onChanged,
          scaleWidth: scaleWidth,
          scaleHeight: scaleHeight,
        ),
      ],
    );
  }
}

// Кастомный переключатель
class _CustomSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final double Function(double) scaleWidth;
  final double Function(double) scaleHeight;

  const _CustomSwitch({
    required this.value,
    required this.onChanged,
    required this.scaleWidth,
    required this.scaleHeight,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        width: scaleWidth(40),
        height: scaleHeight(20),
        decoration: BoxDecoration(
          color: value ? AppColors.primaryBlue : const Color(0xFFD9D9D9),
          borderRadius: BorderRadius.circular(scaleHeight(10)),
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              left: value ? scaleWidth(40 - 16 - 3) : scaleWidth(3),
              top: scaleHeight((20 - 16) / 2),
              child: Container(
                width: scaleWidth(16),
                height: scaleHeight(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFEEEEEE),
                    width: 0.51,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
