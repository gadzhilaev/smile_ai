import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Сервис для управления токеном аутентификации
class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  static const String _prefKeyToken = 'auth_token';

  SharedPreferences? _prefs;

  /// Notifier для отслеживания изменений состояния авторизации
  final ValueNotifier<bool> isAuthenticatedNotifier = ValueNotifier<bool>(false);

  /// Инициализация сервиса
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
    _updateAuthState();
  }

  void _updateAuthState() {
    final token = _prefs?.getString(_prefKeyToken);
    final hasToken = token != null && token.isNotEmpty;
    if (isAuthenticatedNotifier.value != hasToken) {
      isAuthenticatedNotifier.value = hasToken;
    }
  }

  /// Получить сохраненный токен
  String? getToken() {
    final token = _prefs?.getString(_prefKeyToken);
    debugPrint('AuthService: getToken() called, token: ${token ?? "null"}');
    return token;
  }

  /// Сохранить токен
  Future<void> saveToken(String token) async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setString(_prefKeyToken, token);
    debugPrint('AuthService: token saved: $token');
    _updateAuthState();
  }

  /// Удалить токен
  Future<void> clearToken() async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.remove(_prefKeyToken);
    _updateAuthState();
  }

  /// Проверить наличие токена
  bool hasToken() {
    final token = getToken();
    return token != null && token.isNotEmpty;
  }
}

