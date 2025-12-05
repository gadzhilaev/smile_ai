import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart';

/// Сервис для работы с API поддержки
class SupportService {
  SupportService._();

  static final SupportService instance = SupportService._();

  // URL сервера поддержки
  static const String baseUrl = 'http://84.201.149.99:5000';

  /// Отправка сообщения с возможностью прикрепления одного или нескольких фото
  static Future<Map<String, dynamic>> sendMessage({
    required String userId,
    String? userName,
    required String message,
    File? photo, // Для обратной совместимости
    List<File>? photos, // Поддержка нескольких фото
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/send_message'),
      );

      // Добавляем текстовые данные
      request.fields['user_id'] = userId;
      if (userName != null) {
        request.fields['user_name'] = userName;
      }
      request.fields['message'] = message;

      // Добавляем фото (поддержка одного или нескольких)
      if (photos != null && photos.isNotEmpty) {
        // Несколько фото
        for (var photoFile in photos) {
          var photoStream = http.ByteStream(photoFile.openRead());
          var photoLength = await photoFile.length();
          var multipartFile = http.MultipartFile(
            'photo', // Одинаковое имя для всех фото
            photoStream,
            photoLength,
            filename: path.basename(photoFile.path),
          );
          request.files.add(multipartFile);
        }
      } else if (photo != null) {
        // Одно фото (для обратной совместимости)
        var photoStream = http.ByteStream(photo.openRead());
        var photoLength = await photo.length();
        var multipartFile = http.MultipartFile(
          'photo',
          photoStream,
          photoLength,
          filename: path.basename(photo.path),
        );
        request.files.add(multipartFile);
      }

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return json.decode(responseBody);
      } else {
        throw Exception('Ошибка отправки: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('SupportService: ошибка при отправке сообщения: $e');
      throw Exception('Ошибка при отправке сообщения: $e');
    }
  }

  /// Получение истории переписки
  static Future<List<Map<String, dynamic>>> getMessageHistory(
    String userId, {
    int limit = 50,
    String? userName, // Имя пользователя для приветственного сообщения
  }) async {
    try {
      var uri = Uri.parse('$baseUrl/message_history/$userId?limit=$limit');
      if (userName != null && userName.isNotEmpty) {
        uri = uri.replace(queryParameters: {
          'limit': limit.toString(),
          'user_name': userName,
        });
      }
      
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['messages'] ?? []);
      } else {
        debugPrint('SupportService: ошибка получения истории: ${response.statusCode}');
        throw Exception('Ошибка получения истории: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('SupportService: ошибка при получении истории: $e');
      throw Exception('Ошибка при получении истории: $e');
    }
  }

  /// Регистрация токена устройства для push уведомлений
  static Future<void> registerDevice({
    required String userId,
    required String fcmToken,
    required String platform,
    String? deviceId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register_device'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': userId,
          'fcm_token': fcmToken,
          'platform': platform,
          'device_id': deviceId,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        debugPrint('SupportService: ошибка регистрации устройства: ${response.statusCode}');
        throw Exception('Ошибка регистрации устройства: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('SupportService: ошибка при регистрации устройства: $e');
      throw Exception('Ошибка при регистрации устройства: $e');
    }
  }
}

