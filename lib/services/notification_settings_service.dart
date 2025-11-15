class NotificationSettingsService {
  static NotificationSettingsService? _instance;
  static NotificationSettingsService get instance {
    _instance ??= NotificationSettingsService._();
    return _instance!;
  }

  NotificationSettingsService._();

  // Настройки уведомлений
  bool _allNotifications = true;
  bool _sound = true;
  bool _vibration = true;
  bool _updates = true;
  bool _promotions = true;

  // Getters
  bool get allNotifications => _allNotifications;
  bool get sound => _sound;
  bool get vibration => _vibration;
  bool get updates => _updates;
  bool get promotions => _promotions;

  // Методы для обновления настроек
  void setAllNotifications(bool value) {
    _allNotifications = value;
    if (!value) {
      // Если выключаем все уведомления, выключаем звук и вибрацию
      _sound = false;
      _vibration = false;
    }
  }

  void setSound(bool value) {
    _sound = value;
    // Если включаем звук, включаем все уведомления
    if (value) {
      _allNotifications = true;
    } else {
      // Если выключаем звук, проверяем вибрацию
      // Если и звук и вибрация выключены, выключаем все уведомления
      if (!_vibration) {
        _allNotifications = false;
      }
    }
  }

  void setVibration(bool value) {
    _vibration = value;
    // Если включаем вибрацию, включаем все уведомления
    if (value) {
      _allNotifications = true;
    } else {
      // Если выключаем вибрацию, проверяем звук
      // Если и звук и вибрация выключены, выключаем все уведомления
      if (!_sound) {
        _allNotifications = false;
      }
    }
  }

  void setUpdates(bool value) {
    _updates = value;
  }

  void setPromotions(bool value) {
    _promotions = value;
  }

  // Проверка, должны ли показываться уведомления
  bool shouldShowNotifications() {
    return _allNotifications;
  }
}

