import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Сервис для работы с API
class ApiService {
  ApiService._();

  static final ApiService instance = ApiService._();

  static const String _baseUrl = 'https://alpha-backend-c91h.onrender.com';
  static const Duration _healthCheckTimeout = Duration(minutes: 1);

  /// Проверка здоровья сервера
  /// Возвращает true если сервер доступен (статус 200), false в противном случае
  /// Выбрасывает исключение если запрос не выполнен в течение минуты
  Future<bool> checkHealth() async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/health'),
          )
          .timeout(_healthCheckTimeout);

      return response.statusCode == 200;
    } catch (e) {
      // Если таймаут или другая ошибка - возвращаем false
      return false;
    }
  }

  /// Проверка валидности токена
  /// Возвращает Map с ключами 'valid' (bool) и 'message' (String)
  Future<Map<String, dynamic>> checkToken(String token) async {
    try {
      final url = Uri.parse('$_baseUrl/api/auth/check-token?token=$token');
      debugPrint('ApiService: checking token at URL: $url');
      
      final response = await http.get(url);
      
      debugPrint('ApiService: response status code: ${response.statusCode}');
      debugPrint('ApiService: response body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body) as Map<String, dynamic>;
        debugPrint('ApiService: decoded response: $decoded');
        return decoded;
      } else {
        debugPrint('ApiService: non-200 status code, returning invalid');
        return {
          'valid': false,
          'message': 'error',
        };
      }
    } catch (e) {
      debugPrint('ApiService: error checking token: $e');
      return {
        'valid': false,
        'message': 'error',
      };
    }
  }

  /// Проверка существования пользователя по email
  /// Возвращает Map с ключом 'exists' (bool)
  Future<Map<String, dynamic>> checkUser(String email) async {
    try {
      final url = Uri.parse('$_baseUrl/api/auth/check-user?email=$email');
      debugPrint('ApiService: checking user at URL: $url');
      
      final response = await http.get(url);
      
      debugPrint('ApiService: check-user response status code: ${response.statusCode}');
      debugPrint('ApiService: check-user response body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body) as Map<String, dynamic>;
        debugPrint('ApiService: check-user decoded response: $decoded');
        return decoded;
      } else {
        debugPrint('ApiService: check-user non-200 status code');
        return {
          'exists': false,
        };
      }
    } catch (e) {
      debugPrint('ApiService: error checking user: $e');
      return {
        'exists': false,
      };
    }
  }

  /// Вход пользователя
  /// Возвращает Map с ключами 'token' (String), 'user' (Map), 'message' (String) при успехе
  /// Или 'error' (String) при ошибке
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final url = Uri.parse('$_baseUrl/api/auth/login');
      debugPrint('ApiService: login at URL: $url');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );
      
      debugPrint('ApiService: login response status code: ${response.statusCode}');
      debugPrint('ApiService: login response body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body) as Map<String, dynamic>;
        debugPrint('ApiService: login decoded response: $decoded');
        return decoded;
      } else {
        final decoded = json.decode(response.body) as Map<String, dynamic>;
        debugPrint('ApiService: login error response: $decoded');
        return decoded;
      }
    } catch (e) {
      debugPrint('ApiService: error during login: $e');
      return {
        'error': 'Network error',
      };
    }
  }
}

