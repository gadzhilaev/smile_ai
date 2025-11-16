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
}

