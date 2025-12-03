import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'language_service.dart';

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

  /// Регистрация пользователя
  /// Возвращает Map с ключами 'token' (String), 'user' (Map), 'message' (String) при успехе (201)
  /// Или 'error' (String) при ошибке
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String fullName,
    required String nickname,
    required String phone,
    required String country,
    required String gender,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/api/auth/register');
      debugPrint('ApiService: register at URL: $url');
      
      final requestBody = {
        'email': email,
        'password': password,
        'full_name': fullName,
        'nickname': nickname,
        'phone': phone,
        'country': country,
        'gender': gender,
      };
      
      debugPrint('ApiService: register request body: $requestBody');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );
      
      debugPrint('ApiService: register response status code: ${response.statusCode}');
      debugPrint('ApiService: register response body: ${response.body}');

      if (response.statusCode == 201) {
        final decoded = json.decode(response.body) as Map<String, dynamic>;
        debugPrint('ApiService: register decoded response: $decoded');
        return decoded;
      } else {
        final decoded = json.decode(response.body) as Map<String, dynamic>;
        debugPrint('ApiService: register error response: $decoded');
        return decoded;
      }
    } catch (e) {
      debugPrint('ApiService: error during register: $e');
      return {
        'error': 'Network error',
      };
    }
  }

  /// Отправка сообщения в чат
  /// Возвращает Map с ключами 'response' (String), 'message_id' (String), 'timestamp' (String), 'conversation_id' (String), 'files' (dynamic) при успехе
  /// Или 'error' (String) при ошибке
  Future<Map<String, dynamic>> sendMessage({
    required String userId,
    required String message,
    String? category,
    String? conversationId,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/api/chat/message');
      debugPrint('ApiService: sendMessage at URL: $url');
      
      final requestBody = <String, dynamic>{
        'user_id': userId,
        'message': message,
      };
      
      if (category != null && category.isNotEmpty) {
        requestBody['category'] = category;
      }
      
      if (conversationId != null && conversationId.isNotEmpty) {
        requestBody['conversation_id'] = conversationId;
      } else {
        requestBody['conversation_id'] = '';
      }
      
      debugPrint('ApiService: sendMessage request body: $requestBody');
      
      // Получаем текущую локаль из LanguageService
      final currentLocale = LanguageService.instance.localeNotifier.value;
      final acceptLanguage = currentLocale.languageCode == 'ru' ? 'ru' : 'en';
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept-Language': acceptLanguage,
        },
        body: json.encode(requestBody),
      );
      
      debugPrint('ApiService: sendMessage response status code: ${response.statusCode}');
      debugPrint('ApiService: sendMessage response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = json.decode(response.body) as Map<String, dynamic>;
        debugPrint('ApiService: sendMessage decoded response: $decoded');
        return decoded;
      } else {
        final decoded = json.decode(response.body) as Map<String, dynamic>;
        debugPrint('ApiService: sendMessage error response: $decoded');
        return decoded;
      }
    } catch (e) {
      debugPrint('ApiService: error during sendMessage: $e');
      return {
        'error': 'Network error',
      };
    }
  }

  /// Получить топ тренд
  /// Возвращает Map с ключами 'name', 'percent_change', 'description', 'why_popular', 'created_at'
  Future<Map<String, dynamic>> getTopTrend() async {
    try {
      final url = Uri.parse('$_baseUrl/api/analytics/top-trend');
      debugPrint('ApiService: getTopTrend at URL: $url');
      
      final response = await http.get(url);
      
      debugPrint('ApiService: getTopTrend response status code: ${response.statusCode}');
      debugPrint('ApiService: getTopTrend response body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body) as Map<String, dynamic>;
        debugPrint('ApiService: getTopTrend decoded response: $decoded');
        return decoded;
      } else {
        debugPrint('ApiService: getTopTrend error response');
        return {
          'error': 'Failed to load top trend',
        };
      }
    } catch (e) {
      debugPrint('ApiService: error during getTopTrend: $e');
      return {
        'error': 'Network error',
      };
    }
  }

  /// Получить популярность трендов
  /// Возвращает List<Map> с ключами 'name', 'direction', 'percent_change', 'notes', 'created_at'
  Future<List<Map<String, dynamic>>> getPopularity() async {
    try {
      final url = Uri.parse('$_baseUrl/api/analytics/popularity');
      debugPrint('ApiService: getPopularity at URL: $url');
      
      final response = await http.get(url);
      
      debugPrint('ApiService: getPopularity response status code: ${response.statusCode}');
      debugPrint('ApiService: getPopularity response body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body) as List<dynamic>;
        final List<Map<String, dynamic>> result = decoded
            .map((item) => item as Map<String, dynamic>)
            .toList();
        debugPrint('ApiService: getPopularity decoded response: $result');
        return result;
      } else {
        debugPrint('ApiService: getPopularity error response');
        return [];
      }
    } catch (e) {
      debugPrint('ApiService: error during getPopularity: $e');
      return [];
    }
  }

  /// Получить историю чата по conversation_id
  /// Возвращает Map с ключами 'conversation_id', 'count', 'messages' (List)
  Future<Map<String, dynamic>> getChatHistory(String conversationId) async {
    try {
      final url = Uri.parse('$_baseUrl/api/chat/history/$conversationId');
      debugPrint('ApiService: getChatHistory at URL: $url');
      
      final response = await http.get(url);
      
      debugPrint('ApiService: getChatHistory response status code: ${response.statusCode}');
      debugPrint('ApiService: getChatHistory response body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body) as Map<String, dynamic>;
        debugPrint('ApiService: getChatHistory decoded response: $decoded');
        return decoded;
      } else {
        debugPrint('ApiService: getChatHistory error response');
        return {
          'error': 'Failed to load chat history',
        };
      }
    } catch (e) {
      debugPrint('ApiService: error during getChatHistory: $e');
      return {
        'error': 'Network error',
      };
    }
  }

  /// Обновление профиля пользователя
  /// Возвращает Map с данными пользователя при успехе (200)
  /// Или 'error' (String) при ошибке
  Future<Map<String, dynamic>> updateProfile({
    required String token,
    required String email,
    required String fullName,
    required String nickname,
    required String phone,
    required String country,
    required String gender,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/api/auth/profile?token=$token');
      debugPrint('ApiService: updateProfile at URL: $url');
      
      final requestBody = {
        'email': email,
        'full_name': fullName,
        'nickname': nickname,
        'phone': phone,
        'country': country,
        'gender': gender,
      };
      
      debugPrint('ApiService: updateProfile request body: $requestBody');
      
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );
      
      debugPrint('ApiService: updateProfile response status code: ${response.statusCode}');
      debugPrint('ApiService: updateProfile response body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body) as Map<String, dynamic>;
        debugPrint('ApiService: updateProfile decoded response: $decoded');
        return decoded;
      } else {
        final decoded = json.decode(response.body) as Map<String, dynamic>;
        debugPrint('ApiService: updateProfile error response: $decoded');
        return decoded;
      }
    } catch (e) {
      debugPrint('ApiService: error during updateProfile: $e');
      return {
        'error': 'Network error',
      };
    }
  }

  /// Получение профиля пользователя по user_id
  /// Возвращает Map с данными пользователя при успехе (200)
  /// Или 'error' (String) при ошибке
  Future<Map<String, dynamic>> getProfile(String userId) async {
    try {
      final url = Uri.parse('$_baseUrl/api/auth/profile/$userId');
      debugPrint('ApiService: getProfile at URL: $url');
      
      final response = await http.get(url);
      
      debugPrint('ApiService: getProfile response status code: ${response.statusCode}');
      debugPrint('ApiService: getProfile response body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body) as Map<String, dynamic>;
        debugPrint('ApiService: getProfile decoded response: $decoded');
        return decoded;
      } else {
        final decoded = json.decode(response.body) as Map<String, dynamic>;
        debugPrint('ApiService: getProfile error response: $decoded');
        return decoded;
      }
    } catch (e) {
      debugPrint('ApiService: error during getProfile: $e');
      return {
        'error': 'Network error',
      };
    }
  }

  /// Переименование чата
  /// Возвращает Map со статусом при успехе
  Future<Map<String, dynamic>> renameConversation({
    required String userId,
    required String conversationId,
    required String title,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/api/chat/conversations/$conversationId/title');
      debugPrint('ApiService: renameConversation at URL: $url');
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'user_id': userId,
          'title': title,
        }),
      );

      debugPrint('ApiService: renameConversation response status code: ${response.statusCode}');
      debugPrint('ApiService: renameConversation response body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body) as Map<String, dynamic>;
        debugPrint('ApiService: renameConversation decoded response: $decoded');
        return decoded;
      } else {
        return {
          'error': 'Failed to rename conversation',
        };
      }
    } catch (e) {
      debugPrint('ApiService: error during renameConversation: $e');
      return {
        'error': 'Network error',
      };
    }
  }

  /// Удаление чата
  /// Возвращает true при успехе
  Future<bool> deleteConversation({
    required String userId,
    required String conversationId,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/api/chat/conversations/$conversationId');
      debugPrint('ApiService: deleteConversation at URL: $url');
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'user_id': userId,
        }),
      );

      debugPrint('ApiService: deleteConversation response status code: ${response.statusCode}');
      debugPrint('ApiService: deleteConversation response body: ${response.body}');

      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('ApiService: error during deleteConversation: $e');
      return false;
    }
  }

  /// Получение списка чатов пользователя
  /// Возвращает Map с ключами 'conversations' (List) и 'user_id' (String) при успехе
  /// Или 'error' (String) при ошибке
  Future<Map<String, dynamic>> getConversations(String userId) async {
    try {
      final url = Uri.parse('$_baseUrl/api/chat/conversations/$userId');
      debugPrint('ApiService: getConversations at URL: $url');
      
      final response = await http.get(url);
      
      debugPrint('ApiService: getConversations response status code: ${response.statusCode}');
      debugPrint('ApiService: getConversations response body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body) as Map<String, dynamic>;
        debugPrint('ApiService: getConversations decoded response: $decoded');
        return decoded;
      } else {
        debugPrint('ApiService: getConversations error response');
        return {
          'error': 'Failed to load conversations',
        };
      }
    } catch (e) {
      debugPrint('ApiService: error during getConversations: $e');
      return {
        'error': 'Network error',
      };
    }
  }
}

