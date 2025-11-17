import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../utils/env_utils.dart';

class ProfileService {
  static ProfileService? _instance;
  static ProfileService get instance {
    _instance ??= ProfileService._();
    return _instance!;
  }

  ProfileService._();

  bool _initialized = false;

  // Данные профиля
  String _fullName = 'Тест';
  String _username = 'test';
  String _email = 'test@test.ru';
  String _phone = '+7 777 777-77-77';
  String _country = 'russia';
  String _gender = 'male';

  /// Инициализация - загрузка данных из .env
  Future<void> init() async {
    if (_initialized) return;
    
    try {
      await dotenv.load(fileName: ".env");
      await EnvUtils.mergeRuntimeEnvIntoDotenv();
      
      final fullName = dotenv.env['USER_FULL_NAME'];
      final username = dotenv.env['USER_NICKNAME'];
      final email = dotenv.env['USER_EMAIL'];
      final phone = dotenv.env['USER_PHONE'];
      final country = dotenv.env['USER_COUNTRY'];
      final gender = dotenv.env['USER_GENDER'];
      
      if (fullName != null && fullName.isNotEmpty) _fullName = fullName;
      if (username != null && username.isNotEmpty) _username = username;
      if (email != null && email.isNotEmpty) _email = email;
      if (phone != null && phone.isNotEmpty) _phone = phone;
      if (country != null && country.isNotEmpty) {
        // Преобразуем локализованное название страны в код
        _country = _getCountryCode(country);
      }
      if (gender != null && gender.isNotEmpty) {
        // Преобразуем локализованное название пола в код
        _gender = _getGenderCode(gender);
      }
      
      _initialized = true;
    } catch (e) {
      // При ошибке используем значения по умолчанию
      _initialized = true;
    }
  }

  /// Преобразование локализованного названия страны в код
  String _getCountryCode(String countryName) {
    switch (countryName) {
      case 'Россия':
        return 'russia';
      case 'Казахстан':
        return 'kazakhstan';
      case 'Беларусь':
        return 'belarus';
      default:
        return 'russia';
    }
  }

  /// Преобразование локализованного названия пола в код
  String _getGenderCode(String genderName) {
    switch (genderName) {
      case 'Мужской':
        return 'male';
      case 'Женский':
        return 'female';
      default:
        return 'male';
    }
  }

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

