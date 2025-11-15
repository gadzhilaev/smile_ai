class ProfileService {
  static ProfileService? _instance;
  static ProfileService get instance {
    _instance ??= ProfileService._();
    return _instance!;
  }

  ProfileService._();

  // Данные профиля
  String _fullName = 'Тест';
  String _username = 'test';
  String _email = 'test@test.ru';
  String _phone = '+7 777 777-77-77';
  String _country = 'russia';
  String _gender = 'male';

  // Getters
  String get fullName => _fullName;
  String get username => _username;
  String get email => _email;
  String get phone => _phone;
  String get country => _country;
  String get gender => _gender;

  // Метод для обновления данных профиля
  void updateProfile({
    String? fullName,
    String? username,
    String? email,
    String? phone,
    String? country,
    String? gender,
  }) {
    if (fullName != null) _fullName = fullName;
    if (username != null) _username = username;
    if (email != null) _email = email;
    if (phone != null) _phone = phone;
    if (country != null) _country = country;
    if (gender != null) _gender = gender;
  }

  // Метод для получения всех данных
  Map<String, String> getAllData() {
    return {
      'fullName': _fullName,
      'username': _username,
      'email': _email,
      'phone': _phone,
      'country': _country,
      'gender': _gender,
    };
  }
}

